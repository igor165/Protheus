#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA115.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA115
Cadastro de Inscrição Estadual

@author Rafael dos Santos
@since 22.02.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA115()

	Local   oBrowse
	//Private EAI_MESSAGE_MVC := ""

	IF  AliasIndic("F0L") 
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("F0L")
		oBrowse:SetDescription(STR0001) //Tabela de Inscrição Estadual
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help",STR0002,1,0) //Tabela F0L não cadastrada no sistema!
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Rafael dos Santos
@since 22.02.2016
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA115' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA115' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA115' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA115' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Rafael dos Santos
@since 22.02.2016
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct(1,"F0L")    
	
	oModel	:=	MPFormModel():New('FISA115MOD',,{ |oModel| ValidForm(oModel) })
	
	oModel:AddFields('FISA115MOD',,oStructCAB)	   
	
//	oModel:SetPrimaryKey({"F0L_FILIAL"},{"F0L_UF"},{"F0L_INSCR"})	

//	oModel:SetDescription(STR0001) 

	If F0L->(FieldPos("F0L_CGC")) > 0
		oStructCAB:SetProperty('F0L_INSCR', MODEL_FIELD_OBRIGAT, .F. ) //Retira a obrigatoriedade do campo
	EndIf
	
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Rafael dos Santos
@since 22.02.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("FISA115")
	Local oStructCAB := FWFormStruct(2,"F0L")	

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCAB,'FISA115MOD')	

	oView:CreateHorizontalBox("CABEC",100)

	oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author Rafael dos Santos
@since 22.02.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local cUF		:= oModel:GetValue('FISA115MOD','F0L_UF')
	Local nOp		:= oModel:GetOperation()
	Local nRecno    := F0L->(Recno())
	Local nRecnoVld := 0
	Local lRet 		:= .T.
	
 	If nOp == 3 .OR. nOp == 4   //Inclusão ou alteração
		If F0L->(DbSeek(xFilial("F0L")+cUF))
			If nOp == 4 //Alteração
				nRecnoVld := F0L->(Recno())
				If nRecnoVld <> nRecno
					Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
					lRet := .F.
				EndIf
			Else
				Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
				lRet := .F.
			EndIf
			//Volta Recno posicionado na tela
			F0L->(DbGoTo(nRecno))
		EndIF
		//Forçar preencher I.E. ou CNPJ
		If F0L->(FieldPos("F0L_CGC")) > 0 .And. Empty(oModel:GetValue('FISA115MOD','F0L_CGC')) .And. Empty(oModel:GetValue('FISA115MOD','F0L_INSCR'))
			Help(" ",1,"Help",,STR0008,1,0)//Favor preencher o CNPJ ou a Inscrição Estadual!
			lRet:= .F.
		EndIf
	EndIF 

Return lRet
