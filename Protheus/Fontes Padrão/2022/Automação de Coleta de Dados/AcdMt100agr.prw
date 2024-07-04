#include "protheus.ch" 
#include "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ CBMT100AGR  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 22/04/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Realiza o enderecamento automatico p/ o CQ na classificacao  ³±±
±±³          ³  da Nota									                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
Function CBMT100AGR()
Local aCB0			:= {}
Local aSD7			:= {}
Local aQEK			:= {}
Local cAlias		:= ""
Local cQuery		:= ""
Local cCqLocal	:= GetMvNNR('MV_CQ','98')

Private lMsErroAuto := .f.
Private lMsHelpAuto := .t.

If !SuperGetMV("MV_CBPE009",.F.,.F.)
	Return .t.
EndIf       

If l103Class .And. (SD1->D1_LOCAL == cCqLocal) 
	CBNFEDistAut(SD1->D1_COD,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA)
EndIf		

If (SA2->A2_IMPIP == "4") .Or. (SA2->A2_IMPIP $ "03 " .And. SuperGetMv("MV_IMPIP",.F.,"3") == "4" )
	If Inclui .or. Altera
		ACDI10NF(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.,(__cInternet == "AUTOMATICO"))
		SD1->(dbSeek(xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		While SD1->(!EOF() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA ==  ;
			xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			If SD1->D1_LOCAL == cCqLocal
				CBNFEDistAut(SD1->D1_COD,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA)
			EndIf 
			SD1->(dbSkip())
		EndDo
	EndIf
				EndIf

If UsaCB0("01") .And. (Inclui .or. Altera)
	aCB0 := CB0->(GetArea())
	aQEK := QEK->(GetArea())
	aSD7 := SD7->(GetArea())

			cAlias := GetNextAlias()
		
			cQuery := "SELECT D7_DOC,D7_SERIE,D7_FORNECE,D7_LOJA,D7_PRODUTO,D7_LOCDEST "
			cQuery += "FROM "+RetSqlName("SD7")+" SD7, "+RetSqlName("QEK")+" QEK "
			cQuery += "WHERE SD7.D7_FILIAL = QEK.QEK_FILIAL "
			cQuery += "AND D7_DOC||D7_SERIE||D7_FORNECE||D7_LOJA||D7_PRODUTO = QEK_NTFISC||QEK_SERINF||QEK_FORNEC||QEK_LOJFOR||QEK_PRODUT "
			cQuery += "AND QEK.QEK_VERIFI = 2 "
			cQuery += "AND SD7.D7_TIPO = 1 "
			cQuery += "AND SD7.D7_FILIAL = '"+xFilial("SD7")+"' "
			cQuery += "AND SD7.D7_DOC = '"+SF1->F1_DOC+"' "
			cQuery += "AND SD7.D7_SERIE = '"+SF1->F1_SERIE+"' "
			cQuery += "AND SD7.D_E_L_E_T_ = ' ' "
			cQuery += "AND QEK.D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

			CB0->(DbSetOrder(6))	// CB0_FILIAL+CB0_NFENT+CB0_SERIEE+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO
			
			While (cAlias)->(!Eof())
				If Localiza((cAlias)->D7_PRODUTO)
					CB0->(MsSeek(xFilial("CB0")+(cAlias)->(D7_DOC+D7_SERIE+D7_FORNECE+D7_LOJA+D7_PRODUTO)))
					While CB0->(!Eof()) .And. ;
						xFilial("CB0")+(cAlias)->D7_DOC+(cAlias)->D7_SERIE+(cAlias)->D7_FORNECE+(cAlias)->D7_LOJA+(cAlias)->D7_PRODUTO ==;
						CB0->CB0_FILIAL+CB0->CB0_NFENT+CB0->CB0_SERIEE+CB0->CB0_FORNEC+CB0->CB0_LOJAFO+CB0->CB0_CODPRO

						RecLock("CB0",.F.)
						CB0->CB0_LOCAL	= (cAlias)->D7_LOCDEST
						CB0->CB0_LOCALI	= ""
						CB0->(MsUnlock())
						CB0->(DbSkip())
					EndDo
				EndIf
				(cAlias)->(DbSkip())
			EndDo
			
			(cAlias)->(DbCloseArea())
	
	CB0->(RestArea(aCB0))
	QEK->(RestArea(aQEK))
	SD7->(RestArea(aSD7))
EndIf

If __cInternet == "AUTOMATICO"
   Return .t.
Endif

If ! Empty(GetMV("MV_CBCQEND")) .And. Empty(GetMV("MV_DISTAUT"))
	If IsTelnet()
		DistriCQ(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA)
	Else
		Processa({||DistriCQ(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA)})
	EndIf
EndIf

Return .t.
