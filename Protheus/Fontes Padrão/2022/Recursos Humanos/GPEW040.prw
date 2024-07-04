#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "GPEW020.CH"

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEW040  � Autor � Flavio S Correa           � Data �19/09/19  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � WorkArea - M�dias					                          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                       ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS/FNC �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������Ĵ��
���Flavio Corr �26/03/15�PCREQ-4161 �Inclusao Fonte			                  ���
���Flavio Corr �21/09/16�RHRH001-402�Ajustes de menu		                  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/   
Function GPEW040(oObj)

Default oObj	:= Nil

Private oBrwSRV
Private oBrwRCE
Private oBrwRCA

FWMsgRun(/*oComponent*/, { || WkMedia(oObj ) }, "Aguarde", "Carregando �rea de Trabalho..." )		// "Aguarde"		"Carregando �rea de Trabalho..."

Return .T.


Function WkMedia(oObj)

Local lFunc 	:= .F.
Local aMenu 	:= {}
Local cAliasTmp	:= ""
Local cRec		:= ""

Default oObj	:= Nil

If ValType( oObj ) == "O"
	oObj:Sair()
	oObj := Nil
EndIf

oObj := TRHWorkArea():New(STR0001)//"Area de Trabalho - Admiss�o"

//Layout
oObj:SetLayout({{"03",50,.T.},{"04",50,.F.},{"05",50,.F.},{"03",50,.T.}}) //layout da tela.

//Browse
oBrwSRV := oObj:SetBrowse( oObj:getPanel("03"), "SRV", 'GPEA040A', "Verbas",ChkRh("GPEA040","SRV","1"),.T.,.T.,.T.)
oBrwRCE := oObj:SetBrowse( oObj:getPanel("04"), "RCE", 'GPEA340A', "Sindicato",ChkRh("GPEA340","RCE","1"),.T.,.T.,.T.)
oBrwRCA := oObj:SetBrowse( oObj:getPanel("05"), "RCA", 'GPEA300', "Mnemonicos"," 'M' $ RCA_PROCES",.T.,.T.,.T.)


oObj:Activate()

Return

