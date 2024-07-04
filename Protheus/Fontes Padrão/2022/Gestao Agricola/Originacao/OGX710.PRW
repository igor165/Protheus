#INCLUDE "Protheus.ch"
#INCLUDE "fwMvcDef.ch"
#INCLUDE "oga710.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __aTab1225 := {"NLN"}               //tabela inovação liberada na P12.1.25
Static __lLib1225 := AGRTABDIC(__aTab1225) //verifica se array de tabelas existe no dicionario de dados - para proteçao fonte
 
/* OGX710 - Rotinas para funções utilizadas na IE - instrucao de embarque 
@author vanilda.moggio
@since 02/05/2018
@version 1.0
*/

/** {Protheus.doc} OGX710GCLT
Rotina para selecionar quando Grãos o lote para enviar ao processo de exportacao 
para as regras fiscais do romaneio  

Agrupa por lote para a filial\processo de exportacao\romaneio
@param: 	cFilexp , char , filial do romaneio e do processo de exportacao
            cCodRom , char , codigo do romaneio do processo de exportacao 
            cFilorg , char , filial da instrucao de embarque
            cCodigo , char , codigo da instrucao de embarque
@return:	Nil
@author: 	vanilda.moggio
@since: 	01/05/2018
@Uso: 		OGA710
@type function
*/
Function OGX710GCLT(cFilexp, cCodROm, cFilorg, cCodigo)
	Local aArea     := GetArea()
	Local aItens    := {}
	default cCodROm := '' 

	cAliasQry := GetNextAlias()
	cQry := " SELECT NJM.NJM_LOTCTL as LOTE, NJM_QTDFIS as QTDFIS, NJM_VLRUNI AS PRECO,"
	
	IF __lLib1225
		cQry += "NJM_NUMAVI, NJM_NUMDCO, NJM_SEQDCO"
	ELSE
	 	cQry += " N7S_NUMAVI, N7S_NUMDCO, N7S_SEQDCO "
	EndIF
	 
	cQry += "   FROM " + RetSqlName("NJM") + " NJM "
	cQry += " INNER JOIN " + RetSqlName("N7S") + " N7S ON N7S.N7S_FILIAL = NJM.NJM_FILORG AND N7S.N7S_CODINE = NJM.NJM_CODINE "
	cQry += "    AND N7S.N7S_CODCTR = NJM.NJM_CODCTR AND N7S.N7S_ITEM = NJM.NJM_ITEM AND N7S.N7S_SEQPRI = NJM.NJM_SEQPRI "
	cQry += "  WHERE NJM.NJM_FILORG = '"+ cFilorg +"' "	 
	cQry += "    AND NJM.NJM_CODROM = '"+ cCodRom +"' "
	cQry += "    AND NJM.NJM_FILIAL = '"+ cFilexp +"' " 
	cQry += "    AND NJM.NJM_CODINE = '"+ cCodigo +"' "
	cQry += "    AND NJM.NJM_TIPO   = '4' "	 		 
	cQry += "	 AND NJM.D_E_L_E_T_ = ' ' "				
	cQry := ChangeQuery(cQry)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)

	DbSelectArea( cAliasQry )  
	(cAliasQry)->( dbGoTop() )

	While .Not. (cAliasQry)->( Eof() )		
		//aAdd(aItens, { 	(cAliasQry)->LOTE ,; 	
		//				(cAliasQry)->QTDFIS } )

        IF __lLib1225
			nPos := aScan(aItens, {|x| x[1]+x[5]+x[6]+x[7] == (cAliasQry)->LOTE + (cAliasQry)->NJM_NUMAVI + (cAliasQry)->NJM_NUMDCO + (cAliasQry)->NJM_SEQDCO  })
			If  nPos == 0
				aAdd(aItens, {(cAliasQry)->LOTE, (cAliasQry)->QTDFIS, (cAliasQry)->PRECO * (cAliasQry)->QTDFIS, 0, (cAliasQry)->NJM_NUMAVI, (cAliasQry)->NJM_NUMDCO, (cAliasQry)->NJM_SEQDCO})
				nPos := Len(aItens)
			Else
				aItens[nPos,2] += (cAliasQry)->QTDFIS //Quantidaade vinculada da regra fiscal do romaneio
				aItens[nPos,3] += (cAliasQry)->PRECO * (cAliasQry)->QTDFIS			
			EndIf
		ELSE
			nPos := aScan(aItens, {|x| x[1]+x[5]+x[6]+x[7] == (cAliasQry)->LOTE + (cAliasQry)->N7S_NUMAVI + (cAliasQry)->N7S_NUMDCO + (cAliasQry)->N7S_SEQDCO  })
			If  nPos == 0
				aAdd(aItens, {(cAliasQry)->LOTE, (cAliasQry)->QTDFIS, (cAliasQry)->PRECO * (cAliasQry)->QTDFIS, 0, (cAliasQry)->N7S_NUMAVI, (cAliasQry)->N7S_NUMDCO, (cAliasQry)->N7S_SEQDCO})
				nPos := Len(aItens)
			Else
				aItens[nPos,2] += (cAliasQry)->QTDFIS //Quantidaade vinculada da regra fiscal do romaneio
				aItens[nPos,3] += (cAliasQry)->PRECO * (cAliasQry)->QTDFIS			
			EndIf
		EndIF

		If aItens[nPos,2] > 0
			aItens[nPos,4] := aItens[nPos,3] / aItens[nPos,2]
		Else
			aItens[nPos,4] := 0
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo 
	(cAliasQry)->( dbCloseArea() )

	RestArea(aArea)

Return aItens


/** {Protheus.doc} OGX710DN82
Rotina para limpar relacionamento do pedido de exportacao e instrucao de embarque
quando o pedido de exportacao nao existir 
@param: 	cFilN7Q , char , filial da IE
            cCodine , char , codigo do IE 
@return:	Nil
@author: 	vanilda.moggio
@since: 	19/06/2018
@Uso: 		OGA710 ***/
Function OGX710DN82(cFilN7Q, cCodine)
	Local cAliasN82  := GetNextAlias()
	Local lsemExp    := .F.

	cQuery := "   SELECT N82_FILORI, N82_PEDIDO, R_E_C_N_O_ as RECNO"
	cQuery += "     FROM " + RetSqlName('N82') + " N82 "
	cQuery += "    WHERE N82.N82_FILIAL = '" + cFilN7Q + "'"
	cQuery += "      AND N82.N82_CODINE = '" + cCodine + "'"	
	cQuery += "      AND N82.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN82, .F., .T.)

	DbSelectArea("EE7")
	DbselectArea("N82")

	While !(cAliasN82)->( Eof() )		
		EE7->(dbSetOrder(1))
		If !EE7->(dbSeek( (cAliasN82)->N82_FILORI + (cAliasN82)->N82_PEDIDO))		    
			N82->(dbGoTo((cAliasN82)->RECNO))
			If RecLock( "N82", .F. )
				N82->(dbDelete())
				N82->(MsUnLock())
				iF !lsemExp 
					lsemExp := .T.
				EndIf	
			EndIf	
		EndIf     
		(cAliasN82)->(dbSkip())
	EndDo

	EE7->(DbCloseArea())
	N82->(DbCloseArea())
	(cAliasN82)->(DbCloseArea())

return lsemExp


/*/{Protheus.doc} OGX710QIGRAO
//TODO Quebra os itens para o produto grão pelo aviso, DCO e preço conforme N7S
@author claudineia.reinert
@since 02/07/2018
@version undefined
@param cFilGrao, characters, Filial do Grão
@param cCodIE, characters, Codigo da Instrução de embarque
@param cCodCliIE, characters, Codigo do cliente da instrução de embarque
@param cLojCliIE, characters, loja do cliente da instrução de embarque
@type function
/*/
Function OGX710QIGRAO(cFilGrao, cCodIE, cCodCliIE, cLojCliIE, cTes, cTipCli)
	Local nVlrTotal	:= 0
	Local nQtdTotal := 0
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	Local aItens	:= {}

	cQuery := " SELECT N7S_FILORG AS FILIAL, N7S_CODCTR AS CONTRATO, N7S_ITEM AS ENTREGA, N7S_SEQPRI AS REGFIS, 
	cQuery += " NLN_NUMAVI AS NUMAVISO, NLN_NUMDCO AS NUMDCO, NLN_SEQDCO AS SEQDCO, "
	cQuery += " SUM(N7S_QTDVIN) QTDVIN, NJR_VLRUNI AS VLRUNI ,NJR_VLRBAS AS VLRBAS, "
	cQuery += " N9A_NATURE AS NATUREZA  " 
	cQuery += " FROM " + RetSqlName('N7S') + " N7S "
	cQuery += " LEFT JOIN " + RetSqlName("NLN") + " NLN ON NLN.NLN_FILIAL = N7S.N7S_FILIAL AND NLN.NLN_CODINE = N7S.N7S_CODINE "
	cQuery += "   AND NLN.NLN_CODCTR = N7S.N7S_CODCTR AND NLN.NLN_ITEMPE = N7S.N7S_ITEM AND NLN.NLN_ITEMRF = N7S.N7S_SEQPRI "
	cQuery += "   AND NLN.D_E_L_E_T_ = ' ' "		
	cQuery += " INNER JOIN " + RetSqlName('NJR') + " NJR "
	cQuery += "   ON NJR.NJR_FILIAL = N7S_FILIAL "
	cQuery += "   AND NJR.NJR_CODCTR = N7S.N7S_CODCTR AND NJR.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName('N9A') + " N9A "
	cQuery += "   ON N9A.N9A_FILIAL = N7S_FILIAL AND N9A.N9A_CODCTR = N7S.N7S_CODCTR "
	cQuery += "   AND N9A.N9A_ITEM = N7S.N7S_ITEM AND N9A.N9A_SEQPRI = N7S.N7S_SEQPRI AND N9A.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE N7S_FILIAL = '" + FWxFilial("N7S") + "' AND N7S.N7S_CODINE = '" + cCodIE + "' " 
	cQuery += "   AND N7S.D_E_L_E_T_ = ' ' AND N7S_FILORG = '"+cFilGrao+"' AND N7S_QTDVIN > 0 "		
	cQuery += " GROUP BY N7S_FILORG, N7S_CODCTR, N7S_ITEM, N7S_SEQPRI , NLN_NUMAVI, NLN_NUMDCO, NLN_SEQDCO, NJR_VLRUNI, NJR_VLRBAS,N9A_NATURE "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

	If (cAliasQry)->(!EoF())
		While (cAliasQry)->(!EoF())

			//busca preço de faturamento ja convertido para a unidade do produto
			aPreco := OGX060(FWxFilial("NJR"), (cAliasQry)->( CONTRATO ), (cAliasQry)->( QTDVIN ), cTes, (cAliasQry)->( NATUREZA ), cFilGrao, (cAliasQry)->( ENTREGA ), (cAliasQry)->( REGFIS ) ,'' , '', .F. , cTipCli, cCodCliIE, cLojCliIE, IIF((cAliasQry)->( VLRUNI ) > 0, (cAliasQry)->( VLRUNI ), (cAliasQry)->( VLRBAS )), 'F')	
			nPos := aScan(aItens, {|x| x[1]+x[2]+x[3]+x[4]+STR(x[6]) == (cAliasQry)->FILIAL + (cAliasQry)->NUMAVISO + (cAliasQry)->NUMDCO + (cAliasQry)->SEQDCO + STR(aPreco[1,1]) })

			If  nPos = 0
				aAdd(aItens, {(cAliasQry)->FILIAL, (cAliasQry)->NUMAVISO, (cAliasQry)->NUMDCO, (cAliasQry)->SEQDCO, (cAliasQry)->QTDVIN, aPreco[1,1]})
				nPos := Len(aItens)
				nVlrTotal := (cAliasQry)->( QTDVIN ) * aPreco[1,1]
				nQtdTotal := (cAliasQry)->( QTDVIN )
			Else
				nVlrTotal += (cAliasQry)->( QTDVIN ) * aPreco[1,1]
				nQtdTotal += (cAliasQry)->( QTDVIN )
				aItens[nPos][6] := nQtdTotal / nVlrTotal  //preço medio
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->(dbCloseArea())

Return aItens

/*/{Protheus.doc} GetVencCtr
//Busca data, quantidade e valor da parcela do romaneio do
//saldo remansecente ao adiantamento do embarque
@author Marcelo Ferrari
@since 01/10/2018
@version undefined
@param cFilEmb, characters, Filial de Embarque
@param cIEmb, characters, Instrução de Embarque
@param cPedEEC, characters, Código do pedido do EEC
@param dDataEmb, DATE, Data do embarque / 
@type function
/*/
Function GetVencCtr(cFilEmb as Char, cPedEEC as char, dDataEmb as Date, nValor as Numeric, lComissao )
   Local  cSql := ""
   Local cAliasParc := ""
   Local aRetDtVct := {}
   Local aRet      := {}
   Local nX := 0
   Local nParcela := 0
   
   Default lComissao := .F.

   cSql := "SELECT DISTINCT N82_CODINE ,N82_PEDIDO "
   cSql +=       ",N7S.N7S_CODCTR, N7S_ITEM, N7S_SEQPRI "
   cSql +=       ",NJM_FILIAL, NJM_VLRTOT, NJM_QTDFIS, NJM_VLRUNI "
   cSql +=       ",N9K_CODCTR, N9K_CODROM, N9K_ITEROM, N9K_ITEMPE, N9K_ITEMRF,N9K_FIXADO "
   cSql += "FROM " + RetSqlName("N82") + " N82 "
   cSql += "INNER JOIN " + RetSqlName("N7S") + " N7S ON "
   cSql += " N7S_CODINE = N82_CODINE AND "
   cSql += " N7S.D_E_L_E_T_ = N82.D_E_L_E_T_ "

   cSql += "LEFT JOIN " + RetSqlName("NJM") + " NJM ON "
   cSql +=   " NJM_FILIAL = N82_FILORI AND "
   cSql +=   " NJM_CODCTR = N7S_CODCTR AND "
   cSql +=   " NJM_ITEM   = N7S_ITEM   AND "
   cSql +=   " NJM_SEQPRI = N7S_SEQPRI AND "
   cSql +=   " NJM_CODINE = N82_CODINE AND "
   cSql +=   " NJM.D_E_L_E_T_ = N7S.D_E_L_E_T_ "

   cSql += "LEFT JOIN " + RetSqlName("N9K") + " N9K ON "
   cSql +=   " N9K_CODCTR = N7S_CODCTR AND "
   cSql +=   " N9K_CODROM = NJM_CODROM AND "
   cSql +=   " N9K_ITEROM = NJM_ITEROM AND "
   cSql +=   " N9K.D_E_L_E_T_ = NJM.D_E_L_E_T_ "

   cSql += "INNER JOIN " + RetSqlName("N84") + " N84 ON "
   cSql += " N84_CODCTR = N9K_CODCTR AND "
   cSql += " N84_SEQUEN = N9K_SEQCP  AND "
   cSql += " N84.D_E_L_E_T_ = N9K.D_E_L_E_T_ "
   cSql += "WHERE 1=1 "
   cSql += " AND N82_PEDIDO = '" + cPedEEC + "' "
   cSql += " AND NJM_FILIAL = '" + cFilEmb + "' "
   cSql += " AND N9K_CODINE	= '' "
   cSql += " AND N9K_CODINV	= '' "
   cSql += " AND N9K_PREEMB = '' "   
   cSql += " AND N82.D_E_L_E_T_ = ' ' "

   cAliasParc := GetSqlAll(cSql)

   aParc := {} 
   While !((cAliasParc)->(Eof()))
	  aRetDtVct := OGX120DTPR((cAliasParc)->NJM_FILIAL, (cAliasParc)->N9K_CODCTR, (cAliasParc)->N9K_CODROM, (cAliasParc)->N9K_ITEROM, ;
	                          (cAliasParc)->N9K_ITEMPE, (cAliasParc)->N9K_ITEMRF, (cAliasParc)->NJM_QTDFIS, (cAliasParc)->NJM_VLRUNI, ;
						      IIF((cAliasParc)->N9K_FIXADO=="1", .T., .F.) , ;
							  .T. /* lEmbarque*/ , DDatabase /* Data do embarque*/ , ;
							  (cAliasParc)->N82_CODINE, (cAliasParc)->N82_PEDIDO, lComissao   )
	  
	  If !Empty(aRetDtVct[2])
         For nX := 1 to Len(aRetDtVct[2])
		    //Parcela = Valor * ( [pct da cond. pagto] / [Soma dos pct] )
			//Parcel[x1]  = 10000 * (       15             /     20         )
			//Parcel[x2]  = 10000 * (       5             /     20          )
			nParcela := nValor * ( aRetDtVct[2][nX][4] /  aRetDtVct[2][nX][3] )
		    aAdd(aRet, {aRetDtVct[2][nX][1], nParcela } )
		 Next nX
	  EndIf
	  (cAliasParc)->(dbSkip())
   EndDo
   
   //Chama função para gravar dados da invoice
   gravaInv(cFilEmb,cPedEEC)

Return aRet

/*/{Protheus.doc} gravaInv
//Salva dados da Invoice na tabela N82 
//Para uso no registro de peso e qualidade no destino
@author Tamyris Ganzenmueller
@since 09/10/2018
@version undefined
@param cFilEmb, characters, Filial de Origem
@param cPedEEC, characters, Código do pedido do EEC
/*/
Static Function gravaInv(cFilOri as Char, cPedEEC as char )
	Local nVlUnit   := 0
	Local nQtLiqInv := 0
	Local nQtSaldo  := 0
	Local nQtUM     := 1
	Local cNrInv    := ''
	
	//Busca a invoice do processo
	cNrInv := Posicione("EEC",1,cFilOri+cPedEEC,"EEC_NRINVO")
	cUnid  := Posicione("EEC",1,cFilOri+cPedEEC,"EEC_UNIDAD")
	cMoeda := Posicione("EEC",1,cFilOri+cPedEEC,"EEC_MOEDA")
	
	//Estrutura Sql para buscar o código da moeda
	cQuery := "   SELECT YF_MOEFAT " 
	cQuery += "   FROM "+ RetSqlName('SYF') + " SYF"
	cQuery += "   WHERE SYF.YF_MOEDA = '" + cMoeda + "'"
	cQuery += "   AND SYF.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	iF !Empty((cAliasQry)->YF_MOEFAT)
		cMoeda := (cAliasQry)->YF_MOEFAT
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	//Busca valores da invoice
	EXP->(DbSetOrder(1))
	If EXP->(DbSeek(cFilOri+cPedEEC+cNrInv))
	
		cAliasQry := GetNextAlias()
		cQuery := "   SELECT *  FROM " + RetSqlName('EEQ') + " EEQ "
		cQuery += "    WHERE EEQ.EEQ_FILIAL = '" + cFilOri + "' "
		cQuery += "      AND EEQ.EEQ_PREEMB = '" + cPedEEC + "' "
		cQuery += "      AND EEQ.EEQ_NRINVO = '" + cNrInv   + "' "
		cQuery += "      AND EEQ.EEQ_EVENT = '101'" ///Relacionadas às invoices
		cQuery += "      AND EEQ_DTCE  = ''" //Ainda não recebidas
		cQuery += "      AND EEQ.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		(cAliasQry)->(dbGoTop())
		If !(cAliasQry)->( Eof() )
			While ( cAliasQry )->( !Eof() )
				
				nQtSaldo += (cAliasQry)->EEQ_SALDO
				
				(cAliasQry)->( DbSkip() )
			EndDo
		EndIf
		(cAliasQry)->(DbCloseArea())
		
		nQtLiqInv :=  EXP->EXP_PESLIQ
		nVlUnit   := Round( (EXP->EXP_VLFOB / EXP->EXP_PESLIQ), TamSX3("N82_VALUNI" )[2] )
		
	EndIf
	EXP->(DbcloseArea())
		
	//Acha as N82 relacionadas para atualizar
	cQuery := " SELECT N82.R_E_C_N_O_ AS N82_RECNO  "
	cQuery += "  FROM " + RetSqlName('N82') + " N82 "
	cQuery += " WHERE N82_FILORI = '" + cFilOri + "'"
	cQuery += "   AND N82_PEDIDO = '" + cPedEEC + "'"
    cQuery += "   AND N82.D_E_L_E_T_ = ' ' " 
	cAliasN82 := getNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasN82,.F.,.T.)
	
	dbSelectArea(cAliasN82)
	(cAliasN82)->(dbGoTop())
	If (cAliasN82)->(!Eof() )
		While .Not. (cAliasN82)->( Eof() ) 

			dbSelectArea("N82")
			N82->( dbGoto( (cAliasN82)->(N82_RECNO) ) )
			N82->( RecLock( "N82", .f. ) )
				
				//Conversão de Unidade de Medida
				If cUnid <> N82->N82_UNIMED
					nQtUM	  := AGRX001(cUnid, N82->N82_UNIMED,1, N82->N82_CODPRO)
					nQtLiqInv := Round( (nQtLiqInv * nQtUM) , TamSX3("N82_QTLQIV" )[2] ) //preco
				EndIf
				
				//Conversão de Moeda
				If cMoeda <> N82->N82_MOEDA
					nVlUnit  := xMoeda(nVlUnit,  cMoeda, N82->N82_MOEDA , dDataBase , TamSX3("N82_VALUNI" )[2])
					nQtSaldo := xMoeda(nQtSaldo, cMoeda, N82->N82_MOEDA , dDataBase , TamSX3("N82_VLINVO" )[2])
				EndIF
				
				N82->N82_CODINV := cNrInv
				N82->N82_QTLQIV := nQtLiqInv
				N82->N82_VALUNI := nVlUnit
				N82->N82_VLINVO := nQtSaldo
				N82->N82_SLDINV := nQtSaldo - N82->N82_TOTDES
				
			N82->( msUnlock() )
			N82->(DbcloseArea())

			(cAliasN82)->( dbSkip() )
		EndDo
	EndIf
	(cAliasN82)->(DbcloseArea())

   
Return .T.

