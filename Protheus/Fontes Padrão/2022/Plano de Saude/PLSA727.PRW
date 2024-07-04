#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'PLSA727.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA727
Funcao para abrir cadastro de Tipo de Informação Eletrônica

@author Karine Riquena Limp
@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA727()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('B9G')
	oBrowse:SetDescription(STR0001)
    oBrowse:setMainProc("PLSA727")
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
    
    If IsInCallStack ("CFGA530")

	    Add Option aRotina Title STR0004 /*'Visualizar'*/ Action 'VIEWDEF.PLSA727' Operation 2 Access 0
	    Add Option aRotina Title STR0005 /*'Incluir'*/    Action 'VIEWDEF.PLSA727' Operation 3 Access 0
	    Add Option aRotina Title STR0006 /*'Alterar'*/    Action 'VIEWDEF.PLSA727' Operation 4 Access 0
	    Add Option aRotina Title STR0007 /*'Excluir'*/    Action 'VIEWDEF.PLSA727' Operation 5 Access 0
	    Add Option aRotina Title STR0008 /*'Imprimir'*/   Action 'VIEWDEF.PLSA727' Operation 8 Access 0
	    Add Option aRotina Title STR0009 /*'Copiar'*/     Action 'VIEWDEF.PLSA727' Operation 9 Access 0
	    AAdd( aRotina,{ STR0002	,"PLSA808"	,  ,  } )										//Adiciona a opção de Documentação no Browse
	    Add Option aRotina Title STR0004 /*'Visualizar' */Action 'VIEWDEF.PLSA808' Operation 2 Access 0
        Add Option aRotina Title STR0005 /*'Incluir'    */Action 'VIEWDEF.PLSA808' Operation 3 Access 0
        Add Option aRotina Title STR0006 /*'Alterar'    */Action 'VIEWDEF.PLSA808' Operation 4 Access 0
        Add Option aRotina Title STR0007 /*'Excluir'    */Action 'VIEWDEF.PLSA808' Operation 5 Access 0
        Add Option aRotina Title STR0008 /*'Imprimir'   */Action 'VIEWDEF.PLSA808' Operation 8 Access 0
        Add Option aRotina Title STR0009 /*'Copiar'     */Action 'VIEWDEF.PLSA808' Operation 9 Access 0
    ELSE
        Add Option aRotina Title STR0004 /*'Visualizar'*/ Action 'VIEWDEF.PLSA727' Operation 2 Access 0
	    Add Option aRotina Title STR0005 /*'Incluir'*/    Action 'VIEWDEF.PLSA727' Operation 3 Access 0
	    Add Option aRotina Title STR0006 /*'Alterar'*/    Action 'VIEWDEF.PLSA727' Operation 4 Access 0
	    Add Option aRotina Title STR0007 /*'Excluir'*/    Action 'VIEWDEF.PLSA727' Operation 5 Access 0
	    Add Option aRotina Title STR0008 /*'Imprimir'*/   Action 'VIEWDEF.PLSA727' Operation 8 Access 0
	    Add Option aRotina Title STR0009 /*'Copiar'*/     Action 'VIEWDEF.PLSA727' Operation 9 Access 0
	    AAdd( aRotina,{ STR0002	,"PLSA808"	,  ,  } )										//Adiciona a opção de Documentação no Browse

    EndIf

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
Local oStrB9G:= FWFormStruct(1,'B9G')

	oModel := MPFormModel():New( 'PLSA727', , {|| PLSA727OK(oModel) } )
	oModel:addFields('MasterB9G',/*cOwner*/,oStrB9G)
	oModel:getModel('MasterB9G')
	oModel:SetDescription(Fundesc())
	oModel:SetPrimaryKey({"B9G_FILIAL","B9G_COD"})

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
Local oStrB9G:= FWFormStruct(2, 'B9G', { |cCampo| PLSA727VI(cCampo) })

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FrmB9G' , oStrB9G,'MasterB9G' ) 
	oView:CreateHorizontalBox( 'BxB9G', 100)
	oView:SetOwnerView('FrmB9G','BxB9G')

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA727VI
Tratamento para definir os campos da B9G que não serão usados na View
@author Karine Riquena Limp
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA727VI (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo == "B9G_CODINT" 
	lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA727OK
Validar botão confirmar

@author Karine Riquena Limp

@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA727OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelMaster	:= oModel:GetModel( 'MasterB9G' )
LOCAL cDescri   	:= ""
LOCAL cCod          := ""
LOCAL cMOTBG3		:= ""
LOCAL cTipMot		:= ""
LOCAL nOpc			:= oModel:GetOperation()
LOCAL cIntPad       := PLSINTPAD()

If (nOpc <> 5)
	cDescri := oModelMaster:GetValue('B9G_MOTIVO')
	cCod    := oModelMaster:GetValue('B9G_COD')
	B9G->(DbSelectArea("B9G"))
	B9G->(DbSetOrder(2)) // B9G_FILIAL + B9G_CODINT + B9G_MOTIVO
	If B9G->(MsSeek(XFilial("B9G") + cIntPad + cDescri))
	
		   While (B9G->(!Eof()) .AND. B9G->B9G_FILIAL == xFilial("B9G") .AND. B9G->B9G_CODINT == cIntPad .AND. lRet)
		   		If(B9G->B9G_MOTIVO == cDescri .AND. B9G->B9G_COD != cCod)
		   		  	cMsg := STR0003 //Motivo de alteração/solicitação contratual já cadastrado!
			       Help( ,, 'HELP',, cMsg, 1, 0)
			       lRet := .F.
		   		EndIf
		   		B9G->(dbSkip())
		   EndDo
   
	EndIf

	//Confiro se o código inserido está no range de permtidos e se está beneficiário e MOTBG3 preenchido
	cMotBG3 := oModelMaster:GetValue('B9G_MOTBG3')
	cTipMot := oModelMaster:GetValue('B9G_TIPMOT')
	IF (cTipMot == "2" .AND. Empty(cMotBG3))
		Help( ,, 'HELP',, "Informe o Motivo do Bloqueio conforme tabela BG3", 1, 0)
		lRet := .F.	
	ENDIF
B9G->(DbCloseArea())	
EndIf
Return (lRet)



//Função para validar o campo B9G_MOTBG3, para verificar se o código insrerido realmente é de cancelamento/bloqueio.
Function PL720BATR()
Local lRet := .F.
LOCAL oMD  := FWModelActive() 
Local oMA  := oMD:GetModel( 'MasterB9G' )
Local oVA  := FWViewActive()

oVA:Refresh()
oMA:LoadValue("B9G_DESBG3", "")
IF(BG3->BG3_PERBLO = '1'.AND. BG3->BG3_TIPBLO = "0")
	lRet := .T.
ELSE
	oMA:LoadValue("B9G_MOTBG3","")
	Alert("Motivo de Bloqueio informado é Inválido! Utilize a pesquisa para resultados precisos!")
	oMA:LoadValue("B9G_MOTBG3","")
	oVA:Refresh()
ENDIF
Return lRet


