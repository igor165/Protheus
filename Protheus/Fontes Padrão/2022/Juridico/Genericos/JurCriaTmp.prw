#include 'protheus.ch'
#include 'jurcriatmp.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCriaTmp()
Cria uma tabela temporária e Array essa tabela ser exibida em um Browser a partir de uma query
Retornar objeto da tabela tabela temporária e Arrays para montar um FWFormBrowse.

@param  cTmpTable  Alias da tabela temporária
@param  cQryNCnt   Query contendo o select para carregar a tabela temporária
                   Obs: Se no WHERE da query houver um "OR" , colocar o WHERE da query entre Parênteses
                   Exemplo: "WHERE (... AND ... AND ... OR ... AND ...)"
@param  cNomeTab   Nome da tabela para criar os índices conforme os campos da query - Opcional
@param  aIdxAdic   Array com os índices que devem ser criados no Browser/tabela temporária - Opcional
                   Exemplo: aIdxAdic[nI][1] Nome do índice.
                            aIdxAdic[nI][2] Expressão ("NVE_FILIAL+NVE_TITULO")
                            aIdxAdic[nI][3] Tamanho do índice (202)
@param  aStruAdic  Estrutura adicional para incluir na tabela temporária caso exista na query. - Opcional
        Ex: aStruAdic[n][1] "NVE_SITUAC"     //Nome do campo
            aStruAdic[n][2] "Situação"       //Descrição do campo
            aStruAdic[n][3] "C"              //Tipo
            aStruAdic[n][4] 1                //Tamanho
            aStruAdic[n][5] 0                //Decimal
            aStruAdic[n][6] "@X"             //Picture
            aStruAdic[n][7] "NVE_SITUAC"     //Nome do Campo SX3 - Indique o nome do campo no dicionário.
                                                         Deve ser utilizado somente quando o Nome do Campo (aStruAdic[n][1]) não existir no dicionário.
                                               Exemplo: Nome do Campo     (aStruAdic[n][1]) = SITUACAO
                                                        Nome do Campo SX3 (aStruAdic[n][7]) = NVE_SITUAC

@param  aCmpAcBrw   Array simples com os campos onde o X3_BROWSE está como NÃO
                    mas que devem aparecer no Browse (independentemente do seu uso)

@param  aCmpNotBrw  Array simples com os campos onde o X3_BROWSE está como SIM
                    mas que NÃO devem aparecer no Browse (independentemente do seu uso)

@param lOrdemQry

@Param lInsert      .T. habilita a insersão na tabela temporaria. Padarão = .T.

@param aTitCpoBrw    Array composto com o nome do campo e o título que será utilizado no browse (Ignora Título do X3_TITULO) 
		Ex: aTitCpoBrw[n][1] "A1_COD"     		//Nome do campo
            aTitCpoBrw[n][2] "Código do Cliente" //Título do campo
			aTitCpoBrw[n][1] "A1_CGC"          	//Nome do campo
            aTitCpoBrw[n][2] "CPF do Cliente"   //Título do campo

@Param lShowMsg     .T. exibe mesagem de erro

@return aRet Array contendo:
                      [n][1] FWTemporaryTable
                      [n][2] Campos da tabela para o FWFormBrowse e FwMarkBrowse
                      [n][3] Index para o Browse
                      [n][4] Campos da tabela para o FWMarkBrowse
					  [n][5] 
					  [n][6] Estrutura de campos virtuais

@obs Index são criados conforme cNomeTab e aIdxAdic
           Será criado no máximo 35 index

@author Bruno Ritter
@since 30/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCriaTmp(cTmpTable, cQryNCnt, cNomeTab, aIdxAdic, aStruAdic, aCmpAcBrw, aCmpNotBrw, lOrdemQry, lInsert, aTitCpoBrw, lShowMsg)
Local aRet          := {}
Local aArea         := GetArea()
Local aAreaSIX      := SIX->(GetArea())
Local nTamanho      := 0
Local aOpcoes       := {}
Local cOpcoes       := ''
Local aStruDest     := {}
Local aFieldsO      := {}
Local aFields       := {}
Local aFieldsM      := {} //Campos destinados para o FwMarkBrowse
Local cIndExpr      := ""
Local cIndice       := ''
Local cNomInd       := ''
Local cCarcInd      := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local aIndexDb      := {}
Local oTmpTable     := Nil
Local nI            := 1
Local nZ            := 1
Local nIdx          := 1
Local cInsert       := ''
Local cCamposQry    := ''
Local cTitulo       := ''
Local cQryRes       := GetNextAlias()
Local aStruQry      := {}
Local cQryNull      := ''
Local aCamposQry    := {}
Local aStruVirt     := {}
Local aOrder        := {}
Local nDecimal      := 0
Local cTipo         := ''
Local nOrdem        := 0
Local nPosTitulo    := 0
Local cIntBrw       := ''
Local lNivBrw       := .F.
Local lBrowse       := .F.
Local lUsado        := .F.
Local lVirtual      := .F.
Local lCmpAdic      := !Empty(aStruAdic)  //Tem campos adicionais
Local lTitCpoBrw    := !Empty(aTitCpoBrw) //Tem títulos específicos
Local lCmpNotBrw    := Empty(aCmpNotBrw) //Campos removidos do browse
Local aOfuscar      := {} // Usado para LGPD - Somente para MarkBrowse - Indica quais campos da Estrutura adicional devem ser ofuscados
Local aLgpd         := {}
Local aNoAcess      := {}

Default cTmpTable   := GetNextAlias()
Default cNomeTab    := ''
Default aIdxAdic    := {}
Default aStruAdic   := {}
Default aCmpAcBrw   := {}
Default aCmpNotBrw  := {}
Default lOrdemQry   := .F.
Default lInsert     := .T.
Default aTitCpoBrw  := {}
Default lShowMsg    := .T.

//-------------------------------------------------------------------
//Processando a query para receber os campos utilizados
//-------------------------------------------------------------------
cQryNull := StrTran(cQryNCnt, 'WHERE', 'WHERE 1 = 2 AND ') //Alterando a query para não retorna nenhum valor.
cQryNull := ChangeQuery(cQryNull, .F.)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQryNull ), cQryRes, .T., .F. )

aStruQry := DBStruct()
(cQryRes)->(DbCloseArea())

For nZ := 1 To Len(aStruQry) 
	Aadd(aCamposQry, aStruQry[nZ][1])
	
	Iif (Empty(cCamposQry), , cCamposQry += " ," )
	cCamposQry += aStruQry[nZ][1]
Next nZ

//-------------------------------------------------------------------
// Criando Índices
//-------------------------------------------------------------------
If ( !Empty(cNomeTab) )
	nI := 1
	While (!Empty(cIndExpr := &(cNomeTab)->( IndexKey( nI ) )) .And. nI <= 35 ) //35 Quantidade máxima de caracteres (cCarcInd) para index
		cIndice := cNomeTab + SubStr( cCarcInd, nI, 1 )

		If(JurVeIdx(cIndExpr, aCamposQry) .Or. (Len(aCamposQry) == 0) ) //Verifica se todos os campos do índice estão na query.
			If SIX->(dbSeek( cIndice ) )
				cNomInd := AllTrim(SIX->(SixDescricao()))
			Else
				cNomInd := cIndExpr
			EndIf

			If (aScan(aOrder, { |aX| cIndExpr $ aX[2][1][5]})) == 0 //Verifica duplicidade nos índices
				Aadd(aOrder, {cNomInd,{{"", "C", JurIndxTam(cIndExpr), 0, cIndExpr,}}, nIdx, .T.})
				Aadd(aIndexDb, {cNomeTab + cValtoChar(nIdx), JurIndTraA(cIndExpr)})
				nIdx++
			EndIf

		EndIf
		nI++
	EndDo
EndIf

For nI := 1 To Len(aIdxAdic)
	If (aScan(aOrder, { |aX| aIdxAdic[nI][2] $ aX[2][1][5]})) == 0 //Verifica duplicidade nos índices
		Aadd(aOrder, {aIdxAdic[nI][1], {{"", "C", aIdxAdic[nI][3], 0, aIdxAdic[nI][2],}}, nIdx, .T.})
		Aadd(aIndexDb, {cValtoChar(nIdx), JurIndTraA(aIdxAdic[nI][2])})
		nIdx++
	EndIf
Next nI

//Se não foi informado nenhum índice, o primeiro campo será considerado o índice.
If ( Empty(cNomeTab) .And. Empty(aOrder) )
	Aadd(aOrder, {"IDX", {{aStruQry[1][1], aStruQry[1][2], aStruQry[1][3], aStruQry[1][4], aStruQry[1][1],}}, nIdx, .T.})
	Aadd(aIndexDb, {cValtoChar(nIdx), {aStruQry[1][1]}})
EndIf

//-------------------------------------------------------------------
// Cria a estrutura da tabela temporária e Browse
//-------------------------------------------------------------------
For nI := 1 To Len(aStruQry)
	cCampo := AllTrim(aStruQry[nI][1])
	cTipo  := GetSx3Cache(cCampo, 'X3_TIPO')

	If !Empty(cTipo) // Verifica se existe o campo na X3
		cOpcoes  := JurX3cBox(cCampo)
		aOpcoes  := {}
		lVirtual := GetSx3Cache(cCampo, 'X3_CONTEXT') == 'V'
		If lVirtual
			// Se for virtual, usa o tamanho do dbStruct, pois nem sempre o tamanho do campo virtual é o mesmo do campo real equivalente
			nTamanho := aStruQry[nI][3]
			nDecimal := aStruQry[nI][4]
		Else
			nTamanho := GetSx3Cache(cCampo, 'X3_TAMANHO')
			nDecimal := GetSx3Cache(cCampo, 'X3_DECIMAL')
		EndIf
		
		//Busca títulos diferentes do SX3
		If lTitCpoBrw .And. (nPosTitulo := aScan(aTitCpoBrw, {|x|Upper(AllTrim(x[1])) == cCampo})) > 0
			cTitulo  := Alltrim(aTitCpoBrw[nPosTitulo][2])
		Else
			cTitulo  := JurX3Title(cCampo)
		EndIf

		If !Empty(cOpcoes) // Retorna a maior informação da lista de opções
			aOpcoes := STRTOKARR(cOpcoes, ";")
			For nZ := 1 To Len(aOpcoes)
				If Len(aOpcoes[nZ] ) > nTamanho
					nTamanho := Len(aOpcoes[nZ])
				EndIf
			Next nZ
		EndIf

		aAdd( aStruDest, { cCampo, cTipo, nTamanho, nDecimal } )

		If lCmpNotBrw .Or. AScan(aCmpNotBrw, cCampo) == 0
			cPicture := GetSx3Cache(cCampo, 'X3_PICTURE')
			nOrdem   := GetSx3Cache(cCampo, 'X3_ORDEM')
			cIntBrw  := GetSx3Cache(cCampo, 'X3_INIBRW')
			lNivBrw  := GetSx3Cache(cCampo, 'X3_NIVEL') <= cNivel
			lBrowse  := GetSx3Cache(cCampo, 'X3_BROWSE') == 'S'
			lUsado   := X3USO(GetSx3Cache(cCampo, 'X3_USADO'))

			If ((lBrowse .And. lUsado) .Or. (lNivBrw .And. (!Empty(aCmpAcBrw) .And. AScan(aCmpAcBrw, cCampo) > 0)))
				aAdd( aFieldsO, {cCampo, cTitulo, cTipo, nTamanho, nDecimal, cPicture, nOrdem} )

				If lVirtual .Or. !Empty(cOpcoes)
					aAdd( aStruVirt, {cTitulo, cCampo, cTipo, nTamanho, nDecimal, cPicture, cIntBrw, cOpcoes} )
				EndIf
			EndIf
		EndIf

	ElseIf lOrdemQry .And. lCmpAdic
		nPosQuery := aScan(aStruAdic, {|aCampo| aCampo[1] == cCampo})
		If nPosQuery > 0
			aAdd( aStruDest, { aStruAdic[nPosQuery][1], aStruAdic[nPosQuery][3], aStruAdic[nPosQuery][4], aStruAdic[nPosQuery][5] } )
			If lCmpNotBrw .Or. aScan(aCmpNotBrw, aStruAdic[nPosQuery][1]) == 0
				aAdd(aFieldsO, {aStruAdic[nPosQuery][1], aStruAdic[nPosQuery][2], aStruAdic[nPosQuery][3], aStruAdic[nPosQuery][4], aStruAdic[nPosQuery][5], aStruAdic[nPosQuery][6]})
			EndIf
		EndIf
	EndIf
Next nI

If !lOrdemQry
	ASORT(aFieldsO, , , { |x, y| x[7] < y[7] } ) //Organizar campos conforme X3_ORDEM
EndIf

If !Empty(aStruAdic)
	For nI := 1 To Len(aStruAdic)
		If aScan( aStruDest, { | aX | aX[1] == aStruAdic[nI][1] } ) == 0
			aAdd( aStruDest, { aStruAdic[nI][1], aStruAdic[nI][3], aStruAdic[nI][4], aStruAdic[nI][5] } )

			If (lCmpNotBrw .Or. aScan(aCmpNotBrw, aStruAdic[nI][1]) == 0) //Verifica se deve mostrar no browse
				aAdd(aFieldsO , {aStruAdic[nI][1], aStruAdic[nI][2], aStruAdic[nI][3], aStruAdic[nI][4], aStruAdic[nI][5], aStruAdic[nI][6]})
			EndIf

			If (aStruAdic[nI][3] == "M")
				cCamposQry += ", " + aStruAdic[nI][1]
			EndIf
		EndIf
	Next nI
EndIf

For nI := 1 To Len(aFieldsO) 
	Aadd(aFields,  {aFieldsO[nI][1], aFieldsO[nI][2], aFieldsO[nI][3], aFieldsO[nI][4], aFieldsO[nI][5], aFieldsO[nI][6]})
	Aadd(aFieldsM, {aFieldsO[nI][2], aFieldsO[nI][1], aFieldsO[nI][3], aFieldsO[nI][4], aFieldsO[nI][5], aFieldsO[nI][6],,,,,, aFieldsO[nI][1]})
Next nI

//-------------------------------------------------------------------
// Cria tabela temporária.
//-------------------------------------------------------------------
oTmpTable := FWTemporaryTable():New( cTmpTable, aStruDest )

For nI := 1 To Len(aIndexDb)
	oTmpTable:AddIndex(aIndexDb[nI][1], aIndexDb[nI][2] )
Next nI

oTmpTable:Create()

//-------------------------------------------------------------------
// Carrega tabela Temporária
//-------------------------------------------------------------------
If lInsert
	cQryNCnt := StrTran (cQryNCnt, '* FROM', cCamposQry + " FROM")

	cInsert := "INSERT INTO "+ oTmpTable:GetRealName() +" ("
	cInsert += cCamposQry + " ) "
	cQryNCnt := ChangeQuery(cQryNCnt, .F.)
	cInsert += cQryNCnt

	If (TCSQLExec(cInsert) < 0) // Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
		JurLogMsg( TCSQLError() )
		If lShowMsg
			JurMsgErro(STR0001, "JurCriaTmp()", STR0002) //#"Erro ao abrir a janela." ##"Para mais detalhes verificar o log do console."
		EndIf
	EndIf
	(cTmpTable)->(dbGotop())
EndIf

// Tratamento para LGPD verifica os campos que devem ser ofuscados
If FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.)
	If lCmpAdic // Adiciona os campos da estrutura adicional no array de ofuscamento
		aOfuscar := JPDOfCpAdi(aStruAdic)
	EndIf
	AEval(aFieldsM, {|x| AAdd(aLgpd, x[2])})
	aNoAcess := FwProtectedDataUtil():UsrNoAccessFieldsInList(aLgpd)
	AEval(aNoAcess, {|x| AAdd( aOfuscar, x:cField)}) // Adiciona os campos da estrutura do FwMarkBrowse no array de ofuscamento
	JurFreeArr({aLgpd, aNoAcess})
EndIf

aRet := {oTmpTable, aFields, aOrder, aFieldsM, aStruDest, aStruVirt, aOfuscar}

RestArea(aAreaSIX)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCaseCB()
Criar CASE para query com os campos cBox.

@param   aCamposQry  Array simples com o nome dos campos da query.
		Exemplo: aCamposQry[nI] "NVE_SITUAC"

@return  cRet  String com CASE para a query
/*/
//-------------------------------------------------------------------
Function JurCaseCB (aCamposQry)
Local cRet       := ''
Local aArea      := GetArea()
Local aOpcoes    := {}
Local cOpcoes    := ''
Local nZ         := 1
Local nI         := 1
Local nPos       := 1
Local cWhen      := ''
Local cThen      := ''

For nI := 1 To Len(aCamposQry)
	cOpcoes  := JurX3cBox(aCamposQry[nI])

	If ('#'$ cOpcoes)
		cOpcoes := StrTran(cOpcoes, '#', '')
		cOpcoes := &(cOpcoes)
	EndIf
	
	aOpcoes  := {}

	If !Empty(cOpcoes)
		aOpcoes := STRTOKARR(cOpcoes, ";")
		cRet += " CASE "

		//When - opções
		For nZ := 1 To Len(aOpcoes)
			nPos  := At('=', aOpcoes[nZ])
			cWhen := Left(aOpcoes[nZ], nPos - 1)
			cThen := Right(aOpcoes[nZ], Len(aOpcoes[nZ]) - nPos)
			
			cRet  +=     " WHEN " + aCamposQry[nI] + " = '" + cWhen + "' THEN '" + cThen + "' "
		Next nZ

		cRet +=     " ELSE ' ' "
		cRet += " END " + aCamposQry[nI] + ", "
	Else
		cRet += aCamposQry[nI] + ", "
	EndIf

Next nI

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCmpSelc()
Auxiliar para criar os campos de um select a partir de uma tabela.

@param  cNomeTab  Nome da tabela para ser copiado os campos
		Exemplo:"NVE"
		Obs. Não returna campos Memo e Virtuais
@param  aCpoRemove, array, Array simples com campos a ser ignorados
		Exemplo: {"A1_NOME"}

@return  cRet  String com CASE para a query
/*/
//-------------------------------------------------------------------
Function JurCmpSelc(cNomeTab, aCpoRemove)
Local cRet         := ''
Local aArea        := GetArea()
Local aOpcoes      := {}
Local cOpcoes      := ''
Local nI           := 1
Local nPos         := 1
Local cWhen        := ''
Local cThen        := ''
Local cCampo       := ''
Local cVirtual     := 'X3_CAMPO;X3_INIBRW'+CRLF
Local aCpoSX3	   := {}
Local nC	       := 0
Local cX3Content   := ""
Local cX3Tipo	   := ""
Local nTamNome     := 0

Default cNomeTab   := ""
Default aCpoRemove := {}

	aCpoSX3 := FWSX3Util():GetAllFields(cNomeTab)

	For nC := 1 to Len(aCpoSX3)
		//Coloca PadR no campo pois antes pegava o conteúdo do X3_CAMPO
		If nTamNome = 0
			nTamNome := Len(GetSx3CaChe(aCpoSX3[nC], "X3_CAMPO" ) )
		EndIf

		If aScan(aCpoRemove, aCpoSX3[nC]) == 0
			cCampo := PadR(aCpoSX3[nC], nTamNome)
			cX3Content := GetSx3CaChe(cCampo, "X3_CONTEXT" )
			cX3Tipo	   := GetSx3CaChe(cCampo, "X3_TIPO" )
			If cX3Content != 'V' .And. cX3Tipo != 'M'
				cOpcoes  := JurX3cBox(cCampo)
				aOpcoes  := {}

				If !Empty(cOpcoes)
					aOpcoes := StrToArray(cOpcoes, ";")
					cRet += " CASE "
	
					//When - opções
					For nI := 1 To Len(aOpcoes)
						nPos  := At('=', aOpcoes[nI])
						cWhen := Left(aOpcoes[nI], nPos - 1)
						cThen := Right(aOpcoes[nI], Len(aOpcoes[nI]) - nPos)
					
						cRet  +=     " WHEN " + cCampo + " = '" + cWhen + "' THEN '" + cThen + "' "
					Next nI
	
					cRet +=     " ELSE ' ' "
					cRet += " END " + cCampo + ", "
				Else
					cRet += cCampo + ", "
				EndIf
			ElseIf( cX3Content == 'V' .And. cX3Tipo != 'M' .And. GetSx3CaChe(cCampo, "X3_BROWSE") == 'S' .And. X3USO( GetSx3CaChe(cCampo, "X3_USADO")))
		
				cVirtual   += cCampo + ";" + GetSx3CaChe(cCampo, "X3_INIBRW") + CRLF
			EndIf
		EndIf

	Next nC
	JurFreeArr(@aCpoSX3)

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCaseJL()
Criar CASE para query para alterar o valor NULL para ''
Intenção é facilitar a criação de query com LEFT JOIN.

@param   aCampos  Array com o nome do campo real e virtual.
		Exemplo: aCampos[nI][1] "A1_NOME"
		          aCampos[nI][2] "NX0_DCLIEN"

@return  cRet  String com CASE para a query
/*/
//-------------------------------------------------------------------
Function JurCaseJL(aCampos)
Local cRet := ''
Local nI   := 1

For nI := 1 To Len(aCampos)
	If (!Empty(aCampos[nI][1]) .And. !Empty(aCampos[nI][2]))
		cRet += " CASE "
		cRet +=     " WHEN " + aCampos[nI][1] + " IS NULL THEN ' ' "
		cRet +=     " ELSE " + aCampos[nI][1] + " "
		cRet += " END " + aCampos[nI][2] + ", "
	EndIf
Next nI

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIndTraA(cIndExpr)
Função utilizada para transformar a expressão de index em um array para
a tabela temporária, removendo as funções nos campos do índice.

@param cIndExpr     Expressão do índice

@author Bruno Ritter
@since 20/09/16
/*/
//-------------------------------------------------------------------
Function JurIndTraA(cIndExpr)
Local aRet := STRTOKARR(cIndExpr, '+')
Local nI   := 0

For nI := 1 To Len(aRet)
	If At('(', aRet[nI]) > 0
		aRet[nI] := Substr(aRet[nI], At('(', aRet[nI]) + 1)
		aRet[nI] := Substr(aRet[nI], 1, At(')', aRet[nI]) - 1)
	EndIf
Next nI

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVeIdx()
Verificar se todos os campos do index (cIndExpr) existem no array (aCamposQry).

@param  cIndExpr    Expressão contendo os índices
@param  aCamposQry  Array conténdo os campos

@author Bruno Ritter
@since 19/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurVeIdx(cIndExpr, aCamposQry)
Local lRet    := .T.
Local nI      := 1
Local aIndExp := STRTOKARR(cIndExpr, '+')

For nI := 1 To Len(aIndExp)
	If (AScan(aCamposQry, aIndExp[nI]) == 0) 
		lRet := .F.
		Exit
	EndIf
Next

JurfreeArr(aIndExp)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurX3cBox
Devolve o conteudo do campo de lista de opções  de acordo com o idioma corrente.

@param  cCampo, Nome do campo da tabela

@return cRet  , String com a lista de opções

@author Luciano Pereira dos Santos
@since  19/09/2017
@Obs    A função X3cBox() não foi utilizada pois precisa de posicionamento no metadados
/*/
//-------------------------------------------------------------------
Function JurX3cBox(cCampo)
Local cRet    := ''
Local cX3CBox := ''

If FWRetIdiom() == 'pt-br'
	cX3CBox := GetSx3Cache(cCampo, 'X3_CBOX')
ElseIf FWRetIdiom() == 'en'
	cX3CBox := GetSx3Cache(cCampo, 'X3_CBOXENG')
ElseIf FWRetIdiom() == 'es'
	cX3CBox := GetSx3Cache(cCampo, 'X3_CBOXSPA')
EndIf

cRet := Alltrim(cX3CBox)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPDOfCpAdi
Indica quais campos da estrutura adicional devem ser ofuscados

@param aStructCpo - Array a estrutura dos campos da tabela temporária

@return Nil

@author Jorge Martins
@since 27/01/2020
/*/
//-------------------------------------------------------------------
Static Function JPDOfCpAdi(aStructCpo)
	Local aNoAcess    := {}
	Local aOfuscar    := {}
	Local aCpoAdi     := {} // Nomes dos campos da estrutura adicional.              Ex: RAZSOCFAT
	Local aCpoSX3     := {} // Nomes dos campos SX3 referente aos campos adicionais. Ex: A1_NOME
	Local nCpo        := 0
	Local nPos        := 0

	// Tratamento para LGPD verifica os campos que devem ser ofuscados
	If FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.)

		For nCpo := 1 To Len(aStructCpo)
			AAdd(aCpoAdi, aStructCpo[nCpo][1])
			If Len(aStructCpo[nCpo]) >= 7 .And. !Empty(aStructCpo[nCpo][7]) // Verifica se possui a identificação do campo no SX3
				AAdd(aCpoSX3, aStructCpo[nCpo][7])
			Else
				AAdd(aCpoSX3, aStructCpo[nCpo][1])
			EndIf
		Next

		aNoAcess := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCpoSX3)
		AEval(aNoAcess, {|x| AAdd( aOfuscar, x:cField)})

		// Altera os nomes de campos SX3 para os campos adicionais não identificados no SX3.
		// Para que seja ofuscado o campo virtual.
		For nCpo := 1 To Len(aOfuscar)
			nPos := aScan(aCpoSX3, aOfuscar[nCpo])
			If nPos > 0
				aOfuscar[nCpo] := aCpoAdi[nPos]
			EndIf
		Next
	EndIf

	JurFreeArr({aNoAcess, aCpoAdi, aCpoSX3})

Return aOfuscar

//-------------------------------------------------------------------
/*/{Protheus.doc} JurX3Title
Devolve o título do campo no SX3.

@param  cCampo, Nome do campo na tabela SX3

@return cTitle, Título do campo no idioma do sistema

@author Jonatas Martins / Jorge Martins
@since  06/12/2021
/*/
//-------------------------------------------------------------------
Function JurX3Title(cCampo)
Local cTitle := ""

	If FWRetIdiom() == 'pt-br'
		cTitle := Alltrim(GetSx3Cache(cCampo, 'X3_TITULO'))
	ElseIf FWRetIdiom() == 'en'
		cTitle := Alltrim(GetSx3Cache(cCampo, 'X3_TITENG'))
	ElseIf FWRetIdiom() == 'es'
		cTitle := Alltrim(GetSx3Cache(cCampo, 'X3_TITSPA'))
	EndIf

Return (cTitle)