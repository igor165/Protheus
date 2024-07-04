#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGC010.CH"

/*{Protheus.doc} OGX015
(Rotina chamada via FwExecView que irá apresentar a
tela de Confirmação, Atualização e Cancelamento do Take-Up)
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
*/
Function OGX015()	
Return

/*{Protheus.doc} ViewDef
(View chamada através do FwExecView da rotina OGX014)
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/
Static Function ViewDef()
	Local oView    	:= FWFormView():New()
	Local oModel		:= FwLoadModel("AGRA720")
	Local oStruDXP	:= FwFormStruct(2, "DXP", {|cCampo| AllTrim(cCampo) $ "DXP_CODIGO,DXP_DATAGD,DXP_HORAGD,DXP_CLAEXT,DXP_CNOEXT,DXP_CLAINT,DXP_CNOINT,DXP_OBSAGE"})
							
	oStruDXP:SetProperty("DXP_CODIGO" , MVC_VIEW_CANCHANGE, .F.)
	
	oStruDXP:RemoveField("DXP_DATA")
	oStruDXP:SetNoFolders(.T.)
	
	oView:SetModel(oModel)
			
	oView:AddField("VIEW_DXP", oStruDXP, "DXPMASTER")
				
	oView:CreateHorizontalBox('BOXDXP', 100)//Remessa
				
	oView:SetOwnerView("VIEW_DXP", "BOXDXP")
		
	oView:SetAfterViewActivate({|oView| OGX015VAC(oView)}) // Seta o bloco de pós ativação da View
	
	If _lClickAc // Variavel de controle que verifica se a rotina foi chamada ao editar um item do agendamento ou marcando um novo agendamento
		oView:addUserButton(STR0060, 'MAGIC_BMP',{|oView| OGX015CANC(oView)}, STR0064, , {MODEL_OPERATION_UPDATE, MODEL_OPERATION_DELETE}) // # "Cancelar Agendamento" # "Cancela o agendamento de Take-Up"
	EndIf
	
	oView:SetCloseOnOk( {||.T.} )
	
Return (oView)

/*{Protheus.doc} OGX015GRA
(Função de validação do botão Confirmar ou Atualizar agendamento)
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
@param oView, objeto, (View Ativa)
@param cHoraIni, character, (Ação recebida, "bOk" = Ok do botão)
@return ${return}, ${.T. - Validado, .F. - Reprovado}
*/
Function OGX015GRA(oView, cAcao)
	
	Local nIt := 0
	Local oViewAct := FWViewActive()
		
	If Empty(oView:GetModel():GetModel("DXPMASTER"):GetValue("DXP_DATAGD"))
	   	Help('', 1, "OGC0100006") // #O campo Data.Agend não foi informado.
	   	Return .F.
	ElseIf oView:GetModel():GetModel("DXPMASTER"):GetValue("DXP_DATAGD") < dDataBase
		Help('', 1, "OGC0100008") // #A data de agendamento não pode ser menor que a data atual.
		Return .F.
	ElseIf Empty(oView:GetModel():GetModel("DXPMASTER"):GetValue("DXP_HORAGD"))
	  	Help('', 1, "OGC0100007") //#O campo Hora.Agend não foi informado.
	  	Return .F.
	EndIf
	   	
	For nIt := 1 To Len(_aItensAgd)
	   If STOD(_aItensAgd[nIt][2]) ==  oView:GetModel():GetModel("DXPMASTER"):GetValue("DXP_DATAGD");
	   		.AND. AllTrim(_aItensAgd[nIt][3]) == AllTrim(oView:GetModel():GetModel("DXPMASTER"):GetValue("DXP_HORAGD"));
	   		.AND. AllTrim(_aItensAgd[nIt][1]) != oView:GetModel():GetModel("DXPMASTER"):GetValue("DXP_CODIGO")   			
	   		Help('', 1, "OGC0100010") // # Já existe um agendamento com o mesmo período informado.
	   		Return .F.
	   EndIf
	next nIt
	
	If oView:GetOperation() == MODEL_OPERATION_INSERT   
   		_cCodRes := oView:GetModel():GetModel("DXPMASTER"):GetValue("DXP_CODIGO") // Atribui o código da reserva a ser criada ou atualizada
   	EndIf
   	oViewAct:SetModified(.t.) 
      														
Return .T.


/*{Protheus.doc} OGX015CANC
(Função de ação do botão Cancelar Agendamento)
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${.T. = Aplica o refresh da View, .F. = Não aplica o refresh da View}
*/
Static Function OGX015CANC(oView)
	
	Local lRet := .T.
	
	If !MsgYesNo(STR0065) // #"Deseja cancelar o agendamento do Take-Up ?"
		Return lRet
	Else
		lRet := .F.
	EndIf
	
	// Limpa os campos de DATA DO AGENDAMENTO, HORA DO AGENDAMENTO e CLASSIFICADORES DO TAKE-UP		
	oView:GetModel():GetModel("DXPMASTER"):ClearField("DXP_DATAGD") 
	oView:GetModel():GetModel("DXPMASTER"):ClearField("DXP_HORAGD")
	oView:GetModel():GetModel("DXPMASTER"):ClearField("DXP_CLAEXT")
	oView:GetModel():GetModel("DXPMASTER"):ClearField("DXP_CLAINT")
	oView:GetModel():GetModel("DXPMASTER"):ClearField("DXP_OBSAGE")
	
   	oView:ButtonOkAction(.T.) // Executa a ação de Ok do botão gerando a atualização.
   				
Return lRet

/*{Protheus.doc} OGX015VAC
(Função de Pós ativação da View)
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/
Static Function OGX015VAC(oView)
	
	Local lRet 		:= .T.
	Local oModel 		:= oView:GetModel() // Obtem o modelo ativo
	Local oModelDXP 	:= oModel:GetModel("DXPMASTER") // Obtem o submodelo DXPMASTER
	
	If oView:GetOperation() == MODEL_OPERATION_INSERT // Se for inserção preenche os campos necessários para criação da reserva
		oModelDXP:SetValue("DXP_DATA", Date())
		oModelDXP:SetValue("DXP_TIPRES", '1')
		oModelDXP:SetValue("DXP_SAFRA", Alltrim(Posicione("NJR",1,FwXFilial("NJR")+(_cAliasBrw)->NNY_CODCTR, "NJR_CODSAF")))
		oModelDXP:SetValue("DXP_CLIENT", Posicione("NJ0", 1, FwXFilial("NJ0") + (_cAliasBrw)->NJR_CODENT + (_cAliasBrw)->NJR_LOJENT, "NJ0_CODCLI"))
		oModelDXP:SetValue("DXP_LJCLI", Posicione("NJ0", 1, FwXFilial("NJ0") + (_cAliasBrw)->NJR_CODENT + (_cAliasBrw)->NJR_LOJENT, "NJ0_LOJCLI"))
		oModelDXP:SetValue("DXP_CODCTP", (_cAliasBrw)->NNY_CODCTR)
		oModelDXP:SetValue("DXP_ITECAD", (_cAliasBrw)->NNY_ITEM)
		oModelDXP:SetValue("DXP_CLACOM", Posicione("NJR",1,FwXFilial("NJR")+(_cAliasBrw)->NNY_CODCTR, "NJR_TIPALG"))	
	EndIf
	
	oModelDXP:SetValue("DXP_DATAGD", _dData) // Atribui a Data enviada pela widget de calendário
	oModelDXP:SetValue("DXP_HORAGD", _cHoraIni) // Atribui a Hora enviada pela widget de calendário
	
	oView:SetModified() // Seta a view como modificada, pois foram realizadas alterações no model
	oView:Refresh() // Atualiza a view			
Return lRet