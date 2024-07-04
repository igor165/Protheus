#INCLUDE "CTBA161.CH"
#INCLUDE "CTBAREA.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"

Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
Static cTipoCTS := NIL
Static __Release  := NIL
Static __lCOLUN2   // indica se a coluna CTS_COLUN2 existe

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
#DEFINE CONTA_NOTAEXP	  20

#Define CONTA_OPERACOES   20

#DEFINE AHIDESHOW {4,5,12,13,15,16,17}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTBA161  ³ Autor ³ Davi Torchio          ³ Data ³ 01/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastramento Plano Gerencial                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA161()                                                  ³±±
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
Function CTBA161()

Local   aDados		:= {}

Private aRotina 	:= MenuDef()
Private aCVzo		:= {}
Private cCadastro 	:= STR0013 //"Cadastro Visao Gerencial"
Private cAliasBrw	:= ""
Private lTrvNome  	:= .T.

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If !CheckForm()
	Return .F.
Endif

DbSelectArea("CVE")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						³
//³ mv_par01		// Incrementa na inclusao de n em n      	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetKey(VK_F12,{|a,b|AcessaPerg("CTB161",.T.)})

Pergunte("CTB161",.F.)

cAliasBrw := IIf( MV_PAR06 == 2, "CVE", "CTS" )

Ctb161IniVar()

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
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Davi Torchio          ³ Data ³ 01/12/07 ³±±
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
//------------------
Static Function MenuDef()
Local aRotina := { 		{ STR0001,"AxPesqui"				, 0 , 1},;  // // //"Pesquisar"
						{ STR0002,"Ctb161Cad(,, 2, .F. )"	, 0 , 2},;  // // //"Visualizar"
						{ STR0003,"Ctb161Inc"				, 0 , 3},;  // // //"Incluir"
						{ STR0004,"Ctb161Cad(,, 4, .F. )"	, 0 , 4},;  // // //"Alterar"
						{ STR0061,"Ctb161Alt"				, 0 , 4},;  // // //"Alterar Cadastro"
						{ STR0006,"Ctb161Imp"				, 0 , 3},;  // // //"Imp. Estrutura"
						{ STR0005,"Ctb161Exp"				, 0 , 4},;  // // //"Exp. Estrutura"
						{ STR0007,"Ctb161Exc"				, 0 , 5} }  // // //"Excluir"
Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTBA161Inc ³ Autor ³ Davi Torchio        ³ Data ³ 01/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusao de nova Visao Gerencial                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ctb161Inc(cAlias,nReg,nOpc)
Private nRecCVE := 0
If !CheckForm()
	Return .F.
Endif

If MV_PAR06 == 1
	Ctb160Cad( ,, 3, .F. )
Else
	dbSelectArea("CVE")
	/*Passando recno 0 - pois é inclusão
	cTransact pq não estava posicionado */
	If	AxInclui(Alias(),0,3,/*aAcho*/,/*cFunc*/,/*aCpos*/,/*cTudoOk*/,/*lF3*/,"C161SVREC"/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/) == 1
		//posicionar no registro da tabela CVE incluido neste momento
		dbGoto(nRecCVE)

		Ctb161Cad( "CVE", CVE->( Recno() ), 4, .T. )
	Endif
EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTBA161Alt³ Autor ³ Totvs                 ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera o cadastro da visao gerencial                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Alt()
Local cCVE_Descri

	Ctb161Pos()
	cCVE_Descri := CVE->CVE_DESCRI
	AxAltera( "CVE", CVE->( RecNo() ), 4 )

	If cCVE_Descri != CVE->CVE_DESCRI
		//se for modificado a descricao deve alterar todos os registros da tabela CTS - campo CTS_NOME
		dbSelectArea("CTS")
		dbSetOrder(1)
		dbSeek(xFilial("CTS")+CVE->CVE_CODIGO)
		While CTS->(! Eof() .And. CTS_FILIAL+CTS_CODPLA == xFilial("CTS")+CVE->CVE_CODIGO)

			RecLock("CTS", .F.)
			CTS->CTS_NOME := CVE->CVE_DESCRI
			MsUnLock()

			CTS->(dbSkip())

		EndDo

		//posicionar novamente, pois o CTS ficou desposicionado
		Ctb161Pos()

	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTBA161Cad ³ Autor ³ Davi Torchio        ³ Data ³ 01/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Visao Gerencial                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ctb161Cad(cAlias,nReg,nOpc,lInclusao )

Local nWStage 		:= GetScreenRes()[IDX_SCREEN_WIDTH] - 65
Local nHStage 		:= GetScreenRes()[IDX_SCREEN_HEIGHT] - 255
Local nCont			:= 0
Local nPos			:= 0
Local oGetCVF
Local oVisCVF
Local oTREECVF
Local aObjects	:=	{}
Local nCont1 		:= 0
Local nPosLin 	:= 0
Local bWhenGetD	:=	{|| ALTERAGD .And. !M->CVF_NEGRIT .And. !M->CVF_TRACO .And. !M->CVF_SEPARA .And. !( M->CVF_CLASSE == '1' .And. !M->CVF_TOTAL) }
Local oMenuPop
Local nX
Local lErro := .F.
Local aAuxHead := ""
Local nMax  := 35657
Local aNoCampos	:=	{}
Local oStruCVF	:= Nil
Local aStruCVF	:= {}
Local aCpoCVF	:= {}
Local lNotaExp := SUPERGETMV("MV_NEVISAO",,.F.)

Private oArea
Private aTELA[0][0]
Private aTELACVF[0][0]
Private aGETS[0]
Private n
Private cCopiaRef	:=	""

Default lInclusao	:= .F.

If __lCOLUN2 == NIL
	__lCOLUN2 :=  Iif(CTS->(FieldPos("CTS_COLUN2")) > 0, .T., .F.)
Endif
Ctb161IniVar()

For nX := 1 To CONTA_OPERACOES
	AAdd(aObjects, { Nil , Nil, Array(CONTA_OPERACOES) } )
Next

If !CheckForm()
	Return .F.
Endif

Private INCLUI		:=	.F.
Private ALTERA		:=	.F.
Private ALTERAGD	:=	.F.
Private EXCLUI		:=	.F.
Private aEmptyCols	:= {}
Private aHeader
Private aCols
Private lLastCVE	:=	.T.
Private nPop1:=0
Private nPop2:=150
Private lInRefresh	:=	.F.
Private cCadastro := STR0014 //OemToAnsi(STR0006) //"Imp. Estrutura" //"Visoes Gerenciais"

If nOpc == 4 .And. !SoftLock('CVE')
	Return
Endif

If nOpc <> 3 .AND. !lInclusao
	Ctb161Pos()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a forma de exibicao da visao gerencial.³
//³Modo tradicional ou arvore.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR06 == 1
	If nOpc == 2 .OR. nOpc == 4 // Visualizar/Alterar

		If ! Ctb160ChkInc()
			Ctb161Pos()
		EndIf
		//
		Ctb160Cad( cAlias, nReg, nOpc, .T. )
		Return
	EndIf

Else

		If ! Ctb160ChkInc()
			Ctb161Pos()
		EndIf
EndIf

//----- CODIGO PAI PARA CRIACAO DA ARVORE

//"Visao Gerencial"
oArea := FWArea():New( 000, 000, nWStage, nHStage,, 1, STR0012 )

// Cria a borda envolta de toda aplicação
oArea	:CreateBorder ( 3 )

// altera a fonte
SetFont("FW Microsiga")

//Inicio layout Tree
oArea	 	:AddSideBar ( 35, 1, "ArvoreCVF")
oSideBar	:= oArea:GetSideBar ( "ArvoreCVF" )

oArea		:AddWindow ( 100, CtbGetHeight(100), "P_SideBar", STR0012, 1 , 1, oSideBar) //### //"Visao Gerencial"###"Visao Gerencial"
oArea		:AddPanel  ( 100, 100, "P_SideBar",CONTROL_ALIGN_ALLCLIENT )
oPSideBar	:= oArea:GetPanel ( "P_SideBar" )
/**/
//Conteudo layout tree
//------------------------------------------------------------------------------------------//
//CRIACAO DA ARVORE
//------------------------------------------------------------------------------------------//
oTreeCVF:= Xtree():New(000,000,000,000, oPSideBar)

//alinha para tomar toda a tela do PainelSideBar e cria no principal
oTreeCVF:Align := CONTROL_ALIGN_ALLCLIENT
oTreeCVF:bChange := {|x1,x2,x3| If(!lInRefresh,PosicionaCVF(x1,x2,x3,,oArea,oGetCVE,oGetCVF,oGet),NIL)}
oTreeCVF:bValid := {|| !INCLUI .and. !ALTERA .and. !ALTERAGD .and. !EXCLUI }
oTreeCVF:bWhen  := {|| !INCLUI .and. !ALTERA .and. !ALTERAGD .and. !EXCLUI }
oTreeCVF:AddTree (CVE->CVE_DESCRI, "folder516","FOLDER616", 'ID_PRINCIPAL',/*{|| MsgStop('xxx')}*/,/*bRClick*/, { || AddTreeCVF(oTreeCVF,,,@lErro) })

AddTreeCVF(oTreeCVF,,,@lErro)

oTreeCVF:EndTree()

If lErro  // se ocorrer erro na montagem da estrutura entao muda para modo de visualizar
	nOpc := 2
EndIf

If nOpc <> 2
	oTreeCVF:BrClicked	:= {|x,y,z| TreeMenupop(oSideBar,oMenuPop,oTreeCVF,x,y,z) }
	MENU oMenuPop POPUP
		MENUITEM STR0036 	ACTION Eval( oBtBarTree[2]:bAction) RESOURCE  'BMPINCLUIR' //'Incluir'
		MENUITEM STR0037 	ACTION Eval(oBtBarTree[3]:bAction) RESOURCE  'NOTE' //'Alterar'
		If	!lNotaExp
			MENUITEM STR0038 	ACTION Eval(oBtBarTree[4]:bAction) RESOURCE  'EXCLUIR' //'Excluir'
		Else
			MENUITEM STR0101	ACTION Eval(oBtBarTree[4]:bAction) RESOURCE  'CLIPS' //'Nota Explicativa'
			MENUITEM STR0038 	ACTION Eval(oBtBarTree[5]:bAction) RESOURCE  'EXCLUIR' //'Excluir'
		EndIf

	ENDMENU
Endif
//FIM Contteudo layout tree
/**/
//Fim layout tree
//Botoes layoute tree
If nOpc <> 2 .And. !lNotaExp
	oBarTree  :=	{	{"RELOAD.PNG","BMPINCLUIR","NOTE","EXCLUIR"},;
						{	{|| SetStatusVis(aObjects,CONTA_REFRESH,2), oTreeCVF	:=	RefreshTree(oTreeCVF,oPSideBar,,,,,oGetCVE,oGetCVF,oGet)},;
							{|| SetStatusVis(aObjects,CONTA_INCLUI,2),		oArea:ShowLayout ( "ANALITICA" ), oGetCVF	:=	FaManutCONTA("CVF",,3,oTreeCVF,oGetCVF,oPanelAll,aObjects,oGet,oArea)},;
                 			{|| IIf (oTreeCVF:GetCargo()=="ID_PRINCIPAL",;
	   	             			Nil ,;
   	   	          				( SetStatusVis(aObjects,CONTA_ALTERA2,2),oArea:ShowLayout ( "ANALITICA" ), oGetCVF	:=	FaManutCONTA("CVF",,4,oTreeCVF,oGetCVF,oPanelAll,aObjects,oGet,oArea) ) ;
   	   	          				) },;
                			{|| iiF(oTreeCVF:GetCargo()=="ID_PRINCIPAL",nIL,(SetStatusVis(aObjects,CONTA_EXCLUI,2),oGetCVF:=FAManutConta("CVF",,5,oTreeCVF,oGetCVF,oPanelAll,aObjects,oGet,oArea)) )},;
                		},;
					 	{STR0035,STR0003,STR0004,STR0007} }  //"Refresh"###"Incluir"###"Alterar"###"Excluir"###"Sair"
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
ElseIf nOpc <> 2 .AND. lNotaExp

	oBarTree  :=	{	{"RELOAD.PNG","BMPINCLUIR","NOTE","CLIPS","EXCLUIR"},;
						{	{|| SetStatusVis(aObjects,CONTA_REFRESH,2), oTreeCVF	:=	RefreshTree(oTreeCVF,oPSideBar,,,,,oGetCVE,oGetCVF,oGet)},;
							{|| SetStatusVis(aObjects,CONTA_INCLUI,2),		oArea:ShowLayout ( "ANALITICA" ), oGetCVF	:=	FaManutCONTA("CVF",,3,oTreeCVF,oGetCVF,oPanelAll,aObjects,oGet,oArea)},;
                 			{|| IIf (oTreeCVF:GetCargo()=="ID_PRINCIPAL",;
	   	             			Nil ,;
   	   	          				( SetStatusVis(aObjects,CONTA_ALTERA2,2),oArea:ShowLayout ( "ANALITICA" ), oGetCVF	:=	FaManutCONTA("CVF",,4,oTreeCVF,oGetCVF,oPanelAll,aObjects,oGet,oArea) ) ;
   	   	          				) },;
							{|| SetStatusVis(aObjects,CONTA_NOTAEXP,2),oArea:ShowLayout ( "ANALITICA" ), CTBA161P()},;
                			{|| iiF(oTreeCVF:GetCargo()=="ID_PRINCIPAL",nIL,(SetStatusVis(aObjects,CONTA_EXCLUI,2),oGetCVF:=FAManutConta("CVF",,5,oTreeCVF,oGetCVF,oPanelAll,aObjects,oGet,oArea)) )},;
                		},;
					 	{STR0035,STR0003,STR0004,STR0101,STR0007} }  //"Refresh"###"Incluir"###"Alterar"###"Nota Explicativa"###"Excluir"###"Sair"
   	oArea:AddButtonBar( oBarTree )
   	oBtBarTree   :=	oArea:GetButtonBar("P_SideBar")
	DefineStatus(oBtBarTree[1],aObjects,CONTA_REFRESH,2)
	DefineStatus(oBtBarTree[2],aObjects,CONTA_INCLUI,2)
	DefineStatus(oBtBarTree[3],aObjects,CONTA_ALTERA2,2)
	DefineStatus(oBtBarTree[3],aObjects,VISAO_ALTERA2,2)
	DefineStatus(oBtBarTree[4],aObjects,CONTA_NOTAEXP,2)
	DefineStatus(oBtBarTree[5],aObjects,CONTA_EXCLUI,2)
	DefineStatus(oBtBarTree[1],aObjects,CONTA_REFRESH,1)
	DefineStatus(oBtBarTree[2],aObjects,CONTA_INCLUI,1)
	DefineStatus(oBtBarTree[3],aObjects,CONTA_ALTERA2,1)
	DefineStatus(oBtBarTree[3],aObjects,VISAO_ALTERA2,1)
	DefineStatus(oBtBarTree[4],aObjects,CONTA_NOTAEXP,1)
	DefineStatus(oBtBarTree[5],aObjects,CONTA_EXCLUI,1)
	
Else
	oBarTree  :=	{{"RELOAD.PNG"},;
    				{{|| SetStatusVis(aObjects,CONTA_REFRESH,2)} },;
					 {STR0035} }  //"Refresh"
    oArea:AddButtonBar( oBarTree )
    oBtBarTree   :=	oArea:GetButtonBar("P_SideBar")
	DefineStatus(oBtBarTree[1],aObjects,CONTA_REFRESH,2)
Endif
//fim botoes layout tree
//AQUI
//Inicio Layout CVE
//So uma WINDOW
oArea    	:AddLayout ( "VISAOCVE" )
oVISAOCVE	:= oArea:GetLayout ( "VISAOCVE" )
oPanelCapa	:= oArea:GetPanel ( "VISAOCVE" )

oArea		:AddWindow ( 100, CtbGetHeight(100), "VISAOCVE", STR0012, 2, 2,oVISAOCVE) //"Visao Gerencial"###"Visao Gerencial"
oArea		:AddPanel  ( 100, 100, "VISAOCVE" )
oPanelCapa	:= oArea:GetPanel ( "VISAOCVE" )

DbSelectArea("CVE")
RegToMemory("CVE",.F.,,,FunName())
oGetCVE:= MsMGet():New("CVE", CVE->(RecNo()),2,,,,,{0,0,290,252},,,,,,oPanelCapa,,,,,,.T.)
oGetCVE:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//FIM Conteudo layout CVE

// -------  Layout enchoice + Getdados --- Analiticas
//Duas windows: enchoice e getdados

oArea    	:AddLayout ( "ANALITICA" )
oAnalitica	:= oArea:GetLayout ( "ANALITICA" )

oArea:AddWindow ( 100, CtbGetHeight(50), "CONTA_A", "Conta", 3, 4,oAnalitica)
oArea:AddPanel  ( 100,100, "EnchoiceA",CONTROL_ALIGN_ALLCLIENT )
oPanelAll		:= oArea:GetPanel ( "EnchoiceA" )
oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT

oArea :SetTiTleWindow ( "CONTA_A", STR0041 )	 //"Conta Gerencial""

If nOpc <> 2
	//Inicio botoes ANALITICA
	aButtonBar  := {{"NOTE.PNG"},;
	{ ;
	{|| oGetCVF	:= FAManutCONTA("CVF",,4,oTreeCVF,oGetCVF,oPanelAll,aObjects,oGet,oArea) }; 
	},;
	{ STR0004} } //"Alterar"
	oArea                    :AddButtonBar ( aButtonBar )
	oBtBar    := oArea:GetButtonBar ("EnchoiceA")

	DefineStatusVis(oBtBar[1],aObjects,CONTA_ALTERA,2)

	aButtons  := {  { STR0039,STR0040},;
	{ ;
	{|| SetStatusVis(aObjects,CONTA_CANCELA,2),oGetCVF 	:= 	CancOperVis(oTreeCVF,oGetCVF,oPanelAll,aObjects)},;
	{|| SetStatusVis(aObjects,CONTA_OK,2)     ,oGetCVF	:=	ConfOperVis(oTreeCVF,oGetCVF,oPanelAll,aObjects)};
	} ,;
	{STR0039,STR0040 } } //"Cancelar"###"Confirmar"
	oArea:AddTextButton ( aButtons )
	oBtText := oArea:GetTextButton ("EnchoiceA")
	oBtnEscSint  := oBtText[1]
	oBtnConfSint := oBtText[2]
	oBtText[1]:Hide()
	oBtText[2]:Hide()
	DefineStatusVis(oBtText[1],aObjects,CONTA_OK,2)
	DefineStatusVis(oBtText[2],aObjects,CONTA_CANCELA,2)

	//Fim botoes
Endif


oArea:AddWindow ( 100, CtbGetHeight(50), "GETDADOS", STR0015, 4, 3,oAnalitica	) //"Composicao da Conta"###"Composicao da Conta"
oArea:AddPanel  ( 100, 100, "GetDados" )

oPanel_3		:= oArea:GetPanel ( "GetDados" )
If nOpc <> 2
	//Inicio botoes GETDADOS
	aButtonBar  := {{"NOTE.PNG"},;
	{ ;
	{|| FaMntGetd(oGet,oTreeCVF,aObjects)};
	},;
	{ STR0004} } //"Alterar"  
	oArea                    :AddButtonBar ( aButtonBar )
	oBtBar                   := oArea:GetButtonBar ("GetDados")

	DefineStatusVis(oBtBar[1],aObjects,GETD_ALTERA,2)

	aButtons  := {  {STR0039,STR0040 },;
	{ ;
	{|| SetStatusVis(aObjects,GETD_CANCELA,2),CancGDVis(oTreeCVF,oGet  )},;
	{|| Iif(Ctb161GOk(oGet), (SetStatusVis(aObjects,GETD_OK,2)     ,ConfGDVis( oGet  )),Nil)};
	} ,;
	{STR0039,STR0040} } //"Cancelar"###"Confirmar"
	oArea:AddTextButton ( aButtons )
	oBtText := oArea:GetTextButton ("GetDados")
	oBtnConfSint := oBtText[1]
	oBtnEscSint  := oBtText[2]
	oBtText[1]:Hide()
	oBtText[2]:Hide()
	DefineStatusVis(oBtText[1],aObjects,GETD_CANCELA,2)
	DefineStatusVis(oBtText[2],aObjects,GETD_OK,2)

	//Fim botoes
Endif

//-----------------------------------------------------------------------------------------
// Não apresenta o campo CVF_SLDENT, pois nao foi identificada funcionalidade para o mesmo
// Em versao futura, ele será alterado para Nao Usado (X3_USADO)
//-----------------------------------------------------------------------------------------
oStruCVF := FWFormStruct(2,'CVF',{|x| AllTrim(x) != 'CVF_SLDENT'})

aStruCVF := oStruCVF:GetFields()

AEval(aStruCVF,{|x| Aadd(aCpoCVF,x[1])})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da enchoice do CVF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CVF")
dbSetOrder(1)
oGetCVF:= MsMGet():New("CVF", CVF->(RecNo()),2,,,,aCpoCVF,{oPanelAll:nTop,oPanelAll:nLeft,oPanelAll:nHeight,oPanelAll:nWidth/2.5},,,,,,oPanelAll)
oGetCVF:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//------------------------------------------------------------------------------------------//
//Cria GetDados da visao gerencial
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do CTS                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CTS")
dbSetOrder(1)
If __Release .and. __lCOLUN2
	aNoCampos	:= {"CTS_CONTAG","CTS_NOME","CTS_IDENTI","CTS_TPSALD","CTS_CTASUP","CTS_COLUN2","CTS_VISENT","CTS_FATSLD","CTS_CLASSE","CTS_IDENT","CTS_DESCCG",;
				"CTS_TOTVIS","CTS_SLDENT","CTS_DETHCG","CTS_TPVALO","CTS_ORDEM","CTS_CODPLA","CTS_NORMAL","CTS_PICTUR"}
Else
	aNoCampos	:= {"CTS_CONTAG","CTS_NOME","CTS_IDENTI","CTS_TPSALD","CTS_CTASUP","CTS_COLUNA","CTS_VISENT","CTS_FATSLD","CTS_CLASSE","CTS_IDENT","CTS_DESCCG",;
				"CTS_TOTVIS","CTS_SLDENT","CTS_DETHCG","CTS_TPVALO","CTS_ORDEM","CTS_CODPLA","CTS_NORMAL","CTS_PICTUR"}
EndIf
aHeader 	:= GetaHeader("CTS",      ,aNoCampos,{},,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processo para exibir os campos das novas entidades apos os campos das entidades padroes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAuxHead := GetaHeader("CTS",{"CTS_IDENTI","CTS_TPSALD"},,{},,.F.)

aEval(aAuxHead, {|x|aAdd(aHeader, x)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do CTS                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aCols	:=	Array(1,Len(aHeader)+1)
For nX:=1 To Len(aHeader)
	aCols[1][nX]	:=	CriaVar(aHeader[nX,2],.T.)
Next
aCols[1,nX]	:=	.F.
nPosLin 	:= ASCAN(aHeader,{|x| Alltrim(x[2]) == "CTS_LINHA"})
aCols[1,nPosLin] := StrZero(1,Len(CTS->CTS_LINHA))
aEmptyCols := aClone(aCols)

oGet:= MsNewGetDados():New(0,0,50,70,GD_INSERT+GD_DELETE+GD_UPDATE,"Ctb161LOK","Ctb161GOk","+CTS_LINHA/CTS_IDENTI",,,nMax,,,,oPanel_3,aHeader,aCols)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet:Disable()


oArea		:ShowLayout ( "VISAOCVE" )
oArea	 	:ActDialog ()

//Ponto de Entrada ao Final, após fechar o Dialog
If ExistBlock("CT161FIM")
	ExecBlock("CT161FIM",.F.,.F., {IIf(lInclusao, 03, nOpc), CVE->CVE_CODIGO})
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TreeMenupop ³ Autor ³ Davi Torchio        ³ Data ³ 01/12/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao para criacao do popmenu da arvore                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//------------- funcao para criacao do popmenu da arvore ----------------
Static Function TreeMenupop(oDlg,oMenu,oTree,x,y,z)
nZ:=y-nPop1
nK:= z-nPop2
oMenu:Activate(nz,nk,oDlg)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADDTreeCVF   ºAutor  ³Bruno Sobieski  º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a arvore com base em um nodo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AddTreeCVF(oTreeCVF,cPai,lRefresh,lErro)//x1,x2,x3,oTreeCVF,oArea
Local aArea	:=	GetArea()
Local lDETHCG := .T.
DEFAULT lRefresh	:=	.F.
DEFAULT lErro	:=	.F.
DEFAULT cPai	:=	Criavar('CVF_CTASUP',.F.)
If mv_par05 == 1
	If	aSCAN(oTreeCVF:aNodes,{|x| x[1]==oTreeCVF:CurrentNodeID  })  == 0
		DbSelectArea("CVF")
		DbSetOrder(2)

		If DbSeek(xFilial()+CVE->CVE_CODIGO+cPai)
			While ! CVF->(EOF()).And. xFilial()+CVE->CVE_CODIGO+cPai == CVF_FILIAL+CVF_CODIGO+CVF_CTASUP
			    IF CVF->CVF_CLASSE == "2" .And. Empty(ALLTRIM(CVF->CVF_CTASUP))
					Aviso(STR0084,	STR0091+CRLF+;  //"Atencao"##"Inconsistencia na estrutura da visão gerencial. "
									STR0092+CRLF+;  //"Verifique hierarquia e a classificação das contas gerenciais."
									STR0041+": "+CVF->CVF_CONTAG+;  //"Conta Gerencial"
									STR0093+": "+CVF->CVF_CTASUP+CRLF+;  //"Conta Superior"
									STR0070+" "+CVF->CVF_CLASSE+"-"+If(CVF->CVF_CLASSE=="1", STR0094, STR0095), {"Ok"})   //"Classe"##"Sintetica"##"Analitica"
					lErro := .T.
					EXIT
		        ENDIF
			    IF CVF->CVF_CLASSE == "1"
					If Empty(ALLTRIM(CVF->CVF_CTASUP) ) .And. !lRefresh
						oTreeCVF:AddTree ( Alltrim(CVF->CVF_CONTAG)+'-'+AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),  "folder516","FOLDER616" ,	CVF->CVF_CONTAG)
						oTreeCVF:EndTree()
			    	Else
					    oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG)+'-'+AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG,"folder516","FOLDER616",2,)
					Endif
			  	ELSE
			 		oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG) + ' - ' +AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))), CVF->CVF_CONTAG,"BMPVISUAL16","BMPVISUAL16",2,)
				Endif
				CVF->(DBSKIP())
			EndDo
		EndIf
	EndIf
Else
	DbSelectArea("CVF")
	DbSetOrder(4)
	DbSeek(xFilial()+CVE->CVE_CODIGO)
	While ! CVF->(EOF()).And. xFilial()+CVE->CVE_CODIGO == CVF_FILIAL+CVF_CODIGO
		If CVF->CVF_IDENT == '4' //TOtal
			cBitMap:= 'COLTOT16'
		ElseIf CVF->CVF_IDENT = '5' .And. Alltrim(CVF->CVF_DESCCG) == "-"   //traco
			cBitMap:= 'PMSTASK116'
		ElseIf ( CVF->CVF_IDENT = '5' .Or. CVF->CVF_IDENT = '6' ) .And. Alltrim(CVF->CVF_DESCCG) <> "-" //Separador
			cBitMap:= 'PMSTASK316'
		Else
		    IF CVF_CLASSE == "1"
				cBitMap:= "SDUSUM16"
			Else
				cBitMap:= "BMPVISUAL16"
			Endif
		Endif
		oTreeCVF:AddTree ( Alltrim(CVF->CVF_CONTAG)+'-'+AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),  cBitMap,cBitMap ,	CVF->CVF_CONTAG)
		oTreeCVF:EndTree()
		CVF->(DBSKIP())
	EndDo
Endif
REstArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PosicionaCVF ºAutor  ³Bruno Sobieski  º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por atualziar os dados quando se navega  º±±
±±º          ³na arvore                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PosicionaCVF(oTreeCVF,x2,x3,cCodigo,oArea,oGetCVE,oGetCVF,oGetD)
Local cCodigoAnt	:=	""
Local nX
Local lDETHCG := .T.
Default cCodigo:= oTreeCVF:GetCargo()
cCodigoAnt	:=	CVF->CVF_CONTAG
lSintAnt	:=	!lLastCVE	.And. (CVF->CVF_CLASSE == "1")
If !Empty( cCodigo ) .AND. cCodigo <> 'ID_PRINCIPAL'
	lLastCVE	:=	.F.
	dbSelectArea("CVF")
	dbSetOrder(1)
	dbSeek(xFilial()+CVE->CVE_CODIGO+cCodigo)

	RegToMemory("CVF",.F.,,,FunName())

	aCols	:=	{}
	DbSelectArea('CTS')
	DbSetOrder(2)
	DbSeek(xFilial('CTS')+CVE->CVE_CODIGO+CVF->CVF_CONTAG)
	While xFilial("CTS")+CTS->CTS_CODPLA+CTS->CTS_CONTAG ==	xFilial('CTS')+CVE->CVE_CODIGO+CVF->CVF_CONTAG
		If CTS->CTS_CLASSE != "1" .Or. (CTS->CTS_CLASSE == "1" .And. M->CVF_TOTAL)
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
	DbSelectArea("CVF")

	If MV_PAR05 == 2
		aAreaCVF	:=	CVF->(GetArea())		//Restaurar Bitmaps
		If !Empty(cCodigoAnt) .And. lSintAnt
			CVF->(DbSetOrder(2))
			CVF->(DbSeek(xFilial()+CVE->CVE_CODIGO+cCodigoAnt))
			While xFilial('CVF')+CVE->CVE_CODIGO+cCodigoAnt == CVF->(CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_CTASUP)
				oTreeCVF:ChangePrompt(Alltrim(CVF->CVF_CONTAG) + ' - ' + AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG)
				CVF->(DbSkip())
			Enddo
		Endif
		If M->CVF_CLASSE == "1"
			CVF->(DbSeek(xFilial()+CVE->CVE_CODIGO+M->CVF_CONTAG))
			CVF->(DbSetOrder(2))
			CVF->(DbSeek(xFilial()+CVE->CVE_CODIGO+M->CVF_CONTAG))
			While xFilial('CVF')+CVE->CVE_CODIGO+M->CVF_CONTAG == CVF->(CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_CTASUP)
				oTreeCVF:ChangePrompt('**'+Alltrim(CVF->CVF_CONTAG) + ' - ' + Alltrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,"")))+"**",CVF->CVF_CONTAG)
				CVF->(DbSkip())
			Enddo
		Endif
		RestArea(aAreaCVF)
	Else
		If M->CVF_CLASSE == "1"
			AddTreeCVF(oTreeCVF,M->CVF_CONTAG)
		Endif
	Endif
	oGetD:oBrowse:Refresh()
Else
	lLastCVE	:=	.T.
	If MV_PAR05 == 2
		aAreaCVF	:=	CVF->(GetArea())		//Restaurar Bitmaps
		If !Empty(cCodigoAnt) .And. lSintAnt
			CVF->(DbSetOrder(2))
			CVF->(DbSeek(xFilial()+CVE->CVE_CODIGO+cCodigoAnt))
			While xFilial('CVF')+CVE->CVE_CODIGO+cCodigoAnt == CVF->(CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_CTASUP)
				oTreeCVF:ChangePrompt(Alltrim(CVF->CVF_CONTAG) + ' - ' + AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG)
				CVF->(DbSkip())
			Enddo
		Else
			CVF->(DbSetOrder(2))
			CVF->(DbSeek(xFilial()+CVE->CVE_CODIGO))
			While xFilial('CVF')+CVE->CVE_CODIGO == CVF->(CVF_FILIAL+CVF->CVF_CODIGO)
				oTreeCVF:ChangePrompt(Alltrim(CVF->CVF_CONTAG) + ' - ' + AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG)
				CVF->(DbSkip())
			Enddo
		Endif
	Endif
Endif
If ValType(oArea) == 'O'
	If cCodigo == 'ID_PRINCIPAL'
		DbSelectArea("CVE")
		oArea:ShowLayout ( "VISAOCVE" )
		If ValType(oGetCVE) == 'O'
			oGetCVE:EnchRefreshAll()
		EndIf
	Else
		DbSelectArea("CVF")
		oArea:ShowLayout ( "ANALITICA" )
		If ValType(oGetCVF) == 'O'
			oGetCVF:EnchRefreshAll()
		EndIf
	EndIf
EndIf


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FaManutCVEºAutor  ³Davi Torchio    º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manutencao da tabe;a CVE                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/FUNCAO NAUM UTILIZADA/Static Function FAManutCVE(cAlias,nReg,nOpc,oTree,oGetCVE,oVisao,aObjects)
Local lOk	:=	.F.
Local oNewGetCVE
Local nTop		:= oGetCVE:oBox:nTop-12 //O 12 eh o tamanho da toolbar
Local nBottom	:= oGetCVE:oBox:nBottom
Local nLeft		:= oGetCVE:oBox:nLeft
Local nRight	:= oGetCVE:oBox:nRight


If nOpc == 4 //4. Alteração
	If SoftLock('CVE')
		lOk	:=	.T.

		INCLUI	:=	.F.
		ALTERA	:=	.T.
		EXCLUI	:=	.F.

		oGetCVE:oBox:FreeChildren()
		RegToMemory("CVE",.F.,,,FunName())
		oNewGetCVE:= MsMGet():New("CVE", CVE->(RecNo()),4,,,,,{nTop,nLeft,nRight,nBottom},,4,,,,oVisao,,,.F.)
		oArea:ShowLayout("VISAOCVE")
		oNewGetCVE:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		SetStatusVis(aObjects,VISAO_ALTERA,1)
		oArea:SetTitleWindow('VISAOCVE',STR0060)
	Else
		MsgStop(STR0042)		 //'O registro está em uso, tente novamente.'
	Endif
EndIf

Return If(lOk,oNewGetCVE,oGetCVE)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FaManutCtaºAutor  ³Davi Torchio    º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manutencao da tabe;a CVF                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FAManutConta(cAlias,nReg,nOpc,oTree,oGetCVF,oVisao, aObjects,oGetD,oArea)
Local lOk	:=	.F.
Local oNewGetCVF
Local nTop		:= oGetCVF:oBox:nTop-12 //O 12 eh o tamanho da toolbar
Local nBottom	:= oGetCVF:oBox:nBottom
Local nLeft		:= oGetCVF:oBox:nLeft
Local nRight	:= oGetCVF:oBox:nRight
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
	oGetCVF:oBox:FreeChildren()

	RegToMemory("CVF",.T.,,,FunName())
	M->CVF_ORDEM  := cOrdem
	M->CVF_CONTAG := Ctb161Prox( .T. )
	M->CVF_FILIAL := xFilial()
    If cCargo == "ID_PRINCIPAL"
		M->CVF_CTASUP := Space(Len(CVF->CVF_CTASUP))
	Else
		M->CVF_CTASUP := cCargo
	Endif

	oNewGetCVF:= MsMGet():New("CVF",/*CVF->(RecNo())*/,3,,,,,{oVisao:nTop,oVisao:nLeft,oVisao:nHeight,oVisao:nWidth/2.5},,4,,,,oVisao,,,.F.,"aTelaCVF")

	M->CVF_CODIGO := CVE->CVE_CODIGO


	oArea:ShowLayout ( "ANALITICA" )

	oNewGetCVF:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	oArea :SetTiTleWindow ( "CONTA_A", STR0043 )	 //"Visao Gerencial - Inclusao"

	oGetD:aCols	:=	aClone(aEmptyCols)
	oGetD:oBrowse:Refresh()

ElseIf nOpc == 4 //4. Alteração
   	DbSelectArea('CVF')
   	DbSetOrder(1)
   	DbSeek(xFilial()+CVE->CVE_CODIGO+cCargo)
	If SoftLock('CVF')
		lOK		:=	.T.
		INCLUI	:=	.F.
		ALTERA	:=	.T.
		EXCLUI	:=	.F.
		oGetCVF:oBox:FreeChildren()

		RegToMemory("CVF",.F.,,,FunName())

		oArea :SetTiTleWindow ( "CONTA_A", STR0044 )	 //"Visao Gerencial - Alteracao"
//		oNewGetCVF:= MsMGet():New("CVF", CVF->(RecNo()),4,,,,,{nTop,nLeft,nRight,nBottom},,4,,,,oVisao,,,.F.,"aTelaCVF")
		oNewGetCVF:= MsMGet():New("CVF", CVF->(RecNo()),4,,,,,{oVisao:nTop,oVisao:nLeft,oVisao:nHeight,oVisao:nWidth/2.5},,4,,,,oVisao,,,.F.,"aTelaCVF")

		oArea:ShowLayout("ANALITICA")

		oNewGetCVF:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		SetStatusVis(aObjects,CONTA_ALTERA,2)
		SetStatusVis(aObjects,CONTA_ALTERA2,2)
	Else
			MsgStop(STR0018) //'Nao pode ser lockado'
	Endif

ElseIf nOpc == 5 //5. Exclusao
   	DbSelectArea('CVF')
   	DbSetOrder(1)
   	DbSeek(xFilial()+CVE->CVE_CODIGO+cCargo)
	If SoftLock('CVF')
		INCLUI	:=	.F.
		ALTERA	:=	.F.
		EXCLUI	:=	.T.
		nOpcao := 0
		If CVF->CVF_CLASSE == "2"
			nOpcao := Aviso(STR0008,STR0016,{STR0010,STR0011}) //"Confirmacao"###"Confirma exclusao da conta gerencial" //"Ok"###"Cancela"
		Else
			nOpcao := Aviso(STR0008,STR0017,{STR0010,STR0011})	         //"Confirmacao"###"Confirma exclusao da conta gerencial (serao excluidas todas as contas dependentes)." //"Ok"###"Cancela"
    	Endif

		If nOpcao == 1
			Begin Transaction
			If CVF->CVF_CLASSE == "2"
				DbSelectArea('CTS')
				DbSetOrder(2)
				DbSeek(xFilial()+CVF->CVF_CODIGO+CVF->CVF_CONTAG)
				While !Eof() .And. xFilial()+CVF->CVF_CODIGO+CVF->CVF_CONTAG == CTS_FILIAL+CTS_CODPLA+CTS->CTS_CONTAG
					RecLock('CTS',.F.)
					DbDelete()
					MsUnLock()
					DbSkip()
               	Enddo

				If Empty(CVF->CVF_CTASUP)
					cSeek	:= 'ID_PRINCIPAL'
				Else
					cSeek	:= CVF->CVF_CTASUP
				Endif
				RecLock('CVF',.F.)
				DbDelete()
				MsUnLock()
				oTree:DelItem()
	        ElseIf CVF->CVF_CLASSE == "1"
	        	cChave	:=	xFilial('CVF')+CVF->CVF_CODIGO+CVF->CVF_CTASUP
				DbSelectArea('CTS')
				DbSetOrder(2)
				DbSeek(xFilial()+CVF->CVF_CODIGO+CVF->CVF_CONTAG)
				While !Eof() .And. xFilial()+CVF->CVF_CODIGO+CVF->CVF_CONTAG == CTS_FILIAL+CTS_CODPLA+CTS->CTS_CONTAG
					RecLock('CTS',.F.)
					DbDelete()
					MsUnLock()
					DbSkip()
               	Enddo
               	aadd(aFather,CVF->CVF_CONTAG)
				If Empty(CVF->CVF_CTASUP)
					cSeek	:= 'ID_PRINCIPAL'
				Else
					cSeek	:= CVF->CVF_CTASUP
				Endif
				cCVFDel	:=	CVF->CVF_CONTAG
				RecLock('CVF',.F.)
				DbDelete()
				MsUnLock()
				lInRefresh	:=	.T.
				oTree:DelItem()
				//Apagar os filhos
				While Len(aFather) > 0
					nX:=1
					DbSelectArea('CVF')
					DbSetOrder(2)
					DbSeek(xFilial()+CVF->CVF_CODIGO+aFather[nX])
					While !Eof().And. xFilial()+CVF->CVF_CODIGO+aFather[nX]== CVF->CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_CTASUP
						DbSelectArea('CTS')
						DbSetOrder(2)
						DbSeek(xFilial()+CVF->CVF_CODIGO+CVF->CVF_CONTAG)
						While !Eof() .And. xFilial()+CVF->CVF_CODIGO+CVF->CVF_CONTAG == CTS_FILIAL+CTS_CODPLA+CTS->CTS_CONTAG
							RecLock('CTS',.F.)
							DbDelete()
							MsUnLock()
							DbSkip()
	               		Enddo
	               		//Carregar no a father os proximos pais
						If CVF->CVF_CLASSE == '1'
							AAdd(aFather,CVF->CVF_CONTAG)
						Endif
						//Se for nao estruturado, apaga o filho da arvore tb
						If mv_par05 == 2 .And. oTree:TreeSeek(CVF->CVF_CONTAG)
							nRecCVF:=CVF->(Recno())
							oTree:DelItem()
//			    			oTree:TreeSeek(cCVFDel)
			    			CVF->(MsGoTo(nRecCVF))
    						CVF->(DbSetOrder(2)) //o TreeSeek muda a ordem do CVF no bChange
    					Endif
    					//Apaga o Nodo
						DbSelectArea('CVF')
						RecLock('CVF',.F.)
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
		MsgStop(STR0018) //'Nao pode ser lockado'
	Endif
EndIf

Return If(lOk,oNewGetCVF,oGetCVF)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CANCCVEVISºAutor  ³Davi Torchio    º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela edicao da tabela CVE                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


/FUNCAO NAUM UTILIZADA/Static Function CancCVEVis(oTreeCVF,oGetCVE,oPanelCapa)

Local oNewGetCVE
Local nTop		:= oGetCVE:oBox:nTop-12 //O 12 eh o tamanho da toolbar
Local nBottom	:= oGetCVE:oBox:nBottom
Local nLeft		:= oGetCVE:oBox:nLeft
Local nRight	:= oGetCVE:oBox:nRight

INCLUI	:=	.F.
ALTERA	:=	.F.
EXCLUI	:=	.F.
oGetCVE:oBox:FreeChildren()
oNewGetCVE:= MsMGet():New("CVE", CVE->(RecNo()),2,,,,,{nTop,nLeft,nRight,nBottom},,2,,,,oPanelCapa,,,.F.,"aTela")
oNewGetCVE:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oArea:SetTitleWindow('VISAOCVE',STR0012)

INCLUI	:=	.F.
ALTERA	:=	.F.
EXCLUI	:=	.F.

Return oNewGetCVE
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConfCVEVISºAutor  ³Davi Torchio    º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirma Edicao da tabela CVE                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/FUNCAO NAUM UTILIZADA/Static Function ConfCVEVis(oTreeCVF,oGetCVE,oPanel,aObjects)
Local lOk	:=	.F.
Local oNewGetCVE
Local nTop		:= oGetCVE:oBox:nTop-12 //O 12 eh o tamanho da toolbar
Local nBottom	:= oGetCVE:oBox:nBottom
Local nLeft		:= oGetCVE:oBox:nLeft
Local nRight	:= oGetCVE:oBox:nRight
Local cCargo 	:= oTreeCVF:GetCargo()
Local cTudoOk   := ""
Local nX
If Obrigatorio(oGetCVE:aGets,oGetCVE:aTela)
	lOk	:=	.T.
	DbSelectArea('CVE')
	For nX := 1 To FCount()
		FieldPut(nX,&("M->"+FieldName(nX)) )
	Next
	MsUnLock()
	dbSelectArea("CTS")
	dbSetOrder(1)
	MsSeek(xFilial("CTS")+CVE->CVE_CODIGO,.T.)
	While CTS->(!Eof()) .and. CTS->CTS_CODPLA == CVE->CVE_CODIGO
		If CTS->CTS_NOME <> CVE->CVE_DESCRI
			RecLock("CTS",.F.)
			Replace CTS_NOME	With CVE->CVE_DESCRI
			CTS->(MsUnlock())
		Endif
		CTS->(dbSkip())
	EndDo
	INCLUI	:=	.F.
	ALTERA	:=	.F.
	EXCLUI	:=	.F.
	oGetCVE:oBox:FreeChildren()
	RegToMemory("CVE",.F.,,,FunName())
	oNewGetCVE:= MsMGet():New("CVE", CVE->(RecNo()),2,,,,,{nTop,nLeft,nRight,nBottom},,2,,,,oPanel,,,.F.,"aTela")
	oNewGetCVE:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oTreeCVF:ChangePrompt(CVE->CVE_DESCRI ,cCargo)
	oArea:SetTitleWindow('VISAOCVE',STR0012)
Endif

If lOk
	INCLUI	:=	.F.
	ALTERA	:=	.F.
	EXCLUI	:=	.F.
Else
	SetStatusVis(aObjects,VISAO_ALTERA,1)
	SetStatusVis(aObjects,VISAO_ALTERA,2)
Endif
Return IIf(lOk,oNewGetCVE,oGetCVE)
*//*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConfOperVis Autor  ³Davi Torchio    º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirma edicao da tabela CVF                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ConfOperVis(oTreeCVF,oGetCVF,oPanel,aObjects)
Local lOk	:=	.F.
Local lRet  :=  .T.
Local oNewGetCVF
Local nTop		:= oGetCVF:oBox:nTop-12 //O 12 eh o tamanho da toolbar
Local nBottom	:= oGetCVF:oBox:nBottom
Local nLeft		:= oGetCVF:oBox:nLeft
Local nRight	:= oGetCVF:oBox:nRight
Local cCargo 	:= oTreeCVF:GetCargo()
Local cTudoOk   := ""
Local lInclui	:=	INCLUI
Local nX
Local nI
Local lDETHCG 	:= .T.
Local lSavDes   := Alltrim(CVF->CVF_DESCCG)

If cPaisLoc!='RUS'
	//---- VERIFICA SE EXISTE CARACTERES ESPECIAIS NA ENTIDADE GERENCIAL.
	For nI:=1 to Len(CVF->CVF_CONTAG)
		If (ASC(Substr(M->CVF_CONTAG,nI,1)) >= 33 .And. ASC(Substr(M->CVF_CONTAG,nI,1)) < 46) .Or.;
					(ASC(Substr(M->CVF_CONTAG,nI,1)) >= 58 .And. ASC(Substr(M->CVF_CONTAG,nI,1)) <= 64) .Or.;
					(ASC(Substr(M->CVF_CONTAG,nI,1)) >= 91 .And. ASC(Substr(M->CVF_CONTAG,nI,1)) <= 96) .Or.;
					(ASC(Substr(M->CVF_CONTAG,nI,1)) >= 123 .And. ASC(Substr(M->CVF_CONTAG,nI,1)) <= 126)
			MsgInfo("A entidade gerencial possui caracteres invalidos. Sao caracteres validos apenas letras e numeros.")//O ID da formula possui caracteres invalidos. Sao caracteres validos apenas letras e numeros."
			lRet := .F.
			Exit
		EndIf
	Next nI
Endif

If cPaisLoc == 'RUS' .and. M->CVF_CLASSE == '2' .and. Empty(M->CVF_CTASUP)
	Help(" ",1,"CTB161A01")
	lRet := .F.
Endif

If lRet
	lRet := CT161VlTot()
EndIf

//Bloco de código com a validação do usuário
If lRet
	If ExistBlock("CT161TOK")
		xRet := ExecBlock("CT161TOK",.F.,.F.)
		If ValType(xRet) == "L"
			lRet := xRet
		EndIf
	EndIf
EndIf

If M->CVF_TRACO
	If Aviso(STR0097,STR0098, {STR0099, STR0100})== 2
		M->CVF_DESCCG := lSavDes
		M->CVF_TRACO  := .F.
		lRet := .F.
	EndIf
Endif

IF lRet
	If Obrigatorio(oGetCVF:aGets,oGetCVF:aTela)
		lOk	:=	.T.

		DbSelectArea('CVF')
		RecLock('CVF',INCLUI)
		For nX := 1 To FCount()
			FieldPut(nX,&("M->"+FieldName(nX)) )
		Next
		CVF_IDENT	:=	" "
        If M->CVF_CLASSE != "2"
			If M->CVF_NEGRIT .And. M->CVF_SEPARA
				Replace CVF_IDENT With "6"
			Else
				IF M->CVF_NEGRIT
					Replace CVF_IDENT With "3"
				ElseIf M->CVF_TOTAL
					Replace CVF_IDENT With "4"
				ElseIf M->CVF_SEPARA
					Replace CVF_IDENT With "5"
				ElseIf M->CVF_TRACO
					Replace CVF_DESCCG With "-"
					Replace CVF_IDENT  With "5"
				Endif
			Endif
		Endif

		MsUnLock()
		If INCLUI
			RecLock("CTS",.T.)
			Replace CTS_FILIAL	With xFilial()
			Replace CTS_CODPLA	With CVE->CVE_CODIGO
			Replace CTS_NOME   	With CVE->CVE_DESCRI
			Replace CTS_ORDEM  	With CVF->CVF_ORDEM
			Replace CTS_CONTAG	With CVF->CVF_CONTAG
			Replace CTS_CTASUP	With CVF->CVF_CTASUP
			Replace CTS_CLASSE	With CVF->CVF_CLASSE
			Replace CTS_NORMAL	With CVF->CVF_NORMAL
			Replace CTS_DESCCG	With CVF->CVF_DESCCG
			If lDETHCG
				Replace CTS_DETHCG	With CVF->CVF_DETHCG
			EndIf
			If __Release .and. __lCOLUN2
				Replace CTS_COLUN2	With  CVF->CVF_COLUNA
			Else
				 Replace CTS_COLUNA With  GetCTSCol(CVF->CVF_COLUNA,cTipoCTS)
			Endif
			Replace CTS_LINHA	With StrZero(1,Len(CTS->CTS_LINHA))

			If CVF->CVF_CLASSE == "1"
				Replace CTS_IDENT	WITH CVF->CVF_IDENT
			EndIf

			Replace CTS_TOTVIS With CVF->CVF_TOTVIS
			Replace CTS_VISENT With CVF->CVF_VISENT
			Replace CTS_SLDENT With CVF->CVF_SLDENT
			Replace CTS_FATSLD With CVF->CVF_FATSLD
			If cPaisLoc $ "BRA/PAD"
				Replace CTS_TPVALO With CVF->CVF_TPVALO
				Replace CTS_PICTUR With CVF->CVF_PICTUR
			EndIf

			MsUnLock()
			// P E para sincronismo de campos do usuário
			If ExistBlock("C161CTSI")
				ExecBlock("C161CTSI",.F.,.F.)
			EndIf
		ELSE

			DbSelectArea('CTS')
			DbSetOrder(2)
			DbSeek(xFilial('CTS')+CVE->CVE_CODIGO+CVF->CVF_CONTAG)
			While CTS->(! Eof() .And. CTS_FILIAL+CTS_CODPLA+CTS_CONTAG==xFilial('CTS')+CVE->CVE_CODIGO+CVF->CVF_CONTAG)
				RecLock("CTS",.F.)
				Replace CTS_ORDEM	With CVF->CVF_ORDEM                         //ATENCAO POIS EH PARTE DA CHAVE UNICA
				Replace CTS_CTASUP	With CVF->CVF_CTASUP
				Replace CTS_CLASSE	With CVF->CVF_CLASSE
				Replace CTS_NORMAL	With CVF->CVF_NORMAL
				Replace CTS_DESCCG	With CVF->CVF_DESCCG
				If lDETHCG
					Replace CTS_DETHCG	With CVF->CVF_DETHCG
				EndIf
				If __Release .and. __lCOLUN2
					Replace CTS_COLUN2 With  CVF->CVF_COLUNA
				Else
					Replace CTS_COLUNA	With  GetCTSCol(CVF->CVF_COLUNA,cTipoCTS)
				Endif
				
				If CVF->CVF_CLASSE == "1"
					Replace CTS_IDENT	WITH CVF->CVF_IDENT
				EndIf
				Replace CTS_TOTVIS With CVF->CVF_TOTVIS
				Replace CTS_VISENT With CVF->CVF_VISENT
				Replace CTS_SLDENT With CVF->CVF_SLDENT
				Replace CTS_FATSLD With CVF->CVF_FATSLD

				If cPaisLoc $ "BRA/PAD"
					Replace CTS_TPVALO With CVF->CVF_TPVALO
					Replace CTS_PICTUR With CVF->CVF_PICTUR
				EndIf

				MsUnLock()
				// P E para sincronismo de campos do usuário
				If ExistBlock("C161CTSA")
					ExecBlock("C161CTSA",.F.,.F.)
				EndIf
				CTS->(Dbskip())
			EndDo
		Endif
		DbSelectArea('CVF')
		oGetCVF:oBox:FreeChildren()
		RegToMemory("CVF",.F.,,,FunName())
//		oNewGetCVF:= MsMGet():New("CVF", CVF->(RecNo()),2,,,,,{nTop,nLeft,nRight,nBottom},,2,,,,oPanel,,,.F.,"aTelaCVF")
		oNewGetCVF:= MsMGet():New("CVF", CVF->(RecNo()),2,,,,,{oPanel:nTop,oPanel:nLeft,oPanel:nHeight,oPanel:nWidth/2.5},,2,,,,oPanel,,,.F.,"aTelaCVF")
		oNewGetCVF:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		//Mudar, deve ser recostruido todo o nodo para que inclua ordenado
		If lInclui
			IF CVF->CVF_CLASSE == "1"
				IF MV_PAR05 == 1
					If Empty(ALLTRIM(CVF->CVF_CTASUP) )
						oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG)+'-'+AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG,"folder516","folder616",2,)
					Else
						oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG)+'-'+AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG,"folder516","folder616",2,)
					Endif
				ELSE
					If Empty(ALLTRIM(CVF->CVF_CTASUP) )
						oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG)+'-'+AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG,"SDUSUM16","SDUSUM16",1,)
					Else
						oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG)+'-'+AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))),CVF->CVF_CONTAG,"SDUSUM16","SDUSUM16",1,)
					EndIf
				Endif
			ELSE
				IF MV_PAR05 == 1
					oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG) + ' - ' + AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))), CVF->CVF_CONTAG,"BMPVISUAL16","BMPVISUAL16",2,)
				Else
					oTreeCVF:AddItem( Alltrim(CVF->CVF_CONTAG) + ' - ' + AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))), CVF->CVF_CONTAG,"BMPVISUAL16","BMPVISUAL16",1,)
				Endif
			Endif
			oTreeCVF:TreeSeek(CVF->CVF_CONTAG)
		Else
			If CVF->CVF_IDENT == '4' //TOtal
				cBitMap:= 'COLTOT16'
			ElseIf CVF->CVF_IDENT = '5' .And. Alltrim(CVF->CVF_DESCCG) == "-" //traco
				cBitMap:= 'PMSTASK116'
			ElseIf ( CVF->CVF_IDENT = '5' .OR. CVF->CVF_IDENT = '5' ) .And. Alltrim(CVF->CVF_DESCCG) <> "-" //Separador
				cBitMap:= 'PMSTASK316'
			Else
				IF CVF->CVF_CLASSE == "1"
					cBitMap:= "SDUSUM16"
				Else
					cBitMap:= "BMPVISUAL16"
				Endif
			Endif
			oTreeCVF:ChangeBmp(cBitMap,cBitMap,CVF->CVF_CONTAG)
			oTreeCVF:ChangePrompt(AllTrim(CVF->CVF_CONTAG) + ' - ' + AllTrim(CVF->(CVF_DESCCG+IIF(lDETHCG,CVF_DETHCG,""))) ,cCargo)
		Endif
	Endif
Endif


If lOk
	INCLUI	:=	.F.
	ALTERA	:=	.F.
	EXCLUI	:=	.F.
	If !lInclui
		cCtaSup	  := CVF->CVF_CTASUP
		cCodCVF   := CVF->CVF_CODIGO
		cOrdem    := CVF->CVF_ORDEM
		RefreshTree(oTreeCVF,oPsideBar,.T.,cCtaSup,cCodCVF,cOrdem)
	EndIf
	oArea :SetTiTleWindow ( "CONTA_A", STR0041 )	 //"Conta Gerencial"
Else
	SetStatusVis(aObjects,CONTA_INCLUI,1)
	SetStatusVis(aObjects,CONTA_INCLUI,2)
Endif

Return IIf(lOk,oNewGetCVF,oGetCVF)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CancOperVis º Autor ³Davi Torchio      º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela edicao da tabela CVF                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CancOperVis(oTreeCVF,oGetCVF,oPanel)

Local oNewGetCVF
Local nTop		:= oGetCVF:oBox:nTop-12 //O 12 eh o tamanho da toolbar
Local nBottom	:= oGetCVF:oBox:nBottom
Local nLeft		:= oGetCVF:oBox:nLeft
Local nRight	:= oGetCVF:oBox:nRight

INCLUI	:=	.F.
ALTERA	:=	.F.
EXCLUI	:=	.F.
oGetCVF:oBox:FreeChildren()
RegToMemory("CVF",.F.,,,FunName())
//oNewGetCVF:= MsMGet():New("CVF", CVF->(RecNo()),2,,,,,{nTop,nLeft,nRight,nBottom},,2,,,,oPanel,,,.F.,"aTelaCVF")
oNewGetCVF:= MsMGet():New("CVF", CVF->(RecNo()),2,,,,,{oPanel:nTop,oPanel:nLeft,oPanel:nHeight,oPanel:nWidth/2.5},,2,,,,oPanel,,,.F.,"aTelaCVF")
oNewGetCVF:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oArea :SetTiTleWindow ( "CONTA_A", STR0041 )	 //"Conta Gerencial"

Return oNewGetCVF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DefineStatusVis  ³ Autor ³ Davi Torchio   ³ Data ³ 01/12/07          ³±±
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .F. }
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .F. }
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .F. }
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .T. }
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .T. } 
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .F. }
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .T. } 
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .T. } 
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .F. }  
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
	aObjects[nOper,3,CONTA_NOTAEXP]	:= {|| .F. }  
Case nOper == VISAO_CANCELA
EndCase
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SetStatusVis     ³ Autor ³ Davi Torchio   ³ Data ³ 01/12/07          ³±±
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
±±³Fun‡…o	 ³Ctb160LOK ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 08/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da linha da Getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160Lok()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA160                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161LOK(oObj)

Local aSaveArea:= GetArea()
Local lRet		:= .T.

Local nPosCtaIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CT1INI"})
Local nPosCtaFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CT1FIM"})
Local nPosCCIni		:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTTINI"})
Local nPosCCFim		:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTTFIM"})
Local nPosItemIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTDINI"})
Local nPosItemFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTDFIM"})
Local nPosCLVLIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTHINI"})
Local nPosCLVLFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTHFIM"})
Local nPosIdent		:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_IDENTI"})
Local nPosFormula	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_FORMUL"})
//Campos referentes as novas entidades contabeis
Local nPosE05Ini := If(_lCpoEnt05,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E05INI"}),Nil)
Local nPosE05Fim := If(_lCpoEnt05,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E05FIM"}),Nil)
Local nPosE06Ini := If(_lCpoEnt06,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E06INI"}),Nil)
Local nPosE06Fim := If(_lCpoEnt06,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E06FIM"}),Nil)
Local nPosE07Ini := If(_lCpoEnt07,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E07INI"}),Nil)
Local nPosE07Fim := If(_lCpoEnt07,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E07FIM"}),Nil)
Local nPosE08Ini := If(_lCpoEnt08,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E08INI"}),Nil)
Local nPosE08Fim := If(_lCpoEnt08,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E08FIM"}),Nil)
Local nPosE09Ini := If(_lCpoEnt09,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E09INI"}),Nil)
Local nPosE09Fim := If(_lCpoEnt09,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E09FIM"}),Nil)

Local nUsado := Len(aHeader)
Local nLine	:=	oObj:nAt

If ALTERAGD
	If M->CVF_CLASSE == "2"						// Verifica Analiticas
		If !aCols[nLine][nUsado+1]
			If 	Empty(aCols[nLine][nPosCtaIni]) 	.And. Empty(aCols[nLine][nPosCCIni]) 	.And.;
				Empty(aCols[nLine][nPosItemIni]) 	.And. Empty(aCols[nLine][nPosCLVLIni]) .And.;
				Empty(aCols[nLine][nPosCtaFim]) 	.And. Empty(aCols[nLine][nPosCCFim]) 	.And.;
				Empty(aCols[nLine][nPosItemFim]) 	.And. Empty(aCols[nLine][nPosCLVLFim]) .And.;
				Empty(aCols[nLine][nPosFormula])	.And.;
				(aCols[nLine][nPosIdent] == "1" .Or. aCols[nLine][nPosIdent] == "2") 		.And.;
				! (M->CVF_NEGRIT .OR. M->CVF_TOTAL .OR. M->CVF_SEPARA .OR. M->CVF_TRACO)
				lRet := .F.
			EndIf

			If(_lCpoEnt05 .And. !lRet,lRet := !Empty(aCols[n][nPosE05Ini]),Nil)
			If(_lCpoEnt05 .And. !lRet,lRet := !Empty(aCols[n][nPosE05Fim]),Nil)
			If(_lCpoEnt06 .And. !lRet,lRet := !Empty(aCols[n][nPosE06Ini]),Nil)
			If(_lCpoEnt06 .And. !lRet,lRet := !Empty(aCols[n][nPosE06Fim]),Nil)
			If(_lCpoEnt07 .And. !lRet,lRet := !Empty(aCols[n][nPosE07Ini]),Nil)
			If(_lCpoEnt07 .And. !lRet,lRet := !Empty(aCols[n][nPosE07Fim]),Nil)
			If(_lCpoEnt08 .And. !lRet,lRet := !Empty(aCols[n][nPosE08Ini]),Nil)
			If(_lCpoEnt08 .And. !lRet,lRet := !Empty(aCols[n][nPosE08Fim]),Nil)
			If(_lCpoEnt09 .And. !lRet,lRet := !Empty(aCols[n][nPosE09Ini]),Nil)
			If(_lCpoEnt09 .And. !lRet,lRet := !Empty(aCols[n][nPosE09Fim]),Nil)

			If !lRet
				Help(" ",1,"C160NOENTI")
			EndIf

			If lRet
				If !Empty(aCols[nLine][nPosCtaIni]) .And. Empty(aCols[nLine][nPosCtaFim])
					Help(" ",1,"C160NOCTA")
					lRet := .F.
				EndIf
		   	EndIf

	   		If lRet
				If !Empty(aCols[nLine][nPosCCIni]) .And. Empty(aCols[nLine][nPosCCFim])
					Help(" ",1,"C160NOCC")
					lRet := .F.
				EndIf
		   	EndIf

	   		If lRet
				If !Empty(aCols[nLine][nPosItemIni]) .And. Empty(aCols[nLine][nPosItemFim])
					Help(" ",1,"C160NOITEM")
					lRet := .F.
				EndIf
		   	EndIf

	   		If lRet
				If !Empty(aCols[nLine][nPosCLVLIni]) .And. Empty(aCols[nLine][nPosCLVLFim])
					Help(" ",1,"C160NOCLVL")
					lRet := .F.
				EndIf
		   	EndIf

			If lRet
				If 	Empty(aCols[nLine][nPosIdent]) .And.;
					!(M->CVF_NEGRIT .Or. M->CVF_Total .Or. M->CVF_Separa .Or. M->CVF_Traco)
					Help(" ",1,"C160NOSIN")
					lRet := .F.
				EndIf
			EndIf

			If _lCpoEnt05 .And. lRet
				If !Empty(aCols[nLine][nPosE05Ini]) .And. Empty(aCols[nLine][nPosE05Fim])
					Help(" ",1,"C160NOEC05")
					lRet := .F.
				EndIf
			EndIf

			If _lCpoEnt06 .And. lRet
				If !Empty(aCols[nLine][nPosE06Ini]) .And. Empty(aCols[nLine][nPosE06Fim])
					Help(" ",1,"C160NOEC06")
					lRet := .F.
				EndIf
			EndIf

			If _lCpoEnt07 .And. lRet
				If !Empty(aCols[nLine][nPosE07Ini]) .And. Empty(aCols[nLine][nPosE07Fim])
					Help(" ",1,"C160NOEC07")
					lRet := .F.
				EndIf
			EndIf

			If _lCpoEnt08 .And. lRet
				If !Empty(aCols[nLine][nPosE08Ini]) .And. Empty(aCols[nLine][nPosE08Fim])
					Help(" ",1,"C160NOEC08")
					lRet := .F.
				EndIf
			EndIf

			If _lCpoEnt09 .And. lRet
				If !Empty(aCols[nLine][nPosE09Ini]) .And. Empty(aCols[nLine][nPosE09Fim])
					Help(" ",1,"C160NOEC09")
					lRet := .F.
				EndIf
			EndIf

		EndIf
	EndIf

	If M->CVF_CLASSE == "1" .And. M->CVF_TOTAL
		If 	!Empty(aCols[nLine][nPosCtaIni]) 	.Or. !Empty(aCols[nLine][nPosCCIni]) 	.Or.;
			!Empty(aCols[nLine][nPosItemIni]) 	.Or. !Empty(aCols[nLine][nPosCLVLIni]) .Or.;
			!Empty(aCols[nLine][nPosCtaFim]) 	.Or. !Empty(aCols[nLine][nPosCCFim]) 	.Or.;
			!Empty(aCols[nLine][nPosItemFim]) 	.Or. !Empty(aCols[nLine][nPosCLVLFim])
	   		lRet := .F.
	    EndIf

		If(_lCpoEnt05 .And. lRet,lRet := Empty(aCols[nLine][nPosE05Ini]),Nil)
		If(_lCpoEnt05 .And. lRet,lRet := Empty(aCols[nLine][nPosE05Fim]),Nil)
		If(_lCpoEnt06 .And. lRet,lRet := Empty(aCols[nLine][nPosE06Ini]),Nil)
		If(_lCpoEnt06 .And. lRet,lRet := Empty(aCols[nLine][nPosE06Fim]),Nil)
		If(_lCpoEnt07 .And. lRet,lRet := Empty(aCols[nLine][nPosE07Ini]),Nil)
		If(_lCpoEnt07 .And. lRet,lRet := Empty(aCols[nLine][nPosE07Fim]),Nil)
		If(_lCpoEnt08 .And. lRet,lRet := Empty(aCols[nLine][nPosE08Ini]),Nil)
		If(_lCpoEnt08 .And. lRet,lRet := Empty(aCols[nLine][nPosE08Fim]),Nil)
		If(_lCpoEnt09 .And. lRet,lRet := Empty(aCols[nLine][nPosE09Ini]),Nil)
		If(_lCpoEnt09 .And. lRet,lRet := Empty(aCols[nLine][nPosE09Fim]),Nil)

		If !lRet
	    	MsgAlert(STR0045,STR0046) //"Conta de total somente pode possuir formula"###"Alerta"
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
±±³Fun‡…o	 ³Ctb161GOk ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 08/11/99 ³±±
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
Function Ctb161GOk(oGetD)

Local lRet		:=	.T.
aCols	:=	oGetD:aCols
lRet	:=	Ctb161LOK(oGetD:oBrowse)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SetStatusVis     ³ Autor ³ Davi Torchio   ³ Data ³ 01/12/07          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao de manutenção da Getdados                         			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaMntGetd(oGet,oTree,aObjects)
Local cCodigo:= Padr(oTree:GetCargo(),Len(CVF->CVF_CONTAG))
dbSelectArea("CVF")
dbSetOrder(1)
dbSeek(xFilial()+CVE->CVE_CODIGO+cCodigo)
If M->CVF_CLASSE == "1" .And. !M->CVF_TOTAL
	Aviso(STR0053,STR0054,{STR0010}) //"Operacao nao permitida"###"Nao é possivel editar o detalhe de uma conta sintetica, quando nao e total geral"###"Ok"
Else
	If SoftLock('CVF')
		SetStatusVis(aObjects,GETD_ALTERA,2)
		oGet:Enable()
		n :=	1
		ALTERAGD := .T.
		oArea :SetTiTleWindow ( "GETDADOS", STR0058 )
	Else
		Aviso(STR0056,STR0057,{STR0010})  //"Arquivo em uso"###"Nao foi possivel ativar a edicao, tente mais tarde"###"Ok"
	Endif
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CancGDVis   		³ Autor ³ Davi Torchio   ³ Data ³ 01/12/07          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao de cancelamento da Getdados                         			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CancGDVis(oTreeCVF,oGet  )
Local cChave	:=	xFilial('CTS')+CVE->CVE_CODIGO+CVF->CVF_CONTAG
Local nPosLin 	:= ASCAN(oGet:aHeader,{|x| Alltrim(x[2]) == "CTS_LINHA"})
Local nX
Private aCols	:=	{}
DbSelectArea('CTS')
DbSetOrder(2)
DbSeek(xFilial('CTS')+CVE->CVE_CODIGO+CVF->CVF_CONTAG)
While xFilial("CTS")+CTS->CTS_CODPLA+CTS->CTS_CONTAG ==	xFilial('CTS')+CVE->CVE_CODIGO+CVF->CVF_CONTAG
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
oArea :SetTiTleWindow ( "GETDADOS", STR0015 )
oGet:oBrowse:Refresh()
oGet:Disable()
ALTERAGD := .F.

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb160Grv ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 08/11/99 ³±±
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
Local nPosLinha := ASCAN(oGetd:aHeader,{|x| Alltrim(x[2]) == "CTS_LINHA"})
Local lCTSNome  := .F.
Local aHeader	:= oGetd:aHeader
Local aCols		:= oGetd:aCols
Local nUsado	:=	Len(aHeader)

dbSelectArea("SX3")				/// VERIFICA SE O CAMPO ESTA EM USO
dbSetOrder(2)
Begin Transaction
For nCont1 := 1 To Len(aCols)

	dbSelectArea("CTS")
	dbSetOrder(1)
	If aCOLS[nCont1][nUsado+1]
		If dbSeek(xFilial()+CVE->CVE_CODIGO+CVF->CVF_ORDEM+aCols[nCont1][nPosLinha])
			RecLock("CTS",.F.,.T.)
			dbDelete()
			MsUnlock()
		Endif
	Else
		If !dbSeek(xFilial()+CVE->CVE_CODIGO+CVF->CVF_ORDEM+aCols[nCont1][nPosLinha])
			nLinhaGd ++
			RecLock("CTS",.T.)
			Replace CTS_FILIAL	With xFilial()
			Replace CTS_CODPLA	With CVE->CVE_CODIGO
			Replace CTS_ORDEM	With CVF->CVF_ORDEM
			Replace CTS_CONTAG	With CVF->CVF_CONTAG
			Replace CTS_CTASUP	With CVF->CVF_CTASUP
			Replace CTS_CLASSE	With CVF->CVF_CLASSE
			Replace CTS_NORMAL	With CVF->CVF_NORMAL
			Replace CTS_DESCCG	With CVF->CVF_DESCCG
			Replace CTS_DETHCG	With CVF->CVF_DETHCG
			If __Release .and. __lCOLUN2
				Replace CTS_COLUN2	With  CVF->CVF_COLUNA
			Else
			 	Replace CTS_COLUNA	With  GetCTSCol(CVF->CVF_COLUNA,cTipoCTS)
			Endif
			Replace CTS_NOME	With CVE->CVE_DESCRI

			Replace CTS_TOTVIS With CVF->CVF_TOTVIS
			Replace CTS_VISENT With CVF->CVF_VISENT
			Replace CTS_SLDENT With CVF->CVF_SLDENT
			Replace CTS_FATSLD With CVF->CVF_FATSLD

		Else
			nLinhaGd ++
			RecLock("CTS")
			Replace CTS_CONTAG	With CVF->CVF_CONTAG
			Replace CTS_CLASSE	With CVF->CVF_CLASSE
			Replace CTS_NORMAL	With CVF->CVF_NORMAL
			Replace CTS_DESCCG	With CVF->CVF_DESCCG
			Replace CTS_DETHCG	With CVF->CVF_DETHCG
			Replace CTS_CTASUP	With CVF->CVF_CTASUP
			If __Release .and. __lCOLUN2
				Replace CTS_COLUN2 With  CVF->CVF_COLUNA
			Else
				Replace CTS_COLUNA	With  GetCTSCol(CVF->CVF_COLUNA,cTipoCTS)
			EndIf
			
		EndIf

		For nCont := 1 to Len(aHeader)
			cPos += StrZero(FieldPos(aHeader[nCont,2]),2,0)
		Next

		For nCont2 := 1 To Len(aHeader)
			If aHeader[nCont2][10] # "V"
				cVar := Trim(aHeader[nCont2][2])
				FieldPut(Val(Subs(cPos,(nCont2*2-1),2)),aCOLS[nCont1][nCont2])
			ElseIf Trim(aHeader[nCont2][2]) = "CTS_IDENTI"
				Replace CTS_IDENT With aCOLS[nCont1][nCont2]
			EndIf
		Next nCont2

		//Para refazer a contagem da linha quando deletado registro deletado
		Replace CTS_LINHA		With aCols[nCont1][nPosLinha]

		If !Empty(CVF->CVF_IDENT) .AND. CVF->CVF_CLASSE = "1"
			Replace CTS_IDENT 	With CVF->CVF_IDENT
		Endif

		Replace CTS_TOTVIS With CVF->CVF_TOTVIS
		Replace CTS_VISENT With CVF->CVF_VISENT
		Replace CTS_SLDENT With CVF->CVF_SLDENT
		Replace CTS_FATSLD With CVF->CVF_FATSLD

		MsUnlock()
		cVar := ""
	EndIf
Next nCont1
End Transaction
ALTERAGD	:=	.F.
oArea :SetTiTleWindow ( "GETDADOS", STR0015 )

dbSelectArea("CTS")
dbSetOrder(1)

RestArea(aSaveArea)
oGetD:Disable()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB161SetL ºAutor  ³Microsiga          º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializa os campos logicos da tabeka CVF                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION CTB161SetL(lNegrito,lTotal,lSepara,lTraco)
Local lRet	:=	.F.
Do Case
Case	lNegrito
	lRet	:=	 CVF->CVF_IDENT == "3" .Or. CVF->CVF_IDENT = "6"
Case	lTotal
	lRet	:= CVF->CVF_IDENT = "4"
Case	lSepara
	lRet	:= ( CVF->CVF_IDENT = "5" .Or. CVF->CVF_IDENT = "6" ) .And. Alltrim( CVF->CVF_DESCCG ) <> "-"
Case	lTraco
	lRet	:= CVF->CVF_IDENT = "5" .And. Alltrim( CVF->CVF_DESCCG ) == "-"
EndCase
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GetNextOrdem   	³ Autor ³ Davi Torchio   ³ Data ³ 01/12/07          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao  GetNextOrdem ()				                    			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GetNextOrdem()
Local aArea	:=	CVF->(GetArea())
Local nConta:=	Max(Iif(ValType(mv_par01) == "N",mv_par01,1) ,1)
DbSelectArea('CVF')
DbSetOrder(4)
DbSeek(xFilial()+CVE->CVE_CODIGO+"zzzzzzzzzzzzzzzzzzz",.t.)
DbSkip(-1)
If xFilial()+CVE->CVE_CODIGO == CVF->(CVF_FILIAL+CVF_CODIGO)
	cOrdem	:=	StrZero(Val(CVF->CVF_ORDEM) + nConta,Len(CVF->CVF_ORDEM))
Else
	cOrdem	:=	StrZero(nConta,Len(CVF->CVF_ORDEM))
Endif
RestArea(aArea)
Return cOrdem

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RefreshTree   	³ Autor ³ Davi Torchio   ³ Data ³ 01/12/07          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao  RefreshTree ()				                    			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RefreshTree(oTreeCVF,oPsideBar,lConf,cCtaSup,cCodigo,cOrdem,oGetCVE,oGetCVF,oGet)

Default lConf 	:= .F.

lInRefresh	:=	.T.
oTreeCVF:BeginUpdate()
//ESTRUTURA - CODIGO + CONTAG
IF MV_PAR05 == 1
	If Empty(cCtaSup) .Or. oTreeCVF:GetCargo() =="ID_PRINCIPAL"
		cOrigem	:=	"ID_PRINCIPAL"
		cSeek	:=	Space(Len(CVF->CVF_CONTAG))
		DbSelectArea('CVF')
		DbSetOrder(2)
		DbSeek(xFilial()+CVF->CVF_CODIGO+cSeek)
		While !Eof().And. xFilial()+CVF->CVF_CODIGO+cSeek == CVF->CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_CTASUP
			nRecCVF:=CVF->(Recno())
			If oTreeCVF:TreeSeek(CVF->CVF_CONTAG)
				oTreeCVF:DelItem()
			Endif
			CVF->(MsGoTo(nRecCVF))
			DbSelectArea('CVF')
			DbSkip()
		Enddo
		oTreeCVF:TreeSeek("ID_PRINCIPAL")
		lInRefresh	:=	.F.
		AddTreeCVF(oTreeCVF,,.T.)

	Else
		IF lConf
			cOrigem	:=	cCtaSup
			cSeek	:=	cCtaSup
			DbSelectArea('CVF')
			DbSetOrder(2)
			DbSeek(xFilial()+cCodigo+cSeek)
			While !Eof().And. xFilial()+cCodigo+cSeek == CVF->CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_CTASUP
				nRecCVF:=CVF->(Recno())
				If oTreeCVF:TreeSeek(CVF->CVF_CONTAG)
					oTreeCVF:DelItem()
				Endif
				CVF->(MsGoTo(nRecCVF))
				DbSelectArea('CVF')
				DbSkip()
			Enddo
			lInRefresh	:=	.F.
		Else
			cOrigem	:=	CVF->CVF_CONTAG
			cSeek	:=	CVF->CVF_CONTAG
			DbSelectArea('CVF')
			DbSetOrder(2)
			DbSeek(xFilial()+CVF->CVF_CODIGO+cSeek)
			While !Eof().And. xFilial()+CVF->CVF_CODIGO+cSeek == CVF->CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_CTASUP
				nRecCVF:=CVF->(Recno())
				If oTreeCVF:TreeSeek(CVF->CVF_CONTAG)
					oTreeCVF:DelItem()
				Endif
				CVF->(MsGoTo(nRecCVF))
				DbSelectArea('CVF')
				DbSkip()
			Enddo
			oTreeCVF:TreeSeek("ID_PRINCIPAL")
			lInRefresh	:=	.F.
			oTreeCVF:TreeSeek(cOrigem)
		Endif
	Endif
//ORDEM - CODIGO + ORDEM
ELSE
	If oTreeCVF:GetCargo() =="ID_PRINCIPAL"
		cOrigem	:=	"ID_PRINCIPAL"
		cSeek	:=	Space(Len(CVF->CVF_ORDEM))
		DbSelectArea('CVF')
		DbSetOrder(4)
		DbSeek(xFilial()+CVF->CVF_CODIGO+cSeek)
		While !Eof().And. xFilial()+CVF->CVF_CODIGO+cSeek >= CVF->CVF_FILIAL+CVF->CVF_CODIGO+CVF->CVF_ORDEM
			nRecCVF:=CVF->(Recno())
			If oTreeCVF:TreeSeek(CVF->CVF_ORDEM)
				oTreeCVF:DelItem()
			Endif
			CVF->(MsGoTo(nRecCVF))
			DbSelectArea('CVF')
			DbSkip()
		Enddo
		oTreeCVF:TreeSeek("ID_PRINCIPAL")
		lInRefresh	:=	.F.
		AddTreeCVF(oTreeCVF,,.T.)

	Else
		cOrigem := CVF->CVF_CONTAG
		cSeek := CVF->(CVF_FILIAL+CVF_CODIGO)
		DbSelectArea('CVF')
		DbSetOrder(4)//DbSetOrder(2)
		DbSeek(xFilial('CVF')+cSeek)
		While !Eof() .AND. CVF->(CVF_FILIAL+CVF_CODIGO) >= cSeek
			nRecCVF:=CVF->(Recno())
			If oTreeCVF:TreeSeek(CVF->CVF_CONTAG)
				oTreeCVF:DelItem()
			Endif
			CVF->(MsGoTo(nRecCVF))
			DbSelectArea('CVF')
			DbSkip()
		Enddo
		lInRefresh	:=	.F.
		oTreeCVF:TreeSeek("ID_PRINCIPAL")
		AddTreeCVF(oTreeCVF,,.T.)
		PosicionaCVF(oTreeCVF,,,,oArea,oGetCVE,oGetCVF,oGet)
		oArea:ShowLayout("VISAOCVE")
		If ValType(oGetCVE) == "O"
			oGetCVE:EnchRefreshAll()
		EndIf
	Endif
ENDIF

oTreeCVF:EndUpdate()
oTreeCVF:Refresh()
oPsideBar:Refresh()
Return oTreeCVF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb161Exc    ³ Autor ³ Totvs             ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui a visao gerencial.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA161                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Exc( cAlias, nReg, nOpc )
	Ctb161Pos()
	Ctb161Del( cAlias, nReg, nOpc, MV_PAR06 == 2 )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb161Prox ³ Autor ³ Pilar S.Albaladejo	³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb161Prox(lInclui)
Local cReturn := ""
Local cContag := ""
Local aArea   := GetArea()

Do Case
	//Automatico
	Case Empty(M->CVF_CONTAG) .And. lInclui .And. MV_PAR02 = 1

		cContag := CVF->CVF_CONTAG

 	 //	If cContag <> "1"
	  	dbSetOrder(1)
	 	dbSeek(xFilial()+CVF->CVF_CODIGO+"zzzzzzzzzzzzzzzzzzzz",.T.)
		dbSkip(-1)
		cContag := CVF->CVF_CONTAG
 	 //	Endif

		cReturn := PadR(Soma1(AllTrim(cContag)),TamSx3("CVF_CONTAG")[1])

   //Formula
	Case lInclui .And. MV_PAR02 = 2
		If Empty(MV_PAR03)
			cReturn := CriaVar("CVF_CONTAG")
		Else
			If C161VldFormula(MV_PAR03)
				cReturn := &(MV_PAR03)
			EndIf
		EndIf

	//Digitacao
	Case Empty( cReturn ) .And. lInclui .And. MV_PAR02 = 3
		cReturn := CriaVar("CVF_CONTAG")

EndCase

If lInclui .And. MV_PAR04 = 1
	cReturn := StrZero( Val( cReturn ), TamSx3( "CVF_CONTAG" )[1], 0 )
EndIf

RestArea(aArea)

Return cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb161Vld    ³ Autor ³ Pilar S.Albaladejo³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida campos do cabecalho do rotina(tela)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb161Vld(cCpoVld,lInclui)

Local lRet := .T.

Do Case
	Case AllTrim(cCpoVld) == "CVF_CODIGO"
		If lRet
			lRet := NaoVazio(M->CVF_CODIGO)
		EndIf
		If lRet
			lRet := ( CVE->CVE_CODIGO == M->CVF_CODIGO )
		EndIf
		If lRet
			lRet := FreeForUse("CVF",M->CVF_CODIGO)
		EndIf
		If lRet
			lRet := Ctb161Ord(lInclui)
		EndIf
		If lRet
			lRet := Ctb161Nome()
		EndIf

	Case AllTrim(cCpoVld) == "CVF_ORDEM"
		If lRet
			lRet := NaoVazio(M->CVF_ORDEM)
		EndIf
		If lRet
			lRet := Ctb161Ord(lInclui)
		EndIf
		If lRet .And. lInclui
			cOrdem := If(!Empty(M->CVF_ORDEM),StrZero(Val(M->CVF_ORDEM),Len(M->CVF_ORDEM)),M->CVF_ORDEM)
			lRet	:= ExistChav("CVF",M->CVF_CODIGO+M->CVF_ORDEM,4,)
		Endif

	Case AllTrim(cCpoVld) == "CVF_CONTAG"
		If lRet
			lRet := NaoVazio(M->CVF_CONTAG)
		EndIf
		If lRet
			lRet := Ctb161Ent(lInclui)
		EndIf

	Case AllTrim(cCpoVld) == "CVF_CLASSE"

		If lRet .And. NaoVazio(M->CVF_CLASSE)  //somente valida se foi preecnhido a classe
			//verifica se a superior é sintetica
			lRet := Ctb161Sup()
			If !lRet //se nao passou pela validacao entao limpa conteudo do campo CVF_CLASSE para permitir digitar outra conta superior ou sair da edicao
				M->CVF_CLASSE := " "
			EndIf
		EndIf

	Case AllTrim(cCpoVld) == "CVF_CTASUP"
		If lRet
			lRet := NaoVazio(M->CVF_CLASSE)  //CLASSE NAO DEVE ESTAR VAZIA POIS VALID CONTA SUPERIOR UTILIZA ESTA INFORMACAO
		EndIf

		If lRet
			lRet := Ctb161Sup()
		EndIf

	Case AllTrim(cCpoVld) == "CVF_NORMAL"
		If lRet
			lRet := NaoVazio(M->CVF_NORMAL)
		EndIf

	Case AllTrim(cCpoVld) == "CVF_DESCCG"
		If SubStr(M->CVF_DESCCG,1,1) = "-"
			cIdent := "7"
		Else
			cIdent := " "
		EndIf
EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb161IniVar  ºAutor  ³Microsiga       º Data ³  18/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analise da existência dos campos das novas entidades       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb161IniVar()

Local aSaveArea := GetArea()

dbSelectArea("CTS")

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CTS->(FieldPos("CTS_E05INI")>0 .And. FieldPos("CTS_E05FIM")>0)
EndIf

If _lCpoEnt06 == Nil
	_lCpoEnt06 := CTS->(FieldPos("CTS_E06INI")>0 .And. FieldPos("CTS_E06FIM")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CTS->(FieldPos("CTS_E07INI")>0 .And. FieldPos("CTS_E07FIM")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CTS->(FieldPos("CTS_E08INI")>0 .And. FieldPos("CTS_E08FIM")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CTS->(FieldPos("CTS_E09INI")>0 .And. FieldPos("CTS_E09FIM")>0)
EndIf

If cTipoCTS == NIL
	cTipoCTS := FWSX3Util():GetFieldType('CTS_COLUNA')
EndIF

If __Release == NIL
	__Release  :=  Iif(GetRPORelease() >= "12.1.2210", .T., .F.)
EndIF

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb161Nome ³ Autor ³Simone Mie Sato       ³ Data ³ 10.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctb161Nome()

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := CTS->(GetArea())

dbSelectArea("CTS")
dbSetOrder(1)
If MsSeek(xFilial("CTS")+M->CVF_CODIGO,.F.)
	M->CTS_NOME := CTS->CTS_NOME
	lTrvNome := .F.
Else
	lTrvNome := .T.
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} C161SVREC
Função para carregar o recno na variavel private nRecCVE 
utilizada na inclusão do modo arvore

@author TOTVS
@since 26/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function C161SVREC()
nRecCVE := CVE->(RECNO())
Return
