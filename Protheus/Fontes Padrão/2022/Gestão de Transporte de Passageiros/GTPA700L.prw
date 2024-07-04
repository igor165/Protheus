#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPA700L.CH' 

Static CARTAO_CREDITO	:= GTPGetRules('TPCARDCRED', .F., Nil, "CC")
Static CARTAO_DEBITO	:= GTPGetRules('TPCARDDEBI', .F., Nil, "CD")
Static CARTAO_PARCELADO	:= GTPGetRules('TPCARDPARC', .F., Nil, "CP")


function GTPA700L(lJob,nOp, cCaixa, cMsgErro,cMsgTit)

	Local aArray 	:= {}
	Local aParcelas := {}
	Local aDadosG6Y := {}
	Local lRet		:= .T.
	Local cAliasQry	:= GetNextAlias()
	Local cAliasPOS	:= GetNextAlias()
	Local cParc		:= StrZero(1,TamSx3('E1_PARCELA')[1])
	Local cNum		:= ''
	Local cTitChave := ''
	Local cFilAtu	:= cFilAnt
	Local cPrefixo  := PadR("POS",TamSx3('E1_PREFIXO'	)[1])  
	Local cTipo     := PadR("TF" ,TamSx3('E1_TIPO'		)[1])
	Local cNumSE1	:= ''
	Local cCliSBan	:= '999'
	Local nParcelas := 0
	Local nParc		:= 0
	Local cHistTit	:= ""	
	Local cNatTit	:= ''
	Local cDescAdm	:= ''
	Local cPath     := GetSrvProfString("StartPath","")
	Local cFile     := ""
	Local cMsgSoluc	:= ''
	Local cFilAtual := cFilAnt
	Local cFilSE1	:= ""
	Local aAreaG6T	:= G6T->(GetArea())
	Local aAreaG6Y	:= G6Y->(GetArea())
	Local lGT700LPE	:= ExistBlock("GT700LPE")
	Local aParam	:= {}
	
	Default cMsgErro	:= ""
	Default cMsgTit		:= ""
	Default lJob		:= .F.
	Default nOp			:= 1	// Operações(1=Gerar titulos no fechamento do caixa ; 2=Cancelar titulos na reabetura do caixa)
	
	private lMsErroAuto	:= .F.
	
	If nOp	== 1

		G6T->(DbSetOrder(3))
		G6T->( DbSeek(xFilial("G6T") + cCaixa  ) )
		
		If G6T->G6T_STATUS=='2' .Or. lJob
			GI6->(DbSetOrder(1))
			GI6->(DbSeek(xFilial("GI6")+ G6T->G6T_AGENCI))
	
	
			BeginSQL Alias cAliasQry
	
				SELECT  
					G6Y_FILIAL,G6Y_TPLANC,G6Y_VALOR,
					G6Y_DATA,G6Y_TIPPOS,G6Y_CODAGE,
					G6Y_NUMFCH, G6Y_CODADM,G6Y_CODAUT,
					G6Y_CODNSU,G6Y_ESTAB,G6Y_QNTPAR,
					G6Y_CODIGO,G6Y_ITEM,R_E_C_N_O_  AS RECG6Y
				FROM 
				%Table:G6Y% G6Y
				WHERE 
					G6Y_FILIAL = %xFilial:G6Y%
					AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
					AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
					AND G6Y_TPLANC = '6' 
					AND G6Y_TPVEND = 'P'
					AND G6Y_CHVTIT = '' 
					AND %NotDel%
	
			EndSQL
			
			SA1->(dbSetOrder(1))
			SAE->(dbSetOrder(1))
			G58->(dbSetOrder(2))
			SED->(dbSetOrder(1))
			If !(cAliasQry)->(Eof())
			
				RecLock('G6T', .F.)
				G6T->G6T_STSTIT = '1' // Status -> Gerando títulos....
				G6T->(MsUnlock())	
			
				Begin Transaction
	
					While (cAliasQry)->(!Eof()) .AND. lRet 
						cDescAdm	:= ''
						SA1->(dbSetOrder(1))
						If SAE->(DbSeek(xFilial("SAE") + (cAliasQry)->G6Y_CODADM ))
						
							If G58->(DbSeek(xFilial("G58") + SAE->AE_COD))	.AND. !Empty(G58->G58_CLIENT) .AND.	!Empty(G58->G58_LOJA)	
								If SA1->(DbSeek(xFilial("SA1") + G58->G58_CLIENT+G58->G58_LOJA ))
									SED->(DbSeek(xFilial("SED") + G58->G58_NATURE))
									cDescAdm	:= Posicione('SAE',1,xFilial('SAE') + G58->G58_BAND, 'AE_DESC')
								Else
									lRet	:= .F.
								Endif
							Else
								If SA1->(DbSeek(xFilial("SA1") + cCliSBan ))
									SED->(DbSeek(xFilial("SED") + SA1->A1_NATUREZ ))	
									cDescAdm	:= Posicione('SAE',1,xFilial('SAE') + (cAliasQry)->G6Y_CODADM, 'AE_DESC')
								Else
									lRet	:= .F.
								Endif
							Endif
							cNatTit	:= alltrim(SED->ED_CODIGO)
							If !lRet
								cMsgErro	:= STR0001//"Cliente informado nos parâmetros não encontrado. Verifique o conteúdo dos parâmetros"
								cMsgSoluc	:= ''
								cMsgTit		:= STR0002//"Geração dos Títulos de POS"
								Exit
							Endif 
		
							// gera titulo no contas a receber de bilhetes POS
		
							If !Empty(GI6->GI6_FILRES)
								cFilAnt := GI6->GI6_FILRES
							Endif
		
							aArray 		:= {}
							 
							nParcelas	:= Val((cAliasQry)->G6Y_QNTPAR )
		
							If nParcelas <= 0
								nParcelas := 1
							Endif
			
							If Alltrim(SAE->AE_TIPO) == "CD"
								cTipo	:= CARTAO_DEBITO
							ElseIf nParcelas > 1
								cTipo	:= CARTAO_PARCELADO
							Else
								cTipo	:= CARTAO_CREDITO
							Endif
						
							cNum := GtpTitNum('SE1', cPrefixo, cParc, cTipo)
														
							cTitChave   := xFilial("SE1") + cPrefixo + cNum + cParc + cTipo
		
							cHistTit	:= (cAliasQry)->( G6Y_CODIGO + G6Y_CODAGE + G6Y_NUMFCH + G6Y_ITEM )
		
							aParcelas	:= ParcTit(nParcelas,(cAliasQry)->G6Y_VALOR ,STOD((cAliasQry)->G6Y_DATA ),(cAliasQry)->G6Y_TIPPOS)
							
							SE1->(DbSetOrder(1))
		
							For nParc := 1 to Len(aParcelas)
								aArray :=	{;
												{ "E1_PREFIXO"	, cPrefixo									, Nil },; //Prefixo 
												{ "E1_NUM"		, cNum										, Nil },; //Numero
												{ "E1_PARCELA"	, StrZero(nParc,TamSx3('E1_PARCELA')[1])	, Nil },; //Parcela
												{ "E1_TIPO"		, cTipo										, Nil },; //Tipo
												{ "E1_NATUREZ"	, cNatTit									, Nil },; //Natureza
												{ "E1_CLIENTE"	, SA1->A1_COD								, Nil },; //Cliente
												{ "E1_LOJA"		, SA1->A1_LOJA								, Nil },; //Loja
												{ "E1_EMISSAO"	, STOD((cAliasQry)->G6Y_DATA )				, Nil },; //Data Emissão
												{ "E1_VALOR"	, aParcelas[nParc][1]						, Nil },; //Valor
												{ "E1_SALDO"	, aParcelas[nParc][1]	   					, Nil },; //Saldo
												{ "E1_VENCTO"	, aParcelas[nParc][2]						, Nil },; //Data Vencimento
												{ "E1_VENCREA"	, aParcelas[nParc][3]						, Nil },; //Data Vencimento Real
												{ "E1_HIST"		, cHistTit									, Nil },; //HIstórico
												{ "E1_ORIGEM"	, "GTPA700L"								, Nil };  //Origem										
											}
								MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3) // 3-Inclusao,4-Alteração,5-Exclusão		
								If !lMsErroAuto
									SE1->(RecLock("SE1",.F.))
									SE1->E1_NSUTEF 	:= (cAliasQry)->G6Y_CODNSU
									SE1->E1_CARTAUT := (cAliasQry)->G6Y_CODAUT
									SE1->(MsUnlock())
									If lGT700LPE
										Aadd(aParam, (cAliasQry)->G6Y_FILIAL )
										Aadd(aParam, (cAliasQry)->G6Y_CODIGO )
										Aadd(aParam, (cAliasQry)->G6Y_TPLANC )
										Aadd(aParam, (cAliasQry)->G6Y_NUMFCH )
										Aadd(aParam, (cAliasQry)->G6Y_CODAGE )
										Aadd(aParam, (cAliasQry)->G6Y_ITEM   )
										ExecBlock("GT700LPE", .f., .f., aParam)
									EndIf		
								Else
									lRet := .F.
									Exit
								Endif
							Next nParc	
							
							If lRet
								
								DbSelectArea("G6Y")
								
								cFilAnt := cFilAtu		
								
								G6Y->(DbGoTo((cAliasQry)->RECG6Y ))
								
								Reclock("G6Y", .F.)
								G6Y->G6Y_CHVTIT := cTitChave
								G6Y->(MsUnlock())
						
							Else
								Exit
							Endif
	
						Endif
						(cAliasQry)->(dbSkip())
	
					EndDo
					
					RestArea(aAreaG6Y)
					
					If !lRet
						DisarmTransaction()
						Break
					Endif
				End Transaction
				
				If lMsErroAuto
					If !lJob
						MostraErro()
					Else
						cMsgErro := MostraErro(cPath,cFile)
					Endif
					lRet := .F.
				ElseIf !lRet
					If !lJob
						FwAlertHelp(cMsgErro,cMsgSoluc,cMsgTit)					
					EndIf
					lRet := .F.	
				Else
					If !lJob
						FwAlertSuccess(STR0003,STR0002)//"Títulos gerados com sucesso"##"Geração dos Títulos de POS"
					Endif	

					RecLock('G6T', .F.)
					G6T->G6T_STSTIT = '2' // Status -> títulos gerados....
					G6T->(MsUnlock())	
								
				Endif
				
			Else
				cMsgErro	:= STR0004//"Não foram encontrados títulos para serem gerados"
				cMsgSoluc	:= ''
				cMsgTit		:= STR0002//"Geração dos Títulos de POS"
				If !lJob
					FwAlertHelp(cMsgErro,,cMsgTit)
				Endif
				lRet := .F.
			Endif
	
			If Select(cAliasQry) > 0
				(cAliasQry)->(dbCloseArea())
			Endif
		Else
			cMsgErro	:= STR0005//"Somente em caixa com status de fechado é possível gerar os títulos de POS."
			cMsgSoluc	:= ''
			cMsgTit		:= STR0002//"Geração dos Títulos de POS"
			If !lJob
				FwAlertWarning(cMsgErro,cMsgTit)
			Endif
			lRet := .F.
		Endif			
	Else
		
		// Deleta os titulos do POS 
		
		GI6->(DbSetOrder(1))
		GI6->(DbSeek(xFilial("GI6")+ G6T->G6T_AGENCI))
					
		lMsErroAuto := .F.
		
		BeginSQL Alias cAliasPOS
	
			SELECT G6Y_CHVTIT,G6Y.R_E_C_N_O_ AS RECG6Y
			FROM %Table:G6Y% G6Y
			INNER JOIN %Table:G6X% G6X ON 
				G6X.G6X_FILIAL = G6Y.G6Y_FILIAL
				AND G6X.G6X_AGENCI = G6Y.G6Y_CODAGE
				AND G6X.G6X_CODCX = G6Y.G6Y_CODIGO
				AND G6X.%NotDel%
			WHERE 
				G6Y_FILIAL = %xFilial:G6Y%
				AND G6Y_TPLANC = '6' 
				AND G6Y_TPVEND = 'P'
				AND G6Y_CHVTIT <> ' ' 
				AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
				AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
				AND G6Y.%NotDel%
				
		EndSQL
		If (cAliasPOS)->(!Eof() )
		
			RecLock('G6T', .F.)
			G6T->G6T_STSTIT = '4' // Status -> Cancelando títulos....
			G6T->(MsUnlock())	
		
			While (cAliasPOS)->(!Eof() .AND. lRet)
			
				cFilAtual  := cFilAnt
								
				SE1->(DbSetOrder(1))
				If SE1->(DbSeek((cAliasPOS)->G6Y_CHVTIT+GI6->GI6_CLIENT+GI6->GI6_LJCLI))
					cFilSE1		:= SE1->E1_FILIAL
					cPrefixo	:= SE1->E1_PREFIXO
					cNum		:= SE1->E1_NUM
					cTipo		:= SE1->E1_TIPO
					
					While  SE1->(!EOF()) .AND. SE1->E1_FILIAL == cFilSE1 .and. SE1->E1_PREFIXO == cPrefixo ;
							.and. SE1->E1_NUM == cNum .and. SE1->E1_TIPO == cTipo
						
						cFilAnt := 	SE1->E1_FILORIG
						
						lMsErroAuto := .F.
			 	
					 	aTitSE1	:= {}
						aTitSE1 := {	{ "E1_FILIAL"	, SE1->E1_FILIAL		            , Nil },; //Prefixo
										{ "E1_PREFIXO"	, SE1->E1_PREFIXO		            , Nil },; //Prefixo 
						 				{ "E1_NUM"		, SE1->E1_NUM  					    , Nil },; //Numero
								 		{ "E1_PARCELA"	, SE1->E1_PARCELA				    , Nil },; //Parcela
										{ "E1_TIPO"		, SE1->E1_TIPO					    , Nil },; //Tipo
						 				{ "E1_NATUREZ"	, SE1->E1_NATUREZ			        , Nil },; //Natureza
						 				{ "E1_CLIENTE"	, SE1->E1_CLIENTE				    , Nil },; //Cliente
						 				{ "E1_LOJA"		, SE1->E1_LOJA			 		    , Nil },; //Loja
						 				{ "E1_EMISSAO"	, SE1->E1_EMISSAO		         	, Nil },; //Data Emissão
						 				{ "E1_VENCTO"	, SE1->E1_VENCTO				    , Nil },; //Data Vencimento
						 				{ "E1_VENCREA"	, SE1->E1_VENCREA				    , Nil },; //Data Vencimento Real
						 				{ "E1_VALOR"	, SE1->E1_VALOR				        , Nil },; //Valor
						 				{ "E1_SALDO"	, SE1->E1_SALDO					    , Nil },; //Saldo
						 				{ "E1_HIST"		, SE1->E1_HIST						, Nil },; //HIstórico
						 				{ "E1_ORIGEM"	, "GTPA700L"						, Nil }}  //Origem
						 					
						 MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
							 
						If lMsErroAuto
						 	lRet := .F.
							cMsgErro := MostraErro(cPath,cFile) + CRLF	
							cFilAnt := 	cFilAtual									
							DisarmTransaction()
							Exit
						Endif	
						
						SE1->(DbSkip())
					EndDo
					
					If lRet
					
						cFilAnt := 	cFilAtual
						
						DbSelectArea("G6Y")
						
						G6Y->(DbGoTo((cAliasPOS)->RECG6Y ))
						
						Reclock("G6Y", .F.)
						G6Y->G6Y_CHVTIT := ''
						G6Y->(MsUnlock())
						
					Endif
				Else
					lRet:= .F.
					cMsgErro := STR0006//"Título de POS não encontrado no contas a receber"  
					DisarmTransaction()
					Exit
				EndIf
				(cAliasPOS)->(DbSkip())
			End
		Else
			cMsgErro	:= STR0007//"Não foram encontrados títulos para serem cancelados no caixa: "+ G6T->G6T_CODIGO
			cMsgTit		:= STR0008//"Cancelamento dos Títulos de POS"
			lRet := .F.
		Endif
		If Select(cAliasPOS) > 0
			(cAliasPOS)->(dbCloseArea())
		Endif		
	
	Endif
	
	RestArea(aAreaG6T)
	
Return lRet

/*/{Protheus.doc} ParcTit
Função responsavel para quebrar o titulo conforme a quantidade de parcelas
@type function
@author jacomo.fernandes
@since 10/08/2018
@version 1.0
@param nParcelas, numérico, Numero de parcelas
@param nVlrTot, numérico, Valor total da venda
@param dDtVenda, data, Data da venda
@param cTpPgto, character, Tipo de pagamento (1=Debito / 2=Credito)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function ParcTit(nParcelas,nVlrTot ,dDtVenda,cTpPgto)
	Local aParcRet		:= {}
	Local nX	 		:= 0
	Local dDtVenc		:= CTOD('  /  /  ')
	Local dDtVencRea	:= CTOD('  /  /  ')
	Local nVlrParc		:= NoRound(nVlrTot / nParcelas,2)
	Local nDif			:= nVlrTot - (nVlrParc * nParcelas )
	
	For nX := 1 To nParcelas
		
		If cTpPgto == '1' //se for debito é d+1
			dDtVenc := DaySum(dDtVenda,1)
		Else //se for credito é d+(nx*30)
			dDtVenc := MonthSum(dDtVenda,nX)
		Endif
		
		dDtVencRea := DataValida(dDtVenc) //Busca dia util
		
		If nX == nParcelas //Quando for a ultima parcela, adiciona o valor difencial da divisão 
			nVlrParc := nVlrParc + nDif
		Endif
		
		AADD ( aParcRet, { nVlrParc, dDtVenc , dDtVencRea } )

	Next nX

Return(aParcRet)

