#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc}  F0101001
Aprova ou rejeita Strings de sugestões para traduções.
@Author Lucas Graglia
@Since  24/07/2017
@Project Rússia
/*/
User Function F0101001()
	
	Local oMark    := Nil
	Local oCol		 := Nil
	Local aColunas := {}
	Local aStruct  := {"ZA1_TEXT", "ZA1_NEWTEX", "ZA1_MANUAL"}
	Local nX       := 1
	
	For nX := 1 To len(aStruct)
		oCol := FWBrwColumn():New()
		oCol:SetTitle(RetTitle(aStruct[nX]))
		oCol:SetType("C")
		oCol:SetSize(60)
		oCol:SetData(&("{|| ZA1->" + aStruct[nX] + "}"))
		AAdd(aColunas,oCol)
	Next
	
	oMark := FWMarkBrowse():New()
	oMark:SetMenudef('F0101001')
	oMark:SetAlias("ZA1")
	oMark:SetDescription("Strings Approval")
	oMark:SetFieldMark("ZA1_MARK")
	oMark:SetFilterDefault("ZA1->ZA1_STATUS = '3'")
	oMark:SetOnlyFields({""})
	oMark:SetColumns(aColunas)
	oMark:Activate()
	
Return

Static Function MenuDef()
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina TITLE "Approve" ACTION "U_F0101002('APPROVED')" OPERATION OP_ALTERAR    ACCESS 0
	ADD OPTION aRotina TITLE "Reject"  ACTION "U_F0101002('REJECTED')" OPERATION OP_ALTERAR    ACCESS 0
	ADD OPTION aRotina TITLE "View"    ACTION "VIEWDEF.FlavorEdt"      OPERATION OP_VISUALIZAR ACCESS 0
	
Return(aRotina)

/*/{Protheus.doc} F0101002
@Author Lucas Graglia Cardozo
@Since  24/07/2017
@Obs    Função envia as strings para aprovação ou rejeição.
/*/
User Function F0101002(cAcao)
	
	Local cMsg   := ""
	Local cMarca := oMark:Mark()
	Local cAlias := GetNextAlias()
	
	If !MsgYesNo("Confirm?")
        Return
	EndIf
		
    BeginSQL Alias cAlias
        SELECT R_E_C_N_O_ ZA1REC
            FROM %Table:ZA1%
            WHERE ZA1_STATUS = '3'
            AND %NotDel%
    EndSQL
    
    While !(cAlias)->(EoF())
        ZA1->(DbGoTo((cAlias)->ZA1REC))
        
        If oMark:IsMark(cMarca)
            If cAcao == 'APPROVED'
                RegisSug()
            Else
                LimpaSug()
            EndIf
        EndIf
        
        (cAlias)->(DbSkip())
    EndDo
    
    (cAlias)->(DbCloseArea())
    
    If cAcao == 'APPROVED'
        cMsg := 'Approval sucessfully completed!'
    ElseIf cAcao == 'REJECTED'
        cMsg := 'Rejection sucessfully completed!'
    EndIf
    
    MsgAlert(cMsg)
		
Return

/*/{Protheus.doc} RegisSug
Registra a Sugestão como Tradução caso seja aprovada.
@Author Lucas Graglia Cardozo
@Since  24/07/2017
/*/
Static Function RegisSug()
	
	RecLock("ZA1", .F.)
	ZA1->ZA1_STATUS := "4"
	ZA1->ZA1_HIST   := U_ZA1Hist(" Suggestion '" + ZA1->ZA1_MANUAL + "' approved. Original text: '" + ZA1->ZA1_NEWTEX + "'")
	ZA1->ZA1_NEWTEX := ZA1->ZA1_MANUAL
	ZA1->ZA1_APROV  := "1"
	ZA1->ZA1_MANUAL := ""
	ZA1->ZA1_ATUSX  := "2"
	ZA1->(MsUnLock())
	
Return

/*/{Protheus.doc} LimpaSug
Limpa a Sugestão caso seja rejeitada.
@Author Lucas Graglia Cardozo
@Since  24/07/2017
/*/
Static Function LimpaSug()
	
	RecLock("ZA1", .F.)
	
	If Empty(ZA1->ZA1_NEWTEX)
		ZA1->ZA1_STATUS := "1"
	Else
		ZA1->ZA1_STATUS := "4"
	EndIf
	
	ZA1->ZA1_HIST   := U_ZA1Hist(" Suggestion '" + ZA1->ZA1_MANUAL + "' rejected.")
	ZA1->ZA1_MANUAL := ""
	ZA1->ZA1_APROV  := "2"
    ZA1->(MsUnLock())
	
Return

// Russia_R5
