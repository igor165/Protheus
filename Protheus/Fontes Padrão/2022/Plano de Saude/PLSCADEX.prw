#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "plscadex.ch"
 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o³	 PLSCADEX 	 ³Autor ³ Hugo Vieira   ³ Data ³24/03/15   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Cadastrar as exceções para auditoria de procedimentos.
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCADEX()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B1O' )
oBrowse:SetDescription(STR0006) //"Exceção para Auditoria"
oBrowse:Activate()

Return (nil)

//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { STR0001/*'Pesquisar'*/ , 				'PesqBrw'        , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0002/*'Visualizar'*/, 				'VIEWDEF.PLSCADEX', 0, 2, 0, NIL } )
aAdd( aRotina, { STR0003/*'Incluir'*/   , 				'VIEWDEF.PLSCADEX', 0, 3, 0, NIL } )
aAdd( aRotina, { STR0004/*'Alterar'*/   , 				'VIEWDEF.PLSCADEX', 0, 4, 0, NIL } )
aAdd( aRotina, { STR0005/*'Excluir'*/   , 				'VIEWDEF.PLSCADEX', 0, 5, 0, NIL } )
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

LOCAL oModelObj

// Cria o objeto do Modelo de Dados

Local oStrB1O:= FWFormStruct(1,'B1O')

oModelObj := MPFormModel():New( STR0006/*"Exceções para Auditoria de Procedimentos"*/, /*bPreValidacao*/,/* {|oMdl|PLSVLDCADEX(oMdl)}*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModelObj:AddFields( 'B1OMASTER', NIL, oStrB1O )
oModelObj:SetPrimaryKey( { "B1O_FILIAL", "B1O_FILIAL,B1O_CODREG,B1O_CODPRO,B1O_TPGUIA"} )

// Adiciona a descricao do Modelo de Dados
oModelObj:SetDescription(STR0001) //'Calendário de Pagamento de Beneficiário'

// Adiciona a descricao do Componente do Modelo de Dados
oModelObj:GetModel( 'B1OMASTER' ):SetDescription( STR0006 ) //"Exceções para Auditoria de Procedimentos"

Return oModelObj

//-------------------------------------------------------------------
Static Function ViewDef()

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSCADEX' )
Local oStruB1O := FWFormStruct(2, 'B1O')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado

oView:SetModel( oModel )
oView:AddField('B1O' , oStruB1O,'B1OMASTER' )

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMB1O', 100, 'BOX1')

oView:SetOwnerView('B1O','FORMB1O')

Return oView

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o³	 PLSVLDEXAUDITORIA 	 ³Autor ³ Hugo Vieira   ³ Data ³24/03/15   ³ ±±
±±ÃÄÄÄÄÄÄÄÈÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Verifica se existe exceção para auditoria.					   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDEX(cChave,nIdade,nQtdPro)

LOCAL lret := .F.

//Order(2)->  B1O_FILIAL+B1O_CODPRO+B1O_TPGUIA
B1O->(dbSetOrder(2))
If B1O->(dbSeek(xFilial("B1O") + cChave))
	IF B1O->B1O_QTDPRO >= nQtdPro
		If EMPTY(B1O->B1O_IDADE) .OR. val(B1O->B1O_IDADE) <= Calc_Idade(dDataBase,nIdade)
			lret := .T.
		EndIF
	ENDIF
EndIf

return (lret)