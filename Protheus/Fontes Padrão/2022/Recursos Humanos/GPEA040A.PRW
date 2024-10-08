#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA040.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o     � GPEA040A   � Autor � Mauricio Takakura            � Data � 17/11/10     ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o  � Cadastro de Verbas em MVC                                           ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe    � GPEA340()                                                               ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso       � Generico ( DOS e Windows )                                              ���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                           ���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC                    �  Motivo da Alteracao              ���
���������������������������������������������������������������������������������������Ĵ��
*/
Function GPEA040A()

	Local oMBrowse
	Local cFiltraRh

	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias( "SRV" )
	oMBrowse:SetDescription( OemToAnsi( STR0009 ) ) //"Cadastro de Verbas"

	//������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro utilizando a funcao FilBrowse                      �
	//��������������������������������������������������������������������������
	cFiltraRh := CHKRH("GPEA040","SRV","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	oMBrowse:Activate()

Return

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Mauricio Takakura� Data �17/11/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Criacao do Menu do Browse                                   �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA340                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0005				ACTION 'VIEWDEF.GPEA040A' 			OPERATION 2 ACCESS 0 				// "Visualizar"
	ADD OPTION aRotina TITLE STR0007 				ACTION 'VIEWDEF.GPEA040A'	 		OPERATION 4 ACCESS 0 				// "Alterar"

Return aRotina

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ModelDef 		�Autor�  Mauricio Takakura� Data �17/11/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Modelagem da gravacao.                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA340                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ModelDef()
Local oModel := FWLoadModel( "GPEA040" )
Return( oModel )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef  		�Autor�  Mauricio Takakura� Data �17/11/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA340                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ViewDef()
Local oView 	:= FWFormView():New()
Local oModel	:= FWLoadModel("GPEA040")
Local oStructSRV:= FWFormStruct(2, "SRV",{|cCampo|  AllTrim(cCampo) $ "|RV_MED13|RV_MEDFER|RV_MEDAVI|RV_GRAMED|RV_CONVCOL|RV_MEDREAJ|"})
Local oStruct	:= FWFormStruct(2, "SRV",{|cCampo|  AllTrim(cCampo) $ "|RV_COD|RV_DESC|"})
Local nI 		:= 1

oView:SetModel(oModel)

oStruct:SetProperty('RV_COD', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetProperty('RV_DESC', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetNofolder()
oView:AddField("GPEA040_SRV", oStruct,"SRVMASTER")
oView:AddField("GPEA040_1", oStructSRV,"SRVMASTER")
oView:CreateHorizontalBox("FIELDS", 10)
oView:CreateHorizontalBox("FIELDS1", 90)
oView:SetOwnerView("GPEA040_SRV", "FIELDS")
oView:SetOwnerView('GPEA040_1', 'FIELDS1')
Return oView
