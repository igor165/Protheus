#include "VDFA020.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFA020    ³ Autor ³ Totvs                    ³ Data ³ 19/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de Requisitos                                             ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivia F.      ³19/11/13³PRJ. M_RH001     ³-GSP-Cadastro de Requisitos                 ³±±
±±³              ³        ³REQ. 001851      ³                                            ³±±
±±³              ³        ³                 ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFA020  

Cadastro de Requisitos

@owner Tania Bronzeri
@author Tania Bronzeri
@since 11/06/2013
@version P11
@project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)

/*/
//-------------------------------------------------------------------
Function VDFA020()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('REV')
oBrowse:SetDescription(STR0001)//'Cadastro de Requisitos'
oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.VDFA020' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.VDFA020' OPERATION 3 ACCESS 0//'Incluir'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.VDFA020' OPERATION 4 ACCESS 0//'Alterar'
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.VDFA020' OPERATION 5 ACCESS 0//'Excluir'
ADD OPTION aRotina TITLE STR0006   ACTION 'VIEWDEF.VDFA020' OPERATION 8 ACCESS 0//'Imprimir'
ADD OPTION aRotina TITLE STR0007     ACTION 'VIEWDEF.VDFA020' OPERATION 9 ACCESS 0//'Copiar'
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruREV := FWFormStruct( 1, 'REV', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('VDFA020M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('VDFA020M', /*bPreValidacao*/, { |oMdl| VDFA020POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'REVMASTER', /*cOwner*/, oStruREV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0008 )//'Modelo de Dados de Requisitos'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'REVMASTER' ):SetDescription( STR0009 )//'Dados de Requisitos'

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'VDFA020' )
Local oStruREV := FWFormStruct( 2, 'REV' )
Local oView  
Local cCampos := {}

oStruREV:RemoveField( 'REV_FILIAL' )
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_REV', oStruREV, 'REVMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_REV', 'TELA' )

Return oView
