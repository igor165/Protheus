#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA255.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Par�metros para execu��o via Schedule.

@author  Bruno Ritter | Jorge Martins
@since   09/02/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aOrd   := {}
Local aParam := {}

aParam := { "P"       ,; // Tipo R para relatorio P para processo
            "PARAMDEF",; // Pergunte do relatorio, caso nao use passar ParamDef
            ""        ,; // Alias
            aOrd      ,; // Array de ordens
          }
Return aParam

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA255
Posi��o Hist�rica do Contas a Receber.

@author  Cristina Cintra
@since   05/02/2018
@version 1.0
/*/
//------------------------------------------------------------------------------
Function JURA255()
Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001) // "Posi��o Hist�rica do Contas a Receber"
oBrowse:SetAlias("OHH")
oBrowse:SetLocate()
oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Cristina Cintra
@since   05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "VIEWDEF.JURA255", 0, 2, 0, NIL } ) // "Visualizar"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta o modelo de dados da Posi��o Hist�rica do Contas a Receber.

@return  oModel, objeto, Modelo de Dados

@author  Cristina Cintra
@since   05/02/2018
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel      := Nil
Local oStructOHH  := FWFormStruct(1, "OHH")
Local oCommit     := JA255COMMIT():New()
		
oModel := MPFormModel():New("JURA255")
	
oModel:AddFields("OHHMASTER",, oStructOHH)
oModel:InstallEvent("JA255COMMIT",, oCommit)

oModel:SetDescription(STR0001) // "Posi��o Hist�rica do Contas a Receber"
 
Return ( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA255COMMIT
Classe interna implementando o FWModelEvent, para execu��o de fun��o 
durante o commit.

@author  Cristina Cintra
@since   05/02/2018
@version 1.0
/*/
//------------------------------------------------------------------------------
Class JA255COMMIT FROM FWModelEvent

	Method New()
	Method ModelPosVld()
	Method InTTS()
	
End Class

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor FWModelEvent

@author	 Cristina Cintra
@since   05/02/2018
@version 1.0
/*/
//------------------------------------------------------------------------------
Method New() Class JA255COMMIT
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Modelo.

@author  Cristina Cintra
@since   05/02/2018
@version 1.0
@Obs     Valida��o criada para n�o permitir as opera��o de PUT e POST do REST
/*/
//------------------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA255COMMIT
Local nOperation := oModel:GetOperation()
Local lPosVld    := .T.
	
If nOperation <> MODEL_OPERATION_VIEW
	oModel:SetErrorMessage(,, oModel:GetId(),, "ModelPosVld", STR0003, STR0004,, ) // "Opera��o n�o permitida" # "Essa rotina s� permite a opera��o de visualiza��o!"
	lPosVld := .F.
EndIf
	
Return lPosVld

//------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es
por�m antes do final da transa��o

@author		Nivia Ferreira
@since		07/02/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA255COMMIT
	Local lIntFinanc  := SuperGetMV("MV_JURXFIN",, .F.)
	
	If lIntFinanc 
		JFILASINC(oSubModel:GetModel(),"OHH", "OHHMASTER", "OHH_PREFIX", "OHH_NUM", "OHH_PARCEL") // Fila de sincroniza��o
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA255S
Chamada via schedule para atualizar a posi��o do contas a receber referente ao ano-m�s atual

@author Bruno Ritter
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA255S(aParam)
Local cEmp  := ""
Local cFil  := ""
Local cUser := ""

	If !Empty(aParam) .And. Len(aParam) >= 3
		cEmp  := aParam[1]
		cFil  := aParam[2]
		cUser := aParam[3]

		RPCSetType(3) // Prepara o ambiente e n�o consome licen�a
		RPCSetEnv(cEmp, cFil, , , , "JURA255S")
		__cUserID := cUser
		J255UpdHis()
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA255M
Chamada via menu para atualizar a posi��o do contas a receber referente ao ano-m�s atual

@author Bruno Ritter
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA255M()
	Processa({|| J255UpdHis() }, STR0008) //  "Atualizando a posi��o do contas a receber..."
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J255UpdHis()
Atualiza a posi��o do contas a receber referente ao ano-m�s atual.

@author Bruno Ritter | Jorge Martins
@since 06/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J255UpdHis()
Local cQuery     := ""
Local cQryRes    := ""
Local nTotal     := 0
Local lViaTela   := !IsInCallStack("CheckTask") .And. !IsBlind() // Se n�o for Schedule e n�o for execu��o autom�tica
Local lIntFinanc := SuperGetMV("MV_JURXFIN",, .F.)
Local lExecuta   := .T.
Local lExecLote  := .T.
Local nCount     := 0

If FWAliasInDic("OHH")
	If lViaTela .And. !lIntFinanc
		JurMsgErro(STR0010,, STR0011) // "O par�metro MV_JURXFIN deve estar ativo para atualizar a posi��o hist�rica do contas a receber." "Verifique o par�metro MV_JURXFIN."
		lExecuta := .F.
	EndIf

	If lExecuta .And. lViaTela
		lExecuta := ApMsgYesNo(STR0005, STR0006 ) // "Deseja realmente atualizar a posi��o hist�rica?" // "ATEN��O:"
	EndIf

	If lExecuta
		dbSelectArea( 'OHH' ) // Cria a tabela caso ela n�o exista ainda no banco.

		cQryRes := GetNextAlias()
		cQuery  := J255QryOHH()
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

		BEGIN TRANSACTION
			If lViaTela //Conta a quantidade de registros
				dbSelectArea( cQryRes )
				Count To nTotal
				(cQryRes)->(DbGoTop())

				ProcRegua( nTotal )
			EndIf
		
			While !(cQryRes)->( EOF() )
				nCount++
				J255APosHis((cQryRes)->RECNO, dDataBase, lExecLote)

				(cQryRes)->( dbSkip() )
				If lViaTela
					IncProc( I18n(STR0012, {cValToChar(nCount), cValToChar(nTotal)}) ) //"#1 de #2."
				EndIf
			EndDo
		END TRANSACTION

		(cQryRes)->(DbCloseArea())

		If lViaTela
			If nTotal == 0
				ApMsgInfo( STR0009 ) // "N�o existem registros para atualizar."
			Else
				ApMsgInfo( I18n(STR0007, {cValToChar(nTotal)} ) ) // "Posi��o hist�rica foi atualizada com sucesso para #1 registros."
			EndIf
		EndIf
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J255QryOHH
Gera a query com os t�tulo que devem ser atualizados com posi��o do
contas a receber referente ao ano-m�s atual.

@return cQuery, Query dos t�tulos

@author Bruno Ritter
@since 07/02/2018
/*/
//-------------------------------------------------------------------
Static Function J255QryOHH()
Local cQuery   := ""
Local cAnoMes  := AnoMes(dDataBase)

	cQuery := " SELECT SE1.R_E_C_N_O_ RECNO "
	cQuery +=   " FROM " + RetSqlName( "SE1" ) + " SE1 "
	cQuery +=  " WHERE SE1.E1_FILIAL = '" + xFilial( "SE1" ) + "' " 
	cQuery +=    " AND SE1.E1_ORIGEM IN ('JURA203','FINA040', 'FINA460') "
	cQuery +=    " AND SE1.E1_TITPAI = '" + Space(TamSx3('E1_TITPAI')[1]) + "' "
	cQuery +=    " AND SE1.E1_SALDO > 0 "
	cQuery +=    " AND SE1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NOT EXISTS( SELECT 1 "
	cQuery +=                      " FROM " + RetSqlName( "OHH" ) + " OHH "
	cQuery +=                     " WHERE OHH.OHH_FILIAL = SE1.E1_FILIAL "
	cQuery +=                       " AND OHH.OHH_PREFIX = SE1.E1_PREFIXO "
	cQuery +=                       " AND OHH.OHH_NUM = SE1.E1_NUM "
	cQuery +=                       " AND OHH.OHH_PARCEL = SE1.E1_PARCELA "
	cQuery +=                       " AND OHH.OHH_TIPO = SE1.E1_TIPO "
	cQuery +=                       " AND OHH.OHH_ANOMES = '" + cAnoMes + "' "
	cQuery +=                       " AND OHH.D_E_L_E_T_ = ' ') "
	cQuery +=  " ORDER BY SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J255APosHis()
Atualiza a posi��o hist�rica do Contas a Receber (OHH).

@param nRecno,     Recno do t�tulo (SE1)
@param dNewDtMov,  Data da movimenta��o
@param lExecLote,  Indica se � uma execu��o em lote
@param aOHIBxAnt,  Valores de honor�rios e despesas utilizados para a fun��o de estorno
@param lGrParcAnt, Executa fun��o para gerar parcelas anteriores
@param nSaldoRet,  Saldo no momento do ajuste de base retroativo (usado somente via UPDRASTR)
@param lSincLG,    Indica se grava na fila de sincroniza��o
@param dDataBx,    Data da baixa do t�tulo (E1_BAIXA)

@author Bruno Ritter | Jorge Martins
@since 08/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J255APosHis(nRecno, dNewDtMov, lExecLote, aOHIBxAnt, lGrParcAnt, nSaldoRet, lSincLG, dDataBx)
Local aArea        := {}
Local nSaldo       := 0
Local nAbatimentos := 0
Local cAnoMesOHH   := ""
Local cTpEntr      := ""
Local cMoedaLanc   := ""
Local cOpcOHH      := ""
Local cAnoMesAtu   := AnoMes(Date()) // Date, pois a emiss�o da fatura altera o dDataBase
Local dDtOHH       := dDataBase
Local dDtMov       := Nil
Local dDtEmiSE1    := Nil
Local lInclui      := .F.
Local lEstorno     := FwIsInCallStack("JCancBaixa")
Local aSaldos      := {0, 0, 0, 0}
Local cTitulo      := ""
Local cFilFat      := xFilial("NXA")
Local nRecOld      := SE1->(Recno())
Local lDespTrib    := OHH->(ColumnPos("OHH_VLREMB")) > 0
Local lCpoSaldo    := OHH->(ColumnPos("OHH_SALDOH")) > 0
Local lCpoMoeda    := OHH->(ColumnPos("OHH_CMOEDC")) > 0
Local lCpoAbat     := OHH->(ColumnPos("OHH_ABATIM")) > 0
Local lCpoFat      := OHH->(ColumnPos("OHH_CFATUR")) > 0 // Prote��o
Local lZeraSaldo   := .F.
Local nIndexOHH    := IIf(lCpoFat, 3, 1)
Local aValorFat    := {}
Local nSomaAbat    := 0
Local nFat         := 0
Local nTotVlFatH   := 0
Local nTotVlFatD   := 0
Local nIRRF        := 0
Local nPIS         := 0
Local nCOFINS      := 0
Local nCSLL        := 0
Local nISS         := 0
Local nINSS        := 0
Local nTotIRRF     := 0
Local nTotPIS      := 0
Local nTotCOFINS   := 0
Local nTotCSLL     := 0
Local nTotISS      := 0
Local nTotINSS     := 0
Local nValTit      := 0

Default dNewDtMov  := Nil
Default lExecLote  := .F.
Default aOHIBxAnt  := {{"", "", 0, 0, 0, 0, 0, 0}}
Default lGrParcAnt := .T.
Default nSaldoRet  := 0
Default lSincLG    := .T.

If !Empty(dDataBx)
	cAnoMesAtu :=  AnoMes(dDataBx)
EndIf

If FWAliasInDic("OHH")
	
	SE1->(dbGoTo(nRecno))
	dDtEmiSE1 := SE1->E1_EMISSAO
	// Executa somente se o registro n�o estiver deletado
	If SE1->( ! Eof() ) .And. SE1->( ! Deleted() ) .And. !(AllTrim(SE1->E1_TIPO) $ "RA|PR") // T�tulos n�o tratados

		cTitulo := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

		If Type("lMigPFS") == "L" // Se for execu��o via migrador, faz ajustes de data conforme regras do migrador
			Iif(Empty(dMigDtBx), cAnoMesAtu := AnoMes(Date()), cAnoMesAtu := AnoMes(dMigDtBx))
		EndIf

		If !lExecLote
			aArea := GetArea()
			dbSelectArea( 'OHH' ) // Cria a tabela caso ela n�o exista ainda no banco.
		EndIf

		// Guarda o valor de impostos que ser� abatido para uso em relat�rios, visto que h� impostos como o ISS que podem estar sendo apenas destacados
		nSomaAbat := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO, SE1->E1_TIPO)

		// Valor de impostos e abatimentos dos t�tulos - Usado somente se o saldo estiver zerado
		nAbatimentos := Iif(SE1->E1_SALDO == 0, nSomaAbat, 0)

		// Indica se o t�tulo foi digitado manualmente (1) ou se gerado pelo SIGAPFS (2)
		cTpEntr    := Iif(AllTrim(SE1->E1_ORIGEM) == "FINA040" .Or. !JurIsJuTit(nRecno, FwIsInCallStack("JA203TIT")), "1", "2")
		cMoedaLanc := StrZero(SE1->E1_MOEDA, 2)

		// Se uma data de movimenta��o n�o for indicada, pega do campo E1_MOVIMEN
		If Empty(dNewDtMov)
			dDtMov := Iif(Empty(SE1->E1_MOVIMEN), SE1->E1_EMISSAO, SE1->E1_MOVIMEN)
		Else
			dDtMov := dNewDtMov
		EndIf

		dDtOHH     := Lastday(dDtMov) // Indica o �ltimo dia do m�s (data de fechamento)
		cAnoMesOHH := AnoMes(dDtOHH)

		aValorFat := J255VlrFat() // Valores das faturas (NXA/OHT) para gera��o da OHH
		
		// Totaliza os valores das faturas
		AEval(aValorFat, { |aX| nTotVlFatH += aX[1] , nTotVlFatD += aX[2] , ;
		                        nTotIRRF   += aX[9] , nTotPIS    += aX[10], ;
		                        nTotCOFINS += aX[11], nTotCSLL   += aX[12], ;
		                        nTotISS    += aX[13], nTotINSS   += aX[14] })

		// Indice 1 -> OHH_FILIAL + OHH_PREFIX + OHH_NUM    + OHH_PARCEL + OHH_TIPO + OHH_ANOMES
		// Indice 3 -> OHH_CESCR  + OHH_CFATUR + OHH_FILIAL + OHH_PREFIX + OHH_NUM  + OHH_PARCEL + OHH_TIPO + OHH_ANOMES
		OHH->(DBSetOrder(nIndexOHH))

		// Atualiza a posi��o hist�rica para todos os meses (retroativo) at� a data atual
		While cAnoMesOHH <= cAnoMesAtu

			cOpcOHH := "" // 3-Inclus�o, 4-Altera��o, 5-Exclus�o.
			
			If lCpoSaldo .And. !lExecLote .And. lGrParcAnt
				// Gera parcelas at� o no m�s atual para ratear o valor entre honor�rios e despesas.
				GrvParcAnt(lGrParcAnt, dDtOHH, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, lSincLG, dDataBx)
			EndIf

			For nFat := 1 To Len(aValorFat) // Atualiza a posi��o hist�rica para cada fatura vinculada ao t�tulo

				cEscrit := aValorFat[nFat][7]
				cFatura := aValorFat[nFat][8]

				// Valor do t�tulo (Caso seja uma liquida��o pega o valor da baixa feita pela liquida��o, sen�o pega da SE1)
				If !Empty(SE1->E1_NUMLIQ) .And. AliasInDic("OHT")
					nValTit := aValorFat[nFat][1] + aValorFat[nFat][2] // + aValorFat[nFat][15] // Honor�rios + Despesas + Acr�scimos
				Else
					nValTit := RatPontoFl(aValorFat[nFat][1] + aValorFat[nFat][2], nTotVlFatH + nTotVlFatD, SE1->E1_VALOR, 2)
				EndIf

				If nSaldoRet == 0
					// Se for atualiza��o do m�s atual, deve considerar a data do dia como data do fechamento.
					If cAnoMesOHH == cAnoMesAtu
						If Empty(dDataBx)
							dDtOHH := Date() // Date, pois a emiss�o da fatura altera o dDataBase
						Else
							dDtOHH := LastDay(dDataBx)
						Endif
						nSaldo := SE1->E1_SALDO

					Else // Retroativa - Considera o �ltimo dia do m�s como data do fechamento
					     // Retorno o saldo referente a data informada em 'dDtOHH'
						nSaldo := SaldoTit(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
						                   SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA,;
						                   dDtOHH, dDtOHH, SE1->E1_LOJA, SE1->E1_FILIAL, /*nCotacao*/, 1)

						// Quando se trata de impostos (abatimento) o saldotit n�o funciona corretamente por nao tratar tais movimentos de baixa.
						// Com isso se o retorno do saldotit for o mesmo valor de abatimentos, deve-se zerar o saldo.
						If nSaldo == nAbatimentos
							nSaldo := 0
						EndIf

					EndIf
				Else
					nSaldo := nSaldoRet
				EndIf

				// Define a opera��o
				lInclui := J255OpcOHH(lCpoFat, cEscrit, cFatura, cTitulo, cAnoMesOHH)

				If nSaldo > 0
					// Proporcionaliza os impostos entre as Faturas
					// (S� existir� mais de uma fatura em t�tulos que passaram por processo de liquida��o)
					nIRRF   := RatPontoFl(aValorFat[nFat][9] , nTotIRRF  , SE1->E1_IRRF  , 2)
					nPIS    := RatPontoFl(aValorFat[nFat][10], nTotPIS   , SE1->E1_PIS   , 2)
					nCOFINS := RatPontoFl(aValorFat[nFat][11], nTotCOFINS, SE1->E1_COFINS, 2)
					nCSLL   := RatPontoFl(aValorFat[nFat][12], nTotCSLL  , SE1->E1_CSLL  , 2)
					nISS    := RatPontoFl(aValorFat[nFat][13], nTotISS   , SE1->E1_ISS   , 2)
					nINSS   := RatPontoFl(aValorFat[nFat][14], nTotINSS  , SE1->E1_INSS  , 2)

					If lEstorno
						aSaldos := JEstorno(lInclui, cTitulo, aOHIBxAnt, cEscrit, cFatura, lCpoSaldo)
					Else
						aSaldos := JGrvSaldo(cAnoMesOHH, cTitulo, lInclui, dDtEmiSE1, aValorFat[nFat], nValTit, lCpoFat, lCpoSaldo)
					EndIf
					lZeraSaldo := aSaldos[7] + aSaldos[8] == 0
			
					RecLock("OHH", lInclui)
					OHH->OHH_FILIAL := SE1->E1_FILIAL
					OHH->OHH_PREFIX := SE1->E1_PREFIXO
					OHH->OHH_NUM    := SE1->E1_NUM
					OHH->OHH_PARCEL := SE1->E1_PARCELA
					OHH->OHH_TIPO   := SE1->E1_TIPO
					OHH->OHH_DTHIST := Iif(Type("lMigPFS") == "L", SE1->E1_EMISSAO, dDtOHH)
					OHH->OHH_ANOMES := cAnoMesOHH
					OHH->OHH_HIST   := SE1->E1_HIST
					OHH->OHH_CMOEDA := SE1->E1_MOEDA
					OHH->OHH_CCLIEN := SE1->E1_CLIENTE
					OHH->OHH_CLOJA  := SE1->E1_LOJA
					OHH->OHH_CNATUR := SE1->E1_NATUREZ
					OHH->OHH_VALOR  := nValTit
					OHH->OHH_TPENTR := cTpEntr
					OHH->OHH_VENCRE := SE1->E1_VENCREA
					OHH->OHH_VLIRRF := nIRRF
					OHH->OHH_VLPIS  := nPIS
					OHH->OHH_VLCOFI := nCOFINS
					OHH->OHH_VLCSLL := nCSLL
					OHH->OHH_VLISS  := nISS
					OHH->OHH_VLINSS := nINSS

					If lCpoSaldo .And. cTpEntr == '2'
						OHH->OHH_NFELET := SE1->E1_NFELETR
						If Len(aSaldos) > 0
							If lInclui .Or. (OHH->OHH_VLFATH == 0 .And. OHH->OHH_VLFATD == 0)
								OHH->OHH_VLFATH := aSaldos[1] // Valor Original de Honor�rios
								OHH->OHH_VLFATD := aSaldos[2] // Valor Original de Despesas
								If lDespTrib
									OHH->OHH_VLREMB := aSaldos[3] // Valor Original de Despesas Reembols�veis
									OHH->OHH_VLTRIB := aSaldos[4] // Valor Original de Despesas Tribut�veis
									OHH->OHH_VLTXAD := aSaldos[5] // Valor Original de Taxa Administrativa
									OHH->OHH_VLGROS := aSaldos[6] // Valor Original de Gross Up
								EndIf
							EndIf
							OHH->OHH_SALDO  := aSaldos[7] + aSaldos[8] // Saldo Total
							OHH->OHH_SALDOH := IIf(lZeraSaldo, 0, aSaldos[7]) // Saldo de Honor�rios
							OHH->OHH_SALDOD := IIf(lZeraSaldo, 0, aSaldos[8]) // Saldo de Despesas
							If lDespTrib
								OHH->OHH_SDREMB := IIf(lZeraSaldo, 0, aSaldos[9] ) // Saldo de Despesas Reembols�veis
								OHH->OHH_SDTRIB := IIf(lZeraSaldo, 0, aSaldos[10]) // Saldo de Despesas Tribut�veis
								OHH->OHH_SDTXAD := IIf(lZeraSaldo, 0, aSaldos[11]) // Saldo de Taxa Administrativa
								OHH->OHH_SDGROS := IIf(lZeraSaldo, 0, aSaldos[12]) // Saldo de Gross Up
							EndIf
						EndIf
					ElseIf cTpEntr == '2'
						OHH->OHH_SALDO  := aSaldos[7] + aSaldos[8]
					EndIf

					If !Empty(cEscrit) .And. !Empty(cFatura)
						OHH->OHH_JURFAT := cFilFat + '-' + cEscrit + '-' + cFatura + '-' + SE1->E1_FILIAL
					EndIf

					If lCpoMoeda
						OHH->OHH_CMOEDC := AllTrim(Str(SE1->E1_MOEDA))
					EndIf

					If lCpoAbat
						OHH->OHH_ABATIM := nSomaAbat
					EndIf

					If lCpoFat
						OHH->OHH_CESCR  := cEscrit
						OHH->OHH_CFATUR := cFatura
					EndIf

					OHH->(MsUnLock())

					cOpcOHH := Iif(lInclui, "3", "4")

				ElseIf !lInclui .And. nSaldo == 0  .And. OHH->(Found()) // Deleta os registros encontrados que est�o sem saldo.
					Reclock( "OHH", .F. )
					OHH->(dbDelete())
					OHH->(MsUnLock())
					cOpcOHH := "5"
				EndIf

			Next

			If !Empty(cOpcOHH) .And. lSincLG
				//Grava na fila de sincroniza��o a altera��o
				J170GRAVA("OHH", SE1->E1_FILIAL+;
				                 SE1->E1_PREFIXO+;
				                 SE1->E1_NUM+;
				                 SE1->E1_PARCELA+;
				                 SE1->E1_TIPO+;
								cAnoMesOHH, cOpcOHH)
			EndIf

			dDtOHH     := LastDay(MonthSum(dDtOHH, 1)) // �ltimo dia do proximo m�s
			cAnoMesOHH := AnoMes(dDtOHH)

			// Controle para gerar todas as parcelas para cada ano-m�s, at� o ano-m�s atual, com base na data dNewDtMov
			If !lGrParcAnt 
				Exit
			EndIf
		EndDo

		If !lExecLote
			SE1->(DbGoTo(nRecOld))
			RestArea(aArea)
		EndIf
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J255DelHist()
Deleta a posi��o hist�rica do Contas a Receber (OHH) referente a cChaveSE1.

@param cChaveSE1, Chave do t�tulo a receber que foi deletado

@author Bruno Ritter | Jorge Martins
@since 09/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J255DelHist(cChaveSE1)

If FWAliasInDic("OHH")
	dbSelectArea( 'OHH' )
	OHH->(DBSetOrder(1)) // OHH_FILIAL+OHH_PREFIX+OHH_NUM+OHH_PARCEL+OHH_TIPO+OHH_ANOMES
	OHH->(DbGoTop())

	While OHH->(DbSeek(cChaveSE1))
		//Grava na fila de sincroniza��o a exclus�o
		J170GRAVA("OHH", OHH->OHH_FILIAL+;
		                 OHH->OHH_PREFIX+;
		                 OHH->OHH_NUM+;
		                 OHH->OHH_PARCEL+;
		                 OHH->OHH_TIPO+;
		                 OHH->OHH_ANOMES, "5")
		
		Reclock( "OHH", .F. )
		OHH->(dbDelete())
		OHH->(MsUnLock())
	EndDo
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGrvSaldo()
Retorna o saldo e o valor original de Honor�rios e Despesas.

@param cAnoMes,    Ano\M�s do hist�rico do Contas a Receber
@param cTitulo,    Chave do titulo do Contas a Receber
@param lInclui,    Verifica se ser� gravado um novo registro na OHH
@param dDtEmiSE1,  Data de emiss�o do t�tulo
@param aValorFat,  Dados com os valores proporcionalizados por fatura
@param nValParc ,  Valor do t�tulo (parcela)
@param lCpoFat  ,  Indica se existem os campos de identifica��o da fatura na OHH
@param lCpoSaldo ,  Indica se existem os campos de saldo da OHH

@return aSaldos,   Saldos do t�tulo/fatura para grava��o na OHH

@author Anderson Carvalho
@since 14/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGrvSaldo(cAnoMes, cTitulo, lInclui, dDtEmiSE1, aValorFat, nValParc, lCpoFat, lCpoSaldo)
	Local nTamVlH    := 2
	Local nTamVlD    := 2
	Local cQryOHI    := ""
	Local cQryRes    := ""
	Local cTpPriori  := SuperGetMv('MV_JTPRIO',, '1') //1-Prioriza despesas 2-Proporcional
	Local aSaldos    := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local aVlrOrig   := {}
	Local aVlrDesp   := {0, 0, 0, 0, 0}
	Local dDiaIni    := StoD(cAnoMes + "01")
	Local dDiaFim    := LastDay(dDiaIni)
	Local nBaixaDesp := 0
	Local nBxDesRemb := 0
	Local nBxDesTrib := 0
	Local nBxTxAdm   := 0
	Local nBxGross   := 0
	Local nBaixaHon  := 0
	Local nI         := 0
	Local nParcAtu   := 0
	Local nQtdParc   := 0
	Local aDespExist := {}
	Local lDespTrib  := OHH->(ColumnPos("OHH_VLREMB")) > 0 .And. OHI->(ColumnPos("OHI_VLREMB")) > 0 // Prote��o
	Local nTotFat    := aValorFat[1] + aValorFat[2] // Total da Fatura Honor�rios + Despesas
	Local cEscrit    := aValorFat[7]
	Local cFatura    := aValorFat[8]
	Local lValorOHT  := aValorFat[16] // Indica que os valores vieram da OHT

	Default lCpoSaldo := .T.

	If !lCpoSaldo
		nTamVlH    := TamSX3("OHH_SALDO")[2]
		nTamVlD    := TamSX3("OHH_SALDO")[2]
	Else
		nTamVlH    := TamSX3("OHH_SALDOH")[2]
		nTamVlD    := TamSX3("OHH_SALDOD")[2]
	EndIf

	cQryOHI := "SELECT SUM(OHI_VLHCAS) AS SALDO_H, SUM(OHI_VLDCAS) AS SALDO_D "
	If lDespTrib
		cQryOHI += " , SUM(OHI_VLREMB) AS SALDO_DREMB, SUM(OHI_VLTRIB) AS SALDO_DTRIB, SUM(OHI_VLTXAD) AS SALDO_TXADM, SUM(OHI_VLGROS) AS SALDO_GROSS "
	EndIf
	cQryOHI +=  " FROM " + RetSqlName("OHI") + " "
	cQryOHI += " WHERE OHI_CHVTIT = '" + cTitulo + "' "
	cQryOHI +=   " AND OHI_DTAREC <= '" + DtoS(dDiaFim) + "' "
	cQryOHI +=   " AND OHI_CESCR  = '" + cEscrit + "' "
	cQryOHI +=   " AND OHI_CFATUR = '" + cFatura + "' "
	cQryOHI +=   " AND D_E_L_E_T_ = ' ' "

	cQryRes := GetNextAlias()
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQryOHI), cQryRes, .T., .T.)

	nBaixaDesp := (cQryRes)->SALDO_D
	nBaixaHon  := (cQryRes)->SALDO_H
	If lDespTrib
		nBxDesRemb := (cQryRes)->SALDO_DREMB
		nBxDesTrib := (cQryRes)->SALDO_DTRIB
		nBxTxAdm   := (cQryRes)->SALDO_TXADM
		nBxGross   := (cQryRes)->SALDO_GROSS
	EndIf
	
	(cQryRes)->( DbCloseArea())

	If cTpPriori == "1" // Prioriza despesas
		aVlrOrig := GetVlOri(cTitulo, dDtEmiSE1, lCpoFat, cEscrit, cFatura) // Verifica se existem valores em ano-m�s anterior
		If Len(aVlrOrig) >= 2 .And. aVlrOrig[1] == 0 .And. aVlrOrig[2] == 0
			aVlrDesp := J256PriDes(, cEscrit, cFatura,,, aValorFat[2], "OHH", cTitulo, lInclui, aValorFat, cAnoMes, lValorOHT)

			aSaldos[1] := RatPontoFl(aValorFat[1], aValorFat[1], (nValParc - aVlrDesp[1]), nTamVlH) // Valor de honor�rios
			aSaldos[2] := aVlrDesp[1] // Valor total de despesas
			aSaldos[3] := aVlrDesp[2] // Valor de Despesas Reembols�veis
			aSaldos[4] := aVlrDesp[3] // Valor de Despesas Tribut�veis
			aSaldos[5] := aVlrDesp[4] // Valor de Taxa Administrativa
			aSaldos[6] := aVlrDesp[5] // Valor de Taxa Gross Up
		Else
			aSaldos[1] := aVlrOrig[1]
			aSaldos[2] := aVlrOrig[2]
			aSaldos[3] := aVlrOrig[3]
			aSaldos[4] := aVlrOrig[4]
			aSaldos[5] := aVlrOrig[5]
			aSaldos[6] := aVlrOrig[6]
		EndIf
		
		If !Empty(nBaixaHon) .Or. !Empty(nBaixaDesp)
			aSaldos[7]  := (aSaldos[1] - nBaixaHon)  // Saldo Honor�rios
			aSaldos[8]  := (aSaldos[2] - nBaixaDesp) // Saldo Despesas
			aSaldos[9]  := (aSaldos[3] - nBxDesRemb) // Saldo Despesas Reembols�vel
			aSaldos[10] := (aSaldos[4] - nBxDesTrib) // Saldo Despesas Tribut�vel
			aSaldos[11] := (aSaldos[5] - nBxTxAdm  ) // Saldo Taxa Administrativa
			aSaldos[12] := (aSaldos[6] - nBxGross  ) // Saldo Gross Up
		Else
			aSaldos[7]  := aSaldos[1]
			aSaldos[8]  := aSaldos[2]
			aSaldos[9]  := aSaldos[3]
			aSaldos[10] := aSaldos[4]
			aSaldos[11] := aSaldos[5]
			aSaldos[12] := aSaldos[6]
		EndIf

		For nI := 1 To Len(aSaldos)
			If aSaldos[nI] < 0
				aSaldos[nI] := 0
			EndIf
		Next

	Else // 2-Proporcional
	
		If lInclui

			aDespExist := J255GetDes(cEscrit, cFatura, lInclui, , cTitulo) // Valores de despesas na OHH
			nParcAtu   := aDespExist[7] + 1                     // Parcela atual
			nQtdParc   := Round(nTotFat / nValParc, 2)          // Total de Parcelas

			If nQtdParc == nParcAtu // �ltima Parcela - Joga o valor restante
				// Campos totalizadores
				aSaldos[1] := aValorFat[1] - aDespExist[6]
				aSaldos[2] := aValorFat[2] - aDespExist[1]
				aSaldos[3] := aValorFat[3] - aDespExist[2]
				aSaldos[4] := aValorFat[4] - aDespExist[3]
				aSaldos[5] := aValorFat[5] - aDespExist[4]
				aSaldos[6] := aValorFat[6] - aDespExist[5]
			Else
				// Campos totalizadores
				aSaldos[3] := RatPontoFl(aValorFat[3], nTotFat, nValParc, nTamVlD) // Valor Despesas Reembols�vel
				aSaldos[4] := RatPontoFl(aValorFat[4], nTotFat, nValParc, nTamVlD) // Valor Despesas Tribut�vel
				aSaldos[5] := RatPontoFl(aValorFat[5], nTotFat, nValParc, nTamVlD) // Valor Taxa administrativa
				aSaldos[6] := RatPontoFl(aValorFat[6], nTotFat, nValParc, nTamVlD) // Valor Gross Up
				aSaldos[2] := aSaldos[3] + aSaldos[4] + aSaldos[5] + aSaldos[6]    // Valor Despesas
				aSaldos[1] := nValParc - aSaldos[2]                                // Valor Honor�rios
			EndIf
			// Campos de saldos
			aSaldos[7]  := aSaldos[1] - nBaixaHon  // Saldo Honor�rios
			aSaldos[8]  := aSaldos[2] - nBaixaDesp // Saldo Despesas
			aSaldos[9]  := aSaldos[3] - nBxDesRemb // Saldo Despesas Reembols�vel
			aSaldos[10] := aSaldos[4] - nBxDesTrib // Saldo Despesas Tribut�vel
			aSaldos[11] := aSaldos[5] - nBxTxAdm   // Saldo Taxa administrativa
			aSaldos[12] := aSaldos[6] - nBxGross   // Saldo Gross Up
		Else
			aSaldos[1] := OHH->OHH_VLFATH
			aSaldos[2] := OHH->OHH_VLFATD
			If lDespTrib
				aSaldos[3] := OHH->OHH_VLREMB
				aSaldos[4] := OHH->OHH_VLTRIB
				aSaldos[5] := OHH->OHH_VLTXAD
				aSaldos[6] := OHH->OHH_VLGROS
			EndIf
			If !Empty(nBaixaHon) .Or. !Empty(nBaixaDesp)
				aSaldos[7] := (aSaldos[1] - nBaixaHon)  // Saldo Honor�rios
				aSaldos[8] := (aSaldos[2] - nBaixaDesp) // Saldo Despesas
				If lDespTrib
					aSaldos[9]  := (aSaldos[3] - nBxDesRemb) // Saldo Despesas Reembols�vel
					aSaldos[10] := (aSaldos[4] - nBxDesTrib) // Saldo Despesas Tribut�vel
					aSaldos[11] := (aSaldos[5] - nBxTxAdm  ) // Saldo Taxa administrativa
					aSaldos[12] := (aSaldos[6] - nBxGross  ) // Saldo Gross Up
				EndIf
			Else
				aSaldos[7]  := aSaldos[1]
				aSaldos[8]  := aSaldos[2]
				aSaldos[9]  := aSaldos[3]
				aSaldos[10] := aSaldos[4]
				aSaldos[11] := aSaldos[5]
				aSaldos[12] := aSaldos[6]
			EndIf
		EndIf
	EndIf

Return aSaldos

//-------------------------------------------------------------------
/*/{Protheus.doc} J255GetDes()
Retorna os valores de despesas j� gravadas na OHH para cada parcela de t�tulo

@param cEscrit   , C�digo do escrit�rio da fatura
@param cFatura   , C�digo da fatura
@param lInclui   , Verifica se ser� gravado um novo registro na OHH
@param cAnoMesAtu, Ano M�s de refer�ncia
@param cTitulo   , Chave do t�tulo

@return aDesp    , Valores de despesas de parcelas anteriores

@author  Anderson Carvalho / Abner Foga�a
@since   26/12/2018
/*/
//-------------------------------------------------------------------
Function J255GetDes(cEscrit, cFatura, lInclui, cAnoMesAtu, cTitulo)
	Local aDesp      := {0, 0, 0, 0, 0, 0, 0}
	Local cQryOHH    := ""
	Local cAliasOHH  := ""
	Local lDespTrib  := OHH->(ColumnPos("OHH_VLREMB")) > 0 // Prote��o
	Local cJurFat    := xFilial("NXA") + '-' + cEscrit + '-' + cFatura + '-' + SE1->E1_FILIAL

	Local nSE1TamFil := TamSX3("E1_FILIAL")[1]
	Local nSE1TamPre := TamSX3("E1_PREFIXO")[1]
	Local nSE1TamNum := TamSX3("E1_NUM")[1]
	Local nSE1TamPar := TamSX3("E1_PARCELA")[1]
	Local nSE1TamTip := TamSX3("E1_TIPO")[1]

	Default cAnoMesAtu := Anomes(dDataBase)
	Default cTitulo    := ""

	cQryOHH :=  " SELECT SUM(OHH_VLFATD) OHH_VLFATD "
	If lDespTrib
		cQryOHH +=    ", SUM(OHH_VLREMB) OHH_VLREMB, SUM(OHH_VLTRIB) OHH_VLTRIB, SUM(OHH_VLTXAD) OHH_VLTXAD, SUM(OHH_VLGROS) OHH_VLGROS, SUM(OHH_VLFATH) OHH_VLFATH, COUNT(*) CONTADOR  "
	EndIf
	cQryOHH +=    " FROM " + RetSqlName("OHH") + " "
	cQryOHH +=   " WHERE OHH_FILIAL = '" + xFilial("OHH") + "' "
	cQryOHH +=     " AND OHH_JURFAT = '" + cJurFat + "' "
	If lInclui
		cQryOHH += " AND OHH_ANOMES = '" + cAnoMesAtu + "' "
	Else
		cQryOHH += " AND OHH_ANOMES < '" + cAnoMesAtu + "' "
	EndIf
	If !Empty(cTitulo)
		cQryOHH += " AND OHH_PREFIX = '" + Substr(cTitulo, nSE1TamFil + 1, nSE1TamPre) + "' "
		cQryOHH += " AND OHH_NUM    = '" + Substr(cTitulo, nSE1TamFil + nSE1TamPre + 1, nSE1TamNum) + "' "
		cQryOHH += " AND OHH_TIPO   = '" + Substr(cTitulo, nSE1TamFil + nSE1TamPre + nSE1TamNum + nSE1TamPar + 1, nSE1TamTip) + "' "
	EndIf
	cQryOHH +=     " AND D_E_L_E_T_ = ' ' "

	cAliasOHH := GetNextAlias()
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQryOHH), cAliasOHH, .T., .T.)

	If !Empty((cAliasOHH)->OHH_VLFATD)
		aDesp[1] := (cAliasOHH)->OHH_VLFATD
		If lDespTrib
			aDesp[2] := (cAliasOHH)->OHH_VLREMB
			aDesp[3] := (cAliasOHH)->OHH_VLTRIB
			aDesp[4] := (cAliasOHH)->OHH_VLTXAD
			aDesp[5] := (cAliasOHH)->OHH_VLGROS
			aDesp[6] := (cAliasOHH)->OHH_VLFATH
			aDesp[7] := (cAliasOHH)->CONTADOR
		EndIf
	EndIf

	(cAliasOHH)->( DbCloseArea())

Return (aDesp)

//-------------------------------------------------------------------
/*/{Protheus.doc} JEstorno()
Retornar o valor original e de saldo (honor�rios e despesas) quando 
realizado estorno da baixa do t�tulo.

@param lInclui,   Verifica se ser� gravado um novo registro na OHH
@param cTitulo,   Chave do titulo do Contas a Receber
@param aOHIBxAnt, Total de honor�rios e despesas baixados antes do estorno
@param cEscrit,   C�digo do Escrit�rio
@param cFatura,   C�digo da Fatura
@param lCpoSaldo ,  Indica se existem os campos de saldo da OHH

@return aEstorno, Array com valores da OHH para o t�tulo/fatura em quest�o

@author Anderson Carvalho | Abner Foga�a
@since 16/01/2019
/*/
//-------------------------------------------------------------------
Static Function JEstorno(lInclui, cTitulo, aOHIBxAnt, cEscrit, cFatura,lCpoSaldo)
	Local nVlrOriHon := 0
	Local nVlrOriDes := 0
	Local nVlOriRemb := 0
	Local nVlOriTrib := 0
	Local nVlOriTxAd := 0
	Local nVlOriGros := 0
	Local nSaldoHon  := 0
	Local nSaldoDes  := 0
	Local nSaldoDRem := 0
	Local nSaldoDTri := 0
	Local nSaldoTxAd := 0
	Local nSaldoGros := 0
	Local nTamVlH    := 2
	Local nTamVlD    := 2
	Local lDespTrib  := OHH->(ColumnPos("OHH_VLREMB")) > 0 // Prote��o
	Local aEstorno   := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local aOHIBxNew  := J255TotBx(cTitulo)
	Local nPosBxAnt  := aScan(aOHIBxAnt, { |aFat| aFat[1] == cEscrit .And. aFat[2] == cFatura })
	Local nPosBxNew  := aScan(aOHIBxNew, { |aFat| aFat[1] == cEscrit .And. aFat[2] == cFatura })

	nPosBxAnt := IIf(nPosBxAnt == 0, 1, nPosBxAnt)
	nPosBxNew := IIf(nPosBxNew == 0, 1, nPosBxNew)
	
	Default lCpoSaldo := .T.

	If !lCpoSaldo	
		nTamVlH    := TamSX3("OHH_SALDO")[2]
		nTamVlD    := TamSX3("OHH_SALDO")[2]
	Else

		nTamVlH    := TamSX3("OHH_SALDOH")[2]
		nTamVlD    := TamSX3("OHH_SALDOD")[2]
	EndIf

	If lInclui
		nVlrOriHon := aOHIBxAnt[nPosBxAnt][3]
		nVlrOriDes := aOHIBxAnt[nPosBxAnt][4]
		nVlOriRemb := aOHIBxAnt[nPosBxAnt][5]
		nVlOriTrib := aOHIBxAnt[nPosBxAnt][6]
		nVlOriTxAd := aOHIBxAnt[nPosBxAnt][7]
		nVlOriGros := aOHIBxAnt[nPosBxAnt][8]
		nSaldoHon  := Round(nVlrOriHon - aOHIBxNew[nPosBxNew][3], nTamVlH)
		nSaldoDes  := Round(nVlrOriDes - aOHIBxNew[nPosBxNew][4], nTamVlD)
		nSaldoDRem := Round(nVlOriRemb - aOHIBxNew[nPosBxNew][5], nTamVlD)
		nSaldoDTri := Round(nVlOriTrib - aOHIBxNew[nPosBxNew][6], nTamVlD)
		nSaldoTxAd := Round(nVlOriTxAd - aOHIBxNew[nPosBxNew][7], nTamVlD)
		nSaldoGros := Round(nVlOriGros - aOHIBxNew[nPosBxNew][8], nTamVlD)
	Else
		nVlrOriHon := OHH->OHH_VLFATH
		nVlrOriDes := OHH->OHH_VLFATD
		nSaldoHon  := Round(OHH->OHH_VLFATH - aOHIBxNew[nPosBxNew][3], nTamVlH)
		nSaldoDes  := Round(OHH->OHH_VLFATD - aOHIBxNew[nPosBxNew][4], nTamVlD)
		If lDespTrib
			nVlOriRemb := OHH->OHH_VLREMB
			nVlOriTrib := OHH->OHH_VLTRIB
			nVlOriTxAd := OHH->OHH_VLTXAD
			nVlOriGros := OHH->OHH_VLGROS
			nSaldoDRem := Round(OHH->OHH_VLREMB - aOHIBxNew[nPosBxNew][5], nTamVlD)
			nSaldoDTri := Round(OHH->OHH_VLTRIB - aOHIBxNew[nPosBxNew][6], nTamVlD)
			nSaldoTxAd := Round(OHH->OHH_VLTXAD - aOHIBxNew[nPosBxNew][7], nTamVlD)
			nSaldoGros := Round(OHH->OHH_VLGROS - aOHIBxNew[nPosBxNew][8], nTamVlD)
		EndIf
	EndIf

	aEstorno[1]  := nVlrOriHon
	aEstorno[2]  := nVlrOriDes
	aEstorno[3]  := nVlOriRemb
	aEstorno[4]  := nVlOriTrib
	aEstorno[5]  := nVlOriTxAd
	aEstorno[6]  := nVlOriGros
	aEstorno[7]  := nSaldoHon
	aEstorno[8]  := nSaldoDes
	aEstorno[9]  := nSaldoDRem
	aEstorno[10] := nSaldoDTri
	aEstorno[11] := nSaldoTxAd
	aEstorno[12] := nSaldoGros

	JurFreeArr(@aOHIBxNew)

Return aEstorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J255TotBx()
Retorna a somat�ria das baixas de honor�rios e despesas para cada t�tulo.

@param cTitulo, Chave do titulo do Contas a Receber

@return aTotBx, Array com valores de baixas do t�tulo/fatura

@author  Anderson Carvalho | Abner Foga�a
@since   16/01/2019
/*/
//-------------------------------------------------------------------
Function J255TotBx(cTitulo)
	Local cQryOHI   := ""
	Local aTotBx    := {}
	Local lDespTrib := OHI->(ColumnPos("OHI_VLREMB")) > 0

	cQryOHI := " SELECT OHI_CESCR, OHI_CFATUR, SUM(OHI_VLHCAS) AS OHI_VLHCAS, SUM(OHI_VLDCAS) AS OHI_VLDCAS "
	If lDespTrib
		cQryOHI +=   ", SUM(OHI_VLREMB) AS OHI_VLREMB, SUM(OHI_VLTRIB) AS OHI_VLTRIB, SUM(OHI_VLTXAD) AS OHI_VLTXAD, SUM(OHI_VLGROS) AS OHI_VLGROS "
	Else
		cQryOHI +=   ", 0 AS OHI_VLREMB, 0 AS OHI_VLTRIB, 0 AS OHI_VLTXAD, 0 AS OHI_VLGROS "
	EndIf
	cQryOHI +=   " FROM " + RetSqlName("OHI") + " "
	cQryOHI +=  " WHERE OHI_CHVTIT = '" + cTitulo + "' "
	cQryOHI +=    " AND D_E_L_E_T_ = ' ' "
	cQryOHI +=  " GROUP BY OHI_CESCR, OHI_CFATUR "

	aTotBx := JurSQL(cQryOHI, {"*"})

	If Empty(aTotBx)
		aTotBx := {{"", "", 0, 0, 0, 0, 0, 0}}
	EndIf

Return aTotBx

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvParcAnt()
Executa a grava��o de parcelas anteriores at� a parcela posicionada.

@param lGrParcAnt, Executa fun��o para gerar parcelas anteriores.
@param dDtOHH,     Data da movimenta��o da OHH
@param cE1Prefixo, Prefixo do t�tulo
@param cE1Num,     N�mero do t�tulo
@param cE1Parcela, Parcela do t�tulo
@param cE1Tipo,    Tipo do t�tulo
@param lSincLG   , Indica se grava na fila de sincroniza��o
@param dDtBaixa  , Data da baixa do t�tulo (E1_BAIXA)

@author  Anderson Carvalho | Abner Foga�a
@since   18/01/2019
/*/
//-------------------------------------------------------------------
Static Function GrvParcAnt(lGrParcAnt, dDtOHH, cE1Prefixo, cE1Num, cE1Parcela, cE1Tipo, lSincLG, dDtBaixa)
	Local cAliasQry  :=  GetNextAlias()
	Local cAnoMesOHH := AnoMes(dDtOHH)

	BeginSql Alias cAliasQry
		%noparser%
		SELECT SE1.R_E_C_N_O_
		FROM   %Table:SE1% SE1
		LEFT JOIN  %Table:OHH% OHH
				ON (OHH.OHH_ANOMES = %Exp:cAnoMesOHH%
				AND OHH.OHH_FILIAL = SE1.E1_FILIAL 
				AND OHH.OHH_PREFIX = SE1.E1_PREFIXO 
				AND OHH.OHH_NUM = SE1.E1_NUM 
				AND OHH.OHH_PARCEL = SE1.E1_PARCELA 
				AND OHH.OHH_TIPO = SE1.E1_TIPO 
				AND OHH.%NotDel%) 
		WHERE SE1.E1_FILIAL = %xFilial:SE1%
		AND SE1.E1_PREFIXO = %Exp:cE1Prefixo%
		AND SE1.E1_NUM = %Exp:cE1Num%
		AND SE1.E1_PARCELA < %Exp:cE1Parcela%
		AND SE1.E1_TIPO = %Exp:cE1Tipo%
		AND SE1.E1_SALDO > 0
		AND SE1.%NotDel%  
		AND OHH.R_E_C_N_O_ IS NULL 
		ORDER BY SE1.E1_PARCELA 

	EndSql
	dbSelectArea(cAliasQry)

	While !(cAliasQry)->( EOF() )
		J255APosHis((cAliasQry)->R_E_C_N_O_, dDtOHH, , , .F., ,lSincLG, dDtBaixa ) 
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVlOri()
Retorna os valores originais (honor�rios e despesas) do ano m�s anterior.

@param cTitulo  , Chave do t�tulo
@param dDtEmiSE1, Data de emiss�o do t�tulo
@param lCpoFat  , Indica se existem os campos de identifica��o da fatura na OHH
@param cEscrit  , C�digo do Escrit�rio
@param cFatura  , C�digo da Fatura

@return aRetVlOri, Array com os valores de honor�rios e despesas do ano m�s

@author  Anderson Carvalho | Abner Foga�a
@since   18/01/2019
/*/
//-------------------------------------------------------------------
Static Function GetVlOri(cTitulo, dDtEmiSE1, lCpoFat, cEscrit, cFatura)
	Local aArea     := GetArea()
	Local cAnoMes   := AnoMes(dDtEmiSE1)
	Local nRecOld   := OHH->(Recno())
	Local aRetVlOri := {0, 0, 0, 0, 0, 0}
	Local nIndexOHH := IIf(lCpoFat, 3, 1)
	Local cChave    := IIf(nIndexOHH == 1, cTitulo + cAnoMes, cEscrit + cFatura + cTitulo + cAnoMes)

	// Indice 1 -> OHH_FILIAL + OHH_PREFIX + OHH_NUM + OHH_PARCEL + OHH_TIPO + OHH_ANOMES
	// Indice 3 -> OHH_CESCR + OHH_CFATUR + OHH_FILIAL + OHH_PREFIX + OHH_NUM + OHH_PARCEL + OHH_TIPO + OHH_ANOMES
	OHH->(DBSetOrder(nIndexOHH))

	If OHH->(DbSeek(cChave))
		aRetVlOri[1] := OHH->OHH_VLFATH
		aRetVlOri[2] := OHH->OHH_VLFATD
		If OHH->(ColumnPos("OHH_VLREMB")) > 0 // Prote��o
			aRetVlOri[3] := OHH->OHH_VLREMB
			aRetVlOri[4] := OHH->OHH_VLTRIB
			aRetVlOri[5] := OHH->OHH_VLTXAD
			aRetVlOri[6] := OHH->OHH_VLGROS
		EndIf
	EndIf

	OHH->(DbGoto(nRecOld))
	RestArea(aArea)

Return aRetVlOri

//-------------------------------------------------------------------
/*/{Protheus.doc} J255AjNfe
Ajusta a OHH com o n�mero da Nota Fiscal Eletr�nica do t�tulo a receber.

@param nRecSE1, Recno da SE1 que est� sendo alteado o campo E1_NFELETR

@author Bruno Ritter
@since 17/01/2019
/*/
//-------------------------------------------------------------------
Function J255AjNfe(nRecSE1)
	Local nRecOld   := SE1->(Recno())
	Local aArea     := GetArea()
	Local cChaveSE1 := ""
	Local cAnoMes   := AnoMes(dDataBase)

	SE1->(dbGoTo(nRecSE1))
	cChaveSE1 := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

	OHH->(DBSetOrder(1)) // OHH_FILIAL+OHH_PREFIX+OHH_NUM+OHH_PARCEL+OHH_TIPO+OHH_ANOMES
	If OHH->(DbSeek(cChaveSE1 + cAnoMes))
		RecLock("OHH", .F.)
		OHH->OHH_NFELET := SE1->E1_NFELETR
		OHH->(MsUnlock())

		//Grava na fila de sincroniza��o
		J170GRAVA("OHH", cChaveSE1 + cAnoMes, "4")
	EndIf

	SE1->(dbGoTo(nRecOld))
	RestArea(aArea)
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J255VlrFat
Retorna os valores por Fatura para uso na grava��o da OHH.
Somente na emiss�o da Fatura ser�o considerados os valores da NXA, 
nas outras situa��es os valores vir�o da OHT.

@return aValorFat, Array com os valores da(s) fatura(s)
                   aValorFat[nFat][1],  Valor total de honor�rios (considerando acr�scimos e descontos da fatura)
                   aValorFat[nFat][2],  Valor total de despesas
                   aValorFat[nFat][3],  Valor de Despesas Reembols�veis
                   aValorFat[nFat][4],  Valor de Despesas Tribut�veis
                   aValorFat[nFat][5],  Valor de Taxa Administrativa
                   aValorFat[nFat][6],  Valor de Taxa Gross Up
                   aValorFat[nFat][7],  C�digo do Escrit�rio
                   aValorFat[nFat][8],  C�digo da Fatura
                   aValorFat[nFat][9],  IRRF   proporcional por fatura do t�tulo
                   aValorFat[nFat][10], PIS    proporcional por fatura do t�tulo
                   aValorFat[nFat][11], COFINS proporcional por fatura do t�tulo
                   aValorFat[nFat][12], CSLL   proporcional por fatura do t�tulo
                   aValorFat[nFat][13], ISS    proporcional por fatura do t�tulo
                   aValorFat[nFat][14], INSS   proporcional por fatura do t�tulo
                   aValorFat[nFat][15], Acr�scimo do financeiro (utilizado somente no processo de liquida��o)
                   aValorFat[nFat][16], Indica que os valores vieram da OHT

@author Jorge Martins
@since  14/08/2020
/*/
//-------------------------------------------------------------------
Static Function J255VlrFat()
	Local lExistOHT  := AliasIndic("OHT")
	Local aValorFat  := {}
	Local aValImp    := {}
	Local aFatNXA    := {}
	Local aFatOHT    := {}
	Local lValImp    := .F.
	Local nTamFil    := TamSX3("NXA_FILIAL")[1]
	Local nTamEsc    := TamSX3("NXA_CESCR")[1]
	Local nTamFat    := TamSX3("NXA_COD")[1]
	Local cFilter    := ""
	Local cAux       := ""
	Local cEscrit    := ""
	Local cFatura    := ""
	Local cJurFat    := ""
	Local nFat       := 0
	Local cFilFat    := xFilial("NXA")
	Local lCpoGrsHon := NXA->(ColumnPos("NXA_VGROSH")) > 0 .And. NXC->(ColumnPos("NXC_VGROSH")) > 0 // @12.1.2310

	// Mantido devido ao momento da emiss�o da fatura
	If !lExistOHT .Or. FwIsInCallStack("JA203Tit")
		cAux    := Strtran(SE1->E1_JURFAT,"-","")
		cEscrit := Substr(cAux, nTamFil + 1, nTamEsc)
		cFatura := Substr(cAux, nTamFil + nTamEsc + 1, nTamFat)

		cFilter := " SELECT NXA_VLFATH - NXA_VLDESC + NXA_VLACRE + " + IIF(lCpoGrsHon, "NXA_VGROSH", "0") + " VALORH, " // Aplica desconto e acr�scimos da fatura no valor de honor�rios
		cFilter +=        " NXA_VLFATD, NXA_VLREMB, NXA_VLTRIB, " 
		cFilter +=        " NXA_VLTXAD, NXA_VLGROS, NXA_CESCR, NXA_COD "
		cFilter +=   " FROM " + RetSqlName("NXA") + " NXA "
		cFilter +=  " WHERE NXA.NXA_FILIAL = '" + cFilFat + "'"
		cFilter +=    " AND NXA.NXA_CESCR  = '" + cEscrit + "'"
		cFilter +=    " AND NXA.NXA_COD    = '" + cFatura + "'"
		cFilter +=    " AND NXA.D_E_L_E_T_ = ' '"

		aFatNXA := JurSQL(cFilter, "*",,, .F.)

		If Len(aFatNXA) > 0
			Aadd(aValorFat, {aFatNXA[1][1], aFatNXA[1][2], aFatNXA[1][3], aFatNXA[1][4],;
			                 aFatNXA[1][5], aFatNXA[1][6], aFatNXA[1][7], aFatNXA[1][8],;
			                 SE1->E1_IRRF , SE1->E1_PIS, SE1->E1_COFINS, SE1->E1_CSLL, SE1->E1_ISS, SE1->E1_INSS,;
			                 0   ,; // Acr�scimo do financeiro
			                 .F. }) // Indica que os valores vieram da OHT
		EndIf
	EndIf

	If lExistOHT .And. Len(aValorFat) == 0
		cFilter := " SELECT OHT_VLFATH, OHT_VLFATD, OHT_VLREMB, OHT_VLTRIB, OHT_VLTXAD, OHT_VLGROS, OHT_FTESCR, OHT_CFATUR, OHT_ACRESC FROM " + RetSqlName("OHT") + " OHT"
		cFilter +=  " WHERE OHT.OHT_FILIAL = '" + xFilial("OHT") + "'"
		cFilter +=    " AND OHT.OHT_FILTIT = '" + SE1->E1_FILIAL + "'"
		cFilter +=    " AND OHT.OHT_PREFIX = '" + SE1->E1_PREFIXO + "'"
		cFilter +=    " AND OHT.OHT_TITNUM = '" + SE1->E1_NUM  + "'"
		cFilter +=    " AND OHT.OHT_TITPAR = '" + SE1->E1_PARCELA + "'"
		cFilter +=    " AND OHT.OHT_TITTPO = '" + SE1->E1_TIPO + "'"
		cFilter +=    " AND OHT.D_E_L_E_T_ = ' '"

		aFatOHT := JurSQL(cFilter, "*")

		For nFat := 1 To Len(aFatOHT)
			// Localiza os valores de impostos dos t�tulos originais
			cJurFat := cFilFat + '-' + aFatOHT[nFat][7] + '-' + aFatOHT[nFat][8] + '-' + SE1->E1_FILIAL
			aValImp := J255ValImp(cJurFat)
			lValImp := Len(aValImp) > 0 // Encontrou valores de impostos

			Aadd(aValorFat, {aFatOHT[nFat][1], aFatOHT[nFat][2], aFatOHT[nFat][3], aFatOHT[nFat][4],;
			                 aFatOHT[nFat][5], aFatOHT[nFat][6], aFatOHT[nFat][7], aFatOHT[nFat][8],;
			                 IIf(lValImp, aValImp[1][1], 0),; // IRRF
			                 IIf(lValImp, aValImp[1][2], 0),; // PIS
			                 IIf(lValImp, aValImp[1][3], 0),; // COFINS
			                 IIf(lValImp, aValImp[1][4], 0),; // CSLL
			                 IIf(lValImp, aValImp[1][5], 0),; // ISS
			                 IIf(lValImp, aValImp[1][6], 0),; // INSS
			                 aFatOHT[nFat][9]           ,; // Acr�scimo do financeiro
			                 .T.                        }) // Indica que os valores vieram da OHT
		Next nFat
	EndIf

	If Len(aValorFat) == 0
		aValorFat := {{0, 0, 0, 0, 0, 0, avKey("", "NXA_CESCR"), avKey("", "NXA_COD"), 0, 0, 0, 0, 0, 0, 0, .F.}}
	EndIf

Return aValorFat

//-------------------------------------------------------------------
/*/{Protheus.doc} J255ValImp
Retorna os valores de impostos dos t�tulos de faturas liquidadas

@param  cJurFat, Chave da Fatura (SIGAPFS) vinculada ao t�tulo.

@return aValImp, Valor de impostos do t�tulo posicionado da fatura.

@author Jorge Martins | Abner Foga�a
@since  30/11/2020
/*/
//-------------------------------------------------------------------
Static Function J255ValImp(cJurFat)
	Local aValImp := {}
	Local cQrySE1 := ""

	cQrySE1 := " SELECT E1_IRRF , E1_PIS, E1_COFINS, E1_CSLL, E1_ISS, E1_INSS "
	cQrySE1 +=   " FROM " + RetSqlName("SE1") + " SE1 "
	cQrySE1 +=  " WHERE SE1.E1_JURFAT  = '" + cJurFat + "'"
	cQrySE1 +=    " AND SE1.E1_FILIAL  = '" + SE1->E1_FILIAL + "'"
	cQrySE1 +=    " AND SE1.E1_PREFIXO = '" + SE1->E1_PREFIXO + "'"
	cQrySE1 +=    " AND SE1.E1_NUM     = '" + SE1->E1_NUM  + "'"
	cQrySE1 +=    " AND SE1.E1_PARCELA = '" + SE1->E1_PARCELA + "'"
	cQrySE1 +=    " AND SE1.E1_TIPO    = '" + SE1->E1_TIPO + "'"
	cQrySE1 +=    " AND SE1.D_E_L_E_T_ = ' '"

	aValImp := JurSQL(cQrySE1, "*")

Return aValImp

//-------------------------------------------------------------------
/*/{Protheus.doc} J255OpcOHH
Indica se a opera��o a ser utilizada na OHH � de inclus�o

@param lCpoFat   , Indica se existem os campos de Escrit�rio e Fatura
@param cEscrit   , C�digo do Escrit�rio
@param cFatura   , C�digo da Fatura
@param cTitulo   , Chave do t�tulo
@param cAnoMesOHH, Ano-m�s de refer�ncia

@return, lInclui , Indica se a opera��o � uma inclus�o

@author Jorge Martins
@since  14/08/2020
/*/
//-------------------------------------------------------------------
Static Function J255OpcOHH(lCpoFat, cEscrit, cFatura, cTitulo, cAnoMesOHH)
	Local lInclui := .F.

	If lCpoFat
		lInclui := !(OHH->(DbSeek(cEscrit + cFatura + cTitulo + cAnoMesOHH)))
	Else
		lInclui := !(OHH->(DbSeek(cTitulo + cAnoMesOHH)))
	EndIf

Return lInclui