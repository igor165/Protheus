// ษออออออออหออออออออป
// บ Versao บ 5      บ
// ศออออออออสออออออออผ

#INCLUDE "protheus.ch"
#INCLUDE "DbTree.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIVA340.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ VEIVA340 บ Autor ณ Andre Luis Almeida  บ Data ณ  25/05/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Base de Clientes                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340()

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
aAdd(aOpcoes,{ 1 , STR0032 , "VMX" , 999 , ""      , ""    ,   0 , ""    }) // Atividades
aAdd(aOpcoes,{ 1 , STR0011 , "VMD" , 999 , ""      , ""    ,   0 , ""    }) // Dependentes
aAdd(aOpcoes,{ 1 , STR0013 , "VME" ,   1 , ""      , ""    ,   0 , ""    }) // Dados Pessoais
aAdd(aOpcoes,{ 1 , STR0014 , "VMF" , 999 , ""      , ""    ,   0 , ""    }) // Dados Profissionais
aAdd(aOpcoes,{ 1 , STR0012 , "VMG" ,   1 , ""      , ""    ,   0 , ""    }) // Conjuge
aAdd(aOpcoes,{ 1 , STR0040 , "VMZ" , 999 , ""      , ""    ,   0 , ""    }) // S๓cios/Administradores
aAdd(aOpcoes,{ 1 , STR0015 , "VMH" , 999 , ""      , ""    ,   0 , ""    }) // Referencias Comerciais
aAdd(aOpcoes,{ 1 , STR0016 , "VMI" , 999 , ""      , ""    ,   0 , ""    }) // Referencias Bancarias
aAdd(aOpcoes,{ 1 , STR0017 , "VMJ" , 999 , STR0018 , "VMK" , 999 , "003" }) // Propriedades Agricolas  /  Culturas *
aAdd(aOpcoes,{ 1 , STR0019 , "VML" , 999 , ""      , ""    ,   0 , ""    }) // Pecuaria
aAdd(aOpcoes,{ 1 , STR0020 , "VMM" , 999 , ""      , ""    ,   0 , ""    }) // Regime de Exploracao
aAdd(aOpcoes,{ 1 , STR0021 , "VMN" , 999 , ""      , ""    ,   0 , "001" }) // Endividamento *
aAdd(aOpcoes,{ 1 , STR0022 , "VMO" , 999 , ""      , ""    ,   0 , ""    }) // Dividas e Aquisicoes
aAdd(aOpcoes,{ 1 , STR0023 , "VMP" , 999 , STR0024 , "VMQ" , 999 , ""    }) // Principal Produto/Servi็o  /  Prestacao de Servicos
aAdd(aOpcoes,{ 1 , STR0025 , "VMR" , 999 , ""      , ""    ,   0 , ""    }) // Participacoes
aAdd(aOpcoes,{ 1 , STR0026 , "VMS" , 999 , ""      , ""    ,   0 , ""    }) // Outras Rendas
aAdd(aOpcoes,{ 1 , STR0027 , "VMT" , 999 , ""      , ""    ,   0 , ""    }) // Pecuaria / Integracao
aAdd(aOpcoes,{ 1 , STR0035 , "VP6" , 999 , ""      , ""    ,   0 , ""    }) // Bens e Im๓veis
aAdd(aOpcoes,{ 1 , STR0028 , "VMU" ,   1 , ""      , ""    ,   0 , ""    }) // Outras Informacoes
aAdd(aOpcoes,{ 1 , STR0029 , "VMV" , 999 , STR0030 , "VMW" , 999 , "002" }) // Benfeitorias *  /  Instalacoes
//           |Tip| Descric  | Alias | Programa                                      |
aAdd(aOpcoes,{ 2 , STR0031 , "VC3" , "IIf(VEIVA340SA1(4,0),VEICA580(SA1->A1_COD,''),.t.)" }) // Frota (frota do Cliente independente a LOJA)
If ExistBlock("VA340RR")
	//           |Tip| Descric  | Opcao | Ponto de Entrada                                                   |
	aAdd(aOpcoes,{ 3 , STR0033 , "PE"  , "IIf(VEIVA340SA1(4,0),ExecBlock('VA340RR',.f.,.f.,{SA1->A1_COD,''}),.t.)" }) // Resumo da Renda
EndIf
If ExistBlock("VA340IM")
	//           |Tip| Descric  | Opcao | Ponto de Entrada                                                   |
	aAdd(aOpcoes,{ 4 , STR0034 , "PE"  , "IIf(VEIVA340SA1(4,0),ExecBlock('VA340IM',.f.,.f.,{SA1->A1_COD,''}),.t.)" }) // Ficha do Cliente
EndIf
//
VEIVA340SA1(0,0) // Levantar Clientes
//
oSize := FwDefSize():New(.f.)
DEFINE MSDIALOG oDlgBaseCli TITLE STR0001 PIXEL FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] // Base de Clientes

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botใo de fechar
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
oMenuTree:AddTreeItem( STR0004 , "LOCALIZA" , "PESQ" , , , &("{ || VEIVA340SA1(2,0) }") ) // Pesquisar Cliente
oMenuTree:AddTreeItem( STR0036 , "FILTRO"   , "FILT" , , , &("{ || VEIVA340SA1(3,0) }") ) // Filtrar Cliente
For ni := 1 to len(aOpcoes)
	If aOpcoes[ni,1] == 1 // Funcao Padrao
		oMenuTree:AddTreeItem( aOpcoes[ni,2] , "PMSTASK4" , aOpcoes[ni,3] , , , &("{ || VEIVA340CAD('"+aOpcoes[ni,2]+"','"+aOpcoes[ni,3]+"',"+Alltrim(str(aOpcoes[ni,4]))+",'"+aOpcoes[ni,5]+"','"+aOpcoes[ni,6]+"',"+Alltrim(str(aOpcoes[ni,7]))+",'"+aOpcoes[ni,8]+"') }") )
	ElseIf aOpcoes[ni,1] == 2 // Funcao Externa
		oMenuTree:AddTreeItem( aOpcoes[ni,2] , "PMSTASK4" , aOpcoes[ni,3] , , , &("{ || "+aOpcoes[ni,4]+" }") )
	ElseIf aOpcoes[ni,1] == 3 // User Function VA340RR ( Resumo da Renda )
		oMenuTree:AddTreeItem( aOpcoes[ni,2] , "PMSTASK3" , aOpcoes[ni,3] , , , &("{ || "+aOpcoes[ni,4]+" }") )
	ElseIf aOpcoes[ni,1] == 4 // User Function VA340IM ( Impressao )
		oMenuTree:AddTreeItem( aOpcoes[ni,2] , "PMSTASK2" , aOpcoes[ni,3] , , , &("{ || "+aOpcoes[ni,4]+" }") )
	EndIf
Next
oMenuTree:AddTreeItem( STR0005 , "FINAL" , "SAIR" , , , &("{ || oDlgBaseCli:End() }") ) // Sair

// LISTBOX DO CLIENTE //
oAuxPanel := oLayer:getWinPanel('LbCliente','LbCli_W01')
oAuxPanel:FreeChildren()
@ 001,001 LISTBOX oLbClient FIELDS HEADER STR0007,STR0009 COLSIZES 50,300 SIZE 100,100 OF oAuxPanel PIXEL // Codigo / Nome do Cliente
oLbClient:SetArray(aLbClient)
oLbClient:bLine := { || { aLbClient[oLbClient:nAt,1] , aLbClient[oLbClient:nAt,2] }}
oLbClient:Align:= CONTROL_ALIGN_ALLCLIENT
oLbClient:bHeaderClick := {|oObj,nCol| VEIVA340SA1(1,nCol) , } // Ordenar Clientes

oDlgBaseCli:Activate()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340SA1บ Autor ณ Andre Luis Almeida บ Data ณ  25/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ SA1 - Clientes (Levanta/Ordena/Pesquisa/Posiciona/Filtra)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTp = 0 - Levantar Clientes SA1                            บฑฑ
ฑฑบ          ณ     = 1 - Ordenar Clientes                                 บฑฑ
ฑฑบ          ณ     = 2 - Pesquisar Cliente                                บฑฑ
ฑฑบ          ณ     = 3 - Filtrar Cliente                                  บฑฑ
ฑฑบ          ณ     = 4 - Posiciona no Cliente                             บฑฑ
ฑฑบ          ณ nCol = Coluna do ListBox                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340SA1(nTp,nCol)
Local nPos    := 0
Local lOk     := .f.
Local lRet    := .t.
Local cAuxCli := space(100)
Local cAux    := "INICIAL"
Local cQuery  := ""
Local cQAlSA1 := "SQLSA1"

Local oCombo  := Nil
Local cTpSel  := SPACE(10)
Local aTipoFil:= {"1=Nome","2=C๓digo"}
Local nPosPesq:= 2 //Por Nome

If nTp == 0 // Levantar Clientes
	aLbCliTot := {}
	//
	cQuery := "SELECT SA1.A1_COD , SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 "
	cQuery += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_MSBLQL <> '1' AND SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_COD, SA1.A1_LOJA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1 , .F., .T. )
	While !( cQAlSA1 )->( Eof() )
		If cAux <> ( cQAlSA1 )->( A1_COD )
			cAux := ( cQAlSA1 )->( A1_COD )
			aadd(aLbCliTot,{ ( cQAlSA1 )->( A1_COD ) , UPPER(( cQAlSA1 )->( A1_NOME )) })
		EndIf
		( cQAlSA1 )->(DbSkip())
	Enddo
	( cQAlSA1 )->( DbCloseArea() )
	//
	If len(aLbCliTot) <= 0
		aAdd(aLbCliTot,{"",""})
	EndIf
	aLbClient := aClone(aLbCliTot)
ElseIf nTp == 1 // Ordenar Clientes
	If cOrdCli == strzero(nCol,1)+"C" // Crescente
		cOrdCli := strzero(nCol,1)+"D" // Decrescente
	Else
		cOrdCli := strzero(nCol,1)+"C" // Crescente
	EndIf
	If right(cOrdCli,1) == "C" // Crescente
		Asort(aLbClient,,,{|x,y| x[nCol] < y[nCol] })
		Asort(aLbCliTot,,,{|x,y| x[nCol] < y[nCol] })
	Else // Decrescente
		Asort(aLbClient,,,{|x,y| x[nCol] > y[nCol] })
		Asort(aLbCliTot,,,{|x,y| x[nCol] > y[nCol] })
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
		Asort(aLbClient,,,{|x,y| x[2] < y[2] })
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
			Asort(aLbClient,,,{|x,y| x[1] < y[1] })
			For nPos := 1 to len(aLbClient)
				If Alltrim(cAuxCli) $ aLbClient[nPos,1]
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

	DEFINE MSDIALOG oFiltCli FROM 000,000 TO 005,065 TITLE STR0036 OF oMainWnd // Filtrar Cliente
	@ 004,004 TO 034,255 LABEL "" OF oFiltCli PIXEL
	@ 014,014 MSCOMBOBOX oCombo VAR cTpSel ITEMS aTipoFil SIZE 045,10 OF oFiltCli PIXEL // Tipo
	@ 014,060 MSGET oAuxCli VAR cAuxCli PICTURE "@!" SIZE 140,08 OF oFiltCli PIXEL COLOR CLR_BLUE
	@ 014,201 BUTTON oOK PROMPT STR0037 OF oFiltCli SIZE 45,10 PIXEL ACTION ( lOk := .t. , oFiltCli:End() ) // Filtrar
	ACTIVATE MSDIALOG oFiltCli CENTER

	If !Empty(cAuxCli)
		aLbClient := {}
		lOk := .f.

		If cTpSel == "1" //Por Nome
			Asort(aLbCliTot,,,{|x,y| x[2] < y[2] })
			nPosPesq := 2
		Else //Por C๓digo
			Asort(aLbCliTot,,,{|x,y| x[1] < y[1] })
			nPosPesq := 1
		EndIf

		For nPos := 1 to len(aLbCliTot)
			If Alltrim(cAuxCli) == left(aLbCliTot[nPos,nPosPesq],len(Alltrim(cAuxCli)))
				aAdd(aLbClient,aClone(aLbCliTot[nPos]))
			ElseIf Alltrim(cAuxCli) $ aLbCliTot[nPos,nPosPesq]
				aAdd(aLbClient,aClone(aLbCliTot[nPos]))
			EndIf
		Next

		If len(aLbClient) <= 0
			aAdd(aLbClient,{"",""})
		EndIf
	EndIf

	oLbClient:nAt := 1
	oLbClient:SetArray(aLbClient)
	oLbClient:bLine := { || { aLbClient[oLbClient:nAt,1] , aLbClient[oLbClient:nAt,2] }}
	oLbClient:Refresh()
	oLbClient:SetFocus()

ElseIf nTp == 4 // Posiciona no Cliente
	If !Empty(aLbClient[oLbClient:nAt,1])
		cQuery := "SELECT R_E_C_N_O_ SA1RECNO FROM "+RetSqlName("SA1")+" SA1 "
		cQuery += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD = '"+aLbClient[oLbClient:nAt,1]+"' AND SA1.A1_MSBLQL <> '1' AND SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_COD,SA1.A1_LOJA"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1 , .F., .T. )
		if !( cQAlSA1 )->( Eof() ) 
			dbSelectArea("SA1")
			dbSetOrder(1)
			DbGoTo(( cQAlSA1 )->SA1RECNO)
			( cQAlSA1 )->( DbCloseArea() )
		Else
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340CADบ Autor ณ Andre Luis Almeida บ Data ณ  25/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Monta TELA estilo modelo 3                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ c1Tit - Titulo da Tela                                     บฑฑ
ฑฑบ          ณ c1Ali - Alias GetDados1                                    บฑฑ
ฑฑบ          ณ n1Lin - Linhas GetDados1 1 = 1 registro / n registros      บฑฑ
ฑฑบ          ณ c2Tit - Sub-Titulo da Tela - GetDados2                     บฑฑ
ฑฑบ          ณ c2Ali - Alias GetDados2                                    บฑฑ
ฑฑบ          ณ n2Lin - Linhas GetDados2 1 = 1 registro / n registros      บฑฑ
ฑฑบ          ณ cFVX5 - Filtro na Tabela Generica de Concessionaria ( VX5 )บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340CAD(c1Tit,c1Ali,n1Lin,c2Tit,c2Ali,n2Lin,cFVX5)
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nOpcao   := 0
Local nCntFor  := 0
//
Local aCols1   := {}
Local aCols2   := {}
//
Local cLinOk1  := ""
Local cTudOk1  := ""
Local cFldOk1  := ""
Local cLinOk2  := ""
Local cTudOk2  := ""
Local cFldOk2  := ""
//
Private nPosSeq1   := 0 // Posicao do campo SEQUENCIA no aCols 1
Private nPosSeq2   := 0 // Posicao do campo SEQUENCIA no aCols 2
Private nPosSeqP   := 0 // Posicao do campo SEQUENCIA PAI no aCols 2
Private nPosLog1   := 0 // Posicao do campo LOGALT no aCols 1
Private nPosLog2   := 0 // Posicao do campo LOGALT no aCols 2
//
Private aHeader1   := {}
Private aHeader2   := {}
Private aCols2Tot  := {} // aCols2 Total
Private aCols2Bco  := {} // aCols2 em Branco
//
Private cFiltroVX5 := cFVX5 // Filtro na Tabela Generica de Concessionaria ( VX5 )
//
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 01 , 26 , .T. , .F. } ) 		// Cliente
AAdd( aObjects, { 01 , 10 , .T. , .T. } )  	// GetDados 1
If !Empty(c2Ali)
	AAdd( aObjects, { 01, 10 , .T. , .T. } )  	// GetDados 2
EndIf

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

cCadastro := c1Tit
nOpc      := 4

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
/////////////////////////////////////////

If !VEIVA340SA1(4,0) // Posiciona no Cliente
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader da GetDados 1                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(c1Ali)
While !Eof().And.(x3_arquivo==c1Ali)
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And.  !( Trim(SX3->X3_CAMPO) $ c1Ali+"_FILIAL/"+c1Ali+"_CODCLI/" )
		aAdd(aHeader1,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif
	dbSelectArea("SX3")
	dbSkip()
EndDo
dbSelectArea(c1Ali)
nPosSeq1 := FG_POSVAR(c1Ali+"_CODSEQ","aHeader1")
nPosLog1 := FG_POSVAR(c1Ali+"_LOGALT","aHeader1")
If nPosSeq1 == 0 // Caso nao exista o campo de SEQUENCIA
	n1Lin := 1 // Deixar apenas 1 registro na aCols
EndIf
If !Empty(c2Ali)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aHeader da GetDados 2                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(c2Ali)
	While !Eof().And.(x3_arquivo==c2Ali)
		If X3USO(x3_usado).And.cNivel>=x3_nivel .And.  !( Trim(SX3->X3_CAMPO) $ c2Ali+"_FILIAL/"+c2Ali+"_CODCLI/" )
			aAdd(aHeader2,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
			&("M->"+x3_campo) := CriaVar(x3_campo)
		Endif
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	dbSelectArea(c2Ali)
	nPosSeq2 := FG_POSVAR(c2Ali+"_CODSEQ","aHeader2")
	nPosLog2 := FG_POSVAR(c2Ali+"_LOGALT","aHeader2")
	If nPosSeq2 == 0 // Caso nao exista o campo de SEQUENCIA
		n2Lin := 1 // Deixar apenas 1 registro na aCols2
	EndIf
	nPosSeqP := FG_POSVAR(c2Ali+"_PAISEQ","aHeader2")
EndIf
//
DEFINE MSDIALOG oVA340Tela TITLE c1Tit FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
//
@ aPosObj[1,1]+000,aPosObj[1,2]+002 TO aPosObj[1,3],aPosObj[1,4] LABEL (" "+STR0010+" ") OF oVA340Tela PIXEL // Cliente
@ aPosObj[1,1]+011,aPosObj[1,2]+010 SAY (STR0007+":") SIZE 50,8 OF oVA340Tela PIXEL COLOR CLR_BLUE // Codigo
@ aPosObj[1,1]+010,aPosObj[1,2]+035 MSGET oCodCli VAR SA1->A1_COD PICTURE "@!" SIZE 40,08 OF oVA340Tela PIXEL COLOR CLR_BLUE WHEN .f.
@ aPosObj[1,1]+011,aPosObj[1,2]+100 SAY (STR0008+":") SIZE 50,8 OF oVA340Tela PIXEL COLOR CLR_BLUE // Nome
@ aPosObj[1,1]+010,aPosObj[1,2]+125 MSGET oNomCli VAR SA1->A1_NOME PICTURE "@!" SIZE (aPosObj[1,4]-135),08 OF oVA340Tela PIXEL COLOR CLR_BLUE WHEN .f.
//
cLinOk1 := "VEIVA340LOK(1,'"+c1Ali+"')"
cTudOk1 := "VEIVA340TOK(1,'"+c1Ali+"')"
cFldOk1 := "VEIVA340FOK(1,'"+c1Ali+"')"
oGDVA3401:= MsNewGetDados():New(aPosObj[2,1]+002,aPosObj[2,2]+002,aPosObj[2,3]-001,aPosObj[2,4],GD_INSERT+GD_UPDATE+GD_DELETE,cLinOK1,cTudOk1,,,,n1Lin,cFldOk1,,,oVA340Tela,aHeader1,aCols1)
oGDVA3401:oBrowse:bChange := {|| FG_MEMVAR(aHeader1,oGDVA3401:aCols,oGDVA3401:nAt) , VEIVA340SEQ(1,c1Ali,"") , IIf(!Empty(c2Ali),VEIVA340ACO(2,c1Ali,c2Ali),.t.) }
oGDVA3401:oBrowse:bDelete := {|| VEIVA340DEL(1,c1Ali,c2Ali) }
//
oGDVA3401:aCols := {}
dbSelectArea(c1Ali)
dbSetOrder(1)
DbSeek(xFilial(c1Ali)+SA1->A1_COD)
While !Eof() .and. &(c1Ali+"->"+c1Ali+"_FILIAL+"+c1Ali+"->"+c1Ali+"_CODCLI") == xFilial(c1Ali)+SA1->A1_COD
	AADD(oGDVA3401:aCols,Array(Len(oGDVA3401:aHeader)+1))
	For nCntFor := 1 to Len(oGDVA3401:aHeader)
		If IsHeadRec(oGDVA3401:aHeader[nCntFor,2])
			oGDVA3401:aCols[Len(oGDVA3401:aCols),nCntFor] := &(c1Ali+"->(Recno())")
		ElseIf IsHeadAlias(oGDVA3401:aHeader[nCntFor,2])
			oGDVA3401:aCols[Len(oGDVA3401:aCols),nCntFor] := c1Ali
		Else
			oGDVA3401:aCols[Len(oGDVA3401:aCols),nCntFor] := IIf(oGDVA3401:aHeader[nCntFor,10] # "V",FieldGet(FieldPos(oGDVA3401:aHeader[nCntFor,2])),CriaVar(oGDVA3401:aHeader[nCntFor,2]))
		EndIF
	Next
	oGDVA3401:aCols[Len(oGDVA3401:aCols),Len(oGDVA3401:aHeader)+1] := .F.
	dbSkip()
Enddo
If Len(oGDVA3401:aCols) == 0
	oGDVA3401:aCols := { Array(Len(oGDVA3401:aHeader)+1) }
	oGDVA3401:aCols[1,Len(oGDVA3401:aHeader)+1] := .F.
	For nCntFor:=1 to Len(oGDVA3401:aHeader)
		If IsHeadRec(oGDVA3401:aHeader[nCntFor,2])
			oGDVA3401:aCols[Len(oGDVA3401:aCols),nCntFor] := &(c1Ali+"->(Recno())")
		ElseIf IsHeadAlias(oGDVA3401:aHeader[nCntFor,2])
			oGDVA3401:aCols[Len(oGDVA3401:aCols),nCntFor] := c1Ali
		Else
			oGDVA3401:aCols[1,nCntFor] := CriaVar(oGDVA3401:aHeader[nCntFor,2])
		EndIf
	Next
EndIf
//
oGDVA3401:nAt := n := 1
//
If !Empty(c2Ali)
	@ aPosObj[3,1]+000,aPosObj[3,2]+004 SAY (c2Tit) SIZE 150,8 OF oVA340Tela PIXEL COLOR CLR_BLUE
	cLinOk2 := "VEIVA340LOK(2,'"+c2Ali+"')"
	cTudOk2 := "VEIVA340TOK(2,'"+c2Ali+"')"
	cFldOk2 := "VEIVA340FOK(2,'"+c2Ali+"')"
	oGDVA3402:= MsNewGetDados():New(aPosObj[3,1]+008,aPosObj[3,2]+002,aPosObj[3,3],aPosObj[3,4],GD_INSERT+GD_UPDATE+GD_DELETE,cLinOK2,cTudOk2,,,,n2Lin,cFldOk2,,,oVA340Tela,aHeader2,aCols2)
	oGDVA3402:oBrowse:bChange := {|| FG_MEMVAR(aHeader2,oGDVA3402:aCols,oGDVA3402:nAt) , VEIVA340SEQ(2,c2Ali,IIf(nPosSeq1>0,oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1],"")) }
	oGDVA3402:oBrowse:bDelete := {|| VEIVA340DEL(2,c1Ali,c2Ali) }
	//
	oGDVA3402:aCols := {}
	dbSelectArea(c2Ali)
	dbSetOrder(1)
	DbSeek(xFilial(c2Ali)+SA1->A1_COD)
	While !Eof() .and. &(c2Ali+"->"+c2Ali+"_FILIAL+"+c2Ali+"->"+c2Ali+"_CODCLI") == xFilial(c2Ali)+SA1->A1_COD
		AADD(oGDVA3402:aCols,Array(Len(oGDVA3402:aHeader)+1))
		For nCntFor := 1 to Len(oGDVA3402:aHeader)
			If IsHeadRec(oGDVA3402:aHeader[nCntFor,2])
				oGDVA3402:aCols[Len(oGDVA3402:aCols),nCntFor] := &(c2Ali+"->(Recno())")
			ElseIf IsHeadAlias(oGDVA3402:aHeader[nCntFor,2])
				oGDVA3402:aCols[Len(oGDVA3402:aCols),nCntFor] := c2Ali
			Else
				oGDVA3402:aCols[Len(oGDVA3402:aCols),nCntFor] := IIf(oGDVA3402:aHeader[nCntFor,10] # "V",FieldGet(FieldPos(oGDVA3402:aHeader[nCntFor,2])),CriaVar(oGDVA3402:aHeader[nCntFor,2]))
			EndIF
		Next
		oGDVA3402:aCols[Len(oGDVA3402:aCols),Len(oGDVA3402:aHeader)+1] := .F.
		dbSkip()
	Enddo
	VEIVA340ACO(1,c1Ali,c2Ali)
	//
	If Len(oGDVA3402:aCols) == 0
		oGDVA3402:aCols := aClone(aCols2Bco) // Inserir um registro em Branco na aCols2
	EndIf
	//
	oGDVA3402:nAt := n := 1
	//
EndIf
ACTIVATE MSDIALOG oVA340Tela ON INIT EnchoiceBar(oVA340Tela,{ || IIf(VEIVA340OK(c1Ali,c2Ali),(oVA340Tela:End(),nOpcao := 1),.f.) }, { || oVA340Tela:End() },,)

If nOpcao <> 0
	VEIVA340GRV(c1Ali,c2Ali)
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340FOKบ Autor ณ Andre Luis Almeida  บ Data ณ 27/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Field OK                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTp = 1 - aCols1                                           บฑฑ
ฑฑบ          ณ     = 2 - aCols2                                           บฑฑ
ฑฑบ          ณ cAliAux = Alias atual                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340FOK(nTp,cAliAux)
Local lRet    := .t.
Local nPos    := 0
Local nPosCpo := 0
If nTp == 2
	nPos := len(aCols2Tot)
	If ( nPosSeqP+nPosSeq2 ) > 0
		nPos := aScan(aCols2Tot, {|x| IIf(nPosSeqP>0,x[nPosSeqP],"")+IIf(nPosSeq2>0,x[nPosSeq2],"") == IIf(nPosSeqP>0,oGDVA3402:aCols[oGDVA3402:nAt,nPosSeqP],"")+IIf(nPosSeq2>0,oGDVA3402:aCols[oGDVA3402:nAt,nPosSeq2],"") }) // Verifica se ja existe registro no vetor aCols2Tot
	EndIf
	If nPos == 0
		aAdd(aCols2Tot,aClone(aCols2Bco[1]))
		nPos := len(aCols2Tot)
	EndIf
	nPosCpo := FG_POSVAR(substr(READVAR(),4),"aHeader2")
	If nPos > 0
		If nPosCpo > 0
			aCols2Tot[nPos,nPosCpo] := &(READVAR())
		EndIf
		If nPosSeqP > 0
			aCols2Tot[nPos,nPosSeqP] := oGDVA3402:aCols[oGDVA3402:nAt,nPosSeqP]
		EndIf
		If nPosSeq2 > 0
			aCols2Tot[nPos,nPosSeq2] := oGDVA3402:aCols[oGDVA3402:nAt,nPosSeq2]
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340DELบ Autor ณ Andre Luis Almeida  บ Data ณ 31/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Delete nas aCols1 e aCols2                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTp = 1 - aCols1                                           บฑฑ
ฑฑบ          ณ     = 2 - aCols2                                           บฑฑ
ฑฑบ          ณ c1Ali = Alias 1                                            บฑฑ
ฑฑบ          ณ c2Ali = Alias 2                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340DEL(nTp,c1Ali,c2Ali)
Local lOk  := .t.
Local nPos := 0
Local ni   := 0
If nTp == 1 // Delete aCols1
	oGDVA3401:aCols[oGDVA3401:nAt,Len(oGDVA3401:aCols[oGDVA3401:nAt])] := !oGDVA3401:aCols[oGDVA3401:nAt,Len(oGDVA3401:aCols[oGDVA3401:nAt])]
	oGDVA3401:oBrowse:Refresh()
	If !Empty(c2Ali)
		For ni := 1 to len(aCols2Tot)
			lOk := .t.
			If nPosSeqP > 0
				If aCols2Tot[ni,nPosSeqP] <> oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1]
					lOk := .f.
				EndIf
			EndIf
			If lOk
				aCols2Tot[ni,Len(aCols2Tot[ni])] := oGDVA3401:aCols[oGDVA3401:nAt,Len(oGDVA3401:aCols[oGDVA3401:nAt])]
			EndIf
		Next
		For ni := 1 to len(oGDVA3402:aCols)
			oGDVA3402:aCols[ni,Len(oGDVA3402:aCols[ni])] := oGDVA3401:aCols[oGDVA3401:nAt,Len(oGDVA3401:aCols[oGDVA3401:nAt])]
		Next
		oGDVA3402:oBrowse:Refresh()
	EndIf
ElseIf nTp == 2 // Delete aCols2
	If !oGDVA3401:aCols[oGDVA3401:nAt,Len(oGDVA3401:aCols[oGDVA3401:nAt])]
		oGDVA3402:aCols[oGDVA3402:nAt,Len(oGDVA3402:aCols[oGDVA3402:nAt])] := !oGDVA3402:aCols[oGDVA3402:nAt,Len(oGDVA3402:aCols[oGDVA3402:nAt])]
		oGDVA3402:oBrowse:Refresh()
		nPos := len(aCols2Tot)
		If ( nPosSeqP+nPosSeq2 ) > 0
			nPos := aScan(aCols2Tot, {|x| IIf(nPosSeqP>0,x[nPosSeqP],"")+IIf(nPosSeq2>0,x[nPosSeq2],"") == IIf(nPosSeqP>0,oGDVA3402:aCols[oGDVA3402:nAt,nPosSeqP],"")+IIf(nPosSeq2>0,oGDVA3402:aCols[oGDVA3402:nAt,nPosSeq2],"") }) // Verifica se ja existe registro no vetor aCols2Tot
		EndIf
		If nPos > 0
			aCols2Tot[nPos,len(aCols2Tot[nPos])] := oGDVA3402:aCols[oGDVA3402:nAt,Len(oGDVA3402:aCols[oGDVA3402:nAt])]
		EndIf
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340LOKบ Autor ณ Andre Luis Almeida  บ Data ณ 27/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Linha OK                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTp = 1 - aCols1                                           บฑฑ
ฑฑบ          ณ     = 2 - aCols2                                           บฑฑ
ฑฑบ          ณ cAliAux = Alias atual                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340LOK(nTp,cAliAux)
Local iii   := 0
Local lRet  := .t.
DbSelectArea(cAliAux)
If nTp == 1
	For iii := 1 to Len(oGDVA3401:aHeader)
		If X3Obrigat(oGDVA3401:aHeader[iii,2]) .and. Empty(&("M->"+oGDVA3401:aHeader[iii,2]))
			Help(" ",1,"OBRIGAT2",,RetTitle(oGDVA3401:aHeader[iii,2]),4,1 )
			lRet := .f.
			Exit
		EndIf
	Next
Else
	For iii := 1 to Len(oGDVA3402:aHeader)
		If X3Obrigat(oGDVA3402:aHeader[iii,2]) .and. Empty(&("M->"+oGDVA3402:aHeader[iii,2]))
			Help(" ",1,"OBRIGAT2",,RetTitle(oGDVA3402:aHeader[iii,2]),4,1 )
			lRet := .f.
			Exit
		EndIf
	Next
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340TOKบ Autor ณ Andre Luis Almeida  บ Data ณ 27/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Tudo OK                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTp = 1 - aCols1                                           บฑฑ
ฑฑบ          ณ     = 2 - aCols2                                           บฑฑ
ฑฑบ          ณ cAliAux = Alias atual                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340TOK(nTp,cAliAux)
Local lRet := .t.
lRet := AllwaysTrue()
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340OK บ Autor ณ Andre Luis Almeida  บ Data ณ 27/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ OK Tela                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ c1Ali = Alias 1                                            บฑฑ
ฑฑบ          ณ c2Ali = Alias 2                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340OK(c1Ali,c2Ali)
Local nii  := 0
Local njj  := 0
Local lRet := .t.
DbSelectArea(c1Ali)

//Ponto de Entrada para que o cliente possa fazer valida็ใo de INCLUSรO e ALTERAวยO em cada uma das telas.
If ( ExistBlock("VA340VLD") ) 
	ExecBlock("VA340VLD",.f.,.f.,{c1Ali})
EndIf

For njj := 1 to Len(oGDVA3401:aCols)
	If !oGDVA3401:aCols[njj,len(oGDVA3401:aCols[njj])]
		For nii := 1 to Len(oGDVA3401:aHeader)
			If X3Obrigat(oGDVA3401:aHeader[nii,2]) .and. Empty(oGDVA3401:aCols[njj,FG_POSVAR(oGDVA3401:aHeader[nii,2],"oGDVA3401:aHeader")])
				Help(" ",1,"OBRIGAT2",,c1Ali+" - "+RetTitle(oGDVA3401:aHeader[nii,2]),4,1 )
				lRet := .f.
				Exit
			EndIf
		Next
	EndIf
Next
If lRet .and. !Empty(c2Ali)
	DbSelectArea(c2Ali)
	For njj := 1 to Len(aCols2Tot)
		If !aCols2Tot[njj,len(aCols2Tot[njj])]
			For nii := 1 to Len(oGDVA3402:aHeader)
				If X3Obrigat(oGDVA3402:aHeader[nii,2]) .and. Empty(aCols2Tot[njj,FG_POSVAR(oGDVA3402:aHeader[nii,2],"oGDVA3402:aHeader")])
					Help(" ",1,"OBRIGAT2",,c2Ali+" - "+RetTitle(oGDVA3402:aHeader[nii,2]),4,1 )
					lRet := .f.
					Exit
				EndIf
			Next
		EndIf
	Next
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340GRVบ Autor ณ Andre Luis Almeida  บ Data ณ 27/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Gravar                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340GRV(c1Ali,c2Ali)
Local nii     := 0
Local njj     := 0
Local nPosCpo := 0
Local lAlter  := .f.
DbSelectArea(c1Ali)
DbSetOrder(1)
For nii := 1 to Len(oGDVA3401:aCols)
	If !dbSeek(xFilial(c1Ali)+SA1->A1_COD+IIf(nPosSeq1>0,"   ",""))
		dbSeek(xFilial(c1Ali)+SA1->A1_COD+IIf(nPosSeq1>0,oGDVA3401:aCols[nii,nPosSeq1],""))
	Endif
	If !oGDVA3401:aCols[nii,Len(oGDVA3401:aCols[nii])]
		lAlter := .f.
		If nPosLog1 > 0 .and. Found() // Verificar se teve alteracoes nos campos do registro
		    For njj := 1 to fCount()
		        nPosCpo := Fg_PosVar(FieldName(njj),"oGDVA3401:aHeader")
		        If nPosCpo > 0
			        If oGDVA3401:aCols[nii,nPosCpo]  <> &(c1Ali+"->"+FieldName(njj))
				       	lAlter := .t. // Alterado
				       	Exit
			        EndIf
				EndIf
		    Next
		EndIf
		RecLock(c1Ali,!Found())
		FG_GRAVAR(c1Ali,oGDVA3401:aCols,oGDVA3401:aHeader,nii)
		&(c1Ali+"->"+c1Ali+"_FILIAL") := xFilial(c1Ali)
		&(c1Ali+"->"+c1Ali+"_CODCLI") := SA1->A1_COD
		If nPosSeq1 > 0 .and. Empty(oGDVA3401:aCols[nii,nPosSeq1])
			&(c1Ali+"->"+c1Ali+"_CODSEQ") := VEIVA340SEQ(0,c1Ali,"")
		EndIf
		If lAlter .or. !Found()
			&(c1Ali+"->"+c1Ali+"_LOGALT") := left(UPPER(UsrRetName(__CUSERID)),15)+" - "+Transform(dDataBase,"@D")+" as "+left(Time(),5)+"h"
		Endif
		MsUnlock()
	Else
		If Found()
			RecLock(c1Ali,.f.,.t.)
			DbDelete()
			MsUnlock()
		EndIf
	EndIf
	WriteSx2(c1Ali)
Next
//
If !Empty(c2Ali)
	DbSelectArea(c2Ali)
	DbSetOrder(1)
	For nii := 1 to Len(aCols2Tot)
		dbSeek(xFilial(c2Ali)+SA1->A1_COD+IIf(nPosSeqP>0,aCols2Tot[nii,nPosSeqP],"")+IIf(nPosSeq2>0,aCols2Tot[nii,nPosSeq2],""))
		If !aCols2Tot[nii,Len(aCols2Tot[nii])]
			lAlter := .f.
			If nPosLog2 > 0 .and. Found() // Verificar se teve alteracoes nos campos do registro
			    For njj := 1 to fCount()
			        nPosCpo := Fg_PosVar(FieldName(njj),"oGDVA3402:aHeader")
			        If nPosCpo > 0
				        If aCols2Tot[nii,nPosCpo]  <> &(c2Ali+"->"+FieldName(njj))
					       	lAlter := .t. // Alterado
					       	Exit
				        EndIf
					EndIf
			    Next
		    EndIf
			RecLock(c2Ali,!Found())
			FG_GRAVAR(c2Ali,aCols2Tot,oGDVA3402:aHeader,nii)
			&(c2Ali+"->"+c2Ali+"_FILIAL") := xFilial(c2Ali)
			&(c2Ali+"->"+c2Ali+"_CODCLI") := SA1->A1_COD
			If nPosSeqP > 0
				&(c2Ali+"->"+c2Ali+"_PAISEQ") := aCols2Tot[nii,nPosSeqP]
			EndIf
			If nPosSeq2 > 0 .and. Empty(aCols2Tot[nii,nPosSeq2])
				&(c2Ali+"->"+c2Ali+"_CODSEQ") := VEIVA340SEQ(0,c2Ali,aCols2Tot[nii,nPosSeqP])
			EndIf
			If lAlter .or. !Found()
				&(c2Ali+"->"+c2Ali+"_LOGALT") := left(UPPER(UsrRetName(__CUSERID)),15)+" - "+Transform(dDataBase,"@D")+" as "+left(Time(),5)+"h"
			Endif
			MsUnlock()
		Else
			If Found()
				RecLock(c2Ali,.f.,.t.)
				DbDelete()
				MsUnlock()
			EndIf
		EndIf
		WriteSx2(c2Ali)
	Next
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340SEQบ Autor ณ Andre Luis Almeida  บ Data ณ 28/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Gerar sequencia do arquivo (   ???_CODSEQ   C   3   )      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340SEQ(nTp,cAliAux,cAux)
Local lOk     := .t.
Local nCntFor := 0
Local njj     := 0
Local cQuery  := ""
Local cCodSeq := ""
Default cAux  := ""
If nPosSeq1 > 0 .or. nPosSeq2 > 0
	cQuery := "SELECT MAX("+cAliAux+"."+cAliAux+"_CODSEQ) FROM "+RetSqlName(cAliAux)+" "+cAliAux+" "
	cQuery += "WHERE "+cAliAux+"."+cAliAux+"_FILIAL='"+xFilial(cAliAux)+"' AND "+cAliAux+"."+cAliAux+"_CODCLI='"+SA1->A1_COD+"'"
	If !Empty(cAux) .and. nPosSeqP > 0
		cQuery += " AND "+cAliAux+"."+cAliAux+"_PAISEQ='"+cAux+"'"
	EndIf
	cCodSeq := FM_SQL(cQuery) // Trazer o MAIOR numero de SEQUENCIA independetemente se o registro estiver DELETADO
	If nTp == 1 .and. Empty(oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1])
		For njj := 1 to Len(oGDVA3401:aCols)
			If oGDVA3401:nAt <> njj .and. !Empty(oGDVA3401:aCols[njj,nPosSeq1])
				If val(oGDVA3401:aCols[njj,nPosSeq1]) > val(cCodSeq)
					cCodSeq := oGDVA3401:aCols[njj,nPosSeq1]
				EndIf
			EndIf
		Next
	ElseIf nTp == 2 .and. Empty(oGDVA3402:aCols[oGDVA3402:nAt,nPosSeq2])
		For njj := 1 to Len(oGDVA3402:aCols)
			If oGDVA3402:nAt <> njj .and. !Empty(oGDVA3402:aCols[njj,nPosSeq2])
				If val(oGDVA3402:aCols[njj,nPosSeq2]) > val(cCodSeq)
					cCodSeq := oGDVA3402:aCols[njj,nPosSeq2]
				EndIf
			EndIf
		Next
	EndIf
	cCodSeq := strzero(val(cCodSeq)+1,3) // Soma 1
	If nTp == 1 .and. Empty(oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1])
		&("M->"+cAliAux+"_CODSEQ") := oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1] := cCodSeq // aCols1
	ElseIf nTp == 2 .and. Empty(oGDVA3402:aCols[oGDVA3402:nAt,nPosSeq2])
		&("M->"+cAliAux+"_CODSEQ") := oGDVA3402:aCols[oGDVA3402:nAt,nPosSeq2] := cCodSeq // aCols2
	EndIf
EndIf
If nPosSeqP > 0 .and. Empty(oGDVA3402:aCols[oGDVA3402:nAt,nPosSeqP])
	oGDVA3402:aCols[oGDVA3402:nAt,nPosSeqP] := oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1]
EndIf
If nTp == 2 .and. oGDVA3401:aCols[oGDVA3401:nAt,len(oGDVA3401:aCols[oGDVA3401:nAt])] // Se o PAI estiver DELETADO
	For nCntFor := 1 to len(aCols2Tot)
		lOk := .t.
		If nPosSeqP > 0
			If aCols2Tot[nCntFor,nPosSeqP] <> oGDVA3401:aCols[oGDVA3401:nAt,nPosSeqP]
				lOk := .f.
			EndIf
		EndIf
		If lOk .and. nPosSeq2 > 0
			If aCols2Tot[nCntFor,nPosSeq2] <> oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq2]
				lOk := .f.
			EndIf
		EndIf
		If lOk
			aCols2Tot[nCntFor,Len(aCols2Tot[nCntFor])] := .t.
		EndIf
	Next
	For nCntFor := 1 to len(oGDVA3402:aCols)
		oGDVA3402:aCols[nCntFor,Len(oGDVA3402:aCols[nCntFor])] := .t.
	Next
EndIf
If nTp == 1
	oGDVA3401:oBrowse:Refresh()
ElseIf nTp == 2
	oGDVA3402:oBrowse:Refresh()
EndIf
Return(cCodSeq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA340ACOบ Autor ณ Andre Luis Almeida  บ Data ณ 29/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Clonar / Zerar / Filtrar - aCols2Tot / aCols2Bco / aCols2  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA340ACO(nTp,c1Ali,c2Ali)
Local nCntFor := 0
Local lOk     := .t.
If nTp == 1 // Clonar aCols2 para aCols2Tot e Zerar aCols2Bco
	aCols2Tot := aClone(oGDVA3402:aCols)
	aCols2Bco := { Array(Len(oGDVA3402:aHeader)+1) }
	aCols2Bco[1,Len(oGDVA3402:aHeader)+1] := .F.
	For nCntFor:=1 to Len(oGDVA3402:aHeader)
		If IsHeadRec(oGDVA3402:aHeader[nCntFor,2])
			aCols2Bco[Len(aCols2Bco),nCntFor] := &(c2Ali+"->(Recno())")
		ElseIf IsHeadAlias(oGDVA3402:aHeader[nCntFor,2])
			aCols2Bco[Len(aCols2Bco),nCntFor] := c2Ali
		Else
			aCols2Bco[1,nCntFor] := CriaVar(oGDVA3402:aHeader[nCntFor,2])
		EndIf
	Next
ElseIf nTp == 2 // Filtrar aCols2 com registro posicionado no aCols1
	oGDVA3402:aCols := {}
	oGDVA3402:nAt := n := 1
	If nPosSeqP == 0
		oGDVA3402:aCols := aClone(aCols2Tot)
	Else
		For nCntFor := 1 to len(aCols2Tot)
			If aCols2Tot[nCntFor,nPosSeqP] == oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1]
				aAdd(oGDVA3402:aCols,aClone(aCols2Tot[nCntFor]))
			EndIf
		Next
	EndIf
	If len(oGDVA3402:aCols) == 0
		oGDVA3402:aCols := aClone(aCols2Bco)
		If nPosSeqP > 0 .and. nPosSeq1 > 0
			oGDVA3402:aCols[1,nPosSeqP] := oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1]
		EndIf
		If nPosSeq2 > 0
			oGDVA3402:aCols[1,nPosSeq2] := VEIVA340SEQ(0,c2Ali,oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq1])
		EndIf
	EndIf
	If oGDVA3401:aCols[oGDVA3401:nAt,len(oGDVA3401:aCols[oGDVA3401:nAt])] // Se o PAI estiver DELETADO
		For nCntFor := 1 to len(aCols2Tot)
			lOk := .t.
			If nPosSeqP > 0
				If aCols2Tot[nCntFor,nPosSeqP] <> oGDVA3401:aCols[oGDVA3401:nAt,nPosSeqP]
					lOk := .f.
				EndIf
			EndIf
			If lOk .and. nPosSeq2 > 0
				If aCols2Tot[nCntFor,nPosSeq2] <> oGDVA3401:aCols[oGDVA3401:nAt,nPosSeq2]
					lOk := .f.
				EndIf
			EndIf
			If lOk
				aCols2Tot[nCntFor,Len(aCols2Tot[nCntFor])] := .t.
			EndIf
		Next
		For nCntFor := 1 to len(oGDVA3402:aCols)
			oGDVA3402:aCols[nCntFor,Len(oGDVA3402:aCols[nCntFor])] := .t.
		Next
	EndIf
	oGDVA3402:oBrowse:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บ Autor ณ Andre Luis Almeida  บ Data ณ  25/05/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ MenuDef - Menu aRotina                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Return {{ STR0001 , "VEIVA340" , 0 , 2 }} // Base de Clientes
