#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA106()
Rotina para realizar o cadastro de tipo de documento a ser utilizado 
no processamento da CAT83, considerando a combina��o de Movimenta��o Interna (TM)
e tipo de Requisi��o/Devolu�� (CF).

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
	oBrowse:SetDescription('Identifica��o de Documento Interno - CAT83')		
	oBrowse:Activate()
Else
	Alert('Dicion�rio est� desatualizado, por favor verifique atualiza��o das tabelas')	
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
oModel:SetDescription( 'Identifica��o de Documento Interno - CAT83')

//Os campos abaixo somente poder�o ser editados caso esteja em mode de inclus�o
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
oView:EnableTitleView('VIEW_CAB','Identifica��o de Documento Interno - CAT83')//'Contribui��o Previdenci�ria Sobre a Receita Bruta'
		
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm()
Fun��o para realizar a valida��o da grava��o do modelo

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

If nOperation == 3  //Inclus�o de informa��es ou altera��es.
	DbSelectArea ("CLZ")
	
	//Verifico se j� existe alguma informa��o j� cadastrada com o c�digo informado
	CLZ->(DbSetOrder (2))
	If CLZ->(DbSeek(xFilial("CLZ")+cCod))			
		//N�o poder� ter o mesmo c�digo gravado mais de uma vez
		lRet := .F.			
		Help("",1,"Help","Help",'C�digo j� foi cadastrado',1,0)
	Else	
		//Verifico a combina��o da chave �nica para n�o dar erro de chave duplicada.
		CLZ->(DbSetOrder (1))	
		If CLZ->(DbSeek(xFilial("CLZ")+cTm+cCF+cCod))			
			lRet := .F.			
			Help("",1,"Help","Help",'Combina��o de C�digo de Opera��o Interna, C�digo TM e C�digo CF j� foram cadastrados',1,0) //"Ind. de Ajuste, Pis ou COFINS, Cod. de Ajuste e Data Referencial j� cadastrados!"
		EndIF	
	EndIF
	
EndIF

Return lRet
