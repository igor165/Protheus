#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA121()
Rotina para realizar o cadastro dos Indicadores Econômicos 
FCA (Fator de Conversão e Atualização) para cada Estado/Periodo

@author Graziele Mendonça Paro
@since 04/07/2016
@version P12
/*/
//-------------------------------------------------------------------
Function FISA121()
Local   oBrowse
        
If AliasIndic('F0R')    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F0R")
    oBrowse:SetDescription('Indicadores Econômicos FCA (Fator de Conversão e Atualização)')        
    oBrowse:Activate()
Else
    Alert('Dicionário está desatualizado, por favor verifique a versão do dicionário de dados para utilização desta rotina!') 

EndIF
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Define o Menu da rotina

@author Graziele Mendonça Paro
@since 04/07/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA121")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Define o modelo da rotina

@author Graziele Mendonça Paro
@since 04/07/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructCAB := FWFormStruct( 1 , "F0R" )

oModel:= MPFormModel():New('FISA121',, { |oModel| Valid(oModel) } )     
oModel:AddFields( "FISA121" ,, oStructCAB )     
oModel:SetDescription( 'Indicadores Econômicos FCA (Fator de Conversão e Atualização)')

oModel:SetPrimaryKey({"F0R_FILIAL"},{"F0R_UF"},{"F0R_PERIOD"})

       
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Define a view da rotina

@author Graziele Mendonça Paro
@since 04/07/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView      := FWFormView():New()
Local oModel     := FWLoadModel( "FISA121" )
Local oStructCAB := FWFormStruct( 2 , "F0R" )

oView:SetModel(oModel)

oView:AddField( "VIEW_CAB" , oStructCAB , "FISA121" )
oView:CreateHorizontalBox( "CABEC" , 80 )
oView:SetOwnerView( "VIEW_CAB" , "CABEC" )
oView:EnableTitleView('VIEW_CAB','Indicadores Econômicos FCA (Fator de Conversão e Atualização)')
        
Return oView


//-------------------------------------------------------------------

/*/{Protheus.doc} Valid
Validação das informações digitadas.

@author Graziele Mendonça Paro
@since 04/07/2016
@version P12

/*/
//-------------------------------------------------------------------
Static Function Valid(oModel)

    Local lRet          :=  .T.
    Local cEstado       :=  oModel:GetValue('FISA121','F0R_UF')
    Local cPeriod       :=  oModel:GetValue('FISA121','F0R_PERIOD')
    Local nOperation    :=  oModel:GetOperation()
    Local cRegisto      := ""
    

    
    If  nOperation == 3 // Incluindo novo registro
        F0R->(DbSetOrder (1))
        If F0R->(DbSeek(xFilial("F0R")+cEstado+(cPeriod)))                                                                                                             
            //Help("",1,"Help","Help","",1,0,"Já existe um registro para este Estado/Período") 
            Help("",1,"Help","Help","Já existe um registro para este Estado/Período",1,0)
            lRet := .F.
        EndIF
    EndIF

Return lRet
