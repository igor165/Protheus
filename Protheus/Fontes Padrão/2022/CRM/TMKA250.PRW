#INCLUDE "TMKA250.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "TMKDEF.CH"

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Estrura do arquivo temporario           ³
  ³                                        ³
  ³T_IDLIST  N   Codigo interno            ³
  ³T_IDTREE  C   Codigo do pai             ³
  ³T_IDCODE  C   Codigo do item 	       ³
  ³T_ISTREE  C   Flag para indicar se o Pai³
  ³T_PROMPT  C   Descricao do item         ³
  ³T_CARGO	 C   Codigo	da Ocorrencia/Acao ³
  ³T_BMP001  N   Codigo do desenho fechado ³
  ³T_BMP002  N   Codigo do desenho aberto  ³
  ³T_CLIENT  C                             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TmkA250	³ Autor ³ Marcelo Kotaki   		³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro da rela‡„o Ocorrencia x A‡„o c/ entrada automatica³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmkA250(ExpA1,ExpN2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Variaveis da rotina de inclusao automatica         ³±±
±±³          ³ ExpN1 = Tipo de operacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	     ³ CALL CENTER	   			 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando  ³12/12/06³9.12  ³Bops 115410 Alterado a array aRotina        ³±±
±±³          ³        |      ³para criação do menu funcional              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TmkA250(aRotAuto,nOpc)

Local aCores    := {	{"Empty(SUR->UR_CODSOL)" , "BR_AZUL" },;// Ocorrencia
   						{"!Empty(SUR->UR_CODSOL)", "BR_VERDE"    }} // Acao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aAC := { STR0001, STR0002 } //"Abandona","Confirma"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//³ 5. Verifica se a Senha tem acesso a esse tipo de transa‡Æo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := STR0009 //"Atualiza‡„o da Rela‡„o Ocorrencia x A‡„o"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis para rotina de inclusao automatica    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lTk250Auto := ( aRotAuto <> NIL )	//Flag para identificar execucao via MsExecAuto

If lTk250Auto
	MsRotAuto(nOpc,aRotAuto,"SUR")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SUR",,,,,,aCores)
Endif	

Return(.T.) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef³ Autor ³ Fernando Amorim       ³ Data ³08/12/06     ³±±
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

Local aRotina:= { 	 { STR0004 ,"AxPesqui"     , 0 ,1 , , .F.},; 		//"Pesquisar"
					 { STR0005 ,"TK250Visual"  , 0 ,2 , , .T.},; 		//"Visualizar"
					 { STR0006 ,"TK250Inclusao", 0 ,3 , , .T.},; 		//"Incluir"
					 { STR0007 ,"TK250Alter"   , 0 ,4 , , .T.},; 		//"Alterar"
					 { STR0008 ,"TK250Exclusao", 0 ,5, 1 , .T.},;		//"Excluir"
					 { STR0034 ,"TK250Legenda" , 0 ,2 , , .T.}} 		//"Legenda"

Return(ARotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250Inclui³ Autor ³ Marcelo kotaki   		³ Data ³ 03/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de Inclusao de Rela‡„o Ocorrencia x A‡„o           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Inclusao(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Tipo de Opera‡Æo        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk250Inclusao(cAlias,nReg,nOpc)

Local oDlg						// Tela
Local nOpca 		:= 0		// Opcao de retorno do usuario OK/CANCELA
Local aTree  		:= {}		// Objeto TREE para composicao de OCORRENCIAS X ACOES
Local lRet  		:= .F.		// Retorno da funcao
Local aObjects  	:= {}		// Array para MSADVSIZE - redimensionamento da tela
Local aSize			:= {}		// Array para MSADVSIZE - redimensionamento da tela
Local aInfo			:= {}		// Array para MSADVSIZE - redimensionamento da tela
Local aPosObj		:= {}		// Array para MSADVSIZE - redimensionamento da tela
Local cAntOcor		:= ""		// Codigo da ocorrencia anterior
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao para rotina automatica.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk250Auto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize   := MsAdvSize(.T.)  	// Devolve o tamanho da tela atualmente no micro do usuario
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as coordenadas dos objetos.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, { 85, 100, .T., .T., .F. } )  
	AAdd( aObjects, { 15, 100, .T., .T., .F. } )  
	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
	aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )    
	
	DEFINE MSDIALOG oDlg TITLE STR0011 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL STYLE WS_DLGFRAME //"Cadastro de Rela‡„o Ocorrencia x  A‡„o - Inclus„o"
	
		@ aPosObj[1][1]-2,aPosObj[1][2]-2 TO aPosObj[1][3]+2,aPosObj[1][4]+2 LABEL STR0012 OF oDlg PIXEL //"Relacionamento"
		
		DEFINE DBTREE oTree FROM aPosObj[1][1]+5,aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] OF oDlg CARGO
			
		// Adiciona uma ocorrencia 
		@aPosObj[2][1]+20,aPosObj[1][4]+5 BUTTON STR0013 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Recl(nOpc,@oTree,@aTree) //"Adiciona Ocorrencia"
	 
		// Alterar Ocorrencia
		@aPosObj[2][1]+40,aPosObj[1][4]+5 BUTTON STR0030 SIZE 60,15 OF oDlg PIXEL ACTION Tk250OcoAlt(nOpc,@oTree,@aTree,@cAntOcor) When .F.//"Alterar Ocorrência"
	
		//Adiciona as A‡”es
		@aPosObj[2][1]+70,aPosObj[1][4]+5 BUTTON STR0014 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Solu(nOpc,@oTree,@aTree) //"Adiciona A‡„o"
	
		// Remove um filho ou um pai com os filhos
		@aPosObj[2][1]+90,aPosObj[1][4]+5 BUTTON STR0015 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Rem(nOpc,@oTree,@aTree) //Remove Item
	
		// Move o item um nivel acima
		@aPosObj[2][1]+120,aPosObj[1][4]+5 BUTTON STR0031 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Up(@oTree,@aTree) //"Move para cima"
	
		// Move o item um nivel abaixo
		@aPosObj[2][1]+140,aPosObj[1][4]+5 BUTTON STR0032 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Down(@oTree,@aTree) //"Move para baixo"
	
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca := 1,;
														lRet  := Tk250Grava(nOpc,oTree,aTree,cAntOcor),;
														IIF(lRet,oDlg:End(),"")},;
													 {|| nOpca := 2,oDlg:End()},.F.) )
	

Else
	AxIncluiAuto(cAlias)
Endif
	
DbSelectarea("SUR")
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK250Recl ³ Autor ³Marcelo Kotaki    		³ Data ³23/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela para adicionar a Ocorrencia (Pai)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Recl(ExpN1,ExpO2,ExpA3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Operacao									          ³±±
±±³          ³ ExpO2 = Tree 		                                      ³±±
±±³          ³ ExpA3 = Array do Tree                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³CALL CENTER            		                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250Recl(nOpc,oTree,aTree)

Local oDlg                 						// Tela
Local oCodRec									// Objeto com o Codigo da Ocorrencia
Local cCodRec 	:= SPACE(6)						// Variavel com o Codigo da Ocorrencia
Local oDesc                         			// Objeto com o Descricao da Ocorrencia
Local cDesc 	:= SPACE(55)					// Variavel com a Descricao da Ocorrencia
Local lHabilita := .T.							// Flag para habilitar os objetos ou nao	
Local cPicture 	:= PesqPict("SUR","UR_CODREC")	// Picture do campo
Local lRet		:= .F.		                    // Retorno da funcao

If Len(aTree) > 0 
	Help( " ", 1, "TK250JAINF", ,  STR0035,1,1,,,,,,{STR0036} )// 'A ocorrencia ja foi informada.' # 'Somente a funcao de alteracao esta disponivel.'
	Return(lRet)
Endif

DEFINE MSDIALOG oDlg TITLE STR0016 FROM 10,10 TO 16,70 OF oMainWnd //"Ocorrencia"

	@ 02,03 TO 24,232 LABEL STR0017 OF oDlg PIXEL //"Informe a Ocorrencia"
	@ 10,07 SAY STR0018 SIZE 40,8 OF oDlg PIXEL  //"C¢digo"
	@ 10,30 MSGET oCodRec VAR cCodRec SIZE 20, 8 OF oDlg PIXEL Picture cPicture  F3 "SU9" When lHabilita Valid Tk250DescR(cCodRec,oDesc,@cDesc)

	@ 10,65 SAY STR0019 SIZE 40,8 OF oDlg PIXEL //"Descri‡„o"
	@ 10,93 MSGET oDesc VAR cDesc SIZE 135,8 OF oDlg PIXEL Picture "@x" When .F.

	// Adiona no Tree essa Ocorrencia
	DEFINE SBUTTON FROM 27,178 TYPE 1 ENABLE OF oDlg ACTION (	lRet := .T.,;
																Tk250AtuR(nOpc,oTree,cCodRec,cDesc,@aTree),;
																oDlg:End())

	// Fecha a Tela
	DEFINE SBUTTON FROM 27,208 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTER

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³Tk250DescR ³ Autor ³Marcelo Kotaki   		 ³ Data ³23/03/04  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³Atualiza a descri‡„o da Ocorrencia                           ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250DescR(ExpC1,ExpO2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da ocorrencia                                ³±±
±±³          ³ ExpO2 = Objeto ocorrencias                                  ³±±
±±³          ³ ExpC2 = Descricao                            			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso	     ³CALL CENTER                                    	      	   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250DescR(cCodRec,oDesc,cDesc)

Local aArea := GetArea()		// Salva a area atual
Local lRet	:= .F.				// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se essa ocorrencia ja foi gravada antes     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SUR")
DbSetorder(1)
DbSeek(xFilial("SUR")+cCodRec)
If SUR->UR_CODREC == cCodRec
	Help( " ", 1, "TK250CADRE", , STR0037) //'Ocorrencia já foi gravada'
	Return(lRet)
Endif

DbSelectarea("SU9")
DbSetorder(2)
If DbSeek(xFilial("SU9")+cCodRec)
	If VAL(SU9->U9_VALIDO) == VALIDO
		lRet  := .T.
		cDesc := SU9->U9_DESC
		oDesc:Refresh()
	Else
		Help( " ", 1, "TK250INVAL", , STR0038 ) //'ocorrencia Inválida'
		Return(lRet)
	Endif
Else
	Help( " ", 1, "TK250INVAL", , STR0038  )  //'ocorrencia Inválida' 
	Return(lRet)
Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK250AtuR ³ Autor ³Marcelo Kotaki    		³ Data ³23/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adiciona a Ocorrencia como 1§ item (Pai)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250AtuR(ExpC1,ExpO2,ExpC3,ExpC4,ExpA5)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Operacao 											  ³±±
±±³          ³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpC3 = Codigo da Ocorrencia								  ³±±
±±³          ³ExpC4 = Descricao da Ocorrencia							  ³±±
±±³          ³ExpA5 = Array do TREE                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³CALL CENTER					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250AtuR(nOpc,oTree,cCodRec,cDesc,aTree)

Local nAux := TamSx3("UQ_DESC")[1]  	// Tamanho do campo	
Local nCont:= 0 						// Contador
	
// Tratamento para a descricao do tree para poder apresentar a informacao correta.
If Len(cDesc) <= nAux
   cDesc := cDesc + SPACE(nAux-Len(cDesc))
Endif

If nOpc == 3  //INCLUSAO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se o TREE ja esta preechido ou est  vazio   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oTree:IsEmpty()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Como o TREE est  vazio primeiro carrego a Reclamacao        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTree:AddItem(cDesc,cCodRec, "FOLDER12","FOLDER13", , ,1)
		AAdd(aTree,{cCodRec,cDesc,cCodRec,{}}) 
    Else
	    //Atualiza ocorrencia
		aTree[1][1] := cCodRec
		aTree[1][2] := cDesc
		aTree[1][3] := cCodRec
	
	    oTree:BeginUpdate()
	    oTree:Reset() 
		oTree:AddItem(aTree[1][2],aTree[1][3], "FOLDER12","FOLDER13", , ,1)							
		For nCont := 1 To Len(aTree[1][4])
			oTree:AddItem(aTree[1][4][nCont][2],aTree[1][4][nCont][1], "FOLDER5","FOLDER6", , ,2)							
		Next nCont
		oTree:EndUpdate()
		oTree:Refresh()
	Endif
	
ElseIf nOpc == 4 // ALTERACAO
	//Atualiza ocorrencia
	If oTree:IsEmpty()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Como o TREE est  vazio primeiro carrego a Reclamacao        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTree:AddItem(cDesc,cCodRec, "FOLDER12","FOLDER13", , ,1)
		AAdd(aTree,{cCodRec,cDesc,cCodRec,{}}) 
    Else
		aTree[1][1] := cCodRec
		aTree[1][2] := cDesc
		aTree[1][3] := cCodRec
	
	    oTree:BeginUpdate()
	    oTree:Reset() 
		oTree:AddItem(aTree[1][2],aTree[1][3], "FOLDER12","FOLDER13", , ,1)							
		For nCont := 1 To Len(aTree[1][4])
			oTree:AddItem(aTree[1][4][nCont][2],aTree[1][4][nCont][1], "FOLDER5","FOLDER6", , ,2)							
		Next nCont
		oTree:EndUpdate()
		oTree:Refresh()
	EndIf
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK250Solu ³ Autor ³Marcelo Kotaki    		³ Data ³23/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela para adicionar a A‡„o (Filhos)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Solu(ExpN1,ExpO2,ExpA3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Operacao 											  ³±±
±±³          ³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpA3 = Array Tree          								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³CALL CENTER					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250Solu(nOpc,oTree,aTree)

Local oDlg                          			// Tela
Local oCodSol									// Objeto do codigo de Acao
Local cCodSol 	:= SPACE(6)						// Codigo da Acao
Local oDesc										// Objeto com a Descricao da Acao	
Local cDesc 	:= CRIAVAR("UQ_DESC",.F.)		// Descricao da Acao	
Local lHabilita := .T.							// Flag para habilitar os objetos
Local nTotal 	:= 0							// Contador
Local cPicture  := PesqPict("SUR","UR_CODSOL")	// Picture do cadastro
Local lRet		:= .F.							// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o TREE ja esta preechido ou est  vazio   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nToTal := oTree:nTotal
If nTotal == 0
	Help( " ", 1, "TK250SOLU")
	Return(lRet)
Endif

DEFINE MSDIALOG oDlg TITLE STR0020 FROM 10,10 TO 16,80 OF oMainWnd //"A‡„o"

	@ 02,03 TO 23,275 LABEL STR0021 OF oDlg PIXEL //"Informe a A‡„o"
	@ 10,07 SAY STR0018 SIZE 30,8 OF oDlg PIXEL  //"C¢digo"
	@ 10,30 MSGET oCodSol VAR cCodSol SIZE 30,8 OF oDlg PIXEL Picture cPicture F3 "SUQ" When lHabilita Valid Tk250DescS(cCodSol,oDesc,@cDesc,aTree)

	@ 10,65 SAY STR0019 SIZE 40,8 OF oDlg PIXEL //"Descri‡„o"
	@ 10,93 MSGET oDesc VAR cDesc SIZE 175,8 OF oDlg PIXEL Picture "@x" When .F.

	// Adiona no Tree essa A‡„o
	DEFINE SBUTTON FROM 27,210 TYPE 1 ENABLE OF oDlg ACTION (lRet := .T.,;
															 Tk250AtuS(nOpc,oTree,cCodSol,cDesc,aTree),;
															 oDlg:End())

	// Fecha a Tela
	DEFINE SBUTTON FROM 27,245 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTER

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³Tk250DescS ³ Autor ³Marcelo Kotaki    	 ³ Data ³23/03/04  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³Atualiza a descri‡„o da A‡„o                                 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe   ³ Tk250DescS(ExpC1,ExpO2,ExpC3,ExpA4)                         ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ExpC1 = Operacao 									 		   ³±
±±³          ³ExpO2 = Objeto TREE									   	   ³±
±±³          ³ExpC3 = Codigo da Ocorrencia							       ³±
±±³          ³ExpA4 = Array do TREE                                        ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso	     ³CALL CENTER                                    	      	   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Analista  ³ Data/Bops     ³Manutencao Efetuada                          ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Norbert W.³26/02/07³120173³Correcao na condicao do While que varria os  ³±
±±³          ³        ³      ³elementos presentes no DbTree, que nao consi-³±
±±³          ³        ³      ³derava se a chave de busca foi alterada.     ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk250DescS(cCodSol,oDesc,cDesc,aTree)

Local aArea		 := GetArea()	// Salva a area atual
Local nContSol	 := 0			// Contador de acoes
Local nLimite	 := 0			// Limite de acoes
Local cCodOco	 := ""			// Codigo da Ocorrencia
Local lRet		 := .T.			// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico no TREE se a a‡„o ja foi atualizada.        ³
//³Regra:                                               ³
//³  - A reclama‡ao ser  sempre o Pai.                  ³
//³  - N„o pode haver a‡„o repetida                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o codigo Localizado for do PAI (Ocorrencia) o limite para                        ³
//³codigos repetidos ser  2. C¢digo repetido Por que ?                                 ³
//³- Porque as tabelas de ocorrencia e Acao sao distintas e os codigos podem repetir - ³
//³SOMENTE OS CODIGOS DE OCORRENCIA E ACAO                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea(oTree:cArqTree)
DbSetorder(4) //IT_CARGO
If DbSeek(cCodSol) 
	While !Eof() .AND. ((oTree:cArqTree)->T_CARGO == cCodSol)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se e uma ocorrencia (PAI) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (oTree:cArqTree)->T_ISTREE == "S" .OR. (oTree:cArqTree)->T_IDLIST == 1
			cCodOco := (oTree:cArqTree)->T_CARGO
			nLimite := 1 
		Else            
		   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totaliza as acoes repetidas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nContSol ++
		Endif
	
		If nContSol >= nLimite
			Help( " ", 1, "TK250CADSO", , STR0039 ) //'Essa ação já foi adicionada para essa ocorrência'
			lRet := .F.
			Exit
		Endif
			
		DbSkip()
	End
Endif
	
If lRet
	DbSelectarea("SUQ")
	DbSetorder(1)
	If DbSeek(xFilial("SUQ")+cCodSol)
		If VAL(SUQ->UQ_VALIDO) == VALIDO
			cDesc := SUQ->UQ_DESC
			oDesc:Refresh()
		Else
			Help( " ", 1, "TK250INVAL", ,STR0040 ) //'Ação Inválida!'
			lRet := .F.
		Endif
	Else
		Help( " ", 1, "TK250INVAL", ,STR0040 )  //'Ação Inválida!'
		lRet := .F.
	Endif      
Endif

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK250AtuS ³ Autor ³Marcelo Kotaki    		³ Data ³24/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adiciona a A‡„o como 1§ item (Pai)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250AtuS(ExpC1,ExpO2,ExpC3,ExpC4,ExpA5)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Operacao 											  ³±±
±±³          ³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpC3 = Codigo da Acao      								  ³±±
±±³          ³ExpC4 = Descricao da Acao      							  ³±±
±±³          ³ExpA5 = Array do TREE                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³CALL CENTER					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250AtuS(nOpc,oTree,cCodSol,cDesc,aTree)

Local aNova 	:= {}	// Array com a nova acao
Local aAuxTree	:= {}	// Array auxiliar
Local nPos		:= 0    // Contador
Local nCont		:= 0	// Contador

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o TREE ja esta preechido ou est  vazio   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !oTree:IsEmpty()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Incluo a a‡ao sempre depois do item selecionado      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(oTree:currentnodeid)=1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao deixar a mesma acao ser incluida                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos:= Ascan(aTree[1,4],{|aVal|  (aVal[1] == cCodSol)}))=0
			oTree:AddItem(cDesc,cCodSol, "FOLDER5","FOLDER6", , ,2)	
			AAdd(aTree[1][4],{cCodSol,cDesc})
		EndIf	
    Else
		If oTree:TreeSeek(oTree:GetCargo())
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa onde esta o foco do objeto tree.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos:= Ascan(aTree[1,4],{|aVal|  (aVal[1] == oTree:GetCargo())})
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for o foco no ulltimo item nao pesquisa nada e so adiciona no ultimo lugar.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == Len(aTree[1][4])      
				oTree:TreeSeek(aTree[1][3])
				oTree:AddItem(cDesc,cCodSol, "FOLDER5","FOLDER6", , ,2)	
				AAdd(aTree[1][4],{cCodSol,cDesc})
			Else
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O foco nao e no ultimo item. Entao tem que ser feita a reestruturacao do array ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd(aTree[1][4],{cCodSol,cDesc})					// Adiciona a nova pergunta na ultima posicao do array.
				aNova	 := aClone(aTree[1][4][Len(aTree[1][4])])	// Separa a nova pergunta
				aAuxTree := aClone(aTree)							// Preenche array auxiliar com o aTree(array principal).
			
				aAuxTree[1][4][nPos+1]:= aNova						// Insere no array auxiliar a nova pergunta na posicao correta
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A partir da nova pergunta ate o fim do aTree sem o ultimo item      ³
				//³recrio os proximos itens do aAuxTree.                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCont := nPos+1 To (Len(aTree[1][4])-1)
					aAuxTree[1][4][nCont+1] := aTree[1][4][nCont]
				Next nCont
	
	    	    aTree := aClone(aAuxTree)
		        oTree:BeginUpdate()
		        oTree:Reset() 
				oTree:AddItem(aTree[1][2],aTree[1][3], "FOLDER12","FOLDER13", , ,1)							
		        For nCont := 1 To Len(aTree[1][4])
					oTree:AddItem(aTree[1][4][nCont][2],aTree[1][4][nCont][1], "FOLDER5","FOLDER6", , ,2)							
				Next nCont
				oTree:EndUpdate()
	        Endif
			
		Else
			oTree:AddItem(cDesc,cCodSol, "FOLDER5","FOLDER6", , ,2)	
			AAdd(aTree[1][4],{cCodSol,cDesc})
		Endif
	EndIf
Endif
oTree:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk250Rem	³ Autor ³Luis Marcelo Kotaki    ³ Data ³03/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Remove da Arvore o item selecionado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Rem(ExpN1,ExpO2,ExpA3)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Operacao 											  ³±±
±±³          ³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpA3 = Array Tree          								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³CALL CENTER					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK250Rem(nOpc,oTree,aTree,cAntOcor)

Local nPos := 0 	// Retorno do Ascan
DEFAULT cAntOcor := ""
If oTree:IsEmpty()
	Help( " ", 1, "TK250RECLA" )
Else
	If Alltrim(oTree:GetCargo()) == aTree[1][1]
		If TmkOK(STR0022) //"Confirma a exclus„o de tudo ?"
			cAntOcor := aTree[1][1]
			oTree:DelItem()
		    oTree:Reset() 
			oTree:Refresh() 
			aTree := {}
		Endif
	Else
		If TmkOK(STR0023)  //"Confirma a exclus„o dessa A‡„o ?"
			nPos := Ascan(aTree[1,4],{|aVal|  (trim(aVal[1]) == trim(oTree:GetCargo()))})
			aDel(aTree[1,4],nPos)
			aSize(aTree[1,4],Len(aTree[1,4])-1)

			oTree:DelItem()
			oTree:Refresh()
		Endif
	Endif
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk250Grava³ Autor ³Marcelo Kotaki    		³ Data ³23/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava o cadastro de relacionamento de Ocorrencia x A‡„o     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Grava(ExpN1,ExpO2,ExpA3,ExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Operacao 											  ³±±
±±³          ³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpA3 = Array Tree          								  ³±±
±±³          ³ExpC4 = Codigo da Ocorrencia anterior                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³CALL CENTER					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250Grava(nOpc,oTree,aTree,cAntOcor)

Local nTotal 	 	:= 0		// Total de pontos do TREE
Local lRet			:= .T.		// Retorno da funcao
Local cFilSUR		:= ''
Default cAntOcor	:= ""		// Inicializador defaul

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fa‡o as valida‡”es necess rias antes da grava‡„o     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nToTal := oTree:nTotal
If nTotal < 2
	Help( " ", 1, "TK250VAZIO" )
	lRet := .F.
Endif

If lRet
	cFilSUR	:= xFilial("SUR")
	
	BEGIN TRANSACTION
	
		Do Case
			Case nOpc == 3  // INCLUSAO
				
				// DbGotop porque a tabela e pequena, local e temporaria
				(oTree:cArqTree)->(DbGoTop())
				While ( !(oTree:cArqTree)->(EOF()) )
					RecLock("SUR",.T.)
					REPLACE SUR->UR_FILIAL WITH cFilSUR
					REPLACE SUR->UR_CODREC WITH aTree[1][1]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³T_ISTREE - define se e filho, grava acao.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty((oTree:cArqTree)->T_ISTREE)
						REPLACE SUR->UR_CODSOL WITH (oTree:cArqTree)->T_CARGO
					Endif
					REPLACE SUR->UR_IDCODE WITH (oTree:cArqTree)->T_IDCODE
					REPLACE SUR->UR_IDTREE WITH (oTree:cArqTree)->T_IDTREE
					REPLACE SUR->UR_ISTREE WITH (oTree:cArqTree)->T_ISTREE
					REPLACE SUR->UR_DESC   WITH (oTree:cArqTree)->T_PROMPT
					REPLACE SUR->UR_CARGO  WITH (oTree:cArqTree)->T_CARGO
					MsUnlock()
					
					(oTree:cArqTree)->(DbSkip())
				End
				
			Case nOpc == 4 //ALTERACAO
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Apago os items antigos e atualizo com o atual        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SUR")
				DbSetOrder(1)
				If DbSeek(cFilSUR+aTree[1][1])
					While !Eof() .AND. SUR->UR_FILIAL == cFilSUR .AND. (SUR->UR_CODREC == aTree[1][1])
						RecLock("SUR",.F.)
						DbDelete()
						MsUnlock()
						DbSkip()
					End 
					
				ElseIf !Empty(cAntOcor)
					If DbSeek(cFilSUR+cAntOcor)
						While !Eof() .AND. SUR->UR_FILIAL == cFilSUR .AND. (SUR->UR_CODREC == cAntOcor)
							RecLock("SUR",.F.)
							DbDelete()
							MsUnlock()
							DbSkip()
						End
					Endif
				Endif    
				
				(oTree:cArqTree)->(DbGoTop())
				While ( !(oTree:cArqTree)->(EOF()) )
					
					RecLock("SUR",.T.)
					REPLACE SUR->UR_FILIAL WITH cFilSUR
					REPLACE SUR->UR_CODREC WITH aTree[1][1]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³T_ISTREE - define se e filho, grava acao.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty((oTree:cArqTree)->T_ISTREE)
						REPLACE SUR->UR_CODSOL WITH (oTree:cArqTree)->T_CARGO
					Endif
					REPLACE SUR->UR_IDCODE WITH (oTree:cArqTree)->T_IDCODE
					REPLACE SUR->UR_IDTREE WITH (oTree:cArqTree)->T_IDTREE
					REPLACE SUR->UR_ISTREE WITH (oTree:cArqTree)->T_ISTREE
					REPLACE SUR->UR_DESC   WITH (oTree:cArqTree)->T_PROMPT
					REPLACE SUR->UR_CARGO  WITH (oTree:cArqTree)->T_CARGO
					MsUnlock()
					
					(oTree:cArqTree)->(DbSkip())
				End
		Endcase
		
	END TRANSACTION
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK250Alter³ Autor ³ Marcelo Kotaki   		³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de Altera‡„o de Rela‡„o Ocorrencia x A‡„o          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Tipo de Opera‡Æo        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk250Alter(cAlias,nReg,nOpc)

Local oDlg						// Tela
Local nOpca 		:= 0		// Opcao de retorno OK/CANCELA
Local aTree  		:= {}		// Array do TREE
Local aObjects  	:= {}		// Array para redimensionamento da tela
Local aSize			:= {}		// Array para redimensionamento da tela	
Local aInfo			:= {}		// Array para redimensionamento da tela
Local aPosObj		:= {}		// Array para redimensionamento da tela
Local cAntOcor		:= ""		// Codigo da ocorrencia anterior
Local lExtRemIt		:= .T.		// Habilita/Desabilita botao Remover Item 
Local oBtnRemIt   		 	    // Botao Remove Itens da Ocorrencia 
Local lExtOcor      := .T.     	// Indica se a ocorrencia ja foi associada a uma chamada
Local aTreeBUp		:= {}		//Copia da arvore de relacionamentos antes da atualizacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se este cadastro ja foi trabalhado no atendimento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lExtOcor = Tk250VldAlter(cAlias,nReg,nOpc)
lExtRemIt = lExtOcor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avaliacao da rotina automatica.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk250Auto	
	                         
	AAdd(aTree,{ SUR->UR_CODREC,;
				 "",;
				 SUR->UR_CARGO,;
				 {} })
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize( .T. )  	// Devolve o tamanho da tela atualmente no micro do usuario
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as coordenadas dos objetos.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, { 85, 100, .T., .T., .F. } )  
	AAdd( aObjects, { 15, 100, .T., .T., .F. } )  
	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
	aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )  
	
	DEFINE MSDIALOG oDlg TITLE STR0024 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Cadastro de Rela‡„o Ocorrencia x A‡„o - Altera‡„o"
	
		@ aPosObj[1][1]-2,aPosObj[1][2]-2 TO aPosObj[1][3]+2,aPosObj[1][4]+2 LABEL STR0012 OF oDlg PIXEL //"Relacionamento"
		DEFINE DBTREE oTree FROM aPosObj[1][1]+5,aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] OF oDlg ON CHANGE Tk250AltBut(aTreeBUp,oBtnRemIt,@lExtRemIt,lExtOcor) CARGO
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a arvore com as Perguntas e Respostas          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|lEnd| Tk250Mont(oTree,@aTree)},STR0025,STR0026,.F.) //"Aguarde","Montando Estrutura do Relacionamento"
		
		//Copia o array antes de entrar na tela de edicao
		aTreeBUp := aClone(aTree)
	
		// Adiciona uma ocorrencia 
		@aPosObj[2][1]+20,aPosObj[1][4]+5 BUTTON STR0013 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Recl(nOpc,@oTree,@aTree) WHEN lExtOcor  //"Adiciona Ocorrencia"
	
		// Alterar Ocorrencia
		@aPosObj[2][1]+40,aPosObj[1][4]+5 BUTTON STR0030 SIZE 60,15 OF oDlg PIXEL ACTION Tk250OcoAlt(nOpc,@oTree,@aTree,@cAntOcor) When .F.//WHEN lExtOcor //"Alterar Ocorrência"
	
		//Adiciona as A‡”es
		@aPosObj[2][1]+70,aPosObj[1][4]+5 BUTTON STR0014 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Solu(nOpc,@oTree,@aTree) //"Adiciona A‡„o"
	
		// Remove um filho ou um pai com os filhos
		@aPosObj[2][1]+90,aPosObj[1][4]+5 BUTTON oBtnRemIt PROMPT STR0015 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Rem(nOpc,@oTree,@aTree,@cAntOcor) WHEN lExtRemIt //Remove Item
	
		// Move o item um nivel acima
		@aPosObj[2][1]+120,aPosObj[1][4]+5 BUTTON STR0031 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Up(@oTree,@aTree) //"Move para cima"
	
		// Move o item um nivel abaixo
		@aPosObj[2][1]+140,aPosObj[1][4]+5 BUTTON STR0032 SIZE 60,15 OF oDlg PIXEL ACTION Tk250Down(@oTree,@aTree) //"Move para baixo"
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,Tk250Grava(nOpc,oTree,aTree,cAntOcor),oDlg:End()},{|| nOpca := 2,oDlg:End()} )
	
	
	DbSelectarea("SUR")

Else
	AxIncluiAuto(cAlias,NIL,NIL,nOpc,cAlias->(RecNo()))
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk250AltBut³ Autor ³ Michel W. Mosca  	³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controla as alteracoes de estado dos botoes na tela de 	  |±±
±±³          ³de acordo com a acao selecionada de uma ocorrencia		  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250AltBut(ExpA1,ExpO2,ExpL3,ExpL4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|ExpA1 = Array Tree antes da atualizacao no database  		  ³±±
±±³          ³ExpO2 = Botao Remover Acao								  ³±±
±±³          ³ExpL3 = Indica se o botao esta habilitado					  ³±±
±±³          ³ExpL4 = Indica se a ocorrencia possui esta associada a 	  ³±±
±±³          ³        alguma chamada.                                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk250AltBut(aTreeBUp,oBtnRemIt,lExtRemIt,lExtOcor)
Local nPos := 0  //Controla a existencia da acao na ocorrencia

If !lExtOcor 
	nPos := Ascan(aTreeBUp[1,4],{|aVal|  (trim(aVal[1]) == trim(oTree:GetCargo()))})
EndIf

If nPos == 0     			
	lExtRemIt := .T.      	//Acao ainda nao foi salva, permite que ela seja removida
	oBtnRemIt:Enable() 		
Else	
	lExtRemIt := .F. 		//Acao ja foi salva, nao permite que seja removida
	oBtnRemIt:Disable()    
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk250Mont ³ Autor ³ Marcelo Kotaki   		³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de Montagem da Estrutura do TREE                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Mont(ExpO1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|ExpO1 = Objeto TREE										  ³±±
±±³          ³ExpA2 = Array Tree          								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250Mont(oTree,aTree)

Local nRecNo    := 0	// Posicao do Recno da tabela Temporaria do TREE
Local cTreeAnt 	:= ""	// Descricao do Tree auxiliar
Local nRegs 	:= 0	// Contador de posicoes da arvore	
Local nI		:= 0	// Contador 
Local aAux		:= {}	// Array auxiliar para preenchimento do Tree.
Local cFilSUR	:= xFilial("SUR")

DbSelectArea("SUR")
DbSetOrder(1)
DbSeek(cFilSUR+aTree[1][1])
ProcRegua(RecCount())

cTreeAnt := SUR->UR_CODREC+SUR->UR_IDTREE
oTree:BuildTrb(Len(SUR->UR_DESC), Len(SUR->UR_CARGO))

While ( !Eof()) .AND. (SUR->UR_CODREC+SUR->UR_IDTREE == cTreeAnt)
	IncProc()
	nRegs++
	nRecNo := Recno()
	
	cTree := SUR->UR_IDCODE
	
	aTree[1][2] := SUR->UR_DESC
	DBADDTREE oTree PROMPT SUR->UR_DESC RESOURCE "FOLDER12","FOLDER13" CARGO SUR->UR_CARGO
	DbSeek(cFilSUR+SUR->UR_CODREC+SUR->UR_IDCODE)
	While ( !Eof() .AND. SUR->UR_CODREC == aTree[1][1])
		
		nRecTree := Recno()
		If ( SUR->UR_ISTREE <> "S" )
			DBADDITEM oTree PROMPT SUR->UR_DESC RESOURCE "FOLDER5" CARGO SUR->UR_CARGO
			AAdd(aAux,{SUR->UR_CARGO,SUR->UR_DESC})
		Endif

		DbGoTo(nRecTree)
		DbSkip()
	End
		
	DBENDTREE oTree
	
	aTree[1][4]:= aAux

End

DbSelectArea("SUR")
For nI := nRegs To RecCount()
	IncProc()
Next nI

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250Exclui³ Autor ³ Luis marcelo kotaki   ³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de Exclusao de Rela‡„o Ocorrencia x A‡„o           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro 								  ³±±
±±³          ³ ExpN2 = Tipo de Opera‡ao        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk250Exclusao(cAlias,nReg,nOpc)

Local oDlg					// Tela
Local nOpca 		:= 0	// Opcao de retorno da funcao
Local cCodRec		:= ""	// Codigo da Ocorrencia
Local lRet  		:= .F.	// Retorno da funcao
Local aObjects  	:= {}	// Array para redimensionamento da tela
Local aSize			:= {}	// Array para redimensionamento da tela
Local aInfo			:= {}	// Array para redimensionamento da tela
Local aPosObj		:= {}	// Array para redimensionamento da tela
Local aTree			:= {}	// Array do tree

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se este cadastro ja foi trabalhado no atendimento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk250VldAlter(cAlias,nReg,nOpc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avaliacao da rotina automatica.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk250Auto	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize   := MsAdvSize( .T. )  	// Devolve o tamanho da tela atualmente no micro do usuario
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula as coordenadas dos objetos.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aObjects, { 85, 100, .T., .T., .F. } )  
		AAdd( aObjects, { 15, 100, .T., .T., .F. } )  
		aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
		aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )  
		
		AAdd(aTree,{SUR->UR_CODREC,;
					"",;
					SUR->UR_CARGO,;
					{} })
					
		cCodRec := SUR->UR_CODREC // Codigo do registro posicionado.
		
		DEFINE MSDIALOG oDlg TITLE STR0027 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL//"Cadastro de Rela‡„o Ocorrencia x A‡„o - Exclus„o"
		
			@ aPosObj[1][1]-2,aPosObj[1][2]-2 TO aPosObj[1][3]+2,aPosObj[1][4]+2 LABEL STR0012 OF oDlg PIXEL //"Relacionamento"
			DEFINE DBTREE oTree FROM aPosObj[1][1]+5,aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] OF oDlg CARGO
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a arvore com as Perguntas e Respostas          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Processa({|lEnd| Tk250Mont(oTree,@aTree)},STR0025,STR0026,.F.) //"Aguarde","Montando Estrutura do Relacionamento"
		
			// Adiciona uma ocorrencia 
			@aPosObj[2][1]+20,aPosObj[1][4]+5 BUTTON STR0013 SIZE 60,15 OF oDlg PIXEL When .F. //"Adiciona Ocorrencia"
		
			// Alterar Ocorrencia
			@aPosObj[2][1]+40,aPosObj[1][4]+5 BUTTON STR0030 SIZE 60,15 OF oDlg PIXEL When .F. //"Alterar Ocorrência"
		
			//Adiciona as A‡”es
			@aPosObj[2][1]+70,aPosObj[1][4]+5 BUTTON STR0014 SIZE 60,15 OF oDlg PIXEL When .F. //"Adiciona A‡„o"
		
			// Remove um filho ou um pai com os filhos
			@aPosObj[2][1]+90,aPosObj[1][4]+5 BUTTON STR0015 SIZE 60,15 OF oDlg PIXEL When .F. //Remove Item
		
			// Move o item um nivel acima
			@aPosObj[2][1]+120,aPosObj[1][4]+5 BUTTON STR0031 SIZE 60,15 OF oDlg PIXEL When .F. //"Move para cima"
		
			// Move o item um nivel abaixo
			@aPosObj[2][1]+140,aPosObj[1][4]+5 BUTTON STR0032 SIZE 60,15 OF oDlg PIXEL When .F. //"Move para baixo"
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,lRet := Tk250Del(nOpc,oTree,cCodRec),;
														IIF(lRet,oDlg:End(),"")},;
														{|| nOpca := 2,oDlg:End()} )
		
	Else
		Tk250Del(nOpc,oTree,cCodRec)
	Endif

	DbSelectarea("SUR")
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkA250Del ³ Autor ³ Marcelo kotaki  		³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a Exclusao de Rela‡„o Ocorrencia x A‡„o              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpC2 = Codigo da Opera‡„o								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk250Del(nOpc,oTree,cCodRec)
Local aAreaSUR	:= SUR->( GetArea() )
Local lRet 		:= .T.	// Retorno da funcao
Local cFilSUR	:= xFilial("SUR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao da rotina automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUR")
DbSetOrder(1)

If !lTk250Auto

	If TmkOK(STR0028) //"Confirma a exclus„o ?"
		DbSeek(cFilSUR+cCodRec)
		While !Eof() .AND. SUR->UR_FILIAL == cFilSUR .AND. (SUR->UR_CODREC == cCodRec)
			RecLock("SUR",.F.)
			DbDelete()
			MsUnlock()
			DbSkip()
		EndDo
	
		oTree:End()
	Else
		lRet := .F.
	Endif

Else

	cCodRec := SUR->UR_CODREC
	
	If DbSeek(cFilSUR+cCodRec)
		While !Eof() .AND. SUR->UR_FILIAL == cFilSUR .AND. (SUR->UR_CODREC == cCodRec)
			RecLock("SUR",.F.)
			DbDelete()
			MsUnlock()
			SUR->(DbSkip())
		End
	Else
		lRet := .F.
	Endif	
Endif	
RestArea(aAreaSUR)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk250Visual³ Autor ³ Marcelo Kotaki       ³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de Visualiza‡ao do Cad.Rela‡„o Ocorrencia x A‡„o   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Tipo de Opera‡ao        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk250Visual(cAlias,nReg,nOpc)

Local oDlg				// Tela
Local nOpca 	:= 0	// Opcao de retorno OK/CANCELA
Local aObjects  := {}	// Array para redimensionamento da Tela
Local aSize		:= {}	// Array para redimensionamento da Tela
Local aInfo		:= {}	// Array para redimensionamento da Tela
Local aPosObj	:= {}	// Array para redimensionamento da Tela
Local aTree		:= {}	// Array para redimensionamento da Tela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize  := MsAdvSize( .T. )  	// Devolve o tamanho da tela atualmente no micro do usuario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula as coordenadas dos objetos.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 85, 100, .T., .T., .F. } )  
AAdd( aObjects, { 15, 100, .T., .T., .F. } )  
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )  

AAdd(aTree,{SUR->UR_CODREC,'',SUR->UR_CARGO,{}})

DEFINE MSDIALOG oDlg TITLE STR0029 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Cadastro de Rela‡„o Ocorrencia x A‡„o - Visualiza‡„o"

	@ aPosObj[1][1]-2,aPosObj[1][2]-2 TO aPosObj[1][3]+2,aPosObj[1][4]+2 LABEL STR0012 OF oDlg PIXEL //"Relacionamento"
	DEFINE DBTREE oTree FROM aPosObj[1][1]+5,aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] OF oDlg CARGO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a arvore com as Perguntas e Respostas          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|lEnd| Tk250Mont(oTree,@aTree)},STR0025,STR0026,.F.) //"Aguarde","Montando Estrutura do Relacionamento"

	// Adiciona uma ocorrencia 
	@aPosObj[2][1]+20,aPosObj[1][4]+5 BUTTON STR0013 SIZE 60,15 OF oDlg PIXEL When .F. //"Adiciona Ocorrencia"

	// Alterar Ocorrencia
	@aPosObj[2][1]+40,aPosObj[1][4]+5 BUTTON STR0030 SIZE 60,15 OF oDlg PIXEL When .F. //"Alterar Ocorrência"

	//Adiciona as A‡”es
	@aPosObj[2][1]+70,aPosObj[1][4]+5 BUTTON STR0014 SIZE 60,15 OF oDlg PIXEL When .F. //"Adiciona A‡„o"

	// Remove um filho ou um pai com os filhos
	@aPosObj[2][1]+90,aPosObj[1][4]+5 BUTTON STR0015 SIZE 60,15 OF oDlg PIXEL When .F. //Remove Item

	
	// Move o item um nivel acima
	@aPosObj[2][1]+120,aPosObj[1][4]+5 BUTTON STR0031 SIZE 60,15 OF oDlg PIXEL When .F. //"Move para cima"

	// Move o item um nivel abaixo
	@aPosObj[2][1]+140,aPosObj[1][4]+5 BUTTON STR0032 SIZE 60,15 OF oDlg PIXEL When .F. //"Move para baixo"


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()} )

DbSelectarea("SUR")
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk250Up   ºAutor  ³Rafael M. Quadrotti º Data ³  10/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Move o item do Tree(acao)um nivel acima ate ser o primeiro º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Up(ExpO2,ExpA3)    			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpA3 = Array Tree          								  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk250Up(oTree,aTree)

Local aCopyTree := {}	// array de copia para mover objeto.
Local nPos		:= 0	// Posicao do item selecionado no array.
Local nCont		:= 0	// Contador 
Local lFound	:= .F.	// identifica se encontrou o item

If Len(aTree) > 0
	
    DbSelectArea(oTree:cArqTree)
    DbSetOrder(4)
    DbSeek(oTree:GetCargo())    
    If (oTree:cArqTree)->T_ISTREE <> "S"
		lFound := .T.	
	Else
		While ( !(oTree:cArqTree)->(EOF()) ) .AND. (oTree:GetCargo() == (oTree:cArqTree)->T_CARGO)
		   If (oTree:cArqTree)->T_ISTREE <> "S"
				lFound := .T.	
				Exit
			Endif
			DbSkip()
		End	   
		
		If !lFound
			MsgInfo(STR0033)//"Ocorrencias nao podem ser movidas."
		Endif
	Endif	
	
	If lFound
		//Busca foco na acao.
		nPos:= Ascan(aTree[1,4],{|aVal|  (aVal[1] == oTree:GetCargo())})
		If nPos > 0
			aCopyTree := aClone(aTree[1,4,nPos])
			 If nPos-1 > 0
				aTree[1][4][nPos] := aTree[1][4][nPos-1]
				aTree[1][4][nPos-1] := aCopyTree
				oTree:BeginUpdate()
				oTree:Reset() 
				oTree:AddItem(aTree[1][2],aTree[1][3], "FOLDER12","FOLDER13", , ,1)							

	            For nCont := 1 To Len(aTree[1][4])
					oTree:AddItem(aTree[1][4][nCont][2],aTree[1][4][nCont][1], "FOLDER5","FOLDER6", , ,2)							
				Next nCont

				oTree:EndUpdate()
				oTree:TreeSeek(aCopyTree[1])
				oTree:Refresh()
			Endif	 
		Endif	
	Endif	
Endif	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk250Down ºAutor  ³Rafael M. Quadrotti º Data ³  10/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Move o item do Tree(acao)um nivel abaixo até ser o ultimo  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250Down(ExpO2,ExpA3)    			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpA3 = Array Tree          								  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                 		                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk250Down(oTree,aTree)

Local aCopyTree := {}	// array de copia para mover objeto.
Local nPos		:= 0	// Posicao do item selecionado no array.
Local nCont		:= 0	// Contador 
Local lFound	:= .F.	// identifica se encontrou o item

If Len(aTree) > 0

	DbSelectArea(oTree:cArqTree)
    DbSetOrder(4)
    DbSeek(oTree:GetCargo())    
    If (oTree:cArqTree)->T_ISTREE <> "S"
		lFound := .T.	
	Else
		While ( !(oTree:cArqTree)->(EOF()) ) .AND. (oTree:GetCargo() == (oTree:cArqTree)->T_CARGO)
		   If (oTree:cArqTree)->T_ISTREE <> "S"
				lFound := .T.	
				Exit
			Endif
			DbSkip()
		End	   
		
		If !lFound
			MsgInfo(STR0033)//"Ocorrencias nao podem ser movidas."
		Endif
	Endif	
	
	If lFound
		//Busca foco na acao.
		nPos:= Ascan(aTree[1,4],{|aVal|  (aVal[1] == oTree:GetCargo())})
		If nPos > 0
			aCopyTree := aClone(aTree[1,4,nPos])
			If nPos < (oTree:nTotal)-1
				aTree[1][4][nPos] := aTree[1][4][nPos+1]
				aTree[1][4][nPos+1] := aCopyTree
				oTree:BeginUpdate()
				oTree:Reset() 
				oTree:AddItem(aTree[1][2],aTree[1][3], "FOLDER12","FOLDER13", , ,1)							

	            For nCont := 1 To Len(aTree[1][4])
					oTree:AddItem(aTree[1][4][nCont][2],aTree[1][4][nCont][1], "FOLDER5","FOLDER6", , ,2)							
				Next nCont

				oTree:EndUpdate()
				oTree:TreeSeek(aCopyTree[1])
				oTree:Refresh()
			Endif	
		Endif	
	Endif		
Endif	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk250OcoAltºAutor ³Rafael M. Quadrotti º Data ³  10/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera a ocorrencia principal.                              º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250OcoAlt(ExpN1,ExpO2,ExpA3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Operacao 											  ³±±
±±³          ³ExpO2 = Objeto TREE										  ³±±
±±³          ³ExpA3 = Array Tree          								  ³±±
±±³          ³ExpC4 = Codigo da ocorrencia anterior						  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk250OcoAlt(nOpc,oTree,aTree,cAntOcor)

Local aArea := GetArea()	// Salva a area atual		

If Len(aTree) > 0
	
	cAntOcor := aTree[1][1]
	    
    If nOpc <> 3
    
	    DbSelectArea(oTree:cArqTree)
    	DbSetOrder(4)
	    DbSeek(oTree:GetCargo())    
    
    	DbSelectArea("SUR")
	    DbSetOrder(1)
    	If DbSeek(xFilial("SUR")+aTree[1][1]+(oTree:cArqTree)->T_IDTREE+(oTree:cArqTree)->T_IDCODE)
			IF SUR->UR_ISTREE =="S"
				Tk250Recl(nOpc,@oTree,@aTree,.T.)
    		Endif
   		Endif
	Else
		Tk250Recl(nOpc,@oTree,@aTree,.T.)
		oTree:Refresh()		
	Endif
Endif      

RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk250VldAlºAutor  ³Rafael M. Quadrotti º Data ³  11/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validacao da rotina de ALTERACAO DO CADASTRO    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk250VldAlter(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Tipo de Opera‡Æo        							  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk250VldAlter(cAlias,nReg,nOpc)
Local lRet 		:= .T.	// Retorno da funcao
Local aAreaSUR	:= SUR->( GetArea() )
Local cFilSUD	:=  xFilial("SUD")
Local cAliasSUD	:= GetnextAlias()
Local cMsg		:= STR0042 + Chr(13) + Chr(10) + STR0043 + Chr(13) + Chr(10) + STR0044 + Chr(13) + Chr(10)  // 'As Opções são: ' # '1) Inclua uma nova ação' # '2) Inclua um novo relacionamento de Ocorrências x Ações'

SUR->( DbGoTo(nReg) )
//Declara a ordem que será utilizada pelo SqlOrder()
DbSelectArea("SUD")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca no arquivo de Itens do Telemarketing se houve registro dessa Ocorrencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=	" SELECT SUD.UD_FILIAL, SUD.UD_OCORREN " +;
			" FROM " + RetSqlName("SUD") + " SUD" +;
			" WHERE	SUD.UD_FILIAL = '" + xFilial("SUD") + "' AND " +;
			"		SUD.UD_OCORREN = '" + SUR->UR_CODREC + "' AND " +;
			"		SUD.D_E_L_E_T_ = '' " +;
			" ORDER BY " + SqlOrder(IndexKey())

cQuery := ChangeQuery(cQuery)

SUD->(DbCloseArea() )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSUD , .F., .T.)
	
While !Eof() .AND. (cAliasSUD)->UD_FILIAL == cFilSUD
	If (cAliasSUD)->UD_OCORREN == SUR->UR_CODREC 
		lRet := .F.	
		Exit
	Endif
	
	(cAliasSUD)->(DbSkip())
EndDo

(cAliasSUD)->(DbCloseArea())

If !lRet
	If nOpc = 4 
		Help(" ",1,"TK250NOALT", ,STR0041,1,1,,,,,,{cMsg} ) //'Este relacionamento Ocorrência x Ação já foi utilizado e não poderá ser totalmente alterado pois faz parte dos registros de movimentação do sistema' 
	ElseIf nOpc = 5
		Help(" ",1,"GRAVADO" , , STR0045) //'Ocorrência x Ação já Gravada'
	Endif
Endif

RestArea(aAreaSUR)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK250Legenda ºAutor  ³Marcelo Kotaki   º Data ³  23/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legendas do cadastro                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk250Legenda()
//"Legenda"
BrwLegenda(cCadastro,STR0034,{	{"BR_AZUL" 	, STR0016 	},;		//"Ocorrência"
									{"BR_VERDE"	, STR0020	}})     //"Ação" 
Return(.T.)