#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATACHI.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATACHI   �Autor  �Gabriela Kamimoto   � Data �  11/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Series pata Factura de Entrada.                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MATACHI                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function MATACHI()
 
dbSelectArea("SDV")
dbSetOrder(1)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SDV')
oBrowse:SetDescription(STR0006) //"Cadastro de Series"
oBrowse:Activate()
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Gabriela Kamimoto   � Data �  11/04/11	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados em MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATACHI                                                     ���
�������������������������������������������������������������������������ͼ��           	
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruSDV := FWFormStruct(1,'SDV', /*bAvalCampo*/,/*lViewUsado*/ )

Local bCommit		:= {|oMdl|MATACHICmt(oMdl)}		//Gravacao dos dados

oModel := MPFormModel():New('MATACHI', /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/ )
oModel:AddFields('SDVMASTER',/*cOwner*/,oStruSDV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0006)
oModel:SetPrimaryKey({})

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Gabriela Kamimoto   � Data �  11/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de Tipos de tarefas em     ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �MATACHI                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('MATACHI')
Local oStruSDV := FWFormStruct(2,'SDV')  
   

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SDV',oStruSDV,'SDVMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_SDV','TELA') 
  
Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Gabriela Kamimoto     � Data �11/04/11  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATACHI                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina := {}


ADD OPTION aRotina TITLE STR0001  ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0002  ACTION 'VIEWDEF.MATACHI'	OPERATION 2	ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0003  ACTION 'VIEWDEF.MATACHI'	OPERATION 3	ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0004  ACTION 'VIEWDEF.MATACHI'	OPERATION 4	ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0005  ACTION 'VIEWDEF.MATACHI'	OPERATION 5	ACCESS 0  //"Excluir"

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATACHICmt�Autor  �Gabriela Kamimoto   � Data �  11/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario, substi-���
���          �tuindo a gravacao padrao do MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATACHI                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MATACHICmt(oMdl)

Local aArea			:= GetArea()
Local nOperation	:= oMdl:GetOperation()
Local lRet          := .T.

FWModelActive( oMdl )
FWFormCommit( oMdl )

RestArea( aArea )

Return (lRet)
                       
