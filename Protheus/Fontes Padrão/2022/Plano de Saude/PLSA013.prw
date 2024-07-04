#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA013.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSA013  � Autor �F�bio S. dos Santos	� Data �21/10/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela de cadastro de Tipo de Documento. 				      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS			                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA013()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('B2O')
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef	  � Autor � F�bio S. dos Santos   � Data �21/10/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para criar o menu da tela.							���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

	Add Option aRotina Title STR0002 /*'Visualizar'*/ Action 'VIEWDEF.PLSA013' Operation 2 Access 0
	Add Option aRotina Title STR0003 /*'Incluir'*/    Action 'VIEWDEF.PLSA013' Operation 3 Access 0
	Add Option aRotina Title STR0004 /*'Alterar'*/    Action 'VIEWDEF.PLSA013' Operation 4 Access 0
	Add Option aRotina Title STR0005 /*'Excluir'*/    Action 'VIEWDEF.PLSA013' Operation 5 Access 0
	Add Option aRotina Title STR0006 /*'Imprimir'*/   Action 'VIEWDEF.PLSA013' Operation 8 Access 0
	Add Option aRotina Title STR0007 /*'Copiar'*/     Action 'VIEWDEF.PLSA013' Operation 9 Access 0
	
Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef	  � Autor � F�bio S. dos Santos   � Data �21/10/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do modelo de Dados.								���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()
Local oModel 
Local oStrB9G:= FWFormStruct(1,'B2O')

	oModel := MPFormModel():New( 'PLSA013')
	oModel:addFields('MasterB2O',/*cOwner*/,oStrB9G)
	oModel:getModel('MasterB2O')
	oModel:SetDescription(Fundesc())
	oModel:SetPrimaryKey({"B2O_FILIAL","B2O_SEQUEN"})

Return oModel

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ViewDef	  � Autor � F�bio S. dos Santos   � Data �21/10/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do interface.										���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
Local oView
//Local oModel := ModelDef()
Local oModel := FWLoadModel('PLSA013')
Local oStrB2O:= FWFormStruct(2, 'B2O')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FrmB2O' , oStrB2O,'MasterB2O' ) 
	oView:CreateHorizontalBox( 'BxB2O', 100)
	oView:SetOwnerView('FrmB2O','BxB2O')

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PLS013VCPF � Autor � F�bio S. dos Santos   � Data �27/10/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o cpf Informado.										���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS013VCPF(cCpf,cTipPort) 
Local cRet	:= ""
Local aMsg	:= {}

Default cTipPort := "3" 

cCpf := strtran( cCpf, ".","" ) // retira os pontos
cCpf := strtran( cCpf, "/","" ) // retira a barra
cCpf := strtran( cCpf, "-","" ) // retira os tra�os

aMsg := PLSRETMSG(cTipPort,,"POR","PLSABPRAC") 

BTS->(DbSetOrder(3))
If BTS->(DbSeek(xFilial("BTS")+cCpf))
	
	If !Empty(BTS->BTS_EMAIL) .And. IsEMail(AllTrim(BTS->BTS_EMAIL))
		
		BA1->(DbSetOrder(4))
		If BA1->(DbSeek(xFilial("BA1")+cCpf)) 
			
			lRet := PIncLogin(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),,,,cCpf,BTS->BTS_EMAIL,.T.)
			
			If ValType(lRet) == 'L'
				cRet := STR0013 //"Login criado com sucesso! As informa��es de acesso foram enviados para o e-mail cadastrado"
			
			ElseIf ValType(lRet) == 'C' 		
			
				cRet := lRet
			EndIf	
		Else
			cRet := STR0014 //"Benefici�rio n�o encontrado, entre em contato com a operadora"
		EndIf
	Else
		cRet := STR0015 //"N�o existe e-mail cadastrado ou est� incorreto no cadastro de Vidas, entre em contato com a operadora"
	EndIf
Else
	cRet := STR0016 //"N�o foi encontrado o CPF no cadastro de Vidas, entre em contato com a operadora"
EndIf

Return cRet