#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'PLSA816.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA816
Funcao para abrir cadastro Passos da análise
@author Oscar Zanin
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA816()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B4G')
oBrowse:SetDescription(FunDesc())
oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar as opções do menu
@author Oscar Zanin
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0002 /*'Visualizar'*/ Action 'VIEWDEF.PLSA816' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'*/    Action 'VIEWDEF.PLSA816' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'*/    Action 'VIEWDEF.PLSA816' Operation 4 Access 0
Add Option aRotina Title STR0005 /*'Excluir'*/    Action 'VIEWDEF.PLSA816' Operation 5 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'*/   Action 'VIEWDEF.PLSA816' Operation 8 Access 0
Add Option aRotina Title STR0007 /*'Copiar'*/     Action 'VIEWDEF.PLSA816' Operation 9 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin	
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB4G:= FWFormStruct(1,'B4G')

oModel := MPFormModel():New( 'PLSA816', , {|| PLSA816OK(oModel) } )
oModel:AddFields('MasterB4G',/*cOwner*/, oStrB4G)
oModel:GetModel('MasterB4G')
oModel:SetDescription(Fundesc())
oModel:SetPrimaryKey({"B4G_FILIAL","B4G_COD","B4G_CODINT"})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB4G:= FWFormStruct(2, 'B4G', { |cCampo| PLSA816VI(cCampo) })

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('ViewB4G' , oStrB4G, 'MasterB4G' )
oView:CreateHorizontalBox( 'Tela', 100)
oView:SetOwnerView('ViewB4G','Tela')

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA816VI
Tratamento para definir os campos da B4G que não serão usados na View
@author Oscar Zanin
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA816VI(cCampo)

Local lRet	:= .T.

If cCampo == "B4G_CODINT"
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA816OK
Validar botão confirmar
@author Oscar Zanin
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA816OK(oModel)
LOCAL lRet     		:= .T.
LOCAL oModelMaster	:= oModel:GetModel( 'MasterB4G' )
LOCAL cCod           := oModelMaster:GetValue('B4G_COD')
LOCAL cEnvEma			:= oModelMaster:GetValue('B4G_ENVEMA')
LOCAL cCodEma        := oModelMaster:GetValue('B4G_CODEMA')
LOCAL cDescri        := oModelMaster:GetValue('B4G_DESCRI')
LOCAL cCodInt        := PLSINTPAD()

If cEnvEma == "1"
	If EMPTY(Alltrim(cCodEma))
   		Help( ,, 'HELP',, STR0001 /*"Informe o código do e-mail"*/, 1, 0) //"Informe o código do e-mail"
    	lRet := .F.
   	EndIf    
EndIf   

If lRet    
	B4G->(DbSelectArea("B4G"))
	B4G->(DbSetOrder(2)) // B4G_FILIAL + B4G_CODINT + B4G_CODEMA + B4G_DESCRI
	
	If B4G->(MsSeek(xFilial("B4G") + cCodInt + cCodEma + cDescri))
	
		While (B4G->(!Eof()) .AND. B4G->B4G_FILIAL == xFilial("B4G") .AND. B4G->B4G_CODINT == cCodInt .AND. lRet)
		
			If(B4G->B4G_CODEMA == cCodEma .AND. B4G->B4G_DESCRI == cDescri .AND. B4G->B4G_COD != cCod)
				cMsg := STR0008 //'Passo de Análise já cadastrado!'
				Help( ,, 'HELP',, cMsg, 1, 0)
				lRet := .F.
			EndIf
			
			B4G->(dbSkip())
		EndDo
		
	EndIf
	
	B4G->(DbCloseArea())
EndIf

Return (lRet)