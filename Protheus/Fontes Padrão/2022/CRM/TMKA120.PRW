#INCLUDE "TMKA120.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"

/*

쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�	ACOLS DA ROTINA DE TELEMARKETING													 �
�	01 - Assunto																		 �
�	02 - Descricao do assunto				 											 �
�	03 - Produto																		 �
�	04 - Descricao do produto															 �
�	05 - Ocorrencia																		 �	
�	06 - Descricao da ocorrencia														 �
�	07 - Acao																			 �
�	08 - Descricao da Acao																 �
�	09 - Responsavel       																 �
�	10 - Nome do Responsavel															 �
�	11 - Data da Acao																	 �
�	12 - Status    																		 �
�	13 - Observacao      			   													 �
�	14 - Data da Execucao		- NAO ESTAO NO SX3 PORQUE NAO SAO PREVISIVEIS			 �
�	15 - Complemento 			- NAO ESTAO NO SX3 PORQUE NAO SAO PREVISIVEIS			 �
쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
*/

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � TmkA120	� Autor � Fabio Rogerio   	    � Data � 17/03/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Programa Configura놹o do TeleMarketing   		          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso 	 � SIGATMK					 								  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �02/09/02�710   �-Revisao do fonte                           낢�
굇쿑ernando  �12/12/06�912   |Bops 115397 Alterado a array aRotina        낢�
굇�          �        |      쿾ara cria豫o do menu funcional              낢�
굇�          �        �      �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function Tmka120()

Private cCadastro 	:= STR0001//"Configuracao Telemarketing"

Private aRotina		:= MenuDef() 
MBrowse( 6, 1,22,75,"SUE")

Return(.T.) 

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    |MenuDef   � Autor � Fernando Amorim       � Data �08/12/06  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Funcao de defini豫o do aRotina                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � aRotina   retorna a array com lista de aRotina             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � SIGATMK                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function MenuDef() 

Local aRotina:=	{  		{ STR0002 ,"AxPesqui"       , 0 , 1 , , .F. },; //"Pesquisar"
						{ STR0003 ,"Tk120ConfTmk"   , 0 , 2 , , .T. },; //"Visualizar"
						{ STR0004 ,"Tk120ConfTmk"   , 0 , 3 , , .T. },; //"Incluir"
						{ STR0005 ,"Tk120ConfTmk"   , 0 , 4 , , .T. },; //"Alterar"
						{ STR0007 ,"Tk120ConfTmk"   , 0 , 5 , , .T. } } //"Excluir"

Return(aRotina)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � Tk120ConfTmk	  � Autor � Fabio Rogerio         � Data � 17/03/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Programa Configura놹o do TeleMarketing   	        	        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso 	 � SigaTmk					 								        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                               낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿎onrado Q.�12/04/07�10    |Bops 123891 Alterado a maneira e o momento que a  낢�
굇�          �        |      퀁otina pega as posi寤es dos campos no aHeader.    낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿛rotege rotina para que seja usada apenas no SIGATMK ou SIGACRM�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !AmIIn(13,73)			// 13 = SIGATMK, 73 = SIGACRM
	Return(lRet)
Endif
           
// Se o tipo de atendimento nao estiver cadastrado corretamente
If !TMKOPERADOR()
	Help("  ",1,"OPERADOR")		//Esse usuario nao esta associado com um operador. Ou nao se trata de um operador valido..."
	Return(lRet)
Endif


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� A ocorrencia 25 (ACS), verifica se o usu쟲io poder� ou n꼘	 �
//� efetuar um Atendimento. 									 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !ChkPsw(25)
	Return(lRet)
Endif
  
RegToMemory("SUE",IIF(nOpc == 3,.T.,.F.))  

If nOpc <> 3					// Se a operacao for diferente de Inclusao
	cNumCfg := SUE->UE_CODIGO
Endif


//旼컴컴컴컴컴컴컴컴컴컴컴�
//쿞e nao for uma inclusao�
//읕컴컴컴컴컴컴컴컴컴컴컴�
If nOpc <> 3
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿞e estiver cancelado essa configuracao desabilita os objetos da tela �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty(SUE->UE_CODCANC)
		Help(" ",1,"CONFIGCAN")
		lCancelada := .T.
		nOpc := 2
	Endif
Endif
// Carrega Matriz aCols
Private aCOLS[1][nUsado+1]

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Carrega Acols para inclusao   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Tk120Itens(cNumCfg,nOpc,nUsado)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿎arrega o array aPosicoes para que n꼘  haja conflito na ordem dos campos no SX3�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Divide a tela horizontalmente para os objetos enchoice e getdados   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120Itens� Autor � Fabio Rogerio         � Data � 03/03/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o 쿒era Acols para inclusao ou alteracao de orcamento		  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � Tk120Itens(ExpC1, ExpN2, ExpN3)                            낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpC1 = Codigo da regra de tmk a ser exibida               낢�
굇�          � ExpN2 = Opcao selecionada pelo usuario                     낢�
굇�          � ExpN3 = Numero de campos do aHeader                        낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso 	 � TmkA120		            								  낢�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴錮袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튝ichel M. �17/01/07�9.12  쿍ops.115779 - Implementacao da funcao       볍�
굇�          �        �      쿑illGetDados() para preencher o Acols da    볍�
굇�          �        �      퀁otina.                                     볍�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/                            
Static Function Tk120Itens(cNumCfg,nOpc,nUsado)
Local aArea		:= GetArea()
Local cSeek		:= ""	//Armazena a string de busca
Local cWhile	:= ""	//Armazena a condi豫o de parada
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120MontAcols  � Autor � Michel Mosca    � Data �17/01/07  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Monta o Acols da tela                					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso 	 � Tmka120					 						     	  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
		
		

		
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣alida se a tabela de assunto esta atualizada no SX5�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If !Empty(aCols[nCnt][nPAssunto])
	DbSelectarea("SX5")
	DbSetorder(1)
	If !(DbSeek( xFilial("SX5")+"T1"+aCols[nCnt][nPAssunto]))
		Help(" ",1,"ASSUNTO" )
	Endif
	
	aCols[nCnt][nPDescAss] := X5DESCRI()
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣alida se o produto esta atualizado no SB1          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If !Empty(aCols[nCnt][nPProd])
	DbSelectarea("SB1")
	DbSetorder(1)
	If !(DbSeek(xFilial("SB1")+aCols[nCnt][nPProd] ))
		Help(" ",1,"B1PROD" )
	Endif
	aCols[nCnt][nPDescPro] := SB1->B1_DESC
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣alida se a ocorrencia esta atualizada no SU9       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If !Empty(aCols[nCnt][nPOcorren])
	DbSelectarea("SU9")
	DbSetorder(1)
	If ! DbSeek(xFilial("SU9")+aCols[nCnt][nPAssunto]+aCols[nCnt][nPOcorren])
		Help(" ",1,"OCORRENCIA")
	Endif
	aCols[nCnt][nPDescOco] := SU9->U9_DESC
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣alida se a acao esta atualizada na tabela SUQ      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If !Empty(aCols[nCnt][nPAcao])
	DbSelectarea("SUQ")
	DbSetorder(1)
	If !DbSeek( xFilial("SUQ")+aCols[nCnt][nPAcao])
		Help(" ",1,"ACAO")
	Endif
	aCols[nCnt][nPDescAca] := SUQ->UQ_DESC
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣alida se o responsavel pela acao esta no PSS       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120Bar  � Autor � Marcelo Kotaki        � Data �02/09/02  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Mostra a EnchoiceBar na tela 							  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso 	 � Tmka120					 						     	  낢�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                      	  볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튗anna C.  |30/03/07|9.12  쿍ops 118469 - Alterado o nome dos Bitmaps   낢�
굇�        	 �        |      쿭efinidos pela Engenharia para o Protheus 10낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function Tk120Bar(oDlg,nOpc,cNumCfg,nSaveSX8)

Local aButtons 	:= {}

If nOpc <> 3
	AAdd(aButtons,{ "EXCLUIR"    , {|| IIF(Tk120Exc(nOpc,oDlg),oDlg:End(),"")} 	, STR0012 }) //"Cancelar"
Endif	

AAdd(aButtons,{ "AFASTAMENTO", {|| Tk120VCan(.F.,nOpc,.F.)}, STR0014,STR0022 }) //"Motivo de Cancelamento" , "Cancelamento"
AAdd(aButtons,{ "PRODUTO"    , {|| Tk120ConCamp()}         , STR0019,STR0023 }) //"Informa뇯es da Campanha", "Script"
AAdd(aButtons,{ "DbG09"      , {|| Tk120Car()}        		, STR0015,STR0024 }) //"Caracteristicas"        , "Produto"
AAdd(aButtons,{ "RELATORIO"  , {|| TkConcorrente(1)}    	, STR0016,STR0025 }) //"Concorrentes"           , "Concorre"

EnchoiceBar(oDlg,{||IIf(Tk120Grava(cNumCfg,nOpc,nSaveSX8),oDlg:End(),"")},{||Tk120Fim(nOpc,nSaveSX8),oDlg:End()},,aButtons)

Return(.T.)


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120Exc  � Autor � Fabio Rogerio         � Data �03/03/00  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Valida a Exclus꼘 de um item do acols                 	  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso 	 � Sigatmk              						   		      낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �11/12/01�609   �-O usuario podia cancelar sem confirmar     낢�
굇�          �        �      �                                            낢�
굇�          �        �      �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120VCan � Autor � Fabio Rogerio         � Data �03/03/00  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Tela de Consulta do Motivo de cancelamento  				  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so 	     � Generico 						   	 	        		  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �11/12/01�609   �-O usuario podia cancelar sem confirmar     낢�
굇쿘arcelo K �03/09/02�710   �-Revisao da funcoa                          낢�
굇�          �        �      �                                            낢�
굇�          �        �      �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120Car  � Autor � Fabio Rogerio 		� Data � 03/03/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o 쿎arrega Caracteristicas									  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso   	 � Sigatmk      			 								  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function Tk120Car()

SET KEY VK_F9 to

TkProduto()

SET KEY VK_F9 to Tk120Car()    //Caracteristicas do Produto

Return(.T.)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120ConCamp()  � Autor � Fabio Rogerio         � Data � 03/03/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o 쿎onsulta a estrutura do script din긩ico da campanha               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so 	     쿟MKA120         		 									        낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
	// Compatibiliza놹o com a fun놹o a230visual do programa TMKA230.PRW - Cadadastro de Campanhas
	Private cCadastro := STR0020 //"Visualiza뇙o da Campanha"
	Private aTELA[0][0],aGETS[0]
	
	// Pego o codigo da campanha
	cCodCamp := M->UE_CODCAMP
	
	DbSelectarea("SUO")
	DbSetorder(1)
	INCLUI := .F.
	If DbSeek(xFilial("SUO")+cCodCamp)
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Monta a entrada de dados do arquivo                          �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		bCampo := {|nCPO| Field(nCPO) }

		FWExecView( STR0019, "TMKA310", 1 )//"Informa寤es de Campanha" ## Visualizar
				
		DbSelectarea(cAlias)
		lRet := .T.
	Endif
Endif
	
Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컫컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿟k120Delete � Autor � Fabio Rogerio Pereira쿏ata � 06/05/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컨컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿏eleta todos os registros referentes a configuracao     	  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       쿟k310Dele                                                   낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �01/09/02�710   �-Revisao do fonte                           낢�
굇�          �        �      �                                            낢�
굇�          �        �      �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function Tk120Delete()
Local lRet := .F.

BEGIN TRANSACTION

	If TmkOK(STR0011) //"Confirma a exclus꼘 desta campanha ?"
	
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TK120DescUsu� Autor � Fabio Rogerio      � Data � 21/07/01 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Devolve o nome do usuario  selecionado para a ACAO         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � AP6 Call Center                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function Tk120DescUsu()

Local nPCodOpe := aPosicoes[9][2]
Local cNome    := ""
Local aUser	   := {}
	 
If !Empty(aCols[n,nPCodOpe])
	PswOrder(1)
	If PswSeek(aCols[n][nPCodOpe])
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿣erifica as informacoes do usuario�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		aUser:= PswRet(1)
	   
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Carrega o nome do usuario 	     �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		cNome := aUser[1][2]
	Endif
Endif

Return(cNome)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 쿟k120Grava� Autor � Fabio Rogerio         � Data � 28/10/03 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Grava as informacoes do orcamento com integridade.		  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso 	 � Tk120Grava									     		  낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �01/09/02�710   �-Revisao do fonte                           낢�
굇�          �        �      �                                            낢�
굇�          �        �      �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
	
	//旼컴컴컴컴컴컴�
	//쿒rava o memo.�
	//읕컴컴컴컴컴컴�
	MSMM(,TamSx3("UE_OBS")[1],,M->UE_OBS,1,,,"SUE","UE_CODOBS")
	MsUnlock()
	FKCommit()
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿞e for inclusao atualiza o controle de numeracao�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If nOpc == 3
		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		End	
	Endif
		
	DbSelectarea("SUF")	
	For nI := 1 To Len(aCols)
			
		//旼컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿞e a linha nao foi apagada�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟MKA120   � Autor 쿘arcelo Kotaki      � Data �  02/09/02   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒escricao 쿑inaliza a saida da tela de configuracao                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞IGATMK                                                     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴엽�
굇쿑un뇙o    쿟k120HabObj � Autor 쿗uis Marcelo Kotaki    � Data �23/08/00낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴눙�
굇쿏escri뇙o 쿓abilita ou Desabilita os Objetos da Tela      	          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿐xpL1 = .T. = Habilita .F. = Desabilita                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇튧so       쿌P6 - Call Center       	                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �09/09/02�710   �-Revisao do fonte                     	  낢�
굇�          �        �      �                                            낢�
굇�          �        �      �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function Tk120HabObj(lCancelada,oEnchoice,oGet)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿓abilita os objetos da tela�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lCancelada
	oGet:oBrowse:Disable()
Else
	oGet:oBrowse:Enable()
Endif

Return(.T.)

//----------------------------------------------------------------
/*/{Protheus.doc} Tk120Desc()
Fun豫o para realizar a inicializa豫o padr�o da descri豫o do assunto
@author Servi�os
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