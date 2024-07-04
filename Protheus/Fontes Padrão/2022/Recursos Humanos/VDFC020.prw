#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Funcao    � VDFC020  � Autor � Totvs                      � Data � 17/12/2013 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Historico de Adidos/Cedidos                                        ���
���          �                                                                   ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                          ���
��������������������������������������������������������������������������������Ĵ��
���              ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               �����������
����������������������������������������������������������������������������������������Ŀ��
���Programador   � Data   � PRJ/REQ-Chamado �  Motivo da Alteracao                       ���
����������������������������������������������������������������������������������������Ĵ��
���Nivia F.      �17/12/13�PRJ. M_RH001     �-GSP-Historico de Adidos/Cedidos            ���
���              �        �REQ. 002095      �                                            ���
���              �        �                 �                                            ���
�����������������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFC020  

Historico de Adidos/Cedidos

@owner Nivia Ferreira
@author Nivia Ferreira
@since 17/12/2013
@version P11
@project GEST�O DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)

/*/
//-------------------------------------------------------------------
Function VDFC020()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('RID')
oBrowse:SetDescription('Historico de Adidos/Cedidos')//'Historico de Adidos/Cedidos'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VDFC020' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VDFC020' OPERATION 4 ACCESS 0//'Alterar'
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRID := FWFormStruct( 1, 'RID', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
 

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('VDFC020M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'RIDMASTER', /*cOwner*/, oStruRID, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados de Adidos/Cedidos' )//'Modelo de Dados de Adidos/Cedidos'

oModel:SetPrimaryKey( { "RID_FILIAL", "RID_MAT" } )
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'RIDMASTER' ):SetDescription( 'Historico de Adidos/Cedidos' )//'Historico de Adidos/Cedidos'

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'VDFC020' )
Local oStruRID := FWFormStruct( 2, 'RID' )
// Cria a estrutura a ser usada na View
Local oView  


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_RID', oStruRID, 'RIDMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_RID', 'TELA' )

//Desabilita bot? "Salvar e Criar Novo"
oView:SetCloseOnOk({ || .T. })		

Return oView
