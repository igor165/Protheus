#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA106()
Rotina para realizar o cadastro de tipo de documento a ser utilizado 
no processamento da CAT83, considerando a combinação de Movimentação Interna (TM)
e tipo de Requisição/Devoluçã (CF).

@author Erick G. Dias
@since 08/04/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Function FISA106()
Local   oBrowse
		
If AliasIndic('CLZ')	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CLZ")
	oBrowse:SetDescription('Identificação de Documento Interno - CAT83')		
	oBrowse:Activate()
Else
	Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas')	
EndIF
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Define o Menu da rotina

@author Erick G. Dias
@since 08/04/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA106")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Define o modelo da rotina

@author Erick G. Dias
@since 08/04/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructCAB := FWFormStruct( 1 , "CLZ" )

oModel:= MPFormModel():New('FISA106', ,{ |oModel| ValidForm(oModel) } )    
oModel:AddFields( "FISA106" ,, oStructCAB )		
oModel:SetDescription( 'Identificação de Documento Interno - CAT83')

//Os campos abaixo somente poderão ser editados caso esteja em mode de inclusão
oStructCAB:SetProperty( 'CLZ_CODIGO' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })		
oStructCAB:SetProperty( 'CLZ_TM' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
oStructCAB:SetProperty( 'CLZ_CF' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
		
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Define a view da rotina

@author Erick G. Dias
@since 08/04/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView      := FWFormView():New()
Local oModel     := FWLoadModel( "FISA106" )
Local oStructCAB := FWFormStruct( 2 , "CLZ" )

oView:SetModel(oModel)

oView:AddField( "VIEW_CAB" , oStructCAB , "FISA106" )
oView:CreateHorizontalBox( "CABEC" , 80 )
oView:SetOwnerView( "VIEW_CAB" , "CABEC" )
oView:EnableTitleView('VIEW_CAB','Identificação de Documento Interno - CAT83')//'Contribuição Previdenciária Sobre a Receita Bruta'
		
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm()
Função para realizar a validação da gravação do modelo

@author Erick G. Dias
@since 08/04/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local cCod		:=	oModel:GetValue ('FISA106','CLZ_CODIGO')
Local cTm		:=	oModel:GetValue ('FISA106','CLZ_TM')
Local cCF		:=	oModel:GetValue ('FISA106','CLZ_CF')
Local nOperation 	:=	oModel:GetOperation()
Local lRet		:= .T.

If nOperation == 3  //Inclusão de informações ou alterações.
	DbSelectArea ("CLZ")
	
	//Verifico se já existe alguma informação já cadastrada com o código informado
	CLZ->(DbSetOrder (2))
	If CLZ->(DbSeek(xFilial("CLZ")+cCod))			
		//Não poderá ter o mesmo código gravado mais de uma vez
		lRet := .F.			
		Help("",1,"Help","Help",'Código já foi cadastrado',1,0)
	Else	
		//Verifico a combinação da chave única para não dar erro de chave duplicada.
		CLZ->(DbSetOrder (1))	
		If CLZ->(DbSeek(xFilial("CLZ")+cTm+cCF+cCod))			
			lRet := .F.			
			Help("",1,"Help","Help",'Combinação de Código de Operação Interna, Código TM e Código CF já foram cadastrados',1,0) //"Ind. de Ajuste, Pis ou COFINS, Cod. de Ajuste e Data Referencial já cadastrados!"
		EndIF	
	EndIF
	
EndIF

Return lRet
