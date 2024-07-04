#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA120.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA120
Motivo de inventário

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA120()

	Local   oBrowse
	//Private EAI_MESSAGE_MVC := ""

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("F0Q")
		oBrowse:SetDescription(STR0001) //Motivo de inventário
		oBrowse:Activate()

	Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA120' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA120' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA120' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA120' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct(1,"F0Q")    
	
	oModel	:=	MPFormModel():New('FISA120MOD',,{ |oModel| ValidForm(oModel) })
	
	oModel:AddFields('FISA120MOD',,oStructCAB)	   
	
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("FISA120")
	Local oStructCAB := FWFormStruct(2,"F0Q")	

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCAB,'FISA120MOD')	

	oView:CreateHorizontalBox("CABEC",100)

	oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local cCod	  :=	oModel:GetValue('FISA120MOD','F0Q_CODIGO')
Local cMotInv :=	oModel:GetValue('FISA120MOD','F0Q_MOTINV')
Local dDtfec  :=	oModel:GetValue('FISA120MOD','F0Q_DTFECH')
Local nOp	  :=	oModel:GetOperation()
Local lRet		:=	.T.
	
	
	//SX2//F0Q_FILIAL+DTOS(F0Q_DTFECH)+F0Q_CODIGO+F0Q_MOTINV+ID
	//SIX//F0Q_FILIAL+DTOS(F0Q_DTFECH)+F0Q_CODIGO+F0Q_MOTINV
	
If nOp == 3   //Inclusão
	DbSelectArea ("F0Q")  //Valores de exclusão de PIS e Cofins para sociedade cooperativa.
	F0Q->(DbSetOrder (1))
	If F0Q->(DbSeek(xFilial("F0Q")+Dtos(dDtfec)+cCod+cMotInv))
		Help(" ",2,"Help","Help","Registro já cadastrado",1,0)//Registro já cadastrado
		Return .F.
	EndIF		
EndIF

dbSelectArea("F0Q")
cRegisto    := F0Q->(RECNO())
    
If nOp == 4 // Alterando registro   
	F0Q->(DbSetOrder (1))
	If F0Q->(DbSeek(xFilial("F0Q")+Dtos(dDtfec)+cCod+cMotInv))
		 IF F0Q->(RECNO()) <> cRegisto
			Help(" ",1,"Help","Help","Registro já cadastrado",1,0)//Registro já cadastrado
			Return .F.
		 EndIf   
	EndIF
EndIF

Return lRet
