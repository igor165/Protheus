#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA060A.CH"

#DEFINE lDebug .f.

/*/{Protheus.doc} VEIA060A
Avancar Pedido de Venda até Faturamento

@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VEIA060A(cAlias,nReg,nOpc)

	Local lRetorno
	Local oModel060A

	Local cFaseInter := ""

	If VRJ->VRJ_STATUS == "R"
		FMX_HELP("VA060AERR007",STR0001) // "Pedido reprovado."
		REturn
	EndIf
	If VRJ->VRJ_STATUS == "C"
		FMX_HELP("VA060AERR008",STR0002) // "Pedido cancelado."
		REturn
	EndIf

	If VA060A0123_PedidoSemItem(VRJ->VRJ_PEDIDO) .or. VA060A0103_ItemSemChassi(VRJ->VRJ_PEDIDO) .or. VA060A0113_ItemSemValor(VRJ->VRJ_PEDIDO) .or. VA060A0133_NegociacaoInvalida(VRJ->VRJ_PEDIDO)
		Return
	EndIf

	If ! MsgYesNo(STR0003) // "Deseja avançar pedido?"
		Return
	EndIf

	CursorWait()
	oModel060A := FWLoadModel( 'VEIA060' )
	oModel060A:SetOperation( MODEL_OPERATION_UPDATE )
	If ! oModel060A:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf
	CursorArrow()

	lRetorno := VA060A0013_Avancar(oModel060A, cFaseInter)

	oModel060A:DeActivate()

Return lRetorno


Function VA060A0013_Avancar(oModel060A, cFaseInter)

	Local nPos
	Local oModelVRK
	Local lContinua

	cFaseAte := VA060A00_3_GetFase() // "AX1PXOXLXFX" // X=Chamada do Ponto de Entrada entre as Fases

	cFaseAtu := oModel060A:GetValue("MODEL_VRJ","VRJ_STATUS")
	If cFaseAtu == "R" // Reprovado
		cFaseAtu := "1" // Validar novamente Limite Credito / Minimo Comercial e passar para Pendente Aprovacao
	ElseIf cFaseAtu == "F" // Finalizado
		lContinua := .f.
		// Verifica se existe algum item sem atendimento
		oModelVRK := oModel060A:GetModel("MODEL_VRK")
		For nPos := 1 to oModelVRK:Length()
			oModelVRK:GoLine(nPos)
			If ! Empty(oModelVRK:GetValue("VRK_NUMTRA")) .or. oModelVRK:GetValue("VRK_CANCEL") == "1" .or. oModelVRK:isDeleted()
				Loop
			EndIf
			lContinua := .t.
			Exit
		Next nPos

		If lContinua == .f. 
			FMX_HELP("VA060AERR001",STR0004) // "O pedido de venda já está finalizado."
			return .f.
		EndIf
	EndIf

	nPos := At(oModel060A:GetValue("MODEL_VRJ","VRJ_STATUS"),cFaseAte)
	If nPos < 1
		nPos := 1
	EndIf

	// Se o pedido nao estiver com STATUS A (Aberto), avanca uma fase automaticamente
	If ! (cFaseAtu $ "A/F")
		nPos ++
	EndIf

	VA060A0023_PercorreFases(oModel060A, nPos, cFaseInter)

Return .t.

Function VA060A0023_PercorreFases(oModel060A, nPos, cFaseInter)

	Local oModelVRJ := oModel060A:GetModel("MODEL_VRJ")
	Local oModelVRK := oModel060A:GetModel("MODEL_VRK")
	Local nCntFor
	Local lVerificar := .t.
	Local lInterExecAuto := .f.

	// Monta string com as marcas informadas no pedido...
	cMarcasIN := VA0600203_FormatINMarca(oModelVRK)
	//

	For nCntFor := nPos to Len(cFaseAte)
		
		lInterrompe := .f.
		
		cFaseAtu := Subs(cFaseAte,nCntFor,1) // "AX1PXOXLXFX" // X=Chamada do Ponto de Entrada entre as Fases

		If cFaseAtu $ "A1POLF" .and. lVerificar
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificar se o(s) Veiculo(s) esta(o): VENDIDO ou EM REMESSA em TODAS as FASES (A1POLF) do Atendimento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! VA060A0093_ValidaVeiculos(oModelVRK)
				Return .f.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificar se o Cliente esta Bloqueado em TODAS as FASES (A1POLF) do Atendimento                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! VXI001VLCLI(oModelVRJ:GetValue("VRJ_CODCLI"), oModelVRJ:GetValue("VRJ_LOJA"))
				Return .f.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama Ponto de Entrada ( Customizacao antes de cada fase do Atendimento )                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If ExistBlock("VX001AFA")
			//	lInterrompe := ExecBlock("VX001AFA",.f.,.f.,{VV9->VV9_NUMATE,VV9->VV9_STATUS})
			//	If lInterrompe
			//		Return .f.
			//	EndIf
			//EndIf

			lVerificar := .f.
		
		EndIf
		
		
		Do Case
			
			Case cFaseAtu == "A" // ATENDIMENTO ABERTO
				VA060A0033_FaseA(oModelVRJ, cMarcasIN)
				
			Case cFaseAtu == "1" // Checar Limite de Credito do Cliente
				If ! VA060A0043_Fase1(oModelVRJ)
					Return .f.
				EndIf
				
			Case cFaseAtu == "P" // ATENDIMENTO PENDENTE APROVACAO
				If ! VA060A0053_FaseP(oModel060A, oModelVRJ, cMarcasIN)
					Return .f.
				EndIf
				
			Case cFaseAtu == "O" // ATENDIMENTO PRE-APROVADO
				If ! VA060A0063_FaseO(oModel060A, oModelVRJ, cMarcasIN)
					Return .f.
				EndIf
				
			Case cFaseAtu == "L" // ATENDIMENTO APROVADO
				If ! VA060A0073_FaseL(oModel060A, oModelVRJ, cMarcasIN)
					Return .f.
				EndIf
				
			Case cFaseAtu == "F" // ATENDIMENTO FINALIZADO
				If ! VA060A0083_FaseF(oModel060A, oModelVRJ, cMarcasIN)
					Return .f.
				EndIf

			OtherWise
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama Ponto de Entrada ( Customizacao X apos cada fase do Atendimento )  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//If lVX001DFA
				//	lInterrompe := ExecBlock("VX001DFA",.f.,.f.,{VV9->VV9_NUMATE,VV9->VV9_STATUS})
				//EndIf
				
				If lInterExecAuto
					Return .t.
				EndIf


		EndCase

		If cFaseAtu == cFaseInter
			lInterExecAuto := .t.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sair do Laco das Fases do Atendimento      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lInterrompe
			Return .f.
		EndIf
		
	Next	
Return .t.

Static Function VA060A0033_FaseA(oModelVRJ, cMarcasIN)
	Begin Transaction
	VEIVM130TAR(oModelVRJ:GetValue("VRJ_PEDIDO"), "1", "3", oModelVRJ:GetValue("VRJ_FILIAL"), .f., oModelVRJ:GetValue("VRJ_TIPVEN") , cMarcasIN) // Tarefas: 1-Gravacao / 3-Pedido de Venda Atacado
	End Transaction
Return .t. 

Static Function VA060A0043_Fase1(oModelVRJ)
	If "V" $ GetMv("MV_CHKCRE") // Veiculos
		If ! FGX_AVALCRED( oModelVRJ:GetValue("VRJ_CODCLI"), oModelVRJ:GetValue("VRJ_LOJA") , oModelVRJ:GetValue("VRJ_VALTOT") ,.t.)
			Help("  ",1,"LIMITECRED")
			Return .f.
		EndIf
	EndIf
Return .T.

Static Function VA060A0053_FaseP(oModel060A, oModelVRJ, cMarcasIN)
	Begin Transaction
	VEIVM130TAR(oModelVRJ:GetValue("VRJ_PEDIDO"), "4", "3", oModelVRJ:GetValue("VRJ_FILIAL"), .f., oModelVRJ:GetValue("VRJ_TIPVEN") , cMarcasIN) // Tarefas: 4-Pendente Aprovacao / 3-Pedido de Venda Atacado
	VA060A0203_AtuFase(oModel060A, cFaseAtu)
	End Transaction
Return .T.


Static Function VA060A0063_FaseO(oModel060A, oModelVRJ, cMarcasIN)
	Local nRet := -1
	//If VX002DTTIT(VV9->VV9_NUMATE) // Valida as Datas dos Titulos
	//	nRet := VEIXX013(VV9->VV9_NUMATE,1,lXI001Auto) // Pre-Aprovacao
	//	If MsgYesNo("Pré-aprovar pedido?")
			nRet := 1
	//	EndIf
	If nRet > 0
		Begin Transaction
		If nRet == 1 // Pre-Aprovou
			VEIVM130TAR(oModelVRJ:GetValue("VRJ_PEDIDO"), "5", "3", oModelVRJ:GetValue("VRJ_FILIAL"), .f., oModelVRJ:GetValue("VRJ_TIPVEN") , cMarcasIN) // Tarefas: 5-Pre-Aprovado / 3-Pedido de Venda Atacado
			If ! lInterrompe
				VA060A0203_AtuFase(oModel060A, cFaseAtu)
			EndIf
		Else // Reprovou a Pre-Aprovacao
			VA060A0203_AtuFase(oModel060A, "R")
			lInterrompe := .t.
		EndIf
		End Transaction
	Else // Cancelou a Pre-Aprovacao
		FMX_HELP("VA060AERR002",STR0005) // "Pedido de venda pendente de Pré-Aprovação."
		Return .f.
	EndIf
Return .T.

Static Function VA060A0073_FaseL(oModel060A, oModelVRJ, cMarcasIN)
	Local nRet := -1

	If ! VEIVM130TAR(oModelVRJ:GetValue("VRJ_PEDIDO"),"0A", "3", oModelVRJ:GetValue("VRJ_FILIAL"), .f., oModelVRJ:GetValue("VRJ_TIPVEN") , cMarcasIN) // 0A-Verifica/Valida na Aprovacao / 3-Pedido de Venda Atacado
		Return .f.
	EndIf

	// Janela de Aprovacao //
	//nRet :=  VEIXX013(VV9->VV9_NUMATE,2,lXI001Auto) 
	//If MsgYesNo("Aprovar pedido?")
		nRet := 1
	//EndIf
	If nRet > 0
		If ! MsgYesNo(STR0006) // "Pedido Aprovado?"
			nRet := 2
		EndIf

		Begin Transaction

		// Aprovou //
		If nRet == 1
			VEIVM130TAR(oModelVRJ:GetValue("VRJ_PEDIDO"),"6","3",oModelVRJ:GetValue("VRJ_FILIAL"), .f., oModelVRJ:GetValue("VRJ_TIPVEN"), cMarcasIN) // Tarefas: 6-Aprovado / 1-Atendimento
			// Reserva do Veiculo na Fase 4-Aprovado
			//For nPosVVA := 1 to len(aVVAs)
			//	If !Empty(aVVAs[nPosVVA,1]) // Possui VVA_CHAINT
			//		VEIXX004(nOpc,VV9->VV9_NUMATE,aVVAs[nPosVVA,1],"4") 
			//	EndIf
			//Next
			// 
			If ! lInterrompe
				VA060A0203_AtuFase(oModel060A, cFaseAtu)
			EndIf
			
		// Reprovou a Aprovacao //
		Else 
			VA060A0203_AtuFase(oModel060A, "R")
			lInterrompe := .t.
		EndIf

		End Transaction

	// Cancelou a Aprovacao // 
	Else 
		FMX_HELP("VA060AERR003",STR0007) // "Pedido pendente de Aprovação."
		Return .f.
	EndIf

	
Return .t.

Static Function VA060A0083_FaseF(oModel060A, oModelVRJ, cMarcasIN)
	
	Local nPosVVA
	Local oModelVRK := oModel060A:GetModel("MODEL_VRK")

	For nPosVVA := 1 to oModelVRK:Length()

		oModelVRK:GoLine(nPosVVA)
		If ! Empty(oModelVRK:GetValue("VRK_NUMTRA")) .OR. oModelVRK:GetValue("VRK_CANCEL") == "1"
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao do Veiculo                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Empty(oModelVRK:GetValue("VRK_CHAINT"))
			If ! VEIXX012(2,,oModelVRK:GetValue("VRK_CHAINT"),oModelVRK:GetValue("VRK_CODTES"),Space(TamSX3("VV9_NUMATE")[1])) // Validar Veiculo
				Return .f.
			EndIf
		EndIf
			
	Next

	If ! VEIVM130TAR(oModelVRJ:GetValue("VRJ_PEDIDO"),"0F", "3", oModelVRJ:GetValue("VRJ_FILIAL") , .f., oModelVRJ:GetValue("VRJ_TIPVEN"), cMarcasIN) // 0F-Verifica/Valida na Finalizacao / 3-Pedido de Venda Atacado
		Return .f.
	EndIf

	If ! MsgYesNo(STR0008) // "Deseja gerar atendimento para os itens do pedido?"
		Return .f.
	EndIf

	Begin Transaction

	If ! VA0600183_IntegraVEIXX002(oModel060A)
		DisarmTransaction()
		Return .f.
	EndIf

	VEIVM130TAR(oModelVRJ:GetValue("VRJ_PEDIDO"),"2", "3", oModelVRJ:GetValue("VRJ_FILIAL"), .f., oModelVRJ:GetValue("VRJ_TIPVEN") , cMarcasIN) // 2-Finalizacao / 3-Pedido de Venda Atacado
	VA060A0203_AtuFase(oModel060A, cFaseAtu)
	
	End Transaction

	// Avanca atendimentos para Pronto para Faturar 
	VA0600283_ProcFaturamento(oModel060A, "L")
	//
	

Return .t.




Static Function VA060A0093_ValidaVeiculos(oModelVRK)

	Local lRet     := .t.
	Local nLinhaAtual  := 0

	For nLinhaAtual := 1 TO oModelVRK:Length()
		
		oModelVRK:GoLine(nLinhaAtual)

		If ! Empty(oModelVRK:GetValue("VRK_NUMTRA")) .or. oModelVRK:GetValue("VRK_CANCEL") == "1"
			Loop
		EndIf
		
		If ! Empty(oModelVRK:GetValue('VRK_CHAINT')) // Possui CHAINT
			lRet := VXI00101_ValidaVeiculo( oModelVRK:GetValue('VRK_CHAINT') )
			If !lRet
				Exit
			EndIf
		EndIf
	Next

Return lRet

Static Function VA060A0203_AtuFase(oModel060A, cFaseAtu)
	oModel060A:SetValue("MODEL_VRJ","VRJ_STATUS", cFaseAtu)
	If oModel060A:VldData()
		//ConOut( "VRJ_STATUS " + cFaseAtu)
		oModel060A:CommitData()
		oModel060A:DeActivate()
		oModel060A:Activate()
	EndIf
Return .t.




Static Function VA060A00_3_GetFase()
	Local cFases := "AX1PXOXLXFX"// X=Chamada do Ponto de Entrada entre as Fases
Return cFases


Static Function VA060A0103_ItemSemChassi(cNumPedido)

	Local cAliasSChassi := "TVRKSC"
	Local lRetorno := .f.

	// Será permitido avanco do pedido sem chassi...
	Return .f.

	BeginSQL Alias cAliasSChassi
		
		COLUMN CONTADOR AS NUMERIC(10,0)

		SELECT COUNT(*) CONTADOR
		FROM 
			%table:VRK% VRK
		WHERE
			VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_PEDIDO = %exp:cNumPedido%
			AND VRK.VRK_CANCEL IN ('0',' ') 
			AND VRK.VRK_CHAINT = ' '
			AND VRK.%notDel% 
	EndSql
	If (cAliasSChassi)->CONTADOR <> 0
		FMX_HELP("VA060AERR004",STR0009, STR0016) // "Existe um ou mais itens do pedido sem um chassi relacionado." / "Altere o pedido e relacione chassi para o itens sem chassi."
		lRetorno := .t.
	End
	(cAliasSChassi)->(dbCloseArea())

Return lRetorno

Static Function VA060A0113_ItemSemValor(cNumPedido)

	Local cAliasSChassi := "TVRKSC"
	Local lRetorno := .f.

	BeginSQL Alias cAliasSChassi
		
		COLUMN CONTADOR AS NUMERIC(10,0)

		SELECT COUNT(*) CONTADOR
		FROM 
			%table:VRK% VRK
		WHERE
			VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_PEDIDO = %exp:cNumPedido%
			AND VRK.VRK_CANCEL IN ('0',' ') 
			AND ( VRK.VRK_VALMOV = 0 OR VRK.VRK_VALTAB = 0 )
			AND VRK.%notDel% 
	EndSql
	If (cAliasSChassi)->CONTADOR <> 0
		FMX_HELP("VA060AERR005",STR0010, STR0011) // "Existe um ou mais itens do pedido sem valor de tabela ou valor de movimento informado.","Altere o pedido e informe valor de tabela/movimento no item do pedido."
		lRetorno := .t.
	End
	(cAliasSChassi)->(dbCloseArea())

Return lRetorno

Static Function VA060A0123_PedidoSemItem(cNumPedido)

	Local cAliasSChassi := "TVRKSC"
	Local lRetorno := .f.

	BeginSQL Alias cAliasSChassi
		
		COLUMN CONTADOR AS NUMERIC(10,0)

		SELECT COUNT(*) CONTADOR
		FROM 
			%table:VRK% VRK
		WHERE
			VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_PEDIDO = %exp:cNumPedido%
			AND VRK.VRK_CANCEL IN ('0',' ') 
			AND VRK.%notDel% 
	EndSql
	If (cAliasSChassi)->CONTADOR == 0
		FMX_HELP("VA060AERR006",STR0012, STR0013) // "Pedido sem item válido.","Altere o pedido e informe um item."
		lRetorno := .t.
	End
	(cAliasSChassi)->(dbCloseArea())

Return lRetorno

Static Function VA060A0133_NegociacaoInvalida(cNumPedido)

	Local cAliasSChassi := "TVRKSC"
	Local lRetorno := .f.

	BeginSQL Alias cAliasSChassi
		
		COLUMN CONTADOR AS NUMERIC(10,0)

		SELECT COUNT(*) CONTADOR
		FROM (
			SELECT
				VRK_PEDIDO, VRK_ITEPED, VRK_VALVDA, SUM(VRL_E1VALO) VRL_E1VALO
			FROM %table:VRK% VRK
			JOIN %table:VRL% VRL  ON VRK.VRK_FILIAL = VRL.VRL_FILIAL
										AND VRK.VRK_PEDIDO = VRL.VRL_PEDIDO
										AND VRK.VRK_ITEPED = VRL.VRL_ITEPED
										AND VRL.VRL_CANCEL IN (' ', '0')
										AND VRL.%notDel% 
			WHERE
				VRK.VRK_FILIAL = %xFilial:VRK%
				AND VRK.VRK_PEDIDO = %exp:cNumPedido%
				AND VRK.VRK_CANCEL IN ('0',' ') 
				AND VRK.%notDel% 
			GROUP BY
				VRK.VRK_PEDIDO, VRK.VRK_ITEPED, VRK.VRK_VALVDA, VRL.VRL_PEDIDO, VRL.VRL_ITEPED
		) TEMP
		WHERE
			TEMP.VRK_VALVDA <> TEMP.VRL_E1VALO AND TEMP.VRL_E1VALO <> 0

	EndSql
	If (cAliasSChassi)->CONTADOR <> 0
		FMX_HELP("VA060AERR009", STR0014, STR0015) // "A soma das parcelas da negociação é diferente do valor de venda do veículo.","Altere o pedido e corrija a negociação do ítem."
		lRetorno := .t.
	End
	(cAliasSChassi)->(dbCloseArea())

Return lRetorno
