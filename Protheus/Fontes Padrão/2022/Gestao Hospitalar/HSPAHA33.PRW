#INCLUDE "HSPAHA33.ch"
#include "protheus.CH"
#include "colors.CH"
#INCLUDE 'FWMVCDEF.CH' //Necessita desse include quando usar MVC.

/*/HSPAHA33


@author Saúde
@since 06/15
@version P11.8
/*/

Function HSPAHA33()
Local oBrowse
Local cFiltraSX5  :=""
Private cCadastro := STR0001 //"Justificativas de nao Atendto de Solicitacao"
Private cTab      := "JV"

cFiltraSX5  :="X5_TABELA = '"+cTab+"'"

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SX5' )
oBrowse:SetDescription( cCadastro )
oBrowse:SetFilterDefault(cFiltraSx5)
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0002 , 				'PesqBrw'         , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0003, 			   		'HSAHA331(2)', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0004  , 				'HSAHA331(3)', 0, 3, 0, NIL } )//'Incluir'
aAdd( aRotina, { STR0005  , 				'HSAHA331(4)', 0, 4, 0, NIL } )//'Alterar'
aAdd( aRotina, { STR0006  , 				'HSAHA331(5)', 0, 5, 0, NIL } )//'Excluir'




Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSX5 := FWFormStruct( 1, 'SX5', /*bAvalCampo*/, /*lViewUsado*/ )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( cCadastro, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SX5MASTER', NIL, oStruSX5 )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( cCadastro ) 

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SX5MASTER' ):SetDescription( cCadastro ) 
//Seta Chaves primarias
oModel:SetPrimaryKey({})


Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruSX5 := FWFormStruct( 2, 'SX5', /*bAvalCampo*/, /*lViewUsado*/ )
 

 // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'HSPAHA33' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_SX5' , oStruSX5, 'SX5MASTER'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SX5' , 'GERAL'  )

oView:EnableTitleView( 'VIEW_SX5' )

Return oView 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HSPAHA331 ³ Autor ³  Manoel            ³ Data ³ 11/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Inclusao/Alteracao/Visualizacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSAHA331(nOpc)

 cSayCpo1 := STR0007 //"Codigo"
 cSayCpo2 := STR0008 //"Justificativa"

 HS_TelSx5('HS_Exc33()','HS_Check33()',nOpc)

Return


Function HS_Check33()

if DbSeek(xFilial("SX5")+"JV"+M->X5_CHAVE)
   HS_MsgInf(STR0009, STR0011, STR0001)     //"Ja existe este Codigo de Justificativa. Favor cadastrar outro Codigo!"###"Atencao"###"Justificativas de nao Atendto de Solicitacao"
   return .f.
Endif

return .t.


// Funcao de Exclusao
Function HS_Exc33()
        
DbSelectArea("GAJ")
DbSetOrder(1)
if DbSeek(xFilial("GAJ")+M->X5_CHAVE)
   HS_MsgInf(STR0010, STR0011, STR0001)  //"Existe esta Justificativa no Arquivo de Solicitacoes (GAJ). Impossivel Exclui-lo!"###"Atencao"###"Justificativas de nao Atendto de Solicitacao"
   return .f.
Endif
          
nOpca := 1
oDlg:End()          

Return .t.











