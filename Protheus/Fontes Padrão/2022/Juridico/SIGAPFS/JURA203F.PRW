#Include "Protheus.Ch"
#Include "JURA203F.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203
Rotina emissão de Faturas

@Params		*cTipo		Tipo de Emissão: 1 - Fatura / 2 - Minuta de Fatura / 3 - Minuta de Pré-fatura
			  -- mudar para TpExec .. 
			cFila		Código da fila de emissão de Faturas

@Return		aRet		Indica o resultado da operação 	[1]: .T. - Concluído com Êxito / .F. - Falha na execução
														[2]: Nome da rotina que originou o erro

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/	
//-------------------------------------------------------------------
Function JA203FEmi(oParams, cCPREFT, cCFATAD, cCFIXO, cCJCONT, cCCONTR, cCCLIEN, cCLOJA)
	Local aRet      := {.F., "JA203FEmi"}
	Local aArea     := GetArea()
	Local aAreaNX0  := NX0->(GetArea())
	Local cCodCaso  := ""
	
	Local cEscr     := ""	
	Local cMoedaPF  := ""
	Local cRelat    := ""
	Local cTEMTS    := ""
	Local cTEMLT    := ""
	Local cTEMDP    := ""
	Local cTEMFX    := ""
	Local cTEMFA    := ""
	Local cQuery    := ""
	Local cQryRes   := GetNextAlias()

	Local cDIniH    := ""
	Local cDFinH    := ""
	Local cDIniD    := ""
	Local cDFinD    := ""
	Local cFATSUB   := ""
	Local cESCSUB   := ""

	//Verificar Escritório e Filial de emissão (se houver junção é da junção)
	If !Empty(cCPREFT)
		
		aRet := J203FCaMin(cCPREFT)  //Verifica se existe e cancela as Minutas ativas da pré-fatura antes de gerar a Fatura 
		
		If aRet[1]
		
			NX0->( dbSetOrder(1) )
			If NX0->(DbSeek( xFilial("NX0") + cCPREFT))
				cEscr    := NX0->NX0_CESCR
				cMoedaPF := NX0->NX0_CMOEDA
				cTEMFA   := NX0->NX0_FATADC
				cFATSUB  := NX0->NX0_FATOLD
				cESCSUB  := NX0->NX0_ESCOLD
				cCFATAD  := NX0->NX0_CFTADC
		
				oParams:SetFatSub( cFATSUB )
				oParams:SetEscSub( cESCSUB )
				oParams:SetDIniH( IIF(Empty(NX0->NX0_DINITS), NX0->NX0_DINIFX, NX0->NX0_DINITS) )
				oParams:SetDFinH( IIF(Empty(NX0->NX0_DFIMTS), NX0->NX0_DFIMFX, NX0->NX0_DFIMTS) )
				oParams:SetDIniD( NX0->NX0_DINIDP )
				oParams:SetDFinD( NX0->NX0_DFIMDP )
				oParams:SetDIniT( NX0->NX0_DINITB )
				oParams:SetDFinT( NX0->NX0_DFIMTB )

				//	Traz os casos dos contrados da Pré-Fatura
				cQuery := " SELECT NX1_CCLIEN, NX1_CLOJA, NX1_CJCONT, NX1_CCONTR, NX1_CCASO,  " + CRLF
				cQuery +=  		   " NX1_TS, NX1_DESP, NX1_LANTAB, NX8_FIXO " + CRLF
				cQuery +=   " FROM " +RetSqlName( 'NX1' )+ " NX1 " + CRLF
				cQuery +=         " INNER JOIN " +RetSqlName( 'NX8' )+ " NX8 ON ( NX8.NX8_FILIAL = '"+ xFilial("NX8") +"' AND "+CRLF
				cQuery +=                                                       " NX8.NX8_CPREFT = NX1.NX1_CPREFT AND " + CRLF
				cQuery +=                                                       " NX8.NX8_CCONTR = NX1.NX1_CCONTR AND " + CRLF
				cQuery +=                                                       " NX8.D_E_L_E_T_ = ' ' ) " + CRLF
				cQuery += " WHERE	NX1.NX1_FILIAL = '"+ xFilial("NX1") +"' "+CRLF
				cQuery += "   AND NX1.NX1_CPREFT = '"+ cCPREFT +"' "+CRLF
				cQuery += "   AND NX1.D_E_L_E_T_ = ' ' " + CRLF
				
				cQuery := ChangeQuery(cQuery, .F.)
				dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
				
				While !(cQryRes)->(EOF())
					cCJCONT  := (cQryRes)->NX1_CJCONT
					cCCONTR  := (cQryRes)->NX1_CCONTR
					
					cCCLIEN  := (cQryRes)->NX1_CCLIEN
					cCLOJA   := (cQryRes)->NX1_CLOJA
					cCodCaso := (cQryRes)->NX1_CCASO

					cTEMTS   := (cQryRes)->NX1_TS
					cTEMLT   := (cQryRes)->NX1_LANTAB
					cTEMDP   := (cQryRes)->NX1_DESP
					cTEMFX   := (cQryRes)->NX8_FIXO
					
					// Apaga as conferências ao emitir a Fatura				
					JA201JApag(oParams, cCFATAD, cCJCONT, cCCONTR, cCCLIEN, cCLOJA, cCodCaso, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA, '2', cCPREFT, STR0002 ) //# Cancelamento por emissão de fatura
						
					//Vincula os lançamentos à Fatura (de pré)
					If cTEMFA == "2" 
						aRet    := JA201BVinc(oParams, cCFIXO, cCPREFT, cCFATAD, cCJCONT, cCCONTR, cCCLIEN, cCLOJA, cCodCaso, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA  ) 
					EndIf
					
					(cQryRes)->(DbSkip())
				EndDo
				(cQryRes)->(dbCloseArea())
			
			EndIf

			oParams:SetContrato(cCCONTR)

		EndIf

		If !Empty(cCJCONT)
			cRelat	:= JurGetDados("NW2", 1 , xFilial("NW2") + cCJCONT, "NW2_CRELAT")
		Else
			cRelat	:= JurGetDados("NT0", 1 , xFilial("NT0") + cCCONTR, "NT0_CRELAT")
		EndIf

	EndIf
 
	If !Empty(cCFATAD)
		
		aRet := J203FCaMin(Nil, cCFATAD)  //Verifica se existe e cancela as Minutas ativas antes de gerar a Fatura 
		
		If aRet[1]
		
			cEscr     := JurGetDados("NVV", 1 , xFilial("NVV") + cCFATAD, "NVV_CESCR")
			cMoedaPF  := JurGetDados("NVV", 1 , xFilial("NVV") + cCFATAD, "NVV_CMOE3")	

			cQuery := J203FCsAd(cCFATAD, cCPREFT,, cQryRes, oParams)
	
			While !(cQryRes)->(EOF())
	
				cCodCaso := (cQryRes)->NVW_CCASO
				cCCLIEN  := (cQryRes)->NVW_CCLIEN
				cCLOJA   := (cQryRes)->NVW_CLOJA
				cTEMTS   := (cQryRes)->NVV_TRATS
				cTEMLT   := (cQryRes)->NVV_TRALT
				cCCONTR  := (cQryRes)->NVV_CCONTR
	
				If (cQryRes)->NVV_TRADSP == "1" .OR. (cQryRes)->NVV_DSPCAS == "1"
					cTEMDP := "1"
				Else
					cTEMDP := "2"
				EndIf
				cTEMFX := "2"
				cTEMFA := "1"
	
				cDIniH := (cQryRes)->NVV_DTINIH
				cDFinH := (cQryRes)->NVV_DTFIMH
				cDIniT := (cQryRes)->NVV_DTINIT
				cDFinT := (cQryRes)->NVV_DTFIMT
				cDIniD := (cQryRes)->NVV_DTINID
				cDFinD := (cQryRes)->NVV_DTFIMD 
		
				oParams:SetDIniH( sTod(cDIniH) )
				oParams:SetDFinH( sTod(cDFinH) )
				oParams:SetDIniT( sTod(cDIniT) )
				oParams:SetDFinT( sTod(cDFinT) )
				oParams:SetDIniD( sTod(cDIniD) )
				oParams:SetDFinD( sTod(cDFinD) )
	
				// Vincula os lançamendos à Fatura (Casos da Fatura Adicinal)
				aRet := JA201BVinc(oParams, cCFIXO, cCPREFT, cCFATAD, cCJCONT, cCCONTR, cCCLIEN, cCLOJA, cCodCaso, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA  )
	
				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
			oParams:SetContrato(cCCONTR)
		EndIf
	EndIf
	
	If !Empty(cCFIXO)
		
		aRet := J203FCaMin(Nil, Nil, cCFIXO) //Verifica se existe e cancela as Minutas ativas antes de gerar a Fatura 
		
		If aRet[1]
	
			cEscr      := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_CESCR")
			cMoedaPF   := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_CMOE")
			cRelat     := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_CRELAT")
	
			cQryRes := J203FCsAd(, , cCFIXO, cQryRes, oParams)

			
			While !(cQryRes)->(EOF())

				cTEMTS   := "2" // Não tem TS à Faturas de Fixo - verifica na rotina de vínculo.
				cTEMLT   := "2"
				cTEMDP   := "2"
				cTEMFA   := "2"
				cTEMFX   := "1"
				
				cCCLIEN  := (cQryRes)->NUT_CCLIEN
				cCLOJA   := (cQryRes)->NUT_CLOJA
				cCodCaso := (cQryRes)->NUT_CCASO
				cCCONTR  := (cQryRes)->NT1_CCONTR
				
				cDIniH   := (cQryRes)->NT1_DATAIN
				cDFinH   := (cQryRes)->NT1_DATAFI
				
				oParams:SetDIniH( sTod(cDIniH) )
				oParams:SetDFinH( sTod(cDFinH) )
		
				// Vincula os lançamendos dos casos
				aRet := JA201BVinc(oParams, cCFIXO, cCPREFT, cCFATAD, cCJCONT, cCCONTR, cCCLIEN, cCLOJA, cCodCaso, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA  ) 
				
				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
	
			oParams:SetContrato(cCCONTR)
		EndIf
	EndIf

	oParams:SetResomaFt(.F., .T.) // Limpa a variável a cada emissão para garantir o correto preenchimento em caso de emissões em lote.

	If aRet[1]
		//Calcula o Total dos casos
		aRet := JA201DCaso(oParams, cCPREFT, cMoedaPF, cCFATAD, cCJCONT, cCCONTR, cCFIXO) 
	EndIf    
	//Calcula o Total dos Contratos
	If aRet[1]
		aRet := JA201ECont(oParams, cCPREFT, cMoedaPF, cCFATAD, cCJCONT, cCCONTR)
	EndIf    
	//Grava a Fatura e ajusta a numeração
	If aRet[1]
		aRet := JA203HFatu(oParams, cCPREFT, cMoedaPF, cCFATAD, cCJCONT, cCCONTR, cCFIXO)
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaNX0)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203FCaMin()
Rotina que verifica e cancela as minutas no momento da emissão de fatura.

@Param   cCodPre  - pré-fatura a ser analisada
@Param   cFatAdic - fatura adicional a ser analisada
@Param   cFixo    - fixo a ser analisado

@Return  lRet     - .F. := Não coseguiu efetuar o cancelamento     

@author Luciano Pereira dos Santos 
@since 08/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203FCaMin(cCodPre, cFatAdic, cFixo)
Local aRet       := {.T., "J203FCaMin", ""} 
Local aArea      := GetArea()
Local aAreaNXA   := NXA->(GetArea())
Local aCancFat   := {}
Local nI         := 0
Local cMotivo    := ""
Local cMsgErro   := ""
Local cSolucao   := ""
Local cLanc      := ""

Default cCodPre  := ""
Default cFatAdic := ""
Default cFixo    := ""

cQuery := " SELECT NXA.R_E_C_N_O_ NXA_RECNO "
cQuery +=   " FROM " + RetSqlname('NXA') + " NXA "
cQuery +=     " WHERE  NXA.NXA_FILIAL  = '" + xFilial("NXA") + "' "
If !Empty(cCodPre)
	cQuery += " AND NXA.NXA_CPREFT = '" + cCodPre + "' "
	cLanc := STR0003  // "pré-fatura"
ElseIf !Empty(cFatAdic)
	cQuery += " AND NXA.NXA_CFTADC = '" + cFatAdic + "' "
	cLanc := STR0005  // "fatura adicional"
ElseIf !Empty(cFixo)
	cQuery += " AND NXA.NXA_CFIXO = '" + cFixo + "' "
	cLanc := STR0004  // "parcela fixa"
EndIf
cQuery +=     " AND NXA.NXA_SITUAC = '1' "
cQuery +=     " AND NXA.NXA_TIPO IN ('MP','MF','MS') "
cQuery +=     " AND NXA.D_E_L_E_T_ = ' ' "

aCancFat := JurSQL(cQuery, {'NXA_RECNO'})

For nI := 1 To Len(aCancFat)
	
	NXA->(DbGoto(aCancFat[nI][1]))

	If !JA204CanFa(cMotivo, @cMsgErro, @cSolucao)
		aRet[1] := .F.
		aRet[2] := I18N(STR0001, {cCodPre, cLanc}) + CRLF  + cMsgErro //"J203FCaMin - Problema no cancelamento da(s) minuta(s) da '#2' '#1': "
		aRet[3] := cSolucao
		Exit
	EndIf 
		
Next nI

RestArea( aArea )
RestArea( aAreaNXA )

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} J203FCsAd
Função que retorna os Casos dos Contratos Fixos ou Faturas Adicionais

@param   cCFATAD   , caracatere, Código da Fatura Adicional
@param   cCPREFT   , caracatere, Código da Pré-Fatura
@param   cCFIXO    , caracatere, Código do Fixo
@param   cQryRes   , Alias de retorno da Query
@param   oParams   , Objeto de negócio da emissão de fatura

@return  cQryRes   , Alias de retorno da Query

@author  fabiana.silva
@since   13/12/2021
@version 1.0
/*/
//--------------------------------------------------------------------
Function J203FCsAd(cCFATAD, cCPREFT, cCFIXO, cQryRes, oParams)
Local cQuery    := ""
Local cSituac   := ""

Default cCFATAD := ""
Default cCPREFT := ""
Default cCFIXO  := ""
Default oParams := NIL

	If oParams <> NIL
		cSituac := oParams:GetSituac()
	EndIf

	If !Empty(cQryRes)

		If !Empty(cCFATAD)
		// Traz os casos dos contrados da Fatura Adicional
			cQuery :=     " SELECT NVV.NVV_COD, NVV.NVV_CCONTR, NVW.NVW_CCLIEN, NVW.NVW_CLOJA, NVW.NVW_CCASO, "
			cQuery +=            " NVV.NVV_TRALT, NVV.NVV_TRATS, NVV.NVV_DTINIH, NVV.NVV_DTFIMH, NVV.NVV_TRADSP, "
			cQuery +=            " NVV.NVV_DTINID, NVV.NVV_DTFIMD, NVV.NVV_DSPCAS, NVV.NVV_DTINIT, NVV.NVV_DTFIMT "
			cQuery +=       " FROM " + RetSqlName('NVV') + " NVV "
			cQuery +=      " INNER JOIN " + RetSqlName('NVW') + " NVW "
			cQuery +=          "ON ( NVV.NVV_COD = NVW.NVW_CODFAD "
			cQuery +=        " AND NVW.NVW_FILIAL = '" + xFilial("NVW") + "' "
			cQuery +=        " AND NVW.D_E_L_E_T_ = ' ' ) "
			If cSituac <> "" .And. cSituac <> "1" // Conferencia
				cQuery +=  " INNER JOIN " + RetSqlName('NVE') + " NVE "
			    cQuery +=     " ON ( NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
				cQuery +=    " AND NVE.NVE_COBRAV = '1' "
				cQuery +=    " AND NVE.D_E_L_E_T_ = ' ' "
				cQuery +=    " AND NVE.NVE_NUMCAS = NVW.NVW_CCASO "
				cQuery +=    " AND NVE.NVE_CCLIEN = NVW.NVW_CCLIEN "
				cQuery +=    " AND NVE.NVE_LCLIEN = NVW_CLOJA) "
			EndIf
			cQuery +=      " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
			cQuery +=        " AND NVV.NVV_COD    = '" + cCFATAD + "' "
			If !Empty(!Empty(cCPREFT))
				cQuery +=    " AND NVV.NVV_CPREFT = '" + cCPREFT + "' "
			EndIf
			cQuery +=        " AND NVV.D_E_L_E_T_ = ' ' "
		Else
			// Traz os casos dos contratos de Fixos
			cQuery := " SELECT NT1.NT1_SEQUEN, NT1.NT1_CCONTR, NUT.NUT_CCLIEN, NUT.NUT_CLOJA, NUT.NUT_CCASO, "
			cQuery +=        " NT1.NT1_DATAIN, NT1.NT1_DATAFI "
			cQuery +=   " FROM " + RetSqlName("NT1") + " NT1 "
			cQuery +=  " INNER JOIN " + RetSqlName("NT0") + " NT0 "
			cQuery +=     " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
			cQuery +=    " AND NT0.NT0_COD = NT1.NT1_CCONTR "
			cQuery +=    " AND NT0.D_E_L_E_T_ = ' ' "
			cQuery +=  " INNER JOIN " + RetSqlName("NUT") + " NUT "
			cQuery +=     " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
			cQuery +=    " AND NUT.NUT_CCONTR = NT1.NT1_CCONTR "
			cQuery +=    " AND NUT.D_E_L_E_T_ = ' ' "
			cQuery +=  " INNER JOIN " + RetSqlName("NTH") + " NTH "
			cQuery +=     " ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "' "
			cQuery +=    " AND NTH.NTH_CTPHON = NT0.NT0_CTPHON "
			cQuery +=    " AND NTH.NTH_CAMPO = 'NT0_FXABM' "
			cQuery +=    " AND NTH.D_E_L_E_T_ = ' '"
			cQuery +=  " INNER JOIN " + RetSqlName("NVE") + " NVE "
			cQuery +=     " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
			cQuery +=    " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
			cQuery +=    " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
			cQuery +=    " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
			cQuery +=    " AND NVE.NVE_ENCHON = '2' "
			cQuery +=    " AND NVE.D_E_L_E_T_ = ' ' "
			If cSituac <> "" .And. cSituac <> "1" // Conferencia
			   cQuery += " AND NVE.NVE_COBRAV = '1' "
			EndIf
			cQuery +=  " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
			cQuery +=    " AND NT1.NT1_SEQUEN = '" + cCFIXO + "' "
			cQuery +=    " AND NT1.D_E_L_E_T_ = ' ' "
			// Se não for Faixa Qtdade de Casos
			cQuery +=    " AND (CASE WHEN NTH.NTH_VISIV = '2' THEN "
			cQuery +=            " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
			cQuery +=               " (CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQuery +=            " END) "
			cQuery +=         " ELSE "
			// Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
			cQuery +=            " (CASE WHEN NTH.NTH_VISIV = '1' THEN "
			cQuery +=                " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
			cQuery +=                    " (CASE WHEN NT0.NT0_FXABM = '1' THEN  "
			cQuery +=                        " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQuery +=                     " ELSE "
			cQuery +=                         " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQuery +=                     " END) "
			cQuery +=                 " ELSE "
			cQuery +=                    " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
			cQuery +=                        " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQuery +=                            " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQuery +=                         " ELSE "
			cQuery +=                            " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQuery +=                         " END ) "
			cQuery +=                     " ELSE "
			cQuery +=                        " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQuery +=                            " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQuery +=                         " ELSE "
			cQuery +=                            " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQuery +=                         " END) "
			cQuery +=                     " END) "
			cQuery +=                 " END) "
			cQuery +=             " END) "
			cQuery +=          " END) <> '2' "
		EndIf
		cQuery := ChangeQuery(cQuery, .F.)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery), cQryRes, .T., .F.)
	EndIf
Return cQryRes
