#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Programa  ณ getPartStr ณ Autor ณ Totvs				ณ Data ณ 04.02.2012 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descrio ณ Retorna parte da string conforme tamanho do campo			ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

static Function getPartStr(cCampo,cString)
LOCAL cRet := Left(cString,TamSX3(cCampo)[1])
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Retira da string original o conteudo ja capturado
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cString := SubStr(cString,(TamSX3(cCampo)[1])+1,Len(cString))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWSE1  บAutor  ณTotvs               บ Data ณ  20/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de faturas SE1 contrato, subcon e matricula  บฑฑ
ฑฑบ		     ณPara criacao de botoes no browse use a sintaxe 1#=fied ou   บฑฑ
ฑฑบ		     ณ 1#Titulo=field o numero e a ligacao com a funcao a ser     บฑฑ
ฑฑบ		     ณ executada (inicia sempre de zero)					  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWBXX()
Local aArea 	:= GetArea()
Local aWhere  	:= StrToArray( paramixb[1] , '|' )
Local cAlias  	:= "SE2"
Local cAlias1  	:= ""
Local cAlias2  	:= ""
Local cAlias3  	:= ""
Local cCampos 	:= "Vencimento=E2_VENCREA,Prestador=NOMEFOR,Valor=VALOR,Titulo=PREFIXO+NUM+PARCELA+TIPO,Situacao=SITUAC"
Local cSql 	  	:= ""
Local cSql1	  	:= ""
Local cSql2	  	:= ""
Local cSql3	  	:= ""
Local cWhere  	:= ""
Local cWhere1  	:= ""
Local cWhere2  	:= ""
Local cWhere3  	:= ""
Local cFieldJ	:= ""
Local nRegPagina:= 30
Local nI		:= 1
Local cTipo 	:= GETMV("MV_PLTIPE2")
Local cJoin		:= " "+RetSqlName(cAlias)
Local cSomTit	:= GetNewPar("MV_PLSSOTI","N")
Local cCodRda	:= ""
Local cTipRel	:= ""
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cComp		:= ""
Local cPeg		:= ""
Local cGlosa	:= ""
Local cMes		:= ""
Local cAno		:= ""
Local cCodOpe	:= PLSINTPAD()

cTipo := Eval({|| &cTipo })
For nI:=1 To Len(aWhere)
	aWhere1 := StrToArray( aWhere[nI] , '=' )
	If aWhere1[1] == 'Field_CODRDA'
   		cCodRda := AllTrim(aWhere1[2]) 
	Endif
	If aWhere1[1] == 'Field_TIPREL'
   		cTipRel := AllTrim(aWhere1[2]) 
	Endif
	If aWhere1[1] == 'Field_DTDE'
		cDataDe := DTOS(CTOD(aWhere1[2]))
	Endif
	If aWhere1[1] == 'Field_DTATE'
		cDataAte := DTOS(CTOD(aWhere1[2]))
	Endif
	If aWhere1[1] == 'Field_COMP'
		cComp := SubStr(aWhere1[2],4,4) + SubStr(aWhere1[2],1,2)
	Endif
	If aWhere1[1] == 'Field_PEG'
		cPeg := FormatIn(aWhere1[2], ',')  //Pois do portal as pegs vem sem as aspas, acarretando erro na query
	Endif
	If aWhere1[1] == 'Field_GLOSA'
		cGlosa := aWhere1[2]
	Endif
Next
If cTipRel == "4"

	cCampos := "Protocolo=BCI_CODPEG,Situacao=SITUAC,Valor Apresentado=VALORAPR,Valor Glosa=VALORGLO,Valor Liberado=VALOR,Mes=BCI_MES,Ano=BCI_ANO"
	cAlias	:= "BCI"
	/*
	cAlias1	:= "BD5"
	cAlias2	:= "BD7"
	cAlias3	:= "BE4"
	*/
	cJoin	:= " "+RetSqlName(cAlias)
	
	cSql := "SELECT 'BCI' AS ALIAS, BCI_CODPEG BCI_CODPEG, BCI_STTISS SITUAC, SUM(BD7_VALORI) AS VALORAPR, SUM(BD7_VLRGLO)+SUM(BD7_VLRGTX) AS VALORGLO, SUM(BD7_VLRPAG) AS VALOR, BCI_MES, BCI_ANO,  "
	cSql += RetSqlName("BCI")+".R_E_C_N_O_ IDENLINHA "
	cWhere += " FROM " + RetSqlName(cAlias) + cJoin
	cWhere += " INNER JOIN " + RetSqlName('BD7') + " BD7 ON "
	cWhere += " BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = BCI_CODOPE AND BD7_CODLDP = BCI_CODLDP AND BD7_CODPEG = BCI_CODPEG AND BD7_CODRDA = BCI_CODRDA  "
	cWhere += " AND BD7_BLOPAG <> '1' AND BD7.D_E_L_E_T_ = ' '  "
	cWhere += " WHERE BCI_FILIAL = '"+xFilial(cAlias)+"' AND "
	cWhere += " BCI_OPERDA = '" + cCodOpe + "' AND "
	cWhere += " BCI_CODRDA = '"+cCodRda+"' AND "
	If !Empty(cComp)
		cMes := SubStr(cComp,5,2)
		cAno := SubStr(cComp,1,4)
		cWhere += " BCI_ANO = '" + cAno + "' AND"
		cWhere += " BCI_MES = '" + cMes + "' AND"
	Else
		cWhere += " BCI_CODPEG IN  " + cPeg + "  AND "
	EndIf
	cWhere += " BCI_FASE IN ('2','3','4') AND"
	cWhere += " BCI_SITUAC = '1' AND "
	cWhere += " BCI_CODLDP NOT IN ('"+PLSRETLDP(4)+"','"+PLSRETLDP(9)+"') "
	
	//Como podemos ter vแrias PEGs selecionadas, preciso fazer o vํnculo com a BD7 e
	// recuperar todo o valor de glosa de cada PEG para subtrair do valor obtido na BCI
	If cGlosa == "true"	  
		cWhere += " AND ((BCI_VLRGLO > 0 ) OR " 		
		cWhere += " (EXISTS (SELECT BD7_CODPEG FROM " + RetSqlName('BD7') + " WHERE BD7_FILIAL = '" + xFilial("BD7") +"' AND "
		cWhere += " BD7_CODOPE = BCI_CODOPE AND BD7_CODLDP = BCI_CODLDP AND BD7_CODPEG = BCI_CODPEG AND BD7_CODRDA = '" + cCodRda + "' AND"
		If !Empty(cPeg) 
			cWhere += "  BD7_CODPEG IN  " + cPeg + "  AND "
		Endif
		cWhere += "  BD7_VLRGLO > 0 AND D_E_L_E_T_ = ''))) "	
	EndIf
		
	cSql := cSql + cWhere +   " AND "+ RetSqlName("BCI")+".D_E_L_E_T_ = ' ' GROUP BY BCI_CODPEG, BCI_STTISS, BCI_VLRGUI ,BCI_VLRGLO, BCI_MES, BCI_ANO, " + RetSqlName("BCI") + ".R_E_C_N_O_"
	cWhere += " AND " + RetSqlName("BCI")+".D_E_L_E_T_ = ' ' "
	cFieldJ := "BCI_CODPEG"

Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
	//ณ paginas. (count)
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	cSql := " SELECT 'SE2' AS ALIAS, (CASE WHEN E2_BAIXA='' THEN E2_VENCREA ELSE E2_VENCREA END) AS E2_VENCREA, E2_NOMFOR NOMEFOR,E2_PREFIXO PREFIXO,E2_NUM NUM,E2_PARCELA PARCELA,E2_TIPO TIPO,  "
	cSql += " (CASE WHEN E2_SALDO>0 THEN 'Liberado para Pagamento' ELSE 'Pagamento Efetuado' END) AS SITUAC, "
	cSql += retSqlName("SE2")+".R_E_C_N_O_ IDENLINHA, "	

	cSql +="	(CASE " 
	cSql +="		WHEN ED_DEDINSS = '1' AND ( (E2_PRETPIS =' ' OR E2_PRETCOF = ' ' OR E2_PRETCSL = ' ') AND (E2_PIS+E2_COFINS+E2_CSLL) > 0 )"
	cSql +="		 	THEN (E2_VALOR+E2_IRRF+E2_ISS+E2_INSS) + (E2_PIS+E2_COFINS+E2_CSLL)"
	cSql +="		WHEN ED_DEDINSS <> '1' AND ( (E2_PRETPIS =' ' OR E2_PRETCOF = ' ' OR E2_PRETCSL = ' ') AND (E2_PIS+E2_COFINS+E2_CSLL) > 0 )"
	cSql +="			THEN (E2_VALOR+E2_IRRF+E2_ISS) + (E2_PIS+E2_COFINS+E2_CSLL)"
	cSql +="		WHEN ED_DEDINSS = '1' "
	cSql +="			THEN (E2_VALOR+E2_IRRF+E2_ISS+E2_INSS)" 
	cSql +="		ELSE (E2_VALOR+E2_IRRF+E2_ISS) "
	cSql +="	END ) AS VALOR "
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ Where - necessario para utilizacao no contador
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	cWhere += " WHERE E2_FILIAL = '"+xFilial(cAlias)+"' AND "
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ Where
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	cWhere += " E2_CODRDA = '"+cCodRda+"' AND "
	If !Empty(cComp)
		cWhere += " SUBSTRING(E2_PLLOTE,1,6) = '"+cComp+"' AND "	
	Else
		cWhere += " E2_VENCREA >= '"+cDataDe+"' AND "
		cWhere += " E2_VENCREA <= '"+cDataAte+"' AND "
	EndIf
	cWhere	+= " E2_TIPO NOT IN ('AB-','FB-','FC-','IR-','IN-','IS-','PI-','CF-','CS-','FU-','FE-','PR ','PA ','TX ','TXA','ISS','INS','INP') AND "
	cWhere	+= cJoin + ".D_E_L_E_T_ = ' ' "
	
	
	cSql += " FROM " + RetSqlName(cAlias) + "  "
	cSql +="  INNER JOIN "+RetSqlName('SED') +" ON ED_FILIAL ='" +xFilial('SED')+ "' AND ED_CODIGO=E2_NATUREZ AND  "
	cSql +=RetSqlName('SED')+".D_E_L_E_T_=' ' "
	
	cSql += " INNER JOIN " + RetSqlName('BD5') +" BD5 ON BD5_FILIAL = '" + xFilial('BD5') + "' AND "
	cSql += " BD5.BD5_CODOPE = '" + PLSINTPAD() + "' AND BD5.BD5_CODRDA = '" + cCodRda + "' AND "
	cSql += " BD5.BD5_NUMLOT = E2_PLLOTE AND BD5.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName('BD6') +" BD6 ON BD6_FILIAL = '" + xFilial('BD6') + "' AND "
	cSql += " BD5.BD5_CODOPE = BD6.BD6_CODOPE AND BD5.BD5_CODRDA = BD6.BD6_CODRDA AND BD5.BD5_CODPEG = BD6.BD6_CODPEG AND BD6.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName('BR8') +" BR8 ON BR8_FILIAL = '" + xFilial('BR8') + "' AND "
	cSql += " BR8.BR8_CODPSA = BD6.BD6_CODPRO AND BR8.BR8_CODPAD = BD6.BD6_CODPAD AND BR8_ODONTO = '1' AND BR8.D_E_L_E_T_ = ' ' "
		
	If cSomTit == "N" 
		cAlias1  	:= "SC7"

		cSql1:= " UNION " 
	
		cSql1 += "  SELECT 'SC7' AS ALIAS, C7_EMISSAO E2_VENCREA, A2_NOME NOMEFOR, ' ' PREFIXO, C7_NUM NUM, ' ' PARCELA, ' ' TIPO, "
		cSql1 += " 'PEDIDO DE COMPRA EM ABERTO ' AS SITUAC, "+RetSqlName("SC7")+".R_E_C_N_O_ IDENLINHA, C7_TOTAL VALOR  FROM "+RetSqlName('SC7')+" " 
		cSql1 +="  INNER JOIN "+RetSqlName('SA2') +" ON A2_FILIAL ='" +xFilial('SA2')+ "' AND A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND "
		cSql1 +=RetSqlName('SA2')+".D_E_L_E_T_=' ' "
	
		cWhere1= " WHERE C7_FILIAL = '"+Xfilial('SC7')+"' AND "
		cWhere1 += " C7_CODRDA = '"+cCodRda+"' AND "
		If !Empty(cComp)
			cWhere1 += " SUBSTRING(C7_LOTPLS,1,6) = '"+cComp+"' AND "	
		Else
			cWhere1 += " C7_EMISSAO >= '"+cDataDe+"' AND "
			cWhere1 += " C7_EMISSAO <= '"+cDataAte+"' AND "
		EndIf
		
		cWhere1+=RetSqlName('SC7')+".D_E_L_E_T_ = ' ' AND "
		cWhere1+=" NOT EXISTS (SELECT D1_DOC FROM "+RetSqlName('SD1') "
		cWhere1+=" WHERE D1_FILIAL= C7_FILIAL " 
		cWhere1+="		AND D1_PEDIDO = C7_NUM "
		cWhere1+="		AND D1_ITEMPC = C7_ITEM  AND "
		cWhere1+=RetSqlName('SD1')+".D_E_L_E_T_ = ' ')" 
	EndIf
	
	//Define fun็ใo que irแ ser executada para calcular uma das colunas existentes no retorno da grid.
	//Atentar para o posicionamento dentro dessa fun็ใo
	//cFunCalc := "PLCalcDemP"
	//cColCalc := "VALOR"
	
	cSql := cSql + cWhere + cSql1 + cWhere1 + " ORDER BY E2_VENCREA DESC "
EndIf

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",cAlias1,cSql1,cWhere1,.T.," ",cAlias2,cSql2,cWhere2,{},cAlias3,cSql3,cWhere3} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWSE1  บAutor  ณTotvs               บ Data ณ  20/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de faturas SE1 contrato, subcon e matricula  บฑฑ
ฑฑบ		      ณPara criacao de botoes no browse use a sintaxe 1#=fied ou   บฑฑ
ฑฑบ		      ณ 1#Titulo=field o numero e a ligacao com a funcao a ser     บฑฑ
ฑฑบ		      ณ executada (inicia sempre de zero)							    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWSE1()
LOCAL aArea 	:= GetArea()
LOCAL aWhere  	:= StrToArray( paramixb[1] , '=' )
LOCAL cAlias  	:= "SE1"
LOCAL cCampos 	:= "0#Imp=RECNO,?=E1_NOMCLI,?=E1_EMISSAO,Titulo=E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,?=E1_MESBASE,?=E1_ANOBASE,?=E1_VENCREA,?=E1_VALOR"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL nRegPagina:= 7
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados do F3
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

Do Case
	Case AllTrim(TCGetDB()) $ "ORACLE/DB2"
		cSql := "SELECT E1_NOMCLI,E1_EMISSAO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_MESBASE,E1_ANOBASE,E1_VENCREA,(E1_SALDO-E1_IRRF) AS E1_VALOR, TO_CHAR(R_E_C_N_O_) RECNO"
	
	Case AllTrim(TCGetDB()) == "POSTGRES"
		cSql := "SELECT E1_NOMCLI,E1_EMISSAO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_MESBASE,E1_ANOBASE,E1_VENCREA,(E1_SALDO-E1_IRRF) AS E1_VALOR, TO_CHAR(R_E_C_N_O_,'FM99999999') RECNO"
	
	Otherwise
		cSql := "SELECT E1_NOMCLI,E1_EMISSAO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_MESBASE,E1_ANOBASE,E1_VENCREA,(E1_SALDO-E1_IRRF) AS E1_VALOR, CONVERT ( VARCHAR,R_E_C_N_O_ ) RECNO"
EndCase

cSql += "	 FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE E1_FILIAL = '" + xFilial(cAlias) + "' "
cWhere += "	   AND D_E_L_E_T_ 	= ' ' "
cWhere += "	   AND E1_STATUS 	= 'A' "
cWhere += "    AND E1_TIPO 	IN ("+ IIF(GETNEWPAR("MV_PLSTIT","DP")=="DP", "'DP'",GETNEWPAR("MV_PLSTIT","DP")) +") "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where conforme tipo do logim
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Do Case
	Case aWhere[1] == "Field_MATUSU"
		cWhere += " AND E1_CODINT = '" + getPartStr("E1_CODINT",@aWhere[2]) + "' "
		cWhere += " AND E1_CODEMP = '" + getPartStr("E1_CODEMP",@aWhere[2]) + "' "
		cWhere += " AND E1_MATRIC = '" + getPartStr("E1_MATRIC",@aWhere[2]) + "' "

	Case aWhere[1] == "Field_NUMCON"
		cWhere += " AND E1_CODINT = '" + getPartStr("E1_CODINT",@aWhere[2]) + "' "
		cWhere += " AND E1_CODEMP = '" + getPartStr("E1_CODEMP",@aWhere[2]) + "' "
		cWhere += " AND E1_CONEMP = '" + getPartStr("E1_CONEMP",@aWhere[2]) + "' "
		cWhere += " AND E1_VERCON = '" + getPartStr("E1_VERCON",@aWhere[2]) + "' "

	Case aWhere[1] == "Field_SUBCON"
		cWhere += " AND E1_CODINT = '" + getPartStr("E1_CODINT",@aWhere[2]) + "' "
		cWhere += " AND E1_CODEMP = '" + getPartStr("E1_CODEMP",@aWhere[2]) + "' "
		cWhere += " AND E1_CONEMP = '" + getPartStr("E1_CONEMP",@aWhere[2]) + "' "
		cWhere += " AND E1_VERCON = '" + getPartStr("E1_VERCON",@aWhere[2]) + "' "
		cWhere += " AND E1_SUBCON = '" + getPartStr("E1_SUBCON",@aWhere[2]) + "' "
		cWhere += " AND E1_VERSUB = '" + getPartStr("E1_VERSUB",@aWhere[2]) + "' "
EndCase
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Order By
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := cSql + cWhere + "ORDER BY E1_VENCREA, 1,3 "

RestArea(aArea)

Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

//-------------------------------------------
/*/{Protheus.doc} PLBRWGM
Query do Guia M้dico

@author PLS TEAM
@since  05.02.2012
/*/
//-------------------------------------------
User Function PLBRWGM()
Local aArea 	:= GetArea()
Local aPar  	:= StrToArray( paramixb[1] , '|' )
Local aWhere  	:= {}
Local cCampos 	:= "0#Mapa=RECNO,?=BAQ_DESCRI,?=BAU_NOME,?=BB8_DESLOC,?=BB8_END,?=BB8_NR_END,?=BB8_BAIRRO,?=BB8_MUN,?=BB8_EST,?=BB8_TEL"
Local cAlias  	:= "BB8"
Local cSql 	  	:= ""
Local cWhere  	:= ""
Local cFieldJ	:= PLSConSQL("BAQ_DESCRI+BAU_NOME")
Local nI		:= 1
Local nRegPagina:= 7
Local cCodEsp 	:= ""
Local cCodEst 	:= ""
Local cCodMun 	:= ""
Local cBairro 	:= ""
Local cCodPla	:= ""
Local cCodInt	:= plsintpad()
Local lPlGMPla	:= GetNewPar("MV_PLGMPLA",'0') == '1'
Local lAllRed	:= .t.

For nI:=1 To Len(aPar)
	aWhere := StrToArray( aPar[nI] , '=' )

	Do Case
		Case aWhere[1] == 'Field_CODPLA' .And. Len(aWhere)>1
			cCodPla := aWhere[2]
		Case aWhere[1] == 'Field_CODESP' .And. Len(aWhere)>1
			cCodEsp := aWhere[2]
		Case aWhere[1] == 'Field_CODEST' .And. Len(aWhere)>1
			cCodEst := aWhere[2]
		Case aWhere[1] == 'Field_CODMUN' .And. Len(aWhere)>1
			cCodMun := aWhere[2]
		Case aWhere[1] == 'Field_BAIRRO' .And. Len(aWhere)>1
			cBairro := aWhere[2]
	EndCase

Next

if lPlGMPla
	BI3->(dbsetorder(1))// BI3_FILIAL, BI3_CODINT, BI3_CODIGO
	if BI3->(msseek(xfilial("BI3")+cCodInt+cCodPla)) .and. BI3->BI3_ALLRED == '0'		 
		lAllRed := .f.		
	endif
endif

cSql := " SELECT BAQ_DESCRI,BAU_NOME,BB8_DESLOC,BB8_END,BB8_NR_END,BB8_BAIRRO,BB8_MUN,BB8_EST,BB8_TEL," + RetSQLName("BB8") + ".R_E_C_N_O_ RECNO "
// BAX
cWhere += " FROM " + RetSQLName("BAX")
cWhere += " INNER JOIN " + RetSQLName("BAU") + " ON BAU_FILIAL = BAX_FILIAL "
cWhere += " 	AND BAU_CODIGO = BAX_CODIGO "
cWhere += " 	AND " + RetSQLName("BAU") + " .D_E_L_E_T_ = ' ' "

//BI3
cWhere += " INNER JOIN " + RetSQLName("BI3") + " ON BI3_FILIAL = BAX_FILIAL "
cWhere += " 	AND BI3_CODINT = BAX_CODINT "
cWhere += " 	AND BI3_CODIGO = '" + cCodPla + "' "
cWhere += " 	AND " + RetSQLName("BI3") + " .D_E_L_E_T_ = ' ' "

//BB8
cWhere += " INNER JOIN " + RetSQLName("BB8") + " ON BB8_FILIAL = BAX_FILIAL "
cWhere += " 	AND BB8_CODIGO = BAX_CODIGO "
cWhere += " 	AND BB8_CODINT = BAX_CODINT "
cWhere += " 	AND BB8_CODLOC = BAX_CODLOC "
cWhere += " 	AND BB8_EST = '" + cCodEst + "' "
cWhere += " 	AND BB8_CODMUN = '" + cCodMun + "' "
cWhere += " 	AND BB8_GUIMED = '1' "

If !Empty(cBairro)
	cWhere += " AND BB8_BAIRRO = '" + cBairro + "' "
EndIf
cWhere += " 	AND " + RetSQLName("BB8") + " .D_E_L_E_T_ = ' ' "

//BAQ
cWhere += " INNER JOIN " + RetSQLName("BAQ") + " ON BAQ_FILIAL = BAX_FILIAL "
cWhere += "    	AND BAQ_CODINT = BAX_CODINT "
cWhere += "    	AND BAQ_CODESP = BAX_CODESP "
cWhere += "		AND BAU_GUIMED = '1' "
cWhere += "    	AND BAU_CODBLO = '  ' "
cWhere += "    	AND " + RetSQLName("BAQ") + ".D_E_L_E_T_ = ' ' "

//BB6
if !lAllRed
	if lPlGMPla
		cWhere += " INNER JOIN " + RetSQLName("BB6") + " ON BB6_FILIAL = BI3_FILIAL "
	else
		cWhere += " LEFT JOIN " + RetSQLName("BB6") + " ON BB6_FILIAL = BI3_FILIAL "
	endif
	cWhere += " 	AND BB6_CODIGO = BI3_CODINT || BI3_CODIGO "
	cWhere += " 	AND BB6_VERSAO = BI3_VERSAO "
	cWhere += " 	AND " + RetSQLName("BB6") + ".D_E_L_E_T_ = ' ' "
endif 

//BBK
if lPlGMPla
	cWhere += " INNER JOIN " + RetSQLName("BBK") + " ON BBK_FILIAL = BI3_FILIAL "
else
	cWhere += " LEFT JOIN " + RetSQLName("BBK") + " ON BBK_FILIAL = BI3_FILIAL "
endif	
cWhere += " 	AND BBK_CODIGO = BAU_CODIGO "
cWhere += " 	AND BBK_CODINT = BI3_CODINT "
cWhere += " 	AND BBK_CODLOC = BAX_CODLOC "
cWhere += " 	AND BBK_CODESP = BAX_CODESP "
if !lAllRed
	cWhere += " 	AND BBK_CODRED = BB6_CODRED "
endif
cWhere += " 	AND " + RetSQLName("BBK") + ".D_E_L_E_T_ = ' ' "

//BAX
cWhere += "    WHERE BAX_FILIAL = '" + xFilial("BAX") + "' "
cWhere += "    AND BAX_CODINT = BB8_CODINT "
cWhere += "    AND BAX_CODIGO = BB8_CODIGO "
cWhere += "    AND BAX_GUIMED = '1' "

If !Empty(cCodEsp)
	cWhere += " AND BAX_CODESP = '" + cCodEsp + "' "
EndIf

cWhere += "    AND " + RetSQLName("BAX") + ".D_E_L_E_T_ = ' ' "

cSql := cSql + cWhere + " ORDER BY 2 "

RestArea(aArea)

Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณPLBRWMOV  ณ Autor ณ Totvs					ณ Data ณ 05/02/12 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Relacao de Movimentacao									  ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWMOV()
LOCAL aArea 	:= GetArea()
LOCAL aPar  	:= StrToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
LOCAL cAlias  	:= "XXX"
LOCAL cCampos 	:= "?=XXX_NOMUSR,?=XXX_TIPUSU,?=XXX_SEXO,?=XXX_CPFUSR,?=XXX_MATEMP,?=XXX_SALARI,?=XXX_TELEFO,?=XXX_STATUS,?=XXX_OPERAC"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL nI		:= 1
LOCAL nRegPagina:= 7
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Rede de atendimento dos bairros x cidades x estados x planos x especialidades
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT XXX_NOMUSR,XXX_TIPUSU,XXX_SEXO,XXX_CPFUSR,XXX_MATEMP,XXX_SALARI,XXX_TELEFO,XXX_STATUS,XXX_OPERAC,R_E_C_N_O_ RECNO "
cSql += "   FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where - necessario para utilizacao no contador
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "  WHERE XXX_FILIAL = '" + xFilial(cAlias) + "' "
cWhere += "    AND D_E_L_E_T_ = ' ' "
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Parametros
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
For nI:=1 To Len(aPar)

	aWhere := StrToArray( aPar[nI] , '=' )

	Do Case
		Case aWhere[1] == 'Field_NUMCON' .And. Len(aWhere)>1
			If !Empty(aWhere[2])
				cWhere += " AND XXX_NUMCOM = '" + aWhere[2] + "' "
			EndIf
		Case aWhere[1] == 'Field_SUBCON' .And. Len(aWhere)>1
			If !Empty(aWhere[2])
				cWhere += " AND XXX_SUBCOM = '" + aWhere[2] + "' "
			EndIf
		Case aWhere[1] == 'Field_DTDE' .And. Len(aWhere)>1
			If !Empty(aWhere[2])
				cWhere += " AND Field_DATMOV >= '" + aWhere[2] + "' "
			EndIf
		Case aWhere[1] == 'Field_DTATE' .And. Len(aWhere)>1
			If !Empty(aWhere[2])
				cWhere += " AND Field_DATMOV <= '" + aWhere[2] + "' "
			EndIf
		Case aWhere[1] == 'Field_OPERAC' .And. Len(aWhere)>1
			If !Empty(aWhere[2])
				cWhere += " AND Field_OPERAC = '" + aWhere[2] + "' "
			EndIf
		Case aWhere[1] == 'Field_SITUAC' .And. Len(aWhere)>1
			If !Empty(aWhere[2])
				cWhere += " AND Field_STATUS = '" + aWhere[2] + "' "
			EndIf
	EndCase

Next
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Order By
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := cSql + cWhere + " ORDER BY 1 "

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )


/*/{Protheus.doc} PLBRWBD5	
Processa busca de GUIAS BD5 pelo periodo e tipo de guia.
@obs Para criacao de botoes no browse use a sintaxe 1#=fied ou 1#Titulo=field o numero e a ligacao com a funcao a ser executada (inicia sempre de zero)
@version P12
@since 20/02/12
/*/
//-------------------------------------------------------------------
user Function PLBRWBD5()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 2000
Local aPar  	:= strToArray( paramixb[1] , '|' )
Local lResInt	:= Iif(aScan(aPar, "Field_TIPGUI=05") >0, .T., .F.)
Local cAlias  	:= Iif(!lResInt, "BD5", "BE4")
LOCAL cCampos 	:= ""
LOCAL cSql 	  	:= " SELECT "
LOCAL cSql2		:= " "
LOCAL cSql3		:= " "
LOCAL cFieldJ		:= " "
LOCAL cWhere  	:= ""
LOCAL aWhere  	:= {}
LOCAL cPesquisa	:= ""
Local cCodLdpOff	:= PLSRETLDP(4)
LOCAL cOrder 		:= "2 "
Local lChaptc		:= Iif(aScan(aPar, "Func=PPLCHAPTC") >0, .T., .F.)

if !lResInt
	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cSql3 += " BD5_CODLDP, BD5_DATPRO, BD5_SENHA, BD5_OPEMOV||'.'||BD5_ANOAUT||'.'||BD5_MESAUT||'.'||BD5_NUMAUT BD5_NUMAUT, BD5_NOMUSR, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO, BD5_SITUAC, BD5_CODPEG, BD5_FILIAL "
	Else
		cSql3 += " BD5_CODLDP, BD5_DATPRO, BD5_SENHA, BD5_OPEMOV+'.'+BD5_ANOAUT+'.'+BD5_MESAUT+'.'+BD5_NUMAUT BD5_NUMAUT, BD5_NOMUSR, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO, BD5_SITUAC, BD5_CODPEG, BD5_FILIAL "
	EndIf
	cCampos	:= " Origem Guia=BD5_CODLDP, ?=BD5_DATPRO, ?=BD5_SENHA, ?=BD5_NUMAUT, ?=BD5_NOMUSR, ?=BD5_SITUAC"
else
	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cSql3 += " BE4_CODLDP, BE4_DATPRO, BE4_SENHA, BE4_CODOPE||'.'||BE4_ANOINT||'.'||BE4_MESINT||'.'||BE4_NUMINT BE4_NUMAUT, BE4_NOMUSR, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO, BE4_SITUAC, BE4_CODPEG, BE4_FILIAL "	
	Else
		cSql3 += " BE4_CODLDP, BE4_DATPRO, BE4_SENHA, BE4_CODOPE+'.'+BE4_ANOINT+'.'+BE4_MESINT+'.'+BE4_NUMINT BE4_NUMAUT, BE4_NOMUSR, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO, BE4_SITUAC, BE4_CODPEG, BE4_FILIAL "
	EndIf
	cCampos := " Origem Guia=BE4_CODLDP, ?=BE4_DATPRO, ?=BE4_SENHA, N๚mero da Autoriza็ใo=BE4_NUMAUT, ?=BE4_NOMUSR, ?=BE4_SITUAC"
endif

If ExistBlock("PLBRWORD")
	cOrder := ExecBlock("PLBRWORD",.F.,.F.,{cSql3})	//	Retorna a Order do GRID
Endif

//Where
cSql3 += "	 FROM " + RetSQLName(cAlias)
cWhere += "	 WHERE " + cAlias+ "_FILIAL = '" + xFilial(cAlias) + "' "
for nI:=1 to len(aPar)
	aWhere := strToArray( aPar[nI] , '=' )
	do case

		//veio da consulta de peg definitivo
		case aWhere[1] == 'Field_RECNO' .and. len(aWhere)>1
			cPesquisa := ""
			cSql2	  := ""
			nRegPagina:= 10

			//posiciona na bci e pega os parametros para selecao das guias
			BCI->( dbGoTo(val(aWhere[2])) )
			if !BCI->(eof())
				cWhere += " AND " + cAlias+ "_CODOPE = '" + BCI->BCI_CODOPE + "' "
				cWhere += " AND " + cAlias+ "_CODLDP = '" + BCI->BCI_CODLDP + "' "
				cWhere += " AND " + cAlias+ "_CODPEG = '" + BCI->BCI_CODPEG + "' "
			endIf

		//parametros quando vem da sele็ใo para geracao de peg definitivo
		case aWhere[1] == 'Field_CODRDA' .and. len(aWhere)>1
			cWhere += " AND " + cAlias+ "_CODOPE = '" + PLSINTPAD() + "' "
			cWhere += " AND " + cAlias+ "_CODLDP IN ('" + If(PLSOBRPRDA(aWhere[2]),PLSRETLDP(9),GetNewPar("MV_PLSPEGE","0000")) + "', '" + cCodLdpOff + "') "
			cWhere += " AND " + cAlias+ "_CODRDA = '" + aWhere[2] + "' "
		case aWhere[1] == 'Field_DTDE' .and. len(aWhere)>1
			cWhere += " AND " + cAlias+ "_DATPRO >= '" + dtos(ctod(aWhere[2])) + "' "
		case aWhere[1] == 'Field_DTATE' .and. len(aWhere)>1
			cWhere += " AND " + cAlias+ "_DATPRO <= '" + dtos(ctod(aWhere[2])) + "' "
		case aWhere[1] == 'Field_TIPGUI' .and. len(aWhere)>1
			cWhere += " AND " + cAlias+ "_TIPGUI = '" + aWhere[2] + "' "
	endCase

next

cWhere += " AND " + Iif(!lResInt, cAlias+ "_LIBERA <> '1' AND ", "") + cAlias+ "_SITUAC ='1' "

If lChaptc //quando for pra gerar protocolo, filtra a fase igual Pronta
	cWhere += " AND " + cAlias + "_FASE = '3' "
EndIf
cWhere += " AND "+RetSQLName(cAlias)+".D_E_L_E_T_ = ' ' "

//Fแbio Consentino - Customizado - 11/01/16
If ExistBlock("BRWFILPRO")
	aRet := ExecBlock("BRWFILPRO",.F.,.F.,{cAlias,aPar,cSql,cWhere,cCampos,cFieldJ})
	If ValType(aRet) == "A"
		cSql := aRet[1]
		cWhere := aRet[2]
		cCampos := aRet[3]
		cFieldJ := aRet[4]
	EndIf
EndIf

//Order By
cSql += cSql2 + cSql3 + cWhere + " ORDER BY " + cOrder
cSQL := PLSAvaSQL(cSQL)
RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ,cPesquisa} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBCI  บAutor  ณTotvs               บ Data ณ  20/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de GUIAS BCI pelo periodo e tipo de guia	  บฑฑ
ฑฑบ		     ณPara criacao de botoes no browse use a sintaxe 1#=fied ou   บฑฑ
ฑฑบ		     ณ 1#Titulo=field o numero e a ligacao com a funcao a ser     บฑฑ
ฑฑบ		     ณ executada (inicia sempre de zero)					  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWBCI()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 30
LOCAL cAlias  	:= "BCI"
LOCAL cCampos 	:= "0#Imp=RECNO,1#Cancelar=RECNO,2#Guias=RECNO,?=BCI_DTDIGI,?=BCI_CODPEG,?=BCI_QTDEVE,?=BCI_QTDDIG"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
LOCAL lVlrApr		:= .F.
local lStaTiSS	:= getNewPar("MV_STATISS",.F.)

BA0->(dbSetOrder(1))
if BA0->( msSeek( xFilial("BA0") + plsIntPad() ) )

	If ValType(BA0->BA0_VLRAPR) == "C" 
		lVlrApr := ( BA0->BA0_VLRAPR == '1' )
	else
		lVlrApr := BA0->BA0_VLRAPR
	EndIf
	cCampos += iif(lVlrApr, ",?=BCI_VALORI", ",?=BCI_VLRGUI")
endIf

if lStaTiSS
	cCampos += ",?=BCI_STTISS"
endIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT BCI_DTDIGI,BCI_CODPEG,BCI_QTDEVE,BCI_QTDDIG,BCI_VLRGUI, "
cSql += iif(lStaTiSS, "BCI_STTISS, " , "")
cSql += iif(lVlrApr, "BCI_VALORI, " , "BCI_VLRGUI, ")

If AllTrim(TCGetDB()) $ "ORACLE/DB2"	
	cSql += "  TO_CHAR(R_E_C_N_O_) RECNO "
ElseIf AllTrim(TCGetDB()) $ "POSTGRES"
	cSql += "  TO_CHAR(R_E_C_N_O_,'FM99999999') RECNO "
Else	
	cSql += "  CONVERT ( VARCHAR,R_E_C_N_O_ ) RECNO "
EndIf

cSql += "	 FROM " + RetSQLName(cAlias)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE BCI_FILIAL = '" + xFilial(cAlias) + "' "
cWhere += "    AND BCI_CODOPE = '" + PLSINTPAD() + "' "
cWhere += "    AND BCI_CODLDP = '" + PLSRETLDP(1) + "' "
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	do case
		case aWhere[1] == 'MOSGUI' .and. len(aWhere)>1
			if aWhere[2] == "0"
				cCampos := "0#Imp=RECNO,1#Cancelar=RECNO,?=BCI_DTDIGI,?=BCI_CODPEG,?=BCI_QTDEVE,?=BCI_QTDDIG,?=BCI_VLRGUI"
			endIf
		case aWhere[1] == 'Field_CODRDA' .and. len(aWhere)>1
			cWhere += " AND BCI_CODRDA = '" + aWhere[2] + "' "

		case aWhere[1] == 'Field_TIPGUI' .and. len(aWhere)>1
			cWhere += " AND BCI_TIPGUI = '" + aWhere[2] + "' "

		case aWhere[1] == 'Field_DTDE' .and. len(aWhere)>1
			cWhere += " AND BCI_DTDIGI >= '" + dtos(ctod(aWhere[2])) + "' "

		case aWhere[1] == 'Field_DTATE' .and. len(aWhere)>1
			cWhere += " AND BCI_DTDIGI <= '" + dtos(ctod(aWhere[2])) + "' "
	endCase

next
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Order By
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If BCI->(FieldPos("BCI_ORIGEM")) > 0
	cWhere += " AND BCI_ORIGEM = '1' "
Endif
cWhere += "    AND D_E_L_E_T_ = ' ' "

//Fแbio Consentino - Customizado - 11/01/16
If ExistBlock("BRWFILPRO")
	aRet := ExecBlock("BRWFILPRO",.F.,.F.,{cAlias,aPar,cSql,cWhere,cCampos,cFieldJ})
	If ValType(aRet) == "A"
		cSql := aRet[1]
		cWhere := aRet[2]
		cCampos := aRet[3]
		cFieldJ := aRet[4]
	EndIf
EndIf

//ADICIONADA ESSA CONDIวรO POIS O PEG NรO PODE APARECER ATษ TERMINAR DE TRANSFERIR TODAS AS GUIAS, PARA ISSO ESSE CAMPO FICA EM BRANCO ATษ ESSE TERMINO
if lStaTiSS
	cWhere += "    AND BCI_STTISS <> '' "	
endIf

cSql := cSql + cWhere + " ORDER BY 1 DESC"

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ,"","","","",.F.,"BCI_STTISS"} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBD6  บAutor  ณTotvs               บ Data ณ  20/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de GUIAS BCI pelo periodo e tipo de guia	  บฑฑ
ฑฑบ		     ณPara criacao de botoes no browse use a sintaxe 1#=fied ou   บฑฑ
ฑฑบ		     ณ 1#Titulo=field o numero e a ligacao com a funcao a ser     บฑฑ
ฑฑบ		     ณ executada (inicia sempre de zero)					  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWBD6()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 20
LOCAL cAlias  	:= "BD6"
LOCAL cCampos 	:= "?=BD6_SITRG,?=BD6_ANOPAG,?=BD6_MESPAG,?=BD6_NUMERO,?=BD6_CODPEG,?=BD6_CODPAD,?=BD6_CODPRO,?=BD6_DESPRO,?=BD6_QTDSOL,?=BD6_VLRAPR,?=BD6_VLRGLO,0#Adicionar=RECNO,1#Visualizar=RECNO"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
LOCAL lProt		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT BD6_SITRG, BD6_DESPRO,BD6_ANOPAG,BD6_MESPAG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_CODPAD,BD6_CODPRO,BD6_QTDSOL,BD6_VLRAPR,BD6_VLRGLO,R_E_C_N_O_ RECNO "
cSql += "	 FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE BD6_FILIAL = '" + xFilial(cAlias) + "' "
cWhere += "    AND BD6_CODOPE = '" + PLSINTPAD() + "' "
cWhere += "    AND BD6_VLRGLO > 0"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	//Field_GUIAPROT
	do case
		case aWhere[1] == 'Field_TPPESQ' .and. len(aWhere)>1
			if aWhere[2] == "1"
				lProt := .F.
			Else
				lProt := .T.
			endIf
		case aWhere[1] == 'Field_GUIAPROT' .and. len(aWhere)>1
			If lProt
				cWhere += " AND BD6_CODPEG = '" + Alltrim(aWhere[2]) + "' "
			Else
				cWhere += " AND BD6_ANOPAG = '" + Substr(Alltrim(aWhere[2]),1,4) + "' "
				cWhere += " AND BD6_MESPAG = '" + Substr(Alltrim(aWhere[2]),5,2) + "' "
				cWhere += " AND BD6_NUMERO = '" + Substr(Alltrim(aWhere[2]),7,8) + "' "
				//BD6_ANOPAG + BD6_MESPAG + BD6_NUMERO
			EndIf
		case aWhere[1] == 'Field_RDA' .and. len(aWhere)>1
			cWhere += "    AND BD6_OPERDA+BD6_CODRDA IN (" + Alltrim(aWhere[2]) + ")"
			//cWhere += "    AND BD6_CODLOC+BD6_OPERDA+BD6_CODOPE IN ('" + Alltrim(aWhere[2]) + "')"
	endCase
next

cWhere += "    AND D_E_L_E_T_ = ' ' "
cSql := cSql + cWhere
RestArea(aArea)
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBD6  บAutor  ณTotvs               บ Data ณ  20/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de GUIAS BCI pelo periodo e tipo de guia	  บฑฑ
ฑฑบ		     ณPara criacao de botoes no browse use a sintaxe 1#=fied ou   บฑฑ
ฑฑบ		     ณ 1#Titulo=field o numero e a ligacao com a funcao a ser     บฑฑ
ฑฑบ		     ณ executada (inicia sempre de zero)					  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWBVO()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 20
LOCAL cAlias  	:= "BVO"
LOCAL cCampos 	:= "?=BVO_STATUS,?=BVO_RECURS,?=BVO_DATA,?=BVO_SEQUEN,0#Detalhes=RECNO"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT BVO_STATUS,BVO_RECURS,BVO_DATA,BVO_SEQUEN,R_E_C_N_O_ RECNO "
cSql += "	 FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE BVO_FILIAL = '" + xFilial(cAlias) + "' "
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	do case
		case aWhere[1] == 'Field_CHAVEBD6' .and. len(aWhere)>1
			cWhere += " AND BVO_CODOPE = '" + Substr(Alltrim(aWhere[2]),1,4) + "' "
			cWhere += " AND BVO_CODLDP = '" + Substr(Alltrim(aWhere[2]),5,4) + "' "
			cWhere += " AND BVO_CODPEG = '" + Substr(Alltrim(aWhere[2]),9,8) + "' "
			cWhere += " AND BVO_NUMERO = '" + Substr(Alltrim(aWhere[2]),17,8) + "' "
			cWhere += " AND BVO_ORIMOV = '" + Substr(Alltrim(aWhere[2]),25,1) + "' "
			cWhere += " AND BVO_SEQUEN = '" + Substr(Alltrim(aWhere[2]),26,3) + "' "
			cWhere += " AND BVO_CODPAD = '" + Substr(Alltrim(aWhere[2]),29,2) + "' "
			cWhere += " AND BVO_CODPRO = '" + Substr(Alltrim(aWhere[2]),31,16) + "' "

	endCase
next

cWhere += "    AND D_E_L_E_T_ = ' ' "
cSql := cSql + cWhere
RestArea(aArea)
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBD6  บAutor  ณTotvs               บ Data ณ  20/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de GUIAS BCI pelo periodo e tipo de guia	  บฑฑ
ฑฑบ		     ณPara criacao de botoes no browse use a sintaxe 1#=fied ou   บฑฑ
ฑฑบ		     ณ 1#Titulo=field o numero e a ligacao com a funcao a ser     บฑฑ
ฑฑบ		     ณ executada (inicia sempre de zero)					  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWBE2()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 20 // quantos por paginas
LOCAL cCampos 	:= "Sequencial=SEQUEN,Tabela de Eventos=CODPAD,C๓d. Evento=CODPRO,Descri็ใo Evento=DESPRO,Quantidade=QTDPRO,Status=STATUS,Auditoria=AUDITO,Data Evento=DToC(SToD(DATPRO)),Hora do Evento=timeField(HORPRO)"
LOCAL cChaveGui 	:= ""
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
LOCAL cAlias 		:= ""
LOCAL cAliasPai 		:= ""
LOCAL cAliasName		:= ""
LOCAL cAliasPaiName := ""
LOCAL cOpe			:= ""
Local lBlqAne	 := GetNewPar("MV_PLBAGN",.F.)
Local cNegado    := ""

if ( AT( "Field_TPGUIA=1", paramixb[1] ) > 0  )

	cAlias := "BE2"
	cAliasPai := "BEA"
	cAliasName := RetSQLName("BE2")
	cAliasPaiName := RetSQLName("BEA")
	cChaveGui := "OPEMOV+ANOAUT+MESAUT+NUMAUT" 
	cSql := " SELECT BE2_SEQUEN SEQUEN, BE2_CODPAD CODPAD, BE2_CODPRO CODPRO, BE2_DESPRO DESPRO, BE2_QTDPRO QTDPRO, (CASE WHEN BE2_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "
	cSql += " (CASE WHEN BE2_AUDITO = '1' THEN 'Sim' ELSE 'Nใo' END) AS AUDITO,BE2_DATPRO DATPRO,BE2_HORPRO HORPRO," + cAliasName + ".R_E_C_N_O_ RECNO, "
	cSql += " BE2_OPEMOV OPEMOV, BE2_ANOAUT ANOAUT, BE2_MESAUT MESAUT, BE2_NUMAUT NUMAUT, 'BE2' CALIAS, "
	cSql += " BEA_DATPRO, BEA_HORPRO, (CASE WHEN BE2_STATUS = '0' AND BE2_AUDITO = '0' THEN '1' ELSE '0' END) NEGADO "
	cSql += "	 FROM " +  cAliasName
	cWhere += "	 INNER JOIN " + cAliasPaiName

	cWhere += " ON( BE2_OPEMOV = BEA_OPEMOV"
	cWhere += " AND BE2_ANOAUT = BEA_ANOAUT"
	cWhere += " AND BE2_MESAUT = BEA_MESAUT"
	cWhere += " AND BE2_NUMAUT = BEA_NUMAUT )"

	cWhere += "	 WHERE BE2_FILIAL = '" + xFilial(cAlias) + "' "

elseif ( AT( "Field_TPGUIA=2", paramixb[1] ) > 0  )

	cAlias := "BEJ"
	cAliasPai := "BE4"
	cAliasName := RetSQLName("BEJ")
	cAliasPaiName := RetSQLName("BE4")
	cChaveGui := "OPEMOV+ANOAUT+MESAUT+NUMAUT" //BE4_DTDIGI+BE4_HHDIGI 
	cSql := " SELECT BEJ_SEQUEN SEQUEN, BEJ_CODPAD CODPAD, BEJ_CODPRO CODPRO, BEJ_DESPRO DESPRO, BEJ_QTDPRO QTDPRO, (CASE WHEN BEJ_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "
	cSql += " (CASE WHEN BEJ_AUDITO = '1' THEN 'Sim' ELSE 'Nใo' END) AS AUDITO,BEJ_DATPRO DATPRO,'' HORPRO," + cAliasName + ".R_E_C_N_O_ RECNO, "
	cSql += " BEJ_CODOPE OPEMOV, BEJ_ANOINT ANOAUT, BEJ_MESINT MESAUT, BEJ_NUMINT NUMAUT, 'BEJ' CALIAS, "
	cSql += " BE4_DATPRO, BE4_HORPRO, BE4_DTDIGI, BE4_HHDIGI, BEA_DATPRO, BEA_HORPRO, (CASE WHEN BEJ_STATUS = '0' AND BEJ_AUDITO = '0' THEN '1' ELSE '0' END) NEGADO "
	cSql += "	 FROM " +  cAliasName
	cWhere += " INNER JOIN " + cAliasPaiName

 	cWhere += " ON( BEJ_CODOPE = BE4_CODOPE"
	cWhere += " AND BEJ_ANOINT = BE4_ANOINT"
	cWhere += " AND BEJ_MESINT = BE4_MESINT"
	cWhere += " AND BEJ_NUMINT = BE4_NUMINT )"

	cWhere += " INNER JOIN " + RetSQLName("BEA")

	cWhere += " ON( BEJ_CODOPE = BEA_OPEMOV"
	cWhere += " AND BEJ_ANOINT = BEA_ANOAUT"
	cWhere += " AND BEJ_MESINT = BEA_MESAUT"
	cWhere += " AND BEJ_NUMINT = BEA_NUMAUT )"

	cWhere += " WHERE BEJ_FILIAL = '" + xFilial(cAlias) + "' "

elseif ( AT( "Field_TPGUIA=3", paramixb[1] ) > 0  )

	cAlias := "BQV"
	cAliasPai := "B4Q"
	cAliasName := RetSQLName("BQV")
	cAliasPaiName := RetSQLName("B4Q")
	cChaveGui := "OPEMOV+ANOAUT+MESAUT+NUMAUT"
	cSql := " SELECT BQV_SEQUEN SEQUEN, BQV_CODPAD CODPAD, BQV_CODPRO CODPRO, BQV_DESPRO DESPRO, BQV_QTDPRO QTDPRO, (CASE WHEN BQV_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "
	cSql += " (CASE WHEN BQV_AUDITO = '1' THEN 'Sim' ELSE 'Nใo' END) AS AUDITO, BQV_DATPRO DATPRO,BQV_HORPRO HORPRO," + cAliasName + ".R_E_C_N_O_ RECNO, "
	cSql += " BQV_CODOPE OPEMOV, BQV_ANOINT ANOAUT, BQV_MESINT MESAUT, BQV_NUMINT NUMAUT, 'BQV' CALIAS , (CASE WHEN BQV_STATUS = '0' AND BQV_AUDITO = '0' THEN '1' ELSE '0' END) NEGADO "
	cSql += "	 FROM " +  cAliasName
	cWhere += "	 INNER JOIN " + cAliasPaiName

	cWhere += " ON( BQV_CODOPE = B4Q_OPEMOV"
	cWhere += " AND BQV_ANOINT = B4Q_ANOAUT"
	cWhere += " AND BQV_MESINT = B4Q_MESAUT"
	cWhere += " AND BQV_NUMINT = B4Q_NUMAUT )"

	cWhere += " WHERE BQV_FILIAL = '" + xFilial(cAlias) + "' "

elseif ( AT( "Field_TPGUIA=4", paramixb[1] ) > 0  )

	cAlias := "B4C"
	cAliasPai := "B4A"
	cAliasName := RetSQLName("B4C")
	cAliasPaiName := RetSQLName("B4A")
	cChaveGui := "OPEMOV+ANOAUT+MESAUT+NUMAUT"
	cSql := " SELECT B4C_SEQUEN SEQUEN, B4C_CODPAD CODPAD, B4C_CODPRO CODPRO, B4C_DESPRO DESPRO, B4C_QTDPRO QTDPRO, (CASE WHEN B4C_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "
	cSql += " (CASE WHEN B4C_AUDITO = '1' THEN 'Sim' ELSE 'Nใo' END) AS AUDITO, B4C_DATPRO DATPRO, '' HORPRO," + cAliasName + ".R_E_C_N_O_ RECNO, "
	cSql += " B4C_OPEMOV OPEMOV, B4C_ANOAUT ANOAUT, B4C_MESAUT MESAUT, B4C_NUMAUT NUMAUT, 'B4C' CALIAS, (CASE WHEN B4C_STATUS = '0' AND B4C_AUDITO = '0' THEN '1' ELSE '0' END) NEGADO "
	cSql += "	 FROM " +  cAliasName
	cWhere += "	 INNER JOIN " + cAliasPaiName

	cWhere += " ON( B4C_OPEMOV = B4A_OPEMOV"
	cWhere += " AND B4C_ANOAUT = B4A_ANOAUT"
	cWhere += " AND B4C_MESAUT = B4A_MESAUT"
	cWhere += " AND B4C_NUMAUT = B4A_NUMAUT )"

	cWhere += " WHERE B4C_FILIAL = '" + xFilial(cAlias) + "' "

endIf

for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	do case
		case aWhere[1] == 'Field_NUMGUIA' .and. len(aWhere)>1

			aWhere[2] := Alltrim(StrTran(StrTran(aWhere[2],".",""),"-",""))

			if(cAlias == "BEJ" .or. cAlias == "BQV")

				cOpe := "_CODOPE"

				if cAliasPai == "B4Q"
					cOpe := "_OPEMOV"
				endIf

				cWhere += " AND " + cAlias + "_CODOPE = '" + Substr(Alltrim(aWhere[2]),1,4)   + "' "
				cWhere += " AND " + cAlias + "_ANOINT = '" + Substr(Alltrim(aWhere[2]),5,4)   + "' "
				cWhere += " AND " + cAlias + "_MESINT = '" + Substr(Alltrim(aWhere[2]),9,2)   + "' "
				cWhere += " AND " + cAlias + "_NUMINT = '" + Substr(Alltrim(aWhere[2]),11,8)  + "' "
			else
				cOpe := "_OPEMOV"
				cWhere += " AND " + cAlias + "_OPEMOV = '" + Substr(Alltrim(aWhere[2]),1,4) + "' "
				cWhere += " AND " + cAlias + "_ANOAUT = '" + Substr(Alltrim(aWhere[2]),5,4) + "' "
				cWhere += " AND " + cAlias + "_MESAUT = '" + Substr(Alltrim(aWhere[2]),9,2) + "' "
				cWhere += " AND " + cAlias + "_NUMAUT = '" + Substr(Alltrim(aWhere[2]),11,8) + "' "
				if(cAlias == "BE2")
					cWhere += " AND " + cAlias + "_TIPO <> '3' AND  " + cAlias + "_TIPGUI <> '11' " 
				endIf
			endif

		Case aWhere[1] == 'Field_RDA' .and. len(aWhere)>1
			if cAliasPai <> "B4A"
				If !(AllTrim(TCGetDB()) $ "ORACLE|POSTGRES")
					cWhere += "    AND " + cAliasPai + cOpe + " + " + cAliasPai + "_CODRDA IN (" + Alltrim(aWhere[2]) + ")"
				Else
					cWhere += "    AND " + cAliasPai + cOpe + " || " + cAliasPai + "_CODRDA IN (" + Alltrim(aWhere[2]) + ")"
				EndIf
			endIf
	endCase

next

cWhere += "    AND " + cAliasName + ".D_E_L_E_T_ = ' ' "
cWhere += "    AND " + cAliasPaiName + ".D_E_L_E_T_ = ' ' "

If lBlqAne
	cNegado += "+CHR(126)+NEGADO"
EndIf

cCampos := "0*#Anexar=OPEMOV+ANOAUT+MESAUT+NUMAUT+SEQUEN+CHR(126)+STR(RECNO)+CHR(126)+CALIAS+CHR(126)+"+cChaveGui+cNegado+","+cCampos

cSql := cSql + cWhere
RestArea(aArea)
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBR8  บAutor Thiago Guilherme ณTotvsบ Data ณ  23/01/2014บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o procedimento pesquisado na rotina de car๊ncias no	 บฑฑ
				Portal.							    						  	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWBR8()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 9999
LOCAL cAlias  	:= "BR8"
LOCAL cCampos 	:= "Codigo=BR8_CODPSA,Descri็ใo=BR8_DESCRI,0#Car๊ncia Proc.=R_E_C_N_O_"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT BR8_CODPSA,BR8_DESCRI,R_E_C_N_O_"
cSql += "	 FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE BR8_FILIAL = '" + xFilial(cAlias) + "' "
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	do case
		case aWhere[1] == 'Field_TPPSQ' .and. len(aWhere)>1

			If "'" $ APAR[2]
				APAR[2] := "CaracterInvalido"
			EndIf

			If !EMPTY(SUBSTR(APAR[2],12))

				If SUBSTR(APAR[1],13) == "Codigo"
					cWhere += " AND BR8_CODPSA LIKE '%" + AllTrim(SUBSTR(APAR[2],12)) + "%' "

				ElseIf SUBSTR(APAR[1],13) == "Descricao"
					cWhere += " AND BR8_DESCRI LIKE '%" + UPPER(SUBSTR(APAR[2],12)) + "%' "

				EndIf
			EndIf
	endCase
next

cWhere += " AND BR8_CARPRT = '1'"
cWhere += "    AND D_E_L_E_T_ = ' ' "
cSql := cSql + cWhere

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBE4  บAutor Thiago Guilherme ณTotvsบ Data ณ  13/03/2014บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os beneficiแrios com interna็ใo em aberto das RDAs	 บฑฑ
				cadastradas no mesmo login do portal do prestador		  	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWBE4()
LOCAL aArea 		:= getArea()
LOCAL nI			:= 0
LOCAL nRegPagina	:= 9999
LOCAL cAlias  	:= "BE4"
LOCAL cCampos 	:= "Matrํcula=MATRIC ,Nome=BE4_NOMUSR, 0#Matric.=R_E_C_N_O_"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ		:= ""
LOCAL aPar  		:= strToArray( paramixb[1] , '|' )
LOCAL cCodRda 	:= SUBSTR(aPar[3],11)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If AllTrim( TCGetDB() ) $ "ORACLE/POSTGRES"
	cSql := " SELECT BE4_NOMUSR, BE4_CODOPE || BE4_CODEMP || BE4_MATRIC || BE4_TIPREG || BE4_DIGITO MATRIC, R_E_C_N_O_"
Else
	cSql := " SELECT BE4_NOMUSR, BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO MATRIC, R_E_C_N_O_"
EndIf

cSql += " FROM " + RetSQLName(cAlias)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += " WHERE BE4_FILIAL = '" + xFilial(cAlias) + "' "

If AllTrim( TCGetDB() ) $ "ORACLE/POSTGRES"
	cWhere += " AND BE4_CODOPE || BE4_CODRDA IN(" + cCodRda + ")"
	cWhere += " AND BE4_DATPRO <> ''"
Else
	cWhere += " AND BE4_CODOPE + BE4_CODRDA IN(" + cCodRda + ")"
	cWhere += " AND BE4_DATPRO <> ''"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	do case
		case aWhere[1] == 'Field_TPPSQ' .and. len(aWhere)>1

			If "'" $ APAR[2]
				APAR[2] := "CaracterInvalido"
			EndIf

			If !EMPTY(SUBSTR(APAR[2],12))

				If SUBSTR(APAR[1],13) == "Matric"

					If AllTrim( TCGetDB() ) $ "ORACLE/POSTGRES"
						cWhere += " AND BE4_CODOPE || BE4_CODEMP || BE4_MATRIC || BE4_TIPREG || BE4_DIGITO LIKE '%" + AllTrim(SUBSTR(APAR[2],12)) + "%' "
					Else
						cWhere += " AND BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO LIKE '%" + AllTrim(SUBSTR(APAR[2],12)) + "%' "
					EndIf
				ElseIf SUBSTR(APAR[1],13) == "Nome"

					cWhere += " AND BE4_NOMUSR LIKE '%" + UPPER(SUBSTR(APAR[2],12)) + "%' "
				EndIf
			EndIf
	endCase
next

cWhere += " AND BE4_DTALTA = ''"
cWhere += " AND D_E_L_E_T_ = ' ' "

cWhere += " OR "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Verifica a condi็ใo de incluir data de alta com datas posteriores a data atual
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += " BE4_FILIAL = '" + xFilial(cAlias) + "' "

If AllTrim( TCGetDB() ) $ "ORACLE/POSTGRES"
	cWhere += " AND BE4_CODOPE || BE4_CODRDA IN(" + cCodRda + ")"
	cWhere += " AND BE4_DATPRO <> ''"
Else
	cWhere += " AND BE4_CODOPE + BE4_CODRDA IN(" + cCodRda + ")"
	cWhere += " AND BE4_DATPRO <> ''"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	do case
		case aWhere[1] == 'Field_TPPSQ' .and. len(aWhere)>1

			If "'" $ APAR[2]
				APAR[2] := "CaracterInvalido"
			EndIf

			If !EMPTY(SUBSTR(APAR[2],12))

				If SUBSTR(APAR[1],13) == "Matric"

					If AllTrim( TCGetDB() ) $ "ORACLE/POSTGRES"
						cWhere += " AND BE4_CODOPE || BE4_CODEMP || BE4_MATRIC || BE4_TIPREG || BE4_DIGITO LIKE '%" + AllTrim(SUBSTR(APAR[2],12)) + "%' "
					Else
						cWhere += " AND BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO LIKE '%" + AllTrim(SUBSTR(APAR[2],12)) + "%' "
					EndIf

				ElseIf SUBSTR(APAR[1],13) == "Nome"

					cWhere += " AND BE4_NOMUSR LIKE '%" + UPPER(SUBSTR(APAR[2],12)) + "%' "
				EndIf
			EndIf
	endCase
next

cWhere += " AND BE4_DTALTA > '" + DTOS(dDataBase) + "'"
cWhere += " AND D_E_L_E_T_ = ' ' "
cSql := cSql + cWhere

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB4D  บAutor  ณTotvs               บ Data ณ  20/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca glosas e recursos na tabela B4D (TISS 3.0)		    	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWB4D()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 20
LOCAL cAlias  	:= "B4D"
LOCAL cCampos 	:= "0#Adicionar=RECNO,?=B4D_STATUS,?=B4D_OBJREC,?=B4D_ANOAUT,?=B4D_MESAUT,?=B4D_NUMAUT,Protocolo=B4D_CODPEG,Beneficiแrio=B4D_NOMUSR,?=B4D_VLRGLO,?=B4D_DATREC,?=B4D_TOTREC,?=B4D_TOTACA,?=B4D_GLOPRT,?=B4D_GLOGUI,2#Exibe Itens=RECNO,3#Hist. Recurso=RECNO,4#Canc. Recurso=RECNO, 5#Anexa Arquivo=RECNO, 6#Imprimir=RECNO"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cWhrRDAPad	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
LOCAL lProt		:= .F.
Local lRda		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := "SELECT B4D_STATUS, B4D_OBJREC, B4D_ANOAUT, B4D_MESAUT, B4D_NUMAUT, B4D_CODPEG, B4D_VLRGLO, B4D_DATREC, B4D_TOTREC, B4D_TOTACA, B4D_GLOPRT, B4D_GLOGUI, B4D_SEQB4D, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO, B4D_NOMUSR"
cSql += "	 FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE B4D_FILIAL = '" + xFilial(cAlias) + "' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	//Field_GUIAPROT
	do case
		case aWhere[1] == 'Field_TPPESQ' .and. len(aWhere)>1
			if aWhere[2] == "1"
				lProt := .F.
			Else
				lProt := .T.
			endIf
		case aWhere[1] == 'Field_GUIAPROT' .and. len(aWhere)>1
			If lProt
				cWhere += " AND B4D_CODPEG = '" + Alltrim(aWhere[2]) + "' "
			Else
				cWhere += " AND B4D_ANOAUT = '" + Substr(Alltrim(aWhere[2]),1,4) + "' "
				cWhere += " AND B4D_MESAUT = '" + Substr(Alltrim(aWhere[2]),5,2) + "' "
				cWhere += " AND B4D_NUMAUT = '" + Substr(Alltrim(aWhere[2]),7,8) + "' "
			EndIf
		case aWhere[1] == 'Field_RDAFIL' .and. len(aWhere)>1
			lRda := .T.
			cWhere += "    AND B4D_CODRDA = '" + Alltrim(aWhere[2]) + "'"
		case aWhere[1] == 'Field_RDA' .and. len(aWhere)>1
			If AllTrim(TCGetDB()) <> "ORACLE" .AND. AllTrim(TCGetDB()) <> "POSTGRES"
				cWhrRDAPad += "    AND B4D_OPEMOV+B4D_CODRDA IN (" + Alltrim(aWhere[2]) + ")"
			Else
				cWhrRDAPad += "    AND B4D_OPEMOV||B4D_CODRDA IN (" + Alltrim(aWhere[2]) + ")"
			EndIf
	endCase
	If !lRda
		cWhere += cWhrRDAPad
	EndIf
next

// obs.: nใo divulgar este ponto de entrada. Ele serแ utilizado temporariamente pela e-Vida.
if existblock("PLRETB4D") 
	cWhere += execBlock("PLRETB4D",.F.,.F.)
endIf

cWhere += " AND " + RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' "
cSql := cSql + cWhere
RestArea(aArea)
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ,"","","","",.F.,"B4D_OBJREC"} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB4E  บAutor  ณTotvs               บ Data ณ  20/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca itens de glosas e recursos na tabela B4E (TISS 3.0)	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWB4E()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 20
LOCAL cAlias  	:= "B4E"
LOCAL cCampos 	:= "?=B4E_STATUS,?=B4E_DESPRO,?=B4E_GLOTIS,?=B4E_VLRREC,?=B4E_JUSPRE,?=B4E_VLRACA,?=B4E_VLRGLO,?=B4E_SLDREC,?=B4E_JUSOPE,?=B4E_DATPRO,?=B4E_CODPRO,?=B4E_SEQUEN"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT B4E_STATUS,B4E_SEQUEN,B4E_DATPRO,B4E_DESPRO,B4E_GLOTIS,B4E_VLRREC,B4E_JUSPRE,B4E_VLRACA,B4E_VLRGLO,B4E_SLDREC,B4E_JUSOPE,B4E_CODPRO,R_E_C_N_O_ RECNO "
cSql += "	 FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE B4E_FILIAL = '" + xFilial(cAlias) + "' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)
	aWhere := strToArray( aPar[nI] , '=' )
	If aWhere[1] == 'Field_RECNO' .and. len(aWhere)>1
		B4D->( dbGoTo(val(aWhere[2])) )
		if !B4D->(eof())
			cWhere += " AND B4E_SEQB4D = '" + B4D->B4D_SEQB4D + "' AND B4E_CODPEG = '" + B4D->B4D_CODPEG + "' "
		endIf
	EndIf
next

cWhere += "    AND D_E_L_E_T_ = ' '  "
cSql := cSql + cWhere
RestArea(aArea)
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ,"","","","",.F.,""} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBVO  บAutor  ณTotvs               บ Data ณ  20/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca historico de recursos de glosa (TISS 3.0)		    	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRW3BVO()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 20
LOCAL cAlias  	:= "BVO"
LOCAL cCampos 	:= "Status Analise=BVO_STATUS,Just.Prestador=BVO_JUSRDA,Just.Operadora=BVO_JUSOPE,?=BVO_DATREC,?=BVO_HORREC,?=BVO_DATRES,?=BVO_HORRES,?=BVO_VLRREC,?=BVO_VLRACA,?=BVO_DESPRO,?=BVO_CODPRO,?=BVO_SEQUEN,?=BVO_SEQREC"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT BVO_STATUS,BVO_SEQREC,BVO_JUSRDA,BVO_JUSOPE,BVO_DATREC,BVO_HORREC,BVO_DATRES,BVO_HORRES,BVO_VLRREC,BVO_VLRACA,BVO_DESPRO,BVO_CODPRO,BVO_SEQUEN,R_E_C_N_O_ RECNO "
cSql += "	 FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE BVO_FILIAL = '" + xFilial(cAlias) + "' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)
	aWhere := strToArray( aPar[nI] , '=' )
	If aWhere[1] == 'Field_RECNO' .and. len(aWhere)>1
			B4D->( dbGoTo(val(aWhere[2])) )
			if !B4D->(eof())
				cWhere += " AND BVO_SEQB4D = '" + B4D->B4D_SEQB4D + "' AND BVO_CODPEG = '" + B4D->B4D_CODPEG + "' "
			endIf
	EndIf
next

cWhere += "    AND D_E_L_E_T_ = ' '  "
cSql := cSql + cWhere
RestArea(aArea)
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ,"","","","",.F.,"BVO_STATUS"} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB7D  บAutor Rogerio Tabosa   ณTotvsบ Data ณ  20/01/2014บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna as receitas cadastradas do beneficiario         	 บฑฑ
				       							    						  	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWB7D()
LOCAL aArea 	:= getArea()
LOCAL nRegPagina:= 30
LOCAL cAlias  	:= "B7D"
LOCAL cCampos 	:= ""
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aWhere  	:= StrToArray( paramixb[1] , '|' )
LOCAL aWhere1		:= {}
LOCAL nI:=1
LOCAL lTodas		:= .F. // Lista todas as receitas mesmo as vencidas e com quantidade insufieciente

cCampos := "C๓digo da Receita:=B7D_CODREC,Vแlida de:=B7D_DTVINI,At้:=B7D_DTFVAL,C๓d. Medicamento:=B7D_CODMED,"
cCampos += "Descri็ใo do Medicamento:=BR8_DESCRI,unid. Medida:=B7D_UNICON,Quantidade Autorizada:=B7D_QTDAUT,Quantidade Utilizada:=B7D_QTDEXE,"
cCampos += "Estado do Solicit.:=B4F_ESTSOL,Sigla:=B4F_SIGLA,N๚mero:=B4F_REGSOL,Nome:=BB0_NOME, 0*#Rastrear Protocolos:=B7D_CODREC+CHR(95)+B7D_CODMED" 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT  B7D_CODREC,B7D_DTVINI,B7D_DTFVAL,B7D_CODMED,BR8_DESCRI,B7D_UNICON,B7D_QTDAUT,B7D_QTDEXE,B4F_ESTSOL,B4F_SIGLA,B4F_REGSOL,BB0_NOME  "
cSql += " FROM " + RetSQLName(cAlias)
cSql += " INNER JOIN " + RetSQLName("B4F")
cSql += " ON B7D_CODREC = B4F_CODREC "
cSql += " AND B7D_OK = 'T'"
cSql += " INNER JOIN " + RetSQLName("BR8")
cSql += " ON BR8_CODPAD = B7D_CODPAD AND BR8_CODPSA = B7D_CODMED "
cSql += " INNER JOIN " + RetSQLName("BB0")
cSql += " ON BB0_ESTADO = B4F_ESTSOL AND BB0_CODSIG = B4F_SIGLA AND BB0_NUMCR = B4F_REGSOL AND "

cSql += RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' AND " + RetSQLName("B4F")+ ".D_E_L_E_T_ = ' ' AND " + RetSQLName("BB0")+ ".D_E_L_E_T_ = ' ' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
For nI:=1 to Len(aWhere)
	aWhere1 := StrToArray( aWhere[nI] , '=' )
	If aWhere1[1] == 'Field_BENEF'
   		cWhere += " WHERE B7D_BENEFI = '"+aWhere1[2]+"' "
	Endif
	If aWhere1[1] == 'ListaTodas'
		If aWhere1[2] == "1"
			lTodas := .T.
		EndIf
	Endif
Next

If !lTodas
	cSql += " AND B7D_DTFVAL >= '" + DTOS(dDataBase) + "' "
EndIf

cSql := cSql + cWhere
cSql += " GROUP BY B7D_CODREC,B7D_DTVINI,B7D_DTFVAL,B7D_CODMED,BR8_DESCRI,B7D_UNICON,B7D_QTDAUT,B7D_QTDEXE,B4F_ESTSOL,B4F_SIGLA,B4F_REGSOL,BB0_NOME," + RetSQLName(cAlias) + ".R_E_C_N_O_ "
cSql += " ORDER BY B7D_CODREC DESC"

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",,,,.T.} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBOW  บAutor  ณTotvs               บ Data ณ  20/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca protocolos de Reembolso						   		    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWBOW() 

LOCAL aArea 	 := getArea()
LOCAL nI		 := 0
LOCAL nRegPagina := 30 
LOCAL cAlias  	 := "BOW"
LOCAL cCampos 	 := ""
LOCAL cSql 	  	 := ""
LOCAL cWhere  	 := ""
LOCAL cFieldJ	 := ""
LOCAL aPar  	 := strToArray( paramixb[1] , '|' )
LOCAL aWhere  	 := {}
LOCAL cSqlName	 := RetSQLName(cAlias)
LOCAL lTemProtoc := .F. // Determina caso informo o protocolo nใo preciso informar as datas, pois o usuario nใo sabe qual e o mes do protocolo

if(AT( "lConfirmReemb", paramixb[1] ) ) == 0

	cCampos := "2#Despesas=RECNO,Situa็ใo=BOW_STATUS,3#Observa็ใo=RECNO,Protocolo=BOW_PROTOC,Data Solicita็ใo=BOW_DTDIGI,Total Apresentado=BOW_VLRAPR,Reembolsado=BOW_VLRREE,Data de Pagamento=BOW_PGMTO,0#Imp=BOW_PROTOC+SEP+STR(CODREC),1#Cancelar=RECNO,4#Editar=RECNO,5*#Anexar=BOW_OPEUSR+BOW_PROTOC+SEP+STR(CODREC)+SEP+BOW_STATUS,Beneficiแrio=BOW_NOMUSR"

	Do Case
		Case AllTrim(TCGetDB()) $ "ORACLE/DB2"
			cSql := "  SELECT CASE WHEN BOW_STATUS = 'A' THEN '' ELSE " + cSqlName + ".BOW_PROTOC END BOW_PROTOC, CASE  WHEN  B44.B44_STATUS  = '4'  AND BOW_STATUS ='C'  THEN 'C'   WHEN  B44.B44_STATUS  IS NULL  AND BOW_STATUS ='C'  THEN '2'  ELSE BOW_STATUS   END BOW_STATUS, " + cSqlName + ".BOW_NOMUSR," + cSqlName + ".BOW_DTDIGI, " + cSqlName + ".BOW_NOMREF, " + cSqlName + ".BOW_VLRAPR," + cSqlName + ".BOW_VLRREE,SUBSTR(BOW_PGMTO ,(INSTR(BOW_PGMTO,'/')-2),LENGTH(BOW_PGMTO)-(INSTR(BOW_PGMTO,'/')-1)) as BOW_PGMTO  ,Case when SE2.E2_BAIXA <> ' ' Then  SE2.E2_BAIXA Else SE1.E1_BAIXA end as E2_BAIXA, TO_CHAR(" + cSqlName + ".R_E_C_N_O_) RECNO, " 
		
		Case AllTrim(TCGetDB()) == "POSTGRES"
			cSql := "  SELECT CASE WHEN BOW_STATUS = 'A' THEN '' ELSE " + cSqlName + ".BOW_PROTOC END BOW_PROTOC, CASE  WHEN  B44.B44_STATUS  = '4'  AND BOW_STATUS ='C'  THEN 'C'   WHEN  B44.B44_STATUS  IS NULL  AND BOW_STATUS ='C'  THEN '2'  ELSE BOW_STATUS   END BOW_STATUS, " + cSqlName + ".BOW_NOMUSR," + cSqlName + ".BOW_DTDIGI, " + cSqlName + ".BOW_NOMREF, " + cSqlName + ".BOW_VLRAPR," + cSqlName + ".BOW_VLRREE, BOW_PGMTO, Case when SE2.E2_BAIXA <> ' ' Then  SE2.E2_BAIXA Else SE1.E1_BAIXA end as E2_BAIXA, TO_CHAR(" + cSqlName + ".R_E_C_N_O_,'FM99999999') RECNO, " 
		
		Otherwise
			cSql := "  SELECT CASE WHEN BOW_STATUS = 'A' THEN '' ELSE " + cSqlName + ".BOW_PROTOC END BOW_PROTOC, CASE  WHEN  B44.B44_STATUS  = '4'  AND BOW_STATUS ='C'  THEN 'C'   WHEN  B44.B44_STATUS  IS NULL  AND BOW_STATUS ='C'  THEN '2'  ELSE BOW_STATUS   END BOW_STATUS, " + cSqlName + ".BOW_NOMUSR," + cSqlName + ".BOW_DTDIGI, " + cSqlName + ".BOW_NOMREF, " + cSqlName + ".BOW_VLRAPR," + cSqlName + ".BOW_VLRREE,SUBSTRING(" + cSqlName + ".BOW_PGMTO ,(CHARINDEX('/'," + cSqlName + ".BOW_PGMTO)-3),LEN(" + cSqlName + ".BOW_PGMTO)-(CHARINDEX('/'," + cSqlName + ".BOW_PGMTO)-4)) as BOW_PGMTO  ,Case when SE2.E2_BAIXA <> ' ' Then  SE2.E2_BAIXA Else SE1.E1_BAIXA end as E2_BAIXA, CONVERT ( VARCHAR," + cSqlName + ".R_E_C_N_O_) RECNO, " 
	EndCase

	cSql += cSqlName + ".BOW_OPEUSR, " + cSqlName + ".R_E_C_N_O_ CODREC, '~' SEP, B44.B44_STATUS  FROM " + cSqlName
	cSql += "  LEFT JOIN  "+RetSQLName("SE2")+" SE2 ON SE2.E2_FILIAL = '"+xFilial("SE2")+"'   AND SE2.E2_PREFIXO = " + cSqlName + ".BOW_PREFIX    AND SE2.E2_NUM = " + cSqlName + ".BOW_NUM    AND SE2.E2_FORNECE = " + cSqlName + ".BOW_FORNEC    AND SE2.D_E_L_E_T_ = ' '"
	cSql += "  LEFT JOIN  "+RetSQLName("SE1")+" SE1 ON SE1.E1_FILIAL = '"+xFilial("SE1")+"'   AND SE1.E1_PREFIXO = " + cSqlName + ".BOW_PREFIX    AND SE1.E1_NUM = " + cSqlName + ".BOW_NUM    AND SE1.E1_CLIENTE = " + cSqlName + ".BOW_FORNEC    AND SE1.D_E_L_E_T_ = ' '"
	cSql += "  LEFT JOIN  "+RetSQLName("B44")+" B44 ON B44.B44_FILIAL= '"+xFilial("B44")+"'   AND B44.B44_PROTOC = " + cSqlName + ".BOW_PROTOC    AND B44.D_E_L_E_T_ = ' '"

else
	
	if(AT( "cStatus=A", paramixb[1] ) ) == 0
		cCampos := "Protocolo=BOW_PROTOC,Data Solicita็ใo=BOW_DTDIGI,Total Apresentado=BOW_VLRAPR,0#Cancelar=RECNO, 1*#Imp=BOW_PROTOC+CHR(126)+STR(RECNO)"
	else
		cCampos := "Protocolo=BOW_PROTOC,Data Solicita็ใo=BOW_DTDIGI,Total Apresentado=BOW_VLRAPR,0#Cancelar=RECNO"
	endIf

	cSql := "  SELECT " + cSqlName + ".BOW_PROTOC,"
	cSql +=				 cSqlName + ".BOW_DTDIGI,"
	cSql += 				 cSqlName + ".BOW_VLRAPR,"
	cSql += 				 cSqlName + ".R_E_C_N_O_ RECNO FROM " + cSqlName

endIf

cWhere += "	 WHERE " + cSqlName + ".BOW_FILIAL = '" + xFilial(cAlias) + "' "

If FindFunction( "PLSRETRAS")

	cMatFam := SUBSTR( aPar[ aScan(aPar,"Field_USUARI") ],15,14)

	BA3->(DbSetOrder(1))
	If BA3->( MsSeek( xFilial("BA3") + cMatFam))

		if !EMPTY(BA3->BA3_CODRAS)
			aPar[ aScan(aPar,"Field_USUARI") ] := "Field_USUARI=" + PLSRETRAS(BA3->BA3_CODRAS, cMatFam) 
		Else
			aPar[ aScan(aPar,"Field_USUARI") ] := "Field_USUARI=" + cMatFam
		EndIf
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	If Len(awhere) > 1
		awhere[2] := AllTrim(StrTran(aWhere[2],"'",""))
		awhere[2] := AllTrim(StrTran(aWhere[2],'"',""))
	EndIf

	do case
		case aWhere[1] == 'Field_NROPROT' .and. len(aWhere)>1
			If !Empty(aWhere[2]) 
				cWhere += " AND " + cSqlName + ".BOW_PROTOC = '" + aWhere[2] + "' "
				lTemProtoc := .T. // Determina caso informo o protocolo nใo preciso informar as datas, pois o usuario nใo sabe qual e o mes do protocolo
			Endif	
		case aWhere[1] == 'Field_DTDE' .and. len(aWhere)>1  .and. !lTemProtoc
			cWhere += " AND " + cSqlName + ".BOW_DTDIGI >= '" + dtos(ctod("01/"+aWhere[2])) + "' "
		case aWhere[1] == 'Field_DTATE' .and. len(aWhere)>1 .and. !lTemProtoc
			cWhere += " AND " + cSqlName + ".BOW_DTDIGI <= '" + dtos(LastDay(ctod("01/"+aWhere[2]))) + "' "
		case aWhere[1] == 'Field_USUARI' .and. len(aWhere)>1
			
			If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
				If "," $ aWhere[2]
						
						If FindFunction( "PLSRETRAS")
							cWhere += " AND SUBSTR(" + cSqlName + ".BOW_USUARI,1,14) IN (" + aWhere[2] + ") "
						Else
							cWhere += " AND SUBSTR(" + cSqlName + ".BOW_USUARI,1,14) IN ('" + SUBSTR(aWhere[2],1,14) + "') "
						EndIf
				Else
						cWhere += " AND SUBSTR(" + cSqlName + ".BOW_USUARI,1,14) = '" + SUBSTR(aWhere[2],1,14) + "' "
				EndIf
			Else
				If "," $ aWhere[2]
					
					If FindFunction( "PLSRETRAS")
						cWhere += " AND SUBSTRING(" + cSqlName + ".BOW_USUARI,1,14) IN (" + aWhere[2] + ") "
					Else
						cWhere += " AND SUBSTRING(" + cSqlName + ".BOW_USUARI,1,14) IN ('" + SUBSTR(aWhere[2],1,14) + "') "
					EndIf
				Else
					cWhere += " AND SUBSTRING(" + cSqlName + ".BOW_USUARI,1,14) = '" + SUBSTR(aWhere[2],1,14) + "' "
				EndIf
			EndIf
		case aWhere[1] == 'Field_STPROC' .and. len(aWhere)>1
			If !Empty(aWhere[2])
				If 		aWhere[2] == "0"
					cWhere += " AND " + cSqlName + ".BOW_STATUS = 'A' "
				ElseIf aWhere[2] == "1"
					cWhere += " AND " + cSqlName + ".BOW_STATUS IN ( '0', '1' ) "
				ElseIf aWhere[2] == "2"
					//O status 3 tem que estar aqui pois por mais que esteja deferido, ainda nใo foi liberado para pagar
					cWhere += " AND " + cSqlName + ".BOW_STATUS IN ( '2','3','5','9' ) " // beneficiario nao precisa visualizar todos status
				ElseIf aWhere[2] == "3"
					cWhere += " AND " + cSqlName + ".BOW_STATUS = '6'  "
				ElseIf aWhere[2] == "4"
					cWhere += " AND " + cSqlName + ".BOW_STATUS IN ( '4','7','8') "
				ElseIf aWhere[2] == "5"
					cWhere += " AND " + cSqlName + ".BOW_STATUS = 'B' "
				ElseIf aWhere[2] == "6"
					cWhere += " AND " + cSqlName + ".BOW_STATUS = 'C' "
				ElseIf aWhere[2] == "7"
					cWhere += " AND " + cSqlName + ".BOW_STATUS = 'D' "
				ElseIf aWhere[2] == "9" //O 8 sใo todos, ้ s๓ nใo filtrar
					cWhere += " AND " + cSqlName + ".BOW_STATUS = 'E' "
				EndIf
				// Op็ใo Portal (ํndice do combo) $ Descri็ใo = op็ใo Remote correspondente
				//	  0$Solicita็ใo nใo concluํda = A
				//	  1$Protocolado = 0, 1
				//	  2$Em analise = 2, 3, 5, 9
				//	  3$Reembolso aprovado = 6
				//	  4$Reembolso rejeitado = 4, 7, 8
				//	  5$Aguardando informa็ใo do Beneficiแrio = B
				//	  6$Aprovado Parcialmente = C
				//	  7$Cancelado = D
				//	  8$Todos
				//	  9$Reembolso revertido  = E
			EndIf
	endCase
next

cWhere += "    AND " + cSqlName + ".D_E_L_E_T_ = ' ' "
cSql := cSql + cWhere + " ORDER BY 1 DESC"

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )


//////////////////////////////////////////////////////////////////
/*/{Protheus.doc} PLBRWB1N

Busca os itens do Protocolo de Reembolso

@version P12
/*/
//////////////////////////////////////////////////////////////////
user Function PLBRWB1N()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 50
LOCAL cAlias  	:= "B1N"
LOCAL cCampos 	:= ""
LOCAL cSql 	  	:= ""
LOCAL cFieldJ	:= " "
LOCAL cWhere  	:= ""
LOCAL cWhere2  	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
LOCAL cPesquisa	:= ""
LOCAL cGroupBy  := "" 

/////////////////////////////////////////////////////////////////////////////////////////////////////
//ณ Se o status for protocolado ou acima, nใo serแ possํvel excluir o item da solicita็ใo
/////////////////////////////////////////////////////////////////////////////////////////////////////
If BOW->BOW_STATUS == "0"
	cCampos := "0#Cancelar=RECNO,Situa็ใo=B1N_IMGSTA, 1#Observa็ใo=RECNO,Protocolo=B1N_PROTOC, Beneficiario=BA1_NOMUSR, Procedimento=BR8_CODPSA,Despesa=BR8_DESCRI,Valor=B1N_VLRAPR, Quantidade=B1N_QTDPRO, Codigo Prest. Servi็o=B1N_CODREF, Nome Prest. Servi็o=B1N_NOMREF, Tipo Doc.=B1N_TIPDOC, Num. Documento=B1N_NUMDOC,Data do Documento=B1N_DATDOC,Uso Continuo=B1N_USOCON"
Else
	cCampos := "Situa็ใo=B1N_IMGSTA, 1#Observa็ใo=RECNO,Protocolo=B1N_PROTOC, Beneficiario=BA1_NOMUSR, Procedimento=BR8_CODPSA,Despesa=BR8_DESCRI,Valor=B1N_VLRAPR, Quantidade=B1N_QTDPRO, Codigo Prest. Servi็o=B1N_CODREF, Nome RDA=B1N_NOMREF, Tipo Doc.=B1N_TIPDOC, Num. Documento=B1N_NUMDOC,Data do Documento=B1N_DATDOC,Uso Continuo=B1N_USOCON"
EndIf

Do Case
	Case AllTrim(TCGetDB()) $ "ORACLE/DB2"
		cSql += "SELECT  B1N_PROTOC,BR8_CODPSA,BR8_DESCRI, B1N_IMGSTA, B1N_VLRAPR, B1N_QTDPRO, B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_NUMDOC, B1N_DATDOC,B1N_USOCON, TO_CHAR("+RetSQLName(cAlias)+".R_E_C_N_O_) RECNO,BA1_NOMUSR "
	
	Case AllTrim(TCGetDB()) == "POSTGRES"
		cSql += "SELECT  B1N_PROTOC,BR8_CODPSA,BR8_DESCRI, B1N_IMGSTA, B1N_VLRAPR, B1N_QTDPRO, B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_NUMDOC, B1N_DATDOC,B1N_USOCON, TO_CHAR("+RetSQLName(cAlias)+".R_E_C_N_O_,'FM99999999') RECNO,BA1_NOMUSR "
	
	Otherwise
		cSql += "SELECT  B1N_PROTOC,BR8_CODPSA,BR8_DESCRI, B1N_IMGSTA, B1N_VLRAPR, B1N_QTDPRO, B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_NUMDOC, B1N_DATDOC,B1N_USOCON, CONVERT ( VARCHAR,"+RetSQLName(cAlias)+".R_E_C_N_O_) RECNO, BA1_NOMUSR "
EndCase

cSql  += " FROM " + RetSQLName(cAlias) + "," + RetSQLName("BR8") + "," + RetSQLName("BA1")  

/////////////////////////////////////////////////////////////////////////////////////////////////////
//ณ Where
/////////////////////////////////////////////////////////////////////////////////////////////////////
cWhere  += " WHERE B1N_FILIAL = '" + xFilial(cAlias) + "' "
cWhere  += " AND "+RetSQLName(cAlias)+".D_E_L_E_T_ = ' ' "
cWhere2 += " AND BR8_CODPAD = B1N_CODPAD AND BR8_CODPSA = B1N_CODPRO "  
If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cWhere2 += " AND B1N_MATRIC = (BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO)"
Else
	cWhere2 += " AND B1N_MATRIC = (BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)"
EndIf

for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	do case
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	//ณ veio da consulta de peg definitivo
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	case aWhere[1] == 'Field_RECNO' .and. len(aWhere)>1
		nRegPagina:= 10

		BOW->( dbGoTo(val(aWhere[2])) )
		if !BOW->(eof())
			cWhere += " AND B1N_PROTOC = '" + BOW->BOW_PROTOC + "' "
		endIf

			//Se o status for diferente de solicitado, o beneficiแrio nใo poderแ deletar o item
			If BOW->BOW_STATUS == "0"
				cCampos := "Situa็ใo=B1N_IMGSTA, 1#Observa็ใo=RECNO,Protocolo=B1N_PROTOC, Beneficiario=BA1_NOMUSR, Procedimento=BR8_CODPSA,Despesa=BR8_DESCRI,Quantidade=B1N_QTDPRO,Valor Unitแrio=B1N_VLRAPR,Valor Total=B1N_VLRTOT, Valor Reemb.=B1N_VLRREE, Codigo Prest. Servi็o=B1N_CODREF, Nome Prest. Servi็o=B1N_NOMREF, Tipo Doc.=B1N_TIPDOC, Num. Documento=B1N_NUMDOC,Data do Documento=B1N_DATDOC,Uso Continuo=B1N_USOCON,0#Cancelar=RECNO" 
			
			ElseIf BOW->BOW_STATUS == "A"
				cCampos := "Situa็ใo=B1N_IMGSTA, 1#Observa็ใo=RECNO,  Beneficiario=BA1_NOMUSR, Procedimento=BR8_CODPSA,Despesa=BR8_DESCRI,Quantidade=B1N_QTDPRO,Valor Unitแrio=B1N_VLRAPR,Valor Total=B1N_VLRTOT, Valor Reemb.=B1N_VLRREE, Codigo Prest. Servi็o=B1N_CODREF, Nome RDA=B1N_NOMREF, Tipo Doc.=B1N_TIPDOC, Num. Documento=B1N_NUMDOC,Data do Documento=B1N_DATDOC,Uso Continuo=B1N_USOCON"
			
			Else
				cCampos := "Situa็ใo=B1N_IMGSTA, 1#Observa็ใo=RECNO, Beneficiario=BA1_NOMUSR,Protocolo=B1N_PROTOC, Procedimento=BR8_CODPSA,Despesa=BR8_DESCRI,Quantidade=B1N_QTDPRO,Valor Unitแrio=B1N_VLRAPR,Valor Total=B1N_VLRTOT, Valor Reemb.=B1N_VLRREE, Codigo Prest. Servi็o=B1N_CODREF, Nome RDA=B1N_NOMREF, Tipo Doc.=B1N_TIPDOC, Num. Documento=B1N_NUMDOC,Data do Documento=B1N_DATDOC,Uso Continuo=B1N_USOCON" 
			EndIf
			
			Do Case
				Case AllTrim(TCGetDB()) $ "ORACLE/DB2"
					cSql := "SELECT  B1N_PROTOC,BR8_CODPSA,BR8_DESCRI, B1N_IMGSTA, B1N_VLRAPR,B1N_VLRTOT,B1N_VLRREE, B1N_QTDPRO, B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_NUMDOC, B1N_DATDOC,B1N_USOCON,  TO_CHAR("+RetSQLName(cAlias)+".R_E_C_N_O_) RECNO, BA1_NOMUSR "  
				
				Case AllTrim(TCGetDB()) == "POSTGRES"
					cSql := "SELECT  B1N_PROTOC,BR8_CODPSA,BR8_DESCRI, B1N_IMGSTA, B1N_VLRAPR,B1N_VLRTOT,B1N_VLRREE, B1N_QTDPRO, B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_NUMDOC, B1N_DATDOC,B1N_USOCON,  TO_CHAR("+RetSQLName(cAlias)+".R_E_C_N_O_,'FM99999999') RECNO, BA1_NOMUSR "

				Otherwise
					cSql := "SELECT  B1N_PROTOC,BR8_CODPSA,BR8_DESCRI, B1N_IMGSTA, B1N_VLRAPR,B1N_VLRTOT,B1N_VLRREE, B1N_QTDPRO, B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_NUMDOC, B1N_DATDOC,B1N_USOCON,  CONVERT ( VARCHAR,"+RetSQLName(cAlias)+".R_E_C_N_O_) RECNO, BA1_NOMUSR "  
			EndCase

			cSql += " FROM " + RetSQLName(cAlias) + "," + RetSQLName("BR8")  + "," + RetSQLName("BA1") 
			
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	//ณ parametros quando vem da selecao para geracao de peg definitivo
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	case aWhere[1] == 'Field_NROPROT' .and. len(aWhere)>1
		If !Empty(aWhere[2])
			cWhere += " AND B1N_PROTOC = '" + aWhere[2] + "' "
		EndIf
	endCase
next

cGroupBy += " GROUP BY B1N_PROTOC, BR8_CODPSA, BR8_DESCRI, B1N_IMGSTA, B1N_VLRAPR, B1N_VLRTOT, B1N_VLRREE, B1N_QTDPRO," 
cGroupBy += " B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_NUMDOC, B1N_DATDOC, B1N_USOCON, " + RetSQLName(cAlias)+".R_E_C_N_O_, BA1_NOMUSR" 

cSql := cSql + cWhere + cWhere2 + cGroupBy

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ,cPesquisa,,,,.F., "B1N_USOCON"} ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB14  บAutor  ณTotvs               บ Data ณ  20/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca protocolos de Reembolso						   		    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWB14()
LOCAL aArea 	:= getArea()
LOCAL nI		:= 0
LOCAL nRegPagina:= 30
LOCAL cAlias  	:= "B1N"
LOCAL cCampos 	:= "Protocolo=B1N_PROTOC,Cod. Proc.=B1N_CODPRO,Descri. Proc=B14_DESPRO,Quantidade=B1N_QTDPRO,Valor=B1N_VLRAPR,Cod. RDA=B1N_CODREF,Nome RDA=B1N_NOMREF,Tipo Doc.=B1N_TIPDOC,Data Doc.=B1N_DATDOC,0#MOTIVO=RECNO"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
LOCAL aWhereDt	:= strToArray( aPar[2] , '=' )
LOCAL aWhereDt2  	:= strToArray( aPar[3] , '=' )
LOCAL aWhereMt	:= strToArray( aPar[4] , '=' )
LOCAL lProt		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT  B14_DESPRO, B14_MOTIVO, B14_CODUSR, B14_NOMUSR, "+ RetSQLName("B14") +".R_E_C_N_O_ RECNO, "
cSql += " B1N_PROTOC, B1N_CODPRO, B1N_QTDPRO, B1N_VLRAPR, B1N_CODREF, B1N_NOMREF, B1N_TIPDOC, B1N_DATDOC, B14_CODPRO "
cSql += " FROM " + RetSQLName("B1N")
cSql += " INNER JOIN " + RetSQLName("B14")
cSQL += " ON B14_CDPROT = B1N_PROTOC AND B14_DATA BETWEEN '" + dtos(ctod("01/"+aWhereDt[2])) + "' AND '"
cSQL += dtos(LastDay(ctod("01/"+aWhereDt2[2]))) + "' AND B14_MATRIC = " + aWhereMt[2] + " AND B14_CODPRO = B1N_CODPRO AND "
cSQL += RetSQLName("B14")+".D_E_L_E_T_ = ' '"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	do case
		case aWhere[1] == 'Field_NROPROT' .and. len(aWhere)>1
			cWhere += " WHERE B1N_PROTOC = '" + aWhere[2] + "' "
			cWhere += " AND " + RetSQLName("B1N")+".D_E_L_E_T_ = '*'"
			lProt := .T.
	endCase
next

If !lProt
	cWhere += " WHERE " + RetSQLName("B1N")+".D_E_L_E_T_ = '*'"
EndIf

cSql := cSql + cWhere + " ORDER BY 1 DESC"

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB2G  บAutor  ณTotvs               บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de Contratos	                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWB2G()
LOCAL aArea 	    := getArea()
LOCAL nRegPagina  	:= 30
LOCAL cAlias  		:= "B2G"
LOCAL cCampos 		:= "0#Imp=RECNO,?=B2H_DOC,?=B2L_DESC,?=B2H_REV,Tipo=TIPO,?=B2H_DTINC,?=B2H_DTVAL"
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ	   	:= ""
LOCAL aPar  	   	:= strToArray( paramixb[1] , '|' )
Local cAuxSql1   	:=  ""
Local cAuxSql2   	:=  ""
LOCAL cCodRda    	:= SUBSTR(aPar[2],14)


cAuxSql1 := "  SELECT B2H_SEQ,B2H_DOC,B2L_DESC, B2H_REV,(CASE WHEN B2L_TIPO = 1 THEN 'Contrato' ELSE 'Aditivo' END) AS TIPO, B2H_DTINC,B2H_DTVAL,B2H_PATH, "+ RetSQLName("B2H") +".R_E_C_N_O_ RECNO "
cAuxSql1 += "	 FROM " + RetSQLName("B2G")

cAuxSql2 += "  INNER JOIN "+ RetSQLName("B2H") +" ON B2G_RDA = B2H_RDA "
cAuxSql2 += "  INNER JOIN "+ RetSQLName("B2L") +" ON B2H_DOC = B2L_COD "

cWhere += "	 WHERE "
cWhere += "	 B2G_FILIAL = '" + xFilial("B2G") + "' "
cWhere += "	 AND B2G_CODINT = '" + PLSINTPAD() + "' "
cWhere += "	 AND B2G_RDA = '"+cCodRda+"' "
cWhere += "	 AND B2H_FILIAL = B2G_FILIAL "
cWhere += "	 AND B2L_FILIAL = B2G_FILIAL "
cWhere += "	 AND B2H_PATH <> '' " //Importante para nใo exibir contratos sem anexo
cWhere += "    AND "+ RetSQLName("B2G")+".D_E_L_E_T_ = ' ' And "+ RetSQLName("B2H")+".D_E_L_E_T_ = ' ' AND "+ RetSQLName("B2L")+".D_E_L_E_T_ = ' ' "

cSql := cAuxSql1 +cAuxSql2+ cWhere

RestArea(aArea)

return( {cAlias,cSql,cAuxSql2+cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB1K  บAutor Thiago Ribas  ณTotvsบ Data ณ  10/06/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o calendแrio de reembolso				         	 บฑฑ
				       							    					บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWB1K()
LOCAL aArea 	:= GetArea()
LOCAL aWhere  	:= StrToArray( paramixb[1] , '|' )
LOCAL aWhere1		:= {}
LOCAL cAlias  	:= "B1K"
LOCAL cCampos 	:= "De:=B1K_DATINI,At้:=B1K_DATFIN,Data de Reembolso=B1K_DATPRE"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ		:= ""
LOCAL nRegPagina := 10
LOCAL nI:=1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ cFieldJ - Necessario quando tem join de tabelas e utiliza o contador de
//ณ paginas. (count)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados do F3
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT B1K_DATINI, B1K_DATFIN, B1K_DATPRE, "
cSql += RetSQLName(cAlias) + ".R_E_C_N_O_ "
cSql += " FROM " + RetSQLName(cAlias)

cWhere += " WHERE B1K_CODINT = '" + PLSINTPAD() + "' AND B1K_ANO = '" + ALLTRIM(STR(YEAR(dDataBase))) + "' "
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

aWhere1 := StrToArray( aWhere[nI] , '=' )
If aWhere1[1] == 'Field_MES'
	cWhere += " AND B1K_MES = '" + ALLTRIM(STRZERO(VAL(aWhere1[2]),2)) + "' AND "
Endif

cWhere += RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' "

cSql := cSql + cWhere

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWRAST  บAutor Thiago Ribas  ณTotvsบ Data ณ  10/06/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os dados da rotina de rastreabilidade do portal
do beneficiแrio												         	 บฑฑ
				       							    					 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWRAST() 
LOCAL aArea 		:= GetArea()
LOCAL aWhere  		:= StrToArray( paramixb[1] , '|' )
LOCAL aWhere1		:= {}
LOCAL cAlias  		:= "B1N"
LOCAL cCampos 		:= "C๓d. Receita=B1N_CODREC,Medicamento=BR8_DESCRI,Protocolo=B1N_PROTOC,Data Solicita็ใo=BOW_DTDIGI,Quantidade Solicitada=B1N_QTDMED, Data Reembolso=BOW_DATPAG"
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ		:= ""
LOCAL nRegPagina 	:= 10
LOCAL nI			:=1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := " SELECT B1N_CODREC, BR8_DESCRI, B1N_PROTOC, BOW_DTDIGI, B1N_QTDMED, BOW_DATPAG "
cSql += " FROM " + RetSQLName(cAlias)
cSql += " INNER JOIN " + RetSQLName("BOW")
cSql += " ON B1N_PROTOC = BOW_PROTOC "
cSql += " INNER JOIN " + RetSQLName("BR8")
cSql += " ON BR8_CODPAD = B1N_CODPAD AND BR8_CODPSA = B1N_CODPRO AND "
cSql += RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' AND " + RetSQLName("BOW")+ ".D_E_L_E_T_ = ' ' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	For nI := 1 To 2
		aWhere1 := StrToArray( aWhere[nI] , ',' )

		If aWhere1[1] == 'cCodRec'
			cWhere += " WHERE B1N_CODREC = '" + aWhere1[2] +"' " 
		Endif

		If aWhere1[1] == 'cCodMed'
			cWhere += " AND B1N_CODMED = '" + aWhere1[2] +"' " 
		Endif 
	Next 
	
cSql := cSql + cWhere
cSql += " ORDER BY B1N_CODREC DESC"

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB9Y บAutor  ณTotvs               บ Data ณ  27/05/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de protocolos de indica็๕es de profissionais บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWB9Y()
LOCAL aArea 	    := getArea()
LOCAL nI		    := 0
LOCAL nRegPagina  := 30
LOCAL cAlias  	:= "B9Y"
LOCAL cCampos 	:= "Protocolo=B9Y_NROPRO,?=B9Y_NOME,?=B9Y_CRMNUM,?=B9Y_DATAIN,?=B9N_OBSERV "
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	   := ""
LOCAL aPar  	   := strToArray( paramixb[1] , '|' )
LOCAL aWhere     := {}
Local cFile      := "\temp\SQL_LEANDRO.txt"
Local nH
Local cAuxSql1   :=  ""
Local cAuxSql2   :=  ""

cAuxSql1 := "  SELECT B9Y_NROPRO, B9Y_NOME, B9Y_CRMNUM, B9Y_DATAIN, B9N_OBSERV, "+ RetSQLName("B9Y") +".R_E_C_N_O_ RECNO "
cAuxSql1 += "	 FROM " + RetSQLName("B9Y")

cAuxSql2 += "  INNER JOIN "+ RetSQLName("B9N") +" ON B9N_CODOBS = B9Y_CODOBS "

cWhere += "	 WHERE "
cWhere += "	 B9Y_FILIAL = '" + xFilial("B9Y") + "' "
cWhere += "	 AND B9Y_NROPRO <> ' ' "
cWhere += "	 AND B9Y_CODINT = '" + PLSINTPAD() + "' "


for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	do case
		case aWhere[1] == 'Field_DTDE' .and. len(aWhere)>1
			cWhere += " AND B9Y_DATAIN >= '" + dtos(ctod(aWhere[2])) + "' "

		case aWhere[1] == 'Field_DTATE' .and. len(aWhere)>1
			cWhere += " AND B9Y_DATAIN <= '" + dtos(ctod(aWhere[2])) + "' "

		case aWhere[1] == 'Field_CRM' .and. len(aWhere)>1
			cWhere += " AND B9Y_CRMNUM = '" + aWhere[2] + "' "

	endCase

next

cWhere += "    AND "+ RetSQLName("B9Y")+".D_E_L_E_T_ = ' ' And "+ RetSQLName("B9N")+".D_E_L_E_T_ = ' ' "

cSql := cAuxSql1 +cAuxSql2+ cWhere + " ORDER BY B9Y_DATAIN "

nH := fCreate(cFile)
fWrite(nH,cSql + chr(13)+chr(10) )
FClose(nH)

RestArea(aArea)

return( {cAlias,cSql,cAuxSql2+cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWPRE  บAutor Everton M FernandณTotvsบ Data ณ  13/10/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os prestadores que atendem a um plano e a uma     	 บฑฑ
				especialidade. Considera os campos B___GUIMED    		  	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWPRE()
LOCAL aArea 		:= getArea()
LOCAL nI			:= 0
LOCAL nRegPagina	:= 9999
LOCAL cAlias  	:= "BAX"




LOCAL cCampos 	:=	"0#Visualizar=RECNO,"+;
						"1#Mapa=RECNO,"+;
						"Tipo Estabelecimento=BB8_DESLOC,"+;
						"Nome do Profissional=BAU_NOME,"+;
						"Telefone=BB8_DDD+BB8_TEL,"+;
						"CNPJ/CPF=BB8_CPFCGC,"+;
						"Num. Conselho=BAU_CONREG,"+;
						"Estado=BB8_EST,"+;
						"Cidade=BB8_MUN,"+;
						"Bairro=BB8_BAIRRO"

LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ		:= ""
LOCAL aPar  		:= strToArray( paramixb[1] , '|' )
LOCAL cEspec		:= "003" //Valor de teste
LOCAL cCodOpe		:= ""
LOCAL cCodPlan	:= ""
LOCAL cVersao		:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql := "SELECT  BB8_DESLOC"+;
					",BAU_NOME"+;
					",BB8_DDD"+;
					",BB8_TEL"+;
					",BB8_CPFCGC"+;
					",BAU_CONREG"+;
					",BB8_BAIRRO"+;
					",BB8_MUN"+;
					",BB8_EST"+;
					",BI3_DESCRI "+;
					",BI3_SCPA"+;
					",BI3_CLAPLS"+;
					",BI3_APOSRG"+;
			"," + RetSQLName("BB8") + ".R_E_C_N_O_ RECNO "

cSql += " FROM " + RetSQLName("BAX")
cWhere += " INNER JOIN " + RetSQLName("BAU") + " ON BAU_FILIAL = BAX_FILIAL "
cWhere += " 	AND BAU_CODIGO = BAX_CODIGO "
cWhere += " 	AND " + RetSQLName("BAU") + " .D_E_L_E_T_ = ' ' "
cWhere += " INNER JOIN " + RetSQLName("BI3") + " ON BI3_FILIAL = BAX_FILIAL "
cWhere += " 	AND " + RetSQLName("BI3") + " .D_E_L_E_T_ = ' ' "
cWhere += " INNER JOIN " + RetSQLName("BB8") + " ON BB8_FILIAL = BAX_FILIAL "
cWhere += " 	AND " + RetSQLName("BB8") + " .D_E_L_E_T_ = ' ' "
cWhere += " 	AND BB8_CODIGO = BAX_CODIGO "
cWhere += " 	AND BB8_CODINT = BAX_CODINT "
cWhere += " 	AND BB8_CODLOC = BAX_CODLOC "

cWhere += " LEFT JOIN " + RetSQLName("BB6") + " ON BB6_FILIAL = BI3_FILIAL "
cWhere += " 	AND " + RetSQLName("BB6") + ".D_E_L_E_T_ = ' ' "

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cWhere += " 	AND BB6_CODIGO = BI3_CODINT || BI3_CODIGO "
Else
	cWhere += " 	AND BB6_CODIGO = BI3_CODINT + BI3_CODIGO "
EndIf

cWhere += " 	AND BB6_VERSAO = BI3_VERSAO "
cWhere += " LEFT JOIN " + RetSQLName("BBK") + " ON BBK_FILIAL = BB6_FILIAL "
cWhere += " 	AND " + RetSQLName("BBK") + ".D_E_L_E_T_ = ' ' "
cWhere += " 	AND BBK_CODIGO = BAU_CODIGO "
cWhere += " 	AND BBK_CODINT = BI3_CODINT "
cWhere += " 	AND BBK_CODLOC = BAX_CODLOC "
cWhere += " 	AND BBK_CODESP = BAX_CODESP "
cWhere += " 	AND BBK_CODRED = BB6_CODRED "

cWhere += " LEFT JOIN " + RetSQLName("BBI") + " ON BBI_FILIAL = BAX_FILIAL "
cWhere += " 	AND " + RetSQLName("BBI") + " .D_E_L_E_T_ = ' ' "
cWhere += " 	AND BBI_CODIGO = BAX_CODIGO "
cWhere += " 	AND BBI_CODINT = BAX_CODINT "
cWhere += " 	AND BBI_CODLOC = BAX_CODLOC "
cWhere += " 	AND BBI_CODESP = BAX_CODESP "
cWhere += " LEFT JOIN " + RetSQLName("B30") + " ON B30_FILIAL = BI3_FILIAL "
cWhere += " 	AND " + RetSQLName("B30") + " .D_E_L_E_T_ = ' ' "
cWhere += " 	AND B30_CODIGO = BAX_CODIGO "
cWhere += " 	AND B30_CODINT = BI3_CODINT "
cWhere += " 	AND B30_CODPRO = BI3_CODIGO "
cWhere += " 	AND B30_VERSAO = BI3_VERSAO "
cWhere += " LEFT JOIN " + RetSQLName("BT4") + " ON BT4_FILIAL = BAX_FILIAL "
cWhere += " 	AND " + RetSQLName("BT4") + " .D_E_L_E_T_ = ' ' "

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cWhere += " 	AND BT4_CODIGO = BI3_CODINT || BI3_CODIGO "
Else
	cWhere += " 	AND BT4_CODIGO = BI3_CODINT + BI3_CODIGO "
EndIf

cWhere += " 	AND BT4_VERSAO = BI3_VERSAO "
cWhere += " 	AND BT4_CODCRE = BAX_CODIGO "


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Parametros
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )
	If "'" $ APAR[2]
		APAR[2] := "CaracterInvalido"
	EndIf
	If aWhere[1] == "cCodOpe"
		cCodOpe := aWhere[2]
	ElseIf aWhere[1] == "cCodPlan"
		cCodPlan := aWhere[2]
	ElseIf aWhere[1] == "cVersao"
		cVersao := aWhere[2]
	ElseIf aWhere[1] == "cEspec"
		cEspec := TRIM(PLSGETVINC("BTU_CDTERM", "BAQ", .F., "24",  aWhere[2],.T.))
	EndIf

next


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += " WHERE BI3_FILIAL = '" + xFilial("BI3") + "' "
cWhere += " 	AND BI3_CODIGO = '" + cCodPlan + "'" //'PRODUTO PJ LUXO%' " //Recuperar dados do produto
cWhere += " 	AND BI3_CODINT = '"+ cCodOpe +"' " //0001//Operadora do produto
cWhere += " 	AND BI3_VERSAO = '" + cVersao + "' " //001//Versใo do produto
cWhere += " 	AND BAX_FILIAL = '" + xFilial("BAX") + "' "
cWhere += " 	AND BAX_CODINT = '"+ cCodOpe +"' " //0001//Operadora do produto
cWhere += " 	AND BAX_CODESP = '" + cEspec + "' " //003//Especialidade convertida de TISS para Protheus
cWhere += " 	AND ( (BBI_ATIVO <> '0') " //Regra da Especialidade //Nํvel 1, o mais alto
cWhere += " 			OR (B30_ATIVO <> '0'	AND BBI_ATIVO IS NULL ) " //RDA x Plano; Nivel 2
cWhere += " 			OR (BT4_PERM <> '1' AND BBI_ATIVO IS NULL AND B30_ATIVO IS NULL ) " //Rede Ref. no Prod.; Nivel 3
cWhere += " 			OR ( ( (	BI3_ALLRED <> '0'	OR ( BB6_ATIVO <> '0' AND BBK_CODRED = BB6_CODRED))OR (BI3_ALLRED = '0' AND BB6_ATIVO IS NULL) ) "
cWhere += " 				AND (BBI_ATIVO IS NULL AND B30_ATIVO IS NULL AND BT4_PERM IS NULL ) ) )" //Tipo de Rede e AllRed do Produto; Nivel 4; o mais baixo
cWhere += " 	AND (BAX_GUIMED <> '0' OR BAX_GUIMED IS NULL ) "
cWhere += " 	AND (BBI_GUIMED <> '0' OR BBI_GUIMED IS NULL ) "
cWhere += " 	AND BI3_GUIMED <> '0' "
cWhere += " 	AND " + RetSQLName("BAX") + ".D_E_L_E_T_ = ' ' "
cWhere += " 	AND NOT (BT4_PERM IS NULL AND B30_ATIVO IS NULL AND BBI_ATIVO IS NULL AND BB6_ATIVO IS NULL AND BI3_ALLRED = '0')"


cSql := cSql + cWhere

//cSql := ChangeQuery(cSql)

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWB9X  บAutor  ณTotvs               บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de Contratos	                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWB9X()

LOCAL aArea 	   	:= getArea()
LOCAL nRegPagina 	:= 10
LOCAL cAlias  		:= "B9X"
LOCAL cCampos 		:= "C๓digo Doc=B9X_SEQMOT,Doc Motivo=BD2_DESCRI,?=B9X_OBRIG,0#Enviar Anexo=R_E_C_N_O_"
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ	   	:= ""
LOCAL aPar  	   	:= strToArray( paramixb[1] , '|' )
Local cAuxSql1   	:=  ""
LOCAL cMotivo 		:= SubStr(aPar[1], 14)

cAuxSql1 := "  SELECT " + RetSQLName("B9X") + ".R_E_C_N_O_ IDENLINHA, "
cAuxSql1 += RetSQLName("B9X") + ".B9X_CODMOT,  "
cAuxSql1 += RetSQLName("B9X") + ".B9X_CODINT, " + RetSQLName("B9X") + ".B9X_FILIAL, "
cAuxSql1 += RetSQLName("B9X") + ".B9X_OBRIG, " + RetSQLName("B9X") + ".B9X_SEQMOT, "
cAuxSql1 += RetSQLName("B9X") + ".D_E_L_E_T_, " + RetSQLName("B9X") + ".R_E_C_N_O_, "
cAuxSql1 += RetSQLName("BD2") + ".BD2_DESCRI "
cAuxSql1 += "	 FROM " + RetSQLName("B9X")
cAuxSql1 += "	 INNER JOIN " + RetSQLName("BD2")
cAuxSql1 += "  ON BD2_FILIAL = '" + xFilial("BD2") + "'"
cAuxSql1 += "	 AND BD2_CODDOC = B9X_CODDOC"
cAuxSql1 += "	 AND "+RetSQLName("B9X")+".D_E_L_E_T_ = ' ' "

cWhere += "	 WHERE "
cWhere += "	 B9X_FILIAL = '" + xFilial("B9X") + "' "
cWhere += "	 AND B9X_CODINT = '" + PLSINTPAD() + "' "
cWhere += "	 AND B9X_CODMOT = '" + cMotivo + "' "
cWhere += "    AND "+ RetSQLName("B9X")+".D_E_L_E_T_ = ' ' "

cSql := cAuxSql1 + cWhere

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBKU  บAutor  ณTotvs               บ Data ณ  15/12/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca do protocolo de solicitacao                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user Function PLBRWBKU()

LOCAL aArea 	   	:= getArea()
LOCAL nRegPagina 	:= 5
LOCAL cAlias  	    := "BKU"
LOCAL cCampos 	    := "Protocolo=BKU_NRPRO,Beneficiario=BKU_NOMUSR,Matricula=BKU_MATUSR,Solicitante=BKU_NOMSOL,Sigla. CR=BKU_SIGLA,CR. Solic=BKU_REGSOL,Status=BKU_STATUS,Num. Autoriz=BKU_NUMAUT,Tipo. Movto=BKU_TIPO ,0#Informa็๕es=BKU_NRPRO" 
LOCAL cQuery     	:= ""
LOCAL cWhere  	    := ""
LOCAL cFieldJ	   	:= ""
LOCAL aPar  	   	:= strToArray( paramixb[1] , '|' )
LOCAL cNrPro 	    := SubStr(aPar[1], 20)

//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cQuery := " SELECT " + RetSQLName(cAlias) + ".R_E_C_N_O_ IDENLINHA, " 
cQuery += " BKU_NRPRO,BKU_NOMUSR,BKU_MATUSR,BKU_NOMSOL,BKU_SIGLA,BKU_REGSOL,BKU_STATUS,BKU_NUMAUT,"
cQuery += " (CASE WHEN BKU_TIPO = '2' THEN 'SADT' WHEN BKU_TIPO = '3' THEN 'INTERNAวรO' WHEN BKU_TIPO = '4' THEN 'ODONTOLOGICA' ELSE '' END) AS BKU_TIPO,"+ RetSQLName(cAlias) + ".R_E_C_N_O_ "
cQuery += " FROM " + RetSQLName(cAlias)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere += "	 WHERE BKU_FILIAL = '" + xFilial(cAlias) + "' "
cWhere += "  AND BKU_NRPRO LIKE '%" + cNrPro + "%'" 
cWhere += "  AND D_E_L_E_T_   = ' '  "
cQuery := cQuery + cWhere
RestArea(aArea)
return( {cAlias,cQuery,cWhere,nRegPagina,cCampos,cFieldJ,"","","","",.F.,""} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPBRB9X2  บAutor  ณTotvs               บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca dos documentos                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PBRB9X2()

LOCAL aArea 	   	:= getArea()
LOCAL nI		   	:= 0
LOCAL nRegPagina 	:= 10
LOCAL cAlias  		:= "B9X"
LOCAL cCampos 		:= "C๓digo Doc=B9X_SEQMOT,Doc Motivo=BD2_DESCRI,?=B9X_OBRIG,0#Enviar Anexo=R_E_C_N_O_"
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ	   	:= ""
LOCAL aPar  	   	:= strToArray( paramixb[1] , '|' )
Local cAuxSql1   	:=  ""
Local aMotivo 		:= Separa(aPar[1], ':')
Local nTamMotivo	:= len(aMotivo)

cAuxSql1 := "  SELECT " + RetSQLName("B9X") + ".R_E_C_N_O_ IDENLINHA, "
cAuxSql1 += RetSQLName("B9X") + ".B9X_CODMOT,  "
cAuxSql1 += RetSQLName("B9X") + ".B9X_CODINT, " + RetSQLName("B9X") + ".B9X_FILIAL, "
cAuxSql1 += RetSQLName("B9X") + ".B9X_OBRIG, " + RetSQLName("B9X") + ".B9X_SEQMOT, "
cAuxSql1 += RetSQLName("B9X") + ".D_E_L_E_T_, " + RetSQLName("B9X") + ".R_E_C_N_O_, "
cAuxSql1 += RetSQLName("BD2") + ".BD2_DESCRI "
cAuxSql1 += "	 FROM " + RetSQLName("B9X")
cAuxSql1 += "	 INNER JOIN " + RetSQLName("BD2")
cAuxSql1 += "  ON BD2_FILIAL = '" + xFilial("BD2") + "'"
cAuxSql1 += "	 AND BD2_CODDOC = B9X_CODDOC"
cAuxSql1 += "	 AND "+RetSQLName("B9X")+".D_E_L_E_T_ = ' ' "

cWhere += "	WHERE "
cWhere += "	B9X_FILIAL = '" + xFilial("B9X") + "' "
cWhere += "	AND B9X_CODINT = '" + PLSINTPAD() + "' "

if nTamMotivo > 0
	
	cWhere	+= " AND B9X_CODMOT IN(" 

	For nI := 1 To nTamMotivo
		
		cWhere += "'" + AllTrim(aMotivo[nI]) + "' "

		If nI == nTamMotivo
			cWhere += ") "
		Else
			cWhere += ", "
		EndIf 
	Next
endif

cWhere += "    AND "+ RetSQLName("B9X")+".D_E_L_E_T_ = ' ' "

cSql := cAuxSql1 + cWhere

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )


/*/
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWRGB  บAutor: Renan Martins           Data ณ  20/01/2014บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os dados da Guia do Beneficiแrio para consulta das  บฑฑ
ฑฑ            guias e autoriza็๕es realizadas                      	    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
/*/
User Function PLBRWRGB()
LOCAL aArea 		:= getArea()
LOCAL nI			:= 0
LOCAL nRegPagina	:= 30
LOCAL cAlias  		:= "BEA"
Local cAlias1		:= "BE4"
Local cAlias2		:= "B4A"
Local cAlias3		:= "B4Q"
LOCAL cCampos 		:= ""
LOCAL cSql			:= ""
LOCAL cSql1 	  	:= ""
LOCAL cSql2 	  	:= ""
LOCAL cSql3 	  	:= ""
LOCAL cWhere  		:= ""
LOCAL cWhere1  		:= ""
LOCAL cWhere2  		:= ""
LOCAL cWhere3  		:= ""
Local aCmpSub		:= {{"BEA_HHDIGI","HORA"}, {"BEA_TIPO", "TIPO"}}  //Campos de apelidos necessitam substitui็ใo
LOCAL cFieldJ		:= ""
LOCAL aPar  		:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  		:= {}
LOCAL aInt			:= {.F.,.F.}  //Array para verificar se BE4 deve ser considerado 1ชp: Filtro guia? / 2ชp: BE4 selecioanda?
Local AliasInt		:= "BBR"
Local cSetben		:= GetNewPar("MV_SETORBF", .F.)
Local lAliB4Q 		:= PLSALIASEXI("B4Q")
Local aRet 			:= {}

If aScan(aPar,"Field_TPGUIA=3") > 0
	cCampos	:= "0#Itens Guia=BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BBR_TPDIRP,Status=BEA_STTISS,Cancel?=CANCEL,N๚mero da Guia=BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT,Data de Intern.=BEA_DATPRO,Hora de Intern.=BEA_HORPRO,Beneficiแrio=BEA_NOMUSR,CB=BBR_TPDIRP,SE=X,1*#Imprimir=BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT"
else
	cCampos	:= "0#Itens Guia=BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BBR_TPDIRP,Status=BEA_STTISS,Cancel?=CANCEL,N๚mero da Guia=BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT,Data da Solic.=BEA_DATPRO,Hora da Solic.=BEA_HHDIGI,Beneficiแrio=BEA_NOMUSR,CB=BBR_TPDIRP,SE=X,1*#Imprimir=BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Querys para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

cSql := "SELECT BEA_TIPO TIPO, BEA_STTISS, BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT, BEA_NOMUSR, BEA_OPEUSR, BEA_CODEMP, BEA_MATRIC, BEA_HORPRO, "
cSql += " BEA_TIPREG, BEA_DIGITO, BEA_DATPRO, BEA_HHDIGI  HORA , BEA_CANCEL CANCEL,BBR_TPDIRP, '"+cSetben+ "' X, " + RetSqlName(cAlias)+".R_E_C_N_O_ IDENLINHA"
cSql += " FROM " + RetSqlName("BEA")
cSql += " LEFT JOIN " + RetSqlName(AliasInt)
cSql += " ON  BEA_FILIAL = BBR_FILIAL"
cSql += " AND BEA_OPEMOV = BBR_CODOPE"
cSql += " AND BEA_ANOAUT = BBR_ANOAUT"
cSql += " AND BEA_MESAUT = BBR_MESAUT"
cSql += " AND BEA_NUMAUT = BBR_NUMAUT"
cSql += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

cSql1 += " SELECT '3' TIPO, BE4_STTISS, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, BE4_NOMUSR, BE4_OPEUSR, BE4_CODEMP, BE4_MATRIC, BE4_DATPRO, "
cSql1 += " BE4_TIPREG, BE4_DIGITO, BE4_DATPRO, BE4_HHDIGI  HORA, BE4_CANCEL CANCEL,BBR_TPDIRP, '"+cSetben+ "' X,"+RetSqlName(cAlias1)+".R_E_C_N_O_ IDENLINHA"
cSql1 += " FROM " +  RetSqlName("BE4")
cSql1 += " LEFT JOIN " + RetSqlName(AliasInt)
cSql1 += " ON  BE4_CODOPE = BBR_CODOPE"
cSql1 += " AND BE4_ANOINT = BBR_ANOAUT"
cSql1 += " AND BE4_MESINT = BBR_MESAUT"
cSql1 += " AND BE4_NUMINT = BBR_NUMAUT"
cSql1 += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

cSql2 += " SELECT B4A_TIPGUI TIPO, B4A_STTISS, B4A_OPEMOV, B4A_ANOAUT, B4A_MESAUT, B4A_NUMAUT, B4A_NOMUSR, B4A_OPEUSR, B4A_CODEMP, B4A_MATRIC, B4A_DATPRO, "
cSql2 += " B4A_TIPREG, B4A_DIGITO, B4A_DATPRO, '12000'  HORA, B4A_CANCEL CANCEL,BBR_TPDIRP, '"+cSetben+ "' X," +RetSqlName(cAlias2)+".R_E_C_N_O_ IDENLINHA"
cSql2 += " FROM " +  RetSqlName("B4A")
cSql2 += " LEFT JOIN " + RetSqlName(AliasInt)
cSql2 += " ON  B4A_OPEMOV = BBR_CODOPE"
cSql2 += " AND B4A_ANOAUT = BBR_ANOAUT"
cSql2 += " AND B4A_MESAUT = BBR_MESAUT"
cSql2 += " AND B4A_NUMAUT = BBR_NUMAUT"
cSql2 += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

if lAliB4Q

	If (B4Q->(FieldPos("B4Q_STTISS")) > 0)
		cSql3 += " SELECT '11' TIPO, B4Q_STTISS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO, "
	Else
		cSql3 += " SELECT '11' TIPO, B4Q_STATUS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO, "
	EndIf

	cSql3 += " B4Q_TIPREG, B4Q_DIGITO, B4Q_DATPRO, '12000'  HORA, B4Q_CANCEL CANCEL,BBR_TPDIRP, '"+cSetben+ "' X," +RetSqlName(cAlias3)+".R_E_C_N_O_ IDENLINHA"
	cSql3 += " FROM " +  RetSqlName("B4Q")
	cSql3 += " LEFT JOIN " + RetSqlName(AliasInt)
	cSql3 += " ON  B4Q_OPEMOV = BBR_CODOPE"
	cSql3 += " AND B4Q_ANOAUT = BBR_ANOAUT"
	cSql3 += " AND B4Q_MESAUT = BBR_MESAUT"
	cSql3 += " AND B4Q_NUMAUT = BBR_NUMAUT"
	cSql3 += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

endIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere  += " WHERE BEA_FILIAL = '" + xFilial(cAlias) + "' AND BEA_TIPO <> '3' "
cWhere1 += " WHERE BE4_FILIAL = '" + xFilial(cAlias1) + "' "
cWhere2 += " WHERE B4A_FILIAL = '" + xFilial(cAlias2) + "' "

if lAliB4Q
	cWhere3 += " WHERE B4Q_FILIAL = '" + xFilial(cAlias3) + "' "
endIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	Do Case
	case aWhere[1] == 'Field_TPGUIA' .and. len(aWhere)>1
		cWhere += " AND BEA_TIPO = '" + aWhere[2] + "' "
		IIF (aWhere[2] <> '3', aInt := {.T.,.F.}, aInt := {.T.,.T.})//cWhere2 += " AND BEA_TIPO = '" + aWhere[2] + "' "  //Nใo Existe tipo na BE4
		IF (aWhere[2] $ '7,8,9')
			IIF (aWhere[2] == '7', aWhere[2] := '07', IIF(aWhere[2] == '8', aWhere[2] := '08', aWhere[2] := '09'))
		ENDIF
		cWhere2 += " AND B4A_TIPGUI = '" + aWhere[2] + "' "

	case aWhere[1] == 'Field_NUMGUI' .and. len(aWhere)>1
		cWhere  += " AND BEA_OPEMOV = '" + Left(aWhere[2],4) + "' AND BEA_ANOAUT = '" + Substr(aWhere[2],5,4) + "' AND BEA_MESAUT = '" + Substr(aWhere[2],9,2) + "' AND BEA_NUMAUT = '" + Right(aWhere[2],8) + "' "
		cWhere1 += " AND BE4_CODOPE = '" + Left(aWhere[2],4) + "' AND BE4_ANOINT = '" + Substr(aWhere[2],5,4) + "' AND BE4_MESINT = '" + Substr(aWhere[2],9,2) + "' AND BE4_NUMINT = '" + Right(aWhere[2],8) + "' "
		cWhere2 += " AND B4A_OPEMOV = '" + Left(aWhere[2],4) + "' AND B4A_ANOAUT = '" + Substr(aWhere[2],5,4) + "' AND B4A_MESAUT = '" + Substr(aWhere[2],9,2) + "' AND B4A_NUMAUT = '" + Right(aWhere[2],8) + "' "
		cWhere3 += iif(lAliB4Q, " AND B4Q_OPEMOV = '" + Left(aWhere[2],4) + "' AND B4Q_ANOAUT = '" + Substr(aWhere[2],5,4) + "' AND B4Q_MESAUT = '" + Substr(aWhere[2],9,2) + "' AND B4Q_NUMAUT = '" + Right(aWhere[2],8) + "' ", "")

	case aWhere[1] == 'Field_DTSOLIC' .and. len(aWhere)>1
		cWhere  += " AND BEA_DATPRO = '" + dtos(ctod(aWhere[2])) + "' "
		cWhere1 += " AND (BE4_DATPRO = '" + dtos(ctod(aWhere[2])) + "' OR  BE4_DTDIGI = '" + dtos(ctod(aWhere[2])) + "') "
		cWhere2 += " AND B4A_DATPRO = '" + dtos(ctod(aWhere[2])) + "' "
		cWhere3 += iif(lAliB4Q, " AND B4Q_DATPRO = '" + dtos(ctod(aWhere[2])) + "' ", "")

	case aWhere[1] == 'Field_STATUS' .and. len(aWhere)>1
		cWhere  += " AND BEA_STTISS = '" + aWhere[2] + "' "
		cWhere1 += " AND BE4_STTISS = '" + aWhere[2] + "' "
		cWhere2 += " AND B4A_STTISS = '" + aWhere[2] + "' "

		If lAliB4Q

			If (B4Q->(FieldPos("B4Q_STTISS")) > 0)
				cWhere3 += " AND B4Q_STTISS = '" + aWhere[2] + "' "
			Else
				cWhere3 += " AND B4Q_STATUS = '" + aWhere[2] + "' "
			EndIf
		EndIf

	case aWhere[1] == 'Field_BENEF' .and. len(aWhere)>1
		cWhere  += " AND BEA_OPEUSR = '" + Left(aWhere[2],4) + "' AND BEA_CODEMP = '" + Substr(aWhere[2],5,4) + "' AND BEA_MATRIC = '" + Substr(aWhere[2],9,6) + "' AND BEA_TIPREG = '" + Substr(aWhere[2],15,2) + "' AND BEA_DIGITO = '" + Right(aWhere[2],1) + "' "
		cWhere1 += " AND BE4_OPEUSR = '" + Left(aWhere[2],4) + "' AND BE4_CODEMP = '" + Substr(aWhere[2],5,4) + "' AND BE4_MATRIC = '" + Substr(aWhere[2],9,6) + "' AND BE4_TIPREG = '" + Substr(aWhere[2],15,2) + "' AND BE4_DIGITO = '" + Right(aWhere[2],1) + "' "
		cWhere2 += " AND B4A_OPEUSR = '" + Left(aWhere[2],4) + "' AND B4A_CODEMP = '" + Substr(aWhere[2],5,4) + "' AND B4A_MATRIC = '" + Substr(aWhere[2],9,6) + "' AND B4A_TIPREG = '" + Substr(aWhere[2],15,2) + "' AND B4A_DIGITO = '" + Right(aWhere[2],1) + "' "
		cWhere3 += iif(lAliB4Q, " AND B4Q_OPEUSR = '" + Left(aWhere[2],4) + "' AND B4Q_CODEMP = '" + Substr(aWhere[2],5,4) + "' AND B4Q_MATRIC = '" + Substr(aWhere[2],9,6) + "' AND B4Q_TIPREG = '" + Substr(aWhere[2],15,2) + "' AND B4Q_DIGITO = '" + Right(aWhere[2],1) + "' ","")

	case aWhere[1] == 'Field_CANCEL' .and. len(aWhere)>1
		cWhere  += " AND BEA_CANCEL = '" + aWhere[2] + "' "
		cWhere1 += " AND BE4_CANCEL = '" + aWhere[2] + "' "
		cWhere2 += " AND B4A_CANCEL = '" + aWhere[2] + "' "
		cWhere3 += iif(lAliB4Q, " AND B4Q_CANCEL = '" + aWhere[2] + "' ","")

	case aWhere[1] == 'Field_ANX' .and. len(aWhere)>1
		cWhere  += " AND BBR_TPDIRP = '" + aWhere[2] + "' OR BBR_TPDIRP = 'A' "
		cWhere1 += " AND BBR_TPDIRP = '" + aWhere[2] + "' OR BBR_TPDIRP = 'A'  "
		cWhere2 += " AND BBR_TPDIRP = '" + aWhere[2] + "' OR BBR_TPDIRP = 'A'  "
		cWhere3 += iif(lAliB4Q, " AND BBR_TPDIRP = '" + aWhere[2] + "' OR BBR_TPDIRP = 'A'  ","")
	EndCase
Next

IF (!aInt[1] .AND. !aInt[2])

	cSql := cSql + cWhere +   " AND "+ RetSqlName("BEA")+".D_E_L_E_T_ = ' ' " "
	cSql += " GROUP BY  BEA_TIPO, BEA_STTISS, BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT, BEA_NOMUSR, BEA_OPEUSR, BEA_CODEMP, BEA_MATRIC, BEA_HORPRO,"
	cSql += " BEA_TIPREG, BEA_DIGITO, BEA_DATPRO, BEA_HHDIGI, BEA_CANCEL, BBR_TPDIRP, " + RetSqlName("BEA")+".R_E_C_N_O_"

	cSql += " UNION " + cSql1 + cWhere1 + " AND "+RetSqlName("BE4")+".D_E_L_E_T_ = ' '"
	cSql += " GROUP BY BE4_STTISS, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, BE4_NOMUSR, BE4_OPEUSR, BE4_CODEMP, BE4_MATRIC, BE4_DATPRO,"
	cSql += " BE4_TIPREG, BE4_DIGITO, BE4_DATPRO, BE4_HHDIGI, BE4_CANCEL, BBR_TPDIRP, " + RetSqlName("BE4")+".R_E_C_N_O_ "

	cSql += " UNION " + cSql2 + cWhere2 + " AND " + RetSqlName("B4A")+".D_E_L_E_T_ = ' '"
	cSql += " GROUP BY B4A_TIPGUI, B4A_STTISS, B4A_OPEMOV, B4A_ANOAUT, B4A_MESAUT, B4A_NUMAUT, B4A_NOMUSR, B4A_OPEUSR, B4A_CODEMP, B4A_MATRIC, B4A_DATPRO,"
	cSql += " B4A_TIPREG, B4A_DIGITO, B4A_DATPRO, B4A_CANCEL, BBR_TPDIRP, " + RetSqlName("B4A")+".R_E_C_N_O_ "

	if lAliB4Q
		cSql += " UNION " + cSql3 + cWhere3 + " AND " + RetSqlName("B4Q")+".D_E_L_E_T_ = ' '"

		If (B4Q->(FieldPos("B4Q_STTISS")) > 0)
			cSql += " GROUP BY B4Q_STTISS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO,"
		Else
			cSql += " GROUP BY B4Q_STATUS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO,"
		EndIf

		cSql += " B4Q_TIPREG, B4Q_DIGITO, B4Q_DATPRO, B4Q_CANCEL, BBR_TPDIRP, " + RetSqlName("B4Q")+".R_E_C_N_O_ "
	endIf

ELSEIF (aInt[1] .AND. !aInt[2])

	cSql := cSql + cWhere +  " AND "+ RetSqlName("BEA")+".D_E_L_E_T_ = ' '
	cSql += " GROUP BY  BEA_TIPO, BEA_STTISS, BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT, BEA_NOMUSR, BEA_OPEUSR, BEA_CODEMP, BEA_MATRIC, BEA_HORPRO,"
	cSql += " BEA_TIPREG, BEA_DIGITO, BEA_DATPRO, BEA_HHDIGI, BEA_CANCEL, BBR_TPDIRP, " + RetSqlName("BEA")+".R_E_C_N_O_ "

	cSql += " UNION " + cSql2 + cWhere2 + " AND " + RetSqlName("B4A")+".D_E_L_E_T_ = ' '"
	cSql += " GROUP BY B4A_TIPGUI, B4A_STTISS, B4A_OPEMOV, B4A_ANOAUT, B4A_MESAUT, B4A_NUMAUT, B4A_NOMUSR, B4A_OPEUSR, B4A_CODEMP, B4A_MATRIC, B4A_DATPRO,"
	cSql += " B4A_TIPREG, B4A_DIGITO, B4A_DATPRO, B4A_CANCEL, BBR_TPDIRP, " + RetSqlName("B4A")+".R_E_C_N_O_ "

	if lAliB4Q

		cSql += " UNION " + cSql3 + cWhere3 + " AND " + RetSqlName("B4Q")+".D_E_L_E_T_ = ' '"

		If (B4Q->(FieldPos("B4Q_STTISS")) > 0)
			cSql += " GROUP BY B4Q_STTISS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO,"
		Else
			cSql += " GROUP BY B4Q_STATUS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO,"
		EndIf

		cSql += " B4Q_TIPREG, B4Q_DIGITO, B4Q_DATPRO, B4Q_CANCEL, BBR_TPDIRP, " + RetSqlName("B4Q")+".R_E_C_N_O_ "
	endIf

ELSEIF (aInt[1] .AND. aInt[2])

	cSql := cSql + cWhere +  " AND "+ RetSqlName("BEA")+".D_E_L_E_T_ = ' '"
	cSql += " GROUP BY  BEA_TIPO, BEA_STTISS, BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT, BEA_NOMUSR, BEA_OPEUSR, BEA_CODEMP, BEA_MATRIC, BEA_HORPRO,"
	cSql += " BEA_TIPREG, BEA_DIGITO, BEA_DATPRO, BEA_HHDIGI, BEA_CANCEL, BBR_TPDIRP, " + RetSqlName("BEA")+".R_E_C_N_O_ "

	cSql += " UNION " + cSql1 + cWhere1 + " AND "+RetSqlName("BE4")+".D_E_L_E_T_ = ' '"
	cSql += " GROUP BY BE4_STTISS, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, BE4_NOMUSR, BE4_OPEUSR, BE4_CODEMP, BE4_MATRIC, BE4_DATPRO,"
	cSql += " BE4_TIPREG, BE4_DIGITO, BE4_DATPRO, BE4_HHDIGI, BE4_CANCEL, BBR_TPDIRP, " + RetSqlName("BE4")+".R_E_C_N_O_ "

	cSql += " UNION " + cSql2 + cWhere2 + " AND " + RetSqlName("B4A")+".D_E_L_E_T_ = ' '"
	cSql += " GROUP BY B4A_TIPGUI, B4A_STTISS, B4A_OPEMOV, B4A_ANOAUT, B4A_MESAUT, B4A_NUMAUT, B4A_NOMUSR, B4A_OPEUSR, B4A_CODEMP, B4A_MATRIC, B4A_DATPRO,"
	cSql += " B4A_TIPREG, B4A_DIGITO, B4A_DATPRO, B4A_CANCEL, BBR_TPDIRP, " + RetSqlName("B4A")+".R_E_C_N_O_ "

	if lAliB4Q
		cSql += " UNION " + cSql3 + cWhere3 + " AND " + RetSqlName("B4Q")+".D_E_L_E_T_ = ' '"

		If (B4Q->(FieldPos("B4Q_STTISS")) > 0)
			cSql += " GROUP BY B4Q_STTISS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO,"
		Else
			cSql += " GROUP BY B4Q_STATUS, B4Q_OPEMOV, B4Q_ANOAUT, B4Q_MESAUT, B4Q_NUMAUT, B4Q_NOMUSR, B4Q_OPEUSR, B4Q_CODEMP, B4Q_MATRIC, B4Q_DATPRO,"
		EndIf

		cSql += " B4Q_TIPREG, B4Q_DIGITO, B4Q_DATPRO, B4Q_CANCEL, BBR_TPDIRP, " + RetSqlName("B4Q")+".R_E_C_N_O_ "
	endIf

ENDIF
RestArea(aArea)
if lAliB4Q
	aRet := {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",cAlias1,cSql1,cWhere1,.T.," ",cAlias2,cSql2,cWhere2,aCmpSub,cAlias3,cSql3,cWhere3 }
else
	aRet := {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",cAlias1,cSql1,cWhere1,.T.," ",cAlias2,cSql2,cWhere2,aCmpSub }
endIf

return( aRet )

/*/
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWRPG  บAutor: Renan Martins           Data ณ  20/01/2014บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os Procedimentos da Guia selecionada.          	    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
/*/
User Function PLBRWRPG()
LOCAL aArea 		:= getArea()
LOCAL nI			:= 0
Local cSetben		:= AllTrim(GetNewPar("MV_SETORBF", .F.))
LOCAL nRegPagina	:= 30
LOCAL cAlias  	    := "BE2"
Local cAlias1		:= "BEJ"
Local cAlias2		:= "B4C"
Local cAlias3		:= "BQV"
LOCAL cCampos 	    := "0#Informa็๕es=BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN+TABELA,1#Anexo=BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN+TABELA+BBR_TPDIRP+BBR_SETOR+X,Situa็ใo=BE2_STATUS,C๓d. Proced.=BE2_CODPRO,Procedimento=BE2_DESPRO,CTR=BBR_TPDIRP+BBR_SETOR+X,2*#Crํticas=BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN+CHR(126)+TABELA"
LOCAL cSql 	  		:= ""
LOCAL cSql1 	  	:= ""
LOCAL cSql2 	  	:= ""
LOCAL cSql3 	  	:= ""
LOCAL cWhere  		:= ""
LOCAL cWhere1  		:= ""
LOCAL cWhere2  		:= ""
LOCAL cWhere3  		:= ""
LOCAL cFieldJ		:= ""
LOCAL aPar  		:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  		:= {}
Local cAliasInt		:= "BBR"
lOCAL aCmpSub		:={}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Query para retornar dados
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cSql  := " SELECT BE2_TIPO TIPOG, BE2_OPEMOV, BE2_ANOAUT, BE2_MESAUT, BE2_NUMAUT, BE2_CODPRO, '"+cSetben+ "' X,"
cSql  += " BE2_DESPRO, (CASE WHEN BE2_AUDITO = '1' THEN '8' ELSE BE2_STATUS END) as BE2_STATUS, BE2_AUDITO, 'BE2' TABELA, BE2_SEQUEN, "+RetSqlName(cAlias)+".R_E_C_N_O_ RECNO, BBR_TPDIRP, BBR_SETOR "
cSql  += " FROM " + RetSQLName(cAlias)
cSql  += " LEFT JOIN " + RetSqlName(cAliasInt)
cSql  += " ON  BE2_FILIAL = BBR_FILIAL"
cSql  += " AND BE2_OPEMOV = BBR_CODOPE"
cSql  += " AND BE2_ANOAUT = BBR_ANOAUT"
cSql  += " AND BE2_MESAUT = BBR_MESAUT"
cSql  += " AND BE2_NUMAUT = BBR_NUMAUT"
cSql  += " AND BE2_SEQUEN = BBR_SEQPRO"
cSql  += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

cSql1 := " SELECT '' TIPOG, BEJ_CODOPE, BEJ_ANOINT, BEJ_MESINT, BEJ_NUMINT, BEJ_CODPRO, '"+cSetben+ "' X,"
cSql1 += " BEJ_DESPRO,  (CASE WHEN BEJ_AUDITO = '1' THEN '8' ELSE BEJ_STATUS END) as BEJ_STATUS, BEJ_AUDITO, 'BEJ' TABELA, BEJ_SEQUEN, "+RetSqlName(cAlias1)+".R_E_C_N_O_ RECNO, BBR_TPDIRP, BBR_SETOR "                                                           
cSql1 += " FROM " + RetSQLName(cAlias1)
cSql1 += " LEFT JOIN " + RetSqlName(cAliasInt)
cSql1 += " ON  BEJ_FILIAL = BBR_FILIAL"
cSql1 += " AND BEJ_CODOPE = BBR_CODOPE"
cSql1 += " AND BEJ_ANOINT = BBR_ANOAUT"
cSql1 += " AND BEJ_MESINT = BBR_MESAUT"
cSql1 += " AND BEJ_NUMINT = BBR_NUMAUT"
cSql1 += " AND BEJ_SEQUEN = BBR_SEQPRO"
cSql1 += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

cSql2 := " SELECT '' TIPOG, B4C_OPEMOV, B4C_ANOAUT, B4C_MESAUT, B4C_NUMAUT, B4C_CODPRO, '"+cSetben+ "' X,"
cSql2 += " B4C_DESPRO,(CASE WHEN B4C_AUDITO = '1' THEN '8' ELSE B4C_STATUS END) as B4C_STATUS, B4C_AUDITO, 'B4C' TABELA, B4C_SEQUEN, "+RetSqlName(cAlias2)+".R_E_C_N_O_ RECNO, BBR_TPDIRP, BBR_SETOR "
cSql2 += " FROM " + RetSQLName(cAlias2)
cSql2 += " LEFT JOIN " + RetSqlName(cAliasInt)
cSql2 += " ON  B4C_FILIAL = BBR_FILIAL"
cSql2 += " AND B4C_OPEMOV = BBR_CODOPE"
cSql2 += " AND B4C_ANOAUT = BBR_ANOAUT"
cSql2 += " AND B4C_MESAUT = BBR_MESAUT"
cSql2 += " AND B4C_NUMAUT = BBR_NUMAUT"
cSql2 += " AND B4C_SEQUEN = BBR_SEQPRO"
cSql2 += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

cSql3 := " SELECT '' TIPOG, BQV_CODOPE, BQV_ANOINT, BQV_MESINT, BQV_NUMINT, BQV_CODPRO, '"+cSetben+ "' X,"
cSql3 += " BQV_DESPRO,  (CASE WHEN BQV_AUDITO = '1' THEN '8' ELSE BQV_STATUS END) as BQV_STATUS , BQV_AUDITO, 'BQV' TABELA, BQV_SEQUEN, "+RetSqlName(cAlias3)+".R_E_C_N_O_ RECNO, BBR_TPDIRP, BBR_SETOR "
cSql3 += " FROM " + RetSQLName(cAlias3)
cSql3 += " LEFT JOIN " + RetSqlName(cAliasInt)
cSql3 += " ON  BQV_FILIAL = BBR_FILIAL"
cSql3 += " AND BQV_CODOPE = BBR_CODOPE"
cSql3 += " AND BQV_ANOINT = BBR_ANOAUT"
cSql3 += " AND BQV_MESINT = BBR_MESAUT"
cSql3 += " AND BQV_NUMINT = BBR_NUMAUT"
cSql3 += " AND BQV_SEQUEN = BBR_SEQPRO"
cSql3 += " AND " + RetSqlName("BBR")+".D_E_L_E_T_ = ' ' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere  += " WHERE BE2_FILIAL = '" + xFilial(cAlias) + "' AND BE2_TIPO <> '3' "
cWhere1 += " WHERE BEJ_FILIAL = '" + xFilial(cAlias1) + "' "
cWhere2 += " WHERE B4C_FILIAL = '" + xFilial(cAlias2) + "' "
cWhere3 += " WHERE BQV_FILIAL = '" + xFilial(cAlias3) + "' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
for nI:=1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	Do Case
		case aWhere[1] == 'Field_NUMGUI' .and. len(aWhere)>1
			cWhere  += " AND BE2_OPEMOV = '" + Left(aWhere[2],4) + "' AND BE2_ANOAUT ='" + Substr(aWhere[2],5,4) + "' AND BE2_MESAUT = '" + Substr(aWhere[2],9,2) + "' AND BE2_NUMAUT = '" + Right(aWhere[2],8) + "' "
			cWhere1 += " AND BEJ_CODOPE = '" + Left(aWhere[2],4) + "' AND BEJ_ANOINT ='" + Substr(aWhere[2],5,4) + "' AND BEJ_MESINT = '" + Substr(aWhere[2],9,2) + "' AND BEJ_NUMINT = '" + Right(aWhere[2],8) + "' "
			cWhere2 += " AND B4C_OPEMOV = '" + Left(aWhere[2],4) + "' AND B4C_ANOAUT ='" + Substr(aWhere[2],5,4) + "' AND B4C_MESAUT = '" + Substr(aWhere[2],9,2) + "' AND B4C_NUMAUT = '" + Right(aWhere[2],8) + "' "
			cWhere3 += " AND BQV_CODOPE = '" + Left(aWhere[2],4) + "' AND BQV_ANOINT ='" + Substr(aWhere[2],5,4) + "' AND BQV_MESINT = '" + Substr(aWhere[2],9,2) + "' AND BQV_NUMINT = '" + Right(aWhere[2],8) + "' "
	EndCase
Next

cSql := cSql + cWhere + " AND "+ RetSqlName("BE2")+".D_E_L_E_T_ = ' ' UNION " + cSql1 + cWhere1 + " AND "+ RetSqlName("BEJ")+".D_E_L_E_T_ = ' ' UNION " + cSql2 + cWhere2 +  " AND "+ RetSqlName("B4C")+".D_E_L_E_T_ = ' ' UNION " + cSql3 + cWhere3 +  " AND "+ RetSqlName("BQV")+".D_E_L_E_T_ = ' '"

RestArea(aArea)
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",cAlias1,cSql1,cWhere1,.T.," ",cAlias2,cSql2,cWhere2,aCmpSub,cAlias3,cSql3,cWhere3 } )

//QUERY QUE HAVIA AQUI FOI APAGADA POIS SE ENCONTRA EM OUTRO PONTO DO FONTE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBBABBw  บAutor  ณTotvs               บ Data ณ  16/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca os Beneficiแrios e os opcionais da solicita็ใo.	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBBABBW()
Local aArea			:= getArea()
Local nRegPagina	:= 15
Local cAlias		:= "BBW"
Local cCampos		:= "Beneficiแrio=BA1_NOMUSR, Opcional=BI3_DESCRI, Versใo=BI3_VERSAO"
Local cSql			:= ""
Local cWhere		:= ""
Local cFieldJ		:= ""
Local aPar			:= strToArray( paramixb[1] , '|' )

cSql:="SELECT BA1_NOMUSR, BI3_DESCRI, BI3_VERSAO, "+RetSQLName(cAlias)+".R_E_C_N_O_ RECNO "
cSql+=" FROM "  +RetSQLName("BBW")

cWhere+=" INNER JOIN "+RetSQLName("BBA")
cWhere+=" ON(BBA_CODSEQ = BBW_CODSOL) "
cWhere+=" INNER JOIN "+RetSQLName("BA1")

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cWhere+=" ON(BBW_MATRIC =(BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO)) "
Else
	cWhere+=" ON(BBW_MATRIC =(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)) "
EndIf

cWhere+=" INNER JOIN "+RetSQLName("BRP")
cWhere+=" ON(BRP_CODIGO = BA1_GRAUPA) "
cWhere+=" INNER JOIN "+  RetSQLName("BI3")
cWhere+=" ON(BI3_CODIGO = BBW_CODOPC AND BI3_VERSAO = BBW_VEROPC) "
cWhere+=" WHERE "

cWhere+=" BBW_FILIAL = '"+xFilial("BBW")+"' "
cWhere+=" AND BBA_FILIAL = '"+xFilial("BBA")+"' "
cWhere+=" AND BA1_FILIAL = '"+xFilial("BA1")+"' "
cWhere+=" AND BRP_FILIAL = '"+xFilial("BRP")+"' "
cWhere+=" AND BI3_FILIAL = '"+xFilial("BI3")+"' "

cWhere+="   AND "+RetSQLName("BBW")+    ".D_E_L_E_T_ = ' ' "
cWhere+="   AND "+RetSQLName("BBA")+    ".D_E_L_E_T_ = ' ' "
cWhere+="   AND "+RetSQLName("BA1")+    ".D_E_L_E_T_ = ' ' "
cWhere+="   AND "+RetSQLName("BRP")+    ".D_E_L_E_T_ = ' ' "
cWhere+="   AND "+RetSQLName("BI3")+    ".D_E_L_E_T_ = ' ' "

//aPar[1] = c๓digo da solicita็ใo
cWhere+=" AND BBW_CODSOL = '"+ aPar[1] + "' "

cSql := cSql + cWhere

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBC1  บAutor  ณTotvs               บ Data ณ  15/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de Corpo Clinico	                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWBC1()
LOCAL aArea 	    := getArea()
LOCAL nRegPagina  	:= 30
LOCAL cAlias  		:= "BC1"
LOCAL cCampos 		:= "0#Bloqueia=RECNO,?=BC1_CODPRF,?=BC1_SIGLCR,?=BC1_NUMCR,?=BC1_NOMPRF "
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ	   	:= ""
LOCAL aPar  	   	:= strToArray( paramixb[1] , '|' )

cSql :=  " SELECT BC1_CODPRF, BC1_SIGLCR, BC1_NUMCR, BC1_NOMPRF, R_E_C_N_O_ RECNO "
cSql +=    " FROM " + RetSQLName("BC1")
cWhere := " WHERE BC1_FILIAL = '" + xFilial("BC1") + "' "
cWhere += "	 AND BC1_CODINT = '" + PLSINTPAD() + "' "
cWhere += "	 AND BC1_CODIGO = '" + aPar[2] + "'"
cWhere += "	 AND BC1_CODESP = '" + aPar[4] + "'"
cWhere += "	 AND BC1_CODLOC = '" + aPar[5] + "'"
cWhere +=   " AND (BC1_DATBLO = ' ' OR BC1_DATBLO > '" + DTOS(dDataBase) + "')"	//	Sem Bloqueio OU Maior que Hoje
cWhere +=   " AND D_E_L_E_T_ = ' ' "
cSql += cWhere + " ORDER BY BC1_NOMPRF "
RestArea(aArea)

return({cAlias, cSql, cWhere, nRegPagina, cCampos, cFieldJ})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWCAPT บAutor  ณRodrigo Morgon      บ Data ณ  30/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de visitas de captacao                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBRWCAPT()
LOCAL aArea 		:= getArea()
LOCAL nI			:= 0
LOCAL nRegPagina	:= 30
LOCAL cAlias  		:= "B9P"
LOCAL cCampos 		:= "Cidade=DESCRI,Nome=B9P_PRESTA,Especialidade=BAQ_DESCRI,Contato=B9P_NOMCON,Endere็o=B9V_ENDER,Data da Visita=B9P_DATAVI,0#Observa็ใo=RECNO"
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ		:= ""
Local cAuxSql1   	:=  ""
Local cAuxSql2   	:=  ""
LOCAL aPar  		:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  		:= {}

//Busca por parโmetros passados no portal.
For nI := 1 to len(aPar)
	aadd(aWhere,SEPARA(aPar[nI], "="))
Next

cAuxSql1 	:= "SELECT BID_DESCRI AS DESCRI,B9P_DATAVI,B9P_PRESTA,BAQ_DESCRI,B9P_NOMCON,B9V_ENDER," + RetSQLName("B9P")+".R_E_C_N_O_ AS RECNO "
cAuxSql1 	+= " FROM " + RetSQLName("B9P")

cWhere 	:= " INNER JOIN " + RetSQLName("B9V") + " ON B9V_CODPRO = B9P_CODPRO AND B9V_FILIAL = '" + xFilial("B9V") + "' AND "+RetSQLName("B9V")+".D_E_L_E_T_ = ' ' " + IIF(!EMPTY(allTrim(aWhere[3][2])),"AND B9V_CODCID = '" + aWhere[3][2] + "'","")
cWhere 	+= " INNER JOIN " + RetSQLName("B9Q") + " ON B9Q_CODPRO = B9P_CODPRO AND B9Q_FILIAL = '" + xFilial("B9Q") + "' AND "+RetSQLName("B9Q")+".D_E_L_E_T_ = ' '"
cWhere 	+= " INNER JOIN " + RetSQLName("BAQ") + " ON BAQ_CODESP = B9Q_CODESP AND BAQ_CODINT = B9Q_CODINT AND BAQ_FILIAL = '" + xFilial("BAQ") + "' AND "+RetSQLName("BAQ")+".D_E_L_E_T_ = ' ' " + IIF(!EMPTY(allTrim(aWhere[5][2])),"AND BAQ_DESCRI LIKE '%" + aWhere[5][2] + "%'","")
cWhere 	+= " INNER JOIN " + RetSQLName("BID") + " ON BID_CODMUN = B9V_CODCID AND BID_FILIAL = '" + xFilial("BID") + "'"

cWhere 	+= " WHERE "
cWhere		+= RetSQLName("B9P")+".D_E_L_E_T_ = ' ' " 						//Filtra apenas dados que nใo foram deletados de forma l๓gica na tabela
cWhere 	+= " AND B9P_FILIAL = '" + xFilial("B9P") + "'" 					//Filtra dados da filial atual
cWhere 	+= " AND B9P_CODINT = '" + PLSINTPAD() + "'"						//Filtra dados da operadora atualmente selecionada
if(!EMPTY(allTrim(aWhere[1][2])))
	cWhere 	+= " AND B9P_DATAVI >= '" + dtos(ctod(aWhere[1][2])) + "'"	//Filtra dados de acordo com a "DATA DE", caso esse parโmetro seja fornecido
endif
if(!EMPTY(allTrim(aWhere[2][2])))
	cWhere 	+= " AND B9P_DATAVI <= '" + dtos(ctod(aWhere[2][2])) + "'"	//Filtra dados de acordo com a "DATA ATE", caso esse parโmetro seja fornecido
endif
if(!EMPTY(allTrim(aWhere[4][2])))
	cWhere 	+= " AND B9P_PRESTA LIKE '%" + 	AllTrim(aWhere[4][2]) + "%'" //Filtra dados de acordo com o "NOME DO PRESTADOR", caso esse parโmetro seja fornecido
endif

cSql := cAuxSql1 +cAuxSql2+ cWhere

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLAC9ACB  บAutor  ณTotvs               บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBanco de conhecimento                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLAC9ACB()
LOCAL aArea 	:= getArea()
LOCAL nRegPagina:= 50
LOCAL cAlias  	:= "AC9"
LOCAL cCampos 	:= "Anexo=ACB_OBJETO" + iif( AT( "excluir", paramixb[1] ) > 0, ",0*#Excluir=STR(RECNO)", "" ) + iif( AT( "baixarArquivo", paramixb[1] ) > 0, ",1*#Download=STR(RECNO)", "" )
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= Separa( paramixb[1] , '|' )
Local cTabela	:= IIF( Len(aPar) < 2, "", aPar[2])
Local cChave	:= xFilial(cTabela) + IIF(Len(aPar) < 1, "", aPar[1])
Local cAC9 		:= RetSQLName("AC9")
Local cACB 		:= RetSQLName("ACB")
Local cNoCompl 	:= iIf( Len(aPar) >= 3 .and. ! empty(aPar[3]), aPar[3], "")

cSql := "  SELECT " + cAC9 + ".R_E_C_N_O_ IDENLINHA, " + cAC9 + ".R_E_C_N_O_ RECNO, "
cSql += "         ACB_CODOBJ,  ACB_OBJETO, AC9_CODOBJ, AC9_ENTIDA, AC9_CODENT "
cSql += "    FROM " + cACB + " JOIN " + cAC9
cSql += "	   ON ACB_FILIAL = '" + xFilial("ACB") + "' "
cSql += "     AND ACB_CODOBJ = AC9_CODOBJ "
cSql += "     AND " + cACB + ".D_E_L_E_T_ = ' ' "

if ! empty(cNoCompl)
	cSql += " AND ACB_OBJETO LIKE '%_" + RC4Crypt(cNoCompl, '123456789') + "%' "
endIf

cWhere := "	 WHERE AC9_FILIAL = '" + xFilial("AC9") + "' "
cWhere += "    AND AC9_ENTIDA = '" + cTabela + "' "
cWhere += "    AND AC9_CODENT = '" + cChave  + "' "
cWhere += "    AND " + cAC9 + ".D_E_L_E_T_ = ' ' "

cSql += cWhere

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWOPC	บAutor  ณFแbio S. dos Santos บ Data ณ  04/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa busca de opcionais.			                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWOPC()
Local aArea 		:= GetArea()
Local nI			:= 0
Local nRegPagina	:= 5
Local cAlias  		:= "BI3"
Local cCampos 		:= "C๓digo=BI3_CODIGO,Versใo=BI3_VERSAO,Opcional=BI3_DESCRI"
Local cSql 	  		:= ""
Local cWhere  		:= ""
Local cFieldJ		:= "" //utilizado quando tem join com outras tabelas
Local cAuxSql1   	:= ""
Local aPar  		:= iif(!Empty(Paramixb[1]), strToArray( Paramixb[1] , '|' ), {})
Local aWhere  		:= {}
Local cMatric := ""
Local cCodPla := ""
Local cVersao := ""
Local cCodInt := plsintpad()
Local cClasses := ""
Local cBI3 := RetSQLName("BI3")
Local cBT3 := RetSQLName("BT3")
Local cBE5 := RetSQLName("BE5")
//Busca por parโmetros passados no portal.
for nI := 1 to Len(aPar)
	aadd(aWhere,SEPARA(aPar[nI], "="))
next

if(len(aWhere)>0)

	BA3->(dbSetOrder(1))
	if(len(aWhere[1][2]) >= 14)
		cMatric := aWhere[1][2]
	else
		B49->(dbSetOrder(1))
		if(B49->(msSeek(xFilial("B49")+aWhere[1][2])))
			cMatric := B49->B49_BENEFI
		endIf
	endIf

	if(BA3->(msSeek(xFilial("BA3")+substr(cMatric, 1, 14))))
		cCodPla := BA3->BA3_CODPLA
		cVersao := BA3->BA3_VERSAO
	endIf

	if(len(aWhere)>1)
		cClasses := aWhere[2][2]
	endIf

endif


cAuxSql1 	:= "SELECT BI3_CODIGO, BI3_VERSAO, BI3_DESCRI
cAuxSql1 	+= " FROM " + cBI3

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cWhere += " INNER JOIN " + cBT3 + " ON((BT3_CODPLA || BT3_VERPLA) = (BI3_CODIGO || BI3_VERSAO)) "
Else
	cWhere += " INNER JOIN " + cBT3 + " ON((BT3_CODPLA + BT3_VERPLA) = (BI3_CODIGO + BI3_VERSAO)) "
EndIf
cWhere  	+= " INNER JOIN " + cBE5 + " ON (BE5_CODGRU = BI3_GRUPO) "

cWhere 	+= " WHERE "
cWhere		+=   cBI3 + ".D_E_L_E_T_ = ' ' AND "
cWhere		+=   cBT3 + ".D_E_L_E_T_ = ' ' "
cWhere 	+= " AND " + cBI3 + ".BI3_FILIAL = '" + xFilial("BI3") + "' " 					//Filtra dados da filial atual
cWhere 	+= " AND " + cBT3 + ".BT3_FILIAL = '" + xFilial("BT3") + "' " 					//Filtra dados da filial atual
cWhere 	+= " AND " + cBE5 + ".BE5_TIPO   = '2' " //GRUPOS DE PRODUTO DO TIPO OPCIONAL
cWhere		+= " AND " + cBT3 + ".BT3_TIPVIN = '0' "
cWhere    	+= " AND " + cBT3 + ".BT3_CODIGO = '" + cCodInt+cCodPla + "' "
cWhere 	+= " AND " + cBT3 + ".BT3_VERSAO = '" + cVersao + "' "

If !Empty(cClasses)
	cWhere += " AND " + cBI3 + ".BI3_CLASSE IN ('" + cClasses + "')"
EndIf

cSql := cAuxSql1 + cWhere

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWBBA  บAutor  ณKarine Riquena Limp บ Data ณ  22/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca de solicita็๕es de opcionais                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWBBA() 
Local aArea 		:= GetArea()
Local nI			:= 0
Local nRegPagina	:= 5
Local cAlias  		:= "BBA"
Local cAliasAux      := ""
Local cCampos 		:= ""
Local cSql 	  		:= ""
Local cWhere  		:= ""
Local cFieldJ		:= ""
Local cAuxSql1   	:= ""
Local aPar  		:= iif(!Empty(paramixb[1]), strToArray( paramixb[1] , '|' ), {})
Local aWhere  		:= {}

//Busca por parโmetros passados no portal.
for nI := 1 to Len(aPar)
	aadd(aWhere,SEPARA(aPar[nI], "="))
next

//foi retirado o if que tinha aqui pois trazia um campo que nใo estava implementado
//O IF FOI RECOLOCADO Nใo retirar
If aWhere[5][2] == "1" //Consulta pela tela de Solicita็ใo de Opcional
	cCampos 		:= "Status=BBA_STATUS,0*#Itens=BBA_CODSEQ+SEP+STR(RECNO),C๓digo=BBA_CODSEQ,Protocolo=BBA_NROPRO,2*#Obs.=BBA_OBSERV,Data Solicita็ใo=BBA_DATSOL,1#Imprimir=RECNO,3*#Anexos=BBA_CODSEQ+SEP+STR(RECNO)"
Else
	cCampos 		:= "Status=BBA_STATUS,0*#Itens=BBA_CODSEQ+SEP+STR(RECNO),Protocolo=BBA_NROPRO,Opera็ใo=BBA_TIPMAN,2*#Obs.=BBA_OBSERV,Data Solicita็ใo=BBA_DATSOL,1#Imprimir=RECNO,3*#Anexos=BBA_CODSEQ+SEP+STR(RECNO)+SEP+BBA_TIPMAN+SEP+BBA_NROPRO" 
EndIf


cAuxSql1 := "SELECT BBA_STATUS,BBA_CODSEQ,BBA_NROPRO,BBA_MATRIC, "
cAuxSql1 += "(CASE BBA_TIPMAN 
cAuxSql1 += "      WHEN '1' THEN 'Inclusใo' "
cAuxSql1 += "      WHEN '2' THEN 'Altera็ใo' "
cAuxSql1 += "      WHEN '3' THEN 'Exclusใo' END) AS BBA_TIPMAN, "
cAuxSql1 += "BBA_OBSERV,BBA_DATSOL, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO, '~' SEP"
cAuxSql1 += " FROM " + RetSQLName("BBA")

if len(aWhere) > 1 .AND. !empty(aWhere[1][2])
	//aPar[1] = tipo do portal
	//aPar[2] = codigo usuario
	//aPar[3] = protocolo
	//aPar[4] = status
	cAliasAux	:= Iif( aWhere[1][2]=="2" ,"B40" ,"B49")
	cWhere += ", " + RetSQLName(cAliasAux)

	cWhere += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cWhere += "   AND " + RetSQLName(cAlias) 	 +	".D_E_L_E_T_ = ' ' "
	cWhere += "   AND " + RetSQLName(cAliasAux) +	".D_E_L_E_T_ = ' ' "

    if(aWhere[1][2] == "2")
   		cWhere += " AND B40_FILIAL = '" + xFilial(cAlias) + "' "
		cWhere += " AND BBA_CODINT = B40_CODINT "
		cWhere += " AND BBA_CODEMP = B40_CODEMP "
		cWhere += " AND BBA_CONEMP = B40_NUMCON "
		cWhere += " AND BBA_VERCON = B40_VERCON "
		cWhere += " AND BBA_SUBCON = B40_SUBCON "
		cWhere += " AND BBA_VERSUB = B40_VERSUB "
    else
    	cWhere += " AND B49_FILIAL = '" + xFilial(cAlias) + "' "
		cWhere += " AND ((BBA_MATRIC = B49_BENEFI) OR (BBA_MATRIC = '" + Space( TamSX3("BBA_MATRIC")[1]) +"' AND BBA_CPFTIT = B49_BENEFI))"
    endif

    if(!empty(aWhere[2][2]))
		cWhere += " AND " + cAliasAux + "_CODUSR = '" + aWhere[2][2] + "' "
	endif

	if(!empty(aWhere[3][2]))
		cWhere += " AND BBA_NROPRO = '" + aWhere[3][2] + "' "
	endif

	if(!empty(aWhere[4][2]))
		cWhere += " AND BBA_STATUS = '" + aWhere[4][2] + "' "
	endif


else
	cWhere += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cWhere += "   AND " + RetSQLName(cAlias) 	 +	".D_E_L_E_T_ = ' ' "					//Filtra dados da filial atual
endif


cSql := cAuxSql1 + cWhere

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBRWITE  บAutor  ณKarine Riquena Limp บ Data ณ  23/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca de itens da solicita็ใo de opcional                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLBRWITE()
Local aArea 		:= GetArea()
Local nI			:= 0
Local nRegPagina	:= 5
Local cAlias  		:= "BBW"
Local cCampos 		:= "Status=BBW_STATUS,Nome=BA1_NOMUSR,Tipo=BA1_TIPOUS,Grau Parentesco=BRP_DESCRI,C๓digo Opc=BI3_CODIGO,Opcional Solic.=BI3_DESCRI,Versใo=BI3_VERSAO,0*#Obs.=BBW_OBSERV"
Local cSql 	  		:= ""
Local cWhere  		:= ""
Local cFieldJ		:= ""
Local cAuxSql1   	:= ""
Local aPar  		:= iif(!Empty(paramixb[1]), strToArray( paramixb[1] , '|' ), {})
Local aWhere  		:= {}
local cCodTit 		:= getNewPar("MV_PLCDTIT", "T")
local cCodDep 		:= getNewPar("MV_PLCDDEP", "D")

//Busca por parโmetros passados no portal.
for nI := 1 to Len(aPar)
	aadd(aWhere,SEPARA(aPar[nI], "="))
next

cAuxSql1 := "SELECT BBW_STATUS, BA1_NOMUSR, CASE BA1_TIPUSU WHEN '" + cCodTit + "' THEN 'Titular' WHEN '" + cCodDep + "' THEN 'Dependente'  END AS BA1_TIPOUS , BRP_DESCRI, BI3_CODIGO, BI3_DESCRI, BI3_VERSAO, BBW_OBSERV , " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO "
cAuxSql1 += " FROM "  + RetSQLName( "BBW" )

cWhere += " INNER JOIN " + RetSQLName( "BBA" )
cWhere += " ON(BBA_CODSEQ = BBW_CODSOL) "
cWhere += " INNER JOIN " + RetSQLName( "BA1" )

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cWhere += " ON(BBW_MATRIC =(BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO)) "
Else
	cWhere += " ON(BBW_MATRIC =(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)) "
EndIf

cWhere += " INNER JOIN " + RetSQLName( "BRP" )
cWhere += " ON(BRP_CODIGO = BA1_GRAUPA) "
cWhere += " INNER JOIN " +  RetSQLName( "BI3" )
cWhere += " ON(BI3_CODIGO = BBW_CODOPC AND BI3_VERSAO = BBW_VEROPC) "
cWhere += " WHERE "

cWhere += " BBW_FILIAL = '" + xFilial( "BBW" ) + "' "
cWhere += " AND BBA_FILIAL = '" + xFilial( "BBA" ) + "' "
cWhere += " AND BA1_FILIAL = '" + xFilial( "BA1" ) + "' "
cWhere += " AND BRP_FILIAL = '" + xFilial( "BRP" ) + "' "
cWhere += " AND BI3_FILIAL = '" + xFilial( "BI3" ) + "' "

cWhere += "   AND " + RetSQLName( "BBW" ) +	".D_E_L_E_T_ = ' ' "
cWhere += "   AND " + RetSQLName( "BBA" ) +	".D_E_L_E_T_ = ' ' "
cWhere += "   AND " + RetSQLName( "BA1" ) +	".D_E_L_E_T_ = ' ' "
cWhere += "   AND " + RetSQLName( "BRP" ) +	".D_E_L_E_T_ = ' ' "
cWhere += "   AND " + RetSQLName( "BI3" ) +	".D_E_L_E_T_ = ' ' "

if len(aWhere) > 1 .AND. !empty(aWhere[1][2])
	//aPar[1] = c๓digo da solicita็ใo
	cWhere += " AND BBW_CODSOL = '" + aWhere[1][2] + "' "
endif

cSql := cAuxSql1 + cWhere


RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSGETBA1	บAutor  ณFแbio S. dos Santos บ Data ณ  05/11/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca os beneficiแrios para o portal empresa.               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLSGETBA1()

Local aArea := GetArea()
Local nI := 0
Local nRegPagina := 30
Local cAlias := "BA1"
Local cCampos := "Matricula=XPTO+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO,Beneficiแrio=BA1_NOMUSR,CPF=BA1_CPFUSR,Data Nascimento=BA1_DATNAS,Tipo=BA1_TIPUSU,0#Editar=STR(RECNO),1#Excluir=STR(RECNO)"
Local cSql := ""
Local cWhere := ""
Local cWhereDb2 := ""
Local cFieldJ := ""
Local aPar := iif(!Empty(paramixb[1]), strToArray( paramixb[1] , '|' ), {})
Local aWhere := {}
Local cCpf := ""
LOCAL cDBase := "ORACLE/DB2/POSTGRES"

If ExistBlock("PLGETBA1")
	cCampos := ExecBlock("PLGETBA1",.F.,.F.,{cCampos})	//	Ponto de Entrada que permite a manipula็ใo da variแvel cCampos
Endif

//Busca por parโmetros passados no portal.
For nI := 1 to Len(aPar)
	aadd(aWhere, SEPARA(aPar[nI], "="))
Next

cSql   := " SELECT BA1_DATBLO, BA1_CODINT XPTO, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_NOMUSR, BA1_CPFUSR, BA1_DATNAS, "
cSql   +=  " (CASE WHEN BA1_TIPUSU = 'T' THEN 'TITULAR' ELSE 'DEPENDENTE' END) AS BA1_TIPUSU, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, R_E_C_N_O_ RECNO "
cSql   +=  " FROM " + RetSQLName(cAlias)
cWhere +=  " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cWhere +=   " AND D_E_L_E_T_ = ' ' "
If(aWhere[1, 1] == "Field_CPF")
	cCpf := aWhere[1][2]
	cCpf := strtran( cCpf, ".", "" ) // retira os pontos
	cCpf := strtran( cCpf, "/", "" ) // retira a barra
	cCpf := strtran( cCpf, "-", "" ) // retira os tra็os
	cWhere +=    " AND BA1_CPFUSR = '" + cCpf + " ') "
Else
	cWhere +=   " AND BA1_CODINT || BA1_CODEMP || BA1_MATRIC = "
	cWhere += "'" + SubStr(aWhere[1, 2], 1, 14) + "' "
EndIf
IF AllTrim(TCGetDB()) $ cDBase
	cWhereDb2 := cWhere
EndIf
//	Beneficiแrios Ativos no dia
cWhere += " AND NOT EXISTS ( "
cWhere +=  " SELECT BLO.BCA_DATA BLOQUE, BLO.BCA_OBS, DES.BCA_DATA DESLBO, DES.BCA_OBS "
cWhere +=   " FROM ( "
cWhere +=    " SELECT "
IF AllTrim(TCGetDB()) == "ORACLE"
	cWhere +=   " ROWNUM "
ELSE
	cWhere +=   " ROW_NUMBER() OVER(ORDER BY BCA_DATA) "
ENDIF
cWhere +=     " SEQBLO, A.* "
cWhere +=     " FROM " + RetSqlName("BCA") + " A "
cWhere +=     " WHERE A.BCA_MATRIC = "
cWhere += "'" + SubStr(aWhere[1, 2], 1, 14) + "' "
IF AllTrim(TCGetDB()) $ cDBase
	cWhere += " AND A.BCA_TIPREG IN (SELECT BA1_TIPREG FROM "+ RetSQLName(cAlias) +" " + cWhereDb2 + ") AND A.BCA_TIPO = '0' AND A.D_E_L_E_T_ = ' ' "
Else
	cWhere += " AND A.BCA_TIPREG = BA1_TIPREG AND A.BCA_TIPO = '0' AND A.D_E_L_E_T_ = ' ' "
EndIF
IF AllTrim(TCGetDB()) $ cDBase
	cWhere +=   " ORDER BY BCA_DATA "
ENDIF
cWhere +=   " ) BLO "
cWhere +=   " INNER JOIN ( "
cWhere +=    " SELECT "
IF AllTrim(TCGetDB())  == "ORACLE"
	cWhere +=   " ROWNUM "
ELSE
	cWhere +=   " ROW_NUMBER() OVER(ORDER BY BCA_DATA) "
ENDIF
cWhere +=     " SEQDES, A.* "
cWhere +=     " FROM " + RetSqlName("BCA") + " A "
cWhere +=     " WHERE A.BCA_MATRIC = "
cWhere += "'" + SubStr(aWhere[1, 2], 1, 14) + "' "
IF AllTrim(TCGetDB()) $ cDBase
    cWhere += " AND A.BCA_TIPREG IN (SELECT BA1_TIPREG FROM "+ RetSQLName(cAlias) +" " + cWhereDb2 + ") AND A.BCA_TIPO = '1' AND A.D_E_L_E_T_ = ' ' "
Else
	cWhere += " AND A.BCA_TIPREG = BA1_TIPREG AND A.BCA_TIPO = '1' AND A.D_E_L_E_T_ = ' ' "
EndIf

IF AllTrim(TCGetDB()) $ cDBase
	cWhere +=   " ORDER BY BCA_DATA "
ENDIF
cWhere +=   " ) DES "
cWhere +=   " ON BLO.SEQBLO = DES.SEQDES "
cWhere +=   " WHERE BLO.BCA_DATA <= '" + DTOS(dDataBase) + "' AND ( DES.BCA_DATA IS NULL OR DES.BCA_DATA >= '" + DTOS(dDataBase) + "' ) "
cWhere += " ) "
cWhere += " AND (BA1_DATBLO = ' ' OR BA1_DATBLO > '" + DTOS(dDataBase) + "' ) "
//

cSql += cWhere + "ORDER BY BA1_TIPUSU DESC "
RestArea(aArea)

Return( {cAlias, cSql, cWhere, nRegPagina, cCampos, cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBBABBP  บAutor  ณTotvs               บ Data ณ  16/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณOpcionais                             							บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PLBBABBP()

LOCAL aArea 	   	:= getArea()
LOCAL nRegPagina 	:= 15
LOCAL cAlias  	:= "BBW"
LOCAL cCampos 	:= "Beneficiแrio=BA1_NOMUSR, Opcional=BI3_DESCRI"
LOCAL cSql 	  	:= ""
LOCAL cWhere  	:= ""
LOCAL cFieldJ	   	:= ""
LOCAL aPar  	   	:= strToArray( paramixb[1] , '|' )

cSql := " select BA1_NOMUSR, BI3_DESCRI, BBWBI3.R_E_C_N_O_ IDENLINHA from ( "
cSql += " Select BI3_DESCRI, BBW_CODSOL, BBW_MATRIC, BBW_CODOPC, BBWBBA.R_E_C_N_O_ From "
cSql += RetSQLName("BI3") + " JOIN ( SELECT BBA_CODSEQ, BBW_CODSOL, BBW_MATRIC, BBW_CODOPC, "
cSql += " V.R_E_C_N_O_ FROM " + RetSQLName('BBA') + " Z JOIN " + RetSQLName("BBW") + " V ON "
cSql += " BBA_CODSEQ = BBW_CODSOL) BBWBBA ON BBW_CODOPC = BI3_CODIGO) BBWBI3 JOIN "

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES" 
	cSql += RetSQLName("BA1") + " ON BBWBI3.BBW_MATRIC = BA1_CODINT || BA1_CODEMP || BA1_MATRIC"
	cSql += " || BA1_TIPREG || BA1_DIGITO "
Else
	cSql += RetSQLName("BA1") + " ON BBWBI3.BBW_MATRIC = BA1_CODINT + BA1_CODEMP + BA1_MATRIC"
	cSql += " + BA1_TIPREG + BA1_DIGITO "
EndIf

cwhere +=	" Where BBW_CODSOL = " + "'" + aPar[1] + "'"
cwhere += " AND D_E_L_E_T_ = ' ' "

cSql += cWhere

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSITBEN  บAutor  ณFแbio S. dos Santos บ Data ณ  23/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca de itens da solicita็ใo de opcional                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLSITBEN()
Local aArea 		:= GetArea()
Local nI			:= 0
Local nRegPagina	:= 5
Local cAlias		:= ""
Local cCampos		:= "CPF=CPF,Nome=NOME,Tipo=TIPO,Grau Parentesco=GRAU,Opera็ใo=OPER,0*#Editar=STR(RECNO)+SEP+BBA_TIPMAN+SEP+BBA_CODSEQ"
Local cSql			:= ""
Local cWhere		:= ""
Local cFieldJ		:= ""
Local cAuxSql1   	:= ""
Local aPar  		:= iif(!Empty(paramixb[1]), strToArray( paramixb[1] , '|' ), {})
Local aWhere  		:= {}
Local cTipo			:= ""
Local cQuery		:= ""
local cCodTit := getNewPar("MV_PLCDTIT", "T")
local cCodDep := getNewPar("MV_PLCDDEP", "D")
//Busca por parโmetros passados no portal.
for nI := 1 to Len(aPar)
	aadd(aWhere,SEPARA(aPar[nI], "="))
next
//busco na BBA qual tipo de opera็ใo
BBA->(DbSetOrder(1))
BBA->(DbSeek(xFilial("BBA")+aWhere[1][2]))
cTipo := BBA->BBA_TIPMAN

If cTipo $ ("1|3") //inclusใo/exclusใo (bloqueado)
	
	cAlias := "B2N"
	cAuxSql1 := "SELECT B2N_CPFUSR CPF, B2N_NOMUSR NOME, BBA_TIPMAN, BBA_CODSEQ, CASE B2N_TIPUSU WHEN '" + cCodTit + "' THEN 'Titular' WHEN '" + cCodDep + "' THEN 'Dependente'  END AS TIPO , BRP_DESCRI GRAU, CASE BBA_TIPMAN WHEN '1' THEN 'Inclusใo' WHEN '2' THEN 'Altera็ใo' WHEN '3' THEN 'Exclusใo' END AS OPER, " +RetSQLName("B2N")+ ".R_E_C_N_O_ RECNO , '~' SEP "
	cAuxSql1 += " FROM "  + RetSQLName( "B2N" )

	cWhere += " INNER JOIN " + RetSQLName( "BBA" )
	cWhere += " ON(BBA_CODSEQ = B2N_PROTOC) "
	cWhere += " INNER JOIN " + RetSQLName( "BRP" )
	cWhere += " ON(B2N_GRAUPA = BRP_CODIGO) "
	cWhere += " WHERE "

	cWhere += " B2N_FILIAL = '" + xFilial( "B2N" ) + "' "
	cWhere += " AND BBA_FILIAL = '" + xFilial( "BBA" ) + "' "
	cWhere += " AND BRP_FILIAL = '" + xFilial( "BRP" ) + "' "
	cWhere += "   AND " + RetSQLName( "B2N" ) +	".D_E_L_E_T_ = ' ' "
	cWhere += "   AND " + RetSQLName( "BBA" ) +	".D_E_L_E_T_ = ' ' "
	cWhere += "   AND " + RetSQLName( "BRP" ) +	".D_E_L_E_T_ = ' ' "
	If Len(aWhere) >= 1 .AND. !Empty(aWhere[1][2])
		//aPar[1] = c๓digo da solicita็ใo
		cWhere += " AND B2N_PROTOC = '" + aWhere[1][2] + "' "
	EndIf
Else //altera็ใo
	cQuery := " SELECT * FROM " + RetSqlName("B7L")
	cQuery += " WHERE B7L_FILIAL = '" + xFilial("B7L") + "' "
	cQuery += " AND B7L_CHAVE = '" + BBA->BBA_CODSEQ + "' "
	cQuery += " AND B7L_ALIACH = 'BBA' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	If Select("TRBB7L") > 0
		TRBB7L->(DbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "TRBB7L"

	TRBB7L->(DbGoTop())
	//Caso nใo traga nenhum registro na query, ้ pq na altera็ใo nใo teve nenhum campo que precisasse de valida็ใo.
	//Nesse caso a altera็ใo foi realizada diretamente na BA1.
	If TRBB7L->(Eof())

		cAlias := "BA1"
		cAuxSql1 := "SELECT BA1_CPFUSR CPF, BA1_NOMUSR NOME, BBA_TIPMAN, BBA_CODSEQ, CASE BA1_TIPUSU WHEN 'T' THEN 'Titular' WHEN 'D' THEN 'Dependente'  END AS TIPO , BRP_DESCRI GRAU, CASE BBA_TIPMAN WHEN '1' THEN 'Inclusใo' WHEN '2' THEN 'Altera็ใo' WHEN '3' THEN 'Exclusใo' END AS OPER, '~' SEP, " +RetSQLName("BBA")+ ".R_E_C_N_O_ RECNO"
		cAuxSql1 += " FROM "  + RetSQLName( "BA1" )

		cWhere += " INNER JOIN " + RetSQLName( "BBA" )

		If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
			cWhere += " ON ((BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = BBA_MATRIC) AND "
		Else
			cWhere += " ON ((BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO = BBA_MATRIC) AND "
		EndIf

		cWhere += " (BBA_NROPRO = '" + BBA->BBA_NROPRO + "' ))"
		cWhere += " INNER JOIN " + RetSQLName( "BRP" )
		cWhere += " ON (BA1_GRAUPA = BRP_CODIGO) "
		cWhere += " WHERE "
		cWhere += " BA1_FILIAL = '" + xFilial( "BA1" ) + "' "
		cWhere += " AND BBA_FILIAL = '" + xFilial( "BBA" ) + "' "
		cWhere += " AND BRP_FILIAL = '" + xFilial( "BRP" ) + "' "
		cWhere += " AND " + RetSQLName( "BA1" ) +	".D_E_L_E_T_ = ' ' "
		cWhere += " AND " + RetSQLName( "BBA" ) +	".D_E_L_E_T_ = ' ' "
		cWhere += " AND " + RetSQLName( "BRP" ) +	".D_E_L_E_T_ = ' ' "

		If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
			cWhere += " AND BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = '" + BBA->BBA_MATRIC + "' "
		Else
			cWhere += " AND BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO = '" + BBA->BBA_MATRIC + "' "
		EndIf

	Else
		cAlias := "B7L"

		cAuxSql1 := "SELECT BA1_CPFUSR CPF, BA1_NOMUSR NOME, BBA_TIPMAN, BBA_CODSEQ, CASE BA1_TIPUSU WHEN 'T' THEN 'Titular' WHEN 'D' THEN 'Dependente'  END AS TIPO, '~' SEP, " 
		cAuxSql1 += " BRP_DESCRI GRAU, CASE BBA_TIPMAN WHEN '1' THEN 'Inclusใo' WHEN '2' THEN 'Altera็ใo' WHEN '3' THEN 'Exclusใo' END AS OPER, " +RetSQLName("BBA")+ ".R_E_C_N_O_ RECNO "

		cAuxSql1 += " FROM "  + RetSQLName( "B7L" )

		cWhere += " INNER JOIN " + RetSQLName( "BA1" )
		cWhere += " ON(B7L_RECREG = " + RetSQLName( "BA1" ) + ".R_E_C_N_O_) "
		cWhere += " INNER JOIN " + RetSQLName( "BRP" )
		cWhere += " ON(BA1_GRAUPA = BRP_CODIGO) "
		cWhere += " INNER JOIN " + RetSQLName( "BBA" )
		cWhere += " ON(B7L_CHAVE = BBA_CODSEQ) "

		cWhere += " WHERE "

		cWhere += " B7L_FILIAL = '" + xFilial( "B7L" ) + "' "
		cWhere += " AND BA1_FILIAL = '" + xFilial( "BA1" ) + "' "
		cWhere += " AND BBA_FILIAL = '" + xFilial( "BBA" ) + "' "
		cWhere += " AND BRP_FILIAL = '" + xFilial( "BRP" ) + "' "
		cWhere += " AND " + RetSQLName( "B7L" ) +	".D_E_L_E_T_ = ' ' "
		cWhere += " AND " + RetSQLName( "BA1" ) +	".D_E_L_E_T_ = ' ' "
		cWhere += " AND " + RetSQLName( "BBA" ) +	".D_E_L_E_T_ = ' ' "
		cWhere += " AND " + RetSQLName( "BRP" ) +	".D_E_L_E_T_ = ' ' "
		cWhere += " AND B7L_ALIAS = 'BA1' "
		cWhere += " AND B7L_ALIACH = 'BBA' "
		cWhere += " AND B7L_CHAVE = '" + BBA->BBA_CODSEQ + "' "
		cWhere += " AND B7L_VLANT <> B7L_VLPOS "
		cWhere += " GROUP BY BA1_CPFUSR, BA1_NOMUSR, BA1_TIPUSU, BRP_DESCRI, BBA_TIPMAN,BBA_CODSEQ, " +RetSQLName("BBA")+ ".R_E_C_N_O_"
	EndIf

EndIf

cSql := cAuxSql1 + cWhere

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ,"",,,,.T.} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPXAC9ACB  บAutor  ณTotvs               บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBanco de conhecimento - Com exclusใo                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user Function PXAC9ACB()

LOCAL aArea 	   	:= getArea()
LOCAL nRegPagina 	:= 50
LOCAL cAlias  		:= "AC9"
LOCAL cCampos 		:= "Anexo=ACB_OBJETO, 0#Excluir=STR(RECNO)"
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ	   	:= ""
LOCAL aPar  	   	:= Separa( paramixb[1] , '|' )
Local cTabela		:= IIF(Len(aPar)<2, "", aPar[2])
Local cChave		:= xFilial(cTabela)+IIF(Len(aPar)<1, "", aPar[1])
Local cNoCompl 		:= IIF(Len(aPar)>=3 .and. !empty(aPar[3]), aPar[3], "")

If cTabela == "B4F"
	cChave := StaticCall(WSPLSXFUN, PlsProRecAne, cChave, xFilial(cTabela))
EndIF

cSql := "  SELECT " + RetSQLName("AC9") + ".R_E_C_N_O_ IDENLINHA, " + RetSQLName("AC9") + ".R_E_C_N_O_  RECNO, "
cSql += " ACB_CODOBJ,  ACB_OBJETO, AC9_CODOBJ, AC9_ENTIDA, AC9_CODENT "
cSql += "	 FROM " + RetSQLName("ACB") + " JOIN " + RetSQLName("AC9")
cSql += " ON ACB_CODOBJ = AC9_CODOBJ "

if !empty(cNoCompl)
	cSql += "    AND ACB_OBJETO Like " + "'%_" + RC4Crypt(cNoCompl, '123456789') + "%'"
endif

cSql += "	 AND "
cSql += "	 AC9_FILIAL = '" + xFilial("AC9") + "' "
cSql += "    AND AC9_ENTIDA = " + "'" + cTabela + "'"
cSql += "    AND AC9_CODENT = " + "'" + cChave + "'"
cSql += "    AND "+ RetSQLName("AC9")+".D_E_L_E_T_ = ' ' "

cWhere += "	 WHERE AC9_FILIAL = '" + xFilial("AC9") + "' "
cWhere += "    AND AC9_ENTIDA = " + "'" + cTabela + "'"
cWhere += "    AND AC9_CODENT = " + "'" + cChave + "'"

cWhere += "    AND D_E_L_E_T_ = ' ' "

RestArea(aArea)

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSSLCB96  บAutor  ณRenan Martins      บ Data ณ  16/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSolicita็๕es RDA                           					บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLSSLCB96()

LOCAL aArea 		:= getArea()
LOCAL nRegPagina 	:= 30
LOCAL cAlias 		:= "B96"
LOCAL cCampos 		:= "Prestador=BAU_NOME,Local=BB8_DESLOC,Especialidade=BAQ_DESCRI,Solicitado=B96_DTAREQ,Usuแrio=BSW_NOMUSR,Tipo=TIPO,Status=B96_STATUS,0*#Download=B96_STATUS+B96_EMAIL+B96_ARQUP"
LOCAL cSql 			:= ""
LOCAL cWhere 		:= ""
LOCAL cFieldJ 		:= ""
LOCAL aPar 			:= strToArray( paramixb[1], '|' )  //
Local cCodOpe		:= PlsIntPad()

//aPar aqui tem apenas duas posi็๕es: 1ช C๓digo do usuแrio logado / 2ช RDA selecionada no combo

cSQL := " SELECT B96_CODRDA, B96_CODTAB, B96_LOCATE, B96_CODESP, B96_DTAREQ, B96_USUARI, B96_STATUS, B96_EMAIL, "
cSQL += " B96_ARQUP, BAQ_DESCRI, BB8_DESLOC, BAU_NOME, BSW_NOMUSR, (CASE WHEN B96_FORMRE ='1' THEN 'PDF' ELSE 'PLANILHA' END) TIPO, " +RetSqlName("B96")+".R_E_C_N_O_ IDENLINHA "
cSQL +=   " FROM " + RetSQLName("B96")
cSQL += " LEFT JOIN " + RetSQLName("BAQ")
cSQL += " ON B96_FILIAL = BAQ_FILIAL AND BAQ_CODINT = '" + cCodOpe + "' AND B96_CODESP = BAQ_CODESP "
cSQL += " LEFT JOIN " + RetSQLName("BAU")
cSQL += " ON B96_FILIAL = BAU_FILIAL AND B96_CODRDA = BAU_CODIGO "
cSQL += " LEFT JOIN " + RetSQLName("BB8")
cSQL += " ON B96_FILIAL = BB8_FILIAL AND B96_CODRDA = BB8_CODIGO AND BB8_CODINT = '" + cCodOpe + "' AND B96_LOCATE = BB8_CODLOC AND BB8_DESLOC <> '' "
cSQL += " LEFT JOIN " + RetSQLName("BSW")
cSQL += " ON B96_FILIAL = BSW_FILIAL AND B96_USUARI = BSW_CODUSR "
cSQL +=  " WHERE B96_FILIAL = '" + xFilial("B96") + "' "
cSQL += " AND B96_USUARI = '" + aPar[1] + "' "
cSQL += " AND B96_CODRDA = '" + aPar[2] + "' " 
cSQL +=    " AND " + RetSQLName("B96") + ".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY B96_CODRDA, B96_CODTAB, B96_LOCATE, B96_CODESP, B96_DTAREQ, B96_USUARI, B96_STATUS, "
cSQL += " B96_EMAIL,  B96_ARQUP, BAQ_DESCRI, BB8_DESLOC, BAU_NOME, BSW_NOMUSR, B96_FORMRE, " + RetSQLName("B96") + ".R_E_C_N_O_ "
cSQL +=  " ORDER BY B96_DTAREQ "
RestArea(aArea)

Return( {cAlias, cSql, cWhere, nRegPagina, cCampos, cFieldJ} )

/*/{Protheus.doc} PLSRETDIGG

Retorna os dados da Guia do Beneficiแrio para consulta das guias e autoriza็๕es realizadas.

@author Rodrigo Morgon
@since 13/11/2015
@version P12
/*/
User Function PLSRETDIGG()
LOCAL nI		:= 0
LOCAL nRegPagina:= 20
LOCAL cAlias  	:= ""
LOCAL cCampos 	:= ""
LOCAL cFieldJ	:= ""
LOCAL aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL aWhere  	:= {}
Local cTipo		:= ""
Local cWhere	:= ""
Local cLocPadDig:= PLSRETLDP(4)
Local cEditar 	:= ""
Local cListCri	:= ""

/*Recuperar o tipo de guia:
	1 = Guia de Consulta
	2 = Guia de SADT
	3 = Guia de Interna็ใo
	4 = Guia de Odonto
	5 = Guia de Honorแrio Individual

	A consulta serแ realizada a partir do tipo selecionado.
	A maioria dos tipos serแ localizado na BD5, com exce็ใo	do tipo 3 - Interna็ใo, que serแ localizado na BE4.

*/
For nI := 1 to len(aPar)

	aWhere := strToArray( aPar[nI] , '=' )

	If aWhere[1] == 'Field_CTIPOS' .AND. len(aWhere)>1
	
		cTipo 	:= aWhere[2]
		nI		:= len(aPar) + 1
		
	EndIf
	
Next

//Guia de interna็ใo ou Resumo de Interna็ใo
If (cTipo == "3" .Or. cTipo == "5")
	
	cAlias := "BE4"
	
	cEditar := "STR(RECNO)"
	cEditar += "+CHR(126)+STATUS"
	cEditar += "+CHR(126)+OPERUSU+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO"  
	cEditar += "+CHR(126)+BE4_CODRDA"
	cEditar += "+CHR(126)+BE4_CODLOC"
	cEditar += "+CHR(126)+TIPO+CHR(59)+BE4_CODOPE+CHR(59)+BE4_CODLDP+CHR(59)+BE4_CODPEG+CHR(59)+BE4_NUMERO"

	//Serแ buscado na BDX por: BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV
	cListCri := "BE4_CODOPE"
	cListCri += "+BE4_CODLDP"
	cListCri += "+BE4_CODPEG"
	cListCri += "+BE4_NUMERO"
	cListCri += "+BE4_ORIMOV"
	
	cCampos := "Guia Origem=BE4_CODLDP,Status=STATUS,0*#Excluir=STR(RECNO)+CHR(126)+TIPO,1*#Editar="+cEditar+",2*#Outras Despesas=STR(RECNO)+CHR(126)+TIPO,"
	cCampos += "N๚mero da Guia=BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT,Matrํcula=OPERUSU+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO,"
	cCampos += "Nome do Usuแrio=BE4_NOMUSR,C๓d. Prestador=BE4_CODRDA,Prestador=BE4_NOMRDA,Data Atendimento=BE4_DATPRO,Data Digita็ใo=BE4_DTDIGI,3*#Listar Crํticas="+clistCri
	
	cSql := " SELECT '" + Iif(cTipo == "3", "3", "5") + "' TIPO, BE4_STATUS, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, BE4_NOMUSR, BE4_OPEUSR OPERUSU, BE4_CODEMP, BE4_MATRIC, BE4_CODLDP, BE4_TIPGUI,"
	cSql += " BE4_TIPREG, BE4_DIGITO, BE4_DATPRO, BE4_DTDIGI, BE4_CODLDP, BE4_CODRDA, BE4_FASE STATUS, BE4_NOMRDA, BE4_CODPEG, BE4_ORIMOV, BE4_CODLOC, BE4_NUMERO, "+RetSqlName("BE4")+".R_E_C_N_O_ RECNO FROM " +  RetSqlName("BE4")
	
	cWhere += " WHERE BE4_FILIAL = '" + xFilial("BE4") + "' AND BE4_CODOPE = '" + PLSINTPAD() + "' " 
	cWhere += " AND BE4_CODLDP = '" + cLocPadDig + "' AND " + RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' "
	cWhere += " AND BE4_TIPGUI = '" + Iif(cTipo == "3", "03", "05") + "'AND  BE4_SITUAC <> '2' " 


	For nI := 1 to len(aPar)
		aWhere := strToArray( aPar[nI] , '=' )
		Do Case
			Case aWhere[1] == 'Field_PREST' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
		  		cWhere += " AND BE4_CODRDA = '" + aWhere[2] + "'"
			Case aWhere[1] == 'Field_DTINICIAL' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
		  		cWhere += " AND BE4_DATPRO >= '" + dtos(ctod(aWhere[2])) + "'"
			Case aWhere[1] == 'Field_DTFINAL' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
				cWhere += " AND BE4_DATPRO <= '" + dtos(ctod(aWhere[2])) + "'"
			Case aWhere[1] == 'Field_NUMGUI' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
				cWhere += " AND BE4_CODOPE = '" + Left(aWhere[2],4) + "' AND BE4_ANOINT = '" + Substr(aWhere[2],5,4) + "' AND BE4_MESINT = '" + Substr(aWhere[2],9,2) + "' AND BE4_NUMINT = '" + Right(aWhere[2],8) + "'"
			Case aWhere[1] == 'Field_STATUSDIG' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
		  		cWhere += " AND BE4_FASE = '" + aWhere[2] + "'"
		EndCase
	Next
Else
	
	//Consulta, SADT, Odonto e Honorแrio Individual
	cAlias := "BD5"

	//Fazer demais altera็๕es para BD5.
	cEditar := "STR(RECNO)"
	cEditar += "+CHR(126)+STATUS"
	cEditar += "+CHR(126)+OPERUSU+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO"
	cEditar += "+CHR(126)+BD5_CODRDA"
	cEditar += "+CHR(126)+BD5_CODLOC"

	//Serแ buscado na BDX por: BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV
	cListCri := "BD5_CODOPE"
	cListCri += "+BD5_CODLDP"
	cListCri += "+BD5_CODPEG"
	cListCri += "+BD5_NUMERO"
	cListCri += "+BD5_ORIMOV"

	cCampos := "Guia Origem=BD5_CODLDP,Status=STATUS,0*#Excluir=STR(RECNO)+CHR(126)+TIPO,1*#Editar=" + cEditar + ",2*#Outras Despesas=STR(RECNO)+CHR(126)+TIPO, N๚mero da Guia=BD5_CODOPE + BD5_ANOPAG + BD5_MESPAG + BD5_NUMAUT,"
	cCampos += "Matrํcula=OPERUSU+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO,"
	cCampos += "Nome do Usuแrio=BD5_NOMUSR,C๓d. Prestador=BD5_CODRDA,Prestador=BD5_NOMRDA,Data Atendimento=BD5_DATPRO,Data Digita็ใo=BD5_DTDIGI,3*#Listar Crํticas=" + cListCri

	cSql := " SELECT '" + cTipo + "' TIPO, BD5_SITUAC, BD5_CODOPE, BD5_ANOPAG, BD5_MESPAG, BD5_NUMAUT, BD5_NOMUSR, BD5_OPEUSR OPERUSU, BD5_CODEMP, BD5_MATRIC,"
	cSql += " BD5_TIPREG, BD5_DIGITO, BD5_DATPRO, BD5_DTDIGI, BD5_CODLDP, BD5_CODRDA, BD5_FASE STATUS,BD5_NUMERO, BD5_NOMRDA, BD5_CODPEG, BD5_ORIMOV, BD5_CODLOC, " + RetSqlName(cAlias) + ".R_E_C_N_O_ RECNO FROM " + RetSqlName(cAlias)

	cWhere += " WHERE "
	
	cWhere += " BD5_FILIAL = '" + xFilial("BD5") + "' AND BD5_CODOPE = '" + PLSINTPAD() + "' AND ((BD5_CODLDP = '" + cLocPadDig + "') OR (BD5_CODLDP = '"+ Iif(PLSOBRPRDA(aWhere[2]),PLSRETLDP(9),GetNewPar("MV_PLSPEGE","0000")) + "')) "

	For nI := 1 to len(aPar)
		aWhere := strToArray( aPar[nI] , '=' )
		Do Case
			Case aWhere[1] == 'Field_PREST' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
		  		cWhere += " AND BD5_CODRDA = '" + aWhere[2] + "'"
			Case aWhere[1] == 'Field_DTINICIAL' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
		  		cWhere += " AND BD5_DATPRO >= '" + dtos(ctod(aWhere[2])) + "'"
			Case aWhere[1] == 'Field_DTFINAL' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
				cWhere += " AND BD5_DATPRO <= '" + dtos(ctod(aWhere[2])) + "'"
			Case aWhere[1] == 'Field_NUMGUI' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
				cWhere += " AND BD5_CODOPE = '" + Left(aWhere[2],4) + "' AND BD5_ANOPAG = '" + Substr(aWhere[2],5,4) + "' AND BD5_MESPAG = '" + Substr(aWhere[2],9,2) + "' AND BD5_NUMAUT = '" + Right(aWhere[2],8) + "'"
			Case aWhere[1] == 'Field_STATUSDIG' .and. len(aWhere)>1 .and. !Empty(aWhere[2])
		  		cWhere += " AND BD5_FASE = '" + aWhere[2] + "'"
		EndCase
	Next
	
	cWhere += " AND BD5_TIPGUI = '" + IIF(cTipo == "4", "02", STRZERO(Val(cTipo),2)) + "' "
	cWhere += " AND BD5_LIBERA <> '1' AND  BD5_SITUAC <> '2' "
	cWhere += " AND BD5_TIPATO " + IIF(cTipo == "4", "<> ' ' ", "= ' ' ")
	cWhere += " AND " + RetSQLName(cAlias) + ".D_E_L_E_T_ = ' '"

EndIf

cSql := cSql + cWhere + " ORDER BY 14 "

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*/{Protheus.doc} PLBRWB4F

Retorna as receitas cadastradas do beneficiario

@author Karine Riquena Limp
@since 01/04/2016
@version P12
/*/
User Function PLBRWB4F()
LOCAL aArea 		:= getArea()
LOCAL nRegPagina	:= 30
LOCAL cAlias  		:= "B4F"
LOCAL cCampos 		:= ""
LOCAL cBotoes    	:= ""
LOCAL cBotaoIte 	:= ""
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ		:= ""
LOCAL aWhere  		:= StrToArray( paramixb[1] , '|' )
LOCAL aFieldCustom	:= StrToArray( paramixb[2] , '|' )
LOCAL aWhere1		:= {}
LOCAL nI			:= 1
LOCAL aCustom    	:= {}

cBotaoIte := "0*#Itens=B4F_CODREC+CHR(126)+B4F_STATUS"
cBotoes += "1*#Anexar=B4F_CODREC+B4F_MATRIC+CHR(126)+STR(RECNO), 2*#Excluir=B4F_STATUS+CHR(126)+STR(RECNO)"

if existblock("PLRDUSOCON") .AND. len(aFieldCustom) > 0
	aCustom := execBlock("PLRDUSOCON",.F.,.F.,{ aFieldCustom })
endIf

if len(aCustom) > 0
	cSql := aCustom[1]
	cWhere := aCustom[2]
	cCampos := aCustom[3]
else
	cCampos := "Status=B4F_STATUS, Protocolo=B4F_CODREC,Receita=B4F_DESCRI,Matrํcula=B4F_MATRIC,Nome=BA1_NOMUSR,"
	cCampos += "Registro do Prestador=REGCR, Nome do Prestador=BB0_NOME,Data Cadastro Receita=B4F_DTCAD "
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ Query para retornar dados
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cSql := " SELECT  B4F_STATUS, B4F_CODREC, B4F_DESCRI, B4F_MATRIC, BA1_NOMUSR, (B4F_SIGLA || B4F_ESTSOL || '-' || B4F_REGSOL) REGCR , BB0_NOME, B4F_DTCAD, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO "
		cSql += " FROM " + RetSQLName(cAlias)
		cWhere += " INNER JOIN " + RetSQLName("BA1")
		cWhere += " ON (B4F_MATRIC = (BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO) ) "
		cWhere += " INNER JOIN " + RetSQLName("BB0")
		cWhere += " ON ((B4F_SIGLA || B4F_ESTSOL || B4F_REGSOL) = (BB0_CODSIG || BB0_ESTADO || BB0_NUMCR ) ) "
	Else
		cSql := " SELECT  B4F_STATUS, B4F_CODREC, B4F_DESCRI, B4F_MATRIC, BA1_NOMUSR, (B4F_SIGLA + B4F_ESTSOL + '-' + B4F_REGSOL) REGCR , BB0_NOME, B4F_DTCAD, " + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO "
		cSql += " FROM " + RetSQLName(cAlias)
		cWhere += " INNER JOIN " + RetSQLName("BA1")
		cWhere += " ON (B4F_MATRIC = (BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO) ) "
		cWhere += " INNER JOIN " + RetSQLName("BB0")
		cWhere += " ON ((B4F_SIGLA + B4F_ESTSOL + B4F_REGSOL) = (BB0_CODSIG + BB0_ESTADO + BB0_NUMCR ) ) "
	EndIf

	cWhere += " WHERE " + RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' AND " + RetSQLName("BA1")+ ".D_E_L_E_T_ = ' ' AND " + RetSQLName("BB0")+ ".D_E_L_E_T_ = ' ' "
	
endIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
For nI:=1 to Len(aWhere)
	aWhere1 := StrToArray( aWhere[nI] , '=' )
	if(len(aWhere1) == 2)
		If aWhere1[1] == 'Field_NROPROT'
		   	cWhere += " AND B4F_CODREC = '"+aWhere1[2]+"' "
		  	exit
		ElseIf aWhere1[1] == 'Field_Familia'
			cWhere += " AND B4F_MATRIC Like '" + aWhere1[2]+"%' "
		ElseIf aWhere1[1] == 'Field_DTDE'
			cWhere += " AND B4F_DTCAD >= '" + dtos(ctod("01/"+aWhere1[2])) + "' "
		ElseIf aWhere1[1] == 'Field_DTATE'
			cWhere += " AND B4F_DTCAD <= '" + dtos(LastDay(ctod("01/"+aWhere1[2]))) + "' "
		ElseIf aWhere1[1] == 'Field_MATRIC'
			cWhere += " AND B4F_MATRIC = '" + aWhere1[2]+"' "
		ElseIf aWhere1[1] == 'Field_STPROC'
			if aWhere1[2] == "0" //combo solicita็ใo nใo concluida
				aWhere1[2] := "'A'" //considera X3_CBOX A=Solicita็ใo nใo concluํda
			elseif aWhere1[2] == "1" //combo "Protocolado"
				aWhere1[2] := "'0', '1'" //considera X3_CBOX 0=Solicitado(portal) 1=Protocolado
			else
				aWhere1[2] := "'"+aWhere1[2]+"'"
			endif
			cWhere += " AND B4F_STATUS IN ("+aWhere1[2]+") "
		Endif
	endIf
Next

if !existblock("PLRDUSOCON") .AND.  len(aFieldCustom) > 0
	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cWhere += " GROUP BY B4F_STATUS, B4F_CODREC, B4F_DESCRI, B4F_MATRIC, BA1_NOMUSR, (B4F_SIGLA || B4F_ESTSOL || '-' || B4F_REGSOL) , BB0_NOME, B4F_DTCAD, " + RetSQLName(cAlias) + ".R_E_C_N_O_ "
	Else
		cWhere += " GROUP BY B4F_STATUS, B4F_CODREC, B4F_DESCRI, B4F_MATRIC, BA1_NOMUSR, (B4F_SIGLA + B4F_ESTSOL + '-' + B4F_REGSOL) , BB0_NOME, B4F_DTCAD, " + RetSQLName(cAlias) + ".R_E_C_N_O_ "
	EndIf
EndIf

cSql := cSql + cWhere
cCampos := cBotaoIte + "," + cCampos + "," + cBotoes

RestArea(aArea)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",,,,.T.} )
//-------------------------------------------------------------------
/*/{Protheus.doc} PLB4FB7D

Retorna os itens da receita

@author Karine Riquena Limp
@since 04/04/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function PLB4FB7D()
LOCAL aArea 		:= getArea()
LOCAL nRegPagina	:= 30
LOCAL cAlias  		:= "B7D"
LOCAL cCampos 		:= ""
LOCAL cBotoes		:= ""
LOCAL cSql 	  		:= ""
LOCAL cWhere  		:= ""
LOCAL cFieldJ		:= ""
LOCAL aWhere  		:= StrToArray( paramixb[1] , '|' )
LOCAL aWhere1		:= {}
LOCAL nI			:= 1
LOCAL aCustom 		:= {}
LOCAL nPos 			:= 0

cBotoes += "0*#Observa็ใo=RECNO"

if existblock("PLRDITUSOC")
	aCustom := execBlock("PLRDITUSOC",.F.,.F.,{ })
endIf

if(len(aCustom) > 0)
	cSql := aCustom[1]
	cWhere := aCustom[2]
	cCampos := aCustom[3]
else
	cCampos := "Status=B7D_OK,Validade de=B7D_DTVINI,At้=B7D_DTFVAL,C๓d. Medicamento=B7D_CODMED,"
	cCampos += "Descri็ใo do Medicamento=BR8_DESCRI,Unid. Medida=B7D_UNICON,Quantidade Autorizada=B7D_QTDAUT,Quantidade Utilizada=B7D_QTDEXE"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ Query para retornar dados
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	cSql := " SELECT  B7D_CODREC,B7D_DTVINI,B7D_DTFVAL,B7D_CODMED,BR8_DESCRI,B7D_UNICON,B7D_QTDAUT,B7D_QTDEXE,B7D_OK, B4F_STATUS, "
	cSql += RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetSQLName(cAlias)
	cWhere += " INNER JOIN " + RetSQLName("B4F")
	cWhere += " ON (B7D_CODREC = B4F_CODREC) "
	cWhere += " INNER JOIN " + RetSQLName("BR8")

	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cWhere += " ON ((BR8_CODPAD || BR8_CODPSA) = (B7D_CODPAD || B7D_CODMED)) "
	Else
		cWhere += " ON ((BR8_CODPAD + BR8_CODPSA) = (B7D_CODPAD + B7D_CODMED)) "
	EndIf

	cWhere += " WHERE " + RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' AND " + RetSQLName("B4F")+ ".D_E_L_E_T_ = ' ' AND " + RetSQLName("BR8")+ ".D_E_L_E_T_ = ' ' "
endIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
For nI:=1 to Len(aWhere)
	aWhere1 := StrToArray( aWhere[nI] , '=' )
	If aWhere1[1] == 'Field_CODREC'
   		cWhere += " AND B7D_CODREC = '"+aWhere1[2]+"' "
	Endif
Next

nPos := aScan(aWhere, {|x| x == "Field_STAB4F=A"})

cSql += cWhere

if nPos > 0
	cBotoes += ",1*#Excluir=B4F_STATUS+CHR(126)+STR(RECNO)"
endIf
cCampos += ","+cBotoes

RestArea(aArea)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Funcao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",,,,.T.} )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMOSSOL

Retorna as Guias

@author Fแbio Siqueira dos Santos
@since 14/06/2016
@version P12
/*/
//-------------------------------------------------------------------
User Function PLSMOSSOL()
Local aArea 		:= GetArea()
Local nI			:= 0
Local nRegPagina	:= 30
LOCAL cAlias  		:= "BEA"
Local cAlias1		:= "BE4"
Local cAlias2		:= "B4A"
Local cAlias3		:= "B4Q"
Local cAlias4       := "BD5"
Local cCampos 		:= "0*#Itens=GUIA+chr(126)+TIPO,2*#Cancelar=Guia,Guia=GUIA,Beneficiแrio=BENEFICIARIO,Data Guia=DATA,Status=STISS,Cancelada=CANCELADA,Tipo Guia=TIPO,Guia de=LIBERA,Solicita็ใo Origem=LIBORI,Dig. Offline=DIGOFF,"
Local cSql 	  		:= ""
Local cSql1			:= ""
Local cSql2			:= ""
Local cSql3			:= ""
Local cSql4         := ""
Local cWhere  		:= ""
Local cWhere1  		:= ""
Local cWhere2  		:= ""
Local cWhere3  		:= ""
Local cWhere4       := ""
Local cFieldJ		:= ""
Local aPar  		:= iif(!Empty(paramixb[1]), strToArray( paramixb[1] , '|' ), {})
Local aWhere  		:= {}
Local cNumGuiaMat	:= "" //recebe nro da guia ou nro da matricula do beneficiแrio
Local lAliB4Q 		:= PLSALIASEXI("B4Q")
Local aRet    		:= {}
Local asepara		:={} 
LOCAL lMatrAnt  	:= GetNewPar("MV_PLMATAP","0") == "1" //Mostra Matricula Antiga Portal
LOCAL lFPosSTIS 	:= (B4Q->(FieldPos("B4Q_STTISS")) > 0) 
LOCAL lGoriB53  	:=  B53->(FieldPos("B53_NMGORI")) > 0 .AND. B53->(FieldPos("B53_NMGGER")) > 0
LOCAL cSqlB53		:= IIF(lGoriB53, " ,B53_NMGORI NMGORI, B53_NMGGER NMGGER ", "")
LOCAL cGrpB53		:= IIF(lGoriB53, " , B53_NMGORI, B53_NMGGER ", "")
local lExsData		:= "FIELD_DATAATD" $ upper(paramixb[2])
local aWhereDta		:= iif(lExsData, StrTokArr2(paramixb[2] , '=' ), {})

//Novas colunas na tabela de auditoria. Esses campos foram adicionados separados para evitar erros caso o dicionแrio nใo esteja atualizado.
if lGoriB53
    cCampos += "Guia Original=NMGORI,Guia Espelho=NMGGER,"
endif

For nI := 1 to Len(aPar)
	aadd(aWhere,SEPARA(aPar[nI], "="))
Next
If lMatrAnt .Or. !Empty(aWhere[1][2])
	cNumGuiaMat := aWhere[1][2]
Else
	cNumGuiaMat := StrTran(StrTran(aWhere[1][2],".",""),"-","")
EndIf

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cSql := " SELECT BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT GUIA, BEA_NOMUSR BENEFICIARIO, BEA_DATPRO DATA, BEA_STATUS STATUS, BEA_CANCEL CANCELADA, BEA_STTISS STISS, "
	cSql += " BEA_TIPGUI TIPO,CASE WHEN BEA_LIBERA = '0' THEN 'Execu็ใo' ELSE 'Solicita็ใo' END LIBERA, BEA_NRLBOR LIBORI, BEA_OPEMOV || BEA_CODEMP || BEA_MATRIC || BEA_TIPREG || BEA_DIGITO MATRICULA, BEA_CODRDA CODRDA, BEA_CODLOC CODLOC, 'Nใo' DIGOFF," + RetSqlName(cAlias)+".R_E_C_N_O_ IDENLINHA"
	cSql += " ,BEA_HORPRO HORPRO, BEA_SENHA SENHA"
Else
	cSql := " SELECT BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT GUIA, BEA_NOMUSR BENEFICIARIO, BEA_DATPRO DATA, BEA_STATUS STATUS, BEA_CANCEL CANCELADA, BEA_STTISS STISS, "
	cSql += " BEA_TIPGUI TIPO,CASE WHEN BEA_LIBERA = '0' THEN 'Execu็ใo' ELSE 'Solicita็ใo' END LIBERA, BEA_NRLBOR LIBORI, BEA_OPEMOV + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO MATRICULA, BEA_CODRDA CODRDA, BEA_CODLOC CODLOC, 'Nใo' DIGOFF," + RetSqlName(cAlias)+".R_E_C_N_O_ IDENLINHA"
	cSql += " ,BEA_HORPRO HORPRO, BEA_SENHA SENHA"
EndIf

cSql += cSqlB53
cSql += " FROM " + RetSqlName("BEA") 
If (B53->(FieldPos("B53_NMGORI")) > 0)
	cSql += " LEFT JOIN " + RetSqlName("B53") + " B53"
	cSql += "  ON B53_FILIAL = '"+xFilial("B53")+"' "

	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cSql += " AND B53_NUMGUI = BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT "
	Else
		cSql += " AND B53_NUMGUI = BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT "
	EndIf

	cSql += " AND B53.D_E_L_E_T_ = ' ' "
EndIf

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cSql1 += " SELECT BE4_CODOPE || BE4_ANOINT || BE4_MESINT || BE4_NUMINT GUIA, BE4_NOMUSR BENEFICIARIO, BE4_PRVINT DATA, BE4_STATUS STATUS, BE4_CANCEL CANCELADA, BE4_STTISS STISS, "
	cSql1 += " BE4_TIPGUI TIPO, 'Solicita็ใo' LIBERA, ' ' LIBORI, BE4_CODOPE || BE4_CODEMP || BE4_MATRIC || BE4_TIPREG || BE4_DIGITO MATRICULA, BE4_CODRDA CODRDA, BE4_CODLOC CODLOC, 'Nใo' DIGOFF, " + RetSqlName(cAlias1)+".R_E_C_N_O_ IDENLINHA"
	cSql1 += " ,BE4_HORPRO HORPRO, BE4_SENHA SENHA"
Else
	cSql1 += " SELECT BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT GUIA, BE4_NOMUSR BENEFICIARIO, BE4_PRVINT DATA, BE4_STATUS STATUS, BE4_CANCEL CANCELADA, BE4_STTISS STISS, "
	cSql1 += " BE4_TIPGUI TIPO, 'Solicita็ใo' LIBERA, ' ' LIBORI, BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO MATRICULA, BE4_CODRDA CODRDA, BE4_CODLOC CODLOC, 'Nใo' DIGOFF, " + RetSqlName(cAlias1)+".R_E_C_N_O_ IDENLINHA"
	cSql1 += " ,BE4_HORPRO HORPRO, BE4_SENHA SENHA"
EndIf

cSql1 += cSqlB53
cSql1 += " FROM " +  RetSqlName("BE4")
If (B53->(FieldPos("B53_NMGORI")) > 0)
	cSql1 += " LEFT JOIN " + RetSqlName("B53") + " B53"
	cSql1 += "  ON B53_FILIAL = '"+xFilial("B53")+"' "

	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cSql1 += " AND B53_NUMGUI = BE4_CODOPE || BE4_ANOINT || BE4_MESINT || BE4_NUMINT "
	Else
		cSql1 += " AND B53_NUMGUI = BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT "
	EndIf

	cSql1 += " AND B53.D_E_L_E_T_ = ' ' "
EndIf

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cSql2 += " SELECT B4A_OPEMOV || B4A_ANOAUT || B4A_MESAUT || B4A_NUMAUT GUIA, B4A_NOMUSR BENEFICIARIO, B4A_DATSOL DATA, B4A_STATUS STATUS, B4A_CANCEL CANCELADA, B4A_STTISS STISS, "
	cSql2 += "  B4A_TIPGUI TIPO, 'Solicita็ใo' LIBERA, B4A_GUIREF LIBORI, B4A_OPEMOV || B4A_CODEMP || B4A_MATRIC || B4A_TIPREG || B4A_DIGITO MATRICULA, '' CODRDA, '' CODLOC, 'Nใo' DIGOFF, " +RetSqlName(cAlias2)+".R_E_C_N_O_ IDENLINHA"
	cSql2 += " ,':' HORPRO, B4A_SENHA SENHA"
Else
	cSql2 += " SELECT B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT GUIA, B4A_NOMUSR BENEFICIARIO, B4A_DATSOL DATA, B4A_STATUS STATUS, B4A_CANCEL CANCELADA, B4A_STTISS STISS, "
	cSql2 += "  B4A_TIPGUI TIPO, 'Solicita็ใo' LIBERA, B4A_GUIREF LIBORI, B4A_OPEMOV + B4A_CODEMP + B4A_MATRIC + B4A_TIPREG + B4A_DIGITO MATRICULA, '' CODRDA, '' CODLOC, 'Nใo' DIGOFF, " +RetSqlName(cAlias2)+".R_E_C_N_O_ IDENLINHA"
	cSql2 += " ,':' HORPRO, B4A_SENHA SENHA"
EndIf

cSql2 += cSqlB53
cSql2 += " FROM " +  RetSqlName("B4A")
If (B53->(FieldPos("B53_NMGORI")) > 0)
	cSql2 += " LEFT JOIN " + RetSqlName("B53") + " B53"
	cSql2 += "  ON B53_FILIAL = '"+xFilial("B53")+"' "

	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cSql2 += " AND B53_NUMGUI = B4A_OPEMOV || B4A_ANOAUT || B4A_MESAUT || B4A_NUMAUT "
	Else
		cSql2 += " AND B53_NUMGUI = B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT "
	EndIf

	cSql2 += " AND B53.D_E_L_E_T_ = ' ' "
EndIf

if lAliB4Q
	
	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		If lFPosSTIS 
			cSql3 += " SELECT B4Q_OPEMOV || B4Q_ANOAUT || B4Q_MESAUT || B4Q_NUMAUT GUIA, B4Q_NOMUSR BENEFICIARIO, B4Q_DATPRO DATA, B4Q_STATUS STATUS, B4Q_CANCEL CANCELADA, B4Q_STTISS STISS, "
		Else
			cSql3 += " SELECT B4Q_OPEMOV || B4Q_ANOAUT || B4Q_MESAUT || B4Q_NUMAUT GUIA, B4Q_NOMUSR BENEFICIARIO, B4Q_DATPRO DATA, B4Q_STATUS STATUS, B4Q_CANCEL CANCELADA, B4Q_STATUS STISS, "
		EndIf

		cSql3 += "  '11' TIPO, 'Solicita็ใo' LIBERA, B4Q_GUIREF LIBORI,  B4Q_OPEMOV || B4Q_CODEMP || B4Q_MATRIC || B4Q_TIPREG || B4Q_DIGITO MATRICULA, '' CODRDA, '' CODLOC, 'Nใo' DIGOFF, " +RetSqlName(cAlias3)+".R_E_C_N_O_ IDENLINHA"
		cSql3 += " ,':' HORPRO, B4Q_SENHA SENHA"
	Else
		If lFPosSTIS 
			cSql3 += " SELECT B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT GUIA, B4Q_NOMUSR BENEFICIARIO, B4Q_DATPRO DATA, B4Q_STATUS STATUS, B4Q_CANCEL CANCELADA, B4Q_STTISS STISS, "
		Else
			cSql3 += " SELECT B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT GUIA, B4Q_NOMUSR BENEFICIARIO, B4Q_DATPRO DATA, B4Q_STATUS STATUS, B4Q_CANCEL CANCELADA, B4Q_STATUS STISS, "
		EndIf

		cSql3 += "  '11' TIPO, 'Solicita็ใo' LIBERA, B4Q_GUIREF LIBORI,  B4Q_OPEMOV + B4Q_CODEMP + B4Q_MATRIC + B4Q_TIPREG + B4Q_DIGITO MATRICULA, '' CODRDA, '' CODLOC, 'Nใo' DIGOFF, " +RetSqlName(cAlias3)+".R_E_C_N_O_ IDENLINHA"
		cSql3 += " ,':' HORPRO, B4Q_SENHA SENHA"
	EndIf 
	
	cSql3 += cSqlB53
	cSql3 += " FROM " +  RetSqlName("B4Q")
	If (B53->(FieldPos("B53_NMGORI")) > 0)
		cSql3 += " LEFT JOIN " + RetSqlName("B53") + " B53"
		cSql3 += "  ON B53_FILIAL = '"+xFilial("B53")+"' "
		
		If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
			cSql3 += " AND B53_NUMGUI = B4Q_OPEMOV || B4Q_ANOAUT || B4Q_MESAUT || B4Q_NUMAUT "
		Else
			cSql3 += " AND B53_NUMGUI = B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT "
		EndIf

		cSql3 += " AND B53.D_E_L_E_T_ = ' ' "
	EndIf
endIf

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cSql4 += " SELECT BD5_OPEMOV || BD5_ANOAUT || BD5_MESAUT || BD5_NUMAUT GUIA, BD5_NOMUSR BENEFICIARIO, BD5_DATPRO DATA, '0' STATUS, CASE WHEN BD5_SITUAC = '2' THEN '1' ELSE '0' END CANCELADA, "
	cSql4 += " CASE WHEN BD5_SITUAC = '2' THEN '6' ELSE ( CASE WHEN BD5_FASE IN ( '3', '4' ) THEN '1' ELSE '2' END ) END STISS, "
	cSql4 += " BD5_TIPGUI TIPO, 'Execu็ใo' LIBERA, BD5_NRLBOR LIBORI, BD5_OPEMOV || BD5_CODEMP || BD5_MATRIC || BD5_TIPREG || BD5_DIGITO MATRICULA, BD5_CODRDA CODRDA, BD5_CODLOC CODLOC, 'Sim' DIGOFF, " + RetSqlName(cAlias4)+".R_E_C_N_O_ IDENLINHA "
	cSql4 += " ,BD5_HORPRO HORPRO, BD5_SENHA SENHA"
Else
	cSql4 += " SELECT BD5_OPEMOV + BD5_ANOAUT + BD5_MESAUT + BD5_NUMAUT GUIA, BD5_NOMUSR BENEFICIARIO, BD5_DATPRO DATA, '0' STATUS, CASE WHEN BD5_SITUAC = '2' THEN '1' ELSE '0' END CANCELADA, "
	cSql4 += " CASE WHEN BD5_SITUAC = '2' THEN '6' ELSE ( CASE WHEN BD5_FASE IN ( '3', '4' ) THEN '1' ELSE '2' END ) END STISS, "
	cSql4 += " BD5_TIPGUI TIPO, 'Execu็ใo' LIBERA, BD5_NRLBOR LIBORI, BD5_OPEMOV + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG + BD5_DIGITO MATRICULA, BD5_CODRDA CODRDA, BD5_CODLOC CODLOC, 'Sim' DIGOFF, " + RetSqlName(cAlias4)+".R_E_C_N_O_ IDENLINHA "
	cSql4 += " ,BD5_HORPRO HORPRO, BD5_SENHA SENHA"
EndIf

if lGoriB53
	cSql4 += ", ' ' NMGORI, ' ' NMGGER "
endIf	
cSql4 += " FROM " +  RetSqlName("BD5")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere  += " WHERE BEA_FILIAL = '" + xFilial(cAlias) + "' "
cWhere1 += " WHERE BE4_FILIAL = '" + xFilial(cAlias1) + "' "

if Len(aWhere) > 1 .And. aWhere[2][2] == "2" //Por beneficiario
	cWhere2 += " INNER JOIN "+RetSqlName("BEA")+" BEA "
	cWhere2 += " ON BEA_FILIAL = '"+xFilial(cAlias)+"' "

	If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
		cWhere2 += " AND BEA_OPEMOV = SUBSTR(B4A_GUIREF,1,4) "
		cWhere2 += " AND BEA_ANOAUT = SUBSTR(B4A_GUIREF,5,4) "
		cWhere2 += " AND BEA_MESAUT = SUBSTR(B4A_GUIREF,9,2) "
		cWhere2 += " AND BEA_NUMAUT = SUBSTR(B4A_GUIREF,11,8) "
		cWhere2 += " AND BEA_OPEMOV || BEA_CODRDA IN (" + aWhere[3,2] + ") " 
	Else
		cWhere2 += " AND BEA_OPEMOV = SUBSTRING(B4A_GUIREF,1,4) "
		cWhere2 += " AND BEA_ANOAUT = SUBSTRING(B4A_GUIREF,5,4) "
		cWhere2 += " AND BEA_MESAUT = SUBSTRING(B4A_GUIREF,9,2) "
		cWhere2 += " AND BEA_NUMAUT = SUBSTRING(B4A_GUIREF,11,8) "
		cWhere2 += " AND BEA_OPEMOV + BEA_CODRDA IN (" + aWhere[3,2] + ") "
	EndIf

	cWhere2 += " AND BEA.D_E_L_E_T_ = ' ' "
endIf
cWhere2 += " WHERE B4A_FILIAL = '" + xFilial(cAlias2) + "' "
if lAliB4Q
	cWhere3 += " WHERE B4Q_FILIAL = '" + xFilial(cAlias3) + "' "
endIf
cWhere4  += " WHERE BD5_FILIAL = '" + xFilial(cAlias4) + "' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If Len(aWhere) > 1

	If aWhere[2][2]=="1" //busca por guia
	  	cNumGuiaMat := StrTran(StrTran(aWhere[1][2],".",""),"-","")
		B4A->(dbsetorder(1))
	  	B4A->(msseek(xfilial("B4A")+cNumGuiaMat))
		aadd(asepara, Substr(cNumGuiaMat, 1, 4))
		aadd(asepara, Substr(cNumGuiaMat, 5, 4))
		aadd(asepara, Substr(cNumGuiaMat, 9, 2))
		aadd(asepara, substr(cNumGuiaMat, 11))

		If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"	
			cWhere += " AND BEA_OPEMOV = '" + asepara[1] + "' AND BEA_ANOAUT = '" + asepara[2] + "' AND BEA_MESAUT = '" + asepara[3] + "' AND BEA_NUMAUT = '" + asepara[4] + "' "
			cWhere +=  " AND BEA_OPEMOV || BEA_CODRDA    IN (" + aWhere[3,2] + ") "
			
			cWhere1 += " AND BE4_CODOPE = '" + asepara[1] + "' AND BE4_ANOINT = '" + asepara[2] + "' AND BE4_MESINT = '" + asepara[3] + "' AND BE4_NUMINT = '" + asepara[4] + "' "
			cWhere1 += " AND BE4_CODOPE || BE4_CODRDA    IN (" + aWhere[3,2] + ") "

			cWhere2 += " AND B4A_OPEMOV = '" + asepara[1] + "' AND B4A_ANOAUT = '" + asepara[2] + "' AND B4A_MESAUT = '" + asepara[3] + "' AND B4A_NUMAUT = '" + asepara[4] + "' "
			cWhere2 += " AND B4A_GUIREF IN ("  
			cWhere2 += "(SELECT  BE4_CODOPE || BE4_ANOINT|| BE4_MESINT || BE4_NUMINT GUIA  FROM "  + RetSqlName("BE4") +  " WHERE  BE4_FILIAL = '" + xFilial('BE4') + "' " + 'AND ' + RetSqlName("BE4")+".D_E_L_E_T_ = ' ' " +  " AND BE4_CODOPE||BE4_CODRDA IN ("+ aWhere[3,2] +") "  
			cWhere2 += " AND BE4_CODOPE = '"+subStr(B4A->B4A_GUIREF,1,4)+"' AND BE4_ANOINT = '"+subStr(B4A->B4A_GUIREF,5,4)+"' AND BE4_MESINT = '"+subStr(B4A->B4A_GUIREF,9,2)+"' AND BE4_NUMINT = '"+subStr(B4A->B4A_GUIREF,11,8)+"'),"
			
			cWhere2 += "(SELECT  BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT GUIA  FROM "  + RetSqlName("BEA") +  " WHERE  BEA_FILIAL = '" + xFilial('BEA') + "' " + ' AND ' + RetSqlName("BEA")+".D_E_L_E_T_ = ' '" +  "   AND BEA_OPERDA||BEA_CODRDA IN  ("+ aWhere[3,2] +") "
			cWhere2 += " AND BEA_OPEMOV = '"+subStr(B4A->B4A_GUIREF,1,4)+"' AND BEA_ANOAUT = '"+subStr(B4A->B4A_GUIREF,5,4)+"' AND BEA_MESAUT = '"+subStr(B4A->B4A_GUIREF,9,2)+"' AND BEA_NUMAUT = '"+subStr(B4A->B4A_GUIREF,11,8)+"'))"
			
			if lAliB4Q
				cWhere3 += " AND B4Q_OPEMOV = '" +asepara[1] + "' AND B4Q_ANOAUT = '" + asepara[2] + "' AND B4Q_MESAUT = '" + asepara[3] + "' AND B4Q_NUMAUT = '" + asepara[4] + "' "
				cWhere3 += " AND B4Q_OPEMOV || B4Q_CODRDA    IN (" + aWhere[3,2] + ") "
			endIf

			cWhere4 += " AND BD5_OPEMOV = '" + asepara[1] + "' AND BD5_ANOAUT = '" + asepara[2] + "' AND BD5_MESAUT = '" + asepara[3] + "' AND BD5_NUMAUT = '" + asepara[4] + "' "
			cWhere4 += " AND BD5_OPEMOV || BD5_CODRDA    IN (" + aWhere[3,2] + ") "
		Else
			cWhere += " AND BEA_OPEMOV = '" + asepara[1] + "' AND BEA_ANOAUT = '" + asepara[2] + "' AND BEA_MESAUT = '" + asepara[3] + "' AND BEA_NUMAUT = '" + asepara[4] + "' "
			cWhere +=  " AND BEA_OPEMOV + BEA_CODRDA    IN (" + aWhere[3,2] + ") "
			
			cWhere1 += " AND BE4_CODOPE = '" + asepara[1] + "' AND BE4_ANOINT = '" + asepara[2] + "' AND BE4_MESINT = '" + asepara[3] + "' AND BE4_NUMINT = '" + asepara[4] + "' "
			cWhere1 += " AND BE4_CODOPE + BE4_CODRDA    IN (" + aWhere[3,2] + ") "
			
			cWhere2 += " AND B4A_OPEMOV = '" + asepara[1] + "' AND B4A_ANOAUT = '" + asepara[2] + "' AND B4A_MESAUT = '" + asepara[3] + "' AND B4A_NUMAUT = '" + asepara[4] + "' "
			cWhere2 += " AND B4A_GUIREF IN ("  
			cWhere2 += "(SELECT  BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT GUIA  FROM "  + RetSqlName("BE4") +  " WHERE  BE4_FILIAL = '" + xFilial('BE4') + "' " + 'AND ' + RetSqlName("BE4")+".D_E_L_E_T_ = ' ' " +  " AND BE4_CODOPE+BE4_CODRDA IN ("+ aWhere[3,2] +") "  
			cWhere2 += " AND BE4_CODOPE = '"+subStr(B4A->B4A_GUIREF,1,4)+"' AND BE4_ANOINT = '"+subStr(B4A->B4A_GUIREF,5,4)+"' AND BE4_MESINT = '"+subStr(B4A->B4A_GUIREF,9,2)+"' AND BE4_NUMINT = '"+subStr(B4A->B4A_GUIREF,11,8)+"'),"
			
			cWhere2 += "(SELECT  BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT GUIA  FROM "  + RetSqlName("BEA") +  " WHERE  BEA_FILIAL = '" + xFilial('BEA') + "' " + ' AND ' + RetSqlName("BEA")+".D_E_L_E_T_ = ' '" +  "   AND BEA_OPERDA+BEA_CODRDA IN  ("+ aWhere[3,2] +") "
			cWhere2 += " AND BEA_OPEMOV = '"+subStr(B4A->B4A_GUIREF,1,4)+"' AND BEA_ANOAUT = '"+subStr(B4A->B4A_GUIREF,5,4)+"' AND BEA_MESAUT = '"+subStr(B4A->B4A_GUIREF,9,2)+"' AND BEA_NUMAUT = '"+subStr(B4A->B4A_GUIREF,11,8)+"'))"
			
			if lAliB4Q
				cWhere3 += " AND B4Q_OPEMOV = '" +asepara[1] + "' AND B4Q_ANOAUT = '" + asepara[2] + "' AND B4Q_MESAUT = '" + asepara[3] + "' AND B4Q_NUMAUT = '" + asepara[4] + "' "
				cWhere3 += " AND B4Q_OPEMOV + B4Q_CODRDA    IN (" + aWhere[3,2] + ") "
			endIf

			cWhere4 += " AND BD5_OPEMOV = '" + asepara[1] + "' AND BD5_ANOAUT = '" + asepara[2] + "' AND BD5_MESAUT = '" + asepara[3] + "' AND BD5_NUMAUT = '" + asepara[4] + "' "
			cWhere4 += " AND BD5_OPEMOV + BD5_CODRDA    IN (" + aWhere[3,2] + ") "
		EndIf

	Else//busca por beneficiแrio
		aadd(asepara, substr(cNumGuiaMat, 1, 4))
		aadd(asepara, substr(cNumGuiaMat, 5, 4))
		aadd(asepara, substr(cNumGuiaMat, 9, 6))
		aadd(asepara, substr(cNumGuiaMat, 15, 2))
		aadd(asepara, substr(cNumGuiaMat, 17))

		If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
			cWhere +=  " AND BEA_OPEMOV || BEA_CODRDA    IN (" + aWhere[3,2] + ") AND ( (BEA_OPEUSR = '" + asepara[1] + "' AND BEA_CODEMP = '" + asepara[2] + "' AND BEA_MATRIC = '" + asepara[3] + "' AND BEA_TIPREG = '" + asepara[4] + "' AND BEA_DIGITO = '" + asepara[5] + "') OR BEA_MATANT = '" + cNumGuiaMat + "' )"
			cWhere1 += " AND BE4_CODOPE || BE4_CODRDA    IN (" + aWhere[3,2] + ") AND ( (BE4_OPEUSR = '" + asepara[1] + "' AND BE4_CODEMP = '" + asepara[2] + "' AND BE4_MATRIC = '" + asepara[3] + "' AND BE4_TIPREG = '" + asepara[4] + "' AND BE4_DIGITO = '" + asepara[5] + "') OR BE4_MATANT = '" + cNumGuiaMat + "' )"
			cWhere2 += " AND ( (B4A_OPEUSR = '" + asepara[1] + "' AND B4A_CODEMP = '" + asepara[2] + "' AND B4A_MATRIC = '" + asepara[3] + "' AND B4A_TIPREG = '" + asepara[4] + "' AND B4A_DIGITO = '" + asepara[5] + "') OR B4A_MATANT = '" + cNumGuiaMat + "' )"
		
			if lAliB4Q
				cWhere3 += " AND ( (B4Q_OPEUSR = '" + asepara[1] + "' AND B4Q_CODEMP = '" + asepara[2] + "' AND B4Q_MATRIC = '" + asepara[3] + "' AND B4Q_TIPREG = '" + asepara[4] + "' AND B4Q_DIGITO = '" + asepara[5] + "') OR B4Q_MATANT = '" + cNumGuiaMat + "' )"
				cWhere3 += " AND B4Q_OPEMOV || B4Q_CODRDA    IN (" + aWhere[3,2] + ") "
			endIf
			cWhere4 +=  " AND BD5_OPEMOV || BD5_CODRDA    IN (" + aWhere[3,2] + ") AND ( (BD5_OPEUSR = '" + asepara[1] + "' AND BD5_CODEMP = '" + asepara[2] + "' AND BD5_MATRIC = '" + asepara[3] + "' AND BD5_TIPREG = '" + asepara[4] + "' AND BD5_DIGITO = '" + asepara[5] + "') OR BD5_MATANT = '" + cNumGuiaMat + "' )"
		Else
			cWhere +=  " AND BEA_OPEMOV + BEA_CODRDA    IN (" + aWhere[3,2] + ") AND ( (BEA_OPEUSR = '" + asepara[1] + "' AND BEA_CODEMP = '" + asepara[2] + "' AND BEA_MATRIC = '" + asepara[3] + "' AND BEA_TIPREG = '" + asepara[4] + "' AND BEA_DIGITO = '" + asepara[5] + "') OR BEA_MATANT = '" + cNumGuiaMat + "' )"
			cWhere1 += " AND BE4_CODOPE + BE4_CODRDA    IN (" + aWhere[3,2] + ") AND ( (BE4_OPEUSR = '" + asepara[1] + "' AND BE4_CODEMP = '" + asepara[2] + "' AND BE4_MATRIC = '" + asepara[3] + "' AND BE4_TIPREG = '" + asepara[4] + "' AND BE4_DIGITO = '" + asepara[5] + "') OR BE4_MATANT = '" + cNumGuiaMat + "' )"
			cWhere2 += " AND ( (B4A_OPEUSR = '" + asepara[1] + "' AND B4A_CODEMP = '" + asepara[2] + "' AND B4A_MATRIC = '" + asepara[3] + "' AND B4A_TIPREG = '" + asepara[4] + "' AND B4A_DIGITO = '" + asepara[5] + "') OR B4A_MATANT = '" + cNumGuiaMat + "' )"
		
			if lAliB4Q
				cWhere3 += " AND ( (B4Q_OPEUSR = '" + asepara[1] + "' AND B4Q_CODEMP = '" + asepara[2] + "' AND B4Q_MATRIC = '" + asepara[3] + "' AND B4Q_TIPREG = '" + asepara[4] + "' AND B4Q_DIGITO = '" + asepara[5] + "') OR B4Q_MATANT = '" + cNumGuiaMat + "' )"
				cWhere3 += " AND B4Q_OPEMOV + B4Q_CODRDA    IN (" + aWhere[3,2] + ") "
			endIf
			cWhere4 +=  " AND BD5_OPEMOV + BD5_CODRDA    IN (" + aWhere[3,2] + ") AND ( (BD5_OPEUSR = '" + asepara[1] + "' AND BD5_CODEMP = '" + asepara[2] + "' AND BD5_MATRIC = '" + asepara[3] + "' AND BD5_TIPREG = '" + asepara[4] + "' AND BD5_DIGITO = '" + asepara[5] + "') OR BD5_MATANT = '" + cNumGuiaMat + "' )"
		EndIf
	EndIf

EndIf

//Consulta PlGCloGuiR
cWhere  += iif( lExsData, " AND BEA_DATPRO = '" + dtos(ctod(aWhereDta[2])) + "'", "")
cWhere1 += iif( lExsData, " AND BE4_DATPRO = '" + dtos(ctod(aWhereDta[2])) + "'", "")
cWhere2 += iif( lExsData, " AND B4A_DATPRO = '" + dtos(ctod(aWhereDta[2])) + "'", "")
cWhere3 += iif( lExsData, " AND B4Q_DATPRO = '" + dtos(ctod(aWhereDta[2])) + "'", "")
cWhere4 += iif( lExsData, " AND BD5_DATPRO = '" + dtos(ctod(aWhereDta[2])) + "'", "")

cWhere  += " AND BEA_TIPO <> '3' AND "+ RetSqlName("BEA")+".D_E_L_E_T_ = ' ' "
cWhere1 += " AND "+RetSqlName("BE4")+".D_E_L_E_T_ = ' ' "
cWhere2 += " AND " + RetSqlName("B4A")+".D_E_L_E_T_ = ' ' "
cWhere3 += " AND " + RetSqlName("B4Q")+".D_E_L_E_T_ = ' ' "
cWhere4 += " AND BD5_ORIMOV = '5' AND "+ RetSqlName("BD5")+".D_E_L_E_T_ = ' ' "

cSql := cSql + cWhere  

If AllTrim(TCGetDB()) $ "ORACLE/POSTGRES"
	cSql += " GROUP BY BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT, BEA_NOMUSR, BEA_DATPRO, BEA_STATUS, BEA_CANCEL, BEA_TIPGUI, BEA_LIBERA, BEA_NRLBOR, BEA_OPEMOV || BEA_CODEMP || BEA_MATRIC || BEA_TIPREG || BEA_DIGITO, BEA_CODRDA, BEA_CODLOC, BEA_STTISS, BEA_HORPRO, BEA_SENHA, " + RetSqlName(cAlias)+".R_E_C_N_O_ " + cGrpB53

	cSql += " UNION " + cSql1 + cWhere1 
	cSql += " GROUP BY BE4_CODOPE || BE4_ANOINT || BE4_MESINT || BE4_NUMINT, BE4_NOMUSR, BE4_PRVINT, BE4_STATUS, BE4_CANCEL, BE4_TIPGUI, BE4_CODOPE || BE4_CODEMP || BE4_MATRIC || BE4_TIPREG || BE4_DIGITO, BE4_CODRDA, BE4_CODLOC, BE4_STTISS, BE4_HORPRO, BE4_SENHA, " + RetSqlName(cAlias1)+".R_E_C_N_O_ " + cGrpB53

	cSql += " UNION " + cSql2 + cWhere2
	cSql += " GROUP BY B4A_OPEMOV || B4A_ANOAUT || B4A_MESAUT || B4A_NUMAUT, B4A_NOMUSR, B4A_DATSOL, B4A_STATUS, B4A_CANCEL, B4A_TIPGUI, B4A_GUIREF, B4A_OPEMOV || B4A_CODEMP || B4A_MATRIC || B4A_TIPREG || B4A_DIGITO, B4A_STTISS, B4A_SENHA, " + RetSqlName(cAlias2)+".R_E_C_N_O_ "  + cGrpB53

	if lAliB4Q
		cSql += " UNION " + cSql3 + cWhere3 
		
		If lFPosSTIS 
			cSql += " GROUP BY B4Q_OPEMOV || B4Q_ANOAUT || B4Q_MESAUT || B4Q_NUMAUT, B4Q_NOMUSR, B4Q_DATPRO, B4Q_STATUS, B4Q_CANCEL, B4Q_GUIREF, B4Q_OPEMOV || B4Q_CODEMP || B4Q_MATRIC || B4Q_TIPREG || B4Q_DIGITO, B4Q_STTISS, B4Q_SENHA, " + RetSqlName(cAlias3)+".R_E_C_N_O_ " + cGrpB53
		Else
			cSql += " GROUP BY B4Q_OPEMOV || B4Q_ANOAUT || B4Q_MESAUT || B4Q_NUMAUT, B4Q_NOMUSR, B4Q_DATPRO, B4Q_STATUS, B4Q_CANCEL, B4Q_GUIREF, B4Q_OPEMOV || B4Q_CODEMP || B4Q_MATRIC || B4Q_TIPREG || B4Q_DIGITO, B4Q_SENHA," + RetSqlName(cAlias3)+".R_E_C_N_O_ " + cGrpB53
		EndIf 
	endIf

	cSql += " UNION " + cSql4 + cWhere4
	cSql += " GROUP BY BD5_OPEMOV || BD5_ANOAUT || BD5_MESAUT || BD5_NUMAUT, BD5_NOMUSR, BD5_DATPRO, BD5_SITUAC, BD5_FASE, BD5_TIPGUI, BD5_LIBERA, BD5_NRLBOR, BD5_OPEMOV || BD5_CODEMP || BD5_MATRIC || BD5_TIPREG || BD5_DIGITO, BD5_CODRDA, BD5_CODLOC, BD5_HORPRO, BD5_SENHA, " + RetSqlName(cAlias4)+".R_E_C_N_O_ "
Else
	cSql += " GROUP BY BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT, BEA_NOMUSR, BEA_DATPRO, BEA_STATUS, BEA_CANCEL, BEA_TIPGUI, BEA_LIBERA, BEA_NRLBOR, BEA_OPEMOV + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO, BEA_CODRDA, BEA_CODLOC, BEA_STTISS, BEA_HORPRO, BEA_SENHA, " + RetSqlName(cAlias)+".R_E_C_N_O_ " + cGrpB53

	cSql += " UNION " + cSql1 + cWhere1 
	cSql += " GROUP BY BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT, BE4_NOMUSR, BE4_PRVINT, BE4_STATUS, BE4_CANCEL, BE4_TIPGUI, BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO, BE4_CODRDA, BE4_CODLOC, BE4_STTISS, BE4_HORPRO, BE4_SENHA, " + RetSqlName(cAlias1)+".R_E_C_N_O_ " + cGrpB53

	cSql += " UNION " + cSql2 + cWhere2
	cSql += " GROUP BY B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT, B4A_NOMUSR, B4A_DATSOL, B4A_STATUS, B4A_CANCEL, B4A_TIPGUI, B4A_GUIREF, B4A_OPEMOV + B4A_CODEMP + B4A_MATRIC + B4A_TIPREG + B4A_DIGITO, B4A_STTISS, B4A_SENHA, " + RetSqlName(cAlias2)+".R_E_C_N_O_ "  + cGrpB53

	if lAliB4Q
		cSql += " UNION " + cSql3 + cWhere3 
		
		If lFPosSTIS 
			cSql += " GROUP BY B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT, B4Q_NOMUSR, B4Q_DATPRO, B4Q_STATUS, B4Q_CANCEL, B4Q_GUIREF, B4Q_OPEMOV + B4Q_CODEMP + B4Q_MATRIC + B4Q_TIPREG + B4Q_DIGITO, B4Q_STTISS, B4Q_SENHA, " + RetSqlName(cAlias3)+".R_E_C_N_O_ " + cGrpB53
		Else
			cSql += " GROUP BY B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT, B4Q_NOMUSR, B4Q_DATPRO, B4Q_STATUS, B4Q_CANCEL, B4Q_GUIREF, B4Q_OPEMOV + B4Q_CODEMP + B4Q_MATRIC + B4Q_TIPREG + B4Q_DIGITO, B4Q_SENHA, " + RetSqlName(cAlias3)+".R_E_C_N_O_ " + cGrpB53
		EndIf 
	endIf

	cSql += " UNION " + cSql4 + cWhere4
	cSql += " GROUP BY BD5_OPEMOV + BD5_ANOAUT + BD5_MESAUT + BD5_NUMAUT, BD5_NOMUSR, BD5_DATPRO, BD5_SITUAC, BD5_FASE, BD5_TIPGUI, BD5_LIBERA, BD5_NRLBOR, BD5_OPEMOV + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG + BD5_DIGITO, BD5_CODRDA, BD5_CODLOC, BD5_HORPRO, BD5_SENHA," + RetSqlName(cAlias4)+".R_E_C_N_O_ "
EndIf

	cSql += " ORDER BY DATA DESC "

RestArea(aArea)

if lAliB4Q
	aRet := {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",cAlias1,cSql1,cWhere1,.T.," ",cAlias2,cSql2,cWhere2,{},cAlias3,cSql3,cWhere3,cAlias4,cSql4,cWhere4 }
else
	aRet := {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",cAlias1,cSql1,cWhere1,.T.," ",cAlias2,cSql2,cWhere2,{},cAlias4,cSql4,cWhere4 }
endIf

Return( aRet )

/*/{Protheus.doc} PLSMOSPRO

Retorna os procedimentos

@author Fแbio Siqueira dos Santos
@since 15/06/2016
@version P12
/*/
User Function PLSMOSPRO()
Local aArea 		:= getArea()
Local nI			:= 0
Local nRegPagina	:= 30
Local cAlias  	    := "BE2"
Local cAlias1		:= "BEJ"
Local cAlias2		:= "B4C"
Local cAlias3		:= "BQV"
Local cAlias4		:= "BD6"
Local cRetAlias 	:= RetSQLName(cAlias)
Local cRetAlias1 	:= RetSQLName(cAlias1)
Local cRetAlias2 	:= RetSQLName(cAlias2)
Local cRetAlias3 	:= RetSQLName(cAlias3)
Local cRetAlias4    := RetSQLName(cAlias4)
Local cBtn 			:= "0*#Informa็๕es=CODOPE+ANOAUT+MESAUT+NUMAUT+SEQUEN+chr(126)+ALLTRIM(STR(QTD_INTE))+chr(126)+ALITAB,1*#Anexo=CODOPE+ANOAUT+MESAUT+NUMAUT+SEQUEN+chr(126)+ALLTRIM(STR(IDENLINHA))+chr(126)+ALITAB+chr(126)+ANEXO,"+;
						"2*#Obs. Auditoria=CODOPE+ANOAUT+MESAUT+NUMAUT+SEQUEN+chr(126)+ALLTRIM(STR(IDENLINHA))+chr(126)+ALITAB"
Local cCampos 		:= "Tabela=TABELA,Procedimento=PROCEDIMENTO,Descri็ใo=DESCRICAO,Solicitada=QTD_SOLICITADA,Realizada=QTD_REALIZADA,Saldo=QTD_SALDO,Auditoria=AUDITORIA,Status=STATUS"
Local cSql 	  		:= ""
Local cSql1 	  	:= ""
Local cSql2 	  	:= ""
Local cSql3 	  	:= ""
Local cSql4         := ""  
Local cWhere  		:= ""
Local cWhere1  		:= ""
Local cWhere2  		:= ""
Local cWhere3  		:= ""
Local cWhere4       := ""
Local cGroup  		:= ""
Local cGroup1  		:= ""
Local cGroup2  		:= ""
Local cGroup3  		:= ""
Local cGroup4       := ""
Local cFieldJ		:= ""
Local cCodOpe       := ""
Local cCodLdp       := ""
Local cCodPeg       := ""
Local cNumero       := ""
Local aPar  		:= strToArray( paramixb[1] , '|' )
Local aWhere  		:= {}
Local aCmpSub		:= {}
Local cRetAliasInt	:= RetSqlName("BBR")
Local aCustom		:= strToArray( paramixb[2] , '|' )
Local cTipGui       := ""
Local lDigOff       := .F.
Local cOrder1 		:= ""

For nI := 1 to Len(aPar)
   aadd(aWhere,SEPARA(aPar[nI], "="))
Next

BD5->(DbSetOrder(17))//BD5_FILIAL+BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT
if BD5->(msSeek(xFilial("BD5")+ aWhere[1,2])) .And. BD5->BD5_ORIMOV == "5"
	cCodOpe := BD5->BD5_OPEMOV
	cCodLdp := BD5->BD5_CODLDP
	cCodPeg := BD5->BD5_CODPEG
	cNumero := BD5->BD5_NUMERO
	lDigOff := .T.
endIf

//aCustom[1] Libera็ใo
if (Len(aCustom) > 0 .AND. aCustom[1] == "1")
	cCampos := "Tabela=TABELA,Procedimento=PROCEDIMENTO,Descri็ใo=DESCRICAO,Solicitada=QTD_SOLICITADA,Autorizada=QTD_REALIZADA,Saldo=QTD_SALDO,Auditoria=AUDITORIA,Status=STATUS"
Else
	cCampos := "Tabela=TABELA,Procedimento=PROCEDIMENTO,Descri็ใo=DESCRICAO,Solicitada=QTD_SOLICITADA,Realizada=QTD_REALIZADA,Saldo=QTD_SALDO,Auditoria=AUDITORIA,Status=STATUS"
EndIf

//Considera tipo de guia para buscar os itens referentes เ guia selecionada, para evitar duplicidade de itens.
if "Field_TipoGuia" $ aPar[2] 
    cTipGui := strToArray( aPar[2], '=' )[2]
endif

cSql := " SELECT 'BE2' ALITAB, BE2_CODPAD TABELA, BE2_CODPRO PROCEDIMENTO, BE2_DESPRO DESCRICAO, "
cSql += " BE2_OPEMOV CODOPE, BE2_ANOAUT ANOAUT, BE2_MESAUT MESAUT, BE2_NUMAUT NUMAUT, BE2_SEQUEN SEQUEN, "
cSql += " (CASE WHEN BE2_QTDSOL=0 THEN BE2_QTDPRO ELSE BE2_QTDSOL END) QTD_SOLICITADA, "
cSql += " (CASE WHEN BE2_STATUS='1' THEN BE2_QTDPRO ELSE 0 END) QTD_REALIZADA, " 
cSql += " (CASE WHEN BE2_STATUS='1' THEN (CASE WHEN BE2_SALDO ='0' THEN (BE2_QTDSOL - BE2_QTDPRO) WHEN  (BE2_QTDSOL - BE2_QTDPRO)<0 THEN BE2_SALDO ELSE BE2_SALDO  END ) ELSE 0 END) QTD_SALDO, "
cSql += " (CASE WHEN BE2_AUDITO='1' THEN 'Sim' ELSE 'Nใo' END) AUDITORIA, "
cSql += " (CASE WHEN BE2_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "

cSql += "  COUNT(CASE WHEN (  "
If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql += " BBR_ANEXAD = 'F' AND "
EndIf
cSql += "BBR_TPDIRP = 'P') THEN 1 END) QTD_INTE, "

cSql += " (CASE WHEN COUNT(CASE WHEN ( "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql += "BBR_ANEXAD = 'F' AND "
EndIf

cSql += "BBR_TPDIRP = 'P') THEN 1 END)=0 THEN 'false' WHEN COUNT(CASE WHEN (BBR_RESPRE = 'F' "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql += "AND BBR_ANEXAD = 'F'"
EndIf

cSql += ") THEN 1 END)>0 THEN 'obrigat' ELSE 'true' END) ANEXO, "

cSql += cRetAlias+".R_E_C_N_O_ IDENLINHA"
cSql += " FROM " + cRetAlias
cSql += " LEFT JOIN " + cRetAliasInt
cSql += " ON  BE2_FILIAL = BBR_FILIAL"
cSql += " AND BE2_OPEMOV = BBR_CODOPE"
cSql += " AND BE2_ANOAUT = BBR_ANOAUT"
cSql += " AND BE2_MESAUT = BBR_MESAUT"
cSql += " AND BE2_NUMAUT = BBR_NUMAUT"
cSql += " AND BE2_SEQUEN = BBR_SEQPRO"
cSql += " AND " + cRetAliasInt+".D_E_L_E_T_ = ' ' "
cGroup += " GROUP BY BE2_CODPAD, "
cGroup += "          BE2_CODPRO, "
cGroup += "          BE2_DESPRO, "
cGroup += "          BE2_QTDSOL, "
cGroup += "          BE2_QTDPRO, "
cGroup += "          BE2_STATUS, "
cGroup += "          BE2_SALDO,  "
cGroup += "          BE2_AUDITO, "
cGroup += "          BE2_OPEMOV, "
cGroup += "          BE2_ANOAUT, "
cGroup += "          BE2_MESAUT, "
cGroup += "          BE2_NUMAUT, "
cGroup += "          BE2_SEQUEN, "
cGroup +=           cRetAlias+".R_E_C_N_O_ "

cSql1 := " SELECT 'BEJ' ALITAB,BEJ_CODPAD TABELA, BEJ_CODPRO PROCEDIMENTO, BEJ_DESPRO DESCRICAO, "
cSql1 += "  BEJ_CODOPE CODOPE, BEJ_ANOINT ANOAUT, BEJ_MESINT MESAUT, BEJ_NUMINT NUMAUT, BEJ_SEQUEN SEQUEN, "
cSql1 += " (CASE WHEN BEJ_QTDSOL=0 THEN BEJ_QTDPRO ELSE BEJ_QTDSOL END) QTD_SOLICITADA, "
cSql1 += " (CASE WHEN BEJ_STATUS='1' THEN BEJ_QTDPRO ELSE 0 END) QTD_REALIZADA, 0 QTD_SALDO, "
cSql1 += " (CASE WHEN BEJ_AUDITO='1' THEN 'Sim' ELSE 'Nใo' END) AUDITORIA,
cSql1 += " (CASE WHEN BEJ_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "

cSql1 += "  COUNT(CASE WHEN (  "
If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql1 += " BBR_ANEXAD = 'F' AND "
EndIf
cSql1 += " BBR_TPDIRP = 'P') THEN 1 END) QTD_INTE, "


cSql1 += " (CASE WHEN COUNT(CASE WHEN ( "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql1 += "BBR_ANEXAD = 'F' AND "
EndIf

cSql1 += "BBR_TPDIRP = 'P') THEN 1 END)=0 THEN 'false' WHEN COUNT(CASE WHEN (BBR_RESPRE = 'F' "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql1 += "AND BBR_ANEXAD = 'F'"
EndIf

cSql1 += ") THEN 1 END)>0 THEN 'obrigat' ELSE 'true' END) ANEXO, "

cSql1 += cRetAlias1+".R_E_C_N_O_ IDENLINHA"
cSql1 += " FROM " + cRetAlias1
cSql1 += " LEFT JOIN " + cRetAliasInt
cSql1 += " ON  BEJ_FILIAL = BBR_FILIAL"
cSql1 += " AND BEJ_CODOPE = BBR_CODOPE"
cSql1 += " AND BEJ_ANOINT = BBR_ANOAUT"
cSql1 += " AND BEJ_MESINT = BBR_MESAUT"
cSql1 += " AND BEJ_NUMINT = BBR_NUMAUT"
cSql1 += " AND BEJ_SEQUEN = BBR_SEQPRO"
cSql1 += " AND " + cRetAliasInt+".D_E_L_E_T_ = ' ' "
cGroup1 += " GROUP BY BEJ_CODPAD, "
cGroup1 += "          BEJ_CODPRO, "
cGroup1 += "          BEJ_DESPRO, "
cGroup1 += "          BEJ_QTDSOL, "
cGroup1 += "          BEJ_QTDPRO, "
cGroup1 += "          BEJ_STATUS, "
cGroup1 += "          BEJ_AUDITO, "
cGroup1 += "          BEJ_CODOPE, "
cGroup1 += "          BEJ_ANOINT, "
cGroup1 += "          BEJ_MESINT, "
cGroup1 += "          BEJ_NUMINT, "
cGroup1 += "          BEJ_SEQUEN, "
cGroup1 +=           cRetAlias1+".R_E_C_N_O_ "

cSql2 := " SELECT 'B4C' ALITAB, B4C_CODPAD TABELA, B4C_CODPRO PROCEDIMENTO, B4C_DESPRO DESCRICAO, "
cSql2 += "  B4C_OPEMOV CODOPE, B4C_ANOAUT ANOAUT, B4C_MESAUT MESAUT, B4C_NUMAUT NUMAUT, B4C_SEQUEN SEQUEN, "
cSql2 += " (CASE WHEN B4C_QTDSOL=0 THEN B4C_QTDPRO ELSE B4C_QTDSOL END) QTD_SOLICITADA, "
cSql2 += " (CASE WHEN B4C_STATUS='1' THEN B4C_QTDPRO ELSE 0 END) QTD_REALIZADA, "
cSql2 += " (CASE WHEN B4C_STATUS='1' THEN B4C_SALDO ELSE 0 END) QTD_SALDO, "
cSql2 += " (CASE WHEN B4C_AUDITO='1' THEN 'Sim' ELSE 'Nใo' END) AUDITORIA, "
cSql2 += " (CASE WHEN B4C_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "

cSql2 += "  COUNT(CASE WHEN (  "
If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql2 += " BBR_ANEXAD = 'F' AND "
EndIf
cSql2 += " BBR_TPDIRP = 'P') THEN 1 END) QTD_INTE, "

cSql2 += " (CASE WHEN COUNT(CASE WHEN ( "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql2 += "BBR_ANEXAD = 'F' AND "
EndIf

cSql2 += "BBR_TPDIRP = 'P') THEN 1 END)=0 THEN 'false' WHEN COUNT(CASE WHEN (BBR_RESPRE = 'F' "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql2 += "AND BBR_ANEXAD = 'F'"
EndIf

cSql2 += ") THEN 1 END)>0 THEN 'obrigat' ELSE 'true' END) ANEXO, "

cSql2 += cRetAlias2+".R_E_C_N_O_ IDENLINHA"
cSql2 += " FROM " + cRetAlias2
cSql2 += " LEFT JOIN " + cRetAliasInt
cSql2 += " ON  B4C_FILIAL = BBR_FILIAL"
cSql2 += " AND B4C_OPEMOV = BBR_CODOPE"
cSql2 += " AND B4C_ANOAUT = BBR_ANOAUT"
cSql2 += " AND B4C_MESAUT = BBR_MESAUT"
cSql2 += " AND B4C_NUMAUT = BBR_NUMAUT"
cSql2 += " AND B4C_SEQUEN = BBR_SEQPRO"
cSql2 += " AND " + cRetAliasInt+".D_E_L_E_T_ = ' ' "
cGroup2 += " GROUP BY B4C_CODPAD, "
cGroup2 += "          B4C_CODPRO, "
cGroup2 += "          B4C_DESPRO, "
cGroup2 += "          B4C_QTDSOL, "
cGroup2 += "          B4C_QTDPRO, "
cGroup2 += "          B4C_QTDSOL, "
cGroup2 += "          B4C_STATUS, "
cGroup2 += "          B4C_SALDO,  "
cGroup2 += "          B4C_AUDITO, "
cGroup2 += "          B4C_OPEMOV, "
cGroup2 += "          B4C_ANOAUT, "
cGroup2 += "          B4C_MESAUT, "
cGroup2 += "          B4C_NUMAUT, "
cGroup2 += "          B4C_SEQUEN, "
cGroup2 +=           cRetAlias2+".R_E_C_N_O_ "

cSql3 := " SELECT 'BQV' ALITAB, BQV_CODPAD TABELA, BQV_CODPRO PROCEDIMENTO, BQV_DESPRO DESCRICAO, "
cSql3 += "  BQV_CODOPE CODOPE, BQV_ANOINT ANOAUT, BQV_MESINT MESAUT, BQV_NUMINT NUMAUT, BQV_SEQUEN SEQUEN, "
cSql3 += " (CASE WHEN BQV_QTDSOL=0 THEN BQV_QTDPRO ELSE BQV_QTDSOL END) QTD_SOLICITADA, "
cSql3 += " (CASE WHEN BQV_STATUS='1' THEN BQV_QTDPRO ELSE 0 END) QTD_REALIZADA, 0 QTD_SALDO, "
cSql3 += " (CASE WHEN BQV_AUDITO='1' THEN 'Sim' ELSE 'Nใo' END) AUDITORIA, "
cSql3 += " (CASE WHEN BQV_STATUS='1' THEN 'Autorizado' ELSE 'Nใo Autorizado' END) STATUS, "

cSql3 += "  COUNT(CASE WHEN ( "
If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql3 += " BBR_ANEXAD = 'F' AND  "
EndIf

cSql3 += "BBR_TPDIRP = 'P') THEN 1 END) QTD_INTE, "

cSql3 += " (CASE WHEN COUNT(CASE WHEN ( "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql3 += "BBR_ANEXAD = 'F' AND "
EndIf

cSql3 += "BBR_TPDIRP = 'P') THEN 1 END)=0 THEN 'false' WHEN COUNT(CASE WHEN (BBR_RESPRE = 'F' "

If BBR->(FieldPos("BBR_ANEXAD")) > 0
	cSql3 += "AND BBR_ANEXAD = 'F'"
EndIf

cSql3 += ") THEN 1 END)>0 THEN 'obrigat' ELSE 'true' END) ANEXO, "

cSql3 += cRetAlias3+".R_E_C_N_O_ IDENLINHA"
cSql3 += " FROM " + cRetAlias3
cSql3 += " LEFT JOIN " + cRetAliasInt
cSql3 += " ON  BQV_FILIAL = BBR_FILIAL"
cSql3 += " AND BQV_CODOPE = BBR_CODOPE"
cSql3 += " AND BQV_ANOINT = BBR_ANOAUT"
cSql3 += " AND BQV_MESINT = BBR_MESAUT"
cSql3 += " AND BQV_NUMINT = BBR_NUMAUT"
cSql3 += " AND BQV_SEQUEN = BBR_SEQPRO"
cSql3 += " AND " + cRetAliasInt+".D_E_L_E_T_ = ' ' "
cGroup3 += " GROUP BY BQV_CODPAD, "
cGroup3 += "          BQV_CODPRO, "
cGroup3 += "          BQV_DESPRO, "
cGroup3 += "          BQV_QTDSOL, "
cGroup3 += "          BQV_QTDPRO, "
cGroup3 += "          BQV_STATUS, "
cGroup3 += "          BQV_AUDITO, "
cGroup3 += "          BQV_CODOPE, "
cGroup3 += "          BQV_ANOINT, "
cGroup3 += "          BQV_MESINT, "
cGroup3 += "          BQV_NUMINT, "
cGroup3 += "          BQV_SEQUEN, "
cGroup3 +=           cRetAlias3+".R_E_C_N_O_ "


cSql4 := " SELECT 'BD6' ALITAB, BD6_CODPAD TABELA, BD6_CODPRO PROCEDIMENTO, BD6_DESPRO DESCRICAO, "
cSql4 += " BD6_CODOPE CODOPE, BD6_ANOPAG ANOAUT, BD6_MESPAG MESAUT, BD6_NUMERO NUMAUT, BD6_SEQUEN SEQUEN, "
cSql4 += " BD6_QTDPRO QTD_SOLICITADA, "
cSql4 += " BD6_QTDPRO QTD_REALIZADA, " 
cSql4 += " BD6_SALDO QTD_SALDO, "
//cSql4 += " (CASE WHEN BD6_QTDSOL=0 THEN BD6_QTDPRO ELSE BD6_QTDSOL END) QTD_SOLICITADA, "
//cSql4 += " (CASE WHEN BD6_STATUS='1' THEN BD6_QTDPRO ELSE 0 END) QTD_REALIZADA, " 
//cSql4 += " (CASE WHEN BD6_STATUS='1' THEN (CASE WHEN BD6_SALDO ='0' THEN (BD6_QTDSOL - BD6_QTDPRO) WHEN  (BD6_QTDSOL - BD6_QTDPRO)<0 THEN BD6_SALDO ELSE BD6_SALDO  END ) ELSE 0 END) QTD_SALDO, "
cSql4 += " 'Nใo 'AUDITORIA, "
cSql4 += " ( CASE WHEN BD6_FASE IN ('0','1','2') THEN 'Em Anแlise Dig. Contas' ELSE ( CASE WHEN BD6_STATUS = '0' THEN 'Nใo Autorizado' ELSE 'Autorizado' END ) END ) STATUS, "
cSql4 += " 0 QTD_INTE, "
cSql4 += " 'false' ANEXO, "
cSql4 += cRetAlias4+".R_E_C_N_O_ IDENLINHA"
cSql4 += " FROM " + cRetAlias4

cGroup4 += " GROUP  BY BD6_CODPAD, " 
cGroup4 += "          BD6_CODPRO, " 
cGroup4 += "          BD6_DESPRO, " 
cGroup4 += "          BD6_QTDSOL, " 
cGroup4 += "          BD6_QTDPRO, " 
cGroup4 += "          BD6_STATUS, " 
cGroup4 += "          BD6_SALDO, " 
cGroup4 += "          BD6_CODOPE, " 
cGroup4 += "          BD6_ANOPAG, "
cGroup4 += "          BD6_MESPAG, "
cGroup4 += "          BD6_NUMERO, " 
cGroup4 += "          BD6_SEQUEN, "  
cGroup4 += "          BD6_FASE, "  
cGroup4 +=           cRetAlias4+".R_E_C_N_O_ "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere  += " WHERE BE2_FILIAL = '" + xFilial(cAlias) + "' AND BE2_TIPO <> '3' "
cWhere1 += " WHERE BEJ_FILIAL = '" + xFilial(cAlias1) + "' "
cWhere2 += " WHERE B4C_FILIAL = '" + xFilial(cAlias2) + "' "
cWhere3 += " WHERE BQV_FILIAL = '" + xFilial(cAlias3) + "' "
cWhere4 += " WHERE BD6_FILIAL = '" + xFilial(cAlias4) + "' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Where
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cWhere  += " AND BE2_OPEMOV = '" + Left(aWhere[1,2],4) + "' AND BE2_ANOAUT ='" + Substr(aWhere[1,2],5,4) + "' AND BE2_MESAUT = '" + Substr(aWhere[1,2],9,2) + "' AND BE2_NUMAUT = '" + Right(aWhere[1,2],8) + "' "
cWhere1 += " AND BEJ_CODOPE = '" + Left(aWhere[1,2],4) + "' AND BEJ_ANOINT ='" + Substr(aWhere[1,2],5,4) + "' AND BEJ_MESINT = '" + Substr(aWhere[1,2],9,2) + "' AND BEJ_NUMINT = '" + Right(aWhere[1,2],8) + "' "
cWhere2 += " AND B4C_OPEMOV = '" + Left(aWhere[1,2],4) + "' AND B4C_ANOAUT ='" + Substr(aWhere[1,2],5,4) + "' AND B4C_MESAUT = '" + Substr(aWhere[1,2],9,2) + "' AND B4C_NUMAUT = '" + Right(aWhere[1,2],8) + "' "
cWhere3 += " AND BQV_CODOPE = '" + Left(aWhere[1,2],4) + "' AND BQV_ANOINT ='" + Substr(aWhere[1,2],5,4) + "' AND BQV_MESINT = '" + Substr(aWhere[1,2],9,2) + "' AND BQV_NUMINT = '" + Right(aWhere[1,2],8) + "' "

cWhere4 += " AND BD6_CODOPE = '"+cCodOpe+"' " 
cWhere4 += " AND BD6_CODLDP = '"+cCodLdp+"' " 
cWhere4 += " AND BD6_CODPEG = '"+cCodPeg+"' " 
cWhere4 += " AND BD6_NUMERO = '"+cNumero+"' " 
cWhere4 += " AND BD6_ORIMOV = '5' " 

//+------------------------------------------------+
//| 				  ORDER BY 					   |
//+------------------------------------------------+
//Ordena pelo numero do registro no BD 
cOrder1 :=  " ORDER BY IDENLINHA "

if !empty(cTipGui) .and. cTipGui $ "01,02,03,07,08,09,11"
    Do Case
        //Consulta, SADT
        case cTipGui $ "01,02" .And. !lDigOff
            cSql := cSql  + cWhere  + " AND " + cRetAlias+ ".D_E_L_E_T_ = ' '" + cGroup
        
        //Interna็ใo
        case cTipGui $ "03" 
            cSql := cSql1 + cWhere1 + " AND " + cRetAlias1+".D_E_L_E_T_ = ' '" + cGroup1 + " UNION " + cSql3 + cWhere3 + " AND " + cRetAlias3 + ".D_E_L_E_T_ = ' '" + cGroup3 
            
        //Anexos
        case cTipGui $ "07,08,09"
            cSql := cSql2 + cWhere2 + " AND " + cRetAlias2+".D_E_L_E_T_ = ' '" + cGroup2
        
        //Prorrog. Interna็ใo
        case cTipGui $ "11"
            cSql := cSql3 + cWhere3 + " AND " + cRetAlias3+".D_E_L_E_T_ = ' '" + cGroup3

		 //Digitacao Offline
		case lDigOff
			cSql := cSql4 + cWhere4 + " AND " + cRetAlias4+".D_E_L_E_T_ = ' '" + cGroup4

    End Case
else
    cSql := cSql + cWhere + " AND "+ cRetAlias+".D_E_L_E_T_ = ' ' " + cGroup + ;
			" UNION " + cSql1 + cWhere1 + " AND "+ cRetAlias1+".D_E_L_E_T_ = ' '" + cGroup1 +;
			" UNION " + cSql2 + cWhere2 + " AND "+ cRetAlias2+".D_E_L_E_T_ = ' '" + cGroup2 +;
			" UNION " + cSql3 + cWhere3 + " AND "+ cRetAlias3+".D_E_L_E_T_ = ' '" + cGroup3 +;
			" UNION " + cSql4 + cWhere4 + " AND "+ cRetAlias4+".D_E_L_E_T_ = ' '" + cGroup4
endif

	//ORDENA A QUERY NO PORTAL 
	cSql := cSql + cOrder1

cCampos += "," + cBtn

RestArea(aArea)
Return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ," ",cAlias1,cSql1,cWhere1,.T.," ",cAlias2,cSql2,cWhere2,aCmpSub,cAlias3,cSql3,cWhere3,cAlias4,cSql4,cWhere4 } )

/*/{Protheus.doc} PLBRRECGB4D	
Busca os Protocolos de recurso de glosa para exibi็ใo no portal
@since 06/2019
/*/
//-------------------------------------------------------------------
user Function PLBRRECGB4D()
LOCAL nI		:= 0
LOCAL nRegPagina:= 2000
Local aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL cCampos 	:= ""
LOCAL cSql 	  	:= ""
LOCAL cFieldJ	:= ""
LOCAL cWhere  	:= ""
LOCAL aWhere  	:= {}
local cAlias	:= "B4D"
local cListCri	:= ""
local cItens	:= ""

cListCri := "B4D_PROTOC"
cItens	 := "B4D_SEQB4D+CHR(126)+B4D_CODPEG"

cCampos  := "Recurso=B4D_PROTOC, Protocolo=B4D_CODPEG, Guia=B4D_NUMAUT, Data Solicita็ใo=B4D_DATSOL, Status Recurso=STATUS, Objeto Recurso=OBJREC, "
cCampos  += "0#Justif. Operadora Prot/Guia= " + cListCri + ",1#Itens= " + cItens + ", Origem Recurso=ORIGEM,2#Enviar Anexo=CHAVE"

cSql := " Select B4D_PROTOC, B4D_CODPEG, B4D_NUMAUT, B4D_DATSOL, B4D_SEQB4D, "
cSql += "   (CASE WHEN B4D_OBJREC = '1' THEN 'Protocolo' WHEN B4D_OBJREC = '2' THEN 'Guia' ELSE 'Itens' END) OBJREC, "
cSql += "   (CASE WHEN B4D_STATUS = '1' THEN 'Protocolado' WHEN B4D_STATUS = '2' THEN 'Em Anแlise' WHEN B4D_STATUS = '3' THEN 'Autorizado' "
cSql += "         WHEN B4D_STATUS = '4' THEN 'Negado' ELSE 'Aut. Parcialmente' END) STATUS, "
cSql += "   (CASE WHEN B4D_ORIENT = '2' THEN 'Via Portal' WHEN B4D_ORIENT = '4' THEN 'Via XML' WHEN B4D_ORIENT = '3'  THEN 'Via Webservice' END) ORIGEM, "
if "ORACLE" $ upper(TCGetDb()) .OR. "POSTGRES" $ Upper(TCGetDb()) //Nใo remover por causa do STR
	cSql += "   '"+'"'+"'||" + "B4D_OPEMOV||B4D_CODLDP||B4D_CODPEG||B4D_NUMAUT||B4D_QTDIRP||'~'||R_E_C_N_O_" + "||'"+'"'+"'"  +  " CHAVE "
else
	cSql += "   '"+'"'+"'+" + "B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT+right(rtrim(replicate(' ',15)+cast(B4D_QTDIRP as varchar)),15)+'~'+STR(R_E_C_N_O_)" + "+'"+'"'+"'"  +  " CHAVE "
endif
cSql += " FROM " + RetSqlName('B4D') 
cSql += " WHERE B4D_FILIAL = '" + xFilial('B4D') + "' "
cSql += " AND B4D_OPEMOV = '" + PLSINTPAD() + "' "

for nI := 1 to len(aPar)
	aWhere := strToArray( aPar[nI] , '=' )
	do case
	case aWhere[1] == 'CODRDA' .and. len(aWhere)>1
		cSql += " AND B4D_CODRDA = '" + aWhere[2] + "' "
	
	case aWhere[1] == 'DATADE' .and. len(aWhere)>1
		cSql += " AND B4D_DATSOL >= '" + dtos(ctod(aWhere[2])) + "' "
	
	case aWhere[1] == 'DATAATE' .and. len(aWhere)>1
		cSql += " AND B4D_DATSOL <= '" + dtos(ctod(aWhere[2])) + "' "
	
	case aWhere[1] == 'STATUS' .and. len(aWhere)>1 .and. !empty(aWhere[2])
		cSql += " AND B4D_STATUS = '" + aWhere[2] + "' "

	case aWhere[1] == 'PROTPEG' .and. len(aWhere)>1 .and. !empty(aWhere[2])	
		if len(aWhere[2]) == 8
			cSql += " AND B4D_CODPEG = '" + aWhere[2] + "' "
		elseif len(aWhere[2]) > 8
			cSql += " AND B4D_PROTOC = '" + aWhere[2] + "' "
		endif
	endCase
next

cSql += " AND B4D_ORIENT IN ('2', '4', '3') "
cSql += " AND D_E_L_E_T_ = ' ' "

//Order By
cSql := changequery(cSql + " ORDER BY B4D_PROTOC") 

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )

/*/{Protheus.doc} PLBRREIT4E	
Busca os itens do Protocolo de Recurso de glosa, quando o objeto for do tipo Itens.
@since 06/2019
/*/
//-------------------------------------------------------------------
user Function PLBRREIT4E()
LOCAL nI		:= 0
LOCAL nRegPagina:= 2000
Local aPar  	:= strToArray( paramixb[1] , '|' )
LOCAL cCampos 	:= ""
LOCAL cSql 	  	:= ""
LOCAL cFieldJ	:= ""
LOCAL cWhere  	:= ""
LOCAL aWhere  	:= {}
local cAlias	:= "B4E"
local aSepara 	:= ""
local cListCri	:= ""

cListCri	:= "B4E_SEQB4D+CHR(126)+B4E_SEQUEN"

cCampos  	:= "C๓d. Tabela=B4E_CODPAD, C๓d. Procedimento=B4E_CODPRO, Descri็ใo=B4E_DESPRO, Vlr. Recursado=B4E_VLRREC, Vlr. Acatado=B4E_VLRACA, Status Itens=STATUS,0#Justif. Operadora= " + cListCri

cSql := " Select B4E_CODPAD, B4E_CODPRO, B4E_DESPRO, B4E_VLRREC, B4E_VLRACA, B4E_SEQB4D, B4E_SEQUEN, "     
cSql += "   (CASE WHEN B4E_STATUS = '1' THEN 'Protocolado' WHEN B4E_STATUS = '2' THEN 'Em Anแlise' WHEN B4E_STATUS = '3' THEN 'Autorizado' "
cSql += "         WHEN B4E_STATUS = '4' THEN 'Negado' ELSE 'Aut. Parcialmente' END) STATUS "
cSql += " FROM " + RetSqlName('B4E') 
cSql += " WHERE B4E_FILIAL = '" + xFilial('B4E') + "' "

for nI := 1 to len(aPar)
	aWhere := strToArray( aPar[nI] , '=' )
	do case
	case aWhere[1] == 'CCHAVEPESQ' .and. len(aWhere)>1
		aSepara := Separa(aWhere[2], '~')
		cSql += " AND B4E_SEQB4D = '" + aSepara[1] + "' "
		cSql += " AND B4E_CODPEG = '" + aSepara[2] + "' "
	endCase
next

cSql += " AND D_E_L_E_T_ = ' ' "

cSql := changequery(cSql + " ORDER BY B4E_SEQUEN") 

return( {cAlias,cSql,cWhere,nRegPagina,cCampos,cFieldJ} )


user function PlGCloGuiR()
local lExsRDA	:= "FIELD_PREST" $ upper(paramixb[1])
local lExsData	:= "FIELD_DATAATD" $ upper(paramixb[1])
Local aPar  	:= StrTokArr2(paramixb[1] , '|' )
local nPosArr	:= 0
local aDados	:= {}

if lExsRDA 
	nPosArr := aScan(aPar, "Field_RDA")
	aPar[3] := "Field_RDA='" + PlsIntpad() + StrTokArr2(aPar[3] , '=' )[2] + "'"
	aDel(aPar, nPosArr)
	aSize(aPar, len(aPar)-1)
	paramixb[1] := ArrTokStr(aPar)
endif 
if lExsData
	nPosArr := aScan(aPar, "Field_DataAtd")
	paramixb[2] := aPar[nPosArr]
	aDel(aPar, nPosArr)
	aSize(aPar, len(aPar)-1)
	paramixb[1] := ArrTokStr(aPar)	
else
	paramixb[2] := ""
endif
aDados := execBlock("PLSMOSSOL", .f., .f., { paramixb[1], paramixb[2] } )
aDados[5] := "0*#Imprimir=GUIA+CHR(126)+TIPO+CHR(126)+STATUS, Guia=GUIA,Beneficiแrio=BENEFICIARIO,Data Guia=DATA, Tipo Guia=TIPO, Hora=HORPRO, Senha=SENHA, Status=STATUS"
return aDados
