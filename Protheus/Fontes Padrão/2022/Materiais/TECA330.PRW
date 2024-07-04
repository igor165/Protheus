#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TECA330.CH"
#INCLUDE "FWMVCDEF.CH"
Static lGeraMemo := .T.
Static cTipoAuto := ''

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA330
Alocacao de Atendentes

@sample 	TECA330()

@param		ExpC1	Numero do Contrato.
@param		ExpC2	Codigo orçamento de serviços.

@return		ExpL	Verdadeiro / Falso

@author		Anderson Silva
@since		05/10/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA330(cNrContrat, cNrOrcSrv, aAutomato)
	MsgInfo(STR0261) //"Alocacao de Atendentes: Rotina Descontinuada!"
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330VsAtd
Visualiza o Atendente.

@sample 	At330VsAtd(cCodAtend)

@param		ExpC1	Codigo do Atendente.

@return		ExpL	Verdadeiro.

@author		Anderson Silva
@since		27/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function At330VsAtd(cCodAtend)

Local lRetorno := .T. 		// Retorno na rotina.

If !Empty(cCodAtend)

	DbSelectArea("AA1")
	DbSetOrder(1)

	If DbSeek(xFilial("AA1")+cCodAtend)
		FWExecView(Upper(STR0071),"VIEWDEF.TECA020",1,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)    // Visualizar
	EndIf

Else
	MsgAlert(STR0157,STR0158) // "Selecione um atendente para visualizar."###"Atenção"
EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330LMkA1
Legenda do browse atendentes.

@sample 	At330LMkA1()

@param		Nenhum

@return		Nenhum

@author		Anderson Silva
@since		30/10/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function At330LMkA1(lSemSit)

Local oLegenda  :=  FWLegend():New() 				// Objeto FwLegend.

Default lSemSit := .F. //Existe a legenda sem situação
oLegenda:Add("","BR_BRANCO",STR0080)     		  	// "Disponível / Não Alocado."
oLegenda:Add("","BR_AMARELO",STR0081)				// "Não Disponível / Alocado."
oLegenda:Add("","BR_VERMELHO",STR0082)      		// "Não Disponível / Restrito no RH."
oLegenda:Add("","BR_PRETO",STR0231)      		// "Restrição de bloqueio no local de atendimento/cliente"
oLegenda:Add("","BR_LARANJA",STR0232)      		// "Restrição de aviso no local de atendimento/cliente"
oLegenda:Add("","BR_PINK",STR0257)      		// "Disponível / Férias programadas"
oLegenda:Add("","BR_AZUL",STR0259)				//"Atendente Intermitente"
oLegenda:Add("","BR_VIOLETA",STR0265)	//"Disponível / Alocado em RT."
If lSemSit
	oLegenda:Add("","BR_MARROM",STR0260)				//"Situação não consultada"
EndIf

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330GvAlo
Grava a alocacao dos atendentes na tabela ABB.

@sample 	At330GvAlo(aAtdXCalen)

@param		ExpA1 	Array com os atendentes X calendario do RH.
			ExpC2 	Codigo orçamento de serviços

@return		ExpL 	Verdadeiro

@author		Anderson Silva
@since		19/12/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function At330GvAlo(aAtdXCalen,cNrOrcSrv,cTipo,lExibe,aDados,lMemorando,lAtmTCan, lChkABBbd, cMsg, cCodRtItem,lPostoLib)

Local lRetorno 	:= .T.		 			// Retorno da rotina.
Local aAreaABB	:= ABB->(GetArea())  // Area da tabela ABB.
Local nX 		:= 0          			// Incremento utilizado no laco for.
Local nI 		:= 0					// Incremento utilizado no laco for.

// Guarda o Indice da Alocacao do atendente
Local _aAtenABB := {}
Local _cCtrato  := Space(TAMSX3("TFF_CONTRT")[1])
Local cMotCanc  := SuperGetMv("MV_ATMTCAN",,"")
Local cAliasABB := ""
Local cAliasBKP := ""
Local aQuery    := {}
Local oMdlManut := Nil
Local lRet      := .F.
Local aErro550  := {}
Local cQryABB 	:= ""
Local cFilAbb	:= xFilial("ABB")
Local lCustoTWZ	:= ExistBlock("TecXNcusto")
Local nCusto	:= 0
Local cCodTWZ 	:= ""
Local aCodigos 	:= ARRAY(LEN(aAtdXCalen))
Local lAt330Grv	:= ExistBlock("AT330GRV")
Local dDtIni    := StoD("")
Local lResTec   := .F.

Default cNrOrcSrv 	:= ""
Default cTipo 	 	:= ""
Default lExibe		:= .T.
Default aDados 		:= {}
Default lMemorando 	:= .T.
Default lAtmTCan 	:= .T.
Default lChkABBbd 	:= .T.
Default cMsg		:= ""
Default lPostoLib	:= .F.

If (!IsBlind() .And. lExibe) .AND. Empty(cMotCanc) .AND. lAtmTCan
	Aviso( STR0005,	STR0258 + CRLF + STR0244, {STR0161},3)  
EndIf

For nX := 1 TO LEN(aAtdXCalen)
	aCodigos[nX] := {}
	For nI := 1 To Len(aAtdXCalen[nX][10])
		If nI == 1
			AADD(aCodigos[nX], AtABBNumCd() )
		Else
			AADD(aCodigos[nX], Iif(lChkABBbd,AtABBNumCd(),GetSXENum("ABB","ABB_CODIGO")) )
		EndIf
	Next nI
Next nX

nX := 1
nI := 1

Begin Transaction

DbSelectArea("ABB")
ABB->(DbSetOrder(1))

DbSelectArea("AA1")
AA1->(DbSetOrder(1))

For nX := 1 To Len(aAtdXCalen)
	
	AA1->(MsSeek(xFilial("AA1")+ aAtdXCalen[nX][1]))

	//Busca o custo do atendente pelo PE ou pelo campo do atendente
	If lCustoTWZ
		// posicina ABQ
		DbSelectArea("ABQ")
		ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
		ABQ->( DbSeek( aAtdXCalen[nX][7] ) )
		
		// posicina TFF
		DbSelectArea("TFF")
		TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
		TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )

		nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
							{ 1, aAtdXCalen[nX][1], AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
								TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, aAtdXCalen[nX][7] } )
	Else
		nCusto := AA1->AA1_CUSTO
	EndIf
	
	For nI := 1 To Len(aAtdXCalen[nX][10])
		RecLock("ABB",.T.)
			Replace ABB->ABB_FILIAL	With cFilAbb
			Replace ABB->ABB_CODIGO	With aCodigos[nX][nI]
			Replace ABB->ABB_CODTEC	With aAtdXCalen[nX][1]

			If Empty(cNrOrcSrv)
				Replace ABB->ABB_ENTIDA	With "AB7"
				Replace ABB->ABB_CHAVE	With aAtdXCalen[nX][9]
				Replace ABB->ABB_NUMOS	With aAtdXCalen[nX][8]
			Else
				Replace ABB->ABB_LOCAL	With aAtdXCalen[nX][12]
			EndIf

			Replace ABB->ABB_DTINI	With aAtdXCalen[nX][10][nI][1]
			Replace ABB->ABB_HRINI	With aAtdXCalen[nX][10][nI][3]
			Replace ABB->ABB_DTFIM	With IIF(aAtdXCalen[nX][10][nI][4] < aAtdXCalen[nX][10][nI][3],1,0)+aAtdXCalen[nX][10][nI][1]
			Replace ABB->ABB_HRFIM	With aAtdXCalen[nX][10][nI][4]
			Replace ABB->ABB_HRTOT	With AtTotHora(ABB->ABB_DTINI ,aAtdXCalen[nX][10][nI][3], ABB->ABB_DTFIM ,aAtdXCalen[nX][10][nI][4])
			Replace ABB->ABB_SACRA 	With "S"
			Replace ABB->ABB_CHEGOU	With "N"
			Replace ABB->ABB_ATENDE	With "2"
			Replace ABB->ABB_MANUT	With "2"
			Replace ABB->ABB_ATIVO	With "1"
			Replace ABB->ABB_IDCFAL	With aAtdXCalen[nX][7]

			If !Empty(cTipo)
				Replace ABB->ABB_TIPOMV	With cTipo
			EndIf
			
			If lPostoLib
				Replace ABB->ABB_OBSERV	With  STR0266 //"Posto Liberado"
			EndIf

			//Grava o custo da alocação
			Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)

			If !Empty(cCodRtItem) .And. ABB->( ColumnPos("ABB_CODTW1")) > 0 
				Replace ABB_CODTW1 With cCodRtItem
			Endif
		MsUnLock()
		ConfirmSX8()
		
		AADD(aDados, {ABB->(RECNO()),;
						aCodigos[nX][nI],; //ABB->ABB_CODIGO,;
						aAtdXCalen[nX][1],; //ABB->ABB_CODTEC,;
						aAtdXCalen[nX][10][nI][3],; //ABB->ABB_HRINI,;
						aAtdXCalen[nX][10][nI][4],; //ABB->ABB_HRFIM,;
						cTipo,; //ABB->ABB_TIPOMV,;
						aAtdXCalen[nX][10][nI][1],; //ABB->ABB_DTINI,;
						IIF(aAtdXCalen[nX][10][nI][4] < aAtdXCalen[nX][10][nI][3],1,0)+aAtdXCalen[nX][10][nI][1],; //ABB->ABB_DTFIM,;
						aAtdXCalen[nX][10][nI][6],;
						CTOD('')})
		If lAt330Grv
			ExecBlock("AT330GRV",.F.,.F.)
		Endif
		If lMemorando
			_cCtrato := Substr(aAtdXCalen[nX][7],1,TAMSX3("TFF_CONTRT")[1])
			//Armazena os atendentes
			If aScan(_aAtenABB,{|X| X[1] = _cCtrato }) = 0
				Aadd(_aAtenABB, {_cCtrato,;
								ABB->ABB_CODIGO,;
								DTOS(ABB->ABB_DTINI),;
								ABB->ABB_HRINI,;
								DTOS(ABB->ABB_DTFIM),;
								ABB->ABB_HRFIM})
			EndIf
		Endif
	Next nI
	
	If nCusto > 0 .AND. SuperGetMv("MV_GRVTWZ",,.T.)
		//Realiza a gravação do custo
		At330HasTWZ( aAtdXCalen[nX][7], @cCodTWZ  )
		lRetorno := At330GrvCus( aAtdXCalen[nX][7], cCodTWZ, ,@cMsg )
		If !lRetorno
			Exit
		EndIf
	EndIf	
Next nX

//Avalia se ja existia agenda previa do tipo RESERVA para manutencao de CANCELAMENTO
If lRetorno .And. !Empty(cTipo) .And. !Empty(cMotCanc) .AND. lAtmTCan

	dbSelectArea("TCU")
	TCU->(dbSetOrder(1))
	If TCU->(dbSeek(xFilial("TCU")+cTipo )) .And. TCU->TCU_RESTEC <> "1"

		For nX := 1 To Len(aAtdXCalen)

			cAliasABB := GetNextAlias()
			BeginSql alias cAliasABB

				SELECT 1
				FROM %table:ABB% ABB
				INNER JOIN %table:TCU% TCU
				ON TCU_COD = ABB_TIPOMV
				WHERE ABB_CODTEC = %Exp:aAtdXCalen[nX][1]%
				AND ABB_DTINI >= %Exp:DToS(aAtdXCalen[nX][10][1][1])% 
				AND TCU_RESTEC = '1'
				AND ABB_FILIAL = %xFilial:ABB%
				AND TCU_FILIAL = %xFilial:TCU%
				AND ABB.%NotDel% 
				AND TCU.%NotDel% 

			EndSql

				//Verifica se há uma agenda de reserva técnica
			If (cAliasABB)->( !Eof() )
				lResTec := .T.
			EndIf	
			(cAliasABB)->( DbCloseArea() )

			For nI := 1 To Len(aAtdXCalen[nX][10])

				If lResTec
				//Busca as AGENDAS de RESERVA TECNICA para o mesmo periodo, pois serao canceladas automaticamente
					dbSelectArea("ABB") 
					ABB->(dbSetOrder(1))
					ABB->(dbSeek(xFilial("ABB")+aAtdXCalen[nX][1]+DToS(aAtdXCalen[nX][10][nI][1]) ))
					If dDtIni !=  ABB->ABB_DTINI //se as datas forem diferentes faz a próxima manutenção da agenda
						While ABB->(!Eof()) .And. ABB->(ABB_FILIAL+ABB_CODTEC+DTOS(ABB_DTINI)) == xFilial("ABB")+aAtdXCalen[nX][1]+DToS(aAtdXCalen[nX][10][nI][1])
							dbSelectArea("TCU")
							TCU->(dbSetOrder(1))
							TCU->(dbSeek(xFilial("TCU")+ABB->ABB_TIPOMV ))
							If TCU->TCU_RESTEC <> '1'
								ABB->(dbSkip())
								Loop
							EndIf

							aQuery := AT540ABBQry( ABB->ABB_CODTEC, ABB->ABB_CHAVE, ABB->ABB_DTINI, ABB->ABB_DTFIM, ABB->ABB_HRINI, ABB->ABB_HRFIM, ABB->ABB_CODIGO, .T., ABB->ABB_ENTIDA )

							If Len(aQuery) > 0
								cAliasABB := GetNextAlias()
								cAliasBkp := At550GtAls()
								cQryABB   := aQuery[1]
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryABB),cAliasABB)
								AT550StAls(cAliasABB)

								oMdlManut := FWLoadModel( "TECA550" )

								oMdlManut:SetOperation(3)
								lRet := oMdlManut:Activate()

								If lRet
									oMdlManut:SetValue( 'ABRMASTER', 'ABR_MOTIVO'	, cMotCanc)
									oMdlManut:SetValue( 'ABRMASTER', 'ABR_DTINI'	, ABB->ABB_DTINI)
									oMdlManut:SetValue( 'ABRMASTER', 'ABR_HRINI'	, ABB->ABB_HRINI)
									oMdlManut:SetValue( 'ABRMASTER', 'ABR_DTFIM'	, ABB->ABB_DTFIM)
									oMdlManut:SetValue( 'ABRMASTER', 'ABR_HRFIM'	, ABB->ABB_HRFIM)
									oMdlManut:SetValue( 'ABRMASTER', 'ABR_OBSERV'	, STR0221) //"Manutencao pela alocacao de reserva tecnica via contrato"

									lRet := oMdlManut:VldData() .And. oMdlManut:CommitData()
									If ( !lRet )
										aErro550   := oMdlManut:GetErrorMessage()
										Help( ,, 'At330GvAlo_CancAutom',, aErro550[MODEL_MSGERR_MESSAGE], 1, 0 )
									EndIf
								EndIf

								oMdlManut:DeActivate()
								oMdlManut:Destroy()
								At550StAls(cAliasBKP)

							EndIf
							dDtIni := aAtdXCalen[nX][10][nI][1]
							ABB->(DbSkip())
						EndDo
					EndIf	
				EndIf
			Next nI
			lResTec := .F.
		Next nX

	EndIf
EndIf

If lRetorno .And. lMemorando .AND. Len(_aAtenABB) > 0
	If !(isBlind()) .AND. ( PerguntMemo(lExibe) .AND. MSGYESNO( STR0218,STR0217 ) ) //"Deseja realmente gerar os memorandos?" # "Memorando"
		// Filtra os contratos/revisao dos atendentes.
		At330FilCt(_aAtenABB)
	EndIf
EndIf

If !lRetorno
	DisarmTransaction()
	Break
EndIf

End Transaction
RestArea(aAreaABB)

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330GvDes
Desaloca os atendentes na tabela ABB.

@sample 	At330GvDes(aAtdXAgend)

@param		ExpA1 	Array Atendente X Agendamentos.

@return		ExpA 	Saldo de horas por configuracao de alocacao

@author		Anderson Silva
@since		20/12/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function At330GvDes(aAtdXAgend)

Local aAreaABB	:= ABB->(GetArea()) 	// Guarda area atual da tabela ABB.
Local aAreaABR	:= ABR->(GetArea()) 	// Guarda area atual da tabela ABR.
Local nX 		:= 0					// Incremento utilizado no laco for.
Local nI		:= 0					// Incremento utilizado no laco for
Local nTotDes   := 0					// Total de horas a desalocar.
Local aSaldoCfg	:= {}					// Array com saldo de horas por configuracao de alocacao.
Local nPos		:= 0					// Posicao da configuracao da alocacao no array aSaldoCfg.
Local lRetorno 	:= .T.
Local lGrvCus	:= SuperGetMv("MV_GRVTWZ",,.T.)

DbSelectArea("ABB")
DbSetOrder(1)

DbSelectArea("ABR")
DbSetOrder(1)

Begin Transaction

For nX := 1 To Len(aAtdXAgend)
	For nI := 1 To Len(aAtdXAgend[nX][7])
		If aAtdXAgend[nX][7][nI][1]
			//ABB_FILIAL+ABB_CODTEC+DTOS(ABB_DTINI)+ABB_HRINI+DTOS(ABB_DTFIM)+ABB_HRFIM
			If ABB->( DbSeek(xFilial("ABB")+aAtdXAgend[nX][1]+dTos(aAtdXAgend[nX][7][nI][2])+;
					  aAtdXAgend[nX][7][nI][3]+dTos(aAtdXAgend[nX][7][nI][4])+aAtdXAgend[nX][7][nI][5]) )
				ABB->(RecLock("ABB",.F.))
				ABB->(DbDelete())
				ABB->(MsUnlock())
				If ABR->(DbSeek(xFilial("ABR")+ABB->ABB_CODIGO))
					While ABR->(!Eof()) .AND. ABR->ABR_FILIAL == xFilial("ABR") .AND.  ABR->ABR_AGENDA == ABB->ABB_CODIGO
						ABR->(RecLock("ABR",.F.))
							ABR->(DbDelete())
						ABR->(MsUnlock())
						ABR->(DbSkip())
					End
				EndIf
				nPos := aScan(aSaldoCfg,{|x| x[1] == ABB->ABB_IDCFAL})
				If nPos == 0
					aAdd(aSaldoCfg,{ABB->ABB_IDCFAL,HoraToInt(aAtdXAgend[nX][7][nI][6])})
				Else
					aSaldoCfg[nPos][2] += HoraToInt(aAtdXAgend[nX][7][nI][6])
				EndIf
			EndIf
		EndIf
	Next nI
	
	//Atualiza o Saldo do custo
	If lGrvCus
		lRetorno := At330GrvCus( ABB->ABB_IDCFAL, ABB->ABB_CODTWZ, .T. )
		If !lRetorno
			Exit
		EndIf
	EndIf	
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve o saldo de horas para configuracao da alocacao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	For nX := 1 To Len(aSaldoCfg)
		TxSaldoCfg(aSaldoCfg[nX][1],aSaldoCfg[nX][2],.T.)
	Next nX
Else
	DisarmTransaction()
	Break
EndIf

End Transaction

RestArea(aAreaABB)
RestArea(aAreaABR)

Return( aSaldoCfg )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330TipAlo

Tela de seleção do tipo de alocação.

@sample 	At330TipAlo()

@param		lAlocacao - Verifica se a rotina que esta sendo chamada é de alocação
						  ou manutenção.

@return	ExpC	cRet - Codigo do tipo de alocação

@since		23/04/2014
@author	Serviços
@version	P12
/*/
//------------------------------------------------------------------------------//
Function At330TipAlo(lAlocacao, aAutomato)

Local oDlg     := Nil
Local oOk		 := Nil
Local oBottom	 := Nil
Local oCombo	 := Nil
Local aArea    := GetArea()
Local aCmboCmp := {}
Local aTipos 	 := {}
Local nPosTipo := 0
Local cCmboCmp := ""
Local cRet     := ""
Local cTitulo	 := STR0203 // "Seleção do tipo de alocação"
Local lOk      := .F.

Default lAlocacao := .F.
Default aAutomato := Nil

If Empty(cTipoAuto) .AND. aAutomato == Nil

	DbSelectArea('TCU')
	TCU->(DbSetOrder(1)) //TCU_FILIAL+TCU_COD
	
	If !TCU->(DbSeek(xFilial("TCU"))) // caso não encontre informações
		At690Unit()  // crias os tipos padrão para a filial
		TCU->(DbSeek(xFilial("TCU")))  // após criar... reposiciona no primeiro registro da filial
	EndIf
	
	While TCU->(!EOF()) .And. TCU->TCU_FILIAL==xFilial('TCU')
	
		// Valida se o tipo deve ser mostrado na alocacao/manuntencao da agenda
		If	(lAlocacao .And. TCU->TCU_EXALOC <> "1") .Or. ;
			(!lAlocacao .And. TCU->TCU_EXMANU <> "1")
			TCU->(DbSkip())
			Loop
		EndIf
		aAdd( aCmboCmp, TCU->TCU_COD + " - " + TCU->TCU_DESC )
		aAdd( aTipos, { TCU->TCU_DESC, TCU->TCU_COD } )
		TCU->(DbSkip())
	End
	
	//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela
	Define MsDialog oDlg TITLE cTitulo FROM 000, 000 To 200, 200 Pixel Style 128
	
	oOk:= LoadBitMap(GetResources(), "LBOK")
	@ 020,020 SAY STR0203 OF oDlg PIXEL SIZE 80,9 // "Selecione o tipo da alocação:"
	@ 035,020 COMBOBOX oCombo VAR cCmboCmp ITEMS aCmboCmp OF oDlg SIZE 60,10 PIXEL;
	
	@ 060,020 Button oOk Prompt STR0022  Of oDlg Size 60, 010 Pixel //"Ok"
	oOk:bAction := { || lOk := .T., oDlg:End() }
	
	Activate MsDialog oDlg Centered
	
	If lOk
		nPosTipo := aScan( aTipos, { |x| AllTrim(x[2]) == Alltrim(Substr(cCmboCmp,1,TAMSX3("TCU_COD")[1])) } )
		If nPosTipo > 0
			cRet := aTipos[nPosTipo][2]
		EndIf
	Else
		cRet := ""
	EndIf
	
	RestArea(aArea)
Else
	cRet := cTipoAuto
EndIf

Return(cRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330GerMem

Filtra os atendentes do contrato

@sample 	At330GerMem(cNumContr, cRevContr, _aAtend_)

@param		cNumContr - Número do Contrato
@param		cRevContr - Revisão
@param		_aAtend_  - Vetor: cCodSub,cConfig,dDtIniSub,cHrIniSub,dDtFimSub,cHrFimSub,cLocal,cTipoAloc,cAgenda

@return	lRet

@since		05/02/2015
@author	Serviços
@version	P12
/*/
//------------------------------------------------------------------------------//
Function At330GerMem(cNumContr, cRevContr, _aAtend_)

Local lRet     := .F.
Local aAreaABB := GetArea()
Local cAliasAT := GetNextAlias()
Local _aMemo   := {} // Armazena as informacoes do memorando
Local cConfig  := ''
Local cLocal   := ''
Local cCodTec  := ''
Local cAgenda  := ''
Local cObserv 	:= ''
Local lVERSAO_23 := HasOrcSimp()
Local lOrcSimp	:= lVERSAO_23 .AND. AT745Contr(cNumContr, cRevContr)
If Type("M->ABR_OBSERV") == "C"
	cObser := M->ABR_OBSERV
Else
	cObser := STR0255 // "Sem Observações"
EndIF

// Filtra os atendentes alocados no contrato
IF !Empty(_aAtend_)

	cCodTec := _aAtend_[1]
	cConfig := _aAtend_[2]
	cLocal  := _aAtend_[7]
	cAgenda := _aAtend_[9]

	BeginSql Alias cAliasAT
		SELECT DISTINCT ADY_CLIENT
		              , ADY_LOJA
						, A1_NOME
		              , TFF_CONTRT
		              , TFF_CONREV
		              , AA1_CDFUNC
		              , AA1_NOMTEC
		              , AA1_FUNCAO
		              , RJ_DESC
		              , TFF_CARGO
		              , COALESCE(Q3_DESCSUM, '') AS Q3_DESCSUM
		              , ABB_CODTEC
		              , ABS_LOCAL
		              , ABS_DESCRI
		              , ABS_END
		              , ABS_BAIRRO
		              , ABS_CONTAT
		              , COALESCE(U5_CONTAT, '') AS U5_CONTAT
		              , COALESCE(U5_DDD, '') AS U5_DDD
		              , COALESCE(U5_FONE, '') AS U5_FONE
		              , ABB_TIPOMV
		              , COALESCE(TCU_DESC, '') AS TCU_DESC
		              , TFF_TURNO
		              , COALESCE(R6_DESC, '') AS R6_DESC
		  FROM %table:ABB% ABB

		  JOIN %table:AA1% AA1 ON AA1_FILIAL = %xFilial:AA1%
		   AND AA1_CODTEC = ABB_CODTEC
		   AND AA1.%notDel%
		
		  JOIN %Table:ABQ% ABQ ON ABQ_FILIAL = %xFilial:ABQ%
		   AND ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM = ABB_IDCFAL
		   AND ABQ.%notDel%

		  LEFT OUTER JOIN %table:TCU% TCU ON TCU_FILIAL = %xFilial:TCU%
		   AND TCU_COD = ABB_TIPOMV
		   AND TCU.%notDel%

		  JOIN %table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
		   AND TFJ_CONTRT = %Exp:cNumContr%
		   AND TFJ_CONREV = %Exp:cRevContr%
		   AND TFJ.%notDel%

		  JOIN %table:ADY% ADY ON ADY_FILIAL = %xFilial:ADY%
		   AND ADY_PROPOS = TFJ_PROPOS
		   AND ADY_PREVIS = TFJ_PREVIS
		   AND ADY.%notDel%

		  JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1%
		   AND A1_COD = ADY_CLIENT
		   AND A1_LOJA = ADY_LOJA
		   AND SA1.%notDel% 
		   	
		  JOIN %table:TFF% TFF ON TFF_FILIAL = ABQ_FILTFF
		   AND TFF_CONTRT = TFJ_CONTRT
		   AND TFF_CONREV = TFJ_CONREV 
		   AND TFF_COD = ABQ_CODTFF
		   AND TFF.%notDel% 
		
		  LEFT OUTER JOIN %Table:SR6% SR6 ON R6_FILIAL = %xFilial:SR6%
		   AND R6_TURNO = TFF_TURNO
		   AND SR6.%notDel%

		  LEFT OUTER JOIN %Table:SQ3% SQ3 ON Q3_FILIAL = %xFilial:SQ3%
		   AND Q3_CARGO = TFF_CARGO
		   AND SQ3.%notDel%

		  JOIN %Table:SRJ% SRJ ON RJ_FILIAL = %xFilial:SRJ%
		   AND RJ_FUNCAO = TFF_FUNCAO
		   AND SRJ.%notDel%

		  JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
		   AND TFL_CONTRT = TFJ_CONTRT
		   AND TFL_CONREV = TFJ_CONREV
		   AND TFL_CODIGO = TFF_CODPAI
		   AND TFL.%notDel%

		  JOIN %Table:ABS% ABS ON ABS_FILIAL = %xFilial:ABS%
		   AND ABS_LOCAL = TFL_LOCAL
		   AND ABS.%notDel%

		  LEFT OUTER JOIN %Table:SU5% SU5 ON U5_FILIAL = %xFilial:SU5%
		   AND U5_CODCONT = ABS_CONTAT
		   AND SU5.%notDel%
	   	
		 WHERE ABB_FILIAL = %xFilial:ABB%
		   AND ABB_IDCFAL = %Exp:cConfig%
		   AND ABB_LOCAL = %Exp:cLocal%
		   AND ABB_CODTEC = %Exp:cCodTec%
		   AND ABB.%notDel%

	EndSql
ElseIf !lOrcSimp
	BeginSql Alias cAliasAT
		SELECT DISTINCT ADY_CLIENT
		              , ADY_LOJA
						, A1_NOME
		              , TFF_CONTRT
		              , TFF_CONREV
		              , AA1_CDFUNC
		              , AA1_NOMTEC
		              , AA1_FUNCAO
		              , RJ_DESC
		              , TFF_CARGO
		              , COALESCE(Q3_DESCSUM, '') AS Q3_DESCSUM
		              , ABB_CODTEC
		              , ABS_LOCAL
		              , ABS_DESCRI
		              , ABS_END
		              , ABS_BAIRRO
		              , ABS_CONTAT
		              , COALESCE(U5_CONTAT, '') AS U5_CONTAT
		              , COALESCE(U5_DDD, '') AS U5_DDD
		              , COALESCE(U5_FONE, '') AS U5_FONE
		              , ABB_TIPOMV
		              , COALESCE(TCU_DESC, '') AS TCU_DESC
		              , TFF_TURNO
		              , COALESCE(R6_DESC, '') AS R6_DESC
		              , TFL_DTINI
		              , TFL_DTFIM
		              , TFF_HORAIN
		              , TFF_HORAFI
		  FROM %Table:ABB% ABB

		  JOIN %Table:AA1% AA1 ON AA1_FILIAL = %xFilial:AA1%
		   AND AA1_CODTEC = ABB_CODTEC
		   AND AA1.%notDel%
		
		  JOIN %Table:ABQ% ABQ ON ABQ_FILIAL = %xFilial:ABQ%
   		   AND ABB_IDCFAL = ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM
		   AND ABQ.%notDel%
		   
		  LEFT OUTER JOIN %Table:TCU% TCU ON TCU_FILIAL = %xFilial:TCU%
		   AND TCU_COD = ABB_TIPOMV
		   AND TCU.%notDel%

		  JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
		   AND TFJ_CONTRT = %Exp:cNumContr%
		   AND TFJ_CONREV = %Exp:cRevContr%
		   AND TFJ.%notDel%

		  JOIN %Table:ADY% ADY ON ADY_FILIAL = %xFilial:ADY%
		   AND ADY_PROPOS = TFJ_PROPOS
		   AND ADY_PREVIS = TFJ_PREVIS
		   AND ADY.%notDel%

		  JOIN %Table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1%
		   AND A1_COD = ADY_CLIENT
		   AND A1_LOJA = ADY_LOJA
		   AND SA1.%notDel% 
		   	
		  JOIN %table:TFF% TFF ON TFF_FILIAL = ABQ_FILTFF
		   AND TFF_CONTRT = TFJ_CONTRT
		   AND TFF_CONREV = TFJ_CONREV 
		   AND TFF_COD = ABQ_CODTFF
		   AND TFF.%notDel% 
		
		  LEFT OUTER JOIN %Table:SR6% SR6 ON R6_FILIAL = %xFilial:SR6%
		   AND R6_TURNO = TFF_TURNO
		   AND SR6.%notDel%

		  LEFT OUTER JOIN %Table:SQ3% SQ3 ON Q3_FILIAL = %xFilial:SQ3%
		   AND Q3_CARGO = TFF_CARGO
		   AND SQ3.%notDel%

		  JOIN %Table:SRJ% SRJ ON RJ_FILIAL = %xFilial:SRJ%
		   AND RJ_FUNCAO = TFF_FUNCAO
		   AND SRJ.%notDel%

		  JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
		   AND TFL_CONTRT = TFJ_CONTRT
		   AND TFL_CONREV = TFJ_CONREV
		   AND TFL_CODIGO = TFF_CODPAI
		   AND TFL.%notDel%

		  JOIN %Table:ABS% ABS ON ABS_FILIAL = %xFilial:ABS%
		   AND ABS_LOCAL = TFL_LOCAL
		   AND ABS.%notDel%

		  LEFT OUTER JOIN %Table:SU5% SU5 ON U5_FILIAL = %xFilial:SU5%
		   AND U5_CODCONT = ABS_CONTAT
		   AND SU5.%notDel%
	   	
		 WHERE ABB_FILIAL = %xFilial:ABB%
		   AND ABB_ENTIDA = ' '
		   AND ABB.%notDel%

	EndSql
Else

	BeginSql Alias cAliasAT
		SELECT DISTINCT A1_NOME
		              , TFF_CONTRT
		              , TFF_CONREV
		              , AA1_CDFUNC
		              , AA1_NOMTEC
		              , AA1_FUNCAO
		              , RJ_DESC
		              , TFF_CARGO
		              , COALESCE(Q3_DESCSUM, '') AS Q3_DESCSUM
		              , ABB_CODTEC
		              , ABS_LOCAL
		              , ABS_DESCRI
		              , ABS_END
		              , ABS_BAIRRO
		              , ABS_CONTAT
		              , COALESCE(U5_CONTAT, '') AS U5_CONTAT
		              , COALESCE(U5_DDD, '') AS U5_DDD
		              , COALESCE(U5_FONE, '') AS U5_FONE
		              , ABB_TIPOMV
		              , COALESCE(TCU_DESC, '') AS TCU_DESC
		              , TFF_TURNO
		              , COALESCE(R6_DESC, '') AS R6_DESC
		              , TFL_DTINI
		              , TFL_DTFIM
		              , TFF_HORAIN
		              , TFF_HORAFI
		  FROM %Table:ABB% ABB

		  JOIN %Table:AA1% AA1 ON AA1_FILIAL = %xFilial:AA1%
		   AND AA1_CODTEC = ABB_CODTEC
		   AND AA1.%notDel%
		
		  JOIN %Table:ABQ% ABQ ON ABQ_FILIAL = %xFilial:ABQ%
   		   AND ABB_IDCFAL = ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM
		   AND ABQ.%notDel%
		   
		  LEFT OUTER JOIN %Table:TCU% TCU ON TCU_FILIAL = %xFilial:TCU%
		   AND TCU_COD = ABB_TIPOMV
		   AND TCU.%notDel%

		  JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
		   AND TFJ_CONTRT = %Exp:cNumContr%
		   AND TFJ_CONREV = %Exp:cRevContr%
		   AND TFJ.%notDel%

		  JOIN %Table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1%
		   AND A1_COD = TFJ_CODENT
		   AND A1_LOJA = TFJ_LOJA
		   AND SA1.%notDel% 
		   	
		  JOIN %table:TFF% TFF ON TFF_FILIAL = ABQ_FILTFF
		   AND TFF_CONTRT = TFJ_CONTRT
		   AND TFF_CONREV = TFJ_CONREV 
		   AND TFF_COD = ABQ_CODTFF
		   AND TFF.%notDel% 
		
		  LEFT OUTER JOIN %Table:SR6% SR6 ON R6_FILIAL = %xFilial:SR6%
		   AND R6_TURNO = TFF_TURNO
		   AND SR6.%notDel%

		  LEFT OUTER JOIN %Table:SQ3% SQ3 ON Q3_FILIAL = %xFilial:SQ3%
		   AND Q3_CARGO = TFF_CARGO
		   AND SQ3.%notDel%

		  JOIN %Table:SRJ% SRJ ON RJ_FILIAL = %xFilial:SRJ%
		   AND RJ_FUNCAO = TFF_FUNCAO
		   AND SRJ.%notDel%

		  JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
		   AND TFL_CONTRT = TFJ_CONTRT
		   AND TFL_CONREV = TFJ_CONREV
		   AND TFL_CODIGO = TFF_CODPAI
		   AND TFL.%notDel%

		  JOIN %Table:ABS% ABS ON ABS_FILIAL = %xFilial:ABS%
		   AND ABS_LOCAL = TFL_LOCAL
		   AND ABS.%notDel%

		  LEFT OUTER JOIN %Table:SU5% SU5 ON U5_FILIAL = %xFilial:SU5%
		   AND U5_CODCONT = ABS_CONTAT
		   AND SU5.%notDel%
	   	
		 WHERE ABB_FILIAL = %xFilial:ABB%
		   AND ABB_ENTIDA = ' '
		   AND ABB.%notDel%

	EndSql

ENDIF

DbSelectArea(cAliasAT)

// Preenche os dados do memorando
DO WHILE (cAliasAT)->(!Eof())

	Aadd(_aMemo,{(cAliasAT)->A1_NOME,;		//NOME DO CLIENTE
	             (cAliasAT)->ABS_DESCRI,;	//POSTO
	             (cAliasAT)->ABS_END,;		//ENDERECO
	             (cAliasAT)->ABS_BAIRRO,;	//BAIRRO
	             (cAliasAT)->U5_DDD,;		//DDD
	             ContactAGB((cAliasAT)->ABS_CONTAT),;	//TELEFONE (PRIMEIRO PADRÃO)
	             (cAliasAT)->U5_CONTAT,;	//CONTATO
	             (cAliasAT)->AA1_NOMTEC,;	//FUNCIONARIO
	             IIF(!Empty(cCodTec),_aAtend_[4],(cAliasAT)->TFF_HORAIN),;	//HORA INICIAL
	             IIF(!Empty(cCodTec),_aAtend_[6],(cAliasAT)->TFF_HORAFI),;	//HORA FINAL
	             (cAliasAT)->TFF_CONTRT,;	//CONTRATO
	             (cAliasAT)->TFF_CONREV,;	//REVISAO
	             (cAliasAT)->AA1_CDFUNC,;	//MATRICULA
	             (cAliasAT)->RJ_DESC,;		//FUNCAO
	             (cAliasAT)->Q3_DESCSUM,;	//CARGO
	             (cAliasAT)->TCU_DESC,;	//TIPO DE MOVIMENTACAO
	             (cAliasAT)->R6_DESC,;		//TURNO
	             IIF(!Empty(cCodTec),DTOS(_aAtend_[3]),(cAliasAT)->TFL_DTINI),;	//DATA INICIAL
	             IIF(!Empty(cCodTec),DTOS(_aAtend_[5]),(cAliasAT)->TFL_DTFIM),;	//DATA FINAL
	             (cAliasAT)->ABB_CODTEC,;	//TECNICO
	             (cAliasAT)->ABS_LOCAL,;    //21LOCAL
				 Alltrim(cObser)})   //22OBSERVACOES

	(cAliasAT)->(DbSkip())
END

DbSelectArea(cAliasAT)
(cAliasAT)->(DbCloseArea())

IF Len(_aMemo) > 0
	// Chama rotina de geracao memorando em HTML
	lRet := At330Memo(_aMemo, cAgenda)
ELSE
	Help( ' ', 1, 'TECA330', , STR0214, 1, 0 )	//"Não existem atendentes alocados"
ENDIF

RestArea(aAreaABB)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330Memo

Gera o memorando

@sample 	At330Memo(_aMemo,_cAgenda_)

@param		_aMemo    - vetor de dados
@param		_cAgenda_ - codigo da agenda

@return	lRet

@since		06/02/2015
@author	Serviços
@version	P12
/*/
//------------------------------------------------------------------------------//
Static Function At330Memo(_aMemo_, _cAgenda_)

Local lRet			:= .F.
Local nX			:= 0
Local cPathWF		:= "\samples\documents\memorando\"
Local cPath		:= "\memorando\"
Local cPathMArq	:= "memorando_arquivos\"
Local cArqHtm		:= "memorando.html"
Local oWF
Local _cRazao		:= ''
Local _cCnpj		:= ''
Local _cEnd		:= ''
Local _cTel		:= ''
Local _cFax		:= ''
Local cAliasM		:= ''
Local cPathLoc	 := StrTran(cPath,'\','/')
Local cPathAbs	 := StrTran(cPath,'\','/')
Local nRecnoSM0	:= SM0->(RecNo())
Local cPathSrv	:= ''
Local cFileJpg	:= ''
Local cPathFile	:= ''
Local aArea		:= GetArea()
Local cAlias		:= "PROTHEUS_REPOSIT"
Local cBmpPict	:= ""
Local cPath2		:= GetSrvProfString("Startpath","")
Local lFile
Local oDlg8
Local oBmp
Local cDest		:= "\memorando\fotos\"
Local cDirTemp	:= GetTempPath(.T.) + "fotos\"
Local cArqTmp		:= ""
Local lAchou		:= .F.
Local cShowLog	:= ""
Local cMemoHTM	:= ""
Local nFileHTM	:= 0

If	ExistDir( cPathWF )											.and.;
	ExistDir( cPathWF + cPathMArq )								.and.;
	File( cPathWF + cArqHtm )									.and.;
	File( cPathWF + cPathMArq + "colorschememapping.xml" )	.and.;
	File( cPathWF + cPathMArq + "filelist.xml" )				.and.;
	File( cPathWF + cPathMArq + "item0006.xml" )				.and.;
	File( cPathWF + cPathMArq + "props007.xml" )				.and.;
	File( cPathWF + cPathMArq + "themedata.thmx" )

	// cria o diretório que irá armazenar os memorandos
	FwMakeDir( cDest )

	// Dados da Empresa
	DbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	If SM0->(DBSeek(cEmpAnt+cFilAnt))
		_cRazao := SM0->M0_NOME
		_cCnpj  := Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
		_cEnd   := Alltrim(SM0->M0_ENDCOB) + ' ' + Alltrim(SM0->M0_CIDCOB) + ' ' + 'CEP: ' + Transform(SM0->M0_CEPCOB,"@R 99999-999") + ' ' + SM0->M0_ESTCOB
		_cTel   := SM0->M0_TEL
		_cFax   := SM0->M0_FAX
	EndIf

	DBGoTo(nRecnoSM0)

	For nX := 1 to Len(_aMemo_)
	
		lAchou := .F.

		// Inicializa a classe TWFProcess 
		CpyS2T('\samples\documents\memorando\'+cArqHtm,GetTempPath(.T.))
		Sleep(1500)
		oWF := TWFHTML():New( GetTempPath(.T.)+cArqHtm )
	
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))//RA_FILIAL, RA_MAT
		SRA->(DbSeek(xFilial("SRA")+_aMemo_[nX][13]))
	
		// Preenche as variaveis no HTML do corpo do formulário
		cBmpPict := Upper( AllTrim( SRA->RA_BITMAP)) 
		If !Empty(cBmpPict)
			If File(cDest+cBmpPict+".BMP") 
				lAchou := .T.
				cArqTmp := cBmpPict + ".BMP"
			ElseIf File(cDest+cBmpPict+".JPG")
				lAchou := .T.
				cArqTmp := cBmpPict + ".JPG"
			EndIf
		
			IF !lAchou
				cPathPict 	:= ( cPath2 + cBmpPict)
		
				DEFINE MSDIALOG oDlg8   FROM -1000000,-4000000 TO -10000000,-8000000  PIXEL 
				@ -10000000, -1000000000000 REPOSITORY oBmp SIZE -6000000000, -7000000000 OF oDlg8  
		
				// Verifica se a imagem existe no repositorio
				If oBMP:ExistBMP(cBmpPict)
				
					IF !Empty( cBmpPict := Upper( AllTrim( SRA->RA_BITMAP ) ) )
						lFile:=oBmp:Extract(cBmpPict, cPathPict)
						If lFile 
							If File(cPathPict+".BMP") 
								cPathFile := cPathPict + ".BMP"
								cArqTmp := cBmpPict + ".BMP"
							ElseIf File(cPathPict+".JPG")
								cPathFile := cPathPict + ".JPG"
								cArqTmp := cBmpPict + ".JPG"
							EndIf
						EndIf	
					EndIf	
				EndIf
				ACTIVATE MSDIALOG oDlg8 ON INIT (oBmp:lStretch := .T., oDlg8:End())
				
				// Copia para diretorio temporário
				CpyS2T( cPathFile, cDirTemp , .F. )
				// Deleta do diretorio do system
				FERASE( cPathFile )
				CpyT2S( cDirTemp + cArqTmp, cDest, .F.)
			ENDIF
			oWF:ValByName("cFoto"		, "<img src=" + '"fotos\' + cArqTmp + '"' + ' width="80" height="110"' + '/>')
		EndIf
		oWF:ValByName("cServidor"	, Alltrim(_cRazao))                                                                                           
		oWF:ValByName("cEndServ"		, Alltrim(_cEnd))  
		oWF:ValByName("cCnpjServ"	, _cCnpj)                                                                               
		oWF:ValByName("cTelServ"		, _cTel)                                                                                        
		oWF:ValByName("cFaxServ"		, _cFax)               
		oWF:ValByName("cData"		, Dtoc(dDataBase)) 
		oWF:ValByName("cHora"		, Substr(Time(),1,5))
		oWF:ValByName("cCliente"		, Alltrim(_aMemo_[nX][1]))
		oWF:ValByName("cPosto"		, Alltrim(_aMemo_[nX][2]))
		oWF:ValByName("cEndCli"		, Alltrim(_aMemo_[nX][3]))
		oWF:ValByName("cBaiCli"		, Alltrim(_aMemo_[nX][4]))
		oWF:ValByName("cTelCli"		, '('+_aMemo_[nX][5]+') ' + _aMemo_[nX][6])
		oWF:ValByName("cContato"		, Alltrim(_aMemo_[nX][7]))
		oWF:ValByName("cFunc"		, Alltrim(_aMemo_[nX][8]))
		oWF:ValByName("cHoraIni"		, _aMemo_[nX][9])
		oWF:ValByName("cHoraFim"		, _aMemo_[nX][10])
		oWF:ValByName("cContrato"	, _aMemo_[nX][11])
		oWF:ValByName("cRevisa"		, _aMemo_[nX][12])
		oWF:ValByName("cMatFunc"		, _aMemo_[nX][13])
		oWF:ValByName("cFuncao"		, Alltrim(_aMemo_[nX][14]))
		oWF:ValByName("cCargo"		, Alltrim(_aMemo_[nX][15]))
		oWF:ValByName("cTpMov"		, Alltrim(_aMemo_[nX][16]))
		oWF:ValByName("cTurno"		, Alltrim(_aMemo_[nX][17]))
		oWF:ValByName("cObs"		, Alltrim(_aMemo_[nX][22]))

		If ! Empty(_cAgenda_)
			cAliasM := GetNextAlias()
		
			BeginSql Alias cAliasM
				SELECT AA1_CDFUNC
	                , AA1_NOMTEC
				  FROM %table:ABB% ABB
			
				  JOIN %Table:AA1% AA1 ON AA1_FILIAL = %xFilial:AA1%
				   AND AA1_CODTEC = ABB_CODTEC
				   AND AA1.%notDel%
			   
				 WHERE ABB_FILIAL = %xFilial:ABB%
				   AND ABB_CODIGO = %Exp:_cAgenda_%
				   AND ABB.%notDel%
		
			EndSql

			DbSelectArea(cAliasM)
		
			Do While (cAliasM)->(!Eof())	
				oWF:ValByName("cMatSub"	, Alltrim((cAliasM)->AA1_CDFUNC))
				oWF:ValByName("cSubst"	, Alltrim((cAliasM)->AA1_NOMTEC))
				(cAliasM)->(DbSkip())
			EndDo
		
			DbSelectArea(cAliasM)
			(cAliasM)->(DbCloseArea())
		
		EndIf
	
		oWF:ValByName("cDtIni"		, DTOC(STOD(_aMemo_[nX][18])))
		oWF:ValByName("cDtFim"		, DTOC(STOD(_aMemo_[nX][19])))
	
		//salva em diretório local temporário
		//oWF:SaveFile( cPath + dtos(dDataBase) + '_' + _aMemo_[nX][11] + '_' + _aMemo_[nX][20] + '_' + _aMemo_[nX][21] + '.htm' )
		oWF:SaveFile( cPath + dtos(dDataBase) + '_' + _aMemo_[nX][21] + '.htm' )
	Next nX

	If MsgYesNo(	STR0215 + GetSrvProfString("ROOTPATH","/") + cPath + chr(13) + chr(10) +;
					STR0216 ) //"Os arquivos foram gerados no diretório: " # "Deseja visualizar os arquivos gerados?"

		For nX := 1 TO Len(_aMemo_)

			cPathAbs := cPathAbs + dtos(dDataBase) + '_' + _aMemo_[nX][21] + '.htm'
			cPathAbs := Replace(cPathAbs,"/","\")
		
			cPathAbs := Tc330Copy(cPathAbs,dtos(dDataBase) + '_' + _aMemo_[nX][21] + '.htm')
		
			shellExecute("Open",cPathAbs , " /k dir", "C:\", 1 ) 
		Next nX
	EndIf
Else

	cShowLog	:= STR0245+CRLF+STR0246+CRLF+CRLF						//"Não foi encontrada na estrutura de pastas do servidor a configuração necessária para a geração dos memorandos.""Não foi encontrada na estrutura de pastas do servidor a configuração necessária para a geração dos memorandos." ## "Contacte o administrador do sistema."
	cShowLog	+= STR0247+CRLF											//"Solução:"
	cShowLog	+= "1) "+STR0248+CRLF+"   "+AllTrim(cPathWF)+CRLF	//"Verifique o seguinte caminho de diretório:"
	cShowLog	+= "2) "+STR0249+" "+AllTrim(cArqHtm)+CRLF			//"Verifique nesse diretório a existência do arquivo:"
	cShowLog	+= "3) "+STR0248+CRLF+"   "+cPathWF + cPathMArq+CRLF	//"Verifique o seguinte caminho de diretório:"
	cShowLog	+= "4) "+STR0250+CRLF									//"Verifique nesse diretório a existência dos arquivos:"
	cShowLog	+= "   - colorschememapping.xml"+CRLF
	cShowLog	+= "   - filelist.xml"+CRLF
	cShowLog	+= "   - item0006.xml"+CRLF
	cShowLog	+= "   - props007.xml"+CRLF
	cShowLog	+= "   - themedata.thmx"+CRLF+CRLF
	cShowLog	+= STR0251   //"Caso encontre, em seu ambiente, alguma inconsistência na configuração descrita, favor providenciar os ajustes necessários para que a geração dos memorandos possa ocorrer."

	AtShowLog( cShowLog, STR0217 )	//"Memorando"
	lRet	:=	.F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330FilCt
Filtra os contratos/revisao.

@sample 	At330FilCt(_aAtenABB)

@param		_aAtenABB 	Array com dados dos atendentes

@return
@author	Serviços
@since		09/02/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At330FilCt(_aAtenABB_)

Local aAreaABB  := GetArea()
Local cAliasABB := ''
Local nX        := 0

FOR nX := 1 TO Len(_aAtenABB_)

	//Busca a revisao do contrato

	cAliasABB := GetNextAlias()

	BeginSql Alias cAliasABB

		SELECT DISTINCT TFF.TFF_CONTRT, TFF.TFF_CONREV
		  FROM %table:ABB% ABB
	
		  JOIN %table:ABQ% ABQ ON ABQ_FILIAL = %xFilial:ABQ%
		   AND ABQ.%notDel%
		   AND ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM = ABB_IDCFAL
		   	
		  JOIN %table:TFF% TFF ON TFF_FILIAL = %xFilial:TFF%
		   AND TFF_CONTRT = %Exp:_aAtenABB_[nX][1]%
		   AND TFF_COD = ABQ_CODTFF 
		   AND TFF.%notDel% 
		 
		 WHERE ABB_FILIAL = %xFilial:ABB%
		   AND ABB_CODIGO = %Exp:_aAtenABB_[nX][2]%
		   AND ABB_DTINI = %Exp:_aAtenABB_[nX][3]%
		   AND ABB_HRINI = %Exp:_aAtenABB_[nX][4]%
		   AND ABB_DTFIM = %Exp:_aAtenABB_[nX][5]%
		   AND ABB_HRFIM = %Exp:_aAtenABB_[nX][6]%
	EndSql

	DbSelectArea(cAliasABB)

	While (cAliasABB)->( !Eof() )
		// Rotina de geracao do memorando
		At330GerMem((cAliasABB)->TFF_CONTRT, (cAliasABB)->TFF_CONREV,'')
		(cAliasABB)->(DbSkip())
	End

	DbSelectArea(cAliasABB)
	(cAliasABB)->(DbCloseArea())
NEXT nX

RestArea(aAreaABB)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330VsRest
Visualiza o Atendente.

@sample 	At330VsRest(cCodAtend)

@param		ExpC1	Codigo do Atendente.

@return		ExpL	Verdadeiro.

@author	services
@since		14/10/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At330VsRest(cCodAtend)

Local lRetorno := .T. 		// Retorno na rotina.

If !Empty(cCodAtend)
	DbSelectArea("AA1")
	AA1->(DbSetOrder(1))//
	If AA1->(DbSeek(xFilial("AA1")+cCodAtend))
		lRetorno := .T.
		FWExecView(Upper(STR0221),"VIEWDEF.TECA012",1,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)    //"Restrições do atendente"
	Else
		MsgAlert(STR0157,STR0158) // "Selecione um atendente para visualizar."###"Atenção"
	EndIf
EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330GrvCus
Realiza a gravação do custo da alocação conforme o codigo da ABB_IDCFAL

@sample 	At330GrvCus(cIdcFal)
@param		ExpC1	Codigo do campo ABB_IDCFAL(Contrato+Item+Origem)

@author		services
@since		22/02/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At330GrvCus( cIdcFal, cCodTWZ, lRemAloc, cMsg )
Local lRetorno 	:= .T.
Local cCtrato 	:= Substr(cIdcFal,1,TAMSX3("TFF_CONTRT")[1])
Local aAreaABB  := ABB->(GetArea())
Local aAreaTWZ	:= TWZ->(GetArea())
Local cAliasABB := GetNextAlias()
Local cCodTFL	:= ""
Local cItem		:= ""
Local cOrcamen	:= ""
Local cProdut	:= ""
Local nCusto	:= 0

Default cCodTWZ	:= "" // esta variável indica quando é alteração ou exclusão de um lançamento
Default lRemAloc := .F. // para idenficar quando é remoção de alocação
Default cMsg	:= ""	

BeginSql Alias cAliasABB

	SELECT SUM(ABB_CUSTO) CUSTO, ABB.ABB_IDCFAL,ABB.ABB_LOCAL, TFF.TFF_COD, TFF.TFF_CODPAI, 
			TFL.TFL_CODPAI, ABQ.ABQ_PRODUT, ABQ.ABQ_CODTFF, ABB.ABB_CODTWZ
		FROM %table:ABB% ABB

		  INNER JOIN %table:ABQ% ABQ ON ABQ_FILIAL = %xFilial:ABQ%
		   AND ABQ.%notDel%
		   AND ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM = %Exp:cIdcFal%

		  JOIN %table:TFF% TFF ON TFF_FILIAL = ABQ.ABQ_FILTFF
		   AND TFF_CONTRT = %Exp:cCtrato%
		   AND TFF_COD = ABQ_CODTFF
		   AND TFF.%notDel%
		  
		  JOIN %table:TFL% TFL ON TFL_FILIAL = ABQ.ABQ_FILTFF
		   AND TFL_CODIGO = TFF_CODPAI
		   AND TFF.%notDel% 

		 WHERE ABB_FILIAL = %xFilial:ABB%
		   AND ABB.ABB_IDCFAL = %Exp:cIdcFal%
		   AND ABB.ABB_ATIVO = '1'
		   AND ABB.%notDel%

		GROUP BY ABB.ABB_IDCFAL,ABB.ABB_LOCAL, TFF.TFF_COD, TFF.TFF_CODPAI, 
				TFL.TFL_CODPAI, ABQ.ABQ_PRODUT, ABQ.ABQ_CODTFF, ABB.ABB_CODTWZ

EndSql

If Empty(cCodTWZ)
	cCodTWZ 	:= (cAliasABB)->ABB_CODTWZ
EndIf
cOrcamen	:= (cAliasABB)->TFL_CODPAI
cCodTFL		:= (cAliasABB)->TFF_CODPAI
cItem		:= (cAliasABB)->TFF_COD
cProdut		:= (cAliasABB)->ABQ_PRODUT

While (cAliasABB)->( !Eof() )
	nCusto		+= (cAliasABB)->CUSTO
	(cAliasABB)->(DbSkip())
End

If !Empty(cCodTWZ)
	If nCusto > 0
		// Atualiza o valor do custo na TWZ
		lRetorno := At995AtCus( cOrcamen, cCodTWZ, {{"TWZ_VLCUST", nCusto }}, .T. )
		If !lRetorno
			cMsg := STR0262 //"Problemas na atualização de custo na alocação do atendente"
		EndIf	
	Else
		DbSelectArea("TWZ")
		TWZ->( DbSetOrder( 1 ) )  // TWZ_FILIAL + TWZ_CODIGO
		If TWZ->( DbSeek( xFilial("TWZ") + cCodTWZ ) )
			cOrcamen := TWZ->TWZ_CODORC
			// Remove o registro
			lRetorno := At995ExcC( cOrcamen, cCodTWZ, .T.)
			If !lRetorno
				cMsg := STR0263 //"Problemas na exclusão de custo na alocação do atendente"
			EndIf	
		EndIf
	EndIf
ElseIf !lRemAloc .And. nCusto > 0
	//Gera o custo na tabela TWZ somente quando for inclusão de agenda
	cCodTWZ := At995Custo( cOrcamen, cItem, cCodTFL, cProdut, "1", nCusto, "TECA330", .T.)
	If Empty(cCodTWZ)
		lRetorno := .F.
		cMsg := STR0264 //"Problemas na geração de custo na alocação do atendente"
	EndIf
EndIf

//Atualiza os campos da ABB com a codigo do custo
At300CodTWZ(cCodTWZ,cIdcFal)

DbSelectArea(cAliasABB)
(cAliasABB)->(DbCloseArea())

RestArea(aAreaABB)
RestArea(aAreaTWZ)
Return lRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc} At300CodTWZ
Atualiza os campos da alocação(ABB) com o codigo do custo gerado

@sample 	At300CodTWZ(cCodTWZ,cIdcFal)
@param		ExpC1 - Codigo da tabela de custos(TWZ) que será atualizado
@param		ExpC2 - Codigo do campo ABB_IDCFAL(Contrato+Item+Origem)

@author		services
@since		22/02/2017
@version	P12
/*/
Static Function At300CodTWZ(cCodTWZ,cIdcFal)

Local cAliasABB := GetNextAlias()

BeginSql Alias cAliasABB
	SELECT ABB.R_E_C_N_O_ ABB_RECNO
	  FROM %table:ABB% ABB
	 WHERE ABB.ABB_FILIAL = %xFilial:ABB%
	   AND ABB.%NotDel% 
	   AND ABB.ABB_IDCFAL = %Exp:cIdcFal%
	   AND ABB.ABB_CODTWZ = ' ' 
	   AND ABB.ABB_CUSTO > 0
EndSql

While (cAliasABB)->( !Eof() )
	// Posiciona nos itens que sofrerão as atualizações
	ABB->( DbGoTo( (cAliasABB)->ABB_RECNO ) )
	ABB->(RecLock("ABB",.F.))
	ABB->ABB_CODTWZ := cCodTWZ
	ABB->(MsUnlock())
	(cAliasABB)->(DbSkip())
EndDo

DbSelectArea(cAliasABB)
(cAliasABB)->(DbCloseArea())

Return

/*/{Protheus.doc} At330HasTWZ
@descriptio 	Atualiza os campos da alocação(ABB) com o codigo do custo gerado
@sample 		At300CodTWZ(cCodTWZ,cIdcFal)
@version		P12
@author			josimar.assuncao
@since			06.03.2017
@param			cConfigAloc, caracter, configuração de alocação
@param			cCodTWZ, caracter, referência, variável para retorno da TWZ identificada
/*/
Function At330HasTWZ( cConfigAloc, cCodTWZ )
Local lFound := .F.
Local cQrySearch := ""

If !Empty( cConfigAloc )
	cQrySearch := GetNextAlias()
	cCodTWZ := ""

	BeginSQL Alias cQrySearch
		SELECT DISTINCT ABB_CODTWZ
		FROM %Table:ABB% ABB
		WHERE ABB_FILIAL = %xFilial:ABB%
			AND ABB_IDCFAL = %Exp:cConfigAloc%
			AND ABB_CODTWZ <> ' '
			AND ABB.%NotDel%
	EndSQL

	If (cQrySearch)->(!EOF())
		lFound := .T.
		cCodTWZ := (cQrySearch)->ABB_CODTWZ
	EndIf
	(cQrySearch)->(DbCloseArea())
EndIf

Return lFound

//------------------------------------------------------------------------------
Static Function Tc330Copy(cFileOri,cFileName)
	Local cFileDest := alltrim(GetTempPath(.T.)) 
	
	If substr(cFileDest,len(cFileDest),1) != "\"
		cFileDest += "\"
	EndIf
	cFileDest += cFileName
	
	CpyS2T("\memorando\" + cFileName,GetTempPath(.T.))
	Sleep(1500)
Return cFileDest

/*/{Protheus.doc} PerguntMemo
@description 	Função utilizada para evitar o MSGYESNO da pergunta de Gerar Memorando.
				Realizar a chamada PerguntMemo(.F.) para que o sistema não pergunte se
				deve ou não gerar memorando (o sistema irá considerar a resposta "Não")
@version		P12
@author		Mateus Boiani
@since			16/05/2018
/*/
Function PerguntMemo(lSetValue)

If VALTYPE(lSetValue) == 'L'
	lGeraMemo := lSetValue
EndIf

Return lGeraMemo

/*/{Protheus.doc} SetTipAloc
@description 	Função utilizada para setar o valor da variável estática cTipoAuto
@version		P12
@author			Guilherme Pimentel
@since			15/10/2018
/*/
Function SetTipAloc(cValue)
cTipoAuto := cValue
Return nil

