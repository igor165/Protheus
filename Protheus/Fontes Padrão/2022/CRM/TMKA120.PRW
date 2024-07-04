#INCLUDE "TMKA120.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"

/*

ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³	ACOLS DA ROTINA DE TELEMARKETING													 ³
³	01 - Assunto																		 ³
³	02 - Descricao do assunto				 											 ³
³	03 - Produto																		 ³
³	04 - Descricao do produto															 ³
³	05 - Ocorrencia																		 ³	
³	06 - Descricao da ocorrencia														 ³
³	07 - Acao																			 ³
³	08 - Descricao da Acao																 ³
³	09 - Responsavel       																 ³
³	10 - Nome do Responsavel															 ³
³	11 - Data da Acao																	 ³
³	12 - Status    																		 ³
³	13 - Observacao      			   													 ³
³	14 - Data da Execucao		- NAO ESTAO NO SX3 PORQUE NAO SAO PREVISIVEIS			 ³
³	15 - Complemento 			- NAO ESTAO NO SX3 PORQUE NAO SAO PREVISIVEIS			 ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TmkA120	³ Autor ³ Fabio Rogerio   	    ³ Data ³ 17/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa Configura‡ao do TeleMarketing   		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ SIGATMK					 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³02/09/02³710   ³-Revisao do fonte                           ³±±
±±³Fernando  ³12/12/06³912   |Bops 115397 Alterado a array aRotina        ³±±
±±³          ³        |      ³para criação do menu funcional              ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmka120()

Private cCadastro 	:= STR0001//"Configuracao Telemarketing"

Private aRotina		:= MenuDef() 
MBrowse( 6, 1,22,75,"SUE")

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

Local aRotina:=	{  		{ STR0002 ,"AxPesqui"       , 0 , 1 , , .F. },; //"Pesquisar"
						{ STR0003 ,"Tk120ConfTmk"   , 0 , 2 , , .T. },; //"Visualizar"
						{ STR0004 ,"Tk120ConfTmk"   , 0 , 3 , , .T. },; //"Incluir"
						{ STR0005 ,"Tk120ConfTmk"   , 0 , 4 , , .T. },; //"Alterar"
						{ STR0007 ,"Tk120ConfTmk"   , 0 , 5 , , .T. } } //"Excluir"

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Tk120ConfTmk	  ³ Autor ³ Fabio Rogerio         ³ Data ³ 17/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa Configura‡ao do TeleMarketing   	        	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ SigaTmk					 								        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.³12/04/07³10    |Bops 123891 Alterado a maneira e o momento que a  ³±±
±±³          ³        |      ³rotina pega as posições dos campos no aHeader.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk120ConfTmk(cAlias,nReg,nOpc)

Local lRet		 := .F.								// Retorno da funcao
Local aAC        := { STR0008,STR0009 } 			//"Abandona","Confirma"
Local oEnchoice
Local cNumCfg    := ""
Local oDlg
Local oGet
Local aCampos    := {}
Local aSize      := MsAdvSize( .T., .F., 400 )		// Size da Dialog
Local aObjects   := {} 
Local aInfo      := {}
Local aPosObj    := {}
Local nUsado	 := 0
Local lCancelada := .F.								//Flag para indicar que a configuracao esta cancelada
Local nSaveSx8 	 := GetSX8Len()      				// Funcao de numeracao

Private aPosicoes	:= {}
Private aTela[0][0]
Private aGets[0][0] 
Private aHeader[0]
Private nFolder  	:= 4							// Criado para utilizacao das funcoes das rotinas TMKXFUN*.*
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Protege rotina para que seja usada apenas no SIGATMK ou SIGACRM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !AmIIn(13,73)			// 13 = SIGATMK, 73 = SIGACRM
	Return(lRet)
Endif
           
// Se o tipo de atendimento nao estiver cadastrado corretamente
If !TMKOPERADOR()
	Help("  ",1,"OPERADOR")		//Esse usuario nao esta associado com um operador. Ou nao se trata de um operador valido..."
	Return(lRet)
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 25 (ACS), verifica se o usu rio poder  ou n„o	 ³
//³ efetuar um Atendimento. 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkPsw(25)
	Return(lRet)
Endif
  
RegToMemory("SUE",IIF(nOpc == 3,.T.,.F.))  

If nOpc <> 3					// Se a operacao for diferente de Inclusao
	cNumCfg := SUE->UE_CODIGO
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao for uma inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se estiver cancelado essa configuracao desabilita os objetos da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SUE->UE_CODCANC)
		Help(" ",1,"CONFIGCAN")
		lCancelada := .T.
		nOpc := 2
	Endif
Endif
// Carrega Matriz aCols
Private aCOLS[1][nUsado+1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Acols para inclusao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk120Itens(cNumCfg,nOpc,nUsado)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o array aPosicoes para que n„o  haja conflito na ordem dos campos no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET EXACT ON
AADD(aPosicoes,{"UF_ASSUNTO"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_ASSUNTO"})})	//01
AADD(aPosicoes,{"UF_DESCASS"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCASS"})})	//02
AADD(aPosicoes,{"UF_PRODUTO"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_PRODUTO"})})	//03
AADD(aPosicoes,{"UF_DESCPRO"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCPRO"})})	//04
AADD(aPosicoes,{"UF_OCORREN"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_OCORREN"})})	//05
AADD(aPosicoes,{"UF_DESCOCO"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCOCO"})})	//06
AADD(aPosicoes,{"UF_CODSOL"   ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_CODSOL"})})	//07
AADD(aPosicoes,{"UF_DESCSOL"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCSOL"})})	//08
AADD(aPosicoes,{"UF_OPERADO"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_OPERADO"})})	//09
AADD(aPosicoes,{"UF_DESCOPE"  ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCOPE"})})	//10
AADD(aPosicoes,{"UF_DATA"     ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DATA"})})		//11
AADD(aPosicoes,{"UF_STATUS"   ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_STATUS"})})	//12
AADD(aPosicoes,{"UF_OBS"      ,Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_OBS"})})		//13
SET EXACT OFF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divide a tela horizontalmente para os objetos enchoice e getdados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )

DEFINE MSDIALOG oDlg TITLE STR0001 +" - "+ aRotina[nOpc][1] FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP) //"Configuracao Telemarketing "

	SET KEY VK_F9 to Tk120Car()    //Caracteristicas do Produto
	
	Zero()
	oEnchoice:= MsMGet():New(cAlias, nReg, nOpc, aAC,"AC",STR0010,,aPosObj[1],,,,,,,,.T.,.F.,"aTela",.T.) 	//"Quanto a exclusao ?"
	oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AlwaysTrue","AlwaysTrue","",.T.)
	oGet:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],AlwaysTrue(),oGet:oBrowse:Refresh(.F.)}
	
	lRet := .T.
	
ACTIVATE MSDIALOG oDlg ON INIT ( Tk120Bar(@oDlg,nOpc,cNumCfg,nSaveSX8),;
								 Tk120HabObj(lCancelada,@oEnchoice,@oGet) )

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120Itens³ Autor ³ Fabio Rogerio         ³ Data ³ 03/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Acols para inclusao ou alteracao de orcamento		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk120Itens(ExpC1, ExpN2, ExpN3)                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da regra de tmk a ser exibida               ³±±
±±³          ³ ExpN2 = Opcao selecionada pelo usuario                     ³±±
±±³          ³ ExpN3 = Numero de campos do aHeader                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ TmkA120		            								  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMichel M. ³17/01/07³9.12  ³Bops.115779 - Implementacao da funcao       º±±
±±º          ³        ³      ³FillGetDados() para preencher o Acols da    º±±
±±º          ³        ³      ³rotina.                                     º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                            
Static Function Tk120Itens(cNumCfg,nOpc,nUsado)
Local aArea		:= GetArea()
Local cSeek		:= ""	//Armazena a string de busca
Local cWhile	:= ""	//Armazena a condição de parada
Local bCond            	//Armazena a condicao para validar os registros
Local cQuery	:= ""   //Armazena a query para TOP

#IFDEF TOP

	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SUF")+" SUF  "
	cQuery += "WHERE SUF.UF_FILIAL='"+xFilial("SUF")+"' AND "
	cQuery += "SUF.UF_CODIGO='"+cNumCfg+"' AND "
	cQuery += "SUF.D_E_L_E_T_<>'*' "
	cQuery += "ORDER BY "+SqlOrder(SUF->(IndexKey()))		
	
#ENDIF

DbSelectArea("SUF")
DbCloseArea()        

cSeek	:= xFilial("SUF") + cNumCfg
cWhile	:= "SUF->UF_FILIAL + SUF->UF_CODIGO"	
bCond	:= {||IIf(SUF->UF_FILIAL == xFilial('SUF') .AND. SUF->UF_CODIGO == cNumCfg,.T.,.F.)}    


aHeader := {}
aCols	:= {}
FillGetDados(	nOpc /*nOpcX*/, "SUF"/*cAlias*/, 1/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, IIf(nOpc == 3, .T.,.F.)/*lEmpty*/,; 
				/*aHeaderAux*/, /*aColsAux*/, {||Tk120MontAcols()}/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, "SUF"/*cAliasQry*/)

DbSelectArea("SUF")
DbCloseArea()	

RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120MontAcols  ³ Autor ³ Michel Mosca    ³ Data ³17/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o Acols da tela                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka120					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Static Function Tk120MontAcols()   
Local nPAssunto := 0	//Assunto
Local nPDescAss := 0	//Descricao do Assunto	
Local nPProd 	:= 0	//Produto
Local nPDescPro := 0	//Descricao do Produto
Local nPOcorren	:= 0	//Ocorrencia	
Local nPDescOco	:= 0	//Descricao da Ocorrencia
Local nPAcao   	:= 0	//Acao
Local nPDescAca	:= 0	//Descricao da Acao
Local nPCodOpe 	:= 0	//Codigo do Operador
Local nPDescOpe	:= 0	//Descricao do Operador
Local nCnt	:= Len(aCols)


nPAssunto := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_ASSUNTO"})
nPDescAss := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCASS"})
nPProd 	  := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_PRODUTO"})
nPDescPro := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCPRO"})
nPOcorren := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_OCORREN"})
nPDescOco := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCOCO"})
nPAcao    := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_CODSOL"})
nPDescAca := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCSOL"})
nPCodOpe  := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_OPERADO"})
nPDescOpe := Ascan(aHeader, {|x|AllTrim(x[2]) == "UF_DESCOPE"})
		
		

		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se a tabela de assunto esta atualizada no SX5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[nCnt][nPAssunto])
	DbSelectarea("SX5")
	DbSetorder(1)
	If !(DbSeek( xFilial("SX5")+"T1"+aCols[nCnt][nPAssunto]))
		Help(" ",1,"ASSUNTO" )
	Endif
	
	aCols[nCnt][nPDescAss] := X5DESCRI()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o produto esta atualizado no SB1          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[nCnt][nPProd])
	DbSelectarea("SB1")
	DbSetorder(1)
	If !(DbSeek(xFilial("SB1")+aCols[nCnt][nPProd] ))
		Help(" ",1,"B1PROD" )
	Endif
	aCols[nCnt][nPDescPro] := SB1->B1_DESC
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se a ocorrencia esta atualizada no SU9       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[nCnt][nPOcorren])
	DbSelectarea("SU9")
	DbSetorder(1)
	If ! DbSeek(xFilial("SU9")+aCols[nCnt][nPAssunto]+aCols[nCnt][nPOcorren])
		Help(" ",1,"OCORRENCIA")
	Endif
	aCols[nCnt][nPDescOco] := SU9->U9_DESC
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se a acao esta atualizada na tabela SUQ      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[nCnt][nPAcao])
	DbSelectarea("SUQ")
	DbSetorder(1)
	If !DbSeek( xFilial("SUQ")+aCols[nCnt][nPAcao])
		Help(" ",1,"ACAO")
	Endif
	aCols[nCnt][nPDescAca] := SUQ->UQ_DESC
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o responsavel pela acao esta no PSS       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[nCnt][nPCodOpe])
	PswOrder(1)
	If PswSeek(aCols[nCnt][nPCodOpe])
		aUser := PswRet(1)
		If Len(aUser) > 0
			aCols[nCnt][nPDescOpe] := aUser[1][2]
		Else
			aCols[nCnt][nPDescOpe] := ""
		Endif
	Endif
Endif


Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120Bar  ³ Autor ³ Marcelo Kotaki        ³ Data ³02/09/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka120					 						     	  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºHanna C.  |30/03/07|9.12  ³Bops 118469 - Alterado o nome dos Bitmaps   ³±±
±±º        	 ³        |      ³definidos pela Engenharia para o Protheus 10³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk120Bar(oDlg,nOpc,cNumCfg,nSaveSX8)

Local aButtons 	:= {}

If nOpc <> 3
	AAdd(aButtons,{ "EXCLUIR"    , {|| IIF(Tk120Exc(nOpc,oDlg),oDlg:End(),"")} 	, STR0012 }) //"Cancelar"
Endif	

AAdd(aButtons,{ "AFASTAMENTO", {|| Tk120VCan(.F.,nOpc,.F.)}, STR0014,STR0022 }) //"Motivo de Cancelamento" , "Cancelamento"
AAdd(aButtons,{ "PRODUTO"    , {|| Tk120ConCamp()}         , STR0019,STR0023 }) //"Informa‡”es da Campanha", "Script"
AAdd(aButtons,{ "DbG09"      , {|| Tk120Car()}        		, STR0015,STR0024 }) //"Caracteristicas"        , "Produto"
AAdd(aButtons,{ "RELATORIO"  , {|| TkConcorrente(1)}    	, STR0016,STR0025 }) //"Concorrentes"           , "Concorre"

EnchoiceBar(oDlg,{||IIf(Tk120Grava(cNumCfg,nOpc,nSaveSX8),oDlg:End(),"")},{||Tk120Fim(nOpc,nSaveSX8),oDlg:End()},,aButtons)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120Exc  ³ Autor ³ Fabio Rogerio         ³ Data ³03/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a Exclus„o de um item do acols                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Sigatmk              						   		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/12/01³609   ³-O usuario podia cancelar sem confirmar     ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk120Exc(nOpc)
Local lRet := .F.

If (nOpc <> 2)		//Visualizar
	If !Empty(SUE->UE_CODCANC)
		Help(" ",1,"CONFIGCAN")
		Return(lRet)
	Endif
		
	If TmkOK(STR0017) //"Confirma o Cancelamento ?"
		If Tk120VCan(.T.,nOpc,.T.)
			lRet := .T.
        Endif
	Endif
Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120VCan ³ Autor ³ Fabio Rogerio         ³ Data ³03/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Consulta do Motivo de cancelamento  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	     ³ Generico 						   	 	        		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/12/01³609   ³-O usuario podia cancelar sem confirmar     ³±±
±±³Marcelo K ³03/09/02³710   ³-Revisao da funcoa                          ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk120VCan(lHabilita,nOpc,lExclui)

Local nOpcA	  := 0
Local lRet	  := .F.	
Local oVCan
Local oObs
Local cObs 	  := ""
Local oMonoAs := TFont():New( "Courier New", 6, 0 )

//Se nao foi executado pela rotina de exclusao
If !lExclui
	If nOpc == 3 					// Se for inclusao	
		Help(" ",1,"TMKCFGNCA")		// Mensagem avisando que essa configuracao nao esta cancelada
		Return(lRet)
	ElseIf Empty(SUE->UE_CODCANC) 
		Help(" ",1,"TMKCFGNCA")		
		Return(lRet)
	Endif
Endif

DEFINE MSDIALOG oVCan FROM 05,10 TO 170,270 TITLE STR0014 PIXEL OF oMainWnd //"Motivo de Cancelamento"

	cObs := MSMM(SUE->UE_CODCANC,TamSx3("UE_OBSCANC")[1])

	@03,04 TO 62,128 LABEL STR0021 OF oVCan PIXEL  //"Motivo" 	                

	// Se estiver desabilitado coloca o memo em READONLY
	If !lHabilita	
		@12,08 GET oObs VAR cObs OF oVCan MEMO SIZE 113,45 PIXEL Valid !Empty(cObs) READONLY
	Else
		@12,08 GET oObs VAR cObs OF oVCan MEMO SIZE 113,45 PIXEL Valid !Empty(cObs) WHEN .T.
	Endif	
	oObs:oFont := oMonoAs

	DEFINE SBUTTON FROM 65,70  TYPE 2 ACTION oVCan:End() ENABLE OF oVCan
	DEFINE SBUTTON FROM 65,100 TYPE 1 ACTION (nOpca := 1,oVCan:End()) ENABLE OF oVCan

ACTIVATE MSDIALOG oVCan CENTER

oMonoAs:End()

If (nOpca == 1) .AND. lHabilita
	DbSelectarea("SUE")
	RecLock("SUE",.F.)
	MSMM(,TamSx3("UE_OBSCANC")[1],,cObs,1,,,"SUE","UE_CODCANC")
	MsUnlock()
	
	lRet := .T.
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120Car  ³ Autor ³ Fabio Rogerio 		³ Data ³ 03/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega Caracteristicas									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ Sigatmk      			 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk120Car()

SET KEY VK_F9 to

TkProduto()

SET KEY VK_F9 to Tk120Car()    //Caracteristicas do Produto

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120ConCamp()  ³ Autor ³ Fabio Rogerio         ³ Data ³ 03/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta a estrutura do script dinƒmico da campanha               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	     ³TMKA120         		 									        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk120ConCamp()

Local cCodCamp 	:= ""
Local bCampo	:= ""
Local cAlias	:= Alias()
Local lRet		:= .F.

// Se nao houver uma campanha selecionada
If Empty( M->UE_CODCAMP )
	Help(" ",1,"SEMCAMPANH")

Else
	// Compatibiliza‡ao com a fun‡ao a230visual do programa TMKA230.PRW - Cadadastro de Campanhas
	Private cCadastro := STR0020 //"Visualiza‡„o da Campanha"
	Private aTELA[0][0],aGETS[0]
	
	// Pego o codigo da campanha
	cCodCamp := M->UE_CODCAMP
	
	DbSelectarea("SUO")
	DbSetorder(1)
	INCLUI := .F.
	If DbSeek(xFilial("SUO")+cCodCamp)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a entrada de dados do arquivo                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bCampo := {|nCPO| Field(nCPO) }

		FWExecView( STR0019, "TMKA310", 1 )//"Informações de Campanha" ## Visualizar
				
		DbSelectarea(cAlias)
		lRet := .T.
	Endif
Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tk120Delete ³ Autor ³ Fabio Rogerio Pereira³Data ³ 06/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os registros referentes a configuracao     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Tk310Dele                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³01/09/02³710   ³-Revisao do fonte                           ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk120Delete()
Local lRet := .F.

BEGIN TRANSACTION

	If TmkOK(STR0011) //"Confirma a exclus„o desta campanha ?"
	
		DbSelectArea("SUF")
		DbSetOrder(1)
		DbSeek(xFilial("SUF")+SUE->UE_CODIGO)
		While (!Eof()) .AND. (UF_FILIAL == xFilial("SUF")) .AND. (UF_CODIGO == SUE->UE_CODIGO)
			Reclock("SUF",.F.,.T.)
			DbDelete()
			MsUnlock()
			DbSkip()
		End
	
		DbSelectArea("SUE")
		Reclock("SUE" ,.F.,.T.)
		DbDelete()
		MsUnlock()
		
		lRet := .T.
	Endif

END TRANSACTION

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK120DescUsu³ Autor ³ Fabio Rogerio      ³ Data ³ 21/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolve o nome do usuario  selecionado para a ACAO         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP6 Call Center                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk120DescUsu()

Local nPCodOpe := aPosicoes[9][2]
Local cNome    := ""
Local aUser	   := {}
	 
If !Empty(aCols[n,nPCodOpe])
	PswOrder(1)
	If PswSeek(aCols[n][nPCodOpe])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica as informacoes do usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aUser:= PswRet(1)
	   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o nome do usuario 	     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNome := aUser[1][2]
	Endif
Endif

Return(cNome)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk120Grava³ Autor ³ Fabio Rogerio         ³ Data ³ 28/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as informacoes do orcamento com integridade.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tk120Grava									     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³01/09/02³710   ³-Revisao do fonte                           ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk120Grava(cNumCfg,nOpc,nSaveSX8)

Local lGrava  := .F.	
Local nX 	  := 0
Local nI      := 0
Local nPos    := 0
Local lRet	  := .F.
Local cI	  := "00"
	
//Se for visualizacao nao grava nada
If (nOpc == 2)
	Return(.T.)
	
ElseIf (nOpc == 5) //Exclusao
	lRet := Tk120Delete()
	Return(lRet)
Endif

//Valida os campos obrigatorios
If !Obrigatorio(aGets,aTela)
	Return(lRet)
Endif

BEGIN TRANSACTION
	
	If nOpc == 4 //ALTERACAO
			
		//Apago os itens
		DbSelectArea("SUF")
		DbSetOrder(1)
		DbSeek(xFilial("SUF")+cNumCfg)
		While (!Eof()) .AND. (SUF->UF_FILIAL == xFilial("SUF")) .AND. (SUF->UF_CODIGO == cNumCfg)
			RecLock("SUF",.F.,.T.)
			DbDelete()
			MsUnlock()
			DbSkip()
		End
	Endif
	
	If nOpc <> 3
		lGrava := .F.
	Else
		lGrava := .T.
	Endif            
	   
	RecLock("SUE",lGrava) 
	For nI := 1 TO FCount()
		If (FieldName(nI) == "UE_FILIAL" )
			FieldPut(nI, xFilial("SUE"))
		Else
			FieldPut(nI, M->&(FieldName(nI)))
		Endif
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o memo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSMM(,TamSx3("UE_OBS")[1],,M->UE_OBS,1,,,"SUE","UE_CODOBS")
	MsUnlock()
	FKCommit()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for inclusao atualiza o controle de numeracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		End	
	Endif
		
	DbSelectarea("SUF")	
	For nI := 1 To Len(aCols)
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a linha nao foi apagada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aCols[nI][Len(aHeader)+1]
			cI := SomaIt(cI)

			Reclock("SUF",.T.)
			bCampo := {|nCPO| Field(nCPO) }
			
			Replace SUF->UF_FILIAL  With xFilial("SUF")
			Replace SUF->UF_CODIGO  With M->UE_CODIGO
			Replace SUF->UF_ITEM    With cI		
			
			For nX := 1 To SUF->(FCount())
				If (EVAL(bCampo,nX) <> "UF_FILIAL") .AND. (EVAL(bCampo,nX) <> "UF_CODIGO")
					nPos:= Ascan(aHeader,{|x| ALLTRIM(EVAL(bCampo,nX)) == ALLTRIM(x[2])})
					If (nPos > 0)
						If (aHeader[nPos][10] <> "V" .AND. aHeader[nPos][08] <> "M")
							Replace SUF->&(EVAL(bCampo,nX)) With aCols[nI][nPos]
						Endif   
					Endif
				Endif
			Next nX
		
			MsUnlock()
			Dbcommit()
		Endif
	Next nI
         
	lRet := .T.

END TRANSACTION

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA120   º Autor ³Marcelo Kotaki      º Data ³  02/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Finaliza a saida da tela de configuracao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk120Fim(nOpc,nSaveSX8)

If nOpc == 3
	While (GetSx8Len() > nSaveSx8)
		RollBackSX8()
	End
Endif

SET KEY VK_F5 to
SET KEY VK_F9 to

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk120HabObj ³ Autor ³Luis Marcelo Kotaki    ³ Data ³23/08/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Habilita ou Desabilita os Objetos da Tela      	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 = .T. = Habilita .F. = Desabilita                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³AP6 - Call Center       	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³09/09/02³710   ³-Revisao do fonte                     	  ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk120HabObj(lCancelada,oEnchoice,oGet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilita os objetos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCancelada
	oGet:oBrowse:Disable()
Else
	oGet:oBrowse:Enable()
Endif

Return(.T.)

//----------------------------------------------------------------
/*/{Protheus.doc} Tk120Desc()
Função para realizar a inicialização padrão da descrição do assunto
@author Serviços
@since 10/11/2014
/*/
//----------------------------------------------------------------
Function Tk120Desc()
Local cDesc	:= ""
Local nX		:= 0
Local nCnt		:= Len(aCols)

If !INCLUI
	nX := aScan(aHeader,{|x| AllTrim(x[2])=="UF_ASSUNTO"})
	
	If !Empty(aCols[nCnt][nX])
		cDesc := Posicione("SX5",1,XFILIAL("SX5")+"T1" + SUF->UF_ASSUNTO,"X5DESCRI()")
	EndIf	 
EndIf

Return(cDesc)