#INCLUDE "AGRA800.CH"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

//--------------------------------------------------------------
/*{Protheus.doc} AGRA800
Cadastro de Culturas

@author Cleber Maldonado
@since 14/01/2013
**/
//--------------------------------------------------------------
Function AGRA800()
	Private cAlias  := "NP3"
	Private oBrowse := BrowseDef()
// Ativa browser.
oBrowse:Activate()

Return
//--------------------------------------------------------------------------
/*{Protheus.doc} BrowseDef
Definições do Browse

@author Felipe Raposo
@since 09/01/2019
**/
//--------------------------------------------------------------------------
Static Function BrowseDef()

Local oBrowse := FwMBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescripton(FwX2Nome(cAlias))

Return oBrowse

//--------------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de Culturas

@author Cleber Maldonado
@since 14/01/2013
**/
//--------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruNP3 	:= FwFormStruct( 1, "NP3" )//Cadastro de Culturas

	// Instancia o modelo de dados
	oModel := MpFormModel():New( 'AGRA800')
	oModel:SetVldActivate({|oModel| ValidPre(oModel)})
	
// NP3MASTER é o identificador (ID) dado ao componente.
	oModel:AddFields("NP3MASTER",Nil,oStruNP3)

// Adicionamos a descrição dos componentes do modelo de dados: NP3MASTER
oModel:GetModel('NP3MASTER'):SetDescription(FwX2Nome("NP3"))
Return (oModel)

//----------------------------------------------------------------
/*{Protheus.doc} ViewDef
@author Cleber Maldonado
@since 14/01/2013
**/
//----------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA800" )
	Local oStruNPE  := FwFormStruct( 2, "NP3" ) // Amostra do Lote de Sementes
               
	// Instancia a View
	oView := FwFormView():New()

	// Seta o modelo de dados
	oView:SetModel( oModel )
	oModel:SetVldActivate({|oModel| ValidPre(oModel)})

	// Define que a view será fechada após a gravação dos dados no OK.
	oView:bCloseOnOk := {|| .T.}
	oView:ShowUpdateMsg(.F.)

	// Adiciona os atributos da estrutura da view
	oView:AddField( 'VIEW_NP3', oStruNPE, 'NP3MASTER' )

	// Monta o box horizontal
	oView:CreateHorizontalBox( 'TOTAL', 100 )

	// Seta Owner da Interface
	oView:SetOwnerView( 'VIEW_NP3', 'TOTAL' )
	
Return oView

//----------------------------------------------------------------
/*{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de Culturas

@author Cleber Maldonado
@since 14/01/2013
**/
//----------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title OemToAnsi(STR0004)		Action 'VIEWDEF.AGRA800' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0005)		Action 'VIEWDEF.AGRA800' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0006)		Action 'VIEWDEF.AGRA800' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0007)		Action 'VIEWDEF.AGRA800' OPERATION 5 ACCESS 0
Return( aRotina )

/*{Protheus.doc} ValidPre
@author  Felipe Raposo
@version P12.1.17
@since   04/10/2018
*/
Static Function ValidPre(oModel)

Local lRet       := .T.
Local nOper      := oModel:getOperation()
Local cQuery     := ""
Local cAliasSQL  := ""

// Se for exclusão de registro, verifica se não está em uso por outra tabela.
If nOper == MODEL_OPERATION_DELETE
	// Valida se o registro não foi usado.
	cQuery := "select min(NCR.R_E_C_N_O_) NCRRecNo " + CRLF
	cQuery += "from " + RetSqlName('NCR') + " NCR " + CRLF
	cQuery += "where NCR.D_E_L_E_T_ = '' " + CRLF
	cQuery += "and NCR.NCR_FILIAL = '" + xFilial("NCR") + "' " + CRLF
	cQuery += "and NCR.NCR_CULTUR = '" + NP3->NP3_CODIGO + "' " + CRLF
	cAliasSQL := MPSysOpenQuery(cQuery)

	// Verifica se encontrou algum registro.
	If (cAliasSQL)->NCRRecNo > 0
		lRet := .F.
	Endif
	(cAliasSQL)->(dbCloseArea())

	If lRet
		// Valida se o registro não foi usado.
		cQuery := "select min(NCM.R_E_C_N_O_) NCMRecNo " + CRLF
		cQuery += "from " + RetSqlName('NCM') + " NCM " + CRLF
		cQuery += "where NCM.D_E_L_E_T_ = '' " + CRLF
		cQuery += "and NCM.NCM_FILIAL = '" + xFilial("NCM") + "' " + CRLF
		cQuery += "and NCM.NCM_ALIAS  = 'NP3' " + CRLF
		cQuery += "and NCM.NCM_FILREG = '" + NP3->NP3_FILIAL + "' " + CRLF
		cQuery += "and NCM.NCM_CODREG = '" + NP3->NP3_CODIGO + "' " + CRLF
		cAliasSQL := MPSysOpenQuery(cQuery)

		// Verifica se encontrou algum registro.
		If (cAliasSQL)->NCMRecNo > 0
			lRet := .F.
		Endif
		(cAliasSQL)->(dbCloseArea())
	Endif

	If lRet
		// Valida se o registro não foi usado.
		cQuery := "select min(NCM.R_E_C_N_O_) NCMRecNo " + CRLF
		cQuery += "from " + RetSqlName('NCM') + " NCM " + CRLF
		cQuery += "where NCM.D_E_L_E_T_ = '' " + CRLF
		cQuery += "and NCM.NCM_FILIAL = '" + xFilial("NCM") + "' " + CRLF
		cQuery += "and NCM.NCM_ALIAS  = 'NCD' " + CRLF
		cQuery += "and NCM.NCM_CULTUR = '" + NP3->NP3_CODIGO + "' " + CRLF
		cAliasSQL := MPSysOpenQuery(cQuery)

		// Verifica se encontrou algum registro.
		If (cAliasSQL)->NCMRecNo > 0
			lRet := .F.
		Endif
		(cAliasSQL)->(dbCloseArea())
	Endif

	If lRet
		// Valida se o registro não foi usado.
		cQuery := "select min(NCJ.R_E_C_N_O_) NCJRecNo " + CRLF
		cQuery += "from " + RetSqlName('NCJ') + " NCJ " + CRLF
		cQuery += "where NCJ.D_E_L_E_T_ = '' " + CRLF
		cQuery += "and NCJ.NCJ_FILIAL = '" + xFilial("NCJ") + "' " + CRLF
		cQuery += "and NCJ.NCJ_CULTUR = '" + NP3->NP3_CODIGO + "' " + CRLF
		cAliasSQL := MPSysOpenQuery(cQuery)

		// Verifica se encontrou algum registro.
		If (cAliasSQL)->NCJRecNo > 0
			lRet := .F.
		Endif
		(cAliasSQL)->(dbCloseArea())
	Endif

	If !lRet
		Help(" ", 1, "REGUSADO")
	Endif
EndIf

Return lRet

/*{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Felipe Raposo
@version P12
@since   29/08/2018
*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return AGRI800(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
