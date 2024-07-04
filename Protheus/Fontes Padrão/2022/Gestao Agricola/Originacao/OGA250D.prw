#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGA250D.ch'

#DEFINE _CRLF CHR(13)+CHR(10)

Static __aItRefs	 := {}
Static __nPsItRef	 := 0
Static __cCodCtr   := ""
Static __cItemCtr  := ""
Static __cRegFis   := ""
Static __cTESRef   := ""
Static __aCtrs     := {} // Array utilizado para armazenar os contratos e seus respectivos pesos consumidos da NJM
Static __aPrecos   := {}
Static __nXPrecos  := 0
Static __aDCOs	 := {}
Static __nXDCOs    := 0
Static __aDCOsVinc := {}

Static __cLoteQNJM  := "" 
Static __cSubLtQNJM := "" 
Static __cDtValQNJM := "" 
Static __cKeyQNJM   := "" 
Static __lExistNLN := TableInDic("NLN")

/** {Protheus.doc} OG250DQNJM
Quebra NJM (Comercialização) pelos contratos/cadências/regras fiscais das IE(s) definida(s) no romaneio
de acordo com a quantidade instruída e pesagem do romaneio

@return:	Nil
@author: 	franciso.nunes
@since: 	27/03/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, filial do romaneio
@param cCodRom, character, código do romaneio
@param nPesoRom, number, peso total do romaneio, que será distriuido pelas regras fiscais das Ies
@param nValorUnit, number, valor unitário do romaneio
@param cSerNFP, character, Série da NFP do Romaneio
@param cNumNFP, character, Número da NFP do Romaneio
@param nTpProd, number, tipo de produto (1 - Grãos, 2 - Algodão)
@param cSubTipo, character, subtipo do romaneio
@param cTipoRom, character, tipo do romaneio
@param cTipMer,	 character, tipo de mercado(1-interno; 2-externo)
@param cLote, character, lote dos produtos não controlados por fardos
*/
Function OG250DQNJM(cFilRom, cCodRom, nPesoRom, nValorUnit, cSerNFP, cNumNFP, nTpProd, cSubTipo, cTipoRom, cTipMer, cLote)

	Local cQry 	    := ""
	Local cAliasQry := ""
	Local aIES		:= {}
	Local aFldNJM	:= {}
	Local nPesoNJM  := 0	
	Local nPsExcFis := 0	
	Local nPsNJMFis := 0	
	Local aItNJM	:= {}
	Local nPos		:= 0
	Local lRet		:= .T.	
	Local nItRom    := 0	
	Local nPesoNJJ  := nPesoRom
	Local cFilOrg	:= ""
	Local cSubTip	:= ""
	Local cItEtg	:= ""
	Local cItRef	:= ""
	Local cCodIE	:= ""	
	Local nIndOp	:= IIF(cTipMer == '1', 4, 2) //4-mercado interno; 2-mercado externo	
	Local cCodEnt	:= ""
	Local cLojEnt	:= ""
	Local cSafra	:= ""
	Local cCodPro	:= ""
	Local nIt		:= 0	
	Local cTipIE	:= "" //1 - Venda/2 - Armazenagem
	Local cCtrNJM   := ""
	Local cEtgNJM   := ""
	Local cRefNJM   := ""
	Local lRemVnd	:= .F.
	Local lQrbPrc   := SuperGetMV("MV_AGRO209",, .F.)    
	Local nRowNJM   as numeric
	Local aBasAlg	:= {} 
	Local aDadosNF  := {} 
	Private _aFrdRom	:= {} //fardos do romaneio(N9D)
	Private _lUsaIe := .F.
	Default cLote   := ''

	__aItRefs  := {}
	__aCtrs    := {}
	__nPsItRef := 0
	__cCodCtr  := ""
	__cItemCtr := ""
	__cRegFis  := ""
	__cTESRef  := ""
	__aPrecos  := {}
	__nXPrecos := 0

	aIES := OG250DIES(cFilRom, cCodRom)

	_lUsaIe := IIF(LEN(aIES) > 0 , .T. , .F.)

	If nTpProd = 1 // Grãos
		If _lUsaIe
		//usa o processo de instrução de embarque	

			For nIt := 1 to Len(aIES)

				cTipIE  := ""
				lRemVnd := .F.

				DbSelectArea("N7Q")
				N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
				If N7Q->(DbSeek(xFilial("N7Q")+aIES[nIt]))
					cTipIE := N7Q->N7Q_TPCTR
				EndIf

				If cTipoRom == "2" .AND. cTipIE == "1"
					lRemVnd := .T.
				EndIf

				cAliasQry := GetNextAlias()
				cQry := " SELECT N7S.N7S_FILIAL, "				
				cQry += "		 N7S.N7S_CODINE, "

				// Apenas informa o contrato, prev. ent. e regra fiscal caso não for remessa para depósito de uma IE tipo venda			
				If !lRemVnd	
					cQry += "	 N7S.N7S_CODCTR, "
					cQry += "    N7S.N7S_ITEM, "
					cQry += "    N7S.N7S_SEQPRI, "
				EndIf
				
				IF cTipMer = '2' .AND.  cTipoRom == "4"  
					cQry += "        SUM(N7S.N7S_QTDVIN) AS QTDREMET "
				ELSE            
					cQry += "        SUM(N7S.N7S_QTDVIN - N7S.N7S_QTDREM) AS QTDREMET "
				ENDIF
				
				cQry += " FROM " + RetSqlName("N7S") + " N7S "		
				cQry += " WHERE N7S.N7S_FILIAL = '" + xFilial("N7S") + "' "			
				cQry += "   AND N7S.N7S_CODINE = '" + aIES[nIt] + "' "
				
				IF  cTipMer <> '2' .OR. cTipoRom <> "4"  
					cQry += "   AND N7S.N7S_QTDVIN > N7S.N7S_QTDREM "
				ENDIF
				
				cQry += "   AND N7S.N7S_FILORG = '" + cFilRom + "' "
				cQry += "   AND N7S.D_E_L_E_T_ = '' "
				cQry += " GROUP BY N7S.N7S_FILIAL, "
				cQry += "          N7S.N7S_CODINE "

				// Apenas informa o contrato, prev. ent. e regra fiscal caso não for remessa para depósito de uma IE tipo venda
				If !lRemVnd			
					cQry += "    , N7S.N7S_CODCTR, "
					cQry += "      N7S.N7S_ITEM, "
					cQry += "      N7S.N7S_SEQPRI "
				EndIf

				cQry := ChangeQuery( cQry )	
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

				dbSelectArea(cAliasQry)
				(cAliasQry)->(DbGoTop())

				If (cAliasQry)->(Eof())
					Agrhelp(STR0002,STR0003,STR0021) //##A Instrução de Embarque informada não possui regra fiscal com saldo para remeter##""Verifique se existe saldo na regra fiscal para instruir e ajuste a quantidade da instrução de embarque ou remova a instrução de embarque sem saldo do romaneio"."
					(cAliasQry)->(DbCloseArea())
					lRet := .F.
				Else
					While (cAliasQry)->(!Eof())	
						If nPesoRom = 0
							EXIT
						EndIf

						If nPesoRom > (cAliasQry)->QTDREMET //QTD A REMETER
							nPesoNJM := (cAliasQry)->QTDREMET
						Else
							nPesoNJM := nPesoRom
						EndIf

						cCtrNJM := ""
						cEtgNJM := ""
						cRefNJM := ""

						// Apenas informa o contrato, prev. ent. e regra fiscal caso não for remessa para depósito de uma IE tipo venda
						If !lRemVnd
							cCtrNJM := (cAliasQry)->N7S_CODCTR
							cEtgNJM := (cAliasQry)->N7S_ITEM
							cRefNJM := (cAliasQry)->N7S_SEQPRI
						EndIf 

						If !OG250DCNJM(@nItRom, @aFldNJM, cFilRom, cCodRom, (cAliasQry)->N7S_FILIAL, (cAliasQry)->N7S_CODINE, cCtrNJM, cEtgNJM, cRefNJM, nPesoNJM, nPesoNJJ, nValorUnit, '', '', '', '', cSerNFP, cNumNFP, nIndOp, cSubTipo, cTipoRom, lRemVnd, cLote)
							Return .F.
						EndIf

						nPesoRom := nPesoRom - nPesoNJM

						If !lRemVnd
							// Inclui no array de contratos o peso da NJM para ter o controle do saldo que será consumido dos contratos
							ConsumCtr(1, (cAliasQry)->N7S_FILIAL+(cAliasQry)->N7S_CODCTR, nPesoNJM)

							// Grava o consumo da NJM em um array por Filial + Contrato + Prev. Entrega + Regra Fiscal		
							ConsSldRef((cAliasQry)->N7S_FILIAL+cCtrNJM+cEtgNJM+cRefNJM, nPesoNJM, .T.)
						EndIf

						(cAliasQry)->(DbSkip())		
					EndDo
					(cAliasQry)->(DbCloseArea())
				EndIf	
			Next nIt	
		Else	
			//GRÃOS - não usa o processo de instrução de embarque
			nRowNJM    := 0
			nPesoNJM   := 0
			
			cAliasQry  := GetNextAlias()

				cAliasQry := GetNextAlias()
				cQry := " SELECT NJM.*,N9A.*,NJR.*				
				cQry += " FROM " + RetSqlName("NJM") + " NJM "
				cQry += " INNER JOIN " + RetSqlName("N9A") + " N9A  ON N9A_FILIAL = NJM_FILORG AND "
				cQry += " N9A_FILORG = NJM_FILIAL AND N9A_CODCTR = NJM_CODCTR AND "
				cQry += " N9A_ITEM = NJM_ITEM AND N9A_SEQPRI = NJM_SEQPRI AND N9A.D_E_L_E_T_ = '' "
				cQry += " INNER JOIN " + RetSqlName("NJR") + " NJR  ON NJR_FILIAL = N9A_FILIAL AND "
				cQry += " NJR_CODCTR = N9A_CODCTR AND NJR.D_E_L_E_T_ = ''  "
				cQry += " WHERE 
				cQry += " NJM_FILIAL = '" + cFilRom + "' AND "
				cQry += " NJM_CODROM = '" + cCodrom + "' AND "
				cQry += " NJM.D_E_L_E_T_ = '' "
				cQry := ChangeQuery( cQry )	
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
				//RETIRAR NJM SUBTIPO EXCEDENTE

				If (cAliasQry)->(Eof())
					Agrhelp(STR0002,STR0022,STR0023) //##"Não foi possivel localizar a regra fiscal do contrato""##"Verifique as informações do contrato informadas na aba Comercialização do romaneio."
					(cAliasQry)->(DbCloseArea())
					lRet := .F.
				Else
					While (cAliasQry)->(!Eof())	
						aDadosNF := {}
						If (cAliasQry)->NJM_TIPO == "5" .AND. (cAliasQry)->NJM_TPFORM == "2" 
							nPsExcFis := 0
							
							If (cAliasQry)->NJM_QTDFIS > (cAliasQry)->N9A_SDONF 
								nPsExcFis :=  (cAliasQry)->NJM_QTDFIS - (cAliasQry)->N9A_SDONF//EXCEDENTE PESO FISCAL
								nPsNJMFis := (cAliasQry)->NJM_QTDFIS - nPsExcFis
								If nPsNJMFis < (cAliasQry)->NJM_QTDFCO
									nPesoNJM := nPsNJMFis //AQUI É O PESO FISICO
								Else
									nPesoNJM := (cAliasQry)->NJM_QTDFCO - nPsExcFis //AQUI É O PESO FISICO
								EndIf
								
							Else
								nPesoNJM := (cAliasQry)->NJM_QTDFCO  
								nPsNJMFis := (cAliasQry)->NJM_QTDFIS 
							EndIf	

							aadd(aDadosNF, 	(cAliasQry)->NJM_DOCNUM)
							aadd(aDadosNF,  (cAliasQry)->NJM_DOCSER)			
							aadd(aDadosNF,  sToD((cAliasQry)->NJM_DOCEMI))			
							aadd(aDadosNF,  (cAliasQry)->NJM_DOCESP)			
							aadd(aDadosNF,  ROUND( ((cAliasQry)->NJM_VLRUNI * nPsNJMFis) , TamSX3( "NJM_VLRTOT" )[2] ) )
							aadd(aDadosNF,  (cAliasQry)->NJM_VLRUNI)
							aadd(aDadosNF,  nPsNJMFis) //Peso fiscal

							cCtrNJM := (cAliasQry)->N9A_CODCTR
							cEtgNJM := (cAliasQry)->N9A_ITEM
							cRefNJM := (cAliasQry)->N9A_SEQPRI						

							If !OG250DCNJM(@nItRom, @aFldNJM, cFilRom, cCodRom,  (cAliasQry)->N9A_FILIAL , '', cCtrNJM, cEtgNJM, cRefNJM, nPesoNJM, nPesoNJJ, (cAliasQry)->NJM_VLRUNI, '', '', '', '', (cAliasQry)->NJM_NFPSER, (cAliasQry)->NJM_NFPNUM, nIndOp, cSubTipo, cTipoRom, lRemVnd, (cAliasQry)->NJM_LOTCTL,aDadosNF)
								Return .F.
							EndIf

							// Inclui no array de contratos o peso da NJM para ter o controle do saldo que será consumido dos contratos
  						    If (cAliasQry)->(NJR_CLASSP) == "1" 
								ConsumCtr(1, (cAliasQry)->N9A_FILIAL+(cAliasQry)->N9A_CODCTR, nPesoNJM)
							Else
								ConsumCtr(1, (cAliasQry)->N9A_FILIAL+(cAliasQry)->N9A_CODCTR, nPsNJMFis)
							EndIf
							// Grava o consumo da NJM em um array por Filial + Contrato + Prev. Entrega + Regra Fiscal		
							ConsSldRef((cAliasQry)->N9A_FILIAL+cCtrNJM+cEtgNJM+cRefNJM, nPsNJMFis, .T.)
							
							IF nPsExcFis > 0
								nPesoRom := nPesoRom - nPesoNJM //desconta o que ja foi usado acima
								nPesoNJM := (cAliasQry)->NJM_QTDFCO - nPesoNJM //PESO FISICO
								aItNJM := aFldNJM[Len(aFldNJM)] // Pega o último registro inserido na NJM
								aDadosNF[7] := nPsExcFis //PESO FISCAL
								aDadosNF[5] := ROUND( (aDadosNF[6] * aDadosNF[7]) , TamSX3( "NJM_VLRTOT" )[2] ) //VALOR TOTAL
								If !VerExcCtr(FWXFilial("NJR"), (cAliasQry)->NJM_CODCTR, nPsExcFis)//verifica se permite excedente
									lRet := .F.
									EXIT
								ElseIF !VerExcRom(nTpProd, @aFldNJM, aItNJM, @nItRom, cFilRom, cCodRom, nPesoNJJ, N9A->N9A_FILIAL, "", cCtrNJM, cEtgNJM, cRefNJM, nPsExcFis, (cAliasQry)->NJM_VLRUNI, (cAliasQry)->NJM_NFPSER, (cAliasQry)->NJM_NFPNUM, (cAliasQry)->NJM_LOTCTL, IIF((cAliasQry)->N9A_OPEFUT == "1",.T.,.F.),aDadosNF) //insere o excedente
									lRet := .F.
									EXIT
								EndIf
							EndIF

							nPesoRom := nPesoRom - nPesoNJM 						

						Else
							
							//saida ou entrada com formulario proprio sim 
							If nPesoRom > (cAliasQry)->N9A_SDONF
								nPesoNJM := (cAliasQry)->N9A_SDONF
							Else
								nPesoNJM := nPesoRom
							EndIf

							cCtrNJM := ""
							cEtgNJM := ""
							cRefNJM := ""

							// Apenas informa o contrato, prev. ent. e regra fiscal caso não for remessa para depósito de uma IE tipo venda
							If !lRemVnd
								cCtrNJM := (cAliasQry)->N9A_CODCTR
								cEtgNJM := (cAliasQry)->N9A_ITEM
								cRefNJM := (cAliasQry)->N9A_SEQPRI
							EndIf 

							If !OG250DCNJM(@nItRom, @aFldNJM, cFilRom, cCodRom,  (cAliasQry)->N9A_FILIAL , '', cCtrNJM, cEtgNJM, cRefNJM, nPesoNJM, nPesoNJJ, nValorUnit, '', '', '', '', cSerNFP, cNumNFP, nIndOp, cSubTipo, cTipoRom, lRemVnd, cLote,aDadosNF)
								Return .F.
							EndIf

							If !lRemVnd
								// Inclui no array de contratos o peso da NJM para ter o controle do saldo que será consumido dos contratos
								ConsumCtr(1, (cAliasQry)->N9A_FILIAL+(cAliasQry)->N9A_CODCTR, nPesoNJM)

								// Grava o consumo da NJM em um array por Filial + Contrato + Prev. Entrega + Regra Fiscal		
								ConsSldRef((cAliasQry)->N9A_FILIAL+cCtrNJM+cEtgNJM+cRefNJM, nPesoNJM, .T.)
							EndIf

							nPesoRom := nPesoRom - nPesoNJM

						EndIf

						(cAliasQry)->(DbSkip())		
					EndDo
					(cAliasQry)->(DbCloseArea())
				EndIf

		EndIf
			
	Else //se algodão
		
		If _lUsaIe
			aBasAlg := aIES
		Else
			aBasAlg := OG250DRFs(cFilRom, cCodRom) //pega as regras fiscais da NJM
		EndIf 

		For nIt := 1 to Len(aBasAlg)

			cTipIE  := ""
			lRemVnd := .F.

			If _lUsaIe
				DbSelectArea("N7Q")
				N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
				If N7Q->(DbSeek(xFilial("N7Q")+aBasAlg[nIt]))
					cTipIE := N7Q->N7Q_TPCTR
				EndIf

				If cTipoRom == "2" .AND. cTipIE == "1"
					lRemVnd := .T.
				EndIf

			Else
				DbSelectArea("NJR")
				NJR->(DbSetOrder(1)) 
				If NJR->(DbSeek(xFilial("NJR")+aBasAlg[nIt][1]))
					cTipIE := NJR->NJR_TIPO  //AQUI OU SERÁ 2=VENDA OU 4=ARMAZENAGEM EM TERCEIRO
				EndIf

				If cTipoRom == "2" .AND. cTipIE == "2" //ROMANEIO DE REMESSA COM CONTRATO DE VENDA
					lRemVnd := .T. //REMESSA PARA VENDA
				EndIf

			ENDIF

			cAliasQry := GetNextAlias()
			cQry := " SELECT N9D.N9D_CODINE, "

			// Apenas informa o contrato, prev. ent. e regra fiscal caso não for remessa para depósito de uma IE tipo venda			
			If !lRemVnd	
				cQry += "    N9D.N9D_CODCTR, "
				cQry += "    N9D.N9D_ITEETG, "
				cQry += "    N9D.N9D_ITEREF, "
			EndIf

			cQry += "		 SUM(N9D.N9D_PESFIM) AS QTDREMET "
			cQry += " FROM " + RetSqlName("N9D") + " N9D "
			cQry += " WHERE N9D.N9D_FILORG = '" + cFilRom + "' "
			cQry += "   AND N9D.N9D_CODROM = '" + cCodRom + "' "
			If _lUsaIe
				cQry += "   AND N9D.N9D_CODINE = '" + aBasAlg[nIt] + "' "
			Else
				cQry += "   AND N9D.N9D_CODCTR = '" + aBasAlg[nIt][1] + "' "
				cQry += "   AND N9D.N9D_ITEETG = '" + aBasAlg[nIt][2] + "' "
				cQry += "   AND N9D.N9D_ITEREF = '" + aBasAlg[nIt][3] + "' "
			EndIf
			cQry += "   AND N9D.N9D_TIPMOV = '07' " 	 
			cQry += "   AND N9D.N9D_STATUS = '2' "
			cQry += "   AND N9D.D_E_L_E_T_ = '' "
			cQry += " GROUP BY N9D.N9D_CODINE "

			// Apenas informa o contrato, prev. ent. e regra fiscal caso não for remessa para depósito de uma IE tipo venda			
			If !lRemVnd		
				cQry += "	 , N9D.N9D_CODCTR, "
				cQry += "      N9D.N9D_ITEETG, "
				cQry += "      N9D.N9D_ITEREF "
			EndIf

			cQry := ChangeQuery( cQry )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

			dbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())

			If (cAliasQry)->(Eof())
				If _lUsaIe
					Agrhelp(STR0002,STR0004 + aBasAlg[nIt],STR0024) //## Não foram encontrados fardos vinculados ao romaneio para a IE##"Vincule os fardos no romaneio ou remova a instrução de embarque."
				else
					Agrhelp(STR0002,STR0014 + aBasAlg[nIt][1] + STR0015 + aBasAlg[nIt][2] + STR0016 + aBasAlg[nIt][3] ,STR0025) //## Não foram encontrados fardos vinculados ao romaneio para a IE##"Vincule os fardos no romaneio ou remova o contrato da aba Comercialização do romaneio"
				ENDIF
				(cAliasQry)->(DbCloseArea())
				lRet := .F.
			Else
				While (cAliasQry)->(!Eof())	
					If nPesoRom = 0
						EXIT
					EndIf

					If nPesoRom > (cAliasQry)->QTDREMET
						nPesoNJM := (cAliasQry)->QTDREMET
					Else
						nPesoNJM := nPesoRom
					EndIf

					cCtrNJM := ""
					cEtgNJM := ""
					cRefNJM := ""

					// Apenas informa o contrato, prev. ent. e regra fiscal caso não for remessa para depósito de uma IE tipo venda
					If !lRemVnd
						cCtrNJM := (cAliasQry)->N9D_CODCTR
						cEtgNJM := (cAliasQry)->N9D_ITEETG
						cRefNJM := (cAliasQry)->N9D_ITEREF
					EndIf 

					// Verifica se o contrato permite excedente
					If !VerExcCtr(FWXFilial("NJR"), cCtrNJM, nPesoNJM)
						lRet := .F.
						EXIT
					EndIf

					If !OG250DCNJM(@nItRom, @aFldNJM, cFilRom, cCodRom, FWXFilial("N7Q"), (cAliasQry)->N9D_CODINE, cCtrNJM, cEtgNJM, cRefNJM, nPesoNJM, nPesoNJJ, nValorUnit, '', '', '', '', cSerNFP, cNumNFP, nIndOp, @cSubTipo, cTipoRom, lRemVnd, cLote)
						Return .F. 
					EndIf
					
					OG250EAIR(cFilRom, cCodRom, (cAliasQry)->N9D_CODINE, nItRom, cCtrNJM, cEtgNJM, cRefNJM)	
					
					nPesoRom := nPesoRom - nPesoNJM

					If !lRemVnd					
						// Inclui no array de contratos o peso da NJM para ter o controle do saldo que será consumido dos contratos
						ConsumCtr(1, FWXFilial("NJR")+(cAliasQry)->N9D_CODCTR, nPesoNJM)

						// Caso não seja "REMESSA POR VENDA FUTURA", será gravado o saldo consumido na NJM
						// Não grava para "REMESSA POR VENDA FUTURA", pois dentro da OG250DCNJM já realiza a gravação 
						If cSubTipo != "44" 
							// Grava o consumo da NJM em um array por Filial + Contrato + Prev. Entrega + Regra Fiscal		
							ConsSldRef(FWXFilial("NJR")+cCtrNJM+cEtgNJM+cRefNJM, nPesoNJM, .T.)
						EndIf
					EndIf

					(cAliasQry)->(DbSkip())		
				EndDo
				(cAliasQry)->(DbCloseArea())
			EndIf		
		Next nIt
	EndIf	 //FIM ALGODAO

	If cTipoRom == "2" .AND. lRet // (S) REMESSA PARA DEPÓSITO 
		_aFrdRom	:= FrdVincRom(cFilRom,cCodRom) //fardos do romaneio(N9D), será usado para ajustar o contrato da N9D e peso da NJM

		For nIt := 1 to Len(aFldNJM)

			nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_CODCTR"})			
			cCtrNJM := aFldNJM[nIt][nPos][2]

			If Empty(cCtrNJM) // Quando não possui contrato, entende-se que é Remessa Formação de Lote de IE de Venda
				nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_CODENT"})			
				cCodEnt := aFldNJM[nIt][nPos][2]

				nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_LOJENT"})			
				cLojEnt := aFldNJM[nIt][nPos][2]

				nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_CODSAF"})			
				cSafra := aFldNJM[nIt][nPos][2]

				nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_CODPRO"})			
				cCodPro := aFldNJM[nIt][nPos][2]

				// Efetua a seleção da regra fiscal do contrato de armazenagem em 3		
				If !QuebraNJM(1, cCodEnt, cLojEnt, cSafra, cCodPro, cFilRom, @aFldNJM[nIt], nPesoNJJ, @aFldNJM, @nItRom)
					lRet := .F.
				EndIf
			EndIf			
		Next nIt

	EndIf
	
	// (S) SAÍDA POR VENDA / Verificará se deve quebrar por DCO
	If cTipoRom == "4" .AND. lRet
		
		For nIt := 1 to Len(aFldNJM)
			
			aItNJM := aFldNJM[nIt]
			
			// Busca a posição do campo NJM_FILORG no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_FILORG"})			
			cFilOrg := aItNJM[nPos][2]
	
			// Busca a posição do campo NJM_CODCTR no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODCTR"})			
			__cCodCtr := aItNJM[nPos][2]
	
			// Busca a posição do campo NJM_ITEM no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_ITEM"})			
			__cItemCtr := aItNJM[nPos][2]
	
			// Busca a posição do campo NJM_SEQPRI no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQPRI"})			
			__cRegFis := aItNJM[nPos][2]
			
			// Busca a posição do campo NJM_CODINE no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODINE"})
			cCodIE := aItNJM[nPos][2]
			
			__aDCOs  := {}
			__nXDCOs := 1
			
			// Caso possua vinculo de DCO com a regra fiscal (NLN), quebrará a NJM
            If __lExistNLN
                DbSelectArea("NLN")
                NLN->(DbSetOrder(2)) //NLN_FILIAL+NLN_CODCTR+NLN_ITEMPE+NLN_ITEMRF+NLN_CODINE
                If NLN->(DbSeek(cFilOrg+__cCodCtr+__cItemCtr+__cRegFis+cCodIE))
                    While NLN->(!Eof()) .AND. NLN->(NLN_FILIAL+NLN_CODCTR+NLN_ITEMPE+NLN_ITEMRF+NLN_CODINE) == cFilOrg+__cCodCtr+__cItemCtr+__cRegFis+cCodIE
                        
                        If NLN->NLN_QTDVIN - NLN->NLN_QTDFAT > 0
                            Aadd(__aDCOs, {NLN->NLN_NUMAVI, NLN->NLN_NUMDCO, NLN->NLN_SEQDCO, NLN->NLN_PRECO, NLN->NLN_QTDVIN - NLN->NLN_QTDFAT, NLN->NLN_SEQUEN})
                        EndIf
                                            
                        NLN->(DbSkip())
                    EndDo
                EndIf
            EndIf
			
			If Len(__aDCOs) > 0													
				// Efetua a quebra por DCO na NJM		
				If !QuebraNJM(4, , , , , cFilRom, @aFldNJM[nIt], nPesoNJJ, @aFldNJM, @nItRom)
					lRet := .F.
				EndIf
			EndIf
						
		Next nIt	
		
	EndIf
	
	If cTipoRom == "4" .AND. nTpProd = 1 .AND. lRet .AND. lQrbPrc // (S) SAÍDA POR VENDA GRÃOS e PARÂMETRO INDICA QUE A NJM DEVE SER QUEBRADA POR PREÇO
		//SOMENTE GRÃOS QUEBRA PREÇO NA NJM, ALGODÃO IRA QUEBRAR PREÇO NO DOC FISCAL
		For nIt := 1 to Len(aFldNJM)
			
			aItNJM := aFldNJM[nIt]
			
			// Busca a posição do campo NJM_NUMAVI no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_NUMAVI"})
			
			// Verifica se já foi efetuado a quebra desta regra fiscal por DCO, caso já tenha sido feito, não quebra por preço
			// Não quebrará por preço, pois a quebra do DCO já compreende a quebra por preço
			If !Empty(aItNJM[nPos][2])
				LOOP
			EndIf
				
			// Busca a posição do campo NJM_FILORG no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_FILORG"})			
			cFilOrg := aItNJM[nPos][2]
	
			// Busca a posição do campo NJM_CODCTR no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODCTR"})			
			__cCodCtr := aItNJM[nPos][2]
	
			// Busca a posição do campo NJM_ITEM no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_ITEM"})			
			__cItemCtr := aItNJM[nPos][2]
	
			// Busca a posição do campo NJM_SEQPRI no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQPRI"})			
			__cRegFis := aItNJM[nPos][2]
			
			// Busca a posição do campo NJM_QTDFIS no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_QTDFIS"})
			nPesoNJM := aItNJM[nPos][2]
			
			// Busca a posição do campo NJM_CODINE no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODINE"})
			cCodIE := aItNJM[nPos][2]
		
		  	cCodClient := Posicione("NJ0",1,FWxFilial("NJ0")+cCodEnt+cLojEnt,"NJ0_CODCLI")	
			cCodLoja   := Posicione("NJ0",1,FWxFilial("NJ0")+cCodEnt+cLojEnt,"NJ0_LOJCLI")
			
			// Busca os preços disponíveis para quantidade da regra fiscal informada   			
			aRetPrc  := OGAX721FAT(cFilOrg, __cCodCtr, __cItemCtr, __cRegFis, 0, nPesoNJM, 0, cCodClient, cCodLoja, "F")
			__aPrecos  := aRetPrc[1][4]
			__nXPrecos := 1
								
			// Se possui quebra por preço, quebra a NJM
			If Len(__aPrecos) > 1													
				// Efetua a quebra por preço na NJM		
				If !QuebraNJM(3, , , , , cFilRom, @aFldNJM[nIt], nPesoNJJ, @aFldNJM, @nItRom)
					lRet := .F.
				EndIf				
			EndIf
			
		Next nIt	
	
	EndIf  

	// Quando possui excedente para grãos
	If nPesoRom > 0 .AND. lRet .AND. nTpProd == 1

		// Pega o último registro inserido na NJM
		aItNJM := aFldNJM[Len(aFldNJM)]

		// Busca a posição do campo NJM_FILORG no array
		nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_FILORG"})			
		cFilOrg := aItNJM[nPos][2]

		// Busca a posição do campo NJM_CODCTR no array
		nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODCTR"})			
		__cCodCtr := aItNJM[nPos][2]		

		// Verifica se o contrato permite excedente
		If !VerExcCtr(cFilOrg, __cCodCtr, nPesoRom)
			lRet := .F.
		Else		
			// Busca a posição do campo NJM_SUBTIP no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SUBTIP"})
			If 	nPos > 0
				cSubTip := aItNJM[nPos][2]
			EndIf
			
			// Busca a posição do campo NJM_ITEM no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_ITEM"})			
			cItEtg := aItNJM[nPos][2]	

			// Busca a posição do campo NJM_SEQPRI no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQPRI"})			
			cItRef := aItNJM[nPos][2]

			// Busca a posição do campo NJM_CODINE no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODINE"})			
			cCodIE := aItNJM[nPos][2]

			If cSubTip $ "44|52" // (S) REMESSA POR VENDA/COMPRA FUTURA

				// Verifica o excedente na Remessa por Venda Futura
				If !VerExcRom(nTpProd, @aFldNJM, aItNJM, @nItRom, cFilRom, cCodRom, nPesoNJJ, cFilOrg, cCodIE, __cCodCtr, cItEtg, cItRef, nPesoRom, nValorUnit, cSerNFP, cNumNFP, cLote, .T.)
					lRet := .F.
				EndIf																																	
			Else		
				// Verifica o excedente para outras operações
				If !VerExcRom(nTpProd, @aFldNJM, aItNJM, @nItRom, cFilRom, cCodRom, nPesoNJJ, cFilOrg, cCodIE, __cCodCtr, cItEtg, cItRef, nPesoRom, nValorUnit, cSerNFP, cNumNFP, cLote, .F.)
					lRet := .F.
				EndIf					
			EndIf
		EndIf		
	EndIf	

	If lRet	
		OG250DGNJM(aFldNJM, cFilRom, cCodRom)									
	EndIf

Return lRet

/** {Protheus.doc} OG250DIES
Retorna as instruções de embarque da N9E (Integrações do Romaneio) do Romaneio

@return:	Nil
@author: 	franciso.nunes / vanilda.moggio
@since: 	13/04/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, Filial do Romaneio
@param cCodRom, character, Código do Romaneio
*/
Function OG250DIES(cFilRom, cCodRom)

	Local cAliasQry	:= ""
	Local cQry		:= ""
	Local aIES		:= {}

	cAliasQry := GetNextAlias()
	cQry := " SELECT DISTINCT N9E.N9E_CODINE "
	cQry += " FROM " + RetSqlName("N9E") + " N9E "
	cQry += " WHERE N9E.N9E_FILIAL = '" + cFilRom + "' "
	cQry += "   AND N9E.N9E_CODROM = '" + cCodRom + "' "
	cQry += "   AND N9E.N9E_CODINE <> '' "
	cQry += "   AND N9E.D_E_L_E_T_ = '' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())

		Aadd(aIES, (cAliasQry)->N9E_CODINE)

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Return aIES

/** {Protheus.doc} OG250DRFs
Retorna os contratos com as regras fiscais(comercialização) do Romaneio

@return:	Nil
@author: 	claudineia.reinert	
@since: 	06/06/2020
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, Filial do Romaneio
@param cCodRom, character, Código do Romaneio
*/
Function OG250DRFs(cFilRom, cCodRom)

	Local cAliasQry	:= ""
	Local cQry		:= ""
	Local aRegFis		:= {}

	cAliasQry := GetNextAlias()
	cQry := " SELECT NJM.NJM_CODCTR, NJM_ITEM, NJM_SEQPRI "
	cQry += " FROM " + RetSqlName("NJM") + " NJM "
	cQry += " WHERE NJM.NJM_FILIAL = '" + cFilRom + "' "
	cQry += "   AND NJM.NJM_CODROM = '" + cCodRom + "' "
	cQry += "   AND NJM.D_E_L_E_T_ = '' "
	cQry += "   GROUP BY NJM.NJM_CODCTR, NJM_ITEM, NJM_SEQPRI " //PODE TER NJM DUPLICADA, PRINCIPALMENTE SE REABRIR ROMANEIO
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())

		Aadd(aRegFis, {(cAliasQry)->NJM_CODCTR,(cAliasQry)->NJM_ITEM, (cAliasQry)->NJM_SEQPRI})

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Return aRegFis

/** {Protheus.doc} ConsumCtr
Consulta / Inclui peso consumido do contrato de acordo com a NJM a ser criada

@return:	Nil
@author: 	franciso.nunes
@since: 	12/04/2018
@Uso: 		OGA250 - Romaneio
@param nOper, number, 1 - Inclusão, 2 - Consulta
@param cChaveCtr, character, Chave do contrato (Filial + Código)
@param nPesoCons, number, Peso consumido do contrato na NJM (Somente enviado quando operação = 1 - Inclusão)
*/
Static Function ConsumCtr(nOper, cChaveCtr, nPesoCons)

	Local nPos     := 0
	Local nQtdCons := 0

	nPos := aScan(__aCtrs, {|x| AllTrim(x[1]) == AllTrim(cChaveCtr)})

	If nOper = 1 // Inclusão		
		If 	nPos > 0
			__aCtrs[nPos][2] += nPesoCons
		Else
			aAdd(__aCtrs, {cChaveCtr, nPesoCons})			
		EndIf		
	Else // Consulta
		If nPos > 0
			nQtdCons := __aCtrs[nPos][2]
		EndIf
	EndIf	

Return nQtdCons

/** {Protheus.doc} ConsPsNJM
Consome o peso no item (NJM) passado por parâmetro

@return:	Nil
@author: 	franciso.nunes
@since: 	12/04/2018
@Uso: 		OGA250 - Romaneio
@param aItNJM, array, Item da NJM que será atualizado para ascrescentar a quantidade excedente
@param nPesoCons, number, Peso a ser consumido
@param nPesoRom, number, Peso Total do Romaneio (Utilizado para cálculo do Percentual de Divisão da NJM)
*/
Static Function ConsPsNJM(aItNJM, nPesoCons, nPesoRom)

	Local nPos     := 0
	Local nPesoNJM := 0
	Local cFilCtr  := ""
	Local cCodCtr  := ""
	Local cItPrev  := ""
	Local cItRef   := ""

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_QTDFIS"})

	aItNJM[nPos][2] := aItNJM[nPos][2] + nPesoCons

	// Busca a posição do campo NJM_QTDFCO no array 
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_QTDFCO"})

	aItNJM[nPos][2] := aItNJM[nPos][2] + nPesoCons		

	nPesoNJM := aItNJM[nPos][2]				

	// Busca a posição do campo NJM_PERDIV no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_PERDIV"})

	aItNJM[nPos][2] :=  (nPesoNJM / nPesoRom * 100)

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_FILORG"})
	cFilCtr := aItNJM[nPos][2]

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODCTR"})
	cCodCtr := aItNJM[nPos][2]

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_ITEM"})
	cItPrev := aItNJM[nPos][2]

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQPRI"})
	cItRef := aItNJM[nPos][2]

	// Grava o consumo da NJM em um array por Filial + Contrato + Prev. Entrega + Regra Fiscal		
	ConsSldRef(cFilCtr+cCodCtr+cItPrev+cItRef, nPesoCons, .T.)

Return .T.

/** {Protheus.doc} VerExcRom
Verifica excedente do romaneio

@return:	Nil
@author: 	franciso.nunes
@since: 	23/04/2018
@Uso: 		OGA250 - Romaneio
@param nTpProd, number, Tipo de produto: 1 - Grãos; 2 - Algodão
@param aFldNJM, array, Array com todas as NJMs para realizar a criação de um novo item (NJM)
@param aItNJM, array, Item da NJM que será atualizado para copiar e criar a NJM excedente
@param nItRom, number, sequencial da NJM (Utilizado para informar o campo NJM_ITEROM)
@param cFilRom, character, Filial do Romaneio
@param cCodRom, character, Código do Romaneio
@param nPesoRom, number, Peso Total do Romaneio (Utilizado para cálculo do Percentual de Divisão da NJM)
@param cFilOrg, character, Filial do Contrato/Instrução de embarque
@param cCodIE, character, Código da Instrução de Embarque
@param cCodCtr, character, Código do contrato
@param cItEtg, character, Item da previsão de entrega do contrato
@param cItRef, character, Item da regra fiscal do contrato
@param nPsCons, character, Peso a ser consumido pela regra fiscal
@param nValorUnit, number, valor unitário do romaneio
@param cSerNFP, character, Série da NFP do Romaneio
@param cNumNFP, character, Número da NFP do Romaneio
@param cLote, character, lote dos produtos não controlados por fardos
@param lExcVF, boolean, .T. - Excedente Venda Futura; Excedente Normal

*/
Static Function VerExcRom(nTpProd, aFldNJM, aItNJM, nItRom, cFilRom, cCodRom, nPesoRom, cFilOrg, cCodIE, cCodCtr, cItEtg, cItRef, nPsCons, nValorUnit, cSerNFP, cNumNFP, cLote, lExcVF,aDadosNF)

	Local nPesoExc  := 0 // Peso excedente da regra fiscal
	Local nPos	   	:= 0
	Local nPsRefNJM := 0 // Peso já consumido na NJM no romaneio atual
	Local nSldNF    := 0
	Local cCodRef	:= ""
	Local nSldRef	:= 0
	Local cTESRef   := ""	
	Local lRefExc	:= .F. 
	Local lRet		:= .T.
	Local nSldIE    := 0
	Local lUsaIE	:= IIF( Empty(cCodIE) , .F. , .T. )
	Local aRetN9A 	:= {}
	Local cTpForm 	:= "1"
	Local cTESURF 	:= "" //TES da ultima regra fiscal que gerou o excedente
	Local cTipoRom 	:= "4" //Tipo do romaneio

	Default aDadosNF := {} 

	// Busca o saldo de NF / IE da regra fiscal				
	nSldNF := Posicione("N9A",1,cFilOrg+cCodCtr+cItEtg+cItRef,"N9A->N9A_SDONF")
	nSldIE := Posicione("N9A",1,cFilOrg+cCodCtr+cItEtg+cItRef,"N9A->N9A_SDOINS")

	// Verifica o peso já consumido da regra fiscal na NJM no romaneio atual
	nPos := aScan(__aItRefs, {|x| AllTrim(x[1]) == AllTrim(cFilOrg+cCodCtr+cItEtg+cItRef)})			
	If nPos > 0
		nPsRefNJM := __aItRefs[nPos][2]
	EndIf	

	nPesoExc := 0

	// Verifica se o saldo da regra fiscal - (Quantidade da NJM para regra fiscal + Quantidade a consumir) é menor que 0
	If nSldNF - (nPsRefNJM + nPsCons) < 0
		// Caso seja, atribui a variável aquilo que foi excedido
		nPesoExc := (nSldNF - (nPsRefNJM + nPsCons)) * -1
	EndIf
	
	If nPsCons - nPesoExc > 0
		nPsCons := nPsCons - nPesoExc
		
		// Verifica se a ser consumido na mesma regra fiscal ultrapassa o saldo a instruir da regra fiscal quando usa IE ou o saldo da NF quando não usa IE
		If lUsaIE .and. nPsCons > nSldIE  
			nPsCons  := nSldIE
			nPesoExc := nPesoExc + (nPsCons - nSldIE)
		ElseIf !lUsaIE .and. nPsCons > nSldNF  
			nPsCons  := nSldNF
			nPesoExc := nPesoExc + (nPsCons - nSldNF)
		EndIf

		ConsPsNJM(@aItNJM, nPsCons, nPesoRom)	
		
		If nTpProd = 1 // Apenas para grãos	 
			If lUsaIE .and. !GrvRefIE(cFilOrg, cCodIE, cCodCtr, cItEtg, cItRef, nPsCons)
				lRet := .F.
			EndIf
		EndIf
			
	EndIf

	If nPesoExc > 0	.AND. lRet	
		While nPesoExc > 0
			// Retorna dados da regra Fiscal para consumir o valor excedente
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_TES"})
			cTESURF := aItNJM[nPos][2]
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_TPFORM"})
			cTpForm := aItNJM[nPos][2]	
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_TIPO"})
			cTipoRom := aItNJM[nPos][2]						
			
			aRetN9A := OG250DRN9A(cFilOrg, cCodCtr, @cItEtg, cFilRom, 2, nTpProd, lExcVF,lUsaIE,cTpForm,cTESURF)

			cCodRef := aRetN9A[1]			
			cTESRef := aRetN9A[2]					
			lRefExc	:= aRetN9A[4]		

			If (Empty(cTESRef) .AND. lExcVF) 
				Agrhelp(STR0002,STR0006 + STR0017 + cCodCtr + ".",STR0018) //##"Contrato sem regra fiscal para excedente de operação futura. "##" Contrato: "##"No contrato é necessario ter uma regra fiscal para o excedente da operação futura. Se o romaneio for com formulário próprio igual a NÃO, será necessário que a TES seja a mesma da remessa da operação futura."
				lRet := .F.
				EXIT
			ElseIf !lExcVF .AND. Empty(cCodRef)
				
				// Caso não encontra outra regra fiscal, utiliza a última regra fiscal do romaneio para consumir o excedente
				ConsPsNJM(@aItNJM, nPesoExc, nPesoRom)	
				
				nSldRef := nPesoExc
		
				If  nTpProd = 1 // Apenas para grãos	
					If lUsaIE .and. !GrvRefIE(cFilOrg, cCodIE, cCodCtr, cItEtg, cItRef, nPesoExc)
						lRet := .F.
						EXIT
					EndIf
				EndIf
				
			Else
				If nTpProd = 1 .AND. !lRefExc // Grãos e NÃO é a regra fiscal excedente				
										
					nSldRef := aRetN9A[3]
	
					If nPesoExc < nSldRef 
						nSldRef := nPesoExc
					EndIf
				Else
					nSldRef := nPesoExc
				EndIf
			

				If lRefExc				
					// Caso a regra fiscal selecionada seja excedente (quantidade zerada)			
					CriaExcVF(@aFldNJM, aItNJM, @nItRom, cTESRef, nSldRef, cFilRom, cCodRom, nPesoRom)				
				ElseIf  nTpProd = 1 // Apenas para grãos	
					If lUsaIE .and. !GrvRefIE(cFilOrg, cCodIE, cCodCtr, cItEtg, cCodRef, nSldRef)
						lRet := .F.
						EXIT
					EndIf
					
					If cTipoRom == "4"
						If !OG250DCNJM(@nItRom, @aFldNJM, cFilRom, cCodRom, cFilOrg, cCodIE, cCodCtr, cItEtg, cCodRef, nSldRef, nPesoRom, nValorUnit, '', '', '', '', cSerNFP, cNumNFP, 4, '40', '4', .F., cLote)
							lRet := .F.
							EXIT
						EndIf
					ElseIf cTipoRom == "5"
						If cTpForm == "2"
							aDadosNF[7] := nSldRef //PESO FISCAL
							aDadosNF[5] := ROUND( (aDadosNF[6] * aDadosNF[7]) , TamSX3( "NJM_VLRTOT" )[2] ) //VALOR TOTAL
						EndIf
						If !OG250DCNJM(@nItRom, @aFldNJM, cFilRom, cCodRom, cFilOrg, cCodIE, cCodCtr, cItEtg, cCodRef, nSldRef, nPesoRom, nValorUnit, '', '', '', '', cSerNFP, cNumNFP, 4, '50', '5', .F., cLote,aDadosNF)
							lRet := .F.
							EXIT
						EndIf
					EndIf	

					// Busca o último item da NJM 
					aItNJM := aFldNJM[Len(aFldNJM)]							
				EndIf
				// Grava o consumo da NJM em um array por Filial + Contrato + Prev. Entrega + Regra Fiscal	
				ConsSldRef(cFilOrg+cCodCtr+cItEtg+cCodRef, nSldRef, .T.)
			EndIf		
			nPesoExc := nPesoExc - nSldRef
		EndDo			
	EndIf	

Return lRet

/** {Protheus.doc} GrvRefIE
Grava a regra fiscal na Instrução de Embarque

@return:	Nil
@author: 	franciso.nunes
@since: 	24/04/2018
@Uso: 		OGA250 - Romaneio
@param cFilIE, character, Filial da instrução de embarque
@param cCodIE, character, Código da instrução de embarque
@param cCodCtr, character, Código do contrato
@param cItEtg, character, Item da previsão de entrega
@param cCodRef, character, Item da regra fiscal
@param nPesoCons, number, Peso consumido da regra fiscal

*/
Static Function GrvRefIE(cFilIE, cCodIE, cCodCtr, cItEtg, cCodRef, nPesoCons)

	Local aAreaN9A := N9A->(GetArea())
	Local aAreaN7S := N7S->(GetArea())

	DbSelectArea("N9A")
	N9A->(DbSetOrder(1)) // N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
	If !N9A->(DbSeek(cFilIE+cCodCtr+cItEtg+cCodRef))
		Return .F.
	EndIf

	DbSelectArea("N7S")
	N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
	If N7S->(DbSeek(cFilIE+cCodIE+cCodCtr+cItEtg+cCodRef))
		If RecLock("N7S", .F.)
			N7S->N7S_QTDVIN := N7S->N7S_QTDVIN + nPesoCons

			N7S->(MsUnLock())
		EndIf
	Else
		If RecLock("N7S", .T.)
			N7S->N7S_FILIAL := cFilIE
			N7S->N7S_CODINE := cCodIE
			N7S->N7S_CODCTR := cCodCtr
			N7S->N7S_ITEM   := cItEtg
			N7S->N7S_SEQPRI := cCodRef
			N7S->N7S_QTDVIN := nPesoCons
			N7S->N7S_DATINI := Posicione("NNY",1,xFilial("NNY")+N7S->N7S_CODCTR+N7S->N7S_ITEM,"NNY_DATINI")
			N7S->N7S_DATFIM := Posicione("NNY",1,xFilial("NNY")+N7S->N7S_CODCTR+N7S->N7S_ITEM,"NNY_DATFIM") 
			N7S->N7S_CODFIN := N9A->N9A_CODFIN
			N7S->N7S_OPEFIS := N9A->N9A_OPEFIS
			N7S->N7S_FILORG := N9A->N9A_FILORG
			N7S->N7S_TES    := IIf(N9A->N9A_OPEFUT == "1", N9A->N9A_TESAUX, N9A->N9A_TES)
			N7S->N7S_CTREXT := Posicione("NJR",1,xFilial("NJR")+N7S->N7S_CODCTR,'NJR_CTREXT')
			N7S->N7S_GENMOD := Posicione("NJR",1,FwxFilial("NJR")+N7S->N7S_CODCTR,'NJR_GENMOD')
			N7S->N7S_INCAUT := "1" // Inclusão Automática

			N7S->(MsUnLock())
		EndIf						
	EndIf

	If RecLock("N9A", .F.)
		N9A->N9A_QTDINS := N9A->N9A_QTDINS + nPesoCons
		N9A->N9A_SDOINS := N9A->N9A_QUANT - N9A->N9A_QTDINS

		N9A->(MsUnLock())
	EndIf

	DbSelectArea("N7Q")
	N7Q->(DbSetOrder(1)) // N7Q_FILIAL+N7Q_CODINE
	If N7Q->(DbSeek(cFilIE+cCodIE))
		If RecLock("N7Q", .F.)
			N7Q->N7Q_TOTLIQ := N7Q->N7Q_TOTLIQ + nPesoCons
			N7Q->N7Q_TOTBRU := N7Q->N7Q_TOTBRU + nPesoCons

			N7Q->(MsUnLock())
		EndIf
	EndIf

	RestArea(aAreaN9A)
	RestArea(aAreaN7S)

Return .T.

/** {Protheus.doc} AtuRefIE
Atualiza/Deleta a regra fiscal na Instrução de Embarque (Apenas as automáticas)

@return:	Nil
@author: 	franciso.nunes
@since: 	24/04/2018
@Uso: 		OGA250 - Romaneio
@param cFilIE, character, Filial da instrução de embarque
@param cCodIE, character, Código da instrução de embarque
@param cCodCtr, character, Código do contrato
@param cItEtg, character, Item da previsão de entrega
@param cCodRef, character, Item da regra fiscal
@param nPesoCons, number, Peso consumido da regra fiscal

*/
Static Function AtuRefIE(cFilIE, cCodIE, cCodCtr, cItEtg, cCodRef, nPesoCons)

	DbSelectArea("N7S")
	N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
	If N7S->(DbSeek(cFilIE+cCodIE+cCodCtr+cItEtg+cCodRef))		
		If RecLock("N7S", .F.)				
			If N7S->N7S_QTDVIN - nPesoCons > 0
				N7S->N7S_QTDVIN := N7S->N7S_QTDVIN - nPesoCons				
			Else
				N7S->(DbDelete())
			EndIf	

			N7S->(MsUnLock())
		EndIf
	EndIf

	DbSelectArea("N9A")
	N9A->(DbSetOrder(1)) // N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
	If N9A->(DbSeek(cFilIE+cCodCtr+cItEtg+cCodRef))
		If RecLock("N9A", .F.)
			N9A->N9A_QTDINS := N9A->N9A_QTDINS - nPesoCons
			N9A->N9A_SDOINS := N9A->N9A_QUANT - N9A->N9A_QTDINS

			N9A->(MsUnLock())			
		EndIf
	EndIf

	DbSelectArea("N7Q")
	N7Q->(DbSetOrder(1)) // N7Q_FILIAL+N7Q_CODINE
	If N7Q->(DbSeek(cFilIE+cCodIE))
		If RecLock("N7Q", .F.)
			N7Q->N7Q_TOTLIQ := N7Q->N7Q_TOTLIQ - nPesoCons
			N7Q->N7Q_TOTBRU := N7Q->N7Q_TOTBRU - nPesoCons

			N7Q->(MsUnLock())
		EndIf
	EndIf

Return .T.

/** {Protheus.doc} CriaExcVF
Criar uma nova NJM para Saída por Venda Excedente

@return:	Nil
@author: 	franciso.nunes
@since: 	12/04/2018
@Uso: 		OGA250 - Romaneio
@param aFldNJM, array, Array com todas as NJMs para realizar a criação de um novo item (NJM)
@param aItNJM, array, Item da NJM que será atualizado para copiar e criar a NJM excedente
@param nItRom, number, sequencial da NJM (Utilizado para informar o campo NJM_ )
@param cTESExc, character, TES para Saída por Venda utilizada na nova NJM Excedente
@param nPesExc, number, Peso Excedente
@param cFilRom, character, Filial do Romaneio
@param cCodRom, character, Código do Romaneio
@param nPesoRom, number, Peso Total do Romaneio (Utilizado para cálculo do Percentual de Divisão da NJM)

*/
Static Function CriaExcVF(aFldNJM, aItNJM, nItRom, cTESExc, nPesExc, cFilRom, cCodRom, nPesoRom)

	Local aNJMExc  := {}
	Local nPos	   := 0
	Local nPesoNJM := 0
	Local cTpRom   := '' 

	// Cria uma cópia do último registro (Remessa por Venda Futura) e modifica a TES, o subtipo e os pesos	
	aNJMExc := AClone(aItNJM)

	// Busca a posição do campo NJM_ITEROM no array
	nPos := aScan(aNJMExc, {|x| AllTrim(x[1]) == "NJM_TIPO"})			
	cTpRom := aNJMExc[nPos][2] 

	nItRom++
	// Busca a posição do campo NJM_ITEROM no array
	nPos := aScan(aNJMExc, {|x| AllTrim(x[1]) == "NJM_ITEROM"})			
	aNJMExc[nPos][2] := StrZero(nItRom,2)

	// Busca a posição do campo NJM_TES no array
	nPos := aScan(aNJMExc, {|x| AllTrim(x[1]) == "NJM_TES"})			
	aNJMExc[nPos][2] := cTESExc

	// Busca a posição do campo NJM_SUBTIP no array
	nPos := aScan(aNJMExc, {|x| AllTrim(x[1]) == "NJM_SUBTIP"})	
	If cTpRom == "4"		
		aNJMExc[nPos][2] := '49' // (S) Saída por Venda Futura Excedente
	ElseIf cTpRom == "5"
		aNJMExc[nPos][2] := '57' // (E) Excedente por Venda Futura
	EndIf

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aNJMExc, {|x| AllTrim(x[1]) == "NJM_QTDFIS"})

	aNJMExc[nPos][2] := nPesExc

	// Busca a posição do campo NJM_QTDFCO no array 
	nPos := aScan(aNJMExc, {|x| AllTrim(x[1]) == "NJM_QTDFCO"})

	aNJMExc[nPos][2] := nPesExc		

	nPesoNJM := aNJMExc[nPos][2]				

	// Busca a posição do campo NJM_PERDIV no array
	nPos := aScan(aNJMExc, {|x| AllTrim(x[1]) == "NJM_PERDIV"})

	aNJMExc[nPos][2] :=  (nPesoNJM / nPesoRom * 100)

	aAdd(aFldNJM, aNJMExc)

	// Informa a quantidade excedente nos fardos até zerar (Os mesmo serão utilizados na geração do Pedido/Nota Fiscal)
	// Os fardos com valores excedentes serão considerados no pedido/nota fiscal da NJM de Saída por Venda Excedente
	// E o valor excedente dos mesmo será descontado do valor no pedido/nota fiscal da NJM de Remessa Venda Futura
	DbSelectArea("N9D")
	N9D->(DbSetOrder(6)) // N9D_FILORG+N9D_CODROM+N9D_TIPMOV											
	If N9D->(DbSeek(cFilRom+cCodRom+"07"))
		While !N9D->(Eof()) .AND. N9D->(N9D_FILORG+N9D_CODROM+N9D_TIPMOV+N9D_STATUS) == cFilRom+cCodRom+"07"+"2"														
			If nPesExc = 0
				EXIT
			EndIf

			If Reclock("N9D",.F.)
				If nPesExc > N9D->N9D_PESFIM
					N9D->N9D_PESEXC := N9D->N9D_PESFIM
				Else
					N9D->N9D_PESEXC := nPesExc
				EndIf
				N9D->(MsUnLock())
			EndIf

			nPesExc := nPesExc - N9D->N9D_PESEXC								

			N9D->(DbSkip())
		EndDo
	EndIf			

Return .T.

/** {Protheus.doc} QuebraNJM
Realiza a quebra da NJM para as seguintes situações:
nOpc = 1 - Seleção das regras fiscais de armazenagem em 3 na Remessa Formação de Lote
nOpc = 2 - por lote, seleção por fifo
@return:	Nil
@author: 	franciso.nunes
@since: 	19/04/2018
@Uso: 		OGA250 - Romaneio
@param nOpc, number, 1 - Quebra por regra fiscal de armazenagem
@param cCodEnt, character, Código da entidade do romaneio
@param cLojEnt, character, Código do loja da entidade do romaneio
@param cSafra, character, Código da safra do romaneio
@param cProd, character, Código do produto do romaneio
@param cFilRom, character, Filial do romaneio
@param aItNJM, array, Item da NJM corretente (que será editado)
@param nPesoRom, number, Peso do Romaneio (NJJ)
@param aFldNJM, array, Array de itens da NJM
@param nItRom, number, item do romaneio (sequencial)

*/
Function QuebraNJM(nOpc, cCodEnt, cLojEnt, cSafra, cProd, cFilRom, aItNJM, nPesoRom, aFldNJM, nItRom, cLocal)

	Local aContr    := {}	
	Local nPos	    := 0
	Local nPesoNJM  := 0
	Local nPesoDif  := 0
	Local nVlrUnit  := 0
	Local aItRomDif := {}
	Local cFilCtr	:= ""
	Local cLote     := ""
	Local cSubTipo  := ""
	Local cChavLot  := ""
	Local nPsFardos := 0
	Local cPosSafraLot := SuperGetMv('MV_AGRO028', , .F.) //posicionamento da safra dentro do lote
	Local nIniSafLot := VAL(SubStr( cPosSafraLot, 1, 1 )) //posição inicial da safra dentro do lote
	Local nTamSafLot := VAL(SubStr( cPosSafraLot, 2, 1 )) //tamanho da safra dentro do lote
	Local cSafLote	 := '' //armazena a safra do lote confirme posição do parametro
	Local cDriver	:= Nil
	Local cAliasSB8 := Nil
	
	Default cLocal := ""

	If ProcName(1) =  "OGA250LOT" .AND. IsInCallStack("OGA250G") 
		//verifica se a função anterior a chamada da função QuebraNJM é a função OGA250LOT que é chamada pela função OGA250G(confirma romaneio)
		__aItRefs := {} //zera array
	EndIf

	If nOpc = 1 //  Quebra por regra fiscal de armazenagem	
		If __nPsItRef == 0 
			//seleciona o contrato para NJM
			If .not. SelCtrNJM(cCodEnt, cLojEnt, cSafra, cProd, cFilRom, __aItRefs,@aContr)
				Return .F.
			EndIf
			__cCodCtr  := aContr[1]
			__cItemCtr := aContr[2]
			__cRegFis  := aContr[3]
			__cTESRef  := aContr[4]
			__nPsItRef := aContr[5]	

			If !Empty(aContr[1]) .and. AGRTPALGOD(cProd) //se foi selecionado o contrato e for produto algodão
				//irá ajustar o contrato na N9D e o peso para a NJM conforme fardo selecionados abaixo 
				DbSelectArea( "N9D" )
				While Len(_aFrdRom) > 0
					If __nPsItRef < _aFrdRom[1][2] //se o contrato selecionado não possui saldo suficiente para um fardo
						Agrhelp(STR0002,STR0010,STR0026) //## Regra fiscal selecionada não possui saldo suficiente para apropriar o romaneio, selecione outra regra fiscal ##"Verifique a quantidade de fardos vinculados ou vincule um novo contrato ao romaneio."
						//chama tela para selecionar outro contrato que tenha saldo
						If .not. SelCtrNJM(cCodEnt, cLojEnt, cSafra, cProd, cFilRom, __aItRefs,@aContr)
							Return .F. //não foi selecionado, mas cancelado a tela
						EndIf
						__cCodCtr  := aContr[1]
						__cItemCtr := aContr[2]
						__cRegFis  := aContr[3]
						__cTESRef  := aContr[4]
						__nPsItRef := aContr[5]	
					ElseIf __nPsItRef < (nPsFardos + _aFrdRom[1][2]) 
						exit //sai do while pois ja atingiu qtd de fardos para a NJM
					Else
						nPsFardos += _aFrdRom[1][2]
						N9D->(dbGoto(_aFrdRom[1][1]))
						If N9D->( !Eof() )						
							//ajusta contrato de remessa para o fardo na N9D, o _aFrdRom ja esta com o rateio do peso do romaneio neste ponto
							RecLock( "N9D", .F. ) 
							N9D->N9D_CODCTR := __cCodCtr
							N9D->N9D_ITEETG := __cItemCtr
							N9D->N9D_ITEREF := __cRegFis
							N9D->N9D_ITEROM := cValToChar(STRZERO(nItRom,TamSX3( "NJM_ITEROM" )[1])) //cValToChar(nItRom)
							N9D->N9D_TIPOPE := '21' //REMESSA FORMAÇÃO DE LOTE
							N9D->(MsUnLock())
						EndIf
						aDel(_aFrdRom,1) //elimina o elemento do array deixando a posição igual a nil
						aSize(_aFrdRom, (Len(_aFrdRom) - 1) ) //redimensiona o tamanho para não ter posições com nil
					EndIf
				EndDo
				__nPsItRef := nPsFardos //peso para a NJM será o peso dos fardos
			EndIf	
		EndIf

		// Busca a posição do campo NJM_CODCTR no array
		nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_CODCTR"})			
		aItNJM[nPos][2] := __cCodCtr

		// Busca a posição do campo NJM_ITEM no array
		nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_ITEM"})			
		aItNJM[nPos][2] := __cItemCtr

		// Busca a posição do campo NJM_SEQPRI no array
		nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQPRI"})			
		aItNJM[nPos][2] := __cRegFis

		// Busca a posição do campo NJM_TES no array
		nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_TES"})			
		aItNJM[nPos][2] := __cTESRef

		// Busca a posição do campo NJM_FILORG no array
		nPos 	:= aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_FILORG"})
		cFilCtr := aItNJM[nPos][2]

		DbSelectArea("NJR")
		NJR->(DbSetOrder(1))
		If !DbSeek(cFilCtr+__cCodCtr)  
			Return .F.
		EndIf

		// Busca a posição do campo NJM_UM1PRO no array
		nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_UM1PRO"})			
		aItNJM[nPos][2] := NJR->NJR_UM1PRO
	ElseIf nOpc = 2 //Quebra Lote 
		cLote    := ""
		cChavLot := ""

		If __nPsItRef = 0

			//Reset das Variáveis
			__cLoteQNJM  := ""
			__cSubLtQNJM := ""
			__cDtValQNJM := ""
			__cKeyQNJM   := ""
		
			cAliasSB8 	:= GetNextAlias()
			cQry := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_SALDO, B8_DTVALID, B8_EMPENHO, B8_LOTECTL, B8_NUMLOTE"
			cQry += "   FROM " + RetSqlName('SB8')
			cQry += "  WHERE B8_FILIAL  = '" + cFilRom + "'"
			cQry += "    AND B8_PRODUTO  = '" + cProd + "'"
			cQry += "    AND B8_LOCAL  = '" + cLocal + "'"
			cQry += "    AND D_E_L_E_T_  = ' ' "
			
			If cDriver = 'ORACLE'
				cQry += " AND TO_CHAR(B8_DTVALID)    >= '" + Dtos(dDataBase) 	+ "'	"
			Else
				cQry += " AND B8_DTVALID    >= '" + Dtos(dDataBase) 	+ "'	"
			Endif
			
			cQry += "    AND (B8_SALDO - B8_EMPENHO) > 0
			
			cQry := ChangeQuery( cQry )	
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasSB8, .F., .T. )
		
			dbSelectArea(cAliasSB8)
			(cAliasSB8)->(dbGoTop())
			While (cAliasSB8)->(!Eof())
		
				cSafLote := SUBSTR(AllTrim((cAliasSB8)->B8_LOTECTL),nIniSafLot,nTamSafLot)
			  	If nTamSafLot > 0 .AND. Alltrim(cSafLote) != Alltrim(cSafra) 
			  		//se esta setado posição da safra no lote e lote não tem a safra no seu conteudo
			  		(cAliasSB8)->(DbSkip())	
			  		LOOP //procura no proximo registro
			  	EndIf
				cChavLot := cFilRom + cProd + cLocal + (cAliasSB8)->B8_DTVALID + (cAliasSB8)->B8_LOTECTL + (cAliasSB8)->B8_NUMLOTE

				/*Verifica se o saldo foi consumido*/
				nPos := aScan(__aItRefs, {|x| AllTrim(x[1]) == AllTrim(cChavLot) })
				nPesoCons := 0
				If nPos > 0
					nPesoCons := __aItRefs[nPos][2]
				EndIf
				If nPesoCons >= (cAliasSB8)->B8_SALDO
					(cAliasSB8)->(DbSkip())
					LOOP	
				EndIf	

				cLote    := (cAliasSB8)->B8_LOTECTL
				cSubLote := (cAliasSB8)->B8_NUMLOTE
				cDtValid := (cAliasSB8)->B8_DTVALID
				__nPsItRef := (cAliasSB8)->B8_SALDO

				__cLoteQNJM  := (cAliasSB8)->B8_LOTECTL
                __cSubLtQNJM := (cAliasSB8)->B8_NUMLOTE
                __cDtValQNJM := (cAliasSB8)->B8_DTVALID
				__cKeyQNJM   := cChavLot

				(cAliasSB8)->(dbSkip())
			EndDo
			

			// Caso não encontrou saldo com lote, será apresentado mensagem para o usuário
			If Empty(cLote) .Or. Empty(cChavLot)
				Agrhelp(STR0002 , STR0008 + IIF(nTamSafLot > 0, STR0011,'') , STR0027 ) //## Não foi encontrado Lote com saldo para Produto que possui Rastro por Lote ##, e safra posicionada no lote conforme parametro MV_AGRO0028 ##
				Return .F. 				 				
			EndIf  

			// Busca a posição do campo NJM_LOTCTL no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_LOTCTL"})			
			If nPos > 0
				aItNJM[nPos][2] := cLote
			EndIF

			// Busca a posição do campo NJM_NMLOT no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_NMLOT"})			
			If nPos > 0
				aItNJM[nPos][2] := cSubLote
			EndIf
			(cAliasSB8)->(DbCloseArea())
		Else
			// Caso não encontrou saldo com lote, será apresentado mensagem para o usuário
			If Empty(__cLoteQNJM) .Or. Empty(__cKeyQNJM)
				Agrhelp(STR0002 , STR0008 + IIF(nTamSafLot > 0, STR0011,''), STR0027 ) //## Não foi encontrado Lote com saldo para Produto que possui Rastro por Lote ##, e safra posicionada no lote conforme parametro MV_AGRO0028 ## "Verifique o saldo do produto no estoque."
				Return .F. 				 				
			EndIf  

			// Busca a posição do campo NJM_LOTCTL no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_LOTCTL"})			
			If nPos > 0
				aItNJM[nPos][2] := __cLoteQNJM
			EndIF

			// Busca a posição do campo NJM_NMLOT no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_NMLOT"})			
			If nPos > 0
				aItNJM[nPos][2] := __cSubLtQNJM
			EndIf

			cLote    := __cLoteQNJM 
            cSubLote := __cSubLtQNJM
            cDtValid := __cDtValQNJM
			cChavLot := __cKeyQNJM  

		EndIF	
		
	ElseIf nOpc = 3 //Quebra Preço
		
		If __nXPrecos > 0 .AND. __nXPrecos <= Len(__aPrecos)
			__nPsItRef := __aPrecos[ __nXPrecos][3]
			nVlrUnit := __aPrecos[ __nXPrecos][2]
			
			// Busca a posição do campo NJM_LOTCTL no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_VLRUNI"})			
			If nPos > 0
				aItNJM[nPos][2] := nVlrUnit
			EndIf
			
			__nXPrecos++
		EndIf
	
	ElseIf nOpc = 4 //Quebra por DCO
	
		If __nXDCOs > 0 .AND. __nXDCOs <= Len(__aDCOs)
					
			cNumAvi  := __aDCOs[ __nXDCOs][1]
			cNumDCO  := __aDCOs[ __nXDCOs][2]
			cSeqDCO  := __aDCOs[ __nXDCOs][3]
			nVlrUnit := __aDCOs[ __nXDCOs][4]
			__nPsItRef := __aDCOs[ __nXDCOs][5]
			cSeqNLN  := __aDCOs[ __nXDCOs][6]
			
			// Busca a posição do campo NJM_VLRUNI no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_VLRUNI"})			
			If nPos > 0
				aItNJM[nPos][2] := nVlrUnit
			EndIf
			
			// Busca a posição do campo NJM_NUMAVI no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_NUMAVI"})			
			If nPos > 0
				aItNJM[nPos][2] := cNumAvi
			EndIf
			
			// Busca a posição do campo NJM_NUMDCO no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_NUMDCO"})			
			If nPos > 0
				aItNJM[nPos][2] := cNumDCO
			EndIf
			
			// Busca a posição do campo NJM_SEQDCO no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQDCO"})			
			If nPos > 0
				aItNJM[nPos][2] := cSeqDCO
			EndIf
			
			// Busca a posição do campo NJM_SEQNLN no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQNLN"})			
			If nPos > 0
				aItNJM[nPos][2] := cSeqNLN
			EndIf
			
			__nXDCOs++
		Else
		
			__nPsItRef := nPesoNJM
			
			// Busca a posição do campo NJM_NUMAVI no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_NUMAVI"})			
			If nPos > 0
				aItNJM[nPos][2] := ""
			EndIf
			
			// Busca a posição do campo NJM_NUMDCO no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_NUMDCO"})			
			If nPos > 0
				aItNJM[nPos][2] := ""
			EndIf
			
			// Busca a posição do campo NJM_SEQDCO no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQDCO"})			
			If nPos > 0
				aItNJM[nPos][2] := ""
			EndIf
			
			// Busca a posição do campo NJM_SEQNLN no array
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SEQNLN"})			
			If nPos > 0
				aItNJM[nPos][2] := ""
			EndIf
		
		EndIf
				
	EndIf

	// Busca a posição do campo NJM_VLRUNI no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_VLRUNI"})
	nVlrUnit := aItNJM[nPos][2]

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_SUBTIP"})
	cSubTipo := aItNJM[nPos][2]

	// Busca a posição do campo NJM_QTDFIS no array
	nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_QTDFIS"})
	nPesoNJM := aItNJM[nPos][2]
	
	If __nPsItRef > 0
	
		// Verifica se o peso da NJM corrente é maior que o saldo do regra fiscal
		If nPesoNJM > __nPsItRef
			// Caso o peso total da NJM ultrapasse o saldo da regra fiscal, irá  quebrar a NJM
			// A corrente fica com o valor restante do saldo e a quebra fica com a diferença do peso total da NJM - Saldo da regra fiscal	
			nPesoDif := nPesoNJM - __nPsItRef
	
			// Atualiza a quantidade NJM_QTDFIS
			aItNJM[nPos][2] := __nPsItRef
	
			// Busca a posição do campo NJM_QTDFCO no array e atualiza o campo
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_QTDFCO"})		
			aItNJM[nPos][2] := __nPsItRef				
			nPesoNJM := aItNJM[nPos][2]				
	
			// Busca a posição do campo NJM_VLRTOT no array e atualiza o campo
			nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_VLRTOT"})		
			aItNJM[nPos][2] := __nPsItRef	* nVlrUnit			
	
			// Busca a posição do campo NJM_PERDIV no array e atualiza o campo
			If !(cSubtipo == '46')
				nPos := aScan(aItNJM, {|x| AllTrim(x[1]) == "NJM_PERDIV"})		
				aItNJM[nPos][2] :=  (nPesoNJM / nPesoRom * 100)
			EndIf
	
			// Desconta o peso do romaneio do saldo da regra fiscal
			__nPsItRef := __nPsItRef - nPesoNJM
	
			// Inclui no array de contratos o peso da NJM para ter o controle do saldo que será consumido dos contratos
			If nOpc = 1
				ConsumCtr(1, cFilCtr+__cCodCtr, nPesoNJM)
			EndIf
	
			If nOpc = 1 // Apenas para quebra por regra fiscal de armazenagem
				// Grava o consumo da NJM em um array para não apresentar as regras fiscais com saldos consumidos			
				ConsSldRef(cFilCtr+__cCodCtr+__cItemCtr+__cRegFis, nPesoNJM, .T.)
			ElseIF nOpc = 2
				ConsSldRef(cChavLot, nPesoNJM, .T.)
			EndIf
	
			// Quebra da NJM e coloca o valor que sobrou do desconto da NJM anterior		
			aItRomDif := AClone(aItNJM)
	
			nItRom++
			// Busca a posição do campo NJM_ITEROM no array
			nPos := aScan(aItRomDif, {|x| AllTrim(x[1]) == "NJM_ITEROM"})
			aItRomDif[nPos][2] := StrZero(nItRom,2)
	
			// Busca a posição do campo NJM_QTDFIS no array
			nPos := aScan(aItRomDif, {|x| AllTrim(x[1]) == "NJM_QTDFIS"})	
			aItRomDif[nPos][2] := nPesoDif
	
			// Busca a posição do campo NJM_QTDFCO no array 
			nPos := aScan(aItRomDif, {|x| AllTrim(x[1]) == "NJM_QTDFCO"})		
			aItRomDif[nPos][2] := nPesoDif				
			nPesoNJM := aItRomDif[nPos][2]
	
			// Busca a posição do campo NJM_VLRTOT no array 
			nPos := aScan(aItRomDif, {|x| AllTrim(x[1]) == "NJM_VLRTOT"})		
			aItRomDif[nPos][2] := nPesoDif	* nVlrUnit			
	
			// Busca a posição do campo NJM_PERDIV no array
			If !(cSubtipo == '46')
				nPos := aScan(aItRomDif, {|x| AllTrim(x[1]) == "NJM_PERDIV"})		
				aItRomDif[nPos][2] :=  (nPesoNJM / nPesoRom * 100)
			EndIF
	
			aAdd(aFldNJM, aItRomDif)
	
	 		If !QuebraNJM(nOpc, cCodEnt, cLojEnt, cSafra, cProd, cFilRom, @aFldNJM[Len(aFldNJM)], nPesoRom, @aFldNJM, @nItRom, cLocal)
				Return .F.
			EndIf
		Else
			// Desconta o peso do romaneio do saldo da regra fiscal
			__nPsItRef := __nPsItRef - nPesoNJM
	
			// Inclui no array de contratos o peso da NJM para ter o controle do saldo que será consumido dos contratos
			ConsumCtr(1, cFilCtr+__cCodCtr, nPesoNJM)
	
			If nOpc = 1 // Apenas para quebra por regra fiscal de armazenagem
				// Grava o consumo da NJM em um array para não apresentar as regras fiscais com saldos consumidos
				ConsSldRef(cFilCtr+__cCodCtr+__cItemCtr+__cRegFis, nPesoNJM, .T.)
			ElseIF nOpc = 2
				ConsSldRef(cChavLot, nPesoNJM, .T.)
			EndIf
		EndIf
	EndIf
    
Return .T.

/** {Protheus.doc} ConsSldRef
Guarda em um array o consumo por chave (Filial+Contrato+Prev. Ent+Regra Fiscal) do valor da NJM

@return:	Nil
@author: 	franciso.nunes
@since: 	19/04/2018
@param cChaveRef, character, Chave da regra fiscal (Filial+Contrato+Prev. Ent+Regra Fiscal)
@param nPesoCons, number, Peso a ser consumido pelo chave na NJM
@param lSoma, .T. - Soma; .F. - Subtrai
*/
Static Function ConsSldRef(cChaveRef, nPesoCons, lSoma)

	Local nPos := 0

	nPos := aScan(__aItRefs, {|x| AllTrim(x[1]) == AllTrim(cChaveRef)})

	If 	nPos > 0
		If lSoma
			__aItRefs[nPos][2] := __aItRefs[nPos][2] + nPesoCons
		Else
			__aItRefs[nPos][2] := __aItRefs[nPos][2] - nPesoCons
		EndIf
	ElseIf lSoma
		aAdd(__aItRefs, {cChaveRef, nPesoCons})			
	EndIf		

Return .T.

/*{Protheus.doc} OG250DCNJM
Carrega o array de dados da NJM para geração do romaneio

@author francisco.nunes
@since 27/03/2018
@param nItRom, item do romaneio (Sequencial)
@param aFldNJM, array campos NJM
@param cFilRom, Filial do romaneio
@param cCodRom, Código do romaneio
@param cFilIE, Filial da Instrução de Embarque (Consideramos que seja a mesma do contrato)
@param cCodIne, Código da Instrução de Embarque
@param cCodCtr, codigo do contrato
@param cItemCtr, Entrega do contrato
@param cRegFis, Regra fiscal da entrega do contrato
@param nPeso, peso do item da comercialização (NJM)
@param nPesoNJJ, peso do romaneio (NJJ)
@param nPrecMed, peso unitário do romaneio
@param cCodEnt, Entidade de faturamento/entrega
@param cLojEnt, Loja da Entidade de faturamento/entrega
@param cLocal, Local de armazenagem
@param cIdMov, Id da Movimentação (OGA440)
@param cSerNFP, Série da NFP do Romaneio
@param cNumNFP, Número da NFP do Romaneio
@param nIndOp, Indica qual operação está gravando (1 - Venda Global, 2 - Mercado Externo, 3 - Devolução Exportação, 4 - Mercado Interno)
@param cTipoRom, Tipo do Romaneio
@param lRemVnd, .T. - Remessa Formação de Lote de IE de Venda
@param cLote, codigo do lote de produtos não controlados por fardos)
@type function
*/
Function OG250DCNJM(nItRom, aFldNJM, cFilRom, cCodRom, cFilIE, cCodIne, cCodCtr, cItemCtr, cRegFis, nPeso, nPesoNJJ, nPrecMed, cCodEnt, cLojEnt, cLocal, cIdMov, cSerNFP, cNumNFP, nIndOp, cSubTipo, cTipoRom, lRemVnd, cLote, aDadosNF)
	
	Local aAux      := {}
	Local aAreaNJR  := NJR->(GetArea()) 
	Local aAreaN9A  := N9A->(GetArea())
	Local aAreaN7Q  := N7Q->(GetArea())
	Local aAreaN7S  := N7S->(GetArea())		
	Local cTES		:= ""
	Local nTpProd	:= 1
	Local nPesoRVF	:= 0
	Local cLotFut 	:= ''
	Local cOpeFis 	:= ''
	Local lUsaIE	:= IIF( EMPTY(cCodIne) , .F. , .T. )
    Local aAreaNJM  := NJM->(GetArea())
  
	Default cSubTipo := ''
	Default cLote := ''
	Default cTipoRom := ""
	Default lRemVnd  := .F.	
    Default aDadosNF := {}

	If !lRemVnd
		DbSelectArea("NJR")
		NJR->(DbSetOrder(1))
		If !DbSeek(cFilIE+cCodCtr)  
			Return .F.
		EndIf

		DbSelectArea("N9A")
		N9A->(DbSetOrder(1))
		If !DbSeek(cFilIE+cCodCtr+cItemCtr+cRegFis)  
			Return .F.
		EndIf

		If nIndOp == 4 
			If N9A->N9A_OPEFUT = '1' .And. Empty(N9A->N9A_CODROM)  
				Agrhelp(STR0002 , STR0005, STR0028 ) //## Não foi gerado o Romaneio Global de Venda Futura. ##, e safra posicionada no lote conforme parametro MV_AGRO0028 ##"Efetue a geração do romaneio global futuro no cadastro de contratos"
				Return .F.
			Else
				cLotFut := Posicione("NJM",1,N9A->N9A_FILORG+N9A->N9A_CODROM+'01',"NJM->NJM_LOTCTL")                 
                RestArea(aAreaNJM)
			EndIf
		EndIf
	EndIf

	If lUsaIE
		If (nIndOp == 2 .Or. nIndOp == 3 .Or. nIndOp == 4) .AND. !lRemVnd			
			DbSelectArea("N7S")
			N7S->(DbSetOrder(1))
			If !DbSeek(cFilIE+cCodIne+cCodCtr+cItemCtr+cRegFis)  
				Return .F.
			EndIf
		EndIf	

		If nIndOp == 4 .OR. nIndOp == 2

			cLocal := "" //quando em branco Local será igual ao local da NJJ			
			
			DbSelectArea("N7Q") 
			N7Q->(DbSetOrder(1)) 
			If N7Q->(DbSeek(cFilIE+cCodIne))		
				If cTipoRom == "2" //remessa
					If NJR->NJR_TIPO == '4'
						cCodEnt := N7Q->N7Q_IMPORT
						cLojEnt := N7Q->N7Q_IMLOJA
					Else //venda
						cCodEnt := N7Q->N7Q_ENTENT
						cLojEnt := N7Q->N7Q_LOJENT
					EndIf
				Else
					cCodEnt := N7Q->N7Q_IMPORT
					cLojEnt := N7Q->N7Q_IMLOJA
				EndIf
			EndIf
		EndIf	
					
	Else	
		cLocal := "" //quando em branco Local será igual ao local da NJJ		
		cCodEnt := N9A->N9A_CODENT
		cLojEnt := N9A->N9A_LOJENT
	EndIf

	/**** Define subtipo ****/
	// Caso seja uma remessa de uma IE de mercado interno/externo, será Remessa Formação de Lote
	If cTipoRom == "2" .AND. (nIndOp = 2 .OR. nIndOp = 4)
		cSubTipo := '21' //(S) REMESSA PARA FORMAÇÃO LOTE

		// Se não for contrato de armazenagem, irá efetuar a busca dos contratos depois da quebra (QuebraNJM)
		If lRemVnd 			
			cCodCtr  := ""
			cItemCtr := ""
			cRegFis  := ""
		EndIf 				
	EndIf

	If nIndOp = 1 .AND. cTipoRom == "4"
		cSubTipo := '43' //(S) Venda Entrega Futura
	ElseIf nIndOp = 1 .AND. cTipoRom == "5"
        cSubTipo := '51' //(E) Venda Entrega Futura
    ElseIf nIndOp = 2 .AND. cTipoRom == "4"
		cSubTipo := '41' //(S) Venda Exportacao
	ElseIf nIndOp = 4 .AND. cTipoRom $ "4|5" 
		If N9A->N9A_OPETRI == '1' .AND. cTipoRom == '4'
			cSubTipo := '45' //(S) Venda a ordem
		EndIf

		If N9A->N9A_OPEFUT == '1' 
			cSubTipo := IIF(cTipoRom == '4','44','52') //(S) Remessa venda futura
			If !Empty(cLotFut)
				cLote := cLotFut
			EndIF
		EndIf
	EndIf
	
	//atualizo a variavel com a copia exata da linha a ser deletada.
	aAux := GetNJMStr(cFilRom,cCodrom)

	// Apenas para Venda Mercado Interno porque nesta situação o romaneio já foi criado
	If nIndOp = 4 .or. nIndOp = 2  //4=mercado interno; 2=mercado externo
		aAux[aScan(aAux,{|x| x[1] = 'NJM_FILIAL'})][2] := cFilRom
		aAux[aScan(aAux,{|x| x[1] = 'NJM_CODROM'})][2] := cCodRom
	EndIf	

	nItRom++
	aAux[aScan(aAux,{|x| x[1] = 'NJM_ITEROM'})][2] := StrZero(nItRom,2)
	aAux[aScan(aAux,{|x| x[1] = 'NJM_CODENT'})][2] := cCodEnt
	aAux[aScan(aAux,{|x| x[1] = 'NJM_LOJENT'})][2] := cLojEnt
	aAux[aScan(aAux,{|x| x[1] = 'NJM_GENMOD'})][2] := NJR->NJR_GENMOD

	If lRemVnd .and. lUsaIE
		aAux[aScan(aAux,{|x| x[1] = 'NJM_CODSAF'})][2] := N7Q->N7Q_CODSAF
		aAux[aScan(aAux,{|x| x[1] = 'NJM_CODPRO'})][2] := N7Q->N7Q_CODPRO
		aAux[aScan(aAux,{|x| x[1] = 'NJM_UM1PRO'})][2] := ''
	Else	
		aAux[aScan(aAux,{|x| x[1] = 'NJM_CODSAF'})][2] := NJR->NJR_CODSAF
		aAux[aScan(aAux,{|x| x[1] = 'NJM_CODPRO'})][2] := NJR->NJR_CODPRO
		aAux[aScan(aAux,{|x| x[1] = 'NJM_UM1PRO'})][2] := NJR->NJR_UM1PRO
	EndIf

	If nIndOp = 2 .Or. nIndOp = 3 .Or. nIndOp = 4
		aAux[aScan(aAux,{|x| x[1] = 'NJM_CODINE'})][2] := cCodIne
	EndIf

	aAux[aScan(aAux,{|x| x[1] = 'NJM_FILORG'})][2] := cFilIE
	aAux[aScan(aAux,{|x| x[1] = 'NJM_CODCTR'})][2] := cCodCtr
	aAux[aScan(aAux,{|x| x[1] = 'NJM_ITEM'})][2] := cItemCtr
	aAux[aScan(aAux,{|x| x[1] = 'NJM_SEQPRI'})][2] := cRegFis

	If !lRemVnd .AND. cSubTipo $ '44|52' //remessa venda global futura
		If AGRTPALGOD(NJR->NJR_CODPRO) //se algodão  //esta posicionado na NJR
			//na global fututa é executado a precificação, assim na remessa da global fututa o preço do fardo deve ser igual da global futura
			aAux[aScan(aAux,{|x| x[1] = 'NJM_VLRUNI'})][2] := PRCRMGBFT(cFilRom,cCodRom, N9A->N9A_CODROM)
		Else //se grãos							
			aAux[aScan(aAux,{|x| x[1] = 'NJM_VLRUNI'})][2] := NJMGBFT(N9A->N9A_FILORG,N9A->N9A_CODROM,'NJM_VLRUNI')	
		EndIf
	Else
		aAux[aScan(aAux,{|x| x[1] = 'NJM_VLRUNI'})][2] := nPrecMed		
	EndIf	

	nTpProd := IIf(AGRTPALGOD(NJR->NJR_CODPRO) = .T.,2,1)

	// Remessa por Venda Futura para algodão
	If cSubTipo == "44" .AND. nTpProd = 2
		nPesoRVF := nPeso
		nPeso    := 0
	EndIf

    aAux[aScan(aAux,{|x| x[1] = 'NJM_PERDIV'})][2] := (nPeso / nPesoNJJ * 100)		
    aAux[aScan(aAux,{|x| x[1] = 'NJM_STAFIS'})][2] := "1"	
	aAux[aScan(aAux,{|x| x[1] = 'NJM_TPFORM'})][2] := "1"	
    aAux[aScan(aAux,{|x| x[1] = 'NJM_NFPSER'})][2] := cSerNFP		
    aAux[aScan(aAux,{|x| x[1] = 'NJM_NFPNUM'})][2] := cNumNFP		
    aAux[aScan(aAux,{|x| x[1] = 'NJM_QTDFIS'})][2] := nPeso		
    aAux[aScan(aAux,{|x| x[1] = 'NJM_QTDFCO'})][2] := nPeso		
    aAux[aScan(aAux,{|x| x[1] = 'NJM_TRSERV'})][2] := "0"		
    aAux[aScan(aAux,{|x| x[1] = 'NJM_LOCAL'})][2] := cLocal		
    aAux[aScan(aAux,{|x| x[1] = 'NJM_NMLOT'})][2] := ''		

    /*Formulário emissão de terceiro*/
    If !Empty(aDadosNF)        
        aAux[aScan(aAux,{|x| x[1] = 'NJM_TPFORM'})][2] := "2"
        aAux[aScan(aAux,{|x| x[1] = 'NJM_DOCNUM'})][2] := aDadosNF[01]		
        aAux[aScan(aAux,{|x| x[1] = 'NJM_DOCSER'})][2] := aDadosNF[02]		
        aAux[aScan(aAux,{|x| x[1] = 'NJM_DOCEMI'})][2] := aDadosNF[03]		
        aAux[aScan(aAux,{|x| x[1] = 'NJM_DOCESP'})][2] := aDadosNF[04]		
        aAux[aScan(aAux,{|x| x[1] = 'NJM_VLRTOT'})][2] := aDadosNF[05]	
		aAux[aScan(aAux,{|x| x[1] = 'NJM_VLRUNI'})][2] := aDadosNF[06]	
		aAux[aScan(aAux,{|x| x[1] = 'NJM_QTDFIS'})][2] := aDadosNF[07]				
    Else
        aAux[aScan(aAux,{|x| x[1] = 'NJM_VLRTOT'})][2] := 0
    EndIf

	If lUsaIE
		cOpeFis :=  N7S->N7S_OPEFIS
	else
		cOpeFis :=  N9A->N9A_OPEFIS
	EndIf

	If !lRemVnd
		If (nIndOp == 2 .Or. nIndOp == 3 .Or. nIndOp == 4) .AND. cTipoRom != "2" .And. !(cSubTipo $ '44|52') //remessa venda global futura		
			If !Empty(cCodIne)
				cTES := N7S->N7S_TES
			Else
				cTES := N9A->N9A_TES	
			EndIf
		Else
			if cSubTipo $ '44|52' 
				cTES := N9A->N9A_TESAUX
				cOpeFis := ''
			Else
				cTES := N9A->N9A_TES				
			EndIF		
		EndIf
	EndIf
	
	aAux[aScan(aAux,{|x| x[1] = 'NJM_TES'})][2] := cTES	
	aAux[aScan(aAux,{|x| x[1] = 'NJM_OPEFIS'})][2] := cOpeFis
	
	//Não grava lote na NJM se a TES não atualiza estoque.
	If !Empty(cTES) .And. Posicione('SF4',1,FWxFilial('SF4')+cTES,'F4_ESTOQUE') $ 'N'                                                
		cLote := ""
	EndIf
	
	aAux[aScan(aAux,{|x| x[1] = 'NJM_LOTCTL'})][2] := cLote

	If nIndOp = 1 .Or. nIndOp = 3
		aAux[aScan(aAux,{|x| x[1] = 'NJM_IDMOV'})][2] := cSubTipo
	ElseIf nIndOp = 2 
		aAux[aScan(aAux,{|x| x[1] = 'NJM_IDMOV'})][2] := OG250DMVID(cCodIne)
	EndIf
	
	If !lRemVnd	
		If nIndOp = 4  .and. N9A->N9A_OPEFUT = '1'  //Se remessa global futura
			aAux[aScan(aAux,{|x| x[1] = 'NJM_IDMOV'})][2] := NJMGBFT(N9A->N9A_FILORG,N9A->N9A_CODROM,'NJM_IDMOV')
		EndIf
	EndIf

	aAux[aScan(aAux,{|x| x[1] = 'NJM_SUBTIP'})][2] := cSubTipo

	aAdd(aFldNJM, aAux)

	RestArea(aAreaNJR)
	RestArea(aAreaN9A)
	RestArea(aAreaN7Q)
	RestArea(aAreaN7S)

	// Remessa por Venda Futura para algodão
	If cSubTipo == "44" .AND. nTpProd = 2
		If !VerExcRom(nTpProd, @aFldNJM, aAux, @nItRom, cFilRom, cCodRom, nPesoNJJ, cFilIE, cCodIne, cCodCtr, cItemCtr, cRegFis, nPesoRVF, nPrecMed, cSerNFP, cNumNFP, cLote, .F.)
			Return .F.
		EndIf 
	EndIf	

Return .T.

/*{Protheus.doc} OG250DGNJM
Grava o array de dados da NJM

@author francisco.nunes
@since 27/03/2018
@param aFldNJM, array campos NJM
@param cFilRom, Filial do romaneio
@param cCodRom, Código do romaneio
@type function
*/
Function OG250DGNJM(aFldNJM, cFilRom, cCodRom)

	Local nIt   := 0
	Local nX    := 0

	DbSelectArea("NJM") // Comercializações do romaneio

	// Exclui registro de itens para recriá-los
	NJM->(DbSetOrder(1)) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If NJM->(DbSeek(cFilRom+cCodRom))
		While !(NJM->(Eof())) .And. NJM->NJM_FILIAL+NJM->NJM_CODROM == cFilRom+cCodRom

			If RecLock("NJM", .F.)
				NJM->(DbDelete())
				NJM->(MsUnLock())
			EndIf
			NJM->(DbSkip())					
		EndDo
	EndIf

	// Cria os registros na NJM		
	For nIt := 1 To Len(aFldNJM)			
		If RecLock("NJM", .T.)
			For nX := 1 To Len(aFldNJM[nIt])
				NJM->&(aFldNJM[nIt][nX][1]) := aFldNJM[nIt][nX][2]								
			Next nX

			NJM->(MsUnlock())
		EndIf
	Next nIt

Return .T.

/*{Protheus.doc} OG250DGQTD
Atualiza o campo N7S_QTDREM para as regras fiscais da(s) IE(s) do romaneio
Atualiza os campos N9A_QTDNF e N9A_SDONF para as regras fiscais da(s) IE(s) do romaneio

@param cFilRom, Filial do romaneio
@param cCodRom, Código do romaneio
@param lAtuliz, .T. - Atualização do romaneio (Soma a quantidade remetida), .F. - Reaberura do romaneio (Diminui a quantidade remetida)
@author francisco.nunes
@since 27/03/2018

@type function
*/
Function OG250DGQTD(cFilRom, cCodRom, lAtuliz)
	
	Local aAreaNJJ	 := NJJ->(GetArea())
	Local aAreaN9A   := N9A->(GetArea())	
	Local aAreaN7S   := N7S->(GetArea())
	Local aAreaN7Q   := N7Q->(GetArea())
	Local cChaveN9A	 := ""
	Local cTpCtrIE	 := "" //1 - Venda/2 - Armazenagem
	Local lExcAtuN7S := .F.
	Local aFardos	 := {}
	Local lSoma		 := .T.
	Local lUpdRegFis := .T.
	Local lDevol	 := .F.
	Local aIES 		 := OG250DIES(cFilRom, cCodRom)
	Local lUsaIE 	 := IIF(LEN(aIES) > 0 , .T. , .F.)

	Default lAtuliz := .T.
		
	lSoma := lAtuliz
	
	DbSelectArea("NJJ")
	NJJ->(DbSetOrder(1)) // NJJ_FILIAL+NJJ_CODROM
	If NJJ->(DbSeek(cFilRom+cCodRom))		
		If NJJ->NJJ_TIPO $ "6|7|8|9" // Devoluções
			lDevol := .T.
			
			// No caso das devoluções, a atualização vai subtrair a quantidade da N9A e o reabrir vai somar
			If lAtuliz
				lSoma := .F.
			Else
				lSoma := .T.
			EndIf							
		EndIf
	EndIf

	__aCtrs := {}

	DbSelectArea("NJM") // Comercializações do romaneio
	NJM->(DbSetOrder(1)) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If NJM->(DbSeek(cFilRom+cCodRom))
		While !(NJM->(Eof())) .And. NJM->NJM_FILIAL+NJM->NJM_CODROM == cFilRom+cCodRom

			// (S) REMESSA PARA FORMAÇÃO LOTE / (S) SAIDA POR VENDA / (S) REMESSA POR VENDA FUTURA
			// (S) VENDA A ORDEM / (S) SAIDA POR VENDA EXCEDENTE / (S) DEVOLUÇÃO DE VENDA
			If NJM->NJM_SUBTIP $ '21|40|44|45|52|49|57|90'
				cTpCtrIE := ""

				DbSelectArea("N7Q")				
				N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
				If N7Q->(DbSeek(NJM->NJM_FILORG+NJM->NJM_CODINE))
					cTpCtrIE := N7Q->N7Q_TPCTR

					If RecLock("N7Q", .F.)
						If (lAtuliz .AND. !lDevol) .OR. (!lAtuliz .AND. lDevol)
							N7Q->N7Q_QTDREM := N7Q->N7Q_QTDREM + NJM->NJM_QTDFIS
						Else
							N7Q->N7Q_QTDREM := N7Q->N7Q_QTDREM - NJM->NJM_QTDFIS
						EndIf

						N7Q->(MsUnlock())
					EndIf					
				EndIf		

				// SE FOR REMESSA PARA FORMAÇÃO LOTE COM IE DE VENDA 
				If NJM->NJM_SUBTIP == "21" .AND. cTpCtrIE == "1" .And. AGRTPALGOD(NJM->(NJM_CODPRO)) // ALGODÃO
					lExcAtuN7S := .T.
				EndIf	

				// SE NÃO FOR REMESSA PARA FORMAÇÃO LOTE COM IE DE VENDA				
				If NJM->NJM_SUBTIP != "21" .OR. cTpCtrIE != "1"
					DbSelectArea("N7S")				
					N7S->(DbSetOrder(1)) //N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
					If N7S->(DbSeek(NJM->NJM_FILORG+NJM->NJM_CODINE+NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI))
						If RecLock("N7S", .F.)
							If (lAtuliz .AND. !lDevol) .OR. (!lAtuliz .AND. lDevol)						
								N7S->N7S_QTDREM := N7S->N7S_QTDREM + NJM->NJM_QTDFIS																	
							Else						
								N7S->N7S_QTDREM := N7S->N7S_QTDREM - NJM->NJM_QTDFIS						
							EndIf

							N7S->(MsUnlock())																									
						EndIf	

						If N7S->N7S_INCAUT == "1" .AND. !lAtuliz // Inclusão Automática
							If !AtuRefIE(NJM->NJM_FILORG, NJM->NJM_CODINE, NJM->NJM_CODCTR, NJM->NJM_ITEM, NJM->NJM_SEQPRI, NJM->NJM_QTDFIS)
								Return .F.
							EndIf													
						EndIf									
					EndIf
				EndIf
				
				// Atualiza a quantidade faturada na tabela de vinculo do DCO com a IE
                If __lExistNLN
                    DbSelectArea("NLN")
                    NLN->(DbSetOrder(1)) // NLN_FILIAL+NLN_CODCTR+NLN_ITEMPE+NLN_ITEMRF+NLN_SEQUEN
                    If NLN->(DbSeek(NJM->NJM_FILORG+NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI+NJM->NJM_SEQNLN))
                        If RecLock("NLN", .F.)
                            
                            If (lAtuliz .AND. !lDevol) .OR. (!lAtuliz .AND. lDevol)
                                NLN->NLN_QTDFAT := NLN->NLN_QTDFAT + NJM->NJM_QTDFIS
                            Else
                                NLN->NLN_QTDFAT := NLN->NLN_QTDFAT - NJM->NJM_QTDFIS
                            EndIf
                                                
                            NLN->(MsUnlock())
                        EndIf					
                    EndIf
                EndIf
								
			EndIf	

			cChaveN9A := NJM->NJM_FILORG+NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI

			If NJM->NJM_SUBTIP $ "49|57" // (S)/(E) EXCEDENTE VENDA FUTURA 
				// Retorna o Item da Regra Fiscal Excedente da Venda Futura definida no contrato
				cItRef := OG250DRN9A(NJM->NJM_FILORG,NJM->NJM_CODCTR,NJM->NJM_ITEM,NJM->NJM_FILIAL,1,,.T.,lUsaIE)[1]

				cChaveN9A := NJM->NJM_FILORG+NJM->NJM_CODCTR+NJM->NJM_ITEM+cItRef
			ElseIf NJM->NJM_SUBTIP $ "21|40|41|42|43|45|48|50|51" .and. !AGRTPALGOD(NJJ->(NJJ_CODPRO)) .and. !lAtuliz .and. NJM->NJM_TPFORM == "1" //se grãos e é para devolver o saldo da regra fiscal
				lUpdRegFis := IIF(NJM->NJM_SUBTIP $ '43|51',.F., .T.)
				OGX060CANC("R", NJM->NJM_FILORG, NJM->NJM_CODROM, NJM->NJM_ITEROM, NJM->NJM_CODCTR, NJM->NJM_ITEM, NJM->NJM_SEQPRI, NJM->NJM_QTDFIS, lUpdRegFis, NJM->NJM_FILIAL) //Cancela Fixações e devolve Saldos das regras fiscais
			ElseIf NJM->NJM_SUBTIP $ "21|40|41|42|43|45|48|50|51" .and. AGRTPALGOD(NJJ->(NJJ_CODPRO)) .and. !lAtuliz .and. NJM->NJM_TPFORM == "1" //se algodão e é para devolver o saldo da regra fiscal
				lUpdRegFis := IIF(NJM->NJM_SUBTIP $ '43|51',.F., .T.)
				aFardos := OGX050CTRF("07", NJM->NJM_FILIAL ,  NJM->NJM_CODCTR , NJM->NJM_ITEM, NJM->NJM_SEQPRI, " N9D.N9D_CODINE='"+NJM->NJM_CODINE+"' " ) //pega todos os fardos do romaneio para a regra fiscal, necessario filtro pela Ie pois pode ter mesmo contrato de remessa para Ie diferente
				OGX050CANC("R", NJM->NJM_FILORG, NJM->NJM_CODROM, NJM->NJM_ITEROM, NJM->NJM_CODCTR, NJM->NJM_ITEM, NJM->NJM_SEQPRI, NJM->NJM_QTDFIS, lUpdRegFis, aFardos, NJM->NJM_FILIAL) //Cancela Fixações e devolve Saldos das regras fiscais
			EndIf
			
			If (NJM->NJM_TPFORM == "2" .AND. NJM->NJM_SUBTIP = "50") .OR. !NJM->NJM_SUBTIP $ "21|40|41|42|45|48|90|50"
				//NJM->NJM_SUBTIP - estes subtipos ja consome da regra fiscal na execução da precificação OG250DMPRC - OGX050/OGX060 então não é necessario atualizar aqui
				DbSelectArea("N9A")
				N9A->(DbSetOrder(1)) //N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
				If N9A->(DbSeek(cChaveN9A))
					If RecLock("N9A", .F.)
						If lSoma											
							If NJM->NJM_SUBTIP $ "43|46|51" // (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM
								N9A->N9A_CODROM := NJM->NJM_CODROM
							Else
								N9A->N9A_QTDNF  := N9A->N9A_QTDNF + NJM->NJM_QTDFIS
							EndIf						
						Else											
							If NJM->NJM_SUBTIP $ "43|46|51" // (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM
								N9A->N9A_CODROM := ""
							Else
								N9A->N9A_QTDNF  := N9A->N9A_QTDNF - NJM->NJM_QTDFIS
							EndIf						
						EndIf

						N9A->N9A_SDONF := N9A->N9A_QUANT - N9A->N9A_QTDNF

						N9A->(MsUnlock())
					EndIf
				EndIf	

			EndIf		

			If !lAtuliz .and. !AGRTPALGOD(NJM->(NJM_CODPRO)) .AND. NJM->NJM_SUBTIP $ "40|50" .AND. !AjuExcRFIE(lUsaIE)
				Return .F.
			EndIf

			NJM->(DbSkip())					
		EndDo				
	EndIf

	RestArea(aAreaNJJ)
	RestArea(aAreaN9A)
	RestArea(aAreaN7Q)
	RestArea(aAreaN7S)	

	If lExcAtuN7S
		// Atualiza a quantidade remetida das entregas da IE
		If !ConsRemIE(2, cFilRom, cCodRom, 0, lAtuliz)
			Return .F.
		EndIf
	EndIf

Return .T.

/*{Protheus.doc} AjuExcRFIE
Ao reabrir o romaneio Ajusta saldo N9A e quanitdades da N7Q e N7S quando ha excedente por venda/compra normal 
com a aditação automatica

@param lUsaIE, se romaneio esta usando Instrução de embarque
@return .T. 
@author claudineia.reinert
@since 07/08/2020

@type function
*/
Static Function AjuExcRFIE(lUsaIE)
	Local nDifN9A 	:=  0
	Local nQtdExced := 0
	Local cAliasQry := nil
	
	DbSelectArea("N9A")
	N9A->(DbSetOrder(1)) //N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
	If N9A->(DbSeek(NJM->NJM_FILORG+NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI))
		nDifN9A := N9A->(N9A_QTDNF + N9A_SDONF) - N9A->N9A_QUANT //DIFERENCA SALDO COM A QUANTIDADE N9A
		If nDifN9A > 0 //Foi remetido qtd a mais, tem excedente
			cAliasQry := GetNextAlias()
			cQry := " SELECT NNW_QTDALT "
			cQry += " FROM " + RetSqlName("NNW") + " NNW "
			cQry += " WHERE NNW_FILIAL = '"+ FWxFILIAL("NNW") +"' "
			cQry += " AND NNW_CODCTR='"+ NJM->NJM_CODCTR +"' AND NNW_CODROM='"+ NJM->NJM_CODROM +"'  " 
			cQry += " AND NNW_TIPO = '1'  AND NNW_STATUS='2' "
			cQry += " AND NNW_ADEXCE='1' " //EXCEDENTE CARGA
			cQry += " AND NNW.D_E_L_E_T_ = ' ' "	
			cQry := ChangeQuery(cQry)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.) 
				
			If !(cAliasQry)->(Eof()) 
				nQtdExced := (cAliasQry)->NNW_QTDALT
			EndIf
			(cAliasQry)->(dbCloseArea())

			If nQtdExced > 0 //tem excedente por aditação automatica para o contrato pelo romaneio
				If RecLock("N9A", .F.)
					N9A->N9A_SDONF  := N9A->N9A_SDONF - nQtdExced
					If lUsaIE
						N9A->N9A_QTDINS := N9A->N9A_QTDINS - nQtdExced
						N9A->N9A_SDOINS := N9A->N9A_QUANT - N9A->N9A_QTDINS
					EndIf
					N9A->(MsUnlock())
				EndIf	

				If lUsaIE //se tem excedente na N9A a IE tambem foi ajustada com o Excedente
					DbSelectArea("N7Q")
					N7Q->(DbSetOrder(1)) // N7Q_FILIAL+N7Q_CODINE
					If N7Q->(DbSeek(FWxFILIAL("N7Q") + NJM->NJM_CODINE ))
						If RecLock("N7Q", .F.)
							N7Q->N7Q_TOTLIQ := N7Q->N7Q_TOTLIQ - nQtdExced
							N7Q->N7Q_TOTBRU := N7Q->N7Q_TOTBRU - nQtdExced
							N7Q->(MsUnLock())
						EndIf
					EndIf
					DbSelectArea("N7S")				
					N7S->(DbSetOrder(1)) //N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
					If N7S->(DbSeek(NJM->NJM_FILORG+NJM->NJM_CODINE+NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI))
						If RecLock("N7S", .F.)
							N7S->N7S_QTDVIN := N7S->N7S_QTDVIN - nQtdExced																
							N7S->(MsUnlock())		
						EndIf																							
					EndIf
					
				EndIf
			EndIf
		EndIf
	EndIf
	
Return .T.

/*{Protheus.doc} OG250DRN9A
Retorna dados da regra fiscal que consumirá o valor excedente

@param cFilCtr, Filial do contrato
@param cCodCtr, Código do contrato
@param cItEtg, Item da Previsão de Entrega do contrato
@param cFilRef, Filial de origem da regra fiscal
@param nOperRef, 1 - Regra Fiscal de excedente de venda futura / 2 - Qualquer outra regra fiscal
@param nTpProd, Tipo de Produto : 1 - Grãos; 2 - Algodão
@param lExcVF, .T.- Excedente Venda Futura; .F. - Excedente Outroscampos da N9A :
@param lUsaIE, .T.- Usa instrução de embarque; .F. - Não usa IE
@param cTpForm, 1 - Formulario Proprio SIM ; 2 - Formulario Proprio NÃO 
@param cTESEXC, TES que gerou o excedente para vvalidar com Formulario Proprio NÃO 
@return aRetN9A, Array com 

[1] = Código da Regra Fiscal
[2] = TES da Regra Fiscal
[3] = Saldo da Regra Fiscal
[4] = .T. - Regra Fiscal Excedente; .F. - Outra regra Fiscal

@author francisco.nunes
@since 27/03/2018

@type function
*/
Static Function OG250DRN9A(cFilCtr, cCodCtr, cItEtg, cFilRef, nOperRef, nTpProd, lExcVF,lUsaIE,cTpForm, cTESEXC)

	Local aAreaN9A  := N9A->(GetArea())
	Local aRetN9A   := {}	
	Local nPos	    := 0
	Local nPsRefNJM := 0
	Local nForExc	:= IIf(lExcVF, 1, 2)
	Local nX		:= 0
	Local cChave    := ""
	Local cValor    := ""
	Local lEncRF	:= .F.

	Default nTpProd := 0
	Default lExcVF  := .T.
	Default lUsaIE	:= .F.
	Default cTpForm	:= "1"
	Default cTESEXC	:= ""

	aRetN9A := {"","",0,.F.}
	
	// Para Excedente de Venda Futura:
	// Procura uma regra fiscal com a mesma filial, contrato e previsão de entrega, que não seja
	// entrega futura e não tenha quantidade para pegar a TES para incluir um item na NJM para o excedente
	
	// Para Excedente Outros:
	// Procura uma regra fiscal com a mesma filial, contrato e previsão de entrega, caso não encontre
	// procura uma regra fiscal com a mesma filial e contrato
	
	For nX := 1 to nForExc
	
		If nX == 1
			cChave := "N9A_FILIAL+N9A_CODCTR+N9A_ITEM"
			cValor := cFilCtr+cCodCtr+cItEtg		
		Else
			// Irá buscar apenas por contrato
			cChave := "N9A_FILIAL+N9A_CODCTR"
			cValor := cFilCtr+cCodCtr
		EndIf
			
		DbSelectArea("N9A")
		N9A->(DbSetOrder(1)) //N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
		If N9A->(DbSeek(cValor))
			While !N9A->(Eof()) .AND.  N9A->(&(cChave)) == cValor
				
				If nOperRef = 1 .AND. lExcVF //É VENDA FUTURA 
					If N9A->N9A_OPEFUT == '2' .AND. N9A->N9A_QUANT = 0 .AND. N9A->N9A_FILORG == cFilRef ;
					   .AND. (cTpForm == "1" .OR. (cTpForm == "2" .AND. cTESEXC == N9A->N9A_TES))
						aRetN9A[1] := N9A->N9A_SEQPRI
						aRetN9A[2] := N9A->N9A_TES
						aRetN9A[3] := N9A->N9A_SDONF
						aRetN9A[4] := .T.	
						
						lEncRF := .T.
						
						EXIT		
					EndIf
				ElseIf nOperRef = 2 .AND. lExcVF
					// Busca a regra fiscal excedente (Quantidade zerada)
					If N9A->N9A_OPEFUT == '2' .AND. N9A->N9A_QUANT = 0 .AND. N9A->N9A_FILORG == cFilRef ;
					    .AND. (cTpForm == "1" .OR. (cTpForm == "2" .AND. cTESEXC == N9A->N9A_TES))
						aRetN9A[1] := N9A->N9A_SEQPRI
						aRetN9A[2] := N9A->N9A_TES
						aRetN9A[3] := N9A->N9A_SDONF
						aRetN9A[4] := .T.
						
						lEncRF := .T.														
					EndIf
	
					// Para grãos, pode considerar uma regra fiscal que não seja a excedente
					If N9A->N9A_FILORG == cFilRef .AND. N9A->N9A_QUANT != 0 .AND. nTpProd = 1 ;
					.AND. ((lUsaIE .AND. N9A->N9A_SDOINS > 0) .OR. (!lUsaIE .AND. N9A->N9A_SDONF > 0))
	
						// Verifica o peso já consumido da regra fiscal na NJM no romaneio atual
						nPos := aScan(__aItRefs, {|x| AllTrim(x[1]) == AllTrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI))})			
						If nPos > 0
							nPsRefNJM := __aItRefs[nPos][2]
						EndIf
	
						// Apenas considera as regras fiscais com saldo (é descontado a quantidade já consumida no romaneio atual)
						If ((lUsaIE .AND. N9A->N9A_SDOINS - nPsRefNJM > 0) .OR. (!lUsaIE .AND. N9A->N9A_SDONF - nPsRefNJM > 0)) ;				
						   .AND. (cTpForm == "1" .OR. (cTpForm == "2" .AND. cTESEXC == N9A->N9A_TES))
							aRetN9A[1] := N9A->N9A_SEQPRI
							aRetN9A[2] := N9A->N9A_TES
							If lUsaIE
								aRetN9A[3] := N9A->N9A_SDOINS - nPsRefNJM
							ELSE
								aRetN9A[3] := N9A->N9A_SDONF - nPsRefNJM
							ENDIF
							aRetN9A[4] := .F.
							
							lEncRF := .T.
	
							EXIT 
						EndIf	
					EndIf
					nPsRefNJM := 0 //para quando é SEM IE, pois o N9A->N9A_SDONF ainda não foi ajustado ai não entra no if acima
				ElseIf !lExcVF
				
					If N9A->N9A_FILORG == cFilRef .AND. N9A->N9A_QUANT != 0 ;
					.AND. ((lUsaIE .AND. N9A->N9A_SDOINS > 0) .OR. (!lUsaIE .AND. N9A->N9A_SDONF > 0))
											
						// Verifica o peso já consumido da regra fiscal na NJM no romaneio atual
						nPos := aScan(__aItRefs, {|x| AllTrim(x[1]) == AllTrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI))})			
						If nPos > 0
							nPsRefNJM := __aItRefs[nPos][2]
						EndIf

						// Apenas considera as regras fiscais com saldo (é descontado a quantidade já consumida no romaneio atual)
						If ((lUsaIE .AND. N9A->N9A_SDOINS - nPsRefNJM > 0) .OR. (!lUsaIE .AND. N9A->N9A_SDONF - nPsRefNJM > 0)) ;
						    .AND. (cTpForm == "1" .OR. (cTpForm == "2" .AND. cTESEXC == N9A->N9A_TES))
			
							cItEtg := N9A->N9A_ITEM
							
							aRetN9A[1] := N9A->N9A_SEQPRI
							aRetN9A[2] := N9A->N9A_TES
							If lUsaIE
								aRetN9A[3] := N9A->N9A_SDOINS - nPsRefNJM
							Else
								aRetN9A[3] := N9A->N9A_SDONF - nPsRefNJM
							EndIf

							aRetN9A[4] := .F.
							
							lEncRF := .T.
	
							EXIT 
						EndIf

						nPsRefNJM := 0 //para quando é SEM IE, pois o N9A->N9A_SDONF ainda não foi ajustado ai não entra no if acima
						
					EndIf				
				EndIf
	
				N9A->(DbSkip())
			EndDo						
		EndIf
		
		If lEncRF
			EXIT
		EndIf
	
	Next nX

	RestArea(aAreaN9A)

Return aRetN9A

/** {Protheus.doc} OG250DVMI
Retorna o tipo de mercado da Instrução de Embarque informada no romaneio

@return:	Nil
@author: 	franciso.nunes
@since: 	27/03/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, filial do romaneio
@param cCodRom, character, código do romaneio

*/
Function OG250DVMI()
	Local cTipoMerc := "" 	
	Local cAliasQry  := GetNextAlias()	
	Local aIes := {}
	Local cFilRom := ''
	Local cCodRom := ''
	Local cCodCtr := ''
	
	cFilRom := NJJ->NJJ_FILIAL
	cCodRom := NJJ->NJJ_CODROM

	aIes := OG250DIES(cFilRom, cCodRom)

	//Processo sem Instrução de Embarque
	If LEN(aIes) <= 0
		cCodCtr	   := NJM->NJM_CODCTR
		
		BeginSQL alias cAliasQry
		SELECT
			NJR.NJR_TIPMER
		FROM
			%table:NJR% NJR
		WHERE
			NJR_FILIAL = %xFilial:NJR% AND
			NJR_CODCTR = %Exp:cCodCtr% AND
			NJR.%notDel%
		EndSql

		While (cAliasQry)->( !Eof() )
			cTipoMerc := (cAliasQry)->NJR_TIPMER
			(cAliasQry)->(DbSkip())
		Enddo
	
		(cAliasQry)->(DbCloseArea())
		
	//Processo com Instrução de Embarque
	Else

		BeginSQL alias cAliasQry
		SELECT
			DISTINCT NJR.NJR_TIPMER
		FROM
			%table:N9E% N9E
			INNER JOIN %table:N7S% N7S ON
			N7S.N7S_FILIAL = N9E.N9E_FILIE AND 
			N7S.N7S_CODINE = N9E.N9E_CODINE AND
			N7S.%notDel%
			INNER JOIN %table:NJR% NJR ON 
			NJR.NJR_FILIAL = %xFilial:NJR% AND 
			NJR.NJR_CODCTR = N7S.N7S_CODCTR AND 
			NJR.%notDel%
		WHERE
			N9E_FILIAL = %Exp:cFilRom% AND
			N9E.N9E_CODROM = %Exp:cCodRom% AND
			N9E.%notDel%
		EndSql
		
		While (cAliasQry)->( !Eof() )
			cTipoMerc := (cAliasQry)->NJR_TIPMER	
			(cAliasQry)->(DbSkip())
		Enddo
		(cAliasQry)->(DbCloseArea())
	EndIf	
	
Return cTipoMerc

/** {Protheus.doc} OG250DVFT
Retorna se o romaneio é venda futura (43) / remessa venda futura (44)

@return:	Nil
@author: 	franciso.nunes
@since: 	27/03/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, filial do romaneio
@param cCodRom, character, código do romaneio

*/
Function OG250DVFT(cFilRom, cCodRom)

	Local cQry 	    := ""
	Local cAliasQry := ""
	Local cSubTip 	:= "" 
	Local aAreaN9E  := N9E->(GetArea())

	DbSelectArea("N9E") // Integrações do Romaneio

	N9E->(DbSetOrder(1)) //N9E_FILIAL+N9E_CODROM+N9E_SEQUEN
	If N9E->(DbSeek(cFilRom+cCodRom))
		If N9E->N9E_ORIGEM == "4" // 4=Contrato Entrega Futura;
			cSubTip := "43" // (S) VENDA ENTREGA FUTURA
		EndIf

		If !Empty(N9E->N9E_CODINE)
			cAliasQry := GetNextAlias()
			cQry := " SELECT 1 "
			cQry += "   FROM " + RetSqlName("N7S") + " N7S "
			cQry += " INNER JOIN " + RetSqlName("N9A") + " N9A ON N9A.N9A_FILIAL = '"+ xFilial("N9A") +"' AND N9A.N9A_CODCTR = N7S.N7S_CODCTR AND N9A.N9A_ITEM = N7S.N7S_ITEM AND N9A.N9A_SEQPRI = N7S.N7S_SEQPRI AND N9A.N9A_OPEFUT = '1' AND N9A.D_E_L_E_T_ = '' "		
			cQry += " WHERE N7S.N7S_FILIAL = '"+ N9E->N9E_FILIE +"' "
			cQry += "   AND N7S.N7S_CODINE = '"+ N9E->N9E_CODINE +"' "
			cQry += "   AND N7S.D_E_L_E_T_ = '' "
			cQry := ChangeQuery( cQry )	
			dbUseArea(.T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T.)

			dbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())
			If (cAliasQry)->(!Eof())	 	
				cSubTip := "44" // (S) REMESSA POR VENDA FUTURA
			EndIf
			(cAliasQry)->(DbCloseArea())			
		EndIf

	EndIf

	RestArea(aAreaN9E)

Return cSubTip

/** {Protheus.doc} OG250DRFM
Retorna se o romaneio é de remessa formação de lote

@return:	Nil
@author: 	franciso.nunes
@since: 	06/04/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, filial do romaneio
@param cCodRom, character, código do romaneio

*/
Function OG250DRFM(cFilRom, cCodRom)

	Local lRemFLot 	:= .F.
	Local aAreaNJM  := NJM->(GetArea())

	DbSelectArea("NJM") // Comercializações do Romaneio

	NJM->(DbSetOrder(1)) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If NJM->(DbSeek(cFilRom+cCodRom))
		If NJM->NJM_SUBTIP == "21" // (S) REMESSA PARA FORMAÇÃO LOTE
			lRemFLot := .T.
		EndIf
	EndIf 

	RestArea(aAreaNJM)

Return lRemFLot

/** {Protheus.doc} NJMGBFT
Busca valor do campo na NJM para romaneio de venda global futura

@return:	Nil
@author: 	claudineia.reinert
@since: 	06/04/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, filial do romaneio
@param cCodRom, character, código do romaneio
@param cCampo, character, campo da NJM o qual deseja retornar o valor
*/
Static Function NJMGBFT(cFilRom,cCodRom, cCampo)
	Local aAreaNJM  := NJM->( GetArea() )
	Local cRet := ''

	NJM->(dbGoTop())
	NJM->(dbSetorder(1))
	If NJM->(dbSeek(cFilRom+cCodRom) ) //posiciona na njm do romaneio da venda global futura
		cRet := NJM->&cCampo //pega o campo que esta sendo passado para retornar seu valor
	EndIf

	RestArea( aAreaNJM )
Return cRet

/** {Protheus.doc} PRCRMGBFT 
Busca a media de preco dos fardos do romaneio para a NJM da remessa global futura

@return:	Nil
@author: 	claudineia.reinert
@since: 	23/04/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, filial do romaneio
@param cCodRom, character, código do romaneio
@param cRomGbFt, character, Codigo romaneio da venda global futura
*/
Static Function PRCRMGBFT(cFilRom,cCodRom, cRomGbFt)
	Local nValor 	:= 0
	Local cAliasQry := GetNextAlias()
	Local cQuery 	:= ''
	Local aAltera	:= {}
	Local aRet 		:= {}

	//Busca os fardos da venda global futura conforme os fardos da remessa global futura
	cQuery := " SELECT N9D.N9D_FILIAL AS FILIAL, N9D.N9D_SAFRA AS SAFRA, N9D.N9D_FARDO AS FARDO, 
	cQuery += " N9D.N9D_IDMOV AS IDMOV, N9D.N9D_VLRUNI AS PRECOREM, N9D2.N9D_VLRUNI AS PRECOVND "
	cQuery += " FROM " + RetSqlName('N9D')+ " N9D "
	cQuery += " INNER JOIN " + RetSqlName('N9D')+ " N9D2 ON N9D2.D_E_L_E_T_ = '' " 
	cQuery += " AND N9D2.N9D_FILIAL = N9D.N9D_FILIAL AND N9D2.N9D_FARDO = N9D.N9D_FARDO AND N9D2.N9D_FILORG = N9D.N9D_FILORG  "
	cQuery += " AND N9D2.N9D_TIPMOV = '07' AND N9D2.N9D_STATUS='2' AND N9D2.N9D_CODROM = '"+cRomGbFt+"'  "
	cQuery += " WHERE N9D.D_E_L_E_T_ = '' "
	cQuery += " AND N9D.N9D_FILORG = '" + cFilRom + "' AND N9D.N9D_CODROM = '" + cCodRom + "' "
	cQuery += " AND N9D.N9D_TIPMOV = '07' AND N9D.N9D_STATUS = '2'  "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	DbSelectArea( cAliasQry )  
	WHILE (cAliasQry)->( !Eof() )
		If (cAliasQry)->PRECOREM != (cAliasQry)->PRECOVND //se preço dos fardos da remessa global futura for diferente da venda global futura
			//altera preço do fardo da remessa global futura para igual ao preço do fardo na venda global futura
			aAltera := { { {"N9D_VLRUNI" ,(cAliasQry)->PRECOVND} } }
			aRet    :=  AGRMOVFARD(aAltera, 2 , 1, {{(cAliasQry)->FILIAL},{(cAliasQry)->SAFRA},{(cAliasQry)->FARDO},{(cAliasQry)->IDMOV}} )
		EndIf			
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->( dbCloseArea() )

	//busca media de preço dos fardos do romaneio da remessa global futura
	cAliasQry := GetNextAlias()
	cQuery := " SELECT AVG(N9D_VLRUNI) AS PRECO "
	cQuery += " FROM " + RetSqlName('N9D')+ " N9D "
	cQuery += " WHERE N9D.D_E_L_E_T_ = '' "
	cQuery += " AND N9D_FILORG = '" + cFilRom + "' AND N9D_CODROM = '" + cCodRom + "' "
	cQuery += " AND N9D_TIPMOV = '07' AND N9D_STATUS = '2'  "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	DbSelectArea( cAliasQry )  
	If .Not. (cAliasQry)->( Eof() )
		nValor := (cAliasQry)->PRECO
	EndIf
	(cAliasQry)->( dbCloseArea() )

Return nValor

/** {Protheus.doc} OG250DMPRC
Executa as funções de precificação conforme o tipo do produto retornando o preço medio unitario

@return:	Nil
@author: 	claudineia.reinert
@since: 	19/04/2018
@Uso: 		OGA250 - Romaneio
@param cFilRom, character, filial do romaneio
@param cCodRom, character, codigo do romaneio
@param cIteRom, character, Item do romaneio
@param lUpdRegFis, logico, .T. se atualiza saldos NF regras fiscais
*/
Function OG250DMPRC(cFilRom, cCodRom,cIteRom, lUpdRegFis)
	Local aArea  	:= GetArea() 
	Local aAreaN9A  := N9A->( GetArea() )
	Local aAreaNJM  := NJM->( GetArea() )
	Local aAreaNJR  := NJR->( GetArea() )
	Local nPrecMed 	:= 0
	Local nX		:= 0
	Local aFardos	:= {}
	Local aRetorno	:= {}
	Local cErro     := ''
	Local cCodClient := ""
	Local cCodLoja   := ""	

	DbSelectArea("NJM")
	NJM->(DbSetOrder(1))
	If NJM->(DbSeek(cFilRom+cCodRom+cIteRom))  
		
		//Verifica se possui registro na regra fiscal do contrato, se não achar (Legado) retorna ZERO
		DbSelectArea("N9A")
		N9A->(DbSetOrder(1))
		If .NOT. DbSeek(NJM->NJM_FILORG+NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI)  
			RestArea( aAreaNJM )
			RestArea( aAreaN9A )
			RestArea( aArea )
			aRetorno := {0,''}
			Return aRetorno
		EndIf
		
		//verifica o cliente 
		DbSelectArea("NJ0")
		NJ0->(DbSetOrder(1))
		If NJ0->(DbSeek(xFilial("NJ0")+NJM->NJM_CODENT+NJM->NJM_LOJENT))
			if Posicione('NJR',1,NJM->NJM_FILORG+NJM->NJM_CODCTR,'NJR_TIPO')  == "1" //Compras - fornecedor
				cCodClient     := NJ0->NJ0_CODFOR
				cCodLoja       := NJ0->NJ0_LOJFOR				
			else //vendas - cliente
				cCodClient     := NJ0->NJ0_CODCLI
				cCodLoja       := NJ0->NJ0_LOJCLI				
			endif
		EndIf

		If AGRTPALGOD(NJM->NJM_CODPRO) //SE PRODUTO ALGODÃO
			aFardos := OGX050CTRF("07", NJM->NJM_FILIAL ,  NJM->NJM_CODCTR , NJM->NJM_ITEM, NJM->NJM_SEQPRI, " N9D.N9D_CODINE='"+ NJM->NJM_CODINE +"' AND N9D.N9D_CODROM='"+ NJM->NJM_CODROM +"' AND N9D.N9D_ITEROM ='"+ NJM->NJM_ITEROM +"' ", {"DXI_TIPPRE", "N9D_PESFIM"} ) //pega todos os fardos do romaneio para a regra fiscal, necessario filtro pela Ie pois pode ter mesmo contrato de remessa para Ie diferente
			If Len(aFardos) > 0 //temos fardos vinculados, podemos ter um preço previsto
				//busca o valor das quantidades					            
				aRetorno := OGX050(NJM->NJM_FILORG,  NJM->NJM_CODCTR,  aFardos , NJM->NJM_TES,  N9A->N9A_NATURE, NJM->NJM_ITEM, NJM->NJM_SEQPRI, NJM->NJM_FILIAL, NJM->NJM_CODROM, NJM->NJM_ITEROM, lUpdRegFis, N9A->N9A_TIPCLI, cCodClient, cCodLoja )
				If Empty(aRetorno[2])//não teve erros						
					//monta a média ponderada
					For nX := 1 to len(aRetorno[1])		
						nPrecMed  += aRetorno[1][nX][2] //PREÇO
					Next nX	
					nPrecMed := nPrecMed / len(aRetorno[1]) //Media de preço para a NJM
				Else //Tratamento de erros
					cErro := STR0009 + _CRLF + aRetorno[2] // "Erro no processo de precificação: "
				EndIf
			EndIf					
		Else //SE PRODUTO GRÃOS
			aRetorno := OGX060(NJM->NJM_FILORG, NJM->NJM_CODCTR, NJM->NJM_QTDFIS, NJM->NJM_TES, N9A->N9A_NATURE, NJM->NJM_FILIAL, NJM->NJM_ITEM, NJM->NJM_SEQPRI, NJM->NJM_CODROM, NJM->NJM_ITEROM, lUpdRegFis, N9A->N9A_TIPCLI, cCodClient, cCodLoja )
			If Empty(aRetorno[2])//não teve erros						
				//monta a média ponderada
				nPrecMed  := aRetorno[1][1]
			Else //Tratamento de erros
				cErro := STR0009 + _CRLF + aRetorno[2] // "Erro no processo de precificação: "
			EndIf
		EndIf
		   
	EndIf

	RestArea( aAreaNJM )
	RestArea( aAreaN9A )
	RestArea( aAreaNJR )
	RestArea( aArea )

Return {nPrecMed, cErro}

/** {Protheus.doc} OG250DMVID()
Função que Gera um registro de movto na tabela de movtos do OG.

@param: cCodIE, Código da Instrução de Embarque
@Return:    o id do movto a ser Gerado;
@author: 	Tamyris Ganzenmueller
@since: 	01/02/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OG250DMVID(cCodIE)

	Local cIdMv   := ''
	Local cMsg	  := ''
	Local cTpMov  := SuperGetMV("MV_AGRO009",.F.,'') //Tipo de movimento para Exportação
	Local oMdlNKM := {}
	Local oNKM	  := {}

	If !Empty(cTpMov)

		//Verifica se já existe uma movimentação do tipo Exportação para a IE
		cAliasNKM := GetNextAlias()
		cQry := " SELECT NKM_IDMOV  "
		cQry += "     FROM " + RetSqlName("NKM") + " NKM "
		cQry += "    WHERE NKM.NKM_FILIAL = '" + FWxFilial('NKM') + "'"
		cQry += "      AND NKM.NKM_TIPOMV = '" + cTpMov + "'"
		cQry += "      AND NKM.NKM_CODINE = '" + cCodIE + "'"
		cQry += "      AND NKM.D_E_L_E_T_ = ' ' "	
		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasNKM, .F., .T.) 
		DbselectArea( cAliasNKM )
		DbGoTop()
		If (cAliasNKM)->( !Eof() )
			cIdMv := (cAliasNKM)->NKM_IDMOV
		EndIf
		(cAliasNKM)->(DbCloseArea())

		//Se não existe, gera
		If Empty(cIdMv)
			oMdlNKM := FWLoadModel("OGA440")
			oMdlNKM:SetOperation(3) // Inserção
			oMdlNKM:Activate()
			oNKM := oMdlNKM:GetModel( "NKMUNICO" )

			lRet:= oNKM:SetValue("NKM_FILIAL", FWxFilial("NKM"))
			lRet:= oNKM:SetValue("NKM_TIPOMV", cTpMov)
			lRet:= oNKM:SetValue("NKM_CODINE", cCodIE)

			If (lRet:=oMdlNKM:VldData())
				oMdlNKM:CommitData()
				lContinua := .t.
				cIdMV := FWFLDGET('NKM_IDMOV')   // Identificando o Id do Movto a Ser Gerado
			Else
				cMsg := oMdlNKM:GetErrorMessage()[3] + oMdlNKM:GetErrorMessage()[6]
				AgrHelp(STR0002,cMsg, STR0029  ) //"Ajuda""Verifique os dados da Instrução de Embarque."
				lContinua := .F.
			EndIf

			oMdlNKM:DeActivate()
		EndIf	
	EndIf

Return (cIdMv)

/** {Protheus.doc} ConsRemIE()
Atualiza a quantidade remetida das entregas da IE (Quando Remessa Formação de Lote para IE de Venda)

@param:  nProd, Tipo do Produto : 1 - Grãos, 2 - Algodão
@param:  cFilEnt, Filial da Instrução de Embarque (Grãos) / Romaneio (Algodão)
@param:  cCodEnt, Código da Instrução de Embarque (Grãos) / Romaneio (Algodão)
@param:  nPeso, Peso da Entrega da Instrução de Embarque (Apenas para grãos)
@param:  lAtuc, .T. - Atualização do Romaneio / .F. - Reabertura do Romaneio
@author: francisco.nunes
@since:  20/04/2018
@Uso: 	 SIGAAGR - Originação de Grãos
*/
Function ConsRemIE(nProd, cFilEnt, cCodEnt, nPeso, lAtuc, cCtr, cIteEtg, CIteReF)
	Local aAreaN7S  := N7S->(GetArea())
	Local nPesoN7S  := 0
	Local cAliasQry := ""
	Local cQry		:= ""
	Local cFilCtr	:= ""
	Local cCodCtr	:= ""
	Local cChaveUlt	:= "" // Chave da última regra fiscal da IE (para atualizar o excedente quando grãos)
	Local cChave    := cFilEnt+cCodEnt
	Local cChave2   := ''
	
	Default cCtr    := ''
	Default cIteEtg := ''
	Default CIteReF := ''
	
	 If !Empty(cCtr) .And.  !Empty(cIteEtg) .And.  !Empty(CIteReF)
	 	cChave2 := cCtr + cIteEtg + CIteReF
	 	cChave  += cChave2 
	 EndIf
	 
	If nProd = 1 // Grãos	
		DbSelectArea("N7S")
		N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
		If N7S->(DbSeek(cChave))
			While N7S->(!Eof()) .AND. N7S->(N7S_FILIAL+N7S_CODINE) == cFilEnt+cCodEnt	
				
				If !Empty(cChave2) .And. cChave2 <> N7S->N7S_CODCTR+N7s->N7S_ITEM+N7S->N7S_SEQPRI
					EXIT
				EndIF
				
				If nPeso == 0
					EXIT
				EndIf

				cFilCtr	  := N7S->N7S_FILIAL
				cCodCtr	  := N7S->N7S_CODCTR
				cChaveUlt := N7S->(N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI)

				IF lAtuc
					If nPeso > N7S->N7S_QTDVIN	- N7S->N7S_QTDREM				
						nPesoN7S := N7S->N7S_QTDVIN - N7S->N7S_QTDREM	
					Else
						nPesoN7S := nPeso
					EndIf
				Else
					If nPeso > N7S->N7S_QTDVIN				
						nPesoN7S := N7S->N7S_QTDVIN 
					Else
						nPesoN7S := nPeso
					EndIf
				EndIF

				If nPesoN7S > 0 .AND. Reclock("N7S",.F.)
					If lAtuc										
						N7S->N7S_QTDREM := N7S->N7S_QTDREM + nPesoN7S
					Else
						N7S->N7S_QTDREM := N7S->N7S_QTDREM - nPesoN7S
					EndIf
					N7S->(MsUnlock())
				EndIf				

				nPeso := nPeso - nPesoN7S 				

				N7S->(DbSkip())
			EndDo
		EndIf

		If nPeso > 0 .AND. !Empty(cChaveUlt)
			If lAtuc .AND. !VerExcCtr(cFilCtr, cCodCtr, nPeso) 
				Return .F.
			Else
				DbSelectArea("N7S")
				N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
				If N7S->(DbSeek(cChaveUlt))
					If Reclock("N7S", .F.)
						If lAtuc
							N7S->N7S_QTDREM := N7S->N7S_QTDREM + nPeso
						Else
							N7S->N7S_QTDREM := N7S->N7S_QTDREM - nPeso
						EndIf

						N7S->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf			
	Else
		cAliasQry := GetNextAlias()
		cQry := " SELECT N9D.N9D_CODINE, "
		cQry += "        N9D.N9D_CODCTR, "
		cQry += "        N9D.N9D_ITEETG, "
		cQry += "        N9D.N9D_ITEREF, "
		cQry += "        N9D.N9D_TIPOPE, "
		cQry += "        N9D2.N9D_CODCTR AS IE_CODCTR, "
		cQry += "        N9D2.N9D_ITEETG AS IE_ITEETG, "
		cQry += "        N9D2.N9D_ITEREF AS IE_ITEREF, "
		cQry += "        SUM(N9D.N9D_PESFIM) AS QTDREMET "
		cQry += " FROM " + RetSqlName("N9D") + " N9D "
		cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D2 ON N9D2.D_E_L_E_T_ = '' "
		cQry += " 	  AND N9D2.N9D_FILIAL = N9D.N9D_FILIAL AND N9D2.N9D_FARDO = N9D.N9D_FARDO "
		cQry += "     AND N9D2.N9D_CODINE = N9D.N9D_CODINE AND N9D2.N9D_TIPMOV='04' AND N9D2.N9D_STATUS='2' "
		cQry += " WHERE N9D.N9D_FILORG = '" + cFilEnt + "' "
		cQry += "   AND N9D.N9D_CODROM = '" + cCodEnt + "' "
		cQry += "   AND N9D.N9D_TIPMOV = '07' " 	 
		cQry += "   AND N9D.N9D_STATUS = '2' "
		cQry += "   AND N9D.D_E_L_E_T_ = '' "
		cQry += " GROUP BY N9D.N9D_CODINE, "
		cQry += "	       N9D.N9D_CODCTR, "
		cQry += "          N9D.N9D_ITEETG, "
		cQry += "          N9D.N9D_ITEREF, "
		cQry += "          N9D.N9D_TIPOPE, "
		cQry += "          N9D2.N9D_CODCTR, "
		cQry += "          N9D2.N9D_ITEETG, "
		cQry += "          N9D2.N9D_ITEREF "
		cQry := ChangeQuery(cQry)	
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAliasQry, .F., .T.)

		DbSelectArea(cAliasQry)
		(cAliasQry)->(DbGoTop())
		While (cAliasQry)->(!Eof())
			//QUANDO REMESSA FORMAÇÃO DE LOTE COM IE DE VENDA, O CONTRATO NO FARDO(N9D) DE MOVIMENTO '07' É O CONTRATO DE REMESSA PARA DEPOSITO E OS CONTRATOS NA IE SÃO CONTRATOS DE VENDA
			//NO SELECT ALEM DO CONTRATO DO ROMANEIO TRAZ O CONTRATO DA IE EM QUE O FARDO ESTA VINCULADO E O QUAL FOI RESERVADO, 
			//E ASSIM USA SEMPRE O CONTRATO DA IE PARA ATUALIZAR A N7S
			DbSelectArea("N7S")
			N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
			If N7S->(DbSeek(FWXFilial("N7S")+(cAliasQry)->(N9D_CODINE)+(cAliasQry)->(IE_CODCTR)+(cAliasQry)->(IE_ITEETG)+(cAliasQry)->(IE_ITEREF)))							
				If (cAliasQry)->QTDREMET > 0 .AND. Reclock("N7S",.F.)											
					If lAtuc						
						N7S->N7S_QTDREM := N7S->N7S_QTDREM + (cAliasQry)->QTDREMET
					Else
						N7S->N7S_QTDREM := N7S->N7S_QTDREM - (cAliasQry)->QTDREMET
					EndIf
					N7S->(MsUnlock())
				EndIf			
			EndIf				 		
			(cAliasQry)->(DbSkip())			 		
		EndDo
		(cAliasQry)->(DbCloseArea())		
	EndIf

	RestArea(aAreaN7S)

Return .T.

/** {Protheus.doc} VerExcCtr()
Verifica o excedente por contrato para grãos e algodão

@param:  cFilOrg, Filial do Contrato
@param:  cCodCtr, Código do Contrato
@param:  nPesoExc, Peso excedente para o contrato
@author: francisco.nunes
@since:  20/04/2018
@Uso: 	 SIGAAGR - Originação de Grãos
*/
Static Function VerExcCtr(cFilOrg, cCodCtr, nPesoExc)

	Local lRet       := .T.
	Local lUltLimit  := .F.
	Local nSaldCrt	 := 0
	Local nPsConsCtr := 0	
	Local nQtdCont   := 0
	Local nTotAdtv	 := 0
	Local nQtdExcTo	 := 0
	Local nQtdResta	 := 0

	DbSelectArea("NJR")
	NJR->(DbSetOrder(1)) //NJR_FILIAL+NJR_CODCTR
	If DbSeek(cFilOrg+cCodCtr)

		lUltLimit := .F.

		//Verifica se o contrato controla o saldo por 1-Física, 2=Fiscal
		If NJR->(NJR_CLASSP) == "1"
			If NJR->(NJR_TIPO) $ '2|4' // 2=Venda;4=Armazenagem Em 3
				nSaldCrt := NJR->(NJR_QTDCTR) - NJR->(NJR_QTSFCO) + NJR->(NJR_QTEFCO)					
			Else // 1=Compra;3=Armazenagem De 3
				nSaldCrt := NJR->(NJR_QTDCTR) - NJR->(NJR_QTEFCO) + NJR->(NJR_QTSFCO)
			EndIf
		Else
			If NJR->(NJR_TIPO) $ '2|4' // 2=Venda;4=Armazenagem Em 3
				nSaldCrt := NJR->(NJR_QTDCTR) - NJR->(NJR_QTEFIS) + NJR->(NJR_QTSFIS)					
			Else // 1=Compra;3=Armazenagem De 3
				nSaldCrt := NJR->(NJR_QTDCTR) - NJR->(NJR_QTSFIS) + NJR->(NJR_QTEFIS)
			EndIf
		EndIf

		// Consulta o peso a ser consumido do contrato, que será grava na NJM
		nPsConsCtr := ConsumCtr(2, cFilOrg+cCodCtr)

		// Verifica se o peso consumido do contrato + peso excedente ultrapassa o saldo do contrato
		// Caso sim, realiza as verificações de excedentes			
		// Não realiza a validação de excedente para contrato automático
		If nPsConsCtr + nPesoExc > nSaldCrt	.AND. NJR->(NJR_MODELO) != "3"
			If nSaldCrt = 0
				lUltLimit := .T.
			EndIf

			// Excedente - Não Permite
			If NJR->NJR_TPEXC == "1"
				lUltLimit := .T.
			EndIf

			// Excedente - Última carga
			If NJR->NJR_TPEXC == "2" .AND. nSaldCrt > 0 				
				/* Verifica se possui uma aditação execendente para o contrato, caso possua e o mesmo for última carga,
				já foi excedido e não pode exceder novamente */
				DbSelectArea("NNW")
				NNW->(DbSetOrder(3)) //NNW_FILIAL+NNW_CODCTR+NNW_ADEXCE
				If DbSeek(xFilial("NNW")+cCodCtr+"1")
					lUltLimit := .T.
				EndIf							
			EndIf

			// Excedente - Percentual
			If NJR->NJR_TPEXC == "3" .AND. nSaldCrt > 0 

				/* Busca a quantidade de aditações excedentes realizadas para o contrato para descontar do cálculo 
				do percentual excedente */
				DbSelectArea("NNW")
				NNW->(DbSetOrder(3)) //NNW_FILIAL+NNW_CODCTR+NNW_ADEXCE
				If DbSeek(xFilial("NNW")+cCodCtr+"1")
					While !NNW->(Eof()) .AND. NNW_FILIAL+NNW_CODCTR+NNW_ADEXCE == xFilial("NNW")+cCodCtr+"1"
						nTotAdtv += NNW->NNW_QTDALT

						NNW->(DbSkip())
					EndDo
				EndIf				

				//Quantidade a considerar do contrato
				nQtdCont  := NJR->(NJR_QTDCTR) - nTotAdtv

				//Quantidade excedente tolerada
				nQtdExcTo := (nQtdCont * (NJR->(NJR_TOLENT)/100))

				//Quantidade restante do contrato
				nQtdResta := (nSaldCrt + nQtdExcTo - nTotAdtv)

				// SE a quantidade do romaneio for maior que o saldo restante do contrato (c/ excedente) não deixará continuar
				If nPsConsCtr + nPesoExc > nQtdResta 
					lUltLimit := .T.					
				EndIf			
			EndIf
		EndIf

		// Ultrapassou o limite definido no contrato
		If lUltLimit 				
			Agrhelp(STR0002 , STR0001 + " " + cCodCtr + ".", STR0030) //## O romaneio ultrapassou o saldo permitido para o contrato XXX  ##"Verifique o percentual de excedente do contrato ou se o excedente já foi utilizado."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/** {Protheus.doc} FrdVincRom()
Busca os fardos vinculados no romaneio

@param:  cFilRom, Filial do Romaneio
@param:  cCodRom, Código do Romaneio
@return aFard, Array com campos da N9D :
[1] = R_E_C_N_O_ do fardo na tabela 
[2] = N9D_PESFIM peso fim do fardo
@author: claudineia.reinert
@since:  03/05/2018
@Uso: 	 SIGAAGR - Originação de Grãos
*/
Static function FrdVincRom(cFilRom,cCodRom)
	Local aFard := {}
	Local cAliasQry := ''
	Local cQry := ''
	cAliasQry := GetNextAlias()
	cQry := " SELECT N9D.R_E_C_N_O_, "
	cQry += " N9D.N9D_PESFIM "
	cQry += " FROM " + RetSqlName("N9D") + " N9D "
	cQry += " WHERE N9D.N9D_FILIAL = '" + cFilRom + "' "
	cQry += "   AND N9D.N9D_CODROM = '" + cCodRom + "' "
	cQry += "   AND N9D.N9D_TIPMOV = '07' " 	 
	cQry += "   AND N9D.N9D_STATUS = '2' "
	cQry += "   AND N9D.D_E_L_E_T_ = '' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While (cAliasQry)->(!Eof())
		AADD(aFard, {(cAliasQry)->R_E_C_N_O_ , (cAliasQry)->N9D_PESFIM})

		(cAliasQry)->(DbSkip())		
	EndDo
	(cAliasQry)->(DbCloseArea())


Return aFard

/** {Protheus.doc} SelCtrNJM()
Chama tela para selecionar o contrato de remessa para a NJM

@param:  cCodEnt, Codigo da entidade/cliente
@param:  cLojEnt, Loja da entidade/cliente
@param:  cSafra, Safra
@param:  cProd, Codigo do produto
@param:  cFilRom, Filial do romaneio
@param:  aItRefs, array com os contratos e qtd ja selecionadas 
@param:  aContr, array para armazenar os dados do contrato selecionado
@author: claudineia.reinert
@since:  03/05/2018
@Uso: 	 SIGAAGR - Originação de Grãos
*/
Static Function SelCtrNJM(cCodEnt, cLojEnt, cSafra, cProd, cFilRom, aItRefs,aContr)

	aContr := OGX010BC(OGX010TC('2'), cCodEnt, cLojEnt, cSafra, cProd, .T., cFilRom, aItRefs)

	If !Empty(aContr[3])
		Return .T.
	EndIf

	// Caso tenha encontrado mais de um contrato/regra fiscal, abrir tela para selecionar regras fiscais
	If Empty(aContr[3])
		OGX010CT(OGX010TC('2'), cCodEnt, cLojEnt, cSafra, cProd, .T., .T., cFilRom, aItRefs)
		aContr[1] := __cCodigo //esta variavel vem do OGX010CT como publica
		aContr[2] := __cItEtg
		aContr[3] := __cItRef
		aContr[4] := __cTESRef
		aContr[5] := __nSldRef
	EndIf

	// Caso encontrou o contrato (tem apenas um contrato) e caso não encontrou regra fiscal não possui nenhuma
	// Será apresentado a mensagem para alertar o usuário para criar uma regra fiscal para atender a situação
	If Empty(aContr[3]) .AND. Empty(aContr[1])
		Agrhelp(STR0002 , STR0007, STR0031 ) //## Não foi selecionado ou o sitema não encontrou regras fiscais para apropriação no romaneio ##"No contrato, inclua uma regra fiscal para atender o romaneio."
		Return .F. 				 				
	EndIf  

Return .T.

/** {Protheus.doc} OG250DQDEV
Realiza a quebra da NJM conforme as notas fiscais informadas na N9E (Integrações do Romaneio)

@author: franciso.nunes
@since:  27/03/2018
@Uso: 	 OGA250 - Romaneio
@param   cFilRom, character, filial do romaneio
@param   cCodRom, character, código do romaneio
@return: lRet, logical, .T. - Sucesso; .F. - Erro
*/
Function OG250DQDEV(cFilRom, cCodRom)

	Local lRet      := .T.
	Local nItRom    := 0
	Local aAreaNJJ  := NJJ->(GetArea())
	Local aAreaN9E  := N9E->(GetArea())
	Local aAreaNJM  := NJM->(GetArea())
	Local cEntidade := ""
	Local cLojaEnt  := ""
	Local cSafra	:= ""
	Local cCodPro	:= ""
	Local cUniPro	:= ""
	Local nPesoNJJ  := 0
	Local cLocal	:= ""
	Local nPreco	:= 0
	Local cTES		:= ""
	Local cTpForm   := ""
	Local cSerie	:= ""
	Local cNumNF	:= ""
	Local dEmisNF	:= ""
	Local cEspNF	:= ""
	Local aFldNJM   := {}
	Local aAux	    := {}
	Local cTipo		:= ""
	Local cLote 	:= ""
	Local cTesNJJ	:= ""
	Local lDCO 	:= .F. //se NF origem tem DCO vinculado
	Local lPergDCO  := .T. //pergunta se considera DCO
	Local cConDCO   := '2' //não considera DCO
	Local cOrigem 	:= PADR("7", TAMSX3("N9E_ORIGEM")[1], " ")
	Local nTotQtdNJM := 0
	
	DbSelectArea("NJJ")
	NJJ->(DbSetOrder(1)) // NJJ_FILIAL+NJJ_CODROM
	If NJJ->(DbSeek(cFilRom+cCodRom))
		cTipo	  := NJJ->NJJ_TIPO
		cEntidade := NJJ->NJJ_CODENT
		cLojaEnt  := NJJ->NJJ_LOJENT
		cSafra	  := NJJ->NJJ_CODSAF
		cCodPro	  := NJJ->NJJ_CODPRO
		cUniPro	  := NJJ->NJJ_UM1PRO
		nPesoNJJ  := NJJ->NJJ_PESO3
		cLocal	  := NJJ->NJJ_LOCAL
		cTpForm	  := NJJ->NJJ_TPFORM
		cTesNJJ	  := NJJ->NJJ_TES
		
		If nPesoNJJ == 0
			nPesoNJJ := OG251AQN9E(cFilRom, cCodRom)
		
			If RecLock("NJJ", .F.)				
				NJJ->NJJ_PESO3 := nPesoNJJ
				NJJ->(MsUnlock())
			EndIf
		EndIf
		
		If cTpForm == "2"
			cSerie  := NJJ->NJJ_DOCSER
			cNumNF  := NJJ->NJJ_DOCNUM
			dEmisNF := NJJ->NJJ_DOCEMI
			cEspNF  := NJJ->NJJ_DOCESP
		EndIf		
			
		DbSelectArea("N9E")
		N9E->(DbSetOrder(3)) // N9E_FILIAL+N9E_CODROM+N9E_ORIGEM
		If N9E->(DbSeek(cFilRom+cCodRom+cOrigem))
			While N9E->(!Eof()) .AND. N9E->(N9E_FILIAL+N9E_CODROM+N9E_ORIGEM) == cFilRom+cCodRom+cOrigem
					
				DbSelectArea("N8K")
				N8K->(DbSetOrder(1)) //N8K_FILIAL+N8K_DOC+N8K_SERIE+N8K_CLIFOR+N8K_LOJA+N8K_ITEDOC
				If N8K->(DbSeek(cFilRom+N9E->N9E_DOC+N9E->N9E_SERIE+N9E->N9E_CLIFOR+N9E->N9E_LOJA+N9E->N9E_ITEDOC))
					If !Empty(N8K->N8K_NUMAVI) .AND. !Empty(N8K->N8K_NUMDCO)
						//tem dco vinculado na NF de origem
						If NJJ->NJJ_TIPO == "9"
							cConDCO := '1' //devolução venda sempre vincula DCO
						ElseIf NJJ->NJJ_TIPO == "7" .AND. NJJ->NJJ_TPFORM == "1" 
							//Retorno remessa e formulario proprio sim
							If lPergDCO .and. MsgYesNo(STR0032,STR0033) //"Tem certeza que deseja fechar este romaneio?"###"Fechamento do Romaneio"
								lDCO := .T. //sim, considera DCO na NF de devolução/Retorno
							EndIf
							lPergDCO := .F. //para não perguntar novamente
							cConDCO := IIF(lDCO,'1','2') //1=sim, 2=não
						EndIf
					Else
						cConDCO := '2'
					EndIf
					
					DbSelectArea("NJM")
					NJM->(DbSetOrder(1)) // NJM_FILIAL+NJM_CODROM+NJM_ITEROM
					If NJM->(DbSeek(N8K->N8K_FILIAL+N8K->N8K_CODROM+N8K->N8K_ITEROM))
						nPreco := NJM->NJM_VLRUNI
						If !Empty(cTesNJJ) //se romaneio foi informado TES usa do romaneio
							cTES   := cTesNJJ
						Else
							//senao pela TES da NF de origem busca TES de devolução
							cTES   := Posicione("SF4",1,xFilial("SF4")+NJM->NJM_TES,"F4_TESDV") 
							If !empty(cTES) 
								If RecLock("NJJ", .F.)				
									NJJ->NJJ_TES := cTES
									NJJ->(MsUnlock())
								EndIf
							EndIf
						EndIf
						If !Empty(NJM->NJM_LOTCTL) .AND. Rastro(cCodPro)
							cLote := NJM->NJM_LOTCTL
						EndIf
					EndIf
				EndIf
				
				aAux := {}
				
				/* Comercialização */
				nItRom++
				aAdd(aAux, {'NJM_FILIAL', cFilRom})
				aAdd(aAux, {'NJM_CODROM', cCodRom})
				aAdd(aAux, {'NJM_ITEROM', StrZero(nItRom,2)})
				aAdd(aAux, {'NJM_CODENT', cEntidade})
				aAdd(aAux, {'NJM_LOJENT', cLojaEnt})
				aAdd(aAux, {'NJM_CODSAF', cSafra})
				aAdd(aAux, {'NJM_CODPRO', cCodPro})
				aAdd(aAux, {'NJM_UM1PRO', cUniPro})				
				aAdd(aAux, {'NJM_FILORG', N9E->N9E_FILIE})
				aAdd(aAux, {'NJM_CODINE', N9E->N9E_CODINE})
				aAdd(aAux, {'NJM_CODCTR', N9E->N9E_CODCTR})	
				aAdd(aAux, {'NJM_ITEM',   N9E->N9E_ITEM})
				aAdd(aAux, {'NJM_SEQPRI', N9E->N9E_SEQPRI})			
				aAdd(aAux, {'NJM_VLRUNI', nPreco})
				aAdd(aAux, {'NJM_PERDIV', (N9E->N9E_QTDRET / nPesoNJJ  * 100)})	
				aAdd(aAux, {'NJM_STAFIS', "1"})								
				aAdd(aAux, {'NJM_TPFORM', cTpForm})
				
				If cTpForm == "2"
					aAdd(aAux, {'NJM_DOCSER', cSerie})
					aAdd(aAux, {'NJM_DOCNUM', cNumNF})
					aAdd(aAux, {'NJM_DOCEMI', dEmisNF})
					aAdd(aAux, {'NJM_DOCESP', cEspNF})
				EndIf
				
				aAdd(aAux, {'NJM_QTDFIS', N9E->N9E_QTDRET})
				aAdd(aAux, {'NJM_QTDFCO', N9E->N9E_QTDRET})
				aAdd(aAux, {'NJM_TRSERV', "0"})  // Não
				aAdd(aAux, {'NJM_LOCAL ', cLocal})
				aAdd(aAux, {'NJM_LOTCTL', cLote})
				aAdd(aAux, {'NJM_NMLOT' , ''})
				aAdd(aAux, {'NJM_VLRTOT' , 0 })
				aAdd(aAux, {'NJM_TES', 	  Posicione("SF4",1,xFilial("SF4")+cTES,"F4_TESDV")})
				aAdd(aAux, {'NJM_CONDCO', cConDCO })

				nTotQtdNJM  += N9E->N9E_QTDRET
				
				If cTipo == "7"			
					aAdd(aAux, {'NJM_SUBTIP', '71' }) // (S) RETORNO FORMACAO LOTE
				ElseIf cTipo == "9"
					aAdd(aAux, {'NJM_SUBTIP', '90' }) // (S) DEVOLUÇÃO DE VENDA
				EndIf
				
				If !Empty(N9E->N9E_CODINE)
					aAdd(aAux, {'NJM_IDMOV' , OG250DMVID(N9E->N9E_CODINE)})
				EndIf
				
				aAdd(aFldNJM, aAux)
				
				N9E->(DbSkip())
			EndDo		
		EndIf
	EndIf
	
	RestArea(aAreaNJJ)
	RestArea(aAreaNJM)
	RestArea(aAreaN9E)

	If nTotQtdNJM <> NJJ->NJJ_PSLIQU
		AgrHelp(STR0002,STR0034,STR0035) //Atenção #"Quantidade vinculada das NFs de origem para devolução difere da quantidade fisica do romaneio."###"Vincule a quantidade das NFs de origem para atender a quantidade fisica do romaneio."
		Return .F.
	EndIf
	
	If lRet	
		OG250DGNJM(aFldNJM, cFilRom, cCodRom)									
	EndIf

Return lRet

/*/{Protheus.doc} GetNJMStr
	guarda os dados dos campos antes de serem deletados para a quebra.
	@type  Static Function
	@author mauricio.joao
	@since 07/11/2018
	@version 1.0
	/*/
Static Function GetNJMStr(cFilRom,cCodRom)
	Local aRet := {}
	Local cAliasTmp := GetNextAlias()
	Local aStrNJM := {}
	Local nX := 0

	//puxo todas as informações da linha que será deletada
	BeginSql Alias cAliasTmp
		SELECT *
		FROM 
			%Table:NJM% NJM
		WHERE 
			NJM.%notDel% AND 
			NJM.NJM_FILIAL = %Exp:cFilRom% AND
			NJM.NJM_CODROM = %Exp:cCodRom% 
	EndSQL
   
	//Pego a strutura da tabela NJM
	aStrNJM := NJM->(DBStruct())
  
	//Relaciono Nome do campo x informação do guardada
    for nX := 1 to len(aStrNJM)
		//Se o tipo do campo for tipo Data trato os dados recebidos com STOD
		If aStrNJM[nX][2] = 'D'
		    aAdd(aRet,{aStrNJM[nX][1], STOD((cAliasTmp)->&(aStrNJM[nX][1])) } )
		Else      	
		    aAdd(aRet,{aStrNJM[nX][1], (cAliasTmp)->&(aStrNJM[nX][1])       } )
		EndIf
    Next nX

    (cAliasTmp)->(DbcloseArea())

Return aRet
