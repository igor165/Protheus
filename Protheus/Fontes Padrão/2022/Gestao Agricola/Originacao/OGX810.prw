#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGX810.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

/** {Protheus.doc} OGX810VCtr
Vínculo automático dos DCOs do PEPRO nas regras fiscais da IE de acordo com seleciona no contrato

@param: 	oModel, Modelo de Dados do OGA710
@author: 	Francisco Kennedy Nunes Pinheiro
@since:     09/03/2019
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGX810VCtr(oModel)
	Local oModelN7S	:= oModel:GetModel("N7SUNICO")
	Local oModelN7Q	:= oModel:GetModel("N7QUNICO")
	Local oModelNLN := oModel:GetModel("NLNUNICO")
	Local nX        := 0
	Local cQuery    := ""
	Local cAliasDCO := ""
	Local nQtdVin   := 0
	Local nQtdJVin  := 0
	Local cFilCtr   := ""
	Local cCodCtr   := ""
	Local cItPrev   := ""
	Local cRegFis   := ""	
	Local cCodIE    := ""   
	Local nPeso     := 0
	Local cSequen   := ""	
	Local aDCOSld   := {}
	Local nQtdJDCO  := 0
		
	For nX := 1 To oModelN7S:Length()
		oModelN7S:GoLine(nX)
				   
	    cFilCtr  := oModelN7S:GetValue("N7S_FILIAL")
	    cCodCtr  := oModelN7S:GetValue("N7S_CODCTR")
	    cItPrev  := oModelN7S:GetValue("N7S_ITEM")
	    cRegFis  := oModelN7S:GetValue("N7S_SEQPRI")	   
	    nPeso    := oModelN7S:GetValue("N7S_QTDVIN")
	    cCodIE   := oModelN7Q:GetValue("N7Q_CODINE")
	    nQtdVin  := 0
	    nQtdJVin := 0
	    
	    // Verifica se possui DCO vinculado a regra fiscal da IE, caso possua, não atualiza
		If OGX810VERF(cFilCtr, cCodCtr, cItPrev, cRegFis, oModelNLN)
			LOOP
		EndIf
	   
	    cQuery := "SELECT NLN.NLN_NUMAVI, NLN.NLN_NUMDCO, NLN.NLN_SEQDCO, NLN.NLN_PRECO, NLN.NLN_QTDVIN, N9W.N9W_QTDSDO "
	    cQuery += "  FROM " + RetSQLName("NLN") + " NLN "
	    cQuery += " INNER JOIN " + RetSQLName("N9W") + " N9W ON N9W.N9W_FILIAL = '" + FWxFilial("N9W") + "' "
	    cQuery += "   AND N9W.N9W_NUMAVI = NLN.NLN_NUMAVI AND N9W.N9W_NUMDCO = NLN.NLN_NUMDCO AND N9W.N9W_SEQEST = NLN.NLN_SEQDCO "
	    cQuery += "   AND N9W.D_E_L_E_T_ = ' ' "
	    cQuery += " WHERE NLN.NLN_FILIAL = '" + cFilCtr + "'"
	    cQuery += "   AND NLN.NLN_CODCTR = '" + cCodCtr + "'"
	    cQuery += "   AND NLN.NLN_ITEMPE = '" + cItPrev + "'"
	    cQuery += "   AND NLN.NLN_ITEMRF = '" + cRegFis + "'"
	    cQuery += "   AND NLN.NLN_CODINE = ' ' "
	    cQuery += "   AND NLN.D_E_L_E_T_ = ' ' "
	    cQuery += " ORDER BY NLN.NLN_NUMAVI, NLN.NLN_NUMDCO, NLN.NLN_SEQDCO, NLN.NLN_PRECO "
	    
	    cQuery := ChangeQuery(cQuery)
   
		cAliasDCO := GetNextAlias()			
		DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDCO, .F., .T.)
	   
		DbselectArea(cAliasDCO)
		(cAliasDCO)->(DbGoTop())
	   
		If !(cAliasDCO)->(Eof())
	   		
			While !(cAliasDCO)->(Eof())
			
				If nQtdJVin == nPeso
					EXIT
				EndIf
				
				nQtdJDCO := 0
				
				// Busca a quantidade já vinculada do DCO
				nPos := AScan(aDCOSld, {|x| AllTrim(x[1]) == AllTrim((cAliasDCO)->NLN_NUMAVI+(cAliasDCO)->NLN_NUMDCO+(cAliasDCO)->NLN_SEQDCO)})
				If nPos > 0
					nQtdJDCO := aDCOSld[nPos][2]
				EndIf
				
				// Caso já tenha vinculado totalmente na Ie, não considera o DCO
				If (cAliasDCO)->N9W_QTDSDO - nQtdJDCO == 0
					(cAliasDCO)->(DbSkip())
					LOOP
				EndIf
			
				If (cAliasDCO)->NLN_QTDVIN > ((cAliasDCO)->N9W_QTDSDO - nQtdJDCO)
					nQtdVin := (cAliasDCO)->N9W_QTDSDO - nQtdJDCO
				Else
					nQtdVin := (cAliasDCO)->NLN_QTDVIN
				EndIf
				
				If nQtdVin > (nPeso - nQtdJVin)
					nQtdVin := nPeso - nQtdJVin
				EndIf
				
				OGX810INLN(cFilCtr, cCodCtr, cItPrev, cRegFis, @cSequen, (cAliasDCO)->NLN_PRECO, (cAliasDCO)->NLN_NUMAVI, (cAliasDCO)->NLN_NUMDCO, (cAliasDCO)->NLN_SEQDCO, nQtdVin, cCodIE, @oModelNLN)
								
				nQtdJVin := nQtdJVin + nQtdVin
				
				// Atribui a quantidade vinculada daquela comprovação de DCO
				nPos := AScan(aDCOSld, {|x| AllTrim(x[1]) == AllTrim((cAliasDCO)->NLN_NUMAVI+(cAliasDCO)->NLN_NUMDCO+(cAliasDCO)->NLN_SEQDCO)})
				If nPos > 0
					aDCOSld[nPos][2] += nQtdVin
				Else
					Aadd(aDCOSld, {(cAliasDCO)->NLN_NUMAVI+(cAliasDCO)->NLN_NUMDCO+(cAliasDCO)->NLN_SEQDCO, nQtdVin})
				EndIf
				
				(cAliasDCO)->(DbSkip())
			Enddo			
		EndIf
		
		(cAliasDCO)->(DbCloseArea())
			    		
	Next nX	
	
Return .T.

/** {Protheus.doc} OGX810VCIE
Vínculo automático dos DCOs do PEPRO nas regras fiscais da IE

@param: 	oModel, Modelo de Dados do OGA710
@author: 	Francisco Kennedy Nunes Pinheiro
@since:     10/02/2019
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGX810VCIE(oModel)
	Local oModelN7S	:= oModel:GetModel("N7SUNICO")
	Local oModelN7Q	:= oModel:GetModel("N7QUNICO")
	Local oModelNLN := oModel:GetModel("NLNUNICO")
	Local nX        := 0
	Local cTMercIE  := ""
	Local cTCtrIE   := ""
	Local cCodPro   := ""
	Local cFilCtr   := ""
	Local cCodCtr   := ""
	Local cItPrev   := ""
	Local cRegFis   := ""
	Local cFilOrg   := ""
	Local nPeso     := 0
	Local cCodIE    := ""
		
	cTMercIE := oModelN7Q:GetValue("N7Q_TPMERC")
	cTCtrIE  := oModelN7Q:GetValue("N7Q_TPCTR")
    cCodEnt  := oModelN7Q:GetValue("N7Q_ENTENT")
    cLojEnt  := oModelN7Q:GetValue("N7Q_LOJENT")
    cCodPro  := oModelN7Q:GetValue("N7Q_CODPRO")   
    cCodIE   := oModelN7Q:GetValue("N7Q_CODINE") 
	
	// Não vincula os DCOs na IE quando o mercado for exporação e não possuir os campos de Entidade e Loja de entrega informados
	If Empty(cCodEnt) .AND. Empty(cLojEnt) .AND. cTMercIE == "2"
		Return .T.
	EndIf
	
	For nX := 1 To oModelN7S:Length()
		oModelN7S:GoLine(nX)
				   
	   cFilCtr  := oModelN7S:GetValue("N7S_FILIAL")
	   cCodCtr  := oModelN7S:GetValue("N7S_CODCTR")
	   
	   DbSelectArea("NJR")
	   NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
	   If NJR->(DbSeek(cFilCtr+cCodCtr))
	   	  If NJR->NJR_TIPFIX == "2"
			 LOOP
		  EndIf
	   EndIf		
	   NJR->(DbCloseArea())	   
	   
	   cItPrev  := oModelN7S:GetValue("N7S_ITEM")
	   cRegFis  := oModelN7S:GetValue("N7S_SEQPRI")
	   cFilOrg  := oModelN7S:GetValue("N7S_FILORG")	   
	   nPeso    := oModelN7S:GetValue("N7S_QTDVIN")
	   
	   // Verifica se possui DCO vinculado a regra fiscal da IE, caso possua, não atualiza
	   If !OGX810VERF(cFilCtr, cCodCtr, cItPrev, cRegFis, oModelNLN)
	   		// Criar o vinculo da regra fiscal X preço X DCO
	   		OGX810VINC(cTCtrIE, cTMercIE, cFilCtr, cCodCtr, cItPrev, cRegFis, nPeso, cCodPro, cFilOrg, cCodIE, cCodEnt, cLojEnt, oModelNLN)	
	   EndIf	
		
	Next nX	
	
Return .T.

/** {Protheus.doc} OGX810RMIE
Remove o vínculo automático dos DCOs do PEPRO nas regras fiscais da IE

@param: 	oModel, Modelo de Dados do OGA710
@author: 	Francisco Kennedy Nunes Pinheiro
@since:     06/03/2019
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGX810RMIE(oModel)
	Local oModelN7S	:= oModel:GetModel("N7SUNICO")
	Local nX        := 0
	
	For nX := 1 To oModelN7S:Length()
		oModelN7S:GoLine(nX)
		
		cFilCtr  := oModelN7S:GetValue("N7S_FILIAL")
	    cCodCtr  := oModelN7S:GetValue("N7S_CODCTR")
	    cItPrev  := oModelN7S:GetValue("N7S_ITEM")
	    cRegFis  := oModelN7S:GetValue("N7S_SEQPRI")
		cCodIE   := oModelN7S:GetValue("N7S_CODINE")
		
		// Elimina o vinculo da regra fiscal x preço x DCO
	    OGX810RNLN(cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE)
		
	Next nX	
	
Return .T.

/** {Protheus.doc} OGX810VINC
Vinculo da comprovação do DCO com a IE / Contrato

@param: 	cTCtr,    Tipo de contrato, 1-Venda;2-Armazenagem
@param: 	cTMerc,   Tipo de mercado, 1-Interno; 2-Externo
@param: 	cFilCtr,  Filial do contrato
@param: 	cCodCtr,  Código do contrato
@param: 	cItPrev,  Item da previsão de entrega do contrato
@param: 	cRegFis,  Item da regra fiscal do contrato
@param:     nPeso,    Peso
@param:     cCodPro,  Código do produto
@param:     cFilOrg,  Filial de origem
@param:     cCodIE,   Código da Instrução de Embarque
@param:     cCodEnt,  Código da entidade de entrega
@param:     cLojEnt,  Loja da entidade de entrega
@author: 	Francisco Kennedy Nunes Pinheiro
@since:     25/02/2019
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGX810VINC(cTCtr, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, nPeso, cCodPro, cFilOrg, cCodIE, cCodEnt, cLojEnt, oModelNLN)
	
	Local aPrecos    := {}
	Local cSequen    := ""
	Local cUfOrig    := Posicione("SM0",1,cEmpAnt+cFilOrg,"M0_ESTENT")
	Local cTipAvis   := ""
	Local aPrPEPRO   := {}
	Local nPrMiDco   := 0
	Local nVlrPre    := 0
	Local nQtdVin    := 0
	Local nVlrUni    := 0
	Local nQtdJaVinc := 0
	Local aDCOPrc    := {}
	Local aDCOSld    := {}
	Local nSldPrc    := 0
	Local nX         := 0
	Local cQry       := ""
	Local cAliasDCO  := ""
	Local cEstDest   := ""
	Local cCidDest   := ""
	Local cFinalid   := ""
	
	Default cCodIE   := ""
	Default cCodEnt  := ""
	Default cLojEnt  := ""
	
	// Busca a cidade e UF de destino
	aRet := OGX810BUF(cTMerc, cCodEnt, cLojEnt, cFilCtr, cCodCtr, cItPrev, cRegFis)
	
	cEstDest := aRet[1]
	cCidDest := aRet[2]
	
	cFinalid := Posicione("N9A",1,cFilCtr+cCodCtr+cItPrev+cRegFis, "N9A_CODFIN")
	
	// Busca a lista de preços disponíveis
	If cTCtr == "1" // Venda
		
		cSequen := ""
		
		aPrecos := OGX810GetPr(cTCtr, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, cCodEnt, cLojEnt, nPeso)
	Else // Armazenagem
		cItPrev := ""
		cRegFis := ""
		cSequen := ""
				
		aPrecos := OGX810GetPr(cTCtr, , cFilCtr, cCodCtr, , , , , , nPeso, cUfOrig, cEstDest)
	EndIf
	
	// Monta a query para buscar as comprovações de DCO disponíves
	cQry := OGX810QRY(1, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodPro, cFilOrg, "", "", "", cCodEnt, cLojEnt, cEstDest, cFinalid)
   
	cQry := ChangeQuery(cQry)
   
	cAliasDCO := GetNextAlias()			
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry),cAliasDCO, .F., .T.)
   
	DbselectArea(cAliasDCO)
	(cAliasDCO)->(DbGoTop())
   
	If !(cAliasDCO)->(Eof())
   		
		While !(cAliasDCO)->(Eof())
			
			If Empty((cAliasDCO)->N9W_EST)
   				
   				// Valida se a UF da IE está dentro das regras do Aviso do PEPRO
   				If !OGX810VUF((cAliasDCO)->N9W_NUMAVI, cEstDest, cCidDest, "2")
   					(cAliasDCO)->(DbSkip())
   					LOOP
   				EndIf		   				
   			EndIf	
   			
   			If Empty((cAliasDCO)->N9W_CODFIN)
   				
   				// Valida se a finalidade da IE está dentro das regras do Aviso do PEPRO
   				If !OGX810VFN((cAliasDCO)->N9W_NUMAVI, cFinalid)
   					(cAliasDCO)->(DbSkip())
   					LOOP
   				EndIf   				
   			EndIf
   			
   			cTipAvis := ""
   			
   			// Busca o preco minimo e preco do premio
   			aPrPEPRO := OGX810GtPr((cAliasDCO)->N9W_NUMAVI, cTipAvis, cUfOrig, cEstDest, (cAliasDCO)->N9U_CODREG)
   			
   			nPrMiDco := aPrPEPRO[1]
   			nVlrPre  := aPrPEPRO[2]
   					   				
			For nX := 1 to Len(aPrecos)
			
				nQtdVin := aPrecos[nX][3]
				nVlrUni := aPrecos[nX][2]
				
				// Busca a quantidade já vinculada ao preço para aquele contrato+cadência+regra fiscal
				nPos := AScan(aDCOPrc, {|x| AllTrim(x[1])+cValToChar(x[2]) == AllTrim(cFilCtr+cCodCtr+cItPrev+cRegFis)+cValToChar(nX)})
				If nPos > 0
					// Caso encontre, subtrai a quantidade para deixar apenas o saldo a vincular do preço 
					nQtdVin := nQtdVin - aDCOPrc[nPos][4]
					
					// Caso o preço foi vinculado totalmente, move para outro preço
					If nQtdVin == 0
						LOOP
					EndIf
				EndIf	   					
				
				// Validar preço mínimo
			 	If nPrMiDco > nVlrUni + nVlrPre .OR. nPrMiDco = nVlrUni + nVlrPre
			 		LOOP
				EndIf
					
				nQtdJaVinc := 0
				
				// Busca a quantidade já vinculada do DCO
				nPos := AScan(aDCOSld, {|x| AllTrim(x[1]) == AllTrim((cAliasDCO)->N9W_NUMAVI+(cAliasDCO)->N9W_NUMDCO+(cAliasDCO)->N9W_SEQEST)})
				If nPos > 0
					nQtdJaVinc := aDCOSld[nPos][2]
				EndIf
				
				// Se a comprovação do DCO já foi totalmente consumida, sai do for para buscar outro DCO
				If (cAliasDCO)->N9W_QTDSDO - nQtdJaVinc == 0
					EXIT
				EndIf
				
				nSldPrc := 0
										
				If nQtdVin > (cAliasDCO)->N9W_QTDSDO - nQtdJaVinc
					// Quantidade do preço for maior que o saldo da comprovação do DCO - o que já está sendo vinculado, 
					// será utilizado mais de um DCO por preço
					nSldPrc := nQtdVin - ((cAliasDCO)->N9W_QTDSDO - nQtdJaVinc)
					nQtdVin := (cAliasDCO)->N9W_QTDSDO - nQtdJaVinc
				EndIf
				
				If nQtdVin > 0
					// Inclusão da relação regra fiscal x preço x DCO												
					OGX810INLN(cFilCtr, cCodCtr, cItPrev, cRegFis, @cSequen, nVlrUni, (cAliasDCO)->N9W_NUMAVI, (cAliasDCO)->N9W_NUMDCO, (cAliasDCO)->N9W_SEQEST, nQtdVin, cCodIE, @oModelNLN)
										
					// Atribui a quantidade vinculada daquela comprovação de DCO
					nPos := AScan(aDCOSld, {|x| AllTrim(x[1]) == AllTrim((cAliasDCO)->N9W_NUMAVI+(cAliasDCO)->N9W_NUMDCO+(cAliasDCO)->N9W_SEQEST)})
					If nPos > 0
						aDCOSld[nPos][2] += nQtdVin
					Else
						Aadd(aDCOSld, {(cAliasDCO)->N9W_NUMAVI+(cAliasDCO)->N9W_NUMDCO+(cAliasDCO)->N9W_SEQEST, nQtdVin})
					EndIf
					
					// Atribui a quantidade vinculada do preço
					nPos := AScan(aDCOPrc, {|x| AllTrim(x[1])+cValToChar(x[2]) == AllTrim(cFilCtr+cCodCtr+cItPrev+cRegFis)+cValToChar(nX)})
					If nPos > 0
						aDCOPrc[nPos][4] += nQtdVin
					Else
						Aadd(aDCOPrc, {cFilCtr+cCodCtr+cItPrev+cRegFis, nX, nVlrUni, nQtdVin})
					EndIf
				EndIf
				
				// Verifica se possui saldo para buscar outra comprovação do DCO para o mesmo preço												
				If nSldPrc > 0
					EXIT	
				EndIf
															   					
			Next nX
					   			
   			(cAliasDCO)->(DbSkip())		   			
   		EndDo		
   		
   	EndIf
   
   	(cAliasDCO)->(DbCloseArea())	

Return .T.

/*{Protheus.doc} OGX810GetPr
Busca o array de preço disponíveis

@author francisco.nunes
@since 25/02/2019
@version 1.0
@param: cTCtr,   Tipo de contrato; 1-Venda; 2-Armazenagem
@param: cTMerc,  Tipo de mercado; 1-Interno; 2-Externo
@param: cFilCtr, Filial do contrato
@param: cCodCtr, Código do contrato
@param: cItPrev, Item da entrega do contrato
@param: cRegFis, Regra fiscal do contrato
@param: cCodIE,  Código da Instrução de Embarque
@param: cCodEnt, Código da entidade
@param: cLojEnt, Loja da entidade
@param: nPeso,   Peso a ser consumido
@param: cUfOrig, UF de origem
@param: cUfDest, UF de destino
@return True, Logycal, True or False
*/
Function OGX810GetPr(cTCtr, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, cCodEnt, cLojEnt, nPeso, cUfOrig, cUfDest)

	Local cCodClient := ""
	Local cCodLoja   := ""
	Local aRetPrc    := {}
	
	If cTCtr == "1" // Venda
		// Busca o cliente ou fornecedor
		aRetEnt := RetCliForn(cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodEnt, cLojEnt)				   
		
		cCodClient := aRetEnt[1]
		cCodLoja   := aRetEnt[2]
		
		// Busca os preços disponíveis para quantidade da regra fiscal informada   			
		aRetPrc := OGAX721FAT(cFilCtr, cCodCtr, cItPrev, cRegFis, 0, nPeso, 0, cCodClient, cCodLoja, "F")
	Else
		
		// Busca os preços disponíveis para quantidade da regra fiscal informada
		aRetPrc := OGAX721REM(cFilCtr, cCodCtr, "", cUfOrig, cUfDest, nPeso)		
	EndIf
	
	aPrecos := aRetPrc[1][4]

Return aPrecos

/*{Protheus.doc} OGX810RNLN
Remove a tabela NLN - Relação Regra Fiscal X Preço X DCO

@author francisco.nunes
@since 25/02/2019
@version 1.0
@return True, Logycal, True or False
*/
Function OGX810RNLN(cFilCtr, cCodCtr, cItPrev, cRegFis, oModelNLN)
	
	Local nX := 0
	
	oModelNLN:SetNoDeleteLine(.F.)
	
	For nX := 1 To oModelNLN:Length()
		oModelNLN:GoLine(nX)
		
		If oModelNLN:GetValue("NLN_FILIAL") == cFilCtr .AND. oModelNLN:GetValue("NLN_CODCTR") == cCodCtr .AND.;
		   oModelNLN:GetValue("NLN_ITEMPE") == cItPrev .AND. oModelNLN:GetValue("NLN_ITEMRF") == cRegFis .AND.;
		   !oModelNLN:IsDeleted()
		   
		   oModelNLN:DeleteLine()						
		EndIf
				
	Next nX
	
	oModelNLN:SetNoDeleteLine(.T.)
	
Return .T.

/*{Protheus.doc} OGX810INLN
Inclui a tabela NLN - Relação Regra Fiscal X Preço X DCO

@author francisco.nunes
@since 25/02/2019
@version 1.0
@return True, Logycal, True or False
*/
Function OGX810INLN(cFilCtr, cCodCtr, cItPrev, cRegFis, cSequen, nVlrUni, cNumAvi, cNumDCO, cSeqDCO, nQtdVin, cCodIE, oModelNLN, nQtdFat)

	Local nX := 0
	
	Default nQtdFat := 0

	If Empty(cSequen)
		cSequen := GetDataSql ("SELECT MAX(NLN.NLN_SEQUEN) AS SEQUEN " +;
							  	" FROM " + RetSqlName("NLN") + " NLN " +;
							   " WHERE NLN.NLN_FILIAL = '" + cFilCtr + "' " +;
							    "  AND NLN.NLN_CODCTR = '" + cCodCtr + "' " +;
							    "  AND NLN.NLN_ITEMPE = '" + cItPrev + "' " +;
							    "  AND NLN.NLN_ITEMRF = '" + cRegFis + "' " +;
							    "  AND NLN.NLN_CODINE <> '" + cCodIE + "' "+;
							    "  AND NLN.D_E_L_E_T_ = ' ' ")
		
		// Busca a maior sequencial
		For nX := 1 To oModelNLN:Length()
			oModelNLN:GoLine(nX)
			
			If oModelNLN:GetValue("NLN_FILIAL") == cFilCtr .AND. oModelNLN:GetValue("NLN_CODCTR") == cCodCtr .AND.;
			   oModelNLN:GetValue("NLN_ITEMPE") == cItPrev .AND. oModelNLN:GetValue("NLN_ITEMRF") == cRegFis .AND.;
			   !oModelNLN:IsDeleted()
			   
			   If Empty(cSequen) .OR. Val(oModelNLN:GetValue("NLN_SEQUEN")) > Val(cSequen)
			   		cSequen := oModelNLN:GetValue("NLN_SEQUEN")
			   EndIf
								
			EndIf
			
		Next nX
	   
		If Empty(cSequen)
			cSequen := StrZero(1, TamSX3("NLN_SEQUEN")[1])
		Else
			cSequen := Soma1(cSequen)
		EndIf
	EndIf
	
	// Inclui a tabela de relação da Regra Fiscal X Preço X DCO
	oModelNLN:SetNoInsertLine(.F.)
	oModelNLN:SetNoUpdateLine(.F.)
	
	oModelNLN:GoLine(oModelNLN:Length())
	
	If !Empty(oModelNLN:GetValue("NLN_CODCTR")) .OR. oModelNLN:IsDeleted()
		oModelNLN:AddLine()
	EndIf	
	
	oModelNLN:SetValue("NLN_FILIAL", cFilCtr)
	oModelNLN:SetValue("NLN_CODCTR", cCodCtr)
	oModelNLN:SetValue("NLN_ITEMPE", cItPrev)
	oModelNLN:SetValue("NLN_ITEMRF", cRegFis)
	oModelNLN:SetValue("NLN_SEQUEN", cSequen)
	oModelNLN:SetValue("NLN_PRECO",  nVlrUni)
	oModelNLN:SetValue("NLN_NUMAVI", cNumAvi)
	oModelNLN:SetValue("NLN_NUMDCO", cNumDCO)
	oModelNLN:SetValue("NLN_SEQDCO", cSeqDCO)
	oModelNLN:SetValue("NLN_QTDVIN", nQtdVin)		
	oModelNLN:SetValue("NLN_QTDFAT", nQtdFat)
	
	If !Empty(cCodIE)
		oModelNLN:SetValue("NLN_CODINE", cCodIE)
	EndIf
		
	oModelNLN:SetNoInsertLine(.T.)
	oModelNLN:SetNoUpdateLine(.T.)
	
	cSequen := Soma1(cSequen)

Return .T.

/*{Protheus.doc} OGX810QRY
Monta query para buscar/validar DCOs do PEPRO para IE

@author francisco.nunes
@since 10/02/2019
@version 1.0
@param: nIndQry, number, 1 - Buscar DCO; 2 - Validar DCO
@param: cTMerc,  character, 1 - Mercado Interno; 2 - Mercado Externo
@param: cFilCtr, character, Filial do contrato
@param: cCodCtr, character, Código do contrato
@param: cItPrev, character, Código do item da previsão de entrega
@param: cRegFis, character, Código da regra fiscal
@param: cCodPro, character, Código do Produto
@param: cFilOrg, character, Filial de Origem
@param: cNumAvi, character, Número do aviso do PEPRO
@param: cDco, character, DCO do PEPRO
@param: cSeqDCO, character, Código da Comprovação do DCO
@param: cCoEnt, character, Código da entidade de entrega (exportação)
@param: cLojEnt, character, Loja da entidade de entrega (exportação)
@param: cEstDest, character, UF de destino
@return cQry, character, Query para buscar/validar DCO
*/
Function OGX810QRY(nIndQry, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodPro, cFilOrg, cNumAvi, cDco, cSeqDCO, cCoEnt, cLojEnt, cEstDest, cFinali)

	Local cQry    := ""
	
	If nIndQry == 1
		cQry := " SELECT DISTINCT N9W_NUMAVI, N9W_NUMDCO, N9W_SEQEST, N9W_EST, N9W_CODFIN, N9U_CODREG, N9W_QTDSDO, N9W_QUANT " 
	Else
		cQry := " SELECT N9W_NUMAVI, N9W_NUMDCO, N9W_SEQEST, N9U_FILORI, N9U_CODREG "
	EndIf	
	
	cQry += "       FROM " + RetSqlName('N9W') + " N9W "
	cQry += " INNER JOIN " + RetSqlName('N9N') + " N9N ON N9N.D_E_L_E_T_ = '' " 
	cQry += "        AND N9N_FILIAL = N9W_FILIAL " 
	cQry += "        AND N9N_NUMERO = N9W_NUMAVI " 
	cQry += "        AND N9N_CODPRO = '"+ cCodPro +"' "
	cQry += " INNER JOIN " + RetSqlName('N9U') + " N9U ON N9U.D_E_L_E_T_ = '' " 
	cQry += "        AND N9U_FILIAL = N9W_FILIAL " 
	cQry += "        AND N9U_NUMAVI = N9W_NUMAVI " 
	cQry += "        AND N9U_NUMDCO = N9W_NUMDCO "
	cQry += "        AND N9U_FILORI = '"+ cFilOrg +"'  "
	cQry += "      WHERE N9W.D_E_L_E_T_ = '' 
	cQry += "        AND N9W_FILIAL = '" + FWxFilial('N9W') + "' "
	
	If nIndQry == 2		
		cQry += "    AND N9W_NUMAVI = '"+ cNumAvi +"' "
		cQry += "    AND N9W_NUMDCO = '"+ cDco +"' " 
		cQry += "    AND N9W_SEQEST = '"+ cSeqDCO +"' "		
	EndIf
	
	cQry += "        AND N9W_STATUS IN ('1','2') "
	cQry += "        AND N9W_EST IN ('"+ cEstDest +"', '') "
	cQry += "        AND N9W_CODFIN IN ('','"+ cFinali +"') "
	cQry += " ORDER BY N9W_NUMAVI, N9W_NUMDCO, N9W_SEQEST "	
	
Return cQry

/*{Protheus.doc} OGX810BUF
Retorna a UF e Cidade da IE

@author francisco.nunes
@since 15/02/2019
@version 1.0
@return ${return}, ${return_description}
@param: cTMerc,  character, 1 - Mercado Interno; 2 - Mercado Externo
@param: cCoEnt,  character, Código da entidade de entrega (exportação)
@param: cLojEnt, character, Loja da entidade de entrega (exportação)
@param: cFilCtr, character, Filial do contrato
@param: cCodCtr, character, Código do contrato
@param: cItPrev, character, Código do item da previsão de entrega
@param: cRegFis, character, Código da regra fiscal
@type function
*/
Function OGX810BUF(cTMerc, cCoEnt, cLojEnt, cFilCtr, cCodCtr, cItPrev, cRegFis)
	
	Local cCodCliFor := ""
	Local cLojCliFor := ""
	Local cTipCliFor := ""
	Local cEst       := ""
	Local cCid       := ""	
	Local aRet       := {}

	aRet := RetCliForn(cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCoEnt, cLojEnt)
	
	cCodCliFor := aRet[1]
	cLojCliFor := aRet[2]
	cTipCliFor := aRet[3]
	
	If cTipCliFor == "1" // Cliente
		cEst	:= Posicione("SA1",1,FWxFilial("SA1")+cCodCliFor+cLojCliFor,"A1_EST")
		cCid	:= Posicione("SA1",1,FWxFilial("SA1")+cCodCliFor+cLojCliFor,"A1_COD_MUN")
	Else		
		cEst	:= Posicione("SA2",1,FWxFilial("SA2")+cCodCliFor+cLojCliFor,"A2_EST")
		cCid	:= Posicione("SA2",1,FWxFilial("SA2")+cCodCliFor+cLojCliFor,"A2_COD_MUN")
	EndIf	

Return {cEst, cCid}

/*{Protheus.doc} RetCliForn
Retorna código e loja do cliente / fornecedor

@author francisco.nunes
@since 15/02/2019
@version 1.0
@return ${return}, ${return_description}
@param: cTMerc, character, 1 - Mercado Interno; 2 - Mercado Externo
@param: cFilCtr, character, Filial do contrato
@param: cCodCtr, character, Código do contrato
@param: cItPrev, character, Código do item da previsão de entrega
@param: cRegFis, character, Código da regra fiscal
@param: cCoEnt,  character, Código da entidade de entrega (exportação)
@param: cLojEnt, character, Loja da entidade de entrega (exportação)
@type function
*/
Static Function RetCliForn(cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCoEnt, cLojEnt)
	
	Local cCodCliFor := ""
	Local cLojCliFor := ""
	Local cTipo      := ""
	
	Default cCoEnt   := ""
	Default cLojEnt  := ""

	If cTMerc = "1" .OR. Empty(cCoEnt) // Mercado Interno

		cCoEnt  := Posicione("N9A",1,cFilCtr+cCodCtr+cItPrev+cRegFis, "N9A_ENTENT")
		cLojEnt := Posicione("N9A",1,cFilCtr+cCodCtr+cItPrev+cRegFis, "N9A_LJEENT")
	
		//Se a Entidade de entrega não estiver informada na regra fiscal do contrato
		If Empty(cCoEnt)
			cCoEnt  := Posicione("N9A",1,cFilCtr+cCodCtr+cItPrev+cRegFis, "N9A_CODENT")
			cLojEnt := Posicione("N9A",1,cFilCtr+cCodCtr+cItPrev+cRegFis, "N9A_LOJENT")
		EndIf
			
	EndIf
	
	cCodCliFor := Posicione("NJ0",1,FWxFilial("NJ0")+cCoEnt+cLojEnt,"NJ0_CODCLI")	
	cLojCliFor := Posicione("NJ0",1,FWxFilial("NJ0")+cCoEnt+cLojEnt,"NJ0_LOJCLI")
	cTipo      := "1" // Cliente
	
	// Caso não ache cliente para entidade, busca fornecedor
	If Empty(cCodCliFor)
		cCodCliFor := Posicione("NJ0",1,FWxFilial("NJ0")+cCoEnt+cLojEnt,"NJ0_CODFOR")	
		cLojCliFor := Posicione("NJ0",1,FWxFilial("NJ0")+cCoEnt+cLojEnt,"NJ0_LOJFOR")
		cTipo      := "2" // Fornecedor
	EndIf

Return {cCodCliFor, cLojCliFor, cTipo}

/*{Protheus.doc} OGX810VFN
Validação da finalidade com as defindas no aviso PEPRO

@author francisco.nunes
@since 09/03/2019
@version 1.0
@param: cAviso, character, Código do Aviso PEPRO
*/
Function OGX810VFN(cAviso, cFinalid)

	Local lRet := .F.
	
	DbSelectArea("N9V")
	N9V->(DbSetOrder(1)) //N9V_FILIAL+N9V_NUMERO
	If N9V->(DbSeek(FWxFilial("N9V")+cAviso))
		While !N9V->(Eof()) .AND. N9V->(N9V_FILIAL+N9V_NUMERO) == FWxFilial("N9V")+cAviso
			
			If cFinalid == N9V->N9V_FINALI
				lRet := .T.
				EXIT
			EndIf
			
			N9V->(DbSkip())
		EndDo
	EndIf

Return lRet

/*{Protheus.doc} OGX810VUF
Validação da UF/Cidade com as restrições ou permissões de origem/destino defindas no aviso PEPRO

@author francisco.nunes
@since 13/02/2019
@version 1.0
@param: cAviso, character, Código do Aviso PEPRO
@param: cEstado, character, Código do Estado
@param: cCidade, character, Código da Cidade
@param: cTpLoc, character, 1-Origem;2-Destino
*/
Function OGX810VUF(cAviso, cEstado, cCidade, cTpLoc)
	
	Local lRet 		:= .T.
	Local lRegraPm	:= .F.
	Local lPermit	:= .F.
	
	DbSelectArea("N9Q")
	N9Q->(DbSetOrder(1)) // N9Q_FILIAL+N9Q_NUMERO+N9Q_TIPLOC+N9Q_SEQUEN
	If N9Q->(DbSeek(FWxFilial("N9Q")+cAviso+cTpLoc))
		
		While N9Q->(!Eof()) .AND. N9Q->(N9Q_FILIAL+N9Q_NUMERO+N9Q_TIPLOC) == FWxFilial("N9Q")+cAviso+cTpLoc
		
			If N9Q->N9Q_TIPREG == '1' // Permite
				lRegraPm := .T.
			EndIf 
		
			If !Empty(N9Q->N9Q_EST) .AND. N9Q->N9Q_EST == cEstado
				
				If N9Q->N9Q_TIPREG == '1' // Permite		
					lPermit := .T.
					lRet    := .T.
				Else // Restringe
					lRet := .F.
					EXIT
				EndIf
				
			ElseIf !Empty(N9Q->N9Q_CODREG)
			
				DbSelectArea("NBR")
				NBR->(DbSetOrder(1)) // NBR_FILIAL+NBR_CODREG+NBR_ESTADO+NBR_CODMUN
				If NBR->(DbSeek(FWxFilial("NBR")+N9Q->N9Q_CODREG+cEstado+cCidade))
					
					If N9Q->N9Q_TIPREG == '1' // Permite		
						lPermit := .T.
						lRet    := .T.
					Else // Restringe
						lRet := .F.
						EXIT
					EndIf
					
				EndIf
			
			EndIf
						
			N9Q->(DbSkip())
		EndDo
		
		// Se possui alguma regra Permite e não encontrou o estado
		If lRegraPm .AND. !lPermit
			lRet := .F.
		EndIf
				
	EndIf
	
Return lRet

/*{Protheus.doc} OGX810GtPr
Busca o preço mínimo e o premio unitário do DCO do PEPRO

@author francisco.nunes
@since 23/02/2019
@param, cAviso, Código do aviso do PEPRO
@param, cTpAvis, Tipo de aviso (utilizado para algodão)
@param, cUfOrig, UF de origem
@param, cUfDest, UF de destino
@param, cCodReg, Código da região
@return, array, [1]=Preço Mínimo, [2]=Premio unitário
@version 1.
*/
Function OGX810GtPr(cAviso, cTpAvis, cUfOrig, cUfDest, cCodReg)

	Local cUMDes   := ""
	Local nPrMiDco := 0
	Local cUMOri   := ""
	Local nVlrPre  := 0

	DbSelectArea("N9N")
	N9N->(DbSetOrder(1)) //N9N_FILIAL+N9N_NUMERO 
	If  N9N->(DbSeek(xFilial("N9N")+cAviso))
	    
	    // nPrMiDco  - encontrar preço minimo do estado/regiao do DCO
		If  NK0->(DbSeek(xFilial("NK0")+N9N->N9N_INDICE))		    		    				
		    cUMDes   := NK0->NK0_UM1PRO						     					     				    			
			nPrMiDco := AgrGetInd(NK0->NK0_INDICE, NK0->NK0_TPCOTA, dDataBase, N9N->N9N_CODPRO, cTpAvis, N9N->N9N_SAFRA, cUfOrig, cUfDest, '', cCodReg)										
		EndIf
		
		If  nPrMiDco = 0
			Return  {0, 0}   
		EndIf
		
		// nVlrPre  - encontrar premio unitario de venda conforme indice par aa moeda do preco minimo
		If  NK0->(DbSeek(xFilial("NK0")+N9N->N9N_INDPRE))		   
		    cUMOri  := NK0->NK0_UM1PRO		
			nVlrPre := AgrGetInd(NK0->NK0_INDICE, NK0->NK0_TPCOTA, dDataBase, N9N->N9N_CODPRO, cTpAvis, N9N->N9N_SAFRA, cUfOrig, cUfDest, '', cCodReg)							
			nVlrPre := OGX700UMVL(nVlrPre, cUMOri, cUMDes, N9N->N9N_CODPRO)	
		EndIf			
		
		If  nVlrPre = 0 	
			Return  {nPrMiDco, 0}	
		EndIf
		
	EndIf

Return {nPrMiDco, nVlrPre}

/*{Protheus.doc} OGX810REG
Buscar regiao com estado e cidade da filial do aviso

@author francisco.nunes
@since  01/03/2019
@param, cAviso,  Código do aviso do PEPRO
@param, cEstado, Estado
@param, cCidade, Cidade
@return, cCodReg, Código da região
@version 1.
*/
Function OGX810REG(cAviso, cEstado, cCidade)

	Local cCodReg := ""	
	
	cAliasReg := GetNextAlias()
	cQuery := "SELECT DISTINCT NBR.NBR_CODREG "
	cQuery += "  FROM " + RetSqlName("NBR") + " NBR "
	cQuery += " INNER JOIN " + RetSqlName("N9Q") + " N9Q ON N9Q.N9Q_CODREG = NBR.NBR_CODREG AND N9Q.D_E_L_E_T_ = '' "
	cQuery += " WHERE N9Q.N9Q_FILIAL = '" + FWxFilial("N9Q") + "' "
	cQuery += "   AND N9Q.N9Q_TIPLOC = '1' "
	cQuery += "   AND N9Q.N9Q_NUMERO = '" + cAviso + "' "
	cQuery += "   AND NBR.D_E_L_E_T_ = '' "
	cQuery += "   AND NBR.NBR_ESTADO  = '" + cEstado + "' "
	cQuery += "   AND (NBR.NBR_CODMUN = '" + cCidade + "' OR NBR.NBR_CODMUN = '') "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasReg,.F.,.T.)

	DbSelectArea(cAliasReg)
	(cAliasReg)->(DbGoTop())
	If (cAliasReg)->(!Eof())	
		cCodReg := (cAliasReg)->NBR_CODREG	
	EndIf		
	(cAliasReg)->(DbcloseArea())

Return cCodReg

Function OGX810PRN9W(cOpcao, oModel)
	
	Local nOper		 := oModel:GetOperation()
	Local oModelN7Q  := oModel:GetModel("N7QUNICO")
	Local cFilIE     := ""
	Local cCodIE     := ""
	Local nX	     := 0
	Local cTMercIE   := ""
	Local cCodEnt    := ""
	Local cLojEnt    := ""
	Local aRet       := {}
	Local cEstado    := ""
	Local cFinalid   := ""
	Local aDcos 	 := {}
	Local oModelNLN  := oModel:GetModel("NLNUNICO")
	Local lNLNModify := .f.

    If TableInDic("NLN")
        lNLNModify := oModelNLN:IsModified()
    EndIf

	If lNLNModify .AND. cOpcao == "1" .AND. nOper != MODEL_OPERATION_DELETE 
		
		aDcos := {}
		
		cFilIE := oModelN7Q:GetValue("N7Q_FILIAL")
		cCodIE := oModelN7Q:GetValue("N7Q_CODINE")
		
		DbSelectArea("NLN")
		NLN->(DbSetOrder(3)) //NLN_FILIAL+NLN_CODINE
		If NLN->(DbSeek(cFilIE+cCodIE))
			While NLN->(!Eof()) .AND. NLN->(NLN_FILIAL+NLN_CODINE) == cFilIE+cCodIE
				
				// Retira a quantidade vinculada do DCO
				AtuN9W("1", NLN->NLN_NUMAVI, NLN->NLN_NUMDCO, NLN->NLN_SEQDCO, NLN->NLN_QTDVIN)
				
				//Atualiza a previsão de recebimento DCO
				If aScan(aDcos, NLN->NLN_NUMAVI+NLN->NLN_NUMDCO) == 0
					Processa({|| OGA810AVLP(NLN->NLN_FILIAL, NLN->NLN_NUMAVI, NLN->NLN_NUMDCO)}, 'Atualizando previsão de recebimento do DCO...') //"Atualizando previsão de recebimento do DCO..."
					aAdd(aDcos, NLN->NLN_NUMAVI+NLN->NLN_NUMDCO)
				EndIf
								
				NLN->(DbSkip())
			EndDo
		EndIf
				
	ElseIf lNLNModify .OR. nOper == MODEL_OPERATION_DELETE
			
		If nOper != MODEL_OPERATION_DELETE		
			cTMercIE := oModelN7Q:GetValue("N7Q_TPMERC")
			cCodEnt  := IIf(cTMercIE == "2", oModelN7Q:GetValue("N7Q_ENTENT"), "")
			cLojEnt  := IIf(cTMercIE == "2", oModelN7Q:GetValue("N7Q_LOJENT"), "")
		EndIf
		
		aDcos := {}
					
		For nX := 1 To oModelNLN:Length()
			oModelNLN:GoLine(nX)
			
			If !oModelNLN:IsDeleted() .AND. !Empty(oModelNLN:GetValue("NLN_NUMAVI"))
				
				If nOper != MODEL_OPERATION_DELETE
					aRet := OGX810BUF(cTMercIE, cCodEnt, cLojEnt, oModelNLN:GetValue("NLN_FILIAL"), oModelNLN:GetValue("NLN_CODCTR"), oModelNLN:GetValue("NLN_ITEMPE"), oModelNLN:GetValue("NLN_ITEMRF"))
			
					cEstado  := aRet[1]					
					cFinalid := Posicione("N9A",1,oModelNLN:GetValue("NLN_FILIAL")+oModelNLN:GetValue("NLN_CODCTR")+oModelNLN:GetValue("NLN_ITEMPE")+oModelNLN:GetValue("NLN_ITEMRF"), "N9A_CODFIN")
				EndIf
											  
			    // Consume a quantidade no DCO
			    AtuN9W(cOpcao, oModelNLN:GetValue("NLN_NUMAVI"), oModelNLN:GetValue("NLN_NUMDCO"), oModelNLN:GetValue("NLN_SEQDCO"), oModelNLN:GetValue("NLN_QTDVIN"), cEstado, cFinalid)
			    
			    //Atualiza a previsão de recebimento DCO
				If aScan(aDcos, oModelNLN:GetValue("NLN_NUMAVI")+oModelNLN:GetValue("NLN_NUMDCO")) == 0
					Processa({|| OGA810AVLP(oModelNLN:GetValue("NLN_FILIAL"), oModelNLN:GetValue("NLN_NUMAVI"), oModelNLN:GetValue("NLN_NUMDCO"))}, 'Atualizando previsão de recebimento do DCO...') //"Atualizando previsão de recebimento do DCO..."
					aAdd(aDcos, oModelNLN:GetValue("NLN_NUMAVI")+oModelNLN:GetValue("NLN_NUMDCO"))
				EndIf
								
			EndIf
			
		Next nX
	
	EndIf

Return .T.

/*/{Protheus.doc} AtuN9W()
Atualiza o saldo disponivel e quantidade vinculada do DCO

@type  Static Function
@author rafael.kleestadt
@since 24/08/2018
@version 1.0
@param cOpcao, caractere, "1"-Devolve saldo do Aviso/DCO, "2"-Consome saldo do Aviso/DCO
@return True, logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuN9W(cOpcao, cNumAvi, cNumDCO, cSeqDCO, nQtdVin, cEstDes, cFinalid)
	
	Default cEstDes  := ""
	Default cFinalid := ""
			
	DbSelectArea("N9W")
	N9W->(DbSetOrder(1)) // N9W_FILIAL+N9W_NUMAVI+N9W_NUMDCO+N9W_SEQEST
	If N9W->(DbSeek(FWxFilial("N9W")+cNumAvi+cNumDCO+cSeqDCO))
		If RecLock("N9W", .F.)
			
			If cOpcao == "1"
				//Devolve saldo do Aviso/DCO antes da gravação
				N9W->N9W_QTDVIN -= nQtdVin
			Else
				//Consome saldo do Aviso/DCO depois da gravação
				N9W->N9W_QTDVIN += nQtdVin
				N9W->N9W_EST	:= IIf(Empty(N9W->N9W_EST), cEstDes, N9W->N9W_EST)
				N9W->N9W_CODFIN	:= IIf(Empty(N9W->N9W_CODFIN), cFinalid, N9W->N9W_CODFIN)
			EndIf
			
			N9W->N9W_QTDSDO := N9W->N9W_QUANT - N9W->N9W_QTDVIN
			N9W->(MsUnlock())
		EndIf
	EndIf
		
Return .T.

/*{Protheus.doc} OGX810VERF()
Verifica se possui DCO vinculado a regra fiscal da IE

@type    Function
@author  francisco.nunes
@since   06/03/2018
@version 1.0
@return  True, logycal, True or False
@example
(examples)
@see (links_or_references)
*/
Function OGX810VERF(cFilCtr, cCodCtr, cItPrev, cRegFis, oModelNLN)

	Local lRet := .F.
	Local nX   := 0
	
	If Valtype(oModelNLN) == "O" 
        For nX := 1 To oModelNLN:Length()
            oModelNLN:GoLine(nX)
            
            If oModelNLN:GetValue("NLN_FILIAL") == cFilCtr .AND. oModelNLN:GetValue("NLN_CODCTR") == cCodCtr .AND.;
            oModelNLN:GetValue("NLN_ITEMPE") == cItPrev .AND. oModelNLN:GetValue("NLN_ITEMRF") == cRegFis .AND.;
                !oModelNLN:IsDeleted()
                lRet := .T.	
                EXIT
            EndIf
            
        Next nX
    EndIf
	
Return lRet

/*{Protheus.doc} OGX810VPRC()
Valida o preço de venda de acordo com o definido no aviso do PEPRO

@type    Function
@author  francisco.nunes
@since   05/04/2018
@version 1.0
@return  True, logycal, True or False
@example
(examples)
@see (links_or_references)
*/
Function OGX810VPRC(cNumAvi, nVlrUni, cTMerc, cCodEnt, cLojEnt, cFilCtr, cCodCtr, cItPrev, cRegFis, cFilRom)

	Local lRet     := .T.
	Local cCodReg  := ""
	Local aPrPEPRO := {}
	Local nPrMiDco := 0
	Local nVlrPre  := 0
	Local cUFOrig  := ""
	Local cCidOrig := ""
	Local cUFDest  := ""
	
	// Busca a cidade e UF de destino
	aRet := OGX810BUF(cTMerc, cCodEnt, cLojEnt, cFilCtr, cCodCtr, cItPrev, cRegFis)
	
	cUFDest  := aRet[1]
	
	cUFOrig  := UPPER(POSICIONE("SM0",1,cEmpAnt+cFilRom,"M0_ESTENT"))   
	cCidOrig := SubStr(POSICIONE("SM0",1,cEmpAnt+cFilRom,"M0_CODMUN"), 3, TamSx3('CC2_CODMUN')[1])
	
	cCodReg := OGX810REG(cNumAvi, cUFOrig, cCidOrig)
		
	// Busca o preco minimo e preco do premio
	aPrPEPRO := OGX810GtPr(cNumAvi, , cUFOrig, cUFDest, cCodReg)
	
	nPrMiDco := aPrPEPRO[1]
	nVlrPre  := aPrPEPRO[2]
	
	// Validar preço mínimo
 	If nPrMiDco > nVlrUni + nVlrPre
 		lRet := .F.
	EndIf

Return lRet
