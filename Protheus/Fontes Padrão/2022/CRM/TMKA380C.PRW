#INCLUDE "TMKA380C.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMKDEF.CH"

#DEFINE	NMAXITENS 8000

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TMKA380C  �Autor  �Microsiga           � Data �  01/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Agenda do operador. Marketing Ativo.                        ���
���          �Funcoes sem tela utilizadas pela agenda do operador.        ���
�������������������������������������������������������������������������͹��
���Uso       � Call Center                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Tk380CarregaSU4�Autor �Microsiga       � Data �  12/04/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna array com as atividades do Operador. Todas as listas���
���          �do Operador logado de acordo com a data do parametro        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpD1: Data para selecao das informacoes.                   ���
�������������������������������������������������������������������������͹��
���Retorno   �ExpA1: Array com as Listas                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP8-Call Center                                            ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������͹��
���Marcelo K �06/06/02�710   �-Notacao e Logica                           ���
���Andrea F. �27/12/04�811   �- Carregar listas de cobranca pendentes na  ���
���Marcelo K.�27/09/05�811   �- Nao carrega as listas encerradas          ���
���Andrea F. �25/04/05�811   �- BOPS 97565 - Nao permitir que a funcao    ���
���          �        �      �que verifica se o titulo foi pago seja      ���
���          �        �      �executada por outra rotina que nao seja     ���
���          �        �      �a Agenda do Operador.                       ���
���Andrea F. �25/04/06�811   �- BOPS 97587 - Gravar a funcao que encerrou ���
���          �        �      �a pendencia de telecobranca.                ���
���Michel W. �19/09/06�105565�Otimizada rotina de selecao de listas na    ���
���          �        �      �abertura da Agenda do Operador.             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk380CarregaSU4(dData)

Local aAtividades 	:= {}								// Array com as Listas do Operador
Local cOperador		:= TkOperador()						// Codigo do Operador
Local nDiasM		:= TkPosto(cOperador,"U0_VLDTMK") 	// Validade da apresenta��o de Listas de TMK na Agenda.
Local nDiasV		:= TkPosto(cOperador,"U0_VLDTLV") 	// Validade da apresenta��o de Listas de TLV na Agenda.
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

//������������������������������������������������������
//�PE para determinar data limite de execucao de listas�
//������������������������������������������������������
If ExistBlock("TK380DAT") 
	dData := Execblock("TK380DAT",.F.,.F.,{dData})
EndIf

//������������������������������������������������
//�Verifica as atividades do dia para o operador.�
//������������������������������������������������
DbSelectArea("SU4")
DbSetOrder(3) //U4_FILIAL+DTOS(U4_DATA)+U4_STATUS

#IFDEF TOP
	// Muda o alias para o temporario
	cTmpSU4	:= "TMPU4"
	
	//�������������������������������������������������������Ŀ
	//�Filtra todas as atividades para o operador na database.�
	//���������������������������������������������������������
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

	//���������������������������������������������������������������������������������������������������������Ŀ
	//�Se existirem listas  encerradas e o parametro que indica a exibicao das listas encerradas estiver ativo	�
	//�(.T.) elas serao exibidas. Caso contrario, exibe somente as LISTAS EM ABERTO a serem executadas ate hoje	�
	//�����������������������������������������������������������������������������������������������������������
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

	//����������������������������������������������������������������������������������������������Ŀ
	//�Se existirem listas encerradas e o parametro que indica a exibicao das listas encerradas      �
	//�estiver .T. elas serao exibidas. Caso contrario (.F.) exibe somente as pendencias em aberto   �
	//�a serem executadas ate hoje. ESSA VALIDACAO ESTA SENDO FEITO PORQUE O WHILE E PARA CODEBASE   �
	//������������������������������������������������������������������������������������������������
	#IFNDEF TOP
		If !lMV_TMKPHJ
	       If TRIM(U4_STATUS) == "2"  // ENCERRADO
			  SU4->(DbSkip())
			  Loop     
	       Endif
		Endif
	#ENDIF

	//����������������������������������������������������������Ŀ
	//�Se nao for lista aberta, valida se e para o mesmo operador�
	//������������������������������������������������������������
	#IFNDEF TOP
		If !Empty( (cTmpSU4)->U4_OPERAD )
			//�������������������������������������������������Ŀ
			//�Se nao for o mesmo operador nao carrega a Lista  �
			//���������������������������������������������������
			If (cTmpSU4)->U4_OPERAD <> cOperador
				DbSkip()
				Loop
			Endif	
	   	Endif      
   	#ENDIF

	//�������������������������������������������������Ŀ
	//�Agenda com data futura nao pode ser mostrada hoje�
	//���������������������������������������������������
	If (cTmpSU4)->U4_DATA > dData
		DbSkip()
		Loop
   	Endif
		
	//���������������������������������������������������������������Ŀ
	//�Se a lista for igual a TODOS e se estiver fora da data de hoje �
	//�Pula porque nao ha validade para Listas Genericas.			  �
	//�����������������������������������������������������������������
	#IFNDEF TOP
		If  ((cTmpSU4)->U4_TELE == "4" .AND. (cTmpSU4)->U4_DATA != dData )
			DbSkip()
			Loop
		Endif      
	#ENDIF
	
	//��������������������������������Ŀ
	//�Se a Lista for de TELEVENDAS    �
	//����������������������������������
    If (cTmpSU4)->U4_TELE == "2"
		
		//����������������������������������������������������������������������������������������������������������Ŀ
		//�Verifica a VALIDADE das listas de Contato informada no Grupo de Atendimento para LISTAS NOVAS e PENDENTES �
		//������������������������������������������������������������������������������������������������������������
    	If cValidade <> "3" //Todos

    		If cValidade == "1" //Lista de Contatos

    			If  VAL( (cTmpSU4)->U4_FORMA ) <> PENDENCIA
    			   	//�����������������������������������������������������������������������������������������������Ŀ
					//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
					//�������������������������������������������������������������������������������������������������
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasV)
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	

		   	ElseIf cValidade == "2" // Lista de Pendencia

    			If VAL( (cTmpSU4)->U4_FORMA ) == PENDENCIA
    			   	//�����������������������������������������������������������������������������������������������Ŀ
					//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
					//�������������������������������������������������������������������������������������������������
	    			If dData > ( (cTmpSU4)->U4_DATA + nDiasV )
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	
	    		
			Endif
       	
       	Else
        
	   		//�����������������������������������������������������������������������������������������������Ŀ
			//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
			//�������������������������������������������������������������������������������������������������
	    	If dData > ( (cTmpSU4)->U4_DATA + nDiasV )
   				DbSkip()
    			Loop
	    	Endif
	   	Endif                                            
		
 	Endif
   
	//��������������������������������Ŀ
	//�Se a Lista for de TELEMARKETING �
	//����������������������������������
	If (cTmpSU4)->U4_TELE == "1"
		
		//�������������������������������������������������������������������Ŀ
		//�Verifica o acesso definido no Posto de Venda do operador as listas.�
		//���������������������������������������������������������������������
    	If cValidade <> "3" //Todos

    		If cValidade == "1" //Lista de Contatos

    			If  VAL((cTmpSU4)->U4_FORMA) <> PENDENCIA
    			   	//�����������������������������������������������������������������������������������������������Ŀ
					//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
					//�������������������������������������������������������������������������������������������������
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasM)
		   				DbSkip()
    					Loop
	    			Endif

	    		Endif	

		   	ElseIf cValidade == "2" // Lista de Pendencia

    			If  VAL( (cTmpSU4)->U4_FORMA ) == PENDENCIA
    			   	//�����������������������������������������������������������������������������������������������Ŀ
					//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
					//�������������������������������������������������������������������������������������������������
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasM)
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	

			Endif
       	Else
        
	   		//�����������������������������������������������������������������������������������������������Ŀ
			//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
			//�������������������������������������������������������������������������������������������������
	    	If dData > ((cTmpSU4)->U4_DATA + nDiasM)
   				DbSkip()
    			Loop
	    	Endif
	   	Endif                                            
		
	Endif

	//��������������������������������Ŀ
	//�Se a Lista for de TELECOBRANCA  �
	//����������������������������������
	If (cTmpSU4)->U4_TELE == "3"
		
		//�������������������������������������������������������������������Ŀ
		//�Verifica o acesso definido no Posto de Venda do operador as listas.�
		//���������������������������������������������������������������������
    	If cValidade <> "3" //Todos

    		If cValidade == "1" //Lista de Contatos
    			
    			If  VAL((cTmpSU4)->U4_FORMA) <> PENDENCIA
    			   	//�����������������������������������������������������������������������������������������������Ŀ
					//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
					//�������������������������������������������������������������������������������������������������
	    			If dData > ((cTmpSU4)->U4_DATA + nDiasC)
		   				DbSkip()
    					Loop
	    			Endif
	    		Endif	
		   	Endif
		
       	Else
        
	   		//�����������������������������������������������������������������������������������������������Ŀ
			//�Se a data da lista for superior ao numero de dias em que ela fica disponivel nao entra na lista�
			//�������������������������������������������������������������������������������������������������
	    	If dData > ((cTmpSU4)->U4_DATA + nDiasC)
   				DbSkip()
    			Loop
	    	Endif
	   	Endif                                            
	Endif
    
	#IFNDEF TOP
		//�����������������������������������������������Ŀ
		//�Verifica se os itens nao estao todos encerrados�
		//�������������������������������������������������
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
	
	//Verifica��o para atualizar a legenda para atendimentos Televendas
	If (cTmpSU4)->U4_TELE == "2" .And. (cTmpSU4)->U4_STATUS == "1"
		//Verifica se houve atualiza��o da lista
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

//������������������������������������������������������������������������������������Ŀ
//�Caso o array contenha listas com todos os itens ecerrados entao encerra o cabecalho.�
//��������������������������������������������������������������������������������������
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

//��������������������������������������������������������������������Ŀ
//�Se n�o existirem atividades para este dia apresenta dados em branco.�
//����������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TkSX3Box  �Autor  �Microsiga           � Data �  19/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �   Funcao que monta um array com todas as opcoes do combo   ���
���          �box a partir da leitura do dicionario de dados SX3.         ���
�������������������������������������������������������������������������͹��
���Parametros� cCampo - Nome do campo que sera pesquisado no SX3.         ���
�������������������������������������������������������������������������͹��
���Uso       � Call Center                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TK380CFG    �Autor �Microsiga            � Data � 18/12/03  ���
�������������������������������������������������������������������������͹��
���Descricao � Carrega os itens da Lista de contatos     				  ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1: Codigo da Lista de Contatos                          ���
���          �ExpA1: Array Header da GetDados.                            ���
���          �ExpA1: Array aCols da GetDados.                             ���
���          �ExpC2: Alias da Lista de Contatos.                          ���
���          �ExpL1: Identifica se foi a primeira chamada da funcao.      ���
�������������������������������������������������������������������������͹��
���Uso       � Ap8 Agenda do operador.                               	  ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������͹��
���Cleber M. �23/01/07�912   �-Implementacao de Walk-thru para GetDados.  ���
���          �        �115804�                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//���������������������������������������������������������Ŀ
//�A manutencao do aHeader so deve ser efetuada na primeira �
//�execucao. A nova GetDados altera a informacao deste array�
//�com controles internos.                                  �
//�����������������������������������������������������������
If lFirst
	aHeader := {}

	//��������������������������������������������������������Ŀ
	//�Inclui um campo extra no aHeader para a apresentacao da �
	//�legenda do contato.                                     �
	//����������������������������������������������������������
	nUsado++
	AAdd(aHeader,{	" ",;									//01 - X3TITULO()
					"U4_LG",;								//02 - X3_CAMPO
					"@BMP",;								//03 - X3_PICTURE
					2,;										//04 - X3_TAMANHO
					0,;										//05 - X3_DECIMAL
					"",;									//06 - X3_VALID
					"���������������",;						//07 - X3_USADO
					"C",;									//08 - X3_TIPO
					"",;									//09 - X3_F3
					"" 	} )									//10 - X3_CONTEXT
	
	
	//������������������������������������������������������Ŀ
	//�Montagem do aHeader                                   �
	//��������������������������������������������������������
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
	
	//��������������������������������������������������������Ŀ
	//� Inclui colunas do Walk-thru atraves de funcao generica �
	//����������������������������������������������������������
	ADHeadRec("SU6", aHeader)    
	nUsado := Len(aHeader)	
	
Else
	nUsado := Len(aHeader)
Endif	

//������������������������������������������������������Ŀ
//�Montagem do aCols                                     �
//��������������������������������������������������������
aCols 	:= {}


//����������������������������������������������������������Ŀ
//�Se existir a lista carrega todos os itens, caso contrario �
//�carrega o acols vazio.                                    �
//������������������������������������������������������������
DbSelectArea("SU6")
DbSetOrder(1)
nRecTot := RecCount()
  

If DbSeek(xFilial("SU6") + cLista)

	//�����������������Ŀ
	//�Atualiza o acols.�
	//�������������������
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
			
			// O filtro esta montado e o ORDER BY nao esta na query entao � hora de montar o contator da regua
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
    

	//�����������������������������������������������������������Ŀ
	//�Atualiza variavel com o Alias da lista para utilizacao nos �
	//�botoes da tela.                                            �
	//�������������������������������������������������������������
	cAlias := (cArqQry)->U6_ENTIDA

	ProcRegua( nRecTot )

	//��������������������������������������������������Ŀ
	//�Tratamento para evitar erros de listas de contato.�
	//����������������������������������������������������
	
	While 	( !Eof() .And. (cArqQry)->U6_FILIAL == xFilial("SU6") .And. ;
			(cArqQry)->U6_LISTA == cLista ) 

		#IFNDEF TOP 
			If (cArqQry)->U6_STATUS == "3"
				(cArqQry)->(DbSkip())
				Loop
			Endif
		#ENDIF	
		
		nRecAtu++
		IncProc( STR0004 + StrZero(nRecAtu,6) + STR0005 + StrZero(nRecTot,6) ) //"Lendo reg. "###" at� "

		If nRecAtu <= NMAXITENS		//N�mero m�ximo de itens que ser�o visualizados na agenda do operador
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
