#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'PLSA726.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA726
Funcao para abrir cadastro de Tipo de Informação Eletrônica

@author Karine Riquena Limp
@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA726()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('B9F')
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela

@author Karine Riquena Limp	
@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	Add Option aRotina Title STR0003 /*'Visualizar'*/ Action 'VIEWDEF.PLSA726' Operation 2 Access 0
	Add Option aRotina Title STR0004 /*'Incluir'*/    Action 'VIEWDEF.PLSA726' Operation 3 Access 0
	Add Option aRotina Title STR0005 /*'Alterar'*/    Action 'VIEWDEF.PLSA726' Operation 4 Access 0
	Add Option aRotina Title STR0006 /*'Excluir'*/    Action 'VIEWDEF.PLSA726' Operation 5 Access 0
	Add Option aRotina Title STR0007 /*'Imprimir'*/   Action 'VIEWDEF.PLSA726' Operation 8 Access 0
	Add Option aRotina Title STR0008 /*'Copiar'*/     Action 'VIEWDEF.PLSA726' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Karine Riquena Limp	

@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9F:= FWFormStruct(1,'B9F')

	oModel := MPFormModel():New( 'PLSA726', , {|| PLSA726OK(oModel) } )
	oModel:addFields('MasterB9F',/*cOwner*/,oStrB9F)
	oModel:getModel('MasterB9F')
	oModel:SetDescription(Fundesc())
	oModel:SetPrimaryKey({"B9F_FILIAL","B9F_COD","B9F_CODINT"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Karine Riquena Limp

@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB9F:= FWFormStruct(2, 'B9F', { |cCampo| PLSA726VI(cCampo) })

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FrmB9F' , oStrB9F,'MasterB9F' ) 
	oView:CreateHorizontalBox( 'BxB9F', 100)
	oView:SetOwnerView('FrmB9F','BxB9F')

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA726VI
Tratamento para definir os campos da B9F que não serão usados na View
@author Karine Riquena Limp
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA726VI (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo == "B9F_CODINT" 
	lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA726OK
Validar botão confirmar

@author Karine Riquena Limp

@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA726OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelMaster	:= oModel:GetModel( 'MasterB9F' )
LOCAL cDescri   		:= ""
LOCAL cCod           := ""
LOCAL nOpc				:= oModel:GetOperation()
LOCAL cIntPad        := PLSINTPAD()
If (nOpc <> 5)
	cDescri := oModelMaster:GetValue('B9F_DESCRI')
	cCod    := oModelMaster:GetValue('B9F_COD')

	B9F->(DbSelectArea("B9F"))
	B9F->(DbSetOrder(1)) // B9F_FILIAL + B9F_CODINT + B9F_DESCRI
	If B9F->(MsSeek(XFilial("B9F") + cIntPad + cDescri))

	   While (B9F->(!Eof()) .AND. B9F->B9F_FILIAL == xFilial("B9F") .AND. B9F->B9F_CODINT == cIntPad .AND. lRet)
	       If(B9F->B9F_DESCRI == cDescri .AND. B9F->B9F_COD != cCod)
	   		  	cMsg := STR0002
		       Help( ,, 'HELP',, cMsg, 1, 0) //"Tipo de informação eletrônica já cadastrada!"
		       lRet := .F.
	   		EndIf
	   		B9F->(dbSkip())
	   EndDo
   
   EndIf
	B9F->(DbCloseArea())
EndIf
ConfirmSX8()

Return (lRet)





