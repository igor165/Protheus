#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA811.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA811
Funcao para abrir cadastro de Tipo de Estabelecimento
@author Oscar Zanin
@since 27/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA811()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B1Z')
oBrowse:SetDescription(FunDesc())
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0002 /*'Visualizar'*/ Action 'VIEWDEF.PLSA811' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'   */ Action 'VIEWDEF.PLSA811' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'   */ Action 'VIEWDEF.PLSA811' Operation 4 Access 0
Add Option aRotina Title STR0005 /*'Excluir'   */ Action 'VIEWDEF.PLSA811' Operation 5 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'  */ Action 'VIEWDEF.PLSA811' Operation 8 Access 0
Add Option aRotina Title STR0007 /*'Copiar'    */ Action 'VIEWDEF.PLSA811' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since27/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB1Z:= FWFormStruct(1,'B1Z')

oModel := MPFormModel():New( 'PLSA811', , {|| PLSA811OK(oModel) } )		//Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterB1Z',/*cOwner*/,oStrB1Z)								//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterB1Z')
oModel:SetDescription(FunDesc())												// Adiciona a descrição do Modelo de Dados

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 27/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB1Z:= FWFormStruct(2, 'B1Z', { |cCampo| PLSA811CMP(cCampo) })

oView := FWFormView():New()										// Cria o objeto de View
oView:SetModel(oModel)											// Define qual Modelo de dados será utilizado
oView:AddField('FrmB1Z' , oStrB1Z,'MasterB1Z' ) 				// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB1Z', 100)						// Cria o Box que irá conter a View
oView:SetOwnerView('FrmB1Z','BxB1Z')							// Associa a View ao Box

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA811OK
Validar botão confirmar
@author Oscar Zanin
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA811OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB1Z' )
LOCAL cDescri  		:= ""
LOCAL cCodInt			:= ""
LOCAL nOpc				:= oModel:GetOperation()

If (nOpc <> 5) //Não para "Excluir"
	cDescri := oModelDetail:GetValue('B1Z_DESEST')
	cCodInt := PLSINTPAD()

	B1Z->(DbSelectArea("B1Z"))
	B1Z->(DbSetOrder(2)) // B1Z_FILIAL + B1Z_DESEST
	
	//Busca se a Descrição já foi cadastrada
	If (B1Z->(MsSeek(XFilial("B1Z") + cCodInt + cDescri)))
   		cMsg := STR0001 //"Tipo de Estabelecimento já Cadastrado!"
   		Help( ,, 'HELP',, cMsg, 1, 0)
   		lRet := .F.
	EndIf

	B1Z->(DbCloseArea())
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA811CMP
Tratamento para campos que não devem ir na View
@author Oscar Zanin
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA811CMP(cCampo)

Local lRet	:= .T.

If cCampo == "B1Z_CODINT"
	lRet := .F.
EndIf

If cCampo == "B1Z_DESINT"
	lRet := .F.
EndIf

Return lRet