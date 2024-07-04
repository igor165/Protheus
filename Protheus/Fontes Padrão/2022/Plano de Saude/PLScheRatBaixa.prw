#Include "Protheus.ch"
#Include "TBICONN.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLScheRatBaixa
Schedule para gerar o rateio das baixas realizadas pelo Financeiro
em títulos do PLS

@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Prothues 12
/*/
//-----------------------------------------------------------------
Function PLScheRatBaixa()

    Local nDiasAtras := MV_PAR01

    GeraLog(Replicate('*',50), .F.)
    GeraLog('Iniciando Job PLScheRatBaixa')
    Conout("Iniciando Job PLScheRatBaixa.")
  
    PLRatSeekBaixa(nDiasAtras)

    GeraLog('Finalizando Job PLScheRatBaixa')
    Conout("Finalizando Job PLScheRatBaixa.")
    GeraLog(Replicate('*',50), .F.)
    GeraLog('', .F.)
    
    //Libera semaforo
    FreeUsedCode()

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Schedule para job
 
@author vinicius.queiros
@since 19/10/2020
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSQTDDIA",,{},""}


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRatSeekBaixa
Busca as Baixas a serem gravadas na tabela B6U (Rateio)

@author Vinicius Queiros Teixeira
@since 12/04/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLRatSeekBaixa(nDiasAtras)

	Local cQuery := ""
	Local cAlias := ""
	Local cFilialE1 := ""
	Local cPrefixo := ""
	Local cNumero := ""
	Local cParcela := ""
	Local cTipo := ""
	Local dDataBaixa := CToD(" / / ")
	Local cCliente := ""
	Local cLoja := ""
	Local cNumCobranca := ""
	Local nValorBaixa := 0
	Local cSeqBaixa := ""
	Local dDataInicial := CToD(" / / ") 
	Local dDataFinal := CToD(" / / ") 

	Default nDiasAtras := 0

	dDataInicial := dDataBase - nDiasAtras
	dDataFinal := dDataBase

	cAlias := GetNextAlias()
	cQuery := " SELECT SE1.E1_FILIAL,SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_PLNUCOB, "
	cQuery += "        FK1.FK1_VALOR, FK1.FK1_SEQ, FK1.FK1_TPDOC, FK1.FK1_DATA  "	
	cQuery += " FROM "+RetSQLName("FK1")+" FK1 "
	cQuery += " INNER JOIN " + RetSQLName("FK7") + " FK7 "
	cQuery += "      ON FK7_FILIAL = '"+xFilial("FK7")+"' "
	cQuery += "     AND FK7_IDDOC = FK1_IDDOC "
	cQuery += "     AND FK7_ALIAS = 'SE1' "
	cQuery += "     AND FK7.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSQLName("SE1") + " SE1 "
	cQuery += "      ON " + plFiePar("E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_CLIENTE|E1_LOJA", "FK7_CHAVE")
	cQuery += "     AND E1_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVPAGANT+"|"+MVRECANT,"|")	
	If AllTrim(TCGetDB()) $ "ORACLE|DB2|POSTGRES"
		cQuery += " AND SUBSTR(E1_ORIGEM,1,3) = 'PLS' " 
		cQuery += " AND TRIM(E1_TITPAI) IS NULL "
	Else
		cQuery += " AND SUBSTRING(E1_ORIGEM,1,3) = 'PLS' " 
		cQuery += " AND E1_TITPAI = ' ' "
	EndIf
	cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE FK1_FILIAL = '"+xFilial("FK1")+"' "
	cQuery += "   AND FK1_DATA BETWEEN '"+DtoS(dDataInicial)+"' AND '"+dtos(dDataFinal)+"' "
	cQuery += "   AND FK1_TPDOC IN ('BA','VL','BL','V2','ES') "
	cQuery += "   AND FK1_LA <> 'S' "
	cQuery += "   AND FK1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA"

    GeraLog("Buscando Baixas/Estornos no Financeiro...", .F.)
	GeraLog("Query: "+cQuery, .F.)

	DbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAlias,.F.,.T.)
	    
	While !(cAlias)->(Eof())

		cFilialE1 := (cAlias)->E1_FILIAL
		cPrefixo := (cAlias)->E1_PREFIXO
		cNumero := (cAlias)->E1_NUM
		cParcela := (cAlias)->E1_PARCELA
		cTipo := (cAlias)->E1_TIPO
		dDataBaixa := SToD((cAlias)->FK1_DATA)
		cCliente := (cAlias)->E1_CLIENTE
		cLoja := (cAlias)->E1_LOJA
		cNumCobranca := (cAlias)->E1_PLNUCOB
		nValorBaixa := (cAlias)->FK1_VALOR
		cSeqBaixa := (cAlias)->FK1_SEQ

		GeraLog(" -> Titulo: "+cPrefixo+cNumero+cParcela+cTipo+"/ Valor: "+cValToChar(nValorBaixa)+" Seq.Baixa: "+cSeqBaixa)

		Do Case 
			Case (cAlias)->FK1_TPDOC $ "BA/VL/BL/V2" // Baixas
				GeraLog(" Baixa: "+(cAlias)->FK1_TPDOC, .F.)
				If !CheckBaixaRateio(cPrefixo, cNumero, cParcela, cTipo, cSeqBaixa)
                    GeraLog(" Gravando Rateio da Baixa...", .F.)
    				GravaRateioBaixa(cPrefixo, cNumero, cParcela, cTipo, dDataBaixa, cCliente, cLoja, cNumCobranca, nValorBaixa, cSeqBaixa)
                    
                    GeraLog("", .F.)
				EndIf
		    Case (cAlias)->FK1_TPDOC == "ES" // Estorno
				GeraLog(" Estorno: "+(cAlias)->FK1_TPDOC, .F.)
				If CheckBaixaRateio(cPrefixo, cNumero, cParcela, cTipo, cSeqBaixa)

                    GeraLog(" Deletando Rateio da Baixa...", .F.)
					//Item retirado devido que não podemos excluir itens emum momvemnto contabil
					//DelBaixaRateio(cPrefixo, cNumero, cParcela, cTipo, cSeqBaixa)

                    GeraLog("", .F.)
				EndIf 
		EndCase
				
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckEstornoBaixa
Verifica se o a baixa possui estorno no financeiro

@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CheckEstornoBaixa(cFilialE1, cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja, cSeqBaixa)

	Local lRetorno := .F.
	Local nQtdRegistro := 0
	Local cChaveFK7 := ""
	Local cIdDoc := ""
	
	cChaveFK7 := cFilialE1+"|"+cPrefixo+"|"+cNumero+"|"+cParcela+"|"+cTipo+"|"+cCliente+"|"+cLoja

	cIdDoc := FinBuscaFK7(cChaveFK7, "SE1")

	If !Empty(cIdDoc)
		cQuery := " SELECT COUNT(*) CONTADOR FROM "+RetSQLName("FK1")+" FK1 "
		cQuery += " WHERE FK1.FK1_FILIAL = '" +xFilial("FK1")+"' "
		cQuery += "   AND FK1.FK1_IDDOC  = '"+cIdDoc+"' "
		cQuery += "   AND FK1.FK1_SEQ  = '"+cSeqBaixa+"' "
		cQuery += "   AND FK1.FK1_TPDOC = 'ES' " 
		cQuery += "   AND FK1.D_E_L_E_T_ = ' ' "

		nQtdRegistro := MPSysExecScalar(cQuery, "CONTADOR")

		lRetorno := IIF(nQtdRegistro > 0, .T., .F.)
	EndIf
	
	If lRetorno
		GeraLog(" Baixa Estornada no Financeiro.", .F.)
	Else
		GeraLog(" Baixa Ativa no Financeiro.", .F.)
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckBaixaRateio
Verifica se existe baixa grava na tabela B6U

@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CheckBaixaRateio(cPrefixo, cNumero, cParcela, cTipo, cSeqBaixa)

	Local lRetorno := .F.
	Local nQtdRegistro := 0
	 
	cQuery := " SELECT COUNT(*) CONTADOR FROM "+RetSQLName("B6U")+" B6U "
	cQuery += " WHERE B6U.B6U_FILIAL = '" +xFilial("B6U")+"' "
	cQuery += "   AND B6U.B6U_PREFIX = '"+cPrefixo+"' " 
	cQuery += "   AND B6U.B6U_NUMTIT = '"+cNumero+"' " 
	cQuery += "   AND B6U.B6U_PARCEL = '"+cParcela+"' " 
	cQuery += "   AND B6U.B6U_TIPTIT = '"+cTipo+"' " 
	cQuery += "   AND B6U.B6U_SEQBAI = '"+cSeqBaixa+"' " 
	cQuery += "   AND B6U.D_E_L_E_T_ = ' ' "

	nQtdRegistro := MPSysExecScalar(cQuery, "CONTADOR")

	lRetorno := IIF(nQtdRegistro > 0, .T., .F.)

	If lRetorno
		GeraLog(" Baixa do Título já processado na Tabela B6U.", .F.)
	Else
		GeraLog(" Baixa do Título não processado na Tabela B6U.", .F.)
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} DelBaixaRateio
Deleta baixa estornada na tabela de rateio

@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function DelBaixaRateio(cPrefixo, cNumero, cParcela, cTipo, cSeqBaixa)

	Local lRetorno := .T.
	 
	cQuery := " UPDATE "+RetSQLName("B6U")+" SET B6U_LA_CAN = 'S' "
	cQuery += " WHERE B6U_FILIAL = '" +xFilial("B6U")+"' "
	cQuery += "   AND B6U_PREFIX = '"+cPrefixo+"' " 
	cQuery += "   AND B6U_NUMTIT = '"+cNumero+"' " 
	cQuery += "   AND B6U_PARCEL = '"+cParcela+"' " 
	cQuery += "   AND B6U_TIPTIT = '"+cTipo+"' " 
	cQuery += "   AND B6U_SEQBAI = '"+cSeqBaixa+"' " 
	cQuery += "   AND D_E_L_E_T_ = ' ' "

	If TCSQLExec(cQuery) < 0
		lRetorno := .F.
	EndIf

	If lRetorno
		GeraLog(" Registro deletado com sucesso!", .F.)
	Else
		GeraLog(" Não foi possivel deletar a baixa da tabela B6U", .F.)
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaRateioBaixa
Realiza o rateio da baixa e a gravação na tabela B6U

@author Vinicius Queiros Teixeira
@since 08/04/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GravaRateioBaixa(cPrefixo, cNumero, cParcela, cTipo, dDataEmissao, cCliente, cLoja, cPlNumCob,;
                                nValorBaixa, cSeqBaixa)

	Local lRetorno := .F.
	Local cQuery := ""
	Local cAlias := ""
	Local cTipoTitulo := ""
	Local cOperadora := ""
	Local cNumCobranca := ""
	Local cTipoBaixa := ""
	Local nX := 0
	Local nPorcenRateio := 0
	Local nVlrRateio:= 0
	Local nBusca := 0					
	Local nTotalRateio	:= 0 
	Local nVltTotalTitulo := 0
	Local aLancamentos := {}
	Local aRateioBaixa := {}
	Local aRateioTotal := {}
	Local nValorDif := 0
    Local nTotalNCC := 0
    Local nVlrBase := 0
	
	Default nValorBaixa := 0 
	Default cSeqBaixa := ""
	Default nRecno := 0

	cOperadora := SubStr(cPlNumCob, 1, 4)
	cNumCobranca := SubStr(cPlNumCob, 5)

	cAlias := GetNextAlias()
	cQuery := " SELECT BM1_VALOR, BM1_CODTIP, BM1_TIPTIT FROM " + RetSQLName("BM1") + " BM1 "
	cQuery += " WHERE BM1_FILIAL = '" + xFilial("BM1") + "'"
	cQuery += "	  AND BM1.BM1_PLNUCO = '"+cPlNumCob+"'"
	cQuery += "	  AND BM1.BM1_PREFIX = '"+cPrefixo+"'"
	cQuery += "	  AND BM1.BM1_NUMTIT = '"+cNumero+"'"
	cQuery += "	  AND BM1.BM1_PARCEL = '"+cParcela+"'"
	cQuery += "   AND BM1.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY BM1_CODTIP "

	DbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAlias,.F.,.T.)

    GeraLog(" Buscando Lançamentos do Título na BM1", .F.)

	While !(cAlias)->(Eof())

        If (cAlias)->BM1_TIPTIT <> "NCC" 
            nBusca := Ascan(aLancamentos, {|x| x[1] == (cAlias)->BM1_CODTIP})
            If nBusca > 0
                aLancamentos[nBusca][2] += (cAlias)->BM1_VALOR
            Else	
                aAdd(aLancamentos,{ (cAlias)->BM1_CODTIP, (cAlias)->BM1_VALOR })
            EndIf
            cTipoTitulo := (cAlias)->BM1_TIPTIT
            nVltTotalTitulo += (cAlias)->BM1_VALOR
		Else
            nTotalNCC += (cAlias)->BM1_VALOR
        EndIf

		(cAlias)->(DbSkip())		
	EndDo
	
	(cAlias)->(DbCloseArea())

	If nValorBaixa > 0 .And. Len(aLancamentos) > 0 
		For nX := 1 To Len(aLancamentos)

			nPorcenRateio := ((aLancamentos[nX][2] * 100) / nVltTotalTitulo) / 100 // Porcentagem do lançamento sobre o valor do titulo
			nVlrRateio := Round(nPorcenRateio * nValorBaixa ,2) // Valor que corresponde a porcentagem do lançamento sobre a baixa

            If cTipo == "NCC"
                cTipoBaixa := "BAIXA-NCC"
                nVlrBase := Round(nPorcenRateio * nTotalNCC ,2) // Valor que corresponde a porcentagem do lançamento sobre o valor total da NCC
            Else
                cTipoBaixa := "BAIXA-TIT"
                nVlrBase := aLancamentos[nX][2]
            EndIf

			aAdd(aRateioBaixa, { cOperadora ,; 			// [1]  B6U_CODINT	 
							     cNumCobranca ,; 		// [2]  B6U_NUMCOB	 
							     aLancamentos[nX][1] ,; // [3]  B6U_CODTIP
							     cPrefixo ,; 			// [4]  B6U_PREFIX
							     cNumero ,; 			// [5]  B6U_NUMTIT 
							     cTipo ,; 				// [6]  B6U_TIPTIT	 
							     cParcela ,; 			// [7]  B6U_PARCEL
							     cTipoBaixa ,;			// [8]  B6U_IMPOST 		 
							     nVlrRateio ,;			// [9]  B6U_VALOR
							     nVlrBase ,;	        // [10] B6U_VALBAS
							     dDataEmissao ,;		// [11] B6U_DTEMIS
							     cCliente ,;			// [12] B6U_CODIGO
							     cLoja ,;				// [13] B6U_LOJA
							     cTipoTitulo ,;			// [14] B6U_TIPBAS
								 cSeqBaixa }) 			// [15] B6U_SEQBAI
			nTotalRateio += nVlrRateio	 

			GeraLog(" Lançamento: "+aLancamentos[nX][1]+" / Tipo da Baixa: "+cTipoBaixa+" / Valor:"+cValToChar(nVlrRateio), .F.)
		Next nX

		// Quando houver diferença de centavos no rateio, adiciona/diminui do ultimo lançamento
		If nTotalRateio > 0
			nTotalRateio := nValorBaixa - nTotalRateio
		EndIf
		If nTotalRateio <> 0 .And. Len(aRateioBaixa) > 0
			aRateioBaixa[Len(aRateioBaixa)][9] += nTotalRateio
		EndIf
	EndIf

	// Ajuste necessária devido a diferença de centavo nos lançamentos, apos realizar a ultima baixa do titulo
	aRateioTotal := PLRatTotal(cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja)
	If Len(aRateioTotal) > 0 
		For nX := 1 To Len(aRateioBaixa)
			nBusca := Ascan(aRateioTotal, {|x| x[1] == aRateioBaixa[nX][3] }) 

			If nBusca > 0
				nValorDif := aRateioTotal[nBusca][2] - (aRateioTotal[nBusca][3] + aRateioBaixa[nX][9] )
				If nValorDif <= 0.02 .And. nValorDif <> 0  // Se o valor for maior é porque o titulo não foi baixado totalmente
					aRateioBaixa[nX][9] += nValorDif
				EndIf 
			EndIf

		Next nX
	EndIf

	If Len(aRateioBaixa) > 0
		lRetorno := PLGrvRateio(aRateioBaixa)
	EndIf

	If lRetorno
		GeraLog(" Baixa gravada na B6U com sucesso!", .F.)
	Else
		GeraLog(" Não foi possivel gravar a baixa na B6U.", .F.)
	EndIf

Return lRetorno


//------------------------------------------------------------------- 
/*/{Protheus.doc} PLRatTotal
Busca o valor total do titulo e o valor baixado (Impostos+NCC+Baixas)

@author Vinicius Queiros Teixeira
@since 02/02/2021
@version Protheus 12
/*/
//------------------------------------------------------------------- 
Static Function PLRatTotal(cPrefixo, cNumero, cParcela, cTipoTit, cCliente, cLoja)

	Local cQuery := ""
	Local cAlias := ""
	Local nBusca := 0
	Local aTotalLanc := {}
	Local cTipo := ""
	Local cSeqBaixa := ""
	Local nValor := 0

	cAlias := GetNextAlias()
	cQuery := " SELECT * FROM "+RetSQLName("B6U")+" B6U "
	cQuery += " WHERE B6U.B6U_FILIAL = '"+xFilial("B6U")+"'"
	cQuery += "   AND B6U.B6U_PREFIX = '"+cPrefixo+"' " 
	cQuery += "   AND B6U.B6U_NUMTIT = '"+cNumero+"' " 
	cQuery += "   AND B6U.B6U_PARCEL = '"+cParcela+"' "
    If cTipoTit == "NCC"
        cQuery += " AND B6U.B6U_TIPTIT = '"+cTipoTit+"' "
    EndIf
	cQuery += "   AND B6U.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY B6U_PREFIX,B6U_NUMTIT,B6U_PARCEL,B6U_CODTIP"

	DbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAlias,.F.,.T.)
	    
	While !(cAlias)->(Eof())

		nValor := 0
		cTipo := (cAlias)->B6U_TIPTIT
		cSeqBaixa := (cAlias)->B6U_SEQBAI

		If Alltrim((cAlias)->B6U_IMPOST) == "BAIXA-TIT" .Or. Alltrim((cAlias)->B6U_IMPOST) == "BAIXA-NCC"
			If !CheckEstornoBaixa(xFilial("SE1"), cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja, cSeqBaixa) // Verifica se a baixa não foi estornada
				nValor := (cAlias)->B6U_VALOR
			EndIf
		Else
			nValor := (cAlias)->B6U_VALOR
		EndIf

		nBusca := Ascan(aTotalLanc, {|x| x[1] == (cAlias)->B6U_CODTIP })
		If nBusca > 0
			aTotalLanc[nBusca][3] += nValor
            If (cAlias)->B6U_TIPTIT <> "NCC"
                aTotalLanc[nBusca][2] := (cAlias)->B6U_VALBAS
            EndIf
		Else	
			aAdd(aTotalLanc,{ (cAlias)->B6U_CODTIP ,; // Tipo de Lançamento
							  (cAlias)->B6U_VALBAS ,; // Valor Líquido (Esperado)
							  nValor }) 			  // Valor Baixado
		EndIf

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())
	
Return aTotalLanc


//-----------------------------------------------------------------
/*/{Protheus.doc} GeraLog
Gera Log do Schedule de Rateio de Baixas
 
@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Prothues 12
/*/
//-----------------------------------------------------------------
Static Function GeraLog(cMsg, lDateTime)

    Local cNameLog := "Schedule_Rateio_Baixa.log"
    Local cDateTime := Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + "-" + Time()

    Default cMsg := ""
    Default lDateTime := .T.

    If !Empty(cNameLog)   
        If lDateTime
            PlsLogFil("["+cDateTime+"] " + cMsg, cNameLog)
        Else
            PlsLogFil(cMsg, cNameLog)
        EndIf
    EndIf

Return