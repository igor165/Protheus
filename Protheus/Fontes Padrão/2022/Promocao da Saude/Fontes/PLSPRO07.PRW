#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSPRO07.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPRO07   บAutor  ณMicrosiga           บ Data ณ  09/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro das Faixas Padrใo de Crescimento Grafico          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE VERSAO 11.5                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSPRO07()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'GTU' )
oBrowse:SetDescription(STR0001)// "Faixa de Crescimento Grafico" 
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0002 	, 				'PesqBrw'         , 0, 1, 0, .T. } )//'Pesquisar'
aAdd( aRotina, { STR0003		, 				'VIEWDEF.PLSPRO07', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0004   , 				'VIEWDEF.PLSPRO07', 0, 3, 0, NIL } ) //'Incluir'
aAdd( aRotina, { STR0005   , 				'VIEWDEF.PLSPRO07', 0, 4, 0, NIL } ) //'Alterar'
aAdd( aRotina, { STR0006   , 				'VIEWDEF.PLSPRO07', 0, 5, 0, NIL } ) //'Excluir'
aAdd( aRotina, { STR0007  	, 				'VIEWDEF.PLSPRO07', 0, 8, 0, NIL } ) //'Imprimir'


Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruGTU := FWFormStruct( 1, 'GTU', , )


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )  //"Faixa de Crescimento Grafico" 

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'GTUMASTER', NIL, oStruGTU )


// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'GTUMASTER' ):SetDescription( STR0001 )//"Faixa de Crescimento Grafico" 

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )  //"Faixa de Crescimento Grafico"

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  


// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSPRO07' )
Local oStruGTU := FWFormStruct( 2, 'GTU' ) 
Local oView    := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GTU' , oStruGTU, 'GTUMASTER'   )     


// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 100 )



// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_GTU' , 'GERAL'  )



Return oView  
