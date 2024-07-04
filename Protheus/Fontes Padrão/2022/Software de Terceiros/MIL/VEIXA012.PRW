// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 25     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "VEIXA012.CH"
#include "PROTHEUS.CH"                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA012 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Saida de Veiculos por Devolucao de Compra                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA012()
Local cFiltro     := ""
Private cCadastro := STR0001 // Saida de Veiculos por Devolucao de Compra
Private aRotina   := MenuDef()
Private oOk   := LoadBitmap( GetResources(), "LBTIK" )                      
Private oNo   := LoadBitmap( GetResources(), "LBNO" )
Private aCores    := {}
Private cUsaGrVA := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
If ( VV0->(FieldPos("VV0_GERFIN")) > 0 ) // Campo que controla se gerou FINANCEIRO (Titulos)
	aAdd(aCores,{'VV0->VV0_SITNFI == "1" .AND. VV0->VV0_GERFIN <> "0"','BR_VERDE'})	// Valida
	aAdd(aCores,{'VV0->VV0_SITNFI == "1" .AND. VV0->VV0_GERFIN == "0"','f14_verd'}) // Valida com inconsistência no Financeiro
Else
	aAdd(aCores,{'VV0->VV0_SITNFI == "1"','BR_VERDE'})	// Valida
EndIf
aAdd(aCores,{'VV0->VV0_SITNFI == "0"','BR_VERMELHO'})	// Cancelada

//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
dbSetOrder(1)
//
cFiltro := " VV0_OPEMOV='4' " // Filtra as Devolucoes de Venda
//
mBrowse( 6, 1,22,75,"VV0",,,,,,aCores,,,,,,,,cFiltro)
//
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA012_X  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          ³±±
±±           ³ forçando a variável nOpc                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012_3(cAlias,nReg,nOpc)
VXA012(cAlias,nReg,3)
return

Function VXA012_2(cAlias,nReg,nOpc)
VXA012(cAlias,nReg,2)
return

Function VXA012_5(cAlias,nReg,nOpc)
VXA012(cAlias,nReg,5)
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA012   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012(cAlias,nReg,nOpc)
//
DBSelectArea("VV0")
if nOpc == 3 // INCLUSAO
	VA012BVV0()
else // VISUALIZACAO E CANCELAMENTO
	VEIXX001(,,,nOpc,"4")	// VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov)
endif
//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA002BRWVVF³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do Browse com as SAIDAS de Veiculos por Venda                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA012BVV0()
Local aRotinaX := aClone(aRotina)                                                        
Local aOpcoes  := {}
Private cBrwCond2 := 'VVF->VVF_OPEMOV$"01" .AND. VVF->VVF_SITNFI $ "13" .AND. !Empty(VVF->VVF_NUMNFI) .AND. VXA012FIL()' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
Private cFilVV1 := xFilial("VV1")
//
aAdd(aOpcoes,{STR0012,"VXA012DEV('"+cFilAnt+"')"}) // Devolver
//
dbSelectArea("VVF")
dbSetOrder(4)
//
cFilTop := "VVF_OPEMOV IN ('0','1') AND VVF_SITNFI IN ('1','3') AND VVF_NUMNFI<> ' ' AND "
cFilTop += "EXISTS ( "
cFilTop +=     " SELECT VVG.VVG_TRACPA "
cFilTop +=       " FROM "+RetSQLName("VVG")+" VVG "
cFilTop +=              " INNER JOIN "+RetSQLName("VV1")+" VV1 "
cFilTop +=                 " ON VV1.VV1_FILIAL  = '"+xFilial("VV1")+"'"
cFilTop +=                " AND VV1.VV1_CHASSI = VVG.VVG_CHASSI "
cFilTop +=                " AND VV1.VV1_ULTMOV = 'E' "
cFilTop +=                " AND VV1.VV1_FILENT = VVG.VVG_FILIAL "
cFilTop +=                " AND VV1.D_E_L_E_T_ = ' ' "
cFilTop +=     " WHERE VVG.VVG_FILIAL = '"+xFilial("VVG")+"'"
cFilTop +=       " AND VVG.VVG_TRACPA = VVF_TRACPA "
cFilTop +=       " AND VVG.D_E_L_E_T_ = ' ' ) "
FGX_LBBROW(cCadastro,"VVF",aOpcoes,cFilTop,"VVF_FILIAL,VVF_CODFOR,VVF_LOJA,VVF_NUMNFI,VVF_SERNFI","VVF_DATMOV")

aRotina := aClone(aRotinaX)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA012FIL ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o filtro do browse das ENTRADAS de veiculo por Devolucao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012FIL()
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
±±³Funcao    |VXA012DEV | Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a devolucao da nota fiscal selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012DEV(c_xFil)
Local nCntFor
Local xAutoCab := {}
Local xAutoItens := {}
Local xAutoAux := {}
Local nRecVVF := VVF->(RecNo())
Local nQtdDev := 0
Local cGruVei  := Left(GetMv("MV_GRUVEI")+space(TamSx3("B1_GRUPO")[1]),TamSx3("B1_GRUPO")[1]) // Grupo do Veiculo
Local lContEst := .T.
Local lCodTes := .T.
// Declaracao da ParamBox
Local aRet := {}
Local aParamBox := {}
Local i := 0    
Local lContabil := ( VVA->(FieldPos("VVA_CENCUS")) > 0 .and. VVA->(FieldPos("VVA_CONTA")) > 0 .and. VVA->(FieldPos("VVA_ITEMCT")) > 0 .and. VVA->(FieldPos("VVA_CLVL")) > 0 ) // Campos para a contabilizacao - VVA
//
Local aIndPre  := X3CBOXAVET("VV0_INDPRE","0")
Local aTipoFre := X3CBOXAVET("VV0_TPFRET","1")
//
Local oFornece   := OFFornecedor():New()
//
Default c_xFil := cFilAnt
cFilAnt := c_xFil
//
VVF->(dbClearFilter())
If &cBrwCond2 // Condicao do Browse 2, validar ao Devolver
	//
	If oFornece:Bloqueado( VVF->VVF_CODFOR , VVF->VVF_LOJA , .T. ) // Fornecedor Bloqueado ?
		Return .f.
	EndIf
	//
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
	aAdd(aParamBox,{11,RetTitle("VV0_OBSENF"),space(200),"","",.f.}) // MV_PAR12
	
	DBSelectArea("SA3")
	DBSetOrder(7)
	//
	if !DBSeek(xFilial("SA3")+__cUserId)
		MsgStop(STR0013,STR0011) //Usuario nao possui registro no cadastro de vendedor. Favor providenciar. ### Atencao
		Return .f.
	endif
	//
	aRet := FGX_SELVEI("VVF",STR0014,VVF->VVF_FILIAL,VVF->VVF_TRACPA,aParamBox,"VXA012VTES")
		//
	If Len(aRet) == 0 
		Return .f.
	Endif
	//
	aRet[1,12] := MV_PAR12 // Prencher MEMO no Vetor de Retorno da Parambox
    //
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array de integracao com o VEIXX001                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(xAutoCab,{"VV0_FILIAL"  ,xFilial("VVF")		,Nil})
	aAdd(xAutoCab,{"VV0_FORPRO"  ,"1"					,Nil})
	aAdd(xAutoCab,{"VV0_CODCLI"  ,VVF->VVF_CODFOR		,Nil})
	aAdd(xAutoCab,{"VV0_LOJA"    ,VVF->VVF_LOJA			,Nil})
	aAdd(xAutoCab,{"VV0_FORPAG"  ,VVF->VVF_FORPAG		,Nil})
	aAdd(xAutoCab,{"VV0_CODVEN"  ,SA3->A3_COD			,Nil})
	aAdd(xAutoCab,{"VV0_NATFIN"  ,VVF->VVF_NATURE		,Nil})
	aAdd(xAutoCab,{"VV0_INDPRE"  ,aRet[1,1]				,Nil})

	If VV0->(FieldPos("VV0_PESOL")) > 0
		aAdd(xAutoCab,{"VV0_PESOL"   ,aRet[1,2]				,Nil})
	EndIf
	If VV0->(FieldPos("VV0_PBRUTO")) > 0
		aAdd(xAutoCab,{"VV0_PBRUTO"  ,aRet[1,3]				,Nil})
	EndIf
	If VV0->(FieldPos("VV0_VOLUME")) > 0
		aAdd(xAutoCab,{"VV0_VOLUME"  ,aRet[1,4]				,Nil})
	EndIf
	If VV0->(FieldPos("VV0_ESPECI")) > 0
		aAdd(xAutoCab,{"VV0_ESPECI"  ,aRet[1,5]				,Nil})
	EndIf
	If VV0->(FieldPos("VV0_VEICUL")) > 0
		aAdd(xAutoCab,{"VV0_VEICUL"  ,aRet[1,6]				,Nil})
	EndIf
	If VV0->(FieldPos("VV0_SEGURO")) > 0
		aAdd(xAutoCab,{"VV0_SEGURO"  ,aRet[1,7]				,Nil})
	EndIf
	
	aAdd(xAutoCab,{"VV0_CODTRA"  ,aRet[1,8]				,Nil})
	aAdd(xAutoCab,{"VV0_DESACE"  ,aRet[1,9]				,Nil})
	aAdd(xAutoCab,{"VV0_VALFRE"  ,aRet[1,10]				,Nil})
	aAdd(xAutoCab,{"VV0_TPFRET"  ,aRet[1,11]				,Nil})
	aAdd(xAutoCab,{"VV0_OBSENF"  ,aRet[1,12]				,Nil})
	aAdd(xAutoCab,{"VV0_CLIFOR"  ,"F"   				,Nil})
	//
	DBSelectArea("VVG")
	DBSetOrder(1)
	//
	If Len(aRet[2]) == 0
		MsgStop(STR0016,STR0011) //Não existe(m) veiculos(s) para o registro selecionado! ### Atencao
		Return .f.
	Endif
	//
	For i := 1 to Len(aRet[2])
		If aRet[2,i,1] // Veículo está selecionado
			nQtdDev++
			DBSelectArea("VVG")
			DbGoto(aRet[2,i,2])
		
			if !FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
				Help(" ",1,"VEINFNEXCD")
				nOpca := 0
				Return .f.
			Endif
		
			if VV1->VV1_ULTMOV == "S" .or. VV1->VV1_FILENT != VVF->VVF_FILIAL // .or. VV1->VV1_TRACPA != VVF->VVF_TRACPA
				DbSkip()
				Loop
			Endif

			lTemAlgum := .t.
			xAutoIt := {}
			aAdd(xAutoIt,{"VVA_FILIAL"  ,xFilial("VVG")	,Nil})
			aAdd(xAutoIt,{"VVA_CHASSI"  ,VVG->VVG_CHASSI,Nil})
			aAdd(xAutoIt,{"VVA_VALMOV"  ,VVG->VVG_VALUNI,Nil})
			aAdd(xAutoIt,{"VVA_SEGVIA"  ,VVG->VVG_TOTSEG,Nil})
			aAdd(xAutoIt,{"VVA_VALFRE"  ,VVG->VVG_TOTFRE,Nil})
			aAdd(xAutoIt,{"VVA_DESVEI"  ,VVG->VVG_DESACE,Nil})
			aAdd(xAutoIt,{"VVA_CODTES"  ,aRet[2,i,3]	,Nil})
			if lContabil
				aAdd(xAutoIt,{"VVA_CENCUS"  ,aRet[2,i,8],Nil})
				aAdd(xAutoIt,{"VVA_CONTA"   ,aRet[2,i,9],Nil})
				aAdd(xAutoIt,{"VVA_ITEMCT"  ,aRet[2,i,10],Nil})
				aAdd(xAutoIt,{"VVA_CLVL"    ,aRet[2,i,11],Nil})
			Endif
			//
			aAdd(xAutoItens,xAutoIt)
			// MONTA ARRAY AUXILIAR COM INFORMACOES DE CONTROLE DE RETORNO (ITEMSEQ, IDENTB6, ETC)
			xAutoIt := {}
			If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
				FMX_HELP("VA017E01", STR0029 ) //  Veiculo Nao encontrado
				Return .f.
			endif
			If cUsaGrVA == "1" // Usa Veiculos de forma Agrupada por Modelo no SB1
				If !FGX_VV2SB1(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
					MsgStop(STR0031,STR0011) // 
					Return .f.
				Endif
			Endif
			DBSelectArea("SD1")                             
			DBSetOrder(1)
			if !DBSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
				MsgInfo(STR0030,STR0027+": VA017E02")
				Return .f.
			endif
			////////////////////////////////////////////////////////////
			// Verifica se o chassi foi movimentado por outro módulo, o
			// que deixa o veículo sem estoque, no entanto com o Status
			// de Estoque no módulo de Veiculos (VV1_SITVEI)
			////////////////////////////////////////////////////////////
			//Antes verifico se a TES controla estoque.
			lCodTes := VXA012TORI(xFilial("SD1"), VVF->VVF_NUMNFI , VVF->VVF_SERNFI , VVF->VVF_CODFOR , VVF->VVF_LOJA, VVF->VVF_DATEMI, SB1->B1_COD)

			DBSelectArea("SF4")
			DBSetOrder(1)
			DBSeek(xFilial("SF4")+aRet[2,i,3])
			lContEst := IIf(SF4->F4_ESTOQUE=="S",.T.,.F.)

			If lContEst # lCodTes // TES (F4_ESTOQUE) diferente entre a Entrada e a Devolução da Entrada
					MsgStop( STR0040 +;
					Chr(13)+Chr(10),STR0011) // "Impossível Continuar! Situação de Estoque do TES da Compra, difere do TES da Devolução!" // Atenção
				Return .f.
			Endif

			DbSelectArea("SB2")
			dbSetOrder(1)
			DBSeek(xFilial("SB2")+SB1->B1_COD+VVG->VVG_LOCPAD)
				
				If SaldoSB2() <= 0
					MsgStop( STR0039 +;
					Chr(13)+Chr(10)+Left(RetTitle("VV1_CHASSI"),7)+": "+VV1->VV1_CHASSI+Chr(13)+Chr(10)+Left(RetTitle("B5_COD"),7)+": "+SB1->B1_COD,STR0011) // "Impossível Continuar! Não existe Saldo Disponivel para esta movimentação! Favor verificar se houve movimentação deste produto fora do Módulo de Veículos!" // Atenção
					Return .f.
				Endif
			//
			aAdd(xAutoIt,{"C6_NFORI"   ,SD1->D1_DOC		,Nil})
			aAdd(xAutoIt,{"C6_SERIORI" ,SD1->D1_SERIE		,Nil})
			aAdd(xAutoIt,{"C6_ITEMORI" ,SD1->D1_ITEM		,Nil})
			//
			aAdd(xAutoAux,xAutoIt)
			//
		Endif
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a integracao com o VEIXX001                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	lMsErroAuto := .f.
	//
	MSExecAuto({|x,y,w,z,k,l| VEIXX001(x,y,w,z,k,l)},xAutoCab,xAutoItens,{},3,"4",xAutoAux )
	//
	If !(nQtdDev == Len(aRet[2])) // A Devolucao foi Parcial
		DBSelectArea("VVF")
		DBGoTo(nRecVVF)
		reclock("VVF",.f.)
		VVF->VVF_SITNFI := "1"
		msunlock()
	Endif
	//
	if lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Saida de Veiculos por Devolucao de Compra             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{ STR0004 ,"VXA012_3"		, 0 , 3,,.f.})		//Devolver
aAdd(aRotina,{ STR0002 ,"AxPesqui"		, 0 , 1})			//Pesquisar
aAdd(aRotina,{ STR0003 ,"VXA012_2"		, 0 , 2})			//Visualizar
aAdd(aRotina,{ STR0005 ,"VXA012_5"		, 0 , 5,,.f.})		//Cancelar
aAdd(aRotina,{ STR0006 ,"VXA012LEG"		, 0 , 6})			//Legenda
aAdd(aRotina,{ STR0032 ,"VXA012TIT"		, 0 , 4})			// Gerar Financeiro
aAdd(aRotina,{ STR0007 ,"FGX_PESQBRW('S','4')" , 0 , 1})	// Pesquisa Avancada ( E-Saida por 5-Devolucao de Compra )
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA012LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Saida de Veiculos por Devolucao de Compra                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012LEG()
Local aLegenda := {}
aAdd(aLegenda,{'BR_VERDE',STR0008})		// Valida
aAdd(aLegenda,{'f14_verd',STR0033})		// Valida com inconsistência no Financeiro
aAdd(aLegenda,{'BR_VERMELHO',STR0009})	// Cancelada
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Saida de Veiculos por Retorno de remessa              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012VTES(cCodTes)

DBSelectArea("SF4")
DBSetOrder(1)
DBSeek(xFilial("SF4")+cCodTes)
cPoder3 := SF4->F4_PODER3
cEstoque := SF4->F4_ESTOQUE
DBSelectArea("VVG")
DBSetOrder(1)
DBSeek(VVF->VVF_FILIAL+VVF->VVF_TRACPA)
DBSelectArea("SF4")
DBSetOrder(1)
DBSeek(xFilial("SF4")+VVG->VVG_CODTES)
if SF4->F4_PODER3=="S"
	cMsg := STR0021
else
	cMsg := STR0022
endif
//
if SF4->F4_ESTOQUE=="S"
	cMsg += STR0023
else
	cMsg += STR0024
endif
//
if cPoder3 != SF4->F4_PODER3 .and. cEstoque != SF4->F4_ESTOQUE
	MsgInfo(STR0025 + cMsg + STR0026,STR0011)
	return .f.
endif

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA012TIT ³ Autor ³ Andre Luis Almeida                ³ Data ³ 30/11/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Refaz Financeiro somente se deu problema no momento da geracao da NF   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012TIT()
If VV0->VV0_SITNFI == "1" // Valida
	If ( VV0->(FieldPos("VV0_GERFIN")) > 0 ) .and. VV0->VV0_GERFIN == "0" // Existe o campo e 0=NAO gerou Financeiro
		If MsgYesNo(STR0034,STR0011) // Deseja gerar o Financeiro desta Saida por Devolução de Compra? / Atencao
			If VXX001TIT() // Gerar Financeiro ( VEIXX001 - Saidas )
				MsgInfo(STR0035,STR0011) // Financeiro da Saida por Devolução de Compra gerado com sucesso. / Atencao
			Else
				MsgAlert(STR0036,STR0011) // Existe(m) inconsistência(s) na Geração dos Titulos. Favor corrigir a(s) pendência(s) para solicitar novamente a Geração do Financeiro. / Atencao
			EndIf
		EndIf
	Else
		MsgInfo(STR0037,STR0011) // Financeiro já existente para a Saida por Devolução de Compra. / Atencao
	EndIf
Else
	MsgStop(STR0038,STR0011) // A Saida por Devolução de Compra não esta Valida. Impossivel continuar! / Atencao
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA012TORI ³Autor ³Jose Luis                         ³ Data ³ 28/08/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna TES da NF de Origem                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA012TORI(_cFilial, _cDocNfe , _cSerNfe , _cCodCli , _cCodLoj, _dDatEmis, _cCodVei )
Local cQuery := ""
Local lTesOri := ""

	cQuery := "SELECT SF4.F4_ESTOQUE"
	cQuery += "  FROM " + RetSqlName('SD1')+" SD1 "
	cQuery += "  JOIN " + RetSqlName('SF4')+" SF4 "
	cQuery += "    ON ( SF4.F4_FILIAL = '"+xFilial("SF4")+"'"
	cQuery += "   AND SF4.F4_CODIGO  = SD1.D1_TES "
	cQuery += "   AND SF4.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE SD1.D1_FILIAL  = '"+ _cFilial +"'"
	cQuery += "   AND SD1.D1_DOC     = '"+ _cDocNfe +"'"
	cQuery += "   AND SD1.D1_SERIE   = '"+ _cSerNfe +"'"
	cQuery += "   AND SD1.D1_FORNECE = '"+ _cCodCli +"'"
	cQuery += "   AND SD1.D1_LOJA    = '"+ _cCodLoj +"'"
	cQuery += "   AND SD1.D1_EMISSAO = '"+ DtoS(_dDatEmis) +"'"
	cQuery += "   AND SD1.D1_COD     = '"+ _cCodVei +"'"
	cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY SD1.R_E_C_N_O_ DESC"

	lTesOri := iif(FM_SQL(cQuery)=="S", .T., .F.)

Return lTesOri
