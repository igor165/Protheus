#INCLUDE "FINA098.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA098	³ Autor ³ José Lucas	 	    ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CONTROLE DE RECEBIMENTOS POR CARTÃO DE CREDITO.	    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA098(aRotAuto, nOpcAuto )

Local nPos
Local bBlock
Local nX 		:= 0
Local aCores :=	{{ 'FRB_STATUS == "01"','BR_AMARELO' },;	//Em Analise
				 { 'FRB_STATUS == "02"','BR_VERDE'	 },;	//Pagamento Aprovado
				 { 'FRB_STATUS == "03"','BR_AZUL'	 },;	//Rejeição Parcial														//SC com Pedido Colocado Parcial
				 { 'FRB_STATUS == "04"','BR_VERMELHO'}}		//Rejeição Total

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada									 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada							 ³
//³	 1 -Pesquisa e Posiciona em um Banco de Dados				 ³
//³	 2 -Simplesmente Mostra os Campos							 ³
//³	 3 -Inclui registros no Bancos de Dados						 ³
//³	 4 -Altera o registro corrente								 ³
//³	 5 -Exclui um registro cadastrado							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina   := MenuDef()
PRIVATE lF098Auto := ( aRotAuto <> NIL )
PRIVATE lUsaFlag  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do Lote 											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cLote := "",lAltera	:=.F.
PRIVATE cBancoAdt		:= CriaVar("A6_COD")
PRIVATE cAgenciaAdt		:= CriaVar("A6_AGENCIA")
PRIVATE cNumCon			:= CriaVar("A6_NUMCON")
PRIVATE nMoedAdt		:= CriaVar( "A6_MOEDA" )
PRIVATE nMoeda  		:= Int(Val(GetMv("MV_MCUSTO")))
PRIVATE cMarca  		:= GetMark()
PRIVATE lHerdou		:= .F.
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.)
PRIVATE nIndexSE1 := ""
PRIVATE aDadosRet := Array(6)
PRIVATE cIndexSE1 := ""
PRIVATE nVlRetPis	:= 0
PRIVATE nVlRetCof := 0
PRIVATE nVlRetCsl	:= 0
PRIVATE nVlRetIRF := 0
PRIVATE nVlOriCof := 0
PRIVATE nVlOriCsl	:= 0
PRIVATE nVlOriPis := 0
PRIVATE aAutoCab := aRotAuto

If !lF098Auto
	SetKey (VK_F12,{|a,b| AcessaPerg("FIN098",.T.)})
Endif
pergunte("FIN098",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0001  // "Controle de Recebimentos por Cartão de Crédito"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para pre-validar os dados a serem  ³
//³ exibidos.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("F098BROW")
	ExecBlock("F098BROW",.f.,.f.)
Endif

If lF098Auto
	aValidGet := {}
 	If ! SE1->(MsVldGAuto(aValidGet)) // consiste os gets
	  	Return .f.
   	EndIf
	DEFAULT nOpcAuto := 3
	MBrowseAuto(nOpcAuto,aAutoCab,"FRB")
Else
	If nOpcAuto<>Nil
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada direta da funcao de Inclusao/Alteracao/Visualizacao/Exclusao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := nOpcAuto
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k| " + aRotina[ nPos,2 ] + "(x,y,z,k) }" )
			dbSelectArea("FRB")
			Eval( bBlock,Alias(),FRB->(Recno()),nPos)
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE											  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		mBrowse( 6, 1,22,75,"FRB",,,,,,aCores)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12 To
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Jose Lucas - SI5910    ³ Data ³25/09/10 ³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados       	  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {}
Local aRotinaNew

AADD( aRotina,	{ STR0002, "AxPesqui" 		, 0 , 1,,.F. }) //"Pesquisar"
AADD( aRotina,	{ STR0003 ,"AxVisual"		, 0 , 2}) 		// "Visualizar"
AADD( aRotina,	{ STR0004 ,"fA098Manut"		, 0 , 4}) 		// "Manutenção"
AADD( aRotina,	{ STR0019 ,"fA098Cons"		, 0 , 2}) 		// "Consulta"
AADD( aRotina,	{ STR0005 ,"fA098Legenda"	, 0 , 6, ,.F.})	// "Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novos itens no menu aRotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("fA098ROT")
	aRotinaNew := ExecBlock("fA098ROT",.F.,.F.,aRotina)
	If (ValType(aRotinaNew) == "A")
		aRotina := aClone(aRotinaNew)
	EndIf
EndIf
Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fA098Legenda³ Autor ³ José Lucas - SI5910 ³ Data ³10.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Exibe uma janela contendo a legenda da mBrowse.              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA098                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Legenda()

BrwLegenda(cCadastro,STR0005,{	{"BR_AMARELO"	,OemToAnsi(STR0006)},; 		//"Legenda" ### "Em Analise"
								{"BR_VERDE"		,OemToAnsi(STR0007)},;		//"Pagamento Aprovado"
								{"BR_AZUL"		,OemToAnsi(STR0008)},;		//"Rejeição Parcial"
								{"BR_VERMELHO"	,OemToAnsi(STR0009)	}	})  //"Rejeição Total"
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Manut³ Autor ³ Jose Lucas - SI5910   ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obter dados do status ou aceite da Administradora.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Manut(cAlias,nRecno,nOpcx) 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Manut(cAlias,nRecno,nOpcx)
Local aArea  	 := GetArea()
Local nOpca  	 := 0
Local aSize  	 := MSADVSIZE()
Local cCodStatus := CriaVar("FRB_STATUS")
Local cCodMotivo := CriaVar("FRB_MOTIVO")
Local cDscStatus := CriaVar("FR0_DESC01")
Local cDscMotivo := CriaVar("FR0_DESC01")
Local nValReceb  := 0.00
Local cDocCancel := CriaVar("FRB_DOCCAN")
Local dDataCanc  := CriaVar("FRB_DATCAN")
Local cHoraCanc  := CriaVar("FRB_HORCAN")
Local aPicture   := Array(8)
Local oCbxParc
Local oDlg
Local nOpc 		 := 0

aPicture[1] := PesqPict("FRB","FRB_STATUS", TamSX3("FRB_STATUS")[1])
aPicture[2] := PesqPict("FRB","FRB_MOTIVO", TamSX3("FRB_MOTIVO")[1])
aPicture[3] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[4] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[5] := PesqPict("FRB","FRB_VALREC", TamSX3("FRB_VALREC")[1])
aPicture[6] := PesqPict("FRB","FRB_DOCCAN", TamSX3("FRB_DOCCAN")[1])
aPicture[7] := PesqPict("FRB","FRB_DATCAN", TamSX3("FRB_DATCAN")[1])
aPicture[8] := PesqPict("FRB","FRB_HORCAN", TamSX3("FRB_HORCAN")[1])

dbSelectArea("FRB")

cCodStatus := FRB->FRB_STATUS

If cCodStatus <> "01"
	MsgAlert(STR0021,STR0020)	//"Mantenimiento ya efectuado!" ### "Atención"
Else
	DEFINE MSDIALOG oDlg TITLE STR0010 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL // "Manutenção dos Títulos"

		@ 027,010 SAY STR0011	PIXEL OF oDlg COLOR CLR_HBLUE // "Código Status"
		@ 025,070 MSGET cCodStatus  F3 "FR0EQ2" Picture aPicture[1] SIZE 30,08;
				  Valid fA098Status(cCodStatus,@cDscStatus,@nValReceb,@dDataCanc,@cHoraCanc) PIXEL OF oDlg

		@ 025,120 MSGET cDscStatus      	 Picture aPicture[2] SIZE 170,08	PIXEL OF oDlg WHEN .F.

		If cCodStatus $ "01|02"
			@ 042,010 SAY STR0012	PIXEL OF oDlg // "Motivo Cancel.
		Else
			@ 042,010 SAY STR0012	PIXEL OF oDlg COLOR CLR_HBLUE // "Motivo Cancel.
		EndIf
		@ 040,070 MSGET cCodMotivo	F3 "FR0EQ3" Picture aPicture[3] SIZE 30,08;
				  Valid fA098Motivo(cCodMotivo,@cDscMotivo,cCodStatus)	PIXEL OF oDlg
		@ 040,120 MSGET cDscMotivo		     Picture aPicture[4] SIZE 170,08	PIXEL OF oDlg WHEN .F.

		@ 057,010 SAY STR0013	PIXEL OF oDlg 					  // "Valor Recebido".
		@ 055,070 MSGET nValReceb		     Picture aPicture[5] SIZE 70,08;
	        	  Valid fa098ValRec(nValReceb,cCodStatus)		PIXEL OF oDlg

		@ 072,010 SAY STR0014	PIXEL OF oDlg				  // "Código Cancel."
		@ 070,070 MSGET cDocCancel			 Picture aPicture[6] SIZE 50,08;
				  Valid fa098Doc(cDocCancel,cCodStatus) WHEN cCodStatus $ "03|04"		PIXEL OF oDlg

		@ 087,010 SAY STR0015	PIXEL OF oDlg				  // "Código Cancel."
		@ 085,070 MSGET dDataCanc			 Picture aPicture[7] SIZE 50,08;
			 	  Valid fa098Date(dDataCanc)			WHEN cCodStatus $ "03|04"		PIXEL OF oDlg

		@ 102,010 SAY STR0016	PIXEL OF oDlg				  // "Hora Cancel."
		@ 100,070 MSGET cHoraCanc			 Picture aPicture[8] SIZE 30,08;
				  Valid .T. WHEN cCodStatus $ "03|04"		PIXEL OF oDlg

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(fa098Ok(),(nOpca := 1,oDlg:End()),NIL)},{|| nOpca := 2,oDlg:End()})

	//Gravar titulos em um array para posterior substituição.
	If nOpca == 1
	    Pergunte("FIN098",.F.)
		If AllTrim(cCodStatus) == "02"		//Pagamento Aprovado.
			fA098Grv02(cCodStatus,cCodMotivo)
		ElseIf AllTrim(cCodStatus) $ "03" 	//Rejeição Parcial
			//Estornar a Substituição dos Títulos de forma parcial.
			fA098Grv03(cCodStatus,cCodMotivo,nValReceb,cDocCancel,dDataCanc,cHoraCanc)
		ElseIf AllTrim(cCodStatus) $ "04" 	//Rejeição Total
			//Estornar a Substituição dos Títulos de forma total
			fA098Grv04(cCodStatus,cCodMotivo,nValReceb,cDocCancel,dDataCanc,cHoraCanc)
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Cons ³ Autor ³ Jose Lucas - SI5910   ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresentar Consulta dos Status e Motivo.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Cons(cAlias,nRecno,nOpcx) 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Cons(cAlias,nRecno,nOpcx)
Local aArea  	 := GetArea()
Local nOpca  	 := 0
Local aSize  	 := MSADVSIZE()
Local cCodStatus := CriaVar("FRB_STATUS")
Local cCodMotivo := CriaVar("FRB_MOTIVO")
Local cDscStatus := CriaVar("FR0_DESC01")
Local cDscMotivo := CriaVar("FR0_DESC01")
Local nValReceb  := 0.00
Local cDocCancel := CriaVar("FRB_DOCCAN")
Local dDataCanc  := CriaVar("FRB_DATCAN")
Local cHoraCanc  := CriaVar("FRB_HORCAN")
Local aPicture   := Array(8)
Local oCbxParc
Local oDlg
Local nOpc 		 := 0

aPicture[1] := PesqPict("FRB","FRB_STATUS", TamSX3("FRB_STATUS")[1])
aPicture[2] := PesqPict("FRB","FRB_MOTIVO", TamSX3("FRB_MOTIVO")[1])
aPicture[3] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[4] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[5] := PesqPict("FRB","FRB_VALREC", TamSX3("FRB_VALREC")[1])
aPicture[6] := PesqPict("FRB","FRB_DOCCAN", TamSX3("FRB_DOCCAN")[1])
aPicture[7] := PesqPict("FRB","FRB_DATCAN", TamSX3("FRB_DATCAN")[1])
aPicture[8] := PesqPict("FRB","FRB_HORCAN", TamSX3("FRB_HORCAN")[1])

dbSelectArea("FRB")

cCodStatus := FRB->FRB_STATUS
cCodMotivo := FRB->FRB_MOTIVO

cDscStatus := fA098DscSta(FRB->FRB_STATUS)
cDscMotivo := fA098DscMot(FRB->FRB_MOTIVO)
nValReceb  := FRB->FRB_VALREC
cDocCancel := FRB->FRB_DOCCAN
dDataCanc  := FRB->FRB_DATCAN
cHoraCanc  := FRB->FRB_HORCAN

DEFINE MSDIALOG oDlg TITLE STR0010 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL // "Manutenção dos Títulos"

	@ 027,010 SAY STR0011	PIXEL OF oDlg COLOR CLR_HBLUE // "Código Status"
	@ 025,070 MSGET cCodStatus  F3 "FR0EQ2" Picture aPicture[1] SIZE 30,08  WHEN .F. PIXEL OF oDlg
	@ 025,120 MSGET cDscStatus      	 	Picture aPicture[2] SIZE 170,08	WHEN .F. PIXEL OF oDlg

	If cCodStatus $ "01|02"
		@ 042,010 SAY STR0012	PIXEL OF oDlg
	Else
		@ 042,010 SAY STR0012	PIXEL OF oDlg COLOR CLR_HBLUE // "Motivo Cancel.
	EndIf
	@ 040,070 MSGET cCodMotivo	F3 "FR0EQ3" Picture aPicture[3] SIZE 30,08  WHEN .F. PIXEL OF oDlg
	@ 040,120 MSGET cDscMotivo		     	Picture aPicture[4] SIZE 170,08	WHEN .F. PIXEL OF oDlg

	@ 057,010 SAY STR0013	PIXEL OF oDlg 					  // "Valor Recebido".
	@ 055,070 MSGET nValReceb			    Picture aPicture[5] SIZE 70,08  WHEN .F. PIXEL OF oDlg

	@ 072,010 SAY STR0014	PIXEL OF oDlg				  // "Código Cancel."
	@ 070,070 MSGET cDocCancel			 	Picture aPicture[6] SIZE 50,08	WHEN .F. PIXEL OF oDlg

	@ 087,010 SAY STR0015	PIXEL OF oDlg				  // "Código Cancel."
	@ 085,070 MSGET dDataCanc			 Picture aPicture[7] 	SIZE 50,08  WHEN .F. PIXEL OF oDlg

	@ 102,010 SAY STR0016	PIXEL OF oDlg				  // "Hora Cancel."
	@ 100,070 MSGET cHoraCanc			 Picture aPicture[8] 	SIZE 30,08  WHEN .F. PIXEL OF oDlg

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(fa098Ok(),(nOpca := 1,oDlg:End()),NIL)},{|| nOpca := 2,oDlg:End()})

RestArea(aArea)
Return

Function fA098dValid()
Return .T.

Function fA098Ok()
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Grv02³ Autor ³ Jose Lucas - SI5910   ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar Status e Motivo de aprovação.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Grv02(cCodStatus,cCodMotivo)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Grv02(cCodStatus,cCodMotivo)
Local aArea     := GetArea()
Local lBxCrAuto := If(mv_par06==1,.T.,.F.)	//Baixa Automática do Titulo no Contas a Receber...
Local aDadosTit := {}
Local aBaixa    := {}
Local nValorBX  := 0.00

If lBxCrAuto
   	SE1->(dbSetOrder(1))
   	If SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPCAR))

		// Titulo com saldo zero, já foi baixa pelo Contas a Receber, Baixa Automatica ou Recibo.
		If SE1->E1_SALDO > 0 .and. Empty(SE1->E1_BAIXA)

			//Guarda dados do titulo principal
			aDadosTit := {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE,;
			SE1->E1_LOJA, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, SE1->E1_EMISSAO, SE1->E1_NOMCLI }

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Baixa do titulo tipo "CC"...                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc(STR0017+aDadosTit[1]+"/"+aDadosTit[2])
			aBaixa	:=	{}
			nValorBX := SE1->E1_VALOR
			AADD( aBaixa, { "E1_PREFIXO" 	, SE1->E1_PREFIXO		, Nil } )	// 01
			AADD( aBaixa, { "E1_NUM"     	, SE1->E1_NUM		 	, Nil } )	// 02
			AADD( aBaixa, { "E1_PARCELA" 	, SE1->E1_PARCELA		, Nil } )	// 03
			AADD( aBaixa, { "E1_TIPO"    	, SE1->E1_TIPO			, Nil } )	// 04
			AADD( aBaixa, { "E1_CLIENTE"	, SE1->E1_CLIENTE		, Nil } )	// 05
			AADD( aBaixa, { "E1_LOJA"    	, SE1->E1_LOJA			, Nil } )	// 06
			AADD( aBaixa, { "E1_VALOR"    	, nValorBX				, Nil } )	// 06
			AADD( aBaixa, { "AUTMOTBX"  	, "NOR"					, Nil } )	// 07
			AADD( aBaixa, { "AUTBANCO"  	, ""					, Nil } )	// 08
			AADD( aBaixa, { "AUTAGENCIA"  	, ""					, Nil } )	// 09
			AADD( aBaixa, { "AUTCONTA"  	, ""					, Nil } )	// 10
			AADD( aBaixa, { "AUTDTBAIXA"	, SE1->E1_EMISSAO		, Nil } )	// 11
			AADD( aBaixa, { "AUTHIST"   	, STR0018				, Nil } )	// 12
			AADD( aBaixa, { "AUTDESCONT" 	, 0						, Nil } )	// 13
			AADD( aBaixa, { "AUTMULTA"	 	, 0						, Nil } )	// 14
			AADD( aBaixa, { "AUTJUROS" 		, 0						, Nil } )	// 15
			AADD( aBaixa, { "AUTOUTGAS" 	, 0						, Nil } )	// 16
			AADD( aBaixa, { "AUTVLRPG"  	, 0        				, Nil } )	// 17
			AADD( aBaixa, { "AUTVLRME"  	, 0						, Nil } )	// 18
			AADD( aBaixa, { "AUTCHEQUE"  	, ""					, Nil } )	// 19

			lMsErroAuto := .F.
			MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			EndIf
		EndIf
    EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o Status 02-Pagamento Aprovado na tabela de controle - FRB.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("FRB",.F.)
FRB_STATUS := cCodStatus
FRB_VALREC := FRB_VALOR
MsUnLock()

RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Grv03³ Autor ³ Jose Lucas - SI5910   ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar Status, Motivo de aprovação e reverter substituicao.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Grv03(cCodStatus,cCodMotivo,nValReceb,cDocCancel,dDataCanc,cHoraCanc)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Grv03(cCodStatus,cCodMotivo,nValReceb,cDocCancel,dDataCanc,cHoraCanc)
Local aArea      := GetArea()
Local aDadosTit  := {}
Local aBaixa     := {}
Local nValorBX   := 0.00
Local dDataBX    := ctod("  /  /  ")
Local nValorSe1  := 0.00
local nReg       := FRB->(Recno())
Local nOpc 		 := 5
Local lSubst	 := .T.
Local lSubsSuces := .F.
Local lEdita     := GetNewPar("MV_EDITCC","1") == "2"
Local nC         := 0
Local aCampos    := {}
Local lAtuSldNat := .T.
Local aGravaAFT  := {}
Local cPadrao    := "502"
Local cArquivo   := ""
Local nHdlPrv    := 0
Local nTotal     := 0.00
Local lPadrao    := If(mv_par01==1,.T.,.F.)	//Lancamento Contabil on line...
//Local lAglutina  := If(mv_par01==2,.T.,.F.)	//Aglutina lancamentos...
Local lDigita    := If(mv_par02==1,.T.,.F.)	//Mostra lancamentos...
Local lBxCrAuto := If(mv_par06==1,.T.,.F.)	//Baixa Automática do Titulo no Contas a Receber...
Local aAreaFRB 	 := ""
Local cPrefixo   := ""
Local cNum       := ""
Local cTipoCC    := ""
Local cCliente   := ""
Local cLoja      := ""
Local cParcela 	 := GetMV("MV_1DUP")
Local aDiario    := {}
Local aFlagCTB   := {}
Local lPmsInt	:= IsIntegTop(,.T.)
nValorSe1 := nValReceb

If lBxCrAuto
   	SE1->(dbSetOrder(1))
   	If SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPO))

		// Titulo com saldo zero, já foi baixa pelo Contas a Receber, Baixa Automatica ou Recibo.
		If SE1->E1_SALDO > 0 .and. Empty(SE1->E1_BAIXA)

			//Guarda dados do titulo principal
			aDadosTit := {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE,;
			SE1->E1_LOJA, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, SE1->E1_EMISSAO, SE1->E1_NOMCLI }

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Baixa do titulo tipo "CC"...                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc(STR0017+aDadosTit[1]+"/"+aDadosTit[2])
			aBaixa	:=	{}
			nValorBX := nValReceb
			dDataBX  := SE1->E1_EMISSAO
			AADD( aBaixa, { "E1_PREFIXO" 	, SE1->E1_PREFIXO		, Nil } )	// 01
			AADD( aBaixa, { "E1_NUM"     	, SE1->E1_NUM		 	, Nil } )	// 02
			AADD( aBaixa, { "E1_PARCELA" 	, SE1->E1_PARCELA		, Nil } )	// 03
			AADD( aBaixa, { "E1_TIPO"    	, SE1->E1_TIPO			, Nil } )	// 04
			AADD( aBaixa, { "E1_CLIENTE"	, SE1->E1_CLIENTE		, Nil } )	// 05
			AADD( aBaixa, { "E1_LOJA"    	, SE1->E1_LOJA			, Nil } )	// 06
			AADD( aBaixa, { "E1_VALOR"    	, nValorBX				, Nil } )	// 06
			AADD( aBaixa, { "AUTMOTBX"  	, "NOR"					, Nil } )	// 07
			AADD( aBaixa, { "AUTBANCO"  	, ""					, Nil } )	// 08
			AADD( aBaixa, { "AUTAGENCIA"  	, ""					, Nil } )	// 09
			AADD( aBaixa, { "AUTCONTA"  	, ""					, Nil } )	// 10
			AADD( aBaixa, { "AUTDTBAIXA"	, dDataBX				, Nil } )	// 11
			AADD( aBaixa, { "AUTHIST"   	, STR0018				, Nil } )	// 12
			AADD( aBaixa, { "AUTDESCONT" 	, 0						, Nil } )	// 13
			AADD( aBaixa, { "AUTMULTA"	 	, 0						, Nil } )	// 14
			AADD( aBaixa, { "AUTJUROS" 		, 0						, Nil } )	// 15
			AADD( aBaixa, { "AUTOUTGAS" 	, 0						, Nil } )	// 16
			AADD( aBaixa, { "AUTVLRPG"  	, 0        				, Nil } )	// 17
			AADD( aBaixa, { "AUTVLRME"  	, 0						, Nil } )	// 18
			AADD( aBaixa, { "AUTCHEQUE"  	, ""					, Nil } )	// 19

			lMsErroAuto := .F.
			MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			EndIf
		EndIf
    EndIf
EndIf

If (FRB->FRB_VALOR - nValReceb) > 0.00
	nValorSe1 := FRB->FRB_VALOR - nValReceb
   	SE1->(dbSetOrder(1))
   	If SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPO))
		aCampos := {}
	    For nC := 1 To SE1->(FCount())
	    	If SE1->(FieldName(nC)) == "E1_PARCELA"
		    	AADD(aCampos,{SE1->(FieldName(nC)),cParcela})
            ElseIf SE1->(FieldName(nC)) == "E1_TIPO"
		    	AADD(aCampos,{SE1->(FieldName(nC)),FRB->FRB_TIPO})
			Else
	    		AADD(aCampos,{SE1->(FieldName(nC)),SE1->(FieldGet(nC))})
	    	EndIf
	    Next nC

	   	RecLock("SE1",.T.)
	   	For nC := 1 To Len(aCampos)
	   		FieldPut(nC,aCampos[nC,2])
 	   	Next nC
		If cPaisLoc == "EQU"
			E1_PREFIXO  := FRB->FRB_PREORI
    	    E1_NUM		:= FRB->FRB_NUMORI
        	E1_PARCELA  := FRB->FRB_PARORI
			E1_TIPO     := FRB->FRB_TIPORI 	//If(AllTrim(FRB->FRB_TIPO)=="CC","NF",FRB->FRB_TIPO)
		EndIf
		E1_VALOR 	:= nValorSE1
		E1_SALDO 	:= SE1->E1_VALOR
	  	E1_VALLIQ   := SE1->E1_VALOR
	  	E1_BAIXA    := CTOD("  /  /  ")
	  	MsUnLock()

	   	SE1->(dbSetOrder(1))
   		SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPCAR))
	 	nOpc := 5	 		//Exclusao
		lSubsSuces := .T.
	EndIf
	If lSubsSuces

		If ( lPadrao )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Lancamento Contabil                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nHdlPrv := HeadProva( cLote,;
	       		    		      "FINA040" /*cPrograma*/,;
		       		      		  Substr(cUsuario,7,6),;
	           					  @cArquivo )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000001")

		If ! lF098Auto .and. ( lPadrao )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Prepara Lancamento Contabil                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
			Endif
			nTotal += DetProva( nHdlPrv,;
		        	            cPadrao,;
		            	        "FINA040" /*cPrograma*/,;
		                	    cLote,;
		   	                	/*nLinha*/,;
			       	            /*lExecuta*/,;
		    	                /*cCriterio*/,;
		   		                /*lRateio*/,;
		   	                    /*cChaveBusca*/,;
		                        /*aCT5*/,;
		                        /*lPosiciona*/,;
		                        @aFlagCTB,;
		                        /*aTabRecOri*/,;
		                        /*aDadosProva*/ )

			dbSelectArea("SE1")
			dbSetOrder(1)
			If dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPO)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizacao dos dados do Modulo SIGAPMS    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If IntePms().AND. !lPmsInt
					PmsWriteFI(2,"SE1")	//Estorno
					PmsWriteFI(3,"SE1")	//Exclusao
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama a integracao com o SIGAPCO antes de apagar o titulo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoDetLan("000001","01","FINA040",.T.)

				If ExistBlock("F098SUBS")
					ExecBlock("F098SUBS",.F.,.F.)
				Endif
   				If lAtuSldNat
					AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "+")
				Endif
			Endif
		Else
			BEGIN TRANSACTION
			If ( lPadrao )
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA040",cLote)
			EndIf
			// Caso tenha integracao com PMS para alimentar tabela AFT
			If IntePms().AND. !lPmsInt
				If PmsVerAFT()
		  			aGravaAFT := PmsIncAFT()
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga o lacamento gerado para a conta orcamentaria - SIGAPCO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000001","01","FINA040",.T.)

			If lAtuSldNat
				AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "+")
			Endif

			//Se o registro não foi gerado através do botão de integração do PMS na tela de titulos a receber do financeiro
			//Grava o registro na AFT com os dados obtidos na rotina PMSIncAFT()
			If Len(aGravaAFT) > 0 .And. (!AFT->(dbSeek(aGravaAFT[1]+aGravaAFT[6]+aGravaAFT[7]+aGravaAFT[8]+aGravaAFT[9]+aGravaAFT[10]+aGravaAFT[11]+aGravaAFT[2]+aGravaAFT[3]+aGravaAFT[5])))
				RecLock("AFT",.F.)
				DbDelete()
				MsUnLock()
			EndIf
			END TRANSACTION
    	EndIf

		If ( lPadrao )
			RodaProva(nHdlPrv,nTotal)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lancamento Contabil					    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lDigita:=IIF(mv_par01==1,.T.,.F.)
			If UsaSeqCor()
 				aDiario := {}
				aDiario := {{"SE1",SE1->(recno()),SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"}}
			Else
				aDiario := {}
			EndIf
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,aDiario)
		EndIf
		//Excluir os titulos do Tipo == "CC" gravados na tabela SE1.
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM))
   			While !SE1->(Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO == FRB->FRB_PREFIX .and.;
     			SE1->E1_NUM == FRB->FRB_NUM
    			If AllTrim(SE1->E1_TIPO) == AllTrim(FRB->FRB_TIPCAR) .AND. !Empty(SE1->E1_BAIXA)
		   			RecLock("SE1",.F.)
   					DbDelete()
   					MsUnLock()
   				EndIf
   				SE1->(dbSkip())
   			End
		EndIf
		dbSelectArea("FRB")
		aAreaFRB := GetArea()
		cPrefixo := FRB->FRB_PREFIX
		cNum     := FRB->FRB_NUM
		cTipoCC  := FRB->FRB_TIPCAR
		cCliente := FRB->FRB_CLIENTE
		cLoja    := FRB->FRB_LOJA

		FRB->(dbSetOrder(1))
   		If FRB->(dbSeek(xFilial("FRB")+cPrefixo+cNum))
   			While !FRB->(Eof()) .and. FRB->FRB_PREFIX == cPrefixo .and. FRB->FRB_NUM == cNum
	        	If FRB->FRB_CLIENT == cCliente .and. FRB->FRB_LOJA == cLoja .and. FRB->FRB_TIPCAR == cTipoCC
					//Alterar o codigo do Status e Motivo Incluir registros na tabela de Controle de Títulos a pagar por Cartão de Credito
					RecLock("FRB",.F.)
					FRB_STATUS := cCodStatus
					FRB_MOTIVO := cCodMotivo
					FRB_DOCCAN := cDocCancel
					FRB_DATCAN := dDataCanc
					FRB_HORCAN := cHoraCanc
					FRB_VALREC := nValReceb
					MsUnLock()
				EndIf
    			FRB->(dbSkip())
    		End
    	EndIf
    	RestArea(aAreaFRB)
    EndIf
EndIf

RestArea( aArea )
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Grv04³ Autor ³ Jose Lucas - SI5910   ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar Status e Reverter a substitição.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Grv04(cCodStatus,cCodMotivo)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Grv04(cCodStatus,cCodMotivo,nValReceb,cDocCancel,dDataCanc,cHoraCanc)
Local aArea 	 := FRB->(GetArea())
Local nValorSe1  := 0.00
Local nOpc 		 := 5
Local lSubsSuces := .F.
Local nC         := 0
Local aCampos    := {}
Local lAtuSldNat := .T.
Local aGravaAFT  := {}
Local cPadrao    := "502"
Local cArquivo   := ""
Local nHdlPrv    := 0
Local nTotal     := 0.00
Local lPadrao    := If(mv_par01==1,.T.,.F.)	//Lancamento Contabil on line...
//Local lAglutina  := If(mv_par01==2,.T.,.F.)	//Aglutina lancamentos...
Local lDigita    := If(mv_par02==1,.T.,.F.)	//Mostra lancamentos...
Local aAreaFRB 	 := ""
Local cPrefixo   := ""
Local cNum       := ""
Local cTipoCC    := ""
Local cCliente   := ""
Local cLoja      := ""
Local cParcela 	 := GetMV("MV_1DUP")
Local aDiario    := {}
Local aFlagCTB   := {}
Local lPmsInt	:= IsIntegTop(,.T.)
If (FRB->FRB_VALOR - nValorSe1) > 0.00
	nValorSe1 := FRB->FRB_VALOR - nValorSe1
   	SE1->(dbSetOrder(1))
   	If SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPCAR))
		aCampos := {}
	    For nC := 1 To SE1->(FCount())
	    	If SE1->(FieldName(nC)) == "E1_PARCELA"
		    	AADD(aCampos,{SE1->(FieldName(nC)),cParcela})
            ElseIf SE1->(FieldName(nC)) == "E1_TIPO"
		    	AADD(aCampos,{SE1->(FieldName(nC)),FRB->FRB_TIPO})
			Else
	    		AADD(aCampos,{SE1->(FieldName(nC)),SE1->(FieldGet(nC))})
	    	EndIf
	    Next nC

	   	RecLock("SE1",.T.)
	   	For nC := 1 To Len(aCampos)
	   		FieldPut(nC,aCampos[nC,2])
	   	Next nC
	   	If cPaisLoc == "EQU"
			E1_PREFIXO  := FRB->FRB_PREORI
    	    E1_NUM		:= FRB->FRB_NUMORI
        	E1_PARCELA  := FRB->FRB_PARORI
			E1_TIPO     := FRB->FRB_TIPORI 	//If(AllTrim(FRC->FRC_TIPO)=="CC","NF",FRC->FRC_TIPO)
		EndIf
	   	E1_TIPO     := If(AllTrim(FRB->FRB_TIPO)=="CC","NF",FRB->FRB_TIPO)
	   	E1_VALOR 	:= nValorSe1
	   	E1_SALDO 	:= SE1->E1_VALOR
	   	E1_VALLIQ   := SE1->E1_VALOR
        E1_BAIXA    := CTOD("  /  /  ")
	   	E1_SERIE    := SE1->E1_PREFIXO
	   	E1_HIST     := ""
	    MsUnLock()

	   	SE1->(dbSetOrder(1))
   		SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPCAR))
	 	nOpc := 5	 		//Exclusao
		lSubsSuces := .T.
	EndIf
	If lSubsSuces

		If ( lPadrao )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Lancamento Contabil                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nHdlPrv := HeadProva( cLote,;
	       		    		      "FINA040" /*cPrograma*/,;
		       		      		  Substr(cUsuario,7,6),;
	           					  @cArquivo )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000001")

		If ! lF098Auto .and. ( lPadrao )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Prepara Lancamento Contabil                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
			Endif
			nTotal += DetProva( nHdlPrv,;
		        	            cPadrao,;
		            	        "FINA040" /*cPrograma*/,;
		                	    cLote,;
		   	                	/*nLinha*/,;
			       	            /*lExecuta*/,;
		    	                /*cCriterio*/,;
		   		                /*lRateio*/,;
		   	                    /*cChaveBusca*/,;
		                        /*aCT5*/,;
		                        /*lPosiciona*/,;
		                        @aFlagCTB,;
		                        /*aTabRecOri*/,;
		                        /*aDadosProva*/ )

			dbSelectArea("SE1")
			dbSetOrder(1)
			If dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM+FRB->FRB_PARCEL+FRB->FRB_TIPO)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizacao dos dados do Modulo SIGAPMS    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If IntePms().AND. !lPmsInt
					PmsWriteFI(2,"SE1")	//Estorno
					PmsWriteFI(3,"SE1")	//Exclusao
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama a integracao com o SIGAPCO antes de apagar o titulo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoDetLan("000001","01","FINA040",.T.)

				If ExistBlock("F098SUBS")
					ExecBlock("F098SUBS",.F.,.F.)
				Endif
   				If lAtuSldNat
					AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "+")
				Endif
			Endif
		Else
			BEGIN TRANSACTION
			If ( lPadrao )
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA040",cLote)
			EndIf
			// Caso tenha integracao com PMS para alimentar tabela AFT
			If IntePms().AND. !lPmsInt
				If PmsVerAFT()
		  			aGravaAFT := PmsIncAFT()
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga o lacamento gerado para a conta orcamentaria - SIGAPCO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000001","01","FINA040",.T.)

			If lAtuSldNat
				AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "+")
			Endif

			//Se o registro não foi gerado através do botão de integração do PMS na tela de titulos a receber do financeiro
			//Grava o registro na AFT com os dados obtidos na rotina PMSIncAFT()
			If Len(aGravaAFT) > 0 .And. (!AFT->(dbSeek(aGravaAFT[1]+aGravaAFT[6]+aGravaAFT[7]+aGravaAFT[8]+aGravaAFT[9]+aGravaAFT[10]+aGravaAFT[11]+aGravaAFT[2]+aGravaAFT[3]+aGravaAFT[5])))
				RecLock("AFT",.F.)
				DbDelete()
				MsUnLock()
			EndIf
			END TRANSACTION
    	EndIf

		If ( lPadrao )
			RodaProva(nHdlPrv,nTotal)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lancamento Contabil					    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lDigita:=IIF(mv_par01==1,.T.,.F.)
			If UsaSeqCor()
 				aDiario := {}
				aDiario := {{"SE1",SE1->(recno()),SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"}}
			Else
				aDiario := {}
			EndIf
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,aDiario)
		EndIf
		//Excluir os titulos do Tipo == "CC" gravados na tabela SE1.
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial("SE1")+FRB->FRB_PREFIX+FRB->FRB_NUM))
   			While !SE1->(Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO == FRB->FRB_PREFIX .and.;
     			SE1->E1_NUM == FRB->FRB_NUM
    			If AllTrim(SE1->E1_TIPO) == AllTrim(FRB->FRB_TIPCAR)
		   			RecLock("SE1",.F.)
   					DbDelete()
   					MsUnLock()
   				EndIf
   				SE1->(dbSkip())
   			End
		EndIf
		dbSelectArea("FRB")
		aAreaFRB := GetArea()
		cPrefixo := FRB->FRB_PREFIX
		cNum     := FRB->FRB_NUM
		cTipoCC  := FRB->FRB_TIPCAR
		cCliente := FRB->FRB_CLIENTE
		cLoja    := FRB->FRB_LOJA

		FRB->(dbSetOrder(1))
   		If FRB->(dbSeek(xFilial("FRB")+cPrefixo+cNum))
   			While !FRB->(Eof()) .and. FRB->FRB_PREFIX == cPrefixo .and. FRB->FRB_NUM == cNum
	        	If FRB->FRB_CLIENT == cCliente .and. FRB->FRB_LOJA == cLoja .and. FRB->FRB_TIPCAR == cTipoCC
					//Alterar o codigo do Status e Motivo Incluir registros na tabela de Controle de Títulos a pagar por Cartão de Credito
					RecLock("FRB",.F.)
					FRB_STATUS := cCodStatus
					FRB_MOTIVO := cCodMotivo
					FRB_DOCCAN := cDocCancel
					FRB_DATCAN := dDataCanc
					FRB_HORCAN := cHoraCanc
					FRB_VALREC := nValReceb
					MsUnLock()
				EndIf
    			FRB->(dbSkip())
    		End
    	EndIf
    	RestArea(aAreaFRB)
    EndIf
EndIf

RestArea( aArea )
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Status ³ Autor ³ Jose Lucas - SI5910 ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar Status e Reverter a substitição.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Status(cCodStatus,cCodMotivo,,nValReceb,dDataCanc,cHoraCanc) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Status(cCodStatus,cDscStatus,nValReceb,dDataCanc,cHoraCanc)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ2"+Space(nTamTabela-3)
Local lResult 	 := .T.

cCodStatus := cCodStatus+Space(nTamChave-Len(cCodStatus))

FR0->(dbSetOrder(1))
If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodStatus,1,nTamChave)))

	cDscStatus := FR0->FR0_DESC01

	If AllTrim(cCodStatus) == "02"			//Pago Aprovado...
		nValReceb := FRB->FRB_VALOR
	ElseIf AllTrim(cCodStatus) $ "03|04"	//Rejeição Parcial ou Total...
		nValReceb := 0.00
		dDataCanc  := dDataBase
		cHoraCanc  := Subs(Time(),1,5)
	EndIf

Else
   	MsgAlert(STR0022,STR0020)	//"Estatus de pago invalido !","Atención")
   	lResult := .F.
EndIf

RestArea(aArea)
Return( lResult )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Motivo ³ Autor ³ Jose Lucas - SI5910 ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar Status e Reverter a substitição.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Motivo(cCodStatus,cCodMotivo,cCodStatus)		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fA098Motivo(cCodMotivo,cDscMotivo,cCodStatus)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ3"+Space(nTamTabela-3)
Local lResult 	 := .T.

If !Empty(cCodMotivo)
	If AllTrim(cCodStatus) $ "01|02"
    	MsgAlert(STR0023,STR0020) // "Ingrese el motivo solamente cuando Status diferente de 01 y 02 !","Atención")
    	lResult := .F.
	EndIf
Else
	If ! AllTrim(cCodStatus) $ "03|04"
       	lResult := .T.
		RestArea(aArea)
		Return( lResult )
	EndIf
EndIf

If lResult

	cCodMotivo := cCodMotivo+Space(nTamChave-Len(cCodMotivo))

	FR0->(dbSetOrder(1))
	If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodMotivo,1,nTamChave)))
   		cDscMotivo := FR0->FR0_DESC01
	Else
   		MsgAlert(STR0024,STR0020)	//"Motivo de rechazo inválido !","Atención")
   		lResult := .F.
	EndIf
EndIf

RestArea(aArea)
Return( lResult )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098ValRec ³ Autor ³ Jose Lucas - SI5910 ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar Status e Reverter a substitição.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098ValRec(nValReceb,cCodStatus)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa098ValRec(nValReceb,cCodStatus)
Local aArea 	 := GetArea()
Local lResult 	 := .T.

If AllTrim(cCodStatus) == "03"
	If nValReceb >= FRB->FRB_VALOR	//Pago Parcial
   		MsgAlert(STR0025,STR0020)	//"Valor recebido mayor que el importe del título !","Atención")
   		lResult := .F.
   	ElseIf nValReceb == 0
   		MsgAlert(STR0026,STR0020)	//"Ingrese el valor parcial recibido !","Atención")
   		lResult := .F.
   	EndIf
EndIf

RestArea(aArea)
Return( lResult )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Date ³ Autor ³ Jose Lucas - SI5910   ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar a data de cancelamento...						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Date()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa098Date(dDataCanc)
Local aArea 	 := GetArea()
Local lResult 	 := .T.

If dDataCanc < FRB->FRB_DATTEF
	MsgAlert(STR0027,STR0020)	//"Fecha de anulación menor que fecha del título !","Atención")
	lResult := .F.
EndIf

RestArea(aArea)
Return( lResult )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098DscSta ³ Autor ³ Jose Lucas - SI5910 ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar a descrição da Situação de Pagamento.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ cDscSatus := fA098DscSat(cCodStatus)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa098DscSta(cCodStatus)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ2"+Space(nTamTabela-3)
Local cDescri    := ""

cCodStatus := cCodStatus+Space(nTamChave-Len(cCodStatus))

FRB->(dbSetOrder(1))
If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodStatus,1,nTamChave)))
	cDescri := FR0->FR0_DESC01
EndIf

RestArea(aArea)
Return( cDescri )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098DscMot ³ Autor ³ Jose Lucas - SI5910 ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar a descrição do Motivo de Rejeição.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ cDscMotivo := fA098DscMot(cCodMotivo)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa098DscMot(cCodMotivo)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ3"+Space(nTamTabela-3)
Local cDescri    := ""

cCodMotivo := cCodMotivo+Space(nTamChave-Len(cCodMotivo))

FRB->(dbSetOrder(1))
If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodMotivo,1,nTamChave)))
	cDescri := FR0->FR0_DESC01
EndIf

RestArea(aArea)
Return( cDescri )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fA098Doc    ³ Autor ³ Jose Lucas - SI5910 ³ Data ³ 25/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar o codigo do documento para rejeicao.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA098Doc(cCodStatus)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA098													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa098Doc(cDocCancel,cCodStatus)
Local aArea   := GetArea()
Local lResult := .T.

If AllTrim(cCodStatus) $ "03|04" .and. Empty(cDocCancel)
	MsgAlert(STR0028,STR0020)	//"Código de rechazo es obligatório !","Atención")
	lResult := .F.
EndIf

RestArea(aArea)
Return( lResult )
