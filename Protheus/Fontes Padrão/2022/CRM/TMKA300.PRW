#INCLUDE "TMKA300.CH"
#INCLUDE "PROTHEUS.CH"

/*                                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA300   ºAutor  ³Armando M. Tessaroliº Data ³  27/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de transferencia de conta de cobranca entre os       º±±
±±º          ³Operadores (cobradores).                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³27/04/04³811   ³-Revisao do fonte                           º±±
±±³Fernando  ³12/12/06³9.12  ³Bops 115421 Alterado a array aRotina        ³±±
±±³          ³        |      ³para criação do menu funcional              ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA300()

Local cLockByName	:= "TMKSK1" + FWCodEmp( "SK1" )
Local lRet	:= .F.				// Retorno da funcao

PRIVATE aRotina := MenuDef() 
PRIVATE cCadastro := STR0004 //"Transferência de Cobrança"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite a abertura simultanea para o modelo MDI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LockByName( cLockByName, .T., .F. )
	Help("  ",1,"TMKEXCSK1")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe o Cadastro de Operadores para escolher qual o operador de origem   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SU7")

UnLockByName( cLockByName, .T., .F. )

Return(.T.)
                 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³11/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= {		{	STR0001,	"AxPesqui",	0, 1 , , .F.},;		//"Pesquisar"
						{	STR0002,	"AxVisual",	0, 2 , , .T.},;		//"Visualizar"
						{	STR0003,	"Tk300Atu",	0, 4 , , .T.} }		//"Transfere"
			
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300Atu  ºAutor  ³Armando M. Tessaroliº Data ³  02/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a tela com as contas do operador selecionado na entra-º±±
±±º          ³da da rotina e o operador destino da transferencia.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³27/04/04³811   ³-Revisao do fonte                           º±±
±±ºAndrea F. ³23/08/04³811   ³- Inclusao array aRegras que possui todas asº±±
±±º          ³        ³      ³regras de selecao cadastradas no sistema.   º±±
±±ºAndrea F. ³13/10/04³811   ³- Incluido botao na enchoicebar para        º±±
±±º          ³        ³      ³pesquisar as contas disponiveis para transf.º±±
±±ºFernando  ³21/09/06³8.11  ³Tratei a condicao logica l habilita para    º±±
±±º          ³        ³      ³entra na tela de cobrança apenas se houver  º±±
±±º          ³        ³      ³cobranca e criei a STR0017 para informar    º±±
±±º          ³        ³      ³quando nao houver  cobranca(BOPS103839)     º±±  
±±ºTatiana C.³28/03/07³8.11  ³BOPS 121870 - Alterado o conteudo da SRT0017º±±
±±º          ³        ³      ³Para que a mensagem seja compreendida pelo  º±±
±±º          ³        ³      ³usuário nos 2 momentos em que aparece tanto º±± 
±±º          ³        ³      ³no final da transferencia quanto na ausenciaº±±
±±º          ³        ³      ³de titulos para o operador selecionado.     º±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk300Atu()

Local lSuper 	:= .F.									// Flag para indicar que o usuario e um Supervisor no Cadastro de Operadores
Local aArea		:= GetArea()							// Salva a area
Local cChave	:= ""									// Codigo e loja do cliente selecionado
Local oLbx												// Cliente do operador
Local aCliente	:= {}									// Cliente do operador
Local oDlg												// Dialog
Local oOperador											// Codigo do operador destino
Local cOperador	:= CriaVar("U7_COD", .F.)				// Codigo do operador destino
Local oNomeOper											// Nome do operador destino
Local cNomeOper	:= CriaVar("U7_NOME", .F.)				// Nome do operador destino
Local cOperOrig	:= SU7->U7_COD							// Codigo do operador origem
Local oOk		:= LoaDbitmap(GetResources(),"LBOK")	// [X] Marcado
Local oNo		:= LoaDbitmap(GetResources(),"LBNO")	// [ ] Desmarcado
Local oTodos											// Objeto de selecao
Local lTodos	:= .F.									// Valor do objeto de selecao
Local oInverte											// Objeto de selecao
Local lInverte	:= .F.									// Valor do objeto de selecao
Local lRet		:= .F.									// Retorno da funcao
Local lHabilita := .T.									// Flag para habilitar os controles da transferencia
Local nIni		:= 0                                   	// Vencimento inicial dos titulos a cobrar 
Local nFim      := 0                                   	// Vencimento final dos titulos a cobrar
Local aRegras	:= {}                                  	// Todas as Regras de seleção cadastradas 
Local aButtons	:= {}									// Botoes da enchoicebar
Local cCliente	:= Space(TamSx3('A1_COD')[1])		// Codigo do cliente
Local cLoja		:= Space(TamSx3('A1_LOJA')[1])		// Loja do cliente
Local aPDFields	:= {"U7_NOME","A1_NOME","A1_CGC"}
Local aPDCols 	:= {,"","","A1_NOME","A1_CGC"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Usuario atual e um supervisor do Call Center    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lSuper := TmkOperador(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao encontrou o usuario no Cadastro de Operadores e ele nao tem um SUPERIOR - Nao processa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSuper
	Help(" ",1,"TK180NSUPE")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega um array com as regras de cobranca que serao utilizadas pela rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SK0")
DbSetOrder(2) //Filial + Ordem
DBseek(xFilial("SK0"))
While !Eof()
	nIni := nFim + 1
    If SK0->K0_PRAZO == "999999"		// Trabalha com lista de contato
    	nFim := nFim + 100000
    Else
	    nFim := nFim + Val(SK0->K0_PRAZO)
	Endif
    Aadd(aRegras, {SK0->K0_REGSEL, nIni, nFim})
    DbSelectArea("SK0")
    DbSkip()
End


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³Pega as cobrancas do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
aCliente	:= Tk300Cliente(cOperOrig)
cChave		:= aCliente[1][2] + aCliente[1][3]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao existe cobranca efetuada nao pode existir transferencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(TRIM(cChave))
	lHabilita := .T.
Else
	lHabilita := .F.
EndIf

If lHabilita
	FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
	AAdd(aButtons,{ "S4WB011N" , {|| Tk300Pesq(@cCliente,@cLoja,aCliente,oLbx)},STR0014 })//"Pesquisar Cliente"
	DEFINE MSDIALOG oDlg Title STR0005 FROM 0,0 TO 360,600 PIXEL //"Transferencia de cobranca de cliente"

	@ 032,005 LISTBOX oLbx FIELDS Header "",;
			 STR0006,;	// Codigo
			 STR0007,;	// Loja
			 STR0008,;	// Nome
			 STR0009;	//"CNPJ/CPF"
			 SIZE 290,100 OF oDlg PIXEL

	oLbx:SetArray(aCliente)
	oLbx:bLine := {||{	IIF(aCliente[oLbx:nAt][1],oOk,oNo),;
							aCliente[oLbx:nAt][2],;
							aCliente[oLbx:nAt][3],;
							aCliente[oLbx:nAt][4],;
							aCliente[oLbx:nAt][5];
						}}
	If FATPDActive() .And. FTPDUse(.T.)
		oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
	Endif

	oLbx:bChange	:= { || (cChave := aCliente[oLbx:nAt][2] + aCliente[oLbx:nAt][3] ) }
	oLbx:bLDbLClick	:= { || (aCliente[oLbx:nAt][1] := !aCliente[oLbx:nAt][1], oLbx:Refresh()) }
	oLbx:aColSizes	:= {10,25,15,130,50}

  	@ 135,05 CHECKBOX oTodos   VAR lTodos 	SIZE 130,9 PIXEL OF oDlg Prompt STR0011 ON CHANGE;
	Tk300Tools(1, oLbx, lTodos) When lHabilita 		//"Marca e Desmarca Todos"

	@ 135,95 CHECKBOX oInverte VAR lInverte SIZE 130,9 PIXEL OF oDlg Prompt STR0012 ON CHANGE;
	Tk300Tools(2, oLbx, lInverte) When lHabilita  //"Inverte e Retorna Seleção"

	@ 145,005 TO 170,295 Label STR0010 Of oDlg Pixel //"Operador destino"

	@ 155,010  SAY STR0006 OF oDlg PIXEL SIZE 150,9 COLOR CLR_BLUE //"Codigo"
	@ 155,030 GET oOperador VAR cOperador OF oDlg SIZE 20,09 PIXEL PICTURE PesqPict("SU7", "U7_COD") VALID ;
	Tk300Operador(cOperador, @oNomeOper) When lHabilita
	oOperador:cF3 := "SU7"
	
	@ 155,080  SAY STR0008 OF oDlg PIXEL SIZE 150,9 COLOR CLR_BLUE //"Nome"
	@ 155,100 GET oNomeOper VAR cNomeOper OF oDlg SIZE 185,09 PIXEL WHEN .F. PICTURE PesqPict("SU7", "U7_NOME")
	If FATPDActive() .And. FTPDUse(.T.)
		oNomeOper:lObfuscate := FATPDIsObfuscate("U7_NOME")
	Endif

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| IIF(Tk300Transfere(cOperador, cOperOrig, aCliente, aRegras),oDlg:End(),.F.) }, {|| oDlg:End() },,aButtons)
	FATPDUnload()
	FATPDLogUser("TK300ATU")
Else
	Msginfo(STR0017)  // Todas as transferencias de cobrança já foram efetuadas ou não há mais cobranças para esse operador
EndIf

aSize(aPDCols, 0)
aSize(aPDFields, 0)
RestArea(aArea)
lRet := .T.

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300OperadorºAutor³Armando M. TessaroliºData ³  09/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do campo codigo do operador destino e atualizacao º±±
±±º          ³do campo nome do operador destino.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk300Operador(cOperador, oNome)

Local lRet		:= .F. 	// Retorno da funcao

DbSelectArea("SU7")
DbSetOrder(1)
If Dbseek(xFilial("SU7") + cOperador)
	lRet := .T.  
	oNome:bSetGet := {|| SU7->U7_NOME }
	oNome:Refresh()
ElseIf !Empty(cOperador)
	Help("  ",1,"REGNOIS")
	oNome:bSetGet := {|| SU7->U7_NOME }
	oNome:Refresh()
Else
	oNome:bSetGet := {|| Space(Len(SU7->U7_NOME)) }
	oNome:Refresh()
	lRet := .T.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300ClienteºAutor³Armando M. Tessaroliº Data ³  09/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa todos os clientes que estao sendo cobrados pelo opeº±±
±±º          ³rador de origem para serem transferidos.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³08/07/05³811   ³BOPS 83837-  Incluido a clausula DISTINCT   º±±
±±º          ³        ³      ³na query para agilizar o processamento.     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk300Cliente(cOperador)

Local aOldArea	:= GetArea()
Local aAreaSK1	:= SK1->(GetArea())
Local aCliente	:= {}		// Clientes selecionados
Local cQuery		:= ""		// Query de pesquisa

DbSelectArea("SK1")
DbSetOrder(3)	// K1_OPERAD
cQuery	:=	" SELECT DISTINCT SK1.K1_FILIAL, SK1.K1_OPERAD, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_CGC " +;
         	" FROM " +	RetSqlName("SK1") + " SK1, " + RetSqlName("SA1") + " SA1 " +;
         	" WHERE	SK1.K1_FILIAL = '" + xFilial("SK1") + "' AND" +;
         	"		SK1.K1_OPERAD = '" + cOperador + "' AND" +;
         	"		SK1.D_E_L_E_T_ = '' AND" +;
         	"		SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND" +;
         	"		SA1.A1_COD = SK1.K1_CLIENTE AND" +;
         	"		SA1.A1_LOJA = SK1.K1_LOJA AND" +;
         	"		SA1.D_E_L_E_T_ = ' '" +;
         	" ORDER BY " + SqlOrder(IndexKey())

cQuery	:= ChangeQuery(cQuery)
MemoWrite("TK300SK1.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SK1QRY', .F., .T.)
While	SK1QRY->(! Eof())
	If Ascan(aCliente, {|x| x[2]+x[3] == SK1QRY->A1_COD + SK1QRY->A1_LOJA} ) == 0
		Aadd(aCliente, { .F., SK1QRY->A1_COD, SK1QRY->A1_LOJA, SK1QRY->A1_NOME, Transform(SK1QRY->A1_CGC, PesqPict("SA1", "A1_CGC")) } )
	Endif
	SK1QRY->(DbSkip())
EndDo
SK1QRY->(DbCloseArea())

If Len(aCliente) == 0
	Aadd(aCliente, { .F., CriaVar("A1_COD",.F.), CriaVar("A1_LOJA",.F.), CriaVar("A1_NOME",.F.), CriaVar("A1_CGC",.F.) } )
Endif

RestArea(aAreaSK1)
RestArea(aOldArea)
Return(aCliente)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300TransfereºAutor³Armando M. Tessaroliº Data ³ 09/04/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava o novo operador como responsável pelo atendimento de  º±±
±±º          ³cobranca do cliente.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³23/08/04³811   ³- Validacao das regras de cobranca do opera-º±±
±±º          ³        ³      ³dor de destino para transferencia.          º±±
±±ºAndrea F. ³25/04/05³811   ³BOPS 78945 - Permitir que as contas sejam   º±±
±±º          ³        ³      ³transferidas para um operador de um grupo   º±±
±±º          ³        ³      ³com a regra de maior prazo de cobranca.     º±±
±±ºConrado Q.³10/11/06³811   ³- BOPS 112675: Verifica se o grupo de       º±±
±±º          ³        ³      ³atendimento do operador de destino tem regraº±±
±±º          ³        ³      ³de seleção válida.                          º±±
±±ºNorbert W.³03/04/07³912   ³- BOPS 122163: Validacao do operador infor- º±±
±±º          ³        ³      ³mado: Obriga o usuario a preencher o codigo º±±
±±º          ³        ³      ³do operador, caso este esteja em branco.    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk300Transfere(cOperador, cOperOrig, aCliente, aRegras)

Local nI		 := 0											//Contador
Local lRet		 := .T.											//Retorno da funcao
Local cRegSelOrig := TKPosto(cOperOrig,"U0_REGSEL")				//Regra de selecao do operador de origem
Local cRegSelDest := TKPosto(cOperador,"U0_REGSEL")				//Regra de selecao do operador de destino
Local nPosOrig	   := Ascan(aRegras, {|x| x[1] == cRegSelOrig })	//Posicao do array em que se encontra a regra de selecao do operador de origem 
Local nPosDest	   := Ascan(aRegras, {|x| x[1] == cRegSelDest })	//Posicao do array em que se encontra a regra de selecao do operador de destino
Local nPosUlt	   := Len(aRegras)								//Total de regras de selecao cadastradas 													
Local lTK300TRS  := ExistBlock("TK300TRS") 
Local lTrLstCmp  := .F.
Local nTtCli     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o operador for invalido, aborta a execucao da rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SU7->(DbSetOrder(1)) //U7_FILIAL+U7_COD
If Empty(cOperador) .OR. !SU7->(DbSeek(xFilial("SU7")+cOperador))   
	Help(" ",1,"OBRIGAT")
	lRet := .F.
	Return (lRet)
EndIf

If Len(aCliente) == 0
	Help(" ",1,"TK300NCOBR") 
	lRet:= .F.
	Return(lRet)
Endif

If cOperador == cOperOrig
	Help(" ",1,"TK300OPO2D")
	lRet:= .F.
	Return(lRet)
Endif

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o operador de destino participa de um grupo de ³
	//³atendimento com regra de seleção definida.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case nPosDest == 0	
		MsgStop(STR0018)//"Operador de destino não participa de um grupo de atendimento com regra de seleção definida."
		Return(lRet)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para identificar se a regra de destino e a maior, comparo o PRAZO (Dias).   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case aRegras[nPosDest][3] > aRegras[nPosOrig][3] 
		If nPosUlt > 0 .AND. aRegras[nPosUlt][3] == aRegras[nPosDest][3]		
			If !TmkOk(STR0015)//"Confirma a transferência da(s) conta(s) selecionada(s) para um operador de um grupo superior?"
    			Return(lRet)
			Endif
        Else	
        	MsgStop(STR0016)//"Para transferir conta(s) para um grupo superior, o mesmo deve possuir o maior prazo (dias) entre todas as regras cadastradas."
   			Return(lRet)
        Endif
	Case aRegras[nPosDest][3] < aRegras[nPosOrig][3] 
		MsgStop(STR0013)//"A transferência não poderá ser realizada pois a regra de seleção do Operador de destino é inferior a regra do operador de origem")
		Return(lRet)

EndCase	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Incluido para verificar se a tranferencia será total ou parcial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval (aCliente, {|aVal| IIF(aVal[1],nTtCli++,nil)  })
lTrLstCmp := (nTtCli == Len(aCliente))

If lTrLstCmp
	For nI := 1 To Len(aCliente)
		If aCliente[nI][1]
			BEGIN TRANSACTION
				If Tk300AtuSK1(aCliente[nI][2],aCliente[nI][3],cOperador)
					Tk300AtuSU4(aCliente[nI][2],aCliente[nI][3],cOperador,cOperOrig,lTrLstCmp)
	         Endif 
			END TRANSACTION
		Endif
	Next nI
Else // So executa esta funcao quando for transferencia parcial de pendencias
	BEGIN TRANSACTION
		TkAtSU6(aCliente,cOperador,cOperOrig)
	END TRANSACTION
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³P.E apos a gravacao das transferencias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK300TRS
	Execblock("TK300TRS",.F.,.F.,{cOperOrig,cOperador})
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300AtuSK1ºAutor  ³Andrea Farias       º Data ³  05/17/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o codigo do operador de destino no SK1 para os     º±±
±±º          ³titulos do cliente.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºConrado Q.³06/11/06³811   ³Bops 112303 - Quando o título esta em       º±±
±±º          ³        ³      ³exceção não altera o seu operador.          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk300AtuSK1(cCliente,cLoja,cOperador)			

Local lRet	:= .F.					// Retorno da funcao
Local cFilSK1		:= xFilial("SK1")

DbSelectArea("SK1")
DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
If DbSeek(cFilSK1+cCliente+cLoja)
    lRet:= .T.
    
	While SK1->(! Eof())              .AND.;
	      SK1->K1_FILIAL == cFilSK1   .AND.;
	      SK1->K1_CLIENTE == cCliente .AND.;
	      SK1->K1_LOJA == cLoja
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o título está em exceção.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If SK1->K1_OPERAD == "XXXXXX"
			SK1->(DbSkip())
			Loop
		EndIf
	
		RecLock("SK1", .F.)
		SK1->K1_OPERAD := cOperador
		MsUnLock()
		
		SK1->(DbSkip())
	End

Endif	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300AtuSU4ºAutor  ³Microsiga          º Data ³  05/17/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transfere as listas de cobrança pendentes para o operador   º±±
±±º          ³de destino                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³08/07/05³811   ³- Controle da alteracao de campo que esta   º±±
±±º          ³        ³      ³contido na chave de indice.                 º±±
±±ºAndrea F. ³25/04/06³811   ³BOPS 97587 - Gravar a funcao que encerrou a º±±
±±º          ³        ³      ³pendencia de telecobranca.                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk300AtuSU4(cCliente,cLoja,cOperador,cOperOrig,lTrLstCmp)

Local lRet			:= .T.						// Retorno da funcao
Local cFilSU4		:= xFilial("SU4")
Local cFilSU6		:= xFilial("SU6")
Local cFilACF		:= xFilial("ACF")

Default lTrLstCmp := .T.

DbSelectArea("SU4")
DbSetOrder(5)		// U4_FILIAL+U4_OPERAD+U4_STATUS
DbSeek(cFilSU4 + cOperOrig + "1")
While	!Eof()							.AND.;
		SU4->U4_FILIAL 	== cFilSU4	.AND.;
		SU4->U4_STATUS 	== "1"				

	If SU4->U4_TIPO <> "2" //Cobranca   
		Dbskip()
		Loop
	Endif	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda o proximo registro (Recno()) para substituir o Dbskip() pelo Dbgoto()³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SU4->(DbSkip())
	nRecnoSU4 := SU4->(Recno())
	SU4->(DbSkip(-1))
	
	DbSelectArea("SU6")
	DbSetOrder(1)

	If DbSeek(cFilSU6 + SU4->U4_LISTA)
		
		If AllTrim(cCliente+cLoja) == AllTrim(SU6->U6_CODENT)
			
			DbSelectArea("SU4")
			RecLock("SU4", .F.)
			If !Empty(cOperador) .And. lTrLstCmp
				SU4->U4_OPERAD	:= cOperador
			ElseIf lTrLstCmp
				SU4->U4_STATUS	:= "2"  //Enviado
			Endif
			SU4->U4_DATA	:= dDataBase
			SU4->U4_HORA1	:= Time()
			SU4->U4_ROTINA := "TK300ATUSU4"	
			MsUnLock()
				
			DbSelectArea("SU6")
			RecLock("SU6", .F.)
			If Empty(cOperador)
				SU6->U6_STATUS	:= "3" //Enviado
			Endif
			SU6->U6_DATA	:= dDataBase
			SU6->U6_HRINI	:= Time()
			SU6->U6_ROTINA := "TK300ATUSU4"
	
			MsUnLock() 
				
			DbSelectArea("ACF")
			DbSetOrder(1) 
			If DbSeek(cFilACF+SU6->U6_CODLIG)
				RecLock("ACF", .F.)
				ACF->ACF_OPERAD:= cOperador							
				MsUnLock() 
			Endif	

		Endif
	Endif
	
	SU4->(MsGoto(nRecnoSU4))
	
End

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300AtuSU6ºAutor  ³Vendas / CRM       º Data ³  03/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria nova lista de pendencias para o operador destino quandoº±±
±±º          ³a transferencia for parcial.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA300                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkAtSU6(aCliente,cOperador,cOperOrig)

Local InX	:= 0
Local InY	:= 0
Local InZ	:= 0
Local aStructSU4 := SU4->(DbStruct()) 
Local aDadoSU4  := {}
Local nSaveSx8  := GetSx8Len()
Local cLista    := ""
Local cSeek     := ""
Local xDado
Local cFilSU4		:= xFilial("SU4")
Local cFilSU6		:= xFilial("SU6")
Local cFilACF		:= xFilial("ACF")

For InX := 1 To Len(aCliente)
	
	// Busca a lista que a pendencia pertence
	If aCliente[InX][1]
		cQuery := "SELECT DISTINCT U6_LISTA FROM " +	RetSqlName("SU6") + " SU6 "
		cQuery += " WHERE SU6.U6_FILIAL = '" + cFilSU6 + "'AND SU6.D_E_L_E_T_ = ' ' "
		cQuery += " AND '" + aCliente[InX][2] + aCliente[InX][3] + "' = SU6.U6_CODENT "
		cQuery += " AND SU6.U6_STATUS = '1' "
		cQuery := ChangeQuery(cQuery)
		 
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBSU6', .F., .T.)
		While TRBSU6->(!Eof())
		
			cLista := TRBSU6->U6_LISTA
		
			// Busca cabecalho de referencia para a nova lista
			DbSelectArea("SU4")
			If !Empty(cLista)
				DbSetOrder(1)		// U4_FILIAL+U4_LISTA
				cSeek := cFilSU4 + cLista
			Else
				DbSetOrder(5)		// U4_FILIAL+U4_OPERAD + U4_STATUS
				cSeek := cFilSU4 + cOperOrig + "1"
			EndIf
			If dbSeek( cSeek )
				If SU4->U4_TIPO == "2" //Cobranca   
					For InY := 1 To Len(aStructSU4)
						xDado := &("SU4->("+aStructSU4[InY][1]+")")
						If "U4_LISTA" $ aStructSU4[InY][1]
							aaDD(aDadoSU4,{aStructSU4[InY][1],GetSxeNum("SU4","U4_LISTA")})
						ElseIf "U4_OPERAD" $ aStructSU4[InY][1]
							aaDD(aDadoSU4,{aStructSU4[InY][1],cOperador})
						ElseIf !Empty(xDado)
							aaDD(aDadoSU4,{aStructSU4[InY][1],xDado})
						EndIf
					Next InY
				EndIf
			EndIf
			
			If Len(aDadoSU4) > 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava o cabecalho da Lista de pendencia³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SU4",.T.)
				For InZ := 1 To Len(aDadoSU4)
					&("SU4->"+aDadoSU4[InZ][1]) := aDadoSU4[InZ][2]
				Next InZ	 
				MsUnLock("SU4")
				
	
				DbSelectArea("SU6")
				SU6->(dbSetOrder(1))
				SU6->(dbGotop())
				If SU6->(dbSeek(cFilSU6 + cLista))
					While SU6->(!Eof()) .And. SU6->U6_LISTA == cLista
						If AllTrim(aCliente[InX][2] + aCliente[InX][3]) == AllTrim(SU6->U6_CODENT)
							RecLock("SU6", .F.)
							SU6->U6_LISTA := aDadoSU4[aScan(aDadoSU4,{|z| z[1] == "U4_LISTA" })][2]
							SU6->U6_ROTINA := "TKATSU6"	
							
							MsUnLock()
			
							ACF->(dbSetOrder(1))
							If ACF->(dbSeek(cFilACF+SU6->U6_CODLIG))
								RecLock("ACF", .F.)
								ACF->ACF_OPERAD:= cOperador							
								MsUnLock() 
							Endif
							// Se alterou a lista para esta cliente altera as pendencias
							Tk300AtuSK1(aCliente[InX][2],aCliente[InX][3],cOperador)
						EndIf
						SU6->(dbSkip())
					EndDo
				Endif
			EndIf
	
			aDadoSU4 := {}
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente após a alteração do codigo da lista nos itens verifica se ainda consta     ³
			//³algum item pendente nesta lista, se não houve exclui.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SU6->(dbSetOrder(1))
			SU6->(dbGotop())
			If !SU6->(dbSeek(cFilSU6 + cLista))
				SU4->(dbSetOrder(1))	// U4_FILIAL+U4_LISTA
				If SU4->(dbSeek(cFilSU4 + cLista))
					RecLock("SU4",.F.)
					SU4->(dbDelete())
					MsUnLock("SU4")
				EndIf
			EndIf
		
			While (GetSx8Len() > nSaveSx8)
				ConfirmSx8()
			End	
							
			FkCommit()
			
			TRBSU6->(dbSkip())
			
		EndDo
		TRBSU6->(dbCloseArea())

	EndIf
Next InX

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300ToolsºAutor  ³Armando M. Tessaroliº Data ³  03/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para selecao dos Cliente apresentados no browser paraº±±
±±º          ³serem transferidos.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk300Tools(nTipo, oLbx, lCheck)

Local nI	:= 0		// Variavel de Controle

If nTipo == 1
	If lCheck
		For nI := 1 To Len(oLbx:aArray)
			oLbx:aArray[nI][1] := .T.
			oLbx:Refresh()
		Next nI
	Else
		For nI := 1 To Len(oLbx:aArray)
			oLbx:aArray[nI][1] := .F.
			oLbx:Refresh()
		Next nI
	Endif
Else
	For nI := 1 To Len(oLbx:aArray)
		If oLbx:aArray[nI][1]
			oLbx:aArray[nI][1] := .F.
		Else
			oLbx:aArray[nI][1] := .T.
		Endif
		oLbx:Refresh()
	Next nI
Endif

Return(.T.)
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk300Pesq ºAutor  ³Andrea Farias       º Data ³  30/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa um cliente na lista de transferencia               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk300Pesq(cCliente,cLoja,aCliente,oLbx)

Local nPos			:= 0			//Indice de busca no vetor aCliente
Local nOk			:= 0
Local cNome		:= Space(TamSx3("A1_NOME")[1])	//Nome do cliente
Local oCliente	:= NIL			//Objeto para o codigo do cliente
Local oLoja		:= NIL			//Objeto para a loja do cliente
Local oNome		:= NIL			//Objeto para o nome do cliente
Local oDlg			:= NIL			//Objeto para dialogo
Local oFonte		:= NIL			//Objeto para a fonte utilizada

While .T.
	nOk		:= 0
	DEFINE MSDIALOG oDlg TITLE STR0014 FROM 15,2 TO 200,300 PIXEL   //"Pesquisar Cliente"
	@ 002,002 TO 090,148 OF oDlg  PIXEL

	@ 010,010 SAY STR0006 + " :" FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		//"Codigo :"
	@ 010,035 GET oCliente VAR cCliente OF oDlg Picture PesqPict("SA1", "A1_COD") SIZE 40,10 PIXEL VALID Tk300SelCli(cCliente,cLoja,@cNome,oNome)
	oCliente:cF3 := "CLT"

	@ 030,010 SAY STR0007 + "    :" FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL	//"Loja    :"
	@ 030,035 GET oLoja VAR cLoja OF oDlg SIZE 20,10 PIXEL VALID Tk300SelCli(cCliente,cLoja,@cNome,oNome)

	@ 050,010 SAY STR0008 + "    :" FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL	//"Nome    :"
	@ 050,035 GET oNome VAR cNome OF oDlg SIZE 80,10 PIXEL WHEN .F.
	If FATPDActive() .And. FTPDUse(.T.)
		oNome:lObfuscate := FATPDIsObfuscate("A1_NOME")
	Endif

	DEFINE SBUTTON FROM 070,085 TYPE 1 ACTION (nOk := 1, oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 070,115 TYPE 2 ACTION (nOk := 0, oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

	If	nOk == 0 .OR. ( nOk == 1 .AND. ( ! Empty(cCliente) .OR. ! Empty(cLoja) ) .AND. ExistCpo("SA1", cCliente + cLoja) )
		EXIT
	EndIf
EndDo

nPos := Ascan(aCliente, {|x| x[2]+x[3] == cCliente + cLoja} )
If nPos > 0
	oLbx:aArray[nPos][1] := .T.
	oLbx:nAt := nPos
	oLbx:Refresh()
Endif

Return(nPos)

Static Function Tk300SelCli(cCliente,cLoja,cNome,oNome)

cNome := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
oNome:bSetGet := {|| cNome }
oNome:Refresh()
Return(.T.)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
