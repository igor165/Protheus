#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PCOA285.ch'
//
Function PCOA285() 

	Local oBrowse  

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("AMN")                                          
	oBrowse:SetDescription( STR0001 )  //"Cadastro de "Indicadores PPA""
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de Dados

@author gustavo.campos

@since 04/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStruct	:= FWFormStruct(1,'AMN')

	oModel := MPFormModel():New('PCOA285',/*PreValidacao*/,{ |oModel|PCO285TOK(oModel)}/*PosValidacao*/)

	oModel:SetDescription( STR0001 )  //""Indicadores PPA""

	oModel:addFields('MODELAMN',,oStruct)
	oModel:SetPrimaryKey({ 'AMN_FILIAL', 'AMN_CODIGO'})

	oModel:SetVldActivate( {|oModel|ValidPreM(oModel)} )
	oModel:getModel('MODELAMN'):SetOnlyQuery(.F.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de interface

@author

@since 04/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local oView 		:= FWFormView():New()
	Local oModel		:= ModelDef()
	Local oStruct		:= FWFormStruct(2, 'AMN') 
	
	oView:SetModel(oModel)

	oView:AddField('MASTER_AMN' , oStruct,'MODELAMN' )

	oView:EnableTitleView('MASTER_AMN' , STR0001 )  //""Indicadores PPA""

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Funcao para criacao do menu 

@author gustavo.campos
@since 04/08/2020
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu('PCOA285')

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO285TOK()
Tudo ok
@author gustavo.campos
@since 21/07/2020
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Static Function PCO285TOK(oModel)

	Local lRet 				:= .T.
	Local nOpc				:= oModel:GetOperation()
	Local aAreaAMN			:= AMN->(Getarea())
	// Local oMdlAMN			:= oModel:GetModel('MODELAMN')

	Default oModel := Nil

	If lRet .and. (nOpc == 5 .Or. nOpc == 4)
		lRet := PCOA285VIN()
	Endif

	RestArea( aAreaAMN )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA285VIN
Valida se o registro pode ser excluido ou alterado.

@author gustavo.campos
@since 22/07/2020
@version P12

@return  logico, indica se o cadastro pode ser excluido com base nas movimentacoes do PPA
/*/
//-------------------------------------------------------------------
Function PCOA285VIN()

	Local lRet 			:= .T.
	Local aSaveArea 	:= Getarea()
	// Local cQuery		:= ""
	// Local cAliasTRB  	:= GetNextAlias()

	//Sera feito corretamente quando tivermos a tabela e cadastro de PPA criado para validação.
	// DBSelectArea("AMN")
	// ///Fazer query quando tiver a rotina que faz os movimentos do PPA atrelado aos Indicadores.
	// cQuery := "SELECT COUNT(AMN_CODIGO) UNICONT "
	// cQuery += "FROM " + RetSqlName("AMN") + " "
	// cQuery += "WHERE "
	// cQuery += "AMN_FILIAL = '" +XFilial("AMN")  + "' "
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
			lRet := PCOAAMNUsr( 1, cUser, AMN->AMN_CODIGO )

		ElseIf nOper == MODEL_OPERATION_UPDATE
			lRet := PCOAAMNUsr( 2, cUser, AMN->AMN_CODIGO )

		ElseIf nOper == MODEL_OPERATION_INSERT
			lRet := PCOAAMNUsr( 3, cUser, "" , .T. )

		ElseIf nOper == MODEL_OPERATION_DELETE
			lRet := PCOAAMNUsr( 3, cUser, AMN->AMN_CODIGO )

			If lRet
				lRet := PCOA285VIN()
			EndIf

		EndIf

	EndIf

	RestArea( aSaveArea )

Return lRet


/*/{Protheus.doc} PCOAAMNUsr
Verifica os usuarios que tem acesso para efetuar alteracoes referentes Produtos do PPA

@author  Totvs
@version P12
@since   21/07/2020
/*/
Function PCOAAMNUsr(nOpcao, cUser, cChave, lVerSoDir)

	Local lRet 			:= .T.

	Default lVerSoDir 	:= .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
	//criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("AMN", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, STR0003,, STR0002, 1, 0)  // "	"
	EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOAMNXB
Consulta padrao especifica para listar os campos da tabelas de Unid.Med.PPA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOAMNXB()

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

	If cVar == 'M->AMN_UM'
		cCodTab := M->AMN_UNITAB
		cRadical := M->AMN_UNIRAD
		aTabRecDes := PcoAMNTbl(cCodTab, cRadical)
	Endif
	If Empty(aTabRecDes)
		aAdd( aTabRecDes, { STR0013, STR0014, 0})   //"Nao se Aplica"
	EndIf

	Define MsDialog oDlgCons Title STR0006 From 000, 000 To 450, 800 PIXEL //"Consulta de Tabelas"

		Define Font oFont Name 'Courier New' Size 0, -12
		oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0007, STR0008 },,;    //"Codigo"##"Descri÷óo"
									oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

		oGetCons:SetArray(aTabRecDes)
		oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2] } } 	                            
		oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}
		
		@208,310 BUTTON STR0009 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	//"Confirmar"
		@208,360 BUTTON STR0010 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	//"Cancelar"

	Activate MsDialog oDlgCons Centered 

	If nOpcA != 0 .And. aTabRecDes[nAt,3] > 0

		If nOpcA == 1 
			&cVar := aTabRecDes[nAt,1]
			&cVar += Space(nTam-Len(&cVar))
			A1H->( dbGoto(aTabRecDes[nAt,3]) )
			M->AMN_UNDESC := Alltrim( aTabRecDes[nAt,2] )
		Endif

	Else
		//recupera o que estava anteriormente
		&cVar := cCpoAnt
		lRet := .F.
		M->AMN_UNDESC := Space(Len(AMN->AMN_UNDESC))
		Help(,, STR0011,, STR0012, 1, 0)  // "A tabela de Unidade de Medida para Produtos do PPA n?o existe! Cadastrar tabela nos classificadores de Receitas/Despesas."
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PcoAMNTbl
Retorna um array com codigo/descricao da tabelas de Receitas ou Despesas MCASP

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function PcoAMNTbl(cCodTab, cRadical)
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

	//Abre a query com mesmo alias da dimensao
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )

	While (cAliasTmp)->( ! Eof() )
		aAdd( aRetorno, { (cAliasTmp)->A1H_ITECHV, (cAliasTmp)->A1H_CHVCNT, (cAliasTmp)->RECTAB } )
		(cAliasTmp)->( dbSkip() )
	EndDo

	(cAliasTmp)->( DBCloseArea() )

	RestArea(aArea)

Return(aRetorno)