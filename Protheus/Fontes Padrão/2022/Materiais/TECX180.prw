#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'LOCACAO.CH'
#INCLUDE 'TECX180.CH'

#DEFINE MAX_BYTES_STRING 1048500  // "1048576" é o real valor máximo para uma string

Static aTabIndex := {}

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180Parm
	 Realiza o tratamento dos parâmetro passados para gerar de/até em posições de array
@sample 	At180Parm()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180Parm( xData1, xData2 )

Local aRet := Nil

If ValType(xData1) == 'U' .Or. ValType(xData2) == 'U'

	If ValType(xData1)=='U' .And. ValType(xData1)=='U'
		aRet := {}
	ElseIf ValType(xData1)=='U'
		aRet := {xData2,xData2}
	Else
		aRet := {xData1,xData1}
	EndIf

ElseIf Empty(xData1) .Or. Empty(xData2)

	If Empty(xData1) .And. Empty(xData2)
		aRet := {}
	ElseIf Empty(xData1)
		aRet := {xData2,xData2}
	Else
		aRet := {xData1,xData1}
	EndIf

Else
	aRet := { xData1, xData2 }
EndIf

Return aClone( aRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180Query
	Executa as queries para busca dos dados no formato de consulta detalhada
@sample 	At180Query()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180Query( nModRet, xRet, cError, dDtIni, dDtFim, aEqto, aLocal, aPrd, aCliLoj, cStatus, dDtRefe, oGSTmpTbl )

Local lRet         := .T.
Local cExeQry      := ''
Local lFirsCond    := .T.
Local dDtAlvo      := CTOD('')
Local aExeQry      := {}

Local nExec        := 1
Local cTmpQry      := ''

Local nCpo         := 0
Local aCpos        := {}
Local nTotCpos     := 0
Local xValor       := Nil
Local nLinArray    := 0

Local cArqAux      := ''
Local aIdx		   := {}

DEFAULT nModRet    := 0
DEFAULT cError     := ''

DEFAULT dDtRefe    := dDatabase
DEFAULT dDtIni     := dDataBase
DEFAULT dDtFim     := dDataBase

DEFAULT aEqto      := {}
DEFAULT aLocal     := {}
DEFAULT aPrd       := {}
DEFAULT aCliLoj    := {}

DEFAULT cStatus    := EQ_TODOS

If nModRet == 0
	lRet   := .F.
	cError := STR0001 // 'Modo de retorno da query não definido'

ElseIf nModRet == MODO_RET_TABELA .And. ( ValType(xRet) <> 'C' .Or. Empty(xRet) )
	xRet := ''

ElseIf nModRet == MODO_RET_ARRAY .And. ValType(xRet) <> 'A'
	xRet := {}

ElseIf nModRet == MODO_RET_STRING .And. ValType(xRet) <> 'C'
	xRet := ''

EndIf

If lRet

	dDtAlvo := dDtIni

	While lRet .And. dDtAlvo <= dDtFim
		cExeQry := ''
		lFirsCond := .T.
// Identifica os status a serem retornados
		If EQ_TODOS $ cStatus

			At180Disp( @cExeQry, dDtRefe, nModRet, dDtAlvo, aEqto, aLocal, aPrd, aCliLoj)

			cExeQry += " UNION ALL "

			At180Aloc( @cExeQry, dDtRefe, nModRet, dDtAlvo, aEqto, aLocal, aPrd, aCliLoj)

		Else

			// caso não tenha selecionado todos os registros
			// executa para cada situação possível, assim irá permitir visualizar os equipamentos
			// em manutenção e disponíveis OU separados e alocados por exemplo
			If EQ_DISPONIVEL $ cStatus
				At180Disp( @cExeQry, dDtRefe, nModRet, dDtAlvo, aEqto, aLocal, aPrd, aCliLoj)
			EndIf

			If !lFirsCond
				cExeQry += " UNION ALL "
				lFirsCond := .F.
			EndIf
			If EQ_DISPONIVEL <> Alltrim(cStatus)
				At180Aloc( @cExeQry, dDtRefe, nModRet, dDtAlvo, aEqto, aLocal, aPrd, aCliLoj)
			EndIf

		EndIf
		dDtAlvo += 1

		aAdd( aExeQry, cExeQry )

	End

	If MODO_RET_TABELA == nModRet

		Aadd(aIdx, {"I1",{ 'AA3_FILIAL','X_DIA'}})
		Aadd(aIdx, {"I2",{ 'AA3_FILIAL','AA3_CODPRO','AA3_NUMSER'}})
		Aadd(aIdx, {"I3",{ 'AA3_FILIAL','TEW_CODMV'}})
		Aadd(aIdx, {"I4",{ 'AA3_FILIAL','TEW_RESCOD'}})
		Aadd(aIdx, {"I5",{'AA3_FILIAL', 'TEW_TIPO', 'TEW_DTRINI' }})

		aCpos := At180GetSt()
		oGSTmpTbl := GSTmpTable():New('TRAB',aCpos, aIdx )
		xRet := 'TRAB'
		oGSTmpTbl:CreateTMPTable()
		oGSTmpTbl:Commit()

		nTotCpos := Len(aCpos)

		DbSelectArea(xRet)

		cTmpQry := GetNextAlias()

		For nExec := 1 To Len(aExeQry)
			aExeQry[nExec] := ChangeQuery(aExeQry[nExec])
			dbUseArea( .T., "TOPCONN", TcGenQry( , , aExeQry[nExec] ), cTmpQry, .T., .T. )

			DbSelectArea(cTmpQry)  // garante que o resultado da query é a área ativa
			For nCpo := 1 To nTotCpos
				If aCpos[nCpo,2] <> 'C'
					TcSetField( cTmpQry, aCpos[nCpo,1], aCpos[nCpo,2], aCpos[nCpo,3], aCpos[nCpo,4] )
				EndIf
			Next nCpo

			// Copia todos os dados do resultado da query para o arquivo temporário criado
			While (cTmpQry)->(!EOF())
				Reclock(xRet, .T.)
					For nCpo := 1 To (xRet)->( FCount() )
						xValor := (cTmpQry)->&((xRet)->(FieldName(nCpo)))
						FieldPut(nCpo, xValor)
					Next nCpo
				(xRet)->( MsUnlock() )

				(cTmpQry)->( DbSkip() )
			End

			(cTmpQry)->( DbCloseArea() )  // fecha a área com o resultado da query
		Next nExec

	ElseIf MODO_RET_STRING == nModRet
		For nExec := 1 To Len(aExeQry)
			If nExec <> 1
				xRet += ' UNION ALL '
			EndIf

			xRet += ChangeQuery(aExeQry[nExec])

		Next nExec

	ElseIf MODO_RET_ARRAY == nModRet

		xRet := {{},{}}

		xRet[1] := aClone(aCpos := At180GetSt())
		nTotCpos := Len(aCpos)

		For nExec := 1 To Len(aExeQry)
			aExeQry[nExec] := ChangeQuery(aExeQry[nExec])
			dbUseArea( .T., "TOPCONN", TcGenQry( , , aExeQry[nExec] ), cTmpQry, .T., .T. )

			DbSelectArea(cTmpQry)  // garante que o resultado da query é a área ativa
			For nCpo := 1 To Len(aCpos)
				TcSetField( cTmpQry, aCpos[nCpo,1], aCpos[nCpo,2], aCpos[nCpo,3], aCpos[nCpo,4] )
			Next nCpo

			// Copia todos os dados do resultado da query para o arquivo temporário criado
			While (cTmpQry)->(!EOF())
				aAdd( xRet[2], Array(nTotCpos))

				nLinArray := Len( xRet[2] )

				For nCpo := 1 To nTotCpos
					xRet[2,nLinArray,nCpo] := (cTmpQry)->&(FieldName(nCpo))
				Next nCpo

				(cTmpQry)->( DbSkip() )
			End

			(cTmpQry)->( DbCloseArea() )  // fecha a área com o resultado da query
		Next nExec

	EndIf

	aSize( aExeQry, 0)
	aExeQry := Nil

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180GetSt
	carrega os dados da estrutura da tabela para criação da tabela temporária
@sample 	At180GetSt()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180GetSt( nTipo, lOnlyAA3 )

Local aCampos   := {'AA3_FILIAL','AA3_FILORI','AA3_CODPRO','AA3_DESPRO','AA3_NUMSER','AA3_MODELO','AA3_CBASE','AA3_ITEM','AA3_CHAPA','AA3_MANPRE', ;
					'TEW_CODMV','TEW_TIPO','TEW_DTSEPA','TEW_DTRINI','TEW_DTRFIM','TEW_FECHOS','TFI_PERINI','TFI_PERFIM',;
					'TEW_RESCOD','AA3_EQ3'}
Local aEstrut   := {}
Local nX        := 1

Local aSave     := GetArea()
Local aSaveSX3  := SX3->( GetArea() )
Local nCposAnt  := 0
Local lPesq     := .T.
Local lIntTecMnt := ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)

Default nTipo   := 1
Default lOnlyAA3 := .F.

If lIntTecMnt
	aAdd( aCampos, 'TJ_DTMPFIM' )
EndIf

If nTipo == 1  // array básico para a tabela
	If !lOnlyAA3
		aAdd( aEstrut, { 'X_DIA',      'D', 8, 0 } )
	Else
		aAdd( aEstrut, { 'AA3_XDISP',  'N', 1, 0 } )
	EndIf

	DbSelectArea('SX3')
	DbSetOrder(2) // X3_CAMPO

	For nX := 1 To Len(aCampos)
		// --------------------------------------
		//  verifica se tem como origem a tabela AA3
		lPesq := If( !lOnlyAA3, .T., 'AA3_' $ aCampos[nX] )

		If lPesq .And. SX3->( MsSeek( PadR( aCampos[nX], 10 ) ) )
			aAdd( aEstrut, { aCampos[nX], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
		EndIf

	Next nX

ElseIf nTipo == 2
	// array para criação de browse

	If !lOnlyAA3
		// Dia das informações
		aAdd( aEstrut, FWBrwColumn():New() )
			aEstrut[1]:SetData( &("{|| STOD(X_DIA) }") )
			aEstrut[1]:SetTitle( STR0002 )  // 'Data'
			aEstrut[1]:SetSize(8)
			aEstrut[1]:SetDecimal(0)
	Else
		// situção do equipamento
		aAdd( aEstrut, FWBrwColumn():New() )
			aEstrut[1]:SetData( &("{|| AA3_XDISP }") )
			aEstrut[1]:SetTitle( STR0003 )  // 'Status'
			aEstrut[1]:SetSize(1)
			aEstrut[1]:SetDecimal(0)
	EndIf

	DbSelectArea('SX3')

	nCposAnt := Len(aEstrut)

	For nX := 1 To Len(aCampos)

		// --------------------------------------
		//  verifica se tem como origem a tabela AA3
		lPesq := If( !lOnlyAA3, .T., 'AA3_' $ aCampos[nX] )

		DbSetOrder(2) // X3_CAMPO

		If lPesq .And. SX3->( MsSeek( PadR( aCampos[nX], 10 ) ) )

			aAdd( aEstrut, FWBrwColumn():New() )
				aEstrut[nCposAnt+nX]:SetData( &("{||" + aCampos[nX] + "}") )
				aEstrut[nCposAnt+nX]:SetTitle( X3Titulo() )
				aEstrut[nCposAnt+nX]:SetSize( TamSX3(aCampos[nX])[1] )
				aEstrut[nCposAnt+nX]:SetDecimal(TamSX3(aCampos[nX])[2])

		EndIf

	Next nX

ElseIf nTipo == 3
	/* Array para uso na FwBrowse
	// [n][01] Título da coluna
	// [n][02] Code-Block de carga dos dados
	// [n][03] Tipo de dados
	// [n][04] Máscara
	// [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	// [n][06] Tamanho
	// [n][07] Decimal
	// [n][08] Indica se permite a edição
	// [n][09] Code-Block de validação da coluna após a edição
	// [n][10] Indica se exibe imagem
	*/

	If !lOnlyAA3
		// Data
		aAdd( aEstrut, { STR0002, {||X_DIA}, 'D', ,1,8,0,.F.,{||.F.}, .F. } )  // 'Data'
	Else
		// Situação
		aAdd( aEstrut, { STR0003, {||AA3_XDISP}, 'N', ,1,1,0,.F.,{||.F.}, .F. } )  // 'Status'
	EndIf

	DbSelectArea('SX3')

	For nX := 1 To Len(aCampos)

		// --------------------------------------
		//  verifica se tem como origem a tabela AA3
		lPesq := If( !lOnlyAA3, .T., 'AA3_' $ aCampos[nX] )

		DbSetOrder(2) // X3_CAMPO

		If lPesq .And. SX3->( DbSeek( PadR( aCampos[nX], 10 ) ) )

			aAdd( aEstrut, { X3Titulo(), ;
							 &('{||'+aCampos[nX]+'}'),;
							 SX3->X3_TIPO,;
							 X3Picture(aCampos[nX]),;
							 1 ,;
							 TamSX3(aCampos[nX])[1],;
							 TamSX3(aCampos[nX])[2],;
							 .F. ,;
							 {|| .F.},;
							 .F. } )

		EndIf

	Next nX

EndIf

RestArea( aSaveSX3 )
RestArea( aSave )

Return (aClone(aEstrut))

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180Disp
	Consulta os equipamentos disponíveis
@sample 	At180Disp()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At180Disp( cQryDisp, dDtRefe, nModRet, dDtAlvo, aEqto, aLocal, aPrd, aCliLoj)

Local lRet       := .T.
Local lIntTecMnt := ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local cPlanoMNT := "000000"
Local cSrvMnt := SuperGetMv('MV_GSSVMNT', , '')
Local cConcat	:= If(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+") //Sinal de concatenação (Igual ao ADMXFUN)

DEFAULT cQryDisp := ''
DEFAULT dDtRefe  := dDataBase
DEFAULT aEqto    := {}
DEFAULT aLocal   := {}
DEFAULT aPrd     := {}
DEFAULT aCliLoj  := {}

If lIntTecMnt
// equipamentos disponíveis
	cQryDisp += " SELECT "
	cQryDisp += "'"+DTOS(dDtAlvo)+"' X_DIA"
	cQryDisp += ", AA3_FILIAL"
	cQryDisp += ", AA3_FILORI"
	cQryDisp += ", AA3_CODPRO"
	cQryDisp += ", SB1.B1_DESC AA3_DESPRO"
	cQryDisp += ", AA3_NUMSER"
	cQryDisp += ", AA3_MODELO"
	cQryDisp += ", AA3_CBASE"
	cQryDisp += ", AA3_ITEM"
	cQryDisp += ", AA3_CHAPA"
	cQryDisp += ", AA3_MANPRE"
	cQryDisp += ", AA3_EQ3"
	cQryDisp += ", ' ' TEW_CODMV"
	cQryDisp += ", ' ' TEW_TIPO"
	cQryDisp += ", ' ' TEW_DTSEPA"
	cQryDisp += ", ' ' TEW_DTRINI"
	cQryDisp += ", ' ' TEW_DTRFIM"
	cQryDisp += ", ' ' TEW_FECHOS"
	cQryDisp += ", ' ' TEW_RESCOD"
	cQryDisp += ", ' ' TFI_PERINI"
	cQryDisp += ", ' ' TFI_PERFIM"
	cQryDisp += ",COALESCE(("  // consulta OS aberta no MNT para inspeção pós locação e a data de finalização prevista
	cQryDisp += 	"SELECT STJ_OS.TJ_DTMPFIM " // utiliza os bloqueios do sistema para não realizar a alocação do equipamento 2x
	cQryDisp += 	"FROM "+RetSqlName('AA3')+" AA3_OS "  // como base para identificar a única OS de inspeção aberta pelo processo de Locação
	cQryDisp +=			"INNER JOIN "+RetSqlName('TEW')+" TEW_OS ON TEW_OS.TEW_FILIAL = '"+xFilial("TEW")+"' "
	cQryDisp += 											"AND TEW_OS.D_E_L_E_T_=' ' "
	cQryDisp += 											"AND (TEW_OS.TEW_TIPO='1' OR TEW_OS.TEW_TIPO=' ')"
	cQryDisp += 											"AND TEW_OS.TEW_BAATD=AA3_OS.AA3_NUMSER "
	cQryDisp += 											"AND TEW_OS.TEW_DTRFIM <> ' ' "
	cQryDisp += 											"AND TEW_OS.TEW_NUMOS <> ' ' "
	cQryDisp += 											"AND TEW_OS.TEW_FECHOS=' ' "
	cQryDisp +=			"LEFT JOIN "+RetSqlName('STJ')+" STJ_OS ON TEW_OS.TEW_TPOS='2' "
    cQryDisp +=                                                  "AND STJ_OS.TJ_FILIAL = AA3_OS.AA3_CDBMFL "
    cQryDisp +=                                                  "AND STJ_OS.TJ_ORDEM = TEW_OS.TEW_NUMOS "
    cQryDisp +=                                                  "AND STJ_OS.TJ_PLANO = '"+cPlanoMNT+"' "
    cQryDisp +=                                                  "AND STJ_OS.TJ_TIPOOS = 'B' "
    cQryDisp +=                                                  "AND STJ_OS.TJ_CODBEM = AA3_OS.AA3_CODBEM "
    cQryDisp +=                                                  "AND STJ_OS.TJ_SERVICO = '"+cSrvMnt+"' "
    cQryDisp +=                                                  "AND STJ_OS.D_E_L_E_T_=' ' "
	cQryDisp += 	"WHERE '"+DTOS(dDtRefe)+"' < '"+DTOS(dDtAlvo)+"' "
	cQryDisp +=			"AND AA3_OS.R_E_C_N_O_=AA3.R_E_C_N_O_ "
	cQryDisp +=			"AND AA3_OS.AA3_CODBEM <> ' ' "
	cQryDisp += "),' ') TJ_DTMPFIM"
	cQryDisp += " FROM "+RetSqlName('AA3')+" AA3 "
	cQryDisp +=  	"INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = AA3.AA3_CODPRO AND SB1.D_E_L_E_T_=' ' "
	cQryDisp += "WHERE AA3.D_E_L_E_T_ = ' ' AND AA3.AA3_EQALOC = '1' "

	If Len(aPrd) > 0
		cQryDisp += "AND AA3.AA3_CODPRO BETWEEN '"+aPrd[1]+"' AND '"+aPrd[2]+"' "  // adiciona condição de produto
	EndIf

	If Len(aEqto) > 0
		cQryDisp += "AND AA3.AA3_NUMSER BETWEEN '"+aEqto[1]+"' AND '"+aEqto[2]+"' "   // adiciona condição de equipamentos
	EndIf

	cQryDisp += "AND NOT EXISTS ("
	cQryDisp += 	"SELECT TEWEX.TEW_CODMV FROM "+RetSqlName('TEW')+" TEWEX "
	cQryDisp += 		"INNER JOIN "+RetSqlName('TFI')+" TFIEX ON TFIEX.TFI_FILIAL = '"+xFilial('TFI')+"' AND TFIEX.D_E_L_E_T_=' ' AND TFIEX.TFI_COD = TEWEX.TEW_CODEQU "
	cQryDisp += 		"INNER JOIN "+RetSqlName('TFL')+" TFL ON TFL.TFL_FILIAL = '"+xFilial('TFL')+"' AND TFL.TFL_CODIGO = TFIEX.TFI_CODPAI AND TFL.D_E_L_E_T_ = ' ' "
			If Len(aLocal) > 0
				cQryDisp += "AND TFL.TFL_LOCAL BETWEEN '"+aLocal[1]+"' AND '"+aLocal[2]+"' "     // adiciona condição de locais
			EndIf
	cQryDisp += 		"INNER JOIN "+RetSqlName('TFJ')+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial('TFJ')+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND TFJ.D_E_L_E_T_ = ' ' "
			If Len(aCliLoj) > 0
				cQryDisp += "AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT"+cConcat+"TFJ.TFJ_LOJA BETWEEN '"+aCliLoj[1]+"' AND '"+aCliLoj[2]+"' "  // adiciona condição de clientes
			EndIf
	cQryDisp += 		"LEFT JOIN "+RetSqlName('STJ')+" STJ ON TEWEX.TEW_TPOS='2' AND STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_ORDEM = TEWEX.TEW_NUMOS "
	cQryDisp += 													"AND STJ.TJ_PLANO = '"+cPlanoMNT+"' AND STJ.TJ_TIPOOS = 'B' AND STJ.TJ_CODBEM = AA3.AA3_CODBEM "
	cQryDisp += 													"AND STJ.TJ_SERVICO = '"+cSrvMnt+"' AND STJ.D_E_L_E_T_=' ' "
	cQryDisp += 	"WHERE TEWEX.D_E_L_E_T_=' ' AND TEWEX.TEW_FILIAL = '"+xFilial('TEW')+"' "
	cQryDisp += 	"AND TEWEX.TEW_BAATD=AA3.AA3_NUMSER AND ( TEWEX.TEW_TIPO = '1' OR TEWEX.TEW_TIPO = ' ')"

	cQryDisp += 	"AND(NOT(" // trata as condições que indicam não estar alocados no período ou seja... data inicial maior que o alvo
	cQryDisp += 		"(TEWEX.TEW_DTSEPA > '"+DTOS(dDtAlvo)+"')" //  ou data final menor que o alvo
	cQryDisp += 		"OR (TEWEX.TEW_NUMOS <> ' ' AND "
	cQryDisp += 				"((TEWEX.TEW_FECHOS <> ' ' AND TEWEX.TEW_FECHOS < '"+DTOS(dDtAlvo)+"')"
	cQryDisp += 				"OR (TEWEX.TEW_TPOS='2' AND TEWEX.TEW_FECHOS = ' ' AND '"+DTOS(dDtRefe)+"' < '"+DTOS(dDtAlvo)+"' AND STJ.TJ_DTMPFIM < '"+DTOS(dDtAlvo)+"')))"
	cQryDisp += 		"OR (TEWEX.TEW_NUMOS=' ' AND TEWEX.TEW_DTRFIM <> ' ' AND TEWEX.TEW_DTRFIM < '"+DTOS(dDtAlvo)+"')"
	cQryDisp += 		"OR (TEWEX.TEW_DTRFIM=' ' AND TFIEX.TFI_PERFIM <> ' ' AND TFIEX.TFI_PERFIM < '"+DTOS(dDtAlvo)+"' AND '"+DTOS(dDtRefe)+"' >= '"+DTOS(dDtAlvo)+"')"  // condição para verificar se o equipamento retorna antes do início da data alvo
	cQryDisp += 		"OR (TEWEX.TEW_DTRFIM=' ' AND TFIEX.TFI_PERFIM <> ' ' AND TFIEX.TFI_PERFIM < '"+DTOS(dDtRefe)+"' AND '"+DTOS(dDtRefe)+"' < '"+DTOS(dDtAlvo)+"')"
	cQryDisp += 		")"
	cQryDisp += 	"))"
						//------------- Reservas de equipamentos
	cQryDisp += "AND NOT EXISTS ( SELECT TEWEX.TEW_CODMV "
	cQryDisp += 				"FROM   "+RetSqlName('TEW')+" TEWEX "
	cQryDisp += 					"INNER JOIN "+RetSqlName('TFI')+" TFIEX ON TFIEX.TFI_FILIAL = '"+xFilial('TFI')+"' "
	cQryDisp += 											"AND TFIEX.TFI_RESERV <> ' ' "
	cQryDisp += 											"AND TFIEX.TFI_RESERV = TEWEX.TEW_RESCOD "
	cQryDisp += 					"INNER JOIN "+RetSqlName('TFL')+" TFL ON TFL.TFL_FILIAL = '"+xFilial('TFL')+"' AND TFL.TFL_CODIGO = TFIEX.TFI_CODPAI "
	cQryDisp +=												"AND TFL.D_E_L_E_T_ = ' ' "
			If Len(aLocal) > 0
				cQryDisp += "AND TFL.TFL_LOCAL BETWEEN '"+aLocal[1]+"' AND '"+aLocal[2]+"' "     // adiciona condição de locais
			EndIf
	cQryDisp += 					"INNER JOIN "+RetSqlName('TFJ')+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial('TFJ')+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQryDisp += 											"AND TFJ.D_E_L_E_T_ = ' ' "
			If Len(aCliLoj) > 0
				cQryDisp += "AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT"+cConcat+"TFJ.TFJ_LOJA BETWEEN '"+aCliLoj[1]+"' AND '"+aCliLoj[2]+"' "  // adiciona condição de clientes
			EndIf
	cQryDisp += 				"WHERE TEWEX.D_E_L_E_T_=' ' "
	cQryDisp += 						"AND TEWEX.TEW_FILIAL = '"+xFilial('TEW')+"' "
	cQryDisp += 						"AND TEWEX.TEW_BAATD = AA3.AA3_NUMSER "
	cQryDisp += 						"AND TEWEX.TEW_TIPO = '2' "
	cQryDisp += 						"AND TEWEX.TEW_MOTIVO <> '3' "

	cQryDisp += 						"AND ((TEWEX.TEW_DTRINI <= '"+DTOS(dDtAlvo)+"' "
	cQryDisp += 						"AND TEWEX.TEW_DTRFIM >= '"+DTOS(dDtAlvo)+"') "
	cQryDisp += 				")"
	cQryDisp += 		")"

Else
	// equipamentos disponíveis
	cQryDisp += " SELECT "
	cQryDisp += "'"+DTOS(dDtAlvo)+"' X_DIA"
	cQryDisp += ", AA3_FILIAL"
	cQryDisp += ", AA3_FILORI"
	cQryDisp += ", AA3_CODPRO"
	cQryDisp += ", SB1.B1_DESC AA3_DESPRO"
	cQryDisp += ", AA3_NUMSER"
	cQryDisp += ", AA3_MODELO"
	cQryDisp += ", AA3_CBASE"
	cQryDisp += ", AA3_ITEM"
	cQryDisp += ", AA3_CHAPA"
	cQryDisp += ", AA3_MANPRE"
	cQryDisp += ", AA3_EQ3"
	cQryDisp += ", ' ' TEW_CODMV"
	cQryDisp += ", ' ' TEW_TIPO"
	cQryDisp += ", ' ' TEW_DTSEPA"
	cQryDisp += ", ' ' TEW_DTRINI"
	cQryDisp += ", ' ' TEW_DTRFIM"
	cQryDisp += ", ' ' TEW_FECHOS"
	cQryDisp += ", ' ' TEW_RESCOD"
	cQryDisp += ", ' ' TFI_PERINI"
	cQryDisp += ", ' ' TFI_PERFIM"
	cQryDisp += " FROM "+RetSqlName('AA3')+" AA3 "
	cQryDisp +=  	"INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = AA3.AA3_CODPRO AND SB1.D_E_L_E_T_ = ' ' "
	cQryDisp +=  	"INNER JOIN "+RetSqlName('SB5')+" SB5 ON SB5.B5_FILIAL = '"+xFilial('SB5')+"' AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_=' ' "
	cQryDisp += "WHERE AA3.D_E_L_E_T_ = ' ' AND AA3.AA3_EQALOC = '1' AND SB5.B5_ISIDUNI <> '2'"

	If Len(aPrd) > 0
		cQryDisp += "AND AA3.AA3_CODPRO BETWEEN '"+aPrd[1]+"' AND '"+aPrd[2]+"' "  // adiciona condição de produto
	EndIf

	If Len(aEqto) > 0
		cQryDisp += "AND AA3.AA3_NUMSER BETWEEN '"+aEqto[1]+"' AND '"+aEqto[2]+"' "   // adiciona condição de equipamentos
	EndIf

	cQryDisp += "AND NOT EXISTS ( "
	cQryDisp += 	"SELECT TEWEX.TEW_CODMV FROM "+RetSqlName('TEW')+" TEWEX "
	cQryDisp += 		"INNER JOIN "+RetSqlName('TFI')+" TFIEX ON TFIEX.TFI_FILIAL = '"+xFilial('TFI')+"' AND TFIEX.TFI_COD = TEWEX.TEW_CODEQU "
	cQryDisp += 		"INNER JOIN "+RetSqlName('TFL')+" TFL ON TFL.TFL_FILIAL = '"+xFilial('TFL')+"' AND TFL.TFL_CODIGO = TFIEX.TFI_CODPAI AND TFL.D_E_L_E_T_ = ' ' "
			If Len(aLocal) > 0
				cQryDisp += "AND TFL.TFL_LOCAL BETWEEN '"+aLocal[1]+"' AND '"+aLocal[2]+"' "     // adiciona condição de locais
			EndIf
	cQryDisp += 		"INNER JOIN "+RetSqlName('TFJ')+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial('TFJ')+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND TFJ.D_E_L_E_T_ = ' ' "
			If Len(aCliLoj) > 0
				cQryDisp += "AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT"+cConcat+"TFJ.TFJ_LOJA BETWEEN '"+aCliLoj[1]+"' AND '"+aCliLoj[2]+"' "  // adiciona condição de clientes
			EndIf
	cQryDisp += 	"WHERE TEWEX.D_E_L_E_T_ = ' ' AND TEWEX.TEW_FILIAL = '"+xFilial('TEW')+"' "
	cQryDisp += 	"AND TEWEX.TEW_BAATD = AA3.AA3_NUMSER AND ( TEWEX.TEW_TIPO = '1' OR TEWEX.TEW_TIPO = ' ' ) "

	cQryDisp += 	"AND " // -- intervalo movimentação tabela TEW
	cQryDisp += 	"( ( TEWEX.TEW_DTSEPA <= '"+DTOS(dDtAlvo)+"' AND " // -- data inicial entre o período da alocação
	cQryDisp += 		" ( CASE WHEN TEWEX.TEW_FECHOS IS NULL OR TEWEX.TEW_FECHOS = '"+Space(08)+"' "
	cQryDisp += 		"THEN ( CASE WHEN TEWEX.TEW_DTRFIM IS NULL OR TEWEX.TEW_DTRFIM = '"+Space(08)+"' "
	cQryDisp += 				"THEN ( CASE WHEN TFIEX.TFI_PERFIM < '"+DTOS(dDtRefe)+"' "
	cQryDisp += 						"THEN '"+DTOS(dDtRefe)+"' "
	cQryDisp += 						"ELSE TFIEX.TFI_PERFIM END ) "
	cQryDisp += 				"ELSE TEWEX.TEW_DTRFIM END ) "
	cQryDisp += 		"ELSE TEWEX.TEW_FECHOS "  //  -- data final da locação entre o período
	cQryDisp += 		"END ) >= '"+DTOS(dDtAlvo)+"' "
	cQryDisp += 		") "
						// -- intervalo planejado da alocação tabela TFI
	cQryDisp += 		"OR ( TEWEX.TEW_DTSEPA <> '"+Space(08)+"' AND "
	cQryDisp += 		" TEWEX.TEW_DTRINI = '"+Space(08)+"' AND "
	cQryDisp +=				"TFIEX.TFI_PERINI <= '"+DTOS(dDtAlvo)+"' AND " // -- data inicial entre o período planejado da locação
	cQryDisp += 		"TFIEX.TFI_PERFIM >= '"+DTOS(dDtAlvo)+"' ) " // -- data final da locação entre o período planejado da locação
	cQryDisp += 	") "
	cQryDisp += ") "
						//------------- Reservas de equipamentos
	cQryDisp += "AND NOT EXISTS ( SELECT TEWEX.TEW_CODMV "
	cQryDisp += 				"FROM   "+RetSqlName('TEW')+" TEWEX "
	cQryDisp += 					"INNER JOIN "+RetSqlName('TFI')+" TFIEX ON TFIEX.TFI_FILIAL = '"+xFilial('TFI')+"' "
	cQryDisp += 											"AND TFIEX.TFI_RESERV <> ' ' "
	cQryDisp += 											"AND TFIEX.TFI_RESERV = TEWEX.TEW_RESCOD "
	cQryDisp += 					"INNER JOIN "+RetSqlName('TFL')+" TFL ON TFL.TFL_FILIAL = '"+xFilial('TFL')+"' AND TFL.TFL_CODIGO = TFIEX.TFI_CODPAI "
	cQryDisp +=												"AND TFL.D_E_L_E_T_ = ' ' "
			If Len(aLocal) > 0
				cQryDisp += "AND TFL.TFL_LOCAL BETWEEN '"+aLocal[1]+"' AND '"+aLocal[2]+"' "     // adiciona condição de locais
			EndIf
	cQryDisp += 					"INNER JOIN "+RetSqlName('TFJ')+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial('TFJ')+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQryDisp += 											"AND TFJ.D_E_L_E_T_ = ' ' "
			If Len(aCliLoj) > 0
				cQryDisp += "AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT"+cConcat+"TFJ.TFJ_LOJA BETWEEN '"+aCliLoj[1]+"' AND '"+aCliLoj[2]+"' "  // adiciona condição de clientes
			EndIf
	cQryDisp += 				"WHERE TEWEX.D_E_L_E_T_ = ' ' "
	cQryDisp += 						"AND TEWEX.TEW_FILIAL = '"+xFilial('TEW')+"' "
	cQryDisp += 						"AND TEWEX.TEW_BAATD = AA3.AA3_NUMSER "
	cQryDisp += 						"AND TEWEX.TEW_TIPO = '2' "
	cQryDisp += 						"AND TEWEX.TEW_MOTIVO <> '3' "

	cQryDisp += 						"AND ( ( TEWEX.TEW_DTRINI <= '"+DTOS(dDtAlvo)+"' "
	cQryDisp += 						"AND TEWEX.TEW_DTRFIM >= '"+DTOS(dDtAlvo)+"' ) "
	cQryDisp += 				") "
	cQryDisp += 		") "
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180Aloc
	Consulta os equipamentos alocados/reservados no período
@sample 	At180Aloc()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At180Aloc(cQryAloc, dDtRefe, nModRet, dDtAlvo, aEqto, aLocal, aPrd, aCliLoj)

Local lRet       := .T.
Local lIntTecMnt := ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local cConcat	:= If(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+") //Sinal de concatenação (Igual ao ADMXFUN)
DEFAULT cQryAloc := ''
DEFAULT dDtRefe  := dDataBase
DEFAULT aEqto    := {}
DEFAULT aLocal   := {}
DEFAULT aPrd     := {}
DEFAULT aCliLoj  := {}

If lIntTecMnt
	cQryAloc += " SELECT "
	cQryAloc += 	"'"+DTOS(dDtAlvo)+"' X_DIA "
	cQryAloc += 	", AA3_FILIAL"
	cQryAloc +=	", AA3_FILORI"
	cQryAloc += 	", AA3_CODPRO"
	cQryAloc += 	", SB1.B1_DESC AA3_DESPRO"
	cQryAloc += 	", AA3_NUMSER"
	cQryAloc += 	", AA3_MODELO"
	cQryAloc += 	", AA3_CBASE"
	cQryAloc += 	", AA3_ITEM"
	cQryAloc += 	", AA3_CHAPA"
	cQryAloc += 	", AA3_MANPRE"
	cQryAloc +=   ", AA3_EQ3"
	cQryAloc += 	", TEW.TEW_CODMV"
	cQryAloc += 	", TEW.TEW_TIPO"
	cQryAloc += 	", TEW.TEW_DTSEPA"
	cQryAloc += 	", TEW.TEW_DTRINI"
	cQryAloc += 	", TEW.TEW_DTRFIM"
	cQryAloc += 	", TEW.TEW_FECHOS"
	cQryAloc += 	", TEW.TEW_RESCOD"
	cQryAloc += 	", TFI.TFI_PERINI"
	cQryAloc += 	", TFI.TFI_PERFIM"
	cQryAloc += 	", STJ.TJ_DTMPFIM"
	cQryAloc += " FROM "+RetSqlName('AA3')+" AA3 "
	cQryAloc +=  	"INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = AA3.AA3_CODPRO AND SB1.D_E_L_E_T_ = ' ' "
	cQryAloc +=  	"INNER JOIN "+RetSqlName('SB5')+" SB5 ON SB5.B5_FILIAL = '"+xFilial('SB5')+"' AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_=' ' "
	cQryAloc += 	"LEFT JOIN "+RetSqlName('TEW')+" TEW ON "
	cQryAloc += 		"TEW.TEW_FILIAL = '"+xFilial('TEW')+"' AND "
	cQryAloc += 		"TEW.TEW_BAATD = AA3.AA3_NUMSER AND "
	cQryAloc += 		"TEW.D_E_L_E_T_ = ' ' "
	cQryAloc += 	"LEFT JOIN "+RetSqlName('TFI')+" TFI ON "
	cQryAloc += 		"TFI.TFI_FILIAL = '"+xFilial('TFI')+"' AND "
	cQryAloc += 		"((TEW.TEW_CODEQU = '"+space(TamSX3("TEW_CODEQU")[1])+"' AND TEW.TEW_RESCOD = TFI.TFI_RESERV) OR "
	cQryAloc += 		"TEW.TEW_CODEQU = TFI.TFI_COD) AND "
	cQryAloc += 		"TFI.D_E_L_E_T_ = ' ' "
	cQryAloc += 	"LEFT JOIN "+RetSqlName('TFL')+" TFL ON TFL.TFL_FILIAL = '"+xFilial('TFL')+"' AND TFL.TFL_CODIGO = TFI.TFI_CODPAI "
	cQryAloc +=												"AND TFL.D_E_L_E_T_ = ' ' "
			If Len(aLocal) > 0  // adiciona condição de locais
				cQryAloc += "AND TFL.TFL_LOCAL BETWEEN '"+aLocal[1]+"' AND '"+aLocal[2]+"' "
			EndIf

	cQryAloc += 	"LEFT JOIN "+RetSqlName('TFJ')+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial('TFJ')+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQryAloc += 											"AND TFJ.D_E_L_E_T_ = ' ' "
			If Len(aCliLoj) > 0 // adiciona condição de clientes
				cQryAloc += "AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT||TFJ.TFJ_LOJA BETWEEN '"+aCliLoj[1]+"' AND '"+aCliLoj[2]+"' "
			EndIf
	cQryAloc += 	"LEFT JOIN "+RetSqlName('STJ')+" STJ ON TEW.TEW_TPOS='2' AND STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_ORDEM = TEW.TEW_NUMOS "

	cQryAloc += "WHERE AA3.AA3_FILIAL = '"+xFilial('AA3')+"' AND AA3.AA3_EQALOC = '1' AND AA3.D_E_L_E_T_ = ' ' AND SB5.B5_ISIDUNI <> '2'"

			If Len(aPrd) > 0  // adiciona condição de produto
				cQryAloc += "AND AA3.AA3_CODPRO BETWEEN '"+aPrd[1]+"' AND '"+aPrd[2]+"' "
			EndIf

			If Len(aEqto) > 0   // adiciona condição de equipamentos
				cQryAloc += "AND AA3.AA3_NUMSER BETWEEN '"+aEqto[1]+"' AND '"+aEqto[2]+"' "
			EndIf
	cQryAloc +=			"AND TEW.TEW_BAATD <> ' ' "
	cQryAloc += 		"AND "
	cQryAloc += 		"(" // verifica as alocações que compreendam a data alvo >> início alocação | data alvo | fim alocação
	cQryAloc += 			"(( TEW.TEW_TIPO = '1' OR TEW.TEW_TIPO = ' ') AND "
	cQryAloc += 				"TEW.TEW_DTSEPA <= '"+DTOS(dDtAlvo)+"' AND ("
	cQryAloc += 				"(TEW.TEW_NUMOS <> ' ' AND ((TEW.TEW_FECHOS <> ' ' AND TEW.TEW_FECHOS >= '"+DTOS(dDtAlvo)+"'))"
	cQryAloc += 				" OR ( TEW.TEW_TPOS='2' AND TEW.TEW_FECHOS=' ' AND STJ.TJ_DTMPFIM >= '"+DTOS(dDtAlvo)+"'))"
	cQryAloc += 				" OR(TEW.TEW_FECHOS = ' ' AND (TEW.TEW_DTRFIM = ' ' OR TEW.TEW_DTRFIM >= '"+DTOS(dDtAlvo)+"'))"
	cQryAloc += 				" OR((TEW.TEW_DTRFIM = ' ' AND TFI.TFI_PERFIM >= '"+DTOS(dDtRefe)+"' AND TFI.TFI_PERFIM >= '"+DTOS(dDtAlvo)+"') OR "
	cQryAloc += 				"(TEW.TEW_DTRFIM = ' ' AND TFI.TFI_PERFIM < '"+DTOS(dDtRefe)+"' AND '"+DTOS(dDtRefe)+"' >= '"+DTOS(dDtAlvo)+"')))"
	cQryAloc += 			")"
	cQryAloc += 			"OR" // verifica as reservas para a data alvo
	cQryAloc += 			"( TEW.TEW_TIPO = '2' AND TEW.TEW_MOTIVO <> '3' AND "
	cQryAloc += 				"'"+DTOS(dDtAlvo)+"' BETWEEN TEW.TEW_DTRINI AND TEW.TEW_DTRFIM "
	cQryAloc += 				"AND NOT EXISTS ("  // não exista Alocação que compreenda a data alvo >> início alocação | data alvo | fim alocação
	cQryAloc += 					"SELECT TEWIN.TEW_CODMV "
	cQryAloc += 					"FROM "+RetSqlName('TEW')+" TEWIN "
	cQryAloc += 						"INNER JOIN "+RetSqlName('TFI')+" TFIIN ON TFIIN.TFI_FILIAL = '"+xFilial('TFI')+"' AND TFIIN.TFI_COD = TEWIN.TEW_CODEQU "
	cQryAloc += 										"AND TFIIN.D_E_L_E_T_ = ' ' "
	cQryAloc += 					"WHERE TEWIN.TEW_FILIAL = '"+xFilial('TEW')+"' AND TEWIN.D_E_L_E_T_ = ' ' AND "
	cQryAloc += 						"TEWIN.TEW_BAATD = TEW.TEW_BAATD AND "
	cQryAloc += 						"((TEWIN.TEW_TIPO = '1' OR TEWIN.TEW_TIPO = ' ') AND "
	cQryAloc += 						"TEWIN.TEW_DTSEPA <= '"+DTOS(dDtAlvo)+"' AND "
	cQryAloc += 						"(TEWIN.TEW_FECHOS = '"+space(8)+"' OR TEWIN.TEW_FECHOS >= '"+DTOS(dDtAlvo)+"') AND "
	cQryAloc += 						"(TEWIN.TEW_FECHOS = ' ' AND (TEWIN.TEW_DTRFIM = '"+space(8)+"' OR TEWIN.TEW_DTRFIM >= '"+DTOS(dDtAlvo)+"')) AND "
	cQryAloc += 						"((TEWIN.TEW_DTRFIM = ' ' AND TFIIN.TFI_PERFIM >= '"+DTOS(dDtRefe)+"' AND TFIIN.TFI_PERFIM >= '"+DTOS(dDtAlvo)+"') OR "
	cQryAloc += 						"(TEWIN.TEW_DTRFIM = ' ' AND TFIIN.TFI_PERFIM < '"+DTOS(dDtRefe)+"' AND '"+DTOS(dDtRefe)+"' >= '"+DTOS(dDtAlvo)+"'))"
	cQryAloc += 						")"
	cQryAloc += 				")"
	cQryAloc += 			")"
	cQryAloc += 		")"
Else
	cQryAloc += " SELECT "
	cQryAloc += 	"'"+DTOS(dDtAlvo)+"' X_DIA "
	cQryAloc += 	", AA3_FILIAL"
	cQryAloc += 	", AA3_FILORI"
	cQryAloc += 	", AA3_CODPRO"
	cQryAloc += 	", SB1.B1_DESC AA3_DESPRO"
	cQryAloc += 	", AA3_NUMSER"
	cQryAloc += 	", AA3_MODELO"
	cQryAloc += 	", AA3_CBASE"
	cQryAloc += 	", AA3_ITEM"
	cQryAloc += 	", AA3_CHAPA"
	cQryAloc += 	", AA3_MANPRE"
	cQryAloc +=     ", AA3_EQ3"
	cQryAloc += 	", TEW.TEW_CODMV"
	cQryAloc += 	", TEW.TEW_TIPO"
	cQryAloc += 	", TEW.TEW_DTSEPA"
	cQryAloc += 	", TEW.TEW_DTRINI"
	cQryAloc += 	", TEW.TEW_DTRFIM"
	cQryAloc += 	", TEW.TEW_FECHOS"
	cQryAloc += 	", TEW.TEW_RESCOD"
	cQryAloc += 	", TFI.TFI_PERINI"
	cQryAloc += 	", TFI.TFI_PERFIM"
	cQryAloc += " FROM "+RetSqlName('AA3')+" AA3 "
	cQryAloc +=  	"INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = AA3.AA3_CODPRO AND SB1.D_E_L_E_T_ = ' ' "
	cQryAloc +=  	"INNER JOIN "+RetSqlName('SB5')+" SB5 ON SB5.B5_FILIAL = '"+xFilial('SB5')+"' AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_=' ' "
	cQryAloc += 	"LEFT JOIN "+RetSqlName('TEW')+" TEW ON "
	cQryAloc += 		"TEW.TEW_FILIAL = '"+xFilial('TEW')+"' AND "
	cQryAloc += 		"TEW.TEW_BAATD = AA3.AA3_NUMSER AND "
	cQryAloc += 		"TEW.D_E_L_E_T_ = ' ' "
	cQryAloc += 	"LEFT JOIN "+RetSqlName('TFI')+" TFI ON "
	cQryAloc += 		"TFI.TFI_FILIAL = '"+xFilial('TFI')+"' AND "
	cQryAloc += 		"((TEW.TEW_CODEQU = '"+space(TamSX3("TEW_CODEQU")[1])+"' AND TEW.TEW_RESCOD = TFI.TFI_RESERV) OR "
	cQryAloc += 		"TEW.TEW_CODEQU = TFI.TFI_COD) AND "
	cQryAloc += 		"TFI.D_E_L_E_T_ = ' ' "
	cQryAloc += 	"LEFT JOIN "+RetSqlName('TFL')+" TFL ON TFL.TFL_FILIAL = '"+xFilial('TFL')+"' AND TFL.TFL_CODIGO = TFI.TFI_CODPAI "
	cQryAloc +=												"AND TFL.D_E_L_E_T_ = ' ' "
			If Len(aLocal) > 0  // adiciona condição de locais
				cQryAloc += "AND TFL.TFL_LOCAL BETWEEN '"+aLocal[1]+"' AND '"+aLocal[2]+"' "
			EndIf

	cQryAloc += 	"LEFT JOIN "+RetSqlName('TFJ')+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial('TFJ')+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQryAloc += 											"AND TFJ.D_E_L_E_T_ = ' ' "
			If Len(aCliLoj) > 0 // adiciona condição de clientes
				cQryAloc += "AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT||TFJ.TFJ_LOJA BETWEEN '"+aCliLoj[1]+"' AND '"+aCliLoj[2]+"' "
			EndIf

	cQryAloc += "WHERE AA3.AA3_FILIAL = '"+xFilial('AA3')+"' AND AA3.AA3_EQALOC = '1' AND AA3.D_E_L_E_T_ = ' ' AND SB5.B5_ISIDUNI <> '2'"

			If Len(aPrd) > 0  // adiciona condição de produto
				cQryAloc += "AND AA3.AA3_CODPRO BETWEEN '"+aPrd[1]+"' AND '"+aPrd[2]+"' "
			EndIf

			If Len(aEqto) > 0   // adiciona condição de equipamentos
				cQryAloc += "AND AA3.AA3_NUMSER BETWEEN '"+aEqto[1]+"' AND '"+aEqto[2]+"' "
			EndIf
	cQryAloc +=			"AND TEW.TEW_BAATD <> ' ' "
	cQryAloc += 		"AND "
	cQryAloc += 		"( ( TEW.TEW_TIPO = '2' AND TEW.TEW_MOTIVO <> '3' AND "
	cQryAloc += 				"'"+DTOS(dDtAlvo)+"' BETWEEN TEW.TEW_DTRINI AND TEW.TEW_DTRFIM "
	cQryAloc += 				"AND NOT EXISTS ("
	cQryAloc += 					"SELECT TEWIN.TEW_CODMV "
	cQryAloc += 					"FROM "+RetSqlName('TEW')+" TEWIN "
	cQryAloc += 						"INNER JOIN "+RetSqlName('TFI')+" TFIIN ON TFIIN.TFI_FILIAL = '"+xFilial('TFI')+"' AND TFIIN.TFI_COD = TEWIN.TEW_CODEQU "
	cQryAloc += 										"AND TFIIN.D_E_L_E_T_ = ' ' "
	cQryAloc += 					"WHERE TEWIN.TEW_FILIAL = '"+xFilial('TEW')+"' AND TEWIN.D_E_L_E_T_ = ' ' AND "
	cQryAloc += 						"TEWIN.TEW_BAATD = TEW.TEW_BAATD AND "
	cQryAloc += 						"( ( TEWIN.TEW_TIPO = '1' OR TEWIN.TEW_TIPO = ' ' ) AND "
	cQryAloc += 						"TEWIN.TEW_DTSEPA <= '"+DTOS(dDtAlvo)+"' AND "
	cQryAloc += 						"(TEWIN.TEW_FECHOS = '"+space(8)+"' OR TEWIN.TEW_FECHOS >= '"+DTOS(dDtAlvo)+"') AND "
	cQryAloc += 						"(TEWIN.TEW_DTRFIM = '"+space(8)+"' OR TEWIN.TEW_DTRFIM >= '"+DTOS(dDtAlvo)+"') AND "
	cQryAloc += 						"((TFIIN.TFI_PERFIM >= '"+DTOS(dDtRefe)+"' AND TFIIN.TFI_PERFIM >= '"+DTOS(dDtAlvo)+"') OR "
	cQryAloc += 						"(TFIIN.TFI_PERFIM < '"+DTOS(dDtRefe)+"' AND '"+DTOS(dDtRefe)+"' >= '"+DTOS(dDtAlvo)+"' ))"
	cQryAloc += 					")"
	cQryAloc += 				")"
	cQryAloc += 			")"
	cQryAloc += 			"OR"
	cQryAloc += 			"( ( TEW.TEW_TIPO = '1' OR TEW.TEW_TIPO = ' ' ) AND "
	cQryAloc += 				"TEW.TEW_DTSEPA <= '"+DTOS(dDtAlvo)+"' AND "
	cQryAloc += 				"(TEW.TEW_FECHOS = '"+space(8)+"' OR TEW.TEW_FECHOS >= '"+DTOS(dDtAlvo)+"') AND "
	cQryAloc += 				"(TEW.TEW_DTRFIM = '"+space(8)+"' OR TEW.TEW_DTRFIM >= '"+DTOS(dDtAlvo)+"') AND "
	cQryAloc += 				"((TFI.TFI_PERFIM >= '"+DTOS(dDtRefe)+"' AND TFI.TFI_PERFIM >= '"+DTOS(dDtAlvo)+"') OR "
	cQryAloc += 				"(TFI.TFI_PERFIM < '"+DTOS(dDtRefe)+"' AND '"+DTOS(dDtRefe)+"' >= '"+DTOS(dDtAlvo)+"' ))"
	cQryAloc += 				")"
	cQryAloc += 			")"
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180xDisp
	Identifica os itens disponíveis em estoque em determinada faixa de tempo
@sample 	At180xDisp()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180xDisp( xListProd, dDatIni, dDatFim, dDtAtual, cCposSelect, lOnlyString, cAddWhere )

Local cTmpQuery     := Nil
Local cStrQry       := ''
Local lUseIn        := .F.
Local cProdFilter   := ''
Local cCodigosTWS 	:= ''
Local cLastTWS 		:= ''
Local lFoundTWS 	:= .F.
Local lUseInTWS 	:= .F.
Local nTamFilSB1 	:= AtTamFilTab( "SB1" )
Local nTamFilTEW 	:= AtTamFilTab( "TEW" )
Local nTamFilAA3 	:= AtTamFilTab( "AA3" )
Local nTamFilSA1 	:= AtTamFilTab( "SA1" )
Local nZ 			:= 0
Local cEquipSt		:= ''
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular

DEFAULT xListProd 	:= ''
DEFAULT dDatIni 		:= CTOD('')
DEFAULT dDatFim 		:= CTOD('')
DEFAULT dDtAtual 	:= dDataBase
DEFAULT cCposSelect 	:= "AA3.*,SB1.B1_DESC AA3_DESPRO "
DEFAULT lOnlyString 	:= .F.
DEFAULT cAddWhere		:= ""

DbSelectArea('TWS')
TWS->( DbSetOrder( 2 ) ) // TWS_FILIAL+TWS_FILPRD+TWS_PRDCOD

If (ExistBlock("At180DispSt"))
	lBlockSt := ExecBlock("At180DispSt",.F.,.F.)
	If ValType(lBlockSt) == "L" .AND. (lBlockSt) 
		cEquipSt := "AND AA3_STATUS <> '03' "
	EndIf
EndIf  

If ValType(xListProd) == 'A' .And. Len(xListProd) >= 1

	// procura os códigos de produtos associados com a
	For nZ := 1 To Len( xListProd )
		If TWS->(DbSeek( xFilial("TWS")+xFilial("SB1")+xListProd[nZ] ))

			lFoundTWS := .T.
			cCodigosTWS += TWS->TWS_CODIGO+'#'
			cLastTWS := TWS->TWS_CODIGO

			While TWS->( !EOF() ) .And. TWS->TWS_CODIGO == cLastTWS
				cProdFilter += ( TWS->(TWS_FILPRD+TWS_PRDCOD) + '#')
				TWS->(DbSkip())
			End
		EndIf
	Next nZ

	If !lFoundTWS
		AEval( xListProd, {|x| cProdFilter += ( x + '#') } )
	EndIf

	lUseIn := .T.
	lUseInTWS := .T.

ElseIf ValType(xListProd) == 'C'

	If TWS->(DbSeek( xFilial('TWS')+xFilial('SB1')+xListProd ))

		lFoundTWS := .T.
		cCodigosTWS := TWS->TWS_CODIGO
		cLastTWS := TWS->TWS_CODIGO

		While TWS->( !EOF() ) .And. TWS->TWS_CODIGO == cLastTWS
			cProdFilter += ( TWS->(TWS_FILPRD+TWS_PRDCOD) + '#')
			TWS->(DbSkip())
		End

		lUseIn := .T.
	Else
		cProdFilter := xListProd
	EndIf

EndIf
// Adiciona um espaço quando não existir para não confundir com terminação do nome do campo e from
If Right( cCposSelect, 1 ) <> ' '
	cCposSelect += ' '
EndIf

If !Empty(cProdFilter) .And. !Empty(dDatIni) .And. !Empty(dDatFim)

	If lUseIn
		cProdFilter := "IN ('" + StrTran( SubStr( cProdFilter, 1, Len(cProdFilter)-1), "#", "','" ) + "' ) "
	Else
		cProdFilter := "= '" + cProdFilter+ "' "
	EndIf

	If lUseInTWS
		cCodigosTWS := "IN ('" + StrTran( SubStr( cCodigosTWS, 1, Len(cCodigosTWS)-1), "#", "','" ) + "' ) "
	Else
		cCodigosTWS := "= '"+cCodigosTWS+"' "
	EndIf

	If lGSOpTri //Verifica se a operação triangular está ativa e pega valores do AA3_FILORI
		cEquipAA3 := "AND SUBSTRING( AA3.AA3_FILIAL, 1, "+cValToChar(nTamFilAA3)+") = SUBSTRING( AA3.AA3_FILORI, 1, "+cValToChar(nTamFilAA3)+") " // -- filial da AA3
		cEquipSA1 := "AND SUBSTRING(SA1.A1_FILIAL, 1, "+cValToChar(nTamFilSA1)+") = SUBSTRING( AA3.AA3_FILORI, 1, "+cValToChar(nTamFilSA1)+") " // -- filial da SA1
	Else
		cEquipAA3 := "AND AA3.AA3_FILIAL = '"+xFilial('AA3')+"'" // -- filial da AA3
		cEquipSA1 := "AND SA1.A1_FILIAL = '"+xFilial('SA1')+"' " // -- filial da SA1
	EndIf

	cStrQry += "SELECT "
	cStrQry += cCposSelect
	cStrQry += "FROM "+RetSqlName("SB1")+" SB1 "
	cStrQry += 		"INNER JOIN "+RetSqlName('AA3')+ " AA3 ON "
	cStrQry += 									"AA3.AA3_EQALOC = '1' "
	cStrQry += 									"AND AA3.AA3_CODPRO = SB1.B1_COD "
	cStrQry += 									"AND AA3.AA3_MSBLQL <> '1' "  
	cStrQry +=									cEquipSt						
	cStrQry += 									cEquipAA3
	cStrQry += 									"AND AA3.D_E_L_E_T_= ' ' "
	cStrQry +=  	"INNER JOIN "+RetSqlName('SB5')+" SB5 ON "
	cStrQry += 									"SB5.B5_FILIAL = '"+xFilial('SB5')+"' "  // -- filial da SB1
	cStrQry += 									"AND SB5.B5_COD = AA3.AA3_CODPRO "
	cStrQry += 									"AND SB5.D_E_L_E_T_= ' ' "
	cStrQry +=		"LEFT JOIN "+RetSqlName('SA1')+ " SA1 ON "
	cStrQry +=									"SA1.D_E_L_E_T_=' ' "
	cStrQry +=									"AND SA1.A1_COD = AA3.AA3_CODCLI "
	cStrQry +=									"AND SA1.A1_LOJA = AA3.AA3_LOJA "
	cStrQry +=									cEquipSA1
	If lGSOpTri .And. lFoundTWS
		cStrQry +=	"LEFT JOIN "+RetSqlName('TWS')+ " TWS ON "
		cStrQry +=								"TWS.D_E_L_E_T_=' '"
		cStrQry +=								"AND TWS.TWS_FILIAL = ' ' " // -- filial da TWS
		cStrQry +=								"AND AA3.AA3_CODPRO = TWS.TWS_PRDCOD "
		cStrQry +=								"AND TWS.TWS_FILPRD = AA3.AA3_FILORI "
		cStrQry +=								"AND TWS.TWS_CODIGO " + cCodigosTWS
	EndIf
	cStrQry += "WHERE " + cAddWhere + " SB1.D_E_L_E_T_=' ' AND SB5.B5_ISIDUNI <> '2'" // -- não restringe filial da SB1 de propósito

	// -- filtra o código do produto
	cStrQry += " AND ("
	If lFoundTWS
		cStrQry += 		"( SB1.B1_FILIAL || SB1.B1_COD = TWS.TWS_FILPRD || TWS.TWS_PRDCOD)"
	Else
		cStrQry +=      " SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' AND  SB1.B1_COD "+cProdFilter+"  " //-- filial da SB1 combinada com o código do produto
	EndIf
	cStrQry += 		") "

	// -- reservado
	cStrQry += "AND NOT EXISTS ( " + At180xIsRes( dDatIni, dDatFim, dDtAtual ) + ")"  // busca a condição chave para identificar os reservados

	// -- separado ou alocado no período
	cStrQry += "AND NOT EXISTS ( " + At180xIsAloc( dDatIni, dDatFim, dDtAtual ) + ")" // busca a condição chave para identificar os alocados

	cStrQry := ChangeQuery(cStrQry)

	If lOnlyString
		cTmpQuery := cStrQry
	Else
		cTmpQuery := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cStrQry ), cTmpQuery, .T., .T. )
	EndIf

EndIf

Return cTmpQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180CLose
	Remove os índices na tabela temporária
@sample 	At180CLose()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180CLose( cTabDelIdx )

Local nAt1       := aScan( aTabIndex, {|z| z[1]==cTabDelIdx} )
Local nAt2       := 0

If nAt1 > 0

	(cTabDelIdx)->(DbCloseArea())
	Ferase(cTabDelIdx+GetDbExtension())

	For nAt2 := 1 To Len(aTabIndex[nAt1,2])
		Ferase(aTabIndex[nAt1,2,nAt2]+OrDbagExt())
	Next nAt2

EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180xIsAloc
	Monta a condição para filtro dos itens alocados considera a tabela AA3 como referência
@sample 	At180xIsAloc()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At180xIsAloc( dDatIni, dDatFim, dDtAtual )

Local cStrQry := ""
Local lIntTecMnt := ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local nTamFilSB5 := AtTamFilTab( "SB5" )

If lIntTecMnt
	cStrQry += 		"SELECT TEW.TEW_CODMV "
	cStrQry += 		"FROM "+RetSqlName('TEW')+" TEW "
	cStrQry += 			"INNER JOIN "+RetSqlName('TFI')+" TFI ON "
	cStrQry += 											"TFI.TFI_FILIAL = TEW.TEW_FILIAL " // -- filial da TEW no mesmo nível que TFI
	cStrQry += 											"AND TFI.TFI_COD = TEW.TEW_CODEQU "
	cStrQry += 											"AND TFI.D_E_L_E_T_=' ' "
	cStrQry += 			"LEFT JOIN "+RetSqlName("STJ")+" STJ ON "
	cStrQry += 											"TEW.TEW_TPOS='2' "
	cStrQry += 											"AND STJ.TJ_FILIAL=TEW.TEW_FILIAL " // -- filial da TEW no mesmo nível que STJ
	cStrQry += 											"AND STJ.TJ_ORDEM=TEW.TEW_NUMOS "
	cStrQry += 											"AND STJ.D_E_L_E_T_=' ' "
	cStrQry +=  		"INNER JOIN "+RetSqlName('SB5')+" SB5 ON "
	cStrQry += 											"SB5.B5_FILIAL = '"+xFilial('SB5')+"' " 
	cStrQry += 											"AND SB5.B5_COD = AA3.AA3_CODPRO "
	cStrQry += 											"AND SB5.D_E_L_E_T_= ' ' "
	cStrQry += 		"WHERE " // -- não restringe a filial pois a base pode estar alocada em outras filiais
	cStrQry += 			"TEW.D_E_L_E_T_ = ' ' AND SB5.B5_ISIDUNI <> '2'"
	cStrQry += 			"AND AA3.AA3_FILORI = TEW.TEW_FILBAT " // -- restringe os resultados das filiais da TFI e TEW tbm
	cStrQry += 			"AND AA3.AA3_NUMSER = TEW.TEW_BAATD "
	cStrQry += 			"AND ( TEW.TEW_TIPO = '1' OR TEW.TEW_TIPO = ' ')"
	
				// -- intervalo movimentação tabela TEW
	cStrQry += 			"AND (" // -- procura os itens que não atendam a situação: < data fim | ALOCACAO ALVO | data separação >
	cStrQry += 				"(NOT("
	cStrQry += 					"(TEW.TEW_DTSEPA > '"+DTOS(dDatFim)+"')"
	cStrQry += 					"OR (TEW.TEW_NUMOS <> ' ' AND TEW.TEW_FECHOS <> ' ' AND TEW.TEW_FECHOS <= '"+DTOS(dDatIni)+"' )"
	cStrQry += 					"OR (TEW.TEW_NUMOS <> ' ' AND TEW.TEW_TPOS = '2' AND TEW.TEW_FECHOS = ' ' AND STJ.TJ_DTMPFIM < '"+DTOS(dDatIni)+"' AND STJ.TJ_DTMPFIM > '"+DTOS(dDtAtual)+"' )"
	cStrQry += 					"OR (TEW.TEW_NUMOS = ' ' AND TEW.TEW_DTRFIM <> ' ' AND TEW.TEW_DTRFIM <= '"+DTOS(dDatIni)+"')"
	cStrQry += 					"OR (TEW.TEW_DTRFIM = ' ' AND TFI.TFI_PERFIM <> ' ' AND TFI.TFI_PERFIM >= '"+DTOS(dDtAtual)+"' AND TFI.TFI_PERFIM < '"+DTOS(dDatIni)+"')"
	cStrQry += 					"OR (TEW.TEW_DTRFIM = ' ' AND TFI.TFI_PERFIM <> ' ' AND TFI.TFI_PERFIM < '"+DTOS(dDtAtual)+"' AND '"+DTOS(dDtAtual)+"' < '"+DTOS(dDatIni)+"')"
	cStrQry += 					"OR (TEW.TEW_DTRFIM = ' ' AND TFI.TFI_PERFIM = ' ' AND  TEW.TEW_DTSEPA <= '"+DTOS(dDatIni)+"')"
	cStrQry += 				"))"
	cStrQry += 			")"
Else
	cStrQry += 		"SELECT TEW.TEW_CODMV "
	cStrQry += 		"FROM "+RetSqlName('TEW')+" TEW "
	cStrQry += 			"INNER JOIN "+RetSqlName('TFI')+" TFI ON TFI.TFI_FILIAL = '"+xFilial('TFI')+"' AND TFI.TFI_COD = TEW.TEW_CODEQU "
	cStrQry += 		"WHERE "
	cStrQry += 			"TEW.TEW_FILIAL = '"+xFilial('TEW')+"' AND "
	cStrQry += 			"TEW.D_E_L_E_T_ = ' ' AND "
	cStrQry += 			"( TEW.TEW_TIPO = '1' OR TEW.TEW_TIPO = ' ' ) AND "
	cStrQry += 			"AA3.AA3_NUMSER = TEW.TEW_BAATD AND "
				// -- intervalo movimentação tabela TEW
	cStrQry += 		"( ( ( ( TEW.TEW_DTSEPA BETWEEN '"+DTOS(dDatIni)+"' AND '"+DTOS(dDatFim)+"' ) " // -- data inicial entre o período
	cStrQry += 				"OR ( CASE WHEN TEW.TEW_FECHOS = '"+Space(8)+"' "
	cStrQry += 					"THEN ( CASE WHEN TEW.TEW_DTRFIM = '"+Space(8)+"' "
	cStrQry += 						"THEN ( CASE WHEN TFI.TFI_PERFIM < '"+DTOS(dDtAtual)+"' "
	cStrQry += 								"THEN '"+DTOS(dDtAtual)+"' "
	cStrQry += 								"ELSE TFI.TFI_PERFIM END) "
	cStrQry += 						"ELSE TEW.TEW_DTRFIM END)"
	cStrQry += 					"ELSE TEW.TEW_FECHOS END )"
	cStrQry += 					"BETWEEN '"+DTOS(dDatIni)+"' AND '"+DTOS(dDatFim)+"' " //  -- data final da locação entre o período
	cStrQry += 				"OR ( TEW.TEW_DTSEPA <= '"+DTOS(dDatIni)+"' AND "  // -- apura se o período de alocação é maior que o período pesquisado
	cStrQry += 						" ( CASE WHEN TEW.TEW_FECHOS = '"+Space(8)+"' "
	cStrQry += 						"THEN ( CASE WHEN TEW.TEW_DTRFIM = '"+Space(8)+"' "
	cStrQry += 							"THEN ( CASE WHEN TFI.TFI_PERFIM < '"+DTOS(dDtAtual)+"' "
	cStrQry += 									"THEN '"+DTOS(dDtAtual)+"' "
	cStrQry += 									"ELSE TFI.TFI_PERFIM END) "
	cStrQry += 							"ELSE TEW.TEW_DTRFIM END)"
	cStrQry += 						"ELSE TEW.TEW_FECHOS END) >= '"+DTOS(dDatFim)+"')"
	cStrQry += 				"))"

				// -- intervalo planejado da alocação tabela TFI
	cStrQry += 		"OR ( TEW.TEW_DTRINI = '"+Space(8)+"' AND "
	cStrQry += 			" TFI.TFI_PERINI > '"+DTOS(dDtAtual)+"' AND "
	cStrQry += 		"(( TFI.TFI_PERINI BETWEEN '"+DTOS(dDatIni)+"' AND '"+DTOS(dDatFim)+"' )" //  -- data inicial entre o período planejado da locação
	cStrQry += 		"OR ( TFI.TFI_PERFIM BETWEEN '"+DTOS(dDatIni)+"' AND '"+DTOS(dDatFim)+"' )" // -- data final da locação entre o período planejado da locação
	cStrQry += 		"OR ( TFI.TFI_PERINI <= '"+DTOS(dDatIni)+"' AND TFI.TFI_PERFIM >= '"+DTOS(dDatFim)+"' ))" // -- início menor e fim maior que o buscado
	cStrQry += 		"))"
EndIf

Return cStrQry

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180xIsRes
	Monta a condição para filtro dos itens reservados considera a tabela AA3 como referência
@sample 	At180xIsRes()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At180xIsRes( dDatIni, dDatFim, dDtAtual )

Local cStrQry := ""
Local nTamFilSB5 := AtTamFilTab( "SB5" )

	cStrQry += 		"SELECT TEW.TEW_CODMV "
	cStrQry += 		"FROM "+RetSqlName('TEW')+" TEW "
	cStrQry += 			"INNER JOIN "+RetSqlName('TFI')+" TFI ON "
	cStrQry += 											"TFI.TFI_FILIAL = TEW.TEW_FILIAL " // -- filial da TFI no mesmo nível que TEW
	cStrQry += 											"AND TFI.TFI_RESERV <> '' "
	cStrQry += 											"AND TFI.TFI_RESERV = TEW.TEW_RESCOD "
	cStrQry += 											"AND TFI.D_E_L_E_T_= ' ' "
	cStrQry +=  		"INNER JOIN "+RetSqlName('SB5')+" SB5 ON "
	cStrQry += 											"SB5.B5_FILIAL = '"+xFilial('SB5')+"' " 
	cStrQry += 											"AND SB5.B5_COD = AA3.AA3_CODPRO "
	cStrQry += 											"AND SB5.D_E_L_E_T_= ' ' "
	cStrQry += 		"WHERE "  // não restringe a filial pois pode estar reservada para outras filiais
	cStrQry += 			"TEW.D_E_L_E_T_ = ' ' AND SB5.B5_ISIDUNI <> '2'"
	cStrQry += 			"AND TEW.TEW_TIPO = '2' " // tipo igual a reserva
	cStrQry += 			"AND TEW.TEW_MOTIVO <> '3' " // reserva ativa no sistema
	cStrQry += 			"AND AA3.AA3_FILORI = TEW.TEW_FILBAT " // -- restringe os resultados das filiais da TFI e TEW tbm
	cStrQry += 			"AND AA3.AA3_NUMSER = TEW.TEW_BAATD "
				// -- intervalo de reserva na tabela TEW
	cStrQry += 			"AND ( ( ( TEW.TEW_DTRINI BETWEEN '"+DTOS(dDatIni)+"' AND '"+DTOS(dDatFim)+"' )" // -- data inicial entre o período
	cStrQry += 			" OR ( TEW.TEW_DTRFIM BETWEEN '"+DTOS(dDatIni)+"' AND '"+DTOS(dDatFim)+"' )" // -- data final da locação entre o período
	cStrQry += 			" OR ( TEW.TEW_DTRINI <= '"+DTOS(dDatIni)+"' AND TEW.TEW_DTRFIM >= '"+DTOS(dDatFim)+"' ) )" // -- data final da locação entre o período
	cStrQry += 			")"

Return cStrQry

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180xResumo
	Cria a query para busca dos status de forma resumida disponível/indisponível
@sample 	At180xResumo()
@since		11/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180xResumo( nModRet, xRet, cError, dDatIni, dDatFim, dDtAtual, xListProd, xListEquip )

Local lRet          := .T.
Local cResQry       := ""

Local lFilProd      := .T.
Local lFilEquip     := .T.
Local cProdFilter   := ""
Local cEquipFilter  := ""

Local cTmpQry       := ''
Local nTotCpos      := 0
Local nCpo          := 0
Local nLinArray     := 0

Local nX			:= 0
Local aCampos		:= {}

DEFAULT nModRet     := 0
DEFAULT dDatIni     := CTOD('')
DEFAULT dDatFim     := CTOD('')
DEFAULT dDtAtual    := dDataBase
DEFAULT xListProd   := ''
DEFAULT xListEquip  := ''

If nModRet <> 0
	
	//Carrega os campos para a query
	aCampos := At180GetSt( 1, .T. )
	
	// trata de-ate para produtos
	If !Empty(xListProd)
		If ValType(xListProd) == 'A' .And. Len(xListProd) >= 2
			cProdFilter := "AND AA3.AA3_CODPRO  BETWEEN '"+xListProd[1]+"' AND '"+xListProd[2]+"' "
		ElseIf ValType(xListProd) == 'C'
			cProdFilter := "AND AA3.AA3_CODPRO  = '" + xListProd+ "' "
		EndIf
		lFilProd := .T.
	Else
		lFilProd := .F.
	EndIF

	// trata de-ate para equipamentos
	If !Empty(xListEquip)
		If ValType(xListEquip) == 'A' .And. Len(xListEquip) >= 2
			cEquipFilter := "AND AA3.AA3_NUMSER BETWEEN '"+xListEquip[1]+"' AND '"+xListEquip[2]+"' "
		ElseIf ValType(xListEquip) == 'C'
			cEquipFilter := "AND AA3.AA3_NUMSER = '" + xListProd+ "' "
		EndIf
		lFilEquip := .T.
	Else
		lFilEquip := .F.
	EndIF

	// ------------------------------------------------
	//  redefine as variáveis de retorno
	If nModRet == MODO_RET_TABELA .And. ( ValType(xRet) <> 'C' .Or. Empty(xRet) )
		xRet := ''
	ElseIf nModRet == MODO_RET_ARRAY .And. ValType(xRet) <> 'A'
		xRet := {}
	ElseIf nModRet == MODO_RET_STRING .And. ValType(xRet) <> 'C'
		xRet := ''
	EndIf

	cResQry += "SELECT "
	cResQry += 		"CASE WHEN ("
	cResQry += 			"EXISTS (" + At180xIsAloc(dDatIni, dDatFim, dDtAtual)
	cResQry += 			") OR EXISTS ( " + At180xIsRes(dDatIni, dDatFim, dDtAtual)
	cResQry += 			")) THEN 1 "
	cResQry += 			"ELSE 0 END AA3_XDISP "
	
	For nX := 1 To Len(aCampos)
		If aCampos[nX][1] == "AA3_XDISP" .OR. aCampos[nX][1] == "AA3_DESPRO"
			Loop
		EndIf
		cResQry += 			",AA3." + aCampos[nX][1]	
	Next nX
	
	cResQry += 			",SB1.B1_DESC AA3_DESPRO "
	cResQry += "FROM "+RetSqlName('AA3')+" AA3 "
	cResQry += 		"INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = AA3.AA3_CODPRO AND SB1.D_E_L_E_T_ = ' ' "
	cResQry += "WHERE AA3.D_E_L_E_T_ = ' ' "
	cResQry += 		"AND AA3.AA3_FILIAL = '"+xFilial('AA3')+"' "
	cResQry += 		"AND AA3.AA3_EQALOC = '1' "
	cResQry += ( If( lFilProd, cProdFilter, '' ) )
	cResQry += ( If( lFilEquip, cEquipFilter, '' ) )

	cResQry := ChangeQuery(cResQry)

	If MODO_RET_TABELA == nModRet

		xRet := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cResQry ), xRet, .F., .F. )

		DbSelectArea(xRet)  // garante que o resultado da query é a área ativa

	ElseIf MODO_RET_STRING == nModRet
		xRet += cResQry

	ElseIf MODO_RET_ARRAY == nModRet

		xRet := {{},{}}

		cTmpQry := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cResQry ), cTmpQry, .F., .F. )

		xRet[1] := cTmpQry->( DbStruct() )
		nTotCpos := Len(xRet[1])

		DbSelectArea(cTmpQry)  // garante que o resultado da query é a área ativa

		// Copia todos os dados do resultado da query para o arquivo temporário criado
		While (cTmpQry)->(!EOF())
			aAdd( xRet[2], Array(nTotCpos))

			nLinArray := Len( xRet[2] )

			For nCpo := 1 To nTotCpos
				xRet[2,nLinArray,nCpo] := (cTmpQry)->&(FieldName(nCpo))
			Next nCpo

			(cTmpQry)->( DbSkip() )
		End

		(cTmpQry)->( DbCloseArea() )  // fecha a área com o resultado da query
	EndIf

Else

	lRet   := .F.
	cError := STR0001 // 'Modo de retorno da query não definido'

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180QryLc
	Query para selecionar os dados da locações de equipamentos.
@sample 	At180LcEqp()
@since		28/04/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180QryLc(cQryTbl,cId,dPerIni,dPerFim,oGSTmpTbl)
Local lRet		:= .F.
Local cRetTab 	:= ""
Local nCpo		:= 0
Local xValor	:= Nil
Local aCpos		:= {}
Local aIdx		:= {}
Default cId  	:= ""
Default dPerIni	:= Stod("")
Default dPerFim	:= Stod("")

If !Empty(cId)
	cQryTbl := GetNextAlias()

	BeginSql Alias cQryTbl

		COLUMN TFI_PERINI AS DATE
		COLUMN TFI_PERFIM AS DATE

		SELECT	TFI_CONTRT
		 	   ,TFI_LOCAL
			   ,TFI_PERINI
			   ,TFI_PERFIM
			   ,TEW_BAATD
			   ,ABS_CODIGO
			   ,ABS_LOJA
		FROM %Table:TFI% TFI
		INNER JOIN %Table:TEW% TEW
			ON TEW_FILIAL  	= %xFilial:TEW%
			AND TEW_CODEQU 	= TFI_COD
		INNER JOIN %Table:TFL% TFL
			ON TFL_FILIAL = %xFilial:TFL%
			AND TFL_CODIGO = TFI_CODPAI
		INNER JOIN %Table:ABS% ABS
			ON ABS_FILIAL = %xFilial:ABS%
			AND ABS_LOCAL = TFL_LOCAL
		WHERE TFI_FILIAL 	= %xFilial:TFI%
			AND TEW_TIPO = '1'
			AND TEW_BAATD = %Exp:cId%
			AND TEW.%NotDel%
			AND TFI.%NotDel%
			AND NOT (
				TEW_DTSEPA > %Exp:dPerFim%
				OR
				(
					( TEW_NUMOS <> ' ' AND TEW_FECHOS < %Exp:dPerIni% )
					OR ( TEW_NUMOS = ' ' AND TEW_DTRFIM <> ' ' AND TEW_DTRFIM < %Exp:dPerIni%  )
					)
				)

	EndSql

	DbSelectArea(cQryTbl)

	If (cQryTbl)->(!Eof())

		aCpos := At180Stru()
		Aadd(aIdx, {'I1',{"TFI_CONTRT","TFI_LOCAL","ABS_CODIGO","ABS_LOJA","TFI_PERINI","TFI_PERFIM","TEW_BAATD"}})


		oGSTmpTbl := GSTmpTable():New('TRAB',aCpos, aIdx )
		cRetTab := 'TRAB'
		oGSTmpTbl:CreateTMPTable()
		oGSTmpTbl:Commit()

		While (cQryTbl)->(!EOF())
			Reclock(cRetTab, .T.)
				For nCpo := 1 To (cRetTab)->( FCount() )
					xValor := (cQryTbl)->&((cRetTab)->(FieldName(nCpo)))
					FieldPut(nCpo, xValor)
				Next nCpo
			(cRetTab)->( MsUnlock() )

			(cQryTbl)->( DbSkip() )
		End

		(cQryTbl)->( DbCloseArea() )  // fecha a área com o resultado da query

		cQryTbl := cRetTab

		lRet := .T.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180Stru
	Carrega a estrutura para a formação do browse
@sample 	At180Stru() 
@since		28/04/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180Stru(nStru)
Local aCmps		:= {"TFI_CONTRT","TFI_LOCAL","ABS_CODIGO","ABS_LOJA","TFI_PERINI","TFI_PERFIM","TEW_BAATD"}
Local aStrCmp 	:= {}
Local nX		:= 0
Local aAreaSX3  := SX3->( GetArea() )
Default nStru	:= 1

DbSelectArea('SX3')

For nX := 1 To Len(aCmps)
	SX3->(DbSetOrder(2))
	If SX3->( DbSeek( PadR( aCmps[nX], 10 ) ) )  // X3_CAMPO
		If nStru == 1
			aAdd( aStrCmp, { aCmps[nX],;
							SX3->X3_TIPO,;
						 	SX3->X3_TAMANHO,;
						 	SX3->X3_DECIMAL } )
		Else
			aAdd( aStrCmp, { IIF(aCmps[nX] == "ABS_CODIGO" ,STR0005,X3Titulo()), ; //"Cód. Cliente"
							 &('{||'+aCmps[nX]+'}'),;
							 SX3->X3_TIPO,;
							 X3Picture(aCmps[nX]),;
							 1 ,;
							 TamSX3(aCmps[nX])[1],;
							 TamSX3(aCmps[nX])[2],;
							 .F. ,;
							 {|| .F.},;
							 .F. } )
		Endif
	Endif
Next nX

RestArea(aAreaSX3)

Return (aClone(aStrCmp))
