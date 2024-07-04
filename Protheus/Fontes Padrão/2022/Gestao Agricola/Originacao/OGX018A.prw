#INCLUDE "protheus.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "OGX018A.CH"
#DEFINE _CRLF CHR(13)+CHR(10)


/*/{Protheus.doc} OGX018ATPR
	Função responsável por atualizar as previsões na SE1 em base aos dados da NN7
	@type  Function
	@author Rafael Völtz
	@since 31/05/2018
	@version version
	@param cFilial, char, Filial 	
	@param cCodCtr, char, Contrato
	@param cOrigem, char, Programa de Origem

	@return aRetorno, array, Array com os retornos da função
			[1] True/False
			[2] Mensagem erro	
	/*/
Function OGX018ATPR(cFilCtr, cCodCtr, cOrigem)
    Local cAliasQry  := GetNextAlias()
    Local aTitulos   := {}
    Local aRecnos    := {}
	Local aDados     := {}    
    Local nMoeda     := 0
    Local nVlrCrz    := 0
    Local nVlrTit    := 0
    Local nOperE1    := 0
    Local nX         := 0	
    Local aRetorno   := {}
	Local aNewRet    := {}
	Local aRetEnt    := {}
    Local cPrefixo   := "CTR"
    Local cMgs       := STR0004
	Local cOperacao  := ""
	Local cNegocio   := ""   
	Local cTipoCtr   := "" 

    Default cOrigem := "OGA290"

    BeginSQL Alias cAliasQry
        SELECT NJR_CODCTR,
               NJR_CODSAF,
               NJR_MOEDA,
               NJR_TIPMER,
			   NJR_TIPO,
               NN7_PARCEL,
               NJ0_CODCLI,
               NJ0_LOJCLI,
               NN7_DTVENC,
               NN7_FILORG,
               NN7_VLSALD,
			   NN7_NATURE,
               NN7_STSTIT,
			   NN7_TIPO,
               NN7_ITEM,
               NN7_CODBCO,
               NN7_CODAGE,
               NN7_CODCTA,
               NN7.R_E_C_N_O_ RECNO
          FROM %table:NJR% NJR
         INNER JOIN %table:NN7% NN7 ON NN7.NN7_FILIAL = NJR.NJR_FILIAL AND NN7.NN7_CODCTR = NJR.NJR_CODCTR AND NN7.%NotDel%       
		 INNER JOIN %table:NJ0% NJ0 ON NJ0.NJ0_FILIAL = %xFilial:NJ0%  AND NJ0.NJ0_CODENT = NJR.NJR_CODENT AND NJ0.NJ0_LOJENT = NJR.NJR_LOJENT AND NJ0.%NotDel%       
        WHERE NJR_FILIAL = %xFilial:NJR%          
          AND NJR_CODCTR = %Exp:cCodCtr%		  
          AND NN7_STSTIT  IN ("1","2","3") //1-Incluir, 2-Alterar, 3-Excluir
          AND NJR.%NotDel%
          ORDER BY NN7_STSTIT
    EndSQL
    
    (cAliasQry)->( dbGoTop() )
	While (cAliasQry)->(!Eof())
        
        If (cAliasQry)->NN7_STSTIT == "1"
            nOperE1 := 3 //INCLUSAO
        ElseIf (cAliasQry)->NN7_STSTIT == "2"
            nOperE1 := 4 //ALTERACAO
        ElseIf (cAliasQry)->NN7_STSTIT == "3"
            nOperE1 := 5 //EXCLUSAO          
        EndIf		

        nVlrTit := (cAliasQry)->NN7_VLSALD 
        If (cAliasQry)->NJR_TIPMER != "1"
            nVlrCrz := xMoeda( nVlrTit, (cAliasQry)->NJR_MOEDA, 1, dDataBase)
        Else	
            nVlrCrz := nVlrTit
        EndIf
        nMoeda := IIF((cAliasQry)->NJR_TIPMER == "1", 1, (cAliasQry)-> NJR_MOEDA)                

        //Ponto de entrada para retornar as informações contábeis para informarmos no título.
        If ExistBlock('OGX018ACTB')
            aDados := {}

            aAdd(aDados, { (cAliasQry)->NJR_CODCTR, (cAliasQry)->NJ0_CODCLI, (cAliasQry)->NJ0_LOJCLI } )

            aRetEnt := ExecBlock('OGX018ACTB',.F.,.F.,aDados)

            If Len(aRetEnt) == 1 .And. ValType(aRetEnt) == "A" 
                cNegocio  := aRetEnt[1][1]
                cOperacao := aRetEnt[1][2]
            EndIf
        EndIf

        aAdd(aTitulos,{ nOperE1,                     ;
                        cPrefixo,                    ; // "E1_PREFIXO"
                        (cAliasQry)->NJR_CODCTR    , ; // "E1_NUM"    
                        (cAliasQry)->NN7_PARCEL,     ; // "E1_PARCELA"
                        "PR"   ,                     ; // "E1_TIPO"   
                        (cAliasQry)->NJ0_CODCLI,     ; // "E1_CLIENTE"
                        (cAliasQry)->NJ0_LOJCLI,     ; // "E1_LOJA"   
                        dDataBase,                   ; // "E1_EMISSAO"
                        iif(stod((cAliasQry)->NN7_DTVENC) <= dDataBase, dDataBase, stod((cAliasQry)->NN7_DTVENC)),; // "E1_VENCTO" 
                        nVlrTit,                     ; // "E1_VALOR"  
                        nMoeda  ,                    ; // "E1_MOEDA"  
                        nVlrCrz ,                    ; // "E1_VLCRUZ" 
                        cMgs,                        ; // "E1_HIST"   //"Tit. Prov. Ctr. Orig."   
                        cOrigem ,                    ; // "E1_ORIGEM" 
                        (cAliasQry)->NN7_FILORG,     ; // "E1_FILORIG"
                        (cAliasQry)->NN7_NATURE,     ; // "E1_NATUREZ"
                        (cAliasQry)->NJR_CODCTR,     ; // "CONTRATO"
                        (cAliasQry)->NJR_CODSAF,     ; // "SAFRA"
                        (cAliasQry)->NN7_ITEM,       ; // "ITEM PREV"
                        (cAliasQry)->NN7_CODBCO,     ; // "E1_BCOCLI"
                        (cAliasQry)->NN7_CODAGE,     ; // "E1_AGECLI"
                        (cAliasQry)->NN7_CODCTA,     ; // "E1_CTACLI"
                        cNegocio,                    ; // "E1_EC05DB/E1_EC05CR"
                        cOperacao,                   ; // "E1_EC06DB/E1_EC06CR"
                        ;//...                        ; // <-- Adicionar outros campos aqui 
                        (cAliasQry)->RECNO           ;   // GRAVAR RECNO NA ULTIMA POSIÇÃO DO ARRAY para devolver em aRetorno
                        })  			

        

        aAdd(aRecnos, (cAliasQry)->RECNO)  
		
		cTipoCtr := (cAliasQry)->NJR_TIPO

		(cAliasQry)->(dbSkip())
    EndDo

   (cAliasQry)->( dbCloseArea() )      

	aRetorno := {}
	If Len(aTitulos) > 0
		If cTipoCtr == "1" //ctr compra
			aNewRet := OGX018ATE2(cFilial, aTitulos, cOrigem)    
		Else
			aNewRet := OGX018ATE1(cFilial, aTitulos, cOrigem)    
		EndIf
        For nX := 1 to Len(aNewRet)
			If ( aNewRet[nX][1] == .T. )
			   If aNewRet[nX][3] > 0
			       NN7->(dbGoTo( aNewRet[nX][3] ) )
				   RecLock("NN7",.F.)
				      NN7->NN7_STSTIT := "0"  //ATUALIZADO
				   NN7->(MsUnLock())
			   EndIf
			Else
			   If Len(aRetorno) == 0
			       aAdd(aRetorno, {.F., aNewRet[nX, 2] })
			    Else
                   aRetorno[1, 2] += _CRLF + "========================================" + _CRLF + aNewRet[nX, 2]
				EndIF
			EndIf
		Next nX
	EndIf

	IF Len(aRetorno) == 0
		aAdd(aRetorno, {.T.,""})
	EndIf

Return aRetorno

/*/{Protheus.doc} OGX018ATE1
	Função responsável por incluir, alterar e excluir os títulos da SE1.
	@type  Function
	@author Rafael Völtz
	@since 31/05/2018
	@version version
	@param cFilial, char, Filial 	
	@param aTitulos, array, Array com os dados dos títulos.
			[2] PREFIXO"
			[3] NUMERO    
			[4] PARCELA
			[5] TIPO   
			[6] CLIENTE
			[7] LOJA   
			[8] DATA EMISSAO
			[9] DATA VENCIMENTO
			[10] VALOR  
			[11] MODEA
			[12] VAL.CRUZ
			[13] HISTORICO   
			[14] ORIGEM 
			[15] FILIAL ORIGEM
			[16] NATUREZA 
			[17] CODIGO CONTRATO
			[18] CODIGO SAFRA
			[19] ITEM PREV
			...
			[..] RecNo do registro

	@return aRetorno, array, Array com os retornos da função
			[1] True/False
			[2] Mensagem erro	
	/*/
 Function OGX018ATE1(cFilCtr, aTitulos, cOrigem)
	Local aAreaSE1     := SE1->(GetArea())	
	Local aAreaNN7     := NN7->(GetArea())
	Local aAreaN9G     := N9G->(GetArea())
	Local lContinua    := .T.	
	Local aFina040     := {}
	Local aLinVncAux   := {}
	Local aVncCRec     := {}	
	Local aRetorno     := {}		
	Local cErros       := ""
    Local nX           := 0
	Local nY           := 0
	Local cChaveSE1    := ""	
	Local aFina040AX   := {}
	Local aVncCRecD    := {}
	Local cFilAntTmp   := cFilAnt

	Private lMsErroAuto := .F.	
	
	SE1->(DbSetOrder(1))
	N9G->(DbSetOrder(1))

	For nX := 1 to Len(aTitulos)
		//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO				
		
		cFilAnt := aTitulos[nX][15] 
					
		cChaveSE1  := xFilial("SE1") + PADR(aTitulos[nX,2],TamSX3("E1_PREFIXO" )[1]) + PADR(aTitulos[nX,3],TamSX3("E1_NUM" )[1]) + PADR(aTitulos[nX,4],TamSX3("E1_PARCELA" )[1])  + PADR(aTitulos[nX,5],TamSX3("E1_TIPO" )[1])				
		aAdd(aRetorno, {.T., "", aTitulos[nX, Len(aTitulos[Nx /*Ultima pos. array recno*/ ])] })
		If aTitulos[nX,1] == 3 //inclusão			
			If SE1->(DbSeek(cChaveSE1))
				aRetorno[nX, 2] := STR0001  //Inclusão da previsão não foi permitida. Previsão já existe no financeiro.
				aTitulos[nX,1]  := 4 //Modifica a operação para ALTERAÇÃO para garantir a atualização do valor na SE1

			ElseIf aTitulos[nX,10] > 0 
				aFina040 := {}
				aAdd( aFina040, { "E1_PREFIXO" , aTitulos[nX,2]         , Nil } )
				aAdd( aFina040, { "E1_NUM"     , aTitulos[nX,3]         , Nil } )
				aAdd( aFina040, { "E1_PARCELA" , aTitulos[nX,4]         , Nil } )
				aAdd( aFina040, { "E1_TIPO"    , aTitulos[nX,5]         , Nil } )
				aAdd( aFina040, { "E1_CLIENTE" , aTitulos[nX,6] 		, Nil } )
				aAdd( aFina040, { "E1_LOJA"    , aTitulos[nX,7]		 	, Nil } )
				aAdd( aFina040, { "E1_EMISSAO" , aTitulos[nX,8]  		, Nil } )
				aAdd( aFina040, { "E1_VENCTO"  , aTitulos[nX,9]   		, Nil } )
				aAdd( aFina040, { "E1_VALOR"   , aTitulos[nX,10]        , Nil } )
				aAdd( aFina040, { "E1_MOEDA"   , aTitulos[nX,11]     	,Nil } )
				aAdd( aFina040, { "E1_VLCRUZ"  , aTitulos[nX,12]        , Nil } )
				aAdd( aFina040, { "E1_HIST"    , aTitulos[nX,13]        , Nil } ) //"Tit. Prov. Ctr. Orig."
				aAdd( aFina040, { "E1_ORIGEM"  , aTitulos[nX,14]        , Nil } )
				aAdd( aFina040, { "E1_FILORIG" , aTitulos[nX,15]    	, Nil } ) //filial de origem da N9A	
				aAdd( aFina040, { "E1_BCOCLI"  , aTitulos[nX,20]        , Nil } )
				aAdd( aFina040, { "E1_AGECLI"  , aTitulos[nX,21]        , Nil } )
				aAdd( aFina040, { "E1_CTACLI"  , aTitulos[nX,22]        , Nil } )

				If .Not. Empty(aTitulos[nX,16]) //verifica se possui natureza
					aAdd( aFina040, { "E1_NATUREZ" , aTitulos[nX,16]    , Nil } )
				EndIf
				
				//Se houver banco vinculado ao contrato, irá gerar o titulo CTR com portador.
				If NJR->(FieldPos('NJR_BCOPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_AGGPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_CTAPRV')) > 0
					
					If !Empty(NJR->NJR_BCOPRV) .AND. !Empty(NJR->NJR_AGGPRV) .AND. !Empty(NJR->NJR_CTAPRV)
					
						cBanco  :=  PADR( NJR->NJR_BCOPRV, TamSX3('E1_PORTADO')[1] )
						cAgenc  :=  PADR( NJR->NJR_AGGPRV, TamSX3('E1_AGEDEP')[1] )
						cConta  :=  PADR( NJR->NJR_CTAPRV, TamSX3('E1_CONTA')[1] )
					
						aAdd( aFina040, { "E1_PORTADO" ,  cBanco , Nil } ) 
						aAdd( aFina040, { "E1_AGEDEP"  ,  cAgenc , Nil } ) 
						aAdd( aFina040, { "E1_CONTA"   ,  cConta , Nil } )

					EndIf
				EndIf
				cClVl   :=  PADR( NJR->NJR_CLVL,   TamSX3('E1_CLVL')[1] )
				aAdd( aFina040, { "E1_CLVL"    ,  cClVl  , Nil } )
				aAdd( aFina040, { "E1_CLVLCR"    ,  cClVl  , Nil } )
				aAdd( aFina040, { "E1_CLVLDB"    ,  cClVl  , Nil } )

				//5° e 6° Entidade
				If !Empty(Alltrim(aTitulos[nX,23]))
					aAdd( aFina040, { "E1_EC05DB"  , aTitulos[nX,23]        , Nil } )
					aAdd( aFina040, { "E1_EC05CR"  , aTitulos[nX,23]        , Nil } )
				EndIf
				
				If !Empty(Alltrim(aTitulos[nX,24]))
					aAdd( aFina040, { "E1_EC06DB"  , aTitulos[nX,24]        , Nil } )
					aAdd( aFina040, { "E1_EC06CR"  , aTitulos[nX,24]        , Nil } )
				Endif

				aAdd( aFina040AX, {3, cChaveSE1, aFina040, aTitulos[nX,19]})

				//Criando Vinculo com SE1
				aLinVncAux := {}					
				
				aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 							} )
				aadd( aLinVncAux, { "N8L_FILORI"    	, aTitulos[nX,15]						    } )
				aadd( aLinVncAux, { "N8L_PREFIX"    	, aTitulos[nX,2]							} )
				aadd( aLinVncAux, { "N8L_NUM"    		, aTitulos[nX,3]							} )
				aadd( aLinVncAux, { "N8L_PARCEL"    	, aTitulos[nX,4]		 					} )
				aadd( aLinVncAux, { "N8L_TIPO"    		, aTitulos[nX,5]							} )
				aadd( aLinVncAux, { "N8L_CODCTR"    	, aTitulos[nX,17] 							} )
				aadd( aLinVncAux, { "N8L_SAFRA"	    	, aTitulos[nX,18] 							} )
				aadd( aLinVncAux, { "N8L_CODROM"    	, ''										} )
				aadd( aLinVncAux, { "N8L_ITEROM"   		, ''										} )
				aadd( aLinVncAux, { "N8L_CODFIX"   		, ''										} )
				aadd( aLinVncAux, { "N8L_CODOTR"    	, ''										} )
				aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''										} )	
				aadd( aLinVncAux, { "N8L_ORIGEM"    	, aTitulos[nX,14] 							} )
				aAdd( aLinVncAux, { "N8L_HISTOR"    	, FWI18NLang("OGA290","STR0175",175)		} )  //Previsão financeira, Contrato de vendas
				
				aAdd(aVncCRec,aLinVncAux)
			EndIf
		EndIf			

		If aTitulos[nX,1] == 4 //Alteração
			If SE1->(!DbSeek(cChaveSE1)) .and. aTitulos[nX,10] > 0
                //se nao encontrar a SE1 com status de alteração, quer dizer que o saldo dela havia zerado e precisa incluir novamente.    
                aFina040 := {}				
				aAdd( aFina040, { "E1_PREFIXO" , aTitulos[nX,2]         , Nil } )
				aAdd( aFina040, { "E1_NUM"     , aTitulos[nX,3]         , Nil } )
				aAdd( aFina040, { "E1_PARCELA" , aTitulos[nX,4]         , Nil } )
				aAdd( aFina040, { "E1_TIPO"    , aTitulos[nX,5]         , Nil } )
				aAdd( aFina040, { "E1_CLIENTE" , aTitulos[nX,6] 		, Nil } )
				aAdd( aFina040, { "E1_LOJA"    , aTitulos[nX,7]		 	, Nil } )
				aAdd( aFina040, { "E1_EMISSAO" , aTitulos[nX,8]  		, Nil } )
				aAdd( aFina040, { "E1_VENCTO"  , aTitulos[nX,9]   		, Nil } )
				aAdd( aFina040, { "E1_VALOR"   , aTitulos[nX,10]        , Nil } )
				aAdd( aFina040, { "E1_MOEDA"   , aTitulos[nX,11]     	,Nil } )
				aAdd( aFina040, { "E1_VLCRUZ"  , aTitulos[nX,12]        , Nil } )
				aAdd( aFina040, { "E1_HIST"    , aTitulos[nX,13]        , Nil } ) //"Tit. Prov. Ctr. Orig."
				aAdd( aFina040, { "E1_ORIGEM"  , aTitulos[nX,14]        , Nil } )
				aAdd( aFina040, { "E1_FILORIG" , aTitulos[nX,15]    	, Nil } ) //filial de origem da N9A
				aAdd( aFina040, { "E1_BCOCLI"  , aTitulos[nX,20]        , Nil } )
				aAdd( aFina040, { "E1_AGECLI"  , aTitulos[nX,21]        , Nil } )
				aAdd( aFina040, { "E1_CTACLI"  , aTitulos[nX,22]        , Nil } )

				If .Not. Empty(aTitulos[nX,16]) //verifica se possui natureza
					aAdd( aFina040, { "E1_NATUREZ" , aTitulos[nX,16]    , Nil } )
				EndIf	

				//Se houver banco vinculado ao contrato, irá gerar o titulo CTR com portador.
				If NJR->(FieldPos('NJR_BCOPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_AGGPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_CTAPRV')) > 0
					
					If !Empty(NJR->NJR_BCOPRV) .AND. !Empty(NJR->NJR_AGGPRV) .AND. !Empty(NJR->NJR_CTAPRV)
					
					cBanco  :=  PADR( NJR->NJR_BCOPRV, TamSX3('E1_PORTADO')[1] )
					cAgenc  :=  PADR( NJR->NJR_AGGPRV, TamSX3('E1_AGEDEP')[1] )
					cConta  :=  PADR( NJR->NJR_CTAPRV, TamSX3('E1_CONTA')[1] )
				
					aAdd( aFina040, { "E1_PORTADO" ,  cBanco , Nil } ) 
					aAdd( aFina040, { "E1_AGEDEP"  ,  cAgenc , Nil } ) 
					aAdd( aFina040, { "E1_CONTA"   ,  cConta , Nil } )

					EndIf
				EndIf
				cClVl   :=  PADR( NJR->NJR_CLVL,   TamSX3('E1_CLVL')[1] )
				aAdd( aFina040, { "E1_CLVL"    ,  cClVl  , Nil } )
				aAdd( aFina040, { "E1_CLVLCR"    ,  cClVl  , Nil } )
				aAdd( aFina040, { "E1_CLVLDB"    ,  cClVl  , Nil } )

				//5° e 6° Entidade
				If !Empty(Alltrim(aTitulos[nX,23]))
					aAdd( aFina040, { "E1_EC05DB"  , aTitulos[nX,23]        , Nil } )
					aAdd( aFina040, { "E1_EC05CR"  , aTitulos[nX,23]        , Nil } )
				EndIf
				
				If !Empty(Alltrim(aTitulos[nX,24]))
					aAdd( aFina040, { "E1_EC06DB"  , aTitulos[nX,24]        , Nil } )
					aAdd( aFina040, { "E1_EC06CR"  , aTitulos[nX,24]        , Nil } )
				Endif

				aAdd( aFina040AX, {3, cChaveSE1, aFina040, aTitulos[nX,19]})

				//Criando Vinculo com SE1
				aLinVncAux := {}					
				
				aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 							} )
				aadd( aLinVncAux, { "N8L_FILORI"    	, aTitulos[nX,15]						    } )
				aadd( aLinVncAux, { "N8L_PREFIX"    	, aTitulos[nX,2]							} )
				aadd( aLinVncAux, { "N8L_NUM"    		, aTitulos[nX,3]							} )
				aadd( aLinVncAux, { "N8L_PARCEL"    	, aTitulos[nX,4]		 					} )
				aadd( aLinVncAux, { "N8L_TIPO"    		, aTitulos[nX,5]							} )
				aadd( aLinVncAux, { "N8L_CODCTR"    	, aTitulos[nX,17] 							} )
				aadd( aLinVncAux, { "N8L_SAFRA"	    	, aTitulos[nX,18] 							} )
				aadd( aLinVncAux, { "N8L_CODROM"    	, ''										} )
				aadd( aLinVncAux, { "N8L_ITEROM"   		, ''										} )
				aadd( aLinVncAux, { "N8L_CODFIX"   		, ''										} )
				aadd( aLinVncAux, { "N8L_CODOTR"    	, ''										} )
				aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''										} )	
				aadd( aLinVncAux, { "N8L_ORIGEM"    	, aTitulos[nX,14] 							} )
				aAdd( aLinVncAux, { "N8L_HISTOR"    	, FWI18NLang("OGA290","STR0175",175)		} )  //Previsão financeira, Contrato de vendas
				
				aAdd(aVncCRec,aLinVncAux)

			Else				
				aFina040 := {}
				aAdd( aFina040, { "E1_PREFIXO" , aTitulos[nX,2]                     , Nil } )
				aAdd( aFina040, { "E1_NUM"     , aTitulos[nX,3]                     , Nil } )				
				aAdd( aFina040, { "E1_PARCELA" , aTitulos[nX,4]                     , Nil } )
                aAdd( aFina040, { "E1_VALOR"   , aTitulos[nX,10]                    , Nil } )	
                aAdd( aFina040, { "E1_VLCRUZ"  , aTitulos[nX,12]        			, Nil } )
				aAdd( aFina040, { "E1_VENCTO"  , aTitulos[nX,9]              		, Nil } )											
				
				aAdd( aFina040AX, {4, cChaveSE1, aFina040, aTitulos[nX,19]})

				If aTitulos[nX,10]  == 0 //irá excluir a SE1 e N8L
					aLinVncAux := {}					
						
					aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 							        } )					
					aadd( aLinVncAux, { "N8L_PREFIX"    	, PadR( aTitulos[nX,2] , TamSX3( "E1_PREFIXO" )[1] )} )
					aadd( aLinVncAux, { "N8L_NUM"    		, PadR( aTitulos[nX,3] , TamSX3( "E1_NUM" )[1] )    } )
					aadd( aLinVncAux, { "N8L_PARCEL"    	, PadR( aTitulos[nX,4] , TamSX3( "E1_PARCELA" )[1] )} )
					aadd( aLinVncAux, { "N8L_TIPO"    		, PadR( aTitulos[nX,5] , TamSX3( "N8L_TIPO" )[1] )  } )

					aAdd(aVncCRecD,aLinVncAux)
				EndIf
			EndIf

		ElseIf aTitulos[nX,1] == 5 //exclusão
			If SE1->(DbSeek(cChaveSE1))
				aFina040 := {}
				aAdd( aFina040, { "E1_PREFIXO" , aTitulos[nX,2], Nil } )
				aAdd( aFina040, { "E1_NUM"     , aTitulos[nX,3], Nil } )				
				aAdd( aFina040, { "E1_PARCELA" , aTitulos[nX,4], Nil } )
				aAdd( aFina040AX, {5, cChaveSE1, aFina040, aTitulos[nX,19]})

				//Exclui Vinculo com SE1
				aLinVncAux := {}					
				
				aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 							        } )					
				aadd( aLinVncAux, { "N8L_PREFIX"    	, PadR( aTitulos[nX,2] , TamSX3( "E1_PREFIXO" )[1] )} )
				aadd( aLinVncAux, { "N8L_NUM"    		, PadR( aTitulos[nX,3] , TamSX3( "E1_NUM" )[1] )    } )
				aadd( aLinVncAux, { "N8L_PARCEL"    	, PadR( aTitulos[nX,4] , TamSX3( "E1_PARCELA" )[1] )} )
				aadd( aLinVncAux, { "N8L_TIPO"    		, PadR( aTitulos[nX,5] , TamSX3( "N8L_TIPO" )[1] )  } )

				aAdd(aVncCRecD,aLinVncAux)
			Else
				/* CASO NÃO ENCONTRE NA SE1, MESMO ASSIM DEVE APAGAR NA NN7*/
				If NN7->(DbSeek(xFilial("NN7") + aTitulos[nX,3] + aTitulos[nX,19])) 						
					If NN7->NN7_TIPEVE == "1" //por evento						
						If N9G->(DbSeek(NN7->NN7_FILIAL + NN7->NN7_CODCTR + NN7->NN7_ITEM))
							If RecLock('N9G', .F.)
								N9G->(dbDelete())
								N9G->(MsUnlock()) 
							EndIf	
						EndIf

						If RecLock('NN7', .F.)
							NN7->(dbDelete())
							NN7->(MsUnlock()) 
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If len(aFina040AX) > nY
           aAdd(aFina040AX[len(aFina040AX)], aRetorno[nX])  //Adiciona o Status de retorno e aFina040ax para linkar com aTitulos (Recno)
		   nY := nY + 1
		EndIf	
		
		cFilAnt := cFilAntTmp  
		
	Next nX		
	
	If lContinua .OR. len(aFina040AX) > 0
		aRetorno := {}
		If len(aFina040AX) > 0
			For nX := 1 To Len(aFina040AX)															
				aFina040 := {}
				aFina040 := aClone(aFina040AX[nX,3])
				If aFina040AX[nX,1] == 4 //Alteracao
                    //alterado para reclock devido o fina040 nao atualizar previsao com parcelas
                    SE1->(dbGoTop())
					if SE1->(DbSeek(aFina040AX[nX,2]))
	                    If RecLock("SE1",.F.)
	                        If aFina040[4][2] == 0 //se a SE1 vai ficar com valor Zero, então deleta ela.
		                        SE1->(dbDelete())
							Else
								SE1->E1_VALOR  := aFina040[4][2]
	                        	SE1->E1_VLCRUZ := aFina040[5][2]
	                        	SE1->E1_SALDO  := aFina040[4][2]
							EndIf
	                        SE1->(MsUnLock())
	                    EndIf
                    endif	
				ElseIf aFina040AX[nX,1] == 5 //Exclusao				
				    SE1->(dbGoTop())
					if SE1->(DbSeek(aFina040AX[nX,2]))
	                    If RecLock("SE1",.F.)
	                        SE1->(dbDelete())
	                        SE1->(MsUnLock())
	                    EndIf					
					EndIf   					
					
					If NN7->(DbSeek(xFilial("NN7") + aFina040[2,2] + aFina040AX[nX,4])) 												
                        If NN7->NN7_TIPEVE == "1" //por evento							
                            If N9G->(DbSeek(NN7->NN7_FILIAL + NN7->NN7_CODCTR + NN7->NN7_ITEM))
                                If RecLock('N9G', .F.)
                                    N9G->(dbDelete())
                                    N9G->(MsUnlock()) 
                                EndIf	
                            EndIf
                        EndIf

                        If RecLock('NN7', .F.)
                            NN7->(dbDelete())
                            NN7->(MsUnlock()) 
                        EndIf						
					EndIf
				Else
				
					cFilAnt := aFina040[14][2]
				
					MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, aFina040AX[nX,1] )
					
					cFilAnt := cFilAntTmp 
					
					
				    If lMsErroAuto
				    	If isBlind()
				    		cErros := STR0003 + cValToChar(aTitulos[nX,3]) //Ocorreram erros na geração da previsão financeira. Número: 
				    	Else
				    		MostraErro()
				    	EndIf
						//aAdd(aRetorno, {.F.,cErros, aTitulos[nX, Len(aTitulos) /*Ultima pos. array recno*/  ]})										    	
						aFina040AX[nX, Len(aFina040AX[nX] ), 1] := .F.
						aFina040AX[nX, Len(aFina040AX[nX] ), 2] := cErros				    	
					Else
						aFina040AX[nX, Len(aFina040AX[nX] ), 1] := .T.
						aFina040AX[nX, Len(aFina040AX[nX] ), 2] := ""				    	
					EndIf
                EndIf				

				aAdd(aRetorno, aFina040AX[nX, Len(aFina040AX[nX] )] )
			Next nX

			IF lContinua 
				If Len( aVncCRec ) > 0
					If !( fAgrVncRec (aVncCRec, 3, .T. ) ) //Incluir
						aFina040AX[1, Len(aFina040AX[1] ), 1] := .F.
						aFina040AX[1, Len(aFina040AX[1] ), 2] := STR0006
					EndIf
				EndIf

				IF Len( aVncCRecD ) > 0
					If !( fAgrVncRec (aVncCRecD, 5 )  )
					    aFina040AX[1, Len(aFina040AX[1] ), 1] := .F.
						aFina040AX[1, Len(aFina040AX[1] ), 2] := STR0007
					EndIf
				EndIf

			EndIf

		EndIf       
	EndIf
	
	FwFreeObj(aLinVncAux)	
	FwFreeObj(aFina040)		
	FwFreeObj(aVncCRec)
	RestArea(aAreaSE1)
	RestArea(aAreaNN7)
	RestArea(aAreaN9G)

Return aRetorno

/*/{Protheus.doc} OGX018ATE2
	Função responsável por incluir, alterar e excluir os títulos da SE2.
	@type  Function
	@author Rafael Völtz
	@since 31/05/2018
	@version version
	@param cFilial, char, Filial 	
	@param aTitulos, array, Array com os dados dos títulos.
			[2] PREFIXO"
			[3] NUMERO    
			[4] PARCELA
			[5] TIPO   
			[6] CLIENTE
			[7] LOJA   
			[8] DATA EMISSAO
			[9] DATA VENCIMENTO
			[10] VALOR  
			[11] MODEA
			[12] VAL.CRUZ
			[13] HISTORICO   
			[14] ORIGEM 
			[15] FILIAL ORIGEM
			[16] NATUREZA 
			[17] CODIGO CONTRATO
			[18] CODIGO SAFRA
			[19] ITEM PREV
			...
			[..] RecNo do registro

	@return aRetorno, array, Array com os retornos da função
			[1] True/False
			[2] Mensagem erro	
	/*/
 Function OGX018ATE2(cFilCtr, aTitulos, cOrigem)
	Local aAreaSE2     := SE2->(GetArea())	
	Local aAreaNN7     := NN7->(GetArea())
	Local aAreaN9G     := N9G->(GetArea())
	Local lContinua    := .T.	
	Local aFina050     := {}
	Local aLinVncAux   := {}
	Local aVncCPag     := {}	
	Local aRetorno     := {}		
	Local cErros       := ""
    Local nX           := 0
	Local nY           := 0
	Local cChaveSE2    := ""	
	Local aFina050AX   := {}
	Local aVncCPagD    := {}
	Local cFilAntTmp   := cFilAnt

	Private lMsErroAuto := .F.	
	
	SE2->(DbSetOrder(1))
	N9G->(DbSetOrder(1))

	For nX := 1 to Len(aTitulos)
		//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO				
		
		cFilAnt := aTitulos[nX][15] 
					
		cChaveSE2  := xFilial("SE2") + PADR(aTitulos[nX,2],TamSX3("E2_PREFIXO" )[1]) + PADR(aTitulos[nX,3],TamSX3("E2_NUM" )[1]) + PADR(aTitulos[nX,4],TamSX3("E2_PARCELA" )[1])  + PADR(aTitulos[nX,5],TamSX3("E2_TIPO" )[1])				
		aAdd(aRetorno, {.T., "", aTitulos[nX, Len(aTitulos[Nx /*Ultima pos. array recno*/ ])] })
		If aTitulos[nX,1] == 3 //inclusão			
			If SE2->(DbSeek(cChaveSE2))
				aRetorno[nX, 2] := STR0001  //Inclusão da previsão não foi permitida. Previsão já existe no financeiro.
				aTitulos[nX,1]  := 4 		//Modifica a operação para ALTERAÇÃO para garantir a atualização do valor na SE2

			ElseIf aTitulos[nX,10] > 0 
				aFina050 := {}
				aAdd( aFina050, { "E2_PREFIXO" , aTitulos[nX,2]         , Nil } )
				aAdd( aFina050, { "E2_NUM"     , aTitulos[nX,3]         , Nil } )
				aAdd( aFina050, { "E2_PARCELA" , aTitulos[nX,4]         , Nil } )
				aAdd( aFina050, { "E2_TIPO"    , aTitulos[nX,5]         , Nil } )
				aAdd( aFina050, { "E2_FORNECE" , aTitulos[nX,6] 		, Nil } )
				aAdd( aFina050, { "E2_LOJA"    , aTitulos[nX,7]		 	, Nil } )
				aAdd( aFina050, { "E2_EMISSAO" , aTitulos[nX,8]  		, Nil } )
				aAdd( aFina050, { "E2_VENCTO"  , aTitulos[nX,9]   		, Nil } )
				aAdd( aFina050, { "E2_VALOR"   , aTitulos[nX,10]        , Nil } )
				aAdd( aFina050, { "E2_MOEDA"   , aTitulos[nX,11]     	,Nil } )
				aAdd( aFina050, { "E2_VLCRUZ"  , aTitulos[nX,12]        , Nil } )
				aAdd( aFina050, { "E2_HIST"    , aTitulos[nX,13]        , Nil } ) //"Tit. Prov. Ctr. Orig."
				aAdd( aFina050, { "E2_ORIGEM"  , aTitulos[nX,14]        , Nil } )
				aAdd( aFina050, { "E2_FILORIG" , aTitulos[nX,15]    	, Nil } ) //filial de origem da N9A	
				aAdd( aFina050, { "E2_FORBCO"  , aTitulos[nX,20]        , Nil } )
				aAdd( aFina050, { "E2_FORAGE"  , aTitulos[nX,21]        , Nil } )
				aAdd( aFina050, { "E2_FORCTA"  , aTitulos[nX,22]        , Nil } )

				If .Not. Empty(aTitulos[nX,16]) //verifica se possui natureza
					aAdd( aFina050, { "E2_NATUREZ" , aTitulos[nX,16]    , Nil } )
				EndIf
				
				//Se houver banco vinculado ao contrato, irá gerar o titulo CTR com portador.
				If NJR->(FieldPos('NJR_BCOPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_AGGPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_CTAPRV')) > 0
					
					If !Empty(NJR->NJR_BCOPRV) .AND. !Empty(NJR->NJR_AGGPRV) .AND. !Empty(NJR->NJR_CTAPRV)
					
					cBanco  :=  PADR( NJR->NJR_BCOPRV, TamSX3('E2_PORTADO')[1] )
					cAgenc  :=  PADR( NJR->NJR_AGGPRV, TamSX3('E2_AGECHQ')[1] )
					cConta  :=  PADR( NJR->NJR_CTAPRV, TamSX3('E2_CTACHQ')[1] )
				
					aAdd( aFina050, { "E2_PORTADO" ,  cBanco , Nil } ) 
					aAdd( aFina050, { "E2_BCOCHQ"  ,  cBanco , Nil } )
					aAdd( aFina050, { "E2_AGECHQ"  ,  cAgenc , Nil } ) 
					aAdd( aFina050, { "E2_CTACHQ"  ,  cConta , Nil } )

					EndIf
				EndIf
				cClVl   :=  PADR( NJR->NJR_CLVL,   TamSX3('E2_CLVL')[1] )
				aAdd( aFina050, { "E2_CLVL"    ,  cClVl  , Nil } )
				aAdd( aFina050, { "E2_CLVLCR"    ,  cClVl  , Nil } )
				aAdd( aFina050, { "E2_CLVLDB"    ,  cClVl  , Nil } )

				//5° e 6° Entidade
				If !Empty(Alltrim(aTitulos[nX,23]))
					aAdd( aFina050, { "E2_EC05DB"  , aTitulos[nX,23]        , Nil } )
					aAdd( aFina050, { "E2_EC05CR"  , aTitulos[nX,23]        , Nil } )
				EndIf
				
				If !Empty(Alltrim(aTitulos[nX,24]))
					aAdd( aFina050, { "E2_EC06DB"  , aTitulos[nX,24]        , Nil } )
					aAdd( aFina050, { "E2_EC06CR"  , aTitulos[nX,24]        , Nil } )
				Endif

				aAdd( aFina050AX, {3, cChaveSE2, aFina050, aTitulos[nX,19]})

				//Criando Vinculo com SE2
				aLinVncAux := {}					
				
				aadd( aLinVncAux, { "N8M_FILIAL"    	, FwXfilial('SE2') 							} )
				aadd( aLinVncAux, { "N8M_FILORI"    	, aTitulos[nX,15]						    } )
				aadd( aLinVncAux, { "N8M_PREFIX"    	, aTitulos[nX,2]							} )
				aadd( aLinVncAux, { "N8M_NUM"    		, aTitulos[nX,3]							} )
				aadd( aLinVncAux, { "N8M_PARCEL"    	, aTitulos[nX,4]		 					} )
				aadd( aLinVncAux, { "N8M_TIPO"    		, aTitulos[nX,5]							} )
				aadd( aLinvncAux, { "N8M_FORNEC"    	, aTitulos[nX,6]							} )
                aadd( aLinvncAux, { "N8M_LOJA"    		, aTitulos[nX,7]			    			} )
				aadd( aLinVncAux, { "N8M_CODCTR"    	, aTitulos[nX,17] 							} )
				aadd( aLinVncAux, { "N8M_CODSAF"	   	, aTitulos[nX,18] 							} )
				aadd( aLinVncAux, { "N8M_CODROM"    	, ''										} )
				aadd( aLinVncAux, { "N8M_ITEROM"   		, ''										} )
				aadd( aLinVncAux, { "N8M_ITEMFX"   		, ''										} )
				aadd( aLinVncAux, { "N8M_ORDTRA"    	, ''										} )
				aadd( aLinVncAux, { "N8M_ORPGRC"   		, ''										} )	
				aadd( aLinVncAux, { "N8M_ORIGEM"    	, aTitulos[nX,14] 							} )
				aAdd( aLinVncAux, { "N8M_HISTOR"    	, FWI18NLang("OGA280","STR0132",132)		} )  //Previsão financeira, Contrato de compras
				
				aAdd(aVncCPag,aLinVncAux)
			EndIf
		EndIf			

		If aTitulos[nX,1] == 4 //Alteração
			If SE2->(!DbSeek(cChaveSE2)) .and. aTitulos[nX,10] > 0
                //se nao encontrar a SE2 com status de alteração, quer dizer que o saldo dela havia zerado e precisa incluir novamente.    
                aFina050 := {}				
				aAdd( aFina050, { "E2_PREFIXO" , aTitulos[nX,2]         , Nil } )
				aAdd( aFina050, { "E2_NUM"     , aTitulos[nX,3]         , Nil } )
				aAdd( aFina050, { "E2_PARCELA" , aTitulos[nX,4]         , Nil } )
				aAdd( aFina050, { "E2_TIPO"    , aTitulos[nX,5]         , Nil } )
				aAdd( aFina050, { "E2_FORNECE" , aTitulos[nX,6] 		, Nil } )
				aAdd( aFina050, { "E2_LOJA"    , aTitulos[nX,7]		 	, Nil } )
				aAdd( aFina050, { "E2_EMISSAO" , aTitulos[nX,8]  		, Nil } )
				aAdd( aFina050, { "E2_VENCTO"  , aTitulos[nX,9]   		, Nil } )
				aAdd( aFina050, { "E2_VALOR"   , aTitulos[nX,10]        , Nil } )
				aAdd( aFina050, { "E2_MOEDA"   , aTitulos[nX,11]     	,Nil } )
				aAdd( aFina050, { "E2_VLCRUZ"  , aTitulos[nX,12]        , Nil } )
				aAdd( aFina050, { "E2_HIST"    , aTitulos[nX,13]        , Nil } ) //"Tit. Prov. Ctr. Orig."
				aAdd( aFina050, { "E2_ORIGEM"  , aTitulos[nX,14]        , Nil } )
				aAdd( aFina050, { "E2_FILORIG" , aTitulos[nX,15]    	, Nil } ) //filial de origem da N9A
				aAdd( aFina050, { "E2_FORBCO"  , aTitulos[nX,20]        , Nil } )
				aAdd( aFina050, { "E2_FORAGE"  , aTitulos[nX,21]        , Nil } )
				aAdd( aFina050, { "E2_FORCTA"  , aTitulos[nX,22]        , Nil } )

				If .Not. Empty(aTitulos[nX,16]) //verifica se possui natureza
					aAdd( aFina050, { "E2_NATUREZ" , aTitulos[nX,16]    , Nil } )
				EndIf	

				//Se houver banco vinculado ao contrato, irá gerar o titulo CTR com portador.
				If NJR->(FieldPos('NJR_BCOPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_AGGPRV')) > 0 .AND. ;
					NJR->(FieldPos('NJR_CTAPRV')) > 0
					
					If !Empty(NJR->NJR_BCOPRV) .AND. !Empty(NJR->NJR_AGGPRV) .AND. !Empty(NJR->NJR_CTAPRV)
					
					cBanco  :=  PADR( NJR->NJR_BCOPRV, TamSX3('E2_PORTADO')[1] )
					cAgenc  :=  PADR( NJR->NJR_AGGPRV, TamSX3('E2_AGECHQ')[1] )
					cConta  :=  PADR( NJR->NJR_CTAPRV, TamSX3('E2_CTACHQ')[1] )
				
					aAdd( aFina050, { "E2_PORTADO" ,  cBanco , Nil } ) 
					aAdd( aFina050, { "E2_BCOCHQ"  ,  cBanco , Nil } )
					aAdd( aFina050, { "E2_AGECHQ"  ,  cAgenc , Nil } ) 
					aAdd( aFina050, { "E2_CTACHQ"   , cConta , Nil } )

					EndIf
				EndIf
				cClVl   :=  PADR( NJR->NJR_CLVL,   TamSX3('E2_CLVL')[1] )
				aAdd( aFina050, { "E2_CLVL"    ,  cClVl  , Nil } )
				aAdd( aFina050, { "E2_CLVLCR"    ,  cClVl  , Nil } )
				aAdd( aFina050, { "E2_CLVLDB"    ,  cClVl  , Nil } )

				//5° e 6° Entidade
				If !Empty(Alltrim(aTitulos[nX,23]))
					aAdd( aFina050, { "E2_EC05DB"  , aTitulos[nX,23]        , Nil } )
					aAdd( aFina050, { "E2_EC05CR"  , aTitulos[nX,23]        , Nil } )
				EndIf
				
				If !Empty(Alltrim(aTitulos[nX,24]))
					aAdd( aFina050, { "E2_EC06DB"  , aTitulos[nX,24]        , Nil } )
					aAdd( aFina050, { "E2_EC06CR"  , aTitulos[nX,24]        , Nil } )
				Endif

				aAdd( aFina050AX, {3, cChaveSE2, aFina050, aTitulos[nX,19]})

				//Criando Vinculo com SE2
				aLinVncAux := {}					
				
				aadd( aLinVncAux, { "N8M_FILIAL"    	, FwXfilial('SE2') 							} )
				aadd( aLinVncAux, { "N8M_FILORI"    	, aTitulos[nX,15]						    } )
				aadd( aLinVncAux, { "N8M_PREFIX"    	, aTitulos[nX,2]							} )
				aadd( aLinVncAux, { "N8M_NUM"    		, aTitulos[nX,3]							} )
				aadd( aLinVncAux, { "N8M_PARCEL"    	, aTitulos[nX,4]		 					} )
				aadd( aLinVncAux, { "N8M_TIPO"    		, aTitulos[nX,5]							} )
				aadd( aLinvncAux, { "N8M_FORNEC"    	, aTitulos[nX,6]							} )
                aadd( aLinvncAux, { "N8M_LOJA"    		, aTitulos[nX,7]			    			} )
				aadd( aLinVncAux, { "N8M_CODCTR"    	, aTitulos[nX,17] 							} )
				aadd( aLinVncAux, { "N8M_CODSAF"	    , aTitulos[nX,18] 							} )
				aadd( aLinVncAux, { "N8M_CODROM"    	, ''										} )
				aadd( aLinVncAux, { "N8M_ITEROM"   		, ''										} )
				aadd( aLinVncAux, { "N8M_ITEMFX"   		, ''										} )
				aadd( aLinVncAux, { "N8M_ORDTRA"    	, ''										} )
				aadd( aLinVncAux, { "N8M_ORPGRC"   		, ''										} )	
				aadd( aLinVncAux, { "N8M_ORIGEM"    	, aTitulos[nX,14] 							} )
				aAdd( aLinVncAux, { "N8M_HISTOR"    	, FWI18NLang("OGA280","STR0132",132)		} )  //Previsão financeira, Contrato de compras
				
				aAdd(aVncCPag,aLinVncAux)

			Else				
				aFina050 := {}
				aAdd( aFina050, { "E2_PREFIXO" , aTitulos[nX,2]                     , Nil } )
				aAdd( aFina050, { "E2_NUM"     , aTitulos[nX,3]                     , Nil } )				
				aAdd( aFina050, { "E2_PARCELA" , aTitulos[nX,4]                     , Nil } )
                aAdd( aFina050, { "E2_VALOR"   , aTitulos[nX,10]                    , Nil } )	
                aAdd( aFina050, { "E2_VLCRUZ"  , aTitulos[nX,12]        			, Nil } )
				aAdd( aFina050, { "E2_VENCTO"  , aTitulos[nX,9]              		, Nil } )											
				
				aAdd( aFina050AX, {4, cChaveSE2, aFina050, aTitulos[nX,19]})

				If aTitulos[nX,10]  == 0 //irá excluir a SE2 e N8M
					aLinVncAux := {}					
						
					aadd( aLinVncAux, { "N8M_FILIAL"    	, FwXfilial('SE2') 							        } )					
					aadd( aLinVncAux, { "N8M_PREFIX"    	, PadR( aTitulos[nX,2] , TamSX3( "E2_PREFIXO" )[1] )} )
					aadd( aLinVncAux, { "N8M_NUM"    		, PadR( aTitulos[nX,3] , TamSX3( "E2_NUM" )[1] )    } )
					aadd( aLinVncAux, { "N8M_PARCEL"    	, PadR( aTitulos[nX,4] , TamSX3( "E2_PARCELA" )[1] )} )
					aadd( aLinVncAux, { "N8M_TIPO"    		, PadR( aTitulos[nX,5] , TamSX3( "N8M_TIPO" )[1] )  } )

					aAdd(aVncCPagD,aLinVncAux)
				EndIf
			EndIf

		ElseIf aTitulos[nX,1] == 5 //exclusão
			If SE2->(DbSeek(cChaveSE2))
				aFina050 := {}
				aAdd( aFina050, { "E2_PREFIXO" , aTitulos[nX,2], Nil } )
				aAdd( aFina050, { "E2_NUM"     , aTitulos[nX,3], Nil } )				
				aAdd( aFina050, { "E2_PARCELA" , aTitulos[nX,4], Nil } )
				aAdd( aFina050AX, {5, cChaveSE2, aFina050, aTitulos[nX,19]})

				//Exclui Vinculo com SE2
				aLinVncAux := {}					
				
				aadd( aLinVncAux, { "N8M_FILIAL"    	, FwXfilial('SE2') 							        } )					
				aadd( aLinVncAux, { "N8M_PREFIX"    	, PadR( aTitulos[nX,2] , TamSX3( "E2_PREFIXO" )[1] )} )
				aadd( aLinVncAux, { "N8M_NUM"    		, PadR( aTitulos[nX,3] , TamSX3( "E2_NUM" )[1] )    } )
				aadd( aLinVncAux, { "N8M_PARCEL"    	, PadR( aTitulos[nX,4] , TamSX3( "E2_PARCELA" )[1] )} )
				aadd( aLinVncAux, { "N8M_TIPO"    		, PadR( aTitulos[nX,5] , TamSX3( "N8M_TIPO" )[1] )  } )
				aadd( aLinvncAux, { "N8M_FORNEC"    	, PadR( aTitulos[nX,6] , TamSX3( "N8M_FORNEC" )[1] )} )
                aadd( aLinvncAux, { "N8M_LOJA"    		, PadR( aTitulos[nX,7] , TamSX3( "N8M_LOJA" )[1] )	} )

				aAdd(aVncCPagD,aLinVncAux)
			Else
				/* CASO NÃO ENCONTRE NA SE2, MESMO ASSIM DEVE APAGAR NA NN7*/
				If NN7->(DbSeek(xFilial("NN7") + aTitulos[nX,3] + aTitulos[nX,19])) 						
					If NN7->NN7_TIPEVE == "1" //por evento						
						If N9G->(DbSeek(NN7->NN7_FILIAL + NN7->NN7_CODCTR + NN7->NN7_ITEM))
							If RecLock('N9G', .F.)
								N9G->(dbDelete())
								N9G->(MsUnlock()) 
							EndIf	
						EndIf

						If RecLock('NN7', .F.)
							NN7->(dbDelete())
							NN7->(MsUnlock()) 
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If len(aFina050AX) > nY
           aAdd(aFina050AX[len(aFina050AX)], aRetorno[nX])  //Adiciona o Status de retorno e aFina050ax para linkar com aTitulos (Recno)
		   nY := nY + 1
		EndIf	
		
		cFilAnt := cFilAntTmp  
		
	Next nX		
	
	If lContinua .OR. len(aFina050AX) > 0
		aRetorno := {}
		If len(aFina050AX) > 0
			For nX := 1 To Len(aFina050AX)															
				aFina050 := {}
				aFina050 := aClone(aFina050AX[nX,3])
				If aFina050AX[nX,1] == 4 //Alteracao
                    //alterado para reclock devido o fina040 nao atualizar previsao com parcelas
                    SE2->(dbGoTop())
					if SE2->(DbSeek(aFina050AX[nX,2]))
	                    If RecLock("SE2",.F.)
	                        If aFina050[4][2] == 0 //se a SE2 vai ficar com valor Zero, então deleta ela.
		                        SE2->(dbDelete())
							Else
								SE2->E2_VALOR  := aFina050[4][2]
	                        	SE2->E2_VLCRUZ := aFina050[5][2]
	                        	SE2->E2_SALDO  := aFina050[4][2]
							EndIf
	                        SE2->(MsUnLock())
	                    EndIf
                    endif	
				ElseIf aFina050AX[nX,1] == 5 //Exclusao				
				    SE2->(dbGoTop())
					if SE2->(DbSeek(aFina050AX[nX,2]))
	                    If RecLock("SE2",.F.)
	                        SE2->(dbDelete())
	                        SE2->(MsUnLock())
	                    EndIf					
					EndIf   					
					
					If NN7->(DbSeek(xFilial("NN7") + aFina050[2,2] + aFina050AX[nX,4])) 												
                        If NN7->NN7_TIPEVE == "1" //por evento							
                            If N9G->(DbSeek(NN7->NN7_FILIAL + NN7->NN7_CODCTR + NN7->NN7_ITEM))
                                If RecLock('N9G', .F.)
                                    N9G->(dbDelete())
                                    N9G->(MsUnlock()) 
                                EndIf	
                            EndIf
                        EndIf

                        If RecLock('NN7', .F.)
                            NN7->(dbDelete())
                            NN7->(MsUnlock()) 
                        EndIf						
					EndIf
				Else
				
					cFilAnt := aFina050[14][2]
				
					MsExecAuto( { |x,y| Fina050( x, y ) }, aFina050, aFina050AX[nX,1] )
					
					cFilAnt := cFilAntTmp 					
					
				    If lMsErroAuto
				    	If isBlind()
				    		cErros := STR0003 + cValToChar(aTitulos[nX,3]) //Ocorreram erros na geração da previsão financeira. Número: 
				    	Else
				    		MostraErro()
				    	EndIf
						//aAdd(aRetorno, {.F.,cErros, aTitulos[nX, Len(aTitulos) /*Ultima pos. array recno*/  ]})										    	
						aFina050AX[nX, Len(aFina050AX[nX] ), 1] := .F.
						aFina050AX[nX, Len(aFina050AX[nX] ), 2] := cErros				    	
					Else
						aFina050AX[nX, Len(aFina050AX[nX] ), 1] := .T.
						aFina050AX[nX, Len(aFina050AX[nX] ), 2] := ""				    	
					EndIf
                EndIf				

				aAdd(aRetorno, aFina050AX[nX, Len(aFina050AX[nX] )] )
			Next nX

			IF lContinua 
				If Len( aVncCPag ) > 0
					If !( fAgrVncPag (aVncCPag, 3, .T. ) ) //Incluir
						aFina050AX[1, Len(aFina050AX[1] ), 1] := .F.
						aFina050AX[1, Len(aFina050AX[1] ), 2] := STR0006
					EndIf
				EndIf

				IF Len( aVncCPagD ) > 0
					If !( fAgrVncPag (aVncCPagD, 5 )  )
					    aFina050AX[1, Len(aFina050AX[1] ), 1] := .F.
						aFina050AX[1, Len(aFina050AX[1] ), 2] := STR0007
					EndIf
				EndIf

			EndIf

		EndIf       
	EndIf
	
	FwFreeObj(aLinVncAux)	
	FwFreeObj(aFina050)		
	FwFreeObj(aVncCPag)
	RestArea(aAreaSE2)
	RestArea(aAreaNN7)
	RestArea(aAreaN9G)

Return aRetorno

/*/{Protheus.doc} OGX018ASLD
	Função responsável por atualizar os campos de saldo na NN7
	@type  Function
	@author Rafael Völtz
	@since 30/06/2018
	@version version
	@param cFilial,   char,  Filial 	
	@param cCodCtr,   char,  Código do contrato 	
	@param cItemPR,   char,  Item da previsão financeira
	@param cItemParc, char,  Parcela da previsão financeira
	@param aCampos,   array, Array com a estrutura do campo para atualização
				[01] Nome do campo na NN7
				[02] Valor a ser atribuído ou calculado
				[03] Tipo de operação ATU - ATUALIZAÇÃO, SOMA - SOMA, SUBT - SUBTRAÇÃO
/*/	
Function OGX018ASLD(cFilCtr, cCodCtr, cItemPR, cItemParc, aCampos)
	Local aAreaNN7  := NN7->(GetArea())
	Local aCampo    := {}
	Local lLocked   := .F.
	Local nX        := 0
	
	Default aCampos   := {}
	Default cItemParc := ""
	
	NN7->(DbSetOrder(1))
	If NN7->(DbSeek(cFilCtr + cCodCtr + cItemPR + cItemParc)) 							
		RecLock("NN7", .F.)
		lLocked := .T.
	EndIf	

	For nX := 1 To Len(aCampos)
		aCampo := aCampos[nX]
		
		If aCampo[1] $ "NN7_SLDPR|NN7_VLTEMI|NN7_VLTNCO|NN7_VLRAVI|NN7_SLDRA|NN7_VLSALD|NN7_VLCOMP|NN7_STSTIT|NN7_VALOR" .and. lLocked					
			If aCampo[3]	 == "SOMA" .and. ValType(aCampo[2]) == "N"
				NN7->&(aCampo[1]) 		+= aCampo[2]
			ElseIf aCampo[3] == "SUBT" .and. ValType(aCampo[2]) == "N"
				NN7->&(aCampo[1])  	    -= aCampo[2]
			ElseIf aCampo[3] == "ATU"
				NN7->&(aCampo[1]) 		:= aCampo[2]
			EndIf
		EndIf	

		If ValType(aCampo[2]) == "N" 
			If NN7->&(aCampo[1])  < 0
				NN7->&(aCampo[1]) := 0
			EndIf

			If aCampo[1] == "NN7_VLSALD" .OR. aCampo[1] == "NN7_VLTNCO"
				If NN7->NN7_VLSALD == 0 .and. NN7->NN7_VLTNCO == 0 
					NN7->NN7_STATUS := "5" //finalizado
				Else
					If NN7->NN7_STATUS != "2" .AND. NN7->NN7_STATUS != "3" .AND. NN7->NN7_STATUS != "4" //2 - CONFIRMADO; 3 - DIVERGENTE; 4 - EM ATRASO
						NN7->NN7_STATUS := "1" //aberto
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX

	If lLocked
		NN7->(MsUnlock())
	EndIf		

	RestArea(aAreaNN7)
	FwFreeObj(aAreaNN7)	
	FwFreeObj(aCampos)
	FwFreeObj(aCampo)	

Return .T.

