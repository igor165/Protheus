#INCLUDE "FINA669.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA669
Cadastro de tabela de conversao entre o codigo da empresa dentro Site
Reserve e o Codigo da empresa dentro do sistema Protheus

@author Alexandre Circenis
@since 29-08-2013
@version P11.9
/*/
//-------------------------------------------------------------------
Function FINA669()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FL2')
oBrowse:SetDescription(STR0002)
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.FINA669' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.FINA669' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.FINA669' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.FINA669' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.FINA669' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE STR0008    ACTION 'VIEWDEF.FINA669' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser acrescentada no Modelo de Dados
Local oStru := FWFormStruct( 1, 'FL2', /*bAvalCampo*/,/*lViewUsado*/ )
// Inicia o Model com um Model ja existente
Local oModel := MPFormModel():New( 'FINA669A' )

oModel:AddFields( 'FL2MASTER', /*cOwner*/, oStru )
// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( STR0009 )
// Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel( 'FL2MASTER' ):SetDescription( STR0001 ) //'BKO Agencia x BKO Empresa'
// Retorna o Modelo de dados

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'FINA669' )
// Cria a estrutura a ser usada na View
Local oStru := FWFormStruct( 2, 'FL2' )
// Interface de visualiza��o constru�da
Local oView
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados ser� utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul�rio
// (antiga Enchoice)
oView:AddField( 'VIEW_FL2', oStru, 'FL2MASTER' )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )
// Relaciona o identificador (ID) da View com o "box" para
oView:SetOwnerView( 'VIEW_FL2', 'TELA' )
// Retorna o objeto de View criado
Return oView                                                                           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BKO2Age   �Autor  �Microsiga           � Data �  08/29/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o condigo da empresa no Reserve usado pela agencia ���
���          � Recebe o codigo do empresa+Filial do sistema , se nao      ���
���          � receber um valor sera utilizado Empresa e Filial logada    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function BKO2AGE(cCodigo)
local cRet := ''
Local aArea := GetArea()

DEFAULT cCodigo := cEmpAnt+cFilAnt

dbSelectArea("FL2")
dbSetOrder(1)

if dbSeek(xFilial("FL2")+cCodigo)
	cRet := FL2->FL2_BKOAGE
else
	cRet  := cCodigo
endif

RestArea(aArea)

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BKO2Emp   �Autor  �Microsiga           � Data �  08/29/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o condigo da empresa+filial do Protheus            ���
���          � Receber o codigo do empresa vinda no Reserve, se nao       ���
���          � receber um valor sera utilizado Empresa e Filial logada    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function BKO2Emp(cCodigo)
Local aArea := GetArea()
Local aRet := {}

DEFAULT cCodigo := cEmpAnt+cFilAnt                

dbSelectArea("FL2")
dbSetOrder(2)

//[1][1] //C�digo da empresa no Protheus.
//[1][2] //Se encontrou registro na FL2, implementado parametro para casos em que c�digo do Reserve � o mesmo do Protheus.
If dbSeek(xFilial("FL2")+cCodigo)
	aAdd(aRet, {FL2->FL2_BKOEMP, .T.} )
Else
	aAdd(aRet, {cCodigo, .F.} )
Endif

RestArea(aArea)

Return aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BKO2Lic   �Autor  �Microsiga           � Data �  08/29/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o codigo do licenciado com o BKO Protheus          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function BKO2Lic(cCodigo)
local cRet := ''
Local aArea := GetArea()

DEFAULT cCodigo := cEmpAnt+cFilAnt                

dbSelectArea("FL2")
dbSetOrder(1)

if dbSeek(xFilial("FL2")+cCodigo)
	cRet := FL2->FL2_LICENC
endif

RestArea(aArea)

Return cRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BKO2GruCC �Autor  �Microsiga           � Data �  08/29/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a descri��o do grupo de empresas quando o cadastro ���
���          � de centro de cutos for compartilhado pelo grupo            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function BKO2GruCC(cCodigo)
local cRet := ''
Local aArea := GetArea() 


DEFAULT cCodigo := cEmpAnt+cFilAnt                

dbSelectArea("FL2")
dbSetOrder(1)

if dbSeek(xFilial("FL2")+cCodigo) .and. FL2->FL2_CC  = '2'
	cRet := FL2->FL2_GRPEMP
endif

RestArea(aArea)

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BKO2GruCli�Autor  �Microsiga           � Data �  08/29/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a descri��o do grupo de empresas quando o cadastro ���
���          � de cliente for compartilhado pelo grupo                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function BKO2GruCli(cCodigo)
local cRet := ''
Local aArea := GetArea() 

DEFAULT cCodigo := cEmpAnt+cFilAnt                

dbSelectArea("FL2")
dbSetOrder(1)

if dbSeek(xFilial("FL2")+cCodigo) .and. FL2->FL2_CLIENT  = '2'
	cRet := FL2->FL2_GRPEMP
endif

RestArea(aArea)

Return cRet
