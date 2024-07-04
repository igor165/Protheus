#INCLUDE "Protheus.ch"

STATIC __nPagina := 1

/*{Protheus.doc} OGX055
Atualiza as regras fiscais
@author jean.schulze
@since 23/03/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param cCodCaden, characters, descricao
@param cCodRegra, characters, descricao
@type function
*/
function OGX055(cFilCtr, cContrato, cCodCaden, cCodRegra)
	Local aAreaNJR   := NJR->(GetArea())
	Local aAreaN9A   := N9A->(GetArea())
	
	Default cCodCaden := ""
	Default cCodRegra := ""

	//Recalcula Valores da regra FISCAL
	DbSelectArea("NJR")
	NJR->(DbSetorder(1))
	if NJR->(dbSeek(cFilCtr + cContrato))
			
		OGX018(cFilCtr, cContrato, .F.) 
		OGX018ATPR(cFilCtr, cContrato, "OGX055") //atualiza os registros na se1
		
	endif	
	
	RestArea(aAreaNJR)
	RestArea(aAreaN9A)
	
return .t.

/*{Protheus.doc} OGX055SLDR
Função para Faturamento de itens de Regra Fiscal
@author jean.schulze
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param cCodCad, characters, descricao
@param cCodRegFis, characters, descricao
@param cQtd, characters, descricao
@type function
*/
function OGX055SLDR(cFilCtr, cContrato, cCodCad, cCodRegFis, cQtd  )
	Local cErros    := ""

	//posiciona na regra fiscal para faturar
	dbSelectArea('N9A')
	N9A->(dbSetOrder(1))
	If N9A->(dbSeek(cFilCtr+cContrato+cCodCad+cCodRegFis))
		If RecLock('N9A',.f.)
			if cQtd < 0 //removendo valor
				N9A->N9A_SDONF -= cQtd //aumenta o saldo
			else //adicionando valor
				if N9A->N9A_SDONF >= cQtd //podemos ter uma regra que por algum motivo exceda a quantidade por causa do % de tolerância
				 	N9A->N9A_SDONF -= cQtd
				else
					N9A->N9A_SDONF := 0
				endif
			endif
			N9A->N9A_QTDNF += cQtd
			
			N9A->(MsUnLock())
		EndIf		 
	endif

return cErros


//-------------------------------------------------------------------
/*/{Protheus.doc} OGX055SIMU
Simulaçao de faturamento por fixacao
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGX055SIMU(cFormaCalc, cFilialCtr, cCodCtr, cCodCad, cCodRegra, nQtdRegra, cTes, cNaturFin, cTipClient, cCodClient, cCodLoja, cFilOrg, cCodNgc, cVersao, cTipoMerc, nMoedaFat, nDias, cUmPrec, cUmProd, cCodPro, nMoedaCtr, dCadIni, dCadFim, nTaxaCota)
 
    Local cAliasQry  := GetNextAlias() 
    Local cBody      := ""
    Local cBodyFix   := ""
    Local aDadosClie := {}
    Local nFatConv   := 0
    Local cSimbMoeda := ""
    Local cSimbMoeEx := ""
    Local aPaginas   := {}    
    Local nPag   := 0

    Local cQualid := ""
    Local cGenMod := ""
    Local cTecGMO := ""
    Local nAreaN79 := Nil
    Local nIdxOrd  := 0
    Local nSldQtdFix := 0
    Local cTipFix := ""
    Local cTpFret := ""

    Local nPos    := 0

    Private _lMercInEx := .f.
    Private _IndiceCad := ""
    Private _cCodCli   := ""
    Private _cLojCli   := ""

    Private _n8DQTDVNC := 0            

    DbSelectArea("NJR")	
    if NJR->(dbSeek(cFilialCtr+cCodCtr)) //pega os valores padrões do contrato	
        
        aDadosClie := fGetCliente()
        nFatConv   := AGRX001( cUmProd,cUmPrec ,1,cCodPro)   
        cTpFret    := NJR->NJR_TPFRET
        _IndiceCad := Posicione("NNY",1,cFilialCtr+cCodCtr+cCodCad,"NNY_IDXNEG")        
        
        If NJR->NJR_TIPMER == "1"
            cSimbMoeda := AGRMVSIMB(1) 

            If NJR->NJR_MOEDA > 1
                cSimbMoeEx := AGRMVSIMB(NJR->NJR_MOEDA) 
                _lMercInEx := .t.
            EndIf
        else
            cSimbMoeda := AGRMVSIMB(NJR->NJR_MOEDA) 
        EndIf

        nSldQtdFix := GetDataSql("SELECT N9A_QUANT " + ;
                                "FROM " + RetSqlName("N9A") + " N9A " + ; 
                                "WHERE N9A_CODCTR = '" + cCodCtr + "' " + ;
                                "AND N9A_ITEM = '" + cCodCad + "' " + ;
                                "AND N9A_SEQPRI = '" + cCodRegra + "' " + ;
                                "AND D_E_L_E_T_ = ' ' ");

        cBody := fCriaHTML()

        cBody := StrTran( cBody, "_%PRODUTO%_",    ALLTRIM(NJR->NJR_CODPRO) + " - " + ALLTRIM(POSICIONE("SB1", 1, xFilial("SB1")+NJR->NJR_CODPRO,"B1_DESC")))
        cBody := StrTran( cBody, "_%CONTRATO%_",   ALLTRIM(NJR->NJR_CTREXT) )
        cBody := StrTran( cBody, "_%TIPO_CLIE%_",  X3CBOXDESC("N9A_TIPCLI", cTipClient) )
        cBody := StrTran( cBody, "_%TIPO_FRET%_",  X3CBOXDESC("NJR_TPFRET", cTpFret)  )
        cBody := StrTran( cBody, "_%MOEDA_CTR%_",  AGRMVMOEDA(NJR->NJR_MOEDA) )
        cBody := StrTran( cBody, "_%MOEDA_FAT%_",  AGRMVMOEDA(NJR->NJR_MOEDAR))
        cBody := StrTran( cBody, "_%MOEDA_PGTO%_", AGRMVMOEDA(NJR->NJR_MOEDAF))        
        cBody := StrTran( cBody, "_%SAFRA%_", NJR->NJR_CODSAF)
        cBody := StrTran( cBody, "_%FIL_ORIG%_", AllTrim(FWFilialName(, cFilOrg, 1)))
        cBody := StrTran( cBody, "_%TIPO_PRC%_", X3CBOXDESC("NJR_TIPFIX",NJR->NJR_TIPFIX) )
        cBody := StrTran( cBody, "_%MERCADO%_",  X3CBOXDESC("NJR_TIPMER",NJR->NJR_TIPMER) )	
        cBody := StrTran( cBody, "_%TES%_",  cTES + " - " + POSICIONE("SF4", 1, xFilial("SF4")+cTES, "F4_TEXTO"))	
        cBody := StrTran( cBody, "_%NATUREZA%_",  cNaturFin + " - " + POSICIONE("SED", 1, xFilial("SED")+cNaturFin, "ED_DESCRIC"))	    

        cBody := StrTran( cBody, "_%NOME_CLIENTE%_",  ALLTRIM(aDadosClie[1,1]))	    
        cBody := StrTran( cBody, "_%ENDERECO_CLIENTE%_",  ALLTRIM(aDadosClie[1,2]) + " " + ALLTRIM(aDadosClie[1,3]))	    
        cBody := StrTran( cBody, "_%CIDADE_CLIENTE%_",  ALLTRIM(aDadosClie[1,4]) + " - " + ALLTRIM(aDadosClie[1,5]))	    
        cBody := StrTran( cBody, "_%CNPJ_CLIENTE%_",  TRANSFORM(aDadosClie[1,6],"@R 99.999.999/9999-99"))	    

        cBody := StrTran( cBody, "_%DT_ENTREGA_INI%_",  dtoc(dCadIni))	    
        cBody := StrTran( cBody, "_%DT_ENTREGA_FIM%_",  dtoc(dCadFim))	    

        cBody := StrTran( cBody, "_%UM_PRODUTO%_",  cUmProd)	    
        cBody := StrTran( cBody, "_%UM_CTR%_",  cUmPrec)	     

        cBody := StrTran( cBody, "_%UM_PRECO_FIX%_",  cUmPrec   )
        cBody := StrTran( cBody, "_%UM_PRECO_FAT%_",  cUmPrec   )
        cBody := StrTran( cBody, "_%UM_PRECO_DEMONSTRATIVO%_",  cUmPrec   )
        cBody := StrTran( cBody, "_%MOEDA_PRECO_FIX%_",  cSimbMoeda   )
        cBody := StrTran( cBody, "_%MOEDA_PRECO_FAT%_",  cSimbMoeda   )
        cBody := StrTran( cBody, "_%MOEDA_PRECO_DEMONSTRATIVO%_",  cSimbMoeda   )
        cBody := StrTran( cBody, "_%MOEDA_PRECO_FIX_EX%_",  cSimbMoeEx   )
        cBody := StrTran( cBody, "_%MOEDA_PRECO_FAT_EX%_",  cSimbMoeEx   )
        cBody := StrTran( cBody, "_%MOEDA_PRECO_DEMONSTRATIVO_EX%_",  cSimbMoeEx   )

        nAreaN79 := Nil
        nIdxOrd  := 0

        If Select("N79") > 0
            nAreaN79 := N79->(GetArea())
            nIdxOrd  := N79->(IndexOrd())
        Else
            dbSelectArea("N79")
            N79->(DbSetorder())
        EndIf    

        cQualid := ""
        cGenMod := ""
        cTecGMO := ""
        N79->(dbGoTop())
        If N79->(dbSeek(FwXFilial("N79")+cCodNgc+cVersao ))
            //Dados da Qualidade
            cQualid := N79->N79_INFQUA
            cGenMod := X3CBOXDESC("N79_GENMOD",N79->N79_GENMOD) 
            cTecGMO := N79->N79_TECGMO
            cTipFix := N79->N79_TIPFIX
        EndIf

        cBody := StrTran( cBody, "_%TIT:INFQUA%_",  AgrTitulo("N79_INFQUA") + ": "   )
        cBody := StrTran( cBody, "_%CPO:INFQUA%_",  cQualid  )

        cBody := StrTran( cBody, "_%TIT:GENMOD%_",  AgrTitulo("N79_GENMOD") + ":"   )
        cBody := StrTran( cBody, "_%CPO:GENMOD%_",  cGenMod   )
        
        cBody := StrTran( cBody, "_%TIT:TECGMO%_",  AgrTitulo("N79_TECGMO") + ":"   )
        cBody := StrTran( cBody, "_%CPO:TECGMO%_",  cTecGMO   )

        IF !(empty(nAreaN79))
            RestArea(nAreaN79)
            N79->(DbSetorder(nIdxOrd))
        EndIf

    EndIf    
    
    BeginSql Alias cAliasQry
        SELECT N8D.N8D_QTDVNC,
            N8D.N8D_VALOR,
            N8D.N8D_ITEMFX,           
            NN8.NN8_DATA
        FROM %table:N8D% N8D
    INNER JOIN %table:NN8% NN8 ON NN8.NN8_FILIAL = N8D.N8D_FILIAL AND NN8.NN8_CODCTR = N8D.N8D_CODCTR AND NN8.NN8_ITEMFX = N8D.N8D_ITEMFX AND NN8.%notDel%
        WHERE N8D.N8D_FILIAL = %Exp:cFilialCtr%
        AND N8D.N8D_CODCTR = %Exp:cCodCtr%
        AND N8D.N8D_CODCAD = %Exp:cCodCad%
        AND N8D.N8D_REGRA  = %Exp:cCodRegra%
        AND N8D.%NotDel%
        ORDER BY N8D.N8D_SEQVNC
    EndSql

        If FwIsInCallStack("OGC062")
            If Empty(aQtdsNfPv)
                _n8DQTDVNC := N9A->N9A_SDONF
            Else
                //Buscar no array a regra fiscal posicionada e retornar a qtd no _n8DQTDVNC
                nPos := AScan(aQtdsNfPv, {|x| AllTrim(x[1]) == AllTrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI))})
                If nPos > 0
                    If Month(aQtdsNfPv[nPos,3]) = Month(dDatabase)
                        _n8DQTDVNC := N9A->N9A_SDONF + aQtdsNfPv[nPos,2]
                    Else
                        _n8DQTDVNC := aQtdsNfPv[nPos,2]
                    EndIf
                Else
                    _n8DQTDVNC := N9A->N9A_SDONF
                EndIf
            EndIf
        Else
            _n8DQTDVNC := (cAliasQry)->N8D_QTDVNC
        EndIf

    //Adiciona os valores por fixação
    (cAliasQry)->(dbGoTop())
    While (cAliasQry)->(!Eof())   
        cBodyFix := fCarregaInfo(cFilialCtr, cFilOrg, cCodCtr, cCodCad, cCodRegra, (cAliasQry)->N8D_ITEMFX, nFatConv, cBody, cAliasQry, cUmProd,cUmPrec, cCodPro, cCodNgc, cVersao, cTes, cNaturFin, cTipClient, cCodClient, cCodLoja, nMoedaFat, nTaxaCota, cTpFret)
        aAdd(aPaginas, cBodyFix)
        nSldQtdFix := nSldQtdFix - _n8DQTDVNC
        (cAliasQry)->(dbSkip())
    EndDo

    (cAliasQry)->(dbCloseArea())

        //Validar se for contrato FIXO não deve ter saldo a fixar / Indice
    If (cTipFix == '2') .AND. (nSldQtdFix > 0)
        /* chama a segunda vez, agora sem a fixaçao (ou seja por índice ou valor base do contrato) */
        cBodyFix := fCarregaInfo(cFilialCtr, cFilOrg, cCodCtr, cCodCad, cCodRegra, "", nFatConv, cBody, cAliasQry, cUmProd,cUmPrec, cCodPro, cCodNgc, cVersao, cTes, cNaturFin, cTipClient, cCodClient, cCodLoja, nMoedaFat, nTaxaCota, cTpFret)
        aAdd(aPaginas, cBodyFix)
    EndIf

    for nPag := 1 to len(aPaginas)
        aPaginas[nPag] := StrTran( aPaginas[nPag], "_%PAGINA%_",  ALLTRIM(STR(      nPag    ) ) ) //Adiciona a página de valores por índices
        aPaginas[nPag] := StrTran( aPaginas[nPag], "_%PAGINAS%_", ALLTRIM(STR(len(aPaginas) ) ) )     //Total de páginas
    Next nPag

    fPrintSimu( cFilialCtr, cCodCtr, cTipClient, cNaturFin, cTes, aPaginas)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} fCarregaInfo
Carrega os dados principais da tela de consulta
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fCarregaInfo(cFilialCtr, cFilOrg, cCodCtr, cCodCad, cCodRegra, cItemFx, nFatConv, cBodyFix, cAliasQry, cUmProd,cUmPrec, cCodPro, cCodNgc, cVersao, cTes, cNaturFin, cTipClient, cCodClient, cCodLoja, nMoedaFat, nTaxaCota, cTpFret)
 
 Local cAliasQry2 := GetNextAlias()
 Local cAliasQry3 := GetNextAlias()   
 Local cHtmlFin   := "" 
 Local cSize  := "size='4'"
 Local nVolume := 0   
 Local aImpostos := {}
 Local nVlrFix   := 0
 Local nVlrFatur := 0 
 Local nVlrIndx  := 0
 Local cTipPrc   := ""
 Local nVlrFreKg := 0
 Local cUMPesoGFE := SuperGetMv("MV_UMPESO",,"KG")  //Unidade de medida do GFE - Padrão é KG
 Local nFator := 1
 
 Local nSumVlrTot := 0 
 Local nSumValor  := 0 
 Local nCotacao   := 0 
 Local aItens     := {}

    BeginSql Alias cAliasQry2
        SELECT ND1_SEQCP,
               ND1_SEQPF,
               ND1_SEQN9J,
               ND1_SEQ    ,    
               ND1_VLUFIX,
               ND1_VLUFAT,                              
               ND1_VLTAXA,
               ND1_MOEDA,               
               ND1_DTVCTO,
               ND1_SEQCP,
               ND1_TIPPRC,
               ND1_VLUDES,
               ND1_ITEMFX,
            SUM(ND1_QTDE) ND1_QTDE
           FROM %table:ND1% ND1
          WHERE ND1.ND1_FILIAL  = %Exp:cFilialCtr %
            AND ND1.ND1_CODCTR  = %Exp:cCodCtr%
            AND ND1.ND1_ITEMPE  = %Exp:cCodCad%
            AND ND1.ND1_ITEMRF  = %Exp:cCodRegra%
            //AND ND1.ND1_ITEMFX  = %Exp:cItemFx%
            AND ND1.%NotDel%
            GROUP BY ND1_SEQCP,
                     ND1_SEQPF,
                     ND1_SEQN9J ,
                     ND1_SEQ    , 
                     ND1_TIPPRC, 
                     ND1_VLUFIX,
                     ND1_VLUFAT,                                          
                     ND1_VLUDES,
                     ND1_VLTAXA,
                     ND1_MOEDA,               
                     ND1_DTVCTO,
                     ND1_ITEMFX                                                
            ORDER BY ND1.ND1_DTVCTO
    EndSql

    (cAliasQry2)->(dbGoTop())
    While (cAliasQry2)->(!Eof())

        If !(AllTrim((cAliasQry2)->ND1_ITEMFX) == AllTrim(cItemFx))
            (cAliasQry2)->(dbSkip())
            Loop
        EndIf

        nVolume   += (cAliasQry2)->ND1_QTDE 
        nVlrFix   := (cAliasQry2)->ND1_VLUFIX
        nVlrFatur += (cAliasQry2)->ND1_VLUFAT * (cAliasQry2)->ND1_QTDE                
        nVlrIndx  += (cAliasQry2)->ND1_VLUFIX * (cAliasQry2)->ND1_QTDE        
        nVlrFreKg += (cAliasQry2)->ND1_VLUDES * (cAliasQry2)->ND1_QTDE        
        cTipPrc   := (cAliasQry2)->ND1_TIPPRC
        
        BeginSql Alias cAliasQry3
         SELECT N84_REFCTR,
                N84_REFPRF,
                N84_QTDE,
                N84_PCT,           
                N84_NRDIAS,
                N84_ANTPOS,
                N84_TIPVAL,
                N84_SEQUEN
            FROM %table:N84% N84
           WHERE N84.N84_FILIAL = %Exp:cFilialCtr%
             AND N84.N84_CODCTR = %Exp:cCodCtr%
             AND N84.N84_SEQUEN = %Exp:(cAliasQry2)->ND1_SEQCP%
             AND N84.%NotDel% 
        EndSql

        (cAliasQry3)->(dbGoTop())
        
        nValorFat := 0
        
        While (cAliasQry3)->(!Eof())    

	        nValorFat := ( (cAliasQry2)->ND1_VLUFAT * (cAliasQry2)->ND1_QTDE ) * 1           
            
            cHtmlFin += "<tr>"
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+dtoc(stod((cAliasQry2)->ND1_DTVCTO))+"</font></td>"                                       //data            
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+Transform( nValorFat , "@E 999,999.99" )+"</font></td>"              //valor
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+Transform((cAliasQry2)->ND1_VLTAXA, "@E 999,999.99" )+"</font></td>"             //cotacao
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+SUPERGETMV("MV_MOEDA"+ALLTRIM(STR((cAliasQry2)->ND1_MOEDA)),.f.," ")+"</font></td>" //"N84_REFCTR"
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+X3CBOXDESC("N84_REFCTR",(cAliasQry3)->N84_REFCTR)+"</font></td>" //"N84_REFCTR"
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+X3CBOXDESC("N84_REFPRF",(cAliasQry3)->N84_REFPRF)+"</font></td>" //"N84_REFPRF"	
            cHtmlFin += "	<td align='center'><font face='verdana'  " + cSize + ">"+X3CBOXDESC("N84_TIPVAL",(cAliasQry3)->N84_TIPVAL)+"</font></td>" //"N84_TIPVAL"	
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+Transform((cAliasQry3)->N84_QTDE, "@E 999,999.99")+"</font></td>" //"N84_QTDE"	
            cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+Transform((cAliasQry3)->N84_PCT, "@E 999.99")+"</font></td>"     //"N84_PCT"
            cHtmlFin += "	<td align='center'><font face='verdana'  " + cSize + ">"+str((cAliasQry3)->N84_NRDIAS)+"</font></td>"                      //"N84_NRDIAS	
            cHtmlFin += "	<td align='center'><font face='verdana'  " + cSize + ">"+X3CBOXDESC("N84_ANTPOS",(cAliasQry3)->N84_ANTPOS)+"</font></td>"  //"N84_ANTPOS	
            cHtmlFin += "</tr>"
            
            nSumValor  := nSumValor + nValorFat           
            
            nSumVlrTot := nSumVlrTot + nValorFat            

            If nCotacao = 0
                nCotacao := (cAliasQry2)->ND1_VLTAXA
            EndIf

            (cAliasQry3)->(dbSkip())
        EndDo
        
        (cAliasQry3)->(dbCloseArea())
        (cAliasQry2)->(dbSkip())
    EndDo
    (cAliasQry2)->(dbCloseArea())    

    //Totalizador do financeiro
    cHtmlFin += "<tr bgcolor='#D8D8D8'>"
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + "></font></td>"                                       //data
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + ">"+Transform( nSumVlrTot , "@E 999,999.99" )+"</font></td>"              //valor
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + "></font></td>"             //cotacao
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + "></font></td>" //"N84_REFCTR"
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + "></font></td>" //"N84_REFCTR"
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + "></font></td>" //"N84_REFPRF"	
    cHtmlFin += "	<td align='center'><font face='verdana'  " + cSize + "</font></td>" //"N84_TIPVAL"	
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + "></font></td>" //"N84_QTDE"	
    cHtmlFin += "	<td align='center'><font face='verdana' " + cSize + "></font></td>" //"N84_PCT"
    cHtmlFin += "	<td align='center'><font face='verdana'  " + cSize + "></font></td>"                      //"N84_NRDIAS	
    cHtmlFin += "	<td align='center'><font face='verdana'  " + cSize + "></font></td>"  //"N84_ANTPOS	
    cHtmlFin += "</tr>"

    cHtmlFin += "<tr>"
    cHtmlFin += "<td colspan='11' align='center'></td>"
    cHtmlFin += "</tr>"


    if Alltrim(cTipPrc) == '1' 
        If nVlrFatur > 0
            nVlrFatur := nVlrFatur /  _n8DQTDVNC
        EndIf

        If nVlrFreKg > 0
            nVlrFreKg := nVlrFreKg /  _n8DQTDVNC
        EndIf
    else
        If nVlrFatur > 0
            nVlrFatur := nVlrFatur /  nVolume
        EndIf

        If nVlrIndx > 0
            nVlrIndx := nVlrIndx /  nVolume
        EndIf

        If nVlrFreKg > 0
            nVlrFreKg := nVlrFreKg /  nVolume
        EndIf
    EndIf

    aItens := {{cFilOrg, nVlrFatur, nVolume, "" }}

    aImpostos := OGX020(cFilOrg,;
                        "S",   ;
                        cCodClient,  ;
                        cCodLoja,    ;
                        cCodPro,     ;
                        cTES,        ;
                        aItens,      ; 
                        cTipClient,  ;
                        cNaturFin,   ;
                        nMoedaFat,   ;
                        nTaxaCota,   ;
                        cTpFret)
    
    cBodyFix += fGetStrucFin("1") + cHtmlFin + fGetStrucFin("2")        
    cBodyFix += fGetImpostos(aImpostos)  

    If Alltrim(cTipPrc) == '1' //fixado
        cBodyFix := StrTran( cBodyFix, "_%ITEMFX%_",        "Fixação " + cItemFx )
        cBodyFix := StrTran( cBodyFix, "_%DT_FIX%_",        dtoc(stod((cAliasQry)->NN8_DATA))   )
        cBodyFix := StrTran( cBodyFix, "_%PESO_PRODUTO%_",  Transform(_n8DQTDVNC, "@E 999,999.99" ) )
        cBodyFix := StrTran( cBodyFix, "_%PESO_CTR%_",      Transform(_n8DQTDVNC * nFatConv, "@E 999,999.99")  )

        cBodyFix := StrTran( cBodyFix, "_%TITULO_PRECO_FIX%_",  "Pre&ccedil;o Fixado(Venda):"  )        

        nVlrBRL := nVlrFix 
        If NJR->NJR_TIPMER == "1"
            nVlrBRL := nVlrFix * nCotacao
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX%_",    Transform(OGX700UMVL(nVlrBRL,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX_EX%_", Transform(OGX700UMVL(nVlrFix,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
        else
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX%_",    Transform(OGX700UMVL(nVlrBRL,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX_EX%_", Transform(OGX700UMVL(nVlrFix,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
        EndIf

    else        

        If Alltrim(cTipPrc) == "3" //indice 
            nVlrBRL := nVlrIndx 
            cBodyFix := StrTran( cBodyFix, "_%TITULO_PRECO_FIX%_", "Pre&ccedil;o Índice: " )            
        else // 2 Base
            nVlrBRL  := NJR->NJR_VLRBAS
            cBodyFix := StrTran( cBodyFix, "_%TITULO_PRECO_FIX%_", "Pre&ccedil;o Base: " )            
        EndIf
        
        If NJR->NJR_TIPMER == "1"
            nVlrBRL := nVlrBRL * nCotacao
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX%_",    Transform(OGX700UMVL(nVlrBRL,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX_EX%_", Transform(OGX700UMVL(nVlrFix,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
        else
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX%_",    Transform(OGX700UMVL(nVlrBRL,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
            cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX_EX%_", Transform(OGX700UMVL(nVlrFix,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
        EndIf

        //cBodyFix := StrTran( cBodyFix, "_%PRECO_FIX%_",     Transform(OGX700UMVL(nVlrIndx,cUmProd,cUmPrec, cCodPro), "@E 999,999.99" )   )
        cBodyFix := StrTran( cBodyFix, "_%ITEMFX%_",        "À fixar " + Iif(Alltrim(cTipPrc) == "3", "(Índice "+_IndiceCad+")", "(Valor Base Contrato)" )  )
        cBodyFix := StrTran( cBodyFix, "_%DT_FIX%_",        ""   )
        cBodyFix := StrTran( cBodyFix, "_%PESO_PRODUTO%_",  Transform(nVolume, "@E 999,999.99" ) )
        cBodyFix := StrTran( cBodyFix, "_%PESO_CTR%_",      Transform(nVolume * nFatConv, "@E 999,999.99")  )
    EndIF       
    
    nVlrFatBRL := OGX700UMVL(nVlrFatur,cUmProd,cUmPrec, cCodPro)
    nFator := OGX700UMVL(1,cUMPesoGFE,"TN", "")
    If nFator == 1
        nFator := OGX700UMVL(1,cUMPesoGFE,"TON", "")
    EndIf
    
    cBodyFix := StrTran( cBodyFix, "_%PRECO_FAT%_",     Transform(nVlrFatBRL, "@E 999,999.99" )    ) 
    cBodyFix := StrTran( cBodyFix, "_%PRECO_FAT_EX%_",        Transform(nVlrFatBRL / nCotacao, "@E 999,999.99" )    )            

    cBodyFix := StrTran( cBodyFix, "_%FRETE_TON%_",             Transform(nVlrFreKg * nFator,   "@E 999,999.99" )    )
    cBodyFix := StrTran( cBodyFix, "_%FRETE_R$%_",              Transform(nVlrFreKg * nVolume , "@E 999,999.99" )    )         

    cBodyFix += "</body></html>"

Return cBodyFix


//-------------------------------------------------------------------
/*/{Protheus.doc} fGetStrucFin
Monta estrutura da tabela de dados do financeiro em HTML
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fGetStrucFin(cPart)
Local cSize     := "size='4'"
Local cHtml     := ""

 If cPart == "1" //inicio
    cHtml := "<center>"
    cHtml += "<table width= 100%>"
    cHtml += "<tbody>"
    cHtml += "<tr>"
    cHtml += "	<td colspan='11' bgcolor='#A9F5E1' align='center'><font face='verdana' " + cSize + "><strong>FINANCEIRO</strong></font></td>"	
    cHtml += "</tr>"
    cHtml += "<tr>"
    cHtml += "	<td width=5% align='center'><font face='verdana' " + cSize + "><strong>Data</strong></font></td>"
    cHtml += "	<td width=13% align='center'><font face='verdana' " + cSize + "><strong>Valor</strong></font></td>" 
    cHtml += "	<td width=5% align='center'><font face='verdana' " + cSize + "><strong>Cotação</strong></font></td>"	
    cHtml += "	<td width=8% align='center'><font face='verdana' " + cSize + "><strong>Moeda</strong></font></td>"	
    cHtml += "	<td width=13% align='center'><font face='verdana' " + cSize + "><strong>Ref. Ctr.</strong></font></td>"	
    cHtml += "	<td width=13% align='center'><font face='verdana' " + cSize + "><strong>Ref. Prev.</strong></font></td>"	
    cHtml += "	<td width=10%  align='center'><font face='verdana'  " + cSize + "><strong>Tipo Valor</strong></font></td>"	
    cHtml += "	<td width=13% align='center'><font face='verdana' " + cSize + "><strong>Qtde.</strong></font></td>"	
    cHtml += "	<td width=5%  align='center'><font face='verdana' " + cSize + "><strong>Pct.</strong></font></td>"	
    cHtml += "	<td width=5%  align='center'><font face='verdana'  " + cSize + "><strong>Dias</strong></font></td>"	
    cHtml += "	<td width=10%  align='center'><font face='verdana'  " + cSize + "><strong>Ant/Pos</strong></font></td>"	
    cHtml += "</tr>"
else
    cHtml += "<tr>"
    cHtml += "	<td colspan='11'>&nbsp;</td>" 
    cHtml += "</tr>"
    cHtml += "</tbody>"
    cHtml += "</table>"
    cHtml += "</center>"
EndIf

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetCliente
Busca dados de cliente
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fGetCliente()

    Local cAliasQry := GetNextAlias()
    Local aRetorno  := {}
    
    BeginSql Alias cAliasQry
        SELECT SA1.A1_NOME, 
               SA1.A1_END, 
               SA1.A1_BAIRRO, 
               SA1.A1_EST, 
               SA1.A1_MUN,
               SA1.A1_CGC               
            FROM %table:NJ0% NJ0
            INNER JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = NJ0.NJ0_FILIAL 
                                   AND SA1.A1_COD    = NJ0.NJ0_CODCLI 
                                   AND SA1.A1_LOJA   = NJ0.NJ0_LOJCLI 
                                   AND SA1.%NotDel%
            WHERE NJ0.NJ0_FILIAL   = %xFilial:NJ0%
                AND NJ0.NJ0_CODENT = %Exp:NJR->NJR_CODENT%
                AND NJ0.NJ0_LOJENT = %Exp:NJR->NJR_LOJENT%
                AND NJ0.%NotDel%
    EndSql

    (cAliasQry)->(dbGoTop())
    While (cAliasQry)->(!Eof())
        aAdd(aRetorno, {(cAliasQry)->A1_NOME,   ;
                        (cAliasQry)->A1_END,    ;
                        (cAliasQry)->A1_BAIRRO, ;                        
                        (cAliasQry)->A1_MUN,    ;
                        (cAliasQry)->A1_EST,    ;
                        (cAliasQry)->A1_CGC})

        (cAliasQry)->(dbSkip())
    EndDo

    (cAliasQry)->(dbCloseArea())

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fPrintSimu
Função para gerar a tela de simulação de faturamento.
@author  rafael.voltz
@since   18/04/2018
@version version
/*/
//-------------------------------------------------------------------
Function fPrintSimu(cFilCtr, cCodCtr,  cTipocli, cNaturez, cTES, aPaginas)    
	
    Default cTES      	:= ""    
    Default cTipocli  	:= ""
    Default cNaturez  	:= ""    			    
		
	OGX055TL(aPaginas, 600, 1100, 600, 1100)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaHTML
Monta HTML do relatório de preços
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fCriaHTML()

 Local cHtml := ""
 Local cSize := "size='4'"

cHtml += "<html>  "  
cHtml += "<head>"
cHtml += "</head>"
cHtml += "<body>"

cHtml += "<table width= 100%>
cHtml += "<tbody>
cHtml += "<tr>
cHtml += "<td align='center' colspan='5' width= 90%><font face='verdana' size='5'><strong>Contrato _%CONTRATO%_</font></strong></td>
cHtml += "<td align='right' colspan='5'  width= 10%><font face='verdana' size='2'><strong>[ _%PAGINA%_/ _%PAGINAS%_ ]</font></strong></td>
cHtml += "</tr>
cHtml += "</tbody>
cHtml += "</table

cHtml += "<hr>"

cHtml += "<table width= 100%>"
cHtml += "<tbody>"

cHtml += "<tr>"
cHtml += "<td align='center' colspan='5'><font face='verdana' " + cSize + "><strong>Prev. de Entrega _%DT_ENTREGA_INI%_ até _%DT_ENTREGA_FIM%_</font></strong></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td align='center' colspan='5'><font face='verdana' " + cSize + "><strong>_%ITEMFX%_ _%DT_FIX%_</font></strong></td>"
cHtml += "</tr>"
cHtml += "<tr>"
cHtml += "<td align='center' colspan='5'><font face='verdana' " + cSize + "><strong>&nbsp;</font></strong></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Produto:</font></strong></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%PRODUTO%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Tipo Cliente:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%TIPO_CLIE%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Safra:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%SAFRA%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Natureza:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%NATUREZA%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Filial de Origem:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%FIL_ORIG%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Tipo do Frete:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%TIPO_FRET%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=15% align='right'><font face='verdana' " + cSize + "><strong>TES:</strong></font></td>"
cHtml += "<td width=20%><font face='verdana' " + cSize + "> _%TES%_</font></td>"    
cHtml += "<td width=10% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Moeda Contrato:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%MOEDA_CTR%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Tipo Pre&ccedil;o:&nbsp;</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%TIPO_PRC%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=15% align='right'><font face='verdana' " + cSize + "><strong>Moeda Faturamento:</strong></font></td>"
cHtml += "<td width=40%><font face='verdana' " + cSize + "> _%MOEDA_FAT%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Mercado:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%MERCADO%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Moeda Pagamento:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%MOEDA_PGTO%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>&nbsp;</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "></font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong></strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "></font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Nome:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%NOME_CLIENTE%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Peso (_%UM_PRODUTO%_):</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%PESO_PRODUTO%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Endereço:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%ENDERECO_CLIENTE%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Peso (_%UM_CTR%_):</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%PESO_CTR%_</font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>Cidade:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%CIDADE_CLIENTE%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong></strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "></font></td>"
cHtml += "</tr>"

cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>CNPJ:</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "> _%CNPJ_CLIENTE%_</font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong></strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "></font></td>"
cHtml += "</tr>"
cHtml += "<!--  XXXXXXXXXX SEPARAÇÃO XXXXXXXXXXXXXXX -->"
cHtml += "<tr>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong>&nbsp;</strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "></font></td>"    
cHtml += "<td width=05% align='right'><font face='verdana' " + cSize + ">&nbsp;</font></td>"
cHtml += "<td width=20% align='right'><font face='verdana' " + cSize + "><strong></strong></font></td>"
cHtml += "<td width=30%><font face='verdana' " + cSize + "></font></td>"
cHtml += "</tr>"
cHtml += "<!--  XXXXXXXXXXXXXXXXXXXXXXX -->"

cHtml += "<!--  SEÇÃO VALORES / QUALIDADE -->"
cHtml += "<TR>"
	cHtml += "<!--  SEÇÃO VALORES -->"
	cHtml += "<td colspan=2>"
		cHtml += "<table width= 100% border='0' bordercolor='00FFFF'>"
			cHtml += "<tr>"
				cHtml += "<td width=45% align='right'><font face='verdana' " + cSize + "><strong>_%TITULO_PRECO_FIX%_</strong></font></td>"
				cHtml += "<td width=55%><font face='verdana' " + cSize + "> _%MOEDA_PRECO_FIX%_ _%PRECO_FIX%_ _%UM_PRECO_FIX%_ " + iif(_lMercInEx, " <br> _%MOEDA_PRECO_FIX_EX%_ _%PRECO_FIX_EX%_ _%UM_PRECO_FIX%_ ","") + "</font></td>"    
			cHtml += "</tr>"
			cHtml += "<tr>"
				cHtml += "<td width=45% align='right'><font face='verdana' " + cSize + "><strong>Pre&ccedil;o Faturamento:</strong></font></td>"
				cHtml += "<td width=55%><font face='verdana' " + cSize + "> _%MOEDA_PRECO_FAT%_ _%PRECO_FAT%_ _%UM_PRECO_FAT%_ " + iif(_lMercInEx, "<BR>  _%MOEDA_PRECO_FAT_EX%_  _%PRECO_FAT_EX%_ _%UM_PRECO_FAT%_", "") + "</font></td>"    
			cHtml += "</tr>"
            cHtml += "<tr>"
				cHtml += "<td width=45% align='right'><font face='verdana' " + cSize + "><strong>Frete:</strong></font></td>"
				cHtml += "<td width=55%><font face='verdana' " + cSize + "> _%FRETE_TON%_ /TON<br> R$ _%FRETE_R$%_</font></td>"    
			cHtml += "</tr>"
			cHtml += "<tr>"
				cHtml += "<td width=45% align='right'><font face='verdana' " + cSize + "></font></td>"
				cHtml += "<td width=55%><font face='verdana' " + cSize + "></font></td>"    
			cHtml += "</tr>"
		cHtml += "</Table>"
	cHtml += "</td>"
	cHtml += "<td>&nbsp;</td>"
	cHtml += "<!--  QUALIDADE -->"
	cHtml += "<td colspan=2 rowspan=5 valign='TOP' >"
		cHtml += "<table width=100% border='0' bordercolor='#0000FF' >"
			cHtml += "<tr colspan=2>"
				cHtml += "<td width=35% align='right'><font face='verdana' " + cSize + "><strong>_%TIT:INFQUA%_</strong></font></td> "
				cHtml += "<td width=60% ><font face='verdana' " + cSize + ">_%CPO:INFQUA%_</font></td> "
			cHtml += "</tr>"
			cHtml += "<tr>"
				cHtml += "<td width=35% align='right'><font face='verdana' " + cSize + "><strong>_%TIT:GENMOD%_</strong></font></td>"
				cHtml += "<td width=60% ><font face='verdana' " + cSize + ">_%CPO:GENMOD%_</font></td>"
			cHtml += "</tr>"
			cHtml += "<tr>"
				cHtml += "<td width=35% align='right'><font face='verdana' " + cSize + "><strong>_%TIT:TECGMO%_</strong></font></td>"
				cHtml += "<td width=60% ><font face='verdana' " + cSize + ">_%CPO:TECGMO%_</font></td>"
			cHtml += "</tr>"
		cHtml += "</table>"
	cHtml += "</td>"
cHtml += "</tr>"

cHtml += "<!--  XXXXXXXXXX FIM CABEÇALHO XXXXXXXXXXXXXXX -->"
cHtml += "<tr>"
cHtml += "<td width=15% align='right'>&nbsp;</td>"
cHtml += "<td width=20%>&nbsp;</td>"    
cHtml += "<td width=10% align='right'>&nbsp;</td>"
cHtml += "<td width=15% align='right'>&nbsp;</td>"
cHtml += "<td width=40%>&nbsp;</td>"
cHtml += "</tr>"
cHtml += "<!--  XXXXXXXXXXXXXXXXXXXXXXX -->"

cHtml += "</tbody>"
cHtml += "</table>"

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX020TL
Tela responsável por exibir a simulacao do faturamento
@author  rafael.voltz
@since   12/04/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function OGX055TL( aPaginas, nDlgLin, nDlgCol, nEditLin, nEditCol )

 Local oDlg := nil
 Local oEdit := nil

 //DAGROCOM-7616 - tratamento para evitar que a aPaginas,venha vazia e gere errolog.
  If Empty(aPaginas)
    aPaginas := {""}
 EndIf 

    __nPagina := 1 

    DEFINE DIALOG oDlg TITLE "Simulação Regra Fiscal" FROM 3, 1 TO nDlgLin, nDlgCol PIXEL
    oEdit := tSimpleEditor():New(0, 0, oDlg, nEditLin, nEditCol, , .T.)
    oEdit:Align := CONTROL_ALIGN_ALLCLIENT   
    oEdit:Load(aPaginas[__nPagina])	

    // Cria barra de botões
    oTBar := TBar():New( oDlg, 25, 36, .T.,,,, .F. )
    // Cria botões
    oTBtnBmp1 := TBtnBmp():NewBar( 'S4WB010N',,,, 'Imprimir Página', { || fAbrirHtml(aPaginas[__nPagina])}, .F., oTBar, .T., { || .T. },, .F.,,, 1,,,,, .T. )
    oTBtnBmp1 := TBtnBmp():NewBar( 'IMPRESSAO',,,, 'Imprimir Tudo', { || fAbrirTudoHtml(aPaginas) }, .F., oTBar, .T., { || .T. },, .F.,,, 1,,,,, .T. )
    oTBtnBmp2 := TBtnBmp():NewBar( 'PMSSETAESQ',,,, 'Anterior', { ||fBeforePag(oEdit, aPaginas) }, .F., oTBar, .T., { || .T. },, .F.,,, 1,,,,, .T. ) 
    oTBtnBmp2 := TBtnBmp():NewBar( 'PMSSETADIR',,,, 'Próximo', { || fNextPag(oEdit, aPaginas) }, .F., oTBar, .T., { || .T. },, .F.,,, 1,,,,, .T. ) 
  
    ACTIVATE DIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fNextPag
Move para a próxima página
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fNextPag(oEdit, aPaginas)
 
 If __nPagina + 1 > Len(aPaginas)
    MsgInfo("Não existem mais fixações nessa direção.")
 else
    __nPagina++
    oEdit:Load(aPaginas[__nPagina])
 EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fBeforePag
Move para página anterior
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fBeforePag(oEdit, aPaginas)
    If __nPagina - 1 <= 0 
        MsgInfo("Não exitem mais fixações nessa direção.")
    else
        __nPagina--
        oEdit:Load(aPaginas[__nPagina])
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAbrirHtml
Abrir tela de HTML
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fAbrirHtml(cHtml)
    Local cDir :=  GetTempPath(.T.)  //Busca o caminho da pasta temp do usuario local
    Local cArquivo := cDir + "DemonstrativoFixacao_" + ALLTRIM(NJR->NJR_CODCTR) + ".html"
    local nHandle := Nil

    nHandle := FCREATE(cArquivo)

    cHtml := StrTran(cHtml, "size='4'", "size='2'")
  
    if nHandle = -1
        conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
    else
        FWrite(nHandle, cHtml)
        FClose(nHandle)
    endif

    shellExecute("Open", cArquivo, " /k dir", "C:\", 1 )

Return 

Static Function fAbrirTudoHtml( aPaginas )

    Local cAllHtml := ""
    Local nPag     := 0

    Local cDir :=  GetTempPath(.T.)  //Busca o caminho da pasta temp do usuario local
    Local cArquivo := cDir + "DemonstrativoFixacao_" + ALLTRIM(NJR->NJR_CODCTR) + ".html"
    local nHandle := Nil

//<html>
//<head></head>
//<body>
    For nPag := 1 to len(aPaginas)
        cHtml := aPaginas[nPag]
        cHtml := StrTran(cHtml, "</body>", "")
        cHtml := StrTran(cHtml, "</html>", "")

        If nPag > 1
            cHtml := StrTran(cHtml, "<html>", "")
            cHtml := StrTran(cHtml, "<head></head>", "")
            cHtml := StrTran(cHtml, "<body>", "")
        EndIf

        cHtml := cHtml + "<BR><HR>"
        cHtml := cHtml + "<p style='page-break-before: always'>"
        cHtml := cHtml + "<BR>"


        cAllHtml := cAllHtml + cHtml 
    Next nPag

    cAllHtml := cAllHtml + "</body>" + "</html>"

    nHandle := FCREATE(cArquivo)

    cAllHtml := StrTran(cAllHtml, "size='4'", "size='2'")
  
    if nHandle = -1
        conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
    else
        FWrite(nHandle, cAllHtml)
        FClose(nHandle)
    endif

    shellExecute("Open", cArquivo, " /k dir", "C:\", 1 )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fGetImpostos
Monta tabela de dados dos impostos em HTML
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fGetImpostos(aImpostos)
 Local cHtml  := ""
 Local nX     := 0
 Local cSize  := "size='4'" 
 Local nPauta := 0
 
    cHtml := "<center>"
    cHtml += "<table width= 80%>"
    cHtml += "<tbody>"  
    cHtml += "<tr>"
    cHtml += "	<td colspan='4' bgcolor='#A9F5E1' align='center'><font face='verdana' " + cSize + "><strong>IMPOSTOS</strong></font></td>"	
    cHtml += "</tr>"  
    cHtml += "<tr>"
    cHtml += "	<td width=10% align='center'><font face='verdana' " + cSize + "><strong>Imposto</strong></font></td>"        
    cHtml += "	<td width=15% align='center'><font face='verdana' " + cSize + "><strong>Base</strong></font></td>"
    cHtml += "	<td width=10% align='center'><font face='verdana' " + cSize + "><strong>Alíquota</strong></font></td>"
    cHtml += "	<td width=15% align='center'><font face='verdana' " + cSize + "><strong>Valor</strong></font></td>"    
    cHtml += "</tr>"

    For nX := 1 To Len(aImpostos)

        If alltrim(aImpostos[nX,02]) == "PAUTA"
            nPauta := aImpostos[nX,03]
            loop
        EndIf

        cHtml += "<tr >"
        cHtml += "	<td align='center'><font face='verdana' " + cSize + ">"+ aImpostos[nX,02] +"</font></td>"                    //Imposto        
        cHtml += "	<td align='center'><font face='verdana' " + cSize + ">"+ Transform(aImpostos[nX,03], "@E 999,999.99" ) +"</font></td>"      //Base
        cHtml += "	<td align='center'><font face='verdana' " + cSize + ">"+ Transform(aImpostos[nX,04], "@E 999,999.99" ) +"</font></td>"      //Alíquota
        cHtml += "	<td align='center'><font face='verdana' " + cSize + ">"+ Transform(aImpostos[nX,05], "@E 999,999.99" ) +"</font></td>"      //Valor        
        cHtml += "</tr>" 

    Next nX

    If nPauta > 0
        cHtml += "<tr >"
        cHtml += "	<td colspan='4'><font face='verdana' size='2'>*Pauta de ICMS: "+ Transform(nPauta, "@E 999,999.99" )  +"</font></td>"                    //Imposto                
        cHtml += "</tr>" 
    EndIf
    
    cHtml += "</tbody>"
    cHtml += "</table>"
    cHtml += "</center>"
 
Return cHtml
