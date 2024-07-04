#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'
#Include 'FINA677.CH'

Static __nMoedDolar := NIL
Static __nMoedEuro  := NIL	
Static _lFN677CLIP	:= ExistBlock("FN677CLIP")

Function F677PreLib(lAbono) As Logical
Local nMoeda		:= 0
Local nTxMoeda		:= 0
Local aArea 		:= GetArea()
Local nSaldo		:= 0
Local lOutraMoed	:= .F.
Local lGerouTitulo 	:= .F.
Local lGerouAbono	:= .F. 
Local nOpcao		:= 1
Local nX			:= 0
Local nTpTxPct		:= SuperGetMv("MV_TPTXPCT",,1)		//Tipo de taxa utilizada para prestação de contas
Local aAreaFO7		:= {}
Local lRet			:= .T.
Local lUseFluig		:= FWIsInCallStack("WFF677Grv")
Local cChaveFO7     := ""
Local lGerLanCon    := .F.

Default lAbono		:= .F.   

dbSelectArea("FO7")
aAreaFO7 := FO7->(GetArea())
FO7->(dbSetOrder(2))

//Verifica se já foi gerado algum título de outra liberação - não permite gerar outros títulos
If FO7->(dbSeek(xFilial("FO7") + FLF->(FLF_TIPO + FLF_PRESTA + FLF_PARTIC)))
	lRet := .F.
EndIf

If lRet
	//Gravação para as tres moedas
	For nX := 1 to 3
		DO CASE
			CASE nX == 1 //Reais
				nSaldo 	   := (FLF->FLF_TVLRE1 - (FLF->FLF_TADIA1 + FLF->FLF_TDESC1))
				nMoeda	   := 1	
				lGerLanCon := (FLF->FLF_LA != "S")
			CASE nX == 2 //Dolar
				nSaldo   := (FLF->FLF_TVLRE2 - (FLF->FLF_TADIA2 + FLF->FLF_TDESC2))
				nMoeda   := f677GetMoeda(1)
				nTxMoeda := FLF->FLF_TXTUR2
			CASE nX == 3 //Euro
				nSaldo   := (FLF->FLF_TVLRE3 - (FLF->FLF_TADIA3 + FLF->FLF_TDESC3))
				nMoeda   := f677GetMoeda(2)
				nTxMoeda := FLF->FLF_TXTUR3
		END CASE
		
		If nMoeda > 1 .And. nTpTxPct >= 2
			If nTpTxPct == 2
				nTxMoeda := RecMoeda(FLF->FLF_DTINI,nMoeda)
			ElseIF nTpTxPct == 3
				nTxMoeda := RecMoeda(FLF->FLF_DTFIM,nMoeda)
			Endif		
		EndIf
		
		If nSaldo > 0 //Saldo positovo / Contas a pagar			
			dbSelectArea("RD0")
			RD0->(dbSetOrder(1)) //Filial + Codigo
			
			If RD0->(MsSeek( xFilial("RD0") + FLF->FLF_PARTIC )) .And. !Empty(RD0->RD0_FORNEC) .And. !Empty(RD0->RD0_LOJA)   		
				If !lAbono
					lRet := FN677TCP(nOpcao, nSaldo, .F.,RD0->RD0_FORNEC,RD0->RD0_LOJA,RD0->RD0_TIPO == "2",nMoeda,nTxMoeda)
					
					If lRet
						lGerouTitulo := .T.
					ElseIf Type("lExecTit") == "L"
						lExecTit := .T.
					EndIf
				Else
					lRet := FN677TCP(nOpcao, nSaldo, .T.,RD0->RD0_FORNEC,RD0->RD0_LOJA,,nMoeda,nTxMoeda)
					
					If lRet
						lGerouAbono := .T.
					ElseIf Type("lExecTit") == "L"
						lExecTit := .T.
					EndIf
				EndIF
			Else
				lRet := .F.
				Help(" ", 1, "F677NOLIB", Nil, STR0117, 1, 0) //"Participante sem fornecedor vinculado."
			EndIf			
		ElseIf nSaldo < 0 //Saldo negativo / Contas a receber
			nSaldo := (nSaldo *-1)
			
			If !lAbono
				lRet := FN677TCR(nOpcao, nSaldo, .F.,nMoeda,nTxMoeda,FLF->FLF_PARTIC)
				
				If lRet
					lGerouTitulo := .T.
				ElseIf Type("lExecTit") == "L"
					lExecTit := .T.
				EndIf
			Else
				lRet := FN677TCR(nOpcao, nSaldo, .T.,nMoeda,nTxMoeda,FLF->FLF_PARTIC)
				
				If lRet
					lGerouAbono := .T.	
				ElseIf Type("lExecTit") == "L"
					lExecTit := .T.
				EndIf
			EndIf
		Endif
	Next
	
	If lRet
		If lGerouTitulo
			RecLock("FLF",.F.)
			FLF->FLF_STATUS := "7"
			FLF->(MsUnlock())
			
			If !lUseFluig
				F677MsgMail(4,,FLF->FLF_RECPAG,'1')
			EndIf
		ElseIf lGerouAbono	
			RecLock("FLF",.F.)
			FLF->FLF_ABONO 	:= "1"
			
			If !lOutraMoed .Or. (lOutraMoed .And. FLF->FLF_STATMX == "1") //Se não tem outras moedas ou se tem e está finalizada
				FLF->FLF_STATUS := "8"
				FLF->FLF_DTFECH := dDataBase
			Else
				FLF->FLF_STATUS := "7"
			EndIf
			
			FLF->(MsUnlock())
		
			If FLF->FLF_STATUS == "8"
				F677MsgMail(5,,) 
			EndIf
				
			dbSelectArea('FO7')
			FO7->(dbSetOrder(2)) //FO7_FILIAL + TIPO + FO7_PRESTA + FO7_PARTIC
			cChaveFO7 := xFilial('FO7')+FLF->(FLF_TIPO+FLF_PRESTA+FLF_PARTIC)
			
			If FO7->(dbSeek(cChaveFO7))		
				While !FO7->(Eof()) .And. FO7->(FO7_FILIAL+FO7_TPVIAG+FO7_PRESTA+FO7_PARTIC) == cChaveFO7
					RecLock("FO7", .F.)
					FO7->FO7_DTBAIX := dDataBase
					MsUnLock()
					FO7->(dbSkip())
				EndDo
			EndIf
		ElseIf nSaldo == 0
			RecLock("FLF",.F.)
			FLF->FLF_STATUS := "8"
			FLF->FLF_DTFECH := dDataBase
			FLF->(MsUnlock())
			F677MsgMail(5,,)
		EndIf
		
		//Grupo de perguntes
		pergunte("F677REC",.F.)
		
		//Contabilização On-Line
		If lGerLanCon .And. mv_par02 == 1
			F6778BLCt(.F.)
		EndIf
	EndIf
EndIf

RestArea(aAreaFO7)
RestArea(aArea)
FwFreeArray(aAreaFO7)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN677TCP
Gera titulo no contas a pagar no Financeiro, para o participante que
teve mais gastos do que lhe foi pago no adiantamento 

@author Pedro Alencar
@since 06/11/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FN677TCP(nOpcao,nValor,lAbono,cFornece,cLoja,lExterno,nMoeda,nTxMoeda)
	Local aArea			:= GetArea()
	Local aAreaFLF		:= {}
	Local _aTit			:= {}
	Local lRet			:= .F.
	Local cPrefixo		:= ""
	Local cNaturez		:= ""
	Local nUtiOco		:= SuperGetMV('MV_RESUTCO',.F.,1)//"1" = útil
	Local cTipo			:= SuperGetMV("MV_RESTPPC",.T.,"DP ")
	Local nDiasVenc 	:= SuperGetMV("MV_RESDTCP",.T.,1)
	Local nTamPrf		:= TamSx3("E2_PREFIXO")[1]
	Local nTamNum		:= TamSx3("E2_NUM")[1]
	Local nTamParc		:= TamSx3("E2_PARCELA")[1]
	Local nTamTipo		:= TamSx3("E2_TIPO")[1]
	Local nTamNat		:= TamSx3("E2_NATUREZ")[1]
	Local cNumTit		:= ""
	Local dDataVenc 	:= dDataBase 
	Local dDataAux		:= CTOD('//')
	Local lOK			:= .T.
	Local nX			:= 0
	Local aCC			:= {}
	Local aAuxSEV		:= {}
	Local aAuxSEZ		:= {}
	Local aRatSEZ		:= {}
	Local aRatSEVEZ 	:= {}
	Local aExt			:= {}
	Local cID			:= ''
	Local nCurrency		:= 0
	Local lF677MDTIT	:= ExistBlock('F677MDTIT')
	Local aErro			:= {}
	Local cFileLog		:= ""
	Local cPath			:= ""
	Local cMsg			:= ""
	Local oModelAnt		:= FwModelActive()
	Local oModelAtu		:= Nil
	Local cMensagem		:= ''
	Local cValor 		:= ''
		
	Default lExterno	:= .F.
	Default nOpcao 		:= 1
	Default lAbono 		:= .F.
	Default cFornece	:= ""
	Default cLoja 		:= ""
	Default nMoeda		:= 1
	Default nTxMoeda	:= 0

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.

	aAreaFLF := FLF->(GetArea())
	cNaturez := Iif(lAbono, SuperGetMV("MV_RESNABP",.T.,""), SuperGetMV("MV_RESNTCP",.T.,""))
	
	If nOpcao = 1 //Inserir título a pagar
		If lExterno
			SaveInter() // Salva variaveis publicas
			Pergunte("F677REC",.F.)
			
			If Empty(FLF->FLF_SERIE) .OR. Empty(FLF->FLF_DOC)
				If (lOK := F667Externo(aExt))
					cPrefixo := aExt[1]
					cNumTit  := aExt[2]
				EndIf
			Else
				cPrefixo := FLF->FLF_SERIE
				cNumTit  := FLF->FLF_DOC
			EndIf
			
			RestInter() // Restaura variaveis publicas
		Else 
			cPrefixo := Iif(lAbono, SuperGetMV("MV_RESPABN",.T.,"   "), SuperGetMV("MV_RESPFCP",.T.,"   "))
			cNumTit  := ProxTitulo("SE2",cPrefixo)
		EndIf
		
		If lOK		
			//Retorna a data do vencimento 
	    	If !lAbono
		    	//Cálculo do dia de vencimento.
				If nUtiOco == 1 //Util
					For nX = 1 To nDiasVenc
						dDataAux	:= (dDataVenc + 1)
						dDataVenc	:= DataValida(dDataAux)
					Next nX
				Else //Corrido
					dDataVenc := DataValida(dDataVenc + nDiasVenc)
				EndIf
			EndIf
			
			_aTit := {}
			AADD(_aTit , {"E2_NUM"    	,PadR(cNumTit,nTamNum)	,NIL})
			AADD(_aTit , {"E2_PREFIXO"	,PadR(cPrefixo,nTamPrf)	,NIL})
			AADD(_aTit , {"E2_PARCELA"	,Space(nTamParc)		,NIL})
			AADD(_aTit , {"E2_TIPO"   	,PadR(cTipo,nTamTipo)	,NIL})
			AADD(_aTit , {"E2_NATUREZ"	,PadR(cNaturez,nTamNat)	,NIL})
			AADD(_aTit , {"E2_FORNECE"	,cFornece				,NIL})
			AADD(_aTit , {"E2_LOJA"   	,cLoja					,NIL})
			AADD(_aTit , {"E2_EMISSAO"	,dDatabase				,NIL})			
			AADD(_aTit , {"E2_VENCTO" 	,dDataVenc				,NIL})
			AADD(_aTit , {"E2_VENCREA"	,dDataVenc				,NIL})			
			AADD(_aTit , {"E2_EMIS1"  	,dDatabase				,NIL})

			If lF677MDTIT
				nCurrency := nMoeda
			EndIf

			If nMoeda > 1 .And. SuperGetMV("MV_PCMDCP",,"2") == "1" //Moeda forte do sistema
				nValor := Round(xMoeda(nValor, nMoeda, 1, dDataBase, TamSx3("E2_TXMOEDA")[2], nTxMoeda), 2)
				nMoeda := 1
			EndIf

			AADD(_aTit , {"E2_MOEDA"	,nMoeda					,NIL})               			
			AADD(_aTit , {"E2_VALOR"	,nValor					,NIL})			
			AADD(_aTit , {"E2_ORIGEM"	,"FINA677"				,NIL})
			AADD(_aTit , {"E2_HIST"		,STR0123 + FLF->FLF_PRESTA + STR0124 + FLF->FLF_PARTIC, Nil})
			If lAbono 
				AADD(_aTit , {"E2_SALDO" , 0					,NIL})	
				AADD(_aTit , {"E2_BAIXA",dDatabase				,NIL})	
			EndIf

			//Se titulo em moeda estrangeira e com cotação informada
			If nMoeda > 1 .and. nTxMoeda > 0
				AADD(_aTit , {"E2_TXMOEDA"	,nTxMoeda			,NIL})
			Endif
			
			//Calcula a proporção do centro de custo para o título.
			If !Empty(FLF->FLF_VIAGEM)
				aCC := F677CalcCC(FLF->FLF_VIAGEM, nValor)				
			ElseIf !Empty(FLF->FLF_CC) //Prestação de contas avulsa não esta relacionada a viagem.
				aAdd(aCC, {FLF->FLF_CC , nValor , "100",;
				FLF->FLF_ITECTA,FLF->FLF_CLVL } )
			EndIf
			//
			If !Empty(aCC)
			
				If Len(aCC) == 1
			   		AADD(_aTit, {"E2_CCUSTO" , aCC[1][1] , NIL })
			   		AADD(_aTit, {"E2_ITEMCTA", aCC[1][4] , NIL })
			   		AADD(_aTit, {"E2_CLVL"	 , aCC[1][5] , NIL })			   		
				Else  	
					aAdd( aAuxSEV ,{"EV_NATUREZ" , PadR(cNaturez,nTamNat),NIL})
					aAdd( aAuxSEV ,{"EV_VALOR"   , nValor , Nil })//valor do rateio na natureza
					aAdd( aAuxSEV ,{"EV_PERC"    , 100	 , Nil })//percentual do rateio na natureza
					aAdd( aAuxSEV ,{"EV_RATEICC" , "1"			 , Nil })//indicando que há rateio por centro de custo
			   
					For nX := 1 To Len(aCC)
					   
					   aAdd( aAuxSEZ ,{"EZ_CCUSTO" ,aCC[nX][1] , Nil })//centro de custo da natureza
					   aAdd( aAuxSEZ ,{"EZ_VALOR"  ,aCC[nX][2] , Nil })//valor do rateio neste centro de custo
					   aAdd( aAuxSEZ ,{"EZ_PERC"   ,aCC[nX][3] , NIl })
					   aAdd( aAuxSEZ ,{"EZ_ITEMCTA",aCC[nX][4] , NIl })
					   aAdd( aAuxSEZ ,{"EZ_CLVL"   ,aCC[nX][5] , NIl })						
					   aAdd( aRatSEZ ,aClone(aAuxSEZ))
					   aSize(aAuxSEZ ,0)
					   aAuxSEZ := {}
					   
					Next nX
					
					aAdd(aAuxSEV,{"AUTRATEICC" , aRatSEZ, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
					aAdd(aRatSEVEZ,aAuxSEV)//adicionando a natureza ao rateio de multiplas naturezas
				
					//
					AADD(_aTit ,{"E2_MULTNAT","1"		 	  ,NIL}) 	
					AADD(_aTit ,{"AUTRATEEV" ,aRatSEVEZ,Nil})//adicionando ao vetor aCab o vetor do rateio
				EndIf
				
			EndIf
						
			BEGIN TRANSACTION
			
			//Chamada da rotina automatica
			//3 = inclusao
			MSExecAuto({|x,y,w,z| FINA050(x,y,,,,.F.,.F.)}, _aTit, 3)
			
			If lMsErroAuto
				aErro	:= GetAutoGRLog()
				cFileLog:= NomeAutoLog()
				
				If Len(aErro) > 0
					For nX := 1 To Len(aErro)
						cMsg += aErro[nX] + CRLF
					Next nX
					MemoWrite( cFileLog, cMsg )
				EndIf
				
				MostraErro( cPath, cFileLog )
				lMsErroAuto := .F.
				DisarmTransaction()
				lRet := .F.
			Else
				
				lRet 	:= .T.
				cID		:= GetSxENum("FO7","FO7_CODIGO") 
				//
				If lAbono
					DbSelectArea("SE2")
					_aTit := {}

					AADD( _aTit, { "E2_PREFIXO"	, PadR(cPrefixo,nTamPrf), Nil } )
					AADD( _aTit, { "E2_NUM"		, PadR(cNumTit,nTamNum)	, Nil } )
					AADD( _aTit, { "E2_PARCELA"	, Space(nTamParc)		, Nil } )
					AADD( _aTit, { "E2_TIPO"	, PadR(cTipo,nTamTipo)	, Nil } )
					AADD( _aTit, { "E2_FORNECE"	, cFornece				, Nil } )
					AADD( _aTit, { "E2_LOJA"	, cLoja					, Nil } )
					AADD( _aTit, { "AUTMOTBX"  	, "DAC" 				, Nil } )	
					AADD( _aTit, { "AUTDTBAIXA"	, dDatabase				, Nil } )
					AADD( _aTit, { "AUTDTCREDITO", dDatabase				, Nil } )
					AADD( _aTit, { "AUTHIST"   	, STR0209+FLF->FLF_PRESTA, Nil } )	// "Abono Prest. Contas Viagem: "
					AADD( _aTit, { "AUTVLRPG"  	, nValor 				, Nil } )
					AADD( _aTit, { "AUTJUROS"  	, 0						, Nil } )
					AADD( _aTit, { "AUTDESCONT" , 0						, Nil } )
					AADD( _aTit, { "AUTMULTA" 	, 0						, Nil } )
					AADD( _aTit, { "AUTACRESC" 	, 0						, Nil } )
					AADD( _aTit, { "AUTDECRESC" , 0						, Nil } )

					MSExecAuto({|x, y| FINA080(x, y)}, _aTit, 3)

					// Restaura os perguntes que foram desposicionados para a baixa
					Pergunte("F677REC",.F.)

					If lMsErroAuto
						MostraErro()
						lMsErroAuto := .F.
						DisarmTransaction()
					EndIf
				EndIf

				RestArea(aAreaFLF)
											
				RecLock("FO7", .T.)
				FO7->FO7_FILIAL := xFilial("FO7") 				
				FO7->FO7_CODIGO := cID
				FO7->FO7_PRESTA := FLF->FLF_PRESTA
				FO7->FO7_TPVIAG := FLF->FLF_TIPO
				FO7->FO7_PREFIX := cPrefixo
				FO7->FO7_RECPAG := "P"
				FO7->FO7_TIPO 	:= cTipo
				FO7->FO7_TITULO := cNumTit
				FO7->FO7_PARCEL := Space(nTamParc)
				FO7->FO7_CLIFOR := cFornece
				FO7->FO7_LOJA	:= cLoja
				FO7->FO7_PARTIC	:= FLF->FLF_PARTIC
				FO7->(MsUnLock())	
				
				ConfirmSx8()
				
				If !Empty(aExt)
					
					RecLock('FLF', .F.)
						FLF->FLF_SERIE	:= aExt[1]
						FLF->FLF_DOC	:= aExt[2]
					FLF->(MsUnlock())
				
				EndIf	

				cValor := Transform( nValor, PesqPict( "FLF", "FLF_TVLRE1" ) )

				cMensagem := STR0202 + CRLF								//'Prestação de contas enviada para acerto financeiro.'
				cMensagem += STR0197 + FLF->FLF_PRESTA + CRLF 			//'Número da prestação: '
				cMensagem += STR0203 + cNumTit + CRLF 					//'Número do título: '
				cMensagem += STR0204 + Dtoc( dDataVenc ) + CRLF 		//'Vencimento do título: '
				cMensagem += STR0205 + Alltrim( cValor ) + CRLF 		//'Valor do título: '

				F677PushNotification( 100, NIL, STR0001 + " - " + STR0206, cMensagem )			//'Prestação de Contas'###'Geração de título a pagar'
			EndIf
			
			END TRANSACTION
			
			If lF677MDTIT
				ExecBlock('F677MDTIT',.F.,.F.,{nCurrency,'P',nTxMoeda})
			EndIf
			
		Else
			lRet := .F.
			Help(" ",1,"F677NOTIT",,STR0118,1,0)
		EndIf
		
	Else //Excluir 
		//Posiciona no titulo no Financeiro
		DbSelectArea("SE2")
		DbSelectArea("FO7")
		FO7->(dbSetOrder(2)) //FO7_FILIAL + FO7_PRESTA + FO7_PARTIC
		FO7->(dbSeek( xFilial('FO7') + FLF->FLF_TIPO + FLF->FLF_PRESTA + FLF->FLF_PARTIC))

		BEGIN TRANSACTION
		//
		While (!FO7->(Eof()) .AND. FO7->FO7_FILIAL + FO7->FO7_TPVIAG + FO7->FO7_PRESTA + FO7->FO7_PARTIC ==;
									xFilial('FO7') + FLF->FLF_TIPO + FLF->FLF_PRESTA + FLF->FLF_PARTIC ) .AND. FO7->FO7_RECPAG == "P"

			SE2->(dbSetOrder(1))
			If SE2->(MsSeek(xFilial("SE2")+FO7->(FO7_PREFIX+FO7_TITULO+FO7_PARCEL+FO7_TIPO+FO7_CLIFOR+FO7_LOJA)))
				_aTit := {}
				
				If lAbono
					AADD(_aTit , {"E2_PREFIXO"	, FO7->FO7_PREFIX	,NIL})
					AADD(_aTit , {"E2_NUM"		, FO7->FO7_TITULO	,NIL})
					AADD(_aTit , {"E2_PARCELA"	, FO7->FO7_PARCEL	,NIL})
					AADD(_aTit , {"E2_TIPO"  	, FO7->FO7_TIPO		,NIL})
					AADD(_aTit , {"E2_FORNECE"	, FO7->FO7_CLIFOR	,NIL})
					AADD(_aTit , {"E2_LOJA"  	, FO7->FO7_LOJA		,NIL})

					MSExecAuto({|x, y| FINA080(x, y)}, _aTit, 5)

					If lMsErroAuto
						MostraErro() 
						lMsErroAuto := .F.
						DisarmTransaction()
						lRet := .F.
						Exit
					EndIf

					_aTit := {}
				EndIf 
				
				AADD(_aTit, {"E2_NUM"    , FO7->FO7_TITULO,	NIL})
				AADD(_aTit, {"E2_PREFIXO", FO7->FO7_PREFIX,	NIL})
				AADD(_aTit, {"E2_PARCELA", FO7->FO7_PARCEL,	NIL})
				AADD(_aTit, {"E2_TIPO"   , FO7->FO7_TIPO,	NIL})
				AADD(_aTit, {"E2_FORNECE", FO7->FO7_CLIFOR,	NIL})
				AADD(_aTit, {"E2_LOJA"   , FO7->FO7_LOJA,	NIL})
				
				//Chamada da rotina automatica
				//5 = Exclusao
				MSExecAuto( { |x, y, z| FINA050( x, y, z, , , .F., .F. ) }, _aTit, 5, 5 )
				
				If lMsErroAuto
					aErro	:= GetAutoGRLog()
					cFileLog:= NomeAutoLog()
					
					If Len(aErro) > 0
						For nX := 1 To Len(aErro)
							cMsg += aErro[nX] + CRLF
						Next nX
						MemoWrite( cFileLog, cMsg )
					EndIf
					
					MostraErro( cPath, cFileLog )
					lMsErroAuto := .F.
					DisarmTransaction()
					lRet := .F.
					Exit
				Else
					lRet := .T.
					RecLock("FO7",.F.,.T.)
					FO7->(dbDelete())
					FO7->(MsUnlock())
				EndIf
	    		
	    	Endif
			FO7->(dbSkip())	
			
		EndDo	

		END TRANSACTION	
		
	EndIf
	
	oModelAtu := FWModelActive()
	
	If oModelAtu != Nil
		If oModelAnt:cId != oModelAtu:cId 
			oModelAnt:Activate()
		Endif
	Else
		If oModelAnt != Nil
			oModelAnt:Activate()
		EndIf	
	EndIf
	
	RestArea(aAreaFLF)
	RestArea(aArea)
	
	aSize(aAuxSEZ, 0)
	aSize(aAuxSEV, 0)
	aSize(aRatSEVEZ,0)
	aSize(aRatSEZ, 0)
	aSize(aCC, 0)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN677TCR
Gera titulo no contas a receber no Financeiro, quando o participante
gastar menos do que lhe foi adiantado na viagem 

@author Pedro Alencar
@since 06/11/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FN677TCR(nOpcao,nValor,lAbono,nMoeda,nTxMoeda,cCodPart)
	Local aArea			:= GetArea()
	Local aAreaFLF		:= {}
	Local aAreaFO7		:= {}
	Local _aTit			:= {}
	Local lRet			:= .F.
	Local cPrefixo		:= ""
	Local cNaturez		:= ""
	Local nUtiOco		:= SuperGetMV('MV_RESUTCO',.F.,1)//"1" = útil
	Local cTipo			:= SuperGetMV("MV_RESTPPR",.T.,"DP ")	
	Local nDiasVenc		:= 0
	Local cAuxCli  		:= SuperGetMV("MV_RESCLIP",," ")
	Local nTamPrf		:= TamSx3("E1_PREFIXO")[1]
	Local nTamNum		:= TamSx3("E1_NUM")[1]
	Local nTamParc		:= TamSx3("E1_PARCELA")[1]
	Local nTamTipo		:= TamSx3("E1_TIPO")[1]
	Local nTamNat		:= TamSx3("E1_NATUREZ")[1]
	Local nTamLoja 		:= TamSx3("E1_LOJA")[1]
	Local nTamCli		:= TamSx3("E1_CLIENTE")[1]
	Local cNumTit		:= ""
	Local nX			:= 0	
	Local cCliente 		:= ""
	Local cLoja 		:= ""
	Local aAuxCli 		:= {}
	Local dDataVenc		:= dDataBase
	Local dDataAux
	Local aCC			:= {}
	Local aAuxSEV		:= {}
	Local aAuxSEZ		:= {}
	Local aRatSEZ		:= {}
	Local aRatSEVEZ		:= {}
	Local aParam040	:= {{"MV_PAR01",2},{"MV_PAR02",2},{"MV_PAR03",2}}	
	Local oModel 		:= Nil
	Local cViagem		:= ''
	Local cPresta		:= ''
	Local cPartic		:= ''
	Local cID			:= ''
	Local nCurrency		:= 0
	Local lF677MDTIT	:= ExistBlock('F677MDTIT')
	Local cFilFO7		:= '' 
	Local aCliente		:= {}
	Local cChaveFKF     := ""

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	
	Default nOpcao		:= 1
	Default lAbono		:= .F.
	Default nMoeda		:= 1
	Default nTxMoeda	:= 0
	Default cCodPart	:= ''

	aAreaFLF := FLF->(GetArea())
	aAreaFO7 := FO7->(GetArea())

	oModel 	:= FWModelActive()
	
	If oModel == Nil
		oModel := FWLoadModel('FINA677')
		oModel:Activate()
	EndIf

	cViagem	:= oModel:GetValue('FLFMASTER','FLF_VIAGEM')
	cPresta	:= oModel:GetValue('FLFMASTER','FLF_PRESTA')
	cPartic	:= oModel:GetValue('FLFMASTER','FLF_PARTIC')
	
	If Empty(cCodPart)
		cCodPart := cPartic
	EndIf
	
	cPrefixo := Iif(lAbono, SuperGetMV("MV_RESPABN",.T.,"   "), SuperGetMV("MV_RESPFCR",.T.,"   "))
	cNaturez := Iif(lAbono, SuperGetMV("MV_RESNABR",.T.,""), SuperGetMV("MV_RESNTCR",.T.,""))	
	
	If nOpcao = 1 //Inserir título a receber
		//Separa o cliente e loja padrão do parâmetro, em duas strings diferentes	
		aAuxCli  := StrToKArr(cAuxCli, "|")
		cCliente := PadR(aAuxCli[1], nTamCli, " ")
		cLoja    := Space(nTamLoja)
		
		If Len(aAuxCli) > 1
			cLoja := PadR(aAuxCli[2],nTamLoja)
		EndIf
		
		If _lFN677CLIP
			aCliente := ExecBlock("FN677CLIP",.F.,.F.,{cCliente,cLoja,cCodPart})
			If ValType(aCliente) == "A" .and. !Empty(aCliente)
				cCliente := aCliente[1]
				cLoja	 := aCliente[2]
			EndIf
		EndIf
		
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + cCliente + cLoja))
			//Retorna a data do vencimento 
	    	If !lAbono
		    	//Cálculo do dia de vencimento. 
				If nUtiOco == 1 //Util
					nDiasVenc := SuperGetMv("MV_RESDTCR", .T., 1)
					
					For nX := 1 To nDiasVenc
						dDataAux  := (dDataVenc + 1)
						dDataVenc := DataValida(dDataAux)
					Next nX
				Else //Corrido
					dDataVenc := DataValida(dDataVenc + nDiasVenc)
				EndIf
			EndIf
			
			cNumTit	:= ProxTitulo("SE1",cPrefixo)
			_aTit := {}
			
			AADD(_aTit , {"E1_NUM"    	, PadR(cNumTit,nTamNum)		,NIL})
			AADD(_aTit , {"E1_PREFIXO"	, PadR(cPrefixo,nTamPrf) 	,NIL})
			AADD(_aTit , {"E1_PARCELA"	, Space(nTamParc)         	,NIL})
			AADD(_aTit , {"E1_TIPO"   	, PadR(cTipo,nTamTipo)    	,NIL})
			AADD(_aTit , {"E1_NATUREZ"	, PadR(cNaturez,nTamNat)  	,NIL})
			AADD(_aTit , {"E1_CLIENTE"	, cCliente                  ,NIL})
			AADD(_aTit , {"E1_LOJA"   	, cLoja						,NIL})
			AADD(_aTit , {"E1_EMISSAO"	, dDatabase					,NIL})
			AADD(_aTit , {"E1_VENCTO" 	, dDataVenc					,NIL})
			AADD(_aTit , {"E1_VENCREA"	, dDataVenc					,NIL})			
			AADD(_aTit , {"E1_EMIS1"  	, dDatabase					,NIL})

			If lF677MDTIT
				nCurrency := nMoeda
			EndIf
			
			If nMoeda > 1 .And. SuperGetMV("MV_PCMDCR",,"2") == "1" //Moeda forte do sistema
				nValor := Round(xMoeda(nValor, nMoeda, 1, dDataBase, TamSx3("E1_TXMOEDA")[2], nTxMoeda), 2)
				nMoeda := 1
			EndIf
			
			AADD(_aTit, {"E1_MOEDA",  nMoeda,    NIL})               
			AADD(_aTit, {"E1_VALOR",  nValor,    NIL})			
			AADD(_aTit, {"E1_ORIGEM", "FINA677", NIL})
			AADD(_aTit, {"E1_HIST",   STR0123 + cPresta + STR0124 + cPartic, Nil})
			
			//Se titulo em moeda estrangeira e com cotação informada
			If nMoeda > 1 .and. nTxMoeda > 0
				AADD(_aTit , {"E1_TXMOEDA"	,nTxMoeda			,NIL})
			Endif
			
			If !Empty(cViagem)
				aCC := F677CalcCC(cViagem, nValor)				
			ElseIf !Empty(oModel:GetValue("FLFMASTER","FLF_CC")) //Prestação de contas avulsa não esta relacionada a viagem.
				aAdd(aCC, {oModel:GetValue("FLFMASTER","FLF_CC") , nValor , "100",;
						   oModel:GetValue("FLFMASTER","FLF_ITECTA"),oModel:GetValue("FLFMASTER","FLF_CLVL") } )
			EndIf
			
			If !Empty(aCC)
				If Len(aCC) == 1
					AADD(_aTit , {"E1_CCUSTO"  , aCC[1][1] , NIL })
					AADD(_aTit , {"E1_ITEMCTA" , aCC[1][4] , NIL })
					AADD(_aTit , {"E1_CLVL"    , aCC[1][5] , NIL })					
				Else
				   aAdd( aAuxSEV ,{"EV_NATUREZ" , PadR(cNaturez,nTamNat),NIL})
				   aAdd( aAuxSEV ,{"EV_VALOR"   , nValor , Nil })//valor do rateio na natureza
				   aAdd( aAuxSEV ,{"EV_PERC"    , 100	 , Nil })//percentual do rateio na natureza
				   aAdd( aAuxSEV ,{"EV_RATEICC" , "1"			 , Nil })//indicando que há rateio por centro de custo
				   
				   For nX := 1 To Len(aCC)			   
					   aAdd( aAuxSEZ ,{"EZ_CCUSTO" ,aCC[nX][1] , Nil })//centro de custo da natureza
					   aAdd( aAuxSEZ ,{"EZ_VALOR"  ,aCC[nX][2] , Nil })//valor do rateio neste centro de custo
					   aAdd( aAuxSEZ ,{"EZ_PERC"   ,aCC[nX][3] , NIl })
					   aAdd( aAuxSEZ ,{"EZ_ITEMCTA",aCC[nX][4] , Nil })
					   aAdd( aAuxSEZ ,{"EZ_CLVL"   ,aCC[nX][5] , Nil })					   	
					   aAdd( aRatSEZ,aClone(aAuxSEZ))
					   aSize(aAuxSEZ,0)
					   aAuxSEZ := {}					   
					Next nX
					
					aAdd(aAuxSEV,{"AUTRATEICC" , aRatSEZ, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
					aAdd(aRatSEVEZ,aAuxSEV)//adicionando a natureza ao rateio de multiplas naturezas
					AADD(_aTit ,{"E1_MULTNAT","1"	,NIL}) 		
				EndIf
			EndIf	
			
			Begin Transaction
				/*aParam040 - passados para a rotina automatica da FINA040 para que as operacoes com o nao sejam contabilizadas. 
				A contabilizacao sera pelos registros de prestacao de contas */ 
				MSExecAuto({|x,y,z,a,b| FINA040(x,y,z,a,b)}, _aTit, 3,/**/,aRatSEVEZ,aParam040)
				
				If lMsErroAuto
					MOSTRAERRO()
					lMsErroAuto := .F.
					DisarmTransaction()
					lRet := .F.
				Else
					If lAbono
						_aTit := {}
						DbSelectArea("SE1")

						AADD(_aTit, { "E1_PREFIXO" 	, PadR(cPrefixo,nTamPrf), Nil } )	// 01
						AADD(_aTit, { "E1_NUM"     	, PadR(cNumTit,nTamNum)	, Nil } )	// 02
						AADD(_aTit, { "E1_PARCELA" 	, Space(nTamParc)		, Nil } )	// 03
						AADD(_aTit, { "E1_TIPO"    	, PadR(cTipo,nTamTipo)	, Nil } )	// 04
						AADD(_aTit, { "AUTMOTBX"  	, "DAC"					, Nil } )	// 05
						AADD(_aTit, { "AUTDTBAIXA"	, dDatabase				, Nil } )	// 06
						AADD(_aTit, { "AUTDTCREDITO", DataValida(dDatabase)	, Nil } )	// 07
						AADD(_aTit, { "AUTHIST"   	, STR0209+FLF->FLF_PRESTA, Nil } )	// "Abono Prest. Contas Viagem: "
						AADD(_aTit, { "AUTVALREC"  	, nValor				, Nil } )	// 09	
						AADD(_aTit, { "AUTJUROS"  	, 0						, Nil } )	// 10
						AADD(_aTit, { "AUTDESCONT" 	, 0						, Nil } )	// 11
						AADD(_aTit, { "AUTMULTA" 	, 0						, Nil } )	// 12
						AADD(_aTit, { "AUTACRESC" 	, 0						, Nil } )	// 13
						AADD(_aTit, { "AUTDECRESC" 	, 0						, Nil } )	// 14							

						MSExecAuto({|x, y| FINA070(x, y)}, _aTit, 3)

						// Restaura os perguntes que foram desposicionados para a baixa
						Pergunte("F677REC",.F.)

						If lMsErroAuto
							MostraErro()
							lMsErroAuto := .F.
							DisarmTransaction()
						EndIf
					EndIf
					
					FO7->(DbSetOrder(1))
					
					lRet := .T.
					cID  := GetSxENum("FO7","FO7_CODIGO")		

					cFilFO7 := xFilial("FO7")

					If F677FO7Cod(cID, cFilFO7)
						While .T.
							cID := GetSxENum("FO7","FO7_CODIGO")
							If !F677FO7Cod(cID, cFilFO7)
								Exit
							EndIf
						EndDo
					EndIf

					RestArea(aAreaFLF)

					RecLock("FO7", .T.)
					FO7->FO7_FILIAL := cFilFO7 				
					FO7->FO7_CODIGO := cID
					FO7->FO7_PRESTA := oModel:GetValue('FLFMASTER','FLF_PRESTA')
					FO7->FO7_TPVIAG := oModel:GetValue('FLFMASTER','FLF_TIPO')
					FO7->FO7_PREFIX := cPrefixo
					FO7->FO7_RECPAG := "R"
					FO7->FO7_TIPO 	:= cTipo
					FO7->FO7_TITULO := cNumTit
					FO7->FO7_PARCEL := Space(nTamParc)
					FO7->FO7_CLIFOR := cCliente
					FO7->FO7_LOJA  	:= cLoja
					FO7->FO7_PARTIC := cCodPart
					FO7->(MsUnLock())
					ConfirmSx8()
				Endif
			End Transaction
			
			If lF677MDTIT
				ExecBlock('F677MDTIT',.F.,.F.,{nCurrency,'R',nTxMoeda})
			EndIf
		Else
			lRet := .F.
			Help(,,"FN677TCR",,STR0168, 1, 0 ) 					
		Endif	
	Else //Excluir
		DbSelectArea("SE1")
		DbSelectArea('FO7')
		FO7->(dbSetOrder(2)) //FO7_FILIAL + TIPO + FO7_PRESTA + FO7_PARTIC		
		cChaveFKF := xFilial('FO7') + FLF->FLF_TIPO + FLF->FLF_PRESTA + FLF->FLF_PARTIC
		
		If FO7->(dbSeek(cChaveFKF))
			Begin Transaction
				While !FO7->(Eof()) .And. FO7->(FO7_FILIAL+FO7_TPVIAG+FO7_PRESTA+FO7_PARTIC) == cChaveFKF .And. FO7->FO7_RECPAG == "R"
					SE1->(dbSetOrder(1))
					
					If !Empty(FO7->FO7_TITULO) .And. (lRet := SE1->(MsSeek(xFilial("SE1")+FO7->(FO7_PREFIX+FO7_TITULO+FO7_PARCEL+FO7_TIPO+FO7_CLIFOR+FO7_LOJA))))
						_aTit := {}
						
						Aadd(_aTit, {"E1_PREFIXO", FO7->FO7_PREFIX, Nil})
						Aadd(_aTit, {"E1_NUM",     FO7->FO7_TITULO, Nil})
						Aadd(_aTit, {"E1_PARCELA", FO7->FO7_PARCEL, Nil})
						Aadd(_aTit, {"E1_TIPO",    FO7->FO7_TIPO,   Nil})
						Aadd(_aTit, {"E1_CLIENTE", FO7->FO7_CLIFOR, Nil})
						Aadd(_aTit, {"E1_LOJA",    FO7->FO7_LOJA,   Nil})
						
						If lAbono	
							MSExecAuto({|x, y| FINA070(x, y)}, _aTit, 5)
							lRet := Iif(lMsErroAuto, .F., lRet)
						EndIf 
						
						If lRet	 //5 = Exclusao
							/*aParam040 - passados para a rotina automatica da FINA040 para que as operacoes com o titulo 
							nao sejam contabilizadas. A contabilizacao sera pelos registros de prestacao de contas */ 							
							MSExecAuto({|x, y, z,a,b| FINA040(x, y, z, a, b)}, _aTit, 5, 5, Nil, aParam040)
							lRet := Iif(lMsErroAuto, .F., lRet)
							
							If lRet
								RecLock('FO7', .F.)
								FO7->(dbDelete())
								FO7->(MsUnlock())			
							EndIf
						EndIf
						
						_aTit := {}
						
						If !lRet
							If !IsBlind()
								MostraErro() 
							Endif
							lMsErroAuto := .F.
							DisarmTransaction()
							exit
						EndIf					
					EndIf		
					
					FO7->(DbSkip())		
				EndDo
			End Transaction
		EndIf
	Endif
    
	aSize(aCC, 0)
	aSize(aAuxSEV,0)		
	aSize(aAuxSEZ,0)		
	aSize(aRatSEZ,0)		
	aSize(aRatSEVEZ,0)
	RestArea(aAreaFO7)
	RestArea(aAreaFLF)	
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F667FilApAdt
Pergunte do Serie e Nota Fiscal do Fornecedor

@author Jose Domingos Caldana Jr

@since 05/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F667Externo(aRet)
Local cSerie		:= Replicate (" ", Len(FLF->FLF_SERIE)) 
Local cNFiscal		:= Replicate (" ", Len(FLF->FLF_DOC)) 
Local lContinua 	:= .T.
Local lExecute		:= .T.
Local lF677NFCOMP	:= ExistBlock("F677NFCOMP") 
Local lAltSrNt		:= IsInCallStack("F677AltSrNt")
Local aPerguntas	:= {}
Local aParam		:= {}
Local oModel		:= FwModelActive()
Local oModelFLF		:= Nil
Local aAreaFLF		:= FLF->(GetArea())
Local lModelAtivo   := .F.
Local lAchouFLF     := .F.
Local cParticip     := ""

Default aRet := {} 

MV_PAR01 := cSerie
MV_PAR02 := cNFiscal

If oModel != Nil
	oModelFLF := oModel:GetModel("FLFMASTER")
	lModelAtivo := (oModelFLF != Nil)
EndIf

//Ponto de entrada para complemento da nota de terceiro
If lF677NFCOMP
	aRet := ExecBlock("F677NFCOMP",.F.,.F.)
	If Len(aRet) > 0
		cSerie := aRet[1]
		cNFiscal := aRet[2]
	EndIf
EndIf

If lModelAtivo
	If lAltSrNt
		cSerie   := oModelFLF:GetValue('FLF_SERIE')
		cNFiscal := oModelFLF:GetValue('FLF_DOC')
	EndIf
	cParticip := oModelFLF:GetValue('FLF_PARTIC')
EndIf

Aadd( aPerguntas, { 9, STR0119, 150, 7, .F. } )  //"Informe a Série e o número da Nota Fiscal do Terceiro."
Aadd( aPerguntas, { 1, STR0120,	cSerie, "@!", '.T.', , IIf( Empty(cSerie) .OR. lAltSrNt, '.T.', '.F.' ), 30, .T. } ) //"Série"
Aadd( aPerguntas, { 1, STR0121,	cNFiscal, "@!", '.T.', , IIf( Empty(cNFiscal) .OR. lAltSrNt, '.T.', '.F.' ), 60, .T. } ) //"Nota Fiscal"

While lExecute
	lContinua := ParamBox( aPerguntas,STR0039,aParam,{|| F677VldExt(aParam[2],aParam[3]) },,,,,,FunName(),.F.,.T.) 		//"Parâmetros"
	
	//Caso cancele o input dos dados das notas fiscais
	If !lContinua
		Exit
	EndIf
	
	//Efetuo o seek da chave do título que será gerado a partir da NF e Série digitados
	//caso o título com mesmo número e prefixo já exista para o fornecedor em questão,
	//reprovo a prestação de contas e devolvo-a para que o participante que a gerou
	//acerte os dados de NF e série para que a prestação seja reenviada para aprovação
	FLF->(DbSetOrder(4))	
	lAchouFLF := FLF->(DbSeek(xFilial('FLF') + aParam[2] + aParam[3]))
	lExecute  := .F.
	
	If !lAltSrNt .Or. (lAltSrNt .And. (aParam[2]+aParam[3]) <> (cSerie+cNFiscal))
		If (lExecute := (lAchouFLF .And. lModelAtivo .And. FLF->FLF_PARTIC == cParticip))
			Help(' ', 1, 'F677EXTNF', Nil, STR0171, 1, 0) //"Participante sem cadastro de fornecedor. Titulo não será gerado."
			aParam[2] := cSerie
			aParam[3] := cNFiscal
		EndIf
	EndIf
EndDo

// Garantindo que os valores do parambox estarão nas devidas variáveis MV_PARXX
If lContinua
	aRet := {aParam[2] , aParam[3] }
EndIf

RestArea(aAreaFLF)
FwFreeArray(aPerguntas)
FwFreeArray(aParam)
Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} F677CalcCC
Realiza calculo de proporção do centro de custo para a prestação de contas.
@author William Matos Gundim Jr.
@param cViagem = Código da viagem.
@param nTotal = Valor total.
@since 13/08/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F677CalcCC(cViagem, nTotal)
Local aArea		:= GetArea()
Local aAreaFLH	:= FLH->(GetArea())
Local nTotPor	:= 0
Local aRet		:= {}
Local nX		:= 0

dbSelectArea('FLH')
FLH->(dbSeek( xFilial("FLH") + cViagem ))
//
While !FLH->(Eof()) .AND. xFilial('FLH') + FLH->FLH_VIAGEM  == (xFilial('FLH') + cViagem)
					
	If (nPos := Ascan(aRet,{|x| AllTrim(x[1] + x[4] + x[5]) == AllTrim(FLH->FLH_CC + FLH->FLH_ITECTA + FLH->FLH_CLVL)})) > 0
		aRet[nPos][3] := aRet[nPos][3] + FLH->FLH_PORCEN //Acumula porcentagem do CC.
	Else
		aAdd(aRet, {FLH->FLH_CC,0,FLH->FLH_PORCEN,FLH->FLH_ITECTA,FLH->FLH_CLVL } )	
	EndIf
	nTotPor += FLH->FLH_PORCEN
	FLH->(dbSkip())
	
EndDo			

For nX := 1 To Len(aRet)

	aRet[nX][3] := Round((aRet[nX][3] * 100) 		/ nTotPor,2) //Calcula o total que a porcentagem total representa em 100%.
	aRet[nX][2]	:= (aRet[nX][3] * nTotal)/ 100  //Calcula o total em valor que a porcentagem acima representa. 

Next nX

RestArea(aAreaFLH)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} f677GetMoeda
Busca qual moeda do financeiro representa o Dolar e o Euro

@author Mauricio Pequim Jr

@since 09/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function f677GetMoeda(nMoeda)

Local nX := 0
Local nMoedFin := 0

Default nMoeda := 0

If nMoeda > 0 .and. (__nMoedDolar == NIL .or. __nMoedEuro == NIL) 
	For nX := 2 to 99
		If nX <= 10		//MV_MOEDAn
			cDescSX6 := SUPERGETMV("MV_MOEDA"+cValToChar(nX),.T.,"NAOTEM")
		Else			//MV_MOEDnn
			cDescSX6 := SUPERGETMV("MV_MOED"+cValToChar(nX),.T.,"NAOTEM")	
		Endif

		If cDescSX6 == "NAOTEM"
			Exit
		Endif
		
		If Upper(Alltrim(cDescSX6)) == 'DOLAR'
			__nMoedDolar := nX 
		ElseIf Upper(Alltrim(cDescSX6)) == 'EURO'
 			__nMoedEuro := nX
 		Endif
 		
 		If __nMoedDolar != NIL .and. __nMoedEuro != NIL
 			Exit
 		Endif
 	Next nX
Endif

If nMoeda == 1	//Dolar
	nMoedFin := __nMoedDolar
ElseIf nMoeda == 2 //Euro
	nMoedFin := __nMoedEuro
Endif
 
Return nMoedFin

//-------------------------------------------------------------------
/*/{Protheus.doc} F667VldExt
Validação do pergunte do Serie e Nota Fiscal do Fornecedor

@author Pedro Pereira Lima

@since 10/08/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function F677VldExt(cParam1, cParam2)
Local lRet	:= .F.

If Empty(cParam1) .Or. Empty(cParam2)
	MsgAlert(STR0170)
Else
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F667FO7Cod
Executa query para validação do código da tabela FO7, obtido através da função
GetSXENum()

@author Pedro Pereira Lima
@since 22/11/2016
@version P12.1.7
@param cCodigo
@param cFilFO7
@return lExist
/*/
//-------------------------------------------------------------------
Function F677FO7Cod(cCodigo, cFilFO7)
Local lExist	:= .F.
Local cTmpFile	:= GetNextAlias()

If Select(cTmpFile) > 0
	(cTmpFile)->(DbCloseArea())
EndIf

BeginSql Alias cTmpFile
	SELECT FO7_CODIGO FROM %Table:FO7% FO7
	WHERE FO7.FO7_FILIAL = %Exp:cFilFO7% AND
	FO7.FO7_CODIGO = %Exp:cCodigo% AND FO7.%NotDel%
EndSql

If !(cTmpFile)->(Eof())
	lExist := .T.
	ConfirmSX8()
EndIf

If Select(cTmpFile) > 0
	(cTmpFile)->(DbCloseArea())
EndIf

Return lExist
