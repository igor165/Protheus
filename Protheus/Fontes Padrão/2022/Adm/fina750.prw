#INCLUDE "fina750.ch"
#INCLUDE "PROTHEUS.CH"

Static lF050ROT     := ExistBlock("F050ROT")
Static __lExisFKD	:= .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA750	³ Autor ³ Claudio D. de Souza   ³ Data ³ 12/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela unica do contas a pagar, que permitira ao usuario     ³±±
±±³          ³ manipular as opcoes distribuidas nos menus de contas a Pag.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA750

Local cFiltroB  := ""
Local lF750FILB := ExistBlock("F750FILB")

PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := STR0012 //"Contas a Pagar"
PRIVATE lPrim750  := .T. //Variável para verificar primeira execução da rotina

// Ponto de entrada para pre-validar os dados a serem exibidos.
If ExistBlock("F750BROW")
	ExecBlock("F750BROW",.f.,.f.)
Endif

// Ponto de entrada para manipular os tíulos da tabela SE2 há ser exibido Mbrowse.
If lF750FILB
	cFiltroB := ExecBlock("F750FILB",.F.,.F.)
EndIf

//Endereca a funcao de BROWSE
mBrowse(6, 1, 22, 75, "SE2",,,,,, Fa040Legenda("SE2"),,,,,,,,If(lF750FILB, cFiltroB, Nil))

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³28/11/06 ³±±
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

Local aRot080 := {}
Local aRot050 := {}
Local aRot090 := {}
Local aRot240 := {}
Local aRot241 := {}
Local aRot290 := {}
Local aRot390 := {}
Local aRot580 := {}
Local aRot426 := {}
Local aRotina := {}
Local lAgrBot := GetNewPar("MV_BOTFUNP",.F.)	//Agrupa as Baixas e Borderos em sub-menus.
Local aRot080A:= {}
Local aRot240A:= {}
Local lIntSJURI  := SuperGetMV("MV_JURXFIN",,.F.) //Integração com SIGAPFS
Local cTipoLib:= SuperGetMV( "MV_FINCTAL", .F., "1" )	//Parâmetro de ativação de controle de Alçadas

aRot080 :=	{	{ STR0014, "Fin750080" , 0 , 4},; //"Baixar"
				{ STR0015, "Fin750080" , 0 , 4},; //"Lote"
				{ STR0016, "Fin750080" , 0 , 5},; //"Canc Baixa"
				{ STR0017, "Fin750080" , 0 , 5,53}} //"Excluir Baixa"

//Passado como parametro a posicao da opcao dentro da arotina
aRot050 :=	{	{ STR0018, "Fin750050", 0 , 3},; //"Incluir"
				{ STR0019, "Fin750050", 0 , 4},;  //"Alterar"
				{ STR0020, "Fin750050", 0 , 5},; //"Excluir"
				{ STR0021, "Fin750050", 0 , 6} } //"Substituir"

If CtbInUse()
	Aadd(aRot050, { STR0022,"Fin750050", 0 , 2}) //"Visualizar Rateio"
Endif

If FindFunction("F050CMNT") .and. MV_MULNATP
	aAdd( aRot050, { STR0043 ,"F050CMNT()", 0 , 2})	//"Consulta Rateio Multi Naturezas - Emissão"
Endif

If cPaisLoc == "BRA"
	Aadd(aRot050, {STR0045, {|| FINCRET('SE2') }, 0, 2}) // "Consulta de Retenções"
Endif

// Valores acessórios.
If Type('cFilAnt') != "U"
	aAdd(aRot050, { STR0046, "FINA050VA", 0, 4}) // "Valores Acessórios"
EndIf

If cPaisLoc == "BRA"
	aAdd( aRot050, { STR0047,"FINA986('SE2',.T.)",0,4}) //"Complemento do ti­tulo"
EndIf

If FindFunction("FinWizFac")
	aAdd( aRot050, { STR0050,"FinWizFac('SE2')",0, 4, 2, .F.}) //"Facilitador"
Endif	

// Ponto de entrada para inclusão de novos itens no menu aRot050.
If lF050ROT
	aRotinaNew := ExecBlock("F050ROT", .F., .F., aRot050)
	If (ValType(aRotinaNew) == "A")
		aRot050 := aClone(aRotinaNew)
	EndIf
EndIf

aRot090 :=	{	{ STR0023, "Fin750090"   ,0,1},; //"Parâmetros"
				{ STR0024, "Fin750090"   ,0,3} } //"Automática"

If cPaisLoc != "BRA"
	Aadd(aRot090, { STR0025,"Fin750090", 0 , 2}) //"Cancela Chq"
EndIf

aRot240 :=	{	{ STR0026, "Fin750240",0,3},; //"Borderô"
				{ STR0027, "Fin750240",0,3} } //"Cancelar"

aRot241 :=	{	{ STR0039, "Fin750241",0,3},; //"Borderô Imp."
				{ STR0027, "Fin750241",0,3} } //"Cancelar"

aRot290 :=	{	{ STR0028, "Fin750290",0,3},; //"Selecionar"
				{ STR0027, "Fin750290",0,6} } //"Cancelar"

aRot340 :=	{	{ STR0028, "Fin750340",0,4},; //"Selecionar"
				{ STR0027, "Fin750340",0,6},; //"Cancelar"
				{ STR0037, "Fin750340",0,6} } //"Estornar"

aRot390 :=	{	{ STR0029, "Fin750390",0,2},; //"Chq s/Tit"
				{ STR0030, "Fin750390",0,2},; //"Avulsos"
				{ STR0031, "Fin750390",0,2},; //"Redeposito"
				{ STR0027, "Fin750390",0,3} } //"Cancelar"

If cTipoLib == "1"
	aRot580 :=	{	{ STR0032, "Fin750580(2)",0,2},; //"Manual"
					{ STR0033, "Fin750580(3)",0,2},; //"Automatica"
					{ STR0027, "Fin750580(4)",0,2} } //"Cancelar"
Else
	aRot580 :=	{	{ STR0032, "Fin750580(3)",0,2},; //"Manual"
					{ STR0037, "Fin750580(4)",0,2} } //"Estornar"
EndIf

aRot426 :=	{	{ STR0034, "Fina420()",0,3},; //"Gerar Arquivo"
				{ STR0035, "Fina430()",0,3}	 } //"Receber Arquivo"

If lAgrBot
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Agrupa as baixas em sub-menus.							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRot080A :=	{	{ STR0003,aRot080,0,4},;	//"Bai&xa Manual"
					{ STR0004,aRot090,0,4}}		//"Baixa &Autom."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Agrupa os borderos em sub-menus.							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRot240A :=	{	{ STR0026,aRot240,0,3},; 	//"Borderô"
					{ STR0039,aRot241,0,1} } 	//"Borderô Imp."
EndIf
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
aAdd( aRotina,	{ STR0001, "AxPesqui" , 0 , 1,,.F.})  //"Pesquisar"
aAdd( aRotina,	{ STR0013,"Fa050Visua", 0 , 2})  //"Visualizar"
aAdd( aRotina,	{ STR0036, aRot050, 0 , 3}) //"Contas a Pagar"

If !lAgrBot
	aAdd( aRotina,	{ STR0003,aRot080, 0 , 5})  //"Baixa &Manual"
	aAdd( aRotina,	{ STR0004,aRot090, 0 , 4}) //"Baixa &Autom."
	aAdd( aRotina,	{ STR0005,aRot240, 0 , 5}) //"&Borderô"
	aAdd( aRotina,	{ STR0038,aRot241, 0 , 5}) //"Bo&rderô Imp."
Else
	aAdd( aRotina,	{ STR0040,aRot080A, 0 , 3}) //"Bai&xas"
	aAdd( aRotina,	{ STR0041,aRot240A, 0 , 5}) //"&Borderôs"
EndIf

aAdd( aRotina,	{ STR0006,aRot290, 0 , 6}) //"&Faturas"
aAdd( aRotina,	{ STR0007,aRot340, 0 , 6}) //"Co&mpensação"
aAdd( aRotina,	{ STR0008,aRot390, 0 , 6}) //"Cheq s/&Título"
aAdd( aRotina,	{ STR0009,aRot580, 0 , 6}) //"Lib p/Pagto"
aAdd( aRotina,	{ STR0010,aRot426, 0 , 6}) //"C&NAB"
aAdd( aRotina,	{ STR0042,"CTBC662", 0 , 7}) //"Tracker Contábil"
aAdd( aRotina,	{ STR0011,"FA040Legenda", 0 , 6, ,.F.}) //"Le&genda"

If lIntSJURI
	aAdd( aRotina , { STR0048, "JURA246(4,,,, .T.)", 0, 0, 0, NIL }) //"Detalhe / Desdobramentos" (Módulo SIGAPFS)
	aAdd( aRotina , { STR0044, "JURA247(4)", 0, 0, 0, NIL } ) //"Desdobramento Pós Pagamento"
	If FindFunction("JURA273")
		aAdd( aRotina , { STR0049, "JURA273()", 0, 0, 0, NIL } ) // "Copiar Título"
	EndIf
EndIf

// P.E. utilizado para adicionar itens no Menu da mBrowse.
If ExistBlock("FA750BRW")
	aRotAdic := ExecBlock("FA750BRW",.F.,.F.,{aRotina})
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750080	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de baixa.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750080(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		FINA080(,3,.T.)
		lPrim750 := .F.
	Case nOpc == 2
		FINA080(,4,.T.)
	Case nOpc == 3
		FINA080(,5,.T.)
	Case nOpc == 4
		FINA080(,6,.T.)
	EndCase

	Set Filter to &cFilter

SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750050	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de contas a pagar. Inclusao, alteracao e etc.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750050(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		FinA050(,, 3 )
	Case nOpc == 2
		FinA050(,, 4 )
	Case nOpc == 3
		FinA050(,, 5 )
	Case nOpc == 4
		FinA050(,, 6 )
	Case nOpc == 5
		FinA050(,, 8 )
	EndCase

	Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750090	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de baixas automaticas.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750090(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		FinA090(2)
	Case nOpc == 2
		FinA090(3)
	Case nOpc == 3
		FinA090(3)
	EndCase

	Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750240	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de bordero de pagamento.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750240(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		Fina240(2)
	Case nOpc == 2
		Fina240(3)
	EndCase

	Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750241	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de bordero de pagamento.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750241(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		Fina241(2)
	Case nOpc == 2
		Fina241(3)
	EndCase

	Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750290	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de fatura.                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750290(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		Fina290(3)
	Case nOpc == 2
		Fina290(4)
	EndCase

	Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750340	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de compensacao entre titulos.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750340(cAlias, nReg, nOpc)

Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		Fina340(3)
	Case nOpc == 2
		Fina340(4)
	Case nOpc == 3
		Fina340(5)
	EndCase

	Set Filter to &cFilter

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750390	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de compensacao entre titulos.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750390(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		Fina390(2)
	Case nOpc == 2
		Fina390(3)
	Case nOpc == 3
		Fina390(4)
	Case nOpc == 4
		Fina390(5)
	EndCase

	Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750580	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de liberacao de titulos.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750580(nPosArotina)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

Fina580(nPosArotina)

Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Fun‡…o	 ³ FINA750426	³ Autor ³ Pedro Pereira Lima    ³ Data ³ 28/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para manter a consistencia dos filtros utilizados nas  ³±±
±±³          ³ rotinas de sub-menu cnab.                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin750426(cAlias, nReg, nOpc)
Local nOrd := 	SE2->(IndexOrd())
Local cFilter := SE2->(DbFilter())

	Do Case
	Case nOpc == 1
		Fina426(2)
	Case nOpc == 2
		Fina426(3)
	EndCase

	Set Filter to &cFilter
SE2->(DbSetOrder(nOrd))
Return
