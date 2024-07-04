#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "PLSA268.CH"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de cores para legenda [BROWSE] 							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
#DEFINE drAlert		"BR_AZUL"
#DEFINE drGlosa		"BR_VERMELHO"
#DEFINE drRever		"BR_CINZA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicoes do Array aCampo [GUIA] 	    					         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
#DEFINE OPERDA     		1	// Operadora
#DEFINE NUMLIB			2	// Numero de Liberacao
#DEFINE CODRDA     		3	// Codigo RDA
#DEFINE CODEMP     		4	// Empresa
#DEFINE CONEMP     		5	// Contrato
#DEFINE SUBCON     		6	// Sub-Contrato
#DEFINE CODPLA     		7	// Produto
#DEFINE CODPAD     		8	// Codigo Tabela Padrao
#DEFINE CODPRO     		9	// Codigo Procedimento
#DEFINE REGSOL     		10	// RDA Solicitante
#DEFINE REGEXE     		11	// RDA Executante
#DEFINE MATRIC     		12	// Matricula           
#DEFINE TIPREG     		13	// Tipo de Usuario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicaoes do Array aCampoB52 \ aCampoX [REGRAS]				         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

#DEFINE B52OPERDA     	1	// Operadora
#DEFINE B52NUMLIB  		2	// Numero de Liberacao
#DEFINE B52RDADE     	3	// RDA De
#DEFINE B52RDAATE     	4	// RDA Ate
#DEFINE B52FILRDA     	5	// Filtro RDA
#DEFINE B52TIPFIL     	6	// Tipo Filtro (1=Familia\2=Usuario)
#DEFINE B52FILFAM     	7	// Filtro(BA3-Familia\BA1-Usuario)
#DEFINE B52EMPDE     	8	// Empresa De
#DEFINE B52EMPATE     	9	// Empresa Ate
#DEFINE B52CONDE     	10	// Contrato De
#DEFINE B52CONATE     	11	// Contrato Ate
#DEFINE B52SUBDE     	12	// Sub-Contrato De
#DEFINE B52SUBATE     	13	// Sub-Contrato Ate
#DEFINE B52CDPLA1     	14	// Produto De
#DEFINE B52CDPLA2     	15	// Produto Ate  
#DEFINE B52CODPAD     	16	// Codigo Tabela Padrao
#DEFINE B52CDEVE1     	17	// Procedimento De
#DEFINE B52CDEVE2     	18	// Procedimento Ate    
#DEFINE B52REGSOL     	19	// RDA Solicitante
#DEFINE B52REGEXE     	20	// RDA Executante
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA268   ºAutor  ³Fernando Alves      º Data ³ 13/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CADASTRO - SITUACOES ADVERSAS X RDA                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA268()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Validacao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !PLSALIASEXI("B50")                                       
	MsgAlert( "Não é possível utilizar esta rotina! (Execute o compatibilizador da rotina)" )
	Return                                                  
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define cores da Legenda                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCores   := {	{"B50->B50_TPACAO == '1'",drAlert	}	,;
						{"B50->B50_TPACAO == '2'",drGlosa	}	,;
						{"B50->B50_TPACAO == '3'",drRever	}	 }

PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro 	:= Fundesc() //"Situaçoes Adversas X Regras"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
B50->(DbSetOrder(1)) 
B50->(DbGoTop())
B50->(mBrowse(06,01,22,75,"B50",,,,,,aCores))

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA268MOV³ Autor ³ Fernando Alves        ³ Data ³13/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentacao do Cadastro de Sit. Adversas x RDA            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA268MOV(cAlias,nReg,nOpc)

Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nPosIni	:= 0
LOCAL nPosFin	:= 0
LOCAL nPosX	:= 0
LOCAL nPosY	:= 0
LOCAL aAC      		:= {"",""} 
LOCAL nOpca	   		:= 0
LOCAL oDlg      	:= Nil
LOCAL aPosObj   	:= {}
LOCAL aObjects  	:= {}
LOCAL aSize     	:= {}
LOCAL aInfo     	:= {} 
LOCAL bAfterEdit	:= {||oGetB51:Refresh()} 
LOCAL bMultaCols    := {||oGetB51:Refresh()} 
LOCAL bOK       	:= {|| nOpca := 1,IIf(PLSVLD268(oGetB51,oGetB52,nOpc) .And. Obrigatorio(aGets,aTela).And.oGetB51:TudoOK().And.oGetB52:TudoOK(),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL aDifSize		:= {,,,,35,3,,}
LOCAL bLDblClick	:= {|| IIf(!M->B50_TPACAO $"2|3" .And. (nOpc == 3 .Or. nOpc == 4),Aviso(STR0002,STR0003,{"Ok"},1),; //"Atenção","Selecione um Tipo de ação que permita incluir Glosa!"
  					   	 oGetB51:EditRecord("B51",nOpc,PLSRetTit("B51"),oGetB51:Linha(),oGetB51:aCols,oGetB51:aHeader,bAfterEdit,bMultaCols,,,,,,,,IIf (Val(GetVersao(.F.)) >= 12,aDifSize,Nil)))}
PRIVATE oEnchoice
PRIVATE oGetB51
PRIVATE oGetB52
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader		:= {}   
PRIVATE aCols		:= {}     
PRIVATE aHeaderX	:= {}   
PRIVATE aColsX		:= {}
PRIVATE aVetB51 	:= {}  
PRIVATE aVetB52		:= {} 
PRIVATE aChaveB51 	:= {}  
PRIVATE aChaveB52 	:= {}  
PRIVATE oFolder
Private cRet		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols e aHeader...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header  "B51" TO aHeader   For .T.  
Store Header  "B52" TO aHeaderX  For .T.

If nOpc == K_Incluir
	Copy "B50" TO Memory Blank
	Store COLS Blank "B51" TO aCols  FROM aHeader      
	Store COLS Blank "B52" TO aColsX FROM aHeaderX
Else
	Copy "B50" TO MEMORY
	B51->(DbSetOrder(1))
	B52->(DbSetOrder(1))
	
	If B51->(MsSeek(xFilial("B51")+B50->B50_CODINT+B50_CODSAD)) 	                                      
		Store COLS "B51" TO aCols  FROM aHeader  VETTRAB aVetB51  While B51->(B51_FILIAL+B51_CODINT+B51_CODSAD) == B50->(B50_FILIAL+B50->B50_CODINT+B50_CODSAD) 
	Else
		Store COLS Blank "B51" TO aCols  FROM aHeader  
	Endif
	If B52->(MsSeek(xFilial("B52")+B50->B50_CODINT+B50_CODSAD)) 
		Store COLS "B52" TO aColsX FROM aHeaderX VETTRAB aVetB52  While B52->(B52_FILIAL+B52_CODINT+B52_CODSAD) == B50->(B50_FILIAL+B50->B50_CODINT+B50_CODSAD) 
	Else
		Store COLS Blank "B52" TO aColsX FROM aHeaderX
	EndIf
EndIf                                                                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 50, 370, .T., .T. } )
AAdd( aObjects, { 50, 140, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4] - aSize[2], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. ) 

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5]of oMainWnd PIXEL       

CursorWait()                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Folder...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nPosX := aPosObj[1][4] - 30 
nPosY := aPosObj[2][3]

nPosIni := aPosObj[1][1] - 05
nPosFin := aPosObj[1][1] - 15

@ nPosIni,nPosFin  FOLDER oFolder SIZE nPosX,nPosY OF oDlg PIXEL PROMPTS	OemtoAnsi(STR0004),; //"Situação Adversa"	
																OemtoAnsi(STR0005) //"Regras"
aPosObj[1][1] = aPosObj[1][2] + 5//posição de inicio do quadro que contem os campos
aPosObj[1][4] = aPosObj[1][4] - 40 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Echoice ...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oEnchoice	:= MSMGET():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oFolder:aDialogs[1],,.T.,.F.)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados B52 - REGRAS                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetB52				:= 	TPLSBrw():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,4],aPosObj[1,3],nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aHeaderX,aColsX,.F.,"B52",nOpc,PLSRetTit("B52"),nil,nil,nil,nil,'PL268VAL')
oGetB52:aVetTrab	:= aClone(aVetB52) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados B51 - CRITICAS                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetB51 			:= TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],(aPosObj[2,4]-30),aPosObj[2,3],nil,oFolder:aDialogs[1],nil,bLDblClick,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"B51",nOpc,PLSRetTit("B51"))
oGetB51:aVetTrab 	:= aClone(aVetB51) 
oGetB51:oPai    	:= oGetB52
oGetB51:aOrigem 	:= {"B50_CODINT"}
oGetB51:aRelac  	:= {"B51_CODCRI"}
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,{||oDlg:End()},.F.,{})  })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina de gravacao dos dados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK

   	PLUPTENC("B50",nOpc) 
   
   	aChaveB52 := 	{{"B52_CODINT"	,M->B50_CODINT	},;
					{ "B52_CODSAD"	,M->B50_CODSAD	} }
 	oGetB52:Grava(aChaveB52)
 	
 	aChaveB51 := 	{{"B51_CODINT"	,M->B50_CODINT	},;
					{ "B51_CODSAD"	,M->B50_CODSAD	} }
 	oGetB51:Grava(aChaveB51)    

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fernando Alves        ³ Data ³13/10/2010³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()     

If 1 == 2
	PLSA268MOV() 
	PLSA268LEG()
EndIf

Private aRotina := {	{ STR0006 	, 'AxPesqui'   , 0 , K_Pesquisar	,0 ,.F.},; //'Pesquisar'
                      	{ STR0007 	, 'PLSA268MOV' , 0 , K_Visualizar	,0 ,Nil},; //'Visualizar'
                      	{ STR0008 	, 'PLSA268MOV' , 0 , K_Incluir		,0 ,Nil},; //'Incluir'
                      	{ STR0009 	, 'PLSA268MOV' , 0 , K_Alterar		,0 ,Nil},; // 'Alterar'
                      	{ STR0010	, 'PLSA268MOV' , 0 , K_Excluir		,0 ,Nil},; //'Excluir'
                      	{ STR0011	, 'PLSA268LEG', 0 , 0				,0 ,Nil}}  //'Legenda'                     
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA268CSTºAutor  ³Fernando Alves      º Data ³ 13/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CONSULTA ESPECIFICA PARA OS CAMPOS DE FILTRO                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Function PLSA268CST()

Local cAlias := ""
Local cCampo := ReadVar()
Local cRetF3	 := ""    
Local lRet	 := .T.
Local oWnd	 := GetWndDefault() 

cRet := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica o campo em edicao para selecionar a tabela especifica.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Do Case
	Case cCampo == "M->B52_FILRDA" 	// Filtro RDA
	 	 cAlias	:= "BAU"
		 //aCampos	:= MontCampos(cAlias)
	 	    
 	Case cCampo == "M->B52_FILFAM"	// Filtro Familia\Usuario 
	 	If M->B52_TIPFIL == "1"		// Familia
	 		cAlias	:= "BA3"
		    //aCampos	:= MontCampos(cAlias)
		ElseIf M->B52_TIPFIL == "2"	// Usuario
			cAlias	:= "BA1"
	    	//aCampos	:= MontCampos(cAlias)
	    Else
	    	Alert(STR0012) //"Por favor, selecione no campo anterior Familia ou Usuário."
	    	lRet:=.F.   
	    EndIf
EndCase

If lRet == .T.	  
	DbSelectArea(cAlias) 
	cRetF3	:= BuildExpr(cAlias,oWnd,cRetF3,,,,,,,,)            
	&cCampo	:= cRetF3
	cRet := cRetF3
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA268VALºAutor  ³Fernando Alves      º Data ³  13/10/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³VALIDACAO DOS CAMPOS                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function PLSA268VAL(cID)

Local cTipoRegra := ""
Local nI 		 := 0
Local lRet		 := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evita a duplic. da chave:                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case cID == "01"
	If B50->(MsSeek(xFilial("B50")+M->B50_CODINT+M->B50_CODSAD))
		Alert(STR0013) //"Situação Adversa já cadastrada para esta Operadora."
		lRet:=.F.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So permite vincular criticas quando o tipo de acao for Glosa.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
Case cID == "02"
	If M->B50_TPACAO == "1" .OR. Empty(M->B50_TPACAO) 
		Alert(STR0014) //"Só é possivel vincular uma crítica à Sit. Adversa quando: Tipo Ação = Glosa ou Reversão "
		lRet:=.F.
	EndIf
	If lRet 
		BCT->( DbSetOrder(1) ) //BCT_FILIAL, BCT_CODOPE, BCT_PROPRI, BCT_CODGLO
		If !BCT->( MsSeek(xFilial("BCT")+M->B50_CODINT+M->(B51_PROPRI+B51_CODCRI)))
			Help(" ",1,"REGNOIS")
			lRet:=.F.
		Else
			M->B51_DESCRI:= BCT->BCT_DESCRI
		Endif
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 																	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case cID == "03" 

cRda:= Readvar()  

For nI:= 1 to Len(aCols)     
	If nI == oGetB52:Linha()
		Loop
	EndIf
	If aCols[nI][2] == M->B52_TIPREG  .And. Alltrim(&cRda) >= Alltrim(aCols[nI][3]);
	   .And. Alltrim(&cRda) <= Alltrim(aCols[nI][4]) 
		If M->B52_TIPREG == "1"
			cTipoRegra:= "Judicial"
		ElseIf M->B52_TIPREG == "2"
			cTipoRegra:= "Administrativo"
		Else
			cTipoRegra:= "Técnico" 
	    EndIf
		Alert(STR0023 + cTipoRegra + STR0024) // "Já existe uma regra do Tipo "   //   " cadastrada para esta RDA"
		lRet:=.F.
	EndIf
Next nI

EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL268VAL  ºAutor  ³Fernando Alves      º Data ³  13/10/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³VALIDACAO DOS CAMPOS                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function PL268VAL()
Local cTipoRegra := ""
Local nI 		 := 0
Local lRet		 := .T.

For nI:= 1 to Len(aCols)                                      
  	If !oGetB52:lInAddLine
		Loop
 	EndIf
	If aCols[nI][2] == M->B52_TIPREG  .And. Alltrim(M->B52_RDADE) >= Alltrim(aCols[nI][3]);
	   .And. Alltrim(M->B52_RDAATE) <= Alltrim(aCols[nI][4]) 
		If M->B52_TIPREG == "1"
			cTipoRegra:= "Judicial"
		ElseIf M->B52_TIPREG == "2"
			cTipoRegra:= "Administrativo"
		Else
			cTipoRegra:= "Técnico" 
	    EndIf
		Alert(STR0023 + cTipoRegra + STR0024) // "Já existe uma regra do Tipo "   //   " cadastrada para esta RDA"
		lRet:=.F.
	EndIf
Next nI

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA268LEGºAutor  ³Fernando Alves      º Data ³ 19/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MONTA LEGENDA                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA268LEG()

Local cCadLeg := STR0015 //"Tipo de Ação"

BrwLegenda (cCadLeg,STR0015,;// "Tipo de Ação"
{{drAlert	,STR0016	},;// "Alerta"
{drGlosa	,STR0017	},; // "Glosa"
{ drRever	,STR0018	}}) // "Reversão"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA268A  ºAutor  ³Fernando Alves      º Data ³ 19/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³FILTRA E BUSCA DADOS                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA268A(cCdTbPd,cCodPro,cCodOpeRDA,cCodRda,cCodPRFSol,cCodPRFExe,cChavLib)
Local aCampo	 := {"","","","","","","","","","","","",""}                     
Local aCampoB52	 := {"","","","","","","","","","","","","","","","","","","",""}
Local aCampoX    := {"","","","","","","","","","","","","","","","","","","",""}
Local aCamposU	 := {}
Local aCamposC	 := {}
Local aConsulta	 := {}
Local aCriticas	 := {}
Local lRetX		 := .F. 
Local cEof       := Chr(10)+ Chr(13)
Local i			 := 0
Local cTipoAcao	 := ""
Local cCodSitAdv := ""
Local cDescStAdv := ""
Local cObserv01	 := ""
Local cObserv02	 := ""
Local cObserv03	 := ""
Local cObserv04	 := ""
Local cObserv05	 := ""
Local cObserv06	 := ""
Local cObserv07	 := ""
Local cObserv08	 := ""
Local cObserv09	 := ""
Local cObserv10	 := ""
Local cObserv11	 := ""
Local cObserv12	 := ""
Local dDataDe	 := stod('')
Local dDataAte 	 := stod('')
Local cSolic 	 := Iif( ! empty(cCodPRFSol),POSICIONE("BB0",1,xFilial("BB0") + cCodPRFSol,"BB0_NUMCR"),"")
Local cExec  	 := Iif( ! empty(cCodPRFExe),POSICIONE("BB0",1,xFilial("BB0") + cCodPRFExe,"BB0_NUMCR"),"")        

//³ MONTA CAMPOS DA GUIA PARA VERIFICACAO
aCampo[OPERDA]:= cCodOpeRDA
aCampo[NUMLIB]:= cChavLib
aCampo[CODRDA]:= cCodRda 

aCampo[CODEMP]:= &("BA1->BA1_CODEMP")   
aCampo[CONEMP]:= &("BA1->BA1_CONEMP")    
aCampo[SUBCON]:= &("BA1->BA1_SUBCON")
aCampo[CODPLA]:= iIf( empty( &("BA1->BA1_CODPLA") ) , &("BA3->BA3_CODPLA"), &("BA1->BA1_CODPLA") )

aCampo[CODPAD]:= cCdTbPd  
aCampo[CODPRO]:= cCodPro
aCampo[REGSOL]:= cSolic 
aCampo[REGEXE]:= cExec 

aCampo[MATRIC]:= &("BA1->BA1_MATRIC")
aCampo[TIPREG]:= &("BA1->BA1_TIPREG")
                                                                       
B52->(dbGoTop())

if !B52->(eof())
	BGX->(DbSetOrder(1))
	B50->(DbSetOrder(1))
	B51->(DbSetOrder(1))
endIf
	
while !B52->(eof())

	aCamposU	:= {}
	aCamposC	:= {}
	aConsulta	:= {}
	
	//³ MONTA CAMPOS DA TABELA B52 [REGRAS]                               
	aCampoB52[B52OPERDA]:= &("B52->B52_CODINT")
	aCampoB52[B52NUMLIB]:= &("B52->B52_NUMLIB")
	aCampoB52[B52RDADE] := &("B52->B52_RDADE" )   
	aCampoB52[B52RDAATE]:= &("B52->B52_RDAATE")  
	aCampoB52[B52FILRDA]:= &("B52->B52_FILRDA") 
	aCampoB52[B52TIPFIL]:= &("B52->B52_TIPFIL") 
	aCampoB52[B52FILFAM]:= &("B52->B52_FILFAM")
	aCampoB52[B52EMPDE] := &("B52->B52_EMPDE" ) 
	aCampoB52[B52EMPATE]:= &("B52->B52_EMPATE")
	aCampoB52[B52CONDE] := &("B52->B52_CONDE" )      
	aCampoB52[B52CONATE]:= &("B52->B52_CONATE") 
	aCampoB52[B52SUBDE] := &("B52->B52_SUBDE" )
	aCampoB52[B52SUBATE]:= &("B52->B52_SUBATE")
	aCampoB52[B52CDPLA1]:= &("B52->B52_CDPLA1")  
	aCampoB52[B52CDPLA2]:= &("B52->B52_CDPLA2")  
	aCampoB52[B52CODPAD]:= &("B52->B52_CODTAB")   
	aCampoB52[B52CDEVE1]:= &("B52->B52_CDEVE1") 
	aCampoB52[B52CDEVE2]:= &("B52->B52_CDEVE2") 
	aCampoB52[B52REGSOL]:= &("B52->B52_CODSOL") 
	aCampoB52[B52REGEXE]:= &("B52->B52_CODEXE")
	
	//Verifica o tipo de acao da Sit. Adversa.    
	if B50->( msSeek( xFilial("B50") + B52->B52_CODINT + B52->B52_CODSAD ) )
	
		cTipoAcao	:= B50->B50_TPACAO
		cCodSitAdv	:= B50->B50_CODSAD
		cObserv01	:= B50->B50_OBS1	
		cObserv02	:= B50->B50_OBS2	
		cObserv03	:= B50->B50_OBS3	
		cObserv04	:= B50->B50_OBS4	
		cObserv05	:= B50->B50_OBS5	
		cObserv06	:= B50->B50_OBS6	
		cObserv07	:= B50->B50_OBS7	
		cObserv08	:= B50->B50_OBS8	
		cObserv09	:= B50->B50_OBS9 
		cObserv10	:= B50->B50_OBS10
		cObserv11	:= B50->B50_OBS11
		cObserv12	:= B50->B50_OBS12
		
	endIf                             
		
	if BGX->( msSeek( xFilial("BGX") + B52->B52_CODINT + B52->B52_CODSAD ) )
		
		cDescStAdv	:= BGX->BGX_DESCRI	
		dDataDe		:= BGX->BGX_VIGDE
		dDataAte	:= BGX->BGX_VIGATE
				
	endIf
	
	//Soh entra na busca caso o RDA da Guia contemple o da Regra.              
	If 	( dDataDe <= dDataBase ) .and. ( dDataAte >= dDataBase .or. empty(dDataAte) )       

		//Varre a Tabela de Regras e encontra os campo preenchidos                 
		For i := 1 to Len(aCampoB52)
			
			aCampoB52[i] := alltrim(aCampoB52[i])
			
			If !empty(aCampoB52[i])
				Aadd(aCamposU,{aCampoX[i]})		//	Campo preenchido				Ex: XXX->XXX_CODINT
				Aadd(aCamposC,{aCampoB52[i]})	//	Conteudo do campo preenchido	Ex: 00001	
			EndIf
					
		Next i 
						
		//Faz o batimento dos campos da Guia com os campos preenchidos da tabela de regras  
		For i := 1 to Len(aCamposU)
		
	    	Do Case
	    	  				
	    		Case aCamposU[i][1] == "B52->B52_CODINT"

	    			lRetX := PLSA268BAT(1,aCamposC[i][1],,aCampo[OPERDA])
	    		
	    			Aadd(aConsulta,{lRetX})
	    			
				Case aCamposU[i][1] == "B52->B52_NUMLIB"
				
					lRetX := PLSA268BAT(2,aCamposC[i][1],,aCampo[NUMLIB])
				
					Aadd(aConsulta,{lRetX})
				
				Case aCamposU[i][1] == "B52->B52_FILRDA"
				
	    	   		If !Empty(aCamposC[i][1]) 
	    	   	
	    	   			lRetX := PLSA268FIL(aCampo[CODRDA],"RDA",,aCamposC[i][1])
	    	   			
	    	   			Aadd(aConsulta,{lRetX})
	    	   			
	    	   		Else
	    	   			lRetX:= .T.
					EndIf	

				Case aCamposU[i][1] == "B52->B52_TIPFIL" .And. Len(aCamposU)>= (i+1)
				
					If aCamposU[i+1][1] == "B52->B52_FILFAM" .And. !Empty(aCamposC[i+1][1]) 
						
						cFamUser := IIF(aCamposC[i][1]=="1","BA3","BA1")
						
						lRetX := PLSA268FIL(aCampo[CODRDA],"F/U",cFamUser,aCamposC[i+1][1],aCampo[OPERDA],;
										    aCampo[CODEMP],aCampo[CONEMP],aCampo[SUBCON],aCampo[MATRIC],aCampo[TIPREG])
										     
						Aadd(aConsulta,{lRetX})
                    Else
                    	lRetX:= .T.
                    Endif
                    
				Case aCamposU[i][1] == "B52->B52_EMPDE"
					
					lRetX := PLSA268BAT(3,aCamposC[i][1],aCamposC[i+1][1],aCampo[CODEMP]) 
					
					Aadd(aConsulta,{lRetX})
					 
				Case aCamposU[i][1] == "B52->B52_CONDE"
					
					lRetX := PLSA268BAT(4,aCamposC[i][1],aCamposC[i+1][1],aCampo[CONEMP]) 
					
					Aadd(aConsulta,{lRetX})
					      
				Case aCamposU[i][1] == "B52->B52_SUBDE"
					
					lRetX := PLSA268BAT(5,aCamposC[i][1],aCamposC[i+1][1],aCampo[SUBCON])  
					
					Aadd(aConsulta,{lRetX})
							
				Case aCamposU[i][1] == "B52->B52_CDPLA1"
					
					lRetX := PLSA268BAT(6,aCamposC[i][1],aCamposC[i+1][1],aCampo[CODPLA]) 
					
					Aadd(aConsulta,{lRetX})
					 
				Case aCamposU[i][1] == "B52->B52_CODTAB"
					
					lRetX := PLSA268BAT(7,aCamposC[i][1],,aCampo[CODPAD])
					
					Aadd(aConsulta,{lRetX})
					
				Case aCamposU[i][1] == "B52->B52_CDEVE1"
					
					lRetX := PLSA268BAT(8,aCamposC[i][1],aCamposC[i+1][1],aCampo[CODPRO])
					
					Aadd(aConsulta,{lRetX})
					 
				Case aCamposU[i][1] == "B52->B52_CODSOL"
					
					lRetX := PLSA268BAT(9,aCamposC[i][1],,aCampo[REGSOL])
					
					Aadd(aConsulta,{lRetX})
					 
				Case aCamposU[i][1] == "B52->B52_CODEXE"
					
					lRetX := PLSA268BAT(10,aCamposC[i][1],,aCampo[REGEXE])
					
					Aadd(aConsulta,{lRetX})
					
			EndCase
				 	
		Next i
	   	
		//³ Verifica se existe algum retorno .F. no Array aConsulta, caso nao exista, as regras batem com os dados da guia  ³
		nPosX := aScan(aConsulta,{|x| x[1] == .F.}) 
		
		If nPosx == 0
		
           	Do Case
           
           	Case cTipoAcao == "1" // Alerta
           	
           				Aadd(aCriticas,{""			, ""											,;
										cTipoAcao , cCodSitAdv 	, cDescStAdv , cObserv01						,; 
										cObserv02 , cObserv03	, cObserv04	 , cObserv05						,;	
										cObserv06 ,	cObserv07	, cObserv08	 , cObserv09						,;	
										cObserv10 , cObserv11	, cObserv12  ,B52->B52_TIPREG, B52->B52_DATINC	})
						
           	Case cTipoAcao == "2" // Glosa 
           	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Descricao do Array aCriticas                                                              ³
				//³-------------------------------------------------------------------------------------------³
				//³ aCriticas[n][01] - CODIGO DA CRITICA [B51->B51_PROPRI+B51->B51_CODCRI]                    ³
				//³ aCriticas[n][02] - DESCRICAO DA CRITICA 												  ³
				//³ aCriticas[n][03] - TIPO DA ACAO [ALERTA \ GLOSA \ REVERSAO]                               ³
				//³ aCriticas[n][04] - CODIGO DA SITUACAO ADVERSA 											  ³
				//³ aCriticas[n][05] - DESCRICAO DA SITUACAO ADVERSA 										  ³
				//³ aCriticas[n][06] - OBSERVACAO 01														  ³
				//³ aCriticas[n][07] - OBSERVACAO 02														  ³
				//³ aCriticas[n][08] - OBSERVACAO 03 														  ³
				//³ aCriticas[n][09] - OBSERVACAO 04 														  ³
				//³ aCriticas[n][10] - OBSERVACAO 05 														  ³
				//³ aCriticas[n][11] - OBSERVACAO 06 														  ³
				//³ aCriticas[n][12] - OBSERVACAO 07 														  ³
				//³ aCriticas[n][13] - OBSERVACAO 08 														  ³
				//³ aCriticas[n][14] - OBSERVACAO 09 														  ³
				//³ aCriticas[n][15] - OBSERVACAO 10 														  ³
				//³ aCriticas[n][16] - OBSERVACAO 11 														  ³
				//³ aCriticas[n][17] - OBSERVACAO 12 														  ³ 
				//³ aCriticas[n][18] - TIPO DE REGRA 													      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 			

				If B51->( msSeek(xFilial("B51")+B52->B52_CODINT+B52->B52_CODSAD))

					While B51->(B51_FILIAL+B51_CODINT+B51_CODSAD) == B52->(B52_FILIAL+B52_CODINT+B52_CODSAD) 
					
						Aadd(aCriticas,{B51->B51_PROPRI+B51->B51_CODCRI, B51->B51_DESCRI			,;
										cTipoAcao , cCodSitAdv 	, cDescStAdv , cObserv01							,; 
										cObserv02 , cObserv03	, cObserv04	 , cObserv05							,;	
										cObserv06 ,	cObserv07	, cObserv08	 , cObserv09							,;	
										cObserv10 , cObserv11	, cObserv12  , B52->B52_TIPREG	, B52->B52_DATINC	})
						
						
					B51->(DbSkip())
					EndDo
					
				EndIf
		    
		    Case cTipoAcao == "3" // Reversao 
		       
		    	If B51->(MsSeek(xFilial("B51")+B52->B52_CODINT+B52->B52_CODSAD))
		
					While B51->(B51_FILIAL+B51_CODINT+B51_CODSAD) == B52->(B52_FILIAL+B52_CODINT+B52_CODSAD) 
					
						Aadd(aCriticas,{B51->B51_PROPRI+B51->B51_CODCRI, B51->B51_DESCRI			,;
										cTipoAcao , cCodSitAdv 	, cDescStAdv , cObserv01							,; 
										cObserv02 , cObserv03	, cObserv04	 , cObserv05							,;	
										cObserv06 ,	cObserv07	, cObserv08	 , cObserv09							,;	
										cObserv10 , cObserv11	, cObserv12  , B52->B52_TIPREG	, B52->B52_DATINC	})
						
						
					B51->(DbSkip())
					EndDo

				Else

					Aadd(aCriticas,{""			, ""										,;
									cTipoAcao , cCodSitAdv 	, cDescStAdv , cObserv01					,; 
									cObserv02 , cObserv03	, cObserv04	 , cObserv05					,;	
									cObserv06 ,	cObserv07	, cObserv08	 , cObserv09					,;	
									cObserv10 , cObserv11	, cObserv12  , B52->B52_TIPREG	, B52->B52_DATINC	})
				EndIf
		    
		    EndCase
		    
		EndIf
		
	EndIf 	

B52->(dbSkip())
EndDo

Return(aCriticas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA268BATºAutor  ³Fernando Alves      º Data ³ 19/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza batimento de dados Regras x Guia                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSA268BAT(nOpcX,cCampoA,cCampoB,cCampoC)

Local lRet:= .F.

Do case
	Case nOpcX == 1 // Operadora
		If Alltrim(cCampoA) == Alltrim(cCampoC)
			lRet:=.T.
		EndIf 
	Case nOpcX == 2 // Numero de Liberacao
		If Alltrim(cCampoA) == Alltrim(cCampoC)
			lRet:=.T.
		EndIf
	Case nOpcX == 3 // Empresa  
		If	cCampoC >= cCampoA .And. cCampoC <= cCampoB
			lRet:=.T.
		EndIf		                  
	Case nOpcX == 4 // Contrato  
		If	cCampoC >= cCampoA .And. cCampoC <= cCampoB
			lRet:=.T.
		EndIf
	Case nOpcX == 5 // Sub-Contrato 
		If	cCampoC >= cCampoA .And. cCampoC <= cCampoB
			lRet:=.T.
		EndIf
	Case nOpcX == 6 // Produto   
		If	cCampoC >= cCampoA .And. cCampoC <= cCampoB
			lRet:=.T.
		EndIf
	Case nOpcX == 7 // Tabela Padrao   
		If Alltrim(cCampoA) == Alltrim(cCampoC)
			lRet:=.T.
		EndIf
	Case nOpcX == 8 // Procedimento  
		If	cCampoC >= cCampoA .And. cCampoC <= cCampoB
			lRet:=.T.
		EndIf
	Case nOpcX == 9 // RDA Solicitante 
		If Alltrim(cCampoA) == Alltrim(cCampoC)
			lRet:=.T.
		EndIf
	Case nOpcX == 10 //RDA Executante
		If Alltrim(cCampoA) == Alltrim(cCampoC)
			lRet:=.T.
		EndIf 
EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA268FILºAutor  ³Fernando Alves      º Data ³ 19/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³FAZ A LEITURA DO CONTEUDO DO CAMPO DE FILTRO                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA268FIL(cRDA,cFiltroID,cFamUser,cFiltro,cCodint,cCodemp,cConemp,cSubcon,cMatric,cTipreg)

Local cOp		 := ""	  
Local luFiltro	 := .F. 
Local aOrigDados := {}
Local aDados	 := {}
Local cCampo	 := ""
Local XXX		 := ""
Local cAlias	 := ""
Local cChaveAux	 := ""
Local lRet		 := .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|BAU|ÄÄ|BA3|ÄÄÄÄÄ|BA1|ÄÄÄÄ¿
//³ Atraves da variavel cFiltroID define dinamicamente:Campo de controle, DbClearFilter(), dbGotop(),Eof() e Chave.   [RDA - FAMILIA - USUARIO] ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFiltroID == "RDA" 
       xCampo	:= &("BAU->BAU_CODIGO"			)
       xClear	:=  ("BAU->(DbClearFilter())"	)
       xGoTop	:=  ("BAU->(dbGotop())"			)
       xEof		:=  ("!BAU->(Eof())"			)
       xDbSkip	:=  ("BAU->(DbSkip())"			)
       cChaveAux:=  "BAU_CODIGO =='" + cRDA + "' .AND. "
       cAlias	:=  "BAU" 
Else
	If cFamUser == "BA3"
	   xCampo	:= &("BA3->BA3_CODINT")
	   xClear	:=  ("BA3->(DbClearFilter())"	)
       xGoTop	:=  ("BA3->(dbGotop())"			)
       xEof		:=  ("!BA3->(Eof())"			)
       xDbSkip	:=  ("BA3->(DbSkip())"			)
       cChaveAux:= 	"BA3_CODINT = '" + cCodint + "' .AND. " + ;  
       			   	"BA3_CODEMP = '" + cCodemp + "' .AND. " + ;
       			   	"BA3_CONEMP = '" + cConemp + "' .AND. " + ;
       			   	"BA3_SUBCON = '" + cSubcon + "' .AND. " + ;
       			  	"BA3_MATRIC = '" + cMatric + "' .AND. " 				
	   cAlias	:= 	"BA3"
	Else
	   xCampo	:= &("BA1->BA1_CODINT")
	   xClear	:=  ("BA1->(DbClearFilter())"	)
       xGoTop	:=  ("BA1->(dbGotop())"			)
       xEof		:=  ("!BA1->(Eof())"			)
       xDbSkip	:=  ("BA1->(DbSkip())"			)
       cChaveAux:= 	"BA1_CODINT = '" + cCodint + "' .AND. " + ; 
       				"BA1_CODEMP = '" + cCodemp + "' .AND. " + ;
       				"BA1_CONEMP = '" + cConemp + "' .AND. " + ;
       				"BA1_SUBCON = '" + cSubcon + "' .AND. " + ;
       				"BA1_MATRIC = '" + cMatric + "' .AND. " + ;
       				"BA1_TIPREG = '" + cTipreg + "' .AND. "	 
	   cAlias	:= "BA1"
    EndIf 
EndIf

		If Empty(cFiltro)
			&xClear
			aDados := Aclone(aOrigDados)
		Else
			aArea := Getarea()
			DbSelectArea(cAlias)
			Set Filter To &(cChaveAux + cFiltro)
			&xGoTop
			
			If &xEof
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reset aDados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aDados := {}
				luFiltro := .T.
				
				While &xEof  
					Aadd(aDados,{xCampo})
					&xDbSkip
				Enddo 
			Endif
			If !Empty(aDados) 
            	lRet:= .T.
			Else
				aDados := {}
			Endif   
			&xClear	
		Endif
Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontCamposºAutor  ³Fernando Alves      º Data ³ 19/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Array com campos a serem exibidos no Filtro de Regras º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function MontCampos(cAlias)
Local aCampos

Do Case
	Case cAlias == "BAU"
		aCampos:= {	"BAU_CODIGO"	,	"BAU_CODSA2"	, 	"BAU_LOJSA2"	, 	"BAU_TIPPE"	,;
					"BAU_CPFCGC"	,	"BAU_NOME"		,	"BAU_NREDUZ"	, 	"BAU_NFANTA",;
					"BAU_RECPRO"	,	"BAU_DTINCL"	,	"BAU_SIGLCR"	, 	"BAU_ESTCR"	,;
					"BAU_CONREG"	,	"BAU_SIGCR2"	,	"BAU_ESTCR2"	, 	"BAU_CONRE2",;
					"BAU_TIPPRE"	,	"BAU_CODOPE"	,	"BAU_COPCRE"	, 	"BAU_CATHOS",;
					"BAU_ALTCUS"	,	"BAU_LEGEND"	,	"BAU_FAX"		, 	"BAU_TIPLOG",;
					"BAU_CEP"		, 	"BAU_END"		,	"BAU_NUMERO"	, 	"BAU_COMPL"	,;
					"BAU_BAIRRO"	, 	"BAU_MUN"		,	"BAU_EST"		, 	"BAU_TEL"	,;
					"BAU_INSCR"		, 	"BAU_INSCRM"	,	"BAU_SEXO"		, 	"BAU_NASFUN",;
					"BAU_ESTCIV"	, 	"BAU_RG"		,	"BAU_CALIMP"	, 	"BAU_CALIRF",;
					"BAU_CBO"		, 	"BAU_ANOFOR"	,	"BAU_ENFER"		, 	"BAU_APTO"	,;
					"BAU_URGEME"	, 	"BAU_OK"		,	"BAU_CODBB0"	, 	"BAU_CODBK6",;
					"BAU_DTEXCL"	, 	"BAU_CORRES"	,	"BAU_CODBLO"	, 	"BAU_DATBLO",;
					"BAU_CODCFG"	, 	"BAU_EMAIL"		,	"BAU_CONJUG"	, 	"BAU_DIAPGT",;
					"BAU_PAGPRO"	, 	"BAU_CC"		,	"BAU_ITECTA"	, 	"BAU_CLVL"	,;
					"BAU_MODPAG"	, 	"BAU_NACION"	,	"BAU_WEB"		, 	"BAU_CODRET",;
					"BAU_MATFUN"	, 	"BAU_FILFUN"	,	"BAU_GAUSS"		, 	"BAU_CONTRA",;
					"BAU_CLAEST"	, 	"BAU_CNES"		,	"BAU_DTINSE"	, 	"BAU_DTINCT",;
					"BAU_DIRTEC"	, 	"BAU_DIRREG"	,	"BAU_ISS"		, 	"BAU_INSS"	,;
					"BAU_TIPDIS"	, 	"BAU_NRLTOT"	,	"BAU_NRLCON"	, 	"BAU_NRLPIS",;
					"BAU_NRUTIA"	, 	"BAU_NRUTIN"	,	"BAU_NRUTIP"	, 	"BAU_BASINS",;
					"BAU_GRPPAG"	, 	"BAU_PRDATN"	,	"BAU_PRDPAG"	, 	"BAU_POLFIN",;
					"BAU_DIAPOL"	, 	"BAU_RELAOP"	,	"BAU_FORPGT"	, 	"BAU_AUTGER",;
					"BAU_ACDTRB"	, 	"BAU_TABPRO"	,	"BAU_TPPROD"	, 	"BAU_GUIMED",; 
					"BAU_SIGDIR"	, 	"BAU_UFCDIR"	,	"BAU_TIPRED"					 }

	Case cAlias == "BA1"
		aCampos:={	"BA1_MATRIC"	,	"BA1_CONEMP"	,	"BA1_TIPREG"	,	"BA1_DIGITO",;
					"BA1_CPFUSR"	,	"BA1_PISPAS"	,	"BA1_DRGUSR"	,	"BA1_ORGEM"	,;
					"BA1_MATVID"	,	"BA1_NOMUSR"	,	"BA1_NREDUZ"	,	"BA1_DATNAS",;
					"BA1_SEXO"		,	"BA1_TIPUSU"	,	"BA1_ESTCIV"	,	"BA1_GRAUPA",;
					"BA1_DATINC"	,	"BA1_NOMPRE"	,	"BA1_MAE"		,	"BA1_CPFPRE",;
					"BA1_CPFMAE"	,	"BA1_DATADM"	,	"BA1_RECNAS"	,	"BA1_CODPLA",;
					"BA1_VERSAO"	,	"BA1_10ANOS"	,	"BA1_EMICAR"	,	"BA1_DATCAS",;
					"BA1_CEPUSR"	,	"BA1_ENDERE"	,	"BA1_NR_END"	,	"BA1_COMEND",;
					"BA1_BAIRRO"	,	"BA1_CODMUN"	,	"BA1_MUNICI"	,	"BA1_ESTADO",;
					"BA1_DDD"		,	"BA1_TELEFO"	,	"BA1_CODPRF"	,	"BA1_DATMAE",;
					"BA1_PAI"		,	"BA1_CPFPAI"	,	"BA1_DATPAI"	,	"BA1_MATEMP",;
					"BA1_MATANT"	,	"BA1_TIPANT"	,	"BA1_DATCAR"	,	"BA1_DATCPT",;
					"BA1_MUDFAI"	,	"BA1_COBRET"	,	"BA1_MESREA"	,	"BA1_INDREA",;
					"BA1_CB1AMS"	,	"BA1_UNIVER"	,	"BA1_DATBLO"	,	"BA1_MOTBLO",;
					"BA1_CONSID"	,	"BA1_INTERD"	,	"BA1_NUMCON"	,	"BA1_CORNAT",;
					"BA1_SANGUE"	,	"BA1_PRICON"	,	"BA1_ULTCON"	,	"BA1_PROCON",;
					"BA1_VIACAR"	,	"BA1_CODFUN"	,	"BA1_INSALU"	,	"BA1_CODSET",;
					"BA1_PESO"		,	"BA1_ALTURA"	,	"BA1_OBESO"		,	"BA1_RGIMP"	,;
					"BA1_CBTXAD"	,	"BA1_VLTXAD"	,	"BA1_NUMCOB"	,	"BA1_JACOBR",;
					"BA1_TXADOP"	,	"BA1_VLTXOP"	,	"BA1_COBINI"	,	"BA1_ANOMES",;
					"BA1_INFCOB"	,	"BA1_INFGCB"	,	"BA1_INFPRE"	,	"BA1_NUMCER",;
					"BA1_CDIDEN"	,	"BA1_NSUBFT"	,	"BA1_USRVIP"	,	"BA1_OPEORI",;
					"BA1_OPEDES"	,	"BA1_OPERES"	,	"BA1_LOCATE"	,	"BA1_LOCCOB",;
					"BA1_LOCEMI"	,	"BA1_LOCANS"	,	"BA1_INFSIB"	,	"BA1_INFANS",;
					"BA1_LOCSIB"	,	"BA1_ATUSIB"	,	"BA1_DTVLCR"	,	"BA1_OK"	,;
					"BA1_IMPORT"	,	"BA1_DATTRA"	,	"BA1_EQUIPE"	,	"BA1_CODVEN",;
					"BA1_CODVE2"	,	"BA1_FXCOB"		,	"BA1_OUTLAN"	,	"BA1_ESCOLA",;
					"BA1_CDORIG"	,	"BA1_PSORIG"	,	"BA1_SOBRN"		,	"BA1_ARQEDI",;
					"BA1_OBSERV"	,	"BA1_NUMENT"	,	"BA1_FILIAL"	,	"BA1_PLAINT",;
					"BA1_DATREP"	,	"BA1_MATUSB"	,	"BA1_STAEDI"	,	"BA1_PRIENV",;
					"BA1_ULTENV"	,	"BA1_CODERR"	,	"BA1_DATALT"	,	"BA1_FAICOB",;	
					"BA1_TIPINC"	,	"BA1_TRADES"	,	"BA1_TRAORI"	,	"BA1_LOTTRA",;	
					"BA1_BLOFAT"	,	"BA1_OBTSIP"	,	"BA1_MATEDI"	,	"BA1_ENVANS",;	
					"BA1_INCANS"	,	"BA1_EXCANS"	,	"BA1_MOTTRA"	,	"BA1_COBNIV",;
					"BA1_CODCLI"	,	"BA1_LOJA"		,	"BA1_VENCTO"	,	"BA1_CODFOR",;	
					"BA1_LOJFOR"	,	"BA1_NOMTIT"	,	"BA1_ORIEND"	,	"BA1_DTVLCE",;
					"BA1_PLPOR"		,	"BA1_CODCCO" }
	
	Case cAlias == "BA3"			
		aCampos:={	"BA3_VERCON"	,	"BA3_VERSUB"	,	"BA3_NUMCON"	,	"BA3_MATRIC",;
					"BA3_MATEMP"	,	"BA3_MATANT"	,	"BA3_HORACN"	,	"BA3_COBNIV",;
					"BA3_VENCTO"	,	"BA3_DATBAS"	,	"BA3_DATCIV"	,	"BA3_MESREA",;
					"BA3_INDREA"	,	"BA3_CODCLI"	,	"BA3_LOJA"		,	"BA3_TIPOUS",;
					"BA3_NATURE"	,	"BA3_CODFOR"	,	"BA3_LOJFOR"	,	"BA3_MOTBLO",;
					"BA3_DATBLO"	,	"BA3_CODPLA"	,	"BA3_VERSAO"	,	"BA3_FORPAG",;
					"BA3_TIPCON"	,	"BA3_SEGPLA"	,	"BA3_MODPAG"	,	"BA3_FORCTX",;
					"BA3_TXUSU"		,	"BA3_FORCOP"	,	"BA3_AGMTFU"	,	"BA3_APLEI"	,;
					"BA3_AGFTFU"	,	"BA3_VALSAL"	,	"BA3_ROTSAL"	,	"BA3_EQUIPE",;
					"BA3_CODVEN"	,	"BA3_ENDCOB"	,	"BA3_CEP"		,	"BA3_END"	,;
					"BA3_NUMERO"	,	"BA3_COMPLE"	,	"BA3_BAIRRO"	,	"BA3_CODMUN",;
					"BA3_MUN"		,	"BA3_ESTADO"	,	"BA3_USUOPE"	,	"BA3_DATCON",;
					"BA3_HORCON"	,	"BA3_GRPCOB"	,	"BA3_CODTDE"	,	"BA3_DESMUN",;
					"BA3_RGIMP"		,	"BA3_DEMITI"	,	"BA3_DATDEM"	,	"BA3_MOTDEM",;
					"BA3_LIMATE"	,	"BA3_ABRANG"	,	"BA3_INFCOB"	,	"BA3_INFGCB",;
					"BA3_IMPORT"	,	"BA3_VALANT"	,	"BA3_LETANT"	,	"BA3_DATALT",;
					"BA3_COBRAT"	,	"BA3_RATMAI"	,	"BA3_COBRET"	,	"BA3_DIARET",;
					"BA3_ULTCOB"	,	"BA3_RATSAI"	,	"BA3_NUMCOB"	,	"BA3_ULREA"	,;
					"BA3_CARIMP"	,	"BA3_PERMOV"	,	"BA3_NIVFOR"	,	"BA3_NIVFTX",;
					"BA3_NIVFOP"	,	"BA3_OUTLAN"	,	"BA3_MATFMB"	,	"BA3_CODACO",;
					"BA3_TRAORI"	,	"BA3_TRADES"	,	"BA3_ROTINA"	,	"BA3_VALID"	,;
					"BA3_DATPLA"	,	"BA3_DESLIG"	,	"BA3_DATDES"	,	"BA3_LOTTRA",;
					"BA3_BLOFAT"	,	"BA3_CODRDA"	,	"BA3_CODLAN"	,	"BA3_TIPPAG",;
					"BA3_BCOCLI"	,	"BA3_AGECLI"	,	"BA3_CTACLI"	,	"BA3_LIMITE",;
					"BA3_PORTAD"	,	"BA3_AGEDEP"	,	"BA3_CTACOR"	,	"BA3_DESMEN",;
					"BA3_CODVE2"	,	"BA3_CONSID"	,	"BA3_PADSAU"	,	"BA3_PLPOR"	,;
					"BA3_AGLUT"																 }
EndCase

Return(aCampos)

*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLD268 ºAutor  ³Totvs				 º Data ³ 23/12/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação da tela											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSVLD268(oGetB51,oGetB52,nOpc)
Local lRet := .T.                   
Local nI   := 0
Local aMsg := {}

If (nOpc == 3 .Or. nOpc == 4) 
	If M->B50_TPACAO $ "2"//Glosa  
		lRet := .F.
		For nI:= 1 To Len(oGetB51:aCols)
		 	If !oGetB51:aCols[nI,Len(oGetB51:aHeader)+1] .And.;
		 		!EMPTY(oGetB51:aCols[nI,PLRETPOS("B51_CODCRI",oGetB51:aHeader)])
		 	    lRet := .T. 
		 	    Exit
		 	Endif
	   	Next nI
		If !lRet
			aAdd(aMsg,STR0019) //"Deve ser Informada uma Glosa para este tipo de Ação!"
	   	Endif
	ElseIf M->B50_TPACAO == "1"
	  	For nI:= 1 To Len(oGetB51:aCols)
		 	If !oGetB51:aCols[nI,Len(oGetB51:aHeader)+1] .And.;
		 		!EMPTY(oGetB51:aCols[nI,PLRETPOS("B51_CODCRI",oGetB51:aHeader)])
		 	    lRet := .F. 
		 	    Exit
		 	Endif
	   	Next nI
		If !lRet 
		    aAdd(aMsg,STR0021) //"Para este Tipo de Ação nao deve existir Glosa cadastrada!"
	   	Endif
	ElseIf M->B50_TPACAO <> "3"
		aAdd(aMsg,STR0022)//"Deve ser Informado um tipo de Ação!" 
		lRet := .F.
	Endif
	
	lRet := .F.
	For nI:= 1 To Len(oGetB52:aCols)
	 	If !oGetB52:aCols[nI,Len(oGetB52:aHeader)+1]// .And.;
//	 		!EMPTY(oGetB52:aCols[nI,PLRETPOS("B52_RDADE",oGetB52:aHeader)])
	 	    lRet := .T. 
	 	    Exit
	 	Endif
	Next nI
	/*If !lRet 
		aAdd(aMsg,STR0020) //"Deve existir pelo menos uma Regra cadastrada!"
	Endif*/
	  	
	If Len(aMsg) > 0
		lRet:= .F.
		For nI:= 1 To Len(aMsg)
			MsgStop(aMsg[nI]) 
		Next nI
	Endif	   	

Endif

Return lRet