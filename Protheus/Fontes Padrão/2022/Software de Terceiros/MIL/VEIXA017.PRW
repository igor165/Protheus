// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 22     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "VEIXA017.CH"
#include "PROTHEUS.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA017 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Saida de Veiculos por Retorno de Consignacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA017()
Local cFiltro     := ""
Private cCadastro := STR0001 // Saida de Veiculos por Retorno de Consignacao
Private aRotina   := MenuDef()
Private aCores    := {}
If ( VV0->(FieldPos("VV0_GERFIN")) > 0 ) // Campo que controla se gerou FINANCEIRO (Titulos)
	aAdd(aCores,{'VV0->VV0_SITNFI == "1" .AND. VV0->VV0_GERFIN <> "0"','BR_VERDE'})	// Valida
	aAdd(aCores,{'VV0->VV0_SITNFI == "1" .AND. VV0->VV0_GERFIN == "0"','f14_verd'}) // Valida com inconsistência no Financeiro
Else
	aAdd(aCores,{'VV0->VV0_SITNFI == "1"','BR_VERDE'})	// Valida
EndIf
aAdd(aCores,{'VV0->VV0_SITNFI == "0"','BR_VERMELHO'})	// Cancelada
aAdd(aCores,{'VV0->VV0_SITNFI == "2"','BR_PRETO'})		// Devolvida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
dbSetOrder(1)
//
cFiltro := " VV0_OPEMOV='7' " // Filtra os Retornos de Consignacao
//
mBrowse( 6, 1,22,75,"VV0",,,,,,aCores,,,,,,,,cFiltro)
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA017_2 ³ Autor ³ Thiago							³ Data ³ 13/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizar															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017_2(cAlias,nReg,nOpc)
nOpc := 2
VXA017(cAlias,nReg,nOpc)
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA017_3 ³ Autor ³ Thiago							³ Data ³ 13/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusao 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017_3(cAlias,nReg,nOpc)
nOpc := 3
VXA017(cAlias,nReg,nOpc)
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA017_4 ³ Autor ³ Thiago							³ Data ³ 13/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelar 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017_5(cAlias,nReg,nOpc)
nOpc := 5
VXA017(cAlias,nReg,nOpc)
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA017   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Saida de Veiculos por Retorno de Consignacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017(cAlias,nReg,nOpc)
//
DBSelectArea("VV0")
If nOpc == 3 // INCLUSAO
	VXA017BRWVVF()
Else // VISUALIZACAO E CANCELAMENTO
	VEIXX001(,,,nOpc,"7")	// VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov)
EndIf
//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA017BRWVVF³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Saida de Veiculos por Retorno de Consignacao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017BRWVVF()
Local aRotinaX := aClone(aRotina)
Local aOpcoes  := {}
Private cBrwCond2 := 'VVF->VVF_OPEMOV=="4" .AND. VVF->VVF_SITNFI=="1" .AND. !Empty(VVF->VVF_NUMNFI) .AND. xFilial("VVF")==VVF->VVF_FILIAL .AND. VXA017FIL()' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//
aAdd(aOpcoes,{STR0012,"VXA017DEV('"+cFilAnt+"')"}) // Retornar
//
dbSelectArea("VVF")
dbSetOrder(4)
//
cFilTop := "VVF_OPEMOV='4' AND VVF_SITNFI='1' AND VVF_NUMNFI <> ' ' AND '"+xFilial("VVF")+"' = VVF_FILIAL AND "
cFilTop += "EXISTS ( "
cFilTop += " SELECT VVG.VVG_TRACPA "
cFilTop +=   " FROM "+RetSQLName("VVG")+" VVG "
cFilTop +=          " INNER JOIN "+RetSQLName("VV1")+" VV1 ON "
cFilTop +=            " VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND "
cFilTop +=            " VV1.VV1_CHASSI = VVG.VVG_CHASSI AND "
cFilTop +=            " VV1.VV1_ULTMOV = 'E' AND "
cFilTop +=            " VV1.VV1_FILENT = VVG.VVG_FILIAL AND "
cFilTop +=            " VV1.D_E_L_E_T_ = ' ' "
cFilTop += " WHERE VVG.VVG_FILIAL = '"+xFilial("VVG")+"' "
cFilTop +=   " AND VVG.VVG_TRACPA = VVF_TRACPA "
cFilTop +=   " AND VVG.D_E_L_E_T_ = ' ' )"

FGX_LBBROW(cCadastro,"VVF",aOpcoes,cFilTop,"VVF_FILIAL,VVF_CODFOR,VVF_LOJA,VVF_NUMNFI,VVF_SERNFI","VVF_DATMOV")

aRotina := aClone(aRotinaX)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA017FIL ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o filtro do browse das ENTRADAS de veiculo por Consignacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017FIL()
Local lRet := .f.
Local cBkpFilAnt := cFilAnt
cFilAnt := VVG->VVG_FILIAL
//
VV1->(DbSetOrder(2))
VVG->(DbSetOrder(1))
VVG->(DBSeek(VVF->VVF_FILIAL+VVF->VVF_TRACPA))
While VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
	VV1->(DBSeek(xFilial("VV1")+VVG->VVG_CHASSI))
	// Verifica se a ultima movimentacao do veiculo foi o VVF em questao
	If VV1->VV1_ULTMOV == "E" .and. VV1->VV1_FILENT == VVF->VVF_FILIAL // .and. VV1->VV1_TRACPA == VVF->VVF_TRACPA <-- Luis: Precisei remover essa validação CI 1117
		lRet := .t.
		exit
	EndIf
	VVG->(DbSkip())
Enddo
cFilAnt := cBkpFilAnt
//
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA017DEV | Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a devolucao da nota fiscal selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017DEV(c_xFil)
Local xAutoCab := {}
Local xAutoItens := {}
Local xAutoAux := {}
Local nRecVVF := VVF->(RecNo())
Local nQtdDev := 0
Local cGruVei  := Left(GetMv("MV_GRUVEI")+space(TamSx3("B1_GRUPO")[1]),TamSx3("B1_GRUPO")[1]) // Grupo do Veiculo
// Declaracao da ParamBox
Local aRet := {}
Local aParamBox := {}
Local i := 0
Local lContabil := ( VVA->(FieldPos("VVA_CENCUS")) > 0 .and. VVA->(FieldPos("VVA_CONTA")) > 0 .and. VVA->(FieldPos("VVA_ITEMCT")) > 0 .and. VVA->(FieldPos("VVA_CLVL")) > 0 ) // Campos para a contabilizacao - VVA
//
Local aIndPre  := X3CBOXAVET("VV0_INDPRE","0")
Local aTipoFre := X3CBOXAVET("VV0_TPFRET","1")
//
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()
//
Default c_xFil := cFilAnt
cFilAnt := c_xFil
//

If &cBrwCond2 // Condicao do Browse 2, validar ao Devolver
	//
	If VVF->VVF_CLIFOR == "F" // Fornecedor
		If oFornece:Bloqueado( VVF->VVF_CODFOR , VVF->VVF_LOJA , .T. ) // Fornecedor Bloqueado ?
			Return .f.
		EndIf
	Else // Cliente
		If oCliente:Bloqueado( VVF->VVF_CODFOR , VVF->VVF_LOJA , .T. ) // Cliente Bloqueado ?
			Return .f.
		EndIf
	EndIf
	//
	aAdd(aParamBox,{1,STR0014,Space(TamSX3("A3_COD")[1]),"","","SA3","",30,.T.})//Vendedor
	aAdd(aParamBox,{2,RetTitle("VV0_INDPRE"),,aIndPre,80,"",.f.})
	aAdd(aParamBox,{1,RetTitle("VV0_PESOL" ),0,X3Picture("VV0_PESOL" ),,""		,"",50,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VV0_PBRUTO"),0,X3Picture("VV0_PBRUTO"),,""		,"",50,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VV0_VOLUME"),0,X3Picture("VV0_VOLUME"),,""		,"",30,.f.})
	aAdd(aParamBox,{1,RetTitle("VV0_ESPECI"),Space(TAMSX3("VV0_ESPECI")[1]),/*X3Picture("VV0_ESPECI")*/,,""		,"",40,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VV0_VEICUL"),Space(TAMSX3("VV0_VEICUL")[1]),/*X3Picture("VV0_VEICUL")*/,,"DA3"	,"",40,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VV0_SEGURO"),0,X3Picture("VV0_SEGURO"),,""		,"",60,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VV0_CODTRA"),Space(TAMSX3("VV0_CODTRA")[1]),/*X3Picture("VV0_CODTRA")*/,,"SA4"	,"",30,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VV0_DESACE"),0,X3Picture("VV0_DESACE"),,""		,"",60,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VV0_VALFRE"),0,X3Picture("VV0_VALFRE"),,""		,"",60,.f.}) 
	aAdd(aParamBox,{2,RetTitle("VV0_TPFRET"),,aTipoFre,40,"",.f.})
	aAdd(aParamBox,{11,RetTitle("VV0_OBSENF"),space(200),"","",.f.}) // MV_PAR13
	//
	aRet := FGX_SELVEI("VVF",STR0015,VVF->VVF_FILIAL,VVF->VVF_TRACPA,aParamBox,"VXA017VTES")
	//
	If Len(aRet) == 0 
		Return .f.
	Endif
	//
	aRet[1,13] := MV_PAR13 // Prencher MEMO no Vetor de Retorno da Parambox
    //
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array de integracao com o VEIXX000                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(xAutoCab,{"VV0_FILIAL"  ,xFilial("VV0")		,Nil})
	aAdd(xAutoCab,{"VV0_CLIFOR"  ,VVF->VVF_CLIFOR		,Nil})
	aAdd(xAutoCab,{"VV0_FORPRO"  ,"1"   		 		,Nil})
	aAdd(xAutoCab,{"VV0_CODCLI"  ,VVF->VVF_CODFOR		,Nil})
	aAdd(xAutoCab,{"VV0_LOJA"    ,VVF->VVF_LOJA			,Nil})
	aAdd(xAutoCab,{"VV0_FORPAG"  ,VVF->VVF_FORPAG		,Nil})
	aAdd(xAutoCab,{"VV0_CODVEN"  ,aRet[1,1]				,Nil})
	aAdd(xAutoCab,{"VV0_OBSENF"  ,aRet[1,13]			,Nil})
	aAdd(xAutoCab,{"VV0_INDPRE"  ,aRet[1,2]				,Nil})
	If VV0->(FieldPos("VV0_PESOL")) > 0
		aAdd(xAutoCab,{"VV0_PESOL"   ,aRet[1,3]			,Nil})
	EndIf
	If VV0->(FieldPos("VV0_PBRUTO")) > 0
		aAdd(xAutoCab,{"VV0_PBRUTO"  ,aRet[1,4]			,Nil})
	EndIf
	If VV0->(FieldPos("VV0_VOLUME")) > 0
		aAdd(xAutoCab,{"VV0_VOLUME"  ,aRet[1,5]			,Nil})
	EndIf
	If VV0->(FieldPos("VV0_ESPECI")) > 0
		aAdd(xAutoCab,{"VV0_ESPECI"  ,aRet[1,6]			,Nil})
	EndIf
	If VV0->(FieldPos("VV0_VEICUL")) > 0
		aAdd(xAutoCab,{"VV0_VEICUL"  ,aRet[1,7]			,Nil})
	EndIf
	If VV0->(FieldPos("VV0_SEGURO")) > 0
		aAdd(xAutoCab,{"VV0_SEGURO"  ,aRet[1,8]			,Nil})
	EndIf
	aAdd(xAutoCab,{"VV0_CODTRA"  ,aRet[1,9]				,Nil})
	aAdd(xAutoCab,{"VV0_DESACE"  ,aRet[1,10]			,Nil})
	aAdd(xAutoCab,{"VV0_VALFRE"  ,aRet[1,11]			,Nil})
	aAdd(xAutoCab,{"VV0_TPFRET"  ,aRet[1,12]			,Nil})
	aAdd(xAutoCab,{"VV0_NATFIN"  ,VVF->VVF_NATURE		,Nil})
	//
	DBSelectArea("VVG")
	DBSetOrder(1)
	//
	For i := 1 to Len(aRet[2])
		If aRet[2,i,1] // Veículo está selecionado
			nQtdDev++
			DBSelectArea("VVG")
			DbGoto(aRet[2,i,2])
			DBSelectArea("VV1")
			DBSetOrder(2)
			DBSeek(xFilial("VV1")+VVG->VVG_CHASSI)
			xAutoIt := {}
			aAdd(xAutoIt,{"VVA_FILIAL"  ,xFilial("VVA")	,Nil})
			aAdd(xAutoIt,{"VVA_CHASSI"  ,VVG->VVG_CHASSI,Nil})
			aAdd(xAutoIt,{"VVA_CODTES"  ,aRet[2,i,3]	,Nil})
			aAdd(xAutoIt,{"VVA_VALMOV"  ,VVG->VVG_VALUNI,Nil})
			if lContabil
				if Len(aRet[2,i]) > 7
					aAdd(xAutoIt,{"VVA_CENCUS"  ,aRet[2,i,8],Nil})
					aAdd(xAutoIt,{"VVA_CONTA"   ,aRet[2,i,9],Nil})
					aAdd(xAutoIt,{"VVA_ITEMCT"  ,aRet[2,i,10],Nil})
					aAdd(xAutoIt,{"VVA_CLVL"    ,aRet[2,i,11],Nil})
				Endif	
			Endif

			//
			aAdd(xAutoItens,xAutoIt)
			// MONTA ARRAY AUXILIAR COM INFORMACOES DE CONTROLE DE RETORNO (ITEMSEQ, IDENTB6, ETC)
			xAutoIt := {}
			If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
				FMX_HELP("VA017E01", STR0027 ) // "Veículo não encontrado"
				Return .f.
			endif
			DBSelectArea("SD1")
			DBSetOrder(1)
			if !DBSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
				MsgInfo(STR0028,STR0017+": VA017E02") // Item da nota de entrada não encontrado
				Return .f.
			endif
			//
			aAdd(xAutoIt,{"C6_NFORI"   ,SD1->D1_DOC,Nil})
			aAdd(xAutoIt,{"C6_SERIORI" ,SD1->D1_SERIE,Nil})
		   aAdd(xAutoIt,{"C6_IDENTB6" ,SD1->D1_IDENTB6,Nil})
		   aAdd(xAutoIt,{"C6_ITEMORI" ,SD1->D1_ITEM	,Nil})	
			//
			aAdd(xAutoAux,xAutoIt)
			//
		   DBSelectArea("SB6")
			DBSetOrder(3) 
			if DBSeek(xFilial("SB6")+SD1->D1_IDENTB6+SD1->D1_COD)
				xAutoCab[2,2] := SB6->B6_TPCF
			Endif
			//
		Endif
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a integracao com o VEIXX000                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMsErroAuto := .f.
	//
	MSExecAuto({|x,y,w,z,k,l| VEIXX001(x,y,w,z,k,l)},xAutoCab,xAutoItens,{},3,"7",xAutoAux )
	//
	If !(nQtdDev == Len(aRet[2])) // A Devolucao foi Parcial
		DBSelectArea("VVF")
		DBGoTo(nRecVVF)
		reclock("VVF",.f.)
		VVF->VVF_SITNFI := "1"
		msunlock()
	Endif
	//
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .f.
	EndIf
	//
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA017VTES³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida TES                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017VTES(cCodTes)

DBSelectArea("SF4")
DBSetOrder(1)
DBSeek(xFilial("SF4")+cCodTes)
cPoder3 := SF4->F4_PODER3
cEstoque := SF4->F4_ESTOQUE
cDuplic  := SF4->F4_DUPLIC
DBSelectArea("VVG")
DBSetOrder(1)
DBSeek(VVF->VVF_FILIAL+VVF->VVF_TRACPA)
DBSelectArea("SF4")
DBSetOrder(1)
DBSeek(xFilial("SF4")+VVG->VVG_CODTES)
//
if SF4->F4_ESTOQUE=="S"
	cMsg := STR0020
else
	cMsg := STR0021
endif    
if SF4->F4_DUPLIC =="S"
	cMsg += STR0018
else
	cMsg += STR0019
endif
// 
If  (cPoder3 $ "RD" .and. !(SF4->F4_PODER3 $ "RD")) .or. ;
    (cPoder3 == "N" .and. !(SF4->F4_PODER3 == "N"))
	MsgInfo(STR0029,STR0026)
	return .f.
Endif
If  (cEstoque != SF4->F4_ESTOQUE) .or. ;
	(cDuplic  != SF4->F4_DUPLIC) 
	MsgInfo(STR0024 + cMsg + STR0025,STR0026)
	return .f.
endif

return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Saida de Veiculos por Retorno de Consignacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{ STR0002 ,"AxPesqui"	, 0 , 1})		// Pesquisar
aAdd(aRotina,{ STR0003 ,"VXA017_2"	, 0 , 2})		// Visualizar
aAdd(aRotina,{ STR0004 ,"VXA017_3"	, 0 , 3,,.f.})	// Devolver
aAdd(aRotina,{ STR0005 ,"VXA017_5"	, 0 , 5,,.f.})	// Cancelar
aAdd(aRotina,{ STR0006 ,"VXA017LEG"	, 0 , 6})		// Legenda
aAdd(aRotina,{ STR0030 ,"VXA017TIT"	, 0 , 4})		// Gerar Financeiro
aAdd(aRotina,{ STR0007 ,"FGX_PESQBRW('S','7')", 0 , 1})	// Pesquisa Avancada ( S-Saida por 7-Retorno de Consignacao )
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA017LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Saida de Veiculos por Retorno de Consignacao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017LEG()
Local aLegenda := {}
aAdd(aLegenda,{'BR_VERDE',STR0008})		// Valida
aAdd(aLegenda,{'f14_verd',STR0031})		// Valida com inconsistência no Financeiro
aAdd(aLegenda,{'BR_VERMELHO',STR0009})	// Cancelada
aAdd(aLegenda,{'BR_PRETO',STR0010})		// Devolvida
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA017TIT ³ Autor ³ Andre Luis Almeida                ³ Data ³ 30/11/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Refaz Financeiro somente se deu problema no momento da geracao da NF   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA017TIT()
If VV0->VV0_SITNFI == "1" // Valida
	If ( VV0->(FieldPos("VV0_GERFIN")) > 0 ) .and. VV0->VV0_GERFIN == "0" // Existe o campo e 0=NAO gerou Financeiro
		If MsgYesNo(STR0032,STR0011) // Deseja gerar o Financeiro desta Saida por Retorno de Consignação? / Atencao
			If VXX001TIT() // Gerar Financeiro ( VEIXX001 - Saidas )
				MsgInfo(STR0033,STR0011) // Financeiro da Saida por Retorno de Consignação gerado com sucesso. / Atencao
			Else
				MsgAlert(STR0034,STR0011) // Existe(m) inconsistência(s) na Geração dos Titulos. Favor corrigir a(s) pendência(s) para solicitar novamente a Geração do Financeiro. / Atencao
			EndIf
		EndIf
	Else
		MsgInfo(STR0035,STR0011) // Financeiro já existente para a Saida por Retorno de Consignação. / Atencao
	EndIf
Else
	MsgStop(STR0036,STR0011) // A Saida por Retorno de Consignação não esta Valida. Impossivel continuar! / Atencao
EndIf
Return