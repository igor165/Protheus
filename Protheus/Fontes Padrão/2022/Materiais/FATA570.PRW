#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA570.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fata570   | Autor ³ Deosdete P. da Silva          ³ Data ³25.01.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Este processamento gera o rodízio automático entre os               ³±±
±±³          ³ prospects x vendedores.                                             ³±±
±±³          ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Totvs -                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodigo - Do Prospect ou Suspect a ser atendido                     ³±±
±±³          ³ cCodVen - Codigo do vendedor, caso este ja esteja definido (reserva-³±±
±±³          ³ do). Se este parametro for passado anulara o processamento da rotina³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo do vendededor qualificado                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fata570(cCodigo, cCodVen, lReserva)

Local aArea			:= GetArea()			   			// Salva a área atual antes de iniciar esse processo.
Local aAreacAlias	:= {}								// Salva a área atual antes de iniciar esse processo.
Local aAreaSA3		:= SA3->(GetArea())				// Salva a área atual antes de iniciar esse processo.
Local aAreaACH		:= ACH->(GetArea())				// Salva a área atual antes de iniciar esse processo.
Local aAreaSUS		:= SUS->(GetArea())				// Salva a área atual antes de iniciar esse processo.
Local aTipRegr		:= {}			  					// Array contendo Codigo, Informacao e Peso de todos os tipos de regra
Local cAlias		:= ""			   					// Tabela origem da Informacao a ser comparada na regra
Local cQryVend		:= "FA570A3"	   					// Nome para o arquivo temporario da Query da fila de vendedores
Local cQuery		:= ""			   					// Contem a string do sql para gerar a fila de vendedores
Local lAchou		:= .F.			   					// Informa que um vendedor foi qualificado
Local cVend			:= ""			   					// Contem o vendedor qualificado
Local cVlrCpo		:= ""			   					// Contem a informacao a ser comparada na regra
Local nI			:= 0								// Variavel auxiliar para laco
Local cCpo			:= ""								// Campo que contem a informacao a ser comparada na regra
Local _cVar			:= ""			   			 		// Varivel campo que contem a informacao a ser comparada na regra
Local lFA570RGR		:= ExistBlock("FA570RGR")  			// P.E. para entrada da informacao a ser comparada na regra.

// SLA
Local oSLARegister 										// Objeto de registro de SLA
Local oEntity											// Objeto de entidades
Local entities		:= {}								// Array com as entidades
Local severityCode 	:= SuperGetMV( "MV_TMKSEV",,100)	// Codigo da severidade (prospect com reserva)
Local codRespons	:= "000001"							// Codigo do responsavel
// SLA

DEFAULT lReserva := .F.					// A reserva default vem falso
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro obrigatorio cCodigo = codigo do suspect ou ³
//³prospect.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(cCodigo) == "C"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao aplicar rodizio se vendedor reservado e ja definido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If Empty(cCodVen) .OR. cCodVen <> GetMV("MV_VENDPAD")
	If lReserva
		cVend := cCodVen

		FT570Pos( cCodigo, cVend )		//Posiciona nas entidades utilizadas pelo rodizio
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo quando for reserva de vendedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ExecCRMPro("000022")

		If ChkFile("SK5") .AND. ChkFile("SK8")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclusao do SLA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SK8->(DbSetOrder(2))
			If SK8->(DbSeek( xFilial("SK8") + SA3->A3_CODUSR))
				codRespons := SK8->K8_CODUSU
			Endif
			
			oEntity := SLAEntity():New()
			oEntity:entityName	:= 'I5'

			oEntity:entityValue	:= '000022'
			aAdd(entities, oEntity)	    
		
			oSLARegister := SLARegister():New()
			If oSLARegister:start(entities, severityCode, codRespons)
				ConOut("Contrato de SLA: " + oSLARegister:SlaFound)
				//Salva o registro de SLA (SK5)
				oSLARegister:save()
				
				Reclock("SA3",.F.)
				SA3->A3_REGSLA := oSLARegister:RegisterID
				MsUnlock()
			Else
				ConOut("Nao foi possivel iniciar um registro de SLA")
			EndIf
		Endif
		RestArea(aAreaSA3)
		RestArea(aAreaACH)
		RestArea(aAreaSUS)
	Else //Vendedor nao informado   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pegar dados do suspect ou prospect, conforme tipos de regras cadastrados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("ADI")
		DbSetOrder(1)
		ADI->(DbGoTop())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Percorrer tabela de tipos de regras³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !ADI->(Eof())
			cVlrCpo := ""
			cAlias  := ADI->ADI_ALIAS      
			cCpo    := ADI->ADI_CAMPO
			_cVar   := cAlias+"->"+cCpo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Alimentar o array aTipRegr com todas as regras para montar³
			//³o filtro da query                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cAlias) .AND. !Empty(cCpo)
				DbSelectArea(cAlias)
				DbSetOrder(1)
				If (cAlias)->(DbSeek(xFilial(cAlias)+cCodigo))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ajustar o dado para o formato primitivo para gerar a query³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ValType(&(_cVar)) == "D"
						cVlrCpo := Fa571Pcd(ADI->ADI_COD,DToC(&(_cVar))) 
					ElseIf ValType(&(_cVar)) == "N"
						cVlrCpo := Fa571Pcd(ADI->ADI_COD,AllTrim(Transform(&(_cVar),PesqPict(cAlias,cCpo)))) 
					ElseIf ValType(&(_cVar)) == "C" 
						cVlrCpo := Fa571Pcd(ADI->ADI_COD,&(_cVar)) 
					EndIf
				
				EndIf	
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para tratar a informação a ser comparada ³
			//³para verificar a regra de rodizio                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFA570RGR
				cVlrCpo := ExecBlock("FA570RGR",.F.,.F.,{cVlrCpo})
			Endif
			
			If !Empty(cVlrCpo)
				aAdd(aTipRegr,{ADI->ADI_COD,;     
				               AllTrim(cVlrCpo),; 
				               ADI->ADI_PESO;     
				               })  
				// [01] Codigo do tipo de regra
				// [02] Informacao a ser comparada na regra 
				// [03] Peso da regra
               
		    Endif
		   	
  		    ADI->(DbSkip()) 
  		    
		EndDo  //Todos os tipos de regras
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Selecionar todos os vendedores da fila que entram nas regras³
		//³de rodizio                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aTipRegr) > 0
			cQuery := "SELECT "
			cQuery += "ADG.ADG_FILIAL, " 
			cQuery += "ADG.ADG_CODVEN, "
			cQuery += "ADG.ADG_POSICA, "		
			cQuery += "ADH.ADH_TIPREG, " 
			cQuery += "ADH.ADH_FAIXDE, " 
			cQuery += "ADH.ADH_FAIXAT, " 
			cQuery += "ADI.ADI_PESO "
			cQuery += "FROM "+RetSqlName("ADH")+" ADH "
			cQuery += "JOIN "+RetSqlName("ADG")+" ADG ON ADH.ADH_FILIAL = ADG.ADG_FILIAL AND ADH.ADH_COD = ADG.ADG_COD AND ADG.D_E_L_E_T_ = '' "  
			cQuery += "JOIN "+RetSqlName("ADI")+" ADI ON ADH.ADH_FILIAL = ADI.ADI_FILIAL AND ADH.ADH_TIPREG = ADI.ADI_COD AND ADI.D_E_L_E_T_ = '' " 
			cQuery += "WHERE ADH.ADH_FILIAL = '"+xFilial("ADH")+"' "
			cQuery += " AND ADH.D_E_L_E_T_ = '' " 
		
			If Len(aTipRegr) > 0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciona todas as regras existentes na query para montar a ³
				//³fila de vendedores.                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 to Len(aTipRegr)
					If nI == 1
					   	cQuery += "AND ((ADH.ADH_TIPREG = '"+aTipRegr[nI][1]+"' "
				    Else	
				    	cQuery += "OR (ADH.ADH_TIPREG = '"+aTipRegr[nI][1]+"' "
				    EndIf
				    cQuery += "AND '"+aTipRegr[nI][2]+"' >= ADH.ADH_FAIXDE "
				    cQuery += "AND '"+aTipRegr[nI][2]+"' <= ADH.ADH_FAIXAT)"
			
				Next nI
				cQuery += ") "
			Endif		    
			cQuery += "ORDER BY ADI_PESO, ADG_POSICA "
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpar a query se estiver em memoria ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Select(cQryVend) > 0 
				DbSelectArea(cQryVend)
				DbCloseArea()
			EndIf
			
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQryVend, .T., .F. )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Percorrer a query e pegar o vendedor de nota mais alta e ³
			//³procurar na fila padrao                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !(cQryVend)->(Eof())
				cVend  := (cQryVend)->ADG_CODVEN
			    
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Validar vendedor³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Fa570Vld(cVend) 
		        	lAchou := .T.
		        	Ft570GrL("1", cVend, cCodigo)		//1 - Executou rodizio
		        	Exit
				Else
					Ft570GrL("2", cVend, cCodigo)  		//2- Pulou o vendedor
				EndIf	
				(cQryVend)->(DbSkip())
			EndDo
		Else //Nao existe regra
	        Aviso(STR0001, STR0002,{"Ok"}) //Atenção. Nao foi poss´vel qualificar o vendedor. Nenhuma regra cadastrada
		EndIf //Existe regra

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Re-arranjar fila colocando o vendedor qualificado na ultima posicao da fila³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchou
			Fa570Arr(cVend)
	   	Else
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorna vendedor padrao e avisa ao usuario ou pergunta ao usuario ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SuperGetMV("MV_FATROD",,.F.) //Utiliza vendedor padrao caso nenhum seja qualificado?
				cVend := SuperGetMV("MV_VENDPAD")
		        Aviso(STR0001, STR0003,{"Ok"})//Atencao. Nao foi encontrado vendedor qualificado dentro das regras de rodízio
		        Aviso(STR0001, (STR0004 + cVend ),{"Ok"}) //Atencao. Conta encaminhada para o vendedor 
		        Ft570GrL("3", cVend, cCodigo)  		//3- Vendedor padrao do rodizio
		    Else
				cVend := ""
				While Empty(cVend)
					Aviso(STR0001, STR0005,{"Ok"}) //Atencao. Vendedor deve ser informado 
					cVend := Fa570Vnd()
					Ft570GrL("4", cVend, cCodigo)  		//4- Vendedor informado manualmente
				End
			EndIf       
		EndIf

		aAreaSA3	:= SA3->(GetArea())
		aAreaACH	:= ACH->(GetArea())
		aAreaSUS	:= SUS->(GetArea())

		FT570Pos( cCodigo, cVend )		//Posiciona nas entidades utilizadas pelo rodizio  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo ao termino da execucao do rodizio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ExecCRMPro("000023")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajusta o controle de contas do vendedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !Empty(ACH->ACH_VEND) 
			Ft520Del(ACH->ACH_VEND	, "ACH"	, ACH->ACH_CODIGO, ACH->ACH_LOJA	)
		EndIf
		Ft520Inc(cVend	, "ACH"	, ACH->ACH_CODIGO, ACH->ACH_LOJA	)

		RestArea(aAreaSA3)
		RestArea(aAreaACH)
		RestArea(aAreaSUS) 
		
	EndIf //Vendedor informado	
EndIf // cCodigo informado 
RestArea(aArea)
Return cVend
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa570Arr  | Autor ³ Deosdete P. da Silva          ³ Data ³25.01.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Re-arranjar fila de vendedores                                      ³±±     
±±³          ³                                                                     ³±±
±±³          ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Totvs -                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVend - Vendedor qualificado. O vendedor qualificado ira atender    ³±±
±±³Parametros³ ao Prospect ou Suspect e voltara para o final da fila               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fa570Arr(cVend)
Local aArea         := GetArea()                   // Salva a área atual antes de iniciar esse processo.
//Local nCnt          := 0                           // Contador da sequencia dos registros
//Local nTamPos       := TamSx3("ADG_POSICA")[1]     // Tamnho do campo posicao   
Local cUltPos       := 0                           // Ultima posicao da fila

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar ultima posicao na fila³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cUltPos := Fa571Pos()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionar na regra/vendedor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ADG")
DbSetOrder(3)
If ADG->(DbSeek(xFilial("ADG")+cVend))   
    RecLock("ADG", .F.)
    	//ADG->ADG_POSICA := Replicate("Z",nTamPos) 
    	ADG->ADG_POSICA := cUltPos
    ADG->(MsUnlock())	
    
  /*  Begin Transaction
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reordenar para ficar na ordem de peso³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    ADG->(DbSetOrder(2))
    ADG->(DbGoTop())
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reajustar a fila para tirar o buraco e redefinir a posição do vendedor ³
	//³escolhido                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //ADG->(DbEval( { || RecLock("ADG",.F.,.T.), ADG->ADG_POSICA := StrZero(++nCnt,nTamPos), ADG->(MsUnlock())},, { ||!ADG->(Eof()) } ))
    
    End Transaction 
  */  
EndIf

RestArea(aArea)
Return
                         
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa570Vld  | Autor ³ Deosdete P. da Silva          ³ Data ³25.01.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validar vendedor. Verificacao do limite de contas do vendedor.      ³±±     
±±³          ³ Se o limite tiver estourado, sera avaliado o proximo da fila para o ³±±
±±³          ³ atendimento                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Totvs -                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVend - Vendedor qualificado                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. - Validado  .F. - Invalidado                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fa570Vld(cVend)
Local aArea         := GetArea()    // Salva a área atual antes de iniciar esse processo.
Local lRet          := .F.          // Variavel auxiliar do retorno da validacao
Local aContas       := {}           // Contem os valores das contas dos vendedores
Local nLimCtas      := 0            // Limite de contas do vendedor
Local nQtdCtas      := 0            // Total geral das contas do vendedor
Local nI            := 0            // Variavel auxiliar para laco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionar no vendedor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA3")
DbSetOrder(1)

If SA3->(DbSeek(xFilial("SA3")+cVend))   //Aterar o indice     
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pegar limite de contas. Não tendo limites de conta o vendedor³
	//³esta validado quanto a este requisito.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SA3->A3_QTCONTA)
		nLimCtas := SA3->A3_QTCONTA
	Else
	    nLimCtas := SuperGetMV("MV_FATCON",,0)
	EndIf    
	
	If nLimCtas > 0 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posicionar na regra/vendedor  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("ADG")
		DbSetOrder(3)
		If ADG->(DbSeek(xFilial("ADG")+cVend))   

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pegar quantidade de contas do vendedor e                  ³
			//³dos seus subordinados conforme definido na regra          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ADG->ADG_CTASUB == "1" .OR. ADG->ADG_CTASUB == "3"
				aAdd(aContas, Ft520Total(cVend))
		    EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somar contas dos subordinados gerencia³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//aContas
			//[1] - Total de suspects
			//[2] - Total de prospects
			//[3] - Total de clientes
			If ADG->ADG_CTASUB > "1"   
				DbSelectArea("SA3")
				DbSetOrder(4) //A3_FILIAL+A3_GEREN
				SA3->(DbSeek(xFilial("SA3")+cVend)) 
				While !SA3->(Eof()) .AND. SA3->A3_FILIAL + SA3->A3_GEREN == xFilial("SA3")+cVend	
					
					aAdd(aContas, Ft520Total(SA3->A3_COD))
					
					SA3->(DbSkip())
				End

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somar contas dos subordinados supervisao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SA3")
				DbSetOrder(5) //A3_FILIAL+A3_SUPER
				SA3->(DbSeek(xFilial("SA3")+cVend))
				While !SA3->(Eof()) .AND. SA3->A3_FILIAL + SA3->A3_SUPER == xFilial("SA3")+cVend	
					
					aAdd(aContas, Ft520Total(SA3->A3_COD))
					
					SA3->(DbSkip())
				EndDo
				
			EndIf 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quantidade de contas do vendedor³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    For nI := 1 To Len(aContas)
		        aEval(aContas[nI],{|x| nQtdCtas += x})
		    Next nI
		
		    If nQtdCtas < nLimCtas
		        lRet := .T.
		    Else //Sem limite para novas contas
		        lRet := .F.
		    EndIf
	   	Else //Regra nao encontrado
	   	    lRet := .F.
	   	EndIf	
    EndIf
Else //Vendedor nao encontrado
    lRet := .F.
EndIf

RestArea(aArea)
Return lRet
           
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa571Vld  | Autor ³ Deosdete P. da Silva          ³ Data ³21.01.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Permitir que o usuario informe o vendedor quando nenhum for         ³±±
±±³          ³ qualificado pelo processo rodizio                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Rodizio - SIGACRM                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Vendedor informado pelo usuario                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fa570Vnd()

Local cPerg := "FAT570"		// Nome do pergunte para chave no SX1
Local lRetP	:= .F.			// Valida o retorno do pergunte, nao permite o ESC

While !lRetP
	lRetP := Pergunte(cPerg,.T.)
End	

Return mv_par01

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FT570Pos  ºAutor  ³Vendas Clientes     º Data ³  09/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona as entidades usadas no rodizio                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FATA570                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FT570Pos( cCodigo, cCodVen )

DbSelectArea("ACH")
DbSetOrder(1)
DbSeek( xFilial("ACH") + cCodigo )

DbSelectArea("SUS")
DbSetOrder(1)
DbSeek( xFilial("SUS") + cCodigo )

DbSelectArea("SA3")
DbSetOrder(1)
DbSeek( xFilial("SA3") + cCodVen )
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft570GrL  ºAutor  ³Vendas e CRM        º Data ³  12/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava tabela de Log do Rodizio                             º±±
±±º          ³ cRod = 1 vendedor recebeu a conta; 2- Pulou vendedor       º±±
±±º          ³ 3- vendedor padrao do parametro; 4- Vend. informado manual º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rodizio de vendedores                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft570GrL(cRod, cVend, cCodigo)
Local lFt570Grv	:= ExistBlock("FT570Grv")			//Valida a existencia do ponto de entrada
Local aArea		:= GetArea()						// Salva a área atual antes de iniciar esse processo.

Default cVend := ""		// Vendedor do rodizio

SX2->( dbSetOrder(1) )
If !SX2->( DbSeek( "AG7" ) )
	Return Nil
Endif

DbSelectArea("AG7")
Reclock("AG7",.T.)
AG7->AG7_DATA	:= dDataBase
AG7->AG7_HORA	:= Time()
AG7->AG7_VEND	:= cVend
AG7->AG7_EXEC	:= cRod
AG7->AG7_COD	:= cCodigo
MsUnLock()

If lFt570Grv
	ExecBlock("FT570Grv",.F.,.F.)
EndIf
RestArea(aArea)
Return Nil