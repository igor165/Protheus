#INCLUDE "TMKA272A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cEmailPad := ""
Static _lIndAD1     := Nil	

#DEFINE CLR_ORANGE	RGB(255,119,000)  // Laranja
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271HTmk ³ Autor ³ Vendas Clientes       ³ Data ³ 29/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Hist¢rico das liga‡oes da Entidade ou do Contato na rotina  ³±±
±±³          ³de Telemarketing                                            ³±±
±±³          ³                                                            ³±±
±±³          ³Observacao: Quando o contato nao tiver historico junto com a³±±
±±³          ³entidade selecionada o sistema sempre vai exibir o historico³±±
±±³          ³pelo contato.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³Somente Telemarketing							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Operacao autal (inclusao, alteracao, etc)           ³±±
±±³          ³ExpL2 - Controla a habilitacao do atendimento para alteracao³±±
±±³          ³ExpO3 - Objeto do folder                                    ³±±
±±³          ³ExpO4 - Objeto da Enchoice                                  ³±±
±±³          ³ExpC5 - Motivo do encerramento                              ³±±
±±³          ³ExpC6 - Descricao do encerramento                           ³±±
±±³          ³ExpN7 - Controle da apresentacao do historico               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk272HTmk(	nOpc	,lHabilita	,oFolderTmk	,oEnchTmk,;
		cMotivo	,cEncerra	,nTipo		,cLock	)
	
	Local aArea		:= GetArea()									// Salva a area atual
	Local aColAnt	:= {}											// Salva o ACOLS atual
	Local aHeadAnt	:= {}											// Salva o AHEADER atual
	Local nAnt 		:= 0											// Salva o "n" atual
	Local cCodLig	:= ""											// Codigo do atendimento
	Local oDlgHist													// Tela do Historico
	Local oObsMemo                                      			// Observacao do MEMO
	Local cObsMemo 	:=""											// String com a descricao do MEMO
	Local oMonoAs  	:= TFont():New( "Courier New",6,0) 			// Fonte para o campo Memo
	Local oEnceMemo													// Observacao do ENCERRAMENTO - MEMO
	Local cEnceMemo	:= ""											// String com a descricao do ENCERRAMENTO
	Local oLbx														// Listbox com o cabecalho do atendimento
	Local oGetHist													// Itens de cada atendimento
	Local oBtn01													// Botao Follow-up da FNC
	Local aFirst:= {}												// Temporário com o acols que eh Private para depois restaurar o original
	Local oCancMemo													// Observacao do CANCELAMENTO - MEMO
	Local cCancMemo	:= ""											// String com a descricao do CANCELAMENTO
	Local nOpcA		:= 0                                            // Opcao de OK ou CANCELA
	Local aLigacoes := {}											// Array com os atendimentos anteriores
	Local lRet 		:= .F.                                          // Retorno da funcao
	Local cCliente  := ""											// Código do cliente que também será procurado em conjunto com o suspect ou prospect
	Local cLojaCli	:= ""											// Loja do cliente que também será procurado em conjunto com o suspect ou prospect
	Local cProspect := ""											// Código do prospect que também será procurado em conjunto com o cliente ou suspect
	Local cLojaPro	:= ""											// Loja do prospect que também será procurado em conjunto com o cliente ou suspect
	Local cSuspect	:= ""											// Código do suspect que também será procurado em conjunto com o cliente ou prospect
	Local cLojaSus	:= "" 											// Loja do suspect que também será procurado em conjunto com o cliente ou prospect
	
	Local oDlg														// Objeto da tela
	Local aOpcoes	:= {STR0001,STR0002}							// "Historico por Contato","Historico por Entidade"
	Local nArquivo  := 1											// Consulta por 1 - Contato ou por 2 - Cliente
	Local oArquivo													// Objeto radio para escolha do tipo de historico
	
	Local oBmp1 													// Bitmaps das legendas do historico
	Local oBmp2 													// Bitmaps das legendas do historico
	Local oBmp3 													// Bitmaps das legendas do historico
	Local oBmp4 													// Bitmaps das legendas do historico
	
	Local lAtendimento 	:= .T.										// Identifica se o historico foi chamado da tela de Atendimento.
	Local cPerg			:= "TMKH01"                                	// Pergunte exibida para filtrar os atendimentos exibidos no historico
	
	Local cFilSUS			:= xFilial("SUS")
	Local cFilACH			:= xFilial("ACH")
	Local cFilSUC			:= xFilial("SUC")
	Local cFilSU5			:= xFilial("SU5")
	Local cFilSU7			:= xFilial("SU7")
	Local cFilSUL			:= xFilial("SUL")
	Local cFilSUO			:= xFilial("SUO")
	Local cFilSUH			:= xFilial("SUH")
	Local aPDFields			:= {"U5_CONTAT","A1_NOME","U7_NOME"}
	Local aPDCols			:= {}
	Static lProspect  	:= .F. //Ao alterar de suspect para prospect, vira True. Para envio do Email
	Static lClienteM  	:= .F. //Caso seja gerada uma atividade do tipo email para um cliente
	
	Default nTipo := 0												// Permite a pesquisa do histórico por entidade e contato
	Default cLock := ""

	FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o prospect e/ou suspect se a entidade for cliente,      ³
	//³para posteriormente incluir as entidades passadas do cliente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(M->UC_ENTIDAD) == "SA1"
		DbSelectArea("SUS")
		DbSetOrder(5)
		If DbSeek( cFilSUS + M->UC_CHAVE )
			cProspect := SUS->US_COD
			cLojaPro	 := SUS->US_LOJA
		EndIf
		
		If !Empty(Alltrim(cProspect))
			DbSelectArea("ACH")
			DbSetOrder(4)
			If DbSeek( cFilACH + cProspect + cLojaPro )
				cSuspect := ACH->ACH_CODIGO
				cLojaSus := ACH->ACH_LOJA
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega o suspect e cliente se a entidade for prospect,   ³
		//³para posteriormente incluir as entidades relacionadas. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf Alltrim(M->UC_ENTIDAD) == "SUS"
		DbSelectArea("SUS")
		DbSetOrder(1)
		If DbSeek( cFilSUS + M->UC_CHAVE )
			cCliente := SUS->US_CODCLI
			cLojaCli := SUS->US_LOJACLI
		EndIf
		
		DbSelectArea("ACH")
		DbSetOrder(4)
		If DbSeek( cFilACH + M->UC_CHAVE )
			cSuspect := ACH->ACH_CODIGO
			cLojaSus := ACH->ACH_LOJA
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega o prospect e cliente se a entidade for suspect,   ³
		//³para posteriormente incluir as entidades relacionadas. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Elseif Alltrim(M->UC_ENTIDAD) == "ACH"
		DbSelectArea("ACH")
		DbSetOrder(1)
		If DbSeek( cFilACH + M->UC_CHAVE )
			cProspect := ACH->ACH_CODPRO
			cLojaPro  := ACH->ACH_LOJPRO
		Endif
		
		If !Empty(Alltrim(cProspect))
			DbSelectArea("SUS")
			DbSetOrder(1)
			If DbSeek( cFilSUS + cProspect + cLojaPro )
				cCliente := SUS->US_CODCLI
				cLojaCli := SUS->US_LOJACLI
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem atendimentos para a entidade ou uma de³
	//³suas entidades correlatas.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUC")
	DbSetOrder(2)
	SUC->(DbSeek(cFilSUC + M->UC_ENTIDAD + M->UC_CHAVE))
	If !(SUC->(Found())) .And. (M->UC_ENTIDAD == "SA1" .Or. M->UC_ENTIDAD == "SUS" .Or. M->UC_ENTIDAD == "ACH")
		If M->UC_ENTIDAD == "SA1"
			SUC->(DbSeek(cFilSUC + "ACH" + cSuspect + cLojaSus ))
			If !(SUC->(Found()))
				SUC->(DbSeek(cFilSUC + "SUS" + cProspect + cLojaPro ))
			EndIf
		ElseIf M->UC_ENTIDAD == "SUS"
			SUC->(DbSeek(cFilSUC + "SA1" + cCliente + cLojaCli ))
			If !(SUC->(Found()))
				SUC->(DbSeek(cFilSUC + "ACH" + cSuspect + cLojaSus ))
			EndIf
		ElseIf M->UC_ENTIDAD == "ACH"
			SUC->(DbSeek(cFilSUC + "SA1" + cCliente + cLojaCli ))
			If !(SUC->(Found()))
				SUC->(DbSeek(cFilSUC + "SUS" + cProspect + cLojaPro ))
			EndIf
		EndIf
	EndIf
	
	If !(SUC->(Found()))
		DbSetOrder(6)
		If DbSeek(cFilSUC + M->UC_CODCONT)
			Aviso(STR0032, STR0044 ,{"OK"})     //"Atenção"    /"Será exibido apenas o histórico do Contato"
			nTipo := 1
		Else
			Help(" ",1,"SEMDADOS" )
			Return(lRet)
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Permite carregar o atendimento selecionado via Historico se³
	//³nao foi executado via "Agenda do Operador" (TMKA380).      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Upper(FUNNAME()) <> "TMKA380"
		lAtendimento := .T.
	Else
		lAtendimento := .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salvo o acols que eh Private para depois restaurar o original.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColAnt	:= Aclone(aCols)			// Salva o ACOLS atual
	aHeadAnt:= Aclone(aHeader)			// Salva o AHEADER atual
	nAnt 	:= n						// Salva o "n" atual
	
	Aadd(aFirst,{Len(aHeader)+1})
	aCols := aClone(aFirst)
	n	  := Len(aCols)
	
	CursorWait()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o historico pode ser exibido para contato e entidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo <> 1
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abre uma tela para opcao do historico 1 - Contato 2 - Cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra dados do Produto.								     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg FROM  00,00 TO 100,260 TITLE STR0003 PIXEL OF oMainWnd //"Tipo de Consulta"
		@ 06,04 RADIO oArquivo VAR nArquivo PROMPT aOpcoes[1],aOpcoes[2] OF oDlg SIZE 80,20 DESIGN 3D PIXEL
		DEFINE SBUTTON FROM 05,95 TYPE 1 ENABLE OF oDlg ACTION (nOpca:= 1, oDlg:End())	//OK - Executa com a opcao selecionada
		DEFINE SBUTTON FROM 25,95 TYPE 2 ENABLE OF oDlg ACTION (nOpca:= 0, oDlg:End())	//Cancela nao executa a consulta
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Else
		nArquivo := nTipo
		nOpcA 	 := 1
	Endif
	
	If nOpca == 0
		CursorArrow()
		aCols 	:= aClone(aColAnt)
		aHeader := aClone(aHeadAnt)
		n 	 	:= nAnt
		RestArea(aArea)
		Return(lRet)
	Endif
	nOpca := 0
	
	If !Pergunte(cPerg,.T.)
		CursorArrow()
		aCols 	:= aClone(aColAnt)
		aHeader := aClone(aHeadAnt)
		n 	  	:= nAnt
		RestArea(aArea)
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pergunte - TMKH01                                                             ³
	//³MV_PAR01 - Da Emissao                                                         ³
	//³MV_PAR02 - Ate a Emissão                                                      ³
	//³MV_PAR03 - Do Operador                                                        ³
	//³MV_PAR04 - Ate o Operador                                                     ³
	//³MV_PAR05 - Status do Atendimento: (1-Todas 2-Planejada 3-Pendente 4-Encerrada)³
	//³MV_PAR06 - Ligacao: (1-Ambos 2-Receptivo 3-Ativo)                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nArquivo == 1 // Historico por Contato"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A ordem do historico por entidade nao tem ordem crescente nem decrescente - a ordem e de gravacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SUC")
		DbSetOrder(6)	// FILIAL+CONTATO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona todas a liga‡oes desse cliente indexando por ordem de liga‡ao decrescente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			If ( TcSrvType()<>"AS/400" )
				cQuery := "SELECT * "
				cQuery += "FROM " + RetSqlName("SUC") + " SUC "
				cQuery += "WHERE "
				cQuery += 		"SUC.UC_FILIAL	='" + cFilSUC + "' AND "
				cQuery += 		"SUC.UC_ENTIDAD	='"	+ M->UC_ENTIDAD  + "' AND "
				cQuery += 		"SUC.UC_CODCONT	='" + M->UC_CODCONT  + "' AND "
				cQuery += 		"SUC.UC_DATA BETWEEN 	'" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' AND "
				cQuery += 		"SUC.UC_OPERADO BETWEEN '" + MV_PAR03 + "' AND  '" + MV_PAR04 + "' AND "
				
				If MV_PAR05 <> 1 //Todas
					cQuery += 	"SUC.UC_STATUS = '" + STR(MV_PAR05-1,1) + "' AND "
				Endif
				
				If MV_PAR06 <> 1 //Ambos
					cQuery += 	"SUC.UC_OPERACA = '" + IIF(MV_PAR06==2,"1","2") + "' AND "
				Endif
				
				cQuery += 		"SUC.D_E_L_E_T_ = ' '"
				cQuery += " ORDER BY "+SqlOrder(SUC->(IndexKey())) + ",UC_DIASDAT,UC_HORADAT"
				
				cQuery := ChangeQuery(cQuery)
				
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMK',.T.,.T.)
				DbSelectArea("TMK")
				DbGoTop()
				While (!TMK->(Eof()))
					AAdd(aLigacoes, {Tk272Pendente(TMK->UC_STATUS,TMK->UC_CODCANC,TMK->UC_CODIGO),;                                            //  01- Semaforo - vermelho
					                 TMK->UC_CODIGO,;                                                                                          //  02- Codigo
					                 Posicione("SU5",1,cFilSU5+TMK->UC_CODCONT,"U5_CONTAT"),;                                                  //  03- Contato
					                 Posicione("SX2",1,ALLTRIM(TMK->UC_ENTIDAD),"X2NOME()")+":"+TkEntidade(TMK->UC_ENTIDAD,TMK->UC_CHAVE,1),;  //  04- Entidade
					                 DTOC(StoD(TMK->UC_DATA)),;                                                                                //  05- Data
					                 TMK->UC_INICIO,;                                                                                          //  06- Hora
					                 Posicione("SU7",1,cFilSU7+TMK->UC_OPERADO,"U7_NOME"),;                                                    //  07- Operador
					                 TkOperacao(TMK->UC_OPERACA),;                                                                             //  08- Operacao
					                 Tk272Ligacao(TMK->UC_STATUS,"TMK"),;                                                                      //  09- Status
					                 Posicione("SUL",1,cFilSUL+TMK->UC_TIPO,"UL_DESC"),;                                                       //  10- Comunicacao
					                 Posicione("SUO",1,cFilSUO+TMK->UC_CODCAMP,"UO_DESC"),;                                                    //  11- Campanha
					                 Posicione("SUH",1,cFilSUH+TMK->UC_MIDIA,"UH_DESC"),;                                                      //  12- Midia
					                 DTOC(StoD(TMK->UC_PENDENT)),;                                                                             //  13- Retorno
					                 TMK->UC_HRPEND,;                                                                                          //  14- Hora
					                 TMK->UC_CODOBS,;                                                                                          //  15- Codigo da Observacao
					                 TMK->UC_CODMOT,;                                                                                          //  16- Codigo do Encerramento
					                 TMK->UC_CODCANC})                                                                                         //  17- Codigo do Cancelamento
					TMK->(DbSkip())
				EndDo
				DbSelectArea("TMK")
				DbCloseArea()
				DbSelectArea("SUC")
				If Len(aLigacoes) <= 0
					Help(" ",1,"SEMDADOS" )
					CursorArrow()
					aCols 	:= aClone(aColAnt)
					aHeader := aClone(aHeadAnt)
					n 	  	:= nAnt
					RestArea(aArea)
					Return(lRet)
				Endif

			Else
				DbSelectArea("SUC")
				DbSetOrder(6)	//FILIAL+CONTATO
				DbSeek(cFilSUC+M->UC_CODCONT)
				cCodLig := SUC->UC_CODIGO
				While (!SUC->(Eof())) .AND. (cFilSUC == SUC->UC_FILIAL)  .AND. (SUC->UC_CODCONT == M->UC_CODCONT)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica o intervalo de datas do atendimento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SUC->UC_DATA < MV_PAR01 .OR. SUC->UC_DATA > MV_PAR02
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif

					If SUC->UC_OPERADO < MV_PAR03 .OR. SUC->UC_OPERADO > MV_PAR04
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif

					If MV_PAR05 <> 1 //Todas
						If SUC->UC_STATUS <> STR(MV_PAR05-1,1)
							DbSelectArea("SUC")
							SUC->(Dbskip())
							Loop
						Endif
					Endif

					If MV_PAR06 <> 1 //Ambas
						If MV_PAR06 == 2 .AND. SUC->UC_OPERACA <> "1" //Receptivo
							DbSelectArea("SUC")
							SUC->(Dbskip())
							Loop
						ElseIf MV_PAR06 == 3 .AND. SUC->UC_OPERACA <> "2"//Ativo
							DbSelectArea("SUC")
							SUC->(Dbskip())
							Loop
						Endif
					Endif

					aAdd(aLigacoes, {Tk272Pendente(SUC->UC_STATUS,SUC->UC_CODCANC,SUC->UC_CODIGO),;                                            //  01- Semaforo - vermelho
					                 SUC->UC_CODIGO,;                                                                                          //  02- Codigo
					                 Posicione("SU5",1,cFilSU5+SUC->UC_CODCONT,"U5_CONTAT"),;                                                  //  03- Contato
					                 Posicione("SX2",1,ALLTRIM(SUC->UC_ENTIDAD),"X2NOME()")+":"+TkEntidade(SUC->UC_ENTIDAD,SUC->UC_CHAVE,1),;  //  04- Entidade
					                 DTOC(SUC->UC_DATA),;                                                                                      //  05- Data
					                 SUC->UC_INICIO,;                                                                                          //  06- Hora
					                 Posicione("SU7",1,cFilSU7+SUC->UC_OPERADO,"U7_NOME"),;                                                    //  07- Operador
					                 TkOperacao(SUC->UC_OPERACA),;                                                                             //  08- Operacao
					                 Tk272Ligacao(SUC->UC_STATUS),;                                                                            //  09- Status
					                 Posicione("SUL",1,cFilSUL+SUC->UC_TIPO,"UL_DESC"),;                                                       //  10- Comunicacao
					                 Posicione("SUO",1,cFilSUO+SUC->UC_CODCAMP,"UO_DESC"),;                                                    //  11- Campanha
					                 Posicione("SUH",1,cFilSUH+SUC->UC_MIDIA,"UH_DESC"),;                                                      //  12- Midia
					                 DTOC(SUC->UC_PENDENT),;                                                                                   //  13- Data de Retorno
					                 SUC->UC_HRPEND,;                                                                                          //  14- Hora
					                 SUC->UC_CODOBS,;                                                                                          //  15- Codigo da Observacao
					                 SUC->UC_CODMOT,;                                                                                          //  16- Codigo do Encerramento
					                 SUC->UC_CODCANC})                                                                                         //  17- Codigo do Cancelamento

					SUC->(DbSkip())
				EndDo
				If Len(aLigacoes) <= 0
					Help(" ",1,"SEMDADOS" )
					CursorArrow()
					aCols 	:= aClone(aColAnt)
					aHeader := aClone(aHeadAnt)
					n 	  	:= nAnt
					RestArea(aArea)
					Return(lRet)
				Endif
			Endif
			
		#ELSE
			
			DbSelectArea("SUC")
			DbSetOrder(6) // FILIAL+CONTATO
			DbSeek(cFilSUC+M->UC_CODCONT)
			cCodLig :=SUC->UC_CODIGO
			While (!SUC->(Eof())) .AND. (cFilSUC == SUC->UC_FILIAL) .AND. (SUC->UC_CODCONT == M->UC_CODCONT)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o intervalo de datas do atendimento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SUC->UC_DATA < MV_PAR01 .OR. SUC->UC_DATA > MV_PAR02
					DbSelectArea("SUC")
					SUC->(Dbskip())
					Loop
				Endif
				
				If SUC->UC_OPERADO < MV_PAR03 .OR. SUC->UC_OPERADO > MV_PAR04
					DbSelectArea("SUC")
					SUC->(Dbskip())
					Loop
				Endif
				
				If MV_PAR05 <> 1 //Todas
					If SUC->UC_STATUS <> STR(MV_PAR05-1,1)
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif
				Endif
				
				If MV_PAR06 <> 1 //Ambas
					If MV_PAR06 == 2 .AND. SUC->UC_OPERACA <> "1" //Receptivo
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					ElseIf MV_PAR06 == 3 .AND. SUC->UC_OPERACA <> "2"//Ativo
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif
				Endif
				
				aAdd(aLigacoes, {Tk272Pendente(SUC->UC_STATUS,SUC->UC_CODCANC,SUC->UC_CODIGO),;                                               //  01- Semaforo - vermelho
				                 SUC->UC_CODIGO,;                                                                                             //  02- Liga‡„o
				                 Posicione("SU5",1,cFilSU5+SUC->UC_CODCONT,"U5_CONTAT"),;                                                     //  03- Contato
				                 Posicione("SX2",1,ALLTRIM(SUC->UC_ENTIDAD),"X2NOME()")+":"+TkEntidade(SUC->UC_ENTIDAD,SUC->UC_CHAVE,1),;     //  04- Entidade
				                 DTOC(SUC->UC_DATA),;                                                                                         //  05- Data
				                 SUC->UC_INICIO,;                                                                                             //  06- Hora
				                 Posicione("SU7",1,cFilSU7+SUC->UC_OPERADO,"U7_NOME"),;                                                       //  07- Operador
				                 TkOperacao(SUC->UC_OPERACA),;                                                                                //  08- Operacao
				                 Tk272Ligacao(SUC->UC_STATUS),;                                                                               //  09- Status
				                 Posicione("SUL",1,cFilSUL+SUC->UC_TIPO,"UL_DESC"),;                                                          //  10- Comunicacao
				                 Posicione("SUO",1,cFilSUO+SUC->UC_CODCAMP,"UO_DESC"),;                                                       //  11- Campanha
				                 Posicione("SUH",1,cFilSUH+SUC->UC_MIDIA,"UH_DESC"),;                                                         //  12- Midia
				                 DTOC(SUC->UC_PENDENT),;                                                                                      //  13- Data de Retorno
				                 SUC->UC_HRPEND,;                                                                                             //  14- Hora
				                 SUC->UC_CODOBS,;                                                                                             //  15- Codigo da Observacao
				                 SUC->UC_CODMOT,;                                                                                             //  16- Codigo do Encerramento
				                 SUC->UC_CODCANC})                                                                                            //  17- Codigo do Cancelamento
				SUC->(DbSkip())
			EndDo
			
			If Len(aLigacoes) <= 0
				Help(" ",1,"SEMDADOS" )
				CursorArrow()
				aCols 	:= aClone(aColAnt)
				aHeader := aClone(aHeadAnt)
				n 	  	:= nAnt
				RestArea(aArea)
				Return(lRet)
			Endif
		#ENDIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra dados do Produto.								     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgHist FROM 50,001 TO 600,750 TITLE STR0004 + ": " + M->UC_DESCCHAV PIXEL  //"Historico"
		
		@01,02 TO 210,374 LABEL STR0005 OF oDlgHist PIXEL //"Atendimentos realizados pelo TeleMarketing"
		
		@08,05 LISTBOX oLbx FIELDS ;
			HEADER ;
			" ",;		// 01 - Legenda
		STR0006,;	// 02 - "Atendimento"
		STR0007,;	// 03 - "Contato"
		STR0008,;	// 04 - "Entidade"
		STR0009,;	// 05 - "Data"
		STR0010,;	// 06 - "Hora"
		STR0011,;	// 07 - "Operador"
		STR0012,;	// 08 - "Operacao"
		STR0013,;	// 09 - "Status"
		STR0014,;	// 10 - "Comunicacao"
		STR0015,;	// 11 - "Campanha"
		STR0016,;	// 12 - "M¡dia"
		STR0017,;	// 13 - "Retorno"
		STR0010;	// 14 - "Hora"
		SIZE 365,100 OF oDlgHist PIXEL
		
		oLbx:SetArray(aLigacoes)
		oLbx:bLine:={||{aLigacoes[oLbx:nAt,1],;
			aLigacoes[oLbx:nAt,2],;
			aLigacoes[oLbx:nAt,3],;
			aLigacoes[oLbx:nAt,4],;
			aLigacoes[oLbx:nAt,5],;
			aLigacoes[oLbx:nAt,6],;
			aLigacoes[oLbx:nAt,7],;
			aLigacoes[oLbx:nAt,8],;
			aLigacoes[oLbx:nAt,9],;
			aLigacoes[oLbx:nAt,10],;
			aLigacoes[oLbx:nAt,11],;
			aLigacoes[oLbx:nAt,12],;
			aLigacoes[oLbx:nAt,13],;
			aLigacoes[oLbx:nAt,14],;
			aLigacoes[oLbx:nAt,15]}}
		aPDCols := {"","","U5_CONTAT","A1_NOME","","","U7_NOME","","","","","","","",""}
		
		If FATPDActive() .And. FTPDUse(.T.)
			oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols) 
		EndIf
		// Carrega os items do pedido e atualiza o codigo do atendimento para ser carregado na tela no OK
		oLbx:bChange := {||	Tk272CargaTmk(.T.,		oGetHist,				aLigacoes[oLbx:nAt,2],	aLigacoes[oLbx:nAt,15],;
		                                   @cObsMemo,	oObsMemo,				aLigacoes[oLbx:nAt,16],	@cEnceMemo,;
		                                   oEnceMemo,	aLigacoes[oLbx:nAt,17],	@cCancMemo,			oCancMemo ),;
		                                   cCodLig := Eval(oLbx:bLine)[2]}
		oLbx:Refresh()
		oLbx:SetFocus(.T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o acols com os itens da ligacao selecionada		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodLig	:= aLigacoes[1][2]
		TkMontaItens("SUD",cCodLig,"M")
		
		oGetHist:= MSGetDados():New(115,5,200,370,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,99)
		
		//Observa‡„o da liga‡„o
		@ 212,02 TO 258,122 LABEL STR0018 OF oDlgHist PIXEL  //"Observa‡„o da liga‡„o"
		@ 220,05 GET oObsMemo VAR cObsMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
		oObsMemo:oFont := oMonoAs
		oObsMemo:bRClicked := {|| AllwaysTrue() }
		
		//Motivo do Encerramento - Se a liga‡„o for encerrada
		@ 212,125 TO 258,245 LABEL STR0019 OF oDlgHist PIXEL  // "Motivo do Encerramento"
		@ 220,128 GET oEnceMemo VAR cEnceMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
		oEnceMemo:oFont := oMonoAs
		oEnceMemo:bRClicked := {|| AllwaysTrue() }
		
		//Motivo do Cancelamento - Se a liga‡„o for cancelada
		@ 212,249 TO 258,373 LABEL STR0020 OF oDlgHist PIXEL  // "Motivo do Cancelamento"
		@ 220,252 GET oCancMemo VAR cCancMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
		oCancMemo:oFont := oMonoAs
		oCancMemo:bRClicked := {|| AllwaysTrue() }
		
		// Legendas da Tela
		@ 260,05 BITMAP oBmp3 ResName "BR_AZUL" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,15 SAY STR0021 OF oDlgHist Color CLR_BLUE,CLR_WHITE PIXEL  	//"Planejada"
		
		@ 260,60 BITMAP oBmp2 ResName "BR_VERMELHO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,70 SAY STR0023 OF oDlgHist Color CLR_RED,CLR_WHITE PIXEL  	//"Pendente"
		
		@ 260,115 BITMAP oBmp1 ResName "BR_VERDE" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,125 SAY STR0024 OF oDlgHist Color CLR_GREEN,CLR_WHITE PIXEL   //"Encerrada"
		
		@ 260,170 BITMAP oBmp4 ResName "BR_PRETO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,180 SAY "Cancelada" OF oDlgHist Color CLR_BLACK,CLR_WHITE PIXEL  //"Cancelada"
		
		@ 268,005 BITMAP oBmp1 ResName "BR_VIOLETA" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 268,015 SAY STR0055 OF oDlgHist Color CLR_MAGENTA,CLR_WHITE PIXEL   // "Pend.com FNC"
		
		@ 268,060 BITMAP oBmp1 ResName "BR_LARANJA" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 268,070 SAY STR0056 OF oDlgHist Color CLR_ORANGE,CLR_WHITE PIXEL   // "Pend.FNC Baixada"
		
		DEFINE SBUTTON oBtn01 FROM 260,260 TYPE 18  ENABLE  OF oDlgHist ONSTOP STR0058 ACTION TMK272AVFNC(@oDlgHist, @oGetHist, cCodLig, @aCols, @aHeader)  // "Ficha de Nao-Conformidades"
		oBtn01:cTitle := STR0059
		oBtn01:Refresh()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Trata se a rotina foi  chamada de fora do atendimento receptivo. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtendimento
			DEFINE SBUTTON FROM 260,300 TYPE 1 ENABLE OF oDlgHist ACTION (nOpcA := 1,oDlgHist:End())
		Endif
		
		DEFINE SBUTTON FROM 260,340 TYPE 2 ENABLE OF oDlgHist ACTION (oDlgHist:End())
		
		FATPDLogUser("TK272HTMK")
		ACTIVATE MSDIALOG oDlgHist CENTER ON INIT CursorArrow()
		
		RestArea(aArea)
		
		If nOpcA == 1  .AND. lAtendimento
			lRet := .T.
			
			If oEnchTmk:cAlias == "SUC" .And. nOpc <> 2
				If ((TkGetTipoAte() == "1") .OR. (nFolder == 1)) .And. !Empty(cLock)
					UnLockByName(cLock,.T.,FWModeAccess("SUC",3) == "E",.T.)
					cLock := ""
				EndIf
				If !LockByName("SUC"+cFilSUC+cCodLig,.T.,FWModeAccess("SUC",3) == "E",.T.)
					MsgAlert(OemToAnsi(STR0080))	//"Outro operador já está alterando este Atendimento. Será carregado somente para visualização."
					nOpc := 2 // Visualização
					lHabilita := .F.
					cLock := ""
				Else
					cLock := "SUC"+cFilSUC+cCodLig
				EndIf
			ElseIf oEnchTmk:cAlias == "SUC" .And. nOpc == 2
				If ExistCPO("SUC",M->UC_CODIGO)
					If !LockByName("SUC"+cFilSUC+cCodLig,.T.,FWModeAccess("SUC",3) == "E",.T.)
						MsgAlert(OemToAnsi(STR0080))	//"Outro operador já está alterando este Atendimento. Será carregado somente para visualização."
						nOpc := 2 // Visualização
						lHabilita := .F.
						cLock := ""
					Else
						nOpc := 4 // Alteração
						lHabilita := .T.
						cLock := "SUC"+cFilSUC+cCodLig
					EndIf
				EndIf
			EndIf
			
			Tk272NumTmk(@nOpc,cCodLig,@lHabilita,oFolderTmk,@oEnchTmk,@cMotivo,@cEncerra,@cLock)
		Else
			aCols 	:= aClone(aColAnt)
			aHeader := aClone(aHeadAnt)
			n 	  	:= nAnt
			RestArea(aArea)
		Endif
		
		Return(lRet)
		
	Else // Historico por Entidade"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A ordem do historico por entidade e por ordem decrescente ou seja do atendimento mais antigo para o mais novo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SUC")
		DbSetOrder(5)	//FILIAL+ENTIDADE+CHAVE+STR(UC_DIASDAT,8,0)+STR(UC_HORADAT,8,0)
		
		#IFDEF TOP
			If ( TcSrvType()<>"AS/400" )
				cQuery := "SELECT * "
				cQuery += "FROM " + RetSqlName("SUC") + " SUC "
				cQuery += "WHERE "
				cQuery += 		"SUC.UC_FILIAL	='" + cFilSUC + "' AND "
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for cliente procura também seus antepassados.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(M->UC_ENTIDAD) == "SA1"
					cQuery += 	"( ( SUC.UC_ENTIDAD	='" + M->UC_ENTIDAD  + "' AND SUC.UC_CHAVE	='" + M->UC_CHAVE    + "' ) OR "
					cQuery +=	"( SUC.UC_ENTIDAD ='SUS' AND SUC.UC_CHAVE ='" + cProspect + cLojaPro + "' ) OR "
					cQuery +=	"( SUC.UC_ENTIDAD ='ACH' AND SUC.UC_CHAVE ='" + cSuspect + cLojaSus + "' ) ) AND "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for prospect procura também seu suspect e seu cliente.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf Alltrim(M->UC_ENTIDAD) == "SUS"
					cQuery += 	"( ( SUC.UC_ENTIDAD	='" + M->UC_ENTIDAD  + "' AND SUC.UC_CHAVE	='" + M->UC_CHAVE    + "' ) OR "
					cQuery +=	"( SUC.UC_ENTIDAD ='SA1' AND SUC.UC_CHAVE ='" + cCliente + cLojaCli + "' ) OR "
					cQuery +=	"( SUC.UC_ENTIDAD ='ACH' AND SUC.UC_CHAVE ='" + cSuspect + cLojaSus + "' ) ) AND "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for suspect procura também seu prospect e seu cliente.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf Alltrim(M->UC_ENTIDAD) == "ACH"
					cQuery += 	"( ( SUC.UC_ENTIDAD	='" + M->UC_ENTIDAD  + "' AND SUC.UC_CHAVE	='" + M->UC_CHAVE    + "' ) OR "
					cQuery +=	"( SUC.UC_ENTIDAD ='SA1' AND SUC.UC_CHAVE ='" + cCliente + cLojaCli + "' ) OR "
					cQuery +=	"( SUC.UC_ENTIDAD ='SUS' AND SUC.UC_CHAVE ='" + cProspect + cLojaPro + "' ) ) AND "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se não só procura a entidade em si.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					cQuery += 		"SUC.UC_ENTIDAD	='" + M->UC_ENTIDAD  + "' AND "
					cQuery += 		"SUC.UC_CHAVE	='" + M->UC_CHAVE    + "' AND "
				EndIf
				cQuery += 		"SUC.UC_DATA BETWEEN 	'" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' AND "
				cQuery += 		"SUC.UC_OPERADO BETWEEN '" + MV_PAR03 + "' AND  '" + MV_PAR04 + "' AND "
				
				If MV_PAR05 <> 1 //Todas
					cQuery += 	"SUC.UC_STATUS = '" + STR(MV_PAR05-1,1) + "' AND "
				Endif
				
				If MV_PAR06 <> 1 //Ambos
					cQuery += 	"SUC.UC_OPERACA = '" + IIF(MV_PAR06==2,"1","2") + "' AND "
				Endif
				
				cQuery += 		"SUC.D_E_L_E_T_ = ' '"
				cQuery += " ORDER BY "+SqlOrder(SUC->(IndexKey()))
				cQuery := ChangeQuery(cQuery)
				
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMK',.T.,.T.)
				DbSelectArea("TMK")
				DbGoTop()
				While (!TMK->(Eof()))
					aAdd(aLigacoes, {Tk272Pendente(TMK->UC_STATUS,TMK->UC_CODCANC,TMK->UC_CODIGO),;                                             //  01- Semaforo - vermelho
					                 TMK->UC_CODIGO,;                                                                                           //  02- Liga‡„o
					                 Posicione("SX2",1,ALLTRIM(TMK->UC_ENTIDAD),"X2NOME()")+":"+TkEntidade(TMK->UC_ENTIDAD,TMK->UC_CHAVE,1),;   //  03- Entidade
					                 Posicione("SU5",1,cFilSU5+TMK->UC_CODCONT,"U5_CONTAT"),;                                                   //  04- Contato
					                 DTOC(StoD(TMK->UC_DATA)),;                                                                                 //  05- Data
					                 TMK->UC_INICIO,;                                                                                           //  06- Hora
					                 Posicione("SU7",1,cFilSU7+TMK->UC_OPERADO,"U7_NOME"),;                                                     //  07- Operador
					                 TkOperacao(TMK->UC_OPERACA),;                                                                              //  08- Operacao
					                 Tk272Ligacao(TMK->UC_STATUS,"TMK"),;                                                                       //  09- Status
					                 Posicione("SUL",1,cFilSUL+TMK->UC_TIPO,"UL_DESC"),;                                                        //  10- Comunicacao
					                 Posicione("SUO",1,cFilSUO+TMK->UC_CODCAMP,"UO_DESC"),;                                                     //  11- Campanha
					                 Posicione("SUH",1,cFilSUH+TMK->UC_MIDIA,"UH_DESC"),;                                                       //  12- Midia
					                 DTOC(StoD(TMK->UC_PENDENT)),;                                                                              //  13- Retorno
					                 TMK->UC_HRPEND,;                                                                                           //  14- Hora
					                 TMK->UC_CODOBS,;                                                                                           //  15- Codigo da Observacao
					                 TMK->UC_CODMOT,;                                                                                           //  16- Codigo do Encerramento
					                 TMK->UC_CODCANC})                                                                                          //  17- Codigo do Cancelamento
					TMK->(DbSkip())
				End
				DbSelectArea("TMK")
				DbCloseArea()
				DbSelectArea("SUC")
				If Len(aLigacoes) <= 0
					Help(" ",1,"SEMDADOS" )
					CursorArrow()
					aCols 	:= aClone(aColAnt)
					aHeader := aClone(aHeadAnt)
					n 	  	:= nAnt
					RestArea(aArea)
					Return(lRet)
				Endif
				
			Else
				DbSelectArea("SUC")
				DbSetOrder(5)		//FILIAL+ENTIDADE+CHAVE+STR(UC_DIASDAT,8,0)+STR(UC_HORADAT,8,0)
				DbSeek(cFilSUC+M->UC_ENTIDAD+M->UC_CHAVE)
				cCodLig :=SUC->UC_CODIGO
				While (!SUC->(Eof())) .AND. (cFilSUC == SUC->UC_FILIAL)  .AND.;
						(SUC->UC_ENTIDAD == M->UC_ENTIDAD)				 .AND.;
						(ALLTRIM(SUC->UC_CHAVE) == ALLTRIM(M->UC_CHAVE))
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica o intervalo de datas do atendimento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SUC->UC_DATA < MV_PAR01 .OR. SUC->UC_DATA > MV_PAR02
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif
					
					If SUC->UC_OPERADO < MV_PAR03 .OR. SUC->UC_OPERADO > MV_PAR04
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif
					
					If MV_PAR05 <> 1 //Todas
						If SUC->UC_STATUS <> STR(MV_PAR05-1,1)
							DbSelectArea("SUC")
							SUC->(Dbskip())
							Loop
						Endif
					Endif
					
					If MV_PAR06 <> 1 //Ambas
						If MV_PAR06 == 2 .AND. SUC->UC_OPERACA <> "1" //Receptivo
							DbSelectArea("SUC")
							SUC->(Dbskip())
							Loop
						ElseIf MV_PAR06 == 3 .AND. SUC->UC_OPERACA <> "2"//Ativo
							DbSelectArea("SUC")
							SUC->(Dbskip())
							Loop
						Endif
					Endif
					
					aAdd(aLigacoes, {Tk272Pendente(SUC->UC_STATUS,SUC->UC_CODCANC,SUC->UC_CODIGO),;                                              //  01- Semaforo - vermelho
					                 SUC->UC_CODIGO,;                                                                                            //  02- Liga‡„o
					                 Posicione("SX2",1,ALLTRIM(SUC->UC_ENTIDAD),"X2NOME()")+":"+TkEntidade(SUC->UC_ENTIDAD,SUC->UC_CHAVE,1),;    //  03- Entidade
					                 Posicione("SU5",1,cFilSU5+SUC->UC_CODCONT,"U5_CONTAT"),;                                                    //  04- Contato
					                 DTOC(SUC->UC_DATA),;                                                                                        //  05- Data
					                 SUC->UC_INICIO,;                                                                                            //  06- Hora
					                 Posicione("SU7",1,cFilSU7+SUC->UC_OPERADO,"U7_NOME"),;                                                      //  07- Operador
					                 TkOperacao(SUC->UC_OPERACA),;                                                                               //  08- Operacao
					                 Tk272Ligacao(SUC->UC_STATUS),;                                                                              //  09- Status
					                 Posicione("SUL",1,cFilSUL+SUC->UC_TIPO,"UL_DESC"),;                                                         //  10- Comunicacao
					                 Posicione("SUO",1,cFilSUO+SUC->UC_CODCAMP,"UO_DESC"),;                                                      //  11- Campanha
					                 Posicione("SUH",1,cFilSUH+SUC->UC_MIDIA,"UH_DESC"),;                                                        //  12- Midia
					                 DTOC(SUC->UC_PENDENT),;                                                                                     //  13- Data de Retorno
					                 SUC->UC_HRPEND,;                                                                                            //  14- Hora
					                 SUC->UC_CODOBS,;                                                                                            //  15- Codigo da Observacao
					                 SUC->UC_CODMOT,;                                                                                            //  16- Codigo do Encerramento
					                 SUC->UC_CODCANC})                                                                                           //  17- Codigo do Cancelamento
					
					SUC->(DbSkip())
				End
				If Len(aLigacoes) <= 0
					Help(" ",1,"SEMDADOS" )
					CursorArrow()
					aCols 	:= aClone(aColAnt)
					aHeader := aClone(aHeadAnt)
					n 	  	:= nAnt
					RestArea(aArea)
					Return(lRet)
				Endif
			Endif
			
		#ELSE
			DbSelectArea("SUC")
			DbSetOrder(3) 	//FILIAL+ENTIDADE+CHAVE+STR(UC_DIASDAT,8,0)+STR(UC_HORADAT,8,0)
			DbSeek(cFilSUC+DTOS(MV_PAR01),.T.)
			cCodLig :=SUC->UC_CODIGO
			While (!SUC->(Eof())) .And. (cFilSUC == SUC->UC_FILIAL) .And. SUC->UC_DATA <= MV_PAR02
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for cliente procura também seus antepassados.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(M->UC_ENTIDAD) == "SA1"
					If  !(																;
							(															;
							SUC->UC_ENTIDAD == M->UC_ENTIDAD .And.					;
							ALLTRIM(SUC->UC_CHAVE) == ALLTRIM(M->UC_CHAVE)			;
							) .Or.														;
							(   														;
							SUC->UC_ENTIDAD == "SUS" .And.							;
							ALLTRIM(SUC->UC_CHAVE) == AllTrim(cProspect + cLojaPro);
							) .Or.														;
							(															;
							SUC->UC_ENTIDAD == "ACH" .And.							;
							ALLTRIM(SUC->UC_CHAVE) == AllTrim(cSuspect + cLojaSus)	;
							)     														;
							)
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for prospect procura também seu suspect e seu cliente.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf Alltrim(M->UC_ENTIDAD) == "SUS"
					If  !(																;
							(															;
							SUC->UC_ENTIDAD == M->UC_ENTIDAD .And.					;
							ALLTRIM(SUC->UC_CHAVE) == ALLTRIM(M->UC_CHAVE)			;
							) .Or.														;
							(   														;
							SUC->UC_ENTIDAD == "ACH" .And.							;
							ALLTRIM(SUC->UC_CHAVE) == AllTrim(cSuspect + cLojaSus);
							) .Or.														;
							(															;
							SUC->UC_ENTIDAD == "SA1" .And.							;
							ALLTRIM(SUC->UC_CHAVE) == AllTrim(cCliente + cLojaCli)	;
							)     														;
							)
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for suspect procura também seu prospect e seu cliente.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf Alltrim(M->UC_ENTIDAD) == "ACH"
					If  !(																;
							(															;
							SUC->UC_ENTIDAD == M->UC_ENTIDAD .And.					;
							ALLTRIM(SUC->UC_CHAVE) == ALLTRIM(M->UC_CHAVE)			;
							) .Or.														;
							(   														;
							SUC->UC_ENTIDAD == "SUS" .And.							;
							ALLTRIM(SUC->UC_CHAVE) == AllTrim(cProspect + cLojapro);
							) .Or.														;
							(															;
							SUC->UC_ENTIDAD == "SA1" .And.							;
							ALLTRIM(SUC->UC_CHAVE) == AllTrim(cCliente + cLojaCli)	;
							)     														;
							)
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se não só procura a entidade em si.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					If  !(																;
							(															;
							SUC->UC_ENTIDAD == M->UC_ENTIDAD .And.					;
							ALLTRIM(SUC->UC_CHAVE) == ALLTRIM(M->UC_CHAVE)			;
							) 															;
							)
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					EndIf
				Endif
				
				If SUC->UC_OPERADO < MV_PAR03 .OR. SUC->UC_OPERADO > MV_PAR04
					DbSelectArea("SUC")
					SUC->(Dbskip())
					Loop
				Endif
				
				If MV_PAR05 <> 1 //Todas
					If SUC->UC_STATUS <> STR(MV_PAR05-1,1)
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif
				Endif
				
				If MV_PAR06 <> 1 //Ambas
					If MV_PAR06 == 2 .AND. SUC->UC_OPERACA <> "1" //Receptivo
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					ElseIf MV_PAR06 == 3 .AND. SUC->UC_OPERACA <> "2"//Ativo
						DbSelectArea("SUC")
						SUC->(Dbskip())
						Loop
					Endif
				Endif
				
				AAdd(aLigacoes, {Tk272Pendente(SUC->UC_STATUS,SUC->UC_CODCANC,SUC->UC_CODIGO),;                                            //  01- Semaforo - vermelho
				                 SUC->UC_CODIGO,;                                                                                          //  02- Liga‡„o
				                 Posicione("SX2",1,ALLTRIM(SUC->UC_ENTIDAD),"X2NOME()")+":"+TkEntidade(SUC->UC_ENTIDAD,SUC->UC_CHAVE,1),;  //  03- Entidade
				                 Posicione("SU5",1,cFilSU5+SUC->UC_CODCONT,"U5_CONTAT"),;                                                  //  04- Contato
				                 DTOC(SUC->UC_DATA),;                                                                                      //  05- Data
				                 SUC->UC_INICIO,;                                                                                          //  06- Hora
				                 Posicione("SU7",1,cFilSU7+SUC->UC_OPERADO,"U7_NOME"),;                                                    //  07- Operador
				                 TkOperacao(SUC->UC_OPERACA),;                                                                             //  08- Operacao
				                 Tk272Ligacao(SUC->UC_STATUS),;                                                                            //  09- Status
				                 Posicione("SUL",1,cFilSUL+SUC->UC_TIPO,"UL_DESC"),;                                                       //  10- Comunicacao
				                 Posicione("SUO",1,cFilSUO+SUC->UC_CODCAMP,"UO_DESC"),;                                                    //  11- Campanha
				                 Posicione("SUH",1,cFilSUH+SUC->UC_MIDIA,"UH_DESC"),;                                                      //  12- Midia
				                 DTOC(SUC->UC_PENDENT),;                                                                                   //  13- Data de Retorno
				                 SUC->UC_HRPEND,;                                                                                          //  14- Hora
				                 SUC->UC_CODOBS,;                                                                                          //  15- Codigo da Observacao
				                 SUC->UC_CODMOT,;                                                                                          //  16- Codigo do Encerramento
				                 SUC->UC_CODCANC})                                                                                         //  17- Codigo do Cancelamento
				SUC->(DbSkip())
			End
			
			If Len(aLigacoes) <= 0
				Help(" ",1,"SEMDADOS" )
				CursorArrow()
				aCols 	:= aClone(aColAnt)
				aHeader := aClone(aHeadAnt)
				n 	  	:= nAnt
				RestArea(aArea)
				Return(lRet)
			Endif
		#Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra dados do Produto.								     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgHist FROM 50,001 TO 600,750 TITLE STR0004 + ": " + M->UC_DESCCHAV PIXEL  //"Historico"
		
		@01,02 TO 210,374 LABEL STR0005 OF oDlgHist PIXEL //"Atendimentos realizados pelo TeleMarketing"
		
		@08,05 LISTBOX oLbx FIELDS ;
			HEADER ;
			" ",;		// 01 - Legenda
		STR0006,;	// 02 - "Atendimento"
		STR0008,;	// 03 - "Entidade"
		STR0007,;	// 04 - "Contato"
		STR0009,;	// 05 - "Data"
		STR0010,;	// 06 - "Hora"
		STR0011,;	// 07 - "Operador"
		STR0012,;	// 08 - "Operacao"
		STR0013,;	// 09 - "Status"
		STR0014,;	// 10 - "Comunicacao"
		STR0015,;	// 11 - "Campanha"
		STR0016,;	// 12 - "M¡dia"
		STR0017,;	// 13 - "Retorno"
		STR0010;	// 14 - "Hora"
		SIZE 365,100 OF oDlgHist PIXEL
		
		oLbx:SetArray(aLigacoes)
		oLbx:bLine:={||{aLigacoes[oLbx:nAt,1],;
			aLigacoes[oLbx:nAt,2],;
			aLigacoes[oLbx:nAt,3],;
			aLigacoes[oLbx:nAt,4],;
			aLigacoes[oLbx:nAt,5],;
			aLigacoes[oLbx:nAt,6],;
			aLigacoes[oLbx:nAt,7],;
			aLigacoes[oLbx:nAt,8],;
			aLigacoes[oLbx:nAt,9],;
			aLigacoes[oLbx:nAt,10],;
			aLigacoes[oLbx:nAt,11],;
			aLigacoes[oLbx:nAt,12],;
			aLigacoes[oLbx:nAt,13],;
			aLigacoes[oLbx:nAt,14],;
			aLigacoes[oLbx:nAt,15]}}
		aPDCols := {"","","U5_CONTAT","A1_NOME","","","U7_NOME","","","","","","","",""}
		
		If FATPDActive() .And. FTPDUse(.T.)
			oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
		EndIf 

		// Carrega os items do pedido e atualiza o codigo do atendimento para ser carregado na tela no OK
		oLbx:bChange := {||	Tk272CargaTmk(	.T.,		oGetHist,				aLigacoes[oLbx:nAt,2],	aLigacoes[oLbx:nAt,15],;
			@cObsMemo,	oObsMemo,				aLigacoes[oLbx:nAt,16],	@cEnceMemo,;
			oEnceMemo,	aLigacoes[oLbx:nAt,17],	@cCancMemo,				oCancMemo),;
			cCodLig := Eval(oLbx:bLine)[2]}
		oLbx:Refresh()
		oLbx:SetFocus(.T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o acols com os itens da ligacao selecionada		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodLig	:= aLigacoes[1][2]
		TkMontaItens("SUD",cCodLig,"M")
		
		oGetHist:= MSGetDados():New(115,5,200,370,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,99)
		
		//Observa‡„o da liga‡„o
		@ 212,02 TO 258,122 LABEL STR0018 OF oDlgHist PIXEL  //"Observa‡„o da liga‡„o"
		@ 220,05 GET oObsMemo VAR cObsMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
		oObsMemo:oFont := oMonoAs
		oObsMemo:bRClicked := {|| AllwaysTrue() }
		
		//Motivo do Encerramento - Se a liga‡„o for encerrada
		@ 212,125 TO 258,245 LABEL STR0019 OF oDlgHist PIXEL  // "Motivo do Encerramento"
		@ 220,128 GET oEnceMemo VAR cEnceMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
		oEnceMemo:oFont := oMonoAs
		oEnceMemo:bRClicked := {|| AllwaysTrue() }
		
		//Motivo do Cancelamento - Se a liga‡„o for cancelada
		@ 212,249 TO 258,373 LABEL STR0020 OF oDlgHist PIXEL  // "Motivo do Cancelamento"
		@ 220,252 GET oCancMemo VAR cCancMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
		oCancMemo:oFont := oMonoAs
		oCancMemo:bRClicked := {|| AllwaysTrue() }
		
		// Legendas da Tela
		@ 260,05 BITMAP oBmp3 ResName "BR_AZUL" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,15 SAY STR0021 OF oDlgHist Color CLR_BLUE,CLR_WHITE PIXEL  	//"Planejada"
		
		@ 260,60 BITMAP oBmp2 ResName "BR_VERMELHO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,70 SAY STR0023 OF oDlgHist Color CLR_RED,CLR_WHITE PIXEL  	//"Pendente"
		
		@ 260,115 BITMAP oBmp1 ResName "BR_VERDE" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,125 SAY STR0024 OF oDlgHist Color CLR_GREEN,CLR_WHITE PIXEL   //"Encerrada"
		
		@ 260,170 BITMAP oBmp4 ResName "BR_PRETO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 260,180 SAY STR0192 OF oDlgHist Color CLR_BLACK,CLR_WHITE PIXEL  //"Cancelada"
		
		@ 268,005 BITMAP oBmp1 ResName "BR_VIOLETA" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 268,015 SAY STR0055 OF oDlgHist Color CLR_MAGENTA,CLR_WHITE PIXEL   // "Pend.com FNC"
		
		@ 268,060 BITMAP oBmp1 ResName "BR_LARANJA" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
		@ 268,070 SAY STR0056 OF oDlgHist Color CLR_ORANGE,CLR_WHITE PIXEL   // "Pend.FNC Baixada"
		
		DEFINE SBUTTON oBtn01 FROM 260,260 TYPE 18  ENABLE  OF oDlgHist ONSTOP STR0058 ACTION TMK272AVFNC(@oDlgHist, @oGetHist, cCodLig, @aCols, @aHeader)  // "Ficha de Nao-Conformidades"
		oBtn01:cTitle := STR0059
		oBtn01:Refresh()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Trata se a rotina foi  chamada de fora do atendimento receptivo. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtendimento
			DEFINE SBUTTON FROM 260,300 TYPE 1 ENABLE OF oDlgHist ACTION (nOpcA := 1,oDlgHist:End())
		Endif
		
		DEFINE SBUTTON FROM 260,340 TYPE 2 ENABLE OF oDlgHist ACTION (oDlgHist:End())
		
		FATPDLogUser("TK272HTMK")
		ACTIVATE MSDIALOG oDlgHist CENTER ON INIT CursorArrow()
		
		RestArea(aArea)
		
		If nOpcA == 1
			lRet := .T.
			
			If oEnchTmk:cAlias == "SUC" .And. nOpc <> 2
				If ((TkGetTipoAte() == "1") .OR. (nFolder == 1)) .And. !Empty(cLock)
					UnLockByName(cLock,.T.,FWModeAccess("SUC",3) == "E",.T.)
					cLock := ""
				EndIf
				If !LockByName("SUC"+cFilSUC+cCodLig,.T.,FWModeAccess("SUC",3) == "E",.T.)
					MsgAlert(OemToAnsi(STR0080))	//"Outro operador já está alterando este Atendimento. Será carregado somente para visualização."
					nOpc := 2 // Visualização
					lHabilita := .F.
					cLock := ""
				Else
					cLock := "SUC"+cFilSUC+cCodLig
				EndIf
			ElseIf oEnchTmk:cAlias == "SUC" .And. nOpc == 2
				If ExistCPO("SUC",M->UC_CODIGO)
					If !LockByName("SUC"+cFilSUC+cCodLig,.T.,FWModeAccess("SUC",3) == "E",.T.)
						MsgAlert(OemToAnsi(STR0080))	//"Outro operador já está alterando este Atendimento. Será carregado somente para visualização."
						nOpc := 2 // Visualização
						lHabilita := .F.
						cLock := ""
					Else
						nOpc := 4 // Alteração
						lHabilita := .T.
						cLock := "SUC"+cFilSUC+cCodLig
					EndIf
				EndIf
			EndIf
			
			Tk272NumTmk(@nOpc,cCodLig,@lHabilita,oFolderTmk,@oEnchTmk,@cMotivo,@cEncerra,@cLock)
		Else
			aCols 	:= aClone(aColAnt)
			aHeader := aClone(aHeadAnt)
			n 	  	:= nAnt
			RestArea(aArea)
		Endif
		
		Return(lRet)
	Endif
	FATPDUnload()
	CursorArrow()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkPendente ³ Autor ³Vendas Clientes        ³ Data ³18/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Devolve se a ligacao esta com status pendente ou nao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³TeleMarketing 								              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Status do atendimento                               ³±±
±±³          ³ExpC2 - Codigo do cancelamento                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272Pendente(cStatus,cCodCanc,cCodSUC)
	
	Local oEncerrada    := LoadBitmap( GetResources(), "BR_VERDE" ) 	   	// Identifica os Atendimentos Encerrados
	Local oPendente     := LoadBitmap( GetResources(), "BR_VERMELHO" )		// Identifica os Atendimentos Pendentes
	Local oFncPendente  := LoadBitmap( GetResources(), "BR_VIOLETA" )		// Identifica os  Atendimentos Pendentes com FNC
	Local oFncBaixada   := LoadBitmap( GetResources(), "BR_LARANJA" )		// Identifica os Atendimentos Pendentes com FNC Baixada
	Local oPlanejada    := LoadBitmap( GetResources(), "BR_AZUL" )			// Identifica um Atendimento Planejado
	Local oCancelada    := LoadBitmap( GetResources(), "BR_PRETO" ) 		// Identifica Atendimento Cancelado
	Local oBmp 		   := LoadBitmap( GetResources(), "BR_BRANCO" )		// Bitmap para legenda branca
	Local cAliasOld     := Alias()											// Alias corrente
	Local nX                												// Auxiliar de contador
	
	Default cCodSUC := ""												// Codigo da SUC
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis usadas em Integracoes                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Empty(cCodCanc)
		Do case
		case VAL(cStatus) == PLANEJADA
			oBmp := oPlanejada
			
		case VAL(cStatus) == PENDENTE
			nX := QNCvPen(cCodSUC)
			If nX == 1
				oBmp := oFncPendente
			Elseif nX == 2
				oBmp := oFncBaixada
			Else
				oBmp := oPendente
			Endif
			
		case VAL(cStatus) == ENCERRADA
			oBmp := oEncerrada
		Endcase
	Else
		oBmp := oCancelada
	Endif
	DbSelectArea(cAliasOld)
Return(oBmp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271GrvTmk³ Autor ³Vendas Clientes       ³ Data ³01/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a gravacao do atendimento - TELEMARKETING			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TeleMarketing        									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Operacao autal (inclusao, alteracao, etc)           ³±±
±±³          ³ExpO2 - Objeto do folder                                    ³±±
±±³          ³ExpC3 - Motivo do encerramento                              ³±±
±±³          ³ExpC4 - Descricao do encerramento                           ³±±
±±³          ³ExpL5 - Controla a habilitacao do atendimento para alteracao³±±
±±³          ³ExpA6 - aCols do atendimento                                ³±±
±±³          ³ExpL7 - Indica se o atendimento foi originado no TMKA380    ³±±
±±³          ³ExpA8 - Campos do SUC para gravacao do Telemarketing        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272GrvTmk(	nOpc		,oFolderTmk	,cMotivo	,cEncerra,;
		lHabilita	,aColsTmk	,l380		,aSx3SUC, aParScript)
	
Local aAreaSU7	 := SU7->(GetArea())
Local aAreaSUC	 := {}
Local aAreaSUD	 := {}
Local aArea      := GetArea()
Local aAreaSUQ   := SUQ->(GetArea())
Local lTMKMOK	 := ExistBlock("TMKMOK")					// P.E. no TMK
Local lTMKGRAVA  := ExistBlock("TMKGRAVA")					// P.E. no TMK
Local nPAssunto  := aPosicoes[1][2]                 		// Assunto
Local nPStatus   := aPosicoes[13][2]						// Status do item (SUD)
Local nPObsExec  := aPosicoes[15][2]						// Complemento do item
Local nPObsOri	 := aScan( aHeader, { |x| AllTrim(x[2]) == "UD_COMPORI" } )
Local nPosAcao	 := aScan( aHeader, { |x| AllTrim(x[2]) == "UD_SOLUCAO" } )
Local nPosNumOS  := aScan( aHeader, { |x| AllTrim(x[2]) == "UD_NUMOS" } )
Local nPosItem	 := aScan( aHeader, { |x| AllTrim(x[2]) == "UD_ITEM" } )
Local cMay		 := ""										// Variavel auxiliar
Local cHisTmk    := ""										// Monta a descricao do historico
Local cChaveSUC	 := ""										// Chave de pesquisa na SUC
Local cNumAux	 := M->UC_CODIGO							// Variavel auxiliar
Local cCampo     := ""										// Variavel auxiliar para o SX3
Local bCampo    											// Macro do SX3
Local nY		 := 0                               		// Contador de Linhas
Local nX 		 := 0										// Contador de Colunas
Local cI		 := "00"									// Inicializador do ITEM para SUD
Local lNovo      := .F.										// Flag para o Reclock TRUE (inclusao) ou FALSE (alteracao)
Local lPerg		 := .F.										// Flag para perguntar ou nao se desea compartilhar o item do chamado
Local lEncerra	 := .T.										// Indica se deve encerrar o item no chamado pai
Local cTipSta    := STR0021			 						// "Planejada"
Local nPos 		 := 0 										// Contador
Local nPosSUC	 := 0										// Posicao atual do registro do SUC na tabela
Local cCidade	 := ""										// Cidade do contato
Local cEst		 := ""										// Estado do contato
Local cTelRes	 := ""										// Telefone residencial do contato
Local cTelCom1	 := ""										// Telefone Comercial do contato
Local cTelCel	 := ""										// Telefone Celular do Contato
Local cDDD    	 := ""										// DDD do contato
Local cEnd		 := ""										// Endereco do contato
Local cBairro	 := ""										// Bairro do Contato
Local cDescCnt	 := ""										// Nome do Contato
Local lRet		 := .F.										// Retorno da funcao
Local nCont		 := 0 										// Contador para gravacao dos campos no SUC
Local cNovoItem	 := "00"									// Valor do NOVO ITEM que sera incluido no SUD
Local lGravaHist := (GetNewPar("MV_TMKHIST", "S") == "S")	// Verifica se eh permitida a gravacao do campo A1_CODHIST
Local lGravaFNC  := .F.										// Define se ira ser aberta uma FNC
Local aCpoQNC 	 := {}    									// Array com Campos  que  serão preenchidos na FNC
Local aRetQNC 	 := {}    									// Array retorno com dados a serem gravados na FNC
Local aUser 	 := {}										// Array com dados do usuario para  FNC
Local aItCompart := {}										// Array contendo numero dos itens compartilhados
Local lOK		 := .T.										// Conf. do enc. do TLV - Rotina automatica
Local nOpCnvSus  := SuperGetMv("MV_TMKCONV",,3)				// Parametro que define se o suspect deve ou nao ser convertido em prospect
Local nOpDelAch  := SuperGetMv("MV_TMKDACH",,3)				// Parametro que define se deve excluir o suspect apos seu atendimento.
Local lDelACH	 := .F.										// Valor logico que define se o registro do suspect deve ser apagado
Local lCnvACH	 := .F.										// Valor logico que define se o registro do suspect deve ser convertido
Local oWFTemplate:= Nil										// Objeto de gerenciamento de workflow
Local oWFInfo 	 := Nil										// Objeto do workflow
Local cEmail	 := ""										// Email do responsavel
Local cModeloWF  := SuperGetMv("MV_TMKWFCM",,"")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis usadas em Integracoes                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCompart	:= .F.										// Define se podem ser gerados compartilhamentos
Local lIntQNC 	:= .F.                      				// Define a Integracao entre o ambiente Controle de Nao-Conformidades e o ambiente CallCenter
Local lIntTEC	:= .F.										// Define a Integracao entre o ambiente
Local lCpoOs	:= .F.										// Define a capacidade de geracao de OS
Local lTK272QNC	:= ExistBlock("TK272QNC")					// Substitui a chamada de integração com o QNC
Local lGravaCT	:= .F.
Local lGeraOS	:= .F.
Local aCabAB1		:= {}
Local aCabAB6		:= {}
Local aItensAB2		:= {}
Local aItensAB7		:= {}
Local aItemOS		:= {}
Local aCabCmp		:= {}
Local aItemCmp		:= {}
Local aAtendAlt		:= {}
Local nTotalAB2		:= 0
Local nTotalAB7		:= 0
Local nDeletedAB2	:= 0
Local nDeletedAB7	:= 0
Local cOpQNCDDES  	:= SuperGetMv("MV_QNCDDES",,"")
Local cNumOs		:= ""
Local aUDStatus		:= {}
Local nPosStAcao	:= aScan( aHeader, { |x| AllTrim(x[2]) == "UD_STATUS" } )
Local aNewSUS 		:= {}
Local lTK272nOpc := ExistBlock("TK272NOPC")
Local nRetNopc   := 0
	
Local cRetCodUsr		:= RetCodUsr()
	
Local cFilSU5			:= xFilial("SU5")
Local cFilSU7			:= xFilial("SU7")
Local cFilSUC			:= xFilial("SUC")
Local cFilSUD			:= xFilial("SUD")
Local cFilSUQ			:= xFilial("SUQ")
Local cFilSUS			:= xFilial("SUS")
Local cFilAB1			:= xFilial("AB1")
Local cFilAB2			:= xFilial("AB2")
Local cFilAB6			:= xFilial("AB6")
Local cFilAB7			:= xFilial("AB7")
Local cFilACH			:= xFilial("ACH")
Local cFilSA1			:= xFilial("SA1")
Local cFilSB1			:= xFilial("SB1")
	
Static cCodVend		:= ""
Static lUsuCRM		:= .F.
Static lNewOport	:= .F.
Private lMsErroAuto	:= .F.
	
DEFAULT aParScript := {}
	
	
lIntQNC := .T.
	
lCompart := .T.
	
lIntTEC := .T.
	
lCpoOs	:= .T.
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se os campos com os dados da entidade nao estiverem preenchidos, nao efetua a gravacao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If EMPTY(M->UC_ENTIDAD) .OR. EMPTY(M->UC_CHAVE) .Or. !TkContEnt(!lTk271Auto)
	If !lTk271Auto
		Aviso(STR0043,STR0051,{"OK"})//"Atenção","Por favor, selecione uma entidade relacionada ao contato para gravação do atendimento"
	Endif
	Return(lRet)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKMOK
	If !U_TMKMOK(M->UC_CODIGO,M->UC_CHAVE,M->UC_CODCONT,M->UC_OPERADO,M->UC_OPERACA,M->UC_STATUS)
		Return(lRet)
	Endif
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pelo menos o ASSUNTO e obrigatorio no atendimento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[1][nPAssunto]) .AND. Empty(M->UC_OBS)
	If !lTk271Auto
		Help("",1,"FALTA_DADO")
	Endif
	Return(lRet)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se existe um telefone valido para o contato para a geracao de ligacao pendente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->UC_PENDENT)
	DbSelectArea("SU5")
	DbSetOrder(1)
	If DbSeek( cFilSU5 + M->UC_CODCONT)
		
		If 	Empty(SU5->U5_FONE) 	.AND.;
				Empty(SU5->U5_CELULAR) 	.AND.;
				Empty(SU5->U5_FAX) 		.AND.;
				Empty(SU5->U5_FCOM1) 	.AND.;
				Empty(SU5->U5_FCOM2)
			
			If !lTk271Auto
				Help(" ",1,"TMKSEMTEL")
			Endif
			Return(lRet)
		Endif
	Endif
Endif
	
	//Verifico se algum registro Gera oportunidade e se algum registro seleciona vendedor
	DbSelectArea("SUQ")
	SUQ->(DbSetOrder(1))
	For nX := 1 to Len(aCols)
		If SUQ->( DbSeek(cFilSUQ+aCols[nX][nPosAcao]) )
			//----> Apenas quando acao tiver opcao de gerar oportunidade igual a SIM e item do atendimento estiver encerrado
			//Gera oportunidade de venda para DONO/RESPONSAVEL da entidade
			If Alltrim(SUQ->UQ_OPORTU) == "1" .AND. aCols[nX][nPosStAcao] == "2"
				lNewOport := .T.
			EndIf
			//Gera oportunidade de venda para VENDEDOR INFORMADO MANUALMENTE 
			If Alltrim(SUQ->UQ_OPORTU) == "2"	.AND. aCols[nX][nPosStAcao] == "2" .AND. Alltrim(SUQ->UQ_USUCRM) == "1"
				lNewOport 	:= .T.					
				lUsuCRM 	:= .T.
			Endif 
			
			If Alltrim(SUQ->UQ_USUCRM) == "1"
				lUsuCRM := .T.
			Endif
			If lNewOport .And. lUsuCRM
				Exit
			Endif
		EndIf
	Next nX

If lTK272nOpc
	nRetNopc := ExecBlock( "TK272NOPC", .F., .F.)
	If	Valtype( nRetNopc ) == "N" .AND. nRetNopc > 0
		nOpc := nRetNopc
	EndIf
EndIf
	
If nOpc == 5 .Or. nOpc == 4
	If lIntTEC .And. nPosAcao > 0
		cI := "00"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicia a gravacao dos itens do atendimento  - SUD  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aCols)
				
			cI := SomaIt(cI)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existem itens que foram deletados no Atendimento atual e apaga do que foi gravado anteriormente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SUD")
			DbSetOrder(1)
			If DbSeek(cFilSUD + M->UC_CODIGO + cI)
				// Se a ação foi alterada, verifico se a ação gera CT e se gerar procuro ela e vejo seu status
				If SUD->UD_SOLUCAO <> aCols[nX][nPosAcao] .Or. aCols[nX][Len(aHeader)+1]
					If TK272GerCT( SUD->UD_SOLUCAO )
						DbSelectArea("AB1")
						DbSetOrder( 5 )
						If AB1->(DbSeek( cFilAB1 + M->UC_CODIGO ))
							DbSelectArea("AB2")
							DbSetOrder( 1 )
							If AB2->(DbSeek( cFilAB2 + AB1->AB1_NRCHAM ))
								nTotalAB2 := 0
								While AB2->AB2_FILIAL == cFilAB2 .And.;
								      AB2->AB2_NRCHAM == AB1->AB1_NRCHAM	.And.;
								      AB2->(!EOF())
									nTotalAB2++
									// Localiza o produto dessa linha
									If AB2->AB2_CODPRO+AB2->AB2_NUMSER == SUD->UD_PRODUTO+SUD->UD_NSERIE
										// Se estiver encerrado não permite a alteração da ação
										If AB2->AB2_TIPO == "5"
											Alert(STR0064 + " '" + SUD->UD_PRODUTO + "'" + " " + STR0065 + " '" + SUD->UD_NSERIE + "' " + STR0066) // "O chamado gerado pelo produto" "numero de série" "não pode ser alterado pois o chamado técnico foi encerrado."
											aCols[nX][nPosAcao] := SUD->UD_SOLUCAO
											aCols[nX][Len(aHeader)+1] := .F.
											Return(.F.)
										Else
											nDeletedAB2++
											RecLock( "AB2", .F. )
											AB2->(DbDelete())
											AB2->(MsUnLock())
										EndIf
									EndIf
									AB2->(DbSkip())
								End
							EndIf
						EndIf
					EndIf
				EndIf
			Endif

		Next nX
		
		If nTotalAB2 > 0 .And. nTotalAB2 == nDeletedAB2
			RecLock("AB1", .F.)
			AB1->(DbDelete())
			AB1->(MsUnLock())
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ja existia alguma ordem de servico vinculada ao chamado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SUD->(DbSetOrder(1))
	AB6->(DbSetOrder(1))
	AB7->(DbSetOrder(1))
	
	cI := "00"
	
	For nX := 1 to Len(aCols)
		
		cI 		:= SomaIt(cI)
		
		If SUD->(DbSeek(cFilSUD + M->UC_CODIGO + cI))
			
			lGeraOs := (lCpoOS .AND. (Posicione("SUQ",1,cFilSUQ+SUD->UD_SOLUCAO,"UQ_GERAOS") == "1"))
			nTotalAB7 := 0
			
			If (SUD->UD_SOLUCAO <> aCols[nX][nPosAcao] .Or. aCols[nX][Len(aHeader)+1]) .AND. lGeraOS
				If AB6->(DbSeek( cFilAB6 + SUD->UD_NUMOS ))
					AB7->(DbSeek( cFilAB7 + AB6->AB6_NUMOS ))
					While AB7->AB7_FILIAL	== cFilAB7	.And.;
					      AB7->AB7_NUMOS 	== AB6->AB6_NUMOS	.And.;
					      AB7->(!EOF())
						nTotalAB7++
						// Localiza o produto dessa linha
						If AB7->AB7_CODPRO+AB7->AB7_NUMSER == SUD->UD_PRODUTO+SUD->UD_NSERIE
							// Se estiver encerrado não permite a alteração da ação
							If AB7->AB7_TIPO <> "1"
								Alert(STR0067 + " '" + AllTrim(SUD->UD_PRODUTO) + "'" + " " + STR0065 + " '" + AllTrim(SUD->UD_NSERIE) + "' " + STR0068) // "A Ordem de serviço gerada pelo produto" "numero de série" "não pode ser alterada pois a ordem de serviço foi atendida"
								aCols[nX][nPosAcao] := SUD->UD_SOLUCAO
								aCols[nX][Len(aHeader)+1] := .F.
								Return(.F.)
							Else
								nDeletedAB7++
							
								RecLock( "AB7", .F. )
								AB7->(DbDelete())
								AB7->(MsUnLock())
							
								RecLock("SUD", .F.)
								SUD->UD_NUMOS := ""
								SUD->(MsUnLock())
							
								aCols[nX][nPosNumOS] := ""
							EndIf
						EndIf
						AB7->(DbSkip())
					End
				EndIf
			EndIf

		EndIf
	Next nX

	If nTotalAB7 > 0 .And. nTotalAB7 == nDeletedAB7
		RecLock("AB6", .F.)
		AB6->(DbDelete())
		AB6->(MsUnLock())
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for uma ALTERACAO		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 4)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a ligacao existe na base  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUC")
	DbSetOrder(1)
	If !DbSeek(cFilSUC + M->UC_CODIGO)
		If !lTk271Auto
			Help(" ",1,"TK270NSEEK")
		Endif
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a ligacao estava cancelada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SUC->UC_CODCANC)
		If !lTk271Auto
			Help(" ",1,"CANCELADA")
		Endif
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a ligacao estava encerrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SUC->UC_CODENCE)
		If !lTk271Auto
			Help(" ",1,"ENCERRADA")
		Endif
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consistencias da Integracao com o QNC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIntQNC
		// Antes de comecar as consistencias carrego as FNC pois a SUD nao esta posicionada
		SUD->(DbSetOrder(1))
		If SUD->(DbSeek(cFilSUD+SUC->UC_CODIGO))
			nX := 1
			While SUD->(!Eof()) 						.AND. ;
					(cFilSUD == SUD->UD_FILIAL) 		.AND. ;
					(SUD->UD_CODIGO == SUC->UC_CODIGO)
				Aadd(aCpoQNC,{SUD->UD_CODFNC,SUD->UD_FNCREV})
				SUD->(DbSkip())
			End
		Endif
		
		// Garanto o tamanho  do aCpoQNC  seja  igual ao do aCols
		If Len(aCols) > Len(aCpoQNC)
			For nX := Len(aCpoQNC) To Len(aCols)
				Aadd(aCpoQNC,{"",""})
			Next nX
		Endif
		
		If lIntQNC
			For nX := 1 To Len(aCols)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se estiver Encerrada e nao estiver excluida verifico se a FNC esta baixada ou Cancelada   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aCols[nX][nPStatus] == "2" 					.AND.;	// Assunto Encerrado
					!Empty(aCpoQNC[nX][1]) 						.AND.;	// FNC  Gerada
					!QNCVERI(aCpoQNC[nX][1], aCpoQNC[nX][2]) 	.AND.;	// FNC Pendente
					!(aCols[nX][Len(aHeader)+1]) 						// Registro Valido?
					
					aCols[nX][nPStatus] := "1"					// Se a FNC estiver Pendente o Assunto  não podera ser encerrado
					MsgAlert(STR0054) 							//"Nao e  possivel  encerrar um atendimento com FNC Pendente."
					Return(lRet)
					
				Endif
				If aCols[nX][nPStatus] == "1" 					.AND.;	// Assunto Encerrado
					!Empty(aCpoQNC[nX][1]) 						.AND.;	// FNC  Gerada
					!QNCVERI(aCpoQNC[nX][1], aCpoQNC[nX][2]) 	.AND.;	// FNC Pendente
					(aCols[nX][Len(aHeader)+1]) 							// Assunto deletado
					
					MsgAlert(STR0063) 							//"O assunto não pode ser excluído pois possui Ficha de Não Conformidade com status Procede, ou seja já possui movimentação."
					Return(lRet)
					
				Endif
			Next nX
			
			aCpoQNC := {} // Zero array
			
		Endif
	Endif
Endif

If (Val(M->UC_STATUS) == ENCERRADA)
	
	If !lTk271Auto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe algum código de encerramento cadastrado. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Tk272VerSUN("1")
			lOK := TmkOk(STR0022) //Confirma Encerramento ?"
		Else
			Help(" ",1,"TK272SUN")
			lOK := .F.
		EndIf
	Endif
	
	If lOK
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe algum item do atendimento TeleMarketing  ³
		//³que esta pendente. Caso positivo não permite o encerramento ³
		//³da ligacao.                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aCols)
			If (aCols[nX][nPStatus]) == "1" .AND. !(aCols[nX][Len(aHeader)+1])		// Se esta pendente e o item nao esta deletado.
				If !lTk271Auto
					Help(" ",1,"TK272ITPEN")
				Endif
				Return(lRet)
			Endif
		Next nX
	Else
		Return(lRet)
	Endif
Endif

If nOpc == 3  // Se for INCLUSAO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status dos semaforos para evitar o empilhamento do ultimo folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TkGetTipoAte() == "4"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O usuario esta no primeiro folder     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nFolder == 1  //TMK
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volta a sequencia do ultimo folder    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACF")
			RollBackSX8()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volta a sequencia do penultimo folder ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SUA")
			RollBackSX8()
			
			DbSelectArea("SUC")
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impede que sejam feitos 2 atendimentos com o mesmo numero³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUC")
	DbSetOrder(1)
	cMay := "SUC" + ALLTRIM(cFilSUC) + cNumAux
	While (DbSeek(cFilSUC + cNumAux) .OR. !MayIUseCode(cMay))
		cNumAux := Soma1(cNumAux,Len(cNumAux))
		cMay 	:= "SUC"+ALLTRIM(cFilSUC)+cNumAux
	EndDo
	
	If (cNumAux <> M->UC_CODIGO)
		If !lTk271Auto
			Help(" ",1,"NUMSEQ",,cNumAux,4,15)
		Endif
		M->UC_CODIGO := cNumAux
	Endif
	
	If __lSX8
		ConfirmSX8()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera numeros reservados                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FreeUsedCode(.T.)
	
	lNovo := .T.
Endif

BEGIN TRANSACTION
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa as gravacoes de lista (SU4) se houver necessidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Val(M->UC_STATUS) == PENDENTE)
		cTipSta := STR0023 //"Pendente"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a data de retorno estiver preenchida grava uma NOVA lista pendente na lista de contatos SU4/SU6 ³
		//³Para a rotina de TLC nao esta sendo considerado o parametro MV_TMKINCP						 	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->UC_PENDENT)
			
			TKGrvSU4(M->UC_CODCONT	,M->UC_ENTIDAD	,M->UC_CHAVE	,M->UC_OPERADO,;
				"1"				,M->UC_CODIGO	,M->UC_PENDENT	,M->UC_HRPEND,;
				l380)
		Endif
		
	ElseIf (Val(M->UC_STATUS) == ENCERRADA)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a tela de Encerramento          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTipSta := STR0024 //"Encerrada"
		Tk272Encerra(.F.,M->UC_CODIGO,@cEncerra,@cMotivo,Nil)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encerra as listas de pendencias se existir alguma - SOMENTE PARA ESSE ATENDIMENTO ENCERRADO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK272DelSU4(M->UC_CODIGO)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o item do chamado que gerou o compartilhamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCompart .AND. !Empty(SUC->UC_CHAORIG)
			
			aAreaSUD := SUD->(GetArea())
			aAreaSUC := SUC->(GetArea())
			cChaveSUC := cFilSUC+SUC->UC_CHAORIG+SUC->UC_ITCHAOR
			
			DbSelectArea("SUC")
			DbSetOrder(8)
			DbSeek(cChaveSUC)
			While lEncerra .AND. SUC->(!Eof()) .AND. SUC->UC_FILIAL + SUC->UC_CHAORIG + SUC->UC_ITCHAOR == cChaveSUC
				If Val(SUC->UC_STATUS) != ENCERRADA .AND. SUC->UC_CODIGO <> M->UC_CODIGO
					lEncerra := .F.
				EndIf
				SUC->(DbSkip())
			EndDo
			RestArea(aAreaSUC)
			
			//Verifica se todos os compartilhamentos deste item foram encerrados
			If lEncerra
				DbSelectArea("SUD")
				DbSetOrder(1)
				If DbSeek(cFilSUD+SUC->UC_CHAORIG+SUC->UC_ITCHAOR)
					RecLock("SUD",.F.)
					SUD->UD_STATUS := "2"
					MsUnLock()
				EndIf
			EndIf
			RestArea(aAreaSUD)
			
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia a gravacao do cabecalho do atendimento - SUC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SUC", lNovo)
	
	For nCont := 1 To Len(aSx3SUC)				// Array com os campos do SUC no dicionario de dados
		cCampo := ALLTRIM(aSx3SUC[nCont][1])	// X3_CAMPO
		
		Do Case
		Case (cCampo == "UC_FILIAL")
			Replace SUC->&(cCampo) With cFilSUC
			
		Case (cCampo == "UC_ENTIDAD")
			Replace SUC->&(cCampo) With M->UC_ENTIDAD
			
		Case (cCampo == "UC_CHAVE")
			Replace SUC->&(cCampo) With M->UC_CHAVE
			
		Case (cCampo == "UC_INICIO")
			Replace SUC->&(cCampo) With IIf(!Empty(cTimeIni),cTimeIni,Time())
			
		Case (cCampo == "UC_FIM")
			Replace SUC->&(cCampo) With Time()
			
		Case (cCampo == "UC_CODENCE")
			Replace SUC->&(cCampo) With cEncerra
			
		Case (cCampo == "UC_DTENCER")
			Replace SUC->&(cCampo) With IIF(!Empty(cEncerra),MSDATE(),CTOD("  /  /  "))
			
		Case (cCampo == "UC_DIASDAT")
			Replace SUC->&(cCampo) With ( CTOD("01/01/2045") - UC_DATA )
			
		Case (cCampo == "UC_HORADAT")
			Replace SUC->&(cCampo) With 86400 - ( (VAL(Substr(cTimeIni,1,2))*3600) + ( VAL(Substr(cTimeIni,4,2))*60) + VAL(Substr(cTimeIni,7,2))  )
			
		OtherWise
			If (aSx3SUC[nCont][2] <> "V") .AND. (aSx3SUC[nCont][3])		// X3_CONTEXT e .T.
				If (SUC->(FieldPos(cCampo))  > 0)
					Replace SUC->&(cCampo) With M->&(cCampo)
				Endif
			Endif
		EndCase
		
	Next nCont
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MEMO DO MOTIVO DE ENCERRAMENTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMotivo)  // Sempre e inclusao porque so pode encerrar 1 vez
		MSMM(,TamSx3("UC_OBSMOT")[1],,cMotivo,1,,,"SUC","UC_CODMOT")
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MEMO DA OBSERVACAO            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNovo
		If !Empty(M->UC_OBS)		// Inclusao
			MSMM(,TamSx3("UC_OBS")[1],,M->UC_OBS,1,,,"SUC","UC_CODOBS")
		Endif
	Else
		If Empty(SUC->UC_CODOBS)	// Inclusao
			MSMM(,TamSx3("UC_OBS")[1],,M->UC_OBS,1,,,"SUC","UC_CODOBS")
		Else						// Alteracao
			MSMM(SUC->UC_CODOBS,TamSx3("UC_OBS")[1],,M->UC_OBS,1,,,"SUC","UC_CODOBS")
		Endif
	Endif
	
	If lTk271Auto
		If (nX := aScan(aAutoCab,{|x|AllTrim(x[1]) == "UC_CHAORIG"})) > 0
			Replace SUC->UC_CHAORIG With aAutoCab[nX][2]
		EndIf
		If (nX := aScan(aAutoCab,{|x|AllTrim(x[1]) == "UC_ITCHAOR"})) > 0
			Replace SUC->UC_ITCHAOR With aAutoCab[nX][2]
		EndIf
	EndIf
	
	DbSelectArea("SUC")
	MsUnlock()
	FkCommit()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia a gravacao dos itens do atendimento  - SUD  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cI := "00"
	For nX := 1 To Len(aCols)
		
		cI := SomaIt(cI)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existem itens que foram deletados no Atendimento atual e apaga do que foi gravado anteriormente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols[nX][Len(aHeader)+1]
			DbSelectArea( "SUD" )
			DbSetOrder(1)
			If DbSeek(cFilSUD + M->UC_CODIGO + Iif(nPosItem>0,aCols[nX][nPosItem],cI))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifico se houver integracao com o QNC cancelo as FNC geradas  na linha³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIntQNC .AND. !Empty(SUD->UD_CODFNC)
					QNCBAIXA(SUD->UD_CODFNC, SUD->UD_FNCREV)
				Endif
				Reclock("SUD",.F.)
				DbDelete()
				MsUnlock()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a linha foi apagada - percorre o SYP e apaga a descricao do MEMO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aCols[nX][nPObsExec])
					MSMM(SUD->UD_CODEXEC,TamSx3("UD_OBSEXEC")[1],NIL,aCols[nX][nPObsExec],2,NIL,NIL,"SUD","UD_CODEXEC")
				Endif
			Endif
		Endif
		
	Next nX
	
	cI := "00"
	For nY:=1 To Len(aCols)
		lGravaFNC := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a linha atual nao estiver deletada grava no SUD³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cI := SomaIt(cI)
		If ! aCols[nY][Len(aHeader)+1]
			
			//Se o item e valido grava no SUD - verifica se e novo ou nao
			cNovoItem := SomaIt(cNovoItem)
			
			DbSelectArea("SUD")
			DbSetOrder(1)
			If DbSeek(cFilSUD + M->UC_CODIGO + Iif(nPosItem>0,aCols[nY][nPosItem],cI))
				lNovo := .F.
			Else
				lNovo := .T.
			Endif
			
			If !lNovo .AND. lCompart
				
				aAreaSUC := SUC->(GetArea())
				aAtendAlt:= {}
				
				DbSelectArea("SUC")
				DbSetOrder(8)
				DbSeek(cFilSUC+SUD->UD_CODIGO+SUD->UD_ITEM)
				While !SUC->(Eof()) .AND. SUC->UC_FILIAL == cFilSUC .AND.;
						SUC->UC_CHAORIG == SUD->UD_CODIGO .AND. SUC->UC_ITCHAOR == SUD->UD_ITEM
					
					AAdd(aAtendAlt,SUC->(Recno()))
					SUC->(DbSkip())
					
				EndDo
				
				For nX := 1 to Len(aAtendAlt)
					SUC->(DbGoTo(aAtendAlt[nX]))
					RecLock("SUC",.F.)
					SUC->UC_ITCHAOR := cNovoItem
					MsUnLock()
				Next nX
				
				RestArea(aAreaSUC)
				DbSelectArea("SUD")
				
			EndIf
			
			Reclock("SUD",lNovo)
			bCampo := {|nCPO| Field(nCPO) }
			
			Replace SUD->UD_FILIAL With cFilSUD
			Replace SUD->UD_CODIGO With M->UC_CODIGO
			
			For nX := 1 To SUD->(FCount())
				
				If (EVAL(bCampo,nX) <> "UD_FILIAL") .AND. (EVAL(bCampo,nX) <> "UD_CODIGO")
					nPos := Ascan(aHeader,{|x| ALLTRIM(EVAL(bCampo,nX)) == ALLTRIM(x[2])})
					If (nPos > 0)
						If nOpc == 4 .AND. TkPosto(M->UC_OPERADO,"U0_USAMAIL") == "1" .AND. (Val(M->UC_STATUS) <> ENCERRADA)
							If AllTrim(EVAL(bCampo,nX)) == "UD_STATUS"
								AAdd(aUDStatus,{SUD->UD_STATUS, aCols[nY][nPos], lNovo, nY})
							EndIf
						EndIf
						If (aHeader[nPos][10] <> "V" .AND. aHeader[nPos][08] <> "M")
							Replace SUD->&(EVAL(bCampo,nX)) With aCols[nY][nPos]
							If EVAL(bCampo,nX) == "UD_SOLUCAO"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Caso  Haja   integracao  com  o  modulo QNC devera ser ³
								//³habilitada a  gravacao  dos dados  se  o canpo GeraFNC ³
								//³estiver  igual a "S".                                  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lIntQNC
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Caso a opcao  Gera FNC estiver  igual a  nao e  o campo  ³
									//³NumFNC  estiver preenchido nao  geraremos  a FNC         ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If Tk272vAcao(SUD->UD_SOLUCAO,1)
										If !Empty(AllTrim(SUD->UD_CODFNC))
											lGravaFNC := .F.
										Else
											lGravaFNC := .T.
										Endif
									Endif
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Caso o chamado gere um compartilhamento, prepara o array ³
								//³de chamados a serem gerados                              ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								lPerg := .F.
								If Tk272vAcao(SUD->UD_SOLUCAO,2,@lPerg,SUD->UD_ITEM)
									AAdd(aItCompart,{nY,lPerg})
								EndIf
							Endif
						Endif
					Endif
				Endif
			Next nX
			
			If lIntTEC
				If TK272GerCT(SUD->UD_SOLUCAO)
					If !Empty(SUD->UD_NSERIE) .And. AllTrim(SUC->UC_ENTIDAD) == AllTrim("SA1")
						lGravaCT := .T.
					Else
						lGravaCT := .F.
					EndIf
				EndIf
			EndIf
			
			//Verifica se a acao gera uma OS
			lGeraOs := (lCpoOS .AND. (Posicione("SUQ",1,cFilSUQ+SUD->UD_SOLUCAO,"UQ_GERAOS") == "1"))
			
			Replace SUD->UD_ITEM   With cNovoItem
			
			MsUnlock()
			Dbcommit()
			
			TK271GrAG5( nY )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona uma linha ao chamado que será criado futuramente.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGravaCT
				If !Empty(SUD->UD_NSERIE)
					aAdd( aItensAB2,	{																										;
						{ "AB2_ITEM"	, StrZero(nY,TamSX3("AB2_ITEM")[1])									, Nil	}	,;
						{ "AB2_TIPO"	, "1"																	, Nil	}	,;
						{ "AB2_CLASSI"	, Posicione("SUQ",1,cFilSUQ + SUD->UD_SOLUCAO, "UQ_TECCLAS")	, Nil	}	,;
						{ "AB2_CODPRO"	, SUD->UD_PRODUTO														, Nil	}	,;
						{ "AB2_NUMSER"	, SUD->UD_NSERIE														, Nil	}	,;
						{ "AB2_CODPRB"	, Posicione("SUQ",1,cFilSUQ + SUD->UD_SOLUCAO, "UQ_TECOCOR")	, Nil	}	;
						})
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona uma linha aos itens da Ordem de Servico³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGeraOS .AND. !Empty(SUD->UD_NSERIE) .AND. Empty(SUD->UD_NUMOS)
				AAdd(aItensAB7,{	{"AB7_ITEM"		, StrZero(nY,TamSX3("AB2_ITEM")[1])								, Nil	},;
					{"AB7_TIPO"		, "1"																, Nil	},;
					{"AB7_CODPRO"	, SUD->UD_PRODUTO							 						, Nil	},;
					{"AB7_NUMSER"	, SUD->UD_NSERIE				   									, Nil	},;
					{"AB7_CODPRB"	, Posicione("SUQ",1,cFilSUQ+SUD->UD_SOLUCAO	, "UQ_TECOCOR")	, Nil	}})
				AAdd(aItemOS,{SUD->(Recno()),StrZero(nY,TamSX3("AB2_ITEM")[1])})
			EndIf
			
			If lGravaFNC
				If Empty(AllTrim(SUD->UD_CODFNC))
					If !Empty(SUD->UD_OPERADO)
						aUser := aClone(QNCxUser(SUD->UD_OPERADO))
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Realiza integracao com o QNC         						 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCpoQNC := {}
					Aadd(aCpoQNC,{"QI2_NCHAMA"	,SUD->UD_CODIGO})
					Aadd(aCpoQNC,{"QI2_TPFIC" 	,"1"})
					Aadd(aCpoQNC,{"QI2_ORIGEM"	,"TMK"})
					Aadd(aCpoQNC,{"QI2_DESCR"	,STR0052+AllTrim(SUD->UD_CODIGO)+" - "+SUD->UD_ITEM+"/"+SUD->UD_ASSUNTO}) //"ATENDIMENTO - ITEM/ASSUNTO: "
					Aadd(aCpoQNC,{"QI2_MEMO1"	,IIF(!EMPTY(SUD->UD_OBS),STR0053+CHR(13)+CHR(10)+SUD->UD_OBS+; 			  //"OBSERVACAO: "
					IIF(!EMPTY(aCols[nY][nPObsExec]),CHR(13)+CHR(10)+STR0057+CHR(13)+CHR(10)+aCols[nY][nPObsExec],""),;  //"COMPLEMENTO: "
					IIF(!EMPTY(aCols[nY][nPObsExec]),CHR(13)+CHR(10)+STR0057+CHR(13)+CHR(10)+aCols[nY][nPObsExec],""))}) //"COMPLEMENTO: "
					If SUC->UC_ENTIDAD == "SA1"
						Aadd(aCpoQNC,{"QI2_CODCLI"	, SUBSTR(SUC->UC_CHAVE,1,TamSX3("A1_COD")[1])})
						Aadd(aCpoQNC,{"QI2_LOJCLI"	, SUBSTR(SUC->UC_CHAVE,TamSX3("A1_COD")[1]+1,TamSX3("A1_LOJA")[1])})
					Endif
					
					Aadd(aCpoQNC,{"QI2_CODPRO"	, SUD->UD_PRODUTO})
					If !Empty(SUD->UD_OPERADO) .AND. !(aUser[2] $ "ZZZZZZ")
						Aadd(aCpoQNC,{"QI2_FILRES"	, aUser[1]})
						Aadd(aCpoQNC,{"QI2_MATRES"	, aUser[2]})
					Endif
					
					DbSelectArea("SB1")
					DbSetOrder(1)
					If 	DbSeek(cFilSB1+SUD->UD_PRODUTO)
						If Empty(SB1->B1_CODQAD)
							aAdd(aCpoQNC, {"QI2_DESDEP", cOpQNCDDES })
						Else
							aAdd(aCpoQNC, {"QI2_DESDEP", SB1->B1_CODQAD })
						EndIf
						
						aAdd(aCpoQNC, {"QI2_FILDEP", cFilAnt })
					Else
						aAdd(aCpoQNC, {"QI2_DESDEP", cOpQNCDDES })
					EndIf
					
					If !lTK272QNC
						aRetQNC := QNCGERA(1,aCpoQNC)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava o Codigo+Revisao da NC								 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("SUD",.F.)
						Replace SUD->UD_CODFNC With aRetQNC[2] //Codigo da Nao-conformidade
						Replace SUD->UD_FNCREV With aRetQNC[3] //Revisao da Nao-conformidade
						Replace SUD->UD_STATUS With Str(ABERTA,1)		  //Forco o assunto como Pendente pois existe  uma  FNC sem baixa
						MsUnLock()
					Else
						aRetQNC := ExecBlock("TK272QNC",.f.,.f.,{aCpoQNC,"I"})
					EndIf
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MEMO do Complemento           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lNovo
				If !Empty(aCols[nY][nPObsExec])   //Inclusao
					MSMM(,TamSx3("UD_OBSEXEC")[1],,aCols[nY][nPObsExec],1,,,"SUD","UD_CODEXEC")
				Endif
				If nPObsOri > 0 .AND. !Empty(aCols[nY][nPObsOri])
					MSMM(,TamSx3("UD_COMPORI")[1],,aCols[nY][nPObsOri],1,,,"SUD","UD_CODCORI")
				EndIf
			Else
				If Empty(SUD->UD_CODEXEC)	// Inclusao
					MSMM(,TamSx3("UD_OBSEXEC")[1],,aCols[nY][nPObsExec],1,,,"SUD","UD_CODEXEC")
				Else						// Alteracao
					MSMM(SUD->UD_CODEXEC,TamSx3("UD_OBSEXEC")[1],,aCols[nY][nPObsExec],1,,,"SUD","UD_CODEXEC")
				Endif
				
				If Empty(SUD->UD_CODEXEC)	// Inclusao
					MSMM(,TamSx3("UD_COMPORI")[1],,aCols[nY][nPObsOri],1,,,"SUD","UD_CODCORI")
				Else						// Alteracao
					MSMM(SUD->UD_CODCORI,TamSx3("UD_COMPORI")[1],,aCols[nY][nPObsOri],1,,,"SUD","UD_CODCORI")
				EndIf
				
			Endif
		Endif
		
	Next nY
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria o chamado técnico com os itens apontados no aItensAB2.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItensAB2) > 0
		DbSelectArea( "AB1" )
		DbSetOrder( 5 )
		If !DbSeek( cFilAB1 + SUC->UC_CODIGO )
			aCabAB1 :=	{																								;
				{ "AB1_EMISSA"	, dDataBase																	, Nil	}	,;
				{ "AB1_CODCLI"	, SubStr( SUC->UC_CHAVE, 1, TamSX3("A1_COD")[1] )							, Nil	}	,;
				{ "AB1_LOJA"	, SubStr( SUC->UC_CHAVE, TamSX3("A1_COD")[1] + 1, TamSX3("A1_LOJA")[1])	, Nil	}	,;
				{ "AB1_NUMTMK"	, SUC->UC_CODIGO															, Nil	}	;
				}
			
			TECA300( ,, aCabAB1, aItensAB2, 3 )
			
			If !lMsErroAuto
				ConfirmSX8()
			Else
				RollBackSx8()
				MostraErro()
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria a ordem de serviço om os itens apontados no aItensAB7.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItensAB7) > 0
		
		aCabAB6 :=	{	{ "AB6_CODCLI"	, SubStr( SUC->UC_CHAVE, 1, TamSX3("A1_COD")[1] )						, Nil	}	,;
			{ "AB6_LOJA"	, SubStr( SUC->UC_CHAVE, TamSX3("A1_COD")[1]+1, TamSX3("A1_LOJA")[1])	, Nil	}	,;
			{ "AB6_EMISSA"	, dDataBase																, Nil	}	,;
			{ "AB6_HORA"  	, Time()																, Nil	}	,;
			{ "AB6_CONPAG"	, SuperGetMv("MV_CONDPAD")												, Nil	}	}
		
		TECA450(,aCabAB6,aItensAB7,,3,@cNumOs)
		
		If !lMsErroAuto
			ConfirmSX8()
			For nY := 1 to Len(aItemOS)
				SUD->(DbGoTo(aItemOS[nY,1]))
				RecLock("SUD",.F.)
				SUD->UD_NUMOS := cNumOs
				MsUnLock()
			Next nY
		Else
			RollBackSx8()
			MostraErro()
		EndIf
		
	EndIf
	
	lRet := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia a gravacao do Historico do prospect e do cliente da data, da observa‡„o e da origem (TMK)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case (M->UC_ENTIDAD == "SUS")
		DbSelectArea("SUS")
		DbSetOrder(1)
		If DbSeek(cFilSUS + M->UC_CHAVE)
			Reclock("SUS",.F.)
			If Empty(SUS->US_CODHIST)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se ainda n„o existe historico gravado para esse prospect fa‡o uma inclus„o³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//Visualizacao
				cHistmk := DTOC(M->UC_DATA)+STR0025+CRLF //"-TeleMarketing-"
				cHistmk += IIF(Empty(M->UC_OBS),"",M->UC_OBS + CRLF)
				MSMM(,TamSx3("US_HISTMK")[1],,cHisTmk,1,,,"SUS","US_CODHIST") // O nOpc do MSMM para inclusao tem que ser <> 3
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se ja existe historico atualizo com o SA1+SUC atual  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//Visualizacao
				cHisTmk	+= MSMM(SUS->US_CODHIST,35)//Carrego o historico acumulado da entidade antes de inserir o novo
				cHisTmk += DTOC(M->UC_DATA)+STR0025+CRLF //"-TeleMarketing-"
				cHisTmk += IIF(Empty(M->UC_OBS),"",M->UC_OBS + CRLF)
				MSMM(SUS->US_CODHIST,TamSx3("US_HISTMK")[1],,cHisTmk,1,,,"SUS","US_CODHIST")
			Endif
			MsUnlock()
			DbCommit()
		Endif
		
		If lNewOport
			lRet := Tk272OpUsu("SUS", M->UC_CODIGO)
			If !lRet
				DisarmTransaction()
			Endif
		Endif
		lProspect  := .T.
		
	Case (M->UC_ENTIDAD == "SA1")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravo no hist¢rio do cliente o contato, a data, a observa‡„o e a origem(TMK)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(cFilSA1 + M->UC_CHAVE)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se eh permitida a gravacao do hist. do cliente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGravaHist
				If Empty(SA1->A1_CODHIST)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se ainda n„o existe historico gravado para esse cliente fa‡o uma inclus„o ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//Visualizacao
					cHisTmk := DTOC(M->UC_DATA)+STR0025+CRLF //"-TeleMarketing-"
					cHisTmk += IIF(Empty(M->UC_OBS),"",M->UC_OBS + CRLF)
					MSMM(,TamSx3("A1_HISTMK")[1],,cHisTmk,1,,,"SA1","A1_CODHIST") // O nOpc do MSMM para inclusao tem que ser <> 3
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se ja existe historico atualizo com o SA1+SUC atual  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//Visualizacao
					cHisTmk += DTOC(M->UC_DATA)+STR0025+CRLF //"-TeleMarketing-"
					cHisTmk += IIF(Empty(M->UC_OBS),"",M->UC_OBS + CRLF)
					MSMM(SA1->A1_CODHIST,TamSx3("A1_HISTMK")[1],,cHisTmk,1,,,"SA1","A1_CODHIST",,.T.)
				Endif
				MsUnlock()
				Dbcommit()
			Endif
		Endif
		
		If lNewOport
			lRet := Tk272OpUsu("SA1", M->UC_CODIGO)
			If !lRet
				DisarmTransaction()
			Endif
		Endif
		
	Case (M->UC_ENTIDAD == "ACH")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define se o suspect deve ser apagado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpCnvSus == 1
			lCnvACH := .T.
		ElseIf nOpCnvSus == 3
			lCnvACH	:= TmkOk(STR0047)  //"Confirma a conversão desse Suspect em um novo Prospect?"
			If lCnvACH
				If lUsuCRM
					cCodVend := Tk272RVend()
				Else
					cCodVend := cRetCodUsr
				Endif
			Else
				lProspect := .F.
			Endif
		Else
			lCnvACH	:= .F.
		EndIf
		
		If lCnvACH
			
			lGrava := .T.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava informacoes do ACH para o cadastro de Prospect	                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACH")
			DbSetOrder(1)
			If DbSeek(cFilACH + SUBSTR(Alltrim(M->UC_CHAVE),1,TamSX3("ACH_CODIGO")[1]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se existir um PROSPECT ja cadastradado com o mesmo CGC NAO GRAVA O  SUSPECT         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(ACH->ACH_CGC)
					
					//"O CNPJ deste Suspect está em branco. Confirma a gravação ? Sem essa informação não será possivel verificar se esse Suspect já existe nos cadastros de Cliente e Prospect"
					If !TmkOk(STR0042)
						lGrava := .F.
					Endif
					
				Else
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se existir um prospect com esse CGC nao grava no PROSPECT ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SUS")
					DbSetOrder(4)
					If DbSeek(cFilSUS + Alltrim(ACH->ACH_CGC))
						Aviso(STR0043,STR0044, {"OK"}) //"Atenção", "Este CNPJ ja existe no cadastro de Prospect", "OK"
						lGrava := .F.
						
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se existir um cliente com esse CGC nao grava no PROSPECT  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SA1")
						DbSetOrder(3)
						If DbSeek(cFilSA1 + Alltrim(ACH->ACH_CGC))
							// "Atenção", "Este CNPJ ja existe no cadastro de Clientes"
							Aviso(STR0043,STR0045, {"OK"})
							lGrava := .F.
						Endif
					Endif
					
				Endif
			Endif
		Else
			lGrava := .F.
		Endif
		
		If lGrava
			FWMsgRun(/*oComponent*/,{|| lGrava := TK341GrvSTP(ACH->ACH_CODIGO,ACH->ACH_LOJA,@lProspect , cCodVend, @aNewSUS ) },,STR0193)	//"Qualificando o Suspect..."
			
			//Realizar posiconamento no prospect para achar vendedor
			DBSelectArea("SUS") 
			DBSetOrder(1)
			If Len(aNewSUS) > 1 .And. DBSeek(xFilial("SUS")+aNewSUS[1]+aNewSUS[2])
				cCodVend := US_VEND	
			Endif 
			
			If lGrava
				
				//Gera oportunidade rapida para o novo prospect
				If lNewOport .And. !Empty(aNewSUS) .And. !Empty(cCodVend)
				
					lRet := Tk272OpUsu("SUS", M->UC_CODIGO)	
					If !lRet
						DisarmTransaction()
					Endif
					
				EndIf
				
				If lRet
					// "Atenção","Todos os atendimentos do antigo Suspect serão encerrados",{"OK"})
					Aviso(STR0043,STR0048,{"OK"})
					
					nPosSUC := Recno()
					DbSelectArea("SUC")
					DbSetOrder(2)
					If DbSeek(cFilSUC+"ACH"+M->UC_CHAVE)
						While (!SUC->(Eof()))					.AND. ;
								(cFilSUC == SUC->UC_FILIAL)		.AND. ;
								(SUC->UC_ENTIDAD == "ACH")		.AND. ;
								(TRIM(SUC->UC_CHAVE) == TRIM(M->UC_CHAVE))
							
							Reclock("SUC",.F.)
							Replace UC_STATUS With "3"
							MSMM(,TamSx3("UC_OBSMOT")[1],,STR0049,1,,,"SUC","UC_CODMOT") //"Atendimento Encerrado na conversão do  Suspect para Prospect"
							MsUnlock()
							FkCommit()
							
							SUC->(DbSkip())
						End
					Endif
					DbGoto(nPosSUC)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Define se o suspect deve ser apagado³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpDelAch == 1
						lDelACH := .T.
					ElseIf nOpDelAch == 3
						lDelACH	:= TmkOk(STR0046)  //"Deseja apagar esse Suspect do cadastro ?"
					Else
						lDelACH	:= .F.
					EndIf
					If lDelACH
						Reclock( "ACH" ,.F.,.T.)
						DbDelete()
						MsUnlock()
					Endif
					
				EndIf
			Endif
			
		EndIf
		
	EndCase
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a data do ultimo atendimento no cadastro de contatos Para que possam ser geradas listas por ³
		//³ultimo contato todas as interacoes devem atualizar a data do ultimo contato no cadastro de Contatos. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->UC_CODCONT)
			DbSelectArea("SU5")
			DbSetOrder(1)
			If DbSeek(cFilSU5 + M->UC_CODCONT)
				Reclock("SU5",.F.)
				Replace SU5->U5_ULTCONT With M->UC_DATA
				MsUnlock()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega dados do cadastro do contato para colocar no e-mail - quando existe envio de e-mail³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDescCnt:= SU5->U5_CONTAT
				cCidade	:= SU5->U5_MUN
				cEst	:= SU5->U5_EST
				cTelRes := SU5->U5_FCOM1
				cTelCom1:= SU5->U5_FONE
				cTelCel := SU5->U5_CELULAR
				cEnd	:= SU5->U5_END
				cDDD	:= SU5->U5_DDD
				cBairro := SU5->U5_BAIRRO
			Endif
		Endif
	Endif
	
END TRANSACTION

If Len(aItCompart) > 0
	
	For nY := 1 to Len(aSx3SUC)
		If 	(aSx3SUC[nY][2] <> "V") .AND. (aSx3SUC[nY][3]) .AND.;
				!(AllTrim(aSx3SUC[nY][1]) $ "UC_FILIAL/UC_CODIGO/UC_DATA/UC_OPERADO/UC_STATUS") .AND.;
				!Empty(M->&(aSx3SUC[nY][1]))
			AAdd(aCabCmp,{aSx3SUC[nY][1], M->&(aSx3SUC[nY][1]), Nil })
		EndIf
	Next nY
	
	AAdd(aCabCmp,{"UC_DATA"		, dDataBase		,Nil})
	AAdd(aCabCmp,{"UC_OPERADO"	, ""			,Nil})
	AAdd(aCabCmp,{"UC_STATUS"	, M->UC_STATUS	,Nil})
	AAdd(aCabCmp,{"UC_ENTIDAD"	, M->UC_ENTIDAD	,Nil})
	AAdd(aCabCmp,{"UC_CHAVE"	, M->UC_CHAVE	,Nil})
	
	//Se ja trata-se de um chamado compartilhado, aponta para o mesmo chamado pai
	If ALTERA .AND. !Empty(SUC->UC_CHAORIG)
		AAdd(aCabCmp,{"UC_CHAORIG"	, SUC->UC_CHAORIG	,Nil})
	Else
		AAdd(aCabCmp,{"UC_CHAORIG"	, M->UC_CODIGO		,Nil})
	EndIf
	
	AAdd(aCabCmp,{"UC_ITCHAOR"	, ""			,Nil})
	
EndIf

For nX := 1 to Len(aItCompart)
	
	If aItCompart[nX,2] .AND. !MsgYesNo(STR0069 + cValToChar(aItCompart[nX,1]) + "?")
		Loop
	EndIf
	
	aItemCmp:= {}
	
	For nY := 1 to Len(aHeader)
		If aHeader[nY,10] <> "V" .AND. aHeader[nY,8] <> "M" .AND. !Empty(aCols[aItCompart[nX,1],nY]) .AND.;
				!(AllTrim(aHeader[nY,2]) $ "UD_SOLUCAO/UD_OPERADO")
			AAdd(aItemCmp,{aHeader[nY,2],aCols[aItCompart[nX,1],nY],Nil})
		EndIf
		If AllTrim(aHeader[nY,2]) == "UD_OBSEXEC" .AND. !Empty(aCols[aItCompart[nX,1],nY])
			AAdd(aItemCmp,{"UD_COMPORI",aCols[aItCompart[nX,1],nY],Nil})
			AAdd(aItemCmp,{"UD_OBSEXEC",aCols[aItCompart[nX,1],nY],Nil})
		EndIf
	Next nY
	
	lMsErroAuto	:= .F.
	
	SU7->(DbSetOrder(4))
	SU7->(DbSeek(cFilSU7 + aCols[aItCompart[nX,1],aScan(aHeader,{|x|AllTrim(x[2]) == "UD_OPERADO"})] ))
	
	cEmail := AllTrim(UsrRetMail(SU7->U7_CODUSU))
	
	aCabCmp[aScan(aCabCmp,{|x|x[1] == "UC_OPERADO" })][2] := SU7->U7_COD
	
	//Se ja trata-se de um chamado compartilhado, aponta para o mesmo chamado pai
	If ALTERA .AND. !Empty(SUC->UC_ITCHAOR)
		aCabCmp[aScan(aCabCmp,{|x|x[1] == "UC_ITCHAOR" })][2] := SUC->UC_ITCHAOR
	Else
		aCabCmp[aScan(aCabCmp,{|x|x[1] == "UC_ITCHAOR" })][2] := StrZero(aItCompart[nX,1],2)
	EndIf
	
	TMKA271(aCabCmp,{aItemCmp},3,"1")
	
	If lMsErroAuto
		MostraErro()
	Else
		If !Empty(cEmail) .AND. !Empty(cModeloWF)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envia email notificando o usuario que recebeu o compartilhamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWFTemplate := WFTemplate():New()
			If oWFTemplate:load(cModeloWF)
				oWFTemplate:cbTo := "'" + cEmail + "'"
				oWFInfo := oWFTemplate:buildWF(cRetCodUsr)
				oWFInfo:start()
				If oWFInfo:wfType == 2 //WF exige retorno
					oWFInfo:save()
				EndIf
			EndIf
			oWFTemplate := Nil
			oWFInfo		:= Nil
		EndIf
	EndIf
	
Next nX

RestArea(aAreaSU7)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia o envio de email para os usuarios selecionados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	Tk272EnvTmk(cTimeIni	,cTipSta	,cCidade	,cEst		,;
		cTelRes 	,cTelCom1	,cEnd		,cDescCnt	,;
		nOpc		,aSx3SUC	,cDDD		,cEncerra	,;
		cMotivo		,cBairro	,aParScript	,cTelCel	,;
		aUDStatus)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Execucao do P.E. TMKGRAVA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKGRAVA
	U_TMKGRAVA(M->UC_PENDENT,M->UC_CODIGO,aCampos,nOpc)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o motivo do encerramento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	cEncerra := ""
	cMotivo	:= ""
Endif

cCodVend	:= ""
lUsuCRM		:= .F.
lNewOport	:= .F.
lProspect  	:= .F. //Ao alterar de suspect para prospect, vira True. Para envio do Email
lClienteM  	:= .F. //Caso seja gerada uma atividade do tipo email para um cliente
	
RestArea(aAreaSUQ)
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK272DelSU4  ºAutor³Vendas Clientes    º Data ³  28/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Apaga a lista de pendencia gerada pelo atendimento          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TeleMarketing                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo da lista                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK272DelSU4(cCodLig)
	Local aArea := GetArea()		//Salva a area atual
	
	DbSelectArea("SU4")
	DbSetOrder(4) 					// Pesquisar pela descricao temporariamente.
	If DbSeek(xFilial("SU4")+cCodLig)
		RecLock("SU4",.F.)
		Replace SU4->U4_STATUS With "2"      	// Status da Lista 1=Pendente 2=Encerrada
		MsUnlock()
		
		DbSelectArea("SU6")
		DbSetOrder(1)
		If DbSeek(xFilial("SU6")+SU4->U4_LISTA)
			RecLock("SU6",.F.)
			Replace SU6->U6_STATUS With	"2"		//1=Nao Enviado 2=Enviado
			MsUnlock()
		Endif
		
		DbCommit()
	Endif
	
	RestArea(aArea)
	
Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271EnvTmk  ³ Autor ³ Vendas Clientes    ³ Data ³ 04/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc      ³Executa o envio de email para os usuarios selecionados no   ³±±
±±³          ³atendimento. Todos recebem a mesma copia para que todos     ³±±
±±³          ³tenham a mesma informacao sobre o atendimento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TELEMARKETING        									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC01 - Hora inicial                                       ³±±
±±³          ³ExpC02 - Status do atendimento                              ³±±
±±³          ³ExpC03 - Cidade do contato                                  ³±±
±±³          ³ExpC04 - Estaado do contato                                 ³±±
±±³          ³ExpC05 - Telefone residencial do contato                    ³±±
±±³          ³ExpC06 - Telefone comercial do contato                      ³±±
±±³          ³ExpC07 - Endereco do contato                                ³±±
±±³          ³ExpC08 - Contato                                            ³±±
±±³          ³ExpN09 - Tipo da operacao atual                             ³±±
±±³          ³ExpA10 - Campos do SUC do dicinario de dados                ³±±
±±³          ³ExpC11 - DDD do contato                                     ³±±
±±³          ³ExpC12 - Motivo do encerramento                             ³±±
±±³          ³ExpC13 - Descricao do encerramento                          ³±±
±±³          ³ExpC14 - Bairro do contato                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Tk272EnvTmk(cTimeIni, cTipSta,  cCidade,    cEst,;
                            cTelRes,  cTelCom1, cEnd,       cDescCnt,;
                            nOpc,     aSx3SUC,  cDDD,       cEncerra,;
                            cMotivo,  cBairro,  aParScript, cTelCel,;
                            aUDStatus)

Local aCabecalho	:= {}																// Array que carrega a descricao do atendimento
Local aItens		:= {}																// Array para compor os itens do atendimento
Local nLinhas		:= 0																// Percorre as linhas do acols para montar a descricao
Local cMensagem	:= ""																// Monta a descricao do atendimento
Local aSend		:= {}																// Monta um array com os destinatarios de cada linha do acols
Local cEmail		:= ""																// email do remetente
Local cAssunto	:= ""																// Assunto do email
Local nCont		:= 0																// Contador

Local nPAssunto	:= aPosicoes[1][2]												// Assunto
Local nPDescAss	:= aPosicoes[2][2]												// Descricao do Assunto
Local nPProd		:= aPosicoes[3][2]												// Produto
Local nPDescPro	:= aPosicoes[4][2]												// Descricao do produto
Local nPOcorren	:= aPosicoes[5][2]												// Ocorrencia
Local nPDescOco	:= aPosicoes[6][2]												// Descricao da Ocorrencia
Local nPCodOpe 	:= aPosicoes[7][2]												// Codigo do Operador
Local nPDescOpe	:= aPosicoes[8][2]												// Descricao do Operador
Local nPData		:= aPosicoes[9][2]												// Data
Local nPAcao   	:= aPosicoes[10][2]												// Acao
Local nPDescAca	:= aPosicoes[11][2]												// Descricao da Acao
Local nPObs		:= aPosicoes[12][2]												// Observacao
Local nPStatus	:= aPosicoes[13][2]												// Status
Local nPDtExec	:= aPosicoes[14][2]												// Data de Execucao
Local nPObsExec	:= aPosicoes[15][2]												// Observacao da Execucao

Local cFilSU7		:= xFilial("SU7")

Local cAccount	:= IIF( SuperGetMv("MV_RELAUTH"),SuperGetMv("MV_RELAUSR"),Posicione("SU7",1,cFilSU7 + M->UC_OPERADO,"U7_CONTA")) // Conta do remetente
Local cPassword	:= IIF( SuperGetMv("MV_RELAUTH"),SuperGetMv("MV_RELAPSW"),Posicione("SU7",1,cFilSU7 + M->UC_OPERADO,"U7_SENHA")	)// Senha do remetente
Local cUsaEmail	:= TkPosto(M->UC_OPERADO,"U0_USAMAIL")							// Validacao se o operador pode mandar email

Local aStatus 	:= IIF(nPStatus > 0,TkSX3Box("UD_STATUS"),{})					// Array com o conteudo do campo UD_STATUS
Local cStatus		:= ""
Local nPUDStatus	:= 0
Local lTK272Acc	:= ExistBlock("TK272ACC")

Local cRelServ	:= ""
Local cUsrMail	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³trata antes de atribuir³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aStatus) > 0
	cStatus := aStatus[1]
Endif

// Captur	a a senha do operador sem criptografia
If !Empty(cPassword) .And. !SuperGetMv("MV_RELAUTH")
	cPassword := Embaralha(cPassword,1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o operador pode mandar email para os clientes   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cUsaEmail == "1"  //Sim
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o ARRAY  com o cabecalho do atendimento de Telemarketing ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aCabecalho, M->UC_CODIGO)																																// Atendimento                    -01
	Aadd(aCabecalho, M->UC_CHAVE + "-" + M->UC_DESCCHA)																										// Entidade                       -02
	Aadd(aCabecalho, cDescCnt)																																	// Contato                        -03
	Aadd(aCabecalho, cCidade + "-" + cEst)																														// Cidade - Estado                -04
	Aadd(aCabecalho, cEnd)																																		// Endereco                       -05
	Aadd(aCabecalho, "(" + AllTrim(Transform(cDDD,PesqPict("SU5","U5_DDD"))) + ") " + Transform(cTelRes ,PesqPict("SU5","U5_FONE")) + " / " +;
	                 "(" + AllTrim(Transform(cDDD,PesqPict("SU5","U5_DDD"))) + ") " + Transform(cTelCom1,PesqPict("SU5","U5_FCOM1")) + " / " +;
	                 "(" + AllTrim(Transform(cDDD,PesqPict("SU5","U5_DDD"))) + ") " + Transform(cTelCel ,PesqPict("SU5","U5_CELULAR")))			// Telefone Resid/Comer e Celular -06
	Aadd(aCabecalho, M->UC_DATA)																																// Data da ligacao                -07
	Aadd(aCabecalho, cTimeIni)																																	// Hora inicial                   -08
	Aadd(aCabecalho, M->UC_OPERADO + "-" + M->UC_DESCOPE)																									// Codigo - Operador              -09
	Aadd(aCabecalho, M->UC_DESCTIP)																																// Tipo de comunicacao            -10
	Aadd(aCabecalho, cTipSta)																																	// Status                         -11
	Aadd(aCabecalho, M->UC_MIDIA + "-" + M->UC_DESCMID)																										// Midia                          -12
	Aadd(aCabecalho, M->UC_OBS)																																	// Observacao TMK                 -13
	Aadd(aCabecalho, cBairro)																																	// Bairro                         -14
	If Val(M->UC_STATUS) == ENCERRADA
		Aadd(aCabecalho, cEncerra + " - " + Posicione("SUN",1,xFilial("SUN") + cEncerra,"UN_DESC"))													// Motivo do encerramento         -15
		Aadd(aCabecalho, cMotivo)																																// Descricao do encerramento      -16
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o ARRAY  com os itens do atendimento do Telemarketing 	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLinhas := 1 TO len(aCols)

		If !(aCols[nLinhas][Len(aHeader) + 1])	// Se a linha nao estiver apagada.
			If !Empty(aCols[nLinhas][nPCodOpe])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento do Box do campo UD_STATUS, pois o inicilizador padrao³
				//³nao esta sendo executado (TKCONFIG()).	    				   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Val(aCols[nLinhas][nPStatus]) == 0 .OR. Val(aCols[nLinhas][nPStatus]) > Len(aStatus)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Trata antes de Atribuir³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aStatus) > 0
						cStatus := aStatus[1]
					Endif
				Else
					cStatus := aStatus[Val(aCols[nLinhas][nPStatus])]
				Endif
				Aadd(aItens,{aCols[nLinhas][nPAssunto],;			// 01- Assunto
				             aCols[nLinhas][nPDescAss],;			// 02- Descricao do Assunto
				             aCols[nLinhas][nPProd],;				// 03- Produto
				             aCols[nLinhas][nPDescPro],;			// 04- Descricao do Produto
				             aCols[nLinhas][nPOcorren],;			// 05- Ocorrencia
				             aCols[nLinhas][nPDescOco],;			// 06- Descricao da Ocorrencia
				             aCols[nLinhas][nPAcao],;				// 07- Acao
				             aCols[nLinhas][nPDescAca],;			// 08- Descricao da Acao
				             aCols[nLinhas][nPCodOpe],;			// 09- Codigo do Operador
				             aCols[nLinhas][nPDescOpe],;			// 10- Descricao do Operador
				             DTOC(aCols[nLinhas][nPData]),;		// 11- Data
				             aCols[nLinhas][nPObs],;			  	// 12- Observacao
				             cStatus,;								// 13- Status
				             DTOC(aCols[nLinhas][nPDtExec]),;		// 14- Data de Execucao
				             aCols[nLinhas][nPObsExec]})			// 15- Memo da Execucao
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o ARRAY para o numero de usuarios que vao receber³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aUDStatus) <> 0 .AND. ( ( nPUDStatus := aScan(aUDStatus,{|x| x[04] == nLinhas}) ) > 0 ) .AND. !aUDStatus[nPUDStatus][3]
					If aUDStatus[nPUDStatus][2] == "1" .OR. (aUDStatus[nPUDStatus][2] == "2" .AND. aUDStatus[nPUDStatus][1] <> aUDStatus[nPUDStatus][2])
						cEmail	:= UsrRetMail(aCols[nLinhas][nPCodOpe]) + ";"
					EndIf
				Else
					cEmail		:= UsrRetMail(aCols[nLinhas][nPCodOpe]) + ";"
				EndIf
					
				cAssunto := STR0006 + " " + M->UC_CODIGO + " " + STR0026 //"Atendimento"###"realizado pelo CALL CENTER"
					
				If (At("@", cEmail) > 0)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³So serao somados os e-mails diferentes.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (aScan(aSend,{|x| AllTrim(x[1]) == Alltrim(cEmail)}) == 0 )
						Aadd(aSend,{cEmail, cAssunto, "", ""})
					Endif
				Endif
					
			Endif
		Endif
			
	Next nLinhas
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega a conta e a senha do email do usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aSend) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para permitir a alteração da conta e senha do usuário. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTK272Acc
			aRet := ExecBlock("TK272ACC",.F.,.F.,{M->UC_OPERADO})
			If ValType(aRet) == "A"
				cAccount  := aRet[1]
				cPassword := aRet[2]
			EndIf
		EndIf
			
		If TkAccount(@cAccount, @cPassword)
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o corpo do E-mail                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Tk272Body(@cMensagem, aCabecalho, aItens, nOpc, aSx3SUC, aParScript)
				
			For nCont := 1 TO Len(aSend)
				aSend[nCont][MENSAGEM] := cMensagem
			Next nCont
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envio de E-mail³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRelServ	:= SuperGetMV("MV_RELSERV")
			cUsrMail	:= UsrRetMail(__cUserID)
			For nCont := 1 To Len(aSend)
				//"Enviando E-Mail para as acoes..."
				MsgRun(STR0027,"",; //"Enviando E-Mail para as acoes..."
				       {|| lSend := TkSendMail(cAccount, cPassword, cRelServ, cUsrMail,;
				                               aSend[nCont][EMAIL], aSend[nCont][ASSUNTO], aSend[nCont][MENSAGEM], aSend[nCont][ANEXO])})
			Next nCont
		Endif
	FATPDLogUser("TK272ENVTM")
	Endif
Endif
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK272Body ºAutor  ³Vendas Clientes     º Data ³  25/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o corpo do e-mail em HTML para a rotina de            º±±
±±º          ³Telemarketing                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEMARKETING                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Mensagem para envio no e-mail                       º±±
±±º          ³ExpA2 - Elementos do cabecalho do atendimento               º±±
±±º          ³ExpA3 - Elementos dos itens do atendimento                  º±±
±±º          ³ExpN4 - Tipo da operacao                                    º±±
±±º          ³ExpA5 - Campos do SUC do dicionario de dados                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk272Body(	cMensagem	,aCabecalho	,aItens		,nOpc		,;
		aSx3SUC		,aParScript		)
	
	Local nCont  		:= 0			// Contador
	Local cAtend		:= ""			// Descricao do campo "UC_CODIGO"
	Local cCliente		:= ""			// Descricao do campo "UC_CHAVE"
	Local cContato		:= ""			// Descricao do campo "UC_CODCONT"
	Local cData			:= ""			// Descricao do campo "UC_DATA"
	Local cHoraIni		:= ""			// Descricao do campo "UC_HRPEND"
	Local cOperador		:= ""			// Descricao do campo "UC_OPERADO"
	Local cComunica 	:= ""			// Descricao do campo "UC_TIPO"
	Local cStatusSUC	:= ""			// Descricao do campo "UC_STATUS"
	Local cMotEnc		:= STR0061		// "Motivo do encerramento"
	Local cDesEnc		:= STR0062		// "Descrição do encerramento"
	Local cMidia        := ""			// Descricao do campo "UC_MIDIA"
	Local cObsSUC		:= ""			// Observacao do atendimento
	Local cItem			:= ""			// Descricao do campo "UD_ITEM"
	Local cAssunto		:= ""			// Descricao do campo "UD_ASSUNTO"
	Local cProduto		:= ""			// Descricao do campo "UD_PRODUTO"
	Local cOcorren		:= ""			// Descricao do campo "UD_OCORREN"
	Local cAcao			:= ""			// Descricao do campo "UD_SOLUCAO"
	Local cResp			:= ""			// Descricao do campo "UD_OPERADO"
	Local cDataAcao	    := ""			// Descricao do campo "UD_DATA"
	Local cObsSUD       := ""			// Descricao do campo "UD_OBS"
	Local cStatusSUD    := ""			// Descricao do campo "UD_STATUS"
	Local cDataExec	    := ""			// Descricao do campo "UD_DTEXEC"
	Local cCompl	    := ""			// Descricao do campo "UD_OBSEXEC"
	Local lTK272HTM		:= ExistBlock("TK272HTM")
	Local cTiposTels	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa no SX3 qual a descricao dos campos, caso o usuario tenha alterado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := Ascan(aSx3SUC,{|x| x[4] $ "UC_CODIGO"})
	If (nPos > 0)
		cAtend	:= aSx3SUC[nPos][4]
	Else
		cAtend	:= STR0030
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_CHAVE"})
	If (nPos > 0)
		cCliente := aSx3SUC[nPos][4]
	Else
		cCliente := STR0031
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_CODCONT"})
	If (nPos > 0)
		cContato := aSx3SUC[nPos][4]
	Else
		cContato :=STR0033
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_DATA"})
	If (nPos > 0)
		cData := aSx3SUC[nPos][4]
	Else
		cData := STR0009
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_HRPEND"})
	If (nPos > 0)
		cHoraIni := aSx3SUC[nPos][4]
	Else
		cHoraIni :=STR0034
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_OPERADO"})
	If (nPos > 0)
		cOperador := aSx3SUC[nPos][4]
	Else
		cOperador := STR0011
	Endif
	
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_TIPO"})
	If (nPos > 0)
		cComunica := aSx3SUC[nPos][4]
	Else
		cComunica := STR0014
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_STATUS"})
	If (nPos > 0)
		cStatusSUC	:= aSx3SUC[nPos][4]
	Else
		cStatusSUC	:= STR0013
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_MIDIA"})
	If (nPos > 0)
		cMidia := aSx3SUC[nPos][4]
	Else
		cMidia := STR0016
	Endif
	
	nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_OBS"})
	If (nPos > 0)
		cObsSUC	:= aSx3SUC[nPos][4]
	Else
		cObsSUC	:= STR0018
	Endif
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	
	If DbSeek("UD_ITEM")
		cItem		:= Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_ASSUNTO")
		cAssunto	:= Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_PRODUTO")
		cProduto	:= Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_OCORREN")
		cOcorren	:= Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_SOLUCAO")
		cAcao := Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_OPERADO")
		cResp		:= Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_DATA")
		cDataAcao	:= Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_OBS")
		cObsSUD     := Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_STATUS")
		cStatusSUD  := Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_DTEXEC")
		cDataExec	:= Alltrim(X3Titulo())
	Endif
	
	If DbSeek("UD_OBSEXEC")
		cCompl := Alltrim(X3Titulo())
	Endif
	
	If DbSeek("U5_FONE")
		cTiposTels := "  (" + Alltrim(X3Titulo()) + "/"
	EndIf
	
	If DbSeek("U5_FCOM1")
		cTiposTels += Alltrim(X3Titulo()) + "/"
	EndIf
	
	If DbSeek("U5_CELULAR")
		cTiposTels += Alltrim(X3Titulo()) + ")"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Prepara o cabecalho do atendimento - SUC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMensagem += "<html>"
	cMensagem += "<body>"
	
	cMensagem += '<p align="center"><b><font color="#000080" face="Arial" size="4">'   // Alinhamento e tamanho do fonte titulo
	If nOpc == 3 // Inclusao
		cMensagem += STR0028 // "Inclusão de Atendimento - Call Center - Telemarketing"
	ElseIf nOpc == 4 // Alteracao
		cMensagem += STR0050 // "Alteração no Atendimento - Call Center - Telemarketing"
	Endif
	cMensagem += '</font></b></p>'
	
	cMensagem += '<hr>'                	// Linha horizontal do corpo do email
	
	cMensagem += '<p><font face="Arial"><b>'
	cMensagem +=  STR0029 // Dados do Atendimento
	cMensagem += '</b></font></p>'
	
	cMensagem += '<table border="1" width="100%">'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">' 	//Cor azul
	cMensagem += cAtend //Atendimento
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += aCabecalho[1]
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += IIF(!lProspect,STR0031,STR0032)//Cliente , Prospect
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += aCabecalho[2]
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
	cMensagem += cContato //Contato
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[3]),aCabecalho[3],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
	cMensagem += STR0081 //Cidade
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[4]),aCabecalho[4],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
	cMensagem += STR0082 //Endereço
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[5]),aCabecalho[5],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
	cMensagem += STR0083 //Bairro
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[14]),aCabecalho[14],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
	cMensagem += STR0084 + cTiposTels	//Telefones
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[6]),aCabecalho[6],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cData //Data
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[7]),DTOC(aCabecalho[7]),'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cHoraIni //Hora Inicial
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[8]),aCabecalho[8],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cOperador //Operador
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[9]),aCabecalho[9],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cComunica //Comunicacao
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[10]),aCabecalho[10],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cStatusSUC //Status
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[11]),aCabecalho[11],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o Status do chamado for "Encerrada", adiciona o   ³
	//³Motivo do encerramento e a Descrição do encerramento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(M->UC_STATUS) == ENCERRADA
		cMensagem += '<tr>'
		cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
		cMensagem += cMotEnc //Motivo do encerramento
		cMensagem += '</font>&nbsp;</font></b></td>'
		cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aCabecalho[15]),aCabecalho[15],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
		cMensagem += '</font></td>'
		cMensagem += '</tr>'
		
		cMensagem += '<tr>'
		cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
		cMensagem += cDesEnc //Descrição do encerramento
		cMensagem += '</font>&nbsp;</font></b></td>'
		cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aCabecalho[16]),aCabecalho[16],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
		cMensagem += '</font></td>'
		cMensagem += '</tr>'
	EndIf
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cMidia //Midia
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[12]),aCabecalho[12],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cObsSUC //Observacao do atendimento
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[13]),aCabecalho[13],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Prepara o corpo dos itens do atendimento - SUD   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMensagem +='<tr>'
	cMensagem += '<td width="50%">&nbsp;</td>'
	cMensagem += '<td width="50%">&nbsp;</td>'
	cMensagem += '</tr>'
	
	cMensagem += '</table>'
	cMensagem += '<table border="1" width="100%">'
	cMensagem += '<tr>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size=2>'
	cMensagem += cItem//"Item"
	cMensagem += '</font></b></td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cAssunto//"Assunto"
	cMensagem += '</font></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cProduto //"Produto"
	cMensagem += '</font></b></td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cOcorren //"Ocorrencia"
	cMensagem += '</font></b></td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cAcao //"Acao"
	cMensagem += '</font></b>&nbsp;&nbsp;&nbsp;</td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cResp //"Responsavel"
	cMensagem += '&nbsp;</font></b></td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cDataAcao //"Data da Acao"
	cMensagem += '&nbsp;&nbsp;</font></b></td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cObsSUD //"Observacao"
	cMensagem += '&nbsp;&nbsp;</font></b></td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cStatusSUD
	cMensagem += '&nbsp;&nbsp;</font></b></td>'
	
	cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
	cMensagem += cDataExec
	cMensagem += '&nbsp;&nbsp;</font></b></td>'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Prepara a impressao do conteudo dos itens - SUD  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont := 1 To Len(aItens)
		cMensagem += '<tr>'
		
		cMensagem += '<th rowspan=2><font face="Verdana" size=2>'
		cMensagem += StrZero(nCont,3)
		cMensagem += '</font></th>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][2]),AllTrim(aItens[nCont][2]),'&nbsp;') // Assunto - somente descricao
		cMensagem += '</font></td>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][3]),AllTrim(aItens[nCont][3]) + " - " + AllTrim(aItens[nCont][4]),'&nbsp;') //Produto
		cMensagem += '</font></td>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][6]),AllTrim(aItens[nCont][6]),'&nbsp;') // Ocorrencia - somente descricao
		cMensagem += '</font></td>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][8]),AllTrim(aItens[nCont][8]),'&nbsp;') // Acao - Somente descricao
		cMensagem += '</font></td>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][10]),AllTrim(aItens[nCont][10]),'&nbsp;') //Responsavel - somente descricao
		cMensagem += '</font></td>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][11]),AllTrim(aItens[nCont][11]),'&nbsp;')  //Data da acao
		cMensagem +='</font></td>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][12]),AllTrim(aItens[nCont][12]),'&nbsp;')  //Observacao
		cMensagem += '</font></td>'
		
		cMensagem += '<td><font color ="#FF0000" face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][13]),AllTrim(aItens[nCont][13]),'&nbsp;')  //Status
		cMensagem += '</font></td>'
		
		cMensagem += '<td><font face="Verdana" size="2">'
		cMensagem += IIF(!Empty(aItens[nCont][14]),AllTrim(aItens[nCont][14]),'&nbsp;')  //Data
		cMensagem += '</font></td>'
		
		cMensagem += '</tr>'
		
		cMensagem += '<tr><th colspan=9><font face="Verdana" color="#0000FF" size=1>'
		cMensagem += IIF(!Empty(aItens[nCont][15]),cCompl + ": ","")
		cMensagem += '</font><font face="Verdana" size=1>'
		cMensagem += IIF(!Empty(aItens[nCont][15]),AllTrim(aItens[nCont][15]),'&nbsp;') //Memo
		cMensagem += '</font></th></tr>'
		
	Next nCont
	
	cMensagem += '</table>'
	cMensagem += '<p>&nbsp;</p>'
	
	If lTK272HTM
		cMensagem += ExecBlock("TK272HTM",.F.,.F.,{aCabecalho,aItens,nOpc,aSx3SUC,aParScript})
	EndIf
	
	cMensagem += '</body>'
	cMensagem += '</html>'
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk272vAcao³ Autor ³ Vendas Clientes                 ³ Data ³ 14/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se a Ação escolhida gera FNC ou  Nao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEMARKETING                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo da acao escolhida                                      ³±±
±±³          ³ExpN2 - Campo a testar (1-UQ_GERFNC,2-UQ_COMPART)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272vAcao(cAcao,nTipo,lPerg,cItem)
	
	Local aArea		:= GetArea()					// Armazena o posicionamento atual
	Local aAreaSUC	:= SUC->(GetArea())			// Armazena o posicionamento da tabela SUC
	Local aAreaSUQ	:= SUQ->(GetArea())			// Armazena o posicionamento da tabela SUC
	Local lRet 		:= .F. 							// Retorno da funcao indicando se sera gerada uma FNC  ou nao
	
	DbSelectArea("SUQ")
	DbSetOrder(1)
	
	If !Empty(cAcao) .AND. DbSeek(xFilial("SUQ") + cAcao)
		
		Do case
		Case nTipo == 1
			If SUQ->UQ_GERFNC == "1"  					// Indica  se a Acão gera FNC
				lRet := .T.
			EndIf
			
		Case nTipo == 2
			
			If SUQ->UQ_COMPART $ "1/3"
				lRet := .T.
				If SUQ->UQ_COMPART == "3"
					lPerg := .T.
				EndIf
			EndIf
			
			If lRet
				SUC->(DbSetOrder(8)) //UC_FILIAL+UC_CHAORIG+UC_ITCHAOR
				lRet := !SUC->(DbSeek(xFilial("SUC")+M->UC_CODIGO+cItem))
			EndIf
			
		EndCase
		
	EndIf
	
	RestArea(aAreaSUQ)
	RestArea(aAreaSUC)
	RestArea(aArea)
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK272GerCT³ Autor ³ Vendas CRM                      ³ Data ³ 25/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se a Ação escolhida gera CT ou Não                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEMARKETING                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo da acao escolhida                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK272GerCT(cAcao)
	Local lRet := .F.
	Local cGerCT := ""
	
	cGerCT := Posicione("SUQ",1,xFilial("SUQ") + cAcao, "UQ_INTTEC")
	
	If cGerCT == "1"
		lRet := .T.
	EndIf
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³TMK272AVFNC³ Autor ³ Vendas Clientes       ³ Data ³20/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Funcao que  chama Tela da FNC Preenchida                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpO1 - Objeto do dialogo                                    ³±±
±±³           ³ExpO2 - Objeto da getdados                                   ³±±
±±³           ³ExpC3 - Codigo do atendimento                                ³±±
±±³           ³ExpA4 - Array do aCols                                       ³±±
±±³           ³ExpA5 - Array do aHeader                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMK272AVFNC(	oDlg		,oGetD		,cCodigo	,aCols		,;
		aHeader		)
	
	Local n 		:= oGetD:oBrowse:nAt 				// Linha do ACols com o Registro a ser Analisado
	Local aArea 	:= GetArea() 						// Salva posicao dos registros
	Local aColsSav  := aClone(aCols) 					// Salva aCols
	Local aHeadSav  := aClone(aHeader) 					// Salva aHeader
	
	SUD->(DbSetOrder(1))
	If SUD->(DbSeek(xFilial("SUD")+cCodigo+StrZero(n,2)))
		QI2->(DbSetOrder(2))
		If QI2->(DbSeek(xFilial("QI2")+SUD->UD_CODFNC+SUD->UD_FNCREV))
			QI2->(Recno())
			QNC040Foll("QI2",QI2->(Recno()),6)
		Else
			MsgInfo(STR0060)
		Endif
	Endif
	
	aCols   := aClone(aColsSav)
	aHeader := aClone(aHeadSav)
	
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkContEnt ºAutor  ³Vendas / CRM        º Data ³  11/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkContEnt(lMsg)

Local aArea		:= {}
Local lRet			:= .T.
Local cCont		:= ""
Local cChav		:= ""
Local cAliasTmp	:= ""

Default lMsg		:= .T.

If	Type("M->UC_CODCONT") <> "U" .AND. Type("M->UC_CHAVE") <> "U"

	cCont	:= M->UC_CODCONT
	cChav	:= AllTrim(M->UC_CHAVE)

	If ! Empty(cCont)
		If ! Empty(cChav)
			cChav := PadR(cChav, GetSX3Cache("AC8_CODENT","X3_TAMANHO"))

			aArea	:= GetArea()
			cAliasTmp	:= GetNextAlias()
			BeginSQL alias cAliasTmp
				SELECT AC8.R_E_C_N_O_ AC8RECNO
				  FROM %Table:AC8% AC8
				 WHERE AC8.AC8_FILIAL = %xfilial:AC8%
				   AND AC8.AC8_CODCON = %exp:cCont%
				   AND AC8.AC8_CODENT = %exp:cChav%
				   AND AC8.%NotDel%
			EndSQL

			If	( lRet := (cAliasTmp)->(! Eof()) )
				AC8->(DbGoTo((cAliasTmp)->AC8RECNO))
			EndIf
			(cAliasTmp)->(DbCloseArea())
			RestArea(aArea)

		Else
			lRet := .F.
		EndIf
		If !lRet .And. lMsg .And. !IsInCallStack( "TK271GRAVA" )// .And. IsInCallStack( "TK271CABOK" ))
			// Mensagem de aviso para informar o cliente correspondente a este contato.
			Aviso(STR0043,STR0051,{"OK"})//"Atenção","Por favor, selecione uma entidade relacionada ao contato para gravação do atendimento"
		EndIf
	Else
		lRet := Empty(cChav) // Se o contato e a chave estiver em branco deixa passar.
	EndIf

EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk272RlCmpºAutor  ³Vendas CRM          º Data ³  12/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a relacao dos chamados compartilhados a partir do cha-º±±
±±º          ³mado atual.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272RlCmp()
	
	Local oDlg
	Local oPanTop,oPanCenter,oPanBotL,oPanBotR,oGetTop,oGetCenter,oMemo1,oMemo2
	Local cMemo1		:= ""
	Local cMemo2		:= ""
	Local aCoors 		:= FWGetDialogSize(oMainWnd)	// Dimensoes da tela na resolucao atual
	Local aHeadTop		:= {}
	Local aColTop		:= {}
	Local aHeadCenter	:= {}
	Local aColCenter	:= {}
	Local oLayer 		:= FWLayer():new()
	
	SaveInter()
	
	DEFINE MSDIALOG oDlg FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL TITLE STR0070 //"Chamados compartilhados pelo atendimento atual"
	
	oLayer:init(oDlg,.f.)
	
	oLayer:addLine("LINHA1", 25, .F.)
	oLayer:addCollumn('Col01',100,.F.,"LINHA1")
	oLayer:addWindow('Col01','C1_Win01',STR0071,100,.T.,.F.,,"LINHA1") //'Itens do chamado atual'
	
	oLayer:addLine("LINHA2", 50, .F.)
	oLayer:addCollumn('Col01',100,.F.,"LINHA2")
	oLayer:addWindow('Col01','C1_Win02',STR0072,100,.T.,.T.,,"LINHA2") //'Ocorrências referentes ao item selecionado'
	
	oLayer:addLine("LINHA3", 25, .F.)
	oLayer:addCollumn('Col01',50,.F.,"LINHA3")
	oLayer:addCollumn('Col02',50,.F.,"LINHA3")
	oLayer:addWindow('Col01','C1_Win03',STR0053,100,.T.,.F.,,"LINHA3")
	oLayer:addWindow('Col02','C1_Win03',STR0057,100,.T.,.F.,,"LINHA3")
	
	oPanTop		:= oLayer:getWinPanel('Col01','C1_Win01',"LINHA1")
	oPanCenter	:= oLayer:getWinPanel('Col01','C1_Win02',"LINHA2")
	oPanBotL	:= oLayer:getWinPanel('Col01','C1_Win03',"LINHA3")
	oPanBotR	:= oLayer:getWinPanel('Col02','C1_Win03',"LINHA3")
	
	@ 0,0 Get oMemo1 Var cMemo1 Of oPanBotL MULTILINE Size 10,10 PIXEL
	@ 0,0 Get oMemo2 Var cMemo2 Of oPanBotR MULTILINE Size 10,10 PIXEL
	
	oMemo1:Align := CONTROL_ALIGN_ALLCLIENT
	oMemo2:Align := CONTROL_ALIGN_ALLCLIENT
	
	aHeadTop	:= aClone(aHeader)
	aColTop		:= aClone(aCols)
	
	oGetTop:= MsNewGetDados():New(0,0,10,10, 2,/*cLinOk*/,/*cTudoOk*/,/*cIniCpos*/,/*aAlterGDa*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/, /*cSuperDel*/,/*cDelOk*/, oPanTop, aHeadTop, aColTop)
	oGetTop:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetTop:bChange := {|| TkAtCols2(M->UC_CODIGO,oGetTop:nAt,@oGetCenter) }
	oGetTop:lDelete := .F.
	oGetTop:lInsert := .F.
	oGetTop:lUpdate := .F.
	
	aHeadCenter := aClone(aHeadTop)
	
	If aScan(aHeadCenter,{|x|AllTrim(x[2]) == "UD_CODIGO"}) == 0
		aSize(aHeadCenter,len(aHeadCenter) + 1)
		aIns(aHeadCenter,2)
		SX3->(DbSetOrder(2))
		SX3->(DbSeek("UD_CODIGO"))
		aHeadCenter[2] := {	Trim(X3Titulo())	,;
			SX3->X3_CAMPO		,;
			SX3->X3_PICTURE		,;
			SX3->X3_TAMANHO		,;
			SX3->X3_DECIMAL		,;
			SX3->X3_VALID		,;
			SX3->X3_USADO		,;
			SX3->X3_TIPO		,;
			SX3->X3_F3			,;
			SX3->X3_CONTEXT 	,;
			X3CBox()			,;
			SX3->X3_RELACAO		,;
			SX3->X3_WHEN		,;
			SX3->X3_VISUAL		,;
			SX3->X3_VLDUSER		,;
			SX3->X3_PICTVAR		,;
			X3Obrigat(SX3->X3_CAMPO)}
	EndIf
	
	oGetCenter:= MsNewGetDados():New(0,0,10,10, 2,/*cLinOk*/,/*cTudoOk*/,/*cIniCpos*/,/*aAlterGDa*/,/*nFreeze*/,/*nMax*/,/*cFieldOk*/, /*cSuperDel*/,/*cDelOk*/, oPanCenter, aHeadCenter, aColCenter)
	oGetCenter:bChange := {|| TkAtMemo(@oGetCenter,@oMemo1,@oMemo2,@cMemo1,@cMemo2) }
	oGetCenter:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetCenter:lDelete := .F.
	oGetCenter:lInsert := .F.
	oGetCenter:lUpdate := .F.
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	RestInter()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkAtCols2 ºAutor  ³Vendas CRM          º Data ³  14/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o acols ao selecionar um outro item do atendimento º±±
±±º          ³com dados do chamado compartilhado                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA272A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkAtCols2(cCodAte,nItem,oGetCenter)
	
	Local aArea		:= GetArea()
	Local aAreaSUD	:= SUD->(GetArea())
	Local cFilSUD	:= xFilial("SUD")
	Local cQuery	:= ""
	Local nX		:= 0
	Local nLin		:= 0
	Local aColsTmp	:= {}
	Local oVerm		:= LoaDbitmap(GetResources(),"BR_VERMELHO")
	Local oVerde	:= LoaDbitmap(GetResources(),"BR_VERDE")
	Local nPosStat 	:= 0
	
	SUD->(DbSetOrder(1))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona os chamados relacionados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT UC_CODIGO FROM " + RetSqlName("SUC")
	cQuery += " WHERE UC_CHAORIG = '" + cCodAte + "' AND UC_ITCHAOR = '" + StrZero(nItem,2) + "' AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY UC_CODIGO"
	
	cQuery := ChangeQuery(cQuery)
	
	If Select("CHACMP") > 0
		CHACMP->(DbCloseArea())
	EndIf
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'CHACMP',.T.,.T.)
	
	nPosStat := Ascan(oGetCenter:aHeader, {|x|AllTrim(x[2]) == "UD_STATUS"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Constroi o acols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CHACMP->(Eof())
		
		SUD->(DbSeek(cFilSUD+CHACMP->UC_CODIGO))
		
		While !SUD->(Eof()) .AND. SUD->UD_FILIAL == cFilSUD .AND. SUD->UD_CODIGO == CHACMP->UC_CODIGO
			
			AAdd(aColsTmp, Array(Len(oGetCenter:aHeader) + 1) )
			
			nLin++
			
			For nX := 1 to Len(oGetCenter:aHeader)
				If (oGetCenter:aHeader[nX][10] <> "V" .AND. oGetCenter:aHeader[nX][08] <> "M")
					aColsTmp[nLin][nX] := SUD->&(oGetCenter:aHeader[nX][2])
				ElseIf IsHeadAlias(oGetCenter:aHeader[nX][2])
					aColsTmp[nLin][nX] := "SUD"
				ElseIf IsHeadRec(oGetCenter:aHeader[nX][2])
					aColsTmp[nLin][nX] := SUD->(Recno())
				ElseIf oGetCenter:aHeader[nX][2] == "CHECKBOX"
					aColsTmp[nLin][nX] := Nil
				Else
					aColsTmp[nLin][nX] := CriaVar(oGetCenter:aHeader[nX][2],.T.)
				EndIf
			Next nX
			
			aColsTmp[nLin][nX] := .F.
			
			If !Empty(aColsTmp[nLin][nPosStat]) .AND. aColsTmp[nLin][nPosStat] == "2"
				aColsTmp[nLin][1] := oVerde
			Else
				aColsTmp[nLin][1] := oVerm
			EndIf
			
			TkSUDAfterAcols(@oGetCenter:aHeader, @aColsTmp, 2)
			
			SUD->(DbSkip())
			
		End
		
		CHACMP->(DbSkip())
		
	End
	
	oGetCenter:nAt		:= 1
	oGetCenter:aCols	:= aClone(aColsTmp)
	oGetCenter:oBrowse:Refresh()
	
	RestArea(aAreaSUD)
	RestArea(aArea)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkAtMemo  ºAutor  ³Vendas CRM          º Data ³  15/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os campos memo de acordo com a linha selecionada   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkAtMemo(oGetCenter,oMemo1,oMemo2,cMemo1,cMemo2)
	
	Local nPObsExec	:= Ascan(oGetCenter:aHeader, {|x|AllTrim(x[2]) == "UD_OBSEXEC"})
	Local nPObs		:= Ascan(oGetCenter:aHeader, {|x|AllTrim(x[2]) == "UD_OBS"})
	
	If Len(oGetCenter:aCols) >= oGetCenter:nAt
		cMemo1 := oGetCenter:aCols[oGetCenter:nAt][nPObs]
		oMemo1:Refresh()
		
		cMemo2 := oGetCenter:aCols[oGetCenter:nAt][nPObsExec]
		oMemo2:Refresh()
	EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk272TrnsfºAutor  ³Vendas CRM          º Data ³  18/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transfere o chamado de operador                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272Trnsf()
	
	Local aArea		:= GetArea()
	Local aAreaSUC	:= SUC->( GetArea() )
	Local aAreaSUD	:= SUD->( GetArea() )
	Local aAreaSU7	:= SU7->( GetArea() )
	Local aDataTrf	:= Tk272SelOp()
	Local lTemFilho	:= ALTERA .AND. SUC->(FieldPos("UC_CHAORIG")) > 0 .AND. !Empty(SUC->UC_CHAORIG)
	Local nPOper		:= aScan(aHeader,{|x|AllTrim(x[2])=="UD_OPERADO"})
	Local nPStat		:= aScan(aHeader,{|x|AllTrim(x[2])=="UD_STATUS" })
	Local nPAcao		:= aScan(aHeader,{|x|AllTrim(x[2])=="UD_SOLUCAO"})
	Local cChAtu		:= SUC->UC_CODIGO
	Local lTemIndice	:= SIX->(DbSeek("SUC8"))
	Local cUser		:= ""

	Local cFilSU7			:= xFilial("SU7")
	Local cFilSUC			:= xFilial("SUC")
	Local cFilSUD			:= xFilial("SUD")

	Local cUsrAtu		:= Posicione("SU7",1,cFilSU7+M->UC_OPERADO,"U7_CODUSU")
	Local cOperator	:= ""
	Local nPos			:= 0
	Local aGroup		:= aDataTrf[1]
	Local aOper 		:= aDataTrf[2]
	Local nX			:= 0
	Local cName		:= ""
	Local lGroup		:= .F.
	Local nOper		:= 0
	Local nPosSup		:= 0
	Local cType		:= ""
	Local cGrupo		:= ""
		
	//------------------------------------------------
	// Verifica se tem grupo marcado
	//------------------------------------------------
	If !Empty( aGroup )
		If aGroup[01]
			lGroup := .T.
		EndIf
	EndIf
	
	//------------------------------------------------
	// Verifica se tem operador marcado
	//------------------------------------------------
	For nX := 1 To Len( aOper )
		If aOper[nX][01] 
			nOper++
			nPosOPer := nX
			If AllTrim( aOper[nX][05] ) == "2"
				nPosSup := nX
			EndIf
		EndIf
	Next( nX )
	
	//-------------------------------------------------------
	// Se tem um grupo marcado e um operador ou superior
	//-------------------------------------------------------
	If lGroup .And. ( nOper + nPosSup ) > 0
		//---------------------------------------------------
		// Se tem pelo menos um operador marcado
		//---------------------------------------------------
		If nOper == 1
			cOperator	:= aOper[nPosOper][3]
			cGrupo		:= aOper[nPosOper][4]
			cUser		:= aOper[nPosOper][6]
			cName		:= Alltrim( aOper[nPosOper][2] )
		ElseIf nOper > 1 .Or. nPosSup > 0
			//---------------------------------------------------
			// Se tem pelo menos um supervisor no grupo
			//---------------------------------------------------
			If nPosSup > 0
				cOperator	:= aOper[nPosSup][3]
				cGrupo		:= aOper[nPosSup][4]
				cUser		:= aOper[nPosSup][6]
				cName		:= Alltrim( aOper[nPosSup][2] )
			Else
				Help("",1,"TK272TRFCH",,STR0177,1,0,,,,,,{STR0201})	//"Não existe nenhum operador de tipo supervisor no grupo."##"Selecione somente um operador no grupo de destino, para efetuar a transferência."
			EndIf
		EndIf
	ElseIf !lGroup .And. ( nOper + nPosSup ) > 0
		//---------------------------------------------------
		// Se tem pelo menos um operador marcado
		//---------------------------------------------------
		If nOper == 1
			cOperator	:= aOper[nPosOper][3]
			cGrupo		:= aOper[nPosOper][4]
			cUser		:= aOper[nPosOper][6]
			cName		:= Alltrim( aOper[nPosOper][2] )
		ElseIf nOper > 1
			//---------------------------------------------------
			// Se tem pelo menos um supervisor no grupo
			//---------------------------------------------------
			If nPosSup > 0
				cOperator	:= aOper[nPosSup][3]
				cGrupo		:= aOper[nPosSup][4]
				cUser		:= aOper[nPosSup][6]
				cName		:= Alltrim( aOper[nPosSup][2] )
			Else
				Help("",1,"TK272TRFCH",,STR0177,1,0,,,,,,{STR0201})	//"Não existe nenhum operador de tipo supervisor no grupo."##"Selecione somente um operador no grupo de destino, para efetuar a transferência."
			EndIf
		EndIf
	EndIf
	
	If Posicione( "SU7", 1, cFilSU7 + cOperator, "U7_TIPO" ) == "2"
		cType := STR0188 //Supervisor
	Else 
		cType := STR0011 //Operador
	EndIf
	
	If !Empty( cOperator ) .And. MsgYesNo( STR0073 + Iif( lTemFilho, STR0074 + SUC->UC_CHAORIG, "" ) + STR0075 + cOperator +" - "+ FATPDObfuscate(cName,"U7_NOME",/*cSource*/,.T.) + " (" +cType+ ") ?" )//"Confirma a transferência do chamado atual "###"e de seu respectivo item no chamado "###" para o operador "
		
		//------------------------
		// Chamado pai
		//------------------------
		If lTemFilho
			DbSelectArea("SUD")
			SUD->( DbSetOrder( 1 ) )
			If SUD->( DbSeek( cFilSUD + SUC->UC_CHAORIG + SUC->UC_ITCHAOR ) .AND. RecLock( "SUD", .F. ) )
				SUD->UD_OPERADO := SU7->U7_CODUSU
				MsUnLock()
			EndIf
		EndIf
		
		If lTemIndice
			SUC->( DbSetOrder( 8 ) )
		EndIf
		
		//------------------------
		// Itens chamado atual
		//------------------------
		For nX := 1 to Len( aCols )
			If !aTail( aCols[nX] ) .AND. aCols[nX,nPStat] == "1" .AND. aCols[nX,nPOper] == cUsrAtu .AND. ;
					( !lTemIndice .OR. ( lTemIndice .AND. !SUC->( DbSeek( cFilSUC + cChAtu+StrZero( nX, 2 ) ) ) ) )
				
				aCols[nX,nPOper]		:= SU7->U7_CODUSU
			 	                                                                        
			EndIf
		Next( nX )
		
		//------------------------
		// Chamado atual
		//------------------------
		M->UC_OPERADO := cOperator
		M->UC_DESCOPE := Posicione("SU7",1,cFilSU7+cOperator,"U7_NOME")
		M->UC_GRUPO	  := cGrupo
	EndIf
	
	RestArea( aAreaSU7 )
	RestArea( aAreaSUC )
	RestArea( aAreaSUD )
	RestArea( aArea )
	
Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk272VerSUNºAutor  ³Vendas CRM         º Data ³  15/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existem encerramentos cadastrados.             º±±
±±ºParametros³ cTipo: 1- Telemarketing 3- Telecobranca                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA272A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272VerSUN(cTipo)
	
	Local aArea	 := GetArea()
	Local lRet 	 := .F.
	Local cQuery := ""
	Local cFilSUN		:= xFilial("SUN")
	
	DEFAULT cTipo := "1"
	
	#IFDEF TOP
		If Select("TMP") > 0
			TMP->(dbCloseArea())
		EndIf
		
		cQuery	:= "SELECT * FROM " + RetSqlName("SUN")
		cQuery	+= " WHERE UN_FILIAL ='" + cFilSUN + "' AND "
		cQuery	+= " UN_TIPOATE IN('" + cTipo + "','4') AND "	//1- Telemarketing 3- Telecobrança 4- Ambos
		cQuery	+= " UN_VALIDO = '1' AND "						//Encerramento é válido
		cQuery	+= " D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP",.T.,.T.)
		
		TMP->(dbGoTop())
		
		If TMP->(!Eof())
			lRet := .T.
		EndIf
		
		TMP->(dbCloseArea())
	#ELSE
		dbSelectArea("SUN")
		dbSetOrder(1)
		If dbSeek(cFilSUN) .And. !SUN->(Eof())
			While !SUN->(Eof()) .And. SUN->UN_FILIAL == cFilSUN
				//1- Telemarketing 3- Telecobrança 4- Ambos e se o encerramento é válido
				If !(SUN->UN_TIPOATE $ "4" + cTipo .AND. SUN->UN_VALIDO == "1")
					SUN->(dbSkip())
				Else
					lRet := .T.
					Exit
				EndIf
			EndDo
		EndIf
	#ENDIF
	
	RestArea(aArea)
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272SelOp

Interface para seleção de grupos e/ou operadores de destino

@return aRet, array	, aRet[1] = Grupos -  aRet[2] = Operadores

@author  Thamara Villa
@version P11
@since   06/02/2016
/*/
//------------------------------------------------------------------------------------------
Static Function Tk272SelOp()
	
	Local oDlg			:= Nil
	Local oPanel		:= Nil
	Local oFWLayer		:= Nil
	Local oLayerGrp		:= Nil
	Local oColGrp		:= Nil
	Local oDlgGrp		:= Nil
	Local oLayerPsq		:= Nil
	Local oColPsq	 	:= Nil
	Local oDlgPsq	 	:= Nil
	Local oLayerOpe		:= Nil
	Local oColOpe	 	:= Nil
	Local oDlgOpe	 	:= Nil
	Local oLayerBut 	:= Nil
	Local oColBut 		:= Nil
	Local oDlgBut		:= Nil
	Local oChk			:= Nil
	Local oTxt1			:= Nil
	
	Local oLbxOper 		:= Nil
	Local oPesq	 		:= Nil
	Local oInd			:= Nil
	Local oButPesq 		:= Nil
	Local oButOk		:= Nil
	Local oButFec		:= Nil
	
	Local aOperator		:= {}
	Local aGroup 		:= {}
	Local aMatrixOp 	:= {}
	Local aIndPesq 		:= { STR0179, STR0180 } //"1=Grupo" # "2=Operador"
	Local aRet			:= Array( 2 )
	Local cOpSel		:= ""
	Local cVar			:= ""
	Local cGroup		:= ""
	Local cTemp			:= GetNextAlias()
	Local cPesq 		:= Space( 100 )
	Local cInd 			:= Space( 100 )
	Local bPesq 		:= { || Tk272APesq( aIndPesq, cInd, cPesq, aGroup, oLbxGrp, aOperator, oLbxOper ) }
	Local aPDFields		:= {"U7_NOME"}
	Local aPDCols 		:= {}
	Local lChk 			:= .F.
	
	Private oOk		:= LoadBitmap( GetResources(), "LBOK" )
	Private oNo		:= LoadBitmap( GetResources(), "LBNO" )
	Private b272Chg	:= { || TK272Change( @oLbxGrp, @aGroup, @oLbxOper, @aOperator, aMatrixOp ) }
	
	//-----------------------------------------------------------------------------------------------------
	// Query para trazer os grupos e operadores que serão exibidos para seleção, considerando as tabelas:
	//		SU7 - Operadores
	//		SU0 - Grupo de atendimento
	//		AG9 - Operador x Grupos de atendimento
	//-----------------------------------------------------------------------------------------------------
	BeginSQL ALIAS cTemp
		
		SELECT U7_COD, U7_NOME, AG9_CODSU0, U0_NOME, U7_TIPO, U7_CODUSU
		
		FROM %Table:SU7% SU7
		
		INNER JOIN %Table:AG9% AG9 ON AG9.AG9_FILIAL = %xFilial:AG9% AND AG9.AG9_CODSU7 = SU7.U7_COD
		INNER JOIN %Table:SU0% SU0 ON SU0.U0_FILIAL = %xFilial:SU0% AND SU0.U0_CODIGO = AG9.AG9_CODSU0
		
		WHERE SU7.%NotDel%
		AND AG9.%NotDel%
		AND SU0.%NotDel%
		AND SU7.U7_TIPOATE IN ('1', '4', '5')
		AND SU7.U7_VALIDO = '1'
		AND SU7.U7_FILIAL = %xFilial:SU7%
		
		ORDER BY AG9_CODSU0, U7_NOME
		
	EndSQL
	
	//--------------------------------------------------------------------------------------------
	// Inclui um grupo default para trazer todos os operadores para fins de pesquisa
	//--------------------------------------------------------------------------------------------
	Aadd( aGroup, { .F., STR0181, "" } ) //"Todos"
	
	While ( cTemp )->( !Eof() )
		Aadd( aOperator, { .F., ( cTemp )->U7_NOME, ( cTemp )->U7_COD, ( cTemp )->AG9_CODSU0, ( cTemp )->U7_TIPO, ( cTemp )->U7_CODUSU } )
		
		If cGroup <> ( cTemp )->AG9_CODSU0
			Aadd( aGroup, { .F., ( cTemp )->U0_NOME, ( cTemp )->AG9_CODSU0 } )
		EndIf
		cGroup := ( cTemp )->AG9_CODSU0
		
		( cTemp )->( DbSkip() )
	EndDo
	
	aMatrixOp := aClone( aOperator )
	
	If Len( aOperator ) == 0
		Aviso( STR0077, STR0076, { "Ok" } ) //"Operadores"###"Não existem operadores aptos a receber este chamado"
	Else
		FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
		oDlg := FwDialogModal():New()
		oDlg:SetBackground( .F. )
		oDlg:SetSize( 200, 400 )
		oDlg:EnableFormBar( .F. )
		
		oDlg:CreateDialog()
		
		oPanel := oDlg:GetPanelMain()
		
		//--------------------------------------------------------------------------------------------
		// Montagem do layer superior de pesquisa
		//--------------------------------------------------------------------------------------------
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oPanel, .F. )
		oFWLayer:AddLine( "UP_BOX", 25, .T. )
		
		//--------------------------------------------------------------------------------------------
		// Pesquisa
		//--------------------------------------------------------------------------------------------
		oFWLayer:AddCollumn( "PESQ_BOX", 100, .T., "UP_BOX" )
		
		oColPsq := oFWLayer:GetColPanel( "PESQ_BOX", "UP_BOX" )
		
		oLayerPsq := FWLayer():New()
		oLayerPsq:Init( oColPsq, .F. )
		oLayerPsq:AddCollumn( "COLL1", 100, .T., "LINE1" )
		oLayerPsq:AddWindow( "COLL1", "WIN1", "Pesquisa", 100, .F., .F.,, "LINE1" )
		
		oDlgPsq := oLayerPsq:GetWinPanel( "COLL1", "WIN1", "LINE1" )
		
		//-------------------------------------
		// Pesquisa por grupos ou operadores
		//-------------------------------------
		@ 10,10 COMBOBOX  oInd	Var cInd ITEMS aIndPesq	SIZE 60,9 OF oDlgPsq PIXEL
		@ 10,75 MSGET oPesq VAR cPesq PICTURE "@!" SIZE 120,9 OF oDlgPsq PIXEL
		oButPesq := TBtnBmp2():New( 16, 395, 26, 26, "BMPCONS",,,, bPesq, oDlgPsq, STR0182,, .T. ) //"Pesquisar"
		
		//--------------------------------------------------------------------------------------------
		// Montagem dos layers para agrupar os grupos, operadores e botões
		//--------------------------------------------------------------------------------------------
		oFWLayer:AddLine( "DOWN_BOX", 55, .T. )
		oFWLayer:AddLine( "BUT_BOX" , 20, .T. )
		
		//--------------------------------------------------------------------------------------------
		// Grupos
		//--------------------------------------------------------------------------------------------
		oFWLayer:AddCollumn( "GRUPO_BOX", 50, .T., "DOWN_BOX" )
		
		oColGrp := oFWLayer:GetColPanel( "GRUPO_BOX", "DOWN_BOX" )
		
		oLayerGrp := FWLayer():New()
		oLayerGrp:Init( oColGrp, .F.)
		oLayerGrp:AddCollumn( "COLL2", 100, .T., "LINE2" )
		oLayerGrp:AddWindow( "COLL2", "WIN2", STR0183, 100, .F., .F.,, "LINE2" ) //"Grupos"
		
		oDlgGrp := oLayerGrp:GetWinPanel( "COLL2", "WIN2", "LINE2" )
		
		//-------------------------------------
		// ListBox dos grupos
		//-------------------------------------
		@ 30,10 LISTBOX oLbxGrp VAR cVar FIELDS HEADER " ", STR0078, STR0079 ; //"Nome"###"Codigo"
		COLSIZES 10,100,30 ;
			SIZE 165,105 OF oDlgGrp PIXEL
		
		oLbxGrp:Align := CONTROL_ALIGN_ALLCLIENT
		
		oLbxGrp:SetArray( aGroup )
		oLbxGrp:bLine := {|| {Iif(aGroup[oLbxGrp:nAt,1],oOk,oNo),;
			aGroup[oLbxGrp:nAt,2],;
			aGroup[oLbxGrp:nAt,3]}}
		
		oLbxGrp:bChange	:= b272Chg
		oLbxGrp:bLdblClick := {|| aEval( aGroup, { |x|x[1] := .F. } ), aGroup[oLbxGrp:nAt,1] := .T., cOpSel := aGroup[oLbxGrp:nAt,3], ;
			TK272MarkOp( oLbxGrp, oLbxOper, oChk, @lChk ) ,;
			oLbxGrp:Refresh() }
		
		//--------------------------------------------------------------------------------------------
		// Operadores
		//--------------------------------------------------------------------------------------------
		oFWLayer:AddCollumn( "OPERA_BOX", 50, .T., "DOWN_BOX" )
		
		oColOpe := oFWLayer:GetColPanel( "OPERA_BOX", "DOWN_BOX" )
		
		oLayerOpe := FWLayer():New()
		oLayerOpe:Init( oColOpe, .F.)
		oLayerOpe:AddCollumn( "COLL3", 100, .T., "LINE3" )
		oLayerOpe:AddWindow( "COLL3", "WIN3", STR0184, 100, .F., .F.,, "LINE3" ) //"Operadores"
		
		oDlgOpe := oLayerOpe:GetWinPanel( "COLL3", "WIN3", "LINE3" )
		
		//--------------------------------------------------------------------------------------------
		// ListBox dos operadores
		//--------------------------------------------------------------------------------------------
		@ 30,180 LISTBOX oLbxOper VAR cVar FIELDS HEADER " ", STR0078, STR0079 ; //"Nome"###"Codigo"
		COLSIZES 10,120,30 ;
			SIZE 165,105 OF oDlgOpe PIXEL
		
		oLbxOper:Align := CONTROL_ALIGN_ALLCLIENT
		
		oLbxOper:SetArray( aOperator )
		oLbxOper:bLine := {|| { Iif( aOperator[oLbxOper:nAt,1], oOk, oNo ),;
			aOperator[oLbxOper:nAt,2],;
			aOperator[oLbxOper:nAt,3] } }
		oLbxOper:bLdblClick := {|| aOperator[oLbxOper:nAt][1] := ! aOperator[oLbxOper:nAt][1], oLbxOper:Refresh() }
		aPDCols := {"","U7_NOME",""}

		If FATPDActive() .And. FTPDUse(.T.)
			oLbxOper:aObfuscatedCols := FATPDColObfuscate(aPDCols) 
		EndIf
		
		//--------------------------------------------------------------------------------------------
		// Botões
		//--------------------------------------------------------------------------------------------
		oFWLayer:AddCollumn( "BUTTON", 100, .T., "BUT_BOX" )
		
		oColBut := oFWLayer:GetColPanel( "BUTTON", "BUT_BOX" )
		
		oLayerBut := FWLayer():New()
		oLayerBut:Init( oColBut, .F.)
		oLayerBut:AddCollumn( "COLL3", 100, .T., "LINE3" )
		oLayerBut:AddWindow( "COLL3", "WIN3", "", 100, .F., .F.,, "LINE3" )
		
		oDlgBut := oLayerBut:GetWinPanel( "COLL3", "WIN3", "LINE3" )
		
		oButOk  := tButton():New( 02, 355, "Ok", oDlgBut, { || IIf( TK272TudoOk( oLbxGrp, oLbxOper ), ( aRet[01] := oLbxGrp:aArray[oLbxGrp:nAt], aRet[02] := oLbxOper:aArray, oDlg:DeActivate() ) , .F. ) }, 030,011,,/*oFont*/,,.T.,,,,/*bWhen*/ )
		oButFec := tButton():New( 02, 320, STR0185, oDlgBut, { || aRet := { {}, {} }, oDlg:DeActivate() }, 030,011,,/*oFont*/,,.T.,,,,/*bWhen*/ ) //"Fechar"
		
		@ 02,200 CHECKBOX oChk VAR lChk PROMPT STR0202 SIZE 70,07 PIXEL OF oDlgBut ;		//"Marca/Desmarca todos"
			ON CLICK( aEval( aOperator, {|x| x[1] := IIf(lChk,.T.,.F.) } ),oLbxOper:Refresh())

		@ 09,225 SAY STR0184 SIZE 50,10 OF oDlgBut PIXEL	//"Operadores"

		oDlg:Activate()
		FATPDLogUser("TK272SELOP")
		FATPDUnload()
	EndIf 

	aSize(aPDFields, 0)
	aSize(aPDCols, 0)
	
Return( aRet )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK272Change

Rotina responsável por filtrar/atualizar a listagem de operadores de acordo com o grupo
selecionado.

@param oLbxGrp		, objeto	, objeto do listbox do grupo
@param aGroup		, array		, contém os daods dos grupos
@param oLbxOper	, objeto	, objeto do listbox do operadores
@param aOperator	, array		, contém os dados dos operadores
@param aMatrixOp	, array		, clone do array de operadores

@author  Thamara Villa
@version P11
@since   06/02/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TK272Change( oLbxGrp, aGroup, oLbxOper, aOperator, aMatrixOp )
	
	Local cGroup 	:= AllTrim(aGroup[oLbxGrp:nAt][03])
	Local nX     	:= 0
	Local nPosGrp	:= 4
	
	If Empty( cGroup ) // Grupo Todos
		aOperator := aClone( aMatrixOp )
	Else
		aOperator := {}
		For nX := 1 To Len( aMatrixOp )
			If AllTrim( aMatrixOp[nX][nPosGrp] ) == cGroup
				Aadd( aOperator, aClone( aMatrixOp[nX] ) )
			EndIf
		Next
		//--------------------------------------------------
		// Marca os operadores caso o grupo esteja marcado
		//--------------------------------------------------
		aEval( aOperator, { |x|x[1] := aGroup[oLbxGrp:nAt][01] } )
	EndIf
	
	oLbxOper:SetArray( aOperator )
	oLbxOper:bLine := {|| { Iif( aOperator[oLbxOper:nAt,1], oOk, oNo ),;
		aOperator[oLbxOper:nAt,2],;
		aOperator[oLbxOper:nAt,3]}}
	oLbxOper:Refresh()
	
Return( Nil )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK272MarkOp

Marcação dos itens de grupo e operadores

@param oLbxGrp		, objeto	, objeto do listbox do grupo
@param oLbxOper	, objeto	, objeto do listbox do operadores

@return Verdadeiro

@author  Thamara Villa
@version P11
@since   06/02/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TK272MarkOp( oLbxGrp, oLbxOper, oChk, lChk )
	
	If !Empty( oLbxGrp:aArray[oLbxGrp:nAt][03] ) // Grupo Todos
		aEval( oLbxOper:aArray, {|x|x[1] := oLbxGrp:aArray[oLbxGrp:nAt][01] } )
		oLbxOper:Refresh()
		lChk := .T.
		oChk:Refresh()
	Else
		lChk := .F.
		oChk:Refresh()
	EndIf

Return( .T. )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK272TudoOk

Validação dos itens selecionados

@param oLbxGrp		, objeto	, objeto do listbox do grupo
@param oLbxOper	, objeto	, objeto do listbox do operadores


@return lRet		, lógico	, verdeiro ou falso

@author  Thamara Villa
@version P11
@since   06/02/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TK272TudoOk( oLbxGrp, oLbxOper )
	
	Local lRet 		:= .T.
	Local lGroup		:= .F.
	Local nX   		:= 0
	Local nOper		:= 0
	Local nPosSup		:= 0
	Local aOper   	:= oLbxOper:aArray
	Local aGroup   	:= oLbxGrp:aArray
	Local cOperator	:= ""
	Local cUser		:= ""
	Local cName		:= ""
		
	//---------------------------------------------------------------------
	// Não permite a marcação da opção "TODOS", pois tal opção é utilizada
	// apenas para fins de pesquisa.
	//---------------------------------------------------------------------	
	If aGroup[1,1] .And. AScan( aOper, { |x| x[1] == .T. } ) == 0
		lRet := .F.
		MsgAlert( OemToAnsi( STR0189 ) ) //"A opção 'Todos' é utilizada apenas para fins de pesquisa. Utilize os grupos abaixo ou selecione um operador específico. Ao selecionar mais de um operador, o atendimento irá para um operador de tipo 'Supervisor'"
	EndIf
	
	If lRet
		//------------------------------------------------
		// Verifica se tem grupo marcado
		//------------------------------------------------
		For nX := 1 To Len( aGroup )
			If aGroup[nX][1]
				lGroup := .T.
				Exit
			EndIf
		Next( nX )
		
		//------------------------------------------------
		// Verifica se tem operador marcado
		//------------------------------------------------
		For nX := 1 To Len( aOper )
			If aOper[nX][01] 
				nOper++
				nPosOPer := nX
				If AllTrim( aOper[nX][05] ) == "2"
					nPosSup := nX
				EndIf			
			EndIf
		Next( nX )
		
		//-------------------------------------------------------
		// Se tem um grupo marcado
		//-------------------------------------------------------
		If lGroup .And. ( nOper + nPosSup ) > 0
			//---------------------------------------------------
			// Se tem pelo menos um operador marcado
			//---------------------------------------------------
			If nOper == 1
				cOperator	:= aOper[nPosOper][3]
				cUser		:= aOper[nPosOper][6]
				cName		:= Alltrim( aOper[nPosOper][2] )
			ElseIf nOper > 1 .Or. nPosSup > 0
				//---------------------------------------------------
				// Se tem pelo menos um supervisor no grupo
				//---------------------------------------------------
				If nPosSup > 0
					cOperator	:= aOper[nPosSup][3]
					cUser		:= aOper[nPosSup][6]
					cName		:= Alltrim( aOper[nPosSup][2] )
				Else
					Help("",1,"TK272TRFCH",,STR0177,1,0,,,,,,{STR0201})	//"Não existe nenhum operador de tipo supervisor no grupo."##"Selecione somente um operador no grupo de destino, para efetuar a transferência."
				EndIf
			Else
				Alert(STR0178)	//"Não existe nenhum operador ou supervisor selecionado para transferencia."
			EndIf
		ElseIf !lGroup .And. ( nOper + nPosSup ) > 0
			//---------------------------------------------------
			// Se tem pelo menos um operador marcado
			//---------------------------------------------------
			If nOper == 1
				cOperator	:= aOper[nPosOper][3]
				cUser		:= aOper[nPosOper][6]
				cName		:= Alltrim( aOper[nPosOper][2] )
			ElseIf nOper > 1
				//---------------------------------------------------
				// Se tem pelo menos um supervisor no grupo
				//---------------------------------------------------
				If nPosSup > 0
					cOperator	:= aOper[nPosSup][3]
					cUser		:= aOper[nPosSup][6]
					cName		:= Alltrim( aOper[nPosSup][2] )
				Else
					Help("",1,"TK272TRFCH",,STR0177,1,0,,,,,,{STR0201})	//"Não existe nenhum operador de tipo supervisor no grupo."##"Selecione somente um operador no grupo de destino, para efetuar a transferência."
				EndIf
			EndIf
		Else
			Alert(STR0178)	//"Não existe nenhum operador ou supervisor selecionado para transferencia."
		EndIf
	
	EndIf
	
	lRet := !Empty(cOperator)
	
Return( lRet )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272APesq

Rotina responsável por buscar o registro infomado pelo usuário nas list box de
grupos e operadores (A pesquisa sempre será com base no nome do grupo ou operador)

@param aIndPesq	, array		, conteúdo selecionado para pesquisa
@param cInd		, caracter	, conteúdo selecionado sendo 1= Grupo e 2= Operador
@param cPesq		, caracter	, conteúdo digitado
@param aGroup		, array		, contém os daods dos grupos
@param oLbxGrp		, objeto	, objeto do listbox do grupo
@param aOperator	, array		, contém os dados dos operadores
@param oLbxOper	, objeto	, objeto do listbox do operadores

@return lRet		, lógico	, Retorna se o registro pesquisado foi encontrado

@author  Thamara Villa Jacomo
@version P11
@since   24/01/2016
/*/
//------------------------------------------------------------------------------------------
Static Function Tk272APesq( aIndPesq, cInd, cPesq, aGroup, oLbxGrp, aOperator, oLbxOper )
	
	Local lRet  := .T.
	Local nScan := 0
	
	If cInd == "1" .And. !Empty( cPesq )
		nScan := aScan( aGroup,{ |x|  AllTrim( Upper( cPesq ) ) $ AllTrim( Upper( x[2] ) ) } )
		lRet := ( nScan > 0 )
		If lRet
			oLbxGrp:nAt := nScan
		EndIf
	ElseIf cInd == "2" .And. !Empty( cPesq )
		nScan := aScan( aOperator,{ |x|  AllTrim( Upper( cPesq ) ) $ AllTrim( Upper( x[2] ) ) } )
		lRet := ( nScan > 0 )
		If lRet
			oLbxOper:nAt := nScan
		EndIf
	Else
		lRet := .F.
		MsgInfo( STR0186, STR0187 ) //"Preencha os campos corretamente para efetuar a pesquisa. Para efetuar a busca completa, verifique se o grupo 'Todos' está selecionado." # "Pesquisa"
	EndIf
	
	Eval( b272Chg )
	
Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272MailPad(cCod, cLoja, cScript)
Cria modelo de email padrão na tabela AO6, caso o parâmetro MV_TMK341M esteja vazio.
@sample 	Tk341MailPad(cCod, cLoja, cScript) 
@param [cCod] 		Código do usuário
@param [cLoja] 	Loja 
@param [cScript]  Script de campanha respondido
@return	
@author	Philip Pellegrini
@since		25/06/2015       
@version	P12   
/*/
Static Function Tk272MailPad(cCod, cLoja, cScript)

	Local aCampos 			:= {}
	Local cRet				:= ""
	Local cCodigo			:= GetSX8Num("AO6","AO6_CODMOD") 
	Local nLenSX8			:= GetSx8Len()
	Local cBodyPadrao		:= Tk272MontaMgs(cScript)
	Local aArea             := GetArea()
	Local aAreaAO6          := AO6->(GetArea())
	Local aAreaSUS          := SUS->(GetArea())
	Local aAreaAO3			:= AO3->(GetArea())

	Local cFilAO2			:= xFilial("AO2")
	Local cFilAO6			:= xFilial("AO6")
		
	Private lMsErroAuto := .F.
	
	//Verifica se a entidade SUC está na AO2, caso não esteja, efetua o RecLock
	DBselectarea("AO2")  
	Dbsetorder(1)
	If !AO2->(DbSeek(cFilAO2+"SUC"))
		RecLock( "AO2", .T. )
		AO2->AO2_FILIAL := cFilAO2
		AO2->AO2_ENTID  := "SUC"
		AO2->AO2_DESCR  := STR0191 //"Atendimentos"
		AO2->AO2_ATIV   := '1'
		AO2->AO2_MEMAIL := '1'
		AO2->AO2_CEMAIL := '1'
		AO2->( MsUnlock() )
	EndIf
	
	//seleciona a área para executar a função CRM170MEEM() corretamente
	DBselectarea("AO6")
	aCampos:= { {"AO6_FILIAL",cFilAO6		           									,Nil}	,;
				{"AO6_CODMOD",cCodigo	                      							,Nil}	,;
				{"AO6_ENTMOD","SUC"                           							,Nil}	,;
				{"AO6_TITULO",STR0086 + Alltrim(cCod + cLoja) 							,Nil} 	,; //"Modelo de Atendimento Call Center
				{"AO6_MENSAG",cBodyPadrao   					 						,Nil} 	,;
				{"AO6_ASSUNT",(Iif(lClienteM,STR0132,(Iif(lProspect,STR0131,STR0124)))) 		+;
				 Alltrim(UsrFullName(AO3->AO3_CODUSR)) 									,Nil} 	,; //"Atendimento Call Center – Suspect/Prospect/Cliente "
				{"AO6_DESCRI",STR0125 + Alltrim(UsrFullName(AO3->AO3_CODUSR))  			,Nil} 	,; //"Você está recebendo uma notificação de atendimento realizado para a/o Suspect/Prospect/Cliente "
				{"AO6_ANEXO",	"2"								    					,Nil} 	,;
				{"AO6_MSBLQL","2"							       						,Nil}}
	//Efetua o gravação na AO6							
	MSExecAuto({|a,b| CRMA230(,a,b)}, 3,aCampos)  
	
	If lMsErroAuto
		While GetSx8Len() > nLenSX8 
			RollBackSX8()
		EndDo
	Else
		ConfirmSX8()    
		PutMv("MV_TMK341M",cCodigo)
		cRet := cCodigo
	EndIf

	RestArea(aAreaSUS)
	RestArea(aAreaAO6)
	RestArea(aAreaAO3)
	RestArea(aArea)

Return( cRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272MailAtv(cCod,cLoja,cScript)
Gera uma atividade do tipo Email usando o modelo de email padrão criado pela função Tk272MontaMgs.
@sample 	Tk272MailAtv(Código da Conta, Loja da Conta) 
@param [cCod] 		Código do usuário
@param [cLoja] 	Loja 
@param [cScript]  Script de Campanha respondido
@return	
@author	Philip Pellegrini
@since		25/06/2015       
@version	P12   
/*/
Static Function Tk272MailAtv(cCod,cLoja, cScript)

	Local aCampos     	:= {}
	Local cBodyPadrao 	:= Tk272MontaMgs(cScript)
	Local aArea       	:= GetArea()
	Local aAreaSUS    	:= SUS->(GetArea())
	Local aAreaAO3    	:= AO3->(GetArea())
	Local aAreaAO6    	:= AO6->(GetArea())
	Local cEnt        	:= (Iif(lClienteM,"SA1",(Iif(lProspect,"SUS","ACH"))))
	Local cTipoCam    	:= ""
	Local cResponsavel	:= ""
	Local cAliasAD1Tmp	:= GetNextAlias()

	Local cFilSUO			:= xFilial("SUO")
	Local cFilAO2			:= xFilial("AO2")
	Local cFilAO3			:= xFilial("AO3")
	Local cFilAO6			:= xFilial("AO6")
	Local cFilAOF			:= xFilial("AOF")
	
	//Responsável: caso tenha sido executada a rotina de oportunidade rápida, 
	//pega o usuário informado
	If lNewOport .And. (lClienteM .Or. lProspect)
		
		BeginSQL Alias cAliasAD1Tmp 
 			SELECT  AD1_VEND
 			FROM %TABLE:AD1% AD1
 			WHERE
 			AD1.AD1_CODTMK = %exp:M->UC_CODIGO% AND
 			AD1.%NotDel% 
 		EndSQl

		cResponsavel := (cAliasAD1Tmp)->AD1_VEND
	Else
		cResponsavel :=  cCodVend
	Endif 
	
	If	!Empty(cResponsavel)

		DBselectarea("SUS")
		DBselectarea("ACH")

		//Busca o Tipo da Campanha
		DBselectarea("SUO")
		Dbsetorder(1)//AO3_FILIAL+AO3_CODUSR
		If  DbSeek(cFilSUO +  M->UC_CODCAMP)
			cTipoCam := SUO->UO_TIPO
		Endif
 
		//Verifica se a entidade SUC está na AO2, caso não esteja, efetua o RecLock
		DBselectarea("AO2")
		Dbsetorder(1)
		If !AO2->(DbSeek(cFilAO2+"SUC"))
			RecLock( "AO2", .T. )
			AO2->AO2_FILIAL := cFilAO2
			AO2->AO2_ENTID  := "SUC"
			AO2->AO2_DESCR  := STR0191 //"Atendimentos"
			AO2->AO2_ATIV   := '1'
			AO2->AO2_MEMAIL := '1'
			AO2->AO2_CEMAIL := '1'
			AO2->( MsUnlock() )
		EndIf
	
		//Verifica se existe um Usuário CRM e se nele existe o campo email cadastrado
		DBSelectarea("AO3")
		DBSetorder(1)//AO3_FILIAL+AO3_CODUSR
		If DbSeek(cFilAO3 +  cResponsavel)

			If ! Empty(AO3->AO3_EXGEMA)

				DBselectarea("AO6")
				Dbsetorder(1)//AO6_FILIAL+AO6_CODMOD
				If DbSeek(cFilAO6 + __cEmailPad	)

					aCampos:= { {"AOF_FILIAL",cFilAOF							,Nil} ,;
								{"AOF_DESTIN",AO3->AO3_EXGEMA  					,Nil} ,;
								{"AOF_ENTIDA",cEnt          					,Nil} ,;
								{"AOF_CHAVE" ,(Iif(lClienteM,SA1->A1_COD+;
								SA1->A1_LOJA,(Iif(lProspect,SUS->US_COD+;
								SUS->US_LOJA,ACH->ACH_CODIGO+ACH->ACH_LOJA))))	,Nil} ,;
								{"AOF_CODUSR",AO3->AO3_CODUSR 					,Nil} ,;
								{"AOF_CHVCAM",""				  				,Nil} ,;
								{"AOF_CODCAM",M->UC_CODCAMP              		,Nil} ,;
								{"AOF_TIPCAM",cTipoCam			  				,Nil} ,;
								{"AOF_STATUS",'6'     		  					,Nil} ,;
								{"AOF_TIPO"  ,"3"     		  					,Nil} ,;
								{"AOF_DESCRI", CRM170MEEM(cBodyPadrao,cEnt) 	,Nil} ,;
								{"AOF_ASSUNT", (Iif(lClienteM,STR0132,(Iif(lProspect,STR0131,STR0124)))) + (Iif(lClienteM,Substr(SA1->A1_NOME,1,13),(Iif(lProspect,Substr(SUS->US_NOME,1,13),Substr(ACH->ACH_RAZAO,1,13)))))	,Nil }}//–STR0124 Atendimento Call Center – Suspect/Prospect/Cliente 

					//Efetua a gravação na AOF
					CRMA180(aCampos,3)
					
				EndIf
			Else
				Aviso(STR0043, STR0087 + AO3->AO3_CODUSR ,{"OK"})//"Atenção","Este usuário não possui Email cadastrado "
			Endif
		Else
			Aviso(STR0043, STR0088 +  RetCodUsr() ,{"OK"})//"Atenção", "Não existe registro na tabela de Usuários do CRM com esse código "
		Endif

	Endif 

	RestArea(aAreaSUS)
	RestArea(aAreaAO3)
	RestArea(aAreaAO6)
	RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272VeMail(cCodigo)
Função responsável por executar as rotinas de geração de E-mail
(Modelo de Email e Atividade do tipo Email).
Verifica a entidade e verifica a existência do Modelo padrão de Email.
Será executada a partir do fonte TMKA271A, ao confirmar a gravação da campanha.
@sample 	Tk272VeMail() 
@return	
@PARAM     	[cCodigo]  Código do atendimento enviado do Fonte TMKA271A, Função Tk271Grava. 
@author		Philip Pellegrini
@since		16/07/2015       
@version	P12
/*/
Function Tk272VeMail(cCodigo)

Local cScript 		:= ""
Local aArea  		:= {}
Local cAliasTmp     := ""
Local lRet			:= .T.
Local cTpAtend		:= TkGetTipoAte() 		//Retorna o tipo de atendimento,caso chamdo do teleatendimento 1-TMK, 2-TLV, 3-TLC

Default cCodigo		:= M->UC_CODIGO

If ( nFolder == 1 .And. TkGetTipoAte() $ "145" )

	//Envio de e-mail do atendimento do tmk se tiver usuarios do crm.
	DBSelectarea("AO3")
	DBSetorder(1)//AO3_FILIAL+AO3_CODUSR
	If DbSeek(xFilial("AO3"))
	
		DBselectarea("AO2")  
		DBSetorder(1)
		//Verifica se envio de e-mail está habilitado
		If AO2->(DbSeek(xFilial("AO2")+"SUC")) .And. AO2->AO2_MEMAIL <> "1" 
			lRet := .F.
		EndIf
		
		If lRet 
			
			If Empty( __cEmailPad )
				__cEmailPad := GetMV("MV_TMK341M",.F.,"")
			EndIf
			
			aArea  	  := GetArea()
			cAliasTmp := GetNextAlias()
		
			If !Empty( cCodigo )
				
				BeginSQL Alias cAliasTmp
				 	SELECT ACI.ACI_CODIGO
				 	FROM 
				 	%Table:ACI% ACI
				 	WHERE 
				 	ACI.ACI_ATEND = %exp:cCodigo% AND
					ACI.%NotDel%
				EndSql
			
				While !(cAliasTmp)->(Eof())		
					cScript += Tkc10MScr((cAliasTmp)->ACI_CODIGO)
					(cAliasTmp)->(DbSkip())
				End
				
				If !Empty(M->UC_ENTIDAD) 
				
					If Empty(__cEmailPad )
						__cEmailPad	 := Tk272MailPad(SUS->US_COD,SUS->US_LOJA, cScript)
					EndIf
					
					If !Empty( __cEmailPad	 )
						DbSelectArea("AO6")
						Dbsetorder(1)//AO6_FILIAL+AO6_CODMOD
						If DbSeek(xFilial("AO6") + __cEmailPad	)
							If M->UC_ENTIDAD <> "SA1"
								If lProspect
									Tk272MailAtv(SUS->US_COD,SUS->US_LOJA, cScript )
								Else
									Tk272MailAtv(ACH->ACH_CODIGO,ACH->ACH_LOJA, cScript )
								Endif
							Else
								lClienteM := .T.
								Tk272MailAtv(SA1->A1_COD,SA1->A1_LOJA, cScript )
							EndIf
						EndIf
					EndIf
				EndIf
				
			EndIf
		
			RestArea(aArea)
		
		EndIf
		
	EndIf
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272MontaMgs(cScript)
Monta a mensagem do Email a ser gerada em Modelos de Email e/ou em Atividades.
@sample 	Tk272MontaMgs(cScript) 
@param [cScript] Script de Email respondido
@return	
@author	Philip Pellegrini
@since		25/06/2015       
@version	P12   
/*/
Static Function Tk272MontaMgs(cScript)

  	Local cMsg 		 		:= "" 
 	Local cMidia     		:= ""
 	Local cCampanha  		:= ""
 	Local aArea      		:= GetArea()
 	Local aAreaSUO   		:= SUO->(GetArea())
 	Local aAreaSUH   		:= SUH->(GetArea())
 	Local cEnt       		:= (Iif(lClienteM,"SA1",(Iif(lProspect,"SUS","ACH"))))
 	Local cCampoFunc 		:= (Iif(lClienteM,"Cliente",(Iif(lProspect,"$!US_QTFUNC$!","$!ACH_QTFUNC$!"))))
 	Local nRetFunc   		:= CRM170MEEM(cCampoFunc,cEnt)
 	Local cTextoFunc 		:= ""
 	Local cCampoOrig 		:= (Iif(lClienteM,"$!A1_ORIGCT$!",(Iif(lProspect,"$!US_ORIGEM$!","$!ACH_ORIGEM$!"))))
 	Local nRetOrig   		:= CRM170MEEM(cCampoOrig,cEnt)
 	Local cTextOrig  		:= ""
 	Local cAliasTmp  		:= GetNextAlias()
 	Local cCodConta  		:= M->UC_CODCONT
 	Local cDescCnae  		:= ""
 	Local cDescEnt		:= ""
 	Local cAliasAD1Tmp	:= GetNextAlias()
 	Local cCgc				:= ""
 	Local cResponsavel	:= ""
 	
 	//Busca o número de funcionários do suspect ou prospect. Não existe o campo em Clientes
  	Do case 
	 	Case nRetFunc == "0"
	 	   cTextoFunc := "< 50"
	 	Case nRetFunc == "1"
	 	   cTextoFunc := "51 - 200"
	 	Case nRetFunc == "2"
	 	   cTextoFunc := "201 - 500"
	 	Case nRetFunc == "3"
	 	   cTextoFunc := "501 - 1000"
	 	Case nRetFunc == "4"
	 	   cTextoFunc := "1001 - 5000"
	 	Case nRetFunc == "5"
	 	   cTextoFunc := "> 5000"
 	EndCase

 	//Busca a descrição da origem da conta
 	Do case
 		Case nRetOrig == "1"
 			cTextOrig  := STR0140//"Mailing" 
 		Case nRetOrig == "2"
 			cTextOrig  := STR0141//"Campanha"
 		Case nRetOrig == "3"
 			cTextOrig  := STR0142//"Web"
 		Case nRetOrig == "4"
 			cTextOrig  := STR0143//"Indicação"
 		Case nRetOrig == "5"
 			cTextOrig  := STR0144//"Evento"
 		Case nRetOrig == "6"
 			cTextOrig  := STR0145//"Anúncio"
 		Case nRetOrig == "7"
 			cTextOrig  := STR0146//"Parceiro"
 		Case nRetOrig == "8"
 			cTextOrig  := STR0147//"Relações Públicas"
 		Case nRetOrig == "9"
 			cTextOrig  := STR0148//"Seminário"
 		Case nRetOrig == "A"
 			cTextOrig  := STR0149//"Boca-a-Boca"
 		Case nRetOrig == "B"
 			cTextOrig  := STR0150//"Outros"
 	EndCase

 	//Busca os dados do contato
	BeginSQL Alias cAliasTmp 
 		SELECT U5_CONTAT, U5_FUNCAO, U5_CELULAR, UM_DESC, U5_EMAIL
 		FROM %TABLE:SU5% SU5
 		LEFT JOIN %Table:SUM% SUM ON ( SUM.UM_CARGO = SU5.U5_FUNCAO ) 
 		WHERE
 		SU5.U5_CODCONT = %exp:cCodConta% AND
 		SU5.%NotDel% 
 	EndSQl

	//Busca a descrição do segmento
	cDescEnt := Posicione("AOV",1,xFilial("AOV")+ (Iif(lClienteM,SA1->A1_CODSEG,(Iif(lProspect,SUS->US_CODSEG,ACH->ACH_CODSEG)))) , "AOV_DESSEG")

	//Busca a descrição da campanha
	DbSelectArea("SUO")
	DbSetOrder(1)

	If DbSeek( xFilial("SUO") + M->UC_CODCAMP )
		cCampanha := SUO->UO_DESC
	Endif 

	//Busca a descrição da mídia
	DbSelectArea("SUH")
	DbSetOrder(1)

	If DbSeek( xFilial("SUH") + M->UC_MIDIA )
		cMidia := SUH->UH_DESC
	Endif

	//Busco a descrição do CNAE
	cDescCnae := Posicione("CC3",1,xFilial("CC3")+ (Iif(lClienteM,SA1->A1_CNAE,(Iif(lProspect,SUS->US_CNAE,ACH->ACH_CNAE)))) , "CC3_DESC")

	//Busca os dados da oportunidade
	BeginSQL Alias cAliasAD1Tmp 
 		SELECT AD1_NROPOR,AD1_DESCRI, AD1_DTINI, AD1_VEND
 		FROM %TABLE:AD1% AD1
 		WHERE
 		AD1.AD1_CODTMK = %exp:M->UC_CODIGO% AND
 		AD1.%NotDel% 
 	EndSQl

	//Tratamento do CNPJ
	Do case 
		Case lClienteM
			If Len(SA1->A1_CGC) < 14
				cCgc := Transform(SA1->A1_CGC,"@R 999.999.999-99")
			Else				 
				cCgc := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			Endif 

		Case lProspect
			If Len(SUS->US_CGC) < 14
				cCgc := Transform(SUS->US_CGC,"@R 999.999.999-99")
			Else
				cCgc := Transform (SUS->US_CGC,"@R 99.999.999/9999-99")	
			Endif

		Otherwise 
			If Len(ACH->ACH_CGC) < 14
				cCgc := Transform(ACH->ACH_CGC,"@R 999.999.999-99")
			Else 
				cCgc := Transform(ACH->ACH_CGC,"@R 99.999.999/9999-99")
			Endif 
	EndCase

	//Responsável: caso tenha sido executada a rotina de oportunidade rápida, 
	//pega o usuário informado
	If lNewOport .And. (lClienteM .Or. lProspect)
		cResponsavel := UsrFullName((cAliasAD1Tmp)->AD1_VEND)
	Else
		cResponsavel :=  UsrFullName(cCodVend)
	Endif 

	//Monta a mensagem
	cMsg := '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"><head><meta name=Generator content="Microsoft Word 15 (filtered medium)"> '
	cMsg += '</head><body lang=PT-BR link=blue vlink=purple> '
	cMsg += '<o:p></o:p></span></p></td></tr><tr style="height:2.25pt"><td style="padding:7.5pt 0cm 0cm 0cm;height:2.25pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Verdana",sans-serif;color:#202664"><o:p></o:p></span></p></td></tr></table></div><p class=MsoNormal><o:p>&nbsp;</o:p></p><div align=center>'
	cMsg += '<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'
	//**Dados dos responsáveis pela oportunidade no CRM**
	cMsg += STR0089+'<o:p></o:p></span></p></td></tr><tr>'
	cMsg += '<td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Responsável :
	cMsg += STR0090+'<o:p></o:p>'
	cMsg += '</span></p></td><td style="padding:0cm 0cm 0cm 0c m"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+ cResponsavel + '<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"></td></tr></table></td></tr></table></div><p class=MsoNormal>'
	cMsg += '<o:p>&nbsp;</o:p></p><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'
	//**Dados Atendimento**
	cMsg += STR0115+'<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt">'
	cMsg += '<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Código Campanha:
	cMsg += STR0116+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+M->UC_CODCAMP+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Descrição Campanha:
	cMsg += STR0117+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+cCampanha+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Código Mídia:
	cMsg += STR0118+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+M->UC_MIDIA+'</span></strong>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Descrição Mídia:
	cMsg += STR0119+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+cMidia+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"></td></tr></table></td></tr></table></div><p class=MsoNormal>'
	cMsg += '<o:p>&nbsp;</o:p></p><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'

	//**Dados da Empresa**
	cMsg += STR0093+'<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Código do (Cliente/Prospect/Suspect) :
	cMsg += (Iif(lClienteM,STR0134 ,(Iif(lProspect,STR0094,STR0133 ))))+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+ (Iif(lClienteM,"$!A1_COD$!",(Iif(lProspect,"$!US_COD$!","$!ACH_CODIGO$!")))) +'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Razão Social :
	cMsg += STR0095+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+ (Iif(lClienteM,"$!A1_NOME$!",(Iif(lProspect,"$!US_NOME$!","$!ACH_RAZAO$!")))) + '</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td>'
	cMsg += '</tr><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Nome Fantasia :
	cMsg += STR0096+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"$!A1_NREDUZ$!",(Iif(lProspect,"$!US_NREDUZ$!","$!ACH_NFANT$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//CNPJ/CPF :
	cMsg += STR0097+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+ cCgc +'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr>'
	cMsg += '<td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Negócio da Empresa (CNAE) :
	cMsg += STR0098+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"></span>'+(Iif(lClienteM,"$!A1_CNAE$!" + " " + cDescCnae,(Iif(lProspect,"$!US_CNAE$!" + " " + cDescCnae,"$!ACH_CNAE$!" + " "+cDescCnae))))+'</strong>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Segmento  :
	cMsg += STR0099+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+cDescEnt+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Endereço :
	cMsg += STR0100+'<o:p></o:p>'
	cMsg += '</span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"$!A1_END$!",(Iif(lProspect,"$!US_END$!","$!ACH_END$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Bairro :
	cMsg += STR0101+'<o:p></o:p></span></p></td>'
	cMsg += '<td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"$!A1_BAIRRO$!",(Iif(lProspect,"$!US_BAIRRO$!","$!ACH_BAIRRO$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Cidade :
	cMsg += STR0102+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"$!A1_MUN$!",(Iif(lProspect,"$!US_MUN$!","$!ACH_CIDADE$!"))))+'</span>'
	cMsg += '</strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//CEP :
	cMsg += STR0103+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"$!A1_CEP$!",(Iif(lProspect,"$!US_CEP$!","$!ACH_CEP$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p>'
	cMsg += '</td></tr><tr><td nowrap style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Estado :
	cMsg += STR0104+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"$!A1_EST$!",(Iif(lProspect,"$!US_EST$!","$!ACH_EST$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p>'
	cMsg += '</td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Telefone Comercial :
	cMsg += STR0105+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"$!A1_DDD$!" + "$!A1_TEL$!" ,(Iif(lProspect,"$!US_DDD$!" + "$!US_TEL$!","$!ACH_DDD$!" + "$!ACH_TEL$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p>'
	cMsg += '</td></tr><tr><td nowrap style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Site :
	cMsg += STR0106+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+Alltrim(Iif(lClienteM,"$!A1_HPAGE$!",(Iif(lProspect,"$!US_URL$!","$!ACH_URL$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p>'
	cMsg += '</td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	
	If !lClienteM
		//Porte/Faturamento :
		cMsg += STR0107+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(Iif(lClienteM,"",(Iif(lProspect,"$!US_FATANU$!","$!ACH_FATANU$!"))))+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p>'
		cMsg += '</td></tr><tr><td nowrap style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	Endif 
	//Descrição Origem:
	cMsg += STR0121+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+cTextOrig+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p>'
	cMsg += '</td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'	

	If !lClienteM
		//Funcionários :
		cMsg += STR0108+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+cTextoFunc+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"></td></tr></table></td></tr></table></div><p class=MsoNormal>'
		cMsg += '<o:p>&nbsp;</o:p></p><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'
	Else
		cMsg += '<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"></td></tr></table></td></tr></table></div><p class=MsoNormal>'
		cMsg += '<o:p>&nbsp;</o:p></p><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'
	Endif 

	//**Dados do Contato**
	cMsg += STR0110+'<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Nome :
	cMsg += STR0111+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(cAliasTmp)->U5_CONTAT+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr>'
	cMsg += '<td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Cargo :
	cMsg += STR0112+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+Alltrim((cAliasTmp)->UM_DESC)+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'//Cargo :
	//Email :
	cMsg += STR0113+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm">'//Email :
	cMsg += '<p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(cAliasTmp)->U5_EMAIL+'<a href="mailto:celinapaulista@terra.com.br"><span style="font-weight:normal"></span></a> </span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	//Telefone Celular :
	cMsg += STR0114+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(cAliasTmp)->U5_CELULAR+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"></td></tr></table></td></tr></table></div><p class=MsoNormal>'
	cMsg += '<o:p>&nbsp;</o:p></p><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'

	If lNewOport .And. (lClienteM .Or. lProspect)
		//**Dados da Oportunidade**
		cMsg += STR0135+'<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
		cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
		//Código :
		cMsg += STR0136+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(cAliasAD1Tmp)->AD1_NROPOR+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr>'
		cMsg += '<td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
		//Descrição :
		cMsg += STR0137+'<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+(cAliasAD1Tmp)->AD1_DESCRI+'</span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'//Cargo :
		//Data Início :
		cMsg += STR0138+'<o:p></o:p></span></p></td><td style="padding:0cm 0cm 0cm 0cm">'//Email :
		cMsg += '<p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'+DtoC(StoD((cAliasAD1Tmp)->AD1_DTINI))+'<a href="mailto:celinapaulista@terra.com.br"><span style="font-weight:normal"></span></a> </span></strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr><tr><td nowrap style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
		cMsg += '<o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td><td style="background:#E3ECF4;padding:0cm 0cm 0cm 0cm"></td></tr></table></td></tr></table></div><p class=MsoNormal>'
		cMsg += '<o:p>&nbsp;</o:p></p><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'
	Endif

	//**Observações Complementares**
  	cMsg += STR0122+'<o:p></o:p></span></p></td></tr><tr>'
  	cMsg += '<td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
  	cMsg += '<td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
    cMsg += M->UC_OBS

   //Script
   	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84"><o:p></o:p></span></p></td></tr></table></td></tr></table></div><p class=MsoNormal><o:p>&nbsp;</o:p></p><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=760 style="width:570.0pt;background:#A4C2DE"><tr><td style="padding:.75pt .75pt .75pt .75pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial",sans-serif;color:white">'
  	cMsg += STR0123+'<o:p></o:p></span></p></td></tr><tr>'
  	cMsg += '<td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
  	cMsg += '<td style="padding:0cm 0cm 0cm 0cm"><p class=MsoNormal><strong><span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'

  	cMsg += '<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	cMsg += '<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	
	cMsg += '<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'
	cMsg += '<o:p></o:p></span></p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt"><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;background:white"><tr><td width=150 nowrap style="width:112.5pt;padding:0cm 0cm 0cm 0cm"><p class=MsoNormal>'
	cMsg += '<span style="font-size:8.5pt;font-family:"Arial",sans-serif;color:#201D84">'

	cMsg += cScript
	
	(cAliasAD1Tmp)->(DbCloseArea())
	(cAliasTmp)->(DbCloseArea())
	RestArea(aAreaSUH)
	RestArea(aAreaSUO)
	RestArea(aArea)

Return cMsg

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272RVend()
Exibe tela para o usuário selecionar o Usuário de CRM que será atribuído controle total.
@sample 	Tk272RVend() 
@return	cCodVend - Código do Usuário CRM selecionado pelo usuário
@author	Philip Pellegrini
@since		20/07/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function Tk272RVend()

Local oDlg				:= Nil
Local oPanel			:= Nil                                      	//Objeto Dialog
Local oListBox		:= Nil                                        //Objeto ListBox
Local oFWLayer		:= Nil
Local oColPsq			:= Nil
Local oLayerPsq		:= Nil
Local oDlgPsq			:= Nil
Local oInd				:= Nil
Local oPesq			:= Nil
Local oColSeller		:= Nil
Local oLayerSeller	:= Nil
Local oColBut			:= Nil
Local oLayerBut		:= Nil
Local oDlgBut			:= Nil
Local oButOk			:= Nil
Local oButPesq		:= Nil
Local cAliasTmp		:= GetNextAlias()
Local cPesq			:= Space(120)
Local cInd				:= Space(120)
Local cVar				:= ""
Local cCodVend		:= ""
Local aIndPesq		:= {STR0194, STR0195, STR0196}	//"1=Cód.Vendedor"##"2=Cód.Usuário"##"3=Nome"
Local aVend    		:= {}
Local aArea			:= GetArea()
Local bPesq			:= {|| Tk272PSell(aIndPesq, cInd, cPesq, aVend, oListBox)}
Local bOk			:= {|| (cCodVend := aVend[oListBox:nAt,01], oDlg:DeActivate())}
Local aPDFields		:= {}	
Local aPDCols 		:= {}

//Seleciona a lista de Vendedores
BeginSql Alias cAliasTmp
	SELECT AO3.AO3_VEND, AO3.AO3_CODUSR
	  FROM %Table:AO3% AO3
	 WHERE AO3.AO3_FILIAL = %xFilial:AO3%
	   AND AO3.AO3_VEND != ''	
	   AND AO3.%NotDel%
	 ORDER BY AO3.AO3_VEND
EndSql

While !(cAliasTmp)->(Eof())
	aAdd(aVend, {(cAliasTmp)->AO3_VEND, (cAliasTmp)->AO3_CODUSR, UsrFullName((cAliasTmp)->AO3_CODUSR)})
	(cAliasTmp)->(DbSkip())
EndDo

//Caso não seja localizado registro na tabela A03 deve carregar o Cadastro de Vendedores.
If Len(aVend) == 0
	(cAliasTmp)->(DbCloseArea())
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT SA3.A3_COD,  SA3.A3_NOME, SA3.A3_CODUSR
		FROM %Table:SA3% SA3
		WHERE SA3.A3_FILIAL = %xFilial:SA3%
		AND SA3.%NotDel%
		ORDER BY SA3.A3_COD
	EndSql

	While !(cAliasTmp)->(Eof())
		aAdd(aVend, {(cAliasTmp)->A3_COD, (cAliasTmp)->A3_CODUSR, (cAliasTmp)->A3_NOME})
		(cAliasTmp)->(DbSkip())
	EndDo
EndIf

If Len(aVend) <> 0
	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.T.)
	oDlg:SetTitle(STR0126)	//"Favor, selecione o Vendedor"
	oDlg:SetEscClose(.F.)
	oDlg:SetSize(300, 400)
	oDlg:EnableFormBar(.F.)
	oDlg:CreateDialog()

	oPanel := oDlg:GetPanelMain()

	// Montagem dos layers superior de pesquisa
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oPanel, .F.)
	oFWLayer:AddLine("UP_BOX",   15, .T.)	//Layer Pesquisa
	oFWLayer:AddLine("DOWN_BOX", 70, .T.)	//Layer Vendedores
	oFWLayer:AddLine("BUT_BOX",  15, .T.)	//Layer Botões

	// Pesquisa
	oFWLayer:AddCollumn("PESQ_BOX", 100, .T., "UP_BOX")
	oColPsq		:= oFWLayer:GetColPanel("PESQ_BOX", "UP_BOX")

	oLayerPsq		:= FWLayer():New()
	oLayerPsq:Init(oColPsq, .F.)
	oLayerPsq:AddCollumn("COLL1", 100, .T., "LINE1")
	oLayerPsq:AddWindow("COLL1", "WIN1", STR0182, 100, .F., .F.,, "LINE1")	//"Pesquisar"

	oDlgPsq		:= oLayerPsq:GetWinPanel("COLL1", "WIN1", "LINE1")

	// Pesquisa por Código Usuário, Código Vendedor ou Nome
	@ 05,05 ComboBox oInd  Var cInd  Items aIndPesq Size 080,09 of oDlgPsq Pixel
	@ 05,90 MsGet    oPesq Var cPesq                Size 275,09 of oDlgPsq Pixel
	oButPesq		:= TBtnBmp2():New(06, 745, 26, 26, "BMPCONS",,,, bPesq, oDlgPsq, STR0182,, .T.) //"Pesquisar"

	//Vendedores
	oFWLayer:AddCollumn("SELLERS_BOX", 100, .T., "DOWN_BOX")
	oColSeller		:= oFWLayer:GetColPanel("SELLERS_BOX", "DOWN_BOX")

	oLayerSeller	:= FWLayer():New()
	oLayerSeller:Init(oColSeller, .F.)
	oLayerSeller:AddCollumn("COLL2", 100, .T., "LINE2")
	oLayerSeller:AddWindow("COLL2", "WIN2", STR0127, 100, .F., .F.,, "LINE2") //"Vendedores"

	oDlgSeller		:= oLayerSeller:GetWinPanel("COLL2", "WIN2", "LINE2")


	//Listbox dos Vendedores
	@ 30,10 LISTBOX oListBox VAR cVar FIELDS HEADER STR0199, STR0128, STR0200 COLSIZES 45,45,120 SIZE 165,105 Of oDlgSeller Pixel ////"Cód.Usuário"##"Cód.Vendedor"##"Nome Vendedor/Usuário"
	oListBox:Align	:= CONTROL_ALIGN_ALLCLIENT
	oListBox:SetArray(aVend)	//Atribuicao do conteudo da listbox
	oListBox:bLine	:= {|| { aVend[oListBox:nAt,01],;
							aVend[oListBox:nAT,02],;
							aVend[oListBox:nAT,03] }}

	If FATPDActive() .And. FTPDUse(.T.)
		aPDFields	:= {"A3_NOME"}
		aPDCols		:= {"","","A3_NOME"}   
		FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)	
		oListBox:aObfuscatedCols := FATPDColObfuscate(aPDCols) 
		FATPDUnload() 
	EndIf 
							
	oListBox:bLDblClick	:= bOk

	// Botões
	oFWLayer:AddCollumn("BUTTON", 100, .T., "BUT_BOX")
	oColBut		:= oFWLayer:GetColPanel("BUTTON", "BUT_BOX")

	oLayerBut		:= FWLayer():New()
	oLayerBut:Init(oColBut, .F.)
	oLayerBut:AddCollumn("COLL3", 100, .T., "LINE3")
	oLayerBut:AddWindow("COLL3", "WIN3", "", 100, .F., .F.,, "LINE3")

	oDlgBut		:= oLayerBut:GetWinPanel("COLL3", "WIN3", "LINE3")
	oButOk			:= TButton():New(02, 355, "Ok", oDlgBut, bOk, 030, 011, , /*oFont*/,,.T.,,,,/*bWhen*/)

	oDlg:Activate()
EndIf

(cAliasTmp)->(DbCloseArea())
RestArea(aArea)

aSize(aIndPesq	,0)
aSize(aVend		,0)
aSize(aArea		,0)
aSize(aPDFields	,0)
aSize(aPDCols	,0)
Return cCodVend

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272PSell()
Rotina responsável por buscar o registro infomado pelo usuário na Listbox de Vendedores
@param aIndPesq	, array		, conteúdo selecionado para pesquisa
@param cInd		, caracter	, conteúdo selecionado sendo 1= Grupo e 2= Operador
@param cPesq		, caracter	, conteúdo digitado
@param aVend		, array		, contém os dados dos Vendedores
@param oListBox	, objeto	, objeto do Listbox dos Vendedores
@return lRet		, lógico	, Retorna se o registro pesquisado foi encontrado
@author  Squad CRM/Faturamento
@version P12.1.17
@since   Nov/2018
/*/
//------------------------------------------------------------------------------------------
Static Function Tk272PSell(aIndPesq, cInd, cPesq, aVend, oListBox)

Local nScan	:= 0
Local lRet		:= (! Empty(cPesq))

If lRet .AND. ( lRet := ( ( nScan := aScan(aVend, {|x| AllTrim(cPesq) $ AllTrim(x[Val(cInd)])}) ) > 0 ) )
	oListBox:nAt := nScan
EndIf
If ! lRet
	Help("",1,"Tk272PSell",,STR0197,1,0,,,,,,{STR0198})	//"Não foi possível realizar a busca do Vendedor."##"Informe um dado válido para que a localização de um Vendedor ocorra com sucesso."
EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272OpUsu()
//Gera oportunidade rapida conforme acao utilizada no atendimento, 
Executa a tela de seleção de vendedores
@sample 	Tk272OpUsu(cEntida, cCodTmk) 
@Param		cEntida - Entidade (Prospect ou Cliente)
@Param		cCodTmk - Código do Atendimento
@author	Philip Pellegrini
@since		18/08/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function Tk272OpUsu(cEntida, cCodTmk)

Local aArea		:= {}
Local cQryAD1	:= ""
Local lGeraAD1	:= .F.
Local lRet		:= .T.
Local lCRMTerr  := SuperGetMV("MV_CRMTERR",.F.,.F.)	//Habilita distribuicao de conta e rodizio

Default cCodTmk	:= M->UC_CODIGO

If _lIndAD1 == Nil
	_lIndAD1 := !Empty(AD1->(IndexKey(7)))
EndIf

If lCRMTerr .And. _lIndAD1
	lRet := Tk272GerOp(cEntida)
Else
	If lUsuCRM
		cCodVend := Tk272RVend()
	Else
		//Verifica se o operador utiliza vendedor e se o mesmo está preenchido
		If SU7->U7_VEND == "1" .AND. !EMPTY(SU7->U7_CODVEN)
			cCodVend := SU7->U7_CODVEN
		Else
			cCodVend := RetCodUsr()
		EndIf	
	Endif

	If lNewOport
		//Verifica se já existe uma Oportunidade EM ABERTO ou SUSPENSA para o Atendimento TMK
		aArea		:= GetArea()
		cQryAD1	:= GetNextAlias()
		BeginSql Alias cQryAD1
			Select 'S' FOUNDAD1
			From %Table:AD1% AD1
			Where AD1.AD1_FILIAL = %xFilial:AD1%
			and AD1.AD1_CODTMK = %exp:cCodTmk%
			and AD1.AD1_STATUS in ('1','3')
			and AD1.%NotDel%
		EndSql
		lGeraAD1 := ! ( (cQryAD1)->FOUNDAD1 == "S" )
		(cQryAD1)->(dBCloseArea())
		RestArea(aArea)
		aArea	:= {}
		If lGeraAD1
			// Só gera a Oportunidade do Atendimento, se não existir uma Oportunidade em Aberto para o mesmo
			Do Case
				Case cEntida == "SUS"
					lRet := TK341ExecOpt( SUS->US_COD, SUS->US_LOJA, cCodVend, M->UC_CODIGO, cEntida )
				Case cEntida == "SA1"
					lRet := TK341ExecOpt( SA1->A1_COD, SA1->A1_LOJA, cCodVend, M->UC_CODIGO, cEntida )
			EndCase
		EndIf
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272GerOp(cEntida)
//Gera oportunidade rapida conforme acao utilizada no atendimento quando houver rodizio 

@sample 	Tk272OpUsu(cEntidade) 
@Param 	cEntidade, caracter, Alias da entidade em uso (exemplo SA1 ou SUS)
@author	Eduardo Gomes Junior 
@since		17/09/2015       
@version	P12
/*/
Function Tk272GerOp(cEntidade) 

Local aArea  	:= GetArea()

Local cCodEnt	:= ""	//Codigo da entidade
Local cLojEnt	:= ""	//Loja da entidade
Local cCodTerr	:= ""	//Codigo do territorio
Local cCodMemb	:= ""	//Codigo do membro
Local cTpMembr	:= ""	//Tipo de Membro
Local cCodVend	:= ""	//Codigo do vendedor na entidade
Local aRetVend	:= {}
Local lRet		:= .T.
Local lExecView	:= SuperGetMV("MV_TMKOPRA",.F.,.T.)	//Habilita 	

Local lGrOpor		:= .T.
Local cGrOpor		:= ""

dbSelectArea("AD1")
dbSetOrder(7)	//AD1_FILIAL+AD1_CODTMK   
If	!dbSeek(xFilial("AD1")+M->UC_CODIGO)
	
	If	cEntidade == "SA1"
		cCodEnt	:= SA1->A1_COD
		cLojEnt	:= SA1->A1_LOJA
		cCodTerr	:= SA1->A1_CODTER
		cCodMemb	:= SA1->A1_CODMEMB
		cTpMembr	:= SA1->A1_TPMEMB 
		cCodVend	:= SA1->A1_VEND	
	Else
		cCodEnt	:= SUS->US_COD
		cLojEnt	:= SUS->US_LOJA
		cCodTerr	:= SUS->US_CODTER
		cCodMemb	:= SUS->US_CODMEMB
		cTpMembr	:= SUS->US_TPMEMB
		cCodVend	:= SUS->US_VEND		 	
	Endif
	
	If	Empty(cCodVend) .OR. Empty(cCodTerr) .OR. Empty(cCodMemb) .OR. Empty(cTpMembr)
		lGrOpor := .F.
		cGrOpor := STR0153 + CHR(13)+CHR(10)	//Entidade não possui território definido no seu cadastro
		cGrOpor += STR0159 + CHR(13)+CHR(10)	//Entidade não possui vendedor responsável informado no cadastro
		cGrOpor += STR0173	//"Observação: Utilize uma ação que acione a distribuição de território/rodizio para gerar a oportunidade de venda."
	Endif

	If	!lGrOpor
		MsgAlert(cGrOpor,STR0043)	
	Else		
		//Considera vendedor informado (especifico)
		If	lUsuCRM  
			cCodVend := Tk272SlVendEsp()		
		Else
			//Considera vendedor dono (responsavel) pela entidade
			aRetVend := Tk272RetVend(cEntidade,cCodEnt,cLojEnt)	
				
			If	Len(aRetVend) > 0 .AND. !Empty(aRetVend[1])
				cCodVend := aRetVend[1]
			Endif 				
				
		Endif

		If !Empty(cCodVend)
			lRet := TK272ExecOpt(cEntidade, cCodEnt, cLojEnt, cCodVend, M->UC_CODIGO, lExecView )
			If	!lExecView .AND. lRet
				dbSelectArea("AD1")
				dbSetOrder(7)	//AD1_FILIAL+AD1_CODTMK   
				If	dbSeek(xFilial("AD1")+M->UC_CODIGO)
					MsgInfo(STR0175+AD1_NROPOR+STR0176+AD1_REVISA)	//"Gerada oportunidade de venda:"###" - Revisão:" 
				Endif 
			Endif 
			
		Else
			MsgAlert(STR0159)	//Entidade não possui vendedor responsável informado no cadastro
		EndIf
	EndIf  
Endif 		
		
RestArea(aArea)		
		
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} TK272ExecOpt
Aciona rotina FATA300 (Oportunidade de venda) para inclusao de oportunidade rapida  

@sample TK272ExecOpt( cEntidade, cCodEnt, cLojEnt, cCodVend, cCodAtend )
@param cEntidade, character, ALIAS da entidade pesquisada 
@param cCodEnt, character, Codigo da entidade
@param cLojEnt, character, Loja da entidade
@param cCodVend, character, Codigo do vendedor (SA3)
@param cCodAtend, character, Codigo do operador/atendente

@return lRetorno, Logico, Verdadeiro/Falso para indicar a criacao da oportunidade  
 
@author  Eduardo Gomes Junior 
@version P12
@since   17/09/2015  
/*/
//-------------------------------------------------------------------

Function TK272ExecOpt( cEntidade, cCodEnt, cLojEnt, cCodVend, cCodAtend, lExecView )

Local oModel 		:= FWLoadModel( "FATA300" )
Local oView			:= FWLoadView ( "FATA300" )
Local oStructAD1	:= oView:GetViewStruct( "AD1MASTER" )
Local oExecView  	:= Nil
Local lRetorno 		:= .F. 
Local aError		:= {}
Local cDescOP		:= SuperGetMV("MV_TMKODES",.F.,"Atendimento Call Center")

Local cNrOportu	:= ""

Default cEntidade	:= ""
Default cCodEnt	:= ""
Default cLojaEnt	:= ""
Default cCodVend	:= ""

Default lExecView := .T.

oStructAD1:SetProperty( "AD1_PROSPE" , MVC_VIEW_CANCHANGE,.F. )
oStructAD1:SetProperty( "AD1_LOJPRO" , MVC_VIEW_CANCHANGE,.F. )
oStructAD1:SetProperty( "AD1_VEND"   , MVC_VIEW_CANCHANGE,.F. )
oStructAD1:SetProperty( "AD1_CODCLI" , MVC_VIEW_CANCHANGE,.F. )
oStructAD1:SetProperty( "AD1_LOJCLI" , MVC_VIEW_CANCHANGE,.F. )

oModel:SetOperation( MODEL_OPERATION_INSERT )
oModel:Activate()

IF oModel != Nil .AND. oModel:IsActive()
	If	cEntidade == "SA1"	
		oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_CODCLI", cCodEnt	 )
		oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_LOJCLI", cLojEnt	 )
	Else
		oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_PROSPE", cCodEnt	 )
		oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_LOJPRO", cLojEnt	 )
	Endif 	
	
	oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_VEND"  	, cCodVend )
	oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_CODTMK"  , cCodAtend )
	
	//Time de venda 
	oModel:GetModel( "AD2DETAIL" ):LoadValue( "AD2_FILIAL", AD1_FILIAL	 )
	oModel:GetModel( "AD2DETAIL" ):LoadValue( "AD2_NROPOR", AD1_NROPOR	 )
	oModel:GetModel( "AD2DETAIL" ):LoadValue( "AD2_VEND"  , cCodVend )
	oModel:GetModel( "AD2DETAIL" ):LoadValue( "AD2_PERC"  , 100 )
	
	oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_DESCRI", cDescOP )
	oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_DTINI", dDataBase )
EndIf 

If ExistBlock("TK272OPT")
	ExecBlock("TK272OPT",.F.,.F.,oModel)
EndIf

If lExecView

	oExecView := FWViewExec():New()
	oExecView:SetTitle( STR0160 )	//"Oportunidade Rápida"
	oExecView:SetSource( "FATA300" )
	oExecView:SetOK({|oViewExec| lRetorno := Tk272CancelOp(oViewExec) })
	oExecView:SetModal( .T. )
	oExecView:SetOperation( MODEL_OPERATION_INSERT )
	oExecView:SetModel( oModel )
	oExecView:SetView(oView)
	oExecView:OpenView( .F. )
	oExecView:DeActivate()

Else

	If oModel:VldData()
	
		oModel:CommitData()
		lRetorno := .T.
		
	Else
		aError := oModel:GetErrorMessage()
		Help("",1,"TK272ExecOpt",,aError[6],1)
		lRetorno := .F.
	EndIf	
EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272CancelOp

Rotina responsável pelo retorno Falso caso o usuário cancele a operação de Oportunidade Rápida.

@param oViewExec, Objeto da oportunidade de venda 

@return lRetorno, lógico, verdadeiro/falso 

@author  Eduardo Gomes Junior 
@version P12
@since   17/09/2015
/*/
//------------------------------------------------------------------------------

Static Function Tk272CancelOp(oViewExec)

Local lRetorno := .T.
Local oModel	 := oViewExec:GetModel()
Local aError	 := {}

If !( oModel:VldData() )
	lRetorno := .F.
	aError := oModel:GetErrorMessage()
	Help("",1,"TK341VLDOP",,aError[6],1)
EndIf

Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} Tk272RetVend
Retorna informacoes do vendedor dono/responsavel pela entidade.  

@param cEntidade, character, ALIAS da entidade pesquisada 
@param cCodEnt, character, Codigo da entidade
@param cLojEnt, character, Loja da entidade
@return aMacrExec, array, {codigo do vendedor,codigo do territorio,codigo membro,tipo de membro,codigo usuario CRM,e-mail do usuario CRM }
 
@author  Eduardo Gomes Junior 
@version P12
@since   16/09/2015  
/*/
//-------------------------------------------------------------------

Function Tk272RetVend(cEntidade,cCodEnt,cLojEnt)

Local aArea 		:= GetArea()
Local aAreaAO3	:= AO3->(GetArea())

Local cCodVend	:= ""			//Codigo do vendedor
Local cCodTerr	:= ""			//Codigo do territorio
Local cCodMemb	:= ""			//Codigo do membro
Local cTpMembr	:= ""			//Tipo de Membro
Local aMacrExec	:= {"","","","",""}

//Avalia se entidade ja possui vendedor vinculado (dono)
dbSelectArea(cEntidade)
dbSetOrder(1)
If	dbSeek(xFilial(cEntidade)+cCodEnt+cLojEnt)

	cCodVend 	:= SubsTr(cEntidade,2,3)+"_VEND"		//Codigo do vendedor
	cCodTerr	:= SubsTr(cEntidade,2,3)+"_CODTER"		//Codigo do territorio
	cCodMemb	:= SubsTr(cEntidade,2,3)+"_CODMEMB"	//Codigo do membro		
	cTpMembr	:= SubsTr(cEntidade,2,3)+"_TPMEMB"		//Tipo de Membro
	
	aMacrExec := {&cCodVend,&cCodTerr,&cCodMemb,&cTpMembr,"",""}

	AZS->( DBSetOrder( 4 ) )
                    
	If ( AZS->( DbSeek(xFilial("AZS") + aMacrExec[1] ) ) )	
		aMacrExec[5] := AZS->AZS_CODUSR
		
		AO3->( DBSetOrder( 1 ) )
		
		If( AO3->( DBSeek(xFilial("AO3") + AZS->AZS_CODUSR ) ) )
			aMacrExec[6] := AO3->AO3_EXGEMA
		Endif				
	EndIf 
Endif

RestArea(aArea)
RestArea(aAreaAO3)

Return(aMacrExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} Tk272SlVendEsp
Interface para informar vendedor especifico para criacao de oportunidade de venda  

@sample Tk272SlVendEsp()
@param Nenhum 
@return cCodVend,character, Codigo do vendedor informado
 
@author  Eduardo Gomes Junior 
@version P12
@since   17/09/2015  
/*/
//-------------------------------------------------------------------

Static Function Tk272SlVendEsp()

Local aArea     := GetArea()
Local oDlg		:= Nil
Local oPanel	:= Nil 
Local nTmCod	:= TamSX3("A3_COD")[1]
Local cCodVend 	:= Space(nTmCod)
Local oCodVend
Local cNomVend 	:= Space(TamSX3("A3_NOME")[1])
Local oNomVend
Local bOk		:= {|| Tk272VldSA3(cCodVend,oDlg) }
Local lTK272VES := ExistBlock("TK272VES")

If lTK272VES
	cCodVend := ExecBlock("TK272VES",.F.,.F.)

	If ValType(cCodVend) == "C" .And. !Empty(cCodVend)
		cCodVend := PadR(cCodVend, nTmCod)
		RestArea(aArea)
		Return cCodVend 
	EndIf
EndIf

oDlg := FWDialogModal():New()
oDlg:SetBackground(.T.)
oDlg:SetTitle(STR0152)	//"Informe o Vendedor:"
oDlg:SetEscClose(.F.)
oDlg:SetSize(080,205)
oDlg:EnableFormBar(.T.)
oDlg:SetCloseButton(.F.)
oDlg:CreateDialog()
oDlg:CreateFormBar()
oDlg:AddButton(STR0130,bOk,STR0130, , .T., .F., .T., )       //Confirmar
oPanel := oDlg:GetPanelMain()
		
@ 03,03 TO 030,200 PIXEL OF oPanel

@ 05,010 SAY STR0128 	SIZE 50,10 PIXEL OF oPanel	//"Código:"
@ 05,045 SAY STR0078 	SIZE 50,10 PIXEL OF oPanel	//"Nome:"		

@ 13,008 MSGET oCodVend Var cCodVend 						SIZE 030,010 F3 "SA3"	PIXEL	OF oPanel VALID ( ExistCpo("SA3",cCodVend) .AND. ( cNomVend:=Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_NOME") ) )
@ 13,042 MSGET oNomVend Var cNomVend	 PICTURE "@!" 	SIZE 153,010 				PIXEL  OF oPanel WHEN .F. 

oDlg:Activate()

RestArea(aArea)

Return( cCodVend )

//-------------------------------------------------------------------
/*/{Protheus.doc} Tk272VldSA3
Valida codigo de vendedor informado na funcao Tk272SlVendEsp()

@sample Tk272VldSA3(cCodVend,oDlg)
@param cCodVend, character, Codigo do vendedor 
@param oDlg, Objeto, Nome do objeto usado
@return lRetorno, Lógico, Verdadeiro/Falso
 
@author  Eduardo Gomes Junior 
@version P12
@since   17/09/2015  
/*/
//-------------------------------------------------------------------

Static Function Tk272VldSA3(cCodVend,oDlg)

Local lRetorno	:= .T.
Local lRegBlq		:= .T.
Local lCodUsr		:= .T.
Local cMsgVld		:= ""

dbSelectArea("SA3")
dbSetOrder(1)
If	dbSeek(xFilial("SA3")+cCodVend)
		
		If	A3_MSBLQL == "1"
			lRegBlq := .F.
			cMsgVld += STR0161	//"Vendedor bloqueado"
		Endif
		
		If	Empty(A3_CODUSR)
		
			lCodUsr	:= .F.
			
			If	!Empty(cMsgVld)
				cMsgVld	+= Chr(13) + Chr(10) 
			Endif
			
			cMsgVld	+= STR0162	//"Vendedor informado não está incluído na estrutura de negócios"
			  
		Endif 
		
		If	!lRegBlq .OR. !lCodUsr
			lRetorno := .F.
			MsgAlert(cMsgVld)
		Else
			oDlg:DeActivate()			
		Endif
		
Else

	MsgAlert(STR0163)	//"Vendedor não encontrado"

	lRetorno := .F.
	
Endif

Return lRetorno

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
