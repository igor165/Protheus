#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA157.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA157  
Informações Adicionais dos Itens do Documento Fiscal

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA157()

	Local oBrowse
	Local aDados	:= {}		

	IF  AliasIndic("F2Y")
		Private nRecno := F2Y->(Recno())
		
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription(STR0001)		
		oBrowse:SetAlias("F2Y")
		oBrowse:SetUseFilter(.T.)
		oBrowse:Activate()		
	Else
		Help("",1,"Help","Help",STR0002,1,0) 
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA157' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA157' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA157' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA157' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct(1,"F2Y")    
	
	oModel	:=	MPFormModel():New('FISA157MOD',,{ |oModel| ValidForm(oModel) })
	
	oModel:AddFields('FISA157MOD',,oStructCAB)	

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("FISA157")
	Local oStructCAB := FWFormStruct(2,"F2Y")	

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCAB,'FISA157MOD')	

	oView:CreateHorizontalBox("CABEC",100)

	oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet			:=	.T.
	Local cCodigo		:=	oModel:GetValue('FISA157MOD','F2Y_CODAJU')
	Local cDtini		:=	oModel:GetValue('FISA157MOD','F2Y_DTINI')
	Local nRecno    	:= F2Y->(Recno())
	Local nRecnoVld		:= 0
	Local nOperation	:=	oModel:GetOperation()
	
	//PK
	//F2Y_FILIAL, F2Y_CODAJU, F2Y_DTINI

	If (nOperation == MODEL_OPERATION_INSERT) .OR. (nOperation == MODEL_OPERATION_UPDATE)
		F2Y->(DbSetOrder(1))
		If F2Y->(DbSeek(xFilial("F2Y")+cCodigo+DTOS(cDtini)))
			If nOperation == MODEL_OPERATION_UPDATE //Alteração
				nRecnoVld :=  F2Y->(Recno())
				If nRecnoVld <> nRecno
					Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
					lRet := .F.
				EndIf
			Else
				Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
				lRet := .F.
			EndIf
			//Volta Recno posicionado na tela
			F2Y->(DbGoTo(nRecno))
		EndIf
	EndIf

Return lRet          




