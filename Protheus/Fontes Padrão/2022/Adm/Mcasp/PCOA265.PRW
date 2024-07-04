#include "pcoa265.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

//amarracao

/*/{Protheus.doc} PCOA265
Função para cadastramento de Produtos PPA
@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Function PCOA265()

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

	oBrowse:SetAlias('ALZ')
	oBrowse:SetDescripton(STR0001)  // "Cadastro Produtos PPA"

Return oBrowse


/*/{Protheus.doc} MenuDef
Menu Cadastro Produtos PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA265')  // Retorna as opçoes padroes de menu.



/*/{Protheus.doc} ModelDef
Modelo para cadastramento de Produtos do PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'ALZ')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('ALZModel', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro Produtos PPA"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('ALZMASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('ALZMASTER'):SetDescription(STR0001)  //"Cadastro Produtos PPA"

// Configura chave primaria.
oModel:SetPrimaryKey({"ALZ_FILIAL", "ALZ_CODPRO"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ViewDef
View para cadastramento de Produtos do PPA.

@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA265')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'ALZ')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados sera utilizado
oView:SetModel(oModel)

// Define que a view sera fechada apos a gravacao dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_ALZ', oStruct, 'ALZMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_ALZ', 'SUPERIOR')

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
		lRet := PCOAALZUsr( 1, cUser, ALZ->ALZ_CODPRO )   //PRIMEIRO PARAMETRO 1 - SOMENTE VISUALIZAR

	ElseIf nOper == MODEL_OPERATION_UPDATE
		lRet := PCOAALZUsr( 2, cUser, ALZ->ALZ_CODPRO )   //PRIMEIRO PARAMETRO 2 - PERMITE ALTERAR

	ElseIf nOper == MODEL_OPERATION_INSERT
		lRet := PCOAALZUsr( 3, cUser, "" , .T. )           //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

	ElseIf nOper == MODEL_OPERATION_DELETE
		lRet := PCOAALZUsr( 3, cUser, ALZ->ALZ_CODPRO )   //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

		If lRet
			lRet := PCOAALZDEL()
		EndIf

	EndIf

EndIf

Return lRet


/*/{Protheus.doc} PCOAALZUsr
Verifica os usuÃ¡rios que tem acesso para efetuar alteracoes referentes Produtos do PPA

@author  Totvs
@version P12
@since   21/07/2020
/*/
Function PCOAALZUsr(nOpcao, cUser, cChave, lVerSoDir)
Local lRet := .T.

Default lVerSoDir := .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
    //criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("ALZ", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, 'NO_ACESSO',,STR0002, 1, 0)  // "Usuario sem acesso para manutenção do cadastro de Produtos do PPA."
	EndIf

Return ( lRet )


/*/{Protheus.doc} PCOAALZDEL
Valida excluso de Produtos PPA.

@author  Totvs
@version P12
@since   21/07/2020
/*/
Static Function PCOAALZDEL()

Local lRet       := .T.
Local aArea      := GetArea()
// Local cQuery     := ""
// Local cAliasTRB  := GetNextAlias()



//ESTA QUERY DEVE SER ADEQUADA PARA VERIFICAR SE JA FOI UTILIZADO NO CADASTRO DO PPA 
/*
cQuery := "SELECT max(AMY_CODUNI) UNIORC "
cQuery += " FROM " + RetSqlName("AMY")
cQuery += " WHERE "
cQuery += " AMY_FILIAL  = '" + xFilial("AMY") + "' "
cQuery += " AND AMY_CODUNI = '" + ALZ->ALZ_CODIGO + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

If (cAliasTRB)->(!Eof() .and. RTrim(UNIORC) <> '')
	lRet := .F.
EndIf
(cAliasTRB)->(dbCloseArea())
*/

If !lRet
	Help(,, 'PROD_PPA_USADO',, STR0003, 1, 0)  // "Produtos do PPA não pode ser excluida! Produtos ja vinculada ao PPA"
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PcoALZXB
Consulta padrao especifica para listar os campos da tabelas de Unid.Med.PPA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PcoALZXB()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aTabRecDes := {}

Local cCpoAnt   := &cVar
Local cCodTab   := ""
Local cRadical  := ""

If cVar == 'M->ALZ_UNICOD'
	cCodTab := M->ALZ_UNITAB
	cRadical := M->ALZ_UNIRAD
	aTabRecDes := PcoALZTbl(cCodTab, cRadical)
EndIf
If Empty(aTabRecDes)
	aAdd( aTabRecDes, { "NO_APLY", STR0004, 0})   //"Nao se Aplica"
EndIf

Define MsDialog oDlgCons Title STR0005 From 000, 000 To 450, 800 PIXEL //"Consulta de Tabelas"

	Define Font oFont Name 'Courier New' Size 0, -12		
	oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0006, STR0007 },,;    //"Codigo"##"Descrição"
	                            oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

	oGetCons:SetArray(aTabRecDes)
	oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2] } } 	                            
	oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

	@208,310 BUTTON STR0008 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	//"Confirmar"
	@208,360 BUTTON STR0009 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	//"Cancelar"

Activate MsDialog oDlgCons Centered

If nOpcA != 0 .And. aTabRecDes[nAt,3] > 0

	If nOpcA == 1 
		&cVar := aTabRecDes[nAt,1]
		&cVar += Space(nTam-Len(&cVar))
		A1H->( dbGoto(aTabRecDes[nAt,3]) )
		M->ALZ_UNIPRO := Alltrim( aTabRecDes[nAt,2] )
	EndIf

Else

		//recupera o que estava anteriormente
		&cVar := cCpoAnt
		lRet := .F.
		M->ALZ_UNIPRO := Space(Len(ALZ->ALZ_UNIPRO))
		Help(,, 'NO_TAB_UM',, STR0010, 1, 0)  // "A tabela de Unidade de Medida para Produtos do PPA não existe! Cadastrar tabela nos classificadores de Receitas/Despesas."

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PcoALZTbl
Retorna um array com codigo/descricao da tabelas de Receitas ou Despesas MCASP

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function PcoALZTbl(cCodTab, cRadical)
Local aArea := GetArea()
Local cQuery := ""
Local aRetorno := {}
Local cAliasTmp := CriaTrab(,.F.)

cQuery += " SELECT A1H_ITECHV, A1H_CHVCNT, R_E_C_N_O_ RECTAB "
cQuery += " FROM " + RetSqlName("A1H")
cQuery += " WHERE "
cQuery +=  "      A1H_FILIAL = '"+xFilial("A1H")+"' " 
cQuery += "   AND A1H_CODTAB = '"+cCodTab+"' " 
cQuery += "   AND A1H_RADCHV =  '"+cRadical+"' " 
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY A1H_ITECHV "

cQuery := ChangeQuery( cQuery )

//abre a query com mesmo alias da dimensao
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )
While (cAliasTmp)->( ! Eof() )
	aAdd( aRetorno, { (cAliasTmp)->A1H_ITECHV, (cAliasTmp)->A1H_CHVCNT, (cAliasTmp)->RECTAB } )
	(cAliasTmp)->( dbSkip() )
EndDo

(cAliasTmp)->( DBCloseArea() )

RestArea(aArea)

Return(aRetorno)