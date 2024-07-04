#INCLUDE "JURA226.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA226
De/Para CNJ

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA226()

Local oMascara := Nil
Local oComarca := Nil
Local lCod     := .F. // Indica se serão informados os campos de código no cadastro de máscaras
Local lSeek    := .F. // Indica se será necessário realizar busca de descrições de comarca, 2º nível e 3º nível para incluir somente registros novos. Quando NÃO existir nenhuma comarca não será necessário fazer essa busca.
Local oWS
Local lO00InDic := FWAliasInDic("O00")

	If lO00InDic

		oWS := JURA222():New()

		If oWS <> NIL

			DbSelectArea("O00")
			O00->( DbSetOrder(1) )	//O00_FILIAL+O00_MASCAR
			O00->( DbGoTop() )

			//Existem dados no cadastro de máscaras?
			If O00->(Eof()) // Não existem dados no cadastro de máscaras

				If ApMsgYesNo(STR0031) //"Não existem máscaras cadastradas, deseja incluí-las?"

					DbSelectArea("NQ6")
					NQ6->( DbGoTop() )

					//Existem dados no cadastro de comarca?
					If NQ6->(Eof()) // Não
						lCod := .T.

						// Obtem os registros de comarcas CNJ
						Processa( {|| oComarca := J005BusCom(oWs)} , STR0010, STR0011, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando busca de comarcas'
						If oComarca <> NIL
							// Inclui comarcas
							Processa( {|| J005IncCom(oComarca) } , STR0010, STR0012, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando atualização de comarcas'
						EndIf
					EndIf

					Processa( {|| oMascara := J226BusMas(oWs) } , STR0010, STR0013, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando busca de máscaras'
					If oMascara <> NIL
						Processa( {|| J226IncMas(oMascara) } , STR0010, STR0014, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando atualização de máscaras'
					EndIf

				EndIf

			EndIf

		EndIf

		FWExecView(STR0007,"JURA226", 4,, { || .T. },, ) // "De/Para CNJ"

	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA226", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA226", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA226", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA226", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA226", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de De/Para CNJ

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA226" )
Local oStructCab := FWFormViewStruct():New()
Local oStructO00 := FWFormStruct( 2, "O00" )

	oStructCab:AddField( "O00__PROG"  , ; // [01] Campo
													"01"         , ; // [02] Ordem
													STR0015      , ; // [03] Titulo // "Progresso do De/Para em %"
													STR0015      , ; // [04] Descricao // "Progresso do De/Para em %"
													Nil          , ; // [05] Help
													"GET"        , ; // [06] Tipo do campo   COMBO, Get ou CHECK
													"@#"         , ; // [07] Picture
													Nil          , ; // [08] PictVar
													""           , ; // [09] F3
													.T.          , ; // [10] lCanChange
													'01'         , ; // [11] cFolder
													Nil          , ; // [12] cGroup
													Nil          , ; // [13] aComboValues
													Nil          , ; // [14] nMaxLenCombo
													Nil          , ; // [15] cIniBrow
													.T.          , ; // [16] lVirtual
													Nil            ) // [17] cPictVar

	oStructCab:AddField( "O00__COMA"  , ; // [01] Campo
													"02"         , ; // [02] Ordem
													STR0016      , ; // [03] Titulo // "Comarcas não identificadas"
													STR0016      , ; // [04] Descricao // "Comarcas não identificadas"
													Nil          , ; // [05] Help
													"GET"        , ; // [06] Tipo do campo   COMBO, Get ou CHECK
													""           , ; // [07] Picture
													Nil          , ; // [08] PictVar
													""           , ; // [09] F3
													.T.          , ; // [10] lCanChange
													'01'         , ; // [11] cFolder
													Nil          , ; // [12] cGroup
													Nil          , ; // [13] aComboValues
													Nil          , ; // [14] nMaxLenCombo
													Nil          , ; // [15] cIniBrow
													.T.          , ; // [16] lVirtual
													Nil            ) // [17] cPictVar

	oStructCab:AddField( "O00__L2NI"  , ; // [01] Campo
													"03"         , ; // [02] Ordem
													STR0017      , ; // [03] Titulo // "Segundo nível não identificadas"
													STR0017      , ; // [04] Descricao // "Segundo nível não identificadas"
													Nil          , ; // [05] Help
													"GET"        , ; // [06] Tipo do campo   COMBO, Get ou CHECK
													""           , ; // [07] Picture
													Nil          , ; // [08] PictVar
													""           , ; // [09] F3
													.T.          , ; // [10] lCanChange
													'01'         , ; // [11] cFolder
													Nil          , ; // [12] cGroup
													Nil          , ; // [13] aComboValues
													Nil          , ; // [14] nMaxLenCombo
													Nil          , ; // [15] cIniBrow
													.T.          , ; // [16] lVirtual
													Nil            ) // [17] cPictVar

	oStructCab:AddField( "O00__L3NI"  , ; // [01] Campo
													"04"         , ; // [02] Ordem
													STR0018      , ; // [03] Titulo // "Terceiro nível não identificadas"
													STR0018      , ; // [04] Descricao // "Terceiro nível não identificadas"
													Nil          , ; // [05] Help
													"GET"        , ; // [06] Tipo do campo   COMBO, Get ou CHECK
													""           , ; // [07] Picture
													Nil          , ; // [08] PictVar
													""           , ; // [09] F3
													.T.          , ; // [10] lCanChange
													'01'         , ; // [11] cFolder
													Nil          , ; // [12] cGroup
													Nil          , ; // [13] aComboValues
													Nil          , ; // [14] nMaxLenCombo
													Nil          , ; // [15] cIniBrow
													.T.          , ; // [16] lVirtual
													Nil            ) // [17] cPictVar

	If (oStructO00:HasField( "O00_MASCAR" ))
		oStructO00:SetProperty( "O00_MASCAR", MVC_VIEW_WIDTH, 80 )
	Endif
	If (oStructO00:HasField( "O00_DCOMAR" ))
		oStructO00:SetProperty( "O00_DCOMAR", MVC_VIEW_WIDTH, 300 )
	Endif
	If (oStructO00:HasField( "O00_DLOC2N" ))
		oStructO00:SetProperty( "O00_DLOC2N", MVC_VIEW_WIDTH, 300 )
	Endif
	If (oStructO00:HasField( "O00_DLOC3N" ))
		oStructO00:SetProperty( "O00_DLOC3N", MVC_VIEW_WIDTH, 300 )
	Endif

	oStructCab:SetProperty('O00__L3NI',MVC_VIEW_INSERTLINE,.T.)

	JurSetAgrp( 'O00',, oStructCab )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "JURA226_FIELD", oStructCab , "CAB_VAZIO" )
	oView:AddGrid(  "JURA226_GRID" , oStructO00 , "O00DETAIL" )

	oView:CreateHorizontalBox( "FORMFIELD" , 10 )
	oView:CreateHorizontalBox( "FORMGRID"  , 90 )
	oView:SetOwnerView( "JURA226_FIELD" , "FORMFIELD" )
	oView:SetOwnerView( "JURA226_GRID"  , "FORMGRID"  )

	oView:SetViewProperty("O00DETAIL", "GRIDFILTER", {.T.})
	oView:SetViewProperty("O00DETAIL", "GRIDSEEK", {.T.})

	oView:AddUserButton( STR0019, "BUDGET", { |oView| Processa( {|| J226Proc(oView) } , STR0010, STR0020, .F. ) } ) // "Processar pendências" 'Aguarde', 'Processando Pendencias...'

	//oView:SetDescription( STR0007 ) //"De/Para CNJ"
	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de De/Para CNJ

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0

@obs CAB_VAZIO - Dados do De/Para CNJ

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructCab := FWFormModelStruct():New()
Local oStructO00 := FWFormStruct( 1, "O00" )
Local aCab       := J226AtuQtd()

	oStructCab:AddTable("O00",{},STR0021)//"De/Para Comarca"

	oStructCab:AddField( STR0015        , ; // [01] Titulo do campo // "Progresso do De/Para em %"
													STR0015        , ; // [02] ToolTip do campo // "Progresso do De/Para em %"
													"O00__PROG"    , ; // [03] Id do Field
													"C"            , ; // [04] Tipo do campo
													6              , ; // [05] Tamanho do campo
													0              , ; // [06] Decimal do campo
													NIL            , ; // [07] Code-block de validação do campo
													{||.F.}        , ; // [08] Code-block de validação When do campo
													NIL            , ; // [09] Lista de valores permitido do campo
													NIL            , ; // [10] Obrigatorio?
													{|| aCab[1] }  , ; // [11] Bloco de Inicializador padrão
													Nil            , ; // [12] lKey
													.F.            , ; // [13] lNoUpd
													.T.              ) // [14] lVirtual

	oStructCab:AddField( STR0016        , ; // [01] Titulo do campo // "Comarcas não identificadas"
													STR0016        , ; // [02] ToolTip do campo // "Comarcas não identificadas"
													"O00__COMA"    , ; // [03] Id do Field
													"C"            , ; // [04] Tipo do campo
													6              , ; // [05] Tamanho do campo
													0              , ; // [06] Decimal do campo
													NIL            , ; // [07] Code-block de validação do campo
													{||.F.}        , ; // [08] Code-block de validação When do campo
													NIL            , ; // [09] Lista de valores permitido do campo
													NIL            , ; // [10] Obrigatorio?
													{|| aCab[2] }  , ; // [11] Bloco de Inicializador padrão
													Nil            , ; // [12] lKey
													.F.            , ; // [13] lNoUpd
													.T.              ) // [14] lVirtual

	oStructCab:AddField( STR0017        , ; // [01] Titulo do campo // "Segundo nível não identificadas"
													STR0017        , ; // [02] ToolTip do campo // "Segundo nível não identificadas"
													"O00__L2NI"    , ; // [03] Id do Field
													"C"            , ; // [04] Tipo do campo
													6              , ; // [05] Tamanho do campo
													0              , ; // [06] Decimal do campo
													NIL            , ; // [07] Code-block de validação do campo
													{||.F.}        , ; // [08] Code-block de validação When do campo
													NIL            , ; // [09] Lista de valores permitido do campo
													NIL            , ; // [10] Obrigatorio?
													{|| aCab[3] }  , ; // [11] Bloco de Inicializador padrão
													Nil            , ; // [12] lKey
													.F.            , ; // [13] lNoUpd
													.T.              ) // [14] lVirtual

	oStructCab:AddField( STR0018        , ; // [01] Titulo do campo // "Terceiro nível não identificadas"
													STR0018        , ; // [02] ToolTip do campo // "Terceiro nível não identificadas"
													"O00__L3NI"    , ; // [03] Id do Field
													"C"            , ; // [04] Tipo do campo
													6              , ; // [05] Tamanho do campo
													0              , ; // [06] Decimal do campo
													NIL            , ; // [07] Code-block de validação do campo
													{||.F.}        , ; // [08] Code-block de validação When do campo
													NIL            , ; // [09] Lista de valores permitido do campo
													NIL            , ; // [10] Obrigatorio?
													{|| aCab[4] }  , ; // [11] Bloco de Inicializador padrão
													Nil            , ; // [12] lKey
													.F.            , ; // [13] lNoUpd
													.T.              ) // [14] lVirtual

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA226", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:SetDescription( STR0008 ) //"Modelo de Dados de De/Para CNJ"

	oModel:AddFields( "CAB_VAZIO", NIL, oStructCab, /*Pre-Validacao*/, /*Pos-Validacao*/, {|| })
	oModel:AddGrid( "O00DETAIL", "CAB_VAZIO" /*cOwner*/, oStructO00, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/, {|oModel| SelectO00(oModel)} )

	//Aumenta a capacidade de linhas no grid
	oModel:GetModel("O00DETAIL"):SetMaxLine(999999)

	oModel:SetPrimaryKey( {"O00DETAIL", {"O00_FILIAL", "O00_MASCAR", "O00_CCOMAR","O00_CLOC2N"} } )

	oModel:GetModel( "CAB_VAZIO" ):SetDescription( STR0022 ) //"Progresso de De/Para CNJ"
	oModel:GetModel( "O00DETAIL" ):SetDescription( STR0009 ) //"Dados de De/Para CNJ"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J226AtuQtd
Atualiza campos de quantidade do De/Para

@return nPorcent  Progresso de De/Para
         nQtdComar Quantidade de comarcas não identificadas
         nQtdLoc2N Quantidade de segundo nível não identificadas
         nQtdLoc3N Quantidade de terceiro nível não identificadas

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226AtuQtd()

Local aQtd := J226LocMas()
Local nQtdComar := aQtd[1]
Local nQtdLoc2N := aQtd[2]
Local nQtdLoc3N := aQtd[3]
Local nQtdTotal := IIF(aQtd[4] > 0 ,aQtd[4] * 2, 0) // Total de máscaras * 2 para que sejam contados os campos de comarca e 2º nível
Local nQtdTot3N := aQtd[5] // Quantidade total de localizações de 3º nível

Local nTotalNot := nQtdComar + nQtdLoc2N + nQtdLoc3N // Total não localizado

Local nPorcent  := 0

nQtdTotal += nQtdTot3N // Adicionando as localizações de 3º nível no total

If nTotalNot > 0 .And. nQtdTotal > 0 .And. nTotalNot < nQtdTotal

	nPorcent := 100 - ( (nTotalNot / nQtdTotal) * 100 )

ElseIf nQtdTotal > 0 .And. nTotalNot == 0

	nPorcent := 100

EndIf

Return {SubStr(AllTrim(STR(nPorcent)),1,5), AllTrim(STR(nQtdComar)), AllTrim(STR(nQtdLoc2N)), AllTrim(STR(nQtdLoc3N))}

//-------------------------------------------------------------------
/*/{Protheus.doc} J226NQCO00
Filtra consulta padrão de localização de 2. nivel conforme comarca

@Return cRet Comando para filtro
@sample
@#J226NQCO00()

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226NQCO00()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oModelO00 := oModel:GetModel('O00DETAIL')
	Local nLine     := oModelO00:GetLine()
	Local cComar    := ""
	Local cRet      := "@#@#"

	cComar  := oModelO00:GetValue('O00_CCOMAR', nLine)

	If Empty(Alltrim(cComar))
		cComar  := Alltrim(M->O00_CCOMAR)
	EndIf

	If !Empty(cComar)
		cRet := "@#NQC->NQC_CCOMAR == '"+cComar+"'@#"
	Endif

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J226NQEO00
Filtra consulta padrão de localização de 3º nivel conforme localização
de 2º nivel

@Return cRet Comando para filtro
@sample
@#J226NQEO00()

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226NQEO00()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oModelO00 := oModel:GetModel('O00DETAIL')
	Local nLine     := oModelO00:GetLine()
	Local cLoc2N    := ""
	Local cRet      := "@#@#"

	cLoc2N  := oModelO00:GetValue('O00_CLOC2N', nLine)

	If Empty(Alltrim(cLoc2N))
		cLoc2N  := Alltrim(M->O00_CLOC2N)
	EndIf

	If !Empty(cLoc2N)
		cRet := "@#NQE->NQE_CLOC2N == '"+cLoc2N+"'@#"
	Endif

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J226VldNQ6()
Validação de comarca por UF.
Uso na consulta padrão de De/Para CNJ

@return lRet Informa se o valor do campo é válido
@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226VldNQ6()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oModelO00 := oModel:GetModel('O00DETAIL')
	Local nLine     := oModelO00:GetLine()
	Local lRet      := .T.
	Local cUF       := ""

	cUF := oModelO00:GetValue('O00_UF', nLine)

	If !Empty(Alltrim(cUF))
		lRet := JurGetDados("NQ6",1,XFILIAL("NQ6") + oModelO00:GetValue('O00_CCOMAR', nLine), "NQ6_UF") == cUF
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J226VldNQC
Valida se o campo de Localização de 2. Nivel está vinculado ao de
Comarca

@Return lRet Informa se o valor do campo é válido
@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226VldNQC()
	Local lRet      := .F.
	Local aArea     := GetArea()
	Local aAreaNQC  := NQC->( GetArea() )
	Local oModel    := FWModelActive()
	Local oModelO00 := oModel:GetModel('O00DETAIL')
	Local nLine     := oModelO00:GetLine()
	Local cComarca  := oModelO00:GetValue("O00_CCOMAR", nLine)
	Local cLoc2N    := oModelO00:GetValue("O00_CLOC2N", nLine)

	If !Empty(cLoc2N)

		NQC->( dbSetOrder( 3 ) )
		If NQC->( dbSeek( xFilial( 'NQC' ) + cLoc2N ) )
			If cComarca == NQC->NQC_CCOMAR
				lRet := .T.
			Endif
		End

		If !lRet
			JurMsgErro(STR0023) //"Foro ou Tribunal não compatíveis com a Comarca informada"
		EndIf

	EndIf

	RestArea( aAreaNQC )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J226VldNQE
Valida se o campo de Localização de 3. Nivel está vinculado ao de
Localização de 2. Nivel

@Return lRet Informa se o valor do campo é válido
@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226VldNQE()
	Local lRet      := .F.
	Local aArea     := GetArea()
	Local aAreaNQE  := NQE->( GetArea() )
	Local oModel    := FWModelActive()
	Local oModelO00 := oModel:GetModel('O00DETAIL')
	Local nLine     := oModelO00:GetLine()
	Local cLoc2N    := oModelO00:GetValue("O00_CLOC2N", nLine)
	Local cLoc3N    := oModelO00:GetValue("O00_CLOC3N", nLine)

	If !Empty(cLoc3N)

		NQE->( dbSetOrder( 1 ) )

		If NQE->( dbSeek( xFilial( 'NQE' ) + cLoc3N ) )

			If cLoc2N == NQE->NQE_CLOC2N
				lRet := .T.
			Endif

			If !lRet
				JurMsgErro(STR0024) // "Vara ou Camara não compatíveis com o Foro e/ou Tribunal"
			EndIf

		EndIf

	EndIf

	RestArea( aAreaNQE )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SelectO00( oModel )
Carrega os itens de máscaras no grid.

Usado para carregar informações, pois não existe um field acima desse
grid e por isso a carga deve ser manual

@param oModel Modelo de dados ativo

@return aRet Dados que serão exibidos no grid de máscaras

@author Jorge Luis Branco Martins Junior
@since  08/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SelectO00( oModel )
Local aSave      := GetArea()
Local aSaveO00   := O00->( GetArea() )
Local aRet       := {}
Local cTmpQry    := GetNextAlias()
Local cSql       := ""

cSql := " SELECT * "
cSql +=    " FROM " + RetSqlName("O00") + " O00 "
cSql += " WHERE "
cSql +=    " O00.O00_FILIAL = '"+xFilial("O00")+"' AND "
cSql +=    " O00.D_E_L_E_T_ = ' ' "
cSql +=    " ORDER BY O00.O00_MASCAR "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cTmpQry,.T.,.T.)

aRet := FwLoadByAlias( oModel, cTmpQry )

(cTmpQry)->(DbCloseArea())

RestArea(aSaveO00)
RestArea(aSave)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J226Proc(oView)
Processa pendências de De/Para automaticamente

@param  oView	- View de dados de De/Para CNJ

@author Jorge Luis Branco Martins Junior
@since  08/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226Proc(oView)
Local aArea       := GetArea()
Local oModel      := FWModelActive()
Local oModelO00   := oModel:GetModel('O00DETAIL')
Local nQtdLine    := oModelO00:GetQtdLine()
Local nI          := 0
Local cComarca    := ""
Local cUF         := ""
Local cCodComarca := ""
Local cLoc2N      := ""
Local cCodLoc2N   := ""
Local cLoc3N      := ""
Local cCodLoc3N   := ""
Local lRet        := .T.

aQtd := J226LocMas()
nQtdComar := aQtd[1]
nQtdLoc2N := aQtd[2]
nQtdLoc3N := aQtd[3]

// Registros estão todos localizados?
If nQtdComar == 0 .And. nQtdLoc2N == 0 .And. nQtdLoc3N == 0 // Sim, estão todos localizados
	ApMsgInfo(STR0025) //"Todos os registros já estão localizados."
Else
	If nQtdLine > 1

		ProcRegua(0)
		IncProc()
		For nI := 1 To nQtdLine

			IncProc( I18N( STR0026,{ AllTrim(str(nI)) , AllTrim(str(nQtdLine)) } ) ) // "Atualizando pendências #1 de #2"
			oModelO00:GoLine(nI)

			// De/Para Comarca
			If Empty(oModelO00:GetValue("O00_CCOMAR", nI)) .And. !Empty(oModelO00:GetValue("O00_DCOMAR", nI))
				If ( cComarca <> oModelO00:GetValue("O00_DCOMAR", nI) .Or. cUF <> oModelO00:GetValue("O00_UF", nI) ) .And. ;
				   ( oModelO00:GetValue("O00_DCOMAR", nI) <> cComarca .Or. oModelO00:GetValue("O00_UF", nI) <> cUF )

					cComarca := oModelO00:GetValue("O00_DCOMAR", nI)
					cUF      := oModelO00:GetValue("O00_UF", nI)

					If !Empty(cComarca) .AND. !Empty(cUF)
						cCodComarca := J005Comarca(cComarca, cUF)[1]
					EndIf

				EndIf

				If !Empty(cCodComarca)
					lRet := oModelO00:LoadValue("O00_CCOMAR", cCodComarca)
				EndIf

			EndIf

			// De/Para Localização de 2º nível
			If lRet
				If Empty(oModelO00:GetValue("O00_CLOC2N", nI)) .And. !Empty(oModelO00:GetValue("O00_DLOC2N", nI))
					If cLoc2N <> oModelO00:GetValue("O00_DLOC2N", nI) .And. ;
						oModelO00:GetValue("O00_DLOC2N", nI) <> cLoc2N

						cLoc2N := oModelO00:GetValue("O00_DLOC2N", nI)

						If !Empty(cLoc2N)
							cCodLoc2N := J005Loc2N(cLoc2N)[1]
						EndIf

					EndIf

					If !Empty(cCodLoc2N)
						lRet := oModelO00:LoadValue("O00_CLOC2N", cCodLoc2N)
					EndIf

				EndIf

			EndIf

			// De/Para Localização de 3º nível
			If lRet
				If Empty(oModelO00:GetValue("O00_CLOC3N", nI)) .And. !Empty(oModelO00:GetValue("O00_DLOC3N", nI))
					If cLoc3N <> oModelO00:GetValue("O00_DLOC3N", nI) .And. ;
						oModelO00:GetValue("O00_DLOC3N", nI) <> cLoc3N

						cLoc3N := oModelO00:GetValue("O00_DLOC3N", nI)

						If !Empty(cLoc3N)
							cCodLoc3N := J005Loc3N(cLoc3N)[1]
						EndIf

					EndIf

					If !Empty(cCodLoc3N)
						lRet := oModelO00:LoadValue("O00_CLOC3N", cCodLoc3N)
					EndIf

				EndIf

			EndIf

		Next

	EndIf

	oModelO00:GoLine(1)

	If lRet
		ApMsgInfo(STR0027) //"Clique em confirmar para efetivar a alteração"
	EndIf

EndIf

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J226BusMas()
Obtem os registros de máscaras CNJ

@Return oLista Lista de máscaras

@author Jorge Luis Branco Martins Junior
@since 29/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226BusMas(oWs)
Local aArea       := GetArea()
Local cSoapFDescr := ''
Local oLista      := {}
Local cUsuario    := SuperGetMV('MV_JINDUSR',, '')

If Empty(cUsuario) .And. IsInCallStack("JurLoadAsJ")
	cUsuario := "--------"
Endif

If Empty(cUsuario)
	MsgAlert(STR0032) //'É preciso preencher o parametro MV_JINDUSR para obter atualizações da comarca, qualquer dúvida procure o suporte da TOTVS'
Else

	ProcRegua(0)
	IncProc()

	If oWS <> NIL

		IncProc(STR0028)//'Buscando máscaras'

		oWS:cUsuario := cUsuario

		oWS:MTMascaras()
		If oWS:oWSMTMASCARASRESULT:OWSDADOS != Nil
			oLista := oWS:oWSMTMASCARASRESULT:OWSDADOS:OWSSTRUDADOSMASCARA
		Else
			oLista := {}
			cSoapFDescr := GetWSCError(3) // Soap Fault Description

			If Empty(cSoapFDescr)
				MsgAlert(STR0029) //"Erro de conexão"
			Else
				MsgAlert(cSoapFDescr)
			EndIf
		EndIf

		oWS := Nil

	EndIf

EndIf

RestArea( aArea )

Return oLista

//-------------------------------------------------------------------
/*/{Protheus.doc} J226IncMas(oMascara)
Inclui máscaras

@param oMascara Dados de máscaras a serem incluidas

@author Jorge Luis Branco Martins Junior
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226IncMas(oMascara)

	Local oModel      := NIL
	Local nI          := 0
	Local nQtd        := 0
	Local cCodComarca := ""
	Local cCodLoc2N   := ""
	Local cCodLoc3N   := ""
	Local cDescComar  := ""
	Local cUF         := ""
	Local cDescForo   := ""
	Local cDescVara   := ""
	Local cCodComWS   := ""
	Local aComarca    := {"","",""}
	Local aLoc2N      := {"","",""}
	Local aLoc3N      := {"","",""}

	DbSelectArea("O00")
	O00->(DbSetOrder(1)) //O00_FILIAL+O00_MASCAR+O00_CCOMAR+O00_CLOC2N+O00_CLOC3N
	O00->(DbGoTop())

	nQtd := Len(oMascara)

	ProcRegua(0)
	IncProc()

	For nI := 1 to nQtd

		IncProc( I18N( STR0030,{ AllTrim(str(nI)) , AllTrim(str(nQtd)) } ) ) // "Atualizando máscaras #1 de #2"

		// Limpa os Arrays
		aComarca    := {"","",""}
		aLoc2N      := {"","",""}
		aLoc3N      := {"","",""}

		// Inicializa as variáveis
		cCodComarca := AllTrim(oMascara[nI]:cCODCOMARCA)
		cCodLoc2N   := AllTrim(oMascara[nI]:cCODLOC2N)
		cCodLoc3N   := AllTrim(oMascara[nI]:cCODLOC3N)
		cDescComar  := AllTrim(oMascara[nI]:cDESCOMARCA)
		cUF         := AllTrim(oMascara[nI]:cUF)
		cDescForo   := AllTrim(oMascara[nI]:cDESLOC2N)
		cDescVara   := AllTrim(oMascara[nI]:cDESLOC3N)

		// Busca a Comarca pela Descrição + Código + UF
		aComarca    := J005Comarca(cDescComar, cUF, cCodComarca ) // Busca da NQ6

		// Se não encontrou a Comarca, busca pela Descrição + UF
		If Empty(aComarca[1])
			aComarca    := J005Comarca(cDescComar, cUF)
		EndIf

		// Busca os dados do Foro e da Vara
		aLoc2N      := J005Loc2N(cDescForo, aComarca[1])
		aLoc3N      := J005Loc3N(cDescVara, , aLoc2N[1] )

		// Procura a mascara. Indice (01): Filial + Mascara
		If ( O00-> ( DbSeek(xFilial("O00") + AllTrim(oMascara[nI]:cMASCARA) ) ) )
			// Verifica se a Descrição da Comarca bate com a do DE/PARA. Se for diferente, tem de correr a validação. Caso contrario, verificar o Foro
			If (cDescComar <> AllTrim(O00->O00_DCOMAR) .OR. (cCodComarca <> O00->O00_CCOMAR)) .And. !Empty(aComarca[1])
				cCodComarca := aComarca[1]
				cDescComar  := aComarca[2]
			EndIf

			// Foro.
			If (O00->O00_DLOC2N <> aLoc2N[2] .OR. O00->O00_CLOC2N <> aLoc2N[1]) .And. !Empty(aLoc2N[1]) .And. aLoc2N[2] == cCodComarca
				cCodLoc2N   := aLoc2N[1]
				cDescForo   := aLoc2N[2]
			EndIf

			// Vara
			If (O00->O00_DLOC3N <> aLoc3N[2] .OR. O00->O00_CLOC2N <> aLoc3N[1]) .And. !Empty(aLoc3N[1])
				cCodLoc3N := aLoc3N[1]
				cDescVara := aLoc3N[2]
			EndIf

			Reclock( "O00", .F. )
		Else
			Reclock( "O00", .T. )

			// Comarca
			If !Empty(aComarca[1])
				cCodComarca := aComarca[1]
				cDescComar  := aComarca[2]
			EndIf

			// Foro
			If !Empty(aLoc2N[1])
				cCodLoc2N   := aLoc2N[1]
				cDescForo   := aLoc2N[2]
			EndIf

			// Vara
			If !Empty(aLoc3N[1])
				cCodLoc3N := aLoc3N[1]
				cDescVara := aLoc3N[2]
			EndIf

		EndIf

		O00->O00_MASCAR := AllTrim(oMascara[nI]:cMASCARA)
		O00->O00_CCOMAR := cCodComarca
		O00->O00_DCOMAR := cDescComar
		O00->O00_UF     := cUF
		O00->O00_CLOC2N := cCodLoc2N
		O00->O00_DLOC2N := cDescForo
		O00->O00_CLOC3N := cCodLoc3N
		O00->O00_DLOC3N := cDescVara

		O00->( MsUnLock() )

		If __lSX8
			ConfirmSX8()
		EndIf

	Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J226LocMas
Indica se exitem registros não localizados e as quantidades

@return nQtdComar Quantidade de comarcas não localizadas
         nQtdLoc2N Quantidade de localizações de 2º nível não localizadas
         nQtdLoc3N Quantidade de localizações de 3º nível não localizadas
         nQtdTotal Quantidade total de máscaras
         nQtdTot3N Quantidade total de localizações de 3º nível

@author Jorge Luis Branco Martins Junior
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J226LocMas()
Local aArea     := GetArea()
Local cSQL      := ""
Local cQrySql   := NIL
Local nQtdTotal, nQtdComar, nQtdLoc2N, nQtdLoc3N, nQtdTot3N := 0
Local cCComar   := PADR(' ', TamSx3('O00_CCOMAR')[1])
Local cDComar   := PADR(' ', TamSx3('O00_DCOMAR')[1])
Local cCLoc2N   := PADR(' ', TamSx3('O00_CLOC2N')[1])
Local cDLoc2N   := PADR(' ', TamSx3('O00_DLOC2N')[1])
Local cCLoc3N   := PADR(' ', TamSx3('O00_CLOC3N')[1])
Local cDLoc3N   := PADR(' ', TamSx3('O00_DLOC3N')[1])

	cSQL := " SELECT COUNT(O00.O00_CCOMAR) TOTAL "
	cSQL +=   " FROM " + RetSqlName("O00") + " O00 "
	cSQL += " WHERE O00.O00_FILIAL = '"+xFilial("O00")+"' AND "
	cSQL +=       " O00.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	cQrySql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cQrySql,.T.,.T.)

	If (cQrySql)->(!Eof())
		nQtdTotal := (cQrySql)->TOTAL // Quantidade total de máscaras
	End

	(cQrySql)->(dbCloseArea())

	cSQL := " SELECT COUNT(O00.O00_CCOMAR) COMARCA "
	cSQL +=   " FROM " + RetSqlName("O00") + " O00 "
	cSQL += " WHERE O00.O00_DCOMAR <> '"+cDComar+"' AND "
	cSQL +=       " O00.O00_CCOMAR = '"+cCComar+"' AND "
	cSQL +=       " O00.O00_FILIAL = '"+xFilial("O00")+"' AND "
	cSQL +=       " O00.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	cQrySql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cQrySql,.T.,.T.)

	If (cQrySql)->(!Eof())
		nQtdComar := (cQrySql)->COMARCA // Quantidade de comarcas não localizadas
	End

	(cQrySql)->(dbCloseArea())

	cSQL := " SELECT COUNT(O00.O00_CLOC2N) LOC2N "
	cSQL +=   " FROM " + RetSqlName("O00") + " O00 "
	cSQL += " WHERE O00.O00_DLOC2N <> '"+cDLoc2N+"' AND "
	cSQL +=       " O00.O00_CLOC2N = '"+cCLoc2N+"' and
	cSQL +=       " O00.O00_FILIAL = '"+xFilial("O00")+"' AND "
	cSQL +=       " O00.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	cQrySql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cQrySql,.T.,.T.)

	If (cQrySql)->(!Eof())
		nQtdLoc2N := (cQrySql)->LOC2N // Quantidade de localizações de 2º nível não localizadas
	End

	(cQrySql)->(dbCloseArea())

	cSQL := " SELECT COUNT(O00.O00_CLOC3N) LOC3N "
	cSQL +=   " FROM " + RetSqlName("O00") + " O00 "
	cSQL += " WHERE O00.O00_DLOC3N <> '"+cDLoc3N+"' AND "
	cSQL +=       " O00.O00_CLOC3N = '"+cCLoc3N+"' AND "
	cSQL +=       " O00.O00_FILIAL = '"+xFilial("O00")+"' AND "
	cSQL +=       " O00.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	cQrySql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cQrySql,.T.,.T.)

	If (cQrySql)->(!Eof())
		nQtdLoc3N := (cQrySql)->LOC3N // Quantidade de localizações de 3º nível não localizadas
	End

	(cQrySql)->(dbCloseArea())

	cSQL := " SELECT COUNT(O00.O00_CLOC3N) LOC3N "
	cSQL +=   " FROM " + RetSqlName("O00") + " O00 "
	cSQL += " WHERE O00.O00_DLOC3N <> '"+cDLoc3N+"' AND "
	cSQL +=       " O00.O00_FILIAL = '"+xFilial("O00")+"' AND "
	cSQL +=       " O00.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	cQrySql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cQrySql,.T.,.T.)

	If (cQrySql)->(!Eof())
		// Quantidade total de localizações de 3º nível
		// Precisamos desse total para saber quantas localizações de 3º nível realmente existem,
		// já que o CIVEL não possuí Localização de 3º nível
		nQtdTot3N := (cQrySql)->LOC3N
	End

	(cQrySql)->(dbCloseArea())

	RestArea( aArea )

Return {nQtdComar,nQtdLoc2N,nQtdLoc3N,nQtdTotal,nQtdTot3N}
