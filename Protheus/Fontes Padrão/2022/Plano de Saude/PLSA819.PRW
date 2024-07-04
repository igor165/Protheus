#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA819.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA819
Funcao para abrir cadastro de Mensagens do Portal
@author Oscar Zanin
@since 09/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA819()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BMV')
oBrowse:SetDescription(FunDesc())
oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 09/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0002 /*'Visualizar' */Action 'VIEWDEF.PLSA819' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'    */Action 'VIEWDEF.PLSA819' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'    */Action 'VIEWDEF.PLSA819' Operation 4 Access 0
Add Option aRotina Title STR0005 /*'Excluir'    */Action 'VIEWDEF.PLSA819' Operation 5 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'   */Action 'VIEWDEF.PLSA819' Operation 8 Access 0
Add Option aRotina Title STR0007 /*'Copiar'     */Action 'VIEWDEF.PLSA819' Operation 9 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 09/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBMV:= FWFormStruct(1,'BMV')

oModel := MPFormModel():New( 'PLSA819', , {|| PLSA819OK(oModel) } )//Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterBMV',/*cOwner*/,oStrBMV)						//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterBMV')
oModel:SetDescription(FunDesc())										// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"BMV_FILIAL", "BMV_CODIGO"} ) 

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 09/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrBMV:= FWFormStruct(2, 'BMV')

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel(oModel)									// Define qual Modelo de dados será utilizado
oView:AddField('FrmBMV' , oStrBMV,'MasterBMV' ) 		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxBMV', 100)				// Cria o Box que irá conter a View
oView:SetOwnerView('FrmBMV','BxBMV')					// Associa a View ao Box

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA819OK
Validar botão confirmar
@author Oscar Zanin
@since 09/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA819OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterBMV' )
LOCAL nOpc				:= oModel:GetOperation()
Local cCodigo			:= oModeldetail:getvalue("BMV_CODIGO")
Local nRECNO		:= BMV->(RECNO())
Local aArea			:= GetArea()
Local aAreaBMV		:= BMV->(GETArea())

If (nOpc <> 5) //Na exclusão não verifica o código

	BMV->(DbSetOrder(1)) // BMV_FILIAL + BMV_CODIGO
	
	//Busca se o código já foi cadastrado
	If (BMV->(MsSeek(XFilial("BMV") + cCodigo)))
		If ( nRecno <> BMV->(RECNO()) ) //Se diferente, aí dá mensagem. Se não, continuo no mesmo registro.
   			cMsg := STR0001 //"Código já cadastrado!"
   			Help( ,, 'HELP',, cMsg, 1, 0)
   			lRet := .F.
   		EndIf	
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaBMV)
Return (lRet)
