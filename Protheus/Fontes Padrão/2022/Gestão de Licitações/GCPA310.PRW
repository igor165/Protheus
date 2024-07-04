#include "GCPA310.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Flavio Lopes Rasta

@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStruCAB:= FWFormStruct(1,'CPZ')
Local oStruCPZ:= FWFormStruct(1,'CPZ')

oModel := MPFormModel():New('GCPA310')


oModel:addFields('CPZMASTER',,oStruCAB)
oModel:addGrid('CPZDETAIL','CPZMASTER',oStruCPZ)

oModel:GetModel( 'CPZMASTER' ):SetOnlyView ( .T. )

oModel:SetRelation('CPZDETAIL', { { 'CPZ_FILIAL','xFilial("CPZ")' },;
					 { 'CPZ_NUMATA', 'CPZ_NUMATA' },;
					 { 'CPZ_TIPO', 'CPZ_TIPO' },;
					 { 'CPZ_CODIGO', 'CPZ_CODIGO' },;
					 { 'CPZ_LOJA', 'CPZ_LOJA' }}, CPZ->(IndexKey(1)) )

oModel:GetModel( 'CPZDETAIL' ):SetNoDeleteLine(.T.)
oModel:SetPrimaryKey({})

oModel:GetModel('CPZDETAIL'):SetLoadFilter({{'CPZ_STATUS',"'5'",MVC_LOADFILTER_EQUAL}})
oModel:SetActivate({|oModel|A310AtPrcs(oModel) })


oModel:SetDescription(STR0001)	//'Repacturação de Preços'
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Flavio Lopes Rasta

@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStruCAB:= FWFormStruct(2,'CPZ',{|cCampo|  AllTrim(cCampo) $ "CPZ_FILIAL,CPZ_CODIGO,CPZ_LOJA,CPZ_NOME"})
Local oStruCPZ:= FWFormStruct(2,'CPZ',{|cCampo|  AllTrim(cCampo) $ "CPZ_CODPRO,CPZ_VLUNIT,CPZ_VALATU,CPZ_VLRPRE,CPZ_PERCRJ,CPZ_VALRRJ"})

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_CAB' , oStruCAB,'CPZMASTER' )
oView:AddGrid('VIEW_CPZ' , oStruCPZ,'CPZDETAIL')
    
oModel:GetModel( 'CPZDETAIL' ):SetNoInsertLine(.T.)    

oView:CreateHorizontalBox( 'SUPERIOR', 20)
oView:CreateHorizontalBox( 'INFERIOR', 80)


oView:SetOwnerView('VIEW_CAB','SUPERIOR')
oView:SetOwnerView('VIEW_CPZ','INFERIOR')

oView:EnableTitleView('VIEW_CAB')
oStruCPZ:SetProperty('*', 	MVC_VIEW_CANCHANGE,.F.)
oStruCPZ:SetProperty('CPZ_PERCRJ', 	MVC_VIEW_CANCHANGE,.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A310Reaj()
Gatilho para calculo do percentual de reajuste do preço

@author Flavio Lopes Rasta

@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A310Reaj()
Local oModel 		:= FwModelActive()
Local nValAtu 	
Local nValPerc	
Local nValReaj	
oModel := oModel:GetModel('CPZDETAIL')
nValReaj := oModel:GetValue('CPZ_VALRRJ')

If IsInCallStack("GCPA300")
	If IsInCallStack("GCP310ATU")
		nValReaj := oModel:GetValue('CPZ_VALATU')
	Else	
		nValAtu 	:= oModel:GetValue('CPZ_VALATU')
		nValPerc 	:= oModel:GetValue('CPZ_PERCRJ')
		nValReaj 	:= nValAtu + (nValAtu * (nValPerc/100))
	End
Endif
	 
Return nValReaj	

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP310Atu(oModel)
Gravação do preço atual

@author Flavio Lopes Rasta

@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP310Atu(oModel300)
Local aSaveLines := FWSaveRows()
Local aAtuProd		:= {}
Local aLChanged		:= {}
Local oModel    		:= FWModelActive()
Local oModelCPYA		:= oModel300:GetModel('CPYDETAIL')
Local oModelCPZA 	:= oModel300:GetModel('CPZDETAIL')
Local oModelCPZ 		:= oModel:GetModel('CPZDETAIL')
Local oModelCAB		:= oModel:GetModel('CPZMASTER')
Local nX,nY,nZ

aLChanged := oModelCPZ:GetLinesChanged()

For nX := 1 To Len(aLChanged)
	oModelCPZ:GoLine(aLChanged[nX])
	Aadd(aAtuProd,{oModelCPZ:GetValue('CPZ_CODPRO'),oModelCPZ:GetValue('CPZ_VALRRJ'), oModelCPZ:GetValue('CPZ_PERCRJ')})		
Next
oModelCPZA:SetNoUpdateLine(.F.)
For nX:=1 To Len(aAtuProd)
	For nY := 1 To oModelCPYA:Length()
		oModelCPYA:GoLine(nY)
		If aAtuProd[nX][1] == oModelCPYA:GetValue('CPY_CODPRO') 
			For nZ := 1 To oModelCPZA:Length()
				oModelCPZA:GoLine(nZ)
				If oModelCPZA:GetValue('CPZ_CODIGO') == oModelCAB:GetValue('CPZ_CODIGO') .And. oModelCPZA:GetValue('CPZ_LOJA') == oModelCAB:GetValue('CPZ_LOJA');
					.And. oModelCPZA:GetValue('CPZ_STATUS') == '5'  
					oModelCPZA:SetValue('CPZ_VALATU',aAtuProd[nX][2])					
					oModelCPZA:SetValue('CPZ_PERCRJ',aAtuProd[nX][3])
				Endif
			Next
		Endif
	Next 
Next
oModelCPZA:SetNoUpdateLine(.T.)
FWRestRows( aSaveLines )

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} A310AtPrcs(oModel)
Função que atualiza o percentual dos produtos

@author Matheus Lando

@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A310AtPrcs(oModel)
Local oCPZDetail 	:= oModel:GetModel( 'CPZDETAIL' )
Local nI 			:= 0
Local aPrcs 		:= {}

For nI := 1 To Len(aPrcs)	
	oCPZDetail:GoLine(nI)
	If oCPZDetail:GetValue('CPZ_CODPRO') == aPrcs[nI, 1]
		oCPZDetail:SetValue('CPZ_PERCRJ', aPrcs[nI, 2])								
	EndIf
Next nI	

Return Nil
