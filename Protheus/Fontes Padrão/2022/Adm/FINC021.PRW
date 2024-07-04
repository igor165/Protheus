#Include "FINC021.CH"
#Include "PROTHEUS.CH"
#Include "MSGRAPHI.CH"
#Include "FILEIO.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE DATAFLUXO				1
#DEFINE ENTRADAS				2
#DEFINE SAIDAS					3
#DEFINE SALDODIA				4
#DEFINE VARIACAODIA				5
#DEFINE ENTRADASACUMULADAS		6
#DEFINE SAIDASACUMULADAS 		7
#DEFINE SALDOACUMULADO 			8
#DEFINE VARIACAOACUMULADA		9
#DEFINE DEF_POS_TITPAI			1
#DEFINE DEF_POS_DTTRAB			2

Static lFWCodFil 	:= .T.
Static aSitCob		:= NIL
Static aPswUser		:= NIL
Static aPswGrupo	:= NIL
Static lConsDtB 	:= .F.
Static nValorPA		:= 0
Static _oFINC0211
Static _oFINC0212
Static _oFINC0213
Static _oFINC0214
Static _oFINC0215
Static _oFINC0216
Static _oFINC0217
Static _oFINC0218
Static _oFINC0219
Static _oFINC021a
Static _oFINC021b
Static _oFINC021c
Static _oFINC021d
Static _oFINC021e
Static _oFINC021f
Static _oFINC021g
Static __lHTML 		:= (GetRemoteType() == 5)
Static lSC7Exclus 	:= FwModeAccess("SC7") == "E"
Static __oSE1TMP	As Object
Static __oSE1NAT	As Object
Static __oSE2TMP	As Object
Static __oSE2NAT	As Object
Static __cCposSE1	As Character
Static __cCposSE2	As Character
Static __cInsNat1	As Character
Static __cInsNat2	As Character
Static __lMetric	:= FwLibVersion() >= "20210517"
Static __cSGBD		As Character

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FINC021	³ Autor ³ Claudio D. de Souza   ³ Data ³ 04/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fluxo de Caixa 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINC021()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Finc021()
Local cAlias		:= Alias()
Local cCampo		:= Right(cAlias,2)							//FSM - 02/06/2011
Local nCaixas		:= 0										// Total em caixa
Local nBancos		:= 0										// Total em bancos
Local oDlg
Local oGet01
Local oGetFilDe
Local oSelFil
Local oGetFilAte
Local cVisaoG		:= Space(3)
Local lReceber		:= .T.
Local lPagar		:= .T.
Local lComissoes	:= .T.
Local lPedVenda		:= .T.
Local lPedCompra	:= .T.
Local lAplicacoes	:= .F.
Local lSaldoBanc	:= .F.
Local lAnalitico	:= .F.
Local lConsFil		:= .F.
Local lConsDtBase	:= .F.
Local lTitAtraso	:= .F.
Local nTamFilial	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3(cCampo+"_FILIAL")[1] )
Local cTipoSaldo
Local cFilDe		:= Space( nTamFilial )
Local cFilAte		:= Replicate( "Z", nTamFilial )
Local nMoeda		:= 1
Local aMoedas		:= {}
Local cMoeda
Local cPeriodo
Local nPeriodos		:= 10
Local nOpcA			:= 0
Local lTitFuturo	:= .F.
Local lCtrc			:= .F.
Local nLin
Local lLimCred		:= .T.										// Considera Limite de crédito bancário
Local nLimCred		:= 0										// Limite de credito bancario
Local lDMSCompra	:= .F.
Local lDMSVenda		:= .F.
Local aBancos		:= {}
Local aAplic		:= {}
Local aCmbPer
Local cFilterSe1
Local cFilterSe2
Local cBancoCx		:= GetMV("MV_CARTEIR")
Local nHandle
Local cLog			:= Space(69)
Local nOffSet		:= 0
Local aTipoSaldo
Local oPedidos
Local cPedidos		:= "3"
Local aPedidos		:= { STR0224, STR0225, STR0226 }			// "1-Liberados", "2-Bloqueados", "3-Ambos"
Local oSinalRA
Local cSinalRA		:= '-'
Local aSinalRA		:= {'+','-'}
Local nX			:= 0
Local lPesqUsu
Local aButtonTxt	:= {}
Local cSaldo		:= ""
Local aSaldo		:= {}
Local oSaldo
Local lBcoExcl		:= !Empty( xFilial("SA6") )
Local lPanelFin		:= IsPanelFin()
Local lSolFundo		:= .F.										//Considera as solicitacoes de fundo
Local nWndHeight	:= 0										//Altura da janela
//Variaveis da grid de selecao das situacoes dos titulos
Local oOk			:= LoadBitmap( GetResources(), "LBOK" )		//CHECKED    //LBOK  //LBTIK
Local oNo			:= LoadBitmap( GetResources(), "LBNO" )		//UNCHECKED  //LBNO
Local cEmpresa := FWCodEmp()
Local aTxmoe        := {}
Local cTxMoe        := ""
Local oGetTxMoe     := Nil
Local lTxMoePed     := .F.
Private lAgrpVis	:= .F.										//WHRS 01/08/2017 Não era possivel compilar o fonte sem essa variavel TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exportação
//Variaveis da grid de selecao das situacoes dos titulos
Private oLbx		:= Nil
Private aVetor		:= {}
Private cErros		:= ""										//Utilizada na funcao que interpreta a formula de reajuste do pedido de compra
Private aBackSC7	:= {}										//Utilizada na visualizacao do pedido de compra (Mata120)
Private lFirst		:= .F.										//Utilizada na seleção dos bancos se a opção Saldos Bancarios estiver selecionada.
Private lIntGC		:= ( SuperGetMV("MV_VEICULO",,"N") == "S" )
Private lFiliais	:= .F.
Private aSelFil		:= {}
Private cLisFil		:= ""


If GetRpoRelease() >= "12.1.033" .and. FindFunction("MsgExpRot")
	MsgExpRot("FINC021",;
				STR0294,; //"Novo gestor financeiro FINA710" 
				"https://tdn.totvs.com/pages/viewpage.action?pageId=611007335", "20220820" ) 
	if Date() >= CTOD("20/08/2022")
		MsgAlert(STR0295, STR0296) //"Rotina descontinuada" # "Alerta"
		Return
	Endif			
EndIf

aCmbPer := {STR0001,; //"01 Diario"
			STR0002,; //"07 Semanal"
			STR0003,; //"10 Decendial"
			STR0004,; //"15 Quinzenal"
			STR0005 } //"30 Mensal"

aTipoSaldo := {	STR0217,; // "1-Normal
				STR0218,; // "2-Conciliado
				STR0219 } // "3-Não Conciliado

aSaldo := {STR0234,STR0235}

aTxmoe := {STR0282,STR0283}
cTxMoe := STR0283

If __cSGBD == Nil
	__cSGBD := AllTrim(Upper(TcGetDb()))
EndIf

//Inicializa array com as moedas existentes. Para montar o combo de moedas
aMoedas := GetMoedas()
ASort(aMoedas)

//Carrega as opcoes gravadas para o usuario
If File("FINC021.PAR")

	nHandle := fOpen("FINC021.PAR",2)

	If (lPesqUsu := PesqUsu(nHandle,@cLog,@nOffSet)) // Pesquisa o usuario atual

		If !lFWCodFil
			lReceber 	:= Substr(cLog,21,1) == "S"
			lPagar		:= Substr(cLog,22,1) == "S"
			lComissoes	:= Substr(cLog,23,1) == "S"
			lPedVenda	:= Substr(cLog,24,1) == "S"
			lPedCompra  := Substr(cLog,25,1) == "S"
			lAplicacoes := Substr(cLog,26,1) == "S"
			lTitAtraso	:= Substr(cLog,27,1) == "S"
			lConsFil	:= Substr(cLog,28,1) == "S"

			If lConsFil .Or. lFiliais
				cFilDe	:= Substr(cLog,29, 2 )
				cFilAte	:= Substr(cLog,31, 2 )
			EndIf

			cPeriodo	:= Substr(cLog,33,12)
			nPeriodos   := Val(Substr(cLog,45,4))
			cMoeda 		:= Substr(cLog,49,15)
			lAnalitico 	:= Substr(cLog,64,1) == "S"
			lConsDtBase	:= Substr(cLog,65,1) == "S"
			cTipoSaldo	:= aTipoSaldo[If(Val(Substr(cLog,66,1)) > 0,Val(Substr(cLog,66,1)),1)]
			lTitFuturo	:= Substr(cLog,67,1) == "S"
			lCtrc		:= Substr(cLog,68,1) == "S"
			cPedidos	:= Substr(cLog,69,1)
			cSinalRA    := Substr(cLog,70,1)

            /*_*/
            lSaldoBanc  := Substr(cLog,71,1) == "S"
            /*_*/

            If cPaisLoc == "ARG"
               lSolFundo := Substr(cLog,72,1) == "S"
            EndIf

			lDMSCompra 	:= Substr(cLog,73,1) == "S" .And. lIntGC
			lDMSVenda 	:= Substr(cLog,74,1) == "S" .And. lIntGC

		Else
			lReceber 	:= Substr(cLog,21,1) == "S"
			lPagar		:= Substr(cLog,22,1) == "S"
			lComissoes	:= Substr(cLog,23,1) == "S"
			lPedVenda	:= Substr(cLog,24,1) == "S"
			lPedCompra  := Substr(cLog,25,1) == "S"
			lAplicacoes := Substr(cLog,26,1) == "S"
			lTitAtraso	:= Substr(cLog,27,1) == "S"
			lConsFil	:= Substr(cLog,28,1) == "S"

			If lConsFil .Or. lFiliais
				cFilDe	:= Substr(cLog,29, 12 )
				cFilAte	:= Substr(cLog,41, 12 )
			EndIf

			cPeriodo	:= Substr(cLog,53,12)
			nPeriodos   := Val(Substr(cLog,65,4))
			cMoeda 		:= Substr(cLog,69,15)
			lAnalitico 	:= Substr(cLog,84,1) == "S"
			lConsDtBase	:= Substr(cLog,85,1) == "S"
			cTipoSaldo	:= aTipoSaldo[If(Val(Substr(cLog,86,1)) > 0,Val(Substr(cLog,86,1)),1)]
			lTitFuturo	:= Substr(cLog,87,1) == "S"
			lCtrc		:= Substr(cLog,88,1) == "S"
			cPedidos	:= Substr(cLog,89,1)
			cSinalRA    := Substr(cLog,90,1)

            /*_*/
            lSaldoBanc  := Substr(cLog,91,1) == "S"
            /*_*/

            If cPaisLoc == "ARG"
               lSolFundo := Substr(cLog,92,1) == "S"
            EndIf

			lDMSCompra 	:= Substr(cLog,93,1) == "S" .And. lIntGC
			lDMSVenda 	:= Substr(cLog,94,1) == "S" .And. lIntGC

		EndIf

	EndIf

EndIf

fClose(nHandle)

If Empty(cPedidos)
	cPedidos := "3"
Endif

//--------------------------
// Ajuste da altura da tela
//--------------------------
nWndHeight := 460
If(IntTms()			,nWndHeight += 20	,Nil)
If( lIntGC			,nWndHeight += 20	,Nil)
If(cPaisLoc == "ARG",nWndHeight += 230	,Nil)

cPedidos := aPedidos[Val(cPedidos)]
If lPanelFin  //Chamado pelo Painel Financeiro
	DEFINE MSDIALOG oDlg TITLE STR0006 FROM 0,0 TO (nWndHeight+=40),Iif(!lBcoExcl,650,600) OF oMainWnd PIXEL FONT oMainWnd:oFont //"Selecione opçoes do Fluxo de Caixa"
Else
	DEFINE MSDIALOG oDlg TITLE STR0006 FROM 0,0 TO nWndHeight,Iif(!lBcoExcl,650,600) OF oMainWnd PIXEL FONT oMainWnd:oFont //"Selecione opçoes do Fluxo de Caixa"
Endif
@ 05, 05 CHECKBOX oGet01 VAR lReceber    PROMPT STR0007 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9; //"Titulos a Receber"
			ON CLICK oSinalRA:SetFocus()
@ 05,120 SAY STR0230 FONT oDlg:oFont PIXEL OF oDlg  // "Composicao das Antecipacoes"
@ 03,201 COMBOBOX oSinalRA VAR cSinalRA ITEMS aSinalRA SIZE 22, 10 FONT oDlg:oFont PIXEL OF oDlg;
			WHEN lReceber

@ 18, 05 CHECKBOX oGet01 VAR lPagar      PROMPT STR0008 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9; //"Titulos a Pagar"

@ 31, 05 CHECKBOX oGet01 VAR lComissoes  PROMPT STR0009 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Comissões"

@ 44, 05 CHECKBOX oGet01 VAR lPedVenda   PROMPT STR0010 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9; //"Pedido de Venda"
			ON CLICK oGetTxMoe:SetFocus()

@ 44,120 SAY STR0284 FONT oDlg:oFont PIXEL OF oDlg // "Conv.Moeda"
@ 41,155 COMBOBOX oGetTxMoe VAR cTxMoe ITEMS aTxMoe SIZE 60, 13 FONT oDlg:oFont PIXEL OF oDlg WHEN lPedVenda

@ 57, 05 CHECKBOX oGet01 VAR lPedCompra  PROMPT STR0011 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 ; //"Pedido de Compra"
			ON CLICK oPedidos:SetFocus()

@ 57,120 SAY STR0227 FONT oDlg:oFont PIXEL OF oDlg  // "Pedidos"
@ 54,155 COMBOBOX oPedidos VAR cPedidos ITEMS aPedidos SIZE 60, 13 FONT oDlg:oFont PIXEL OF oDlg WHEN lPedCompra

If !__lPyme
	@ 70, 05 CHECKBOX oGet01 VAR lAplicacoes PROMPT STR0012 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Aplicacoes/Emprestimos"
Endif
@ 83, 05 CHECKBOX oGet01 VAR lSaldoBanc  PROMPT STR0013  FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9; //"Saldos Bancarios"
         ON CLICK (oGetTpSaldo:SetFocus(),If( lSaldoBanc,(nMoeda := Val(Left(cMoeda,2))), NIL ))

@ 83,120 SAY STR0216 FONT oDlg:oFont PIXEL OF oDlg // "Tipo de Saldo"
@ 80,155 COMBOBOX oGetTpSaldo VAR cTipoSaldo ITEMS aTipoSaldo SIZE 60, 13 FONT oDlg:oFont PIXEL OF oDlg WHEN lSaldoBanc;
			ON CHANGE (If( lSaldoBanc, (nMoeda := Val(Left(cMoeda,2))), NIL ))

If !lBcoExcl //Opcao de Saldo por Total ou Filial, caso a tabela SA6 seja exclusiva
	@ 83,220 SAY STR0233 FONT oDlg:oFont PIXEL OF oDlg  // "Saldo por"
	@ 80,245 COMBOBOX oSaldo VAR cSaldo ITEMS aSaldo SIZE 40, 13 FONT oDlg:oFont PIXEL OF oDlg WHEN lSaldoBanc;
				ON CHANGE (If( lSaldoBanc, (nMoeda := Val(Left(cMoeda,2))), NIL ))
EndIf

@ 96, 05 CHECKBOX oGet01 VAR lTitAtraso  PROMPT STR0014 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Titulos em Atraso"
@ 109,05 CHECKBOX oGet01 VAR lTitFuturo  PROMPT STR0220 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9	//"Titulos com Emissão Futura"

@ 128, 05  SAY STR0237 FONT oDlg:oFont PIXEL OF oDlg //"Visão Gerencial"
@ 126, 50 MSGET oGet01 VAR cVisaoG FONT oDlg:oFont PIXEL SIZE 30, 9 OF oDlg F3 "FJ3" HasButton

@ 128,120 CHECKBOX oGet01 VAR lAgrpVis PROMPT STR0273 FONT oDlg:oFont PIXEL OF oDlg SIZE 90,9 //"Somente Contas Agrupadoras"

nLin := 132

If IntTms()
	@ (nLin += 13), 05 CHECKBOX oGet01 VAR lCtrc  PROMPT STR0265 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9		//"Doctos. de Transporte"
Endif

If cPaisLoc == "ARG"
	@ (nLin += 13), 05 CHECKBOX oGet01 VAR lSolFundo  PROMPT STR0242 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Solic. Fundo"
EndIf

If lIntGC
	@ (nLin += 13), 05 CHECKBOX oGet01 VAR lDMSCompra  PROMPT STR0276 FONT oDlg:oFont PIXEL OF oDlg SIZE 90,9 // "Pedido de Compra de Máquinas"
	@ nLin        ,120 CHECKBOX oGet01 VAR lDMSVenda   PROMPT STR0277 FONT oDlg:oFont PIXEL OF oDlg SIZE 90,9 // "Pedido de Venda de Máquinas"
EndIf

@ nLin+16, 00 TO nLin + 17, 340 OF oDlg PIXEL
@ nLin+25, 05 CHECKBOX oGet01 VAR lConsFil PROMPT STR0017 FONT oDlg:oFont PIXEL OF oDlg SIZE 70,9 ON CLICK ( oGetFilAte:SetFocus() , oGetFilDe:SetFocus() ) //"Considera filiais"
@ nLin+25,120 SAY STR0018+":" FONT oDlg:oFont PIXEL OF oDlg //"Filial de"
@ nLin+23,155 MSGET oGetFilDe VAR cFilDe FONT oDlg:oFont PIXEL SIZE 60, 9 OF oDlg PICTURE Replicate( "!", nTamFilial ) WHEN lConsFil .And. !lFiliais F3 "SM0" HasButton
@ nLin+25,220 SAY STR0019+":" FONT oDlg:oFont PIXEL OF oDlg //"Ate"
@ nLin+23,236 MSGET oGetFilAte VAR cFilAte FONT oDlg:oFont PIXEL SIZE 60, 9 OF oDlg PICTURE Replicate( "!", nTamFilial ) WHEN lConsFil .And. !lFiliais F3 "SM0" HasButton 

@ nLin+41, 05 SAY STR0020    FONT oDlg:oFont PIXEL OF oDlg //"Periodicidade"
@ nLin+38, 50 COMBOBOX oGet01 VAR cPeriodo ITEMS aCmbPer FONT oDlg:oFont PIXEL OF oDlg SIZE 50,13
@ nLin+41,120 SAY STR0021 FONT oDlg:oFont PIXEL OF oDlg  //"Quantos periodos"
@ nLin+38,170 MSGET  oGet01 VAR nPeriodos   FONT oDlg:oFont PIXEL SIZE 30, 10 OF oDlg PICTURE "9999"

@ nLin+61, 05 SAY STR0022 FONT oDlg:oFont PIXEL OF oDlg //"Moeda"
@ nLin+58, 50 COMBOBOX oGet01 VAR cMoeda ITEMS aMoedas SIZE 60, 13 FONT oDlg:oFont PIXEL OF oDlg

@ nLin+61, 05 SAY STR0022 FONT oDlg:oFont PIXEL OF oDlg //"Moeda"
@ nLin+58, 50 COMBOBOX oGet01 VAR cMoeda ITEMS aMoedas SIZE 60, 13 FONT oDlg:oFont PIXEL OF oDlg

@ nLin+61,120 CHECKBOX oGet01 VAR lAnalitico PROMPT STR0023 FONT oDlg:oFont PIXEL OF oDlg SIZE 70,9 //"Processa analitico"

@ nLin+78, 05 CHECKBOX oGet01 VAR lConsDtBase PROMPT STR0215 FONT oDlg:oFont PIXEL OF oDlg SIZE 70,9 // "Considera Data Base"
@ nLin+78,120 CHECKBOX oSelFil VAR lFiliais PROMPT STR0263 FONT oDlg:oFont PIXEL OF oDlg SIZE 70,9 ON CLICK DiagRefresh( @oGetFilDe, @oGetFilAte, @oSelFil ) // "Seleciona Filiais"

@ nLin+92, 00 TO nLin + 93, 340 OF oDlg PIXEL //Linha separadora

//-----------------------------------------------------
// Grid para selecao da situacao(E1_SITUACA) do titulo
// do tipo CH a ser considerado no fluxo de caixa
//-----------------------------------------------------
If cPaisLoc == "ARG"

	aVetor := F021SitCob()

	@ nLin+98,05 SAY STR0243+":" FONT oDlg:oFont PIXEL OF oDlg //"Situações do Titulo a Receber"
	@ nLin+107,05 LISTBOX oLbx FIELDS HEADER " ", STR0244, STR0245 SIZE ((oDlg:nClientWidth/2) - 11),075 OF oDlg PIXEL ; //"Cod"###"Descricao"
	ON DblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1])

	oLbx:bHeaderClick := {|oObj,nCol| If( nCol==1, aEval( aVetor, {|x| x[1] := !(x[1]) } ),Nil), oLbx:Refresh()}

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {If(aVetor[oLbx:nAt,1],oOk,oNo),aVetor[oLbx:nAt,2],aVetor[oLbx:nAt,3]}}
EndIf

If lPanelFin  //Chamado pelo Painel Financeiro
	aButtonTxt := {}
	AADD(aButtonTxt,{STR0231,STR0231,{||Fc021Filtro(@cFilterSe1,@cFilterSe2)}})
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT FaMyBar(oDlg,;
		{||nOpcA := 1, oDlg:End()},;
		{||nOpcA := 0, oDlg:End()},,aButtonTxt)


Else
	DEFINE SBUTTON FROM 05,Iif(!lBcoExcl,290,265) TYPE 17 ENABLE OF oDlg ACTION Fc021Filtro(@cFilterSe1,@cFilterSe2)
	DEFINE SBUTTON FROM 20,Iif(!lBcoExcl,290,265) TYPE  1 ENABLE OF oDlg ACTION (nOpcA := 1,oDlg:End())
	DEFINE SBUTTON FROM 35,Iif(!lBcoExcl,290,265) TYPE  2 ENABLE OF oDlg ACTION ( nOpcA := 0, oDlg:End() )

	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

If nOpcA == 1
	If cTxMoe == STR0282
		lTxMoePed := .T.
	Else
		lTxMoePed := .F.
	EndIf
		
	If lFiliais // Seleciona Filiais
		nRegSM0 := SM0->(Recno())

		aSelFil := AdmGetFil()

		SM0->(DbGoTo(nRegSM0))
		nConsFil := .F.
	EndIf

	If Empty(aSelFil)
		Aadd(aSelFil,cFilAnt)
	EndIf

	If lSaldoBanc .AND. !lFirst
		nMoeda := Val(Left(cMoeda,2))
		Processa({|| aBancos := Bancos( lConsFil, nMoeda, @nBancos, @nCaixas,cFilDe,cFilAte,cTipoSaldo,.T.,,@lLimCred,,,lFiliais,cEmpresa)},STR0286,STR0287) //"Aguarde..."/"Preparando saldos bancários..."
	EndIf
	// Lista as filiais para clausula IN no select
	cLisFil	  := SelectFil(aSelFil)

	lConsDtB := lConsDtBase

	If File("FINC021.PAR")
		nHandle := fOpen("FINC021.PAR",2)
	Else
		nHandle := fCreate("FINC021.PAR")
	Endif
	If !lPesqUsu
		fSeek(nHandle,nOffSet,0) // Posiciona na linha a ser gravada
	Else
		fSeek(nHandle,nOffSet - (Len(cLog)+2),0) // Posiciona na linha a ser gravada
	Endif

	cLog := Pad(Left(cUsuario,19),20)
	cLog += If(lReceber,"S","N")
	cLog += If(lPagar,"S","N")
	cLog += If(lComissoes,"S","N")
	cLog += If(lPedVenda,"S","N")
	cLog += If(lPedCompra,"S","N")
	cLog += If(lAplicacoes,"S","N")
	cLog += If(lTitAtraso,"S","N")
	cLog += If(lConsFil,"S","N")

	If lFWCodFil
		cLog += PadR( cFilDe, 12 ) + PadR( cFilAte, 12 )
	Else
		cLog += cFilDe + cFilAte
	EndIf

	cLog += Pad(cPeriodo,12)
	cLog += Str(nPeriodos,4)
	cLog += Pad(cMoeda,15)
	cLog += If(lAnalitico,"S","N")
	cLog += If(lConsDtBase,"S","N")
	cLog += Left(cTipoSaldo,1)
	cLog += If(lTitFuturo,"S","N")
	cLog += If(lCtrc,"S","N")
	cLog += Left(cPedidos,1)
	cLog += Left(cSinalRA,1)

    /*_*/
	cLog += If(lSaldoBanc,"S","N")
    /*_*/

	If cPaisLoc == "ARG"
		cLog += If(lSolFundo,"S","N")
	Else
		cLog += " "
	EndIf

	cLog += If(lDMSCompra,"S","N")
	cLog += If(lDMSVenda,"S","N")

	fWrite(nHandle,cLog+Chr(13)+Chr(10))
	fClose(nHandle)

	// Recalcula o saldo em Bancos/Caixas de acordo com a moeda escolhida
	nMoeda	:= Val(Left(cMoeda,2))
	nBancos	:= 0
	nCaixas	:= 0
	nLimCred := 0

	//Somar saldos bancarios e limites de credito bancario
	For nX := 1 to Len(aBancos)
		If aBancos[nX,1]  //	Se Considera banco nos saldos bancarios
			aBancos[nX][6] := Transform(xMoeda(Fc021Val(aBancos[nX][6]),aBancos[nX][7],nMoeda),"@E 999,999,999.99")
			aBancos[nX][8] := Transform(xMoeda(Fc021Val(aBancos[nX][8]),aBancos[nX][7],nMoeda),"@E 999,999,999.99")
			If Left(aBancos[nX][2],2)=="CX" .Or. Left(aBancos[nX][2],3) $ cBancoCx
				nCaixas +=	Fc021Val(aBancos[nX][6])
			Else
			  	nBancos +=	Fc021Val(aBancos[nX][6])
				If lLimCred
				  	nLimCred+=	Fc021Val(aBancos[nX][8])
				EndIf
			EndIf
		EndIf
	Next nX

	//Se for visao gerencial financeira processara de outra forma
	If (!Empty(AllTrim(cVisaoG)))
		Processa({|lEnd| FRVisaoGer(lEnd,cMoeda,cPeriodo,nPeriodos,cFilDe,cFilAte,lReceber,;
											 lPagar,lComissoes,lPedVenda,lPedCompra,lAplicacoes,;
											 lSaldoBanc,lAnalitico,lConsFil,lTitAtraso,;
											 nCaixas,nBancos,aBancos,aAplic,cFilterSe1,cFilterSe2,;
											 lConsDtBase,lTitFuturo, lCtrc, cPedidos, nLimCred , lLimCred,;
											 cSinalRA,cVisaoG,lFiliais)})
	Else
		Processa({|lEnd| Fc021Proc(lEnd,cMoeda,cPeriodo,nPeriodos,cFilDe,cFilAte,lReceber,;
											 lPagar,lComissoes,lPedVenda,lPedCompra,lAplicacoes,;
											 lSaldoBanc,lAnalitico,lConsFil,lTitAtraso,;
											 nCaixas,nBancos,aBancos,aAplic,cFilterSe1,cFilterSe2,;
											 lConsDtBase,lTitFuturo, lCtrc, cPedidos, nLimCred , lLimCred,;
											 cSinalRA,cVisaoG,lSolFundo,lConsDtBase,lDMSCompra,lDMSVenda,lTxMoePed)})
	EndIf

EndIf

If !Empty(cAlias)
   DbSelectArea(cAlias)
Endif

If lPanelFin  //Chamado pelo Painel Financeiro
	dbSelectArea(FinWindow:cAliasFile)
	ReCreateBrow(FinWindow:cAliasFile,FinWindow)
	INCLUI := .F.
	ALTERA := .F.
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc021Proc ³ Autor ³ Claudio D. de Souza   ³ Data ³ 17/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa Fluxo de Caixa                			  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc021Proc												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Financeiro												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc021Proc(lEnd,cMoeda,cPeriodo,nPeriodos,cFilDe,cFilAte,lReceber,lPagar,;
						 lComissoes,lPedVenda,lPedCompra,lAplicacoes,lSaldoBanc,;
						 lAnalitico,lConsFil,lTitAtraso,nCaixas,nBancos,;
						 aBancos,aAplic,cFilterSe1,cFilterSe2,lConsDtBase,lTitFuturo,;
						 lCtrc, cPedidos,nLimCred, lLimCred, cSinalRA, cVisaoG,lSolFundo,lConsDtBase,lDMSCompra,lDMSVenda,lTxMoePed)

Local aArqTmp								// Nome do arquivo temporario e alias criado aleatoriamente
Local aArqCo								// Nome do arquivo temporario e alias para comissões
Local cSavFil								// Salva a Filial atual
Local aCalc									// Calculo de aplicacao
Local aAreaSM0			:= SM0->(GetArea())	// Salva a area do SM0
Local dDataTrab								// Data de trabalho
Local nAplicacao		:= 0				// Valor da aplicacao
Local nEmprestimo		:= 0				// Valor do emprestimo
Local nDias
Local nX									// Contador de loop for...next
Local nAtrReceber		:= 0
Local nAtrPagar			:= 0
Local aTmpAnaEmp
Local aTmpAnaApl
Local aTmpAnaCtrc		:= Array(2)
Local aTmpAnaSol		:= Array(2)
Local cAliasEmp
Local cAliasApl
Local oDlg
Local oGet02
Local cAliasPc
Local cAliasPv
Local cArqAnaPc
Local cAliasChq
Local aTotais			:= {{},{},{},{},{},{},{},{},{},{},{},{},{}}
Local aPeriodo			:= {}
Local aFluxo			:= {}
Local oPanel
Local oFluxo
Local nAscan
Local nRecSeh
Local cAplCotas			:= GetMv("MV_APLCAL4")
Local cAliasDMSCompra
Local cAliasDMSVenda
Local aSize
Local aObjects 			:= {}
Local aInfo
Local aPosObj
Local nTotRegs			:= 0
Local aTit				:= {{"01",STR0177 },{"07",STR0178},{"10",STR0179},{"15",STR0180},{"30",STR0181}}	//"Dia"###"Semana"###"Decendio"###"Quinzena"###"Mes"
Local cTit
Local lLibCheq			:= GetMv("MV_LIBCHEQ") == "N"	// Para controlar os cheques pendentes de liberacao
Local j					:= 0
Local i					:= 0
Local nValBancos		:= 0
Local lPanelFin			:= IsPanelFin()
Local lFC21CTRFLX		:= ExistBlock("FC21CTRFLX")
Local cFilSEF			:= ""
Local cSelFil			:= ""
Local lMVEffFin         := GetMV("MV_EFF_FIN",,.F.)
Local cPicture			:= PesqPict("SE9","E9_VLRCOTA",18)
Local cTempVA			:= GetNextAlias()			// Alias Tabela temporária VA
Local oTmpVA			:= Nil 			// Objeto Tab. temp. VA
Local lSeekVA			:= .T.			// Define se busca VA para o título
Local cInsert			:= ""
Local lContinua			:= .T.	

Default cVisaoG			:= ""
Default lSolFundo		:= .F.
Default lTxMoePed       := .F.

// Declara a Cols Aqui, pois sera utilizada na rotina de simulacao
// e seu conteudo deve permanecer o mesmo toda vez que o usuario clicar
// no botao simulacao.
aCols		:= {}
aHeader		:= {}
lConsDtBase	:= lConsDtB
lConsDtB	:= .F.

// Utilizada na simulacao
Aadd( aHeader, { STR0024 , "_SI_DATA"  , ""					, 08, 0, ".T."			, USADO, "D",, "V" } ) //"Data"
Aadd( aHeader, { STR0025 , "_SI_TIPO"  , "!"				, 01, 0, "Fc021Tipo()"	, USADO, "C",, "V" } ) //"Receita/Despesa"
Aadd( aHeader, { STR0026 , "_SI_VALOR" , "@E 999,999,999.99", 15, 2, ".T."			, USADO, "N",, "V" } ) //"Valor"
Aadd( aHeader, { STR0027 , "_SI_HISTOR", "@!"				, 40, 0, ".T."			, USADO, "C",, "V" } ) //"Historico"
Aadd( aHeader, { STR0199 , "_SI_VALANT", "@E 999,999,999.99", 15, 2, ".T."			, USADO, "N",, "V" } ) //"Valor"

// Pega o titulo da primeira coluna de acordo com o periodo selecionado
cTit := aTit[Ascan(aTit,{|e|e[1] == Left(cPeriodo,2)})][2]

nMoeda := Val(Left(cMoeda,2))
nDias  := Val(Left(cPeriodo,2)) * nPeriodos // Calcula quantos dias
If nDias <= 0
   nDias := 1
EndIf

// Gera os registros para todas as datas do periodo, inclusive a database
For nX := 1 To nDias
	If !lConsDtBase
		dDataTrab := (dDataBase + 1) + nX-1
	Else
		dDataTrab := dDataBase + nX-1
    EndIf

	TemFluxoData(dDataTrab,aFluxo)
	TemFluxoData(dDataTrab,aPeriodo)
Next nX
// Monta os periodos na matriz para ser utilizada na simulacao e na projecao
MontaPeriodo(aPeriodo,cPeriodo)

// Inicia o total de registros a srem processados para incrementar a regua
If lReceber
	nTotRegs += SE1->(RecCount())
Endif
If lPagar
	nTotRegs += SE2->(RecCount())
Endif
If lComissoes
	nTotRegs += SE3->(RecCount())
Endif
If lPedVenda
	nTotRegs += SC6->(RecCount())
Endif
If lPedCompra
	nTotRegs += SC7->(RecCount())
Endif
If lAplicacoes
	nTotRegs += SEH->(RecCount())
Endif
If lSaldoBanc
	nTotRegs += SE8->(RecCount())
Endif

ProcRegua(nTotRegs)

If lFiliais
	cFilDe  := aSelFil[1]
	cFilAte := aSelFil[Len(aSelFil)]
Endif

If lAplicacoes
	If lAnalitico
	   aTmpAnaEmp := CriaTmpAna(1) // Cria o arquivo temporario analitico de emprestimos
	   cAliasEmp  := aTmpAnaEmp[1]
	   aTmpAnaApl := CriaTmpAna(2) // Cria o arquivo temporario analitico de aplicacoes
	   cAliasApl  := aTmpAnaApl[1]
	EndIf

	For j := 1 To nDias
		dDataTrab := dDataBase + j - 1
		cSavFil := cFilAnt

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atribui valores as variaveis ref a filiais                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lConsFil .And. !lFiliais
			cFilDe  := cFilAnt
			cFilAte := cFilAnt
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a Disponibilidade Financeira                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SM0" )
		dbSetOrder( 1 )
		dbSeek( cEmpAnt + cFilDe, .T. )
		While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
			cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe Emprestimo a ser resgatado no dia ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SEH")
			dbSetOrder(2)
			dbSeek(xFilial("SEH")+"A",.T.)
			nRecSeh := Recno()
			While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )
				If SEH->EH_APLEMP == "EMP"
					If ( Empty(SEH->EH_DATARES) .And. J==1 ) .Or.;
						( SEH->EH_DATARES == dDataTrab )
						dA181DtApr := dDataTrab
						nA181VlMoed:= RecMoeda(dA181DtApr,SEH->EH_MOEDA)
						nA181SPCP2	:= 0
						nA181SPLP2	:= 0
						nA181SPCP1	:= 0
						nA181SPLP1	:= 0
						nA181SJUR2	:= 0
						nA181SJUR1	:= 0
						nA181SVCLP	:= 0
						nA181SVCCP	:= 0
						nA181SVCJR	:= 0
						nA181VPLP1 	:= 0
						nA181VPCP1 	:= 0
						nA181VJUR1 	:= 0
						nA181VVCLP 	:= 0
						nA181VVCCP 	:= 0
						nA181VVCJR 	:= 0
						nA181VPLP2 	:= 0
						nA181VlDeb  := 0

						aCalculo	  := Fa171Calc(dDataTrab,SEH->EH_SALDO,.F.)
						nA181SPCP2 := Round(SEH->EH_SALDO * SEH->EH_PERCPLP/100 , TamSX3("EH_SALDO")[2])
						nA181SPLP2 := SEH->EH_SALDO - nA181SPCP2
						nA181SPLP1 := SEH->EH_VLCRUZ
						nA181SPCP1 := Round(SEH->EH_VLCRUZ * SEH->EH_PERCPLP/100,TamSX3("EH_SALDO")[2])
						nA181SPLP1 := SEH->EH_VLCRUZ - nA181SPCP1
						nA181SJUR2 := aCalculo[1,2]
						nA181SJUR1 := aCalculo[2,2]
						nA181SVCLP := aCalculo[2,3]
						nA181SVCCP := aCalculo[2,4]
						nA181SVCJR := aCalculo[2,5]
						nA181VlIRF := 0
						nA181VLDES := 0
						nA181VLGAP := 0
						nA181STOT1 := nA181SPLP1+nA181SPCP1+nA181SJUR1+nA181SVCLP+nA181SVCCP+nA181SVCJR
						nA181STOT2 := nA181SPLP2+nA181SPCP2+nA181SJUR2
						nA181VPLP1 := nA181SPLP1
						nA181VPCP1 := nA181SPCP1
						nA181VPLP2 := nA181SPLP2
						nA181VPCP2 := nA181SPCP2
						nA181VJUR1 := nA181SJUR1
						nA181VJUR2 := nA181SJUR2
						nA181VVCLP := nA181SVCLP
						nA181VVCCP := nA181SVCCP
						nA181VVCJR := nA181SVCJR
						nA181VTOT1 := nA181STOT1
						nA181VTOT2 := nA181STOT2

						Fa181Valor(,"DA181DTAPR") // Atualiza as variaveis PRIVATES do calculo do emprestimo
						nEmprestimo := xMoeda(nA181VlDeb,1,nMoeda,dDataTrab)
						// Verifica se esta no periodo solicitado
						nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
						If nAscan > 0
							aFluxo[nAscan][SAIDAS] += nEmprestimo
						Endif
						If lAnalitico .And. nEmprestimo > 0
							// Pesquisa na matriz de totais, os totais de contas a pagar
							nAscan := Ascan( aTotais[6], {|e| e[1] == dDataTrab})
							If nAscan == 0
								Aadd( aTotais[6], {dDataTrab,nEmprestimo})
							Else
								aTotais[6][nAscan][2] += nEmprestimo // Contabiliza os totais de emprestimos
							Endif
							// Verifica se esta no periodo solicitado
							nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
							If nAscan > 0 .And. SEH->EH_DATA <= ( dDataBase + nDias )
								RecLock(cAliasEmp,.T.)
								(cAliasEmp)->DataX	:= dDataTrab
								(cAliasEmp)->Periodo	:= aPeriodo[nAscan][2]
								(cAliasEmp)->NUMERO	:= SEH->EH_NUMERO
								(cAliasEmp)->BANCO	:= SEH->EH_BANCO
								(cAliasEmp)->AGENCIA	:= SEH->EH_AGENCIA
								(cAliasEmp)->CONTA	:= SEH->EH_CONTA
								(cAliasEmp)->EMISSAO	:= SEH->EH_DATA
								(cAliasEmp)->SALDO	:= nEmprestimo
								(cAliasEmp)->APELIDO	:= "SEH"
								(cAliasEmp)->CHAVE	:= xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
								MsUnlock()
							Endif
						Endif
					Endif
				Else
					If SEH->EH_DATA == dDataTrab .And. SEH->EH_DATA > dDataBase
					   nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
					   If nAscan > 0
					      aFluxo[nAscan][SAIDAS] += xMoeda(SEH->EH_VALOR,1,nMoeda,dDataTrab)
					   Endif
					Endif
				EndIf
				dbSelectArea("SEH")
				dbSkip()
			EndDo
			DbGoTo(nRecSeh) // Para evitar outro SEEK
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe Aplicacoes a serem resgatadas no dia ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )
				If SEH->EH_APLEMP == "APL"
			  		If (Empty(SEH->EH_DATARES) .And. J==1) .Or. ((SEH->EH_DATARES < dDataTrab) .And. J==1) .Or. ;
			  			(SEH->EH_DATARES == dDataTrab)
						nAplicacao := xMoeda(SEH->EH_SALDO,1,nMoeda,dDataTrab)
					Else
						nAplicacao := 0
					EndIf
					DbSelectArea("SE9")
					DbSetOrder(1)
					DbSeek(xFilial()+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
					DbSelectArea("SEH")
					If (Empty(SEH->EH_DATARES) .And. J==1) .Or. ((SEH->EH_DATARES < dDataTrab) .And. J==1) .Or. ;
						(SEH->EH_DATARES == dDataTrab)
						If !SEH->EH_TIPO $ cAplCotas
							aCalc :=	Fa171Calc(dDataTrab)
							nAplicacao += xMoeda((aCalc[5]-aCalc[2]-aCalc[3]-aCalc[4]),1,nMoeda,dDataTrab)							
						Else
							aCalc := {0,0,0,0,0,0}
							DbSelectArea("SE0")
							SE0->(DbSetOrder(2)) // E0_FILIAL+E0_BANCO+E0_AGENCIA+E0_CONTA+E0_CONTRAT+DTOS(E0_DATA)+E0_SUBCTA
							SE0->(MsSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO)+DTOS(dDataTrab)))
							Aadd(aAplic,{	SEH->EH_CONTRAT,SEH->EH_BCOCONT,SEH->EH_AGECONT,;
												Transform(SEH->EH_SALDO,"@E 999,999,999.99"),;
												Transform(SE9->E9_VLRCOTA,cPicture),;
												SE0->E0_VALOR})
							DbSelectArea("SEH")
							nAscan := Ascan(aAplic, {|e|	e[1] == SEH->EH_CONTRAT .And.;
																   e[2] == SEH->EH_BCOCONT .And.;
																   e[3] == SEH->EH_AGECONT})
							If nAscan > 0
								aCalc	:=	Fa171Calc(dDataTrab,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,aAplic[nAscan][6],(SEH->EH_SLDCOTA * aAplic[nAscan][6]))
								nAplicacao := xMoeda((aCalc[1]-(aCalc[2]+aCalc[3]+aCalc[4])),1,nMoeda,dDataTrab)								
							Endif
						EndIf
					EndIf
					// Verifica se esta no periodo solicitado
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
					If nAscan > 0
						aFluxo[nAscan][ENTRADAS] += nAplicacao
					Endif
					If lAnalitico .And. nAplicacao > 0
						// Pesquisa na matriz de totais, os totais de contas a pagar
						nAscan := Ascan( aTotais[7], {|e| e[1] == dDataTrab})
						If nAscan == 0
							Aadd( aTotais[7], {dDataTrab,nAplicacao})
						Else
							aTotais[7][nAscan][2] += nAplicacao // Contabiliza os totais de Aplicacoes
						Endif
						// Verifica se esta no periodo solicitado
						nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
						If nAscan > 0 .And. SEH->EH_DATA <= ( dDataBase + nDias )
							RecLock(cAliasApl,.T.)
							(cAliasApl)->DataX	:= dDataTrab
							(cAliasApl)->Periodo	:= aPeriodo[nAscan][2]
							(cAliasApl)->NUMERO	:= SEH->EH_NUMERO
							(cAliasApl)->BANCO	:= SEH->EH_BANCO
							(cAliasApl)->AGENCIA	:= SEH->EH_AGENCIA
							(cAliasApl)->CONTA	:= SEH->EH_CONTA
							(cAliasApl)->EMISSAO	:= SEH->EH_DATA
							(cAliasApl)->SALDO	:= nAplicacao
							(cAliasApl)->APELIDO	:= "SEH"
							(cAliasApl)->CHAVE	:= xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
							MsUnlock()
						Endif
					Endif
				Endif
				dbSelectArea("SEH")
				dbSkip()
			EndDo

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ AAF - Fluxo de caixa para financiamentos originados no SIGAEFF  ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lMVEffFin .AND. j == 1
               aRet := EX102FlCaixa(dDataTrab,aPeriodo,nMoeda,lAnalitico)
               For i := 1 To Len(aRet)
                  nVlFluxo := aRet[i][6]
                  // Verifica se esta no periodo solicitado
				  nAscan := Ascan(aPeriodo, {|e| e[1] == aRet[i][11]}) //WHRS 01/08/2017 foi alterado o parameto de comparação do Ascan de dDataTrab para aRet[i][11] TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exportação
				  If nAscan > 0
				     aFluxo[nAscan][SAIDAS] += nVlFluxo
                  Endif

				  If lAnalitico .And. nVlFluxo > 0
				     // Pesquisa na matriz de totais, os totais de contas a pagar
					 nAscan := Ascan( aTotais[6], {|e| e[1] == aRet[i][11]}) //WHRS 01/08/2017 foi alterado o parameto de comparação do Ascan de dDataTrab para aRet[i][11] TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exportação
					 If nAscan == 0
					    Aadd( aTotais[6], {aRet[i][11],nVlFluxo})
				     Else
						aTotais[6][nAscan][2] += nVlFluxo
					 Endif

					 // Verifica se esta no periodo solicitado
					 nAscan := Ascan(aPeriodo, {|e| e[1] == aRet[i][11]}) //WHRS 01/08/2017 foi alterado o parameto de comparação do Ascan de dDataTrab para aRet[i][11] TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exportação
					 If nAscan > 0
						RecLock(cAliasEmp,.T.)
						(cAliasEmp)->DataX	:= aRet[i][11]
						(cAliasEmp)->Periodo:= aPeriodo[nAscan][2]
						(cAliasEmp)->NUMERO	:= aRet[i][1]//SEH->EH_NUMERO
						(cAliasEmp)->BANCO	:= aRet[i][2]//SEH->EH_BANCO
						(cAliasEmp)->AGENCIA:= aRet[i][3]//SEH->EH_AGENCIA
						(cAliasEmp)->CONTA	:= aRet[i][4]//SEH->EH_CONTA
						(cAliasEmp)->EMISSAO:= aRet[i][5]//SEH->EH_DATA
						(cAliasEmp)->SALDO	:= nVlFluxo
						(cAliasEmp)->APELIDO:= aRet[i][7]//"SEH"
						(cAliasEmp)->CHAVE	:= aRet[i][8]
						MsUnlock()
					 Endif
                  Endif

               Next i
            EndIf
            If Empty(FwFilial("SEH"))
				Exit
			Endif
			dbSelectArea("SEH")
			dbSetOrder(1)
			dbSelectArea("SM0")
			dbSkip()
		EndDo
		SM0->(RestArea(aAreaSM0))
		cFilAnt := cSavFil
	Next
Endif

aArqTmp := Array(4)

If lLibCheq // Verifica cheques nao liberados
	cSavFil := cFilAnt

	If lAnalitico
		aTmpAnaChq := CriaTmpAna(6) // Cria o arquivo temporario analitico de emprestimos
		cAliasChq  := aTmpAnachq[1]
	EndIf

	cSelFil := IIf( Len(aSelFil) > 0, ArrayToStr( aSelFil, ';' ), "")

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL <= cFilAte
		cFilAnt := SM0->M0_CODFIL

		If !cFilAnt $ cSelFil
			SM0->(DBSKIP())
			Loop
		EndIf

		// Tratamento para Gestao corporativa visando garantir que sejam processadas apenas as filiais realmente diferentes.
		// Exemplo:
		// Empresa = Exclusiva
		// U.Negocio = Exclusiva
		// Filial = Compartilhada
		// Somente ao se alterar o valor de xFilial() e que a rotina tem que reprocessar
		If xFilial("SEF") != cFilSEF
			cFilSEF := xFilial("SEF")
		Else
			SM0->(dbSkip())
			Loop
		Endif

		cFiltro := "EF_FILIAL = '" + xFilial("SEF") + "' .And. "
		cFiltro += "EF_NUM <> '" + Space(Len(SEF->EF_NUM)) + "' .And. "
		cFiltro += "!EF_IMPRESS $ 'AC' .And. "
		cFiltro += "EF_LIBER <> 'S' .And. "
		cFiltro += "EF_CART <> 'R' "
		dbSelectArea("SEF")
		cIndTmp := CriaTrab(,.F.)
		IndRegua( "SEF", cIndTmp, "EF_FILIAL+DTOS(EF_DATA)+EF_LIBER", , cFiltro )
		nIndSEF := RetIndex("SEF")
		nIndSEF++

		DbSetOrder(nIndSef)

		While Sef->(!Eof()) .And. SEF->EF_DATA<=dDataBase+nDias-1 .And. SEF->EF_LIBER$" N" .And. SEF->EF_FILIAL == xFilial("SEF")
			// Verifica se esta no periodo solicitado
			If SEF->EF_DATA < dDataBase // Se o cheque nao foi liberado e estiver anterior a data inicial
												 // do fluxo de caixa, assume a data base para exibir este cheque.
				nAscan := 1
			Else
				nAscan := Ascan(aPeriodo, {|e| e[1] == SEF->EF_DATA})
			Endif
			If nAscan > 0
				// Se não for cheque sobre titulos, assume como saida de caixa
				If !AllTrim(SEF->EF_ORIGEM) $ "FINA390TIT" .or. lLibCheq .and. SE2->E2_SALDO == 0
					aFluxo[nAscan][SAIDAS] += SEF->EF_VALOR
				Endif
				If lAnalitico
					RecLock(cAliasChq,.T.)
					(cAliasChq)->DataX	:= If(SEF->EF_DATA < dDataBase,dDataBase,SEF->EF_DATA)
					(cAliasChq)->Periodo	:= aPeriodo[nAscan][2]
					(cAliasChq)->NUMERO	:= SEF->EF_NUM
					(cAliasChq)->BANCO	:= SEF->EF_BANCO
					(cAliasChq)->AGENCIA	:= SEF->EF_AGENCIA
					(cAliasChq)->CONTA	:= SEF->EF_CONTA
					(cAliasChq)->SALDO	:= SEF->EF_VALOR
					(cAliasChq)->APELIDO	:= "SEF"
					(cAliasChq)->CHAVE	:= xFilial("SEF")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)
					If SEF->EF_DATA < dDataBase // Se o cheque nao foi liberado e estiver anterior a data inicial
														 // do fluxo de caixa, assume a data base para exibir este cheque.
						nAscan := 1
					Else
						nAscan := Ascan( aTotais[8], {|e| e[1] == SEF->EF_DATA})
					Endif
					If nAscan == 0 .Or. Len(aTotais[8]) == 0
						Aadd( aTotais[8], {If(SEF->EF_DATA < dDataBase,dDataBase,SEF->EF_DATA),SEF->EF_VALOR})
					Else
						aTotais[8][nAscan][2] += SEF->EF_VALOR // Contabiliza os totais de cheques pendentes
					Endif
				Endif
			Endif
			DbSelectArea("SEF")
			DbSkip()
		End
		dbSelectArea("SEF")
		dbClearFil()
		RetIndex("SEF")
		If !Empty(cIndTmp)
			FErase (cIndTmp+OrdBagExt())
		Endif
		dbSetOrder(1)
		dbSelectArea("SM0")
		SM0->(dbSkip())
	EndDo
	SM0->(RestArea(aAreaSM0))
	cFilAnt := cSavFil
Endif

// Criação de tabela temporária para armazernar a chave da FK7 para os títulos que possuem VA (FKD)
If oTmpVA == Nil	
    
    oTmpVA := FwTemporaryTable():New( cTempVA )
    
    oTmpVA:SetFields( { {'CHAVE','C',100,0} } )

    oTmpVA:AddIndex( '01', {'CHAVE'} )
    
    oTmpVA:Create()
    
    cInsert := " INSERT INTO " + oTmpVA:GetRealName()  + "  (CHAVE)  "
    cInsert += " SELECT FK7.FK7_CHAVE FROM " + RetSqlName( 'FK7' ) + " FK7  JOIN " 
    cInsert += RetSqlName( 'FKD' ) + " FKD ON FK7.FK7_FILIAL = FKD.FKD_FILIAL AND FK7.FK7_IDDOC = FKD.FKD_IDDOC "
    cInsert += " WHERE FK7.D_E_L_E_T_ = ' ' AND FKD.D_E_L_E_T_ = ' ' "

	TcSqlExec( cInsert )

	( cTempVA )->(DbGoTop())
	//Caso não haja nenhum registro de Valores Acessórios, evito chamar a rotina de cálculo de VA
	If ( cTempVA )->( BOF() ) .And. ( cTempVA )->( EOF() )  
		lSeekVA := .F.
	EndIf	

EndIf

If lReceber .and. lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os titulos a receber                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArqTmp := GeraTmp("SE1",7,Iif(lConsDtBase,dDataBase+nDias-1,dDataBase+nDias),lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,,,nMoeda,aTotais,aPeriodo,cFilterSe1,lConsDtBase,lTitFuturo, cSinalRA,lSeekVA,cTempVA,@lContinua)
Endif
If lPagar .and. lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os titulos a pagar  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArqTmp := GeraTmp("SE2",3,Iif(lConsDtBase,dDataBase+nDias-1,dDataBase+nDias),lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,If(aArqTmp!=Nil,aArqTmp[1],Nil),If(aArqTmp!=Nil,aArqTmp[3],Nil),nMoeda,aTotais,aPeriodo,cFilterSe2,lConsDtBase,lTitFuturo, cSinalRA,lSeekVA,cTempVA,@lContinua)
Endif
If lPedCompra .and. lContinua
	// Variaveis utilizadas pela rotina Fc020Compra()
	aCompras	:= {}
	adCompras	:= {}
	MV_PAR03	:= If( lConsFil .Or. lFiliais, 2, 1 )
	MV_PAR02	:= nMoeda

	// Analitico
	If lAnalitico
		aTmpAna		:= CriaTmpAna(3) // Cria o arquivo temporario analitico
		cAliasPc	:= aTmpAna[1]
		cArqAnaPc	:= aTmpAna[2]
     Endif     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os pedidos de compra³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fc020Compra(cAliasPc, aTotais, .T., nMoeda, aPeriodo, cFilDe, cFilAte, cPedidos, .F.,, aSelFil)
	For nX := 1 To Len(aCompras)
		IncProc(STR0028) //"Processando Pedidos de compras"
		// Verifica se esta no periodo solicitado
		nAscan := Ascan(aPeriodo, {|e| e[1] == aCompras[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aCompras[nX][1] < aPeriodo[1][1]
			aCompras[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][SAIDAS] += iif (cSinalRA='-',aCompras[nX][2]-aCompras[nX][4],aCompras[nX][2])
		Endif
	Next
Endif
If lCtrc .and. lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os titulos a Doctos. de Transporte										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTmpAnaCtrc := CriaTmpAna(7) // Cria o arquivo temporario analitico de Doctos. de Transporte
	Fc021Ctrc(aTmpAnaCtrc[1],dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,nMoeda,aTotais,aPeriodo,lFiliais)
Endif

If lSolFundo .and. lContinua
	//---------------------------------------------------------------------------
	// Processa as solicitacoes de fundo aprovadas e nao amarradas a Ordem Pagam.
	//---------------------------------------------------------------------------
	aTmpAnaSol := CriaTmpAna(8) // Cria o arquivo temporario analitico de Solicitacoes de Fundo
	Fc021Solic(aTmpAnaSol[1],dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,nMoeda,aTotais,aPeriodo)
EndIf

If lPedVenda .and. lContinua
	// Variaveis utilizadas pela rotina Fc020Compra()
	aVendas  := {}
	adVendas := {}
	MV_PAR03 := If( lConsFil .Or. lFiliais, 2, 1 )
	MV_PAR02 := nMoeda

	// Analitico
	If lAnalitico
		aTmpAna		:= CriaTmpAna(4) // Cria o arquivo temporario analitico
		cAliasPv	:= aTmpAna[1]
		cArqAnaPv	:= aTmpAna[2]
     Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os pedidos de venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fc020Venda(, cAliasPv, aTotais, .T., nMoeda, aPeriodo, cFilDe, cFilAte,,,, aSelFil,,lTxMoePed)
	For nX := 1 To Len(aVendas)
		IncProc(STR0029) //"Processando Pedidos de vendas"
		nAscan := Ascan(aPeriodo, {|e| e[1] == aVendas[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aVendas[nX][1] < aPeriodo[1][1]
			aVendas[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][ENTRADAS] += iif (cSinalRA='-',aVendas[nX][2]-aVendas[nX][4],aVendas[nX][2])
		Endif
	Next
Endif
aArqCo := Array(4)

If lDMSCompra .and. lContinua

	aDMSCompras  := {}
	MV_PAR03 := If( lConsFil, 2, 1 )

	// Analitico
	If lAnalitico
		aTmpAna := CriaTmpAna(09) // Cria o arquivo temporario analitico
		cAliasDMSCompra := aTmpAna[1]
		cArqDMSCompra   := aTmpAna[2]
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Processa os pedidos de compra?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	Fc020DMSCompra(cAliasDMSCompra,aTotais,.T.,nMoeda,aPeriodo,cFilDe, cFilAte, lConsDtBase, , )
	For nX := 1 To Len(aDMSCompras)
		IncProc(STR0278) // "Processando Pedido de Compra de Máquinas"
		// Verifica se esta no periodo solicitado
		nAscan := Ascan(aPeriodo, {|e| e[1] == aDMSCompras[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aDMSCompras[nX][1] < aPeriodo[1][1]
			aDMSCompras[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][SAIDAS] += aDMSCompras[nX][2]
		EndIf
	Next
EndIf

If lDMSVenda .and. lContinua

	aDMSVendas  := {}
	MV_PAR03 := If( lConsFil, 2, 1 )

	// Analitico
	If lAnalitico
		aTmpAna := CriaTmpAna(10) // Cria o arquivo temporario analitico
		cAliasDMSVenda := aTmpAna[1]
		cArqDMSVenda   := aTmpAna[2]
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Processa os pedidos de Venda ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	Fc020DMSVenda(cAliasDMSVenda,aTotais,.T.,nMoeda,aPeriodo,cFilDe, cFilAte, lConsDtBase, , )
	For nX := 1 To Len(aDMSVendas)
		IncProc(STR0279) // "Processando Pedido de Venda de Máquinas"
		// Verifica se esta no periodo solicitado
		nAscan := Ascan(aPeriodo, {|e| e[1] == aDMSVendas[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aDMSVendas[nX][1] < aPeriodo[1][1]
			aDMSVendas[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][ENTRADAS] += aDMSVendas[nX][2]
		Endif
	Next
Endif

If lComissoes .and. lContinua
	aArqCo := Fc021Comis(dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,aFluxo,nMoeda,lAnalitico,aTotais,aPeriodo)
Endif

If lContinua
	If aArqTmp == Nil .And. aArqco == Nil
		IW_MSGBOX(STR0030,STR0198,"STOP") //"E necessario escolher ao menos um tipo"
	Else
		Private aRotina := {{"", "", 0, 1},;
						{STR0031, "", 0, 2},; // "Visualizar"
							{"", "", 0, 3},;
							{"", "", 0, 4},;
							{"", "", 0, 5},;
							{"", "", 0, 3}}
		If lTitAtraso
			If lReceber
				nAtrReceber := Fc021Vencidos("SE1",lConsFil,cFilDe,cFilAte,nMoeda,cFilterSe1,lSeekVA,cTempVA)
			Endif
			If lPagar
				nAtrPagar   := Fc021Vencidos("SE2",lConsFil,cFilDe,cFilAte,nMoeda,cFilterSe2,lSeekVA,cTempVA)
			Endif
			If lComissoes
				nAtrPagar   += Fc021Vencidos("SE3",lConsFil,cFilDe,cFilAte,nMoeda)
			Endif
		Endif
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ordena aFluxo pela data³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		aFluxo := aSort(aFluxo,,,{|x,y| x[1] < y[1]})
		aEval(aTotais, {|e| aSort(e,,, {|x,y| x[1] < y[1] })}) // Ordena pela data de cada sub-total
		Consolida(aFluxo,aTotais,cPeriodo)
		CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nLimCred)
		nValBancos := nBancos + nLimCred

		aSize := MsAdvSize()
		aadd( aObjects, {  30,  70, .T., .T.} )
		aadd( aObjects, {  20, 180, .T., .T., .T. } )
		aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
		aPosObj := MsObjSize( aInfo, aObjects )
		DEFINE MSDIALOG oDlg TITLE STR0032 + STR0197 + Capital(SubStr(cMoeda,3)) FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Fluxo de Caixa" //"Fluxo de Caixa" //" em "
		oDlg:lMaximized := .T.

		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,50,50,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		If !ExistBlock("FC021MENU")
			@  0,  1 TO 48,396 OF oPanel PIXEL
		Else
			@  0,  1 TO 48,460 OF oPanel PIXEL
		Endif
		@  6,  6 TO 44,152 PROMPT STR0033 OF oPanel PIXEL //"Titulos Atrasados"
		@  6,156 TO 44,311 PROMPT STR0034 OF oPanel PIXEL //"Saldos"
		@ 16, 11 SAY STR0035   OF oPanel PIXEL //"A Pagar"
		@ 29, 11 SAY STR0036 OF oPanel PIXEL //"A Receber"
		@ 16,162 SAY STR0037  OF oPanel PIXEL //"Em &Caixa"
		@ 29,162 SAY STR0038 OF oPanel PIXEL //"Em &Bancos"
		@ 14, 73 MSGET nAtrPagar   SIZE 76,10 OF oPanel WHEN .F. PICTURE TM(nAtrPagar,21,TamSX3("E2_SALDO")[2]) PIXEL Hasbutton
		@ 29, 73 MSGET nAtrReceber SIZE 76,10 OF oPanel WHEN .F. PICTURE TM(nAtrPagar,21,TamSX3("E1_SALDO")[2]) PIXEL Hasbutton
		@ 14,231 MSGET oGet01 VAR nCaixas     SIZE 76,10 OF oPanel WHEN .T. VALID { || If(oGet01:lModified,;
																					(CalcSaldo(aFluxo,nValBancos,nCaixas,nAtrReceber,nAtrPagar,0),oFluxo:Refresh(.T.)), Nil), .T. } PICTURE "@E 999,999,999.99" PIXEL Hasbutton
		@ 29,231 MSGET oGet02 VAR nValBancos  SIZE 76,10 OF oPanel WHEN .T. VALID { || If(oGet02:lModified,;
																					(CalcSaldo(aFluxo,nValBancos,nCaixas,nAtrReceber,nAtrPagar,0),nBancos:=nValbancos,oFluxo:Refresh(.T.)),Nil), .T. } PICTURE "@E 999,999,999.99" PIXEL Hasbutton
		If !lPanelFin  //Nao chamado pelo Painel Financeiro
			@ 06,315 BUTTON STR0039 SIZE 32, 13 OF oPanel PIXEL ACTION Grafico(oDlg,aFluxo,nMoeda,cTit) //"&Grafico"
			@ 06,351 BUTTON STR0040 SIZE 32, 13 OF oPanel PIXEL ACTION oDlg:End() //"&Sair"
			@ 19,315 BUTTON STR0041 SIZE 32, 13 OF oPanel PIXEL ACTION Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo,nLimCred) //"Si&mulação"

			@ 19,351 BUTTON STR0042 SIZE 32, 13 OF oPanel PIXEL ACTION Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda,lLimCred,cVisaoG) //"&Relatório"

			@ 32,315 BUTTON STR0189 SIZE 32, 13 OF oPanel PIXEL ACTION Fc021Excel(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico)  //"&Exportar para Excel"

			@ 32,351 BUTTON STR0266 SIZE 32, 13 OF oPanel PIXEL ACTION Fc021Grava(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico,cPeriodo,nPeriodos)  //"Salvar"
			If ExistBlock("FC021MENU")
				@ 32,386 BUTTON "Salvar Fluxo" SIZE 68, 13 OF oPanel PIXEL ACTION ExecBlock("FC021MENU",.F.,.F.,oFluxo)
			EndIf
		Endif

		@ aPosObj[2,1]-63, aPosObj[2,2] LISTBOX oFluxo FIELDS ;
			HEADER cTit   ,; //"Dia","Semana","Decendio","Quinzena","Mes"
					STR0043,; //"Entradas"
					STR0044,; //"Saidas"
					STR0045,; //"Saldo do Dia"
					STR0046,; //"Var.Dia"
					STR0047,; //"Entr.Acumul."
					STR0048,; //"Saida Acumul."
					STR0049,; //"Saldo Acumul."
					STR0050 SIZE aPosObj[2,3],aPosObj[2,4]+259; //"Var. Acumul."
			COLSIZES If(Left(cPeriodo,2)="01",30,45),;
				GetTextWidth(0,"BBBBBBB"),;
				GetTextWidth(0,"BBBBBBB"),;
				GetTextWidth(0,"BBBBBBB"),;
				GetTextWidth(0,"BBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBB");
			OF oDlg ON DBLCLICK (If(lAnalitico, FluxoAna(aArqTmp[2], aArqTmp[4], cAliasPc, cAliasPv, aArqCo[4],cAliasEmp,cAliasApl,aTmpAnaCtrc[1],aFluxo[oFluxo:nAt][DATAFLUXO],aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo,cAliasChq,oFluxo,nLimCred,aTmpAnaSol[1],cAliasDMSCompra,cAliasDMSVenda), IW_MsgBox(STR0051 + STR0023,STR0198,"STOP"))) PIXEL //"Não foi selecionado Processa analitico! Impossivel consultar."

		If lFC21CTRFLX
		aFluxo := ExecBlock( "FC21CTRFLX", .f., .f., {aFluxo} )
		EndIf

		oFluxo:SetArray(aFluxo)
		oFluxo:bLine := { || {xPadC(Transform(aFluxo[oFluxo:nAt,DATAFLUXO],""),45),;
									Transform(aFluxo[oFluxo:nAt,ENTRADAS				]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SAIDAS				]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SALDODIA				]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,VARIACAODIA			]	,"@r 9999999999.99%"),;
									Transform(aFluxo[oFluxo:nAt,ENTRADASACUMULADAS]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SAIDASACUMULADAS	]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SALDOACUMULADO		]	,"@e 999,999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,VARIACAOACUMULADA	]	,"@r 9999999999.99%")}}
		If !lPanelFin
			oFluxo:bRClicked       := { |o,nX,nY| oMenu:Activate(nX,nY,oFluxo) }
			oFluxo:oWnd:bRClicked  := { |o,nX,nY| oMenu:Activate(nX,nY,oFluxo) }
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define os itens do Menu PopUp                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MENU oMenu POPUP
				MENUITEM STR0039	Action Grafico(oDlg,aFluxo,nMoeda,cTit) //"&Grafico"
				MENUITEM STR0041  Action Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo,nLimCred) //"Si&mulação"

				MENUITEM STR0042 	Action Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda,lLimCred,cVisaoG) //"&Relatório"

				MENUITEM STR0052 	Action (If(lAnalitico, FluxoAna(aArqTmp[2], aArqTmp[4], cAliasPc, cAliasPv, aArqCo[4],cAliasEmp,cAliasApl,aTmpAnaCtrc[1],aFluxo[oFluxo:nAt][DATAFLUXO],aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo,cAliasChq,oFluxo,nLimCred,aTmpAnaSol[1],cAliasDMSCompra,cAliasDMSVenda), IW_MSGBOX(STR0051 + STR0023,STR0198,"STOP"))) //"Visualiza etapa" //"Fluxo Analitico"###"Não foi selecionado Processa analitico! Impossivel consultar."

				//Desabilitar botão de exportação para Excel quando SmartClient HTML
				MENUITEM STR0053  Action Fc021Excel(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico) // "Exportar para Excel"

				If ExistBlock("FC021MENU")
					MENUITEM STR0236  Action ExecBlock("FC021MENU",.F.,.F.,oFluxo)
				Endif
			ENDMENU
		Endif
		oFluxo:Align := CONTROL_ALIGN_ALLCLIENT

		If lPanelFin  //Chamado pelo Painel Financeiro
			aButtonTxt := {}
			AADD(aButtonTxt,{STR0039,STR0039,{||Grafico(oDlg,aFluxo,nMoeda,cTit)}}) //"&Grafico"
			AADD(aButtonTxt,{STR0041,STR0041,{||Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo,nLimCred)}}) //"Si&mulação"

			AADD(aButtonTxt,{STR0042,STR0042,{||Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda,lLimCred,cVisaoG)}}) //"&Relatório"

			AADD(aButtonTxt,{STR0232,STR0053,{||Fc021Excel(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico)}}) //"&Exportar para Excel"

			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
				,{||oDlg:End()},,aButtonTxt)
		Else
			ACTIVATE MSDIALOG oDlg
		Endif
	Endif
Endif

If cAliasPc != Nil
	(cAliasPc)->(DbCloseArea())
	//Deleta tabela temporária no banco de dados
	If _oFINC0216 <> Nil
		_oFINC0216:Delete()
		_oFINC0216 := Nil
	Endif
Endif

If cAliasPv != Nil
	(cAliasPv)->(DbCloseArea())
	//Deleta tabela temporária no banco de dados
	If _oFINC0217 <> Nil
		_oFINC0217:Delete()
		_oFINC0217 := Nil
	Endif
Endif

If aArqTmp[2] != Nil .And. Select(aArqTmp[2]) > 0
	(aArqTmp[2])->(DbCloseArea())
	(aArqTmp[4])->(DbCloseArea())

	//Deleta tabelas temporárias no banco de dados
	If _oFINC0211 <> Nil
		_oFINC0211:Delete()
		_oFINC0211 := Nil
	Endif

	If _oFINC0212 <> Nil
		_oFINC0212:Delete()
		_oFINC0212 := Nil
	Endif
Endif

If aArqCo != Nil
	// Apaga o arquivo sintético de comissões
	If aArqCo[4] != Nil .And. Select(aArqCo[4]) > 0
		(aArqCo[4])->(DbCloseArea())
		If _oFINC0213 <> Nil
			_oFINC0213:Delete()
			_oFINC0213 := Nil
		Endif
	Endif

Endif

If cAliasEmp != Nil
	(cAliasEmp)->(DbCloseArea())
	//Deleta tabela temporária no bano de dados
	If _oFINC0214 <> Nil
		_oFINC0214:Delete()
		_oFINC0214 := Nil
	Endif
Endif

If cAliasApl != Nil
	(cAliasApl)->(DbCloseArea())
	//Deleta tabela temporária no banco de dados
	If _oFINC0215 <> Nil
		_oFINC0215:Delete()
		_oFINC0215 := Nil
	Endif
Endif

If cAliasChq != Nil
	(cAliasChq)->(DbCloseArea())
	//Deleta tabela temporária no banco de dados
	If _oFINC0218 <> Nil
		_oFINC0218:Delete()
		_oFINC0218 := Nil
	Endif
Endif

If aTmpAnaCtrc[1] != Nil
	(aTmpAnaCtrc[1])->(DbCloseArea())
Endif

If aTmpAnaSol[1] != Nil
	(aTmpAnaSol[1])->(DbCloseArea())


	//Deleta tabela temporária no banco de dados
	If _oFINC021a <> Nil
		_oFINC021a:Delete()
		_oFINC021a := Nil
	Endif

Endif

If cAliasDMSCompra != Nil
	(cAliasDMSCompra)->(DbCloseArea())
	If _oFINC021e <> Nil
		_oFINC021e:Delete()
		_oFINC021e := Nil
	Endif
Endif

If cAliasDMSVenda != Nil
	(cAliasDMSVenda)->(DbCloseArea())
	If _oFINC021f <> Nil
		_oFINC021f:Delete()
		_oFINC021f := Nil
	Endif
Endif

If oTmpVA <> Nil
	oTmpVA:Delete()
	oTmpVA := Nil
Endif	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³GeraTmp   ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera dados no arquivo temporario, a partir do arquivo de   º±±
±±º          ³ titulos a receber ou do arquivo de titulos a pagar         º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cAlias     -> Alias do arquivo (SE1/SE2)                   º±±
±±º          ³ nOrdem     -> Ordem de Vencto.                             º±±
±±º          ³ dUltData   -> Ultima data do periodo                       º±±
±±º          ³ lConsFil   -> Considera filiais                            º±±
±±º          ³ cFilDe     -> Filial inicial                               º±±
±±º          ³ cFilAte    -> Filial final                                 º±±
±±º          ³ lAnalitico -> Gera dados analiticos                        º±±
±±º          ³ aFluxo     -> Matriz que contera os dados do fluxo         º±±
±±º          ³ cArqAnaP   -> Nome do arquivo temporario Analitico CP      º±±
±±º          ³ cArqAnaR   -> Nome do arquivo temporario Analitico CR      º±±
±±º          ³ nMoeda     -> Codigo da Moeda                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GeraTmp(cAlias,nOrdem,dUltData,lConsFil,cFilDe,cFilAte,lAnalitico,;
							   aFluxo,cArqAnaP,cArqAnaR,nMoeda,aTotais,aPeriodo,cFilterUser,;
							   lConsDtBase,lTitFuturo, cSinal,lSeekVA,cTempVA,lContinua)
Local cAliasAnaP
Local cAliasAnaR
Local cAliasAna
Local cAliasTrb
Local cAliasAux
Local nSaldoTit
Local aCposAna
Local aCposSin
Local dDataTrab
Local cCampo		:= Right(cAlias,2)
Local nCampSin		:= If(Upper(cAlias) == "SE1", ENTRADAS, SAIDAS)
Local cCliFor
Local nAscan
Local cAbatim		:= MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM
Local aSx3Box		:= F021SitCob()
Local cAliasCF		:= ""
Local lAliasCF		:= .F.
Local nCiclos		:= 0
Local nAscanPA		:= 0
Local nX			:= 0
Local lFc021Fil		:= ExistBlock("FC021FIL")
Local dDataVcOri	:= Ctod("//")
Local nDesconto
Local lTxMoeda
Local nDiasRet		:= 0
Local lFC021MAM		:= ExistBlock("FC021MAN")
Local cE1Situaca	:= ""
Local cFils			:= ""
Local lPAFUTFL		:= SuperGetMv("MV_PAFUTFL",.T.,.F.)
//--- Tratamento Gestao Corporativa
Local lGestao		:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilFwSE2		:= IIF( lGestao .And. FindFunction("FwFilial"), FwFilial("SE2") , xFilial("SE2") )
//--- Rastro Financeiro
Local lRastro		:= If(FindFunction("FVerRstFin"),FVerRstFin(),.F.)
Local cAliasRst		:= If( Upper(cAlias) == "SE1" , "FI7" , "FI8" )
Local lNRastDSD		:= SuperGetMV("MV_NRASDSD",.T.,.F.)
Local aData			:= {}
Local nPos			:= 0
Local dDataAux		:= Ctod("//")
Local lFValAcess	:= ExistFunc('FValAcess')
Local cTipo         := ""
Local lConsFlCx     := .T.
Local lExibVenc     := .T.
Local lExibEmis     := .T.
Local lFc021atrb    := ExistBlock("FC021ATRB")
Local lFc021Cpo		:= ExistBlock("FC021CPO")
Local cQuery
Local cQry
Local aStru
Local dDataM2 	    := Ctod("//")
Local nTxC 		    := 0
Local aCposA	    := {}
Local dDataBx       := Ctod("//")
Local cInsert       := "" 
Local cValues		:= ""
Local cBdTable 		:= ""
Local lCabec		:= .F.
Local aAuxGem		:= {}
Local nTamNome		:= 0
Local cChaveTit		:= ""
Local aTitulos		:= {}
Local nPosTitPai	:= 0
Local nTamChave		:= 0

DEFAULT cSinal = '-'
DEFAULT lContinua := .T.

cAlias := Upper(cAlias)

cAliasAnaP := "cArqAnaP"  // Alias do arquivo analitico
cAliasAnaR := "cArqAnaR"  // Alias do arquivo analitico
cAliasAna  := If(cAlias=="SE1","cArqAnaR","cArqAnaP")

cAliasCF := StrTran(cAlias,"E","A")
lAliasCF := Empty(FwFilial(cAliasCF))


If cPaisLoc == "ARG"
	//Obtem as situacoes selecionadas
	For nX := 1 To Len(aVetor)
		If aVetor[nX,1]
			cE1Situaca += aVetor[nX,2] +"|"
		EndIf
	Next nX
EndIf

// Analitico
If lAnalitico .And. (_oFINC0211 == Nil .Or. _oFINC0212 == Nil)
	aCposAna := {}
	nTamNome := IIF(TamSx3("A2_NOME")[1] > TamSx3("A1_NOME")[1], TamSx3("A2_NOME")[1], TamSx3("A1_NOME")[1])
	nTamChave := TamSx3(cCampo+"_FILIAL")[1]+TamSx3(cCampo+"_PREFIXO")[1]+TamSx3(cCampo+"_NUM")[1]+TamSx3(cCampo+"_PARCELA")[1]+;
					TamSx3(cCampo+"_TIPO")[1]+TamSx3("A1_COD")[1]+TamSx3(cCampo+"_LOJA")[1]
	If nTamChave < 40
		nTamChave := 40
	EndIf
	Aadd( aCposAna, { "PERIODO"  , "C", 25, 0 } )
	Aadd( aCposAna, { "DATAX"    , "D", 08, 0 } )
	Aadd( aCposAna, { "FILIAL"   , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3(cCampo+"_FILIAL")[1] ), 0 } )
	Aadd( aCposAna, { "PREFIXO"  , "C", TamSx3(cCampo+"_PREFIXO")[1], 0 } )
	Aadd( aCposAna, { "NUM"      , "C", TamSx3(cCampo+"_NUM")[1], 0 } )
	Aadd( aCposAna, { "PARCELA"  , "C", TamSx3(cCampo+"_PARCELA")[1], 0 } )
	Aadd( aCposAna, { "TIPO"     , "C", TamSx3(cCampo+"_TIPO")[1], 0 } )
	Aadd( aCposAna, { "CLIFOR"   , "C", TamSx3("A1_COD")[1], 0 } )
	Aadd( aCposAna, { "NOMCLIFOR", "C", nTamNome, 0 } )
	Aadd( aCposAna, { "LOJA"     , "C", TamSx3(cCampo+"_LOJA")[1], 0 } )
	Aadd( aCposAna, { "SALDO"    , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	If cAlias == "SE1"
		Aadd( aCposAna, { "SITUACAO", "C",TamSx3("FRV_DESCRI")[1], 0 } )
		Aadd( aCposAna, { "PORTADO", "C", TamSx3(cCampo+"_PORTADO")[1], 0 } )
		Aadd( aCposAna, { "AGEDEP", "C", TamSx3(cCampo+"_AGEDEP")[1], 0 } )
		Aadd( aCposAna, { "CONTA", "C", TamSx3(cCampo+"_CONTA")[1], 0 } )
	Endif

	Aadd( aCposAna, { "CHAVE"  , "C", nTamChave, 0 } )
	Aadd( aCposAna, { "APELIDO", "C", 10, 0 } )
   // Ponto de entrada para criar campos no arquivo temporario
	If lFC021Cpo
		aCposA := ExecBlock("FC021CPO",.F.,.F.,{aCposAna})
		For nX := 1 to len(aCposA)
 			aAdd(aCposAna,aCposA[nX])
	 	Next
	EndIf
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "FLAG"     , "L", 1, 0 } )

	//------------------
	//Criação da tabela temporaria 1
	//------------------
	If _oFINC0211 <> Nil
		_oFINC0211:Delete()
		_oFINC0211 := Nil
	Endif

	If Select(cAliasAnaP) > 0
		(cAliasAnaP)->(DbCloseArea())
	EndIf

	_oFINC0211 := FWTemporaryTable():New( cAliasAnaP )
	_oFINC0211:SetFields(aCposAna)
	_oFINC0211:AddIndex("1", {"DATAX"})
	_oFINC0211:Create()

	//------------------
	//Criação da tabela temporaria 2
	//------------------
	If _oFINC0212 <> Nil
		_oFINC0212:Delete()
		_oFINC0212 := Nil
	Endif

	If Select(cAliasAnaR) > 0
		(cAliasAnaR)->(DbCloseArea())
	EndIf

	_oFINC0212 := FWTemporaryTable():New( cAliasAnaR )
	_oFINC0212:SetFields(aCposAna)
	_oFINC0212:AddIndex("1", {"DATAX"})
	_oFINC0212:Create()

Endif

aCposSin :=	{{"DATAX"   , "D" , 08, 0},;
				{"ENTR"    , "N" , 17, 2},;
				{"SAID"    , "N" , 17, 2},;
				{"SALDO"   , "N" , 17, 2},;
				{"ENTRAC"  , "N" , 17, 2},;
				{"SAIDAC"  , "N" , 17, 2},;
				{"SALDOAC" , "N" , 17, 2},;
				{"VARIACAO", "N" ,  9, 2},;
				{"VARIACAC", "N" ,  9, 2},;
				{"FLAG"    , "L" , 1, 0 }}

cFils := FincRetFils() // Retorna filiais que o usuario tem acesso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConsFil
	cFilDe  := xFilial(cAlias)
	cFilAte := xFilial(cAlias)
EndIf

aStru     := (cAlias)->(dbStruct())
cAbatim   := FormatIn(cAbatim,"/")
cAliasTrb := "FINC021"
caliasAux := "DESD0BR"
cQuery := ""
aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
cQuery := "SELECT "+SubStr(cQuery,2)
cQuery +=         ","+cAlias+".R_E_C_N_O_ TITRECNO "
cQuery += "FROM "+RetSqlName(cAlias)+ " "+ cAlias + " "

cQuery += "WHERE "
If lFiliais
	If Empty( cFilFwSE2 )
		cQuery += cAlias + "." + cCampo + "_FILORIG IN ("+cLisFil+") AND "
	Else
		cQuery += cAlias + "." + cCampo + "_FILIAL IN ("+cLisFil+") AND "
	EndIf		
ElseIf lConsFil
	If Empty( cFilFwSE2 )
		cQuery += cAlias + "." + cCampo + "_FILORIG BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
	Else
		cQuery += cAlias + "." + cCampo + "_FILIAL BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
	EndIf
Else
	If !Empty( cFils ) .and. !("@@" $ cFils)
		If Empty( cFilFwSE2 )
			cQuery += cAlias + "." + cCampo + "_FILORIG IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
		Else
			cQuery += cAlias + "." + cCampo + "_FILIAL IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
		EndIf
	ElseIf Empty( cFilFwSE2 )
		cQuery += cAlias + "." + cCampo + "_FILIAL = '" + xFilial(cAlias) + "' AND "
	EndIf
EndIf
If lConsDtBase
	cQuery += cAlias + "." + cCampo + "_VENCREA >= '"+Dtos(dDataBase)+"' AND "
Else
	cQuery += cAlias + "." + cCampo + "_VENCREA > '"+Dtos(dDataBase)+"' AND "
EndIf
cQuery += cAlias + "." + cCampo + "_VENCREA <= '"+Dtos(dUltData)+"' AND "
// Nao considerar titulos emitidos apos a data base, para compatiblizacao
// com FINR140.
If cAlias == "SE1"
	If !lTitFuturo  //Nao considerar titulos com emissao posterior a database
		cQuery += "(E1_EMISSAO <= '"+Dtos(dDataBase) + "' OR E1_TIPO IN " + FormatIn(MVRECANT,"/")+") AND "
	Endif

	If cPaisLoc == "ARG"
		cQuery += "E1_SITUACA IN " + FormatIn(cE1Situaca,"|")+" AND "
	EndIf
Else
	If !lTitFuturo  //Nao considerar titulos com emissao posterior a database
		cQuery += "(E2_EMIS1 <= '"+Dtos(dDataBase) +"' OR E2_TIPO IN " + FormatIn(MVPAGANT,"/")+") AND "
	Endif
Endif
If !lConsDtBase
	cQuery += cAlias + "." + cCampo + "_SALDO > 0 AND "
Endif
cQuery += cAlias + "." + cCampo + "_FLUXO<>'N' AND "
cQuery += cAlias + ".D_E_L_E_T_=' ' "

If lFC021MAM
	cQuery :=  ExecBlock("FC021MAN",.F.,.F.,{cQuery,cAlias,cCampo})
EndIf
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})

While (cAliasTrb)->(!Eof()) .and. lContinua
	IncProc(STR0055 + If(cAlias=="SE1", STR0056, STR0057)) //"Processando titulos a "###"Receber"###"Pagar"
	dDataTrab := (cAliasTrb)->&(cCampo+"_VENCREA")
	
	If cAlias == "SE1"
		If !(Empty((cAliasTrb)->(E1_TITPAI)))
			If (nPosTitPai := AScan(aTitulos, {|titulos| titulos[DEF_POS_TITPAI] == RTrim((cAliasTrb)->(E1_FILIAL+E1_TITPAI))})) > 0
				dDataTrab := aTitulos[nPosTitPai][DEF_POS_DTTRAB]
			ElseIf SE1->(MsSeek(FwXFilial("SE1", (cAliasTrb)->E1_FILIAL) + RTrim((cAliasTrb)->(E1_TITPAI))))
				dDataVcOri := (cAliasTrb)->E1_VENCTO
				If DTOS(DataValida(dDataVcOri)) == DTOS(dDataTrab) .And. !Empty(SE1->E1_PORTADO)
					If SA6->(MsSeek(FwXFilial("SA6", SE1->E1_FILORIG) + SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA)))
						nDiasRet := SA6->A6_RETENCA
						For nX := 1 To nDiasRet
							dDataTrab := DataValida(dDataTrab + 1,.T.)
						Next nX
						cChaveTit	:= SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)
						AAdd(aTitulos, {cChaveTit, dDataTrab})
					EndIf
				EndIf
			EndIf
		ElseIf (nPosTitPai := AScan(aTitulos, {|titulos| titulos[DEF_POS_TITPAI] ==;
			RTrim((cAliasTrb)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))})) > 0
				dDataTrab := aTitulos[nPosTitPai][DEF_POS_DTTRAB]
		ElseIf FN022SITCB((cAliasTrb)->E1_SITUACA)[2]
			dDataVcOri := (cAliasTrb)->E1_VENCTO
			//Verifico se o proximo dia util apos o vencimento eh igual ao vencto real do titulo
			//Se for igual e o titulo estiver em cobranca, aplico os dias de retencao do banco
			If DToS(DataValida(dDataVcOri)) == DToS(dDataTrab)
				If SA6->(MsSeek(FwXFilial("SA6", (cAliasTrb)->E1_FILORIG) + (cAliasTrb)->(E1_PORTADO + E1_AGEDEP + E1_CONTA)))
					nDiasRet := SA6->A6_RETENCA
					For nX := 1 To nDiasRet
						dDataTrab := DataValida(dDataTrab + 1,.T.)
					Next nX
					cChaveTit   := (cAliasTrb)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)
					AAdd(aTitulos, {cChaveTit, dDataTrab})
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a data de vencto. nao ultrapassar a ultima data da consulta ³
	//³ e nao for um adiantamento                                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTipo := (cAliasTrb)->&(cCampo+"_TIPO")
	lConsFlCx := dDataTrab <= dUltData
	lExibVenc := .T.
	lExibEmis := .T.

	If lConsFlCx .And. cTipo $ MVRECANT + IIf(!cPaisLoc $"ARG|CHI",MVPAGANT,"")
		If cAlias == "SE2" .And. cTipo $ MVPAGANT
			//Se não possui mov banc mostra considera no flux cx a previsão de pagto do PA, e não mostra a emissão.
			If F080MovPA(.F., (cAliasTrb)->E2_PREFIXO, (cAliasTrb)->E2_NUM, (cAliasTrb)->E2_PARCELA,(cAliasTrb)->E2_TIPO, (cAliasTrb)->E2_FORNECE, (cAliasTrb)->E2_LOJA, xFilial("FK5", (cAliasTrb)->E2_FILORIG)) == 0
				lExibVenc := .T.
				lExibEmis := .F.
			Else
				lExibVenc := lPAFUTFL .And. (cAliasTrb)->E2_EMISSAO > dDataBase
				lExibEmis := .T.
			EndIf
		Else
			lConsFlCx := (If(cAlias == "SE2", (cAliasTrb)->E2_EMISSAO, (cAliasTrb)->E1_EMISSAO) > dDataBase)
		EndIf
	EndIf

	If lConsFlCx
		// Posiciona SE1 ou SE2 se for TOP e nao AS400, pois o filtro de usuario e
		// feito sobre o arquivo original.
		If TcSrvType() != "AS/400"
			DbSelectArea(cAlias)
			MsGoto((cAliasTrb)->TITRECNO)
		Endif

		If (cAlias)->&(cCampo+"_DESDOBR") == 'S' .and. lRastro .and. !lNRastDSD

			cQry := " SELECT COUNT(*) AS RESULT FROM " + RetSqlName(cAliasRst)+ " "+ cAliasRst + " "
			cQry += " WHERE "
			cQry +=           cAliasRst + "." + cAliasRst + "_FILIAL = '" + (cAliasTrb)->&(cCampo+"_FILIAL") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_PRFDES = '" + (cAliasTrb)->&(cCampo+"_PREFIXO") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_NUMDES = '" + (cAliasTrb)->&(cCampo+"_NUM") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_PARDES = '" + (cAliasTrb)->&(cCampo+"_PARCELA") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_TIPDES = '" + (cAliasTrb)->&(cCampo+"_TIPO") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_FORDES = '" + (cAliasTrb)->&(cCampo+"_FORNECE") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_LOJDES = '" + (cAliasTrb)->&(cCampo+"_LOJA") + "'"
			cQry := ChangeQuery(cQry)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasAux,.T.,.T.)

			If (cAliasAux)->RESULT <= 0
				(cAliasAux)->(dbCloseArea())
				(cAliasTrb)->(dbSkip())
				Loop
			Else
				(cAliasAux)->(dbCloseArea())
			EndIf

		EndIf

		DbSelectArea(cAlias)
		If lFc021Fil
			cFilterUser := ExecBlock("FC021FIL", .F., .F., {cAlias} )
		Endif
		// Se nao existir filtro de usuario, ou se o filtro retornar uma expressao
		// valida para o registro atual do titulo, entao processsa o registro.
		If Empty(cFilterUser) .Or. (&cFilterUser)

			nSaldoTit := 0
			dDataBx   := (cAliasTrb)->&(cCampo+"_BAIXA")
			dDataBx   := Iif(!Empty(dDataBx), dDataBx + nDiasRet, dDataBx)
			dDataAux  := DataValida(dDataBx,.T.)
			nPos := Ascan(aData, { |x| x[1] == dDataBx} )
			If nPos == 0
				dDataAux := DataValida(dDataBx,.T.)
				aadd(aData, {dDataBx, dDataAux})
			EndIf

			If lConsDtBase .AND. dDataAux > dDataBase
					nSaldoTit := SaldoTit(	(cAliasTrb)->&(cCampo+"_PREFIXO"),;
												(cAliasTrb)->&(cCampo+"_NUM"),;
												(cAliasTrb)->&(cCampo+"_PARCELA"),;
												(cAliasTrb)->&(cCampo+"_TIPO"),;
												(cAliasTrb)->&(cCampo+"_NATUREZA"),;
												If(cAlias="SE1","R","P"),;
												(cAliasTrb)->&(cCampo+IF(cAlias="SE1","_CLIENTE","_FORNECE")),;
												nMoeda,(cAliasTrb)->&(cCampo+"_VENCREA"),;
												dDataBase,(cAliasTrb)->&(cCampo+"_LOJA"),,If(cPaisLoc=="BRA",(cAliasTrb)->&(cCampo+"_TXMOEDA"),0),2)

				// Se o titulo foi baixado e a data da baixa eh maior que a database, os campos SDACRES e SDDECRES utilizados na SaldoTit
				// estao zerados pois o titulo foi baixado, entao deve considerar os campos ACRESC e DECRESC do para recompor o saldo.
				nSaldoTit += ( (cAliasTrb)->&(cCampo+"_ACRESC") - (cAliasTrb)->&(cCampo+"_DECRESC") )
			Else
				// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
				dDataAux := dDataTrab
				nPos := Ascan(aData, { |x| x[1] == dDataTrab })
				If nPos == 0
					dDataAux := DataValida(dDataTrab,.T.)
					aadd(aData,{dDataTrab, dDataAux})
				EndIf

				If (Empty(dDataAux) .Or. ValType(dDataAux) != "D")
					dDataAux := dDataBase
				EndIf

				lTxMoeda := SM2->(MsSeek(dDataAux)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(nMoeda))) != 0
				dDataM2 := If(lTxMoeda, dDataAux, dDataBase)

				If cAlias == "SE1"
					If cPaisLoc == "BRA"
						nTxC := (cAliasTrb)->E1_TXMOEDA

						If (cAliasTrb)->E1_MOEDA > 1 .And. Empty(nTxC) .And. SM2->(DbSeek(dDataM2))
							nTxC := SM2->(FieldGet(FieldPos("M2_MOEDA" + AllTrim(cValToChar((cAliasTrb)->E1_MOEDA)))))
						EndIf
					EndIf

					If (cAliasTrb)->E1_MOEDA != nMoeda
						nSaldoTit := xMoeda( (cAliasTrb)->(E1_SALDO+E1_SDACRES-E1_SDDECRE), (cAliasTrb)->E1_MOEDA, nMoeda, dDataM2,,nTxC)
					Else
						nSaldoTit := (cAliasTrb)->(E1_SALDO+E1_SDACRES-E1_SDDECRE)
					EndIf	
				Else
					If cPaisLoc == "BRA"
						nTxC := (cAliasTrb)->E2_TXMOEDA

						If (cAliasTrb)->E2_MOEDA > 1 .And. Empty(nTxC) .And. SM2->(DbSeek(dDataM2))
							nTxC := SM2->(FieldGet(FieldPos("M2_MOEDA" + AllTrim(cValToChar((cAliasTrb)->E2_MOEDA)))))
						EndIf
					EndIf
					If (cAliasTrb)->E2_MOEDA != nMoeda
						nSaldoTit := xMoeda( (cAliasTrb)->(E2_SALDO+E2_SDACRES-E2_SDDECRE), (cAliasTrb)->E2_MOEDA, nMoeda, dDataM2,,nTxC)
					Else
						nSaldoTit := (cAliasTrb)->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
					EndIf	
				EndIf
			EndIf

			If cAlias == "SE1"
				nDesconto := FaDescFin(cAliasTrb,dDataBase,nSaldoTit,1)
				nSaldoTit -= nDesconto

				// Se titulo do Template Gem
				If HasTemplate("LOT") .And. !Empty(SE1->E1_NCONTR)
					aAuxGem		:= ExecTemplate("CMDtPrc",.F.,.F.,{(cAliasTrb)->E1_PREFIXO,(cAliasTrb)->E1_NUM ,(cAliasTrb)->E1_PARCELA ,(cAliasTrb)->E1_VENCREA ,(cAliasTrb)->E1_VENCREA})
					nSaldoTit	+= aAuxGem[2]
				Endif

				// Calculo valores acessórios
				If lFValAcess .AND. lSeekVA .AND. ( cTempVA )->( DbSeek((cAliasTrb)->(	E1_FILIAL	+ '|' + ;
																						E1_PREFIXO	+ '|' + ;
																						E1_NUM		+ '|' + ;
																						E1_PARCELA	+ '|' + ;
																						E1_TIPO		+ '|' + ;
																						E1_CLIENTE	+ '|' + ;
																						E1_LOJA		) ) )						
					nSaldoTit += (cAliasTrb)->(FValAcess(E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NATUREZ, !Empty(E1_BAIXA), "", "R", E1_BAIXA))
				Endif
			ElseIf cAlias == "SE2"
				// Calculo valores acessórios
				If lFValAcess .AND. lSeekVA .AND. ( cTempVA )->( DbSeek((cAliasTrb)->(	E2_FILIAL	+ '|' + ;
																						E2_PREFIXO	+ '|' + ;
																						E2_NUM		+ '|' + ;
																						E2_PARCELA	+ '|' + ;
																						E2_TIPO		+ '|' + ;
																						E2_FORNECE	+ '|' + ;
																						E2_LOJA		) ) )						
					nSaldoTit += (cAliasTrb)->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, !Empty(E2_BAIXA), "", "P", E2_BAIXA))
				Endif
			EndIf

			If Abs(nSaldoTit) > 0.0001
				// Verifica a situacao, somente se nao for Contas a Receber.
				If cAlias == "SE2" .Or. !(FN022SITCB( (cAliasTrb)->E1_SITUACA )[3])
					nCiclos	:=	1

					If lExibVenc
						nAscan := TemFluxoData(dDataTrab,aFluxo)

						If ((cTipo $ cAbatim) .Or. (cSinal == '-' .And. cTipo $ cAbatim+"/"+MVRECANT) .Or. (cTipo $ MVPAGANT .And. lExibEmis))
							aFluxo[nAscan][nCampSin] -= nSaldoTit
						Else
							aFluxo[nAscan][nCampSin] += nSaldoTit
						EndIf
					EndIf

					//Movimento Bancario gerado pelo PA (na data de emissao do PA)
					If lExibEmis .And. cAlias == "SE2" .And. cTipo $ MVPAGANT .And. (cAliasTrb)->E2_EMISSAO >= dDataBase .And. (!cPaisLoc $"ARG|CHI" .And. Empty(E2_ORDPAGO))
						nAscanPA := TemFluxoData((cAliasTrb)->E2_EMISSAO,aFluxo)
						aFluxo[nAscanPA][nCampSin] += nSaldoTit

						If lExibVenc
							nCiclos	:= 2
						Else
							If (cAliasTrb)->E2_EMISSAO == dDataBase
								nValorPA	+= 	nSaldoTit
							EndIf
						EndIf
					Endif

					If lAnalitico // Analitico
						For nX := 1 To nCiclos
							cCliFor := (cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))
							DbSelectArea(StrTran(cAlias,"E","A"))
							DbSetOrder(1)
							MsSeek(xFilial(StrTran(cAlias,"E","A"),(cAliasTrb)->&(cCampo+"_FILORIG"))+cCliFor+(cAliasTrb)->&(cCampo+"_LOJA"))
							DbSelectArea(cAliasTrb)
							
 							If cAlias=="SE1"
								cBdTable := _oFINC0212:GETREALNAME()
							Else
								cBdTable := _oFINC0211:GETREALNAME()
							Endif
	
							cInsert := "INSERT INTO "+cBdTable
							cValues += " VALUES( "

							If nX == 1 .And. lExibVenc
								nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
								If nAscan > 0
									cInsert += "(DATAX, "
									cValues += " '"+DTOS(dDataTrab)+"', " // Atualiza a coluna DataX
									cInsert += " PERIODO, "
									cValues += " '"+aPeriodo[nAscan][2]+"', " // Atualiza a coluna Periodo
									lCabec  := .T.
								EndIf
							Else
								If nAscanPA := Ascan(aPeriodo, {|e| e[1] == (cAliasTrb)->E2_EMISSAO})
									cInsert += "(DATAX, "
									cValues += " '"+DTOS((cAliasTrb)->E2_EMISSAO)+"', " // Atualiza a coluna DataX
									cInsert += " PERIODO, "
									cValues += " '"+aPeriodo[nAscanPA][2]+"', " // Atualiza a coluna Periodo
									lCabec  := .T.
								EndIf
							Endif

							IF lCabec  
								cInsert += " FILIAL, "
							Else
								cInsert += " (FILIAL, "
							Endif
							cValues += " '"+(cAliasTrb)->&(cCampo+"_FILIAL")+"', " //Atualiza coluna FILIAL 

							cInsert += " PREFIXO, "
							cValues += " '"+(cAliasTrb)->&(cCampo+"_PREFIXO")+"', " //Atualiza coluna PREFIXO

							cInsert += " NUM, "
							cValues += " '"+(cAliasTrb)->&(cCampo+"_NUM")+"', " //Atualiza coluna NUM 

							cInsert += " PARCELA, "
							cValues += " '"+(cAliasTrb)->&(cCampo+"_PARCELA")+"', " //Atualiza coluna PARCELA 

							cInsert += " TIPO, "
							cValues += " '"+cTipo+"', " //Atualiza coluna TIPO

							cInsert += " CLIFOR, "
							cValues += " '"+cCliFor+"', " //Atualiza coluna CLIFOR

							// Se o cadastro de clientes/fornecedores estiver compartilhado,
							// obtem o nome do clientes/fornecedor do cadastro
							If lAliasCF
								cInsert += " NOMCLIFOR, "
								cValues += " '"+StrTran((cAliasCF)->&(Right(cAliasCF,2)+"_NOME"),"'"," ")+"', " //Atualiza a coluna NOMCLIFOR
							Else
								cInsert += " NOMCLIFOR, "
								cValues += " '"+If(cAlias=="SE1", StrTran(SE1->E1_NOMCLI,"'"," "), StrTran(SE2->E2_NOMFOR,"'"," "))+"', " //Atualiza a coluna NOMCLIFOR
							Endif

							cInsert += " LOJA, "
							cValues += " '"+(cAliasTrb)->&(cCampo+"_LOJA")+"', " //Atualiza a coluna LOJA

							cIdentific :=	(cAliasTrb)->&(cCampo+"_FILIAL")+;
												(cAliasTrb)->&(cCampo+"_PREFIXO") +;
												(cAliasTrb)->&(cCampo+"_NUM")     +;
												(cAliasTrb)->&(cCampo+"_PARCELA") +;
												cTipo+;
												(cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))+;
												(cAliasTrb)->&(cCampo+"_LOJA")
							
							cInsert += " CHAVE, "
							cValues += " '"+cIdentific+"', " //Atualiza a coluna Chave

							cInsert += " APELIDO, "
							cValues += " '"+cAlias+"', " //Atualiza a coluna Apelido

							If (cTipo $ MVRECANT .Or. nCiclos == 2) .And. nX == 1
								If cAlias == "SE1"
									cInsert += " SALDO, "
									cValues += STR(nSaldoTit * -1)+", " //Atualiza a coluna SALDO
								Else
									cInsert += " SALDO ) "
									cValues += STR(nSaldoTit * -1)+" ) " //Atualiza a coluna SALDO
								Endif
							Else
								If cAlias == "SE1"
									cInsert += " SALDO, "
									cValues += STR(nSaldoTit)+", " //Atualiza a coluna SALDO
								Else
									cInsert += " SALDO ) "
									cValues += STR(nSaldoTit)+" ) " //Atualiza a coluna SALDO
								Endif	
							Endif

							If cAlias == "SE1"
								nAscan := Ascan( aSx3Box, { |e| e[2] = (cAlias)->E1_SITUACA } )
								If nAscan > 0
									cInsert += " SITUACAO, "
									cValues += " '"+AllTrim( aSx3Box[nAscan][3] )+"', " //Atualiza a coluna Situacao
								Endif
								cInsert += " PORTADO, "
								cValues += " '"+(cAliasTrb)->&(cCampo+"_PORTADO")+"', " //Atualiza a coluna PORTADO
								cInsert += " AGEDEP, "
								cValues += " '"+(cAliasTrb)->&(cCampo+"_AGEDEP")+"', " //Atualiza a coluna AGEDEP
								cInsert += " CONTA ) "
								cValues += " '"+(cAliasTrb)->&(cCampo+"_CONTA")+"' ) " //Atualiza a coluna CONTA
							Endif

							cInsert += cValues

							If TcSqlExec(cInsert) <> 0
								MsgAlert(If(cAlias=="SE1",STR0288,STR0289) + CRLF + cIdentific + CRLF + CRLF + STR0290 + CRLF + CRLF + TCSQLError(), STR0291) //"Houve um problema ao processar os dados do título 
								lContinua := MSGYESNO(STR0292, STR0293)
							Else
								(cAliasAna)->(DBGOTO(RECCOUNT()))
							EndIf

							If lFc021atrb //Ponto de entrada para atualizar o valor dos novos campos inclusos no arquivo tmp
								IF !(cAliasAna)->(EOF())
									RecLock(cAliasAna,.F.)
									ExecBlock("FC021ATRB",.F.,.F.,{cAliasAna,cAliasTrb,cCampo})
									(cAliasAna)->(MsUnlock())
								EndIF
							EndIf

							//Pesquisa na matriz de totais, os totais de contas a pagar ou a receber da data de trabalho.
							nAscan := Ascan( aTotais[If(cAlias=="SE1",2,1)], {|e| e[1] == (cAliasAna)->DATAX})

							If nAscan == 0
								If cTipo $ cAbatim
									Aadd( aTotais[If(cAlias=="SE1",2,1)], {(cAliasAna)->DATAX,(cAliasAna)->SALDO*-1})
								Else
									Aadd( aTotais[If(cAlias=="SE1",2,1)], {(cAliasAna)->DATAX,(cAliasAna)->SALDO})
								Endif
							Else
								If cTipo $ cAbatim
									aTotais[If(cAlias=="SE1",2,1)][nAscan][2] -= (cAliasAna)->SALDO // Contabiliza os totais de titulos
								Else
									aTotais[If(cAlias=="SE1",2,1)][nAscan][2] += (cAliasAna)->SALDO // Contabiliza os totais de titulos
								EndIf
							Endif

							cInsert := ""
							cValues := ""
							lCabec := .F.
						Next
					Endif
				EndIf
			EndIf
		Endif
	Endif
	DbSelectArea(cAliasTrb)
	(cAliasTrb)->(dbSkip())
Enddo

dbSelectArea(cAliasTrb)
dbCloseArea()
dbSelectArea(cAlias)

Return { cArqAnaP, cAliasAnaP, cArqAnaR, cAliasAnaR }


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CalcSaldo ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcular o saldo no arquivo temporario                      º±±
±±º          ³Parametros:                                                 º±±
±±º          ³aFluxo      -> Matriz contendo os dados do fluxo            º±±
±±º          ³nBancos     -> Saldo em bancos                              º±±
±±º          ³nCaixas     -> Saldo em caixas                              º±±
±±º          ³nAtrReceber -> Valor dos titulos atrasados a Receber        º±±
±±º          ³nAtrPagar   -> Valor dos titulos atrasados a Pagar          º±±
±±º          ³Retorno:                                                    º±±
±±º          ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcSaldo(aFluxo, nBancos, nCaixas, nAtrReceber, nAtrPagar,nLimCred)
Local nEntrAnt  := 0,;
	  nSaidAnt  := 0,;
	  aArea     := GetArea()
Local nX := 0

// Calcula o saldo inicial
aFluxo[1][SALDOACUMULADO] := (nBancos + nCaixas + nLimCred + nAtrReceber - nAtrPagar)
nSaldoAc := aFluxo[1][SALDOACUMULADO]
ProcRegua(Len(aFluxo))
For nX := 1 to Len(aFluxo)

	IncProc(STR0058)  //"Calculando saldos"
	// Calcula o saldo da data
	aFluxo[nX][SALDODIA] := aFluxo[nX][ENTRADAS]-aFluxo[nX][SAIDAS]

	// Calcula a variacao do dia
	aFluxo[nX][VARIACAODIA] := (aFluxo[nX][SAIDAS]/aFluxo[nX][ENTRADAS]) * 100

	// Calcula os creditos acumulados ate a data
	aFluxo[nX][ENTRADASACUMULADAS] := (nEntrAnt + aFluxo[nX][ENTRADAS])
	nEntrAnt := aFluxo[nX][ENTRADASACUMULADAS]

	// Calcula os debitos acumulados ate a data
	aFluxo[nX][SAIDASACUMULADAS] := (nSaidAnt + aFluxo[nX][SAIDAS])
	nSaidAnt := aFluxo[nX][SAIDASACUMULADAS]

	// Calcula o saldo acumulado ate a data
	aFluxo[nX][SALDOACUMULADO] := (aFluxo[nX][ENTRADAS]-aFluxo[nX][SAIDAS])+nSaldoAc+nValorPA
	nSaldoAc 	:= aFluxo[nX][SALDOACUMULADO]
	nValorPA	:= 0

	// Calcula a variacao acumulada
	aFluxo[nX][VARIACAOACUMULADA] := (aFluxo[nX][SAIDASACUMULADAS]/aFluxo[nX][ENTRADASACUMULADAS])*100

Next

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Consolida ºAutor  ³Claudio D. de Souza º Data ³  15/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcular o saldo no arquivo temporario                      º±±
±±º          ³Parametros:                                                 º±±
±±º          ³aArray      -> Matriz contendo os dados do fluxo            º±±
±±º          ³cPeriodos   -> Codigos dos periodos								  º±±
±±º          ³07 - Semanal                                                º±±
±±º          ³10 - Decendial                                              º±±
±±º          ³15 - Quinzenal                                              º±±
±±º          ³30 - Mensal                                                 º±±
±±º          ³Retorno:                                                    º±±
±±º          ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Consolida(aArray,aTotais,cPeriodos)
Local nX,;
		nY,;
		nZ,;
		nPeriodo := Val(Left(cPeriodos,2)),;
		nResto		  	,;
		aCopia := {}	,;
		nEntradas := 0	,;
		nSaidas	 := 0	,;
		nSoma     := 0	,;
		dDataTrab		,;
		cPer           ,;
		aCopiaTot := {}

If nPeriodo != 1
	aEval(aTotais, {|e|Aadd(aCopiaTot, {})}) // Inicializa aCopiaTot com Array em todos os elementos
Else
	// Transforma a Data para Caracter pois assim sera usada nas rotinas sequintes
	aEval(aArray, {|e| e[DATAFLUXO] := Dtoc(e[DATAFLUXO])})
	For nX := 1 To Len(aTotais)
		For nY := 1 To Len(aTotais[nX])
			aTotais[nX][nY][1] := Dtoc(aTotais[nX][nY][1])
		Next
	Next
Endif
If nPeriodo != 1
	For nX := 1 TO Len(aArray)
		dDataTrab := aArray[nX][DATAFLUXO]
		Do Case
		Case nPeriodo == 7  // Semanal
			// Verifica quantos dias faltam para a proxima semana
			nResto := 6
			If Dow(dDataTrab) != 1
				nResto := 7-Dow(dDataTrab)
			EndIf
		Case nPeriodo == 10 // Decendial
			nResto := 9
			// Verifica quantos dias faltam para o proximo decendio
			If Day(dDataTrab) < 10
				nResto := 10-Day(dDataTrab)
			ElseIf Day(dDataTrab) > 10 .And. Day(dDataTrab) < 20
				nResto := 20-Day(dDataTrab)
			ElseIf Day(dDataTrab) > 20
				nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
			Endif
		Case nPeriodo == 15 // Quinzenal
			nResto := 14
			// Verifica quantos dias faltam para a proxima quinzena
			If Day(dDataTrab) < 15
				nResto := 15-Day(dDataTrab)
			Else
				nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
			Endif
		Case nPeriodo == 30 // Mensal
			// Verifica quantos dias faltam para o proximo mes
			nResto := LastDay(dDataTrab)-dDataTrab
		EndCase
		For nY := nX To (nResto+nX)
			If nY > Len(aArray)
				Exit
			Endif
			nEntradas += aArray[nY][ENTRADAS]
			nSaidas 	 += aArray[nY][SAIDAS]
		Next
		nX := (nY-1)
		If nPeriodo != 1
			cPer := Dtoc(dDataTrab) + STR0182 + Dtoc(aArray[nX][DATAFLUXO]) //" a "
		Endif
		Aadd(aCopia, {cPer,nEntradas, nSaidas,0,0,0,0,0,0})
		// Consolida aTotais
		For nY := 1 To Len(aTotais)
			For nZ := 1 to Len(aTotais[nY])
				// Se os totais tiverem dentro das datas do periodo, acumula os valores
				If aTotais[nY][nZ][1] >= dDataTrab .And. aTotais[nY][nZ][1] <= aArray[nX][DATAFLUXO]
					nSoma += aTotais[nY][nZ][2]
				ElseIf aTotais[nY][nZ][1] > aArray[nX][DATAFLUXO]
					// Senao forca a saida por nao ser amis necessario processar, para nao
					// perder tempo.
					Exit
				Endif
			Next
			If nSoma > 0
				Aadd(aCopiaTot[nY], {cPer, nSoma})
			Endif
			nSoma := 0
		Next
		nEntradas := nSaidas := 0
	Next
	aArray  := aClone(aCopia)
	aTotais := aClone(aCopiaTot)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MontaPerioºAutor  ³Claudio D. de Souza º Data ³  18/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar os periodos na matriz de periodos para ser utilizada º±±
±±º          ³na simulacao e na projecao do fluxo								  º±±
±±º          ³Parametros:                                                 º±±
±±º          ³aArray      -> Matriz contendo as datas do periodo          º±±
±±º          ³cPeriodos   -> Codigos dos periodos								  º±±
±±º          ³07 - Semanal                                                º±±
±±º          ³10 - Decendial                                              º±±
±±º          ³15 - Quinzenal                                              º±±
±±º          ³30 - Mensal                                                 º±±
±±º          ³Retorno:                                                    º±±
±±º          ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaPeriodo(aArray,cPeriodos)
Local nX,;
		nY,;
		nInicio := 0,;
		nFim,;
		nPeriodo := Val(Left(cPeriodos,2)),;
		nResto		  	,;
		aCopia := {}	,;
		dDataTrab		,;
		cPer

For nX := 1 TO Len(aArray)
	dDataTrab := aArray[nX][DATAFLUXO]
	Do Case
	Case nPeriodo == 1  // Diario
		nResto := 0
		cPer := Dtoc(dDataTrab)
	Case nPeriodo == 7  // Semanal
		// Verifica quantos dias faltam para a proxima semana
		nResto := 6
		If Dow(dDataTrab) != 1
			nResto := 7-Dow(dDataTrab)
		EndIf
	Case nPeriodo == 10 // Decendial
		nResto := 9
		// Verifica quantos dias faltam para o proximo decendio
		If Day(dDataTrab) < 10
			nResto := 10-Day(dDataTrab)
		ElseIf Day(dDataTrab) > 10 .And. Day(dDataTrab) < 20
			nResto := 20-Day(dDataTrab)
		ElseIf Day(dDataTrab) > 20
			nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
		Endif
	Case nPeriodo == 15 // Quinzenal
		nResto := 14
		// Verifica quantos dias faltam para a proxima quinzena
		If Day(dDataTrab) < 15
			nResto := 15-Day(dDataTrab)
		Else
			nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
		Endif
	Case nPeriodo == 30 // Mensal
		// Verifica quantos dias faltam para o proximo mes
		nResto := LastDay(dDataTrab)-dDataTrab
	EndCase
	nInicio := nX
	nFim    := (nResto+nX)
	nFim    := If(nFim <= Len(aArray),nFim,Len(aArray))
	nX 	  := nFim
	If nPeriodo != 1
		cPer := Dtoc(dDataTrab)+ STR0182 + Dtoc(aArray[nX][DATAFLUXO]) //" a "
	Endif
	For nY := nInicio To nFim
		If aArray[nY][1] <= aArray[nX][DATAFLUXO]
			Aadd(aCopia,{aArray[nY][1],cPer})
		Else
			Exit
		Endif
	Next
Next
aArray  := aClone(aCopia)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetMoedas ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obter as moedas utilizadas pelo sistema                    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ Nenhum                                                     º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = Codigo da moeda + Descricao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetMoedas
Local aRet     := {}       ,;
		aArea    := GetArea(),;
		aAreaSx6 := Sx6->(GetArea()),;
		cFilSx6

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com as moedas existentes.						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GetMv("MV_MOEDA1")
cFilSx6 := SX6->X6_FIL
While Substr(SX6->X6_VAR,1,8) == "MV_MOEDA" .And. ;
		SX6->(!Eof()) .And. SX6->X6_FIL == cFilSx6
	If Substr(SX6->X6_VAR,9,1) != "P" .And. Substr(SX6->X6_VAR,9,2) != "CM" // Desconsiderar plural e MV_MOEDACM
		Aadd( aRet, StrZero(Val(Substr(SX6->X6_VAR,9,2)),2) + " " + GetMv(SX6->X6_VAR) )
	Endif
	SX6->(DbSkip())
EndDo

Sx6->(RestArea(aAreaSx6))
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetBancos ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obter os bancos do SA6                                     º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetBancos( lConsFil, nMoeda, cFilDe, cFilAte, cTipoSaldo, lRecalcula, aBancos, lZeraSld, nSldBco, lFiliais, cEmpresa)
Local aRet			:= {}
Local aArea			:= GetArea()
Local aAreaSa6		:= SA6->(GetArea())
Local aAreaSe8		:= SE8->(GetArea())
Local cTrbBanco		:= ""
Local cTrbAgencia	:= ""
Local cTrbConta		:= ""
Local cTrbNome		:= ""
Local nTrbSaldo		:= 0
Local lSldBco		:= .F.
Local cSavFil		:= cFilAnt
Local nMoedaBco		:= 0
Local nI			:= 0
Local aRetorno		:= {}
Local cPicture		:= PesqPict("SE8","E8_SALATUA")
Local cQuery		:= ""
Local cAliasSE8		:= GetNextAlias()
Local cFilSE8		:= ""
Local cFilSE8De		:= ""
Local cFilSE8Ate	:= ""
Local cContaAnt		:= ""
Local cAliasSA6		:= GetNextAlias()
Local oSE8Qry		:= Nil

Local nTamFSA6		:= 0	
Local nTamFSE8		:= 0
Local nTamFil		:= 0
Default cEmpresa := FwCodEmp()

If aBancos != Nil
	aRet := aClone(aBancos)
Endif

//Zera o Saldo para o recálculo de Slado por Filial ou por Total
If lZeraSld
	For nI :=1 to Len(aBancos)
		aRet[nI][6] := 0
		aRet[nI][8] := 0
	Next nI
Endif

nTamFSA6 := Len(Alltrim(xFilial("SA6")))
nTamFSE8 := Len(Alltrim(xFilial("SE8")))

If nTamFSE8 > nTamFSA6
	nTamFil	:= nTamFSA6
Else
	nTamFil	:= nTamFSE8
EndIf

cFilSE8		:= Substr(cFilAnt,1,nTamFil)
cFilSE8De	:= Substr(cFilDe,1,nTamFil)
cFilSE8Ate	:= Substr(cFilAte,1,nTamFil)

cQrySA6 := "SELECT SA6.A6_FILIAL, SA6.A6_FLUXCAI, SA6.A6_COD, SA6.A6_AGENCIA, SA6.A6_NUMCON, SA6.A6_NREDUZ, SA6.A6_MOEDA, SA6.A6_LIMCRED " 
cQrySA6 += "FROM " + RetSqlName("SA6") + " SA6 "
cQrySA6 += " WHERE "
If nTamFSA6 > 0
	If lFiliais 
		cQrySA6 += " SA6.A6_FILIAL " + FinSelFil( aSelFil, "SA6", .F., .F.) + " "
	ElseIf lConsFil .and. !lFiliais
		cQrySA6 += " SA6.A6_FILIAL >= '" + xFilial("SA6",cFilDe) + "' "
		cQrySA6 += " AND SA6.A6_FILIAL <= '" + xFilial("SA6",cFilAte) + "' "
	Else 	
		cQrySA6 += " SA6.A6_FILIAL = '" + xFilial("SA6") + "' "
	EndIf 
Else
	cQrySA6 += " SA6.A6_FILIAL = '" + xFilial("SA6") + "' "
EndIf
cQrySA6 += " AND (SA6.A6_FLUXCAI = 'S' OR SA6.A6_FLUXCAI = ' ') "
cQrySA6 += " AND SA6.D_E_L_E_T_ = ' ' " 
cQrySA6 += " ORDER BY SA6.A6_COD, SA6.A6_AGENCIA, SA6.A6_NUMCON " 

cQrySA6 := ChangeQuery(cQrySA6)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQrySA6), cAliasSA6, .T., .T. )

While (cAliasSA6)->(!Eof())



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica banco a banco a disponibilidade imediata				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTrbBanco  := (cAliasSA6)->A6_COD
	cTrbAgencia:= (cAliasSA6)->A6_AGENCIA
	cTrbConta  := (cAliasSA6)->A6_NUMCON
	cTrbNome   := (cAliasSA6)->A6_NREDUZ
	nMoedaBco  := Max((cAliasSA6)->A6_MOEDA,1)
	lSldBco := .F.
	
	If cContaAnt != cTrbBanco + cTrbAgencia + cTrbConta
		cContaAnt := cTrbBanco + cTrbAgencia + cTrbConta
	Else
		(cAliasSA6)->(DBSkip())	
		Loop
	EndIf	

	If oSE8Qry == NIL
		cQuery := "SELECT SE8.E8_FILIAL, SE8.E8_DTSALAT, SE8.E8_SALRECO, SE8.E8_SALATUA "
		cQuery += "FROM " + RetSqlName("SE8") + " SE8 "
		cQuery += "WHERE "
		If nTamFSE8 > 0 // SE SE8 for exclusiva em qualquer MODO
			If nTamFil > 0 // SE SE8 ou SA6 for exclusiva em qualquer MODO
				If lFiliais 
					cQuery += " SUBSTRING(SE8.E8_FILIAL,1, " + Str(nTamFil) + ") " + F21BcoFil( aSelFil, nTamFil) + " AND "
				ElseIf lConsFil .and. !lFiliais
					cQuery += " SUBSTRING(SE8.E8_FILIAL,1," + Str(nTamFil) + ")  >= '" + cFilSE8De + "' "
					cQuery += " AND SUBSTRING(SE8.E8_FILIAL,1," + Str(nTamFil) + ")  <= '" + cFilSE8Ate + "' AND  "
				Else
					cQuery += " SUBSTRING(SE8.E8_FILIAL,1," + Str(nTamFil) + ") = '" + cFilSE8 + "' AND "
				EndIf
			EndIf
		Else
			// SE8 compartilhada, pega todos os registros da SE8
			cQuery += " SE8.E8_FILIAL = '" + xFilial("SE8") + "' AND "
		EndIf
		cQuery += "SE8.E8_BANCO = ? AND " 
		cQuery += "SE8.E8_AGENCIA = ? AND "
		cQuery += "SE8.E8_CONTA = ? AND "
		cQuery += "SE8.D_E_L_E_T_ = ' ' AND "
		cQuery += "SE8.E8_DTSALAT = ( SELECT MAX(TMP.E8_DTSALAT) "
		cQuery += "FROM " + RetSqlName("SE8") + " TMP "
		cQuery += "WHERE "
		cQuery += "TMP.E8_FILIAL = SE8.E8_FILIAL AND "
		cQuery += "TMP.E8_BANCO = SE8.E8_BANCO AND "
		cQuery += "TMP.E8_AGENCIA = SE8.E8_AGENCIA AND "
		cQuery += "TMP.E8_CONTA = SE8.E8_CONTA AND "
		cQuery += "TMP.E8_DTSALAT <= ? AND "
		cQuery += "TMP.D_E_L_E_T_ = ' ') "
		cQuery += "ORDER BY E8_FILIAL,E8_BANCO,E8_AGENCIA,E8_CONTA,E8_DTSALAT "

		cQuery := ChangeQuery(cQuery)
		oSE8Qry := FWPreparedStatement():New(cQuery)

	EndIf

	oSE8Qry:SetString(1, (cAliasSA6)->A6_COD)
	oSE8Qry:SetString(2, (cAliasSA6)->A6_AGENCIA)
	oSE8Qry:SetString(3, (cAliasSA6)->A6_NUMCON)
	oSE8Qry:SetDate(4, dDataBase)

	cQuery := oSE8Qry:GetFixQuery()
	cAliasSE8 := MpSysOpenQuery(cQuery)				
	nTrbSaldo := 0

	While (cAliasSE8)->(!Eof())	
		lSldBco := .T.

		If nMoedaBco != nMoeda
			If Left(cTipoSaldo,1)=="1" // Somente saldo normal
				nTrbSaldo += xMoeda((cAliasSE8)->E8_SALATUA,nMoedaBco,nMoeda)
			ElseIf Left(cTipoSaldo,1)=="2" // Somente os conciliados
				nTrbSaldo += xMoeda((cAliasSE8)->E8_SALRECO,nMoedaBco,nMoeda)
			Elseif Left(cTipoSaldo,1)=="3" // Nao conciliados
				nTrbSaldo += xMoeda((cAliasSE8)->E8_SALATUA-(cAliasSE8)->E8_SALRECO,nMoedaBco,nMoeda)
			Endif
		Else
			If Left(cTipoSaldo,1)=="1" // Somente saldo normal
				nTrbSaldo += (cAliasSE8)->E8_SALATUA
			ElseIf Left(cTipoSaldo,1)=="2" // Somente os conciliados
				nTrbSaldo += (cAliasSE8)->E8_SALRECO
			Elseif Left(cTipoSaldo,1)=="3" // Nao conciliados
				nTrbSaldo += (cAliasSE8)->E8_SALATUA-(cAliasSE8)->E8_SALRECO
			Endif
		EndIf

		(cAliasSE8)->(DbSkip())
	EndDo

	(cAliasSE8)->(DbCloseArea())
	If lSldBco
		Aadd(aRet,{.F.,cTrbBanco,cTrbAgencia,cTrbConta,cTrbNome,Transform(nTrbSaldo,cPicture),nMoeda,Transform(xMoeda((cAliasSA6)->A6_LIMCRED,nMoedaBco,nMoeda),cPicture)})
	EndIf
	(cAliasSA6)->(dbSkip())
	
EndDo

(cAliasSA6)->(DbCloseArea())


If oSE8Qry != Nil
	oSE8Qry:Destroy()
	oSE8Qry := Nil
Endif

aRetorno := AClone(aRet)

cFilAnt := cSavFil

SA6->(RestArea(aAreaSa6))
SE8->(RestArea(aAreaSe8))
RestArea(aArea)

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Bancos    ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe os bancos para selecao dos saldos                    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ nBancos     -> Saldo em bancos (por referencia)            º±±
±±º          ³ nCaixas     -> Saldo em caixas (por referencia)            º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Bancos( lConsFil, nMoeda, nBancos, nCaixas, cFilDe, cFilAte, cTipoSaldo, lRecalcula, aBancos, lLimCred, nSldBco, lZeraSld, lFiliais, cEmpresa)
Local oDlgBanc
Local oOk			:= LoadBitmap( GetResources(), "LBOK" )
Local oNo			:= LoadBitmap( GetResources(), "LBNO" )
Local cBancoCx		:= GetMV("MV_CARTEIR")
Local oGet01
Local lInverter
Local oGet02
Local aRet
Local aVerBco
Local nI			:=	0

Default lLimCred	:= .T.
Default nSldBco		:= 1
Default lZeraSld	:= .F.
Default lFiliais	:= .F.

aRet := GetBancos( lConsFil, nMoeda, cFilDe, cFilAte, cTipoSaldo, lRecalcula, aBancos, lZeraSld, nSldBco, lFiliais, cEmpresa)

If Len(aRet) == 0
	IW_MSGBOX(STR0059,STR0198,"STOP") //"Nao existem saldos bancarios"
Else
	ASort(aRet,,, { |x,y| x[2]+x[3]+x[4] < y[2]+y[3]+y[4] } ) // Ordena pelo codigo do banco

	DEFINE MSDIALOG oDlgBanc TITLE STR0060 From 5,5 To 20,84 OF oMainWnd //"Selecione os bancos"
	@	 .8, .5 LISTBOX oBancos FIELDS HEADER "",STR0061,STR0062,STR0063,STR0064,STR0065,STR0203 FIELDSIZES 14,25,31,31,60,40,40 SIZE 270, 100 OF oDlgBanc //"Banco"###"Agencia"###"Conta"###"Nome"###"Saldo"
	@   .6,  4 CHECKBOX oGet01 VAR lInverter PROMPT STR0066 FONT oDlgBanc:oFont PIXEL OF oDlgBanc SIZE 50,9 ON CLICK (oGet01:cCaption := If( lInverter, STR0067, STR0068)+STR0069, oGet01:Refresh(), aEval(aRet, {|e| e[1] := lInverter}), oBancos:Refresh()) //"Marcar todos"###"Desmarcar"###"Marcar"###" todos"
	@   .6, 115 CHECKBOX oGet02 VAR lLimCred PROMPT STR0228 FONT oDlgBanc:oFont PIXEL OF oDlgBanc SIZE 50,9 // "Considera Limite de Crédito"

	oBancos:SetArray(aRet)
	oBancos:bLine      := {|| {If(aRet[oBancos:nAt,1],oOk,oNo),;
										    aRet[oBancos:nAt,2],;
				  						    aRet[oBancos:nAt,3],;
										    aRet[oBancos:nAt,4],;
										    aRet[oBancos:nAt,5],;
							   			 aRet[oBancos:nAt,6],;
										    aRet[oBancos:nAt,8]}}

	oBancos:bLDblClick := {|| aRet[oBancos:nAt][1] := !aRet[oBancos:nAt][1], oBancos:DrawSelect()}
	DEFINE SBUTTON FROM 10, 280 TYPE 1 ACTION oDlgBanc:End() ENABLE OF oDlgBanc
	ACTIVATE MSDIALOG oDlgBanc

	aVerBco	:= {}
	For nI =1 to Len(aRet)
		If aRet[nI,1] = .T.
			Aadd(aVerBco,aRet[nI])
		Endif
	Next

	aRet	:=	aClone(aVerBco)

	// Calcula o saldo em Bancos/Caixas
	aEval( aRet, { |e| If( e[1], If( Left(e[2],2)=="CX" .Or. Left(e[2],3) $ cBancoCx,;
										nCaixas +=	Fc021Val(e[6]),;
									  	nBancos +=	Fc021Val(e[6])),Nil)})
Endif

lFirst := .T.

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021ComisºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera dados no arquivo temporario, a partir do arquivo de   º±±
±±º          ³ comissoes																  º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ dUltData   -> Ultima data do periodo                       º±±
±±º          ³ lConsFil   -> Considera filiais                            º±±
±±º          ³ cFilDe     -> Filial inicial                               º±±
±±º          ³ cFilAte    -> Filial final                                 º±±
±±º          ³ aFluxo     -> Matriz que contera os dados do fluxo         º±±
±±º          ³ nMoeda     -> Codigo da Moeda                              º±±
±±º          ³ lAnalitico -> Gera dados analiticos                        º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[1] =                                                  º±±
±±º          ³ cArqAnaCo -> Nome do arquivo analitico                     º±±
±±º          ³ cAliasCo  -> Alias do arquivo analitico                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Comis( dUltData, lConsFil, cFilDe, cFilAte, aFluxo, nMoeda, lAnalitico, aTotais, aPeriodo, lFiliais )
Local cAliasCo
Local cArqAnaCo
Local aCposAna
Local aCposSin
Local cAliasTrb
Local nSaldoTit
Local dDataTrab
Local nAscan
Local cQuery
Local aStru

// Analitico
If lAnalitico
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C", Iif( Len( DtoC(dDataBase) ) > 8, 23, 20 ), 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "FILIAL"  , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3("E3_FILIAL")[1] ), 0 } )
	Aadd( aCposAna, { "PREFIXO" , "C", TamSx3("E3_PREFIXO")[1], 0 } )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("E3_NUM")[1], 0 } )
	Aadd( aCposAna, { "PARCELA" , "C", TamSx3("E3_PARCELA")[1], 0 } )
	Aadd( aCposAna, { "VEND"    , "C", TamSx3("E3_VEND")[1], 0 } )
	Aadd( aCposAna, { "NOMEVEND", "C", TamSx3("A3_NOME")[1], 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					             TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )

	cAliasCo := "cArqAnaCo"  // Alias do arquivo analitico

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera tabela temporária        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If _oFINC0213 <> Nil
		_oFINC0213:Delete()
		_oFINC0213 := Nil
	Endif

	_oFINC0213 := FWTemporaryTable():New( cAliasCo )
	_oFINC0213:SetFields(aCposAna)
	_oFINC0213:AddIndex("1", {"DATAX"})

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC0213:Create()

Endif

aCposSin:={{"DATAX"   , "D" , 08, 0},;
		    	{"ENTR"    , "N" , 17, 2},;
			 	{"SAID"    , "N" , 17, 2},;
			 	{"SALDO"   , "N" , 17, 2},;
			 	{"ENTRAC"  , "N" , 17, 2},;
			 	{"SAIDAC"  , "N" , 17, 2},;
			 	{"SALDOAC" , "N" , 17, 2},;
			 	{"VARIACAO", "N" ,  9, 2},;
			 	{"VARIACAC", "N" ,  9, 2},;
			 	{"FLAG"    , "L" ,  1, 0 }}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConsFil
   cFilDe  := xFilial("SE3")
   cFilAte := xFilial("SE3")
EndIf

aStru     := SE3->(dbStruct())
cAliasTrb := "FINC021"

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("SE3") + " SE3 "
cQuery += "WHERE "

If lFiliais //Seleciona Filiais
	cQuery += "SE3.E3_FILIAL IN (" + cLisFil + ") AND "
Else
	cQuery += "SE3.E3_FILIAL >= '" + cFilDe + "' AND "
	cQuery += "SE3.E3_FILIAL <= '" + cFilAte + "' AND "
EndIf

cQuery += "SE3.E3_VENCTO >= '" + Dtos( dDataBase ) + "' AND "
cQuery += "SE3.E3_VENCTO <= '" + Dtos( dUltData ) + "' AND "
cQuery += "SE3.E3_DATA = ' ' AND "
cQuery += "SE3.D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasTrb, .T., .T. )
aEval( aStru, {|e| If(e[2]!= "C", TCSetField( cAliasTrb, e[1], e[2], e[3], e[4] ), Nil ) } )

While (cAliasTrb)->( !Eof() ) //IndRegua
	IncProc(STR0087) //"Processando Comissäes"
	dDataTrab := DataValida((cAliasTrb)->E3_VENCTO,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a data de vencto. nao ultrapassar a ultima data do relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dDataTrab <= dUltData
		nSaldoTit := xMoeda((cAliasTrb)->E3_COMIS,1,nMoeda)
		If Abs(nSaldoTit) > 0.0001
			// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
			nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
			// Verifica se esta no periodo solicitado
			If nAscan > 0
				aFluxo[nAscan][SAIDAS] += nSaldoTit
			Endif
			If lAnalitico .And. nAscan > 0
				RecLock(cAliasCo,.T.)
				(cAliasCo)->Datax	:= dDataTrab
				(cAliasCo)->Periodo	:= aPeriodo[nAscan][2]
				(cAliasCo)->FILIAL	:= (cAliasTrb)->E3_FILIAL
				(cAliasCo)->PREFIXO	:= (cAliasTrb)->E3_PREFIXO
				(cAliasCo)->NUMERO	:= (cAliasTrb)->E3_NUM
				(cAliasCo)->PARCELA	:= (cAliasTrb)->E3_PARCELA
				(cAliasCo)->VEND		:= (cAliasTrb)->E3_VEND
				DbSelectArea("SA3")
				dbSetOrder(1)
				MsSeek(xFilial("SA3")+(cAliasTrb)->E3_VEND)
				DbSelectArea(cAliasTrb)
				(cAliasCo)->NOMEVEND:= SA3->A3_NOME
				cIdentific :=	xFilial("SE3")+;
								   (cAliasTrb)->E3_PREFIXO +;
								   (cAliasTrb)->E3_NUM     +;
								   (cAliasTrb)->E3_PARCELA +;
								   (cAliasTrb)->E3_SEQ
				(cAliasCo)->Chave     := cIdentific
				(cAliasCo)->SALDO     := nSaldoTit
				(cAliasCo)->Apelido   := "SE3"
				MsUnlock()
				// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
				// da data de trabalho.
				nAscan := Ascan( aTotais[5], {|e| e[1] == dDataTrab})
				If nAscan == 0
					Aadd( aTotais[5], {dDataTrab,nSaldoTit})
				Else
					aTotais[5][nAscan][2] += nSaldoTit // Contabiliza os totais de comissões
				Endif
			Endif
		EndIf
	Endif
	(cAliasTrb)->(dbSkip())
EndDo

dbSelectArea(cAliasTrb)
dbCloseArea()
dbSelectArea("SE3")

Return { ,, cArqAnaCo, cAliasCo }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021VenciºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula os titulos vencidos do SE1/SE2                     º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cAlias   -> Alias do arquivo de titulos SE1 ou SE2         º±±
±±º          ³ lConsFil -> Considera filiais                              º±±
±±º          ³ cFilDe   -> Filial inicial                                 º±±
±±º          ³ cFilAte  -> Filial final                                   º±±
±±º          ³ nMoeda   -> Codigo da moeda                                º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ nRet -> Valor total dos titulos vencidos                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Vencidos(cAlias, lConsFil, cFilDe, cFilAte,nMoeda,cFilterUser,lSeekVA,cTempVA)
Local nRet			:= 0
Local cAliasTmp		:= ""
Local cAliasTrb		:= ""
Local cCampo		:= Right(cAlias,2)
Local nOrdem		:= If( cAlias == "SE1", 7, 3 )
Local nSaldo		:= 0
Local aArea			:= GetArea()
Local aArea1		:= (cAlias)->(GetArea())
Local lFc021Fil		:= ExistBlock("FC021FIL")
Local cListDesc		:= FN022LSTCB(2)	//Obtem a lista de situacos de cobranca que nao possuem portador (Carteira)
Local lFValAcess	:= ExistFunc('FValAcess')
Local cQuery	:= ""

DEFAULT cFilterUser	:= ""
Default lSeekVA		:= .F.
Default cTempVA		:= ""

DbSelectArea(cAlias)
DbSetOrder(nOrdem)

If !lConsFil
   cFilDe  := xFilial(cAlias)
   cFilAte := xFilial(cAlias)
Endif

cAliasTmp := "cArqTmp" // Alias do arquivo

aStru     := (cAlias)->(dbStruct())
cAliasTrb := "VENCIDOS"

If cAlias == "SE3" // Comissoes
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SE3")+ " SE3 "
	cQuery += "WHERE "
	cQuery += "SE3.E3_FILIAL>='"+cFilDe+"' AND "
	cQuery += "SE3.E3_FILIAL<='"+cFilAte+"' AND "
	cQuery += "SE3.E3_VENCTO <= '"+Dtos(dDataBase-1)+"' AND "
	cQuery += "SE3.E3_DATA = ' ' AND "
	cQuery += "SE3.D_E_L_E_T_=' ' "
Else
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName(cAlias) + " " + cAlias + " "
	cQuery += "WHERE "
	cQuery += cAlias + "." + cCampo + "_FILIAL>='"+cFilDe+"' AND "
	cQuery += cAlias + "." + cCampo + "_FILIAL<='"+cFilAte+"' AND "
	cQuery += cAlias + "." + cCampo + "_VENCREA <= '"+Dtos(dDataBase-1)+"' AND "
	cQuery += cAlias + "." + cCampo + "_SALDO > 0 AND "
	cQuery += cAlias + "." + cCampo + "_FLUXO <> 'N' AND "
	If cAlias == "SE1"
		cQuery += cAlias + "." + cCampo + "_SITUACA NOT IN  " + FormatIn(cListDesc,"|") + " AND "
	Endif
	cQuery += cAlias + ".D_E_L_E_T_=' ' "
Endif

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})

While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc(STR0074 + If(cAlias=="SE1", STR0056,STR0057)) //"Processando titulos vencidos a "###"Receber"###"Pagar"

	If lFc021Fil
		cFilterUser := ExecBlock("FC021FIL", .F., .F., {cAlias} )
	EndIf

	If cAlias == "SE3"
		nRet += xMoeda((cAliasTrb)->E3_COMIS,1,nMoeda)
	Else
		// Se nao existir filtro de usuario, ou se o filtro retornar uma expressao
		// valida para o registro atual do titulo, entao processsa o registro.

		If	(Empty(cFilterUser) .Or. (&cFilterUser))
			nSaldo:=xMoeda((cAliasTrb)->&(cCampo+"_SALDO")+;
								((cAliasTrb)->&(cCampo+"_SDACRES")-;
								(cAliasTrb)->&(cCampo+"_SDDECRE")),;
								(cAliasTrb)->&(cCampo+"_MOEDA")  ,;
								nMoeda,,,;
								If(cPaisLoc=="BRA",(cAliasTrb)->&(cCampo+"_TXMOEDA"),0))

			If cPaisLoc <> "BRA"
				If (cAliasTrb)->&(cCampo+"_TIPO") $ MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM+"/"+MVRECANT+"/"+MVPAGANT
					nRet -= nSaldo
				Else
					nRet += nSaldo
					If lFValAcess .AND. lSeekVA						
						If (cCampo == "E1")
							If ( cTempVA )->( DbSeek((cAliasTrb)->(	E1_FILIAL	+ '|' + ;
																	E1_PREFIXO	+ '|' + ;
																	E1_NUM		+ '|' + ;
																	E1_PARCELA	+ '|' + ;
																	E1_TIPO		+ '|' + ;
																	E1_CLIENTE	+ '|' + ;
																	E1_LOJA		) ) )						
								SE1->(DbGoTo((cAliasTrb)->R_E_C_N_O_))
								nRet += (cAliasTrb)->(FValAcess(E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NATUREZ, !Empty(E1_BAIXA), "", "R", E1_BAIXA))
							EndIf
						ElseIf (cCampo == "E2")
							If ( cTempVA )->( DbSeek((cAliasTrb)->(	E2_FILIAL	+ '|' + ;
																	E2_PREFIXO	+ '|' + ;
																	E2_NUM		+ '|' + ;
																	E2_PARCELA	+ '|' + ;
																	E2_TIPO		+ '|' + ;
																	E2_FORNECE	+ '|' + ;
																	E2_LOJA		) ) )												
								SE2->(DbGoTo((cAliasTrb)->R_E_C_N_O_))
								nRet += (cAliasTrb)->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, !Empty(E2_BAIXA), "", "P", E2_BAIXA))
							EndIf
						EndIf
					EndIf
				EndIf
			ElseIf !(cAliasTrb)->&(cCampo+"_TIPO") $ MVRECANT+MVPAGANT
				If (cAliasTrb)->&(cCampo+"_TIPO") $ MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM
					nRet -= nSaldo
				Else
					nRet += nSaldo
					If lFValAcess .AND. lSeekVA
						If (cCampo == "E1")
							If ( cTempVA )->( DbSeek((cAliasTrb)->(	E1_FILIAL	+ '|' + ;
																	E1_PREFIXO	+ '|' + ;
																	E1_NUM		+ '|' + ;
																	E1_PARCELA	+ '|' + ;
																	E1_TIPO		+ '|' + ;
																	E1_CLIENTE	+ '|' + ;
																	E1_LOJA		) ) )						
								SE1->(DbGoTo((cAliasTrb)->R_E_C_N_O_))
								nRet += (cAliasTrb)->(FValAcess(E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NATUREZ, !Empty(E1_BAIXA), "", "R", E1_BAIXA))
							EndIf
						ElseIf (cCampo == "E2")
							If ( cTempVA )->( DbSeek((cAliasTrb)->(	E2_FILIAL	+ '|' + ;
																	E2_PREFIXO	+ '|' + ;
																	E2_NUM		+ '|' + ;
																	E2_PARCELA	+ '|' + ;
																	E2_TIPO		+ '|' + ;
																	E2_FORNECE	+ '|' + ;
																	E2_LOJA		) ) )												
								SE2->(DbGoTo((cAliasTrb)->R_E_C_N_O_))
								nRet += (cAliasTrb)->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, !Empty(E2_BAIXA), "", "P", E2_BAIXA))
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasTrb)->(dbSkip())
EndDo

dbSelectArea(cAliasTrb)
dbCloseArea()
dbSelectArea(cAlias)

RestArea(aArea)
(cAlias)->(RestArea(aArea1))

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³FluxoAna  ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe o fluxo analitico, ou seja, os dados que compem os   º±±
±±º          ³ valores do fluxo sintetico                                 º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cArqAnaP   -> Nome do arquivo temporario CP                º±±
±±º          ³ cAliasP    -> Alias do arquivo temporario CP               º±±
±±º          ³ cArqAnaR   -> Nome do arquivo temporario CR                º±±
±±º          ³ cAliasR    -> Alias do arquivo temporario CR               º±±
±±º          ³ cAliasPc   -> Alias do arquivo temporario Pedido de compra º±±
±±º          ³ cAliasPv   -> Alias do arquivo temporario Pedido de Venda  º±±
±±º          ³ cAliasEmp  -> Alias do arquivo temporario Emprestimos      º±±
±±º          ³ cAliasCo   -> Alias do arquivo temporario Comissões        º±±
±±º          ³ dData      -> Data a exibir                                º±±
±±º          ³ aTotais    -> Matriz de totais por folder/data             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION FluxoAna(cAliasP,cAliasR,cAliasPc,cAliasPv,cAliasCo,cAliasEmp,;
								 cAliasApl,cAliasCtrc,cPeriodo,aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,;
								 nAtrPagar,aPeriodo,cAliasChq,oFluxo,nLimCred,cAliasSol,;
								 cAliasDMSCompra,cAliasDMSVenda)
Local aArea    := GetArea(),;
		aOldHeader	:= aClone(aHeader),;
		aOldaCols	:= aClone(aCols),;
		aOldaRotina	:= aClone(aRotina),;
		oGetDb1 ,;
		oGetDb2 ,;
		oGetDb3 ,;
		oGetDb4 ,;
		oGetDb5 ,;
		oGetDb6 ,;
		oGetDb7 ,;
		oGetDb8 ,;
		oGetDb9 ,;
		oGetDb10,;
		oGetDb11,;
		oGetDb12,;
		oFolder ,;
		aHeader1,;
		aHeader2,;
		aHeader3,;
		aHeader4,;
		aHeader5,;
		aHeader6,;
		aHeader7,;
		aHeader8,;
		aHeader9,;
		aHeader10,;
		aHeader11,;
		aHeader12,;
		nAscan  ,;
		oSayTotal,;
		oGetTotal,;
		nTotal := 0
LOCAL oDlg,oBold, aGetDb, aAlias
LOCAL aSize, aObjects := {}, aInfo, aPosObj
LOCAL cFiltro := "Alltrim(Periodo)=='"+Alltrim(Transform(cPeriodo,""))+"'" // Filtro para a GetDb
Local nX := 0
Local aUsButtons
Local aButton := {	{"SIMULACAO",	{|| If(ValType(aGetDb[oFolder:nOption])=="O" .And. !Empty((aAlias[oFolder:nOption])->DataX),(Fc021Proj(oDlg,aFluxo,aAlias,oFolder,aGetDb,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,@nTotal,aPeriodo,nLimCred),aGetDb[oFolder:nOption]:oBrowse:Refresh()), .T.) }, STR0171},;
						 	{"BMPVISUAL",	{|| If(ValType(oFolder:aDialogs[oFolder:nOption])=="O"  .And.;
														 ValType(oFolder:aDialogs[oFolder:nOption]:Cargo) == "A" .And.;
											    		 ValType(oFolder:aDialogs[oFolder:nOption]:Cargo[2]) == "B", Eval(oFolder:aDialogs[oFolder:nOption]:Cargo[2]), .T.)},STR0172}}

Local lPanelFin := IsPanelFin()
Local lFC021HDPV := ExistBlock("FC021HDPV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicionar botoes do usuario na EnchoiceBar       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "FC021BUT" )
	aUsButtons := ExecBlock( "FC021BUT", .F., .F.)
	AEval( aUsButtons, { |x| AAdd( aButton, x ) } )
EndIf


DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
aSize := MsAdvSize()
aadd( aObjects, { 100, 100, .T., .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE OemToAnsi(STR0075 + cPeriodo) PIXEL of oMainWnd //"Detalhes do Dia" //"Detalhes do dia "
oDlg:lMaximized := .T.

oPanel := TPanel():New(aPosObj[1,1]-5,aPosObj[1,2],'',oDlg,, .T., .T.,, ,aPosObj[1,3],aPosObj[1,4])

oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
If !lPanelFin
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
Endif

@ aPosObj[1,1]-30,aPosObj[1,2] FOLDER oFolder SIZE aPosObj[1,3],aPosObj[1,4] OF oPanel PROMPTS STR0035,STR0036,STR0011,STR0010,STR0009,STR0076,STR0077,STR0195, "Doctos. de Transporte",STR0246, STR0280 ,STR0281 PIXEL //"A Pagar"###"A Receber"###"Pedido de Compra"###"Pedido de Venda"###"Comissões"###"Emprestimos"###"Aplicações"###"Cheques pendentes"###"Doctos. de Transporte"###"Solicitações de Fundo"###"Ped. Compra de Máquinas"###"Ped. Venda de Máquinas"
oFolder:bSetOption:={|nAtu| Fc021ChFol(nAtu,oFolder:nOption,oFolder,oPanel,aTotais,oSayTotal,oGetTotal, @nTotal,cPeriodo,aGetDb, aAlias,aHeader1,aHeader2,aHeader3,aHeader4,aHeader5,aHeader6,aHeader7,aHeader8,aHeader9,aHeader10,aHeader11,aHeader12)}

nAscan := Ascan( aTotais[oFolder:nOption], {|e|Transform(e[1],"") = cPeriodo})
If nAscan > 0
	nTotal := aTotais[oFolder:nOption][nAscan][2]
Endif

@ 03,010   SAY oSayTotal VAR STR0078 PIXEL OF oPanel2 FONT oBold //"Total de titulos a Pagar"
@ 03,100 MSGET oGetTotal VAR nTotal PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oPanel2 SIZE 65,10 FONT oBold

If cAliasP != Nil .And. Select(cAliasP) > 0
	DbSelectArea(cAliasP)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0200, "Filial"   , "", Len((cAliasP)->Filial), 0, ".F.", USADO, "C",, "V" } ) //"Filial"
	Aadd( aHeader, { STR0079, "Prefixo"   , "", Len((cAliasP)->Prefixo), 0, ".F.", USADO, "C",, "V" } ) //"Prefixo"
	Aadd( aHeader, { STR0080, "Num"       , "", Len((cAliasP)->Num)    , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0081, "Parcela"   , "", Len((cAliasP)->Parcela), 0, ".F.", USADO, "C",, "V" } ) //"Parc"
	Aadd( aHeader, { STR0082, "Tipo"      , "", Len((cAliasP)->Tipo)   , 0, ".F.", USADO, "C",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0083, "CliFor"    , "", Len((cAliasP)->CliFor) , 0, ".F.", USADO, "C",, "V" } ) //"Fornecedor"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasP)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0084, "Loja"      , "", Len((cAliasP)->Loja)   , 0, ".F.", USADO, "C",, "V" } ) //"Loja"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
   // Ponto entrada para incluir novas colunas no aHeader
	If ExistBlock("FC021HEAD")
		aHdNew := ExecBlock("FC021HEAD",.F.,.F.,{aHeader})
		For nX := 1 to len(aHdNew)
 			aAdd(aHeader,aHdNew[nX])
	 	Next
	EndIf
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader1 := aClone(aHeader)
	oGetDb1 := (cAliasP)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasP,"AllwaysTrue",,,oFolder:aDialogs[1],.F.,.T.))
	oGetDb1:oBrowse:lHScroll := .F.
	oGetDb1:oBrowse:lDisablePaint := .T.

	oFolder:aDialogs[1]:Cargo := {"P",{||Fc021Visual("SE2",(cAliasP)->Chave,STR0085)}} //"Contas a Pagar"
Endif
If cAliasR != Nil .And. Select(cAliasR) > 0
	DbSelectArea(cAliasR)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0200, "Filial"    , "", Len((cAliasR)->Filial), 0, ".F.", USADO, "C",, "V" } ) //"Filial"
	Aadd( aHeader, { STR0079, "Prefixo"   , "", Len((cAliasR)->Prefixo), 0, ".F.", USADO, "C",, "V" } ) //"Prefixo"
	Aadd( aHeader, { STR0080, "Num"       , "", Len((cAliasR)->Num)    , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0081, "Parcela"   , "", Len((cAliasR)->Parcela), 0, ".F.", USADO, "C",, "V" } ) //"Parc"
	Aadd( aHeader, { STR0082, "Tipo"      , "", Len((cAliasR)->Tipo)   , 0, ".F.", USADO, "C",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0088, "CliFor"    , "", Len((cAliasR)->CliFor) , 0, ".F.", USADO, "C",, "V" } ) //"Cliente"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasR)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0084, "Loja"      , "", Len((cAliasR)->Loja)   , 0, ".F.", USADO, "C",, "V" } ) //"Loja"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	// Se o campo de situacao existir no arquivo temporario.
	If (cAliasR)->(FieldPos("Situacao")) > 0
		Aadd( aHeader, { "Situacao", "Situacao", "", Len((cAliasR)->Situacao), 0, ".F.", USADO, "C",, "V" } ) // "Situacao"
	Endif
	If (cAliasR)->(FieldPos("Portado")) > 0
		Aadd( aHeader, { STR0061 ,"Portado"	, "", Len((cAliasR)->Portado) ,0 , ".F.", USADO, "C",, "V"} )
	EndIf
	If (cAliasR)->(FieldPos("AgeDep")) > 0
		Aadd( aHeader, { STR0062 ,"AgeDep"	, "", Len((cAliasR)->AgeDep)  ,0 , ".F.", USADO, "C",, "V"} )
	EndIf
	If (cAliasR)->(FieldPos("AgeDep")) > 0
		Aadd( aHeader, { STR0063 ,"Conta"	, "", Len((cAliasR)->Conta)   ,0 , ".F.", USADO, "C",, "V"} )
	EndIf
	   // Ponto entrada para incluir novas colunas no aHeader
	If ExistBlock("FC021HEAD")
		aHdNew := ExecBlock("FC021HEAD",.F.,.F.,{aHeader})
		For nX := 1 to len(aHdNew)
 			aAdd(aHeader,aHdNew[nX])
	 	Next
	EndIf
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader2 := aClone(aHeader)
	oGetDb2 := (cAliasR)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasR,"AllwaysTrue",,,oFolder:aDialogs[2],.F.,.T.))
	oGetDb2:oBrowse:lHScroll := .F.
	oGetDb2:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[2]:Cargo := {"R",{||Fc021Visual("SE1",(cAliasR)->Chave,STR0089)}} //"Contas a Receber"
Endif
If cAliasPc != Nil .And. Select(cAliasPc) > 0
	DbSelectArea(cAliasPc)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	If lSC7Exclus
		Aadd(aHeader, {STR0200, "Filial", "", Len((cAliasPc)->FILIAL), 0, ".F.", USADO, "C",, "V"}) //"Filial"
	EndIf
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasPc)->numero)   , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0090, "Emissao"   , "",              8, 0, ".F.", USADO, "D",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0083, "Clifor"    , "", Len((cAliasPc)->CliFor)   , 0, ".F.", USADO, "C",, "V" } ) //"Fornecedor"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasPc)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0082, "Tipo"      , "", TamSx3("C7_TIPO")[1], 0, ".F.", USADO, "N",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0091, "Item"      , "", Len((cAliasPc)->Item)     , 0, ".F.", USADO, "C",, "V" } ) //"Item"
	Aadd( aHeader, { STR0092, "Produto"   , "", Len((cAliasPc)->Produto)  , 0, ".F.", USADO, "C",, "V" } ) //"Produto"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { STR0264, "ValPagAnt", "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor do Adiantamento"

	// Ponto entrada para incluir novas colunas no aHeader
	If ExistBlock( "FC021HDPC" )
		aHdNew := ExecBlock( "FC021HDPC", .F., .F., { aHeader } )
		For nX := 1 to Len( aHdNew )
 			aAdd( aHeader, aHdNew[ nX ] )
	 	Next
	EndIf

	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader3 := aClone(aHeader)
	oGetDb3 := (cAliasPc)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasPc,"AllwaysTrue",,,oFolder:aDialogs[3],.F.,.T.))
	oGetDb3:oBrowse:lHScroll := .F.
	oGetDb3:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[3]:Cargo := {"P",{||Fc021Visual("SC7",(cAliasPc)->Chave,STR0093)}} //"Pedidos de Compras"
Endif
If cAliasPv != Nil .And. Select(cAliasPv) > 0
	DbSelectArea(cAliasPv)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasPv)->Numero) , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0082, "Tipo"      , "", Len((cAliasPv)->Tipo)   , 0, ".F.", USADO, "C",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0090, "Emissao"   , "",  			  8, 0, ".F.", USADO, "C",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0088, "CliFor"    , "", Len((cAliasPv)->CliFor) , 0, ".F.", USADO, "C",, "V" } ) //"Cliente"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasPv)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0094, "LojaCli" , "", Len((cAliasPv)->LojaCli) , 0, ".F.", USADO, "C",, "V" } ) //"Loja Cliente"
	Aadd( aHeader, { STR0095, "LojaEnt" , "", Len((cAliasPv)->LojaEnt) , 0, ".F.", USADO, "C",, "V" } ) //"Loja Entrega"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { STR0264, "ValRecAnt", "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor do Adiantamento"

	If lFC021HDPV
		aHdNew := ExecBlock( "FC021HDPV", .F., .F., { aHeader } )
		For nX := 1 to Len( aHdNew )
 			aAdd( aHeader, aHdNew[ nX ] )
	 	Next
	EndIf

	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader4 := aClone(aHeader)
	oGetDb4 := (cAliasPv)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasPv,"AllwaysTrue",,,oFolder:aDialogs[4],.F.,.T.))
	oGetDb4:oBrowse:lHScroll := .F.
	oGetDb4:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[4]:Cargo := {"R",{||Fc021Visual("SC5",(cAliasPv)->Chave,STR0096)}} //"Pedidos de Venda"
Endif
If cAliasCo != Nil .And. Select(cAliasCo) > 0
	DbSelectArea(cAliasCo)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0200, "Filial"  , "", Len((cAliasCo)->Filial) , 0, ".F.", USADO, "C",, "V" } ) //"Filial"
	Aadd( aHeader, { STR0079, "Prefixo"  , "", Len((cAliasCo)->prefixo) , 0, ".F.", USADO, "C",, "V" } ) //"Prefixo"
	Aadd( aHeader, { STR0080, "Numero"   , "", Len((cAliasCo)->numero)  , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0097, "Parcela"  , "", Len((cAliasCo)->Parcela) , 0, ".F.", USADO, "C",, "V" } ) //"Parcela"
	Aadd( aHeader, { STR0098, "Vend"     , "", Len((cAliasCo)->Vend)    , 0, ".F.", USADO, "C",, "V" } ) //"Vendedor"
	Aadd( aHeader, { STR0064, "NomeVend" , "", Len((cAliasCo)->NomeVend), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0026, "Saldo"    , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo", "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader5 := aClone(aHeader)
	oGetDb5 := (cAliasCo)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasCo,"AllwaysTrue",,,oFolder:aDialogs[5],.F.,.T.))
	oGetDb5:oBrowse:lHScroll := .F.
	oGetDb5:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[5]:Cargo := {"P",{||Fc021Visual("SE3",(cAliasCo)->Chave,STR0009)}} //"Comissões"
Endif
If cAliasEmp != Nil .And. Select(cAliasEmp) > 0
	DbSelectArea(cAliasEmp)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasEmp)->numero) , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0061, "Banco"     , "", Len((cAliasEmp)->Banco)  , 0, ".F.", USADO, "C",, "V" } ) //"Banco"
	Aadd( aHeader, { STR0062, "Agencia"   , "", Len((cAliasEmp)->Agencia), 0, ".F.", USADO, "C",, "V" } ) //"Agencia"
	Aadd( aHeader, { STR0063, "Conta"     , "", Len((cAliasEmp)->Conta)  , 0, ".F.", USADO, "C",, "V" } ) //"Conta"
	Aadd( aHeader, { STR0090, "Emissao"   , "", 8,0, ".F.", USADO, "D",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader6 := aClone(aHeader)
	oGetDb6  := (cAliasEmp)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.T.,{},,.T.,,cAliasEmp,"AllwaysTrue",,,oFolder:aDialogs[6],.F.,.T.))
	oGetDb6:oBrowse:lHScroll := .F.
	oGetDb6:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[6]:Cargo := {"P",{||Fc021Visual(Left((cAliasEmp)->APELIDO,3),(cAliasEmp)->Chave,STR0076)}} //"Emprestimos"
Endif
If cAliasApl != Nil .And. Select(cAliasApl) > 0
	DbSelectArea(cAliasApl)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasApl)->numero) , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0061, "Banco"     , "", Len((cAliasApl)->Banco)  , 0, ".F.", USADO, "C",, "V" } ) //"Banco"
	Aadd( aHeader, { STR0062, "Agencia"   , "", Len((cAliasApl)->Agencia), 0, ".F.", USADO, "C",, "V" } ) //"Agencia"
	Aadd( aHeader, { STR0063, "Conta"     , "", Len((cAliasApl)->Conta)  , 0, ".F.", USADO, "C",, "V" } ) //"Conta"
	Aadd( aHeader, { STR0090, "Emissao"   , "", 8,0, ".F.", USADO, "D",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader7 := aClone(aHeader)
	oGetDb7  := (cAliasApl)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.T.,{},,.T.,,cAliasApl,"AllwaysTrue",,,oFolder:aDialogs[7],.F.,.T.))
	oGetDb7:oBrowse:lHScroll := .F.
	oGetDb7:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[7]:Cargo := {"R",{||Fc021Visual("SEH",(cAliasApl)->Chave,STR0077)}} //"Aplicações"
Endif
If cAliasChq != Nil .And. Select(cAliasChq) > 0
	DbSelectArea(cAliasChq)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasChq)->numero) , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0061, "Banco"     , "", Len((cAliasChq)->Banco)  , 0, ".F.", USADO, "C",, "V" } ) //"Banco"
	Aadd( aHeader, { STR0062, "Agencia"   , "", Len((cAliasChq)->Agencia), 0, ".F.", USADO, "C",, "V" } ) //"Agencia"
	Aadd( aHeader, { STR0063, "Conta"     , "", Len((cAliasChq)->Conta)  , 0, ".F.", USADO, "C",, "V" } ) //"Conta"
	Aadd( aHeader, { STR0090, "Emissao"   , "", 8,0, ".F.", USADO, "D",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader8 := aClone(aHeader)
	oGetDb8  := (cAliasChq)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.T.,{},,.T.,,cAliasChq,"AllwaysTrue",,,oFolder:aDialogs[8],.F.,.T.))
	oGetDb8:oBrowse:lHScroll := .F.
	oGetDb8:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[8]:Cargo := {"P",{||Fc021Visual("SEF",(cAliasChq)->Chave,STR0195)}}
Endif
If cAliasCtrc != Nil .And. Select(cAliasCtrc) > 0
	DbSelectArea(cAliasCtrc)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { "Fil. Deb."	, "FILDEB"  , "", Len((cAliasCtrc)->FILDEB) , 0, ".F.", USADO, "C",, "V" } )
	Aadd( aHeader, { "Fil. Doc"	, "FILDOC"  , "", Len((cAliasCtrc)->FILDOC) , 0, ".F.", USADO, "C",, "V" } )
	Aadd( aHeader, { "Docto."		, "DOC"     , "", Len((cAliasCtrc)->DOC)  , 0, ".F.", USADO, "C",, "V" } )
	Aadd( aHeader, { "Serie"		, "SERIE"   , "", Len((cAliasCtrc)->SERIE), 0, ".F.", USADO, "C",, "V" } )
	Aadd( aHeader, { "Emissão"		, "EMISSAO" , "", 8,0, ".F.", USADO, "D",, "V" } )
	Aadd( aHeader, { "Valor"		, "SALDO"   , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } )
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader9 := aClone(aHeader)
	oGetDb9  := (cAliasCtrc)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.T.,{},,.T.,,cAliasCtrc,"AllwaysTrue",,,oFolder:aDialogs[9],.F.,.T.))
	oGetDb9:oBrowse:lHScroll := .F.
	oGetDb9:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[9]:Cargo := {"R",{||Fc021Visual("DT6",(cAliasCtrc)->Chave,"Docto. de Transporte")}}
Endif
//-----------------------
// Solicitacoes de Fundo
//-----------------------
If cAliasSol != Nil .And. Select(cAliasSol) > 0
	DbSelectArea(cAliasSol)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, {RetTitle("FJA_FILIAL")	,"FILIAL"	,PesqPict("FJA","FJA_FILIAL")	,TamSX3("FJA_FILIAL")[1]	,0						,".F."	,	,"C"} )
	Aadd( aHeader, {RetTitle("FJA_SOLFUN")	,"SOLFUN"	,PesqPict("FJA","FJA_SOLFUN")	,TamSX3("FJA_SOLFUN")[1]	,0						,".F."	,	,"C"} )
	Aadd( aHeader, {RetTitle("FJA_FORNEC")	,"FORNEC"	,PesqPict("FJA","FJA_FORNEC")	,TamSX3("FJA_FORNEC")[1]	,0						,".F."	,	,"C"} )
	Aadd( aHeader, {RetTitle("FJA_LOJA")	,"LOJA"		,PesqPict("FJA","FJA_LOJA")		,TamSX3("FJA_LOJA")[1]		,0						,".F."	,	,"C"} )
	Aadd( aHeader, {RetTitle("FJA_DATAPR")	,"DATAPR"	,""								,8							,0						,".F."	,	,"D"} )
	Aadd( aHeader, {RetTitle("FJA_VALOR")	,"SALDO"	,PesqPict("FJA","FJA_VALOR")	,TamSX3("FJA_VALOR")[1]		,TamSX3("FJA_VALOR")[2]	,".F."	,	,"N"} )
	Aadd( aHeader, {""						,"CampoNulo",""								,1							,0						,".F."	,	,"C"} )
	aHeader10 := aClone(aHeader)
	oGetDb10  := (cAliasSol)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.T.,{},,.T.,,cAliasSol,"AllwaysTrue",,,oFolder:aDialogs[10],.F.,.T.))
	oGetDb10:oBrowse:lHScroll := .F.
	oGetDb10:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[10]:Cargo := {"R",{||Fc021Visual("FJA",(cAliasSol)->Chave,STR0246)}}  //"Solicitacoes de Fundos"
Endif

If cAliasDMSCompra != Nil .And. Select(cAliasDMSCompra) > 0
	DbSelectArea(cAliasDMSCompra)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := VM210FluxoAna("MAQ_COMPRA")
	aHeader11 := aClone(aHeader)
	oGetDb11 := (cAliasDMSCompra)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasDMSCompra,"AllwaysTrue",,,oFolder:aDialogs[11],.F.,.T.))
	oGetDb11:oBrowse:lHScroll := .F.
	oGetDb11:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[11]:Cargo := {"R",{||Fc021Visual("VQ0",AllTrim((cAliasDMSCompra)->Chave),STR0276 )}} //"Pedidos de Compra de Maquinas"
Endif

If cAliasDMSVenda != Nil .And. Select(cAliasDMSVenda) > 0
	DbSelectArea(cAliasDMSVenda)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := VM210FluxoAna("MAQ_VENDA")
	aHeader12 := aClone(aHeader)
	oGetDb12 := (cAliasDMSVenda)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasDMSVenda,"AllwaysTrue",,,oFolder:aDialogs[12],.F.,.T.))
	oGetDb12:oBrowse:lHScroll := .F.
	oGetDb12:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[12]:Cargo := {"R",{||Fc021Visual("VV0",AllTrim((cAliasDMSVenda)->Chave),STR0277 )}} //"Pedidos de Venda de Maquinas"
Endif

aGetDb := {oGetDb1,oGetDb2,oGetDb3,oGetdb4,oGetDb5,oGetDb6,oGetDb7,oGetDb8,oGetDb9,oGetDb10,oGetDb11,oGetDb12}
aAlias := {cAliasP,cAliasR,cAliasPc,cAliasPv,cAliasCo,cAliasEmp,cAliasApl,cAliasChq,cAliasCtrc,cAliasSol,cAliasDMSCompra,cAliasDMSVenda}

// Posiciona no primeiro folder valido
For nX := 1 To Len(aAlias)
	Do Case
	Case nX == 1 .And. ValType(aHeader1) == "A"
		aHeader := aClone(aHeader1)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 2 .And. ValType(aHeader2) == "A"
		aHeader := aClone(aHeader2)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 3 .And. ValType(aHeader3) == "A"
		aHeader := aClone(aHeader3)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 4 .And. ValType(aHeader4) == "A"
		aHeader := aClone(aHeader4)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 5 .And. ValType(aHeader5) == "A"
		aHeader := aClone(aHeader5)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 6 .And. ValType(aHeader6) == "A"
		aHeader := aClone(aHeader6)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 7 .And. ValType(aHeader7) == "A"
		aHeader := aClone(aHeader7)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 7 .And. ValType(aHeader8) == "A"
		aHeader := aClone(aHeader8)
		DbSelectArea(aAlias[nX])
	Case nX == 11 .And. ValType(aHeader11) == "A"
		aHeader := aClone(aHeader11)
		DbSelectArea(aAlias[nX])
	Case nX == 12 .And. ValType(aHeader12) == "A"
		aHeader := aClone(aHeader12)
		DbSelectArea(aAlias[nX])
	EndCase
Next

If lPanelFin  //Chamado pelo Painel Financeiro
	ACTIVATE MSDIALOG oDlg ON INIT (FaMyBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()},aButton),oPanel2:Align := CONTROL_ALIGN_BOTTOM)
Else
	ACTIVATE MSDIALOG oDlg ON INIT (aEval(aGetDb, {|e| If(ValType(e)=="0",(e:oBrowse:lDisablePaint := .F., e:oBrowse:Refresh(.T.)),Nil)}),;
										  	  EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End()},,aButton),;
											  oFolder:SetOption(2))
Endif
// Limpa os filtros dos arquivos temporarios
For nX := 1 To Len(aAlias)
	If aAlias[nX] != Nil .And. Select(aAlias[nX]) > 0
		DbSelectArea(aAlias[nX])
		(aAlias[nX])->(DbClearFil())
	EndIf
Next

RestArea(aArea)
aHeader	:= aClone(aOldHeader)
aCols	:= aClone(aOldaCols)
aRotina	:= aClone(aOldaRotina)
oFluxo:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc020visua³ Autor ³ Claudio d. de Souza   ³ Data ³ 21/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Detalhe do t¡tulo da tela anal¡tica					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Fc020Visual(cAlias,cChave) 										  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ Gen‚rico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Visual(cAlias,cChave,cTitulo)
Local aArea      := GetArea(),;
		aOldHeader	:= aClone(aHeader),;
		aOldaCols	:= aClone(aCols),;
		aOldaRotina	:= aClone(aRotina),;
		cFilOld     := cFilAnt

Local nTamFil 	:= FinTamSXG("033",TAMSX3("E2_FILIAL")[1])[1]

If !Empty(cChave)
	cFilAnt := Left(cChave,nTamFil)
	dbSelectArea(cAlias)
	dbSetOrder( 1 )
	dbseek( xFilial(cAlias)+SubStr(cChave,nTamFil+1))
	If !(cAlias)->( Eof() )
		cCadastro := OemToAnsi(cTitulo)
		Do Case
		Case cAlias == "SC7"
			MatA120(SC7->C7_TIPO,,,2)
		Case cAlias == "SC5"
			aRotina   := {{ "","AxPesqui", 0 , 1},;
							   { "","A410Visual", 0 , 2} }
			a410Visual(cAlias,RECNO(),2)
		Case cAlias == "EF1"
		    EFFEX400(RecNo(),2)
		Case Left(cAlias,1) == "V"
			VM210Visual( cAlias , nRecno )
		OtherWise
			AxVisual(cAlias,Recno(),2)
		EndCase
	Endif
	RestArea(aArea)
	aHeader	:= aClone(aOldHeader)
	aCols		:= aClone(aOldaCols)
	aRotina	:= aClone(aOldaRotina)
	cFilant  := cFilOld
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Grafico   ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar o tipo da serie de dados e o tipo de grafico    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ oDlg   -> Objeto dialog onde sera exibido a tela do graficoº±±
±±º          ³ cAlias -> Alias do arquivo temporario que sera processado  º±±
±±º          ³ nMoeda -> Codigo da moeda                                  º±±
±±º          ³ cTit   -> Titulo do eixo X                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grafico(oDlg As Object, aFluxo As Array, nMoeda As Numeric, cTit As Character, cVisaoG As Character)
Local oDlgSer	As Object
Local oSer		As Object
Local oVisual	As Object
Local cCbx 		As Character //"Linha"
Local cVisual 	As Character //"Projeção do Saldo"
Local nCbx 		As Numeric
Local aCbx 		As Array
Local aVisual 	As Array
Local nVisual 	As Numeric
Local lFwChart 	As Logical
Local lNewGrfc 	As Logical

cCbx 		:= STR0099 //"Linha"
cVisual 	:= STR0100 //"Projeção do Saldo"
nCbx 		:= 1
aCbx 		:= { STR0099, STR0101, STR0102, STR0103, STR0109 } //"Linha"###"Área"###"Pontos"###"Barras"###"Pizza"
aVisual 	:= { STR0115, STR0100 } //"Receitas x Despesas"###"Projeção do Saldo"
nVisual 	:= 2
lFwChart 	:= !Empty( GetSrcArray( "FWCHART.PRW" ) )
lNewGrfc 	:= .F.

DEFAULT cVisaoG := ""

If lFwChart .And. !IsBlind()
	lNewGrfc := MsgNoYes( STR0275 ) //"Deseja trabalhar com o novo gráfico?"
EndIf

If lNewGrfc
	aSize( aCbx , 0 )
	aCbx := { STR0099 , STR0103 + " - 01" , STR0109 , STR0103 + " - 02" }
EndIf

DEFINE MSDIALOG oDlgSer TITLE STR0116 FROM 0,0 TO 100,280 PIXEL OF oDlg //"Tipo do gráfico"

@ 010, 005 SAY STR0117 PIXEL OF oDlgSer //"Escolha o tipo de série:"
@ 008, 063 MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 10 OF oDlgSer PIXEL ON CHANGE nCbx := oSer:nAt
@ 024, 005 SAY STR0118 PIXEL OF oDlgSer //"Tipo de Visualização   :"
@ 022, 063 MSCOMBOBOX oVisual VAR cVisual ITEMS aVisual SIZE 077, 10 OF oDlgSer PIXEL ON CHANGE nVisual := oVisual:nAt

@ 035, 080 BUTTON "&Ok"  SIZE 30,12 OF oDlgSer PIXEL ACTION (MontaGrafico(aFluxo,nCbx,nVisual,nMoeda,cTit,cVisaoG,lNewGrfc),oDlgSer:End())

@ 035, 110 BUTTON STR0040 SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End() //"&Sair"

ACTIVATE MSDIALOG oDlgSer CENTER

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MontaGraf ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa os dados necessarios para montagem do grafico e   º±±
±±º          ³ exibe o grafico.                                           º±±
±±º          ³ cAlias  -> Alias do arquivo temporario que sera processado º±±
±±º          ³ nCbx    -> Codigo da serie de dados que sera utilizada peloº±±
±±º          ³            objeto grafico                                  º±±
±±º          ³ nVisual -> Tipo de visualizacao 1-Contas a pagar x Ctas Recº±±
±±º          ³                                 2-Projecao do saldo        º±±
±±º          ³ nMoeda  -> Codigo da moeda                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaGrafico(aFluxo As Array, nCbx As Numeric, nVisual As Numeric, nMoeda As Numeric, cTit As Character, cVisaoG As Character, lNewGrfc As Logical)
Local lPanelFin As Logical
Local oDlg		As Object
Local oBold		As Object
Local oGraphic	As Object
Local nSerie    As Numeric
Local nSerie2   As Numeric
Local aArea     As Array
Local aTabela	As Array
Local aVisao 	As Array
Local nX 		As Numeric
Local oPanel	As Object
Local lVideo    As Logical
Local aValGrf01 As Array
Local aValGrf02 As Array

lPanelFin 	:= IsPanelFin()
nSerie    	:= 0
nSerie2   	:= 0
aArea     	:= GetArea()
aVisao 		:= {}
nX 			:= 0
lVideo    	:= .F.
aValGrf01 	:= {}
aValGrf02 	:= {}

DEFAULT cVisaoG 	:= ""
DEFAULT lNewGrfc 	:= .F.

//Verifica se a resolução de vídeo é menor que 1024 x 768
If oMainWnd:nClientWidth < 1000
	lVideo := .T.
EndIf

If !Empty(cVisaoG)
	dbSelectArea("FJ3")
	dbSetOrder(1)
	dbGoTop()

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	dbGoTop()
EndIf

aTabela		:= {{	cTit   ,; //"Dia","Semana","Decendio","Quinzena","Mes"
		 			   STR0043,; //"Entradas"
		 				STR0044,; //"Saidas"
		 				STR0045,; //"Saldo do Dia"
		 				STR0046,; //"Var.Dia"
		 				STR0047,; //"Entr.Acumul."
		 				STR0048,; //"Saida Acumul."
		 				STR0049,; //"Saldo Acumul."
		 				STR0050}}

		For nX := 1 To Len(aFluxo)

	    //Se tiver visao gerencial, só colocar no grafico o total geral do dia
	   	If Empty(cVisaoG) .Or. FJ3->(dbSeek(xFilial("FJ3")+cVisaoG+AllTrim(CARQTMP->ORDEM)))
	  		If (Empty(cVisaoG) .Or. (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '1'))
				Aadd(aTabela,{	Pad(Transform(aFluxo[nX,DATAFLUXO],""),17),;
								 	Transform(aFluxo[nX,ENTRADAS				]	,"@E 999,999,999,999.99"),;
									Transform(aFluxo[nX,SAIDAS		  		   ]	,"@E 999,999,999,999.99"),;
									Transform(aFluxo[nX,SALDODIA				]	,"@E 999,999,999,999.99"),;
									Transform(aFluxo[nX,VARIACAODIA			]	,"@r 9999999999999.99%"),;
									Transform(aFluxo[nX,ENTRADASACUMULADAS]	,"@e 99,999,999,999.99"),;
									Transform(aFluxo[nX,SAIDASACUMULADAS	]	,"@e 99,999,999,999.99"),;
									Transform(aFluxo[nX,SALDOACUMULADO		]	,"@e 99,999,999,999.99"),;
									Transform(aFluxo[nX,VARIACAOACUMULADA	]	,"@r 9999999999999.99%")})
	   		EndIf
	  	EndIf

	  	If !Empty(cVisaoG)
			CARQTMP->(dbSkip())
		EndIf
	Next
	//Montar gráfico somente com as entidades totalizadoras
	If !Empty(cVisaoG)
		CARQTMP->(dbGoTop())

		For nX := 1 To Len(aFluxo)
			//Se tiver visao gerencial, só colocar no grafico o total geral do dia
		   	If FJ3->(dbSeek(xFilial("FJ3")+cVisaoG+AllTrim(CARQTMP->ORDEM)))
		  		If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '1')
		  			Aadd(aVisao, aFluxo[nX] )
		  		EndIf
			EndIf
			CARQTMP->(dbSkip())
		Next
	EndIf


oSize := FwDefSize():New(.T.)

oSize:lLateral := .F.
oSize:lProp	:= .T. // Proporcional

oSize:AddObject( "1STROW" ,  100, 90, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "2NDROW" ,  100, 10, .T., .T. ) // Totalmente dimensionavel

oSize:aMargins := { 2, 2, 1, 2 } // Espaco ao lado dos objetos 0, entre eles 3

oSize:Process() // Dispara os calculos

a1stRow := {oSize:GetDimension("1STROW","LININI"),;
			oSize:GetDimension("1STROW","COLINI"),;
			oSize:GetDimension("1STROW","LINEND"),;
			oSize:GetDimension("1STROW","COLEND")}

a2ndRow := {oSize:GetDimension("2NDROW","LININI"),;
			oSize:GetDimension("2NDROW","COLINI"),;
			oSize:GetDimension("2NDROW","LINEND"),;
			oSize:GetDimension("2NDROW","XSIZE")}

DEFINE MSDIALOG oDlg TITLE STR0119 From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL //"Representação gráfica do Fluxo de Caixa"
oDlg:lMaximized := .T.

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

If !lNewGrfc
	// Layout da janela
	If nCbx == 5
		nCbx	:= 10
	EndIf
	
	@ a1stRow[1] - 23 , a1stRow[2] MSGRAPHIC oGraphic SIZE a1stRow[4], a1stRow[3] OF oDlg PIXEL

	oGraphic:SetTitle(STR0120 + If( nVisual == 1, STR0115, STR0121),"",CLR_HBLUE,3,.F.)
	oGraphic:SetMargins( 2, 6, 6, 6 )

	If !lPanelFin
		oGraphic:bRClicked := {|o,x,y| oMenu:Activate(x,y,oGraphic) } // Posição x,y em relação a Dialog

		MENU oMenu POPUP
			MENUITEM STR0188 Action ConsDadGraf(aTabela) //"Consulta dados do grafico"
		ENDMENU
	EndIf

	// Habilita a legenda, apenas se houver mais de uma serie de dados.
	oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)
	nSerie  := oGraphic:CreateSerie(nCbx,,2)

	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,,,25,25,.T.,.T. )

	// Adiciona mais uma série de dados, conforme o tipo do grafico
	If nVisual == 1 // Contas a Pagar x Contas a Receber
	   nSerie2 := oGraphic:CreateSerie(nCbx,,2)
	   @ 005, 30 SAY STR0122 OF oPanel COLOR CLR_HBLUE FONT oBold PIXEL //"Receitas"
	   @ 013, 30 SAY STR0123 OF oPanel COLOR CLR_HRED  FONT oBold PIXEL //"Despesas"
	EndIf


		If nSerie != GRP_CREATE_ERR .And. nSerie2 != GRP_CREATE_ERR
			If (Empty(cVisaoG))
				aEval(aFluxo,{|e|If(nVisual==1,(oGraphic:Add(nSerie ,e[ENTRADASACUMULADAS],Transform(e[DATAFLUXO],""),CLR_HBLUE),;
													  	   oGraphic:Add(nSerie2,e[SAIDASACUMULADAS]  ,Transform(e[DATAFLUXO],""),CLR_HRED)),;
													  		oGraphic:Add(nSerie ,e[SALDOACUMULADO]    ,Transform(e[DATAFLUXO],""),If(e[SALDOACUMULADO]<0,CLR_HRED,CLR_HBLUE)))})
			Else
		   		aEval(aVisao,{|e|If(nVisual==1,(oGraphic:Add(nSerie ,e[ENTRADASACUMULADAS],Transform(e[DATAFLUXO],""),CLR_HBLUE),;
													  	   oGraphic:Add(nSerie2,e[SAIDASACUMULADAS]  ,Transform(e[DATAFLUXO],""),CLR_HRED)),;
													  		oGraphic:Add(nSerie ,e[SALDOACUMULADO]    ,Transform(e[DATAFLUXO],""),If(e[SALDOACUMULADO]<0,CLR_HRED,CLR_HBLUE)))})
			EndIf
		Else
			IW_MSGBOX(STR0124,STR0198,"STOP") //"Não foi possível criar a série."
		EndIf

	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( GetMv("MV_SIMB"+Alltrim(Str(nMoeda,2))),"", CLR_HRED , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetTitle( "", cTit, CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //"Datas"

	If ! lPanelFin  //Nao chamado pelo Painel Financeiro
		oPanel:Align := CONTROL_ALIGN_BOTTOM
		@ 005, If(!lVideo,300,200) BUTTON o3D PROMPT "&2D" SIZE 40,14 OF oPanel PIXEL ACTION (oGraphic:l3D := !oGraphic:l3D, o3d:cCaption := If(oGraphic:l3D, "&2D", "&3D"))
		@ 005, If(!lVideo,350,250) BUTTON STR0126   SIZE 40,14 OF oPanel PIXEL ACTION GrafSavBmp( oGraphic ) //"&Salva BMP"

		If !__lPyme
			@ 005, If(!lVideo,400,300) BUTTON STR0187 SIZE 40,14 OF oPanel PIXEL ACTION PmsGrafMail(oGraphic,STR0119,{STR0120 + If( nVisual == 1, STR0115, STR0121)},aTabela,1) // E-Mail
		Endif
		@ 005, If(!lVideo,450,350) BUTTON STR0040 SIZE 40,14 OF oPanel PIXEL ACTION oDlg:End() //"&Sair"
	EndIf

	If lVideo
		oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	If lPanelFin  //Chamado pelo Painel Financeiro
		aButtonTxt := {}
		AADD(aButtonTxt,{"3D","3D",{||oGraphic:l3D := !oGraphic:l3D}})
		AADD(aButtonTxt,{STR0126,STR0126,{||GrafSavBmp( oGraphic )}})
		AADD(aButtonTxt,{STR0187,STR0187,{||PmsGrafMail(oGraphic,STR0119,{STR0120 + If( nVisual == 1, STR0115, STR0121)},aTabela,1)}})
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
			,{||oDlg:End()},,aButtonTxt)
	Else
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
Else
	//Linha, barra e pizza
	If nCbx == 1
		oGraphic := FWChartLine():New()
	ElseIf nCbx == 2
		oGraphic := FWChartBar():New()
	ElseIf nCbx == 3
		oGraphic := FwChartPie():New()
	Else
		oGraphic := FWChartBarComp():New()
	EndIf 

	oGraphic:Init( oDlg , .T. , .T. )
	oGraphic:SetTitle( STR0120 + If( nVisual == 1, STR0115 , STR0121 ) )
	oGraphic:SetLegend( CONTROL_ALIGN_LEFT )

	//SALDOACUMULADO
	//DATAFLUXO
	//ENTRADASACUMULADAS
	//SAIDASACUMULADAS

	For nX := 1 To Len( aFluxo )
		If nVisual == 2
			If nCbx == 1 .Or. nCbx == 4
				aAdd( aValGrf01 , { aFluxo[ nX ][ DATAFLUXO ] , aFluxo[ nX ][SALDOACUMULADO] } )
			Else
				oGraphic:AddSerie( aFluxo[ nX ][ DATAFLUXO ] , aFluxo[ nX ][SALDOACUMULADO] )
			EndIf
		Else
			If nCbx == 1 .Or. nCbx == 4
				aAdd( aValGrf01 , { aFluxo[ nX ][ DATAFLUXO ] , aFluxo[ nX ][ENTRADASACUMULADAS] } )
				aAdd( aValGrf02 , { aFluxo[ nX ][ DATAFLUXO ] , aFluxo[ nX ][SAIDASACUMULADAS]   } )
			Else
				oGraphic:AddSerie( aFluxo[ nX ][ DATAFLUXO ] + " - " + STR0047 , aFluxo[ nX ][ENTRADASACUMULADAS] )
				oGraphic:AddSerie( aFluxo[ nX ][ DATAFLUXO ] + " - " + STR0048 , aFluxo[ nX ][SAIDASACUMULADAS]   )
			EndIf
		EndIf
	Next nX

	If nCbx == 1 .Or. nCbx == 4
		If nVisual == 2
			oGraphic:AddSerie( STR0049 , aValGrf01 )
		Else
			oGraphic:AddSerie( STR0047 , aValGrf01 )
			oGraphic:AddSerie( STR0048 , aValGrf02 )
		EndIf
	EndIf

	oGraphic:Build()

	Activate MsDialog oDlg Center
EndIf

aSize( aValGrf01 , 0 )
aSize( aValGrf02 , 0 )
aValGrf02 := Nil
aValGrf01 := Nil

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021ImpFlx³ Autor ³ Claudio Donizete 	  ³ Data ³ 23/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime o Fluxo de Caixa											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,;
									 nAtrReceber,aFluxo,cTit,cMoeda,lLimCred,cVisaoG)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 														  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1 :=OemToAnsi(STR0132) //"Este programa ir  imprimir o Fluxo de Caixa."s //"Este programa imprimirá o Fluxo de Caixa."
Local cDesc2 :=""
Local cDesc3 :=""
Local lRetImp := .T.

Private aReturn:={STR0133,1,STR0134,1,2,1,"",1} //"Zebrado"###"Administracao" //"Zebrado"###"Administracao"
Private cabec1,cabec2,nLastKey:=0,titulo,wnrel,tamanho:="P"
Private nomeprog :="FINC021"

DEFAULT cVisaoG := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo:= STR0032 + STR0197 + Capital(SubStr(cMoeda,3)) // "Fluxo de Caixa em " //" em "

If (Empty(cVisaoG))
	cabec1:= Pad(cTit, IIf(cTit == "Dia", 18, 24))+STR0135 //"Data             " + "A Pagar       A Receber      Disponivel"
Else
	cabec1:= Pad(cTit, IIf(cTit == "Dia", 18, 24))+STR0238 //"                 A Pagar          A Receber         Disponivel "
EndIf

cabec2:= ""

//Altera o tamanho do formulario
tamanho := IIf(cTit == "Dia", "P", "M")

//Ponto de entrada pela Microsiga
If ExistBlock("FC021TIT")
	ExecBlock("FC021TIT",.F.,.F.,Titulo)
Endif

// Ponto de entrada para possibilitar ou nao a impressao
If ExistBlock("FC021IMP")
	lRetImp:=ExecBlock("FC021IMP",.F.,.F.)
Endif

wnrel:="FINC021"            //Nome Default do relatorio em Disco
If lRetImp
	wnrel:=SetPrint("SE1",wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn)

	If nLastKey == 27
		Return
	Endif

	RptStatus({|lEnd| Fc021ImpOk(@lEnd,wnRel,aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,lLimCred,cTit,cVisaoG)},Titulo)

EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021ImpOk ³ Autor ³ Claudio Donizete 	  ³ Data ³ 23/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime o Fluxo de Caixa.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021ImpOk(lEnd,wnRel,aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,lLimCred,cTit,cVisaoG)
Local nX := 0
Local nTotReceitas 	:= 0
Local nTotDespesas 	:= 0
Local nDisponivel  	:= 0
Local nLimCrdBco	:= 0
Local nLimCrdCx	 	:= 0
Local aArea 		:= GetArea()
Local cBancoCx 		:= GetMV("MV_CARTEIR")
Local cData 		:= ""
Local cAno 			:= ""
Local nAno 			:= 0

DEFAULT lLimCred := .T.
DEFAULT cVisaoG  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt  := Space(10)
cbcont := 00
li  := 80
m_pag  := 01

SetRegua(Len(aFluxo)+Len(aBancos))

If lSaldoBanc
	If Len(aBancos) > 0
		If ( li > 58 )
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
		EndIf
		@ ++li, 0 PSAY	STR0201 //"Banco                      Agencia           Conta                    Saldo"
		//"Banco"###"Agencia"###"Conta"###"Nome"
	Endif
	For nX := 1 To Len(aBancos)
		IncRegua()
		// Se imprime saldos bancarios e o saldo eh maior que zero, imprime
		If aBancos[nX][1] .And. (Fc021Val(aBancos[nX,6]) != 0) .Or. (Fc021Val(aBancos[nX][8]) != 0)

			If ( li > 58 )
				@ ++li, 0 PSAY	STR0201 //"Banco                      Agencia           Conta                    Saldo"
		                 //12345678901234567890123456789012345678901234567890123456789012345678901234567890
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
			EndIf
			li++
			@li, 0 PSAY	Pad(aBancos[nX,2]+"-"+aBancos[nX,5],13)+;
							PadL(aBancos[nX,3],11)+PadL(aBancos[nX,4],14)
			@li,44 PSAY aBancos[nX,6]
			If lLimCred
				@li,66 PSAY aBancos[nX,8]  //Limite de crédito
			Endif
			If lLimCred
				If (Left(aBancos[nX][2],2)=="CX" .Or. Left(aBancos[nX][2],3) $ cBancoCx)
					nLimCrdCx  += Fc021Val(aBancos[nX][8])
				Else
					nLimCrdBco += Fc021Val(aBancos[nX][8])
				Endif
			Endif
		EndIf
	Next
	If ( li > 55 )
		li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
	EndIf
	If ( nBancos+nCaixas != 0 )
		@++li,00 PSay Repl("-",80)
	Endif
	If ( nBAncos != 0)
		li++
		@li, 0 PSAY STR0136 //"Total em Bancos : "
		@li,40 PSAY nBancos	 Picture tm(nBancos,18)
		If lLimCred .and. ( nLimCrdBco != 0)
			@li,62 PSAY nLimCrdBco Picture tm(nLimCrdBco,18)
		Endif
	EndIf
	If ( nCaixas != 0 )
		li++
		@li, 0 PSAY STR0137 //"Total em Caixa : "
		@li,40 PSAY nCaixas	 Picture tm(nCaixas,18)
		If lLimCred .and. ( nLimCrdCx != 0)
			@li,62 PSAY nLimCrdCx Picture tm(nLimCrdCx,18)
		Endif
	EndIf
	If ( nBancos+nCaixas != 0 )
		li++
		@li, 0 PSAY STR0138 //"Total Disponivel : "
		@li,40 PSAY nBancos+nCaixas	Picture tm(nBancos+nCaixas,18)
		If lLimCred .and. nLimCrdBco+nLimCrdCx != 0
			@li,62 PSAY nLimCrdBco+nLimCrdCx	Picture tm(nLimCrdBco+nLimCrdCx,18)
		Endif
	EndIf
	@++li,00 PSay Repl("-",80)
EndIf

nDisponivel := (nBancos+nCaixas+nLimCrdBco+nLimCrdCx)
nDisponivel += (nAtrReceber - nAtrPagar)
li++

	If !Empty(cVisaoG)
    	dbSelectArea("FJ3")
		dbSetOrder(1)
		dbGoTop()

		dbSelectArea( "cArqTmp" )
		dbSetOrder(1)
		dbGoTop()
	EndIf

	For nX := 1 TO Len(aFluxo)
		IF lEnd
			@PROW()+1,001 PSAY STR0139 //"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIF

		IncRegua()

		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
		End

		If (Empty(cVisaoG))
			nDisponivel -= aFluxo[nX][SAIDAS]
			nDisponivel += aFluxo[nX][ENTRADAS]

			If aFluxo[nX][SAIDAS]+aFluxo[nX][ENTRADAS] != 0
				cAno := Alltrim(STR(YEAR(CTOD(aFluxo[nX][DATAFLUXO]))))
				nAno := If(Len(cAno) == 4, 9 ,7)	
				cData := substr(aFluxo[nX][DATAFLUXO],1,2) +"/"+ substr(aFluxo[nX][DATAFLUXO],4,2) +"/"+ substr(aFluxo[nX][DATAFLUXO],nAno,2)
				
				@li,00 PSay Left(cData,23)
				@Prow(),PCOL()+1 PSay aFluxo[nX][ENTRADAS]  picture TM(aFluxo[nX][ENTRADAS],18)
				@Prow(),PCOL()+1 PSay aFluxo[nX][SAIDAS]    picture TM(aFluxo[nX][SAIDAS],18)
				@Prow(),PCOL()+1 Psay (aFluxo[nX][SAIDAS]/aFluxo[nX][ENTRADAS])*100 Picture "@E 9999999999.99%"
				@Prow(),PCOL()+1 PSay nDisponivel  picture TM(nDisponivel,18)
				li ++
			Endif

			nTotDespesas += aFluxo[nX][SAIDAS]
			nTotReceitas += aFluxo[nX][ENTRADAS]
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Imprimir o relatório usando a visão gerencial³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

			If FJ3->(dbSeek(xFilial("FJ3")+cVisaoG+AllTrim(CARQTMP->ORDEM))) //Procura pela descricao na FJ3 para impressao em branco
				//Se deve imprimir em branco
				If (FJ3->FJ3_IDENT $ "5")

				    If (FJ3->FJ3_IDENT $ "5" .And. Alltrim(FJ3->FJ3_DESCCG) == "-")
		                //Desabilita a impressão da linha quando for imprimir o traco
						@Li,00 PSAY Replic("-",79)
						Li++
				  	Else
				   		@Li,00 PSAY AllTrim(CARQTMP->CODDESC)//CARQTMP->CODDESC
				   		@Li,28 PSAY "" //Recebidos
						@Li,45 PSAY "" //Pagos
						@Li,66 PSAY "" //Disponivel
						Li++
					EndIf
				Else
					@Li,00 PSAY AllTrim(CARQTMP->CODDESC)//CARQTMP->CODDESC
					@Li,28 PSAY CARQTMP->RECEBIDOS	PICTURE TM(CARQTMP->RECEBIDOS,14,2) // "@E 999,999,999.99"
					@Li,45 PSAY CARQTMP->PAGOS 		PICTURE TM(CARQTMP->PAGOS,14,2) //"@E 999,999,999.99"
					@Li,66 PSAY CARQTMP->DISPONIVEL	PICTURE TM(CARQTMP->DISPONIVEL,14,2) //"@E 999,999,999.99"
					Li++
		    	EndIf
			EndIf
			CARQTMP->(dbSkip())
		EndIf
	Next

If li+9 > 55
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
End

@li++,00 PSay Repl("-",IIf(cTit == "Dia", 80, 86))
@li++,00 PSay STR0186 + Transform(nAtrReceber,"@E 999,999,999,999.99") //"Total de Atrasados a Receber : "
@li++,00 PSay STR0140 + Transform(nAtrPagar,"@E 999,999,999,999.99") //"Total de Atrasados a Pagar   : "
@li++,00 PSay STR0202 + Transform(nLimCrdBco+nLimCrdCx+nBancos+nCaixas,"@E 999,999,999,999.99") //"Saldo             : "
@li++,00 PSay STR0141 + Transform(nBancos+nCaixas,"@E 999,999,999,999.99") //"Disponibilidade   : "
@li++,00 PSay STR0142 + Transform(nTotReceitas,"@E 999,999,999,999.99") //"Total A Receber   : "
@li++,00 PSay STR0143 + Transform(nTotDespesas,"@E 999,999,999,999.99") //"Total A Pagar     : "
@li++,00 PSay STR0144 + Transform(nDisponivel,"@E 999,999,999,999.99") //"Saldo             : "
@li++,00 PSay Repl("-",IIf(cTit == "Dia", 80, 86))

roda(cbcont,cbtxt)

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021SimulºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Simulacao do fluxo de caixa                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,;
									nMoeda,nDias,aPeriodo,nLimCred)

Local lPanelFin := IsPanelFin()
Local oGet					 ,;
		aArea := GetArea(),;
		aOldHeader := aClone(aHeader),;
		oDlg              ,;
		nOpca					,;
		lNaoTemSimul	   ,;
		nIndPer				,;
		nAscan
Local aCopiaCols	:= {}
Local aAlterCols	:= {}
Local nX := 0
LocaL	aButSimul := {	{"IMPRESSAO", {|| Fc021ImpSi()}, STR0210,STR0211},; //"Imprime Simulação"###"Imprimir"
							{"SALVAR",{||Fc021GrvSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda)},STR0145,STR0212},; //"Grava Simulação"
						  	{"NOTE",{||Fc021RstSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,!lNaoTemSimul,nDias,aPeriodo,nLimCred)},STR0146,STR0213}} //"Restaura Simulação"

lNaoTemSimul := (aCols == Nil .Or. Empty(aCols) .Or. Empty(aCols[1][3]))
// Cria aCols caso nao exista, ou esteja vazia e nao permite a opcao de
// nova simulacao pois os valores da simulacao atual sao abatidos do Fluxo.
If lNaoTemSimul
	LimpaACols()
Else
	Aadd(aButSimul,{"EDIT"  ,{||Fc021NovSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo,nLimCred)},STR0151,STR0151}) //"Nova"
	aAlterCols := aClone( aCols )
Endif

If cPaisLoc == "ARG"
	AAdd(aButSimul,{"GERTIT",{|| Fc021GerTi()},STR0248,STR0249}) //"Gerar Titulos"###"Gerar"
EndIf

aSort(aCols,,,{|x,y| DTOS(x[1]) < DTOS(y[1])})
aSort(aAlterCols,,,{|x,y| DTOS(x[1]) < DTOS(y[1])})

DEFINE MSDIALOG oDlg TITLE STR0147 From 9,0 To 28,93 OF oMainWnd //"Fluxo de Caixa - Simulação"
oGet := MSGetDados():New(30,2,140,370,3,{||Fc021LinOk(aPeriodo)},,,.T.,{"_SI_DATA","_SI_TIPO","_SI_VALOR","_SI_HISTOR"},,,99999,,,,,oDlg)
oGet:oBrowse:lHScroll := .F.

If lPanelFin  //Chamado pelo Painel Financeiro
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT FaMyBar(oDlg,;
														 {||nOpca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca := 0)},;
														 {||nOpca:=0,oDlg:End()},aButSimul)
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
														 {||nOpca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca := 0)},;
														 {||nOpca:=0,oDlg:End()},,;
															 aButSimul) CENTER
Endif

If nOpca == 1
	For nX := 1 To Len(aCols)
		// Se a linha nao estiver deletada
		If !aCols[nX][Len(aCols[nX])] .And. !Empty(aCols[nX][3])
			// No caso de alteracao de data ou de carteira, os valores antigos sao zerados
			If Len( aAlterCols ) >= nX .And. ( aCols[nX][1] <> aAlterCols[nX][1] .Or. aCols[nX][2] <> aAlterCols[nX][2] )
				SubtraiFlx( nX , aPeriodo , @aFluxo , aAlterCols )
				aCols[nX][5] := 0
			EndIf
			// Pesquisa a Data da Simulacao
			nIndPer := Ascan(aPeriodo,{|e| e[1] == aCols[nX][1]})
			If nIndPer > 0
				nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPer][2] $ e[DATAFLUXO]})
				// Valor diferente, significa alteracao ou nova entrada/saida na simulacao
				If aCols[nX][5] != aCols[nX][3]
					If aCols[nX][2] == "R"
						aFluxo[nAscan][ENTRADAS] -= aCols[nX][5] // Tira o valor antigo
						aFluxo[nAscan][ENTRADAS] += aCols[nX][3] // Guarda o novo valor
					Else
						aFluxo[nAscan][SAIDAS]   -= aCols[nX][5] // Tira o valor antigo
						aFluxo[nAscan][SAIDAS]   += aCols[nX][3] // Guarda o novo valor
					Endif
 					aCols[nX][5] := aCols[nX][3] // Guarda o novo valor em valor antigo
				Endif
			Endif
			Aadd(aCopiaCols,aCols[nX]) // Copia as linhas nao deletadas de aCols
		ElseIf aCols[nX][Len(aCols[nX])] .And. Len(aAlterCols) > 0 // Linha deletada, exclui lancamento
			SubtraiFlx( nX , aPeriodo , @aFluxo , aAlterCols )
		EndIf
	Next
	aCols := aClone(aCopiaCols) // Copia as linhas nao deletadas para aCols
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula o saldo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nLimCred)
	oFluxo:Refresh()
Endif

// Restaura ambiente
RestArea(aArea)
aHeader := aClone(aOldHeader)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³SubtraiFlx  ³Daniel Mendes de Melo º     Data ³  28/11/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Subtrai os valores antigos do Fluxo                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SubtraiFlx( nX , aPeriodo , aFluxo/*@*/ , aAlterCols)
// Pesquisa a Data da Simulacao
Local nIndPer := Ascan(aPeriodo,{|e| e[1] == aAlterCols[nX][1]})
Local nAscan  := Ascan(aFluxo,	{|e| aPeriodo[nIndPer][2] $ e[DATAFLUXO]})

	If aAlterCols[nX][2] == "R"
		aFluxo[nAscan][ENTRADAS] -= aAlterCols[nX][5] // Tira o valor antigo
	Else
		aFluxo[nAscan][SAIDAS]   -= aAlterCols[nX][5] // Tira o valor antigo
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021LinOkºAutor  ³Claudio D. de Souza º Data ³  11/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a linha da GetDados da Simulacao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc021LinOk(aPeriodo)
Local lRet := .F.

Do Case
Case !aCols[n][Len(aCols[1])] .And. (Empty(aCols[n][1]) .Or. aCols[n][1] < dDataBase)
	IW_MsgBox(STR0148 + DTOC(dDataBase),STR0198, "STOP") //"E necessario informar uma data maior ou igual a "
Case !aCols[n][Len(aCols[1])] .And. !aCols[n][2] $ "RD"
	IW_MsgBox(STR0149,STR0198, "STOP")	 //"E necessario informar um tipo válido de simulação (R=Receita ou D=Despesa)"
Case !aCols[n][Len(aCols[1])] .And. aCols[n][3] <= 0
	IW_MsgBox(STR0150,STR0198, "STOP") //"E necessario informar um valor maior que zero"
Case !aCols[n][Len(aCols[1])] .And. (Ascan(aPeriodo,	{|e| e[1] == aCols[n][1]}) == 0)
	IW_MsgBox(STR0183 + DTOC(aPeriodo[Len(aPeriodo)][1]),STR0198, "STOP") //"E necessario informar uma data menor ou igual a "
OtherWise
	lRet := .T.
EndCase
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021GrvSim³ Autor ³ Claudio D. de Souza  ³ Data ³ 11/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Salva 	simula‡äes em disco. 				       		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021GrvSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda)

LOCAL cArquivo := space(8)
LOCAL nX := 0
LOCAL nHdl	:= 0
LOCAL cDate := SET(_SET_DATEFORMAT)

If !Empty(aCols[1,3])

	cArquivo := cGetFile(STR0152, STR0153) //"Simulação | *.SIM"###"Informe o arquivo de simulação"

	If !Empty( cArquivo ) .and. Left( Alltrim( cArquivo ) ,1) # "*"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Verifica se o arquivo j  existe e pergunta se   ³
		//³	quer sobrepor. 										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArquivo := Alltrim( cArquivo )

		If Upper(Right(cArquivo,4)) # ".SIM"
			cArquivo += ".SIM"
		Endif

		IF File(cArquivo)
			IF !MsgYesNo( STR0154 + cArquivo + "?" , STR0155 ) //"Sobregrava "###"Arquivo J  Existe !" //"Sobregravar "###"Arquivo já existe!"
				Return Nil
			Endif
		Endif
		nHdl:=fCreate(cArquivo)
		If nHdl == -1
			IW_MSGBOX(STR0156 + Str(fError(),2),STR0198,"STOP") //"Erro na criação do arquivo - Erro DOS Nº"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ao se gravar o arquivo de simula‡Æo, desligo a op‡Æo de ano³
			//³	com 4 digitos para que uma simula‡Æo possa ser restaurada³
			//³	por qualquer usu rio, utilizando ele 2 ou 4 digitos/ano  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SET(_SET_DATEFORMAT, "DD/MM/YY")
			For nX := 1 to Len( aCols )
				If !aCols[nX][Len(aCols[1])] // Se a Linha nao estiver deletada
					cCampo := dtoc(acols[nX,1]) + Str(aCols[nX,3],15,2) + ;
								 aCols[nX,2] + aCols[nX,4] + Str(nMoeda,1,0)
					fWrite( nHdl,cCampo+CHR(13)+CHR(10),Len(cCampo)+2 )
				Endif
			Next
			fClose(nHdl)
			SET(_SET_DATEFORMAT,cDate)
		Endif
	Endif
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021RstSim³ Autor ³ Claudio D. de Souza  ³ Data ³ 11/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Restaura 	simula‡äes do disco. 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021RstSim (aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,lGravado,nDias,aPeriodo,nLimCred )

Local cFile 	:= ""
Local xBuffer  := ""
Local nX 		:= 0
Local nY  		:= 0
Local dData 	:= Ctod("")
Local nValor	:= 0
Local cTipo 	:= ""
Local cHistor  := ""
Local nLen

cFile := cGetFile(STR0152, STR0157) //"Simulação | *.SIM"###"Selecione o arquivo de simulação"
If !Empty(cFile) .and. File( cFile )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Se j  houver uma simula‡…o em mem¢ria, pergunta se ³
	//³  haver  sobreposi‡Æo.									     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Empty(aCols[1,3])
		IF MsgYesNo( STR0158, STR0159) //"Salva simulação existente"###"Existe simulação"
			Fc021GrvSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda)
		Endif
		If lGravado
			For nX := 1 to Len(aCols)
				If !aCols[nX][Len(aCols[1])] // Se a linha nao estiver deletada
					For nY := 1 to Len(aPeriodo)
						If aPeriodo[nY,1] == aCols[nX,1]
							IF Left(aCols[nX,2],1) == "D"
								aFluxo[nY][SAIDAS]   -= aCols[nX,3]
							Else
								aFluxo[nY][ENTRADAS] -= aCols[nX,3]
							EndIf
						Endif
					Next
				Endif
			Next
		Endif
	Endif
	LimpaAcols()
	nHdl:=fOpen(cFile,0+64)
	nLidos:=0
	fSeek(nHdl,0,0)
	nTamArq:=fSeek(nHdl,0,2)
	FSEEK(nHdl,0,0)
	nLen := 70
	xBuffer:=Space(nLen)
	fRead(nHdl,@xBuffer,nLen)
	// Indica arquivo de simulacao no formato antigo, antes de ser aumentado o
	// tamanho do campo valor
	If At("/",SubStr(xBuffer,9)) == 55
		nLen := 60
	Else
		nLen := 67
	Endif
	FSEEK(nHdl,0,0) // Reposiciona no inicio do arquivo off-set 0,0
	While nLidos < nTamArq
		xBuffer:=Space(nLen)
		fRead(nHdl,@xBuffer,nLen)
		dData 	:= ctod( Subst( xBuffer,01,08),"ddmmyy" )
		nValor	:= val( Subst( xBuffer,09,If(nLen=60,10,15)) )
		cTipo 	:= Subst( xBuffer,If(nLen==60,19,24),01 )
		cHistor  := Subst( xBuffer,If(nLen==60,20,25),40 )
		cSimMoeda:= Subst( xBuffer,If(nLen==60,60,65),01 )

		If (dData >= dDataBase .And. dData <= dDataBase+nDias-1)
			If Len(aCols) == 1
				If Empty(aCols[1,3])
					nPointer := 1
				Else
					LimpaACols(.F.)
					nPointer := 2
				Endif
			Else
				LimpaACols(.F.)
				nPointer := Len(aCols)
			Endif
			aCols[nPointer,1] := dData
			aCols[nPointer,2] := cTipo
			aCols[nPointer,3] := xMoeda(nValor,Int(Val(cSimMoeda)),nMoeda)
			aCols[nPointer,4] := cHistor
		EndIf
		nLidos += nLen
	EndDo
	fClose(nHdl)
	// Ordena por data
	aSort(aCols,,,{|x,y| DTOS(x[1]) < DTOS(y[1])})
	// Recalcula o saldo
	CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nLimCred)
	oFluxo:Refresh(.f.)
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021NovSim³ Autor ³ Claudio D. de Souza  ³ Data ³ 10/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reseta simulacoes da mem¢ria. 				   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021NovSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,;
									 aPeriodo,nLimCred)
Local nX    := 0
Local nAscan:= 0
Local nIndPer

If !Empty(aCols[1,3])
	IF MsgYesNo(STR0160,	STR0161) //"Confirma ?"###"Nova Simula‡„o" //"Confirma?"###"Nova Simulação"
		For nX := 1 to Len(aCols)
			If !aCols[nX][Len(aCols[1])] .And. !Empty(aCols[nX][5]) // Se a linha nao estiver deletada
				nIndPer := Ascan(aPeriodo,{|e| e[1] == aCols[nX][1]})
				If nIndPer > 0
					nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPer][2] $ e[DATAFLUXO]})
					IF aCols[nX][2] == "R"
						aFluxo[nAscan][ENTRADAS] -= aCols[nX][5]
					Else
						aFluxo[nAscan][SAIDAS] -= aCols[nX][5]
					End
				Endif
			Endif
		Next
		LimpaAcols()
		CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nLimCred)
		oFluxo:Refresh(.f.)
	Endif
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TemFluxoDat³ Autor ³ Claudio D. de Souza  ³ Data ³ 10/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe dados para a data na matriz de periodos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TemFluxoData(dData, aFluxo)
Local nAscan
	nAscan := Ascan(aFluxo, {|e|e[DATAFLUXO]==dData})
	If nAscan == 0
		Aadd(aFluxo, {dData,0,0,0,0,0,0,0,0,0})
		nAscan := Len(aFluxo)
	Endif
Return nAscan

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LimpaACols ³ Autor ³ Claudio D. de Souza  ³ Data ³ 10/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa a variavel aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LimpaAcols(lZera)
Local nLenaCols
DEFAULT lZera := .T. // Indica se deve zerar a matriz

	If lZera
		aCols := {}
	Endif
	Aadd(aCols,Array(Len(aHeader)+1))
	nLenaCols := Len(aCols)
	Aeval(aHeader, { |e,nX|	If(e[8] == "D", aCols[nLenaCols][nX] := dDataBase,;
									If(e[8] == "N", aCols[nLenaCols][nX] := 0       ,;
									If(e[8] == "C" .And. !Empty(e[1])       ,;
								   	    aCols[nLenaCols][nX] := Space(e[4])           ,;
										aCols[nLenaCols][nX] := "")))})
	aCols[nLenaCols][Len(aCols[1])] := .F. // Indica que a linha nao esta deletada

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fc021ChFol³ Autor ³Claudio D. de Souza    ³ Data ³03.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento dos Folders da consulta analitica Fluxo³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fc021ChFol(nFldDst,nFldAtu,oFolder,oDlg,aTotais,oSayTotal,oGetTotal,;
									nTotal,cPeriodo,aGetDb,aAlias,aHeader1,aHeader2,aHeader3,;
									aHeader4,aHeader5,aHeader6,aHeader7,aHeader8,aHeader9,aHeader10,;
									aHeader11,aHeader12)
Local lRetorno := .T.
Local oBold
Local nAscan

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Se o Folder Destino puder ser exibido, seleciona o arquivo
If aAlias[nFldDst] != Nil .And. Select(aAlias[nFldDst]) > 0
	DbSelectArea(aAlias[nFldDst])
	DbGoTop()
Else
	lRetorno := .F. // Desabilita o Folder
EndIf
If lRetorno
	IF ValType(aGetDb[nFldAtu]) == "O"
		aGetDb[nFldAtu]:oBrowse:lDisablePaint := .T.
	Endif
	Do Case
		Case ( nFldDst == 1 )
			aHeader := aClone(aHeader1)
			oSayTotal:cCaption := STR0078 //"Total de Titulos a Pagar"
		Case ( nFldDst == 2 )
			aHeader := aClone(aHeader2)
			oSayTotal:cCaption := STR0162 //"Total de Titulos a Receber"
		Case ( nFldDst == 3 )
			aHeader := aClone(aHeader3)
			oSayTotal:cCaption := STR0163 //"Total de Pedidos de Compra"
		Case ( nFldDst == 4 )
			aHeader := aClone(aHeader4)
			oSayTotal:cCaption := STR0164 //"Total de Pedidos de Venda"
		Case ( nFldDst == 5 )
			aHeader := aClone(aHeader5)
			oSayTotal:cCaption := STR0165 //"Total de Comissões"
		Case ( nFldDst == 6 )
			aHeader := aClone(aHeader6)
			oSayTotal:cCaption := STR0166 //"Total de Empréstimos"
		Case ( nFldDst == 7 )
			aHeader := aClone(aHeader7)
			oSayTotal:cCaption := STR0167 //"Total de Aplicações"
		Case ( nFldDst == 8 )
			aHeader := aClone(aHeader8)
			oSayTotal:cCaption := STR0196 // "Total de cheques pendentes"
		Case ( nFldDst == 9 )
			aHeader := aClone(aHeader9)
			oSayTotal:cCaption := "Total de Doctos. Transporte"
		Case ( nFldDst == 10 )
			aHeader := aClone(aHeader10)
			oSayTotal:cCaption := STR0246 //"Solicitações de Fundo"
		Case ( nFldDst == 11 )
			aHeader := aClone(aHeader11)
			oSayTotal:cCaption := STR0280 // "Ped. Compra de Máquinas"
		Case ( nFldDst == 12 )
			aHeader := aClone(aHeader12)
			oSayTotal:cCaption := STR0281 // "Ped. Venda de Máquinas"
	EndCase
	nAscan := Ascan( aTotais[nFldDst], {|e|Transform(e[1],"") = cPeriodo})
	nTotal := 0
	If nAscan > 0
		nTotal := aTotais[nFldDst][nAscan][2]
	Endif
	oGetTotal:Refresh()
	oSayTotal:Refresh()
	If ValType(aGetDb[nFldDst]) == "O"
		aGetDb[nFldDst]:oBrowse:lDisablePaint := .F.
		aGetDb[nFldDst]:oBrowse:Refresh(.T.)
	Endif
Endif
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021Edit ºAutor  ³Claudio D. de Souza º Data ³  04/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite a alteracao da data do credito/debito de um titulo º±±
±±º          ³ simulando a entrada/saida em nova data                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Proj(oDlg,aFluxo,aAliasAna,oFolder,aGetDb,aTotais,nBancos,;
								  nCaixas,nAtrReceber,nAtrPagar,nTotal,aPeriodo,nLimCred)
Local oDlgProj, nOpcA
LOCAL oBold
LOCAL cCarteira := oFolder:aDialogs[oFolder:nOption]:Cargo[1]
LOCAL nCampSin  := If(cCarteira=="R", ENTRADAS, SAIDAS)
LOCAL dDataProj := (aAliasAna[oFolder:nOption])->DataX
LOCAL aArea 	 := GetArea()
LOCAL nAscan, nIndPerAtu, nIndPerProj
LOCAL nValor    := (aAliasAna[oFolder:nOption])->Saldo

dbSelectArea(aAliasAna[oFolder:nOption])

DEFINE MSDIALOG oDlgProj FROM 0,0 TO 140,304 TITLE STR0174 Of oMainWnd PIXEL  //"Fluxo de Caixa - Projeção"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgProj SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgProj PIXEL
@ 3  ,37  SAY STR0175 Of oDlgProj PIXEL SIZE 35 ,9 FONT oBold //"Projeção de fluxo de caixa"
@ 19,050 SAY STR0026 			  OF oDlgProj PIXEL //"Valor"
@ 19,090 MSGET nValor WHEN .F. OF oDlgProj SIZE 60,9 PIXEL PICTURE "@E 999,999,999.99"
@ 29,050 SAY STR0184 		  OF oDlgProj PIXEL //"Data Atual"
@ 29,110 MSGET DataX WHEN .F.  OF oDlgProj SIZE 40,9 PIXEL
@ 39,050 SAY STR0176 	  OF oDlgProj PIXEL //"Projetar Para"
@ 39,110 MSGET dDataProj		  OF oDlgProj SIZE 40,9 PIXEL VALID dDataProj != (aAliasAna[oFolder:nOption])->DataX

DEFINE SBUTTON FROM 55,52 TYPE 1 ENABLE OF oDlgProj ACTION (nOpcA := 1, oDlgProj:End())
DEFINE SBUTTON FROM 55,90 TYPE 2 ENABLE OF oDlgProj ACTION (nOpcA := 0, oDlgProj:End())

ACTIVATE MSDIALOG oDlgProj CENTERED

If nOpcA == 1
	If ExistBlock("FC021PROJ")
		ExecBlock("FC021PROJ", .F. ,.F., { (aAliasAna[oFolder:nOption])->Apelido, (aAliasAna[oFolder:nOption])->CHAVE, dDataProj } )
	Endif
	// Pesquisa a data na matriz de referencia de periodos para localizar o fluxo pelo periodo
	// e nao pela data, se projetou para uma data dentro do periodo do Fluxo, atualiza as
	// informacoes na matriz de Fluxo, Totais e no arquivo temporario de fluxo analitico
	nIndPerAtu := Ascan(aPeriodo, {|e| e[1] == (aAliasAna[oFolder:nOption])->DataX})
	nIndPerProj:= Ascan(aPeriodo, {|e| e[1] == dDataProj})
	If nIndPerAtu > 0 .And. nIndPerProj > 0
		aGetDb[oFolder:nOption]:oBrowse:lDisablePaint := .T.
		// Subtrai da data atual
		nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPerAtu][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aFluxo[nAscan][nCampSin] -= nValor
		Endif
		// Subtrai a matriz de totais do fluxo analitico tambem
		nAscan := Ascan(aTotais[oFolder:nOption], {|e|aPeriodo[nIndPerAtu][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aTotais[oFolder:nOption][nAscan][2] -= nValor
			nTotal -= nValor
		Endif
		// Transfere o valor para a nova data
		nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPerProj][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aFluxo[nAscan][nCampSin] += nValor
		Endif
		nAscan := Ascan( aTotais[oFolder:nOption], {|e|aPeriodo[nIndPerProj][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aTotais[oFolder:nOption][nAscan][2] += nValor
		Endif
		DbSelectArea(aAliasAna[oFolder:nOption])
		nOrder := IndexOrd()
		DbSetOrder(0)
		RecLock(aAliasAna[oFolder:nOption], .F.)
		// Transfere o fluxo analitico para o novo periodo/Data
		(aAliasAna[oFolder:nOption])->DataX   := dDataProj
		(aAliasAna[oFolder:nOption])->Periodo := aPeriodo[nIndPerProj][2]
		MsUnlock()
		DbSetOrder(nOrder)
		CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nLimCred)
		aGetDb[oFolder:nOption]:oBrowse:lDisablePaint := .F.
		aGetDb[oFolder:nOption]:ForceRefresh()
	Else
		IW_MSGBOX(STR0185,STR0198,"STOP") //"Nao eh possivel projetar para uma data fora do periodo do fluxo de caixa"
	Endif
	/*
	If oDlg != Nil
   	aEval(oDlg:aControls, {|e| If(ValType(e) == "O", e:Refresh(), Nil) } )
	Endif
	*/
Endif
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaTmpAnaºAutor  ³Claudio D. de Souza º Data ³  08/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criar os arquivos analiticos do Fluxo de Caixa             º±±
±±º          ³ Parametro:                                                 º±±
±±º          ³ nArquivo   Numero do arquivo que sera criado               º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet                                                       º±±
±±º          ³ aRet[1] - Alias do arquivo temporario							  º±±
±±º          ³ aRet[2] - Nome do arquivo temporario                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION CriaTmpAna(nArquivo)
Local aCposAna
Local cAliasAna
Local cArqAna
Local aChave
Local aChave2
Local aChave3
Local aChave4
Local aRetDMS

aChave 	:= {"DATAX","NUMERO"}
aChave2	:= {"CHAVE"}

Do Case
Case nArquivo == 1 // Emprestimos
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EH_NUMERO")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EH_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EH_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EH_CONTA")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EH_SALDO")[1], TamSx3("EH_SALDO")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaEmp"  // Alias do arquivo analitico

	If _oFINC0214 <> Nil
		_oFINC0214:Delete()
		_oFINC0214 := Nil
	Endif

	_oFINC0214 := FWTemporaryTable():New( cAliasAna )
	_oFINC0214:SetFields(aCposAna)
	_oFINC0214:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC0214:Create()

Case nArquivo == 2 // Aplicacoes
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EH_NUMERO")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EH_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EH_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EH_CONTA")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EH_SALDO")[1], TamSx3("EH_SALDO")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaApl"  // Alias do arquivo analitico

	If _oFINC0215 <> Nil
		_oFINC0215:Delete()
		_oFINC0215 := Nil
	Endif

	_oFINC0215 := FWTemporaryTable():New( cAliasAna )
	_oFINC0215:SetFields(aCposAna)
	_oFINC0215:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC0215:Create()

Case nArquivo == 3 // Pedidos de compras
	aCposAna := {}
	aChave3 	:= { "DATAX", "NUMERO", "ITEM"}
	If lSC7Exclus
		AAdd(aCposAna, {"FILIAL", "C", TamSX3("C7_FILIAL")[1], 0})
		aChave4 	:= {"FILIAL", "DATAX", "NUMERO", "ITEM"}
	EndIf
	AAdd(aCposAna, { "Periodo",		"C", 25,						0})
	AAdd(aCposAna, { "DATAX", 		"D", 08, 						0})
	AAdd(aCposAna, { "NUMERO",		"C", TamSx3("C7_NUM")[1], 		0})
	AAdd(aCposAna, { "EMISSAO",		"D", 08, 						0})
	AAdd(aCposAna, { "CLIFOR",		"C", TamSX3("A2_COD")[1],		0})
	AAdd(aCposAna, { "TIPO",		"N", TamSX3("C7_TIPO")[1],		0})
	AAdd(aCposAna, { "ITEM",		"C", TamSX3("C7_ITEM")[1],		0})
	AAdd(aCposAna, { "NomCliFor",	"C", TamSX3("A2_NOME")[1],		0})
	AAdd(aCposAna, { "PRODUTO",		"C", TamSX3("C7_PRODUTO")[1],	0})
	AAdd(aCposAna, { "SALDO",		"N", Max(TamSx3("E1_SALDO")[1], TamSX3("E2_SALDO")[1]), TamSx3("E1_SALDO")[2]})
	AAdd(aCposAna, { "VALPAGANT",	"N", Max(TamSx3("E1_SALDO")[1] , TamSX3("E2_SALDO")[1]), TamSx3("E1_SALDO")[2]})
	AAdd(aCposAna, { "CHAVE",		"C", 40, 						0})
	AAdd(aCposAna, { "Apelido",		"C", 10, 						0})
	AAdd(aCposAna, { "CampoNulo",	"C", 01, 						0})
	AAdd(aCposAna, { "Flag",		"L", 01, 						0})
	AAdd(aCposAna, { "NATUREZA",	"C", TamSX3("A2_NATUREZ")[1],	0})

	cAliasAna := "cArqAnaPc"  // Alias do arquivo analitico

	If _oFINC0216 <> Nil
		_oFINC0216:Delete()
		_oFINC0216 := Nil
	Endif

	_oFINC0216 := FWTemporaryTable():New( cAliasAna )
	_oFINC0216:SetFields(aCposAna)
	_oFINC0216:AddIndex("1", aChave )
	_oFINC0216:AddIndex("2", aChave2 )	
	_oFINC0216:AddIndex("3", aChave3 )	
	If lSC7Exclus
		_oFINC0216:AddIndex("4", aChave4 )	
	EndIf
	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC0216:Create()

Case nArquivo == 4 // Pedidos de vendas
	aCposAna := {}
	Aadd( aCposAna, { "Periodo", "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"  , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO" , "C", TamSx3("C5_NUM")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO", "D",  8, 0 } )
	Aadd( aCposAna, { "CLIFOR" , "C", TamSx3("A1_COD")[1], 0 } )
	Aadd( aCposAna, { "TIPO"   , "C", TamSx3("C5_TIPO")[1], 0 } )
	Aadd( aCposAna, { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
	Aadd( aCposAna, { "LOJAENT", "C", TamSx3("C5_LOJAENT")[1], 0 } )
	Aadd( aCposAna, { "LOJACLI", "C", TamSx3("C5_LOJAENT")[1], 0 } )
	Aadd( aCposAna, { "SALDO"  , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "VALRECANT", "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )	// Valor Adiantamento.
	Aadd( aCposAna, { "CHAVE"  , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido", "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaPv"  // Alias do arquivo analitico

	If _oFINC0217 <> Nil
		_oFINC0217:Delete()
		_oFINC0217 := Nil
	Endif

	_oFINC0217 := FWTemporaryTable():New( cAliasAna )
	_oFINC0217:SetFields(aCposAna)
	_oFINC0217:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC0217:Create()

Case nArquivo == 6 // Cheques pendentes
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EF_NUM")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EF_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EF_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EF_CONTA")[1], 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EF_VALOR")[1], TamSx3("EF_VALOR")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaChq"  // Alias do arquivo analitico

	If _oFINC0218 <> Nil
		_oFINC0218:Delete()
		_oFINC0218 := Nil
	Endif

	_oFINC0218 := FWTemporaryTable():New( cAliasAna )
	_oFINC0218:SetFields(aCposAna)
	_oFINC0218:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC0218:Create()

Case nArquivo == 7 // Doctos. Transporte
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "FILDEB"  , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3("DT6_FILDEB")[1] ), 0 } )
	Aadd( aCposAna, { "FILDOC"  , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3("DT6_FILDOC")[1] ), 0 } )
	Aadd( aCposAna, { "DOC"   , "C", TamSx3("DT6_DOC")[1], 0 } )
	Aadd( aCposAna, { "SERIE" , "C", TamSx3("DT6_SERIE")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("DT6_VALTOT")[1], TamSx3("DT6_VALTOT")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaCtrc"  // Alias do arquivo analitico

	aChave := {"DATAX","FILDOC","DOC","SERIE"}

	If _oFINC0219 <> Nil
		_oFINC0219:Delete()
		_oFINC0219 := Nil
	Endif

	_oFINC0219 := FWTemporaryTable():New( cAliasAna )
	_oFINC0219:SetFields(aCposAna)
	_oFINC0219:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC0219:Create()

Case nArquivo == 8 // Solicitacoes de Fundo
	aCposAna := {}
	Aadd( aCposAna, { "Periodo"	,"C"	,25														,0						} )
	Aadd( aCposAna, { "DATAX"	,"D"	,08														,0						} )
	Aadd( aCposAna, { "FILIAL"  ,"C"	,If(lFWCodFil,FWGETTAMFILIAL,TamSx3("FJA_FILIAL")[1])	,0						} )
	Aadd( aCposAna, { "SOLFUN"	,"C"	,TamSX3("FJA_SOLFUN")[1]								,0						} ) //Codigo da Solic Fundo
	Aadd( aCposAna, { "FORNEC"	,"C"	,TamSX3("FJA_FORNEC")[1]								,0						} ) //Fornecedor
	Aadd( aCposAna, { "LOJA"	,"C"	,TamSX3("FJA_LOJA")[1]									,0						} ) //Loja
	Aadd( aCposAna, { "DATAPR"	,"D"	,08														,0						} ) //Data Prevista Pagamento
	Aadd( aCposAna, { "SALDO"	,"N"	,TamSx3("FJA_VALOR")[1]									,TamSx3("FJA_VALOR")[2]	} )
	Aadd( aCposAna, { "CHAVE"	,"C"	,40														,0						} )
	Aadd( aCposAna, { "Apelido"	,"C"	,10														,0						} )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaSol"  // Alias do arquivo analitico

	aChave := {"DATAX","SOLFUN"}

	If _oFINC021a <> Nil
		_oFINC021a:Delete()
		_oFINC021a := Nil
	Endif

	_oFINC021a := FWTemporaryTable():New( cAliasAna )
	_oFINC021a:SetFields(aCposAna)
	_oFINC021a:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC021a:Create()

Case nArquivo == 09 // Pedido de Compra de Maquinas - DMS
	aRetDMS := VM210CriaTmpAna("MAQ_COMPRA")
	aCposAna  := aRetDMS[1]
	cAliasAna := aRetDMS[2]

	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	If _oFINC021e <> Nil
		_oFINC021e:Delete()
		_oFINC021e := Nil
	Endif
	_oFINC021e := FWTemporaryTable():New( cAliasAna )
	_oFINC021e:SetFields(aCposAna)
	_oFINC021e:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC021e:Create()

Case nArquivo == 10 // Pedido de Compra de Maquinas - DMS
	aRetDMS := VM210CriaTmpAna("MAQ_VENDA")
	aCposAna  := aRetDMS[1]
	cAliasAna := aRetDMS[2]

	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	If _oFINC021f <> Nil
		_oFINC021f:Delete()
		_oFINC021f := Nil
	Endif
	_oFINC021f := FWTemporaryTable():New( cAliasAna )
	_oFINC021f:SetFields(aCposAna)
	_oFINC021f:AddIndex("1", aChave )

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oFINC021f:Create()

EndCase


Return {cAliasAna,cArqAna}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fc021Tipo ºAutor  ³Wagner Mobile Costa º Data ³  06/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se o tipo indicado na simulacao eh Receita/Despesa  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc021Tipo

Local lRet := .T.

If ! M->_SI_TIPO $ "RD"
	IW_MsgBox(STR0149,STR0198,"STOP") //"E necessario informar um tipo válido de simulação (R=Receita ou D=Despesa)"
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Fc021Excel ³ Autor ³ Claudio D. de Souza  ³ Data ³ 06-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exporta a planilha de trabalho para o Excel.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FINC021                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Excel(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico)

Local nOpcao := 0

Default lAnalitico := .F.

If cPaisLoc == "ARG"

	nOpcao := Aviso(STR0053, STR0251,{STR0252,STR0253,STR0254} ,1) //"Exportar para Excel"###"Selecione a forma como os valores serão apresentados."###"Sintética"###"Análitica"###"Cancelar"

	If nOpcao == 1 //Sintética
		Processa( { || Fc021ProcEx(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar) } )
	ElseIf nOpcao == 2 //Analítica
		If lAnalitico
			MsgRun(STR0221,"", {|| Fc021ExcAn()}) //"Aguarde! Gerando arquivo de integração com Excel..."
		Else
			MsgAlert(STR0261+STR0023) //"Processo analitico não habilitado, verifique na definição da consulta o campo: "###"Processa analitico"
		EndIf
	EndIf

Else
	Processa( { || Fc021ProcEx(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar) } )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Fc021ProcEx³ Autor ³ Claudio D. de Souza  ³ Data ³ 25-04-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Processa a exportacao da planilha de trabalho para o Excel.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FINC021                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021ProcEx(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar)
LOCAL cDirDocs   := MsDocPath()
Local aStru		:= {}
Local cArquivo := CriaTrab(,.F.)
Local cPath		:= AllTrim(GetTempPath())
Local oExcelApp
Local nHandle
Local cCrLf 	:= Chr(13) + Chr(10)
Local nX
Local cLib 
Local nTpRemote	:= GetRemoteType(@cLib)
Local lRet	:= .F.

aStru := {	{STR0229	, "C", 30, 0},; //"Periodo"
			 	{STR0043, "N", 17, 2},; //"Entradas"
			 	{STR0044	, "N", 17, 2},; //"Saidas"
			 	{STR0045	, "N", 17, 2},; //"Saldo do Dia"
			 	{STR0046	, "N", 17, 2},; //"Var.Dia"
			 	{STR0047	, "N", 17, 2},; //"Entr.Acumulada"
			 	{STR0048	, "N", 17, 2},; //"Saida Acumulada"
			 	{STR0049	, "N", 17, 2},; //"Saldo Acumulado"
			 	{STR0050	, "N", 17, 2}} //"Var. Acumulada"

ProcRegua(Len(aFluxo)+2)

nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)

If nHandle > 0

	// Grava o cabecalho do arquivo
	IncProc(STR0221) // "Aguarde! Gerando arquivo de integração com Excel..."
	aEval(aStru, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
	fWrite(nHandle, cCrLf ) // Pula linha

	For nX := 1 to Len(aFluxo)
		IncProc(STR0221) // "Aguarde! Gerando arquivo de integração com Excel..."
		fWrite(nHandle, Transform(aFluxo[nX,DATAFLUXO],"") + ";" )
		fWrite(nHandle, Transform(aFluxo[nX,ENTRADAS], "@E 999,999,999,999.99" )	+ ";" )
		fWrite(nHandle, Transform(aFluxo[nX,SAIDAS], "@E 999,999,999,999.99" ) + ";" )
		fWrite(nHandle, Transform(aFluxo[nX,SALDODIA], "@E 999,999,999,999.99" ) + ";" )
		fWrite(nHandle, Transform(aFluxo[nX,VARIACAODIA] / 100, "@E 999,999.999" ) + ";" )
		fWrite(nHandle, Transform(aFluxo[nX,ENTRADASACUMULADAS], "@E 999,999,999,999.99" ) + ";" )
		fWrite(nHandle, Transform(aFluxo[nX,SAIDASACUMULADAS], "@E 999,999,999,999.99" ) + ";" )
		fWrite(nHandle, Transform(aFluxo[nX,SALDOACUMULADO], "@E 999,999,999,999.99" ) + ";" )
		fWrite(nHandle, Transform(aFluxo[nX,VARIACAOACUMULADA] / 100, "@E 999,999.999" ) + ";" )
		fWrite(nHandle, cCrLf ) // Pula linha
	Next

	IncProc(STR0222) //"Aguarde! Abrindo o arquivo..."

	fClose(nHandle)
	lRet := CpyS2T( cDirDocs+"\"+cArquivo+".CSV" , Iif(nTpRemote==2,"l:","")+cPath, .T. )
	
	If nTpRemote <> 2	//Se não for LINUX ou MAC
		If !__lHTML .AND. ! ApOleClient( 'MsExcel' ) 
			MsgAlert( STR0190 ) //'MsExcel nao instalado'
			Return
		EndIf

		If !__lHTML
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
			oExcelApp:SetVisible(.T.)
		EndIf
	Else
		If lRet
			MsgAlert( STR0285 +cPath+cArquivo+".CSV")  // "Arquivo copiado para a pasta:"
		EndIf
	EndIf
Else
	MsgAlert( STR0223 ) // "Falha na criação do arquivo"
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021Filtro³ Autor ³ Claudio D. de Souza  ³ Data ³ 18/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem o filtro do usuario para os dados do SE1 e do SE2.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Filtro(cFilterSe1,cFilterSe2)
Local nOpc := 1
Local oDLg
Local cAlias

DEFINE MSDIALOG oDlg FROM 90,11 TO 260,321 TITLE STR0191 PIXEL

@ 10,13 TO 53, 142 LABEL STR0192 OF oDlg	PIXEL
@ 24,27 RADIO nOpc PROMPT STR0193,STR0194 SIZE  60,9 OF oDlg PIXEL

DEFINE SBUTTON FROM 60, 85 TYPE 1 ENABLE OF oDlg ACTION (cAlias := If(nOpc=1,"SE1","SE2"), dbSelectArea(cAlias), If(nOpc=1,cFilterSe1,cFilterSe2) := BuildExpr(cAlias,oDlg ),oDlg:End())
DEFINE SBUTTON FROM 60,115 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PesqUsu   ºAutor  ³Claudio D. de Souza º Data ³  18/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa usuario no arquivo de param. da rotina            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesqUsu(nHandle,cLog,nOffSet)
Local lAchou := .F.
While fReadLn(nHandle,@cLog,100)
	nOffSet := fSeek(nHandle,0,1) // Retorna o offset atual (posicao do arquivo)
	If Left(cLog,20)==Pad(Left(cUsuario,19),20)
		lAchou := .T.
		Exit
	Endif
EndDo

Return lAchou


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021ImpSi ³ Autor ³ Claudio D. de Souza  ³ Data ³ 16/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime a Simula‡ao da mem¢ria.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021ImpSi()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1 := STR0204 //"Este programa irá imprimir a simulação atualmente em"
Local cDesc2 := STR0205 //"uso."
Local cDesc3 := ""
Local cString:= "SE1"

PRIVATE nomeprog :="FINC021"
PRIVATE cabec1,cabec2,nLastKey:=0,titulo,wnrel,tamanho:="P"
PRIVATE aReturn:={STR0133,1,STR0134,1,2,1,"",1} //"Zebrado"###"Administracao"


If Empty( aCols[1,2] ) // Valor em branco
	Return Nil
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo:= STR0206 //"Simulação do Fluxo de Caixa"
cabec1:= STR0207 //"Data                   Valor  Tipo   Histórico"
cabec2:= ""

wnrel:="FINC021"           //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| Fc021ISiOk(@lEnd,wnRel,cString)},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021ImpSiOk³ Autor ³ Claudio D. de Souza  ³ Data ³ 18/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime a Simula‡ao da mem¢ria.			  				     		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC020																	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc021ISiOk(lEnd,wnRel,cString )
Local nLaco := 0
Local nTotReceitas := 0
Local nTotDespesas := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt  := Space(10)
cbcont := 00
li 	 := 80
m_pag  := 01


SetRegua( Len( aCols ) )

For nLaco := 1 to Len( aCols )

	IF lEnd
		@PROW()+1,001 PSAY STR0139 //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF

	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
	EndIF

	IncRegua()

	@li,00 PSay aCols[ nLaco,1 ]
	@Prow(),Pcol() + 2	PSay aCols[ nLaco,3 ] Picture TM(aCols[ nLaco,2 ],18)
	@Prow(), 		  31 	PSay aCols[ nLaco,2 ]
	@Prow(),			  37	PSay aCols[ nLaco,4 ]
	li ++

	If Left( aCols[nLaco,2] , 1 ) == "R"
		nTotReceitas += aCols[ nLaco,3 ]
	Else
		nTotDespesas += aCols[ nLaco,3 ]
	Endif
Next

IF li+4 > 58
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
EndIF

@li++,00 PSay Repl("-",80)
@li++,00 PSay STR0208 //"Total de Receitas : "
@Prow(),PCol()+2 PSay nTotReceitas Picture TM(nTotReceitas,18)
@li++,00 PSay STR0209 //"Total de Despesas : "
@prow(),PCol()+2 PSay nTotDespesas Picture TM(nTotDespesas,18)
@li++,00 PSay Repl("-",80)

roda(cbcont,cbtxt)

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fc021Val   ³ Autor ³ Leonardo Gentile     ³ Data ³ 02/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor do argumento passado considerando a picture ³±±
±±³          ³ no formato AMERICAN (9,999.99) ou DEFAULT (9.999,99)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ FINC021													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Val( cTexto)
Local nValor
Local cDec, cMil

cTexto 	:= AllTrim( cTexto)
cDec := Subs( cTexto, Len(cTexto)-2, 1)
cMil := If( cDec=".",",",".")

nValor := Val( StrTran( StrTran( cTexto, cMil, ""), cDec, ".") )

Return nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fc021Ctrc  ³ Autor ³ Claudio D. de Souza	³ Data ³ 11/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa os documentos de transporte a serem exibidos no    ³±±
±±³          ³ fluxo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ FINC021														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Ctrc( cAliasCtrc, dUltData, lConsFil, cFilDe, cFilAte, lAnalitico, aFluxo, nMoeda, aTotais, aPeriodo, lFiliais )
Local nValDoc
Local cIdentific
Local nAscan

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConsFil
   cFilDe  := xFilial("DT6")
   cFilAte := xFilial("DT6")
EndIf

aStru     := DT6->( dbStruct() )
cAliasTrb := "FINC021"

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName( "DT6" ) + " DT6 "
cQuery += "WHERE "

If lFiliais
	cQuery += "DT6.DT6_FILIAL IN(" + cLisFil + ") AND "
Else
	cQuery += "DT6.DT6_FILIAL >= '" + cFilDe + "' AND "
	cQuery += "DT6.DT6_FILIAL <= '" + cFilAte + "' AND "
EndIf

// Doctos. nao faturados
cQuery += "DT6.DT6_PREFIX = '" + Space( Len( DT6->DT6_PREFIX ) ) + "' AND "
cQuery += "DT6.DT6_NUM = '" + Space( Len( DT6->DT6_NUM ) ) + "' AND "
cQuery += "DT6.DT6_TIPO = '" + Space( Len( DT6->DT6_TIPO ) ) + "' AND "
cQuery += "DT6.DT6_MOEDA = " + AllTrim( Str( nMoeda, 2, 0 ) ) + " AND "
cQuery += "DT6.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})

While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc("Processando Doctos. de Transporte")
	dDataTrab := DataValida((cAliasTrb)->DT6_VENCTO,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a data de vencto. nao ultrapassar a ultima data do relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dDataTrab <= dUltData
		nValDoc := xMoeda( (cAliasTrb)->DT6_VALTOT, (cAliasTrb)->DT6_MOEDA, nMoeda )
		If Abs(nValDoc) > 0.0001
			// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
			nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
			// Verifica se esta no periodo solicitado
			If nAscan > 0
				aFluxo[nAscan][ENTRADAS] += nValDoc
			Endif
			If lAnalitico .And. nAscan > 0
				RecLock(cAliasCtrc,.T.)
				(cAliasCtrc)->Datax		:= dDataTrab
				(cAliasCtrc)->Periodo	:= aPeriodo[nAscan][2]
				(cAliasCtrc)->FILDEB		:= (cAliasTrb)->DT6_FILDEB
				(cAliasCtrc)->FILDOC		:= (cAliasTrb)->DT6_FILDOC
				(cAliasCtrc)->DOC			:= (cAliasTrb)->DT6_DOC
				(cAliasCtrc)->SERIE		:= (cAliasTrb)->DT6_SERIE
				(cAliasCtrc)->EMISSAO	:= (cAliasTrb)->DT6_DATEMI
				cIdentific :=	xFilial("DT6")+;
								   (cAliasTrb)->DT6_FILDOC	+;
								   (cAliasTrb)->DT6_DOC		+;
								   (cAliasTrb)->DT6_SERIE
				(cAliasCtrc)->Chave     := cIdentific
				(cAliasCtrc)->SALDO     := nValDoc
				(cAliasCtrc)->Apelido   := "DT6"
				MsUnlock()
				// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
				// da data de trabalho.
				nAscan := Ascan( aTotais[9], {|e| e[1] == dDataTrab})
				If nAscan == 0
					Aadd( aTotais[9], {dDataTrab,nValDoc})
				Else
					aTotais[9][nAscan][2] += nValDoc // Contabiliza os totais de Doctos.
				Endif
			Endif
		EndIf
	Endif
	(cAliasTrb)->(dbSkip())
Enddo

dbSelectArea(cAliasTrb)
dbCloseArea()
dbSelectArea("DT6")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FinTamSXG ³ Autor ³ Totvs					  ³ Data ³ 27/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SXD                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FINC021                                   				        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinTamSXG(cGrupo,nTamPad)
Local aRet

DbSelectArea("SXG")
DbSetOrder(1)

IF DbSeek(cGrupo)
	aRet := TamSXG(cGrupo)
Else
	aRet := {nTamPad,"@!",nTamPad,nTamPad}
Endif

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FinJobInd ºAutor  ³Marcelo Akama		 º Data ³  19/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job                                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinJobInd(cEmpX,cFilDe,cFilAte,dDataDe,dDataAte,cAliasPrv,cMoedaDe,cMoedaAte)
Local lRet		 := .T.

DEFAULT cMoedaDe  := '01'
DEFAULT cMoedaAte := '01'

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilDe,,,,,)

lRet := FinGerInd(dDataDe,dDataAte,cAliasPrv,cFilDe,cFilAte,cMoedaDe,cMoedaAte)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FinGerInd ºAutor  ³Marcelo Akama		 º Data ³  19/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função geradora de fluxo de caixa                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinGerInd( dDataDe, dDataAte, cAliasPrv, cFilDe, cFilAte, cMoedaDe, cMoedaAte, lFiliais, aSelFil )
Local lRet		:= .T.
Local aSM0		:= AdmAbreSM0()
Local cFilOri	:= cFilAnt
Local aAux		:= {}
Local aMoedas	:= {}
Local aStruSQL	:= {}
Local aTotais	:= {{},{},{},{},{},{},{},{}, {}}
Local aPeriodo	:= {}
Local aFluxo	:= {}
Local cMoeda	:= ''
Local nContFil	:= 0
Local nx		:= 0
Local dDtBasOri	:= dDataBase
Local aTmpAna
Local cAliasPc
Local cArqAnaPc
Local cAliasPv
Local cArqAnaPv
Local nDias
Local dData
Local cFilialDe
Local cFilialAte

Default cMoedaDe	:= '01'
Default cMoedaAte	:= '01'

If Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return .F.
EndIf

cFilialDe	:= IIf(cFilDe==nil,cFilAnt,cFilDe)
cFilialAte	:= IIf(cFilAte==nil,cFilAnt,cFilAte)

dDataBase := dDataDe

aAux := GetMoedas()
ASort(aAux)

For nX := 1 to Len(aAux)
	cMoeda := Left(aAux[nX],2)
	If cMoeda >= cMoedaDe .And. cMoeda <= cMoedaAte
		AADD(aMoedas, Val(cMoeda))
	EndIf
Next nX

nDias := dDataAte - dDataDe + 1
If nDias <= 0
	nDias := 1
EndIf

// Gera os registros para todas as datas do periodo, inclusive a database
For nX := 1 To nDias
	dData := dDataDe+nX-1
	TemFluxoData(dData,aFluxo)
	TemFluxoData(dData,aPeriodo)
Next
// Monta os periodos na matriz para ser utilizada na simulacao e na projecao
MontaPeriodo(aPeriodo,STR0001) //"01 Diario"

//Cria Tabela Temporária Fluxo de Caixa Previsto
aStruSQL := {}
AADD(aStruSQL,{"HLH_EMPRES","C",02,00})
AADD(aStruSQL,{"HLH_FILIAL","C",TamSx3("E1_FILIAL")[1],00})
AADD(aStruSQL,{"HLH_ORIGEM","C",10,00})
AADD(aStruSQL,{"HLH_ESPDOC","C",TamSx3("E1_TIPO")[1],00})
AADD(aStruSQL,{"HLH_CLIENT","C",TamSx3("A1_COD")[1],00})
AADD(aStruSQL,{"HLH_LJCLI" ,"C",TamSx3("A1_LOJA")[1],00})
AADD(aStruSQL,{"HLH_FORNEC","C",TamSx3("A2_COD")[1],00})
AADD(aStruSQL,{"HLH_LJFORN","C",TamSx3("A2_LOJA")[1],00})
AADD(aStruSQL,{"HLH_MOEDA" ,"N",TamSx3("E1_MOEDA")[1],00})
AADD(aStruSQL,{"HLH_MODALI","C",TamSx3("FRV_DESCRI")[1],00})
AADD(aStruSQL,{"HLH_TIPMOV","C",10,00})
AADD(aStruSQL,{"HLH_ESPREC","C",TamSx3("E1_TIPO")[1],00})
AADD(aStruSQL,{"HLH_BANCO" ,"C",TamSx3("A6_COD")[1],00})
AADD(aStruSQL,{"HLH_DATA"  ,"D",08,00})
AADD(aStruSQL,{"HLH_SERDOC","C",TamSx3("E1_PREFIXO")[1],00})
AADD(aStruSQL,{"HLH_NUMDOC","C",TamSx3("E1_NUM")[1],00})
AADD(aStruSQL,{"HLH_PARCEL","C",TamSx3("E1_PARCELA")[1],00})
AADD(aStruSQL,{"HLH_VPRENT","N",TamSx3("E1_VALOR")[1],TamSx3("E1_VALOR")[2]})
AADD(aStruSQL,{"HLH_VPRSAI","N",TamSx3("E1_VALOR")[1],TamSx3("E1_VALOR")[2]})

If Select(cAliasPrv) > 0
	(cAliasPrv)->(dbCloseArea())
EndIf

MsErase(cAliasPrv)
MsCreate(cAliasPrv, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasPrv, cAliasPrv, .T., .F. )

If lFiliais
	aSM0 		:= aClone( aSelFil )
	cFilialDe	:= aSM0[1]
	cFilialAte	:= aSM0[Len( aSM0 )]
EndIf

For nX := 1 To Len( aMoedas )

	For nContFil := 1 to Len( aSM0 )

		If !lFiliais
			If aSM0[nContFil][SM0_CODFIL] < cFilialDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilialAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
				Loop
			EndIf
		EndIf

		cFilAnt := aSM0[nContFil][SM0_CODFIL]

		// Aplicacoes/Emprestimos e Cheques nao liberados
		lRet := GeraAplChq(dDataDe,dDataAte,aMoedas[nX],cAliasPrv)

		If !lRet
			Exit
		EndIf
	Next nContFil

	If !lRet
		Exit
	EndIf

	// Titulos a Receber
	GeraTmpJob("SE1",7,dDataDe,dDataAte,cFilDe,cFilAte,aMoedas[nX],cAliasPrv)

	// Titulos a Pagar
	GeraTmpJob("SE2",3,dDataDe,dDataAte,cFilDe,cFilAte,aMoedas[nX],cAliasPrv)

	// Pedido de Compra
	aCompras	:= {}
	adCompras	:= {}
	MV_PAR03	:= 2
	MV_PAR02	:= aMoedas[nX]
	aTmpAna		:= CriaTmpAna(3) // Cria o arquivo temporario analitico
	cAliasPc	:= aTmpAna[1]
	cArqAnaPc	:= aTmpAna[2]
	cFilialDe	:= IIf( cFilDe == nil, xFilial("SC7"), cFilDe )
	cFilialAte	:= IIf( cFilAte == nil, xFilial("SC7"), cFilAte )
	Fc020Compra(cAliasPc, aTotais, .T., aMoedas[nX], aPeriodo, cFilialDe, cFilialAte, "3",,, aSelFil)
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSelectArea(cAliasPc)
	dbGoTop()

	Do While !Eof()
		dbSelectArea("SC7")
		MsSeek( (cAliasPc)->CHAVE )
		dbSelectArea(cAliasPrv)
		RecLock(cAliasPrv,.T.)
		(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
		(cAliasPrv)->HLH_FILIAL	:= Left((cAliasPc)->CHAVE,len(xFilial("SC7")))
		(cAliasPrv)->HLH_ORIGEM	:= '05'
		(cAliasPrv)->HLH_ESPDOC	:= ''
		(cAliasPrv)->HLH_FORNEC	:= (cAliasPc)->CLIFOR
		(cAliasPrv)->HLH_LJFORN	:= SC7->C7_LOJA
		(cAliasPrv)->HLH_CLIENT	:= ''
		(cAliasPrv)->HLH_LJCLI	:= ''
		(cAliasPrv)->HLH_MOEDA	:= aMoedas[nX]
		(cAliasPrv)->HLH_MODALI	:= ''
		(cAliasPrv)->HLH_TIPMOV	:= '3'
		(cAliasPrv)->HLH_ESPREC	:= ''
		(cAliasPrv)->HLH_BANCO	:= ''
		(cAliasPrv)->HLH_DATA	:= (cAliasPc)->DATAX
		(cAliasPrv)->HLH_SERDOC	:= ''
		(cAliasPrv)->HLH_NUMDOC	:= (cAliasPc)->NUMERO
		(cAliasPrv)->HLH_PARCEL	:= ''
		(cAliasPrv)->HLH_VPRENT	:= 0.00
		(cAliasPrv)->HLH_VPRSAI	:= (cAliasPc)->SALDO
		MsUnlock()
		dbSelectArea(cAliasPc)
		dbSkip()
	EndDo
	(cAliasPc)->(DbCloseArea())

	//Deleta tabela temporária no banco de dados
	If _oFINC0216 <> Nil
		_oFINC0216:Delete()
		_oFINC0216 := Nil
	Endif

	dbSelectArea(cAliasPrv)

	// Pedido de Venda
	aVendas  := {}
	adVendas := {}
	MV_PAR03 := 2
	MV_PAR02 := aMoedas[nX]
	aTmpAna := CriaTmpAna(4)// Cria o arquivo temporario analitico
	cAliasPv:= aTmpAna[1]
	cArqAnaPv:=aTmpAna[2]
	cFilialDe	:= IIf(cFilDe==nil,xFilial("SC6"),cFilDe)
	cFilialAte	:= IIf(cFilAte==nil,xFilial("SC6"),cFilAte)
	Fc020Venda(, cAliasPv, aTotais, .T., aMoedas[nX], aPeriodo, cFilialDe, cFilialAte,,,, aSelFil)
	dbSelectArea(cAliasPv)
	dbGoTop()
	Do While !Eof()
		dbSelectArea(cAliasPrv)
		RecLock(cAliasPrv,.T.)
		(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
		(cAliasPrv)->HLH_FILIAL	:= Left((cAliasPv)->CHAVE,len(xFilial("SC5")))
		(cAliasPrv)->HLH_ORIGEM	:= '04'
		(cAliasPrv)->HLH_ESPDOC	:= ''
		(cAliasPrv)->HLH_FORNEC	:= ''
		(cAliasPrv)->HLH_LJFORN	:= ''
		(cAliasPrv)->HLH_CLIENT	:= (cAliasPv)->CLIFOR
		(cAliasPrv)->HLH_LJCLI	:= (cAliasPv)->LOJACLI
		(cAliasPrv)->HLH_MOEDA	:= aMoedas[nX]
		(cAliasPrv)->HLH_MODALI	:= ''
		(cAliasPrv)->HLH_TIPMOV	:= '2'
		(cAliasPrv)->HLH_ESPREC	:= ''
		(cAliasPrv)->HLH_BANCO	:= ''
		(cAliasPrv)->HLH_DATA	:= (cAliasPv)->DATAX
		(cAliasPrv)->HLH_SERDOC	:= ''
		(cAliasPrv)->HLH_NUMDOC	:= (cAliasPv)->NUMERO
		(cAliasPrv)->HLH_PARCEL	:= ''
		(cAliasPrv)->HLH_VPRENT	:= (cAliasPv)->SALDO
		(cAliasPrv)->HLH_VPRSAI	:= 0.00
		MsUnlock()
		dbSelectArea(cAliasPv)
		dbSkip()
	EndDo
	(cAliasPv)->(DbCloseArea())


	//Deleta tabela temporária no banco de dados
	If _oFINC0217 <> Nil
		_oFINC0217:Delete()
		_oFINC0217 := Nil
	Endif

	// Comissões
	aArqCo := Array(4)
	cFilialDe	:= IIf(cFilDe==nil,xFilial("SE3"),cFilDe)
	cFilialAte	:= IIf(cFilAte==nil,xFilial("SE3"),cFilAte)
	aArqCo := Fc021Comis(dDataAte,.T.,cFilialDe,cFilialAte,aFluxo,aMoedas[nX],.T.,aTotais,aPeriodo)
	dbSelectArea("SE3")
	dbSetOrder(1)
	dbSelectArea(aArqCo[4])
	dbGoTop()
	Do While !Eof()
		dbSelectArea("SE3")
		MsSeek( RTrim((aArqCo[4])->Chave) )
		dbSelectArea(cAliasPrv)
		RecLock(cAliasPrv,.T.)
		(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
		(cAliasPrv)->HLH_FILIAL	:= (aArqCo[4])->FILIAL
		(cAliasPrv)->HLH_ORIGEM	:= '03'
		(cAliasPrv)->HLH_ESPDOC	:= ''
		(cAliasPrv)->HLH_FORNEC	:= ''
		(cAliasPrv)->HLH_LJFORN	:= ''
		(cAliasPrv)->HLH_CLIENT	:= SE3->E3_CODCLI
		(cAliasPrv)->HLH_LJCLI	:= SE3->E3_LOJA
		(cAliasPrv)->HLH_MOEDA	:= aMoedas[nX]
		(cAliasPrv)->HLH_MODALI	:= ''
		(cAliasPrv)->HLH_TIPMOV	:= '3'
		(cAliasPrv)->HLH_ESPREC	:= ''
		(cAliasPrv)->HLH_BANCO	:= ''
		(cAliasPrv)->HLH_DATA	:= (aArqCo[4])->DATAX
		(cAliasPrv)->HLH_SERDOC	:= (aArqCo[4])->PREFIXO
		(cAliasPrv)->HLH_NUMDOC	:= (aArqCo[4])->NUMERO
		(cAliasPrv)->HLH_PARCEL	:= (aArqCo[4])->PARCELA
		(cAliasPrv)->HLH_VPRENT	:= 0.00
		(cAliasPrv)->HLH_VPRSAI	:= (aArqCo[4])->SALDO
		MsUnlock()
		dbSelectArea(aArqCo[4])
		dbSkip()
	EndDo
	(aArqCo[4])->(DbCloseArea())

	//Deleta tabela temporária
	If _oFINC0213 <> Nil
		_oFINC0213:Delete()
		_oFINC0213 := Nil
	Endif

	// Doctos. de Transporte
	aTmpAna := CriaTmpAna(7)// Cria o arquivo temporario analitico
	cFilialDe	:= IIf(cFilDe==nil,xFilial("DT6"),cFilDe)
	cFilialAte	:= IIf(cFilAte==nil,xFilial("DT6"),cFilAte)
	Fc021Ctrc(aTmpAna[1],dDataAte,.T.,cFilialDe,cFilialAte,.T.,aFluxo,aMoedas[nX],aTotais,aPeriodo)
	dbSelectArea(aTmpAna[1])
	dbGoTop()
	Do While !Eof()
		dbSelectArea(cAliasPrv)
		RecLock(cAliasPrv,.T.)
		(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
		(cAliasPrv)->HLH_FILIAL	:= Left((aTmpAna[1])->CHAVE,len(xFilial("DT6")))
		(cAliasPrv)->HLH_ORIGEM	:= '09'
		(cAliasPrv)->HLH_ESPDOC	:= ''
		(cAliasPrv)->HLH_FORNEC	:= ''
		(cAliasPrv)->HLH_LJFORN	:= ''
		(cAliasPrv)->HLH_CLIENT	:= ''
		(cAliasPrv)->HLH_LJCLI	:= ''
		(cAliasPrv)->HLH_MOEDA	:= aMoedas[nX]
		(cAliasPrv)->HLH_MODALI	:= ''
		(cAliasPrv)->HLH_TIPMOV	:= '3'
		(cAliasPrv)->HLH_ESPREC	:= ''
		(cAliasPrv)->HLH_BANCO	:= ''
		(cAliasPrv)->HLH_DATA	:= (aTmpAna[1])->DATAX
		(cAliasPrv)->HLH_SERDOC	:= ''
		(cAliasPrv)->HLH_NUMDOC	:= (aTmpAna[1])->NUMERO
		(cAliasPrv)->HLH_PARCEL	:= ''
		(cAliasPrv)->HLH_VPRENT	:= 0.00
		(cAliasPrv)->HLH_VPRSAI	:= (aTmpAna[1])->SALDO
		MsUnlock()
		dbSelectArea(aTmpAna[1])
		dbSkip()
	EndDo
	(aTmpAna[1])->(DbCloseArea())


	//Deleta tabela temporária no banco de dados
	If _oFINC0219 <> Nil
		_oFINC0219:Delete()
		_oFINC0219 := Nil
	Endif

Next nX


dDataBase := dDtBasOri
cFilAnt := cFilOri

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraAplChqºAutor  ³Marcelo Akama		 º Data ³  19/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função geradora de aplcacoes/emprestimos e cheques nao lib º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraAplChq(dDataDe,dDataAte,nMoeda,cAliasPrv)
Local lRet		:= .T.
Local cAplCotas	:= GetMv("MV_APLCAL4")
Local lLibCheq	:= GetMv("MV_LIBCHEQ")=="N" // Para controlar os cheques pendentes de liberacao.
Local dData
Local nDias
Local nX
Local aCalc
Local nValor
Local cFiltro
Local cIndTmp
Local nIndSEF

nDias := dDataAte - dDataDe + 1
If nDias <= 0
	nDias := 1
EndIf

For nX := 1 to nDias
	dData := dDataDe + nX - 1

	// Emprestimos / Aplicacoes
	dbSelectArea("SEH")
	dbSetOrder(2)
	dbSeek(xFilial("SEH")+"A",.T.)
	Do While !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A"
		If SEH->EH_APLEMP == "EMP" // Emprestimos
			If ( Empty(SEH->EH_DATARES) .And. nX==1 ) .Or. ( SEH->EH_DATARES == dData )
				dA181DtApr	:= dData
				nA181VlMoed	:= RecMoeda(dA181DtApr,SEH->EH_MOEDA)
				nA181SPCP2	:= 0
				nA181SPLP2	:= 0
				nA181SPCP1	:= 0
				nA181SPLP1	:= 0
				nA181SJUR2	:= 0
				nA181SJUR1	:= 0
				nA181SVCLP	:= 0
				nA181SVCCP	:= 0
				nA181SVCJR	:= 0
				nA181VPLP1 	:= 0
				nA181VPCP1 	:= 0
				nA181VJUR1 	:= 0
				nA181VVCLP 	:= 0
				nA181VVCCP 	:= 0
				nA181VVCJR 	:= 0
				nA181VPLP2 	:= 0
				nA181VlDeb  := 0

				aCalc		:= Fa171Calc(dData,SEH->EH_SALDO,.F.)
				nA181SPCP2	:= Round(SEH->EH_SALDO * SEH->EH_PERCPLP/100 , TamSX3("EH_SALDO")[2])
				nA181SPLP2	:= SEH->EH_SALDO - nA181SPCP2
				nA181SPLP1	:= SEH->EH_VLCRUZ
				nA181SPCP1	:= Round(SEH->EH_VLCRUZ * SEH->EH_PERCPLP/100,TamSX3("EH_SALDO")[2])
				nA181SPLP1	:= SEH->EH_VLCRUZ - nA181SPCP1
				nA181SJUR2	:= aCalc[1,2]
				nA181SJUR1	:= aCalc[2,2]
				nA181SVCLP	:= aCalc[2,3]
				nA181SVCCP	:= aCalc[2,4]
				nA181SVCJR	:= aCalc[2,5]
				nA181VlIRF	:= 0
				nA181VLDES	:= 0
				nA181VLGAP	:= 0
				nA181STOT1	:= nA181SPLP1+nA181SPCP1+nA181SJUR1+nA181SVCLP+nA181SVCCP+nA181SVCJR
				nA181STOT2	:= nA181SPLP2+nA181SPCP2+nA181SJUR2
				nA181VPLP1	:= nA181SPLP1
				nA181VPCP1	:= nA181SPCP1
				nA181VPLP2	:= nA181SPLP2
				nA181VPCP2	:= nA181SPCP2
				nA181VJUR1	:= nA181SJUR1
				nA181VJUR2	:= nA181SJUR2
				nA181VVCLP	:= nA181SVCLP
				nA181VVCCP	:= nA181SVCCP
				nA181VVCJR	:= nA181SVCJR
				nA181VTOT1	:= nA181STOT1
				nA181VTOT2	:= nA181STOT2

				Fa181Valor(,"DA181DTAPR") // Atualiza as variaveis PRIVATES do calculo do emprestimo
				nValor := xMoeda(nA181VlDeb,1,nMoeda,dData)
				If nValor > 0
					RecLock(cAliasPrv,.T.)
					(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
					(cAliasPrv)->HLH_FILIAL	:= cFilAnt
					(cAliasPrv)->HLH_ORIGEM	:= '07'
					(cAliasPrv)->HLH_ESPDOC	:= ''
					(cAliasPrv)->HLH_FORNEC	:= ''
					(cAliasPrv)->HLH_LJFORN	:= ''
					(cAliasPrv)->HLH_CLIENT	:= ''
					(cAliasPrv)->HLH_LJCLI	:= ''
					(cAliasPrv)->HLH_MOEDA	:= nMoeda
					(cAliasPrv)->HLH_MODALI	:= ''
					(cAliasPrv)->HLH_TIPMOV	:= '3'
					(cAliasPrv)->HLH_ESPREC	:= ''
					(cAliasPrv)->HLH_BANCO	:= SEH->EH_BANCO
					(cAliasPrv)->HLH_DATA	:= dData
					(cAliasPrv)->HLH_SERDOC	:= ''
					(cAliasPrv)->HLH_NUMDOC	:= SEH->EH_NUMERO
					(cAliasPrv)->HLH_PARCEL	:= ''
					(cAliasPrv)->HLH_VPRENT	:= 0.00
					(cAliasPrv)->HLH_VPRSAI	:= nValor
					MsUnlock()
				EndIf
			EndIf
		ElseIf SEH->EH_APLEMP == "APL" // Aplicacoes
	  		If (Empty(SEH->EH_DATARES) .And. nX==1) .Or. (SEH->EH_DATARES == dData)
				nValor := xMoeda(SEH->EH_SALDO,1,nMoeda,dData)
			Else
				nValor := 0
			EndIf
			DbSelectArea("SE9")
			DbSetOrder(1)
			DbSeek(xFilial("SE9")+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
			DbSelectArea("SEH")
			If (Empty(SEH->EH_DATARES) .And. nX==1) .Or. (SEH->EH_DATARES == dData)
				If !SEH->EH_TIPO $ cAplCotas
					aCalc :=	Fa171Calc(dData)
				Else
					aCalc := {0,0,0,0,0,0}
					DbSelectArea("SE0")
					MsSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO))
					DbSelectArea("SEH")
					aCalc := Fa171Calc(dData,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,SE0->E0_VALOR,(SEH->EH_SLDCOTA * SE0->E0_VALOR))
					nValor += xMoeda((aCalc[5]-aCalc[2]-aCalc[3]-aCalc[4]),1,nMoeda,dData)
				EndIf
				If nValor > 0
					RecLock(cAliasPrv,.T.)
					(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
					(cAliasPrv)->HLH_FILIAL	:= cFilAnt
					(cAliasPrv)->HLH_ORIGEM	:= '06'
					(cAliasPrv)->HLH_ESPDOC	:= ''
					(cAliasPrv)->HLH_FORNEC	:= ''
					(cAliasPrv)->HLH_LJFORN	:= ''
					(cAliasPrv)->HLH_CLIENT	:= ''
					(cAliasPrv)->HLH_LJCLI	:= ''
					(cAliasPrv)->HLH_MOEDA	:= nMoeda
					(cAliasPrv)->HLH_MODALI	:= ''
					(cAliasPrv)->HLH_TIPMOV	:= '2'
					(cAliasPrv)->HLH_ESPREC	:= ''
					(cAliasPrv)->HLH_BANCO	:= SEH->EH_BANCO
					(cAliasPrv)->HLH_DATA	:= dData
					(cAliasPrv)->HLH_SERDOC	:= ''
					(cAliasPrv)->HLH_NUMDOC	:= SEH->EH_NUMERO
					(cAliasPrv)->HLH_PARCEL	:= ''
					(cAliasPrv)->HLH_VPRENT	:= nValor
					(cAliasPrv)->HLH_VPRSAI	:= 0.00
					MsUnlock()
				EndIf
			EndIf
		EndIf
		dbSelectArea("SEH")
		dbSkip()
	EndDo

	// Cheques pendentes de liberacao
	If lLibCheq
		dbSelectArea("SEF")
		cFiltro := "EF_FILIAL='"+xFilial("SEF")+"'.And."
		cFiltro += "EF_NUM<>'"+Space(Len(SEF->EF_NUM))+"'.And."
		cFiltro += "!EF_IMPRESS$'AC'.And."
		cFiltro += "EF_LIBER<>'S'.And."
		cFiltro += "EF_CART<>'R'.And."
		cFiltro += "DTOS(EF_DATA)>='"+DTOS(dDataDe)+"'.And."
		cFiltro += "DTOS(EF_DATA)<='"+DTOS(dDataAte)+"'"
		cIndTmp := CriaTrab(,.F.)
		IndRegua("SEF",cIndTmp,"EF_FILIAL+DTOS(EF_DATA)+EF_LIBER",,cFiltro)
		nIndSEF := RetIndex("SEF")
		nIndSEF++
		DbSetOrder(nIndSEF)
		Do While !SEF->(Eof()) .And. SEF->EF_LIBER$" N" .And. SEF->EF_FILIAL == xFilial("SEF")
			RecLock(cAliasPrv,.T.)
			(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
			(cAliasPrv)->HLH_FILIAL	:= cFilAnt
			(cAliasPrv)->HLH_ORIGEM	:= '08'
			(cAliasPrv)->HLH_ESPDOC	:= ''
			(cAliasPrv)->HLH_FORNEC	:= ''
			(cAliasPrv)->HLH_LJFORN	:= ''
			(cAliasPrv)->HLH_CLIENT	:= ''
			(cAliasPrv)->HLH_LJCLI	:= ''
			(cAliasPrv)->HLH_MOEDA	:= nMoeda
			(cAliasPrv)->HLH_MODALI	:= ''
			(cAliasPrv)->HLH_TIPMOV	:= '3'
			(cAliasPrv)->HLH_ESPREC	:= ''
			(cAliasPrv)->HLH_BANCO	:= SEF->EF_BANCO
			(cAliasPrv)->HLH_DATA	:= dData
			(cAliasPrv)->HLH_SERDOC	:= ''
			(cAliasPrv)->HLH_NUMDOC	:= SEF->EF_NUM
			(cAliasPrv)->HLH_PARCEL	:= ''
			(cAliasPrv)->HLH_VPRENT	:= 0.00
			(cAliasPrv)->HLH_VPRSAI	:= SEF->EF_VALOR
			MsUnlock()
			DbSelectArea("SEF")
			DbSkip()
		EndDo
		dbSelectArea("SEF")
		dbClearFil()
		RetIndex("SEF")
		If !Empty(cIndTmp)
			FErase (cIndTmp+OrdBagExt())
		EndIf
		dbSetOrder(1)
	EndIf

Next nX

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³GeraTmpJobºAutor  ³Marcelo Akama		 º Data ³  20/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera dados no arquivo temporario, a partir do arquivo de   º±±
±±º          ³ titulos a receber ou do arquivo de titulos a pagar         º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cAlias     -> Alias do arquivo (SE1/SE2)                   º±±
±±º          ³ nOrdem     -> Ordem de Vencto.                             º±±
±±º          ³ dDataDe    -> Data inicial                                 º±±
±±º          ³ dDataAte   -> Data final                                   º±±
±±º          ³ cFilDe     -> Filial inicial                               º±±
±±º          ³ cFilAte    -> Filial final                                 º±±
±±º          ³ nMoeda     -> Codigo da Moeda                              º±±
±±º          ³ cAliasPrv  -> Alias do arquivo                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraTmpJob( cAlias, nOrdem, dDataDe, dDataAte, cFilDe, cFilAte, nMoeda, cAliasPrv, lFiliais )
Local cAbatim		:= MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM
Local cCampo		:= Right(cAlias,2)
Local dDataVcOri	:= Ctod("//")
Local lFc021Fil		:= ExistBlock("FC021FIL")
Local nCiclos		:=	0
Local nX			:=	0
Local cAliasCF		:= StrTran(cAlias,"E","A")
Local lMvPafutfl    := SuperGetMv("MV_PAFUTFL",.T.,.T.)
Local nSaldoTit
Local nSaldo
Local dDataTrab
Local cAliasTmp
Local nDesconto
Local cCliFor
Local cQuery
Local aStru
Local aAuxGem		:= {}
If cFilDe == nil
	cFilDe := xFilial(cAlias)
EndIf

If cFilAte == nil
	cFilAte := xFilial(cAlias)
EndIf

aStru		:= (cAlias)->(dbStruct())
cAbatim		:= FormatIn(cAbatim,"/")
cAliasTmp	:= "FINC021"
cQuery		:= ""
aEval( aStru, {|x| cQuery += "," + AllTrim( x[1] ) } )
cQuery := "SELECT "+SubStr(cQuery,2)
cQuery +=         ","+cAlias+".R_E_C_N_O_ TITRECNO "
cQuery += "FROM "+RetSqlName(cAlias)+ " "+ cAlias + " "
cQuery += "WHERE "

If lFiliais
	cQuery += cAlias + "." + cCampo + "_FILIAL IN(" + cLisFil + ") AND "
Else
	cQuery += cAlias + "." + cCampo + "_FILIAL >= '" + cFilDe + "' AND "
	cQuery += cAlias + "." + cCampo + "_FILIAL <= '" + cFilAte + "' AND "
EndIf

cQuery += cAlias + "." + cCampo + "_VENCREA >= '" + Dtos( dDataDe ) + "' AND "
cQuery += cAlias + "." + cCampo + "_VENCREA <= '" + Dtos( dDataAte ) + "' AND "
cQuery += cAlias + "." + cCampo + "_FLUXO <> 'N' AND "
cQuery += cAlias + ".D_E_L_E_T_=' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTmp, e[1], e[2],e[3],e[4]),Nil)})


Do While (cAliasTmp)->(!Eof())
	dDataTrab := (cAliasTmp)->&(cCampo+"_VENCREA")
	// Considera a retencao bancaria, caso o titulo esteja em banco
	If cAlias == "SE1" .And. FN022SITCB( (cAliasTrb)->E1_SITUACA )[2]

		dDataVcOri := (cAliasTmp)->&(cCampo+"_VENCTO")

		//Verifico se o proximo dia util apos o vencimento eh igual ao vencto real do titulo
		//Se for igual e o titulo estiver em cobranca, aplico os dias de retencao do banco
		//Se for diferente e o titulo estiver em cobranca, quer dizer que ja foram aplicados os dias de retencao
		//logo nao aplico novamente.
		If DTOS(DataValida(dDataVcOri)) == DTOS(dDataTrab)
			SA6->(MsSeek(xFilial("SA6")+(cAliasTmp)->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
			For nX := 1 To SA6->A6_RETENCA
				dDataTrab := DataValida(dDataTrab+1,.T.)
			Next
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a data de vencto. nao ultrapassar a ultima data da consulta ³
	//³ e nao for um adiantamento                                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dDataTrab <= dDataAte .And.;
		(!(cAliasTmp)->&(cCampo+"_TIPO") $ MVRECANT+IIf(!cPaisLoc $"ARG|CHI",MVPAGANT,"") .OR. ;
		 ((cAliasTmp)->&(cCampo+"_TIPO") $ MVRECANT+IIf(!cPaisLoc $"ARG|CHI",MVPAGANT,"") .And. ;
		 (cAliasTmp)->&(cCampo+"_EMISSAO")>dDataDe)) // Se for um adiantamento, considera se for emissao futura, pois ele ainda nao estara no saldo bancario

		DbSelectArea(cAlias)
		MsGoto((cAliasTmp)->TITRECNO)

		DbSelectArea(cAlias)
		If lFc021Fil
			cFilterUser := ExecBlock("FC021FIL", .F., .F., {cAlias} )
		EndIf
		nSaldoTit := SaldoTit(	(cAliasTmp)->&(cCampo+"_PREFIXO"),;
								(cAliasTmp)->&(cCampo+"_NUM"),;
								(cAliasTmp)->&(cCampo+"_PARCELA"),;
								(cAliasTmp)->&(cCampo+"_TIPO"),;
								(cAliasTmp)->&(cCampo+"_NATUREZA"),;
								If(cAlias="SE1","R","P"),;
								(cAliasTmp)->&(cCampo+IF(cAlias="SE1","_CLIENTE","_FORNECE")),;
								nMoeda,(cAliasTmp)->&(cCampo+"_VENCREA"),;
								dDataTrab,(cAliasTmp)->&(cCampo+"_LOJA"),,If(cPaisLoc=="BRA",(cAliasTmp)->&(cCampo+"_TXMOEDA"),0))
		If cAlias == "SE1"
			nDesconto := FaDescFin(cAliasTmp,dDataDe,nSaldoTit,1)
			nSaldoTit -= nDesconto
			// Se titulo do Template Gem
			If HasTemplate("LOT") .And. !Empty(SE1->E1_NCONTR)
				aAuxGem		:= ExecTemplate("CMDtPrc",.F.,.F.,{(cAliasTmp)->E1_PREFIXO,(cAliasTmp)->E1_NUM ,(cAliasTmp)->E1_PARCELA ,(cAliasTmp)->E1_VENCREA ,(cAliasTmp)->E1_VENCREA})
				nSaldoTit	+= aAuxGem[2]
			EndIf
		EndIf

		If Abs(nSaldoTit) > 0.0001
			// Verifica a situacao, somente se nao for Contas a Receber.
			If cAlias == "SE2" .Or.  !(FN022SITCB( (cAliasTmp)->E1_SITUACA )[3])
				nCiclos	:=	1
				//Movimento Bancario gerado pelo PA (na data de emissao do PA)
				If cAlias == "SE2" .And. (cAliasTmp)->E2_TIPO == MVPAGANT .And. (cAliasTmp)->E2_EMISSAO >= dDataDe .And. (!cPaisLoc $"ARG|CHI" .And. Empty(E2_ORDPAGO))
					nCiclos	:=	If(lMvPafutfl,2,1)
				EndIf
				For nX := 1 To nCiclos
					If (cAliasTmp)->&(cCampo+"_TIPO") $ MVRECANT+MVPAGANT .And. nX == 1	.And. lMvPafutfl
						nSaldo := nSaldoTit * -1
					Else
						nSaldo := nSaldoTit
					Endif
					cCliFor := (cAliasTmp)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))
					// Posiciona no cliente ou fornecedor para buscar o nome
					DbSelectArea(cAliasCF)
					DbSetOrder(1)
					MsSeek(xFilial(cAliasCF)+cCliFor+(cAliasTmp)->&(cCampo+"_LOJA"))
					// Posiciona no FRV para buscar a modalidade
					If Upper(cAlias)=="SE1"
						DbSelectArea("FRV")
						DbSetOrder(1)
						MsSeek(xFilial("FRV")+(cAliasTmp)->(E1_SITUACA))
					Endif

					DbSelectArea(cAliasTmp)

					RecLock(cAliasPrv,.T.)
					(cAliasPrv)->HLH_EMPRES	:= cEmpAnt
					(cAliasPrv)->HLH_FILIAL	:= cFilAnt
					(cAliasPrv)->HLH_ORIGEM	:= IIf(Upper(cAlias)=="SE1","01","02")
					(cAliasPrv)->HLH_ESPDOC	:= IIf(Upper(cAlias)=="SE2",(cAliasTmp)->&(cCampo+"_TIPO"),'')
					(cAliasPrv)->HLH_FORNEC	:= IIf(Upper(cAlias)=="SE2",(cAliasTmp)->&(cCampo+"_FORNECE"),'')
					(cAliasPrv)->HLH_LJFORN	:= IIf(Upper(cAlias)=="SE2",(cAliasTmp)->&(cCampo+"_LOJA"),'')
					(cAliasPrv)->HLH_CLIENT	:= IIf(Upper(cAlias)=="SE1",(cAliasTmp)->&(cCampo+"_CLIENTE"),'')
					(cAliasPrv)->HLH_LJCLI	:= IIf(Upper(cAlias)=="SE1",(cAliasTmp)->&(cCampo+"_LOJA"),'')
					(cAliasPrv)->HLH_MOEDA	:= nMoeda
					(cAliasPrv)->HLH_MODALI	:= IIf(Upper(cAlias)=="SE1",(cAliasTmp)->&(cCampo+"_SITUACA"),'')
					(cAliasPrv)->HLH_TIPMOV	:= IIf(Upper(cAlias)=="SE1",'2','3')
					(cAliasPrv)->HLH_ESPREC	:= IIf(Upper(cAlias)=="SE1",(cAliasTmp)->&(cCampo+"_TIPO"),'')
					(cAliasPrv)->HLH_BANCO	:= (cAliasTmp)->&(cCampo+IIf(Upper(cAlias)=="SE1","_PORTADO","_BCOPAG"))
					(cAliasPrv)->HLH_DATA	:= (cAliasTmp)->&(cCampo+"_VENCREA")
					(cAliasPrv)->HLH_SERDOC	:= (cAliasTmp)->&(cCampo+"_PREFIXO")
					(cAliasPrv)->HLH_NUMDOC	:= (cAliasTmp)->&(cCampo+"_NUM")
					(cAliasPrv)->HLH_PARCEL	:= (cAliasTmp)->&(cCampo+"_PARCELA")
					(cAliasPrv)->HLH_VPRENT	:= IIf(Upper(cAlias)=="SE1",nSaldo,0.00)
					(cAliasPrv)->HLH_VPRSAI	:= IIf(Upper(cAlias)=="SE2",nSaldo,0.00)
					MsUnlock()
				Next
			EndIf
		EndIf
	EndIf
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbSkip())
Enddo

dbSelectArea(cAliasTmp)
dbCloseArea()
dbSelectArea(cAlias)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRVisaoGerºAutor  ³fsw           º Data ³  09/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprimir consulta como visao gerencial                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRVisaoGer(lEnd,cMoeda,cPeriodo,nPeriodos,cFilDe,cFilAte,lReceber,lPagar,lComissoes,lPedVenda,lPedCompra,lAplicacoes,lSaldoBanc,lAnalitico,lConsFil,lTitAtraso,nCaixas,nBancos, aBancos,aAplic,cFilterSe1,cFilterSe2,lConsDtBase,lTitFuturo, lCtrc, cPedidos,nLimCred, lLimCred, cSinal, cVisaoG, lFiliais)

	Local aArqTmp							// Nome do arquivo temporario e alias criado aleatoriamente
	Local aArqCo							// Nome do arquivo temporario e alias para comissões
	Local cSavFil							// Salva a Filial atual
	Local aCalc								// Calculo de aplicacao
	Local aAreaSM0		:= SM0->(GetArea()) // Salva a area do SM0
	Local dDataTrab							// Data de trabalho
	Local nAplicacao	:= 0				// Valor da aplicacao
	Local nEmprestimo	:= 0				// Valor do emprestimo
	Local nDias
	Local nX								// Contador de loop for...next
	Local nAtrReceber	:= 0
	Local nAtrPagar		:= 0
	Local aTmpAnaEmp
	Local aTmpAnaApl
	Local aTmpAnaCtrc	:= Array(2)
	Local cAliasEmp
	Local aTmpAnaSol	:= Array(2)
	Local cAliasApl
	Local oDlg
	Local oGet02
	Local cAliasPc
	Local cAliasPv
	Local cAliasChq
	Local aTotais		:= {{},{},{},{},{},{},{},{}, {}}
	Local aPeriodo		:= {}
	Local aFluxo		:= {}
	Local oPanel
	Local oFluxo
	Local nAscan
	Local nRecSeh
	Local cAplCotas		:= GetMv("MV_APLCAL4")
	Local aCampos		:= {{"CODDESC   "	,"C",50	,0}	,;
							{"RECEBIDOS "	,"N",17	,2}	,;
							{"PAGOS     "	,"N",17	,2}	,;
							{"DISPONIVEL"	,"N",17	,2}	,;
							{"DATAAN"		,"D",08	,0}	,;
							{"ORDEM"		,"C",17	,0}}
	Local cAlias
	Local cQueryVis
	Local aSize
	Local aObjects		:= {}
	Local aInfo
	Local aPosObj
	Local nTotRegs		:= 0
	Local aTit			:= {{"01",STR0177 },{"07",STR0178},{"10",STR0179},{"15",STR0180},{"30",STR0181}}	//"Dia"###"Semana"###"Decendio"###"Quinzena"###"Mes"
	Local cTit
	Local lLibCheq		:= GetMv( "MV_LIBCHEQ" ) == "N"	// Para controlar os cheques pendentes de liberacao
	Local dDataAte
	Local nValBancos	:= 0
	Local cAliasSe1
	Local cAliasSe2
	Local cAliasAnaP
	Local cAliasAnaR
	Local cAliasTrb
	Local nSaldoTit
	Local aCposAnaP
	Local aCposAnaR
	Local cIndTmp
	Local cCliFor
	Local cFils			:= ""
	Local lGestao		:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
	Local cFilFwSE2		:= IIF( lGestao .And. FindFunction("FwFilial"), FwFilial("SE2") , xFilial("SE2") )
	Local cFilFwSE1		:= IIF( lGestao .And. FindFunction("FwFilial"), FwFilial("SE1") , xFilial("SE1") )
	Local cAbatim		:= MV_CRNEG + "/" + MV_CPNEG + "/" + MVIRABT + "/" + MVCSABT + "/" + MVCFABT + "/" + MVPIABT + "/" + MVABATIM
	Local aSx3Box		:= F021SitCob()
	Local nCiclos		:= 0
	Local lFc021Fil		:= ExistBlock("FC021FIL")
	Local dDataVcOri	:= Ctod("//")
	Local nDesconto
	Local lTxMoeda
	Local nDiasRet		:= 0
	Local lFC021MAM		:= ExistBlock("FC021MAN")
	Local lFc021atrb    := ExistBlock("FC021ATRB")
	Local lFc021Cpo		:= ExistBlock("FC021CPO")
	Local cFilterUser
	Local nResto
	Local nDiasR
	Local dDataPri
	Local cQuery
	Local aStru
	Local cFilSEF		:= ""
	Local lPanelFin		:= IsPanelFin()
	local aFJ3TEMP		:= {}
	local nPosLine		:= 0
	local lLastLine		:= .F.
	Local cTable     := ""
	Local nProcQry   := 0
	Local cInsert    := ""
	Local cColuna    := ""
	Local aEstruct   := {}
	Local nJ		 := 0
	Local lPAFUTFL	 := SuperGetMv("MV_PAFUTFL",.T.,.F.)
	Local nTamDisp   := TamSX3("E2_VALOR")[1]
	Local nTamRec    := TamSX3("E1_VALOR")[1]
	Local nTamPg     := TamSX3("E2_VALOR")[1]
	Local nTamDCCG   := TamSX3("FJ2_DESCCG")[1]
	Local nTamFil    := TamSX3("FJ3_FILIAL")[1]
	Local nTamCodPla := TamSX3("FJ3_CODPLA")[1]
	Local nTamOrd    := TamSX3("FJ3_ORDEM")[1]
	Local nTamContag := TamSX3("FJ3_CONTAG")[1]
	Local nTamCtaSup := TamSX3("FJ3_CTASUP")[1]
	Local nTamDscCg  := TamSX3("FJ3_DESCCG")[1]
	Local nTamDetHcg := TamSX3("FJ3_DETHCG")[1]
	Local nTamNorm   := TamSX3("FJ3_NORMAL")[1]
	Local nTamCol    := TamSX3("FJ3_COLUNA")[1]
	Local nTamClas   := TamSX3("FJ3_CLASSE")[1]
	Local nTamIdent  := TamSX3("FJ3_IDENT")[1]
	Local nTamNome   := TamSX3("FJ3_NOME")[1]
	Local nTamLin    := TamSX3("FJ3_LINHA")[1]
	Local nTamSedIn  := TamSX3("FJ3_SEDINI")[1]
	Local nTamSedFm  := TamSX3("FJ3_SEDFIM")[1]
	Local nTamForm   := TamSX3("FJ3_FORMUL")[1]
	Local nTamTvsIs  := TamSX3("FJ3_TOTVIS")[1]
	Local nTamVisEnt := TamSX3("FJ3_VISENT")[1]
	Local nTamSldEnt := TamSX3("FJ3_SLDENT")[1]
	Local nTamFatSld := TamSX3("FJ3_FATSLD")[1]
	Local cPicture	 := PesqPict("SE9","E9_VLRCOTA",18)
	Local dBkpDtBase
	Local dDataPedCom
	Local aCposA		:= {}
	Local cTempVA		:= GetNextAlias()			// Alias Tabela temporária VA
	Local oTmpVA		:= Nil 			// Objeto Tab. temp. VA
	Local lSeekVA		:= .T.			// Define se busca VA para o título
	Local dDataBx   	:= Ctod("//")
	Local aAuxGem		:= {}
	Local cRNatIniAnt	:= ""
	Local cRNatFimAnt	:= ""
	Local dRDtTrabAnt	:= CToD("//")
	Local cPNatIniAnt	:= ""
	Local cPNatFimAnt	:= ""
	Local dPDtTrabAnt	:= CToD("//")
	Local cFwFilSEH		:= FwFilial("SEH")
	Local cCompSA1		:= FwFilial("SA1")
	Local cCompSA2		:= FwFilial("SA2")
	Local cCampo		:= ""
	Local cChaveTit		:= ""
	Local aTitulos		:= {}
	Local nPosTitPai	:= 0

	//	Declara a Cols Aqui, pois sera utilizada na rotina de simulacao e seu conteudo deve permanecer o mesmo toda vez que o usuario clicar no botao simulacao
	aCols := {}

	aHeader := {}

	cFils 		:= FincRetFils() // Retorna filiais que o usuario tem acesso

	// Analitico
	If lAnalitico .And. (_oFINC021c == Nil .Or. _oFINC021b == Nil)
		//Analitico Recebidos SE1
		cAliasAnaP	:= "cArqAnaP"  // Alias do arquivo analitico
		cAliasAnaR	:= "cArqAnaR"  // Alias do arquivo analitico
		aCposAnaR	:= {}
		cCampo		:= "E1"
		AAdd(aCposAnaR, {"Periodo",		"C", 25,														0})
		AAdd(aCposAnaR, {"DATAX",		"D", 08,														0})
		AAdd(aCposAnaR, {"FILIAL",		"C", IIf(lFWCodFil, FWGETTAMFILIAL, TamSX3("E1_FILIAL")[1]),	0})
		AAdd(aCposAnaR, {"PREFIXO",		"C", TamSX3("E1_PREFIXO")[1],									0})
		AAdd(aCposAnaR, {"NUM",			"C", TamSX3("E1_NUM")[1],										0})
		AAdd(aCposAnaR, {"PARCELA",		"C", TamSX3("E1_PARCELA")[1],									0})
		AAdd(aCposAnaR, {"TIPO",		"C", TamSX3("E1_TIPO")[1],										0})
		AAdd(aCposAnaR, {"CLIFOR",		"C", TamSX3("A1_COD")[1],										0})
		AAdd(aCposAnaR, {"NomCliFor",	"C", TamSX3("A1_NOME")[1],										0})
		AAdd(aCposAnaR, {"LOJA",		"C", TamSX3("E1_LOJA")[1],										0})
		AAdd(aCposAnaR, {"SALDO",		"N", Max(TamSX3("E1_SALDO")[1], TamSX3("E2_SALDO")[1]), 		TamSX3("E1_SALDO")[2]})
		AAdd(aCposAnaR, {"SITUACAO",	"C", TamSX3("FRV_DESCRI")[1],									0})
		AAdd(aCposAnaR, {"PORTADO",		"C", TamSX3("E1_PORTADO")[1],									0})
		AAdd(aCposAnaR, {"AGEDEP",		"C", TamSX3("E1_AGEDEP")[1],									0})
		AAdd(aCposAnaR, {"CONTA",		"C", TamSX3("E1_CONTA")[1],										0})
		AAdd(aCposAnaR, {"CHAVE",		"C", 40, 0})
		AAdd(aCposAnaR, {"Apelido",		"C", 10, 0})

		// Ponto de entrada para criar campos no arquivo temporario
		If lFc021Cpo
			aCposA := ExecBlock("FC021CPO",.F.,.F.,{aCposAnaR})
			For nX := 1 to len(aCposA)
				aAdd(aCposAnaR,aCposA[nX])
			Next
		EndIf

		AAdd(aCposAnaR, {"CampoNulo",	"C", 1, 0})
		AAdd(aCposAnaR, {"Flag",		"L", 1, 0})

		// Define estrutura da tabela temporária
		If _oFINC021b  <> Nil
			_oFINC021b:Delete()
			_oFINC021b := Nil
		Endif

		_oFINC021b := FWTemporaryTable():New( cAliasAnaR )
		_oFINC021b:SetFields(aCposAnaR)
		_oFINC021b:AddIndex("1", {"DATAX"})

		//Criação da tabela temporaria
		_oFINC021b:Create()

		//Analitico Pago SE2
		aCposAnaP := {}
		cCampo := "E2"
		AAdd(aCposAnaP, {"Periodo",		"C", 25,														0})
		AAdd(aCposAnaP, {"DATAX",		"D", 08,														0})
		AAdd(aCposAnaP, {"FILIAL",		"C", IIf(lFWCodFil, FWGETTAMFILIAL, TamSX3("E2_FILIAL")[1]),	0})
		AAdd(aCposAnaP, {"PREFIXO",		"C", TamSX3("E2_PREFIXO")[1],									0})
		AAdd(aCposAnaP, {"NUM",			"C", TamSX3("E2_NUM")[1],										0})
		AAdd(aCposAnaP, {"PARCELA",		"C", TamSX3("E2_PARCELA")[1],									0})
		AAdd(aCposAnaP, {"TIPO",		"C", TamSX3("E2_TIPO")[1],										0})
		AAdd(aCposAnaP, {"CLIFOR",		"C", TamSX3("A2_COD")[1],										0})
		AAdd(aCposAnaP, {"NomCliFor",	"C", TamSX3("A2_NOME")[1],										0})
		AAdd(aCposAnaP, {"LOJA",		"C", TamSX3("E2_LOJA")[1],										0})
		AAdd(aCposAnaP, {"SALDO",		"N", Max(TamSX3("E1_SALDO")[1], TamSX3("E2_SALDO")[1]),			TamSX3("E1_SALDO")[2]})
		AAdd(aCposAnaP, {"CHAVE",		"C", 40,														0})
		AAdd(aCposAnaP, {"Apelido",		"C", 10,														0})

		// Ponto de entrada para criar campos no arquivo temporario
		If lFc021Cpo
			aCposA := ExecBlock("FC021CPO",.F.,.F.,{aCposAnaP})
			For nX := 1 to len(aCposA)
				aAdd(aCposAnaP,aCposA[nX])
			Next
		EndIf

		AAdd(aCposAnaP, {"CampoNulo",	"C", 1, 0})
		AAdd(aCposAnaP, {"Flag", 		"L", 1, 0})

		// Define estrutura da tabela temporária
		If _oFINC021c  <> Nil
			_oFINC021c:Delete()
			_oFINC021c := Nil
		Endif

		_oFINC021c := FWTemporaryTable():New( cAliasAnaP )
		_oFINC021c:SetFields(aCposAnaP)
		_oFINC021c:AddIndex("1", {"DATAX"})

		//Criação da tabela temporaria
		_oFINC021c:Create()
	EndIf

	// Utilizada na simulacao
	aHeader := {}
	AAdd(aHeader, {STR0024, "_SI_DATA"  , "", 8, 0, ".T.", USADO, "D",, "V"})//"Data"
	AAdd(aHeader, {STR0025, "_SI_TIPO"  , "!", 1, 0, "Fc021Tipo()", USADO, "C",, "V"})//"Receita/Despesa"
	AAdd(aHeader, {STR0026, "_SI_VALOR" , "@E 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V"})//"Valor"
	AAdd(aHeader, {STR0027, "_SI_HISTOR", "@!", 40, 0, ".T.", USADO, "C",, "V"})//"Historico"
	AAdd(aHeader, {STR0199, "_SI_VALANT", "@E 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V"})//"Valor"

	cIndex		:= "a"+Substr(CriaTrab( NIL, .f. ),2,7)

	// Define estrutura da tabela temporária
	If _oFINC021d  <> Nil
		_oFINC021d:Delete()
		_oFINC021d := Nil
	Endif

	_oFINC021d := FWTemporaryTable():New( "cArqTmp" )
	_oFINC021d:SetFields(aCampos)
	_oFINC021d:AddIndex("1", {"DATAAN"})

	//Criação da tabela temporaria
	_oFINC021d:Create()

	dBkpDtBase := dDataBase

	// Pega o titulo da primeira coluna de acordo com o periodo selecionado
	cTit := aTit[Ascan(aTit,{|e|e[1]==Left(cPeriodo,2)})][2]

	nMoeda := Val(Left(cMoeda,2))
	nDias  := Val(Left(cPeriodo,2))*nPeriodos // Calcula quantos dias
	If nDias <= 0
	nDias := 1
	EndIf

	If lConsDtBase
		dDataAte  := dDataBase + nDias - 1
	Else
		dDataAte  := (dDataBase + 1) + nDias - 1
	EndIf

	If !lConsDtBase
		dDatabase++
	EndIf

	dDataTrab := dDataBase

	// Monta os periodos na matriz para ser utilizada na simulacao e na projecao
	MontaPeriodo(aPeriodo,cPeriodo)

	If !lConsFil .And. !lFiliais
		cFilDe  := cFilAnt
		cFilAte := cFilAnt
	Endif

	//Query para buscar a visão gerencial escolhida no parametro
	cQueryVis := " SELECT 0 as FJ3_REC, 0 AS FJ3_PAGO, 0 AS FJ3_DISP , FJ3.FJ3_FILIAL,FJ3.FJ3_CODPLA,FJ3.FJ3_ORDEM,FJ3.FJ3_CONTAG,FJ3.FJ3_CTASUP,"
	cQueryVis += " FJ3.FJ3_DESCCG,FJ3.FJ3_DETHCG,FJ3.FJ3_NORMAL,FJ3.FJ3_COLUNA,FJ3.FJ3_CLASSE,FJ3.FJ3_IDENT,FJ3.FJ3_NOME,FJ3.FJ3_LINHA,"
	cQueryVis += " FJ3.FJ3_SEDINI,FJ3.FJ3_SEDFIM,FJ3.FJ3_FORMUL,FJ3.FJ3_TOTVIS,FJ3.FJ3_VISENT,FJ3.FJ3_SLDENT,FJ3.FJ3_FATSLD,FJ2.FJ2_DESCCG"
	cQueryVis += " FROM " + RetSqlName("FJ3") + " FJ3, " + RetSqlName("FJ2") + " FJ2"
	cQueryVis += " WHERE FJ3_CODPLA = '" + cVisaoG + "' "
	cQueryVis += " AND FJ3.D_E_L_E_T_ = ' ' "
	cQueryVis += " AND FJ2.D_E_L_E_T_ = ' ' "
	cQueryVis += " AND FJ3.FJ3_CODPLA = FJ2.FJ2_CODIGO"
	cQueryVis += " AND FJ3.FJ3_ORDEM = FJ2.FJ2_ORDEM"

	cQueryVis := ChangeQuery(cQueryVis)

	//Define as colunas e suas propriedades para criar a tabela temporaria TRB4
	AAdd(aEstruct,{"FJ3_REC"   ,"N",nTamRec,2})
	AAdd(aEstruct,{"FJ3_PAGO"  ,"N",nTamPg,2})
	AAdd(aEstruct,{"FJ3_DISP"  ,"N",nTamDisp,2})
	AAdd(aEstruct,{"FJ3_FILIAL","C",nTamFil,0})
	AAdd(aEstruct,{"FJ3_CODPLA","C",nTamCodPla,0})
	AAdd(aEstruct,{"FJ3_ORDEM" ,"C",nTamOrd,0})
	AAdd(aEstruct,{"FJ3_CONTAG","C",nTamContag,0})
	AAdd(aEstruct,{"FJ3_CTASUP","C",nTamCtaSup,0})
	AAdd(aEstruct,{"FJ3_DESCCG","C",nTamDscCg,0})
	AAdd(aEstruct,{"FJ3_DETHCG","C",nTamDetHcg,0})
	AAdd(aEstruct,{"FJ3_NORMAL","C",nTamNorm,0})
	AAdd(aEstruct,{"FJ3_COLUNA","N",nTamCol,0})
	AAdd(aEstruct,{"FJ3_CLASSE","C",nTamClas,0})
	AAdd(aEstruct,{"FJ3_IDENT" ,"C",nTamIdent,0})
	AAdd(aEstruct,{"FJ3_NOME"  ,"C",nTamNome,0})
	AAdd(aEstruct,{"FJ3_LINHA" ,"C",nTamLin,0})
	AAdd(aEstruct,{"FJ3_SEDINI","C",nTamSedIn,0})
	AAdd(aEstruct,{"FJ3_SEDFIM","C",nTamSedFm,0})
	AAdd(aEstruct,{"FJ3_FORMUL","C",nTamForm,0})
	AAdd(aEstruct,{"FJ3_TOTVIS","C",nTamTvsIs,0})
	AAdd(aEstruct,{"FJ3_VISENT","C",nTamVisEnt,0})
	AAdd(aEstruct,{"FJ3_SLDENT","C",nTamSldEnt,0})
	AAdd(aEstruct,{"FJ3_FATSLD","C",nTamFatSld,0})
	AAdd(aEstruct,{"FJ2_DESCCG","C",nTamDCCG,0})

	//Armazena colunas para utilizar no insert de dados na tabela temporaria TRB4
	For nJ := 1 to Len( aEstruct )
		cColuna += IIF(nJ>1,","+aEstruct[nJ][1],aEstruct[nJ][1])
	Next nJ

	//Criação da tabela temporaria
	If _oFINC021g <> Nil
		_oFINC021g:Delete()
		_oFINC021g := Nil
	Endif

	_oFINC021g := FWTemporaryTable():New( "TRB4" )
	_oFINC021g:SetFields(aEstruct)

	//Adiciono o índice da tabela temporária
	_oFINC021g:AddIndex("1",{"FJ3_CODPLA","FJ3_ORDEM","FJ3_LINHA"})

	_oFINC021g:Create()

	//Obtenho o nome físico da tabela temporária no banco de dados
	cTable := _oFINC021g:GetRealName()

	cInsert := " INSERT "
	If __cSGBD == "ORACLE"
		cInsert += " /*+ APPEND */ "
	EndIf

	If __cSGBD == "DB2"
		cQueryVis := STRTRAN( cQueryVis, "FOR READ ONLY", "" )
	EndIf

	cInsert += " INTO " + cTable + " ("+cColuna+" ) " + cQueryVis

	//Executo o comando para alimentar a tabela temporária
	Processa({|| nProcQry := TcSQLExec(cInsert)})

	If nProcQry != 0
		UserException( TCSqlError() )
	EndIf

	DbSelectArea("TRB4")
	TRB4->(DbGoTop())

	If lReceber
		aStru	:= SE1->(DbStruct())
		cAbatim	:= FormatIn(cAbatim, "/")

		CriaTMPTit(.T., .F., AClone(aStru))

		__cCposSE1 := ""
		AEval(aStru, {|campo| __cCposSE1 += "," + AllTrim(campo[1])})
		__cCposSE1 := SubStr(__cCposSE1, 2)

		cSE1TMPTB := __oSE1TMP:GetRealName()
		cAliasSE1 := __oSE1NAT:GetAlias()

		cInsertSE1 := " INSERT "

		If "ORACLE" $ __cSGBD
			cInsertSE1 += " /*+ APPEND */ "
		EndIf

		cInsertSE1 += " INTO " + cSE1TMPTB  + " (" + __cCposSE1  + ", TITRECNO) "

		cQuery := "SELECT " + __cCposSE1 + ", SE1.R_E_C_N_O_ TITRECNO "
		cQuery += "FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += "WHERE "

		If !Empty(cFils) .And. !("@@" $ cFils)
			// Contas a pagar compartilhado deve observar FILORIG para realizar filtro
			If lConsFil .And. !Empty(cFilAte) //filtro por usuário quando não possui controle de todas as empresas.
				If Empty( cFilFwSE1 )
					cQuery += "SE1.E1_FILORIG BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
					cQuery += "SE1.E1_FILIAL = '" + FwXFilial("SE1") + "' AND "
				Else
					cQuery += "SE1.E1_FILIAL BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
				EndIf
			Else
				If Empty( cFilFwSE1 )
					cQuery += "SE1.E1_FILORIG IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
				Else
					cQuery += "SE1.E1_FILIAL IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
				EndIf
			EndIf
		Else
			// Contas a pagar compartilhado deve observar FILORIG para realizar filtro
			If !lConsFil .And. Empty( cFilFwSE1 )
				cQuery += "SE1.E1_FILIAL = '" + FwXFilial("SE1") + "' AND "
			Else
				If Empty( cFilFwSE1 )
					cQuery += "SE1.E1_FILORIG >= '" + cFilDe + "' AND "
					cQuery += "SE1.E1_FILORIG <= '" + cFilAte+"' AND "
					cQuery += "SE1.E1_FILIAL = '" + FwXFilial("SE1") + "' AND "
				ElseIf lFiliais
					cQuery += "SE1.E1_FILIAL IN("+cLisFil+") AND "
				Else
					cQuery += "SE1.E1_FILIAL>='"+cFilDe+"' AND "
					cQuery += "SE1.E1_FILIAL<='"+cFilAte+"' AND "
				EndIf
			EndIf
		EndIf
		cQuery += "SE1.E1_VENCREA >= '" + DToS(dDataBase) + "' AND "
		cQuery += "SE1.E1_VENCREA <= '" + DToS(dDataAte) + "' AND "

		// Nao considerar titulos emitidos apos a data base, para compatiblizacao com FINR140.
		If !lTitFuturo  //Nao considerar titulos com emissao posterior a database
			cQuery += "(E1_EMISSAO <= '"+DToS(dDataBase) + "' OR E1_TIPO IN " + FormatIn(MVRECANT,"/")+") AND "
		EndIf

		If !lConsDtBase
			cQuery += "SE1.E1_SALDO > 0 AND "
		Endif
		cQuery += "SE1.E1_FLUXO <> 'N' AND "
		cQuery += "SE1.D_E_L_E_T_ = ' ' "

		IIf(TCSQLExec(cInsertSE1 + cQuery) < 0, UserException(TCSQLError()), Nil)

		FwFreeArray(aStru)
	Endif

	If lPagar
		aStru	:= SE2->(DbStruct())
		cAbatim	:= FormatIn(cAbatim, "/")

		CriaTMPTit(.F., .T.,, AClone(aStru))

		__cCposSE2 := ""
		AEval(aStru, {|campo| __cCposSE2 += "," + AllTrim(campo[1])})
		__cCposSE2 := SubStr(__cCposSE2, 2)

		cSE2TMPTB := __oSE2TMP:GetRealName()
		cAliasSE2 := __oSE2NAT:GetAlias()

		cInsertSE2 := " INSERT "

		If "ORACLE" $ __cSGBD
			cInsertSE2 += " /*+ APPEND */ "
		EndIf

		cInsertSE2 += " INTO " + cSE2TMPTB  + " (" + __cCposSE2  + ", TITRECNO) "

		cQuery := "SELECT " + __cCposSE2 + ", SE2.R_E_C_N_O_ TITRECNO "
		cQuery += "FROM " + RetSQLName("SE2") + " SE2 "
		cQuery += "WHERE "

		If !Empty( cFils ) .and. !("@@" $ cFils)
			// Contas a pagar compartilhado deve observar FILORIG para realizar filtro
			If lConsFil .And. !Empty(cFilAte) //filtro por usuário quando não possui controle de todas as empresas.
				If Empty( cFilFwSE2 )
					cQuery += "SE2.E2_FILORIG BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
				Else
					cQuery += "SE2.E2_FILIAL BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
				EndIf
			Else
				If Empty( cFilFwSE2 )
					cQuery += "SE2.E2_FILORIG IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
				Else
					cQuery += "SE2.E2_FILIAL IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
				EndIf
			EndIf
		Else
			// Contas a pagar compartilhado deve observar FILORIG para realizar filtro
			If !lConsFil .And. Empty( cFilFwSE2 )
				cQuery += "SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND "
			Else
				If Empty( cFilFwSE2 )
					cQuery += "SE2.E2_FILORIG >= '" + cFilDe + "' AND "
					cQuery += "SE2.E2_FILORIG <= '" + cFilAte+"' AND "
					cQuery += "SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND "
				ElseIf lFiliais
					cQuery += "SE2.E2_FILIAL IN("+cLisFil+") AND "
				Else
					cQuery += "SE2.E2_FILIAL >= '"+cFilDe+"' AND "
					cQuery += "SE2.E2_FILIAL <= '"+cFilAte+"' AND "
				EndIf
			EndIf
		EndIf
		cQuery += "SE2.E2_VENCREA >= '" + Dtos( dDataBase ) + "' AND "
		cQuery += "SE2.E2_VENCREA <= '" + Dtos( dDataAte ) + "' AND "

		// Nao considerar titulos emitidos apos a data base, para compatiblizacao com FINR140
		If !lTitFuturo  //Nao considerar titulos com emissao posterior a database
			cQuery += "(E2_EMIS1 <= '"+Dtos(dDataBase) +"' OR E2_TIPO IN " + FormatIn(MVPAGANT,"/")+") AND "
		EndIf
		If !lConsDtBase
			cQuery += "SE2.E2_SALDO > 0 AND "
		Endif
		cQuery += "SE2.E2_FLUXO <> 'N' AND "
		cQuery += "SE2.D_E_L_E_T_=' ' "

		If lFC021MAM
			cQuery :=  ExecBlock("FC021MAN",.F.,.F.,{cQuery,"SE2","E2"})
		EndIf
		
		IIf(TCSQLExec(cInsertSE2 + cQuery) < 0, UserException(TCSQLError()), Nil)

		FwFreeArray(aStru)
	EndIf

	// Criação de tabela temporária para armazernar a chave da FK7 para os títulos que possuem VA (FKD)
	If oTmpVA == Nil	
		
		oTmpVA := FwTemporaryTable():New( cTempVA )
		
		oTmpVA:SetFields( { {'CHAVE','C',100,0} } )

		oTmpVA:AddIndex( '01', {'CHAVE'} )
		
		oTmpVA:Create()
		
		cInsert := " INSERT INTO " + oTmpVA:GetRealName()  + "  (CHAVE)  "
		cInsert += " SELECT FK7.FK7_CHAVE FROM " + RetSqlName( 'FK7' ) + " FK7  JOIN " 
		cInsert += RetSqlName( 'FKD' ) + " FKD ON FK7.FK7_FILIAL = FKD.FKD_FILIAL AND FK7.FK7_IDDOC = FKD.FKD_IDDOC "
		cInsert += " WHERE FK7.D_E_L_E_T_ = ' ' AND FKD.D_E_L_E_T_ = ' ' "

		TcSqlExec( cInsert )

		( cTempVA )->(DbGoTop())
		//Caso não haja nenhum registro de Valores Acessórios, evito chamar a rotina de cálculo de VA
		If ( cTempVA )->( BOF() ) .And. ( cTempVA )->( EOF() )  
			lSeekVA := .F.
		EndIf	

	EndIf

	// Inicia o total de registros a srem processados para incrementar a regua
	If lReceber
		nTotRegs += MPSysExecScalar("SELECT COUNT(*) QTDSE1 FROM " + cSE1TMPTB, "QTDSE1")//SE1->(RecCount())
	Endif
	If lPagar
		nTotRegs += MPSysExecScalar("SELECT COUNT(*) QTDSE2 FROM " + cSE2TMPTB, "QTDSE2")//SE2->(RecCount())
	Endif
	If lAplicacoes
		nTotRegs += SEH->(RecCount())
	Endif
	If lPedCompra
		nTotRegs += SC7->(RecCount())
	Endif

	ProcRegua(nTotRegs)

	If lAplicacoes
		If lAnalitico
			aTmpAnaEmp := CriaTmpAna(1) // Cria o arquivo temporario analitico de emprestimos
			cAliasEmp  := aTmpAnaEmp[1]
			aTmpAnaApl := CriaTmpAna(2) // Cria o arquivo temporario analitico de aplicacoes
			cAliasApl  := aTmpAnaApl[1]
		Endif
	EndIf

	aArqTmp := Array(4)
	If lLibCheq // Verifica cheques nao liberados
		If lAnalitico
			aTmpAnaChq := CriaTmpAna(6) // Cria o arquivo temporario analitico de emprestimos
			cAliasChq  := aTmpAnachq[1]
		Endif
	EndIf

	If lPedCompra
		
		aTmpAna		:= CriaTmpAna(3) // Cria o arquivo temporario analitico
		cAliasPc	:= aTmpAna[1]
		cArqAnaPc	:= aTmpAna[2]
		
		// Variaveis utilizadas pela rotina Fc020Compra()
		aCompras	:= {}
		adCompras	:= {}
		MV_PAR03	:= If( lConsFil .Or. lFiliais, 2, 1 )
		MV_PAR02	:= nMoeda

		aPeriodo := {}
		If lFiliais
			aSort(aSelFil)
			cFilDe	:= aSelFil[1]
			cFilAte	:= aSelFil[Len(aSelFil)]
		EndIf
		For nX := 1 To nDias
			dDataTrab := dDataBase + nX-1
			TemFluxoData(dDataTrab,aPeriodo)
		Next nX

		MontaPeriodo(aPeriodo,cPeriodo)
		Fc020Compra(cAliasPc, aTotais, .T., nMoeda, aPeriodo, cFilDe, cFilAte, cPedidos, .F.,, aSelFil)  
		(cAliasPc)->(dbGoTop())
		aPeriodo := {} 

	EndIF
	dDataTrab := dDataBase
	nResto := 0
	nDiasR := 0

	//Calcula o numero de dias que devem ser somados caso o periodo seja diferente de Diario
	If (Val(Left(cPeriodo,2)) != 1)
		nResto := CalcDias(cPeriodo, dDataTrab)
		nDiasR := 0 //Contador para os dias
		dDataPri := dDataTrab // Guarda a data do primeiro dia processado
	EndIf

	While (dDataTrab <= dDataAte)
		cSavFil 	:= cFilAnt
		//Atribui valores as variaveis ref a filiais
		If !lConsFil .And. !lFiliais
			cFilDe  := cFilAnt
			cFilAte := cFilAnt
		EndIf

		If lFiliais
			aSort(aSelFil)
			cFilDe	:= aSelFil[1]
			cFilAte	:= aSelFil[Len(aSelFil)]
		EndIf

		// Se for analitica -  busco por naturezas
		If (!Empty(TRB4->FJ3_SEDINI) .And. !Empty(TRB4->FJ3_SEDFIM))
			//Verifica a Disponibilidade Financeira
			DbSelectArea("SM0")
			SM0->(DbSetOrder(1))
			SM0->(DbSeek(cEmpAnt + cFilDe, .T.))
			While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
				cFilAnt := IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)

				If lAplicacoes
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se existe Emprestimo a ser resgatado no dia ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SEH")
					dbSetOrder(2)
					dbSeek(xFilial("SEH")+"A",.T.)
					nRecSeh := Recno()
					While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )//.And.;
						If SEH->EH_NATUREZ >= TRB4->FJ3_SEDINI .And. SEH->EH_NATUREZ <= TRB4->FJ3_SEDFIM 
							If SEH->EH_APLEMP == "EMP"
								If ( Empty(SEH->EH_DATARES) .And. dDataTrab == dDataBase ) .Or. (SEH->EH_DATARES == dDataTrab)

									dA181DtApr := dDataTrab
									nA181VlMoed:= RecMoeda(dA181DtApr,SEH->EH_MOEDA)
									nA181SPCP2	:= 0
									nA181SPLP2	:= 0
									nA181SPCP1	:= 0
									nA181SPLP1	:= 0
									nA181SJUR2	:= 0
									nA181SJUR1	:= 0
									nA181SVCLP	:= 0
									nA181SVCCP	:= 0
									nA181SVCJR	:= 0
									nA181VPLP1 	:= 0
									nA181VPCP1 	:= 0
									nA181VJUR1 	:= 0
									nA181VVCLP 	:= 0
									nA181VVCCP 	:= 0
									nA181VVCJR 	:= 0
									nA181VPLP2 	:= 0
									nA181VlDeb  := 0

									aCalculo	  := Fa171Calc(dDataTrab,SEH->EH_SALDO,.F.)
									nA181SPCP2 := Round(SEH->EH_SALDO * SEH->EH_PERCPLP/100 , TamSX3("EH_SALDO")[2])
									nA181SPLP2 := SEH->EH_SALDO - nA181SPCP2
									nA181SPLP1 := SEH->EH_VLCRUZ
									nA181SPCP1 := Round(SEH->EH_VLCRUZ * SEH->EH_PERCPLP/100,TamSX3("EH_SALDO")[2])
									nA181SPLP1 := SEH->EH_VLCRUZ - nA181SPCP1
									nA181SJUR2 := aCalculo[1,2]
									nA181SJUR1 := aCalculo[2,2]
									nA181SVCLP := aCalculo[2,3]
									nA181SVCCP := aCalculo[2,4]
									nA181SVCJR := aCalculo[2,5]
									nA181VlIRF := 0
									nA181VLDES := 0
									nA181VLGAP := 0
									nA181STOT1 := nA181SPLP1+nA181SPCP1+nA181SJUR1+nA181SVCLP+nA181SVCCP+nA181SVCJR
									nA181STOT2 := nA181SPLP2+nA181SPCP2+nA181SJUR2
									nA181VPLP1 := nA181SPLP1
									nA181VPCP1 := nA181SPCP1
									nA181VPLP2 := nA181SPLP2
									nA181VPCP2 := nA181SPCP2
									nA181VJUR1 := nA181SJUR1
									nA181VJUR2 := nA181SJUR2
									nA181VVCLP := nA181SVCLP
									nA181VVCCP := nA181SVCCP
									nA181VVCJR := nA181SVCJR
									nA181VTOT1 := nA181STOT1
									nA181VTOT2 := nA181STOT2

									Fa181Valor(,"DA181DTAPR") // Atualiza as variaveis PRIVATES do calculo do emprestimo
									nEmprestimo := xMoeda(nA181VlDeb,1,nMoeda,dDataTrab)

									//Calcula valor do emprestimo e soma na linha correto do arquivo
									//Soma/Subtrai nas entidades superiores
									//Soma na propria linha da natureza
									RecLock("TRB4",.F.)
										TRB4->FJ3_PAGO += nEmprestimo
									TRB4->(MsUnLock())

									cSuperior := TRB4->FJ3_CTASUP // Conta Superior
									cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
									nCont     := TRB4->(Recno())

									//Procurar nas superiores e somar ou subtrair
									Do While ! TRB4->(BOF()) .And. (!Empty(cSuperior))

										//Somar ou Subtrair conforme campo FJ3_IDENTI
										If (cSuperior == TRB4->FJ3_CONTAG)
												If (cIdenti == '1')
													RecLock("TRB4",.F.)
														TRB4->FJ3_PAGO += nEmprestimo
													TRB4->(MsUnLock())
												Else
													RecLock("TRB4",.F.)
														TRB4->FJ3_PAGO -= nEmprestimo
													TRB4->(MsUnLock())
												EndIf
										EndIf

										cSuperior := TRB4->FJ3_CTASUP
										TRB4->(dbSkip(-1))
									EndDo

									TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

									If lAnalitico .And. nEmprestimo > 0
										// Pesquisa na matriz de totais, os totais de contas a pagar
										nAscan := Ascan( aTotais[6], {|e| e[1] == dDataTrab})
										If nAscan == 0
											Aadd( aTotais[6], {dDataTrab,nEmprestimo})
										Else
											aTotais[6][nAscan][2] += nEmprestimo // Contabiliza os totais de emprestimos
										Endif
										// Verifica se esta no periodo solicitado
									//	nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
									//	If nAscan > 0
											RecLock(cAliasEmp,.T.)
											(cAliasEmp)->DataX	 := dDataTrab
											If (Val(Left(cPeriodo,2)) != 1)
												dUlti := dDataTrab+nResto
												(cAliasEmp)->Periodo := DTOC(dDataPri)+" a "+DTOC(dUlti) //aPeriodo[nAscan][2]
										Else
												(cAliasEmp)->Periodo := DTOC(dDataTrab)
										EndIf
											//(cAliasEmp)->Periodo := aPeriodo[nAscan][2]
											(cAliasEmp)->NUMERO	 := SEH->EH_NUMERO
											(cAliasEmp)->BANCO	 := SEH->EH_BANCO
											(cAliasEmp)->AGENCIA := SEH->EH_AGENCIA
											(cAliasEmp)->CONTA	  := SEH->EH_CONTA
											(cAliasEmp)->EMISSAO := SEH->EH_DATA
											(cAliasEmp)->SALDO   := nEmprestimo
											(cAliasEmp)->APELIDO := "SEH"
											(cAliasEmp)->CHAVE	  := xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
											MsUnlock()
									//	Endif
									Endif
								Endif
							Else
								If SEH->EH_DATA == dDataTrab .And. SEH->EH_DATA > dDataBase
									nEmprestimo := xMoeda(SEH->EH_VALOR,1,nMoeda,dDataTrab)

									RecLock("TRB4",.F.)
										TRB4->FJ3_PAGO += nEmprestimo
									TRB4->(MsUnLock())

									cSuperior := TRB4->FJ3_CTASUP // Conta Superior
									cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
									nCont     := TRB4->(Recno())

									//Procurar nas superiores e somar ou subtrair
									Do While ! TRB4->(BOF()) .and. (!Empty(cSuperior))

										//Somar ou Subtrair conforme campo FJ3_IDENTI
										If (cSuperior == TRB4->FJ3_CONTAG)
												If (cIdenti == '1')
													RecLock("TRB4",.F.)
														TRB4->FJ3_PAGO += nEmprestimo
													TRB4->(MsUnLock())
												Else
													RecLock("TRB4",.F.)
														TRB4->FJ3_PAGO -= nEmprestimo
													TRB4->(MsUnLock())
												EndIf
										EndIf

										cSuperior := TRB4->FJ3_CTASUP
										TRB4->(dbSkip(-1))
									EndDo

									TRB4->(dbGoto(nCont))// Posiciona no ultimo registro
								Endif
							EndIf
						EndIf
						dbSelectArea("SEH")
						dbSkip()
					EndDo
					DbGoTo(nRecSeh) // Para evitar outro SEEK

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se existe Aplicacoes a serem resgatadas no dia ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )//.And. ;
						If SEH->EH_NATUREZ >= TRB4->FJ3_SEDINI .And. SEH->EH_NATUREZ <= TRB4->FJ3_SEDFIM 
							If SEH->EH_APLEMP == "APL"
								If (Empty(SEH->EH_DATARES) .And. dDataTrab == dDataBase ) .Or. (SEH->EH_DATARES == dDataTrab)
									nAplicacao := xMoeda(SEH->EH_SALDO,1,nMoeda,dDataTrab)
								Else
									nAplicacao := 0
								EndIf
								DbSelectArea("SE9")
								DbSetOrder(1)
								DbSeek(xFilial()+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
								DbSelectArea("SEH")

								If (Empty(SEH->EH_DATARES) .And. dDataTrab == dDataBase) .Or. (SEH->EH_DATARES == dDataTrab)
									If !SEH->EH_TIPO $ cAplCotas
										aCalc :=	Fa171Calc(dDataTrab)
										nAplicacao += xMoeda((aCalc[5]-aCalc[2]-aCalc[3]-aCalc[4]),1,nMoeda,dDataTrab)										
									Else
										aCalc := {0,0,0,0,0,0}
										DbSelectArea("SE0")
										SE0->(DbSetOrder(2)) // E0_FILIAL+E0_BANCO+E0_AGENCIA+E0_CONTA+E0_CONTRAT+DTOS(E0_DATA)+E0_SUBCTA
										SE0->(MsSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO)+DTOS(dDataTrab)))
										Aadd(aAplic,{	SEH->EH_CONTRAT,SEH->EH_BCOCONT,SEH->EH_AGECONT,;
															Transform(SEH->EH_SALDO,"@E 999,999,999.99"),;
															Transform(SE9->E9_VLRCOTA,cPicture),;
															SE0->E0_VALOR})
										DbSelectArea("SEH")
										nAscan := Ascan(aAplic, {|e|	e[1] == SEH->EH_CONTRAT .And.;
																			e[2] == SEH->EH_BCOCONT .And.;
																			e[3] == SEH->EH_AGECONT})
										If nAscan > 0
											aCalc	:=	Fa171Calc(dDataTrab,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,aAplic[nAscan][6],(SEH->EH_SLDCOTA * aAplic[nAscan][6]))
											nAplicacao := xMoeda((aCalc[1]-(aCalc[2]+aCalc[3]+aCalc[4])),1,nMoeda,dDataTrab)	
										Endif
									EndIf
								EndIf

								//Soma nas entidades e superiores
								RecLock("TRB4",.F.)
									TRB4->FJ3_REC += nAplicacao
								TRB4->(MsUnLock())

								cSuperior := TRB4->FJ3_CTASUP // Conta Superior
								cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
								nCont     := TRB4->(Recno())

								//Procurar nas superiores e somar ou subtrair
								Do While ! TRB4->(BOF()) .And. (!Empty(cSuperior))

									//Somar ou Subtrair conforme campo FJ3_IDENTI
									If (cSuperior == TRB4->FJ3_CONTAG)
											If (cIdenti == '1')
												RecLock("TRB4",.F.)
													TRB4->FJ3_REC += nAplicacao
												TRB4->(MsUnLock())
											Else
												RecLock("TRB4",.F.)
													TRB4->FJ3_REC -= nAplicacao
												TRB4->(MsUnLock())
											EndIf
									EndIf

									cSuperior := TRB4->FJ3_CTASUP
									TRB4->(dbSkip(-1))
								EndDo

								TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

								If lAnalitico .And. nAplicacao > 0
									// Pesquisa na matriz de totais, os totais de contas a pagar
									nAscan := Ascan( aTotais[7], {|e| e[1] == dDataTrab})
									If nAscan == 0
										Aadd( aTotais[7], {dDataTrab,nAplicacao})
									Else
										aTotais[7][nAscan][2] += nAplicacao // Contabiliza os totais de Aplicacoes
									Endif
									// Verifica se esta no periodo solicitado
								//	nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
								//	If nAscan > 0
										RecLock(cAliasApl,.T.)
										(cAliasApl)->DataX	:= dDataTrab
										If (Val(Left(cPeriodo,2)) != 1)
											dUlti := dDataPri+nResto
											(cAliasApl)->Periodo := DTOC(dDataPri)+" a "+DTOC(dUlti) //aPeriodo[nAscan][2]
									Else
											(cAliasApl)->Periodo := DTOC(dDataTrab)
									EndIf
										//(cAliasApl)->Periodo	:= aPeriodo[nAscan][2]
										(cAliasApl)->NUMERO	:= SEH->EH_NUMERO
										(cAliasApl)->BANCO	:= SEH->EH_BANCO
										(cAliasApl)->AGENCIA	:= SEH->EH_AGENCIA
										(cAliasApl)->CONTA	:= SEH->EH_CONTA
										(cAliasApl)->EMISSAO	:= SEH->EH_DATA
										(cAliasApl)->SALDO	:= nAplicacao
										(cAliasApl)->APELIDO	:= "SEH"
										(cAliasApl)->CHAVE	:= xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
										MsUnlock()
								//	Endif
								Endif
							Endif
						EndIf
						dbSelectArea("SEH")
						dbSkip()
					EndDo

				EndIf//Endif do laplicacoes

				If lLibCheq // Verifica cheques nao liberados

					//Tratamento para Gestao corporativa visando garantir que sejam processadas apenas as filiais realmente diferentes.
					//Exemplo:
					//Empresa = Exclusiva
					//U.Negocio = Exclusiva
					//Filial = Compartilhada
					//Somente ao se alterar o valor de xFilial() e que a rotina tem que reprocessar
					If xFilial("SEF") != cFilSEF
						cFilSEF := xFilial("SEF")

						cFiltro := "EF_FILIAL='"+xFilial("SEF")+"'.And."
						cFiltro += "EF_NUM<>'"+Space(Len(SEF->EF_NUM))+"'.And."
						cFiltro += "!EF_IMPRESS$'AC'.And."
						cFiltro += "EF_LIBER<>'S'.And."
						cFiltro += "EF_CART<>'R'"
						dbSelectArea("SEF")
						cIndTmp := CriaTrab(,.F.)
						IndRegua("SEF",cIndTmp,"EF_FILIAL+DTOS(EF_DATA)+EF_LIBER",,cFiltro)
						nIndSEF := RetIndex("SEF")
						nIndSEF++

						While Sef->(!Eof()) .And. SEF->EF_DATA<=dDataAte .And. SEF->EF_LIBER$" N" .And. SEF->EF_FILIAL == xFilial("SEF") //.And.;
							If SEF->EF_NATUR >= TRB4->FJ3_SEDINI .And. SEF->EF_NATUR <= TRB4->FJ3_SEDFIM

								If dDataTrab == SEF->EF_DATA

									If SEF->EF_DATA < dDataBase // Se o cheque nao foi liberado e estiver anterior a data inicial do fluxo de caixa, assume a data base para exibir este cheque.
										nAscan := 1
									Else
										nAscan := Ascan(aPeriodo, {|e| e[1] == SEF->EF_DATA})
									Endif

									// Se não for cheque sobre titulos, assume como saida de caixa
									If !AllTrim(SEF->EF_ORIGEM) $ "FINA390TIT"

										RecLock("TRB4",.F.)
											TRB4->FJ3_PAGO += SEF->EF_VALOR
										TRB4->(MsUnLock())

										cSuperior := TRB4->FJ3_CTASUP // Conta Superior
										cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
										nCont     := TRB4->(Recno())

										//Procurar nas superiores e somar ou subtrair
										Do While ! TRB4->(BOF()) .And. (!Empty(cSuperior))

											//Somar ou Subtrair conforme campo FJ3_IDENTI
											If (cSuperior == TRB4->FJ3_CONTAG)
													If (cIdenti == '1')
														RecLock("TRB4",.F.)
															TRB4->FJ3_PAGO += SEF->EF_VALOR
														TRB4->(MsUnLock())
													Else
														RecLock("TRB4",.F.)
															TRB4->FJ3_PAGO -= SEF->EF_VALOR
														TRB4->(MsUnLock())
													EndIf
											EndIf

											cSuperior := TRB4->FJ3_CTASUP
											TRB4->(dbSkip(-1))
										EndDo

										TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

									Endif

									If lAnalitico
										RecLock(cAliasChq,.T.)
										(cAliasChq)->DataX	:= If(SEF->EF_DATA < dDataBase,dDataBase,SEF->EF_DATA)
										If (Val(Left(cPeriodo,2)) != 1)
											dUlti := dDataPri+nResto
											(cAliasChq)->Periodo := DTOC(dDataPri)+" a "+DTOC(dUlti) //aPeriodo[nAscan][2]
									Else
											(cAliasChq)->Periodo := DTOC(dDataTrab)
									Endif
										//(cAliasChq)->Periodo	:= aPeriodo[nAscan][2]
										(cAliasChq)->NUMERO	:= SEF->EF_NUM
										(cAliasChq)->BANCO	:= SEF->EF_BANCO
										(cAliasChq)->AGENCIA	:= SEF->EF_AGENCIA
										(cAliasChq)->CONTA	:= SEF->EF_CONTA
										(cAliasChq)->SALDO	:= SEF->EF_VALOR
										(cAliasChq)->APELIDO	:= "SEF"
										(cAliasChq)->CHAVE	:= xFilial("SEF")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)
										If SEF->EF_DATA < dDataBase // Se o cheque nao foi liberado e estiver anterior a data inicial
																			// do fluxo de caixa, assume a data base para exibir este cheque.
											nAscan := 1
										Else
											nAscan := Ascan( aTotais[8], {|e| e[1] == SEF->EF_DATA})
										Endif
										If nAscan == 0 .Or. Len(aTotais[8]) == 0
											Aadd( aTotais[8], {If(SEF->EF_DATA < dDataBase,dDataBase,SEF->EF_DATA),SEF->EF_VALOR})
										Else
											aTotais[8][nAscan][2] += SEF->EF_VALOR // Contabiliza os totais de cheques pendentes
										Endif
									Endif
								Endif
							Endif
							DbSelectArea("SEF")
							DbSkip()
						EndDo

						dbSelectArea("SEF")
						dbClearFil()
						RetIndex("SEF")
						If !Empty(cIndTmp)
							FErase (cIndTmp+OrdBagExt())
						Endif
						dbSetOrder(1)
						dbSelectArea("SM0")
						If Empty(FwFilial("SEF"))
							Exit
						EndIf
					Endif

				EndIf//cheques não liberados

				If lReceber .And. (cRNatIniAnt != TRB4->FJ3_SEDINI .Or. cRNatFimAnt != TRB4->FJ3_SEDFIM .or. dRDtTrabAnt != dDataTrab )// Titulos a Receber SE1
					dRDtTrabAnt := dDataTrab
					cRNatIniAnt := TRB4->FJ3_SEDINI
					cRNatFimAnt := TRB4->FJ3_SEDFIM
					cAlias		:= "SE1"
					cCampo		:= "E1"

					InsertNat("R", TRB4->FJ3_SEDINI, TRB4->FJ3_SEDFIM)
					(cAliasSE1)->(DbGoTop())
					(cAliasSE1)->(DbGoTo(Recno()))

					While (cAliasSE1)->(!(EoF())) //IndRegua
						nDiasRet := 0

						IncProc(STR0055 + STR0056) //"Processando titulos a "###"Receber"
						dDataVenc := (cAliasSE1)->E1_VENCREA

						If !Empty((cAliasSE1)->(E1_TITPAI))
							If (nPosTitPai := AScan(aTitulos, {|titulos| titulos[DEF_POS_TITPAI] == RTrim((cAliasSE1)->(E1_FILIAL+E1_TITPAI))})) > 0
								dDataVenc := aTitulos[nPosTitPai][DEF_POS_DTTRAB]
							ElseIf SE1->(MsSeek(xFilial("SE1", (cAliasSE1)->(E1_FILIAL)) + RTrim((cAliasSE1)->(E1_TITPAI))))
								dDataVcOri := (cAliasSE1)->(E1_VENCTO)
								If DTOS(DataValida(dDataVcOri)) == DToS(SE1->E1_VENCREA) .And. !Empty(SE1->E1_PORTADO)
									If SA6->(MsSeek(xFilial("SA6", SE1->E1_FILORIG) + SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA)))
										nDiasRet := SA6->A6_RETENCA
										For nX := 1 To nDiasRet
											dDataVenc := DataValida(dDataVenc + 1,.T.)
										Next
										cChaveTit	:= SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)
										AAdd (aTitulos, {cChaveTit, dDataVenc})
									EndIf
								Endif
							EndIf
						ElseIf (nPosTitPai := AScan(aTitulos, {|titulos| titulos[DEF_POS_TITPAI]  ==;
							RTrim((cAliasSE1)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))})) > 0
							dDataVenc := aTitulos[nPosTitPai][DEF_POS_DTTRAB]
						ElseIf FN022SITCB((cAliasSE1)->E1_SITUACA) [2]
							dDataVcOri := (cAliasSE1)->E1_VENCTO
							If DToS(DataValida(dDataVcOri)) == DToS((cAliasSE1)->E1_VENCREA)
								SA6->(MsSeek(xFilial("SA6") + (cAliasSE1)->(E1_PORTADO + E1_AGEDEP + E1_CONTA)))
								nDiasRet := SA6->A6_RETENCA
								For nX := 1 To nDiasRet
									dDataVenc := DataValida(dDataVenc + 1,.T.)
								Next
								cChaveTit	:= (cAliasSE1)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)
								AAdd (aTitulos, {cChaveTit, dDataVenc})
							Endif
						Endif

						//Se a data de vencto. nao ultrapassar a ultima data da consulta e nao for um adiantamento
						If dDataTrab == dDataVenc .And.;   //se vencimento for o dia processado
							(!(cAliasSE1)->E1_TIPO $ MVRECANT + IIf(!cPaisLoc $"ARG|CHI", MVPAGANT, "") .Or. ;
							((cAliasSE1)->E1_TIPO $ MVRECANT + IIf(!cPaisLoc $"ARG|CHI",MVPAGANT, "") .And. ;
							(cAliasSE1)->E1_EMISSAO>dDataBase)) // Se for um adiantamento, considera se for emissao futura, pois ele ainda nao estara no saldo bancario

							DbSelectArea("SE1")
							SE1->(MsGoTo((cAliasSE1)->TITRECNO))

							DbSelectArea("SE1")
							If lFc021Fil
								cFilterUser := ExecBlock("FC021FIL", .F., .F., {cAlias} )
							Endif
							// Se nao existir filtro de usuario, ou se o filtro retornar uma expressao valida para o registro atual do titulo, entao processsa o registro.
							If Empty(cFilterUser) .Or. (&cFilterUser)
								dDataBx := (cAliasSE1)->E1_BAIXA
								dDataBx := Iif(!Empty(dDataBx), dDataBx + nDiasRet, dDataBx)
								If DataValida(dDataBx,.T.) > dDataBase .And. lConsDtBase

										nSaldoTit := SaldoTit(	(cAliasSE1)->E1_PREFIXO,;
																	(cAliasSE1)->E1_NUM,;
																	(cAliasSE1)->E1_PARCELA,;
																	(cAliasSE1)->E1_TIPO,;
																	(cAliasSE1)->E1_NATUREZA,;
																	"R",;
																	(cAliasSE1)->E1_CLIENTE,;
																	nMoeda,;
																	(cAliasSE1)->E1_VENCREA,;
																	dDataBase,;
																	(cAliasSE1)->E1_LOJA,,;
																	If(cPaisLoc=="BRA", (cAliasSE1)->E1_TXMOEDA, 0), 2)

									// Se o titulo foi baixado e a data da baixa eh maior que a database, os campos SDACRES e SDDECRES utilizados na SaldoTit
									// estao zerados pois o titulo foi baixado, entao deve considerar os campos ACRESC e DECRESC do para recompor o saldo.
									nSaldoTit += ( (cAliasSE1)->E1_ACRESC - (cAliasSE1)->E1_DECRESC )
								Else
									// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
									lTxMoeda := SM2->(MsSeek(DataValida(dDataTrab,.T.))) .And. SM2->&("M2_MOEDA" + AllTrim(Str(nMoeda))) != 0
									nSaldoTit := xMoeda((cAliasSE1)->E1_SALDO	+;
														(cAliasSE1)->E1_SDACRES	-;
														(cAliasSE1)->E1_SDDECRE	,;
														(cAliasSE1)->E1_MOEDA	,;
														nMoeda                            	,;
														If(lTxMoeda,DataValida(dDataTrab,.T.), dDataBase),,If(cPaisLoc=="BRA",(cAliasSE1)->E1_TXMOEDA,0))
								EndIf

								nDesconto := FaDescFin(cAliasSe1,dDataBase,nSaldoTit,1)
								nSaldoTit -= nDesconto
								// Se titulo do Template Gem
								If HasTemplate("LOT") .And. !Empty((cAliasSE1)->E1_NCONTR)
									aAuxGem		:= ExecTemplate("CMDtPrc",.F.,.F.,{(cAliasSe1)->E1_PREFIXO,(cAliasSe1)->E1_NUM ,(cAliasSe1)->E1_PARCELA ,(cAliasSe1)->E1_VENCREA ,(cAliasSe1)->E1_VENCREA})
									nSaldoTit	+= aAuxGem[2]
								Endif

								If Abs(nSaldoTit) > 0.0001
									// Verifica a situacao, somente se nao for Contas a Receber.
									If !(FN022SITCB( (cAliasSe1)->E1_SITUACA )[3])
										// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
										nCiclos	:=	1

										DO CASE
										CASE cSinal == '-' //Forma utilizada ate 28/02/2008
											RecLock("TRB4", .F.)
											If (cAliasSE1)->E1_TIPO $ cAbatim + MVRECANT + MVPAGANT
												//Soma na propria linha da natureza
												TRB4->FJ3_REC -= nSaldoTit
											Else
												//Soma na propria linha da natureza
												TRB4->FJ3_REC += nSaldoTit
											EndIf
											TRB4->(MsUnLock())
										CASE cSinal == '+' //Forma utilizada a partir de 28/02/2008
											RecLock("TRB4", .F.)
											If (cAliasSE1)->E1_TIPO $  cAbatim
												//Soma na propria linha da natureza
												TRB4->FJ3_REC -= nSaldoTit
											Else
												TRB4->FJ3_REC += nSaldoTit
											Endif
											TRB4->(MsUnLock())
										ENDCASE

										cSuperior := TRB4->FJ3_CTASUP // Conta Superior
										cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
										nCont     := TRB4->(Recno())

										//Procurar nas superiores e somar ou subtrair
										Do While ! TRB4->(BOF()) .And. (!Empty(cSuperior))

											//Somar ou Subtrair conforme campo FJ3_IDENTI
											If (cSuperior == TRB4->FJ3_CONTAG)
												If (cIdenti == '1')
													DO CASE
													CASE cSinal == '-' //Forma utilizada ate 28/02/2008
														RecLock("TRB4",.F.)
														If (cAliasSE1)->E1_TIPO $ cAbatim + MVRECANT + MVPAGANT
															TRB4->FJ3_REC -= nSaldoTit
														Else
															//Soma na propria linha da natureza
															TRB4->FJ3_REC += nSaldoTit
														EndIf
														TRB4->(MsUnLock())
													CASE cSinal == '+' //Forma utilizada a partir de 28/02/2008
														RecLock("TRB4",.F.)
														If (cAliasSE1)->E1_TIPO $  cAbatim
															//Soma na propria linha da natureza
															TRB4->FJ3_REC -= nSaldoTit
														Else
															//Soma na propria linha da natureza
															TRB4->FJ3_REC += nSaldoTit
														Endif
														TRB4->(MsUnLock())
													ENDCASE
												Else
													Do Case
													CASE cSinal == '-' //Forma utilizada ate 28/02/2008
														RecLock("TRB4",.F.)
														If (cAliasSE1)->E1_TIPO $ cAbatim + MVRECANT + MVPAGANT
															//Soma na propria linha da natureza
															TRB4->FJ3_REC += nSaldoTit
														Else
															//Soma na propria linha da natureza
															TRB4->FJ3_REC -= nSaldoTit
														EndIf
														TRB4->(MsUnLock())
													CASE cSinal == '+' //Forma utilizada a partir de 28/02/2008
														RecLock("TRB4",.F.)
														If (cAliasSE1)->E1_TIPO $  cAbatim
															//Soma na propria linha da natureza
															TRB4->FJ3_REC += nSaldoTit
														Else
															//Soma na propria linha da natureza
															TRB4->FJ3_REC -= nSaldoTit
														Endif
														TRB4->(MsUnLock())
													ENDCASE
												EndIf
											EndIf

											cSuperior := TRB4->FJ3_CTASUP
											TRB4->(dbSkip(-1))
										EndDo

										TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

										If lAnalitico // Analitico
											For nX := 1 To nCiclos
												cCliFor := (cAliasSE1)->E1_CLIENTE
												// Posiciona no cliente ou fornecedor para buscar o nome
												DbSelectArea("SA1")
												SA1->(DbSetOrder(1))
												SA1->(MsSeek(xFilial("SA1") + cCliFor + (cAliasSE1)->E1_LOJA))
												DbSelectArea(cAliasSe1)
												RecLock(cAliasAnaR, .T.)
												If nX == 1
													nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
													(cAliasAnaR)->DataX   := dDataTrab
													If (Val(Left(cPeriodo,2)) != 1)
														dUlti := dDataPri+nResto
														(cAliasAnaR)->Periodo := DTOC(dDataPri)+" a "+DTOC(dUlti) //aPeriodo[nAscan][2]
													Else
														(cAliasAnaR)->Periodo := DToC(dDataTrab)
													EndIf
												Else
													nAscan := AScan(aPeriodo, {|e| e[1] == (cAliasSE1)->E2_EMISSAO})
													(cAliasAnaR)->DataX   := (cAliasSe1)->E2_EMISSAO
													If (Val(Left(cPeriodo,2)) != 1)
														dUlti := dDataPri+nResto
														(cAliasAnaR)->Periodo := DToC(dDataPri) + " a " + DToC(dUlti) //aPeriodo[nAscan][2]
													Else
														(cAliasAnaR)->Periodo := DToC(dDataTrab)
													EndIf
												Endif
												(cAliasAnaR)->FILIAL	:= (cAliasSE1)->E1_FILIAL
												(cAliasAnaR)->PREFIXO	:= (cAliasSE1)->E1_PREFIXO
												(cAliasAnaR)->NUM		:= (cAliasSE1)->E1_NUM
												(cAliasAnaR)->PARCELA	:= (cAliasSE1)->E1_PARCELA
												(cAliasAnaR)->TIPO		:= (cAliasSE1)->E1_TIPO
												(cAliasAnaR)->CLIFOR	:= cCliFor

												// Se o cadastro de clientes/fornecedores estiver compartilhado, obtem o nome do clientes/fornecedor do cadastro
												If Empty(cCompSA1)
													(cAliasAnaR)->NOMCLIFOR := SA1->A1_NOME
												Else
													(cAliasAnaR)->NOMCLIFOR := (cAliasSE1)->E1_NOMCLI
												Endif
												(cAliasAnaR)->LOJA := (cAliasSE1)->E1_LOJA
												cIdentific :=		(cAliasSE1)->E1_FILIAL	+;
																	(cAliasSE1)->E1_PREFIXO +;
																	(cAliasSE1)->E1_NUM     +;
																	(cAliasSE1)->E1_PARCELA +;
																	(cAliasSE1)->E1_TIPO    +;
																	(cAliasSE1)->E1_CLIENTE	+;
																	(cAliasSE1)->E1_LOJA
												(cAliasAnaR)->Chave		:= cIdentific
												(cAliasAnaR)->Apelido	:= "SE1"

												If (cAliasSE1)->E1_TIPO $ MVRECANT+MVPAGANT .And. nX == 1 .And. lPAFUTFL
													(cAliasAnaR)->SALDO      := nSaldoTit * -1
												Else
													(cAliasAnaR)->SALDO      := nSaldoTit
												Endif

												nAscan := AScan(aSx3Box, {|e| e[2] = (cAliasSE1)->E1_SITUACA})
												If nAscan > 0
													(cAliasAnaR)->Situacao  := AllTrim(aSx3Box[nAscan][3])	// Descricao da situacao.
												Endif
												(cAliasAnaR)->PORTADO	:= (cAliasSE1)->E1_PORTADO
												(cAliasAnaR)->AGEDEP	:= (cAliasSE1)->E1_AGEDEP
												(cAliasAnaR)->CONTA		:= (cAliasSE1)->E1_CONTA

												MsUnlock()
												//Ponto de entrada para atualizar o valor dos novos campos inclusos no arquivo tmp
												If lFc021atrb
													ExecBlock("FC021ATRB",.F.,.F.,{cAliasAnaR,cAliasSe1,cCampo})
												EndIf

												// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber da data de trabalho.
												nAscan := Ascan( aTotais[2], {|e| e[1] == (cAliasAnaR)->DataX})
												If nAscan == 0
													If (cAliasSE1)->E1_TIPO $ cAbatim
														Aadd( aTotais[2], {(cAliasAnaR)->DataX,(cAliasAnaR)->SALDO*-1})
													Else
														Aadd( aTotais[2], {(cAliasAnaR)->DataX,(cAliasAnaR)->SALDO})
													Endif
												Else
													If (cAliasSE1)->E1_TIPO $ cAbatim
														aTotais[2][nAscan][2] -= (cAliasAnaR)->SALDO // Contabiliza os totais de titulos
													Else
														aTotais[2][nAscan][2] += (cAliasAnaR)->SALDO // Contabiliza os totais de titulos
													EndIf
												Endif
											Next nX
										Endif
									EndIf
								EndIf
							Endif
						Endif
						DbSelectArea(cAliasSE1)
						(cAliasSE1)->(DbSkip())
					EndDo
					ClrTmpNat(.T.)
				EndIf

				If lPagar .And. (cPNatIniAnt != TRB4->FJ3_SEDINI .Or. cPNatFimAnt != TRB4->FJ3_SEDFIM .or. dPDtTrabAnt != dDataTrab)//Titulos a Pagar SE2
					dPDtTrabAnt := dDataTrab
					cPNatIniAnt := TRB4->FJ3_SEDINI
					cPNatFimAnt := TRB4->FJ3_SEDFIM
					cAlias		:= "SE2"
					cCampo		:= "E2"
					
					InsertNat("P", TRB4->FJ3_SEDINI, TRB4->FJ3_SEDFIM)
					(cAliasSE2)->(DbGoTop())
					(cAliasSE2)->(DbGoTo(Recno()))

					While (cAliasSE2)->(!(EoF())) //IndRegua
						nDiasRet := 0

						IncProc(STR0055 + STR0057)

						//Se a data de vencto. nao ultrapassar a ultima data da consulta e nao for um adiantamento
						If dDataTrab == (cAliasSe2)->E2_VENCREA .And.;   //se vencimento for o dia processado
							(!(cAliasSe2)->E2_TIPO $ MVRECANT+IIf(!cPaisLoc $"ARG|CHI",MVPAGANT,"") .Or. ;
							((cAliasSe2)->E2_TIPO $ MVRECANT+IIf(!cPaisLoc $"ARG|CHI",MVPAGANT,"") .And. ;
							(cAliasSe2)->E2_EMISSAO>dDataBase)) // Se for um adiantamento, considera se for emissao futura, pois ele ainda nao estara no saldo bancario
							DbSelectArea("SE2")
							SE2->(MsGoTo((cAliasSe2)->TITRECNO))

							DbSelectArea("SE2")
							If lFc021Fil
								cFilterUser := ExecBlock("FC021FIL", .F., .F., {cAlias} )
							Endif
							// Se nao existir filtro de usuario, ou se o filtro retornar uma expressao valida para o registro atual do titulo, entao processsa o registro.
							If Empty(cFilterUser) .Or. (&cFilterUser)
								If DataValida((cAliasSe2)->E2_BAIXA + nDiasRet,.T.) > dDataBase .And. lConsDtBase
										nSaldoTit := SaldoTit(	(cAliasSe2)->E2_PREFIXO,;
																	(cAliasSe2)->E2_NUM,;
																	(cAliasSe2)->E2_PARCELA,;
																	(cAliasSe2)->E2_TIPO,;
																	(cAliasSe2)->E2_NATUREZA,;
																	"P",;
																	(cAliasSe2)->E2_FORNECE,;
																	nMoeda,(cAliasSe2)->E2_VENCREA,;
																	dDataBase,;
																	(cAliasSe2)->E2_LOJA,,;
																	If(cPaisLoc=="BRA",(cAliasSe2)->E2_TXMOEDA,0),2)

									// Se o titulo foi baixado e a data da baixa eh maior que a database, os campos SDACRES e SDDECRES utilizados na SaldoTit
									// estao zerados pois o titulo foi baixado, entao deve considerar os campos ACRESC e DECRESC do para recompor o saldo.
									nSaldoTit += ( (cAliasSe2)->E2_ACRESC - (cAliasSe2)->E2_DECRESC )
								Else
									// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
									lTxMoeda := SM2->(MsSeek(DataValida(dDataTrab,.T.))) .And. SM2->&("M2_MOEDA"+Alltrim(Str(nMoeda))) != 0
									nSaldoTit := xMoeda((cAliasSe2)->E2_SALDO		+;
														(cAliasSe2)->E2_SDACRES	-;
														(cAliasSe2)->E2_SDDECRE  ,;
														(cAliasSe2)->E2_MOEDA		,;
														nMoeda                            	,;
														If(lTxMoeda,DataValida(dDataTrab,.T.), dDataBase),,If(cPaisLoc=="BRA",(cAliasSe2)->E2_TXMOEDA,0))
								EndIf

								If Abs(nSaldoTit) > 0.0001
									// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
									nCiclos	:=	1

									Do Case
										CASE cSinal == '-' //Forma utilizada ate 28/02/2008
											RecLock("TRB4",.F.)
											If (cAliasSe2)->E2_TIPO $ cAbatim + MVRECANT + MVPAGANT
												//Soma na propria linha da natureza
												TRB4->FJ3_PAGO -= nSaldoTit
											Else
												//Soma na propria linha da natureza
												TRB4->FJ3_PAGO += nSaldoTit
											EndIf
											TRB4->(MsUnLock())
										CASE cSinal == '+' //Forma utilizada a partir de 28/02/2008
											RecLock("TRB4",.F.)
											If (cAliasSe2)->E2_TIPO $  cAbatim + MVPAGANT
												TRB4->FJ3_PAGO -= nSaldoTit
											Else
												TRB4->FJ3_PAGO += nSaldoTit
											Endif
											TRB4->(MsUnLock())
									EndCase

									cSuperior := TRB4->FJ3_CTASUP // Conta Superior
									cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
									nCont     := TRB4->(Recno())

									//Procurar nas superiores e somar ou subtrair
									Do While ! TRB4->(BoF()) .And. (!Empty(cSuperior))

										//Somar ou Subtrair conforme campo FJ3_IDENTI
										If (cSuperior == TRB4->FJ3_CONTAG)
											If (cIdenti == '1')
												Do Case
													CASE cSinal == '-' //Forma utilizada ate 28/02/2008
														RecLock("TRB4",.F.)
														If (cAliasSe2)->E2_TIPO $ cAbatim + MVRECANT + MVPAGANT
															//Soma na propria linha da natureza
															TRB4->FJ3_PAGO -= nSaldoTit
														Else
															//Soma na propria linha da natureza
															TRB4->FJ3_PAGO += nSaldoTit
														EndIf
														TRB4->(MsUnLock())
													CASE cSinal == '+' //Forma utilizada a partir de 28/02/2008
														RecLock("TRB4",.F.)
														If (cAliasSe2)->E2_TIPO $  cAbatim + MVPAGANT
															TRB4->FJ3_PAGO -= nSaldoTit
														Else
															TRB4->FJ3_PAGO += nSaldoTit
														Endif
														TRB4->(MsUnLock())
												EndCase
											Else
												Do Case
												Case cSinal == '-' //Forma utilizada ate 28/02/2008
													RecLock("TRB4",.F.)
													If (cAliasSe2)->E2_TIPO $ cAbatim + MVRECANT + MVPAGANT
														//Soma na propria linha da natureza
														TRB4->FJ3_PAGO += nSaldoTit
													Else
														//Soma na propria linha da natureza
														TRB4->FJ3_PAGO -= nSaldoTit
													EndIf
													TRB4->(MsUnLock())
												Case cSinal == '+' //Forma utilizada a partir de 28/02/2008
													RecLock("TRB4",.F.)
													If (cAliasSe2)->E2_TIPO $  cAbatim + MVPAGANT
														TRB4->FJ3_PAGO -= nSaldoTit
													Else
														TRB4->FJ3_PAGO += nSaldoTit
													EndIf
													TRB4->(MsUnLock())
												EndCase
											EndIf
										EndIf

										cSuperior := TRB4->FJ3_CTASUP
										TRB4->(DbSkip(-1))
									EndDo

									TRB4->(DbGoTo(nCont))// Posiciona no ultimo registro

									If lAnalitico // Analitico
										For nX := 1 To nCiclos
											cCliFor := (cAliasSe2)->E2_FORNECE
											// Posiciona no cliente ou fornecedor para buscar o nome
											DbSelectArea("SA2")
											SA2->(DbSetOrder(1))
											SA2->(MsSeek(xFilial("SA2")+cCliFor+(cAliasSe2)->E2_LOJA))
											DbSelectArea(cAliasSe2)
											RecLock(cAliasAnaP,.T.)
											If nX == 1
												nAscan := AScan(aPeriodo, {|e| e[1] == dDataTrab})
												(cAliasAnaP)->DataX   := dDataTrab
												If (Val(Left(cPeriodo,2)) != 1)
													dUlti := dDataPri+nResto
													(cAliasAnaP)->Periodo := DToC(dDataPri)+" a "+DToC(dUlti) //aPeriodo[nAscan][2]
												Else
													(cAliasAnaP)->Periodo := DToC(dDataTrab)
												Endif
											Else
												nAscan := AScan(aPeriodo, {|e| e[1] == (cAliasSe2)->E2_EMISSAO})
												(cAliasAnaP)->DataX   := (cAliasSe2)->E2_EMISSAO

												If (Val(Left(cPeriodo,2)) != 1)
													dUlti := dDataPri+nResto
													(cAliasAnaP)->Periodo := DToC(dDataPri)+" a "+DToC(dUlti) //aPeriodo[nAscan][2]
												Else
													(cAliasAnaP)->Periodo := DToC(dDataTrab)
												Endif
											EndIf
											(cAliasAnaP)->FILIAL	:= (cAliasSe2)->E2_FILIAL
											(cAliasAnaP)->PREFIXO	:= (cAliasSe2)->E2_PREFIXO
											(cAliasAnaP)->NUM		:= (cAliasSe2)->E2_NUM
											(cAliasAnaP)->PARCELA	:= (cAliasSe2)->E2_PARCELA
											(cAliasAnaP)->TIPO		:= (cAliasSe2)->E2_TIPO
											(cAliasAnaP)->CLIFOR	:= cCliFor
											// Se o cadastro de clientes/fornecedores estiver compartilhado, obtem o nome do clientes/fornecedor do cadastro
											If Empty(cCompSA2)
												(cAliasAnaP)->NOMCLIFOR := SA2->A2_NOME
											Else
												(cAliasAnaP)->NOMCLIFOR := SE2->E2_NOMFOR
											EndIf
											(cAliasAnaP)->LOJA    := (cAliasSe2)->E2_LOJA
											cIdentific :=	(cAliasSe2)->E2_FILIAL+;
																(cAliasSe2)->E2_PREFIXO +;
																(cAliasSe2)->E2_NUM     +;
																(cAliasSe2)->E2_PARCELA +;
																(cAliasSe2)->E2_TIPO    +;
																(cAliasSe2)->E2_FORNECE+;
																(cAliasSe2)->E2_LOJA
											(cAliasAnaP)->Chave      := cIdentific
											(cAliasAnaP)->Apelido    := "SE2"

											If (cAliasSe2)->E2_TIPO $ MVRECANT+MVPAGANT .And. nX == 1	.And. lPAFUTFL
												(cAliasAnaP)->SALDO      := nSaldoTit * -1
											Else
												(cAliasAnaP)->SALDO      := nSaldoTit
											EndIf

											(cAliasAnaP)->(MsUnlock())
											//Ponto de entrada para atualizar o valor dos novos campos inclusos no arquivo tmp
											If lFc021atrb
												ExecBlock("FC021ATRB",.F.,.F.,{cAliasAnaP,cAliasSe2,cCampo})
											EndIf

											// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber da data de trabalho.
											nAscan := AScan( aTotais[1], {|e| e[1] == (cAliasAnaP)->DataX})
											If nAscan == 0
												If (cAliasSe2)->E2_TIPO $ cAbatim
													AAdd( aTotais[1], {(cAliasAnaP)->DataX,(cAliasAnaP)->SALDO*-1})
												Else
													AAdd( aTotais[1], {(cAliasAnaP)->DataX,(cAliasAnaP)->SALDO})
												EndIf
											Else
												If (cAliasSe2)->E2_TIPO $ cAbatim
													aTotais[1][nAscan][2] -= (cAliasAnaP)->SALDO // Contabiliza os totais de titulos
												Else
													aTotais[1][nAscan][2] += (cAliasAnaP)->SALDO // Contabiliza os totais de titulos
												Endif
											EndIf
										Next nX
									EndIf
								EndIf
							Endif
						Endif
						DbSelectArea(cAliasSe2)
						(cAliasSe2)->(DbSkip())
					EndDo
					ClrTmpNat(.F., .T.)
				EndIf

				If lPedCompra
					While (cAliasPc)->(!(EoF()))
						If (cAliasPc)->NATUREZA >= TRB4->FJ3_SEDINI .And. (cAliasPc)->NATUREZA <= TRB4->FJ3_SEDFIM
							dDataPedCom := dDataTrab
							If !lConsDtBase .And. dDataTrab == dDatabase
								If (cAliasPc)->EMISSAO <= dDataTrab
									dDataPedCom := (cAliasPc)->EMISSAO
								EndIF
							EndIF
							If dDataPedCom == (cAliasPc)->EMISSAO
								RecLock("TRB4",.F.)
									TRB4->FJ3_PAGO += (cAliasPc)->SALDO
								TRB4->(MsUnLock())

								cSuperior := TRB4->FJ3_CTASUP // Conta Superior
								cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
								nCont     := TRB4->(Recno())

								//Procurar nas superiores e somar ou subtrair
								Do While ! TRB4->(BOF()) .And. (!Empty(cSuperior))

									//Somar ou Subtrair conforme campo FJ3_IDENTI
									If (cSuperior == TRB4->FJ3_CONTAG)
										If (cIdenti == '1')
											//Soma na propria linha da natureza
											RecLock("TRB4",.F.)
												TRB4->FJ3_PAGO += (cAliasPc)->SALDO
											TRB4->(MsUnLock())
										Else
											//Soma na propria linha da natureza
											RecLock("TRB4",.F.)
												TRB4->FJ3_PAGO -= (cAliasPc)->SALDO
											TRB4->(MsUnLock())
										EndIf
									EndIf

									cSuperior := TRB4->FJ3_CTASUP
									TRB4->(dbSkip(-1))
								EndDo
								TRB4->(DbGoto(nCont))
							EndIf	
						EndIf
						(cAliasPc)->(DbSkip())
					EndDo
				EndIf

				If Empty(cFwFilSEH)
					Exit
				EndIf
				DbSelectArea("SEH")
				SEH->(DbSetOrder(1))
				DbSelectArea("SM0")
				SM0->(DbSkip())
			EndDo
		EndIf

		TRB4->(DbSkip())

		If (TRB4->(EOF()))
			If (Val(Left(cPeriodo,2)) == 1 .Or. nDiasR == nResto)
				TRB4->(dbGoTop())

				Do While (TRB4->(!EOF()))
					//Calcular o disponivel de todas as contas (Recebido - Pago)
					RecLock("TRB4",.F.)
						If !empty(aFJ3Temp) .and. aFJ3Temp[len(aFJ3Temp)][1] == TRB4->FJ3_ORDEM .and. lAgrpVis//parametro novo
							aFJ3Temp[len(aFJ3Temp)][2] 	+= TRB4->FJ3_REC
							aFJ3Temp[len(aFJ3Temp)][3]  += TRB4->FJ3_PAGO
							TRB4->FJ3_DESCCG			:= Alltrim(TRB4->FJ2_DESCCG)
							aFJ3temp[len(aFJ3Temp)][4] 	:= TRB4->FJ3_LINHA 	
						Else
							AADD(aFJ3Temp,{TRB4->FJ3_ORDEM,TRB4->FJ3_REC,TRB4->FJ3_PAGO,FJ3_LINHA})
						EndIf
						
						If(lAgrpVis)	
							TRB4->FJ3_REC	:= aFJ3Temp[len(aFJ3Temp)][2]
							TRB4->FJ3_PAGO 	:= aFJ3Temp[len(aFJ3Temp)][3]				
							TRB4->FJ3_DISP 	:= aFJ3Temp[len(aFJ3Temp)][2] - aFJ3Temp[len(aFJ3Temp)][3]
						Else
							TRB4->FJ3_DISP 	:= TRB4->FJ3_REC - TRB4->FJ3_PAGO
						Endif

					TRB4->(MsUnLock())

					TRB4->(dbSkip())
				EndDo

				TRB4->(dbGoTop())

				Do While (TRB4->(!EOF()))

					If (!Empty(TRB4->FJ3_SEDINI) .And. !Empty(TRB4->FJ3_SEDFIM)) //Soh entra nas analiticas
						//Calculo das formulas digitadas pelo usuario
						CNICalc021()
					EndIf

					TRB4->(dbSkip())
				EndDo

				TRB4->(dbGoTop())

				Do While (TRB4->(!EOF()))
					nPosLine := Ascan(aFJ3temp, {|e| e[1] == TRB4->FJ3_ORDEM})
					lLastLine := TRB4->FJ3_LINHA = aFJ3temp[nPosLine][4]

					// Soh imprimir se a linha estiver como SIM no VISENT
					If (TRB4->FJ3_VISENT == '1') .and. !( lAgrpVis .and. !lLastLine)
						// Incluir no arquivo de trabalho para impressão na tela
						RecLock("cArqTmp",.T.)
							If (Val(Left(cPeriodo,2)) != 1)
								CARQTMP->CODDESC    := DTOC(dDataPri)+" a "+DTOC(dDataTrab)+" "+Space(TRB4->FJ3_COLUNA)+TRB4->FJ3_DESCCG
							Else
								CARQTMP->CODDESC    := DTOC(dDataTrab)+" "+Space(TRB4->FJ3_COLUNA)+TRB4->FJ3_DESCCG
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Inverte o saldo se assim a entidade estiver configurada ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (TRB4->FJ3_FATSLD == "2")
								CARQTMP->RECEBIDOS  := ((TRB4->FJ3_REC) * -1)
								CARQTMP->PAGOS      := ((TRB4->FJ3_PAGO) * -1)
								CARQTMP->DISPONIVEL := ((TRB4->FJ3_DISP) * -1)
							Else
								CARQTMP->RECEBIDOS  := TRB4->FJ3_REC
								CARQTMP->PAGOS      := TRB4->FJ3_PAGO
								CARQTMP->DISPONIVEL := TRB4->FJ3_DISP
							EndIf

							If (Val(Left(cPeriodo,2)) != 1)
								CARQTMP->DATAAN 	:= dDataPri
							Else
								CARQTMP->DATAAN 	:= dDataTrab
							EndIf
							CARQTMP->ORDEM 		:= TRB4->FJ3_ORDEM
						MsUnLock()
					EndIf

					RecLock("TRB4",.F.)
						//Inicializo os campos utilizados
						TRB4->FJ3_REC  := 0
						TRB4->FJ3_PAGO := 0
						TRB4->FJ3_DISP := 0
					TRB4->(MsUnLock())

					TRB4->(dbSkip())
				EndDo

				//Calcula o numero de dias que devem ser somados caso o periodo seja diferente de Diario
				If (Val(Left(cPeriodo,2))!= 1)
					nResto := CalcDias(cPeriodo, dDataTrab+1)
					nDiasR := -1 //Contador para os dias
					dDataPri := dDataTrab + 1 // Guarda a data do primeiro dia processado
				EndIf
			EndIf

			dDataTrab := dDataTrab+1

			If (Val(Left(cPeriodo,2)) != 1)
				nDiasR := nDiasR + 1 //Incrementa no contador para controlar o periodo
			EndIf

			TRB4->(dbGoTop())// Comecar de novo
		Else
			If (SEH->(EOF()))
				SEH->(dbGoTop()) //Inicia o arquivo novamente pois o arquivo de visao nao esta no fim
			EndIf

			If (SEF->(EOF()))
				SEF->(dbGoTop()) //Inicia o arquivo de baixas novamente pois o arquivo de visao nao esta no fim
			EndIf

			If lPedCompra .And. cAliasPc <> Nil
				If ((cAliasPc)->(EOF()))
					(cAliasPc)->(dbGoTop()) //Inicia o arquivo de baixas novamente pois o arquivo de visao nao esta no fim
				EndIf
			EndIf
		EndIf

		SM0->(RestArea(aAreaSM0))
		cFilAnt := cSavFil
	EndDo

	If lReceber .Or. lPagar
		dbSelectArea(cAliasTrb)
		dbCloseArea()
		dbSelectArea(cAlias)
	EndIf

	DbSelectArea("FJ3")
	DbSetOrder(1)
	DbGoTop()

	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	DbGoTop()

	//Soma o Total Geral(Recebido, pago e disponivel)
	Do While (CARQTMP->(!EOF()))

		nTotRec  := 0
		nTotPago := 0
		nTotDisp := 0

		cData := SubStr(CARQTMP->CODDESC,1,10)
		nRec := CARQTMP->(Recno())

		Do While(cData == SubStr(CARQTMP->CODDESC,1,10))

			If FJ3->(dbSeek(xFilial("FJ3")+cVisaoG+AllTrim(CARQTMP->ORDEM)))
				//Se nao tiver entidade superior deve ser somada (Soma as sinteticas)
				If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '2')
					//Se for debito

					nTotRec  += CARQTMP->RECEBIDOS
					nTotPago += CARQTMP->PAGOS 
					nTotDisp += CARQTMP->DISPONIVEL
				EndIf
			EndIf

			CARQTMP->(dbSkip())
		EndDo
		
		CARQTMP->(dbGoto(nRec))//Volta para o primeiro registro da data selecionada
		cData := SubStr(CARQTMP->CODDESC,1,10)

		Do While(cData == SubStr(CARQTMP->CODDESC,1,10))

			If FJ3->(dbSeek(xFilial("FJ3")+cVisaoG+AllTrim(CARQTMP->ORDEM)))
				If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '1') // Totaliza na entidade totalizadora por data
					RecLock("cArqTmp",.F.)
						CARQTMP->RECEBIDOS := nTotRec
						CARQTMP->PAGOS := nTotPago
						CARQTMP->DISPONIVEL := nTotDisp
					MsUnLock()
				EndIf
			EndIf

			CARQTMP->(dbSkip())
		EndDo
	EndDo

	Private aRotina := {{"", "", 0, 1},;
						{STR0031, "", 0, 2},; // "Visualizar"
							{"", "", 0, 3},;
							{"", "", 0, 4},;
							{"", "", 0, 5},;
							{"", "", 0, 3}}
	If lTitAtraso

		If lReceber
			nAtrReceber := Fc021Vencidos("SE1",lConsFil,cFilDe,cFilAte,nMoeda,cFilterSe1,lSeekVA,cTempVA)
		Endif
		If lPagar
			nAtrPagar   := Fc021Vencidos("SE2",lConsFil,cFilDe,cFilAte,nMoeda,cFilterSe2,lSeekVA,cTempVA)
		Endif
		If lComissoes
			nAtrPagar   += Fc021Vencidos("SE3",lConsFil,cFilDe,cFilAte,nMoeda)
		Endif
	Endif

	CARQTMP->(DbGoTop())

	//Passa do arquivo de trabalho para o aFluxo que sera impresso na tela
	Do While (CARQTMP->(!EOF()))
		Aadd(aFluxo, {CARQTMP->CODDESC,CARQTMP->RECEBIDOS,CARQTMP->PAGOS,CARQTMP->DISPONIVEL,0,0,0,0,0})
		CARQTMP->(dbSkip())
	EndDo

	//CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nLimCred)
	SaldoEnt(aFluxo, nBancos, nCaixas, nAtrReceber, nAtrPagar,nLimCred,cVisaoG)
	nValBancos := nBancos + nLimCred

	If lAnalitico
		dbSelectArea("cArqAnaP")
		COPY TO "AnaP.TXT" SDF

		dbSelectArea("cArqAnaR")
		COPY TO "AnaR.TXT" SDF
	Endif

	//Ordena aFluxo pela data
	aSize := MsAdvSize()
	aadd( aObjects, {  30,  70, .T., .T.} )
	aadd( aObjects, {  20, 180, .T., .T., .T. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects )
	DEFINE MSDIALOG oDlg TITLE STR0032 + STR0197 + Capital(SubStr(cMoeda,3)) FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Fluxo de Caixa" //"Fluxo de Caixa" //" em "
	oDlg:lMaximized := .T.

	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,50,50,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	If !ExistBlock("FC021MENU")
		@  0,  1 TO 48,396 OF oPanel PIXEL
	Else
		@  0,  1 TO 48,460 OF oPanel PIXEL
	Endif
	@  6,  6 TO 44,152 PROMPT STR0033 OF oPanel PIXEL //"Titulos Atrasados"
	@  6,156 TO 44,311 PROMPT STR0034 OF oPanel PIXEL //"Saldos"
	@ 16, 11 SAY STR0035   OF oPanel PIXEL //"A Pagar"
	@ 29, 11 SAY STR0036 OF oPanel PIXEL //"A Receber"
	@ 16,162 SAY STR0037  OF oPanel PIXEL //"Em &Caixa"
	@ 29,162 SAY STR0038 OF oPanel PIXEL //"Em &Bancos"
	@ 14, 73 MSGET nAtrPagar   SIZE 76,10 OF oPanel WHEN .F. PICTURE TM(nAtrPagar,21,TamSX3("E2_SALDO")[2]) PIXEL Hasbutton
	@ 29, 73 MSGET nAtrReceber SIZE 76,10 OF oPanel WHEN .F. PICTURE TM(nAtrPagar,21,TamSX3("E1_SALDO")[2]) PIXEL Hasbutton
	@ 14,231 MSGET oGet01 VAR nCaixas     SIZE 76,10 OF oPanel WHEN .T. VALID { || If(oGet01:lModified,;
																				(CalcSaldo(aFluxo,nValBancos,nCaixas,nAtrReceber,nAtrPagar,0),oFluxo:Refresh(.T.)), Nil), .T. } PICTURE "@E 999,999,999.99" PIXEL Hasbutton
	@ 29,231 MSGET oGet02 VAR nValBancos  SIZE 76,10 OF oPanel WHEN .T. VALID { || If(oGet02:lModified,;
																				(CalcSaldo(aFluxo,nValBancos,nCaixas,nAtrReceber,nAtrPagar,0),nBancos:=nValbancos,oFluxo:Refresh(.T.)),Nil), .T. } PICTURE "@E 999,999,999.99" PIXEL Hasbutton
	If !lPanelFin  //Nao chamado pelo Painel Financeiro
		@ 06,315 BUTTON STR0039 SIZE 32, 13 OF oPanel PIXEL ACTION Grafico(oDlg,aFluxo,nMoeda,cTit,cVisaoG) //"&Grafico"
		@ 06,351 BUTTON STR0040 SIZE 32, 13 OF oPanel PIXEL ACTION oDlg:End() //"&Sair"
		@ 19,315 BUTTON STR0041 SIZE 32, 13 OF oPanel PIXEL ACTION MsgInfo("Essa funcionalidade não está disponível quando utilizada a Visão Gerencial","Não disponível")//Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo,nLimCred) //"Si&mulação"
		@ 19,351 BUTTON STR0042 SIZE 32, 13 OF oPanel PIXEL ACTION Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda,lLimCred,cVisaoG) //"&Relatório"

		@ 32,315 BUTTON STR0189 SIZE 68, 13 OF oPanel PIXEL ACTION Fc021Excel(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico)  //"&Exportar para Excel"

		If ExistBlock("FC021MENU")
			@ 32,386 BUTTON "Salvar Fluxo" SIZE 68, 13 OF oPanel PIXEL ACTION ExecBlock("FC021MENU",.F.,.F.,oFluxo)
		EndIf
	EndIf

	@ aPosObj[2,1]-63, aPosObj[2,2] LISTBOX oFluxo FIELDS ;
		HEADER cTit   ,; //"Dia","Semana","Decendio","Quinzena","Mes"
				STR0043,; //"Entradas"
				STR0044,; //"Saidas"
				STR0045,; //"Saldo do Dia"
				STR0046,; //"Var.Dia"
				STR0047,; //"Entr.Acumul."
				STR0048,; //"Saida Acumul."
				STR0049,; //"Saldo Acumul."
				STR0050 SIZE aPosObj[2,3],aPosObj[2,4]+259; //"Var. Acumul."
		COLSIZES If(Left(cPeriodo,2)="01",30,45),;
		GetTextWidth(0,"BBBBBBB"),;
			GetTextWidth(0,"BBBBBBB"),;
			GetTextWidth(0,"BBBBBBB"),;
			GetTextWidth(0,"BBBB"),;
			GetTextWidth(0,"BBBBBBBBB"),;
			GetTextWidth(0,"BBBBBBBBB"),;
			GetTextWidth(0,"BBBBBBBBB"),;
			GetTextWidth(0,"BBBB");
		OF oDlg ON DBLCLICK (If(lAnalitico, FluxoAna(cAliasAnaP, cAliasAnaR,cAliasPc, , ,cAliasEmp,cAliasApl,aTmpAnaCtrc[1],If((Val(Left(cPeriodo,2)) == 1),(SubStr(aFluxo[oFluxo:nAt][DATAFLUXO],1,10)),(SubStr(aFluxo[oFluxo:nAt][DATAFLUXO],1,23))),aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo,cAliasChq,oFluxo,nLimCred,aTmpAnaSol[1]), IW_MsgBox(STR0051 + STR0023,STR0198,"STOP"))) PIXEL //"Não foi selecionado Processa analitico! Impossivel consultar."


	If Len(aFluxo) > 0
		oFluxo:SetArray(aFluxo)
		oFluxo:bLine := { || {xPadC(Transform(aFluxo[oFluxo:nAt,DATAFLUXO],""),45),;
									Transform(aFluxo[oFluxo:nAt,ENTRADAS				]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SAIDAS				]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SALDODIA				]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,VARIACAODIA			]	,"@r 9999999.99%"),;
									Transform(aFluxo[oFluxo:nAt,ENTRADASACUMULADAS]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SAIDASACUMULADAS	]	,"@e 99999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,SALDOACUMULADO		]	,"@e 999,999,999,999,999.99"),;
									Transform(aFluxo[oFluxo:nAt,VARIACAOACUMULADA	]	,"@r 9999999.99%")}}
	Endif



		If !lPanelFin
		oFluxo:bRClicked       := { |o,nX,nY| oMenu:Activate(nX,nY,oFluxo) }
		oFluxo:oWnd:bRClicked  := { |o,nX,nY| oMenu:Activate(nX,nY,oFluxo) }
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define os itens do Menu PopUp                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MENU oMenu POPUP
			MENUITEM STR0039	Action Grafico(oDlg,aFluxo,nMoeda,cTit,cVisaoG) //"&Grafico"
			MENUITEM STR0041  Action MsgInfo("Essa funcionalidade não está disponível quando utilizada a Visão Gerencial","Não disponível")//Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo,nLimCred) //"Si&mulação"
			MENUITEM STR0042 	Action Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda,lLimCred,cVisaoG) //"&Relatório"
			MENUITEM STR0052 	Action (If(lAnalitico, FluxoAna(aArqTmp[2], aArqTmp[4], cAliasPc, cAliasPv, aArqCo[4],cAliasEmp,cAliasApl,aTmpAnaCtrc[1],aFluxo[oFluxo:nAt][DATAFLUXO],aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo,cAliasChq,oFluxo,nLimCred,aTmpAnaSol[1]), IW_MSGBOX(STR0051 + STR0023,STR0198,"STOP"))) //"Visualiza etapa" //"Fluxo Analitico"###"Não foi selecionado Processa analitico! Impossivel consultar."
			//Desabilitar botão de exportação para Excel quando SmartClient HTML
			MENUITEM STR0053  Action Fc021Excel(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico) // "Exportar para Excel"
		
			If ExistBlock("FC021MENU")
				MENUITEM STR0236  Action ExecBlock("FC021MENU",.F.,.F.,oFluxo)
			Endif
		ENDMENU
	Endif
	oFluxo:Align := CONTROL_ALIGN_ALLCLIENT

	If lPanelFin  //Chamado pelo Painel Financeiro
		aButtonTxt := {}
		AADD(aButtonTxt,{STR0039,STR0039,{||Grafico(oDlg,aFluxo,nMoeda,cTit,cVisaoG)}}) //"&Grafico"
		AADD(aButtonTxt,{STR0041,STR0041,{||MsgInfo("Essa funcionalidade não está disponível quando utilizada a Visão Gerencial","Não disponível")/*Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo,nLimCred)*/}}) //"Si&mulação"
		AADD(aButtonTxt,{STR0042,STR0042,{||Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda,lLimCred,cVisaoG)}}) //"&Relatório"
		AADD(aButtonTxt,{STR0232,STR0053,{||Fc021Excel(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico)}}) //"&Exportar para Excel"
		
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
			,{||oDlg:End()},,aButtonTxt)
	Else
		ACTIVATE MSDIALOG oDlg
	Endif

	If aArqTmp[2] != Nil .And. Select(aArqTmp[2]) > 0

		(aArqTmp[2])->(DbCloseArea())
		(aArqTmp[4])->(DbCloseArea())

		//Deleta tabelas temporárias no banco de dados
		If _oFINC0211 <> Nil
			_oFINC0211:Delete()
			_oFINC0211 := Nil
		Endif

		If _oFINC0212 <> Nil
			_oFINC0212:Delete()
			_oFINC0212 := Nil
		Endif

	Endif

	If cAliasEmp != Nil
		(cAliasEmp)->(DbCloseArea())


		//Deleta tabela temporária no banco dados
		If _oFINC0214 <> Nil
			_oFINC0214:Delete()
			_oFINC0214 := Nil
		Endif
	Endif
	If cAliasApl != Nil
		(cAliasApl)->(DbCloseArea())

		//Deleta tabela temporária no banco de dados
		If _oFINC0215 <> Nil
			_oFINC0215:Delete()
			_oFINC0215 := Nil
		Endif
	Endif
	If cAliasChq != Nil
		(cAliasChq)->(DbCloseArea())

		//Deleta tabela temporária no banco de dados
		If _oFINC0218 <> Nil
			_oFINC0218:Delete()
			_oFINC0218 := Nil
		Endif
	Endif

	If aTmpAnaCtrc[1] != Nil
		(aTmpAnaCtrc[1])->(DbCloseArea())
	Endif

	If cAliasAnaR != Nil
		(cAliasAnaR)->(dbCloseArea())
		If _oFINC021b  <> Nil
			_oFINC021b:Delete()
			_oFINC021b := Nil
		Endif
	Endif

	If cAliasAnaP != Nil
		(cAliasAnaP)->(dbCloseArea())
		If _oFINC021c  <> Nil
			_oFINC021c:Delete()
			_oFINC021c := Nil
		Endif
	Endif

	DestroyTMP(lReceber, lPagar)

	If cAliasPc != NIL
		(cAliasPc)->(dbCloseArea())
		If _oFINC0216 <> Nil
			_oFINC0216:Delete()
			_oFINC0216 := Nil
		Endif
	Endif

	TRB4->(dbCloseArea())
	CARQTMP->(dbCloseArea())

	If _oFINC021d <> Nil
		_oFINC021d:Delete()
		_oFINC021d := Nil
	Endif

	If _oFINC021g <> Nil
		_oFINC021g:Delete()
		_oFINC021g := Nil
	Endif

	If oTmpVA <> Nil
		oTmpVA:Delete()
		oTmpVA := Nil
	Endif

	__cInsNat1 := NIL
	__cInsNat2 := NIL

	dDataBase := dBkpDtBase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR770   ºAutor  ³Microsiga           º Data ³  08/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula saldo com base na formula digitada                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CNICalc021()
Local cSuperior
Local cIdenti
Local nCont
Local nFator

cSuperior := TRB4->FJ3_CTASUP // Conta Superior
cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
nCont     := TRB4->(Recno())

//Procurar nas superiores e somar ou subtrair
Do While ! TRB4->(BOF()) .And. (!Empty(cSuperior))

	//Ralizar calculo com a formula digitada pelo usuario
	If (cSuperior == TRB4->FJ3_CONTAG)
			If (Left(TRB4->FJ3_FORMUL, 7) == "ROTINA=")
				nFator := &(Subs(TRB4->FJ3_FORMUL, 8))

				RecLock("TRB4",.F.)
					TRB4->FJ3_DISP *= nFator
				TRB4->(MsUnLock())

			ElseIf Left(TRB4->FJ3_FORMUL, 6) == "FATOR="
				nFator := &(Subs(TRB4->FJ3_FORMUL, 7))

				RecLock("TRB4",.F.)
					TRB4->FJ3_DISP *= nFator
				TRB4->(MsUnLock())

			Elseif Left(TRB4->FJ3_FORMUL,6 ) == "SALDO="
				nFator := &(Subs(TRB4->FJ3_FORMUL, 7))

				RecLock("TRB4",.F.)
					TRB4->FJ3_DISP := nFator
				TRB4->(MsUnLock())

		    EndIf
	EndIf

	cSuperior := TRB4->FJ3_CTASUP
	TRB4->(dbSkip(-1))
EndDo

TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINC021   ºAutor  ³Microsiga           º Data ³  09/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula os dias que devem ser calculados caso o periodo    º±±
±±º          ³ seja diferente de dias                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CalcDias(cPeriodos, dDataTrab)

Local nResto := 0
Local nPeriodo := Val(Left(cPeriodos,2))

Do Case
Case nPeriodo == 7  // Semanal
	// Verifica quantos dias faltam para a proxima semana
	nResto := 6
	If Dow(dDataTrab) != 1
		nResto := 7-Dow(dDataTrab)
	EndIf
Case nPeriodo == 10 // Decendial
	nResto := 9
	// Verifica quantos dias faltam para o proximo decendio
	If Day(dDataTrab) < 10
		nResto := 10-Day(dDataTrab)
	ElseIf Day(dDataTrab) > 10 .And. Day(dDataTrab) < 20
		nResto := 20-Day(dDataTrab)
	ElseIf Day(dDataTrab) > 20
		nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
	Endif
Case nPeriodo == 15 // Quinzenal
	nResto := 14
	// Verifica quantos dias faltam para a proxima quinzena
	If Day(dDataTrab) < 15
		nResto := 15-Day(dDataTrab)
	Else
		nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
	Endif
Case nPeriodo == 30 // Mensal
	// Verifica quantos dias faltam para o proximo mes
	nResto := LastDay(dDataTrab)-dDataTrab
EndCase


Return (nResto)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SaldoEnt  ºAutor  ³Microsiga           º Data ³  09/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula saldo da entidade totalizadora                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SaldoEnt(aFluxo, nBancos, nCaixas, nAtrReceber, nAtrPagar,nLimCred,cVisaoG)
Local nEntrAnt  := 0,;
	  nSaidAnt  := 0,;
	  aArea     := GetArea()
Local nX := 0

dbSelectArea("FJ3")
dbSetOrder(1)
dbGoTop()

dbSelectArea("cArqTmp")
dbSetOrder(1)
dbGoTop()

//Calcula o saldo acumulado para o primeiro dia da consulta
Do While (CARQTMP->(!EOF()))
	If FJ3->(dbSeek(xFilial("FJ3")+cVisaoG+AllTrim(CARQTMP->ORDEM)))
		If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '1')
			// Calcula o saldo inicial
			aFluxo[CARQTMP->(Recno())][SALDOACUMULADO] := (nBancos + nCaixas + nLimCred + nAtrReceber - nAtrPagar)
			nSaldoAc := aFluxo[CARQTMP->(Recno())][SALDOACUMULADO]
			Exit
		EndIf
	EndIf

	CARQTMP->(dbSkip())
EndDo

CARQTMP->(dbGoTop())

ProcRegua(Len(aFluxo))
For nX := 1 to Len(aFluxo)

	IncProc(STR0058)  //"Calculando saldos"

	If FJ3->(dbSeek(xFilial("FJ3")+cVisaoG+AllTrim(CARQTMP->ORDEM)))
		If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '1')

			// Calcula o saldo da data
			aFluxo[nX][SALDODIA] := aFluxo[nX][ENTRADAS]-aFluxo[nX][SAIDAS]

			// Calcula a variacao do dia
			aFluxo[nX][VARIACAODIA] := (aFluxo[nX][SAIDAS]/aFluxo[nX][ENTRADAS]) * 100

			// Calcula os creditos acumulados ate a data
			aFluxo[nX][ENTRADASACUMULADAS] := (nEntrAnt + aFluxo[nX][ENTRADAS])
			nEntrAnt := aFluxo[nX][ENTRADASACUMULADAS]

			// Calcula os debitos acumulados ate a data
			aFluxo[nX][SAIDASACUMULADAS] := (nSaidAnt + aFluxo[nX][SAIDAS])
			nSaidAnt := aFluxo[nX][SAIDASACUMULADAS]

			// Calcula o saldo acumulado ate a data
			aFluxo[nX][SALDOACUMULADO] := (aFluxo[nX][ENTRADAS]-aFluxo[nX][SAIDAS])+nSaldoAc
			nSaldoAc := aFluxo[nX][SALDOACUMULADO]

			// Calcula a variacao acumulada
			aFluxo[nX][VARIACAOACUMULADA] := (aFluxo[nX][SAIDASACUMULADAS]/aFluxo[nX][ENTRADASACUMULADAS])*100
		EndIf
	EndIf

	CARQTMP->(dbSkip())

Next

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fc021SolicºAutor  ³Microsiga           º Data ³  10/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa as solicitacoes de fundos a serem exibidas no     º±±
±±º          ³ fluxo                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN - Argentina                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Solic( cAliasSol, dUltData, lConsFil, cFilDe, cFilAte, lAnalitico, aFluxo, nMoeda, aTotais, aPeriodo, lFiliais )
Local nValSol		:= 0
Local nAscan		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConsFil
   cFilDe  := xFilial("FJA")
   cFilAte := xFilial("FJA")
Endif

aStru     := FJA->(DbStruct())
cAliasTrb := "FINC021"

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("FJA") + " FJA "
cQuery += "WHERE "

If lFiliais
	cQuery += "	FJA.FJA_FILIAL IN	(" + cLisFil + ") AND "
Else
	cQuery += "	FJA.FJA_FILIAL	>=	'" + cFilDe + "' AND "
	cQuery += "	FJA.FJA_FILIAL	<=	'" + cFilAte + "' AND "
EndIf

cQuery += "	FJA.D_E_L_E_T_	=	' ' AND "
cQuery += "	FJA.FJA_DATAPR	>=	'" + DToS(dDataBase) + "' AND "
cQuery += "	FJA.FJA_DATAPR	<=	'" + DToS(dUltData) + "' AND "
cQuery += "	(FJA.FJA_ESTADO	= '1' OR FJA.FJA_ESTADO	= '2') AND "	// Solicitacoes pendentes e aprovadas
cQuery += "	FJA.FJA_ORDPAG	=	' ' AND "	// Nao associadas a Ordem de Pagamento
cQuery += "	FJA.FJA_MOEDA	=	'" + AllTrim(StrZero(nMoeda,2)) +"'"

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})

While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc(STR0247) //"Processando Solicitações de Fundo"
	dDataTrab := DataValida((cAliasTrb)->FJA_DATAPR,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a data de vencto. nao ultrapassar a ultima data do relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dDataTrab <= dUltData
		nValSol := xMoeda((cAliasTrb)->FJA_VALOR,Val((cAliasTrb)->FJA_MOEDA),nMoeda)
		If Abs(nValSol) > 0.0001
			// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
			nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
			// Verifica se esta no periodo solicitado
			If nAscan > 0
				aFluxo[nAscan][ENTRADAS] += nValSol
			Endif
			If lAnalitico .And. nAscan > 0
				RecLock(cAliasSol,.T.)
				(cAliasSol)->PERIODO	:= aPeriodo[nAscan][2]
				(cAliasSol)->DATAX		:= dDataTrab
				(cAliasSol)->FILIAL		:= (cAliasTrb)->FJA_FILIAL
				(cAliasSol)->SOLFUN		:= (cAliasTrb)->FJA_SOLFUN
				(cAliasSol)->FORNEC		:= (cAliasTrb)->FJA_FORNEC
				(cAliasSol)->LOJA		:= (cAliasTrb)->FJA_LOJA
				(cAliasSol)->DATAPR		:= (cAliasTrb)->FJA_DATAPR
				(cAliasSol)->SALDO		:= nValSol
				(cAliasSol)->CHAVE		:= xFilial("FJA")+(cAliasTrb)->(FJA_FORNEC+FJA_LOJA+FJA_SOLFUN)
				(cAliasSol)->APELIDO	:= "FJA"
				MsUnlock()
				// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
				// da data de trabalho.
				nAscan := Ascan( aTotais[10], {|e| e[1] == dDataTrab})
				If nAscan == 0
					Aadd( aTotais[10], {dDataTrab,nValSol})
				Else
					aTotais[10][nAscan][2] += nValSol // Contabiliza os totais de Solicitacoes.
				Endif
			Endif
		EndIf
	Endif
	(cAliasTrb)->(dbSkip())
Enddo

DbSelectArea(cAliasTrb)
DbCloseArea()
DbSelectArea("FJA")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fc021GerTiºAutor  ³Microsiga           º Data ³  12/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de titulos com base nos valores utilizados na simu-º±±
±±º          ³ lacao.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN - Argentina                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc021GerTi()
Local nPosDelet		:= Len(aHeader)+1
Local nPosTipo		:= GDFieldPos("_SI_TIPO",aHeader)
Local nX			:= 0

Private nFc021Lin	:= 0
Private cFc021Tipo	:= ""
Private cCadastro	:= STR0250 //"Inclusão de Titulo"
Private lF050Auto	:= .F.
Private lF040Auto	:= .F.
Private lAltera		:= .F. //Utilizada no AxInclui da receita
Private Inclui		:= .T. //Utilizada no AxInclui da despesa

For nX := 1 To Len(aCols)

	//Omite linhas deletadas
	If aCols[nX][nPosDelet]
		Loop
	EndIf

	//Omite linha sem tipo definido
	If Empty(aCols[nX][nPosTipo])
		Loop
	EndIf

	nFc021Lin := nX

	//Geracao dos titulos
	If aCols[nX][nPosTipo] == "D" //Despesa
		cFc021Tipo := "D"
		AxInclui("SE2",0,3,,"FC021PreTi")

    ElseIf aCols[nX][nPosTipo] == "R" //Receita
		cFc021Tipo := "R"
		AxInclui("SE1",0,3,,"FC021PreTi")

    EndIf

Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FC021PreTiºAutor  ³Microsiga           º Data ³  12/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche o titulo com os valores definidos na simulacao    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaFin - Argentina                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FC021PreTi()
Local nPosData	:= GDFieldPos("_SI_DATA",aHeader)
Local nPosValor := GDFieldPos("_SI_VALOR",aHeader)
Local nPosHist	:= GDFieldPos("_SI_HISTOR",aHeader)

If cFc021Tipo == "D" //Despesa

	M->E2_TIPO		:= "PRE" //Titulo Provisorio
	M->E2_VALOR		:= aCols[nFc021Lin][nPosValor]
	M->E2_HIST		:= aCols[nFc021Lin][nPosHist]
	M->E2_EMISSAO	:= aCols[nFc021Lin][nPosData]
	M->E2_BAIXA 	:= CriaVar( "E2_BAIXA" , .F. )
	M->E2_ORIGEM    := "FINC021"
	M->E2_SALDO     := aCols[nFc021Lin][nPosValor]
	M->E2_FILORIG   := cFilAnt

ElseIf cFc021Tipo == "R" //Receita

	M->E1_TIPO		:= "PRE" //Titulo Provisorio
	M->E1_VALOR		:= aCols[nFc021Lin][nPosValor]
	M->E1_HIST		:= aCols[nFc021Lin][nPosHist]
	M->E1_EMISSAO	:= aCols[nFc021Lin][nPosData]
	M->E1_EMIS1     := aCols[nFc021Lin][nPosData]
	M->E1_SALDO     := aCols[nFc021Lin][nPosValor]
	M->E1_BAIXA 	:= CriaVar( "E1_BAIXA" , .F. )
	M->E1_STATUS    := "A"
	M->E1_SITUACA   := "0"
	M->E1_ORIGEM    := "FINC021"
	M->E1_FILORIG   := cFilAnt

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fc021ExcAnºAutor  ³Microsiga           º Data ³  12/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa a exportacao analitica da consulta do fluxo de    º±±
±±º          ³ caixa para o Excel                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaFin - Argentina                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021ExcAn(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar)
Local cArquivo	:= CriaTrab(,.F.)+".xml"
Local cDirDocs	:= MsDocPath()
Local oExcelApp	:= Nil
Local cPath		:= AllTrim(GetTempPath())
Local oExcel	:= FWMSEXCEL():New()

If !ApOleClient('MsExcel')
	MsgAlert(STR0190) //'MsExcel nao instalado'
	Return
EndIf

If Select("CARQANAP") > 0 //Contas a Pagar

	CARQANAP->(DbGoTop())
	If CARQANAP->(!Eof())

		oExcel:AddworkSheet(STR0008) //"Titulos a Pagar"
		oExcel:AddTable(STR0008,STR0008) //"Titulos a Pagar"

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0008		,STR0008	,STR0200	,1		,1			,.F.	) //"Titulos a Pagar"###"Filial"
		oExcel:AddColumn(STR0008		,STR0008	,STR0079	,1		,1			,.F.	) //"Titulos a Pagar"###"Prefixo"
		oExcel:AddColumn(STR0008		,STR0008	,STR0080	,1		,1			,.F.	) //"Titulos a Pagar"###"Num"
		oExcel:AddColumn(STR0008		,STR0008	,STR0081	,1		,1			,.F.	) //"Titulos a Pagar"###"Parcela"
		oExcel:AddColumn(STR0008		,STR0008	,STR0082	,1		,1			,.F.	) //"Titulos a Pagar"###"Tipo"
		oExcel:AddColumn(STR0008		,STR0008	,STR0083	,1		,1			,.F.	) //"Titulos a Pagar"###"CliFor"
		oExcel:AddColumn(STR0008		,STR0008	,STR0064	,1		,1			,.F.	) //"Titulos a Pagar"###"NomCliFor"
		oExcel:AddColumn(STR0008		,STR0008	,STR0084	,1		,1			,.F.	) //"Titulos a Pagar"###"Loja"
		oExcel:AddColumn(STR0008		,STR0008	,STR0026	,3		,3			,.F.	) //"Titulos a Pagar"###"Saldo"

		While CARQANAP->(!Eof())
			oExcel:AddRow(STR0008,STR0008,{CARQANAP->FILIAL,CARQANAP->PREFIXO,CARQANAP->NUM,CARQANAP->PARCELA,CARQANAP->TIPO,CARQANAP->CLIFOR,CARQANAP->NOMCLIFOR,CARQANAP->LOJA,CARQANAP->SALDO}) //"Titulos a Pagar"
		CARQANAP->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANAR") > 0 //Contas a Receber

	CARQANAR->(DbGoTop())
	If CARQANAR->(!Eof())

		oExcel:AddworkSheet(STR0007) //"Titulos a Receber"
		oExcel:AddTable(STR0007,STR0007) //"Titulos a Receber"

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0007		,STR0007	,STR0200	,1		,1			,.F.	) //"Titulos a Receber"###"Filial"
		oExcel:AddColumn(STR0007		,STR0007	,STR0079	,1		,1			,.F.	) //"Titulos a Receber"###"Prefixo"
		oExcel:AddColumn(STR0007		,STR0007	,STR0080	,1		,1			,.F.	) //"Titulos a Receber"###"Num"
		oExcel:AddColumn(STR0007		,STR0007	,STR0081	,1		,1			,.F.	) //"Titulos a Receber"###"Parcela"
		oExcel:AddColumn(STR0007		,STR0007	,STR0082	,1		,1			,.F.	) //"Titulos a Receber"###"Tipo"
		oExcel:AddColumn(STR0007		,STR0007	,STR0088	,1		,1			,.F.	) //"Titulos a Receber"###"CliFor"
		oExcel:AddColumn(STR0007		,STR0007	,STR0064	,1		,1			,.F.	) //"Titulos a Receber"###"NomCliFor"
		oExcel:AddColumn(STR0007		,STR0007	,STR0084	,1		,1			,.F.	) //"Titulos a Receber"###"Loja"
		oExcel:AddColumn(STR0007		,STR0007	,STR0026	,3		,3			,.F.	) //"Titulos a Receber"###"Saldo"

		While CARQANAR->(!Eof())
			oExcel:AddRow(STR0007,STR0007,{CARQANAR->FILIAL,CARQANAR->PREFIXO,CARQANAR->NUM,CARQANAR->PARCELA,CARQANAR->TIPO,CARQANAR->CLIFOR,CARQANAR->NOMCLIFOR,CARQANAR->LOJA,CARQANAR->SALDO}) //"Titulos a Receber"
		CARQANAR->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANAPC") > 0 //Pedido de Compra

	CARQANAPC->(DbGoTop())
	If CARQANAPC->(!Eof())

		oExcel:AddworkSheet(STR0011)
		oExcel:AddTable(STR0011,STR0011)

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		If lSC7Exclus
			oExcel:AddColumn(STR0011 	,STR0011	,STR0200	,1		,1			,.F.	) //"Pedido de Compra"###"Filial"
		EndIf
		oExcel:AddColumn(STR0011		,STR0011	,STR0080	,1		,1			,.F.	) //"Pedido de Compra"###"Numero"
		oExcel:AddColumn(STR0011		,STR0011	,STR0090	,1		,4			,.F.	) //"Pedido de Compra"###"Emissao"
		oExcel:AddColumn(STR0011		,STR0011	,STR0083	,1		,1			,.F.	) //"Pedido de Compra"###"Fornecedor"
		oExcel:AddColumn(STR0011		,STR0011	,STR0064	,1		,1			,.F.	) //"Pedido de Compra"###"Nome"
		oExcel:AddColumn(STR0011		,STR0011	,STR0082	,1		,2			,.F.	) //"Pedido de Compra"###"Tipo"
		oExcel:AddColumn(STR0011		,STR0011	,STR0091	,1		,1			,.F.	) //"Pedido de Compra"###"Item"
		oExcel:AddColumn(STR0011		,STR0011	,STR0092	,1		,1			,.F.	) //"Pedido de Compra"###"Produto"
		oExcel:AddColumn(STR0011		,STR0011	,STR0026	,3		,3			,.F.	) //"Pedido de Compra"###"Valor"

		While CARQANAPC->(!Eof())
			oExcel:AddRow(STR0011, STR0011, IIf(lSC7Exclus,;
			{CARQANAPC->FILIAL, CARQANAPC->NUMERO, CARQANAPC->EMISSAO, CARQANAPC->CLIFOR, CARQANAPC->NOMCLIFOR, CARQANAPC->TIPO, CARQANAPC->ITEM, CARQANAPC->PRODUTO, CARQANAPC->SALDO}, {                   CARQANAPC->NUMERO, CARQANAPC->EMISSAO, CARQANAPC->CLIFOR, CARQANAPC->NOMCLIFOR, CARQANAPC->TIPO, CARQANAPC->ITEM, CARQANAPC->PRODUTO, CARQANAPC->SALDO}))
			CARQANAPC->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANAPV") > 0 //Pedido de venda

	CARQANAPV->(DbGoTop())
	If CARQANAPV->(!Eof())

		oExcel:AddworkSheet(STR0010) //"Pedido de Venda"
		oExcel:AddTable(STR0010,STR0010) //"Pedido de Venda"

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0010		,STR0010	,STR0080	,1		,1			,.F.	) //"Pedido de Venda"###"Numero"
		oExcel:AddColumn(STR0010		,STR0010	,STR0082	,1		,1			,.F.	) //"Pedido de Venda"###"Tipo"
		oExcel:AddColumn(STR0010		,STR0010	,STR0090	,1		,4			,.F.	) //"Pedido de Venda"###"Emissao"
		oExcel:AddColumn(STR0010		,STR0010	,STR0088	,1		,1			,.F.	) //"Pedido de Venda"###"Cliente"
		oExcel:AddColumn(STR0010		,STR0010	,STR0064	,1		,1			,.F.	) //"Pedido de Venda"###"Nome"
		oExcel:AddColumn(STR0010		,STR0010	,STR0094	,1		,1			,.F.	) //"Pedido de Venda"###"Loja Cliente"
		oExcel:AddColumn(STR0010		,STR0010	,STR0095	,1		,1			,.F.	) //"Pedido de Venda"###"Loja Entrega"
		oExcel:AddColumn(STR0010		,STR0010	,STR0026	,3		,3			,.F.	) //"Pedido de Venda"###"Valor"

		While CARQANAPV->(!Eof())
			oExcel:AddRow(STR0010,STR0010,{CARQANAPV->NUMERO,CARQANAPV->TIPO,CARQANAPV->EMISSAO,CARQANAPV->CLIFOR,CARQANAPV->NOMCLIFOR,CARQANAPV->LOJACLI,CARQANAPV->LOJAENT,CARQANAPV->SALDO}) //"Pedido de Venda"
		CARQANAPV->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANACO") > 0 //Comissoes

	CARQANACO->(DbGoTop())
	If CARQANACO->(!Eof())

		oExcel:AddworkSheet(STR0009) //"Comissões"
		oExcel:AddTable(STR0009,STR0009) //"Comissões"

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0009		,STR0009	,STR0200	,1		,1			,.F.	) //"Comissões"###"Filial"
		oExcel:AddColumn(STR0009		,STR0009	,STR0079	,1		,1			,.F.	) //"Comissões"###"Prefixo"
		oExcel:AddColumn(STR0009		,STR0009	,STR0080	,1		,1			,.F.	) //"Comissões"###"Numero"
		oExcel:AddColumn(STR0009		,STR0009	,STR0097	,1		,1			,.F.	) //"Comissões"###"Parcela"
		oExcel:AddColumn(STR0009		,STR0009	,STR0098	,1		,1			,.F.	) //"Comissões"###"Vendedor"
		oExcel:AddColumn(STR0009		,STR0009	,STR0064	,1		,1			,.F.	) //"Comissões"###"Nome"
		oExcel:AddColumn(STR0009		,STR0009	,STR0026	,3		,3			,.F.	) //"Comissões"###"Valor"

		While CARQANACO->(!Eof())
			oExcel:AddRow(STR0009,STR0009,{CARQANACO->FILIAL,CARQANACO->PREFIXO,CARQANACO->NUMERO,CARQANACO->PARCELA,CARQANACO->VEND,CARQANACO->NOMEVEND,CARQANACO->SALDO}) //"Comissões"
		CARQANACO->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANAEMP") > 0 //Emprestimos

	CARQANAEMP->(DbGoTop())
	If CARQANAEMP->(!Eof())

		oExcel:AddworkSheet(STR0076) //"Emprestimos"
		oExcel:AddTable(STR0076,STR0076) //"Emprestimos"

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0076		,STR0076	,STR0080	,1		,1			,.F.	) //"Emprestimos"###"Numero"
		oExcel:AddColumn(STR0076		,STR0076	,STR0061	,1		,1			,.F.	) //"Emprestimos"###"Banco"
		oExcel:AddColumn(STR0076		,STR0076	,STR0062	,1		,1			,.F.	) //"Emprestimos"###"Agencia"
		oExcel:AddColumn(STR0076		,STR0076	,STR0063	,1		,1			,.F.	) //"Emprestimos"###"Conta"
		oExcel:AddColumn(STR0076		,STR0076	,STR0090	,1		,4			,.F.	) //"Emprestimos"###"Emissao"
		oExcel:AddColumn(STR0076		,STR0076	,STR0026	,3		,3			,.F.	) //"Emprestimos"###"Valor"

		While CARQANAEMP->(!Eof())
			oExcel:AddRow(STR0076,STR0076,{CARQANAEMP->NUMERO,CARQANAEMP->BANCO,CARQANAEMP->AGENCIA,CARQANAEMP->CONTA,CARQANAEMP->EMISSAO,CARQANAEMP->SALDO}) //"Emprestimos"
		CARQANAEMP->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANAAPL") > 0 //Aplicacoes

	CARQANAAPL->(DbGoTop())
	If CARQANAAPL->(!Eof())

		oExcel:AddworkSheet(STR0077) //"Aplicações"
		oExcel:AddTable(STR0077,STR0077) //"Aplicações"

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0077		,STR0077	,STR0080	,1		,1			,.F.	) //"Aplicações"###"Numero"
		oExcel:AddColumn(STR0077		,STR0077	,STR0061	,1		,1			,.F.	) //"Aplicações"###"Banco"
		oExcel:AddColumn(STR0077		,STR0077	,STR0062	,1		,1			,.F.	) //"Aplicações"###"Agencia"
		oExcel:AddColumn(STR0077		,STR0077	,STR0063	,1		,1			,.F.	) //"Aplicações"###"Conta"
		oExcel:AddColumn(STR0077		,STR0077	,STR0090	,1		,4			,.F.	) //"Aplicações"###"Emissao"
		oExcel:AddColumn(STR0077		,STR0077	,STR0026	,3		,3			,.F.	) //"Aplicações"###"Valor"

		While CARQANAAPL->(!Eof())
			oExcel:AddRow(STR0077,STR0077,{CARQANAAPL->NUMERO,CARQANAAPL->BANCO,CARQANAAPL->AGENCIA,CARQANAAPL->CONTA,CARQANAAPL->EMISSAO,CARQANAAPL->SALDO}) //"Aplicações"
		CARQANAAPL->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANACHQ") > 0 //Cheques

	CARQANACHQ->(DbGoTop())
	If CARQANACHQ->(!Eof())

		oExcel:AddworkSheet(STR0255) //Cheques
		oExcel:AddTable(STR0255,STR0255) //Cheques

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0255		,STR0255	,STR0080	,1		,1			,.F.	) //"Cheques"###"Numero"
		oExcel:AddColumn(STR0255		,STR0255	,STR0061	,1		,1			,.F.	) //"Cheques"###"Banco"
		oExcel:AddColumn(STR0255		,STR0255	,STR0062	,1		,1			,.F.	) //"Cheques"###"Agencia"
		oExcel:AddColumn(STR0255		,STR0255	,STR0063	,1		,1			,.F.	) //"Cheques"###"Conta"
		oExcel:AddColumn(STR0255		,STR0255	,STR0090	,1		,4			,.F.	) //"Cheques"###"Emissao"
		oExcel:AddColumn(STR0255		,STR0255	,STR0026	,3		,3			,.F.	) //"Cheques"###"Valor"

		While CARQANACHQ->(!Eof())
			oExcel:AddRow(STR0255,STR0255,{CARQANACHQ->NUMERO,CARQANACHQ->BANCO,CARQANACHQ->AGENCIA,CARQANACHQ->CONTA,CARQANACHQ->EMISSAO,CARQANACHQ->SALDO}) //"Cheques"
		CARQANACHQ->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANACTRC") > 0 //Docto Transporte

	CARQANACTRC->(DbGoTop())
	If CARQANACTRC->(!Eof())

		oExcel:AddworkSheet(STR0256) //"Doctos. de Transporte"
		oExcel:AddTable(STR0256,STR0256) //"Doctos. de Transporte"

						//cWorkSheet	,cTable		,cColumm	,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0256		,STR0256	,STR0257	,1		,1			,.F.	) //"Doctos. de Transporte"###"Fil. Deb."
		oExcel:AddColumn(STR0256		,STR0256	,STR0258	,1		,1			,.F.	) //"Doctos. de Transporte"###"Fil. Doc"
		oExcel:AddColumn(STR0256		,STR0256	,STR0259	,1		,1			,.F.	) //"Doctos. de Transporte"###"Docto."
		oExcel:AddColumn(STR0256		,STR0256	,STR0260	,1		,1			,.F.	) //"Doctos. de Transporte"###"Serie"
		oExcel:AddColumn(STR0256		,STR0256	,STR0090	,1		,4			,.F.	) //"Doctos. de Transporte"###"Emissao"
		oExcel:AddColumn(STR0256		,STR0256	,STR0026	,3		,3			,.F.	) //"Doctos. de Transporte"###"Valor"

		While CARQANACTRC->(!Eof())
			oExcel:AddRow(STR0256,STR0256,{CARQANACTRC->FILDEB,CARQANACTRC->FILDOC,CARQANACTRC->DOC,CARQANACTRC->SERIE,CARQANACTRC->EMISSAO,CARQANACTRC->SALDO}) //"Doctos. de Transporte"
		CARQANACTRC->(DbSkip())
		EndDo
	EndIf
EndIf

If Select("CARQANASOL") > 0 //Solicitacao de Fundo

	CARQANASOL->(DbGoTop())
	If CARQANASOL->(!Eof())

		oExcel:AddworkSheet(STR0246) //"Solicitações de Fundos"
		oExcel:AddTable(STR0246,STR0246) //"Solicitações de Fundos"

						//cWorkSheet	,cTable		,cColumm				,nAlign	,nFormat	,lTotal
		oExcel:AddColumn(STR0246		,STR0246	,RetTitle("FJA_FILIAL")	,1		,1			,.F.	) //"Solicitações de Fundos"
		oExcel:AddColumn(STR0246		,STR0246	,RetTitle("FJA_SOLFUN")	,1		,1			,.F.	) //"Solicitações de Fundos"
		oExcel:AddColumn(STR0246		,STR0246	,RetTitle("FJA_FORNEC")	,1		,1			,.F.	) //"Solicitações de Fundos"
		oExcel:AddColumn(STR0246		,STR0246	,RetTitle("FJA_LOJA")	,1		,1			,.F.	) //"Solicitações de Fundos"
		oExcel:AddColumn(STR0246		,STR0246	,RetTitle("FJA_DATAPR")	,1		,4			,.F.	) //"Solicitações de Fundos"
		oExcel:AddColumn(STR0246		,STR0246	,RetTitle("FJA_VALOR")	,3		,3			,.F.	) //"Solicitações de Fundos"

		While CARQANASOL->(!Eof())
			oExcel:AddRow(STR0246,STR0246,{CARQANASOL->FILIAL,CARQANASOL->SOLFUN,CARQANASOL->FORNEC,CARQANASOL->LOJA,CARQANASOL->DATAPR,CARQANASOL->SALDO}) //"Solicitações de Fundos"
		CARQANASOL->(DbSkip())
		EndDo
	EndIf
EndIf

If !Empty(oExcel:aWorkSheet)
	oExcel:Activate()
	oExcel:GetXMLFile(cDirDocs+"\"+cArquivo)

	CpyS2T(cDirDocs+"\"+cArquivo,cPath)

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre uma planilha
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()
Else
	MsgAlert(STR0262) //"Não há valores para exportação."
EndIf

Return

//-------------------------------------------------------------------
/*/
{Protheus.doc} F021SitCob
Função para retornar as informações do cadastro de situacao de cotrança

@return aRet	 - Array contendo as seguintes informações
					[1] - lMark (utilizado apenas na ARG)
					[2] - Codigo da situacao de cobranca
					[3] - Descricao da situacao de cobranca

@author pequim

@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F021SitCob()

Local lMark		:= .T.

If aSitCob == NIL

	aSitCob := {}

	DbSelectArea("FRV")
	DbSetOrder(1)
	If MsSeek(xFilial("FRV"))
		While FRV->(!Eof()) .And. FRV->FRV_FILIAL == XFilial("FRV")
			//---------------------------------------------------------
			//Situacoes de cobranca descontadas são desconsideradas
			//pois a movimentacao ja ocorreu
			//---------------------------------------------------------
			If FRV->FRV_DESCON == "2"	//situacao de cobranca nao possui desconto
				AAdd( aSitCob, { lMark, FRV->FRV_CODIGO, Capital(FRV->FRV_DESCRI) })
			EndIf
			FRV->(DbSkip())
		EndDo
	Endif
Endif

Return aSitCob

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FincRetFils ºAutor ³ Jose.Gavetti 	º Data ³  23/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna filiais que o usuario logado tem acesso            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Filial inicial informada no range                  º±±
±±º          ³ EXPC2 - Filial final   informada no range                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPC1 - String com as filiais que o usuario tem acesso     º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FincRetFils( cFilIni, cFilFim )

Local cFils		:= ""
Local i			:= 0
Local j			:= 0
Local nTamFil   := ""

Default cFilIni	:= Space( TamSX3( "E2_FILIAL" )[1] )
Default cFilFim	:= PadR( "Z", TamSX3( "E2_FILIAL" )[1], "Z" )

nTamFil := len(cFilIni)

// --------------------------------------------------------------------------
// SIGAPSW.PRW:RSWRET()	Retorna um vetor com informacoes do ultimo usuario ou
//						grupo posicionado pela funcao PswSeek.
// RSWRET()[2][6]		Vetor contendo as empresas, cada elemento contem a
// 						empresa e a filial. Ex:"9901", se existir "@@@@"
//						significa acesso a todas as empresas.
// --------------------------------------------------------------------------
If aPswUser == nil
	PswOrder( 1 )
	PswSeek( __cUserId, .T. )
	aPswUser := PswRet()
Else
	PswOrder( 2 )
	PswSeek( aPswUser[1][2], .T. )
Endif

// Prioriza informacao do grupo?
If ( ValType( aPswUser ) == "A" ) .and. ( aPswUser[2][11] )
	For i := 1 To Len( aPswUser[1][10] )
		// Pesquisa o(s) Grupo(s) que o Usuario participa
		PswOrder( 1 )
		If PswSeek( aPswUser[1][10][i], .F. )
			aPswGrupo := FwGrpEmp(aPswUser[1][10][i])
			If ( ValType( aPswGrupo ) == "A" )
				For j := 1 To Len( aPswGrupo)
					If	aPswGrupo[j] == "@@@@"
						cFils := "@@"
						Exit
					ElseIf	SubStr( aPswGrupo[j], 1, Len(cEmpAnt) ) == cEmpAnt
						If  SubStr( aPswGrupo[j], 3, nTamFil ) >= cFilIni .And. ;
							SubStr( aPswGrupo[j], 3, nTamFil ) <= cFilFim
							cFils += SubStr( aPswGrupo[j], 3, nTamFil ) + "/"
						EndIf
					EndIf
				Next j
			EndIf
		EndIf
	Next i
// Prioriza Informacao do Usuario
Else
	If ( ValType( aPswUser ) == "A" )
		For i := 1 To Len( aPswUser[2][6] )
			If	aPswUser[2][6][i] == "@@@@"
				cFils := "@@"
				Exit
			ElseIf	SubStr( aPswUser[2][6][i], 1, 2 ) == cEmpAnt
				If  SubStr( aPswUser[2][6][i], 3, 2 ) >= cFilIni .And. ;
					SubStr( aPswUser[2][6][i], 3, 2 ) <= cFilFim
					cFils += SubStr( aPswUser[2][6][i], 3, LEN(aPswUser[2][6][i]) ) + "/"
				EndIf
			EndIf
		Next i
	EndIf
EndIf

Return cFils

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc021Grava   ³ Autor ³ Ronaldo Tapia           ³ Data ³ 13/06/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a consulta atual para visualizacao futura               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc021Grava(cAliasFIY, cCodigo, dData, cHora)                   ³±±
±±³          ³ cAliasFIY -> Alias do arquivo que contem os dados a gravar    ³±±
±±³          ³ cCodigo   -> Codigo da consulta  (por referencia)             ³±±
±±³          ³ dData     -> Data para gravacao                               ³±±
±±³          ³ cHora     -> Hora para gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	   ³ FINC021     											  			    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Grava(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico,cPeriodo,nPeriodos)
Local lRet := .T.
Local cCodigo, cHora := Left(Time(),5)

nPeriodi := Val(Left(cPeriodo,2))

If lRet
	If cCodigo # Nil
		FLZ ->(DbSetOrder(1)) // FLZ _FILIAL+FLZ _CODIGO+DTOS(FLZ _DATA)+FLZ _HORA+FLZ _CODUSR
		// Verifica se a consulta nao foi gravada
		If !FLZ ->(MsSeek(xFilial("FLZ") + cCodigo+ DTOS(dData) + cHora + __cUserID))
			MsgRun(STR0267,, { || lRet := Fc021Inc(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico,cHora,nPeriodos,nPeriodi) }  ) //"Aguarde, gravando a consulta..."
		Else
			Alert(STR0268 + Dtoc(dData) + STR0269 + Transform(cHora, "@R 99:99") )  //"Consulta já foi gravada! em "###" as "
		Endif
	Else
		MsgRun(STR0267,, { || lRet := Fc021Inc(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico,cHora,nPeriodos,nPeriodi) } ) //"Aguarde, gravando a consulta..."
	Endif
EndIf

If lRet
	Aviso("FINC021",STR0270,{"Ok"}) //"Gravação efetuada com sucesso."
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc021Inc     ³ Autor ³ Ronaldo Tapia           ³ Data ³ 13/06/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui registro na tabela FLZ e FLW                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc022Inc(cAliasFLZ, cCodigo, dData, cHora)                    ³±±
±±³          ³ cAliasFLZ -> Alias do arquivo que contem os dados a gravar    ³±±
±±³          ³ cCodigo   -> Codigo da consulta (por referencia)              ³±±
±±³          ³ dData     -> Data para gravacao                               ³±±
±±³          ³ cHora     -> Hora para gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	  ³ FINC021  												  			    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Inc(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lAnalitico,cHora,nPeriodos,nPeriodi)
Local nX
Local lRet  := .T.

// Atualiza o codigo no momento da inclusao do registro de persistencia
cCodigo := GetSx8Num("FLZ", "FLZ_CODIGO")
ConfirmSx8()

// Grava o cabecalho da persistencia
dbSelectArea("FLZ")
RecLock("FLZ",.T.)
FLZ->FLZ_FILIAL	:= xFilial("FLZ")
FLZ->FLZ_CODIGO	:= cCodigo
FLZ->FLZ_DATA		:= dDatabase
FLZ->FLZ_HORA		:= cHora
FLZ->FLZ_CODUSR	:= __cUserID
FLZ->FLZ_PERIOD	:= nPeriodi
FLZ->FLZ_QTDPER	:= nPeriodos
MsUnlock()
FkCommit()

// Grava os itens (dias) do fluxo de caixa
dbSelectArea("FLW")
For nx := 1 To Len(aFluxo)
	If !FLW->(MsSeek(xFilial("FLW")+cCodigo+aFluxo[nx][1]))
		RecLock("FLW",.T.)
		FLW->FLW_FILIAL := xFilial("FLW")
		FLW->FLW_CODIGO := cCodigo
		FLW->FLW_DATA   := CTOD(aFluxo[nx][1])
		FLW->FLW_ENTRAD := aFluxo[nx][2]
		FLW->FLW_SAIDA  := aFluxo[nx][3]
		MsUnlock()
		FkCommit()
	Endif
Next

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelectFil
Separa as filiais, inserindo aspas simples e virgula, para ser usado na clausula IN do SQL

@type Function
@author Unknown
@since 04/09/2013
@version 12
/*/
//--------------------------------------------------------------------------------------------------
Static Function SelectFil(aSelFil)
Local cFilRet	:= ""
Local nX		:= 0
Local cReturn	:= ""

For nX := 1 to Len(aSelFil)

	cFilRet += "'"
	If Len( aSelFil ) > 0
		If aScan( aSelFil, { |x|x == aSelFil[1]} ) > 0
			cFilRet += aSelFil[nX]
		EndIf
	Else
		cFilRet += "'"
	EndIf

	cFilRet += "',"

Next nX

cReturn := SubStr( cFilRet, 1, Len( cFilRet ) - 1 )

Return cReturn

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DiagRefresh
Força o refresh das gets de filias através do método SetFocus, retornando o foco para a get
do checkbox que indica se será utilizado seleção de filiais ou não

@type Function
@author Pedro Pereira Lima
@since 06/12/2017
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Static Function DiagRefresh( oObj1, oObj2, oObj3 )

oObj1:SetFocus()
oObj2:SetFocus()
oObj3:SetFocus()

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F21BcoFil
Cria a clausual IN para filtro na SE8, conforme o menor compartilhamento entre SE8 e SA6. 
@param aSelFil array, contem as filiais selecionadas
@param nTamFil Numérico, contem o tamanho da filial considerando o menor compartilhamento

@type Function
@author Karen Honda
@since 15/01/2020
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Static Function F21BcoFil( aSelFil As Array, nTamFil As Numeric) As Character
Local cReturn As Character
Local nI As Numeric

cReturn := "IN ("

For nI := 1 to Len(aSelFil)
	cReturn += "'" + Substr(aSelFil[nI],1,nTamFil) + "'"
	If nI < Len(aSelFil)
		cReturn += ", "
	EndIf	
Next nI
cReturn += ") "
Return cReturn 

/*/{Protheus.doc} CriaTMPTit
Cria as tabelas temporárias para títulos a receber e pagar.

@type 	Function
@author Rafael Riego
@since	06/04/2022
@param	lReceber, logical, verdadeiro caso deva criar as tabelas temporárias (receber)
@param	lPagar, logical, verdadeiro caso deva criar as tabelas temporárias (pagar)
@param 	aStructSE1, array, campos a serem criados nas tabelas temporárias (receber)
@param	aStructSE2, array, campos a serem criados nas tabelas temporárias (pagar)
@return	Nil
/*/
Static Function CriaTMPTit(lReceber As Logical, lPagar As Logical, aStructSE1 As Array, aStructSE2 As Array)

	Default lReceber	:= .F.
	Default lPagar		:= .F.
	Default aStructSE1	:= {}
	Default aStructSE2	:= {}

	If lReceber
		AAdd(aStructSE1, {"TITRECNO", "N", 8, 0})
		__oSE1TMP := FwTemporaryTable():New()
		__oSE1NAT := FwTemporaryTable():New()
		__oSE1TMP:SetFields(aStructSE1)
		__oSE1NAT:SetFields(aStructSE1)
		__oSE1TMP:AddIndex("1", {"E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_FILORIG", "TITRECNO"})
		__oSE1NAT:AddIndex("1", {"E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_FILORIG", "TITRECNO"})
		__oSE1TMP:AddIndex("2", {"E1_NATUREZ"})
		__oSE1NAT:AddIndex("2", {"E1_NATUREZ"})
		__oSE1TMP:Create()
		__oSE1NAT:Create()
	EndIf

	If lPagar
		AAdd(aStructSE2, {"TITRECNO", "N", 8, 0})
		__oSE2TMP := FwTemporaryTable():New()
		__oSE2NAT := FwTemporaryTable():New()
		__oSE2TMP:SetFields(aStructSE2)
		__oSE2NAT:SetFields(aStructSE2)
		__oSE2TMP:AddIndex("1", {"E2_FILIAL", "E2_PREFIXO", "E2_NUM", "E2_PARCELA", "E2_TIPO", "E2_FILORIG", "TITRECNO"})
		__oSE2NAT:AddIndex("1", {"E2_FILIAL", "E2_PREFIXO", "E2_NUM", "E2_PARCELA", "E2_TIPO", "E2_FILORIG", "TITRECNO"})
		__oSE2TMP:AddIndex("2", {"E2_NATUREZ"})
		__oSE2NAT:AddIndex("2", {"E2_NATUREZ"})
		__oSE2TMP:Create()
		__oSE2NAT:Create()
	EndIf

Return Nil

/*/{Protheus.doc} InsertNat
Pesquisa os títulos (pagar/receber) conforme range de natureza informado.

@type 	Function
@author Rafael Riego
@since	06/04/2022
@param	cRecPag, character, R se carteira a receber, P se cartteira a pagar
@param	cNatIni, character, natureza inicial do range
@param	cNatFim, character, natureza final do range
@return	Nil
/*/
Static Function InsertNat(cRecPag As Character, cNatIni As Character, nNatFim As Character)

	Local cWhere	As Character

	cAliasTit := ""

	Default cRecPag		:= "R"
	Default cNatIni		:= ""
	Default cNatFim		:= ""

	If cRecPag == "R"
		If __cInsNat1 == Nil
			__cInsNat1 := " INSERT "
			If "ORACLE" $ __cSGBD
				__cInsNat1 += " /*+ APPEND */ "
			EndIf
			__cInsNat1 += " INTO " + __oSE1NAT:GetRealName()  + " (" + __cCposSE1  + ", TITRECNO) "
			__cInsNat1 += "SELECT " + __cCposSE1 + ", TITRECNO "
			__cInsNat1 += "FROM " + __oSE1TMP:GetRealName() + " "
		EndIf
		cWhere := "WHERE E1_NATUREZ BETWEEN '" + cNatIni + "' AND '" + nNatFim + "'"

		IIf(TCSQLExec(__cInsNat1 + cWhere) < 0, UserException(TCSQLError()), Nil)
	Else
		If __cInsNat2 == Nil
			__cInsNat2 := " INSERT "
			If "ORACLE" $ __cSGBD
				__cInsNat2 += " /*+ APPEND */ "
			EndIf
			__cInsNat2 += " INTO " + __oSE2NAT:GetRealName()  + " (" + __cCposSE2  + ", TITRECNO) "
			__cInsNat2 += "SELECT " + __cCposSE2 + ", TITRECNO "
			__cInsNat2 += "FROM " + __oSE2TMP:GetRealName() + " "
		EndIf
		cWhere := "WHERE E2_NATUREZ BETWEEN '" + cNatIni + "' AND '" + nNatFim + "'"

		IIf(TCSQLExec(__cInsNat2 + cWhere) < 0, UserException(TCSQLError()), Nil)
	EndIf

Return Nil

/*/{Protheus.doc} ClrTmpNat
Realiza a limpeza das tabela de títulos a receber/pagar por natureza

@type 	Function
@author Rafael Riego
@since	06/04/2022
@param	lReceber, logical, se deve limpar a tabela referente aos títulos a receber por natureza
@param	lPagar, logical, se deve limpar a tabela referente aos títulos a receber por natureza
@return	Nil
/*/
Static Function ClrTmpNat(lReceber As Logical, lPagar As Logical)

	Default lReceber	:= .F.
	Default lPagar		:= .F.

	If lReceber
		IIf(TCSQLExec("TRUNCATE TABLE " + __oSE1NAT:GetRealName()) < 0, UserException(TCSQLError()), Nil)
		IIf(__lMetric, TCRefresh(__oSE1NAT:GetTableNameForTCFunctions()), TCRefresh(__oSE1NAT:cTableName))
	EndIf

	If lPagar
		IIf(TCSQLExec("TRUNCATE TABLE " + __oSE2NAT:GetRealName()) < 0, UserException(TCSQLError()), Nil)
		IIf(__lMetric, TCRefresh(__oSE2NAT:GetTableNameForTCFunctions()), TCRefresh(__oSE2NAT:cTableName))
	EndIf

Return Nil

/*/{Protheus.doc} DestroyTMP
Realiza a destruição das tabelas temporárias utilizadas para os títulos receber e pagar.

@type 	Function
@author Rafael Riego
@since	06/04/2022
@param	lReceber, logical, se deve destruir as tabelas referentes aos títulos a receber
@param	lPagar, logical, se deve destruir as tabelas referentes aos títulos a pagar
@return	Nil
/*/
Static Function DestroyTMP(lReceber As Logical, lPagar As Logical)

	If lReceber
		If __oSE1NAT != NIL
			__oSE1NAT:Delete()
			__oSE1NAT := Nil
		EndIf

		If __oSE1TMP != NIL
			__oSE1TMP:Delete()
			__oSE1TMP := Nil
		EndIf
	EndIf

	If lPagar
		If __oSE2NAT != NIL
			__oSE2NAT:Delete()
			__oSE2NAT := Nil
		EndIf

		If __oSE2TMP != NIL
			__oSE2TMP:Delete()
			__oSE2TMP := Nil
		EndIf
	EndIf

Return Nil
