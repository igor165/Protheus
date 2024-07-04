#INCLUDE "TMSA970.ch"
#INCLUDE "PROTHEUS.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA970     ³ Autor ³ Rodrigo Gomes       ³ Data ³28/09/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Reajuste dos preços de Pedágio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA970                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA970()
Local cPerg		:= "TMA970"
Local aSays		:= {}
Local aButtons	:= {}
Local cCadastro	:= STR0001 //"Reajuste dos preços de Pedágio"
Local lEnd      := .F.
Local nOpcx     := 0

// -- Se a rotina de Reajuste dos precos de Pedágio estiver sendo executada por outro
// -- usuario o sistema nao efetua o reajuste 
If !LockByName("REAJPDG",.T.,.F.)
	Help("",1,"TMSA97002") //O Reajuste dos preços de Pedágio está sendo efetuado por outro usuário.
	UnLockByName("REAJPDG",.T.,.F.) // Libera Lock
	Return( Nil )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

Aadd( aSays, STR0002 ) //"Esta rotina tem como objetivo reajustar automaticamente os valores"
Aadd( aSays, STR0003 ) //'para Faturamento, conforme parametro estipulado pelo usuario.' //"dos pedágios de acordo com os parâmetros informados."
Aadd( aSays, STR0004 ) //"Confirma Reajuste dos preços de Pedágio?"

Aadd( aButtons, { 1, .T., {|o| nOpcx := 1, o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
Aadd( aButtons, { 5, .T., {|| Pergunte(cPerg,.T.) } } )

FormBatch( cCadastro, aSays, aButtons )

If nOpcx == 1
	// -- Chama a rotina responsavel por reajustar os valores de pedagios
	MsgRun(STR0005,,{|| TMSA970Ger() }) //"Gerando Reajuste dos preços de Pedágio ..."
EndIf

UnLockByName("REAJPDG",.T.,.F.) // Libera Lock

Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA970Ger  ³ Autor ³ Rodrigo Gomes		³ Data ³28/09/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processamento do Reajuste dos preços de Pedágio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA970                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/

Static Function TMSA970Ger()
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local lTabDYP   := AliasIndic("DYP")

// -- Executa a query contendo os Recnos do arquivo DU0, para posicionamento e
// -- alteracao dos campos DU0_RECNO e DU0_VALEIX, com o percentual de reajuste
cQuery := " SELECT DU0.R_E_C_N_O_ DU0_RECNO "
cQuery += " FROM " + RetSqlName("DA8") + " DA8, " + RetSqlName("DU2") + " DU2, " + RetSqlName("DU0") + " DU0 "
cQuery += " WHERE DA8_FILIAL = '"+xFilial("DA8")+"' "
cQuery += "	AND DA8_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cQuery += "	AND DA8_ATIVO  = '1' "
cQuery += "	AND DA8_TIPTRA = '1' "
cQuery += "	AND DA8.D_E_L_E_T_ = ' ' "
//-- Rotas x Rodovias 
cQuery += "	AND DU2_FILIAL = '"+xFilial("DU2")+"' "
cQuery += "	AND DU2_ROTA   = DA8_COD "
cQuery += "	AND DU0_FILIAL = '"+xFilial("DU0")+"' "
cQuery += "	AND DU0_CODROD = DU2_CODROD "
cQuery += "	AND DU0_SEQPDG = DU2_SEQPDG "
cQuery += "	AND DU2.D_E_L_E_T_ = ' ' "
//-- Pracas de Pedagio 
cQuery += "	AND DU0_CODFOR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR03+"' "
cQuery += " AND DU0_LOJFOR BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"' "
cQuery += "	AND DU0.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
While (cAliasQry)->(!eof())
	DU0->(dbGoto((cAliasQry)->DU0_RECNO))
	RecLock('DU0',.F.)
	DU0->DU0_VALEIX += (DU0->DU0_VALEIX * (MV_PAR07/100))
	DU0->DU0_VALVEI += (DU0->DU0_VALVEI * (MV_PAR07/100)) 
	MsUnLock()
	//----- Praça de Pedagio por Catgoria
	If lTabDYP                      
		DYP->(dBSetOrder(1))
		If DYP->(dbSeek(xFilial('DYP')+DU0->DU0_CODROD+DU0->DU0_SEQPDG))
			While DYP->(DYP_FILIAL+DYP_CODROD+DYP_SEQPDG) == xFilial('DYP')+DU0->(DU0_CODROD+DU0_SEQPDG)
				If DYP->DYP_VALOR > 0
					RecLock('DYP',.F.)
					DYP->DYP_VALOR += (DYP->DYP_VALOR * (MV_PAR07/100))
					MsUnlock()
				EndIf
				DYP->(DbSkip())
			EndDo
		EndIf	
	EndIf                           
	(cAliasQry)->(DbSkip())
EndDo
ApMsgInfo(STR0006) //"Reajuste dos preços de pedágio realizado com sucesso."

(cAliasQry)->(dbCloseArea())
RestArea(aArea)
Return( Nil )
