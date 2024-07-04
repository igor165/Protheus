#Include "PLSR415.ch"
#Include "PROTHEUS.ch"
#Include "PLSMGER.ch"
#Include "TopConn.ch"
//
#Define SEPARADOR Space(01)
//
#Define PIC_TAXA   "@E 999.99 "
#Define PIC_QTD    "@E 999,999 "
#Define PIC_VALOR7 "@E 999,999.99 "
#Define PIC_VALOR8 "@E 9,999,999.99 "
//
#Define COL_ABR  01
#Define COL_SEG  02
#Define COL_EMP  03
#Define COL_QTD1 04
#Define COL_QTD2 05
#Define COL_QTD3 06
#Define COL_QTDM 07
#Define COL_USUA 08
//
#Define TOT_COL1 01
#Define TOT_COL2 02
#Define TOT_COL3 03
#Define TOT_COLM 04
#Define TOT_TAXA 05
#Define TOT_DESC 06
#Define TOT_VLR  07
#Define TOT_VLTO 08
//
#Define ITE_ATE60 01//Ate 60 ano
#Define ITE_MAI60 02//Menos de 60 anos

Static aTrim := { ;		//	Trimestres a serem considerados conforme RN89
	'12,01,02', ;
	'03,04,05', ;
	'06,07,08', ;
	'09,10,11'}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR460 ³ Autor ³ Angelo Sperandio       ³ Data ³ 30/01/04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Emite relatorio para calculo da taxa de saude              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR460()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSR460(lAuto)

	Private cNomeProg   := "PLSR460"
	Private nCaracter   := 15
	Private cTamanho    := "G"
	Private cTitulo     := STR0001 //"Resumo para Taxa de Saude"
	Private cDesc1      := STR0002 //"Emite resumo para calculo da taxa de saude."
	Private cDesc2      := ""
	Private cDesc3      := ""
	Private cCabec1     := ""
	Private cCabec2     := ""
	Private cCabecx     := ""
	Private cAlias      := "BA1"
	Private cPerg       := "PLR460"
	Private wnRel       := "PLSR460"
	Private Li          := 99
	Private nLi         := 01
	Private m_pag       := 1
	Private aReturn     := {STR0003, 1,STR0004, 1, 1, 2, "",1 } //"Zebrado"###"Administracao"
	Private lAbortPrint := .F.
	Private aOrdens     := ""
	Private lDicion     := .F.
	Private lCompres    := .F.
	Private lCrystal    := .F.
	Private lFiltro     := .T.
	Private nTaxa       := 0
	Private cTIPODB 	:= Alltrim(Upper(TCGetDb()))
	DEFAULT lAUto       := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama SetPrint                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IIF(!lAuto,wnRel := SetPrint(cAlias,wnRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,cTamanho,{},lFiltro,lCrystal),)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi cancelada a operacao                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuto .And. nLastKey  == 27
		Return
	Endif

	BA1->(DbSetOrder(2))
	BA3->(DbSetOrder(1))
	BI3->(DbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acessa parametros do relatorio...                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	nTaxa    := IIF(!lAuto,mv_par04,2)
	cTitulo  += " ** Referência: " + DTOC(dDataBase) + " **"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta cabecalho                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCabecx := STR0005+Space(23)+STR0006
	cCabecx += Space(36)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura impressora                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IIF(!lAuto,SetDefault(aReturn,cAlias),)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Emite relat¢rio                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsAguarde( {|| IMPR460(lAuto) }, cTitulo ,"", .T.)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ IMPR460  ³ Autor ³ Angelo Sperandio      ³ Data ³ 30/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function IMPR460(lAuto)
	Local nOrdSel			:= aReturn[8]
	Local nI				:= 0
	Local nFor				:= 0
	Local aTotSegAte60	:= {0,0,0,0,0,0,0,0}
	Local aTotSegMai60	:= {0,0,0,0,0,0,0,0}
	Local aTotSeg  		:= {0,0,0,0,0,0,0,0}
	Local aTotAbrAte60	:= {0,0,0,0,0,0,0,0}
	Local aTotAbrMai60	:= {0,0,0,0,0,0,0,0}
	Local aTotAbr  		:= {0,0,0,0,0,0,0,0}
	Local aTotGerAte60	:= {0,0,0,0,0,0,0,0}
	Local aTotGerMai60	:= {0,0,0,0,0,0,0,0}
	Local aTotGer  		:= {0,0,0,0,0,0,0,0}
	Local cMes01			:= ""
	Local cMes02 			:= ""
	Local cMes03 			:= ""
	Local cAno 			    := AllTrim(Str(MV_PAR02))
	Local cTrim 			:= AllTrim(MV_PAR03)
	Local cMV_COMP := GetMv("MV_COMP")
	Local cMV_NORM := GetMv("MV_NORM")
	Local cAbrSeg := ""
	Default lAuto :=.F.

	If lAuto
		cAno:="2017"
		cTrim:="04,"
	Endif

	IIF(!lAuto,msProcTxt(STR0014),"")

	aTrimProc := StrTokArr(cTrim,',')
	For nFor := 1 TO Len(aTrimProc)

		aTotGerAte60	:= {0,0,0,0,0,0,0,0}
		aTotGerMai60	:= {0,0,0,0,0,0,0,0}
		aTotGer  		:= {0,0,0,0,0,0,0,0}

		nTrim := Val(aTrimProc[nFor])
		aMesAno := RetMesAno(nTrim,cAno)
		//	Cabeçalho
		cMes01  := PADR(MesExtenso(VAL(  aMesAno[1][1]  )), 6)
		cMes02  := PADR(MesExtenso(VAL( aMesAno[2][1] )), 6)
		cMes03  := PADR(MesExtenso(VAL( aMesAno[3][1]   )), 6)
		cCabec1 := cCabecx + STR0008 + Space(02) + cMes01 + "  " + cMes02 + "  " + cMes03 + "   " + STR0013 + " M   " + ;
			STR0009 + Space(08) + STR0010 + Space(03) + STR0011 + Space(08) + STR0012

		Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1, cMV_COMP, cMV_NORM))

		If VerAbrangencias()

			While !TRBABR->(Eof())

				aTotAbrAte60	:= {0,0,0,0,0,0,0,0}
				aTotAbrMai60	:= {0,0,0,0,0,0,0,0}
				cLinAbr := TRBABR->B4X_CODORI + Space(01) + TRBABR->B4X_DESORI + Space(01)

				If VerSegmentos(TRBABR->B4X_CODORI)

					While !TRBSEG->(Eof())

						cLinSeg := TRBSEG->B4Y_SEGMEN + Space(01) + TRBSEG->B4Y_DESORI + Space(01)

						//Quantidade de Beneficiários ativos:
						CalcQtdBenAtiv(aTotSegAte60,aTotSegMai60)

						TotalizaGrupo(aTotSegAte60,aTotSegMai60,aTotSeg,aTotAbrAte60,;
							aTotAbrMai60)

						cAbrSeg := cLinAbr + cLinSeg + Space(11)
						PrintGrupos(cAbrSeg,STR0026,aTotSegAte60,aTotSegMai60,;
							aTotSeg)

						TRBSEG->(dbSkip())

					EndDo

					TotalizaGrupo(aTotAbrAte60,aTotAbrMai60,aTotAbr,aTotGerAte60,;
						aTotGerMai60)

					cAbrSeg := STR0027 + Replicate(".",Len(cAbrSeg)-Len(STR0027))
					PrintGrupos(cAbrSeg,STR0012,aTotAbrAte60,aTotAbrMai60,;
						aTotAbr)

				EndIf

				TRBABR->(dbSkip())
				TRBSEG->(dbCloseArea())

			EndDo

			//Total Geral
			TotalizaGrupo(aTotGerAte60,aTotGerMai60,aTotGer)

			cAbrSeg := STR0028 + Replicate(".",Len(cAbrSeg)-Len(STR0028))
			PrintGrupos(cAbrSeg,STR0012,aTotGerAte60,aTotGerMai60,;
				aTotGer)

		EndIf
		TRBABR->(dbCloseArea())
		//Imprime rodape do relatorio...
		Roda(0,space(10),cTamanho)

	Next nFor

	If aReturn[5] == 1
		Set Printer To
		Ourspool(wnRel)
	Endif
	MS_FLUSH()

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetQtdBenef

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TotalizaGrupo(aAte60,aMai60,aTot,aSupAte60,;
		aSupMai60)

	Local nI := 1
	Default aSupAte60 := {}
	Default aSupMai60 := {}

	For nI := 1 to Len(aTot)
		//Totaliza segmento
		aTot[nI] := aAte60[nI] + aMai60[nI]
		//Totaliza Abrangecia
		If Len(aSupAte60) > 0 .AND. Len(aSupMai60) > 0
			aSupAte60[nI] += aAte60[nI]
			aSupMai60[nI] += aMai60[nI]
		EndIf
	Next nI

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetQtdBenef

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CalcQtdBenAtiv(aTotSegAte60,aTotSegMai60)
	Local dDatIni := cToD("")
	Local dDatFim := cToD("")

	Local nQtd1MAte60 := 0
	Local nQtd1MMai60 := 0
	Local nQtd2MAte60 := 0
	Local nQtd2MMai60 := 0
	Local nQtd3MAte60 := 0
	Local nQtd3MMai60 := 0
	Local nVlrAte60 := 0
	Local nDesAte60 := 0
	Local nAte60Media := 0
	Local nTotAte60 := 0
	Local nVlrMai60 := 0
	Local nDesMai60 := 0
	Local nMai60Media := 0
	Local nTotMai60 := 0
	Local nPerSeg := TRBSEG->B4Y_PERDES
	Local nPerAbr := TRBABR->B4X_PERDES

	Local cOper    := mv_par01

	If IsBlind()
		cOper    := "000000"
	Endif

	//1 - No primeiro mês do trimestre
	dDatIni := cToD("01/" + aMesAno[1][1] + "/"+ aMesAno[1][2])
	dDatFim := Lastday(dDatIni, 0)
	//1.1 - Com Menos de 60 Anos
	nQtd1MAte60 := RetQtdBenef( cOper, dDatIni , dDatFim , .T.,TRBABR->B4X_CODORI,;
		TRBSEG->B4Y_SEGMEN )

	//1.2 - Com Mais de 60 Anos
	nQtd1MMai60 := RetQtdBenef(cOper,dDatIni , dDatFim , .F. ,TRBABR->B4X_CODORI,;
		TRBSEG->B4Y_SEGMEN )

	//2 - No Segundo mês do trimestre
	dDatIni := cToD("01/" + aMesAno[2][1] + "/"+ aMesAno[2][2])
	dDatFim := Lastday(dDatIni, 0)
	//2.1 - Com Menos de 60 Anos
	nQtd2MAte60 := RetQtdBenef(cOper,dDatIni , dDatFim , .T.,TRBABR->B4X_CODORI,;
		TRBSEG->B4Y_SEGMEN  )
	//2.2 - Com Mais de 60 Anos
	nQtd2MMai60 := RetQtdBenef(cOper,dDatIni , dDatFim , .F. ,TRBABR->B4X_CODORI,;
		TRBSEG->B4Y_SEGMEN )

	//3 - No Terceiro mês do trimestre
	dDatIni := cToD("01/" + aMesAno[3][1] + "/"+ aMesAno[3][2])
	dDatFim := Lastday(dDatIni, 0)
	//3.1 - Com Menos de 60 Anos
	nQtd3MAte60 := RetQtdBenef(cOper,dDatIni , dDatFim , .T. ,TRBABR->B4X_CODORI,;
		TRBSEG->B4Y_SEGMEN )
	//3.2 - Com Mais de 60 Anos
	nQtd3MMai60 := RetQtdBenef(cOper,dDatIni , dDatFim , .F.,TRBABR->B4X_CODORI,;
		TRBSEG->B4Y_SEGMEN  )

	//Quantidade Média
	nAte60Media := (nQtd1MAte60+nQtd2MAte60+nQtd3MAte60) / 3
	nMai60Media := (nQtd1MMai60+nQtd2MMai60+nQtd3MMai60) / 3

	//Calcula valores - Ate 60 anos
	nVlrAte60 := nAte60Media * nTaxa
	nDesAte60 := noround((nVlrAte60 * (nPerAbr / 100)) + (nVlrAte60 * (nPerSeg / 100)),2)
	nTotAte60 := nVlrAte60 - nDesAte60
	nTotAte60 := iIF(nTotAte60<0,0,nTotAte60)

	//Calcula valores - Mais de 60 anos  - REMOVIDO, VALOR PARA >60 É SEMPRE 0
	// nVlrMai60 := nMai60Media * nTaxa
	// nDesMai60 := noround((nVlrMai60 * (nPerAbr / 100)) + (nVlrMai60 * (nPerSeg / 100)),2)
	// nTotMai60 := nVlrMai60 - nDesMai60
	// nTotMai60 := iIF(nTotMai60<0,0,nTotMai60)

	//Segmento
	aTotSegAte60[TOT_COL1] := nQtd1MAte60
	aTotSegAte60[TOT_COL2] := nQtd2MAte60
	aTotSegAte60[TOT_COL3] := nQtd3MAte60
	aTotSegAte60[TOT_COLM] := nAte60Media
	aTotSegAte60[TOT_TAXA] := nTaxa
	aTotSegAte60[TOT_DESC] := nDesAte60
	aTotSegAte60[TOT_VLR]  := nVlrAte60
	aTotSegAte60[TOT_VLTO] := nTotAte60

	aTotSegMai60[TOT_COL1] := nQtd1MMai60
	aTotSegMai60[TOT_COL2] := nQtd2MMai60
	aTotSegMai60[TOT_COL3] := nQtd3MMai60
	aTotSegMai60[TOT_COLM] := nMai60Media
	aTotSegMai60[TOT_TAXA] := 0 //nTaxa
	aTotSegMai60[TOT_DESC] := nDesMai60
	aTotSegMai60[TOT_VLR ] := nVlrMai60
	aTotSegMai60[TOT_VLTO] := nTotMai60
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetQtdBenef

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetQtdBenef(cCodOpe,dDatIni,dDatFim,lAte60,cAbrang,cSegmen)
	Local cDataBase	:= DTOS(dDataBase)
	Local cSql := ""
	Local nQtd := 0
	Local dDatLim

	Default cCodOpe := ""
	Default dDatIni := CTOD("")
	Default dDatFim := CTOD("")
	Default lAte60 := .F.

	If !Empty(dDatIni)

		If !isBlind()
			dDatLim := DTOS(Lastday(cToD("01/" + aMesAno[3][1] + "/"+ aMesAno[3][2]), 0))
		Else
			dDatLim := DTOS(dDatFim)

		EndIf

		cSQL := " SELECT COUNT(DISTINCT(B3K_MATRIC)) QTD " + CRLF
		cSQL += " FROM " + RetSqlName("B3K") + " B3K " + CRLF
		cSQL += " LEFT OUTER JOIN " + RetSqlName("B4W") + " B4W ON B3K_FILIAL=B4W_FILIAL AND B3K_MATRIC = B4W_MATRIC AND B4W.D_E_L_E_T_ = '' ," + RetSqlName("B3J") +   " B3J," + RetSqlName("B3W") + " B3W " + CRLF
		cSQL += " WHERE " + CRLF
		cSQL += " 	B3K_FILIAL = '" + xFilial('B3K') + "' " + CRLF
		cSQL += " 	AND B3J_FILIAL = '" + xFilial('B3J') + "' " + CRLF
		cSQL += " 	AND B3W_FILIAL = '" + xFilial('B3W') + "' " + CRLF
		cSQL += " 	AND B3K_CODPRO = B3J_CODIGO " + CRLF
		cSQL += " 	AND B3K_CODCCO = B3W_CODCCO " + CRLF
		cSQL += " 	AND B3K_CODCCO <> ' ' " + CRLF
		cSQL += " 	AND B3K_CODOPE = '" + cCodOpe + "' " + CRLF
		cSQL += " 	AND B3J_ABRANG ='" + cAbrang + "'" + CRLF
		cSQL += " 	AND B3J_SEGMEN ='" + cSegmen + "'" + CRLF

		If cTIPODB $ "MSSQL/MSSQL7"
			cSQL += " AND  ( YEAR('" + dDatLim + "')-YEAR(B3K_DATNAS)-IIF(MONTH('" + dDatLim + "')*32+DAY('" + dDatLim + "')<MONTH(B3K_DATNAS)*32+DAY(B3K_DATNAS),1,0) )" + IIf(lAte60,"<",">=") + " '60' " + CRLF
		ElseIf cTIPODB $ "POSTGRES"
			cSQL += " AND DATE_PART('YEAR', AGE('" + dDatLim + "',  TO_DATE(CONCAT(SUBSTRING(B3K_DATNAS,1,4),'-',SUBSTRING(B3K_DATNAS,5,2),'-',SUBSTRING(B3K_DATNAS,7,2)), 'YYYY/MM/DD')	))" + IIf(lAte60,"<",">=") + " 60 " + CRLF
		Else
			cSQL += " AND EXTRACT(YEAR FROM TO_DATE('" + dDatLim + "', 'YYYY-MM-DD')) - EXTRACT(YEAR FROM TO_DATE(B3K_DATNAS, 'YYYY-MM-DD')) - CASE WHEN EXTRACT(MONTH FROM TO_DATE('" + dDatLim + "', 'YYYY-MM-DD'))*32+EXTRACT (DAY FROM TO_DATE('" + dDatLim + "', 'YYYY-MM-DD')) < EXTRACT(MONTH FROM TO_DATE(B3K_DATNAS, 'YYYY-MM-DD'))*32+EXTRACT (DAY FROM TO_DATE(B3K_DATNAS, 'YYYY-MM-DD')) THEN 1 ELSE 0 END " + IIf(lAte60,"<",">=") + " 60 " + CRLF
		EndIf

		cSQL += " 	AND ((SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 " + CRLF
		cSQL += " 		WHERE   B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' " + CRLF
		cSQL += " 			AND B4W2.B4W_TIPO = '0' " + CRLF
		cSQL += "			AND B4W2.B4W_STATUS = '1' " + CRLF
		cSQL += "			AND B4W2.D_E_L_E_T_ = ' ' " + CRLF
		cSQL += "           AND B4W2.B4W_MATRIC = B3K_MATRIC) = 0" + CRLF

		cSQL += " 	AND ((SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 " + CRLF
		cSQL += " 		WHERE   B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' " + CRLF
		cSQL += " 			AND B4W2.B4W_TIPO = '1' " + CRLF
		cSQL += "			AND B4W2.B4W_STATUS = '1' " + CRLF
		cSQL += "			AND B4W2.D_E_L_E_T_ = ' ' " + CRLF
		cSQL += "			AND B4W2.B4W_MATRIC = B3K_MATRIC) >= 1) " + CRLF

		cSQL += " 	OR ((SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 " + CRLF
		cSQL += " 		WHERE   B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' " + CRLF
		cSQL += " 			AND B4W2.B4W_TIPO = '0' " + CRLF
		cSQL += "			AND B4W2.B4W_STATUS = '1' " + CRLF
		cSQL += "			AND B4W2.D_E_L_E_T_ = ' ' " + CRLF
		cSQL += "			AND B4W2.B4W_MATRIC = B3K_MATRIC) =  " + CRLF
		cSQL += "			(SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 " + CRLF
		cSQL += " 				WHERE  B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' " + CRLF
		cSQL += " 				AND B4W2.B4W_TIPO = '1' " + CRLF
		cSQL += "				AND B4W2.B4W_STATUS = '1' " + CRLF
		cSQL += "				AND B4W2.B4W_MATRIC = B3K_MATRIC " + CRLF
		cSQL += "				AND B4W2.D_E_L_E_T_ = ' ' ))) "  + CRLF
		cSQL += "	AND B3K.B3K_DATINC <= '" + DTOS(dDatFim) + "' " + CRLF
		cSQL += "	AND (B3K.B3K_SITANS IN (' ','A')  OR (B3K.B3K_SITANS ='I' AND  B3K.B3K_DATBLO >= '" + DTOS(dDatFim) + "'  ) )" + CRLF
		cSQL += "	AND B3K.D_E_L_E_T_ = '' " + CRLF
		cSQL += "	AND B3J.D_E_L_E_T_ = '' " + CRLF

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBQTD",.F.,.T.)

		If !TRBQTD->(Eof())

			nQtd := TRBQTD->QTD

		EndIf

		TRBQTD->(dbCloseArea())
	EndIf

Return nQtd

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetQtdBenef

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrintGrupos(cTexto,cTextoTotal,aAte60,aMai60,;
		aTot)

	Local nColuna  := 00

	@ Li,nColuna pSay ""
	Li++
	PrintLines(aAte60,cTexto,STR0019)
	PrintLines(aMai60,Space(Len(cTexto)),STR0020)
	PrintLines(aTot,Space(Len(cTexto)),cTextoTotal)
	@ Li,nColuna pSay ""
	Li++

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetQtdBenef

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrintLines(aValue,cLinha,cTexto)

	Local nColuna  := 00
	Local nQtdLin	:= 58
	Local cMV_COMP := GetMv("MV_COMP")
	Local cMV_NORM := GetMv("MV_NORM")

	Default cLinha  := ""

	If Li > nQtdLin
		Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1, cMV_COMP, cMV_NORM))
	Endif

	cLinha += Padl(cTexto,15," ")
	cLinha += SEPARADOR

	cLinha += Transform(aValue[TOT_COL1]  ,PIC_QTD) + SEPARADOR
	cLinha += Transform(aValue[TOT_COL2]  ,PIC_QTD) + SEPARADOR
	cLinha += Transform(aValue[TOT_COL3]  ,PIC_QTD) + SEPARADOR
	cLinha += Transform(aValue[TOT_COLM]  ,PIC_QTD) + SEPARADOR
	cLinha += Transform(aValue[TOT_TAXA] ,PIC_TAXA) + SEPARADOR
	cLinha += Transform(aValue[TOT_VLR ],PIC_VALOR8)+ SEPARADOR
	cLinha += Transform(aValue[TOT_DESC],PIC_VALOR7)+ SEPARADOR
	cLinha += Transform(aValue[TOT_VLTO],PIC_VALOR8)+ SEPARADOR

	@ Li,nColuna pSay cLinha
	Li++

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIPRTV

Funcao criada para retornar a lista de rotinas / jobs de validacao

@param cDado		Variavel passada por referencia para receber a lista de opcoes selecionada do F3
@description
	Lista de opcoes
	1 - Produtos / Plano
	2 - Beneficiarios
	3 - Eventos X Despesas

@return cDados		Lista de opcoes selecionadas no F3 separadas por virgula

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSTSSRTV(cDado)
	Local oDlg		:= Nil
	Local aConjunto	:= {}
	Local nFor		:= 0
	Local nOpc		:= 0
	Local bOK		:= { || nOpc := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Default cDado	:= ''

	aAdd(aConjunto,{'1','1º Trimestre'	,.F.})
	aAdd(aConjunto,{'2','2º Trimestre'	,.F.})
	aAdd(aConjunto,{'3','3º Trimestre'	,.F.})
	aAdd(aConjunto,{'4','4º Trimestre'	,.F.})

	DEFINE MSDIALOG oDlg TITLE 'Conjuntos a processar' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT 'Selecione o(s) trimestre(s) a serem processados' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
	oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
	oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:SetArray(aConjunto)
	oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 12 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

	If nOpc == 1

		cDado := ""
		For nFor := 1 To Len(aConjunto)
			If aConjunto[nFor,3]
				cDado += aConjunto[nFor,1]+","
			Endif
		Next

	Endif

	//Tira a virgula do final
	If Subs(cDado,Len(cDado),1) == ","
		cDado := Subs(cDado,1,Len(cDado)-1)
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIPRTV

Funcao criada para retornar a lista de rotinas / jobs de validacao

@param cDado		Variavel passada por referencia para receber a lista de opcoes selecionada do F3
@description
	Lista de opcoes
	1 - Produtos / Plano
	2 - Beneficiarios
	3 - Eventos X Despesas

@return cDados		Lista de opcoes selecionadas no F3 separadas por virgula

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------


Static Function RetMesAno(nTrim,cAno)

	Local aRet := {}
	Local  aTrim := { ;		//	Trimestres a serem considerados conforme RN89
		{'12','01','02'}, ;
		{'03','04','05'}, ;
		{'06','07','08'}, ;
		{'09','10','11'}}
	aRet := { {aTrim[nTrim][1],IIf(nTrim=1,AllTrim(Str(Val(cAno)-1) ), cAno) },;
		{aTrim[nTrim][2],cAno},;
		{aTrim[nTrim][3],cAno} }

Return aRet
