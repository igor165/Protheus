#INCLUDE "TMKA150.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³  ARRAY ASIZE - Tamannhos da Dialog e Area de Trabalho									³
³                        																³
³ 1 -> Linha inicial area trabalho														³
³ 2 -> Coluna inicial area trabalho														³
³ 3 -> Linha final area trabalho														³
³ 4 -> Coluna final area trabalho														³
³ 5 -> Coluna final dialog																³
³ 6 -> Linha final dialog																³
³ 7 -> Linha inicial dialog																³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³																						³
³  ARRAY AOBJECTS - Tamanhos Default dos Objetos para o calculo das posicoes			³
³                        																³
³ 1 - Tamanho X																			³
³ 2 - Tamanho Y																			³
³ 3 - Dimensiona X																		³
³ 4 - Dimensiona Y																		³
³ 5 - Retorna dimensoes X e Y (SIZE) ao inves de linha / coluna final					³	
³																						³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³  ARRAY AINFO - Tamanhos da Area onde sera calculado as posicoes dos objetos			³
³                        																³
³ 1 - Posicao Inicial X																	³
³ 2 - Posicao Inicial Y                                                                 ³ 
³ 3 - Posicao Final X																	³
³ 4 - Posicao Final Y                                                                   ³ 
³ 5 - Espaco lateralmente entre os objetos                                              ³ 
³ 6 - Espaco verticalmente entre os objetos                                             ³ 
³																						³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ TMKA150	³ Autor ³ Vendas Clientes  		³ Data ³ 28/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao de Notas Fiscais								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 		 ³ CALL CENTER 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMKA150()                        

// Manter identico a Legenda do Televendas
Local aCores2    := {	{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. Empty(SUA->UA_DOC))" 	, "BR_VERDE"   	},;	// Faturamento - VERDE
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. !Empty(SUA->UA_DOC))"	, "BR_VERMELHO"	},;	// Faturado - VERMELHO
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2)"							, "BR_AZUL"   	},;	// Orcamento - AZUL
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 3)"							, "BR_MARRON" 	},; // Atendimento - MARRON
   						{"(!EMPTY(SUA->UA_CODCANC))"														, "BR_PRETO"	}} 	// Cancelado - PRETO

Private cCadastro := STR0002	//"Excluir"
Private aRotina   := MenuDef() 	//Vetor aRotina utilizado na mBrowse


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Protege rotina para que seja usada apenas no SIGATMK ou SIGACRM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !AMIIn(13,73)			// 13 = SIGATMK, 73 = SIGACRM
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endere‡a a fun‡„o de BROWSE									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SUA",,,,,,aCores2)

Return(.T.)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas Clientes       ³ Data ³08/12/06  ³±±
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

Local aRotina:=	{  		{ STR0001	,"AxPesqui"   	   , 0 , 1 , , .F.},;	//"Pesquisa"
						{ STR0002	,"Tk150Exclusao"   , 0 , 5 , , .T.},;	//"Excluir"
						{ STR0024  	,"Tk150Legenda"    , 0 , 2 , , .T.}}	//"Legenda"


Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ TK150Exclusao ³ Autor ³ Vendas Clientes	³ Data ³ 28/10/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de exclusao de Pedidos             				   ³±±
±±³          ³ Somente atendimentos do tipo ORCAMENTO e FATURAMENTO        ³±±
±±³          ³ serao alterados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TK150Exc(ExpC1,ExpN1,ExpN2)								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo					  			  	   ³±±
±±³			 ³ ExpN1 = Numero do registro 								   ³±±
±±³			 ³ ExpN2 = Opcao selecionada								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CALL CENTER 												   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK150Exclusao(cAlias,nReg,nOpc)

Local aSize      	:= MsAdvSize( .T., .F., 400 )					// Size da Dialog
Local aObjects   	:= {}											// Definicoes dos objetos
Local aPosObj    	:= {}											// Posicao dos Objetos Enchoice e Getdados
Local aInfo      	:= {}											// Dimensoes da area a ser dividida entre os objetos
Local aPosGet    	:= {}											// Posicoes dos Gets

Local oDlg															// Objeto para tela
Local oGet															// Objeto para GetDados
Local oEnchoice														// Objeto para Enchoice
Local cTipo		 	:= ""											// Tipo do Cliente ou Prospect (Consumidor, etc...)
Local lOrcamento 	:= .F.											// Flag para apontar se e um ORCAMENTO
Local cOpfat     	:= GetMV("MV_OPFAT") 							// Parametro que Gera ou nao a nota fiscal
Local cTmkLoj     	:= GetMV("MV_TMKLOJ")							// Parametro que indica integracao com SIGALOJA
Local lRet			:= .F.											// Retorno da funcao
Local cEstacao	:= ""												// Codigo da estacao

Local aAC        	:= {STR0003,STR0004}							// Usado nas Enchoices "Abandona","Confirma"
Local aObj[7]							  							// Array com os objetos utilizados no Folder do rodape
Local aTitlesRodape := {STR0005,STR0006}							//"Totais","Impostos"
Local aPages        := {"HEADER","HEADER"}							// Carrega os valores da Funcao fiscal e executa o Refresh	
Local bListRefresh  := {|| (MaFisToCols(aHeader,aCols,,"TMK271")),Eval(bRefresh),Eval(bGdRefresh)}	// Codigo para atualizar referencias fiscais
Local bRefresh		:= {|| (Tk150Refresh(aObj))}	    			// Efetua o Refresh da NF
Local aGrupos		:= {}											// Retorno de array
Local lApaga		:= .F.											// Flag de controle para delecao
Local lTmk150 		:= ExistBlock("TMK150EXC")                 		// P.E. na exclusao do pedido de vendas, antes de qualquer validacao.
	
Private aTELA[0][0]													// Vetor com informacoes genericas para a enchoice
Private aGETS[0]													// Vetor com informacoes genericas para a enchoice
Private aHeader[0]													// Cabecalho dos itens da getdados
Private aCols														// Itens da getdados
Private nUsado      := 0											// Contador de campos utilizados
Private aValores    := {0,0,0,0,0,0}         						// Array com os valores dos objetos utilizados no Folder do rodape
                                        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o usuario pode excluir a Nota Fiscal    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkPsw(21)  // Exclui pedidos de venda
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e apenas um ATENDIMENTO					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VAL(SUA->UA_OPER) == ATENDIMENTO
	Help(" ",1,"TMKCANTLV")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o atendimento NAO ESTA CANCELADO			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ALLTRIM(SUA->UA_CANC) == "S"
	Help(" ",1,"TMKCANTLV")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a emissao da NF esta dentro da validade	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SUA->UA_DOC) .AND. ALLTRIM(UA_STATUS) == "NF."
	If Month(SUA->UA_EMISSAO) <> Month(dDataBase) .OR. Year(SUA->UA_EMISSAO) <> Year(dDataBase)
		Help(" ",1,"FORA_MES")
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o cadastro de estacao esta correto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If SU7->(ColumnPos("U7_ESTACAO")) > 0 .AND. !Empty(SU7->U7_ESTACAO)
	cEstacao := TkPosto(SUA->UA_OPERADO,"U7_ESTACAO")	//Pega o codigo da ESTACAO do OPERADOR
Else
	cEstacao := TkPosto(SUA->UA_OPERADO,"U0_ESTACAO") //Pega o codigo da ESTACAO do GRUPO DE ATENDIMENTO
EndIf

If ValType(cEstacao) <> "C"
	MsgStop(STR0031, STR0030) // "Cadastre um Grupo de Atendimento válido no parâmetro MV_POSTO." // "Atenção"
    Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente o operador que fez a venda pode excluir a nota³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk150CodVen() == SUA->UA_VEND
	If !Empty(SUA->UA_VEND)
		lApaga := .T.
	Endif
Endif                                                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o operador for supervisor pode excluir a nota      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(Posicione( "SU7", 4, xFilial("SU7") + __cUserID, "U7_TIPO")) == SUPERVISOR
	lApaga := .T.
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a senha for do ADMINISTRADOR ou o usuario pertencer ³
//³ao grupo de administradores o pedido pode ser apagado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lApaga
	If ( __cUserID == "000000" )
		lApaga := .T.
	Else	
		// Para verificar se faz parte do grupo de administradores
		PswOrder(1)
		If (PswSeek(__cUserID) )
			aGrupos := Pswret(1)
			If ( Ascan(aGrupos[1][10],"000000") <> 0 )
				lApaga := .T.
			Endif
		Endif
	Endif
Endif

If !lApaga
	Help(" ",1,"OUTROVEND")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se ‚ um Orcamento ou um Faturamento           		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VAL(SUA->UA_OPER) == ORCAMENTO  
	lOrcamento := .T.	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existe integracao com SIGALOJA nao exclui o orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTmkLoj == "S")
		Help(" ",1,"ORC_LOJA")
		Return(lRet)
	Endif

ElseIf VAL(SUA->UA_OPER) == FATURAMENTO
	lOrcamento := .F.    
       
	If lTmk150 
		lRet := ExecBlock("TMK150EXC",.F.,.F.)
		If !lRet
			Return(lRet)
		Else 
			lRet := .F.
		Endif 
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se o MV_OPFAT ‚ Sim ou Pergunta               	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOpFat == "S" .OR. cOpFat == "P"

		//ÚÄLocalizacoesÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se n„o tiver sido REMITITDO ou tiver a RM cancelado entao pode-se cancelar o pedido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUA->UA_STATUS == "RM."
			Help(" ",1,"RM.ENVIADA")
			Return(lRet)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida a integracao de orcamentos para o SIGALOJA          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SUA->UA_NUMSL1)
			Help(" ",1,"ORC_LOJA")
			Return(lRet)
		Endif
	Endif		
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os dados do cliente na FUNCAO FISCAL  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SUA->UA_PROSPEC)	
	cTipo := Posicione("SUS",1,xFilial("SUS") + SUA->UA_CLIENTE + SUA->UA_LOJA,"US_TIPO")
Else
	cTipo := Posicione("SA1",1,xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,"A1_TIPO")
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os dados do cliente na FUNCAO FISCAL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisIni(SUA->UA_CLIENTE,;	// 1-Codigo Cliente/Fornecedor
		 SUA->UA_LOJA,;		// 2-Loja do Cliente/Fornecedor
		 "C",;				// 3-C:Cliente , F:Fornecedor
		 "N",;				// 4-Tipo da NF
		 cTipo,;			// 5-Tipo do Cliente/Fornecedor
		 Nil,;				// 6-Relacao de Impostos que suportados no arquivo
		 Nil,;				// 7-Tipo de complemento
		 Nil,;				// 8-Permite Incluir Impostos no Rodape .T./.F.
		 Nil,;				// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		 Nil,;				// 10-Nome da rotina que esta utilizando a funcao
		 Nil,;				// 11-Tipo de documento
		 Nil,;  			// 12-Especie do documento 
	     IIF(SUA->UA_PROSPEC,SUA->UA_CLIENTE+SUA->UA_LOJA,""))// 13- Codigo e Loja do Prospect 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o aHeader e o aCols.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk150Config(SUA->UA_NUM, nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os dados para a enchoice.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetorder(1)
DbSeek("SUA")
While ( !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == "SUA")
	If X3USO(SX3->X3_USADO) .OR. (AllTrim(X3_CAMPO) == "UA_DOC") .OR. (AllTrim(X3_CAMPO) == "UA_SERIE")
		cCampo := SX3->X3_CAMPO
		If (X3_CONTEXT == "V")
			M->&(cCampo) := CriaVar(cCampo,.T.)
		Else
			M->&(cCampo) := SUA->&(cCampo)
		Endif
	Endif
	DbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divide a tela lateralmente para a Enchoice e a Getdados             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T.} )
AAdd( aObjects, { 100, 100, .T., .T.} )
AAdd( aObjects, {  66, 65 , .T., .F., .T.} )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj := MsObjSize( aInfo, aObjects,, .F. )
aPosGet := MsObjGetPos(aSize[3]-aSize[1],263,{{5,60,140,185},{260}})

cCadastro:= STR0002
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
    lRet := .T.
    
	Zero()
	oEnchoice:= MsMGet():New("SUA", nReg, nOpc, aAC,"AC",STR0007,,aPosObj[1],,,,,,oDlg,,.T.,,"aTela" ) 	//"Quanto a exclusao ?"
	
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,"")
	
	oFoldRodape := TFolder():New(aPosObj[3,1], aPosObj[3,2],aTitlesRodape,aPages,oDlg,,,, .T., .F.,aPosObj[3,3], aPosObj[3,4],)
	
	// FOLDER DE TOTALIZADORES
	@ 5,aPosGet[1,1]  SAY STR0008 OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,9 //"Valor Mercadoria"
	@ 4,aPosGet[1,2]  MSGET aObj[MERCADORIA] VAR aValores[MERCADORIA] Picture PesqPict('SUA','UA_VALMERC') OF oFoldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 70 ,9
	
	@ 19,aPosGet[1,1] SAY STR0009 OF oFoldRodape:aDialogs[1] PIXEL SIZE 58,9 //"Acrescimo"
	@ 19,aPosGet[1,2] MSGET aObj[ACRESCIMO] VAR aValores[ACRESCIMO] Picture PesqPict('SUA','UA_ACRECND') OF oFoldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 70 ,9
	
	@ 33,aPosGet[1,1] SAY STR0010 OF oFoldRodape:aDialogs[1] PIXEL SIZE 50,9 //"Despesas"
	@ 33,aPosGet[1,2] MSGET aObj[DESPESA] VAR aValores[DESPESA] Picture PesqPict('SUA','UA_DESPESA') OF oFoldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 70 ,9
	
	@ 5,aPosGet[1,3]  SAY STR0011 OF oFoldRodape:aDialogs[1] PIXEL SIZE 49,9 //"Descontos"
	@ 4,aPosGet[1,4]  MSGET aObj[DESCONTO] VAR aValores[DESCONTO] Picture PesqPict('SUA','UA_DESCONT') OF oFoldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 70 ,9
	
	@ 19,aPosGet[1,3] SAY STR0012 OF oFoldRodape:aDialogs[1] PIXEL SIZE 45,9 //"Valor do Frete"
	@ 19,aPosGet[1,4] MSGET aObj[FRETE] VAR aValores[FRETE]  Picture PesqPict('SUA','UA_FRETE') OF oFoldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 70 ,9
	
	@ 33,aPosGet[1,3] SAY STR0013 OF oFoldRodape:aDialogs[1] PIXEL SIZE 58,9 COLOR CLR_RED //"Total do Pedido"
	@ 33,aPosGet[1,4] MSGET aObj[TOTAL] VAR aValores[TOTAL] Picture PesqPict('SUA','UA_VLRLIQ') OF oFoldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 70 ,9 COLOR CLR_RED
	
	// FOLDER DE IMPOSTOS
	oFoldRodape:aDialogs[2]:oFont := oDlg:oFont
	aObj[7] := MaFisRodape(2,oFoldRodape:aDialogs[2],,{0,1,aPosGet[2,1],52},bListRefresh,.T.)
	
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
											{|| IIF(lOrcamento,Tk150ExcOrc(),Tk150Grava()),oDlg:End()},;
											{|| oDlg:End()}), Eval(bRefresh))
FATPDLogUser("TK150EXCLU")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encerra as operacoes fiscais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisEnd()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Ponto de entrada após a exclusão do pedido       ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TMK150DEL")
  ExecBlock("TMK150DEL",.F.,.F.,{SUA->UA_NUM,SUA->UA_CLIENTE,SUA->UA_LOJA})
Endif        

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Tk150Grava³ Autor ³ Vendas Clientes  		³ Data ³ 28/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao e exclusao dos registros necessarios de acordo com³±±
±±³          ³o tipo de operacao e o statu do pedido atualmente no ERP    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER 												  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk150Grava()

Local lTefOk     := .F.												// Retorno do comando de cancelamento quando o TEF esta sendo utilizado
Local lNaoBaixa  := .F.												// Verifica se a baixa podera ser realizada normalmente
Local aArea  	 := GetArea()										// Salva a area atual
Local cNumNota 	 := SUA->UA_DOC										// Numero da NF 
Local lRet		 := .T.	 											// Retorno da funcao
Local cTextoCan	 := ""												// Texto para o cancelamento do atendimento
Local lTMK150VLD := ExistBlock("TMK150VLD") 						// Ponto de Entrada antes da exclusao com retorno esperado
Local nRecno		:= 0
Local cAliasTot	:= GetNextAlias()
Local lCancOp		:= .F.
Local aDocTef		:= {}
Private aTefDados	:= {}												// Array com os dados da transacao TEF

Default lUsaTEF		:= .F.

If !ctbValiDt( Nil, dDataBase, .T., Nil, Nil, { "FAT001" }, Nil )
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se nao existem titulos baixados com data diferente da data base do sistema para poder excluir o faturamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE1")
DbSetorder(1)
If DbSeek(xFilial("SE1")+ SUA->UA_SERIE+SUA->UA_DOC ) .AND. !lUsaTEF
	While !Eof() 						     .AND. ;
		  xFilial("SE1") == SE1->E1_FILIAL   .AND. ;
		  SUA->UA_SERIE  == SE1->E1_PREFIXO  .AND. ;
  		  SUA->UA_DOC 	 == SE1->E1_NUM

		If SE1->E1_STATUS == "B" .AND. !(E1_BAIXA == dDataBase)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³STR0014  "Esta nota fiscal possui titulo(s) baixado(s) em outra data e nao podera ser excluida 		³
			//³sem que seja realizado o cancelamento das baixas pelo modulo financeiro"								³
			//³                                                                                                     ³
			//³STR0015  "  Filial:"                                                                                 ³
			//³STR0016  "  Prefixo:"                                                                                ³
			//³STR0017  "  Numero:"                                                                                 ³
			//³STR0018  "  Parcela:"                                                                                ³
			//³STR0019  "  Tipo:"                                                                                   ³
			//³STR0020  "  Cliente:"                                                                                ³
			//³STR0021  "  Loja:"                                                                                   ³
			//³STR0022  "  Data da Baixa"                                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgStop(STR0014+STR0015+xFilial("SE5")+STR0016+SE1->E1_PREFIXO+STR0017+SE1->E1_NUM+;
			STR0018+SE1->E1_PARCELA+STR0019+SE1->E1_TIPO+STR0020+SE1->E1_CLIENTE+STR0021+SE1->E1_LOJA,STR0022)
			lNaoBaixa := .T.
			Exit
		Endif
		
		DbSkip()
	End

	If lNaoBaixa
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica status de trasmissão da nota antes da exclusão. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF2")
DbSetOrder(1)
If DbSeek( xFilial("SF2")+cNumNota+SUA->UA_SERIE)
	If SF2->F2_FIMP $ 'TSN'
		MsgStop(STR0033 + cNumNota + STR0034 + SUA->UA_SERIE + STR0035)  //A NF XXXXXX, série XXX foi transmitida e seu status atual não permite a exclusão.
		Return(.F.)
	Endif
Endif

If lTMK150VLD
	lRet := U_TMK150VLD(SUA->UA_NUM)
	// Se o retorno for .F. nao prossegue com o cancelamento
	If (ValType(lRet) <> "L")
		Return(.F.)
	ElseIf !lRet
		Return(lRet)
	Endif 
Endif


BEGIN TRANSACTION 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a venda tenha sido feita utilizando o TEF, tenta excluir a operacao antes da exclusao da nota ³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SUA->UA_VENDTEF == "S")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o usuario utiliza o TEF na rotina de TELEVENDAS a abertura do TEF ja foi realizada pelo TMK273BRETEF  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUsaTEF
			BeginSQL Alias cAliasTot
			
			SELECT E1_VALOR
			FROM %Table:SE1% SE1
			WHERE  SE1.E1_FILIAL = %xFilial:SE1% AND
				SE1.E1_NUM = %Exp:SUA->UA_DOC% AND 
				SE1.E1_PREFIXO = %Exp:SUA->UA_SERIE% AND
				SE1.E1_TIPO = %Exp:"CC"% AND
				SE1.E1_STATUS = %Exp:"B"% AND
				SE1.%NotDel%
					
			EndSql
		
			If !(cAliasTot)->(Eof())
				Help("   ",1,"TMK150Baixo")
				lRet:= .F.
				(cAliasTot)->(dbCloseArea())
			Else
				(cAliasTot)->(dbCloseArea())
				DbSelectArea( "SL4" )
				If DbSeek( xFilial("SL4")+ SUA->UA_NUM + "SIGATMK ")
					While !SL4->(Eof()) .AND. ;
						xFilial("SL4") == L4_FILIAL .AND. ;
						L4_NUM == SUA->UA_NUM 	  .AND. ;
						L4_ORIGEM == "SIGATMK "	 
						If aScan(aDocTef,SL4->L4_DOCTEF)==0
							aAdd(aDocTef,SL4->L4_DOCTEF)
						
							LJRotTEF()	//Chama a rotina TEF para exclusão da movimentação
							lTefOk := oTef:lTefOk
							lCancOp := oTef:nRet == -2 //Se abortado pelo usuario.
						EndIf
						SL4->(DbSkip())
					EndDo
				Endif
				lRet:= .T.
			EndIf			
			
			If lRet
				If lTefOk
					RecLock("SUA",.F.)
					SUA->UA_DOCCANC := oTef:aRetCartao[1]:cNsuAutor
					SUA->UA_HORCANC := oTef:aRetCartao[1]:cHoraTrans
					SUA->UA_DATCANC := StrTran(DToC(DDATABASE),"/","")
					MsUnLock()
				Else
					If !lCancOp
						Help(" ",1,"TEFOK")
					EndIf
					lRet := .F.
				Endif
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a nota foi gerada com o uso do TEF, nao permite a exclusao ³
			//³se o usuario nao utiliza TEF porque e necessaria a gravacao de³
			//³alguns campos.                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Help(" ",1,"TEFOK")
			Return(lRet)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Antes de Excluir Comissao - Verifica o Parametro de Geracao de Comissao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		DbSelectArea("SE3")
		If DbSeek(xFilial("SE3")+ SUA->UA_SERIE+SUA->UA_DOC)
			While !Eof() 						.AND. ;
				  !Empty(SUA->UA_VEND)  		.AND. ;
				  SUA->UA_SERIE == E3_PREFIXO 	.AND. ;
				  SUA->UA_DOC 	== E3_NUM
				
				If !Empty(E3_DATA)
					Help( " ",1,"A140COMIS")
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza‡„o de Comiss”es            						 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("SE3",.F.,.T.)
					DbDelete()
					MsUnlock()
				Endif	       
				
				SE3->(DbSkip())
			End
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclusao do contas a receber            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE1")
		DbSetorder(1)
		If DbSeek(xFilial("SE1")+ SUA->UA_SERIE+SUA->UA_DOC )
		
			While !Eof() 						   .AND. ;
				  xFilial("SE1")== SE1->E1_FILIAL  .AND. ;
				  SUA->UA_SERIE == SE1->E1_PREFIXO .AND. ;
				  SUA->UA_DOC == SE1->E1_NUM		
	
				Reclock( "SE1",.F. )
				DbDelete()
				MsUnlock()
				
				SE1->(DbSkip())
			End
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclusao da NF             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek( xFilial("SF2")+cNumNota+SUA->UA_SERIE)
			While !Eof() 							.AND. ;
				  xFilial("SF2") == SF2->F2_FILIAL  .AND. ;
				  cNumNota == SF2->F2_DOC 		    .AND. ;
				  SUA->UA_SERIE == SF2->F2_SERIE
				nRecno := SF2->(Recno())
				Pergunte("MTA521",.F.)
				Ma521Markb("SF2",nRecno,3,"",.F.)
				MaFisAtuSF3(2,"S",nRecno)
				DbSkip()
			End
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o estorno dos itens liberados do pedido de venda                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SC9")
		If DbSeek(xFilial("SC9")+ SUA->UA_NUMSC5 )
			While !Eof() .AND. xFilial("SC9") == SUA->UA_FILIAL .AND. SC9->C9_PEDIDO == SUA->UA_NUMSC5
				
				RecLock("SC9",.F.)
				MaAvalSC9("SC9",2)
				DbDelete()
				MsUnlock()
				
				SC9->(DbSkip())
			End
		Endif
	
		dbSelectArea("SUB")
		SUB->(dbSetOrder(3))	//UB_FILIAL + UB_NUMPV + UB_ITEMPV	
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o estorno dos itens do pedido de venda                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SC6")
		If DbSeek(xFilial("SC6")+ SUA->UA_NUMSC5 )
			While !Eof() .AND. xFilial("SC6") == SUA->UA_FILIAL .AND. SC6->C6_NUM == SUA->UA_NUMSC5
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Antes de excluir o SC6 apago o relacionamento do SUB - UB_NUMPV e UB_ITEMPV para manter a integridade referencial ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SUB->(dbSeek(xFilial("SUB")+SC6->C6_NUM+SC6->C6_ITEM))
					SUB->(Reclock("SUB",.F.))
					Replace SUB->UB_NUMPV	WITH ""
					Replace SUB->UB_ITEMPV	WITH ""
					SUB->(MsUnlock())
				EndIf
						
				RecLock("SC6",.F.)
				MaAvalSC6("SC6",2,"SC5")
				SC6->(DbDelete())
				SC6->(MsUnlock())
				
				SC6->(DbSkip())
			End
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÎ¿
			//³Chama o commit para atualizar a base e nao dar problema de integridade referencial³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÎÙ
			SUB->( FKCommit() )
			SC6->( FKCommit() ) 
	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os acumulados do SC5                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC5")
			If DbSeek(xFilial("SC5")+ SUA->UA_NUMSC5 )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Antes de excluir o SC5 apaga o relacionamento do SUA - UA_NUMSC5 para manter a integridade referencial³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Reclock( "SUA" ,.F.)
				Replace UA_NUMSC5  	WITH ""
				MsUnlock()
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÎ¿
				//³Chama o commit para atualizar a base e nao dar problema de integridade referencial³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÎÙ
				SUA->( FKCommit() ) 
				
				MaAvalSC5("SC5",2)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui o SC5                                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SC5")
				DbDelete()
				MsUnLock()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÎ¿
				//³Chama o commit para atualizar a base e nao dar problema de integridade referencial³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÎÙ
				SC5->( FKCommit() ) 
				
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclusao do cadastro de parcelas da condicao de pagamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "SL4" )
		If DbSeek( xFilial("SL4")+ SUA->UA_NUM + "SIGATMK ")
			While !Eof() 					  .AND. ;
				  xFilial("SL4") == L4_FILIAL .AND. ;
				  L4_NUM == SUA->UA_NUM 	  .AND. ;
				  L4_ORIGEM == "SIGATMK "	
				Reclock("SL4",.F.,.T.)
				DbDelete()
				MsUnlock()
				SL4->(DbSkip())
			End
		Endif
		
		cTextoCan := STR0023 + DTOC(date()) + " - "+ Time() //"Esse atendimento foi cancelado pela rotina de exclusão de Pedido do Televendas em :"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a exclusao do contrato de credito. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk150ExCred()
		
		Reclock( "SUA" ,.F.)
		Replace UA_DOC 	 	WITH ""
		//Replace UA_SERIE	WITH ""
		SerieNfId ('SUA',4,'UA_SERIE',,,'')
		Replace UA_EMISNF  	WITH CTOD("  /  /  ")
		Replace UA_OPER	 	WITH "2"   				// Orcamento
		Replace UA_CANC   	With "S"
		Replace UA_STATUS 	With "CAN"
		MSMM(,TamSx3("UA_OBSCANC")[1],,cTextoCan,1,,,"SUA","UA_CODCANC")
		MsUnlock()
	EndIf
END TRANSACTION


RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK150ExcOr³ Autor ³ Vendas Clientes    	³ Data ³ 28/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de exclusao de Orcamentos						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk150ExcOrc()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CALL CENTER 												  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk150ExcOrc()

Local lTMK150VLD := ExistBlock("TMK150VLD") 					// Ponto de Entrada antes da exclusao com retorno esperado

If lTMK150VLD
	lRet := U_TMK150VLD(SUA->UA_NUM)
	// Se o retorno for .F. nao prossegue com o cancelamento
	If (ValType(lRet) <> "L")
		Return(.F.)
	ElseIf !lRet
		Return(lRet)
	Endif 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclusao do cadastro de parcelas da condicao de pagamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SL4" )
If DbSeek( xFilial("SL4")+ SUA->UA_NUM + "SIGATMK ")
	While !Eof() 					  .AND. ;
		  xFilial("SL4") == L4_FILIAL .AND. ;
		  L4_NUM == SUA->UA_NUM 	  .AND. ;
		  L4_ORIGEM == "SIGATMK "	
		Reclock("SL4",.F.,.T.)
		DbDelete()
		MsUnlock()
		SL4->(DbSkip())
	End
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclusao dos itens do atendimento - Televendas       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUB")
DbSetorder(1)
If DbSeek(xFilial("SUB")+SUA->UA_NUM )
	While !Eof() .AND. xFilial("SUB") == UB_FILIAL .AND. UB_NUM == SUA->UA_NUM
		Reclock("SUB" ,.F.,.T.)
		DbDelete()
		MsUnlock()
		SUB->(DbSkip())
	End
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a exclusao do contrato de credito. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk150ExCred()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclusao do cabecalho do atendimento Televendas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reclock( "SUA" ,.F.,.T.)
DbDelete()
MsUnlock()  



Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Tk150Config      ³ Autor ³Vendas Clientes        ³ Data ³ 28/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os dados da venda								          	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk150Config(ExpC1, ExpN2)				                         ³±±
±±³          ³                     			                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do atendimento    	                             ³±±
±±³          ³ ExpN2 = Opcao selecionada pelo usuario  		                     ³±±
±±³          ³                                                   		         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³CALL CENTER						     				         	 ³±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk150Config(cNumTlv, nOpc)

Local aArea := GetArea()		// Salva a area 
Local cSeek		:= ""	//Armazena a string de busca
Local cWhile	:= ""	//Armazena a condição de parada
Local bCond            	//Armazena a condicao para validar os registros
Local cQuery	:= ""   //Armazena a query para TOP
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o aCols 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:= {}
aHeader	:= {}

#IFDEF TOP

	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SUB")+" SUB  "
	cQuery += "WHERE SUB.UB_FILIAL='"+xFilial("SUB")+"' AND "
	cQuery += "SUB.UB_NUM='"+cNumTlv+"' AND "
	cQuery += "SUB.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "+SqlOrder(SUB->(IndexKey()))		
	
#ENDIF       

DbSelectArea("SUB")
DbCloseArea() 

cSeek	:= xFilial("SUB") + cNumTlv
cWhile	:= "SUB->UB_FILIAL + SUB->UB_NUM"	
bCond	:= {||IIf(SUB->UB_FILIAL+SUB->UB_NUM == xFilial("SUB")+cNumTlv,.T.,.F.)}    

FillGetDados(	nOpc/*nOpcX*/, "SUB"/*cAlias*/, 1/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, .F./*lEmpty*/,; 
				/*aHeaderAux*/, /*aColsAux*/, {||Tk150MontAcols()}/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, "SUB"/*cAliasQry*/)

DbSelectArea("SUB")
DbCloseArea()	

If MaFisFound()
	MaFisClear()
	MaColsToFis(aHeader,aCols,,"TK271",.T.)
Endif

RestArea(aArea)

Return(.T.)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk150MontAcols  ³ Autor ³ Vendas Clientes ³ Data ³17/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o Acols da tela                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka150					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Static Function Tk150MontAcols()  
Local nPDescri := 0		//Armazena a posicao da coluna de descricao

nPDescri	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UB_DESCRI"})
If (aHeader[nPDescri][10] == "V" .AND. Alltrim(aHeader[nPDescri][2])=="UB_DESCRI") 
	aCols[Len(aCols)][nPDescri] := Posicione("SB1",1,xFilial("SB1") + Alltrim(FieldGet(ColumnPos("UB_PRODUTO"))),"B1_DESC") // O campo UB_DESCRI (Descricao do produto) eh virtual e pega seu conteudo da tabela SB1 (Produtos)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk150Refresh ³ Autor ³Vendas Clientes      ³ Data ³ 28/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o Refresh do Folder.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Tk150Refresh(aObj)

Local aArea	:= GetArea()	// Salva a area atual
Local nx    := 0			// Contador

aValores[MERCADORIA]	:= SUA->UA_VALMERC
aValores[ACRESCIMO]		:= SUA->UA_ACRESCI
aValores[DESPESA]	 	:= SUA->UA_DESPESA
aValores[DESCONTO]		:= SUA->UA_DESCONT
aValores[FRETE]			:= SUA->UA_FRETE
aValores[TOTAL]         := aValores[MERCADORIA] + (aValores[FRETE]+aValores[DESPESA]+aValores[ACRESCIMO]) - aValores[DESCONTO]

For nX := 1 TO Len(aObj)
	aObj[nx]:Refresh()
Next nX

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³TK150CodVenºAutor  ³Vendas Clientes     º Data ³  07/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Retorna o codigo de vendedor do usuario do Sistema.         º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ CALL CENTER                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk150CodVen()

Local aArea	  := GetArea() 						// Salva a area atual
Local cCodVen := Criavar("A3_COD",.F.)			// Codigo do Vendedor 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida o codigo do usuario logado procurando no cadastro de operadores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SU7")
DbSetorder(4)
If DbSeek(xFilial("SU7") + __cUserID ) 
	cCodVen := SU7->U7_CODVEN
	If ! Empty(ALLTRIM(cCodVen))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Uma vez identificado o operador - identifica o vendedor pelo CODIGO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("SA3")
		DbSetorder(1)
		If DbSeek( xFilial("SA3")+ cCodVen)
			cCodVen := SA3->A3_COD
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao foi identificado o operador pelo codigo - identifica pelo NOME  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("SA3")
		DbSetorder(2)
		If DbSeek( xFilial("SA3")+ UPPER(Substr(cUsuario,7,15)) )
			cCodVen := SA3->A3_COD                               
		ElseIf DbSeek(xFilial("SA3")+Substr(cUsuario,7,15)) 
			cCodVen := SA3->A3_COD                               
		Endif		
		
	Endif
Endif

RestArea(aArea)

Return(cCodVen)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK150Legenda ºAutor  ³Vendas Clientes  º Data ³  04/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legendas do browse de Exclusao de NF                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk150Legenda()

// Legenda
BrwLegenda(cCadastro,STR0024  ,{	{"BR_VERDE"		,STR0025 },;		// "Atendimento com Pedido    "
									{"BR_VERMELHO" 	,STR0026 },;		// "Atendimento com NF emitida"
									{"BR_AZUL" 		,STR0027 },;      	// "Atendimento com Orçamento "
									{"BR_MARRON"	,STR0028 },;    	// "Atendimento               " 
									{"BR_PRETO"		,STR0029 }}) 		// "Atendimento Cancelado"

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk150ExCred ºAutor  ³Vendas Clientes   º Data ³  06/24/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realizar a exclusao do contrato de credito quando foi feito º±±
±±º          ³no orcamento ou pedido.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELEVENDAS                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk150ExCred()

Local aARea		:= GetArea()   	// Salva a area atual
Local lRet		:= .T.			// Retorno da funcao
Local lSigaCRD	:= .F.			// Indica se o operador esta configurado para realizar a analise de credito pelo SIGACRD
Local cEstacao	:= ""			// Codigo da estacao
Local aRetCRD	:= {}			// Retorno da funcao de cancelamento do contrato

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o operador realiza analise de credito atraves do SIGACRD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SU7->(ColumnPos("U7_ESTACAO")) > 0 .AND. SU7->U7_ESTACAO <> "   "
	cEstacao:= TkPosto(SUA->UA_OPERADO,"U7_ESTACAO")	//Pega o codigo da ESTACAO do OPERADOR
Else
	cEstacao:= TkPosto(SUA->UA_OPERADO,"U0_ESTACAO") //Pega o codigo da ESTACAO do GRUPO DE ATENDIMENTO
EndIf

Dbselectarea("SLG")
DbSetOrder(1)
If DbSeek(xFilial("SLG")+cEstacao)
	If LG_CRDXINT == "1"	//Sim
		lSigaCrd:= .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui a transacao de credito quando existiu ³
//³analise de credito feita pelo SIGACRD        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSigaCrd
	If SUA->(ColumnPos("UA_CONTRA")) > 0
		If !Empty(SUA->UA_CONTRA)
    		aRetCrd    := aClone(CrdxVenda( "3", {"",""}, SUA->UA_CONTRA, .F., Nil))     		   
		Endif
	Endif
Endif			
                                                     
RestArea(aArea)
Return(lRet)

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
