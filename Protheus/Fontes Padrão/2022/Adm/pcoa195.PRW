#include "pcoa195.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} PCOA195
Função para cadastramento de tipos de saldos orcamentários.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Function PCOA195(nOpcX)

Private oBrowse

If ValType(nOpcX) = "N" .and. nOpcX >= 3 .and. nOpcX <= 5
	FWExecView(STR0001, "VIEWDEF.PCOA195", nOpcX, /*oDlg*/, {|| .T.}, /*bOk*/, /*nPercReducao*/)  // "Cadastro Tipos de Saldos"
Else
	// Ativa browser.
	oBrowse := FwMBrowse():New()
	oBrowse:SetAlias('AL2')
	oBrowse:SetDescripton(STR0001)  // "Cadastro Tipos de Saldos"
	oBrowse:Activate()
Endif

Return


/*/{Protheus.doc} MenuDef
Menu para cadastramento de tipos de saldos orcamentários.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA195')


/*/{Protheus.doc} ModelDef
Modelo para cadastramento de tipos de saldos orcamentários.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AL2')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AL2Model', /*bPreValid*/, {|oModel| ValidPos(oModel)}/*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)

// Adiciona ao modelo um componente de formulário.
oModel:AddFields('AL2MASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AL2MASTER'):SetDescription(STR0001)

// Configura chave primária.
oModel:SetPrimaryKey({"AL2_FILIAL", "AL2_CODIGO"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ModelDef
View para cadastramento de tipos de saldos orcamentários.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA195')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AL2')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel(oModel)

// Define que a view será fechada após a gravação dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulário (antiga enchoice).
oView:AddField('VIEW_AL2', oStruct, 'AL2MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibição.
oView:SetOwnerView('VIEW_AL2', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function ValidPre(oModel)

Local lRet       := .T.
Local nOper      := oModel:getOperation()

If nOper == MODEL_OPERATION_DELETE
	lRet := A195ExclOK()
EndIf

Return lRet


/*/{Protheus.doc} A195ExclOK
Valida exclusão de tipos de saldos orcamentários.

@author  Paulo Carnelossi
@version
@since   14/01/2009
/*/
Static Function A195ExclOK()

Local lRet       := .T.
Local aArea      := GetArea()
Local cQuery     := ""
Local cAliasTRB  := GetNextAlias()

// Verificar se utilizado na tabela de movimentos orcamentarios AKD.
cQuery := "SELECT max(AKD_TPSALD) CLASSE "
cQuery += " FROM " + RetSqlName("AKD")
cQuery += " WHERE "
cQuery += " AKD_FILIAL  = '" + xFilial("AKD") + "' "
cQuery += " AND AKD_TPSALD = '" + AL2->AL2_TPSALD + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

If (cAliasTRB)->(!Eof() .and. RTrim(CLASSE) <> '')
	lRet := .F.
EndIf
(cAliasTRB)->(dbCloseArea())

If !lRet
	Help(,, 'Help',, STR0008, 1, 0)  // "Tipo de Saldo nao pode ser excluido. Verifique os movimentos orcamentarios."
EndIf

RestArea(aArea)

Return lRet


/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Felipe Raposo
@version P12
@since   10/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return PCOI195(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)


/*/{Protheus.doc} ValidPos

@author  Darcio Ribeiro Spörl
@version P12.1.25
@since   18/06/2019
/*/
Static Function ValidPos(oModel)
Local lRet       := .T.

If oModel:IsCopy()
	lRet := ExistChav("AL2",oModel:GetValue( 'AL2MASTER', 'AL2_TPSALD' ))
EndIf

Return lRet