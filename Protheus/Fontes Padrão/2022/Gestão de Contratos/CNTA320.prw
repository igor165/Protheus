#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'CNTA320.CH'

Static _aValDev := {}
Static _cFilCtr := ""

//=============================================================================
/*/{Protheus.doc}  CNTA320
Efetua ajustes dos saldos do contrato

@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
//=============================================================================
Function CNTA320(aLog, lKeepLog)
Local cLog		:= ""
Local lIsBlind	:= IsBlind()
Local bAction	:= Nil
Local lContinua	:= IIF(lIsBlind, .T., MsgYesNo( STR0005, STR0001 ))//-- Esta rotina efetua ajustes de saldos do contrato, das planilhas, dos itens e dos cronogramas com base nas medições realizadas até o momento. É importante que um backup seja realizado. Para processar contratos eventuais configure o parâmetro MV_320SLD = 2. Deseja prosseguir?
Default aLog	:= {}
Default lKeepLog:= .F.

If lContinua	
	If Pergunte("CNTA320",!lIsBlind)
		bAction := {||aLog:= AjustaSaldos()}
		If(lIsBlind)
			Eval(bAction)
		Else
			Processa(bAction, STR0001, STR0002) //-- Ajuste de Saldos | Processando, aguarde...
		EndIf

		cLog:= MontaLog(aLog)
		If !lIsBlind
			If Empty(cLog) .and. Len(aLog)>0
				FWAlertInfo(STR0003,'CNTA320') //-- Processo finalizado! Nenhum contrato precisou ser ajustado.
			ElseIf Empty(cLog) .and. Len(aLog)=0
				FWAlertWarning(STR0006,'CNTA320') //-- Contrato(s) não encontrado(s)
			Else		
				GCTLog(cLog, STR0004, 1, .T.) //-- Ajuste de Saldos
			EndIf
		EndIf
		If !lKeepLog
			FwFreeArray(aLog)
		EndIf
		aSize(_aValDev, 0)
	EndIf
EndIf

Return cLog

//=============================================================================
/*/{Protheus.doc}  AjustaSaldos
Ajusta os campos CNA_SALDO e CN9_SALDO, com base nas medições realizadas para 
os itens da planilha.

@return aLog, Array, array com os contratos processados
@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
//=============================================================================
Static Function AjustaSaldos()
Local cAliasCNA  := GetNextAlias()
Local cAliasCNAP := GetNextAlias()
Local cContrato  := ""
Local cRevisa    := ""
Local cContraPos := ""
Local nCNASaldo  := 0
Local nNewSaldo  := 0
Local nDifSaldo  := 0
Local nX         := 1
Local nY         := 1
Local lAjustou   := .F.
Local lFixo      := .F.
Local lEventual  := .F.
Local lEvenSItem := .F.
Local lFisico	 := .F.
Local aLog       := {}
Local nTipoSaldo := SuperGetMV("MV_320SLD", .F., 1) //-- Processa apenas contratos fixos = 1, fixos e eventuais = 2

//-- Busca planilhas da revisão vigente de cada contrato que não esteja em revisão(CN9_SITUAC = 05 que não tenha CN9_SITUAC = 09)
BeginSql Alias cAliasCNA
	SELECT CNA.CNA_CONTRA, CNA.CNA_REVISA, CNA.CNA_NUMERO, CNA.CNA_SALDO, CNA.CNA_FORNEC, CN9.*
	FROM %table:CNA% CNA
	INNER JOIN %table:CN9% CN9 ON(
			CN9.CN9_FILIAL = CNA.CNA_FILIAL
		AND CN9.CN9_NUMERO = CNA.CNA_CONTRA
		AND CN9.CN9_REVISA = CNA.CNA_REVISA
		AND CN9.%NotDel%)
	WHERE 		
		 CNA.CNA_FILIAL = %xFilial:CNA% 
		 AND CNA.CNA_CONTRA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%		 
		 AND CN9.CN9_SITUAC = '05'
		 AND CN9.CN9_REVATU = %exp:Space(Len(CN9->CN9_REVATU))%
		 AND CNA.%NotDel%	
	ORDER BY CNA_CONTRA, CNA_NUMERO		 
		 
EndSQL

CNA->(dbSetOrder(1))
CN9->(dbSetOrder(1))

ProcRegua( (cAliasCNA)->(LastRec()) )
While (cAliasCNA)->(!EOF())
	IncProc()	
    lFixo     	:= CN300RetSt("FIXO"	,0,(cAliasCNA)->CNA_NUMERO,(cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CN9_FILCTR,.F.)
    lEventual	:= CN300RetSt("MEDEVE"	,0,(cAliasCNA)->CNA_NUMERO,(cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CN9_FILCTR,.F.)
    lFisico 	:= CN300RetSt("FISICO"	,0,(cAliasCNA)->CNA_NUMERO,(cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CN9_FILCTR,.F.)
    lEvenSItem 	:= !lFixo .And. lEventual //-- Verifica se o contrato é eventual sem itens

	If nTipoSaldo == 2 .Or. !lEventual
		cContrato := (cAliasCNA)->CNA_CONTRA
		cRevisa   := (cAliasCNA)->CNA_REVISA
		_cFilCtr  := (cAliasCNA)->CN9_FILCTR
		If nY == 1	
			aAdd(aLog, {cContrato, cRevisa, "", 0 , 0, {}, lAjustou})
		EndIf

		aAdd(aLog[nX][6], {cContrato, cRevisa, (cAliasCNA)->CNA_NUMERO, (cAliasCNA)->CNA_FORNEC, (cAliasCNA)->CNA_SALDO, 0, {}, {}, {}})

		FwLogMsg("INFO", , "", "CNTA260", "", "01", "Contrato: " + (cAliasCNA)->CNA_CONTRA + "Revisão: " + (cAliasCNA)->CNA_REVISA + "Planilha: " + (cAliasCNA)->CNA_NUMERO + "nX: " + cValtoChar(nX) + "nY: " + cValtoChar(nY), 0, -1, {})
		
        If !lEvenSItem //-- Não atualiza CNA caso o contrato não possua itens
            nNewSaldo := CalcSaldo((cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CNA_REVISA,(cAliasCNA)->CNA_NUMERO, @aLog[nX][6][nY], @lAjustou)
            nDifSaldo := nNewSaldo - (cAliasCNA)->CNA_SALDO
		
            If ABS(nDifSaldo) > 0.02

                If CNA->(dbSeek(xFilial('CNA')+(cAliasCNA)->CNA_CONTRA+(cAliasCNA)->CNA_REVISA+(cAliasCNA)->CNA_NUMERO))
                    RecLock( "CNA", .F. )
                    nCNASaldo:= CNA->CNA_SALDO += nDifSaldo
                    CNA->( MsUnlock() )
                    lAjustou := .T.
                    aLog[nX][6][nY][6]+= nCNASaldo
                EndIf
                
            Else
                aLog[nX][6][nY][6]+= (cAliasCNA)->CNA_SALDO								
            EndIf
        EndIf	
		
		aLog[nX][7]:= lAjustou
		
		If lFisico			
			lAjustou := (cAliasCNA)->(AjsCNFxCNS(CNA_CONTRA, CNA_REVISA, CNA_NUMERO, @aLog[nX][6][nY]))//Ajusta valor previsto da CNF pelo cronograma físico(CNS)
		EndIf

		ReajuCrono((cAliasCNA)->CNA_CONTRA, (cAliasCNA)->CNA_REVISA, (cAliasCNA)->CNA_NUMERO, @aLog[nX][6][nY], @lAjustou)			
		
        aLog[nX][7]:= aLog[nX][7] .Or. lAjustou

		(cAliasCNA)->(dbSkip())
		cContraPos:= (cAliasCNA)->CNA_CONTRA+(cAliasCNA)->CNA_REVISA
		nY++
		If cContraPos != cContrato+cRevisa
			
			BeginSql Alias cAliasCNAP	
				SELECT SUM (CNA.CNA_SALDO) CNA_SALDO
				FROM %table:CNA% CNA
				WHERE
				CNA.CNA_FILIAL = %xFilial:CNA% AND
				CNA.CNA_CONTRA = %exp:cContrato% AND
				CNA.CNA_REVISA = %exp:cRevisa% AND
				CNA.%NotDel%
			EndSql
		
			If CN9->(dbSeek(xFilial('CN9')+cContrato+cRevisa)) 	
				aLog[nX][3]:= CN9->CN9_TPCTO
				aLog[nX][4]:= CN9->CN9_SALDO
				
				If CN9->CN9_SALDO != (cAliasCNAP)->CNA_SALDO
					RecLock( "CN9", .F. )
					CN9->CN9_SALDO := (cAliasCNAP)->CNA_SALDO	
					CN9->( MsUnlock() )
					lAjustou:= .T.
						
					aLog[nX][5]:= (cAliasCNAP)->CNA_SALDO
				Else
					aLog[nX][5]:= CN9->CN9_SALDO
				EndIf

			EndIf

            aLog[nX][7]:= aLog[nX][7] .Or. lAjustou

			nX++
			nY:= 1	
			lAjustou := .F.		
			
			(cAliasCNAP)->(dbCloseArea())

		EndIf
	Else
		(cAliasCNA)->(dbSkip())
	EndIf

EndDo

(cAliasCNA)->(dbCloseArea())

Return aLog

/*/{Protheus.doc}  CalcSaldo
Calcula o saldo dos itens da planilha e efetua ajuste dos itens na CNB

@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param aLog, array, Dados dos contratos processados
@param lAjustou, logico, verifica se houver ajuste

@return nSaldo, numerico, saldo da planilha

@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
Static Function CalcSaldo(cContra, cRev, cPlan, aLog, lAjustou)
Local nSaldo     := 0
Local nSldItem   := 0
Local nSldQtd    := 0
Local aCNEMed    := {0,0,0}
Local nI         := 1
Local nDifQdt    := 0
Local nDifSld    := 0
Local nDecQtMed  := TamSx3("CNB_QTDMED")[2]
Local nTipoSaldo := SuperGetMV("MV_320SLD", .F., 1) //-- Processa apenas contratos fixos = 1, fixos e eventuais
Local cItem      := ""
Local cAliasCNB  := GetNextAlias()

Default aLog := {}
Default lAjustou := .F.

BeginSql Alias cAliasCNB

	SELECT 	CNB_CONTRA,CNB_REVISA,CNB_NUMERO,CNB_ITEM,CNB_VLTOT,CNB_QUANT,CNB_VLUNIT,
			CNB_QTDMED,CNB_SLDMED,CNB_PRODUT,CNB_DESCRI
	FROM 	%table:CNB% CNB
	WHERE	CNB.CNB_FILIAL = %xFilial:CNB% AND
			CNB.CNB_CONTRA = %exp:cContra% AND
			CNB.CNB_REVISA = %exp:cRev% AND
			CNB.CNB_NUMERO = %exp:cPlan% AND
			CNB.%NotDel%
EndSQL

CNB->(dbSetOrder(1))

While (cAliasCNB)->(!EOF())
	IncProc()
	cItem		:= (cAliasCNB)->CNB_ITEM
	
	aCNEMed	:= QuantMed(cContra, cRev, cPlan, cItem,(cAliasCNB)->CNB_VLTOT, (cAliasCNB)->CNB_QUANT)
	nSldQtd	:= (cAliasCNB)->CNB_QUANT - aCNEMed[nTipoSaldo]
	nSldItem	:= nSldQtd * (cAliasCNB)->CNB_VLUNIT
	
	aCNEMed[1]	:= Round(aCNEMed[1], nDecQtMed) //Quantidade
	aCNEMed[2]	:= Round(aCNEMed[2], nDecQtMed) //Quantidade proporcional ao valor da medição
	
	if nTipoSaldo == 1
		nDifQdt	:= aCNEMed[1] - (cAliasCNB)->CNB_QTDMED
	Else
		nDifQdt	:= aCNEMed[2] - (cAliasCNB)->CNB_QTDMED
	EndIf

	nDifSld	:= nSldQtd - (cAliasCNB)->CNB_SLDMED
	If nSldItem > 0 
		nSaldo += nSldItem
	EndIf
	
	aadd(aLog[7], {(cAliasCNB)->CNB_ITEM, (cAliasCNB)->CNB_PRODUT, (cAliasCNB)->CNB_DESCRI, (cAliasCNB)->CNB_QTDMED, (cAliasCNB)->CNB_SLDMED, 0, 0})
	
	If aCNEMed[nTipoSaldo] < 0 //-- Tratamento para valores negativos
		aCNEMed[nTipoSaldo] := 0
	EndIf
	If nSldQtd < 0
		nSldQtd := 0
	EndIf
	
	If ABS(nDifQdt) > 0.001 .Or. ABS(nDifSld) > 0.001 .And. ((cAliasCNB)->CNB_QTDMED != aCNEMed[nTipoSaldo] .Or. (cAliasCNB)->CNB_SLDMED != nSldQtd )

		If CNB->( dbSeek( xFilial('CNB') + (cAliasCNB)->CNB_CONTRA + (cAliasCNB)->CNB_REVISA + (cAliasCNB)->CNB_NUMERO + (cAliasCNB)->CNB_ITEM ) )
			
			RecLock( "CNB", .F. )
			CNB->CNB_QTDMED := aCNEMed[nTipoSaldo]
			CNB->CNB_SLDMED := nSldQtd
			CNB->( MsUnlock() )
			lAjustou := .T.
			
			aLog[7][nI][6]:= aCNEMed[nTipoSaldo] //Quantidade Medida		
			aLog[7][nI][7]:= nSldQtd //Quantidade a Medir
			
		EndIf	
	Else						
		aLog[7][nI][6]:= (cAliasCNB)->CNB_QTDMED	//Quantidade Medida		
		aLog[7][nI][7]:= (cAliasCNB)->CNB_SLDMED //Quantidade a Medir		
	EndIf

	(cAliasCNB)->(dbSkip())
	nI++
End

(cAliasCNB)->(dbCloseArea())

return nSaldo

/*/{Protheus.doc} QuantMed
Retorna a quantidade medida do item da planilha
@type function
@author janaina.jesus
@since 24/07/2018
@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param cItem, character, Item da planilha
@param nTotItem, numeric, Valor total do item no contrato
@param nQtdItem, numeric, Quantidade total do item no contrato
@return array, Quatidade medida do item do contrato
/*/
Static Function QuantMed(cContra, cRev, cPlan, cItem, nTotItem, nQtdItem)
Local aArea    	:= GetArea()
Local cAliasCNE	:= GetNextAlias()
Local aCNEMed  	:= {0,0}
Local cWhere   	:= ""
Local cJoinSC5	:= "%" + FWJoinFilial("SC5", "CNE") + "%"
Local cJoinSD2	:= "%" + FWJoinFilial("SD2", "SC5") + "%"
Local nPosDev	:= 0
Local cChave	:= cContra+cRev+cPlan

cWhere += "AND CNE.CNE_CONTRA = '" + cContra + "' "
cWhere += "AND CNE.CNE_REVISA = '" + cRev + "' "
cWhere += "AND CNE.CNE_NUMERO = '" + cPlan + "' "
cWhere += "AND CNE.CNE_ITEM = '" + cItem + "' "
cWhere += "AND CND.CND_DTFIM != '"+Space(8)+"'"
	
cWhere := '%'+cWhere+'%'

BeginSql Alias cAliasCNE

	SELECT CND.CND_SERVIC, CND.CND_NUMMED, CNE.CNE_QUANT, CNE.CNE_VLTOT, ISNULL(SD2.D2_QTDEDEV, 0) D2_QTDEDEV, ISNULL(SD2.D2_VALDEV, 0) D2_VALDEV
	FROM %table:CND% CND
	INNER JOIN %table:CNE% CNE ON
		CNE.CNE_FILIAL = CND.CND_FILIAL AND 
		CNE.CNE_CONTRA = CND.CND_CONTRA AND 
		CNE.CNE_REVISA = CND.CND_REVISA AND 
		CNE.CNE_NUMMED = CND.CND_NUMMED AND
		CNE.CNE_VLTOT > 0
	LEFT JOIN %table:SC5% SC5 ON (%exp:cJoinSC5% AND C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO AND SC5.%NotDel%)
	LEFT JOIN %table:SC6% SC6 ON (SC6.C6_FILIAL = SC5.C5_FILIAL AND C5_CLIENT = C6_CLI AND C5_LOJACLI = C6_LOJA AND C6_NUM = C5_NUM AND C6_ITEMED = CNE_ITEM AND SC6.%NotDel%) 
	LEFT JOIN %table:SD2% SD2 ON (%exp:cJoinSD2% AND D2_PEDIDO = C5_NUM AND D2_ITEMPV = C6_ITEM AND C5_CLIENT = D2_CLIENTE AND D2_LOJA = C5_LOJACLI AND SD2.%NotDel%)				 
	WHERE	CND.CND_FILCTR = %exp:_cFilCtr% AND
			CND.%NotDel% AND
			CNE.%NotDel%
			%exp:cWhere%

EndSQL

While (cAliasCNE)->(!EOF()) 

	aCNEMed[1] += (cAliasCNE)->CNE_QUANT - (cAliasCNE)->D2_QTDEDEV//Subtrai a quantidade devolvida da quantidade do item da medição
	aCNEMed[2] += ( ( (cAliasCNE)->CNE_VLTOT / nTotItem ) * nQtdItem ) //qtde proporcional ao valor medido

	If (cAliasCNE)->D2_QTDEDEV > 0
		If (nPosDev := aScan(_aValDev, {|x| x[1] == cChave+(cAliasCNE)->CND_NUMMED})) > 0
			_aValDev[nPosDev, 2] += (cAliasCNE)->D2_VALDEV
		Else			
			aAdd(_aValDev, {cChave+(cAliasCNE)->CND_NUMMED, (cAliasCNE)->D2_VALDEV})
		EndIf
	EndIf
	(cAliasCNE)->(dbSkip())
EndDo

(cAliasCNE)->(dbCloseArea())

RestArea(aArea)
Return aCNEMed

/*/{Protheus.doc} ReajuCrono
Efetua o ajuste do saldo do cronograma financeiro do contrato.

@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param cItem, character, Item da planilha
@param aLog, array, Dados dos contratos processados
@param lAjustou, logico, verifica se houver ajuste

@return nQtdMed, numérico, Quatidade medida do item do contrato
    
@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
Static Function ReajuCrono(cContra, cRev, cPlan, aLog, lAjustou)
Local cAliasCNF  := GetNextAlias()
Local nSaldo     := 0
Local nDifSaldo  := 0
Local nVlrMed    := 0
Local nX         := 1

Default aLog := {}
Default lAjustou := .F.

BeginSql Alias cAliasCNF

	SELECT 	CNF_CONTRA,CNF_REVISA,CNF_NUMERO,CNF_PARCEL,CNF_COMPET,CNF_VLPREV,CNF_VLREAL,CNF_SALDO
	FROM 	%table:CNF% CNF
	WHERE	CNF.CNF_FILIAL = %xFilial:CNF% AND
			CNF.CNF_CONTRA = %exp:cContra% AND
			CNF.CNF_REVISA = %exp:cRev% AND
			CNF.CNF_NUMPLA = %exp:cPlan% AND
			CNF.%NotDel%
			ORDER BY
			CNF.CNF_PARCEL

EndSQL

dbSelectArea("CNF")
dbSetOrder(3) //CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO+CNF_PARCEL                                                                                                                                                                                                                 

While (cAliasCNF)->(!EOF())
	
	nVlrMed := CN320VlrMed(cContra, cRev, cPlan, (cAliasCNF)->CNF_COMPET)
	nSaldo := ((cAliasCNF)->CNF_VLPREV - (cAliasCNF)->CNF_VLREAL)
	nDifSaldo:= (cAliasCNF)->CNF_SALDO - nSaldo
	
	aadd(aLog[8], {(cAliasCNF)->CNF_PARCEL, (cAliasCNF)->CNF_SALDO, 0, (cAliasCNF)->CNF_VLREAL,0})
	
	If (cAliasCNF)->CNF_VLREAL <> nVlrMed

		If CNF->(dbSeek(xFilial('CNF')+(cAliasCNF)->CNF_CONTRA+(cAliasCNF)->CNF_REVISA+(cAliasCNF)->CNF_NUMERO+(cAliasCNF)->CNF_PARCEL))
			RecLock( "CNF", .F. )
			CNF->CNF_VLREAL := nVlrMed
			nSaldo := CNF->CNF_VLPREV - CNF->CNF_VLREAL
			CNF->CNF_SALDO := nSaldo
			CNF->( MsUnlock() )
			
			aLog[8][nX][3] := nSaldo
			aLog[8][nX][5] := nVlrMed
						
			lAjustou := .T.
		EndIf
	ElseIf ABS(nDifSaldo) > 0.02

		If CNF->(dbSeek(xFilial('CNF')+(cAliasCNF)->CNF_CONTRA+(cAliasCNF)->CNF_REVISA+(cAliasCNF)->CNF_NUMERO+(cAliasCNF)->CNF_PARCEL))
			RecLock( "CNF", .F. )
			CNF->CNF_SALDO := nSaldo
			CNF->( MsUnlock() )
			
			aLog[8][nX][3] := nSaldo
			
			lAjustou := .T.
		EndIf	
			
	Else			
		aLog[8][nX][3] := (cAliasCNF)->CNF_SALDO
	EndIf	
	nX++
	(cAliasCNF)->(dbSkip())
	
EndDo
(cAliasCNF)->(dbCloseArea())

Return 

/*/{Protheus.doc} CN320VlrMed
Retorna o valor total medido pela competencia.

@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param cCompet, character, Competência do Cronograma

@return nVlrMed, numérico, Valor medido na competencia do Cronograma Financeiro.
    
@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
Static Function CN320VlrMed(cContra, cRev, cPlan, cCompet)
Local cAliasCND	:= GetNextAlias()
Local nVlrMed   := 0
Local aArea     := GetArea()
Local nPosDev	:= 0
Local cChave	:= ""
Local cCN9Join	:= ""
Local cCNFJoin	:= ""

cCN9Join := "CN9.CN9_FILCTR = CND.CND_FILCTR"
cCN9Join += " AND CN9.CN9_NUMERO = CND.CND_CONTRA"
cCN9Join += " AND CN9.CN9_REVISA = CND.CND_REVISA"
cCN9Join := '%'+cCN9Join+'%'

cCNFJoin := "CNF.CNF_FILIAL=CN9.CN9_FILIAL"
cCNFJoin += " AND CNF.CNF_CONTRA = CN9.CN9_NUMERO"
cCNFJoin += " AND CNF.CNF_REVISA = CN9.CN9_REVISA"
cCNFJoin += " AND CNF.CNF_COMPET = CND.CND_COMPET"
cCNFJoin := '%'+cCNFJoin+'%'

BeginSql Alias cAliasCND

		SELECT 	SUM (CXN_VLLIQD) CND_VLTOT, CND.CND_NUMMED
			FROM 	%table:CND% CND

			INNER JOIN %table:CN9% CN9 ON(%exp:cCN9Join% AND CN9.%NotDel%)
			INNER JOIN %table:CNF% CNF ON(%exp:cCNFJoin% AND CNF.%NotDel%)

			INNER JOIN %Table:CXN% CXN ON( 
				CXN.CXN_FILIAL = CND.CND_FILIAL
				AND CXN.CXN_CONTRA = CND.CND_CONTRA
				AND CXN.CXN_REVISA = CND.CND_REVISA
				AND CXN.CXN_NUMMED = CND.CND_NUMMED
				AND CXN.CXN_NUMPLA = CNF.CNF_NUMPLA
				AND CXN.CXN_CRONOG = CNF.CNF_NUMERO
				AND CXN.CXN_PARCEL = CNF.CNF_PARCEL
				AND CXN.CXN_CHECK  = 'T'
				AND CXN.%NotDel%)
			
			WHERE	CND.CND_DTFIM <> %exp:Space(8)%	AND
					CND.CND_FILCTR = %exp:_cFilCtr%	AND
					CND.CND_CONTRA = %exp:cContra% 	AND
					CND.CND_REVISA = %exp:cRev%  	AND
					CND.CND_COMPET = %exp:cCompet%	AND
					CNF.CNF_NUMPLA = %exp:cPlan% 	AND					
					CND.%NotDel%
			GROUP BY CND.CND_NUMMED
		UNION
		SELECT 	SUM (CND_VLTOT) CND_VLTOT, CND.CND_NUMMED
			FROM 	%table:CND% CND			
			
			INNER JOIN %table:CN9% CN9 ON(%exp:cCN9Join% AND CN9.%NotDel%)			
			INNER JOIN %table:CNF% CNF ON(%exp:cCNFJoin% AND CND.CND_NUMERO = CNF.CNF_NUMPLA AND CNF.%NotDel%)			
						
			WHERE	CND.CND_DTFIM <> %exp:Space(8)%	AND
					CND.CND_FILCTR = %exp:_cFilCtr% AND
					CND.CND_CONTRA = %exp:cContra% 	AND
					CND.CND_REVISA = %exp:cRev%  	AND
					CND.CND_COMPET = %exp:cCompet%	AND
					CNF.CNF_NUMPLA = %exp:cPlan% 	AND
					CND.%NotDel%					
			GROUP BY CND.CND_NUMMED
EndSQL

While (cAliasCND)->(!EOF())
	nVlrMed += (cAliasCND)->CND_VLTOT

	cChave := cContra + cRev + cPlan + (cAliasCND)->CND_NUMMED	
	If (nPosDev := aScan(_aValDev, {|x| x[1] == cChave })) > 0
		nVlrMed -= _aValDev[nPosDev,2]
	EndIf
	(cAliasCND)->(dbSkip())
EndDo

(cAliasCND)->(dbCloseArea())

RestArea(aArea)

Return nVlrMed

/*/{Protheus.doc} MontaLog
Retorna a quantidade medida do item da planilha

@param aLog, array, Dados dos contratos processados

@return cLog, character, Log a ser exibido para o usuário
    
@author janaina.jesus
@since 25/07/2018
@version 1.0
/*/
Static Function MontaLog(aLog)
	Local cLog       := ""
	Local nX         := 0 //Contratos
	Local nY         := 0 //Planilhas
	Local nW         := 0 //Itens
	Local nZ         := 0 //Cronograma
	Local nContratos := 0
	Local lIsBlind	 := IsBlind()
	Local cPictVlr   := PesqPict("CNE","CNE_VLTOT")

	Local cHeadCN9	:= STR0007+ CRLF
	Local cHeadCNA	:= STR0008+ CRLF
	Local cHeadCNB	:= STR0009+ CRLF
	Local cHeadCNF	:= STR0010+ CRLF
	Local cHeadCNS	:= STR0011+ CRLF
	Local cTitleCN9	:= PadC(STR0012	, Len(cHeadCN9), '_' ) + CRLF
	Local cTitleCNA	:= PadC(STR0013	, Len(cHeadCNA), '_' ) + CRLF
	Local cTitleCNB	:= PadC(STR0014	, Len(cHeadCNB), '_' ) + CRLF
	Local cTitleCNF	:= PadC(STR0015	, Len(cHeadCNF), '_' ) + CRLF
	Local cTitleCNS	:= PadC(STR0016	, Len(cHeadCNS), '_' ) + CRLF
	Local cQuebra	:= CRLF + Replicate('=',110) + CRLF

	Local aContrato := {}
	Local aPlanilhas:= {}
	Local aUmaPlan	:= {}
	Local aItensPlan:= {}
	Local aCronoFin := {}
	Local aCrgFisico:= {} 

	Default aLog:= {}

	nContratos:= Len(aLog)

	For nX:= 1 To nContratos
		aContrato := aLog[nX]
		
		If aContrato[7] .Or. lIsBlind		
			cLog += cTitleCN9
			cLog += cHeadCN9
			cLog += aContrato[1]					+ " | " +;
					aContrato[2] 					+ " | " +;
					aContrato[3] 					+ " | " +;
					Transform(aContrato[4],cPictVlr)+ " | " +;
					Transform(aContrato[5],cPictVlr)+ CRLF

			aPlanilhas := aContrato[6]
			
			For nY:= 1 To Len(aPlanilhas)

				aUmaPlan := aPlanilhas[nY]

				cLog += cTitleCNA
				cLog += cHeadCNA
				
				cLog += aUmaPlan[1] 						+ " | " +;
						aUmaPlan[2] 						+ " | " +;
						aUmaPlan[3] 						+ " | " +;
						aUmaPlan[4] 						+ " | " +;
						Transform(aUmaPlan[5],cPictVlr) 	+ " | " +;
						Transform(aUmaPlan[6],cPictVlr) 	+ CRLF
				
				cLog += cTitleCNB
				cLog += cHeadCNB
				aItensPlan := aUmaPlan[7]
				For nW:= 1 to Len(aItensPlan)
					cLog += "  " + aItensPlan[nW][1] 				+ " | " +;
							aItensPlan[nW][2] 						+ " | " +;
							aItensPlan[nW][3] 						+ " | " +;
							Transform(aItensPlan[nW][4],cPictVlr) 	+ " | " +;
							Transform(aItensPlan[nW][5],cPictVlr) 	+ " | " +;
							Transform(aItensPlan[nW][6],cPictVlr) 	+ " | " +;
							Transform(aItensPlan[nW][7],cPictVlr) 	+ CRLF  
				Next nW				
				
				cLog += cTitleCNF
				cLog += cHeadCNF
				aCronoFin := aUmaPlan[8]
				For nZ:= 1 to Len(aCronoFin)
					cLog += "  " + aCronoFin[nZ][1] + " | " + ;
						Transform(aCronoFin[nZ][2],cPictVlr) + " | " +;
						Transform(aCronoFin[nZ][3],cPictVlr) + " | " +;
						Transform(aCronoFin[nZ][4],cPictVlr) + " | " +;
						Transform(aCronoFin[nZ][5],cPictVlr) +CRLF  
				Next nZ

				cLog += cTitleCNS
				cLog += cHeadCNS
				aCrgFisico := aUmaPlan[9]
				For nZ:= 1 to Len(aCrgFisico)
					cLog += "  " + aCrgFisico[nZ][1] + " | " + ;
						Transform(aCrgFisico[nZ][2],cPictVlr) + " | " + ;
						Transform(aCrgFisico[nZ][3],cPictVlr) + " | " + ;
						Transform(aCrgFisico[nZ][4],cPictVlr) + " | " +CRLF  
				Next nZ
				
			Next nY
					
			cLog += cQuebra		
		EndIf	
	Next nX
Return cLog

/*/{Protheus.doc} AjsCNFxCNS
Ajusta previsto do cronograma financeiro 
@author vitor.pires
@since 01/09/2022
@param cContra, character, Numero do Contrato
@param cRevisa, character, Revisao do contrato
@param aLog, array, Array do Log
@return lAjustou, logical, Indica se ajustou ou não
/*/
Static Function AjsCNFxCNS(cContra, cRevisa, cPlan, aLog)
	Local lAjustou := .F.
	Local cAlCNS := GetNextAlias()

	BeginSQL Alias cAlCNS
		SELECT
		CNF.CNF_PARCEL,
		CNF.CNF_VLPREV,
		CNF.R_E_C_N_O_ REGCNF,
		SUM(CNS_PRVQTD * CNB.CNB_VLUNIT) CNFCALC,
		SUM(CNS_PRVQTD * CNB.CNB_VLUNIT) - CNF_VLPREV DIVERGENCIA
		FROM
		%table:CNS% CNS
		INNER JOIN %table:CNF% CNF ON(
				CNF_FILIAL = CNS_FILIAL
			AND CNF_CONTRA = CNS_CONTRA
			AND CNF_REVISA = CNS_REVISA
			AND CNF_NUMPLA = CNS_PLANI
			AND CNF_PARCEL = CNS_PARCEL
			AND CNF.%NotDel%)		
		INNER JOIN %table:CNB% CNB ON(
				CNB.CNB_FILIAL 	= CNS.CNS_FILIAL
			AND CNB.CNB_CONTRA 	= CNS.CNS_CONTRA
			AND CNB.CNB_REVISA 	= CNS.CNS_REVISA
			AND CNB.CNB_NUMERO 	= CNS.CNS_PLANI
			AND CNB.CNB_ITEM 	= CNS.CNS_ITEM
			AND CNB.%NotDel%)
		WHERE
				CNS_FILIAL 	= %xFilial:CNS%
		AND CNS.CNS_CONTRA 	= %exp:cContra% 
		AND	CNS.CNS_REVISA 	= %exp:cRevisa%
		AND CNS.CNS_PLANI 	= %exp:cPlan%
		AND CNS.%NotDel%
		GROUP BY CNF_PARCEL, CNF_VLPREV, CNF.R_E_C_N_O_
		HAVING ABS(SUM(CNS_PRVQTD * CNB.CNB_VLUNIT) - CNF_VLPREV) > 0.01
		ORDER BY CNF_PARCEL
	EndSQL

	While (cAlCNS)->(!EOF())		
		lAjustou := .T.
		aadd(aLog[9], {(cAlCNS)->CNF_PARCEL,(cAlCNS)->CNF_VLPREV,(cAlCNS)->CNFCALC,(cAlCNS)->(CNFCALC-CNF_VLPREV)})
		CNF->(dbGoTo((cAlCNS)->REGCNF))
		RecLock( "CNF", .F. )
		CNF->CNF_VLPREV := (cAlCNS)->CNFCALC
		CNF->( MsUnlock() )
		(cAlCNS)->(dbSkip())
	EndDo

	(cAlCNS)->(dbCloseArea())
Return lAjustou
