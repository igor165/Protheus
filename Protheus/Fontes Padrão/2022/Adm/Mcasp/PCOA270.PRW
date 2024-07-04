#include "pcoa270.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} PCOA270
Função para cadastramento de Ação PPA
@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Function PCOA270()

Private oBrowse := BrowseDef()

// Ativa browser.
oBrowse:Activate()

Return


/*/{Protheus.doc} BrowseDef
Definição do MBrowse

@author  Totvs
@version 12.1.27
@since   27/11/2018
/*/
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('ALE')
	oBrowse:SetDescripton(STR0001)  // "Cadastro Ações PPA"

Return oBrowse


/*/{Protheus.doc} MenuDef
Menu Cadastro Ações PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA270')  // Retorna as opçoes padroes de menu.



/*/{Protheus.doc} ModelDef
Modelo para cadastramento de Ações do PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'ALE')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('ALEModel', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription("Cadastro Ações PPA")

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('ALEMASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('ALEMASTER'):SetDescription(STR0001)  //"Cadastro Ações PPA"

// Configura chave primaria.
oModel:SetPrimaryKey({"ALE_FILIAL", "ALE_CODACA"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ViewDef
View para cadastramento de Ações do PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA270')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'ALE')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados sera utilizado
oView:SetModel(oModel)

// Define que a view sera fechada apos a gravacao dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_ALE', oStruct, 'ALEMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_ALE', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function ValidPre(oModel)
Local lRet       := .T.
Local nOper      := oModel:getOperation()
Local cUser      := RetCodUsr()
If nOper != 1

	If nOper == 2 
		lRet := PCOAALEUsr( 1, cUser, ALE->ALE_CODACA )   //PRIMEIRO PARAMETRO 1 - SOMENTE VISUALIZAR

	ElseIf nOper == MODEL_OPERATION_UPDATE
		lRet := PCOAALEUsr( 2, cUser, ALE->ALE_CODACA )   //PRIMEIRO PARAMETRO 2 - PERMITE ALTERAR

	ElseIf nOper == MODEL_OPERATION_INSERT
		lRet := PCOAALEUsr( 3, cUser, "" , .T. )           //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

	ElseIf nOper == MODEL_OPERATION_DELETE
		lRet := PCOAALEUsr( 3, cUser, ALE->ALE_CODACA )   //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

		If lRet
			lRet := PCOAALEDEL()
		EndIf

	EndIf

EndIf

Return lRet



/*/{Protheus.doc} PCOAALEUsr
Verifica os usuÃ¡rios que tem acesso para efetuar alteracoes referentes ação do PPA

@author  Totvs
@version P12
@since   21/07/2020
/*/
Function PCOAALEUsr(nOpcao, cUser, cChave, lVerSoDir)
Local lRet := .T.

Default lVerSoDir := .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
    //criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("ALE", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, 'NO_ACESSO_ACAO',, STR0002, 1, 0)  // "Usuario sem acesso para manutenção do cadastro de Ação do PPA."
	EndIf

Return ( lRet )



/*/{Protheus.doc} PCOAALEDEL
Valida excluso de Ações PPA.

@author  Totvs
@version P12
@since   21/07/2020
/*/
Static Function PCOAALEDEL()

Local lRet       := .T.
Local aArea      := GetArea()
// Local cQuery     := ""
// Local cAliasTRB  := GetNextAlias()
/*  
//ADEQUAR QUERY PARA VERIFICAR SE ACAO ESTA EM USO NO PPA
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
	Help(,, 'NO_DEL_ACAO',, STR0003, 1, 0)  // "Ação do PPA não pode ser excluida! Ação ja vinculada ao PPA"
EndIf

RestArea(aArea)

Return lRet

