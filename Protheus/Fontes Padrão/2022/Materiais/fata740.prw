#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FATA740.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FatA740   � Autor � Vendas CRM		    � Data � 10/02/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Responsavel x Grupo de Produtos em (MVC) 		              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function FatA740 

Local oBrowse	:= Nil //Objeto oBrowse
                                                                                 
//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGV')
oBrowse:SetDescription(STR0001)
oBrowse:Activate()

Return(.T.)


/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  10/02/11 ���
�����������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento.         ���
�����������������������������������������������������������������������͹��
���Uso       �FatA740                                                   ���
�����������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruAGV 	:= FWFormStruct(1,'AGV',/*bAvalCampo*/,/*lViewUsado*/)
Local oStruAGX 	:= FWFormStruct(1,'AGX',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('FATA740',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AGVMASTER', /*cOwner*/,oStruAGV, /*bPreValidacao*/,/*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'AGXDETAIL','AGVMASTER',oStruAGX,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/) 
oModel:SetRelation( 'AGXDETAIL',{{'AGX_FILIAL','xFilial("AGX")'},{'AGX_CODRSP','AGV_CODUSR'}} ,'AGX_FILIAL+AGX_CODRSP+AGX_GRUPO')
oModel:GetModel('AGXDETAIL'):SetUniqueLine({'AGX_GRUPO'})
oModel:SetDescription(STR0001)

Return(oModel)                                                          

/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  10/02/11 ���
�����������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro Responsaveis x Grupos de ���
���          �produtos.                                                 ���
�����������������������������������������������������������������������͹��
���Uso       �FatA740                                                   ���
�����������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('FATA740')
Local oStruAGV := FWFormStruct(2,'AGV')
Local oStruAGX := FWFormStruct(2,'AGX')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_AGV', oStruAGV, 'AGVMASTER' )
oView:AddGrid( 'VIEW_AGX', oStruAGX, 'AGXDETAIL' )
oView:CreateHorizontalBox('SUPERIOR', 10 )
oView:CreateHorizontalBox('INFERIOR', 90 )
oView:SetOwnerView( 'VIEW_AGV','SUPERIOR' )
oView:SetOwnerView( 'VIEW_AGX','INFERIOR' )


Return(oView)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 10/02/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina   retorna a array com lista de aRotina              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FatA740                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA740'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA740'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA740'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA740'	OPERATION 5	ACCESS 0

Return(aRotina)



/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Programa  �Ft740REmail�Autor  �Vendas CRM          � Data �  10/02/11 ���
������������������������������������������������������������������������͹��
���Desc.     �Retorna o e-mail do usuario cadastrado no configurador. 	 ���
������������������������������������������������������������������������͹��
���Uso       �FatA740                                                    ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/

Function Ft740REmail()   

Local oMdl 	 	:= FWModelActive() 			
Local oMdlAGV 	:= oMdl:GetModel('AGVMASTER')
Local cCodUsr   := AllTrim(oMdlAGV:GetValue('AGV_CODUSR')) 	//Codigo do Usuario
Local aDadUsr 	 := {}    						   			//Array que contem os dados do usuario
Local cEmailUsr  := ' '  									//Armazena o e-mail do usuario

aDadUsr := FWSFAllUsers({cCodUsr})	 //Retorna os dados do usuario.

If !Empty(aDadUsr[1][5]) 
	oMdlAGV:SetValue('AGV_MAILAL',AllTrim(aDadUsr[1][5]))
EndIf

Return(.T.)     

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Programa  �Ft740VEMail�Autor  �Vendas CRM          � Data �  10/02/11 ���
������������������������������������������������������������������������͹��
���Desc.     �Valida se o email digitado pelo usuario e valido.      	 ���
������������������������������������������������������������������������͹��
���Uso       �FatA740                                                    ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/

Function Ft740VEMail()

Local lRet := .T.     									//Retorno da validacao
Local oMdl 	 	:= FWModelActive()
Local oMdlAGV 	:= oMdl:GetModel('AGVMASTER')
Local cEmail    := AllTrim(oMdlAGV:GetValue('AGV_MAILAL'))


If !IsEMail(cEmail)
	Help(" ",1,"FTEMAIL")
	lRet := .F.
EndIf

Return(lRet)





