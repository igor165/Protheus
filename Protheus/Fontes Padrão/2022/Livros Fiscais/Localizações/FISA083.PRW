#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FISA083.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA083
Cadastro MVC para atender o cadastro de Ponto de Venda.

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA083()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Ponto de venda.
oBrw:SetAlias( 'CFH')
oBrw:SetMenuDef( 'FISA083' )

oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return FWMVCMenu( "FISA083" )      
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruCFH := FWFormStruct( 1, 'CFH' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('FISA083',,,)

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CFH', /*cOwner*/, oStruCFH)
oModel:GetModel( 'MODEL_CFH' ):SetPrimaryKey( { 'CFH_FILIAL' , 'CFH_CODIGO'} )

Return oModel             
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'FISA083' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCFH	:= FWFormStruct( 2, 'CFH' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_CFH', oStruCFH, 'MODEL_CFH' )

oView:EnableTitleView( 'VIEW_CFH',  STR0001 ) //Ponto de venda

oView:CreateHorizontalBox( 'FIELDSCFH', 100 )

oView:SetOwnerView( 'VIEW_CFH', 'FIELDSCFH' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F083ExtSFP
Função que verifica se existe relacionamento com SFP.

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function F083ExtSFP(cPV, lMsg)
Local lRet := .F.
Default cPV := ""
Default lMsg:= .F.

dbSelectArea("SFP")
dbSetOrder(9)
If SFP->(MsSeek(xFilial("SFP")+cPV))
	lRet := .T.
Else
	If (lMsg) 
		Alert(STR0002)//"Não existe relacionamento entre o ponto de venda informado e o cadastro de formulários."
	EndIf
EndIf
Return lRet