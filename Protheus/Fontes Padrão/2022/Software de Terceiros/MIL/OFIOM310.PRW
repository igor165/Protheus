// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "FILEIO.CH"
#Include "OFIOM310.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM310 | Autor ³  Silvio Gregorio      ³ Data ³29/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao:³ criar tela de manutencao do preco de venda.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM310
//parametros do sistema:
Private GET_GRUPO  := space(len(SB1->B1_GRUPO))	// Grupo  Produto
Private GET_CODIGO := space(len(SB1->B1_CODITE))	// Cod.Item
Private cCodProd   := space(len(SB1->B1_COD))		// Codigo Produto Siga
Private nValor   := 0          // Preco Venda
Private nValor2  := 0          // Preco Reposicao
Private nValor3  := 0          // Preco Garantia
_walias:=alias()
_worder:=indexord()
_wrecno:=recno()

DbSelectArea("SB1")  // tabela de produtos
_wordsb1:=indexord()
_wrecsb1:=recno()
DbSetOrder(7)
DbGoTop()

DbSelectArea("SB5")  // dados adicionais do produto
_wordsb5:=indexord()
_wrecsb5:=recno()
DbSetOrder(1)
DbGoTop()

DEFINE MSDIALOG oDlg1 FROM 001,000 TO 017,057 TITLE STR0001 OF oMainWnd

@ 010,003 Say STR0002 PIXEL COLOR CLR_BLUE
@ 010,050 MSGET OBJ1 VAR GET_GRUPO picture "@k!" F3 "BM2" valid ( vazio() .or. SBM->(DbSeek(xFilial("SBM")+ GET_GRUPO)) ) of ODLG1 PIXEL COLOR CLR_BLACK

@ 030,003 Say STR0003 PIXEL COLOR CLR_BLUE
@ 030,050 MSGET OBJ2 VAR GET_CODIGO picture "@!" F3 "B11" valid FG_POSSB1("GET_CODIGO","SB1->B1_CODITE","GET_GRUPO") .and. FS_AP_ARMAZ() of ODLG1 PIXEL COLOR CLR_BLACK

@ 050,003 SAY   STR0004 PIXEL
@ 050,050 MSGET OBJ3 VAR nValor PICTURE "@E 999,999.99" SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_HBLUE

@ 070,003 Say STR0005 PIXEL
@ 070,050 MSGET OBJ4 VAR nValor2 PICTURE "@E 999,999.99" SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_HBLUE

@ 090,003 Say STR0006 PIXEL
@ 090,050 MSGET OBJ5 VAR nValor3 PICTURE "@E 999,999.99" SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_HBLUE

DEFINE SBUTTON FROM 107,130 TYPE 1 ACTION FS_AP_ATUAL() ENABLE OF oDlg1 when (!Empty(GET_GRUPO) .and. !Empty(GET_CODIGO)) // .and. nValor>0 .and. nValor2>0 .and. nValor3>0)
DEFINE SBUTTON FROM 107,160 TYPE 2 ACTION oDlg1:END() ENABLE OF oDlg1

ACTIVATE DIALOG oDlg1 CENTERED


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma |FS_AP_ARMAZ     º Autor ³ Silvio Gregorio    º Data ³29/04/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Armazena Precos de Venda do SB1 e SB5                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AP_ARMAZ

DbSelectArea("SB1")
DbSetOrder(7)
SB1->(DbSeek(xFilial("SB1") + GET_GRUPO + GET_CODIGO))
cCodProd := SB1->B1_COD    // recebe o valor do codigo do produto
nValor   := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")	// atribui o valor do preco de venda.

DbSelectArea("SB5")
DbSetOrder(1)
If DbSeek( xFilial() + cCodProd) // se achou produto
	nValor2 := SB5->B5_PRV2        // preco de reposicao.
	nValor3 := SB5->B5_PRV3        // preco de garantia.
Endif

OBJ3:SETFOCUS() // atualiza campo de preco de venda
OBJ4:SETFOCUS() // atualiza campo de preco de reposicao
OBJ5:SETFOCUS() // atualiza campo de preco de garantia

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma |FS_AP_ATUAL     º Autor ³ Silvio Gregorio    º Data ³29/04/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Atualiza preco do produto no SB1 e SB5                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AP_ATUAL
Local lBZ_PRV1   := ( SBZ->(FieldPos("BZ_PRV1")) > 0 )
Local cQuery     := ""
Local nRecSBZ    := 0
Local cDadosProd := SuperGetMV("MV_ARQPROD",.F.,"SB1")
DbSelectArea("SB1")
DbSetOrder(7)
if SB1->(DbSeek(xFilial("SB1") + GET_GRUPO + GET_CODIGO)) // se achou produto no SB1
	If cDadosProd == "SBZ" .and. lBZ_PRV1
		cQuery := "SELECT SBZ.R_E_C_N_O_ AS RECSBZ FROM "+RetSQLName("SBZ")+" SBZ WHERE "
		cQuery += "SBZ.BZ_FILIAL='"+xFilial("SBZ")+"' AND SBZ.BZ_COD='"+SB1->B1_COD+"' AND SBZ.D_E_L_E_T_=' '"
		nRecSBZ := FM_SQL(cQuery)
		If nRecSBZ > 0
			DbSelectArea("SBZ")
			DbGoTo(nRecSBZ)
			Reclock("SBZ",.F.)  // trava o registro para atualizacao.
			SBZ->BZ_PRV1 := nValor
			MsUnLock()
		EndIf
	EndIf
	DbSelectArea("SB1")
	reclock("SB1",.F.)  // trava o registro para atualizacao.
	SB1->B1_PRV1 := nValor
	msunlock()          // libera registro atualizado.
endif
DbSelectArea("SB5")
if DbSeek( xFilial() + cCodProd) // se achou produto no SB5
	reclock("SB5",.F.)
	SB5->B5_PRV2 := nValor2    // preco de reposicao
	SB5->B5_PRV3 := nValor3    // preco de garantia
	msunlock()
endif

MsgInfo(STR0007,STR0008)

GET_GRUPO  := space(len(SB1->B1_GRUPO))	// Grupo  Produto
GET_CODIGO := space(len(SB1->B1_CODITE))	// Cod.Item
cCodProd   := space(len(SB1->B1_COD))		// Codigo Produto Siga

nValor   := 0
nValor2  := 0
nValor3  := 0

OBJ1:SETFOCUS()
OBJ2:SETFOCUS()
OBJ3:SETFOCUS()
OBJ4:SETFOCUS()
OBJ5:SETFOCUS()

DbSelectArea("SB1")              // volta ao registro do inicio
DbSetOrder(_wordsb1)
DbGoTo(_wrecsb1)

DbSelectArea("SB5")					// volta ao registro do inicio
DbSetOrder(_wordsb5)
DbGoTo(_wrecsb5)

Return