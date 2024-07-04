#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA803.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA803
Funcao para abrir cadastro de Observações Padrão da Tela de Credenciamento de Candidato
@author Oscar Zanin
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA803()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9N')
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

Add Option aRotina Title STR0002 /*'Visualizar'*/ Action 'VIEWDEF.PLSA803' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'*/    Action 'VIEWDEF.PLSA803' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'*/    Action 'VIEWDEF.PLSA803' Operation 4 Access 0
Add Option aRotina Title STR0005 /*'Excluir'*/    Action 'VIEWDEF.PLSA803' Operation 5 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'*/   Action 'VIEWDEF.PLSA803' Operation 8 Access 0
Add Option aRotina Title STR0007 /*'Copiar'*/     Action 'VIEWDEF.PLSA803' Operation 9 Access 0

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
Local oStrB9N:= FWFormStruct(1,'B9N')

oModel := MPFormModel():New( 'PLSA803', , {|| PLSA803OK(oModel) } ) 	//Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterB9N',/*cOwner*/,oStrB9N)							//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterB9N')
oModel:SetDescription(FunDesc())											// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"B9N_FILIAL", "B9N_CODINT", "B9N_CODOBS"} )

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
Local oStrB9N:= FWFormStruct(2, 'B9N', { |cCampo| PLSA803CMP(cCampo) } )

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel(oModel)									// Define qual Modelo de dados será utilizado
oView:AddField('FrmB9N' , oStrB9N,'MasterB9N' ) 		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB9N', 100)				// Cria o Box que irá conter a View
oView:SetOwnerView('FrmB9N','BxB9N')					// Associa a View ao Box

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA803OK
Validar botão confirmar
@author Oscar Zanin
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA803OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9N' )
LOCAL cDescri  		:= ""
LOCAL cCodInt			:= ""
LOCAL nOpc				:= oModel:GetOperation()

If (nOpc <> 5) //Não para "Excluir"
	cDescri := oModelDetail:GetValue('B9N_OBSERV')
	cCodInt := PLSINTPAD()

	B9N->(DbSelectArea("B9N"))
	B9N->(DbSetOrder(2)) // B9N_FILIAL + B9N_OBSERV
	
	//Busca se a Descrição já foi cadastrada
	If (B9N->(MsSeek(XFilial("B9N") + cCodInt + cDescri)))
   		cMsg := STR0001 //"Observação já cadastrada!"
   		Help( ,, 'HELP',, cMsg, 1, 0)
   		lRet := .F.
	EndIf

	B9N->(DbCloseArea())
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA803CMP
Tratamento para campos que não devem ir na View
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA803CMP(cCampo)

Local lRet	:= .T.

If cCampo == "B9N_CODINT"
	lRet := .F.
EndIf

If cCampo == "B9N_DESINT"
	lRet := .F.
EndIf

Return lRet