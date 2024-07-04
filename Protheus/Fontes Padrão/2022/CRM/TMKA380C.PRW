#INCLUDE "TMKA380C.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMKDEF.CH"

#DEFINE	NMAXITENS 8000

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMKA380C  ºAutor  ³Microsiga           º Data ³  01/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Agenda do operador. Marketing Ativo.                        º±±
±±º          ³Funcoes sem tela utilizadas pela agenda do operador.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk380CarregaSU4ºAutor ³Microsiga       º Data ³  12/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com as atividades do Operador. Todas as listasº±±
±±º          ³do Operador logado de acordo com a data do parametro        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpD1: Data para selecao das informacoes.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1: Array com as Listas                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K ³06/06/02³710   ³-Notacao e Logica                           º±±
±±ºAndrea F. ³27/12/04³811   ³- Carregar listas de cobranca pendentes na  º±±
±±ºMarcelo K.³27/09/05³811   ³- Nao carrega as listas encerradas          º±±
±±ºAndrea F. ³25/04/05³811   ³- BOPS 97565 - Nao permitir que a funcao    º±±
±±º          ³        ³      ³que verifica se o titulo foi pago seja      º±±
±±º          ³        ³      ³executada por outra rotina que nao seja     º±±
±±º          ³        ³      ³a Agenda do Operador.                       º±±
±±ºAndrea F. ³25/04/06³811   ³- BOPS 97587 - Gravar a funcao que encerrou º±±
±±º          ³        ³      ³a pendencia de telecobranca.                º±±
±±ºMichel W. ³19/09/06³105565³Otimizada rotina de selecao de listas na    º±±
±±º          ³        ³      ³abertura da Agenda do Operador.             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk380CarregaSU4(dData)

Local aAtividades 	:= {}								// Array com as Listas do Operador
Local cOperador		:= TkOperador()						// Codigo do Operador
Local nDiasM		:= TkPosto(cOperador,"U0_VLDTMK") 	// Validade da apresentação de Listas de TMK na Agenda.
Local nDiasV		:= TkPosto(cOperador,"U0_VLDTLV") 	// Validade da apresentação de Listas de TLV na Agenda.
Local nDiasC        := SuperGetMv("MV_TMKDTLC")			// Parametro que indica a validade das listas de TeleCobranca
Local cValidade   	:= TkPosto(cOperador,"U0_LSTVLD") 	// Validade das listas de TMK e TLV - "1" Lista de Contatos "2" Lista de Pendencia "3" Ambos
Local lSemItens		:= .T.								// Flag para indicar que nao existe Listas para o Operador
Local aSemItens		:= {}								// Array com os itens
Local aAreaAux		:= GetArea()						// Salva a area antes de mudar de tabela 
Local nI			:= 0								// Contador
Local cTmpSU4		:= "SU4"           					// Alias auxiliar para TOP e CODEBASE
Local nCont			:= 0								// Contador
Local lMV_TMKPHJ	:= GetNewPar("MV_TMKPHJ",.T.)		// Indica se as pendencias encerradas na database serao exibidas no painel de pendencias agendadas - Default EXIBE
														// Esse parametro e usado para todas as listas inclusive de TELECOBRANCA
Local nTotal		:= 0


#IFDEF TOP
	Local cQuery	:= ""								// QUERY PARA TOP	
#ENDIF 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PE para determinar data limite de execucao de listas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TK380DAT") 
	dData := Execblock("TK380DAT",.F.,.F.,{dData})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as atividades do dia para o operador.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU4")
DbSetOrder(3) //U4_FILIAL+DTOS(U4_DATA)+U4_STATUS

#IFDEF TOP
	// Muda o alias para o temporario
	cTmpSU4	:= "TMPU4"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra todas as atividades para o operador na database.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery	:=	" SELECT 	U4_FILIAL, 		U4_LISTA, 		U4_DESC, 		U4_DATA, " +;
							" U4_TIPO, 		U4_FORMA, 		U4_TELE, 		U4_OPERAD, " +;
							" U4_CONFIG, 	U4_TIPOTEL, 	U4_MALADIR, 	U4_TIPOEND, " +;
							" U4_LABEL, 	U4_ETIQUET, 	U4_CODCAMP, 	U4_SCRIPT, " +;
							" U4_EVENTO, 	U4_ASSUNTO,		U4_CODMENS, 	U4_ATTACH, " +;
							" U4_FILTRO, 	U4_STATUS, 		U4_CRONUM, 		U4_CLIENTE, " +;
							" U4_LOJA, 		U4_NREDUZ, 		U4_HORA1, 		U4_HORA2," +;
							" U4_OCODISC, 	U4_NIVEL, 		U4_CODLIG, 		U4_PROSPEC, " +;
							" U4_FAXARQ, 	U4_CONTATO,		COUNT(U6_LISTA) TOTAL_ITENS" +;
				" FROM " + RetSqlName("SU4") + " LEFT JOIN " + RetSqlName("SU6") +;
				" ON(U6_LISTA = U4_LISTA AND U6_FILIAL = '" + xFilial("SU6") + "' AND (U6_STATUS = '" + AllTrim(Str(NAOENVIADO)) + "' Or U6_STATUS = '" + AllTrim(Str(EMUSO)) + "')) " +;
				" WHERE	U4_FILIAL = '" + xFilial("SU4") + "' AND " +; 
				" 		(U4_OPERAD = '" + cOperador + "' OR U4_OPERAD ='') AND " +;
				" 		U4_DATA <= '" + DtoS(dData) + "' AND " +;
				" 		((U4_TELE = '4' AND U4_DATA ='" + DtoS(dData) + "') OR (U4_TELE <> '4')) AND U4_ENTIDA = '' AND " 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existirem listas  encerradas e o parametro que indica a exibicao das listas encerradas estiver ativo	³
	//³(.T.) elas serao exibidas. Caso contrario, exibe somente as LISTAS EM ABERTO a serem executadas ate hoje	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lMV_TMKPHJ
		cQuery += " 	U4_STATUS <> '2'" + " AND " 
	Endif

	cQuery +=	" 		" + RetSqlName("SU6") + ".D_E_L_E_T_ = '' AND " +;
				" " + RetSqlName("SU4") + ".D_E_L_E_T_ = ''" +;        
				" GROUP BY U4_FILIAL, U4_DATA, U4_STATUS, U4_LISTA, U4_DESC, U4_TIPO, U4_FORMA, U4_TELE, U4_OPERAD, U4_CONFIG, U4_TIPOTEL, U4_MALADIR, U4_TIPOEND, U4_LABEL, U4_ETIQUET, U4_CODCAMP, U4_SCRIPT, U4_EVENTO, U4_ASSUNTO, U4_CODMENS, U4_ATTACH, U4_FILTRO, U4_CRONUM, U4_CLIENTE, U4_LOJA, U4_NREDUZ, U4_HORA1, U4_HORA2, U4_OCODISC, U4_NIVEL, U4_CODLIG, U4_PROSPEC, U4_FAXARQ, U4_CONTATO" +;
				" ORDER BY U4_FILIAL, U4_DATA, U4_STATUS, U4_LISTA, U4_DESC, U4_TIPO, U4_FORMA, U4_TELE, U4_OPERAD, U4_CONFIG, U4_TIPOTEL, U4_MALADIR, U4_TIPOEND, U4_LABEL, U4_ETIQUET, U4_CODCAMP, U4_SCRIPT, U4_EVENTO, U4_ASSUNTO, U4_CODMENS, U4_ATTACH, U4_FILTRO, U4_CRONUM, U4_CLIENTE, U4_LOJA, U4_NREDUZ, U4_HORA1, U4_HORA2, U4_OCODISC, U4_NIVEL, U4_CODLIG, U4_PROSPEC, U4_FAXARQ, U4_CONTATO" 
				
	cQuery := ChangeQuery(cQuery)
	MemoWrite("TMKA380C.SQL", cQuery)                	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTmpSU4,.F.,.T.)
	
	TCSetField(cTmpSU4, "U4_DATA"   , "D")

#ELSE
	DbSeek(xFilial(cTmpSU4)) // retirar a data da validacao para as listas de telecobranca
#ENDIF	

ProcRegua(10)

While (!Eof()) .AND. (cTmpSU4)->U4_FILIAL == xFilial("SU4")

	nCont++
	IncProc( STR0001 + StrZero(nCont,5)+ STR0002+ DTOC((cTmpSU4)->U4_DATA)) //"Tarefas "" do dia "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existirem listas encerradas e o parametro que indica a exibicao das listas encerradas      ³
	//³estiver .T. elas serao exibidas. Caso contrario (.F.) exibe somente as pendencias em aberto   ³
	//³a serem executadas ate hoje. ESSA VALIDACAO ESTA SENDO FEITO PORQUE O WHILE E PARA CODEBASE   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFNDEF TOP
		If !lMV_TMKPHJ
	       If TRIM(U4_STATUS) == "2"  // ENCERRADO
			  SU4->(DbSkip())
			  Loop     
	       Endif
		Endif
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao for lista aberta, valida se e para o mesmo operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFNDEF TOP
		If !Empty( (cTmpSU4)->U4_OPERAD )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao for o mesmo operador nao carrega a Lista  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cTmpSU4)->U4_OPERAD <> cOperador
				DbSkip()
				Loop
			Endif	
	   	Endif      
   	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agenda com data futura nao pode ser mostrada hoje³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTmpSU4)->U4_DATA > dData
		DbSkip()
		Loop
   	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a lista for igual a TODOS e se estiver fora da data de hoje ³
	//³Pula porque nao ha validade para Listas Genericas.			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFNDEF TOP
		If  ((cTmpSU4)->U4_TELE == "4" .AND. (cTmpSU4)->U4_DATA != dData )
			DbSkip()
			Loop
		Endif      
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a Lista for de TELEVENDAS    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If (cTmpSU4)->U4_TELE == "2"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a VALIDADE das listas de Contato informada no Grupo de Atendimento para LISTAS NOVAS e PENDENTES ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If cValidade <> "3" //Todos

    		If cValidade == "1" //Lista de Contatos

    			If  VAL( (cTmpSU4)->U4_FORMA ) <> PENDENCIA
    			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasV)
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	

		   	ElseIf cValidade == "2" // Lista de Pendencia

    			If VAL( (cTmpSU4)->U4_FORMA ) == PENDENCIA
    			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    			If dData > ( (cTmpSU4)->U4_DATA + nDiasV )
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	
	    		
			Endif
       	
       	Else
        
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	If dData > ( (cTmpSU4)->U4_DATA + nDiasV )
   				DbSkip()
    			Loop
	    	Endif
	   	Endif                                            
		
 	Endif
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a Lista for de TELEMARKETING ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTmpSU4)->U4_TELE == "1"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o acesso definido no Posto de Venda do operador as listas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If cValidade <> "3" //Todos

    		If cValidade == "1" //Lista de Contatos

    			If  VAL((cTmpSU4)->U4_FORMA) <> PENDENCIA
    			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasM)
		   				DbSkip()
    					Loop
	    			Endif

	    		Endif	

		   	ElseIf cValidade == "2" // Lista de Pendencia

    			If  VAL( (cTmpSU4)->U4_FORMA ) == PENDENCIA
    			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasM)
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	

			Endif
       	Else
        
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	If dData > ((cTmpSU4)->U4_DATA + nDiasM)
   				DbSkip()
    			Loop
	    	Endif
	   	Endif                                            
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a Lista for de TELECOBRANCA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTmpSU4)->U4_TELE == "3"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o acesso definido no Posto de Venda do operador as listas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If cValidade <> "3" //Todos

    		If cValidade == "1" //Lista de Contatos
    			
    			If  VAL((cTmpSU4)->U4_FORMA) <> PENDENCIA
    			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasC)
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	
		   	Endif
		
       	Else
        
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	If dData > ((cTmpSU4)->U4_DATA + nDiasC)
   				DbSkip()
    			Loop
	    	Endif
	   	Endif                                            
	Endif
    
	#IFNDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se os itens nao estao todos encerrados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaAux := GetArea()
		DbSelectarea("SU6")
		DbSetOrder(1)
		lSemItens := .T.
		If DbSeek(xFilial("SU6") + (cTmpSU4)->U4_LISTA)
			While	(!Eof())							.AND.;
					SU6->U6_FILIAL == xFilial("SU6") 	.AND.;
					SU6->U6_LISTA == (cTmpSU4)->U4_LISTA
				
				If VAL(SU6->U6_STATUS) == NAOENVIADO .or. VAL(SU6->U6_STATUS) == EMUSO
					lSemItens := .F.
					Exit
				Endif
				SU6->(DbSkip())
		    End
		Endif
		RestArea(aAreaAux)
	#ELSE
		lSemItens := .T.
	    If (cTmpSU4)->TOTAL_ITENS > 0
	    	lSemItens := .F.
	    Endif
	#ENDIF
	
	DbSelectArea((cTmpSU4))
	If lSemItens
		AAdd(aSemItens, (cTmpSU4)->U4_LISTA)
		DbSkip()
		Loop
	Endif
	
	// Cobranca e que tenha sido executada APENAS pela Agenda do Operador		
    If (cTmpSU4)->U4_TIPO == "2" .AND. UPPER(FunName()) == "TMKA380" 
		If Tk380Baixa((cTmpSU4)->U4_LISTA)
			DbSkip()
			Loop
		Endif
	Endif
	
	//Verificação para atualizar a legenda para atendimentos Televendas
	If (cTmpSU4)->U4_TELE == "2" .And. (cTmpSU4)->U4_STATUS == "1"
		//Verifica se houve atualização da lista
		nTotal := Tk380AtuPercent((cTmpSU4)->U4_LISTA)
		
		If nTotal > 0
				AAdd(aAtividades,{	(cTmpSU4)->U4_LISTA	,; 	// 1
						"3",; 	// 2
						(cTmpSU4)->U4_DATA	,; 	// 3
						(cTmpSU4)->U4_HORA1	,; 	// 4
						(cTmpSU4)->U4_DESC	,; 	// 5
						(cTmpSU4)->U4_OPERAD,; 	// 6
						(cTmpSU4)->U4_TELE	,; 	// 7
						(cTmpSU4)->U4_CODLIG,;	// 8
						(cTmpSU4)->U4_FORMA})	// 9	
		Else
			AAdd(aAtividades,{	(cTmpSU4)->U4_LISTA	,; 	// 1
						(cTmpSU4)->U4_STATUS,; 	// 2
						(cTmpSU4)->U4_DATA	,; 	// 3
						(cTmpSU4)->U4_HORA1	,; 	// 4
						(cTmpSU4)->U4_DESC	,; 	// 5
						(cTmpSU4)->U4_OPERAD,; 	// 6
						(cTmpSU4)->U4_TELE	,; 	// 7
						(cTmpSU4)->U4_CODLIG,;	// 8
						(cTmpSU4)->U4_FORMA})	// 9		
		EndIf
	Else
		AAdd(aAtividades,{	(cTmpSU4)->U4_LISTA	,; 	// 1
						(cTmpSU4)->U4_STATUS,; 	// 2
						(cTmpSU4)->U4_DATA	,; 	// 3
						(cTmpSU4)->U4_HORA1	,; 	// 4
						(cTmpSU4)->U4_DESC	,; 	// 5
						(cTmpSU4)->U4_OPERAD,; 	// 6
						(cTmpSU4)->U4_TELE	,; 	// 7
						(cTmpSU4)->U4_CODLIG,;	// 8
						(cTmpSU4)->U4_FORMA})	// 9
	EndIf	
																														
	DbSelectArea((cTmpSU4))
	DbSkip()
End

#IFDEF TOP
	DbSelectArea(cTmpSU4)
	DbCloseArea()
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o array contenha listas com todos os itens ecerrados entao encerra o cabecalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aSemItens) > 0
	DbSelectArea("SU4")
	DbSetOrder(1)
	For nI := 1 To Len(aSemItens)
		If DbSeek(xFilial("SU4") + aSemItens[nI])
			RecLock("SU4", .F.)
			SU4->U4_STATUS := "2"
			SU4->U4_ROTINA := "TK380CARREGASU4"
			MsUnLock("SU4")
		Endif
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se não existirem atividades para este dia apresenta dados em branco.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aAtividades) == 0
	AAdd(aAtividades,{	SPACE(6)								,; 	// 1
						" "										,; 	// 2
						SPACE(8)								,; 	// 3
						SPACE(5)								,; 	// 4
						STR0003									,; 	// 5 //"Nao ha atividades para esta data"
						SPACE(8)								,; 	// 6
						SPACE(1)								,; 	// 7
						SPACE(6)								,; 	// 8
						SPACE(1)}) 									// 9
Endif

RestArea(aAreaAux)
Return(aAtividades)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkSX3Box  ºAutor  ³Microsiga           º Data ³  19/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Funcao que monta um array com todas as opcoes do combo   º±±
±±º          ³box a partir da leitura do dicionario de dados SX3.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCampo - Nome do campo que sera pesquisado no SX3.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk380Box(cCampo)
Local aArea		:= GetArea()
Local aBox		:= {}
Local aItens	:= {}
Local nI		:= 0

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek(cCampo)
	AAdd( aBox, &('{"' + StrTran( AllTrim( X3CBox() ), ';', '","' ) + '"}' ) )
Endif

For nI := 1 To Len(aBox[1])
	AAdd(aItens, Substr(aBox[1][nI],At("=",aBox[1][nI])+1,(Len(aBox[1][nI]))) )
Next nI
AAdd(aItens, "" )

RestArea(aArea)

Return(aItens)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK380CFG    ºAutor ³Microsiga            º Data ³ 18/12/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega os itens da Lista de contatos     				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ExpC1: Codigo da Lista de Contatos                          ³±±
±±³          ³ExpA1: Array Header da GetDados.                            ³±±
±±³          ³ExpA1: Array aCols da GetDados.                             ³±±
±±³          ³ExpC2: Alias da Lista de Contatos.                          ³±±
±±³          ³ExpL1: Identifica se foi a primeira chamada da funcao.      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ap8 Agenda do operador.                               	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³23/01/07³912   ³-Implementacao de Walk-thru para GetDados.  º±±
±±º          ³        ³115804³                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk380CFG(	cLista,		aHeader,	aCols,		cAlias,;	
					lFirst)
Local aArea		:= GetArea() 	// Salva area padrao para restauracao posterior.
Local nCntFor 	:= 0			// Contador do for.
Local cArqQry   := ""			// Define o Alias da query.
Local lQuery    := .F.			// Parametro logico que define se existe ou nao query.
Local nUsado	:= 0			// Contador de campos usados.
Local nRecAtu   := 0			// Recno atual
Local nRecTot   := 0			// Total de registros a processar
Local oBmpGreen :=	LoadBitmap( GetResources(), "br_verde" )		//BMP de status (verde)
Local oBmpRed   :=	LoadBitmap( GetResources(), "br_vermelho" )		//BMP de status (verde)

#IFDEF TOP
	Local aStruSU6  := {}		// Estrutura do dicionario de dados Tabela SU6.
	Local cQuery    := ""		// String contendo a query.
	Local cQryTot   := ""		// Query para contador.
#ENDIF	

INCLUI := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A manutencao do aHeader so deve ser efetuada na primeira ³
//³execucao. A nova GetDados altera a informacao deste array³
//³com controles internos.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFirst
	aHeader := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui um campo extra no aHeader para a apresentacao da ³
	//³legenda do contato.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado++
	AAdd(aHeader,{	" ",;									//01 - X3TITULO()
					"U4_LG",;								//02 - X3_CAMPO
					"@BMP",;								//03 - X3_PICTURE
					2,;										//04 - X3_TAMANHO
					0,;										//05 - X3_DECIMAL
					"",;									//06 - X3_VALID
					"€‚€€€€€€€€€€€€",;						//07 - X3_USADO
					"C",;									//08 - X3_TIPO
					"",;									//09 - X3_F3
					"" 	} )									//10 - X3_CONTEXT
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do aHeader                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SU6")
	While ( !Eof() .AND. (SX3->X3_ARQUIVO == "SU6") )
		
		If ( X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL )
			
			nUsado++
			AAdd(aHeader,{ 	AllTrim(X3Titulo())	,;	//01
							SX3->X3_CAMPO		,;	//02
							SX3->X3_PICTURE		,;	//03
							SX3->X3_TAMANHO		,;	//04
							SX3->X3_DECIMAL		,;	//05
							SX3->X3_VALID		,;	//06	
							SX3->X3_USADO		,;	//07
							SX3->X3_TIPO		,;	//08
							SX3->X3_F3			,;	//09
							SX3->X3_CONTEXT } )		//10
						Endif
		
		DbSelectArea("SX3")
		DbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui colunas do Walk-thru atraves de funcao generica ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ADHeadRec("SU6", aHeader)    
	nUsado := Len(aHeader)	
	
Else
	nUsado := Len(aHeader)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols 	:= {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir a lista carrega todos os itens, caso contrario ³
//³carrega o acols vazio.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU6")
DbSetOrder(1)
nRecTot := RecCount()
  

If DbSeek(xFilial("SU6") + cLista)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o acols.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {}
	
	#IFDEF TOP
		If Ascan(aHeader,{|x| x[8] == "M"}) == 0
			aStruSU6:= SU6->(dbStruct())
			cArqQry := "SU6"
			lQuery  := .T.
			
			cQuery 	:= "SELECT * "
			cQuery 	+= "FROM "+RetSqlName("SU6")+" SU6  "
			cQuery 	+= "WHERE SU6.U6_FILIAL='"+xFilial("SU6")+"' AND "
			cQuery 	+= "	SU6.U6_LISTA='"+cLista+"' AND "
			cQuery 	+= "	(SU6.U6_STATUS = '1' OR SU6.U6_STATUS = '2' ) AND" 
			cQuery 	+= "	SU6.D_E_L_E_T_ = ' ' "
			
			// O filtro esta montado e o ORDER BY nao esta na query entao é hora de montar o contator da regua
			// Monto o SELECT que conta e aproveito o filtro da outra query
			cQryTot := "SELECT COUNT(*) U6TOTAL " + SubStr(cQuery,AT("FROM ",cQuery),Len(cQuery))
				
			cQuery += "ORDER BY "+SqlOrder(SU6->(IndexKey()))
	
			cQryTot := ChangeQuery(cQryTot)
			DbSelectArea("SU6")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTot), cArqQry, .F., .T.)
			nRecTot := SU6->U6TOTAL
			
			cQuery := ChangeQuery(cQuery)
			dbSelectArea("SU6")
			dbCloseArea()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
			For nCntFor := 1 To Len(aStruSU6)
				If ( aStruSU6[nCntFor,2]<>"C" )
					TcSetField(cArqQry,aStruSU6[nCntFor,1],aStruSU6[nCntFor,2],aStruSU6[nCntFor,3],aStruSU6[nCntFor,4])
				Endif
			Next nCntFor
		Else
	#ENDIF
   
		cArqQry := "SU6"
		DbSeek(xFilial("SU6")+cLista)

	#IFDEF TOP
		Endif
	#ENDIF
    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza variavel com o Alias da lista para utilizacao nos ³
	//³botoes da tela.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAlias := (cArqQry)->U6_ENTIDA

	ProcRegua( nRecTot )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para evitar erros de listas de contato.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While 	( !Eof() .And. (cArqQry)->U6_FILIAL == xFilial("SU6") .And. ;
			(cArqQry)->U6_LISTA == cLista ) 

		#IFNDEF TOP 
			If (cArqQry)->U6_STATUS == "3"
				(cArqQry)->(DbSkip())
				Loop
			Endif
		#ENDIF	
		
		nRecAtu++
		IncProc( STR0004 + StrZero(nRecAtu,6) + STR0005 + StrZero(nRecTot,6) ) //"Lendo reg. "###" até "

		If nRecAtu <= NMAXITENS		//Número máximo de itens que serão visualizados na agenda do operador
			AAdd(aCols,Array(nUsado + 1))
		
			For nCntFor	:= 1 To nUsado
				If nCntFor == 1					
					If (cArqQry)->U6_STATUS == "1"
						aCols[Len(aCols)][nCntFor] := oBmpGreen // Livre
					Else
						aCols[Len(aCols)][nCntFor] := oBmpRed	// Em uso
					Endif	
				ElseIf IsHeadAlias(aHeader[nCntFor,2])
					aCols[Len(aCols)][nCntFor] := "SU6"
				ElseIf IsHeadRec(aHeader[nCntFor,2])
					#IFDEF TOP
						aCols[Len(aCols)][nCntFor] := (cArqQry)->R_E_C_N_O_
					#ELSE
						aCols[Len(aCols)][nCntFor] := (cArqQry)->(Recno())
					#ENDIF
				ElseIf aHeader[nCntFor][10] == "V"
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				Else
					aCols[Len(aCols)][nCntFor] := (cArqQry)->&(aHeader[nCntFor][2])
				Endif
			Next nCntFor	
			
			aCols[Len(aCols)][nUsado + 1] := .F.
		EndIf	
		(cArqQry)->(DbSkip())
	End
Endif

ProcRegua( nRecTot )

If ( lQuery )
	DbSelectArea(cArqQry)
	DbCloseArea()
	ChkFile("SU6",.F.)
	DbSelectArea("SU6")
Endif

RestArea(aArea)

Return Nil
