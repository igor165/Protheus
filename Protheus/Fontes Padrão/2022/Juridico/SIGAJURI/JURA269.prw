#INCLUDE "JURA269.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA269
TOTV Legal - Favoritos

@since 24/06/2019
/*/
//-------------------------------------------------------------------
Function JURA269()

Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0001) //-- Favoritos
	oBrowse:SetAlias( "O0V" )
	oBrowse:SetMenuDef( 'JURA269' )
	oBrowse:SetLocate()
	oBrowse:Activate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura

@since 24/06/2019
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA269", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA269", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA269", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA269", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA269", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Processos Favoritos.

@since 24/06/2019
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructO0V := FWFormStruct( 1, "O0V" )

	oModel:= MPFormModel():New( "JURA269", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

	oModel:SetDescription( STR0008 ) //-- "Cadastro de Favoritos"

	oModel:AddFields( "O0VMASTER", NIL, oStructO0V, /*Pre-Validacao*/, /*Pos-Validacao*/ )

	oModel:GetModel( "O0VMASTER" ):SetDescription( STR0008 ) //-- "Cadastro de Favoritos"

	JurSetRules( oModel, 'O0VMASTER',, 'O0V' )

	oModel:SetPrimaryKey( { "O0V_FILCAJ", "O0V_CAJURI", "O0V_USER"  }  )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Favoritos.

@since 24/06/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA269" )
Local oStructO0V := FWFormStruct( 2, "O0V" )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "O0V_VIEW", oStructO0V, "O0VMASTER"  )

	oView:CreateHorizontalBox( "SUPERIOR", 100 )
	oView:SetDescription( STR0008 ) //-- "Cadastro de Favoritos"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J269QryFav()
Função retorna Polos Ativo e Passivo Concatenados, Ato Processual e
Data do útimo Andamento para a funcionalidade de Favoritos

@param   cFilCaj - Filial do Assunto Juridico
@param   cCajuri - Assunto Juridico
@return  aRet    - Dados filtrados na query
		 aRet[1] - Filial Cajuri
		 aRet[2] - Assunto Juridico / Cajuri
		 aRet[3] - Polo Ativo
		 aRet[4] - Polo Passivo
		 aRet[5] - Solicitação
		 aRet[6] - Código Fluig
		 aRet[7] - Razão Social
		 aRet[8] - Nome da marca
		 aRet[9] - Situação da marca

@since 25/06/2019
/*/
//-------------------------------------------------------------------
Function J269QryFav( cFilCaj, cCajuri )
Local cQry    := ""
Local aRet    := {}
Local cAlias  := GetNextAlias()

	cQry := " SELECT NSZ_FILIAL, "
	cQry += 	   " NSZ_COD, "
	cQry += 	   " NSZ_PATIVO, "
	cQry += 	   " NSZ_PPASSI, "
	cQry +=        " NYA.NYA_DESC, "
	cQry +=        " NSZ_CODWF, "
	cQry +=        " A1_NOME, "
	cQry +=        " NSZ_NOMEMA, "
	cQry +=        " NY7_DESC "
	cQry += " FROM " + RetSqlName("NSZ") + " NSZ "
	cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQry +=         " ON " + JQryFilial("NSZ","SA1","NSZ","SA1") + " "
	cQry +=         " AND (SA1.A1_COD = NSZ.NSZ_CCLIEN) "
	cQry +=         " AND (SA1.A1_LOJA = NSZ.NSZ_LCLIEN) "
	cQry +=         " AND (SA1.D_E_L_E_T_ = ' ') "
	cQry += " LEFT JOIN " + RetSqlName("NYA") + " NYA "
	cQry +=			"ON NYA.NYA_FILIAL = '"+xFilial('NYA')+"' "
	cQry +=			"AND NYA.NYA_COD = NSZ_CTPSOL "
	cQry +=			"AND NYA.D_E_L_E_T_ = ' ' "
	cQry += " LEFT JOIN " + RetSqlName("NY7") + " NY7 "
	cQry +=			"ON NY7.NY7_FILIAL = '" + xFilial('NY7') + "' "
	cQry +=			"AND NY7.NY7_COD = NSZ.NSZ_CSITMA "
	cQry +=			"AND NY7.D_E_L_E_T_ = ' ' "
	cQry += " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cQry +=   " AND NSZ_FILIAL = '" + cFilCaj + "' "
	cQry +=   " AND NSZ_COD = '" + cCajuri + "' "

	cQry := ChangeQuery(cQry)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQry ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )

		aAdd(aRet, (cAlias)->NSZ_FILIAL)    //-- Filial do Assunto Juridico
		aAdd(aRet, (cAlias)->NSZ_COD)       //-- Código do Assunto Juridico
		aAdd(aRet, (cAlias)->NSZ_PATIVO)    //-- Polo Ativo
		aAdd(aRet, (cAlias)->NSZ_PPASSI)    //-- Polo Passivo
		aAdd(aRet, (cAlias)->NYA_DESC)      //-- Solicitação
		aAdd(aRet, (cAlias)->NSZ_CODWF)     //-- Código Fluig
		aAdd(aRet, (cAlias)->A1_NOME)       //-- Razão Social
		aAdd(aRet, (cAlias)->NSZ_NOMEMA)    //-- Nome da Marca
		aAdd(aRet, (cAlias)->NY7_DESC)      //-- Situação da marca

		(cAlias)->( dbSkip() )
	End
	(cAlias)->( DbCloseArea() )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J269RFav
Verifica qual informação deve retornar em cada campo.

aRet - Dados filtrados pela função J269QryFav()
	 aRet[1] - Filial Cajuri
	 aRet[2] - Assunto Juridico / Cajuri
	 aRet[3] - Polo Ativo
	 aRet[4] - Polo Passivo
	 aRet[5] - Ato Processual
	 aRet[6] - Data do último Andamento
@return cConteud - Conteúdo string para os campos de Partes, Movimentação
		dData    - Conteúdo date para o campo de Data do ultimo andamento

@since 25/06/2019
/*/
//-------------------------------------------------------------------
Function J269RFav( )

Local cConteud  := ""
Local cPAtivo   := ""
Local cPPassivo := ""
Local dData     := ""
Local cCampo    := ""
Local cFilCaj   := ""
Local cCajuri   := ""
Local aRet      := {}

//-- guarda a filial do cajuri e o Cajuri
cFilCaj := O0V->O0V_FILCAJ
cCajuri := O0V->O0V_CAJURI

//-- Busca o conteudo de cada campo
aRet := J269QryFav( cFilCaj, cCajuri )

cCampo := ReadVar()

If Len(aRet) > 0
	If ( 'O0V_PARTES' $ cCampo )
		//-- Título do caso
		cPAtivo   := aRet[3]
		cPPassivo := aRet[4]

		//-- Concatena Polo Ativo x Polo Passivo
		cConteud := AllTrim( cPAtivo ) + " x " + AllTrim( cPPassivo )

	ElseIf ( 'O0V_MOVIME' $ cCampo )
		//-- Ato Processual
		cConteud := aRet[5]

	ElseIf ( 'O0V_DATA' $ cCampo )
		//-- Data do ultimo Andamento
		dData    := SToD( aRet[6] )
	EndIf
EndIf

Return IIF( ('O0V_DATA' $ cCampo), dData, cConteud   )

//-------------------------------------------------------------------
/*/{Protheus.doc} JFilExist(cFilPro)
Verifica se a filial existe

@Param cFilPro - Filial do Processo

@Return lExist - Lógico .T./.F.

@since 28/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFilExist(cFilPro)
Local lExist := .F.

	lExist := FWFilExist(,cFilPro)

return lExist
