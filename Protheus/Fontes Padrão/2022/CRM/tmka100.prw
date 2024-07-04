#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA100.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmkA100   � Autor � Vendas CRM		    � Data � 26/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de grupos DAC 						              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TmkA100(void)                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TmkA100()
Local oBrowse	:= Nil

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGI')
oBrowse:SetDescription(STR0001) //STR0001 "Grupos Dac"
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
���Uso       �TmkA100                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruAGI := FWFormStruct(1,'AGI',/*bAvalCampo*/,/*lViewUsado*/)
Local bCommit	:= {|oMdl|TMKA100Cmt(oMdl)}		//Gravacao dos dados

oModel := MPFormModel():New('TMKA100',/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)
oModel:AddFields('AGIMASTER',/*cOwner*/,oStruAGI,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
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
���Uso       �TmkA100                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA100')
Local oStruAGI := FWFormStruct(2,'AGI')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_AGI', oStruAGI,'AGIMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_AGI','TELA')

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
���Uso       �TmkA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA100'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA100'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA100'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.TMKA100'	OPERATION 5	ACCESS 0


Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA100Cmt� Autor � Vendas CRM         � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario, substi-���
���          �tuindo a gravacao padrao do MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA100                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMKA100Cmt(oMdl)
Local lRet := .T.
Local nOperation := oMdl:GetOperation()

if nOperation == 5
	DbSelectArea("AGI")
	DbSelectArea("AGJ")
	DbSetOrder(1)
	
	If DbSeek(xFilial("AGJ") + AGI->AGI_COD)
	    lRet := .F.
		msgAlert(STR0002)		//Esse grupo DAC n�o pode ser excluido porque est� associado � um Grupo de Atendimento
		Return(lRet)
	EndIf
	
EndIf

FWModelActive(oMdl)
FWFormCommit(oMdl)

Return(lRet)


