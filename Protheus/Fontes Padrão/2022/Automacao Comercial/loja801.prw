#INCLUDE "PROTHEUS.CH"                                              
#INCLUDE "APWIZARD.CH" 
#INCLUDE "LOJA801.CH"

Static oCodPro 					   												// Codigo do Produto
Static cCodPro 			:= CriaVar("B1_COD",.F.)								// Codigo do Produto 
Static cNomePro			:= CriaVar("B1_DESC",.F.)								// Nome do Produto
Static oNomePro		   															// Nome do Produto 
Static cAliasTRB		:="TRB"                                              
Static cMarca  			:= GetMark()  
Static nQtdeVend        :=0 
Static oChkData         														//permite altera��o de data
Static lChkData	    														    // permite alteracao da data
Static oAtencao
Static cAtencao 
Static aProdCad 											 					//Array contendo os produtos j� cadastrados
Static oDlg             														// Tela dos produtos j� cadastrados
Static oMark                                                                   
Static oWizard
Static oDBTree

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao	 �LOJA801   � Autor � Vendas Cliente        � Data � 08.11.10  ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Rotina que efetua atraves do wizard a sugestao de vendas    ���
���          �                                                             ���
���          �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � SIGALOJA - VENDA ASSISTIDA                                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function LOJA801()  

//������������������������������Ŀ
//�Declaracao de variaveis locais�
//��������������������������������
Local nTpProc		:= 1      													// Opcao selecionada. 1-Produto especifico 2-Quantidade vendida
Local aGrid 		:= {}       												// Campos da tabela SL2 que serao exibidos na MsSelect                                                  
//�����������������������Ŀ
//�Declaracao dos Objetos �
//�������������������������

Local cSugestao 	:=CriaVar("ACU_DESC",.F.)   								// Nome da Sugestao da Venda
Local dDataIni		:= dDataBase										        // Data Inicial para filtrar as vendas efetuadas         
Local dDataFim		:= dDataBase										        // Data Final para filtrar as vendas efetuadas  
Local oDataIniP		:= NIL															// Data Inicial para filtro do produto espec�fico
Local oDataFimP     := NIL   											           	// Data Final para filtro do produto espec�fico
Local aStruTRB 		:={}                                                        // array de estrutura dos arquivos temporarios
Local aNomeTMP		:= {}                                                      //  Array tamporario
Local lQtdeVen		:=.F.														//verifica se o grid esta em quantuidade vendida   
Local nTpSubCat		:= 0	  						                                //Verifica se havera sub categoria       

If !LJ801aVlUs()
	Return(Nil)  
EndIf         

Lj801aGetS(@aGrid,@aStruTRB,@aNomeTMP)   

/*
�������������������������������������������������������������������Ŀ
� Montagem dos paineis do WIZARD , cada funcao representa um painel |
���������������������������������������������������������������������
*/
Lja801P1() 
/*
�����������������������������Ŀ
� Montagem do segundo painel  |
�������������������������������
*/
Lja801P2(@nTpProc,@oDataIniP,@oDataFimP)
/*
�����������������������������Ŀ
� Montagem do Terceiro painel |                   
�������������������������������
*/
Lja801P3(@nTpProc ,@lQtdeVen,@dDataIni,@dDataFim,@oDataIniP,@oDataFimP)
/*
�����������������������������Ŀ
� Montagem do Quarto painel   |
�������������������������������
*/
Lja801P4(@nTpProc,@lQtdeVen)   
/*
�����������������������������Ŀ
� Montagem do Quinto painel   |
�������������������������������
*/
Lja801P5(@nTpProc,@oDataIniP,@oDataFimP,@lQtdeVen,@aGrid)
/*
�����������������������������Ŀ
� Montagem do Sexto painel    |
�������������������������������
*/
Lja801P6(@nTpSubCat)   
/*
�����������������������������Ŀ
� Montagem do Setimo painel   |
�������������������������������
*/
Lja801P7(@nTpSubCat,@cSugestao)
/*
�����������������������������Ŀ
� Montagem do Oitavo painel   |
�������������������������������
*/
Lja801P8(@nTpProc,@aGrid,@cCodPro)
/*
�����������������������������Ŀ
� Montagem do Nono painel     |
�������������������������������
*/
Lja801P9(@nTpProc) 
/*
�����������������������������Ŀ
� Montagem do Decimo painel   |
�������������������������������
*/
Lja801P10()
                        
Return(Nil)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P1	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao e primeiro painel do Wizard                      ���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P1()
	//�������Ŀ
	//�Panel 1�
	//���������           
	
	DEFINE WIZARD oWizard TITLE OemToAnsi(STR0001) HEADER OemToAnsi(STR0002) MESSAGE " " ;      //Assistente de sugest�o de Venda
	TEXT OemToAnsi(STR0003)+OemToAnsi(STR0004) PANEL NEXT {|| .T.} FINISH {|| .F.}	//Processo de sugest�o de Vendas do Sistema loja
	/*Este assistente ira ajuda-lo a relacionar produtos que normalmente s�o vendidos em conjunto (Sugest�o de Vendas)."
	 Clique em avancar para iniciar o assistente"*/

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P2	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Segundo Painel do Wizard, nesse painel o usuario seleciona ���
���          �o tipo de  consulta que ira fazer, se eh por 1-produto      ���
���          �especifico ou por 2-quantidade vendida, indicados pela      ���
���          �variavel nTpProc                                            ���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpProc: Tipo escolhido                                    ���
���				       [1] Produto especifico                             ���
���          �         [2] quantidade vendida                             ���
���          � oDataIniP: Objeto Data inicial                             ���
���          � oDataFimP: Objeto Data Final                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P2(nTpProc,oDataIniP,oDataFimP)
//Os objetos de data inicial e data final foram incluidos nessa funcao pois eles serao habilitados ou desabilitados
// de acordo com a opcao selecionada
Local   oTpProc			:= NIL						//objeto tipo do processo 1 prod especifico 2 quantidade vendida
Default oWizard 		:= NIL                     // objeto Wizard
Default nTpProc 		:= 0                       // variavel de tipo de processo
Default oDataIniP 		:= Nil                    //  objeto de pesquisa para data inicial
Default oDataFimP 		:= Nil                    //  objeto de pesquisa para data final

	/*Selecao do processo"
	 Deseja relacionar os produtos por qual crit�rio? */ 
	CREATE PANEL oWizard  HEADER STR0005  MESSAGE OemToAnsi(STR0006) ;
	BACK {|| .T. } ;
	NEXT {||  Lj801aNe2(@nTpProc,1,@oCodPro,@oDataIniP,@oDataFimP)} ;	
	FINISH {||  .F. } PANEL 
	@ 001,01 TO 139,300 
	@ 01,01  TO 139,300 LABEL STR0004		OF oWizard:GetPanel(2) PIXEL //Clique em avancar para iniciar o assistente
	@ 20,20 RADIO oTpProc  		VAR nTpProc ITEMS STR0008,STR0007  	SIZE 70,10 PIXEL OF oWizard:GetPanel(2) ;       
	   
Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P3	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Terceiro Painel do Wizard, nesse painel o usuario seleciona���
���          �o produto que deseja consultar, a data inicial e final e    ���
���          �porcentagem inicial e final, sendo que eh necessario informar��
���          �o produto e data inicial e final, com isso sera executada a ���
���          �funcao Lj801aNe3  que efetuara filtro e exibira os produtos ���
���          �no grid do painel 5 - cinco                                 ���
���          �a variavel lQtdeVen representa que sera por produto especif.���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpProc: Tipo escolhido                                    ���
���				       [1] Produto especifico                             ���
���          �         [2] quantidade vendida                             ���
���          � oDataIniP: Objeto Data inicial                             ���
���          � oDataFimP: Objeto Data Final                               ���
���          � dDataIniP:        Data inicial                             ���
���          � dDataFimP:        Data Final                               ���
���          � lQtdeVen: qtde vendida = .F. , Prod. Especifico :T         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P3(nTpProc,	lQtdeVen,	dDataIni,	dDataFim,;
                            oDataIniP,	oDataFimP)        
                            
Local nPerceIni	   		:= 0												//Percentual inicial
Local oPerceIni         := NIL												//Objeto Percentual inicial
Local nPerceFim			:= 0												//Percentual Final
Local oPerceFim         := NIL												//Objeto Percentual Final
Default oWizard 		:= Nil
Default nTpProc 		:=0
Default lQtdeVen 		:=.F.
Default dDataIni 		:=dDataBase
Default dDataFim 		:=dDataBase
Default oDataIniP 		:=Nil   
Default oDataFimP 		:=Nil    
Default cCodPro     	:=""  

	/*Selecao do processo
	Nesse painel iremos informar o produto que ser� pesquisado, intervalo de Data e/ou porcentagem, lembrando que a porcentagem diz 
	respeito a quantidade vendida	*/
	CREATE PANEL oWizard HEADER OemToAnsi(STR0005) MESSAGE OemToAnsi(STR0041+CHR(10)+CHR(13)+(STR0039));
	 PANEL BACK {|| Lj801aNe3(@nTpProc  ,2, @cCodPro, dDataINI,dDataFIM,nPerceIni,nPerceFim )};
	 NEXT   {|| Lj801aNe3(@nTpProc  ,1, @cCodPro, dDataINI,dDataFIM,nPerceIni,nPerceFim ,@lQtdeVen)};
                FINISH {|| .F.} PANEL

	oWizard:GetPanel(3)

	@ 01,01 TO 139,300 LABEL 	OF oWizard:GetPanel(3) PIXEL
	@ 10,8 TO 40,292 LABEL STR0010	OF oWizard:GetPanel(3) PIXEL //"Informa��es sobre o Produto
	@ 22,16  SAY  STR0011     		   	OF oWizard:GetPanel(3) PIXEL SIZE 50,9 //"Produto:"
	@ 20,50  MSGET 	oCodPro  	VAR cCodPro  	SIZE 40,10 	Picture "@!" F3 "SB1" 	OF  oWizard:GetPanel(3) ;
	         VALID (If(!EMPTY(cCodPro), cNomePro:=Lj801aDescP(cCodPro),oNomePro:Refresh())) ;
	         PIXEL
	@ 20,110 SAY 	oNomePro 	Var cNomePro 	OF oWizard:GetPanel(3) COLOR CLR_RED PIXEL SIZE 210,9
	@ 40,8   TO 100,148 LABEL STR0015	OF oWizard:GetPanel(3) PIXEL //"Intervalo de Datas :       
	@ 40,152   TO 100,292 LABEL STR0009	OF oWizard:GetPanel(3) PIXEL //"Porcentagem : 
	@ 53,30  SAY  STR0012 		OF oWizard:GetPanel(3) 	SIZE 50,9 PIXEL //"Data Inicial
	@ 50,65  MSGET oDataIniP 	VAR dDataIni   			SIZE 50,10 	OF  oWizard:GetPanel(3) VALID( If(nTpProc == 1,!EMPTY(dDataIni),.T.) , IIf(!Empty(dDataFim),dDataFim >= dDataIni,.T.)) PIXEL 
	@ 73,30 SAY  STR0013 		OF oWizard:GetPanel(3) 	SIZE 50,9 PIXEL //"Data Final
	@ 70,65 MSGET	oDataFimP  	VAR dDataFim   			SIZE 50,10 	OF  oWizard:GetPanel(3) VALID( If(nTpProc == 1,!EMPTY(dDataFim),.T.) ,  dDataFim >= dDataIni) PIXEL
	@ 53,155  SAY  STR0036  		OF oWizard:GetPanel(3) 	SIZE 50,15 PIXEL //Porcentagem inicial
	@ 52,210  MSGET	oPerceIni  	VAR nPerceIni   			SIZE 40,10 Picture "@E 99.99"	OF  oWizard:GetPanel(3) VALID( If(nTpProc == 1,!EMPTY(nPerceIni),.T.)) PIXEL
	@ 73,155  SAY  STR0037  		OF oWizard:GetPanel(3) 	SIZE 50,15 PIXEL //Porcentagem final
	@ 72,210  MSGET	oPerceFim  	VAR nPerceFim   			SIZE 40,10 Picture "@R 999.99" OF  oWizard:GetPanel(3) VALID( LjVldPorc(nTpProc,nPerceFim) ) PIXEL

	lChkData := .F.
	oChkData := TCheckBox():New(88,100,"Alterar Data",,oWizard:GetPanel(3), 150,400,,,,,,,,.T.,,,)
	oChkData:Disable()
	oChkData:Refresh()	
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P4	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quarto Painel do Wizard, nesse painel o usuario seleciona  ���
���          �a data inicial e data final alem da quantidade vendida inici���
���          �al com o intuido de buscar na base de dados todos os produtos��
���          �que satisfizerem as condicoes da consulta, sera executada a ���
���          �funcao Lj801aNe4 que efetuara filtro e exibira os produtos  ���
���          �no grid do painel 5 - cinco                                 ���
���          �a variavel lQtdeVen representa que sera por qtade vendida   ���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpProc: Tipo escolhido                                    ���
���				       [1] Produto especifico                             ���
���          �         [2] quantidade vendida                             ���
���          � lQtdeVen: qtde vendida = .F. , Prod. Especifico :T         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P4(nTpProc,lQtdeVen)

Local cQuantIni			:=CriaVar("B1_COD",.F.)                             //Quantidade Inicial
Local oQuantIni			:= NIL													//Quantidade Inicial
Local cQuantFim			:=CriaVar("B1_COD",.F.)    							//Quantidade Final
Local oQuantFim 		:= NIL													//Quantidade Final    
Local oDataIni			:= NIL											    	// Data Inicial para filtro da quantidade vendida
Local oDataFim        	:= NIL										           	// Data Final para filtro das Notas Fiscais de Saida
Local dDataIni			:= dDataBase									    // Data Inicial para filtrar as vendas efetuadas         
Local dDataFim			:= dDataBase									    // Data Final para filtrar as vendas efetuadas  
Default oWizard 		:= Nil
Default nTpProc 		:=0
Default lQtdeVen 		:=.F.

	CREATE PANEL oWizard HEADER OemToAnsi(STR0005) MESSAGE "";   //Sele��o do processo
	PANEL BACK {||  Lj801aNe4( nTpProc,2 ,dDataINI,dDataFIM  ,cQuantIni, cQuantFim,@lQtdeVen)};
	NEXT {||  Lj801aNe4( nTpProc,1 ,dDataINI,dDataFIM  ,cQuantIni, cQuantFim,@lQtdeVen)} ;	
    FINISH {|| .F.} 
   	@ 40,8   TO 100,148 LABEL STR0015 	OF oWizard:GetPanel(4) PIXEL //"Data       
	@ 40,152   TO 100,292 LABEL STR0047	OF oWizard:GetPanel(4) PIXEL //Quantidade Vendida
	
	@ 53,30  SAY  STR0012 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL //"Data Inicial
	@ 50,64  MSGET oDataIni 	VAR dDataIni   			SIZE 50,10 	OF  oWizard:GetPanel(4) VALID( If(nTpProc == 1,!EMPTY(dDataIni),.T.) , IIf(!Empty(dDataFim),dDataFim >= dDataIni,.T.)) PIXEL 
	@ 73,30 SAY  STR0013 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL //"Data Final 
	@ 70,64 MSGET	oDataFim  	VAR dDataFim   			SIZE 50,10 	OF  oWizard:GetPanel(4) VALID( If(nTpProc == 1,!EMPTY(dDataFim),.T.) ,  dDataFim >= dDataIni) PIXEL 	 
 	@ 53,180  SAY  STR0022 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL // Quantidade vendida de 
	@ 50,210  MSGET oQuantIni 	VAR cQuantIni   			SIZE 40,10 Picture "@E 999999999"	OF  oWizard:GetPanel(4)  PIXEL 				
	@ 73,180  SAY  STR0023 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL //ate
	@ 70,210  MSGET	oQuantFim 	VAR cQuantFim   			SIZE 40,10 Picture "@E 999999999"	OF  oWizard:GetPanel(4)  PIXEL 		

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P5	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quinto Painel do Wizard, nesse painel sera exibido o grid  ���
���          �com as informacoes passadas pelo painel 3 ( prod especifico)���
���          �ou 4 ( quantidade vendida ) caso seja painel 3 sera efetuada|��
���          �validacao de escolha de pelo menos um item do grid, se for  ���
���          �pelo painel 4, sera possivel apenas a escolha de UM produto ���
���          �pois sera retornado ao painel 3 com o produto selecionado no|��
���          �grid para uma nova busca na base com o produto sel no grid  ���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpProc: Tipo escolhido                                    ���
���				       [1] Produto especifico                             ���
���          �         [2] quantidade vendida                             ���
���          � oDataIniP: Objeto Data inicial                             ���
���          � oDataFimP: Objeto Data Final                               ���
���          � lQtdeVen: qtde vendida = .F. , Prod. Especifico :T         ���
���          � aGrid   : Grid dos produtos encontrados                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P5(nTpProc,oDataIniP,oDataFimP,lQtdeVen,;
				  aGrid)
Default oWizard 	:= Nil
Default nTpProc 	:= 0
Default lQtdeVen 	:= .F.
Default oDataIniP 	:= Nil   
Default oDataFimP 	:= Nil
Default aGrid 		:= {}

// caso seja quantidade vendida, apos selecionar apenas um produto a rotina voltara para o
// painel 3 , com o codigo do produto e as datas desabilitadas 

		//Neste painel s�o exibidos os produtos que foram vendidos no per�odo selecionado, juntamente com o produto escolhido anteriormente."
	CREATE PANEL oWizard  HEADER STR0001  MESSAGE OemToAnsi(STR0014+CHR(10)+CHR(13)+(STR0038)) ; 
	BACK {|| Lj801aNe5(nTpProc   ,2) }; 
	NEXT {|| Lj801aNe5(@nTpProc   ,1,@cCodPro,@oCodPro,@cNomePro,@oNomePro,@oDataIniP,@oDataFimP,lQtdeVen)} ;							
	FINISH {|| .F.} PANEL 

	oWizard:GetPanel(5)

	@ 03,02 SAY ""  OF oWizard:GetPanel(5) SIZE 120,8 PIXEL 
  	@ 10,10 SAY STR0018	OF oWizard:GetPanel(5) PIXEL SIZE 801,801  //Selecione o produto para relacionar na sugest�o de vendas
	@ 125,30  SAY 	oAtencao 	Var cAtencao 	OF oWizard:GetPanel(5) 	SIZE 200,9 PIXEL //"Data Inicial        
	
    
    oMark := MsSelect():New(cAliasTRB,"L2_OK",,aGrid,.F.,@cMarca,{05,02,115,300},"SD2->(DbGotop())","SD2->(DbGoBottom())",oWizard:GetPanel(5))
	oMark:oBrowse:lhasMark    := .T.
	oMark:oBrowse:lCanAllmark := .F.
    
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P6	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Sexto Painel do Wizard, nesse painel o usuario ira decidir ���
���          �se o produto selecionado inicialmente vai ser ou nao "pai"  ���
���          �do(s) produto(s) escolhidos posteriormente                  ���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpSubCat: Se o produto sera pai ou nao                    ���
���				       [1] Sim                                            ���
���          �         [2] nao                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P6(nTpSubCat)
Local oTpSubCat		:= NIL							//Verifica se havera sub categoria
Default oWizard 	:= NIL                          //Objeto do wizard

Default nTpSubCat 	:=0
		/*Selecao do processo"
	 Definir o produto selecionado como produto 'Pai'?"*/ 
	CREATE PANEL oWizard  HEADER STR0055 MESSAGE OemtoAnsi (STR0056+CHR(10)+CHR(13)+(STR0040)) ;
	BACK {|| .T. } ;
	NEXT {|| .T.} ;	
	FINISH {||  .F. } PANEL          
	@ 001,01 TO 139,300 LABEL STR0050 OF oWizard:GetPanel(6) PIXEL 
	@ 01,01  TO 139,300 LABEL	      OF oWizard:GetPanel(6) PIXEL 
	@ 20,20 RADIO oTpSubCat  		VAR nTpSubCat ITEMS STR0026,STR0027  	SIZE 70,10 PIXEL OF oWizard:GetPanel(6) ;    

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P7	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Setimo Painel do Wizard, nesse painel o usuario ira digitar���
���          �o nome da categoria que sera cadastrada apos selecao dos prod��
���          �dutos, o parametro nTpSubCat determina se o produto sera pai���
���          �ou nao dos produtos selecionados no grid                    ���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpSubCat: Se o produto sera pai ou nao                    ���
���				       [1] Sim                                            ���
���          �         [2] nao                                            ���
���          � cSugestao: Nome da sugestao que sera cadastrada            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P7(nTpSubCat,cSugestao)
Local oSugestao		:= NIL														//Nome da Sugestao da Venda    
Default oWizard 	:= Nil
Default nTpSubCat 	:=0
Default cSugestao 	:=""

		//Finaliza��o de Processo"
        //Informe o nome da Sugest�o de vendas que acabou de criar.
	CREATE PANEL oWizard  HEADER STR0057  MESSAGE OemToAnsi(STR0032) ; 
	BACK {||  , .T. }; 
	NEXT {|| Lj801aNe7( 1,cSugestao,nTpSubCat)} ;							
	FINISH {|| .F.} PANEL
	
	@ 001,01 TO 139,300 LABEL 		OF oWizard:GetPanel(7) PIXEL 
   	@ 30,16  SAY  STR0058     		    	OF oWizard:GetPanel(7) PIXEL SIZE 200,80 //"Nome da Sugest�o:
	@ 40,16  MSGET	oSugestao  	VAR cSugestao   SIZE 80,10 	Picture "@!" 	OF  oWizard:GetPanel(7)  PIXEL 				

	oWizard:GetPanel(7) 
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P8	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Oitavo Painel do Wizard, esse painel eh parecido com o     ���
���          �painel 5, ele eh acionado quando o usuario seleciona um     |��
���          �produto que ja tem sugestao cadastrada, que alem de ter o   ���
���          �grid como o painel 5 tem o botao detalhes que exibe todos os���
���          �produtos que estao associados a essa sugestao, com isso depois�
���          �de selecionar um produto, sera verificado se na sugestao cadas�
���          �trada existe um produto pai, caso nao exista, sera acrescenta��
���          �do o novo produto, caso tenha, sera envidado ao proximo painel�
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpProc: Tipo escolhido                                    ���
���			 |	       [1] Produto especifico                             ���
���          �         [2] quantidade vendida                             ���
���          | oDBTree: Objeto de Exibicao em forma hierarquica "arvore"  ���
���          � aGrid   : Grid dos produtos encontrados                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P8(nTpProc,aGrid,cCodPro)
Local oButton  := NIL                               // Objeto para Botao
Local cCateg := AllTrim(LJ801aRetC(cCodPro))// Retorna a categoria do respectivo produto 
Default oWizard 	:= Nil
Default nTpProc 	:=0
Default aGrid 		:={}
  
	//Neste painel s�o exibidos os produtos que foram vendidos no per�odo selecionado, juntamente com o produto escolhido no painel anterior"
	CREATE PANEL oWizard  HEADER STR0001  MESSAGE OemToAnsi(STR0014+CHR(10)+CHR(13)+(STR0038)) ; 
	BACK {|| Lj801aNe3(@nTpProc  ,2,@cCodPro)};
	NEXT {|| Lj801aNe8(@nTpProc  ,1,@cCodPro)} ;
	FINISH {|| .F.} PANEL 

	oWizard:GetPanel(8)
	@ 03,02 SAY ""  OF oWizard:GetPanel(8) SIZE 120,8 PIXEL 
  	@ 10,10 SAY ""	OF oWizard:GetPanel(8) PIXEL SIZE 801,801  // Selecione o produto para relacionar na sugest�o de vendas
	@ 125,30  SAY 	oAtencao 	Var cAtencao 	OF oWizard:GetPanel(8) 	SIZE 200,9 PIXEL //"Data Inicial

	aAdd(aGrid,{"L2_PORCENT"	,,STR0009," "})							 	//Porcentagem
	oMark := MsSelect():New(cAliasTRB,"L2_OK",,aGrid,.F.,@cMarca,{05,02,115,300},"SD2->(DbGotop())","SD2->(DbGoBottom())",oWizard:GetPanel(8))
	oMark:oBrowse:lhasMark    := .T.
	oMark:oBrowse:lCanAllmark := .F.

		oButton:=tButton():New(120,260,STR0045,oWizard:GetPanel(8),{||oWizard:GetPanel(8):End()},30,12,,,,.T.)  //Detalhes
		oButton:bAction := {|| Ljc801ExGr()}       
     
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P9	� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Nono  Painel do Wizard, esse painel exibe um DbTree com a  ���
���          �estrutura da sugestao ja existente, perguntando ao usuario  |��
���          �em que hierarquia deseja inserir o produto selecionado, se  ���
���          �eh na mesma estrutura do produto pai ou na sub sugestao dos ���
���          �produtos filhos, a resposta sera obtida pelo retorno da     ���
���          �funcao GetCargo() do DbTree. No DbTree serao exibidas tanto as�
���          �sugestoes como o produtos que fazem parte delas             |��
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
���          � nTpProc: Tipo escolhido                                    ���
���			 |	       [1] Produto especifico                             ���
���          �         [2] quantidade vendida                             ���
���          | oDBTree: Objeto de Exibicao em forma hierarquica "arvore"  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P9(nTpProc) 
Default oWizard 	:= Nil
Default nTpProc 	:=0

	//Neste painel s�o exibidos os produtos que foram vendidos no per�odo selecionado, juntamente com o produto escolhido no painel anterior"
	CREATE PANEL oWizard  HEADER STR0001  MESSAGE OemToAnsi(STR0053) ; //Selecione em qual categoria o produto selecionado no grid deve ser inserido
	BACK {|| Lj801aNe8(nTpProc  ,2,@cCodPro)};
	NEXT {|| Lj801aNe9(nTpProc ,3,,oDBTree:GetCargo())} ;										
	FINISH {|| .F.} PANEL 
	oWizard:GetPanel(9)
	@ 03,02 SAY ""  OF oWizard:GetPanel(9) SIZE 120,8 PIXEL 
  	@ 10,10 SAY ""	OF oWizard:GetPanel(9) PIXEL SIZE 801,801  
	@ 125,30  SAY 	oAtencao 	Var cAtencao 	OF oWizard:GetPanel(9) 	SIZE 200,9 PIXEL   

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801P10 |Autor  � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Decimo Painel do Wizard, indica a finalizacao do wizard    ���
���          �estrutura da sugestao ja existente, perguntando ao usuario  |��
���          �em que hierarquia deseja inserir o produto selecionado, se  ���
���          �eh na mesma estrutura do produto pai ou na sub sugestao dos ���
���          �produtos filhos, a resposta sera obtida pelo retorno da     ���
���          �funcao GetCargo() do DbTree. No DbTree serao exibidas tanto as�
���          �sugestoes como o produtos que fazem parte delas             |��
�������������������������������������������������������������������������Ĵ�� 
���Parametros� oWizard: Objeto do Wizard                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lja801P10()
Default oWizard 	:= Nil 

	CREATE PANEL oWizard HEADER STR0025 MESSAGE OemToAnsi(STR0059) ; 
	BACK {|| .F. } ; 
	NEXT {||  .F. } ;	 
	FINISH {|| .T.} PANEL
     	@ 45,16  SAY  STR0024 		OF oWizard:GetPanel(10) 	SIZE 150,60 PIXEL //"	Os produtos foram gravados com sucesso
	ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.} VALID {||.T.}

Return
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801ExCa� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibte a categoria selecionada ao clicar no dbtree         ���
�������������������������������������������������������������������������Ĵ�� 
���Parametros� cCargo: String retornada ao clicar no dbtree               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/         
Function Lja801ExCa(cCargo)  
Local cArea := "LJVC" 	//Alias temporario                
                        
cQuery:= "SELECT  ACU_DESC, ACU_CODPAI, ACU_COD FROM " +   RetSQLName("ACU") + " WHERE  D_E_L_E_T_ = ' '  AND ACU_COD IN( "
cQuery+= "SELECT ACV_CATEGO FROM "+   RetSQLName("ACV") + " WHERE ACV_CATEGO = '" + cCargo + "' AND D_E_L_E_T_ = ' ' )"
LJa801ExQu(cArea,@cQuery)
cCondPai := AllTrim((cArea)->ACU_DESC)     
cCodProP := Alltrim((cArea)->ACU_COD)
cDescP   := Alltrim((cArea)->ACU_DESC)

If cCondPai <> '' 
	cAtencao := STR0051 + cCodProp + " - " + cDescP //"A categoria seleccionada e : "
Else
	cAtencao:=""
EndIf
oAtencao:Refresh()

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Ljc801ExGr� Autor � Vendas Cliente        � Data �08.11.10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exbibe grid de produtos que ja foram relacionados ao produto��
���          � selecionado no painel 3                                     ��
�������������������������������������������������������������������������Ĵ�� 
���Parametros� cProduto: Produto necessario para desc sugestao de Vendas  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ljc801ExGr(cProduto) 
Local oOK 	:= LoadBitmap(GetResources(),'br_verde')  //Botao verde somente para exibicao

DEFINE MSDIALOG oDlg FROM 0,0 TO 310,402 PIXEL TITLE STR0046      //Produtos Relacionados 

oBrowse := TWBrowse():New( 5 , 5, 195,  130,,;
		{'',STR0028,STR0029},{20,40,40}, oDlg, ,,,,;
		{||},,,,,,,.F.,,.T.,,.F.,,, )
  
oBrowse:SetArray(aProdCad)    
oBrowse:bLine := {||{;
If(aProdCad[oBrowse:nAt,01],oOK,oOK),;
	aProdCad[oBrowse:nAt,02],;
	aProdCad[oBrowse:nAt,03]} }

ACTIVATE MSDIALOG oDlg CENTERED
oDlg:=Nil
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lja801Desc� Autor � Vendas Cliente        � Data �27/10/10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descricao da categoria em que o produto passado  ���
���          � como parametro eh pai                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProd: Produto selecionado                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LJa801Desc(cProd)
Local cCateg	:=""		//variavel de retorno     
Local cQuery	:=""       // Variavel de consulta
Local cArea 	:="LJVC" 	//Alias temporario

cQuery:= "SELECT  ACU_DESC FROM " +   RetSQLName("ACU") + " WHERE  D_E_L_E_T_ = ' '  AND ACU_COD IN( "
cQuery+= "SELECT ACV_CATEGO FROM "+   RetSQLName("ACV") + " WHERE ACV_CODPRO = '" + cProd + "' AND D_E_L_E_T_ = ' ')"
LJa801ExQu(cArea,@cQuery)
cCateg := AllTrim((cArea)->ACU_DESC)
(cArea)->(DbCloseArea())

Return cCateg
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |LJa801ExQu� Autor � Vendas Cliente        � Data �27/110/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que executa querys                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cArea   : Arquivo temporario                               ���
���          � cQuery  : Query que vai ser executada                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LJa801ExQu(cArea,cQuery) 
Default cArea 	:="LJVC"
Default cQuery	:=""
If Select(cArea) > 0
	(cArea)->(DbCloseArea())
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cArea,.F.,.T.)

Return                                                                                 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |LJa801HDat� Autor � Vendas Cliente        � Data �27/10/10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Habilita ou desabilita as datas na sugest�o de vendas      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oDataini: Data inicial                                     ���
���          � oDataFim: Data final                                       ���
���          � lHabilita: Verifica se ir� habilitar ou desabilitar as datas��
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LJa801HDat(oDataini,oDataFim,lHabilita)
Default oDataini 	:=Nil	
Default oDataFim 	:=Nil   
Default  lHabilita 	:=.F. 
If lHabilita                            
	oDataini:Enable()
	oDataFim:Enable()
Else
	oDataini:Disable()
	oDataFim:Disable()
EndIf

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |LJa801GRAV� Autor � Vendas Cliente        � Data �22/10/10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Gravacao da sugestao de vendas                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet, .T. para gravado com sucesso                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodPro: Codigo do Produto                                 ���
���          � cSugestao : Nome da sugestao de Vendas que ser� cadastrada ���
���          � nTipo  : Deseja considerar o produto selecionado no painel ���
���          � 3 como produto pai ?                                       ���
���			 |	       [1] Sim                                            ���
���          �         [2] Nao                                            ��� 
���          � cCategoria : Caso seja inclusao de um produto a uma sugestao��
���          � existente, caso o array aProdCad tiver informacao indica que��
���          � sera inclusao de um prod. em uma categoria existente, caso |��
���          � contrario ser de um prod. em uma categoria existente, caso |��
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LJa801GRAV(cCodPro,cSugestao,nTipo,cCategoria)
Local lRet 			:= .T.       				//Variavel de Retorno
Local cCateg        := ""                           	//Categoria
Local cAlias 	    := cAliasTrb               // Alias temporario
Local lIntPOS 		:= (SuperGetMV("MV_LJSYNT",,"0") == "1")
Local lACV_POSFLG	:= ACV->(FieldPos("ACV_POSFLG")) > 0
Local lACU_POSFLG	:= ACU->(FieldPos("ACU_POSFLG")) > 0
Default	cCodPro 	:=""
Default cSugestao 	:=""
Default nTipo		:=0
Default cCategoria	:=""

//Caso n�o tenha informacoes no aProdCad sera inclusao caso contrario sera alteracao
If Len(aProdCad)==0       // Somente quando for inclusao de item que nao tem ja sugestao cadastrada esse array estara zerado
	//Inclusao
	DbSelectArea("ACU")
	cCateg := AllTrim(LJ801aRetC())       // Retorna a primeira categoria disponivel
	Reclock("ACU",.T.)
    
	REPLACE	ACU->ACU_FILIAL	WITH  xFilial("ACU")
	REPLACE	ACU->ACU_COD 	WITH cCateg
	REPLACE	ACU->ACU_DESC	WITH AllTrim(cSugestao)
	REPLACE	ACU->ACU_MSBLQL	WITH "2"
	If lIntPOS .AND. lACU_POSFLG
		REPLACE ACU->ACU_POSFLG WITH "1"
	EndIf
	ACU->(MsUnlock())
	
	Reclock("ACV",.T.)

	REPLACE	ACV->ACV_FILIAL		WITH  xFilial("ACU")
	REPLACE	ACV->ACV_CATEGO 	WITH  cCateg
	REPLACE	ACV->ACV_CODPRO		WITH  AllTrim(cCodPro)
	REPLACE	ACV->ACV_SUVEND		WITH  "1"
	If lIntPOS .AND. lACV_POSFLG
		REPLACE ACV->ACV_POSFLG WITH "1"
	EndIf
	ACV->(MsUnlock())

	If nTipo == 1    
		Reclock("ACU",.T.)        
	    
		REPLACE	ACU->ACU_FILIAL	WITH xFilial("ACU")
		REPLACE	ACU->ACU_CODPAI	WITH cCateg    
		cCateg := Soma1(cCateg)
		REPLACE	ACU->ACU_COD   	WITH AllTRIM(cCateg)
		REPLACE	ACU->ACU_DESC	WITH "Filho " +  AllTrim(cSugestao)
		REPLACE	ACU->ACU_MSBLQL	WITH "2" 
		If lIntPOS .AND. lACU_POSFLG
			REPLACE ACU->ACU_POSFLG WITH "1"
		EndIf
		ACU->(MsUnlock())
	EndIf	

Else
	// ALTERACAO
	cCateg := AllTrim(LJ801aRetC(cCodPro))// Retorna a categoria do respectivo produto
	
EndIf

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

While (cAlias)->( !Eof() )
   If !Empty(AllTrim((cAlias)->L2_OK))
		Reclock("ACV",.T.)
   		REPLACE	ACV->ACV_FILIAL		WITH xFilial("ACU")
   		REPLACE	ACV->ACV_CATEGO 	WITH AllTrim(cCateg)
		REPLACE	ACV->ACV_CODPRO		WITH (cAlias)->L2_PRODUTO
		REPLACE	ACV->ACV_SUVEND		WITH "1"
		If lIntPOS .AND. lACV_POSFLG
			REPLACE ACV->ACV_POSFLG WITH "1"
		EndIf
		ACV->(MsUnlock())
   EndIf
   (cAlias)->(DbSkip())
End

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Lj801aDescP �Autor  � Vendas Cliente     � Data �  26/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     � Devolve o nome do produto baseado no codigo que foi        ���
���          � digitado.                                                  ���
�������������������������������������������������������������������������͹��
���Parametros�cCodPro - Codigo do Produto                                 ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aDescP(cCodPro)
Local cDesc 		:= CRIAVAR("B1_DESC",.F.)                //Nome do Produto
Local aArea			:= GetArea()                             //Area atual para restaurar no final da funcao
Default cCodpro 	:=""                             			

If !Empty(cCodPro) 
	DbSelectArea("SB1")
	If SB1->(DbSeek(xFilial("SB1")+cCodPro))
		cDesc := SB1->B1_DESC
	Endif	
Endif

RestArea(aArea)

Return cDesc

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe2    �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao executada quando eh clicado no botao avancar do pai- ���
���          �nel 2 o parametro principal eh nTpProc que vai determinar   ���
���          �o proximo painel                                            ���
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � nTpProc: tipo processo 1 prod especifico 2 quant vendida   ���
���          � nAvanc: Verifica se est� avancando ou voltando             ���
���          � oCodPro: Codigo do produto                                 ���
���          � oDataIni: Data inicial                                     ���
���          � oDataFim: Data final                                       ���
�������������������������������������������������������������������������͹��
���Retorno   |  Retorna Verdadeiro caso efetuado com sucesso              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj801aNe2(nTpProc, nAvanc,oCodPro,oDataIni,;
                   oDataFim) 
Local lRet 			:= .T.     // Variavel de retorno
Default oWizard 	:=Nil
Default nTpProc 	:=0 
Default nAvanc 		:=0  
Default oCodPro 	:=Nil
Default oDataIni 	:=Nil   
Default oDataIni 	:=Nil		
If nAvanc  ==1
	If nTpProc ==1       // Produto especifico, habilita os campos de data para alteracao 
 		oWizard:SetPanel(2)
	   	oDataIni:Enable()
		oDataFim:Enable()
		oCodPro:Enable()
		oCodPro:Refresh()
		oDataIni:Refresh()
		oDataFim:Refresh()
		oChkData:bSetGet 	:= {|| .T. }
		oChkData:Disable()
		oChkData:Refresh()	
 	Else  //Quantidade vendida, pula um painel
     	oWizard:SetPanel(3)    		
    EndIf
EndIf

Return lRet 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe3    �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que retorna os os produtos de acordo com as informacoes�
���          �passadas no painel 3                                        ���
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � nTpProc: tipo processo 1 prod especifico 2 quant vendida   ���
���          � nAvanc: Verifica se est� avancando ou voltando             ���
���          � cCodProd: Codigo do produto                                ���
���          � dDataIni: Data inicial                                     ���
���          � dDataFIM: Data final                                       ���
���          � nPorceIni: Porcentagem inicial                             ���
���          � lQtdeVen : Indifica se eh qtde vendida ou prod. especifico ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aNe3(nTpProc	, nAvanc    ,  cCodProd,	dDataIni,;
                   dDataFIM , nPorceIni , nPorceFim,	lQtdeVen ) 
Local lRet 			:= .T.       //Variavel de retorno
Default oWizard 	:=Nil
Default nTpProc 	:=0 
Default nAvanc 		:=0
Default cCodProd 	:=""
Default dDataini 	:=""
Default dDataFIM	:=""
Default nPorceIni 	:=0
Default nPorceFim 	:=0
Default lQtdeVen	:=.T.
lQtdeVen:=.T.                

If nAvanc  ==1
	If Empty(cCodProd) 
		Alert(STR0016)//"O codigo do produto deve ser informado
		lRet:= .F.
	Else
 		DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
  	    If !SB1->(DbSeek(xFilial("SB1")+cCodProd))
	      //"O Produto nao existe
	      	Alert(STR0016)
	    	lRet  := .F.       
	    ElseIf Lj801cFilP(@cCodProd,DTOS(dDataIni),DTOS(dDataFIM),1, ,,nPorceIni, nPorceFim )  // efetua filtro de acordo com os dados informados
     	   	cAtencao := OemToAnsi(STR0028) + AllTrim(@cCodPro) + OemToAnsi(STR0042);// O produto x foi vendido y vezes no periodo
     	   	 +  AllTrim(STR(@nQtdeVend)) + OemToAnsi(STR0043)   
			oAtencao:Refresh()
			If Len(aProdCad)>0   // Caso esse array tenha informa��es indica que ja existe sugestao de vendas para esse produto, ou seja, sera atleracao
			  	MsgAlert(STR0044)//Este produto j� tem sugest�o de vendas relacionada, para mais informar��es pressione o bot�o Detalhes "
				oWizard:SetPanel(7)
			Else
			 	oWizard:SetPanel(4)
			EndIf
		Else
			MsgAlert(STR0030) //N�o foi encontrado nenhum produto com a sele��o informada!
			lRet := .F.
			oWizard:SetPanel(3)				   
   		EndIf
	Endif
Else
	oWizard:SetPanel(3)	

	
EndIf
Return lRet 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe4    �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Esse painel filtra os produtos de acordo com a quantidade   ���
���          �vendida                                                     ���
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � nTpProc: tipo processo 1 prod especifico 2 quant vendida   ���
���          � nAvanc: Verifica se est� avancando ou voltando             ���
���          � dDataIni: Data inicial                                     ���
���          � dDataFIM: Data final                                       ���
���          � nQuantIni: Quantidade inicial                              ���
���          � nQuantFin: Quantidade Final                                ���
���          � lQtdeVen : Indifica se eh qtde vendida ou prod. especifico ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aNe4( nTpProc  , nAvanc    ,dDataIni	,dDataFIM,;
                    nQuantIni, nQuantFin ,lQtdeVen ) 
Local lRet 			:= .T.   //Variavel de retorno
Default oWizard 	:=Nil
Default nTpProc 	:=0 
Default nAvanc 		:=0
Default dDataini 	:= dDataBase
Default dDataFIM	:= dDataBase
Default nQuantIni 	:=0
Default nQuantFin 	:=0
Default lQtdeVen	:=.F.
lQtdeVen:=.F.
If nAvanc  ==1
	If Empty(nQuantIni)  .OR.  Empty(nQuantFin) 
	 	MsgAlert(STR0017)		//Informe a quantidade vendida
		lRet := .F.
	ElseIf Lj801cFilP(cCodPro,DTOS(dDataIni),DTOS(dDataFIM),2,nQuantIni,nQuantFin)   // efetua o filtro por quantidade vendida
	    cAtencao:=""
	    oAtencao:Refresh()
	Else
		MsgAlert(STR0030)    //N�o foi encontrado nenhum produto com a sele��o informada!
		lRet := .F.
	EndIf   
Else
oWizard:SetPanel(3)  
  
EndIf
Return lRet 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe5    �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que valida se o produto do grid  foi selecionado ou nao�
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � nTpProc: tipo processo 1 prod especifico 2 quant vendida   ���
���          � nAvanc: Verifica se est� avancando ou voltando             ���
���          � cCodProd: Codigo do produto                                ���
���          � oCodPro:Objeto codigo do produto                           ���
���          � cNomePro: Nome do produto                                  ���
���          � oNomePro: Objeto nome do produto                           ���
���          � oDataIni: Objeto data inicial                              ���
���          � oDataFim: Objeto data Final                                ���
���          � cAliasTrb: Alias arquivo temporario                        ���
���          � lQtdeVen: Verifica se o grid ant. foi o qtde vendida       ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aNe5(nTpProc	 , 	nAvanc	 ,cCodPro ,oCodPro,;
                   cNomePro  ,	oNomePro ,oDataIni,oDataFim,;
                   lQtdeVen )                  
                   
Local lRet           := .F.    		//Variavel de retorno
Local lChkData    := .F.		//Define se o componente ochkData estara marcado ou nao 
Local nTipo          := 0           //Variavel de controle de Tipo
Default oWizard   :=Nil
Default nTpProc   :=0 
Default nAvanc     :=0
Default cCodPro   :=""
Default oCodPro   := Nil
Default cNomePro :=""
Default oNomePro := Nil
Default oDataIni     :=Nil
Default oDataFim   :=Nil
Default lQtdeVen   :=.T. 

Do Case
    Case nAvanc  ==1     				// Indica que veio do painel numero 3, e que vai validar se o usuario selecionou ou nao o produto do grid
    	If lQtdeVen
       		nTipo :=1	  
    	Else
       		nTipo :=2    		
    	EndIf
		If Lj801aSelPr(nTipo,@cCodPro) // valida se foi selecionado o produto
			If nTipo ==2       					// caso seja  por quantidade vendida ira desabilitar alguns campos
			  	cNomePro:=Lj801aDescP(cCodPro)
				oNomePro:Refresh()
				oDataIni:Disable()
				oDataFim:Disable()
				oCodPro:Disable()
				oCodPro:Refresh()
				oDataIni:Refresh()
				oDataFim:Refresh()
			  	oWizard:SetPanel(2)
				oChkData:Enable()
				oChkData:bSetGet 	:= {|| lChkData }
				oChkData:bLClicked	:= {|| lChkData:=!lChkData,LJa801HDat(oDataIni,oDataFim,lChkData) }
				oChkData:Refresh()                     
			Else                                                         
			
				oCodPro:Refresh()  
				// fazer novo painel
		
			EndIf
			lRet :=.T.
		EndIf
	Case nAvanc  ==2 //est� voltando e deve ir ao painel de selecionar por produto especifico ou quantidade vendida
		 oWizard:SetPanel(2)

Endcase

Return lRet 
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe7    �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida o nome da sugestao de vendas e chama funcao de gravacao�
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � nAvanc: Verifica se est� avancando ou voltando             ���
���          � cSugestao:Nome da sugestao de vendas que sera cadastrada   ���
���          � nTipoCateg: Verifica se vai usuar sub categoria ou nao     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aNe7(nAvanc,cSugestao,nTipoCateg ) 
Local lRet 			:= .T. 		//Variavel de Retorno

Default oWizard 	:=Nil
Default nAvanc 		:=0 
Default cSugestao 	:= ""
Default nTipoCateg 	:=0        

If nAvanc  ==1
	If Empty(cSugestao)
	 	MsgAlert(STR0031)		//Informe a Sugest�o
		lRet := .F.		
	ElseIf LJa801GRAV(cCodPro,cSugestao,nTipoCateg)  // Funcao de gravacao a sugestao de vendas
		oWizard:SetPanel(9)
	Else
		lRet := .F.			
	EndIf
EndIf

Return lRet

/*/                        
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe8    �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que valida se o produto do grid  foi selecionado ou nao�
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � nTpProc: tipo processo 1 prod especifico 2 quant vendida   ���
���          � nAvanc: Verifica se est� avancando ou voltando             ���
���          � cCodProd: Codigo do produto                                ���
���          � oDBTree: Objeto arvore                                     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aNe8(nTpProc, nAvanc,cCodPro)
Local cCateg := AllTrim(LJ801aRetC(cCodPro))// Retorna a categoria do respectivo produto 
Local lRet := .F.    		//Variavel de retorno 
Default oWizard	:=Nil
Default nTpProc		:=0
Default nAvanc		:=0
Default cCodPro		:=""

If nAvanc  ==1  //Caso seja inclusao de um produto em uma sugestao de vendas existente, sera considerado alteracao e ir� para o ultimo painel
	If Lj801aSelPr(nTpProc,@cCodPro)    
		If Lj801aSuCa(cCateg)
				cAtencao:=""
			    oAtencao:Refresh()
		Else
			If LJa801GRAV(cCodPro, , ,AllTrim(LJ801aRetC(cCodPro))) 
				oWizard:SetPanel(9)
			EndIf
	  	EndIf
	  	lRet :=.T.
	EndIf
Else  //Caso seja retorno ao Painel, exibe novamente Grid com os produtos que podem ser associados ao Principal
	Lj801aSelPr(nTpProc,@cCodPro)
  	oWizard:SetPanel(8)   	      	 
  	
	oDBTree:Reset()

	cAtencao := OemToAnsi(STR0028) + AllTrim(cCodPro) + OemToAnsi(STR0042);// O produto x foi vendido y vezes no periodo
     	   	 +  AllTrim(STR(@nQtdeVend)) + OemToAnsi(STR0043)   
	oAtencao:Refresh()
	
EndIf

Return lRet 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe9    �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a categoria foi selecionada                     ���
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � nTpProc: tipo processo 1 prod especifico 2 quant vendida   ���
���          � nAvanc: Verifica se est� avancando ou voltando             ���
���          � cCodProd: Codigo do produto                                ���
���          � cCateg: Sugestao  nao formatada                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aNe9(nTpProc, nAvanc,cCodPro,cCateg) 
Local lRet 				:=.F.		//Variavel de retorno
Local cQuery         := ""                //Variavel de consulta
Local cArea	        :="LJVC"    //variavel de Area temporaria para consulta           
Default oWizard		:=Nil
Default nTpProc		:=0
Default nAvanc		:=0
Default cCodPro		:=""       

cQuery := "SELECT V.ACV_CODPRO, U.ACU_CODPAI FROM "+ RetSqlName("ACU") +" U LEFT JOIN "+ RetSqlName("ACV") +" V "
cQuery += "ON V.ACV_CATEGO = U.ACU_COD WHERE U.ACU_COD = '"+ cCateg +"' AND V.ACV_SUVEND = '1' "
cQuery += "AND V.D_E_L_E_T_ = ' ' AND U.D_E_L_E_T_ = ' '"
LJa801ExQu(cArea,@cQuery)                        

cCodPro    := Alltrim((cArea)->ACV_CODPRO)    

If cAtencao = ''                                                                             
   	MsgAlert(STR0060)
Else 
  	lRet:=	LJa801GRAV(cCodPro,,,cCateg)
EndIf
                     
Return lRet 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aNe10   �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel por limpar todos os campos do wizard funcao eh  ���
���          �executada no ultimo painel                                  ���
�������������������������������������������������������������������������͹��
���Parametros� oWizard: Wizard atual                                      ���
���          � cCodProd: Codigo do produto                                ���
���          � oCodPro:Objeto codigo do produto                           ���
���          � oQtdeIni: Objeto Quantidade inicial                        ���
���          � oQtdeFim: Objeto Quantidade Final                          ���
���          � dDataIni: Data inicial                                     ���
���          � dDataFIM: Data final                                       ���
���          � nQtdeIni: Quantidade inicial                               ���
���          � nQtdeFim: Quantidade Final                                 ���
���          � cSugestao:Nome da sugestao de vendas que sera cadastrada   ���
���          � oSugestao:Objeto  sugestao de vendas que sera cadastrada   ��� 
���          � oDataIni: Objeto data inicial                              ���
���          � oDataFim: Objeto data Final                                ���
���          � nPercentIni:Nome da sugestao de vendas que sera cadastrada ���
���          � oPercentIni:Objeto  sugestao de vendas que sera cadastrada ��� 
���          � nPercentFim: Objeto data inicial                           ���
���          � oPercentFim: Objeto data Final                             ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aNe10() 
Local lRet := .T.        //Variavel de Retorno                                                                                                             

oWizard:SetPanel(1)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aSuCa   �Autor  � Vendas Cliente    � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o produto selecionado tem ou nao sub categorias ���
�������������������������������������������������������������������������͹��
���Parametros� cCateg: Categoria do produto                               ���
���          � oDBTree: Objeto de de exibicao das categorias em forma     ���
���          � hierarquica                                                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aSuCa(cCateg)  
Local cQuery        := ""				//Query que sera executada
Local lRet 			:=.F.			// variavel de retorno
Local cCat          := ""        		// Categoria que sera inserida no dbtree
Local cArea 		:= "LJVC"		// tabela temporaria
Local cBmp1 		:= "PMSEDT3"    // icone das categorias
Local cBmp2 		:= "PMSDOC"     // icone dos produtos
Default cCateg 		:=""                                                                                          

oDBTree := dbTree():New(10,10,95,300,oWizard:GetPanel(9),{||Lja801ExCa(oDBTree:GetCargo())},,.T.)	                     
oDBTree:PTRefresh()
  
cQuery:= "SELECT ACU_COD, ACU_DESC, ACU_CODPAI FROM "+ RetSqlName("ACU") + " WHERE ACU_CODPAI ='"+cCateg+"'  OR ACU_COD ='" +cCateg + "' "
cQuery+= " AND D_E_L_E_T_ = ' '"
LJa801ExQu(cArea,@cQuery)

While !(cArea) ->(EOF())
	cCat  := Alltrim((cArea)->ACU_COD) + " - " + (cArea)->ACU_DESC
   	If(AllTrim(cCateg)==AllTrim((cArea)->ACU_COD)) 
		oDBTree:AddTree(cCat ,.T.,cBmp1,cBmp1,,,(cArea)->ACU_COD)
		cQuery :=" SELECT DISTINCT C.ACV_CATEGO,C.ACV_CODPRO,P.B1_DESC FROM  "+ RetSqlName("ACV") + " C LEFT JOIN "+ RetSqlName("SB1") + " P "
		cQuery += "ON P.B1_COD = C.ACV_CODPRO WHERE C.ACV_CATEGO ='"+cCateg+"' "
		cQuery += "AND C.D_E_L_E_T_ = ' ' AND P.D_E_L_E_T_ = ' '"
		LJa801ExQu("LJPAI",@cQuery)

		While !LJPAI->(EOF())
			cCat:= AllTrim(LJPAI->ACV_CODPRO) + " - "+ (LJPAI->B1_DESC)
			oDBTree:AddItem(cCat,(LJPAI->ACV_CODPRO),cBmp2,,,2)
			LJPAI ->(DBSKIP())
		End
		LJPAI->(DbCloseArea())    
		
	Else
		oDBTree:AddTree(cCat ,.F.,cBmp1,cBmp1,,,(cArea)->ACU_COD)
		cQuery :=" SELECT DISTINCT C.ACV_CATEGO,C.ACV_CODPRO,P.B1_DESC FROM "+ RetSqlName("ACV") + " C LEFT JOIN "+ RetSqlName("SB1") + " P "
		cQuery += "ON P.B1_COD = C.ACV_CODPRO WHERE C.ACV_CATEGO ='"+(cArea)->ACU_COD+"' "  
		cQuery += "AND C.D_E_L_E_T_ = ' ' AND P.D_E_L_E_T_ = ' '"
		LJa801ExQu("LJPAI",@cQuery)                                                                                  
		
		While !LJPAI->(EOF())
			cCat:= Alltrim((LJPAI->ACV_CODPRO)) + " - "+ (LJPAI->B1_DESC)
  			oDBTree:AddTreeItem(cCat, cBmp2,,(LJPAI->ACV_CODPRO))
		
			LJPAI ->(DBSKIP())
		End
		
		lRet:=.T.	
		LJPAI->(DbCloseArea())  
	EndIf 
	(cArea) ->(DBSKIP()) 
End
oDBTree:EndTree()
oDBTree:PTRefresh()
(cArea)->(DbCloseArea())

Return  lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801SelPr  �Autor  � Vendas Cliente     � Data � 28/10/2010���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica os produtos selecionados pela quantidade vendida  ���
���          � ou produto especifico                                      ���
�������������������������������������������������������������������������͹��
���Parametros�nTipo - por prod especifico ou qtdade vendida               ���
���          �cprodSel - retorna o produto selecionado                    ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aSelPr(nTipo,cProdSel)

Local lRet 			:= .F.			//Variavel de retorno  
    
Default nTipo 		:=0
Default cProdSel 	:=""

DbSelectArea(cAliasTRB)
(cAliasTRB)->(DbGoTop())

While (cAliasTRB)->( !Eof() )
    If !Empty(AllTrim((cAliasTRB)->L2_OK))
    	If nTipo ==1         // caso seja por produto especifico sera necessario selecionar pelo menos um produto
    		lRet :=.T.
    		Exit
    	Else// caso seja por quantidade vendida sera necessario selecionar APENAS  um produto
    		If lRet
	    		lRet :=.F.
	    		Exit		    		     
    		EndIf
    		lRet :=.T.
    		cProdSel := (cAliasTRB)->L2_PRODUTO
    	Endif
    EndIf
	(cAliasTRB)->(DbSkip())
End
If !lRet
	If nTipo ==1
		MsgAlert(STR0033)
	Else
		MsgAlert(STR0034)
	EndIf

	/*/
� necess�rio informar pelo menos um produto.
Selecione apenas um produto.
/*/

EndIf
(cAliasTRB)->(DbGoTop())
Return lRet              

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801cFilP  �Autor  � Vendas Cliente     � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtra os produtos de acordo com a selecao informada ao    ���
���          � usuario                                                    ���
�������������������������������������������������������������������������͹��
���Parametros�cCodProduto - Codigo do produto                             ���
���          �cDataInicial - Data inicial da consulta                     ���
���          |cDataFinal - Data final da consulta                         ���
���          |nTipo - Tipo - se e por produto especifico ou qtde vendida  ���
���          �nQuantIni - Quantidade inicial                              ���
���          �nQuantFim - Quantidade Final                                ���
���          �nPercenIni - Porcentagem inicial                            ���
���          �nPercenFim - Porcentagem final                              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801cFilP (cCodProduto, cDataInicial, cDataFinal, nTipo,;
                     nQuantIni  , nQuantFim    , nPercenIni, nPercenFim)   

Local cOrcament 					:=  RetSQLName("SL2")			//Verificar qual eh a tabela de orcamento
Local cArea							:= "LJVC"  						//Alias temporario
Local lRet						    :=.F.							//Vari�vel de retorno
Local cQuerySel   					:=""								//Query
Local nPos                          :=0                              //variavel de controle de posicao
Default cCodProduto 				:=""
Default cDataInicial 				:="20100101"
Default cDataFinal	 				:="20101231"
Default nTipo 						:= 0
Default	nPercenIni 					:=0
Default	nPercenFim 					:=0
Default nQuantIni 					:=0
Default nQuantFim 					:=0


If Empty(nPercenIni)
	nPercenIni = 00.01
Endif
If Empty(nPercenFim)
	nPercenFim = 100
Endif

aProdCad:={}
If ntipo == 1     // caso seja produto especifico
	Lj801cVlPr(cCodProduto)     // verifica se o produto informado ja tem sugestao cadastrada
	nQtdeVend:=	Lj801aLocQ(cCodProduto, cDataInicial, cDataFinal)   // verifica a quantidade vendida do produto no periodo
	cQuerySel := "SELECT DISTINCT L2_PRODUTO, SUM(L2_QUANT) L2_QUANT, '.F.' L2_OK,   	L2_DESCRI FROM "  +  cOrcament
	cQuerySel += " WHERE  L2_NUM IN (  SELECT L2_NUM FROM " + cOrcament + " 	WHERE D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "' )"
  	cQuerySel += " AND  L2_PRODUTO <> '" + AllTrim(cCodProduto) + "' AND L2_EMISSAO BETWEEN '" + cDataInicial  + "' AND '" + cDataFinal + "' "  
  	cQuerySel += " AND D_E_L_E_T_ = ' ' AND (L2_DOC <> '" + Space(TamSx3("L2_DOC")[1]) + "' OR L2_PEDRES <> '" + Space(TamSx3("L2_PEDRES")[1]) +  "') "
	cQuerySel += " GROUP BY L2_PRODUTO,  L2_DESCRI"
	cQuerySel += " HAVING SUM(L2_QUANT)"
  	cQuerySel += " BETWEEN "
  	cQuerySel += "( (SELECT SUM (L2_QUANT) FROM " + cOrcament + " WHERE  D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "')*"  + STR(nPercenIni) + ") /100 AND "
  	cQuerySel += "( (SELECT SUM (L2_QUANT) FROM " + cOrcament + " WHERE  D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "')*"  + STR(nPercenFim) + ") /100     "
Else
    nQtdeVend:=0
	cQuerySel := "SELECT DISTINCT L2_PRODUTO, SUM(L2_QUANT) AS L2_QUANT,	L2_DESCRI FROM "  +  cOrcament
	cQuerySel += " WHERE L2_EMISSAO 	BETWEEN '" + cDataInicial  + "' AND '" + cDataFinal + "'
	cQuerySel += " AND D_E_L_E_T_ = ' '  AND (L2_DOC <> '" + Space(TamSx3("L2_DOC")[1]) + "' OR L2_PEDRES <> '" + Space(TamSx3("L2_PEDRES")[1]) +  "')"
	cQuerySel += " GROUP BY L2_PRODUTO, L2_DESCRI HAVING  SUM(L2_QUANT)"
	cQuerySel += " BETWEEN " + nQuantIni + " AND "  +  nQuantfim
Endif

cQuerySel += " ORDER BY L2_QUANT DESC "
LJa801ExQu(cArea,@cQuerySel)
DbSelectArea(cAliasTRB)
(cAliasTRB)->(__dbZap())
DbSelectArea(cArea)   
While !(cArea) ->(EOF())  // passa da tabela temporaria  LJVC para a TRB que ira preencher o grid
    nPos := aScan(aProdCad, {|c| c[2] == AllTrim((cArea)->L2_PRODUTO)} )     // verifica se os produtos retornados ja estao cadastrados
    If	nPos  == 0      // retorna zero quando o produto retornado nao esta cadastrado
		Reclock("TRB",.T.)
		(cAliasTRB)->L2_PRODUTO:=(cArea)->L2_PRODUTO                       // codigo do produto
		(cAliasTRB)->L2_DESCRI:=(cArea)->L2_DESCRI                         // Descricao do produto
		(cAliasTRB)->L2_QUANT:=(cArea)->L2_QUANT                           // quantidade vendida no periodo
		(cAliasTRB)->L2_PORCENT:= ((cArea)->L2_QUANT * 100)/ nQtdeVend     // porcentagem 
		(cAliasTRB)->L2_OK:=" "
	    lRet :=.T.
    EndIf
	(cArea) ->(DBSKIP())
End

(cAliasTRB)->(DbGoTop())  

Return lRet 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801cVlPr  �Autor  � Vendas Cliente     � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se j� existe o produto na sugest�o de vendas      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�cCodPro - Codigo do produto                                 ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801cVlPr(cCodPro) 

Local cArea	    := "LJVC"  						//Alias temporario	
Local cQuery 	:= ""                               //Variavel de Consulta
Default cCodPro :=""

cQuery:="SELECT DISTINCT C.ACV_CATEGO,C.ACV_CODPRO,P.B1_DESC FROM " + RetSqlName("ACV") +" C LEFT JOIN "+ RetSqlName("SB1") +" P " 
cQuery+="ON P.B1_COD = C.ACV_CODPRO WHERE  C.ACV_CATEGO IN ("
cQuery+="SELECT ACU_COD FROM  " + RetSqlName("ACU") +" WHERE ACU_CODPAI IN" 
cQuery+="(SELECT ACV_CATEGO FROM  " + RetSqlName("ACV") +" WHERE ACV_CODPRO ='" + (cCodPro) + "' AND D_E_L_E_T_ = ' ')) OR C.ACV_CATEGO IN("
cQuery+="(SELECT ACV_CATEGO FROM  " + RetSqlName("ACV") +" WHERE ACV_CODPRO ='" + (cCodPro) + "' AND D_E_L_E_T_ = ' ')) "
cQuery+="AND C.ACV_CODPRO <> '" + (cCodPro) + "' "
cQuery+="AND C.D_E_L_E_T_ =' '"   

LJa801ExQu(cArea,@cQuery)
While !(cArea) ->(EOF())
	AAdd(aProdCad, { .T., AllTrim((cArea)->ACV_CODPRO),(cArea)->B1_DESC} )  // preenche no array os produtos encontrados que ja estao cadastrados 
	(cArea) ->(DBSKIP())														//na sugestao de vendas
End	
(cArea)->(DbCloseArea())

Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aGetS  �Autor  � Vendas Cliente     � Data �  28/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     � Efetua a estrutura do grid e da tabela temporaria de produ ���
���          � tos                                                        ���
�������������������������������������������������������������������������͹��
���Parametros�aGrid - array de Campos para o grid de produtos             ���
���          �aStruTRB - Array com estrutura da tabela temporaria         ���
���          �aNomeTMP - Array com os arquviso temporarios                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aGetS(aGrid,aStruTRB,	aNomeTMP)
Local aTamD2_ITEM		:= TamSx3("L2_ITEM")		// Tamanho do campo D2_ITEM
Local aTamD2_COD		:= TamSx3("L2_PRODUTO")		// Tamanho do campo D2_COD
Local aTamB1_DESC		:= TamSx3("L2_DESCRI")		// Tamanho do campo B1_DESC
Local aTamD2_QTD		:= TamSx3("L2_QUANT")		// Tamanho do campo D2_QUANT
Local oTempTable		:= Nil 						// Objeto tabela temporaria

Default aGrid 			:= {}
Default aStruTrB 		:= {}
Default aNomeTMP 		:= {}

//����������������������������������������������������������Ŀ
//�Se estiver utilizando rastreablidade, mostra os campos de �
//�controle de lote.                                         �
//������������������������������������������������������������
   
AADD(aStruTRB,{"L2_OK"		,"C",aTamD2_ITEM[1]			,aTamD2_ITEM[2]		}) 
AADD(aStruTRB,{"L2_PRODUTO"	,"C",aTamD2_COD[1]			,aTamD2_COD[2]		})
AADD(aStruTRB,{"L2_DESCRI" 	,"C",aTamB1_DESC[1]			,aTamB1_DESC[2]		})
AADD(aStruTRB,{"L2_QUANT" 	,"N",aTamD2_QTD[1]			,aTamD2_QTD[2]		})
AADD(aStruTRB,{"L2_RECNO"   ,"C",10						,0					})
AADD(aStruTRB,{"L2_PORCENT"	,"N",aTamD2_QTD[1]			,aTamD2_QTD[2]		})

aAdd(aGrid,{"L2_OK"		,," "	 ," "})		
aAdd(aGrid,{"L2_PRODUTO",,STR0011," "}) 		//"Produto		
aAdd(aGrid,{"L2_DESCRI"	,,STR0029," "})			//"Descricao		
aAdd(aGrid,{"L2_QUANT"	,,STR0021," "})			//Quantidade

If Select(cAliasTRB) > 0
	If( ValType(oTempTable) == "O")
	  oTempTable:Delete()
	  FreeObj(oTempTable)
	  oTempTable := Nil
	EndIf
EndIf

//Cria tabela temporaria
oTempTable := LjCrTmpTbl(cAliasTRB, aStruTRB, {"L2_RECNO","L2_OK"})

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj801aLocQ  �Autor  � Vendas Cliente     � Data �  20/10/10 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a quantidade vendida de um determinado produto em ���
���          � um intervalo de tempo                                      ���
�������������������������������������������������������������������������͹��
���Parametros�cCodProduto - Codigo do produto                             ���
���          �cDataInicial - Data inicial da consulta                     ���
���          |cDataFinal - Data final da consulta                         ���  
�������������������������������������������������������������������������͹��
���Retorno   �Retorna a quantidade vendida do produto                     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - VENDA ASSISTIDA                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj801aLocQ (cCodProduto, cDataInicial, cDataFinal)     
Local nQuant 		:= 0				 	//Variavel de retorno
Local cOrcament 	:= RetSQLName("SL2")	//Verificar qual eh a tabela de orcamento
Local cArea			:= "LJVC"    			//Alias temporario 
Local cQuery       	:= ""                   //Variavel de Consulta
Default cCodProduto := ""
Default cDataInicial:= ""
Default cDataFinal 	:= ""

cQuery := " SELECT SUM(L2_QUANT) AS L2_QUANT FROM "  +  cOrcament
cQuery += " WHERE  L2_NUM IN (  SELECT L2_NUM FROM " + cOrcament + " 	WHERE D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "')"
cQuery += " AND  L2_PRODUTO = '" + AllTrim(cCodProduto) + "' AND L2_EMISSAO BETWEEN '" + cDataInicial  + "' AND '" + cDataFinal + "' "
cQuery += " AND D_E_L_E_T_ = ' '  AND (L2_DOC <> '" + Space(TamSx3("L2_DOC")[1]) + "' OR L2_PEDRES <> '" + Space(TamSx3("L2_PEDRES")[1]) +  "') "
cQuery += " GROUP BY L2_PRODUTO,  L2_DESCRI"
cQuery += " ORDER BY L2_QUANT DESC "
LJa801ExQu(cArea,@cQuery)

nQuant := LJVC->L2_QUANT

(cArea)->(DbCloseArea())

Return nQuant
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |LJ801aRetC  �Autor �Vendas               � Data � 28/10/10  ���
�������������������������������������������������������������������������͹��
���Descricao �Retorna ultima Categora cadastrada                          ���
�������������������������������������������������������������������������͹��
���Parametros�cCodPro = codigo do produto                	              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/    	
Function LJ801aRetC(cCodPro) 
Local cCateg  := "" 	// Variavel de Retorno
Local cQuery  := ""  // Query
Local cACU	  :=  RetSQLName("ACU")  //Define a tabela a ser utilizada em consulta
Local cArea	  := "LJVC"             //Area temporaria para consulta

Default	cCodPro	:=""

If !Empty(AllTrim(cCodPro)) // Caso tenha produto sera efetuada busca do produto para alteracao
	cQuery :="SELECT ACV_CATEGO FROM " + RetSQLName("ACV") + " WHERE ACV_CODPRO ='" + cCodPro + "' AND ACV_SUVEND = '1' AND D_E_L_E_T_ = ' '"
	LJa801ExQu(cArea,@cQuery)
	DbSelectArea(cArea) 
	cCateg := LJVC->ACV_CATEGO  //campo � tipo varchar
Else      
	cQuery :="SELECT MAX(ACU_COD) COD FROM " + cAcu +" WHERE D_E_L_E_T_ = ' '"
 	LJa801ExQu(cArea,@cQuery)
	DbSelectArea(cArea) 
	cCateg := Soma1(LJVC->COD)		//campo alfanumerico
EndIf
(cArea)->(DbCloseArea())

Return cCateg

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LJ801aVlUs� Autor � RAFAEL MARQUES        � Data �25/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se o usuario esta habilitado para usar a rotina     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LOJA801()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���                                                                        ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LJ801aVlUs()
Local lCat	:= SuperGetMV("MV_LJCATPR",,.F.) 	// Verifica se o usuario esta com o parametro setado como True  
Local lRet  := .F.                       // Variavel de retorno

#IFDEF TOP 
	lRet := .T.
#ELSE	
	MsgStop(STR0065,STR0064) //"Rotina disponivel apenas para ambiente TOPCONECT."."###"Aten��o !"
#ENDIF                                                

If lRet
	If !lCat  
		MsgStop(STR0066,STR0064) //"O parametro MV_LJCATPR deve estar habilitado."."###"Aten��o !"
		lRet := .F.	
	EndIf	
EndIf 

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LjVldPorc
Usado para valida��o do valor informado no campo de porcentagem final

@param   nTpProc - Tipo escolhido (1-Produto especifico;2-quantidade vendida
@param   nPerceFim - Valor de porcentagem informado 
@author  Varejo
@version P11
@since   21/10/2014
@return  lRet - booleana com o retorno de sucesso (.T.) ou problema (.F.) 
/*/
//-------------------------------------------------------------------
Static Function LjVldPorc(nTpProc, nPerceFim)
Local lRet := .T.

If nTpProc == 1 .And. nPerceFim > 100	//Produto especifico
	lRet := .F.
	MsgInfo(STR0063, STR0064) //#"A porcentagem final n�o pode ser supeior a 100%." //##"Aten��o"
EndIf

Return lRet
