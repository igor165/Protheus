#INCLUDE "plsa106.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'  
#include "PLSMGER.CH" 

#DEFINE PLS_MODELO_CABECALHO	"VIEWDEF.PLSA106"
#DEFINE PLS_MODELO_ITENS 		"PLSA106A"
#DEFINE PLS__ALIAS_CABECALHO 	"B22" 
#DEFINE PLS__ALIAS_ITENS 		"B23"
#DEFINE PLS_TITULO 	STR0001 //"Tabela de Preços para Valorização"
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Private
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PRIVATE _CodPad_  := ""
PRIVATE cCadastro := ""
PRIVATE aRotina   := {}
PRIVATE oB22
PRIVATE oB23
Inclui := .F.    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ MsDialog																 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0002,,,,,,,,,.T.) // //'Tabela de Preços'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Cria o conteiner onde serão colocados s browses							 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlg, .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Divisao da tela em duas linhas de 50%									 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oFWLayer:AddLine('UpTop',4,.F.)
oFWLayer:AddLine('Up'	,46,.F.)
oFWLayer:AddLine('Down'	,50,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Monta obj de Linha														 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPLUpTop := oFWLayer:GetLinePanel( 'UpTop' )
oPLUp 	 := oFWLayer:GetLinePanel( 'Up' )
oPLDown  := oFWLayer:GetLinePanel( 'Down' )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Painel																	 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cStyle 		 := "Q3Frame{ border-style:solid; border-color:#FFFFFF; border-bottom-width:3px; border-top-width:1px; background-color:#D6E4EA }"
oPanel 		 := TPanelCss():New(000,000,"",oPLUpTop,,.F.,.F.,,,012,012,.T.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
oPanel:setCSS( cStyle )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Browse dos registros das guias em auditoria								 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Browse demanda
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oB23 := FWmBrowse():New()
oB23:SetOwner( oPLDown )
oB23:SetProfileID( "1" )
oB23:SetAlias( PLS__ALIAS_ITENS )
oB23:SetDescription( STR0003 ) //"Itens da Tabela de Preços"
oB23:SetMenuDef(PLS_MODELO_ITENS)
oB23:DisableDetails()
oB23:SetAmbiente(.T.)
oB23:SetWalkThru(.T.)
oB23:SetBlkBackColor( {||PLS_CORLIN} )
oB23:ForceQuitButton()
oB23:Activate()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Relacao do Browse Mestre com os Detail
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oRB22B23 := FWBrwRelation():New()
oRB22B23:AddRelation( oB22, oB23, {	{ 'B23_FILIAL', 'xFilial( "B23" )' },;
									{ 'B23_CODINT', 'B22_CODINT' },;
									{ 'B23_CODTAB', 'B22_CODTAB' } } )
									
oRB22B23:Activate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Ativando componentes de tela											 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oDlg:lCentered	:= .T.

// Evento executado apos o fechamento da janela de edição do grid Pai, para atualizar o grid Filho.
oB22:BAFTEREXEC	 := {|CFUNCTION,NOPTION,NVERIFY| RefrB23()}

// Valida se pode incluir ou nao!
oB23:BBEFOREEXEC := {|CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC| WhenB23(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)}
oDlg:Activate()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Rest nas linhas do browse e na area										 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RestArea( aArea )                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ MenuDef ³ Autor ³ Totvs                  ³ Data ³ 16.02.11 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ MenuDef													  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
PRIVATE aRotina := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Opcoes de menu															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 

ADD OPTION aRotina Title STR0004  	Action 'PesqBrw'		OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0005 	Action PLS_MODELO_CABECALHO	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0006  	Action PLS_MODELO_CABECALHO OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0007  	Action PLS_MODELO_CABECALHO OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0008  	Action PLS_MODELO_CABECALHO OPERATION 5 ACCESS 0  //"Excluir"
//ADD OPTION aRotina Title "Clonar"  	Action 'B22CLONE' 		OPERATION 6 ACCESS 0  //"Clonar"
ADD OPTION aRotina Title STR0010  	Action 'PLSRJGENT(.f.)' 			OPERATION 8 ACCESS 0  //"Reajuste de Preços"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB22 := FWFormStruct( 1, 'B22', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   := MPFormModel():New('PLSA106MD', /*bPreValidacao*/, {|oX|ValDtB22(oX)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ ) //

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B22MASTER', /*cOwner*/, oStruB22, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //"Tabela de Preços"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B22MASTER' ):SetDescription( STR0009 )  //"Tabela de Preços"

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

// Define qual o Modelo de dados será utilizado
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
validação ao incluir ou excluir b22
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
		// Verifica os itens da tabela de preço.		
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
	// verifica se o código da tabela já existe
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA106   ºAutor  ³Microsiga           º Data ³  03/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
		Help(nil, nil , "Atenção", nil, "Os campos B23_CDPAD1 e B23_CDPAD2 devem ser iguais, apague o conteúdo desse campo e altere B23_CDPAD2 para o valor desejado", 1, 0, nil, nil, nil, nil, nil, {""} )
		lRet := .f. 
	endif 

	if lRet
		if (!empty(M->B23_CDPRO1)) 
			BR8->(DbSetOrder(1))
			lRet := BR8->(MsSeek(xFilial("BR8") + alltrim(M->B23_CDPAD1) + alltrim(M->B23_CDPRO1))) 
			if (!lRet)
				Help(nil, nil , "Atenção", nil, "evento cadastrado não cadastrado na tabela BR8", 1, 0, nil, nil, nil, nil, nil, {""} )
			endif
		else 
			lRet := .t.
		endif
	endif

elseif(empty(M->B23_CDPAD1))
	lRet := .t.
else 
	Help(nil, nil , "Atenção", nil, "código informado não existe", 1, 0, nil, nil, nil, nil, nil, {""} )
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
		Help(nil, nil , "Atenção", nil, "Os campos B23_CDPAD1 e B23_CDPAD2 devem ser iguais, apague o conteúdo desse campo e altere B23_CDPAD1 para o valor desejado", 1, 0, nil, nil, nil, nil, nil, {""} )
		lRet := .f. 
	endif 

	if lRet
		if (!empty(M->B23_CDPRO2)) 
			BR8->(DbSetOrder(1))
			lRet := BR8->(MsSeek(xFilial("BR8") + alltrim(M->B23_CDPAD2) + alltrim(M->B23_CDPRO2))) 
			if (!lRet)
				Help(nil, nil , "Atenção", nil, "evento cadastrado não cadastrado na tabela BR8", 1, 0, nil, nil, nil, nil, nil, {""} )
			endif
		else 
			lRet := .t.
		endif
	endif

elseif(empty(M->B23_CDPAD2))
	lRet := .t.
else 
	Help(nil, nil , "Atenção", nil, "código informado não existe", 1, 0, nil, nil, nil, nil, nil, {""} )
	lRet := .f.
endif 

return lRet
