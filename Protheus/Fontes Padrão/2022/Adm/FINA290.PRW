#INCLUDE "FINA290.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FwLibVersion.ch"

STATIC lF290OWN			:= .F.
STATIC lF290FPG 		:= .F.
STATIC lf290CHK 		:= .F.
STATIC lF290LIBT		:= .F.
STATIC lFA290HPAD		:= .F.
STATIC lF290BTIT	  	:= .F.
STATIC lF290FORNP		:= .F.
STATIC lF290BROW		:= .F.
STATIC lF290BFIL		:= .F.
STATIC lF290PRE			:= .F.
STATIC lF290Baixa		:= .F.
STATIC lPEGrava			:= .F.
STATIC lF290FIL 		:= .F.
STATIC lF290CON			:= .F.
STATIC lFA290			:= .F.
STATIC lValidCan		:= .F.
STATIC lF290CN2			:= .F.
STATIC lFA290C 			:= .F.
STATIC lF290CAN			:= .F.
STATIC lFA290OK			:= .F.
STATIC lF290Tit			:= .F.
STATIC lFa290TOk		:= .F.
STATIC lF290Val 		:= .F.
STATIC LFIN290NAT		:= .F.
STATIC lFILEMOT 		:= .F.
STATIC lPEMostraTela	:= .F.
STATIC lFI290Cols		:= .F.
Static dLastPcc  		:= dDatabase
Static lIsIssBx 		:= .F.
Static lPLSFN290 		:= .F.
Static __nIdxE2OK		:= 2
Static lPodeTVA   		:= .F.
Static lAbatiment 		:= .F.
Static _oFina2901		:= NIL
Static _oFina2902		:= NIL
Static __oCanQry  		:= NIL
Static __oStFix1  		:= NIL
Static __oStFix2  		:= NIL
Static __lExecSt		:= NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Fina290
Selecao de titulos para Fatura

@author Paulo Boschetti
@version P12
@since	27/07/93
/*/
//-------------------------------------------------------------------
Function Fina290(nPosArotina,aFatPag,lAutomato)
	Local lPanelFin		:= IsPanelFin()
	Local xRet	    	:= ''

	Private aRotina		:= MenuDef()
	Private cFatura		:= CRIAVAR("E2_FATURA")
	Private cForn		:= CriaVar("A2_COD")
	Private cLoja		:= CriaVar("A2_LOJA")
	Private cPrefix 	:= CRIAVAR("E2_PREFIXO",.T.)
	Private dVencto		:= Ctod(Space(8))
	Private dDataDe		:= dDataBase
	Private dDataAte	:= dDataBase
	Private nValor 		:= 0
	Private nValorFat	:= 0
	Private cNat		:= Space(10)
	Private nTotAbat	:= 0
	Private nValCruz	:= 0
	Private aVlCruz		:= {}
	Private aDupl		:= {}
	Private nValtot		:= 0
	Private aVenc		:= {}
	Private nMoeda 		:= 1
	Private nIndex 		:= 0
	Private cFil290 	:= ""
	Private cLote
	Private oFatura 	:= NIL
	Private lFocus 		:= .F.
	Private oTipo		:= NIL
	Private oNat
	Private cCadastro 	:= STR0005 //"Aglutinação de Titulos"
	Private nMoedaBco	:= 1 // Variavel necessaria para não ocorrer error.log na funcao fa090Correc()

	Default nPosArotina := 0
	Default aFatPag     := {}
	Default lAutomato	:= .F.

	F290Static()

	Fa290MotBx("FAT","FATURAS   ","ANNS")

	If FunName() <> "FINA750" .And. !lPanelFin .and. Empty(aFatPag)
		dbSelectArea("SE2")
		dbSetOrder(1)
		dbGoTop()
	EndIf

	SetKey(VK_F12,{|a,b| AcessaPerg("AFI290",.T.)})
	Pergunte("AFI290",.F.)


	//Ponto de entrada a ser executado antes da browse
	IF lF290BROW
		ExecBlock("F290BROW",.f.,.f.)
	Endif

	If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
		dbSelectArea("SE2")
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
		xRet   := Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,aFatPag,lAutomato)
	Else
		mBrowse( 6, 1,22,75,"SE2",,,,,,Fa040Legenda("SE2"),,,,,,,,IIF(lF290BFIL,ExecBlock("F290BFIL",.f.,.f.),NIL))
	Endif

	Set Key VK_F12 to

	//Recupera a Integridade dos dados				
	dbSelectArea("SE2")
	dbSetOrder(1)
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fA290Aglu
Marcacao dos titulos para emissao de fatura

@author Paulo Boschetti
@version P12
@since	27/07/93
/*/
//-------------------------------------------------------------------
Function fA290Aut(cAlias As Character, nRecno As Numeric, nOpcE As Numeric, aFatPag As Array, lAutomato As Logical) As Logical
	Local lPanelFin 	:= IsPanelFin()
	Local lPadrao		:= .F.
	Local cPadrao		:= "587"
	Local dDatCont 		:= dDatabase
	Local nOpca 		:= 2
	Local aBut290 		:= {{"PESQUISA",{||Fa290Pesq(oMark,cAlias)}, STR0070,STR0001}} //###"Pesquisar" ### "Pesquisar..(CTRL-P)"
	Local bSet16 		:= SetKey(16,{||Fa290Pesq(oMark,cAlias)})
	Local oValor		:= 0
	Local oQtdTit		:= 0
	Local oTitAbats		:= 0
	Local oValorFat		:= 0
	Local cMarca		:= GetMark()
	LOCAL aMoedas		:= {}
	LOCAL cVar			:= ""
	LOCAL nI			:= 0
	LOCAL aCampos 		:= {}
	LOCAL cAliasSE2 	:= "SE2"
	Local cSetFilter 	:= SE2->(DBFILTER()) // Salva o filtro atual, para restaurar no final da rotina
	Local nX			:= 0
	Local oDlg			:= nil
	Local oDlg1			:= nil
	Local oDlg2			:= nil
	LOCAL oCbx			:= nil
	Local oTimer		:= nil
	Local nTimeOut  	:= SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione os titulos a faturar
	Local nTimeMsg  	:= SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usuário
																// informando que a tela fechará automaticamente em XX minutos
	Local aChaveLbn 	:= {}
	Local lPccBaixa		:= (cPaisLoc == "BRA") .And. (SuperGetMv( "MV_BX10925" ,.T.,"2") == "1")
	Local aSize 		:= {}
	Local oPanel		:= nil
	Local lNumFat   	:= .T.
	Local lFatAut   	:= .F.
	Local nDecres   	:= 0
	Local nAcresc   	:= 0
	Local nIndSE2 		:= SE2->(IndexOrd())
	Local nRecnoSE2		:= SE2->(Recno())
	Local nTcSql		:= 0
	Local lMostraTela	:=.T.
	Local aCps 			:= {}
	Local cCond 		:= Space(3)
	Local lIRPFBaixa	:= .F.
	Local lAWB			:= Left(FunName(),7) == 'TMSA920' //Geracao de Titulos AWB
	Local cCampoAbat	:= "Abatmts"
	Local cCampoSel		:= ""
	Local cTituloSel	:= ""
	Local cPictSel		:= ""
	Local aPcc		 	:= Array(4)
	Local aSelFil		:= {}
	Local aTmpFil		:= {}
	Local aAuxFil		:= {}
	Local cTmpSE2Fil 	:= ""
	Local cLayout   	:= FWSM0Layout()
	Local lGestao		:= "E" $ cLayout .Or. "U" $ cLayout
	Local lSE2Compart	:= Iif( lGestao, FWModeAccess("SE2",1) == "C", FWModeAccess("SE2",3) == "C")
	Local cQuery		:= ""
	Local aStru			:= {}
	Local cQuery2		:= ''
	Local cCampos		:= ''
	Local aCamposExtras	:= {}
	Local lLoja			:= (MV_PAR01 == 1)
	Local lExistVA 		:= TableInDic("FKD") .and. TableInDic("FKC")
	Local lCtrlAlc		:= (SuperGetMV( "MV_FINCTAL", .T., "1" ) == "2")
	Local oSay	 		:= nil
	local cQuery3		:= ""
	local cSelect		:= ""
	
	Private nInsFat		:= 0
	Private aInsFat		:= {}
	Private aBaseIns	:= {}
	Private oGet		:= nil
	Private cCondicao	:= Space(3)
	Private nValCorr	:= 0
	Private nBasePCC	:= 0
	Private nPisFat		:= 0
	Private nCofFat		:= 0
	Private nCslFat		:= 0
	Private nIrfFat		:= 0
	Private aBaseFat	:= {}
	Private aPisFat		:= {}
	Private aCofFat		:= {}
	Private aCslFat		:= {}
	Private aIrfFat		:= {}
	Private lInverte	:= .F.
	Private aHeader		:= {}
	Private aCols		:= {}
	Private oValTot		:= 0
	Private nValTot		:= 0
	Private nUsado 		:= 0
	Private cTipo		:= CRIAVAR("E2_TIPOFAT")
	Private cFornP		:= CRIAVAR("E2_FORNECE",.F.)
	Private cLojaP		:= CRIAVAR("E2_LOJA",.F.)
	Private nJur290		:= 0
	Private nDesc290	:= 0
	Private nAcres290	:= 0
	Private nDecres290	:= 0
	Private nBaseIrpf	:= 0
	Private aDocsOri	:= {}
	Private aDocsDes	:= {}
	Private dEmiss		:= SE2->E2_EMIS1
	Private nTxFat 		:= 0

	Default lAutomato := .F.

	If Type("lEmpPub") <> "L"
		lEmpPub	:= IsEmpPub()
	EndIf
	If dDatabase >= dLastPCc
		nVlMinImp	:= 0
	EndIf

	//Verifica se data do movimento não é menor que data limite de 
	//movimentacao no financeiro    					
	If !DtMovFin(,,"1")
		Return
	Endif

	//Verifica se se o processo será contabilizado      
	lPadrao := VerPadrao(cPadrao) .and. mv_par03 == 1

	aPcc[1]	:= .F.

	SomaAbat("","","","P")

	SetKey(VK_F12,{|a,b| AcessaPerg("AFI290",.T.)})
	Pergunte("AFI290",.F.)

	//Inicializa array com as moedas existentes.						  
	aMoedas := FDescMoed()

	dbSelectArea( cAlias )

	cPictPref := AllTrim(PesqPict("SE2","E2_PREFIXO"))
	cForn	:= SPACE(TamSX3("E2_FORNECE")[1])
	cLoja	:= SPACE(TamSX3("E2_LOJA")[1])

	//-- Tratamento necessario devido os parametros enviados pela MBrowse
	If ValType(aFatPag) != "A" .Or. Len(aFatPag) < 13 .Or. ValType(aFatPag[13]) != "A"
		aFatPag := {}
	EndIf
	//Descricao do Array aFatPag
	//[01] - Prefixo
	//[02] - Tipo
	//[03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)
	//[04] - Natureza
	//[05] - Data de
	//[06] - Data Ate
	//[07] - Fornecedor
	//[08] - Loja
	//[09] - Fornecedor para geracao
	//[10] - Loja do fornecedor para geracao
	//[11] - Condicao de pagto
	//[12] - Moeda
	//[13] - ARRAY com os titulos da fatura
	//[13,1] Prefixo
	//[13,2] Numero
	//[13,3] Parcela
	//[13,4] Tipo
	//[13,5] Título localizado na geracao de fatura (lógico). Iniciar com falso.
	//[14] - Valor de decrescimo
	//[15] - Valor de acrescimo

	LoteCont( "FIN" )

	nOpca 		:= 2

	While nOpca == 2
		nOpca 		:= 3
		dbSelectArea(cAlias)
		//Recebe dados a serem digitados					
		cVar := aMoedas[1]
		If Len(aFatPag) > 0
			lFatAut := .T.
			
			If !Empty(aFatPag[3])
				lNumFat := .F.
				cFatura := aFatPag[3]
			EndIf
			
			If Len(aFatPag) >= 16 .And. Valtype(aFatPag[16]) == "N"
				nTxFat := aFatPag[16] 
			EndIf
		EndIf
		
		If lNumFat
			aTam := TamSx3("E2_NUM")
			cFatura	:= Soma1(GetMv("MV_NUMFATP"), aTam[1])
			cFatura	:= Pad(cFatura,aTam[1])
		EndIf
		
		cFatAnt	:= cFatura
		//Ponto de Entrada para inicializacao das vari veis da fatura 
		If lF290PRE
			ExecBlock("F290PRE",.F.,.F.)
		Endif

		If lFatAut
			cPrefix  := aFatPag[01]
			cTipo    := aFatPag[02]
			cNat     := aFatPag[04]
			dDataDe  := Iif(!Empty(aFatPag[05]),aFatPag[05],dDataDe)
			dDataAte := Iif(!Empty(aFatPag[06]),aFatPag[06],dDataAte)
			cForn    := aFatPag[07]
			cLoja    := aFatPag[08]
			cFornP   := aFatPag[09]
			cLojaP   := aFatPag[10]
			nOpca    := 1
			nDecres  := Iif(Len(aFatPag) > 13 .And. ValType(aFatPag[14]) == "N",aFatPag[14],0)
			nAcresc  := Iif(Len(aFatPag) > 14 .And. ValType(aFatPag[15]) == "N",aFatPag[15],0)

			If lLoja .AND. !Empty(cFornP) .AND. !Empty(cLojaP)
				lLoja := .F. //Será gerado fatura para outro fornecedor.
			Endif
			
			If lAutomato
				If FindFunction("GetParAuto")
					aRetAuto := GetParAuto("FINA290TestCase")
					nValorFat := aRetAuto[1][1]
				EndIf
			EndIf
			If ValType(aFatPag[13][1]) == "A" .And. Len(aFatPag[13][1]) > 7
				For nI := 1 to Len(aFatPag[13])
					If ( aScan(aAuxFil, {|e| e == aFatPag[13][nI][8]} ) ) == 0
						aAdd(aAuxFil, aFatPag[13][nI][8])
					EndIf
				Next nI
			EndIf
		Else
			aSize := MSADVSIZE()
			If lPanelFin  //Chamado pelo Painel Financeiro
				//Espacamento := 45
				dbSelectArea(cAlias)
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
				nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 218) /2
				nEspLin  := 0

			Else
				DEFINE MSDIALOG oDlg FROM	22,9 TO 240,540 TITLE STR0009 PIXEL //"Faturas a Pagar"
				nEspLarg := 5
				nEspLin  := 2
			Endif

			oDlg:lMaximized := .F.
			oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT


			@ 004+nEspLin, nEspLarg TO 036+nEspLin, 218+nEspLarg OF oPanel PIXEL
			@ 038+nEspLin, nEspLarg TO 070+nEspLin, 218+nEspLarg OF oPanel PIXEL
			@ 072+nEspLin, nEspLarg TO 104+nEspLin, 218+nEspLarg OF oPanel PIXEL

			nEspLarg := nEspLarg - 7

			@ 020+nEspLin, 014+nEspLarg MSGET cPrefix	Pict cPictPref  			 SIZE 10, 11 OF oPanel PIXEL
			@ 020+nEspLin, 040+nEspLarg MSGET oTipo VAR cTipo		F3 "05" Picture "@!" Valid If(nOpca<>0,(!Empty (cTipo) .and. FA290Tipo(@cTipo)),.T.) SIZE 10, 11 OF oPanel PIXEL HASBUTTON
			oTipo:cReadVar := "E2_TIPOFAT"

			@ 020+nEspLin, 075+nEspLarg MSGET oFATURA VAR cFatura	Valid If(nOpca<>0,!Empty(cFatura),.T.) SIZE 42, 11 OF oPanel PIXEL
			@ 020+nEspLin, 120+nEspLarg MSGET oNat VAR cNat		F3 "SED" Valid If(nOpca<>0,Fa290Nat(),.T.) SIZE 55, 11 OF oPanel PIXEL HASBUTTON
			@ 020+nEspLin, 175+nEspLarg MSCOMBOBOX oCbx VAR cVar ITEMS aMoedas 		SIZE 46, 14 OF oPanel PIXEL

			@ 054+nEspLin, 014+nEspLarg MSGET dDataDe	Valid If(nOpca<>0,F290VLDDT("DataDe", dDataDe),.T.)		SIZE 50, 11 OF oPanel PIXEL HASBUTTON
			@ 054+nEspLin, 068+nEspLarg MSGET dDataAte	Valid If(nOpca<>0, F290VLDDT("DataAte", dDataDe, dDataAte),.T.) SIZE 50, 11 OF oPanel PIXEL HASBUTTON
			@ 054+nEspLin, 120+nEspLarg MSGET nValorFat Picture "@E 9,999,999,999.99"    SIZE 65, 11 OF oPanel PIXEL HASBUTTON

			@ 085+nEspLin, 014+nEspLarg MSGET cForn		F3 "FOR" Valid If(nOpca<>0,Fa290For(cForn,cLoja,lLoja,.F.),.T.) SIZE 65, 11 OF oPanel PIXEL HASBUTTON
			@ 085+nEspLin, 079+nEspLarg MSGET cLoja		When lLoja Valid If(nOpca<>0,Fa290For(cForn,cLoja,lLoja,.F.),.T.) SIZE 21, 11 OF oPanel PIXEL

			@ 085+nEspLin, 120+nEspLarg MSGET cFornP		When mv_par01 == 2 .and. ( Iif( lF290FORNP , EXECBLOCK("F290FORNP",.F.,.F.) , .T. )) Valid If(nOpca<>0,Fa290For(cFornP,cLojaP,.T.,.F.),.T.) F3 "FOR" SIZE 65, 11 OF oPanel PIXEL HASBUTTON
			@ 085+nEspLin, 185+nEspLarg MSGET cLojaP		When mv_par01 == 2 .and. ( Iif( lF290FORNP , EXECBLOCK("F290FORNP",.F.,.F.) , .T. )) Valid If(nOpca<>0,Fa290For(cFornP,cLojaP,.T.,.F.),.T.) SIZE 21, 11 OF oPanel PIXEL

			@ 010+nEspLin, 014+nEspLarg SAY STR0010 SIZE 20, 7 OF oPanel PIXEL //"Prefixo"
			@ 010+nEspLin, 040+nEspLarg SAY STR0053 SIZE 12, 7 OF oPanel PIXEL //"Tp"
			@ 010+nEspLin, 075+nEspLarg SAY STR0055 SIZE 49, 7 OF oPanel PIXEL //"Nr.Fatura"
			@ 010+nEspLin, 120+nEspLarg SAY STR0012 SIZE 25, 7 OF oPanel PIXEL //"Natureza"
			@ 010+nEspLin, 175+nEspLarg SAY STR0013 SIZE 25, 7 OF oPanel PIXEL //"Moeda"

			@ 044+nEspLin, 014+nEspLarg SAY STR0014 SIZE 30, 7 OF oPanel PIXEL //"Emissão de"
			@ 044+nEspLin, 068+nEspLarg SAY STR0015 SIZE 10, 7 OF oPanel PIXEL //"At‚"
			@ 044+nEspLin, 120+nEspLarg SAY STR0016 SIZE 50, 7 OF oPanel PIXEL //"Valor da Fatura"

			@ 075+nEspLin, 014+nEspLarg SAY STR0017 SIZE 30, 7 OF oPanel PIXEL //"Fornecedor"
			@ 075+nEspLin, 079+nEspLarg SAY STR0018 SIZE 30, 7 OF oPanel PIXEL //"Loja"
			@ 075+nEspLin, 120+nEspLarg SAY STR0057 SIZE 50, 7 OF oPanel PIXEL //"Gerar p/Fornecedor"
			@ 075+nEspLin, 185+nEspLarg SAY STR0018 SIZE 30, 7 OF oPanel PIXEL //"Loja"

			aCps := {"cPrefix","cFatura","cNat","cForn","cLoja","cFornP","cLojaP"}

			If lPanelFin  //Chamado pelo Painel Financeiro
				oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])
				ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
				{||nOpca:=0,IF(If(FA290NUM(cFatAnt), FA290Ok() .And. Iif(lLoja, Fa290For(cForn,cLoja,.T.,.T.), Fa290For(cFornP,cLojaP,.T.,.T.)) ,.F.),nOpca:=1,nOpca:=2),oDlg:End()},;
				{||nOpca:=0,oDlg:End()})

				FinVisual(cAlias,FinWindow,(cAlias)->(Recno()),.T.)

			Else
				DEFINE SBUTTON FROM 07, 230 TYPE 1 ACTION (nOpca:=0,IF(If(FA290NUM(cFatAnt),FA290Ok() .And. F290VlCpos(aCps) .And. Iif(lLoja, Fa290For(cForn,cLoja,.T.,.T.), Fa290For(cFornP,cLojaP,.T.,.T.)) ,.F.),nOpca:=1,nOpca:=2),oDlg:End()) ENABLE OF oDlg
				DEFINE SBUTTON FROM 21, 230 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg

				ACTIVATE MSDIALOG oDlg CENTERED
			Endif
		Endif
	Enddo

	If(nOpca<>1,nOpca:=0,.T.)

	If nOpca == 0
		FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
		Return
	EndIf

	If lFatAut .And. !Empty(aFatPag[12])
		nMoeda := aFatPag[12]
	Else
		nMoeda := Val(Substr(cVar,1,2))
	EndIf

	//Selecao de filiais
	If ( lFatAut .Or. lAutomato ) .And. Len(aAuxFil) > 0
		aSelFil := aAuxFil
	Else
		If mv_par06 == 1 .and. !lSE2Compart
			If Len( aSelFil ) <= 0
				aSelFil := AdmGetFil(.F.,.T.,"SE2")
				If Len( aSelFil ) <= 0
					Return
				EndIf
			Endif
		Else
			aSelFil := { cFilAnt }
		EndIf
	EndIf
	// Monta Estrutura de Campos
	cCampos := TTGetStru(aStru,"SE2")

	cAliasSE2 := "TRBSE2"
	cQuery := Fa290ChecF(aSelFil,aTmpFil,cTmpSE2Fil,cCampos)

	// Adiciono o campo RECNO a Estrutura dos campos
	Aadd( aStru , { "RECNO" , "N" , 10 , 0 } )
	cCampos += ",RECNO"

	AADD(aCamposExtras,{ cCampoAbat 	, "N" , 14 	, 2 })
	AADD(aCamposExtras,{ "ABATSOMADO" 	, "N" , 14 	, 2 })
	AADD(aCamposExtras,{ "CALCULADO"	, "C" , 1 	, 0 })
	AADD(aCamposExtras,{ "VLSOMAABAT" 	, "N" , 14 	, 2 })
	AADD(aCamposExtras,{ "VLACESS"		, "N" , 16	, 2 })

	For nI := 1 To Len(aCamposExtras)
		AADD(aStru,aCamposExtras[nI])
	Next nI

	If _oFina2901 <> Nil
		//-- Limpa registros para nova execução
		cAliasSe2 	:= _oFina2901:GetAlias()		
		nTcSql 		:= TcSQLExec("DELETE FROM " + _oFina2901:GetRealName() )
		If nTcSql < 0
			//-- Se ocorrer algum problema refaz a temporaria
			_oFina2901:Delete()
			_oFina2901 := Nil
		Else // Necessária para atualização do Alias após deleção dos dados 
			(cAliasSe2)->(dbGoTo(1))
		EndIf
	EndIf
	If _oFina2901 == Nil
		// Criação da Tabela Temporßria >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		MsErase(cAliasSE2)

		_oFina2901 := FWTemporaryTable():New( cAliasSe2 )
		_oFina2901:SetFields(aStru)
		_oFina2901:AddIndex("1", {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"})
		_oFina2901:AddIndex(TRIM(STR(__nIdxE2OK)), {"E2_OK","E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO"}) //Ordem de Marcacao
		_oFina2901:Create()

	EndIf

	cQuery2 := " INSERT "
	If ALLTRIM(tcGetdb()) == "ORACLE"
		cQuery2 += " /*+ APPEND */ "
	Endif

	cQuery2 += " INTO "+_oFINA2901:GetRealName()+" ("+cCampos+") " + cQuery
	FWMsgRun(, {|| TcSQLExec(cQuery2)},STR0100,STR0101) //"Processando registros solicitados."
	(cAliasSE2)->(DbSetOrder(1))
	(cAliasSE2)->(DbGoTop())
	// ---------------------------------------------------------------------------------------

	If BOF() .and. EOF()
		Help(" ",1,"RECNO")
		Set Filter to
		dbSetOrder(1)
		RetIndex("SE2")
		// Restaura o filtro
		Set Filter To &cSetFilter.
		dbGoTop()

		//Gestao
		For nX := 1 TO Len(aTmpFil)
			CtbTmpErase(aTmpFil[nX])
		Next

		FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
		Return(.F.)
	Endif
	
	nValor		:= 0	// valor total dos titulos,mostrado no rodape do browse
	nValCruz 	:= 0
	nQtdTit		:= 0	// quantidade de titulos,mostrado no rodape do browse
	nTitAbats	:= 0	// valor dos abatimentos dos titulos marcados
	aVlCruz		:= {}   // Valor na Moeda Nacional correspondente a cada parcela
	lIrpfBaixa	:=  SA2->A2_CALCIRF == "2"
	nOpcA 		:= 0

	//Monta array com capos a serem mostrados na marcacao de titulos 
	//Utiliza os capos em uso do SE2 mais o E2_SALDO que apesar de   
	//nao estar em uso deve ser mostrado na tela.                    
	AADD(aCampos,{"E2_OK","","  ",""})

	For nX := 1 To Len(aStru)
		If (aStru[nX,1] $ "E2_OK|ABATSOMADO|CALCULADO|VLSOMAABAT|VLACESS"+cCampoAbat) .Or. ;
		   (aStru[nX,1] == "E2_FILIAL" .And. Len(aSelFil) > 1)
			Loop
		EndIf
		cCampoSel := aStru[nX,1]
		cPictSel := X3Picture(cCampoSel)
		cTituloSel := X3Titulo() // Posicionamento do SX3 feito pela funcao X3Picture
		AADD(aCampos,{cCampoSel,"",cTituloSel,cPictSel})
	Next nX

	AADD(aCampos,{cCampoAbat,"",STR0077,"@E 999,999,999.99"})
	AADD(aCampos,{"ABATSOMADO","",STR0096,"@E 999,999,999.99"})		//"Valor do abatimento considerado na fatura"

	If lExistVA
		AADD( aCampos, { "VLACESS"	, "", STR0095, PesqPict( "FKD", "FKD_VALOR" ) } )
	Else
		//Crio o campo VLACESS com essa picture caso não exista as tabelas FKD e FKC
		//para não gerar error de invalid field name
		AADD( aCampos, { "VLACESS"	, "", STR0095, "@E 9,999,999,999,999.99" } )           
	EndIf

	dbSelectArea(cAliasSe2)

	IF lF290BTIT
		aCampos:=ExecBlock("F290BTIT",.f.,.f.,aCampos)
	EndIF

	//-------------------------------------------
	// Inicia integracao com Modulo SIGAPCO
	//-------------------------------------------
	PcoInilan("000015")

	//-------------------------------------------
	// Valores Acessórios
	//-------------------------------------------
	If lExistVA
		FWMsgRun(, {|oSay| FA290VA(cAliasSE2,oSay) },STR0102,STR0103)//Processando valores acessórios dos títulos
	EndIf
	
	F290SumAbt(cAliasSE2)

	If MV_PAR05 == 1 .Or. lFatAut	//marcação automática dos títulos
		
		cASE2Abt := "TRBSE2ABT"

		If _oFina2902 <> Nil

			//-- Limpa registros para nova execução
			cASE2Abt 	:= _oFina2902:GetAlias()		
			nTcSql 		:= TcSQLExec("DELETE FROM " + _oFina2902:GetRealName() )
			If nTcSql < 0
				//-- Se ocorrer algum problema refaz a temporaria
				_oFina2902:Delete()
				_oFina2902 := Nil
			Else // Necessária para atualização do Alias após deleção dos dados 
				(cASE2Abt)->(dbGoTo(1))
			EndIf
		EndIf

		If _oFina2902 == Nil

			// Criação da Tabela Temporária >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			MsErase(cASE2Abt)

			aStru2 := {}
			AADD(aStru2,{ "E2_MOEDA", "N" , 2 		, 0 })
			AADD(aStru2,{ "VLRET"	, "N" , 16 		, 2 })
			AADD(aStru2,{ "RECNO" 	, "N" , 10		, 0 })

			_oFina2902 := FWTemporaryTable():New( cASE2Abt )
			_oFina2902:SetFields(aStru2)
			_oFina2902:AddIndex("1", {"RECNO"})
			_oFina2902:Create()

		EndIf

		cQuery3 := " INSERT "
		If ALLTRIM(tcGetdb()) == "ORACLE"
			cQuery3 += " /*+ APPEND */ "
		Endif

		cQuery3 += " INTO " + _oFINA2902:GetRealName() + " (E2_MOEDA,VLRET,RECNO) "
		cSelect =  " SELECT SE2.E2_MOEDA,SUM(SE2.E2_SALDO) AS VLRET, TRBSE2.RECNO "
		cSelect += " FROM " + RetSqlName("SE2") + " SE2 inner join " + _oFINA2901:GetRealName() + " TRBSE2 "
		cSelect += " ON SE2.E2_FILIAL = TRBSE2.E2_FILIAL AND "	
		cSelect += " SE2.E2_TITPAI = TRBSE2.E2_PREFIXO || TRBSE2.E2_NUM || TRBSE2.E2_PARCELA || TRBSE2.E2_TIPO || TRBSE2.E2_FORNECE || TRBSE2.E2_LOJA "	
		cSelect += " WHERE SE2.E2_TIPO IN " + FormatIn(MVABATIM,"|") + " AND "
		cSelect += " SE2.D_E_L_E_T_ = ' ' "
		cSelect += " GROUP BY TRBSE2.RECNO,SE2.E2_MOEDA "	//como abatimento soh poder ser feito na moeda do titulo, entao posso retornar o valor somado
		cQuery3 += ChangeQuery(cSelect)

		FWMsgRun(, {|| TcSQLExec(cQuery3)},STR0100,STR0101) //"Processando registros solicitados."
		(cASE2Abt)->(DbSetOrder(1))
		(cASE2Abt)->(DbGoTop())

		FWMsgRun(, {|oSay| Fa290Marca(cAliasSe2, cMarca, nValorFat, lPccBaixa, (cPaisLoc == "BRA"), ;
					aChaveLbn, aFatPag,cASE2Abt,oSay)},STR0104,STR0103) //Totalizando os valores dos títulos
	EndIf

	nValorF := nValorFat

	If lFatAut
		If Ascan(aFatPag[13],{ | e | e[5] == .F. }) > 0
			IW_MSGBOX(STR0075,,STR0067,'STOP')		//'Existem títulos que não foram localizados na geração da fatura'###"Atenção"
			FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
			dbSelectArea("SE2")
			RetIndex( "SE2" )
			// Restaura o filtro
			Set Filter To &cSetFilter.

			//Gestao
			For nX := 1 TO Len(aTmpFil)
				CtbTmpErase(aTmpFil[nX])
			Next
			dbSelectArea("SE2")
			Return(.F.)
		EndIf
		nOpca := 1
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MSADVSIZE()

		oSize := FWDefSize():New(.T.)

		oSize:AddObject("MASTER",100,100,.T.,.T.)
		oSize:lLateral := .F.
		oSize:lProp := .T.

		oSize:Process()

		DEFINE MSDIALOG oDlg1 TITLE STR0020 PIXEL FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd  //"Fatura a Pagar"
		oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg1) },oDlg1) // Ativa timer
		oTimer:Activate()


		nLinIni := oSize:GetDimension("MASTER","LININI")
		nColIni := oSize:GetDimension("MASTER","COLINI")
		nLinFin := oSize:GetDimension("MASTER","LINEND")
		nColFin := oSize:GetDimension("MASTER","COLEND")

		@ nLinIni + 001, 002  To nLinIni+033,nColFin PIXEL OF oDlg1

		@ nLinIni + 008 , 005		SAY STR0021 + cPrefix 				  FONT oDlg1:oFont PIXEL Of oPanel// "Prefixo: "
		@ nLinIni + 017 , 005		Say STR0022 + cFatura 				  FONT oDlg1:oFont PIXEL Of oPanel// "N£mero: "
		@ nLinIni + 008 , 080		SAY STR0023 + Substr(cNat,1,10)		  FONT oDlg1:oFont PIXEL Of oPanel// "Natureza: "
		@ nLinIni + 017 , 080		SAY STR0024 + AllTrim(Str(nMoeda,2,0)) FONT oDlg1:oFont PIXEL Of oPanel// "Moeda: "

		@ nLinIni + 008 , 150		Say STR0025 FONT oDlg1:oFont PIXEL Of oPanel	//"Valor Fatura"
		@ nLinIni + 008 , 200		Say STR0026 FONT oDlg1:oFont PIXEL Of oPanel	//"Valor Selecionado"
		@ nLinIni + 008 , 250		Say STR0027 FONT oDlg1:oFont PIXEL Of oPanel	//"Tít. Selec."
		@ nLinIni + 017 , 150		Say oValorFat VAR nValorF	  Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL Of oPanel
		@ nLinIni + 017 , 200		Say oValor	  VAR nValor	  Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL Of oPanel
		@ nLinIni + 017 , 250		Say oQtdTit   VAR nQtdTit	  Picture "999999"            FONT oDlg1:oFont PIXEL Of oPanel


		oMark 		:= MsSelect():New(cAliasSE2,"E2_OK","!E2_SALDO",aCampos,@lInverte,@cMarca,{nLinIni + 36, nColIni, nLinFin, nColFin})
		oMark:bMark := {||Fa290Exibe(cMarca,oValor,oQtdTit,lPccBaixa,(cPaisLoc == "BRA"),cAliasSE2)}
		oMark:bAval	:= {||Fa290bAval(cAliasSE2,cMarca,oValor,oQtdTit,oMark,lPccBaixa,(cPaisLoc == "BRA"),aChaveLbn)}
		oMark:oBrowse:lhasMark = .t.
		oMark:oBrowse:lCanAllmark := .t.
		oMark:oBrowse:bAllMark := { || ProcInverte(cAliasSE2,cMarca,oValor,oQtdTit,.T.,oMark,lPccBaixa,(cPaisLoc == "BRA"),aChaveLbn,,,,oTitAbats) }

		If lF290FPG
		aBut290 := ExecBlock( "F290FPG",.F.,.F., {aBut290})
		EndIf

		If lPanelFin  //Chamado pelo Painel Financeiro
		ACTIVATE MSDIALOG oDlg1 ON INIT FaMyBar(oDlg1,{|| nOpca := 1,;
			IIF(Fa290ValOK(cAliasSe2, cMarca),IF(Fa290Soma(),oDlg1:End(),;
				Iif(Fa290Val(oValorFat),nOpca:=0,nOpca:=0)),nOpca:=0)},;
				{|| nOpca := 2,oDlg1:End()},aBut290)
		Else
			ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| nOpca := 1,;
				IIF(Fa290ValOK(cAliasSe2, cMarca),IF(Fa290Soma(),oDlg1:End(),;
				Iif(Fa290Val(oValorFat),nOpca:=0,nOpca:=0)),nOpca:=0)},;
				{|| nOpca := 2,oDlg1:End()},,aBut290)
		Endif
		SetKey(16,bSet16)
	EndIf

	dbSelectArea("SE2")

	If nOpca == 1
		If lPLSFN290 .And. PLSFN290(cAliasSE2)
			Return(.f.)
		EndIf
		
		nOpcA := 0
		
		If !lF290CON
			If lCtrlAlc
				MsgInfo(STR0078 + AllTrim(Str(nMoeda)) + ".",STR0079)//"Para a fatura será adotado o aprovador padrão para a moeda: " ###"Controle de alçadas ativo"
			Endif

			cCond := Iif(lFatAut .And. !Empty(aFatPag[11]),aFatPag[11],Space(3))

			If lFatAut .And. !lAWB
				nOpca := 1
				cCondicao := cCond
				
				If lAutomato
					nValor := nValorF
				Endif
				
				aVenc := Condicao(nValor, cCondicao, 0)

				nDup	:= Len(aVenc)
				aCols := GravaDup(nDup,cPrefix,cFatura,nValor,dDatabase,aVenc)

				If Empty(aCols)
					Help("",,"CONDICAONOTEXIST",,STR0097,1,0) //"A condição de pagamento informada não existe."
					nOpcA := 0	
				EndIf

				If !Fa290TudOK()
					nOpcA := 0
				EndIf
			Else
				aSize := MsAdvSize(,.F.,400)
				DEFINE MSDIALOG oDlg2 TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
				oDLg2:lMaximized := .T.

				oPanel1 := TPanel():New(0,0,'',oDlg2, oDlg2:oFont, .T., .T.,, ,65,65,.T.,.T. )
				oPanel1:Align := CONTROL_ALIGN_TOP

				oPanel2 := TPanel():New(0,0,'',oDlg2, oDlg2:oFont, .T., .T.,, ,20,20,.T.,.T. )
				oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

				@ 003,010 TO 55,125 OF oPanel1 Pixel
				@ 003,127 TO 55,500 OF oPanel1 Pixel

				@ 015, 015 Say STR0094 Of oPanel1 Pixel //Taxa Moeda
				@ 015, 050 MSGET nTxFat When If(nMoeda > 1, .T., .F.) Picture PesqPict("SE2","E2_TXMOEDA") PIXEL Of oPanel1 Hasbutton

				@ 032,015 Say STR0052 Of oPanel1 Pixel   //"Condição: "
				@ 032,050 MSGET cCond F3 "SE4" Picture "!!!" Of oPanel1 Pixel Hasbutton Valid If(nOpca<>0,ExistCpo("SE4",cCond) .And. Fa290Cond(cCond),.T.)
				DEFINE SBUTTON FROM 032, 090	TYPE 1 ACTION (If(!Empty(cCond)	.And.	ExistCpo("SE4",cCond) .And. Fa290Cond(cCond),;
														nOpca:=F290SelFat(oDlg2,1,@cCond,@nValor,@nValTot,@aVenc,@cPrefix,@cFatura,@cTipo,dDatCont,oPanel2,oPanel1),nOpca:=0)) ENABLE OF oPanel1

				If lPanelFin  //Chamado pelo Painel Financeiro
					ACTIVATE MSDIALOG oDlg2 ON INIT FaMyBar(oDlg2,;
																{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,oDlg2:End(),nOpca := 0), nOpca := 0)},;
																{||oDlg2:End()})
				Else
					ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,oDlg2:End(),nOpca := 0), nOpca := 0)},{||oDlg2:End()})
				Endif

				cCondicao := If(nOpca=0,"   ",cCond)
				aVenc := Condicao(nValor,cCondicao,0)
			EndIf
		Else
			aVenc := Execblock("F290CON",.f.,.f.,{nValor,cCondicao,cMarca,nBasePcc,nPisFat,nCofFat,nCslFat})
			nDup := Len(aVenc)
			aCols := GravaDup(nDup,cPrefix,cFatura,nValor,dDatabase,aVenc)

			If !Empty(aCols)
				aVlCruz := {}
				aVlCruz := F280VlCruz(nDup,nValCruz)

				//Mostra tela com os diversos titulos
				For nI:=1 To Len(aCols)
					nValTot += aCols[nI][6]
				Next nI

				//Faz o calculo automatico de dimensoes de objetos
				If lPEMostraTela
					lMostraTela:=ExecBlock("FI290MT",.f.,.f.)
					If ValType(lMostraTela) # "L"
						lMostraTela:=.T.
					EndIf
				EndIf

				If lMostratela
					aSize := MSADVSIZE()
					nOpca := 0
					DEFINE MSDIALOG oDlg2 TITLE STR0028 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Dados Cont beis Financeiros"
					oDlg2:lMaximized := .T.
					oPanel := TPanel():New(0,0,'',oDlg2,, .T., .T.,, ,20,20,.T.,.T. )
					oPanel:Align := CONTROL_ALIGN_TOP

					@ 003 , 005	SAY STR0029	PIXEL OF oPanel //"Data Contabilização : "
					@ 003 , 060	Say dDatCont				PIXEL OF oPanel FONT oDlg2:oFont
					@ 003 , 105	Say STR0030	PIXEL OF oPanel //"Condição de Pagamento : "
					@ 003 , 170	Say cCondicao				PIXEL OF oPanel
					@ 003 , 215	Say STR0031	PIXEL OF oPanel //"Valor Total:"
					@ 003 , 260	Say oValTot VAR nValTot	PIXEL OF oPanel FONT oDlg2:oFont Picture "@E 9,999,999,999.99"

					oGet:= MSGetDados():New(90,1,172,312,3,"Fa290LinOk","Fa290TudOk","",.T.,,,,,,"",,"Fa290AtuVl(.F.)")
					oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					ACTIVATE MSDIALOG oDlg2 ON INIT (oGet:oBrowse:Refresh(.T.),EnchoiceBar(oDlg2,{||nOpca:=1,if(oGet:TudoOk(),oDlg2:End(),nOpca := 0)},{||oDlg2:End()}))
				Else
					nOpca := 1
					
					If !Fa290TudOK()
						nOpcA := 0
					EndIf
				EndIf
			Endif
		Endif

		// Criar a fatura
		If nOpcA == 1
			FWMsgRun(, {|oSay| FA290GRVFT(cAliasSe2,oSay,nOpcE,cMarca,lExistVA,lPccBaixa,lCtrlAlc,;
						lLoja,lPadrao,nDecres,nAcresc,lSE2Compart,nTxFat,cPadrao,nQtdTit) },STR0100,STR0103)
		Endif
	Else
		(cAliasSE2)->(dbSetOrder(__nIdxE2OK))
		(cAliasSE2)->(dbSeek(cMarca))
		While !(cAliasSE2)->(Eof()) .And. (cAliasSE2)->E2_OK == cMarca
			SE2->(DbGoTo((cAliasSE2)->RECNO))
			MsUnlock()
			(cAliasSE2)->(dbSkip())
		Enddo
	Endif

	If !Empty(aChaveLbn)
		FWMsgRun(, {|oSay| aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) },STR0105,STR0103)//Finalizando processamento
	Endif

	cFatura	 := CRIAVAR("E2_FATURA")
	cForn 	 := CriaVar("A2_COD")
	cNat	 := Space(10)
	cPrefix  := CRIAVAR("E2_PREFIXO",.T.)
	cLoja 	 := CriaVar("A2_LOJA")
	dDataDe	 := dDatabase
	dDataAte := dDatabase
	nValorFat:= 0
	aVlCruz	 := {}

	//Recupera a Integridade dos dados
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()

	dbSelectArea("SE2")

	//Gestao
	For nX := 1 TO Len(aTmpFil)
		CtbTmpErase(aTmpFil[nX])
	Next

	// Restaura indice original do SE2 que foi selecionado no Browse
	dbSelectArea("SE2")
	SE2->(dbSetOrder(nIndSE2))
	SE2->(dbGoto(nRecnoSE2))

	//Finaliza integracao com Modulo PCO
	PcoFinLan("000015")

Return (nOpca == 1)

//-------------------------------------------------------------------
/*/{Protheus.doc} fa290num
Verifica se ja' existe numero do titulo.  

@author Paulo Boschetti
@version P12
@since	27/07/93
/*/
//-------------------------------------------------------------------
Static Function fa290num(cFatAnt)
	Local aAreaSE2:= SE2->(GetArea())
	Local lRet := .T.
	Local cFornLoja := IIF(mv_par01 == 1,cForn+cLoja,cFornp+cLojaP)

	If !MayIUseCode( "SE2"+xFilial("SE2")+cPrefix+cFatura+cTipo+cFornLoja)//verifica se esta na memoria, sendo usado busca o proximo numero disponivel
		Help(" ",1,"A290EXIST")
		oFatura:SetFocus()
		lFocus := .T.
		lRet := .F.
	Else

		dbSelectArea("SE2")
		dbSetOrder(6)
		
		If dbSeek(xFilial("SE2")+cFornLoja+cPrefix+cFatura)
			While !Eof() .and.SE2->E2_FILIAL == xFilial("SE2") .and. ;
					cFornLoja+cPrefix+cFatura == SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)

				If 	(SE2->E2_TIPO == cTipo .and. SE2->(E2_FORNECE+E2_LOJA) == cFornLoja)
					Help(" ",1,"A290EXIST")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Retorno .T. para que possa focar o campo do numero da³
					//³ fatura para altera‡Æo e posterior valida‡Æo. A valida³
					//³ ‡Æo neste caso ‚ feita somente no Fornecedor e ao con³
					//³ firmar a opera‡Æo da fatura.                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oFatura:SetFocus()
					lFocus := .T.
					lRet := .F.
					Exit
				Else
					dbSkip()
				Endif
			Enddo
		Else
			If cFatura <> cFatAnt
				FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
			Endif
			If	!MayIUseCode( "SE2"+xFilial("SE2")+cPrefix+cFatura+cTipo+cFornLoja )
				oFatura:SetFocus()
				lFocus := .T.
				lRet := .F.
			Endif
		Endif
	Endif
	RestArea(aAreaSe2)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290For
Valida Fornecedor e Loja informado

@param cFornecedor - Código do Fornecedor
@param cloja - Código da Loja
@param lVldForBlq - Valida fornecedor bloqueado
@param lTudoOk - Validação chamada do botão OK

@author Paulo Boschetti
@version P12
@since	27/07/1993
/*/
//-------------------------------------------------------------------
Static Function Fa290For( cFornecedor, cLoja, lVldForBlq ,lTudoOK)
	Local aArea			:= GetArea()
	Local lRet			:= .T.

	Default cLoja		:= ""
	Default lTudoOK		:= .F.
	Default lVldForBlq	:= .F.

	//------------------------------------------------------------------------------------------
	// Validacao de confirmacao de tela e obrigatoriedade do preenchimento do fornecedor e loja
	//------------------------------------------------------------------------------------------
	If lTudoOK .And. (Empty(cFornecedor) .Or. Empty(cLoja))
		Help("  ",1,"FA290FOR",,STR0084,1,0) //"Informe o código do fornecedor e loja."
		lRet := .F.

	//---------------------------------------------------------------------------
	// Validacao durante preenchimento do campo para evitar dados nao existentes
	//---------------------------------------------------------------------------
	ElseIf !Empty(cFornecedor)
		cLoja := If(Empty(cLoja), "", cLoja)

		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(xFilial("SA2")+cFornecedor+cLoja))
			//------------------------------------------------------------------------
			// Avalia se o fornecedor esta bloqueado se informado o fornecedor e loja
			//------------------------------------------------------------------------
			If !Empty(cLoja) .And. lVldForBlq .And. SA2->A2_MSBLQL == "1"
				Help(" ",1,"FA290FOR",,STR0085,1,0) //"O código de fornecedor e loja informados para geração estão bloqueados."
				lRet := .F.
			EndIf

		Else
			Help(" ",1,"FA290FOR",,STR0086,1,0) //"O código de fornecedor e loja informados não estão cadastrados no sistema."
			lRet := .F.
		Endif
	Endif

	RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDup
Formata Array com os desdobramentos dos titulos 	 

@author Paulo Boschetti
@version P12
@since	12/11/93
/*/
//-------------------------------------------------------------------
Function GravaDup(nDup,cPrefixo,cNumero,nValor,dVencto,aVenc)
	Local nTamParcela	:= TamSx3("E2_PARCELA")[1]
	Local cParcSE2		:= SuperGetMv("MV_1DUP")
	Local cParcela		:= Space(nTamParcela)
	Local cTmpParcela	:= Space(nTamParcela)
	Local nValorTit		:= NoRound((nValor/nDup))
	Local nValDup		:= nValor
	Local nMaxParc		:= 1
	Local nTamBanco		:= TamSx3("A6_COD")[1]
	Local ni			:= 0

	AADD(aHeader,{ STR0032,"E2_PREFIXO"	,"@!"                 ,TamSx3("E2_PREFIXO")[1] ,0,"","û","C","SE2" } )//"Prf"
	AADD(aHeader,{ STR0033,"E2_NUM"		,"@!"                 ,TamSx3("E2_NUM")[1],0,"","û","C","SE2" } )//"Número"
	AADD(aHeader,{ STR0034,"E2_PARCELA"	,PesqPict("SE2","E2_PARCELA"),TamSx3("E2_PARCELA")[1],0,"","û","C","SE2" } )//"Ord"
	AADD(aHeader,{ STR0054,"E2_TIPO"	,"@!"                 ,TamSx3("E2_TIPO")[1],0,"","û","C","SE2" } )//"Tipo"
	AADD(aHeader,{ STR0035,"E2_DTFATUR"	,"99/99/99"           ,TamSx3("E2_DTFATUR")[1],0,"","û","D","SE2" } )//"Vencimento"
	AADD(aHeader,{ STR0036,"E2_VALOR"	,"@E 9,999,999,999.99",TamSx3("E2_VALOR")[1],TamSx3("E2_VALOR")[2],"Fa290AtuVl()","û","N","SE2"})//"Valor Duplicata"
	AADD(aHeader,{ STR0037,"A6_COD"		,"@!"                 ,TamSx3("A6_COD")[1],0,"","û","C","SA6" })//"Banco"

	If lFI290Cols
		PRIVATE aCOLS[nDup][7]
		aHeader := ExecBlock("FI290COLS",.f.,.f.,{1,aHeader,}) // 1- aHeader; 2- aCols
	Else
		PRIVATE aCOLS[nDup][8]
	Endif

	// Verifica o tamnho da parcela
	If nDup > 1
		//Verifica a validade do parametro
		If Len(GetMV("mv_1dup")) >= 1
			cTmpParcela := Substr(GetMV("mv_1dup"),Len(GetMV("mv_1dup"))+1-nTamParcela,nTamParcela)
		Else
			IW_MSGBOX(STR0064 + Str(nMaxParc,2) + CHR(13)+ ;//"Número máximo de parcelas permitido "
						STR0065 + Str(nDup,4) + CHR(13)+; //"Número de parcelas da condição de pagto. "
						STR0066, STR0067,"STOP") //"Verifique parâmetro MV_1DUP."###"Atenção"
			Return {}
		EndIf
		// Se parcela tiver apenas um digito, ou o parametro tiver apenas um digito, verifica a quantidade maxima de parcelas
		If nTamParcela == 1 .Or. Len(AllTrim(GetMV("mv_1dup"))) == 1
			// Verifica a quantidade maxima de parcelas
			cParcela := cTmpParcela
			For ni := 1 To 63
				cParcela:=Soma1( cParcela,, .T. )
				If AllTrim(cParcela) == "*"
					Exit
				Endif
			nMaxParc++
			Next
			If nDup > nMaxParc
				IW_MSGBOX(STR0064 + Str(nMaxParc,2) + CHR(13)+ ;  //"Número máximo de parcelas permitido "
							STR0065 + Str(nDup,4) + CHR(13)+; //"Número de parcelas da condição de pagto. "
							STR0066, STR0067,"STOP") //"Verifique parâmetro MV_1DUP."###"Atenção"
				Return {}
			Endif
		Endif
	EndIf

	For ni := 1 To nDup
		cParcSE2 := Right("000"+cParcSE2,nTamParcela)
		nValorTit	:= aVenc[ni][2]
		cParcela	:= cTmpParcela
		aCols[ni,1]	:= cPrefixo
		aCols[ni,2]	:= cNumero
		aCols[ni,3]	:= cParcSE2
		aCols[ni,4]	:= cTipo
		aCols[ni,5]	:= aVenc[ni,1]
		aCols[ni,6]	:= IIf(ni<nDup,nValorTit,nValDup)
		aCols[ni,7] := Space(nTamBanco)

		// PE para manipulação do aCols do FINA290
		If lFI290Cols
			aCols := ExecBlock("FI290COLS",.f.,.f.,{2,aCols,ni})
		Else
			aCols[ni,8]	:= .F.
		End

		cParcSE2 := Soma1(cParcSE2,nTamParcela,.F.)

		nValDup -= nValortit
	NEXT ni

Return(aCols)

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290ChecF
Selecao para a criacao do indice condicional 	 

@author Valter G. Nogueira Jr.
@version P12
@since	14/03/94
/*/
//-------------------------------------------------------------------
Function Fa290ChecF(aSelFil,aTmpFil,cTmpSE2Fil,cCampos,lUsaQry)
	Local cFiltro 		:= ""
	Local nValmin 		:= 0
	LOcal lVerLibTit	:= .T.
	Local cFil290 		:= ""
	Local lLoja			:= (MV_PAR01 == 1)

	DEFAULT aSelFil		:= {}
	DEFAULT aTmpFil		:= {}
	DEFAULT cTmpSE2Fil	:= ""
	DEFAULT cCampos		:= " * "
	DEFAULT lUsaQry		:= .T.

	IF lF290LIBT
		lVerLibTit :=ExecBlock("F290LIBT",.f.,.f.)
	Endif

	If lUsaQry
		cFiltro := "SELECT "
		cFiltro += cCampos
		cFiltro += If(!Empty(cCampos),",","") + " SE2.R_E_C_N_O_ RECNO "
		cFiltro	+= "FROM "+RetSqlName("SE2")+ " SE2 "
		cFiltro	+= "WHERE "

		//Gestao
		If Len(aSelFil) > 0
			cFiltro += "E2_FILIAL " + GetRngFil( aSelFil, "SE2", .T., @cTmpSE2Fil )
			aAdd(aTmpFil, cTmpSE2Fil)
		Else
			cFiltro 	+= "E2_FILIAL='"	+ xFilial("SE2") + "'"
		Endif

		cFiltro 	+= " AND E2_FORNECE ='"	+ cForn + "'"
		IF lLoja
		cFiltro +=" AND E2_LOJA='"+cLoja+"'"
		EndIf

		If lf290OWN
			cFiltro += ExecBlock("F290OWN",.F.,.F.)
		Else
			cFiltro	+= " AND E2_EMISSAO >='"+DTOS(dDataDe) + "'"
			cFiltro += " AND E2_EMISSAO <='"+DTOS(dDataAte)+ "'"
		Endif

		cFiltro	+= " AND E2_MOEDA = "  + Str(nMoeda,2,0)
		cFiltro	+= " AND E2_FATURA ='" + Space(Len(SE2->E2_FATURA)) + "'"
		cFiltro += " AND E2_NUMBOR ='" + Space( Len( E2_NUMBOR ) )  + "'"
		cFiltro	+= " AND E2_TIPO NOT IN "+FormatIN(MVPAGANT+MVPROVIS,,3)

		/*
		Os abatimentos não devem aparecer na seleção de títulos,
		eles seram baixados de forma automática caso o título seja selecionado
		*/
		cFiltro	+= " AND E2_TIPO NOT IN "+FormatIn(MVABATIM,"|")

		cFiltro	+= " AND E2_SALDO > 0"
		// AAF - Titulos originados no SIGAEFF não devem ser alterados
		cFiltro += " AND E2_ORIGEM NOT IN ('SIGAEFF ', 'FINA667 ', 'FINA677 ', 'FINI055 ') "

		//Titulos com DARF gerado não devem ser incluidos em Fatura
		cFiltro += " AND E2_IDDARF = '" + Space(Len(E2_IDDARF)) + "' "

		//Verifica Titulo bloqueado MSBLQL
		If SE2->(ColumnPos("E2_MSBLQL")) > 0
			cFiltro += " AND E2_MSBLQL <> '1' "
		EndIF

		If lVerLibTit
			If GetMv("MV_CTLIPAG")
				cFiltro += " AND (E2_DATALIB <> ' '"
				cFiltro += " OR (E2_SALDO+E2_SDACRES-E2_SDDECRE<="+ALLTRIM(STR(GetMv('MV_VLMINPG'),17,2))+"))"
			Endif
		Endif

		cFiltro += " AND E2_NUMSOL = '"+ Space( Len( E2_NUMSOL ) ) + "' "

		//-----------------------------------------------------
		// Complemento de filtro - SIAFI
		//-----------------------------------------------------
		cFiltro += FinTemDH(.T. /*lFiltro*/,/*cAlias*/,.F. /*lHelp*/, .T./*lTop*/)

		cFiltro	+= " AND D_E_L_E_T_ = ' ' "

		If lF290FIL
			IF lF290FIL
				cFil290 := ExecBlock("F290FIL",.f.,.f.,{.T.})
			Endif
			If !Empty(cFil290)
				cFiltro += ' AND ' + cFil290 +' '
			EndIf
		Endif

		If lf290CHK
			cFiltro := ExecBlock("F290CHK",.F.,.F.,cFiltro)
		Endif

		cFiltro += " ORDER BY E2_FILIAL,E2_FORNECE,E2_LOJA,E2_PREFIXO,E2_NUM,E2_PARCELA "

	Else

		cFiltro += 'E2_FILIAL=="'+xFilial("SE2") + '"'
		cFiltro += '.AND.E2_SALDO>0'
		cFiltro += '.AND.E2_FORNECE=="' + cForn + '"'

		If lf290OWN
			cFiltro += ExecBlock("F290OWN",.F.,.F.)
		Else
			cFiltro += '.AND.DTOS(E2_EMISSAO)>="' + DTOS( dDataDe ) + '"'
			cFiltro += '.AND.DTOS(E2_EMISSAO)<="' + DTOS( dDataAte ) + '"'
		Endif

		If lVerLibTit
			If GetMv("MV_CTLIPAG")
				nValmin:= GetMV("MV_VLMINPG")
				cFiltro += ".AND. (!(DTOS(SE2->E2_DATALIB) = '        ').or. (DTOS(SE2->E2_DATALIB) = '        '.and.(E2_SALDO+E2_SDACRES-E2_SDDECRE)< " + str(nValmin)+ "))"
			EndIf
		EndIf

		//AAF - Titulos originados no SIGAEFF não devem ser alterados   
		cFiltro += ".AND. !('SIGAEFF' $ E2_ORIGEM) "
		cFiltro += ".AND. !('FINA667' $ E2_ORIGEM) "
		cFiltro += ".AND. !('FINA677' $ E2_ORIGEM) "
		cFiltro += ".AND. !('FINI055' $ E2_ORIGEM) "


		cFiltro += '.AND.E2_MOEDA=' + AllTrim(Str( nMoeda,2 ))
		cFiltro += '.AND.E2_FATURA=="' + Space( Len( E2_FATURA ) ) + '"'

		cFiltro += "  .AND. E2_NUMSOL=='"+ Space( Len( E2_NUMSOL ) ) + "'  "

		cFiltro += '.AND.E2_NUMBOR=="' + Space( Len( E2_NUMBOR ) ) + '"'
		cFiltro += '.AND.!(E2_TIPO $"'+MVPAGANT+"/"+MVPROVIS+'")'
		cFiltro += '.AND.!(E2_TIPO $"'+MVABATIM+'")'

		If lLoja
			cFiltro += '.And.E2_LOJA=="'+cLoja+'"'
		EndIF

		IF lF290FIL
			cFil290 := ExecBlock("F290FIL",.f.,.f.,{.F.})
		Endif

		If !Empty(cFil290)
			cFiltro := '(' + cFiltro + ') .And. (' + cFil290 + ')'
		Endif

		If lf290CHK
			cFiltro := ExecBlock("F290CHK",.F.,.F.,cFiltro)
		Endif
	Endif

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290CAN
Marcacao dos titulos para cancelamento de fatura		 

@author Cesar C S Prado	
@version P12
@since	13/05/94
/*/
//-------------------------------------------------------------------
Function FA290CAN(cAlias As Character, nRecno As Numeric, nOpcE As Numeric, aFatPag As Array, lAutomato as Logical) as Logical
	Local lPanelFin 	:= IsPanelFin()
	Local oDlg			:= NIL
	Local nOpca			:= 0
	Local nValor		:= 0
	Local l290CalCn		:= .F.
	Local lRet   		:=.T.
	Local lFatAut		:= .F.
	Local cLayout   	:= FWSM0Layout()
	Local lGestao		:= "E" $ cLayout .Or. "U" $ cLayout
	Local lSE2Compart	:= Iif( lGestao, FWModeAccess("SE2",1) == "C", FWModeAccess("SE2",3) == "C")
	Local cAliasQry 	:= cAlias
	Local cOrigem		:= Alltrim(SE2->E2_ORIGEM)
	Local lBxParcFat	:= .F.
	
	Private oTitulos	:= NIL
	Private oValorCan	:= NIL
	Private cIndex		:= ""
	Private cFatCan		:= CriaVar("E2_NUM"    , .F.)
	Private cPrefCan	:= CriaVar("E2_PREFIXO", .F.)
	Private cTipoCan	:= CriaVar("E2_TIPOFAT")
	Private cFornCan	:= CriaVar("E2_FORNECE", .F.)
	Private cLojaCan	:= CriaVar("E2_LOJA"   , .F.)
	Private dDataCan	:= CriaVar("E2_EMIS1"  , .F.)
	Private cLote

	DEFAULT aFatPag		:= {}

	//Verifica se data do movimento não é menor que data limite de movimentacao no financeiro    						
	If !DtMovFin(,,"1")
		Return .F.
	Endif

	LoteCont( "FIN" )

	//Verifica se o cancelamento da fatura foi feito via rotina semi-automatica
	//Necessário que o SE2 esteja posicionado em um dos titulos gerados
	If !Empty(aFatPag)
		lFatAut := .T.
	Endif

	SetKey(VK_F12,{|a,b| AcessaPerg("AFI290",.T.)})
	Pergunte("AFI290",.F.)

	dbSelectArea("SE2")
	cFornCan 	:= SE2->E2_FORNECE
	cLojaCan 	:= SE2->E2_LOJA
	cFatCan		:= SE2->E2_NUM
	cPrefCan 	:= SE2->E2_PREFIXO
	cTipoCan	:= SE2->E2_TIPO
	dDataCan	:= SE2->E2_EMIS1

	nValor		:= 0
	nTitulos 	:= 0
	nFaturas 	:= 0

	FA290CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l290CalCn,.F.,lSE2Compart,@cAliasQry,cOrigem,@lBxParcFat)
		
	If cOrigem $ "FINA565"
		Help(" ",1,"INDVAZIO")
		lRet := .F.
	ElseIf lFatAut
		nOpca := 1
	Else
		aSize := MSADVSIZE()
		If lPanelFin //Chamado pelo Painel Financeiro
			dbSelectArea(cAlias)
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
			nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 116) /2
			nEspLin  := 0

		Else
			nEspLarg := 0
			nEspLin  := 0
			DEFINE MSDIALOG oDlg FROM	15,6 TO 243,345 TITLE STR0038 PIXEL//"Cancelamento de Fatura a Pagar"
		Endif

		oDlg:lMaximized := .F.
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT


		@ 39+nEspLin, 11+nEspLarg TO 068+nEspLin, 127+nEspLarg OF oPanel	PIXEL
		@ 72+nEspLin, 11+nEspLarg TO 104+nEspLin, 127+nEspLarg OF oPanel	PIXEL
		@ 07+nEspLin, 11+nEspLarg TO 036+nEspLin, 127+nEspLarg OF oPanel	PIXEL

		@ 22+nEspLin, 14+nEspLarg MSGET cFornCan Valid Fa290For(cFornCan)	SIZE 70, 08 OF oPanel PIXEL
		@ 22+nEspLin, 87+nEspLarg MSGET cLojaCan Valid Fa290For(cFornCan,cLojaCan)	SIZE 20, 08 OF oPanel PIXEL
		@ 54+nEspLin, 14+nEspLarg MSGET cPrefCan 								SIZE 21, 08 OF oPanel PIXEL
		@ 54+nEspLin, 40+nEspLarg MSGET cTipoCan		F3 "05";
			Picture "@!" 		 ;
			SIZE 12, 08 OF oPanel PIXEL hasbutton ;
			Valid If(nOpca<>0,!Empty (cTipoCan) .and. FA290Tipo(cTipoCan),.T.)
		@ 54+nEspLin, 75+nEspLarg MSGET cFatCan Valid If(nOpca<>0,!Empty(cFatCan) .and. ;
			FA290CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l290CalCn,.T.,lSE2Compart,@cAliasQry,cOrigem,@lBxParcFat),.T.);
			SIZE 49, 08 OF oPanel PIXEL
		@ 88+nEspLin, 14+nEspLarg MSGET nTitulos		When .F. SIZE 28, 08 OF oPanel PIXEL
		@ 88+nEspLin, 53+nEspLarg MSGET nValor		Picture "@E 999,999,999.99" HASBUTTON  When .F. SIZE 71, 08 OF oPanel PIXEL
		@ 12+nEspLin, 14+nEspLarg SAY STR0039 SIZE 70, 7 OF oPanel PIXEL //"Fornecedor"
		@ 12+nEspLin, 87+nEspLarg SAY STR0040 SIZE 20, 7 OF oPanel PIXEL //"Loja"
		@ 44+nEspLin, 14+nEspLarg SAY STR0041 SIZE 21, 7 OF oPanel PIXEL //"Prefixo"
		@ 44+nEspLin, 43+nEspLarg SAY STR0054 SIZE 12, 7 OF oPanel PIXEL //"Tipo"
		@ 44+nEspLin, 74+nEspLarg SAY STR0042 SIZE 49, 7 OF oPanel PIXEL //"Número T¡tulo"
		@ 78+nEspLin, 14+nEspLarg SAY STR0043 SIZE 35, 7 OF oPanel PIXEL //"Total Notas"
		@ 78+nEspLin, 53+nEspLarg SAY STR0044 SIZE 53, 7 OF oPanel PIXEL //"Valor da Fatura"


		If lPanelFin  //Chamado pelo Painel Financeiro
			oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
			{||nOpca:=1,IF(IF(l290CalCn,.T.,FA290CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l290CalCn,.T.,lSE2Compart,@cAliasQry,cOrigem,@lBxParcFat)),oDlg:End(),nOpca:=0)},;
			{||oDlg:End()})

			FinVisual(cAlias,FinWindow,(cAlias)->(Recno()),.T.)

		Else
			DEFINE SBUTTON FROM 10, 133 TYPE 1 ACTION (nOpca:=1,;
				IF(IF(l290CalCn,.T.,;
				FA290CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l290CalCn,.T.,lSE2Compart,@cAliasQry,cOrigem,@lBxParcFat)),;
				oDlg:End(),nOpca:=0)) ENABLE OF oDlg
			DEFINE SBUTTON FROM 23, 133 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

			ACTIVATE MSDIALOG oDlg CENTERED
		Endif
	Endif

	If nOpcA == 1
		//Efetua o cancelamento das baixas
		FWMsgRun(, {|oSay| F290PRCCAN(@nTitulos,@nValor,cAlias,@nFaturas,@l290CalCn,lSE2Compart,@cAliasQry,cOrigem,@lBxParcFat,nOpcE,oSay) },STR0100,STR0103)
	Endif

	dbSelectArea(cAlias)
	Set Filter to
	RetIndex(cAlias)
	If	!Empty(cIndex)
		fErase(cIndex+OrdBagExt())
		cIndex := ""
	Endif
	lAbatiment := .F.
	dbSetOrder(1)
	dbSeek(xFilial(cAlias),.T.)
	
	If __oCanQry <> Nil
		__oCanQry:Destroy()
		__oCanQry := Nil
	Endif

Return(nOpca == 1)

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290CAlCn
Cria o indice temporario para o cancelamento da fatura			 

@author Cesar C S Prado	
@version P12
@since	27/04/94
/*/
//-------------------------------------------------------------------
Function FA290CalCn(nTitulos As Numeric, nValor As Numeric, cAlias as Character,nFaturas As Numeric,; 
					l290CalCn As Logical, lHelpCan As Logical, lSE2Compart As Logical, cAliasQry As Character,;
					cOrigem As Character, lBxParcFat As Logical)
	
	Local lBanco 	As Logical
	Local lRet	 	As Logical
	Local nValFat 	As Numeric

	lBanco	:= .F.
	lRet	:= .T.
	nValFat := 0

	DEFAULT lHelpCan  	:= .T.
	DEFAULT l290CalCn 	:= .F.
	DEFAULT lSE2Compart := .F.
	DEFAULT cAliasQry 	:= "SE2CAN"
	DEFAULT cOrigem		:= "FINA290"
	DEFAULT lBxParcFat	:= .F.

	If Empty(cFatCan)
		Help(" ",1,"INDVAZIO")
		lRet := .F.
	Else
		If Select(cAliasQry) > 0
			dbSelectArea(cAliasQry)
			dbCloseArea()
		Endif
		//abre alias com lista de Selecao para a criacao do indice condicional 	
		FA290FCAN(@cAliasQry)

		If (cAliasQry)->(BOF()) .and. (cAliasQry)->(EOF())
			FixNoFI8(@cAliasQry)
		EndIf

		If (cAliasQry)->(BOF()) .and. (cAliasQry)->(EOF())
			If lHelpCan
				Help(" ",1,"INDVAZIO")
			Endif
			dbSelectArea(cAliasQry)
			dbCloseArea()
			dbSelectArea("SE2")
			dbSetOrder(1)
			lRet := .F.
		else
			//Caso tenha ocorrido a baixa de alguma parcela da fatura, nao sera possivel a operacao de cancelamento.									
			nValor	:= 0
			lCancelar:= .T.
			lBanco := .F.
			While !(cAliasQry)->(Eof()) 

				SE2->(dbGoto((cAliasQry)->RECNO))

				If (SE2->E2_NUM == cFatCan .And. Day(SE2->E2_BAIXA) > 0 .And.;
					cPrefCan ==  SE2->E2_PREFIXO .and. SE2->E2_FATURA = "NOTFAT" .and. SE2->E2_TIPO == cTipoCan )
					lCancelar:=.F.
				ElseIf (SE2->E2_NUM == cFatCan .And. Day(SE2->E2_BAIXA) > 0 .And.;
					cPrefCan ==  SE2->E2_PREFIXO .and. SE2->E2_FATURA = "NOTFAT" .and. SE2->E2_TIPO == cTipoCan  .And.;
					SE2->E2_FATFOR == cFornCan .And. SE2->E2_FATLOJ == cLojaCan )
					lCancelar:=.F.
				ElseIf !Empty(SE2->E2_NUMBOR)
					lBanco := .T.
				Else
					If SE2->E2_TIPO $ MV_CPNEG +"/"+ MVABATIM
						lAbatiment := .T.
					Else
						nValor += IIF(SE2->E2_SALDO == 0 , SE2->E2_VALLIQ, 0)

						//Faturas compostas por tít que sofreram baixas parcias e as bxs foram cancel antes do cancel da fatura
						If AllTrim(SE2->E2_FATURA) == "NOTFAT" .And. SE2->E2_SALDO > 0 .And. SE2->E2_VALLIQ == 0
							nValFat += SE2->E2_SALDO
							lBxParcFat := .T.
						EndIf
					Endif
					If !(SE2->E2_TIPO $ MVABATIM)
						nTitulos+= IIF(!Empty(SE2->E2_TIPOFAT), 1, 0)
					Endif
				Endif

				(cAliasQry)->(dbSkip())

			Enddo

			If nValFat > 0 .And. nValFat <> nValor
				nValor := nValFat
			EndIf

			If !lCancelar .or. lBanco
				dbSelectArea(cAliasQry)
				dbCloseArea()

				dbSelectArea("SE2")
				dbSetOrder(1)

				If lHelpCan
					If !lCancelar
						Help(" ",1,"FATPJABX") // Nao aceita se ja houve baixa em fatura
					ElseIf lBanco
						Help(" ",1,"TITBCO",,STR0063,1,0) //"Esta fatura possui parcela transferida para banco. Retorne os titulos para carteira antes de cancelar a fatura"
					Endif
				Endif

				lRet := .F.

			Endif
		Endif
	Endif

	l290CalCn := lRet

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290FCAN
Abre Alias para Selecao para a criacao do indice condicional 			 
Deverá selecionar todos os registros que atendam a seguinte condicao...
 1. Mesmo fornecedor e loja
 2. Prefixo e Numero do Titulo iguais aos selecionados
 3. Ou titulos que tenham originado a fatura selecionada
@Type Function
@author Cesar C S Prado	
@version P12
@Param cAliasQry, String, Passado por referencia para alimentar o Alias que será aberto
@since	03/05/94
/*/
//-------------------------------------------------------------------
Function FA290FCAN(cAliasQry as Character)
	Local cQuery 	As Character
	Local cCampos 	As Character
	Local cJoinFat	As Character
	Local cJoinTit 	As Character
	Local cWhere 	As Character


	cQuery 	:= ""
	cCampos 	:= ""
	cJoinFat 	:= ""
	cJoinTit 	:= ""
	cWhere 		:= ""

	DEFAULT cAliasQry 	:= "SE2CAN"

	If __oCanQry == NIL
		// Clausula SELECT -----------------------------------------------------------
		cCampos := "SELECT DISTINCT SE2.R_E_C_N_O_ RECNO "
		cCampos += "FROM " + RetSqlName("FI8") + " FI8 "
		// Clausula JOIN Títulos ------------------------------------------------------
		cJoinTit := "INNER JOIN " + RetSqlName("SE2") + " SE2 ON "
		cJoinTit += "FI8.FI8_FILIAL = SE2.E2_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFORI = SE2.E2_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMORI = SE2.E2_NUM "
		cJoinTit += "AND FI8.FI8_PARORI = SE2.E2_PARCELA " 
		cJoinTit += "AND (FI8.FI8_TIPORI = SE2.E2_TIPO " 
		cJoinTit += "OR  (SE2.E2_TIPO IN " + FormatIN(MV_CPNEG +"|"+ MVABATIM,"|") + ") "

		cJoinTit += "AND SE2.E2_FATPREF = FI8.FI8_PRFDES AND SE2.E2_FATURA = FI8.FI8_NUMDES " 
		cJoinTit += "AND SE2.E2_DTFATUR = FI8.FI8_DATA AND SE2.E2_TIPOFAT = FI8.FI8_TIPDES "
		cJoinTit += "AND SE2.E2_FATFOR = FI8.FI8_FORDES AND SE2.E2_FATLOJ = FI8.FI8_LOJDES ) "

		cJoinTit += "AND FI8.FI8_FORORI = SE2.E2_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJORI = SE2.E2_LOJA "
		cJoinTit += "AND SE2.D_E_L_E_T_ = ' '  "
		// Clausula JOIN Fatura -------------------------------------------------------
		cJoinFat := "INNER JOIN " + RetSqlName("SE2") + " SE2 ON "
		cJoinFat +=     "FI8.FI8_FILDES = SE2.E2_FILIAL "
		cJoinFat += "AND FI8.FI8_PRFDES = SE2.E2_PREFIXO "
		cJoinFat += "AND FI8.FI8_NUMDES = SE2.E2_NUM "
		cJoinFat += "AND FI8.FI8_PARDES = SE2.E2_PARCELA "
		cJoinFat += "AND FI8.FI8_TIPDES = SE2.E2_TIPO "
		cJoinFat += "AND FI8.FI8_FORDES = SE2.E2_FORNECE "
		cJoinFat += "AND FI8.FI8_LOJDES = SE2.E2_LOJA "
		cJoinFat += "AND SE2.D_E_L_E_T_ = ' ' "

		// Clausula WHERE -------------------------------------------------------------
		cWhere := "WHERE "
		cWhere +=     "FI8.FI8_FILDES = ? "
		cWhere += "AND FI8.FI8_PRFDES = ? "
		cWhere += "AND FI8.FI8_NUMDES = ? "
		cWhere += "AND FI8.FI8_TIPDES = ? "
		cWhere += "AND FI8.FI8_FORDES = ? "
		cWhere += "AND FI8.FI8_LOJDES = ? "
		cWhere += "AND FI8.FI8_DATA   = ? "
		cWhere += "AND FI8.D_E_L_E_T_ = ' '"

		// Montagem QUERY ------------------------------------------------------------
		cQuery += cCampos + cJoinTit + cWhere
		cQuery += "UNION "
		cQuery += cCampos + cJoinFat + cWhere
		// ----------------------------------------------------------------------------
		
		cQuery 		:= ChangeQuery(cQuery)
		__oCanQry 	:= FWPreparedStatement():New(cQuery)
	endif

	//Insere parâmetros em todas as Queries separadas por UNION

	__oCanQry:SetString(1,FWxFilial("FI8"))
	__oCanQry:SetString(2,cPrefCan)
	__oCanQry:SetString(3,Pad(cFatCan,TAMSX3("E2_FATURA")[1]))
	__oCanQry:SetString(4,cTipoCan)
	__oCanQry:SetString(5,cFornCan)
	__oCanQry:SetString(6,cLojaCan)
	__oCanQry:SetString(7,DTOS(dDataCan))
	//para segunda query
	__oCanQry:SetString(8,FWxFilial("FI8"))
	__oCanQry:SetString(9,cPrefCan)
	__oCanQry:SetString(10,Pad(cFatCan,TAMSX3("E2_FATURA")[1]))
	__oCanQry:SetString(11,cTipoCan)
	__oCanQry:SetString(12,cFornCan)
	__oCanQry:SetString(13,cLojaCan)
	__oCanQry:SetString(14,DTOS(dDataCan))

    cQuery := __oCanQry:GetFixQuery()
		
	cAliasQry := MpSysOpenQuery(cQuery)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290Ok
Exibe mensagem de OK para dados digitados da fatura 			 

@author Pilar S. Albaladejo
@version P12
@since	07/11/95
/*/
//-------------------------------------------------------------------
Static Function Fa290Ok()
	Local lRet := .T.
	lFocus := .F.

	If !lFocus .and. Empty(cTipo)

		//Retorno .T. para que possa focar o campo do numero da
		//fatura para alteração e posterior validação. A valida
		//ção neste caso ‚ feita somente no Fornecedor e ao confirmar a operação da fatura.                         
		Help(" ",1,"TIPOFAT")
		oTipo:SetFocus()
		lFocus := .T.
	Endif

	If !lFocus .and. Empty(cNat)
		//Retorno .T. para que possa focar o campo de natureza 
		//para alteração e posterior validação. A validacao    
		//neste caso ‚ feita somente no Fornecedor e ao con    
		//firmar a operação da fatura.                         
		Help(" ",1,"A290NAT")
		oNat:SetFocus()
		lFocus := .T.
	Endif


	If	!lFocus .and. !Fa290Nat()
		//Retorno .T. para que possa focar o campo de natureza
		//para alteração e posterior validação. A validacao   
		//neste caso ‚ feita somente no Fornecedor e ao con   
		//firmar a operação da fatura.                        
		oNat:SetFocus()
		lFocus := .T.
		lRet := .F.
	Endif

	If lFA290OK
		lRet := Execblock("FA290OK",.F.,.F.)
	Endif

Return If( lRet, (MsgYesNo(STR0045,STR0046)), .F.)//"Confirma Dados?"###"Atenção"

//-------------------------------------------------------------------
/*/{Protheus.doc} fa290Marca
	Trata o valor	para marcar e desmarcar item			 

	@author Pilar S. Albaladejo
	@version P12
	@since	21/11/95
/*/
//-------------------------------------------------------------------
STATIC Function fa290Marca(cAlias As Character, cMarca As Character, nLimite As Numeric, lPccBaixa As Logical, lBaseSE2 As Logical, ;
	aChaveLbn As Array, aFatPag As Array, cASE2Abt As Character, oSay As Object)

	LOCAL nRec 		As Numeric
	Local cAliasAnt As Character
	Local lMarkTit 	As Logical
	Local nPosChave As Numeric
	Local cChaveLbn As Character
	Local nAbatim 	As Numeric
	Local aChaveTit As Array
	Local nCasDec 	As Numeric
	Local _nIVa		As Numeric
	Local _nTotSe2	As Numeric
	Local lTela		As Logical

	nRec 		:= 0
	cAliasAnt 	:= Alias()
	lMarkTit 	:= .t.
	nPosChave 	:= 0
	cChaveLbn 	:= ""
	nAbatim 	:= 0
	aChaveTit 	:= {}
	nCasDec 	:= TamSx3("E2_TXMOEDA")[2]
	_nIVa		:= 1
	_nTotSe2	:= (cAlias)->(RECCOUNT())
	lTela		:= !isblind()

	Default aFatPag   := {}

	dbSelectArea(cAlias)
	nRec := Recno()
	SE2->(dbGoto((cAlias)->RECNO))
	
	(cASE2Abt)->(DbSetOrder(1))

	While (cAlias)->(!Eof())
		If	lTela
			oSay:cCaption := (STR0106 + cValToChar(_nIVa) + STR0107 + cValToChar(_nTotSe2) + STR0108) //Processando registro x de y, aguarde."
			ProcessMessages()
		EndIf
		cChaveLbn := "FAT" + (cAlias)->(xFilial("SE2")+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		nAbatim := 0
		//-----------------------------------------------------------------
		// PONTO DE ENTRADA F290TIT
		// Verifica se titulo pode ser marcado para compor a Fatura,
		// caso tenha sido alterada a marcação do titulo, ExecBlock
		// deve retornar .F., para não haver alteração dos acumuladores
		// de valores e numero de titulos.
		//-----------------------------------------------------------------
		If Len(aFatPag) > 0
			lMarkTit := .T.
		EndIf
		If lF290Tit
			lMarkTit := ExecBlock("F290TIT",.F.,.F.,{.T.})
		EndIf
		If LockByName(cChaveLbn,.T.,.F.)
			If  SE2->(MsRLock()) .And. RecLock(cAlias) // Se conseguir travar o registro
				If lMarkTit .And. Len(aFatPag) > 0
					nPosFat := Ascan(aFatPag[13],{ | e | e[1]+e[2]+e[3]+e[4]+ if(len(e)>=6,e[6]+e[7],"") + if(len(e)>7,e[8],"")== (cAlias)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+ if(len(e)>=6,E2_FORNECE+E2_LOJA,"") + if(len(e)>7,E2_FILIAL,""))})
					If nPosFat > 0
						aFatPag[13,nPosFat,5] := .T.
					Else
						lMarkTit := .F.
					EndIf
				EndIf
				If lMarkTit
					If	(nValor <= nLimite .Or. Empty(nLimite)) .and. (cAlias)->(MsRLock()) // Se conseguir travar o registro
						(cAlias)->E2_OK := cMarca
						If Ascan(aChaveLbn, cChaveLbn) == 0
							Aadd(aChaveLbn,cChaveLbn)
						Endif
						If E2_TIPO $ MV_CPNEG+"/"+MVABATIM
							nValor -= Round( xMoeda((cAlias)->(E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS), (cAlias)->E2_MOEDA, nMoeda, dDatabase,nCasDec, (cAlias)->E2_TXMOEDA), 2)
							nValCruz -= (cAlias)->E2_VLCRUZ + Round( xMoeda((cAlias)->(E2_SDACRES-E2_SDDECRE),(cAlias)->E2_MOEDA,1,(cAlias)->E2_EMISSAO,nCasDec),2)
							nQtdTit++
						Else
							If (cAlias)->CALCULADO == '1'
								nAbatim	:= (cAliasSE2)->ABATMTS
							Else								
								(cASE2Abt)->(DBGoTop())
								(cASE2Abt)->(DbSeek((cAlias)->(RECNO)))
								While (cASE2Abt)->(!EoF()) .and. (cASE2Abt)->(!BOF()) .and. (cASE2Abt)->(RECNO) == (cAlias)->(RECNO)
									nAbatim += xMoeda((cASE2Abt)->VLRET,(cASE2Abt)->E2_MOEDA,(cAlias)->E2_MOEDA, dDataBase)
									(cASE2Abt)->(dbSkip())
								EndDo
							
								(cAlias)->CALCULADO := '1'
							EndIf

							//Tratamento para os títulos que possuem a mesma chave, com exceção do tipo, o sistema considera o mesmo abatimento para ambos
							If nAbatim > 0
								If aScan( aChaveTit , E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA ) > 0
									nAbatim := 0
								Else
									aAdd( aChaveTit , E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA )
									ABATSOMADO := nAbatim
								EndIf
							EndIf

							nTitAbats += nAbatim
							nValor += Round( xMoeda((cAlias)->(E2_SALDO+E2_SDACRES-E2_SDDECRE + VLACESS) - nAbatim, (cAlias)->E2_MOEDA, nMoeda, dDatabase,nCasDec,(cAlias)->E2_TXMOEDA), 2)
							nValCruz += (cAlias)->E2_VLCRUZ + Round( xMoeda((cAlias)->(E2_SDACRES-E2_SDDECRE+VLACESS),(cAlias)->E2_MOEDA,1,(cAlias)->E2_EMISSAO,nCasDec), 2) - nAbatim
							nQtdTit++
						EndIf
					Endif
				Endif

			Else
				UnlockByName(cChaveLbn, .T., .F.)
				nPosChave:= Ascan(aChaveLbn, cChaveLbn)
				If nPosChave >0
					aDel(aChaveLbn,nPosChave)
					aSize(aChaveLbn,Len(aChaveLbn)-1)
				Endif
			EndIf
		EndIf
		(cAlias)->(dbSkip())
		SE2->(dbGoto((cAlias)->Recno))
		_nIVa ++ 
	EndDo

	dbGoto(nRec)
	SE2->(dbGoto((cAlias)->Recno))
	dbSelectArea(cAliasAnt)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290Exibe
Exibe Totais de titulos selecionados				 

@author Pilar S. Albaladejo
@version P12
@since	07/11/95
/*/
//-------------------------------------------------------------------
Function Fa290Exibe(cMarca,oValor,oQtdTit,lPccBaixa,lBaseSE2,oTitAbats)
	Local lMarkTit := .t.
	Local nAbatim := 0
	//------------------------------------------------------------------
	//PONTO DE ENTRADA F290TIT                                       
	//Verifica se titulo pode ser marcado para compor a Fatura,      
	//caso tenha sido alterada a marcação do titulo, ExecBlock       
	//dever  retornar .F., para não haver alteração dos acumuladores 
	//de valores e numero de titulos.                                
	//------------------------------------------------------------------
	If lF290TIT
		lMarkTit := ExecBlock("F290TIT",.F.,.F.,{.F.})
	Endif

	If lMarkTit
		If SE2->E2_OK == cMarca
			If E2_TIPO $ MV_CPNEG
				nValor   -= E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS
				nValCruz -= E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE+VLACESS,E2_MOEDA,1,E2_EMISSAO,3),3),2)
				nQtdTit++
			Else
				nAbatim := F290VerAbt( cMarca , .T. )
				nValor   += (E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS) - nAbatim
				nValCruz += E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE+VLACESS,E2_MOEDA,1,E2_EMISSAO,3),3),2) - nAbatim
				nTitAbats += nAbatim
				nQtdTit++
			Endif
		Else
			If E2_TIPO $ MV_CPNEG
				nValor	+= E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS
				nValCruz += E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE+VLACESS,E2_MOEDA,1,E2_EMISSAO,3),3),2)
				nQtdTit--
			Else
				nAbatim := F290VerAbt( cMarca , .F. )
				nValor   -= (E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS) - nAbatim
				nValCruz -= E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE+VLACESS,E2_MOEDA,1,E2_EMISSAO,3),3),2) - nAbatim
				nTitAbats -= nAbatim
				nQtdTit--
			Endif
		Endif
	Endif

	nQtdTit:= Iif(nQtdTit<0,0,nQtdTit)
	oValor:Refresh()
	oQtdTit:Refresh()

	If ValType(oTitAbats) == "O"
		oTitAbats:Refresh()
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fa290Soma
Verifica se o valor da fatura ‚ o mesmo dos tit. marcados 				 

@author Pilar S. Albaladejo
@version P12
@since	27/11/95
/*/
//-------------------------------------------------------------------
Function Fa290Soma()
	IF Str(nValorF,16,2) != Str(nValor,16,2) .and. nValorF != 0
		Help(" ",1,"VALFAT")
		Return .F.
	Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fa290Val
Pede que se digite o valor correto da fatura 				 

@author Pilar S. Albaladejo
@version P12
@since	27/11/95
/*/
//-------------------------------------------------------------------
Function Fa290Val(oValorFat)
	Local oDlg
	Local nOpca := 0

	DEFINE MSDIALOG oDlg FROM 10, 5 TO 17, 33 TITLE STR0049 //"Informe valor correto da Fatura"
	@	 .3,1 TO 2.3,11.9 OF oDlg
	@	1.0,2 	Say STR0050 //"Valor : "
	@	1.0,4.5	MSGET nValorF Picture "@E 999,999,999.99"

	DEFINE SBUTTON FROM 034,042	TYPE 1 ACTION (nOpca := 1,If(!Empty(nValorF),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 034,069.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg
	oValorFat:Refresh()

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290PedCd
Pede que se digite a condicao de pagamento				 

@author Pilar S. Albaladejo
@version P12
@since	27/11/95
/*/
//-------------------------------------------------------------------
Function Fa290PedCd()
	Local oDlg
	Local nOpca := 0
	Local cCond := Space(3)

	DEFINE MSDIALOG oDlg FROM 10, 5 TO 17, 33 TITLE STR0051 //"Informe Condição de Pagamento"
	@	1.0,2 	Say STR0052 //"Condição: "
	@	1.0,5.5	MSGET cCond F3 "SE4" Picture "!!!"  Valid ExistCpo("SE4",cCond) .and. Fa290Cond(cCond) HASBUTTON
	@	0.3,1 TO 2.3,11.9 OF oDlg


	DEFINE SBUTTON FROM 034,069.1	TYPE 1 ;
		ACTION (nOpca := 1,If(	!Empty(cCond) .and. ;
		ExistCpo("SE4",cCond) .and. ;
		Fa290Cond(cCond),oDlg:End(),nOpca:=0)) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return If(nOpca=0,"   ",cCond)

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290LinOk
Confere se a linha digitada esta OK 					 

@author Pilar S. Albaladejo
@version P12
@since	27/11/95
/*/
//-------------------------------------------------------------------
FuncTion Fa290LinOk()
	Local lRet := .T.
	Local nX, lDuplicado := .F.
	Local aArea 	:= GetArea()
	Local aAreaSe2 := SE2->(GetArea())
	Local nCol	   := Len(aCols[1])

	// Se a linha nao estiver deletada e o prefixo foi alterado
	IF !(aCols[n,nCol]) .And. aCols[n][1] != cPrefix
		Help(" ",1,"IGUALPREF")
		lRet := .F.
	Endif
	// Se a linha nao estiver deletada e o TIPO foi alterado
	IF !(aCols[n,nCol]) .and. aCols[n][4] != cTipo
		Help(" ",1,"IGUALTIPO",,STR0058,1,0)  //"Nao e permitida alteracao do tipo do titulo."+CHR(13)+"Deve-se manter o tipo definido no inicio da rotina")
		lRet := .F.
	Endif
	// Se a linha nao estiver deletada e o NUMERO foi alterado
	IF !(aCols[n,nCol]) .and. aCols[n][2] != cFatura
		Help(" ",1,"IGUALNUM",,STR0059+CHR(13)+STR0060	,1,0)	 //"Nao e permitida alteracao do numero do titulo."###"Deve-se manter o numero definido no inicio da rotina"
		lRet := .F.
	Endif
	// Verificar o vencimento da parcela
	IF (aCols[n,5]) < dDataBase
		Help(" ",1,"NOVENCREA")
		lRet := .F.
	Endif
	// Pesquisa por titulos ja cadastrados
	For nX := 1 To Len(aCols)
		// Se encontrou um titulo igual ao ja cadastrado, avisa e nao permite continuar
		If !aCols[nX][Len(aCols[nX])] .And. aCols[nX][1]+aCols[nX][2]+aCols[nX][3]+aCols[nX][4] == ;
			aCols[n][1]+aCols[n][2]+aCols[n][3]+aCols[n][4] .And. nX != n
			lDuplicado := .T.
			Exit
		Endif
	Next
	// Se encontrou um titulo igual ao ja cadastrado, avisa e nao permite continuar
	If !(aCols[n,nCol]) .And. lDuplicado
		lRet := .F.
		Help(" ",1,"A290EXIST")
	Elseif !(aCols[n,nCol]) .And. !lDuplicado
		DbSelectArea("SE2")
		DbSetOrder(1)
		If Msseek(xFilial("SE2")+aCols[n][1]+aCols[n][2]+aCols[n][3]+aCols[n][4]+;
					If(mv_par01 == 1,cForn,cFornP)+If(mv_par01 == 1,cLoja,cLojaP))
			lRet := .F.
			Help(" ",1,"A290EXIST")
		Endif
	Endif
	// Se passou por todas as validacoes, valida o valor
	If lRet .And. !(aCols[n,nCol])
		lRet := NaoVazio(aCols[n][6])
	Endif

	SE2->(RestArea(aAreaSe2))
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290TudOK
Verifica se aCols esta preenchida corretamente						 

@author Pilar S. Albaladejo
@version P12
@since	27/11/95
/*/
//-------------------------------------------------------------------
Function Fa290TudOk() As Logical
	Local nX, nValTot := 0
	LOCAL lRet := .T.
	Local aArea 	:= GetArea()
	Local aAreaSe2 := SE2->(GetArea())
	Local nCol	   := Len(aCols[1])

	For nx:=1 To Len(aCols)
		If !aCols[nx,nCol]
			nValTot += aCols[nx][6]
			// Verifica se o titulo esta cadastrado
			DbSelectArea("SE2")
			DbSetOrder(1)
			If Msseek(xFilial("SE2")+aCols[nX][1]+aCols[nX][2]+aCols[nX][3]+aCols[nX][4]+;
						If(mv_par01 == 1,cForn,cFornP)+If(mv_par01 == 1,cLoja,cLojaP))
				lRet := .F.
				Help(" ",1,"A290EXIST")
				Exit
			Endif
		Endif
	Next nx

	IF Str(nValor,16,2) != Str(nValTot,16,2)
		Help(" ",1,"VALFAT1",,STR0061 + Transform(nValor,"@E 99,999,999,999.99")+chr(13)+; //"Valor das notas "
									STR0062 + Transform(nValTot,"@E 99,999,999,999.99"),4,0) //"Valor da fatura  "
		lRet := .F.
	End

	If lRet .and. (nMoeda != 1) .and. (xMoeda(nValTot, nMoeda, 1, dDataBase, 2, nTxFat, 0) == 0)
		Help(NIL, NIL, "NOEXCHANGE", NIL, STR0112, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0113}) //Taxa da operação não informada. | Informe a taxa da operação ou a taxa do dia antes de confirmar.
		lRet := .F.
	EndIf

	If lFa290TOk .and. lRet
		If !(Execblock("FA290TOK",.F.,.F.))
			lRet := .F.
		Endif
	Endif

	If !isBlind()
		oValTot:Refresh()
	EndIf	
	
	SE2->(RestArea(aAreaSe2))
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290AtuVl
Atualiza valor da fatura na tela 					 

@author Pilar S. Albaladejo
@version P12
@since	27/11/95
/*/
//-------------------------------------------------------------------
FuncTion Fa290AtuVl(lVldCampo)
	Local nx
	DEFAULT lVldCampo := .T.
	nValTot := 0
	For nx:=1 To Len(aCols)
		If !aCols[nx,Len(aCols[1])]
			If nx == n .and. lVldCampo//Se estiver somando a posicao que alterei
				nValtot+= &(ReadVar())
			Else
				nValTot += aCols[nx][6]
			Endif
		Endif
	Next nx

	oValTot:Refresh()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290Invert
Marca / Desmarca	todos os titulos					 

@author Wagner Xavier
@version P12
@since	27/11/95
/*/
//-------------------------------------------------------------------
Static Function Fa290Inverte(cAliasSE2,cMarca,oValor,oQtdTit,lTodos,oMark,lPccBaixa,lBaseSE2,aChaveLbn,cChaveLbn,lAbat,cMarkTit,oTitAbats)
	Local nReg 		:= (cAliasSE2)->(Recno())
	Local lMarkTit	:= .t.
	Local nAbatim	:= 0
	Local cTitAnt	:= ""
	Local nOrderSe2 := (cAliasSE2)->(IndexOrd())
	Local cFilAtu	:= cFilAnt
	Local cFilOrig	:= cFilAnt
	Local nCasDec   := TamSx3("E2_TXMOEDA")[2]
	Local lRet		:= .T.
	Local lHelp     := .F.
	Local nTotalRec := 1


	DEFAULT lTodos  	:= .T.
	DEFAULT lAbat		:= .F.
	DEFAULT cMarkTit	:= ""

	If !lAbat .And. (cAliasSE2)->E2_TIPO $ MVABATIM+"/"+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT
		Msginfo(STR0074,STR0048)//"Este é um título de abatimento, não pode ser marcado/desmarcado, posicione sobre o titulo principal para esta operação"
		Return
	Endif

	dbSelectArea(cAliasSe2)

	If lTodos
		DbGoTop()

		nTotalRec := (cAliasSE2)->(RecCount())
	Endif

	nReg := (cAliasSE2)->(Recno())

	ProcRegua(nTotalRec)

	While !lTodos .Or. ((cAliasSe2)->(!Eof()))

		IncProc()

		If (lTodos .And. (cAliasSE2)->(MsRLock())) .Or. !lTodos

			SE2->(MsGoto((cAliasSe2)->RECNO))

			cFilOrig := SE2->E2_FILORIG

			cChaveLbn := "FAT" + SE2->(xFilial("SE2",cFilOrig)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)

			If SE2->(MsRLock()) .And. ( (lTodos .And. LockByName(cChaveLbn,.T.,.F.)) .Or. !lTodos) .And. Empty(SE2->E2_NUMBOR)
				IF (cAliasSe2)->E2_OK == cMarca
					// Valida se o abatimento ja nao foi desmarcado anteriormente e recalcula a base de saldo
					If lAbat .and. cMarkTit == (cAliasSE2)->E2_OK
						nValor += Round( xMoeda((cAliasSE2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS), (cAliasSE2)->E2_MOEDA, nMoeda, dDatabase,nCasDec, (cAliasSE2)->E2_TXMOEDA), 2)
						lMarkTit := .F.
					Elseif lAbat .and. !empty(cMarkTit) .and. cMarkTit <> (cAliasSE2)->E2_OK
						nValor += Round( xMoeda((cAliasSE2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS), (cAliasSE2)->E2_MOEDA, nMoeda, dDatabase, nCasDec,(cAliasSE2)->E2_TXMOEDA), 2)
						lMarkTit := .F.
					Endif
					
					If lMarkTit
						nAscan := Ascan(aChaveLbn, cChaveLbn )
						
						If nAscan > 0
							UnLockByName(aChaveLbn[nAscan],.T.,.F.) // Libera Lock
							aDel(aChaveLbn,nAscan)
							aSize(aChaveLbn,Len(aChaveLbn)-1)
						Endif
						
						RecLock(cAliasSE2)
						(cAliasSE2)->E2_OK	:= "  "
						(cAliasSE2)->(MsUnlock())

						SE2->(MsUnlock())

						If !lAbat
							cMarkTit := (cAliasSE2)->E2_OK
						Endif
						
						If (cAliasSE2)->E2_TIPO $ MV_CPNEG
							nValor += Round( xMoeda((cAliasSE2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS), (cAliasSE2)->E2_MOEDA, nMoeda, dDatabase, nCasDec, (cAliasSE2)->E2_TXMOEDA), 2)
						Else
							If !((cAliasSE2)->E2_TIPO $ MVABATIM)
								cFilAnt := cFilOrig

								If (cAliasSE2)->CALCULADO == "1"
									nAbatim	:= (cAliasSE2)->ABATMTS
								Else
									nAbatim := F290VerAbt(cMarca , .F.)
								EndIf
								(cAliasSE2)->ABATSOMADO := 0
								nValor -= Round( xMoeda((cAliasSE2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS) - nAbatim, (cAliasSE2)->E2_MOEDA, nMoeda, dDatabase, nCasDec, (cAliasSE2)->E2_TXMOEDA), 2)
								nTitAbats -= nAbatim
								cFilAnt := cFilAtu
							Endif
						Endif
						nQtdTit--
					Endif
				Else
					//PONTO DE ENTRADA F290TIT                                       
					//Verifica se titulo pode ser marcado para compor a Fatura,      
					//caso tenha sido alterada a marcação do titulo, ExecBlock       
					//dever  retornar .F., para não haver alteração dos acumuladores 
					//de valores e numero de titulos.                                
					lMarkTit := .T.
					If lF290Tit
						lMarkTit := ExecBlock("F290TIT",.F.,.F.,{.F.})
					Endif
					// Valida se o abatimento ja nao foi desmarcado anteriormente e recalcula a base de saldo
					If lAbat .and. cMarkTit == (cAliasSE2)->E2_OK
						nValor -= Round( xMoeda((cAliasSE2)->( E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS), (cAliasSE2)->E2_MOEDA, nMoeda, dDatabase, nCasDec, (cAliasSE2)->E2_TXMOEDA), 2)
						lMarkTit := .F.
					Endif

					If SE2->(Deleted())//Verifica se registro está deletado, caso sim, não permite a marcação.
						lMarkTit := .F.
						If !lHelp
							lHelp := .T.
							Help(" ",1,"DELETED",,If(!lTodos, STR0098, STR0099),1,0)//"Este título está deletado. Não é permitido marcar/desmarcar" # "Há registro(s) deletado(s). Não é permitido marcar/desmarcar."  
						EndIf	
					EndIf

					If lMarkTit
						If Ascan(aChaveLbn, cChaveLbn) == 0
							Aadd(aChaveLbn,cChaveLbn)
						Endif
						RecLock(cAliasSE2)
						(cAliasSE2)->E2_OK := cMarca

						If !lAbat
							cMarkTit := (cAliasSE2)->E2_OK
						Endif
						If (cAliasSE2)->E2_TIPO $ MV_CPNEG
							nValor -= Round( xMoeda((cAliasSE2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS) - nAbatim, (cAliasSE2)->E2_MOEDA, nMoeda, dDatabase, nCasDec, (cAliasSE2)->E2_TXMOEDA), 2)
						Else
							If !(E2_TIPO $ MVABATIM)
								cFilAnt := cFilOrig

								If (cAliasSE2)->CALCULADO == "1"
									(cAliasSE2)->ABATSOMADO := nAbatim := (cAliasSE2)->ABATMTS
								Else
									nAbatim	:= F290VerAbt(cMarca , .T.)
								EndIf

								nValor += Round( xMoeda((cAliasSE2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE+VLACESS) - nAbatim, (cAliasSE2)->E2_MOEDA, nMoeda, dDatabase, nCasDec, (cAliasSE2)->E2_TXMOEDA), 2)
								nTitAbats += nAbatim
								cFilAnt := cFilAtu
							Endif
						Endif
						nQtdTit++
					Else
						(cAliasSE2)->E2_OK	:= "  "
						(cAliasSE2)->(MsUnlock())
					Endif
				Endif
			Else
				IW_MsgBox(STR0068,STR0046,"STOP") //"Este titulo está sendo utilizado em outro terminal, não pode ser utilizado na fatura"###"Atenção"
				lRet := .F.
				Exit
			Endif

			If lTodos
				(cAliasSE2)->(dbSkip())
			Else
				cChaveLbn := "FAT" + (cAliasSE2)->(xFilial("SE2",cFilOrig)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
				nReg := (cAliasSE2)->(Recno())
				Exit
			Endif
		EndIf
	Enddo

	If lRet .and. !(cAliasSE2)->E2_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT

		cFilOrig := SE2->E2_FILORIG
		cChaveLbn := "FAT" + (cAliasSE2)->(xFilial("SE2",cFilOrig)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
		If !lTodos
			nReg := (cAliasSE2)->(Recno())
		EndIf

		(cAliasSE2)->(DbSetOrder(1))	//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA
		If (cAliasSE2)->(dbSeek((cAliasSE2)->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA)))
			cTitAnt := (cAliasSE2)->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA)
			While (cAliasSE2)->(!Eof()) .And. cTitAnt == (cAliasSE2)->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA)
				If !(cAliasSE2)->E2_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT
					(cAliasSE2)->(dbSkip())
					Loop
				Endif
				If (cAliasSE2)->(FieldPos("RECNO")) > 0
					DbSelectArea("SE2")
					MsGoto((cAliasSE2)->RECNO)
					DbSelectArea(cAliasSE2)
				Endif
				// Verifica se o registro nao esta sendo utilizado em outro terminal
				If LockByName(cChaveLbn,.T.,.F.)
					If Ascan(aChaveLbn, cChaveLbn) == 0
						Aadd(aChaveLbn,cChaveLbn)
					Endif
					Fa290Inverte(cAliasSE2,cMarca,oValor,oQtdTit,lTodos,oMark,lPccBaixa,lBaseSE2,aChaveLbn,cChaveLbn,.T.,cMarkTit,oTitAbats)
				Else
					IW_MsgBox(STR0068,STR0046,"STOP") //"Este titulo está sendo utilizado em outro terminal, não pode ser utilizado na fatura"###"Atenção"
				Endif
				(cAliasSE2)->(DbSkip())
			Enddo
		Endif
		(cAliasSE2)->(DbSetOrder(nOrderSe2))
		(cAliasSE2)->(dbGoto(nReg))
	Endif
	(cAliasSE2)->(dbGoto(nReg))

	oValor:Refresh()
	oQtdTit:Refresh()
	If ValType(oTitAbats) == "O"
		oTitAbats:Refresh()
	EndIf
	oMark:oBrowse:Refresh(.t.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fa290ValOK
Verifica se o valor da fatura ‚ v lido (maior que zero) 					 

@author Mauricio Pequim Junior
@version P12
@since	28/09/99
/*/
//-------------------------------------------------------------------
Function Fa290ValOK(cAliasSe2, cMarca)

	Local lRet := .T. 
	Local nBkpReg := SE2->(Recno())
	Local lHelp := .F.

	IF nValor <= 0
		Help(" ",1,"VLFATNEG")
		lRet := .F.
	Endif

	If lRet .and. SuperGetMV("MV_NGMNTFI",.F.,"N") == "S"  .And. FindFunction("NGVALFAT")
		If !NGVALFAT(_oFina2901)
			lRet := .F.
		EndIf
	EndIf

	//verifica se os registros selecionados não foram deletados no meio tempo.
	While ((cAliasSe2)->(!Eof()))

		SE2->(MsGoto((cAliasSe2)->RECNO))

		If (cAliasSe2)->E2_OK == cMarca .AND. SE2->(Deleted())
			lRet := .F.
			If !lHelp
				lHelp := .T.
				Help(" ",1,"DELETED",,STR0099,1,0)
			EndIf

			Exit
		EndIf

		(cAliasSe2)->(DbSkip())
	EndDo

	SE2->(MsGoto(nBkpReg)) //restaura registro posicionado
	(cAliasSe2)->(DbGoTop())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290Tipo 
Checa o Tipo do titulo informado 					 

@author Mauricio Pequim Junior
@version P12
@since	19/11/99
/*/
//-------------------------------------------------------------------
Function FA290Tipo(cTipoDoc)
	LOCAL lRetorna := .T.
	dbSelectArea("SX5")
	If !dbSeek(cFilial+"05"+cTipoDoc)
		Help(" ",1,"E2_TIPO")
		lRetorna := .F.
	Elseif !NewTipCart(cTipoDoc,"2")
		Help(" ",1,"TIPOCART")
		lRetorna := .F.
	Else
		If cTipoDoc $ MVRECANT+"/"+MV_CRNEG
			Help(" ",1,"E2_TIPO")
			lRetorna := .F.
		ElseIf cTipoDoc $ MVPAGANT+"/"+MVTAXA+"/"+MV_CPNEG+"/"+MVABATIM
			Help(" ",1,"TIPOFAT")
			lRetorna := .F.
		Endif
	Endif
Return lRetorna

//-------------------------------------------------------------------
/*/{Protheus.doc} fa290nat 
Checa o Tipo do titulo informado 					 

@author Paulo Boschetti
@version P12
@since	27/07/93
/*/
//-------------------------------------------------------------------
Static Function FA290NAT()
	Local cAlias		:= Alias()
	Local lRet			:= .T.
	Local lValidBloq	:= SED->(FieldPos("ED_MSBLQL")) > 0

	dbSelectArea("SED")
	If !(dbSeek(xFilial("SED")+cNat))
		Help(" ",1,"A290NAT")
		lRet:=.F.
	Endif

	If lRet .and. !FinVldNat( .F., cNat, 2 )
		lRet	:= .F.
	EndIf

	If lRet .And. lValidBloq
		If SED->ED_MSBLQL == "1"
			Help(" ",1,"EDBLOCKED",,STR0072,1,0)//"Natureza bloqueada para novas movimentações"
			lRet := .F.
		Endif
	EndIf

	If lRet .And. lFIN290NAT
		lRet := ExecBlock("FIN290NAT")
	Endif

	dbSelectArea(cAlias)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290bAval
Bloco de marcacoo  				 

@author Mauricio Pequim Jr.
@version P12
@since	02/04/03
/*/
//-------------------------------------------------------------------
Static Function Fa290bAval(cAlias,cMarca,oValor,oQtda,oMark,lPccBaixa,lBaseSE2,aChaveLbn,oTitAbats)
	Local lRet 		:= .T.
	Local cChaveLbn

	// Verifica se o registro nao esta sendo utilizado em outro terminal
	cChaveLbn := "FAT" + (cAlias)->(xFilial("SE2")+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)

	//PONTO DE ENTRADA F290VAL                                       
	//Retorna Array contendo os Titulos Marcados.                    
	If lF290Val
		ExecBlock("F290VAL",.F.,.F.,{aChaveLbn})
	Endif

	// Verifica se o registro nao esta sendo utilizado em outro terminal
	//-- Parametros da Funcao LockByName() :
	//   1o - Nome da Trava
	//   2o - usa informacoes da Empresa na chave
	//   3o - usa informacoes da Filial na chave
	lRet := Processa({ || Fa290Inverte(cAlias,cMarca,oValor,oQtda,.F.,oMark,lPccBaixa,lBaseSE2,aChaveLbn,cChaveLbn,,,oTitAbats)}) // Marca o registro e trava

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa290Pesq
tela de pesquisa - WINDOWS 			 

@author Paulo Augusto
@version P12
@since	07/03/06
/*/
//-------------------------------------------------------------------
Function Fa290Pesq(oMark, cAlias)
	Local cAliasAnt	:= Alias()
	Local nRecno
	Local nOrdInd		:= IndexOrd()
	Local cFiltro		:= ""

	dbSelectArea(cAlias)
	nRecno := Recno()

	AxPesqui()

	// Se o que foi digitado para pesquisa nao estiver dentro do filtro
	// Continua no mesmo registro que estava antes de selecionar CTRL-P
	cFiltro := Fa290ChecF(,,,,.F.)
	If &(cFiltro)
		(cAliasAnt)->(dbSeek((cAlias)->&((cAliasAnt)->(INDEXKEY()))))
	Else
		(cAlias)->(dbGoto(nRecNo))
	Endif

	DbSelectArea(cAliasAnt)
	(cAliasAnt)->(dbSetOrder(nOrdInd))

	oMark:oBrowse:Refresh(.T.)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@Sample 
Parametros do array a Rotina:
1. Nome a aparecer no cabecalho                          
2. Nome da Rotina associada                                 
3. Reservado                                                
4. Tipo de Transa‡„o a ser efetuada:                       
	1 - Pesquisa e Posiciona em um Banco de Dados   	
	2 - Simplesmente Mostra os Campos                     
	3 - Inclui registros no Bancos de Dados              
	4 - Altera o registro corrente                          
	5 - Remove o registro corrente do Banco de Dados      
5. Nivel de acesso                                         
6. Habilita Menu Funcional

@author Ana Paula N. Silva
@since  27/11/2006
@version 12
@Return Array com opcoes da rotina.
/*/
//-------------------------------------------------------------------------  
Static Function MenuDef()
	Local aRotina := { 	{ STR0001,"AxPesqui"  	, 0 , 1,,.F.},; //"Pesquisar"
						{ STR0002,"FA050Visua"  , 0 , 2 	},; //"Visualizar"
						{ STR0003,"FA290Aut"    , 0 , 3 	},; //"Selecionar"
						{ STR0004,"FA290Can"    , 0 , 6 	},; //"Cancelar"
						{ STR0071,"FA040Legenda", 0 , 7,,.F.}}	//"Legenda"
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} FinA290T
Chamada semi-automatica utilizado pelo gestor financeiro		 

@author Marcelo Celi Marques
@version P12
@since	26/03/08
/*/
//-------------------------------------------------------------------
Function FinA290T(aParam)
	cRotinaExec := "FINA290"
	ReCreateBrow("SE2",FinWindow)
	FinA290(aParam[1])
	ReCreateBrow("SE2",FinWindow)
	dbSelectArea("SE2")

	INCLUI := .F.
	ALTERA := .F.
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F290SelFat
Markbrowse da Faturas a Pagar		 
			 
@author Marcelo Celi Marques
@version P12
@since	13/05/08
/*/
//-------------------------------------------------------------------
Function F290SelFat(oDlg,nOpca,cCond,nValor,nValTot,aVenc,cPrefix,cFatura,cTipo,dDatCont,oPanel,oPanel2)
	Local nI  := 0
	Local oFnt := NIL
	Local oFnt2 := NIL

	DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD
	DEFINE FONT oFnt2 NAME "Arial" SIZE 10,14 BOLD

	aCols 	:= If(Type("aCols")=="A",{},aCols)
	aHeader := If(Type("aHeader")=="A",{},aHeader)

	cCondicao := If(nOpca=0,"   ",cCond)
	aVenc := Condicao(nValor,cCondicao,0)
	nDup	:= Len(aVenc)

	aCols := GravaDup(nDup,cPrefix,cFatura,nValor,dDatabase,aVenc)

	If !Empty(aCols)
		aVlCruz := {}
		aVlCruz := F280VlCruz(nDup,nValCruz)
		For nI:=1 To Len(aCols)
			nValTot += aCols[nI][6]
		Next

		IF Str(nValor,16,2) != Str(nValTot,16,2)
			nValTot := nValor
		EndIf

		nOpca := 0
		@ 015,135	SAY STR0029 OF oPanel2 SIZE 80,14 Pixel//"Data Contabiliza‡„o : "
		@ 015,190	Say dDatCont OF oPanel2 SIZE 80,14  Pixel //FONT oDlg2:oFont
		@ 015,248	Say STR0030 OF oPanel2 SIZE 80,14 Pixel //"Condição de Pagamento : "
		@ 015,315	Say cCondicao OF oPanel2 SIZE 80,14  Pixel
		@ 015,375	Say STR0031 OF oPanel2 Pixel SIZE 80,14 //"Valor Total:"

		@ 025,248	Say SE4->E4_DESCRI OF oPanel2 Pixel FONT oFnt2 COLOR CLR_HBLUE
		@ 015,400 Say oValTot VAR nValTot Picture "@E 9,999,999,999.99" OF oPanel2 PIXEL FONT oFnt COLOR CLR_HBLUE //FONT oDlg2:oFont

		oGet := MSGetDados():New(34,5,128,315,3,"Fa290LinOk","Fa290TudOk","",.T.,,,,,,"",,"Fa290AtuVl(.F.)")
		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290MotBX
Funcao criar automaticamente o motivo de baixa FAT na
tabela Mot baixas                                    		 
			 
@author Marcelo Celi Marques
@version P12
@since	23/01/09
/*/
//-------------------------------------------------------------------
Static Function Fa290MotBx(cMot,cNomMot, cConfMot)
	Local lMotBxEsp	:= .F.
	Local aMotbx 	:= ReadMotBx(@lMotBxEsp)
	Local nHdlMot	:= 0
	Local I			:= 0
	Local cFile 	:= "SIGAADV.MOT"
	Local nTamLn	:= 19

	If lMotBxEsp
		nTamLn	:= 20
		cConfMot	:= cConfMot + "N"
	EndIf
	If lFILEMOT
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

		For I:= 0 to  nTamArq step nTamLn // Processo para ir para o final do arquivo
			xBuffer:=Space(nTamLn)
			FREAD(nHdlMot,@xBuffer,nTamLn)
	    Next

		fWrite(nHdlMot,cMot+cNomMot+cConfMot+chr(13)+chr(10))
		fClose(nHdlMot)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F290VlCpos
Função para varrer os campos preenchidos em busca de caracteres especiais
@author TOTVS S/A
@since 14/07/2014
@version P1180
@return Retorno Booleano da validação dos dados
/*/
//-------------------------------------------------------------------
Static Function F290VlCpos(aCps)
	Local nX := 1
	Local lOk := .T.
	Local xCampo

	Default aCps := {"cPrefix","cFatura"}

	Do While nX <= Len(aCps) .And. lOk
		xCampo := &(aCps[nX])
		If !Empty(xCampo) .And. ValType(xCampo) == "C"
			If CHR(39) $ xCampo	 .Or. ;
			CHR(34) $ xCampo
				lOk := .F.
			Endif
		Endif
		nX++
	Enddo
	If !lOk
	Help("",1,"INVCAR",,STR0076,1,0) //"Informe caracteres válidos no preenchimento dos campos"
	Endif

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} F290VerAbt
Faz o controle dos valores de abatimentos para títulos com 
a chave igual, exceção para o tipo.                                                            		 
			 
@author Daniel Mendes de Melo
@version P12
@since	06/01/15
/*/
//-------------------------------------------------------------------
Static Function F290VerAbt( cMarca , lMarcou )
	Local nReturn  := 0
	Local nVlrAbat := 0
	Local nRecNo   := RecNo()
	Local cChave   := E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA
	Local cKey     := E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA
	Local nVlrSoma := ABATSOMADO
	Local cAlias   := Alias()
	Local cFilBckp := cFilAnt

	cFilAnt := E2_FILORIG
	If (cAlias)->CALCULADO == '1'
		nReturn := (cAlias)->VLSOMAABAT
	Else
		nReturn := SomaAbat(E2_PREFIXO,E2_NUM,E2_PARCELA,"P",E2_MOEDA,,E2_FORNECE,E2_LOJA,,,E2_TIPO)
		RecLock( cAlias )
		(cAlias)->VLSOMAABAT := nReturn
		(cAlias)->CALCULADO := '1'
		MsUnLock( cAlias )
	EndIf

	If nReturn > 0
		If ABATSOMADO > 0 .And. !lMarcou
			RecLock( cAlias )
			ABATSOMADO := nVlrAbat
			MsUnLock( cAlias )
		EndIf

		(cAlias)->(DbSeek(xFilial('SE2')+E2_PREFIXO+E2_NUM+E2_PARCELA))

		While !Eof() .AND. (cKey == E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA)
			If ( cChave == E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA ) .And. RecNo() <> nRecNo
				If (cAlias)->CALCULADO == '1'
					nVlrAbat := (cAlias)->VLSOMAABAT
				Else
					nVlrAbat := SomaAbat(E2_PREFIXO,E2_NUM,E2_PARCELA,"P",E2_MOEDA,,E2_FORNECE,E2_LOJA,,,E2_TIPO)
					RecLock( cAlias )
					(cAlias)->VLSOMAABAT := nVlrAbat
					(cAlias)->CALCULADO := '1'
					MsUnLock( cAlias )
				EndIf

				If nVlrAbat > 0 .And. E2_OK == cMarca
					If ABATSOMADO > 0
						nReturn := 0
						Exit
					ElseIf ABATSOMADO == 0 .And. !lMarcou .And. nVlrSoma > 0
						RecLock( cAlias )
						(cAlias)->ABATSOMADO := nVlrAbat
						(cAlias)->CALCULADO := '1'
						MsUnLock( cAlias )
						nReturn := 0
						Exit
					EndIf
				EndIf
			EndIf
			dbSkip()
		EndDo

		dbGoTo( nRecNo )

		If ABATSOMADO == 0 .And. lMarcou .And. nReturn > 0
			RecLock( cAlias )
			ABATSOMADO := nReturn
			MsUnLock( cAlias )
		EndIf
	EndIf

	cFilAnt := cFilBckp

Return nReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} F290VLDDT
Valida data de/até

@author lucas.oliveira
@version P12
@since	26/02/2015
/*/
//-------------------------------------------------------------------
Function F290VLDDT(cCampo, dDataDe, dDataAte )
	local lRet := .T.

	If cCampo == "DataDe"
		If Empty(dDataDe)
			Help(" ",1,"DTVAZIA",,STR0080,1,0)//"O campo Emissão De deve ser preenchido."
			lRet := .F.
		EndIf
	Else
		If !Empty(dDataAte)
			If dDataAte < dDataDe
				Help(" ",1,"DTINVALID",,STR0081,1,0)//"O campo Até deve ser maior ou igual ao campo Emissão De."
				lRet := .F.
			EndIf
			If lRet .and. dDataAte > dDataBase
				Help(" ",1,"DTINVALID",,STR0082 + DTOC(dDataBase)+".",1,0)//"O campo Até deve ser menor ou igual a " DTOC(dDataBase) "."
				lRet := .F.
			EndIf
		Else
		Help(" ",1,"DTVAZIA",,STR0083,1,0)//"O campo Até deve ser preenchido."
		lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F290Static
Inicialização das variaveis estaticas

@author Vitor Duca
@version P12
@since	07/11/2019
/*/
//-------------------------------------------------------------------
Static Function F290Static()

	lF290OWN		:= ExistBlock("F290OWN")
	lF290FPG 		:= ExistBlock("F290FPG")
	lf290CHK 		:= ExistBlock("F290CHK")
	lF290LIBT		:= ExistBlock("F290LIBT")
	lFA290HPAD		:= ExistBlock("FA290HPAD")
	lF290BTIT	  	:= ExistBlock("F290BTIT")
	lF290FORNP		:= EXISTBLOCK("F290FORNP")
	lF290BROW		:= ExistBlock("F290BROW")
	lF290BFIL		:= ExistBlock("F290BFIL")
	lF290PRE		:= ExistBlock("F290PRE")
	lF290Baixa		:= Existblock("F290BAIXA")
	lPEGrava		:= ExistBlock("FI290GE5")
	lF290FIL 		:= ExistBlock("F290FIL")
	lF290CON		:= ExistBlock("F290CON")
	lFA290			:= ExistBlock("FA290")
	lValidCan		:= ExistBlock("FA290OKC")
	lF290CN2		:= ExistBlock("F290CN2")
	lFA290C 		:= ExistBlock("FA290C")
	lF290CAN		:= ExistBlock("F290CAN")
	lFA290OK		:= ExistBlock("FA290OK")
	lF290Tit		:= ExistBlock("F290TIT")
	lFa290TOk		:= Existblock("FA290TOK")
	lF290Val 		:= ExistBlock("F290VAL")
	LFIN290NAT		:= ExistBlock("FIN290NAT")
	lFILEMOT 		:= ExistBlock("FILEMOT")
	lPEMostraTela	:= ExistBlock("FI290MT")
	lFI290Cols		:= ExistBlock("FI290COLS")
	dLastPcc  		:= CTOD("22/06/2015")
	lIsIssBx 		:= FindFunction("IsIssBx")
	lPLSFN290 		:= findFunction("PLSFN290")
	lPodeTVA   		:= ExistFunc("FAPodeTVA")	

	__lExecSt	 	:= FwLibVersion() >= "20211116"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F290SumAbt
Preenche o campo ABATMTS da tabela temporaria com os valores dos
abatimentos correspondentes.

@author Vinicius do Prado
@version P12
@since	19/12/2019
/*/
//-------------------------------------------------------------------
Static Function F290SumAbt(cAliasSE2)
	Local nError   As Numeric
	Local cQry 	   As Character
	Local cTable   As Character
	Local aAreaAnt As Array
	Local cNulo	   As Character
	Local cBDname  As Character

	Default cAliasSE2 := "TRBSE2"
	
	nError    := 0
	cQry 	  := ""
	cTable    := _oFina2901:GetRealName()
	aAreaAnt  := GetArea()
	cNulo	  := ""
	cBDname   := Upper( TCGetDB() )
	cAliasTMP := IIF( cBDname $ "POSTGRES", "", cTable + "." )

	Do CASE
		CASE cBDname $ "ORACLE|INFORMIX|DB2"
			cNulo := "NVL"
		CASE cBDname $ "POSTGRES|MYSQL"
			cNulo := "COALESCE"
		OTHERWISE
			cNulo := "ISNULL"
	End CASE
	
	cQry := " UPDATE " + cTable
	cQry += " SET "+ cAliasTMP +"ABATMTS = "
	cQry += cNulo + "((SELECT SUM(SE2.E2_SALDO) "
	cQry += " FROM " + RetSqlName("SE2") +" SE2"
	cQry += " WHERE " + cTable + ".E2_FILIAL = SE2.E2_FILIAL AND "
	cQry += cTable + ".E2_PREFIXO = SE2.E2_PREFIXO AND "
	cQry += cTable + ".E2_NUM     = SE2.E2_NUM AND "
	cQry += cTable + ".E2_PARCELA = SE2.E2_PARCELA AND "
	cQry += cTable + ".E2_FORNECE = SE2.E2_FORNECE AND "
	cQry += cTable + ".E2_LOJA    = SE2.E2_LOJA AND "
	cQry += "SE2.E2_TIPO IN " + FormatIn(MVABATIM,"|") + " AND "
	cQry += "SE2.D_E_L_E_T_ = ' ' AND "
	cQry += cTable+ ".D_E_L_E_T_ = ' '),0) "
	
	nError := TcSQLExec(cQry)

	If nError < 0
		Conout( 'Erro : ' + 'Erro ao filtrar abatimentos' )
	Else
		dbCommitAll()
		TcRefresh(cTable)
		(cAliasSE2)->(dbGoTop())
	EndIf 

	RestArea(aAreaAnt)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcInverte

Chama a função de marcar todos os registros.

@author L. Fini
@version P12
@since	09/11/2020
/*/
//-------------------------------------------------------------------
Static Function ProcInverte(cAliasSE2,cMarca,oValor,oQtdTit,lTodos,oMark,lPccBaixa,lBaseSE2,aChaveLbn,cChaveLbn,lAbat,cMarkTit,oTitAbats)

	Processa({ || Fa290Inverte(cAliasSE2,cMarca,oValor,oQtdTit,lTodos,oMark,lPccBaixa,lBaseSE2,aChaveLbn,cChaveLbn,lAbat,cMarkTit,oTitAbats) })

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290VA

Calcula os valores acessórios do título posicionado.

@author Bruno Horvat
@version P12
@since	24/08/2021
/*/
//-------------------------------------------------------------------
Static function FA290VA(cAliasSe2,oSay)

Local _nIVa 	:= 0
Local nVA		:= 0
Local _nTotSe2	:= 0
local lTela		:= !isblind()

dbSelectArea(cAliasSe2)
_nIVa := 1
_nTotSe2 := (cAliasSe2)->(RECCOUNT())
nRec := Recno()
While (cAliasSe2)->( !EOF() )
	If	lTela
		oSay:cCaption := (STR0106 + cValToChar(_nIVa) + STR0107 + cValToChar(_nTotSe2) + STR0108)
		ProcessMessages()
	EndIf
	nVA	:= 0.00
	nVA	:= FValAcess( (cAliasSe2)->E2_PREFIXO, (cAliasSe2)->E2_NUM, (cAliasSe2)->E2_PARCELA, (cAliasSe2)->E2_TIPO, (cAliasSe2)->E2_FORNECE, (cAliasSe2)->E2_LOJA, (cAliasSe2)->E2_NATUREZ, Iif(Empty( (cAliasSe2)->E2_BAIXA),.F.,.T.),"","P",  dDatabase )
	DBSelectArea(cAliasSe2)
	RecLock( cAliasSe2, .F. )
	(cAliasSe2)->VLACESS := nVA
	MsUnlock()
	_nIVa ++ 
	(cAliasSe2)->( DBSkip() )
EndDo
dbGoto(nRec)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FA290GRVFT

Efetiva a baixa dos titulos e gera as faturas

@param cAliasSe2	, character	, Alias da tabela filtrada da SE2 com registros marcados para processamento.
@param oSay			, object	, Responsável por exibir as mensagens da régua de processamento
@param nOpcE		, numeric	, Opção escolhida pelo usuário no browse
@param cMarca		, character	, Marca que identifica se o registro deve ser processado ou não
@param lExistVA 	, logical	, Identifica se existe valores acessórios para os títulos (tabelas FKD/FKC)
@param lPccBaixa	, logical	, Identifica se o PCC está configurado para a Baixa
@param lCtrlAlc 	, logical 	, Identifica se o sistema está configurado com o controle de alçada
@param lLoja		, logical	, Identifica se conidera loja do fornecedor 
@param lPadrao		, logical	, Identifica se o processo será contabilizado  
@param nDecres		, numeric	, Valor de Descrescimo a ser considerado caso o array exeutado via execauto
@param nAcresc		, numeric	, Valor de Acrescimo a ser considerado caso o array exeutado via execauto
@param lSE2Compart	, logical	, Identifica o compartilhamento da SE2 
@param nTxFat		, numeric	, Valor da Taxa da Fatura
@param cPadrao		, character	, Código do lançamento padrão
@param nQtdTit		, numeric	, Quantidade de títulos

@return Nil

@author Bruno Horvat
@version P12
@since	24/08/2021
/*/
//-------------------------------------------------------------------
Static Function FA290GRVFT(cAliasSe2,oSay,nOpcE,cMarca,lExistVA,lPccBaixa,lCtrlAlc,;
							lLoja,lPadrao,nDecres,nAcresc,lSE2Compart,nTxFat,cPadrao,nQtdTit)
Local cArquivo		:= ""
Local nTotal		:= 0
Local nHdlPrv		:= 0
Local nX 			:= 0
Local nW 			:= 1
Local cOrigem		:= ''
Local nAcols        := 0
Local lCalcIssBx    := cPaisLoc == "BRA" .And. SuperGetMv("MV_MRETISS",.F.,"1") == "2"
Local lMVINSIRF     := SuperGetMv("MV_INSIRF",.F.,"2") == "1"
Local lIntegAtiv    := SuperGetMV("MV_NGMNTFI",.F.,"N") == "S"  .And. FindFunction("NGATUMNT")
Local nCasDec       := TamSx3("E2_TXMOEDA")[2]
Local cFunName      := SubStr(AllTrim(FunName()), 1, TamSx3("FK2_ORIGEM")[1])
Local nVlMoed2      := 0
Local nSalDup       := 0
Local nSalDupM      := 0
Local nFK2MOEDA     := TamSx3("FK2_MOEDA")[1]
Local nQtdMark		:= 0
Local cFilAtu		:= cFilAnt
Local lInssBx 		:= SuperGetMv("MV_INSBXCP",.F.,"2") == "1"
Local nTotIns 		:= 0
Local nTotBIns		:= 0
Local nTotBISS		:= 0
Local nBaseFat		:= 0
Local oModelBxP		:= nil
Local oSubFK2		:= nil
Local oSubFK6		:= nil
Local oFKA			:= nil
Local cLog			:= ""
Local cChaveTit		:= ""
Local cChaveFK7		:= ""
Local cCamposE5		:= ""
Local nRecSE5		:= 0
Local lRet			:= .T.
Local cCodAprov		:= ""
Local lDirf			:= .F.
Local cTitpai		:=""
// Contabilidade
Local aContabil 	:= {}
Local cCContabil	:= ""
Local cContaCR  	:= ""
Local cContaDB  	:= ""
Local cCCC	    	:= ""
Local cCCD	    	:= ""
Local cCCusto   	:= ""
Local cItemCTA  	:= ""
Local cItemC    	:= ""
Local cItemD    	:= ""
Local cClVl     	:= ""
Local cClVlCR   	:= ""
Local cClVlDB   	:= ""
Local nZ 			:= 0
Local lCContabil 	:= .T.
Local lContaCR	 	:= .T.
Local lContaDB	 	:= .T.
Local lCCusto	 	:= CtbMovSaldo("CTT")		
Local lCCC		 	:= .T.
Local lCCD		 	:= .T.
Local lItemCTA	 	:= CtbMovSaldo("CTD")
Local lItemC	 	:= .T.
Local lItemD	 	:= .T.
Local lClVl	  	 	:= CtbMovSaldo("CTH")
Local lClVlCR	 	:= .T.
Local lClVlDB	 	:= .T.
Local lFAT290SE5 	:= ExistBlock("FAT290SE5")
Local aTitSE5   	:= {}
Local nFRetISS 		:= ""
Local nTRetISS 		:= ""
Local aBaseISS		:= {}
Local nBaseISS		:= 0 
Local aISSFat		:= {}
Local nISSFat 		:= 0
Local lCompNdf  	:= .F.
Local nTamTip  	 	:= TamSX3("E2_TIPO")[1]
Local nTamTit	  	:= TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1]
Local lRastro		:= FVerRstFin()
Local aRastroOri	:= {}
Local aRastroDes	:= {}
Local aFlagCTB		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lBaseIRPF		:= .F.
Local nTotIRF		:= 0
Local nPropIR		:= 1
Local lUsaBaseIr	:= .F.
Local cHistFat		:= ""
Local lFinVDoc		:= IIF(GetNewPar("MV_FINVDOC","2")=="1",.T.,.F.)		//Controle de validacao de documentos obrigatorios
Local cKeyTit		:= ""
Local nPCCRet		:= 0
Local nPisRet		:= 0
Local nCofRet		:= 0
Local nCslRet		:= 0
Local nOldPis 		:= 0
Local nOldCof 		:= 0
Local nOldCsl 		:= 0
Local nTotBase		:= 0
Local nTotPis 		:= 0
Local nTotCof 		:= 0
Local nTotCsl 		:= 0
Local nTotISS 		:= 0
Local nTotIRPJ		:= 0
Local nBaseIrf		:= 0
Local nTtIRFat		:= 0
Local nTxMoeda		:= 0
Local nCpoTp 		:= 0
Local nVlDesc   	:= 0
Local nSlDesc   	:= 0
Local nTamSeq 		:= TamSX3("E5_SEQ")[1]
Local cSequencia 	:= Replicate("0",nTamSeq)
Local nRecSe2 		:= 0
Local nValTotal 	:= 0
Local nVlAcre   	:= 0
Local nSlAcre   	:= 0
Local lContab530	:= mv_par03 == 1 .And. VerPadrao("530")
Local nMoedaC 	 	:= Int(Val(GetMv("MV_MCUSTO")))
Local lPaBruto		:= GetNewPar("MV_PABRUTO","2") == "1"  //Indica se o PA terá o valor dos impostos descontados do seu valor
Local nSalTit 		:= 0
Local STRLCTPAD 	:= ""
Local nTotAbat  	:= 0
Local lTela			:= !isblind()
Local _nIVa			:= 1
local nVA			:= 0
local cTpDoc		:= ""

DbSelectArea("SA2")
DbSelectArea(cAliasSE2)
(cAliasSE2)->(dbGotop())

//ponto de entrada para customizar um historico a ser gravado em todos os titulos selecionados para gerar a fatura.
If lFA290HPAD
	cHistFat := ExecBlock("FA290HPAD", .F., .F.)
EndIf

Begin Transaction
	SED->(dbSetOrder(1))
	SA2->(dbSetOrder(1))
	(cAliasSE2)->(dbSetOrder(__nIdxE2OK))
	(cAliasSE2)->(dbSeek(cMarca))
	
	While !(cAliasSE2)->(Eof()) .And. (cAliasSE2)->E2_OK == cMarca

		If	lTela
			oSay:cCaption := ( STR0109 + cValToChar(_nIVa) + STR0107 + cValToChar(nQtdTit) + STR0108)
			ProcessMessages()
		EndIf

		dbSelectArea("SE2")
		SE2->(DbGoTo((cAliasSE2)->RECNO))
		
		cFilOrig   := SE2->E2_FILORIG
		cNumero    := SE2->E2_NUM
		cPrefixo   := SE2->E2_PREFIXO
		cParcela   := SE2->E2_PARCELA
		ABATIMENTO := 0
		cCamposE5  := ""
		nTxMoeda   := 0
		nValCorr   := 0					
		nSalDupM   := 0
		nQtdMark++
		
		If SE2->E2_MOEDA > 1
			nTxMoeda := Iif(SE2->E2_TXMOEDA > 0, SE2->E2_TXMOEDA, RecMoeda(dDataBase, SE2->E2_MOEDA))
			
			If SE2->E2_TXMOEDA == 0
				nValCorr := fa090Correc() //Calcula correção monetária.
			EndIf
		EndIf
		
		//VALORES ACESSÓRIOS
		If lPodeTVA .and. lExistVA
			FAtuFKDBx(.F., "P")
			nVa := (cAliasSE2)->VLACESS
		Endif
		
		If !lFA290HPAD
			cHistFat := (cAliasSE2)->E2_HIST
		EndIf
		
		cFilAnt := SE2->E2_FILORIG
		
		If (cAliasSE2)->CALCULADO == '1'
			ABATIMENTO := (cAliasSE2)->ABATSOMADO
		Else
			ABATIMENTO := SomaAbat(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, "P", SE2->E2_MOEDA, , SE2->E2_FORNECE, SE2->E2_LOJA, , ,SE2->E2_TIPO)
		Endif
		
		cFilAnt	 := cFilAtu
		nTotAbat += ABATIMENTO
		
		//Baixo os titulos de abatimento
		If ABATIMENTO > 0
			DbSelectArea("__SE2")
			__SE2->(dbSetOrder(1))
			__SE2->(MsSeek(xFilial("SE2",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)))
			While !EOF() .And. __SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA) == xFilial("SE2",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)
				If __SE2->E2_TIPO $ MVABATIM .And. __SE2->E2_FORNECE == SE2->E2_FORNECE .And. Empty( __SE2->E2_BAIXA ) .And. !Empty( __SE2->E2_SALDO )
					If !(__SE2->(E2_FATURA+E2_FATPREF+E2_TIPOFAT+E2_FLAGFAT) == (cFatura+cPrefix+cTipo+"S") .And. __SE2->E2_DTFATUR == dDatabase)
						RecLock("__SE2")
						__SE2->E2_BAIXA 	:= dDataBase
						__SE2->E2_VALLIQ	:= __SE2->E2_SALDO
						__SE2->E2_SALDO	    := 0
						__SE2->E2_MOVIMEN	:= dDataBase
						__SE2->E2_FATURA	:= cFatura
						__SE2->E2_FATPREF	:= cPrefix
						__SE2->E2_TIPOFAT	:= cTipo
						__SE2->E2_DTFATUR	:= dDatabase
						__SE2->E2_FLAGFAT	:= "S"
						__SE2->E2_FATFOR	:= IIF(lLoja,cForn,cFornP)
						__SE2->E2_FATLOJ	:= IIF(lLoja,cLoja,cLojaP)
						MsUnlock()
						
						//Tira o saldo do vencimento programado do titulo
						AtuSldNat(__SE2->E2_NATUREZ, __SE2->E2_VENCREA, __SE2->E2_MOEDA, "2", "P", __SE2->E2_VALLIQ,;
							Round(xMoeda(__SE2->E2_VALLIQ, __SE2->E2_MOEDA, 1, dDataBase, nCasDec, __SE2->E2_TXMOEDA, 0), 2),;
							"+", Nil, cFunName, "__SE2", __SE2->(Recno()), nOpcE)
					EndIf
				Endif
				
				__SE2->(dbSkip())
			Enddo
		Endif
		
		DbSelectArea("SE2")
		SE2->(DbGoTo((cAliasSE2)->RECNO))
		
		//Posiciona no Cadastro de Naturezas
		SED->(DbSeek(xFilial("SED", cFilOrig) + SE2->E2_NATUREZ))
		SA2->(DbSeek(xFilial("SA2", cFilOrig) + SE2->(E2_FORNECE+E2_LOJA)))
		
		If !SE2->E2_TIPO $ MVABATIM .And. SE2->E2_SALDO > 0
			nJur290    := SE2->E2_SDACRES
			nDesc290   := SE2->E2_SDDECRE
			nAcres290  := SE2->E2_ACRESC
			nDecres290 := SE2->E2_DECRESC						
			lIRPFBaixa := SA2->A2_CALCIRF == "2"
			nSalDupM   := (SE2->E2_SALDO - ABATIMENTO)
			lBaseIRPF  := F050BIRPF(2)
			
			//Tratamento de base e impostos Lei 10925 quando pela baixa
			If lPccBaixa .And. SE2->(E2_PIS+E2_COFINS+E2_CSLL) > 0
				nVlrTit := SE2->(E2_VALOR+E2_IRRF+E2_ISS)
				If !lInssBx
					nVlrTit += SE2->E2_INSS
				Endif
				
				nVlrTit += SE2->E2_SEST
				If lCalcIssBx
					nVlrTit -= SE2->E2_ISS
				EndIf
				//AQUI VERIFICO QUANTO FOI RETIDO E QUANTO FALTA RETER
				nPCCRet	:= 0
				nPisRet	:= 0
				nCofRet	:= 0
				nCslRet	:= 0
				If dDatabase < dLastPcc .Or. lEmpPub
					SE5->(DBSetOrder(7))
					If SE5->(MSSEEK(xFilial("SE5",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
						cKeyTit := xFilial("SE5",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
						While !(SE5->(EOF())) .AND. cKeyTit = xFilial("SE5",cFilOrig)+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
							If (Empty( SE5->E5_PRETPIS ) .Or. SE5->E5_PRETPIS == '4' .Or. SE5->E5_PRETPIS == '5') .AND. !(SE5->E5_SITUACA=='C')
								//Valida se trata-se de um movimento de estorno, retirando os valores retidos
								If SE5->E5_TIPODOC != "ES"
									//Armazeno os valores calculados por titulo, retirando os valores retidos
									nPisRet += SE5->E5_VRETPIS
									nCofRet += SE5->E5_VRETCOF
									nCslRet += SE5->E5_VRETCSL
								Else
									//Armazeno os valores calculados por titulo, retirando os valores retidos
									nPisRet -= SE5->E5_VRETPIS
									nCofRet -= SE5->E5_VRETCOF
									nCslRet -= SE5->E5_VRETCSL
								EndIf
								If SubStr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MV_CPNEG
									lCompNdf := .T.
								Endif
							Endif
							SE5->(dbSkip())
						Enddo
					Endif
					If (cPaisLoc == "BRA")   //Utilizo a base dos impostos e nao o saldo do titulo
						nBasePCC += IIF(Empty(E2_BASEPIS), E2_SALDO+E2_ISS+E2_IRRF,E2_BASEPIS)
						If !lInssBx
							nBasePCC += IIF(Empty(E2_BASEPIS),Iif(!lInssBx,E2_INSS,0),0)
						Endif
					Endif
					If lPABruto
						nBasePCC += PABrtComp()
					Endif
					If !lCompNdf
						nPisFat+= SE2->E2_PIS - nPisRet
						nCofFat+= SE2->E2_COFINS - nCofRet
						nCslFat+= SE2->E2_CSLL - nCslRet
					Else
						nPisFat+= (SE2->E2_PIS * E2_SALDO+nPisRet) / E2_VALOR
						nCofFat+= (SE2->E2_COFINS * E2_SALDO+nCofRet) / E2_VALOR
						nCslFat+= (SE2->E2_CSLL * E2_SALDO+nCslRet) / E2_VALOR
					Endif
				ElseIf SE2->E2_TIPO # MVPAGANT .And. Empty(SE2->E2_NUMBOR)
					nSalTit		:= salRefPag(SE2->E2_FORNECE+SE2->E2_LOJA)
					nBasePCC 	+= nSalTit
					aPcc:= newMinPcc(dDataBase,  nSalTit ,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE+SE2->E2_LOJA)
					nPisFat+=   aPcc[2]
					nCofFat+=   aPcc[3]
					nCslFat+=   aPcc[4]
				EndIf
			EndIf
			
			//IRRF na Baixa
			If lIrpfBaixa
				SED->(DbSeek(xFilial("SED", SE2->E2_FILORIG) + SE2->E2_NATUREZ ))
				
				If SA2->A2_TIPO == "J" .And. SED->ED_CALCIRF == "S"
					nTotIRPJ += FCalcIRBx(0, SA2->A2_TIPO, dDatabase, dDataBase)
					nSalTit	 := salRefPag(SE2->E2_FORNECE+SE2->E2_LOJA)
					nBaseIrf += nSalTit
				Endif
				
				lUsaBaseIr := .F.
				
				//Verifico se controla a base de Impostos
				If lBaseIrpf
					If SE2->E2_BASEIRF > 0
						nBaseIrpf += SE2->E2_BASEIRF
						lUsaBaseIr := .T.
					Else
						nBaseIrpf += (SE2->E2_SALDO + Iif(!lInssBx, SE2->E2_INSS,0))
					Endif
				Else
					nBaseIrpf += (SE2->E2_SALDO + Iif(!lInssBx, SE2->E2_INSS,0))
				Endif
				
				//Se nao usou o valor do
				If !lUsaBaseIr .And. !lCalcIssBx
					nBaseIrpf += SE2->E2_ISS
				Endif
				
				//Se for PF, verifica se reduz o INSS da base do IRRF
				nBaseIrpf -= Iif(lMVINSIRF .And. SA2->A2_TIPO != "J", SE2->E2_INSS, 0)
			Endif
			
			RecLock("SE2")
			SE2->E2_BAIXA   := dDataBase
			SE2->E2_VALLIQ	:= SE2->E2_SALDO + SE2->E2_SDACRES - SE2->E2_SDDECRE - ABATIMENTO
			SE2->E2_JUROS	:= nJur290
			SE2->E2_DESCONT	:= nDesc290
			SE2->E2_SALDO	:= 0
			SE2->E2_MOVIMEN := dDataBase
			SE2->E2_FATURA  := cFatura
			SE2->E2_FATPREF := cPrefix
			SE2->E2_TIPOFAT := cTipo
			SE2->E2_DTFATUR := dDataBase
			SE2->E2_FLAGFAT := "S"
			SE2->E2_SDACRES := 0
			SE2->E2_SDDECRE := 0
			SE2->E2_CORREC  := 	nValCorr
			SE2->E2_FATFOR  := IIF(lLoja, cForn, cFornP)
			SE2->E2_FATLOJ  := IIF(lLoja, cLoja, cLojaP)
			
			//Zero os impostos para que não sejam contabilizados neste momento
			//Somente o serao na baixa do titulo gerado pela fatura.
			If lPccBaixa .And. SE2->(E2_PIS+E2_COFINS+E2_CSLL) > 0
				nOldPis        := SE2->E2_PIS
				nOldCof 	   := SE2->E2_COFINS
				nOldCsl        := SE2->E2_CSLL
				SE2->E2_PIS    := 0
				SE2->E2_COFINS := 0
				SE2->E2_CSLL   := 0
			ElseIf lPccBaixa .AND. (nOldPis + nOldCof + nOldCsl) > 0 .AND. SE2->(E2_PIS+E2_COFINS+E2_CSLL) == 0 //reseto as variáveis caso o título anterior tivesse retenção e esse não.
				nOldPis        := SE2->E2_PIS
				nOldCof 	   := SE2->E2_COFINS
				nOldCsl        := SE2->E2_CSLL
			Endif
			
			If lFA290HPAD
				SE2->E2_HIST := cHistFat
			EndIf
			
			SE2->(MsUnlock())
			
			//Atualiza integração com Manutenção de Ativos
			If lIntegAtiv .And. 'MNT' $ SE2->E2_ORIGEM						
				NGATUMNT(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE, SE2->E2_LOJA, cPrefix, cFatura, cTipo, SE2->E2_ORIGEM)
				DbSelectArea("SE2")
				SE2->(DbGoTo((cAliasSE2)->RECNO))
			EndIf
			
			//Tira o saldo do vencimento programado do titulo
			AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALLIQ,;
				Round(xMoeda(SE2->E2_VALLIQ, SE2->E2_MOEDA, 1, dDataBase, nCasDec, SE2->E2_TXMOEDA, 0), 2),;
				"-", Nil, cFunName, "SE2", (cAliasSE2)->RECNO, nOpcE)
			
			//Rastreamento - Geradores
			If lRastro
				aadd(aRastroOri, {SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_VALLIQ } )
			Endif
			
			aAdd(aContabil,  { ;
								{'E2_CONTAD' ,SE2->E2_CONTAD  },;
								{'E2_CREDIT' ,SE2->E2_CREDIT  },;
								{'E2_DEBITO' ,SE2->E2_DEBITO  },;
								{'E2_CCUSTO' ,SE2->E2_CCUSTO  },;
								{'E2_CCC'	  ,SE2->E2_CCC	   },;
								{'E2_CCD'	  ,SE2->E2_CCD     },;
								{'E2_ITEMCTA',SE2->E2_ITEMCTA },;
								{'E2_ITEMC'  ,SE2->E2_ITEMC   },;
								{'E2_ITEMD'  ,SE2->E2_ITEMD   },;
								{'E2_CLVL'   ,SE2->E2_CLVL	   },;
								{'E2_CLVLCR' ,SE2->E2_CLVLCR  },;
								{'E2_CLVLDB' ,SE2->E2_CLVLDB  },;
								} )
			
			If lFinVDoc .And. SE2->E2_TEMDOCS = "1"
				aAdd(aDocsOri, {SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA } )
			EndIf
			
			If lCalcIssBx .And. SE2->E2_ISS > 0 //Retencao do ISS na baixa
				nISSFat  += SE2->E2_ISS
				nBaseISS += SE2->E2_BASEISS
				nFRetISS := SE2->E2_FRETISS
				nTRetISS := SE2->E2_TRETISS
			EndIf
			
			//Grava os lancamentos nas contas orcamentarias SIGAPCO
			PcoDetLan("000015","02","FINA290")
			
			If lF290Baixa
				//Executa PE apos a baixa do titulo que gerou a fatura.
				//Pode ser retornado um historico que sera utilizado na contabilizacao, atraves da variavel STRLCTPAD
				STRLCTPAD += ExecBlock("F290BAIXA",.F., .F.)
			Endif
			
			//Gera movimento da Baixa do Titulo	no SE5
			cSequencia := FaNxtSeqBx("SE2",.T.)  // Sequência da baixa do adiantamento + 1
			
			oModelBxP := FWLoadModel("FINM020")
			oModelBxP:SetOperation(3)
			oModelBxP:Activate()
			oModelBxP:SetValue("MASTER", "E5_GRV", .T.)
			oModelBxP:SetValue("MASTER", "NOVOPROC", .T.)
			
			oSubFK2   := oModelBxP:GetModel("FK2DETAIL")
			oSubFK6   := oModelBxP:GetModel("FK6DETAIL")
			cChaveTit := SE2->E2_FILIAL +"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
			cChaveFK7 := FINGRVFK7("SE2", cChaveTit)
			cChaveFk2 := FWUUIDV4()
			
			//Dados do Processo - Define a chave da FK5 no IDORIG
			oFKA := oModelBxP:GetModel("FKADETAIL")
			
			For nX := 1 To 5
				If nX == 1
					nCpoTp   := SE2->E2_VALLIQ
					nVlMoed2 := nCpoTp 
					cTpDoc   := "BA"
					
					If SE2->E2_MOEDA > 1
						nVlMoed2 := Round(xMoeda(nCpoTp, SE2->E2_MOEDA, 1, dDataBase, nCasDec, nTxMoeda, 0), 2)
					EndIf
				ElseIf nX == 2
					nCpoTp  := nJur290
					cTpDoc  := "JR"
				Elseif nX == 3
					nCpoTp  := nDesc290
					cTpDoc  :="DC"
				Elseif nX == 4
					nCpoTp  := nValCorr
					cTpDoc  :="CM"
				Elseif nX == 5
					nCpoTp  := nVA
					cTpDoc  :="VA"
				Endif
				
				If nCpoTp == 0
					Loop
				EndIf
				
				If !Empty(cCamposE5)
					cCamposE5 += "|"
				Endif
				
				cCamposE5 += "{"
				cCamposE5 += " {'E5_TIPO'	, SE2->E2_TIPO}"
				cCamposE5 += ",{'E5_PREFIXO', SE2->E2_PREFIXO}"
				cCamposE5 += ",{'E5_NUMERO'	, SE2->E2_NUM}"
				cCamposE5 += ",{'E5_PARCELA', SE2->E2_PARCELA}"
				cCamposE5 += ",{'E5_FORNECE', SE2->E2_FORNECE}"
				cCamposE5 += ",{'E5_CLIFOR'	, SE2->E2_FORNECE}"
				cCamposE5 += ",{'E5_LOJA'	, SE2->E2_LOJA}"
				cCamposE5 += ",{'E5_DTDIGIT', dDataBase}"
				cCamposE5 += ",{'E5_DTDISPO', dDataBase}"
				cCamposE5 += ",{'E5_BENEF'	, SE2->E2_NOMFOR}"
				
				If nX == 1
					cCamposE5 += ",{'E5_VLDESCO'," + cValToChar(nDesc290) + "}"
					cCamposE5 += ",{'E5_VLJUROS'," + cValToChar(nJur290)  + "}"
					cCamposE5 += ",{'E5_VLCORRE'," + cValToChar(nValCorr) + "}"
					cCamposE5 += ",{'E5_VLACRES'," + cValToChar(nAcres290)  + "}"
					cCamposE5 += ",{'E5_VLDECRE'," + cValToChar(nDecres290) + "}"
					If !lUsaFlag .and. lPadrao
						cCamposE5 += ",{'E5_LA'	, 'S'}"
					EndIf
					
					//Relacionamento FKA X FK2
					If !oFKA:IsEmpty()
						oFKA:AddLine()
						oFKA:GoLine( oFKA:Length() )
					Endif
					
					oFKA:SetValue("FKA_IDORIG", cChaveFk2 )
					oFKA:SetValue("FKA_TABORI", "FK2" )
					
					//Dados da baixa a pagar
					oSubFK2:SetValue("FK2_DATA",    dDataBase)
					oSubFK2:SetValue("FK2_VALOR",   nCpoTp)
					oSubFK2:LoadValue("FK2_NATURE", SE2->E2_NATUREZ)
					oSubFK2:SetValue("FK2_RECPAG",  "P")
					oSubFK2:SetValue("FK2_TPDOC",   cTpDoc)
					oSubFK2:SetValue("FK2_HISTOR",  STR0056+cFatura) //"Bx.p/Emiss.Fatura "
					oSubFK2:SetValue("FK2_VLMOE2",  nVlMoed2)
					oSubFK2:SetValue("FK2_SEQ",     cSequencia)
					oSubFK2:SetValue("FK2_FILORI",  SE2->E2_FILORIG)
					oSubFK2:SetValue("FK2_CCUSTO",  SE2->E2_CCUSTO)
					oSubFK2:SetValue("FK2_MOEDA",   StrZero(SE2->E2_MOEDA, nFK2MOEDA))
					oSubFK2:SetValue("FK2_MOTBX",   "FAT")
					oSubFK2:SetValue("FK2_IDDOC",   cChaveFK7)
					oSubFK2:SetValue("FK2_ORIGEM",  cFunName)
					oSubFK2:SetValue("FK2_TXMOED",  nTxMoeda)
				ElseIf oFKA:SeekLine({{'FKA_TABORI', "FK2"}})

					If cTpDoc == "VA" .and. nVA != 0
						FSetFK6FKD(oSubFK6,cChaveFK7,cChaveFk2)
					Else
						If !oSubFK6:IsEmpty()
							oSubFK6:AddLine()
							oSubFK6:GoLine( oSubFK6:Length() )
						Endif

						// Grava valores acessórios.
						oSubFK6:SetValue("FK6_FILIAL", FWxFilial("FK6") )
						oSubFK6:SetValue("FK6_IDFK6",  GetSxEnum("FK6","FK6_IDFK6") )
						oSubFK6:SetValue("FK6_TABORI", "FK2" )
						oSubFK6:SetValue("FK6_TPDOC",  cTpDoc )
						oSubFK6:SetValue("FK6_VALCAL", nCpoTp)
						oSubFK6:SetValue("FK6_VALMOV", nCpoTp)
						oSubFK6:SetValue("FK6_RECPAG", "P" )
						oSubFK6:SetValue("FK6_IDORIG", cChaveFK2 )
						oSubFK6:SetValue("FK6_HISTOR", STR0056+cFatura)
					Endif
				EndIf
				
				If !Empty(cCamposE5)
					cCamposE5 += "}"
				Endif
			Next
			
			ABATIMENTO := 0
			oModelBxP:SetValue("MASTER", "E5_CAMPOS", cCamposE5)
			
			//Grava os dados
			If oModelBxP:VldData()
				oModelBxP:CommitData()
				nRecSE5 := oModelBxP:GetValue("MASTER","E5_RECNO")
				SE5->(dbGoTo(nRecSE5))
			Else
				lRet := .F.
				cLog := cValToChar(oModelBxP:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelBxP:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelBxP:GetErrorMessage()[6])
				Help( ,,"M020VALID",,cLog, 1, 0 )
			Endif
			
			If lRet
				//Contabiliza a baixa do titulo
				If lContab530
					If nHdlPrv <= 0
						nHdlPrv := HeadProva( cLote, "FINA290", substr( cUsuario, 7, 6 ), @cArquivo )
					Endif
					
					If lUsaFlag	// Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd(aFlagCTB, {"FK2_LA", "S", "FK2", FK2->(RecNo()), 0, 0, 0})
						aAdd(aFlagCTB, {"E5_LA",  "S", "SE5", SE5->(RecNo()), 0, 0, 0})
					EndIf
					
					//Contabiliza pela variavel VALOR. Nao necessita de controle de flag.
					nTotal += DetProva( nHdlPrv, "530", "FINA290" /*cPrograma*/, cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
										/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
					
					If !lUsaFlag .And. nTotal > 0
						RecLock("FK2",.F.)
						FK2->FK2_LA := "S"
						MsUnlock()
						
						RecLock("SE5",.F.)
						SE5->E5_LA := "S"
						MsUnlock()
					EndIf
				EndIf
				
				If lPEGrava
					Execblock("FI290GE5",.F.,.F.)
				EndIf
				
				//Preenchendo variavel para ponto de entrada
				aadd(aTitSE5,{{"E5_FILIAL"	, E5_FILIAL	, nil },;
					{"E5_DATA"		, E5_DATA		, nil },;
					{"E5_VALOR"		, E5_VALOR		, nil },;
					{"E5_NATUREZ"	, E5_NATUREZ	, nil },;
					{"E5_RECPAG"	, E5_RECPAG		, nil },;
					{"E5_TIPO"		, E5_TIPO		, nil },;
					{"E5_TIPODOC"	, E5_TIPODOC	, nil },;
					{"E5_HISTOR"	, E5_HISTOR		, nil },;
					{"E5_PREFIXO"	, E5_PREFIXO	, nil },;
					{"E5_NUMERO"	, E5_NUMERO		, nil },;
					{"E5_PARCELA"	, E5_PARCELA	, nil },;
					{"E5_FORNECE"	, E5_FORNECE	, nil },;
					{"E5_CLIFOR"	, E5_CLIFOR		, nil },;
					{"E5_LOJA"		, E5_LOJA		, nil },;
					{"E5_DTDIGIT"	, E5_DTDIGIT	, nil },;
					{"E5_MOTBX"		, E5_MOTBX		, nil },;
					{"E5_VLMOED2"	, E5_VLMOED2	, nil },;
					{"E5_VLCORRE"	, E5_VLCORRE	, nil },;
					{"E5_SEQ"		, E5_SEQ		, nil },;
					{"E5_DTDISPO"	, E5_DTDISPO	, nil },;
					{"E5_BENEF"		, E5_BENEF		, nil },;
					{"E5_FILORIG"	, E5_FILORIG	, nil },;
					{"R_E_C_N_O_"	, SE5->(Recno()), nil }})
				//Restauro os valores dos impostos
				If lPccBaixa
					RecLock("SE2")
					SE2->E2_PIS    := nOldPis
					SE2->E2_COFINS := nOldCof
					SE2->E2_CSLL   := nOldCsl
					MsUnlock()
				Endif
				
				If SA2->(DbSeek(xFilial("SA2", cFilOrig) + SE2->(E2_FORNECE+E2_LOJA)))
					nSalDup  := Round(xMoeda(nSalDupM, SE2->E2_MOEDA, 1, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA, 0), 2)
					nSalDupM := Round(xMoeda(nSalDupM, SE2->E2_MOEDA, nMoedaC, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA), 2)
					
					SA2->(RecLock("SA2"))
					If SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG+"|"+MVABATIM
						SA2->A2_SALDUP  += nSalDup
						SA2->A2_SALDUPM += nSalDupM
					Else
						SA2->A2_SALDUP  -= nSalDup
						SA2->A2_SALDUPM -= nSalDupM
					EndIf
					SA2->(MsUnLock())
				EndIf
			EndIf
			
			If ValType(oModelBxP) == "O"
				oModelBxP:DeActivate()
				oModelBxP:Destroy()
			EndIf
			
			oModelBxP:= Nil
			oSubFK2  := Nil
			oSubFK6  := Nil
			oFKA     := Nil
		EndIf
		
		(cAliasSE2)->(dbSkip())
		_nIVa ++
	Enddo

	If	lTela
		oSay:cCaption := (STR0110 + STR0108)
		ProcessMessages()
	EndIf

	If lRet
		If lFAT290SE5
			Execblock("FAT290SE5", .F. ,.F., aTitSE5)
		EndIf
		
		SED->(DbSeek(xFilial("SED", SE2->E2_FILORIG)+cNat))
		
		If dDatabase > dLastPcc .And. SE2->E2_TIPO # MVPAGANT .And. Empty(SE2->E2_NUMBOR) .And. !lEmpPub
			aPcc    := newMinPcc(dDataBase, nBasePCC, cNat, "P", Iif(lLoja, SE2->(E2_FORNECE+E2_LOJA), (cFornP+cLojaP)), , , , , lPCCBaixa)
			nPisFat :=   aPcc[2]
			nCofFat :=   aPcc[3]
			nCslFat :=   aPcc[4]
		Endif
		//Reposiciono no fornecedor destino.
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(fwxFilial("SA2")+Iif(lLoja, (cForn+cLoja), (cFornp+cLojap))))
		
		nValTotal := 0
		
		//Recrio as bases e valores de impostos de acordo com as alteracoes efetuadas nas parcelas da fatura
		aBaseFat  := aClone(aCols)
		aPisFat   := aClone(aCols)
		aCofFat   := aClone(aCols)
		aCslFat   := aClone(aCols)
		aIrfFat	  := aClone(aCols)
		aBaseISS  := aClone(aCols)
		aISSFat   := aClone(aCols)
		aBaseIR	  := aClone(aCols)
		aInsFat	  := aClone(aCols)
		aBaseIns  := aClone(aCols)
		
		lBaseIRPF := F050BIRPF(3)
		
		If lIrpfBaixa .And. (lBaseIrpf .Or. SA2->A2_TIPO == "J")
			If nBaseIrf > 0
				nBaseIrpf := nBaseIrf
			EndIf
			
			If nBaseIrpf < nValor
				nPropIR := nBaseIrpf/nValor
				
				For nW := 1 to Len(aBaseIR)
					aBaseIR[nW,6]	:= (aBaseIR[nW,6] * nPropIr)
				Next nW
			Endif
			
			nPropIr	:= If (SED->ED_BASEIRF > 0, (SED->ED_BASEIRF/100),1)
			
			//Reduzo a base do IR para cada parcela, de acordo com a base de IR da natureza da fatura
			If nPropIR < 1
				nBaseIrpf := nBaseIrpf * nPropIr
				For nW := 1 to Len(aBaseIR)
					aBaseIR[nW,6]	:= (aBaseIR[nW,6] * nPropIr)
				Next nW
			Endif
		Endif										
		
		nAcols := Len(aCols)
		
		//Acerto os valores de base e impostos de acordo com a nova configuracao do aCols
		For nW := 1 to nAcols
			nProp := aCols[nW,6] / nValor  //Proporcao entre a parcela e o valor total da fatura
			
			If nW < nAcols
				aBaseFat[nW,6]	:= nBasePcc  * nProp
				aPisFat[nW,6]	:= nPisFat   * nProp
				aCofFat[nW,6]	:= nCofFat   * nProp
				aCslFat[nW,6]	:= nCslFat   * nProp
				aIrfFat[nW,6]	:= nTotIRPJ  * nProp
				aBaseIr[nW,6]	:= nBaseIrpf * nProp
				aISSFat[nW,6]	:= nISSFat   * nProp
				aBaseISS[nW,6]	:= nBaseISS  * nProp
				
				aBaseIns[nW,6] := nBaseFat * nProp
				aInsFat[nW,6]  := nInsFat  * nProp
				nTotBase +=	aBaseFat[nW,6]
				nTotPis	 +=	aPisFat[nW,6]
				nTotCof	 +=	aCofFat[nW,6]
				nTotCsl	 +=	aCslFat[nW,6]
				nTotISS	 += aISSFat[nW,6]
				nTtIRFat += Round(NoRound(aIrfFat[nW,6],3),2)
				nTotIRF	 += Round(NoRound(aBaseIr[nW,6],3),2)
				nTotIns	 += aInsFat[nW,6]
				nTotBIns += Round(NoRound(aBaseIns[nW,6],3),2)
				nTotBISS += Round(NoRound(aBaseISS[nW,6],3),2)
			Else
				aBaseFat[nW,6] := nBasePcc - nTotBase
				aPisFat[nW,6]  := nPisFat - nTotPis
				aCofFat[nW,6]  := nCofFat - nTotCof
				aCslFat[nW,6]  := nCslFat - nTotCsl
				aISSFat[nW,6]  := nISSFat - nTotISS
				aBaseIr[nW,6]  := nBaseIrpf - nTotIRF
				aIrfFat[nW,6]  := nTotIRPJ - nTtIRFat
				aBaseIns[nW,6] := nBaseFat - nTotBIns
				aInsFat[nW,6]  := nInsFat - nTotIns
				aBaseISS[nW,6] := nBaseISS - nTotBISS 
			Endif
		Next nW
		
		nVlDesc := nDecres / nAcols
		nSlDesc := nDecres
		nVlAcre := nAcresc / nAcols
		nSlAcre := nAcresc
		cCodAprov := ""
		
		If lCtrlAlc
			cCodAprov := FA050Aprov(nMoeda)
		Endif
		
		If lPccBaixa
			If SE2->E2_DIRF == "1"
				lDirf := .T.
			Else
				cTitpai:=SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
				
				BeginSQL Alias "TMPSE2X"
					SELECT E2.E2_DIRF
					FROM %Table:SE2% E2
					WHERE E2.E2_FILIAL = %xfilial:SE2% AND
					E2.E2_DIRF  = %exp:"1"% AND
					E2.E2_TITPAI = %exp:cTitpai% AND
					E2.%NotDel%
				EndSQL
				
				If TMPSE2X->(! Eof())// Verifica se existem titulos de impostos com Dirf, caso não exista não grava o E2_CODRET
					lDirf:=.T.
				EndIf
				
				TMPSE2X->(dbCloseArea())
			EndIf
		EndIf
		//Informacoes contabeis
		cCContabil := SE2->E2_CONTAD	
		cContaCR   := SE2->E2_CREDIT
		cContaDB   := SE2->E2_DEBITO
		cCCusto    := SE2->E2_CCUSTO
		cCCC 	   := SE2->E2_CCC
		cCCD 	   := SE2->E2_CCD	
		cItemC 	   := SE2->E2_ITEMC
		cItemCTA   := SE2->E2_ITEMCTA	
		cItemD     := SE2->E2_ITEMD
		cClVl 	   := SE2->E2_CLVL
		cClVlCR	   := SE2->E2_CLVLCR	
		cClVlDB	   := SE2->E2_CLVLDB
		
		For nW := 1 To nAcols

			If	lTela
				oSay:cCaption := (STR0110 + cValToChar(nW) + STR0107 + cValToChar(nAcols) + STR0108)
				ProcessMessages()
			EndIf

			If !aCols[nW, Len(aCols[1]) ]
				cPrefix		:= aCols[nW][1]
				cParcela 	:= aCols[nW][3]
				cTipo    	:= aCols[nW][4]
				cVencmto 	:= aCols[nW][5]
				nValDup		:= aCols[nW][6]
				nValCruz 	:= xMoeda(aCols[nW,6], nMoeda, 1, dDataBase)
				cBanco		:= aCols[nW][7]
				
				//Caso as Valores das Entidades sejam iguais para todos os titulos, ele irá manter os valores
				//Caso tenha divergencia ele retorna em branco.
				nZ := 1 
				
				While nZ < Len(aContabil)
					If (lCContabil) .and. (AllTrim(aContabil[nZ][1][2]) <> AllTrim(aContabil[nZ+1][1][2]))
						cCContabil := ''
						lCContabil := .F.							
					EndIf
					
					If (lContaCR) .and. (AllTrim(aContabil[nZ][2][2]) <> AllTrim(aContabil[nZ+1][2][2])) 
						cContaCR := ''
						lContaCR := .F.
					EndIf
					
					If (lContaDB) .and. (AllTrim(aContabil[nZ][3][2]) <> AllTrim(aContabil[nZ+1][3][2])) 
						cContaDB := ''
						lContaDB := .F.	
					EndIf
					
					If (lCCusto) .and. (AllTrim(aContabil[nZ][4][2]) <> AllTrim(aContabil[nZ+1][4][2])) 
						cCCusto := ''
						lCCusto := .F.	
					EndIf
					
					If (lCCC).and. (AllTrim(aContabil[nZ][5][2]) <> AllTrim(aContabil[nZ+1][5][2]))
						cCCC := ''
						lCCC := .F.
					EndIf
					If (lCCD) .and. (AllTrim(aContabil[nZ][6][2]) <> AllTrim(aContabil[nZ+1][6][2])) 
						cCCD := ''
						lCCD := .F.
					EndIf
					If (lItemCTA).and.(AllTrim(aContabil[nZ][7][2]) <> AllTrim(aContabil[nZ+1][7][2]))
						cItemCTA := ''
						lItemCTA := .F.
					EndIf
					If (lItemC).and.(AllTrim(aContabil[nZ][8][2]) <> AllTrim(aContabil[nZ+1][8][2])) 
						cItemC := ''
						lItemC := .F.
					EndIf
					If (lItemD) .and.(AllTrim(aContabil[nZ][9][2]) <> AllTrim(aContabil[nZ+1][9][2]))
						cItemD := ''
						lItemD := .F.
					EndIf
					If (lClVl) .and.(AllTrim(aContabil[nZ][10][2]) <> AllTrim(aContabil[nZ+1][10][2]))
						cClVl := ''
						lClVl := .F.		
					EndIf
					If (lClVlCR) .and.(AllTrim(aContabil[nZ][11][2]) <> AllTrim(aContabil[nZ+1][11][2]))
						cClVlCR := ''
						lClVlCR := .F.
					EndIf
					If (lClVlDB) .and. (AllTrim(aContabil[nZ][12][2]) <> AllTrim(aContabil[nZ+1][12][2]))
						cClVlDB := ''
						lClVlDB := .F.	
					EndIf
					If !(lCContabil .Or. lContaCR .Or. lContaDB .Or.;
						lCCusto    .Or. lCCC     .Or. lCCD     .Or.;
						lItemCTA   .Or. lItemC   .Or. lItemD   .Or.;
						lClVl      .Or. lClVlCR  .Or. lClVlDB)
						Exit
					EndIF
					nZ++
				EndDo
				
				If !lSE2Compart .and. mv_par06 == 1
					cOrigem := iIf( lPLSFN290 .and. PLSFN290(), SE2->E2_ORIGEM, "FINA290M" )
				else
					cOrigem := iIf( lPLSFN290 .and. PLSFN290(), SE2->E2_ORIGEM, "FINA290" )
				endIf
				
				RecLock("SE2",.T.)
				Replace E2_FILIAL 	With xFilial("SE2")
				Replace E2_NUM 		With cFatura
				Replace E2_PARCELA	With cParcela
				Replace E2_PREFIXO	With cPrefix
				Replace E2_NATUREZ	With cNat
				Replace E2_VENCTO 	With cVencmto
				Replace E2_VENCREA	With DataValida(E2_VENCTO,.T.)
				Replace E2_VENCORI	With SE2->E2_VENCTO
				Replace E2_EMISSAO	With dDatabase
				Replace E2_EMIS1	With dDatabase
				Replace E2_TIPO		With cTipo
				Replace E2_FORNECE 	With IIF(lLoja, cForn, cFornP)
				Replace E2_LOJA		With IIF(lLoja, cLoja, cLojaP)
				Replace E2_VALOR	With nValDup
				Replace E2_SALDO	With nValDup
				Replace E2_MOEDA	With nMoeda
				Replace E2_PORTADO	With cBanco
				Replace E2_FATURA 	With "NOTFAT"
				Replace E2_NOMFOR 	With SA2->A2_NREDUZ
				Replace E2_VLCRUZ	With Round(xMoeda(nValDup, nMoeda, 1, dDataBase, nCasDec, nTxFat, 0), 2)
				Replace E2_MULTNAT	With "2"
				Replace E2_FILORIG  With cFilAnt
				Replace E2_CODAPRO	With cCodAprov
				Replace E2_DATAAGE 	With DataValida(E2_VENCTO,.T.)
				Replace E2_TXMOEDA 	With nTxFat
				Replace E2_CONTAD 	With cCContabil
				Replace E2_CREDIT   With cContaCR
				Replace E2_DEBITO   With cContaDB
				Replace E2_CCUSTO	With cCCUSTO
				Replace E2_CCC		With cCCC
				Replace E2_CCD		With cCCD
				Replace E2_ITEMCTA 	With cItemCTA
				Replace E2_ITEMC 	With cItemC
				Replace E2_ITEMD 	With cItemD
				Replace E2_CLVL		With cClVl
				Replace E2_CLVLCR	With cClVlCR
				Replace E2_CLVLDB	With cClVlDB
				Replace E2_ORIGEM 	With cOrigem
				
				If lCalcIssBx
					Replace E2_BASEISS 	With  aBaseISS[nW,6]
					Replace E2_ISS 		With  aISSFat[nW,6]
					Replace E2_FRETISS 	With  nFRetISS
					Replace E2_TRETISS 	With  nTRetISS
				EndIf
				
				//Gravar campo de base do IRPF
				If lIrpfBaixa .and. lBaseIrpf
					Replace E2_BASEIRF	With aBaseIR[nW,6]
					Replace E2_PRETIRF 	With "1"
				Endif
				
				//Grava o valor do IRPJ
				If lIrpfBaixa .and. SA2->A2_TIPO == "J" .AND. Len(aIrfFat) > 0
					Replace E2_IRRF 	With aIrfFat[nW,6]
					Replace E2_BASEIRF	With aBaseIR[nW,6]
					Replace E2_PRETIRF 	With "1"
				EndIf
				
				//Impostos Lei 10925 para tratamento na baixa.
				If lPccBaixa .and. (Len(aPisFat)+Len(aCofFat)+Len(aCslFat)> 0 ) .and. ;
					(nW <= Len(aPisFat) .and. nW <= Len(aCofFat) .and. nW <= Len(aCslFat)) .and. ;
					(aPisFat[nW,6]+aCofFat[nW,6]+aCslFat[nW,6] > 0)
					Replace E2_PIS		With  aPisFat[nW,6]
					Replace E2_COFINS	With  aCofFat[nW,6]
					Replace E2_CSLL		With  aCslFat[nW,6]
					Replace E2_BASEPIS 	With  aBaseFat[nW,6]
					Replace E2_BASECOF 	With  aBaseFat[nW,6]
					Replace E2_BASECSLL	With  aBaseFat[nW,6]
					Replace E2_PRETPIS	With  "1"
					Replace E2_PRETCOF 	With  "1"
					Replace E2_PRETCSL 	With  "1"
				Endif
				
				// lDirf - necessária pois podemos ter PCC na Bx e IR na Emissao, isso faz com que o E2_DIRF=="2" e não podemos gerar cod ret quando não houver impostos.
				If lPccBaixa .And. lDirf .And. ( SE2->E2_PIS> 0 .Or. SE2->E2_COFINS > 0 .Or. SE2->E2_CSLL > 0 )
					Replace E2_CODRET With "5952"
				Endif
				
				If nDecres > 0
					Replace E2_DECRESC   With Iif(nW == Len(aCols),nSlDesc,nVlDesc)
					Replace E2_SDDECRE   With Iif(nW == Len(aCols),nSlDesc,nVlDesc)
					nSlDesc -= nVlDesc
				EndIf
				
				If nAcresc > 0
					Replace E2_ACRESC    With Iif(nW == Len(aCols),nSlAcre,nVlAcre)
					Replace E2_SDACRES   With Iif(nW == Len(aCols),nSlAcre,nVlAcre)
					nSlAcre -= nVlAcre
				EndIf
				
				If nQtdMark == 1 // Replicar informações somente em caso de Fatura de 1(um) título originador.
					Replace E2_HIST With  cHistFat
					//Grava contas e custos do titulo pai
					Replace E2_CONTAD	With  cContaDB
					Replace E2_ITEMC	With  cItemC
					Replace E2_ITEMD	With  cItemD
					Replace E2_CLVLCR	With  cClVlCR
					Replace E2_CLVLDB	With  cClVlDB
				ElseIf lFA290HPAD
					Replace E2_HIST		With  cHistFat
				EndIf
				//Atualiza Flag de Lancamento contabil
				If lPadrao
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, { "E2_LA", "S", "SE2", SE2->( RecNo() ), 0, 0, 0} )
					Else
						SE2->E2_LA := "S"
					EndIf
				EndIf
				
				//Documentos
				IF lFinVDoc .And. Len(aDocsOri) > 0
					SE2->E2_TEMDOCS := "1"
				EndIf
				
				MsUnlock()
				
				nRecSe2 := SE2->(Recno())	
				//Dados da tabela auxiliar com o código do título a pagar
				cChaveTit := xFilial("SE2", SE2->E2_FILORIG)+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
				FINGRVFK7("SE2", cChaveTit)
				//Somo o saldo do vencimento programado do titulo
				AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "+", Nil, cFunName, "SE2", SE2->(Recno()), nOpcE)
				
				SE2->(DBGoTo(nRecSe2))
				
				If SE2->E2_VALOR > 0 .And. SA2->(DbSeek(xFilial("SA2", SE2->E2_FILORIG) + SE2->(E2_FORNECE+E2_LOJA)))
					nSalDup  := Round(xMoeda(SE2->E2_VALOR, SE2->E2_MOEDA, 1, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA, 0), 2)
					nSalDupM := Round(xMoeda(SE2->E2_VALOR, SE2->E2_MOEDA, nMoedaC, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA), 2)
					
					SA2->(RecLock("SA2"))
					If SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG+"|"+MVABATIM
						SA2->A2_SALDUP  -= nSalDup
						SA2->A2_SALDUPM -= nSalDupM
					Else
						SA2->A2_SALDUP  += nSalDup
						SA2->A2_SALDUPM += nSalDupM
					EndIf
					SA2->(MsUnlock())
				EndIf
				
				If lFA290
					ExecBlock("FA290",.f.,.f.)
				Endif
				
				nValTotal += Round(xMoeda(nValDup, SE2->E2_MOEDA, 1, dDataBase, nCasDec, nTxFat, 0), 2)
				
				If lPadrao
					If nHdlPrv <= 0
						nHdlPrv := HeadProva( cLote, "FINA290", substr( cUsuario, 7, 6 ), @cArquivo )
					Endif
					
					VALOR := 0
					//Contabiliza pela variavel VALOR. Nao necessita de controle de flag.
					nTotal += DetProva( nHdlPrv, cPadrao, "FINA290" /*cPrograma*/, cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/,;
										/*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
				EndIf
				
				dbSelectArea("SE2")
				//Grava os lancamentos nas contas orcamentarias SIGAPCO
				PcoDetLan("000015","01","FINA290")
				
				//Rastreamento - Gerados
				If lRastro
					aadd(aRastroDes,{	SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_VALOR } )
				Endif
				
				//Documentos
				IF lFinVDoc .And. Len(aDocsOri) > 0
					aAdd(aDocsDes,{SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA } )
				EndIf
			Endif
		Next nW
		
		//Gravacao do rastreamento
		If lRastro
			FINRSTGRV(2,"SE2",aRastroOri,aRastroDes,nValTotal)
		Endif
		
		If Len(aDocsOri) > 0
			CN062GrvFat(aDocsOri,aDocsDes)
		EndIf
	Else
		DisarmTransaction()
	EndIf
End Transaction

If nTotal > 0
	nRecSe2 := SE2->(Recno())				
	VALOR   := nValTotal
	SE2->(DbGoto(0))
	
	//Contabiliza pela variavel VALOR. Nao necessita de controle de flag.
	nTotal += DetProva( nHdlPrv, cPadrao, "FINA290" /*cPrograma*/, cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/,;
						/*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
	
	RodaProva(nHdlPrv, nTotal)
	cA100Incl(cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, mv_par02 == 1, .F., /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/ )
	
	aFlagCTB := {}
	VALOR    := 0
	dbSelectArea("SE2")
	SE2->(DbGoto(nRecSe2))
Endif

//Grava no SX6 o numero da ultima fatura gerada
If lRet
	dbSelectArea("SX6")
	PutMv("MV_NUMFATP", cFatura)
EndIf
		
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} F290PRCCAN

Efetiva o cancelamento da Fatura

@param nTitulos		, numeric	, Quantidades de títulos que compõe o processamento 
@param nValor		, numeric	, Valor das notas
@param cAlias		, character	, Alias da tabela principal - SE2
@param nFaturas		, numeric	, Valor total da Fatura
@param l290CalCn 	, logical	, Identifica e conseguiu criar indice temporario para o cancelamento da fatura	
@param lSE2Compart	, logical	, Identifica o compartilhamento da SE2 
@param cAliasQry 	, character , Alias da tabela SE2 para os registros de cancelamento - SE2CAN
@param cOrigem		, character	, identificação da rotina de origem do título
@param lBxParcFat	, logical	, Identifica ses títulos que geraram a fatura sofrera baixas parciais 
@param nOpce		, numeric	, Opção escolhida pelo usuário no browse
@param oSay			, object	, Responsável por exibir as mensagens da régua de processamento

@return Nil

@author Bruno Horvat
@version P12
@since	25/08/2021
/*/
//-------------------------------------------------------------------
Static Function F290PRCCAN(nTitulos,nValor,cAlias,nFaturas,l290CalCn,lSE2Compart,cAliasQry,cOrigem,lBxParcFat,nOpce,oSay)

Local cArquivo		:= ""
Local nTotal		:= 0 
Local nHdlPrv		:= 0
Local cChaveSE2		:= ""
Local cFilTit		:= ""
Local nValTotal 	:= 0
Local dBaixa 		:= CTOD("//")
Local lValidCan		:= ExistBlock("FA290OKC")
Local lContab531 	:= VerPadrao("531") .And. ( mv_par04 == 1 )
Local aFatCan		:= {}
Local lDocFat		:= .F.
Local aAreaSe2		:= {}
Local nAbat			:= 0
Local lRastro		:= FVerRstFin()
Local lFinVDoc		:= IIF(GetNewPar("MV_FINVDOC","2")=="1",.T.,.F.)//Controle de validacao de documentos obrigatorios
Local nMoedaC 	 	:= Int(Val(GetMv("MV_MCUSTO")))
Local cFilOrig		:= cFilAnt
Local aTitPai		:= {}
Local nI			:= 0
Local nValTit		:= 0
Local lLoja			:= (MV_PAR01 == 1)
Local oModelBxP		:= NIL
Local cLog			:= ""
Local oFKA			:= NIL
Local lExistVA		:= TableInDic("FKD") .and. TableInDic("FKC")
Local nCasDec       := TamSx3("E2_TXMOEDA")[2]
Local nSalDup       := 0
Local nSalDupM      := 0
Local lTela			:= !isblind()
Local _nIVa 		:= 0
Local _nTotSe2 		:= nTitulos
Local lRet			:= .T.
Local lExistFJU		:= FJU->(ColumnPos("FJU_RECPAI")) >0
Local lPadrao		:= .F.
Local cPadrao		:= "593"
Local cChaveVA		:= ""

aAreaSe2			:= SE2->(GetArea())

// Proteção tabela FJU
If FindFunction("FinGrvEx")
	If AliasIndic("FJU")
		If (FieldPos("FJU->FJU_RECPAI")) > 0
			lExistFJU:= .T.
		Else
			lExistFJU:= .F.
		EndIf
	EndIf
EndIf

//Verifica se se o processo será contabilizado              
lPadrao := VerPadrao(cPadrao) .and. mv_par04 == 1

If SE2->(MsSeek(xFilial("SE2")+cPrefCan+cFatCan))
	While !EoF() .And. (SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == xFilial("SE2")+cPrefCan+cFatCan)
		If SE2->(E2_TIPO+E2_FORNECE+E2_LOJA) == (cTipoCan+cFornCan+cLojaCan)
			nAbat := SumAbatPag(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_FORNECE, SE2->E2_MOEDA, "V", SE2->E2_BAIXA, SE2->E2_LOJA)
			Exit
		Endif
		SE2->(dbSkip())
	Enddo
EndIf
SE2->(RestArea(aAreaSe2))
If lFinVDoc
	aFatCan := {}
	dbSelectArea("SE2")
	dbSetOrder(1)//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If MsSeek(xFilial("SE2")+cPrefCan+cFatCan)
		If SE2->E2_TEMDOCS == "1"
			lDocFat := .T.
			While !EoF() .And. (SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cFilAnt+cPrefCan+cFatCan) .And. (SE2->(E2_TIPO+E2_FORNECE+E2_LOJA) == cTipoCan+cFornCan+cLojaCan)
				AADD(aFatCan,{SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA})
				SE2->(dbSkip())
			End
		EndIf
	EndIf
EndI
If lFA290C
	ExecBlock("FA290C",.f.,.f.)
Endif

If lValidCan
	lRet:=ExecBlock("FA290OKC",.F.,.F.)
	If ValType(lRet) # "L"
		lRet:=.T.
	EndIf
EndIf

If lRet
	dbSelectArea("SE2")
	If nAbat > 0
		MsgAlert(STR0048,STR0073)//'Esta fatura possui um abatimento. Favor exclui-lo antes de cancelar a fatura.'
	Endi
	If FA290CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l290CalCn,.T.,lSE2Compart,@cAliasQry,cOrigem,@lBxParcFat) .And. nAbat == 0
		(cAliasQry)->(dbGoTop())
		nValTotal 	:= 0

		Begin Transaction
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1))
			DbSelectArea((cAliasQry))
			
			While !(cAliasQry)->(Eof())
				
				SE2->(dbGoto((cAliasQry)->RECNO))
				cFilOrig := SE2->E2_FILORIG
				
				If	lTela
					If SE2->E2_FATURA <> 'NOTFAT   ' .and. !SE2->E2_TIPO $ MVABATIM
						_nIVa ++	//somente conto NF das faturas originais
						oSay:cCaption := (STR0111 + cValToChar(_nIVa) + STR0107 + cValToChar(_nTotSe2) + STR0108)
						ProcessMessages()
					EndIf
				EndIf
				
				If ( (SE2->(E2_FATURA+E2_TIPOFAT+E2_FORNECE+E2_LOJA) == (cFatCan+cTipoCan+cFornCan+cLojaCan)) .Or.;
					SE2->(E2_FATFOR+E2_FATLOJ) == (cFornCan+cLojaCan) )
					
					cChaveSE2 := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+IIf(lLoja,cFornCan+cLojaCan,E2_FORNECE+E2_LOJA))
					cFilTit   := SE2->E2_FILORIG
					nSalDupM  := 0
					
					dbSelectArea("SE5")
					SE5->(DbSetOrder(7))
					SE5->(dbSeek(xFilial("SE5")+cChaveSE2))
					
					While !SE5->(Eof()) .and. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == cChaveSE2
						If SE5->E5_MOTBX == "FAT" .and. SE5->E5_RECPAG == "P"
							If lBxParcFat .And. Empty(SE2->E2_VALLIQ)
								nValTit := SE5->E5_VALOR
							EndIf
							
							cHist190La := SE5->(E5_CLIFOR+E5_LOJA)
							dBaixa     := SE5->E5_DATA
							
							If !AllTrim(SE5->E5_TIPODOC) $ (MVABATIM + "|CM|DC|VA|D2|J2|TL|MT|M2|C2")
								nSalDupM := SE5->(E5_VALOR+E5_VLDESCO-E5_VLJUROS)
							EndIf
							
							//Verifica movimentacao de AVP
							FAVPValTit("SE2", SE5->(RecNo()))
							
							// Contabiliza o cancelamento da baixa do titulo, somente se o título foi contabilizado anteriormente.
							If lContab531 .And. SE5->E5_LA == "S "
								If nHdlPrv <= 0
									nHdlPrv := HeadProva(cLote,"FINA290",Substr(cUsuario,7,6),@cArquivo)
								Endif
								
								nTotal += DetProva(nHdlPrv,"531","FINA290",cLote)
							Endif
							
							If SE5->E5_TIPODOC $ "VL|BA"
								If AllTrim( SE5->E5_TABORI ) == "FK2"
									oModelBxP := FWLoadModel("FINM020")
									oModelBxP:SetOperation(4)
									oModelBxP:Activate()
									oModelBxP:SetValue( "MASTER", "E5_GRV", .T. )
									oModelBxP:SetValue( "MASTER", "HISTMOV", STR0038) //"Cancelamento de Cheque"
									oModelBxP:SetValue( "MASTER", "E5_OPERACAO", 3 )
									
									//Posiciona a FKA com base no IDORIG da SE5 posicionada
									oFKA := oModelBxP:GetModel( "FKADETAIL" )
									oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
									
									If oModelBxP:VldData()
										oModelBxP:CommitData()
									Else
										lRet := .F.
										cLog := cValToChar(oModelBxP:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
										cLog += cValToChar(oModelBxP:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
										cLog += cValToChar(oModelBxP:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
										Help( ,,"M020VALID",,cLog, 1, 0 )
									Endif
									
									If Valtype(oModelBxP) = "O"
										oModelBxP:DeActivate()
										oModelBxP:Destroy()
										oModelBxP:= nil
									EndIf
								EndIf
							else
								//Cancelo os registros de valores acessoriso (Multas, Juros etc)
								If SE5->E5_TIPODOC == "VA" //Valores Acessórios								
									cChaveVA := SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ)
									SE5->(dbSetOrder(2))
									While !SE5->(EOF()) .and. cChaveVA == SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ)
										RecLock("SE5")
										dbDelete()
										MSUnlock()
										SE5->(Dbskip())
									EndDo										
									SE5->(Dbskip(-1))		
								Else
									RecLock("SE5")
									dbDelete()
									MsUnLock()
								Endif								
							endIf
						EndIf
						
						SE5->(dbSkip())
					EndDo
					
					//Se for um titulo que gerou a fatura, desfaz o processo volto o saldo da natureza
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALLIQ, xMoeda(SE2->E2_VALLIQ, SE2->E2_MOEDA, 1),If(SE2->E2_TIPO$MVABATIM,"-","+"),,FunName(),"SE2",SE2->(Recno()),nOpcE)
					dbSelectArea("SE2")
					
					If lAbatiment .And. !SE2->E2_TIPO $ MV_CPNEG +"/"+ MVABATIM
						nTotAbat := SumAbatPag(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_FORNECE, SE2->E2_MOEDA, "V", SE2->E2_BAIXA, SE2->E2_LOJA,,,,,SE2->E2_TIPO)
					Else
						nTotAbat := 0
					EndIf
					
					RecLock("SE2")
					SE2->E2_SALDO	+= (If(lBxParcFat .And. nValTit > 0, nValTit, E2_VALLIQ)+nTotAbat) - E2_JUROS + E2_DESCONT
					SE2->E2_MOVIMEN	:= dDataBase
					SE2->E2_FATURA	:= " "
					SE2->E2_FATPREF	:= " "
					SE2->E2_TIPOFAT	:= " "
					SE2->E2_FATFOR	:= " "
					SE2->E2_FATLOJ	:= " "
					SE2->E2_DTFATUR	:= CtoD("  /  /  ")
					SE2->E2_JUROS	:= 0
					SE2->E2_DESCONT	:= 0
					SE2->E2_VALLIQ	:= 0
					SE2->E2_CORREC 	:= 0
					If SE2->E2_SALDO == SE2->E2_VALOR
						SE2->E2_BAIXA	:= CtoD("  /  /  ")
						SE2->E2_SDDECRE := SE2->E2_DECRESC
						SE2->E2_SDACRES := SE2->E2_ACRESC
					Else
						If SE2->E2_SDACRES > 0
							SE2->E2_SDACRES += SE5->E5_VLACRES
						EndIf
						
						If SE2->E2_SDDECRE > 0
							SE2->E2_SDDECRE += SE5->E5_VLDECRE 
						EndIf
					Endi
					SE2->E2_FLAGFAT	:= Space(Len(SE2->E2_FLAGFAT))
					SE2->(MsUnlock())
					//adiciona no array os titulos pai
					If lExistFJU
						aAdd(aTitPai,{SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->(Recno())})
					EndI
					//VALORES ACESSÓRIOS
					If lPodeTVA .and. lExistVA
						FAtuFKDBx(.T., "P")
					Endif
					
					If nSalDupM > 0 .And. SA2->(MsSeek(xFilial("SA2", cFilOrig) + SE2->(E2_FORNECE+E2_LOJA)))
						nSalDup  := Round(xMoeda(nSalDupM, SE2->E2_MOEDA, 1, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA, 0), 2)
						nSalDupM := Round(xMoeda(nSalDupM, SE2->E2_MOEDA, nMoedaC, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA), 2) 
						
						SA2->(RecLock("SA2"))								
						If SE2->E2_TIPO $ (MVPAGANT+"|"+MV_CPNEG)
							SA2->A2_SALDUP  -= nSalDup 
							SA2->A2_SALDUPM -= nSalDupM
						Else
							SA2->A2_SALDUP  += nSalDup 
							SA2->A2_SALDUPM += nSalDupM
						EndIf
						SA2->(MsUnlock())
					EndIf
				Else
					If lPadrao
						If nHdlPrv <= 0
							nHdlPrv:=HeadProva(cLote,"FINA290",Substr(cUsuario,7,6),@cArquivo)
						Endif
						
						nTotal += DetProva(nHdlPrv,cPadrao,"FINA290",cLote)
					Endif
					
					DbSelectArea("SE2")
					SE2->(dbGoto((cAliasQry)->RECNO))
					nValTotal += SE2->E2_VLCRUZ
					
					//Ponto de entrada para tratamento especifico de dados do titulo a ser deletado
					IF lF290CN2
						ExecBlock("F290CN2",.F.,.F.)
					Endif
					
					If SE2->E2_VALOR > 0 .And. SA2->(MsSeek(xFilial("SA2", cFilOrig) + SE2->(E2_FORNECE+E2_LOJA)))
						nSalDup  := Round(xMoeda(SE2->E2_VALOR, SE2->E2_MOEDA, 1, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA, 0), 2)
						nSalDupM := Round(xMoeda(SE2->E2_VALOR, SE2->E2_MOEDA, nMoedaC, SE2->E2_EMISSAO, nCasDec, SE2->E2_TXMOEDA), 2)
						
						SA2->(RecLock("SA2"))								
						If SE2->E2_TIPO $ (MVPAGANT+"|"+MV_CPNEG+"|"+MVABATIM)
							SA2->A2_SALDUP  += nSalDup 
							SA2->A2_SALDUPM += nSalDupM
						Else
							SA2->A2_SALDUP  -= nSalDup 
							SA2->A2_SALDUPM -= nSalDupM
						EndIf
						SA2->(MsUnlock())
					EndIf							
					
					//Volto o saldo da natureza
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ,If(SE2->E2_TIPO$MVABATIM,"+","-"),,FunName(),"SE2",SE2->(Recno()),nOpcE)
					FINDELFKs(xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA, "SE2")
					If lExistFJU
						For ni := 1 to Len(aTitPai)
							FinGrvEx("P",aTitPai[nI][1], aTitPai[nI][2],aTitPai[nI][3],aTitPai[nI][4],aTitPai[nI][5],aTitPai[nI][6],aTitPai[nI][7],aTitPai[nI][8])
						Next ni
					Endif

					// Limpa chaves de relacionamento com as baixas.
					FA290Bxs()

					RecLock("SE2",.F.,.T.)
					SE2->(dbDelete())
					SE2->(MsUnlock())
				Endif
				
				//Este PE serve para grava‡äes complementares ap¢s cancelamento do titulo na fatura.                                          
				IF lF290CAN
					ExecBlock("F290CAN",.F.,.F.)
				Endif

				(cAliasQry)->(dbSkip())
				
				//Cancelamento do rastreamento(FI7/FI8)
				If lRastro
					FINRSTDEL("SE2",cChaveSe2,,,cFilTit)
				Endif
				
				nValTit := 0 

			Enddo
		End Transaction
		
		//Apaga o registro da fatura na tabela FRD
		IF lDocFat .And. lFinVDoc
			CN062ApagDocs(aFatCan)
		EndI
		If nTotal > 0
			dbSelectArea("SE2")
			nRecSe2 := Recno()
			SE2->(DBGoBottom())
			SE2->(dbSkip())
			SE5->(DBGoBottom())
			SE5->(dbSkip())
			VALOR := nValTotal
			nTotal+=DetProva(nHdlPrv,cPadrao,"FINA290",cLote)
			RodaProva(nHdlPrv,nTotal)
			lDigita:=IIF(mv_par02==1,.T.,.F.)
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.)
			VALOR := 0
			dbSelectArea("SE2")
			SE2->(DBGoTo(nRecSe2))
		Endif
	EndIf
Endif

Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} FA290Bxs
Limpa chaves de relacionamento.

@author Fabio Zanchim
@version P12
@since	28/06/2022
/*/
//-------------------------------------------------------------------
Static Function FA290Bxs()

Local aArea 	As Array
Local nAtuRec	As Numeric
Local nProxRec	As Numeric
Local cChaveSE2 As Character

aArea 		:= SE2->(GetArea())
cChaveSE2 	:= SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
					
	dbSelectArea("FK2")
    dbSetOrder(1)//FK2_FILIAL+FK2_IDFK2
	dbSelectArea("SE5")
	dbSetOrder(7)
	SE5->(dbSeek(xFilial("SE5")+cChaveSE2))
	While !SE5->(Eof()) .And.  SE5->E5_FILIAL==xFilial("SE5") .And. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == cChaveSE2 		
		// Guarda posição, pois a modificação dos campos da SE5 reindexa os registros
		nAtuRec := SE5->(Recno())
        SE5->(dbSkip())
        nProxRec := SE5->(Recno())
        SE5->(dbGoto(nAtuRec))

        If SE5->E5_TABORI== "FK2" .AND. FK2->(dbSeek( xFilial("FK2") + SE5->E5_IDORIG ))
			RecLock('FK2',.F.)
			FK2->FK2_LA := 'S'
			FK2->(msUnLock())

			RecLock('SE5',.F.)
			SE5->E5_KEY		:= SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
			SE5->E5_PREFIXO	:= ''
			SE5->E5_NUMERO	:= ''
			SE5->E5_PARCELA	:= ''
			SE5->E5_TIPO	:= ''
			SE5->E5_LA		:= 'S'
			SE5->(msUnLock())
		EndIF
		SE5->(dbGoto(nProxRec))
	EndDo

RestArea(aArea)
FWFreeArray(aArea)
Return


/*/{Protheus.doc} FixNoFI8
	@description
	Erro que existia: em títulos de moeda diferente de 1, se o usuário não informasse nenhuma taxa de moeda
	e a moeda não tivesse taxa cadastrada na SM2, o título gerado em moeda estrangeira ficava com E2_VLCRUZ = 0 e 
	não era gravado nada na FI8.
	Sem FI8, não era possível fazer o estorno porque a função FA290FCAN não retorna nenhum dado.
	A função FIXNoFI8 foi criada para que o usuário consiga realizar o estorno em títulos gerados nessas condições,
	inclusive sem registros na tabela FI8.
	@Type 		Static Function	
	@author 	guilherme.sordi@totvs.com.br
	@version 	12.1.2210
	@Param 		cAliasQry, String, Alias que será analisado posteriormente
	@since		14/09/2022
/*/
Static Function FixNoFI8(cAliasQry as Character) As Variant
	Local cQuery 	As Character
	Local cAlias	As Character

	cQuery := cAlias := ""

	If __oStFix1 == NIL
		cQuery := "SELECT E2_MOEDA, E2_VLCRUZ "
		cQuery += "FROM " + RetSQLName("SE2") + " SE2 "
		cQuery += "WHERE E2_FILIAL = ? "
		cQuery += "AND E2_PREFIXO = ? "
		cQuery += "AND E2_NUM = ? "
		cQuery += "AND E2_TIPO = ? "
		cQuery += "AND E2_FORNECE = ? "
		cQuery += "AND E2_LOJA = ? "
		cQuery += "AND E2_FATURA = 'NOTFAT' "
		cQuery += "AND D_E_L_E_T_ = ' ' "		
		
		cQuery := ChangeQuery(cQuery)
		__oStFix1 := if( __lExecSt, FWExecStatement():New(cQuery), FWPreparedStatement():New(cQuery) )
	EndIf

	__oStFix1:SetString(1, FWxFilial("SE2"))
	__oStFix1:SetString(2, cPrefCan)
	__oStFix1:SetString(3, cFatCan)
	__oStFix1:SetString(4, cTipoCan)
	__oStFix1:SetString(5, cFornCan)
	__oStFix1:SetString(6, cLojaCan)
		
	cAlias := if ( __lExecSt, __oStFix1:OpenAlias(), MPSysOpenQuery(__oStFix1:getFixQuery()) )

	If (cAlias)->(EOF())
		Return NIL
	EndIf

	If (cAlias)->E2_MOEDA == 1 .or. (cAlias)->E2_VLCRUZ > 0 
		Return NIL
	EndIf


	If __oStFix2 == NIL
		//Títulos gerados
		cQuery := "SELECT DISTINCT SE2.R_E_C_N_O_ RECNO "
		cQuery += "FROM " + RetSQLName("SE2") + " SE2 "
		cQuery += "WHERE E2_FILIAL = ? "
		cQuery += "AND E2_PREFIXO = ? "
		cQuery += "AND E2_NUM = ? "
		cQuery += "AND E2_TIPO = ? "
		cQuery += "AND E2_FORNECE = ? "
		cQuery += "AND E2_LOJA = ? "
		cQuery += "AND E2_FATURA = 'NOTFAT' "
		cQuery += "AND SE2.D_E_L_E_T_ = ' ' "		

		cQuery += "UNION "

		//Títulos baixados
		cQuery += "SELECT DISTINCT SE2.R_E_C_N_O_ RECNO "
		cQuery += "FROM  " + RetSQLName("SE2") + " SE2 "

		cQuery += "JOIN  " + RetSQLName("FK7") + " FK7 "
		cQuery += "ON E2_FILIAL = FK7_FILTIT "
		cQuery += "AND E2_PREFIXO = FK7_PREFIX "
		cQuery += "AND E2_NUM = FK7_NUM "
		cQuery += "AND E2_PARCELA = FK7_PARCEL "
		cQuery += "AND E2_TIPO = FK7_TIPO "
		cQuery += "AND E2_FORNECE = FK7_CLIFOR "
		cQuery += "AND E2_LOJA = FK7_LOJA "
		cQuery += "AND FK7.D_E_L_E_T_ = ' ' "	

		cQuery += "JOIN  " + RetSQLName("FK2") + " FK2 "
		cQuery += "ON FK7_IDDOC = FK2_IDDOC "
		cQuery += "AND FK2_FILIAL = ? "
		cQuery += "AND FK2_MOTBX = 'FAT' "
		cQuery += "AND FK2.D_E_L_E_T_ = ' ' "	

		cQuery += "WHERE E2_FATPREF = ? "
		cQuery += "AND E2_FATURA = ? "
		cQuery += "AND E2_TIPOFAT = ? "
		cQuery += "AND E2_FORNECE = ? "
		cQuery += "AND E2_LOJA = ? "
		cQuery += "AND E2_DTFATUR <> '        ' "
		cQuery += "AND E2_FLAGFAT = 'S' "
		cQuery += "AND SE2.D_E_L_E_T_ = ' ' "	
		
		cQuery := ChangeQuery(cQuery)
		__oStFix2 := if( __lExecSt, FWExecStatement():New(cQuery), FWPreparedStatement():New(cQuery) )
	EndIf

	__oStFix2:SetString(1, FWxFilial("SE2"))
	__oStFix2:SetString(2, cPrefCan)
	__oStFix2:SetString(3, cFatCan)
	__oStFix2:SetString(4, cTipoCan)
	__oStFix2:SetString(5, cFornCan)
	__oStFix2:SetString(6, cLojaCan)

	__oStFix2:SetString(7, FWxFilial("FK2"))
	__oStFix2:SetString(8, cPrefCan)
	__oStFix2:SetString(9, cFatCan)
	__oStFix2:SetString(10, cTipoCan)
	__oStFix2:SetString(11, cFornCan)
	__oStFix2:SetString(12, cLojaCan)

	cAliasQry := if ( __lExecSt, __oStFix2:OpenAlias(), MPSysOpenQuery(__oStFix2:getFixQuery()) )

Return NIL
