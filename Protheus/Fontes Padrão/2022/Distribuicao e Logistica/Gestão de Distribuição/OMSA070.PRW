#include "Protheus.ch"
#Include "FWMVCDEF.CH"
#include "OMSA070.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OMSA070  � Autor � Waldemiro L. Lustosa  � Data � 18.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA08  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Percursos                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  � Cristiane Moreto - Convers�o p/ Protheus � Data � 19.01.00 ���
���          � OMSA070.                                 �      �          ���
��� RevisAO  � Mauro Paladini : Conversao para MVC      � Data � 12.08.13 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function OMSA070()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DA5")
oBrowse:SetDescription(STR0001) // "Cadastro de Zonas"
oBrowse:Activate()

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �09.08.2013���
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
Local oStruDA5	:= FWFormStruct(1,"DA5")

Local bPreValid	:= Nil
Local bPosValid := { |oMdl| A070Vdel(oMdl) }
Local bComValid := Nil
Local bCancel	:= Nil

oModel:= MpFormMOdel():New("OMSA070",  /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
oModel:AddFields("MdFieldDA5",Nil,oStruDA5,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 	// "Cadastro de Zonas"
oModel:GetModel("MdFieldDA5"):SetDescription(STR0001) // "Cadastro de Zonas"

Return ( oModel )                   



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �09.08.2013���
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

Local oModel := FwLoadModel("OMSA070")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDA5', FWFormStruct(2,"DA5") , 'MdFieldDA5') 
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDA5","TELA")

Return(oView)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �09.08.2013���
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

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.OMSA070" OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.OMSA070" OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.OMSA070" OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.OMSA070" OPERATION 5 ACCESS 0   //"Excluir"

Return ( aRotina )



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A070VDEL � Autor � Waldemiro L. Lustosa  � Data � 29.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA081 �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Percursos (Controle de Dele��o)                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  � Cristiane Moreto - Convers�o p/ Protheus � Data � 19.01.00 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A070Vdel(oMdl)

Local lRet  := .T.
Local aArea := GetArea()

If oMdl == Nil .Or. oMdl:GetOperation() == MODEL_OPERATION_DELETE

	dbSelectArea("DA6")
	dbSetOrder(1)
	If	dbSeek(xFilial("DA6")+DA5->DA5_COD)
		lRet := .F.
		Help(" ",1,"DS0700811") //"Zona j� utilizada no Cadastro de Setores por Zona, exclus�o n�o permitida."
	EndIf

Endif

RestArea(aArea)

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Oms070Cal � Autor � Henry Fila            � Data � 05.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA081 �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Percursos (Controle de Dele��o)                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  � Cristiane Moreto - Convers�o p/ Protheus � Data � 19.01.00 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Oms070Cal()

Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaDA6 := DA6->(GetArea())
DA6->(dbSetOrder(1))
If	DA6->(MsSeek(xFilial("DA6")+M->DA5_COD))
	While DA6->(!Eof()).And. DA6->DA6_FILIAL == xFilial("DA6") .And.;
								DA6->DA6_PERCUR == M->DA5_COD .And. lRet
		If !Empty(DA6->DA6_CODCAL)
			lRet := OmsVldCal(M->DA5_CODCAL,DA6->DA6_CODCAL)
			If !lRet
				Help(" ",1,"OMS070CAL") //"Existem setores associados � zona que possuem calend�rios n�o compat�veis com o selecionado."
			EndIf
		EndIf
		DA6->(dbSkip())
	EndDo
EndIf
RestArea(aAreaDA6)
RestArea(aArea)

Return(lRet)
