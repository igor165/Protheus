#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc}PLSA272M
Fun��o para carregar o model da tabela B5F sem o BA1
Devido a limita��es do modelo 3 n�o � possivel posicionar o item da grid somente o item do cabe�alho.

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//------------------------------------------------------------------- 
Function PLSA272M()
Local aArea   := GetArea()
Local oBrowse

oBrowse := FWMBrowse():New()    
oBrowse:SetAlias("B5F")    
oBrowse:SetDescription("Beneficiarios Habituais")
oBrowse:SetMenuDef( 'PLSA272M' )      

oBrowse:Activate()
 
RestArea(aArea)
Return Nil
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cria��o do menu MVC

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------  
Static Function MenuDef()
Local aRotina := {} 

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.PLSA272M' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria��o do modelo de dados MVC 

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()
Local oModel        := Nil
Local oStPai        := FWFormStruct(1, 'B5F')
 
oModel := MPFormModel():New('PLSA272MM')
oModel:AddFields('B5FMASTER',/*cOwner*/,oStPai)
 
oModel:SetDescription("Benefici�rios Habituais Intercambio")
oModel:GetModel('B5FMASTER'):SetDescription('Habitualidade')

Return oModel
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria��o da vis�o MVC   

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------  
Static Function ViewDef()
Local aArea   	:= GetArea()
Local oView		:= Nil

RestArea(aArea)

Return oView


