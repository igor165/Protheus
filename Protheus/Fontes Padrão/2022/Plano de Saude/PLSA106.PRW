#INCLUDE "plsa106.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'  
#include "PLSMGER.CH" 

#DEFINE PLS_MODELO_CABECALHO	"VIEWDEF.PLSA106"
#DEFINE PLS_MODELO_ITENS 		"PLSA106A"
#DEFINE PLS__ALIAS_CABECALHO 	"B22" 
#DEFINE PLS__ALIAS_ITENS 		"B23"
#DEFINE PLS_TITULO 	STR0001 //"Tabela de Pre�os para Valoriza��o"
#DEFINE PLS_CORLIN 	"#D6E4EA"

Function PLSA106()

Local oBrowse1
LOCAL aArea     := GetArea()
LOCAL nI		:= 0
LOCAL nFldId  	:= 1
LOCAL nAtuSec	:= 60
LOCAL aTFolder 	:= {}
LOCAL aHeader	:= {}
LOCAL aFiles	:= {}
LOCAL aCoors  	:= FWGetDialogSize( oMainWnd )
LOCAL oPanelUp 	:= NIL
LOCAL oFWLayer 	:= NIL 
LOCAL oPLUpTop 	:= NIL
LOCAL oPLUp 	:= NIL
LOCAL oPLDown  	:= NIL
LOCAL oDlg		:= NIL  
//����������������������������������������������������������������������������
//� Private
//����������������������������������������������������������������������������
PRIVATE _CodPad_  := ""
PRIVATE cCadastro := ""
PRIVATE aRotina   := {}
PRIVATE oB22
PRIVATE oB23
Inclui := .F.    
//����������������������������������������������������������������������������
//� MsDialog																 
//����������������������������������������������������������������������������
oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0002,,,,,,,,,.T.) // //'Tabela de Pre�os'
//����������������������������������������������������������������������������
//� Cria o conteiner onde ser�o colocados s browses							 
//����������������������������������������������������������������������������
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlg, .F.)
//����������������������������������������������������������������������������
//� Divisao da tela em duas linhas de 50%									 
//����������������������������������������������������������������������������
oFWLayer:AddLine('UpTop',4,.F.)
oFWLayer:AddLine('Up'	,46,.F.)
oFWLayer:AddLine('Down'	,50,.F.)
//����������������������������������������������������������������������������
//� Monta obj de Linha														 
//����������������������������������������������������������������������������
oPLUpTop := oFWLayer:GetLinePanel( 'UpTop' )
oPLUp 	 := oFWLayer:GetLinePanel( 'Up' )
oPLDown  := oFWLayer:GetLinePanel( 'Down' )

//����������������������������������������������������������������������������
//� Painel																	 
//����������������������������������������������������������������������������
cStyle 		 := "Q3Frame{ border-style:solid; border-color:#FFFFFF; border-bottom-width:3px; border-top-width:1px; background-color:#D6E4EA }"
oPanel 		 := TPanelCss():New(000,000,"",oPLUpTop,,.F.,.F.,,,012,012,.T.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
oPanel:setCSS( cStyle )

//����������������������������������������������������������������������������
//� Browse dos registros das guias em auditoria								 
//����������������������������������������������������������������������������
oB22 := FWmBrowse():New()
oB22:SetOwner( oPLUp )
oB22:SetProfileID( '0' )
oB22:SetAlias( PLS__ALIAS_CABECALHO ) 
oB22:SetDescription( PLS_TITULO )
oB22:DisableDetails()
oB22:ForceQuitButton()
oB22:SetAmbiente(.T.)
oB22:SetWalkThru(.T.)
oB22:SetBlkBackColor( {||PLS_CORLIN} )
oB22:Activate()                  

//����������������������������������������������������������������������������
//� Browse demanda
//����������������������������������������������������������������������������
oB23 := FWmBrowse():New()
oB23:SetOwner( oPLDown )
oB23:SetProfileID( "1" )
oB23:SetAlias( PLS__ALIAS_ITENS )
oB23:SetDescription( STR0003 ) //"Itens da Tabela de Pre�os"
oB23:SetMenuDef(PLS_MODELO_ITENS)
oB23:DisableDetails()
oB23:SetAmbiente(.T.)
oB23:SetWalkThru(.T.)
oB23:SetBlkBackColor( {||PLS_CORLIN} )
oB23:ForceQuitButton()
oB23:Activate()
//����������������������������������������������������������������������������
//� Relacao do Browse Mestre com os Detail
//����������������������������������������������������������������������������
oRB22B23 := FWBrwRelation():New()
oRB22B23:AddRelation( oB22, oB23, {	{ 'B23_FILIAL', 'xFilial( "B23" )' },;
									{ 'B23_CODINT', 'B22_CODINT' },;
									{ 'B23_CODTAB', 'B22_CODTAB' } } )
									
oRB22B23:Activate()

//����������������������������������������������������������������������������
//� Ativando componentes de tela											 
//����������������������������������������������������������������������������
oDlg:lCentered	:= .T.

// Evento executado apos o fechamento da janela de edi��o do grid Pai, para atualizar o grid Filho.
oB22:BAFTEREXEC	 := {|CFUNCTION,NOPTION,NVERIFY| RefrB23()}

// Valida se pode incluir ou nao!
oB23:BBEFOREEXEC := {|CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC| WhenB23(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)}
oDlg:Activate()
//����������������������������������������������������������������������������
//� Rest nas linhas do browse e na area										 
//����������������������������������������������������������������������������
RestArea( aArea )                   
//����������������������������������������������������������������������������
//� Fim da Rotina															 
//����������������������������������������������������������������������������
Return NIL

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � MenuDef � Autor � Totvs                  � Data � 16.02.11 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � MenuDef													  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function MenuDef()
PRIVATE aRotina := {}
//����������������������������������������������������������������������������
//� Opcoes de menu															 
//���������������������������������������������������������������������������� 

ADD OPTION aRotina Title STR0004  	Action 'PesqBrw'		OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0005 	Action PLS_MODELO_CABECALHO	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0006  	Action PLS_MODELO_CABECALHO OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0007  	Action PLS_MODELO_CABECALHO OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0008  	Action PLS_MODELO_CABECALHO OPERATION 5 ACCESS 0  //"Excluir"
//ADD OPTION aRotina Title "Clonar"  	Action 'B22CLONE' 		OPERATION 6 ACCESS 0  //"Clonar"
ADD OPTION aRotina Title STR0010  	Action 'PLSRJGENT(.f.)' 			OPERATION 8 ACCESS 0  //"Reajuste de Pre�os"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB22 := FWFormStruct( 1, 'B22', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   := MPFormModel():New('PLSA106MD', /*bPreValidacao*/, {|oX|ValDtB22(oX)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ ) //

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'B22MASTER', /*cOwner*/, oStruB22, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //"Tabela de Pre�os"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B22MASTER' ):SetDescription( STR0009 )  //"Tabela de Pre�os"

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB22 := FWFormStruct( 2, 'B22' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA106' )

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B22', oStruB22, 'B22MASTER' )  

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao               admin
oView:SetOwnerView( 'VIEW_B22', 'SUPERIOR' )

Return oView

/*//-------------------------------------------------------------------
{Protheus.doc} ValDtB22
valida��o ao incluir ou excluir b22
@since    06/2002
//-------------------------------------------------------------------*/
Static Function ValDtB22(oModel)

Local cSql      := ""
Local lRet		:= .T.
Local nOpc      := oModel:GetOperation()
Local aArea 	:= GetArea()
local cCodInt   := oModel:getmodel("B22MASTER"):getValue("B22_CODINT")
local cCodTab   := oModel:getmodel("B22MASTER"):getValue("B22_CODTAB")
     
If nOpc == K_Excluir    
                           
	// Verifica se a tabela esta vinculada a alguma RDA.
	cSql := " SELECT COUNT(*) CONTADOR FROM "+RetSQLName("B24")+" "
	cSql += " WHERE B24_FILIAL = '"+xFilial("B24")+"'"//Filial
	cSql += "   AND B24_CODINT = '"+Alltrim(B22->B22_CODINT)+"'"//Operadora
	cSql += "   AND B24_TABPRE = '"+Alltrim(B22->B22_CODTAB)+"'"//Tabela
	cSql += "   AND D_E_L_E_T_ <> '*' "
	
	PlsQuery(cSql,'Trb106')
	
	If Trb106->CONTADOR > 0
		Help(" ",1,'PLSA106A')
		lRet := .F.
	Endif
	Trb106->(DbCloseArea())
	
	If lRet 		
		// Verifica os itens da tabela de pre�o.		
		cSql := " SELECT COUNT(*) CONTADOR FROM "+RetSQLName("B23")+" "
		cSql += " WHERE B23_FILIAL = '"+xFilial("B23")+"'"//Filial
		cSql += "   AND B23_CODINT = '"+Alltrim(B22->B22_CODINT)+"'"//Operadora
		cSql += "   AND B23_CODTAB = '"+Alltrim(B22->B22_CODTAB)+"'"//Tabela
		cSql += "   AND D_E_L_E_T_ <> '*' "
	
		PlsQuery(cSql,'Trb106')
	
		If Trb106->CONTADOR > 0
			Help(" ",1,'PLSA106B')
			lRet := .F.
		Endif
		Trb106->(DbCloseArea())
	Endif

elseif nOpc == K_Incluir
	// verifica se o c�digo da tabela j� existe
	B22->(DbSetOrder(1))
	if B22->(MsSeek(xFilial("B22")+cCodInt+cCodTab))
		MsgAlert(STR0011, 'PLSA106' )
		lRet := .F.
	endif
EndIf

// Restaura area.
RestArea(aArea)
	
Return(lRet)
                                

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA106   �Autor  �Microsiga           � Data �  03/18/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RefrB23()

Eval(oB22:BCHANGE)

Return(.T.)

/*//-------------------------------------------------------------------
{Protheus.doc} ValDtB22
valida campo B23_CDPAD1
@author Daniel Silva Dias
@since    
//-------------------------------------------------------------------*/

function PB23CDPAD1()

local lRet := .F.

BR4->(DbSetOrder(1))
if BR4->(MsSeek(xFilial("BR4") + M->B23_CDPAD1)) 

	if (empty(M->B23_CDPAD2)) .or. M->B23_CDPAD1 == M->B23_CDPAD2
		lRet := .t.
	else 
		Help(nil, nil , "Aten��o", nil, "Os campos B23_CDPAD1 e B23_CDPAD2 devem ser iguais, apague o conte�do desse campo e altere B23_CDPAD2 para o valor desejado", 1, 0, nil, nil, nil, nil, nil, {""} )
		lRet := .f. 
	endif 

	if lRet
		if (!empty(M->B23_CDPRO1)) 
			BR8->(DbSetOrder(1))
			lRet := BR8->(MsSeek(xFilial("BR8") + alltrim(M->B23_CDPAD1) + alltrim(M->B23_CDPRO1))) 
			if (!lRet)
				Help(nil, nil , "Aten��o", nil, "evento cadastrado n�o cadastrado na tabela BR8", 1, 0, nil, nil, nil, nil, nil, {""} )
			endif
		else 
			lRet := .t.
		endif
	endif

elseif(empty(M->B23_CDPAD1))
	lRet := .t.
else 
	Help(nil, nil , "Aten��o", nil, "c�digo informado n�o existe", 1, 0, nil, nil, nil, nil, nil, {""} )
	lRet := .f.
endif 

return lRet

/*//-------------------------------------------------------------------
{Protheus.doc} ValDtB22
valida campo B23_CDPAD1
@author Daniel Silva Dias
@since    
//-------------------------------------------------------------------*/

function PB23CDPAD2()

local lRet := .F.

BR4->(DbSetOrder(1))
if BR4->(MsSeek(xFilial("BR4") + M->B23_CDPAD2)) 

	if (empty(M->B23_CDPAD1)) .or. M->B23_CDPAD1 == M->B23_CDPAD2
		lRet := .t.
	else 
		Help(nil, nil , "Aten��o", nil, "Os campos B23_CDPAD1 e B23_CDPAD2 devem ser iguais, apague o conte�do desse campo e altere B23_CDPAD1 para o valor desejado", 1, 0, nil, nil, nil, nil, nil, {""} )
		lRet := .f. 
	endif 

	if lRet
		if (!empty(M->B23_CDPRO2)) 
			BR8->(DbSetOrder(1))
			lRet := BR8->(MsSeek(xFilial("BR8") + alltrim(M->B23_CDPAD2) + alltrim(M->B23_CDPRO2))) 
			if (!lRet)
				Help(nil, nil , "Aten��o", nil, "evento cadastrado n�o cadastrado na tabela BR8", 1, 0, nil, nil, nil, nil, nil, {""} )
			endif
		else 
			lRet := .t.
		endif
	endif

elseif(empty(M->B23_CDPAD2))
	lRet := .t.
else 
	Help(nil, nil , "Aten��o", nil, "c�digo informado n�o existe", 1, 0, nil, nil, nil, nil, nil, {""} )
	lRet := .f.
endif 

return lRet
