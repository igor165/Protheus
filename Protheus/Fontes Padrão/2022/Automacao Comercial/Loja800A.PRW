#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA800A.CH" 
#INCLUDE 'FWMVCDEF.CH'

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Program   �LOJA800A  � Autor �Vendas CRM             � Data �21/03/2011	���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Contrato de Manejo de Apartados                              	���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      	���
�������������������������������������������������������������������������������
/*/
Function Loja800A()

Local oBrowse := Nil 

PRIVATE cCadastro := STR0001 //"Contrato de Manejo de Apartados"   
PRIVATE aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('MEO')
oBrowse:SetDescription(STR0001)//"Contrato de Manejo de Apartados" 
oBrowse:Activate()

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  21/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do (MVC)                           ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA800A                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruMEO := FWFormStruct(1,'MEO', /*bAvalCampo*/,/*lViewUsado*/ )

Local bCommit		:= {|oMdl|LOJA800ACmt(oMdl)}		//Gravacao dos dados

oModel := MPFormModel():New('LOJA800A', /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/ )
oModel:AddFields('MEOMASTER',/*cOwner*/,oStruMEO, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0001)//"Contrato de Manejo de Apartados"
oModel:SetPrimaryKey({"MEO_FILIAL"},{'MEO_CODIGO'})

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  21/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro do contrato de manejo de   ���
���          �Apartados                                                   ���
�������������������������������������������������������������������������͹��
���Uso       �Loja800A                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('LOJA800A')
Local oStruMEO := FWFormStruct( 2,'MEO')  
   

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_MEO',oStruMEO,'MEOMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_MEO','TELA') 
  
Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data �21/03/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()    

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002    ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.LOJA800A'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.LOJA800A'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.LOJA800A'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.LOJA800A'	OPERATION 5	ACCESS 0


Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA800A  �Autor  �Vendas CRM          � Data �  21/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario, substi-���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA800A                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Loja800ACmt(oMdl)

Local aArea			:= GetArea()
Local nOperation	:= oMdl:GetOperation()
Local lRet          := .T.

If nOperation == 5  
   If ! Loja800ADEL()
   		lRet:= .F.
		Return(lRet)		
   EndIf 
End if

FWModelActive( oMdl )
FWFormCommit( oMdl )
 
RestArea( aArea )

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA800A  �Autor  �Vendas CRM          � Data �  21/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de Tratamento da Exclusao dos Contratos de Manejos  ���
���          � de Apartados                                               ���
�������������������������������������������������������������������������͹��
���Uso       � Loja800A                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Loja800ADEL()

Local lExclui := .T.  
Local nBusca
Local nRecnoSM0  := SM0->(RecNo())
Local aSM0CodFil := {}
Local aAreaSM0 		:= SM0->(GetArea())
Local aAreaSLO 		:= SLO->(GetArea())

// Preenche um array com as filiais
DBSelectArea("SM0")
DBGoTop()
Do While ! Eof()
	If SM0->M0_CODIGO == cEmpAnt
		Aadd(aSM0CodFil, FWGETCODFILIAL )
	Endif
	DBSkip()
EndDo
DBGoTo(nRecnoSM0)

//��������������������������������������������������������������������Ŀ
//� Verifica se existe algum Contrato vinculado                        �
//����������������������������������������������������������������������
DBSelectArea("SLO")
DBSetOrder(3)
aFiliais := If(!Empty(xFilial()) .and. Empty(xFilial("SLO")), aClone(aSM0CodFil), {xFilial()})
For nBusca := 1 to Len(aFiliais)
   	If DBSeek(aFiliais[nBusca]+MEO->MEO_CODIGO)
   		While !SLO->(EOF()) 
   			If SLO->LO_STATUS == "1"
   	   			Aviso(STR0007,STR0008,{STR0009},3) //"Aten��o"##"Contrato n�o pode ser excluido, pois esta vinculado a algum registro de manejo de apartados"##"OK"
   	   			lExclui := .F.
   	   			Exit
   	   		Else
   	   			SLO->(dbSkip())
   	   		EndIf	
   	   End
    EndIf
Next

RestArea(aAreaSM0)
RestArea(aAreaSLO)

Return(lExclui)