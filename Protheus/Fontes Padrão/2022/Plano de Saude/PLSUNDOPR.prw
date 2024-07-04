#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSUNDOPR.CH"
#INCLUDE 'FWADAPTEREAI.CH'
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSUNDOPR   �Autor  �Microsiga           � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro do setor de atua��o do benefici�rio				    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SEGMENTO SAUDE VERSAO 11.5                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PLSUNDOPR()
Local oBrowse

//Cria��o do help do campo BBZ_CODORG
PutHelp("PPLUNDORG",{STR0001,STR0002},{},{},.T.) // "Este c�digo j� "##"est� cadastrado."  
PutHelp("SPLUNDORG",{STR0003},{},{},.T.) // "Insira um novo c�digo!"

//Cria��o do objeto.
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BBZ' )
oBrowse:SetDescription(STR0004) //'Unidade Organizacional'
oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'	        , 0, 1, 0, .T. } )
aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSUNDOPR', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 				'VIEWDEF.PLSUNDOPR', 0, 3, 0, NIL } ) 
aAdd( aRotina, { 'Alterar'   , 				'VIEWDEF.PLSUNDOPR', 0, 4, 0, NIL } ) 
aAdd( aRotina, { 'Excluir'   , 				'VIEWDEF.PLSUNDOPR', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Copiar'   , 				'VIEWDEF.PLSUNDOPR', 0, 9, 0, NIL } )
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

LOCAL oModelUND

// Cria o objeto do Modelo de Dados

Local oStrBBZ:= FWFormStruct(1,'BBZ')

oModelUND := MPFormModel():New( STR0004, ,{ | oMdl | PLSVLDLNA( oMdl ) } , /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModelUND:AddFields( 'BBZMASTER', NIL, oStrBBZ )
oModelUND:SetPrimaryKey( { "BBZ_FILIAL", "BBZ_CODSEQ" } ) 

// Adiciona a descricao do Modelo de Dados
oModelUND:SetDescription( 'Unidade Organizacional' )

// Adiciona a descricao do Componente do Modelo de Dados
oModelUND:GetModel( 'BBZMASTER' ):SetDescription( STR0004 )

Return oModelUND

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSUNDOPR' )
Local oStruBBZ := FWFormStruct(2, 'BBZ')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado

oView:SetModel( oModel )
oView:AddField('BBZ' , oStruBBZ,'BBZMASTER' )

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMBBZ', 100, 'BOX1')

oView:SetOwnerView('BBZ','FORMBBZ')

Return oView

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �ValCodSeq    �Autor  � Thiago Guilherme   � Data �23/01/14   ���
��������������������������������������������������������������������������Ĵ��
���          �Valida o campo BBZ_CODORG 
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
function ValCodSeq()

	If ExistCPO("BBZ",M->BBZ_CODORG,1 )

		Help("",1,"PLUNDORG")                                                                                                                                                                              
		return .F.
	EndIf
Return .T.

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �PLSVLDLNA    �Autor  � Thiago Guilherme   � Data �23/01/14   ���
��������������������������������������������������������������������������Ĵ��
���          �Valida gravar linhas iguais na op��o copiar. 
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSVLDLNA(oModel)

LOCAL lret := .T.

If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	
	BBZ->(dbSetOrder(1))
	If BBZ->(dbSeek(xFilial("BBZ") + oModel:getValue("BBZMASTER","BBZ_CODORG"))) //"O c�digo organizacional j� existe na base de dados."
	
		Help(,,"Help",,STR0005,1,0)
		lret := .F.
	EndIf
EndIf
Return lret