// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 27     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "VEIXA007.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA007 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrada de Veiculos por Retorno de Consignacao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA007()
Local cFiltro     := ""
Private cCadastro := STR0001 // Entrada de Veiculos por Retorno de Consignacao
Private aRotina   := MenuDef()
Private aCores    := {;
					{'VVF->VVF_SITNFI == "1"','BR_VERDE'},;		// Valida
					{'VVF->VVF_SITNFI == "0"','BR_VERMELHO'},;	// Cancelada
					{'VVF->VVF_SITNFI == "2"','BR_PRETO'}}		// Devolvida
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVF")
dbSetOrder(1)
//
cFiltro := " VVF_OPEMOV='8' " // Filtra Retornos de Consignacao
//
mBrowse( 6, 1,22,75,"VVF",,,,,,aCores,,,,,,,,cFiltro)
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA007   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Entrada de Veiculos por Retorno de Consignacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007(cAlias,nReg,nOpc)
//
DBSelectArea("VVF")
If nOpc == 3 // INCLUSAO
	VXA007BRWVV0()
Else // VISUALIZACAO E CANCELAMENTO
	VEIXX000(,,,nOpc,"8")	// VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov)
EndIf
//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA007BRWVV0³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Retorno de Consignacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007BRWVV0()
Local aRotinaX := aClone(aRotina)     
Local aOpcoes  := {}
Private cBrwCond2 := 'VV0->VV0_OPEMOV=="5" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. xFilial("VV0")==VV0->VV0_FILIAL .AND. VXA007FIL()' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//
aAdd(aOpcoes,{STR0012,"VXA007DEV('"+cFilAnt+"')"}) // Retornar
//
dbSelectArea("VV0")
dbSetOrder(4)
//
cFilTop := "VV0_OPEMOV='5' AND VV0_SITNFI='1' AND VV0_NUMNFI <> ' ' AND '"+xFilial("VV0")+"'=VV0_FILIAL AND "
cFilTop += "EXISTS ( "
cFilTop +=     " SELECT VVA.VVA_NUMTRA "
cFilTop +=       " FROM "+RetSQLName("VVA")+" VVA "
cFilTop +=              " INNER JOIN "+RetSQLName("VV1")+" VV1 "
cFilTop +=                 " ON VV1.VV1_FILIAL  = '"+xFilial("VV1")+"' "
cFilTop +=                " AND VV1.VV1_CHASSI = VVA.VVA_CHASSI "
cFilTop +=                " AND VV1.VV1_ULTMOV = 'S' "
cFilTop +=                " AND VV1.VV1_FILSAI = '"+xFilial("VVA")+"' "
cFilTop +=                " AND VV1.VV1_NUMTRA = VVA.VVA_NUMTRA "
cFilTop +=                " AND VV1.D_E_L_E_T_ = ' ' "
cFilTop +=      " WHERE VVA.VVA_FILIAL = '"+xFilial("VVA")+"' "
cFilTop +=        " AND VVA.VVA_NUMTRA = VV0_NUMTRA "
cFilTop +=        " AND VVA.D_E_L_E_T_ = ' ' ) "

FGX_LBBROW(cCadastro,"VV0",aOpcoes,cFilTop,"VV0_FILIAL,VV0_NUMNFI,VV0_SERNFI","VV0_DATMOV")
aRotina := aClone(aRotinaX)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA007FIL ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o filtro do browse das SAIDAS de veiculo por remessa           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007FIL()
Local lRet := .f.
//
VVA->(DbSetOrder(1))
VVA->(DBSeek(xFilial("VVA")+VV0->VV0_NUMTRA))
While VVA->(!eof()) .and. VVA->VVA_FILIAL+VVA->VVA_NUMTRA == xFilial("VVA")+VV0->VV0_NUMTRA
	VV1->(DbSetOrder(2))
	VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
	// Verifica se a ultima movimentacao do veiculo foi o VV0 em questao ( SAIDA por Transferencia )
	If VV1->VV1_ULTMOV == "S" .and. VV1->VV1_FILSAI == xFilial("VV0") .and. VV1->VV1_NUMTRA == VV0->VV0_NUMTRA
		lRet := .t.
		Exit
	EndIf
	VVA->(DbSkip())
Enddo
//
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA007DEV | Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a devolucao da nota fiscal selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007DEV(c_xFil)
Local xAutoCab := {}
Local xAutoItens := {}
Local xAutoAux := {}
Local nRecVV0 := VV0->(RecNo())
Local cGruVei  := Left(GetMv("MV_GRUVEI")+space(TamSx3("B1_GRUPO")[1]),TamSx3("B1_GRUPO")[1]) // Grupo do Veiculo
// Declaracao da ParamBox
Local aRet := {}
Local aParamBox := {}
Local i := 0 
Local nQtdDev := 0
Local nPosVet := 0
Local lContabil := ( VVG->(FieldPos("VVG_CENCUS")) > 0 .and. VVG->(FieldPos("VVG_CONTA")) > 0 .and. VVG->(FieldPos("VVG_ITEMCT")) > 0 .and. VVG->(FieldPos("VVG_CLVL")) > 0 ) // Campos para a contabilizacao - VVG
//
Local lVVF_DEVMER := ( VVF->(FieldPos("VVF_DEVMER")) > 0 )
Local lVVF_MENPAD := ( VVF->(FieldPos("VVF_MENPAD")) > 0 )
Local lVVF_MENNOT := ( VVF->(FieldPos("VVF_MENNOT")) > 0 )
Local lVVF_VEICU1 := ( VVF->(FieldPos("VVF_VEICU1")) > 0 )
Local lVVF_VEICU2 := ( VVF->(FieldPos("VVF_VEICU2")) > 0 )
Local lVVF_VEICU3 := ( VVF->(FieldPos("VVF_VEICU3")) > 0 )
Local lVVF_TPFRET := ( VVF->(ColumnPos("VVF_TPFRET")) > 0 )
//
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()
//
Default c_xFil := cFilAnt
cFilAnt := c_xFil
//
If &cBrwCond2 // Condicao do Browse 2, validar ao Devolver
	//
	If VV0->VV0_CLIFOR == "C" // Cliente
		If oCliente:Bloqueado( VV0->VV0_CODCLI , VV0->VV0_LOJA , .T. ) // Cliente Bloqueado ?
			Return .f.
		EndIf
	Else // Fornecedor
		If oFornece:Bloqueado( VV0->VV0_CODCLI , VV0->VV0_LOJA , .T. ) // Fornecedor Bloqueado ?
			Return .f.
		EndIf
	EndIf
	//
	aAdd(aParamBox,{2,STR0020,STR0021,{STR0022,STR0021},80,"",.T.})
	aAdd(aParamBox,{1,STR0013,space(TamSX3("VV0_NUMNFI")[1]),"","","","MV_PAR01='"+STR0021+"'",40,.F.}) // Nota Fiscal
	aAdd(aParamBox,{1,STR0014,space(FGX_MILSNF("VVF", 6, "VV0_SERNFI")),"","","","MV_PAR01='"+STR0021+"'",20,.F.}) // Serie
	aAdd(aParamBox,{1,STR0026,ddatabase,"@D","","","MV_PAR01='"+STR0021+"'",50,.T.})
	aAdd(aParamBox,{1,STR0027,Space(TamSX3("VVF_NATURE")[1]),"","VXA007VNAT()","SED","",60,.F.}) // Natureza
	aAdd(aParamBox,{1,RetTitle("VVF_ESPECI"),space(TamSX3("VVF_ESPECI")[1]),VVF->(X3Picture("VVF_ESPECI")),"Vazio() .or. ExistCpo('SX5','42'+MV_Par06)","42","",20,X3Obrigat("VVF_ESPECI")}) // Especie da NF
	aAdd(aParamBox,{1,STR0038,space(TamSX3("VVF_CHVNFE")[1]),VVF->(X3Picture("VVF_CHVNFE")),"VXVlChvNfe('0',Mv_Par06)","","MV_PAR01='"+STR0021+"'",120,.F.}) // Chave da NFE
	aAdd(aParamBox,{1,RetTitle("VVF_TRANSP"),Space(TAMSX3("VVF_TRANSP")[1]),/*X3Picture("VVF_TRANSP")*/,,"SA4"	,"",30,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VVF_PLIQUI"),0,X3Picture("VVF_PLIQUI"),,""		,"",50,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VVF_PBRUTO"),0,X3Picture("VVF_PBRUTO"),,""		,"",50,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VVF_VOLUM1"),0,X3Picture("VVF_VOLUM1"),,""		,"",30,.f.})
	aAdd(aParamBox,{1,RetTitle("VVF_ESPEC1"),space(TamSX3("VVF_ESPEC1")[1]),VVF->(X3Picture("VVF_ESPEC1")),"","","",50,.f.}) // Especie 1

	nPosVet := 13

	if lVVF_DEVMER
		aAdd(aParamBox,{2,RetTitle("VVF_DEVMER"),"",{"","S="+STR0022,"N="+STR0021},40,"",.f.}) // N=Nao / S=Sim
		nPosVet++
	EndIf

	// Veículo Transportador (Integração MATA103 - CI 008022)
	If lVVF_VEICU1
		aAdd(aParamBox, {1, RetTitle("VVF_VEICU1"), space(TamSX3("VVF_VEICU1")[1]), VVF->(X3Picture("VVF_VEICU1")), "", "DA3", "", 8, .f.}) // Veículo 1
		nPosVet++
	EndIf

	If lVVF_VEICU2
		aAdd(aParamBox, {1, RetTitle("VVF_VEICU2"), space(TamSX3("VVF_VEICU2")[1]), VVF->(X3Picture("VVF_VEICU2")), "", "DA3", "", 8, .f.}) // Veículo 2
		nPosVet++
	EndIf

	If lVVF_VEICU3
		aAdd(aParamBox, {1, RetTitle("VVF_VEICU3"), space(TamSX3("VVF_VEICU3")[1]), VVF->(X3Picture("VVF_VEICU3")), "", "DA3", "", 8, .f.}) // Veículo 3
		nPosVet++
	EndIf

	aAdd(aParamBox,{11,RetTitle("VVF_OBSENF"),space(200),"","",.f.}) // MV_PAR13 ou MV_PAR17
	if lVVF_MENPAD
		aAdd(aParamBox,{1,RetTitle("VVF_MENPAD"),space(TamSX3("VVF_MENPAD")[1]),VVF->(X3Picture("VVF_MENPAD")),"texto().Or.Vazio()","SM4","MV_PAR01='"+STR0022+"'",30,.f.}) // Mensagem padrao
	Endif
	if lVVF_MENNOT
		aAdd(aParamBox,{1,RetTitle("VVF_MENNOT"),space(TamSX3("VVF_MENNOT")[1]),VVF->(X3Picture("VVF_MENNOT")),"","","MV_PAR01='"+STR0022+"'",200,.f.}) // Mensagem NF
	Endif
	if lVVF_TPFRET
		aCBOX_TPFret := X3CBOXAVET("VVF_TPFRET","1")
		aAdd(aParamBox,{2,RetTitle("VVF_TPFRET")," ",aCBOX_TPFret,100,"",.f.}) // Tipo de Frete
	EndIf
	//
	lPassou := .f.
	while !lPassou
		lPassou := .t.
		//
		aRet := FGX_SELVEI("VV0",STR0017,VV0->VV0_FILIAL,VV0->VV0_NUMTRA,aParamBox,"VXA007VTES")
        //
		If Len(aRet) == 0 //!(ParamBox(aParamBox,STR0017,@aRet))//Dados do Retorno de Remessa
			Return .f.
		Endif
		if aRet[1,1] == STR0021 .and. Empty(aRet[1,2])
			MsgInfo(STR0023,STR0024)
			lPassou := .f.
		endif
	Enddo
	//
	aRet[1,nPosVet] := &("MV_PAR"+strzero(nPosVet,2)) // Prencher MEMO no Vetor de Retorno da Parambox
    //
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array de integracao com o VEIXX000                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")	,Nil})
	aAdd(xAutoCab,{"VVF_CLIFOR"  ,VV0->VV0_CLIFOR   ,Nil})        
	if aRet[1,1] == STR0021 // Nao
		aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"   		,Nil})
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,aRet[1,2]		,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,aRet[1,3]		,Nil})
		aAdd(xAutoCab,{"VVF_CHVNFE"  ,aRet[1,7]		,Nil})
	else
		aAdd(xAutoCab,{"VVF_FORPRO"  ,"1"   		,Nil})
	endif
	aAdd(xAutoCab,{"VVF_CODFOR"  ,VV0->VV0_CODCLI	,Nil})
	aAdd(xAutoCab,{"VVF_DATEMI"  ,aRet[1,4]			,Nil})
	aAdd(xAutoCab,{"VVF_NATURE"  ,aRet[1,5]			,Nil})
	aAdd(xAutoCab,{"VVF_LOJA"    ,VV0->VV0_LOJA		,Nil})
	aAdd(xAutoCab,{"VVF_FORPAG"  ,VV0->VV0_FORPAG	,Nil})
	aAdd(xAutoCab,{"VVF_ESPECI"  ,aRet[1,6]			,Nil})
	aAdd(xAutoCab,{"VVF_TRANSP"  ,aRet[1,8]			,Nil})
	aAdd(xAutoCab,{"VVF_PLIQUI"  ,aRet[1,9]			,Nil})
	aAdd(xAutoCab,{"VVF_PBRUTO"  ,aRet[1,10]		,Nil})
	aAdd(xAutoCab,{"VVF_VOLUM1"  ,aRet[1,11]		,Nil})
	aAdd(xAutoCab,{"VVF_ESPEC1"  ,aRet[1,12]		,Nil})
	nPosVet := 13
	If lVVF_DEVMER
		if aRet[1,1] == STR0022 // Formulario proprio = Sim
			If !Empty(aRet[1,nPosVet])
				aAdd(xAutoCab,{"VVF_DEVMER" ,aRet[1,nPosVet],Nil})
			EndIf
		EndIf
		nPosVet++
	EndIf

	// Veículo Transportador (Integração MATA103 - CI 008022)
	If lVVF_VEICU1
		aAdd(xAutoCab,{"VVF_VEICU1" ,aRet[1,nPosVet++],Nil})
	EndIf

	If lVVF_VEICU2
		aAdd(xAutoCab,{"VVF_VEICU2" ,aRet[1,nPosVet++],Nil})
	EndIf

	If lVVF_VEICU3
		aAdd(xAutoCab,{"VVF_VEICU3" ,aRet[1,nPosVet++],Nil})
	EndIf

	aAdd(xAutoCab,{"VVF_OBSENF"  ,aRet[1,nPosVet++]	,Nil})
	if aRet[1,1] == STR0022 // Formulario proprio = Sim
		if lVVF_MENPAD
			aAdd(xAutoCab,{"VVF_MENPAD"  ,aRet[1,nPosVet++]	,Nil})
		Endif
		if lVVF_MENNOT
			aAdd(xAutoCab,{"VVF_MENNOT"  ,aRet[1,nPosVet++]	,Nil})
		EndIf
	else
		if lVVF_MENPAD
			++nPosVet
		Endif
		if lVVF_MENNOT
			++nPosVet
		EndIf
	EndIf
	If lVVF_TPFRET
		cVVF_TPFRET := aRet[1,nPosVet++]
		If ! empty(cVVF_TPFRET)
			aAdd(xAutoCab,{"VVF_TPFRET" ,cVVF_TPFRET,Nil})
		EndIf
	EndIf
//
	DBSelectArea("VVA")
	DBSetOrder(1)
	For i := 1 to Len(aRet[2])
		If aRet[2,i,1] // Veículo está selecionado
			nQtdDev++
			DBSelectArea("VVA")
			DbGoto(aRet[2,i,2])
			DBSelectArea("SF4")
			DBSetOrder(1)
			DBSeek(xFilial("SF4")+aRet[2,i,3])

			If ! FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )
				FMX_HELP("VA007E01", STR0039) // "Veículo não encontrado"
				Return .f.
			endif
			xAutoIt := {}
			aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")					,Nil})
			aAdd(xAutoIt,{"VVG_CHASSI"  ,VVA->VVA_CHASSI 				,Nil})
			aAdd(xAutoIt,{"VVG_CODTES"  ,aRet[2,i,3]					,Nil})
			aAdd(xAutoIt,{"VVG_LOCPAD"  ,VV1->VV1_LOCPAD				,Nil})
			aAdd(xAutoIt,{"VVG_SITTRI"  ,SB1->B1_ORIGEM+SF4->F4_SITTRIB	,Nil}) 
			aAdd(xAutoIt,{"VVG_VALUNI"  ,VVA->VVA_VALMOV				,Nil})
			aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"							,Nil})
			if lContabil     
				if Len(aRet[2,i]) > 7
					aAdd(xAutoIt,{"VVG_CENCUS"  ,aRet[2,i,8],Nil})
					aAdd(xAutoIt,{"VVG_CONTA"   ,aRet[2,i,9],Nil})
					aAdd(xAutoIt,{"VVG_ITEMCT"  ,aRet[2,i,10],Nil})
					aAdd(xAutoIt,{"VVG_CLVL"    ,aRet[2,i,11],Nil})
				Endif
			Endif	
			//
			aAdd(xAutoItens,xAutoIt)
			// MONTA ARRAY AUXILIAR COM INFORMACOES DE CONTROLE DE RETORNO (ITEMSEQ, IDENTB6, ETC)
			xAutoIt := {}
			DBSelectArea("SD2")
			DBSetOrder(3)
			if !DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
				MsgInfo(STR0040,STR0019+": VA007E02")
				Return .f.
			endif
			//
			aAdd(xAutoIt,{"D1_NFORI"   ,SD2->D2_DOC     ,Nil})
			aAdd(xAutoIt,{"D1_SERIORI" ,SD2->D2_SERIE   ,Nil})
			aAdd(xAutoIt,{"D1_ITEMORI" ,SD2->D2_ITEM    ,Nil})
			aAdd(xAutoIt,{"D1_IDENTB6" ,SD2->D2_IDENTB6 ,Nil})
			//
			aAdd(xAutoAux,xAutoIt)
			//
		   DBSelectArea("SB6")
			DBSetOrder(3) 
			if DBSeek(xFilial("SB6")+SD2->D2_IDENTB6+SD2->D2_COD)
				xAutoCab[2,2] := SB6->B6_TPCF
			Endif
			//
		Endif
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a integracao com o VEIXX000                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	lMsErroAuto := .f.
	//
	MSExecAuto({|x,y,w,z,k,l| VEIXX000(x,y,w,z,k,l)},xAutoCab,xAutoItens,{},3,"8",xAutoAux )
	//
	If !(nQtdDev == Len(aRet[2])) // A Devolucao foi Parcial
		DBSelectArea("VV0")
		DBGoTo(nRecVV0)
		reclock("VV0",.f.)
		VV0->VV0_SITNFI := "1"
		msunlock()
	Endif
	//
	if lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .f.
	Endif
	//
EndIf
//
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA007VTES³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao no campo TES										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007VTES(cCodTes)
Local cFilBkp := cFilAnt
if !Empty(cCodTes)
	DBSelectArea("SF4")
	DBSetOrder(1)
	if !DBSeek(xFilial("SF4")+cCodTes) // TES DE ENTRADA POR RETORNO DE CONSIGNACAO
		MsgStop(STR0028,STR0024)
		Return(.f.)
	Endif
	If FMX_TESTIP(cCodTes) <> "E" // TES não é de ENTRADA
		MsgStop(STR0029,STR0024)
		Return(.f.)
	Endif
Endif
cPoder3 := SF4->F4_PODER3
cEstoque := SF4->F4_ESTOQUE
DBSelectArea("VVA")
DBSetOrder(1)
DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
//
cFilAnt := VV0->VV0_FILIAL // Mudar cFilAnt pq o Cadastro de TES pode ser EXCLUSIVO
DBSelectArea("SF4")
DBSetOrder(1)
DBSeek(xFilial("SF4")+VVA->VVA_CODTES) // TES DE SAIDA POR CONSIGNACAO - NF Origem
cFilAnt := cFilBkp
//
if SF4->F4_PODER3=="S"
	cMsg := STR0030
else
	cMsg := STR0031
endif
//
if SF4->F4_ESTOQUE=="S"
	cMsg += STR0032
else
	cMsg += STR0033
endif
//
if cPoder3 != SF4->F4_PODER3 .and. cEstoque != SF4->F4_ESTOQUE
	MsgInfo(STR0034 + cMsg + STR0035,STR0024)
	return .f.
endif
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA007VSIT³ Autor ³Thiago						        ³ Data ³ 13/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao no campo situacao tributaria						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007VSIT()


if !Empty(MV_PAR06)
	DBSelectArea("SX5")
	DBSetOrder(1)
	if !DBSeek(xFilial("SX5")+"S0"+MV_PAR06)
		MsgStop(STR0036,STR0024)
		Return(.f.)
	Endif
Endif
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA007VNAT³ Autor ³Thiago						        ³ Data ³ 13/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao no campo natureza									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007VNAT()


if !Empty(MV_PAR05)
	DBSelectArea("SED")
	DBSetOrder(1)
	if !DBSeek(xFilial("SED")+MV_PAR05)
		MsgStop(STR0037,STR0024)
		Return(.f.)
	Endif
Endif
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Entrada de Veiculos por Retorno de Consignacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {;
{ OemtoAnsi(STR0002) ,"AxPesqui" , 0 , 1},;			// Pesquisar
{ OemtoAnsi(STR0003) ,"VXA007"     		, 0 , 2},;		// Visualizar
{ OemtoAnsi(STR0004) ,"VXA007"    		, 0 , 3,,.f.},;		// Devolver
{ OemtoAnsi(STR0005) ,"VXA007"    	 	, 0 , 5,,.f.},;		// Cancelar
{ OemtoAnsi(STR0006) ,"VXA007LEG" 	 	, 0 , 6},;		// Legenda
{ OemtoAnsi(STR0007) ,"FGX_PESQBRW('E','8')" , 0 , 2}}	// Pesquisa Avancada ( E-Entrada por 8-Retorno de Consignacao )
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA007LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Retorno de Consignacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007LEG()
Local aLegenda := {;
{'BR_VERDE',STR0008},;
{'BR_VERMELHO',STR0009}}
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return
