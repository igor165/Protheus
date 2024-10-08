#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FISA035.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �  FISA035  � Autor � Luccas Curcio             � 22.08.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tipos de Utiliza��o de Cr�dito - SPED Fiscal                ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Programa respons�vel por controlar os registros de          ���
���          � tipos de utiliza��o de cr�dito.							  ���
���			 � Programa desenvolvido na estrutura MVC.		      		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil                                                         ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FISA035

Local oBrowse

MenuDef()

oBrowse	:=	FWMBrowse():New()
oBrowse:SetAlias('CE7')
oBrowse:SetDescription(STR0001) //"Tipos de Utiliza��o de Cr�dito"
oBrowse:DisableDetails()
oBrowse:Activate()

ModelDef()

ViewDef()

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �  MenuDef  � Autor � Luccas Curcio             � 22.08.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta o menu com as op��es da rotina                        ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Desenvolvido na estrutura MVC                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �FWMVCMenu (Programa) -> Menu com as op��es b�sicas          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function MenuDef()

Return FWMVCMenu ("FISA035")

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �  ModelDef � Autor � Luccas Curcio             � 22.08.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Define o Modelo da Rotina (oModel)                          ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Desenvolvido na estrutura MVC                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �oModel -> Objeto que cont�m as funcionalidades da rotina    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ModelDef()

Local oStruCE7 	:=	FWFormStruct (1, "CE7")
Local oModel

oModel:= MPFormModel():New('CE7MODEL', ,{ |oModel| ValidForm(oModel) } )  

oModel:AddFields('CE7MODEL',,oStruCE7)
oModel:SetDescription(STR0001) //"Tipos de Utiliza��o de Cr�dito"
oModel:GetModel('CE7MODEL'):SetDescription(STR0001) //"Tipos de Utiliza��o de Cr�dito"
oModel:SetPrimaryKey( { "CE7_CODUTI" } )
oStruCE7:SetProperty('CE7_CODUTI' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

Return oModel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �  ViewDef  � Autor � Luccas Curcio             � 22.08.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Define a visualiza��o de telas da rotina                    ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Desenvolvido na estrutura MVC                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �oView -> Objeto respons�vel pela exibi��o dos dados         ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ViewDef()

Local oModel	:=	FWLoadModel ("FISA035")
Local oStruCE5	:=	FWFormStruct (2, "CE7")
Local oView

oView	:=	FWFormView():New()

oView:SetModel(oModel)
oView:AddField("View_CE7",oStruCE5,"CE7MODEL")
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("View_CE7","TELA")

Return oView    
/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Valter Silva       � Data � 02/0122013  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.            	       ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

 	Local lRet		:=	.T.
	Local cCod		:=	oModel:GetValue ('CE7MODEL','CE7_CODUTI'  )
	Local nOperation:=	oModel:GetOperation()
	
 	If nOperation == 3 //Inclus�o de informa��es.
		DbSelectArea ("CE7")  //
		CE7->(DbSetOrder (1))
		If CE7->(DbSeek(xFilial("CE7")+cCod))			
			Help(" ",1,"Help",,STR0002,1,0)//"Tipo de Utiliza��o de Cr�dito j� cadastrado."
			lRet := .F.
		EndIF		
	EndIF 

Return lRet

