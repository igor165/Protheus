#include "protheus.ch"
#include "msGraphi.ch"
#include "QPPP010.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QPPP010  ³ Autor ³ Rafael S. Bernardi    ³ Data ³22/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - PPAPs completos e imcompletos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void            											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPP010()

Local aRetPanel := {} //Array com os dados que serao exibidos no painel
Local aResult   := {}
Local aDesCpo   := aClone(SX3Desc({"QK1_PECA","QK1_REV","AD8_STATUS"}))

Pergunte("QPPP10",.F.)

//Geracao dos Dados para o Browse
aResult := aClone(QPPGerPPAP())

aAdd(aRetPanel,{||})       
aAdd(aRetPanel,{aDesCpo[1],aDesCpo[2],aDesCpo[3]})//"Peca"###"Revisao"###"Status"
aAdd(aRetPanel,aResult)
aAdd(aRetPanel,{"LEFT","CENTER","CENTER"})

Return aRetPanel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QPPGerPPAP³ Autor ³ Rafael S. Bernardi    ³ Data ³22/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados do painel de gestao PPAPs completos e         ³±±
±±³          ³imcompletos                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPPAP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPGerPPAP()
Local cAliasQry := GetNextAlias()
Local aDados    := {}
Local aRet      := {}

MakeSqlExpr("QPPP10")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QK1");dbSelectArea("QKG");dbSelectArea("QKF")
dbSelectArea("QM4");dbSelectArea("QK9");dbSelectArea("QKB")
dbSelectArea("QKD");dbSelectArea("QKC");dbSelectArea("QK3")
dbSelectArea("QKI");dbSelectArea("QKL");dbSelectArea("QK5")
dbSelectArea("QK7");dbSelectArea("QKJ");dbSelectArea("QKN")
dbSelectArea("QKH");dbSelectArea("QKQ");dbSelectArea("QKR")
dbSelectArea("QKS");dbSelectArea("QKT");dbSelectArea("QKU")
dbSelectArea("QKV");dbSelectArea("QKW");dbSelectArea("QKX")
dbSelectArea("QKY");dbSelectArea("QL0");dbSelectArea("QL1")

BeginSql Alias cAliasQry

	SELECT QK1.QK1_PECA, QK1.QK1_REV, COUNT(QKG.QKG_PECA) QKGCOUNT,
									  COUNT(QKF.QKF_PECA) QKFCOUNT,
									  COUNT(QM4.QM4_PECA) QM4COUNT,
									  COUNT(QK9.QK9_PECA) QK9COUNT,
									  COUNT(QKB.QKB_PECA) QKBCOUNT,
									  COUNT(QKD.QKD_PECA) QKDCOUNT,
									  COUNT(QKC.QKC_PECA) QKCCOUNT,
									  COUNT(QK3.QK3_PECA) QK3COUNT,
									  COUNT(QKI.QKI_PECA) QKICOUNT,
									  COUNT(QKL.QKL_PECA) QKLCOUNT,
									  COUNT(QK5.QK5_PECA) QK5COUNT,
									  COUNT(QK7.QK7_PECA) QK7COUNT,
									  COUNT(QKJ.QKJ_PECA) QKJCOUNT,
									  COUNT(QKN.QKN_PECA) QKNCOUNT,
									  COUNT(QKH.QKH_PECA) QKHCOUNT,
									  COUNT(QKQ.QKQ_PECA) QKQCOUNT,
									  COUNT(QKR.QKR_PECA) QKRCOUNT,
									  COUNT(QKS.QKS_PECA) QKSCOUNT,
									  COUNT(QKT.QKT_PECA) QKTCOUNT,
									  COUNT(QKU.QKU_PECA) QKUCOUNT,
									  COUNT(QKV.QKV_PECA) QKVCOUNT,
									  COUNT(QKW.QKW_PECA) QKWCOUNT,
									  COUNT(QKX.QKX_PECA) QKXCOUNT,
									  COUNT(QKY.QKY_PECA) QKYCOUNT,
									  COUNT(QL0.QL0_PECA) QL0COUNT,
									  COUNT(QL1.QL1_PECA) QL1COUNT FROM %table:QK1% QK1
	LEFT JOIN %TABLE:QKG% QKG ON QKG.QKG_FILIAL = %XFILIAL:QKG% AND
	                   QKG.QKG_PECA   = QK1.QK1_PECA   AND
			   QKG.QKG_REVINV = QK1.QK1_REVINV AND
			   QKG.%NOTDEL%
	
	LEFT JOIN %TABLE:QKF% QKF ON QKF.QKF_FILIAL = %XFILIAL:QKF% AND
	                   QKF.QKF_PECA   = QK1.QK1_PECA   AND
			   QKF.QKF_REVINV = QK1.QK1_REVINV AND
			   QKF.%NOTDEL%
	
	LEFT JOIN %TABLE:QM4% QM4 ON QM4.QM4_FILIAL = %XFILIAL:QM4% AND
	                   QM4.QM4_PECA   = QK1.QK1_PECA   AND
			   QM4.QM4_REVINV = QK1.QK1_REVINV AND
			   QM4.%NOTDEL%
	
	LEFT JOIN %TABLE:QK9% QK9 ON QK9.QK9_FILIAL = %XFILIAL:QK9% AND
	                   QK9.QK9_PECA   = QK1.QK1_PECA   AND
			   QK9.QK9_REVINV = QK1.QK1_REVINV AND
			   QK9.%NOTDEL%
	
	LEFT JOIN %TABLE:QKB% QKB ON QKB.QKB_FILIAL = %XFILIAL:QKB% AND
	                   QKB.QKB_PECA   = QK1.QK1_PECA   AND
			   QKB.QKB_REVINV = QK1.QK1_REVINV AND
			   QKB.%NOTDEL%
	
	LEFT JOIN %TABLE:QKD% QKD ON QKD.QKD_FILIAL = %XFILIAL:QKD% AND
	                   QKD.QKD_PECA   = QK1.QK1_PECA   AND
			   QKD.QKD_REVINV = QK1.QK1_REVINV AND
			   QKD.%NOTDEL%
	
	LEFT JOIN %TABLE:QKC% QKC ON QKC.QKC_FILIAL = %XFILIAL:QKC% AND
	                   QKC.QKC_PECA   = QK1.QK1_PECA   AND
			   QKC.QKC_REVINV = QK1.QK1_REVINV AND
			   QKC.%NOTDEL%
	
	LEFT JOIN %TABLE:QK3% QK3 ON QK3.QK3_FILIAL = %XFILIAL:QK3% AND
	                   QK3.QK3_PECA   = QK1.QK1_PECA   AND
			   QK3.QK3_REVINV = QK1.QK1_REVINV AND
			   QK3.%NOTDEL%
	
	LEFT JOIN %TABLE:QKI% QKI ON QKI.QKI_FILIAL = %XFILIAL:QKI% AND
	                   QKI.QKI_PECA   = QK1.QK1_PECA   AND
			   QKI.QKI_REVINV = QK1.QK1_REVINV AND
			   QKI.%NOTDEL%
	
	LEFT JOIN %TABLE:QKL% QKL ON QKL.QKL_FILIAL = %XFILIAL:QKL% AND
	                   QKL.QKL_PECA   = QK1.QK1_PECA   AND
			   QKL.QKL_REVINV = QK1.QK1_REVINV AND
			   QKL.%NOTDEL%
	
	LEFT JOIN %TABLE:QK5% QK5 ON QK5.QK5_FILIAL = %XFILIAL:QK5% AND
	                   QK5.QK5_PECA   = QK1.QK1_PECA   AND
			   QK5.QK5_REVINV = QK1.QK1_REVINV AND
			   QK5.%NOTDEL%
	
	LEFT JOIN %TABLE:QK7% QK7 ON QK7.QK7_FILIAL = %XFILIAL:QK7% AND
	                   QK7.QK7_PECA   = QK1.QK1_PECA   AND
			   QK7.QK7_REVINV = QK1.QK1_REVINV AND
			   QK7.%NOTDEL%
	
	LEFT JOIN %TABLE:QKJ% QKJ ON QKJ.QKJ_FILIAL = %XFILIAL:QKJ% AND
	                   QKJ.QKJ_PECA   = QK1.QK1_PECA   AND
			   QKJ.QKJ_REVINV = QK1.QK1_REVINV AND
			   QKJ.%NOTDEL%
	
	LEFT JOIN %TABLE:QKN% QKN ON QKN.QKN_FILIAL = %XFILIAL:QKN% AND
	                   QKN.QKN_PECA   = QK1.QK1_PECA   AND
			   QKN.QKN_REVINV = QK1.QK1_REVINV AND
			   QKN.%NOTDEL%
	
	LEFT JOIN %TABLE:QKH% QKH ON QKH.QKH_FILIAL = %XFILIAL:QKH% AND
	                   QKH.QKH_PECA   = QK1.QK1_PECA   AND
			   QKH.QKH_REVINV = QK1.QK1_REVINV AND
			   QKH.%NOTDEL%
	
	LEFT JOIN %TABLE:QKQ% QKQ ON QKQ.QKQ_FILIAL = %XFILIAL:QKQ% AND
	                   QKQ.QKQ_PECA   = QK1.QK1_PECA   AND
			   QKQ.QKQ_REVINV = QK1.QK1_REVINV AND
			   QKQ.%NOTDEL%
	
	LEFT JOIN %TABLE:QKR% QKR ON QKR.QKR_FILIAL = %XFILIAL:QKR% AND
	                   QKR.QKR_PECA   = QK1.QK1_PECA   AND
			   QKR.QKR_REVINV = QK1.QK1_REVINV AND
			   QKR.%NOTDEL%
	
	LEFT JOIN %TABLE:QKS% QKS ON QKS.QKS_FILIAL = %XFILIAL:QKS% AND
	                   QKS.QKS_PECA   = QK1.QK1_PECA   AND
			   QKS.QKS_REVINV = QK1.QK1_REVINV AND
			   QKS.%NOTDEL%
	
	LEFT JOIN %TABLE:QKT% QKT ON QKT.QKT_FILIAL = %XFILIAL:QKT% AND
	                   QKT.QKT_PECA   = QK1.QK1_PECA   AND
			   QKT.QKT_REVINV = QK1.QK1_REVINV AND
			   QKT.%NOTDEL%
	
	LEFT JOIN %TABLE:QKU% QKU ON QKU.QKU_FILIAL = %XFILIAL:QKU% AND
	                   QKU.QKU_PECA   = QK1.QK1_PECA   AND
			   QKU.QKU_REVINV = QK1.QK1_REVINV AND
			   QKU.%NOTDEL%
	
	LEFT JOIN %TABLE:QKV% QKV ON QKV.QKV_FILIAL = %XFILIAL:QKV% AND
	                   QKV.QKV_PECA   = QK1.QK1_PECA   AND
			   QKV.QKV_REVINV = QK1.QK1_REVINV AND
			   QKV.%NOTDEL%
	
	LEFT JOIN %TABLE:QKW% QKW ON QKW.QKW_FILIAL = %XFILIAL:QKW% AND
	                   QKW.QKW_PECA   = QK1.QK1_PECA   AND
			   QKW.QKW_REVINV = QK1.QK1_REVINV AND
			   QKW.%NOTDEL%
	
	LEFT JOIN %TABLE:QKX% QKX ON QKX.QKX_FILIAL = %XFILIAL:QKX% AND
	                   QKX.QKX_PECA   = QK1.QK1_PECA   AND
			   QKX.QKX_REVINV = QK1.QK1_REVINV AND
			   QKX.%NOTDEL%
	
	LEFT JOIN %TABLE:QKY% QKY ON QKY.QKY_FILIAL = %XFILIAL:QKY% AND
	                   QKY.QKY_PECA   = QK1.QK1_PECA   AND
			   QKY.QKY_REVINV = QK1.QK1_REVINV AND
			   QKY.%NOTDEL%
	
	LEFT JOIN %TABLE:QL0% QL0 ON QL0.QL0_FILIAL = %XFILIAL:QL0% AND
	                   QL0.QL0_PECA   = QK1.QK1_PECA   AND
			   QL0.QL0_REVINV = QK1.QK1_REVINV AND
			   QL0.%NOTDEL%
	
	LEFT JOIN %TABLE:QL1% QL1 ON QL1.QL1_FILIAL = %XFILIAL:QL1% AND
	                   QL1.QL1_PECA   = QK1.QK1_PECA   AND
			   QL1.QL1_REVINV = QK1.QK1_REVINV AND
			   QL1.%NOTDEL%
	
	WHERE QK1.QK1_FILIAL = %XFILIAL:QK1% AND  QK1.QK1_PECA BETWEEN %EXP:mv_par02% AND %EXP:mv_par03% AND QK1.D_E_L_E_T_ = ' '
	GROUP BY QK1.QK1_PECA, QK1.QK1_REV
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{(cAliasQry)->QK1_PECA,;
					 (cAliasQry)->QK1_REV,;
					 (cAliasQry)->QKGCOUNT,;
					 (cAliasQry)->QKFCOUNT,;
					 (cAliasQry)->QM4COUNT,;
					 (cAliasQry)->QK9COUNT,;
					 (cAliasQry)->QKBCOUNT,;
					 (cAliasQry)->QKDCOUNT,;
					 (cAliasQry)->QKCCOUNT,;
					 (cAliasQry)->QK3COUNT,;
					 (cAliasQry)->QKICOUNT,;
					 (cAliasQry)->QKLCOUNT,;
					 (cAliasQry)->QK5COUNT,;
					 (cAliasQry)->QK7COUNT,;
					 (cAliasQry)->QKJCOUNT,;
					 (cAliasQry)->QKNCOUNT,;
					 (cAliasQry)->QKHCOUNT,;
					 (cAliasQry)->QKQCOUNT,;
					 (cAliasQry)->QKRCOUNT,;
					 (cAliasQry)->QKSCOUNT,;
					 (cAliasQry)->QKTCOUNT,;
					 (cAliasQry)->QKUCOUNT,;
					 (cAliasQry)->QKVCOUNT,;
					 (cAliasQry)->QKWCOUNT,;
					 (cAliasQry)->QKXCOUNT,;
					 (cAliasQry)->QKYCOUNT,;
					 (cAliasQry)->QL0COUNT,;
					 (cAliasQry)->QL1COUNT})
		(cAliasQry)->(DbSkip())
	EndDo
	aRet := QPPPAComp(aDados)
Else
	aAdd(aRet,{"","",""})
EndIf

(cAliasQry)->(DbCloseArea())

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FSelPPAP  ³ Autor ³ Rafael S. Bernardi    ³ Data ³21/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar os parametros do painel                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSelPPAP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPP010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FSelPPAP()

Local oDlg
Local oListbox
Local oOk    := LoaDbitmap( GetResources(), "LBOK" )
Local oNo    := LoaDbitmap( GetResources(), "LBNO" )
Local cTitulo:= STR0005       // "Documento"
Local cMvpar := &(ReadVar()) // Carrega Nome da Variavel do Get em Questao
Local cMvret := ReadVar()    // Iguala Nome da Variavel ao Nome variavel de Retorno
Local nOpcao := 0
Local aNiv	 := {}
Local cAlias := Alias()
Local nFor

AADD(aNiv,{If("TO "$cMvpar,.T.,.F.),STR0006,"TO "}) //"Todos"
AADD(aNiv,{If("1 "$cMvpar,.T.,.F.),STR0007,"1 "})//"Cronograma?"
AADD(aNiv,{If("2 "$cMvpar,.T.,.F.),STR0008,"2 "})//"Viabiliadade"
AADD(aNiv,{If("3 "$cMvpar,.T.,.F.),STR0009,"3 "})//"Estudo de RR?"
AADD(aNiv,{If("4 "$cMvpar,.T.,.F.),STR0010,"4 "})//"Capabilidade?"
AADD(aNiv,{If("5 "$cMvpar,.T.,.F.),STR0011,"5 "})//"Ensaio dimensional?"
AADD(aNiv,{If("6 "$cMvpar,.T.,.F.),STR0012,"6 "})//"Ensaio Material?"
AADD(aNiv,{If("7 "$cMvpar,.T.,.F.),STR0013,"7 "})//"Ensaio desempenho?"
AADD(aNiv,{If("8 "$cMvpar,.T.,.F.),STR0014,"8 "})//"Aprov. por Aparencia?"
AADD(aNiv,{If("9 "$cMvpar,.T.,.F.),STR0015,"9 "})//"Cert. de submissao?"
AADD(aNiv,{If("10 "$cMvpar,.T.,.F.),STR0016,"10 "})//"Plano de controle?"
AADD(aNiv,{If("11 "$cMvpar,.T.,.F.),STR0017,"11 "})//"FMEA de projeto?"
AADD(aNiv,{If("12 "$cMvpar,.T.,.F.),STR0018,"12 "})//"FMEA de processo?"
AADD(aNiv,{If("13 "$cMvpar,.T.,.F.),STR0019,"13 "})//"Sumario e APQP?"
AADD(aNiv,{If("14 "$cMvpar,.T.,.F.),STR0020,"14 "})//"Diagrama de Fluxo?"
AADD(aNiv,{If("15 "$cMvpar,.T.,.F.),STR0021,"15 "})//"Aprovacao interina?"
AADD(aNiv,{If("16 "$cMvpar,.T.,.F.),STR0022,"16 "})//"Check List APQP - A1?"
AADD(aNiv,{If("17 "$cMvpar,.T.,.F.),STR0026,"17 "})//"Check List APQP - A2?"
AADD(aNiv,{If("18 "$cMvpar,.T.,.F.),STR0027,"18 "})//"Check List APQP - A3?"
AADD(aNiv,{If("19 "$cMvpar,.T.,.F.),STR0028,"19 "})//"Check List APQP - A4?"
AADD(aNiv,{If("20 "$cMvpar,.T.,.F.),STR0029,"20 "})//"Check List APQP - A5?"
AADD(aNiv,{If("21 "$cMvpar,.T.,.F.),STR0030,"21 "})//"Check List APQP - A6?"
AADD(aNiv,{If("22 "$cMvpar,.T.,.F.),STR0031,"22 "})//"Check List APQP - A7?"
AADD(aNiv,{If("23 "$cMvpar,.T.,.F.),STR0032,"23 "})//"Check List APQP - A8?"
AADD(aNiv,{If("24 "$cMvpar,.T.,.F.),STR0023,"24 "})//"Check List Granel?"
AADD(aNiv,{If("25 "$cMvpar,.T.,.F.),STR0024,"25 "})//"PSA"
AADD(aNiv,{If("26 "$cMvpar,.T.,.F.),STR0025,"26 "})//"VDA"

nLin1 := 0.5
nCol1 := 002

DEFINE MSDIALOG oDlg FROM 005,005 TO 016,050 TITLE STR0003 //"Escolha Padr„o"

@ nLin1,nCol1 LISTBOX oListBox  NOSCROLL ;
					FIELDS HEADER " ",OemToAnsi(cTitulo) ;
					SIZE 150,057;
					ON DbLCLICK fSelecCli(@oListBox,@aNiv)

oListBox:SetArray(aNiv)
oListBox:bLine := { || {If(aNiv[oListBox:nAt,1],oOk,oNo),aNiv[oListBox:nAt,2]}}

DEFINE SBUTTON FROM 065,112   TYPE 1 ACTION (nOpcao:= 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 065,139.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	cMvpar:= ""
	For nFor := 1 TO Len(aNiv)
		cMvpar += If(aNiv[nFor,1],aNiv[nFor,3],Replicate("*",Len(aNiv[nFor,3])))
	Next nFor
EndIf

&cMvRet := cMvpar // Devolve Resultado

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSelecCli()³ Autor ³ Rafael S. Bernardi   ³ Data ³21/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Trata o clique do parametro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSelPPAP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPP010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fSelecCli(oListBox,aNiv)

Local nI:= 0

aNiv[oListBox:nat,1]:= !aNiv[oListBox:nat,1]

If oListBox:nAt == 1	 // Todos
	For nI:= 2 To Len(aNiv)
		aNiv[nI,1] := aNiv[1,1]
	Next nI
Else
	If !aNiv[oListBox:nat,1]
		aNiv[1,1]:= .F.
	EndIf
EndIf

oListBox:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPPPAComp  ³ Autor ³ Rafael S. Bernardi   ³ Data ³10/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Trata os dados da query e retorna um array com os dados que ³±±
±±³          ³serão exibidos no painel de gestao PPAPs completos / incom  ³±±
±±³          ³pletos													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPPAComp(aExp01)	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 = Array com os resultados da busca para cada documen³±±
±±³          ³          to dos PPAPs de cada peca                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPP010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPPAComp(aDados)
Local aRetorno := {}
Local lFlag    := .T.
Local nX
Local nY

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aDados:          						  				  ³
³ aDados[1]  - Peca                          				  				  ³	
³ aDados[2]  - Rev		          							  				  ³
³ aDados[3]  - QKGCOUNT - Cronograma 			   - 1 = existe / 0 nao existe³
³ aDados[4]  - QKFCOUNT - Viabilidade 			   - 1 = existe / 0 nao existe³
³ aDados[5]  - QM4COUNT - Rep/Repro 			   - 1 = existe / 0 nao existe³
³ aDados[6]  - QK9COUNT - Capabilidade 			   - 1 = existe / 0 nao existe³
³ aDados[7]  - QKBCOUNT - Ens. Dimensional 		   - 1 = existe / 0 nao existe³
³ aDados[8]  - QKDCOUNT - Ens. Material 		   - 1 = existe / 0 nao existe³
³ aDados[9]  - QKCCOUNT - Ens. Desempenho 		   - 1 = existe / 0 nao existe³
³ aDados[10] - QK3COUNT - Aprov. Aparencia 		   - 1 = existe / 0 nao existe³
³ aDados[11] - QKICOUNT - Cert. Submissao 		   - 1 = existe / 0 nao existe³
³ aDados[12] - QKLCOUNT - Plano de Controle 	   - 1 = existe / 0 nao existe³
³ aDados[13] - QK5COUNT - FMEA de Projeto		   - 1 = existe / 0 nao existe³
³ aDados[14] - QK7COUNT - FMEA de Processo		   - 1 = existe / 0 nao existe³
³ aDados[15] - QKJCOUNT - Sumario & APQP 		   - 1 = existe / 0 nao existe³
³ aDados[16] - QKNCOUNT - Fluxo de Processo 	   - 1 = existe / 0 nao existe³
³ aDados[17] - QKHCOUNT - Aprovacao Interina	   - 1 = existe / 0 nao existe³
³ aDados[18] - QKQCOUNT - A1					   - 1 = existe / 0 nao existe³
³ aDados[19] - QKRCOUNT - A2 					   - 1 = existe / 0 nao existe³
³ aDados[20] - QKSCOUNT - A3 					   - 1 = existe / 0 nao existe³
³ aDados[21] - QKTCOUNT - A4 					   - 1 = existe / 0 nao existe³
³ aDados[22] - QKUCOUNT - A5 					   - 1 = existe / 0 nao existe³
³ aDados[23] - QKVCOUNT - A6 					   - 1 = existe / 0 nao existe³
³ aDados[24] - QKWCOUNT - A7 					   - 1 = existe / 0 nao existe³
³ aDados[25] - QKXCOUNT - A8                       - 1 = existe / 0 nao existe³
³ aDados[26] - QKYCOUNT - Check List Mat. a Granel - 1 = existe / 0 nao existe³
³ aDados[27] - QL0COUNT - Amostras Iniciais        - 1 = existe / 0 nao existe³
³ aDados[28] - QL1COUNT - VDA Folha de Capa        - 1 = existe / 0 nao existe³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

For nx := 1 To Len(aDados)
	For nY := 3 To Len(aDados[nX])
		If (StrZero(nY-2,IIF(nY-2 < 10,1,2)) $ mv_par01) .And. lFlag .And. aDados[nX][nY] == 0
			lFlag := .F.
		EndIf
	Next nY	
	aAdd(aRetorno,{aDados[nx][1],;         //Peca
			   aDados[nx][2],;             //Revisao
			   IIf(lFlag,STR0001,STR0002)})//"Completo"###"Incompleto"
	lFlag := .T.
Next nX

Return aRetorno
