#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FATA360.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA360   �Autor  �			         � Data �  01/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro da tabela ADO - Cadastro de Categoria.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FATA360()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ADO')
oBrowse:SetDescription(STR0001)
oBrowse:Activate()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �			         � Data �  01/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Criacao do MenuDef.	  	                        		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Opcoes de menu    		                                  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA360                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FATA360' OPERATION 1 ACCESS 0  //Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA360' OPERATION 2 ACCESS 0  //Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA360' OPERATION 3 ACCESS 0  //Incluir
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA360' OPERATION 4 ACCESS 0  //Alterar
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA360' OPERATION 5 ACCESS 0  //Excluir

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �			         � Data �  01/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de Dados de categoria.     						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Modelo de Dados		                                      ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA360                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruABT := FWFormStruct( 1, 'ADO', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('CADCATEG', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'ADOMASTER', /*cOwner*/, oStruABT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados de Categoria' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ADOMASTER' ):SetDescription( 'Dados de Categoria' )

oModel:SetVldActivate({|oMdl| AT360EXCL(oMdl)})

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �			         � Data �  01/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface Tipo de visita.        							  ���
�������������������������������������������������������������������������͹��
���Retorno   �Interface                            			              ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA360                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FATA360' )
// Cria a estrutura a ser usada na View
Local oStruABT := FWFormStruct( 2, 'ADO' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ADO', oStruABT, 'ADOMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'BOX' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ADO', 'BOX' )

Return oView


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AT360EXCL �Autor  �Microsiga           � Data �  01/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verificar se a categoria n�o tem subcategorias para excluir ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FATA360                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AT360EXCL(oMdl)

Local aAreaADO	:= ADO->(GetArea())
Local lRet		:= .T.
Local cPai		:= ADO->ADO_CODIGO

ADO->( DBSetOrder( 2 ) )
If oMdl:GetOperation() == MODEL_OPERATION_DELETE
	If ADO->( DBSeek(xFilial("ADO")+cPai) )
		lRet := .F.         
		Help("",1,"AT360EXCL",,STR0008,2,0) //"N�o � possivel excluir esta categoria, possui subcategoria"
	EndIf
EndIf

RestArea(aAreaADO) 

Return lRet
