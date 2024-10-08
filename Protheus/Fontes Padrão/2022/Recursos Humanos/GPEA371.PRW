#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA371.CH'

	 		
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA371  � Autor � Marcia Moura                      � Data � 14/11/2016 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Informacoes de Hitorico de Cargos - Audesp              					���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA371()                                                                ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Marcia Moura�14/11/2016� MRH-2369       �Inclusao da rotina                          ���
���Marcia Moura�24/11/2016�MRH-19          �Inclusao dos controles para  Audesp         ���
��|Claudinei S.|19/09/2017|DRHESOCP-904    |Inclus�o do hist�rico de cargos - AUDESP    |��
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/

Function GPEA371()

Local oMBrowse
Local cFiltraRh  := ""


oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SQ3")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //Historico de Cargos

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//�������������������������������������������������������������������������

oMBrowse:SetFilterDefault(cFiltraRh)
oMBrowse:SetLocate()
GpLegMVC(@oMBrowse)

oMBrowse:ExecuteFilter(.T.)

oMBrowse:Activate()

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
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

ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA371'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA371'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA371'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Funcionarios Temporarios (RS8)                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function ModelDef()

Local oMdlRS8
Local bAvalCampo	:= {|cCampo| AllTrim(cCampo)+"|" $ "|Q3_CARGO|Q3_DESCSUM|"}
Local oStruSQ3 	  	:= FWFormStruct(1, 'SQ3', bAvalCampo,/*lViewUsado*/)
Local oStruRS8 	  	:= FWFormStruct(1, 'RS8', /*bAvalCampo*/,/*lViewUsado*/)
Local bPosValid  	:= {|oMdlRS8| Gp371PosVal(oMdlRS8)}
Local bCommit		:= {|oMdlRS8| f371Comm(oMdlRS8)}

oMdlRS8 := MPFormModel():New('GPEA371', /*bPreValid */, bPosValid, bCommit, /*bCancel*/)

oMdlRS8:AddFields('SQ3MASTER', /*cOwner*/, oStruSQ3, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdlRS8:AddGrid( 'RS8DETAIL', 'SQ3MASTER', oStruRS8, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oMdlRS8:SetRelation('RS8DETAIL', {{'RS8_FILIAL', 'xFilial("RS8")'}, {'RS8_ADCCAR', 'Q3_CARGO'}}, RS8->(IndexKey(1)))

oMdlRS8:SetPrimaryKey( {"RS8_FILIAL", "RS8_ADCCAR", "RS8_ADDTMV", "R_E_C_D_E_L_"} )

oMdlRS8:GetModel('RS8DETAIL'):SetUniqueLine({'RS8_FILIAL','RS8_ADCCAR','RS8_ADDTMV'})
//oMdlRS8:GetModel('RS8DETAIL'):SetMaxLine(1)

//Permite grid sem dados
oMdlRS8:GetModel('RS8DETAIL'):SetOptional(.T.)

oMdlRS8:GetModel('SQ3MASTER'):SetOnlyView(.T.)
oMdlRS8:GetModel('SQ3MASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Modelo de Dados
oMdlRS8:SetDescription(OemToAnsi(STR0001))  //"Cadastro de Historico de Cargos"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRS8:GetModel('SQ3MASTER'):SetDescription(OemToAnsi(STR0002)) // "Cargos"
oMdlRS8:GetModel('RS8DETAIL'):SetDescription(OemToAnsi(STR0001)) // "Historico de Cargos"
//oMdlRS8:SetVldActivate({|oMdlRS8| fSQ3Back(oMdlRS8)})

Return oMdlRS8

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de Funcion�rios Tempor�rios���
���          � (RS8)                                                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function ViewDef()

Local oView
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|Q3_CARGO|Q3_DESCSUM|"}
Local oModel   := FWLoadModel('GPEA371')
Local oStruSQ3 := FWFormStruct(2, 'SQ3', bAvalCampo)
Local oStruRS8 := FWFormStruct(2, 'RS8')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SQ3', oStruSQ3, 'SQ3MASTER')
oStruSQ3:SetNoFolder()

oView:AddGrid('VIEW_RS8', oStruRS8, 'RS8DETAIL')

oStruRS8:RemoveField("RS8_ADCCAR")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 12)
oView:CreateHorizontalBox('INFERIOR', 88)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SQ3', 'SUPERIOR')
oView:SetOwnerView('VIEW_RS8', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SQ3', OemToAnsi(STR0002)) // "Cargos"
oView:EnableTitleView('VIEW_RS8', OemToAnsi(STR0003)) // "Hitorico de Cargos"


Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp927PosVal � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos-validacao do Cadastro de Funcionarios Temporarios        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp927PosVal( oMdlRFX )                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRFX = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function Gp371PosVal( oMdl )

Local aArea      := GetArea()
Local oGridRS8   := oMdl:GetModel('RS8DETAIL') 
Local nOperation := oMdl:GetOperation()
Local lRetorno   := .F.

lRetorno := .T.

RestArea(aArea)

Return lRetorno  
           
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fGp927When � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verificacao de When para Cadastro de Funcionarios Temporarios��� 
���          � Campo RS8_MATSUB e RS8_CPFSUB.                               ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp927When()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function fGp371When()

Local aSaveArea:= GetArea()
Local lRetorno := .F.

lRetorno := .T.

RestArea(aSaveArea)

Return lRetorno 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fGp927Valid� Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes dos campos de Cadastro de Funcionarios Temporarios��� 
���          � Campo RS8_MATSUB e RS8_CPFSUB.                               ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp927Valid()                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function fGp371Valid(cCampo)

Local aSaveArea  := GetArea()
Local lRetorno   := .F.

		lRetorno := .T.	

RestArea(aSaveArea)

Return lRetorno

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � f926Comm      � Autor � Glaucia Messina  � Data �05/07/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para integracao TAF evento S-2200                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEA371                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function f371Comm(oModel)
Local lRet	:= .T.
local aBackSQ3

Default aBackSQ3 := SQ3->(GetArea())

FWFormCommit(oModel)
RestArea(aBackSQ3) // Restaura a area do registro corrente, pois ao realizar os gatilhos dos campos RS8_MATSUB a SQ3 muda de registr, se perdendo.
	
Return lRet

