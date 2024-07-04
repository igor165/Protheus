#INCLUDE "TMSAC23.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TMSAC23()
Controle Integração Planejamento de Rotas (TPR)
Uso: SIGATMS
@sample
@author Katia
@since 22/09/2021
@version 12.1.37
/*/
Function TMSAC23()
Local oBrowse   := Nil				// Recebe o  Browse          

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DLU")			    
oBrowse:SetMenuDef("TMSAC23")		
oBrowse:SetDescription(STR0001)		//"Controle Integração Planejamento de Rotas (TPR)
oBrowse:SetFilterDefault( "AllTrim(Upper(DLU_API)) $ 'ROUTING , GEOLOC' " )   //APIs da TPR
oBrowse:Activate()          

Return Nil

/*/{Protheus.doc} MenuDef()
Utilizacao de Menu Funcional  
@author Katia
@since 22/09/2021
@version 12.1.37
@return aRotina
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAC23" OPERATION 2 ACCESS 0 // "Visualizar"

Return (aRotina)  

/*/{Protheus.doc} ModelDef()
Definição do Modelo
@author Katia
@since 22/09/2021
@version 12.1.37
/*/
Static Function ModelDef()
Local oModel	:= Nil		// Objeto do Model
Local oStruDLU	:= Nil		// Recebe a Estrutura da tabela DLU
Local bCommit	:= { |oMdl| CommitMdl(oMdl) }

oStruDLU:= FWFormStruct( 1, "DLU" )

oModel := MPFormModel():New( "TMSAC23",,, bCommit, /*bCancel*/ ) 

oModel:AddFields( 'MdFieldDLU',, oStruDLU,,,/*Carga*/ ) 

oModel:GetModel( 'MdFieldDLU' ):SetDescription( STR0001 ) 	//"Controle Integracao Planejamento Rotas (TPR)

oModel:SetPrimaryKey({"DLU_FILIAL" , "DLU_CODIGO"})     

oModel:SetActivate()
     
Return oModel 

/*/{Protheus.doc} ViewDef()
Definição da View
@author Katia
@since 22/09/2021
@version 12.1.37
/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDLU	:= Nil		// Recebe a Estrutura da tabela DLU
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAC23")
oStruDLU := FWFormStruct( 2, "DLU" )

//-- Campo Rota Inteligente (Maplink)
oStruDLU:RemoveField( "DLU_STATUS" )

oView := FwFormView():New()

oView:SetModel(oModel)     

oView:AddField('VwFieldDLU', oStruDLU , 'MdFieldDLU')   

oView:CreateHorizontalBox('FIELD', 100)  

oView:SetOwnerView('VwFieldDLU','FIELD')

Return oView

/*/{Protheus.doc} CommitMdl()
Definição da CommitMdl
@author Katia
@since 22/09/2021
@version 1.0
@return lRet
/*/
Static Function CommitMdl(oModel)
Local lRet:= .T.

	lRet:=	FwFormCommit(oModel ,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)

Return lRet


