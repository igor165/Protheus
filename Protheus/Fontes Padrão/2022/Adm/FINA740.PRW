#INCLUDE "fina740.ch"
#INCLUDE "PROTHEUS.CH"

Static __lLocBRA  := cPaisLoc == "BRA"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA740	³ Autor ³ Claudio D. de Souza   ³ Data ³ 11/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela unica do contas a receber, que permitira ao usuario   ³±±
±±³          ³ manipular as opcoes distribuidas nos menus de contas a Rec.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA740
	LOCAL lNewDic		AS Logical
	PRIVATE aRotina		AS Array
	PRIVATE cCadastro 	AS Character
	PRIVATE lF060LOOP	AS Logical
	PRIVATE cPorta740	AS Character  
	PRIVATE cBanco740	AS Character 
	PRIVATE cAgenc740	AS Character
	PRIVATE cConta740	AS Character

	aRotina := MenuDef()
	cCadastro := STR0011                             //"Contas a Receber"
	lF060LOOP := .T.		// VARIAVEL LOGICA PARA ROTINA FINA060

	cPorta740  := CriaVar("E1_PORTADO",.F.)
	cBanco740  := CriaVar("E1_PORTADO",.F.)
	cAgenc740  := CriaVar("E1_AGEDEP" ,.F.)
	cConta740  := CriaVar("E1_CONTA"  ,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para pre-validar os dados a serem  ³
	//³ exibidos.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock("F740BROW")
		ExecBlock("F740BROW",.f.,.f.)
	Endif

	lNewDic := ( TableIndic("FO0") .and. TableIndic("FO1") .and. TableIndic("FO2") .and. TableIndic("FKD") .and. TableIndic("FKC"))

	If !lNewDic
		aRot280 :=	{	{ STR0023, "FINA280(3)", 0 , 3},;  	//"Selecionar"
						{ STR0019, "FINA280(4)", 0 , 4} } 	//"Cancelar"
		aAdd( aRotina,	{ STR0006,aRot280, 0 , 6}) 			//"Faturas"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SE1",,,,,, Fa040Legenda("SE1"),,,,,,,,IIF(ExistBlock("F740FILB"),ExecBlock("F740FILB",.f.,.f.),NIL),,,,,{|oBrw|oBrw:SetMainProc("FINA740")})

Return Nil

Static Function MenuDef() AS Array
	Local aRotina  		AS Array
	Local aAreaSe1		AS Array 
	Local aRot040 		AS Array
	Local aRot060 		AS Array
	Local aRot070  		AS Array
	Local aRot330 		AS Array
	Local aRot460 		AS Array
	Local aRot175  		AS Array
	Local aRotinaNew 	AS Array
	Local aRot280		AS Array
	Local lIntPFS 		AS Logical
	Local nPos			AS Numeric

	aRotina 	:= 	{}
	aRot040 	:=	{}
	aRot060 	:=	{}
	aRot070 	:= 	{}
	aRot330 	:=	{}
	aRot460 	:=	{}
	aRot175 	:= 	{}
	aRotinaNew 	:=  {}
	lIntPFS 	:=  SuperGetMV("MV_JURXFIN",,.F.) //Integração SIGAPFS
	nPos		:= 	0
	lNewDic 	:= .F.
	aRot280 	:= {}

	//Passado como parametro a posicao da opcao dentro da arotina
	aRot040 :=	{	{ STR0013,"	FINA040(,3)", 0 , 3},; //"Incluir"
						{ STR0014,"	FINA040(,4)", 0 , 4},; //"Alterar"
						{ STR0015,"	FINA040(,5)", 0 , 5},; //"Excluir"
						{ STR0016,"	FINA040(,6)", 0 , 6}} //"Substituir"
	If FindFunction("F040CMNT") .and. MV_MULNATR
		aAdd( aRot040,	{ STR0033,"F040CMNT()", 0 , 2})	//"Consulta Rateio Multi Naturezas - Emissão"	
	Endif	
	If cPaisLoc == "BRA"
		aAdd( aRot040,	{ STR0038,"FINA986('SE1',.T.)", 0 , 4})	//"Complemento do ti­tulo"	
	Endif	

	If FindFunction("FinWizFac")
		aAdd( aRot040, { STR0040,"FinWizFac('SE1')",0, 4, 2, .F.}) //"Facilitador"
	ENDIF

	// Ponto de entrada para inclusão de novos itens no menu aRot040, mesmo PE que existe no FINA040.
	If ExistBlock("FI040ROT")
		aRotinaNew := ExecBlock("FI040ROT",.F.,.F.,aRot040)
		If (ValType(aRotinaNew) == "A")
			aRot040 := aClone(aRotinaNew)
		EndIf
	EndIf

	//Passado como parametro a posicao da opcao dentro da arotina

	aRot060	:= {	{ STR0017, "FIN740060", 0 , 4},; //"Transferir"
						{ STR0018, "FIN740060", 0 , 3},; //"Borderô"
						{ STR0019, "FIN740060", 0 , 3}} //"Cancelar"

	//Passado como parametro o conteudo da posicao 4 da aRotina Original
	aRot070 :=	{	{ STR0020, "FINA070(,3,.T.)", 0 , 4},; //"Baixar"
						{ STR0021, "FINA070(,4,.T.)", 0 , 4},; //"Lote"
						{ STR0022, "FINA070(,5,.T.)", 0 , 5},; //"Canc Baixa"
						{ STR0015, "FINA070(,6,.T.)", 0 , 6}} //"Excluir"
	
	//Passado como parametro a posicao da opcao dentro da arotina
	aRot330 :=	{	{ STR0024, "FINA330(3)", 0 , 4},;  //"Compensar"
						{ STR0015, "FINA330(4)", 0 , 4},; //"Excluir"
						{ STR0030, "FINA330(5)", 0 , 4} } //"Estornar"

	aRot460 := {	{ STR0025, "FINA460(2)" , 0 , 3 },;   //"Liquidar"
						{ STR0026, "FINA460(3)" , 0 , 3 },; //"Reliquidar"
						{ STR0019, "FINA460(4)" , 0 , 6 }}  //"Cancelar"

	aRot175 := {	{STR0027, "Fina150(2)", 0, 3},; //"Gera arq envio"
						{STR0028, "Fina200(3)", 0, 3}} //"Lê arq retorno"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa 	  ³
	//³ ----------- Elementos contidos por dimensao ------------	  ³
	//³ 1. Nome a aparecer no cabecalho 									  ³
	//³ 2. Nome da Rotina associada											  ³
	//³ 3. Usado pela rotina													  ³
	//³ 4. Tipo de Transa‡„o a ser efetuada								  ³
	//³	 1 -Pesquisa e Posiciona em um Banco de Dados				  ³
	//³	 2 -Simplesmente Mostra os Campos								  ³
	//³	 3 -Inclui registros no Bancos de Dados						  ³
	//³	 4 -Altera o registro corrente									  ³
	//³	 5 -Exclui um registro cadastrado								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSe1 := {}

	aAdd( aRotina,	{ STR0001,"AxPesqui", 0 , 1,,.F. }) //"Pesquisar"
	aAdd( aRotina,	{ STR0012,"FA280Visua", 0 , 2}) //"Visualizar"
	aAdd( aRotina,	{ STR0010,"FA040Legenda", 0 , 6, ,.F.}) //"Le&genda"
		
	If lIntPFS
		If ExistFunc("JurBtnReli")
			JurBtnReli(@aRot460, STR0026)
		EndIf

		If ExistFunc("JurDocVinc")
			aAdd( aRotina, {STR0035, "JurDocVinc()"  , 0, 2} )    // "Docs Relacionados - Fatura SIGAPFS"
		EndIf
		
		If ExistFunc("JurBoleto") .And. ExistFunc("JurBolFat") .And. ExistFunc("U_FINX999") 
			aAdd( aRotina,	{ STR0037 ,"JurBolFat(SE1->(Recno()))", 0 , 8}) // "Boleto - Fatura SIGAPFS"
		EndIf
	EndIf

	aAdd( aRotina,	{ STR0029,aRot040, 0 , 3}) //"Opções CR" //"Ctas a Receber"
	aAdd( aRotina,	{ STR0003,aRot060, 0 , 4}) //"Transf/Borderô"
	aAdd( aRotina,	{ STR0004,aRot070, 0 , 5})  //"Bai&xas"
	aAdd( aRotina,	{ STR0007,aRot330, 0 , 6}) //"Co&mpensação"
	aAdd( aRotina,	{ STR0008,aRot460, 0 , 6}) //"Liquidação"
	aAdd( aRotina,	{ STR0031,"CTBC662", 0 , 7}) //"Tracker Contábil"
	aAdd( aRotina,	{ STR0009,aRot175, 0 , 6}) //"CNA&B"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. utilizado para adicionar itens no Menu da mBrowse       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("FA740BRW")
		aRotAdic := ExecBlock("FA740BRW",.F.,.F.,{aRotina})
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf

	If ExistFunc("FINA040VA")
		If (nPos := (aScan(aRotina,{|x| AllTrim(x[1]) == "Ctas a Receber"}))) > 0
			aAdd( aRotina[nPos][2], {STR0034 ,"FINA040VA",0,4})		//"Valores Acessórios"
		EndIf
	EndIf

	//Motor de Retenções
	If __lLocBRA .and. (nPos := (aScan(aRotina,{|x| AllTrim(x[1]) == "Ctas a Receber"}))) > 0
		aAdd( aRotina[nPos][2], { STR0036, "FINCRET('SE1')", 0, 2 } ) //"Consulta de Retenções"
	EndIf

Return(aRotina)    

Function Fin740060(cAlias, nReg, nOpc)
Local nOrd 		:= SE1->(IndexOrd())
Local cFilter 	:= SE1->(DbFilter())
Local aAreaSEA	:= SEA->(GetArea())
Local cRotina	:= "FINA060"
Local cFun		:= ""
Local lPermis	:= .T.

DbSelectArea("SEA")
DbSetOrder(1)
DbSeek(xFilial("SEA") + SE1->(E1_NUMBOR + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO) )

	Do Case 
	Case nOpc == 1 
		If MPUserHasAccess(cRotina, 2, __cUserId)
			FINA060(2)
		Else
			lPermis := .F.
			cFun	:= STR0017
		EndIf
	Case nOpc == 2 
		If MPUserHasAccess(cRotina, 3, __cUserId)
			FINA060(3)
		Else
			lPermis := .F.
			cFun	:= STR0018
		EndIf
	Case nOpc == 3
		If MPUserHasAccess(cRotina, 4, __cUserId)
			Iif(GetNewPar("MV_CNABIMP",.F.) .Or. "FINA060" <> SEA->EA_ORIGEM,FINA060(4),FINA061(3))
		Else
			lPermis := .F.
			cFun	:= STR0019
		EndIf
	EndCase	
	
	If !lPermis
		Help(" ",1,"SEMPERM",, STR0039 + Chr(10) + Chr(13) ;
			+ "Menu: " + cRotina + " / Rotina: " + cFun,1,0)		//"Esse usuário não possui acesso para executar essa operação."
	EndIf

	Set Filter to &cFilter
SE1->(DbSetOrder(nOrd))
RestArea(aAreaSEA)
Return
