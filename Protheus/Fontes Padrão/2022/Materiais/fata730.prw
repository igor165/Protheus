#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA730.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FatA730   �Autor  �Vendas CRM          � Data �  03/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grupos Societarios em MVC.								  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FatA730
Local oBrowse	:= Nil 

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGT')
oBrowse:SetDescription(STR0001)//'Grupos Societarios'
oBrowse:Activate()

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  03/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupos societarios.             ���
�������������������������������������������������������������������������͹��
���Uso       �FatA730                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruAGT 		:= FWFormStruct(1,'AGT',/*bAvalCampo*/,/*lViewUsado*/)
Local oStruAGU 		:= FWFormStruct(1,'AGU',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('FATA730',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AGTMASTER',/*cOwner*/,oStruAGT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'AGUDETAIL','AGTMASTER',oStruAGU,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/) 
oModel:SetRelation( 'AGUDETAIL',{{'AGU_FILIAL','xFilial("AGU")'},{'AGU_CODIGO','AGT_CODIGO'}} ,'AGU_FILIAL+AGU_CODIGO')
oModel:GetModel('AGUDETAIL'):SetUniqueLine({'AGU_CODCLI','AGU_LOJCLI'})
oModel:SetDescription(STR0001)

Return(oModel)


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  03/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro do grupo societario.        ���
��������������������������������������������������������������������������͹��
���Uso       �FatA730                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/  

Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('FATA730')
Local oStruAGT := FWFormStruct(2,'AGT')
Local oStruAGU := FWFormStruct(2,'AGU')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_AGT', oStruAGT, 'AGTMASTER' )
oView:AddGrid( 'VIEW_AGU', oStruAGU, 'AGUDETAIL' )
oView:CreateHorizontalBox('SUPERIOR', 10 )
oView:CreateHorizontalBox('INFERIOR', 90 )
oView:SetOwnerView( 'VIEW_AGT','SUPERIOR' )
oView:SetOwnerView( 'VIEW_AGU','INFERIOR' )

Return(oView)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 03/02/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina.                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina   retorna a array com lista de aRotina              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FatA730                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/    

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA730'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA730'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA730'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA730'	OPERATION 5	ACCESS 0

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft730VdCli
Validacao dos campos AGU_CODCLI / AGU_LOJCLI.
@sample 	Ft730Cli(cCodCli,cLoja)
@param		ExpC1	Codigo do cliente
			ExpC2	Loja do cliente
@return   	ExpL	True - V�lido, False - Inv�lido
@author	    Squad CRM
@since		13/02/2019
@version	12.1.17
/*/
//------------------------------------------------------------------------------ 
Function Ft730VdCli(cCodCli, cLoja)

Local lRetorno  := .T.
Default cCodCli := ""
Default cLoja   := ""

If !Empty( cCodCli ) .And. Empty( cLoja )
	SA1->(DbSetOrder(1))
	If SA1->(!DbSeek(xFilial("SA1")+cCodCli))
        Help(NIL, NIL, "Ft730VdCli", NIL, STR0007 , 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0008 }) // "Cliente inv�lido." ## "Verificar o c�digo informado."
		lRetorno := .F.
	EndIf
Else
    lRetorno := Vazio() .OR. ExistCpo("SA1", cCodCli + cLoja)
EndIf	

Return(lRetorno)