#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCPA105.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} PCPA105
Tela de cadastro de família técnica

@author Lucas Konrad França
@since 07/10/2013
@version P12
/*/
//------------------------------------------------------------------
Function PCPA105()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CZL')
	oBrowse:SetDescription( STR0001 ) //Família Técnica
	oBrowse:Activate()
Return NIL

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Camada Model do MVC.

@author  Lucas Konrad França
@since   07/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruCZL := FWFormStruct( 1, 'CZL' )
	Local oModel
	oModel := MPFormModel():New( 'PCPA105', /*bPre*/, {|oModel| posValid(oModel)}/*bPost*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'CZLMASTER', /*cOwner*/, oStruCZL )
	oModel:SetDescription( STR0001 ) //Família Técnica
	oModel:SetPrimaryKey({"CZL_CDFATD"})
Return oModel

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada View do MVC.

@author  Lucas Konrad França
@since   07/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel( 'PCPA105' )
	Local oStruCZL := FWFormStruct( 2, 'CZL' )
	Local oView
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_CZL', oStruCZL, 'CZLMASTER' )
Return oView

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author  Lucas Konrad França
@since   07/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCPA105' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCPA105' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCPA105' OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCPA105' OPERATION 5 ACCESS 0 //Excluir
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCPA105' OPERATION 8 ACCESS 0 //Imprimir
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.PCPA105' OPERATION 9 ACCESS 0 //Copiar
Return aRotina

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA105VCD
Função de validação do código da família técnica (CZL_CDFATD)

@author  Lucas Konrad França
@since   07/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA105VCD()
	Local lRet := .T.

	dbSelectArea("CZL")
	CZL->(dbSetOrder(1))
	If CZL->(dbSeek(xFilial("CZL")+M->CZL_CDFATD))
		Help( ,, 'Help',, STR0008, 1, 0 ) //Família técnica já cadastrada.
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} posValid
Função de pós validação do formulário.

@author  Lucas Konrad França
@since   07/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function posValid(oModel)

	Local nOp  := oModel:GetOperation()
	Local lRet := .T.

	If nOp == 5
		dbSelectArea("CZG")
		CZG->(dbSetOrder(4))
		If CZG->(dbSeek(xFilial("CZG")+oModel:GetValue("CZLMASTER","CZL_CDFATD")))
			Help( ,, 'Help',, STR0009, 1, 0 ) //Família técnica já utilizada em uma ficha técnica, não pode ser excluída.
			lRet := .F.
		Else
			dbSelectArea("SB5")
			SB5->(dbSetOrder(6))
			If SB5->(dbSeek(xFilial("SB5")+oModel:GetValue("CZLMASTER","CZL_CDFATD")))
				Help( ,, 'Help',, STR0010, 1, 0 ) //Família técnica já utilizada em um produto, não pode ser excluída.
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

