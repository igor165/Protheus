#INCLUDE "TMKA530Q.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �TmkA510I  � Autor � Vendas CRM		    � Data � 26/10/10   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de entidades autorizadas para contrato de SLA        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TmkA530Q(void)                                           ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                       ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function TmkA530Q()
Local oBrowse	:= Nil
 
//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SKX')
oBrowse:SetDescription(STR0001) //"Entidades habilitadas para controle de SLA"
oBrowse:Activate()

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  � Autor � Vendas CRM         � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento (MVC)      ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA530Q                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruSKX := FWFormStruct(1,'SKX',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('TMKA530Q',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('SKXMASTER',/*cOwner*/,oStruSKX,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetDescription(STR0001)

Return(oModel)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   � Autor � Vendas CRM         � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de atendimento em ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA530Q                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA530Q')
Local oStruSKX := FWFormStruct(2,'SKX')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SKX', oStruSKX,'SKXMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_SKX','TELA')

Return(oView)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 26/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina   retorna a array com lista de aRotina              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TmkA530Q                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMKA530Q'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA530Q'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA530Q'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA530Q'	OPERATION 5	ACCESS 0


Return(aRotina)
