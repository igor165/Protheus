#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MATA481.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MATA481   � Autor � Vendas CRM		    � Data � 17/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manuten��o de associa��o de Usuario Vs Categoria de Pedido ���
���          � de venda.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
���M.Camargo   �29/07/14�TPYEZ0�Quitar Ajustahlp                          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/


Function MATA481()
                                            
Local oBrowse	:= Nil

//AjustaHlp() //"Ajusta Help"

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGS')
oBrowse:SetDescription(STR0006)  //"Meta de Venda"
oBrowse:Activate()

Return(.T.)

/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ��
���Programa  �ModelDef  � Autor � Vendas CRM         � Data � 17/01/11  ���
�����������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados para Associacao de Usuarios Vs   ���
���          �categorias de pedidos de vendas.                          ���
�����������������������������������������������������������������������͹��
���Uso       �MATA481                                                   ���
�����������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/

Static Function ModelDef()

Local oModel
Local oStruCab := FWFormStruct(1,'AGS',{|cCampo| AllTrim(cCampo)+"|" $ "AGS_FILIAL|AGS_USER|AGS_NOME|"})
Local oStruGrid := FWFormStruct(1,'AGS')

oStruGrid:RemoveField('AGS_USER')
oStruGrid:RemoveField('AGS_NOME')

oModel := MPFormModel():New('MATA481',/*bPreValidacao*/,/*..bPosValidacao*/,/*..bCommit*/,/*..bCancel*/)
oModel:AddFields('AGSCAB',/*cOwner*/,oStruCab,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid( 'AGSGRID','AGSCAB',oStruGrid,/*bLinePre*/,/*..bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oModel:SetRelation("AGSGRID",{{"AGS_FILIAL",'xFilial("AGS")'},{"AGS_USER","AGS_USER"}},AGS->(IndexKey(1)))
oModel:SetPrimaryKey({'AGS_FILIAL','AGS_USER'})       
oModel:GetModel('AGSGRID'):SetUniqueLine({'AGS_TIPO'})
//oModel:SetDescription("Descri��o do model")
                                     
Return(oModel)

/*                               
�����������������������������������������������������������������������
�����������������������������������������������������������������������
�������������������������������������������������������������������ͻ��
���Programa  �ViewDef   � Autor � Vendas CRM      � Data � 17/01/11 ���
�������������������������������������������������������������������͹��
���Desc.     �Define a interface para Manutencao da Associacao de   ���
���          �usuarios Vs Categorias de Pedidos de Vendas           ���
�������������������������������������������������������������������͹��
���Uso       �MATA481                                               ���
�������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������
�����������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView

Local oModel     := FWLoadModel('MATA481')
Local oStruCab   := FWFormStruct(2,'AGS',{|cCampo| AllTrim(cCampo)+"|" $ "AGS_FILIAL|AGS_USER|AGS_NOME|"})
Local oStruGrid   := FWFormStruct(2,'AGS')
Local oMdlCab    := oModel:GetModel('AGSCAB')
Local oMdlGrid    := oModel:GetModel('AGSGRID')

oStruGrid:RemoveField('AGS_USER')
oStruGrid:RemoveField('AGS_NOME')


oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruCab,'AGSCAB')
oView:AddGrid('VIEW_GRID',oStruGrid,'AGSGRID' )

oView:CreateHorizontalBox('SUPERIOR',15)
oView:CreateHorizontalBox('INFERIOR',85)

oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )
oView:SetOwnerView( 'VIEW_GRID','INFERIOR' )

Return(oView)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 17/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina retorna a array com lista de aRotina                ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATA481                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :={}

ADD OPTION aRotina TITLE STR0001 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0 //Pesquisar
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MATA481'	OPERATION 2	ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA481'	OPERATION 3	ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA481'	OPERATION 4	ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA481'	OPERATION 5	ACCESS 0 //Excluir

Return(aRotina)