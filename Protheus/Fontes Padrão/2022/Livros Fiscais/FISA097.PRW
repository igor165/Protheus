#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA097.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA097
Cadastro de Inscrição Estadual

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA097()

	Local   oBrowse
	//Private EAI_MESSAGE_MVC := ""

	IF  AliasIndic("CLO") 
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("CLO")
		oBrowse:SetDescription(STR0001) //Tabela de Inscrição Estadual
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help",STR0002,1,0) //Tabela CLO não cadastrada no sistema!
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA097' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA097' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA097' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA097' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct(1,"CLO")    
	
	oModel	:=	MPFormModel():New('FISA097MOD',,{ |oModel| ValidForm(oModel) })
	
	oModel:AddFields('FISA097MOD',,oStructCAB)	   
	
//	oModel:SetPrimaryKey({"CLO_FILIAL"},{"CLO_UF"},{"CLO_INSCR"})	

//	oModel:SetDescription(STR0001) 
	
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("FISA097")
	Local oStructCAB := FWFormStruct(2,"CLO")	

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCAB,'FISA097MOD')	

	oView:CreateHorizontalBox("CABEC",100)

	oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local cUF	:=	oModel:GetValue('FISA097MOD','CLO_UF')
	Local cIE	:=	oModel:GetValue('FISA097MOD','CLO_INSCR')
	Local nOp	:=	oModel:GetOperation()
	
 	If nOp == 3   //Inclusão
		If CLO->(DbSeek(xFilial("CLO")+cUF))			
			Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
			Return .F.
		EndIF		
	EndIF
	
	If nOp == 4	//Alteração
		If CLO->(DbSeek(xFilial("CLO")+cUF+cIE))			
			Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
			Return .F.
		EndIF
	EndIf 

Return .T.           
