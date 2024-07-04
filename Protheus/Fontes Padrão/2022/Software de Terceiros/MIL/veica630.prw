// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "protheus.ch"
#INCLUDE "DbTree.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEICA630.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEICA630 º Autor ³ Thiago              º Data ³  12/07/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Painel Cliente CEV.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA630()

// Objeto de Tamanho de Tela
Local oSize

// Objetos da Tela
Local oDlgBaseCli
Local oMenuTree
//
Local aOpcoes      := {} // Tabelas relacionadas no Cliente
//
Local ni           := 0
//
Private oLayer
Private oBrwPainel	// MBrowse do Painel
//
Private aRotina    := MenuDef()
Private aLbCliTot  := {}
Private aLbClient  := {}
Private cOrdCli    := "1C" // 1 - Codigo Crescente
//
//           |---|------------------------|-----------------------|-------|
//           |Tip| DescPai   Alias   Qtde | DescFilho Alias  Qtde | F3VX5 |
//           |---|------------------------|-----------------------|-------|
aAdd(aOpcoes,{ 2 , STR0041 , "VCF" , "IIf(VEICA630SA1(4,0),VEICM560(SA1->A1_COD,SA1->A1_LOJA,''),.t.)" }) // Dados Adicionais
aAdd(aOpcoes,{ 2 , STR0042 , "VC2" , "IIf(VEICA630SA1(4,0),VEICA570(SA1->A1_COD,SA1->A1_LOJA,''),.t.)" }) // Pessoas de Contato
aAdd(aOpcoes,{ 2 , STR0031 , "VC3" , "IIf(VEICA630SA1(4,0),VEICA580(SA1->A1_COD,SA1->A1_LOJA,''),.t.)" }) // Frota

//
VEICA630SA1(0,0) // Levantar Clientes
//
oSize := FwDefSize():New(.f.)
DEFINE MSDIALOG oDlgBaseCli TITLE STR0001 PIXEL FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] // Base de Clientes

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botão de fechar
oLayer := FWLayer():new()
oLayer:Init(oDlgBaseCli,.f.)

//Cria as colunas do Layer
oLayer:addCollumn('Menu'     ,20,.T.)
oLayer:addCollumn('LbCliente',80,.F.)

//Adiciona Janelas as colunas
oLayer:addWindow('Menu'     ,'Menu_W01' ,STR0002,100,.F.,.F., /* bAction */ ,, /* bGotFocus */ ) // Menu
oLayer:addWindow('LbCliente','LbCli_W01',STR0003,100,.F.,.F., /* bAction */ ,, /* bGotFocus */ ) // Clientes

// MENU LATERAL //
oLayer:setColSplit('Menu',CONTROL_ALIGN_RIGHT)
oMenuTree := Xtree():New(0, 0, 0, 0, oLayer:getWinPanel('Menu','Menu_W01'))
oMenuTree:Align := CONTROL_ALIGN_ALLCLIENT
oMenuTree:AddTreeItem( STR0004 , "LOCALIZA" , "PESQ" , , , &("{ || VEICA630SA1(2,0) }") ) // Pesquisar Cliente
oMenuTree:AddTreeItem( STR0036 , "FILTRO"   , "FILT" , , , &("{ || VEICA630SA1(3,0) }") ) // Filtrar Cliente
For ni := 1 to len(aOpcoes)
	If aOpcoes[ni,1] == 2 // Funcao Externa
		oMenuTree:AddTreeItem( aOpcoes[ni,2] , "PMSTASK4" , aOpcoes[ni,3] , , , &("{ || "+aOpcoes[ni,4]+" }") )
	EndIf
Next
oMenuTree:AddTreeItem( STR0005 , "FINAL" , "SAIR" , , , &("{ || oDlgBaseCli:End() }") ) // Sair

// LISTBOX DO CLIENTE //
oAuxPanel := oLayer:getWinPanel('LbCliente','LbCli_W01')
oAuxPanel:FreeChildren()
@ 001,001 LISTBOX oLbClient FIELDS HEADER STR0007,STR0043,STR0009 COLSIZES 50,30,300 SIZE 100,100 OF oAuxPanel PIXEL // Codigo / Loja / Nome do Cliente
oLbClient:SetArray(aLbClient)
oLbClient:bLine := { || { aLbClient[oLbClient:nAt,1] , aLbClient[oLbClient:nAt,3] , aLbClient[oLbClient:nAt,2] }}
oLbClient:Align:= CONTROL_ALIGN_ALLCLIENT
oLbClient:bHeaderClick := {|oObj,nCol| VEICA630SA1(1,nCol) , } // Ordenar Clientes

oDlgBaseCli:Activate()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VEICA630SA1º Autor ³ Thiago             º Data ³  12/06/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ SA1 - Clientes (Levanta/Ordena/Pesquisa/Posiciona/Filtra)  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nTp = 0 - Levantar Clientes SA1                            º±±
±±º          ³     = 1 - Ordenar Clientes                                 º±±
±±º          ³     = 2 - Pesquisar Cliente                                º±±
±±º          ³     = 3 - Filtrar Cliente                                  º±±
±±º          ³     = 4 - Posiciona no Cliente                             º±±
±±º          ³ nCol = Coluna do ListBox                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA630SA1(nTp,nCol)
Local nPos    := 0
Local lOk     := .f.
Local lRet    := .t.
Local cAuxCli := space(100)
Local cAux    := "INICIAL"
Local cQuery  := ""
Local cQAlSA1 := "SQLSA1"
If nTp == 0 // Levantar Clientes
	aLbCliTot := {}
	//
	cQuery := "SELECT SA1.A1_COD , SA1.A1_NOME , SA1.A1_LOJA FROM "+RetSqlName("SA1")+" SA1 "
	cQuery += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_COD"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1 , .F., .T. )
	While !( cQAlSA1 )->( Eof() )
		If cAux <> ( cQAlSA1 )->( A1_COD )+( cQAlSA1 )->( A1_LOJA )
			cAux := ( cQAlSA1 )->( A1_COD )+( cQAlSA1 )->( A1_LOJA )
			aadd(aLbCliTot,{ ( cQAlSA1 )->( A1_COD ) , UPPER(( cQAlSA1 )->( A1_NOME )) , ( cQAlSA1 )->( A1_LOJA ) })
		EndIf
		( cQAlSA1 )->(DbSkip())
	Enddo
	( cQAlSA1 )->( DbCloseArea() )
	//
	If len(aLbCliTot) <= 0
		aAdd(aLbCliTot,{"","",""})
	EndIf
	aLbClient := aClone(aLbCliTot)
	Asort(aLbClient,,,{|x,y| x[1]+x[3] < y[1]+y[3] })
ElseIf nTp == 1 // Ordenar Clientes
	If cOrdCli == strzero(nCol,1)+"C" // Crescente
		cOrdCli := strzero(nCol,1)+"D" // Decrescente
	Else
		cOrdCli := strzero(nCol,1)+"C" // Crescente
	EndIf
	If right(cOrdCli,1) == "C" // Crescente
		Asort(aLbClient,,,{|x,y| x[nCol]+x[3] < y[nCol]+y[3] })
		Asort(aLbCliTot,,,{|x,y| x[nCol]+x[3] < y[nCol]+y[3] })
	Else // Decrescente
		Asort(aLbClient,,,{|x,y| x[nCol]+x[3] > y[nCol]+y[3] })
		Asort(aLbCliTot,,,{|x,y| x[nCol]+x[3] > y[nCol]+y[3] })
	EndIf
	oLbClient:Refresh()
	oLbClient:SetFocus()
ElseIf nTp == 2 // Pesquisar Cliente
	DEFINE MSDIALOG oPesqCli FROM 000,000 TO 005,055 TITLE STR0004 OF oMainWnd // Pesquisar Cliente
	@ 004,004 TO 034,216 LABEL "" OF oPesqCli PIXEL
	@ 014,014 MSGET oAuxCli VAR cAuxCli PICTURE "@!" SIZE 140,08 OF oPesqCli PIXEL COLOR CLR_BLUE
	@ 014,160 BUTTON oOK PROMPT STR0006 OF oPesqCli SIZE 45,10 PIXEL ACTION ( lOk := .t. , oPesqCli:End() ) // Pesquisar
	ACTIVATE MSDIALOG oPesqCli CENTER
	If lOk .and. !Empty(cAuxCli)
		lOk := .f.
		Asort(aLbClient,,,{|x,y| x[2]+x[3] < y[2]+y[3] })
		For nPos := 1 to len(aLbClient)
			If Alltrim(cAuxCli) == left(aLbClient[nPos,2],len(Alltrim(cAuxCli)))
				lOk := .t.
				Exit
			EndIf
		Next
		If !lOk
			For nPos := 1 to len(aLbClient)
				If Alltrim(cAuxCli) $ aLbClient[nPos,2]
					lOk := .t.
					Exit
				EndIf
			Next
        EndIf
		If !lOk
			Asort(aLbClient,,,{|x,y| x[1]+x[3] < y[1]+y[3] })
			For nPos := 1 to len(aLbClient)
				If Alltrim(cAuxCli) $ aLbClient[nPos,1]+aLbClient[nPos,3]
					lOk := .t.
					Exit
				EndIf
			Next
		EndIf
		If lOk .and. nPos > 0
			oLbClient:nAt := nPos
			oLbClient:Refresh()
			oLbClient:SetFocus()
		EndIf
	EndIf
ElseIf nTp == 3 // Filtrar Clientes
	aLbClient := aClone(aLbCliTot)
	DEFINE MSDIALOG oFiltCli FROM 000,000 TO 005,055 TITLE STR0036 OF oMainWnd // Filtrar Cliente
	@ 004,004 TO 034,216 LABEL "" OF oFiltCli PIXEL
	@ 014,014 MSGET oAuxCli VAR cAuxCli PICTURE "@!" SIZE 140,08 OF oFiltCli PIXEL COLOR CLR_BLUE
	@ 014,160 BUTTON oOK PROMPT STR0037 OF oFiltCli SIZE 45,10 PIXEL ACTION ( lOk := .t. , oFiltCli:End() ) // Filtrar
	ACTIVATE MSDIALOG oFiltCli CENTER
	If !Empty(cAuxCli)
		aLbClient := {}
		lOk := .f.
		Asort(aLbCliTot,,,{|x,y| x[2] < y[2] })
		For nPos := 1 to len(aLbCliTot)
			If Alltrim(cAuxCli) == left(aLbCliTot[nPos,2],len(Alltrim(cAuxCli)))
				lOk := .t.
				aAdd(aLbClient,aClone(aLbCliTot[nPos]))
			EndIf
		Next
		If !lOk
			For nPos := 1 to len(aLbCliTot)
				If Alltrim(cAuxCli) $ aLbCliTot[nPos,2]
					lOk := .t.
					aAdd(aLbClient,aClone(aLbCliTot[nPos]))
				EndIf
			Next
        EndIf
		If !lOk
			Asort(aLbCliTot,,,{|x,y| x[1] < y[1] })
			For nPos := 1 to len(aLbCliTot)
				If Alltrim(cAuxCli) $ aLbCliTot[nPos,1]+aLbCliTot[nPos,3]
					lOk := .t.
					aAdd(aLbClient,aClone(aLbCliTot[nPos]))
				EndIf
			Next
		EndIf
		If len(aLbClient) <= 0
			aAdd(aLbClient,{"","",""})
		EndIf
	EndIf
	oLbClient:nAt := 1
	oLbClient:SetArray(aLbClient)
	oLbClient:bLine := { || { aLbClient[oLbClient:nAt,1] , aLbClient[oLbClient:nAt,3] , aLbClient[oLbClient:nAt,2] }}
	oLbClient:Refresh()
	oLbClient:SetFocus()
ElseIf nTp == 4 // Posiciona no Cliente
	If !Empty(aLbClient[oLbClient:nAt,1])
		DbSelectArea("SA1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA1")+aLbClient[oLbClient:nAt,1]+aLbClient[oLbClient:nAt,3])
			MsgStop(STR0039,STR0038) // Cliente nao encontrado! / Atencao
			lRet := .f.
		EndIf
	Else
		MsgStop(STR0039,STR0038) // Cliente nao encontrado! / Atencao
		lRet := .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  º Autor ³ Andre Luis Almeida  º Data ³  25/05/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MenuDef - Menu aRotina                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Return {{ STR0001 , "VEICA630" , 0 , 2 }} // Base de Clientes