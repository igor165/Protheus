#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA570.ch"

//----------------------------------------------------------------------//
//- Função para solicitação de frete de forma automática ao incluir IE -//
//----------------------------------------------------------------------//

Function AGRX570SFA(oModelN7S, oModelN7Q)			    		   
	Local aSaveArea := GetArea()
	Local lRet		:= .T.
	Local aSolicN7S := {}
	Local aSomaN7S  := {}
	Local aValAlg	:= {}
	Local aVExAlg	:= {}
	Local aValores	:= {}

	Local lAlgodao  := if(Posicione("SB5",1,fwxFilial("SB5")+oModelN7Q:GetValue("N7Q_CODPRO"),"B5_TPCOMMO")== '2',.T.,.F.)
	Local lExterno	:= oModelN7Q:GetValue("N7Q_TPMERC") = '2'

	Local cFilOrg 	:= ""
	Local cFilEnt 	:= ""
	Local cGU3Org	:= ""	
	Local cGU3Ent	:= ""
	Local cOpLog    := ""
	Local cCdClFr   := ""
	Local cUnPrc	:= ""
	Local cUMOrig	:= ""	
	Local cCodClient:= ""	
	Local cCodLoja	:= ""
	Local cVlt2Mo   := 0
	Local dDtLimi   
	Local dDtInic
	Local dDtTerm
	Local nI
	Local lMudouFil	:= .F.
	Local nQtdFrd	:= 0
	Local cFilAtu	:= ""
	Local nQtdSoma	:= 0

    For nI := 1 To oModelN7S:Length()
    	oModelN7S:GoLine(nI)
    	
    	If oModelN7S:GetValue('N7S_QTDVIN') > 0

			cFilOrg 	:= POSICIONE('NJ0',5,FWxFilial('N7S') + oModelN7S:GetValue("N7S_FILORG"), "NJ0_CGC" )  
	    	cFilEnt 	:= POSICIONE('NJ0',1,FWxFilial('N7Q') + IIF(EMPTY(oModelN7Q:GetValue("N7Q_ENTENT")),oModelN7Q:GetValue("N7Q_IMPORT"),oModelN7Q:GetValue("N7Q_ENTENT")) + IIF(EMPTY(oModelN7Q:GetValue("N7Q_LOJENT")),oModelN7Q:GetValue("N7Q_IMLOJA") ,oModelN7Q:GetValue("N7Q_LOJENT")), "NJ0_CGC" )
	    	cCodClient	:= POSICIONE('NJ0',5,FWxFilial('N7S') + oModelN7S:GetValue("N7S_FILORG"), "NJ0_CODENT" )  
	    	cCodLoja	:= POSICIONE('NJ0',5,FWxFilial('N7S') + oModelN7S:GetValue("N7S_FILORG"), "NJ0_LOJENT" )  
	    	
			cGU3Org 	:= GETDATASQL("SELECT GU3_CDEMIT FROM " + RetSqlName("GU3") + " WHERE GU3_IDFED = '" + cFilOrg +"' ")
			cGU3Ent 	:= GETDATASQL("SELECT GU3_CDEMIT FROM " + RetSqlName("GU3") + " WHERE GU3_IDFED = '" + cFilEnt +"' ")
			
			cOpLog  	:= Posicione('NJU',1,FWxFilial('NJU')+oModelN7Q:GetValue("N7Q_CODSAF"),"NJU_OPELOG")
			cCdClFr 	:= POSICIONE("GUK", 1, FWxFilial("GUK") + PADR(AllTrim(oModelN7Q:GetValue("N7Q_CODPRO")), TamSX3("GUK_ITEM")[1]), "GUK_CDCLFR")
			
			/*------ PEGAR O VALOR BASEADO NA REGRA FISCAL -------*/
			//GRAOS MERCADO INTERNO REMESSA ou EXTERNO
			//OGAX721 === PEGA O N8D_VALOR PARA USAR COMO TOTAL NA REQUISIÇÃO DA FRETE.
			aValores := OGAX721FAT(FWxFilial('N9A') , oModelN7S:GetValue("N7S_CODCTR"), oModelN7S:GetValue("N7S_ITEM") , oModelN7S:GetValue("N7S_SEQPRI"), , oModelN7S:GetValue("N7S_QTDVIN"), , cCodClient, cCodLoja, /*cFormCalc*/, /*nQtdConsum*/, /*nQtdUsTot*/, /*dDataVenc*/)
			
			if EMPTY(aValores)
				cVlt2Mo := Posicione('N9A',1,FWxFilial('N9A')+oModelN7S:GetValue("N7S_CODCTR")+oModelN7S:GetValue("N7S_ITEM")+oModelN7S:GetValue("N7S_SEQPRI"),"N9A_VLUFPR")
			else
				//Valor unitário em REAL/SC
				cVlt2Mo := aValores[1][1]
				
				//Unidade de medida do contrato
				cUnPrc  := Posicione('NJR',1,FWxFilial('NJR')+ oModelN7S:GetValue("N7S_CODCTR"),"NJR_UM1PRO")
				
				//Unidade de medida de preço do produto 
				cUMOrig := AGRUmPrc(oModelN7Q:GetValue("N7Q_CODPRO"))
				
				//Converte o valor pra unidade de medida de preço do produto
				cVlt2Mo := AGRX001(cUnPrc, cUMOrig, cVlt2Mo, oModelN7Q:GetValue("N7Q_CODPRO"))
			endIf				
			/*------ PEGAR O VALOR BASEADO NA REGRA FISCAL -------*/
			
			//tipo mercado 2=Externo
			If oModelN7Q:GetValue("N7Q_TPMERC") == '2'
				dDtLimi  := oModelN7Q:GetValue("N7Q_DDELDR")
				dDtTerm  := ""
				dDtInic  := ""
			//tipo mercado 1=Interno
			Else
				dDtLimi  := oModelN7S:GetValue("N7S_DATFIM")
				dDtTerm  := oModelN7S:GetValue("N7S_DATFIM")
				dDtInic  := oModelN7S:GetValue("N7S_DATINI")
			EndIf
			
			//ALGODAO
			if lAlgodao
				//Pega a quantidade instruida
				aValAlg := GetDataSqA("SELECT SUM(N83_QUANT), SUM(N83_PSBRUT) FROM " + RetSqlName('N83') + " N83 "+;
									  "WHERE N83.N83_FILIAL 	= '" + oModelN7Q:GetValue("N7Q_FILIAL") + "' "+;
									        "AND N83.N83_CODCTR = '" + oModelN7S:GetValue("N7S_CODCTR") + "' "+;
									        "AND N83.N83_CODINE = '" + oModelN7Q:GetValue("N7Q_CODINE") + "' "+; 
									        "AND N83.N83_ITEM   = '" + oModelN7S:GetValue("N7S_ITEM")   + "' "+;
									        "AND N83.N83_ITEREF = '" + oModelN7S:GetValue("N7S_SEQPRI") + "' "+;
									        "AND N83.D_E_L_E_T_ = ' ' ")
				//aValAlg[1] = QUANTIDADE DE FARDINHOS INSTRUIDOS
				//aValAlg[2] = PESO BRUTO DA INSTRUÇÃO
				if lExterno
					aVExAlg :=  GetDataSqA ("SELECT SUM(N9D.N9D_PESINI), SUM(DXI.DXI_PSTARA), COUNT(*) FROM " + RetSqlName('N9D') + " N9D " +;
											  "INNER JOIN " + RetSqlName('DXI') + " DXI ON DXI.D_E_L_E_T_ = ' ' " +;
											       "AND DXI.DXI_FILIAL = N9D.N9D_FILIAL " +;
											       "AND DXI.DXI_SAFRA = N9D.N9D_SAFRA " +;
											       "AND DXI.DXI_ETIQ = N9D.N9D_FARDO " +;
											  "INNER JOIN " + RetSqlName('N9D') + " N9D2 ON N9D2.D_E_L_E_T_ = ' ' " +;
												   "AND N9D2.N9D_FILIAL = N9D.N9D_FILIAL " +;
												   "AND N9D2.N9D_SAFRA = N9D.N9D_SAFRA " +;
												   "AND N9D2.N9D_FARDO = N9D.N9D_FARDO " +;
												   "AND N9D2.N9D_TIPMOV = '04' " +;
												   "AND N9D2.N9D_STATUS = '2' " +;
											  "WHERE N9D2.N9D_FILORG    = '" + oModelN7S:GetValue("N7S_FILIAL") + "' " +;
											       "AND N9D2.N9D_CODINE = '" + oModelN7S:GetValue("N7S_CODINE") + "' " +;
											       "AND N9D2.N9D_CODCTR = '" + oModelN7S:GetValue("N7S_CODCTR") + "' " +;
											       "AND N9D2.N9D_ITEETG = '" + oModelN7S:GetValue("N7S_ITEM") + "' "   +;
											       "AND N9D2.N9D_ITEREF = '" + oModelN7S:GetValue("N7S_SEQPRI") + "' " +;
											       "AND N9D.N9D_STATUS = '2' "+;
											       "AND N9D.N9D_TIPMOV = '07' "+;
											       "AND N9D.D_E_L_E_T_ = ' '")
					
					//aVExAlg[1] = TOTAL LIQUIDO
					//aVExAlg[2] = TARA DE ACORDO COM A DXI
					//aVExAlg[3] = QUANTIDADE DE FARDINHOS
					
					//Pega a quantidade instruida e diminui a quantidade que já foi remetida(Que está no porto)
					aValAlg[2] := aValAlg[2] - (aVExAlg[1] + aVExAlg[2])
					//  quantidade instruida - quantidade remetida(que está no porto)
					aValAlg[1] := aValAlg[1] - aVExAlg[3]
				endIf
												
				aAdd(aSolicN7S,{oModelN7S:GetValue("N7S_FILORG"),;  //1 - filial origem
				                oModelN7Q:GetValue("N7Q_CODINE"),;  //2 - instrução embarque
				                oModelN7S:GetValue("N7S_ITEM"),  ;  //3 - ID entrega fiscal
				                oModelN7S:GetValue("N7S_CODROM"),;  //4 - romaneio
				                aValAlg[2],;                        //5 - quantidade instruída (negociada)
				                0,;                                 //6 - saldo negociado
				                oModelN7S:GetValue("N7S_CODCTR"),;  //7 - contrato  
				                oModelN7S:GetValue("N7S_SEQPRI"),;  //8 - sequencia 
				                dDtTerm,;  							//9 - Data fim
				                cGU3Org,;  							//10- Filial de origem
				                cGU3Ent,;  							//11- Filial destino
				                oModelN7Q:GetValue("N7Q_UNIMED"),;  //12- unidade medida
				                dDtInic,;  							//13- data ini
				                cOpLog, ;  							//14- operacao logistica
				                (cVlt2Mo * aValAlg[2]),;  			//15- valor total fixação
				                oModelN7Q:GetValue("N7Q_OBSERV"),;  //16- observação N7Q	                
				                aValAlg[1],;  						//17 - Quantidade de fardos
								cCdClFr,;  							//18 - Codigo da Clas. Fret de acordo com produto na tabela de item com exceção
								dDtLimi})  							//19 - data limite

//				aAdd(aSomaN7S,{oModelN7S:GetValue("N7S_FILORG"),;   //1 - filial origem
//			                   aValAlg[2],;                         //2 - quantidade instruída (negociada)
//			                   oModelN7Q:GetValue("N7Q_CODINE"),;   //3 - instrução embarque (Ident Demand)                   
//			                   aValAlg[1]}) 						//4 - Qtd acumulado por filial
			
			//GRAOS
			Else 
				aAdd(aSolicN7S,{oModelN7S:GetValue("N7S_FILORG"),;  //1 - filial origem
				                oModelN7Q:GetValue("N7Q_CODINE"),;  //2 - instrução embarque
				                oModelN7S:GetValue("N7S_ITEM"),  ;  //3 - ID entrega fiscal
				                oModelN7S:GetValue("N7S_CODROM"),;  //4 - romaneio
				                oModelN7S:GetValue("N7S_QTDVIN"),;  //5 - quantidade instruída (negociada)
				                0,;                                 //6 - saldo negociado
				                oModelN7S:GetValue("N7S_CODCTR"),;  //7 - contrato  
				                oModelN7S:GetValue("N7S_SEQPRI"),;  //8 - sequencia 
				                dDtTerm,;  							//9 - Data fim
				                cGU3Org,;  							//10- Filial de origem
				                cGU3Org,;  							//11- Filial destino
				                oModelN7Q:GetValue("N7Q_UNIMED"),;  //12- unidade medida
				                dDtInic,;  							//13- data ini
				                cOpLog, ;  							//14- operacao logistica
				               (cVlt2Mo),;  //15- valor total fixação
				                oModelN7Q:GetValue("N7Q_OBSERV"),;  //16- observação N7Q	                
				                oModelN7S:GetValue("N7S_QTDVIN"),;  //17 - Quantidade de fardos
								cCdClFr,;  							//18 - Codigo da Clas. Fret de acordo com produto na tabela de item com exceção
								dDtLimi})  							//19 - data limite

//				aAdd(aSomaN7S,{oModelN7S:GetValue("N7S_FILORG"),;   //1 - filial origem
//			                   oModelN7S:GetValue("N7S_QTDVIN"),;   //2 - quantidade instruída (negociada)
//			                   oModelN7Q:GetValue("N7Q_CODINE"),;   //3 - instrução embarque (Ident Demand)                   
//			                   oModelN7S:GetValue("N7S_QTDVIN")}) 	//4 - Qtd acumulado por filial
			endIf
		EndIf
	Next nI
	
	/*AGRUPA POR FILIAL*/
	//ordena array pelo campo N7S_FILORG
	ASORT(aSolicN7S, , , { | x,y | x[1] < y[1] } )
    
    //atribui valor da primeira linha e coluna
	cFilAtu := aSolicN7S[1][1]
	
	//inclui array com quantidade acumulada por filial
	For nI := 1 To Len(aSolicN7S)
		//Se filial da posição do array for igual filial atual
		If aSolicN7S[nI][1] == cFilAtu
		    lMudouFil := .T.
		    cCodIne   := aSolicN7S[nI][2]

		    if lAlgodao
		    	nQtdFrd := nQtdFrd + aSolicN7S[nI][17]
		    endIf		    
			//se quantidade negociada for informada
			If aSolicN7S[nI][5] > 0 
			   //soma o valor da quantidade para mesma filial
			   nQtdSoma := nQtdSoma + aSolicN7S[nI][5] 
			//senão atribui valor do saldo negociado
			Else
			   //soma o valor da quantidade para mesma filial
			   nQtdSoma := nQtdSoma + aSolicN7S[nI][6]
			EndIf   
		Else
			aAdd(aSomaN7S,{cFilAtu, ;  //1 - filial origem
			               nQtdSoma,;  //2 - Peso acumulado por filial
			               cCodIne,;   //3 - instrução embarque (Ident Demand)
			               iif(lAlgodao,nQtdFrd,nQtdSoma)}) //4 - Qtd acumulado por filial          
			               				
			lMudouFil := .F.
			cCodIne   := ""
			cFilAtu   := aSolicN7S[nI][1]
			nQtdSoma  := 0
			nI := nI - 1
		EndIf
	Next nI
    
    //inclui último registro
    If lMudouFil
		aAdd(aSomaN7S,{cFilAtu, ;          //1 - filial origem
		               nQtdSoma,;          //2 - Peso acumulada por filial
		               cCodIne,;   		   //3 - instrução embarque (Ident Demand)
			           iif(lAlgodao,nQtdFrd,nQtdSoma)}) //4 - Qtd acumulado por filial      
	EndIf
	/*AGRUPA POR FILIAL*/
	
	
	//-- INICIO TRANSACAO --//
	BEGIN TRANSACTION

		//função que irá gravar os registros
		Processa({|| lRet := AGRA570GRV(aSolicN7S, aSomaN7S)}, STR0013, STR0014 ) //"Atualizando solicitação frete..."###"Aguarde"

	    If !(lRet)
		   DisarmTransaction()
		EndIf

	END TRANSACTION
	//-- FINAL TRANSACAO --//
	
	RestArea( aSaveArea )
	
Return lRet

/*/{Protheus.doc} AGRX570INC
//Função valida se gera ou não solicitação de frete de acordo com parametrização incoterm
@author marina.muller
@since 24/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRX570INC(cIncoN7Q)
	Local aArea     := GetArea()
    Local cIncoterm := SuperGetMV("MV_AGRO034",.F.,.F.)
	Local aIncoterm := {}
	Local nPosicao  := 0
	Local lRet    := .T.
	
	// se parâmetro e incoterm da N&Q não estiver vazio 
	IF !Empty(cIncoterm) .And. !Empty(cIncoN7Q)
		// transforma string com os dados do parâmetro em array
		aIncoterm := StrTokArr(cIncoterm, ",")
		
		//verifica se incoterm da N7Q está dentro do array
		nPosicao := Ascan(aIncoterm,{|x| ALLTRIM(x) == ALLTRIM(cIncoN7Q)})
		If nPosicao == 0
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
		
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRX570RSF
//Responsável por retornar o saldo da Requisição de frete cancelada/excluida para a Instrução de embarque correspondente
// e excluir a tabela N9R.
@author brunosilva
@since 19/02/2019
@version 1.0
@param cGXRFILIAL, characters, Filail da Requisição de Frete
@param cGXRIDREQ, characters, ID da requisição - Código da Instrução de Embarque
@param nSalNeg, numeric, Quantidade requisitada.
@type function
/*/
Function AGRX570RSF(cGXRFILIAL,cGXRIDREQ,nReqNeg)
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local aLines	:= FwSaveRows()	
	
	Default cGXRFILIAL 	:= ''
	Default cGXRIDREQ 	:= ''
	Default nReqNeg		:= 0
	
	dbSelectArea('N9R')
	N9R->(dbSetOrder(3)) 
	If N9R->(dbSeek(cGXRFILIAL+cGXRIDREQ))	
	
		N7S->(dbSelectArea('N7S'))
		N7S->(dbSetOrder(1))    	
		If N7S->(dbSeek(FwxFilial("N7S")+N9R->N9R_CODINE+N9R->N9R_CODCTR+N9R->N9R_ITEM+N9R->N9R_SEQPRI)) //item //seqpri
		   	RecLock("N7S",.F.)
		   	N7S->N7S_SALNEG += nReqNeg
		   	MsUnLock()
		else
			lRet := .F.
		endIf
		
		//Excluir o registro da N9R
		if RecLock("N9R",.F.)
			dbDelete()
			N9R->(MsUnlock())
		endIf
	else
		lRet := .F.
	endIf
	
	N7S->(dbCloseArea())
	RestArea(aArea)
	
	FwRestRows(aLines)
Return lRet
