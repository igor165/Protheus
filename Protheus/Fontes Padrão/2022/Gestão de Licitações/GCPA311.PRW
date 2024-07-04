#include "GCPA311.CH" 
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
Local oStruCO3:= FWFormStruct(1,'CO3')
Local oStruCP6:= FWFormStruct(1,'CP6')

oModel := MPFormModel():New('GCPA311')


oModel:addFields('CO3MASTER',,oStruCO3)
oModel:addGrid('CP6DETAIL','CO3MASTER',oStruCP6)

oModel:GetModel( 'CO3MASTER' ):SetOnlyView ( .T. )

oModel:SetRelation('CP6DETAIL', { { 'CP6_FILIAL','xFilial("CP6")' },;
					 					{ 'CP6_CODEDT', 'CO3_CODEDT' 	},;
					 					{ 'CP6_NUMPRO', 'CO3_NUMPRO' 	},;
									 	{ 'CP6_REVISA', 'CO3_REVISA' 	}}, CP6->(IndexKey(1)))
									 	/*{ 'CP6_LOTE'	, 'CO3_LOTE'		},;
									 	{ 'CP6_CODIGO', 'CO3_CODIGO' 	},;
									 	{ 'CP6_LOJA', 'CO3_LOJA' } }*/

oModel:SetPrimaryKey({})

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
Local oStruCO3:= FWFormStruct(2,'CO3',{|cCampo|  AllTrim(cCampo) $ "CO3_FILIAL,CO3_CODIGO,CO3_LOJA,CO3_NOME"})
Local oStruCP6:= FWFormStruct(2,'CP6',{|cCampo|  AllTrim(cCampo) $ "CP6_LOTE,CP6_CODPRO,CP6_DESCRP,CP6_PRCUN,CP6_VLRTOT,CP6_PERCRJ"})

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_CO3' , oStruCO3,'CO3MASTER' )
oView:AddGrid('VIEW_CP6' , oStruCP6,'CP6DETAIL')
    

oView:CreateHorizontalBox( 'SUPERIOR', 20)
oView:CreateHorizontalBox( 'INFERIOR', 80)


oView:SetOwnerView('VIEW_CO3','SUPERIOR')
oView:SetOwnerView('VIEW_CP6','INFERIOR')

oView:EnableTitleView('VIEW_CO3')
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A311Reaj()
Gatilho para calculo do percentual de reajuste do preço por Lote

@author Flavio Lopes Rasta

@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A311Reaj()
Local oModel 		:= FwModelActive()
Local nValPerc	
Local nValReaj	
oModel := oModel:GetModel('CP6DETAIL')
nValReaj := oModel:GetValue('CP6_PRCUN')
If IsInCallStack("GCPA300")
	nValPerc 	:= oModel:GetValue('CP6_PERCRJ')
	nValReaj 	:= nValReaj + (nValReaj * (nValPerc/100))
Endif
	 
Return nValReaj	

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP311Atu(oModel)
Gravação do preço atual

@author Flavio Lopes Rasta

@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP311Atu(oModel300)
Local aSaveLines := FWSaveRows()
Local oModel    		:= FWModelActive()
Local oModelCP3A 	:= oModel300:GetModel('CP3DETAIL')
Local oModelCO3A 	:= oModel300:GetModel('CO3DETAIL')
Local oModelCP6A		:= oModel300:GetModel('CP6DETAIL')
Local oModelCP6		:= oModel:GetModel('CP6DETAIL')
Local oModelCO3		:= oModel:GetModel('CO3MASTER')
Local nX,nY,nZ
Local nTotal
oModelCO3A:SetNoUpdateLine(.F.)

For nX:=1 To oModelCP3A:Length()
	oModelCP3A:GoLine(nX)
	For nY:=1 To oModelCO3A:Length()
		oModelCO3A:GoLine(nX)
		If oModelCO3A:GetValue('CO3_CODIGO') == oModelCO3:GetValue('CO3_CODIGO')
			nTotal := 0
			For nZ:=1 To oModelCP6:Length()
				oModelCP6:GoLine(nZ)
				If oModelCP3A:GetValue('CP3_LOTE') == oModelCP6:GetValue('CP6_LOTE')
					nTotal += oModelCP6:GetValue('CP6_VLRTOT')
				Endif
Next
			oModelCO3A:SetValue('CO3_VLUNIT',nTotal)
			oModelCO3A:SetValue('CO3_VALATU',nTotal)
				Endif
			Next
	Next 
oModelCO3A:SetNoUpdateLine(.T.)


FWRestRows( aSaveLines )

Return .T.







