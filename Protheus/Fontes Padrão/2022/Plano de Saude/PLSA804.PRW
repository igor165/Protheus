#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA804.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA804
Funcao para abrir cadastro de Serviços Realizados
@author Oscar Zanin
@since 27/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA804()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9O')
oBrowse:SetDescription(FunDesc())
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 27/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0002 /*'Visualizar'*/ Action 'VIEWDEF.PLSA804' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'   */ Action 'VIEWDEF.PLSA804' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'   */ Action 'VIEWDEF.PLSA804' Operation 4 Access 0
Add Option aRotina Title STR0005 /*'Excluir'   */ Action 'VIEWDEF.PLSA804' Operation 5 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'  */ Action 'VIEWDEF.PLSA804' Operation 8 Access 0
Add Option aRotina Title STR0007 /*'Copiar'    */ Action 'VIEWDEF.PLSA804' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9O:= FWFormStruct(1,'B9O')

oModel := MPFormModel():New( 'PLSA804', , {|| PLSA804OK(oModel) } )		//Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterB9O',/*cOwner*/,oStrB9O)								//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterB9O')
oModel:SetDescription(FunDesc())												// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"B9O_FILIAL", "B9O_CODINT", "B9O_DESSER"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB9O:= FWFormStruct(2, 'B9O', {|cCampo| PLSA804CMP(cCampo)})

oView := FWFormView():New()										// Cria o objeto de View
oView:SetModel(oModel)											// Define qual Modelo de dados será utilizado
oView:AddField('FrmB9O' , oStrB9O,'MasterB9O' ) 				// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB9O', 100)						// Cria o Box que irá conter a View
oView:SetOwnerView('FrmB9O','BxB9O')							// Associa a View ao Box

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA804OK
Validar botão confirmar
@author Oscar Zanin
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA804OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9O' )
LOCAL cDescri  		:= ""
LOCAL cCodInt			:= ""
LOCAL nOpc				:= oModel:GetOperation()

If (nOpc <> 5) //Não para "Excluir"
	cDescri := oModelDetail:GetValue('B9O_DESSER')
	cCodInt := PLSINTPAD()

	B9O->(DbSelectArea("B9O"))
	B9O->(DbSetOrder(3)) // B9O_FILIAL + B9O_DESSER
	
	//Busca se a Descrição já foi cadastrada
	If (B9O->(MsSeek(XFilial("B9O") + cCodInt + cDescri)))
   		cMsg := STR0001 //"Serviço já cadastrado!"
   		Help( ,, 'HELP',, cMsg, 1, 0)
   		lRet := .F.
	EndIf

	B9O->(DbCloseArea())
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA804CMP
Tratamento para campos que não devem ir na View
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA804CMP(cCampo)

Local lRet	:= .T.

If cCampo == "B9O_CODINT"
	lRet := .F.
EndIf

If cCampo == "B9O_DESINT"
	lRet := .F.
EndIf

Return lRet