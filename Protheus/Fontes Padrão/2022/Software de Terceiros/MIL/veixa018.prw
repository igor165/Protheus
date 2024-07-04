#include "PROTHEUS.CH"
#include "VEIXA018.CH"

Static lIntLoja := ( Substr(GetNewPar("MV_LOJAVEI","NNN"),3,1) == "S" )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA018 ³ Autor ³ Andre Luis Almeida / Rubens       ³ Data ³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atendimento de Veiculos                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA018(lNoMBrowse,aRecInter)
Local cFiltro     := ""
Local cFilUser    := ""
Local aRegs       := {}
Local aCoresUsr   := {}
Local cMV_MIL0047 := GetNewPar("MV_MIL0047","") // Orcamento: Vendedor
Local cMV_MIL0048 := GetNewPar("MV_MIL0048","") // Orcamento: Tipo de Tempo Interno
Local cMV_MIL0049 := GetNewPar("MV_MIL0049","")	// Orcamento: Tipo de Tempo Cliente
Local cMV_MIL0050 := GetNewPar("MV_MIL0050","") // Vendedor da integracao com o Venda Direta
Private cCadastro := STR0001
Private aRotina   := MenuDef()
Private aCores    := {}
Private oBrowse
Private cMotivo   := "000001"
Default lNoMBrowse := .f.
Default aRecInter  := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
aAdd(aCores,{'VV9->VV9_STATUS == "A" .AND.  VXA018VEIVD()','lbok_ocean'})		// Em Aberto com Veiculo ja Vendido
aAdd(aCores,{'VV9->VV9_STATUS == "A" .AND. !VXA018VEIVD()','BR_VERDE'})			// Em Aberto
aAdd(aCores,{'VV9->VV9_STATUS == "P"','BR_AMARELO'})							// Pendente de Aprovacao
aAdd(aCores,{'VV9->VV9_STATUS == "O"','BR_BRANCO'})								// Pre-Aprovado
aAdd(aCores,{'VV9->VV9_STATUS == "L"','BR_AZUL'})								// Aprovado
aAdd(aCores,{'VV9->VV9_STATUS == "R"','BR_LARANJA'})							// Reprovado
If ( VV0->(ColumnPos("VV0_GERFIN")) > 0 ) // Campo que controla se gerou FINANCEIRO (Titulos)
	aAdd(aCores,{'VV9->VV9_STATUS == "F" .AND.  VXA018TEMFIN()','BR_PRETO'})	// Finalizado
	aAdd(aCores,{'VV9->VV9_STATUS == "F" .AND. !VXA018TEMFIN()','f14_pret'})	// Finalizado com inconsistência no Financeiro
Else
	aAdd(aCores,{'VV9->VV9_STATUS == "F"','BR_PRETO'})							// Finalizado
EndIf
aAdd(aCores,{'VV9->VV9_STATUS == "C"','BR_VERMELHO'})							// Cancelado
//
//////////////////////////////////////////////////////////////////////////////
// Ponto de Entrada para manipular o aCores ( VV9_STATUS )                  //
//////////////////////////////////////////////////////////////////////////////
If 	( ExistBlock("VM011LEG") )
	aCoresUsr := ExecBlock("VM011LEG",.F.,.F.,{aCores,"C"})
	If ( ValType(aCoresUsr) == "A" )
		aCores := aClone(aCoresUsr)
	EndIf
EndIf

//////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos //
//////////////////////////////////////////////////////////////////////////////
If !AMIIn(11) .or. !FMX_AMIIN({"VEIXA018"})
	Return()
EndIf

///////////////////////////////////////////////////////////////
// Acerta PERGUNTE VXA018 ( retirada do Faturamento Direto ) //
///////////////////////////////////////////////////////////////
DbSelectArea("SX1")
DbSetOrder(1)
If DbSeek(PadR("VXA018",len(SX1->X1_GRUPO)," ")+"12")
	RecLock("SX1",.f.,.t.)
		dbDelete()
	MsUnLock()	
	DbSelectArea("SX1")
	DbSetOrder(1)
	If DbSeek(PadR("VXA018",len(SX1->X1_GRUPO)," ")+"08")
		RecLock("SX1",.f.,.t.)
			dbDelete()
		MsUnLock()	
    EndIf
	PutHelp("P.VXA01808.",{STR0087,STR0088,STR0089,STR0090,STR0091,STR0092},{},{},.T.) // Ajusta HELP
EndIf
DbSelectArea("SX1")
DbSetOrder(1)
If DbSeek(PadR("VXA018",len(SX1->X1_GRUPO)," ")+"09")
	if Alltrim(SX1->X1_VALID) <> 'Vazio() .or. (FMX_TESTIP(MV_PAR09) == "S")'
		RecLock("SX1",.f.,.t.)
		dbDelete()
		MsUnLock()	
	Endif
Endif
DbSelectArea("SX1")
DbSetOrder(1)
If DbSeek(PadR("VXA018",len(SX1->X1_GRUPO)," ")+"10")
	if Alltrim(SX1->X1_VALID) <> 'Vazio() .or. (FMX_TESTIP(MV_PAR10) == "S")'
		RecLock("SX1",.f.,.t.)
		dbDelete()
		MsUnLock()	
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte para Configuracao da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aRegs,{STR0010, "", "", "mv_ch1", "C", SFM->(TamSx3("FM_TIPO")[1])   , 0, 0, "G", 'Vazio() .or. ExistCpo("SX5","DJ"+MV_PAR01)'                 , "mv_par01", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "DJ " , "" , "" , "" ,{STR0011,STR0012,STR0013,STR0014},{},{}})
AADD(aRegs,{STR0015, "", "", "mv_ch2", "C", SFM->(TamSx3("FM_TIPO")[1])   , 0, 0, "G", 'Vazio() .or. ExistCpo("SX5","DJ"+MV_PAR02)'                 , "mv_par02", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "DJ " , "" , "" , "" ,{STR0016,STR0017,STR0018,STR0019},{},{}})
AADD(aRegs,{STR0020, "", "", "mv_ch3", "C", SA1->(TamSx3("A1_COD")[1])    , 0, 0, "G", 'Vazio() .or. ExistCpo("SA1",MV_PAR03+AllTrim(MV_PAR04),1)'  , "mv_par03", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , "001" , "" , "" ,{STR0021,STR0022},{},{}})
AADD(aRegs,{STR0023, "", "", "mv_ch4", "C", SA1->(TamSx3("A1_LOJA")[1])   , 0, 0, "G", 'Vazio() .or. ExistCpo("SA1",MV_PAR03+MV_PAR04,1)'           , "mv_par04", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "   " , "002" , "" , "" ,{STR0024,STR0025},{},{}})
AADD(aRegs,{STR0026, "", "", "mv_ch5", "C", SA3->(TamSx3("A3_COD")[1])    , 0, 0, "G", 'Vazio() .or. ExistCpo("SA3",MV_PAR05)'                      , "mv_par05", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA3" , "" , "" , "" ,{STR0027,STR0028,STR0029},{},{}})
AADD(aRegs,{STR0030, "", "", "mv_ch6", "C", VOI->(TamSx3("VOI_TIPTEM")[1]), 0, 0, "G", 'Vazio() .or. ExistCpo("VOI",MV_PAR06)'                      , "mv_par06", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VOI" , "" , "" , "" ,{STR0031,STR0032,STR0033},{},{}})
AADD(aRegs,{STR0034, "", "", "mv_ch7", "C", VOI->(TamSx3("VOI_TIPTEM")[1]), 0, 0, "G", 'Vazio() .or. ExistCpo("VOI",MV_PAR07)'                      , "mv_par07", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VOI" , "" , "" , "" ,{STR0035,STR0036,STR0037},{},{}})
AADD(aRegs,{STR0086, "", "", "mv_ch8", "C", SA3->(TamSx3("A3_COD")[1])    , 0, 0, "G", 'Vazio() .or. ExistCpo("SA3",MV_PAR08)'                      ,"mv_par08", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA3" , "" , "" , "" ,{STR0087,STR0088,STR0089,STR0090,STR0091,STR0092},{},{}})
AADD(aRegs,{STR0066, "", "", "mv_ch9", "C", SF4->(TamSx3("F4_CODIGO")[1]) , 0, 0, "G", 'Vazio() .or. (FMX_TESTIP(MV_PAR09) == "S")', "mv_par09", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SF4" , "" , "" , "" ,{STR0068,STR0070,STR0071},{},{}})
AADD(aRegs,{STR0067, "", "", "mv_cha", "C", SF4->(TamSx3("F4_CODIGO")[1]) , 0, 0, "G", 'Vazio() .or. (FMX_TESTIP(MV_PAR10) == "S")', "mv_par10", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SF4" , "" , "" , "" ,{STR0069,STR0070,STR0071},{},{}})
AADD(aRegs,{STR0080, "", "", "mv_chb", "N", 1                              , 0, 1, "C", ''                               , "mv_par11", STR0084, STR0084 , STR0084 , "" , "" , STR0085 , STR0085 , STR0085 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {STR0081,STR0082,STR0083},{},{}})

Pergunte("VXA018",.f.,,,,.f.)    

While .t.
	If 	Empty(MV_PAR03) .or. ;	// Cliente Padrao
		Empty(MV_PAR04) .or. ;	// Loja Cliente Padrao
	    (Empty(MV_PAR05) .and. Empty(cMV_MIL0047)) .or. ;	// Orcamento: Vendedor
		(Empty(MV_PAR06) .and. Empty(cMV_MIL0048)) .or. ;	// Orcamento: Tipo de Tempo Interno
		(Empty(MV_PAR07) .and. Empty(cMV_MIL0049)) .or. ;	// Orcamento: Tipo de Tempo Cliente
		( lIntLoja .and. Empty(MV_PAR08) .and. Empty(cMV_MIL0050)) .or. ;	// Vendedor da integracao com o Venda Direta
		Empty(MV_PAR09) .or. ;	// TES default Veiculos Novos
		Empty(MV_PAR10)	.or. ;	// TES default Veiculos Usados
		Empty(MV_PAR11)		 	// Mostra Parametros Faturamento
		If !Pergunte("VXA018",.T.,,,,.f.)
			Return()
		EndIf
	Else
		Exit
	EndIf
EndDo

If ExistBlock("VEI018FBRW") // Ponto de Entrada para Filtro no Browse
	cFilUser := ExecBlock("VEI018FBRW",.F.,.F.)
Endif

SetKey(VK_F12,{ || Pergunte( "VXA018" , .T. ,,,,.f.)})
//
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
DbSelectArea("VV9")
DbSetOrder(1)

If lNoMBrowse
	If ( nOpc <> 0 ) .and. !Deleted()		
		bBlock := &( "{ |a,b,c,d| " + aRotina[ nOpc,2 ] + "(a,b,c,d) }" )
		Eval( bBlock , Alias() , (Alias())->(Recno()) , nOpc , aRecInter )
	EndIf
Else
	////////////////////////////////////////////////////////////////////////
	// Filtro do Browse - NAO visualiza Atendimentos de outros vendedores //
	////////////////////////////////////////////////////////////////////////
	cFiltro := " EXISTS ( SELECT VV0.VV0_CODVEN FROM "+RetSQLName("VV0")+" VV0 WHERE "
	cFiltro += "VV0.VV0_FILIAL=VV9_FILIAL AND VV0.VV0_NUMTRA=VV9_NUMATE AND VV0.VV0_TIPFAT<>'2' AND "
	If Empty(VAI->VAI_ATEOUT) .or. VAI->VAI_ATEOUT == "0" // Nao Visualiza Atendimentos de outros vendedores
		cFiltro += "VV0.VV0_CODVEN='"+VAI->VAI_CODVEN+"' AND " // NAO visualiza Atendimentos de outros vendedores
	EndIf
	cFiltro += "VV0.D_E_L_E_T_=' ') "
	cFiltro	+=	IIf( !Empty(cFilUser) , ' AND ' + cFilUser , "" )
	mBrowse( 6, 1,22,75,"VV9",,,,,,aCores,,,,,,,,cFiltro,,,,, { |oBrowse| VXA018BrwAct(oBrowse) } )
EndIf

DbSelectArea("VV9")

SetKey(VK_F12,Nil)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA018?  ³ Autor ³ Andre Luis Almeida / Rubens       ³ Data ³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Saida de Veiculos por Venda                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018V(cAlias,nReg,nOpc)
nOpc := 2 // Visualizar
VXA018(cAlias,nReg,nOpc)
Return()
//
Function VXA018I(cAlias,nReg,nOpc,aRecInter)
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
nOpc := 3 // Incluir
VXA018(cAlias,nReg,nOpc,aRecInter)
Return()
//
Function VXA018A(cAlias,nReg,nOpc)
nOpc := 4 // Alterar
VXA018(cAlias,nReg,nOpc)
Return()
//
Function VXA018C(cAlias,nReg,nOpc)
nOpc := 5 // Cancelar
VXA018(cAlias,nReg,nOpc)
Return()
///////////////////////////////////////////////////////
// Montagem da Janela de Saida de Veiculos por Venda //
///////////////////////////////////////////////////////
Function VXA018(cAlias,nReg,nOpc,aRecInter)
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
DbSelectArea("VV9")
If nOpc == 4 .or. nOpc == 5
	If !Softlock("VV9")
		Return .f.
	EndIf
EndIf
//
SetKey(VK_F12,Nil)
//
VEIXX002(NIL,NIL,NIL,nOpc,aRecInter)
//
SetKey(VK_F12,{ || Pergunte( "VXA018" , .T. ,,,,.f.)})
//
MsUnlockAll()
//
SA1->(MsUnlock()) // Nao remover, pois quando integrado com o Venda Direta o registro permanecia bloqueado
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA018P  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 22/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pre Atendimento ( inclusao simplificada do VV9 / VV0 / VVA )           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018PRE()
nOpc := 4 // Alterar
VXX002PRE()
nOpc := 1
DbSelectArea("VV9")
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA018F  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 13/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fila de Vendedor para Atentimentos                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018FILA()
nOpc := 4 // Alterar
VX002FILA()
nOpc := 1
DbSelectArea("VV9")
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Rubens       ³ Data ³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Saida de Veiculos por Venda                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0040,"AxPesqui"	,0,1})			// Pesquisar
aAdd(aRotina,{STR0041,"VXA018V"		,0,2})			// Visualizar
aAdd(aRotina,{STR0042,"VXA018I"		,0,3})			// Incluir
aAdd(aRotina,{STR0043,"VXA018A"		,0,4})			// Alterar
aAdd(aRotina,{STR0044,"VXA018C"		,0,5})			// Cancelar
aAdd(aRotina,{STR0114,"VXA018011_AprovacaoPrevia"	,0,4})			// Aprovação Prévia
If FunName() == "VEIXA018" .and. !Empty(RetSQLName("VDG")) // Existe Fila de Vendedores no Atendimento
	aAdd(aRotina,{STR0038,"VXA018PRE"	,0,1}) 		// Pre Atendimento
	aAdd(aRotina,{STR0039,"VXA018FILA"	,0,1}) 		// Fila de Atendimentos
EndIf
aAdd(aRotina,{STR0102,"VXA018FIN"	,0,4})			// Gerar Financeiro
aadd(aRotina,{STR0116,"VXA018VQL"	,0,2})			// Consulta Log Integração Financeiro
aAdd(aRotina,{STR0045,"VXA018LEG"	,0,4,2,.f.})	// Legenda
aAdd(aRotina,{STR0046,"VXA018PESQ"	,0,1})			// Pesq.Avancada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para alteração do aRotina (menu)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("VXA018BOT") ) // Ponto de entrada para adicionar botões na mbrowse na tela de Atendimento de Veiculos
	aRotina := ExecBlock("VXA018BOT",.f.,.f.,{aRotina})
EndIf

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA018LEG ³ Autor ³ Andre Luis Almeida / Rubens       ³ Data ³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Saida de Veiculos por Venda                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018LEG()
Local aLegUsr  := {}
Local aLegenda := {}
aAdd(aLegenda,{'BR_VERDE'   , "[ A ] "+STR0003 }) // Em Aberto
aAdd(aLegenda,{'lbok_ocean' , "[ A ] "+STR0002 }) // Em Aberto com Veiculo ja Vendido
aAdd(aLegenda,{'BR_AMARELO' , "[ P ] "+STR0004 }) // Pendente de Aprovacao
aAdd(aLegenda,{'BR_BRANCO'  , "[ O ] "+STR0005 }) // Pre-Aprovado
aAdd(aLegenda,{'BR_AZUL'    , "[ L ] "+STR0006 }) // Aprovado
aAdd(aLegenda,{'BR_LARANJA' , "[ R ] "+STR0007 }) // Reprovado
aAdd(aLegenda,{'BR_PRETO'   , "[ F ] "+STR0008 }) // Finalizado
aAdd(aLegenda,{'f14_pret'   , "[ F ] "+STR0101 }) // Finalizado com inconsistência no Financeiro
aAdd(aLegenda,{'BR_VERMELHO', "[ C ] "+STR0009 }) // Cancelado
If ( ExistBlock("VM011LEG") )
	aLegUsr := ExecBlock("VM011LEG",.F.,.F.,{aLegenda,"L"})
	If ( ValType(aLegUsr) == "A" )
		aLegenda := aClone(aLegUsr)
	EndIf
EndIf
BrwLegenda(cCadastro,STR0045,aLegenda) // Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA018VEIVD³ Autor ³ Andre Luis Almeida               ³ Data ³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atendimento "A"berto com veiculo ja vendido em outro Atendimento       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018VEIVD()
Local lRet    := .f.
Local cQuery  := ""
cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA"
cQuery += "  FROM " + RetSqlName("VVA") + " VVA"
cQuery += "  JOIN " + RetSqlName("VV1") + " VV1"
cQuery += "    ON ( VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
cQuery += "     AND VV1.VV1_CHAINT = VVA.VVA_CHAINT"
cQuery += "     AND VV1.VV1_SITVEI = '1'"
cQuery += "     AND VV1.D_E_L_E_T_ = ' ' )"
cQuery += " WHERE VVA.VVA_FILIAL = '" + VV9->VV9_FILIAL + "'"
cQuery += "   AND VVA.VVA_NUMTRA = '" + VV9->VV9_NUMATE + "'"
cQuery += "   AND VVA.VVA_CHASSI <> ' '"
cQuery += "   AND VVA.D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0
	lRet := .t.
EndIf
DbSelectArea("VV9")
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VXA018PESQ³Autor³ Andre Luis Almeida          ³Data³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levanta REGISTROS VV9/VV0/VVA e posiciona no Browse          ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018PESQ()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0
Local nOpca    := 0
//
Private nCkPerg1   := 1
Private cComboStat := ""
Private aComboStat := {"",	"A="+STR0003,; // Em Aberto
							"X="+STR0002,; // Em Aberto com Veiculo ja Vendido
							"F="+STR0008,; // Finalizado
							"P="+STR0004,; // Pendente de Aprovacao
							"R="+STR0007,; // Reprovado
							"O="+STR0005,; // Pre-Aprovado
							"L="+STR0006,; // Aprovado
							"C="+STR0009}  // Cancelado
Private cComboSubS := ""
Private aComboSubS := {"",	"1="+STR0047,; // Liberado para Faturamento
							"2="+STR0048,; // Liberado para Entrega
							"3="+STR0049}  // Veiculo Entregue
Private dDtIniAte  := dDataBase-(day(dDataBase)-1)
Private dDtFinAte  := dDataBase
Private cNroNFI    := space(len(VV0->VV0_NUMNFI))
Private cSerNFI    := space(len(VV0->VV0_SERNFI))
Private aLevPesq   := {{"","","",ctod(""),"",0,"","",""}}
Private cLevCliC   := space(len(VV9->VV9_CODCLI))
Private cLevCliL   := space(len(VV9->VV9_LOJA))
Private cLevCliN   := space(len(VV9->VV9_NOMVIS))
Private cLevChas   := space(len(VV1->VV1_CHASSI))
Private oVerd      := LoadBitmap( GetResources() , "BR_VERDE" )
Private oOcea      := LoadBitmap( GetResources() , "lbok_ocean" )
Private oPret      := LoadBitmap( GetResources() , "BR_PRETO" )
Private oAmar      := LoadBitmap( GetResources() , "BR_AMARELO" )
Private oLara      := LoadBitmap( GetResources() , "BR_LARANJA" )
Private oBran      := LoadBitmap( GetResources() , "BR_BRANCO" )
Private oAzul      := LoadBitmap( GetResources() , "BR_AZUL" )
Private oVerm      := LoadBitmap( GetResources() , "BR_VERMELHO" )
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 36, .T. , .F. } )  	//Label Superior
AAdd( aObjects, { 1, 10, .T. , .T. } )  	//list box
// Fator de reducao de 0.8
for nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
next
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0050) FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL // Pesquisa Chassi/Cliente/Status/Periodo/NF/Serie

@ aPosObj[1,1],aPosObj[1,2]+2 RADIO oRadio1 VAR nCkPerg1 3D SIZE 50,10 PROMPT STR0061,STR0051,STR0052,STR0053 OF oLevPesq PIXEL ON CHANGE (FS_COMBOTIPO(),FS_LEVVEI())  // Cliente ### Chassi ### Status/Periodo ### NF/Serie

@ aPosObj[1,1]+010,aPosObj[1,2]+065 SAY oTit3 VAR STR0078 SIZE 50,08 OF oLevPesq PIXEL COLOR CLR_BLUE // Codigo/Loja
@ aPosObj[1,1]+019,aPosObj[1,2]+065 MSGET oLevCliC VAR cLevCliC F3 "SA1" VALID FS_LEVVEI() PICTURE "@!" SIZE 40,08 OF oLevPesq PIXEL
@ aPosObj[1,1]+019,aPosObj[1,2]+108 MSGET oLevCliL VAR cLevCliL VALID FS_LEVVEI() PICTURE "@!" SIZE 20,08 OF oLevPesq PIXEL
@ aPosObj[1,1]+010,aPosObj[1,2]+140 SAY oTit4 VAR STR0079 SIZE 50,08 OF oLevPesq PIXEL COLOR CLR_BLUE // Nome/Visitante
@ aPosObj[1,1]+019,aPosObj[1,2]+140 MSGET oLevCliN VAR cLevCliN F3 "VSA1" VALID FS_LEVVEI() PICTURE "@!" SIZE 150,08 OF oLevPesq PIXEL WHEN Empty(cLevCliC+cLevCliL)
@ aPosObj[1,1]+013,aPosObj[1,2]+065 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ aPosObj[1,1]+013,aPosObj[1,2]+065 MSCOMBOBOX oCoboStat VAR cComboStat VALID FS_LEVVEI() SIZE 100,08 ITEMS aComboStat OF oLevPesq PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+014,aPosObj[1,2]+213 SAY oTit1 VAR STR0054 SIZE 10,08 OF oLevPesq PIXEL COLOR CLR_BLUE // a
@ aPosObj[1,1]+014,aPosObj[1,2]+080 SAY oTit2 VAR (STR0055+":") SIZE 40,08 OF oLevPesq PIXEL COLOR CLR_BLUE /// Nro NF/Serie
@ aPosObj[1,1]+013,aPosObj[1,2]+120 MSGET oNroNFI VAR cNroNFI F3 "SF2" VALID IIf(!Empty(cNroNFI),cSerNFI:=SF2->F2_SERIE,.t.) PICTURE "@!" SIZE 36,08 OF oLevPesq PIXEL
@ aPosObj[1,1]+013,aPosObj[1,2]+166 MSGET oSerNFI VAR cSerNFI PICTURE "@!" SIZE 15,08 OF oLevPesq PIXEL
@ aPosObj[1,1]+013,aPosObj[1,2]+200 BUTTON oOKNF PROMPT "OK" OF oLevPesq SIZE 30,11 PIXEL ACTION (FS_LEVVEI()) // OK
@ aPosObj[1,1]+013,aPosObj[1,2]+168 MSGET oDtIniAte VAR dDtIniAte VALID FS_LEVVEI() PICTURE "@D" SIZE 42,08 OF oLevPesq PIXEL
@ aPosObj[1,1]+013,aPosObj[1,2]+220 MSGET oDtFinAte VAR dDtFinAte VALID FS_LEVVEI() PICTURE "@D" SIZE 42,08 OF oLevPesq PIXEL
@ aPosObj[1,1]+013,aPosObj[1,2]+263 MSCOMBOBOX oCoboSubS VAR cComboSubS VALID FS_LEVVEI() SIZE 85,08 ITEMS aComboSubS OF oLevPesq PIXEL COLOR CLR_BLUE
oLevChas:lVisible:=.f.
oTit1:lVisible:=.f.
oTit2:lVisible:=.f.
oOKNF:lVisible:=.f.
oCoboStat:lVisible:=.f.
oCoboSubS:lVisible:=.f.
oDtIniAte:lVisible:=.f.
oDtFinAte:lVisible:=.f.
oNroNFI:lVisible:=.f.
oSerNFI:lVisible:=.f.

@ aPosObj[2,1]+1,aPosObj[2,2] LISTBOX oLbLevPesq FIELDS HEADER "",;
																STR0057,; // Filial
																STR0058,; // Data
																STR0059,; // Atendimento
																STR0055,; // Nro NF - Serie
																STR0060,; // Valor
																STR0061;  // Cliente
																COLSIZES 10,35,35,35,38,40,150 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oLevPesq PIXEL ON DBLCLICK IIf(!Empty(aLevPesq[1,1]),( nOpca := oLbLevPesq:nAt, oLevPesq:End() ),.t.)
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
							aLevPesq[oLbLevPesq:nAt,03],;
							Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
							aLevPesq[oLbLevPesq:nAt,05],;
							aLevPesq[oLbLevPesq:nAt,08]+aLevPesq[oLbLevPesq:nAt,09],;
							FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
							aLevPesq[oLbLevPesq:nAt,07] }}

@ aPosObj[1,1]+012,aPosObj[1,4]-30 BUTTON oNo PROMPT STR0056 OF oLevPesq SIZE 30,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) // SAIR

ACTIVATE MSDIALOG oLevPesq CENTER

DbSelectArea("VV9")
If nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	DbSetOrder(1)//NUM.ATENDIMENTO
	DbSeek(left(aLevPesq[nOpca,3],VV9->(TamSx3("VV9_FILIAL")[1]))+ aLevPesq[nOpca,1]) 
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEVVEI ³ Autor ³ Andre Luis Almeida                ³ Data ³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Atendimentos de Veiculos na Pesquisa Avancada                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVVEI()
Local cNomCli  := ""
Local aSA1     := {}
Local nLinha   := 0
Local cLevCliF := ""
Local aSM0     := FWLoadSM0() // Carrega Empresa/Filiais
Local nInc     := 0
Local cEmpAtu  := ""
Local cFilSalv := cFilAnt // Salvar Filial Atual
Local cQuery   := ""
Local cQAlVV0  := "SQLVV0"
Local cQAlSA1  := "SQLSA1"
Local cQAlVV9  := "SQLVV9"
Local cVV9_STATUS := ""
If Empty(cLevChas) .and. nCkPerg1 == 2 // Chassi
	aLevPesq := {{"","","",ctod(""),"",0,"","",""}}
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
								aLevPesq[oLbLevPesq:nAt,03],;
								Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
								aLevPesq[oLbLevPesq:nAt,05],;
								aLevPesq[oLbLevPesq:nAt,08]+aLevPesq[oLbLevPesq:nAt,09],;
								FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
								aLevPesq[oLbLevPesq:nAt,07] }}
								oLbLevPesq:SetFocus()
								oLbLevPesq:Refresh()
	Return()
EndIf
If nCkPerg1 == 1 // Cliente
	If !Empty(cLevCliC)
		SA1->(DbSetOrder(1))
		SA1->(DbSeek( xFilial("SA1") + cLevCliC + Alltrim(cLevCliL) ))
		cLevCliL := SA1->A1_LOJA
		cLevCliN := SA1->A1_NOME
	Else
		If !Empty(cLevCliL)
			cLevCliL := space(len(SA1->A1_LOJA))
			cLevCliN := space(len(SA1->A1_NOME))
		EndIf
	EndIf
	If Empty(cLevCliC) .and. !Empty(cLevCliN)
		// Pesquisa no SA1 pelo Nome do Cliente
		cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_TEL , SA1.A1_CGC FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_NOME LIKE '%"+Alltrim(cLevCliN)+"%' AND SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_NOME"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1, .F., .T. )
		Do While !( cQAlSA1 )->( Eof())
			Aadd(aSA1,{( cQAlSA1 )->( A1_COD ),( cQAlSA1 )->( A1_LOJA ),( cQAlSA1 )->( A1_NOME ),( cQAlSA1 )->( A1_TEL ),Transform(( cQAlSA1 )->( A1_CGC ),IIf(Len(Alltrim(( cQAlSA1 )->( A1_CGC )))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))})
			( cQAlSA1 )->( DbSkip() )
		EndDo
		( cQAlSA1 )->( dbCloseArea() )
		For nInc := 1 To Len( aSM0 )
			If aSM0[nInc][1] == cEmpAnt .and. aSM0[nInc][11]
				cFilAnt := aSM0[nInc][2] // Altera Filial
				// Pesquisa no VV9 pelo Nome do Cliente
				cQuery := "SELECT DISTINCT VV9.VV9_NOMVIS , VV9.VV9_TELVIS FROM "+RetSqlName("VV9")+" VV9 WHERE VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND  VV9.VV9_CODCLI=' ' AND VV9.VV9_NOMVIS LIKE '%"+Alltrim(cLevCliN)+"%' AND VV9.D_E_L_E_T_=' ' ORDER BY VV9.VV9_NOMVIS"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV9, .F., .T. )
				Do While !( cQAlVV9 )->( Eof())
					If aScan(aSA1,{|x| x[1]+x[2]+x[3]+x[4] == space(len(SA1->A1_COD)+len(SA1->A1_LOJA))+( cQAlVV9 )->( VV9_NOMVIS )+( cQAlVV9 )->( VV9_TELVIS )}) == 0
						Aadd(aSA1,{space(len(SA1->A1_COD)),space(len(SA1->A1_LOJA)),( cQAlVV9 )->( VV9_NOMVIS ),( cQAlVV9 )->( VV9_TELVIS ),""})
					EndIf
					( cQAlVV9 )->( DbSkip() )
				EndDo
				( cQAlVV9 )->( dbCloseArea() )
			EndIf
		Next
		cFilAnt := cFilSalv // Volta Filial salva
		If len(aSA1)>0
			If len(aSA1) > 1
				nLinha := FS_CLIENTE(aSA1) // n registros
			Else
				nLinha := 1 // 1 registro -> 1 linha
			EndIf
		EndIf
		If nLinha > 0
			cLevCliC := aSA1[nLinha,1] // Codigo
			cLevCliL := aSA1[nLinha,2] // Loja
			cLevCliN := aSA1[nLinha,3] // Nome
			cLevCliF := aSA1[nLinha,4] // Fone
		EndIf
	EndIf
	oLevCliL:Refresh()
	cLevCliN := left(cLevCliN+space(50),len(VV9->VV9_NOMVIS))
	oLevCliN:Refresh()
EndIf
/////////////////////////////////////////
// Posicionar no VAI do usuario logado //
/////////////////////////////////////////
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
/////////////////////////////////////////
aLevPesq := {}
For nInc := 1 To Len( aSM0 )
	
	If aSM0[nInc,1] == cEmpAnt .and. aSM0[nInc,11]
		
		cFilAnt := aSM0[nInc,2] // Altera Filial
		
		cQuery := "SELECT VV9.VV9_NUMATE , VV9.VV9_STATUS , VV9.VV9_DATVIS , VV9.VV9_NOMVIS , VV0.VV0_FILIAL , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA , VVA.VVA_CHAINT "
		cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
		cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
		If Empty(VAI->VAI_ATEOUT) .or. VAI->VAI_ATEOUT == "0" // Nao Visualiza Atendimentos de outros vendedores
			cQuery += "VV0.VV0_CODVEN='"+VAI->VAI_CODVEN+"' AND "
		EndIf
		If nCkPerg1 == 1 // Cliente
			If !Empty(cLevCliC+cLevCliL) // Codigo + Loja
				cQuery += "VV9.VV9_CODCLI='"+cLevCliC+"' AND VV9.VV9_LOJA='"+cLevCliL+"' AND "
			Else // Nome + Fone
				cQuery += "VV9.VV9_NOMVIS='"+cLevCliN+"' AND VV9.VV9_TELVIS='"+cLevCliF+"' AND "
			EndIf
		ElseIf nCkPerg1 == 2 // Chassi
			cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND "
		ElseIf nCkPerg1 == 3 // Status/Periodo
			If !Empty(cComboStat)
				If left(cComboStat,1)=="X"
					cQuery += "VV9.VV9_STATUS='A' AND "
				Else
					cQuery += "VV9.VV9_STATUS='"+left(cComboStat,1)+"' AND "
				EndIf
			EndIf
			If Empty(dDtFinAte) .or. dDtIniAte > dDtFinAte
				dDtFinAte := dDtIniAte
				oDtFinAte:Refresh()
			EndIf
			cQuery += "VV9.VV9_DATVIS>='"+dtos(dDtIniAte)+"' AND VV9.VV9_DATVIS<='"+dtos(dDtFinAte)+"' AND "
			If !Empty(cComboSubS)
				If left(cComboSubS,1)=="1" // Liberado para Faturamento
					cQuery += "VV9.VV9_STATUS='L' AND VVA.VVA_DTLIBF>' ' AND VVA.VVA_DTLIBE=' ' AND VVA.VVA_DTEREA=' ' AND "
				ElseIf left(cComboSubS,1)=="2" // Liberado para Entrega
					cQuery += "VVA.VVA_DTLIBE>' ' AND VVA.VVA_DTEREA=' ' AND "
				ElseIf left(cComboSubS,1)=="3" // Veiculo Entregue
					cQuery += "VVA.VVA_DTEREA>' ' AND "
				EndIf
			EndIf
		Else//If nCkPerg1 == 4 // NF/Serie
			cQuery += "VV0.VV0_NUMNFI='"+cNroNFI+"' AND VV0.VV0_SERNFI='"+cSerNFI+"' AND "
		EndIf
		cQuery += "VV0.VV0_TIPFAT<>'2' AND VV0.D_E_L_E_T_=' ' ORDER BY VV9.VV9_DATVIS , VV9.VV9_NUMATE "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
		Do While !( cQAlVV0 )->( Eof() )
			cVV9_STATUS := ( cQAlVV0 )->( VV9_STATUS )
			If cVV9_STATUS == "A"
				VV1->(DbSetOrder(1))
				VV1->(DbSeek( xFilial("VV1") + ( cQAlVV0 )->( VVA_CHAINT ) ))
				If VV1->VV1_SITVEI == "1" // 1-Vendido
					cVV9_STATUS := "X"
				EndIf
			EndIf
			If ( cVV9_STATUS == "A" .and. left(cComboStat,1) == "X" ) .or. ( cVV9_STATUS == "X" .and. left(cComboStat,1) == "A" )
				( cQAlVV0 )->( DbSkip() )
				Loop
			EndIf
			cEmpAtu := left(FWFilialName(cEmpAnt,( cQAlVV0 )->( VV0_FILIAL ),1),15)
			nLinha := aScan(aLevPesq,{|x| x[1]+x[3] == ( cQAlVV0 )->( VV9_NUMATE ) + ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu })
			If nLinha <= 0
				If !Empty( ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) )
					SA1->(DbSetOrder(1))
					SA1->(DbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) ))
					cNomCli := ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME
				Else
					cNomCli := ( cQAlVV0 )->( VV9_NOMVIS )
				EndIf			
				aAdd(aLevPesq,{ ( cQAlVV0 )->( VV9_NUMATE ) , cVV9_STATUS , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV9_DATVIS )) , ( cQAlVV0 )->( VV9_NUMATE ) , ( cQAlVV0 )->( VV0_VALMOV ) , cNomCli , ( cQAlVV0 )->( VV0_NUMNFI ) , ( cQAlVV0 )->( VV0_SERNFI ) })
			Else
				If cVV9_STATUS == "X"
					aLevPesq[nLinha,2] := cVV9_STATUS
				EndIf
			EndIf
			( cQAlVV0 )->( DbSkip() )
		EndDo
		( cQAlVV0 )->( dbCloseArea() )
	EndIf
Next
cFilAnt := cFilSalv // Volta Filial salva
If len(aLevPesq) <= 0
	If nCkPerg1 == 1 // Cliente
		If !Empty(Alltrim(cLevCliC+cLevCliL+cLevCliN))
			MsgAlert(STR0072+" "+Alltrim(cLevCliC+"-"+cLevCliL)+" "+cLevCliN,STR0062) //Nenhum Atendimento encontrado para o Cliente  /  Atencao
		EndIf
	ElseIf nCkPerg1 == 2 // Chassi
		If !Empty(Alltrim(cLevChas))
			MsgAlert(STR0063+" "+cLevChas,STR0062) //Nenhum Atendimento encontrado para o Chassi  /  Atencao
		EndIf
	ElseIf nCkPerg1 == 3 // Status/Periodo
		MsgAlert(STR0064,STR0062) //Nenhum Atendimento encontrado  /  Atencao
	Else//If nCkPerg1 == 4 // NF/Serie
		MsgAlert(STR0065,STR0062) //Nenhuma NF/Serie encontrada para os Atendimentos  /  Atencao
	EndIf
	aLevPesq := {{"","","",ctod(""),"",0,"","",""}}
EndIf
oLbLevPesq:nAt := 1
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
							aLevPesq[oLbLevPesq:nAt,03],;
							Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
							aLevPesq[oLbLevPesq:nAt,05],;
							aLevPesq[oLbLevPesq:nAt,08]+aLevPesq[oLbLevPesq:nAt,09],;
							FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
							aLevPesq[oLbLevPesq:nAt,07] }}
oLbLevPesq:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_COMBOTIPO³ Autor ³ Andre Luis Almeida              ³ Data ³ 30/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Selecao do ComboBox - Visualiza / Nao Visualiza campos na tela         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COMBOTIPO()
cComboStat := ""
cComboSubS := ""
dDtIniAte  := dDataBase-(day(dDataBase)-1)
dDtFinAte  := dDataBase
cNroNFI    := space(len(VV0->VV0_NUMNFI))
cSerNFI    := space(len(VV0->VV0_SERNFI))
cLevCliC   := space(len(VV9->VV9_CODCLI))
cLevCliL   := space(len(VV9->VV9_LOJA))
cLevCliN   := space(len(VV9->VV9_NOMVIS))
cLevChas   := space(len(VV1->VV1_CHASSI))
oLevCliC:lVisible := .f.
oLevCliL:lVisible := .f.
oLevCliN:lVisible := .f.
oLevChas:lVisible := .f.
oTit1:lVisible := .f.
oTit2:lVisible := .f.
oTit3:lVisible := .f.
oTit4:lVisible := .f.
oOKNF:lVisible := .f.
oCoboStat:lVisible := .f.
oCoboSubS:lVisible := .f.
oDtIniAte:lVisible := .f.
oDtFinAte:lVisible := .f.
oNroNFI:lVisible := .f.
oSerNFI:lVisible := .f.
If nCkPerg1 == 1 // Cliente
	oTit3:lVisible := .t.
	oTit4:lVisible := .t.
	oLevCliC:lVisible := .t.
	oLevCliL:lVisible := .t.
	oLevCliN:lVisible := .t.
	oLevCliC:SetFocus()
ElseIf nCkPerg1 == 2 // Chassi
	oLevChas:lVisible:=.t.
	oLevChas:SetFocus()
ElseIf nCkPerg1 == 3 // Status/Periodo
	oTit1:lVisible:=.t.
	oCoboStat:lVisible:=.t.
	oCoboStat:SetFocus()
	oCoboSubS:lVisible:=.t.
	oCoboSubS:SetFocus()
	oDtIniAte:lVisible:=.t.
	oDtFinAte:lVisible:=.t.
Else//If nCkPerg1 == 4 // NF/Serie
	oTit2:lVisible:=.t.
	oNroNFI:lVisible:=.t.
	oNroNFI:SetFocus()
	oSerNFI:lVisible:=.t.
	oOKNF:lVisible:=.t.
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CLIENTE ³ Autor ³ Andre Luis Almeida              ³ Data ³ 09/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Escolher o Cliente desejado no vetor aSA1 para utiliza-lo no filtro    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CLIENTE(aSA1)
Local nLinha    := 0
Local nCntFor   := 0
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Veiculos
// Fator de reducao de 0.7
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.7)
Next
aInfo := {aSizeHalf[1] , aSizeHalf[2] , aSizeHalf[3] , aSizeHalf[4] , 2 , 2 }
aPos := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oSA1Obj FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0061 OF oMainWnd PIXEL // Cliente
@ aPos[1,1]+005,aPos[1,2] LISTBOX oLbSA1 FIELDS HEADER STR0073,STR0074,STR0075,STR0076,STR0077 ;	// Codigo / Loja / Nome / Fone / CPF/CNPJ
COLSIZES 25,15,160,20,40 SIZE @ aPos[1,4]-001,aPos[1,3]-015 OF oSA1Obj PIXEL ON DBLCLICK ( nLinha := oLbSA1:nAt , oSA1Obj:End() )
oLbSA1:SetArray(aSA1)
oLbSA1:bLine := { || { aSA1[oLbSA1:nAt,1] , aSA1[oLbSA1:nAt,2] , aSA1[oLbSA1:nAt,3] , aSA1[oLbSA1:nAt,4] , aSA1[oLbSA1:nAt,5] }}
ACTIVATE MSDIALOG oSA1Obj ON INIT EnchoiceBar(oSA1Obj,{ || ( nLinha := oLbSA1:nAt , oSA1Obj:End() ) }, { || oSA1Obj:End() },,) CENTER
Return nLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA018SUBSTA³ Autor ³ Andre Luis Almeida              ³ Data ³ 26/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Sub-Status ( Texto ou Data ) do Atendimento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTp   1 = Sub-Status  ( Texto )                                        ³±±
±±³          ³       2 = Data do Sub-Status  ( Data )                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018SUBSTA(nTp)
Local cStatus   := ""
Local dStatus   := ctod("")
VVA->(DbSetOrder(1))
If VVA->(DbSeek(VV9->VV9_FILIAL+VV9->VV9_NUMATE))
	Do Case
		Case !Empty(VVA->VVA_DTEREA)
			///////////////////////////////
			// Veiculo Entregue          //
			///////////////////////////////
			cStatus := STR0049 // Veiculo Entregue
			dStatus := VVA->VVA_DTEREA
		Case !Empty(VVA->VVA_DTLIBE)
			///////////////////////////////
			// Liberado para Entrega     //
			///////////////////////////////
			cStatus := STR0048 // Liberado para Entrega
			dStatus := VVA->VVA_DTLIBE
		Case !Empty(VVA->VVA_DTLIBF)
			If VV9->VV9_STATUS == "L"
				///////////////////////////////
				// Liberado para Faturamento //
				///////////////////////////////
				cStatus := STR0047 // Liberado para Faturamento
				dStatus := VVA->VVA_DTLIBF
			EndIf
	EndCase
EndIf
Return(IIf(nTp==1,cStatus,dStatus))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA018OPORT³ Autor ³ Andre Luis Almeida              ³ Data ³ 25/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Incluir Atendimento atraves da tela de Oportunidade de Vendas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRecInter = RecNo's dos Interesses da Oportunidade de Vendas           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018OPORT(aRecInter)
Local cBkpFunName := FunName()
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
SetFunName("VEIXA018") 
nOpc := 3
dbSelectArea("VV9") 
VEIXA018(.T.,aRecInter)
SetFunName(cBkpFunName)
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA018FIN  ³ Autor ³ Andre Luis Almeida              ³ Data ³ 27/11/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerar somente o Financeiro, pq o Atendimento foi finalizado gerando NF,³±±
±±³          ³ porem deu problema na geracao dos Titulos                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018FIN() 
Local lOkTit := .t.
Local lVV0_GERFIN := ( VV0->(ColumnPos("VV0_GERFIN")) > 0 ) // Campo que controla se gerou FINANCEIRO (Titulos)
Local cQuery := ""
If VV9->VV9_STATUS == "F" // Atendimento Finalizado
	VV0->(dbSetOrder(1))
	If VV0->(dbSeek(xFilial("VV0")+VV9->VV9_NUMATE))
		If lVV0_GERFIN .and. VV0->VV0_GERFIN == "0" // Existe o campo e 0=NAO gerou Financeiro
			If MsgYesNo(STR0096,STR0062) // Deseja gerar o Financeiro deste Atendimento? / Atencao
				Begin Transaction
					If !VEIXI002(VV9->VV9_NUMATE,.f.,.f.,.t.,"",.f.,VV9->VV9_STATUS) // Geracao de Pedido (.F.) , NF (.F.) e Titulos (.T.)
						DisarmTransaction()
						lOkTit := .f.
					EndIf
				End Transaction
				DbSelectArea("VV0")
				RecLock("VV0",.f.)
					VV0->VV0_GERFIN := IIf(lOkTit,"1","0") // Gerou Financeiro (Titulos)? ( 1=Sim / 0=Nao, deu problema na geracao )
				MsUnLock()
				DbSelectArea("VV9")
				If lOkTit
					MsgInfo(STR0097,STR0062) // Financeiro do Atendimento gerado com sucesso. / Atencao
					// Exclui os LOGS gerados no momento do faturamento 
					cQuery := "DELETE FROM "+ RetSqlName("VQL")
					cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"' "
					cQuery += "   AND VQL_AGROUP = 'VEIXI002' "
					cQuery += "   AND VQL_FILORI = '" + VV0->VV0_FILIAL + "' "
					cQuery += "   AND VQL_TIPO = 'VV0-" + VV0->VV0_NUMTRA + "'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					TcSqlExec(cQuery)
				Else
					MsgAlert(STR0098,STR0062) // Existe(m) inconsistencia(s) na Geração dos Titulos. Favor corrigir a(s) pendencia(s) para solicitar novamente a Geração do Financeiro. / Atencao
				EndIf
			EndIf
		Else
			MsgInfo(STR0099,STR0062) // Financeiro já existente para o Atendimento. / Atencao
		EndIf
	EndIf
Else
	MsgStop(STR0100,STR0062) // Atendimento não Finalizado. Impossivel continuar! / Atencao
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA018TEMFIN³ Autor ³ Andre Luis Almeida              ³ Data ³ 27/11/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Caso exista o campo VV0_GERFIN, verifica se o Atendimento gerou        ³±±
±±³          ³ financeiro ou nao                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA018TEMFIN()
Local cQuery := ""
Local lRet   := .t. // Possui Financeiro
cQuery := "SELECT R_E_C_N_O_ AS RECVV0"
cQuery += "  FROM "+RetSqlName("VV0")
cQuery += " WHERE VV0_FILIAL = '" + VV9->VV9_FILIAL + "'"
cQuery += "   AND VV0_NUMTRA = '" + VV9->VV9_NUMATE + "'"
cQuery += "   AND VV0_GERFIN = '0'" // 0=NAO gerou Financeiro (Titulos)
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0
	lRet := .f. // NAO possui Financeiro
EndIf
DbSelectArea("VV9")
Return lRet

/*/{Protheus.doc} VXA018BrwAct
Monta Graficos e Filtros do Browse

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Function VXA018BrwAct(oBrowse)
oTableAtt := TableAttDef()
oBrowse:SetAttach(.T.)
//
oBrowse:AddFilter(STR0103+": [ A ] "+UPPER(STR0003),"VV9_STATUS=='A'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // STATUS: [ A ] EM ABERTO
oBrowse:AddFilter(STR0103+": [ P ] "+UPPER(STR0004),"VV9_STATUS=='P'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // STATUS: [ P ] PENDENTE APROVAÇÃO
oBrowse:AddFilter(STR0103+": [ O ] "+UPPER(STR0005),"VV9_STATUS=='O'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // STATUS: [ O ] PRÉ-APROVADO
oBrowse:AddFilter(STR0103+": [ L ] "+UPPER(STR0006),"VV9_STATUS=='L'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // STATUS: [ L ] APROVADO
oBrowse:AddFilter(STR0103+": [ R ] "+UPPER(STR0007),"VV9_STATUS=='R'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // STATUS: [ R ] REPROVADO
oBrowse:AddFilter(STR0103+": [ F ] "+UPPER(STR0008),"VV9_STATUS=='F'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // STATUS: [ F ] FINALIZADO
oBrowse:AddFilter(STR0103+": [ C ] "+UPPER(STR0009),"VV9_STATUS=='C'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // STATUS: [ C ] CANCELADO
oBrowse:AddFilter(STR0104,"EMPTY(VV9_MOTIVO)",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // ATENDIMENTOS NÃO CANCELADOS
//
oBrowse:SetViewsDefault( oTableAtt:aViews ) // Criar Visoes
oBrowse:SetChartsDefault( oTableAtt:aCharts ) // Criar Graficos
oBrowse:SetOpenChart( .T. )
Return

/*/{Protheus.doc} TableAttDef
Monta Graficos do Browse

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function TableAttDef() 
//
Local oTableAtt := FWTableAtt():New() 
Local oSqlHlp   := DMS_SqlHelper():New()
//
//Gráficos
Local oGraStat := Nil // Grafico por Status
Local oGraVend := Nil // Grafico por Vendedor 
Local oGraMarc := Nil // Grafico por Marca
Local oGraMMod := Nil // Grafico por Marca + Modelo
Local oGraDAte := Nil // Grafico por Data do Atendimento
Local oGraMotC := Nil // Grafico por Motivo de Cancelamento
Local oGraNvUs := Nil // Grafico por Novo/Usado
//
// Grafico Por Status
oGraStat := FWDSChart():New()
oGraStat:SetName(STR0106) // Status do Atendimento
oGraStat:SetTitle(STR0106) // A=Aberto / P=Pendente Aprovação / O=Pré-Aprovado / L=Aprovado / R=Reprovado / F=Finalizado / C=Cancelado") // "A=Aberto / P=Pendente Aprovação / O=Pré-Aprovado / L=Aprovado / R=Reprovado / F=Finalizado / C=Cancelado
oGraStat:SetID("GrafStat") 
oGraStat:SetType("BARCOMPCHART")
oGraStat:SetSeries({{"VV9","VV9_STATUS","COUNT"}})
oGraStat:SetCategory({{"VV9", "VV9_STATUS"}})
oGraStat:SetPublic( .T. )
oGraStat:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraStat:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraStat) 

// Grafico Por Vendedor
oGraVend := FWDSChart():New()
oGraVend:SetName(STR0107) // Vendedor
oGraVend:SetTitle(STR0107) // Vendedor
oGraVend:SetID("GrafVend") 
oGraVend:SetType("BARCOMPCHART")
oGraVend:SetSeries({{"VV0","VV0_CODVEN","COUNT"}})
oGraVend:SetCategory({{"VV0", "VV0_CODVEN"}})
oGraVend:SetPublic( .T. )
oGraVend:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraVend:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraVend)

// Grafico Por Marca
oGraMarc := FWDSChart():New()
oGraMarc:SetName(STR0108) // Marca
oGraMarc:SetTitle(STR0108) // Marca
oGraMarc:SetID("GrafMarc") 
oGraMarc:SetType("BARCOMPCHART")
oGraMarc:SetSeries({{"VVA","VVA_CODMAR","COUNT"}})
oGraMarc:SetCategory({{"VVA", "VVA_CODMAR"}})
oGraMarc:SetPublic( .T. )
oGraMarc:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraMarc:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraMarc)

// Grafico Por Marca + Modelo
oGraMMod := FWDSChart():New()
oGraMMod:SetName(STR0108+" + "+STR0109) // Marca + Modelo
oGraMMod:SetTitle(STR0108+" + "+STR0109) // Marca + Modelo
oGraMMod:SetID("GrafMMod") 
oGraMMod:SetType("BARCOMPCHART")
oGraMMod:SetSeries({{"VVA", oSqlHlp:Concat({"VVA_CODMAR","VVA_MODVEI"}),"COUNT"}})
oGraMMod:SetCategory({{"VVA", oSqlHlp:Concat({"VVA_CODMAR","VVA_MODVEI"}) }})
oGraMMod:SetPublic( .T. )
oGraMMod:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraMMod:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraMMod)

// Grafico Por Data do Atendimento
oGraDAte := FWDSChart():New()
oGraDAte:SetName(STR0110) // Data do Atendimento ( ANO MES )
oGraDAte:SetTitle(STR0110) // Data do Interesse ( ANO MES )
oGraDAte:SetID("GrafDAte")
oGraDAte:SetType("BARCOMPCHART")
oGraDAte:SetSeries({{"VV9", oSqlHlp:Concat({oSqlHlp:CompatFunc("SUBSTR")+"(VV9_DATVIS,5,2)","'/'",oSqlHlp:CompatFunc("SUBSTR")+"(VV9_DATVIS,1,4)"}),"COUNT"}})
oGraDAte:SetCategory({{"VV9", oSqlHlp:Concat({oSqlHlp:CompatFunc("SUBSTR")+"(VV9_DATVIS,5,2)","'/'",oSqlHlp:CompatFunc("SUBSTR")+"(VV9_DATVIS,1,4)"}) }})
oGraDAte:SetPublic( .T. )
oGraDAte:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraDAte:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraDAte)

// Grafico Por Motivo Cancelamento
oGraMotC := FWDSChart():New()
oGraMotC:SetName(STR0111) // Motivo Cancelamento
oGraMotC:SetTitle(STR0111) // Motivo Cancelamento
oGraMotC:SetID("GrafMotC") 
oGraMotC:SetType("BARCOMPCHART")
oGraMotC:SetSeries({{"VV9","VV9_MOTIVO","COUNT"}})
oGraMotC:SetCategory({{"VV9", "VV9_MOTIVO"}})
oGraMotC:SetPublic( .T. )
oGraMotC:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraMotC:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraMotC)

// Grafico Por Novo/Usado
oGraNvUs := FWDSChart():New()
oGraNvUs:SetName("0="+STR0112+" / 1="+STR0113) // 0=Novo / 1=Usado
oGraNvUs:SetTitle("0="+STR0112+" / 1="+STR0113) // 0=Novo / 1=Usado
oGraNvUs:SetID("GrafNvUs") 
oGraNvUs:SetType("BARCOMPCHART")
oGraNvUs:SetSeries({{"VV0","VV0_TIPFAT","COUNT"}})
oGraNvUs:SetCategory({{"VV0", "VV0_TIPFAT"}})
oGraNvUs:SetPublic( .T. )
oGraNvUs:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraNvUs:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraNvUs)

Return oTableAtt

/*/{Protheus.doc} VXA018011_AprovacaoPrevia
	Executa a Aprovacao Previa
	 
	@type function
	@author Andre Luis Almeida
	@since 17/02/2020
/*/
Function VXA018011_AprovacaoPrevia()
Local lVVASEGMOD  := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )
Local lVV0SEGMOD  := ( VV0->(ColumnPos("VV0_SEGMOD")) > 0 )
Local aRetMapa    := {}
Local nPosVet     := 0
Local nPosMap     := 0
Local aStruMCom   := {"","","","","",0,0,0,0,0} // Estrutura do Array de Minimo Comercial
Private aMinCom   := {} // Minimo Comercial do Veiculo
//
If FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_APROVA","?") <> "3" // Usuario nao faz Aprovacao Previa
	MsgStop(STR0115,STR0062) // Usuario sem permissao para realizar a Aprovacao Previa. Impossivel continuar. / Atencao
	Return
EndIf
//
dbSelectarea("VV0")
dbSetOrder(1) // VV0_FILIAL+VV0_NUMTRA
If dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
	RegTomemory("VV0",.f.) // Carregar M-> do VV0
EndIf
dbSelectarea("VVA")
dbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
If dbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
	RegTomemory("VVA",.f.) // Carregar M-> do VVA
EndIf
aRetMapa := FM_MAPAVAL(1,,VV9->VV9_NUMATE,.f.,0,,)
//
dbSelectarea("VVA")
dbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
dbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
While !Eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == VV9->VV9_NUMATE
	nPosVet++
	AADD( aMinCom , aClone(aStruMCom) )
	aMinCom[nPosVet,01] := VVA->VVA_CHAINT
	If !Empty(VVA->VVA_CODMAR)
		FGX_VV2(VVA->VVA_CODMAR, VVA->VVA_MODVEI, IIf( lVVASEGMOD , VVA->VVA_SEGMOD , "" ) )
		aMinCom[nPosVet,02] := VVA->VVA_CODMAR	// Marca do Veiculo
		aMinCom[nPosVet,03] := VVA->VVA_MODVEI	// Modelo do Veiculo
		aMinCom[nPosVet,04] := VV2->VV2_SEGMOD	// Segmento do Modelo
		aMinCom[nPosVet,05] := VVA->VVA_CORVEI	// Cor do Veiculo
	Else
		FGX_VV2(VV0->VV0_CODMAR, VV0->VV0_MODVEI, IIF( lVV0SEGMOD , VV0->VV0_SEGMOD , "" ) )
		aMinCom[nPosVet,02] := VV0->VV0_CODMAR	// Marca do Veiculo
		aMinCom[nPosVet,03] := VV0->VV0_MODVEI	// Modelo do Veiculo
		aMinCom[nPosVet,04] := VV2->VV2_SEGMOD	// Segmento do Modelo
		aMinCom[nPosVet,05] := VV0->VV0_CORVEI	// Cor do Veiculo
	EndIf
	aMinCom[nPosVet,06] := VVA->VVA_VALTAB	// Valor da Negociacao do Veiculo
	nPosMap := aScan(aRetMapa[3],{|x| x[1] == VVA->(RecNo()) })
	If nPosMap > 0
		aMinCom[nPosVet,09] := aRetMapa[3,nPosMap,2] // Resultado do Mapa
	EndIf
	DbSelectArea("VVA")
	DbSkip()
EndDo
//
VEIXX013( VV9->VV9_NUMATE , 3 , .f. ) // Chama a Aprovacao Previa ( 3 - Aprovacao Previa )
//
Return

/*/{Protheus.doc} VXA018VQL
	Consulta LOG de erro de integrao com financeiro 
	@type  Function
	@author Andre Luis Almeida
	@since 16/09/2021
	@version 1.0
	/*/
Function VXA018VQL(cAlias,nReg,nOpc)
Local aBkpRotina
If VV9->VV9_STATUS == "F" // Finalizado
	VV0->(DbSetOrder(1))
	If VV0->(DbSeek( VV9->VV9_FILIAL + VV9->VV9_NUMATE ))
		If VV0->VV0_GERFIN == '0' // SEM Financeiro
			aBkpRotina := aClone(aRotina)
			aRotina := {}
			OFIC020("VEIXI002","@VQL_TIPO = 'VV0-" + VV0->VV0_NUMTRA + "' AND VQL_FILORI = '" + VV0->VV0_FILIAL + "' ", .F. )
			aRotina := aClone(aBkpRotina)
		Else
			MsgInfo(STR0117) // Consulta utilizada somente quando não foi possível gerar os títulos de contas à receber no Atendimento.
		EndIf
	EndIf
EndIf
Return