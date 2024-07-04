#include "pcoa080.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} PCOA080
Função para cadastramento de operações da planilha orçamentária.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Function PCOA080()

Private oBrowse := FwMBrowse():New()

// Ativa browser.
oBrowse:SetAlias('AKF')
oBrowse:SetDescripton(STR0001)  // "Cadastro de operações"
oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
Menu para cadastramento de operações da planilha orçamentária.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA080')


/*/{Protheus.doc} ModelDef
Modelo para cadastramento de operações da planilha orçamentária.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AKF')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AKFModel', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)

// Adiciona ao modelo um componente de formulário.
oModel:AddFields('AKFMASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AKFMASTER'):SetDescription(STR0001)

// Configura chave primária.
oModel:SetPrimaryKey({"AKF_FILIAL", "AKF_CODIGO"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ModelDef
View para cadastramento de operações da planilha orçamentária.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA080')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AKF')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel(oModel)

// Define que a view será fechada após a gravação dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulário (antiga enchoice).
oView:AddField('VIEW_AKF', oStruct, 'AKFMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibição.
oView:SetOwnerView('VIEW_AKF', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function ValidPre(oModel)

Local lRet       := .T.
Local nOper      := oModel:getOperation()

If nOper == MODEL_OPERATION_DELETE
	lRet := PCOA080DEL()
EndIf

Return lRet


/*/{Protheus.doc} PCOA080DEL
Valida exclusão de operação.

@author  Edson Maricate
@version P12.1.17
@since   27/01/2004
/*/
Static Function PCOA080DEL

Local lRet       := .T.
Local aArea      := GetArea()
Local cQuery     := ""
Local cAliasTRB  := GetNextAlias()

// Verificar se utilizado na tabela de itens orcamentarios AK2.
cQuery := "SELECT max(AK2_OPER) OPER "
cQuery += " FROM " + RetSqlName("AK2")
cQuery += " WHERE "
cQuery += " AK2_FILIAL  = '" + xFilial("AK2") + "' "
cQuery += " AND AK2_OPER = '" + AKF->AKF_CODIGO + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

If (cAliasTRB)->(!Eof() .and. RTrim(OPER) <> '')
	lRet := .F.
EndIf
(cAliasTRB)->(dbCloseArea())

// Verificar se utilizado na tabela de movimentos orcamentarios AKD.
If lRet
	cQuery := "SELECT max(AKD_OPER) OPER "
	cQuery += " FROM " + RetSqlName("AKD")
	cQuery += " WHERE "
	cQuery += " AKD_FILIAL  = '" + xFilial("AKD") + "' "
	cQuery += " AND AKD_OPER = '" + AKF->AKF_CODIGO + "' "
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

	If (cAliasTRB)->(!Eof() .and. RTrim(OPER) <> '')
		lRet := .F.
	EndIf
	(cAliasTRB)->(dbCloseArea())
EndIf

If !lRet
	Help(,, 'Help',, STR0003, 1, 0)  // "Operação orçamentária não pode ser excluída. Verifique planilha/movimento orcamentário."
EndIf

RestArea(aArea)

Return lRet


/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Felipe Raposo
@version P12
@since   09/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return PCOI080(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
