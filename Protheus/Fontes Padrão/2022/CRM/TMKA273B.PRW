#INCLUDE "TMKA273B.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMKDEF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkStatus   ³ Autor ³Vendas Clientes    	 ³ Data ³21/07/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o status do pedido selecionado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas - SX3                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function Tk273Status(cCampo)

Local cDesc := " "			//Retorno do status

Do case
	case AllTrim(cCampo) == "NF." .AND. AllTrim(SUA->UA_OPER) == "1"
  		 cDesc := STR0003 //"NF.Emitida" 
  		 
	case AllTrim(cCampo) == "RM." .AND. AllTrim(SUA->UA_OPER) == "1"
  		 cDesc := STR0002 //"Merc.Enviada" 

	case AllTrim(cCampo) == "SUP" .AND. AllTrim(SUA->UA_OPER) == "1"
  		 cDesc := STR0004 //"Ped. Bloq." 

	case AllTrim(cCampo) == "SUP" .AND. AllTrim(SUA->UA_OPER) == "3"  // Atendimento
  		 cDesc := STR0001 //"Atendimento"

	case AllTrim(cCampo) == "CAN"
  		 cDesc := STR0005 //"Cancelado " 

	case AllTrim(SUA->UA_STATUS) == "LIB"
  		 cDesc := STR0006 //"Liberado  " 

	other
		 cDesc := STR0007 //"Or‡amento" 
Endcase

Return(cDesc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271NumTlv ³ Autor ³Vendas Clientes      ³ Data ³ 03/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega as informacoes do numero do atendimento digitado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas - SX3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273NumTlv(	nOpc		,cNumTlv		,lHabilita		,oFolderTlv,;
						oEnchTlv	,cCodPagto		,cDescPagto		,cCodTransp,;
						cTransp		,cCob			,cEnt			,cCidadeC,;
						cCepC		,cUfC			,cBairroE		,cBairroC,;
						cCidadeE	,cCepE			,cUfE			,nLiquido,;
						nTxJuros	,nTxDescon		,nVlJur			,aParcelas,;
						nEntrada	,nFinanciado	,nNumParcelas	,nValorCC,;
						aColsTlv	,cCodAnt		,cCliAnt		,cLock)

Local aArea   	:= GetArea()						// Salva a area atual
Local aSaSUA   	:= {}                        	// Salvar a area para posterior restauracao
Local cTmkaLoj	:= SuperGetMv("MV_TMKALOJ")  	// Parametro que altera os ORCAMENTOS NO SIGALOJA gerados pelo Televendas
Local cAltPed 	:= SuperGetMV("MV_ALTPED")   	// Parametro que permite a edição de pedido já faturado
Local cFilSUA 	:= xFilial("SUA")
Local cFilSC6		:= ""
Local cFilSC9		:= ""
Local cNumAux 	:= ""								// Armazena o UA_NUM quando nao encontra no SUA
Local cTipo   	:= ""								// Armazena o Tipo do Contato (US_TIPO)
Local cAliasEnt	:= ""
Local cNaturez	:= ""
Local lTLVENT 	:= ExistBlock("TLVENT") 		// P.E. executado no fim da funcao
Local lRet		:= .F.								// Retorno da funcao
Local aPDFields := {"U7_NOME","A1_NOME","U5_CONTAT"}
Local lCliEntreg:= SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0

Default cLock := ""

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se encontrar o atendimento informado carrega na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUA")
DbSetOrder(1)
If DbSeek( cFilSUA + cNumTlv)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o aParcelas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParcelas:={}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a rotina estava incluindo e agora passou a ser uma alteracao solta o SXE ³
	//³Atualiza o status dos semaforos para evitar o empilhamento do ultimo folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se foi usado o SX8 e nao foi feita nenhuma inclusao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TkGetTipoAte() == "4"// todos os atendimentos
			DbSelectArea("ACF")
			RollBackSX8() // rollback do ultimo folder

			DbSelectArea("SUA")
			RollBackSX8() // rollback do primeiro folder.

			DbSelectArea("SUC")
			RollBackSX8() // rollback do penultimo folder
		ElseIf TkGetTipoAte() == "2"  //TLV
			DbSelectArea("SUA")
			RollBackSX8()
		Endif

		nOpc		:= 4   // Alteracao
		INCLUI		:= .F.
		ALTERA 		:= .T.

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a opcao gravada foi FATURAMENTO o usuario nao pode mudar a opcao ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SUA->UA_OPER == "1"
		lAltTpOper := .F.
	Else
		lAltTpOper := .T.
	Endif

	lProspect := SUA->UA_PROSPEC

	If lProspect
		cTipo := Posicione("SUS",1,xFilial("SUS") + SUA->UA_CLIENTE + SUA->UA_LOJA,"US_TIPO")
		cAliasEnt	:= 'SUS'
	Else
		cTipo := Posicione("SA1",1,xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,"A1_TIPO")
		cAliasEnt	:= 'SA1'
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Habilita os dados para depois validar o status   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 2 .And. Empty(cLock) .And. !lHabilita
		Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
	Else
		Tk271HabObj(.T.,@lHabilita,@oEnchTlv)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa os dados do cliente na FUNCAO FISCAL  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nOpc <> 2 )
		MaFisIni(IIF(lCliEntreg .And. !lProspect,SUA->UA_CLIENT,SUA->UA_CLIENTE),;	// 1-Codigo Cliente/Fornecedor
				 IIF(lCliEntreg .And. !lProspect,SUA->UA_LOJAENT,SUA->UA_LOJA),;	// 2-Loja do Cliente/Fornecedor
		         "C",;				// 3-C:Cliente , F:Fornecedor
		         "N",;				// 4-Tipo da NF
		         cTipo,;				// 5-Tipo do Cliente/Fornecedor
		         Nil,;				// 6-Relacao de Impostos que suportados no arquivo
		         Nil,;				// 7-Tipo de complemento
		         Nil,;				// 8-Permite Incluir Impostos no Rodape .T./.F.
		         Nil,;				// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		         Nil,;				// 10-Nome da rotina que esta utilizando a funcao
		         Nil,;				// 11-Tipo de documento
		         Nil,;				// 12-Especie do documento
		         IIF(lProspect,SUA->UA_CLIENTE+SUA->UA_LOJA,""))// 13- Codigo e Loja do Prospect

		cNaturez := Tk273DpNat(SUA->UA_CLIENTE, SUA->UA_LOJA)
		If !Empty(cNaturez)
			MaFisAlt("NF_NATUREZA",cNaturez)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for um PROSPECT atualiza o estado de DESTINO e valida o campo de inscricao estadual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lProspect .AND. ( nOpc <> 2 ) )
		DbSelectArea("SUS")
		DbSetOrder(1)
		If DbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA)
			MaFisAlt("NF_UFDEST",SUS->US_EST)
		Endif
	Endif

	Do Case
		Case SUA->UA_STATUS == "NF."           // MV_OPFAT = "S"
			If  ! Empty(SUA->UA_NUMSC5)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\¿
				//³Verifica se o pedido já foi faturado, se o parametro MV_ALTPED estiver como "N",³
				//³o pedido não podera ser alterado, caso contrario o sistema verificara cada item.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\Ù
				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
					If !Empty(SC5->C5_NOTA)					// Verifica se o pedido foi faturado totalmente
						Aviso(STR0008,STR0012,{STR0009})	// "Atenção!" "A Nota fiscal referente a este pedido já foi emitida!" "Continuar"
						If cAltPed == "N"					// Se o parâmeto MV_ALTPED == "N", o pedido não pode ser alterado
							Help(" ",1,"A410PEDFAT")
							Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
						EndIf
					EndIf
				EndIf
			Else
				//Empty(SUA->UA_NUMSC5) - identifica geração de venda pelo Venda Direta
				DbSelectArea("SF2")
				DbSetOrder(1)
				If DbSeek(xFilial("SC5")+SUA->UA_DOC+SUA->UA_SERIE+SUA->UA_CLIENTE+SUA->UA_LOJA)
					Help(" ",1,"VENDA_LOJA")      //Aviso(STR0008,"A Nota fiscal referente a este pedido já foi emitida atraves da Venda Direta!",{STR0009})	// "Atenção!" "A Nota fiscal referente a este pedido já foi emitida!" "Continuar"
					Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
				EndIf
			EndIf

		Case SUA->UA_STATUS == "RM."
			Help(" ",1,"RM.ENVIADA")
			Tk271HabObj(.F.,@lHabilita,@oEnchTlv)

		Case SUA->UA_STATUS == "CAN"           // Nao habilita nada
			Help(" ",1,"PED.CAN")
			Tk271HabObj(.F.,@lHabilita,@oEnchTlv)

		Case SUA->UA_STATUS == "SUP" .Or. SUA->UA_STATUS == "LIB"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o Operador tem acesso (Senhas) para alterar o ³
			//³pedido.                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (VAL(SUA->UA_OPER) == FATURAMENTO) .AND. !Empty(SUA->UA_NUMSC5)
				If !ChkPsw(20)
					Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se esse pedido foi liberado pelo SIGAFAT    ³
			//³sao verificados os campos C6_QTDEMP + C6_QTDENT > 0  ³
			//³nao altera mais o atendimento                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SUA->UA_NUMSC5)
				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Antes de alterar o pedido verifico se nao foi liberado ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(SC5->C5_NOTA)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se teve algum item com NF emitida parcial     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cFilSC6	:= xFilial("SC6")
						cFilSC9	:= xFilial("SC9")
						DbSelectArea("SC6")
						DbSetOrder(1)
						If SC6->(DbSeek(cFilSC6+SUA->UA_NUMSC5))
							While SC6->(! Eof()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == SUA->UA_NUMSC5

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Impede a alteracao de Pedido com Servico de WMS jah executado 		  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
								If	IntDL(SC6->C6_PRODUTO)
									SC9->(dbSetOrder(2)) //-- C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
									If	SC9->(DbSeek(cFilSC9+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC5->C5_NUM+SC6->C6_ITEM, .F.))
										If	Empty(SC9->C9_NFISCAL) .And. SC9->C9_BLWMS == '05' .And. !(SC6->C6_QTDLIB==SC9->C9_QTDLIB) //-- Liberado para WMS (Servico jah executado)
											Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
											Aviso('SigaWMS',STR0015+AllTrim(SC6->C6_ITEM)+STR0016+" ( "+AllTrim(Transform(SC9->C9_QTDLIB, PesqPict('SC9', 'C9_QTDLIB')))+" "+STR0017, {'Ok'}) //'O Item '###" nao pode ser alterado porque possui servicos de WMS pendentes. Estorne estes servicos para proceder com a alteracao."###"na 1a UM ) nao pode ser alterada."
											Exit
										EndIf
									EndIf
								EndIf

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Visualiza o atendimento mas, nao pode alterar nada³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !Empty(SC6->C6_NOTA)
									Aviso(STR0008,STR0013,{STR0009}) // "Atenção!" "A Nota fiscal referente a este pedido já foi emitida parcialmente!" "Continuar"
									Exit
								Elseif (SC6->C6_QTDEMP + SC6->C6_QTDENT) > 0
									Aviso(STR0008,STR0014,{STR0009}) // "Atenção!" "Este pedido já foi liberado!" "Continuar"
									Exit
								Endif
								SC6->(DbSkip())
							EndDo
						Endif
					Endif
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³O pedido foi apagado pelo SIGAFAT - na base da 609 - Na 710 quem apaga o pedido e o SIGATMK ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Help(" ",1,"PED.CAN")
					Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se existe integracao com o SIGALOJA         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cTmkaLoj == "S") .AND. (Val(SUA->UA_OPER) == ORCAMENTO)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se encontrou o orcamento e ele ja foi recebido sera emitido um HELP e ³
				//³impede a alteracao desse atendimento porque ele ja foi fechado no LOJA³ 
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SL1")
				DbSetOrder(1)
				If DbSeek(xFilial("SL1") + SUA->UA_NUMSL1)
					If!Empty(SL1->L1_DOC)
						Help(" ",1,"VENDA_LOJA")
						Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tranca o orçamento para edição pelo SIGALOJA.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nOpc <> 2
							If !TkLibLoja("C")
								Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
							EndIf
						EndIf
					Endif
				EndIf
			Endif

	EndCase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a enchoice de Telemarketing.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SUA")
	While (!SX3->( Eof()) .AND. SX3->X3_ARQUIVO == "SUA")
		If X3USO(SX3->X3_USADO)
			cCampo := ALLTRIM(SX3->X3_CAMPO)
			If (X3_CONTEXT # "V")
				M->&(cCampo) := SUA->&(cCampo)
			ElseIf (X3_CONTEXT == "V")
				M->&(cCampo) :=  CriaVar(cCampo)
			EndIf
		EndIf
		DbSkip()
	EndDo
	If Empty(M->UA_TIPOCLI)
		M->UA_TIPOCLI := cTipo
	EndIf

	If nOpc == 4
		If (SUA->(FieldPos("UA_TIPOCLI")) > 0)
			Tk273RodImposto("NF_TPCLIFOR",SUA->UA_TIPOCLI)
		EndIf
		If lCliEntreg
			MaFisAlt("NF_CODCLIFOR",IIf(!lProspect,M->UA_CLIENT,M->UA_CLIENTE))
			MaFisAlt("NF_LOJA",IIf(!lProspect,M->UA_LOJAENT, M->UA_LOJA))
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava a condição de pagamento atual para que se for alterada³
	//³aconteça a montagem das parcelas novamente.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodAnt := SUA->UA_CONDPG

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡ao da GetDados - Folder 01  *** Televendas 		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK271Config("SUB","UB_NUM",nOpc,NIL,cNumTlv,NIL,)
	oGetTlv:oBrowse:Refresh(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena o ACOLS anterior para recaculo posterior do ESTOQUE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsTlv := aClone(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Refresh no RODAPE	  										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValores[MERCADORIA]	:= SUA->UA_VALMERC
	aValores[ACRESCIMO]		:= SUA->UA_ACRESCI

	aValores[DESCONTO]		:= SUA->UA_DESCONT
	Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])

	aValores[DESPESA]	 	:= SUA->UA_DESPESA
	Tk273RodImposto("NF_DESPESA",aValores[DESPESA])

	aValores[FRETE]			:= SUA->UA_FRETE
	Tk273RodImposto("NF_FRETE",aValores[FRETE])

	aValores[MERCADORIA]	:= SUA->UA_VALBRUT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existir BONUS deleta o item para indicar que e um BONUS    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk273Bonus(2)

	nEntrada 	:= SUA->UA_ENTRADA
	nFinanciado := SUA->UA_FINANC
	nTxJuros	:= SUA->UA_JUROS
	nTxDescon	:= SUA->UA_TXDESC

	nNumParcelas:= SUA->UA_PARCELA
	cCodPagto	:= SUA->UA_CONDPG
	cCodTransp	:= SUA->UA_TRANSP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona a Condicao de Pagamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCodPagto)
		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek(xFilial("SE4")+cCodPagto)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza nome da transportadora³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCodTransp)
		cTransp		:= Posicione("SA4",1,xFilial("SA4")+M->UA_TRANSP,"A4_NOME")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizo o Endre‡o de entrega e de cobran‡a                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCob    	:=SUA->UA_ENDCOB
	cEnt    	:=SUA->UA_ENDENT
	cCidadeC	:=SUA->UA_MUNC
	cCepC   	:=SUA->UA_CEPC
	cUfC    	:=SUA->UA_ESTC
	cBairroC	:=SUA->UA_BAIRROC
	cCidadeE	:=SUA->UA_MUNE
	cCepE   	:=SUA->UA_CEPE
	cUfE    	:=SUA->UA_ESTE
	cBairroE	:=SUA->UA_BAIRROE
	cCliAnt		:=SUA->UA_CLIENTE + SUA->UA_LOJA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o operador mude de or‡amento p/ faturamento obrigo ele a indicar a forma de pagto escolhida ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUA")

    //Salva a area anterior para evitar o desposicionamento no SUA.
	aSaSUA:= GetArea()

	DbSetOrder(7)   //Data da ultima liga‡ao
	If DbSeek(cFilSUA + M->UA_CLIENTE + M->UA_LOJA)
		FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
		While !EOF() .And. cFilSUA ==  SUA->UA_FILIAL .And. M->UA_CLIENTE == SUA->UA_CLIENTE .And. M->UA_LOJA == SUA->UA_LOJA
			If lProspect == SUA->UA_PROSPEC
				cLigacao	:= DTOC(CTOD("01/01/45")-UA_DIASDAT)+" - "+Substr(SUA->UA_INICIO,1,5)
				cOperador   := FATPDObfuscate( Posicione("SU7",1,xFilial("SU7") + SUA->UA_OPERADO,"U7_NOME"),"U7_NOME")
				If !Empty(SUA->UA_PROXLIG)
					cProximo:= DTOC(SUA->UA_PROXLIG) + " - " + SUA->UA_HRPEND + " - " + cOperador
				Endif
			
				cOperacao := Tk273Status(SUA->UA_STATUS)
				cNomeHist := FATPDObfuscate(TkEntidade(cAliasEnt,SUA->UA_CLIENTE+M->UA_LOJA,1),"A1_NOME")
				cContHist:=  FATPDObfuscate(TkDadosContato(M->UA_CODCONT,0),"U5_CONTAT")

				oLigacao :Refresh()
				oOperador:Refresh()
				oOperacao:Refresh()
				oProximo :Refresh()
				oNomeHist:Refresh()
				oContHist:Refresh()
				Exit
			EndIf
			SUA->(DbSkip())
		EndDo
		FATPDUnload()
	Endif

	RestArea(aSaSUA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reposiciona o SUA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aArea)

	lRet := .T.
Else
	cNumAux   := GetSxeNum("SUA","UA_NUM")
	M->UA_NUM := cNumAux
	RollBackSxe()

	If cNumTlv > cNumAux
		Help( " ",1,"FORA_SEQ")
	EndIf

	lRet := .T.
Endif

If lTLVENT
	U_TLVENT(M->UA_NUM,@lHabilita,@oGetTlv,@oEnchTlv)
Endif

oFolderTlv:Refresh()
oGetTlv:oBrowse:Refresh()
Eval(bRefresh)
CursorArrow()
Return(lRet)

//--------------------------------------- Funcoes nao chamadas no sistema------------------------------------------------------

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273Track  ºAutor  ³Vendas Clientes   º Data ³  07/31/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a funcao de Tracker para rastrear o atendimento no  º±±
±±º          ³SIGAFAT                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Somente Televendas                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function TK273Track()

Local aEnt     := {}
Local cNumTlv  := M->UA_NUM
Local nPosItem := GDFieldPos( "UB_ITEM" )
Local nLoop    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := 1 To Len( aCols )
	AAdd( aEnt, { "SUB", cNumTlv + aCols[ nLoop, nPosItem ] } )
Next nLoop

MaTrkShow( aEnt )

Return(.T.)
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271TabValid³ Autor ³ Vendas Clientes      ³ Data ³ 10.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona a primeira tabela valida para o produto            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271TabValid(ExpC1) 										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Produto	                            			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMKA271													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273TabValid(cProduto)
Local aSaveArea := GetArea()
Local cCodTab   := ""

If !Empty(cProduto)
	DbSelectArea("DA1")
	DbSetOrder(2)
	If DbSeek (xFilial("DA1") + cProduto)
		While (!EOF()) .AND. (xFilial("DA1") == DA1->DA1_FILIAL) .AND. (DA1->DA1_CODPRO == cProduto)
			If MaVldTabPrc(DA1->DA1_CODTAB,"","")
				cCodTab := DA1->DA1_CODTAB
				Exit
			Endif
			DbSkip()
		End
	Endif
	
Endif

RestArea(aSaveArea)

Return(cCodTab)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK271LOTCTL ³Autor  ³Vendas Clientes      ³ Data ³23.03.00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Lote de Controle digitado pelo usuario             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Logico                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK273LotCTL()

Local aArea		:= GetArea()
Local aAreaF4	:= SF4->(GetArea())
Local nPProduto := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_PRODUTO"})
Local nPLocal	:= Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_LOCAL"})
Local nPLoteCtl := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_LOTE"})
Local nPNumLote := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_SUBLOTE"})
Local nPDtValid := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_DTVALID"})
Local nPTes		:= Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_TES"})
Local nPQuant	:= Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_QUANT"})
Local cProduto	:= aCols[n][nPProduto]
Local cLocal	:= aCols[n][nPLocal]
Local cNumLote	:= aCols[n][nPNumLote]
Local cLoteCtl  := aCols[n][nPLoteCtl]
Local nQuant    := aCols[n][nPQuant]
Local lRetorna  := .T.
Local nSaldo	:= 0
Local lGrade 	:= SuperGetMv("MV_GRADE")

If Empty(cLoteCtl) .AND. Empty(cNumLote)
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Movimenta Estoque                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF4")
DbSetOrder(1)
If ( DbSeek(xFilial("SF4")+aCols[n][nPTes]) .AND. SF4->F4_ESTOQUE=="N" )
	Help(" ",1,"A410TEEST")
	lRetorna := .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Produto eh uma referencia                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ( lRetorna .AND. lGrade )
	If ( MatGrdPrrf(cProduto) )
		Help(" ",1,"A410NGRADE")
		lRetorna := .F.
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Produto possui rastreabilidade                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRetorna .AND. !Rastro(cProduto) )
	Help( " ", 1, "NAORASTRO" )
	aCols[n,nPNumLote]  := CriaVar( "UB_SUBLOTE" )
	aCols[n,nPLoteCtl]	:= CriaVar( "UB_LOTE" )
	aCols[n,nPDtValid]	:= CriaVar( "UB_DTVALID" )
	aCols[n,nPQuant]	:= CriaVar( "UB_QUANT" )
	lRetorna := .F.
Else
	If ( lRetorna )
		nSaldo := SldAtuEst(cProduto,cLocal,nQuant,cLoteCtl)
		If ( nQuant > nSaldo )
			Help(" ",1,"A440ACILOT")
			lRetorna  := .F.
		Else
			If !Empty(cLoteCtl)
				aCols[n,nPDtValid]	:= SB8->B8_DTVALID
			Endif
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Entrada da Rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaF4)
RestArea(aArea)
Return(lRetorna)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK271Lote ³ Autor ³ Vendas Clientes      ³ Data ³ 23.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a Quantidade digitada no Lote.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMK010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TK273Lote()

Local cLote 
Local cProduto
Local cLocal
Local nSaldo
Local cAlias 	:= Alias()
Local cTes
Local nPosProd 	:= 0
Local lGrade   	:= SuperGetMv("MV_GRADE")
Local cLoteCtl
Local nX		:= 0 			// Contador

nPosProd := Ascan(aHeader,{ |x| ALLTRIM(x[2])=="UB_PRODUTO"})
If !Rastro(aCols[n,nPosProd])
	Help(" ",1,"A440NAORAS")
	For nX = 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == "UB_SUBLOTE"
			aCols[n][nX] 	:=CriaVar("UB_SUBLOTE")
			M->UB_SUBLOTE	:=CriaVar("UB_SUBLOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_LOTE"
			aCols[n][nX]	:=CriaVar("UB_LOTE")
			M->UB_LOTE		:=CriaVar("UB_LOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_DTVALID"
			aCols[n][nX]	:=CriaVar("UB_DTVALID")
			M->UB_DTVALID	:=CriaVar("UB_DTVALID")
		Endif
	Next nX
	Return .T.
Endif

cLote := &(ReadVar())

If Empty(cLote)
	Return .T.
Endif

For nX=1 to Len(aHeader)
	If Trim(aHeader[nX][2]) == "UB_PRODUTO"
		cProduto := aCols[n][nX]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a grade esta ativa, e se o produto digitado e'   ³
		//³ uma referencia                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGrade
			lRet := MatGrdPrrf(@cProduto)
			If lRet
				cProduto := ALLTRIM(cProduto)
			Endif
		Endif
	Elseif Trim(aHeader[nX][2]) == "UB_LOCAL"
		cLocal := aCols[n][nX]
	Elseif Trim(aHeader[nX][2]) == "UB_QUANT"
		nQuant := aCols[n][nX]
	Elseif Trim(aHeader[nX][2]) == "UB_TES"
		cTes := aCols[n][nX]
	Elseif Trim(aHeader[nX][2]) == "UB_LOTE"
		cLoteCtl := aCols[n][nX]
	End
Next nX

DbSelectArea("SF4")
DbSeek(xFilial("SF4")+cTes)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o arquivo a ser pesquisado                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SB8")
DbSetOrder(1)
DbSeek(xFilial("SB8")+cProduto+cLocal)
If !Found()
	Help(" ",1,"A440NAOLOT")
	For nX = 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == "UB_SUBLOTE"
			aCols[n][nX] :=CriaVar("UB_SUBLOTE")
			M->UB_SUBLOTE:=CriaVar("UB_SUBLOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_LOTE"
			aCols[n][nX] :=CriaVar("UB_LOTE")
			M->UB_LOTE   :=CriaVar("UB_LOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_DTVALID"
			aCols[n][nX] :=CriaVar("UB_DTVALID")
			M->UB_DTVALID:=CriaVar("UB_DTVALID")
		Endif
	Next nX
	DbSelectArea(cAlias)
	Return .T.
Else
	If SF4->F4_ESTOQUE == "S"
		DbSelectArea("SB8")
		
		If Rastro( cProduto, "S" )
			DbSetOrder( 2 )
			DbSeek(xFilial("SB8")+cLote+If(!Empty(cLoteCtl),cLoteCtl,""))
		Else
			DbSetOrder( 3 )
			cChave := xFilial( "SB8" ) + cProduto + cLocal + cLoteCtl
			DbSeek( cChave, .f. )
		Endif
		
		If Found()
			
			If Rastro( cProduto, "S" )
				nSaldo := B8_SALDO - ( B8_EMPENHO + QtdLote(SB8->B8_PRODUTO,SB8->B8_LOCAL,SB8->B8_NUMLOTE) )
			Else
				
				nSaldo := SaldoLote( cProduto, cLocal, cLoteCtl )
				nSaldo -= QtdLote(SB8->B8_PRODUTO,SB8->B8_LOCAL,,,SB8->B8_LOTECTL)
				
			Endif
			
			If nSaldo > 0
				For nX := 1 To Len(aHeader)
					If nSaldo < nQuant
						If Trim(aHeader[nX][2]) == "UB_QUANT"
							aCols[n][nX] := nSaldo
						ElseIf Trim(aHeader[nX][2]) == "UB_SUBLOTE"
							aCols[n][nX] := cLote
							M->UB_SUBLOTE := cLote
						ElseIf Trim(aHeader[nx][2]) == "UB_LOTE"
							aCols[n][nx] :=SB8->B8_LOTECTL
							M->UB_LOTE   :=SB8->B8_LOTECTL
						ElseIf Trim(aHeader[nx][2]) == "UB_DTVALID"
							aCols[n][nx] :=SB8->B8_DTVALID
							M->UB_DTVALID:=SB8->B8_DTVALID
						Endif
					Endif
				Next nX
			Else
				Help(" ",1,"A440LOTVAZ")
				DbSelectArea(cAlias)
				Return .F.
			Endif
		Else
			Help(" ",1,"A440NAOLOT")
			For nx = 1 to Len(aHeader)
				If Trim(aHeader[nx][2]) == "UB_SUBLOTE"
					aCols[n][nx] :=CriaVar("UB_SUBLOTE")
					M->UB_SUBLOTE:=CriaVar("UB_SUBLOTE")
				ElseIf Trim(aHeader[nx][2]) == "UB_LOTE"
					aCols[n][nx] :=CriaVar("UB_LOTE")
					M->UB_LOTE   :=CriaVar("UB_LOTE")
				ElseIf Trim(aHeader[nx][2]) == "UB_DTVALID"
					aCols[n][nx] :=CriaVar("UB_DTVALID")
					M->UB_DTVALID:=CriaVar("UB_DTVALID")
				Endif
			Next nx
			DbSelectArea(cAlias)
			Return .F.
		Endif
	Endif
Endif
Return .T.   




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
