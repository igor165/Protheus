#INCLUDE "JURA092.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE 'FWBROWSE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA092
Log Integracao Juridica Server
@author Clóvis Eduardo Teixeira
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA092()
Local oBrowse     

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NWT" )
oBrowse:SetLocate()      
JurSetLeg( oBrowse, "NWT" )              
JurSetBSize( oBrowse )       
oBrowse:Activate()    

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Clóvis Eduardo Teixeira
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "VIEWDEF.JURA092", 0, 2, 0, NIL } ) // "Visualizar"  

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Alter. Processos Encerrados

@author Clóvis Eduardo Teixeira
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA092" )
Local oStruct := FWFormStruct( 2, "NWT" )  

JurSetAgrp( 'NWT',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )         

oView:AddField( "JURA092_VIEW", oStruct, "NWTMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA092_VIEW", "FORMFIELD" ) 

oView:SetDescription( STR0007 ) // "Alter. Processos Encerrados"
oView:EnableControlBar( .T. )     

oView:setUseCursor(.F.)  

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Alter. Processos Encerrados
@author Clóvis Eduardo Teixeira
@since 05/08/09
@version 1.0
@obs NWTMASTER - Dados do Alter. Processos Encerrados
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NWT" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA092", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NWTMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ ) 
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Alter. Processos Encerrados"
oModel:GetModel( "NWTMASTER" ):SetDescription( STR0009 ) // "Dados de Alter. Processos Encerrados" 

JurSetRules( oModel, "NWTMASTER",, "NWT")

Return oModel