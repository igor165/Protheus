// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 5      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "VEIXA007.CH"
#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA027 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrada de Veiculos por Retorno de Consignacao (fonte duplicado do VEIXA007)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA027()
Private cCadastro := STR0001 // Entrada de Veiculos por Retorno de Consignacao
Private aRotina   := MenuDef()
Private aCores    := {;
{'VVF->VVF_SITNFI == "1"','BR_VERDE'},;		// Valida
{'VVF->VVF_SITNFI == "0"','BR_VERMELHO'},;	// Cancelada
{'VVF->VVF_SITNFI == "2"','BR_PRETO'}}			// Devolvida
Private cBrwCond := 'VVF->VVF_OPEMOV=="8"' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVF")
dbSetOrder(1)
//
FilBrowse('VVF',{},'VVF->VVF_OPEMOV=="8"')
mBrowse( 6, 1,22,75,"VVF",,,,,,aCores)
dbClearFilter()
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA007A  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Entrada de Veiculos por Retorno de Consignacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007A(cAlias,nReg,nOpc)
//
//If &cBrwCond // Condicao do Browse, validar ao Incluir/Alterar/Excluir
	If nOpc == 3 // INCLUSAO
		VXA007BRVV0()
	Else // VISUALIZACAO E CANCELAMENTO
		DBSelectArea("VVF")
		dbclearfilter()
		VEIXX000(,,,nOpc,"8",,,"C")	// VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov)
		FilBrowse('VVF',{},'VVF->VVF_OPEMOV=="8"')
	EndIf
//EndIf
//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA007BRVV0 ³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Retorno de Consignacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007BRVV0()
Local aRotinaX := aClone(aRotina)
Local aCampos := {;
{RetTitle("VV0_NUMNFI"),	"VV0_NUMNFI"	},;
{FGX_MILSNF("VV0", 7, "VV0_SERNFI"),	FGX_MILSNF("VV0", 3, "VV0_SERNFI")},;
{RetTitle("VV0_DATMOV"),	"VV0_DATMOV"	},;
{RetTitle("VV0_CODCLI"),	"VV0_CODCLI"	},;
{RetTitle("VV0_LOJA"),		"VV0_LOJA"		},;
{RetTitle("VV0_NOMCLI"),	"VV0_NOMCLI"	}}
Private cBrwCond2 := 'VV0->VV0_OPEMOV=="5" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. xFilial("VV0")==VV0->VV0_FILIAL .AND. VXA007FILA()' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//
aRotina := {;
{ STR0002 ,"axPesqui", 0 , 1,,.f.},;		// Pesquisar
{ STR0012 ,"VXA007DEVA('"+cFilAnt+"')", 0 , 1,,.f.}}	// Retornar
//
dbSelectArea("VV0")
dbSetOrder(4)
//
FilBrowse('VV0',{},'VV0->VV0_OPEMOV=="5" .AND. VV0->VV0_SITNFI=="1" .AND. !Empty(VV0->VV0_NUMNFI) .AND. xFilial("VV0")==VV0->VV0_FILIAL .AND. VXA007FILA()')
mBrowse( 6, 1,22,75,"VV0",aCampos,,,,,)
dbClearFilter()
aRotina := aClone(aRotinaX)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA007FILA³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o filtro do browse das SAIDAS de veiculo por remessa           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007FILA(c_xFil)
Local lRet := .f.
//
Default c_xFil := cFilAnt
cFilAnt := c_xFil
//

//
VVA->(DbSetOrder(1))
VVA->(DBSeek(xFilial("VVA")+VV0->VV0_NUMTRA))
VV1->(DbSetOrder(2))
VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
// Verifica se a ultima movimentacao do veiculo foi o VV0 em questao ( SAIDA por Transferencia )
If VV1->VV1_ULTMOV == "S" .and. VV1->VV1_FILSAI == xFilial("VV0") .and. VV1->VV1_NUMTRA == VV0->VV0_NUMTRA
	lRet := .t.
EndIf
//
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA007DEVA| Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a devolucao da nota fiscal selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007DEVA()
Local xAutoCab := {}
Local xAutoItens := {}
Local xAutoAux := {}
Local nRecVV0 := VV0->(RecNo())
Local cGruVei  := Left(GetMv("MV_GRUVEI")+space(TamSx3("B1_GRUPO")[1]),TamSx3("B1_GRUPO")[1]) // Grupo do Veiculo
// Declaracao da ParamBox
Local aRet := {}
Local aParamBox := {}
If &cBrwCond2 // Condicao do Browse 2, validar ao Devolver
	aAdd(aParamBox,{2,"Formulário Próprio","Não",{"Sim","Não"},80,"",.T.}) 
	aAdd(aParamBox,{1,STR0013,space(TamSX3("VV0_NUMNFI")[1]),"","","","MV_PAR01='Não'",0,.F.}) // Nota Fiscal
	aAdd(aParamBox,{1,STR0014,space(FGX_MILSNF("VV0", 6, "VV0_SERNFI")),"","","","MV_PAR01='Não'",0,.F.}) // Serie
	aAdd(aParamBox,{1,"Data Emissão",ddatabase,"@D","","","MV_PAR01='Não'",0,.T.})
	aAdd(aParamBox,{1,STR0015,Space(TamSX3("F4_CODIGO")[1]),"","VXA007TES()","SF4","",0,.T.}) // TES
	aAdd(aParamBox,{1,STR0016,Space(TamSX3("VVG_SITTRI")[1]),"","","S0","",0,.T.}) // Sit.Tributaria
	aAdd(aParamBox,{1,"Natureza",Space(TamSX3("VVF_NATURE")[1]),"","","SED","",0,.F.}) // Sit.Tributaria
	//
	lPassou := .f.
	while !lPassou
		lPassou := .t.
		//
		If !(ParamBox(aParamBox,STR0017,@aRet))//Dados do Retorno de Remessa
			return
		Endif
		if aRet[1] == "Não" .and. Empty(aRet[2])
			MsgInfo("Digite o número e série da NF quando for formulário de terceiros.","Atencao")
			lPassou := .f.
		endif
		DBSelectArea("SF4")
		DBSetOrder(1)
		DBSeek(xFilial("SF4")+MV_PAR05)
		if SF4->F4_DUPLIC =="S" .and. Empty(MV_PAR07)
			MsgInfo("A Natureza é obrigatória para TES que geram duplicata.","Atencao")
			lPassou := .f.
		endif
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array de integracao com o VEIXX000                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")		,Nil})
	if aRet[1] == "Não"
		aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"   		 		,Nil})
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,aRet[2]				,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,aRet[3]				,Nil})
	else
		aAdd(xAutoCab,{"VVF_FORPRO"  ,"1"   		 		,Nil})
	endif
	aAdd(xAutoCab,{"VVF_CODFOR"  ,VV0->VV0_CODCLI	,Nil})
	aAdd(xAutoCab,{"VVF_DATEMI"  ,aRet[4]	,Nil})
	aAdd(xAutoCab,{"VVF_NATURE"  ,aRet[7]	,Nil})	
	aAdd(xAutoCab,{"VVF_LOJA"    ,VV0->VV0_LOJA		,Nil})
	aAdd(xAutoCab,{"VVF_FORPAG"  ,VV0->VV0_FORPAG	,Nil})
	//
	DBSelectArea("VVA")
	DBSetOrder(1)
	DBSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	//
	While !eof() .and. xFilial("VVA")+VV0->VV0_NUMTRA == VVA->VVA_FILIAL + VVA->VVA_NUMTRA
		DBSelectArea("VV1")
		DBSetOrder(2)
		DBSeek(xFilial("VV1")+VVA->VVA_CHASSI)
		xAutoIt := {}
		aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")		,Nil})
		aAdd(xAutoIt,{"VVG_CHASSI"  ,VVA->VVA_CHASSI 	,Nil})
		aAdd(xAutoIt,{"VVG_CODTES"  ,aRet[5]				,Nil})
		aAdd(xAutoIt,{"VVG_LOCPAD"  ,VV1->VV1_LOCPAD		,Nil})
		aAdd(xAutoIt,{"VVG_SITTRI"  ,aRet[6]				,Nil})
		aAdd(xAutoIt,{"VVG_VALUNI"  ,VVA->VVA_VALMOV		,Nil})
		aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"						,Nil})
		//
		aAdd(xAutoItens,xAutoIt)
		// MONTA ARRAY AUXILIAR COM INFORMACOES DE CONTROLE DE RETORNO (ITEMSEQ, IDENTB6, ETC)
		xAutoIt := {}
		If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			FMX_HELP("VA027E01", STR0039) // Veiculo nao encontrado
			Return .f.
		endif
		DBSelectArea("SD2")
		DBSetOrder(3)
		if !DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
			MsgInfo(STR0040,STR0019+": VA007E02")//Ocorreu um erro inesperado. Favor contactar o administrador do sistema. ### Codigo
			Return .f.
		endif
		//
		aAdd(xAutoIt,{"D1_NFORI"   ,SD2->D2_DOC,Nil})
		aAdd(xAutoIt,{"D1_SERIORI" ,SD2->D2_SERIE,Nil})
	   aAdd(xAutoIt,{"D1_IDENTB6" ,SD2->D2_IDENTB6,Nil})	
		//
		aAdd(xAutoAux,xAutoIt)
		DBSelectArea("VVA")
		DBSkip()
	enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a integracao com o VEIXX000                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	lMsErroAuto := .f.
	//
	MSExecAuto({|x,y,w,z,k,l| VEIXX000(x,y,w,z,k,l,,"C")},xAutoCab,xAutoItens,{},3,"8",xAutoAux )
	//
	if lMsErroAuto
		DisarmTransaction()
		MostraErro()
		return .f.
		
	Endif
	//
EndIf
//
Return .t.
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
Function VXA007TES()
    
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+MV_PAR05)
	cPoder3 := SF4->F4_PODER3
	cEstoque := SF4->F4_ESTOQUE
	DBSelectArea("VVA")
	DBSetOrder(1)
	DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+VVA->VVA_CODTES)
	if SF4->F4_PODER3=="S"
		cMsg := " deve controlar poder de terceiros e "
	else
		cMsg := " não deve controlar poder de terceiros e "
	endif
	//
	if SF4->F4_ESTOQUE=="S"
		cMsg += " movimentar estoque "
	else
		cMsg += " não movimentar estoque "
	endif
	//
	if cPoder3 != SF4->F4_PODER3 .and. cEstoque != SF4->F4_ESTOQUE
		MsgInfo("O Tes de entrada " + cMsg + "segundo a saída.","Atencao")
		return .f.
	endif
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
{ OemtoAnsi(STR0003) ,"VXA007A"     		, 0 , 2},;		// Visualizar
{ OemtoAnsi(STR0004) ,"VXA007A"    		, 0 , 3},;		// Devolver
{ OemtoAnsi(STR0005) ,"VXA007A"    	 	, 0 , 5},;		// Cancelar
{ OemtoAnsi(STR0006) ,"VXA007LEGA" 	 	, 0 , 6},;		// Legenda
{ OemtoAnsi(STR0007) ,"FGX_PESQBRW('E','8')" , 0 , 2}}	// Pesquisa Avancada ( E-Entrada por 8-Retorno de Consignacao )
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA007LEGA³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Retorno de Consignacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA007LEGA()
Local aLegenda := {;
{'BR_VERDE',STR0008},;
{'BR_VERMELHO',STR0009},;
{'BR_PRETO',STR0010}}
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return
