// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º  03    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#INCLUDE "VEIVM510.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVM510 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 28/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao de Comissoes/Premiacoes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM510()
Private aRotina   := MenuDef()
Private cCadastro := STR0001 // Manutencao de Comissoes/Premiacoes

mBrowse( 6, 1,22,75,"VD2",,,,,,)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VM510Ger ³ Autor ³ Andre Luis Almeida    ³ Data ³ 28/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerar Comissoes/Premiacoes                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM510Ger()
	Processa( { || FS_GerVD2() } )
Return()
//////////////// Gerar Comissoes/Premiacoes ////////////////
Static Function FS_GerVD2()
Local cCpoDet   := ""
Local cCpoBas   := ""
Local cCpoBasS  := ""
Local cCodVZ8   := ""
Local cCodSup   := ""
Local aStru     := {}
Local cDescVOQ  := ""
Local aRet      := {}
Local aParamBox := {}
Local dDatIni   := ( ( dDataBase - day(dDataBase) ) + 1 )
Local dDatFin   := dDataBase
Local cQuery    := ""
Local cSQLAlias := "SQLVV90A"
Local cSQLVS9   := "SQLVS9"
Local cAdmCon   := ""
Local aVended   := {}
Local aValVZ8   := {0,0,0,0,0}
Local aVD1      := {}
Local cOrd      := ""
Local nPos      := 0
Local nVlr      := 0
Local nVlrQ     := 0
Local nVlrT     := 0
Local ni        := 0
Local dDatAux   := ctod("")
Local cQAux10   := ""
Local cQAux20   := ""
Local cQAux30   := ""
Local cQAux31   := ""
Local cQAux40   := ""
Local cQAux41   := ""
Local cQAux50   := ""
Local cQAux51   := ""
Local cQAux60   := ""
Local cQAux61   := ""
Local cQAux70   := ""
Local nRecVZ8   := 0
Local cTipo     := "3"
Local aTipo     := {("1="+STR0038),("2="+STR0039),("3="+STR0031)} // Comissao / Premiacao / Comissao/Premiacao
Private cCodMap := space(3)
AADD(aParamBox,{1,STR0006,dDatIni,"@D","","",".T.",50,.t.}) // Data Inicial
AADD(aParamBox,{1,STR0007,dDatFin,"@D","MV_PAR02 >= MV_PAR01","",".T.",50,.t.}) // Data Final
AADD(aParamBox,{2,STR0011,cTipo,aTipo,80,"Pertence('123')",.t.}) // Tipo

If ParamBox(aParamBox,STR0028,@aRet,,,,,,,,.f.) // Parametros
	dDatIni := aRet[01] // Data Inicial
	dDatFin := aRet[02] // Data Final
	cTipo   := aRet[03] // Tipo

	If cTipo $ "1/3" // 1-Comissao ou 3-Comissao/Premiacao

		ProcRegua( ( dDatFin - dDatIni ) )
		IncProc(STR0008) // Gerando Comissoes
		
		/////////////////////////////////////////////////////
		// Levanta os Atendimentos Finalizados no periodo  //
		/////////////////////////////////////////////////////
		cQuery := "SELECT VV9.R_E_C_N_O_ AS RECVV9 , VV0.R_E_C_N_O_ AS RECVV0 , VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VV0")+" VV0 "
		cQuery += "JOIN "+RetSQLName("VV9")+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS='F' AND VV9.D_E_L_E_T_=' ' "
		cQuery += "JOIN "+RetSQLName("VVA")+" VVA ON VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND VV0.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY VV0.VV0_DATMOV , VV0.VV0_NUMTRA "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			dbSelectArea("VV9")
			dbGoTo( (cSQLAlias)->( RECVV9 ) )
			dbSelectArea("VV0")
			dbGoTo( (cSQLAlias)->( RECVV0 ) )
			dbSelectArea("VVA")
			dbGoTo( (cSQLAlias)->( RECVVA ) )
			VV1->(DbSetOrder(1))
			VV1->(DbSeek( xFilial("VV1") + VVA->VVA_CHAINT ))
			VV2->(DbSetOrder(1))
			VV2->(DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI ))
	
			If dDatAux <> VV0->VV0_DATMOV
				dDatAux := VV0->VV0_DATMOV
				IncProc(STR0008+" "+Transform(dDatAux,"@D")) // Gerando Comissoes
			EndIf
	
			/////////////////////////////////////////////////////
			// Carregar variaveis M-> que o MAPA pode utilizar //
			/////////////////////////////////////////////////////
			dbSelectArea("SX3")
			SX3->(dbSetOrder(1))
			SX3->(dbSeek("VV9"))
			While !Eof().and.(SX3->X3_ARQUIVO=="VV9")
				If SX3->X3_CONTEXT == "V"
					&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
				Else
					&("M->"+SX3->X3_CAMPO):= &("VV9->"+SX3->X3_CAMPO)
				EndIf
				DbSkip()
			Enddo
			SX3->(dbSeek("VV0"))
			While !Eof().and.(SX3->X3_ARQUIVO=="VV0")
				If SX3->X3_CONTEXT == "V"
					&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
				Else
					&("M->"+SX3->X3_CAMPO):= &("VV0->"+SX3->X3_CAMPO)
				EndIf
				DbSkip()
			Enddo
			SX3->(dbSeek("VVA"))
			While !Eof().and.(SX3->X3_ARQUIVO=="VVA")
				If SX3->X3_CONTEXT == "V"
					&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
				Else
					&("M->"+SX3->X3_CAMPO):= &("VVA->"+SX3->X3_CAMPO)
				EndIf
				DbSkip()
			Enddo
	
			cCpoDet  := ""
			cCpoBas  := ""
			cCpoBasS := ""
			cCodVZ8  := ""
			cCodSup  := ""
		
			cQAux10 := "SELECT VZ8.R_E_C_N_O_ AS RECVZ8 FROM "+RetSQLName("VZ8")+" VZ8 WHERE VZ8.VZ8_FILIAL='"+xFilial("VZ8")+"' AND VZ8.VZ8_MODVDA='"+VV0->VV0_MODVDA+"' AND "
			cQAux20 := "VZ8.VZ8_DATINI<='"+dtos(VV0->VV0_DATMOV)+"' AND VZ8.VZ8_DATFIN>='"+dtos(VV0->VV0_DATMOV)+"' AND "
			cQAux30 := "VZ8.VZ8_CODVEN='"+VV0->VV0_CODVEN+"' AND "
			cQAux31 := "VZ8.VZ8_CODVEN='"+space(len(VV0->VV0_CODVEN))+"' AND "
			cQAux40 := "VZ8.VZ8_CODMAR='"+VV1->VV1_CODMAR+"' AND "
			cQAux41 := "VZ8.VZ8_CODMAR='"+space(len(VV1->VV1_CODMAR))+"' AND "
			cQAux50 := "VZ8.VZ8_GRUMOD='"+VV2->VV2_GRUMOD+"' AND "
			cQAux51 := "VZ8.VZ8_GRUMOD='"+space(len(VV2->VV2_GRUMOD))+"' AND "
			cQAux60 := "VZ8.VZ8_MODVEI='"+VV1->VV1_MODVEI+"' AND "
			cQAux61 := "VZ8.VZ8_MODVEI='"+space(len(VV1->VV1_MODVEI))+"' AND "
			cQAux70 := "VZ8.D_E_L_E_T_=' '"
			///////////////////////////////
	        // Posiciona no VZ8 Comissao //
	        ///////////////////////////////
			nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux30+cQAux40+cQAux50+cQAux60+cQAux70) // Periodo + Vendedor + Marca + Grupo + Modelo
			If nRecVZ8 <= 0
				nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux30+cQAux40+cQAux50+cQAux61+cQAux70) // Periodo + Vendedor + Marca + Grupo
				If nRecVZ8 <= 0
					nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux30+cQAux40+cQAux51+cQAux61+cQAux70) // Periodo + Vendedor + Marca
					If nRecVZ8 <= 0
						nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux30+cQAux41+cQAux51+cQAux61+cQAux70) // Periodo + Vendedor
						If nRecVZ8 <= 0
							nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux31+cQAux40+cQAux50+cQAux60+cQAux70) // Periodo + Marca + Grupo + Modelo
							If nRecVZ8 <= 0
								nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux31+cQAux40+cQAux50+cQAux61+cQAux70) // Periodo + Marca + Grupo
								If nRecVZ8 <= 0
									nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux31+cQAux40+cQAux51+cQAux61+cQAux70) // Periodo + Marca
									If nRecVZ8 <= 0
										nRecVZ8 := FM_SQL(cQAux10+cQAux20+cQAux31+cQAux41+cQAux51+cQAux61+cQAux70) // Periodo
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
	
			If nRecVZ8 > 0
	
				aValVZ8 := {0,0,0,0,0}
				aStru   := {}
				
				/////////////////////////////////////////////////////
				// Carregar DADOS da Comissao VZ8                  //
				/////////////////////////////////////////////////////
				DbSelectArea("VZ8")
				VZ8->(DbSetOrder(1))
				VZ8->(DbGoTo(nRecVZ8))
				cCodMap  := VZ8->VZ8_MAPRES
				cCpoDet  := VZ8->VZ8_CPODET
				cCpoBas  := VZ8->VZ8_CPOBAS
				cCpoBasS := VZ8->VZ8_BASSUP
				cCodVZ8  := VZ8->VZ8_CODCOM
				cCodSup  := VZ8->VZ8_CODSUP
	
				/////////////////////////////////////////////////////
				// Montagem do MAPA                                //
				/////////////////////////////////////////////////////
				DbSelectArea("VOQ")
				DbSetOrder(1)
				DbSeek(xFilial("VOQ")+cCodMap)
				While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. VOQ->VOQ_CODMAP == cCodMap
					If !(VV0->VV0_TIPFAT $ VOQ->VOQ_TIPFAT) .or. VOQ->VOQ_INDATI # "1"
						DbSelectArea("VOQ")
						DbSkip()
						Loop
					Endif
					cDescVOQ := IIf(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
					aadd(aStru,{ VV0->VV0_NUMTRA,VVA->VVA_TRACPA,VV1->VV1_CHAINT,VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,VV0->VV0_DATMOV,0,0,VOQ->VOQ_CTATOT})
					DbSelectArea("VOQ")
					DbSkip()
				Enddo
				aStru := FG_CalcVlrs(aStru)
	
				/////////////////////////////////////////////////////
				// Calcular VALORES de Comissao                    //
				/////////////////////////////////////////////////////
				nPos := aScan(aStru,{|x| Alltrim(x[5]) == Alltrim(cCpoDet)})
				If nPos > 0
					aValVZ8[1] := aStru[nPos,10]
				Endif
				nPos := aScan(aStru,{|x| Alltrim(x[5]) == Alltrim(cCpoBas)})
				If nPos > 0
					aValVZ8[2] := aStru[nPos,9]
				Endif
				nPos := aScan(aStru,{|x| Alltrim(x[5]) == Alltrim(cCpoBasS)})
				If nPos > 0
					aValVZ8[3] := aStru[nPos,9]
				Endif
				If aValVZ8[1] > 0
					If VZ8->VZ8_FXAINI <= round(aValVZ8[1],2) .and. VZ8->VZ8_FXAFIN >= round(aValVZ8[1],2)
						aValVZ8[4] := VZ8->VZ8_PERCOM
						aValVZ8[5] := VZ8->VZ8_PERSUP
					Endif
				Else
					If aValVZ8[1] < 0
						aValVZ8[4] := 0
					Else
						aValVZ8[4] := VZ8->VZ8_PERCOM
					Endif
					If aValVZ8[3] < 0
						aValVZ8[5] := 0
					Else
						aValVZ8[5] := VZ8->VZ8_PERSUP
					Endif
				Endif
	
				/////////////////////////////////////////////////////////////
				// Verifica se ja existe a Comissao para o VENDEDOR no VD2 //
				/////////////////////////////////////////////////////////////
				cNumNFI := FM_SQL("SELECT VD2.VD2_NUMNFI FROM "+RetSQLName("VD2")+" VD2 WHERE VD2.VD2_FILIAL='"+xFilial("VD2")+"' AND VD2.VD2_CODVEN='"+VV0->VV0_CODVEN+"' AND VD2.VD2_COMPRE='1' AND VD2.VD2_CDCMPR='"+cCodVZ8+"' AND VD2.VD2_NUMNFI='"+VV0->VV0_NUMNFI+"' AND VD2.VD2_SERNFI='"+VV0->VV0_SERNFI+"' AND VD2.D_E_L_E_T_=' '")
				If cNumNFI <> VV0->VV0_NUMNFI .and. ( aValVZ8[2] * ( aValVZ8[4] / 100 ) ) > 0
					/////////////////////////////////////////////////////////
					// Gera Comissao a ser paga para o VENDEDOR no VD2     //
					/////////////////////////////////////////////////////////
					DbSelectArea("VD2")
					RecLock("VD2",.t.)
						VD2->VD2_FILIAL := xFilial("VD2")
						VD2->VD2_CODIGO := GetSXENum("VD2","VD2_CODIGO")
						VD2->VD2_CODVEN := VV0->VV0_CODVEN // VENDEDOR
						VD2->VD2_DATLEV := VV0->VV0_DATMOV
						VD2->VD2_MODVDA := VV0->VV0_MODVDA
						VD2->VD2_COMPRE := "1" // VZ8 - Comissao
						VD2->VD2_CDCMPR := cCodVZ8 // Codigo do VZ8 - Comissao
						VD2->VD2_NUMNFI := VV0->VV0_NUMNFI
						VD2->VD2_SERNFI := VV0->VV0_SERNFI
						VD2->VD2_VALCAL := ( aValVZ8[2] * ( aValVZ8[4] / 100 ) ) // ( Valor do Campo Base ) x ( % de Comissao )
						VD2->VD2_JAPAGO := "0"
						VD2->VD2_VALPAG := VD2->VD2_VALCAL
						VD2->VD2_DATPAG := ctod("")
						VD2->VD2_DATGER := dDataBase
						VD2->VD2_DATINI := dDatIni
						VD2->VD2_DATFIN := dDatFin
					MsUnLock()
					ConfirmSx8()
				EndIf
				If !Empty(cCodSup)
					/////////////////////////////////////////////////////////////
					// Verifica se ja existe a Comissao para o SUPERIOR no VD2 //
					/////////////////////////////////////////////////////////////
					cNumNFI := FM_SQL("SELECT VD2.VD2_NUMNFI FROM "+RetSQLName("VD2")+" VD2 WHERE VD2.VD2_FILIAL='"+xFilial("VD2")+"' AND VD2.VD2_CODVEN='"+cCodSup+"' AND VD2.VD2_COMPRE='1' AND VD2.VD2_CDCMPR='"+cCodVZ8+"' AND VD2.VD2_NUMNFI='"+VV0->VV0_NUMNFI+"' AND VD2.VD2_SERNFI='"+VV0->VV0_SERNFI+"' AND VD2.D_E_L_E_T_=' '")
					If cNumNFI <> VV0->VV0_NUMNFI .and. ( aValVZ8[3] * ( aValVZ8[5] / 100 ) ) > 0
						/////////////////////////////////////////////////////////
						// Gera Comissao a ser paga para o SUPERIOR no VD2     //
						/////////////////////////////////////////////////////////
						DbSelectArea("VD2")
						RecLock("VD2",.t.)
							VD2->VD2_FILIAL := xFilial("VD2")
							VD2->VD2_CODIGO := GetSXENum("VD2","VD2_CODIGO")
							VD2->VD2_CODVEN := cCodSup // SUPERIOR
							VD2->VD2_DATLEV := VV0->VV0_DATMOV
							VD2->VD2_MODVDA := VV0->VV0_MODVDA
							VD2->VD2_COMPRE := "1" // VZ8 - Comissao
							VD2->VD2_CDCMPR := cCodVZ8 // Codigo do VZ8 - Comissao
							VD2->VD2_NUMNFI := VV0->VV0_NUMNFI
							VD2->VD2_SERNFI := VV0->VV0_SERNFI
							VD2->VD2_VALCAL := ( aValVZ8[3] * ( aValVZ8[5] / 100 ) ) // ( Valor do Campo Base ) x ( % de Comissao )
							VD2->VD2_JAPAGO := "0"
							VD2->VD2_VALPAG := VD2->VD2_VALCAL
							VD2->VD2_DATPAG := ctod("")
							VD2->VD2_DATGER := dDataBase
							VD2->VD2_DATINI := dDatIni
							VD2->VD2_DATFIN := dDatFin
						MsUnLock()
						ConfirmSx8()
					EndIf
				EndIf
			EndIf
	
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
	
	EndIf
	
	If cTipo $ "2/3" // 2-Premiacao ou 3-Comissao/Premiacao

		/////////////////////////////////////////////////////
		// Levanta os cadastros validos de Premiacao  VD1  //
		/////////////////////////////////////////////////////
		cQuery := "SELECT VD1.VD1_CODPRE , VD1.VD1_MODVDA , VD1.VD1_CODVEN , VD1.VD1_CATVEN , VD1.VD1_CODBCO , VD1.VD1_TABFEI , "
		cQuery += "VD1.VD1_ADMCON , VD1.VD1_MODVEI , VD1.VD1_CODMAR , VD1.VD1_GRUMOD , VD1.VD1_QTUNVD , VD1.VD1_PERQVD , "
		cQuery += "VD1.VD1_VRTTVD , VD1.VD1_PERTVD , VD1.VD1_VRPQVD , VD1.VD1_VRPTVD , VD1.VD1_PAGPRE "
		cQuery += "FROM "+RetSQLName("VD1")+" VD1 WHERE VD1.VD1_FILIAL='"+xFilial("VD1")+"' AND VD1.VD1_ATIVO='1' AND VD1.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			cOrd := ""
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_CODVEN )),"0","1")	// Vendedor
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_CODMAR )),"0","1")	// Marca
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_GRUMOD )),"0","1")	// Grupo do Modelo
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_MODVEI )),"0","1")	// Modelo do Veiculo
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_MODVDA )),"0","1")	// Modalidade da Venda
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_CATVEN )),"0","1")	// Categoria da Venda
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_CODBCO )),"0","1")	// Banco FI
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_TABFEI )),"0","1")	// Tabela FI
			cOrd += IIf(!Empty((cSQLAlias)->( VD1_ADMCON )),"0","1")	// Administradora de Consorcio
			aAdd(aVD1,{	cOrd ,;							// 01 - Ordem
						(cSQLAlias)->( VD1_CODPRE ) ,;	// 02 - Codigo Premiacao
						(cSQLAlias)->( VD1_CODVEN ) ,;	// 03 - Vendedor
						(cSQLAlias)->( VD1_CODMAR ) ,;  // 04 - Marca
						(cSQLAlias)->( VD1_GRUMOD ) ,;	// 05 - Grupo do Modelo
						(cSQLAlias)->( VD1_MODVEI ) ,;	// 06 - Modelo do Veiculo
						(cSQLAlias)->( VD1_MODVDA ) ,;	// 07 - Modalidade da Venda
						(cSQLAlias)->( VD1_CATVEN ) ,;	// 08 - Categoria da Venda
						(cSQLAlias)->( VD1_CODBCO ) ,;	// 09 - Banco FI
						(cSQLAlias)->( VD1_TABFEI ) ,;	// 10 - Tabela FI
						(cSQLAlias)->( VD1_ADMCON ) ,;	// 11 - Administradora de Consorcio
						(cSQLAlias)->( VD1_QTUNVD ) ,;	// 12 - Qtd. Unidade Vendida
						(cSQLAlias)->( VD1_PERQVD ) ,;	// 13 - Percentual quando atingiu Qtd. Unidade Vendida
						(cSQLAlias)->( VD1_VRTTVD ) ,;	// 14 - Vlr. Total Vendido
						(cSQLAlias)->( VD1_PERTVD ) ,;	// 15 - Percentual quando atingiu Vlr. Total Vendido
						(cSQLAlias)->( VD1_VRPQVD ) ,;	// 16 - Valor Fixo quando atingiu Qtd. Unidade Vendida
						(cSQLAlias)->( VD1_VRPTVD ) ,;	// 17 - Valor Fixo quando atingiu Vlr. Total Vendido
						(cSQLAlias)->( VD1_PAGPRE ) })	// 18 - 1=Maior Criterio / 2=Ambos
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())

		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Ordena: Vendedor + Marca + Grp.Modelo + Modelo + Modal.Venda + Categ.Venda + Cod.Banco FI + Tabela FI + Adminst.Consorcio //
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		Asort(aVD1,,,{|x,y| x[1] < y[1] })

		ProcRegua( len(aVD1) )

		/////////////////////////////////////////////////////
		// Percorre Premiacoes VD1                         //
		/////////////////////////////////////////////////////
		For ni := 1 to len(aVD1)

			IncProc(STR0040) // Gerando Premiacoes

			aVended := {}
			
			/////////////////////////////////////////////////////
			// Levanta os Atendimentos Finalizados no periodo  //
			/////////////////////////////////////////////////////
			cQuery := "SELECT VV0.R_E_C_N_O_ AS RECVV0 , VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VV0")+" VV0 "
			cQuery += "JOIN "+RetSQLName("VV9")+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS='F' AND VV9.D_E_L_E_T_=' ' "
			cQuery += "JOIN "+RetSQLName("VVA")+" VVA ON VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
			cQuery += "WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
			If !Empty(aVD1[ni,03]) // Vendedor
				cQuery += "VV0.VV0_CODVEN='"+aVD1[ni,03]+"' AND " // VD1_CODVEN
			EndIf
			cQuery += "VV0.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV , VV0.VV0_NUMTRA "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
			While !(cSQLAlias)->(Eof())
				dbSelectArea("VV0")
				dbGoTo( (cSQLAlias)->( RECVV0 ) )

				//////////////////////////////////////////////
				// Valida Modalidade da Venda               //
				//////////////////////////////////////////////
				If !Empty(aVD1[ni,07]) .and. aVD1[ni,07] <> VV0->VV0_MODVDA // Modalidade da Venda
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf

				//////////////////////////////////////////////
				// Valida Categoria da Venda                //
				//////////////////////////////////////////////
				If !Empty(aVD1[ni,08]) .and. aVD1[ni,08] <> VV0->VV0_CATVEN // Categoria da Venda
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf

				//////////////////////////////////////////////
				// Valida Cod.Banco FI                      //
				//////////////////////////////////////////////
				If !Empty(aVD1[ni,09]) .and. aVD1[ni,09] <> VV0->VV0_CODBCO // Cod.Banco FI
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf

				//////////////////////////////////////////////
				// Valida Tabela FI                         //
				//////////////////////////////////////////////
				If !Empty(aVD1[ni,10]) .and. aVD1[ni,10] <> VV0->VV0_TABFAI // Tabela FI
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf

				//////////////////////////////////////////////
				// Valida Marca do Modelo                   //
				//////////////////////////////////////////////
				dbSelectArea("VVA")
				dbGoTo( (cSQLAlias)->( RECVVA ) )
				VV1->(DbSetOrder(1))
				VV1->(DbSeek( xFilial("VV1") + VVA->VVA_CHAINT ))
				If !Empty(aVD1[ni,04]) .and. aVD1[ni,04] <> VV1->VV1_CODMAR // Marca
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf

				//////////////////////////////////////////////
				// Valida Modelo do Veiculo                 //
				//////////////////////////////////////////////
				If !Empty(aVD1[ni,06]) .and. aVD1[ni,06] <> VV1->VV1_MODVEI // Modelo do Veiculo
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf

				//////////////////////////////////////////////
				// Valida Grupo do Modelo                   //
				//////////////////////////////////////////////
				VV2->(DbSetOrder(1))
				VV2->(DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI ))
				If !Empty(aVD1[ni,05]) .and. aVD1[ni,05] <> VV2->VV2_GRUMOD // Grupo do Modelo
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf
				
				//////////////////////////////////////////////
				// Valida Administradora Consorcio          //
				//////////////////////////////////////////////
				cAdmCon := ""
				cQuery := "SELECT VS9.VS9_TIPPAG , VS9.VS9_SEQUEN FROM "+RetSQLName("VS9")+" VS9 INNER JOIN "+RetSQLName("VSA")+" VSA ON "
				cQuery += "( VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_ = ' ' ) "
				cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+VV0->VV0_NUMTRA+"' AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_ = ' ' "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVS9 , .F. , .T. )
				While !(cSQLVS9)->(Eof())
					cAdmCon += Alltrim(FM_SQL("SELECT VSE.VSE_VALDIG FROM "+RetSqlName("VSE")+" VSE WHERE VSE.VSE_FILIAL='"+xFilial("VSE")+"' AND VSE.VSE_NUMIDE='"+VV0->VV0_NUMTRA+"' AND VSE.VSE_TIPOPE='V' AND VSE.VSE_TIPPAG='"+(cSQLVS9)->( VS9_TIPPAG )+"' AND VSE.VSE_SEQUEN='"+(cSQLVS9)->( VS9_SEQUEN )+"' AND VSE.D_E_L_E_T_=' ' ORDER BY VSE.VSE_DESCCP"))+"/"
					(cSQLVS9)->(dbSkip())
				EndDo
				(cSQLVS9)->(dbCloseArea())
				If !Empty(aVD1[ni,11]) .and. !( Alltrim(aVD1[ni,11]) $ Alltrim(cAdmCon) ) // Administradora Consorcio
					(cSQLAlias)->(dbSkip())
					Loop
				EndIf
				
				/////////////////////////////////////////////////
				// Atualiza Vetor de Vendedor ( QTDE e TOTAL ) //
				/////////////////////////////////////////////////
				nPos := aScan(aVended,{|x| x[1] == VV0->VV0_CODVEN })
				If nPos <= 0
					aAdd(aVended,{ VV0->VV0_CODVEN , 0 , 0 })
					nPos := len(aVended)
				EndIf
				aVended[nPos,2] += 1 // Qtde Vendida
				aVended[nPos,3] += VV0->VV0_VALTOT // Valor do Atendimento
				/////////////////////////////////////////////////
		
				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
			
			For nPos := 1 to len(aVended)
				nVlrQ := 0
				nVlrT := 0
				If aVended[nPos,2] >= aVD1[ni,12] // Qtd. Unidade Vendida
					nVlrQ := ( aVended[nPos,3] * ( aVD1[ni,13] / 100 ) ) // Percentual quando atingiu Qtd. Unidade Vendida
					If nVlrQ < aVD1[ni,16]
						nVlrQ := aVD1[ni,16] // Valor Fixo quando atingiu Qtd. Unidade Vendida
					EndIf
				EndIf
				If aVended[nPos,3] >= aVD1[ni,14] // Vlr. Total Vendido
					nVlrT := ( aVended[nPos,3] * ( aVD1[ni,15] / 100 ) ) // Percentual quando atingiu Vlr. Total Vendido
					If nVlrT < aVD1[ni,17]
						nVlrT := aVD1[ni,17] // Valor Fixo quando atingiu Vlr. Total Vendido
					EndIf
				EndIf
				nVlr := 0
				If aVD1[ni,18] == "1" // 1=Maior Criterio
					nVlr := IIf(nVlrQ>nVlrT,nVlrQ,nVlrT) // Qtd ou Vlr
				Else // 2=Ambos
					nVlr := ( nVlrQ + nVlrT ) // Qtd e Vlr
				EndIf
				If nVlr > 0
					/////////////////////////////////////////////////////////
					// Gera Premiacao a ser paga para o VENDEDOR no VD2    //
					/////////////////////////////////////////////////////////
					DbSelectArea("VD2")
					RecLock("VD2",.t.)
						VD2->VD2_FILIAL := xFilial("VD2")
						VD2->VD2_CODIGO := GetSXENum("VD2","VD2_CODIGO")
						VD2->VD2_CODVEN := aVended[nPos,1] // VENDEDOR
						VD2->VD2_DATLEV := dDataBase
						VD2->VD2_MODVDA := aVD1[ni,7]
						VD2->VD2_COMPRE := "2" // VD1 - Premiacao
						VD2->VD2_CDCMPR := aVD1[ni,2] // Codigo do VD1 - Premiacao
						VD2->VD2_NUMNFI := ""
						VD2->VD2_SERNFI := ""
						VD2->VD2_VALCAL := nVlr
						VD2->VD2_JAPAGO := "0"
						VD2->VD2_VALPAG := VD2->VD2_VALCAL
						VD2->VD2_DATPAG := ctod("")
						VD2->VD2_DATGER := dDataBase
						VD2->VD2_DATINI := dDatIni
						VD2->VD2_DATFIN := dDatFin
					MsUnLock()
					ConfirmSx8()
				EndIf
			Next
        Next

	EndIf

EndIf
    
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VM510Man ³ Autor ³ Andre Luis Almeida   ³ Data ³ 28/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao da Comissao / Premiacao                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM510Man()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private aComPre := {}
Private aVenTot := {}
Private cFCdVen := space(TamSx3("VD2_CODVEN")[1])
Private dFDlIni := ctod("")
Private dFDlFin := dDataBase
Private dFDpIni := ctod("")
Private dFDpFin := ctod("")
Private cFComPr := ""
Private aFComPr := X3CBOXAVET("VD2_COMPRE","1")
Private cFJaPag := "0"
Private aFJaPag := X3CBOXAVET("VD2_JAPAGO","0")
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )   		// Comissao/Premiacao selecionada
Private oVerm   := LoadBitmap( GetResources() , "BR_VERMELHO" )		// Comissao/Premiacao nao selecionada
Private oAzul   := LoadBitmap( GetResources() , "BR_AZUL_OCEAN" )	// Comissao/Premiacao ja paga
Private lTik    := .f.
Private aNewBot := {}
AADD(aNewBot, {"PMSCOLOR"  ,{|| FS_LEGENDA() }   ,(STR0029 )} )	// Legenda
AADD(aNewBot, {"IMPRESSAO" ,{|| FS_IMPRIMIR(0) } ,(STR0030 )} )	// Impressao da Comissao/Premiacao

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 30 , .T. , .F. } ) // Filtros
aAdd( aObjects, { 0 , 00 , .T. , .T. } ) // ListBox Comissao/Premiacao
aAdd( aObjects, { 0 , 99 , .T. , .f. } ) // ListBox Total Vendedor
aPos := MsObjSize( aInfo, aObjects )

FS_FILTRO(0)

DEFINE MSDIALOG VM510Man FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL

@ aPos[1,1],aPos[1,2] TO aPos[1,3],aPos[1,4]-2 LABEL "" OF VM510Man PIXEL

@ aPos[1,1]+005,aPos[1,2]+005 SAY STR0009 SIZE 60,8 OF VM510Man PIXEL COLOR CLR_BLUE // Dt.NF
@ aPos[1,1]+014,aPos[1,2]+005 MSGET oFDtIni VAR dFDlIni PICTURE "@D" SIZE 48,08 OF VM510Man PIXEL COLOR CLR_BLUE
@ aPos[1,1]+014,aPos[1,2]+055 SAY STR0010 SIZE 60,8 OF VM510Man PIXEL COLOR CLR_BLUE // a
@ aPos[1,1]+014,aPos[1,2]+060 MSGET oFDtFin VAR dFDlFin PICTURE "@D" SIZE 48,08 OF VM510Man PIXEL COLOR CLR_BLUE

@ aPos[1,1]+005,aPos[1,2]+114 SAY STR0011 SIZE 60,8 OF VM510Man PIXEL COLOR CLR_BLUE // Tipo
@ aPos[1,1]+014,aPos[1,2]+114 MSCOMBOBOX oFComPr VAR cFComPr SIZE 40,08 COLOR CLR_BLACK ITEMS aFComPr OF VM510Man PIXEL COLOR CLR_BLUE

@ aPos[1,1]+005,aPos[1,2]+160 SAY STR0012 SIZE 60,8 OF VM510Man PIXEL COLOR CLR_BLUE // Pago
@ aPos[1,1]+014,aPos[1,2]+160 MSCOMBOBOX oFJaPag VAR cFJaPag VALID FS_LIMPADT() SIZE 25,08 COLOR CLR_BLACK ITEMS aFJaPag OF VM510Man PIXEL COLOR CLR_BLUE

@ aPos[1,1]+005,aPos[1,2]+190 SAY STR0013 SIZE 60,8 OF VM510Man PIXEL COLOR CLR_BLUE // Dt.Pagamento
@ aPos[1,1]+014,aPos[1,2]+190 MSGET oFDeIni VAR dFDpIni PICTURE "@D" SIZE 48,08 OF VM510Man PIXEL COLOR CLR_BLUE WHEN ( cFJaPag == "1" )
@ aPos[1,1]+014,aPos[1,2]+240 SAY STR0010 SIZE 60,8 OF VM510Man PIXEL COLOR CLR_BLUE // a
@ aPos[1,1]+014,aPos[1,2]+245 MSGET oFDeFin VAR dFDpFin PICTURE "@D" SIZE 48,08 OF VM510Man PIXEL COLOR CLR_BLUE WHEN ( cFJaPag == "1" )

@ aPos[1,1]+005,aPos[1,2]+300 SAY STR0014 SIZE 60,8 OF VM510Man PIXEL COLOR CLR_BLUE // Vendedor
@ aPos[1,1]+014,aPos[1,2]+300 MSGET oFCdVen VAR cFCdVen PICTURE "@!" F3 "SA3" SIZE 35,08 OF VM510Man PIXEL COLOR CLR_BLUE

@ aPos[1,1]+014,aPos[1,2]+350 BUTTON oFiltrar PROMPT STR0015 OF VM510Man SIZE 40,10 PIXEL ACTION FS_FILTRO(1)

@ aPos[2,1],aPos[2,2] LISTBOX oLbComPre FIELDS HEADER "",STR0011,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0014,STR0022,STR0041 COLSIZES 10,45,40,50,50,35,40,40,90,40,90 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1] OF VM510Man PIXEL ON DBLCLICK FS_ALTVLR()
oLbComPre:SetArray(aComPre)
oLbComPre:bLine := { || { IIf(aComPre[oLbComPre:nAt,04]=="1",oAzul,IIf(aComPre[oLbComPre:nAt,11],oVerd,oVerm)),;
						IIf(!Empty(aComPre[oLbComPre:nAt,01]),X3CBOXDESC("VD2_COMPRE",aComPre[oLbComPre:nAt,01]),"") ,;
						Transform(aComPre[oLbComPre:nAt,02],"@D") ,;
						aComPre[oLbComPre:nAt,08] ,;
						FG_AlinVlrs(Transform(aComPre[oLbComPre:nAt,03],"@E 999,999,999.99")),;
						IIf(!Empty(aComPre[oLbComPre:nAt,04]),X3CBOXDESC("VD2_JAPAGO",aComPre[oLbComPre:nAt,04]),"") ,;
						FG_AlinVlrs(Transform(aComPre[oLbComPre:nAt,05],"@E 999,999,999.99")),;
						Transform(aComPre[oLbComPre:nAt,06],"@D") ,;
						aComPre[oLbComPre:nAt,07] ,;
						Transform(aComPre[oLbComPre:nAt,09],"@D") ,;
						aComPre[oLbComPre:nAt,12] }}
@ aPos[2,1],aPos[2,2]+1 CHECKBOX oTik VAR lTik PROMPT "" OF VM510Man ON CLICK FS_TIKTOT() SIZE 10,08 PIXEL COLOR CLR_BLUE

@ aPos[3,1],aPos[3,2] LISTBOX oLbVenTot FIELDS HEADER STR0014,STR0023 COLSIZES 90,40 SIZE aPos[3,4]-4,aPos[3,3]-aPos[3,1] OF VM510Man PIXEL
oLbVenTot:SetArray(aVenTot)
oLbVenTot:bLine := { || { aVenTot[oLbVenTot:nAt,01] ,;
						FG_AlinVlrs(Transform(aVenTot[oLbVenTot:nAt,02],"@E 999,999,999.99")) }}

ACTIVATE MSDIALOG VM510Man ON INIT EnchoiceBar(VM510Man,{ || IIf(FS_OK(),VM510Man:End(),.t.) }, { || VM510Man:End() },,aNewBot)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LIMPADT³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa data de pagamento ( Data Inicial / Final )          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMPADT()
If cFJaPag == "1" // Ja Pago
	dFDpIni := ctod("")
	dFDpFin := dDataBase
Else // Nao Pago
	dFDpIni := ctod("")
	dFDpFin := ctod("")
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OK    ³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ OK da janela, confirma pagamento da Comissao/Premiacao    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OK()
Local ni   := 0
Local lOk  := .f.
Local lRet := .f.
For ni := 1 to len(aComPre)
	If aComPre[ni,11]
		lOk := .t.
		Exit
	EndIf
Next
If lOk
	If MsgYesNo(STR0024,STR0025) // Confirma o Pagamento da(s) Comissao(oes)/Premiacao(oes) selecionada(s)? / Atencao
	    DbSelectArea("VD2")
		lRet := .t.
  		For ni := 1 to len(aComPre)
  			If aComPre[ni,11]
  				VD2->(DbGoTo(aComPre[ni,10]))
  				RecLock("VD2",.f.)
					VD2->VD2_JAPAGO := "1" // PAGO
					VD2->VD2_DATPAG := dDataBase
				MsUnLock()				
			EndIf
		Next
		FS_IMPRIMIR(1)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRO³ Autor ³ Andre Luis Almeida   ³ Data ³ 27/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro ( levanta registros do VD2 )                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRO(nTip)
Local cQuery    := ""
Local cSQLAlias := "SQLVD2"
aComPre := {}
cQuery := "SELECT VD2.R_E_C_N_O_ AS RECVD2 , VD2.VD2_COMPRE , VD2.VD2_DATLEV , VD2.VD2_VALCAL , VD2.VD2_JAPAGO , VD2.VD2_VALPAG , "
cQuery += "VD2.VD2_DATPAG , VD2.VD2_CODVEN , SA3.A3_NOME , VD2.VD2_NUMNFI , VD2.VD2_SERNFI , VD2.VD2_DATGER , VD2.VD2_DATINI , VD2.VD2_DATFIN "
cQuery += "FROM "+RetSQLName("VD2")+" VD2 "
cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VD2.VD2_CODVEN AND SA3.D_E_L_E_T_=' ' "
cQuery += "WHERE VD2.VD2_FILIAL='"+xFilial("VD2")+"' AND "
If !Empty(cFCdVen)
	cQuery += "VD2.VD2_CODVEN='"+cFCdVen+"' AND "
EndIf
cQuery += "VD2.VD2_DATLEV>='"+dtos(dFDlIni)+"' AND VD2.VD2_DATLEV<='"+dtos(dFDlFin)+"' AND "
If !Empty(cFComPr)
	cQuery += "VD2.VD2_COMPRE='"+cFComPr+"' AND "
EndIf
cQuery += "VD2.VD2_JAPAGO='"+cFJaPag+"' AND "
If cFJaPag == "1" // Data Pagamento
	cQuery += "VD2.VD2_DATPAG>='"+dtos(dFDpIni)+"' AND VD2.VD2_DATPAG<='"+dtos(dFDpFin)+"' AND "
EndIf
cQuery += "VD2.D_E_L_E_T_=' ' ORDER BY VD2.VD2_DATLEV , VD2.VD2_NUMNFI , VD2.VD2_SERNFI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	aAdd(aComPre,{ 	(cSQLAlias)->( VD2_COMPRE ) ,;
					stod((cSQLAlias)->( VD2_DATLEV )) ,;
					(cSQLAlias)->( VD2_VALCAL ) ,;
					(cSQLAlias)->( VD2_JAPAGO ) ,;
					(cSQLAlias)->( VD2_VALPAG ) ,;
					stod((cSQLAlias)->( VD2_DATPAG )) ,;
					(cSQLAlias)->( VD2_CODVEN )+" - "+left((cSQLAlias)->( A3_NOME ),20) ,;
					(cSQLAlias)->( VD2_NUMNFI )+"-"+(cSQLAlias)->( VD2_SERNFI ) ,;
					stod((cSQLAlias)->( VD2_DATGER )) ,;
					(cSQLAlias)->( RECVD2 ) ,;
					.f. ,;
					Transform(stod((cSQLAlias)->( VD2_DATINI )),"@D")+" "+STR0010+" "+Transform(stod((cSQLAlias)->( VD2_DATFIN )),"@D") })
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
If len(aComPre) <= 0
	aAdd(aComPre,{ 	"" , ctod("") , 0 , "" , 0 , ctod("") , "" , "" , ctod("") , 0 , .f. , "" })
EndIf
If nTip > 0
	oLbComPre:nAt := 1
	oLbComPre:SetArray(aComPre)
	oLbComPre:bLine := { || { IIf(aComPre[oLbComPre:nAt,04]=="1",oAzul,IIf(aComPre[oLbComPre:nAt,11],oVerd,oVerm)),;
						IIf(!Empty(aComPre[oLbComPre:nAt,01]),X3CBOXDESC("VD2_COMPRE",aComPre[oLbComPre:nAt,01]),"") ,;
						Transform(aComPre[oLbComPre:nAt,02],"@D") ,;
						aComPre[oLbComPre:nAt,08] ,;
						FG_AlinVlrs(Transform(aComPre[oLbComPre:nAt,03],"@E 999,999,999.99")),;
						IIf(!Empty(aComPre[oLbComPre:nAt,04]),X3CBOXDESC("VD2_JAPAGO",aComPre[oLbComPre:nAt,04]),"") ,;
						FG_AlinVlrs(Transform(aComPre[oLbComPre:nAt,05],"@E 999,999,999.99")),;
						Transform(aComPre[oLbComPre:nAt,06],"@D") ,;
						aComPre[oLbComPre:nAt,07] ,;
						Transform(aComPre[oLbComPre:nAt,09],"@D") ,;
						aComPre[oLbComPre:nAt,12] }}
	oLbComPre:Refresh()
EndIf
FS_VENTOT(nTip)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ALTVLR ³ Autor ³ Andre Luis Almeida   ³ Data ³ 04/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera Valor Comissao/Premiacao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALTVLR()
Local aRet      := {}
Local aParamBox := {}
If aComPre[oLbComPre:nAt,10] <= 0 .or. aComPre[oLbComPre:nAt,4] == "1" // RECNO VD2 <= 0 ou ja pago
	Return()
EndIf
aComPre[oLbComPre:nAt,11] := !aComPre[oLbComPre:nAt,11]
oLbComPre:Refresh()
If aComPre[oLbComPre:nAt,11] // Selecionado
	AADD(aParamBox,{1,STR0011,X3CBOXDESC("VD2_COMPRE",aComPre[oLbComPre:nAt,01]),"@!","","",".f.",80,.f.}) // Tipo
	AADD(aParamBox,{1,STR0016,aComPre[oLbComPre:nAt,02],"@D","","",".f.",80,.f.}) // Dt.NF
	AADD(aParamBox,{1,STR0017,aComPre[oLbComPre:nAt,08],"@!","","",".f.",80,.f.}) // Nro NF
	AADD(aParamBox,{1,STR0014,aComPre[oLbComPre:nAt,07],"@!","","",".f.",80,.f.}) // Vendedor
	AADD(aParamBox,{1,STR0018,aComPre[oLbComPre:nAt,03],"@E 999,999,999.99","","",".f.",80,.f.}) // Vlr.Calculado
	AADD(aParamBox,{1,STR0027,aComPre[oLbComPre:nAt,05],"@E 999,999,999.99","","",".t.",80,.f.}) // Valor a Pagar
	If ParamBox(aParamBox,STR0028,@aRet,,,,,,,,.f.) // Parametros
		aComPre[oLbComPre:nAt,05] := aRet[06] // Valor a Pagar
		DbSelectArea("VD2")
		VD2->(DbGoTo(aComPre[oLbComPre:nAt,10]))
		RecLock("VD2",.f.)
			VD2->VD2_VALPAG := aRet[06] // Valor a Pagar
		MsUnLock()
	EndIf
EndIf
FS_VENTOT(1)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VENTOT³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totaliza por Vendedor (selecionados ou ja pagos)          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VENTOT(nTip)
Local ni   := 0
Local nPos := 0
aVenTot := {}
For ni := 1 to len(aComPre)
	If aComPre[ni,11] .or. ( aComPre[ni,04] == "1" )
		nPos := aScan(aVenTot,{|x| x[1] == aComPre[ni,7] }) // Pesquisa vendedor no vetor total 
		If nPos <= 0
			aAdd(aVenTot,{aComPre[ni,7],0}) // inclui vendedor no vetor total 
			nPos := len(aVenTot)
		EndIf
		aVenTot[nPos,2] += aComPre[ni,5] // soma no vetor total do vendedor
	EndIf
Next
If len(aVenTot) <= 0
	aAdd(aVenTot,{"",0})
EndIf
If nTip > 0
	oLbVenTot:nAt := 1
	oLbVenTot:SetArray(aVenTot)
	oLbVenTot:bLine := { || { aVenTot[oLbVenTot:nAt,01] ,;
							FG_AlinVlrs(Transform(aVenTot[oLbVenTot:nAt,02],"@E 999,999,999.99")) }}
	oLbVenTot:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIKTOT³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tik total do ListBox da Comissao/Premiacao                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIKTOT()
Local ni := 0
For ni := 1 to len(aComPre)
	If aComPre[ni,04] == "0" // NAO PAGA
		aComPre[ni,11] := lTik
	EndIf
Next
oLbComPre:Refresh()
FS_VENTOT(1)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Ponto de Equilibrio do Estoque                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR(nTip)
Local ni       := 0
Local nj       := 0
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "P"
Private limite := 80
Private cString:= "VD2"
Private titulo := STR0031 // Comissao/Premiacao
Private cabec1 := ""
Private cabec2 := ""
Private aReturn:= {"",1,"",1,2,1,"",1}  
Private nomeprog:= "VEIVM510"
Private nLastKey:= 0
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf     
SetDefault(aReturn,cString)
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
For ni := 1 to len(aVenTot)
	If aVenTot[ni,2] > 0
		If cFJaPag == "0" // Nao pago
			cabec1 := left(IIf(nTip==0,STR0035,STR0036)+" "+aVenTot[ni,1]+space(55),55)+right(space(25)+STR0037,25) // Conferencia / Confirmacao do Pagamento / Valor Comissao/Premiacao
		Else // Ja pago
			cabec1 := left(STR0034+" "+aVenTot[ni,1]+space(55),55)+right(space(25)+STR0037,25) // Comissao/Premiacao ja paga / Valor Comissao/Premiacao
		EndIf
		cabec2 := left(STR0017+space(55),55)+right(space(25)+Transform(aVenTot[ni,2],"@E 999,999,999,999.99"),25) // Nro.NF
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
  		For nj := 1 to len(aComPre)
  			If ( aComPre[nj,11] .or. aComPre[nj,4]=="1" ) .and. ( aComPre[nj,7] == aVenTot[ni,1] ) // selecionados ou ja pagos do vendedor
				If nLin >= 58
					cabec2 := left(STR0017+space(55),55)+right(space(25)+STR0026,25) // Nro.NF / continuacao...
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
				EndIf
				@ nLin++, 00 PSAY left(aComPre[nj,8]+" "+Transform(aComPre[nj,2],"@D")+space(62),62)+Transform(aComPre[nj,5],"@E 999,999,999,999.99")
			EndIf
		Next
	EndIf
Next
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEGENDA³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Comissao/Premiacao                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEGENDA()
Local aLegenda := {	{"BR_VERDE"      , STR0032 },; 	// Comissao/Premiacao selecionada
					{"BR_VERMELHO"   , STR0033 },;	// Comissao/Premiacao nao selecionada
					{"BR_AZUL_OCEAN" , STR0034 }}  	// Comissao/Premiacao ja paga
BrwLegenda(STR0031,STR0029,aLegenda) // Comissao/Premiacao / Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida   ³ Data ³ 27/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA)                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{STR0002,"AxPesqui"	,0,1},; // Pesquisar
					{STR0003,"AxVisual"	,0,2},; // Visualizar
					{STR0004,"VM510Ger"	,0,3},; // Gerar
					{STR0005,"VM510Man"	,0,4}}  // Manutencao
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VM510DEL ³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Deleta VD2 ou cria registro negativo                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM510DEL(cNF,cSer)
Local cQuery    := ""
Local cSQLAlias := "SQLVD2"
Local _cCodVen  := ""
Local _cModVda  := ""
Local _cCdCmPr  := ""
Local _nValPag  := 0
Local _dDtIni   := ctod("")
Local _dDtFin   := ctod("")
cQuery := "SELECT VD2.R_E_C_N_O_ AS RECVD2 FROM "+RetSQLName("VD2")+" VD2 "
cQuery += "WHERE VD2.VD2_FILIAL='"+xFilial("VD2")+"' AND VD2.VD2_NUMNFI='"+cNF+"' AND VD2.VD2_SERNFI='"+cSer+"' AND VD2.VD2_COMPRE='1' AND VD2.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	DbSelectArea("VD2")
    VD2->(DbGoTo((cSQLAlias)->( RECVD2 )))
	If VD2->VD2_JAPAGO == "0" // Comissao nao paga
		///////////////////////////////////////////////////////////
		// Deleta comissao, caso ainda nao foi paga a comissao   // 
		///////////////////////////////////////////////////////////
		RecLock("VD2",.F.,.T.)
		VD2->(dbDelete())
		MsUnLock()
	Else // Comissao ja paga
		_cCodVen := VD2->VD2_CODVEN
		_cModVda := VD2->VD2_MODVDA
		_cCdCmPr := VD2->VD2_CDCMPR
		_nValPag := ( VD2->VD2_VALPAG * ( -1 ) )
		_dDtIni  := VD2->VD2_DATINI
		_dDtFin  := VD2->VD2_DATFIN
		///////////////////////////////////////////////////////////
		// Gera comissao NEGATIVA, caso existir comissao ja paga //
		///////////////////////////////////////////////////////////
		DbSelectArea("VD2")
		RecLock("VD2",.t.)
			VD2->VD2_FILIAL := xFilial("VD2")
			VD2->VD2_CODIGO := GetSXENum("VD2","VD2_CODIGO")
			VD2->VD2_CODVEN := _cCodVen
			VD2->VD2_DATLEV := dDataBase
			VD2->VD2_MODVDA := _cModVda
			VD2->VD2_COMPRE := "1"
			VD2->VD2_CDCMPR := _cCdCmPr
			VD2->VD2_NUMNFI := cNF
			VD2->VD2_SERNFI := cSer
			VD2->VD2_VALCAL := _nValPag
			VD2->VD2_JAPAGO := "0"
			VD2->VD2_VALPAG := VD2->VD2_VALCAL
			VD2->VD2_DATPAG := ctod("")
			VD2->VD2_DATGER := dDataBase
			VD2->VD2_DATINI := _dDtIni
			VD2->VD2_DATFIN := _dDtFin
		MsUnLock()
		ConfirmSx8()
	EndIf
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
Return()