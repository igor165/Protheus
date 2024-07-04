#include "CTBA520.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} CTBA520
Função para cadastro de pessoas contato ou responsavel pelo instrumento juridico de receita
@author  Totvs
@version 12.1.27
@since   01/12/2020
/*/
Function CTBA520()

Private oBrowse := BrowseDef()

// Ativa browser.
oBrowse:Activate()

Return


/*/{Protheus.doc} BrowseDef
Definicao do MBrowse

@author  Totvs
@version 12.1.27
@since   27/11/2018
/*/
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('QL9')
	oBrowse:SetDescripton(STR0001)  // "Cadastro de Pessoas do Instrumento Juridico de Receita"

Return oBrowse


/*/{Protheus.doc} MenuDef
Menu Cadastro Pessoas do Instrumento Juridico de Receita

@author  Totvs
@version 12.1.27
@since   01/12/2020
/*/
Static Function MenuDef()
Return FWMVCMenu('CTBA520')  // Retorna as opcoes padroes de menu.



/*/{Protheus.doc} ModelDef
Modelo para cadastramento de AÃ§Ãµes do PPA.

@author  Totvs
@version 12.1.27
@since   01/12/2020
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'QL9')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('QL9Model', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descriÃ§Ã£o do modelo de dados.
oModel:SetDescription("Cadastro Pessoas Instr.Jur.Receita")

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('QL9MASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('QL9MASTER'):SetDescription(STR0001)  //"Cadastro de Pessoas do Instrumento Juridico de Receita"

// Configura chave primaria.
oModel:SetPrimaryKey({"QL9_FILIAL", "QL9_CODPES"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ViewDef
View para Cadastro de Pessoas do Instrumento Juridico de Receita

@author  Totvs
@version 12.1.27
@since   01/12/2020
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('CTBA520')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'QL9')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados sera utilizado
oView:SetModel(oModel)

// Define que a view sera fechada apos a gravacao dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_QL9', oStruct, 'QL9MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_QL9', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Totvs
@version 12.1.27
@since   01/12/2020
/*/
Static Function ValidPre(oModel)
Local lRet       := .T.
Local nOper      := oModel:getOperation()
If nOper != 1

	If nOper == 2 //visualização
		lRet := .T.

	ElseIf nOper == MODEL_OPERATION_UPDATE
		lRet := .T.

	ElseIf nOper == MODEL_OPERATION_INSERT
		lRet := .T.

	ElseIf nOper == MODEL_OPERATION_DELETE
			lRet := CTBAQL9DEL()
	
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} CTBAQL9DEL
Valida excluso Cadastro de Pessoas do Instrumento Juridico de Receita

@author  Totvs
@version P12
@since   01/12/2020
/*/
Static Function CTBAQL9DEL()

Local lRet       := .T.
Local aArea      := GetArea()
// Local cQuery     := ""
// Local cAliasTRB  := GetNextAlias()
/*  
//ADEQUAR QUERY PARA VERIFICAR SE PESSOA ESTA SENDO USADO EM OUTRA TABELA COMO CHAVE ESTRANGEIRA
cQuery := "SELECT max(AMY_CODUNI) UNIORC "
cQuery += " FROM " + RetSqlName("AMY")
cQuery += " WHERE "
cQuery += " AMY_FILIAL  = '" + xFilial("AMY") + "' "
cQuery += " AND AMY_CODUNI = '" + XYZ->XYZ_CODIGO + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

If (cAliasTRB)->(!Eof() .and. RTrim(UNIORC) <> '')
	lRet := .F.
EndIf
(cAliasTRB)->(dbCloseArea())
*/

If !lRet
	Help(,, 'NO_DEL_PESSOA',, STR0003, 1, 0)  // "Cadastro de Pessoas do Instrumento Juridico de Receita não pode ser excluido! Pessoa ja vinculada ao Instr.Jur.Receita."
EndIf

RestArea(aArea)

Return lRet


