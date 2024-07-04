#include "pcoa010.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} PCOA010
Função para cadastramento de centros orçamentários.

@author  Felipe Raposo
@version P12.1.17
@since   11/04/2018
/*/
Function PCOA010(nOpcAuto, aCabAuto)

If AMIIn(57)
	If (ValType(nOpcAuto) == "N" .and. nOpcAuto >= 3 .and. nOpcAuto <= 5 .and. ValType(aCabAuto) == "A")
		Private aRotina := MenuDef()
		FWMVCRotAuto(ModelDef(), 'AK5', nOpcAuto, {{"AK5MASTER", aCabAuto}})
	Else
		Private oBrowse := FwMBrowse():New()

		// Ativa browser.
		oBrowse:SetAlias('AK5')
		oBrowse:SetDescripton(STR0001)  // "Cadastro de Centros Orçamentários"
		oBrowse:Activate()
	Endif
Endif

Return


/*/{Protheus.doc} MenuDef
Menu para cadastramento de classes orçamentárias.

@author  Felipe Raposo
@version P12.1.17
@since   11/04/2018
/*/
Static Function MenuDef()

Local aMenu      := {}
Local cSinc      := SuperGetMV("MV_PCOSINC", .T., "1")

// Monta o menu da rotina.
If cSinc $ "2|3" .and. AMIIn(57)
	ADD OPTION aMenu TITLE STR0002 ACTION 'PesqBrw'         OPERATION OP_PESQUISAR           ACCESS 0  // "Pesquisar"
	ADD OPTION aMenu TITLE STR0003 ACTION 'VIEWDEF.PCOA010' OPERATION MODEL_OPERATION_VIEW   ACCESS 0  // "Visualizar"
	ADD OPTION aMenu TITLE STR0005 ACTION 'VIEWDEF.PCOA010' OPERATION MODEL_OPERATION_UPDATE ACCESS 0  // "Alterar"
	ADD OPTION aMenu TITLE STR0007 ACTION 'a010SincCO'      OPERATION MODEL_OPERATION_INSERT ACCESS 0  // "Sincronizar"
Else
	aMenu := FWMVCMenu('PCOA010')
Endif
	
If SUPERGETMV("MV_NEVISAO",,.F.)
	ADD OPTION aMenu TITLE STR0011 ACTION 'PCOA161'      OPERATION 4 ACCESS 0  // "Nota Explicativa"
EndIf

Return aMenu


/*/{Protheus.doc} ModelDef
Modelo para cadastramento de classes orçamentárias.

@author  Felipe Raposo
@version P12.1.17
@since   11/04/2018
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AK5')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AK5Model', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)

// Adiciona ao modelo um componente de formulário.
oModel:AddFields('AK5MASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AK5MASTER'):SetDescription(STR0001)

// Configura chave primária.
oModel:SetPrimaryKey({"AK5_FILIAL", "AK5_CODIGO"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ModelDef
View para cadastramento de classes orçamentárias.

@author  Felipe Raposo
@version P12.1.17
@since   11/04/2018
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA010')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AK5')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel(oModel)

// Define que a view será fechada após a gravação dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulário (antiga enchoice).
oView:AddField('VIEW_AK5', oStruct, 'AK5MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibição.
oView:SetOwnerView('VIEW_AK5', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Felipe Raposo
@version P12.1.17
@since   11/04/2018
/*/
Static Function ValidPre(oModel)

Local lRet       := .T.
Local nOper      := oModel:getOperation()

If nOper == MODEL_OPERATION_DELETE
	lRet := A010ExclOK()
EndIf

Return lRet


/*/{Protheus.doc} PCOA010TOk

@author  Felipe Raposo
@version P12.1.17
@since   11/04/2018
/*/
Function PCOA010TOk()

If Empty(M->AK5_COSUP)
	// Aviso de que a conta superior nao foi preenchida.
	Help(" ", 1, "NOCTASUP")
EndIf

Return .T.


/*/{Protheus.doc} A010ExclOK
Valida exclusão de classes orçamentárias.

@author  Paulo Carnelossi
@version
@since   14/01/2009
/*/
Static Function A010ExclOK()

Local lRet       := .T.
Local aArea      := GetArea()
Local aAK5Area   := AK5->(GetArea())
Local cQuery     := ""
Local cAliasTRB  := GetNextAlias()
Local cCodigoAK5 := ""

// Se encontro a conta como superior de alguma outra conta, restrinjo a exclusão
If AK5->AK5_TIPO == "1" // Sintetica
	cCtaSup := AK5->AK5_CODIGO
	AK5->(DbSetOrder(3)) // AK5_FILIAL + AK5_COSUP
	If AK5->(DbSeek(xFilial() + cCtaSup, .F.))
		Help("  ", 1, "DELCTAORC")
		lRet := .F.
	Endif
	RestArea(aAK5Area)
Endif

cCodigoAK5 := AK5->AK5_CODIGO

//Se encontrar aspas no codigo, realiza a troca por caractere que pode ser usado em query
If ValType(cCodigoAK5) == "C" .And. At("'", cCodigoAK5) > 0
	cCodigoAK5 := ClearAsp(cCodigoAK5)
Endif

If lRet
	cQuery := "SELECT max(AK3_CO) CO "
	cQuery += " FROM " + RetSqlName("AK3")
	cQuery += " WHERE "
	cQuery += " AK3_FILIAL  = '" + xFilial("AK3") + "' "
	cQuery += " AND AK3_CO = '" + cCodigoAK5 + "' "
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

	If (cAliasTRB)->(!Eof() .and. RTrim(CO) <> '')
		Help(,, 'CTASINC',, STR0009, 1, 0)  // "Conta orcamentaria nao pode ser excluida. Verifique planilha/movimento orcamentario."
		lRet := .F.
	Endif
	(cAliasTRB)->(dbCloseArea())
Endif

If lRet
	cQuery := "SELECT max(AKD_CO) CO "
	cQuery += " FROM " + RetSqlName("AKD")
	cQuery += " WHERE "
	cQuery += " AKD_FILIAL  = '" + xFilial("AKD") + "' "
	cQuery += " AND AKD_CO = '" + cCodigoAK5 + "' "
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

	If (cAliasTRB)->(!Eof() .and. RTrim(CO) <> '')
		Help(,, 'CTASINC',, STR0009, 1, 0)  // "Conta orcamentaria nao pode ser excluida. Verifique planilha/movimento orcamentario."
		lRet := .F.
	Endif
	(cAliasTRB)->(dbCloseArea())
Endif

RestArea(aArea)

Return lRet


/*/{Protheus.doc} PCOA010ELK
Encapslumaneto da função A010ExcloK para uso no CTBA020,
validando a exclusão da conta no CTB quando sincronizado.

@author  Pedro Pereira Lima
@since   03/02/2010
/*/
Function PCOA010ELK()

Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaAK5 := AK5->(GetArea("AK5"))
Local aAreaCT1 := CT1->(GetArea("CT1"))

dbSelectArea("AK5")
dbSetOrder(1)
If dbSeek(xFilial("AK5") + PadR(CT1->CT1_CONTA, Len(AK5->AK5_CODIGO)), .F.)
	lRet := A010ExclOK()
EndIf

RestArea(aAreaCT1)
RestArea(aAreaAK5)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PCO010Cta
Função para validação da chave e código da conta orçamentária a ser cadastrada.

@author  Lucas de Oliveira
@version P12
@since   24/09/2014
/*/
//-------------------------------------------------------------------
Function PCO010Cta()

Local aSaveArea  := GetArea()
Local lRet       := .T.

lRet := (ExistChav("AK5",, 1) .and. FreeForUse("AK5", M->AK5_CODIGO))

RestArea(aSaveArea)

Return lRet


/*/{Protheus.doc} a010SincCO
Função para gerar cadastro de centros orcamentários utilizado
no PCO a partir do plano de contas cadastrado no CTB.

@author  Edson Maricate
@version P12
@since   26/08/2005
/*/
Function a010SincCO()
Local cSinc := SuperGetMV("MV_PCOSINC", .T., "1")
Return Processa({|| If(cSinc == "2", SincCT1(), SincCTT()) }, "Verificando sincronização do Plano de Contas. Aguarde...")


/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Felipe Raposo
@version P12
@since   11/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return PCOI010(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
