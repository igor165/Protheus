#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'JURA297.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 10/09/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := nil
Local oStrO1D    := FWFormStruct(1,'O1D')
Local bPosValid  := {|oMdl|ModelPosValid(oMdl)}
Local lWSTLegal  := JModRst()

	If lWSTLegal // Se a chamada estiver vindo do TOTVS Legal
		//Campo que indica se o registro posicionado possui anexo - criado para o TOTVS Legal
		oStrO1D:AddField( ;
			""                                                 , ; // [01] Titulo do campo
			""		                                           , ; // [02] ToolTip do campo
			"O1D__TEMANX"                                      , ; // [03] Id do Field
			"C"                                                , ; // [04] Tipo do campo
			2                                                  , ; // [05] Tamanho do campo
			0                                                  , ; // [06] Decimal do campo
			,                                                    ; // [07] Bloco de código de validação do campo
			,                                                    ; // [08] Bloco de código de validação when do campo
			,                                                    ; // [09] Lista de valores permitido do campo
			,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
			{|| JTemAnexo("O1D",O1D->O1D_CAJURI,O1D->O1D_COD)} , ; // [11] Bloco de código de inicialização do campo
			,                                                    ; // [12] Indica se trata-se de um campo chave
			,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                                  ; // [14] Indica se o campo é virtual
			,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
		oStrO1D:AddField( ;
			""                                                 , ; // [01] Titulo do campo
			""		                                           , ; // [02] ToolTip do campo
			"O1D_CCLIEN"                                      , ; // [03] Id do Field
			"C"                                                , ; // [04] Tipo do campo
			TamSx3('A1_COD')[1]                                                  , ; // [05] Tamanho do campo
			0                                                  , ; // [06] Decimal do campo
			,                                                    ; // [07] Bloco de código de validação do campo
			,                                                    ; // [08] Bloco de código de validação when do campo
			,                                                    ; // [09] Lista de valores permitido do campo
			,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
			{|| IF(!INCLUI,Posicione("NSZ",1,xFilial("NSZ")+O1D->O1D_CAJURI,"NSZ_CCLIEN"), '') } , ; // [11] Bloco de código de inicialização do campo
			,                                                    ; // [12] Indica se trata-se de um campo chave
			,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                                  ; // [14] Indica se o campo é virtual
			,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
		oStrO1D:AddField( ;
			""                                                 , ; // [01] Titulo do campo
			""		                                           , ; // [02] ToolTip do campo
			"O1D_LCLIEN"                                      , ; // [03] Id do Field
			"C"                                                , ; // [04] Tipo do campo
			TamSx3('A1_COD')[1]                                                  , ; // [05] Tamanho do campo
			0                                                  , ; // [06] Decimal do campo
			,                                                    ; // [07] Bloco de código de validação do campo
			,                                                    ; // [08] Bloco de código de validação when do campo
			,                                                    ; // [09] Lista de valores permitido do campo
			,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
			{|| IF(!INCLUI,Posicione("NSZ",1,xFilial("NSZ")+O1D->O1D_CAJURI,"NSZ_LCLIEN"), '') } , ; // [11] Bloco de código de inicialização do campo
			,                                                    ; // [12] Indica se trata-se de um campo chave
			,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                                  ; // [14] Indica se o campo é virtual
			,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
		oStrO1D:AddField( ;
			""                                                 , ; // [01] Titulo do campo
			""		                                           , ; // [02] ToolTip do campo
			"O1D_DCLIEN"                                      , ; // [03] Id do Field
			"C"                                                , ; // [04] Tipo do campo
			TamSx3('A1_NOME')[1]                                                  , ; // [05] Tamanho do campo
			0                                                  , ; // [06] Decimal do campo
			,                                                    ; // [07] Bloco de código de validação do campo
			,                                                    ; // [08] Bloco de código de validação when do campo
			,                                                    ; // [09] Lista de valores permitido do campo
			,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
			{|oMd| IF(!INCLUI,Posicione("SA1",1,xFilial("SA1")+oMd:GetValue('O1D_CCLIEN')+oMd:GetValue('O1D_LCLIEN'),"A1_NOME"), '') } , ; // [11] Bloco de código de inicialização do campo
			,                                                    ; // [12] Indica se trata-se de um campo chave
			,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                                  ; // [14] Indica se o campo é virtual
			,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
	Endif

	oModel := MPFormModel():New('JURA297', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('O1DMASTER',/*cOwner*/,oStrO1D,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001) //'Ato societário'
	oModel:GetModel('O1DMASTER'):SetDescription(STR0001) //'Ato societário' 

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Função responsavel pela pós validação do modelo
@since 10/09/2021
@param oModel - Modelo de dados da JURA297
@return lRet - Indica se foi validado com sucesso
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet := .T.

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		lRet := JurExcAnex('O1D',oModel:GetValue("O1DMASTER","O1D_COD"))
	EndIf

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J297PChave(cPchave, cFilter)
Monta o filtro para pesquisar atos societarios por palavra chave.

@param cPchave - Palavra que o usuário deseja filtrar.
@param cFilter - Filtros aplicados na pesquisa

@since 15/10/2020
/*/
//-------------------------------------------------------------------
Function J297PChave(cPchave, cFilter)
Local aArea       := GetArea()
Local cAlias      := GetNextAlias()
Local cCampo      := ''
Local cQry        := ""
Local cFilPalavra := " O1D_FILIAL || O1D_COD IN ('0'"

	cCampo := "O1D_LOCALI||O1D_RESUMO||COALESCE(O1D_TEOR, '')"

	cQry := "SELECT O1D_FILIAL, O1D_COD "
	cQry +=  " FROM " + RetSqlName('O1D')
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	
	If !Empty(cFilter)
		cQry += " AND " + cFilter
	EndIf

	cQry := ChangeQuery(cQry)
	cQry += " AND " + JA020QryFil(cPchave, cCampo)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), cAlias, .F., .F. )
		While (cAlias)->(!Eof())
			cFilPalavra += ",'" + (cAlias)->O1D_FILIAL + (cAlias)->O1D_COD + "'" 
			(cAlias)->( dbSkip() )
		End	
	(cAlias)->( DbCloseArea() )

	cFilPalavra += ") "

	RestArea(aArea)
Return cFilPalavra
