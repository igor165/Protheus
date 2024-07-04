#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "TOPCONN.CH"

#DEFINE _NOMEIMP   01 
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
#DEFINE _CODPROD   16

/*/{Protheus.doc} EuaTax
    Function used to get EUA Tax Formula
    @type  Function
    @author Yves Oliveira
    @since 25/03/2020
    /*/
Function EuaTax(cCalculo,nItem,aInfo)

Local aArea	 := getArea()
Local cQuery := ""
Local cAlias := GetNextAlias()
Local nTaxRet := 0
Local aImposto
Local lXFis
Local xRet
Local aItemINFO 
Local lTaxFrete := .F. 

Local nValImpFr  := 0
Local nBaseImpFr := 0
Local nAliqFr    := 0

lXFis := (MaFisFound() .and. ProcName(1)  <> "EXECBLOCK")

If !lXFis //caso for faturamento por produto
	aItemINFO	:= ParamIxb[1]
	aImposto	:= aClone(ParamIxb[2])  

	//Verifica se calcula taxa sobre o frete
	lTaxFrete := getTaxFrete()


	//caso nao tenha taxa sobre o frete eu sero o frete para calculo
	If !lTaxFrete
		aItemINFO[_FLETE] := 0	
	EndIf

	//aqui eu buco aliq e valor do imposto
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	cQuery += "" + CRLF
	cQuery += "SELECT SUM(A1L_VALIMP) AS A1L_VALIMP,AVG(A1L_BASIMP) AS A1L_BASIMP,SUM(A1L_ALIIMP) AS A1L_ALIIMP "+ CRLF
	cQuery += "FROM " + RetSqlTab("A1L") + CRLF
	cQuery += "WHERE D_E_L_E_T_= ' ' "+ CRLF
	cQuery += "AND A1L_FILIAL = '" + xFilial("A1L") +"'" + CRLF
	cQuery += "AND A1L_INVOIC  = '" + SC5->C5_NUM + "' "+ CRLF
	cQuery += "AND A1L_CLIENT  = '" + SC5->C5_CLIENTE + "' "+ CRLF
	cQuery += "AND A1L_LOJA    = '" + SC5->C5_LOJACLI + "' "+ CRLF
	cQuery += "AND A1L_SKU     = '" + aImposto[_CODPROD] + "' "+ CRLF

	cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)
   
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If !(cAlias)->(Eof())

		If (cAlias)->A1L_VALIMP > 0  //quer dizer que tem imposto
			nBase := (cAlias)->A1L_BASIMP  + aItemINFO[_FLETE] + aItemINFO[_GASTOS] 
		Else 
			nBase :=  aItemINFO[_FLETE] + aItemINFO[_GASTOS] 
		EndIf	

		aImposto[_BASECALC] := nBase 
		aImposto[_ALIQUOTA] :=  (cAlias)->A1L_ALIIMP
		aImposto[_IMPUESTO] := ( nBase  *  (cAlias)->A1L_ALIIMP ) / 100		

	EndIf

	(cAlias)->(DbCloseArea()) 

	xRet := aImposto	

Else
	If FunName() == "MATA410" .And. IsInCallStack("Ma410Impos")

		getTaxFrete(@nValImpFr, @nBaseImpFr, @nAliqFr)

		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf

		cQuery += "" + CRLF
		cQuery += "SELECT SUM(A1L_VALIMP) AS A1L_VALIMP,AVG(A1L_BASIMP) AS A1L_BASIMP,SUM(A1L_ALIIMP) AS A1L_ALIIMP, "+ CRLF

		cQuery += "(SELECT COUNT(1) FROM " + RetSqlName("SC6") + " WHERE D_E_L_E_T_ = '  ' AND C6_FILIAL = '" + xFilial("SC6") + "'AND C6_NUM = '" +  SC5->C5_NUM  + "') QTD" + CRLF

		cQuery += "FROM " + RetSqlTab("A1L,SC6") + CRLF
		cQuery += "WHERE A1L.D_E_L_E_T_= ' ' "+ CRLF
		cQuery += "AND A1L_FILIAL = '" + xFilial("A1L") +"'" + CRLF
		cQuery += "AND A1L_INVOIC  = '" + SC5->C5_NUM + "' "+ CRLF
		cQuery += "AND A1L_CLIENT  = '" + SC5->C5_CLIENTE + "' "+ CRLF
		cQuery += "AND A1L_LOJA    = '" + SC5->C5_LOJACLI + "' "+ CRLF
		
		cQuery += "AND C6_FILIAL = '" + xFilial("SC6") +"'" + CRLF
		cQuery += "AND SC6.D_E_L_E_T_= ' ' "+ CRLF
		cQuery += "AND A1L_INVOIC = C6_NUM"+ CRLF
		cQuery += "AND A1L_CLIENT = C6_CLI"+ CRLF
		cQuery += "AND A1L_LOJA = C6_LOJA"+ CRLF
		cQuery += "AND A1L_SKU = C6_PRODUTO"+ CRLF
		cQuery += "AND C6_ITEM = '" + StrZero(nItem, TamSx3("C6_ITEM")[1]) + "'"+ CRLF

		cQuery := ChangeQuery(cQuery)
    	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)
		//TcQuery cQuery new Alias cAlias

		DbSelectArea(cAlias)
		(cAlias)->(DbGoTop())

		If nBaseImpFr > 0
			nBaseImpFr := Round(nBaseImpFr / (cAlias)->QTD, 3)
		EndIf
		If !(cAlias)->(Eof())
			If cCalculo == "B" //Base
				nTaxRet := (cAlias)->A1L_BASIMP + nBaseImpFr  
			ElseIf cCalculo == "A" //Aliquota
				nTaxRet := (cAlias)->A1L_ALIIMP
			ElseIf cCalculo == "V" //Valor do Imposto
				nTaxRet :=( ((cAlias)->A1L_BASIMP + nBaseImpFr) *  (cAlias)->A1L_ALIIMP ) / 100
			EndIf
		EndIf

		(cAlias)->(DbCloseArea()) 

	EndIf

	xRet := nTaxRet
	
EndIf 	

restArea(aArea)

Return( xRet ) 

/*/{Protheus.doc} EuaTax
    Function used to get EUA Tax Frete Formula
    @type  Function
    @author Yves Oliveira
    @since 25/03/2020
    /*/
Static Function getTaxFrete(nValImp, nBaseImp, nAliq)

	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local lRet := .F. 

	Default nValImp  := 0
	Default nBaseImp := 0
	Default nAliq    := 0

	//aqui eu buco aliq e valor do imposto
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	cQuery += "" + CRLF
	cQuery += "SELECT SUM(A1L_VALIMP) AS A1L_VALIMP,AVG(A1L_BASIMP) AS A1L_BASIMP,SUM(A1L_ALIIMP) AS A1L_ALIIMP "+ CRLF
	cQuery += "FROM " + RetSqlTab("A1L") + CRLF
	cQuery += "WHERE D_E_L_E_T_= ' ' "+ CRLF
	cQuery += "AND A1L_FILIAL = '" + xFilial("A1L") +"'" + CRLF
	cQuery += "AND A1L_INVOIC  = '" + SC5->C5_NUM + "' "+ CRLF
	cQuery += "AND A1L_CLIENT  = '" + SC5->C5_CLIENTE + "' "+ CRLF
	cQuery += "AND A1L_LOJA    = '" + SC5->C5_LOJACLI + "' "+ CRLF
	cQuery += "AND A1L_SKU     = '" + "FRETE" + "' "+ CRLF


	cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If !(cAlias)->(Eof())
		If (cAlias)->A1L_VALIMP > 0  //quer dizer que tem imposto
			nValImp  := (cAlias)->A1L_VALIMP
			nBaseImp := (cAlias)->A1L_BASIMP
			nAliq    := (cAlias)->A1L_ALIIMP
			lRet 	 := .T.  //quer dizer que tem imposto
		EndIf
	EndIf

	(cAlias)->(DbCloseArea()) 

Return lRet
