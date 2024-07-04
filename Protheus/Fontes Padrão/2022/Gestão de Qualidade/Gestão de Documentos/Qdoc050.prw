#INCLUDE "QDOC050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDOC050 ³ Autor ³ Eduardo de Souza      ³ Data ³ 30/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consulta Documentos Referenciados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOC050()                   				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³  BOPS ³Programador³ Alteracao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³27/08/02³ FICHA ³Eduardo S. ³ Alterado para nao apresentar os botoes  ³±±
±±³        ³       ³           ³ pesquisa qdo nao houver dados p/ cons.  ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOC050()

Local oTree
Local oDlg
Local aButtons := {}
Local cFiltro  := ""
Local lTreeOk  := .F.

Private nSeqTree  := 0
Private cChaveTree:= Space(100)
Private cChaveSeq := "0000"
Private lEditPTree:= .T.
Private lTrat		:= GetMv("MV_QDOQDG",.T.,.F.)

DbSelectArea("QDH")
DbSetOrder(1)
cFiltro := 'QDH_FILIAL == "'+xFilial("QDH")+'" .and. ( (QDH_CANCEL != "S" .or. ( QDH_CANCEL == "S".and. QDH_STATUS!="L  " ) ) .and. ( QDH_OBSOL !="S" .or.( QDH_OBSOL == "S" .and. Dtos(QDH_DTLIM) >= "'+Dtos(dDataBase)+'" )))'
Set Filter to &(cFiltro)
DbGotop()

DEFINE MSDIALOG oDlg FROM 000,000 TO 385,625 TITLE OemToAnsi(STR0001) PIXEL // "Consulta Documentos Referenciados"
oTree:= DbTree():New(035,005,191,311,oDlg,,,.T.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Objetos Tree                      						    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(OemToAnsi(STR0002),OemToAnsi(STR0003),{|| QDC50Tree(@oTree,@lTreeOk)}) // "Carregando Lancamentos..." ### "Aguarde..."

If !lTreeOk
	oTree:AddTreeItem(Padr(OemToAnsi(STR0017),150),"FOLDER9",,StrZero(nSeqTree++,4)) // "Nao existem dados para esta consulta."
	oTree:EndTree()	
Else
	aButtons := {{"PESQUISA", {|| QDC050Pesq(@oTree,nBtn:=1) }	, OemToAnsi(STR0004) },;  //"Pesquisa Texto"
				 {"BMPVISUAL" , {|| QDC050Pesq(@oTree,nBtn:=2) }	, OemToAnsi(STR0005) }  } //"Proxima Pesquisa"
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ ||oDlg:End() },{ ||oDlg:End() },,aButtons) CENTERED

DbSelectArea("QDH")
Set Filter To

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDC50Tree  ³ Autor ³ Eduardo de Souza   ³ Data ³ 30/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Tree de Documentos Referenciados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDC50Tree(ExpO1,ExpL1)     				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tree                                       ³±±
±±³          ³ ExpL1 - Verifica se ha dados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC50Tree(oTree,lTreeOk)

Local oMenu
Local cDocto  	:= ""
Local cOrigem 	:= ""
Local cRvObrig	:= ""
Local cDesc   	:= ""
Local cCargo  	:= ""
Local cSx3Tit	:= RetTitle("QDH_TITULO")
Local nPosRec	:= 0
Local nLargLin	:= 250

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o menu de opcoes POPUP                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MENU oMenu POPUP
	MENUITEM OemToAnsi(STR0015) Action FActionQDO(1,oTree)	// "Cadastro"
	MENUITEM OemToAnsi(STR0006) Action FActionQDO(2,oTree)	// "Documento"
	MENUITEM OemToAnsi(STR0016) Action FActionQDO(3,oTree)	// "Posiciona Docto"
ENDMENU

oTree:bRClicked:= { |o,x,y| QDAtivPopUp(o,x,y,oMenu) } // Posicao x,y em relação a Dialog

QDH->(DbSeek(xFilial("QDH")))
While QDH->(!Eof())
	If QDB->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		lTreeOk:= .T.
		oTree:AddTree(Padr(OemToAnsi(STR0006)+": "+AllTrim(QDH->QDH_DOCTO)+" - "+QDH->QDH_RV+" - "+cSx3Tit+": "+AllTrim(QDH->QDH_TITULO),nLargLin),.T.,"PMSDOC",,,,"QDH"+StrZero(QDH->(Recno()),7)) // "Documento: "
		While QDB->(!Eof()) .And. QDB->QDB_FILIAL+QDB->QDB_DOCTO+QDB->QDB_RV == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV
			nPosRec := QDH->(Recno())
			cDocto	:= " "
			cDesc 	:= " "
			QDH->(DbSeek(xFilial() + QDB->QDB_DOCREF + QDUltRvDoc(QDB->QDB_DOCREF)))
			If !Empty(QDB->QDB_DOCREF)
				cDocto:= OemToAnsi(STR0006)+": "+AllTrim(QDB->QDB_DOCREF)+" - " + cSx3Tit + ": " + AllTrim(QDH->QDH_TITULO) + " - " // "Documento: "
			EndIf
			If QDB->QDB_ORIGEM == "I"
				cOrigem:= OemToAnsi(STR0007)+OemToAnsi(STR0008)+" - " // "Origem: " ### "Interno"
			Else
				cOrigem:= OemToAnsi(STR0007)+OemToAnsi(STR0009)+" - " // "Origem: " ### "Externo"
			EndIf				
			If QDB->QDB_REVIS == "S"
				cRvObrig:= OemToAnsi(STR0010)+OemToAnsi(STR0011) // "Rev. Obrig: " ### "Sim"
			Else
				cRvObrig:= OemToAnsi(STR0010)+OemToAnsi(STR0012) // "Rev. Obrig: " ### "Nao"
			EndIf
			If !Empty(QDB->QDB_DESC)
				cDesc:= " - "+AllTrim(QDB->QDB_DESC)
			EndIf
			If !Empty(cDocto) .And. QDB->QDB_ORIGEM == "I"
				cCargo:= "QDB"+StrZero(QDB->(Recno()),7)		
			Else
				cCargo:= ""+StrZero(QDB->(Recno()),7)
			EndIf						
			oTree:AddTreeItem(Padr(cDocto+cOrigem+cRvObrig+cDesc,nLargLin),"FOLDER9",,cCargo)
			QDH->(DbGoto(nPosRec))
			QDB->(DbSkip())
		EndDo
		oTree:EndTree()
	EndIf
	QDH->(DbSkip())
EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDC050Pesq ³ Autor ³ Eduardo de Souza   ³ Data ³ 30/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa Texto                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDC020Pesq(oTree)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC050Pesq(oTree,nBtn)

Local oDlgPesq
Local oBtn1
Local oBtn2
Local nOpcao:= 0
Local lAchou:= .F.

If nBtn == 1 // "Pesquisa Texto"
	lEditPTree := .T.		
Else         // "Proxima Pesquisa"
	lEditPTree := .F.
EndIf

If lEditPTree
	DEFINE MSDIALOG oDlgPesq FROM 0,0 TO 080,634 PIXEL TITLE OemToAnsi(STR0004)	// "Pesquisa Texto"
    cChaveTree:= Padr(cChaveTree,100)
	@ 010,05 MSGET cChaveTree SIZE 310,08 OF oDlgPesq PIXEL

	DEFINE SBUTTON oBtn1 FROM 25,005 TYPE 1 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=1,oDlgPesq:End() )
	DEFINE SBUTTON oBtn2 FROM 25,035 TYPE 2 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=2,oDlgPesq:End() )

	ACTIVATE MSDIALOG oDlgPesq CENTERED
EndIf

If (nOpcao == 1 .Or. nOpcao == 0) .And. !Empty(AllTrim(cChaveTree))
	cChaveTree := UPPER(AllTrim(cChaveTree))
	DbSelectArea(oTree:cArqTree)
	DbGoTop()	
	While !Eof()
		If cChaveTree $ UPPER(T_PROMPT)
			If (nOpcao == 0 .And. T_CARGO > cChaveSeq) .Or. nOpcao == 1
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				// Colocado duas vezes para posicionar na linha onde esta o texto
				// porque se buscar uma vez posiciona no Item pai.                
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				cChaveSeq := T_CARGO
				lAchou := .T.
				lEditPTree := .F.
				Exit
			EndIf
		EndIf
		DbSkip()
	EndDo
	If !lAchou
		If cChaveSeq <> "0000"
			lEditPTree := .T.
		Endif
		MsgAlert(OemToAnsi(STR0013+" '"+cChaveTree+"' "+STR0014))	// "Texto" ### "nao encontrado"
	Else
		lEditPTree := .F.
	Endif
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FActionQDO ³ Autor ³ Eduardo de Souza    ³ Data ³ 30/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para carregar os Cadastros \ Documentos \ Avisos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FActionQDO(nOpcao,oTree)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numerico contendo a opcao(1-Cad/2-Docto/3-Aviso)   ³±±
±±³          ³ ExpO1 - Objeto do Tree para poder pegar o numero do recno()³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FActionQDO(nOpcao,oTree)

Local cCargo   :=oTree:GetCargo()
Local nReg     := 0
Local cRv      := ""

Private aRotina  := { {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"
Private cCadastro:= OemToAnsi( STR0001 ) // "Lancamentos Pendentes"
Private bCampo   := { |nCPO| Field( nCPO ) }       
Private lSolicitacao	:= .f.

INCLUI := .F.

DbSelectArea("QDH")
DbSetOrder(1)
If Left(cCargo,3) == "QDH"
	nReg := Val(SubStr(cCargo,4,7))
	DbSelectArea("QDH")
	DbGoTo(nReg)
   If QDH->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		If nOpcao == 1 	// Cadastro
			QD050Telas("QDH",QDH->(RecNo()),8)
		ElseIf nOpcao == 2 // Documento
			QdoDocCon()	
		EndIf
	EndIf	
ElseIf Left(cCargo,3) == "QDB"
	nReg := Val(SubStr(cCargo,4,7))
	DbSelectArea("QDB")
	DbGoTo(nReg)
   cRv:= QDUltRvDoc(QDB->QDB_DOCREF)   
   If QDH->(DbSeek(QDB->QDB_FILIAL+QDB->QDB_DOCREF+cRv))
		If nOpcao == 1 	// Cadastro
			QD050Telas("QDH",QDH->(RecNo()),8)
		ElseIf nOpcao == 2 // Documento
			QdoDocCon()	
		ElseIf nOpcao == 3 // Posiciona Documento
		   cChaveTree:= UPPER(AllTrim(QDB->QDB_DOCREF)+" - "+cRv)
			DbSelectArea(oTree:cArqTree)
			DbGotop()	
			While !Eof()
				If cChaveTree $ UPPER(T_PROMPT)
					oTree:TreeSeek(T_CARGO)
					oTree:Refresh()
					Exit
				EndIf
				DbSkip()
			EndDo
		EndIf
	Else
		MsgAlert(OemToAnsi(STR0006)+" "+OemToAnsi(STR0014))	// "Documento" ### "nao encontrado"
	EndIf	
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDAtivPopUp³ Autor ³ Eduardo de Souza    ³ Data ³ 30/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para Ativar Pop-Up                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDAtivPopUp(oTree,nX,nY,oMenu)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do Tree                                     ³±±
±±³          ³ ExpN1 - Numerico contendo as coordenadas da linha          ³±±
±±³          ³ ExpN2 - Numerico contendo as coordenadas da coluna         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDAtivPopUp(oTree,nX,nY,oMenu)

Local cCargo := oTree:GetCargo() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( oMenu:aItems, { |x| x:Disable() } ) 
If Left(cCargo,3) == "QDH" .Or. Left(cCargo,3) == "QDB"
	oMenu:aItems[1]:enable()
	oMenu:aItems[2]:enable()
	If Left(cCargo,3) == "QDB"
		oMenu:aItems[3]:enable()
	EndIf
EndIf

oMenu:Activate( nX, nY, oTree )

Return
