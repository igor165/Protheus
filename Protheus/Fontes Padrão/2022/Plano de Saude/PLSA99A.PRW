#INCLUDE "PLSA99A.ch"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA99A   บAutor  ณMicrosiga           บ Data ณ  08/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Classifica็ใo da Regiใo				           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE VERSAO 12                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSA99A()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B9I' )
oBrowse:SetDescription(STR0001) //'Classifica็ใo da Regiใo'
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0003,'PesqBrw'         , 0, 1, 0, .T. } )//Pesquisar
aAdd( aRotina, { STR0004,'VIEWDEF.PLSA99A', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0005,'VIEWDEF.PLSA99A', 0, 3, 0, NIL } ) //'Incluir'
aAdd( aRotina, { STR0006,'VIEWDEF.PLSA99A', 0, 4, 0, NIL } ) //'Alterar'
aAdd( aRotina, { STR0007,'VIEWDEF.PLSA99A', 0, 5, 0, NIL } ) //'Excluir'
aAdd( aRotina, { STR0008,'VIEWDEF.PLSA99A', 0, 8, 0, NIL } ) //'Imprimir'
aAdd( aRotina, { STR0009,'VIEWDEF.PLSA99A', 0, 9, 0, NIL } ) //'Copiar'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruB9I := FWFormStruct( 1, 'B9I', , )
Local oStruB9J := FWFormStruct( 1, 'B9J', , )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA99AMD', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'B9IMASTER', NIL, oStruB9I )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por grid
oModel:AddGrid( 'B9JDETAIL', 'B9IMASTER', oStruB9J, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


oModel:SetPrimaryKey({"B9I_FILIAL","B9I_CODINT","B9I_CODCLA"})


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B9JDETAIL', { { 'B9J_FILIAL', 'xFilial( "B9J" ) ' } ,;
	                                { 'B9J_CODCLA', 'B9I_CODCLA' } } ,  "B9J_FILIAL+B9J_CODCLA" )

// Indica que ้ opcional ter dados informados na Grid
oModel:GetModel( 'B9JDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B9IMASTER' ):SetDescription( STR0001 ) //'Classifica็ใo da Regiใo'

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0001) //'Classifica็ใo da Regiใo'

//Valida se existem codigos duplicados no aCols
oModel:GetModel('B9JDETAIL'):SetUniqueLine({'B9J_ESPECI'})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruB9J := FWFormStruct( 2, 'B9J' )
Local oStruB9I := FWFormStruct( 2, 'B9I' )

Local oModel   := FWLoadModel( 'PLSA99A' )
Local oView    := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B9I' , oStruB9I, 'B9IMASTER'   )     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B9J' , oStruB9J, 'B9JDETAIL'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID', 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B9I' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_B9J' , 'GRID'  )

oView:EnableTitleView( 'VIEW_B9J' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_B9J', 'B9J_SEQ' )   

Return oView  