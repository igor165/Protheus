#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU06D01.CH'



/*/{Protheus.doc} RU06D01a
@author Andrews Egas
@since 22/12/2016
@version P10
/*/
//-
Function RU06D01a()
Local oBrowse := FWLoadBrw("RU06D01a")
oBrowse:Activate()
Return NIL



Static Function BrowseDef()
Local oBrowse := FWMBrowse():New()
Local cRecnos := ""
Local cUltRep := "00"
Local cQuery := "select distinct f42_filial, f42_report, f42_repnam from " + RetSqlName("F42") + " where f42_filial = '" + xFilial("F42") + "' and d_e_l_e_t_ = ' '"

oBrowse:SetMenuDef("RU06D01a")
oBrowse:SetAlias('F42')
oBrowse:SetDescription(STR0015) // Reports x Signers
oBrowse:SetQuery(cQuery)
ADD COLUMN oColumn DATA {|| F42_FILIAL} TITLE STR0016 SIZE GetSX3Cache("F42_FILIAL", "X3_TAMANHO") OF oBrowse
ADD COLUMN oColumn DATA {|| F42_REPORT} TITLE STR0013 SIZE GetSX3Cache("F42_REPORT", "X3_TAMANHO") OF oBrowse
ADD COLUMN oColumn DATA {|| F42_REPNAM} TITLE STR0014 SIZE GetSX3Cache("F42_REPNAM", "X3_TAMANHO") OF oBrowse
Return(oBrowse)



//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 		ACTION 'VIEWDEF.RU06D01a' OPERATION 2 ACCESS 0 //View

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruF42 := FWFormStruct( 1, 'F42', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruGridF42 := FWFormStruct( 1, 'F42')
Local oModel
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('RU06D01a', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )


oModel:AddFields( 'F42MASTER', /*cOwner*/, oStruF42, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 	'F42DETAIL', 'F42MASTER', oStruGridF42, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetPrimaryKey( { "F42_FILIAL", "F42_EMPL"} )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'F42DETAIL', {{ 'F42_FILIAL', 'xFilial( "F42" )' },  { 'F42_REPORT', 'F42_REPORT' } }, F42->( IndexKey( 1 ) ) )

oModel:GetModel( 'F42DETAIL' ):SetUniqueLine( { 'F42_EMPL' } )


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0012)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'F42MASTER' ):SetDescription(STR0012)
oModel:GetModel( 'F42DETAIL' ):SetDescription(STR0011)
// Liga a validasso da ativacao do Modelo de Dados
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'RU06D01a' )
// Cria a estrutura a ser usada na View
Local oStruF42 	:= FWFormStruct( 2, 'F42',{|cCampo| (AllTRim(cCampo) $  "F42_REPORT|F42_REPNAM")} )//F42_REPNAM
Local oStruGridF42 := FWFormStruct( 2, 'F42')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados sers utilizado
oView:SetModel( oModel )

oStruGridF42:RemoveField("F42_ITEM")

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 	'FIELD_F42', oStruF42, 'F42MASTER' )
oView:AddGrid( 	'GRID_F42', oStruGridF42, 'F42DETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 30 )
oView:CreateHorizontalBox( 'TELA2' , 70 )


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'FIELD_F42', 'TELA' )
oView:SetOwnerView( 'GRID_F42', 'TELA2' )

Return oView

//merge branch 12.1.19
// Russia_R5
