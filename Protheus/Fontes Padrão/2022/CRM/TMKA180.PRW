#INCLUDE "TMKA180.CH"
#INCLUDE "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA180   ºAutor  ³Armando M. Tessaroliº Data ³  02/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de selecao e atualizacao dos titulos vencidos do ca- º±±
±±º          ³dastro SE1 para a referencia no SK1.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºAndrea F. ³13/09/04³811   ³- Considerar todos os titulos vencidos      º±±
±±º          ³        ³      ³independente da filial. Gravacao da filial  º±±
±±º          ³        ³      ³de origem do titulo no campo K1_FILORIG.    º±±
±±ºAndrea F. ³15/09/04³811   ³- Implementado o parametro MV_TMKCOBR que   º±±
±±º          ³        ³      ³contem os tipos de titulos a serem conside- º±±
±±º          ³        ³      ³rados para a cobranca.                      º±±
±±ºAndrea F. ³04/03/05³811   ³- Implementado ponto de entrada TK180QRY    º±±
±±º          ³        ³      ³que inclui uma expressao de filtro na query.º±±
±±³Fernando  ³12/12/06³9.12  ³Bops 115402 Alterado a array aRotina        ³±±
±±³          ³        |      ³para criação do menu funcional              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA180(aRotAuto,nOpc)

Local cLockByName	:= "TMKSK1" + FWCodEmp( "SK1" )
Private aRotina := MenuDef() 
Private cCadastro := STR0005 //"Atualizacao dos Titulos para Cobranca"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis para rotina de inclusao automatica    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lTk180Auto := ( aRotAuto <> NIL )
Private oTempTable	:= NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite a abertura simultanea para o modelo MDI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk180Auto 
	If !LockByName( cLockByName, .T., .F. )
		Help("  ",1,"TMKEXCSK1")
		Return(.F.)
	Endif
Endif

If lTk180Auto 
	MsRotAuto(nOpc,aRotAuto,"SK1")
Else	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse(,,,,"SK1")
	UnLockByName( cLockByName, .T., .F. )
Endif

Return(.T.) 


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Fernando Amorim       ³ Data ³08/12/06  ³±±
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

Local aRotAdic	:= {}		// Retorno do P.E. TK180ROT
Local lTk180Rot := ExistBlock("TK180ROT")

Local aRotina:= {	{ STR0001,	"AxPesqui", 0, 1 , , .F.},;		//"Pesquisar"
					{ STR0002,	"AxVisual", 0, 2 , , .T.},;		//"Visualizar"
					{ STR0003,	"Tk180Atu", 0, 3 , , .T.},;		//"Gerar"
					{ STR0010,	"Tk180Exc", 0, 5 , , .T.} }  		//"Excecao"   
					
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTk180Rot
	aRotAdic := ExecBlock("TK180ROT" , .F. , .F. )
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	Endif
Endif


Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK180Exc  ºAutor  ³Armando M. Tessaroliº Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que controla a Excecao de cobranca, ou seja, titulos º±±
±±º          ³que nao deverao ser cobrados.                               º±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TK180Exc(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo					  			  	  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMichel M. ³18/01/07³9.12  ³Bops.115782 - Implementacao da funcao       º±±
±±º          ³        ³      ³FillGetDados() para preencher o Acols da    º±±
±±º          ³        ³      ³rotina.                                     º±±
±±ºMichel M. ³05/04/07³9.12  ³Bops.115782 - Substituido o uso do objeto   º±±
±±º          ³        ³      ³MsGetDados() por MsSelect() em funcao do    º±±
±±º          ³        ³      ³walk thru nao funcionar quando era utilizadaº±±
±±º          ³        ³      ³a propriedade blDblClick do objeto.         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK180Exc(cAlias, nReg, nOpc)

Local aArea		:= GetArea()			// Salva a area
Local oDlg								// Dialog
Local oTodos							// Objeto de selecao
Local lTodos	:= .F.					// Valor do objeto de selecao
Local oInverte							// Objeto de selecao
Local lInverte	:= .F.					// Valor do objeto de selecao
Local oAcao								// Objeto de acao
Local lAcao		:= .T.					// Valor do objeto de acao
Local cCliente	:= SK1->K1_CLIENTE		// Codigo do cliente selecionado
Local cLoja		:= SK1->K1_LOJA			// Loja do cliente selecionado
Local cPrefixo	:= SK1->K1_PREFIXO		// Prefixo do titulo inicial
Local cNum		:= SK1->K1_NUM			// Numero do titulo inicial
Local cParcela	:= SK1->K1_PARCELA		// Parcela do titulo inicial
Local cTipo		:= SK1->K1_TIPO			// Tipo do titulo inicial
Local nRow		:= 0					// Valor maximo de linhas da dialog em pixel
Local nCol		:= 0					// Valor maximo de colunas da dialog em pixel

Local cSeek		:= ""					// Armazena a string de busca
Local cWhile	:= ""					// Armazena a condição de parada
Local bCond            					// Armazena a condicao para validar os registros
Local cQuery	:= ""  					// Armazena a query para TOP
Local aYesUsado := {}
             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros utilizadados pelo MsSelect() ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lInvert :=.F.  					// Parametro do MSSelect()
Local cAliasTRB							// Alias do arquivo de trabalho utilizado pelo MsSelect()
Local aCpos := {}  						// Array com informacoes dos campos a serem exibidos no MsSelect()


//Adiciona campos na FillGetDados()
aAdd(aYesUsado, "K1_FILORIG")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o aCols 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:= {}
aHeader	:= {} 
Aadd(aHeader,	{"","CHECKBOL","@BMP",20,00,,,"C",,"V" } )


cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SK1")+" SK1  "
cQuery += "WHERE SK1.K1_FILIAL='"+xFilial("SK1")+"' AND "
cQuery += "SK1.K1_CLIENTE='"+cCliente+"' AND "
cQuery += "SK1.K1_LOJA='"+cLoja+"' AND "	
cQuery += "SK1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "+SqlOrder(SK1->(IndexKey()))		

DbSelectArea("SK1")
DbCloseArea() 

cSeek	:= xFilial("SK1") + cCliente + cLoja
cWhile	:= "SK1->K1_FILIAL + SK1->K1_CLIENTE + SK1->K1_LOJA"	
bCond	:= {||IIf(SK1->K1_FILIAL == xFilial("SK1") .AND. SK1->K1_CLIENTE == cCliente .AND. SK1->K1_LOJA == cLoja,.T.,.F.)}    

FillGetDados(	nOpc/*nOpcX*/, "SK1"/*cAlias*/, 4/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, .F./*lEmpty*/,; 
				/*aHeaderAux*/, /*aColsAux*/, {||Tk180AfterCols(cPrefixo, cNum, cParcela, cTipo)}/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, "SK1"/*cAliasQry*/, {|cField|Tk180CriaVar(cField)}/*bCriaVar*/,/*lUserFields*/,aYesUsado)
	
DbSelectArea("SK1")
DbSetOrder(4)

DEFINE MSDIALOG oDlg Title STR0011 FROM 0,0 TO 340,600 PIXEL //"Títulos em Exceção de Cobrança"

	nRow := oDlg:nHeight*.87 / 1
	nCol := oDlg:nWidth*.99 / 2
	
	EnchoiceBar(oDlg, {|| (Tk180TrbToCol(cAliasTRB, aCols, aHeader, "CHECKBOL", "TMP_OK", "LBOK", "LBNO", "x", " "),Tk180Acao(aHeader, aCols, lAcao),oDlg:End()) }, {|| oDlg:End() } )
	Tk180ColToTrb(@cAliasTRB, @aCpos, aCols, aHeader, "CHECKBOL" /*cChkBoxName*/, "TMP_OK"/*cChkTrbName*/, "LBOK"/*cOkName*/, /*cFalseName*/, "x"/*cTrbOkValue*/, " "/*cTrbFalseValue*/) 
	oSelect := MsSelect():New(cAliasTRB,"TMP_OK",,aCpos,@lInvert,"x",{(nRow*.1),(nCol*.02),(nRow*.45),(nCol*.99)})
	
	@ (nRow*.48),(nCol*.02) CheckBox oTodos Var lTodos Size 130,9 Pixel Of oDlg Prompt STR0012 On Change Tk180Tools(1, cAliasTRB, lTodos, oSelect) //"Marca e Desmarca Todos"
	@ (nRow*.48),(nCol*.34) CheckBox oInverte Var lInverte Size 130,9 Pixel Of oDlg Prompt STR0013 On Change Tk180Tools(2, cAliasTRB, lInverte, oSelect) //"Inverte e Retorna Seleção"
	@ (nRow*.48),(nCol*.66) CheckBox oAcao Var lAcao Size 130,9 Pixel Of oDlg Prompt STR0014 //"Bloqueia e Libera os Títulos"
	
ACTIVATE MSDIALOG oDlg CENTERED 

Tk180CloseTrb()
RestArea(aArea)

Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk180CriaVar    ³ Autor ³ Michel Mosca    ³ Data ³18/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona nova coluna no Acols        					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk180CriaVar(ExpC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo a ser criado no acols.		  			  	  ³±±
±±³			 ³                              							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka180					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Static Function Tk180CriaVar(cField)
Local cRet		//Retorno do CriaVar
Local nPos

If cField <> "CHECKBOL"
	For nPos:=1 To Len(aHeader)-2
		If AllTrim(aHeader[nPos][2]) == AllTrim(cField)
			Exit	
		EndIf
	Next nPos    
	If ( aHeader[nPos][10] <>  "V" )
		cRet := FieldGet(FieldPos(aHeader[nPos][2]))
	Else
		cRet := CriaVar(aHeader[nPos][2],.T.)
	Endif		
Else
	cRet	:= {"","CHECKBOL","@BMP",20,00,,,"C",,"V" }	
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk180AfterCols  ³ Autor ³ Michel Mosca    ³ Data ³18/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza processamento do aCols       					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk180AfterCols(ExpC1, ExpC2, ExpC3, ExpC4)  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Prefixo do titulo                			  	  ³±±
±±³			 ³ ExpC2 = Numero do titulo     							  ³±±
±±³			 ³ ExpC3 = Parcela                							  ³±±
±±³			 ³ ExpC4 = Tipo                 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka180					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk180AfterCols(cPrefixo, cNum, cParcela, cTipo)
If SK1->K1_PREFIXO+SK1->K1_NUM+SK1->K1_PARCELA+SK1->K1_TIPO == cPrefixo+cNum+cParcela+cTipo
	aCols[Len(aCols)][1] := "LBOK"
Else
	aCols[Len(aCols)][1] := "LBNO"
Endif
Return .T.                               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk180Atu  ºAutor  ³Armando M. Tessaroliº Data ³  27/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utiliza este recurso para montar a regua de progresso.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³09/03/06 ³ 8.11³ Tratar a inicializacao da variavel que     º±±
±±º          ³         ³     ³ controla entrada automatica.               º±±
±±ºConrado Q.³06/03/07 ³ 9.12³ -Bops: 119542: Retirada função de ajuste deº±±
±±º          ³         ³     ³ dicionário.                                º±±
±±ºConrado Q.³17/07/07 ³ 8.11³ - Bops 127902: Corrigida a exibição da dataº±±
±±º          ³         ³     ³ e hora da última atualização, quando o ano º±±
±±º          ³         ³     ³ tem 4 digitos.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk180Atu(lFirst,cArqLog,cFilDe,cFilAte,cGeraLog)

Local aArea		:= GetArea()				// Salva a area atual
Local lExiste	:= .F.						// Flag para indicar se o usuario esta no cadastro de Operadores
Local cUltimo	:= GetMv("MV_TMKSK1")		// Data e hora da ultima atualizacao
Local lRet		:= .F.						// Retorno da funcao
Local cModo		:= ""						// Modo de Acesso do SE1
Local aSX2Info	:= {}

Private cPerg	:= "TMK180"            		// Pergunte para filtrar as filiais do SE1

Default cFilDe   := ""
Default cFilAte  := ""
Default cGeraLog := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a variavel nao estiver inicializada nesse ponto, significa que nao e entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  Type("lTk180Auto") == "U" 
	Private lTk180Auto:= .F.
Endif	 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o dicionario nao estiver compatibilizado para cobranca entre filiais³
//³avisa o usuario da execucao da rotina e dos riscos.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	GetRpoRelease() >= "12.1.027"
	aSX2Info    := FwSX2Util():GetSX2Data("SE1" /*cAlias*/, {"X2_MODO"} /*aFields*/, /*lQuery*/)
Else
	SX2->(DbSetOrder(1))
	If SX2->(DbSeek("SE1"))
		aSX2Info    := {{"X2_MODO", AllTrim(SX2->X2_MODO)}}
	EndIf
EndIf
cModo	:= aSX2Info[01,02]

If cModo == "E" 
	//Se o dicionario nao estiver compatibilizado
	If !Tk180Dic()
		If !lTk180Auto .OR. ! ExecSchedule()
			If !TmkOk(STR0015)//"O Contas a Receber - SE1 esta em modo exclusivo e os campos para compatibilizacao da cobrança entre filiais nao foram criados. Se a rotina for executada poderão existir títulos que nao serao carregados no atendimento para cobrança. Tem certeza que deseja executar a rotina?"
				RestArea(aArea)
				aSize(aArea,0)
				FreeObj(aSX2Info)
				Return(lRet)
			Endif	
		Else
			// Projeto Geracao Automatica de Titulos
			if Type("aMsgSch") == "A"
				Aadd(aMsgSch,STR1033) //  "O Contas a Receber - SE1 esta em modo exclusivo e os campos para compatibilizacao da cobrança entre filiais nao foram criados."				Endif	
			Endif	
			RestArea(aArea)
			aSize(aArea,0)
			FreeObj(aSX2Info)
			Return(lRet)	
		Endif	
	Endif
Endif	
	
If ValType(lFirst) == "U"
	Default lFirst := .F.
ElseIf ValType(lFirst) <> "L"
	lFirst := .F.
Endif

If ( Type("lTk180Auto") == "U" )
	lTk180Auto := .F.
EndIf

// Projeto Geracao Automatica de Titulos
If lTk180Auto .OR. ExecSchedule()
	lFirst := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao for a primeira vez que o processo esta sendo executado - valida o usuario que solicitou o processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFirst
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa o usuario no cadastro de operadores					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lExiste := TmkOperador()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver no SCHEDULE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Projeto Geracao Automatica de Titulos
	If ! ExecSchedule()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao encontrou o usuario no Cadastro de Operadores e ele nao tem um SUPERIOR - Nao processa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExiste .OR. SU7->U7_TIPO <> "2"
			Help(" ",1,"TK180NSUPE")
			RestArea(aArea)
			aSize(aArea,0)
			FreeObj(aSX2Info)
			Return(lRet)
		Endif	
	Else
		// Projeto Geracao Automatica de Titulos
		if Type("aMsgSch") == "A"
			Aadd(aMsgSch,STR1034) //  "Usuario nao localizado no Cadastro de Operadores ou sem Superior cadastradado"
		Endif	
	Endif
	
	// Projeto Geracao Automatica de Titulos
	if ! ExecSchedule()
		If !Empty(cUltimo) .AND. !TMKOK(STR0007 + StrTran(cUltimo, "-", STR0008 ) + STR0009) //"A ultima atualização foi executada no dia "###" as "###" horas. Deseja realizar a atualização agora?"
			RestArea(aArea)
			aSize(aArea,0)
			FreeObj(aSX2Info)
			Return(lRet)
		Endif
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for entrada automatica ou estiver no SCHEDULE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Projeto Geracao Automatica de Titulos
If lTk180Auto .OR. ExecSchedule()
	// Pergunte TMK180
	// mv_par01 Filial de ?                   
	// mv_par02 Filial Ate?
	// mv_par03 Gera Log ?

	If ExecSchedule()	
		Pergunte(cPerg,.F.,Nil,Nil,Nil,.F.)  // carrega as perguntas que foram atualizadas anteriormente
		If IsInCallStack("TMKA185")
			MV_PAR01 := cFilDe
			MV_PAR02 := cFilAte
			MV_PAR03 := Val(cGeraLog)
		EndIf
	Else
		Pergunte(cPerg,.F.)
	Endif	
	BatchProcess(,,, { || TK180Gera(@cArqLog) } )
Else
	If Pergunte(cPerg,.T.)
		Processa( {|| TK180Gera() }, STR0006) //"Avaliando Titulos para cobranca..."
	Endif	
Endif

lRet := .T.

RestArea(aArea)
aSize(aArea,0)
FreeObj(aSX2Info)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk180Gera ºAutor  ³Armando M. Tessaroliº Data ³  18/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que busca no cadastro de Titulos a Receber todos os  º±±
±±º          ³Titulos com saldo maior que zero e com a data de vencimento º±±
±±º          ³maior que a data do sistema e atualiza uma tabela de refe-  º±±
±±º          ³rencias SK1, para pesquisas da Telecobranca.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³25/04/06 ³ 8.11³ BOPS 97584 - Realizar alteracao no titulo  º±±
±±º          ³         ³     ³ da tabela SK1 quando este foi alterado no  º±±
±±º          ³         ³     ³ SE1.                                       º±±
±±ºAndrea F. ³25/04/06 ³ 8.11³ BOPS 97567 - Melhorar a performance da ro- º±±
±±º          ³         ³     ³ tina incluindo nova query.                 º±±
±±ºHanna C.  ³01/02/07 ³ 8.11³ BOPS 118217 - Inclusao do LOG de inconsis- º±±
±±º          ³         ³     ³ tencias do SK1                             º±±
±±ºMichel W. ³13/03/07 ³ 9.12³ BOPS 120945 - Aplicacao de melhoria na que-º±±
±±º          ³         ³     ³ry de selecao de titulos para melhor perfor-º±±
±±º          ³         ³     ³-mance conforme orientacao do setor Tecnolo-º±±
±±º          ³         ³     ³-gia.                                       º±±
±±º          ³         ³     ³                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk180Gera(cArqLog)

Local nY		:= 0									// Controle de loop
Local cFilOrig	:= ""									// Filial de Origem do titulo
Local cTipo		:= UPPER(GetNewPar("MV_TMKCOBR","")) 	// Contem os tipos de titulos que devem ser utilizados para cobranca
Local cSep		:= ""     								// Separador dos tipos de titulo utilizado na select 
Local lOrigSK1	:= Tk180Check()							// Indica se o campo de filial de origem (K1_FILORIG) esta presente no SIX e no SK1
Local aAlias	:= {"SE1"}								// Alias Utilizados (ASE1 - Processar os titulos a serem incluidos  BSE1- Processar os titulos a serem alterados)
Local nTot		:= 0									// Total de registros processados 
Local lTk180Grv := ExistBlock("TK180GRV")               // Ponto de entrada que sera executado apos a gravacao da tabela SK1


Local cQuery	:= ""  								// Query de pesquisa dos titulos na base de dados
Local nI		:= 0								// Controle de loop
Local cAbat		:= ""								// Tipo de titulo de abatimento
Local lTk180Qry	:= ExistBlock("TK180QRY") 			// Adiciona expressao na query


If ( Type("lTk180Auto") == "U" )
	lTk180Auto := .F.
EndIf

// Projeto Geracao Automatica de Titulos
Default cArqLog := ""
DbSelectArea("SK1")
ProcRegua(RecCount())

DbSelectArea("SE1")
DbSetOrder(7)	// FILIAL+DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atribui os separadores dos tipos de titulos a serem utilizados e os tipos de  titulos de abatimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cTipo)
	cSep:=	If("/" $ cTipo,"/",",") 
Endif


//Alias 
aAlias	:= {"ASE1","BSE1"}

//Atribui os tipos de titulo de abatimento na variavel que sera utilizada no select
For nI := 1 To Len(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM) Step 4
	cAbat := cAbat + "'" + SubStr(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM,nI,3) + "', "
Next nI
cAbat := SubStr(cAbat,1,Len(cAbat)-2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query 1 do SE1                                   ³
//³==============                                   ³
//³Verifica apenas o que precisa incluir no SK1     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Conout(DTOC(dDatabase) + Time() + STR0022)       //" TK180ATU 1- Inicio da query para filtrar os titulos que serao incluidos no SK1"
cQuery	:=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
			"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
			"			SE1.E1_PORTADO " +;
			" FROM " +	RetSqlName("SE1") + " SE1 " +;
			" WHERE "
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valido se os parametros estao preenchidos em virtude do Schedule. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
				cQuery	+=	" SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " 					
			Endif

cQuery	+=	" SE1.E1_VENCREA < '" + DtoS(dDataBase) + "' AND" 
			
			If !Empty(cTipo)
				cQuery	+=	" SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " AND " 
			Else
				cQuery	+=	" SE1.E1_TIPO NOT IN (" + cAbat + ") AND " 
			Endif
			
cQuery	+=	" SE1.E1_SALDO > 0 AND " +;
			" SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND " 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recebe o retorno do ponto de entrada que tem como objetivo inserir ³
//³uma expressao na query, de acordo com a regra de negocio do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lTk180Qry      
	cQuery	+= ExecBlock( "TK180QRY", .F., .F. ) + " AND "
Endif
		

cQuery 	+=	" SE1.D_E_L_E_T_ = '' " +;
			" AND NOT EXISTS " +;
			" 				(SELECT 1 "+;
			" 				FROM " + RetSqlName("SK1") + " SK1 " +;
			" 				WHERE K1_FILIAL = '" + xFilial("SK1") + "' AND " +;
			" 				SK1.K1_PREFIXO = SE1.E1_PREFIXO AND " +;				
			" 				SK1.K1_NUM = SE1.E1_NUM AND " +;								
			" 				SK1.K1_PARCELA = SE1.E1_PARCELA AND " +;								
			" 				SK1.K1_TIPO =  SE1.E1_TIPO AND " +;								
			" 				SK1.K1_FILORIG = SE1.E1_FILIAL AND " +;																																
			" 				SK1.D_E_L_E_T_ = '') "		
	
cQuery	:= ChangeQuery(cQuery)
MemoWrite("TMKA180AE1.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), aAlias[1], .F., .T.)
Conout(DTOC(dDatabase) + Time() + STR0023)		//" TK180ATU 2- Termino da query para filtrar os titulos que serao incluidos no SK1"
TCSetField(aAlias[1], "E1_VENCREA", "D")
TCSetField(aAlias[1], "E1_VENCTO", "D")



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query 2 do SE1                                   ³
//³==============                                   ³
//³Verifica apenas as modificacoes entre o SE1 e SK1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Conout(DTOC(dDatabase) + Time() +  STR0024)		//" TK180ATU 3- Inicio da query para filtrar os titulos que serao alterados  no SK1"
cQuery	:=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
			"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
			"			SE1.E1_PORTADO " +;
			" FROM " +	RetSqlName("SE1") + " SE1, " +	RetSqlName("SK1") + " SK1 " +;
			" WHERE SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' " +;
			" AND SE1.E1_PREFIXO 	= SK1.K1_PREFIXO " +;
			" AND SE1.E1_NUM 		= SK1.K1_NUM " +;
			" AND SE1.E1_PARCELA 	= SK1.K1_PARCELA " +;
			" AND SE1.E1_TIPO 		= SK1.K1_TIPO " +;
			" AND SE1.E1_FILIAL 	= SK1.K1_FILORIG "
			
			If !Empty(cTipo)
				cQuery	+=	" AND SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " " 
			Else
				cQuery	+=	" AND SE1.E1_TIPO NOT IN (" + cAbat + ") " 
			Endif

cQuery	+=	" AND SE1.E1_SALDO > 0 " +;
			" AND SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND " 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recebe o retorno do ponto de entrada que tem como objetivo inserir ³
//³uma expressao na query, de acordo com a regra de negocio do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lTk180Qry      
	cQuery	+= ExecBlock( "TK180QRY", .F., .F. )	+ " AND "
Endif
		
cQuery 	+=	"   SE1.D_E_L_E_T_ = '' " +;
			" 	AND SK1.D_E_L_E_T_ = '' " +;
			" 	AND (SK1.K1_VENCTO <> SE1.E1_VENCTO " +;
			" 	OR 	SK1.K1_VENCREA <> SE1.E1_VENCREA " +;
			" 	OR 	SK1.K1_NATUREZ <> SE1.E1_NATUREZ " +;
			" 	OR 	SK1.K1_PORTADO <> SE1.E1_PORTADO " +;
			" 	OR 	SK1.K1_SITUACA <> SE1.E1_SITUACA " 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o campo existir, verifico se alterou o valor do titulo atraves do saldo restante.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			cQuery 	+=	" 	OR 	SK1.K1_SALDO <> SE1.E1_SALDO) "  


cQuery	:= ChangeQuery(cQuery)
MemoWrite("TMKA180BE1.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), aAlias[2], .F., .T.)
Conout(DTOC(dDatabase) + Time() + STR0025)        //" TK180ATU 4- Termino da query para filtrar os titulos que serao alterados  no SK1"
TCSetField(aAlias[2], "E1_VENCREA", "D")
TCSetField(aAlias[2], "E1_VENCTO", "D")

For nY := 1 to Len(aAlias)
	Conout(DTOC(dDatabase) + Time() + STR0026 + aAlias[nY] )  	//" TK180ATU 5- Inicio do processamento para "
    nTot:= 0
    
    DbSelectArea(aAlias[nY])
	While (aAlias[nY])->(!Eof()) 
	    nTot++
		cFilOrig	:= (aAlias[nY])->E1_FILIAL	//Filial de origem do titulo
  	
	  	//Valida se o cliente existe na base de dados
	  	Dbselectarea("SA1")
	  	DbsetOrder(1)
	  	If !DbSeek(xFilial("SA1")+ (aAlias[nY])->E1_CLIENTE + (aAlias[nY])->E1_LOJA)
			DbSelectArea(aAlias[nY])
			(aAlias[nY])->(DbSkip())
			Loop
		Endif
		
		// Somente incrementa a regua se nao for rotina automatica
		If !lTk180Auto
			IncProc()
		Endif
	    
	    //Se nao existir o campo K1_FILORIG no SIX nao utiliza a filial de origem na chave de busca.
		If !lOrigSK1	
			cFilorig:= ""
		Endif
			
		DbSelectArea("SK1")
		DbSetOrder(1)
		If DbSeek(xFilial("SK1")+ (aAlias[nY])->E1_PREFIXO + (aAlias[nY])->E1_NUM + (aAlias[nY])->E1_PARCELA + (aAlias[nY])->E1_TIPO + cFilOrig)
			RecLock("SK1",.F.)
          //Se data de vencimento real alterada e titulo passou para a situacao de A VENCER, exclui o titulo da tabela SK1
          If DTOS((aAlias[nY])->E1_VENCREA) >= DTOS(dDataBase)
	          	SK1->(dbDelete())
          Else
				REPLACE SK1->K1_VENCTO	WITH (aAlias[nY])->E1_VENCTO
				REPLACE SK1->K1_VENCREA	WITH (aAlias[nY])->E1_VENCREA
				REPLACE SK1->K1_NATUREZ	WITH (aAlias[nY])->E1_NATUREZ
				REPLACE SK1->K1_PORTADO	WITH (aAlias[nY])->E1_PORTADO
				REPLACE SK1->K1_SITUACA	WITH (aAlias[nY])->E1_SITUACA
				REPLACE SK1->K1_SALDO WITH (aAlias[nY])->E1_SALDO
				REPLACE SK1->K1_SALDEC WITH 100000 - (aAlias[nY])->E1_SALDO
			Endif
	
			MsUnLock()
		Else
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando estiver em ambiente codebase, somente na inclusao tratar se o vencimento e menor que a database³
			//³em ambiente top a query ja realiza esse tratamento.                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			RecLock("SK1",.T.)
			REPLACE SK1->K1_FILIAL	WITH xFilial("SK1")
			REPLACE SK1->K1_PREFIXO	WITH (aAlias[nY])->E1_PREFIXO
			REPLACE SK1->K1_NUM		WITH (aAlias[nY])->E1_NUM
			REPLACE SK1->K1_PARCELA	WITH (aAlias[nY])->E1_PARCELA
			REPLACE SK1->K1_TIPO	WITH (aAlias[nY])->E1_TIPO
			REPLACE SK1->K1_VENCTO	WITH (aAlias[nY])->E1_VENCTO
			REPLACE SK1->K1_VENCREA	WITH (aAlias[nY])->E1_VENCREA
			REPLACE SK1->K1_CLIENTE	WITH (aAlias[nY])->E1_CLIENTE
			REPLACE SK1->K1_LOJA	WITH (aAlias[nY])->E1_LOJA
			REPLACE SK1->K1_NATUREZ	WITH (aAlias[nY])->E1_NATUREZ
			REPLACE SK1->K1_PORTADO	WITH (aAlias[nY])->E1_PORTADO
			REPLACE SK1->K1_SITUACA	WITH (aAlias[nY])->E1_SITUACA 
			REPLACE SK1->K1_FILORIG	WITH cFilOrig
			REPLACE SK1->K1_SALDO WITH (aAlias[nY])->E1_SALDO
			REPLACE SK1->K1_SALDEC WITH 100000 - (aAlias[nY])->E1_SALDO

			MsUnLock()
		Endif
		
		If lTk180Grv
			ExecBlock("TK180GRV",.F.,.F.,{(aAlias[nY])->E1_CLIENTE,(aAlias[nY])->E1_LOJA})
		Endif
				
		DbSelectArea(aAlias[nY])
		DbSkip()
	End
	

	DbSelectArea(aAlias[nY])
	DbCloseArea()


	Conout(DTOC(dDatabase) + Time() + STR0027 + aAlias[nY] + STR0028 + StrZero(nTot,10))    //" TK180ATU 6- Termino do processamento para "   /" Total de titulos processados = "

Next nY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o parametro MV_TMKSK1 que indica quando foi feita a ultima atualizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SX6")
DbSetOrder(1)
PutMv("MV_TMKSK1",DtoC(dDatabase)+"-"+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a criacao LOG de inconsistencias do SK1, SOMENTE TOP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If MV_PAR03 == 2
	// Projeto Geracao Automatica de Titulos
	Tk180VerK1(@cArqLog)
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk180ToolsºAutor  ³Armando M. Tessaroliº Data ³  29/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para selecao dos Cliente apresentados no browser paraº±±
±±º          ³serem transferidos.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMichel W. ³04/04/07 ³ 9.12³ BOPS 115782 - Implementacao da FillGetDadosº±±
±±º          ³         ³     ³Passou a utilizar o objeto msSelect, alteranº±±
±±º          ³         ³     ³-do o uso de aCols e aHeader por arquivo de º±±
±±º          ³         ³     ³trabalho.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk180Tools(nTipo, cAliasTRB, lCheck, oSelect)

If nTipo == 1  
	(cAliasTRB)->(dbGoTop())                               
	While (cAliasTRB)->(!EOF())  
		Reclock(cAliasTRB, .F.)	
		If lCheck
			(cAliasTRB)->TMP_OK := "x"
		Else
			(cAliasTRB)->TMP_OK := " "
		Endif		                    
		MsUnlock()	
		(cAliasTRB)->(dbSkip())				
	End
Else   
	(cAliasTRB)->(dbGoTop())                               
	While (cAliasTRB)->(!EOF())  
		Reclock(cAliasTRB, .F.)	    
		(cAliasTRB)->TMP_OK := IIF((cAliasTRB)->TMP_OK=="x"," ","x") 
		MsUnlock()	
		(cAliasTRB)->(dbSkip())				
	End
Endif
(cAliasTRB)->(dbGoTop()) 
oSelect:oBrowse:Refresh()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk180Acao ºAutor  ³Armando M. Tessaroliº Data ³  28/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para atualizacao do SK1 de acordo com a operacao     º±±
±±º          ³escolhida - Marcar ou inverter a selecao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMichel W. ³04/04/07 ³ 9.12³ BOPS 115782 - Implementacao da FillGetDadosº±±
±±º          ³         ³     ³Passou a utilizar o objeto msSelect, passan-º±±
±±º          ³         ³     ³-do a utilizar diretamente o aCols e aHeaderº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk180Acao(aHeader, aCols, lAcao)

Local nI		:= 0														// Controle de Loop
Local nPPrefix	:= Ascan(aHeader, {|x| x[2] == "K1_PREFIXO"} )		// Ponteiro de array
Local nPTitulo	:= Ascan(aHeader, {|x| x[2] == "K1_NUM    "} )		// Ponteiro de array
Local nPParcel	:= Ascan(aHeader, {|x| x[2] == "K1_PARCELA"} )		// Ponteiro de array
Local nPTipo	:= Ascan(aHeader, {|x| x[2] == "K1_TIPO   "} )		// Ponteiro de array   
Local cAcao		:= IIF(lAcao,"XXXXXX","")									// Conteudo a ser gravado na base
Local lApaga	:= .F.														// Se o titulo desmarcado ja foi pago, elimina do SK1
Local nPFilOrig	:= 0                                                       	// Ponteiro de array que indicara a filial de origem do titulo
Local cFilOrig	:= ""                                                      	// Filial de Origem do titulo
                     
nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "K1_FILORIG"} )   //Ponteiro de array


For nI := 1 To Len(aCols)
	If aCols[nI][1] == "LBOK" 
		
		If nPFilOrig > 0
			cFilOrig:= aCols[nI][nPFilOrig]
		Else
			cFilOrig:= xFilial("SE1")
		Endif
			
		DbSelectArea("SK1")
		DbSetOrder(1)		// K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG
		If DbSeek(xFilial("SK1") + aCols[nI][nPPrefix] + aCols[nI][nPTitulo] + aCols[nI][nPParcel] + aCols[nI][nPTipo] + cFilOrig)
			If !lAcao		// Desmarcar o titulo
				DbSelectarea("SE1")
				DbSetOrder(1)
				If DbSeek(cFilOrig + aCols[nI][nPPrefix] + aCols[nI][nPTitulo] + aCols[nI][nPParcel] + aCols[nI][nPTipo])
					If SE1->E1_SALDO <= 0
						lApaga := .T.
					Endif
				Endif
			Endif
			If lApaga
				RecLock("SK1", .F., .T.)
				DbDelete()
			Else
				RecLock("SK1", .F.)
				SK1->K1_OPERAD := cAcao
			Endif
			MsUnLock()
			lApaga := .F.
		Endif
	Endif
Next nI

Return(.T.)
                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk180Dic  ºAutor  ³Andrea Farias       º Data ³  14/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avalia quando o SE1 estiver EXCLUSIVO se o  dicionario      º±±
±±º          ³esta  compatibilizado  para cobranca entre filiais.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TELECOBRANCA - CALL CENTER                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk180Dic()

Local aArea	:= GetArea()	// Salva a area atual
Local lRet	:= .F.     		// Retorno da Funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os campos para cobranca de filiais estao na base de dados.³
//³Se os indices foram alterados.                                    	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Dbselectarea("SIX")
DbSetOrder(1)
If DbSeek("SK1")
	If ORDEM == "1" .AND. "K1_FILORIG" $ CHAVE 
		If DbSeek("ACG") 
			If ORDEM == "1" .AND. "ACG_FILORI" $ CHAVE   
				lRet:= .T.
			Endif
		Endif			 	
	Endif				
EndIf


RestArea(aArea)                            
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk180CheckºAutor  ³Microsiga           º Data ³  05/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk180Check()
             
Local aArea	:= GetArea()	// Salva a area atual
Local lRet	:= .F.     		// Retorno da Funcao

Dbselectarea("SIX")
DbSetOrder(1)
If DbSeek("SK11") 
	If "K1_FILORIG" $ CHAVE
 		lRet:=.T.
    Endif
Endif

RestArea(aArea)                            
Return(lRet)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk180ColToTrb   ³ Autor ³ Michel Mosca    ³ Data ³04/04/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte o aCols em arquivo de trabalho para utilizar com  ³±±
±±³			 ³o objeto MSSelect.            							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk180ColToTrb(	ExpC1, ExpA2, ExpA3, ExpA4,  			  ³±±
±±³			 ³					ExpA5, ExpC6, ExpC7, ExpC8,  			  ³±±
±±³			 ³					ExpC9)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do alias do arquivo de trabalho				  ³±±
±±³			 ³ ExpA2 = Array com definicoes dos campos a serem exibidos   ³±±
±±³			 ³ ExpA3 = Array com informacoes do arquivo de trabalho		  ³±±
±±³			 ³ ExpA4 = Array com o aCols      						      ³±±
±±³			 ³ ExpA5 = Array com o aHeader                             	  ³±±
±±³			 ³ ExpC6 = Nome do campo com CheckBox no aHeader              ³±±
±±³			 ³ ExpC7 = Nome do campo com checkbox no arquivo de trabalho  ³±±
±±³			 ³ ExpC8 = Valor atribuido no check box do acols para true    ³±±
±±³			 ³ ExpC9 = Valor atribuido no check box do acols para false   ³±±
±±³			 ³ ExpC10= Valor atribuido no arquivo de trabalho para true   ³±±
±±³			 ³ ExpC11= Valor atribuido no arquivo de trabalho para false  ³±±
±±³			 ³                              							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka180					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function Tk180ColToTrb(cAliasTRB, aCpos, aCols, aHeader, cChkBoxName, cChkTrbName, cOkName, cFalseName, cTrbOkValue, cTrbFalseValue) 
Local aStruSel := {}         	// Armazena a estrutura do arquivo de trabalho
Local nCols					 	// Utilizado em loop do acols
Local nHeader					// Utilizado em loop do aheader
Local cField					// Armazena o campo atual que está sendo alterado no arquivo de trabalho
            
aStruSel := {}
Tk180TrbHead(@aStruSel, @aCpos, cChkTrbName, aHeader)


cAliasTRB := GetNextAlias()
//-------------------------------------------------------------------
// Criação do objeto  
//-------------------------------------------------------------------
oTempTable := FWTemporaryTable():New( cAliasTRB )

//-------------------------------------------------------------------
// Atribui campos e índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aStruSel )


//------------------
//Criação da tabela
//------------------
oTempTable:Create()



// Atribui os valores do aCols no arquivo de trabalho
For nCols := 1 To Len(aCols)
	DbSelectArea(cAliasTRB)
	Reclock(cAliasTRB, .T.)	
	For nHeader := 1 To Len(aHeader)
		cField := aHeader[nHeader][2] 
		If Upper(AllTrim(aHeader[nHeader][2])) == Upper(AllTrim(cChkBoxName))
			If Upper(AllTrim(cOkName)) == Upper(AllTrim(aCols[nCols][nHeader]))
				Eval(&("{|xValue| " + cAliasTRB + "->" + cChkTrbName + " := xValue}"), cTrbOkValue)
			Else                                            
				Eval(&("{|xValue| " + cAliasTRB + "->" + cChkTrbName + " := xValue}"), cTrbFalseValue) 
			EndIf		 			
		Else
			If IsHeadAlias(aHeader[nHeader][2])
				cField := "TRB_ALI_WT" 
			ElseIf IsHeadRec(aHeader[nHeader][2])
				cField := "TRB_REC_WT" 			
			EndIf
			Eval(&("{|xValue| " + cAliasTRB + "->" + cField + " := xValue}"), aCols[nCols][nHeader])
		EndIf
	Next nHeader           
	MsUnlock()	
Next nCols	  
(cAliasTRB)->(dbGoTop())       

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |Tk180TrbToCol   ³ Autor ³ Michel Mosca    ³ Data ³04/04/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte o arquivo de trabalho para o aCols com o objeto   ³±±
±±³			 ³MSSelect.            							 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk180ColToTrb(	ExpC1, ExpA2, ExpA3, ExpA4,   			  ³±±
±±³			 ³					ExpC5, ExpC6, ExpC7, ExpC8)  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do alias do arquivo de trabalho				  ³±±
±±³			 ³ ExpA2 = Array com informacoes do arquivo de trabalho		  ³±±
±±³			 ³ ExpA3 = Array com o aCols      						      ³±±
±±³			 ³ ExpA4 = Array com o aHeader                             	  ³±±
±±³			 ³ ExpC5 = Nome do campo com CheckBox no aHeader              ³±±
±±³			 ³ ExpC6 = Nome do campo com checkbox no arquivo de trabalho  ³±±
±±³			 ³ ExpC7 = Valor atribuido no check box do acols para true    ³±±
±±³			 ³ ExpC8 = Valor atribuido no check box do acols para false   ³±±
±±³			 ³ ExpC9 = Valor atribuido no arquivo de trabalho para true   ³±±
±±³			 ³ ExpC10= Valor atribuido no arquivo de trabalho para false  ³±±
±±³			 ³                              							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka180					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function Tk180TrbToCol(cAliasTRB, aCols, aHeader, cChkBoxName, cChkTrbName, cOkName, cFalseName, cTrbOkValue, cTrbFalseValue)
Local nChk	:= Ascan(aHeader, {|x| x[2] == Upper(AllTrim(cChkBoxName))} )		// Ponteiro de array
Local nCols 	:= 1															// Utilizado no Loop do aCols

(cAliasTRB)->(dbGoTop())                               
While (cAliasTRB)->(!EOF())
  	aCols[nCols][nChk]	:= IIf(Eval(&("{|| " + cAliasTRB + "->" + cChkTrbName + "}"))==cTrbOkValue,cOkName, cFalseName)	 
	nCols++
	(cAliasTRB)->(dbSkip())	
End
(cAliasTRB)->(dbGoTop()) 

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk180TrbHead    ³ Autor ³ Michel Mosca    ³ Data ³04/04/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria a estrutura do arquivo de trabalho 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk180TrbHead(ExpA1, ExpA2, ExpC3, ExpA4)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com definicoes dos campos a serem exibidos   ³±±
±±³			 ³ ExpA2 = Nome dos campos para exibicao					  ³±±
±±³			 ³ ExpC3 = Nome da coluna do CheckBox						  ³±±
±±³			 ³ ExpA4 = Array com o aHeader     							  ³±±
±±³			 ³                              							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka180					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function Tk180TrbHead(aStruSel, aCpos, cChkTrbName, aHeader)
Local nHeader		// utilizado no loop do aHeader  
Local cField		// nome do campo a ser inserido no arquivo de trabalho                                      

/*
aStruct[X][1] := Nome do campo
aStruct[X][2] := Tipo de dado
aStruct[X][3] := Tamanho
aStruct[X][4] := Casas decimais
*/          
Aadd(aStruSel, {cChkTrbName    , "C",  1, 0} ) 
Aadd(aCpos, {cChkTrbName    , "", ""                , ""})
For nHeader := 2 To Len(aHeader)   
	cField := aHeader[nHeader][2] 
	If IsHeadAlias(aHeader[nHeader][2])
		cField := "TRB_ALI_WT" 
	ElseIf IsHeadRec(aHeader[nHeader][2])
		cField := "TRB_REC_WT" 			
	EndIf
	Aadd(aStruSel, {	cField, aHeader[nHeader][8], aHeader[nHeader][4], aHeader[nHeader][5]})
	Aadd(aCpos, {cField, "", aHeader[nHeader][1] , ""})
Next nHeader

Return(.T.)           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |Tk180CloseTrb   ³ Autor ³ Michel Mosca    ³ Data ³04/04/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fecha o arquivo de trabalho criado a partir do aCols.      ³±±
±±³			 ³                     							 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk180CloseTrb(	ExpA1)                        			  ³±±
±±³			 ³					                             			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA2 = Array com informacoes do arquivo de trabalho		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka180					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function Tk180CloseTrb()

	If( valtype(oTempTable) == "O")
		oTempTable:Delete()
		freeObj(oTempTable)
		oTempTable := nil
	
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk180VerK1ºAutor  ³Hanna Caroline      º Data ³  01/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validar se todos os campos "obrigatorios" do SK1º±±
±±º          ³estao preenchidos - Gera LOG                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk180VerK1(cArqLog)
Local nHandle	:= 0 		// CRIA ARQUIVO READ ONLY DE LOG PARA SK1
Local cQuery	:= ""  		// Query de pesquisa dos titulos na base de dados
Local cText		:= ""  		// Texto que sera gravado no LOG
Local cPath		:= Alltrim(GetMV('MV_RELT'))

Default cArqLog := "TMKSK1INCON.LOG"  // arquivo default para geracao de Log

// Projeto Geracao Automatica de Titulos
if ExecSchedule()
	cArqLog := cPath+"TMKA185_"+Dtos(dDataBase)+Left(Time(),2)+Substr(Time(),4,2)+".LOG"
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica apenas o que precisa incluir no SK1     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Conout(DTOC(dDatabase) + Time() + " TK180SK1 1- Inicio da query para filtrar os registros do SK1 com inconsistencia")
cQuery	:=	" SELECT	SK1.K1_PREFIXO, SK1.K1_NUM,		SK1.K1_PARCELA, SK1.K1_TIPO, SK1.K1_VENCTO, " +;
			"			SK1.K1_VENCREA, SK1.K1_FILIAL,	SK1.K1_CLIENTE, SK1.K1_LOJA" +;
			" FROM " +	RetSqlName("SK1") + " SK1 " +;
			" WHERE "
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valido se os parametros estao preenchidos em virtude do Schedule. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
				cQuery	+=	" SK1.K1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " 					
			Endif
			cQuery	+=	"( SK1.K1_VENCREA	= '' OR	"+;
						" SK1.K1_VENCTO		= '' OR	"+;
						" SK1.K1_CLIENTE	= '' OR	"+;
						" SK1.K1_PREFIXO	= '' OR	"+;
						" SK1.K1_NUM		= '')AND"+;
						" SK1.D_E_L_E_T_	= ''	"

cQuery	:= ChangeQuery( cQuery )
MemoWrite("TMKA180SK1.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
Conout(DTOC(dDatabase) + Time() + " TK180SK1 1- Termino da query para filtrar os registros do SK1 com inconsistencia")

TRB->( DbGotop() )

If TRB->( !EOF() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso existam registros selecionados pelo SELECT - Apaga o arquivo, gera um novo LOG ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cArqLog)
		nHandle := FCREATE(cArqLog,1)
	Else
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua a delecao do arquivo para geracao de novo log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nErase := FERASE(cArqLog)   
		
		While nErase == -1 
			nErase := FERASE(cArqLog)
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria novo Log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHandle := FCREATE(cArqLog,1)
	Endif
Endif


While TRB->( !EOF() )

	cText :=	"Prefixo: "	+ TRB->K1_PREFIXO		+ " Numero: "	+ TRB->K1_NUM		+ ;
				" Parcela: "+ TRB->K1_PARCELA		+ " Tipo: "		+ TRB->K1_TIPO		+ ;
				" Vencto: "	+ TRB->K1_VENCTO		+ " Vencto Real: "+ TRB->K1_VENCREA	+ ;
				" Filial: "	+ TRB->K1_FILIAL		+ " Cliente: "	+ TRB->K1_CLIENTE	+ ;
				" Loja: "	+ TRB->K1_LOJA

	// Projeto Geracao Automatica de Titulos
	if Type("aMsgSch") == "A"
		Aadd(aMsgSch, cText)
	Endif	

	FWrite(nHandle, cText) 
	TRB->( DbSkip() )
End

// nao gerou arquivo
if nHandle == 0
	cArqLog := ""
Endif	

DbSelectArea("TRB")
DbCloseArea()
FClose(nHandle)
Return           

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ExecSchedule³ Autor ³ Aldo Barbosa dos Santos      ³01/07/11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna se o programa esta sendo executado via schedule     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExecSchedule()
Local lRetorno := .T.

lRetorno := IsBlind()

Return( lRetorno )
