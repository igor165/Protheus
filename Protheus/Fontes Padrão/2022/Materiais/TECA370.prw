#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"     
#Include "TECA370.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CADTPVIS  �Autor  �			         � Data �  12/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro da tabela ABT - Tipo de visita.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TECA370()

Local oBrowse     

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ABT')
oBrowse:SetDescription(STR0001) //'Cadastro Tipo de Vistoria T�cnica'
oBrowse:Activate()

Return Nil  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �			         � Data �  10/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Criacao do MenuDef.	  	                        		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Opcoes de menu    		                                  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �TECA370                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TECA370' OPERATION 1 ACCESS 0  //'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA370' OPERATION 2 ACCESS 0  //'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TECA370' OPERATION 3 ACCESS 0  //'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TECA370' OPERATION 4 ACCESS 0  //'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TECA370' OPERATION 5 ACCESS 0  //'Excluir'

Return aRotina
              
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �			         � Data �  10/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de Dados de Tipo de visita.  						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Modelo de Dados		                                      ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �TECA370                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruABT := FWFormStruct( 1, 'ABT', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
 
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('CADTPVIS', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'ABTMASTER', /*cOwner*/, oStruABT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 ) //'Modelo de Dados de Tipo de Vistoria T�cnica'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ABTMASTER' ):SetDescription( STR0008 ) //'Dados de Tipo de Vistoria T�cnica'

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �			         � Data �  10/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface Tipo de visita.        							  ���
�������������������������������������������������������������������������͹��
���Retorno   �Interface                            			              ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �TECA370                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef() 

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'TECA370' )
// Cria a estrutura a ser usada na View
Local oStruABT := FWFormStruct( 2, 'ABT' )
Local oView  

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ABT', oStruABT, 'ABTMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ABT', 'TELA' )

Return oView