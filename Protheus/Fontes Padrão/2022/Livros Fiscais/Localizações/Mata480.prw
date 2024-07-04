#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MATA480.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MATA480   � Autor � Vendas CRM		    � Data � 17/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manuten��o de Categoria de pedido de Vendas                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGAFAT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
Function MATA480()

Local oBrowse             

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGR')
oBrowse:SetDescription(STR0001) //Categorias de Pedidos de Vendas
oBrowse:DisableDetails()

oBrowse:Activate()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 17/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina   retorna a array com lista de aRotina              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATA480                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'        	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA480'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA480' 	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA480' 	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MATA480' 	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.MATA480' 	OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.MATA480'	OPERATION 9 ACCESS 0 //"Copiar"

Return( aRotina )

/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ��
���Programa  �ModelDef  � Autor � Vendas CRM         � Data �  17/01/11 ���
�����������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados da Manutencao de Categoria de    ���
���          �Pedido de Vendas.											���
�����������������������������������������������������������������������͹��
���Uso       �MATA480                                                   ���
�����������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/

Static Function ModelDef() 

Local oStruZB1 := FWFormStruct(1,'AGR',/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   := Nil

oModel := MPFormModel():New('MATA480',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AGRPAI',/*cOwner*/,oStruZB1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({'AGR_FILIAL','AGR_COD'},{'AGR_DESCRI'})

oModel:SetDescription(STR0001)
oModel:GetModel('AGRPAI'):SetDescription(STR0001)

Return( oModel )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   � Autor � Vendas CRM         � Data �  17/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro da Manutencao de Categoria ���
���          �de Pedido de Vendas.                                        ���
�������������������������������������������������������������������������͹��
���Uso       �MATA480                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oModel   := FWLoadModel('MATA480')
Local oStruZB1 := FWFormStruct(2,'AGR')
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )


oView:AddField('VIEW_AGR',oStruZB1,'AGRPAI')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_AGR','TELA')

Return( oView )