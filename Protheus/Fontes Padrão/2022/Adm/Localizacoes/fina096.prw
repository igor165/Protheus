#INCLUDE "rwmake.ch"
#INCLUDE "FINA096.CH"
#INCLUDE "PROTHEUS.CH"

Static lFWCodFil := .T.
STATIC lMod2	 := .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ FINA096	³ Autor ³ Wagner Montenegro		³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Controle de Cheques Recebidos.							   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum													   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±³Luis Enríquez 30/12/2016 SERINN001-484 Se realizó merge para agregar    ³±
±±³                                       cambio de ctree para generar ta- ³±
±±³                                       blas temp. utilizando la clase   ³±
±±³                                       FWTemporaryTable.                ³±
±±³Dora Vega     ³03/05/17|MMI-42  ³Merge de replica del llamado TVWGBT.Se ³±
±±³              ³        |        ³visualiza asientos contables de liqui- ³±
±±³              ³        |        ³dacion de cheques para borderos.(ARG)  ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA096()
	Local aCores    := {}

	Private xObrw
	Private cCadastro := STR0001 //"Controle de Cheques Recebidos"
	Private lInverte:=.F.
	Private lGeraLanc:=.T.
	Private aIndex		:= {}
	Private bFiltraBrw := {|| FilBrowse("SEF",@aIndex,@cCondicao)}
	Private dIniDt380:= dDataBase
	Private dFimDt380:= dDataBase
	Private lIndice12 := .F.
	Private lCtrlCheq :=.T.
	Private cArquivo   := ""
	Private nHdlPrv    := 0
	Private nTotalLanc := 0
	Private cLoteCom   := ""
	Private nLinha     := 0
	Private lCancel    := .F.

	Private cBco380	   := Criavar("EF_BANCO")
	Private cAge380	   := Criavar("EF_AGENCIA")
	Private cCta380	   := Criavar("EF_CONTA")
	Private cCheq380   := Criavar("EF_NUM")
	Private cBcoDe 	   := cBco380   // Variavel Usada em A089Recibe (FINA089)
	Private cBcoAte	   := cBco380   // Variavel Usada em A089Recibe (FINA089)
	Private dDataDe    := dIniDt380 // Variavel Usada em A089Recibe (FINA089)
	Private dDataAte   := dFimDt380 // Variavel Usada em A089Recibe (FINA089)
	Private cBord380	:= Criavar("E1_NUMBOR",.F.)

	//--- Variaveis Relativas ao Banco de Terceiros (Junho/2012)
	Private cBcoChq	   := Criavar("EF_BANCO")
	Private cAgeChq	   := Criavar("EF_AGENCIA")
	Private cCtaChq	   := Criavar("EF_CONTA")
	Private cPostal    := Space( 4 )

	//--- Para uso de A089Recibe (FINA089)
	Private cBcoFJN    := cBcoChq
	Private cAgeFJN    := cAgeChq
	Private cPosFJN    := cPostal

	Private lDigita    := .F.
	Private lAglutina  := .F.
	Private cIndex     := ""
	Private cTxtInd    := ""
	Private cKey       := ""
	Private nIndex     := 1
	Private _sAlias    := ""
	Private cPerg      := "FIN096"
	Private aRegs      := {}
	Private nA         := 0
	Private nB         := 0
	Private cKeyBusca  := ""
	Private lQuery	   := .F.
	Private nValorSe1  := 0
	Private cAliasTmp  := ""
	Private aDiario	   := {}
	Private cCodDiario := ""
	Private aFlagCTB   := {}
	Private lUsaFlag   := SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
	Private cFilter		:= ""
	Private cCondicao  	:= "" 
Private lExecute	:= .T.
	Private oTmpTable := Nil
	Private aIndx := {}	

	#IFDEF TOP
		cFilter := "EF_FILIAL = '"+xFilial('SEF')+"' AND EF_CART = 'R' "
	#ELSE
		cCondicao := "EF_FILIAL=='"+xFilial('SEF')+"' .AND. EF_CART=='R' "
	#ENDIF

	cCondicao := "EF_FILIAL == '"+xFilial('SEF')+"' .AND. EF_CART == 'R' "

	Private lFa380		:= ExistBlock("F380RECO",.F.,.F.)

	Private aCampos	:= CamposDef( "1" ) 

	Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private aRotina 	:= MenuDef()
	Private aDados040	:={}
	Private aDados050	:={}  
	Private cChvLbx	:=	""

	/*
	* Verificação do processo que está configurado para ser utilizado no Módulo Financeiro (Argentina)
	*/
	If lMod2
		If !FinModProc()
			Return()
		EndIf
	EndIf
	If cPaisLoc == "ARG"
		A096PERG()
	EndIf

	#IFDEF TOP
	
		If cPaisLoc == "ARG"
			SetKey(VK_F12,{||A096PERG()})
			PERGUNTE("FIN096",.F.)
			lDigita:= Iif(MV_PAR01 == 1, .T.,.F.)
			lGeraLanc:= Iif(MV_PAR02 == 1, .T.,.F.)
		EndIF
		
		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias("SEF")
		oBrowse:SetFilterDefault(cCondicao)
	
		oBrowse:AddLegend('EF_STATUS == "01" .AND. EMPTY(EF_RECONC)','BR_AZUL'		,STR0016) //"Em Carteira"		
		oBrowse:AddLegend('EF_STATUS == "04" .AND. EMPTY(EF_RECONC)','BR_VERDE'		,STR0019) //"Liquidado"
		oBrowse:AddLegend('EF_STATUS == "05" .AND. EMPTY(EF_RECONC)','BR_PRETO'		,STR0020) //"Anulado"		
		oBrowse:AddLegend('EF_STATUS == "06" .AND. EMPTY(EF_RECONC)','BR_CINZA'		,STR0021) //"Substituído"
		oBrowse:AddLegend('EF_STATUS == "07" .AND. EMPTY(EF_RECONC)','BR_VERMELHO'	,STR0022) //"Devolvido"		
		oBrowse:AddLegend('EF_STATUS == "08" .AND. EMPTY(EF_RECONC)','BR_VIOLETA'	,STR0023) //"Protestado"		
		oBrowse:AddLegend('EF_STATUS == "09" .AND. EMPTY(EF_RECONC)','BR_BRANCO'	,STR0116) //"Compensado"	
		oBrowse:AddLegend('EF_RECONC == "x"'						,'LIGHTBLU'		,STR0024) //"Conciliado"	
	
		oBrowse:Activate()
	#ELSE
		EndFilBrw("SEF",@aIndex)
		bFiltraBrw:= { || FilBrowse("SEF",@aIndex,@cCondicao,.T.) }
		Eval( bFiltraBrw )
	#ENDIF

	SEF->(dbSetOrder(8))
	cCadastro := STR0014 //"Recebimento Bancario"
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096Comp³ Autor ³ Wagner Montenegro		³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Compensar Cheque recebido, executandi a função A089Recibe   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096Comp(cAlias, nRec, nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096Comp(cAlias,nReg,nOpcx,lAutomato)
	Local lRet		:= .T.
	Local aAreaSEF	:= SEF->(GetArea())

	Private nModo	:= 1
	Default lAutomato 	:= .F.

	If !fA096SITE1(xFilial('SEF')+PadR(AllTrim(EF_PORTADO),TamSX3("E1_PORTADO")[1])+PadR(AllTrim(EF_EMITENT),TamSX3("E1_NOMCLI")[1])+PadR(AllTrim(EF_PREFIXO),TamSX3("E1_PREFIXO")[1])+PadR(AllTrim(EF_NUM),TamSX3("E1_NUM")[1])+PadR(AllTrim(EF_TIPO),TamSX3("E1_TIPO")[1]))
		Help( ,,"fA096Comp",,STR0126, 1, 0 )//"O cheque se enconta en carteira e não compoe um bordero portanto não pode ser liquidado."
		Return
	Endif 	

	If lAutomato
	   lExecute:= .T.
	Endif

	If !lExecute
		lExecute:= .T.
		MsgStop(STR0128)
		Return
	EndIf 
	
	If !FA096Bco(.T.,,lAutomato)
		Return
	EndIf

	lRet := A089Recibe(lAutomato)
	lExecute:= .T.

	If !lAutomato
		#IFNDEF TOP
			EndFilBrw("SEF",@aIndex)
			bFiltraBrw := { || FilBrowse("SEF",@aIndex,@cCondicao,.T.) }
			Eval( bFiltraBrw ) 
		#ELSE
			oBrowse:DeleteFilter("fA096Bco")
		#ENDIF
	EndIf
	RestArea(aAreaSEF)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096Anula ³ Autor ³ Wagner Montenegro	 ³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Anular cheque recebido, executando a função A089Cancel.	   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096Anula(cAlias, nRec, nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096Anula(cAlias,nReg,nOpcx)

Local lRet			:= .T.
Local aRegs		:= {}
Local aAreaSEF 	:= SEF->(GetArea())
Local cCondAux	:= cCondicao

Private nModo 	:= 2

aDados040 :={}
aDados050 :={}

cChvLbx := ""

	//Controle de Conciliação Bancária
If cPaisLoc $ "ARG"
	If !(SEF->EF_RECONC == "x")
		aAdd(aRegs,{SEF->EF_PREFIXO,SEF->EF_NUM,SEF->EF_PARCELA,SEF->EF_TIPO,SEF->EF_CLIENTE,SEF->EF_LOJACLI,SEF->EF_BANCO,SEF->EF_AGENCIA,SEF->EF_CONTA})
		If F472VldConc(aRegs) 
			Help( ,,"fA096Anula1",,STR0076, 1, 0 )//"Este cheque já foi conciliado e não pode ser anulado!"
			lRet := .F.
		EndIf
	EndIf	
ElseIf SEF->EF_RECONC == "x"
		Help( ,,"fA096Anula1",,STR0076, 1, 0 )//"Este cheque já foi conciliado e não pode ser anulado!"
		lRet := .F.	
EndIf

If lRet
	If !lExecute
		MsgStop(STR0128)
		Return
	EndIf
	If !FA096Bco(.T.)
		Return
	EndIf
	lRet := A089Cancel(cAlias,nReg,nOpcx,lCtrlCheq)
	cCondicao := cCondAux
	oBrowse:DeleteFilter("fA096Bco")
	lExecute:= .T.
EndIf


	RestArea(aAreaSEF)

	// Set Filter to &cFilterSEF //aplica o filtro novamente

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096Fluxo³ Autor ³ Wagner Montenegro	³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consultar Fluxo de Caixa.								   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096Fluxo(cAlias, nRec, nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096Fluxo(cAlias,nReg,nOpcx)
	Local lRet		:= .T. 
	Local aAreaSEF	:= SEF->(GetArea()) 

	lRet := FINC021()

	RestArea(aAreaSEF)

	#IFNDEF TOP
		EndFilBrw("SEF",aIndex)
		Eval( bFiltraBrw )
	#ELSE
		oBrowse:DeleteFilter("fA096Bco")
	#ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096Legen³ Autor ³ Wagner Montenegro	³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Exibe a legenda do Controle de Cheques.					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ fA096Legen()												   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096Legen(cAlias, nReg)
	Local aLegenda	:= {}

	aLegenda:= 		{{"BR_AZUL"		,STR0016},;	//01 //"Em Carteira"
	{"BR_VERDE"	,STR0019},;	//04 //"Liquidado"
	{"BR_PRETO"	,STR0020},;	//05 //"Anulado"
	{"BR_CINZA"	,STR0021},;	//06 //"Substituído"
	{"BR_VERMELHO"	,STR0022},;	//07 //"Devolvido"
	{"BR_VIOLETA"	,STR0023},;	//08 //"Protestado"
	{"BR_BRANCO"	,STR0116},;	//09 //"Compensado" 
	{"LIGHTBLU"	,STR0024}}	//10 //"Conciliado"

	BrwLegenda(STR0025,STR0026,aLegenda) //"Controle de Cheques", "Legenda"  
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096Prote ³ Autor ³ Wagner Montenegro    ³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Cadastro de Contratos de Protesto de Cheques				   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096Prote(cAlias, nRec, nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096Prote(cAlias,nReg,nOpcx)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis 														  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nOpca 	 := 0
	LOCAL cIndex	 := ""
	LOCAL aStruct	 := {}
	LOCAL dDTLimRec  := GetMV("MV_DATAREC")
	Local lF380Grv	 := ExistBlock("F380GRV",.F.,.F.)
	LOCAL aMkBCampos := {}
	LOCAL oDlg
	LOCAL oQtdaP
	LOCAL oQtdaR
	LOCAL oValRec
	LOCAL oValPag
LOCAL oValIni, oValAtu, oValRecT, oValGer
	LOCAL oMark
	LOCAL lInverte  := .f.
Local lAtuSaldo := .F.
Local lAtSalRec1 := .F.
Local lAtSalRec2 := .F.
Local nReconc := 0
Local cReconAnt := ""
	Local aSize := {}
	Local oPanel
	Local cKeyCheque := ""
Local lAltDt := .T.
	Local aButtons := {}
Local lSaldoAtu := .F.
	Local aArea
	Local nLinha
	Local nSize
	Local aColuna
	Local cQuery :=""
	Local aAreaSEF			:=	SEF->(GetArea())
	Local aStruTRB			:=	{}
	Local nX				:=	0
	Local lCtrlCheq			:=	.F.
	Local cItem				:=	""
	Local cFiltroSEF		:= ""
Local cCampoData		:= ""

	Private cCartorio		:=	Criavar("FRG_FORNEC")
	Private cLoja			:=	Criavar("FRG_LOJA")
	Private cContrato		:=	Criavar("FRG_CONTRA")
	Private cLoteTit		:=	Criavar("FRG_LOTE")
	Private dDataIni		:=	dDataBase
	Private dDataFin		:=	dDataBase
	Private nItem			:=	Criavar("FRG_ITEM")
	Private nQuantidade	:=	0
	Private cNomeA2		:=	""
	PRIVATE cIndexSEF		:= ""
	PRIVATE cMarca			:= GetMark()
	Private oQuantidade

If !lExecute
	MsgStop(STR0128)
	Return
EndIf
FA096Bco(.T.)
lExecute:= .T.
	aMkBCampos := CamposDef( "2" ) // Campos da Mark Browse

	// Permite a altera‡Æo da ordem em que os campos serÆo apresentados.
	If ExistBlock("F096CPOS")
		aMkBCampos := ExecBlock("F096CPOS", .F., .F., { aMkBCampos } )
	Endif

	If Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	While .T.
		nQtdTitP	:= 0
		nQtdTitR	:= 0
		nValRec		:= 0
		nValPag		:= 0
		nValRecT	:= 0
		nValPagT	:= 0
		nOpca		:= 3

		aSize := MSADVSIZE()
		nEspLarg := 0
		nEspLin  := 0

		dbSelectArea("SEF")
		aStruct := dbStruct()

		AAdd( aStruct, {"EF_RECNO"	,"N", 09, 0} )
		AAdd( aStruct, {"E1_MOEDA"	,"N", 02, 0} )
		AAdd( aStruct, {"E1_TXMOEDA","N", 11, 4} )

		//Creacion de Objeto 
		oTmpTable := FWTemporaryTable():New("TRB") //leem
		oTmpTable:SetFields( aStruct ) //leem

		aIndx	:=	{"EF_VENCTO","EF_BANCO","EF_AGENCIA","EF_CONTA","EF_NUM"} //leem

		oTmpTable:AddIndex("IN1", aIndx) //leem

		oTmpTable:Create() //leem

		#IFDEF TOP
			cQuery	:= "SELECT EF_OK,EF_BANCO,EF_AGENCIA,EF_CONTA,EF_PREFIXO,EF_NUM,"
			cQuery	+= "EF_VENCTO,EF_VALOR,EF_STATUS,EF_DATA,EF_TITULO,EF_PARCELA,EF_CLIENTE,EF_LOJACLI,"
			cQuery	+= "EF_EMITENT,EF_CPFCNPJ,EF_FILIAL,EF_TIPO,E1_MOEDA,E1_TXMOEDA "
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Expressao de Filtro para Entidades Bancarias - Junho de 2012 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "ARG"
	
				cQuery	+= ",EF_POSTAL "
	
			EndIf
	
			cQuery	+= "FROM " + RETSQLNAME("SEF") + " SEF, " + RETSQLNAME("SE1") + " SE1 "
			cQuery	+= "WHERE SEF.EF_FILIAL = '" + xFILIAL("SEF") + "' AND "
			cQuery	+= "SEF.EF_BANCO = SE1.E1_BCOCHQ AND "
			cQuery	+= "SEF.EF_AGENCIA = SE1.E1_AGECHQ AND "
			cQuery	+= "SEF.EF_CONTA = SE1.E1_CTACHQ AND "
			cQuery	+= "SEF.EF_PREFIXO = SE1.E1_PREFIXO AND "
			cQuery	+= "SEF.EF_NUM = SE1.E1_NUM AND "
	
			If !Empty( cBco380+cAge380+cCta380 )
	
				cQuery	+= "SE1.E1_PORTADO = '" + cBco380 + "' AND "
				cQuery	+= "SE1.E1_AGEDEP = '" + cAge380 + "' AND "
				cQuery	+= "SE1.E1_CONTA = '" + cCta380 + "' AND "
	
			EndIf
			If !Empty(cBord380)
				cQuery	+= "SE1.E1_NUMBOR = '" + cBord380+ "' AND "
			EndIf
			If ( cPaisLoc $ "EQU|DOM|ARG" ) .And. FUNNAME() == "FINA096"
	
				cQuery += "SEF.EF_DATA BETWEEN '" + DTOS( dIniDt380 ) + "' AND '" + DTOS( dFimDt380 ) + "' AND "
	
			Else
	
				cQuery += "SEF.EF_VENCTO BETWEEN '" + DTOS( dIniDt380 ) + "' AND '" + DTOS( dFimDt380 ) + "' AND "
	
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Expressao de Filtro para Entidades Bancarias - Junho de 2012 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( cBcoChq )
				If cPaisLoc == "ARG"
					If !Empty( cPostal )
						cQuery += "SEF.EF_POSTAL ='" + cPostal + "' AND "
					EndIf
				Endif
			Else
				cQuery += "SEF.EF_BANCO ='" + cBcoChq + "' AND "
				cQuery += "SEF.EF_AGENCIA ='" + cAgeChq + "' AND "
			EndIf
	
			//ÚÄÄÄÄÄ¿
			//³ FIM ³
			//ÀÄÄÄÄÄÙ
	
			cQuery += "SEF.EF_STATUS IN ('05','07') AND "
	
			cQuery += "SEF.D_E_L_E_T_ = '' AND SE1.D_E_L_E_T_ = '' "
	
			cQuery += "ORDER BY EF_VENCTO,EF_BANCO,EF_AGENCIA,EF_CONTA,EF_NUM"
	
			cQuery 	:= ChangeQuery(cQuery)
		#ELSE
			cQuery	:=	SEF->EF_FILIAL==xFILIAL("SEF") .AND. SEF->EF_BANCO==E1_BCOCHQ .AND. SEF->EF_AGENCIA==SE1->E1_AGECHQ .AND. SEF->EF_CONTA==SE1->E1_CTACHQ .AND. SEF->EF_PREFIXO==SE1->E1_PREFIXO .AND. SEF->EF_NUM==SE1->E1_NUM .AND. ;
			SE1->E1_PORTADO==cBco380 .AND. SE1->E1_AGEDEP==cAge380 .AND. SE1->E1_CONTA==cCta380 .AND. SEF->EF_VENCTO >= DTOS(dIniDt380) .AND. SEF->EF_VENCTO <= DTOS(dFimDt380) .AND. SEF->EF_STATUS $ "05/07" .AND. (Empty(cBord380) .Or. SE1->E1_NUMBOR == cBord380)
		#ENDIF

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPTRB", .F., .T.)
		DbSelectArea("TMPTRB")
		aStruTRB := dbStruct()

		TMPTRB->(DbGoTop())

		If TMPTRB->(EOF()) .and. TMPTRB->(BOF())
			Help(" ",1,"RECNO")
			Exit
		ENDIF

		While !TMPTRB->(EOF())
			If TRB->(RecLock("TRB",.T.))
				For nX := 1 to Len( aStruTRB )
					cCampo    := aStruTRB[ nX, 1 ]
					xConteudo := TMPTRB->( FieldGet( FieldPos( cCampo ) ) )
					nPosCampo := TRB->( FieldPos( cCampo ) )
					If nPosCampo > 0
						If TamSX3(cCampo)[3]=="D"
							xConteudo := StoD( xConteudo )
						EndIf
						TRB->( FieldPut( nPosCampo, xConteudo ) )
					EndIf
				Next nX
				TRB->EF_OK := cMarca
				nQuantidade++
				TRB->(MsUnlock())
			Endif
			TMPTRB->(DbSkip())
		Enddo

		dbGoTop()

		While !TRB->(EOF())
			TRB->EF_OK := cMarca
			TRB->(DbSkip())
		Enddo

		TRB->(DbGoTop())

		Fa096ChecF(lCtrlCheq)

		IF BOF() .and. EOF()
			Help(" ",1,"RECNO")
			Exit
		Endif

		nOpca := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MSADVSIZE()

		DEFINE MSDIALOG oDlg TITLE STR0044 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL  //"Seleção de Títulos para Protesto"
		oDlg:lMaximized := .T.

		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,40, 50,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		nLinha := 3

		nSize := 90
		aColuna:={005,,,}
		aColuna[2]:=aColuna[1]+nSize+5
		aColuna[3]:=aColuna[2]+70
		aColuna[4]:=aColuna[3]+nSize+5

		@nLinha,005 	Say STR0045	SIZE 30, 07 OF oPanel PIXEL //"Cartório: "
		@nLinha,045		MSGET cCartorio	F3 "SA2" Picture "@!"	Valid lCkCart() 	SIZE 40, 08 OF oPanel Hasbutton PIXEL
		@nLinha,085		MSGET cLoja						Picture "@!" 	Valid lCkCart(1)	SIZE 15, 08 OF oPanel Hasbutton PIXEL
		@nLinha,145 	Say cNomeA2 		SIZE 90, 07 OF oPanel PIXEL
		nLinha += 12
		@nLinha,005		Say STR0046 	SIZE 30, 07 OF oPanel PIXEL //"Contrato: "
		@nLinha,045		MSGET cContrato	Picture "@!"	Valid If(Empty(cContrato),Eval({|| Help('',1,'CONTNINF',,STR0047,1,0),.F.}),.T.)  SIZE 17, 08 OF oPanel Hasbutton PIXEL	//"Informe o Contrato!"
		@nLinha,110 	Say STR0052		SIZE 30, 07 OF oPanel PIXEL	//"Data Inicial: "
		@nLinha,215 	Say STR0053		SIZE 30, 07 OF oPanel PIXEL	//"Data Final: "
		@nLinha,145		MSGET dDataIni		Picture "@D"	Valid If( Empty(dDataIni),Eval({|| Help('',1,'',,STR0048,1,0),.F.}),If( dDataIni<=dDataFin,.T.,Eval({|| Help('',1,'DTINCOMP',,STR0049,1,0),.F.}) ) )	SIZE 50, 08 OF oPanel Hasbutton PIXEL //"Informe a Data Inicial!" //"A data inicial deve ser menor ou igual a data final!"
		@nLinha,245		MSGET dDataFin		Picture "@D" 	Valid If( Empty(dDataFin),Eval({|| Help('',1,'INFDTFIN',,STR0053,1,0),.F.}),If( dDataFin>=dDataIni,.T.,Eval({|| Help('',1,'',,STR0051,1,0),.F.}) ) )	SIZE 50, 08 OF oPanel Hasbutton PIXEL //"Informe a Data Final!" //"A data final deve ser maior ou igual a data inicial!"
		nLinha += 12
		@nLinha,005 	Say STR0054	SIZE 30, 07 OF oPanel PIXEL //"Lote: "
		@nLinha,045		MSGET cLoteTit			Picture "@!" 	Valid lCkFRG(xFilial("FRG")+cCartorio+cLoja+cContrato,cLoteTit) SIZE 30, 08 OF oPanel Hasbutton PIXEL
		@nLinha,110 	Say STR0055	SIZE 30, 07 OF oPanel PIXEL //"Quantidade: "

		@nLinha,145		SAY   oQuantidade	Var nQuantidade Picture "@!" 	SIZE 30, 08 OF oPanel PIXEL
		oMark := MsSelect():New("TRB","EF_OK","",aMkBCampos,@lInverte,@cMarca,{48,1,180,315})


		oMark:oBrowse:lColDrag := .T.
		oMark:bMark := {| | FA096Displ(cMarca,lInverte)}
		oMark:oBrowse:bAllMark := { || A096Inverte(cMarca,oQtdaP,oQtdaR,oValRec,oValPag)}

		oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		ACTIVATE MSDIALOG oDlg ON INIT (Fa096Bar(oDlg,{|| nOpca := 1,IIF(lCkProtOK(),oDlg:End(),NIL)},{|| nOpca := 2,IIF(MsgYesNo(STR0086),oDlg:End(),NIL)},oMark),oMark:oBrowse:Refresh()) CENTERED //"Cancelar?"
		If nOpca==1
			TRB->(dbGoTop())
			aAreaSEF:=SEF->(GetArea())
			cFiltroSEF := SEF->(DbFilter())
			SEF->(DbClearFilter())
			SEF->(DbSetOrder(6))
			While !TRB->(Eof())
				If TRB->EF_OK==cMarca
					IF SEF->( DbSeek( TRB->EF_FILIAL+"R"+TRB->EF_BANCO+TRB->EF_AGENCIA+TRB->EF_CONTA+TRB->EF_NUM+TRB->EF_PREFIXO+TRB->EF_TITULO+TRB->EF_PARCELA+TRB->EF_TIPO ))
						RecLock("SEF")
						SEF->EF_STATUS := "08"
						SEF->(MSUnlock())
						RecLock("FRG",.T.)
						If Empty(cItem)
							cItem	:=	Soma1(FRG->FRG_ITEM)
						Else
							cItem :=SOMA1(cItem)
						Endif
						FRG->FRG_FILIAL	:=	xFilial("FRG")
						FRG->FRG_FORNEC	:= cCartorio
						FRG->FRG_LOJA		:=	cLoja
						FRG->FRG_CONTRA	:=	cContrato
						FRG->FRG_LOTE		:=	cLoteTit
						FRG->FRG_QUANT		:=	nQuantidade
						FRG->FRG_INIVIG	:=	dDataIni
						FRG->FRG_FINVIG	:=	dDataFin
						FRG->FRG_PREFIXO	:=	SEF->EF_PREFIXO
						FRG->FRG_TITULO	:=	SEF->EF_TITULO
						FRG->FRG_PARCELA	:=	SEF->EF_PARCELA
						FRG->FRG_TIPO		:=	SEF->EF_TIPO
						FRG->FRG_CLIENT	:=	SEF->EF_CLIENTE
						FRG->FRG_LOJCLI	:=	SEF->EF_LOJACLI
						FRG->FRG_BANCO		:=	SEF->EF_BANCO
						FRG->FRG_AGENCI	:=	SEF->EF_AGENCIA
						FRG->FRG_CONTA		:=	SEF->EF_CONTA
						FRG->FRG_MOEDA		:=	TRB->E1_MOEDA
						FRG->FRG_TXMOED	:=	TRB->E1_TXMOEDA
						FRG->FRG_VALOR		:=	SEF->EF_VALOR
						FRG->FRG_MULTA		:=	0
						FRG->FRG_JUROS		:=	0
						FRG->FRG_VLTAXA	:=	0
						FRG->FRG_TOTAL		:=	0
						FRG->FRG_VENCTO	:=	SEF->EF_VENCTO
						FRG->FRG_STATUS	:=	"1" //Protestado
						FRG->FRG_ITEM		:=	cItem
						FRG->(MSUnlock())
					Endif
					fA96GrvFRF("R","A2","CHEQUE PROTESTADO",cCartorio,cLoja,SEF->EF_TITULO)
				Endif
				TRB->(DbSkip())
			EndDo
		Endif
		Exit
	EndDo
	If Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	If Select("TMPTRB") > 0
		dbSelectArea("TMPTRB")
		dbCloseArea()
	EndIf
	If Select("NEWSEF") > 0
		dbSelectArea( "NEWSEF" )
		dbCloseArea()
	Endif
	dbSelectArea("SEF")
	If !Empty(cFiltroSEF)
		SEF->(DbSetfilter({||&cFiltroSEF},cFiltroSEF))
	EndIf

	#IFNDEF TOP
		EndFilBrw("SEF",@aIndex)	
		bFiltraBrw:= { || FilBrowse("SEF",@aIndex,@cCondicao,.T.) }
		Eval( bFiltraBrw ) 
	#ELSE
		oBrowse:DeleteFilter("fA096Bco")
	#ENDIF

	RestArea(aAreaSEF)

Return (.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096ChecF³ Autor ³ Wagner Montenegro	³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Preparar arquivos temporarios...							   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096ChecF(lCtrlCheq)							   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa096ChecF(lCtrlCheq)
	LOCAL aStruSEF := {}
	LOCAL aStruTRB := {}
	LOCAL nX 		:= 1
	Local nRegEmp	:= SM0->(Recno())
	Local nRegAtu	:= SM0->(Recno())
	Local cEmpAnt	:= SM0->M0_CODIGO
	Local aFiliais := {xFilial("SEF")}
	Local lTodasFil := .F.
	Local cCond1 := "!Eof()"
	Local nCond	 := 1
	Local aAreaAtu := {}
	Local lIndice12 := .F.
	Local nI := 0
	Local nPosCampo := 0
	Local cCampo := ""

	Default lCtrlCheq:=.F.

	dbSelectArea("TRB")
	aStruTRB := dbStruct()

	dbSelectArea("SEF")
	aStruSEF := dbStruct()

	//Verifica existencia do indice 1 do SEF - EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
	aAreaAtu := GetArea()
	dbSelectArea("SIX")

	If MSSeek("SEF"+"C")
		If "EF_FILIAL" $ CHAVE .AND. "EF_BANCO" $ CHAVE .AND. "EF_AGENCIA" $ CHAVE .AND. "EF_CONTA" $ CHAVE .AND. ;
		"EF_NUM" $ CHAVE
			lIndice12:=	.T.
		EndIf
	Else
		lIndice12:=	.F.
	Endif

	RestArea(aAreaAtu)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre o SEF com outro alias para ser filtrado                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF ChkFile("SEF",.F.,"NEWSEF")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Execblock a ser executado antes da Indregua                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//	IF (ExistBlock("F096FIL"))
		//		cFil380 := ExecBlock("F096FIL",.f.,.f.)
		//	Else
		cFil380 := ""
		//	Endif

		//Formato antigo
		If !lIndice12

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta express„o do Filtro para sele‡„o                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cIndexSEF	:= CriaTrab(nil,.f.)
			cChaveSEF	:= IndexKey()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se devem ser consideradas todas as filiais          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(xFilial( "SA6")) .And. !Empty(xFilial("SEF"))
				If Left(LTrim(cChaveSEF),9) == "EF_FILIAL"
					// Tira a filial da chave.
					cChaveSEF := lTrim(SubStr(cChaveSEF,AT("+",cChaveSEF)+1))
				EndIf
			EndIf
			nOldIndex	:= IndexOrd()
			
			IndRegua("NEWSEF",cIndexSEF,cChaveSEF,,fA096FilEF(),OemToAnsi(STR0056))  //"Selecionando Registros..."

			dbSelectArea("NEWSEF")
			#IFNDEF TOP
				dbSetIndex(cIndexSEF+OrdBagExt())
			#ENDIF
			dbGoTop()
			If Bof() .And. Eof()
				Return
			EndIf

		Else  //indice novo existe

			If Empty(xFilial( "SA6")) .And. !Empty(xFilial("SEF"))
				lTodasFil := .T.
				dbSelectArea("SM0")
				nRegAtu := SM0->(RECNO())
				If dbSeek(cEmpAnt,.T.)
					aFiliais := {}
					While !Eof() .and. SM0->M0_CODIGO == cEmpAnt
						AADD(aFiliais,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ))
						DbSkip()
					Enddo
				EndIf
				SM0->(dbGoto(nRegAtu))
			EndIf

			dbSelectArea("NEWSEF")
			dbSetOrder(1)  //EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
			cCond1 := "!Eof() .and. "
			cCond1 += "EF_FILIAL == xFilial('SEF') .And."
			cCond1 += "DTOS(EF_VENCTO)>= '" + DTOS(dIniDt380)+"'" + " .and. "
			cCond1 += "DTOS(EF_VENCTO)<= '" + DTOS(dFimDt380)+"'"
			If lTodasFil
				nCond := Len(aFiliais)
			Else
				nCond := 1
			Endif
		Endif

		//Tratamento de todas as filiais
		For nI := 1 to nCond

			//Se forem todas as filiais,utilizo o arrau aFiliais como referencia
			If nCond > 1
				cFilAtu := aFiliais[nI]
				SM0->(MsSeek(SM0->M0_CODIGO+cFilAtu))
			Else
				cFilAtu := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
			Endif

			cEmpAnt := SM0->M0_CODIGO

			While !Eof() .and. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) == cFilAtu

				cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
				dbSelectArea("NEWSEF")

				//Se possui novo indice posiciono no primeiro registro da filial
				If lIndice12 
					MsSeek(xFilial("SEF")+cBco380+cAge380+cCta380+DTOS(dIniDt380),.T.)
				Endif

				//Verifico quebra por filial ou por fim de arquivo
				While &cCond1

					If lIndice12 .and. !&(fA096FilEF(,lCtrlCheq)) .and. !lCkSEF()
						dbSkip()
						Loop
					EndIf

					dbSelectArea("NEWSEF")

					If ! Empty( TRB->EF_OK )
						If EF_CART == "P"
							nQtdTitP++
							nValPag += EF_VALOR
						Else
							nQtdTitR++
							nValRec += EF_VALOR
						Endif
					Else
						If EF_CART == "P"
							nValPagT += EF_VALOR
						Else
							nValRecT += EF_VALOR
						Endif
					EndIf
					dbSelectArea("NEWSEF")
					dbSkip()
				EndDo
				If Empty(xFilial("SEF"))
					Exit
				Endif
				dbSelectArea("SM0")
				dbSkip()
			Enddo
		Next
	EndIf
	SM0->(dbGoTo(nRegEmp))
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096FilEF³ Autor ³ Wagner Montenegro	³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Filtar tabela SEF.										   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096FilEF(cAlias, nRec, nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fA096FilEF(cAlias,lCtrlCheq)
	Local cFiltro := ""
	Default lCtrlCheq	:=	.F.

	If !(Empty(xFilial( "SA6")) .And. !Empty(xFilial("SE5")))
		cFiltro := 'EF_FILIAL=="'+xFilial("SEF")				+'".And.'
	Endif
	cFiltro += 'DTOS(EF_DATA)>="' + DTOS(dIniDt380)	+ '".And.'
	cFiltro += 'DTOS(EF_DATA)<="' + DTOS(dFimDt380) + '" '
Return( cFiltro )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096FilE1 ³ Autor ³ Wagner Montenegro    ³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Filtar tabela SE1.										   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096FilE1( <chave de busca na tabela SE1> )		   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096FilE1( cBusca )

	Local lRet    := .F.
	Local nOrdSE1 := SE1->( IndexOrd() )

	// ------------------------------------------------------------------------
	// E1_FILIAL+E1_PORTADO+E1_AGEDEP+E1_CONTA+E1_BCOCHQ+E1_AGECHQ+E1_CTACHQ+E1_PREFIXO+E1_NUM
	// Portador + Agencia Depositária + Conta + Banco do Cheque + Agencia + C
	// ------------------------------------------------------------------------
	SE1->( DbSetOrder(26) )

	lRet := SE1->( DBSeek( cBusca ) )

	//--- Restaura a Ordem Original
	SE1->( DbSetOrder( nOrdSE1 ) )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ lCkCart 	 Autor ³ Wagner Montenegro		³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consultar Fluxo de Caixa.								   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := lCkCart(nX)										   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lCkCart(nX)
	Local lRet :=.T.
	Local aAreaSA2 :=	GetArea()
	Default nX := 0
	SA2->(DbSetOrder(1))
	If nX==0
		If !SA2->(DbSeek(xFilial("SA2")+cCartorio))
			Help('',1,'NAOENCONTRADO',,STR0057,1,0) //"Cartorio não encontrado!"
			lRet :=.F.
		Endif
	Else
		If SA2->(DbSeek(xFilial("SA2")+cCartorio+cLoja))
			cNomeA2	:= SA2->A2_NOME
		Else
			Help('',1,'NAOENCONTRADO',,STR0058,1,0) //"Loja não cadastrada!"
			lRet :=.F.
		Endif
	Endif
	SA2->(RestArea(aAreaSA2))
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ lCkSEF	³ Autor ³ Wagner Montenegro		³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Verificar a existencia do Cheque.						   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := lCkSEF(cAlias, nRec, nOpcx)						   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lCkSEF()
	Local lRet:= .F.
	Local aAreaSEF:=SEF->(GetArea())
	Local cFiltroSEF := ""
	cFiltroSEF := SEF->(DbFilter())
	SEF->(DbClearFilter())
	SEF->(DbSetOrder(6))
	IF SEF->(DbSeek(NEWSE5->E5_FILIAL+"R"+NEWSE5->E5_BANCO+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA+NEWSE5->E5_NUMERO+NEWSE5->E5_PREFIXO))
		If SEF->EF_STATUS$"04/07"
			lRet:=.T.
		Endif
	Endif
	If !Empty(cFiltroSEF)
		SEF->(DbSetfilter({||&cFiltroSEF},cFiltroSEF))
	EndIf
	SEF->(RestArea(aAreaSEF))
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³A096ConSEF³ Autor ³ Wagner Montenegro      ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consiste os motivos/status da baixa de cheques.			   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096Fluxo(cAlias, nRec, nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A096ConSEF(cBusca,nOrdSEF,nModo)
//nModo = 1 Compensar
//nModo = 2 Anular
Local lRet :=.F.
Local cFiltro := ""
Local aAreaSEF:= SEF->(GetArea())
Local cFilialFRF := ""
Local nTamCpoFRF := 0

Default nModo := 0

cFiltro := SEF->(DbFilter())
SEF->(DbClearFilter())
DbSelectArea("SEF")
SEF->(DbSetOrder(nOrdSEF))
// xFilial('SEF')+'R'+SE1->E1_BCOCHQ+SE1->E1_AGECHQ+SE1->E1_CTACHQ+SUBSTR(SE1->E1_NUM,1,Len(SEF->EF_NUM))+SE1->E1_PREFIXO)
//EF_FILIAL+EF_CART+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO  
If SEF->(DbSeek(cBusca))
	If nModo==1
		If SEF->EF_STATUS=="01" //Em Carteira
			lRet:=.T.
		Endif
	Elseif nModo==2 .and. SEF->EF_STATUS $ "04/09"
		If cPaisLoc=="ARG" .and. ((SEF->EF_TERCEIR .And. SEF->EF_ENDOSSA=="1") .Or. (!SEF->EF_TERCEIR)) .and. !Empty(SEF->EF_ORDPAGO)
			If cChvLbx $ "11/12"
				If SEF->EF_STATUS$"04/09"
					If !(FRF->(DbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM+cChvLbx)))
						If cChvLbx $ "12"
							lRet:= FRF->(DbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM+"11"))
						Else
							lRet:=.T.
						Endif
					Endif
				Endif
			Else
				lRet:=.T.
			Endif
		Else
			If SEF->EF_STATUS=="04" //Compensado
				If cChvLbx $ "11/12"
					If !(FRF->(DbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM+cChvLbx)))
						If cChvLbx $ "12"
							lRet:= FRF->(DbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM+"11"))
						Else
							lRet:=.T.
						Endif
					Endif
				Else
					lRet:=.T.
				Endif
			Endif
		Endif
	Endif
Endif

If SEF->EF_RECONC == "x"
	lRet:=.F.
EndIf
	If !Empty(cFiltro)
		SEF->(DbSetfilter({||&cFiltro},cFiltro))
	EndIf
	SEF->(RestArea(aAreaSEF))
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ lCkProtOk	³ Autor ³ Wagner Montenegro	³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consiste os motivos/status da baixa de cheques.			   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := lCkProtOk()										   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lCkProtOK()
	Local lRet:=.T.
	If Empty(cCartorio) .or. Empty(cLoja)
		MsgAlert(STR0059) //"Campos obrigatórios. Informe o Cartório e Loja."
		lRet:=.F.
	Endif
	If Empty(cContrato)
		MsgAlert(STR0060) //"Campo obrigatório. Informe o Contrato."
		lRet:=.F.
	Endif
	If Empty(dDataINI) .or. Empty(dDataFin)
		MsgAlert(STR0061) //"Campos obrigatórios. Informe as datas de vigência do Contrato."
		lRet:=.F.
	Endif
	If Empty(cLoteTit)
		MsgAlert(STR0062) //"Campos obrigatório. Informe o Lote."
		lRet:=.F.
	Endif
	If Empty(nQuantidade)
		MsgAlert(STR0063) //"Seleção obrigatória. Selecione os cheques para protesto."
		lRet:=.F.
	Endif
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096Bco	³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Seleciona Banco / Conta / Periodo.						   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametro ³ ExpC1 enviado pela rotina fA096Conci, apenas, para que nao  ³±
±±³          ³       seja gerada a metade inferior da tela de parametros.  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096Bco()                      					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096Bco(lBordero,lfiltro,lAutomato)
	//--- Retorno
	Local lRet := .F.
	//--- Genericas
	Local nEspLarg := 0
	Local nEspLin  := 0
	Local nOpca    := 0
	//--- Tela
	Local oDlg
	Local oPanel
	Local nLen	:=	0
	Local aSaveArea	:= GetArea()

	Default lBordero 	:= .F.
	Default lfiltro 	:= .T.
	Default lAutomato 	:= .F.
	
	//--- Definicao de Coordenadas
	nEspLarg := 8
	nEspLin  := 5

	If lBordero
		nLen:=13
	Endif
If cPaisLoc $ "ARG"
	If ValType(lExecute)=="L"
		lExecute	:= .F.
	EndIf
EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Requisito Entidades Bancarias (Junho de 2012) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cPaisLoc == "ARG" )
		cPostal := Criavar("EF_POSTAL")    // Inicialmente inicializada com Space(4)
	Endif
  If !lAutomato
	DEFINE MSDIALOG oDlg FROM 143,145 TO 169,190 TITLE OemToAnsi( STR0119 ) // "Entidades Bancarias"
	oDlg:lMaximized := .F.
	oPanel := TPanel():New(00,00,'',oDlg,, .T., .T.,, ,00,00)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Metade Superior - Variaveis Relativas ao Banco de Deposito ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 000+nEspLin,003+nEspLarg TO 075+nEspLin+nLen,163+nEspLarg OF oPanel  PIXEL

	@ 011+nEspLin,010+nEspLarg SAY STR0028 SIZE 20, 7 OF oPanel PIXEL //"Banco Portador:"

	@ 009+nEspLin,045+nEspLarg MSGET cBco380	F3 "SA6" Picture "@!" ;
	Valid If(nOpca<>0,CarregaSA6(@cBco380,,,.T.),.T.) ;
	SIZE 17, 10 OF oPanel Hasbutton PIXEL

	@ 026+nEspLin,010+nEspLarg SAY STR0029 SIZE 24, 7 OF oPanel PIXEL //"Agencia depositaria:"

	@ 024+nEspLin,045+nEspLarg MSGET cAge380	Picture "@!"  ;
	Valid If(nOpca<>0,CarregaSA6(@cBco380,@cAge380,,.T.),.T.) ;
	SIZE 32, 10 OF oPanel PIXEL

	@ 42+nEspLin,010+nEspLarg SAY STR0004 SIZE 20, 7 OF oPanel PIXEL //"Conta:"

	@ 040+nEspLin,045+nEspLarg MSGET cCta380	Picture PesqPict("SE8","E8_CONTA") ;
	Valid If(nOpca<>0,CarregaSA6(@cBco380,@cAge380,@cCta380,.T.),.T.) ;
	SIZE 47, 10 OF oPanel PIXEL

	@ 057+nEspLin,010+nEspLarg SAY STR0064 SIZE 20, 7 OF oPanel PIXEL //"De"

	@ 056+nEspLin,045+nEspLarg MSGET dIniDt380;
	VALID If(Empty(dFimDt380),If(Empty(dIniDt380), .F. , .T. ),If(!Empty(dIniDt380) .and. dIniDt380<=dFimDt380, .T. , .F. )) ;
	SIZE 46, 10 OF oPanel Hasbutton PIXEL

	@ 058+nEspLin,095+nEspLarg SAY STR0065 SIZE 20, 7 OF oPanel PIXEL //"Até: "

	@ 056+nEspLin,114+nEspLarg MSGET dFimDt380;
	VALID If(dFimDt380 >= dIniDt380, .T. , .F.) ;
	SIZE 46, 10 OF oPanel Hasbutton PIXEL
	If lBordero
		@ 072+nEspLin,010+nEspLarg SAY STR0125  SIZE 25, 7 OF oPanel PIXEL //'Bordero'
		@ 071+nEspLin,045+nEspLarg MSGET cBord380;
		SIZE 30, 10 PICTURE X3Picture("E1_NUMBOR") OF oPanel Hasbutton PIXEL
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Metade Inferior - Variaveis Relativas ao Entidades Bancarias (Junho de 2012) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 078+nEspLin+nLen,003+nEspLarg TO 156+nEspLin+nLen,163+nEspLarg OF oPanel  PIXEL

	@ 089+nEspLin+nLen,010+nEspLarg SAY STR0120 SIZE 55, 7 OF oPanel PIXEL //"Banco Cheque:"

	@ 087+nEspLin+nLen,060+nEspLarg MSGET cBcoChq	F3 "FJNCON" Picture "@!" Valid VerFJN("cBcoChq") SIZE 17, 10 OF oPanel Hasbutton PIXEL

	@ 104+nEspLin+nLen,010+nEspLarg SAY STR0121 SIZE 55, 7 OF oPanel PIXEL // "Agencia Cheque:"

	@ 102+nEspLin+nLen,060+nEspLarg MSGET cAgeChq	Picture "@!" Valid VerFJN("cAgeChq") SIZE 32, 10 OF oPanel PIXEL

	@ 120+nEspLin+nLen,010+nEspLarg SAY STR0122 SIZE 55, 7 OF oPanel PIXEL // "Conta Cheque:"

	@ 118+nEspLin+nLen,060+nEspLarg MSGET cCtaChq	Picture PesqPict("SE8","E8_CONTA") SIZE 47, 10 OF oPanel PIXEL READONLY

	If cPaisLoc == "ARG"
		@ 136+nEspLin+nLen,010+nEspLarg SAY STR0123 SIZE 55, 7 OF oPanel PIXEL // "Codigo Postal:"
		@ 134+nEspLin+nLen,060+nEspLarg MSGET cPostal	Picture "9999" Valid VerFJN("cPostal") SIZE 47, 10 OF oPanel PIXEL
	Endif

	DEFINE SBUTTON FROM 170+nLen, 100 TYPE 1 ENABLE ACTION ( nOpca := 1 , oDlg:End() ) OF oPanel
	DEFINE SBUTTON FROM 170+nLen, 130 TYPE 2 ENABLE ACTION oDlg:End() OF oPanel

	ACTIVATE MSDIALOG oDlg CENTERED

  Else
    	If FindFunction("GetParAuto")
			aRetAuto 		:= GetParAuto("FINA096TESTCASE")
			cBco380 		:= aRetAuto[1]
			cAge380 		:= aRetAuto[2]
			cCta380 		:= aRetAuto[3]
			dIniDt380		:= aRetAuto[4]
			dFimDt380		:= aRetAuto[5]
			cBcoChq			:= aRetAuto[6]
			cAgeChq			:= aRetAuto[7]
			cCtaChq			:= aRetAuto[8]
			cPostal			:= aRetAuto[9]
			If lBordero
				cBord380		:= aRetAuto[10]
			Endif
		Endif
		nOpca := 1
  EndIf

	If nOpca == 0 .Or. nOpca == 3
		oBrowse:DeleteFilter("fA096Bco")
	lExecute	:= .T.   
		Return(lRet)
	Endif

	cCondicao := "EF_FILIAL=='"+xFilial('SEF')+"' .AND. EF_CART=='R' "

	If !EMPTY(dIniDt380)
		cCondicao += ".AND. DTOS(EF_DATA) >= '"+DTOS(dIniDt380)+"' "
	EndIf

	If !EMPTY(dFimDt380)
		cCondicao += ".AND. DTOS(EF_DATA) <= '"+DTOS(dFimDt380)+"' "
	EndIf

	If !Empty(cBco380+cAge380+cCta380) .And. lfiltro
		cCondicao += ".AND. fA096FilE1(xFilial('SEF')+cBco380+cAge380+cCta380+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_PREFIXO+EF_NUM) "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Expressao de Filtro para Entidades Bancarias - Junho de 2012 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cBcoChq )
		If cPaisLoc == "ARG"
			If !Empty( cPostal )
				cCondicao += ".AND. EF_POSTAL=='" + cPostal + "' "
			EndIf
		Endif
	Else
		cCondicao += ".AND. EF_BANCO=='" + cBcoChq + "' "
		cCondicao += ".AND. EF_AGENCIA=='" + cAgeChq + "'"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis que irao compor a expressao do Select em A089Recibe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBcoFJN := cBcoChq
	cAgeFJN := cAgeChq
	cPosFJN := cPostal

	cFilter := cCondicao
	IF !lAutomato
	    Eval( bFiltraBrw ) 
	    lRet		:=	.T.
		cBcoDe 		:= cBco380
		cBcoAte		:= cBco380
		dDataDe		:= dIniDt380
		dDataAte	:= dFimDt380
		#IFDEF TOP
			oBrowse:DeleteFilter("fA096Bco")
			oBrowse:AddFilter(STR0069,cFilter,.T.,.T.,"SEF",,,"fA096Bco")	
		#ELSE
			EndFilBrw("SEF",@aIndex)
			mBrowse(  6, 1,22,75,"SEF",aCampos,,,,,Fa096Legen("SEF"))
			SEF->(DbGoTop())	
		#ENDIF
		RestArea(aSaveArea)
		oBrowse:Refresh()
	Else
		lRet		:=	.T.
		cBcoDe 		:= cBco380
		cBcoAte		:= cBco380
		dDataDe		:= dIniDt380
		dDataAte	:= dFimDt380
		RestArea(aSaveArea)
	Endif 
	lExecute	:= .T.
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ lCkFRG	³ Autor ³ Wagner Montenegro		³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consiste existência de Lote para o Contrato de Protesto.	   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := lCkFRG(cBusca,cLoteTit)								   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lCkFRG(cBusca,cLoteTit)
	Local lRet := .T.
	If FRG->(DbSeek(cBusca))
		While !FRG->(EOF()) .and. (FRG->FRG_FILIAL+FRG->FRG_FORNEC+FRG->FRG_LOJA+FRG->FRG_CONTRA)==cBusca
			If FRG->FRG_LOTE==cLoteTit
				MsgAlert(STR0066) //"Já existe este lote para o Contrato informado!"
				lRet:=.F.
			Endif
			FRG->(DbSkip())
		Enddo
	Endif
Return(lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa380BAR	³ Autor ³ Wagner Monteiro       ³ Data ³30.09.10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela - WINDOWS 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa096Bar(oDlg,bOk,bCancel,oSelecP,oSelecR,oMark)
Local oBar, bSet15, bSet24, bSet18, lOk
	Local lVolta := .F.
	Local aButtons := {}
	EnchoiceBar( oDlg, {|| ( lLoop := lVolta, lOk := Eval( bOk ) ) }, {|| ( lLoop := .F., Eval( bCancel ), ButtonOff( bSet15, bSet24,bSet18,.T. ) ) },, aButtons,,,,, .F. )
Return nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A380Invert ³ Autor ³ Wagner Montiro        ³ Data ³ 30/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca titulos			   		         			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina380										                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A096Inverte(cMarca,oQtdaP,oQtdaR,oValRec,oValPag)
	Local nReg := TRB->(Recno())
	DbSelectArea("TRB")
	DbGoTop()

	While !Eof()
		If TRB->EF_OK == cMarca
			If TRB->EF_CART == "P"
				nQuantidade--
				nValPag -= TRB->EF_VALOR
				nQtdTitP--
			Else
				nQuantidade--
				nValRec -= TRB->EF_VALOR
				nQtdTitR--
			Endif
			RecLock("TRB")
			Replace TRB->EF_OK with "  "
			MsUnlock()
		Else
			If TRB->EF_CART == "P"
				nQuantidade++
				nValPag += TRB->EF_VALOR
				nQtdTitP++
			Else
				nQuantidade++
				nValRec += TRB->EF_VALOR
				nQtdTitR++
			Endif
			RecLock("TRB")
			Replace TRB->EF_OK with cMarca
			MsUnlock()
		Endif
		dbskip()
	EndDo
	DbSelectArea("TRB")
	DbGoTo(nReg)
	oQuantidade:Refresh()
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Wagner Monteiro        ³ Data ³30/10/10 ³±±
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
	Local aRotina
	aRotina:=		{{STR0068 				, 'AxPesqui()'    	, 0 , 1 },; //"Buscar"
	{ STR0069               , 'fA096Bco()'		, 0 , 3 },; //"Parâmetros"
	{ STR0070               , 'fA096Fluxo()' 	, 0 , 4 },; //"Fluxo de Caixa"
	{ STR0071               , 'fA096Comp()'	 	, 0 , 4 },; //"Liquidar"
	{ STR0073               , 'fA096Anula()' 	, 0 , 5 },; //"Anular"
	{ STR0074               , 'fA096Prote()'	, 0 , 4 },; //"Protestar"
	{ STR0077               , 'fA096Hist()' 	, 0 , 4 },; //"Historico"
	{ STR0075               , 'fA096Legen(,1)' 	, 0 , 1 } } //"Legenda"

Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fa380Displ³ Autor ³ Wagner Monteiro       ³ Data ³ 30/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca e Desmarca Titulos, invertendo a marca‡†o existente  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa380Displ()															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA380																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fa096Displ(cMarca,lInverte,oQtdaP,oQtdaR,oValRec,oValPag,oValRecT,oValPagT)

	If IsMark("EF_OK",cMarca,lInverte)
		If TRB->EF_CART == "P"
			nQuantidade++
			nValPag += TRB->EF_VALOR
			nValPagT -= TRB->EF_VALOR
			nQtdTitP++
		Else
			nQuantidade++
			nValRec += TRB->EF_VALOR
			nValRecT -= TRB->EF_VALOR
			nQtdTitR++
		Endif
	Else
		If TRB->EF_CART == "P"
			nQuantidade--
			nValPag -= TRB->EF_VALOR
			nValPagT += TRB->EF_VALOR
			nQtdTitP--
		Else
			nQuantidade--
			nValRec -= TRB->EF_VALOR
			nValRecT += TRB->EF_VALOR
			nQtdTitR--
		Endif
	Endif
	oQuantidade:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ A096MTVSEF³ Autor ³ Wagner Montenegro	  ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consiste os motivos/status da baixa de cheques.			    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096Fluxo(cAlias, nRec, nOpcx)					    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										    ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A096MTVSEF(nModo)
	//nModo = 1 Compensar
	//nModo = 2 Anular
	Local lRet :=.F.
	Default nModo := 0

	If nModo==1
		lRet:= SEF->EF_STATUS=="01" //Em Carteira
	Elseif nModo==2
		If SEF->EF_STATUS=="04" //Compensado
			If cChvLbx $ "11/12"
				If !(FRF->(DbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM+SPACE(2)+cChvLbx)))
					If cChvLbx $ "12"
						If FRF->(DbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM+SPACE(2)+"11"))
							lRet:=.T.
						Endif
					Else
						lRet:=.T.
					Endif
				EndIf
			Endif
		Else
			lRet:=.T.
		Endif
	Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³fA096Hist | Autor ³ Rodrigo Gimenes        ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±³          ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³              											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização República Dominicana							   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096Hist()

	Local aArea         := GetArea()
	Local oDlg				// Dialog Principal
	Local oListBox
	Local aDevolu := {}
Local nPosicao := 1
	Local oPanel

	dbSelectArea("FRF")
	FRF->(dbSetOrder(2))
	FRF->(dbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM))

	While !FRF->(Eof()) .And. xFilial("FRF")  == FRF->FRF_FILIAL .And. FRF->FRF_BANCO == SEF->EF_BANCO .And. FRF->FRF_AGENCIA == SEF->EF_AGENCIA;
	.And. FRF->FRF_CONTA == SEF->EF_CONTA .And. FRF->FRF_NUM == SEF->EF_NUM

		aAdd(aDevolu,{FRF->FRF_NUM,FRF->FRF_DATDEV,FRF->FRF_DATPAG,FRF->FRF_MOTIVO,Lower(FRF->FRF_DESCRI),FRF->FRF_FORNEC,IIf(Empty(FRF->FRF_CLIENT),SEF->EF_CLIENTE,FRF->FRF_CLIENT),IIf(Empty(FRF->FRF_LOJA),SEF->EF_LOJACLI,FRF->FRF_LOJA),FRF->FRF_ESPDOC,SerieNfId('FRF',2,'FRF_SERDOC'),IIF(Empty(FRF->FRF_NUMDOC),SEF->EF_TITULO,FRF->FRF_NUMDOC),FRF->FRF_ITDOC,FRF->(Recno())})

		dbSelectArea("FRF")
		FRF->(dbSkip())
	EndDo

	If Len( aDevolu ) == 0
		Help( ,,"fA096Anula1",,STR0078, 1, 0 )//"Não existem dados a consultar"
		Return
	Endif


	DEFINE MSDIALOG oDlg FROM 0, 0 TO 400,900 PIXEL TITLE OemToAnsi(STR0095) //"Histórico de Compensações e Devoluções"
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,370,80,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_BOTTOM
	oPanel:nHeight := 30
	oListBox := TCBrowse():New(0,0,10,10,,,,oDlg,,,,,,,,,,,,,,.T.,,,,.T.,)
	oListBox:AddColumn(TCColumn():New(STR0082,{||aDevolu[oListBox:nAt,1]},,,,,030,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0081,{||If(!Empty(aDevolu[oListBox:nAt,2]),aDevolu[oListBox:nAt,2],"")},,,,,030,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0084,{||If(!Empty(aDevolu[oListBox:nAt,3]),aDevolu[oListBox:nAt,3],"")},,,,,030,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0083,{||aDevolu[oListBox:nAt,4]},,,,,015,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0080,{||aDevolu[oListBox:nAt,5]},,,,,020,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0127,{||AllTrim(aDevolu[oListBox:nAt,6]) + AllTrim(aDevolu[oListBox:nAt,7])},,,,,020,.F.,.F.,,,,,))//"Código"
	oListBox:AddColumn(TCColumn():New(AllTrim(SF2->(RetTitle("F2_LOJA"))),{||aDevolu[oListBox:nAt,8]},,,,,020,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(AllTrim(SF2->(RetTitle("F2_DOC"))),{|| If(!Empty(aDevolu[oListBox:nAt,9]+aDevolu[oListBox:nAt,8]+aDevolu[oListBox:nAt,10]+aDevolu[oListBox:nAt,11]),AllTrim(aDevolu[oListBox:nAt,8]) + "  -  " + AllTrim(aDevolu[oListBox:nAt,9]) + " / " + AllTrim(aDevolu[oListBox:nAt,10]) + " - " + AllTrim(aDevolu[oListBox:nAt,11]),"")},,,,,030,.F.,.F.,,,,,))
	oListBox:SetArray( aDevolu)
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	DEFINE SBUTTON FROM 02,330 PIXEL TYPE 1 ACTION oDLg:End() ENABLE OF oPanel
	ACTIVATE MSDIALOG oDlg CENTERED

	lRet := .T.

	RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA096DevCH  ºAutor ³ Wagner Montenegro º Data ³ 18/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validação de devolução Cheques e preparação de NDI.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Argentina                                                 ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA096DevCH(CCAMPO,CCPO,CALIAS)
	Local lRet:=.T.
	Local aAreaSEF:=SEF->(GetArea())
	Local aAreaSEK:=SEK->(GetArea())
	Local aAreaSEL:=SEL->(GetArea())
	Local aAreaSA1:=SA1->(GetArea())
	Local aAreaSA2:=SA2->(GetArea())
	Local cInfoForn:=""
	Local cInfoClie:=""
	Local aFina040:={}
	Local aFina050:={}
	Local nI :=0

	If Empty((cAlias)->E1_OK)
		SEF->(DbSetOrder(6))
		If SEF->(DbSeek(xFilial("SEF")+"R"+(cAlias)->E1_BCOCHQ+(cAlias)->E1_AGECHQ+(cAlias)->E1_CTACHQ+Substr((cAlias)->E1_NUM,1,TamSX3("EF_NUM")[1])+(cAlias)->E1_PREFIXO))
			If SEF->EF_ENDOSSA=="1" .and. !Empty(SEF->EF_ORDPAGO) .and. SEF->EF_STATUS=="09" .and. Empty(SEF->EF_DTDEVCH)
				SEK->(DbSetOrder(1))
				IF SEK->(DbSeek(xFilial("SEK")+SEF->EF_ORDPAGO))
					SA2->(DbSetOrder(1))
					If SA2->(DbSeek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA))
						cInfoForn:="["+SA2->A2_COD+"-"+SA2->A2_LOJA+" "+Rtrim(SA2->A2_NOME)+"] "
					Else
						lRet:=.F.
					Endif
				Endif
				SEL->(DbSetOrder(1))
				IF SEL->(DbSeek(xFilial("SEL")+SEF->EF_TITULO+SUBSTR(SEF->EF_TIPO+space(5),1,TAMSX3("EL_TIPODOC")[1])+SEF->EF_PREFIXO+SEF->EF_NUM))
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG))
						cInfoClie:="["+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+Rtrim(SA1->A1_NOME)+"] "
					Else
						lRet:=.F.
					Endif
				Endif
				If lRet
					If cChvLbx<>"11"
						Aviso(STR0088+SEF->EF_ORDPAGO+STR0089+cInfoForn+STR0090+cInfoClie+".")//"FA096 - DEVOLUCAO CHEQUE TERCEIRO" //"Cheque de terceiro usado em pagamento através da Ordem de Pago nº "  //". O cancelamento deste cheque ira gerar automaticamente uma NDI a favor do Fornecedor "   //"e uma NDC contra o cliente "
						lRet := .T. //"Confirma a devolução do cheque pelo fornecedor e a geração dos titulos de NDI e NDC ?"
						If lRet
							aAdd(aFina040,{"E1_PREFIXO"	,GetMv("MV_FINPXE1")       	, Nil})   // E1_PREFIXO
							aAdd(aFina040,{"E1_NUM"			,"", Nil})//GetSx8Num("SE1","FINPRDB")   , Nil}) // E1_NUM
							aAdd(aFina040,{"E1_TIPO"		,"NDC"                    	   , Nil})// E1_TIPO
							aAdd(aFina040,{"E1_NATUREZA"	,SEF->EF_NATUR             	, Nil})   // E1_NATUREZA
							aAdd(aFina040,{"E1_CLIENTE"	,SEF->EF_CLIENTE         	   , Nil})// E1_CLIENTE
							aAdd(aFina040,{"E1_LOJA"		,SEF->EF_LOJACLI              , Nil})// E1_LOJA
							aAdd(aFina040,{"E1_EMISSAO"	,dDataBase                	   , Nil})// E1_EMISSAO
							aAdd(aFina040,{"E1_VENCTO"		,dDataBase		          	   , Nil})// E1_VENCTO
							aAdd(aFina040,{"E1_VENCREA"	,DataValida(dDataBase)		  	, Nil})   // E1_VENCREA
							aAdd(aFina040,{"E1_VALOR"		,SEF->EF_VALOR            	   , Nil})// E1_VALOR
							aAdd(aFina040,{"E1_ORIGEM"		,"T"+STRZERO(TMP089->(RECNO()),9) 	   , Nil})// E1_VALOR
							aAdd(aDados040,aFina040)

							aAdd(aFina050,  {"E2_PREFIXO" , GetMv("MV_FINPXE2")  , Nil})
							aAdd(aFina050,  {"E2_NUM"     ,"" , Nil})//GetSx8Num("SE2","FINPRDB")    , Nil})
							aAdd(aFina050,  {"E2_TIPO"    , 'NDI'           , Nil})
							aAdd(aFina050,  {"E2_NATUREZ" , SEF->EF_NATUR   , Nil})
							aAdd(aFina050,  {"E2_FORNECE" , SA2->A2_COD		, Nil})
							aAdd(aFina050,  {"E2_LOJA"    , SA2->A2_LOJA    , Nil})
							aAdd(aFina050,  {"E2_EMISSAO" , dDataBase 		, Nil})
							aAdd(aFina050,  {"E2_VENCTO"  , dDataBase			, Nil})
							aAdd(aFina050,  {"E2_VALOR"   , SEF->EF_VALOR   , Nil})
							aAdd(aFina050,  {"E2_VLCRUZ"  , SEF->EF_VALOR   , Nil})
							aAdd(aFina050,  {"E2_ORIGEM"  , "T"+STRZERO(TMP089->(RECNO()),9)  , Nil})
							aAdd(aDados050,aFina050)
							TMP089->LCANCELOP := "T"
						Endif
					Else
						lRet:=MsgYesNo(STR0092+SEF->EF_PREFIXO+"-"+SEF->EF_NUM+STR0093+SEF->EF_BANCO+"/"+SEF->EF_AGENCIA+"/"+SEF->EF_CONTA+STR0094) //"O cheque [" //"] do Banco/Agencia/Conta ["//"] está sendo devolvido pelo fornecedor?"
						If lRet
							Aviso(STR0096+SEF->EF_ORDPAGO+STR0097+cInfoForn+".")//"FA096 - DEV.CH.TERCEIRO M11"//"Cheque de terceiro usado em pagamento através da Ordem de Pago nº " //". O cancelamento deste cheque ira gerar automaticamente uma NDI a favor do Fornecedor "
							lRet:=MsgYesNo(STR0098)//"Confirma a devolução do cheque pelo fornecedor e a geração do titulo de NDI?"
							If lRet
								aAdd(aFina050,  {"E2_PREFIXO" , GetMv("MV_FINPXE2")  , Nil})
								aAdd(aFina050,  {"E2_NUM"     ,"" , Nil})//GetSx8Num("SE2","FINPRDB")    , Nil})
								aAdd(aFina050,  {"E2_TIPO"    , 'NDI'           , Nil})
								aAdd(aFina050,  {"E2_NATUREZ" , SEF->EF_NATUR   , Nil})
								aAdd(aFina050,  {"E2_FORNECE" , SA2->A2_COD     , Nil})
								aAdd(aFina050,  {"E2_LOJA"    , SA2->A2_LOJA    , Nil})
								aAdd(aFina050,  {"E2_EMISSAO" , dDataBase 		, Nil})
								aAdd(aFina050,  {"E2_VENCTO"  , dDataBase			, Nil})
								aAdd(aFina050,  {"E2_VALOR"   , SEF->EF_VALOR   , Nil})
								aAdd(aFina050,  {"E2_VLCRUZ"  , SEF->EF_VALOR   , Nil})
								aAdd(aFina050,  {"E2_ORIGEM"  , "T"+STRZERO(TMP089->(RECNO()),9)  , Nil})
								aAdd(aDados050,aFina050)
								TMP089->LCANCELOP := "2"
							Endif
						Else
							lRet:=MsgYesNo(STR0099)//"Confirmar apenas registro da devolução e a reapresentação do mesmo pelo fornecedor?"
							TMP089->LCANCELOP := "R"
						Endif
					Endif
				Endif
			Elseif SEF->EF_ENDOSSA=="1" .and. !Empty(SEF->EF_ORDPAGO) .and. SEF->EF_STATUS=="04" .and. !Empty(SEF->EF_DTDEVCH)
				SEL->(DbSetOrder(1))
				IF SEL->(DbSeek(xFilial("SEL")+SEF->EF_TITULO+SUBSTR(SEF->EF_TIPO+space(5),1,TAMSX3("EL_TIPODOC")[1])+SEF->EF_PREFIXO+SEF->EF_NUM))
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG))
						cInfoClie:="["+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+Rtrim(SA1->A1_NOME)+"] "
					Else
						lRet:=.F.
					Endif
				Endif
				If cChvLbx<>"11"
					If lRet
						Aviso(STR0100,STR0101+cInfoClie+".")//"FA096 - DEVOLUCAO CHEQUE TERCEIRO" //"O cancelamento deste cheque ira gerar automaticamente uma NDC contra o cliente "
						lRet:=MsgYesNo(STR0102)   //"Confirma a geração de NDC contra o Cliente?"
						If lRet
							aAdd(aFina040,{"E1_PREFIXO"	,GetMv("MV_FINPXE1")       	, Nil})   // E1_PREFIXO
							aAdd(aFina040,{"E1_NUM"			,"", Nil})//GetSx8Num("SE1","FINPRDB")   , Nil}) // E1_NUM
							aAdd(aFina040,{"E1_TIPO"		,"NDC"                    	   , Nil})// E1_TIPO
							aAdd(aFina040,{"E1_NATUREZA"	,SEF->EF_NATUR             	, Nil})   // E1_NATUREZA
							aAdd(aFina040,{"E1_CLIENTE"	,SEF->EF_CLIENTE         	   , Nil})// E1_CLIENTE
							aAdd(aFina040,{"E1_LOJA"		,SEF->EF_LOJACLI              , Nil})// E1_LOJA
							aAdd(aFina040,{"E1_EMISSAO"	,dDataBase                	   , Nil})// E1_EMISSAO
							aAdd(aFina040,{"E1_VENCTO"		,dDataBase         	   		, Nil})// E1_VENCTO
							aAdd(aFina040,{"E1_VENCREA"	,DataValida(dDataBase)		  	, Nil})   // E1_VENCREA
							aAdd(aFina040,{"E1_VALOR"		,SEF->EF_VALOR            	   , Nil})// E1_VALOR
							aAdd(aFina040,{"E1_ORIGEM"		,"T"+STRZERO(TMP089->(RECNO()),9) 	   , Nil})// E1_VALOR
							aAdd(aDados040,aFina040)
							TMP089->LCANCELOP := "1"
						Endif
					Endif
				Endif
			Elseif SEF->EF_ENDOSSA=="1" .and. Empty(SEF->EF_ORDPAGO) .and. SEF->EF_STATUS=="04" .or. SEF->EF_ENDOSSA<>"1" .and. SEF->EF_STATUS=="04"
				SEL->(DbSetOrder(1))
				IF SEL->(DbSeek(xFilial("SEL")+SEF->EF_TITULO+SUBSTR(SEF->EF_TIPO+space(5),1,TAMSX3("EL_TIPODOC")[1])+SEF->EF_PREFIXO+SEF->EF_NUM))
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG))
						cInfoClie:="["+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+Rtrim(SA1->A1_NOME)+"] "
					Else
						lRet:=.F.
					Endif
				Endif
				If cChvLbx<>"11"
					If lRet
						Aviso(STR0104+cInfoClie+".")//"FA096 - DEVOLUCAO CHEQUE / NDC" //"O cancelamento deste cheque ira gerar automaticamente uma NDC contra o cliente "
						lRet:=MsgYesNo(STR0102)//"Confirma a geração de NDC contra o Cliente?"
						If lRet
							aAdd(aFina040,{"E1_PREFIXO"	,GetMv("MV_FINPXE1")       	, Nil})   // E1_PREFIXO
							aAdd(aFina040,{"E1_NUM"			,"", Nil})//GetSx8Num("SE1","FINPRDB")   , Nil}) // E1_NUM
							aAdd(aFina040,{"E1_TIPO"		,"NDC"                    	   , Nil})// E1_TIPO
							aAdd(aFina040,{"E1_NATUREZA"	,SEF->EF_NATUR             	, Nil})   // E1_NATUREZA
							aAdd(aFina040,{"E1_CLIENTE"	,SEF->EF_CLIENTE         	   , Nil})// E1_CLIENTE
							aAdd(aFina040,{"E1_LOJA"		,SEF->EF_LOJACLI              , Nil})// E1_LOJA
							aAdd(aFina040,{"E1_EMISSAO"	,dDataBase                	   , Nil})// E1_EMISSAO
							aAdd(aFina040,{"E1_VENCTO"		,dDataBase		          	   , Nil})// E1_VENCTO
							aAdd(aFina040,{"E1_VENCREA"	,DataValida(dDataBase)		  	, Nil})   // E1_VENCREA
							aAdd(aFina040,{"E1_VALOR"		,SEF->EF_VALOR            	   , Nil})// E1_VALOR
							aAdd(aFina040,{"E1_ORIGEM"		,"T"+STRZERO(TMP089->(RECNO()),9) 	   , Nil})// E1_VALOR
							aAdd(aDados040,aFina040)
							TMP089->LCANCELOP := "1"
						Endif
					Endif
				Endif
			Endif
		Endif
	Else
		If Len(aDados040)>0
			For nI:= 1 to Len(aDados040)
				If aDados040[nI][11][2]=="T"+STRZERO(TMP089->(RECNO()),9)
					aDel(aDados040,nI)
				Endif
			Next
		Endif
		nI:=0
		If Len(aDados040)>0
			For nI:= 1 to Len(aDados050)
				If aDados050[nI][11][2]=="T"+STRZERO(TMP089->(RECNO()),9)
					aDel(aDados050,nI)
				Endif
			Next
		Endif
	Endif
	SEF->(RestArea(aAreaSEF))
	SEK->(RestArea(aAreaSEK))
	SEL->(RestArea(aAreaSEL))
	SA1->(RestArea(aAreaSA1))
	SA2->(RestArea(aAreaSA2))
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o  ³ FA096RdSel ³ Autor ³ Wagner Montenegro   ³ Data ³ 18/08/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Simular markbrowse a ser ultizado via chamada no Rdmake,   ³±±
±±³          ³ desvinculado das op‡oes do array aRotina.                  ³±±
±±³           Função replicada da função RDSelect() p/ Uso Argentina.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ nOpcao:=RDSelect(cAlias,cCpoMark,cCpoCond,aCampos,cTitle,  ³±±
±±³          ³         cMsg,cFilter,lInverte)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias   := Alias do arquivo utilizado no RDMarkBrow.      ³±±
±±³          ³ cCpoMark := Campo de controle ex: E1_OK.                   ³±±
±±³          ³ cCpoCond := Condicao CamposObjeto RDMarkBrowse.            ³±±
±±³          ³ aCampos  := Array contEndo as campos/colunas de Edicao ou  ³±±
±±³          ³             Visualizacao.                                  ³±±
±±³          ³ cTitle   := Titulo a ser impressp na janela de Dialogo     ³±±
±±³          ³ cFilter  := Expressao de filtro para selecao dos regitros  ³±±
±±³          ³ cMarca   := cMarca ( cMarca:=GetMark() ).                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nOpcao == 1 Confirma a selecao ou 2 Abandona selecao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso     ³ RDMakes.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA096RdSel(cAlias,cCpoMark,cCpoCond,aCampos,cTitle,cMsg,cFilter,cMarca,lInverte,aCoordIn,aCoordExt,cRDM,aButtons)
	Local nRec
	Local oDlgMark, nOpca
	Local oValor  := 0
	Local cCpoFilial := Subs(cAlias,2,2)+"_FILIAL"
	Private cMarcaRDM:= Iif(ValType(cMarca) == Nil,"",cMarca)
	Private nValorSel:= 0
	Private lNOT
	Private lFA096Ret

	DEFAULT aButtons := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os valores por default se nao for pasados os parametr³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ValType(aCoordIn)=="U"
		aCoordIn:={34,1,143,315}
	EndIf
	If ValType(aCoordExt)=="U"
		aCoordExt:={9,0,28,80}
	EndIf
	DbSelectArea(cAlias)
	If cAlias != "TRB"
		bWhile := { || xFilial( cAlias ) == &(cCpoFilial) }
		DbSeek(xFilial( cAlias ) )
	Else
		bWhile := { || ! Eof() }
		DbGoTop()
	EndIf
	nOpca :=0
	DbGoTop()

	DEFINE MSDIALOG oDlgMark TITLE OemToAnsi(cTitle) From aCoordExt[1],aCoordExt[2] To aCoordExt[3],aCoordExt[4]

	@ 1.4,.8 Say OemToAnsi(cMsg)
	If ValType(cRDM)#"U" .and. ExistBlock(cRDM)
		@2.1,.8 Say   OemToAnsi(STR0041)    // "Valor Selecionado "
		@2.1,10 Say oValor VAR nValorSel Picture "@E 999,999,999,999.99"  //Valid Execute(ExecBlock('pepe',.f.,.f.))
	EndIf

	oMark := MsSelect():New(cAlias,cCpoMark,cCpoCond,aCampos,@lInverte,@cMarca,aCoordIn)

	If cPaisLoc=="ARG" .and. FUNNAME()=="FINA096"
		oMark:oBrowse:BLDBLCLICK:={|| MARKREC(CCPOMARK,CCPOCOND,CALIAS,THISINV(),THISMARK(),LNOT,oMark:BMARK,oMark:BAVAL),oMark:REFRESHLINE() }
	Endif
	If ValType(cRDM)=="U"
		oMark:bMark := {|| RdMark(cAlias, oMark, cMarca, cCpoMark, lInverte)}
	ElseIf ExistBlock(cRDM)
		oMark:bMark := {|| RdMark(cAlias, oMark, cMarca, cCpoMark, lInverte),nValorSel:=ExecBlock(cRDM,.f.,.f.),oValor:Refresh()}
	EndIf

	oMark:oBrowse:lhasMark = .T.
	oMark:oBrowse:lCanAllmark := .T.

	If ValType(cRDM)#"U"  .and. ExistBlock(cRDM)
		oMark:oBrowse:bAllMark := {|| nValorSel:=ExecBlock(cRDM,.f.,.f.),oValor:Refresh(),oMark:oBrowse:Refresh(.t.)}
	Else
		oMark:oBrowse:bAllMark := {|| RdMarkAll(cAlias, oMark, cMarca, cCpoMark)}
	EndIf

	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgMark CENTERED ON INIT EnchoiceBar(oDlgMark,{ || nOpca:=1, oDlgMark:End() },{ || nOpca:=0, oDlgMark:End() },Nil,aButtons)

Return( nOpca )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA096   ºAutor  ³Microsiga           ºFecha ³ 12/12/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o cabecalho e o gride de itens da nota de debito com º±±
±±º          ³ os dados do fornecedor e dos cheques.                      º±±
±±º          ³ Esta funcao e chamada na montagem da tela pela LOCXNF,     º±±
±±º          ³ montando-se um bloco de codigo como mostrado abaixo:       º±±
±±º          ³ bFunAuto:={||A096DadosND(SEF->EF_CLIENTE,SEF->EF_LOJACLI,  º±±
±±º          ³ ,{SEF->(Recno())})}                                        º±±
±±º          ³ Esta variavel deve ser inicializada antes da chamada a     º±±
±±º          ³ funcao da locxnf.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA096 - geracao de notas de debito para clientes         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A096DadosND(cCliente,cLoja,aItens,cAlias,cCpoVal,lLinhas,lTitulo,cPV)
	Local nItem			:= 0
	Local nPosQtd		:= 0
	Local nPosVlrUn		:= 0
	Local nPosTotal		:= 0
	Local nPosTES		:= 0
	Local cValidacao	:= ""
	Local bValid		:= {|| }

	Default cCliente	:= ""
	Default cLoja		:= ""
	Default aItens		:= {}
	Default cAlias		:= "SEF"
	Default cCpoVal		:= "EF_VALOR"
	Default lTitulo		:= .T.
	Default lLinhas		:= .T.
	Default cPV			:=""

	If !Empty(aItens)
		/* inicializa os dados do cebecalho da nota */
		M->F2_CLIENTE := cCliente
		M->F2_LOJA := cLoja		
		If cPaisloc=="ARG"
			M->F2_PV	:= cPV
		M->F2_SERIE :=Space(Len(SF2->F2_SERIE))
		EndIf
		/* impede a edicao do fornecedor */
		If Type("__aoGets")!= "U" .And. ValType(__aoGets)=="A"
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F2_CLIENTE"})
			If nItem > 0
				__aoGets[nItem]:bWhen := {|| .F.}
			Endif
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F2_LOJA"})
			If nItem > 0
				__aoGets[nItem]:bWhen := {|| .F.}
			Endif
		Endif
		/*
		inicializa os dados dos itens */
		nPosQtd   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D2_QUANT"})
		nPosVlrUn := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D2_PRCVEN"})
		nPosTotal := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D2_TOTAL"})
		nPosTES   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D2_TES"})
		aCols := {}
		For nItem := 1 To Len(aItens)
			If aItens[nItem] > 0
				(cAlias)->(DbGoTo(aItens[nItem]))
				oGetDados:AddLine()
				aCols[nItem,nPosQtd] := 1
				aCols[nItem,nPosVlrUn] := (cAlias)->&cCpoVal
				aCols[nItem,nPosTotal] := (cAlias)->&cCpoVal
			Endif
		Next
		nItem--		//contem a quantidade de documentos devolvidos
		cValidacao := " F096MaxLin(" + cValToChar(nItem) + ")"
		/*
		altera a validacao da quantidade para nao permitir sua alteracao quando o item for um documento devolvido */
		If Empty(aHeader[nPosQtd,6])
			aHeader[nPosQtd,6] := cValidacao
		Else
			aHeader[nPosQtd,6] := cValidacao + " .And. " + aHeader[nPosQtd,6]
		Endif
		/*
		altera a validacao do valor para nao permitir sua alteracao quando o item for um documento devolvido */
		If Empty(aHeader[nPosVlrUn,6])
			aHeader[nPosVlrUn,6] := cValidacao
		Else
			aHeader[nPosVlrUn,6] := cValidacao + " .And. " + aHeader[nPosVlrUn,6]
		Endif
		/*
		altera a validacao do valor para nao permitir sua alteracao quando o item for um documento devolvido */
		If Empty(aHeader[nPosTotal,6])
			aHeader[nPosTotal,6] := cValidacao
		Else
			aHeader[nPosTotal,6] := cValidacao + " .And. " + aHeader[nPosTotal,6]
		Endif
		/*
		nao permite TES que atualizem estoque e/ou que nao gerem titulos*/
		If Empty(aHeader[nPosTES,6])
			aHeader[nPosTES,6] := "A096NDTES(M->D2_TES," + If(lTitulo,".T.",".F.") + ")"
		Else
			aHeader[nPosTES,6] := "A096NDTES(M->D2_TES," + If(lTitulo,".T.",".F.") + ") .And. " + aHeader[nPosTES,6]
		Endif
		/*-*/
		If Empty(oGetDados:cLinhaOK)
			If lLinhas
				oGetDados:cLinhaOK := "A096NDTES(," + If(lTitulo,".T.",".F.") + ")"
			Else
				oGetDados:cLinhaOK := "A096NDTES(," + If(lTitulo,".T.",".F.") + ") .And. " + cValidacao
			Endif
		Else
			If lLinhas
				oGetDados:cLinhaOK := "A096NDTES(," + If(lTitulo,".T.",".F.") + ") .And. " + oGetDados:cLinhaOK
			Else
				oGetDados:cLinhaOK := "(A096NDTES(," + If(lTitulo,".T.",".F.") + ") .And. " + cValidacao + ") .And. " + oGetDados:cLinhaOK
			Endif
		Endif
		If Empty(oGetDados:cTudoOK)
			oGetDados:cTudoOKOK := "A096NDTES(," + If(lTitulo,".T.",".F.") + ")"
		Else
			oGetDados:cTudoOK := "A096NDTES(," + If(lTitulo,".T.",".F.") + ") .And. " + oGetDados:cTudoOK
		Endif
		/*
		nao pemite a exclusao dos itens referentes aos documentos devolvidos */
		If Empty(oGetDados:cSuperDel)
			oGetDados:cSuperDel := cValidacao
		Else
			oGetDados:cSuperDel := cValidacao + ".And. " + oGetDados:cSuperDel
		Endif
		If Empty(oGetDados:cDelOk)
			oGetDados:cDelOk := cValidacao
		Else
			oGetDados:cDelOk := cValidacao + ".And. " + oGetDados:cDelOk
		Endif
		/*
		define uma funcao para ser executada ao final da edicao da nota de debito para capturar os dados na nd gerada*/
		oGetDados:oWnd:bValid := {|| A096NDGer(),.T.}
		/*-*/
		oGetDados:lNewLine := .F.
		/*-*/
		MaFisClear()
		MaColsToFis(aHeader,aCols,,"MT100",.T.)
		If !lLinhas
			oGetDados:nMax := nItem
		Endif
		oGetDados:oBrowse:nAt := 1
		oGetDados:oBrowse:Refresh()
	Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA096   ºAutor  ³Microsiga           ºFecha ³ 12/12/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recupera os dados da nota de debito gerada para serem      º±±
±±º          ³ incluidos nos cheques devolvidos.                          º±±
±±º          ³ Atribui os valores as variaveis declaradas como PRIVATE    º±±
±±º          ³ pela rotina que executou a funcao da locxnf.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA096 - geracao de notas de debito para fornecedores     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A096NDTES(cTes,lTitulo)
	Local lRet		:= .T.
	Local nPosTES	:= 0

	Default cTes	:= ""
	Default lTitulo	:= .T.

	If Empty(cTes)
		nPosTES := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D2_TES"})
		If nPosTES <> 0
			cTes := aCols[n,nPosTES]
		Endif
	Endif

	If !Empty(cTes)
		If SF4->(DbSeek(xFilial("SF4") + cTes))
			/* para despesas, o TES nao deve atualizar estoque e deve gerar titulos no financeiro */
			If SF4->F4_ESTOQUE == "S" .Or. If(lTitulo,SF4->F4_DUPLIC <> "S",SF4->F4_DUPLIC == "S")
				If lTitulo
					MsgAlert("Para incluir despesas, utilize somente TES que não atualizem estoque e que gerem títulos financeiros" + ".")
				Else
					MsgAlert("Para incluir despesas, utilize somente TES que não atualizem estoque e que não gerem títulos financeiros" + ".")
				Endif
				lRet := .F.
			Endif
		Endif
	Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA096   ºAutor  ³Microsiga           ºFecha ³ 12/12/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recupera os dados da nota de debito gerada para serem      º±±
±±º          ³ incluidos nos cheques devolvidos.                          º±±
±±º          ³ Atribui os valores as variaveis declaradas como PRIVATE    º±±
±±º          ³ pela rotina que executou a funcao da locxnf.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA096 - geracao de notas de debito para fornecedores     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A096NDGer()
	Local nItem

	If oGetDados:oWnd:nResult == 0
		If Type("__aoGets")!= "U" .And. ValType(__aoGets)=="A"
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F2_DOC"})
			If nItem > 0
				cNumNota := __aoGets[nItem]:cText
			Endif
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->"+SerieNfId("SF2",3,"F2_SERIE") })
			If nItem > 0
				cSerNota := __aoGets[nItem]:cText
			Endif
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F2_ESPECIE"})
			If nItem > 0
				cEspNota := __aoGets[nItem]:cText
			Endif
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F2_VALBRUT"})
			If nItem > 0
				nValBrut := __aoGets[nItem]:cText
			Endif
		Endif
	Endif
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fA100GrvFRF   ºAutor  ³ Jose Lucas     º Data ³  13/09/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gravar o histórico das movimentações do cheque na tabela   º±±
±±º          ³ FRF.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ fA100GrvFRF(cCodMotivo,cDescricao)	                      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpC1 = cCodMotivo									      ³±±
±±³          ³ ExpC1 = cDescricao									      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fA96GrvFRF(cCarteira,cMotivo,cDescricao,cCliFor,cLoja,cTitulo)
	Local cSavArea := GetArea()
	Local cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
	Default cCliFor := SEF->EF_CLIENTE
	Default cLoja	:= SEF->EF_LOJACLI
	Default cTitulo  := SEF->EF_TITULO


	//Gravar o histórico para as alterações de status do cheque.
	RecLock("FRF",.T.)
	FRF->FRF_FILIAL	 := xFilial("FRF")
	FRF->FRF_BANCO	 := SEF->EF_BANCO
	FRF->FRF_AGENCIA := SEF->EF_AGENCIA
	FRF->FRF_CONTA	 := SEF->EF_CONTA
	FRF->FRF_NUM	 := SEF->EF_NUM
	FRF->FRF_PREFIX	 := SEF->EF_PREFIXO
	FRF->FRF_CART	 := cCarteira
	FRF->FRF_DATPAG	 := SEF->EF_DATA
	FRF->FRF_MOTIVO	 := cMotivo
	FRF->FRF_CLIENT  := cCliFor
	FRF->FRF_LOJA	 := cLoja
	FRF->FRF_NUMDOC	 := cTitulo
	FRF->FRF_DESCRI	 := cDescricao
	FRF->FRF_SEQ	 := cSeqFRF
	FRF->(MsUnLock())
	ConfirmSX8()

	RestArea(cSavArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VerFJN     ³ Autor ³ Carlos Eduardo Chigres      ³ Data ³ 20/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao das variaveis cBcoChq e aAgeChq na digitacao do Filtro   ³±±
±±³          ³ implementado pela rotina fA096Bco()                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA096, sub - rotina  fA096Bco()					              ³±±
±±³          ³ FINA060, sub - rotina  Fa060Borde()					              ³±±
±±³          ³ FINA060, sub - rotina  fA060Bco()					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³          Manutencoes efetuadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VerFJN( cVariab )

	//--- Retorno
	Local lRet := .T.

	//--- Ambiente
	Local aOrigin  := GetArea()
	Local aFJN     := FJN->( GetArea() )

	//--- Genericas
	Local nOrder   := 1   // Order Default de Busca na FJN, Filial + Banco + Agencia
	Local cFilFJN  := xFilial( "FJN" )
	Local cConten  := &(Readvar())
	Local cChave   := " "
	Local lFullKey := .F.


	//--- Testo qual variavel esta sendo editada
	If cVariab == "cBcoChq"

		If !Empty( cConten )
			cChave := cFilFJN + cConten
		EndIf

	ElseIf cVariab == "cAgeChq"

		If !Empty( cConten )
			lFullKey := .T.
			cChave := cFilFJN + cBcoChq + cConten
		EndIf

	ElseIf cVariab == "cPostal"
		If !Empty( cConten )
			nOrder := 2    // Pesquisa por Filial + Codigo Postal
			cChave := cFilFJN + cPostal
		EndIf	

	EndIf

	//--- Existe chave preenchida para a busca ??
	If !Empty( cChave )

		dbSelectArea( "FJN" )
		//--- Filial + Banco + Agencia
		dbSetOrder( nOrder )

		lRet := dbSeek( cChave )

		If lRet
			If cPaisLoc == "ARG"
				If lFullKey
					cPostal := FJN->FJN_POSTAL
				EndIf
			Endif
		Else
			Help(" ",1,"REGNOIS")
		EndIf

		RestArea( aFJN )
		RestArea( aOrigin )
	EndIf

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CamposDef ³ Autor ³ Carlos E. Chigres    ³ Data ³ 26/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Construcao de array de Campos de Browse especifico         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com Lista de Campos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Sao dois os pontos onde essa rotina eh acionada:           ³±±
±±³          ³ 1 = mBrowse principal                                      ³±±
±±³          ³ 2 = Mark Browse da rotina de Cheques Protestados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CamposDef( cModo )

	//--- Campos da mBrowse principal Default
	Local aListCamp := { { STR0002	,"EF_BANCO"		,"",00,00,""} ,; //"BANCO"
	{ STR0003	,"EF_AGENCIA"	,"",00,00,""} ,; //"AGENCIA"
	{ STR0004	,"EF_CONTA"		,"",00,00,""} ,; //"CONTA"
	{ STR0005	,"EF_NUM"		,"",00,00,""} ,; //"NUMERO"
	{ STR0006	,"EF_VALOR"		,"",00,00,""} ,; //"VALOR"
	{ STR0007	,"EF_DATA"		,"",00,00,""} ,; //"EMISSAO"
	{ STR0008	,"EF_VENCTO"	,"",00,00,""} ,; //"VENCTO"
	{ STR0009	,"EF_PREFIXO"	,"",00,00,""} ,; //"PREFIXO"
	{ STR0010	,"EF_TITULO"	,"",00,00,""} ,; //"TITULO"
	{ STR0011	,"EF_PARCELA"	,"",00,00,""} ,; //"PARCELA"
	{ STR0012	,"EF_TIPO"		,"",00,00,""} ,; //"TIPO"
	{ STR0013	,"EF_BENEF"		,"",00,00,""} }  //"BENEFICENTE"

	If cModo == "1"    // Campos da mBrowse Principal - modificado

		If cPaisLoc == "ARG"

			aListCamp := {}

			aListCamp := { { STR0002	,"EF_BANCO"		,"",00,00,""} ,; //"BANCO"
			{ STR0003	,"EF_AGENCIA"	,"",00,00,""} ,; //"AGENCIA"
			{ STR0004	,"EF_CONTA"		,"",00,00,""} ,; //"CONTA"
			{ STR0124	,"EF_POSTAL"	,"",00,00,""} ,; //"Cod.Postal"
			{ STR0005	,"EF_NUM"		,"",00,00,""} ,; //"NUMERO"
			{ STR0006	,"EF_VALOR"		,"",00,00,""} ,; //"VALOR"
			{ STR0007	,"EF_DATA"		,"",00,00,""} ,; //"EMISSAO"
			{ STR0008	,"EF_VENCTO"	,"",00,00,""} ,; //"VENCTO"
			{ STR0009	,"EF_PREFIXO"	,"",00,00,""} ,; //"PREFIXO"
			{ STR0010	,"EF_TITULO"	,"",00,00,""} ,; //"TITULO"
			{ STR0011	,"EF_PARCELA"	,"",00,00,""} ,; //"PARCELA"
			{ STR0012	,"EF_TIPO"		,"",00,00,""} ,; //"TIPO"
			{ STR0013	,"EF_BENEF"		,"",00,00,""} }  //"BENEFICENTE"

		EndIf

	Else

		aListCamp := {}

		If cPaisLoc == "ARG"

			aListCamp := {	{ "EF_OK"			,, STR0027},;   //"Rec"
			{ "EF_BANCO"		,, 	STR0028},;  //"Banco"
			{ "EF_AGENCIA"		,, 	STR0029},;  //"Agencia"
			{ "EF_CONTA"		,, 	STR0030},;  //"Conta"
			{ "EF_PREFIXO"		,, 	STR0031},;  //"Prefixo"
			{ "EF_NUM"			,, 	STR0032},;  //"Num. Cheque"
			{ "EF_VENCTO"		,, 	STR0033},;  //"Vencimento"
			{ "EF_VALOR"		,, 	STR0034},;  //"Valor"
			{ "EF_STATUS"		,, 	STR0035},;  //"Status"
			{ "EF_DATA"	     	,, 	STR0036},;  //"Emissão"
			{ "EF_TITULO" 		,, 	STR0037},;  //"Titulo"
			{ "EF_PARCELA"		,,	STR0038},;  //"Parcela"
			{ "EF_CLIENTE"		,,  STR0039},;  //"Cod. Cliente"
			{ "EF_LOJACLI"		,,  STR0040},;  //"Loja"
			{ "EF_EMITENT"		,,  STR0041},;  //"Emitente"
			{ "EF_TIPO"	    	,,  STR0042},;  //"Tipo"
			{ "EF_BANCO"    	,,  STR0120},;  //"Banco Cheque"
			{ "EF_AGENCIA"    	,,  STR0121},;  //"Agencia Cheque"
			{ "EF_POSTAL"    	,,  STR0123}}   //"Codigo Postal"

		Else

			aListCamp := {	{ "EF_OK"			,, STR0027},;   //"Rec"
			{ "EF_BANCO"		,, 	STR0028},;  //"Banco"
			{ "EF_AGENCIA"		,, 	STR0029},;  //"Agencia"
			{ "EF_CONTA"		,, 	STR0030},;  //"Conta"
			{ "EF_PREFIXO"		,, 	STR0031},;  //"Prefixo"
			{ "EF_NUM"			,, 	STR0032},;  //"Num. Cheque"
			{ "EF_VENCTO"		,, 	STR0033},;  //"Vencimento"
			{ "EF_VALOR"		,, 	STR0034},;  //"Valor"
			{ "EF_STATUS"		,, 	STR0035},;  //"Status"
			{ "EF_DATA"	     	,, 	STR0036},;  //"Emissão"
			{ "EF_TITULO" 		,, 	STR0037},;  //"Titulo"
			{ "EF_PARCELA"		,,	STR0038},;  //"Parcela"
			{ "EF_CLIENTE"		,,  STR0039},;  //"Cod. Cliente"
			{ "EF_LOJACLI"		,,  STR0040},;  //"Loja"
			{ "EF_EMITENT"		,,  STR0041},;  //"Emitente"
			{ "EF_TIPO"	    	,,  STR0042} }  //"Tipo"

		EndIf

	EndIf

Return ( aListCamp )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F850Busca ºAutor  ³Marcos Berto        º Data ³  03/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa do Browse         									    º±±
±±º          ³ 		                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA850                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F096Busca(cAlias,cArq,cIndex,lAutomato)

	Local aAux			:= {}
	Local aOrdem 		:= {}
	Local bOk			:= Nil
	Local cAux			:= ""
	Local cCampo 		:= ""
	Local cOrdem 		:= ""
	Local nY			:= 0
	Local nPos			:= 0
	Local nOpc			:= 0
	Local nPosIni		:= 0
	Local nPosFim		:= 0
	Local oDlgBsc
	Local oOrdem
    
	DEFAULT cAlias 		:= ""
	DEFAULT cArq		:= ""
	DEFAULT cIndex		:= ""
	DEFAULT lAutomato  	:= .F.

	cOrdem := AllTrim(RetTitle("EF_NUM"))

	cCampo := Space(TamSX3("E1_NUM")[1])

	Aadd(aOrdem,cOrdem)

	bOk 	:= {|| F096Local(cAlias,cArq,cCampo),oDlgBsc:End()}
  If !lAutomato
	DEFINE MSDIALOG oDlgBsc FROM 00,00 TO 70,400 PIXEL TITLE OemToAnsi("Busca") //Busca
	@ 02,02 COMBOBOX oOrdem VAR cOrdem ITEMS aOrdem SIZE 165,44 OF oDlgBsc PIXEL
	@ 15,02 GET cCampo SIZE 165,10 OF oDlgBsc PIXEL
	DEFINE SBUTTON FROM 02,170 TYPE 1 OF oDlgBsc ENABLE ACTION Eval(bOk)
	DEFINE SBUTTON FROM 15,170 TYPE 2 OF oDlgBsc ENABLE ACTION oDlgBsc:End()
	ACTIVATE DIALOG oDlgBsc
  Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F850Local ºAutor  ³Marcos Berto        º Data ³  03/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa do Browse         									    º±±
±±º          ³ 		                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA850                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F096Local(cAlias,cArq,cBusca)
	Private cAliasTmp := cAlias
	DEFAULT cAlias 	:= ""
	DEFAULT cArq		:= ""
	DEFAULT cBusca	:= ""

	dbSelectArea(cAlias)

	F096GerInd(cArq,"E1_NUM")

	(cAlias)->(dbGoTop())
	If !(cAlias)->(dbSeek(cBusca))
		(cAlias)->(dbGoBottom())
	EndIf

	If Type("oMark") <> "U"
		oMark:oBrowse:Refresh()
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F096GerIndºAutor  ³Marcos Berto        º Data ³  03/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera Índices para pesquisa 									    º±±
±±º          ³ 		                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA850                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F096GerInd(cArq,cIndex)

	DEFAULT cArq		:= ""
	DEFAULT cIndex 	:= ""

	If !Empty(cIndex) .And. !Empty(cArq)
		(cAliasTmp)->(dbSetOrder(2))  
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ fA096SITE1 ³ Autor ³ Eduardo Lima         ³ Data ³ 02.12.14 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Validar campos E1_SITUACA, E1_STATUSatravez da SEL          ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Logico       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ ExpL := fA096SITE1( <chave de busca na tabela SE1> )		   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA096SITE1( cBusca )

	Local lRet    := .T.
	Local nOrdSE1 := SE1->( IndexOrd() )

	SE1->( DbSetOrder(4) )   

	If SE1->( DBSeek( cBusca ) )
		lRet:= (SE1->E1_SITUACA != '0' .OR. (SE1->E1_SITUACA = '0' .AND. SE1->E1_STATUS = 'R'))
	Endif 
	//--- Restaura a Ordem Original
	SE1->( DbSetOrder( nOrdSE1 ) )

Return( lRet )   

//-------------------------------------------------------------------
/*/ {Protheus.doc} F096MaxLin 

Valida a quantidade de linhas

@author Alvaro Camillo Neto
@since 05/01/2015
@version 1.1
/*/                 
//-------------------------------------------------------------------
Function F096MaxLin(nItem)
	Local lRet := .T.

	If !FWIsInCallStack("NfTudOk")
		lRet := n > nItem
	Else
		cSerNota := M->F2_SERIE
	EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A096PERG    º Autor ³ TOTVS            º Data ³  06/09/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carregar as perguntas da contabilizacao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA096                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function A096PERG()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MV_PAR01 -> Muestra Asientos Contab.       ³
	//³ MV_PAR02 -> Agrupa Asientos                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	PERGUNTE( cPerg ,.T.)
	
	lDigita:= Iif(MV_PAR01 == 1, .T.,.F.)
	lGeraLanc:= Iif(MV_PAR02 == 1, .T.,.F.)

Return ()


