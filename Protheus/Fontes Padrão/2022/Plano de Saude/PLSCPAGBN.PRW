#INCLUDE "PLSCPAGBN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCPAGBN   ºAutor  ³Microsiga           º Data ³  09/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calendario de pagamento do beneficiario					   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE VERSAO 11.5                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSCPAGBN()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B1K' )
oBrowse:SetDescription(STR0001) //"Calendario de pagamento do beneficiario"
oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'        , 0, 1, 0, .T. } )
aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSCPAGBN', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 				'VIEWDEF.PLSCPAGBN', 0, 3, 0, NIL } ) 
aAdd( aRotina, { 'Alterar'   , 				'VIEWDEF.PLSCPAGBN', 0, 4, 0, NIL } ) 
aAdd( aRotina, { 'Excluir'   , 				'VIEWDEF.PLSCPAGBN', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Copiar'   , 				'VIEWDEF.PLSCPAGBN', 0, 9, 0, NIL } )
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

LOCAL oModelObj

// Cria o objeto do Modelo de Dados

Local oStrB1K:= FWFormStruct(1,'B1K')

oModelObj := MPFormModel():New( STR0001/*"Calendario de pagamento do beneficiario"*/, /*bPreValidacao*/, {| oMdl | PLSVLDCDP( oMdl )}, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModelObj:AddFields( 'B1KMASTER', NIL, oStrB1K )
oModelObj:SetPrimaryKey( { "B1K_FILIAL", "B1K_FILIAL,B1K_CODINT,B1K_ANO,B1K_MES,B1K_DATINI,B1K_DATFIN" } ) 

// Adiciona a descricao do Modelo de Dados
oModelObj:SetDescription(STR0001) //'Calendário de Pagamento de Beneficiário'

// Adiciona a descricao do Componente do Modelo de Dados
oModelObj:GetModel( 'B1KMASTER' ):SetDescription( STR0001 ) //'Calendário de Pagamento de Beneficiário'

Return oModelObj

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSCPAGBN' )
Local oStruB1K := FWFormStruct(2, 'B1K')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado

oView:SetModel( oModel )
oView:AddField('B1K' , oStruB1K,'B1KMASTER' )

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMB1K', 100, 'BOX1')

oView:SetOwnerView('B1K','FORMB1K')

Return oView

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PLSVLDLNA    ³Autor  ³ Thiago Guilherme   ³ Data ³23/01/14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Valida gravar dados iguais na opcao copiar. 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDCDP(oModel)

LOCAL lret := .T.
LOCAL cChave := oModel:getValue("B1KMASTER","B1K_CODINT") + oModel:getValue("B1KMASTER","B1K_ANO") +  oModel:getValue("B1KMASTER","B1K_MES") 
 
cChave += DTOS(oModel:getValue("B1KMASTER","B1K_DATINI")) + DTOS(oModel:getValue("B1KMASTER","B1K_DATFIN")) + DTOS(oModel:getValue("B1KMASTER","B1K_DATPRE"))
 
If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	
	B1K->(dbSetOrder(1))
	If B1K->(dbSeek(xFilial("B1K") + cChave))
	
		Help(,,"Help",,STR0003,1,0) //"Esta configuração do calendário já existe."
		lret := .F.
	EndIf
EndIf
Return lret