#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA281A
Rotina para carregar o modelo de dados do programa GPTA281

@author MRW Solutions
@since 24/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA281A()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Função para carregar a definição do modelo do progrma principal GTPA281.
 
@sample	ModelDef()
 
@return	oModel - objeto Model.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel   := FWLoadModel( 'GTPA281'/*'GTPA281Y'*/ /*'GYFMASTER'*/ )

Return oModel 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Função para exibir a view de dados.
 
@sample	ViewDef()
 
@return	oView - objeto view.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := ModelDef()

// Cria a estrutura a ser usada na View
Local oStruGYF := FWFormStruct( 2, 'GYF' )

Local oView  

oStruGYF:SetProperty("GYF_CONTEU", MVC_VIEW_ORDEM,'08')

If !Empty(GYF->GYF_CPX3)
	oStruGYF:SetProperty("GYF_CONTEU",MVC_VIEW_LOOKUP,GYF->GYF_CPX3)
EndIf

If !Empty(GYF->GYF_PICTUR)
	oStruGYF:SetProperty("GYF_CONTEU",MVC_VIEW_PICT,GYF->GYF_PICTUR)
EndIf


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GYF', oStruGYF, 'GYFMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_GYF', 'TELA' )

Return oView
