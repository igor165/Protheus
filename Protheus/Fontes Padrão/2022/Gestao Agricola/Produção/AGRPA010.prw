#include "totvs.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} AGRPA010
Rotina de manuten��o de mantenedores.

@author  Felipe Raposo
@version Protheus 12
@since   30/07/2018
/*/
Function AGRPA010

Local cAlias  := "NC7"
Local oBrowse := FwMBrowse():New()

// Ativa browser.
oBrowse:SetAlias(cAlias)
oBrowse:SetDescripton(FwX2Nome(cAlias))
oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
Defini��o do menu da rotina.

@author  Felipe Raposo
@version Protheus 12
@since   30/07/2018
/*/
Static Function MenuDef
Return FWMVCMenu('AGRPA010')  // Retorna as op��es padr�es de menu.


/*/{Protheus.doc} ViewDef
Defini��o da vis�o (view) da rotina.

@author  Felipe Raposo
@version Protheus 12
@since   30/07/2018
/*/
Static Function ViewDef

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('AGRPA010')

// Cria as estruturas a serem usadas na View
Local oStruNC7   := FWFormStruct(2, 'NC7')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Define que a view ser� fechada ap�s a grava��o dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// N�o exibe mensagem de registro gravado.
oView:ShowUpdateMsg(.F.)

// Adiciona no nosso view um controle do tipo formul�rio (antiga enchoice).
oView:AddField('VIEW_NC7', oStruNC7, 'NC7MASTER')

// Cria um "box" horizontal para receber o elemento da view.
oView:CreateHorizontalBox('DIV_CAB', 100)  // 100% da tela para o formul�rio.

// Relaciona o identificador (ID) da view com o "box" para exibi��o.
oView:SetOwnerView('VIEW_NC7', 'DIV_CAB')

Return oView


/*/{Protheus.doc} ModelDef
Defini��o do modelo (model) da rotina.

@author  Felipe Raposo
@version Protheus 12
@since   30/07/2018
/*/
Static Function ModelDef

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruNC7   := FWFormStruct(1, 'NC7')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AGRPA010', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descri��o do modelo de dados.
oModel:SetDescription(FwX2Nome("NC7"))

// Adiciona ao modelo um componente de formul�rio.
oModel:AddFields('NC7MASTER', /*cOwner*/, oStruNC7, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('NC7MASTER'):SetDescription(FwX2Nome("NC7"))

// Configura chave prim�ria.
oModel:SetPrimaryKey({"NC7_FILIAL", "NC7_CODIGO"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ValidPre

@author  Felipe Raposo
@version P12.1.17
@since   04/10/2018
/*/
Static Function ValidPre(oModel)

Local lRet       := .T.
Local nOper      := oModel:getOperation()
Local cQuery     := ""
Local cAliasSQL  := ""

// Se for exclus�o de registro, verifica se n�o est� em uso por outra tabela.
If nOper == MODEL_OPERATION_DELETE
	// Valida se o registro n�o foi usado.
	cQuery := "select min(NCM.R_E_C_N_O_) NCMRecNo " + CRLF
	cQuery += "from " + RetSqlName('NCM') + " NCM " + CRLF
	cQuery += "where NCM.D_E_L_E_T_ = '' " + CRLF
	cQuery += "and NCM.NCM_FILIAL = '" + xFilial("NCM") + "' " + CRLF
	cQuery += "and NCM.NCM_ALIAS  = 'NC7' " + CRLF
	cQuery += "and NCM.NCM_FILREG = '" + NC7->NC7_FILIAL + "' " + CRLF
	cQuery += "and NCM.NCM_CODREG = '" + NC7->NC7_CODIGO + "' " + CRLF
	cAliasSQL := MPSysOpenQuery(cQuery)

	// Verifica se encontrou algum registro.
	If (cAliasSQL)->NCMRecNo > 0
		Help(" ", 1, "REGUSADO")
		lRet := .F.
	Endif
	(cAliasSQL)->(dbCloseArea())
EndIf

Return lRet


/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@author  Felipe Raposo
@version P12
@since   28/08/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return AGRPI010(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
