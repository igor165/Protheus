#include "protheus.ch"
#include "MSMGADD.CH"
#include "PMSA095.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA095  � Autor � Totvs                 � Data � 26/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Funcoes - Modelo Estruturado                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PMSA095()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Gen�rico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PMSA095( aRotAuto, nOpcAuto )
	Local oMenuPop
	Local aCoors 		:= FWGetDialogSize( oMainWnd )

	Private INCLUI		:= .F.
	Private ALTERA		:= .F.
	Private EXCLUI		:= .F.
	Private cCopiaRef	:= ""
	Private oGetTBL
	Private oGetTBL2
	Private oPanel1								// Tela de Apresentacao da Rotina
	Private oPanel2								// Tela de Apresentacao da Rotina
	Private oTree
	Private oDlg
	Private oFWLayer
	Private oBtnBar1
	Private oBtnBar2
	Private oSay
	Private oTPane1

	Private aAutoCab	:= aRotAuto
	Private lExecAuto	:= ( aRotAuto <> NIL )

	If lExecAuto
		Private cCadastro	:= OemToAnsi( STR0001 )
		Private aRotina		:= MenuDef()
		DEFAULT nOpcAuto 	:= 3

		MBrowseAuto( nOpcAuto, aAutoCab, "AN1" )
	Else	
		If AMIIn(44) .And. !PMSBLKINT()
			DEFINE DIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL 
	
		 		// Cria instancia do fwlayer
				oFWLayer := FWLayer():New()
	
				// Inicializa componente passa a Dialog criada, 
				// o segundo parametro � para cria��o de um botao de fechar utilizado para Dlg sem cabe�alho
				oFWLayer:init( oDlg, .T. )
	
				// Adiciona coluna passando nome, porcentagem da largura, e se ela � redimensionada ou n�o
				// Cria windows passando, nome da coluna onde sera criada, nome da window
				// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
				// se � redimensionada em caso de minimizar outras janelas e a a��o no click do split
				oFWLayer:addCollumn( "Col01", 30, .F. )
				oFWLayer:addWindow( "Col01", "Win01", STR0001, 95, .F., .F., /*{|| oFWChart01:refresh() }*/ )
				oPanel1	:= oFWLayer:getWinPanel( "Col01", "Win01" )
	
					// TREE
					oTree			:= XTree():New( 000, 000, 000, 000, oPanel1 )
					oTree:Align		:= CONTROL_ALIGN_ALLCLIENT
				 	oTree:bChange	:= {|x1,x2,x3| PosicionaREG( oTree, oGetTBL, oPanel1 ) }
					oTree:bValid	:= {|| !INCLUI .and. !ALTERA .and.!EXCLUI }
					oTree:bWhen		:= {|| !INCLUI .and. !ALTERA .and.!EXCLUI } 
	
					If SuperGetMV( "MV_QTMKPMS", .F., 1 ) < 3 //Integracao entre PMS x TMK x QNC
						oTree:BrClicked := {|x,y,z| oMenuPop:Activate( y-40, z-185, oPanel1 )	 } 
					EndIf
	
					//Cria o primeiro nodo
					oTree:AddTree ( STR0002, "BMPGROUP","BMPGROUP", 'ID_PRINCIPAL',/*{|| MsgStop('xxx')}*/,/*bRClick*/, { || AddTreeREG(oTree,Criavar("AN1_CODIGO"))})	
					AddTreeREG(oTree,Criavar("AN1_CODIGO"))
					oTree:EndTree()
	
					If SuperGetMV( "MV_QTMKPMS", .F., 1 ) < 3 //Integracao entre PMS x TMK x QNC
						MENU oMenuPop POPUP
							MENUITEM STR0003 ACTION actButtons( 3, oPanel2, oGetTBL, oTree, oPanel1 )
							MENUITEM STR0004 ACTION actButtons( 4, oPanel2, oGetTBL, oTree, oPanel1 )
							MENUITEM STR0005 ACTION actButtons( 5, oPanel2, oGetTBL, oTree, oPanel1 )
						ENDMENU
					Else
						MsgAlert( STR0019 ) //"Apenas a pesquisa e visualiza��o poder� ser feita por essa rotina devido a integra��o com TMK/QNC. A edi��o s� pode ser feita pelo Cadastro de Cargos."
					EndIf
	
					// BUTTONS
					oBtnBar1 := FWButtonBar():new()
					oBtnBar1:Init( oPanel1, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )
					oBtnBar1:addBtnText( STR0008,					STR0008,	{|| RefreshTree( oTree, oPanel1, oGetTBL ) }	,,, CONTROL_ALIGN_LEFT) //"Refresh"
					oBtnBar1:addBtnText( STR0010,		STR0010+" "+STR0009,	{|| PesqTree( oTree, oGetTBL, oPanel1 ) }		,,, CONTROL_ALIGN_LEFT) //"Pesquisa R�pida"

				// Adiciona coluna passando nome, porcentagem da largura, e se ela � redimensionada ou n�o
				// Cria windows passando, nome da coluna onde sera criada, nome da window
				// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
				// se � redimensionada em caso de minimizar outras janelas e a a��o no click do split
				oFWLayer:addCollumn( "Col02", 70, .F. )
				oFWLayer:addWindow( "Col02", "Win01", STR0006, 95, .F., .F., /*{|| oFWChart02:refresh() }*/ )
				oPanel2	:= oFWLayer:getWinPanel( "Col02", "Win01" )
	
					oTPane1 := TPanel():New( 0, 0, "", oPanel2, NIL, .T., .F., NIL, NIL, 0, 16, .T., .F. )
					oTPane1:Align := CONTROL_ALIGN_TOP
	
						@ 20,5 SAY oSay VAR HTMLDEF() OF oTPane1 FONT oTPane1:oFont PIXEL SIZE 350, 550 HTML
						
					// Painel 2 - Enchoice
					RegToMemory( "AN1", .F.,,, FunName() )
					oGetTBL				:= MsMGet():New( "AN1", AN1->( RecNo() ), 2,,,,, { 0, 0, 290, 252 },, 4,,,, oPanel2 )
					oGetTBL:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT
					oGetTBL:Hide()
					oGetTBL:oBox:Hide()
	
					// Posiciona a arvore no cabecalho para mostrar a tela de apresentacao
					oTree:TreeSeek( "ID_PRINCIPAL" )
					PosicionaREG( oTree, oGetTBL, oPanel1 )
	
			ACTIVATE DIALOG oDlg	
		Endif
	Endif

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �AddTreeREG� Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para inclusao de nodos no XTree                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AddTreeREG(ExpO1,ExpC1)                              	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto xTree                                       ���
���          � ExpC1 = Codigo da Pai						         	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � 		                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AddTreeREG( oTree, cPai, cIntQNC )
Local lRet 		:= .F.
Local cCargo	:=	oTree:GetCargo()
Local aArea 	:= GetArea()
Local aAreaAux
Local cPaiItem	:= ""

DEFAULT cIntQNC := "2"

If Empty(cPai)
	cIntQNC := ''
EndIf

If aScan( oTree:aNodes, { |x| x[1] == oTree:CurrentNodeID } ) == 0

	DbSelectArea( "AN1" )
	AN1->( DbSetOrder( 2 ) )
	If AN1->( DbSeek( xFilial( "AN1" ) + cPai ) )
		Do While !AN1->( Eof() ) .And. AN1->AN1_FILIAL + AN1->AN1_NIVSUP == xFilial( "AN1" ) + cPai
			If Empty(cIntQNC) .Or. AN1->AN1_INTQNC == cIntQNC
				If !oTree:TreeSeek( AN1->AN1_CODIGO + AN1->AN1_INTQNC )
					If Empty(AN1->AN1_NIVSUP)
						oTree	:AddTree ( 	RTrim(AN1->AN1_CODIGO) + ' - ' + AllTrim( AN1->AN1_DESCRI ),  "BMPUSER","BMPUSER",	AN1->AN1_CODIGO + AN1->AN1_INTQNC,/*{|x| AddTreeREG(x, Alltrim(oTree:aCargo[aSCAN(oTree:aNodes,{|x| x[2]==oTree:CurrentNodeID}) ][1]))}*/,/*bRClick*/,/*bDblClick*/ )	
						oTree	:EndTree()
			   		Else
						oTree	:AddItem (  RTrim(AN1->AN1_CODIGO) + ' - ' + AllTrim( AN1->AN1_DESCRI ),	AN1->AN1_CODIGO + AN1->AN1_INTQNC,  "BMPUSER", "BMPUSER", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )	
					EndIf
					lRet := .T. 
				EndIf
			EndIf

			DbSkip()                   		
		EndDo
	EndIf
EndIf

RestArea(aArea)                          

Return lRet                                                       

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 �PosicionaREG� Autor � Totvs                 � Data � 23/11/09 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para inclusao de registros	                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � PosicionaREG(oTree, oGetTBL, oArea )                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto xTree                                         ���
���          � ExpO2 = Objeto MsmGet (enchoice)      					    ���
���          � ExpO3 = Objeto Painel, onde se encontra o xTree              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � 		                                                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function PosicionaREG( oTree, oGetTBL, oArea )
Local aArea
Local cCodigo	:= oTree:GetCargo()

If ValType( cCodigo ) <> "C"
	cCodigo := CriaVar( "AN1_CODIGO" ) + CriaVar( "AN1_INTQNC" )
EndIf

dbSelectArea( "AN1" )
AN1->( dbSetOrder( 1 ) )
AN1->( dbSeek( xFilial( "AN1" ) + cCodigo ) )

If AN1->( Eof() )
	AN1->( DbGoTop() )
EndIf

aArea := GetArea()

RegToMemory( "AN1", .F., ,, FunName() )
AddTreeREG( oTree, AN1->AN1_CODIGO, AN1->AN1_INTQNC )

If ValType(oArea) == 'O'
    If cCodigo == 'ID_PRINCIPAL'
		oTPane1 := TPanel():New( 0, 0, "", oPanel2, NIL, .T., .F., NIL, NIL, 350, 550, .T., .F. )
		oTPane1:Align := CONTROL_ALIGN_TOP

		@ 20,5 SAY oSay VAR HTMLDEF() OF oTPane1 FONT oTPane1:oFont PIXEL SIZE 350, 550 HTML
	Else
		oPanel2:FreeChildren()

		// Painel 2 - Enchoice
		RegToMemory( "AN1", .F.,,, FunName() )
		oGetTBL				:= MsMGet():New( "AN1", AN1->( RecNo() ), 2,,,,, { 0, 0, 290, 252 },, 4,,,, oPanel2 )
		oGetTBL:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

		// BUTTONS
		If SuperGetMV( "MV_QTMKPMS", .F., 1 ) < 3 //Integracao entre PMS x TMK x QNC
			oBtnBar2 := FWButtonBar():new()
			oBtnBar2:Init( oPanel2, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )

			oBtnBar2:addBtnText( STR0003,		STR0003, {|| actButtons( 3, oPanel2, oGetTBL, oTree, oPanel1 ) },,, CONTROL_ALIGN_LEFT) //"Incluir"
			oBtnBar2:addBtnText( STR0004,		STR0004, {|| actButtons( 4, oPanel2, oGetTBL, oTree, oPanel1 ) },,, CONTROL_ALIGN_LEFT) //"Alterar"
			oBtnBar2:addBtnText( STR0005,		STR0005, {|| actButtons( 5, oPanel2, oGetTBL, oTree, oPanel1 ) },,, CONTROL_ALIGN_LEFT) //"Excluir"
		EndIf

		If ValType( oGetTBL ) =='O' .and. cCodigo <> 'ID_PRINCIPAL'
			oGetTBL:EnchRefreshAll()
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*/
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o	 � RefreshTree    � Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza a arvore                                                ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � RefreshTree( oTree, oPanel1, oGetTBL )                           ���
�������������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto xTree                                             ���
���          � ExpO2 = Objeto Painel, onde se encontra o xTree                  ���
���          � ExpO3 = Objeto MsmGet (enchoice)      					        ���
���          � ExpC1 = Cargo a ser posicionado apos atualizacao da arvore       ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      �																	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
/*/
Static Function RefreshTree( oTree, oPanel1, oGetTBL, cPosic )
	Local aArea 	:= GetArea()
	Local cCodigo	:= ""
	Local cPaiItem	:= ""
	Local cPai		:= CriaVar( "AN1_CODIGO" )

	// Item a ser posicionado apos atualizacao
	Default cPosic	:= "ID_PRINCIPAL"

	// Limpa a arvore
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()

	// Cria novamente 
	oTree:Hide()
	oTree:BeginUpdate()

	oTree:TreeSeek( "" )
	oTree:AddItem( STR0002, "ID_PRINCIPAL", "BMPGROUP","BMPGROUP", 1 )

	If	aScan( oTree:aNodes, { |x| x[1] == oTree:CurrentNodeID } ) == 0

		DbSelectArea( "AN1" )
		AN1->( DbSetOrder( 2 ) )
		If AN1->( DbSeek( xFilial( "AN1" ) + cPai ) )
			Do While !AN1->( Eof() ) .And. AN1->AN1_FILIAL + AN1->AN1_NIVSUP == xFilial( "AN1" ) + cPai
				cCodigo 	:= AN1->AN1_CODIGO
				cPaiItem	:= AN1->AN1_NIVSUP
				If Empty( cPaiItem )
					cPaiItem := "ID_PRINCIPAL"
				EndIf

				oTree:TreeSeek( cPaiItem )
				oTree:AddItem (	RTrim(cCodigo) + ' - ' + AllTrim( AN1->AN1_DESCRI ) ,	AN1->AN1_CODIGO + AN1->AN1_INTQNC, "BMPUSER","BMPUSER",2,/*bAction*/,/*bRClick*/,/*bDblClick*/ )

				AN1->( DbSkip() )
			EndDo
		EndIf
	Endif      

	oTree:EndUpdate()
	oTree:Show()

	// Posiciona na arvore o item que sofreu alteracao ou simplesmente no cabecalho
	oTree:TreeSeek( cPosic )
	PosicionaREG( oTree, oGetTBL, oPanel1 )

	RestArea(aArea)                          
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � PesqTree � Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a pesquisa de um codigo na �rvore e chama a func�o para���
���       	 � posicionar na �rvore.                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PesqTree()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = Informa se eh pesquisa rahpida					  ���
���          � ExpO1 = Ahrvore onde vai ocorrer a busca		  	  		  ���
���          � ExpO2 = Objeto MsmGet (enchoice)      					  ���
���          � ExpO3 = Objeto Painel, onde se encontra o xTree            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                     		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PesqTree( oTree, oGetTBL, oArea )
Local cCodAtu	:=	oTree:GetCargo()
Local nPesq

// Verifica se existe registro para a operacao
If AN1->( Bof() ) .AND. AN1->( Eof() )
   Help( " ", 1, "ARQVAZIO" )
   Return
EndIf

DbSelectArea( "AN1" )

nPesq := AxPesqui()
If cCodAtu <> AN1->AN1_CODIGO + AN1->AN1_INTQNC
	PosicTree( oTree, oGetTBL, oArea )
Endif	

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PosicTree � Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a busca de um codigo na �rvore e posiciona no registro ���
���       	 � encontrado                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PosicTree(ExpO1,ExpO2,ExpO3,ExpO4,ExpO5,ExpO6)             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Arvore onde vai ocorrer a busca		  	  		  ���
���          � ExpO2 = Objeto MsmGet (enchoice)      					  ���
���          � ExpO3 = Objeto Painel, onde se encontra o xTree            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                     		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PosicTree( oTree, oGetTBL, oArea )
Local aPais:={}
Local lAchou	:=	.F.
Local cCodPesq	:= AN1->AN1_CODIGO + AN1->AN1_INTQNC
Local cCargo	:= AN1->AN1_CODIGO + AN1->AN1_INTQNC
Local nX	:= 0

Do While !lAchou
	lAchou	:=	oTree:TreeSeek(cCargo)
	If !lAchou
		cCargo	:= AN1->AN1_CODIGO + AN1->AN1_INTQNC
		AAdd(aPais, {AN1->AN1_CODIGO, AN1->AN1_INTQNC})
		DbSeek(xFilial("AN1")+AN1->AN1_NIVSUP)		
	Endif
	If AllTrim(AN1->AN1_NIVSUP) == ''
		lAchou := .T.
	EndIf
Enddo                   
	
For nX:= Len(aPais) TO 1 STEP -1
	If !oTree:TreeSeek(aPais[nX][1]+aPais[nX][2])
		AddTreeREG(oTree, aPais[nX][1], aPais[nX][2])
	EndIf
	
	oTree:TreeSeek(aPais[nX][1]+aPais[nX][2])
Next                              

AN1->(dbSetOrder(1))
DbSeek(xFilial("AN1")+cCodPesq)
oTree:TreeSeek(AN1->AN1_CODIGO + AN1->AN1_INTQNC)

PosicionaREG( oTree, oGetTBL, oArea )

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �actButtons� Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Acao dos botoes para a enchoice                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � actButtons( nOpc )                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao da acao, inclusao, alteracao ou exclusao     ���
���          � ExpO1 = Objeto Painel, onde se encontra o MsmGet           ���
���          � ExpO2 = Objeto MsmGet (enchoice)      					  ���
���          � ExpO3 = Ahrvore onde vai ocorrer a busca		  	  		  ���
���          � ExpO4 = Objeto Painel, onde se encontra o xTree            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                     		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function actButtons( nOpc, oPanel2, oGetTBL, oTree, oPanel1 )
	Local aDim		:= DlgInPanel( oPanel2 )
	Local cOldPai	:= ""
	Local cCodigo	:= ""
	Local cTudoOK	:= "PA095Vld()"
	Local cTransact	:= NIL
	Local nOk		:= 0
	Local nRecNo	:= AN1->( RecNo() )
	Local cCodItem	:= ""
	Local cDescItem	:= ""
	Local oDlgAlt
	Local oEnc01
	Local bOk		:= {|| .T. }
	Local bOk2		:= {|| .T. }

	// Verifica se existe registro para as opcoes ALTERAR/EXCLUIR.
	If AN1->( Eof() ) .AND. nOpc <> 3
	   Help( " ", 1, "ARQVAZIO" )
	   Return
	EndIf

	// Workarround para solucao da falta de tratamento do WHEN no objeto xTree
	oPanel1:Disable()
	
	If nOpc == 3
		INCLUI := .T.
		nOk := AxInclui( "AN1", nRecNo, nOpc,,,{"AN1_CODIGO","AN1_DESCRI","AN1_NIVSUP"},cTudoOk,,cTransact,,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,	.F.,oPanel1, aDim,, .T. )

		If nOk == 1
			If Empty( AN1->AN1_NIVSUP )
				oTree:TreeSeek( "ID_PRINCIPAL" )
				oTree:AddItem( RTrim( AN1->AN1_CODIGO ) + ' - ' + AllTrim( AN1->AN1_DESCRI ), AN1->AN1_CODIGO + AN1->AN1_INTQNC , "BMPUSER","BMPUSER", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
			Else
				oTree:TreeSeek( AN1->AN1_NIVSUP + AN1->AN1_INTQNC )
				oTree:AddItem( RTrim( AN1->AN1_CODIGO ) + ' - ' + AllTrim( AN1->AN1_DESCRI ), AN1->AN1_CODIGO + AN1->AN1_INTQNC , "BMPUSER","BMPUSER", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
			EndIf
		EndIf

	ElseIf nOpc == 4
		ALTERA		:= .T.
		cOldPai		:= AN1->AN1_NIVSUP
		cCodigo		:= AN1->AN1_CODIGO + AN1->AN1_INTQNC
	   	nOk 		:= AxAltera( "AN1", nRecNo, nOpc,,{"AN1_DESCRI","AN1_NIVSUP"}, 4, AN1->AN1_CODIGO, cTudoOk, cTransact,,,,,,,,, oPanel1, aDim,, .T. )

		If nOk == 1 .And. AN1->AN1_NIVSUP <> cOldPai
			cCodItem	:= RTrim( AN1->AN1_CODIGO )
			cDescItem	:= AllTrim( AN1->AN1_DESCRI )

			oTree:TreeSeek( cCodigo )
			If Empty( AN1->AN1_NIVSUP )
				oTree:TreeSeek( "ID_PRINCIPAL" )
				oTree:AddItem( cCodItem + ' - ' + cDescItem, cCodigo, "BMPUSER","BMPUSER", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
			Else
				oTree:TreeSeek( AN1->AN1_NIVSUP + AN1->AN1_INTQNC )
				If !oTree:TreeSeek( cCodigo )
					oTree:AddItem( cCodItem + ' - ' + cDescItem, cCodigo, "BMPUSER","BMPUSER", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
				EndIf
			EndIf

		Else
			If nOk == 1
				// Atualiza a descricao do item na arvore
				oTree:ChangePrompt( RTrim( AN1->AN1_CODIGO ) + ' - ' + AllTrim( AN1->AN1_DESCRI ), cCodigo )
			EndIf
		EndIf

	ElseIf nOpc == 5
		EXCLUI := .T.
		PA095Del( "AN1", oTree )
	EndIf

	INCLUI := .F.
	ALTERA := .F.
	EXCLUI := .F.

	// Workarround para solucao da falta de tratamento do WHEN no objeto xTree
	oPanel1:Enable()
	
	If nOpc <> 5
		RefreshTree( oTree, oPanel1, oGetTBL )
	EndIf
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PA095Del  � Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para exlusao                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PA095Del(cAlias, oTree, cCodigo )                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpO3 = Ahrvore onde vai ocorrer a busca		  	  		  ���
���          � ExpO1 = Objeto Painel, onde se encontra o MsmGet           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � 		                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA095Del(cAlias, oTree, cCodigo )
Local aArea		:= AN1->( GetArea() )
Local nConfDel 								//utilizada para o usu�rio confirmar ou n�o a dele��o 1.Confirma 2.Cancela
Local lDeleta	:= .T.
Local lRet		:= .T.
Local cOcorr	:= ""
Local cCodFunc

INCLUI	:=	.F.
ALTERA	:=	.F.
EXCLUI	:=	.T.

If ValType( cCodigo ) == "U"
	cCodigo	:= oTree:getCargo()
EndIf

cCodFunc := Left(cCodigo, TamSX3("AN1_CODIGO")[1])

// Verifica se esta sendo usado como nivel superior e nao permite exclusao
DbSelectArea( "AN1" )
AN1->( DbSetOrder( 1 ) )
AN1->( DbSeek( xFilial( "AN1" ) ) )
While AN1->( !Eof() ) .AND. AN1->AN1_FILIAL == xFilial( "AN1" )
	If AN1->AN1_NIVSUP + AN1->AN1_INTQNC == cCodigo
		lDeleta := .F.
		cOcorr	:= "A095NIVSUP"
		
		Exit
	EndIf
	
	AN1->( DbSkip() )
End

// Verifica se esta sendo usado em algum recurso
If lDeleta
	DbSelectArea( "AE8" )
	AE8->( DbSetOrder( 1 ) )
	AE8->( DbSeek( xFilial( "AE8" ) ) )
	Do While AE8->( !Eof() ) .AND. AE8->AE8_FILIAL == xFilial( "AE8" )
		If AE8->AE8_FUNCAO == cCodFunc
			lDeleta := .F.
			cOcorr	:= "A095RECURS"

			Exit
		EndIf
		
		AE8->( DbSkip() )
	EndDo
EndIf

If lDeleta
	If ValType( oTree ) == "O"
		nConfDel := Aviso( STR0011, STR0007, { STR0012, STR0013 })
	Else
		nConfDel := 1
	EndIf

	If nConfDel == 1
		//��������������������������������������������������������������Ŀ
		//� Inicio da Protecao via TTS                                   �
		//����������������������������������������������������������������
		BEGIN TRANSACTION           
			dbSelectArea( cAlias )
			dbSetOrder( 1 )    
			If DbSeek( xFilial() + cCodigo )
				RecLock(cAlias,.F.)
				If !FKDelete()
					Help(" ",1,"A095NAODEL")
				Else
					If ValType( oTree ) == "O"
						oTree:TreeSeek( cCodigo )
						oTree:DelItem()						
					EndIf
				Endif
				MsUnLock()
			EndIf
		//��������������������������������������������������������������Ŀ
		//� Final da protecao via TTS                                    �
		//����������������������������������������������������������������
		END TRANSACTION   

		If ValType( oTree ) == "O"
			oTree :TreeSeek( "ID_PRINCIPAL" )
		EndIf
	EndIf
Else
	Help( " ", 1, cOcorr,, STR0017, 1, 0 )
	lRet		:= .F.
EndIf


dbSetOrder(1)
dbSelectArea(cAlias)

INCLUI	:=	.F.
ALTERA	:=	.F.
EXCLUI	:=	.F.

RestArea( aArea )
Return lRet


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � HTMLDEF  � Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para retornar o texto de apresentacao da rotina.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � HTMLDEF()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � 		                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function HTMLDEF()
cRet	:=	"<H1>" + STR0009 + "</H1>"
cRet	+=	"<br>         "
cRet	+=	"<FONT size=+1>"
cRet	+=	STR0014 + "<br> "
cRet	+=	STR0015 + "<br> "
cRet	+=	STR0016 + "<br> "
cRet	+=	"</FONT>"
return cRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �DlgInPanel� Autor � Totvs                 � Data � 23/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obtem a dimensao do painel na dialog.                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � DlgInPanel(oParent)			                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto no qual foi adicionado.                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function DlgInPanel(oParent)
	Local aDim := {}
	Local nTop := 0
	Local nLeft := 0

	oParent:ReadClientCoors( ,.T.)
	_GetXCoors(oParent, @nTop)
	_GetYCoors(oParent, @nLeft)

	aDim := {oParent:oWnd:nTop + nTop + 30, ;
					nLeft + oParent:oWnd:nLeft + 2, ;
					oParent:nBottom + oParent:oWnd:nTop + nTop, ;
					oParent:nRight + nLeft }
Return aDim

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PA095Vld  � Autor � Totvs                 � Data � 16/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para validar o codigo do nivel superior             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PA095Vld( cCodigo )                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = codigo da funcao superior a ser validado           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA095Vld()
Local aArea		:= AN1->( GetArea() )
Local cCodigo	:= UPPER( M->AN1_NIVSUP )
Local lRet		:= .T.

If cCodigo == M->AN1_CODIGO
	lRet := .F.
Else
	lRet := PA095Loop( cCodigo, Upper( M->AN1_CODIGO ), M->AN1_INTQNC )
EndIf

If !lRet
	Help( " ", 1, "A095LOOP",, STR0018, 1, 0 ) // "Este codigo causar� refer�ncia circular e n�o pode ser usado! Selecione outro c�digo."
EndIf

If lRet
	DbSelectArea( "AN1" )
	AN1->( DbSetOrder( 1 ) )
	If !AN1->( DbSeek( xFilial( "AN1" ) + cCodigo + M->AN1_INTQNC ) )
		If AN1->( DbSeek( xFilial( "AN1" ) + cCodigo ) )
			MsgInfo(STR0020) //"A estrutura n�o deve conter fun��es do PMS e QNC mesclados, utilize apenas fun��es do PMS ou apenas fun��es do QNC."
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PA095Loop � Autor � Totvs                 � Data � 16/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para verificar recursividade ao informar o niv.sup  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PA095Loop( cCodigo )                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = codigo da funcao superior a ser validado           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PA095Loop( cCodigo, cCodSup, cIntQNC )
Local aArea	:= AN1->( GetArea() )
Local lRet	:= Empty( cCodigo )

If !lRet
	DbSelectArea( "AN1" )
	AN1->( DbSetOrder( 1 ) )
	If AN1->( DbSeek( xFilial( "AN1" ) + cCodigo + cIntQNC ) )
		If AN1->AN1_NIVSUP == cCodSup
			lRet := .F.
		Else
			lRet := PA095Loop( AN1->AN1_NIVSUP, cCodSup, cIntQNC )
		EndIf
	Else
		lRet := .T.
	EndIf
EndIf

RestArea( aArea )
Return lRet                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �17/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := { { OemToAnsi(STR0001) ,"AxPesqui",	0 , 1,,.F.	},;		//"Pesquisar"
                   { OemToAnsi(STR0003) ,"PA095Inclu",	0 , 3, 81	},;		//"Incluir"
                   { OemToAnsi(STR0004) ,"PA095Alter",	0 , 4, 82	} }		//"Alterar"

Return aRotina

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PA095Inclu� Autor � Totvs                 � Data � 28/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para inclusao de naturezas                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PA095Inclu(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA095Inclu(cAlias,nReg,nOpc)

Local nOpca
Local cTudoOk	:= Nil
Local cTransact	:= Nil

If Type( "lExecAuto" ) != "L" .OR. lExecAuto
	RegToMemory( "AN1", .T., .F. )
	If EnchAuto( cAlias, aAutoCab, cTudoOk, nOpc )
		nOpca := AxIncluiAuto( cAlias, cTudoOk, cTransact )
	EndIf
EndIf

Return nOpca


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PA095Alter� Autor � Totvs                 � Data � 28/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para alteracao de naturezas                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PA095Alter(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA095Alter(cAlias,nReg,nOpc)

Local nOpca		:= 0
Local cTudoOK 	:= Nil
Local cTransact := Nil

If Type( "lExecAuto" ) != "L" .OR. lExecAuto
	RegToMemory( "AN1", .F., .F. )
	If EnchAuto( cAlias, aAutoCab, cTudoOk, nOpc )
		nOpcA := AxIncluiAuto( cAlias,, cTransact, 4, RecNo() )
	EndIf
EndIf

Return
