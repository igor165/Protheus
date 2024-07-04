#include "pcoa275.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} PCOA275
Função para cadastramento de Diretrizes PPA
@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Function PCOA275()

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

	oBrowse:SetAlias('AMS')
	oBrowse:SetDescripton(STR0001)  // "Cadastro Diretrizes PPA"

Return oBrowse


/*/{Protheus.doc} MenuDef
Menu Cadastro Ações PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA275')  // Retorna as opçoes padroes de menu.



/*/{Protheus.doc} ModelDef
Modelo para cadastramento de Ações do PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AMS')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AMSModel', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro Diretrizes PPA"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('AMSMASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AMSMASTER'):SetDescription(STR0001)  //"Cadastro Diretrizes PPA"

// Configura chave primaria.
oModel:SetPrimaryKey({"AMS_FILIAL", "AMS_CODDIR"})

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
Local oModel     := FWLoadModel('PCOA275')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AMS')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados sera utilizado
oView:SetModel(oModel)

// Define que a view sera fechada apos a gravacao dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_AMS', oStruct, 'AMSMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_AMS', 'SUPERIOR')

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
		lRet := PCOAAMSUsr( 1, cUser, AMS->AMS_CODDIR )   //PRIMEIRO PARAMETRO 1 - SOMENTE VISUALIZAR

	ElseIf nOper == MODEL_OPERATION_UPDATE
		lRet := PCOAAMSUsr( 2, cUser, AMS->AMS_CODDIR )   //PRIMEIRO PARAMETRO 2 - PERMITE ALTERAR

	ElseIf nOper == MODEL_OPERATION_INSERT
		lRet := PCOAAMSUsr( 3, cUser, "" , .T. )           //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

	ElseIf nOper == MODEL_OPERATION_DELETE
		lRet := PCOAAMSUsr( 3, cUser, AMS->AMS_CODDIR )   //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

		If lRet
			lRet := PCOAAMSDEL()
		EndIf

	EndIf

EndIf

Return lRet



/*/{Protheus.doc} PCOAAMSUsr
Verifica os usuÃ¡rios que tem acesso para efetuar alteracoes referentes ação do PPA

@author  Totvs
@version P12
@since   21/07/2020
/*/
Function PCOAAMSUsr(nOpcao, cUser, cChave, lVerSoDir)
Local lRet := .T.

Default lVerSoDir := .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
    //criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("AMS", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, 'NO_ACESSO_ACAO',, STR0002, 1, 0)  // "Usuario sem acesso para manutenção do cadastro de Diretrizes do PPA."
	EndIf

Return ( lRet )



/*/{Protheus.doc} PCOAAMSDEL
Valida excluso de Ações PPA.

@author  Totvs
@version P12
@since   21/07/2020
/*/
Static Function PCOAAMSDEL()

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
	Help(,, 'NO_DEL_ACAO',, STR0003, 1, 0)  // "Diretriz do PPA não pode ser excluida! Diretriz ja vinculada ao PPA"
EndIf

RestArea(aArea)

Return lRet

