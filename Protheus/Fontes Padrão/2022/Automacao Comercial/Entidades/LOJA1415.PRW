#INCLUDE "PROTHEUS.CH"
#INCLUDE  "LOJA1415.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |LOJA1415  º Autor ³ Vendas CRM		 º Data ³  05/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de rotas de limpeza,onde sera informado tabela    º±±
±±º          ³ que tera seus registros excluidos						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA						                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOJA1415()

Local cAlias	:= "MDR"				//falta comentario
Local aTabelas	:= {"MD6","MD7","MD8"} //falta comentario
Local nI		:= 0 					//controle de loop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existem as rotas MD6, MD7, MD8 ja cadastradas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aTabelas)
	
	DbSelectArea("MDR")
	DbSetOrder(2) //MDR_FILIAL + MDR_TABELA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao encontre, entao realiza o pre-cadastro³
	//³facilitando a utilizacao da limpeza            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(DbSeek(xFilial("MDR") + aTabelas[nI]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclui na tabela MDR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Reclock("MDR",.T.)
		Replace MDR->MDR_COD		With Ltrim( STR(nI))
		Replace MDR->MDR_FILIAL		With xFilial("MDR")
		Replace	MDR->MDR_TABELA		With aTabelas[nI]
		Replace	MDR->MDR_HABILI		With .T.
		Replace MDR->MDR_MODO 		With "T"
		If aTabelas[nI] <> "MD6"
			Replace	MDR->MDR_COND1		With aTabelas[nI] + "_STATUS NOT IN ('1','3')"
		EndIf
		MsUnLock()
	EndIf
	
Next nI


dbSelectArea (cAlias)
dbSetOrder(1)
AxCadastro(cAlias, STR0014, ".T.", ".T.")//"Cadastro de Rotas de Limpeza"

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |LJ1415LP  º Autor ³ Vendas CRM		 º Data ³  07/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Executa rotina de limpeza para 							  º±±
±±º          ³ loja off-line											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA						                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ1415LP(lJob)

Local cAlias 		:= "MDR"	//Tabela com as rotas de limpeza
Local cQuerySel 	:= ""		//Armazena as queries de consulta
Local cQueryDel 	:= ""		//Armazena os scripts SQL de exclusao
Local cQueryUpd 	:= ""		//Armazena os scripts SQL de atualizacao
Local cTabela 		:= ""		//Tabela de origem onde sera realizada a limpeza
Local cCond 		:= ""		//Condicao de consulta e exclusao dos registros na tabela de origem (cCond1+cCond2+cCond3)
Local cCond1 		:= ""		//1a condicao
Local cCond2 		:= ""		//2a condicao
Local cCond3 		:= ""		//3a condicao
Local cHoraExe 		:= ""		//Horario agendado para execucao
Local cHoraAtual	:= ""		//Horario atual, desconsiderando os segundos.
Local cElapsed 		:= ""		//Diferença entre o horario agendado e o horario atual
Local cCondMD6 		:= ""		//Condicao Especifica para a tabela MD6
Local cCondMD7 		:= ""		//Condicao Especifica para a tabela MD7
Local cCondMD8 		:= ""		//Condicao Especifica para a tabela MD8
Local cGroupBy 		:= ""		//Condicao de agrupamento
Local nCount 		:= 0		//Contador da quantidade de registros que serao excluidos da tabela de origem
Local lConfirma 	:= .F.		//recebe a confirmacao do usuario/job se a rotina sera executada
Local cMsgFinal 	:= ""		//Mensagem final exbida para o usuario com o resultado final da operacao
Local cTeste		:= ""		//Recebbe o retorno das funcoes iniciadas com & informadas pelo usuario nos campos Cond1,Cond2,Cond3
Local cLog 			:= ""		//Recebe a linha que será registrada no arquivo de log
Local nI 			:= 0		//Controle de loop
Local cPipe 		:= ""		//Recebe o caracter Pipe ou espaco em branco para concatenar com o conteudo do log
Local aTABREG 		:= ""		//Array temporario que contem o registro que sera excluido.
Local lMsgFinal		:= .T. 

Default lJob := .F. 	//Informa se a rotina foi iniciada via Job ou Tela

#IFDEF TOP
	
	//Objeto para gravação de LOG
	oLog		:= LJCLogIntegracao():New()
	
	cQuerySel	:= "SELECT MDR_TABELA,MDR_FILIAL,MDR_COND1,MDR_COND2,MDR_COND3,MDR_HORA,MDR_ULTEXE,MDR_MODO FROM " +RetSQLName(cAlias)
	cQuerySel	+= " WHERE MDR_HABILI='T' "
	cQuerySel	+= " ORDER BY MDR_COD "
	cQuerySel	:= ChangeQuery(cQuerySel)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySel),'MDRTMP',.F.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³//PARA CADA ROTA HABILITADA, EXCLUIR OS                          ³
	//³REGISTROS DE SUA RESPECTIVA TABELA CONFORME CONDICOES CADASTRADAS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !MDRTMP->(EOF())
		
		cTabela		:= Trim(MDRTMP->MDR_TABELA)
		cCond1		:= Rtrim(MDRTMP->MDR_COND1)
		cCond2		:= Rtrim(MDRTMP->MDR_COND2)
		cCond3		:= Rtrim(MDRTMP->MDR_COND3)
		cCond		:= ""
		cMsgFinal	:= ""
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a limpeza for executada via JOB,sera analisado se o modo de  |
		//³execucao da rotina :MANUAL(M),JOB (J), OU TODOS (T).            |
		//³A rota so sera executada se o modo de execucao for J ou T       |
		//|																   |
		//|Verificar se o horario atual e maior ou igual ao horario        ³
		//³agendado para execucao da rota de limpeza e se a mesma ainda    ³
		//³não foi executada no dia.Ser a rota não tiver horario agendado  ³
		//³para execucao, a mesma nao sera executada 		               |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		
		If Empty(MDRTMP->MDR_MODO) 
			MDRTMP ->(DbSkip())	 // ANALISAR PROXIMA ROTA DE LIMPEZA
			Loop
		Endif
		
		If lJob								
			If MDRTMP->MDR_MODO <> "M" //SE O MODO DE EXECUCAO FOR J ou T				
				If !Empty(MDRTMP->MDR_HORA)
					cHoraExe	:= Alltrim(MDRTMP->MDR_HORA) + ":00"
					cHoraAtual	:= Substr(Time(),1,2) + Substr(Time(),3,3) + ":00"			
					
					If !((cHoraAtual >= cHoraExe) .AND. Substr(MDRTMP->MDR_ULTEXE,1,8) <> Dtoc(dDataBase))			
						MDRTMP ->(DbSkip())	 // ANALISAR PROXIMA ROTA DE LIMPEZA
						Loop
					EndIf
				Else //SE O MODO DE EXECUCAO FOR M
					MDRTMP ->(DbSkip())	 // ANALISAR PROXIMA ROTA DE LIMPEZA
					Loop
				EndIf	
			Else
				MDRTMP ->(DbSkip())	 // ANALISAR PROXIMA ROTA DE LIMPEZA
				Loop	
			EndIf			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a limpeza não for executada via Job, a mesma so sera executada³
		//³se o modo de execucao for M ou T.Ignorar horario de agendamento  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		Else						
			
			If MDRTMP->MDR_MODO = "J" //SE O MODO DE EXECUCAO FOR J
				MDRTMP ->(DbSkip())	
				Loop
			EndIf			
		EndIf
		
		
		Do Case						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a tabela de origem for MD6 (SAIDA) verificar     ³
			//³a existencia obrigatoria da transacao correspondente³
			//³na tabela MD7 com status 2 (processado)             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			Case cTabela == "MD6"
				cQuerySel	:=	'SELECT MD6_TRANS,MD6_REG,MD6_PACOTE ,MD6_DATA , COUNT(R_E_C_N_O_) COUNTRECNO ' + ;
				' FROM ' + RetSQLName(cTabela) +  ' MD6 ' ;
				
				cGroupBy	:=	' GROUP BY  MD6_TRANS,MD6_REG,MD6_PROCES,MD6_PACOTE ,MD6_DATA '
				
				cCondMD6	:=	' (NOT MD6_TRANS = (SELECT MAX(MD6_TRANS) FROM ' + RetSQLName(cTabela) + ' )) AND EXISTS (SELECT 1 FROM '+ RetSQLName("MD7") + ' MD7 WHERE MD6.MD6_TRANS = MD7.MD7_TRANS AND MD7.MD7_STATUS = 2) '
				
				If Empty(cCond)
					cCond 	+=	' WHERE ' + cCondMD6
				Else
					cCond 	+=	' AND ' + cCondMD6
				EndIf
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a tabela for MD7 , a transacao correspondente         ³
				//³na tabela MD6 devera ter sido excluida  e as demais      ³
				//³condicoes informada pelo usuario deverao ser verdadeiras.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
			Case cTabela == "MD7"
				
				cQuerySel	:=	'SELECT MD7_TRANS , COUNT(R_E_C_N_O_) COUNTRECNO ' + ;
				' FROM ' + RetSQLName(cTabela) + ' ' +  cTabela
				
				cGroupBy	:=	' GROUP BY MD7_TRANS '
				
				cCondMD7	:=	' (NOT MD7_TRANS = (SELECT MAX(MD7_TRANS) FROM ' + RetSQLName(cTabela) + ' )) AND NOT EXISTS (SELECT 1 FROM '+ RetSQLName("MD6") + ' MD6 WHERE MD6.MD6_TRANS = MD7.MD7_TRANS ) '
				
				If Empty(cCond)
					cCond	+=	' WHERE ' + cCondMD7
				Else
					cCond	+=	' AND ' + cCondMD7
				EndIf
				
			Case cTabela == "MD8"
				
				cQuerySel	:=	'SELECT MD8_TRANS,MD8_REG,MD8_PACOTE ,MD8_DATA , COUNT(R_E_C_N_O_) COUNTRECNO ' + ;
				' FROM ' + RetSQLName(cTabela) +  ' MD8 ' ;
				
				cGroupBy	:=	' GROUP BY  MD8_TRANS,MD8_REG,MD8_PROCES,MD8_PACOTE ,MD8_DATA '
				
				
				cCondMD8	:=	' (NOT MD8_TRANS = (SELECT MAX(MD8_TRANS) FROM ' + RetSQLName(cTabela) + ' )) '
				
				If Empty(cCond)
					cCond	+=	' WHERE ' + cCondMD8
				Else
					cCond	+=	' AND ' + cCondMD8
				EndIf
				
			Otherwise
				cGroupBy	:=	''
				cQuerySel	:=	'SELECT COUNT(R_E_C_N_O_) COUNTRECNO FROM ' + RetSQLName(cTabela) + ' ' + cTabela + ' '
		EndCase
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³CONDICOES DE EXCLUSAO:                        ³
		//³                                              ³
		//³Para execucao de funcoes informadas nos campos³
		//³COND1,COND2 ou COND3, a mesmas deverao ser    ³
		//³precedidas de "&", sempre obedecendo a        ³
		//³sintaxe SQL.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//CONDICAO 1
		If !Empty(cCond1)
			If "&" $ Rtrim(cCond1)
				cTeste := &(SubStr( cCond1,AT("&",cCond1) + 1,Len(Rtrim(cCond1))))
			Else
				cTeste := Rtrim(cCond1)
			EndIf
			If cTeste <> ""
				If Empty(cCond)
					cCond += " WHERE " + cTeste
				Else
					cCond += " AND " + cTeste
				EndIf
			EndIf
		Else
			If cTabela <> "MD6" .AND. cTabela <> "MD7" .AND. cTabela <> "MD8"
			    cMsgFinal := STR0015 + cTabela +  STR0016 //"Rotina de limpeza não executada na tabela ",". Informe uma condicao no cadastro de rotas de limpeza."
			    oLog:Gravar(cMsgFinal)				
				Conout (cMsgFinal)    				
				If !(lJob)
				  	MsgAlert (cMsgFinal)
				EndIf 
						
			    MDRTMP ->(DbSkip())	 // ANALISAR PROXIMA ROTA DE LIMPEZA
				Loop  
				
			EndIf			
		EndIf
		
		//CONDICAO 2
		If !Empty(cCond2)
			If "&" $ Rtrim(cCond2)
				cTeste := &(SubStr( cCond2,AT("&",cCond2) + 1,Len(Rtrim(cCond2))))
			Else
				cTeste := Rtrim(cCond2)
			EndIf
			If cTeste <> ""
				If Empty(cCond)
					cCond += " WHERE " + cTeste
				Else
					cCond += " AND " + cTeste
				EndIf
			EndIf
		EndIf
		
		//CONDICAO 3
		If !Empty(cCond3)
			If "&" $ Rtrim(cCond3)
				cTeste := &(SubStr( cCond3,AT("&",cCond3) + 1,Len(Rtrim(cCond3))))
			Else
				cTeste := Rtrim(cCond3)
			EndIf
			If cTeste <> ""
				If Empty(cCond)
					cCond += " WHERE " + cTeste
				Else
					cCond += " AND " + cTeste
				EndIf
			EndIf
		EndIf
		
		cQuerySel += cCond + cGroupBy
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contagem dos registros 			  ³
		//³de acordo com as condicoes acima.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cQuerySel := ChangeQuery(cQuerySel)
		dbUseArea (.T.,"TOPCONN",TCGenQry(,,cQuerySel),'COUNTTMP',.T.,.T.)
		oLog:Gravar(TCSQLError())
		Conout(TCSQLError())
		
		
		
		If !COUNTTMP -> (EOF()) .AND. COUNTTMP-> COUNTRECNO > 0
			
			If lJob
				lConfirma := .T.
			Else
				If MsgYesNo(STR0008 + cTabela + "?", STR0009)//"Deseja realmente executar a rotina de limpeza na tabela ","Atencao"
					lConfirma := .T.
				Else
					lConfirma := .F.
				EndIf
			EndIf
			
			If lConfirma
				
				oLog:Gravar( Repl("-", 28) )
				Conout(Repl("-", 28))
				oLog:Gravar(STR0012)//"INICIO DA ROTINA DE LIMPEZA"
				Conout(STR0012)
				oLog:Gravar( Repl("-", 28) )
				Conout(Repl("-", 28))
				oLog:Gravar( STR0001 + " : " + cTabela + " / " + RetSQLName(cTabela))//Inicio da Limpeza na Tabela
				Conout(STR0001 + " : " + cTabela + " / " + RetSQLName(cTabela))
				nCount := 0				
				
				//ÚÄÄÄÄÄÄÄÄ¿
				//³EXCLUSAO³
				//ÀÄÄÄÄÄÄÄÄÙ
				
				While !COUNTTMP->(EOF())
					nCount += COUNTTMP-> COUNTRECNO
					Do Case
						Case cTabela == "MD6"
							
							cQueryDel	:= 'DELETE FROM ' + RetSQLName("MD6") + ;
										   ' WHERE MD6_TRANS = ' +  COUNTTMP->MD6_TRANS        
										   
							cLog		:= " MD6_TRANS : "	+ COUNTTMP->MD6_TRANS 	+ " | " + ;
										   " MD6_REG : "	+ COUNTTMP->MD6_REG 	+ " | " + ;
										   " MD6_PACOTE : "	+ COUNTTMP->MD6_PACOTE 	+ " | " + ;
										   " MD6_DATA : "	+ COUNTTMP->MD6_DATA 	+ " | "
							
							oLog:Gravar(cLog)
							Conout (cLog)
							
							TCSQLEXEC(cQueryDel)
							oLog:Gravar(TCSQLError())
							
						Case cTabela == "MD7"
							
							cQueryDel := 'DELETE FROM ' + RetSQLName("MD7") + ;
										 ' WHERE MD7_TRANS = ' +  COUNTTMP->MD7_TRANS
							
							cLog := "MD7_TRANS : " 	+ COUNTTMP->MD7_TRANS
							oLog:Gravar(cLog)
							Conout (cLog)
							
							TCSQLEXEC(cQueryDel)
							oLog:Gravar(TCSQLError())
							Conout (TCSQLError())
							
						Case cTabela == "MD8"
							
							cQueryDel := 'DELETE FROM ' + RetSQLName("MD8") + ;
										 ' WHERE MD8_TRANS = ' +  COUNTTMP->MD8_TRANS
							
							
							cLog := "MD8_TRANS : "		+ COUNTTMP->MD8_TRANS 	+ " | " + ;
									" MD8_REG : "		+ COUNTTMP->MD8_REG 	+ " | " + ;
									" MD8_PACOTE : "	+ COUNTTMP->MD8_PACOTE 	+ " | " + ;
									" MD8_DATA : "		+ COUNTTMP->MD8_DATA 	+ " | "
							
							oLog:Gravar(cLog)
							
							TCSQLEXEC(cQueryDel)
							oLog:Gravar(TCSQLError())
							
							Conout(cLog)
							Conout(TCSQLError())
							
						Otherwise
							
							cQuerySel := 'SELECT * FROM ' + RetSQLName(cTabela) + ' ' + cTabela + ' '  +  cCond + cGroupBy
							dbUseArea (.T.,"TOPCONN",TCGenQry(,,cQuerySel),'TABREGS',.T.,.T.)//SELECIONAR TODOS REGISTROS A SEREM EXCLUIDOS
							oLog:Gravar(TCSQLError())
							
							While !TABREGS->(EOF())
																
								cQuerySel := 'SELECT * FROM ' + RetSQLName(cTabela) + ' ' + cTabela + ' WHERE R_E_C_N_O_ = ' + Str(TABREGS -> R_E_C_N_O_)
								cQuerySel := ChangeQuery(cQuerySel)
								dbUseArea (.T.,"TOPCONN",TCGenQry(,,cQuerySel),'TABREG',.T.,.T.)//SELECIONAR UM REGISTRO ESPECIFICO
								oLog:Gravar(TCSQLError())
								Conout(TCSQLError())				
								
								cQueryDel := ''
								cQueryDel := 'DELETE FROM ' + RetSQLName(cTabela) + ' WHERE R_E_C_N_O_ = ' + Rtrim(Str(TABREGS -> R_E_C_N_O_))  //EXCLUIR UM REGISTRO ESPECIFICO
								TCSQLEXEC(cQueryDel)
								oLog:Gravar(TCSQLError())
								Conout(TCSQLError())
																
								If Select ("TABREG") > 0
									aTABREG := Array(FCount())
									For ni := 1 To 4
										
										If !Empty (cLog)
											cPipe := " | "
										Else
											cPipe := ""
										EndIf
										
										If !Empty (FieldGet(i))
											cLog += cPipe + FieldName(i) 	+  " : " + FieldGet(i)
									Else
											cLog += cPipe + FieldName(i) 	+  " : "
										EndIf
									Next
									oLog:Gravar(Rtrim(cLog))
									Conout(cLog)
									TABREG-> (DbCloseArea())
									cLog := ""
									
								EndIf
								TABREGS->(DbSkip())
								
							EndDo
							TABREGS->(DbCloseArea())
							
					EndCase
					COUNTTMP->(DbSkip())
				EndDo                          
				oLog:Gravar("")
				If nCount > 1
					cMsgFinal :=  STR0002 + Ltrim(Str(nCount)) + STR0003 + cTabela	//"Foram excluidos "," registros da tabela "
				Else
					cMsgFinal :=  STR0011 + cTabela	//"Foi excluído 1 registro da tabela "
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizar o horario da ultima execucao desta rota de limpeza.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQueryUpd := "UPDATE " + RetSQLName("MDR") + " SET MDR_ULTEXE = '" + Dtoc(dDatabase) + ' ' + Time() + ;
					    	 "' WHERE MDR_TABELA = '" + cTabela + "'"
				
				TCSQLEXEC (cQueryUpd)
				
			EndIf
		EndIf
		
		
		If !(lJob)
			If lConfirma			
				MsgAlert (cMsgFinal,STR0005) //"Resultado da Limpeza"
				lMsgFinal := .F.
			EndIf
		EndIf
		oLog:Gravar(cMsgFinal)
		oLog:Gravar(tcsqlerror())
		Conout (cMsgFinal)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisar proxima rota de limpeza.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MDRTMP ->(DbSkip())
		COUNTTMP->(DbCloseArea())
		lConfirma := .F.
		
		
	EndDo
	
	MDRTMP->(dbCloseArea())
	If nCount > 0
		cMsgFinal :=STR0006
		Conout (cMsgFinal)
	Endif	
				
	If !(lJob)
		If lMsgFinal
			MsgAlert(STR0010)  //"Nenhum registro foi encontrado pela rotina de limpeza"
		Endif			
	Endif	
	
	If !(lJob)
		If lConfirma
			MsgAlert (cMsgFinal,STR0007)//"Resultado"
		EndIf
	EndIf
	
	oLog := NIL
#EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SqlCmpData       º Autor ³ Vendas CRM		    º Data ³  12/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna clausula SQL para comparacao de um campo data.			 º±±
±±º          ³ 																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA						                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SqlCmpData(cCampo,cOperador,dData,nDias)

Local cSqlClause	:= ""	//Retorna clausula SQL para comparacao de um campo data.

Default cCampo		:= ""	//Campo que sera comparado
Default cOperador	:= ""	//Operador utilizado na comparacao
Default dData 		:= ""	//Data que será comparada ao campo da tabela, caso nao seja informada será considerada a data corrente
Default nDias		:= 0	//Dias que seao substraidos da data comparada ao campo da tabela


If !Empty(cCampo) 	.AND. !Empty(cOperador)
	If !Empty(dData)
		cSqlClause := cCampo + " " + cOperador+ " '" + DtoS((Ctod(dData) - nDias))+ "'"
	Else
		cSqlClause := cCampo + " " + cOperador+ " '" + DtoS(dDatabase - nDias)+ "'"
	EndIf
EndIf


Return cSqlClause
