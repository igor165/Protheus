/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Observacao:
Em 14/12/2011 foi informado sobre o interropimento do projeto Australia, sendo 
assim todos os fontes ja realizados serao guardados para futuras utilizacoes
no retorno do projeto.
Situacao:
Este cadastro esta finalizado e serve apenas para start do fonte GPEA551AUS.
Necess�rio apenas criar um include exclusivo apra ele pois para teste estava 
utilizando o #include 'GPEA551AUS.CH'

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/
#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA551AUS.CH'
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEA551AUS� Autor � Emerson Campos                    � Data � 12/12/2011 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Benef�cios Adicionais (Fringe Benefits) (RHU)                ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA551AUS()                                                             ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���            �          �                �                                            ���
���������������������������������������������������������������������������������������Ĵ��
���            �          �                �                                            ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
Function GPEA551 
Local cFiltraRh
Local oBrwSRA
Local xRetFilRh

oBrwSRA := FWmBrowse():New()		
oBrwSRA:SetAlias( 'SRA' )
oBrwSRA:SetDescription(STR0001)	//"Benef�cios Adicionais"
	
//Inicializa o filtro utilizando a funcao FilBrowse
xRetFilRh := CHKRH(FunName(),"SRA","1")
If ValType(xRetFilRh) == "L"
	cFiltraRh := if(xRetFilRh,".T.",".F.")
Else
	cFiltraRh := xRetFilRh
EndIf

//Filtro padrao do Browse conforme tabela SRA (Funcion�rios)
oBrwSRA:SetFilterDefault(cFiltraRh)

oBrwSRA:DisableDetails()	
oBrwSRA:Activate()
Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Emerson Campos        � Data �12/12/2011���
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

ADD OPTION aRotina Title STR0002  Action 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.GPEA551' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA551' 	OPERATION 4 ACCESS 0 //"Manuten��o"
ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA551' 	OPERATION 5 ACCESS 0 //"Excluir"
Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Emerson Campos        � Data �12/12/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Benef�cios Adicionais (Fringe Benefits)(RHU)                  ���
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
//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRHU 		:= FWFormStruct(1, 'RHU', /*bAvalCampo*/,/*lViewUsado*/)
Local oMdlRHU

// Blocos de codigo do modelo
Local bLinePos		:= {|oMdl| Gp551PosLine(oMdl)}
Local bPosValid 	:= {|oMdl| Gp551PosVal(oMdl)}
    
// REMOVE CAMPOS DA ESTRUTURA
//oStruRHU:RemoveField('RHQ_MAT')
 
//Atribui 
//oStruRHU:SetProperty( 'RHQ_ORIGEM'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'S'" ) ) 

// Cria o objeto do Modelo de Dados
oMdlRHU := MPFormModel():New('GPEA551', /*bPreValid*/ , bPosValid, /*bCommit*/, /*bCancel*/)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oMdlRHU:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oMdlRHU:AddGrid( 'RHUDETAIL', 'SRAMASTER', oStruRHU, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
// Faz relaciomaneto entre os compomentes do model
oMdlRHU:SetRelation('RHUDETAIL', {{'RHU_FILIAL', 'xFilial("RHU")'}, {'RHU_MAT', 'RA_MAT'}}, RHU->(IndexKey(1)))

//Define Chave �nica
oMdlRHU:GetModel('RHUDETAIL'):SetUniqueLine({'RHU_CODBEN'})

//Permite grid sem dados
oMdlRHU:GetModel('RHUDETAIL'):SetOptional(.T.)

oMdlRHU:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRHU:GetModel('SRAMASTER'):SetOnlyQuery(.T.)
//oMdlRHU:SetOnlyQuery('SRAMASTER')

// Adiciona a descricao do Modelo de Dados
oMdlRHU:SetDescription(OemToAnsi(STR0006))  // "Cadastro Benef�cios Adicionais"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRHU:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0007)) // "Funcion�rios"
oMdlRHU:GetModel('RHUDETAIL'):SetDescription(OemToAnsi(STR0001)) // "Benef�cios Adicionais"
Return oMdlRHU	
	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Emerson               � Data � 11/10/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de Benef�cios Adicionais   ���
���          � (Fringe Benefits)(RHU)                                       ���
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
//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA551')
// Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRHU := FWFormStruct(2, 'RHU')

// Cria o objeto de View
oView := FWFormView():New()

// Remove campos da estrutura e ajusta ordem dos campos na view
//Remove
oStruRHU:RemoveField('RHU_MAT')	
 
// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RHU', oStruRHU, 'RHUDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('INFERIOR', 90)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RHU', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_RHU', OemToAnsi(STR0007)) // "Cadastro Programa��o de Rateio"
Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp551LinePos� Autor � Emerson Campos        � Data �12/12/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao responsavel valida��o linha Cad Benef�cios Adicionais ���
���          � (Fringe Benefits)(RHU)                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp551LinePos( oMdlRHU )                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRHU = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Gp551PosLine( oMdlRHU )	
Local lRetorno		:= .T.	
		
Return lRetorno

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp551PosVal � Autor � Emerson Campos        � Data �12/12/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos-validacao do Cadastro de  Benef�cios Adicionais          ���
���          � (Fringe Benefits)(RHU)                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp551PosVal( oMdlRHU )                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRHU = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Gp551PosVal( oMdlRHU )
Local oModel     	:= oMdlRHU:GetModel('RHUDETAIL')	
Local lRetorno      := .T.

Return lRetorno