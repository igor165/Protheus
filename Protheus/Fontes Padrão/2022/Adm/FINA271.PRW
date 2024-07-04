#INCLUDE 	"PROTHEUS.CH"  
#INCLUDE	"FINA271.CH"

#DEFINE CONTA_INCLUI       1
#DEFINE CONTA_ALTERA       2
#DEFINE CONTA_EXCLUI       3
#DEFINE CONTA_OK           4
#DEFINE CONTA_CANCELA      5
#DEFINE CONTA_PESQUISA     6
#DEFINE CONTA_IMPORTA      7
#DEFINE CONTA_REFRESH      8
#DEFINE CONTA_COPIA        9
#DEFINE CONTA_COLA        10
#DEFINE VISAO_ALTERA      11
#DEFINE VISAO_CANCELA     12
#DEFINE VISAO_OK          13
#DEFINE GETD_ALTERA       14
#DEFINE GETD_OK           15
#DEFINE GETD_CANCELA      16
#DEFINE GETDADOS          17
#DEFINE CONTA_ALTERA2     18
#DEFINE VISAO_ALTERA2     19

#Define CONTA_OPERACOES   19

#DEFINE AHIDESHOW {4,5,12,13,15,16,17}   

#define IDX_SCREEN_WIDTH  1
#define IDX_SCREEN_HEIGHT 2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA271  ³ Autor ³ TOTVS		            ³ Data ³ 08/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastramento Plano Gerencial Financeiro                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA271()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINA271()

Private aRotina 	:= MenuDef()
Private aCVzo		:= {}
Private cCadastro 	:= STR0001 //"Cadastro Visao Gerencial Financeira"
Private cAliasBrw	:= ""
Private lTrvNome  	:= .T.

// Acesso somente pelo SIGAFIN
If ( !AMIIn(06) )		
	Return
EndIf  

DbSelectArea("FJ1")
DbSelectArea("FJ2")
DbSelectArea("FJ3")

If !FinaCheck()
	Return .F.
Endif  

DbSelectArea("FJ1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						³
//³ mv_par01		// Incrementa na inclusao de n em n      	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetKey(VK_F12,{|a,b|AcessaPerg("FIN271",.T.)})

Pergunte("FIN271",.F.)

cAliasBrw := "FJ1"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1, 22, 75, cAliasBrw )

dbSetOrder(1)
SET KEY VK_F12 to

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ TOTVS			        ³ Data ³ 01/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastramento Plano Gerencial                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := { 	{ STR0004,"AxPesqui"					, 0 , 1},;  // // //"Pesquisar"
						{ STR0005,"Fin271Cad(,, 2, .F. )"	, 0 , 2},;  // // //"Visualizar"
						{ STR0006,"Fin271Inc"				, 0 , 3},;  // // //"Incluir"
						{ STR0007,"Fin271Cad(,, 4, .F. )"	, 0 , 4},;  // // //"Alterar"
						{ STR0008,"Fin271Alt"				, 0 , 4},;  // // //"Alterar Cadastro"
						{ STR0009,"Fin271Exc"				, 0 , 5} }  // // //"Excluir" 

Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fin271Inc ³ Autor ³ TOTVS		            ³ Data ³ 01/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusao de nova Visao Gerencial                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Fin271Inc(cAlias,nReg,nOpc) 
Private nRecFJ1 := 0

If !FinaCheck()
	Return .F.
Endif	

dbSelectArea("FJ1")
If	AxInclui(Alias(),FJ1->(Recno()),3,/*aAcho*/,/*cFunc*/,/*aCpos*/,/*cTudoOk*/,/*lF3*/,"Fa271GRV"/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/) == 1
	//posicionar no registro da tabela  incluido neste momento
	dbGoto(nRecFJ1)
	
	Fin271Cad( "FJ1", FJ1->( Recno() ), 4, .T. )
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fin271Alt ³ Autor ³ Totvs                 ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera o cadastro da visao gerencial                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin271Alt() 

Local cFJ1_Descri

	Fa271Pos()
	cFJ1_Descri := FJ1->FJ1_DESCRI
	AxAltera( "FJ1", FJ1->( RecNo() ), 4 )

	If cFJ1_Descri != FJ1->FJ1_DESCRI
		//se for modificado a descricao deve alterar todos os registros da tabela FJ3 - campo FJ3_NOME
		dbSelectArea("FJ3")
		dbSetOrder(1)
		dbSeek(xFilial("FJ3")+FJ1->FJ1_CODIGO)
		While FJ3->(! Eof() .And. FJ3_FILIAL+FJ3_CODPLA == xFilial("FJ3")+FJ1->FJ1_CODIGO)
		
			RecLock("FJ3", .F.)
			FJ3->FJ3_NOME := FJ1->FJ1_DESCRI
			MsUnLock()
			
			FJ3->(dbSkip())
			
		EndDo

		//posicionar novamente, pois o FJ3 ficou desposicionado 
		Fa271Pos()

	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fin271Cad ³ Autor ³ TOTVS		            ³ Data ³ 01/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Visao Gerencial                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Fin271Cad(cAlias,nReg,nOpc,lInclusao ) 

Local nWStage 		:= GetScreenRes()[IDX_SCREEN_WIDTH] - 65
Local nHStage 		:= GetScreenRes()[IDX_SCREEN_HEIGHT] - 255



Local oGetFJ2
Local oTREEFJ2
Local aObjects	:=	{}

Local nPosLin 	:= 0      
Local bWhenGetD	:=	{|| ALTERAGD .And. !M->FJ2_NEGRIT .And. !M->FJ2_TRACO .And. !M->FJ2_SEPARA .And. !( M->FJ2_CLASSE == '1' .And. !M->FJ2_TOTAL) }
Local oMenuPop
Local nX
Local lErro := .F.
Local aAuxHead := ""

Private oArea
Private aTELA[0][0]
Private aTELAFJ2[0][0]
Private aGETS[0]
Private n
Private cCopiaRef	:=	""

Default lInclusao	:= .F.

For nX := 1 To CONTA_OPERACOES
	AAdd(aObjects, { Nil , Nil, Array(CONTA_OPERACOES) } )
Next

If !FinaCheck()
	Return .F.
Endif	

Private INCLUI		:=	.F.
Private ALTERA		:=	.F.
Private ALTERAGD	:=	.F.
Private EXCLUI		:=	.F.
Private aEmptyCols	:= {}
Private aHeader
Private aCols
Private lLastFJ1	:=	.T.
Private nPop1:=0
Private nPop2:=150
Private lInRefresh	:=	.F.
Private cCadastro 	:= STR0010 //"Visoes Gerenciais"


If nOpc == 4 .And. !SoftLock('FJ1')
	Return
Endif
		
If nOpc <> 3 .AND. !lInclusao
	Fa271Pos()
EndIf
		
If ! Fa271ChkInc()  
	Fa271Pos()
EndIf

//CODIGO PAI PARA CRIACAO DA ARVORE

//"Visao Gerencial"
oArea := FWArea():New( 000, 000, nWStage, nHStage,, 1, STR0011 )//"Visão Gerencial"

// Cria a borda envolta de toda aplicação
oArea	:CreateBorder ( 3 )

// altera a fonte
SetFont("FW Microsiga")

//Inicio layout Tree
oArea	 	:AddSideBar ( 35, 1, "ArvoreFJ2")
oSideBar	:= oArea:GetSideBar ( "ArvoreFJ2" )

oArea		:AddWindow ( 100, CtbGetHeight(100), "P_SideBar", STR0011, 1 , 1, oSideBar) //"Visão Gerencial"
oArea		:AddPanel  ( 100, 100, "P_SideBar",CONTROL_ALIGN_ALLCLIENT )
oPSideBar	:= oArea:GetPanel ( "P_SideBar" )

//------------------------------------------------------------------------------------------//
//CRIACAO DA ARVORE
//------------------------------------------------------------------------------------------//
oTreeFJ2:= Xtree():New(000,000,000,000, oPSideBar)

//alinha para tomar toda a tela do PainelSideBar e cria no principal
oTreeFJ2:Align := CONTROL_ALIGN_ALLCLIENT
oTreeFJ2:bChange := {|x1,x2,x3| If(!lInRefresh,PosicionaFJ2(x1,x2,x3,,oArea,oGetFJ1,oGetFJ2,oGet),NIL)}	
oTreeFJ2:bValid := {|| !INCLUI .and. !ALTERA.and. !ALTERAGD .and.!EXCLUI }
oTreeFJ2:bWhen  := {|| !INCLUI .and. !ALTERA .and. !ALTERAGD .and.!EXCLUI }	
oTreeFJ2:AddTree (FJ1->FJ1_DESCRI, "folder516","FOLDER616", 'ID_PRINCIPAL',/*{|| MsgStop('xxx')}*/,/*bRClick*/, { || AddTreeFJ2(oTreeFJ2,,,@lErro) })

AddTreeFJ2(oTreeFJ2,,,@lErro)

oTreeFJ2:EndTree()

If lErro  // se ocorrer erro na montagem da estrutura entao muda para modo de visualizar
	nOpc := 2
EndIf

If nOpc <> 2
	oTreeFJ2:BrClicked	:= {|x,y,z| TreeMenupop(oSideBar,oMenuPop,oTreeFJ2,x,y,z) }
	MENU oMenuPop POPUP																		
		MENUITEM STR0006 	ACTION Eval( oBtBarTree[2]:bAction) RESOURCE  'BMPINCLUIR' //"Incluir"
		MENUITEM STR0007 	ACTION Eval(oBtBarTree[3]:bAction) RESOURCE  'NOTE' 		//"Alterar"
		MENUITEM STR0009 	ACTION Eval(oBtBarTree[4]:bAction) RESOURCE  'EXCLUIR' 		//"Excluir"
	ENDMENU            
Endif

//Botoes layoute tree
If nOpc <> 2
	oBarTree  :=	{	{"RELOAD.PNG","BMPINCLUIR","NOTE","EXCLUIR"},;
						{	{|| SetStatusVis(aObjects,CONTA_REFRESH,2), oTreeFJ2	:=	RefreshTree(oTreeFJ2,oPSideBar,,,,,oGetFJ1,oGetFJ2,oGet)},;
							{|| SetStatusVis(aObjects,CONTA_INCLUI,2),		oArea:ShowLayout ( STR0028 ), oGetFJ2	:=	CNManutCONTA("FJ2",,3,oTreeFJ2,oGetFJ2,oPanelAll,aObjects,oGet,oArea)},; //"ANALITICA"
                 			{|| IIf (oTreeFJ2:GetCargo()=="ID_PRINCIPAL",;
	   	             			Nil ,;					
   	   	          				( SetStatusVis(aObjects,CONTA_ALTERA2,2),oArea:ShowLayout ( STR0028 ), oGetFJ2	:=	CNManutCONTA("FJ2",,4,oTreeFJ2,oGetFJ2,oPanelAll,aObjects,oGet,oArea) ) ;   //"ANALITICA"
   	   	          				) },;
                			{|| iiF(oTreeFJ2:GetCargo()=="ID_PRINCIPAL",nIL,(SetStatusVis(aObjects,CONTA_EXCLUI,2),oGetFJ2:=CNManutCONTA("FJ2",,5,oTreeFJ2,oGetFJ2,oPanelAll,aObjects,oGet,oArea)) )},;
                		},; 
					 	{STR0012,STR0006,STR0007,STR0009} }  //"Refresh"###"Incluir"###"Alterar"###"Excluir"###"Sair"
   	oArea:AddButtonBar( oBarTree )
   	oBtBarTree   :=	oArea:GetButtonBar("P_SideBar")
	DefineStatus(oBtBarTree[1],aObjects,CONTA_REFRESH,2)		
	DefineStatus(oBtBarTree[2],aObjects,CONTA_INCLUI,2)		
	DefineStatus(oBtBarTree[3],aObjects,CONTA_ALTERA2,2)		
	DefineStatus(oBtBarTree[3],aObjects,VISAO_ALTERA2,2)		
	DefineStatus(oBtBarTree[4],aObjects,CONTA_EXCLUI,2)		
	DefineStatus(oBtBarTree[1],aObjects,CONTA_REFRESH,1)		
	DefineStatus(oBtBarTree[2],aObjects,CONTA_INCLUI,1)		
	DefineStatus(oBtBarTree[3],aObjects,CONTA_ALTERA2,1)		
	DefineStatus(oBtBarTree[3],aObjects,VISAO_ALTERA2,1)		
	DefineStatus(oBtBarTree[4],aObjects,CONTA_EXCLUI,1)		
Else
	oBarTree  :=	{{"RELOAD.PNG"},;
    				{{|| SetStatusVis(aObjects,CONTA_REFRESH,2)} },; 
					 {"Refresh"} }  
    oArea:AddButtonBar( oBarTree )
    oBtBarTree   :=	oArea:GetButtonBar("P_SideBar")
	DefineStatus(oBtBarTree[1],aObjects,CONTA_REFRESH,2)		
Endif

//Inicio Layout 
oArea    	:AddLayout ( "VISAOFJ1" )  
oVISAOFJ1	:= oArea:GetLayout ( "VISAOFJ1" )
oPanelCapa	:= oArea:GetPanel ( "VISAOFJ1" )

oArea		:AddWindow ( 100, CtbGetHeight(100), "VISAOFJ1", STR0011 , 2, 2,oVISAOFJ1) //"Visão Gerencial"
oArea		:AddPanel  ( 100, 100, "VISAOFJ1" )
oPanelCapa	:= oArea:GetPanel ( "VISAOFJ1" )

DbSelectArea("FJ1")
RegToMemory("FJ1",.F.,,,FunName())
oGetFJ1:= MsMGet():New("FJ1", FJ1->(RecNo()),2,,,,,{0,0,290,252},,,,,,oPanelCapa,,,,,,.T.)
oGetFJ1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oArea    	:AddLayout ( STR0028 )//"ANALITICA"
oAnalitica	:= oArea:GetLayout ( STR0028 ) //"ANALITICA"

oArea:AddWindow ( 100, CtbGetHeight(50), "CONTA_A", STR0013 , 3, 4,oAnalitica) //"Conta"
oArea:AddPanel  ( 100,100, "EnchoiceA",CONTROL_ALIGN_ALLCLIENT )                                   
oPanelAll		:= oArea:GetPanel ( "EnchoiceA" )
oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT

oArea :SetTiTleWindow ( "CONTA_A", STR0014 ) //"Conta Gerencial"

If nOpc <> 2
	//Inicio botoes ANALITICA
	aButtonBar  := {{"NOTE.PNG"},;
	{ ;
	{|| oGetFJ2	:= CNManutCONTA("FJ2",,4,oTreeFJ2,oGetFJ2,oPanelAll,aObjects,oGet,oArea) };
	},;
	{ STR0007 } } //"Alterar"
	oArea                    :AddButtonBar ( aButtonBar )
	oBtBar    := oArea:GetButtonBar ("EnchoiceA")
	
	DefineStatusVis(oBtBar[1],aObjects,CONTA_ALTERA,2)
	
	aButtons  := {  { STR0015 , STR0016 },; //"CANCELAR"###"CONFIRMAR"
	{ ;
	{|| SetStatusVis(aObjects,CONTA_CANCELA,2),oGetFJ2 	:= 	CancOperVis(oTreeFJ2,oGetFJ2,oPanelAll,aObjects)},;
	{|| SetStatusVis(aObjects,CONTA_OK,2)     ,oGetFJ2	:=	ConfOperVis(oTreeFJ2,oGetFJ2,oPanelAll,aObjects) , PosicionaFJ2(oTreeFJ2,,,,oArea,oGetFJ1,oGetFJ2,oGet) };
	} ,;
	{ STR0017,STR0018 } } //"Cancelar"###"Confirmar"
	oArea:AddTextButton ( aButtons )
	oBtText := oArea:GetTextButton ("EnchoiceA")
	oBtnEscSint  := oBtText[1]
	oBtnConfSint := oBtText[2]
	oBtText[1]:Hide()
	oBtText[2]:Hide()
	DefineStatusVis(oBtText[1],aObjects,CONTA_OK,2)
	DefineStatusVis(oBtText[2],aObjects,CONTA_CANCELA,2)
	
Endif


oArea:AddWindow ( 100, CtbGetHeight(50), "GETDADOS", STR0019 , 4, 3,oAnalitica	) //"Composicao da Conta"###"Composicao da Conta"
oArea:AddPanel  ( 100, 100, "GetDados" )

oPanel_3		:= oArea:GetPanel ( "GetDados" )
If nOpc <> 2
	//Inicio botoes GETDADOS
	aButtonBar  := {{"NOTE.PNG"},;
	{ ;
	{|| FaMntGetd(oGet,oTreeFJ2,aObjects)};
	},;
	{ STR0007 } } //"Alterar"
	oArea                    :AddButtonBar ( aButtonBar )
	oBtBar                   := oArea:GetButtonBar ("GetDados")
	
	DefineStatusVis(oBtBar[1],aObjects,GETD_ALTERA,2)
	
	aButtons  := {  {STR0015,STR0016},; //"CANCELAR"###"CONFIRMAR"
	{ ;
	{|| SetStatusVis(aObjects,GETD_CANCELA,2),CancGDVis(oTreeFJ2,oGet  )},;
	{|| Iif(Fa271GOk(oGet), (SetStatusVis(aObjects,GETD_OK,2)     ,ConfGDVis( oGet  )),Nil)};   
	} ,;
	{STR0017,STR0018} } //"Cancelar"###"Confirmar"
	oArea:AddTextButton ( aButtons )
	oBtText := oArea:GetTextButton ("GetDados")
	oBtnConfSint := oBtText[1]
	oBtnEscSint  := oBtText[2]
	oBtText[1]:Hide()
	oBtText[2]:Hide()
	DefineStatusVis(oBtText[1],aObjects,GETD_CANCELA,2)
	DefineStatusVis(oBtText[2],aObjects,GETD_OK,2)
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da enchoice do FJ2                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("FJ2")
dbSetOrder(1)
RegToMemory("FJ2",.F.,,,FunName())                                       
oGetFJ2:= MsMGet():New("FJ2", FJ2->(RecNo()),2,,,,,{oPanelAll:nTop,oPanelAll:nLeft,oPanelAll:nHeight,oPanelAll:nWidth/2.5},,,,,,oPanelAll,,,,,,.T.)
oGetFJ2:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//Cria GetDados da visao gerencial
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do FJ3                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("FJ3")
dbSetOrder(1)  
aHeader := GetaHeader("FJ3",      ,{"FJ3_CODPLA","FJ3_ORDEM","FJ3_CONTAG","FJ3_CTASUP","FJ3_NOME  ","FJ3_IDENTI"},{},,.F.)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processo para exibir os campos das novas entidades apos os campos das entidades padroes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAuxHead := GetaHeader("FJ3",{"FJ3_IDENTI"},,{},,.F.)

aEval(aAuxHead, {|x|aAdd(aHeader, x)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do FJ3                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:=	Array(1,Len(aHeader)+1)
For nX:=1 To Len(aHeader)
	aCols[1][nX]	:=	CriaVar(aHeader[nX,2],.T.)
Next                                        
aCols[1,nX]	:=	.F.
nPosLin 	:= ASCAN(aHeader,{|x| Alltrim(x[2]) == "FJ3_LINHA"})
aCols[1,nPosLin] := StrZero(1,Len(FJ3->FJ3_LINHA))
aEmptyCols := aClone(aCols)

oGet:= MsNewGetDados():New(0,0,50,70,GD_INSERT+GD_DELETE+GD_UPDATE,"Fa271LOK","Fa271GOk","+FJ3_LINHA/FJ3_IDENTI",,,9999,,,,oPanel_3,aHeader,aCols)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet:Disable()


oArea		:ShowLayout ( "VISAOFJ1" )
oArea	 	:ActDialog ()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TreeMenupop³Autor ³ TOTVS			        ³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao para criacao do popmenu da arvore                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TreeMenupop(oDlg,oMenu,oTree,x,y,z) 
nZ:=y-nPop1
nK:= z-nPop2
oMenu:Activate(nz,nk,oDlg)
Return                                                                                        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AddTreeFJ2ºAutor  ³TOTVS				 º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a arvore com base em um nodo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddTreeFJ2(oTreeFJ2,cPai,lRefresh,lErro)
Local aArea	:=	GetArea()
Local lDETHCG := FJ2->(FIELDPOS("FJ2_DETHCG")) > 0
DEFAULT lRefresh	:=	.F.
DEFAULT lErro	:=	.F.
DEFAULT cPai	:=	Criavar('FJ2_CTASUP',.F.)
If mv_par05 == 1
	If	aSCAN(oTreeFJ2:aNodes,{|x| x[1]==oTreeFJ2:CurrentNodeID  })  == 0 
		DbSelectArea("FJ2")     
		DbSetOrder(2)
		
		If DbSeek(xFilial()+FJ1->FJ1_CODIGO+cPai)
			While ! FJ2->(EOF()).And. xFilial()+FJ1->FJ1_CODIGO+cPai == FJ2_FILIAL+FJ2_CODIGO+FJ2_CTASUP
				// Impede erro de estrutura no objeto(TDbtree)
			    IF FJ2->FJ2_CLASSE == "2" .And. Empty(ALLTRIM(FJ2->FJ2_CTASUP))
					Aviso(STR0020,	STR0021+CRLF+;  //"Atencao"###"Inconsistencia na estrutura da visão gerencial. "
								   	STR0022+CRLF+; //"Verifique hierarquia e a classificação das contas gerenciais." 
								   	STR0023+": "+FJ2->FJ2_CONTAG+; //"Conta Gerencial"
								   	STR0024+": "+FJ2->FJ2_CTASUP+CRLF+;  //"Conta Superior"
								   	STR0025+" " +FJ2->FJ2_CLASSE+"-"+If(FJ2->FJ2_CLASSE=="1", STR0026, STR0027), {"Ok"})   //"Classe"###"Sintetica"###"Analitica"
					lErro := .T.										
					EXIT
		        ENDIF

			    IF FJ2->FJ2_CLASSE == "1"
					If Empty(ALLTRIM(FJ2->FJ2_CTASUP) ) .And. !lRefresh
						oTreeFJ2:AddTree ( Alltrim(FJ2->FJ2_CONTAG)+'-'+AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),  "folder516","FOLDER616" ,	FJ2->FJ2_CONTAG)	
						oTreeFJ2:EndTree()
			    	Else
					    oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG)+'-'+AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG,"folder516","FOLDER616",2,)
					Endif
			  	ELSE
			 		oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG) + ' - ' +AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))), FJ2->FJ2_CONTAG,"BMPVISUAL16","BMPVISUAL16",2,)	
				Endif
				FJ2->(DBSKIP())
			EndDo
		EndIf
	EndIf
Else
	DbSelectArea("FJ2")     
	DbSetOrder(4)
	DbSeek(xFilial()+FJ1->FJ1_CODIGO)
	While ! FJ2->(EOF()).And. xFilial()+FJ1->FJ1_CODIGO == FJ2_FILIAL+FJ2_CODIGO
		If FJ2->FJ2_IDENT == '4' //TOtal
			cBitMap:= 'COLTOT16'
		ElseIf FJ2->FJ2_IDENT = '5' .And. Alltrim(FJ2->FJ2_DESCCG) == "-"   //traco
			cBitMap:= 'PMSTASK116'
		ElseIf ( FJ2->FJ2_IDENT = '5' .Or. FJ2->FJ2_IDENT = '6' ) .And. Alltrim(FJ2->FJ2_DESCCG) <> "-" //Separador 
			cBitMap:= 'PMSTASK316'
		Else                                                                         
		    IF FJ2_CLASSE == "1"                                                  
				cBitMap:= "SDUSUM16"       
			Else
				cBitMap:= "BMPVISUAL16"			    
			Endif
		Endif
		oTreeFJ2:AddTree ( Alltrim(FJ2->FJ2_CONTAG)+'-'+AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),  cBitMap,cBitMap ,FJ2->FJ2_CONTAG)	
		oTreeFJ2:EndTree()
		FJ2->(DBSKIP())
	EndDo
Endif
REstArea(aArea)
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PosicionaFJ2ºAutor³TOTVS				 º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por atualziar os dados quando se navega  º±±
±±º          ³na arvore                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PosicionaFJ2(oTreeFJ2,x2,x3,cCodigo,oArea,oGetFJ1,oGetFJ2,oGetD)
Local cCodigoAnt	:=	"" 
Local nX                              
Local lDETHCG := FJ2->(FIELDPOS("FJ2_DETHCG")) > 0
Default cCodigo:= oTreeFJ2:GetCargo() 
cCodigoAnt	:=	FJ2->FJ2_CONTAG
lSintAnt	:=	!lLastFJ1	.And. (FJ2->FJ2_CLASSE == "1")
If !Empty( cCodigo ) .AND. cCodigo <> 'ID_PRINCIPAL'
	lLastFJ1	:=	.F.
	dbSelectArea("FJ2")     
	dbSetOrder(1)                                  
	dbSeek(xFilial()+FJ1->FJ1_CODIGO+cCodigo)

	RegToMemory("FJ2",.F.,,,FunName())                                       
	
	aCols	:=	{}
	DbSelectArea('FJ3')
	DbSetOrder(1)
	DbSeek(xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_ORDEM)
	While xFilial("FJ3")+FJ3->FJ3_CODPLA+FJ3->FJ3_ORDEM ==	xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_ORDEM
		If FJ3->FJ3_CLASSE != "1" .OR. M->FJ2_TOTAL
			AAdd(aCols, Array(Len(aHeader)+1))
			For nX:=1 To Len(aHeader)
				If aHeader[nX,10] =="V"
					aCols[Len(aCols)][nX]	:=	CriaVar(aHeader[nX][2],.T.)
				Else
					aCols[Len(aCols)][nX]	:=	FieldGet(FieldPos(aHeader[nX,2]))				
				Endif
			Next
			aCols[Len(aCols)][nX]	:=	.F.
		EndIf
		DbSkip()	
	Enddo     
	If Len(aCols) > 0
		oGetD:aCols	:=	aClone(aCols)  
	Else
		oGetD:aCols	:=	aClone(aEmptyCols)  		
	Endif                      
	DbSelectArea("FJ2")  

	If MV_PAR05 == 2      
		aAreaFJ2	:=	FJ2->(GetArea())		//Restaurar Bitmaps
		If !Empty(cCodigoAnt) .And. lSintAnt
			FJ2->(DbSetOrder(2))
			FJ2->(DbSeek(xFilial()+FJ1->FJ1_CODIGO+cCodigoAnt))
			While xFilial('FJ2')+FJ1->FJ1_CODIGO+cCodigoAnt == FJ2->(FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP)
				oTreeFJ2:ChangePrompt(Alltrim(FJ2->FJ2_CONTAG) + ' - ' + AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG)
				FJ2->(DbSkip())
			Enddo
		Endif    	
		If M->FJ2_CLASSE == "1"
			FJ2->(DbSeek(xFilial()+FJ1->FJ1_CODIGO+M->FJ2_CONTAG))
			FJ2->(DbSetOrder(2))
			FJ2->(DbSeek(xFilial()+FJ1->FJ1_CODIGO+M->FJ2_CONTAG))
			While xFilial('FJ2')+FJ1->FJ1_CODIGO+M->FJ2_CONTAG == FJ2->(FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP)
				oTreeFJ2:ChangePrompt('**'+Alltrim(FJ2->FJ2_CONTAG) + ' - ' + Alltrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,"")))+"**",FJ2->FJ2_CONTAG)
				FJ2->(DbSkip())
			Enddo
		Endif
		RestArea(aAreaFJ2)
	Else
		If M->FJ2_CLASSE == "1"
			AddTreeFJ2(oTreeFJ2,M->FJ2_CONTAG)
		Endif
	Endif
	oGetD:oBrowse:Refresh()
Else
	lLastFJ1	:=	.T.
	If MV_PAR05 == 2      
		aAreaFJ2	:=	FJ2->(GetArea())		//Restaurar Bitmaps
		If !Empty(cCodigoAnt) .And. lSintAnt
			FJ2->(DbSetOrder(2))
			FJ2->(DbSeek(xFilial()+FJ1->FJ1_CODIGO+cCodigoAnt))
			While xFilial('FJ2')+FJ1->FJ1_CODIGO+cCodigoAnt == FJ2->(FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP)
				oTreeFJ2:ChangePrompt(Alltrim(FJ2->FJ2_CONTAG) + ' - ' + AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG)
				FJ2->(DbSkip())
			Enddo
		Else
			FJ2->(DbSetOrder(2))
			FJ2->(DbSeek(xFilial()+FJ1->FJ1_CODIGO))
			While xFilial('FJ2')+FJ1->FJ1_CODIGO == FJ2->(FJ2_FILIAL+FJ2->FJ2_CODIGO)
				oTreeFJ2:ChangePrompt(Alltrim(FJ2->FJ2_CONTAG) + ' - ' + AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG)
				FJ2->(DbSkip())
			Enddo
		Endif    	
	Endif
Endif
If ValType(oArea) == 'O'
	If cCodigo == 'ID_PRINCIPAL'
		DbSelectArea("FJ1")
		oArea:ShowLayout ( "VISAOFJ1" )
		If ValType(oGetFJ1) == 'O'
			oGetFJ1:EnchRefreshAll()
		EndIf
	Else
		DbSelectArea("FJ2")
		oArea:ShowLayout ( STR0028 ) //ANALITICA
		If ValType(oGetFJ2) == 'O'
			oGetFJ2:EnchRefreshAll()
		EndIf
	EndIf
EndIf             


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNManutCONTAºAutor³TOTVS			     º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manutencao da tabe;a FJ2                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CNManutCONTA(cAlias,nReg,nOpc,oTree,oGetFJ2,oVisao, aObjects,oGetD,oArea)
Local lOk	:=	.F.
Local oNewGetFJ2
Local nTop		:= oGetFJ2:oBox:nTop-12 
Local nBottom	:= oGetFJ2:oBox:nBottom	
Local nLeft		:= oGetFJ2:oBox:nLeft
Local nRight	:= oGetFJ2:oBox:nRight      
Local cCargo	:= oTree:GetCargo()
Local cOrdem	:= ""
Local aFather 	:=	{}
Local nOpcao	:=	0
Local cSeek		:= 'ID_PRINCIPAL'

IF nOpc == 3
	lOK		:=	.T.
	INCLUI	:=	.T.
	ALTERA	:=	.F.
	EXCLUI	:=	.F.
	cOrdem	:=	GetNextOrdem()
	oGetFJ2:oBox:FreeChildren()
	
	RegToMemory("FJ2",.T.,,,FunName())
	M->FJ2_ORDEM  := cOrdem	
	M->FJ2_CONTAG := Fa271Prox( .T. )
	M->FJ2_FILIAL := xFilial()
    If cCargo == "ID_PRINCIPAL"
		M->FJ2_CTASUP := Space(Len(FJ2->FJ2_CTASUP))
	Else
		M->FJ2_CTASUP := cCargo	
	Endif

	oNewGetFJ2:= MsMGet():New("FJ2",/*->(RecNo())*/,3,,,,,{oVisao:nTop,oVisao:nLeft,oVisao:nHeight,oVisao:nWidth/2.5},,4,,,,oVisao,,,.F.,"aTelaFJ2")	

	M->FJ2_CODIGO := FJ1->FJ1_CODIGO 

	
	oArea:ShowLayout ( STR0028 ) //"ANALITICA"

	oNewGetFJ2:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	oArea :SetTiTleWindow ( "CONTA_A", STR0029 ) //"Visao Gerencial - Inclusao"

	oGetD:aCols	:=	aClone(aEmptyCols) 
	oGetD:oBrowse:Refresh()	                                         
	
ElseIf nOpc == 4
   	DbSelectArea('FJ2')
   	DbSetOrder(1)
   	DbSeek(xFilial()+FJ1->FJ1_CODIGO+cCargo)
	If SoftLock('FJ2')
		lOK		:=	.T.
		INCLUI	:=	.F.
		ALTERA	:=	.T.
		EXCLUI	:=	.F.
		oGetFJ2:oBox:FreeChildren()
	
		RegToMemory("FJ2",.F.,,,FunName())
		
		oArea :SetTiTleWindow ( "CONTA_A", STR0030 )	//"Visao Gerencial - Alteracao"
		oNewGetFJ2:= MsMGet():New("FJ2", FJ2->(RecNo()),4,,,,,{oVisao:nTop,oVisao:nLeft,oVisao:nHeight,oVisao:nWidth/2.5},,4,,,,oVisao,,,.F.,"aTelaFJ2")
	
		oArea:ShowLayout(STR0028) //"ANALITICA"
	
		oNewGetFJ2:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		SetStatusVis(aObjects,CONTA_ALTERA,2)
		SetStatusVis(aObjects,CONTA_ALTERA2,2)		
	Else
			MsgStop(STR0031) //"Nao pode ser lockado"
	Endif
	
ElseIf nOpc == 5 //Exclusao
   	DbSelectArea('FJ2')
   	DbSetOrder(1)
   	DbSeek(xFilial()+FJ1->FJ1_CODIGO+cCargo)
	If SoftLock('FJ2')
		INCLUI	:=	.F.
		ALTERA	:=	.F.
		EXCLUI	:=	.T.
		nOpcao := 0
		If FJ2->FJ2_CLASSE == "2"				
			nOpcao := Aviso(STR0033,STR0034,{"Ok",STR0032}) //"Confirmacao"###"Confirma exclusao da conta gerencial"###"Cancela"
		Else
			nOpcao := Aviso(STR0033,STR0035,{"Ok",STR0032}) //"Confirmacao"###"Confirma exclusao da conta gerencial (serao excluidas todas as contas dependentes)."###"Cancela"
    	Endif
		
		If nOpcao == 1
			Begin Transaction	
			If FJ2->FJ2_CLASSE == "2"
				DbSelectArea('FJ3')
				DbSetOrder(2)
				DbSeek(xFilial()+FJ2->FJ2_CODIGO+FJ2->FJ2_CONTAG)
				While !Eof() .And. xFilial()+FJ2->FJ2_CODIGO+FJ2->FJ2_CONTAG == FJ3_FILIAL+FJ3_CODPLA+FJ3->FJ3_CONTAG
					RecLock('FJ3',.F.)
					DbDelete()
					MsUnLock()
					DbSkip()                                		
               	Enddo
				
				If Empty(FJ2->FJ2_CTASUP)
					cSeek	:= 'ID_PRINCIPAL'
				Else
					cSeek	:= FJ2->FJ2_CTASUP
				Endif
				RecLock('FJ2',.F.)
				DbDelete()
				MsUnLock()
				oTree:DelItem()              
	        ElseIf FJ2->FJ2_CLASSE == "1"
	        	cChave	:=	xFilial('FJ2')+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP
				DbSelectArea('FJ3')
				DbSetOrder(2)
				DbSeek(xFilial()+FJ2->FJ2_CODIGO+FJ2->FJ2_CONTAG)
				While !Eof() .And. xFilial()+FJ2->FJ2_CODIGO+FJ2->FJ2_CONTAG == FJ3_FILIAL+FJ3_CODPLA+FJ3->FJ3_CONTAG
					RecLock('FJ3',.F.)
					DbDelete()
					MsUnLock()
					DbSkip()                                		
               	Enddo                                                
               	aadd(aFather,FJ2->FJ2_CONTAG)
				If Empty(FJ2->FJ2_CTASUP)
					cSeek	:= 'ID_PRINCIPAL'
				Else
					cSeek	:= FJ2->FJ2_CTASUP
				Endif
				cFJ2Del	:=	FJ2->FJ2_CONTAG
				RecLock('FJ2',.F.)
				DbDelete()
				MsUnLock()
				lInRefresh	:=	.T.
				oTree:DelItem()              
				//Apagar os filhos
				While Len(aFather) > 0                            
					nX:=1
					DbSelectArea('FJ2')
					DbSetOrder(2)
					DbSeek(xFilial()+FJ2->FJ2_CODIGO+aFather[nX])
					While !Eof().And. xFilial()+FJ2->FJ2_CODIGO+aFather[nX]== FJ2->FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP
						DbSelectArea('FJ3')
						DbSetOrder(2)
						DbSeek(xFilial()+FJ2->FJ2_CODIGO+FJ2->FJ2_CONTAG)
						While !Eof() .And. xFilial()+FJ2->FJ2_CODIGO+FJ2->FJ2_CONTAG == FJ3_FILIAL+FJ3_CODPLA+FJ3->FJ3_CONTAG
							RecLock('FJ3',.F.)
							DbDelete()
							MsUnLock()
							DbSkip()                                		
	               		Enddo     
	               		//Carregar no a father os proximos pais
						If FJ2->FJ2_CLASSE == '1'
							AAdd(aFather,FJ2->FJ2_CONTAG)
						Endif                           
						//Se for nao estruturado, apaga o filho da arvore tb
						If mv_par05 == 2 .And. oTree:TreeSeek(FJ2->FJ2_CONTAG)
							nRecFJ2:=FJ2->(Recno())
							oTree:DelItem()              
			    			FJ2->(MsGoTo(nRecFJ2))
    						FJ2->(DbSetOrder(2)) //o TreeSeek muda a ordem do  no bChange
    					Endif
    					//Apaga o Nodo
						DbSelectArea('FJ2')
						RecLock('FJ2',.F.)
						DbDelete()
						MsUnLock()
						DbSkip()
					Enddo             
					//Apaga do aFather o que ja foi feito
               		aDel(aFather,nX)                    
               		aSize(aFather,Len(aFather)-1)
				EndDo
				lInRefresh	:=	.F.
	 		Endif

			End Transaction		
			oTree:TreeSeek(cSeek)
		Endif
		SetStatusVis(aObjects,CONTA_OK,2)
		EXCLUI	:=	.F.
	Else
		MsgStop(STR0031) //"Nao pode ser lockado"
	Endif
EndIf

Return If(lOk,oNewGetFJ2,oGetFJ2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConfOperVis Autor ³TOTVS			     º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirma edicao da tabela                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConfOperVis(oTreeFJ2,oGetFJ2,oPanel,aObjects)
Local lOk	:=	.F.
Local lRet  :=  .T.
Local oNewGetFJ2    
Local nTop		:= oGetFJ2:oBox:nTop-12 //O 12 eh o tamanho da toolbar 
Local nBottom	:= oGetFJ2:oBox:nBottom	
Local nLeft		:= oGetFJ2:oBox:nLeft
Local nRight	:= oGetFJ2:oBox:nRight
Local cCargo 	:= oTreeFJ2:GetCargo()
Local cTudoOk   := ""
Local lInclui	:=	INCLUI
Local nX
Local nI		
Local lDETHCG 	:= FJ2->(FIELDPOS("FJ2_DETHCG")) > 0

//VERIFICA SE EXISTE CARACTERES ESPECIAIS NA ENTIDADE GERENCIAL.
For nI:=1 to Len(FJ2->FJ2_CONTAG)
	If (ASC(Substr(M->FJ2_CONTAG,nI,1)) >= 33 .And. ASC(Substr(M->FJ2_CONTAG,nI,1)) <= 47) .Or.;
				(ASC(Substr(M->FJ2_CONTAG,nI,1)) >= 58 .And. ASC(Substr(M->FJ2_CONTAG,nI,1)) <= 64) .Or.;
				(ASC(Substr(M->FJ2_CONTAG,nI,1)) >= 91 .And. ASC(Substr(M->FJ2_CONTAG,nI,1)) <= 96) .Or.;
				(ASC(Substr(M->FJ2_CONTAG,nI,1)) >= 123 .And. ASC(Substr(M->FJ2_CONTAG,nI,1)) <= 126)
		MsgInfo(STR0036) //"A entidade gerencial possui caracteres invalidos. Sao caracteres validos apenas letras e numeros."
		lRet := .F.
		Exit
	EndIf
Next nI 

If lRet
	lRet := Fa61VlTot()
EndIf

//Bloco de código com a validação do usuário
If lRet
	If ExistBlock("Fa271TOK")
		xRet := ExecBlock("Fa271TOK",.F.,.F.)
		If ValType(xRet) == "L"
			lRet := xRet
		EndIf
	EndIf
EndIf

IF lRet
	If Obrigatorio(oGetFJ2:aGets,oGetFJ2:aTela)
		lOk	:=	.T.
		
		DbSelectArea('FJ2')
		RecLock('FJ2',INCLUI)
		For nX := 1 To FCount()
			FieldPut(nX,&("M->"+FieldName(nX)) )
		Next
		FJ2_IDENT	:=	" "   
        If M->FJ2_CLASSE != "2"
			If M->FJ2_NEGRIT .And. M->FJ2_SEPARA
				Replace FJ2_IDENT With "6"
			Else
				IF M->FJ2_NEGRIT
					Replace FJ2_IDENT With "3"
				ElseIf M->FJ2_SEPARA
					Replace FJ2_IDENT With "5"
				ElseIf M->FJ2_TRACO
					Replace FJ2_DESCCG With "-"
					Replace FJ2_IDENT  With "5"
				Endif
			Endif
		Endif

		MsUnLock()
		If INCLUI
			RecLock("FJ3",.T.)
			Replace FJ3_FILIAL	With xFilial()
			Replace FJ3_CODPLA	With FJ1->FJ1_CODIGO
			Replace FJ3_NOME   	With FJ1->FJ1_DESCRI
			Replace FJ3_ORDEM  	With FJ2->FJ2_ORDEM
			Replace FJ3_CONTAG	With FJ2->FJ2_CONTAG
			Replace FJ3_CTASUP	With FJ2->FJ2_CTASUP
			Replace FJ3_CLASSE	With FJ2->FJ2_CLASSE
			Replace FJ3_NORMAL	With FJ2->FJ2_NORMAL
			Replace FJ3_DESCCG	With FJ2->FJ2_DESCCG
			If lDETHCG
				Replace FJ3_DETHCG	With FJ2->FJ2_DETHCG
			EndIf
			Replace FJ3_COLUNA	With Val(FJ2->FJ2_COLUNA)
			Replace FJ3_LINHA	With StrZero(1,Len(FJ3->FJ3_LINHA))

			If FJ2->FJ2_CLASSE == "1"
				Replace FJ3_IDENT	WITH FJ2->FJ2_IDENT
			Else
				Replace FJ3_IDENT	WITH "1"
			EndIf

			Replace FJ3_TOTVIS With FJ2->FJ2_TOTVIS
	        Replace FJ3_VISENT With FJ2->FJ2_VISENT 
			Replace FJ3_SLDENT With FJ2->FJ2_SLDENT 
			Replace FJ3_FATSLD With FJ2->FJ2_FATSLD 
							
			MsUnLock()
	
		ELSE

			DbSelectArea('FJ3')
			DbSetOrder(2)
			DbSeek(xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_CONTAG)
			While FJ3->(! Eof() .And. FJ3_FILIAL+FJ3_CODPLA+FJ3_CONTAG==xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_CONTAG)
				RecLock("FJ3",.F.)
				Replace FJ3_ORDEM	With FJ2->FJ2_ORDEM                         //ATENCAO POIS EH PARTE DA CHAVE UNICA
				Replace FJ3_CTASUP	With FJ2->FJ2_CTASUP
				Replace FJ3_CLASSE	With FJ2->FJ2_CLASSE
				Replace FJ3_NORMAL	With FJ2->FJ2_NORMAL
				Replace FJ3_DESCCG	With FJ2->FJ2_DESCCG
				If lDETHCG
					Replace FJ3_DETHCG	With FJ2->FJ2_DETHCG
				EndIf
				Replace FJ3_COLUNA	With Val(FJ2->FJ2_COLUNA)

				If FJ2->FJ2_CLASSE == "1"
					Replace FJ3_IDENT	WITH FJ2->FJ2_IDENT
					Replace FJ3_SEDINI With ""
			   		Replace FJ3_SEDFIM With ""
				Else
					Replace FJ3_IDENT	WITH "1"
				EndIf
				
		       Replace FJ3_TOTVIS With FJ2->FJ2_TOTVIS
		       Replace FJ3_VISENT With FJ2->FJ2_VISENT 
		       Replace FJ3_SLDENT With FJ2->FJ2_SLDENT 
		       Replace FJ3_FATSLD With FJ2->FJ2_FATSLD 
			   
				MsUnLock()	
				FJ3->(Dbskip())
			EndDo
		Endif
		DbSelectArea('FJ2')
		oGetFJ2:oBox:FreeChildren()
		RegToMemory("FJ2",.F.,,,FunName())
		oNewGetFJ2:= MsMGet():New("FJ2", FJ2->(RecNo()),2,,,,,{oPanel:nTop,oPanel:nLeft,oPanel:nHeight,oPanel:nWidth/2.5},,2,,,,oPanel,,,.F.,"aTelaFJ2")
		oNewGetFJ2:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		
		//Mudar, deve ser recostruido todo o nodo para que inclua ordenado
		If lInclui
			IF FJ2->FJ2_CLASSE == "1"
				IF MV_PAR05 == 1
					If Empty(ALLTRIM(FJ2->FJ2_CTASUP) )
						oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG)+'-'+AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG,"folder516","folder616",2,)
					Else
						oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG)+'-'+AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG,"folder516","folder616",2,)
					Endif
				ELSE
					If Empty(ALLTRIM(FJ2->FJ2_CTASUP) )
						oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG)+'-'+AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG,"SDUSUM16","SDUSUM16",1,)
					Else
						oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG)+'-'+AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))),FJ2->FJ2_CONTAG,"SDUSUM16","SDUSUM16",1,)
					EndIf
				Endif
			ELSE
				IF MV_PAR05 == 1
					oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG) + ' - ' + AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))), FJ2->FJ2_CONTAG,"BMPVISUAL16","BMPVISUAL16",2,)
				Else
					oTreeFJ2:AddItem( Alltrim(FJ2->FJ2_CONTAG) + ' - ' + AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))), FJ2->FJ2_CONTAG,"BMPVISUAL16","BMPVISUAL16",1,)
				Endif
			Endif
			oTreeFJ2:TreeSeek(FJ2->FJ2_CONTAG)
		Else
			If FJ2->FJ2_IDENT == '4' //TOtal
				cBitMap:= 'COLTOT16'
			ElseIf FJ2->FJ2_IDENT = '5' .And. Alltrim(FJ2->FJ2_DESCCG) == "-" //traco
				cBitMap:= 'PMSTASK116'
			ElseIf ( FJ2->FJ2_IDENT = '5' .OR. FJ2->FJ2_IDENT = '5' ) .And. Alltrim(FJ2->FJ2_DESCCG) <> "-" //Separador
				cBitMap:= 'PMSTASK316'
			Else
				IF FJ2->FJ2_CLASSE == "1"
					cBitMap:= "SDUSUM16"
				Else
					cBitMap:= "BMPVISUAL16"
				Endif
			Endif
			oTreeFJ2:ChangeBmp(cBitMap,cBitMap,FJ2->FJ2_CONTAG)
			oTreeFJ2:ChangePrompt(AllTrim(FJ2->FJ2_CONTAG) + ' - ' + AllTrim(FJ2->(FJ2_DESCCG+IIF(lDETHCG,FJ2_DETHCG,""))) ,cCargo)
		Endif
	Endif
Endif


If lOk
	INCLUI	:=	.F.
	ALTERA	:=	.F.
	EXCLUI	:=	.F.
	If !lInclui
		cCtaSup	  := FJ2->FJ2_CTASUP
		cCodFJ2   := FJ2->FJ2_CODIGO
		cOrdem    := FJ2->FJ2_ORDEM
		RefreshTree(oTreeFJ2,oPsideBar,.T.,cCtaSup,cCodFJ2,cOrdem)
	EndIf
	oArea :SetTiTleWindow ( "CONTA_A", STR0023 ) //"Conta Gerencial"
Else
	SetStatusVis(aObjects,CONTA_INCLUI,1)	
	SetStatusVis(aObjects,CONTA_INCLUI,2)	
Endif	

Return IIf(lOk,oNewGetFJ2,oGetFJ2)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CancOperVis º Autor ³TOTVS		     º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela edicao da tabela                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CancOperVis(oTreeFJ2,oGetFJ2,oPanel)

Local oNewGetFJ2    
Local nTop		:= oGetFJ2:oBox:nTop-12 //O 12 eh o tamanho da toolbar 
Local nBottom	:= oGetFJ2:oBox:nBottom	
Local nLeft		:= oGetFJ2:oBox:nLeft
Local nRight	:= oGetFJ2:oBox:nRight

INCLUI	:=	.F.
ALTERA	:=	.F.
EXCLUI	:=	.F.
oGetFJ2:oBox:FreeChildren()
RegToMemory("FJ2",.F.,,,FunName())                                       
oNewGetFJ2:= MsMGet():New("FJ2", FJ2->(RecNo()),2,,,,,{oPanel:nTop,oPanel:nLeft,oPanel:nHeight,oPanel:nWidth/2.5},,2,,,,oPanel,,,.F.,"aTelaFJ2")
oNewGetFJ2:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oArea :SetTiTleWindow ( "CONTA_A", STR0023 ) //"Conta Gerencial"

Return oNewGetFJ2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DefineStatusVis  ³ Autor ³ TOTVS				    ³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao para definir se apresenta os botoes               			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DefineStatusVis(oObj,aObjects,nOper, nLayOut)
aObjects[nOper,nLayout] :=	oObj
Do Case
Case nOper == CONTA_INCLUI 
	//Definir estatus dos botoes quando acionada esta opcao
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .F. }
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .F. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .T. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .F. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETDADOS]		:= {|| .F. }
Case nOper == CONTA_ALTERA .or. nOper == CONTA_ALTERA2
	//Definir estatus dos botoes quando acionada esta opcao
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .F. }
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .F. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .T. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .F. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETDADOS]		:= {|| .F. }
	
Case nOper == GETD_ALTERA
	//Definir estatus dos botoes quando acionada esta opcao
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .F. }	
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .F. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .F. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,GETD_OK]		:= {|| .T. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .T. }
	aObjects[nOper,3,GETDADOS]		:= {|| .T. }
Case nOper == CONTA_EXCLUI 
Case nOper == CONTA_PESQUISA 
Case nOper == CONTA_OK
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .T. }
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_PESQUISA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| !Empty(cCopiaRef) }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .T. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
Case nOper == CONTA_CANCELA
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .T. }	
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_PESQUISA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| !Empty(cCopiaRef) }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .T. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETDADOS]		:= {|| .F. }
Case nOper == GETD_OK
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .T. }
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .T. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| !Empty(cCopiaRef) }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .T. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
Case nOper == GETD_CANCELA
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .T. }
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .T. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| !Empty(cCopiaRef) }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .T. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETDADOS]		:= {|| .F. }
Case nOper == CONTA_REFRESH
Case nOper == CONTA_COPIA
Case nOper == CONTA_COLA
Case nOper == VISAO_ALTERA .Or. nOper == VISAO_ALTERA2
	//Definir estatus dos botoes quando acionada esta opcao
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .F. }	
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .F. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .F. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .F. }	
	aObjects[nOper,3,VISAO_OK]		:= {|| .T. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .T. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .F. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETDADOS]		:= {|| .F. }
Case nOper == VISAO_OK
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .T. }	
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .T. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| !Empty(cCopiaRef) }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .T. }
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETDADOS]		:= {|| .F. }
Case nOper == VISAO_CANCELA
	aObjects[nOper,3,CONTA_INCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_ALTERA2]	:= {|| .T. }
	aObjects[nOper,3,CONTA_EXCLUI]	:= {|| .T. }
	aObjects[nOper,3,CONTA_PESQUISA]:= {|| .T. }
	aObjects[nOper,3,CONTA_OK]		:= {|| .F. }
	aObjects[nOper,3,CONTA_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,CONTA_IMPORTA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_REFRESH]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COPIA]	:= {|| .T. }
	aObjects[nOper,3,CONTA_COLA]	:= {|| !Empty(cCopiaRef) }
	aObjects[nOper,3,VISAO_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,VISAO_ALTERA2]	:= {|| .T. }
	aObjects[nOper,3,VISAO_OK]		:= {|| .F. }
	aObjects[nOper,3,VISAO_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETD_ALTERA]	:= {|| .T. }
	aObjects[nOper,3,GETD_OK]		:= {|| .F. }
	aObjects[nOper,3,GETD_CANCELA]	:= {|| .F. }
	aObjects[nOper,3,GETDADOS]		:= {|| .F. }
EndCase
Return                                          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SetStatusVis     ³ Autor ³ TOTVS				    ³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao para definir as operaões                         			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SetStatusVis(aObjects,nOper, nLayout)
Local nX
For nX:= 1 To CONTA_OPERACOES  
	//Verificar como deverao ficar os outros objetos com a operacao atual
	If ValType(aObjects[nX,nLayout]) == "O"
		If aObjects[nOper,3,nX] <> Nil
			//Avaliar as condicoes dos outros objetops em relacao a operacao atual
			If Eval( aObjects[nOper,3,nX] ) 
				//Habilitar o objeto correspondete
				If Ascan(AHIDESHOW,nX) > 0 //OK e Confirmar
					aObjects[nX,nLayout]:SHOW()				
				Else
					aObjects[nX,nLayout]:ENABLE()
				Endif
			Else
				If Ascan(AHIDESHOW,nX) > 0 //OK e Confirmar
					//Desabilitar o objeto correspondete		
					aObjects[nX,nLayout]:HIDE()				
				Else
					aObjects[nX,nLayout]:Disable()
				Endif
			Endif
		Endif
		aObjects[nX,nLayout]:Refresh()
	Endif	
Next                                              
Return                 


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Fa271LOK ³ Autor ³ TOTVS				    ³ Data ³ 08/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da linha da Getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa271LOK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA271                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271LOK(oObj)  

Local aSaveArea:= GetArea()
Local lRet		:= .T.

Local nPosNatIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_SEDINI"})
Local nPosNatFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_SEDFIM"})
Local nPosIdent		:= Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_IDENTI"})
Local nPosFormula	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_FORMUL"})
Local nUsado := Len(aHeader)
Local nLine	:=	oObj:nAt      

If ALTERAGD
	If M->FJ2_CLASSE == "2"						// Verifica Analiticas
		If !aCols[nLine][nUsado+1]
			If 	Empty(aCols[nLine][nPosNatIni]) 	.And. Empty(aCols[nLine][nPosNatFim]) 	.And.;
				Empty(aCols[nLine][nPosFormula])	.And.;
				(aCols[nLine][nPosIdent] == "1" .Or. aCols[nLine][nPosIdent] == "2") 		.And.;
				! (M->FJ2_NEGRIT .OR. M->FJ2_TOTAL .OR. M->FJ2_SEPARA .OR. M->FJ2_TRACO)
				lRet := .F.
			EndIf	
	
			If !lRet
				Help(" ",1,"C160NOENTI")
			EndIf

			If lRet
				If !Empty(aCols[nLine][nPosNatIni]) .And. Empty(aCols[nLine][nPosNatFim])
					lRet := .F.
				EndIf
		   	EndIf
	
	   		If lRet
				If 	Empty(aCols[nLine][nPosIdent]) .And.;
					!(M->FJ2_NEGRIT .Or. M->FJ2_Total .Or. M->FJ2_Separa .Or. M->FJ2_Traco)
					Help(" ",1,"C160NOSIN")
					lRet := .F.
				EndIf
			EndIf
			
		EndIf
	EndIf
	
	If M->FJ2_CLASSE == "1" .And. M->FJ2_TOTAL      
		If 	!Empty(aCols[nLine][nPosNatIni]) 	.Or. !Empty(aCols[nLine][nPosNatFim])
	   		lRet := .F.
	    EndIf

		If !lRet
	    	MsgAlert(STR0037,STR0003) //"Conta de total somente pode possuir formula"###"Alerta"
		EndIf

	EndIf
	RestArea(aSaveArea)
Else
	lRet	:=	.T.
Endif	
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Fa271GOk ³ Autor ³ TOTVS				    ³ Data ³ 08/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Getdados - TudoOK                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb160Gok()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA160                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271GOk(oGetD)

Local lRet		:=	.T.
aCols	:=	oGetD:aCols
lRet	:=	Fa271LOK(oGetD:oBrowse)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SetStatusVis     ³ Autor ³ TOTVS					³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao de manutenção da Getdados                         			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaMntGetd(oGet,oTree,aObjects)
Local cCodigo:= Padr(oTree:GetCargo(),Len(FJ2->FJ2_CONTAG))
Local nX

dbSelectArea("FJ2")     
dbSetOrder(1)                                  
dbSeek(xFilial()+FJ1->FJ1_CODIGO+cCodigo)
If M->FJ2_CLASSE == "1" .And. !M->FJ2_TOTAL
	Aviso(STR0038,STR0039,{"Ok"}) //"Operacao nao permitida"###"Nao é possivel editar o detalhe de uma conta sintetica, quando nao e total geral"
Else
	If SoftLock('FJ2')
		SetStatusVis(aObjects,GETD_ALTERA,2)
		oGet:Enable()
		n :=	1
		ALTERAGD := .T.
		oArea :SetTiTleWindow ( "GETDADOS", STR0040 )	//"Composição Da Conta - Alterar"

		aCols 	:= {} 
		DbSelectArea('FJ3')
		DbSetOrder(2)
		DbSeek(xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_CONTAG)
		While xFilial("FJ3")+FJ3->FJ3_CODPLA+FJ3->FJ3_CONTAG ==	xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_CONTAG		
			AAdd(aCols, Array(Len(aHeader)+1))
			For nX:=1 To Len(aHeader)
				If aHeader[nX,10] =="V"
					aCols[Len(aCols)][nX]	:=	CriaVar(aHeader[nX][2],.T.)
				Else
					aCols[Len(aCols)][nX]	:=	FieldGet(FieldPos(aHeader[nX,2]))				
				Endif
			Next
			aCols[Len(aCols)][nX]	:=	.F.
			DbSkip()	
		Enddo     
		If Len(aCols) > 0
			oGet:aCols	:=	aClone(aCols)  
		Else
			oGet:aCols	:=	aClone(aEmptyCols)  		
		Endif

		oGet:oBrowse:Refresh()

	Else
		Aviso(STR0041,STR0042,{"Ok"}) //"Arquivo em uso"###"Nao foi possivel ativar a edicao, tente mais tarde"
	Endif
Endif	

Return		

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CancGDVis   		³ Autor ³ TOTVS			  		³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao de cancelamento da Getdados                         			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CancGDVis(oTreeFJ2,oGet  )
Local cChave	:=	xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_CONTAG
Local nPosLin 	:= ASCAN(oGet:aHeader,{|x| Alltrim(x[2]) == "FJ3_LINHA"})
Local nX
Private aCols	:=	{}
DbSelectArea('FJ3')
DbSetOrder(2)
DbSeek(xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_CONTAG)
While xFilial("FJ3")+FJ3->FJ3_CODPLA+FJ3->FJ3_CONTAG ==	xFilial('FJ3')+FJ1->FJ1_CODIGO+FJ2->FJ2_CONTAG		
	AAdd(aCols, Array(Len(aHeader)+1))
	For nX:=1 To Len(aHeader)
		If aHeader[nX,10] =="V"
			aCols[Len(aCols)][nX]	:=	CriaVar(aHeader[nX][2],.T.)
		Else
			aCols[Len(aCols)][nX]	:=	FieldGet(FieldPos(aHeader[nX,2]))				
		Endif
	Next
	aCols[Len(aCols)][nX]	:=	.F.
	DbSkip()	
Enddo     
If Len(aCols) > 0
	oGet:aCols	:=	aClone(aCols)  
Else
	oGet:aCols	:=	aClone(aEmptyCols)  		
Endif
oArea :SetTiTleWindow ( "GETDADOS", STR0043 )	//"Composição Da Conta"
oGet:oBrowse:Refresh()
oGet:Disable()
ALTERAGD := .F.

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb160Grv ³ Autor ³ TOTVS				    ³ Data ³ 08/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao dos dados digitados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb160Grv( nOpc,cCts_CodPla,cCts_Ordem,cCts_ContaG,         ³±±
±±³          ³ cCts_CtaSup,cCts_Classe,cCts_Normal,cCts_DescCg)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA160                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da opcao escolhida                          ³±±
±±³          ³ ExpC1 = Codigo do Plano Gerencial                          ³±±
±±³          ³ ExpC2 = Codigo da Ordem                                    ³±±
±±³          ³ ExpC3 = Codigo da Conta do Plano Gerencial                 ³±±
±±³          ³ ExpC4 = Codigo da Conta Superior                           ³±±
±±³          ³ ExpC5 = Classe                                             ³±±
±±³          ³ ExpC6 = Condicao Normal                                    ³±±
±±³          ³ ExpC7 = Descricao da entidade gerencial                    ³±±
±±³          ³ ExpC8 = Coluna para uso em demonstrativos                  ³±±
±±³          ³ lNegrito   = CTS_IDENT = 3                                 ³±±
±±³          ³ lTotal     = CTS_IDENT = 4                                 ³±±
±±³          ³ lSeparador = CTS_IDENT = 5                                 ³±±
±±³          ³ lTraco     = CTS_IDENT = 5 .And. CTS_DESCCG = "-"          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ConfGDVis(oGetD )

Local aSaveArea := GetArea()
Local cPos		:= ""
Local nCont
Local nCont1
Local nCont2
Local nLinhaGd  := 0
Local nPosLinha := ASCAN(oGetd:aHeader,{|x| Alltrim(x[2]) == "FJ3_LINHA"})
Local lFJ3Nome  := .F.
Local aHeader	:= oGetd:aHeader
Local aCols		:= oGetd:aCols
Local nUsado	:=	Len(aHeader)
Local lDETHCG	:= FJ2->(FIELDPOS("FJ2_DETHCG")) > 0
dbSelectArea("SX3")				/// VERIFICA SE O CAMPO ESTA EM USO
dbSetOrder(2)
Begin Transaction 
For nCont1 := 1 To Len(aCols)

	dbSelectArea("FJ3")
	dbSetOrder(1)
	If aCOLS[nCont1][nUsado+1] 
		If dbSeek(xFilial("FJ3")+FJ1->FJ1_CODIGO+FJ2->FJ2_ORDEM+aCols[nCont1][nPosLinha])
			RecLock("FJ3",.F.,.T.)
			dbDelete()
			MsUnlock()
		Endif
	Else
		If !dbSeek(xFilial("FJ3")+FJ1->FJ1_CODIGO+FJ2->FJ2_ORDEM+aCols[nCont1][nPosLinha])
			nLinhaGd ++
			RecLock("FJ3",.T.)
			Replace FJ3_FILIAL	With xFilial()
			Replace FJ3_CODPLA	With FJ1->FJ1_CODIGO
			Replace FJ3_ORDEM	With FJ2->FJ2_ORDEM
			Replace FJ3_CONTAG	With FJ2->FJ2_CONTAG
			Replace FJ3_CTASUP	With FJ2->FJ2_CTASUP
			Replace FJ3_CLASSE	With FJ2->FJ2_CLASSE
			Replace FJ3_NORMAL	With FJ2->FJ2_NORMAL
			Replace FJ3_DESCCG	With FJ2->FJ2_DESCCG
			If lDETHCG
				Replace FJ3_DETHCG	With FJ2->FJ2_DETHCG
			EndIf
			Replace FJ3_COLUNA	With Val(FJ2->FJ2_COLUNA)
			If lFJ3Nome
				Replace FJ3_NOME	With FJ2->FJ2_DESCCG
			Endif

		   	Replace FJ3_TOTVIS With FJ2->FJ2_TOTVIS
			Replace FJ3_VISENT With FJ2->FJ2_VISENT 
			Replace FJ3_SLDENT With FJ2->FJ2_SLDENT 
			Replace FJ3_FATSLD With FJ2->FJ2_FATSLD 
			
		Else
			nLinhaGd ++
			RecLock("FJ3")
			Replace FJ3_CONTAG	With FJ2->FJ2_CONTAG
			Replace FJ3_CLASSE	With FJ2->FJ2_CLASSE
			Replace FJ3_NORMAL	With FJ2->FJ2_NORMAL
			Replace FJ3_DESCCG	With FJ2->FJ2_DESCCG
			If lDETHCG
				Replace FJ3_DETHCG	With FJ2->FJ2_DETHCG
			EndIf
			Replace FJ3_CTASUP	With FJ2->FJ2_CTASUP
			Replace FJ3_COLUNA	With Val(FJ2->FJ2_COLUNA)
		EndIf

		For nCont := 1 to Len(aHeader)
			cPos += StrZero(FieldPos(aHeader[nCont,2]),2,0)
		Next
	
		For nCont2 := 1 To Len(aHeader)
			If aHeader[nCont2][10] # "V"
				cVar := Trim(aHeader[nCont2][2])
				FieldPut(Val(Subs(cPos,(nCont2*2-1),2)),aCOLS[nCont1][nCont2])
			ElseIf Trim(aHeader[nCont2][2]) = "FJ3_IDENTI"
				Replace FJ3_IDENT With aCOLS[nCont1][nCont2]
			EndIf
		Next nCont2
		
		//Para refazer a contagem da linha quando deletado registro deletado
		Replace FJ3_LINHA		With StrZero(nLinhaGd,Len(FJ3->FJ3_LINHA))
		
		If !Empty(FJ2->FJ2_IDENT) .AND. FJ2->FJ2_CLASSE = "1"
			Replace FJ3_IDENT 	With FJ2->FJ2_IDENT
		Endif

	   	Replace FJ3_TOTVIS With FJ2->FJ2_TOTVIS
		Replace FJ3_VISENT With FJ2->FJ2_VISENT
		Replace FJ3_SLDENT With FJ2->FJ2_SLDENT
		Replace FJ3_FATSLD With FJ2->FJ2_FATSLD
		
		MsUnlock()
		cVar := ""
	EndIf
Next nCont1
End Transaction  
ALTERAGD	:=	.F.
oArea :SetTiTleWindow ( "GETDADOS", STR0043 )	//"Composição Da Conta"

dbSelectArea("FJ3")
dbSetOrder(1)

RestArea(aSaveArea)
oGetD:Disable()

Return          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa271SetL  ºAutor  ³TOTVS		         º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializa os campos logicos da tabeka                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
*/
FUNCTION Fa271SetL(lNegrito,lTotal,lSepara,lTraco)
Local lRet	:=	.F.
Do Case
Case	lNegrito	
	lRet	:=	 FJ2->FJ2_IDENT == "3" .Or. FJ2->FJ2_IDENT = "6"
Case	lTotal		
	lRet	:= FJ2->FJ2_CLASSE = "1" // Se for sintetica, sempre marcado
Case	lSepara	
	lRet	:= ( FJ2->FJ2_IDENT = "5" .Or. FJ2->FJ2_IDENT = "6" ) .And. Alltrim( FJ2->FJ2_DESCCG ) <> "-"
Case	lTraco		
	lRet	:= FJ2->FJ2_IDENT = "5" .And. Alltrim( FJ2->FJ2_DESCCG ) == "-"
EndCase
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GetNextOrdem   	³ Autor ³ TOTVS		     		³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao  GetNextOrdem ()				                    			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetNextOrdem()
Local aArea	:=	FJ2->(GetArea())
Local nConta:=	Max(Iif(ValType(mv_par01) == "N",mv_par01,1) ,1)
DbSelectArea('FJ2')
DbSetOrder(4)
DbSeek(xFilial()+FJ1->FJ1_CODIGO+"zzzzzzzzzzzzzzzzzzz",.t.)
DbSkip(-1)
If xFilial()+FJ1->FJ1_CODIGO == FJ2->(FJ2_FILIAL+FJ2_CODIGO)
	cOrdem	:=	StrZero(Val(FJ2->FJ2_ORDEM) + nConta,Len(FJ2->FJ2_ORDEM))
Else
	cOrdem	:=	StrZero(nConta,Len(FJ2->FJ2_ORDEM))
Endif           
RestArea(aArea)
Return cOrdem

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RefreshTree   	³ Autor ³ TOTVS					³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao  RefreshTree ()				                    			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RefreshTree(oTreeFJ2,oPsideBar,lConf,cCtaSup,cCodigo,cOrdem,oGetFJ1,oGetFJ2,oGet)

Default lConf 	:= .F.

lInRefresh	:=	.T.
oTreeFJ2:BeginUpdate() 
//ESTRUTURA - CODIGO + CONTAG
IF MV_PAR05 == 1
	If Empty(cCtaSup) .Or. oTreeFJ2:GetCargo() =="ID_PRINCIPAL"
		cOrigem	:=	"ID_PRINCIPAL"
		cSeek	:=	Space(Len(FJ2->FJ2_CONTAG))
		DbSelectArea('FJ2')
		DbSetOrder(2)
		DbSeek(xFilial()+FJ2->FJ2_CODIGO+cSeek)
		While !Eof().And. xFilial()+FJ2->FJ2_CODIGO+cSeek == FJ2->FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP
			nRecFJ2:=FJ2->(Recno())
			If oTreeFJ2:TreeSeek(FJ2->FJ2_CONTAG)
				oTreeFJ2:DelItem()
			Endif
			FJ2->(MsGoTo(nRecFJ2))
			DbSelectArea('FJ2')
			DbSkip()
		Enddo
		oTreeFJ2:TreeSeek("ID_PRINCIPAL")
		lInRefresh	:=	.F.
		AddTreeFJ2(oTreeFJ2,,.T.)
		
	Else
		IF lConf
			cOrigem	:=	cCtaSup
			cSeek	:=	cCtaSup
			DbSelectArea('FJ2')
			DbSetOrder(2)
			DbSeek(xFilial()+cCodigo+cSeek)
			While !Eof().And. xFilial()+cCodigo+cSeek == FJ2->FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP
				nRecFJ2:=FJ2->(Recno())
				If oTreeFJ2:TreeSeek(FJ2->FJ2_CONTAG)
					oTreeFJ2:DelItem()
				Endif
				FJ2->(MsGoTo(nRecFJ2))
				DbSelectArea('FJ2')
				DbSkip()
			Enddo
			lInRefresh	:=	.F.
		Else
			cOrigem	:=	FJ2->FJ2_CONTAG
			cSeek	:=	FJ2->FJ2_CONTAG
			DbSelectArea('FJ2')
			DbSetOrder(2)
			DbSeek(xFilial()+FJ2->FJ2_CODIGO+cSeek)
			While !Eof().And. xFilial()+FJ2->FJ2_CODIGO+cSeek == FJ2->FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_CTASUP
				nRecFJ2:=FJ2->(Recno())
				If oTreeFJ2:TreeSeek(FJ2->FJ2_CONTAG)
					oTreeFJ2:DelItem()
				Endif
				FJ2->(MsGoTo(nRecFJ2))
				DbSelectArea('FJ2')
				DbSkip()
			Enddo
			oTreeFJ2:TreeSeek("ID_PRINCIPAL")
			lInRefresh	:=	.F.
			oTreeFJ2:TreeSeek(cOrigem)
		Endif
	Endif  
//ORDEM - CODIGO + ORDEM	
ELSE
	If oTreeFJ2:GetCargo() =="ID_PRINCIPAL"
		cOrigem	:=	"ID_PRINCIPAL"
		cSeek	:=	Space(Len(FJ2->FJ2_ORDEM))
		DbSelectArea('FJ2')
		DbSetOrder(4)
		DbSeek(xFilial()+FJ2->FJ2_CODIGO+cSeek)
		While !Eof().And. xFilial()+FJ2->FJ2_CODIGO+cSeek >= FJ2->FJ2_FILIAL+FJ2->FJ2_CODIGO+FJ2->FJ2_ORDEM
			nRecFJ2:=FJ2->(Recno())
			If oTreeFJ2:TreeSeek(FJ2->FJ2_ORDEM)
				oTreeFJ2:DelItem()
			Endif
			FJ2->(MsGoTo(nRecFJ2))
			DbSelectArea('FJ2')
			DbSkip()
		Enddo
		oTreeFJ2:TreeSeek("ID_PRINCIPAL")
		lInRefresh	:=	.F.
		AddTreeFJ2(oTreeFJ2,,.T.)
		
	Else
		cOrigem := FJ2->FJ2_CONTAG
		cSeek := FJ2->(FJ2_FILIAL+FJ2_CODIGO)
		DbSelectArea('FJ2')
		DbSetOrder(4)
		DbSeek(xFilial('FJ2')+cSeek)
		While !Eof() .AND. FJ2->(FJ2_FILIAL+FJ2_CODIGO) >= cSeek
			nRecFJ2:=FJ2->(Recno())
			If oTreeFJ2:TreeSeek(FJ2->FJ2_CONTAG)
				oTreeFJ2:DelItem()
			Endif
			FJ2->(MsGoTo(nRecFJ2))
			DbSelectArea('FJ2')
			DbSkip()
		Enddo
		lInRefresh	:=	.F.
		oTreeFJ2:TreeSeek("ID_PRINCIPAL")
		AddTreeFJ2(oTreeFJ2,,.T.)
		PosicionaFJ2(oTreeFJ2,,,,oArea,oGetFJ1,oGetFJ2,oGet)
		oArea:ShowLayout("VISAOFJ1")
		If ValType(oGetFJ1) == "O"
			oGetFJ1:EnchRefreshAll()
		EndIf
	Endif
ENDIF

oTreeFJ2:EndUpdate()
oTreeFJ2:Refresh()
oPsideBar:Refresh()
Return oTreeFJ2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fin271Exc    ³ Autor ³ Totvs             ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui a visao gerencial.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA161                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin271Exc( cAlias, nReg, nOpc )
	Fa271Pos()
	Fa271Del( cAlias, nReg, nOpc, .T. )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fa271Prox  ³ Autor ³ TOTVS				³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa271Prox(lInclui)
Local cReturn := ""
Local cContag := ""
Local aArea   := GetArea()

Do Case
	//Automatico
	Case Empty(M->FJ2_CONTAG) .And. lInclui .And. MV_PAR02 = 1 
	
		cContag := FJ2->FJ2_CONTAG

	  	dbSetOrder(1)   
	 	dbSeek(xFilial()+FJ2->FJ2_CODIGO+"zzzzzzzzzzzzzzzzzzzz",.T.)
		dbSkip(-1) 
		cContag := FJ2->FJ2_CONTAG

		cReturn := PadR(Soma1(AllTrim(cContag)),TamSx3("FJ2_CONTAG")[1])
		
   //Formula
	Case lInclui .And. MV_PAR02 = 2
		If Empty(MV_PAR03)
			cReturn := CriaVar("FJ2_CONTAG")
		Else
			If C271VldFormula(MV_PAR03) 
				cReturn := &(MV_PAR03)
			EndIf
		EndIf
	
	//Digitacao
	Case Empty( cReturn ) .And. lInclui .And. MV_PAR02 = 3
		cReturn := CriaVar("FJ2_CONTAG")

EndCase

If lInclui .And. MV_PAR04 = 1
	cReturn := StrZero( Val( cReturn ), TamSx3( "FJ2_CONTAG" )[1], 0 )
EndIf

RestArea(aArea)

Return cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fina271Vld   ³ Autor ³ TOTVS				³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida campos do cabecalho do rotina(tela)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fina271Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fina271Vld(cCpoVld,lInclui)

Local lRet := .T.

Do Case
	Case AllTrim(cCpoVld) == "FJ2_CODIGO"
		If lRet
			lRet := NaoVazio(M->FJ2_CODIGO)
		EndIf
		If lRet 
			lRet := ( FJ1->FJ1_CODIGO == M->FJ2_CODIGO )
		EndIf
		If lRet
			lRet := FreeForUse("FJ2",M->FJ2_CODIGO)
		EndIf
		If lRet
			lRet := Fa271Ord(lInclui)
		EndIf
		If lRet           
			lRet := Fa271Nome()
		EndIf

	Case AllTrim(cCpoVld) == "FJ2_ORDEM"
		If lRet
			lRet := NaoVazio(M->FJ2_ORDEM)
		EndIf
		If lRet
			lRet := Fa271Ord(lInclui)
		EndIf

	Case AllTrim(cCpoVld) == "FJ2_CONTAG"
		If lRet
			lRet := NaoVazio(M->FJ2_CONTAG)
		EndIf
		If lRet
			lRet := Fa271Ent(lInclui)
		EndIf

	Case AllTrim(cCpoVld) == "FJ2_CTASUP"
		If lRet
			lRet := Fa271Sup()
		EndIf

	Case AllTrim(cCpoVld) == "FJ2_NORMAL"
		If lRet
			lRet := NaoVazio(M->FJ2_NORMAL)
		EndIf

	Case AllTrim(cCpoVld) == "FJ2_DESCCG"
		If SubStr(M->FJ2_DESCCG,1,1) = "-"
			cIdent := "7"
		Else
			cIdent := " "		
		EndIf
EndCase

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fa271Nome ³ Autor ³TOTVS			        ³ Data ³ 10.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Fa271Nome()

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := FJ3->(GetArea())

dbSelectArea("FJ3")
dbSetOrder(1)
If MsSeek(xFilial("FJ3")+M->FJ2_CODIGO,.F.)
	M->FJ3_NOME := FJ3->FJ3_NOME
	lTrvNome := .F.
Else
	lTrvNome := .T.
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fa271Chkbox
Validação dos checkboxes 

@param lNegrito, lógico, indica se o campo é o negrito
@param lTotal, lógico, indica se o campo é o total geral
@param lSemValor, lógico, indica se o campo é o Sem Valor
@param lTraco, lógico, indica se o campo é o Traço

@author Karen Honda
@since 05/11/2020
@version 12
/*/
//-----------------------------------------------------------------------------------------------------
Function Fa271Chkbox(lNegrito as Logical, lTotal as Logical, lSemValor as Logical, lTraco as Logical) as Logical
Local lRet as Logical


Default lNegrito := .F.
Default lTotal := .F.
Default lSemValor := .F.
Default lTraco := .F.

lRet := .T.

If lNegrito	
	If M->FJ2_TRACO
		lRet := .F.
	EndIf
ElseIf lTotal
		lRet := .F.
ElseIf lSemValor
	If M->FJ2_TRACO
		lRet := .F.
	EndIf
ElseIf lTraco
	If M->FJ2_NEGRITO .or. M->FJ2_SEPARA
		lRet := .F.
	EndIf
EndIf
Return lRet
