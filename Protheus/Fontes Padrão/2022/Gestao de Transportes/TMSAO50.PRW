#INCLUDE "TMSAO50.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/-----------------------------------------------------------
{Protheus.doc} TMSAO50()
Controle Integração TMS x Roteirizador
Uso: SIGATMS
@sample
//TMSAO50()
@author Rafael Souza
@since 12/06/2019
@version 1.0
-----------------------------------------------------------/*/
Function TMSAO50()
Local oBrowse   := Nil				// Recebe o  Browse          

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DLU")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSAO50")		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)		//"Controle Integração TMS x Roteirizador"
oBrowse:AddLegend("DLU_STATUS='1'" , "GREEN", STR0006 )	//-- Integrado com sucesso
oBrowse:AddLegend("DLU_STATUS='2'" , "RED" 	, STR0007 ) //-- Falha
oBrowse:Activate()

Return Nil

 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  
Uso: TMSAO50
@sample
//MenuDef()
@author Rafael Souza
@since 12/06/2019
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAO50" OPERATION 2 ACCESS 0 // "Visualizar"

Return (aRotina)  

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo
Uso: TMSAO50
@sample
//ModelDef()
@author Rafael Souza
@since 12/06/2019
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()

Local oModel	:= Nil		// Objeto do Model
Local oStruDLU	:= Nil		// Recebe a Estrutura da tabela DLU
Local bCommit	:= { |oMdl| CommitMdl(oMdl) }

oStruDLU:= FWFormStruct( 1, "DLU" )

oModel := MPFormModel():New( "TMSAO50",,, bCommit /*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDLU',, oStruDLU,,,/*Carga*/ ) 
oModel:GetModel( 'MdFieldDLU' ):SetDescription( STR0001 ) 	//"Controle Integ. TMS x Roteirizador"
oModel:SetPrimaryKey({"DLU_FILIAL" , "DLU_CODIGO"})     
oModel:SetActivate()
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAO50

@sample
//ViewDef()

@author Rafael Souza
@since 12/06/2019
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDLU	:= Nil		// Recebe a Estrutura da tabela DLU
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAO50")
oStruDLU := FWFormStruct( 2, "DLU" )

oView := FwFormView():New()
oView:SetModel(oModel)     
oView:AddField('VwFieldDLU', oStruDLU , 'MdFieldDLU')   
oView:CreateHorizontalBox('CABECALHO', 100)  
oView:SetOwnerView('VwFieldDLU','CABECALHO')

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Definição da CommitMdl

Uso: TMSAO50

@sample
//CommitMdl()

@author Rafael Souza
@since 12/06/2019
@version 1.0
-----------------------------------------------------------/*/
Static Function CommitMdl(oModel)

	Begin Transaction	
		FwFormCommit(oModel ,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)
	End Transaction

Return .T.

