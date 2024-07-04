#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "GTPA010.CH"

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA010
Cadastro Tipo de Recurso
 
@sample		GTPA010()
@return		Objeto oBrowse  
@author		Lucas.Brustolin
@since			16/10/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA010()
Local oBrowse := FWMBrowse():New()//-- Instanciamento da Classe de Browse

oBrowse:SetAlias("GYK")			// Define a tabela  
oBrowse:SetDescription(STR0001)	//'Tipo de Recurso'
oBrowse:SetMenuDef("GTPA010")	//Define o Menu

// Ativação da Classe
oBrowse:Activate()

Return (oBrowse)

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Tipo de Recurso

@Return 	aRotina - Vetor com os menus
@author 	Lucas.Brustolin
@since 		16/10/2014
@version	P12
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.GTPA010"	OPERATION 2 ACCESS 0 	// STR0003//"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.GTPA010" 	OPERATION 3	ACCESS 0 	// STR0004//"Incluir"
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.GTPA010"	OPERATION 4	ACCESS 0 	// STR0005//"Alterar"
ADD OPTION aRotina TITLE STR0006	ACTION "VIEWDEF.GTPA010"	OPERATION 5	ACCESS 0 	// STR0006//"Excluir"

Return(aRotina)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel - Objeto do Model
 
@author 	Lucas.Brustolin
@since 		16/10/2014
@version	P12
/*/ 
//--------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= MPFormModel():New('GTPA010', /*bPreValidacao*/, {|oModel|TP010TdOK(oModel)}, /*bCommit*/, /*bCancel*/ )
Local oStruct	:= FWFormStruct( 1, 'GYK' )

oModel:AddFields('GYKMASTER', /*cOwner*/, oStruct ) 

oModel:SetVldActivate({|oModel| VldActivate(oModel)})

oModel:SetDescription( STR0001 ) //-- 'Tipo de Recurso'

Return (oModel)
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da  View Interface 

@sample  	ViewDef()

@return  	oView - Objeto do View

@author 	Lucas.Brustolin
@since 		16/10/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FWLoadModel( 'GTPA010' )
Local oStruct	:= FWFormStruct( 2, 'GYK' )

oStruct:RemoveField('GYK_PROPRI')

oView:SetModel( oModel )

oView:AddField('VIEW_TELA', oStruct,'GYKMASTER') 

oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_TELA','TELA')

Return(oView)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP010TdOK()
Definição do Menu
 
@sample	TP010TdOK()
 
@return	lRet - Retorna true caso a validação estiver ok
 
@author	Inovação
@since		05/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP010TdOK(oModel)
Local lRet	:= .T.
Local oMdlGYK	:= oModel:GetModel('GYKMASTER')
// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGYK:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGYK:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GYK", oMdlGYK:GetValue("GYK_CODIGO")))
		Help( ,, 'Help',"TP010TdOK", STR0007, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)


/*/{Protheus.doc} VldActivate
Função responsavel para validação do tipo de recuroso para não permitir exclui-lo ou altera-lo
@type function
@author jacomo.fernandes
@since 27/08/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldActivate(oModel)
Local lRet		:= .T.
Local nOpc		:= oModel:GetOperation()
Local cMdlId	:= oModel:GetId()

If nOpc	== MODEL_OPERATION_UPDATE .or. nOpc	== MODEL_OPERATION_DELETE  
	If GYK->GYK_PROPRI = 'S'
		lRet := .F.
		oModel:SetErrorMessage(cMdlId,'',cMdlId,'','VLDACTIVATE', STR0013) //'Não é possivel Alterar/Excluir registros incluidos pelo sistema'
	Endif
Endif
Return lRet	