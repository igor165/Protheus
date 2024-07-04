#include "PROTHEUS.CH"
#include "VEIXA030.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA030 ³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faturamento Direto                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA030(lNoMBrowse,aRecInter)
Local cFiltro     := ""
Local cFilUser    := ""
Private cCadastro := STR0001
Private aRotina   := MenuDef()
Private aCores    := {	{'VV9->VV9_STATUS == "F"','BR_PRETO'},;		// Finalizado
						{'VV9->VV9_STATUS == "C"','BR_VERMELHO'},;	// Cancelado
						{'VV9->VV9_STATUS == "P"','BR_AMARELO'},;	// Pendente de Aprovacao
						{'VV9->VV9_STATUS == "O"','BR_BRANCO'},;	// Pre-Aprovado
						{'VV9->VV9_STATUS == "L"','BR_AZUL'},;		// Aprovado
						{'VV9->VV9_STATUS == "R"','BR_LARANJA'},;	// Reprovado
						{'.T.'                   ,'BR_VERDE'}}		// Em Aberto
Private cMotivo   := "000001"
Default lNoMBrowse := .f.
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas

//////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos //
//////////////////////////////////////////////////////////////////////////////
If !AMIIn(11) .or. !FMX_AMIIN({"VEIXA030"})
	Return()
EndIf

// Ponto de Entrada para Filtro do Browse
If ExistBlock("VXA030FBRW")
	cFilUser := ExecBlock("VXA030FBRW", .f., .f.)
EndIf

//
SetKey(VK_F12,{ || VXA030F12(.t.) })
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
	////////////////////////////////////////////
	// Filtro do Browse - Faturamento Direto  //
	////////////////////////////////////////////
	cFiltro := " EXISTS ( SELECT VV0.VV0_CODVEN FROM "+RetSQLName("VV0")+" VV0 WHERE "
	cFiltro += "VV0.VV0_FILIAL=VV9_FILIAL AND VV0.VV0_NUMTRA=VV9_NUMATE AND VV0.VV0_TIPFAT='2' AND "
	If Empty(VAI->VAI_ATEOUT) .or. VAI->VAI_ATEOUT == "0" // Nao Visualiza Atendimentos de outros vendedores
		cFiltro += "VV0.VV0_CODVEN='"+VAI->VAI_CODVEN+"' AND " // NAO visualiza Atendimentos de outros vendedores
	EndIf
	cFiltro += "VV0.D_E_L_E_T_=' ') "
	cFiltro += IIf(Empty(cFilUser), "", " AND " + cFilUser)
	mBrowse( 6, 1,22,75,"VV9",,,,,,aCores,,,,,,,,cFiltro)
EndIf

DbSelectArea("VV9")

SetKey(VK_F12,Nil)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030?  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Faturamento Direto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030V(cAlias,nReg,nOpc)
nOpc := 2 // Visualizar
VXA030(cAlias,nReg,nOpc)
Return()
//
Function VXA030I(cAlias,nReg,nOpc,aRecInter)
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
nOpc := 3 // Incluir
VXA030(cAlias,nReg,nOpc,aRecInter)
Return()
//
Function VXA030A(cAlias,nReg,nOpc)
nOpc := 4 // Alterar
VXA030(cAlias,nReg,nOpc)
Return()
//
Function VXA030C(cAlias,nReg,nOpc)
nOpc := 5 // Cancelar
VXA030(cAlias,nReg,nOpc)
Return()
///////////////////////////////////////////////////////
// Montagem da Janela de Faturamento Direto          //
///////////////////////////////////////////////////////
Function VXA030(cAlias,nReg,nOpc,aRecInter)
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
VEIXX030(NIL,NIL,NIL,nOpc,aRecInter)
//
SetKey(VK_F12,{ || VXA030F12(.t.) })
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
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Faturamento Direto                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local  aRotina := {	{STR0005,"AxPesqui"		,0,1},; 		// Pesquisar
					{STR0006,"VXA030V"		,0,2},;  		// Visualizar
					{STR0007,"VXA030I"		,0,3},;   		// Incluir
					{STR0008,"VXA030A"		,0,4},;   		// Alterar
					{STR0009,"VXA030C"		,0,5},;   		// Cancelar
					{STR0010,"VXA030LEG"	,0,4,2,.f.},;	// Legenda
					{STR0011,"VEIVM180(VV9->(RecNo()))",0,6}} // Gerar NF/Titulos

If (ExistBlock("VXA030MD")) // Ponto de Entrada para adicionar opções no Menu
	aRotina := ExecBlock("VXA030MD", .f., .f., {aRotina})
EndIf
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030LEG³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Faturamento Direto                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030LEG()
Local aLegenda := {	{'BR_VERDE'   , STR0002 },; // Em Aberto
					{'BR_AMARELO' , STR0015 },; // Pendente de Aprovacao
					{'BR_BRANCO'  , STR0016 },; // Pre-Aprovado
					{'BR_AZUL'    , STR0017 },; // Aprovado
					{'BR_LARANJA' , STR0018 },; // Reprovado
					{'BR_PRETO'   , STR0003 },; // Finalizado
					{'BR_VERMELHO', STR0004 }}  // Cancelado
BrwLegenda(cCadastro,STR0010,aLegenda) // Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030F12³ Autor ³ Andre Luis Almeida                ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ F12 - Parametros da Rotina                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030F12(lMostra)
Local cPerg := "VXA030"
//
If lMostra
	SetKey(VK_F12, Nil )
EndIf
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte para Configuracao da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AADD(aRegs,{STR0012,STR0012,STR0012,"MV_CH1","N",1 ,0,2,"C",'',"MV_PAR01",STR0013,STR0013,STR0013,"","",STR0014,STR0014,STR0014,'','','','','','','','','','','','','','','','','','S','','','',''})
//
Pergunte(cPerg,lMostra,,,,.f.)
//
If lMostra
	SetKey(VK_F12,{ || VXA030F12(.t.) })
EndIf
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030OPORT³ Autor ³ Andre Luis Almeida              ³ Data ³ 10/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Incluir Fat.Direto atraves da tela de Oportunidade de Vendas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRecInter = RecNo's dos Interesses da Oportunidade de Vendas           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030OPORT(aRecInter)
Local cBkpFunName := FunName()
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
SetFunName("VEIXA030") 
nOpc := 3
dbSelectArea("VV9") 
VEIXA030(.T.,aRecInter)
SetFunName(cBkpFunName)
//
Return()