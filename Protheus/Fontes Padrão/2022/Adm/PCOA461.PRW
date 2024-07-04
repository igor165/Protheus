#include "protheus.ch"
#include "pcoa461.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA461  ³ AUTOR ³ Paulo Carnelossi       ³ DATA ³ 09/06/2008  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa Cadastro dos Grupos de Verbas + Verbas Relacionadas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA461                                                        ³±±
±±³_DESCRI_  ³ Programa Cadastro dos Grupos de Verbas                         ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal      ³±±
±±³          ³ partir do Menu                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCOA461()

Local nWidth  		:= GetScreenRes()[1] - 40
Local nHeight 		:= GetScreenRes()[2] - 200
Local _nContItem, nX

//variaveis para montagem dos layouts
Local aLayout 			:= { "Grp_Verba", "VERBAHTML" }

//variaveis para montagem do tree
Local aNode_Tree 		:= { STR0001 } //"Variacao Composta"
Local aAliasTree    	:= { "AM3" }
Local aExpTitleTree 	:= { "ALLTRIM(AM3_GRUPO)+'-'+AM3_DESCRI" }
							
Local aResourceTree 	:= { "RPMCPO" }

Local bShow_02 		:= {|| oGrupoVerba:oArea:ShowLayout(aLayout[2] )				}	

Local bExecMenu 		:= 	{|x,y,z| RightTree( oGrupoVerba:GetTre("001"),, x, y, z)}

Local bRunEntid 		:= {|| /*RunEntid()*/}

Local bInclAM3Entid 	:= {|x|  }
Local bEnchQtd 		:= {|| oGrupoVerba:GetMsm("001"):EnchRefreshAll() }
Local aButs
Local cSayVerbaHTM, oVerbaHTM, oPanel1_HTML

Private oGrupoVerba 	:= PCOArea():New(0,0, nWidth, nHeight, STR0002 ) //"Planejamento Orçamentário - Grupo de Verbas"
Private bShow_01 		:= {|| oGrupoVerba:oArea:ShowLayout("LYT0"), oGrupoVerba:ShowLayout(aLayout[1]), PcoAtuBrow()}	

Private cCadastro		:= STR0003 //"Cadastro dos Grupos de Verbas" 
                                                       
dbSelectArea("AM8")
dbSetOrder(1)

cFiltro	:= PcoFilConf("AM3",.T.,.T.,.T.)

SetKey( VK_F12, {|| PcoFilConf("AM3",.T.,.T.,.T.,.T.) } )

If AMIIn(57) .and. !Empty(cFiltro)// AMIIn do modulo SIGAPCO ( 57 )

	dbSelectArea("AM3")
	dbSetOrder(1)

	//Cria  Layouts para a Tela
	oGrupoVerba:AddLayout( aLayout[1] )

	//adiciona SideBar no objeto oGrupoVerba (FWAREA)
	oGrupoVerba:addSide( 28, "GrupoVerba")
	
	// Adiciona Janela 1 - contera a sidebar e o tree pára navegacao
	oGrupoVerba:AddWindow( 96, "WIN1", STR0001, 2, .F.,,oGrupoVerba:oArea:oSideBar) //"Variacao Composta"

	// Adiciona Janela 2 com Botões - servira para conter o cadastro Grupo de Verbas /ou Verbas Relacionadas
	oGrupoVerba:AddWindow( 48, "WIN2", STR0004 , 3, .T., aLayout[1] )//"Cadastro de Grupos de Verbas"

	// Adiciona Janela 3 com Botões
	oGrupoVerba:AddWindow( 48, "WIN3", STR0005 , 2, .T., aLayout[1] )//"Composição de Verbas"

	//--------
	oGrupoVerba:oArea:AddLayout( aLayout[2] )
	oLayout := oGrupoVerba:oArea:GetLayout( aLayout[2] )

	oGrupoVerba:oArea:AddWindow( 100, 100, "WIN4", STR0004 , 2, 2, oLayout ) // "Cadastro de Grupos de Verbas"
	oGrupoVerba:oArea:AddPanel( 100 , 100, "WIN4" )                                
	oPanel1_HTML	:= oGrupoVerba:oArea:GetPanel ( "WIN4" )

	cSayVerbaHTM := PcoVerbaHTML()
	@ 0,0 SAY oSayVerbaHTM VAR cSayVerbaHTM OF oPanel1_HTML FONT oPanel1_HTML:oFont PIXEL HTML
	oSayVerbaHTM:Align := CONTROL_ALIGN_ALLCLIENT
	//-----------

	oGrupoVerba:AddTre("001","WIN1",nil)
	oGrupoVerba:GetTre("001"):AddTree(STR0020, "RPMCPO", "FOLDER6", "AM3GRUPOVERBA", bShow_02, bExecMenu, {||}) //"Grupos de Verbas"

	// Monta Estrutura do Tree
	oGrupoVerba:No_Tree( aNode_Tree[1], aAliasTree[1], aExpTitleTree[1], aResourceTree[1], bShow_01, bExecMenu,{|| /*RunEntid()*/},bInclAM3Entid)
	//-----------------------------------------------------------------------------------------------
	// TELAS 
	//-----------------------------------------------------------------------------------------------

	// Cria variaveis de memoria para a MSMGet da Planilha de Planejamento
	RegToMemory("AM3", .F.,,, FunName())  // usa no metodo msm

	//Cria MsmGet e adiciona ao layou Planej
	oGrupoVerba:AddMsm("001", STR0001 ,"AM3",AM3->(Recno()),"WIN2",aLayout[1],{|x| },{|x| PcoGrvAM3() }) //"Variacao Composta"

	//-----------------------------------------------------------------------------------------------
	// Monta aHeader e aCols a ser utilizado na GetDados referente a Grupo de Verbas Saldarios
	dbSelectArea("AM6")
	dbSetOrder(1)
	Inclui := .F.
	Altera := .T.
	aCpos := {"AM6_GRCOMP", "AM6_DESCOM"}
	If ExistBlock("PCOA4961")
		If VALTYPE(aCposUsr := ExecBlock("PCOA4961"))="A"
			aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
		EndIf
	EndIf
	aHeaderAM6 := GetAHeader("AM6",aCpos)
	aColsAM6 	:= nil

	// Cria GetDados da Tela
	oGrupoVerba:AddGtD("001", STR0005 , "WIN3", aLayout[1], aHeaderAM6, aColsAM6, {||  }, {|x| }, {|x| PcoAtualAM6() } ) //"Composição de Verbas"

	oGrupoVerba:ShowLayout("VERBAHTML")

	// Inicializa o Tree
	PcoAtuAgreg(.T.)

	oGrupoVerba:GetTre("001"):TreeSeek("AM3GRUPOVERBA")  //Posiciona no node principal
	PcoAtuBrow() //forca limpeza da tela e getdados

	oGrupoVerba:Activate()

EndIf

Set Key VK_F12 To 

Return


//----------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PopupMenu ºAutor  ³Acacio Egas         º Data ³  03/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função executada ao clicar botão direita no xTree.         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RightTree(oTree,oObject1,oObject2, x, y, z)

Local oMenu 	:= PopupMenu(oTree)
Local oSideBar 	:= oGrupoVerba:GetSidebar()

If oMenu <> Nil
	oMenu:Activate( x-24, y-100, oSideBar )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PopupMenu ºAutor  ³Acacio Egas         º Data ³  03/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Popup executado no xTree                                   º±±
±±º          ³                                                            º±±
±±ºSintaxe   ³ LoadTree(ExpC1)                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ ExpC1 - Objeto xTree para disparar popup.                  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PopupMenu(oTree)

Local oMenu := Nil
Local cCargo := oTree:GetCargo()
Local cAlias := SubStr(cCargo,1,3)
Local cCC, cFunc
Local bConfExcl := { |x| Aviso( STR0006 ,STR0007 + x + " ? ", { STR0008, STR0009 }) == 1 }  //	"Atencao"###"Confirma Exclusao "##"Sim"###"Nao"

Local bDelAM3 := {||  }

Do Case	
	Case cAlias == "AM3"
	
		Menu oMenu Popup
		MenuItem STR0010 Block {|| PcoInsertAM3(), ;
																		oTree:TreeSeek("AM3"+AM3->(AM3_FILIAL+AM3_GRUPO)), ;
																		Eval(bShow_01) } // "Adicionar Grupo de Verba"
		
		If cCargo != "AM3GRUPOVERBA"
			MenuItem STR0011 Block {|| oGrupoVerba:Bt(1,"WIN2") } //"Alterar Grupo de Verba"
			MenuItem STR0012 Block {|| If(Eval(bConfExcl, ""), PcoDeleteAM3(), NIL) } //"Excluir Grupo de Verba"
		EndIf	
		
		EndMenu
		
	Otherwise		
		// sem menu
EndCase

Return oMenu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoInsertAM3 ºAutor  ³Paulo Carnelossi    º Data ³  09/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir Grupo de Verbas no xTree.                             º±±
±±º          ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoInsertAM3()
Local lInclui, lAltera 
Local nOpc
dbSelectArea("AM3")
//salva estado anterior
lInclui := Inclui
lAltera := Altera

Inclui := .T.
Altera := .F.

nOpc := axInclui("AM3",AM3->(Recno()),3,,,,,,,) 

If nOpc==1

	Inclui := lInclui
	Altera := lAltera
	
	PcoAtuAgreg()
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoDeleteAM3 ºAutor  ³Paulo Carnelossi    º Data ³  09/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Excluir Grupo de Verbas no xTree.                             º±±
±±º          ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoDeleteAM3()
Local lInclui, lAltera 
Local cCargo := oGrupoVerba:GetTre("001"):GetCargo()
Local lContinua

//salva estado anterior
lInclui := Inclui
lAltera := Altera

Inclui := .F.
Altera := .F.

dbSelectArea(Left(cCargo,3))

If dbSeek(Subs(cCargo,4))

	lContinua := ! PcoVerComp()
   
	If lContinua

		dbSelectArea("AM6")
		dbSetOrder(1)
		dbSeek(xFilial("AM6")+AM3->AM3_GRUPO)
		aRecAM6 :=	{}
	
		While AM6->( ! Eof() .And. AM6_FILIAL+AM6_GRPPAI == xFilial("AM6")+AM3->AM3_GRUPO )
			RecLock("AM6", .F.)
			dbDelete()
			MsUnLock()
			AM6->(dbSkip())
		EndDo
	
		dbSelectArea("AM3")
		RecLock("AM3", .F.)
		dbDelete()
		MsUnLock()
		oGrupoVerba:GetTre("001"):DelItem()
		oGrupoVerba:GetTre("001"):TreeSeek("AM3GRUPOVERBA")

	Else

		Aviso( STR0006 , STR0013 , { STR0014 }) //"Atencao"###"O grupo de verba esta sendo utilizado. Verifique !"###"Ok"
	
	EndIf
		
EndIf	

//restaura estado anterior
Inclui := lInclui
Altera := lAltera

Return





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAtuAgreg ºAutor  ³Paulo Carnelossi  º Data ³  10/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tree                                                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAtuAgreg(lIni)

Local aArea 	:= GetArea()
Local aLoad 	:= {}
Local oTree 	:= oGrupoVerba:GetTre("001")

Default lIni := .F.

DbSelectArea("AM3")
DbSetorder(1)

// Monta Tree             
If lIni

	DbSeek(xFilial("AM3"))
	
	Do While AM3->(! Eof() .And. AM3_FILIAL == xFilial("AM3") )
	
		oGrupoVerba:LoadTree(oTree,"AM3",AM3->AM3_GRUPO,,1,.F.,aLoad)
			
		dbSelectArea("AM3")
		AM3->(DbSkip())
	
	EndDo               
	

Else

		oTree:TreeSeek("AM3GRUPOVERBA")
		oGrupoVerba:LoadTree(oTree,"AM3",AM3->AM3_GRUPO,,2,.F.,aLoad)
		
EndIf

RestArea(aArea)
	
Return

                   
Static Function PcoAtuBrow(lIniaCols)
Local cCargo := oGrupoVerba:GetTre("001"):GetCargo()
Local oGet := oGrupoVerba:GetMsm("001")
Local oGetDados := oGrupoVerba:GetGtd("001")
Local lContinua
Local cCodGrupo

Default lIniaCols := .T.

dbSelectArea(Left(cCargo,3))
lContinua := dbSeek(Subs(cCargo,4))
//atualiza enchoice
RegToMemory("AM3", .F.,,, FunName())
oGet:EnchRefreshAll()

If cCargo != "AM3GRUPOVERBA"  .And. lContinua// no Principal

		cCodGrupo := AM3->AM3_GRUPO
		
		//atualiza getdados
		dbSelectArea("AM6")
		dbSetOrder(1)
		lIniLin := ! dbSeek(xFilial("AM6")+cCodGrupo)
	
		aHeader := aClone(oGetDados:aHeader)

		If !lIniLin
		
			If ! lIniaCols
				aCols 	:= aClone(oGetDados:aCols)
			Else	
				aCols 	:= {}
			EndIf
				
			While AM6->( ! Eof() .And. AM6_FILIAL+AM6_GRPPAI == xFilial("AM6")+cCodGrupo )
				aAdd(aCols,Array(Len(aHeader) + 1))
				n		:= Len(aCols)
				AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
				// Deleted
				aCols[Len(aCols)][Len(aHeader) + 1] := .F.
				AM6->(dbSkip())
			EndDo
	
		Else

			aCols 	:= {}
			n		:= 1
			aAdd(aCols,Array(Len(aHeader) + 1))
			AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT",NIL,CriaVar(AllTrim(x[2]))) })
			// Deleted
			aCols[Len(aCols)][Len(aHeader) + 1] := .F.

		EndIf

		oGetDados:aCols 	:= aCols
		oGetDados:aHeader	:= aHeader
		oGetDados:refresh()

Else

		aHeader := aClone(oGetDados:aHeader)
		aCols 	:= {}
		n		:= 1
		aAdd(aCols,Array(Len(aHeader) + 1))
		AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT",NIL,CriaVar(AllTrim(x[2]))) })
		// Deleted
		aCols[Len(aCols)][Len(aHeader) + 1] := .F.

		oGetDados:aCols 	:= aCols
		oGetDados:aHeader	:= aHeader
		oGetDados:refresh()

EndIf

Return

Static Function PcoGrvAM3()
Local cCargo := oGrupoVerba:GetTre("001"):GetCargo()
Local cCampo
Local nI

dbSelectArea(Left(cCargo,3))

If dbSeek(Subs(cCargo,4))

	Reclock("AM3", .F.)
	
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AM3_FILIAL"
			FieldPut(nI,xFilial())
		ElseIf Type("M->" + cCampo)<>"U"
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	
	MsUnLock()
	
EndIf

Return


Static Function PcoAtualAM6()
Local cCargo := oGrupoVerba:GetTre("001"):GetCargo()
Local oGetDados := oGrupoVerba:GetGtd("001")
Local aHeader := oGetDados:aHeader
Local nPosComp := aScan(aHeader, {|x| x[2] == "AM6_GRCOMP" })
Local nPosRec 
Local cCampo
Local nI, nX

dbSelectArea(Left(cCargo,3))

If dbSeek(Subs(cCargo,4))

	dbSelectArea("AM6")
	dbSetOrder(1)
	aRecAM6 :=	{}

	If dbSeek(xFilial("AM6")+AM3->AM3_GRUPO)
		While AM6->( ! Eof() .And. AM6_FILIAL+AM6_GRPPAI == xFilial("AM6")+AM3->AM3_GRUPO )
			aAdd(aRecAM6, { AM6->(Recno()), AM6->AM6_GRCOMP })
			AM6->(dbSkip())
		EndDo
	EndIf
   //apaga os recnos cuja linha na grade esteja deletado
	For nI := 1 TO Len(oGetDados:aCols)
		If oGetDados:aCols[nI, Len(aHeader)+1]  //se esta deletado
			If ( nPosRec := aScan(aRecAM6, {|x| x[2] == oGetDados:aCols[nI, nPosComp]} ) ) > 0
				dbSelectArea("AM6")
				dbGoto(aRecAM6[nPosRec, 1])
				RecLock("AM6", .F.)
				dbDelete()
				MsUnLock()
				aRecAM6[nPosRec, 1] := 0
			EndIf	
		EndIf
	Next
	//insere ou atualiza as linhas nao deletadas
	For nI := 1 TO Len(oGetDados:aCols)

		If ! oGetDados:aCols[nI, Len(aHeader)+1]  //se nao esta deletado

			If ( nPosRec := aScan(aRecAM6, {|x| x[2] == oGetDados:aCols[nI, nPosComp]} ) ) > 0

				dbSelectArea("AM6")
            	If aRecAM6[nPosRec, 1] > 0

					dbGoto(aRecAM6[nPosRec, 1])
					aRecAM6[nPosRec, 1] := 0 
			 		RecLock("AM6", .F.)

				Else

					RecLock("AM6", .T.)

				EndIf	

			Else

				RecLock("AM6", .T.)

			EndIf	
         //grava os campos do acols da getdados
			For nX := 1 TO Len(aHeader)

				If ( nPosCpo := FieldPos(aHeader[nX,2]) ) > 0

					FieldPut(nPosCpo, oGetDados:aCols[nI, nX])

				EndIf	

    		Next
	        //grava os campos que sao fixos (filial e codigo grupo de verba)
			AM6->AM6_FILIAL := xFilial("AM6")
			AM6->AM6_GRPPAI := AM3->AM3_GRUPO
			MsUnLock()

		EndIf

	Next
	//verifica se algum recno anterior esta com conteudo diferente de zero--em caso positivo deleta 
	For nX := 1 TO Len(aRecAM6)
		If aRecAM6[nX, 1] > 0
			dbSelectArea("AM6")
			dbGoto(aRecAM6[nX, 1])
			RecLock("AM6", .F.)
			dbDelete()
			MsUnLock()
			aRecAM6[nX, 1] := 0
		EndIf
	Next	
EndIf

Return

Static Function PcoVerComp()
Local cQuery := ""

cQuery += " SELECT AM6_GRCOMP "
cQuery += " FROM "
cQuery += RetSqlName("AM6")
cQuery += " WHERE "
cQuery += " AM6_FILIAL = '"+xFilial("AM6")+"' "
cQuery += " AND AM6_GRCOMP = '"+AM3->AM3_GRUPO+"' "
cQuery += " AND D_E_L_E_T_ =  ' ' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAM6", .T., .T. )

dbSelectArea("TMPAM6")
dbGoTop()

If ! Eof()
	lRet := .T.
Else
	lRet := .F.
EndIf

dbCloseArea()

Return(lRet)

Static Function PcoVerbaHTML()
Local cSayHTML
cSayHTML :=	"<H1>"
cSayHTML +=	STR0015 //"Planejamento Orçamentários - Grupos de Verbas"
cSayHTML +=	"</H1>"
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0016 //" Os grupos de verbas no planejamento orçamentário tem como objetivo agrupar os"
cSayHTML +=	STR0017 //" as diversas verbas utilizadas no sistema de folha de pagamento mas de forma  "
cSayHTML +=	STR0018 //" independente. Permite ainda a vinculacao de um grupo de verba com outros que "
cSayHTML +=	STR0019 //" servirao de base para compor o valor final."
cSayHTML +=	"</FONT> "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
Return(cSayHTML)
	
