#include "pcoa290.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} PCOA290
Função para cadastramento de codigo de aplicação
@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Function PCOA290()

Private oBrowse := BrowseDef()

A290Carga()  //Carga da tabela passado como modelo

// Ativa browser.
oBrowse:Activate()

Return


/*/{Protheus.doc} BrowseDef
Definição do MBrowse

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('AML')
	oBrowse:SetDescripton(STR0001)  // "Cadastro Codigo de Aplicacao"

Return oBrowse


/*/{Protheus.doc} MenuDef
Menu Cadastro Codigo de Aplicacao.

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA290')  // Retorna as opçoes padroes de menu.



/*/{Protheus.doc} ModelDef
Modelo para cadastramento de Codigo de Aplicação.

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AML')
Local oModel
Local bPosvld := {|x| A290VldPos(x) }
// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AMLModel', /*bPreValid*/, bPosvld/*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro Codigo de Aplicacao"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('AMLMASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AMLMASTER'):SetDescription(STR0001)  //"Cadastro Codigo de Aplicacao"

// Configura chave primaria.
oModel:SetPrimaryKey({"AML_FILIAL", "AML_CODFIX", "AML_CODVAR"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ViewDef
View para cadastramento de Codigo de Aplicação.

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA290')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AML')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados sera utilizado
oView:SetModel(oModel)

// Define que a view sera fechada apos a gravacao dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_AML', oStruct, 'AMLMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_AML', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function ValidPre(oModel)
Local lRet       := .T.
Local nOper      := oModel:getOperation()
Local cUser      := RetCodUsr()

If nOper != 1

	If nOper == 2 
		lRet := PCOAAMLUsr( 1, cUser, AML->AML_CODFIX+AML->AML_CODVAR )   //PRIMEIRO PARAMETRO 1 - SOMENTE VISUALIZAR

	ElseIf nOper == MODEL_OPERATION_UPDATE
		lRet := PCOAAMLUsr( 2, cUser, AML->AML_CODFIX+AML->AML_CODVAR )   //PRIMEIRO PARAMETRO 2 - PERMITE ALTERAR

	ElseIf nOper == MODEL_OPERATION_INSERT
		lRet := PCOAAMLUsr( 3, cUser, "" , .T. )           //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

	ElseIf nOper == MODEL_OPERATION_DELETE
		lRet := PCOAAMLUsr( 3, cUser, AML->AML_CODFIX+AML->AML_CODVAR )   //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

		If lRet
			lRet := PCOAAMLDEL()
		EndIf

	EndIf

EndIf

Return lRet

/*/{Protheus.doc} A290FixWhen
Somente Inclusao pode editar o campo Cod.Fixo / Gatilha codigo fixo de origem na copia

@author  Totvs
@version P12
@since   02/09/2020
/*/
Function A290FixWhen()
Local lRet := .T.
Local lCopia := .F.
Local oModel := FWModelActive()

	lCopia     := ( oModel:aControls[4] == 6 )  //qdo tiver metodo + apropriado mudar
	If lCopia
		oModel:LoadValue("AMLMASTER","AML_CODFIX", AML->AML_CODFIX )
		lRet := .F.
	Else
		lRet := Inclui
	EndIf

Return lRet

/*/{Protheus.doc} PCOAAMLUsr
Verifica os usuÃ¡rios que tem acesso para efetuar alteracoes referentes ação do PPA

@author  Totvs
@version P12
@since   02/09/2020
/*/
Function PCOAAMLUsr(nOpcao, cUser, cChave, lVerSoDir)
Local lRet := .T.

Default lVerSoDir := .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
    //criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("AML", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, 'NO_ACESSO_CODAPL',, STR0002, 1, 0)  // "Usuario sem acesso para manutenção do cadastro de Codigo de Aplicacao."
	EndIf

Return ( lRet )



/*/{Protheus.doc} PCOAAMLDEL
Valida excluso de Codigo de Aplicacao.

@author  Totvs
@version P12
@since   02/09/2020
/*/
Static Function PCOAAMLDEL()

Local lRet       := .T.
Local aArea      := GetArea()
// Local cQuery     := ""
// Local cAliasTRB  := GetNextAlias()

lRet := (AML->AML_STATUS == '2')  //SOMENTE PODE EXCLUIR SE INATIVO
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
	Help(,, 'NO_DEL_CODAPL',, STR0003, 1, 0)  // "Código de Aplicação não pode ser excluida! "
EndIf

RestArea(aArea)

Return lRet

Static Function A290VldPos( oModel )
Local lRet := .T.

If Inclui
	lRet := ExistChav("AML", M->AML_CODFIX+M->AML_CODVAR)
EndIf

Return( lRet )


/*/{Protheus.doc} A290Carga
Carrega planilha modeloValida excluso de Codigo de Aplicacao.

@author  Totvs
@version P12
@since   02/09/2020
/*/
Static Function A290Carga()
Local aCodApl := {}
Local nX

dbSelectArea("AML")
dbSetOrder(1)

If Len(AML->AML_CODFIX) == 3 .And. Len(AML->AML_CODVAR)==4
	aAdd(aCodApl,{ '100','0000','GERAL TOTAL','Recursos  da entidade de livre aplicação.' }  )
	aAdd(aCodApl,{ '100','XXXX','GERAL - Convênios/Entidades/Fundos','Recursos específicos para aplicação em convênios, entidades ou fundos não vinculados a outras categorias pré-determinadas.' }  )
	aAdd(aCodApl,{ '110','0000','GERAL','Recursos próprios da entidade de livre aplicação.' }  )
	aAdd(aCodApl,{ '111','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos de livre movimentação. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '120','0000','ALIENAÇÃO DE BENS','Recursos advindos de alienações de bens cuja aplicação deverá ser vinculada.' }  )
	aAdd(aCodApl,{ '121','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos de alienação de bens. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '130','0000','CIDE-CONTRIBUIÇÃO DE INTERVENÇÃO NO DOMÍNIO ECONÔMICO','Recursos advindos da CIDE cuja aplicação deverá ser vinculada.' }  )
	aAdd(aCodApl,{ '130','XXXX','CIDE-CONTRIBUIÇÃO DE INTERVENÇÃO NO DOMÍNIO ECONÔMICO - Convênios/Entidades/Fundos','Recursos advindos da CIDE ou de convênios, entidades ou fundos a ela vinculadas.' }  )
	aAdd(aCodApl,{ '131','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos da CIDE. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '140','0000','ROYALTIES DA EXPLORAÇÃO DO PETRÓLEO E GÁS NATURAL','Recursos advindos das receitas provenientes  da participação no resultado ou da compensação financeira pela exploração de petróleo e gás natural.' }  )
	aAdd(aCodApl,{ '141','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos das receitas da participação no resultado ou da compensação financeira pela exploração de petróleo e gás natural.' }  )
	aAdd(aCodApl,{ '200','0000','EDUCAÇÃO','Recursos vinculados à Educação.' }  )
	aAdd(aCodApl,{ '200','XXXX','EDUCAÇÃO - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos da Educação.' }  )
	aAdd(aCodApl,{ '201','0000','OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - CRECHE ','Recursos de Operações e Crédito Vinculadas à Educação para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '201','XXXX','OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos','Recursos de Operações e Crédito Vinculadas à Educação para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '202','0000','OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - PRÉ-ESCOLA','Recursos de Operações e Crédito Vinculadas à Educação para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '202','XXXX','OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Recursos de Operações e Crédito Vinculadas à Educação para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '203','0000','OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - ENSINO FUDAMENTAL','Recursos de Operações e Crédito Vinculadas à Educação para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '203','XXXX','OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - ENSINO FUDAMENTAL - Convênios/Entidades/Fundos','Recursos de Operações e Crédito Vinculadas à Educação para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '204','0000','ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - CRECHE','Recursos de Royalties do Petróleo Destinados a Educação para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '204','XXXX','ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos','Recursos de Royalties do Petróleo Destinados a Educação para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '205','0000','ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA','Recursos de Royalties do Petróleo Destinados a Educação para aplicação em Pré-Escola' }  )
	aAdd(aCodApl,{ '205','XXXX','ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Recursos de Royalties do Petróleo Destinados a Educação para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '206','0000','ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - ENSINO FUNDAMENTAL','Recursos de Royalties do Petróleo Destinados a Educação para aplicação no Ensino Fundamental' }  )
	aAdd(aCodApl,{ '206','XXXX','ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos','Recursos de Royalties do Petróleo Destinados a Educação para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '207','0000','RECEITA PELA PRESTAÇÃO DE SERVIÇOS EDUCACIONAIS ','Recursos decorrentes de receitas da prestação de serviços educacionais.' }  )
	aAdd(aCodApl,{ '207','XXXX','RECEITA PELA PRESTAÇÃO DE SERVIÇOS EDUCACIONAIS - Convênios/Entidades/Fundos','Recursos decorrentes de receitas da prestação de serviços educacionais.' }  )
	aAdd(aCodApl,{ '210','0000','EDUCAÇÃO INFANTIL','Recursos vinculados à Educação Infantil.' }  )
	aAdd(aCodApl,{ '210','XXXX','EDUCAÇÃO INFANTI - Convênios/Entidades/Fundos','Recursos vinculados à convênios da Educação Infantil.' }  )
	aAdd(aCodApl,{ '211','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados da Educação Infantil. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '212','0000','EDUCAÇÃO INFANTIL - CRECHE','Recursos vinculados à Educação Infantil - Creche.' }  )
	aAdd(aCodApl,{ '212','XXXX','EDUCAÇÃO INFANTIL - CRECHE - Convênios/Entidades/Fundos','Recursos vinculados à convênios da Educação Infantil - Creche.' }  )
	aAdd(aCodApl,{ '213','0000','EDUCAÇÃO INFANTIL - PRÉ-ESCOLA','Recursos vinculados à Educação Infantil - Pré-Escola.' }  )
	aAdd(aCodApl,{ '213','XXXX','EDUCAÇÃO INFANTIL - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Recursos vinculados à convênios da Educação Infantil - Pré-Escola.' }  )
	aAdd(aCodApl,{ '220','0000','ENSINO FUNDAMENTAL','Recursos vinculados ao Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '220','XXXX','ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos do Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '221','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados do Ensino Fundamental. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '230','0000','ENSINO MÉDIO','Recursos vinculados ao Ensino Médio.' }  )
	aAdd(aCodApl,{ '230','XXXX','ENSINO MÉDIO - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos do Ensino Médio.' }  )
	aAdd(aCodApl,{ '231','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados do Ensino Médio. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '232','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO MÉDIO','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação no Ensino Médio.' }  )
	aAdd(aCodApl,{ '232','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO MÉDIO - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação no Ensino Médio.' }  )
//	aAdd(aCodApl,{ '233','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO MÉDIO','Recursos do Programa Nacional de Alimentação Escolar para aplicação no Ensino Médio.' }  )
	aAdd(aCodApl,{ '233','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO MÉDIO - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Alimentação Escolar para aplicação no Ensino Médio.' }  )
	aAdd(aCodApl,{ '240','0000','EDUCAÇÃO ESPECIAL','Recursos vinculados ao Ensino Médio.' }  )
	aAdd(aCodApl,{ '240','XXXX','EDUCAÇÃO ESPECIAL - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos do Ensino Médio.' }  )
	aAdd(aCodApl,{ '241','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados do Ensino Especial. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '242','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EDUCAÇÃO ESPECIAL','Recursos do Programa Nacional de Alimentação Escolar para aplicação no Educação Especial.' }  )
	aAdd(aCodApl,{ '242','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EDUCAÇÃO ESPECIAL - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Alimentação Escolar para aplicação no Educação Especial.' }  )
	aAdd(aCodApl,{ '243','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EJA','Recursos do Programa Nacional de Alimentação Escolar para aplicação na Educação de Jovens e Adultos (EJA).' }  )
	aAdd(aCodApl,{ '243','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EJA - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Alimentação Escolar para aplicação na Educação de Jovens e Adultos (EJA).' }  )
	aAdd(aCodApl,{ '250','0000','EDUCAÇÃO - FUNDEF','Recursos vinculados ao FUNDEF.' }  )
	aAdd(aCodApl,{ '251','0000','EDUCAÇÃO - FUNDEF - MAGISTÉRIO','Recursos vinculados ao FUNDEF para aplicação no magistério.' }  )
	aAdd(aCodApl,{ '252','0000','EDUCAÇÃO - FUNDEF - OUTROS','Recursos vinculados ao FUNDEF para aplicação em outras despesas.' }  )
	aAdd(aCodApl,{ '253','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados do FUNDEF. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '260','0000','EDUCAÇÃO - FUNDEB','Recursos vinculados ao FUNDEB.' }  )
	aAdd(aCodApl,{ '260','XXXX','EDUCAÇÃO - FUNDEB - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos do FUNDEB.' }  )
	aAdd(aCodApl,{ '261','0000','EDUCAÇÃO - FUNDEB - MAGISTÉRIO','Recursos vinculados ao FUNDEB para aplicação no magistério.' }  )
	aAdd(aCodApl,{ '262','0000','EDUCAÇÃO - FUNDEB - OUTROS','Recursos vinculados ao FUNDEB para aplicação em outras despesas.' }  )
	aAdd(aCodApl,{ '263','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados do FUNDEB. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '264','AAAA','EDUCAÇÃO - FUNDEB - MAGISTÉRIO - Ano Anterior','Recursos vinculados ao FUNDEB para aplicação no magistério, advindos de exercícios anteriores. Identificado pelo ano de ingresso dos recursos.' }  )
	aAdd(aCodApl,{ '265','AAAA','EDUCAÇÃO - FUNDEB - OUTROS - Ano Anterior ','Recursos vinculados ao FUNDEB para aplicação em outras despesas, advindos de exercícios anteriores. Identificado pelo ano de ingresso dos recursos.' }  )
	aAdd(aCodApl,{ '266','AAAA','EDUCAÇÃO - FUNDEB - MAGISTÉRIO - Ano Anterior - CRECHE','Recursos vinculados ao FUNDEB para aplicação no magistério, advindos de exercícios anteriores. Identificado pelo ano de ingresso dos recursos - Creche.' }  )
	aAdd(aCodApl,{ '267','AAAA','EDUCAÇÃO - FUNDEB - MAGISTÉRIO - Ano Anterior - PRÉ-ESCOLA','Recursos vinculados ao FUNDEB para aplicação no magistério, advindos de exercícios anteriores. Identificado pelo ano de ingresso dos recursos - Pré-Escola.' }  )
	aAdd(aCodApl,{ '268','AAAA','EDUCAÇÃO - FUNDEB-OUTROS - Ano Anterior - CRECHE','Recursos vinculados ao FUNDEB para aplicação em outras despesas, advindos de exercícios anteriores. Identificado pelo ano de ingresso dos recursos - Creche.' }  )
	aAdd(aCodApl,{ '269','AAAA','EDUCAÇÃO - FUNDEB - OUTROS - Ano Anterior - PRÉ-ESCOLA','Recursos vinculados ao FUNDEB para aplicação em outras despesas, advindos de exercícios anteriores. Identificado pelo ano de ingresso dos recursos - Pré-Escola.' }  )
	aAdd(aCodApl,{ '271','0000','EDUCAÇÃO - FUNDEB - MAGISTÉRIO - CRECHE','Recursos vinculados ao FUNDEB para aplicação no magistério - Creche.' }  )
	aAdd(aCodApl,{ '272','0000','EDUCAÇÃO - FUNDEB - MAGISTÉRIO - PRÉ-ESCOLA','Recursos vinculados ao FUNDEB para aplicação no magistério - Pré-Escola.' }  )
	aAdd(aCodApl,{ '273','0000','EDUCAÇÃO - FUNDEB - OUTROS - CRECHE','Recursos vinculados ao FUNDEB para aplicação em outras despesas - Creche.' }  )
	aAdd(aCodApl,{ '274','0000','EDUCAÇÃO - FUNDEB - OUTROS - PRÉ-ESCOLA','Recursos vinculados ao FUNDEB para aplicação em outras despesas - Pré-Escola.' }  )
	aAdd(aCodApl,{ '275','0000','RECURSOS COMPLEMENTAÇÃO DO FUNDEB - MAGISTÉRIO - CRECHE','Recursos vinculados ao FUNDEB decorrentes de complementação da União para aplicação no magistério - Creche.' }  )
	aAdd(aCodApl,{ '276','0000','RECURSOS COMPLEMENTAÇÃO DO FUNDEB - MAGISTÉRIO - PRÉ - ESCOLA','Recursos vinculados ao FUNDEB decorrentes de complementação da União para aplicação no magistério - Pré-Escola.' }  )
	aAdd(aCodApl,{ '277','0000','RECURSOS COMPLEMENTAÇÃO DO FUNDEB - MAGISTÉRIO - ENSINO FUDAMENTAL','Recursos vinculados ao FUNDEB decorrentes de complementação da União para aplicação no magistério - Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '280','0000','RECURSOS DO SALÁRIO EDUCAÇÃO - CRECHE','Recursos do Salário Educação para aplicação em Creche.' }  )
	aAdd(aCodApl,{ '280','XXXX','RECURSOS DO SALÁRIO EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos','Recursos do Salário Educação para aplicação em Creche.' }  )
	aAdd(aCodApl,{ '281','0000','RECURSOS DO SALÁRIO EDUCAÇÃO - PRÉ-ESCOLA','Recursos do Salário Educação para aplicação em Pré - Escola.' }  )
	aAdd(aCodApl,{ '281','XXXX','RECURSOS DO SALÁRIO EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Recursos do Salário Educação para aplicação em Pré - Escola.' }  )
	aAdd(aCodApl,{ '282','0000','RECURSOS DO SALÁRIO EDUCAÇÃO - ENSINO FUNDAMENTAL','Recursos do Salário Educação para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '282','XXXX','RECURSOS DO SALÁRIO EDUCAÇÃO - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos','Recursos do Salário Educação para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '283','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - CRECHE','Recursos do Programa Nacional de Alimentação Escolar para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '283','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - CRECHE - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Alimentação Escolar para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '284','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - PRÉ-ESCOLA','Recursos do Programa Nacional de Alimentação Escolar para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '284','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Alimentação Escolar para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '285','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO FUNDAMENTAL','Recursos do Programa Nacional de Alimentação Escolar para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '285','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Alimentação Escolar para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '286','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - CRECHE','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '286','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - CRECHE - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '287','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - PRÉ-ESCOLA','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '287','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '288','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO FUNDAMENTAL','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '288','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '291','0000','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - CRECHE','Recursos do Programa Dinheiro Direto na Escola para aplicação em Creche.' }  )
	aAdd(aCodApl,{ '291','XXXX','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - CRECHE - Convênios/Entidades/Fundos','Recursos do Programa Dinheiro Direto na Escola para aplicação em Creche.' }  )
	aAdd(aCodApl,{ '292','0000','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - PRÉ-ESCOLA','Recursos do Programa Dinheiro Direto na Escola para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '292','XXXX','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Recursos do Programa Dinheiro Direto na Escola para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '293','0000','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - ENSINO FUNDAMENTAL','Recursos do Programa Dinheiro Direto na Escola para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '293','XXXX','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos','Recursos do Programa Dinheiro Direto na Escola para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '294','0000','OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - CRECHE',' Outras Transferências de Recursos do FNDE para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '294','XXXX','OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - CRECHE - Convênios/Entidades/Fundos',' Outras Transferências de Recursos do FNDE para aplicação em Creches.' }  )
	aAdd(aCodApl,{ '295','0000','OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - PRÉ-ESCOLA',' Outras Transferências de Recursos do FNDE para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '295','XXXX','OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - PRÉ-ESCOLA - Convênios/Entidades/Fundos ',' Outras Transferências de Recursos do FNDE para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '296','0000','OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - ENSINO FUNDAMENTAL',' Outras Transferências de Recursos do FNDE para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '296','XXXX','OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos ',' Outras Transferências de Recursos do FNDE para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '297','0000','OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - CRECHE ','Outras  Recursos destinados à Educação para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '297','XXXX','OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos','Outras  Recursos destinados à Educação para aplicação em Pré-Escola.' }  )
	aAdd(aCodApl,{ '298','0000','OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA','Outras  Recursos destinados à Educação para aplicação em Creche.' }  )
	aAdd(aCodApl,{ '298','XXXX','OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos','Outras  Recursos destinados à Educação para aplicação em Creche.' }  )
	aAdd(aCodApl,{ '299','0000','OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - ENSINO FUNDAMENTAL','Outras  Recursos destinados à Educação para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '299','XXXX','OUTROS RECURSOS DESTINADOS À EDUCAÇÃO  - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos','Outras  Recursos destinados à Educação para aplicação no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '300','0000','SAÚDE','Recursos vinculados à Saúde.' }  )
	aAdd(aCodApl,{ '300','XXXX','SAÚDE - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos da Saúde.' }  )
	aAdd(aCodApl,{ '301','0000','ATENÇÃO BÁSICA','Recursos destinados às ações da Atenção Básica.' }  )
	aAdd(aCodApl,{ '301','XXXX','ATENÇÃO BÁSICA - Convênios/Entidades/Fundos','Recursos destinados à ações da Atenção Básica provenientes de transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '302','0000','ATENÇÃO DE MÉDIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR','Recursos destinados às ações de Média e Alta Complexidade Ambulatorial e Hospitalar.' }  )
	aAdd(aCodApl,{ '302','XXXX','ATENÇÃO DE MÉDIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR - Convênios/Entidades/Fundos','Recursos destinados às ações de Média e Alta Complexidade Ambulatorial e Hospitalar provenientes de transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '303','0000','VIGILÂNCIA EM SAÚDE','Recursos destinados às ações de Vigilância em Saúde.' }  )
	aAdd(aCodApl,{ '303','XXXX','VIGILÂNCIA EM SAÚDE - Convênios/Entidades/Fundos','Recursos destinados às ações de Vigilância em Saúde provenientes de transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '304','0000','ASSISTÊNCIA FARMACÊUTICA','Recursos destinados às ações de Assistência Farmacèutica.' }  )
	aAdd(aCodApl,{ '304','XXXX','ASSISTÊNCIA FARMACÊUTICA - Convênios/Entidades/Fundos','Recursos destinados às ações de Assistência Farmacêutica provenientes de transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '305','0000','GESTÃO DO SUS','Recursos destinados às ações de Gestão do SUS.' }  )
	aAdd(aCodApl,{ '305','XXXX','GESTAO DO SUS - Convênios/Entidades/Fundos','Recursos destinados às ações de Gestão do SUS provenientes de transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '307','0000','OUTROS PROGRAMAS FINANCIADOS POR TRANSFERÊNCIAS FUNDO A FUNDO','Recursos destinados a Outros Programas Financiados por Transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '307','XXXX','OUTROS PROGRAMAS FINANCIADOS POR TRANSFERÊNCIAS FUNDO A FUNDO - Convênios/Entidades/Fundos','Recursos destinados a Outros Programas Financiados por Transferências fundo a fundo provenientes de transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '308','0000','CONVÊNIOS SUS','Recursos destinados a Convênios com o SUS.' }  )
	aAdd(aCodApl,{ '308','XXXX','CONVÊNIOS SUS - Convênios/Entidades/Fundos','Recursos destinados a Convênios provenientes de convênios com o SUS.' }  )
	aAdd(aCodApl,{ '309','0000','SERVIÇOS DE SAÚDE','Recursos destinados às ações de Serviços de Saúde.' }  )
	aAdd(aCodApl,{ '309','XXXX','SERVIÇOS DE SAÚDE - Convênios/Entidades/Fundos','Recursos destinados às ações de Serviços de Saúde provenientes de transferências fundo a fundo.' }  )
	aAdd(aCodApl,{ '310','0000','SAÚDE–GERAL','Recursos vinculados à Saúde Geral.' }  )
	aAdd(aCodApl,{ '311','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados da Saúde. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '320','0000','SAÚDE - TAXAS','Recursos advindos das receitas de taxas vinculadas à Saúde cuja aplicação deverá ser vinculada à Saúde.' }  )
	aAdd(aCodApl,{ '330','0000','SAÚDE - SERVIÇOS','Recursos advindos das receitas de serviços vinculadas à Saúde cuja aplicação deverá ser vinculada à Saúde.' }  )
	aAdd(aCodApl,{ '340','0000','SAÚDE - OUTROS','Recursos advindos das outras receitas vinculadas à Saúde cuja aplicação deverá ser vinculada à Saúde.' }  )
	aAdd(aCodApl,{ '350','0000','BLOCO DE CUSTEIO DAS AÇÕES E SERVIÇOS PÚBLICOS DE SAÚDE','Esta codificação deverá ser utilizada exclusivamente nos registros contábeis  da receita e do ativo disponivel decorrentes do ingresso de  Recursos destinados às ações e serviços públicos de saúde relacionados ao Bloco de Custeio.' }  )
	aAdd(aCodApl,{ '351','0000','BLOCO DE CUSTEIO DAS AÇÕES E SERVIÇOS PÚBLICOS DE SAÚDE - Remuneração de Aplicação Financeira','Esta codificação deverá ser utilizada exclusivamente no registros contábeis decorrentos  da remuneração de aplicação financeira dos  Recursos destinados às ações e serviços públicos de saúde relacionados ao Bloco de Custeio.' }  )
	aAdd(aCodApl,{ '360','0000','BLOCO DE INVESTIMENTOS NA REDE DE SERVIÇOS DE SAÚDE','Esta codificação deverá ser utilizada exclusivamente nos registros contábeis  da receita e no ativo disponivel decorrentes do ingresso de  Recursos destinados às ações e serviços públicos de saúde relacionados ao Bloco de Investimentos.' }  )
	aAdd(aCodApl,{ '361','0000','BLOCO DE INVESTIMENTOS NA REDE DE SERVIÇOS DE SAÚDE - Remuneração de Aplicação Financeira','Esta codificação deverá ser utilizada exclusivamente no registro contábil da remuneração de aplicação financeira dos  Recursos destinados às ações e serviços públicos de saúde relacionados ao ao Bloco de Investimentos.' }  )
	aAdd(aCodApl,{ '400','0000','TRÂNSITO','Recursos vinculados ao Trânsito.' }  )
	aAdd(aCodApl,{ '400','XXXX','TRÂNSITO - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos ao Trânsito.' }  )
	aAdd(aCodApl,{ '410','0000','TRÂNSITO - SINALIZAÇÃO','Recursos vinculados ao Trânsito, para aplicação em sinalização.' }  )
	aAdd(aCodApl,{ '411','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados do Trânsito-Sinalização. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '420','0000','TRÂNSITO - ENGENHARIA DE TRÂNSITO','Recursos vinculados ao Trânsito, para aplicação em engenharia de trânsito.' }  )
	aAdd(aCodApl,{ '430','0000','TRÂNSITO - ENGENHARIA DE CAMPO','Recursos vinculados ao Trânsito, para aplicação em engenharia de campo..' }  )
	aAdd(aCodApl,{ '440','0000','TRÂNSITO - POLICIAMENTO','Recursos vinculados ao Trânsito, para aplicação em policiamento.' }  )
	aAdd(aCodApl,{ '450','0000','TRÂNSITO - FISCALIZAÇÃO','Recursos vinculados ao Trânsito, para aplicação em fiscalização.' }  )
	aAdd(aCodApl,{ '460','0000','TRÂNSITO - EDUCAÇÃO DE TRÂNSITO','Recursos vinculados ao Trânsito, para aplicação em educação de trânsito.' }  )
	aAdd(aCodApl,{ '470','0000','TRÂNSITO - FUNSET','Recursos vinculados ao Trânsito - FUNSET.' }  )
	aAdd(aCodApl,{ '500','0000','ASSISTÊNCIA SOCIAL','Recursos vinculados à Assistência Social.' }  )
	aAdd(aCodApl,{ '500','XXXX','ASSISTÊNCIA SOCIAL - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos da Assistência Social.' }  )
	aAdd(aCodApl,{ '510','0000','ASSISTÊNCIA SOCIAL - GERAL','Recursos vinculados à Assistência Social - Geral.' }  )
	aAdd(aCodApl,{ '511','0000','REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS','Recursos advindos de aplicações financeiras dos recursos vinculados à Assistência Social. Utilizado apenas para a classificação de receitas.' }  )
	aAdd(aCodApl,{ '600','0000','REGIME PRÓPRIO DE PREVIDÊNCIA SOCIAL','Recursos vinculados ao RPPS.' }  )
	aAdd(aCodApl,{ '600','XXXX','RPPS - Convênios/Entidades/Fundos','Recursos vinculados à convênios, entidades ou fundos do RPPS.' }  )
	aAdd(aCodApl,{ '601','0000','REGIME PRÓPRIO DE PREVIDÊNCIA SOCIAL - PLANO FINANCEIRO','Recursos vinculados ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '602','0000','REGIME PRÓPRIO DE PREVIDÊNCIA SOCIAL - PLANO PREVIDENCIÁRIO','Recursos vinculados ao RPPS - Plano Previdenciário.' }  )
	aAdd(aCodApl,{ '610','0000','RPPS - CONTRIBUIÇÕES','Recursos advindos das receitas de contribuições vinculadas ao RPPS cuja aplicação deverá ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '611','0000','RPPS - CONTRIBUIÇÃO PATRONAL','Recursos advindos das receitas de contribuições patronais ao RPPS cuja aplicação deverá ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '612','0000','RPPS - CONTRIBUIÇÃO SEGURADOS','Recursos advindos das receitas de contribuições dos segurados ao RPPS cuja aplicação deverá ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '613','0000','RPPS - CONTRIBUIÇÕES - PLANO FINANCEIRO','Recursos advindos das receitas de contribuições vinculadas ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '614','0000','RPPS - CONTRIBUIÇÕES - PLANO PREVIDENCIÁRIO','Recursos advindos das receitas de contribuições vinculadas ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Previdenciário.' }  )
	aAdd(aCodApl,{ '615','0000','RPPS - CONTRIBUIÇÃO PATRONAL - PLANO FINANCEIRO','Recursos advindos das receitas de contribuições patronais ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '616','0000','RPPS - CONTRIBUIÇÃO PATRONAL - PLANO PREVIDENCIÁRIO','Recursos advindos das receitas de contribuições patronais ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Previdenciário.' }  )
	aAdd(aCodApl,{ '617','0000','RPPS - CONTRIBUIÇÃO SEGURADOS - PLANO FINANCEIRO','Recursos advindos das receitas de contribuições dos segurados ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '618','0000','RPPS - CONTRIBUIÇÃO SEGURADOS - PLANO PREVIDENCIÁRIO','Recursos advindos das receitas de contribuições dos segurados ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Previdenciário.' }  )
	aAdd(aCodApl,{ '620','0000','RPPS - COMPENSAÇÃO PREVIDENCIÁRIA','Recursos advindos das receitas de compensação previdenciária ao RPPS cuja aplicação deverá ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '621','0000','RPPS - COMPENSAÇÃO PREVIDENCIÁRIA - PLANO FINANCEIRO','Recursos advindos das receitas de compensação previdenciária ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '622','0000','RPPS - COMPENSAÇÃO PREVIDENCIÁRIA - PLANO PREVIDENCIÁRIO','Recursos advindos das receitas de compensação previdenciária ao RPPS cuja aplicação deverá ser vinculada ao RPPS - Plano Previdenciário.' }  )
	aAdd(aCodApl,{ '700','0000','DESVINCULAÇÃO DE RECEITAS MUNICIPAIS - DRM','Desvinculação de 30% da receita dos municípios relativas a impostos, taxas, e multas conforme previsto na Emenda Constitucional nº 93/2016. Este código deverá ser utilizado exclusivamente no Controle de Disponibilidade Financeira por destinação de recursos e no registro da despesa orçamentária custeadas com recursos da DRM.' }  )

	For nX := 1 TO Len(aCodApl)
		If ! dbSeek(xFilial("AML")+aCodApl[nX, 1]+aCodApl[nX, 2])
			AML->( RecLock("AML", .T. ) )
			AML->AML_FILIAL := xFilial("AML")
			AML->AML_CODFIX := aCodApl[nX, 1]
			AML->AML_CODVAR := aCodApl[nX, 2]
			AML->AML_NOME   := aCodApl[nX, 3]
			AML->AML_ESPEC  := aCodApl[nX, 4]
			If aCodApl[nX, 2] != 'XXXX'
				AML->AML_STATUS := '1'
			Else
				AML->AML_STATUS := '2'
			EndIf
			AML->( MsUnLock() )
		EndIf
	Next

EndIf

Return



