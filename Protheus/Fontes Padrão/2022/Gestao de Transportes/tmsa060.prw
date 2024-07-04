#Include "FWMVCDEF.CH"
#INCLUDE "tmsa060.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSA060  � Autor �Patricia A. Salomao    � Data �06.11.2001  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Despesas de Transporte                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA060()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                          ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaTMS - Gestao de Transporte                               ���
���������������������������������������������������������������������������Ĵ��
���Comentario�                                                              ���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                           ���
���������������������������������������������������������������������������Ĵ��
��� 17/10/13 � Mauro Paladini�Conversao da rotina para o padrao MVC         ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function TMSA060()

Local oBrowse 	:= Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DT7")
oBrowse:SetDescription(STR0001) //"Despesas de Transporte"
oBrowse:Activate()

Return Nil

 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �17.10.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()

Local oModel	:= Nil
Local oStruDT7	:= FWFormStruct(1,"DT7")

Local bPreValid	:= Nil
Local bPosValid := Nil
Local bCommit 	:= Nil
Local bCancel	:= Nil

oModel:= MpFormMOdel():New("TMSA060",  /*bPreValid*/ , /*bPosValid*/ , /*bCommit*/ ,/*bCancel*/ )
oModel:AddFields("MdFieldDT7",Nil,oStruDT7,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 	//"Despesas de Transporte"
oModel:GetModel("MdFieldDT7"):SetDescription(STR0001) //"Despesas de Transporte"
oModel:SetPrimaryKey({ "DT7_FILIAL","DT7_CODDES" })

Return ( oModel )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �17.10.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ViewDef()

Local oModel 	:= FwLoadModel("TMSA060")
Local oStruDT7	:= FWFormStruct(2,"DT7")
Local oView 	:= Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDT7', oStruDT7 , 'MdFieldDT7') 
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDT7","TELA")

Return(oView)




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �11.10.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA060" OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA060" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA060" OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA060" OPERATION 5 ACCESS 0  //"Excluir"

Return ( aRotina )
