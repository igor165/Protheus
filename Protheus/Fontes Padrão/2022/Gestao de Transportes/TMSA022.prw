#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA022.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSA022  � Autor �Jefferson Tomaz        � Data �08.02.2011  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de CFOP x Segmento                                  ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaTMS - Gestao de Transporte                               ���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                           ���
���������������������������������������������������������������������������Ĵ��
��� 06/12/13 � Mauro Paladini�Ajustes para funcionamento do Mile            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������

*/

Function TMSA022()
Local oBrowse := Nil 

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DY5")
oBrowse:SetDescription(STR0001) // "Cadastro de CFOP x Segmento"

oBrowse:Activate()

Return(Nil)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSA022  � Autor �Jefferson Tomaz        � Data �08.02.2011  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de CFOP x Segmento - Model                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ModelDef()
LOCAL oStruDY5 := FWFormStruct(1,"DY5")
Local oModel

oModel:= MpFormMOdel():New("TMSA022M",/*PREVAL*/,/*POSVAL*/,/*BCOMMIT*/,/*BCANCEL*/)
oModel:AddFields("DY5MASTER",Nil,oStruDY5,/*prevalid*/,/*Posvald*/,/*bCarga*/)
oModel:SetDescription(STR0001) // "Cadastro de CFOP x Segmento" --  Metodo XML
oModel:GetModel("DY5MASTER"):SETDESCRIPTION(STR0001) // "Cadastro de CFOP x Segmento"
oModel:SetPrimaryKey({"DY5_FILIAL","DY5_CF","DY5_SATIV"})

Return oModel

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSA022  � Autor �Jefferson Tomaz        � Data �08.02.2011  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de CFOP x Segmento - ViewDef                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oModel := FwLoadModel("TMSA022")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField("DY5MASTER", FWFormStruct(2,"DY5"))
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("DY5MASTER","TELA")

Return(oView)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSA022  � Autor �Jefferson Tomaz        � Data �08.02.2011  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de CFOP x Segmento - MenuDef                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.TMSA022" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.TMSA022" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.TMSA022" OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.TMSA022" OPERATION 5 ACCESS 0 // "Excluir"

Return aRotina 
