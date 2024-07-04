#include "OFIXA012.CH"
#include "PROTHEUS.CH"

Static cMVMIL0006  := AllTrim(GetNewPar("MV_MIL0006","")) // Marca da Filial

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIXA012 ³ Autor ³ Luis Delorme                      ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pedido de Venda (Orçamento Fases) / Faturamento Parcial                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXA012()

Private cCadastro := STR0001
Private aRotina   := MenuDef()
Private nCloOrc   := .f.
Private nAviso    := 0
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
Private cMotivo := "000004"
Private nRecVS1020 := 0
Private lLibPV    := .f.
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de  Oficina e Auto Peças        //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIXA011","OFIOM350","OFIXA012" })
    Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if VAI->VAI_TIPTEC == "4"
	cFilVend := "VS1_CODVEN='"+VAI->VAI_CODVEN+"' AND VS1_TIPORC = 'P'"
else
	cFilVend := "VS1_TIPORC = 'P'"
endif
//
aCores := {{'VS1->VS1_PEDSTA == "0"','BR_VERDE'},; //aberto
           {'VS1->VS1_PEDSTA == "1"','BR_AMARELO'},; // parcial
           {'VS1->VS1_PEDSTA == "2"','BR_PRETO'},; // finalizado
           {'VS1->VS1_PEDSTA == "3"','BR_VERMELHO'}} // cancelado total

mBrowse( 6, 1,22,75,"VS1",,,,,,aCores,,,,,,,,cFilVend)
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA012V  ³ Autor ³ Luis Delorme                      ³ Data ³ 08/07/13 ³±±
±±³          ³ Visualização do Pedido                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012V(cAlias,nReg,nOpc)
//
lRet = OFIXX001(NIL,NIL,NIL,105)
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA012I  ³ Autor ³ Luis Delorme                      ³ Data ³ 08/07/13 ³±±
±±³          ³ Inclusão do Pedido                                                	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012I(cAlias,nReg,nOpc)
//
// Ponto de Entrada para validações antes de abrir a tela para Incluir
If ExistBlock("OA012INI")
	If !ExecBlock("OA012INI", .f., .f.)
		Return .f.
	EndIf
EndIf

lRet = OFIXX001(NIL,NIL,NIL,100)
nRecVS1020 := VS1->(Recno())
OXA012ATUVS1(nRecVS1020)
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA012CP ³ Autor ³ Luis Delorme                      ³ Data ³ 08/07/13 ³±±
±±³          ³ Cancelamento Parcial do Pedido                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012CP(cAlias,nReg,nOpc)
//
If VS1->VS1_PEDSTA == "3" // cancelou tudo
	MsgInfo(STR0017,STR0005)
	return .f.
Endif
If !OX012011_Valida_Usuario_Cancelamento_Pedido()
	return .f.
EndIf
//
nRecVS1020 := VS1->(Recno())
lRet = OFIXX001(NIL,NIL,NIL,101)
OXA012ATUVS1(nRecVS1020)
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA012CT ³ Autor ³ Luis Delorme                      ³ Data ³ 08/07/13 ³±±
±±³          ³ Cancelamento Total do Pedido                                        	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
5±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012CT(cAlias,nReg,nOpc)
Local aMotPed01  := {}
Local cMotCancel := ""
Local cMotivo := "000004"  //Filtro da consulta do motivo de Cancelamentos
Local cMotBo := ""
Local oPedido := DMS_Pedido():New()
//
If VS1->VS1_PEDSTA == "3" // cancelou tudo
	MsgInfo(STR0017,STR0005)
	return .f.
Endif
If !OX012011_Valida_Usuario_Cancelamento_Pedido()
	return .f.
EndIf
//
//If FM_SQL("")
//	return FMX_CancBOPed(cNumPed)
//EndIf
//
//cMotPed01 := OA012TMOT()
aMotPed01 := OFA210MOT(cMotivo,"4",xFilial("VS1"),VS1->VS1_NUMORC,.T.)
if len(aMotPed01) > 0
	cMotCancel := aMotPed01[1]
Endif

if cMotCancel = ""
	return .f.
endif
nRecVS1020 := VS1->(Recno())
DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
while VS3->VS3_FILIAL + VS3->VS3_NUMORC ==  xFilial("VS3")+VS1->VS1_NUMORC

	If oPedido:isBO({; // é back order? se for pode cancelar dependendo do VAI
			{ 'VS3_NUMORC', VS1->VS1_NUMORC },;
			{ 'VS3_CODITE', VS3->VS3_CODITE },;
			{ 'VS3_GRUITE', VS3->VS3_GRUITE },;
			{ 'VS3_SEQUEN', VS3->VS3_SEQUEN } ;
		})
		If Empty(cMotBo)
			cMotBo := OFA210MOT('000015',,,,.F.,)[1] // 15 => MOTIVO DO CANCELAMENTO DE BACKORDER
		EndIf
		oPedido:DelBoItem({; // é back order? se for pode cancelar dependendo do VAI
			{ 'VS3_NUMORC', VS1->VS1_NUMORC },;
			{ 'VS3_CODITE', VS3->VS3_CODITE },;
			{ 'VS3_GRUITE', VS3->VS3_GRUITE },;
			{ 'VS3_SEQUEN', VS3->VS3_SEQUEN },;
			{ 'MOTIVO'    , cMotBo          } ;
		})
	EndIf

	if VS3->VS3_QTDPED > 0
		reclock("VS3",.f.)
		VS3->VS3_QTDELI = VS3->VS3_QTDPED
		VS3->VS3_QTDPED := 0
		msunlock()
	endif
	If Empty(VS3->VS3_MOTPED)
		reclock("VS3",.f.)
		VS3->VS3_MOTPED := cMotCancel
		msunlock()
	EndIf
	DBSkip()
enddo
if VS3->(FieldPos("VS3_RESERV")) > 0 .and. VS1->(FieldPos("VS1_RESERV")) > 0
//	if VS1->VS1_RESERV == '1'
		cRetRes := OX001RESITE(VS1->VS1_NUMORC,.f., {"9999"})
		// desreserva
		if cRetRes <> "NA"
			if ExistBlock("ORDBUSCB")
				ExecBlock("ORDBUSCB",.f.,.f.,{"OR","CANCELA"})
			Endif
		Endif
//	endif
endif

if ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
	if FindFunction('OFAGVmi')
		oVmi := OFAGVmi():New()
		oVmi:Trigger({;
			{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
			{'ORIGEM'          , "OFIXA012_DMS4"  },;
			{'NUMERO_ORCAMENTO', VS1->VS1_NUMORC  } ;
		})
	endif
endif
OXA012ATUVS1(nRecVS1020)
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA012FP ³ Autor ³ Luis Delorme                      ³ Data ³ 08/07/13 ³±±
±±³          ³ Faturamento do Pedido                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012FP(cAlias,nReg,nOpc)
Local dDatVal := Ctod("")
Local nRecnoVS1 := 0
Local cQVE6     := "VE6SQL"
//
nRecVS1020 := VS1->(Recno())
nNumOrc020 := VS1->VS1_NUMORC
lRet = OFIXX001(NIL,NIL,NIL,103)
nRecNovoVS1 := VS1->(Recno())
nNumOrcNovo := VS1->VS1_NUMORC

cQuery := "SELECT VS1.R_E_C_N_O_ FROM "+RetSqlName("VS1")+" VS1 WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1.VS1_NUMORC = '"+nNumOrc020+"' "
cQuery += " AND VS1.D_E_L_E_T_ = ' '"
nRecNoVS1 := FM_SQL(cQuery)

VS1->(DbGoto(nRecVS1020))

OXA012ATUVS1(If(!(VS1->(eof())),nRecVS1020,nRecNoVS1))
If nRecNovoVS1 != nRecVS1020 .and. nNumOrc020 != nNumOrcNovo
	dDatVal := CriaVar("VS1_DATVAL")
	VS1->(DbGoTo(nRecNoVS1))
	RecLock("VS1",.f.)
	VS1->VS1_DATVAL := dDatVal
	MsUnlock()
Endif
cQuery := "SELECT VE6.R_E_C_N_O_ VE6RECNO FROM "+RetSQLName("VE6")+" VE6 "
cQuery += " WHERE VE6.VE6_FILIAL = '"+xFilial("VE6")+"'"
cQuery +=   " AND VE6.VE6_NUMORC = '" + nNumOrc020 + "'"
cQuery +=   " AND VE6.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQVE6, .F., .T. )

Do While !( cQVE6 )->( eof() )
	DbSelectArea("VE6")
	DbGoTo( ( cQVE6 )->( VE6RECNO ) )
	RecLock("VE6",.f.)
	VE6->VE6_NUMORC := nNumOrcNovo
	MsUnlock()
	dbSelectArea(cQVE6)
	( cQVE6 )->(dbSkip())
Enddo
(cQVE6)->(DbCloseArea())


//
VS1->(DBGoTo(nRecNovoVS1))
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA012FP ³ Autor ³ Luis Delorme                      ³ Data ³ 08/07/13 ³±±
±±³          ³ Alteraçao do Pedido                                                 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012A(cAlias,nReg,nOpc)
//
lRet = OFIXX001(NIL,NIL,NIL,104,,lLibPV)
nRecVS1020 := VS1->(Recno())
cNumOrc020 := VS1->VS1_NUMORC
OXA012ATUVS1(nRecVS1020)
//
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA012AX ³ Autor ³ Thiago			                    ³ Data ³ 22/02/16 ³±±
±±³          ³ Alteraçao do Pedido                                                 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012AX(cAlias,nReg,nOpc,lAtuTipOrc)
Default lAtuTipOrc := .t.  // .t. atualizar o VS1_TIPORC
//
lRet = OFIXX001(NIL,NIL,NIL,106,,lLibPV,lAtuTipOrc)
nRecVS1020 := VS1->(Recno())
cNumOrc020 := VS1->VS1_NUMORC
OXA012ATUVS1(nRecVS1020)
//
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA012ATUVS1³ Autor ³ Luis Delorme                    ³ Data ³ 08/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o Status do Pedido de Venda conforme os Itens                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012ATUVS1(nRecVS1020)

VS1->(DBGoTo(nRecVS1020))
if VS1->(eof())
	return
endif
DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
lTemCancel := .f.
lTemFaturado := .f.
lTemAberto := .f.
while xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
	if VS3->VS3_QTDPED < VS3->VS3_QTDINI  // se a quantidade pendente for menor que a inicial, algum item sofreu alteração
		if VS3->VS3_QTDELI > 0 // se a quantidade eliminada for maior que zero a alteração foi um cancelamento
			lTemCancel := .t.
		else					// senão a alteração foi um faturamento
			lTemFaturado := .t.
		endif
	endif
	if VS3->VS3_QTDPED > 0 // se a quantidade pendente for maior que zero então ainda está aberto
		lTemAberto := .t.
	endif
	reclock("VS3",.f.)
	VS3->VS3_QTDITE := VS3->VS3_QTDPED
	MsUnlock()
	DBSkip()
enddo
//
DBSelectArea("VS1")
reclock("VS1",.f.)
//
if !ALTERA  // Nao alterar status quando for alteração
	if lTemCancel .and. !lTemFaturado .and. !lTemAberto
		VS1->VS1_PEDSTA := "3" // cancelou tudo
	elseif lTemFaturado .and. !lTemAberto
		VS1->VS1_PEDSTA := "2" // finalizado (pode ter um ou outro cancelado)
	elseif lTemFaturado .and. lTemAberto
		VS1->VS1_PEDSTA := "1"
	else
		VS1->VS1_PEDSTA := "0"
	endif
Endif
//
msunlock()

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OA012TMOT ³ Autor ³ Luis Delorme                      ³ Data ³ 08/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela questionando o motivo do cancelamento dos itens                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA012TMOT()
Local cMotCort := Space(6)
Local lGrava   := .f.

DEFINE MSDIALOG oDlgCorte FROM 000,000 TO 100,320 TITLE ("") OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS//bonus do veiculo
oDlgCorte:lEscClose := .F.

@ 005,006 SAY STR0002 SIZE 150,08 OF oDlgCorte PIXEL FONT oFnt3
@ 020,006 SAY STR0003 SIZE 50,08 OF oDlgCorte PIXEL  //Motivo
@ 020,027 MSGET oMotivo VAR cMotCort F3 "VS0" PICTURE "@!" SIZE 50,06 OF oDlgCorte PIXEL

DEFINE SBUTTON FROM 038,105 TYPE 1 ACTION (iif(Empty(cMotCort) .or. !(VS0->(DBSeek(xFilial("VS0")+"000004"+Alltrim(cMotCort)))),MsgInfo(STR0004,STR0005),(lGrava := .t.,oDlgCorte:End()))) ENABLE OF oDlgCorte
DEFINE SBUTTON FROM 038,132 TYPE 2  ACTION (oDlgCorte:End()) ENABLE OF oDlgCorte

ACTIVATE MSDIALOG oDlgCorte CENTER

if !(lGrava)
	return ""
endif

return cMotCort
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Orcamento de Pecas e Servicos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {;
{ OemtoAnsi(STR0006),"AxPesqui" 		, 0 , 1},;
{ OemtoAnsi(STR0007),"OXA012V"    		, 0 , 2},;
{ OemtoAnsi(STR0008),"OXA012I"    		, 0 , 3},;
{ OemtoAnsi(STR0018),"OXA012A"    		, 0 , 4},;
{ OemtoAnsi(STR0009),"OXA012CP"    		, 0 , 5},;
{ OemtoAnsi(STR0010),"OXA012CT"    		, 0 , 5},;
{ OemtoAnsi(STR0011),"OXA012FP"    		, 0 , 6},;
{ OemtoAnsi(STR0012),"OXA012Leg"		, 0 , 8} }
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA012LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Orcamento de Pecas e Servicos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA012LEG(nReg)
Local uRetorno := .t.
Local aLegenda := {}
Local nCont := 0

// Se aumentar a matriz de cores e/ou a matriz de legenda verificar o tratamento depois da execucao do PE OA011COR
// para a criacao da matriz uRetorno
If nReg == nil
   uRetorno := {}
	aLegenda := {{'BR_VERDE',STR0013},;
					   {'BR_AMARELO',STR0014},;
					   {'BR_PRETO',STR0015},;
					   {'BR_VERMELHO',STR0016}}

	For nCont := 1 to Len(aCores)
		AADD( uRetorno , { aCores[nCont,01] , aLegenda[nCont,01] , aLegenda[nCont,02] } )
	Next nCont

Else
	aLegenda := {{'BR_VERDE',STR0013},;
					   {'BR_AMARELO',STR0014},;
					   {'BR_PRETO',STR0015},;
					   {'BR_VERMELHO',STR0016}}

	If ( ExistBlock("OX012LEG") )
		aLegenda := ExecBlock("OX012LEG",.f.,.f.,{aLegenda})
	EndIf

	BrwLegenda(cCadastro,STR0001,aLegenda)
Endif

//
Return uRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OX012MOT ³ Autor ³ Thiago 						    ³ Data ³ 04/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Motivos item a item.									                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX012MOT(cTpAssunto,cMotCort,cTipOri,cFilOri,cCodOri,aQuestMot,cCancParc)

Local aObjects    := {} , aPos := {} , aInfo := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nOpcE := 2
Local nOpcG := 4
Local cLinOk := ""
Local cTudOk := ""
Local cFieldOk := ""
Local nCntFor := 0
Local i := 0
Local _ni := 0
Local y := 0
Local cSQLVS3 := "SQLVS3"
Local nOpcA := 0
Default cCancParc := "T"

cLinOk   := "FG_OBRIGAT()"
cFieldOk := "FG_MEMVAR() .AND. OX012FOK()"
cTudOk := ""


aHeaderM := {}
aAdd(aHeaderM,{RetTitle("VS3_GRUITE"),"VS3_GRUITE","@!",TamSx3("VS3_GRUITE")[1],TamSx3("VS3_GRUITE")[2],"","","C","",""})
aAdd(aHeaderM,{RetTitle("VS3_CODITE"),"VS3_CODITE","@!",TamSx3("VS3_CODITE")[1],TamSx3("VS3_CODITE")[2],"","","C","",""})
aAdd(aHeaderM,{RetTitle("VS3_DESITE"),"VS3_DESITE","@!",TamSx3("VS3_DESITE")[1],TamSx3("VS3_DESITE")[2],"","","C","",""})
aAdd(aHeaderM,{STR0021,"VS3_MOTPED","@!",TamSx3("VS3_MOTPED")[1],TamSx3("VS3_MOTPED")[2],"","","C","",""})

nUsado:=0
aColsM := {}

if cCancParc <> "P"
	cQuery := "SELECT VS3.VS3_GRUITE,VS3.VS3_CODITE,SB1.B1_DESC "
	cQuery += "FROM " + RetSQLName("VS3") + " VS3"
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND VS3.VS3_GRUITE = SB1.B1_GRUPO AND VS3.VS3_CODITE = SB1.B1_CODITE AND SB1.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE VS3.VS3_FILIAL = '"+xFilial("VS3")+"' AND VS3.VS3_NUMORC = '"+VS1->VS1_NUMORC+"' AND VS3.D_E_L_E_T_ = ' '"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVS3 , .F. , .T. )
	i := 0
	While !(cSQLVS3)->(Eof())

		i += 1
		Aadd(aColsM, Array(Len(aHeaderM)+1) )
		aColsM[1,5]:=.F.
		For _ni:=1 to 4
			aColsM[i,_ni]:=CriaVar(aHeaderM[_ni,2])
	  	Next
		aColsM[i,1] := (cSQLVS3)->VS3_GRUITE
		aColsM[i,2] := (cSQLVS3)->VS3_CODITE
		aColsM[i,3] := (cSQLVS3)->B1_DESC
		aColsM[i,4] := cMotCort
		aColsM[i,5] := .f.

		dbSelectArea(cSQLVS3)
		(cSQLVS3)->(dbSkip())

	Enddo
	(cSQLVS3)->(DbCloseArea())
Else
	For y := 1 to Len(oGetPecas:aCols)
      if oGetPecas:aCols[y,Len(oGetPecas:aCols[y])]
			i += 1
			Aadd(aColsM, Array(Len(aHeaderM)+1) )
			aColsM[1,5]:=.F.
			For _ni:=1 to 4
				aColsM[i,_ni]:=CriaVar(aHeaderM[_ni,2])
	  		Next
			aColsM[i,1] := oGetPecas:aCols[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]
			aColsM[i,2] := oGetPecas:aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")]
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+oGetPecas:aCols[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+oGetPecas:aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")]  )
			aColsM[i,3] := SB1->B1_DESC
			aColsM[i,4] := cMotCort
			aColsM[i,5] := .f.
		Endif
	Next
Endif

aCpoAlt := {}
aAdd(aCpoAlt,"VS3_MOTPED")
M->VS3_MOTPED := space(TamSX3("VS3_MOTPED")[1])

// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Finame
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE STR0020 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Finame

  oGetDadosMot := MsNewGetDados():New(aPos[1,1]+004,aPos[1,2],aPos[1,3],aPos[1,4],3,cLinOk,cTudOk,,aCpoAlt,0,999,cFieldOk,,"",,aHeaderM,aColsM )

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||(nOpcA:=1,oDlg:End())},{||oDlg:End()},,)

if nOpcA == 1
	For i := 1 to Len(aColsM)
		dbSelectArea("VS3")
		dbSetOrder(2)
		if dbSeek(xFilial("VS3")+VS1->VS1_NUMORC+aColsM[i,1]+aColsM[i,2])
			While !eof() .and.  VS3->VS3_FILIAL+VS3->VS3_NUMORC+VS3->VS3_GRUITE+VS3->VS3_CODITE == xFilial("VS3")+VS1->VS1_NUMORC+aColsM[i,1]+aColsM[i,2]
				If !Empty(VS3->VS3_MOTPED)
					DbSkip()
					Loop
				Endif
				RecLock("VS3",.f.)
				VS3->VS3_MOTPED := aColsM[i,4]
				if VS3->VS3_QTDELI == 0 .and. !Empty(VS3->VS3_MOTPED)
					VS3->VS3_QTDELI := VS3->VS3_QTDITE
				endif
				MsUnlock()                  
	     		If FM_SQL("SELECT VDT.R_E_C_N_O_ RECVDT FROM "+RetSQLName("VDT")+" VDT WHERE VDT.VDT_FILIAL='"+xFilial("VDT")+"' AND VDT.VDT_TIPORI= '4' AND VDT.VDT_FILORI = '"+VS1->VS1_FILIAL+"' AND VDT.VDT_CODMOT = '"+aColsM[i,4]+"' AND VDT.VDT_CODORI = '"+VS1->VS1_NUMORC+"' AND VDT.D_E_L_E_T_ = ' '") == 0
					OFA210VDT(cTpAssunto,aColsM[i,4],cTipOri,cFilOri,cCodOri,aQuestMot)
				Endif
				DbSkip()
			Enddo
		Endif
	Next
Endif


Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OX012FOK ³ Autor ³ Thiago 						    ³ Data ³ 04/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Motivos fieldok.										                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX012FOK()

if ReadVar() == "M->VS3_MOTPED"
	aColsM[oGetDadosMot:nAt,4] := M->VS3_MOTPED
Endif

oGetDadosMot:oBrowse:Refresh()

Return(.t.)

/*/{Protheus.doc} OX012011_Valida_Usuario_Cancelamento_Pedido
Valida se o usuario tem permissao para cancelar o Pedido

@author Andre Luis Almeida
@since 26/03/2021
/*/
Static Function OX012011_Valida_Usuario_Cancelamento_Pedido()
If ( VAI->(ColumnPos("VAI_CANCPR")) > 0 ) // Campo de Permissao do Usuario para Cancelar/Deletar Pecas ja Reservadas?
	If VS1->VS1_STARES $ "12" .or. FM_SQL("SELECT SUM(VS3_QTDRES) FROM " + retsqlname('VS3') + " WHERE VS3_FILIAL='"+xFilial('VS3')+"' AND VS3_NUMORC='"+VS1->VS1_NUMORC+"' AND D_E_L_E_T_=' '") > 0
		//Verificar se o usuario pode cancelar/deletar uma Peca ja Reservada
		VAI->(DbSetOrder(4))
		VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
		If VAI->VAI_CANCPR == '0' // Sem permissão para Cancelar
			MsgStop(STR0022,STR0005) // Usuário sem permissão para Cancelar o Pedido com Peças já Reservadas. Impossivel continuar. / Atencao
			return .f.
		EndIf
	EndIf
EndIf
Return .t.