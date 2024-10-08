#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA510F.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �TmkA510F          � Autor � Vendas CRM      � Data �  11/01/08    ���
�������������������������������������������������������������������������������͹��
���Desc.     |Programa para atualizacao do cadastro de Etapas QNC x Ocorrencia. ��� 
���          �                                                                  ���
�������������������������������������������������������������������������������͹��
���Uso       � SIGATMK                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������     
*/    

Function TmkA510F()
Local oBrowse	:= Nil   

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SKQ')
oBrowse:SetDescription(STR0001)  // "Etapas QNC x Ocorrencia"
oBrowse:Activate()

Return(.T.)   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento (MVC)      ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA510F                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruSKQ := FWFormStruct(1,'SKQ',/*bAvalCampo*/,/*lViewUsado*/)  
Local aAuxTrig := FwStruTrigger("KQ_CODSUQ","KQ_NMSUQ","POSICIONE('SUQ',1,xFilial('SUQ')+FwFldGet('KQ_CODSUQ'),'UQ_DESC')",.F.,Nil,Nil,Nil)

oStruSKQ:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])  
 
oModel := MPFormModel():New('TMKA510F',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('SKQMASTER',/*cOwner*/,oStruSKQ,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({' '})
oModel:SetDescription(STR0001)

Return(oModel)                      
                                     

                                                                          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de atendimento em ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA510F                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('TMKA510F')
Local oStruSKQ := FWFormStruct(2,'SKQ')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SKQ', oStruSKQ,'SKQMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_SKQ','TELA') 

Return(oView)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 25/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina   retorna a array com lista de aRotina              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TmkA510F                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMKA510F'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA510F'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA510F'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA510F'	OPERATION 5	ACCESS 0


Return(aRotina)   