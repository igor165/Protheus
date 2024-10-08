#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'GPEA012.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Funcao    � GPEA013  � Autor � Leandro Drumond                   � Data � 10/09/2014 ���
���������������������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro Refeicao				                                        ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA013()			                                                    ���
���������������������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                         ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function GPEA013()
Local cFiltraRh
Local oBrwRFO  
Local oDlg
Local oRadio
Local nRadio
Local nOpca := 1
 
Private nTpVale	:= 2

oBrwRFO := FWmBrowse():New()		
oBrwRFO:SetAlias( 'RFO' )
oBrwRFO:SetDescription( STR0016 )   //"Definicao de Vale Alimenta��o"
		
//Inicializa o filtro utilizando a funcao FilBrowse
cFiltraRh := CHKRH("GPEA013","RFO","1")

If !Empty(cFiltraRh)
	cFiltraRh += " .And. "
EndIf 

cFiltraRh += "RFO_TPVALE == '" +CValtoChar(nTpVale) + "'"

//Filtro padrao do Browse conforme tabela RFO (Definicao de Beneficios)
oBrwRFO:SetFilterDefault(cFiltraRh)
	
oBrwRFO:Activate()    

Return( Nil )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Equipe RH Inovacao    � Data � 14/01/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Menu Funcional                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina Title STR0004  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA012'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.GPEA012'	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0007  Action 'VIEWDEF.GPEA012'	OPERATION 4 ACCESS 0 //"Atualizar"
	ADD OPTION aRotina Title STR0008  Action 'VIEWDEF.GPEA012'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEA013   �Autor  �Microsiga           � Data � 22/01/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     � Usado no Valid do campo RFO_TPBEN:                         ���
�������������������������������������������������������������������������͹��
���Uso       � X3_VALID                                                   ���
�������������������������������������������������������������������������͹��
���Sintaxe   � AtuCpoDet2                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function AtuCpoDet2()
Local lRet 	   := .T.
Local oMdl     := FWModelActive()
Local oMyMdl01 := oMdl:GetModel("GPEA012_MRFO")
Local oMyMdl02 := oMdl:GetModel("GPEA012_MRFP")
Local cMyCod   := oMyMdl01:GetValue('RFO_CODIGO')
Local cMyBen   := oMyMdl01:GetValue('RFO_TPBEN')
	
oMyMdl02:SetValue( 'RFP_CODIGO', cMyCod )
oMyMdl02:SetValue( 'RFP_TPBEN',  cMyBen )
oMyMdl02:LoadValue("RFP_PRODSX",oMyMdl02:GetValue("RFP_PRODSX")) //Utilizado para reavaliar o WHEN dos campos da RFP

Return lRet