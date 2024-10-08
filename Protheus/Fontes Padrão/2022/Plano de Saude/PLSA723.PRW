#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA723.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA723
Funcao para abrir cadastro de tipo de classifica��o

@author Karine Riquena Limp
@since 30/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA723()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('B9A')
	oBrowse:SetDescription(STR0001)//'Cadastro de Tipo de Classifica��o de regi�o'
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

	Add Option aRotina Title STR0003 /*'Visualizar'*/ Action 'VIEWDEF.PLSA723' Operation 2 Access 0
	Add Option aRotina Title STR0004 /*'Incluir'*/    Action 'VIEWDEF.PLSA723' Operation 3 Access 0
	Add Option aRotina Title STR0005 /*'Alterar'*/    Action 'VIEWDEF.PLSA723' Operation 4 Access 0
	Add Option aRotina Title STR0006 /*'Excluir'*/    Action 'VIEWDEF.PLSA723' Operation 5 Access 0
	Add Option aRotina Title STR0007 /*'Imprimir'*/   Action 'VIEWDEF.PLSA723' Operation 8 Access 0
	Add Option aRotina Title STR0008 /*'Copiar'*/     Action 'VIEWDEF.PLSA723' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author Karine Riquena Limp	

@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9A:= FWFormStruct(1,'B9A')

	oModel := MPFormModel():New( 'PLSA723', , {|| PLSA723OK(oModel) } )
	oModel:addFields('MasterB9A',/*cOwner*/,oStrB9A)
	oModel:getModel('MasterB9A')
	oModel:SetDescription(Fundesc())
	oModel:SetPrimaryKey({"B9A_FILIAL","B9A_COD","B9A_CODINT"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author Karine Riquena Limp

@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB9A:= FWFormStruct(2, 'B9A', { |cCampo| PLSA723VI(cCampo) })

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FrmB9A' , oStrB9A,'MasterB9A' ) 
	oView:CreateHorizontalBox( 'BxB9A', 100)
	oView:SetOwnerView('FrmB9A','BxB9A')
	
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA723VI
Tratamento para definir os campos da B9A que n�o ser�o usados na View
@author Karine Riquena Limp
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA723VI (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo == "B9A_CODINT" 
	lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA723OK
Validar bot�o confirmar

@author Karine Riquena Limp

@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA723OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelMaster	:= oModel:GetModel( 'MasterB9A' )
LOCAL cTpClas   		:= ""
LOCAL cCod           := ""
LOCAL nOpc				:= oModel:GetOperation()
LOCAL cIntPad        := PLSINTPAD()

cCod    := oModelMaster:GetValue('B9A_COD')
cTpClas := oModelMaster:GetValue('B9A_TPCLAS')

If (nOpc <> 5)
	B9A->(DbSelectArea("B9A"))
	B9A->(DbSetOrder(2)) // B9A_FILIAL + B9A_CODINT + B9A_TPCLAS
	If B9A->(MsSeek(xFilial("B9A") + cIntPad + cTpClas))
		   While (B9A->(!Eof()) .AND. B9A->B9A_FILIAL == xFilial("B9A") .AND. B9A->B9A_CODINT == cIntPad .AND. lRet)
		   		If(B9A->B9A_TPCLAS == cTpClas .AND. B9A->B9A_COD != cCod)
		   		  	cMsg := STR0002 //Classifica��o de regi�o j� cadastrada!
			       Help( ,, 'HELP',, cMsg, 1, 0)
			       lRet := .F.
		   		EndIf
		   		B9A->(dbSkip())
		   EndDo
   EndIf
	B9A->(DbCloseArea())
Else 
	If (nOpc == 5)
    	B9I->(DbSelectArea("B9I"))
		B9I->(DbSetOrder(1))                                                                                                                                
		If B9I->(MsSeek(xFilial("B9I") + cIntPad ))
			While (B9I->(!Eof()) .AND. B9I->B9I_FILIAL == xFilial("B9I") .AND. B9I->B9I_CODINT == cIntPad .AND. lRet)
				If alltrim(B9I->B9I_TPCLA) == alltrim(cCod)
				 	Help( ,, STR0009,, STR0010 + alltrim(B9I->B9I_CODCLA), 1, 0 )//"Permiss�o de exclus�o" ## "Registro n�o pode ser excluido, pois est� em uso na rotina de Classifica��o de Regi�o "
				 	lRet := .F.
				Endif
	   			B9I->(dbSkip())
	   		EndDo
	   	EndIf
	   	B9I->(DbCloseArea())
	   	
	   	If lRet 
			BIC->(DbSelectArea("BIC"))
			BIC->(DbSetOrder(1))                                                                                                                                
			If BIC->(MsSeek(xFilial("BIC") + cIntPad ))
				While (BIC->(!Eof()) .AND. BIC->BIC_FILIAL == xFilial("BIC") .AND. BIC->BIC_CODINT  == cIntPad .AND. lRet)
					If !Empty(alltrim(BIC->BIC_TPCLA))
						If alltrim(BIC->BIC_TPCLA) == alltrim(cCod)
					 		Help( ,, STR0009,, STR0011 + alltrim(B9I->B9I_CODCLA), 1, 0 )//"Permiss�o de exclus�o" ## "Registro n�o pode ser excluido, pois est� em uso na rotina de Cadastro de Regi�o / Municipios "
					 		lRet := .F.
						Endif
					Endif	
		   			BIC->(dbSkip())
		   		EndDo
		   	EndIf
		   	BIC->(DbCloseArea())	
	   	Endif
	   	
	Endif
EndIf

Return (lRet)

