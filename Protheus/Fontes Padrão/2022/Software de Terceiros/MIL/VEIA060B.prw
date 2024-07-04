#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA060B.CH"

#DEFINE lDebug .f.

/*/{Protheus.doc} VEIA060B
Cancelar Pedido de Venda

@author Rubens
@since 01/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VEIA060B()

	Local lRetorno
	Local oModel060B

	Private l060BAuto := .f. // x060BAuto

	If VRJ->VRJ_STATUS == "R"
		FMX_HELP("VA060BERR001",STR0001) // "Pedido reprovado."
		Return
	EndIf
	If VRJ->VRJ_STATUS == "C"
		FMX_HELP("VA060BERR001",STR0002) // "Pedido cancelado."
		Return
	EndIf

	If VA060B0043_AtendimentoCriado(VRJ->VRJ_PEDIDO)
		Return
	EndIf

	If l060BAuto
		nOpcao := nOpcCancAuto
		aMotCancel := aMotCancAuto
	Else
	EndIf

	CursorWait()
	oModel060B := FWLoadModel( 'VEIA060' )
	oModel060B:SetOperation( MODEL_OPERATION_UPDATE )
	If ! oModel060B:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf
	CursorArrow()

	lRetorno := VA060B0013_Cancelar(oModel060B)

	oModel060B:DeActivate()

Return lRetorno

Function VA060B0013_Cancelar(oModel060B)

	Local cFasePrx := ""
	Local nOpcao := 0
	Local aMotCancel := {}

	If VA060B0023_SemPermissao(oModel060B, @cFasePrx, @nOpcao)
		Return .f.
	EndIf

	If cFasePrx == "C"
		If l060BAuto
			nOpcao := 1
			If Len(aMotCancAuto) > 0
				aMotCancel := aClone(aMotCancAuto)
			EndIf
		Else
			nOpcao := 0
			If MsgYesNo(STR0003) // "Deseja cancelar pedido de venda?"
				nOpcao := 1

				aMotCancel := OFA210MOT("000001",,oModel060B:GetValue("MODEL_VRJ","VRJ_FILIAL"),oModel060B:GetValue("MODEL_VRJ","VRJ_PEDIDO"),.F.) // Filtro da consulta do motivo de Cancelamentos ( 000001 = Atendimento de Veiculos )
				If len(aMotCancel) <= 0
					Return .f.
				EndIf
			EndIf
			
		EndIf
	EndIf

	If nOpcao == 0
		Return .t.
	EndIf

	VA060B0033_ProcCancelamento(oModel060B, cFasePrx, nOpcao, aMotCancel)
Return .t.


Function VA060B0023_SemPermissao(oModel060B, cFasePrx, nOpcao)
	
	Local cCancVAI := "222222" // Permissao: ( 0=Nao faz nada / 1=Volta / 2=Cancela/Volta /3=Cancela)
	Local cOptVAICanc
	Local lCancVAI := .t.
	Local cFaseAtu

	cCancVAI := FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_CANVEI","?")

	cMsg := STR0012 // "Usuário sem premissão para Cancelar/Voltar Pedido de Venda."
	cFaseAtu := oModel060B:GetValue("MODEL_VRJ","VRJ_STATUS")

	Do Case
		Case cFaseAtu == "A" ; cOptVAICanc := substr(cCancVAI,1,1) // A = Em Aberto
		Case cFaseAtu == "P" ; cOptVAICanc := substr(cCancVAI,2,1) // P = Pend.Aprovacao
		Case cFaseAtu == "O" ; cOptVAICanc := substr(cCancVAI,3,1) // O = Pre-Aprovado
		Case cFaseAtu == "L" ; cOptVAICanc := substr(cCancVAI,4,1) // L = Aprovado
		Case cFaseAtu == "R" ; cOptVAICanc := substr(cCancVAI,5,1) // R = Reprovado
		Case cFaseAtu == "F" ; cOptVAICanc := substr(cCancVAI,6,1) // F = Finalizado
	EndCase

	Do Case
		Case cFaseAtu == "A" // Aberto
		If cOptVAICanc $ "2/3" // VAI - Permite Cancelar/Voltar ou Permite somente Cancelar
			nOpcao   := 2   // Cancelar
			cFasePrx := "C" // Cancelar o Atendimento
		Else
			lCancVAI := .f. // Usuario sem permissao
			If cOptVAICanc == "1" // VAI - Permite Voltar
				cMsg := STR0013 // Impossivel Voltar o Atendimento, pois o mesmo se encontra Aberto!
			EndIf
		EndIf

	Case cFaseAtu $ "POLR" // Pendente Aprovacao / Pre-Aprovado / Aprovado / Reprovado

		Do Case
		// VAI - Permite somente Cancelar
		Case cOptVAICanc == "3"
			nOpcao   := 2   // Cancelar
			cFasePrx := "C" // Cancelar o Atendimento

		// VAI - Permite Cancelar/Voltar
		Case cOptVAICanc == "2"
			If ! l060BAuto
				nOpcao := Aviso(STR0006,"- " + STR0007+ CRLF +"- " + STR0009, { STR0010 , STR0011 } ) // "Cancelamento do Pedido de Venda" / "Voltar Pedido de Venda para Aberto" / "Cancelar Pedido de Venda" / "Voltar" / "Cancelar"
			EndIf

			If nOpcao == 1 // Voltar para Aberto
				cFasePrx := "A" 
			ElseIf nOpcao == 2 // Cancelar
				cFasePrx := "C" 
			EndIf

		// VAI - Permite Voltar
		Case cOptVAICanc == "1"
			nOpcao   := 1   // Voltar para Aberto
			cFasePrx := "A" // Voltar o Atendimento para Aberto
		OtherWise
			lCancVAI := .f. // Usuario sem permissao
		EndCase

	Case cFaseAtu == "F" // Finalizado

		cOptVAICanc := substr(cCancVAI,6,1)

		Do Case
		// VAI - Permite somente Cancelar
		Case cOptVAICanc == "3"
			nOpcao   := 2   // Cancelar
			cFasePrx := "C" // Cancelar o Atendimento

		// VAI - Permite Cancelar/Voltar
		Case cOptVAICanc == "2"

			If ! l060BAuto
				nOpcao := Aviso(STR0006,"- "+STR0008+CHR(13)+CHR(10)+"- "+STR0009, { STR0010 , STR0011 } ) // Cancelamento do Atendimento / Voltar Atendimento para Aprovado / Cancelar Total o Atendimento / Voltar / Cancelar
			EndIf
			If nOpcao == 1 // Voltar para Aprovado
				cFasePrx := "L" // Voltar o Atendimento para Aprovado
			ElseIf nOpcao == 2 // Cancelar
				cFasePrx := "C" // Cancelar o Atendimento
			EndIf


		// VAI - Permite Voltar
		Case cOptVAICanc == "1"
			nOpcao   := 1   // Voltar para Aprovado
			cFasePrx := "L" // Voltar o Atendimento para Aprovado

		// Usuario sem permissao
		OtherWise
			lCancVAI := .f. 
		EndCase
	EndCase

Return (! lCancVAI)


Function VA060B0033_ProcCancelamento(oModel060B, cFasePrx, nOpcao, aMotCancel)

	Local oModelVRJ := oModel060B:GetModel("MODEL_VRJ")
	Local oModelVRK := oModel060B:GetModel("MODEL_VRK")

	Local cVRJFilial := oModelVRJ:GetValue("VRJ_FILIAL")
	Local cVRJPedido := oModelVRJ:GetValue("VRJ_PEDIDO")

	CursorWait()

	Begin Transaction
	Begin Sequence
	
		If cFasePrx == "C"
			OFA210VDT("000001",aMotCancel[1],"9",cVRJFilial,cVRJPedido,aMotCancel[4])

			oModel060B:SetValue("MODEL_VRJ","VRJ_MOTCAN", aMotCancel[1])
			oModel060B:SetValue("MODEL_VRJ","VRJ_DATCAN", dDataBase)

			VEIVM130TAR( cVRJPedido , "9", "3", cVRJFilial, .f., oModelVRJ:GetValue("VRJ_TIPVEN") , VA0600203_FormatINMarca(oModelVRK)) // Tarefas: 1-Gravacao / 3-Pedido de Venda Atacado
		EndIf

		VEIVM130DEL( cVRJPedido ,cFasePrx, cVRJFilial, "3" ) // "Deleta" Tarefas que deverao ser executadas novamente.

		// Volta Pedido para Aberto
		If cFasePrx == "A"
			
		EndIf
		
		// Volta Pedido para Aprovado
		If cFasePrx == "L"
		EndIf

		// TO-DO Verificar como trabalhar com atendimentos quando o pedido ja possui atendimento gerado ...
		//

		oModel060B:SetValue("MODEL_VRJ","VRJ_STATUS", cFasePrx)
		If oModel060B:VldData()
			oModel060B:CommitData()
		Else
			Break
		EndIf

	Recover
		DisarmTransaction()
		MsUnlockAll()
		MostraErro()

		Return .f.

	End Sequence
	End Transaction

	CursorArrow()


Return

Static Function VA060B0043_AtendimentoCriado(cNumPedido)

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
			AND VRK.VRK_NUMTRA <> ' '
			AND VRK.VRK_CANCEL IN ('0',' ') 
			AND VRK.%notDel% 
	EndSql
	If (cAliasSChassi)->CONTADOR <> 0
		FMX_HELP("VA060BERR002",STR0004, STR0005) // "Pedido com atendimento criado." / "Cancele o(s) atendimento(s) e tente novamente."
		lRetorno := .t.
	End
	(cAliasSChassi)->(dbCloseArea())

Return lRetorno