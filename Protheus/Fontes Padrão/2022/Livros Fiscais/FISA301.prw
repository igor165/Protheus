#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*{Protheus.doc} FISA301
Rotina para gerenciamento de C�digos da tabela 5.7 de Motivo do Resssarcimento de ICMS ST

@author pereira.weslley

@since 24/10/2019
@version P01*/
Function FISA301()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription('C�digo de Motivo do Resssarcimento de ICMS ST')
    oBrowse:SetAlias('CIF')
    oBrowse:SetUseFilter(.T.)
    oBrowse:DisableDetails()

    oBrowse:Activate()

Return NIL
//-------------------------------------------------------------------

/*{Protheus.doc} MenuDef
Fun��o MVC gen�rica com as op��es de menu

@return aRotina - Array com as op��es de menu

@author pereira.weslley

@since 24/10/2019
@version P01*/
Static Function MenuDef()
Return FWMVCMenu("FISA301")


//-------------------------------------------------------------------

/*{Protheus.doc} ModelDef
Fun��o MVC gen�rica do model

@return oModel - Objeto do Modelo MVC

@author pereira.weslley

@since 24/10/2019
@version P01*/
Static Function ModelDef()
    Local oModel
    Local oStruCIF := FWFormStruct(1, 'CIF')

    oModel := MPFormModel():New('CIFMASTER',, {|oModel| ValidForm(oModel)})

    oModel:AddFields('CIFMASTER',, oStruCIF)
    oModel:SetPrimaryKey({"CIF_FILIAL", "CIF_CODIGO", "CIF_DTINI"})
    oModel:SetDescription('Cadastro de Motivo do Resssarcimento de ICMS ST')

Return oModel
//-------------------------------------------------------------------

/*{Protheus.doc} ViewDef
Fun��o MVC gen�rica do View

@return oView - Objeto da View MVC

@author pereira.weslley

@since 24/10/2019
@version P01*/
Static Function ViewDef()
    Local oView    := FWFormView():New()
    Local oModel   := FWLoadModel('FISA301')
    Local oStruCIF := FWFormStruct(2, 'CIF')

    oView:SetModel(oModel)
    oView:AddField('VIEW_CIF', oStruCIF, 'CIFMASTER')

    oView:CreateHorizontalBox('TELA', 100)
    oView:SetOwnerView('VIEW_CIF', 'TELA')

Return oView
//-------------------------------------------------------------------

/*/{Protheus.doc} ValidForm
Valida��o das informa��es digitadas para inclus�o e altera��o do registro

@return lRet - .T. = Altera��o/Inclus�o com sucesso na CIF
               .F. = N�o foi poss�vel altera��o/Inclus�o na CIF

@author pereira.weslley

@since 24/10/2019
@version P01*/
Static Function ValidForm(oModel)
	Local lRet		  := .T.
	Local nRecno2	  := 0
	Local cCodigo	  := oModel:GetValue('CIFMASTER','CIF_CODIGO')
	Local cDtini	  := oModel:GetValue('CIFMASTER','CIF_DTINI')
	Local nOperation  := oModel:GetOperation()
    Local nRecno      := CIF->(Recno())
    Local cMsg        := "A combina��o de C�digo e Data In�cio deve ser diferente da inserida"

	//CIF_FILIAL, CIF_CODIGO, CIF_DTINI
 	If nOperation == 3 //Inclus�o de informa��es
		CIF->(DbSetOrder(1))
		If CIF->(DbSeek(xFilial("CIF")+cCodigo+DToS(cDtini)))
			Help(Nil, Nil, "Help",, "Registro j� cadastrado", 1, 0,,,,,, {cMsg})
			lRet := .F.
		EndIf	
	EndIf
	If nOperation == 4 //Altera��es
		CIF->(DbSetOrder(1))
		If CIF->(DbSeek(xFilial("CIF")+cCodigo+DToS(cDtini)))
			nRecno2 := CIF->(Recno())
			If nRecno2 <> nRecno
				Help(Nil, Nil, "Help",, "Registro j� cadastrado", 1, 0,,,,,, {cMsg})
				lRet := .F.
			EndIf				
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------