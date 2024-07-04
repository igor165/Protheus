#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'PLSA725.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA725
Funcao para abrir cadastro de tipo de classificação

@author Karine Riquena Limp
@since 30/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA725()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('B99')
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela

@author Karine Riquena Limp	
@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	Add Option aRotina Title STR0003 /*'Visualizar'*/ Action 'VIEWDEF.PLSA725' Operation 2 Access 0
	Add Option aRotina Title STR0004 /*'Incluir'*/    Action 'VIEWDEF.PLSA725' Operation 3 Access 0
	Add Option aRotina Title STR0005 /*'Alterar'*/    Action 'VIEWDEF.PLSA725' Operation 4 Access 0
	Add Option aRotina Title STR0006 /*'Excluir'*/    Action 'VIEWDEF.PLSA725' Operation 5 Access 0
	Add Option aRotina Title STR0007 /*'Imprimir'*/   Action 'VIEWDEF.PLSA725' Operation 8 Access 0
	Add Option aRotina Title STR0008 /*'Copiar'*/     Action 'VIEWDEF.PLSA725' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Karine Riquena Limp	

@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB99:= FWFormStruct(1,'B99')

	oModel := MPFormModel():New( 'PLSA725', , {|| PLSA725OK(oModel) } )
	oModel:addFields('MasterB99',/*cOwner*/,oStrB99)
	oModel:getModel('MasterB99')
	oModel:SetDescription(Fundesc())
	oModel:SetPrimaryKey({"B99_FILIAL","B99_COD","B99_CODINT"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Karine Riquena Limp

@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB99:= FWFormStruct(2, 'B99', { |cCampo| PLSA725VI(cCampo) })

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FrmB99' , oStrB99,'MasterB99' ) 
	oView:CreateHorizontalBox( 'BxB99', 100)
	oView:SetOwnerView('FrmB99','BxB99')
	
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA725VI
Tratamento para definir os campos da B9G que não serão usados na View
@author Karine Riquena Limp
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA725VI (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo == "B99_CODINT" 
	lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA725OK
Validar botão confirmar

@author Karine Riquena Limp

@since 05/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA725OK(oModel)
LOCAL lRet     := .T.
LOCAL oModelMaster	:= oModel:GetModel( 'MasterB99' )
LOCAL cCod           := oModelMaster:GetValue('B99_COD')
LOCAL cEnvEma			:= oModelMaster:GetValue('B99_ENVEMA')
LOCAL cCodEma        := oModelMaster:GetValue('B99_CODEMA')
LOCAL cDescri        := oModelMaster:GetValue('B99_DESCRI')
LOCAL cIntPad        := PLSINTPAD()

    If cEnvEma == "1"
        If EMPTY(Alltrim(cCodEma))
            Help( ,, 'HELP',, STR0002, 1, 0) //"Informe o código do e-mail"
    	     lRet := .F.
        EndIf    
    EndIf   
    
    If lRet    
		B99->(DbSelectArea("B99"))
		B99->(DbSetOrder(2)) // B99_FILIAL + B99_CODINT + B99_CODEMA + B99_DESCRI
		If B99->(MsSeek(xFilial("B99") + cIntPad + cCodEma + cDescri))
			   While (B99->(!Eof()) .AND. B99->B99_FILIAL == xFilial("B99") .AND. B99->B99_CODINT == cIntPad .AND. lRet)
			   		If(B99->B99_CODEMA == cCodEma .AND. B99->B99_DESCRI == cDescri .AND. B99->B99_COD != cCod)
			   		  	cMsg := 'Passo de credenciamento já cadastrado!'//STR0003 //Passo de credenciamento já cadastrado!
				       Help( ,, 'HELP',, cMsg, 1, 0)
				       lRet := .F.
			   		EndIf
			   		B99->(dbSkip())
			   EndDo
	   EndIf
		B99->(DbCloseArea())
		
	EndIf
    
Return (lRet)



