#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA820.ch'

//------------------------------------------------------------------------------
/*{Protheus.doc} LOJA820
Cadastro De/Para das Formas de Pagamento
@param   	     
@author     andy.pudja
@version    P12
@since      26/03/2018
@return     Nil
/*/
//------------------------------------------------------------------------------
Function LOJA820()
Local aArea		:= GetArea()
Local oBrowse

Private aRotina	:= Menudef()	

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("MHI")
oBrowse:SetDescription(STR0001)
oBrowse:Activate()
RestArea(aArea)
	
Return ( Nil )

//------------------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menudef
@param   	     
@author     andy.pudja
@version    P12
@since      26/03/2018
@return     aRot
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRot := {}
	
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.LOJA820' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.LOJA820' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.LOJA820' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.LOJA820' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

//------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Menudef
@param   	     
@author     andy.pudja
@version    P12
@since      26/03/2018
@return     oModel
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStructMHI := FWFormStruct(1, "MHI")

oModel := MPFormModel():New("LOJA820",/*bPre*/, {||tValidOk()},/*bCommit*/,/*bCancel*/)
oModel:AddFields("MASTERMHI",/*cOwner*/,oStructMHI)
oModel:SetPrimaryKey({})
oModel:SetDescription(STR0001)
oModel:GetModel("MASTERMHI"):SetDescription(STR0001)
	
Return ( oModel )

//------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Menudef
@param   	     
@author     andy.pudja
@version    P12
@since      26/03/2018
@return     oView
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel := FWLoadModel("LOJA820")
Local oStructMHI := FWFormStruct(2, "MHI")  
Local oView := Nil

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_MHI", oStructMHI, "MASTERMHI")
oView:CreateHorizontalBox("TELA",100)
oView:EnableTitleView("MASTERMHI", " " )  
oView:SetCloseOnOk({||.T.})
oView:SetOwnerView("VIEW_MHI","TELA")
	
Return ( oView )

//------------------------------------------------------------------------------
/*{Protheus.doc} tValidOk
Menudef
@param   	     
@author     andy.pudja
@version    P12
@since      26/03/2018
@return     lRet
/*/
//------------------------------------------------------------------------------
Static Function tValidOk()
Local oModel 	 := FwModelActive()
Local nOperation := oModel:GetOperation()
Local lRet 		 := .T.
Local cAliPri 	 := GetNextAlias()
Local cAliTro 	 := GetNextAlias()
Local cAliMHI 	 := GetNextAlias()
Local uCodFrm    := "24" // Tabela 24 Forma de Pagamento em SX5
Local uCodPri 	 := oModel:GetValue("MASTERMHI","MHI_FRMPRI")
Local uCodTro 	 := oModel:GetValue("MASTERMHI","MHI_FRMTRO")

If ( nOperation ==  MODEL_OPERATION_INSERT .Or. nOperation ==  MODEL_OPERATION_UPDATE)
	
	//Fazer consistência como exemplo abaixo se o Registro do MHI estiver sendo já utilizado em alguma outra tabela do Protheus
	BeginSQL Alias cAliPri // Consistir MHI_FRMPRI
			SELECT DISTINCT X5_TABELA
				FROM %TABLE:SX5% SX5
			WHERE SX5.D_E_L_E_T_ = ''
				  AND SX5.X5_TABELA = %EXP:uCodFrm%
				  AND SX5.X5_CHAVE  = %EXP:uCodPri%
				  AND SX5.X5_FILIAL = %EXP:xFilial("SX5")% 
	EndSQl
	If ( ( (cAliPri)->( eof() ) ) )
		cTitle      := STR0002 // "Códigos incorretos"
		cMsgProb    := STR0005 // "Código da Forma de Pagamento De inválido
		cMsgSolu    := STR0007 // "Escolha um Código de Forma de Pagamento que existe na Tabela SX5!" 
		lRet := .F.
	EndIf

	(cAliPri)->(dbCloseArea())
	
	If ( lRet )
		BeginSQL Alias cAliTro // Consistir MHI_FRMTRO
			SELECT DISTINCT X5_TABELA
				FROM %TABLE:SX5% SX5
				WHERE SX5.D_E_L_E_T_ = ''
					  AND SX5.X5_TABELA = %EXP:uCodFrm%
					  AND SX5.X5_CHAVE  = %EXP:uCodTro%
					  AND SX5.X5_FILIAL = %EXP:xFilial("SX5")% 
				
		EndSQl
		If ( ( (cAliTro)->( eof() ) ) )
			cTitle      := STR0002 // "Códigos incorretos"
			cMsgProb    := STR0006 // "Código da Forma de Pagamento Para inválido "
			cMsgSolu    := STR0007 // "Escolha um Código de Forma de Pagamento que existe na Tabela SX5!" 
				lRet := .F.
			EndIf

			(cAliTro)->(dbCloseArea())
 
		EndIf
		
		If ( lRet )
			BeginSQL Alias cAliMHI // Consistir MHI_FRMPRI + MHI_FRMTRO
			SELECT *
				FROM %TABLE:MHI% MHI
				WHERE MHI.D_E_L_E_T_ = ''
					  AND MHI.MHI_FRMPRI = %EXP:uCodPri%
					  AND MHI.MHI_FRMTRO  = %EXP:uCodTro%
					  AND MHI.MHI_FILIAL = %EXP:xFilial("MHI")% 
				
		EndSQl
		If ( .NOT. ( (cAliMHI)->( eof() ) ) )
			cTitle      := STR0002 // "Códigos incorretos"
			cMsgProb    := STR0008 // "Registro de Troca Forma de Pagamento De e Para já cadastrado"
			cMsgSolu    := STR0009 // "Escolha Códigos de Forma de Pagamento De e Para ainda não cadastrados em MHI" 
			lRet := .F.
		EndIf

		(cAliMHI)->(dbCloseArea())

	EndIf

EndIf
If ( nOperation ==  MODEL_OPERATION_INSERT .Or. nOperation ==  MODEL_OPERATION_UPDATE)
EndIf

If ( !lRet )
    oModel:GetModel():SetErrorMessage(oModel:GetModel():GetId(),,oModel:GetModel():GetId(),,cTitle,cMsgProb,cMsgSolu)
EndIf

Return ( lRet )