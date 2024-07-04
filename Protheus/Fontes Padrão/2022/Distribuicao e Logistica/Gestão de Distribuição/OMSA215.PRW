#INCLUDE "OMSA215.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE OMSA21501 "OMSA21501"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OMSA215  ³ Rev.  ³ Henry Fila            ³ Data ³ 19.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Geracao de carga                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void OMSA215(void)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OMSA215()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa vari veis utilizadas na cria‡Æo de Arquivos de Trabalho     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
Local aCores    := {}
Local aIndDAK   := {}
Local cCondicao := ""

Private bFiltraBrw := {|| Nil}
Private cCadastro  := OemtoAnsi(STR0001) //"Montagem de carga para terceiros"

Private aRotina := MenuDef()

If (AMIIn(5,39)) // SigaFat - SigaOms
	Aadd(aCores,{"DAK_FEZNF == '2' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","ENABLE"})		//Totalmente em aberto
	Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_LARANJA"})	//Somente faturada e nao acertada
	Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '1'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","DISABLE"})		//Faturada e acertada
	Aadd(aCores,{"                                              DAK_BLQCAR == '1'                         .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_PRETO"})	//Bloqueada

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui Filial de / ate nos parametros OM341B                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//-- mv_par01 - Carga de ?
	//-- mv_par02 - Carga ate ?
	//-- mv_par03 - Data geracao de ?
	//-- mv_par04 - Data geracao ate ?
	//-- mv_par05 - Filtra por ? Em aberto / Faturadas / Encerradas / Todas
	If Pergunte("OMS20A",.T.)

		cCondicao += "DAK_COD >= '"+mv_par01+"' .And. DAK_COD <= '"+mv_par02+"' .And. "
		cCondicao += "Dtos(DAK_DATA) >= '"+Dtos(mv_par03)+"' .And. Dtos(DAK_DATA) <= '"+Dtos(mv_par04)+"' "
		If mv_par05 == 1
			cCondicao += " .And. DAK_FEZNF=='2' .And. DAK_ACECAR == '2'"
		ElseIf mv_par05 == 2
			cCondicao += " .And. DAK_FEZNF =='1' .And. DAK_ACECAR == '2'"
		ElseIf mv_par05 == 3
			cCondicao += " .And. DAK_FEZNF =='1' .And. DAK_ACECAR == '1' "
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a Filtragem                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bFiltraBrw := {|| FilBrowse("DAK",@aIndDAK,@cCondicao) }
		Eval(bFiltraBrw)

		Mbrowse(6,1,22,75,"DAK",,,,,,aCores)

	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a integridade da rotina                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()
	aEval(aIndDAK,{|x| Ferase(x[1]+OrdBagExt())})
	RestArea(aArea)
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os215Load ³ Rev.  ³ Henry Fila            ³ Data ³ 19.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Geracao de carga                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void Os215Load(void)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Os215Load()
Local aSays    := {}
Local aButtons := {}
Local nOpca    := 0
Local oProcess

	Aadd(aSays,OemToAnsi( STR0004 ) ) //"Esta rotina ira gerar as cargas para terceiros dos pedidos que utilizam transportadora"		 
	Aadd(aSays,OemToAnsi( STR0005 ) ) //"e enderecamentos informados."

	Aadd(aButtons, { 5,.T.,{|o| Pergunte("OMS215",.T.) } } )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	Aadd(aButtons, { 1,.T.,{|o| nOpca := 1,o:oWnd:End() } } )
	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1
		oProcess := MsNewProcess():New({|lEnd| Oms215Proc(oProcess)},"","",.F.)
		oProcess:Activate()
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os215Proc ³ Rev.  ³ Henry Fila            ³ Data ³ 19.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Geracao de carga                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void Os215Proc(void)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Oms215Proc(oProcess)
Local aGera      := {}
Local cQuery     := ""
Local cCondicao  := ""
Local cAliasSC9  := "SC9"
Local cTransp    := ""
Local cEstFis    := ""
Local cLocal     := ""
Local cEndPad    := ""
Local cRetPE     := ""
Local nTipoOper  := OsVlEntCom()
Local nSequencia := 0
Local lGeraCar   := .T. 
Local lOM215PCA  := ExistBlock("OM215PCA")

	//-- mv_par01 - Pedido de  ?
	//-- mv_par02 - Pedido ate ?
	//-- mv_par03 - Cliente de  ?
	//-- mv_par04 - Cliente ate ?
	//-- mv_par05 - Considera Restricao ? sim/nao
	//-- mv_par06 - Aglutina por ? pedido/itens
	//-- mv_par07 - End. Destino de ?
	//-- mv_par08 - End. Destino ate ?
	//-- mv_par09 - Filial de ?
	//-- mv_par10 - Filial ate ?
	//-- mv_par11 - Data Liberacao de ?
	//-- mv_par12 - Data Liberacao ate ?
	//-- mv_par13 - Loja de ?
	//-- mv_par14 - Loja ate ?
	//-- mv_par15 - Data Entrega de ?
	//-- mv_par16 - Data Entrega ate ?
	//-- mv_par17 - Transportadora de ?
	//-- mv_par18 - Transportadora ate ?
	Pergunte("OMS215",.F.)

	cAliasSC9 := "TRBSC9"

	cQuery := "SELECT A4_COD,A4_ENDPAD,A4_ESTFIS,A4_LOCAL,C9_CLIENTE,C9_FILIAL,C9_LOJA,C9_PEDIDO,C9_ITEM,SC9.R_E_C_N_O_ RECSC9 FROM "
	cQuery += RetSqlName("SC9")+" SC9, "
	cQuery += RetSqlName("SC5")+" SC5, "
	cQuery += RetSqlName('SC6')+" SC6, "
	cQuery += RetSqlName("SA4")+" SA4 "
	cQuery += " WHERE SC9.D_E_L_E_T_ = ' '"
	cQuery += " AND C9_BLCRED  ='"+Space(Len(SC9->C9_BLCRED))+"' "
	cQuery += " AND C9_BLEST   ='"+Space(Len(SC9->C9_BLEST)) +"' "
	cQuery += " AND C9_CARGA   ='"+Space(Len(SC9->C9_CARGA)) +"' "
	cQuery += " AND C9_SEQCAR  ='"+Space(Len(SC9->C9_SEQCAR))+"' "
	cQuery += " AND (C9_TPCARGA='1' OR C9_TPCARGA='3')"
	cQuery += " AND C9_PEDIDO  >= '"+mv_par01+"' AND C9_PEDIDO  <='"+mv_par02+"' "
	cQuery += " AND C9_CLIENTE >= '"+mv_par03+"' AND C9_CLIENTE <='"+mv_par04+"' "
	cQuery += " AND C9_LOJA    >= '"+mv_par13+"' AND C9_LOJA    <='"+mv_par14+"' "
	cQuery += " AND C9_ENDPAD  >= '"+mv_par07+"' AND C9_ENDPAD  <='"+mv_par08+"' "
	cQuery += " AND C9_DATALIB >= '"+Dtos(mv_par11)+"'"
	cQuery += " AND C9_DATALIB <= '"+Dtos(mv_par12)+"'"

	If nTipoOper == 1
		cQuery += "AND C9_FILIAL ='"+xFilial("SC9")+"' "
	Else
		cQuery += "AND C9_FILIAL >= '"+mv_par09+"' "
		cQuery += "AND C9_FILIAL <= '"+mv_par10+"' "
	EndIf

	cQuery += " AND SC5.C5_FILIAL = SC9.C9_FILIAL "
	cQuery += " AND SC5.C5_NUM    = SC9.C9_PEDIDO "
	cQuery += " AND SC5.C5_TRANSP <> '"+Space(Len(SC5->C5_TRANSP))+"' "
	cQuery += " AND SC5.C5_TRANSP >= '" + mv_par17 + "' "
	cQuery += " AND SC5.C5_TRANSP <= '" + mv_par18 + "' "
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' "

	cQuery += " AND SC6.C6_FILIAL = SC9.C9_FILIAL "
	cQuery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "
	cQuery += " AND SC6.C6_ITEM   = SC9.C9_ITEM "
	cQuery += " AND SC6.C6_PRODUTO = SC9.C9_PRODUTO "
	cQuery += " AND SC6.C6_ENTREG>='"+Dtos(mv_par15)+"'"
	cQuery += " AND SC6.C6_ENTREG<='"+Dtos(mv_par16)+"'"
	cQuery += " AND SC6.D_E_L_E_T_ = ' ' "

	cQuery += " AND SA4.A4_FILIAL = '"+xFilial("SA4")+"' "
	cQuery += " AND SA4.A4_COD    = SC5.C5_TRANSP "
	cQuery += " AND SA4.A4_ENDPAD <> '"+Space(Len(SA4->A4_ENDPAD))+"' "
	cQuery += " AND SA4.A4_ESTFIS <> '"+Space(Len(SA4->A4_ESTFIS))+"' "
	cQuery += " AND SA4.A4_LOCAL  <> '"+Space(Len(SA4->A4_LOCAL)) +"' "
	cQuery += " AND SA4.D_E_L_E_T_ = ' ' "

	If ExistBlock("OM215QRY")
		cRetPE := ExecBlock("OM215QRY",.F.,.F.,{ cQuery , 1 })
		cQuery   := If(ValType(cRetPE)=="C", cRetPE, cQuery)
	EndIf

	cQuery += " ORDER BY C5_TRANSP,A4_ESTFIS,A4_ENDPAD,A4_LOCAL,C9_CLIENTE,C9_LOJA,C9_PEDIDO,C9_ITEM"

	cQuery := ChangeQuery(cQuery)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSC9",.F.,.T.)

	If !(cAliasSC9)->(Eof())
		While !(cAliasSC9)->(Eof())

			cTransp := (cAliasSC9)->A4_COD
			cEstFis := (cAliasSC9)->A4_ESTFIS
			cLocal  := (cAliasSC9)->A4_LOCAL
			cEndPad := (cAliasSC9)->A4_ENDPAD

			nSequencia := 0

			While (cAliasSC9)->(!Eof()) .And. cTransp ==  (cAliasSC9)->A4_COD .And.;
												cEstFis == (cAliasSC9)->A4_ESTFIS .And.;
												cLocal  == (cAliasSC9)->A4_LOCAL .And. ;
												cEndPad == (cAliasSC9)->A4_ENDPAD
				nSequencia++

				Aadd(aGera, {StrZero(nSequencia,6),;
							"",;
							"",;
							"",;
							(cAliasSC9)->C9_PEDIDO,;
							(cAliasSC9)->C9_ITEM,;
							(cAliasSC9)->C9_CLIENTE,;
							(cAliasSC9)->C9_LOJA,;
							(cAliasSC9)->RECSC9,;
							(cAliasSC9)->A4_ENDPAD,;
							(cAliasSC9)->C9_FILIAL,;
							OsFilial("SA1",(cAliasSC9)->C9_FILIAL),;
							"",;
							"",;
							dDataBase,;
							dDataBase,Nil,Nil} )

				(cAliasSC9)->(dbSkip())

			EndDo

			If lOM215PCA
				lGeraCar := ExecBlock("OM215PCA",.F.,.F.,{aGera})
			EndIf

			If lGeraCar
				Processa({ || Oms200Carga(@aGera,,, "",,,,,,,,,,,,,cTransp,,,,,,.T.) })
				ConfirmSX8()
			EndIf 
			aGera:= {}
		EndDo
	Else
		WmsHelp(STR0007,STR0008,OMSA21501) // "Não foi possível encontrar pedidos para a montagem da carga." // "Verifique os parâmetros configurados e se foi informada uma transportadora (com as características necessárias) para os pedidos que utilizam carga."
	EndIf

	(cAliasSC9)->(dbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := {	{ OemtoAnsi(STR0002) ,'PesqBrw'   , 0, 1 ,0,.F.},;	//"Pesquisar"
						{ OemtoAnsi(STR0006) ,'OmsVisCg'  , 0, 2 ,0,NIL},;	//"Gerar"
						{ OemtoAnsi(STR0003) ,'Os215Load' , 0, 3 ,0,NIL} }	//"Gerar"

If ExistBlock("OM215MNU")
	ExecBlock("OM215MNU",.F.,.F.)
EndIf

Return(aRotina)
