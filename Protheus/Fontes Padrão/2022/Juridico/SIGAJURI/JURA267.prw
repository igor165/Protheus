#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'JURA267.CH'

#DEFINE JUSTICA       1
#DEFINE CHAVE         2
#DEFINE PROCESSO      3
#DEFINE AUTOR         4
#DEFINE REU           5
#DEFINE DEPOSITANTE   6
#DEFINE SALDOCAPITAL  7
#DEFINE SALDODATABASE 8
#DEFINE CONTAJUDICIAL 9
#DEFINE TIPOEXTRATO   10
#DEFINE SALDOPROCESSO 11
#DEFINE SALDOATUALIZA 12

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA267
Conciliação de depositos judiciais.

@author  Brenno Gomes
@since   06/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA267()
Local lRet    := .F.

	DbSelectArea("NT2")

	lRet := Pergunte("JURA267",.T.)

	If lRet .And. !Empty(AllTrim(MV_PAR01)) .And. (!Empty(AllTrim(MV_PAR02)) .Or. ColumnPos("NT2_CONJUD") > 0)
		Processa( {|| JMakeExcel() } , STR0002, STR0001, .F. ) // 'Aguarde', 'Gerando...'
	EndIf

	NT2->( DbCloseArea())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JMakeExcel
Função responsável por criar tabela temporária e inserir dados dos extratos
dos depósitos judíciais.

@since 12/03/2019
/*/
//-------------------------------------------------------------------
Function JMakeExcel()
Local cArquivo   := AllTrim(MV_PAR01)
Local cRelac     := AllTrim(MV_PAR02)
Local cTab       := Nil
Local oObjTab    := Nil
Local oObjTabGar := Nil

	ProcRegua(8)

	IncProc(STR0064) // "Criando tabelas temporárias"

	If Empty(cRelac)
		cRelac := "NT2_CONJUD"
	EndIf

	oObjTab := JCriaTab(JStruExt(cRelac), {{"TMP_CHAVE"}}) // Tabela temporária de Extratos
	cTab := oObjTab:GetAlias()

	oObjTabGar := JCriaTab(JStruGar(), {{"TMP_CODGAR"}}) // Tabela temporária de calculo de saldo das garantias

	IncProc(STR0065 + cArquivo) //"Lendo arquivos na pasta: "
	JDicFold(cArquivo,cTab)

	IncProc(STR0066) //"Gerando relatório de conciliação!"
	JA267Expor(oObjTab,oObjTabGar)

	oObjTab:Delete()
	oObjTabGar:Delete()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JDicFold

Lista os arquivos da pasta e verifica qual o Layout de cada arquivo

@param  cPath  Caminho da pasta com os arquivos
@author sigajuri
@since 15/03/2019
/*/
//-------------------------------------------------------------------
Static Function JDicFold(cPath, cTabela)
Local aListArqs := {}
Local aReq      := {}
Local aArquivos := {}
Local nI        := 1

	If !(SubStr(cPath, Len(cPath),1) == "\")
		cPath += "\"
	Endif

	aListArqs := Directory(cPath + '*.*')

	//-- Percorre arquivos para realizar a leitura dos Layouts
	For nI := 1 To Len(aListArqs)
		aAdd(aArquivos, cPath + aListArqs[nI][1] ) //-- Path + Nome do Arquivo / Extensao do Arquivo
	Next nI

	//-- Verifica qual é o Layout - BB / CEF / Recursal
	For nI := 1 to Len(aArquivos)
		aReq := J267RdRCF(aArquivos[nI], cTabela) // Recursal CEF

		If !aReq[1]  //--Layout Recursal
			aSize(aReq,0)
			aReq := J267RdCEF(aArquivos[nI], cTabela) //--Layout CEF

			If !aReq[1]
				aSize(aReq,0)
				aReq := J267RdBB(aArquivos[nI], cTabela) //-- Layout BB
			EndIf
		EndIf

	Next nI
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} JGetTotal
Cria o Array para gerar a tabela de Totalizadores na Tela de Resumo

@param aResArea - Array que contem o resumo por Area

@return aResumo - Array de retorno
	[Linha do Grupo][Campo da Linha]

@since 22/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGetTotal(aResArea)
Local aResTotal  := {}
Local aConjGrupo := JGtConjGrp()
Local nIndGrupo  := 1
Local nConj      := 0
Local nQtdTotal  := 0
Local nVlrGarTot := 0
Local nVlrExtTot := 0
Local nVlrDifTot := 0
Local nLastCod   := Len(aResArea)
Local cIdLinRes  := ""

	// Cria o Array
	aAdd(aResTotal, StruResumo(AllTrim(cValToChar(nIndGrupo+nLastCod)), STR0009)) //"Resumo Depósitos Judiciais"

	// Os loops começam pelo 2º parâmetro pois o primeiro é o Cabeçalho/Ordem
	For nConj := 2 To Len(aConjGrupo)
		cIdLinRes := AllTrim(cValToChar(nIndGrupo+nLastCod)) + "." + AllTrim(cValToChar(nConj-1))
		aAdd(aResTotal, StruResumo(cIdLinRes, aConjGrupo[nConj]))
	Next nConj

	// Loop para Guardar os total por Grupos
	For nIndGrupo := 1 To Len(aResArea)
		For nConj := 2 To Len(aConjGrupo)
			aResTotal[nConj][3] += aResArea[nIndGrupo][nConj][3] // Quantidade de registros
			aResTotal[nConj][5] += aResArea[nIndGrupo][nConj][5] // Valor de Garantia
			aResTotal[nConj][7] += aResArea[nIndGrupo][nConj][7] // Valor do Extrato

			nQtdTotal  += aResArea[nIndGrupo][nConj][3] // Totalizador de Quantidade
			nVlrGarTot += aResArea[nIndGrupo][nConj][5] // Valor Total de Garantias
			nVlrExtTot += aResArea[nIndGrupo][nConj][7] // Valor Total do Extrato
		Next nConj
	Next nIndGrupo

	// Atualiza os percentuais
	For nConj := 2 To Len(aConjGrupo)
		aResTotal[nConj][4] := (aResTotal[nConj][3]/nQtdTotal) * 100   // Percentual de Qtd Total
		aResTotal[nConj][6] := (aResTotal[nConj][5]/nVlrGarTot) * 100  // Percentual na Garantia
		aResTotal[nConj][8] := aResTotal[nConj][5]-aResTotal[nConj][7] // Diferença
		nVlrDifTot          += aResTotal[nConj][8]                     // Total das diferenças
	Next nConj

	// Valores do Cabeçalho de Totalizadores
	aResTotal[1][3] := nQtdTotal    // Qtd
	aResTotal[1][4] := 100          // % Qtd
	aResTotal[1][5] := nVlrGarTot   // Valor total Garantias (SIGAJURI)
	aResTotal[1][6] := 100          // % Valor total
	aResTotal[1][7] := nVlrExtTot   // Valor total Extratos
	aResTotal[1][8] := nVlrDifTot   // Diferença entre SIGAJURI x Extrato

Return aResTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetResumo
Monta o Layout das tabelas do Resumo

@param oObjTable - Objeto da tabela temporária
@param cRelac    - Campo para o relacionamento com a temporária

@return aResumo - Array de retorno
	[Tipo Assunto Juridico][Linha do Grupo][Campo da Linha]

@since 22/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGetResumo(cRelac, oObjTable, oObjTabGar)
Local aSaldos    := {}
Local aResumo    := {}
Local aConjGrupo := JGtConjGrp()
Local cAlias     := ""
Local cAliasRec  := ""
Local cCajuriAtu := ""
Local cTab       := ""
Local cTabGar    := ""
Local cCodConj   := ""
Local cIdLinRes  := ""
Local nJuros     := 0
Local nLevant    := 0
Local nSaldoAtu  := 0
Local nI         := 0
Local nRecno     := 0
Local nQtdAreas  := 0
Local nConj      := 0
Local nValGarant := 0
Local nValSldBnc := 0
Local nGrupoItem := 0
Local nValTotGar := 0
Local nValTotBnc := 0
Local nQtdTotGar := 0
Local nPercToler := 0.10 // Analisando o Excel do cliente, o percentual é de 10%

Default oObjTabGar := Nil
Default oObjTable  := Nil

	If oObjTable != Nil
		cTab :=  oObjTable:GetAlias()
	EndIf

	// Geração do primeiro select para calculo dos Saldos
	cQuery := JQryGarant(cRelac, oObjTable)
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .F.)

	If oObjTabGar != Nil
		cTabGar := oObjTabGar:GetAlias()
	EndIf

	IncProc(STR0067)//"Calculando Saldo de Garantias"

	// Loop para Geração dos Saldos
	While (cAlias)->(!Eof()) .And. oObjTable != Nil
		// Verifica se o Cajuri mudou
		If (cAlias)->CAJURI != cCajuriAtu

			cCajuriAtu := (cAlias)->CAJURI

			// Busca o Saldo do Cajuri Posicionado
			aSaldos := JA098CriaS(cCajuriAtu, (cAlias)->FilialGar)

			// Zera as variáveis de Saldo
			nJuros    := 0
			nLevant   := 0
			nSaldoAtu := 0

			// Loop para incrementar os valores nas varia´veis
			For nI := 2 to Len(aSaldos)
				Do case
					Case aSaldos[nI][4] == "SF" // Saldo Atual
						// Atualiza os campos de saldos na Tabela Temporária
						GrvTmpGar(cTabGar, aSaldos[nI][8], cCajuriAtu,aSaldos[nI][5])
				EndCase
			Next nI
		EndIf

		(cAlias)->(dbSkip())
	EndDo
	// Fecha a query utilizada para calculo de saldo
	(cAlias)->( dbcloseArea() )

	// Cria o Alias para a Reconsultar a query para incluir os saldos
	cAliasRec := GetNextAlias()
	cQuery := JQryGarant(cRelac, oObjTable, oObjTabGar)
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasRec, .T., .F.)

	IncProc(STR0068) //"Criando lista de dados"
	// Loop de Geração do Resumo
	While (cAliasRec)->(!Eof())
		// Verifica se está no mesmo Assunto Juridico
		If (cAliasRec)->TipAssJur != cCodConj
			// Inclui um novo Grupo no Resumo para o Assunto Juridico novo
			cCodConj := (cAliasRec)->TipAssJur
			If nQtdAreas > 0
				aResumo[nQtdAreas][1][3] := nQtdTotGar
				aResumo[nQtdAreas][1][4] := 100
				aResumo[nQtdAreas][1][5] := nValTotGar
				aResumo[nQtdAreas][1][6] := 100
				aResumo[nQtdAreas][1][7] := nValTotBnc
				aResumo[nQtdAreas][1][8] := nValTotGar-nValTotBnc

				// Atualiza os campos de Percentual e de Diferença
				For nConj := 2 to Len(aConjGrupo)
					aResumo[nQtdAreas][nConj][4] := (aResumo[nQtdAreas][nConj][3]/nQtdTotGar) * 100  // Percentual em cima de todas as Garantias
					aResumo[nQtdAreas][nConj][6] := (aResumo[nQtdAreas][nConj][5]/nValTotGar) * 100 // Percentual em cima do Valor total das Garantias
					aResumo[nQtdAreas][nConj][8] := aResumo[nQtdAreas][nConj][5]-aResumo[nQtdAreas][nConj][7]  // Diferença entre o Banco e as Garantias Encontradas
				Next nConj

				// Zera os totalizadores
				nQtdTotGar := 0
				nValTotGar := 0
				nValTotBnc := 0
			EndIf

			// Incrementa pois irá gerar uma nova tabela de Area
			nQtdAreas++
			aAdd(aResumo,{})

			aAdd(aResumo[nQtdAreas],StruResumo(AllTrim(cValToChar(nQtdAreas)),cCodConj)) // Linha dos totalizadores
			// Cria a Estrutura dos Resumos por Assunto Juridico
			For nConj := 2 To Len(aConjGrupo)
				// Cria o ID para a Primeira coluna
				cIdLinRes := AllTrim(cValToChar(nQtdAreas)) + "." + AllTrim(cValToChar(nConj-1))

				aAdd(aResumo[nQtdAreas], StruResumo(cIdLinRes, AllTrim(aConjGrupo[nConj])))
			Next nConj
		Endif

		// Inicializa as variáveis com Saldo Garantia e Saldo no Banco
		nValGarant := (cAliasRec)->SldGarant
		nValSldBnc := (cAliasRec)->SaldoCap

		//{"Cabeçalho","Conciliado", "Baixa Total", "Baixa Parcial", "Saldo maior no Banco", "Não identificados"}
		Do Case
			Case Empty((cAliasRec)->Chave) // Não identificado
				nGrupoItem := 6
			Case (((nValGarant - nValSldBnc)/nValGarant) == 1) // Baixa Total
				nGrupoItem := 3
			Case (Abs((nValGarant - nValSldBnc)/nValGarant) < nPercToler)  // Conciliado. Se a diferença entre o Valor da Garantias e o Valor no Extrato está dentro do percentual de Tolerancia.
				nGrupoItem := 2
			Case (((nValGarant - nValSldBnc)/nValGarant) > nPercToler) // Baixa parcial. Mais no Protheus do que no Banco. Acima do Percentual de Tolerancia
				nGrupoItem := 4
			Case (((nValGarant - nValSldBnc)/nValGarant) < (nPercToler * -1)) // Saldo maior no Banco. Acima do Percentual de Tolerancia
				nGrupoItem := 5
			Otherwise	// Não Identificado
				nGrupoItem := 6
		EndCase

		// Incrementa os dados no Resumo do assunto juridico
		aResumo[nQtdAreas][nGrupoItem][3]++
		aResumo[nQtdAreas][nGrupoItem][5] += nValGarant
		aResumo[nQtdAreas][nGrupoItem][7] += nValSldBnc

		// Totalizadores
		nQtdTotGar++
		nValTotGar += nValGarant
		nValTotBnc += nValSldBnc

		(cAliasRec)->(dbSkip())
	EndDo

	// Gera o ultimo totalizador
	If nQtdAreas > 0
		aResumo[nQtdAreas][1][3] := nQtdTotGar
		aResumo[nQtdAreas][1][4] := 100
		aResumo[nQtdAreas][1][5] := nValTotGar
		aResumo[nQtdAreas][1][6] := 100
		aResumo[nQtdAreas][1][7] := nValTotBnc
		aResumo[nQtdAreas][1][8] := nValTotGar-nValTotBnc

		// Atualiza os campos de Percentual e de Diferença
		For nConj := 2 to Len(aConjGrupo)
			aResumo[nQtdAreas][nConj][4] := (aResumo[nQtdAreas][nConj][3]/nQtdTotGar) * 100  // Percentual em cima de todas as Garantias
			aResumo[nQtdAreas][nConj][6] := (aResumo[nQtdAreas][nConj][5]/nValTotGar) * 100 // Percentual em cima do Valor total das Garantias
			aResumo[nQtdAreas][nConj][8] := aResumo[nQtdAreas][nConj][5]-aResumo[nQtdAreas][nConj][7]  // Diferença entre o Banco e as Garantias Encontradas
		Next nConj
	EndIf

	// Fecha a query de Resumo
	(cAliasRec)->( dbcloseArea() )
Return aResumo

//-------------------------------------------------------------------
/*/{Protheus.doc} StruResumo
Layout das Tabelas dos Resumos

@param  cId - ID apresentado nas tabelas
@param  cDescri - Descrição da Coluna

@return aStruLin - Linha montada

@since 22/03/2019
/*/
//-------------------------------------------------------------------
Static Function StruResumo(cId,cDescri)
Local aStruLin    := {}

	aAdd(aStruLin, cId           ) // [1] - Id da Linha
	aAdd(aStruLin, cDescri       ) // [2] - Descrição da Linha
	aAdd(aStruLin, 0             ) // [3] - Quantidadeu
	aAdd(aStruLin, 0             ) // [4] - Percentual
	aAdd(aStruLin, 0             ) // [5] - Saldo total Protheus
	aAdd(aStruLin, 0             ) // [6] - Percentual do Total
	aAdd(aStruLin, 0             ) // [7] - Saldo do Banco
	aAdd(aStruLin, 0             ) // [8] - Diferença
Return aStruLin

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvTmpGar
Insere registro na tabela temporária de garantia

@param  cTab - Id da tabela para o RecLock
@param  cCodGar - Cód. da Garantia
@param  nSaldoAtu - Saldo Atual

@since 22/03/2019
/*/
//-------------------------------------------------------------------
Static Function GrvTmpGar(cTab, cCodGar, cCajuri, nSaldoAtu)
	If Reclock( cTab , .T. )
		(cTab)->TMP_CODGAR := cCodGar   // Cód. da Garantia
		(cTab)->TMP_CAJURI := cCajuri   // Cód. do Assunto Juridico
		(cTab)->TMP_SLDGAR := nSaldoAtu // Saldo calculado.
		(cTab)->(MsUnlock())
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryGarant
Query de garantias

@param oObjTable - Objeto da tabela temporária
@param cRelac    - Campo para o relacionamento com a Tabela temporária

@since 22/03/2019
/*/
//-------------------------------------------------------------------
Static Function JQryGarant(cRelac, oObjTable, oObjTabGar)
Local cQuery     := ""
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryOrd    := ""
Local cTabRealNm := ""
Local cTabGarNm  := ""
Local aCampos    := JGtColsGar() // Colunas da Garantia
Local aCamposExt := JGtColsExt() // Colunas da Tab. Temporária de Extratos
Local aCamposGar := JGtClsTmpG() // Colunas da Tab. Temporária de Saldos das Garantias
Local nC         := 0

Default cRelac     := AllTrim(MV_PAR02)
Default oObjTable  := Nil
Default oObjTabGar := Nil

	If Empty(cRelac)
		cRelac := "NT2_CONJUD"
	EndIf

	//- Select
	cQrySel := " SELECT NT2.NT2_COD CodGar "

	For nC := 2 To Len(aCampos)
		cQrySel += "," + AllTrim(aCampos[nC][4]) + " " + AllTrim(aCampos[nC][2])
	Next nC

	//- From
	cQryFrm := " FROM " + RetSqlName("NT2") + " NT2 INNER JOIN " + RetSqlName("NSZ") + " NSZ ON NSZ.NSZ_FILIAL = NT2.NT2_FILIAL "
	cQryFrm +=                                                                            " AND NSZ.NSZ_COD    = NT2.NT2_CAJURI "
	cQryFrm +=                                                                            " AND NSZ.D_E_L_E_T_ = ' '"
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NYB") + " NYB ON NYB.NYB_COD = NSZ.NSZ_TIPOAS "
	cQryFrm +=                                                                            " AND NYB.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NRB") + " NRB ON NRB.NRB_COD = NSZ.NSZ_CAREAJ "
	cQryFrm +=                                                                            " AND NRB.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NUQ") + " NUQ ON NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrm +=                                                                            " AND NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrm +=                                                                            " AND NUQ.NUQ_INSATU = '1' "
	cQryFrm +=                                                                            " AND NUQ.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NQW") + " NQW ON NQW.NQW_COD = NT2.NT2_CTPGAR "
	cQryFrm +=                                                                            " AND NQW.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                    " LEFT  JOIN " + RetSqlName("NT9") + " NT901 ON NT901.NT9_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrm +=                                                                              " AND NT901.NT9_CAJURI = NSZ.NSZ_COD "
	cQryFrm +=                                                                              " AND NT901.NT9_TIPOEN = '1' "
	cQryFrm +=                                                                              " AND NT901.NT9_PRINCI = '1' "
	cQryFrm +=                                                                              " AND NT901.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                    " LEFT  JOIN " + RetSqlName("NT9") + " NT902 ON NT902.NT9_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrm +=                                                                              " AND NT902.NT9_CAJURI = NSZ.NSZ_COD "
	cQryFrm +=                                                                              " AND NT902.NT9_TIPOEN = '2' "
	cQryFrm +=                                                                              " AND NT902.NT9_PRINCI = '1' "
	cQryFrm +=                                                                              " AND NT902.D_E_L_E_T_ = ' ' "

	For nC := 1 To Len(aCamposGar)
		If oObjTabGar != Nil
			cQrySel += "," + AllTrim(aCamposGar[nC][4] + " " + AllTrim(aCamposGar[nC][2]))
		Else
			cQrySel += ",' ' " + AllTrim(aCamposGar[nC][2])
		EndIf
	Next nC

	If oObjTabGar != Nil
		cQryFrm += " LEFT JOIN " + oObjTabGar:GetRealName() + " TMPGAR ON TMPGAR.TMP_CODGAR = NT2.NT2_COD "
		cQryFrm +=                                                  " AND TMPGAR.TMP_CAJURI = NT2.NT2_CAJURI "
	EndIf

	// Cria o relacionamento da Tabela principal com os dados da Garantia
	If oObjTable != Nil .And. !Empty(cRelac)
		For nC := 1 To Len(aCamposExt)
			cQrySel += "," + AllTrim(aCamposExt[nC][4]) + " " + AllTrim(aCamposExt[nC][2])
		Next nC

		cTabRealNm := oObjTable:GetRealName()

		cQryFrm += " LEFT JOIN " + cTabRealNm + " EXTRATO ON EXTRATO.TMP_CHAVE = NT2." + cRelac + " "
		cQryWhr +=                                     " AND EXTRATO.TMP_CHAVE > ' ' "
	EndIf

	//- Where
	cQryWhr := " WHERE NT2.D_E_L_E_T_ = ' ' "
	cQryWhr +=   " AND NT2.NT2_MOVFIN = '1' "
	cQryWhr +=   " AND NSZ.NSZ_SITUAC = '1' "
	//cQryWhr +=   " AND NYB.NYB_COD = '002' "

	DbSelectArea("NQW")
	If ColumnPos("NQW_CONCIL") > 0
		cQryWhr += " AND NQW.NQW_CONCIL = '1' "
	EndIf

	If !Empty(cRelac)
		cQryWhr +=   " AND NT2." + cRelac + " > ' ' "
	EndIf

	//- Order
	cQryOrd := " ORDER BY NSZ.NSZ_TIPOAS, NSZ.NSZ_COD, NT2.NT2_COD "

	//- Concatenação das clausulas
	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JCriaTab
Função responsável por criar tabela temporária e inserir dados dos extratos
dos depósitos judíciais.

@param cChave - Campo Chave para setar o tamanho do campo TMP_CHAVE
@since 12/03/2019
/*/
//-------------------------------------------------------------------
Function JCriaTab(aStruct, aIndex)
Local oTmpTable := Nil
Local nIndex    := 0
Default aIndex := {}

	//Criação do objeto
	oTmpTable := FWTemporaryTable():New()
	oTmpTable:SetFields(aStruct)

	//Criação do Indice
	For nIndex := 1 To Len(aIndex)
		oTmpTable:AddIndex( Right("0" + cValToChar(nIndex), 2) , aIndex[nIndex])
	Next nIndex

	//Criação da tabela
	oTmpTable:Create()

	aSize(aStruct,0)

Return oTmpTable

//-------------------------------------------------------------------
/*/{Protheus.doc} mountLnBB
Retorna dados da linha do deposito

@author Brenno Gomes
@since 06/02/2019
/*/
//-------------------------------------------------------------------
Static Function mountLnBB(cContent,oResponse,nI,cJustica)

	oResponse[nI]['chaveSigajuri'] := JExtSubStr(cContent,2,13) + cValToChar(Val(JExtSubStr(cContent,16,4)))
	oResponse[nI]['contaJudicial'] := JExtSubStr(cContent,2,13)
	oResponse[nI]['processo']      := JExtSubStr(cContent,20,21)
	oResponse[nI]['autor']         := JExtSubStr(cContent,41,18)
	oResponse[nI]['reu']           := JExtSubStr(cContent,59,18)
	oResponse[nI]['depositante']   := JExtSubStr(cContent,77,19)
	oResponse[nI]['saldoCapital']  := JExtSubStr(cContent,96,18, "N")
	oResponse[nI]['saldoDataBase'] := JExtSubStr(cContent,114,19, "N")
	oResponse[nI]['justica']       := cJustica
	oResponse[nI]['tipoExtrato']   := 'BB'


Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} mountLnCEF
Retorna dados da linha do deposito

@author Brenno Gomes
@since 08/03/2019
/*/
//-------------------------------------------------------------------
Static Function mountLnCEF(cContent,oResponse,nI)

	oResponse[nI]['chaveSigajuri'] := JExtSubStr(cContent,20,4) + "/" + JExtSubStr(cContent,24,3) + "/" + JExtSubStr(cContent,27,8) + "-" + JExtSubStr(cContent,35,1)
	oResponse[nI]['processo']      := JExtSubStr(cContent,151,20)
	oResponse[nI]['autor']         := JExtSubStr(cContent,171,45)
	oResponse[nI]['reu']           := JExtSubStr(cContent,230,45)
	oResponse[nI]['depositante']   := JExtSubStr(cContent,306,70)
	oResponse[nI]['saldoCapital']  := Val(JExtSubStr(cContent,295,11, "N")) / 100
	oResponse[nI]['saldoDataBase'] := 0
	oResponse[nI]['justica']       := JExtSubStr(cContent,3,11)
	oResponse[nI]['tipoExtrato']   := 'CEF'

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} J267RdBB
Função que lê layout de relatório de depositos judiciais em TXT (BB)

@param  cArquivo - Arquivo XML
@param  cTab     - Tabela que será inserida os dados do extrato
@Return oResponse - Json com a estrutura separada por justiça

@author Brenno Gomes
@since 06/02/2019
/*/
//-------------------------------------------------------------------
Function J267RdBB(cArquivo,cTab)
Local oResponse  := JsonObject():New()
Local cPesq      := 'Justiça:'
Local cPesCta    := 'Cta. Judicial'
Local cContent   := ""
Local cChave     := ""
Local cJust      := ""
Local nIndJust   := 0
Local nPos       := 0
Local nLineJust  := 0
Local lRet       := .T.
Local lPulaLin   := .F.
Local oFile      := Nil

Default cArquivo := ""
Default cTab     := Nil

	oFile := FWFileReader():New( CopyFile(Alltrim(cArquivo)) )
	oResponse['operation'] := "ReadLayout"
	oResponse['data']      := {}

	If cTab != Nil
		DbSelectArea(cTab)
	EndIf

	If (oFile:Open())
		While (oFile:hasLine()) .AND. lRet
			cContent := oFile:GetLine()

			If !Empty(cContent)
				lPulaLin   := .F.
				If !("BANCO DO BRASIL" $ UPPER(cContent) ) .AND. (nIndJust == 0) .AND. AT( cPesq, cContent ) == 0 //-- BB
					lRet := .F.
				EndIf

				If (nPos := AT( cPesq, cContent )) > 0
					If !Empty(cJust)
						Conout(STR0060 + JurLmpCpo(Alltrim(cJust)) +" - "+ STR0061 + cValtoChar(nLineJust) ) //STR0060 "Hemisferio : "   //STR0061 "Quantidade de Depositos: "
					EndIf

					cJust := Substr(cContent,nPos + 9,40)//Justiça: ######...

					If nIndJust > 0
						oResponse['data'][nIndJust]['length'] := nLineJust
					EndIf
					nIndJust++
					Aadd(oResponse['data'], JsonObject():New())
					oResponse['data'][nIndJust]['hemisferio'] := JurEncUTF8(Alltrim(cJust))
					oResponse['data'][nIndJust]['length']     := 0
					oResponse['data'][nIndJust]['info']       := {}
					nLineJust := 0 // Zerando o total da justiça anterior

				EndIf
				If !Empty(cJust) .And. !Empty(Substr(cContent,2,13)) .And. Substr(cContent,2,13) <> cPesCta
					If Empty(cTab)
						nLineJust ++
						aAdd(oResponse['data'][nIndJust]['info'], JSonObject():New())
						oResponse['data'][nIndJust]['info'] := mountLnBB(cContent,@oResponse['data'][nIndJust]['info'],nLineJust,JurEncUTF8(Alltrim(cJust)))
					Else
						cChave := JExtSubStr(cContent,2,13) + cValToChar(Val(JExtSubStr(cContent,16,4)))

						If cChave == "0"
							cChave := ""
						EndIf

						If Reclock( cTab , .T. )
							(cTab)->(FieldPut(JUSTICA      , JurEncUTF8(Alltrim(cJust))                                             )) //'Justiça'
							(cTab)->(FieldPut(CHAVE        , cChave                                                                 )) //'Chave Sigajuri'
							(cTab)->(FieldPut(PROCESSO     , JExtSubStr(cContent,20,21)                                             )) //'Processo'
							(cTab)->(FieldPut(AUTOR        , JExtSubStr(cContent,41,18)                                             )) //'Autor'
							(cTab)->(FieldPut(REU          , JExtSubStr(cContent,59,18)                                             )) //'Reu'
							(cTab)->(FieldPut(DEPOSITANTE  , JExtSubStr(cContent,77,19)                                             )) //'Depositante'
							(cTab)->(FieldPut(SALDOCAPITAL , Val(JExtSubStr(cContent,96,18, "N"))                                        )) //'Saldo Capital'
							(cTab)->(FieldPut(SALDODATABASE, Val(JExtSubStr(cContent,114,19, "N"))                                       )) //'Saldo DataBase'
							(cTab)->(FieldPut(CONTAJUDICIAL, JExtSubStr(cContent,2,13)                                              )) //'Conta Judícial'
							(cTab)->(FieldPut(TIPOEXTRATO  , 'BB'                                                                   )) //'Tipo Extrato'
							(cTab)->(MsUnlock())
						EndIf
					EndIf
				EndIf

			ElseIf lPulaLin
				lRet := .F.
			Else
				lPulaLin := .T.
			EndIf

			If !lRet
				Exit
			EndIf
		EndDo

		If !Empty(cJust)
			Conout(STR0060 + JurLmpCpo(Alltrim(cJust)) +" - "+ STR0061 + cValtoChar(nLineJust) ) //STR0060 "Hemisferio : "   //STR0061 "Quantidade de Depositos: "
		EndIf
		If nIndJust > 0
			oResponse['data'][nIndJust]['length'] := nLineJust
		EndIf

		oFile:Close()
	Else
		lRet := .F.//não realizou a abertura do arquivo (para automação)
	EndIf
Return {lRet,oResponse}

//-------------------------------------------------------------------
/*/{Protheus.doc} J267RdCEF
Função que lê layout de relatório de depositos judiciais em TXT (CEF)

@param  cArquivo - Arquivo XML
@param  cTab     - Tabela que será inserida os dados do extrato
@Return oResponse - Json com a estrutura separada por justiça

@author Brenno Gomes
@since 08/03/2019
/*/
//-------------------------------------------------------------------
Function J267RdCEF(cArquivo,cTab)
Local oResponse  := JsonObject():New()
Local cPesq      := 'AGENOPECONTA'
Local cJust      := ""
Local cContent   := ""
Local nIndJust   := 0
Local nLineJust  := 0
Local lRet       := .T.
Local oFile      := Nil

Default cArquivo := ""
Default cTab     := Nil

	oFile := FWFileReader():New( CopyFile(Alltrim(cArquivo)) )
	oResponse['operation'] := "ReadLayout"
	oResponse['data']      := {}

	If cTab != Nil
		DbSelectArea(cTab)
	EndIf

	If (oFile:Open())
		While (oFile:hasLine()) .AND. lRet
			cContent := oFile:GetLine()

			If !Empty(cContent)
				If !("TP JUSTICA   NSU" $ cContent ) .AND. (nIndJust == 0) //-- CEF
					lRet := .F.
					Exit
				EndIf

				If AT( cPesq, cContent ) == 0//Verifica se não está na linha no cabeçalho
					If Empty(cJust)//se tiver vazio, significa que o hemisf foi trocado Ou está no inicio do arquivo
						cJust := Substr(cContent,3,11)//Justiça: ######...
						Aadd(oResponse['data'], JsonObject():New())
						oResponse['data'][nIndJust]['hemisferio'] := JurEncUTF8(Alltrim(cJust))
						oResponse['data'][nIndJust]['length']     := 0
						oResponse['data'][nIndJust]['info']       := {}
					EndIf
				Else
					If nIndJust > 0
						oResponse['data'][nIndJust]['length'] := nLineJust
					EndIf
					nIndJust++
					cJust := ""
					nLineJust := 0 // Zerando o total da justiça anterior
				EndIf

				If !Empty(cJust)
					If Empty(cTab)
						nLineJust ++
						aAdd(oResponse['data'][nIndJust]['info'], JSonObject():New())
						oResponse['data'][nIndJust]['info'] := mountLnCEF(cContent,@oResponse['data'][nIndJust]['info'],nLineJust)
					Else
						// Reclock para Inserir o Registro na Tabela
						If Reclock( cTab , .T. )
							(cTab)->(FieldPut(JUSTICA      , JExtSubStr(cContent,3,11)                                                                                                       )) //'Justiça'
							(cTab)->(FieldPut(CHAVE        , JExtSubStr(cContent,20,4) + "/" + JExtSubStr(cContent,24,3) + "/" + JExtSubStr(cContent,27,8) + "-" + JExtSubStr(cContent,35,1) )) //'Chave Sigajuri'
							(cTab)->(FieldPut(PROCESSO     , JExtSubStr(cContent,151,20)                                                                                                     )) //'Processo'
							(cTab)->(FieldPut(AUTOR        , JExtSubStr(cContent,171,45)                                                                                                     )) //'Autor'
							(cTab)->(FieldPut(REU          , JExtSubStr(cContent,230,45)                                                                                                     )) //'Reu'
							(cTab)->(FieldPut(DEPOSITANTE  , JExtSubStr(cContent,306,70)                                                                                                     )) //'Depositante'
							(cTab)->(FieldPut(SALDOCAPITAL , Val(JExtSubStr(cContent,295,11, "N")) / 100                                                                                          )) //'Saldo Capital'
							(cTab)->(FieldPut(SALDODATABASE, 0                                                                                                                               )) //'Saldo DataBase'
							(cTab)->(FieldPut(CONTAJUDICIAL, ''                                                                                                                              )) //'Conta Judícial'
							(cTab)->(FieldPut(TIPOEXTRATO  , 'CEF'                                                                                                                           )) //'Tipo Extrato'
							(cTab)->(MsUnlock())
						EndIf
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIf

			If !lRet
				Exit
			EndIf
		End
		If !Empty(cJust)
			Conout(STR0060 + JurLmpCpo(Alltrim(cJust)) +" - "+ STR0061 + cValtoChar(nLineJust) ) //STR0060 "Hemisferio : "   //STR0061 "Quantidade de Depositos: "
		EndIf
		If nIndJust > 0
			oResponse['data'][nIndJust]['length'] := nLineJust
		EndIf
		oFile:Close()
	Else
		lRet := .F.//não realizou a abertura do arquivo (para automação)
	EndIf
Return {lRet,oResponse}

//-------------------------------------------------------------------
/*/{Protheus.doc} J267RdRCF
Leitura do XML de Extrato - Recursal

@param  cArquivo - Arquivo XML
@param  cTab     - Tabela que será inserida os dados do extrato

@Return oResponse - Json com a os dados de depósicos Recursais

@author sigajuri
@since 15/03/2019
/*/
//-------------------------------------------------------------------
Function J267RdRCF(cArquivo,cTab)

Local oResponse := JsonObject():New()
Local aChild    := {}
Local lRet      := .F.
Local cReu      := ''
Local cPath     := '/relatorio/dados'
Local cPathLin  := '/linha[#1]'
Local cPathCol  := '/col[#2]'
Local cPathQubr := '/quebra[#1]/legenda[#2]/col[#2]'
Local nQuant    := 0
Local nI        := 1
Local nC        := 1
Local oXML      := Nil

Default cArquivo := ''
Default cTab     := Nil

	If ".rml" $ Lower(cArquivo)
		lRet := .T.
	EndIf

	If lRet
		oResponse['data'] := {}
		oXML   := TXmlManager():New()
		lRet   := oXML:ReadFile(CopyFile(cArquivo))
		nQuant := oXML:XPathChildCount(cPath)

		If cTab != Nil
			DbSelectArea(cTab)
		EndIf

		If lRet .AND. nQuant > 0

			//-- Reu
			If oXML:XPathHasNode(cPath + I18n('/quebra[#1]/legenda[#1]' ,{1}))
				cReu := oXML:XPathGetNodeValue(cPath + I18n(cPathQubr,{1,2,2}))
			EndIf

			Aadd(oResponse['data'], JsonObject():New())
			oResponse['data'][1]['info'] := {}

			//-- Busca as informações em cada nó filho
			While oXML:XPathHasNode(cPath + I18n(cPathLin ,{nI}))

				nQuant := oXML:XPathChildCount(cPath + I18n(cPathLin ,{nI}))

				For nC := 1 to nQuant
					aAdd(aChild,oXML:XPathGetNodeValue(cPath + I18n(cPathLin + cPathCol,{nI,nC})))
				Next nC

				aChild[2] := cValToChar(Val(aChild[2]))
				aChild[7] := Val(JExtSubStr(aChild[7],/*cIni*/,/*nQtdCarac*/,"N"))

				If Empty(cTab)
					aAdd(oResponse['data'][1]['info'], JSonObject():New())

					//-- Guarda os dados de cada linha do extrato
					oResponse['data'][1]['info'][nI]['chaveSigajuri'] := aChild[2]
					oResponse['data'][1]['info'][nI]['processo']      := aChild[10]
					oResponse['data'][1]['info'][nI]['autor']         := aChild[1]
					oResponse['data'][1]['info'][nI]['reu']           := cReu
					oResponse['data'][1]['info'][nI]['depositante']   := ""
					oResponse['data'][1]['info'][nI]['saldoCapital']  := aChild[7]
					oResponse['data'][1]['info'][nI]['saldoDataBase'] := (0)
					oResponse['data'][1]['info'][nI]['justica']       := "Trabalhista"
					oResponse['data'][1]['info'][nI]['tipoExtrato']   := "RCCEF"
				Else
					If Reclock( cTab , .T. )
						(cTab)->(FieldPut(JUSTICA      , "Trabalhista"              ))  //'Justiça'
						(cTab)->(FieldPut(CHAVE        , aChild[2]                  ))  //'Chave Sigajuri'
						(cTab)->(FieldPut(PROCESSO     , aChild[10]                 ))  //'Processo'
						(cTab)->(FieldPut(AUTOR        , aChild[1]                  ))  //'Autor'
						(cTab)->(FieldPut(REU          , cReu                       ))  //'Reu'
						(cTab)->(FieldPut(DEPOSITANTE  , ''                         ))  //'Depositante'
						(cTab)->(FieldPut(SALDOCAPITAL , aChild[7]                  ))  //'Saldo Capital'
						(cTab)->(FieldPut(SALDODATABASE, 0                          ))  //'Saldo DataBase'
						(cTab)->(FieldPut(CONTAJUDICIAL, ''                         ))  //'Conta Judícial'
						(cTab)->(FieldPut(TIPOEXTRATO  , 'RCCEF'                    ))  //'Tipo Extrato'
						(cTab)->(MsUnlock())
					EndIf
				EndIf

				aSize(aChild,0)
				nI++
			EndDo
		EndIf
	EndIf
Return {lRet,oResponse}

//-------------------------------------------------------------------
/*/{Protheus.doc} RetArquivo
Retorna nome do arquivo.

@author Rafael Tenorio da Costa
@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function RetArquivo(cPatchArq, lExtensao)
Local nPos     := 0
Local cArquivo := ""

	Default lExtensao := .F. //Define se sera retornada a extensao do arquivo

	nPos     := Rat("\", cPatchArq)
	cArquivo := SubStr(cPatchArq, nPos + 1)

	If !lExtensao
		nPos     := Rat(".", cArquivo)
		cArquivo := SubStr(cArquivo, 1, nPos - 1)
	EndIf

Return cArquivo

//-------------------------------------------------------------------
/*/{Protheus.doc} CopyFile
Gera uma cópia do arquivo na pasta SPOOL

@author Willian Kazahaya
@since 06/02/2019
/*/
//-------------------------------------------------------------------
Static Function CopyFile(cFile)
Local cDestino := "\SPOOL\"
Local cName    := RetArquivo(cFile, .T.)
Local lRet     := .F.

	lRet := _CopyFile(cFile, cDestino + cName)
	If !lRet
		conout(STR0062) //"Erro ao copiar o arquivo !"
	EndIf
Return cDestino + cName

//-------------------------------------------------------------------
/*/{Protheus.doc} J267GetFld
Função para pegar o caminho do Arquivo

@author Willian Kazahaya
@since 06/02/2019
/*/
//-------------------------------------------------------------------
Function J267GetFld()
Local cFolder := cGetFile('Arquivos |*.*','',,,,176)
Return cFolder

//-------------------------------------------------------------------
/*/{Protheus.doc} JA020Export(oObjTab)
Gera o arquivo .xls do relatório de Conciliação de Depósitos Jurídicos.

@param oObjTab     Objeto da tabela temporária de Extratos

@return Nil

@author nishizaka.cristiane
@since  18/01/2019
/*/
//--------------------------------------------------------
Static Function JA267Expor(oObjTab,oObjTabGar)

Local oExcel     := FWMSEXCEL():New()

Local cArquivo  := AllTrim(MV_PAR01)
Local cRelac    := AllTrim(MV_PAR02)

Local aAux       := {"","","","","","","",""}
Local aCamps     := {}
Local aDados     := {}
Local aDetExt    := {}
Local aTitColExt := {}
Local aTitColAss := {}
Local aExtratos  := {}
Local aDadosDate := {}
Local cExtens    := "Arquivo" + " XLS | *.xls"
Local cArq       := ""
Local cFunction  := "CpyS2TW"
Local cPathS     := "\SPOOL\"  //Caminho onde o arquivo será gerado no servidor
Local cTipoExt   := ""
Local cAssJur    := ""
Local cData      := ""
Local aResArea   := ""
Local aResTotal  := ""
Local cTabName   := STR0010 //"Conciliação de Depósitos Judiciais"
Local cWrkSName  := STR0059 //"Resumo"
Local nI,nX,nY   := 0
Local nTipo      := 0
Local nD         := 0
Local nPosDel    := 0
Local nPosTipAss := 0
Local lHtml      := (GetRemoteType() == 5)  //Valida se o ambiente é SmartClientHtml

Default oObjTab    := Nil
Default oObjTabGar := Nil

	If Empty(cRelac)
		cRelac := "NT2_CONJUD"
	EndIf

	//Escolha o local para salvar o arquivo
	//Se for o html, não precisa escolher o arquivo
	If !lHtml
		cArq := cGetFile(cExtens, STR0011, , 'C:\', .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), .F.)  //"Salvar como"
	Else
		cArq := cPathS + JurTimeStamp(1) + "_" + cTabName + "_" + RetCodUsr()
	Endif

	If At(".xls",cArq) == 0
		cArq += ".xls"
	Endif

	//RESUMO ----------------------------------------------------------------------------------------------------
	aTitColRes := JGtColsRes()

	aResArea  := JGetResumo(cRelac,oObjTab, oObjTabGar )
	aResTotal := JGetTotal(aResArea)

	IncProc("Gerando aba de Resumo")
	//Adiciona a aba Resumo
	oExcel:AddworkSheet(cWrkSName)
	oExcel:AddTable(cWrkSName, cTabName)
	//Cria as colunas da tabela
	For nX := 1 To Len(aTitColRes)
		Do Case
			Case aTitColRes[nX][2] == 'C'
				nTipo := 1
			Case aTitColRes[nX][2] == 'N'
				nTipo := 2
			Case aTitColRes[nX][2] == 'D'
				nTipo := 4
		EndCase
		oExcel:AddColumn(cWrkSName /*cWorkSheet*/,cTabName /*cTable*/,;
				         aTitColRes[nX][1] /*Título*/, 2 /*nAlign*/,nTipo /*nFormat*/,.F. /*lTotal*/)
	Next nX

	//Tipo de Assunto Jurídico
	For nI := 1 To Len(aResArea)
		For nY := 1 to Len(aResArea[nI])
			//Popula as linhas da tabela
			oExcel:AddRow(cWrkSName /*cWorkSheet*/,cTabName /*cTable*/,aResArea[nI][nY] /*aRow*/)
		Next nY
		//Quebra de linha
		oExcel:AddRow(cWrkSName /*cWorkSheet*/,cTabName /*cTable*/,aAux /*aRow*/)
	Next nI
	//Totais
	For nY := 1 To Len(aResTotal)
		//Popula as linhas da tabela
		oExcel:AddRow(cWrkSName /*cWorkSheet*/,cTabName /*cTable*/,aResTotal[nY] /*aRow*/)
	Next nY

	IncProc(STR0069) //"Gerando aba de assuntos juridicos"
	//TIPOS DE ASSUNTOS JURIDICOS -------------------------------------------------------------------------------
	aTitColAss := JGtColsGar(.T.)
	aTitColAss := JGtClsTmpG(.T.,aTitColAss)
	aTitColAss := JGtColsExt(.T.,aTitColAss)

	aDados    := JGetGarant(oObjTab,oObjTabGar)
	nPosTipAss := aScan(aTitColAss, {|x| x[2] == "TipAssJur" })

	If Len(aDados) > 0
		For nI := 1 To Len(aDados)
			//A cada novo Assunto Jurídico
			If cAssJur <> aDados[nI][nPosTipAss]
				cAssJur := aDados[nI][nPosTipAss]
				aSize(aDadosDate,0)

				//Adiciona as abas de Assuntos Jurídicos
				oExcel:AddworkSheet(AllTrim(aDados[nI][nPosTipAss]))
				oExcel:AddTable (AllTrim(aDados[nI][nPosTipAss]), cTabName + ' ' + AllTrim(aDados[nI][nPosTipAss]))
				//Cria as colunas da tabela
				For nX := 1 To Len(aTitColAss)
					Do Case
						Case aTitColAss[nX][3] == 'C'
							nTipo := 1
						Case aTitColAss[nX][3] == 'N'
							nTipo := 2
						Case aTitColAss[nX][3] == 'D'
							nTipo := 4
							aAdd(aDadosDate,nX)
					EndCase

					oExcel:AddColumn(AllTrim(aDados[nI][nPosTipAss]) /*cWorkSheet*/,cTabName + ' ' + AllTrim(aDados[nI][nPosTipAss]) /*cTable*/,;
							         aTitColAss[nX][1] /*Título*/, 2 /*nAlign*/,nTipo /*nFormat*/,.F. /*lTotal*/)
				Next nX
			EndIf

			For nD := 1 To Len(aDadosDate)
				aDados[nI][aDadosDate[nD]] := SToD(aDados[nI][aDadosDate[nD]])
			Next nD

			//Popula as linhas da tabela
			oExcel:AddRow(AllTrim(aDados[nI][nPosTipAss]) /*cWorkSheet*/,AllTrim(cTabName + ' ' + AllTrim(aDados[nI][nPosTipAss])) /*cTable*/,aDados[nI] /*aRow*/)
		Next nI
	EndIf

	IncProc(STR0070) //"Gerando abas de extratos"
	//EXTRATOS ----------------------------------------------------------------------------------------------------
	aTitColExt:= JGtColsTmp()
	aExtratos := JGtListExt()

	For nX := 1 To Len(aExtratos)
		aDados    := JQryExtrat(oObjTab, aExtratos[nX][2])
		If Len(aDados) > 0
			//Adiciona as abas de Extratos
			oExcel:AddworkSheet(aExtratos[nX][1])
			oExcel:AddTable (aExtratos[nX][1], cTabName)
			//Cria as colunas da tabela
			For nI := 1 To Len(oObjTab:ostruct:aFields)
				If aScan(aTitColExt, {|x| AllTrim(x[2]) == AllTrim(oObjTab:ostruct:aFields[nI][1])}) > 0
					Do Case
						Case oObjTab:ostruct:aFields[nI][2] == 'C'
							nTipo := 1
						Case oObjTab:ostruct:aFields[nI][2] == 'N'
							nTipo := 2
						Case oObjTab:ostruct:aFields[nI][2] == 'D'
							nTipo := 4
					EndCase
					oExcel:AddColumn(aExtratos[nX][1] /*cWorkSheet*/,cTabName /*cTable*/,aTitColExt[nI][1] /*Título*/,;
					                 2 /*nAlign*/,nTipo /*nFormat*/,.F. /*lTotal*/)
				EndIf
			Next nI
			//Popula as linhas da tabela
			For nY := 1 To Len(aDados)
				oExcel:AddRow(aExtratos[nX][1] /*cWorkSheet*/,cTabName /*cTable*/,aDados[nY] /*aRow*/)
			Next nY
		EndIf
	Next nX

	oExcel:Activate()

	If oExcel:GetXMLFile(cArq)
		If !lHtml

			If ApMsgYesNo(I18n(STR0031,{cArq}))	//"Deseja abrir o arquivo #1 ?"
				If !File(cArq)
					ApMsgYesNo(I18n(STR0032,{cArq}))	//"O arquivo #1 não pode ser aberto "
				Else
					nRet := ShellExecute('open', cArq , '', "C:\", 1)
				EndIf
			EndIf

		ElseIf FindFunction(cFunction)
			//Executa o download no navegador do cliente
			nRet := CpyS2TW(cArq,.T.)
			If nRet == 0
				MsgAlert(STR0033 + cArq)	//"Arquivo gerado com sucesso, caminho: "
			Else
				JurMsgErro(STR0034)	//STR0034 //"Erro ao efetuar o download do arquivo"
			EndIf
		Endif
	Else
		JurMsgErro(STR0035)	//STR0035 //"Erro ao gerar arquivo"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryExtrat(oObjTab, cLayout)

Lista o conteúdo dos Extratos Bancários por layout.

@param oObjTab    Objeto da tabela temporária de Extratos
@param cLayout    Nome do Layout do Extrato

@return aRet      Array com o conteúdo do extrato extraído da tabela
		          temporária, de acordo com o layout do parâmetro.

@since  20/03/2019
/*/
//--------------------------------------------------------
Static Function JQryExtrat(oObjTab, cLayout)

Local aRet       := {}
Local cQuery     := ""
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryOrd    := ""

Default oObjTab  := Nil
Default cLayout  := ""

	cTabRealNm := oObjTab:GetRealName()
	cQrySel := " SELECT TMP_JUSTI, "
	cQrySel +=        " TMP_CHAVE, "
	cQrySel +=        " TMP_NUMPRO, "
	cQrySel +=        " TMP_AUTOR, "
	cQrySel +=        " TMP_REU, "
	cQrySel +=        " TMP_DEPOSI, "
	cQrySel +=        " TMP_SLDCAP, "
	cQrySel +=        " TMP_SLDDBS, "
	cQrySel +=        " TMP_CNTJUD "
	cQryFrm := " FROM " + cTabRealNm + " EXTRATO "

	If !Empty(cLayout)
		cQryWhr := " WHERE EXTRATO.TMP_TIPEXT = '" + cLayout + "' "
	EndIf

	cQryOrd := " ORDER BY EXTRATO.TMP_TIPEXT "

	//Concatenação das clausulas
	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd

	aRet := JurSQL(cQuery,{'TMP_JUSTI' , 'TMP_CHAVE' , 'TMP_NUMPRO', 'TMP_AUTOR' , 'TMP_REU',;
	                       'TMP_DEPOSI', 'TMP_SLDCAP', 'TMP_SLDDBS', 'TMP_CNTJUD'})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetGarant

Lista as Garantias X Extratos

@param oObjTab    Objeto da tabela temporária de Extratos

@return aRet      Array com as garantias

@since  20/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGetGarant(oObjTable,oObjTabGar)
Local aRet       := {}
Local aCampQry   := {}
Local aRetQry    := {}
Local nX         := 0

Default oObjTable  := Nil
Default oObjTabGar := Nil

	aCampQry := JGtColsGar(.T.)
	aCampQry := JGtClsTmpG(.T.,aCampQry)
	aCampQry := JGtColsExt(.T.,aCampQry)

	cQuery := JQryGarant(/*cRelac*/, oObjTable, oObjTabGar)
	cQuery := ChangeQuery(cQuery)

	For nX := 1 To Len(aCampQry)
		aAdd(aRetQry, aCampQry[nX][2])
	Next nX

	aRet := JurSQL(cQuery, aRetQry)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JStruExt
Struct da Tabela Temporária de Extrato
@return aStruct - Estrutura da TMP Extrato

@since  27/03/2019
/*/
//-------------------------------------------------------------------
Static Function JStruExt(cChave)
Local aStruct   := {}
Local nTamChave := TamSx3(cChave)[1]

	//            { Nome do campo, Tipo, Tamanho   , Decimal}
	Aadd(aStruct, { 'TMP_JUSTI'  , 'C' , 40        , 0      } ) //'Justiça'
	Aadd(aStruct, { 'TMP_CHAVE'  , 'C' , nTamChave , 0      } ) //'Chave Sigajuri'
	Aadd(aStruct, { 'TMP_NUMPRO' , 'C' , 20        , 0      } ) //'Numero do Processo'
	Aadd(aStruct, { 'TMP_AUTOR'  , 'C' , 18        , 0      } ) //'Autor'
	Aadd(aStruct, { 'TMP_REU'    , 'C' , 18        , 0      } ) //'Reu'
	Aadd(aStruct, { 'TMP_DEPOSI' , 'C' , 19        , 0      } ) //'Depositante'
	Aadd(aStruct, { 'TMP_SLDCAP' , 'N' , 18        , 2      } ) //'Saldo Capital'
	Aadd(aStruct, { 'TMP_SLDDBS' , 'N' , 19        , 2      } ) //'Saldo DataBase'
	Aadd(aStruct, { 'TMP_CNTJUD' , 'C' , 19        , 0      } ) //'Conta Judicial'
	Aadd(aStruct, { 'TMP_TIPEXT' , 'C' , 06        , 0      } ) //'Tipo de extrato'
Return aStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} JStruGar
Struct da Tabela Temporária de Garantias para inserir o Saldo
@return aStruct - Estrutura da TMP Extrato

@since  27/03/2019
/*/
//-------------------------------------------------------------------
Static Function JStruGar()
Local aStruct := {}
Local nTamCodGar := TamSx3("NT2_COD")[1]

	//            { Nome do campo, Tipo, Tamanho   , Decimal}
	Aadd(aStruct, { 'TMP_CODGAR' , 'C' , nTamCodGar, 0      } ) //'Justiça'
	Aadd(aStruct, { 'TMP_CAJURI' , 'C' , 10        , 0      } ) //'Justiça'
	Aadd(aStruct, { 'TMP_SLDGAR' , 'N' , 18        , 2      } ) //'Saldo Capital'
Return aStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtColsGar
Array com os campos do Select. Utilizado na construção do Excel

@param aCols     Array com Colunas pré-existente

@return aCols    Array com os campos da Garantia

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGtColsGar(lFiltVis, aCols)
Default aCols := {}
Default lFiltVis := .F.
	aAdd(aCols,{STR0036 , 'CodGar'    , 'C', "NT2.NT2_COD"})    //'Id Garantia'
	aAdd(aCols,{STR0038 , 'Cajuri'    , 'C', "NSZ.NSZ_COD"})    //'Código Interno'
	aAdd(aCols,{STR0039 , 'NumCaso'   , 'C', "NSZ.NSZ_NUMCAS"}) //'Número do Caso'
	aAdd(aCols,{STR0041 , 'DescArea'  , 'C', "NRB.NRB_DESC"})   //'Área Juridica'
	aAdd(aCols,{STR0043 , 'TipAssJur' , 'C', "NYB.NYB_DESC"})   //'Tipo Ass. Jurídico'
	aAdd(aCols,{STR0022 , 'NomeAutor' , 'C', "NT901.NT9_NOME"}) //'Autor'
	aAdd(aCols,{STR0023 , 'NomeReu'   , 'C', "NT902.NT9_NOME"}) //'Réu'
	aAdd(aCols,{STR0044 , 'NumProc'   , 'C', "NUQ.NUQ_NUMPRO"}) //'Numero do Processo'
	aAdd(aCols,{STR0071 , 'TipGarant' , 'C', "NQW.NQW_DESC"})   //'Tipo da Garantia'
	aAdd(aCols,{STR0045 , 'GData'     , 'D', "NT2.NT2_DATA"})   //'Data'
	aAdd(aCols,{STR0046 , 'GValor'    , 'N', "NT2.NT2_VALOR"})  //'Valor Inicial'

	// Campos utilizados em Processamento, mas não utilizados na Exibição
	If !lFiltVis
		aAdd(aCols,{STR0072 , 'FilialGar'    , 'C', "NT2.NT2_FILIAL"})    //'Código Interno'
	EndIf
Return aCols

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtColsExt
Array com os campos do Extrato. Utilizado na construção do Excel

@param aCols     Array com Colunas pré-existente

@return aCols    Array com os campos do Extrato

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGtColsExt(lFiltVis, aCols)
Default aCols    := {}
Default lFiltVis := .F.

	aAdd(aCols,{STR0054     , 'TipoExtrat', 'C', "EXTRATO.TMP_TIPEXT"}) //'Tipo do Extrato'
	aAdd(aCols,{STR0073     , 'ContaJudic', 'C', "EXTRATO.TMP_CNTJUD"}) //'Conta Judicial'
	aAdd(aCols,{STR0019     , 'Justic'    , 'C', "EXTRATO.TMP_JUSTI"})  //'Justiça'
	aAdd(aCols,{STR0051     , 'Chave'     , 'C', "EXTRATO.TMP_CHAVE"})  //'Chave'
	aAdd(aCols,{STR0052     , 'NumProExt' , 'C', "EXTRATO.TMP_NUMPRO"}) //'Num. Processo'
	aAdd(aCols,{STR0022     , 'Autor'     , 'C', "EXTRATO.TMP_AUTOR"})  //'Autor'
	aAdd(aCols,{STR0053     , 'Reu'       , 'C', "EXTRATO.TMP_REU"})    //'Reu'
	aAdd(aCols,{STR0024     , 'Deposito'  , 'C', "EXTRATO.TMP_DEPOSI"}) //'Depositante'
	aAdd(aCols,{STR0025     , 'SaldoCap'  , 'N', "EXTRATO.TMP_SLDCAP"}) //'Saldo Capital'
	aAdd(aCols,{STR0074     , 'SldDataBas', 'N', "EXTRATO.TMP_SLDDBS"}) //'Saldo Capital'
Return aCols

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtClsTmpG
Array com os campos da Tab. Temp. de Saldos. Utilizado na construção do Excel

@param aCols     Array com Colunas pré-existente

@return aCols    Array com os campos do Extrato

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGtClsTmpG(lFiltVis, aCols)
Default aCols := {}
Default lFiltVis := .F.
	aAdd(aCols,{STR0077 , "SldGarant", "N", "TMP_SLDGAR"}) //"Saldo Garantia "

	If !lFiltVis
		aAdd(aCols,{STR0075 , "CodGarTmp", "N", "TMP_CODGAR"}) //"Código Garantia"
		aAdd(aCols,{STR0076 , "CodCajTmp", "N", "TMP_CAJURI"}) //"Código Interno"
	EndIf
Return aCols

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtColsRes
Lista de colunas que estarão presentes nas tabelas de resumo

@param aCols     Array com Colunas pré-existente

@return aCols    Array com os campos do Extrato

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGtColsRes(aCols)
Default aCols := {}
	aAdd(aCols,{''      , 'C'})
	aAdd(aCols,{STR0012 , 'C'}) //'Processos'
	aAdd(aCols,{STR0013 , 'N'}) //'Qtd'
	aAdd(aCols,{'%'     , 'N'})
	aAdd(aCols,{STR0014 , 'N'}) //'Saldo SIGAJURI'
	aAdd(aCols,{STR0015 , 'N'}) //'% Total'
	aAdd(aCols,{STR0016 , 'N'}) //'Saldo Bancos'
	aAdd(aCols,{STR0017 , 'N'})  //'Diferença'
Return aCols

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtColsTmp
Colunas da tabela temporária para as Tabelas da Aba de Extratos

@param aCols     Array com Colunas pré-existente

@return aCols    Array com os campos do Extrato

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGtColsTmp(aCols)
Default aCols := {}
	aAdd(aCols,{STR0019 ,'TMP_JUSTI'})  //'Justiça'
	aAdd(aCols,{STR0020 ,'TMP_CHAVE'})  //'Chave Sigajuri'
	aAdd(aCols,{STR0021 ,'TMP_NUMPRO'}) //'Número do Processo'
	aAdd(aCols,{STR0022 ,'TMP_AUTOR'})  //'Autor'
	aAdd(aCols,{STR0023 ,'TMP_REU'})    //'Réu'
	aAdd(aCols,{STR0024 ,'TMP_DEPOSI'}) //'Depositante'
	aAdd(aCols,{STR0025 ,'TMP_SLDCAP'}) //'Saldo Capital'
	aAdd(aCols,{STR0026 ,'TMP_SLDDBS'}) //'Saldo DataBase'
	aAdd(aCols,{STR0027 ,'TMP_CNTJUD'})  //'Conta Extrato'
Return aCols

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtListExt
Lista de Extratos a serem colocados no Relatório

@param aCols     Array com Colunas pré-existente

@return aCols    Array com os campos do Extrato

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGtListExt(aCols)
Default aCols := {}
	aAdd(aCols,{STR0028 , 'BB'})   //'Extrato BB'
	aAdd(aCols,{STR0029 , 'CEF'})  //'Extrato CEF'
	aAdd(aCols,{STR0030 , 'RCCEF'}) //'CEF Recursal'
Return aCols
//-------------------------------------------------------------------
/*/{Protheus.doc} JExtSubStr
Substr com validação do Type da Variavél. Prevenção para CHR(0) [Nul]
@param cString   - Conteudo
@param nIni      - Index inicial para o SubStr
@param nQtdCarac - Quantidade de Caracteres do SubStr
@param cTipo     - Tipo de dado para fazer o StrTran.
		[C] - Mantem o formato
		[N] - Remove os "." e troca o "," por "."

@return cReturn - Valor Tratado

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JExtSubStr(cString, nIni, nQtdCarac, cTipo)
Local cReturn     := ""

Default nIni      := 1
Default nQtdCarac := Len(cString)
Default cTipo     := "C"

	cReturn := Substr(cString,nIni,nQtdCarac)

	If (Empty(AllTrim(cReturn)) .Or. Type(cReturn) = 'U')
		cReturn := ""
	ElseIf cTipo = "N"
		cReturn := StrTran(StrTran(cReturn,".",""),",",".")
	EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtConjGrp
Array com o descritivo das linhas de cada Grid

@return Array com os descritivos das linhas

@since 25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JGtConjGrp()
	 //"Cabeçalho" "Conciliado" "Baixa Total" "Baixa Parcial" "Saldo maior no Banco" "Não identificados" "Baixados"
Return {STR0006    ,STR0007     ,STR0008     ,STR0003        ,STR0004                ,STR0005          /*,STR0063*/}

