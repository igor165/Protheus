#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBA017.CH'


Function CTBA017()
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("CVS")
	oBrowse:SetDescription( STR0001 )  //"Cadastro de SCP"
	oBrowse:Activate()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author pauloc

@since 17/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel := Nil
	Local oStr1  := FWFormStruct(1, 'CVS')

	oModel := MPFormModel():New('CTBA017',/*PreValidacao*/,{ |oModel| CTB017TDOK(oModel)}/*PosValidacao*/,)
	oModel:SetDescription(STR0001)  //"Cadastro de SCP"

	oModel:addFields('ModelCVS', , oStr1)
	oModel:SetPrimaryKey({'CVS_FILIAL', 'CVS_IDTSCP'})

	oModel:getModel('ModelCVS'):SetOnlyQuery(.F.)
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author pauloc

@since 17/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel  := ModelDef()
	Local oStr1   := FWFormStruct(2, 'CVS')
	Local oView   := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('Master_CVS' , oStr1,'ModelCVS' )
	oView:EnableTitleView('Master_CVS' , STR0001 )  //"Cadastro de SCP"
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para criar do menu

@author guilherme.pimentel
@since 29/08/2013
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {} //Array utilizado para controlar opcao selecionada

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CTBA017" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CTBA017" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CTBA017" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CTBA017" OPERATION 5 ACCESS 3 //"Excluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CTBA017" OPERATION 8 ACCESS 0 //"Imprimir"
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para validar formulario de acordo com as regras do ECD

@author pauloc

@since 17/03/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function CTB017TDOK(oModel)
	Local lRet := .T.

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. ;//Incluir
		oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar

		lRet := !Empty( M->CVS_IDTSCP ) .And. !Empty( M->CVS_NOMSCP )

		If !lRet
			Help( ,, 'Help',, STR0007, 1, 0 )  //"Codigo/Nome SCP não preenchido."
		Endif

		//nao permitir mudar o codigo do SCP na alteracao
		If	lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar

			lRet := ( oModel:GetValue( 'ModelCVS', 'CVS_IDTSCP' ) == CVS->CVS_IDTSCP )

			If !lRet
				Help( ,, 'Help',, STR0008, 1, 0 )  //"Codigo SCP não pode ser alterado."
			Endif

		Endif

		//nao permitir incluir novo registro com CGC ja existente
		If	lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT

			lRet := CVS->( ! dbSeek( xFilial("CVS")+M->CVS_IDTSCP ) )

			If !lRet
				Help( ,, 'Help',, STR0009, 1, 0 )  //"Codigo SCP ja incluido."
			Endif

		Endif

		If lRet
			lRet := CTB017VldSCP( M->CVS_IDTSCP )
		EndIf
	Endif
Return(lRet)


//-------------------------------------------------------------------
/*{Protheus.doc}CTB017VldSCP
@author Eduardo Lima - Totvs
@since  02/02/2016
@version 11.8
*/
//-------------------------------------------------------------------
Static Function CTB017VldSCP(cSCP)
	Local lReturn :=.T.
	Local nX      := 0

	If Len(AllTrim(cSCP)) != 14
		Help(, , "Help", , STR0011, 1, 0)  //"Codigo deve conter 14 digitos"
		lReturn := .F.
	Else
		For nX := 1 To Len(cSCP)
			If !IsDigit(SubStr(cSCP, nX, 1))
				Help(, , "Help", , STR0012, 1, 0)  //"Os 14 digitos do codigo devem ser numeros"
				lReturn := .F.
				Exit
			Endif
		Next
	Endif
Return lReturn
