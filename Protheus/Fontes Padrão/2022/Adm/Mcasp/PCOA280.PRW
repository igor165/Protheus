#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PCOA280.ch'
//
Function PCOA280() 

	Local oBrowse  

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("AL0")                                          
	oBrowse:SetDescription( STR0001 )  //"Cadastro de "Programas PPA""
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de Dados

@author gustavo.campos

@since 27/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStruct	:= FWFormStruct(1,'AL0')

	oModel := MPFormModel():New('PCOA280',/*PreValidacao*/,{ |oModel|PCO280TOK(oModel)}/*PosValidacao*/)

	oModel:SetDescription( STR0001 )  //""Programas PPA""

	oModel:addFields('MODELAL0',,oStruct)
	oModel:SetPrimaryKey({ 'AL0_FILIAL', 'AL0_CODIGO'})

	oModel:SetVldActivate( {|oModel|ValidPreM(oModel)} )
	oModel:getModel('MODELAL0'):SetOnlyQuery(.F.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de interface

@author

@since 27/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local oView 		:= FWFormView():New()
	Local oModel		:= ModelDef()
	Local oStruct		:= FWFormStruct(2, 'AL0') 
	
	oView:SetModel(oModel)

	oView:AddField('MASTER_AL0' , oStruct,'MODELAL0' )

	oView:EnableTitleView('MASTER_AL0' , STR0001 )  //""Programas PPA""

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Funcao para criacao do menu 

@author gustavo.campos
@since 27/07/2020
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu('PCOA280')

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO280TOK()
Tudo ok
@author gustavo.campos
@since 21/07/2020
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Static Function PCO280TOK(oModel)

	Local lRet 				:= .T.
	Local nOpc				:= oModel:GetOperation()
	Local aAreaAL0			:= AL0->(Getarea())
	// Local oMdlAL0			:= oModel:GetModel('MODELAL0')

	Default oModel := Nil
	
	If lRet .and. (nOpc == 5 .Or. nOpc == 4)
		lRet := PCOA280VPR()
	Endif

	RestArea( aAreaAL0 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA280VPR
Valida se o registro pode ser excluido ou alterado.

@author gustavo.campos
@since 22/07/2020
@version P12

@return  logico, indica se o cadastro pode ser excluido com base nas movimentacoes do PPA
/*/
//-------------------------------------------------------------------
Function PCOA280VPR()

	Local lRet 			:= .T.
	Local aSaveArea 	:= Getarea()
	// Local cQuery		:= ""
	// Local cAliasTRB  	:= GetNextAlias()

	//Sera feito corretamente quando tivermos a tabela e cadastro de PPA criado para validação.
	// DBSelectArea("AL0")
	// ///Fazer query quando tiver a rotina que faz os movimentos do PPA atrelado aos programas.
	// cQuery := "SELECT COUNT(AL0_CODIGO) UNICONT "
	// cQuery += "FROM " + RetSqlName("ALD") + " "
	// cQuery += "WHERE "
	// cQuery += "ALD_FILIAL = '" +XFilial("ALD")  + "' "
	// cQuery += "AND ?MODIFICAR? = '" + cCodigo  + "' "
	// cQuery += "AND D_E_L_E_T_ = '' "
	// cQuery := ChangeQuery(cQuery)

	// dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

	// If (cAliasTRB)->(!Eof() .and. UNICONT > 0)
	// 	lRet := .F.
	// EndIf

	// (cAliasTRB)->(dbCloseArea())

	If !lRet 
		Help("",1,STR0005,, STR0004, 1, 0 ) //"Não permitido exclusao/alteração pois existem vinculos com algum PPA."
	Endif
	
	RestArea(aSaveArea)

Return lRet

/*/{Protheus.doc} ValidPreM
Pre-validacao do modelo
@author  Totvs
@version 12.1.27
@since   21/07/2020
/*/
Static Function ValidPreM(oModel)

	Local lRet       	:= .T.
	Local cUser      	:= RetCodUsr()
	Local aSaveArea		:= Getarea()
	Local nOper      	:= oModel:GetOperation()
	Local cAlias		:= Alias()

	DBSelectArea(cAlias)
	
	If nOper != 1

		If nOper == 2 
			lRet := PCOAAL0Usr( 1, cUser, AL0->AL0_CODIGO )

		ElseIf nOper == MODEL_OPERATION_UPDATE
			lRet := PCOAAL0Usr( 2, cUser, AL0->AL0_CODIGO )

		ElseIf nOper == MODEL_OPERATION_INSERT
			lRet := PCOAAL0Usr( 3, cUser, "" , .T. )

		ElseIf nOper == MODEL_OPERATION_DELETE
			lRet := PCOAAL0Usr( 3, cUser, AL0->AL0_CODIGO )

			If lRet
				lRet := PCOA280VPR()
			EndIf

		EndIf

	EndIf

	RestArea( aSaveArea )

Return lRet


/*/{Protheus.doc} PCOAAL0Usr
Verifica os usuarios que tem acesso para efetuar alteracoes referentes Produtos do PPA

@author  Totvs
@version P12
@since   21/07/2020
/*/
Function PCOAAL0Usr(nOpcao, cUser, cChave, lVerSoDir)

	Local lRet 			:= .T.

	Default lVerSoDir 	:= .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
	//criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("AL0", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, STR0003,, STR0002, 1, 0)  // "	"
	EndIf

Return ( lRet )