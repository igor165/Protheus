#Include "RwMake.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSATUTAB ºAutor  ³Geraldo Felix Jr.   º Data ³  09/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Migra o valor de cobranca do sub contrato para a familia    º±±
±±º          ³somente para pessoa juridica...                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PLATUFAI()

If ! Pergunte("PLSPFM", .T.)
	Return
Endif         

If  ! msgyesno("Este programa ira copiar os valores de faixa etaria do subcontrato para as familias")
    Return()
Endif    

MsAguarde({|| PlsAtuFam()}, "", "Migracao valor cobranca familia", .T.)

Return

Static Function PlsAtuFam

Local cCodQtd, cCodFor, nHeader
Local cAno := mv_par02, cMes := mv_par01

BA3->(DbSetOrder(1))
//BA3->(DbSeek(xFilial("BA3") + mv_par03 + mv_par05 ))

cSql := "SELECT R_E_C_N_O_ BA3REC FROM "+RetSqlName("BA3")+" WHERE "
cSql += "BA3_FILIAL = '"+xFilial("BA3")+"' "
cSql += "And BA3_CODINT >= '"+mv_par03+"' "
cSql += "And BA3_CODINT <= '"+mv_par04+"' "
cSql += "And BA3_CODEMP >= '"+mv_par05+"' "
cSql += "And BA3_CODEMP <= '"+mv_par06+"' "
cSql += "And BA3_MATRIC >= '"+mv_par07+"' "
cSql += "And BA3_MATRIC <= '"+mv_par08+"' "
cSql += "And D_E_L_E_T_ = ' ' "
PlsQuery(cSql, "TRB1")

While 	! TRB1->(Eof()) 
                                 
	// Posiciona a familia...
	BA3->( dbGoto(TRB1->BA3REC) )
	
	MsProcTXT("Atualizando familia Empresa "+BA3->BA3_CODEMP + " - Matricula "+ BA3->BA3_MATRIC)
    cCodFor := BA3->BA3_FORPAG
	If !Empty(cCodFor) .And. !BJK->(DbSeek(xFilial("BJK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC))

		BJ1->(MsSeek(xFilial("BJ1") + cCodFor))		
		DbSelectArea("BJK")
		RecLock("BJK", .T.)
		Replace BJK_FILIAL With xFilial("BJK"), BJK_CODOPE With BA3->BA3_CODINT,;
				BJK_CODEMP With BA3->BA3_CODEMP, BJK_MATRIC With BA3->BA3_MATRIC,;
				BJK_CODFOR With cCodFor, BJK_AUTOMA With "1"
		MsUnLock()
				
		nLido := 0
		
		If BA3->BA3_TIPOUS = "2"	// Pessoa Juridica - Valores da Mensalidade
			cCodQtd := PlsRetQtd(	BA3->BA3_CODINT, BA3->BA3_CODEMP, BA3->BA3_CONEMP, BA3->BA3_VERCON,;
									BA3->BA3_SUBCON, BA3->BA3_VERSUB, BA3->BA3_CODPLA, BA3->BA3_VERSAO,;
									cCodFor, "","","")
		
			cSQL := "SELECT * FROM " + RetSQLName("BTN")+" WHERE "
			cSQL += "BTN_FILIAL = '"+xFilial("BTN")+"' AND "
			cSQL += "BTN_CODIGO = '"+BA3->BA3_CODINT + BA3->BA3_CODEMP+"' AND "
			cSQL += "BTN_NUMCON = '"+BA3->BA3_CONEMP+"' AND "
			cSQL += "BTN_VERCON = '"+BA3->BA3_VERCON+"' AND "
			cSQL += "BTN_SUBCON = '"+BA3->BA3_SUBCON+"' AND "
			cSQL += "BTN_VERSUB = '"+BA3->BA3_VERSUB+"' AND "
			cSQL += "BTN_CODPRO = '"+BA3->BA3_CODPLA+"' AND "
			cSQL += "BTN_VERPRO = '"+BA3->BA3_VERSAO+"' AND "
			cSQL += "BTN_CODQTD = '"+Iif(cCodQtd=="ZZZ",'001',cCodQtd)+"' AND "
			cSQL += "BTN_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND BTN_CODFOR = '"+cCodFor + "' AND "
			cSQL += "D_E_L_E_T_ = '' AND BTN_TABVLD = (SELECT MAX(BTN_TABVLD) FROM " + RetSQLName("BTN")
			cSQL += " WHERE BTN_FILIAL = '"+xFilial("BTN")+"' AND "
			cSQL += "BTN_CODIGO = '"+BA3->BA3_CODINT + BA3->BA3_CODEMP+"' AND "
			cSQL += "BTN_NUMCON = '"+BA3->BA3_CONEMP+"' AND "
			cSQL += "BTN_VERCON = '"+BA3->BA3_VERCON+"' AND "
			cSQL += "BTN_SUBCON = '"+BA3->BA3_SUBCON+"' AND "
			cSQL += "BTN_VERSUB = '"+BA3->BA3_VERSUB+"' AND "
			cSQL += "BTN_CODPRO = '"+BA3->BA3_CODPLA+"' AND "
			cSQL += "BTN_VERPRO = '"+BA3->BA3_VERSAO+"' AND "
			cSQL += "BTN_CODQTD = '"+Iif(cCodQtd=="ZZZ",'001',cCodQtd)+"' AND "
			cSQL += "BTN_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND BTN_CODFOR = '"+cCodFor + "' AND "
			cSQL += "BTN_TABVLD <= '" + cAno + cMes + "' AND D_E_L_E_T_= '') " 
			cSQL += "ORDER BY BTN_CODFOR, BTN_TIPUSR DESC,BTN_GRAUPA DESC ,BTN_SEXO DESC"
		
			PLSQuery(cSQL,"TrbBTN")
			
			While ! TrbBTN->(Eof())
				nLido ++
				DbSelectArea("BBU")
				RecLock("BBU", .T.)
				Replace BBU_FILIAL With xFilial("BBU"), BBU_CODOPE With BA3->BA3_CODINT,;
						BBU_CODEMP With BA3->BA3_CODEMP, BBU_MATRIC With BA3->BA3_MATRIC,;
						BBU_AUTOMA With "1"
				For nHeader := 1 To BBU->(FCount())
					If (nPos := BTN->(FieldPos(StrTran(BBU->(FieldName(nHeader)), "BBU", "BTN")))) > 0
						Replace &("BBU->" + BBU->(FieldName(nHeader))) With TRBBTN->(FieldGet(nPos))
					Endif
				Next
				MsUnLock()
		
				TrbBTN->(DbSkip())
			EndDo
			TrbBTN->(DbCloseArea())
		Endif
		
		If BA3->BA3_TIPOUS = "1" .Or. nLido = 0	// Pessoa Fisica - Valores da Mensalidade
			cSQL := "SELECT * FROM " + RetSQLName("BB3")+" WHERE BB3_FILIAL = '"+xFilial("BB3")+"' AND "
			cSQL += "BB3_CODIGO = '"+BA3->BA3_CODINT + BA3->BA3_CODPLA+"' AND "
			cSQL += "BB3_VERSAO = '"+BA3->BA3_VERSAO+"' AND "
			cSQL += "BB3_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND BB3_CODFOR = '" + cCodFor + "' AND "
			cSQL += "D_E_L_E_T_= '' AND BB3_TABVLD = (SELECT MAX(BB3_TABVLD) FROM "
			cSQL += RetSQLName("BB3")+" WHERE BB3_FILIAL = '"+xFilial("BB3")+"' AND "
			cSQL += "BB3_CODIGO = '"+BA3->BA3_CODINT + BA3->BA3_CODPLA+"' AND "
			cSQL += "BB3_VERSAO = '"+BA3->BA3_VERSAO+"' AND "
			cSQL += "BB3_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND BB3_CODFOR = '" + cCodFor + "' AND "
			cSQL += "D_E_L_E_T_= '' AND BB3_TABVLD <= '" + cAno + cMes + "') "
			cSQL += "ORDER BY BB3_TIPUSR DESC ,BB3_GRAUPA DESC ,BB3_SEXO DESC "
			
			PLSQuery(cSQL,"TrbBB3")
		
			While ! TrbBB3->(Eof())
				DbSelectArea("BBU")
				RecLock("BBU", .T.)
				Replace BBU_FILIAL With xFilial("BBU"), BBU_CODOPE With BA3->BA3_CODINT,;
						BBU_CODEMP With BA3->BA3_CODEMP, BBU_MATRIC With BA3->BA3_MATRIC,;
						BBU_AUTOMA With "1"
				nLido ++
				For nHeader := 1 To BBU->(FCount())
					If (nPos := BB3->(FieldPos(StrTran(BBU->(FieldName(nHeader)), "BBU", "BB3")))) > 0
						Replace &("BBU->" + BBU->(FieldName(nHeader))) With TRBBB3->(FieldGet(nPos))
					Endif
				Next
				MsUnLock()

				TRBBB3->(DbSkip())
			EndDo
			TrbBB3->(DbCloseArea())
		Endif
		
		nLido := 0

		If BA3->BA3_TIPOUS = "2"	// Pessoa Juridica - Descontos da Mensalidade
			BFT->(DbSetOrder(1))
			BFT->(DbSeek(	xFilial("BFT") + BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_CONEMP +;
							BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB + BA3->BA3_CODPLA +;
							BA3->BA3_VERSAO + cCodFor + cCodQtd))
			While 	BFT->BFT_FILIAL = xFilial("BFT") .And.;
					BFT->BFT_CODIGO = BA3->BA3_CODINT + BA3->BA3_CODEMP .And.;
					BFT->BFT_NUMCON = BA3->BA3_CONEMP .And. BFT->BFT_VERCON = BA3->BA3_VERCON .And.;
					BFT->BFT_SUBCON = BA3->BA3_SUBCON .And. BFT->BFT_VERSUB = BA3->BA3_VERSUB .And.;
					BFT->BFT_CODPRO = BA3->BA3_CODPLA .And. BFT->BFT_VERPRO = BA3->BA3_VERSAO .And.;
					BFT->BFT_CODFOR = cCodFor .And. BFT->BFT_CODQTD = cCodQtd  .And. ! BFT->(Eof())

				DbSelectArea("BFY")
				RecLock("BFY", .T.)
				Replace BFY_FILIAL With xFilial("BFY"), BFY_CODOPE With BA3->BA3_CODINT,;
						BFY_CODEMP With BA3->BA3_CODEMP, BFY_MATRIC With BA3->BA3_MATRIC,;
						BFY_AUTOMA With "1"
				nLido ++
				For nHeader := 1 To BFY->(FCount())
					If (nPos := BFT->(FieldPos(StrTran(BFY->(FieldName(nHeader)), "BFY", "BFT")))) > 0
						Replace &("BFY->" + BFY->(FieldName(nHeader))) With BFT->(FieldGet(nPos))
					Endif
				Next
				MsUnLock()

				BFT->(DbSkip())
			EndDo
		Endif

		If BA3->BA3_TIPOUS = "1" .Or. nLido = 0	// Pessoa Fisica - Descontos da Mensalidade
			BFS->(DbSetOrder(1))
			BFS->(DbSeek(	xFilial("BFS") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO +;
							cCodFor))
			While 	BFS->BFS_FILIAL = xFilial("BFS") .And.;
					BFS->BFS_CODIGO = BA3->BA3_CODINT + BA3->BA3_CODPLA .And.;
					BFS->BFS_VERSAO = BA3->BA3_VERSAO .And. BFS->BFS_CODFOR = cCodFor .And.;
					! BFS->(Eof())
				DbSelectArea("BFY")
				RecLock("BFY", .T.)
				Replace BFY_FILIAL With xFilial("BFY"), BFY_CODOPE With BA3->BA3_CODINT,;
						BFY_CODEMP With BA3->BA3_CODEMP, BFY_MATRIC With BA3->BA3_MATRIC,;
						BFY_AUTOMA With "1"
				nLido ++
				For nHeader := 1 To BFY->(FCount())
					If (nPos := BFS->(FieldPos(StrTran(BFY->(FieldName(nHeader)), "BFY", "BFS")))) > 0
						Replace &("BFY->" + BFY->(FieldName(nHeader))) With BFS->(FieldGet(nPos))
					Endif
				Next
				MsUnLock()
				
				BFS->(DbSkip())
			EndDo
		Endif
	Endif
		
	TRB1->(DbSkip())
EndDo
TRB1->( dbCloseArea() )

Return

