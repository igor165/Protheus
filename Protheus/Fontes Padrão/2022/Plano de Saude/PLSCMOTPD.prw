#INCLUDE "PLSCMOTPD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSCMOTPD   บAutor  ณRoberto Vanderlei บ Data ณ  05/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Motivo Padrใo para Itera็๕es 					 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE VERSAO                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSCMOTPD()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BBP' )
oBrowse:SetDescription(STR0001) //'Cadastro Tipo Documento'
oBrowse:Activate()

Return( NIL ) 

//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'        , 0, 1, 0, .T. } )
aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSCMOTPD', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 				'VIEWDEF.PLSCMOTPD', 0, 3, 0, NIL } ) 
aAdd( aRotina, { 'Alterar'   , 				'VIEWDEF.PLSCMOTPD', 0, 4, 0, NIL } ) 
aAdd( aRotina, { 'Excluir'   , 				'VIEWDEF.PLSCMOTPD', 0, 5, 0, NIL } )
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
LOCAL oModelNOT

// Cria o objeto do Modelo de Dados

Local oStrBBP:= FWFormStruct(1,'BBP')

oStrBBP:SetProperty( 'BBP_DESMOT' , MODEL_FIELD_OBRIGAT, .T.)
oStrBBP:SetProperty( 'BBP_OBSERV' , MODEL_FIELD_OBRIGAT, .T.)
oStrBBP:SetProperty( 'BBP_SEQUEN' , MODEL_FIELD_WHEN, {||.F.})

oModelNOT := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModelNOT:AddFields( 'BBPMASTER', NIL, oStrBBP )
oModelNOT:SetPrimaryKey( { "BBP_FILIAL", "BBP_SEQUEN, BBP_DESMOT" } ) 

// Adiciona a descricao do Modelo de Dados
oModelNOT:SetDescription( STR0001 )

// Adiciona a descricao do Componente do Modelo de Dados
oModelNOT:GetModel( 'BBPMASTER' ):SetDescription( STR0001 )

Return oModelNOT

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSCMOTPD' )
Local oStruBBP := FWFormStruct(2, 'BBP')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado

oView:SetModel( oModel )
oView:AddField('BBP' , oStruBBP,'BBPMASTER' )

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMBBP', 100, 'BOX1')

oView:SetOwnerView('BBP','FORMBBP')

Return oView