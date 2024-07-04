#include "pcoa295.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} PCOA295
Função para cadastramento de Fonte de Recurso
@author  Totvs
@version 12.1.27
@since   08/09/2020
/*/
Function PCOA295()

Private oBrowse := BrowseDef()

A295Carga()  //Carga da tabela passado como modelo

// Ativa browser.
oBrowse:Activate()

Return


/*/{Protheus.doc} BrowseDef
Definição do MBrowse

@author  Totvs
@version 12.1.27
@since   08/09/2020
/*/
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('AM0')
	oBrowse:SetDescripton(STR0001)  // "Cadastro Fonte de Recurso"

Return oBrowse


/*/{Protheus.doc} MenuDef
Menu Cadastro Fonte de Recurso.

@author  Totvs
@version 12.1.27
@since   08/09/2020
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA295')  // Retorna as opções padroes de menu.



/*/{Protheus.doc} ModelDef
Modelo para cadastramento de Fonte de Recurso.

@author  Totvs
@version 12.1.27
@since   08/09/2020
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AM0')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AM0Model', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro Fonte de Recurso"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('AM0MASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AM0MASTER'):SetDescription(STR0001)  //"Cadastro Fonte de Recurso"

// Configura chave primaria.
oModel:SetPrimaryKey({"AM0_FILIAL", "AM0_CODFRC "})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ViewDef
View para cadastramento de Fonte de Recurso.

@author  Totvs
@version 12.1.27
@since   08/09/2020
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA295')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AM0')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados sera utilizado
oView:SetModel(oModel)

// Define que a view sera fechada apos a gravacao dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_AM0', oStruct, 'AM0MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_AM0', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Totvs
@version 12.1.27
@since   08/09/2020
/*/
Static Function ValidPre(oModel)
Local lRet       := .T.
Local nOper      := oModel:getOperation()
Local cUser      := RetCodUsr()

If nOper != 1

	If nOper == 2 
		lRet := PCOAAM0Usr( 1, cUser, AM0->AM0_CODFRC )   //PRIMEIRO PARAMETRO 1 - SOMENTE VISUALIZAR

	ElseIf nOper == MODEL_OPERATION_UPDATE
		lRet := PCOAAM0Usr( 2, cUser, AM0->AM0_CODFRC )   //PRIMEIRO PARAMETRO 2 - PERMITE ALTERAR

	ElseIf nOper == MODEL_OPERATION_INSERT
		lRet := PCOAAM0Usr( 3, cUser, "" , .T. )           //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

	ElseIf nOper == MODEL_OPERATION_DELETE
		lRet := PCOAAM0Usr( 3, cUser, AM0->AM0_CODFRC )   //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

		If lRet
			lRet := PCOAAM0DEL()
		EndIf

	EndIf

EndIf

Return lRet


/*/{Protheus.doc} PCOAAM0Usr
Verifica os usuÃƒÂ¡rios que tem acesso para efetuar alteracoes referentes 

@author  Totvs
@version P12
@since   08/09/2020
/*/
Function PCOAAM0Usr(nOpcao, cUser, cChave, lVerSoDir)
Local lRet := .T.

Default lVerSoDir := .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
    //criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("AM0", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, 'NO_ACESSO_CODAPL',, STR0002, 1, 0)  // "Usuario sem acesso para manutenção do cadastro de Fonte de Recurso."
	EndIf

Return ( lRet )



/*/{Protheus.doc} PCOAAM0DEL
Valida excluso de Fonte de Recurso.

@author  Totvs
@version P12
@since   08/09/2020
/*/
Static Function PCOAAM0DEL()

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
	Help(,, 'NO_DEL_CODAPL',, STR0003, 1, 0)  // "Cadastro de Fonte de Recurso não pode ser excluido! "
EndIf

RestArea(aArea)

Return lRet



/*/{Protheus.doc} A295Carga
Carrega planilha modeloValida excluso de Fonte de Recurso.

@author  Totvs
@version P12
@since   08/09/2020
/*/
Static Function A295Carga()
Local aFontRec := {}
Local nX

dbSelectArea("AM0")
dbSetOrder(1)

aAdd(aFontRec,{ '01','TESOURO','Recursos próprios gerados pelo Município, ou decorrentes de Cota-Parte Constitucional;','1' } )
aAdd(aFontRec,{ '02','TRANSFERÊNCIAS E CONVÊNIOS ESTADUAIS - VINCULADOS','Recursos originários de transferências estaduais em virtude de assinatura de convênios ou legislações específicas, cuja destinação encontra-se vinculada aos seus objetos;','2' } )
aAdd(aFontRec,{ '03','RECURSOS PRÓPRIOS DE FUNDOS ESPECIAIS DE DESPESA - VINCULADOS','Recursos gerados pelos Fundos Especiais de Despesa ou a eles pertencentes, com destinação vinculada conforme legislação específica de criação de cada Fundo;','2' } )
aAdd(aFontRec,{ '04','RECURSOS PRÓPRIOS DA ADMINISTRAÇÃO INDIRETA','Recursos gerados pelos respectivos Órgãos que compõem a Administração Indireta do Município, conforme legislação específica de criação de cada entidade;','2' } )
aAdd(aFontRec,{ '05','TRANSFERÊNCIAS E CONVÊNIOS FEDERAIS - VINCULADOS','Recursos originários de transferências federais em virtude de assinatura de convênios ou legislações específicas, cuja destinação encontra-se vinculada aos seus objetos;','2' } )
aAdd(aFontRec,{ '06','OUTRAS FONTES DE RECURSOS','Recursos não enquadrados em especificações próprias;','2' } )
aAdd(aFontRec,{ '07','OPERAÇÕES DE CRÉDITO','Recursos originários de operações de crédito internas ou externas;','2' } )
aAdd(aFontRec,{ '08','EMENDAS PARLAMENTARES INDIVIDUAIS','Recursos destinados ao atendimento às emendas parlamentares individuais por força da Emenda Constitucional nº 86, de 17 de março de 2015.','2' } )
aAdd(aFontRec,{ '91','TESOURO - Exercícios Anteriores','Recursos próprios gerados pelo Município, ou decorrentes de Cota-Parte Constitucional; Utilizada apenas para controle das disponibilidades financeiras advindas do exercício anterior.','2' } )
aAdd(aFontRec,{ '92','TRANSFERÊNCIAS E CONVÊNIOS ESTADUAIS - VINCULADOS - Exercícios Anteriores','Recursos originários de transferências estaduais em virtude de assinatura de convênios ou legislações específicas, cuja destinação encontra-se vinculada aos seus objetos; Utilizada apenas para controle das disponibilidades financeiras advindas do exercício anterior.','2' } )
aAdd(aFontRec,{ '93','RECURSOS PRÓPRIOS DE FUNDOS ESPECIAIS DE DESPESA - VINCULADOS - Exercícios Anteriores','Recursos gerados pelos Fundos Especiais de Despesa ou a eles pertencentes, com destinação vinculada conforme legislação específica de criação de cada Fundo;','2' } )
aAdd(aFontRec,{ '94','RECURSOS PRÓPRIOS DA ADMINISTRAÇÃO INDIRETA - Exercícios Anteriores','Recursos gerados pelos respectivos Órgãos que compõem a Administração Indireta do Município, conforme legislação específica de criação de cada entidade; Utilizada apenas para controle das disponibilidades financeiras advindas do exercício anterior.','2' } )
aAdd(aFontRec,{ '95','TRANSFERÊNCIAS E CONVÊNIOS FEDERAIS - VINCULADOS - Exercícios Anteriores','Recursos originários de transferências federais em virtude de assinatura de convênios ou legislações específicas, cuja destinação encontra-se vinculada aos seus objetos; Utilizada apenas para controle das disponibilidades financeiras advindas do exercício anterior.','2' } )
aAdd(aFontRec,{ '96','OUTRAS FONTES DE RECURSOS - Exercícios Anteriores','Recursos não enquadrados em especificações próprias;','2' } )
aAdd(aFontRec,{ '97','OPERAÇÕES DE CRÉDITO - Exercícios Anteriores','Recursos originários de operações de crédito internas ou externas; Utilizada apenas para controle das disponibilidades financeiras advindas do exercício anterior.','2' } )
aAdd(aFontRec,{ '98','EMENDAS PARLAMENTARES INDIVIDUAIS - Exercícios Anteriores','Recursos destinados ao atendimento às emendas parlamentares individuais por força da Emenda Constitucional nº 86, de 17 de março de 2015, do exercício anterior.','2' } )

For nX := 1 TO Len(aFontRec)
	If ! dbSeek(xFilial("AM0")+aFontRec[nX, 1]+aFontRec[nX, 2])
		AM0->( RecLock("AM0", .T. ) )
		AM0->AM0_FILIAL := xFilial("AM0")
		AM0->AM0_CODFRC := aFontRec[nX, 1]
		AM0->AM0_DESCFR := aFontRec[nX, 2]
		AM0->AM0_ESPEFR := aFontRec[nX, 3]
		AM0->AM0_TIPREC := aFontRec[nX, 4]
		AM0->( MsUnLock() )
	EndIf
Next

Return



