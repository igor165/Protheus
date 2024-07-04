#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "OGX030.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

/*{Protheus.doc} OGX030
Função para simulação de cálculo de comissões

@author 	ana.olegini
@since 		27/09/2017
@version 	1.0
*/
Function OGX030(cFilContr, cContrato, cRomaneio, cCorretor, cLjCorret, cTipComs, nVlrUniDoc)
	Local aRetorno 	:= {}

	If .NOT. Empty(cContrato) .AND. .NOT. Empty(cRomaneio) .AND. .NOT. Empty(cCorretor) .AND. .NOT. Empty(cLjCorret) .AND. .NOT. Empty(cTipComs) 
		aRetorno := OGX030CAL(cFilContr, cContrato, cRomaneio, cCorretor, cLjCorret, cTipComs, nVlrUniDoc)	
	EndIf
Return(aRetorno)

Function OGX030CAL(cFilContr, cContrato, cRomaneio, cCorretor, cLjCorret, cTipComs, nVlrUniDoc)
	Local aRetorno   := {}
	Local cTexto	 := ""				//-- PARA LOG DE PROCESSAMENTO - SOMENTE PARA TESTAR A FUNÇÃO DE CALCULO -- SERA RETIRADO
	Local cTemp	     := GetNextAlias()
	Local cQuery	 := ""
	Local lRetorno	 := .T.
	Local nQtdRom	 := 0	//Qtd do Romaneio
	Local nVlrUni	 := 0	//Valor Unitario + complemento
	Local nVlrTot	 := 0	//Valor Total do romaneio + complemento	
	Local nValor1	 := 0	//Resultado 1
	Local nValor2	 := 0	//Resultado 2
	Local nValor3	 := 0	//Resultado 3
	Local nValor4	 := 0	//Resultado 4			
	
	//-- Busca as informações para realizar o calculo.
	cQuery := " SELECT NJR.NJR_CODCTR, NJR.NJR_CODPRO, NJR.NJR_VLRBAS, NJR.NJR_UMPRC, NJR.NJR_FILIAL,"
	cQuery += 		 " NJM.NJM_CODROM, NJM.NJM_UM1PRO, NJM.NJM_QTDFIS, NJM.NJM_QTDFCO, NJM.NJM_VLRUNI, NJM.NJM_FILIAL, "
	cQuery += 		 " NNF.NNF_CODENT, NNF.NNF_LOJENT, NNF.NNF_MODCOM, NNF.NNF_UNIMED, NNF.NNF_VLBCOM, NNF.NNF_QTDCON, NNF.NNF_FATCON"
	cQuery +=   " FROM "+ RetSqlName('NJR')+" NJR"
	cQuery +=  " INNER JOIN "+ RetSqlName('NJM')+" NJM ON NJM.D_E_L_E_T_ = ''"
	cQuery +=                                       " AND NJM.NJM_FILIAL = '"+cFilContr+"'"
	cQuery +=                                       " AND NJM.NJM_CODCTR = NJR.NJR_CODCTR "
	cQuery +=                                       " AND NJM.NJM_CODPRO = NJR.NJR_CODPRO "
	cQuery +=                                       " AND NJM.NJM_CODROM = '"+cRomaneio+"'"'
	cQuery +=  " INNER JOIN "+ RetSqlName('NNF')+" NNF ON NNF.D_E_L_E_T_ = '' "
	cQuery +=                                       " AND NNF.NNF_FILIAL = '"+FWxFilial("NNF")+"'"
	cQuery +=   									" AND NNF.NNF_CODCTR = NJR.NJR_CODCTR "
	cQuery +=   									" AND NNF.NNF_CODENT = '"+cCorretor+"'"
	cQuery +=   									" AND NNF.NNF_LOJENT = '"+cLjCorret+"'"'
	cQuery +=   									" AND NNF.NNF_MODCOM = '"+cTipComs+"'"'
	cQuery +=  " WHERE NJR.D_E_L_E_T_ = '' "
	cQuery +=    " AND NJR.NJR_FILIAL = '"+FWxFilial("NJR")+"'"
	cQuery +=    " AND NJR.NJR_CODCTR = '"+cContrato+"'"
 	cQuery := ChangeQuery( cQuery )

 	//--Identifica se tabela esta aberta e fecha
	If Select(cTemp) <> 0
		(cTemp)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTemp,.T.,.T.)
	If Select(cTemp) <> 0 .AND. lRetorno

		//Quantidade Considerada
		If (cTemp)->NNF_QTDCON == '1'		//[1= Quantidade Fiscal]
			nQtdRom	:= (cTemp)->NJM_QTDFIS
		ElseIf (cTemp)->NNF_QTDCON == '2'	//[2= Quantidade Fisica]
			nQtdRom	:= (cTemp)->NJM_QTDFCO
		EndIf
				
		aAdd(aRetorno,{'COD_CONTRATO'	, cContrato			  })	//Posicao 01
		aAdd(aRetorno,{'COD_CORRETOR'  	, cCorretor			  })	//Posicao 02
		aAdd(aRetorno,{'LOJ_CORRETOR'   , cLjCorret			  })	//Posicao 03
		aAdd(aRetorno,{'COD_ROMANEIO'   , cRomaneio			  })	//Posicao 04
		
		aAdd(aRetorno,{'QTD_ROMANEIO'   , nQtdRom			  })	//Posicao 05
		aAdd(aRetorno,{'VLR_UNT_CTR'    , (cTemp)->NJM_VLRUNI })	//Posicao 06
		
		//#########################################
		//Tipo de Comissao [1= % Valor Contrato ]
		If (cTemp)->NNF_MODCOM == "1"
			
			If (cTemp)->NJM_UM1PRO <> (cTemp)->NNF_UNIMED
			
				//-- funcao AGRX001 do fonte AGRXESP //-- converte quando unidade de medida
				nVlrUM 	:= AGRX001( (cTemp)->NJM_UM1PRO,(cTemp)->NNF_UNIMED ,1,(cTemp)->NJR_CODPRO)
			Else
				//-- funcao AGRX001 do fonte AGRXESP //-- converte quando unidade de medida
				nVlrUM 	:= AGRX001( (cTemp)->NJM_UM1PRO,(cTemp)->NNF_UNIMED ,1 ,(cTemp)->NJR_CODPRO)
			EndIf

			//--------- Vlr Tot do Rom
			nVlrUni := fGetPreco((cTemp)->NJM_FILIAL,  (cTemp)->NJR_FILIAL, cRomaneio,  (cTemp)->NJR_CODCTR, '1', (cTemp)->NJR_UMPRC, (cTemp)->NJM_UM1PRO, (cTemp)->NJR_CODPRO) //precUni := fGetPreco((cTemp)->NJM_FILIAL, (cTemp)->NJR_FILIAL, cRomaneio,  (cTemp)->NJR_CODCTR, '1') //preco vazio												
			nVlrTot := A410Arred( nVlrUni * nQtdRom, 'C6_VALOR')			
			
			//--------- Adiciona os impostos e as notas de complemento
			nVlrTot += nVlrUniDoc				
			
			//--------- Acha o novo valor unitário após adicionar Imposto e Complemento
			If nVlrUniDoc > 0
				nVlrUni := nVlrTot / nQtdRom 
			EndIf
			
			//----------- Vlr Unitario 		+ Complemento * Vlr Conversao
			nValor1 := nVlrUni 
			
			//--- Qtd Romaneio / Vlr Conversao
			nValor2 := nQtdRom * nVlrUM	
			
			//-------- Result2 * Result1 
			nValor3 := nValor2 * nValor1

			//-------- Result3 * (% Ctr Comissao/100)
			nValor4 := A410Arred( nValor3 * ((cTemp)->NNF_VLBCOM/100), 'C6_VALOR') 

			//--------------- ARRAY RETORNA ROTINA OGC100 --------------------------
			aAdd(aRetorno,{'UM_ROMANEIO'	, (cTemp)->NJM_UM1PRO	})	//Posicao 07
			aAdd(aRetorno,{'UM_CORRETOR'  	, (cTemp)->NNF_UNIMED	})	//Posicao 08
			aAdd(aRetorno,{'VLR_CONVERS'    , nVlrUM				})	//Posicao 09
			aAdd(aRetorno,{'VLR_UNITAR'     , nVlrUni				})	//Posicao 10
			aAdd(aRetorno,{'VLR_CONS_CORR'  , (cTemp)->NNF_VLBCOM	})	//Posicao 11
			aAdd(aRetorno,{'VLR_COMISSAO'   , nValor4				})	//Posicao 12
			aAdd(aRetorno,{'FATOR_CONVERS'  , 0						})	//Posicao 13
			aAdd(aRetorno,{'VLR_COMPLEMEN' 	, nVlrTot				})	//Posicao 14
			aAdd(aRetorno,{'VLR_BASE' 		, nValor3				})	//Posicao 15		


		//#########################################
		//Tipo de Comissao [2= Valor ]
		ElseIf (cTemp)->NNF_MODCOM == "2"

			//-- Se unidade de medida do romaneio for diferente da unidade de medida da comissão
			If (cTemp)->NJM_UM1PRO <> (cTemp)->NNF_UNIMED
				//-- funcao AGRX001 do fonte AGRXESP //-- converte quando unidade de medida
				nVlrUM 	:= AGRX001( (cTemp)->NJM_UM1PRO,(cTemp)->NNF_UNIMED ,1,(cTemp)->NJR_CODPRO)
			Else
				//-- funcao AGRX001 do fonte AGRXESP //-- converte quando unidade de medida
				nVlrUM 	:= AGRX001( (cTemp)->NJM_UM1PRO,(cTemp)->NNF_UNIMED ,1,(cTemp)->NJR_CODPRO)
			EndIf
			
			nVlrUni := fGetPreco((cTemp)->NJM_FILIAL,  (cTemp)->NJR_FILIAL, cRomaneio,  (cTemp)->NJR_CODCTR, '1', (cTemp)->NJR_UMPRC, (cTemp)->NJM_UM1PRO, (cTemp)->NJR_CODPRO) //precUni := fGetPreco((cTemp)->NJM_FILIAL, (cTemp)->NJR_FILIAL, cRomaneio,  (cTemp)->NJR_CODCTR, '1') //preco vazio																	
			
			//--------- Vlr Tot Uni Fixação			
			nVlrTot := A410Arred( nVlrUni * nQtdRom, 'C6_VALOR')
								
			//--- Qtd Romaneio / Vlr Conversao
			nValor1	:= nQtdRom * nVlrUM 
		
			//------------------- Result1 * Qtd Considerada
			nValor2	:= A410Arred( nValor1 * (cTemp)->NNF_VLBCOM , 'C6_VALOR')

			//--------------- ARRAY RETORNA ROTINA OGC100 --------------------------
			aAdd(aRetorno,{'UM_ROMANEIO'	, (cTemp)->NJM_UM1PRO	})	//Posicao 07
			aAdd(aRetorno,{'UM_CORRETOR'  	, (cTemp)->NNF_UNIMED	})	//Posicao 08
			aAdd(aRetorno,{'VLR_CONVERS'    , nVlrUM				})	//Posicao 09
			aAdd(aRetorno,{'VLR_UNITAR'     , nVlrUni				})	//Posicao 10
			aAdd(aRetorno,{'VLR_CONS_CORR'  , (cTemp)->NNF_VLBCOM	})	//Posicao 11
			aAdd(aRetorno,{'VLR_COMISSAO'   , nValor2				})	//Posicao 12
			aAdd(aRetorno,{'FATOR_CONVERS'  , 0						})	//Posicao 13
			aAdd(aRetorno,{'VLR_COMPLEMEN' 	, nVlrTot  				})	//Posicao 14
			aAdd(aRetorno,{'VLR_BASE' 		, nValor1				})	//Posicao 15			

		//#########################################
		//Tipo de Comissao [3= Pontos ]
		ElseIf (cTemp)->NNF_MODCOM == "3"

			//-- Se unidade de medida do romaneio for diferente da unidade de medida da comissão
			If (cTemp)->NJM_UM1PRO <> (cTemp)->NNF_UNIMED
				//-- funcao AGRX001 do fonte AGRXESP //-- converte quando unidade de medida
				nVlrUM 	:= AGRX001( (cTemp)->NJM_UM1PRO,(cTemp)->NNF_UNIMED ,1,(cTemp)->NJR_CODPRO)
			Else
				//-- funcao AGRX001 do fonte AGRXESP //-- converte quando unidade de medida
				nVlrUM 	:= AGRX001( (cTemp)->NJM_UM1PRO,(cTemp)->NNF_UNIMED ,1,(cTemp)->NJR_CODPRO)
			EndIf

			
			//--------- Vlr Tot Uni Fixação
			nVlrUni := fGetPreco((cTemp)->NJM_FILIAL,  (cTemp)->NJR_FILIAL, cRomaneio,  (cTemp)->NJR_CODCTR, '1', (cTemp)->NJR_UMPRC, (cTemp)->NJM_UM1PRO, (cTemp)->NJR_CODPRO) //precUni := fGetPreco((cTemp)->NJM_FILIAL, (cTemp)->NJR_FILIAL, cRomaneio,  (cTemp)->NJR_CODCTR, '1') //preco vazio																	 
			nVlrTot := A410Arred( nVlrUni * nQtdRom, 'C6_VALOR')

			//--- Qtd Romaneio / Vlr Conversao
			nValor1	:= nQtdRom * nVlrUM 

			//-------- Result1 * Qtd Considerada
			nValor2	:= nVlrTot * (cTemp)->NNF_VLBCOM
			
			//------------------- Result2 / Fator de Conversao
			nValor3 := A410Arred( nValor2 / (cTemp)->NNF_FATCON , 'C6_VALOR') 
			
			//--------------- ARRAY RETORNA ROTINA OGC100 --------------------------
			aAdd(aRetorno,{'UM_ROMANEIO'	, (cTemp)->NJM_UM1PRO	})	//Posicao 07
			aAdd(aRetorno,{'UM_CORRETOR'  	, (cTemp)->NNF_UNIMED	})	//Posicao 08
			aAdd(aRetorno,{'VLR_CONVERS'    , nVlrUM				})	//Posicao 09
			aAdd(aRetorno,{'VLR_UNITAR'     , nVlrUni				})	//Posicao 10
			aAdd(aRetorno,{'VLR_CONS_CORR'  , (cTemp)->NNF_VLBCOM	})	//Posicao 11
			aAdd(aRetorno,{'VLR_COMISSAO'   , nValor3				})	//Posicao 12
			aAdd(aRetorno,{'FATOR_CONVERS'  , (cTemp)->NNF_FATCON	})	//Posicao 13
			aAdd(aRetorno,{'VLR_COMPLEMEN' 	, nVlrTot				})	//Posicao 14
			aAdd(aRetorno,{'VLR_BASE' 		, nValor2				})	//Posicao 15			

		EndIf	
	EndIF

	//---------------------------------------------------------------------------------------
	//-- LOG DE PROCESSAMENTO - SOMENTE PARA TESTAR A FUNÇÃO DE CALCULO -- SERA RETIRADO
	AutoGrLog(cTexto)
	//MostraErro()

	//-- Fecha tabela temporaria
   (cTemp)->(dbCloseArea())
Return(aRetorno)

/*{Protheus.doc} OGX030
Função para cálculo de comissões para agents comissionados do processo de exportacao
@author 	Vanilda.moggio / filipe.olegini
@since 		19/01/2018	
@version 	2.0
*/
Function OGX030C2(cFilOrg, cContrato, nVlrUniCal, nQtdIe)
	Local cAliasNNF	:= GetNextAlias()
	Local cForn     := GetNextAlias()
	Local cQuery	:= ""
	Local nVlrUM	:= 1
	Local nUMVlr	:= 1    //conversão unidade de medida preço contrato
	Local nValor1	:= 0	//valor unitário
	Local nValor2	:= 0	//quantidade convertida
	Local nValor3	:= 0	//valor total base
	Local nValor4	:= 0	//% da comissão
	Local nValor5	:= 0	//Valor da comissão
	Local nValor6	:= 0	//Valor da comissão em Reais
	Local aRetorno  := {}
	Local cAgente   := ""
	
	Default	nVlrUniCal := 0 //valor unitário por parametro

	//--Identifica se tabela esta aberta e fecha
	If Select(cAliasNNF) <> 0
		(cAliasNNF)->(dbCloseArea())
	EndIf

	//BUSCA OS DADOS DO CONTRATO E AGENTES DE COMISSAO
	cQuery := " SELECT NJR.NJR_CODCTR,"
	cQuery += 		 " NJR.NJR_CODPRO,"
	cQuery += 		 " NJR.NJR_VLRBAS,"
	cQuery += 		 " NJR.NJR_VLRUNI,"
	cQuery += 		 " NJR.NJR_UM1PRO,"
	cQuery += 		 " NJR.NJR_UMPRC,"
	cQuery += 		 " NJR.NJR_MOEDA, "
	cQuery += 		 " NNF.NNF_CODENT,"
	cQuery += 		 " NNF.NNF_LOJENT,"
	cQuery += 		 " NNF.NNF_MODCOM,"
	cQuery += 		 " NNF.NNF_UNIMED,"
	cQuery += 		 " NNF.NNF_VLBCOM,"
	cQuery += 		 " NNF.NNF_QTDCON,"
	cQuery += 		 " NNF.NNF_FATCON,"
	cQuery += 		 " NNF.NNF_TXMOED,"
	cQuery += 		 " NNF.NNF_TIPCOM "
	cQuery +=   " FROM " + RetSqlName('NJR')+" NJR"
	cQuery +=  " INNER JOIN "+ RetSqlName('NNF')+" NNF ON (NNF.D_E_L_E_T_ = NJR.D_E_L_E_T_ AND "
	cQuery +=											 " NNF.NNF_FILIAL = '" + FWxFilial("NNF") + "' AND "
	cQuery += 		 									 " NNF.NNF_CODCTR = NJR.NJR_CODCTR)"
	cQuery +=  " WHERE NJR.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NJR.NJR_FILIAL = '" + FWxFilial("NJR") + "' "
	cQuery +=    " AND NJR.NJR_CODCTR = '" + cContrato + "'"
	
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNNF,.T.,.T.)

	While (cAliasNNF)->(!EoF())

		//verifica se o valor unitário vem do parametro
		If nVlrUniCal = 0
			//se não tiver valor por parametro o valor unitário vem do contrato
			If (cAliasNNF)->NJR_VLRUNI > 0
				nValor1 := (cAliasNNF)->NJR_VLRUNI
			Else
				nValor1 := (cAliasNNF)->NJR_VLRBAS
			EndIf
		Else
			nValor1 := nVlrUniCal
		EndIf

		nUMVlr := 1
		//se forem diferentes converte a unidade de medida para comissão
		If (cAliasNNF)->NJR_UM1PRO <> (cAliasNNF)->NNF_UNIMED 
			nUMVlr := AGRX001( (cAliasNNF)->NJR_UM1PRO,(cAliasNNF)->NNF_UNIMED ,1 ,(cAliasNNF)->NJR_CODPRO)
			nValor1 := nValor1 * nUMVlr
		EndIf

		nVlrUM := 1 //valor padrão
		//converte a unidade de medida do valor unitário do contrato
		If (cAliasNNF)->NJR_UM1PRO <> (cAliasNNF)->NJR_UMPRC 
			nVlrUM  := AGRX001( (cAliasNNF)->NJR_UM1PRO,(cAliasNNF)->NJR_UMPRC ,1 ,(cAliasNNF)->NJR_CODPRO)
		EndIf	

		//calcula a quantidade na UM da comissao com base na quantidade da IE
		nValor2 := nQtdIe * nVlrUM

		//Tipo de Comissao [1= % Valor Contrato ]
		If (cAliasNNF)->NNF_MODCOM == "1"
			
			//calcula o valor total com base na quantidade da IE
			nValor3 := A410Arred( nValor1 * nQtdIe, 'C6_VALOR')
			
			nValor4 := (cAliasNNF)->NNF_VLBCOM
			nValor5	:= A410Arred(((nValor4 * nValor3) / 100), 'C6_VALOR') //valor da comissão
                                                 
		//Tipo de Comissao [2= Valor ]
		ElseIf (cAliasNNF)->NNF_MODCOM == "2"
			
			//Calcula o valor aplicando o valor informado na corretagem * a quantidade convertida (nvalor2)
			nValor5 := A410Arred( ((cAliasNNF)->NNF_VLBCOM * nValor2), 'C6_VALOR') //valor ca comissão
			
			//calcula o % com base no valor total da IE
			nValor3 := A410Arred( nValor1 * nQtdIe, 'C6_VALOR')
			nValor4 := (nValor5 * 100) / nValor3 //% de comissão

		//Tipo de Comissao [3= Pontos ]
		ElseIf (cAliasNNF)->NNF_MODCOM == "3"

			//Fator de Conversao for zero, considera como 1
			If  (cAliasNNF)->NNF_FATCON > 0 
				nValor5 := A410Arred( (((cAliasNNF)->NNF_VLBCOM / (cAliasNNF)->NNF_FATCON) * nValor2), 'C6_VALOR')
			else    		
				nValor5 := A410Arred( (((cAliasNNF)->NNF_VLBCOM / 1) * nValor2), 'C6_VALOR')
			EndIf
			
			//calcula o % de comissão com base no valor total da IE
			nValor3 := A410Arred( nValor1 * nQtdIe, 'C6_VALOR')
			nValor4 := (nValor5 * 100) / nValor3 //% de comissão

		EndIf
        	
		//-- Busca as informações para realizar o calculo.
		cQuery := " SELECT SY5.Y5_COD, SY5.Y5_TIPOAGE "	
		cQuery +=   " FROM "+ RetSqlName('SY5')+ " SY5"
		cQuery +=  " WHERE SY5.D_E_L_E_T_ = '' "
		cQuery +=    " AND SY5.Y5_FILIAL  = '" + FWxFilial("SY5") + "'"	
		cQuery +=    " AND SY5.Y5_FORNECE = '" + (cAliasNNF)->NNF_CODENT + "'"
		cQuery +=    " AND SY5.Y5_LOJAF   = '" + (cAliasNNF)->NNF_LOJENT + "'"
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cForn,.T.,.T.)
		
		//não é necessário validar aqui pois esse cadastro na SY5 já é validado na tela de contrato aba corretagem.
		If Select(cForn) <> 0 
			cAgente := (cForn)->Y5_COD
			cTipAge	:= (cForn)->Y5_TIPOAGE
		EndIf
		(cForn)->(dbCloseArea())

		//se a modea for diferente de 1 faz a converão para reais
		If (cAliasNNF)->NJR_MOEDA <> 1 
			nValor6 := A410Arred( (nValor5 * (cAliasNNF)->NNF_TXMOED), 'C6_VALOR')
		Else
			nValor6 := nValor5 //valor ja é em reais
		EndIf

		//grava o retorno	
		aAdd(aRetorno, {cFilOrg,;
						cFilOrg + cAgente,; 
						cAgente,; 
						cTipAge,;  
						(cAliasNNF)->NJR_UM1PRO,;
						(cAliasNNF)->NNF_UNIMED,;
						nValor1,; //Valor unitário
						nValor2,; //qtd convertida para qtd comissão
						nValor3,; //valor total base
						nValor4,; // % de comissão 
						nValor5,; //valor da comissão
						nValor6,; //valor da comissão em reais
						(cAliasNNF)->NJR_MOEDA,; //moeda do contrato
						(cAliasNNF)->NNF_TXMOED,; //taxa da moeda informada no contrato
						(cAliasNNF)->NNF_TIPCOM,; //retorno o tipo de comissão
						(cAliasNNF)->NNF_CODENT + (cAliasNNF)->NNF_LOJENT}) //codigo e loja do corretor

		(cAliasNNF)->(dbSkip())
	EndDo

	//Fecha tabela temporaria
	(cAliasNNF)->(dbCloseArea())

Return(aRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetPreco
Busca valor vazio consumido no romaneio.
@author  rafael.voltz
@since   14/07/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function fGetPreco(cFilOrg, cFilContr, cRomaneio,  cContrato, cTipoPrec,  cUMPRC, cUM1PRO, cCODPRO)
	Local cAliasQry := GetNextAlias()
	Local nValor    := 0
	Local nValUnit  := 0	

	BeginSQL Alias cAliasQry
		SELECT N8T_VALOR VALOR, N8T_TAXCOT COTACAO
		  FROM %table:N8T%
		 WHERE N8T_FILIAL = %Exp:cFilOrg%
		   AND N8T_CODROM = %Exp:cRomaneio%
		   AND N8T_FILCTR = %Exp:cFilContr%
		   AND N8T_CODCTR = %Exp:cContrato%
		   AND N8T_TIPPRC = %Exp:cTipoPrec%
		   AND %NotDel%
	EndSQL

	While (cAliasQry)->(!Eof())		
		
		nValUnit := OGX700UMVL((cAliasQry)->VALOR, cUMPRC, cUM1PRO, cCODPRO)			

		If (cAliasQry)->COTACAO > 0			
			nValor += nValUnit * (cAliasQry)->COTACAO 
		Else
			nValor += nValUnit
		EndIf

		(cAliasQry)->(dbSkip())
	Enddo	

	(cAliasQry)->(dbCloseArea())

Return nValor
