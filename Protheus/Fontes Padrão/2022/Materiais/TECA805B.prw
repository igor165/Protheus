#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "TECA805B.CH"

/*/{Protheus.doc} TECA805B
	Fonte com as funções desenvolvidas para uso na execução do checklist
/*/
Function TECA805B()
Return

/*/{Protheus.doc} At805HrAtu
	Função para atualizar o valor para o horímetro de saída a ser chamado no checklist
/*/
Function At805HrAtu(oMdl, cValMarc, cTpChk)
Local lRet := .F.
Local oMdlTEWCab := oMdl:GetModel():GetModel("TEWMASTER")
Local cFilOri := oMdlTEWCab:GetValue("TEW_FILBAT")
Local cNS := oMdlTEWCab:GetValue("TEW_BAATD")
Local cPrdAA3 := At820FilPd( oMdlTEWCab:GetValue("TEW_PRODUT"),  oMdlTEWCab:GetValue("TEW_FILIAL"), oMdlTEWCab:GetValue("TEW_FILBAT") )

If AtPosAA3( cFilOri + cNS, cPrdAA3 )
	If Empty(oMdl:GetValue('TWF_CODUSR'))
		If cTpChk == "1" 
			lRet := At970AtSep()
		ElseIf cTpChk == "2"
			lRet := At970AtRet()
		EndIf
	Else
		// quando já está executado (usuário preenchido) não executa novamente
		lRet := .T.
	EndIf
Else
	Help(' ',1,"At805HrAtu",,STR0001,2,0,,,,,,;  // "Equipamento não encontrado"
							i18n(STR0002,;  // "Verifique se existe a combinação: Fil. Origem[#1], Produto[#2], Núm. Série[#3]"
							{ cFilOri, cPrdAA3, cNS} ) )
EndIf

Return lRet

/*/{Protheus.doc} At805HrDes
	Função para atualizar o valor para o horímetro de retorno a ser chamado no checklist
/*/
Function At805HrDes(oMdl, cValMarc, cTpChk)
Local lDesfeito := .F.
Local oAtuHoras := Nil
Local lContinua := .T.
Local oAtuTWT   := Nil
Local oMdlTEWCab := oMdl:GetModel():GetModel("TEWMASTER")
Local cFilOri := oMdlTEWCab:GetValue("TEW_FILBAT")
Local cNS := oMdlTEWCab:GetValue("TEW_BAATD")
Local cPrdAA3 := At820FilPd( oMdlTEWCab:GetValue("TEW_PRODUT"),  oMdlTEWCab:GetValue("TEW_FILIAL"), oMdlTEWCab:GetValue("TEW_FILBAT") )

If AtPosAA3( cFilOri + cNS, cPrdAA3 )

	If !Empty(oMdl:GetValue('TWF_CODUSR'))
		
		oAtuHoras := FwLoadModel('TECA970')
		oAtuHoras:SetOperation(MODEL_OPERATION_UPDATE)
		lContinua := oAtuHoras:Activate()
		oAtuTWT := oAtuHoras:GetModel('TWTDETAIL')
		
		// Procura pela linha de saída ou retorno inserida : TWTDETAIL
		// TWT_CODMV  : TEW_CODMV
		// TWT_MOTIVO : 0=Saída / 9=Retorno
		// TWT_TPLCTO : 1=Saída para Locação / 3=Retorno de Locação
		lContinua := ( ( cTpChk == "1" .And. oAtuTWT:SeekLine( {{'TWT_CODMV',TEW->TEW_CODMV},{'TWT_MOTIVO','0'},{'TWT_TPLCTO','1'}} ) ) .Or. ;
						( cTpChk == "2" .And. oAtuTWT:SeekLine( {{'TWT_CODMV',TEW->TEW_CODMV},{'TWT_MOTIVO','9'},{'TWT_TPLCTO','3'}} ) ) )
		
		lContinua := lContinua .And. oAtuTWT:DeleteLine()
		lContinua := lContinua .And. oAtuHoras:VldData() .And. oAtuHoras:CommitData()
		
		If !( lDesfeito := lContinua )
			
			If oAtuHoras:HasErrorMessage()
				AtErroMvc( oAtuHoras )
				MostraErro()
			EndIf
		EndIf
		
	Else
		// quando já está executado (usuário preenchido) não executa novamente
		lDesfeito := .T.
	EndIf
Else
	Help(' ',1,"At805HrAtu",,STR0001,2,0,,,,,,;  // "Equipamento não encontrado"
							i18n(STR0002,;  // "Verifique se existe a combinação: Fil. Origem[#1], Produto[#2], Núm. Série[#3]"
							{ cFilOri, cPrdAA3, cNS} ) )
EndIf

Return lDesfeito
