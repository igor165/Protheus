#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'Totvs.ch'
#INCLUDE 'FwMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef() 

@sample  	ViewDef()

@return  	oView - Objeto do View

@author		Fernando Amorim(Cafu)

@since		11/07/2017
@version 	P12.1.16
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local omodel 		:= FWLoadModel( 'MNTA084' )
Local oModelSTB  	:= oModel:GetModel( oModel:cId + '_STB')
Local cCodVei		:= GetVeicAt()

oModel:SetRelation(oModel:cId + '_STB' ,{{ 'TB_CODBEM', "'" + cCodVei + "'"}})

//--------------------------------------------------------------------------
// Cria o objeto de View
//--------------------------------------------------------------------------
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( omodel )

// Cria Box na view
oView:CreateHorizontalBox( 'MAIN', 100 )

// Cria Folder na view
oView:CreateFolder( 'MAIN_FOLDER' , 'MAIN' )
//--------------------------------------------------------------------------
// Details
//--------------------------------------------------------------------------

If FindFunction('ViewSTB')
    ViewSTB(oView, oModel)
Endif  

Return (oView)
