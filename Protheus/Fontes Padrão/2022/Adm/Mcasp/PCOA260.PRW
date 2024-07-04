#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PCOA260.ch'
//
Function PCOA260() 

	Local oBrowse  

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ALD")                                          
	oBrowse:SetDescription( STR0001 )  //"Cadastro de Unidade Gestora"
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de Dados

@author gustavo.campos

@since 20/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStruct	:= FWFormStruct(1,'ALD')

	oModel := MPFormModel():New('PCOA260',/*PreValidacao*/,{ |oModel|PCO260TOK(oModel)}/*PosValidacao*/)

	oModel:SetDescription( STR0001 )  //"Unidade Gestora"

	oModel:addFields('MODELALD',,oStruct)
	oModel:SetPrimaryKey({ 'ALD_FILIAL', 'ALD_CODIGO'})

	oModel:SetVldActivate( {|oModel|ValidPreM(oModel)} )
	oModel:getModel('MODELALD'):SetOnlyQuery(.F.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de interface

@author

@since 20/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local oView 		:= FWFormView():New()
	Local oModel		:= ModelDef()
	Local oStruct		:= FWFormStruct(2, 'ALD') 
	
	oView:SetModel(oModel)

	oView:AddField('MASTER_ALD' , oStruct,'MODELALD' )

	oView:EnableTitleView('MASTER_ALD' , STR0001 )  //"Unidade Gestora"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Funcao para criacao do menu 

@author gustavo.campos
@since 20/07/2020
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu('PCOA260')

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO260TOK()
Tudo ok
@author gustavo.campos
@since 21/07/2020
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Static Function PCO260TOK(oModel)

	Local lRet 				:= .T.
	Local nOpc				:= oModel:GetOperation()
	Local aAreaALD			:= ALD->(Getarea())
	Local oMdlALD			:= oModel:GetModel('MODELALD')
	Local nX
	Local cCodAux

	Default oModel := Nil

	If nOpc == 3 .And. ALD->(dbSeek(xFilial("ALD")+oMdlALD:GetValue('ALD_CODIGO'))) /// OK
		lRet := .F.
		Help("",1,STR0009,, STR0002, 1, 0 ) // "Codigo de Unidade já cadastrado"
	EndIf

	//na inclusao validar se 6 digitos do codigo estao preenchidos com digitos numericos
	If nOpc == 3 .And. lRet
		cCodAux := Alltrim(oMdlALD:GetValue('ALD_CODIGO'))
		For nX := 1 TO Len(cCodAux) 
			If !( Subs(cCodAux, nX, 1) $ "0123456789" )
				lRet := .F.
				Exit
			EndIf
		Next
		If !lRet
			Help("",1,"COD_NOTNUM",, STR0018, 1, 0 ) // "Codigo deve conter somente digitos numericos - Padrao MCASP. Verifique!"
		EndIf
	EndIf

	//na inclusao validar se 6 digitos do codigo estao preenchidos
	If nOpc == 3 .And. lRet .And. Len(Alltrim(oMdlALD:GetValue('ALD_CODIGO'))) != 6 //inclusao
		lRet := .F.
		Help("",1,"COD_INVL1",, STR0019, 1, 0 ) // "Tamanho do codigo deve ser de 6 digitos - Padrao MCASP. Verifique!"
	EndIf

	//validar se unidade superior esta vazio....caso esteja deve possuir 4 digitos zeros a direita
	If nOpc == 3 .And. lRet .And. Len(Alltrim(oMdlALD:GetValue('ALD_GESSUP'))) == 0 .And. Right(oMdlALD:GetValue('ALD_CODIGO'),4) != "0000" //inclusao
		lRet := .F.
		Help("",1,"COD_INVL2",, STR0020, 1, 0 ) // "Se a Unidade superior esta vazio o codigo deve ter 4 zeros a direita - Padrao MCASP. Verifique!"
	EndIf

	//validar se unidade superior esta preenchido mas eh uma tipo sintetica as 2 ultimas posicoes deve ser 00
	If nOpc == 3 .And. lRet .And. oMdlALD:GetValue('ALD_TPUNID') == "1" .And. Len(Alltrim(oMdlALD:GetValue('ALD_GESSUP'))) != 0 .And. Right(oMdlALD:GetValue('ALD_CODIGO'),2) != "00" //inclusao
		lRet := .F.
		Help("",1,"COD_INVL3",, STR0021, 1, 0 ) // "Se Unidade for sintetica e codigo da superior esta preenchido os ultimos 2 digitos deve ser 00 - Padrao MCASP. Verifique!"
	EndIf

    //valida se unidade eh analitica e se codigo da superior esta preenchido para inclusao e alteraçao
	If  (lRet .And. (nOpc == 3 .Or. nOpc == 4) ) .And. oMdlALD:GetValue('ALD_TPUNID') == "2" .And. Empty(oMdlALD:GetValue('ALD_GESSUP'))
		lRet := .F.
		Help("",1,STR0010,, STR0003, 1, 0 ) // "Tipo da Unidade(Analitico) não permite que seja incluído sem uma unidade superior"
	Endif

	If (lRet .And. (nOpc == 5 .Or. nOpc == 4))
		lRet := PCOA260VUN()
	Endif

	RestArea( aAreaALD )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO260GSup
Valida Unidade Superior na inclusao da unidade orcamentaria.
X3_VALID do campo ALD_GESSUP.

@author Totvs
@since 21/07/2020
@version P12

@return  logico, indica se a unidade superior é valida
/*/
//-------------------------------------------------------------------
Function PCO260GSup()

	Local aSaveArea	:= GetArea()
	Local lRet		:= .T.
	Local cCodSup	:= FWFldGet("ALD_GESSUP")
	Local cCodigo	:= FWFldGet("ALD_CODIGO")

	DBSelectArea("ALD")
	DBSetOrder(1)

	Do Case
		Case cCodigo == cCodSup
			lRet := .F.
			Help("",1,STR0011,, STR0004, 1, 0 ) // "Codigo da unidade e Codigo da unidade Superior não podem ser iguais"
		Case !MsSeek(xFilial()+cCodSup)
			lRet := .F.
			Help("",1,STR0012,, STR0005, 1, 0 ) // "A Unidade digitada no campo (ALD_GESSUP) deve existir no cadastro"
		Case dbSeek(xFilial() + cCodSup) .And. ALD->ALD_TPUNID == "2"
			lRet := .F.
			Help("",1,STR0013,, STR0006, 1, 0 ) // "Não permitido vínculo de unidades analítica com analíticas"
	EndCase

	RestArea(aSaveArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA260VUN
Valida se o registro pode ser excluido ou alterado.

@author gustavo.campos
@since 22/07/2020
@version P12

@return  logico, indica se o cadastro pode ser excluido com base nas movimentacoes do PPA
/*/
//-------------------------------------------------------------------
Function PCOA260VUN()

	Local lRet       := .T.
	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cAliasTRB  := GetNextAlias()

	DBSelectArea("ALD")
	DBSetOrder(1)

	// ///Fazer query quando tiver a rotina que faz os movimentos do PPA atrelado as unidades.
	cQuery := "SELECT DISTINCT AK4_UNGEST "
	cQuery += " FROM " + RetSqlName("AK4")
	cQuery += " WHERE "
	cQuery += " AK4_FILIAL  = '" + xFilial("AK4") + "' "
	cQuery += " AND AK4_UNGEST = '" + ALD->ALD_CODIGO + "' "
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

	If (cAliasTRB)->( !Eof() )
		lRet := .F.
	EndIf
	(cAliasTRB)->(dbCloseArea())

	If !lRet 
		Help("",1,STR0014,, STR0007, 1, 0 ) //"Não permitido exclusao pois existem movimentos PPA relacionados a esta Gestao."
	Endif
	RestArea(aArea)

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
			lRet := PCOAALDUsr( 1, cUser, ALD->ALD_CODIGO )

		ElseIf nOper == MODEL_OPERATION_UPDATE
			lRet := PCOAALDUsr( 2, cUser, ALD->ALD_CODIGO )

		ElseIf nOper == MODEL_OPERATION_INSERT
			lRet := PCOAALDUsr( 3, cUser, "" , .T. )

		ElseIf nOper == MODEL_OPERATION_DELETE
			lRet := PCOAALDUsr( 3, cUser, ALD->ALD_CODIGO )

			If lRet
				lRet := PCOA260VUN()
			EndIf

		EndIf

	EndIf

	RestArea( aSaveArea )

Return lRet


/*/{Protheus.doc} PCOAALDUsr
Verifica os usuarios que tem acesso para efetuar alteracoes referentes Produtos do PPA

@author  Totvs
@version P12
@since   21/07/2020
/*/
Function PCOAALDUsr(nOpcao, cUser, cChave, lVerSoDir)

	Local lRet 			:= .T.

	Default lVerSoDir 	:= .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
	//criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave é em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("ALD", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, STR0015,, STR0008, 1, 0)  // "Usuario sem acesso para manutenção do cadastro de Unidades Gestoras."
	EndIf

Return ( lRet )


/*/{Protheus.doc} P260VLDTIP
Verifica se existem unidades sinteticas amarradas a analiticas ou sinteticas com sinteticas
Se True pode alterar normal, se não exibe help
@author  Totvs
@version P12
@since   21/07/2020
/*/
Function P260VLDTIP()

	Local lRet 		:= .T.
	Local cCodigo	:= FWFldGet("ALD_CODIGO")
	Local cQuery	:= ""
	Local cAliasTRB  := GetNextAlias()
	Local oModel	:= FWModelActive()

	If !oModel:IsCopy()
		cQuery := "SELECT COUNT(ALD_CODIGO) UNICONT "
		cQuery += "FROM " + RetSqlName("ALD") + " "
		cQuery += "WHERE "
		cQuery += "ALD_FILIAL = '" +XFilial("ALD")  + "' "
		cQuery += "AND ALD_GESSUP = '" + cCodigo  + "' "
		cQuery += "AND D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

		If (cAliasTRB)->(!Eof() .and. UNICONT > 0)
			lRet := .F.
		EndIf

		(cAliasTRB)->(dbCloseArea())
	Endif

	If !lRet
		Help("",1,STR0017,, STR0016, 1, 0 )	//"Unidade é superior de outras unidades analitícas ou sintéticas, não é possivel alterar seu tipo."
	Endif

return lRet