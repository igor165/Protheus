#INCLUDE "TMKA271A.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"  

STATIC __lNewGetD										// Variavel usada para corrigir o foco na enchoice - para a digitacao depois da primeira gravacao
Static _lTMKALTA5	:= ExistBlock("TMKALTA5")			// P.E. Antes da alteracao do contato.
Static _lTMKALTU5	:= ExistBlock("TMKALTU5")			// P.E. Depois da alteracao do contato.
Static _lTMKINCU5	:= ExistBlock("TMKINCU5")			// P.E  Antes da inclusao do contato.
Static _lTMKVPE	:= ExistBlock("TMKVPE")					//P.E. para Televendas
Static _lTMKMPE	:= ExistBlock("TMKMPE")					//P.E. para Telemarketing
Static _lTMKCPE	:= ExistBlock("TMKCPE")					//P.E. para Telecobranca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³TKValidEnvºAutor  ³ Vendas Clientes    º Data ³  21/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se existe cliente selecionado e qual folder esta     º±±
±±º          ³ativo para execucao da funcao - TkHistLoj                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                          	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK271ValidEnv()

Local cProduto  := ""       		// Codigo do produto
Local aPosicoes := {}      			// Array interno
Local nPProd    := 0        		// Posicao do Produto
Local cTip      := TkGetTipoAte() 	// "cTip" fica igual a cTipoAte para utilizacao na funcao seguinte juntamente com o SIGALOJA
Local cCliente	:= ""				// Codigo do Cliente
Local cLoja 	:= ""	    		// Loja do Cliente
Local lRet		:= .F.				// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A consulta e somente para CLIENTES                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lProspect
	Return(lRet)
Endif

If nFolder == 1 // TeleMarketing 
	If TkGetTipoAte() $ "145" 	//Telemarketing,  Ambos e TMK x TLV

		If (M->UC_ENTIDAD == "SA1")			//Cliente
			cCliente   := SubStr(M->UC_CHAVE,1,TamSx3("A1_COD")[1])
			cLoja      := SubStr(M->UC_CHAVE,TamSx3("A1_COD")[1]+1,TamSx3("A1_LOJA")[1])

		ElseIf (M->UC_ENTIDAD == "SUS")		//Prospect
			cCliente   := SubStr(M->UC_CHAVE,1,TamSx3("US_COD")[1])
			cLoja      := SubStr(M->UC_CHAVE,TamSx3("US_COD")[1]+1,TamSx3("US_LOJA")[1])
		Endif
		
		aPosicoes  := Aclone(aPosicoesM)
		nPProd     := aPosicoes[3][2]
	    cProduto   := IIF (aCols[n,Len(aCols[n])],"",aCols[n][nPProd])
	
	Elseif TkGetTipoAte() == "2" //Televendas
		cCliente   := M->UA_CLIENTE
		cLoja      := M->UA_LOJA
		aPosicoes  := Aclone(aPosicoesV)
		nPProd     := aPosicoes[1][2]
	    cProduto   := IIF (aCols[n,Len(aCols[n])],"",aCols[n][nPProd])
	 
		
	ElseIf TkGetTipoAte() == "3" //Telecobranca
		cCliente   := M->ACF_CLIENT
		cLoja      := M->ACF_LOJA
		
	Endif
	
ElseIf nFolder == 2 // Televendas
	cCliente   := M->UA_CLIENTE
	cLoja      := M->UA_LOJA
	aPosicoes  := Aclone(aPosicoesV)
	nPProd     := aPosicoes[1][2]
	cProduto   := IIF (aCols[n,Len(aCols[n])],"",aCols[n][nPProd])
	 
ElseIf nFolder == 3 // Telecobranca
	cCliente   := M->ACF_CLIENT
	cLoja      := M->ACF_LOJA
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um cliente/prospect selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cCliente )
	Help(" ",1,"SEM CLIENT" )
	Return(lRet)
Else 
	TkHistLoj(cCliente,cProduto,cTip)
	lRet := .T.
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ³Tk271Cancela ³ Autor ³ Vendas Clientes       ³ Data ³27/12/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Valida e Exibe o motivo do Cancelamento do TMK/TLV             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Call Center													 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk271Cancela(	nOpc		,oCrono		,cCrono			,nTimeSeg		,;
						nTimeMin	,oFolderTmk	,oEnchTmk		,oFolderTlv		,;
						oEnchTlv	,cCodPagto	,cDescPagto		,cCodTransp		,;
						cTransp		,cCob		,cEnt			,cCidadeC		,;
						cCepC		,cUfC		,cBairroE		,cBairroC		,;
						cCidadeE	,cCepE		,cUfE			,nLiquido		,;
						nTxJuros	,nTxDescon	,nVlJur			,aParcelas		,;
						nEntrada	,nFinanciado,nNumParcelas	,nValorCC		,;
						lHabilita	,cMotivo	,cEncerra		,oFolderTlc		,;
						oEnchTlc	,cCodAnt	,lMsg			,lPriContato	)

Local lTMKVEX 	:= ExistBlock("TMKVEX")   				// P.E. para antes do cancelamento do TLV
Local lTMKMEX 	:= ExistBlock("TMKMEX")   				// P.E. para antes do cancelamento do TMK
Local oDlgVCan											// Tela para cancelamento	
Local oObs												// MEMO para observacao do cancelamento
Local cObs    	:= ""									// variavel com a descricao do MEMO
Local oMonoAs 	:= TFont():New( "Courier New", 6, 0 )	// Fonte do MEMO
Local nOpca	  	:= 0									// Opcao de escolha OK ou CANCELA		
Local lCancela	:= .F.      							// Retorno da funcao
Local lTMKMDC 	:= ExistBlock("TMKMDC")   				// P.E. para DEPOIS do cancelamento TMK 
Local lTMKVDC 	:= ExistBlock("TMKVDC")   				// P.E. para TLV DEPOIS do cancelamento
Local lLimpaSK1	:= .F.                                 	// Indica se pode limpar os titulos que estao para o operador no SK1
Local cFilOrig	:= ""			              			// Filial de origem do titulo
Local lIntQly   := GetMv("MV_QLYXCAL",.F.,.F.)			// Habilita a Integração com o Quality
Local nCntFor	:= 0									// Contador
Local cTmkaloj	:= SuperGetMv("MV_TMKALOJ")				// Se pode efetuar alteração no orçamento gerado pro loja
Local aLista		:= {}								//Array para armazenar o campo U4_LISTA para cancelamento da SU6
Local nI			:= 0								//Contador
			
If nFolder == 1  // Telemarketing
	
	If lTMKMEX
		lCancela := ExecBlock( "TMKMEX", .F., .F. )
		
		// Se o retorno for .F. nao prossegue com o cancelamento
		If (ValType(lCancela) <> "L")
			Return(.F.)
		ElseIf !lCancela
			Return(.F.)
		Endif 
	Endif
	If lIntQly //Se tiver integração com o Quality
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando há integração, só não permite a exclusão quando a³
		//³função QNCVERI retornar .F., caso contrário, por padrão ³
		//³permite o cancelamento.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCancela := .T.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a QNC pode ser desvinculada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SUD")
		DbSetOrder(1)
		For nCntFor:=1 To Len(aCols)
			If DbSeek(xFilial("SUD")+M->UC_CODIGO+StrZero(nCntFor,2)) .AND. !Empty(SUD->UD_CODFNC)
				lCancela:=QNCVERI(SUD->UD_CODFNC, SUD->UD_FNCREV, "TMK") 
				If !lCancela 
					Exit	
				Endif
			Endif
		Next
		If !lCancela
			Help( " ", 1, "TMKFNCPRO") // Esse atendimento possui Ficha de Não-Conformidade(STATUS PROCEDE), portanto não pode ser cancelado.
			Return(.f.)
		Endif
	Endif
		
	DbSelectarea("SUC")
	DbSetorder(1)
	If DbSeek(xFilial("SUC") + M->UC_CODIGO)

		If !Empty(SUC->UC_CODENCE) .OR. !Empty(SUC->UC_CODMOT)
			Help(" ",1,"ENCERRADA")
			Return(lCancela)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o atendimento foi cancelado o usuario pode apenas visualizar o motivo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SUC->UC_CODCANC)
			DEFINE MSDIALOG oDlgVCan FROM 05,10 TO 170,270 TITLE STR0014 PIXEL //"Motivo de Cancelamento"
	
				cObs := MSMM(SUC->UC_CODCANC,TamSx3("UC_OBSCANC")[1])
	
				@03,04 TO 62,128 LABEL STR0015 OF oDlgVcan PIXEL //"Motivo informado"
				@12,08 GET oObs VAR cObs OF oDlgVCan MEMO size 113,45 PIXEL READONLY NO VSCROLL
	
				oObs:oFont := oMonoAs
				DEFINE SBUTTON FROM 65,100 TYPE 1 ENABLE ACTION oDlgVcan:End()
	
			ACTIVATE MSDIALOG oDlgVCan CENTER

			Return(lCancela)
		Endif
		
		If ! TmkOK(STR0016) //"Confirma Cancelamento ?"
		   Return(lCancela)
		Endif
		   
		DEFINE MSDIALOG oDlgVCan FROM 05,10 TO 170,270 TITLE STR0014 PIXEL  //"Motivo de Cancelamento"
	
			cObs := MSMM(SUC->UC_CODCANC,TamSx3("UC_OBSCANC")[1])
		
			@03,04 TO 62,128 LABEL STR0017 OF oDlgVcan PIXEL //"Digite o Motivo"
			@12,08 GET oObs VAR cObs OF oDlgVCan MEMO SIZE 113,45 PIXEL Valid !Empty(cObs)
		
			oObs:oFont := oMonoAs
		
			DEFINE SBUTTON FROM 65,100  TYPE 1 ACTION (nOpca:=1,oDlgVCan:End() ) ENABLE OF oDlgVCan
		
		ACTIVATE MSDIALOG oDlgVCan CENTER
			
		If nOpca == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o MEMO de cancelamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lCancela := .T.		
			RecLock("SUC",.F.)
			MSMM(,TamSx3("UC_OBSCANC")[1],,cObs,1,,,"SUC","UC_CODCANC")
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apaga a lista de Contato Pendente gerada para esse atendimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SU4")
			DbSetOrder(2) // Pesquisar pela descricao temporariamente.
			If DbSeek(xFilial("SU4")+"Atendimento: "+M->UC_CODIGO)
				
				DbSelectarea("SU6")
                DbSetorder(1)
                If DbSeek(xFilial("SU6")+SU4->U4_LISTA)
					Reclock("SU6",.F.)
					DbDelete()
					MsUnlock()

					DbSelectarea("SU4")
					Reclock("SU4",.F.)
					DbDelete()
					MsUnlock()
            	Endif
			EndIf
		   
			If lCancela .AND. lIntQly // integração com o QNC para cancelamento da FNC
				For nCntFor:=1 To Len(aCols)                                
			    	DbSelectArea("SUD")
			    	DbSetOrder(1)
					If DbSeek(xFilial("SUD")+M->UC_CODIGO+StrZero(nCntFor,2))
						QNCBAIXA(SUD->UD_CODFNC, SUD->UD_FNCREV, "TMK",)
					Endif
				Next
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada depois do cancelamento do atendimento TMK³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTMKMDC
			U_TMKMDC(nOpca)
		Endif
	Endif    
	
Elseif nFolder == 2  // Televendas
	
	If lTMKVEX
		lCancela := ExecBlock( "TMKVEX", .F., .F. )
		
		// Se o retorno for .F. nao prossegue com o cancelamento
		If (ValType(lCancela) <> "L")
			Return(.F.)
		ElseIf !lCancela
			Return(.F.)
		Endif 
	Endif
	
	// verifico se existe a ligacao antes de cancelar
	DbSelectarea("SUA")
	DbSetorder(1)
	If DbSeek(xFilial("SUA") + M->UA_NUM)

		// Se nao tiver sido LIBERADO pelo SIGAFAT entao pode-se cancelar o pedido
		DbSelectarea("SC9")
		DbSetorder(1)
		If DbSeek(xFilial("SC9")+SUA->UA_NUMSC5)
			Help(" ",1,"TLVLIBSC9")
			Return(lCancela)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao tiver sido faturado ou tiver a NF cancelada entao pode-se cancelar o pedido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUA->UA_STATUS == "NF."
			Help(" ",1,"NF.EMITIDA")
			Return(lCancela)
		Endif
		
		//ÚÄLocalizacoesÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se n„o tiver sido REMITITDO ou tiver a RM cancelado entao pode-se cancelar o pedido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUA->UA_STATUS == "RM."
			Help(" ",1,"RM.ENVIADA")
			Return(lCancela)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida a integracao de orcamentos para o SIGALOJA          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SUA->UA_NUMSL1)
			If  cTmkaloj == "S"   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o orçamento no loja está em aberto             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectarea("SL1")
				DbSetorder(1)
				If DbSeek(xFilial("SC9")+SUA->UA_NUMSL1)
					If !((Empty(L1_DOC) .AND. Empty(L1_RESERVA) .AND. dDataBase<=L1_DTLIM .AND. L1_STATUS <> "D" .AND. L1_STORC <> "C"   .AND. Empty(L1_STATUES)) .OR.;
					 	 (Empty(L1_DOC) .AND. !Empty(L1_RESERVA) .AND. Empty(L1_DOCPED) .AND. L1_STATUS <> "D" .AND. Empty(L1_PEDRES)))
						Help(" ",1,"ORC_LJ01")
						Return(lCancela)
					Endif	
				Endif	
			Else	
				Help(" ",1,"ORC_LOJA")
				Return(lCancela)
			Endif 
		Endif 
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o Operador tem acesso (Senhas) para excluir o pedido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Val(SUA->UA_OPER) == FATURAMENTO) .AND. !Empty(SUA->UA_NUMSC5)
			If !ChkPsw(21)
				Return(lCancela)
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apaga a somente a lista de Contato Pendente gerada para esse atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SU4")
		DbSetOrder(2) // Pesquisar pela descrição temporariamente.
		If DbSeek(xFilial("SU4")+"Atendimento: "+M->UA_NUM)
			
			DbSelectarea("SU6")
			DbSetorder(1)
			If DbSeek(xFilial("SU6")+SU4->U4_LISTA)
				Reclock("SU6",.F.)
				DbDelete()
				MsUnlock()

				DbSelectarea("SU4")
				Reclock("SU4",.F.)
				DbDelete()
				MsUnlock()
			Endif
		Endif
		        
		If SUA->UA_STATUS == "CAN"
			
			DEFINE MSDIALOG oDlgVCan FROM 05,10 TO 170,270 TITLE STR0014 PIXEL //"Motivo de Cancelamento"
				cObs := MSMM(SUA->UA_CODCANC,TamSx3("UA_OBSCANC")[1])
		
				@03,04 TO 62,128 LABEL STR0015 OF oDlgVcan PIXEL  //Motivo Informado
				@12,08 GET oObs VAR cObs OF oDlgVCan MEMO SIZE 113,45 PIXEL READONLY NO VSCROLL
		
				oObs:oFont := oMonoAs
		
				DEFINE SBUTTON FROM 65,100 TYPE 1 ACTION (nOpca := 1,oDlgVCan:End()) ENABLE OF oDlgVCan
		
			ACTIVATE MSDIALOG oDlgVCan CENTER

			Return(lCancela)
		Endif
				
		If !TMKOK(STR0016)  //"Confirma Cancelamento ?"
  			Return(lCancela)
		Endif

		DEFINE MSDIALOG oDlgVCan FROM 05,10 TO 170,270 TITLE STR0014 PIXEL //"Motivo de Cancelamento"
		
			cObs := MSMM(SUA->UA_CODCANC,TamSx3("UA_OBSCANC")[1])
			
			@ 03,04 TO 62,128 LABEL STR0017 OF oDlgVcan PIXEL  //"Digite o Motivo"
			@ 12,08 GET oObs VAR cObs OF oDlgVCan MEMO SIZE 113,45 PIXEL Valid !Empty(cObs)
			
			oObs:oFont := oMonoAs
		
			DEFINE SBUTTON FROM 65,100 TYPE 1 ACTION (nOpca := 1,oDlgVCan:End()) ENABLE OF oDlgVCan
		
		ACTIVATE MSDIALOG oDlgVCan CENTER
			
		If nOpca == 1
			lCancela:= .T.		
		
			RecLock("SUA",.F.)
			Replace UA_CANC   With "S"
			Replace UA_STATUS With "CAN"
			MSMM(,TamSx3("UA_OBSCANC")[1],,cObs,1,,,"SUA","UA_CODCANC")
			MsUnlock()
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apaga o pedido se ele ainda nao foi liberado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea("SC5")
			DbSetorder(1)
			If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5,.T.)
				RecLock("SC5",.F.,.T.)
				DbDelete()
				MsUnLock()
			
				DbSelectarea("SC6")
				DbSetorder(1)
				If DbSeek(xFilial("SC6")+SUA->UA_NUMSC5,.T.)
					While !Eof() .AND. (xFilial("SC6")+SUA->UA_NUMSC5 == C6_FILIAL+C6_NUM)
						Reclock( "SC6" ,.F.,.T.)
						DbDelete()

						MaAvalSC6("SC6",2,"SC5")

						SC6->(MsUnLock())

						DbSkip()
					End
					MsUnLockAll()
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apaga a lista de Contato Pendente gerada para esse atendimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SU4")
			DbSetOrder(2) // Pesquisar pela descricao temporariamente
			If DbSeek(xFilial("SU4")+"Atendimento: "+M->UA_NUM)
				
				DbSelectarea("SU6")
                DbSetorder(1)
                If DbSeek(xFilial("SU6")+SU4->U4_LISTA)
					Reclock("SU6",.F.)
					DbDelete()
					MsUnlock()

					DbSelectarea("SU4")
					Reclock("SU4",.F.)
					DbDelete()
					MsUnlock()
            	Endif
			Endif 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Libera o orçamento para edição no loja, claro, se ele for do³
			//³loja.                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nOpc == 4)
				TkLibLoja("D")
			EndIf

			Tk273DelLoj(nOpc,SUA->UA_NUMSL1) 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada depois do cancelamento do atendimento TLV³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTMKVDC
				U_TMKVDC(nOpca,M->UA_NUM)
			Endif
			
		Endif
	Endif
Elseif nFolder == 3  // TeleCobranca
	
	If lTMKMEX
		lCancela := ExecBlock( "TMKMEX", .F., .F. )
		
		// Se o retorno for .F. nao prossegue com o cancelamento
		If (ValType(lCancela) <> "L")
			Return(lCancela)
		ElseIf !lCancela
			Return(lCancela)
		Endif 
	Endif
	
	DbSelectarea("ACF")
	DbSetorder(1)
	If DbSeek(xFilial("ACF") + M->ACF_CODIGO)

		If ACF->ACF_STATUS == "3"
			Help(" ",1,"ENCERRADA")
			Return(lCancela)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o atendimento foi cancelado o usuario pode apenas visualizar o motivo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(ACF->ACF_CCANC)
			DEFINE MSDIALOG oDlgVCan FROM 05,10 TO 170,270 TITLE STR0014 PIXEL //"Motivo de Cancelamento"
	
				cObs := MSMM(ACF->ACF_CCANC,TamSx3("ACF_OBSCAN")[1])
	
				@03,04 TO 62,128 LABEL STR0015 OF oDlgVcan PIXEL //"Motivo informado"
				@12,08 GET oObs VAR cObs OF oDlgVCan MEMO size 113,45 PIXEL READONLY NO VSCROLL
	
				oObs:oFont := oMonoAs
				DEFINE SBUTTON FROM 65,100 TYPE 1 ENABLE ACTION oDlgVcan:End()
	
			ACTIVATE MSDIALOG oDlgVCan CENTER

			Return(lCancela)
		Endif
		
		If !TmkOK(STR0016) //"Confirma Cancelamento ?"
		   Return(lCancela)
		Endif
		   
		DEFINE MSDIALOG oDlgVCan FROM 05,10 TO 170,270 TITLE STR0014 PIXEL  //"Motivo de Cancelamento"
			
			cObs := MSMM(ACF->ACF_CCANC,TamSx3("ACF_OBSCAN")[1])
			
			@03,04 TO 62,128 LABEL STR0017 OF oDlgVcan PIXEL //"Digite o Motivo"
			@12,08 GET oObs VAR cObs OF oDlgVCan MEMO SIZE 113,45 PIXEL Valid !Empty(cObs)
		
			oObs:oFont := oMonoAs
		
			DEFINE SBUTTON FROM 65,100  TYPE 1 ACTION (nOpca:=1,oDlgVCan:End() ) ENABLE OF oDlgVCan
		
		ACTIVATE MSDIALOG oDlgVCan CENTER
			
		If nOpca == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o MEMO de cancelamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lCancela := .T.		
			RecLock("ACF",.F.)
			MSMM(,TamSx3("ACF_OBSCAN")[1],,cObs,1,,,"ACF","ACF_CCANC")
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apaga a lista de Contato Pendente gerada para esse atendimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SU4")
			SU4->(DbSetOrder(4)) // U4_CODLIG
			If SU4->(DbSeek(xFilial("SU4")+M->ACF_CODIGO))
				
				While !SU4->(Eof()) .AND. xFilial("SU4")==U4_FILIAL .AND. U4_CODLIG == M->ACF_CODIGO
				
					aAdd(aLista,SU4->U4_LISTA)
					
					Reclock("SU4",.F.)
						REPLACE SU4->U4_STATUS WITH "2"
						REPLACE SU4->U4_ROTINA WITH "TK271CANCELA"
					MsUnlock()
                
					SU4->(DbSkip())
				End
			EndIf
			
			If Len(aLista) > 0
				For nI := 1 To Len(aLista)
					DbSelectarea("SU6")
          			SU6->(DbSetorder(1))
              	If SU6->(DbSeek(xFilial("SU6")+aLista[nI]))
						Reclock("SU6",.F.)
							REPLACE SU6->U6_STATUS WITH "3"
							REPLACE SU6->U6_ROTINA WITH "TK271CANCELA"	
						MsUnlock()
					EndIf
				Next nI
				lLimpaSK1:= .T.
			EndIf
			
			If lLimpaSK1
				Dbselectarea("ACG")
				DbSetOrder(1)
				If DbSeek(xFilial("ACG")+ M->ACF_CODIGO)
					While !Eof() .AND. xFilial("ACG") == ACG->ACG_FILIAL .AND.;
								  		M->ACF_CODIGO  == ACG->ACG_CODIGO

						cFilOrig:= ACG->ACG_FILORI

							
						DbSelectArea("SK1")
						DbSetOrder(1)
						If DbSeek(xFilial("SK1") + ACG->ACG_PREFIX+ ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO + cFilOrig)
							RecLock("SK1", .F.)
							REPLACE SK1->K1_OPERAD WITH ""
							MsUnLock()  
						Endif
												
						Dbselectarea("ACG")
						DbSkip()           
					End
				Endif		
			Endif	
		Endif
	Endif
Endif

If !lCancela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este atendimento nao pode ser cancelado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help(" ",1,"NOCANCELAM")
Else           

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houve a gravação e é o primeiro atendimento, seta a ³
	//³variável lPriContato para .F.                          ³
	//³Essa variável é utilizada para que se possa desabilitar³
	//³o cancelamento da janela de atendimento quando é o     ³
	//³primeiro atendimento que está sendo gravado e o        ³
	//³atendimento foi efetuado a partir da agenda do operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lCancela .AND. lPriContato)
		lPriContato := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da exibicao da mensagem de fechamento de tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMsg := .F.
Endif				
				
Return(lCancela)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Tk271Discagem³ Autor ³ Vendas Clientes       ³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Exibe a tela para a discagem automatica 						 ³±±
±±³          ³-O desenho do telefone esta no arquivo AP6CONN.DLL			 ³±±
±±³          ³-Para TMK a discagem e feita para os telefones do CONTATO - SU5³±±
±±³          ³-Para TLV a discagem e feita para o CLIENTE ou PROSPECT-SA1/SUS³±±
±±³          ³-Para TLC a discagem e feita para o CLIENTE - SA1              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CALL CENTER                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk271Discagem(oDlg)

Local cEntidade:= ""									//Alias da entidade
Local cChave   := ""									//Chave da entidade
Local cCodCont := ""		   							//Codigo do contato
Local nCol 	   := 220				 					//Numero de colunas
Local nLin 	   := 25									//Numero de linhas
Local cTipoCti := TkPosto(TkOperador(),"U0_TIPOCTI")	//Tipo da CTI
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os codigos da entidade e contato.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFolder == 1 // TeleMarketing ou Televendas
	If TkGetTipoAte() $ "145" //Telemarketing, Ambos e TMK x TLV
		cChave    := M->UC_CHAVE
		cCodCont  := M->UC_CODCONT
		cEntidade := M->UC_ENTIDAD
		
	Elseif TkGetTipoAte() == "2" //Televendas
		cChave     := M->UA_CLIENTE + M->UA_LOJA
		cCodCont   := M->UA_CODCONT
		cEntidade  := IIF(lProspect,"SUS","SA1")
		
		
	ElseIf TkGetTipoAte() == "3" //Telecobranca
		cChave     := M->ACF_CLIENT + M->ACF_LOJA
		cCodCont   := M->ACF_CODCON
		cEntidade  := IIF(lProspect,"SUS","SA1")
	Endif
	
ElseIf nFolder == 2 // Televendas
	cChave     := M->UA_CLIENTE + M->UA_LOJA
	cCodCont   := M->UA_CODCONT
	cEntidade  := IIF(lProspect,"SUS","SA1")
	
ElseIf nFolder == 3 // Telecobranca
	cChave     := M->ACF_CLIENT + M->ACF_LOJA
	cCodCont   := M->ACF_CODCON
	cEntidade  := IIF(lProspect,"SUS","SA1")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo de discagem a ser realizada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoCti == "3" // 3 - Manual  

	Tk271Tel(cCodCont,cChave,cEntidade)
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe as opcoes de discagem ativa configurados pelo parametro MV_TMKCFGR ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SGMnuAtivo(	NIL		,cEntidade	,cChave	,cCodCont	,;
				nLin	,nCol		,oDlg	,NIL		,;
				NIL, 	,NIL		,NIL	,NIL		,;
				NIL, 	,NIL		,NIL	,NIL		,;
				NIL)
Endif


Return(NIL) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³Tk271ShowScript³Autor  ³ Vendas Clientes      ³Data  ³  12/05/00  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição³Exibe os SCRIPTS da campanha selecionada. Os scripts serao        º±±
±±º         ³selecionados de acordo com:									   º±±
±±º         ³o Tipo de atendimento 			                              	   º±±
±±º         ³- Ativo                                                           º±±
±±º         ³- Receptivo                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³CALL CENTER                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271Script(nOpc,aParScript,cEntidade,lMosTraTela,oContato,oCampanhas,tableStructure)

Local oDlgScri									//Tela para escolha dos SCRIPTS da campanha selecionada
Local oLbx1										//Listbox com os scripts para escolha
Local lRet      := .F.							//Retorno da funcao
Local lTMKVTM 	:= ExistBlock("TMKVTM")     	//Ponto de Entrada
Local nPos      := 0							//Posicao dentro do listbox
Local cCodCamp  := ""							//Codigo da Campanha
Local cScript   := ""							//Codigo do Script
Local cCliente  := ""							//Codigo do Cliente
Local cLoja     := ""							//Codigo da Loja	
Local cContato  := ""                           //Codigo do Contato
Local cOperador := ""                           //Codigo do Operador
Local cOperacao := ""							//Tipo da Operacao
Local aScript   := {}							//Array com os scripts da campanha
Local cCodAte	:= ""							//Codigo do Atendimento
Local cAte      := ""					        //Folder do atendimento utilizado.
Local cRetAte   := ""                           // Atendimento no qual foi executado o script dinamico. 
Local lTk271Scr	:= ExistBlock("TK271SCR")		//Ponto de entrada 
Local bOk		:= NIL							// Instrucao executada ao clicar em ok ou duplo clique no script

Default cEntidade := ""							//Codigo da Entidade

lExibe := .T.

If Empty( cEntidade )
	cAte      := Alltrim(Str(nFolder))        //Folder do atendimento utilizado.

	If nFolder == 1 // Telemarketing ou Televendas
	
		If TkGetTipoAte() $ "145" // Telemarketing ,Ambos e TMK x TLV
			cCodCamp := M->UC_CODCAMP
			cEntidade:= M->UC_ENTIDAD
			cCliente := SubStr(M->UC_CHAVE,1,TamSX3("A1_COD")[1])
			cLoja    := SubStr(M->UC_CHAVE,TamSX3("A1_COD")[1] + 1,TamSX3("A1_LOJA")[1])
			cContato := M->UC_CODCONT
			cOperador:= M->UC_OPERADO
			cOperacao:= M->UC_OPERACA
			cCodAte	 := M->UC_CODIGO
	
		ElseIf TkGetTipoAte() == "2" 				// Televendas
			cCodCamp := M->UA_CODCAMP
			cEntidade:= IIF(lProspect,"SUS","SA1")
			cCliente := M->UA_CLIENTE
			cLoja    := M->UA_LOJA
			cContato := M->UA_CODCONT
			cOperador:= M->UA_OPERADO
			cOperacao:= M->UA_TMK
			cCodAte	 := M->UA_NUM
	
		ElseIf TkGetTipoAte() == "3" 				// TeleCobranca
			cCodCamp := M->ACF_CODCAM
			cEntidade:= "SA1"
			cCliente := M->ACF_CLIENT
			cLoja    := M->ACF_LOJA
			cContato := M->ACF_CODCON
			cOperador:= M->ACF_OPERAD
			cOperacao:= M->ACF_OPERA
			cCodAte	 := M->ACF_CODIGO
		Endif
		
	ElseIf nFolder == 2  //Televendas
		cCodCamp := M->UA_CODCAMP
		cEntidade:= IIF(lProspect,"SUS","SA1")
		cCliente := M->UA_CLIENTE
		cLoja    := M->UA_LOJA
		cContato := M->UA_CODCONT
		cOperador:= M->UA_OPERADO
		cOperacao:= M->UA_TMK
		cCodAte	 := M->UA_NUM
	
	ElseIf nFolder == 3  //TeleCobranca
		cCodCamp := M->ACF_CODCAM
		cEntidade:= "SA1"
		cCliente := M->ACF_CLIENT
		cLoja    := M->ACF_LOJA
		cContato := M->ACF_CODCON
		cOperador:= M->ACF_OPERAD
		cOperacao:= M->ACF_OPERA
		cCodAte	 := M->ACF_CODIGO
		
	ElseIf nFolder == 4 //Help Desk
		cCodCamp := M->&(tableStructure:campaignKey:name)
		cEntidade:= M->&(tableStructure:entityName:name)
		cCliente := SubStr(M->&(tableStructure:entityKey:name),1,TamSX3("A1_COD")[1])
		cLoja    := SubStr(M->&(tableStructure:entityKey:name),TamSX3("A1_COD")[1] + 1,TamSX3("A1_LOJA")[1])
		cContato := M->&(tableStructure:contactField:name)
		cOperador:= TkOperador()
		cOperacao:= M->&(tableStructure:operationCode:name)
		cCodAte	 := M->&(tableStructure:registerCode:name)	
	Endif
	
Else
	If cEntidade == "ACH"	// Suspect
		cCliente := M->ACH_CODIGO
		cLoja    := M->ACH_LOJA
	ElseIf cEntidade == "SUS"	// Prospect
		cCliente := IIF(nOpc == 3,M->US_COD,SUS->US_COD)
		cLoja    := IIF(nOpc == 3,M->US_LOJA,SUS->US_LOJA)
	ElseIf cEntidade == "SA1"	// Cliente
		cCliente := M->A1_COD
		cLoja    := M->A1_LOJA
	EndIf	

	cCodCamp	:= ""
	cContato	:= ""
	cOperacao	:= ""
	
	If lTk271Scr
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O PE TK271SCR deve alterar o valor das variaveis cCodCamp     ³
		//³e cContato, passadas por referencia e, alem disto, retornar se³
		//³a janela para captura destes dados deve ser exibida           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lExibe := ExecBlock( "TK271SCR", .F., .F., { @cCodCamp, @cContato, @cOperacao } )
		
		// Valida os retornos do Ponte de Entrada
		If Type("lExibe") <> "L"
			lExibe	:= .T.
		EndIf
		
		SUO->( dbSetOrder(1) )	//UO_FILIAL+UO_CODCAMP
		SU5->( dbSetOrder(1) )	//U5_FILIAL+U5_CODCONT

		// Se não retornou char em um dos parâmetros, deve exibir a janela
		If Type("cCodCamp") <> "C" .OR. Empty(cCodCamp) .OR. SUO->( !dbSeek( xFilial("SUO")+cCodCamp ) )
			cCodCamp	:= ""
			lExibe		:= .T.
		EndIF
		
		If Type("cContato") <> "C" .OR. Empty(cContato) .OR. SU5->( !dbSeek( xFilial("SU5")+cContato ) )
			cContato	:= ""
			lExibe		:= .T.
		EndIF

		If Type("cOperacao") <> "C" .OR. Len(cOperacao) <> 1 .OR. !(cOperacao$"12")
			cOperacao	:= ""
			lExibe		:= .T.
		EndIF
	EndIf

	If lExibe
		If !Tk271AskCp( cEntidade, cCliente, cLoja, @cCodCamp, @cContato, @cOperacao,@lMosTraTela,@oContato,@oCampanhas )	// Static Function neste mesmo fonte
			Return .F.
		EndIf
	EndIf
EndIf

If lMosTraTela

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se foi selecionado a campanha e o tipo da ligacao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCodCamp) .OR. Empty(cOperacao)
		Help(" ",1,"FALTA_CAMP" )
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O codigo do contato faz parte da chave de pesquisa para identificar se um script³
	//³ja foi executado para ele, portanto nao pode estar em branco.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cContato)
		Aviso(STR0032,STR0033,{"OK"}) //"E necessário informar o código do contato para executar o script" 
		Return(lRet)
	Endif
Endif	 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Evita que a campanha seja gravada sem entidade e sua chave.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cEntidade) .Or. Empty(cCliente+cLoja)
	If !lTk271Auto
		Aviso(STR0032,STR0063, {"OK"}) // "E necessário informar a entidade para executar o script"
	EndIf
	Return(lRet)
EndIf

If lTMKVTM
	U_TMKVTM(M->UC_CODIGO,M->UA_NUM,cCliente,cLoja,cContato,cOperador)
	lRet := .T.
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona os scripts que pertencem a campanha selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCodCamp)

	cQuery := " SELECT UW_CODEVE,UW_DESCEVE,UW_CODCAMP,UW_CODSCRI,UW_PRODUTO,UW_MIDIA,UZ_CODSCRI,UZ_DESC,UZ_TEMPO,UZ_TIPO,UZ_FORMATO,UZ_ARMRESP,UZ_SCORMIN,UZ_PROCMIN,UZ_SCORMAX,UZ_PROCMAX "
	cQuery += " FROM " + RetSqlName("SUW") + " SUW, " + RetSqlName("SUZ") + " SUZ "
	cQuery += " WHERE SUW.UW_FILIAL = '"+xFilial("SUW")+"' AND SUW.D_E_L_E_T_ = '' "
	cQuery += "   AND SUZ.UZ_FILIAL = '"+xFilial("SUZ")+"' AND SUZ.D_E_L_E_T_ = '' "
	cQuery += "   AND SUW.UW_CODCAMP = '"+cCodCamp+"' "
	cQuery += "   AND SUZ.UZ_CODSCRI = SUW.UW_CODSCRI "
	cQuery += "   AND (SUZ.UZ_TIPO = '"+cOperacao+"' OR SUZ.UZ_TIPO = '3') "
	            
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TMPSUW", .F., .T.)

	dbSelectArea("TMPSUW")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os scripts para a selecao do operador ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !Eof()
		AAdd(aScript,{	Tk271ExeScr(cCodCamp,TMPSUW->UZ_CODSCRI,cContato,cEntidade,cCliente+cLoja,cAte,cCodAte, @cRetAte,@aParScript),;
							TMPSUW->UZ_CODSCRI,;								//Codigo do Script
							TMPSUW->UZ_DESC,;									//Descricao
							IIF(TMPSUW->UZ_FORMATO == "1",STR0001,STR0002),;   //"Atendimento"/"Pesquisa"
							TMPSUW->UZ_FORMATO,;                               //Campo Tipo
							cRetAte})
		DbSkip()
	EndDo

	TMPSUW->(dbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe algum script que atende as condicoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(aScript) > 0)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define acao comum ao botao OK e ao duplo clique do listbox³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bOk	:= {||lRet:= .T., nPos:= oLbx1:nAt,oDlgScri:End()}
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a tela para a escolha do script a ser executado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgScri FROM  50,0 TO 260,700 TITLE STR0003 PIXEL //"Script Dinamico"
	
			@02,03 TO 87,337 LABEL "" OF oDlgScri PIXEL
			@05,05 LISTBOX oLbx1 FIELDS HEADER ;
				"",;
				STR0004,;  //"Script"
				STR0005,;  //"Titulo"
				STR0006,;  //"Formato"
				STR0001;   //"Atendimento"
				SIZE 330,80 OF oDlgScri PIXEL NOSCROLL 

			oLbx1:SetArray(aScript)
			oLbx1:bLine:={||{Tk271LegScri(	 aScript[oLbx1:nAt,1]),;
											 aScript[oLbx1:nAt,2],;
											 aScript[oLbx1:nAt,3],;
											 aScript[oLbx1:nAt,4],;							 
											 aScript[oLbx1:nAt,6]}}
			oLbx1:bLDblClick := bOk
			oLbx1:Refresh()

			@90,03 TO 103,200 LABEL STR0018 OF oDlgScri PIXEL		// Legenda
			
			@ 95,05  BitMap oBmp1 ResName "ENABLE"  OF oDlgScri Size 10,10 NoBorder When .F. Pixel 
			@ 95,52  BitMap oBmp1 ResName "DISABLE" OF oDlgScri Size 10,10 NoBorder When .F. Pixel 
			@ 95,105 BitMap oBmp1 ResName "BR_AZUL" OF oDlgScri Size 10,10 NoBorder When .F. Pixel
			
			@ 95,015 SAY  STR0019 OF oDlgScri COLOR CLR_GREEN PIXEL 
			@ 95,062 SAY  STR0020 OF oDlgScri COLOR CLR_RED   PIXEL 
			@ 95,115 SAY  STR0021 OF oDlgScri COLOR CLR_BLUE  PIXEL 

			DEFINE SBUTTON FROM 90,260	TYPE 15 ENABLE OF oDlgScri ACTION (lRet:= Tk271VisScr(cCodCamp,aScript[oLbx1:nAt,2],cContato,cEntidade,cCliente+cLoja,cAte,cCodAte, @cRetAte), IF(lRet,,oDlgScri:End())  )
			DEFINE SBUTTON FROM 90,290  TYPE 1 ENABLE OF oDlgScri ACTION (Eval(bOk))
			DEFINE SBUTTON FROM 90,320	TYPE 2 ENABLE OF oDlgScri ACTION (lRet:= .F.,oDlgScri:End())
	
		ACTIVATE MSDIALOG oDlgScri CENTERED
	
		If lRet
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o script selecionado já foi aplicado ao cliente neste atendimento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cScript:= aScript[nPos][2]
			
			If Len(aParScript)>0  .AND. (nOpc==3 .OR. nOpc==4)
				If cCodAte==aParScript[1][13] .AND. cCodCamp==aParScript[1][6] 
			   		 If cScript<>aParScript[1][7]
			   		 	If !TmkOk(STR0022)//"Para esta inclusão de atendimento já foi efetuado outro Script Dinâmico. Deseja Iniciar um novo Script? "
			   		 		lRet := .F.
			   		 	Endif	
			   		 Endif
			   	Endif	
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa o script que foi selecionado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				Tk380Script(nOpc		,cCodCamp		,cScript	,cContato,;
							cEntidade	,cCliente+cLoja	,NIL		,NIL,;
							cOperador	,"&*%*%%"	    ,NIL        ,cCodAte,;
							@aParScript)
			Endif
		Endif
	Endif
Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk271ExeScrºAutor ³ Vendas Clientes    º Data ³  10/21/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avalia se o Script que será exibido foi ou nao executado e  º±±
±±º          ³se executado se foi no atendimento posicionado ou em outro. º±±
±±º          ³De acordo com esta avaliacao a funcao retorna um caracter   º±±
±±º          ³entre 1,2 e 3 que serão os flags para as legendas. A funcao º±±
±±º          ³tambem retorna o codigo do atendimento se este Script ja foiº±±
±±º          ³executado.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271ExeScr(cCampanha	, cScript	, cCodCont	, cEntidade	,;
							cChave		, cAte		, cCodAte	, cRetAte	,;
							aParScript	)

Local cRet   := "2" // nao executado // vermelho // valores proveniente da funcao tkpendente em TMKXFUNA
Local aSArea := GetArea() //Area atual para restauracao posterior

cRetAte := "" // limpa variavel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o atendimento ja foi executado para o³
//³atendimento atual                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aParScript) > 0
	nPos := aScan(aParScript,{|x| x[6]==cCampanha .AND. x[7]==cScript .AND. x[13]==cCodAte })  
	If nPos > 0
		cRet 	:= "3" // ja executado neste atendimento // verde
		cRetAte := cCodAte
	EndIf
EndIf

If (cRet == "2")
	cQuery := " SELECT ACI_CODCAM,ACI_CODSCR,ACI_ROTINA,ACI_ATEND "
	cQuery += " FROM " + RetSqlName("ACI") 
	cQuery += " WHERE ACI_FILIAL = '"+xFilial("ACI")+"' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += "   AND ACI_CODCON = '" +Alltrim(cCodCont)+ "' "
	cQuery += "   AND ACI_ENTIDA = '" +cEntidade+ "' "
	cQuery += "   AND ACI_CHAVE = '" +AllTrim(cChave)+ "' "
	cQuery += " ORDER BY ACI_FILIAL,ACI_CODCON,ACI_ENTIDA,ACI_CHAVE "
	            
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TMPACI", .F., .T.)
	dbSelectArea("TMPACI")
	dbGoTop()
	
	If !Found()
		While TMPACI->(!Eof())
			If  (Alltrim(TMPACI->ACI_CODCAM) == cCampanha) .AND. (Alltrim(TMPACI->ACI_CODSCR) == cScript) .AND. (TMPACI->ACI_ROTINA == cAte)
				IF TMPACI->ACI_ATEND == cCodAte
					cRet 	:= "3" // ja executado neste atendimento // verde
					cRetAte := TMPACI->ACI_ATEND
				Else
					cRet 	:= "1" // Executado em outro atendimento.  // azul
					cRetAte := TMPACI->ACI_ATEND
				Endif
			Endif
			DbSkip()
		EndDo // sai do laco quando encontrar o ultimo registro com este atendimento.
   EndIf
   
   TMPACI->(dbCloseArea())

EndIf

RestArea(aSArea)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk271VisScrºAutor ³ Vendas CRM         º Data ³  06/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Localiza o script e chama a tela de visualizacao de script. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271VisScr(cCampanha,cScript,cCodCont,cEntidade,cChave,cAte,cCodAte)

Local aSArea		:= GetArea() //Area atual para restauracao posterior
Local lEncontrou	:= .F.

DbSelectArea("ACI")
DbSetOrder(2)
If DbSeek(xFilial("ACI")+cCodCont+cEntidade+cChave)

	While((!EOF()) .AND. (xFilial("ACI") == ACI_FILIAL) 	.AND.;
 						 (Alltrim(ACI_CODCON) == Alltrim(cCodCont))  .AND.;
						 (ACI_ENTIDA == cEntidade) 			.AND.;
						 (Alltrim(ACI_CHAVE) == Alltrim(cChave)) )
							
		If  (Alltrim(ACI_CODCAM) == cCampanha) .AND. (Alltrim(ACI_CODSCR) == cScript) .AND. (ACI_ROTINA == cAte)
			IF ACI_ATEND == cCodAte
				lEncontrou := .T.
				TkVisScr( ACI_CODIGO, , .T. )
			Endif
		Endif
		
		DbSkip()
	End
Endif

If !lEncontrou
	Aviso(STR0032, STR0064,{"OK"}) // "O script ainda não foi executado."
EndIf

RestArea(aSArea)
Return lEncontrou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ³Tk271AltEnt³ Autor ³ Vendas Clientes       ³ Data ³ 22/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Altera dos dados da entidade selecionada			 	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³Call Center      			 								   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271AltEnt()

Local aArea		:= {}								//Salva a area atual
Local cCad			:= cCadastro						//Armazena o cCadastro atual
Local aRots		:= {}								//Armazena o aRotinas  atual
Local cEntidade	:= ""								//Alias da Entidade
Local cChave		:= ""								//Chave da Entidade
Local cAtend		:= ""								//Codigo do atendimento
Local cCodCont	:= ""       						//Codigo do Contato
Local cOperador	:= ""								//Codigo do Operador
Local cCliente	:= ""								//Codigo do Cliente
Local cLoja		:= ""								//Codigo da Loja
Local cTipoAte	:= ""								//Tipo de Atendimento
Local cNewNEnt	:= ""								//Nome da Entidade atualizada
Local cFldNEnt	:= ""								//Nome da Entidade
Local cFldNEnt2	:= ""								//Nome da Entidade
Local cFldNEnt3	:= ""								//Nome da Entidade
Local lAltera		:= Nil								//Armazena conteudo da variavel ALTERA
Local lInclui		:= Nil								//Armazena conteudo da variavel INCLUI
Local lRet			:= .F.								//Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 82 (ACS), verifica se o usuário poder  ou não alterar cadastros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkPsw(82)
	Help(" ",1,"TMKACETLV")
	Return(lRet)
Endif

aArea		:= GetArea()
aRots		:= aClone(aRotina)
cTipoAte	:= TkGetTipoAte()

If Type("ALTERA") == "L"
	lAltera	:= ALTERA
EndIf

If Type("INCLUI") == "L"
	lInclui	:= INCLUI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena as informacoes do atendimento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFolder == 1 // Telemarketing, Televendas ou Telecobranca
	If (cTipoAte $ "145") // Telemarketing , Ambos ou TMK x TLV
		cAtend		:= M->UC_CODIGO
		cEntidade	:= M->UC_ENTIDAD
		cChave		:= M->UC_CHAVE
		cCodCont	:= M->UC_CODCONT
		cOperador	:= M->UC_OPERADO
		cFldNEnt	:= "M->UC_DESCCHA"
		cFldNEnt2	:= If(cTipoAte $ "45", "M->UA_DESCCLI", "")
		cFldNEnt3	:= If(cTipoAte == "4", "M->ACF_DESC", "")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a existencia do ponto de entrada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _lTMKMPE
			U_TMKMPE(cAtend,cEntidade,cChave,cCodCont,cOperador)
			Return(.T.)
		Endif
		
	ElseIf cTipoAte == "2" // Televendas
		cAtend		:= M->UA_NUM
		cEntidade	:= IIF(lProspect,"SUS","SA1")
		cCliente	:= M->UA_CLIENTE
		cLoja		:= M->UA_LOJA
		cCodCont	:= M->UA_CODCONT
		cOperador	:= M->UA_OPERADO
		cFldNEnt	:= "M->UA_DESCCLI"

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena os dados da chave primaria para pesquisa   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave		:= Alltrim(cCliente)+Alltrim(cLoja)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a existencia do ponto de entrada   		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _lTMKVPE
			U_TMKVPE(cAtend,cCliente,cLoja,cCodCont,cOperador)
			Return(.T.)
		Endif

	ElseIf cTipoAte == "3" // Telecobranca
		cAtend		:= M->ACF_CODIGO
		cEntidade	:= "SA1"
		cCliente	:= M->ACF_CLIENT
		cLoja		:= M->ACF_LOJA
		cCodCont	:= M->ACF_CODCON
		cOperador	:= M->ACF_OPERAD
		cFldNEnt	:= "M->ACF_DESC"

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena os dados da chave primaria para pesquisa   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave		:= M->ACF_CLIENT + M->ACF_LOJA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a existencia do ponto de entrada   		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _lTMKCPE
			U_TMKCPE(cAtend,cCliente,cLoja,cCodCont,cOperador)
			Return(.T.)
		Endif
	Endif
	
ElseIf nFolder == 2 // Televendas
	cAtend		:= M->UA_NUM
	cEntidade	:= IIF(lProspect,"SUS","SA1")
	cCliente	:= M->UA_CLIENTE
	cLoja		:= M->UA_LOJA
	cCodCont	:= M->UA_CODCONT
	cOperador	:= M->UA_OPERADO
	cFldNEnt	:= "M->UA_DESCCLI"
	cFldNEnt2	:= If(cTipoAte $ "45", "M->UC_DESCCHA", "")
	cFldNEnt3	:= If(cTipoAte == "4", "M->ACF_DESC", "")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena os dados da chave primaria para pesquisa   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave		:= cCliente+cLoja

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia do ponto de entrada   		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lTMKVPE
		U_TMKVPE(cAtend,cCliente,cLoja,cCodCont,cOperador)
		Return(.T.)
	Endif
    
ElseIf nFolder == 3 // Telecobranca
	cAtend		:= M->ACF_CODIGO
	cEntidade	:= "SA1"
	cCliente	:= M->ACF_CLIENT
	cLoja		:= M->ACF_LOJA
	cCodCont	:= M->ACF_CODCON
	cOperador	:= M->ACF_OPERAD
	cFldNEnt	:= "M->ACF_DESC"
	If cTipoAte == "4"
		cFldNEnt2	:= "M->UC_DESCCHA"
		cFldNEnt3	:= "M->UA_DESCCLI"
	EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena os dados da chave primaria para pesquisa   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave		:= M->ACF_CLIENT + M->ACF_LOJA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia do ponto de entrada   		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lTMKCPE
		U_TMKCPE(cAtend,cCliente,cLoja,cCodCont,cOperador)
		Return(.T.)
	Endif
Endif

aRotina	:= MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a alteração dos dados da entidade.			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cEntidade)
	DbSelectArea(cEntidade)
	If cEntidade = "BA1"
		lSelEntF3	:= GetNewPar("MV_TMKF3",.F.)
		If 	lSelEntF3
			BA1->(dbSetOrder(2))
		Else
			BA1->(dbSetOrder(1))
		EndIf
		If BA1->(MsSeek(xFilial(cEntidade)+cChave))
			INCLUI := .F.
			ALTERA := .T.
			PLSA260MOV("BA1",BA1->(RECNO()),4)
			lRet := .T.
		Else
			Help(" ",1,"SEMENTIDAD") //Selecione uma entidade valida
		EndIf
	Else
		DbSetOrder(1)
		If DbSeek(xFilial(cEntidade) + cChave)
			cCadastro	:= STR0011  //"Alteracao de Entidades"
			INCLUI		:= .F.
			ALTERA		:= .T.
			Do Case
				Case cEntidade == "SA1"
					aRotAuto := Nil
					A030Altera(cEntidade,Recno(),4)
				Case cEntidade == "SUS"
					FWExecView( STR0010, 'TMKA260', 4,, { || .T. } ) //"Alterar"
				Case cEntidade == "ACH"
					FWExecView( STR0010, 'TMKA341', 4,, { || .T. } ) //"Alterar"
				Otherwise
					AxAltera(cEntidade,Recno(),4)
			EndCase
			lRet		:= .T.
		Else
			Help(" ",1,"SEMENTIDAD") //Selecione uma entidade valida
		Endif
	EndIf

	If	lRet
		cNewNEnt	:= TkEntidade(cEntidade,cChave,1)
		If &(cFldNEnt) <> cNewNEnt
			&(cFldNEnt) := cNewNEnt
		EndIf
		If ! Empty(cFldNEnt2) .AND. ! Empty(&(cFldNEnt2)) .AND. &(cFldNEnt2) <> cNewNEnt
			&(cFldNEnt2) := cNewNEnt
		EndIf
		If ! Empty(cFldNEnt3) .AND. ! Empty(&(cFldNEnt3)) .AND. &(cFldNEnt3) <> cNewNEnt
			&(cFldNEnt3) := cNewNEnt
		EndIf
		cNomeHist	:= cNewNEnt
		oNomeHist:Refresh()
	EndIf	
Else
	Help(" ",1,"SEMENTIDAD") //Selecione uma entidade valida
Endif

If ValType(lAltera) == "L"
	ALTERA	:= lAltera
EndIf
If ValType(lInclui) == "L"
	INCLUI	:= lInclui
EndIf
cCadastro	:= cCad
aRotina	:= AClone(aRots)
Restarea(aArea)
aSize(aRots,0)
aSize(aArea,0)
aRots	:= Nil
aArea	:= Nil
Return(lRet)   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³14/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= {	{ STR0007  ,"AxPesqui"   ,0 , 1 , , .F. },;  //"Pesquisar"
			   		{ STR0008  ,"AxVisual"   ,0 , 2 , , .T. },;  //"Visualizar"
					{ STR0009  ,"AxInclui"   ,0 , 3 , , .T. },;  //"Incluir"
					{ STR0010  ,"AxAltera"   ,0 , 4 , , .T. }}   //"Alterar"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ³Tk271Historico ³ Autor ³ Vendas Clientes  ³ Data ³ 30/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Hist¢rico das liga‡oes do Cliente selecionado	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ SIGATMK      			 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271Historico(	nOpc		,lHabilita	,oFolderTmk	,oEnchTmk		,;
							oFolderTlv	,oEnchTlv	,cCodPagto	,cDescPagto		,;
							cCodTransp	,cTransp	,cCob		,cEnt			,;
							cCidadeC	,cCepC		,cUfC		,cBairroE		,;
							cBairroC	,cCidadeE	,cCepE		,cUfE			,;
							nLiquido	,nTxJuros	,nTxDescon	,nVlJur			,;
							aParcelas	,nEntrada	,nFinanciado,nNumParcelas	,;
							nValorCC	,cMotivo	,cEncerra	,oFolderTlc		,;
							oEnchTlc	,aColsTlv	,cCodAnt	,cCliAnt,cLock )
					
Local lTMKMHI	:= ExistBlock("TMKMHI")			//P.E. para TeleMarketing
Local lTMKVHI	:= ExistBlock("TMKVHI")			//P.E. para Televendas
Local nTipo		:= 0							//Variavel para controle da apresentacao do historico.
Local lRet		:= .F.							//Retorno da funcao
Local nFocus	:= GetFocus()

Default cLock := ""

If nFolder == 1 // TeleMarketing,Televendas ou Telecobranca

	If TkGetTipoAte() $ "145" //Telemarketing, Ambos ou TMK x TLV
		
		If lTMKMHI
			U_TMKMHI(	@nOpc,	@lHabilita,		@oFolderTmk,	@oEnchTmk)
			SetFocus(nFocus)
			Return(.T.)
		Endif

		nPProd := aPosicoes[3][2]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza as validacoes necessarias antes de executar o historico³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(M->UC_CHAVE)
			Help(" ",1,"SEM CLIENT" )
			Return(lRet)
		Endif
		
		DbSelectArea("SUC")
		DbSetOrder(2)
		If ! DbSeek(xFilial("SUC") + M->UC_ENTIDAD + M->UC_CHAVE)
			DbSetOrder(6)
			If DbSeek(xFilial("SUC") + M->UC_CODCONT)
				Aviso(STR0032, STR0044 ,{"OK"})     //"Atenção"    /"Será exibido apenas o histórico do Contato"
				nTipo := 1
			Else
				Help(" ",1,"SEMDADOS" )
				Return(lRet)
			Endif
		Endif	
		
		Tk272HTmk(	@nOpc		,@lHabilita	,@oFolderTmk	,@oEnchTmk	,;
					@cMotivo	,@cEncerra	,nTipo			, @cLock	)
		lRet := .T.				
					
	ElseIf (TkGetTipoAte() == "2") //Televendas

		If lTMKVHI
			lRet:=U_TMKVHI(@nOpc,	@lHabilita,	@oFolderTlv,	@oEnchTlv)
			If ValType(lRet) <> "L"
				lRet := .T.
			EndIf		
			If lRet
				SetFocus(nFocus)
				Return(lRet)
			EndIf
		Endif
		
		DbSelectArea( "SUA" )
		DbSetOrder(7)
		If ! DbSeek(xFilial("SUA") + M->UA_CLIENTE + M->UA_LOJA)
			Help(" ",1,"SEMDADOS" )
			Return(lRet)
		Endif
		
		Tk273HTlv(	@nOpc		 ,@lHabilita	,@oFolderTlv	,@oEnchTlv,;
					@cCodPagto	 ,@cDescPagto	,@cCodTransp	,@cTransp,;
					@cCob		 ,@cEnt		 	,@cCidadeC		,@cCepC,;
					@cUfC		 ,@cBairroE	 	,@cBairroC		,@cCidadeE,;
					@cCepE		 ,@cUfE		 	,@nLiquido		,@nTxJuros,;
					@nTxDescon	 ,@nVlJur		,@aParcelas		,@nEntrada,;
					@nFinanciado ,@nNumParcelas	,@nValorCC		,@aColsTlv,;
					cCodAnt		 ,@cCliAnt   , @cLock)
		lRet := .T.				
					
	ElseIf (TkGetTipoAte() == "3") //TeleCobranca
		
		DbSelectArea( "ACF" )
		DbSetOrder(2)
		If ! DbSeek(xFilial("ACF") + M->ACF_CLIENT + M->ACF_LOJA)
			Help(" ",1,"SEMDADOS" )
			Return(lRet)
		Endif
		
		Tk274HTLC(	@nOpc	,@lHabilita	,@oFolderTlc	,@oEnchTlc	)
		
		lRet := .T.				
	Endif
	
ElseIf nFolder == 2 // Televendas

	If lTMKVHI
		lRet:=U_TMKVHI(@nOpc)
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf		
		If lRet
			SetFocus(nFocus)
			Return(lRet)
		EndIf
	EndIf
	
	DbSelectarea( "SUA" )
	DbSetorder(7)
	If ! DbSeek(xFilial("SUA") + M->UA_CLIENTE +  M->UA_LOJA)
		Help(" ",1,"SEMDADOS" )
		Return(lRet)
	Endif
	
	Tk273HTlv(	@nOpc			,@lHabilita		,@oFolderTlv	,@oEnchTlv,;
				@cCodPagto		,@cDescPagto	,@cCodTransp	,@cTransp,;
				@cCob			,@cEnt			,@cCidadeC		,@cCepC,;
				@cUfC			,@cBairroE		,@cBairroC		,@cCidadeE,;
				@cCepE			,@cUfE			,@nLiquido		,@nTxJuros,;
				@nTxDescon		,@nVlJur		,@aParcelas		,@nEntrada,;
				@nFinanciado	,@nNumParcelas	,@nValorCC		,@aColsTlv,;
				@cCodAnt		,@cCliAnt, @cLock)
	lRet := .T.				
				
ElseIf nFolder == 3 // Telecobranca
	
	DbSelectarea( "ACF" )
	DbSetorder(2)
	If ! DbSeek(xFilial("ACF") + M->ACF_CLIENT + M->ACF_LOJA)
		Help(" ",1,"SEMDADOS" )
		Return(lRet)
	Endif
	
	Tk274HTLC(	@nOpc	,@lHabilita	,@oFolderTlc	,@oEnchTlc	)
	lRet := .T.				
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Workaround para forçar que se for feita alguma alteração        ³
//³em algum campo logo após sair da tela de histórico,             ³
//³o valid do campo seja executado. Em alguns casos, o campo       ³
//³era alterado mais não tinha sua validação e gatilhos executados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetFocus(nFocus)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Tk271SituaC ³ Autor ³ Vendas Clientes     ³ Data ³ 04/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Rotina para consultar a Situa‡„o Financeira do Cliente      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Call Center                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk271SituaC()

Local aArea		:= GetArea()						//Salva a area atual
Local aColsAnt  := aClone(aCols)					//Salva o ACOLS			
Local aHeadAnt	:= aClone(aHeader)					//Salva o AHEADER
Local nAnt		:= n 								//Salva a variavel N
Local lTMKVSI  	:= ExistBlock("TMKVSI")         	//P.E. do Televendas
Local lTMKMSI  	:= ExistBlock("TMKMSI")				//P.E. do Telemarketing		
Local cCliente  := ""								//Codigo do Cliente 
Local cLoja     := ""                               //Loja do Cliente
Local cAtend    := ""								//Codigo do Atendimento		
Local cDesc     := ""								//Descricao do cliente
Local cCodCont  := ""								//Codigo do Contato
Local cOperador := "" 								//Operador
Local lRet		:= .F.								//Retorno da funcao
Local cCadSave	:= cCadastro						//Salva o cCadastro
Local aRotSave	:= aClone(aRotina)                  //Salva o aRotinas

cCadastro	:= STR0023	//	"Consulta Posi‡ao Clientes"
aRotina		:= {	{ STR0007, "AxPesqui" , 0 , 1},;  //"Pesquisar"
					{ STR0008, "AxVisual", 0 , 2},;   //"Visualizar"
					{ STR0045 , "FC010CON" , 0 , 2},;  //"Consultar"
					{ STR0046 , "FC010IMP" , 0 , 4}}   //"Impressao"
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada								        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("Tk271Sit01") 
	lRet := ExecBlock( "Tk271Sit01", .F., .F.)  
	Return(lRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consulta financeira somente para clientes            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lProspect
	Help(" ",1,"NOPROSPECT" )
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o SF2 porque nao esta o MNU        			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF2")
	
If nFolder == 1 // TeleMarketing,Televendas ou Telecobranca

	If TkGetTipoAte() $ "145" // Telemarketing, Ambos e TMK x TLV

		cCliente   := SubStr(M->UC_CHAVE,1,TamSX3("A1_COD")[1])
		cLoja      := SubStr(M->UC_CHAVE,TamSX3("A1_COD")[1] + 1,TamSX3("A1_LOJA")[1])
		cAtend     := M->UC_CODIGO
		cDesc      := M->UC_DESCCHA
		cCodCont   := M->UC_CODCONT
		cOperador  := M->UC_OPERADO

		If lTMKMSI
			U_TMKMSI(cAtend,cCliente,cLoja,cDesc,cCodCont,cOperador)
			Return(.T.)
		Endif
		
	Elseif TkGetTipoAte() == "2" //Televendas
		cCliente   := M->UA_CLIENTE
		cLoja      := M->UA_LOJA
		cAtend     := M->UA_NUM
		cDesc      := M->UA_DESCCLI
		cCodCont   := M->UA_CODCONT
		cOperador  := M->UA_OPERADO
		
		If lTMKVSI
			U_TMKVSI(cAtend,cCliente,cLoja,cDesc,cCodCont,cOperador)
			Return(.T.)
		Endif
		
	ElseIf TkGetTipoAte() == "3" //Telecobranca
		cCliente   := M->ACF_CLIENT
		cLoja      := M->ACF_LOJA
		cAtend     := M->ACF_CODIGO
		cDesc      := M->ACF_DESC
		cCodCont   := M->ACF_CODCON
		cOperador  := M->ACF_OPERAD
	Endif
	
ElseIf nFolder == 2 // Televendas
	cCliente   := M->UA_CLIENTE
	cLoja      := M->UA_LOJA
	cAtend     := M->UA_NUM
	cDesc      := M->UA_DESCCLI
	cCodCont   := M->UA_CODCONT
	cOperador  := M->UA_OPERADO
	
	If lTMKVSI
		U_TMKVSI(cAtend,cCliente,cLoja,cDesc,cCodCont,cOperador)
		Return(.T.)
	Endif
	
ElseIf nFolder == 3 // Telecobranca
	cCliente   := M->ACF_CLIENT
	cLoja      := M->ACF_LOJA
	cAtend     := M->ACF_CODIGO
	cDesc      := M->ACF_DESC
	cCodCont   := M->ACF_CODCON
	cOperador  := M->ACF_OPERAD
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um cliente selecionado            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCliente)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif

DbSelectArea("SA1")
DbSetorder(1)
If DbSeek(xFilial("SA1") + cCliente + cLoja)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o Pergunte seja confirmado executa a consulta financeira.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If Pergunte("FIC010",.T.)
		Fc010Con("SA1",SA1->(Recno()),2)
		lRet := .T.
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o acols e aheader salvos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
aCols  := aClone(aColsAnt)
aHeader:= aClone(aHeadAnt)
n	   := nAnt

cCadastro	:= cCadSave 	
aRotina		:= aClone(aRotSave)
	
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ³Tk271AtuCont³ Autor ³ Vendas Clientes     ³ Data ³06/08/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Atualiza os dados do contato para inclusao e alteracao      ³±±
±±³          ³TMK:                                                        ³±±
±±³          ³     Se o contato estiver vazio - inclusao                  ³±±
±±³          ³     Se o contato estiver preenchido - alteracao 	          ³±±
±±³          ³                                                            ³±±
±±³          ³TLV e TLC:                                                  ³±±
±±³          ³     O cliente precisa estar preenchido                     ³±±
±±³          ³     Se o contato estiver vazio - inclusao                  ³±±
±±³          ³     Se o contato estiver preenchido - alteracao 	          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CALL CENTER - TOOLBAR 	   								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk271AtuCont()

Local aArea		:= {}								// Salva a area atual
Local cCad			:= cCadastro						// Salva o cCadastro atual
Local aRots		:= {}								// Salva o aRotinas atual
Local cContato	:= ""								// Codigo do Contato
Local lInclui 	:= INCLUI							// Armazena o status da VARIAVEL INCLUI para retornar o status na saida da funcao
Local nOpcA		:= 0 								// Retorno da Inclusao ou Alteracao (OK - CANCELA)
Local lRet			:= .T.								// Retorno do P.E. 
Local cEntidade	:= IIF(lProspect,"SUS","SA1")	// Alias da entidade
Local cCliente	:= ""								// Codigo do Cliente
Local cLoja		:= ""								// Codigo da Loja
Local cTipoAte	:= ""								// Tipo de atendimento
Local lNormatiz	:= .F.								// Valida se o cad. contatos utiliza as tabelas AGA e AGB
Local cFldNCont	:= ""
Local cFldNCont2	:= ""
Local cFldNCont3	:= ""

// Se o Operador executa as rotinas: TODAS e TMK x TLV e nao esta no 1 folder - O cliente e Obrigatorio
If (cTipoAte $ "45") .AND. nFolder <> 1 .AND. ( Empty(cCliente) .AND. Empty(cLoja) )
	Help(" ",1,"SEM CLIENT")
	lRet := .F.
	Return(lRet)
Endif

aArea	  	:= GetArea()
aRots   	:= aClone(aRotina)
lNormatiz	:= A70Normatizado()
cTipoAte	:= TkGetTipoAte()

aRotina	:= {{STR0007, "AxPesqui", 0, 1},; // "Pesquisar"
       	    {STR0008, "AxVisual", 0, 2},; // "Visualizar"
       	    {STR0009, "AxInclui", 0, 3},; // "Incluir"
       	    {STR0010, "AxAltera", 0, 4}}  // "Alterar"

If nFolder == 1
	If (cTipoAte $ "145")  //Telemarketing, Ambos ou TMK x TLV
		cContato := M->UC_CODCONT
		cFldNCont := "M->UC_DESCNT"
		cFldNCont2 := If(cTipoAte $ "45", "M->UA_DESCNT",  "")
		cFldNCont3 := If(cTipoAte == "4", "M->ACF_DESCNT", "")
		
	ElseIf cTipoAte == "2" // Televendas
		// Preenche o cliente/loja para montar o Relacionamento depois
		cCliente := M->UA_CLIENTE
		cLoja    := M->UA_LOJA
		cContato := M->UA_CODCONT
		cFldNCont := "M->UA_DESCNT"

	ElseIf cTipoAte == "3" // Telecobranca
		// Preenche o cliente/loja para montar o Relacionamento depois
		cCliente := M->ACF_CLIENT
		cLoja    := M->ACF_LOJA
		cContato := M->ACF_CODCON
		cFldNCont := "M->ACF_DESCNT"
	Endif

ElseIf nFolder == 2  // Televendas
	// Preenche o cliente/loja para montar o Relacionamento depois
	cCliente := M->UA_CLIENTE
	cLoja    := M->UA_LOJA
	cContato := M->UA_CODCONT
	cFldNCont := "M->UA_DESCNT"
	cFldNCont2 := If(cTipoAte $ "45", "M->UC_DESCNT",  "")
	cFldNCont3 := If(cTipoAte == "4", "M->ACF_DESCNT", "")

ElseIf nFolder == 3  // Telecobranca
	// Preenche o cliente/loja para montar o Relacionamento depois
	cCliente := M->ACF_CLIENT
	cLoja    := M->ACF_LOJA
	cContato := M->ACF_CODCON
	cFldNCont := "M->ACF_DESCNT"
	If cTipoAte == "4"
		cFldNCont2 := "M->UC_DESCNT"
		cFldNCont3 := "M->UA_DESCNT"
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o contato estiver preenchido executa a alteracao caso contrario executa a inclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU5")
DbSetOrder(1)
If DbSeek(xFilial("SU5") + cContato)
	
	If _lTMKALTA5 .And. !lNormatiz
		lRet := U_TMKALTA5(SU5->(Recno()))
		// Se o retorno for .F. nao prossegue com o cancelamento
		If (ValType(lRet) <> "L")
			lRet := .F.
		Endif
	Endif
	
	If lRet
		INCLUI 	  := .F.
		cCadastro := STR0012   //"Alteracao de Contatos"

		If lNormatiz
			INCLUI := .F.
			ALTERA := .T.
			nOpcA := A70Manut("SU5",SU5->(RecNo()),4)

			If nOpcA == 1
				If &(cFldNCont) <> SU5->U5_CONTAT
					&(cFldNCont) := SU5->U5_CONTAT
				EndIf
				If ! Empty(cFldNCont2) .AND. ! Empty(&(cFldNCont2)) .AND. &(cFldNCont2) <> SU5->U5_CONTAT
					&(cFldNCont2) := SU5->U5_CONTAT
				EndIf
				If ! Empty(cFldNCont3) .AND. ! Empty(&(cFldNCont3)) .AND. &(cFldNCont3) <> SU5->U5_CONTAT
					&(cFldNCont3) := SU5->U5_CONTAT
				EndIf
				cContHist	:= SU5->U5_CONTAT
				oContHist:Refresh()
			EndIf

			cCadastro	:= cCad
			aRotina	:= AClone(aRots)
			RestArea(aArea)
			aSize(aRots,0)
			aSize(aArea,0)
			aRots	:= Nil
			aArea	:= Nil
			Return( nOpcA )
		Else
			nOpcA := AxAltera("SU5",SU5->(RecNo()),4)		
		EndIf	
		
		If nOpcA == 1	// OK
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa o P.E.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If _lTMKALTU5
				ExecBlock( "TMKALTU5", .F., .F. )
			Endif
		Endif
		
		INCLUI := lInclui
	Endif		

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui o Contato e ja monta o relacionamento com o Cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCadastro	:= STR0013   //"Inclusao de Contatos"

	If lNormatiz
		nOpcA := A70Manut("SU5",1,3)
		cCadastro	:= cCad
		aRotina  := AClone(aRots)
		RestArea(aArea)
		aSize(aRots,0)
		aSize(aArea,0)
		aRots	:= Nil
		aArea	:= Nil
		Return( nOpcA )
	Else
		nOpcA := AxInclui("SU5",1,3)
	EndIf	
	
	If nOpcA == 1	// OK
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa o P.E.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _lTMKINCU5
			ExecBlock( "TMKINCU5", .F., .F. )
		Endif
	Endif
	
	If (nOpcA == 1) .AND. !Empty(cCliente) .AND. !Empty(cLoja)
		DbSelectArea("AC8")
		RecLock("AC8",.T.)
		Replace AC8_FILIAL With xFilial("AC8")
		Replace AC8_FILENT With xFilial(cEntidade)
		Replace AC8_ENTIDA With cEntidade
		Replace AC8_CODENT With cCliente + cLoja
		Replace AC8_CODCON With SU5->U5_CODCONT
		MsUnLock()
		DbCommit()
	Endif
Endif

cCadastro	:= cCad
aRotina	:= AClone(aRots)
RestArea(aArea)
aSize(aRots,0)
aSize(aArea,0)
aRots	:= Nil
aArea	:= Nil
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ³Tk271Grava ³ Autor ³ Vendas Clientes      ³ Data ³01/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Executa a gravacao dos atendimentos 						  ³±±
±±³          ³Telemarketing / Televendas / Telecobranca					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TMKA271											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß   
*/                       
Function Tk271Grava(nOpc			,oFolderTmk		,nTimeSeg		,nTimeMin		,;
					oCrono			,cCrono			,oEnchTmk		,cMotivo		,;
					cEncerra		,oFolderTlv		,oEnchTlv		,cCodPagto		,;
					cDescPagto		,cCodTransp		,cTransp		,cCob			,;
					cEnt			,cCidadeC		,cCepC			,cUfC			,; 	
					cBairroE		,cBairroC		,cCidadeE		,cCepE			,;
					cUfE			,nLiquido		,nTxJuros		,nTxDescon		,;
					nVlJur			,aParcelas		,nEntrada		,nFinanciado	,;
					nNumParcelas	,nValorCC		,lHabilita  	,oFolderTlc		,;
					oEnchTlc		,aColsTmk	    ,aColsTlv   	,oDlg			,;
					cCodAnt     	,aParScript 	,l380			,lMsg			,;
					aSx3Sua			,cAgenda		,nValnFat		,aSx3SUC		,;
					aItens			,oCodPagto		,oDescPagto		,oCodTransp		,;
					oTransp			,oCob			,oEnt			,oCidadeC		,;
					oUfC			,oBairroE		,oCepC			,oCidadeE		,;
					oBairroC		,cCidadeE		,oCepE			,oUfE			,;
					oLiquido		,nTxJuros		,oTxJuros		,oTxDescon		,;
					oParcelas		,oEntrada		,oFinanciado	,oNumParcelas	,;
					lTipo9			,oValNFat		,aSX3ACF		,cCliAnt		,;
					lSigaCRD		,lPriContato	,cLock			,cDlgTitle		) 
					
Local lRet 		 	:= .T.             						// Retorno da Funcao
Local dFechamento	:= CTOD("  /  /  ")    					// Data de fechamento somente para TELEMARKETING
Local cTipoCti 	 	:= TkPosto(TkOperador(),"U0_TIPOCTI")	// Tipo de Hardware do grupo de atendimento do Operador
Local nI 		 	:= 0									// Contador	
Local nTotal 	 	:= 0 									// Totalizador
Local lExibeMsg	 	:= .F.									// Flag para indicar se exibira mensagem ao realizar a limpeza da tela. Utilizado no ponto de entrada TMKLIMPA.
Local lTK271BOK	 	:=  ExistBlock("TK271BOK") 				// Ponto de Entrada no botao Ok da toolbar
Local lTk271FIMGR 	:= ExistBlock("TK271FIMGR")				// Ponto de Entrada no Fim da Gravacao  para complemento dos dados gravados
Local lTCPG			:= SuperGetMV("MV_TMKTCPG",.F.,.F.)		// Parametro do SX6 que controla ou não a abertura da tela de condição de pagamento ao confirmar o atendimento.
Local lTk271END	 	:= ExistBlock("TK271END")		 		// Ponto de Entrada no Fim da Gravacao  quando selecionado o botao OK
Local lResp		 	:= Len(aParScript) > 0					// Indica se o operador executou o script para atendimento atual
Local lTLVReg        := .F.  								//  Validacao da regra de negocios
Local cCodigo        := M->UC_CODIGO
Local cChave		   := ""

Default lPriContato := .F.									// Usado para controlar a habilitação ou não do botão cancelar na tela de atendimento, ver TMKA271 variável lPriContato para mais informações
Default cLock    	:= ""
Default cDlgTitle 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criado o ponto de entrada TK271BOK na chamada do OK da Toolbar da    ³
//³ tela de atendimento. Se o retorno for negativo, nao chama a funcao   ³
//³ de gravacao e nao sai da tela.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK271BOK
	lRet := U_TK271BOK( nOpc, lResp )
	If ValType( lRet ) <> "L"
		lRet := .T.
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a validacao foi negativa nao efetua a gravacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRet
		Return(lRet)
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o ATENDIMENTO  = TELEVENDAS ou = AMBOS ou = TMK x TLV e o folder for o segundo (TLV) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (TkGetTipoAte() == "2") .OR. (TkGetTipoAte() $ "45" .AND. nFolder == 2) 
	If __lNewGetD == NIL
	   aProps := ClassDataArr(oEnchTlv)
	   __lNewGetD := (Ascan(aProps,{|x| Upper(x[1]) == "NCTRL" }) > 0 )
	Endif
Endif

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nunca permite o foco no UA_Cliente p/ nao validar o campo na montagem da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !__lNewGetD
	oCrono:SetFocus()
Endif	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente faz as gravacaoes do atendimento se for a rotina de INCLUSAO ou ALTERACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	// Se for VISUALIZACAO nao grava nada e fecha a tela
	Case nOpc == 2							 
		lMsg := .F. // Nao exibe a mensagem de confirmacao de saida da tela
		oDlg:End()
	
	// Se for ALTERACAO ou INCLUSAO valida e grava
	Case (nOpc == 3) .OR. (nOpc == 4)		
		
		If nFolder == 1	//Telemarketing, Televendas ou Telecobranca
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o TIPO DO ATENDIMENTO = TMK ou = TODOS ou = TMK x TLV ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TkGetTipoAte() $ "145"		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega a data do ultimo fechamento da rotina de TMK	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dFechamento := SuperGetMv("MV_TMKFECHA")
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se data atual for <= a data do fechamento nao grava  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If dDatabase <= dFechamento
					Help(" ",1,"FECHAMENTO")
					lRet :=.F.
					Return( lRet )
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valido se os campos da ENCHOICE estao preenchidos    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Obrigatorio(oEnchTmk:aGets,oEnchTmk:aTela) .AND. Tk272GetTmk() .AND. oGetTmk:TudoOK()
		
					oGetTmk:oBrowse:SetFocus()
					lRet := TK272GrvTmk(nOpc		,@oFolderTmk	,@cMotivo	,@cEncerra,;
										@lHabilita	,aColsTmk		,l380		,aSx3SUC, aParScript)
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TkGrvSUV(__cUserId, "TMK0")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza protocolo de atendimento ANS - RN395 - SIGAPLS       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If GetNewPar("MV_PLRN395","0") == "1"
			  			P773TmkCon()
					EndIf
					
				Else
					lRet := .F.
					Return( lRet )					
				Endif
			Endif
		   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o TIPO DO ATENDIMENTO = TLV ou FOLDER e de TLV			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (TkGetTipoAte() == "2") .OR. (nFolder == 2)
		
		  If CtoD(SuperGetMv("MV_NT2006I",.F.,"05/04/2021")) <= dDataBase //Valida a vigencia da NT2020-006
			If SUA->(ColumnPos("UA_INDPRES")) > 0 //Existe o campo indicador de presença (Campo inserido durante a Versão 12.1.27)
				If !( M->UA_INDPRES $ "12349" ) .AND. !Empty(M->UA_CODA1U)
					Help(" ",1,"TK273CODA1U02",,STR0069,1,0)	//"Não é permitido informar o Código do Intermediador para a TeleVenda conforme o campo Presença do Comprador (AU_INDPRES)."
					lRet := .F.
				EndIf
			EndIf
		  EndIf

		  If lRet .And. ( Tk273GetOK() .And. ( Type( 'oGetTLV' ) == 'O' .And. oGetTLV:TudoOk() ) ) .AND. Obrigatorio(oEnchTlv:aGets,oEnchTlv:aTela) .AND. If(Len(ReadVar()) > 0, SafeEval({||.T.}) ,.T. )
				If ( ( Val(M->UA_OPER) == FATURAMENTO ) 								.OR.;
				     ( Val(M->UA_OPER) == ORCAMENTO .AND. !Empty(M->UA_CONDPG) ) )	.AND.;
				     lHabilita
					
					If lTCPG
						If (M->UA_CONDPG <> cCodPagto)
							lRet:=Tk273Pagamento(	nOpc			,lHabilita		,@aItens		,@cCodPagto		,;
								  					oCodPagto		,@cDescPagto	,@oDescPagto	,@cCodTransp	,;
													@oCodTransp		,@cTransp		,@oTransp		,@cCob			,;
													@oCob			,@cEnt			,@oEnt			,@cCidadeC		,;
													@oCidadeC		,@cCepC			,@oCepC			,@cUfC			,;
													@oUfC			,@cBairroE		,@oBairroE		,@cBairroC		,;
													@oBairroC		,@cCidadeE		,@oCidadeE		,@cCepE			,;
													@oCepE			,@cUfE			,@oUfE			,@nLiquido		,;
													@oLiquido		,@nTxJuros		,@oTxJuros		,@nTxDescon		,;
													@oTxDescon		,@aParcelas		,@oParcelas		,@nEntrada		,;
													@oEntrada		,@nFinanciado	,@oFinanciado	,@nNumParcelas	,;
													@oNumParcelas	,@nVlJur		,@cCodAnt 		,@lTipo9		,;
													@oValNFat		,@nValNFat		,@cCliAnt		,lSigaCRD       ,;
												    @lTLVReg)
						EndIf
					Else
						lRet:=Tk273Pagamento(	nOpc			,lHabilita		,@aItens		,@cCodPagto		,;
												oCodPagto		,@cDescPagto	,@oDescPagto	,@cCodTransp	,;
												@oCodTransp		,@cTransp		,@oTransp		,@cCob			,;
												@oCob			,@cEnt			,@oEnt			,@cCidadeC		,;
												@oCidadeC		,@cCepC			,@oCepC			,@cUfC			,;
												@oUfC			,@cBairroE		,@oBairroE		,@cBairroC		,;
												@oBairroC		,@cCidadeE		,@oCidadeE		,@cCepE			,;
												@oCepE			,@cUfE			,@oUfE			,@nLiquido		,;
												@oLiquido		,@nTxJuros		,@oTxJuros		,@nTxDescon		,;
												@oTxDescon		,@aParcelas		,@oParcelas		,@nEntrada		,;
												@oEntrada		,@nFinanciado	,@oFinanciado	,@nNumParcelas	,;
												@oNumParcelas	,@nVlJur		,@cCodAnt 		,@lTipo9		,;
												@oValNFat		,@nValNFat		,@cCliAnt		,lSigaCRD       ,;
												@lTLVReg)
					EndIf
				Elseif ( Val(M->UA_OPER) == ATENDIMENTO .AND. !Empty(M->UA_CONDPG) )	.AND.;
						 lHabilita
					cCodPagto := M->UA_CONDPG
				EndIf   
			    
				oGetTlv:oBrowse:SetFocus()
				If (lRet)
					lRet:=	Tk273GrvTel(@nOpc		,@oFolderTlv	,@cCodPagto		,@cDescPagto,;
						 				@cCodTransp	,@cTransp		,@cCob			,@cEnt,;
										@cCidadeC	,@cCepC			,@cUfC			,@cBairroE,;
										@cBairroC	,@cCidadeE		,@cCepE			,@cUfE,;
										@nLiquido	,@nTxJuros		,@nTxDescon		,nVlJur,;
										@aParcelas	,@nEntrada		,@nFinanciado	,@nNumParcelas,;
										@nValorCC	,@lHabilita		,aColsTlv		,l380,;
										aSx3Sua		,@nValNFat		,cCliAnt		,lSigaCRD,;
										lTLVReg)
										
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TkGrvSUV(__cUserId, "TLV0")
				Endif
			Else	
				CursorArrow()	
				lRet := .F.
		   		Return( lRet )
			Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o TIPO DO ATENDIMENTO = TLC ou FOLDER e de TLC			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (TkGetTipoAte() == "3") .OR. (nFolder == 3)
		
			If Obrigatorio(oEnchTlc:aGets,oEnchTlc:aTela)
		
			   oGetTlc:oBrowse:SetFocus()
			   lRet := TK274GrvTlc(	nOpc	,@oFolderTlc	,@lHabilita	,l380,;
			   						cAgenda	,aSX3ACF)
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TkGrvSUV(__cUserId, "TLC0")

			Else	
				lRet := .F.
		   		Return( lRet )
			Endif
			
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   		//³P.E apos a gravacao dos dados da Agenda³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lTk271FIMGR
			ExecBlock("TK271FIMGR" , .F. , .F. ,{nFolder})            	
 		EndIf 
		
		          	
		
		If lRet
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa a gravacao das campanhas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !IsInCallStack("TMKA380")
				TkGrvCamp(aParScript)
				Tk272VeMail(cCodigo)
			EndIf
		
			// Volta o tipo de cursor
			CursorArrow()	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada no final da gravacao, ao dar o OK na tela de atendimento e apos a gravacao da campanha caso exista³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTk271END
				ExecBlock("TK271END" , .F. , .F.)
	 		EndIf

			Tk271GrvACH()
	 		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for ALTERACAO e foi executado a partir da AGENDA DO OPERADOR fecha a tela para ³
			//³que o usuario nao tente fazer novas inclusoes					                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
			If FunName() == "TMKA280"
		   		lMsg := .F.		// Nao exibe a mensagem de confirmacao de saida da tela
				oDlg:End()      //Fecha a tela do atendimento
		
			Else
				// Verifica se eh televenda e libera os atendimento bloqueados.
				If ((TkGetTipoAte() == "2") .OR. (nFolder == 2)) .And. !Empty(cLock)
					UnLockByName(cLock,.T.,FWModeAccess("SUA",3) == "E",.T.)
			   		cLock := ""
				ElseIf ((TkGetTipoAte() == "1") .OR. (nFolder == 1)) .And. !Empty(cLock)
					UnLockByName(cLock,.T.,FWModeAccess("SUC",3) == "E",.T.)
			   		cLock := ""
				EndIf
				
				TkLimpa(@oCrono		,@cCrono		,@nTimeSeg		,@nTimeMin,;
		 				@nOpc		,@oFolderTmk	,@oEnchTmk		,@lHabilita,;
						@oFolderTlv	,@oEnchTlv		,@nLiquido		,@cCob,;
						@cEnt		,@cCidadeC		,@cCepC			,@cUfC,;
						@cBairroc	,@cCidadeE		,@cCepE			,@cUfE,;
						@cBairroE	,@nEntrada		,@aParcelas		,@nFinanciado,;
						@cTransp	,@cCodPagto		,@cDescPagto	,@nTxJuros,;
						@nVlJur		,@nNumParcelas	,@cCodTransp	,@oFolderTlc,;
						@oEnchTlc	,@cCodAnt		,aSx3SUA		,aSx3SUC,;
						lExibeMsg	,@cCliAnt)
				
				If !Empty(cDlgTitle) .And. nOpc == 3	//Altera o tipo de operação na descrição da janela do atendimento
					If Type("ALTERA") == "L"
						ALTERA := .F.
					EndIf
					oDlg:cCaption := cDlgTitle + " - " + Upper(STR0009)	//## INCLUIR
					oDlg:Refresh()
				EndIf
			
			Endif				
		Endif
Endcase     
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houve a gravação e é o primeiro atendimento, seta a ³
//³variável lPriContato para .F.                          ³
//³Essa variável é utilizada para que se possa desabilitar³
//³o cancelamento da janela de atendimento quando é o     ³
//³primeiro atendimento que está sendo gravado e o        ³
//³atendimento foi efetuado a partir da agenda do operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lRet .AND. lPriContato)
	lPriContato := .F.
EndIf
		
MaReleTabPrc()//Limpa array da tabela de preço


//----------------------------------------------------------
// Controle de concorrência TMK
//----------------------------------------------------------

If TkGetTipoAte() $ "14" .Or. nFolder == 1 //Telemarketing ou todos
	cChave := cEmpAnt + xFilial( "SUC" ) + cCodigo
	Tk271UnLock( cChave )
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Tk271LegScri³ Autor ³ Vendas Clientes   	 ³ Data ³18/07/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Legendas da utilizacao do script dinamico                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³SIGATMK                                     	 	      	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk271LegScri(cStatus)

Local oEncerrada := LoadBitmap( GetResources(), "BR_VERDE" )		//Imagem para encerramento
Local oPendente  := LoadBitmap( GetResources(), "BR_VERMELHO" )		//Imagem para pendencia
Local oPlanejada := LoadBitmap( GetResources(), "BR_AZUL" )			//Imagem para planejada
Local oBmp 		 := LoadBitmap( GetResources(), "BR_BRANCO" )		//Imagem de retorno

Do case
	Case VAL(cStatus) == PLANEJADA
		  oBmp := oPlanejada

	Case VAL(cStatus) == PENDENTE
		  oBmp := oPendente

	Case VAL(cStatus) == ENCERRADA
		  oBmp := oEncerrada
Endcase

Return(oBmp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Tk271Tel  ³ Autor ³ Vendas Clientes       ³ Data ³ 17/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria uma tela com todos os telefones do contato selecionado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Call Center                                                ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³05/08/05³811   ³BOPS 83779 - Exibir o telefone do contato   ³±±
±±³          ³        ³      ³com uma picture mais adequada.              ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk271Tel(cCodCont,cChave,cEntidade)     

Local oDlgTel												// Tela					
Local oLbx1													// Objeto com os telefones
Local aTel   := {}											// Array com os telefones
Local nTipo  := 1											// Tipo selecionado

Local cOperEst  := TkPosto(TkOperador(),"U0_OPEREST")		// Operadora dentro do estado
Local cOperFora := TkPosto(TkOperador(),"U0_OPEFEST")		// Operadora fora do estado
Local cEst	    := SuperGetMv("MV_ESTADO")						// Estado de onde se esta fazendo a ligacao (ATENDIMENTO ATIVO)
Local cTmkDDI   := SuperGetMv("MV_TMKDDI")						// Codigo que PRECEDE a discagem DDI - 00
Local cTmkDDD   := SuperGetMv("MV_TMKDDD")						// Codigo que PRECEDE a discagem DDD - 0
Local cDDIPais  := SuperGetMv("MV_TMKPAIS")						// Pais de origem
Local cEstTel   := ""										// Estado PARA onde se esta fazendo a ligacao
Local cOperadora:= ""										// Codigo para usar a discagem por uma OPERADORA
Local lDDD      := .F.  									// Flag para indicar se ira utilizar o DDD
Local lDDI      := .F.     						   			// Flag para indicar se ira utilizar o DDI
Local lOperadora:= .F.										// Flag para indicar se ira utilizar o codigo do Operadora
Local cPicture	:= ""  										// Picture completa do telefone
Local cPictOper	:= "999" 									// Picture da Operadora
Local cPictDDD 	:= "(99)"									// Picture do DDD       
Local cPictTel 	:= "9999-9999"								// Picture do telefone 
Local lObfTel	:= ( FATPDIsObfuscate("U5_TEL",,.T.) .Or. FATPDIsObfuscate("U5_FCOM1",,.T.) .Or. FATPDIsObfuscate("U5_CELULAR",,.T.) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o estado onde esta Localizado o contato ou a entidade.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cChave) .AND. cEntidade == "SU5"
	cEstTel:= TkDadosContato(cCodCont,7)
	
ElseIf !Empty(cChave)
	cEstTel:= TkEntidade(cEntidade,cChave,4)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe uma tela com os telefones do contato para ser selecionado³
//³para a geracao de ligacao pendente.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU5")
DbSetOrder(1)
If DbSeek( xFilial("SU5") + cCodCont)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o pais de origem e o pais das ligacoes 					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SU5->U5_CODPAIS)
		If (ALLTRIM(SU5->U5_CODPAIS) <> cDDIPais)
			cOperadora := cTmkDDI + cOperFora
			lDDI := .T.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se estao no mesmo estado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cEst == cEstTel)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SU5->U5_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
			lOperadora := .T.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIF  ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SU5->U5_MUN)) .AND. !Empty(SM0->M0_CIDENT)
			lOperadora := .T.
		Endif
	Else
		lOperadora := .T.
	Endif
	
	If Empty(cOperadora)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual sera a operadora utilizada para realizar o DDD.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cEstTel)
			If lOperadora
				If (cEst == cEstTel) .AND. !Empty(SU5->U5_DDD)
					cOperadora:= cTmkDDD + cOperEst
					lDDD := .T.
				ElseIf (cEst <> cEstTel) .AND. !Empty(SU5->U5_DDD)
					cOperadora:= cTmkDDD + cOperFora
					lDDD := .T.
				Endif
			Endif
		Endif
	Endif

	If !Empty(cOperadora)
        If !Empty(cOperEst) .OR. !Empty(cOperFora)
	        cPicture:= "@R " + cPictOper + IIF(lDDD,cPictDDD,"") + cPictTel
	    Else
		    cPicture:= "@R 9" + IIF(lDDD,cPictDDD,"") + cPictTel	     
		Endif
		Aadd(aTel,{STR0024,Transform(cOperadora + IIF(lDDI,ALLTRIM(SU5->U5_CODPAIS),"") + IIF(lDDD,ALLTRIM(SU5->U5_DDD),"") + SU5->U5_FONE		,cPicture)})
		Aadd(aTel,{STR0025,Transform(cOperadora + IIF(lDDI,ALLTRIM(SU5->U5_CODPAIS),"") + IIF(lDDD,ALLTRIM(SU5->U5_DDD),"") + SU5->U5_CELULAR	,cPicture)})
		Aadd(aTel,{STR0026,Transform(cOperadora + IIF(lDDI,ALLTRIM(SU5->U5_CODPAIS),"") + IIF(lDDD,ALLTRIM(SU5->U5_DDD),"") + SU5->U5_FAX		,cPicture)})
		Aadd(aTel,{STR0027,Transform(cOperadora + IIF(lDDI,ALLTRIM(SU5->U5_CODPAIS),"") + IIF(lDDD,ALLTRIM(SU5->U5_DDD),"") + SU5->U5_FCOM1		,cPicture)})
		Aadd(aTel,{STR0028,Transform(cOperadora + IIF(lDDI,ALLTRIM(SU5->U5_CODPAIS),"") + IIF(lDDD,ALLTRIM(SU5->U5_DDD),"") + SU5->U5_FCOM2		,cPicture)})
	Else
		Aadd(aTel,{STR0024,SU5->U5_FONE})
		Aadd(aTel,{STR0025,SU5->U5_CELULAR})
		Aadd(aTel,{STR0026,SU5->U5_FAX})
		Aadd(aTel,{STR0027,SU5->U5_FCOM1})
		Aadd(aTel,{STR0028,SU5->U5_FCOM2})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe a tela de escolha do telefone.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgTel FROM 15,2 TO 200,347 TITLE STR0029 PIXEL //"Telefones do Contato"
	    @ 002,002 TO 075,165 LABEL "" OF oDlgTel PIXEL
		@ 005,004 LISTBOX oLbx1 FIELDS HEADER STR0030,STR0031 SIZE 160,65 OF oDlgTel PIXEL ON CHANGE (nTipo:= oLbx1:nAt) //"Tipo" "Numero"
		oLbx1:SetArray(aTel)
		oLbx1:bLine := {||{	aTel[oLbx1:nAt, 1],;
							aTel[oLbx1:nAt, 2] }}
		If FATPDActive() .And. FTPDUse(.T.)					
			oLbx1:aObfuscatedCols := {.F.,lObfTel}   
		Endif

		DEFINE SBUTTON FROM 080,140 TYPE 1 ACTION oDlgTel:End()	ENABLE OF oDlgTel
	
	FATPDLogUser("TK271TEL")
	ACTIVATE MSDIALOG oDlgTel CENTERED

Else
	Help(" ",1,"SEM CONTAT")
Endif

Return(StrZero(nTipo,1))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271Legenda ºAutor  ³ Vendas Clientes º Data ³  23/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legendas dos browses de Telemarketing e Televendas          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271Legenda()

Local lTK271LEG	:= ExistBlock("TK271LEG")				// P.E. Para substituir as legendas do sistema padrao
Local aCores 	:= {}									// Array Default com as definicoes de cores
Local cPasta	:= TkGetTipoAte()						// Parametro com a pasta que sera inicializada

If lTK271LEG
	aCores := U_TK271LEG(cPasta)
	If ValType(aCores) <> "A"
		aCores := {}	
	Endif
Endif	

Do Case

	Case (TkGetTipoAte() == "1") //Telemarketing                
        If Len(aCores) == 0
			aCores := {	{"BR_AZUL"		,STR0034 },;					//"Atendimento Planejado"
						{"BR_VERMELHO" 	,STR0035 },;					//"Atendimento Pendente"
						{"BR_VERDE"		,STR0036 },;    				//"Atendimento Encerrado"
						{"BR_PRETO"		,STR0043 },; 					//"Atendimento Cancelado"
						{"BR_CINZA"		,STR0065 }} 					//"Compartilhamento"
		Endif
		BrwLegenda(cCadastro,"Legenda"	,aCores )

	Case (TkGetTipoAte() == "2") //Televendas
        If Len(aCores) == 0
			aCores := {	{"BR_MARRON"  	,STR0001 },;					//"Atendimento"
						{"BR_AZUL"		,STR0037 },;      				//"Orçamento"
						{"BR_VERDE"    	,STR0038 },;					//"Faturamento"
						{"BR_VERMELHO" 	,STR0039 },;					//"NF.Emitida"
						{"BR_PRETO"    	,STR0042 }}						//"Cancelado"
		Endif
		BrwLegenda(cCadastro,"Legenda"	,aCores )

	Case (TkGetTipoAte() == "3") //Telecobranca
        If Len(aCores) == 0
			aCores := {	{"BR_AZUL"  	,STR0001},;						//"Atendimento"
						{"BR_VERDE"		,STR0040},;						//"Cobrança"
						{"BR_VERMELHO"  ,STR0041},;						//"Encerrado"
						{"BR_CINZA" 	,STR0042 }}						//"Cancelado"	
		Endif
		BrwLegenda(cCadastro, STR0047	,aCores )   //"Legenda"
EndCase

Return(.T.)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271AskCp ºAutor ³Vendas Clientes     º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta uma dialog para capturar dados de contato e codigo da º±±
±±º          ³campanha a ser utilizado no script.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cEntidade - Alias da entidade em uso (ACH, SUS, SA1)        º±±
±±º          ³cCliente  - Codigo do cliente (ou suspect ou prospect)      º±±
±±º          ³cLoja     - Loja do cliente                                 º±±
±±º          ³cCodCamp  - Codigo da Campanha (passar por referencia)      º±±
±±º          ³cContato  - Codigo do Contato (passar por referencia)       º±±
±±º          ³cOperacao - Tipo de operacao (1:Ativo ou 2:Receptivo)       º±±
±±º          ³lMostraTela-Se Exibira atela de Conta e Campanha            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet - Indica se obteve sucesso na captura de todos os dadosº±±
±±º          ³necessarios.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271AskCp(	cEntidade	, cCliente	, cLoja		, cCodCamp	,;
							cContato	, cOperacao , lMosTraTela , oContato ,oCampanhas)

Local lRet			:= .T.		// Variavel de retorno
Local aContatos		:= {}		// Array com os contatos da entidade informada
Local aContTmp		:= {}		// Array temporario de contatos da entidade informada
Local aCampanhas	:= {}		// Array com as campanhas disponíveis
Local nX			:= 0		// Variavel auxiliar de loop
Local aPDFields		:= {"U5_CONTAT"}

FATPDLoad(Nil,Nil,aPDFields)

If lMosTraTela = nil
   lMosTraTela:=.T.
Endif

// Identifica todos os contatos da entidade
AC8->( dbSetOrder(2) )	//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
SU5->( dbSetOrder(1) )	//U5_FILIAL+U5_CODCONT

AC8->( dbSeek( xFilial("AC8")+cEntidade+xFilial(cEntidade)+cCliente+cLoja ) )
While AC8->( !Eof() .AND. AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+RTrim(AC8_CODENT)) == ;
						  xFilial("AC8")+cEntidade+xFilial(cEntidade)+cCliente+cLoja)
						  
	SU5->( dbSeek( xFilial("SU5")+AC8->AC8_CODCON ) )
	aAdd( aContatos, AC8->AC8_CODCON + " " + FATPDObfuscate(SU5->U5_CONTAT,"U5_CONTAT") )
	
	AC8->( dbSkip() )
End

If Len( aContatos ) == 0
	Help( " ", 1, "SEM CONTAT" )	//Nenhum contato cadastrado para esta entidade
	cContato := ""	// Zera o codigo de contato  
	Return .F.
EndIf

If Len(aContatos) > 1
	aAdd( aContTmp, STR0048 )	//"< selecione o contato >"
	For nX := 1 to Len(aContatos)
		AAdd(aContTmp,aContatos[nX])
	Next nX
	aContatos	:= aClone(aContTmp)
	aContTmp	:= {}
EndIf

// Identifica as campanhas disponíveis
SUO->( dbSetOrder(1) )	//UO_FILIAL+UO_CODCAMP
SUO->( dbSeek( xFilial("SUO") ) )
While SUO->( !Eof() .AND. UO_FILIAL == xFilial("SUO") )

	If ( dDatabase >= SUO->UO_DTINI .OR. Empty( SUO->UO_DTINI ) ) .AND.;
	   ( dDatabase <= SUO->UO_DTFIM .OR. Empty( SUO->UO_DTFIM ) )
		aAdd( aCampanhas, { .F., SUO->UO_CODCAMP, SUO->UO_DESC, SUO->UO_TIPO, SUO->UO_DTINI, SUO->UO_DTFIM } )
	EndIf

	SUO->(DbSkip())
End

If Empty( aCampanhas )
	aAdd( aCampanhas, { .F., "", "", "", "", "" } )
EndIf

If lMosTraTela
   lRet := Tk271DlCmp( aContatos, aCampanhas, @cContato, @cCodCamp, @cOperacao )
Else
  cCodCamp	:= oCampanhas:AARRAY[oCampanhas:NAT][2]
  nCampanha	:= aScan( aCampanhas, {|x| x[2]==cCodCamp } ) 
  cCodCamp	:= aCampanhas[nCampanha,2]
  cOperacao	:= aCampanhas[nCampanha,4]
  cContato	:= Left( oContato:AITEMS[oContato:NAT], 6 )						 				 	
Endif   

FATPDUnload()

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271DlCmpºAutor  ³Vendas Clientes     º Data ³  03/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a dialog para captacao dos dados de contato e campanhaº±±
±±º          ³para execucao do script.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - TMKA271A                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271DlCmp(	aContatos	, aCampanhas	, cContato	, cCampanha	,;
							cOperacao	)

Local lRet			:= .F.		// Variavel de retorno
Local nCampanha		:= 0		// Ponteiro da campanha selecionada
Local oDlgParam					// Objeto dialog
Local oGrpContato				// Objeto moldura superior
Local oGrpCamp					// Objeto moldura inferior
Local oContato					// Combobox para selecao do contato
Local oCampanhas				// ListBox com as campanhas
Local oBtOk						// Botao Ok
Local oBtCancelar				// Botao Cancelar
Local oLbOk						// Imagem do botao confirmar
Local oLbNo						// Imagem do botao cancelar

oLbNo	:= LoadBitmap( GetResources(), "LBNO" )
oLbOk	:= LoadBitmap( GetResources(), "LBOK" )

// Monta a tela para seleção
oDlgParam := MSDIALOG():Create()
oDlgParam:cName := "oDlgParam"
oDlgParam:cCaption := STR0049	//"Dados para execução do script"
oDlgParam:nLeft := 0
oDlgParam:nTop := 0
oDlgParam:nWidth := 490
oDlgParam:nHeight := 345
oDlgParam:lShowHint := .F.
oDlgParam:lCentered := .T.

oGrpContato := TGROUP():Create(oDlgParam)
oGrpContato:cName := "oGrpContato"
oGrpContato:cCaption := STR0050	//"Contato"
oGrpContato:nLeft := 4
oGrpContato:nTop := 4
oGrpContato:nWidth := 480
oGrpContato:nHeight := 48
oGrpContato:lShowHint := .F.
oGrpContato:lReadOnly := .F.
oGrpContato:Align := 0
oGrpContato:lVisibleControl := .T.

oGrpCamp := TGROUP():Create(oDlgParam)
oGrpCamp:cName := "oGrpCamp"
oGrpCamp:cCaption := STR0051	//"Campanha"
oGrpCamp:nLeft := 4
oGrpCamp:nTop := 57
oGrpCamp:nWidth := 480
oGrpCamp:nHeight := 225
oGrpCamp:lShowHint := .F.
oGrpCamp:lReadOnly := .F.
oGrpCamp:Align := 0
oGrpCamp:lVisibleControl := .T.

oContato := TCOMBOBOX():Create(oDlgParam)
oContato:cName := "oContato"
oContato:cCaption := ""
oContato:nLeft := 12
oContato:nTop := 24
oContato:nWidth := 354
oContato:nHeight := 21
oContato:lShowHint := .F.
oContato:lReadOnly := .F.
oContato:Align := 0
oContato:bSetGet := {|u| If(PCount()>0,cContato:=u,cContato) }
oContato:lVisibleControl := .T.
oContato:aItems := aContatos
oContato:nAt := 1

//{ ACI_CODIGO, ACI_DATA, ACI_CODCON, U5_CONTAT, ACI_CODCAM, UO_DESC, ACI_CODSCR, UZ_DESC, ACI_ROTINA, ACI_ATEND }
oCampanhas := TWBrowse():New( 77/2/*<nRow>*/, 12/2/*<nCol>*/, 465/2/*<nWidth>*/, 174/2/*<nHeigth>*/, /*<Flds>*/,;
								{ " ", STR0052, STR0053, STR0054, STR0055, STR0056 }/*<aHeaders>*/,;	//"Código", "Descrição", "Tipo", "Início", "Fim"
							{ 8, 30, 90, 30, 30 }/*<aColSizes>*/, oDlgParam/*<oDlg>*/,,,,,,,,,,,,,,.T. )
oCampanhas:bLDblClick	:=	{|| Tk271MkCmp( @oCampanhas, @aCampanhas ) }
oCampanhas:SetArray( aCampanhas )
oCampanhas:bLine	:=	{|| {If( oCampanhas:aArray[oCampanhas:nAt,1], oLbOk, oLbNo ),;											// Marcado/Desmarcado
							 oCampanhas:aArray[oCampanhas:nAt,2],;																// Codigo
							 oCampanhas:aArray[oCampanhas:nAt,3],;																// Descricao
							 If( oCampanhas:aArray[oCampanhas:nAt,4] == "1", STR0057,;											// "Receptivo"
							 If( oCampanhas:aArray[oCampanhas:nAt,4] == "2", STR0058, "" )),;									// "Ativo"
							 oCampanhas:aArray[oCampanhas:nAt,5],;																// Data inicio
							 oCampanhas:aArray[oCampanhas:nAt,6] } }															// Data fim
oCampanhas:Refresh()
								
oBtOk := TBUTTON():Create(oDlgParam)
oBtOk:cName := "oBtOk"
oBtOk:cCaption := STR0059	//"Ok"
oBtOk:nLeft := 373
oBtOk:nTop := 288
oBtOk:nWidth := 52
oBtOk:nHeight := 22
oBtOk:lShowHint := .F.
oBtOk:lReadOnly := .F.
oBtOk:lVisibleControl := .T.
oBtOk:bAction := {|| If( Tk271VldBt( oContato, aCampanhas ),;
					 	( lRet := .T.,;
						  nCampanha	:= aScan( aCampanhas, {|x| x[1] } ),;
						  cCampanha	:= aCampanhas[nCampanha,2],;
						  cOperacao	:= aCampanhas[nCampanha,4],;
						  cContato	:= Left( aContatos[oContato:nAt], 6 ),;						 				 	
						  oDlgParam:End() ), nil ) }

oBtCancelar := TBUTTON():Create(oDlgParam)
oBtCancelar:cName := "oBtCancelar"
oBtCancelar:cCaption := STR0060	//"Cancelar"
oBtCancelar:nLeft := 430
oBtCancelar:nTop := 288
oBtCancelar:nWidth := 52
oBtCancelar:nHeight := 22
oBtCancelar:lShowHint := .F.
oBtCancelar:lReadOnly := .F.
oBtCancelar:lVisibleControl := .T.
oBtCancelar:bAction := {|| oDlgParam:End() }

FATPDLogUser("Tk271DlCmp")
oDlgParam:Activate()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271MkCmpºAutor  ³Vendas Clientes     º Data ³  03/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa a marcacao de itens na ListBox de Campanhas.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - TMKA271A - AskCampan                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271MkCmp( oCampanhas, aCampanhas )

Local lMarked	:= aCampanhas[oCampanhas:nAt, 1]		// Status atual da linha clicada
Local nLin		:= oCampanhas:nAt						// Linha atual da listbox

//Desmarca todas as linhas do array
aEval( aCampanhas, {|x| x[1] := .F. } )

//Inverte a marcacao da linha posicionada na list (se nao for vazia)
If !Empty( aCampanhas[oCampanhas:nAt,2] )
	aCampanhas[oCampanhas:nAt, 1] := !lMarked
EndIf

//Executa refresh no objeto
oCampanhas:Refresh()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271VldBtºAutor  ³Vendas Clientes     º Data ³  04/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o botao Ok dos parametros da execucao do script.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - TMKA271A - AskCampan                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271VldBt( oContato, aCampanhas )

Local lRet := .F.

If (Len(oContato:aItems) > 1 .AND. oContato:nAt <= 1) .OR. (Len(oContato:aItems) == 1 .AND.  oContato:nAt < 1 )
	MsgStop( STR0061 )	//"Selecione um contato para prosseguir."
ElseIf aScan( aCampanhas, {|x| x[1] } ) == 0
	MsgStop( STR0062 )	//"Selecione uma campanha para prosseguir."
Else
	lRet := .T.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271GrvACºAutor  ³Vendas Clientes     º Data ³  04/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o campo ACH->ACH_CODTMK com o codigo do atendiment.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - TMKA271A - AskCampan                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk271GrvACH()              

Local nTamProspe := TamSX3("AD1_PROSPE")[1]
Local nTamLojPro := TamSX3("AD1_LOJPRO")[1]
Local cCliSus := Alltrim(SubStr(SUC->UC_CHAVE,1,nTamProspe))
Local cLojSus := Alltrim(SubStr(SUC->UC_CHAVE,(nTamProspe + 1),nTamLojPro))

If !Empty(SUD->UD_SOLUCAO) .AND. ACH->(FieldPos("ACH_CODTMK")) > 0 .AND. SUQ->(FieldPos("UQ_INTWOR")) > 0

	If SUC->UC_ENTIDAD == "ACH"
	
		DbSelectArea("SUQ")
		DbSetOrder(1)
		If DbSeek(xFilial("SUQ")+SUD->UD_SOLUCAO)
			
			If SUQ->UQ_INTWOR == "1"
			
				DbSelectArea("ACH")
				DbSetOrder(1)
				If DbSeek(xFilial("ACH") + cCliSus)
					While !EOF() .AND. cCliSus + cLojSus == ACH->ACH_CODIGO + ACH->ACH_LOJA
						
						RecLock("ACH",.F.)
						Replace ACH->ACH_CODTMK With SUC->UC_CODIGO
						MsUnLock()
	
	                    ACH->(DbSkip())
	                    Loop
					End			
				EndIf  
			EndIf
		EndIf

	EndIf

EndIf
	
Return Nil

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
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

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
