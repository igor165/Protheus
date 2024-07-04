#include "VDFA010.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFA010  ³ Autor ³ Totvs                      ³ Data ³ 19/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de Concursos.                                             ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivia F.      ³19/11/13³PRJ. M_RH001     ³-GSP-Cadastro de Concursos                  ³±±
±±³              ³        ³REQ. 001851      ³                                            ³±±
±±³              ³        ³                 ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFA010  

Cadastro de Concursos

@owner Tania Bronzeri
@author Tania Bronzeri
@since 11/06/2013
@version P11
@project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)

/*/
//-------------------------------------------------------------------
Function VDFA010()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('REW')
oBrowse:SetDescription(STR0001)//'Cadastro de Concursos'
oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.VDFA010' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.VDFA010' OPERATION 3 ACCESS 0//'Incluir'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.VDFA010' OPERATION 4 ACCESS 0//'Alterar'
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.VDFA010' OPERATION 5 ACCESS 0//'Excluir'
ADD OPTION aRotina TITLE STR0006   	ACTION 'VIEWDEF.VDFA010' OPERATION 8 ACCESS 0//'Imprimir'
ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.VDFA010' OPERATION 9 ACCESS 0//'Copiar'
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruREW := FWFormStruct( 1, 'REW', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
 

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('VDFA010M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('VDFA010M', /*bPreValidacao*/, { |oMdl| VDFA010POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'REWMASTER', /*cOwner*/, oStruREW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0008 )//'Modelo de Dados de Concursos'

oModel:SetPrimaryKey( { "REW_FILIAL", "REW_CODIGO" } )
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'REWMASTER' ):SetDescription( STR0009 )//'Dados de Concursos'

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'VDFA010' )
// Cria a estrutura a ser usada na View
Local oStruREW := FWFormStruct( 2, 'REW' )
//Local oStruREW := FWFormStruct( 2, 'REW', { |cCampo| VDFA010STRU(cCampo) } )
Local oView  
Local cCampos := {}


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_REW', oStruREW, 'REWMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_REW', 'TELA' )

//oView:SetViewAction( 'BUTTONOK'    , { |o| Help(,,'HELP',,'Ação de Confirmar ' + o:ClassName(),1,0) } )
//oView:SetViewAction( 'BUTTONCANCEL', { |o| Help(,,'HELP',,'Ação de Cancelar '  + o:ClassName(),1,0) } )
Return oView
