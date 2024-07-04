#INCLUDE "TMSA015.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMSA015   �Autor  �Marcelo C. Coutinho � Data �  28/08/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Prioridades - Agendamento de Entrega.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TMSA015                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSA015()
dbSelectArea("DYK")
dbSetOrder(1)
	
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DYK')
oBrowse:SetDescription(STR0001) // Cadastro de Prioridades

//-- Legenda
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '1'", "YELLOW", "Amarelo"  )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '2'", "BLUE"  , "Azul"     )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '3'", "WHITE" , "Branco"   )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '4'", "GRAY"  , "Cinza"    )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '5'", "ORANGE", "Laranja"  )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '6'", "BROWN" , "Marrom"   )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '7'", "BLACK" , "Preto"    )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '8'", "PINK"  , "Rosa"     )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== '9'", "GREEN" , "Verde"    )
oBrowse:AddLegend( "AllTrim(DYK_CORPRI)== 'A'", "RED"   , "Vermelho" )
//--
oBrowse:Activate()                                     
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Marcelo C. Coutinho   � Data �  28/08/12 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados em MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �TMSA015                                                     ���
�������������������������������������������������������������������������ͼ��           	
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruDYK := FWFormStruct(1,'DYK', /*bAvalCampo*/,/*lViewUsado*/ )

Local bCommit		:= {|oMdl|TMSA015Cmt(oMdl)}		//Gravacao dos dados

oModel := MPFormModel():New('TMSA015', /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/ )
oModel:AddFields('DYKMASTER',/*cOwner*/,oStruDYK, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription( STR0001) // Cadastro de Prioridades
oModel:SetPrimaryKey({})

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Marcelo C. Coutinho    � Data � 28/08/12 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de Tipos de tarefas em     ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �TMSA015                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   
                                                                                    
Local oView
Local oModel   := FWLoadModel('TMSA015')
Local oStruDYK := FWFormStruct(2,'DYK')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_DYK',oStruDYK,'DYKMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_DYK','TELA')
  
Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Marcelo C. Coutinho    � Data �28/08/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA015                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina  TITLE STR0002  ACTION 'PesqBrw' 		 OPERATION 1  ACCESS 0  //"Pesquisar"
ADD OPTION aRotina  TITLE STR0003  ACTION 'VIEWDEF.TMSA015'  OPERATION 2  ACCESS 0  //"Visualizar"
ADD OPTION aRotina  TITLE STR0004  ACTION 'VIEWDEF.TMSA015'  OPERATION 3  ACCESS 0  //"Incluir"
ADD OPTION aRotina  TITLE STR0005  ACTION 'VIEWDEF.TMSA015'  OPERATION 4  ACCESS 0  //"Alterar"
ADD OPTION aRotina  TITLE STR0006  ACTION 'VIEWDEF.TMSA015'  OPERATION 5  ACCESS 0  //"Excluir"

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMSA015Cmt�Autor  �Marcelo C. Coutinho   � Data � 28/08/12  ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario, substi-���
���          �tuindo a gravacao padrao do MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �TMSA015                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMSA015Cmt(oMdl)

Local aArea	:= GetArea()
Local lRet  := .T.

FWModelActive( oMdl )
FWFormCommit( oMdl )

RestArea( aArea )

Return (lRet)
