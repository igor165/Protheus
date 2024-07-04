// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 18     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "VEIXA008.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA008 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrada de Veiculos por Remessa/Consignacao entre Filiais              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA008()
Local aCampos := {;
{RetTitle("VV0_NUMNFI"),	"VV0_NUMNFI"	},;
{FGX_MILSNF("VV0", 7, "VV0_SERNFI"),	FGX_MILSNF("VV0", 3, "VV0_SERNFI")},;
{RetTitle("VV0_DATMOV"),	"VV0_DATMOV"	},;
{RetTitle("VV0_CODCLI"),	"VV0_CODCLI"	},;
{RetTitle("VV0_LOJA"),		"VV0_LOJA"		},;
{RetTitle("VV0_NOMCLI"),	"VV0_NOMCLI"	}}

Private cCliForA := "" //GetNewPar("MV_CLFRRC","")
Private cCadastro := STR0001 // Entrada de Veiculos por Remessa/Consignacao entre Filiais
Private aRotina   := MenuDef()
Private aCores    := {;
{'VV0->VV0_OPEMOV == "3"','BR_AZUL'},;
{'VV0->VV0_OPEMOV == "5"','BR_AMARELO'},;
{'VV0->VV0_OPEMOV == "6"','BR_VERMELHO'},;
{'VV0->VV0_OPEMOV == "7"','BR_LARANJA'} }
Private cBrwCond := 'VV0->VV0_OPEMOV$"3567" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. VXA008FIL()' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//
dbSelectArea("VV0")
dbSetOrder(4)
//
FilBrowse('VV0',{},'VV0->VV0_OPEMOV$ "3567" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. VXA008FIL()')
mBrowse( 6, 1,22,75,"VV0",aCampos,,,,,aCores,,,,,,.t.)
//
dbClearFilter()
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA008_2 ³ Autor ³ Thiago							³ Data ³ 03/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacao														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008_2(cAlias,nReg,nOpc)
nOpc := 2
VXA008(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA008_3 ³ Autor ³ Thiago							³ Data ³ 03/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusao															      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008_3(cAlias,nReg,nOpc)
nOpc := 3
VXA008(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA008   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008(cAlias,nReg,nOpc)
//
// If &cBrwCond // Condicao do Browse, validar ao Incluir/Alterar/Excluir
If nOpc == 3 					// INCLUSAO
	VXA008TRF()
Else 								// VISUALIZACAO E CANCELAMENTO
	DBSelectArea("VVF")
	DBClearFilter()
	VEIXX001(,,,nOpc,VV0->VV0_OPEMOV)	// VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov)  
	FilBrowse('VV0',{},'VV0->VV0_OPEMOV$ "3567" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. VXA008FIL()')
EndIf
// EndIf
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA008FIL ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o filtro do browse das SAIDAS de veiculo por transferencia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008FIL()
Local lRet := .f.
Local aSM0     := {}
//
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
IF VV0->VV0_CLIFOR == "C"
	SA1->(DbSetOrder(1))
	if FWModeAccess("SA1",3) == "E"
		SA1->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_CODCLI+VV0->VV0_LOJA))
	else
		SA1->(DBSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
	endif
	// Verifica se o cliente da transf. e' a filial atual
	If SA1->A1_CGC == aSM0[18]
		VVA->(DbSetOrder(1))
		VVA->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA))
		VV1->(DbSetOrder(2))
		VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
		// Verifica se a ultima movimentacao do veiculo foi o VV0 em questao ( SAIDA por Transferencia ) //
		If VV1->VV1_ULTMOV == "S" .and. VV1->VV1_FILSAI == VV0->VV0_FILIAL .and. VV1->VV1_NUMTRA == VV0->VV0_NUMTRA
			lRet := .t.
		EndIf
	EndIf
else
	SA2->(DbSetOrder(1))
	if FWModeAccess("SA2",3) == "E"
		SA2->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_CODCLI+VV0->VV0_LOJA))
	else
		SA2->(DBSeek(xFilial("SA2")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
	endif
	// Verifica se o cliente da transf. e' a filial atual
	If SA2->A2_CGC == aSM0[18]
		VVA->(DbSetOrder(1))
		VVA->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA))
		VV1->(DbSetOrder(2))
		VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
		// Verifica se a ultima movimentacao do veiculo foi o VV0 em questao ( SAIDA por Transferencia ) //
		If VV1->VV1_ULTMOV == "S" .and. VV1->VV1_FILSAI == VV0->VV0_FILIAL .and. VV1->VV1_NUMTRA == VV0->VV0_NUMTRA
			lRet := .t.
		EndIf
	EndIf
endif
	//
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA008TRF ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz verificacoes finais e executa a transferencia via integracao com   ³±±
±±³          ³ o programa VEIXX000                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008TRF()
Local xAutoCab := {}
Local xAutoItens := {}
Local xAutoAux := {}
Local nRecVV0 := VV0->(RecNo())
// Declaracao da ParamBox
Local aRet := {}
Local aParamBox := {}
Local nTamGru := TamSx3("B1_GRUPO")[1]		// Tamanho da variavel de grupo
Local aSM0 := {}
//
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()
//
Private cCF := ""
Private cGruVei  := Left(GetMv("MV_GRUVEI")+space(nTamGru),nTamGru)
Private cCliForA := VV0->VV0_CLIFOR

DBSelectArea("VVA")
DBSetOrder(1)
DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
//
while !eof() .and. VV0->VV0_FILIAL+VV0->VV0_NUMTRA == VVA->VVA_FILIAL + VVA->VVA_NUMTRA
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+VVA->VVA_CHASSI)
	//
	if VV0->VV0_OPEMOV $"67"

		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )		

		DBSelectArea("SD2")
		DBSetOrder(3)
		DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)

	   DBSelectArea("SD2")
		DBSetOrder(3) 
		DBSeek(xFilial("SD2")+SD2->D2_NFORI+SD2->D2_SERIORI)

	   DBSelectArea("SB6")
		DBSetOrder(3) 
		if DBSeek(xFilial("SB6")+SD2->D2_IDENTB6+SD2->D2_COD)
		   cCliForA := SB6->B6_TPCF
		   exit
		Endif
	endif
	//
	DBSelectArea("VVA")
	DBSkip()
	//
enddo
// Posiciona do SM0 para obter o CGC da filial que ORIGINOU a transferencia (saida)
aSM0 := FWArrFilAtu(cEmpAnt,VV0->VV0_FILIAL) 
if Len(aSM0) == 0
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0014)//A Filial nro ### nao encontrada. Impossivel continuar
	return .f.
endif
cCGC := aSM0[18]
// Pesquisa o cliente pelo CGC da filial que ORIGINOU a transferencia (saida)
if cCliForA == "C"
	DBSelectArea("SA1")
	DBSetOrder(3)
	if !DBSeek(xFilial("SA1")+cCGC)
		MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0015+" " + cCGC+ " "+STR0016)//A Filial nro ### CGC ### nao foi encontrada no cadastro de clientes. Favor cadastrar
		return .f.
	Else
		If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
			Return .f.
		EndIf
	endif
	//
	aAdd(aParamBox,{1,STR0017,SA1->A1_COD,"","","",".F.",0,.T.})//Cliente
	aAdd(aParamBox,{1,STR0018,SA1->A1_LOJA,"","","",".F.",0,.T.})//Loja
	aAdd(aParamBox,{1,STR0019,Left(SA1->A1_NOME,20),"","","",".F.",0,.T.})//Nome  
	cCF := "C"
	//
else
	DBSelectArea("SA2")
	DBSetOrder(3)
	if !DBSeek(xFilial("SA2")+cCGC)
		MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0015+" " + cCGC+ " "+STR0025)//A Filial nro ### CGC ### nao foi encontrada no cadastro de clientes. Favor cadastrar
		return .f.
	Else
		If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
			Return .f.
		EndIf
	endif
	//
	aAdd(aParamBox,{1,STR0017,SA2->A2_COD,"","","",".F.",0,.T.})//Cliente
	aAdd(aParamBox,{1,STR0018,SA2->A2_LOJA,"","","",".F.",0,.T.})//Loja
	aAdd(aParamBox,{1,STR0019,Left(SA2->A2_NOME,20),"","","",".F.",0,.T.})//Nome
	cCF := "F"
	//
endif

aAdd(aParamBox,{1,STR0020,VV0->VV0_NUMNFI,"","","",".F.",0,.T.})//Nota Fiscal
aAdd(aParamBox,{1,STR0021, FGX_MILSNF("VV0", 2, "VV0_SERNFI") ,"","","",".F.",0,.T.})//Serie
aAdd(aParamBox,{1,STR0035,Space(2),"","VXA008TOP(MV_PAR06,MV_PAR01,MV_PAR02)","DJ","",0,.T.})//Tp Operacao
aAdd(aParamBox,{1,STR0022,Space(TamSX3("F4_CODIGO")[1]),"","VXA008VTES()","SF4","",0,.T.})//TES
aAdd(aParamBox,{1,STR0023,Space(TamSX3("VVG_SITTRI")[1]),"","","S0","",0,.T.})//Sit.Tributaria
aAdd(aParamBox,{1,RetTitle("VVF_ESPECI"),space(TamSX3("VVF_ESPECI")[1]),VVF->(X3Picture("VVF_ESPECI")),"Vazio() .or. ExistCpo('SX5','42'+MV_Par09)","42","",20,X3Obrigat("VVF_ESPECI")}) // Especie da NF
aAdd(aParamBox,{1,STR0034,space(TamSX3("VVF_CHVNFE")[1]),VVF->(X3Picture("VVF_CHVNFE")),"VXVlChvNfe('0',Mv_Par09)","","",120,.T.}) // Chave da NFE
aAdd(aParamBox,{1,RetTitle("VVF_TRANSP"),Space(TAMSX3("VVF_TRANSP")[1]),/*X3Picture("VVF_TRANSP")*/,,"SA4"	,"",30,.f.}) 
aAdd(aParamBox,{1,RetTitle("VVF_PLIQUI"),0,X3Picture("VVF_PLIQUI"),,""		,"",50,.f.}) 
aAdd(aParamBox,{1,RetTitle("VVF_PBRUTO"),0,X3Picture("VVF_PBRUTO"),,""		,"",50,.f.}) 
aAdd(aParamBox,{1,RetTitle("VVF_VOLUM1"),0,X3Picture("VVF_VOLUM1"),,""		,"",30,.f.})
aAdd(aParamBox,{1,RetTitle("VVF_ESPEC1"),space(TamSX3("VVF_ESPEC1")[1]),VVF->(X3Picture("VVF_ESPEC1")),"","","",50,.f.}) // Especie 1
aAdd(aParamBox,{11,RetTitle("VVF_OBSENF"),space(200),"","",.f.}) // MV_PAR16
If !(ParamBox(aParamBox,STR0024,@aRet,,,,,,,,.f.) )//Dados da Transferencia
	return
Endif
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array de integracao com o VEIXX000                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")	,Nil})
aAdd(xAutoCab,{"VVF_CLIFOR"  ,cCliForA		    ,Nil})
aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"   		 	,Nil})
aAdd(xAutoCab,{"VVF_NUMNFI"  ,VV0->VV0_NUMNFI	,Nil})
aAdd(xAutoCab,{"VVF_SERNFI"  ,VV0->VV0_SERNFI	,Nil})
aAdd(xAutoCab,{"VVF_CODFOR"  ,MV_PAR01			,Nil})
aAdd(xAutoCab,{"VVF_LOJA "   ,MV_PAR02			,Nil})
aAdd(xAutoCab,{"VVF_FORPAG"  ,VV0->VV0_FORPAG	,Nil})
aAdd(xAutoCab,{"VVF_NATURE"  ,VV0->VV0_NATFIN	,Nil})
aAdd(xAutoCab,{"VVF_DATEMI"  ,VV0->VV0_DATEMI	,Nil})
aAdd(xAutoCab,{"VVF_ESPECI"  ,aRet[9]			,Nil})
aAdd(xAutoCab,{"VVF_CHVNFE"  ,aRet[10]			,Nil})
aAdd(xAutoCab,{"VVF_TRANSP"  ,aRet[11]			,Nil})
aAdd(xAutoCab,{"VVF_PLIQUI"  ,aRet[12]			,Nil})
aAdd(xAutoCab,{"VVF_PBRUTO"  ,aRet[13]			,Nil})
aAdd(xAutoCab,{"VVF_VOLUM1"  ,aRet[14]			,Nil})
aAdd(xAutoCab,{"VVF_ESPEC1"  ,aRet[15]			,Nil})
aAdd(xAutoCab,{"VVF_OBSENF"  ,aRet[16]			,Nil})
//
DBSelectArea("VVA")
DBSetOrder(1)
DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
//
while !eof() .and. VV0->VV0_FILIAL+VV0->VV0_NUMTRA == VVA->VVA_FILIAL + VVA->VVA_NUMTRA
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+VVA->VVA_CHASSI)
	xAutoIt := {}
	aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")	,Nil})
	aAdd(xAutoIt,{"VVG_CHASSI"  ,VVA->VVA_CHASSI,Nil})
	aAdd(xAutoIt,{"VVG_CODTES"  ,aRet[7]		,Nil})
	aAdd(xAutoIt,{"VVG_LOCPAD"  ,VV1->VV1_LOCPAD,Nil})
	aAdd(xAutoIt,{"VVG_SITTRI"  ,aRet[8]		,Nil})
	aAdd(xAutoIt,{"VVG_VALUNI"  ,VVA->VVA_VALMOV,Nil})
	aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"			,Nil})
	//
	aAdd(xAutoItens,xAutoIt)
	//
	if VV0->VV0_OPEMOV $"67"
		xAutoIt := {}
		DBSelectArea("SB1")
		DBSetOrder(7)
		If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			FMX_HELP("VA008E01" , STR0030)//Veículo não existe. ### Atencao
			Return .f.
		endif
		DBSelectArea("SD2")
		DBSetOrder(3)
		if !DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
			MsgInfo(STR0032,STR0031+": VA008E02")//Nota fiscal de saída não encontrada. ### Atencao
			Return .f.
		Endif
		DBSelectArea("VV0")
		DBSetOrder(4)
		nRecNo := VV0->(Recno())
		dbClearFilter()
	    if !DBSeek(xFilial("VV0")+SD2->D2_NFORI+SD2->D2_SERIORI)
		    VV0->(DBGoTo(nRecNo))
		    MsgInfo(STR0033,STR0031+": VA008E03")//"Nota fiscal de origem não encontrada". ### Atencao
   			Return .f.
	    Endif	
	    VV0->(DBGoTo(nRecNo))
	    //
	    DBSelectArea("SD2")
		DBSetOrder(3) 
		if !DBSeek(xFilial("SD2")+SD2->D2_NFORI+SD2->D2_SERIORI)
			MsgInfo(STR0032,STR0031+": VA008E04")//Nota fiscal de saída não encontrada. ### Atencao
			Return .f.
		Endif
		//
		aAdd(xAutoIt,{"D1_NFORI"   ,SD2->D2_DOC     ,Nil})
		aAdd(xAutoIt,{"D1_SERIORI" ,SD2->D2_SERIE   ,Nil})
		aAdd(xAutoIt,{"D1_ITEMORI" ,SD2->D2_ITEM    ,Nil})
		aAdd(xAutoIt,{"D1_IDENTB6" ,SD2->D2_IDENTB6 ,Nil})
		//
		aAdd(xAutoAux,xAutoIt)
	endif
	//
	DBSelectArea("VVA")
	DBSkip()
enddo
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a integracao com o VEIXX000                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN TRANSACTION
//
lMsErroAuto := .f.
//
if  VV0->VV0_OPEMOV == "3"
	cOpeMov := "2"
elseif VV0->VV0_OPEMOV == "5"
	cOpeMov := "4"
elseif VV0->VV0_OPEMOV == "6"
	cOpeMov := "7"
elseif VV0->VV0_OPEMOV == "7"
	cOpeMov := "8"
endif

MSExecAuto({|x,y,w,z,k,l| VEIXX000(x,y,w,z,k,l)},xAutoCab,xAutoItens,{},3,cOpeMov,xAutoAux )
//
if lMsErroAuto
	DisarmTransaction()
	MostraErro()
	return .f.
Endif
//
END TRANSACTION
FilBrowse('VV0',{},'VV0->VV0_OPEMOV$ "3567" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. VXA008FIL()')
//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA008VTES³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida TES de Entrada por Transferencia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008VTES()
// TODO: Validar o TES de Entrada
return .t.

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
{ OemtoAnsi(STR0002) ,"AxPesqui" , 0 , 1},;				// Pesquisar
{ OemtoAnsi(STR0003) ,"VXA008_2"     		, 0 , 2},;			// Visualizar
{ OemtoAnsi(STR0004) ,"VXA008_3"    		, 0 , 3,,.f.},;			// Devolver
{ OemtoAnsi(STR0006) ,"VXA008LEG" 	 	, 0 , 6}}
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA008LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Transferencia                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008LEG()
Local aLegenda := {;
{'BR_AZUL',STR0008},;
{'BR_AMARELO',STR0009},;
{'BR_VERMELHO',STR0028},;
{'BR_LARANJA',STR0029} }
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA008TOP ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tipo de Operacao. (Tes inteligente)				                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA008TOP(cTOper,cCliFor,cLoja)
Local cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
 
if !Empty(cTOper)           
	VVA->(DbSetOrder(1))
	VVA->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA))
	VV1->(DbSetOrder(2))
	VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	MV_PAR07 := MaTesInt(1,cTOper,cCliFor,cLoja,cCF,SB1->B1_COD)
Endif

Return(.t.)