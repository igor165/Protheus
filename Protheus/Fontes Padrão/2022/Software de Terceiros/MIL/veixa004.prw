// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 34     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "VEIXA004.CH"
#include "PROTHEUS.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±               		
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA004 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrada de Veiculos por Transferencia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA004()
Local cFiltro     := ""
Private cCadastro := STR0001 // Entrada de Veiculos por Transferencia
Private aRotina   := MenuDef()
Private cCGCSM0 := ""
Private aHeader :={{"",""}}
Private cFilAntBkp := cFilAnt
Private aCores    := {;
					{'VVF->VVF_SITNFI == "1"','BR_VERDE'},;		// Valida
					{'VVF->VVF_SITNFI == "0"','BR_VERMELHO'},;	// Cancelada
					{'VVF->VVF_SITNFI == "2"','BR_PRETO'}}		// Transferida
Private cGruVei  := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVF")
dbSetOrder(1)
//
cFiltro := " VVF_OPEMOV='3' " // Filtra as Transferencias
//
mBrowse( 6, 1,22,75,"VVF",,,,,,aCores,,,,,,,,cFiltro)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_V ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizar													          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_V(cAlias,nReg,nOpc)
nOpc := 2
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_I ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclui transferencia											          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_I(cAlias,nReg,nOpc)
nOpc := 3
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_C ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelar transferencia										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_C(cAlias,nReg,nOpc)
nOpc := 5
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004(cAlias,nReg,nOpc)
//
DBSelectArea("VVF")
if nOpc == 3 // INCLUSAO
	VXA004BRWVV0()
Else // VISUALIZACAO E CANCELAMENTO
	VEIXX000(,,,nOpc,"3")	// VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov)
EndIf
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA004BRWVV0³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do Browse com as SAIDAS de Veiculos por Transferencia         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004BRWVV0()
Local aRotinaX := aClone(aRotina)      
Local aSM0     := {}
Local aOpcoes  := {}
Private cBrwCond2 := 'VV0->VV0_OPEMOV$ "2" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. VXA004FIL()' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
cCGCSM0 := aSM0[18]
dbSelectArea("VV0")
dbSetOrder(4)
//   
cFilTop := "VV0.R_E_C_N_O_ IN ( SELECT VV0.R_E_C_N_O_ "
cFilTop += " FROM " + RetSQLName("SA1") + " A1 JOIN "+RetSQLName("VV0")+" VV0 ON VV0_FILIAL <> '" + xFilial("VV0") + "' AND VV0_CODCLI = A1_COD AND VV0_LOJA = A1_LOJA AND VV0.D_E_L_E_T_ = ' '"
cFilTop += " JOIN " + RetSQLName("VVA") + " VVA ON VVA_FILIAL = VV0_FILIAL AND VVA_NUMTRA = VV0_NUMTRA AND VVA.D_E_L_E_T_ = ' '"
cFilTop += " JOIN " + RetSQLName("VV1") + " VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VVA.VVA_CHAINT AND VV1.VV1_FILSAI = VV0_FILIAL AND VV1.VV1_SITVEI = '2' "
cFilTop += " AND VV1.VV1_ULTMOV = 'S'"
cFilTop += " AND VV1.D_E_L_E_T_ = ' '"
cFilTop += " WHERE A1.A1_FILIAL = '"+xFilial("SA1")+"'"
cFilTop +=  " AND A1.A1_CGC = '" + cCGCSM0 + "'"
cFilTop +=  " AND A1.D_E_L_E_T_ = ' '"
cFilTop +=  " AND VV0_OPEMOV = '2'"
cFilTop +=  " AND VV0_SITNFI = '1'"
cFilTop +=  " AND VV0_NUMNFI <> '  ') "
//
aAdd(aOpcoes,{STR0003,"VXA004VIS()"}) // Visualizar Saida por Transferencia
aAdd(aOpcoes,{STR0012,"VXA004TRF('"+cFilAnt+"')"}) // Transferir
//
FGX_LBBROW(cCadastro,"VV0",aOpcoes,cFilTop,"VV0_FILIAL,VV0_NUMNFI,VV0_SERNFI","VV0_DATMOV")
//
cFilAnt := cFilAntBkp
//
aRotina := aClone(aRotinaX)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA004FIL ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o filtro do browse das SAIDAS de veiculo por transferencia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004FIL()
Local lRet := .f.
//
SA1->(DbSetOrder(1))
SA1->(DBSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
// Verifica se o cliente da transf. e' a filial atual
If SA1->A1_CGC == cCGCSM0
	VVA->(DbSetOrder(1))
	VVA->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA))	
	VV1->(DbSetOrder(2))
	VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
	// Verifica se a ultima movimentacao do veiculo foi o VV0 em questao ( SAIDA por Transferencia ) //
	If VV1->VV1_ULTMOV == "S" .and. VV1->VV1_FILSAI == VV0->VV0_FILIAL .and. VV1->VV1_NUMTRA == VV0->VV0_NUMTRA
		lRet := .t.
	EndIf
EndIf
//
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA004TRF ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz verificacoes finais e executa a transferencia via integracao com   ³±±
±±³          ³ o programa VEIXX000                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004TRF(c_xFil)
Local xAutoCab := {}
Local xAutoItens := {}
Local cCodTes , cSitTri, cLocPad, cLocaliz, lLocaliz
// Declaracao da ParamBox
Local aRet := {}
Local aParamBox := {}
Local aRetSelVei := {}
Local aSM0 := {}
Local nPosVet := 0

Local lVVF_VEICU1 := ( VVF->(FieldPos("VVF_VEICU1")) > 0 )
Local lVVF_VEICU2 := ( VVF->(FieldPos("VVF_VEICU2")) > 0 )
Local lVVF_VEICU3 := ( VVF->(FieldPos("VVF_VEICU3")) > 0 )
Local lContabil   := ( VVG->(FieldPos("VVG_CENCUS")) > 0 .and. VVG->(FieldPos("VVG_CONTA")) > 0 .and. VVG->(FieldPos("VVG_ITEMCT")) > 0 .and. VVG->(FieldPos("VVG_CLVL")) > 0 ) // Campos para a contabilizacao das ENTRADAS de Veiculos
//
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()
//
Default c_xFil := cFilAnt

cFilAnt := c_xFil

// Posiciona do SM0 para obter o CGC da filial que ORIGINOU a transferencia (saida)

aSM0 := FWArrFilAtu(cEmpAnt,VV0->VV0_FILIAL) 

if Len(aSM0) == 0 
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0014)//A Filial nro. ### nao encontrada. Impossivel continuar
	Return .f.
endif

cCGC := aSM0[18]

// Pesquisa o fornecedor pelo CGC da filial que ORIGINOU a transferencia (saida)
DBSelectArea("SA2")
DBSetOrder(3)
if !DBSeek(xFilial("SA2")+cCGC)
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0016+": " + cCGC+ " "+STR0017)//A Filial nro. ### CGC ### nao foi encontrada no cadastro de fornecedores. Favor cadastrar
	Return .f.
Else
	If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
		Return .f.
	EndIf
endif
If &cBrwCond2 // Condicao do Browse 2, validar a Transferencia
	aAdd(aParamBox,{1,STR0018,SA2->A2_COD,"","","",".F.",0,.T.})//Fornecedor
	aAdd(aParamBox,{1,STR0019,SA2->A2_LOJA,"","","",".F.",0,.T.})//Loja
	aAdd(aParamBox,{1,STR0020,Left(SA2->A2_NOME,20),"","","",".F.",0,.T.})//Nome
	aAdd(aParamBox,{1,STR0021,VV0->VV0_NUMNFI,"","","",".F.",0,.T.})//Nota Fiscal
	aAdd(aParamBox,{1,STR0022,VV0->VV0_SERNFI,"","","",".F.",0,.T.})//Serie
	aAdd(aParamBox,{1,RetTitle("VVG_OPER"),Space(TamSX3("VVG_OPER")[1]),"","VXA004OPER(VV0->VV0_FILIAL,VV0->VV0_NUMTRA,MV_PAR06,cCGC)","DJ","",0,.f.})//OPER
	aAdd(aParamBox,{1,RetTitle("VVF_ESPECI"),space(TamSX3("VVF_ESPECI")[1]),VVF->(X3Picture("VVF_ESPECI")),"Vazio() .or. ExistCpo('SX5','42'+MV_Par07)","42","",20,X3Obrigat("VVF_ESPECI")}) // Especie da NF
	aAdd(aParamBox,{1,STR0026,VXA004CNFE(VV0->VV0_FILIAL,VV0->VV0_NUMNFI , VV0->VV0_SERNFI , VV0->VV0_CODCLI , VV0->VV0_LOJA, VV0->VV0_DATEMI),VVF->(X3Picture("VVF_CHVNFE")),"VXVlChvNfe('0',Mv_Par07)","","",120,.F.})//Chave da NFE
	aAdd(aParamBox,{1,RetTitle("VVF_TRANSP"),Space(TAMSX3("VVF_TRANSP")[1]),/*X3Picture("VVF_TRANSP")*/,,"SA4"	,"",30,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VVF_PLIQUI"),0,X3Picture("VVF_PLIQUI"),,""		,"",50,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VVF_PBRUTO"),0,X3Picture("VVF_PBRUTO"),,""		,"",50,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VVF_VOLUM1"),0,X3Picture("VVF_VOLUM1"),,""		,"",30,.f.})
	aAdd(aParamBox,{1,RetTitle("VVF_ESPEC1"),space(TamSX3("VVF_ESPEC1")[1]),VVF->(X3Picture("VVF_ESPEC1")),"","","",50,.f.}) // Especie 1
	aAdd(aParamBox,{1,RetTitle("VVF_TOTFRE"),VV0->VV0_VALFRE,X3Picture("VVF_TOTFRE"),,"","",50,.f.}) 
	aAdd(aParamBox,{1,RetTitle("VVF_NATURE"),VV0->VV0_NATFIN,"","Vazio() .or. FinVldNat( .F. )","SED","",40,.F.}) // Natureza

	// Veículo Transportador (Integração MATA103 - CI 008022)
	nPosVet := 16

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

	aAdd(aParamBox,{11,RetTitle("VVF_OBSENF"),space(200),"","",.f.}) // MV_PAR16 ou MV_PAR19
	
	//
	lPassou := .f.
	while !lPassou
		lPassou := .t.
		//
		aRetSelVei := FGX_SELVEI("VV0",STR0017,VV0->VV0_FILIAL,VV0->VV0_NUMTRA,aParamBox, 'VA0004001B_ValidaTES')
		//
		If Len(aRetSelVei) == 0 //!(ParamBox(aParamBox,STR0017,@aRet,,,,,,,,.f.)) //Dados do Retorno de Remessa
			Return .f.
		Endif
	Enddo
	//
	aRetSelVei[1,nPosVet] := &("MV_PAR"+strzero(nPosVet,2)) // Prencher MEMO no Vetor de Retorno da Parambox
    //
    
	lLocaliz := .f.
	// USA LOCALIZACAO DE VEICULOS
	if GetNewPar("MV_LOCVZL","N")=="S" .and. VVG->(FieldPos("VVG_LOCALI")) <> 0
		lLocaliz := .t.
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array de integracao com o VEIXX000                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")		,Nil})
	aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"   		 		,Nil})
	aAdd(xAutoCab,{"VVF_CLIFOR"  ,"F" 					,Nil})
	aAdd(xAutoCab,{"VVF_NUMNFI"  ,VV0->VV0_NUMNFI		,Nil})
	aAdd(xAutoCab,{"VVF_SERNFI"  ,VV0->VV0_SERNFI		,Nil})
	aAdd(xAutoCab,{"VVF_CODFOR"  ,SA2->A2_COD			,Nil})
	aAdd(xAutoCab,{"VVF_LOJA "   ,SA2->A2_LOJA			,Nil})
	aAdd(xAutoCab,{"VVF_FORPAG"  ,VV0->VV0_FORPAG  		,Nil})
	
	If !Empty(aRetSelVei[1,15])
		aAdd(xAutoCab,{"VVF_NATURE"  ,aRetSelVei[1,15],Nil})
	elseif !Empty(VV0->VV0_NATFIN)
		aAdd(xAutoCab,{"VVF_NATURE"  ,VV0->VV0_NATFIN	,Nil})
	endif

	aAdd(xAutoCab,{"VVF_DATEMI"  ,VV0->VV0_DATMOV		,Nil})
	aAdd(xAutoCab,{"VVF_ESPECI"  ,aRetSelVei[1,7]		,Nil})
	aAdd(xAutoCab,{"VVF_CHVNFE"  ,aRetSelVei[1,8]		,Nil})
	aAdd(xAutoCab,{"VVF_TRANSP"  ,aRetSelVei[1,9]		,Nil})
	aAdd(xAutoCab,{"VVF_PLIQUI"  ,aRetSelVei[1,10]		,Nil})
	aAdd(xAutoCab,{"VVF_PBRUTO"  ,aRetSelVei[1,11]		,Nil})
	aAdd(xAutoCab,{"VVF_VOLUM1"  ,aRetSelVei[1,12]		,Nil})
	aAdd(xAutoCab,{"VVF_ESPEC1"  ,aRetSelVei[1,13]		,Nil})
	aAdd(xAutoCab,{"VVF_TOTFRE"  ,aRetSelVei[1,14]		,Nil})

	// Veículo Transportador (Integração MATA103 - CI 008022)
	nPosVet := 15 // Última posíção válida para incremento

	If lVVF_VEICU1
		aAdd(xAutoCab,{"VVF_VEICU1" ,aRetSelVei[1,nPosVet++],Nil})
	EndIf

	If lVVF_VEICU2
		aAdd(xAutoCab,{"VVF_VEICU2" ,aRetSelVei[1,nPosVet++],Nil})
	EndIf

	If lVVF_VEICU3
		aAdd(xAutoCab,{"VVF_VEICU3" ,aRetSelVei[1,nPosVet++],Nil})
	EndIf

	aAdd(xAutoCab,{"VVF_OBSENF"  ,aRetSelVei[1,nPosVet++]		,Nil})
	
	//
	DBSelectArea("VVA")
	DBSetOrder(4)
	DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
	//
	nVeic := 0
	cStr  := STR0028 + CRLF
	cStr  += Repl("-",40) +CRLF
	while !eof() .and. VV0->VV0_FILIAL+VV0->VV0_NUMTRA == VVA->VVA_FILIAL + VVA->VVA_NUMTRA
	
		DBSelectArea("VV1")
		DBSetOrder(2)
		DBSeek(xFilial("VV1")+VVA->VVA_CHASSI)

		if lLocaliz
			VZL->(DBSetOrder(1))
			aParamBox := {}
			aRet := {}
			MV_PAR01 := ""
			MV_PAR02 := ""
			M->VVG_LOCPAD := VV1->VV1_LOCPAD // Variavel utilizada na consulta padrao VZL
			aAdd(aParamBox,{1,RetTitle("VVG_LOCPAD"),VV1->VV1_LOCPAD,"","VXA004VLOC()","NNR","",0,X3Obrigat("VVG_LOCPAD")})
			aAdd(aParamBox,{1,RetTitle("VVG_LOCALI"),Space(TamSX3("VVG_LOCALI")[1]),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01+MV_PAR02))","VZL","",0,X3Obrigat("VVG_LOCALI")})
			If !(ParamBox(aParamBox,STR0025+Alltrim(VVA->VVA_CHASSI),@aRet,,,,,,,,.F.))
				Return .f.
			endif
			cLocPad := aRet[1]
			cLocaliz := aRet[2]
		else
			cLocPad := VV1->VV1_LOCPAD
			cLocaliz := ""
		Endif
	   nVeic := Ascan(aRetSelVei[2],{|x| x[4] == VVA->VVA_CHASSI })
		xAutoIt := {}
		aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")		,Nil})
		aAdd(xAutoIt,{"VVG_CHASSI"  ,VVA->VVA_CHASSI 	,Nil})
		aAdd(xAutoIt,{"VVG_CODTES"  ,aRetSelVei[2,nVeic,3]			,Nil})
		aAdd(xAutoIt,{"VVG_LOCPAD"  ,cLocPad			,Nil})
		if lLocaliz
			aAdd(xAutoIt,{"VVG_LOCALI"  ,cLocaliz		,Nil})
		endif
		aAdd(xAutoIt,{"VVG_VALUNI"  ,VVA->VVA_VALMOV	,Nil})
		aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"				,Nil})

		If lContabil
			if Len(aRetSelVei[2,nVeic]) > 7
				aAdd(xAutoIt,{"VVG_CENCUS",aRetSelVei[2,nVeic,8]	,Nil})
				aAdd(xAutoIt,{"VVG_CONTA" ,aRetSelVei[2,nVeic,9]	,Nil})
				aAdd(xAutoIt,{"VVG_ITEMCT",aRetSelVei[2,nVeic,10]	,Nil})
				aAdd(xAutoIt,{"VVG_CLVL"  ,aRetSelVei[2,nVeic,11]	,Nil})
			EndIf
		EndIf
		//
		aAdd(xAutoItens,xAutoIt)
		cStr += Left(VVA->VVA_CHASSI + SPACE(30),30) + Right(SPACE(20)+Transform(VVA->VVA_VALMOV,"@E 999,999,999.99"),20) + CRLF
		DBSelectArea("VVA")
		DBSkip()

	enddo
	cStr  += Repl("-",40) +CRLF
	cStr  += STR0029+"           " + Transform(VV0->VV0_VALTOT,"@E 999,999,999.99") + CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a integracao com o VEIXX000                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	lMsErroAuto := .f.
	//
	if !MsgYesNo(cStr)
		Return .f.
	endif
	MSExecAuto({|x,y,w,z,k| VEIXX000(x,y,w,z,k)},xAutoCab,xAutoItens,{},3,"3" )
	//
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .f.
	EndIf
EndIf
VV0->(dbGotop())
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004OPER³Autor ³Manoel                             ³ Data ³ 09/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação da Operação e Retorno da TES                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004OPER(_cFilTI , _cNroTI , _cCodOperTI , _cCGCForTI )
Local aArea  := GetArea()
Local ii  := 0

If !ExistCpo("SX5","DJ"+_cCodOperTI)
	Return .F.
Else
	For ii = 1 to Len(aIteVei)
		DBSelectArea("VVA")
		DBSetOrder(1)
		DBSeek(_cFilTI + _cNroTI)
		DBSelectArea("SB1")
		DBSetOrder(7)
		If FGX_VV1SB1("CHAINT", aIteVei[ii,7] , /* cMVMIL0010 */ , cGruVei )
			cTes := MaTesInt(1,_cCodOperTI,SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)

			If !Empty(cTes)
				If VA0004001B_ValidaTES(cTes, aIteVei, ii, aIteVei[ii, 4])
					aIteVei[ii,3] := cTes
				else
					Return .F.
				Endif
			Endif
		Endif
	Next

	oLbIteVei:refresh()

Endif
    
RestArea( aArea )

Return .T.       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004VLOC  ³ Autor ³ Rubens                         ³ Data ³ 14/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Localizacao na Parambox                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004VLOC()

Local lRetorno

VZL->(dbSetOrder(1))
lRetorno := VZL->(DBSeek(xFilial('VZL')+MV_PAR01))

M->VVG_LOCPAD := MV_PAR01

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Entrada de Veiculos por Transferencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { ;
{ OemtoAnsi(STR0002) ,"AxPesqui" , 0 , 1},;			// Pesquisar
{ OemtoAnsi(STR0003) ,"VXA004_V"     		, 0 , 2},;		// Visualizar
{ OemtoAnsi(STR0004) ,"VXA004_I"    		, 0 , 3,,.f.},;		// Devolver
{ OemtoAnsi(STR0005) ,"VXA004_C"    	 	, 0 , 5,,.f.},;		// Cancelar
{ OemtoAnsi(STR0006) ,"VXA004LEG" 	 	, 0 , 6},;		// Legenda
{ OemtoAnsi(STR0007) ,"FGX_PESQBRW('E','3')" , 0 , 1}}	// Pesquisa Avancada ( E-Entrada por 3-Transferencia )
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA004LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Transferencia                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004LEG()
Local aLegenda := {;
{'BR_VERDE',STR0008},;
{'BR_VERMELHO',STR0009},;
{'BR_PRETO',STR0010}}
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA004VIS ³ Autor ³ Manoel                            ³ Data ³ 07/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a vizualização da Nota de Transferencia de Saida                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004VIS()
// Declaracao da ParamBox
Local aSM0 := {}   
Local lRet := .t.

c_xFil := VV0->VV0_FILIAL

//
cFilBkp := cFilAnt
cFilAnt := c_xFil

// Posiciona do SM0 para obter o CGC da filial que ORIGINOU a transferencia (saida)

aSM0 := FWArrFilAtu(cEmpAnt,VV0->VV0_FILIAL) 

if Len(aSM0) == 0 
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0014)//A Filial nro. ### nao encontrada. Impossivel continuar
	Return .f.
endif

cCGC := aSM0[18]

// Pesquisa o fornecedor pelo CGC da filial que ORIGINOU a transferencia (saida)
DBSelectArea("SA2")
DBSetOrder(3)
if !DBSeek(xFilial("SA2")+cCGC)
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0016+": " + cCGC+ " "+STR0017)//A Filial nro. ### CGC ### nao foi encontrada no cadastro de fornecedores. Favor cadastrar
	Return .f.
endif
//
DBSelectArea("VV0")
cAlias := "VV0"
nReg := VV0->( recno() )
nOpc := 2
lRet = VEIXX001(NIL,NIL,NIL,nOpc,"2")
//
cFilAnt := cFilBkp
Return lRet


Function VA0004001B_ValidaTES(cTES, aItevei, nLha, cChassi)
	Local cFilBkp := cFilAnt
	Local cEstoque
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+cTes)
	cEstoque := SF4->F4_ESTOQUE
	DBSelectArea("VVA")
	DBSetOrder(1)
	DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA+cChassi)
	
	cFilAnt := VV0->VV0_FILIAL // Mudar cFilAnt pq o Cadastro de TES pode ser EXCLUSIVO
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+VVA->VVA_CODTES)
	cFilAnt := cFilBkp

	if SF4->F4_ESTOQUE == "S"
		cMsg := STR0030
	else
		cMsg := STR0031
	endif
	if cEstoque != SF4->F4_ESTOQUE
		MsgInfo(STR0023 + cMsg, STR0011)
		return .F.
	endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VVXA004CNFE³Autor ³Jose Luis                         ³ Data ³ 05/08/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a chave eletrônica da Nota Fiscal de Saida por Transferencia   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004CNFE(_cFilial, _cDocNfe , _cSerNfe , _cCodCli , _cCodLoj, _dDatEmis )
Local cQuery := ""
Local cChvNfe := ""

	cQuery := "SELECT F2_CHVNFE FROM " + RetSqlName('SF2')
	cQuery += " WHERE F2_FILIAL = '" + _cFilial + "' "
	cQuery += "   AND F2_DOC = '"+ _cDocNfe +"' AND F2_SERIE = '"+ _cSerNfe +"'"
	cQuery += "   AND F2_CLIENTE = '"+ _cCodCli +"' AND F2_LOJA = '"+ _cCodLoj +"'"
	cQuery += "   AND F2_EMISSAO = '"+ DtoS(_dDatEmis) +"'
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cChvNfe := FM_SQL(cQuery)

Return cChvNfe
