#INCLUDE "FWLIBVERSION.CH"

/*/{Protheus.doc} EstCalcTerc
		Retorna um Array onde:
		aSaldo[1] := Saldo de Poder Terceiro
		aSaldo[2] := Quantidade Poder Terceiro Liberada(ainda nao faturada)
		aSaldo[3] := Saldo total do poder de terceiro ( Valor)
		aSaldo[4] := Soma do total de devolucoes do Poder Terceiros
		aSaldo[5] := Valor Total em Poder Terceiros
		aSaldo[6] := Quantidade Total em Poder Terceiros
		Função original : CalcTerc criada por Rosane L Chene em 23.05.95
		Fonte Original: MATXATU.PRX
	@type  Function
	@author reynaldo
	@since 16/04/2021
	@version version
	@param   cCod, caracter, Codigo do Produto
				cCliFor, caracter, Codigo do Cliente/Fornecedor
				cLoja, caracter, Codigo da Loja
				cIdentB6, caracter, Codigo do identIficador do SB6
				cTesB6, caracter, Codigo da Tes
				cTipo, caracter, Tipo da Nota
				dDtIni, caracter, Dt Inicial a ser Considerada na Composição do Saldo
				dDtFim, caracter, Dt Final a ser Considedara na Composiçãoo do Saldo
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function EstCalcTerc(cCod,cCliFor,cLoja,cIdentB6,cTesB6,cTipo,dDtIni,dDtFim)

Local aArq
Local aArqSD1
Local aStruSB6  := {}
Local aStruSD1  := {}
Local aStruTMP  := {}
Local aSaldo    := {0, 0, 0, 0, 0, 0}
Local lConsIni  := (ValType(dDtIni)== 'D' .And.!Empty(dDtIni))
Local lConsFim  := (ValType(dDtFim)== 'D' .And.!Empty(dDtFim))
Local cAliasSB6  := "SB6"
Local aNF        := {}
Local cNF        := ""
Local l103
Local cFilialSD1
Local aParamSQL := {}
Local cMD5

Local cQuery     := ""
Local nX         := 0
Local nPos
Local oStatSB6
Local cQrySD1
Local cAliasSD1
Local aWhereValue:= {}

Static oJGrpQrySB6
Static _cQrySD1

Static __lEstcVLib

__lEstcVLib 	:= If(__lEstcVLib == NIL,FWLibVersion() >= "20211116",__lEstcVLib)

If !Empty(cIdentB6)

	dbSelectArea("SF4") // somente garantir que a tabela exista
	dbSelectArea("SB6")

	l103 := IsInCallStack("MATA103")

	aArq    := GetArea()
	aArqSD1 := SD1->(GetArea())

	aWhereValue := {}

	If oJGrpQrySB6 == NIL
		oJGrpQrySB6 := JsonObject():New()
		oJGrpQrySB6:fromJson("{}")
	EndIf

	aStruSB6   := SB6->(dbStruct())
	cAliasSB6  := "CALCTERC"

	cTPCF := ' '
	If cTesB6 <= "500"
		If cTipo == "B"
			cTPCF := 'C'
		ElseIf cTipo == "N"
			cTPCF := 'F'
		EndIf
	Else
		If cTipo == "B"
			cTPCF := 'F'
		ElseIf cTipo == "N"
			cTPCF := 'C'
		EndIf
	EndIf

	aParamSQL := {}
	cQuery := "SELECT"
	cQuery += " B6_PRODUTO, "
	cQuery += " B6_CLIFOR, "
	cQuery += " B6_LOJA, "
	cQuery += " B6_IDENT, "
	cQuery += " F4_PODER3, "
	cQuery += " B6_DOC, "
	cQuery += " B6_SERIE, "
	cQuery += " B6_QUANT, "
	cQuery += " B6_QULIB, "
	cQuery += " B6_PRUNIT "
	cQuery += " FROM " +RetSqlName("SB6")+ " SB6 "
	cQuery += " INNER JOIN " +RetSqlName("SF4")+ " SF4 "
	cQuery += " ON SF4.F4_FILIAL= ? "
	aAdd(aParamSQL,xFilial("SF4") )
	cQuery += " AND SF4.F4_CODIGO=SB6.B6_TES "
	cQuery += " AND SF4.D_E_L_E_T_=' ' "
	cQuery += " WHERE SB6.B6_FILIAL= ? "
	aAdd(aParamSQL,xFilial("SB6") )
	cQuery += " AND SB6.B6_PRODUTO= ? "
	aAdd(aParamSQL,cCod )
	cQuery += " AND ( SB6.B6_IDENT= ? "
	aAdd(aParamSQL,cIdentB6 )
	cQuery += " OR ( SB6.B6_IDENTB6= ? "
	aAdd(aParamSQL,cIdentB6 )
	cQuery += " AND SB6.B6_QUANT = 0 )) "
	If ( lConsIni )
		cQuery += " and SB6.B6_DTDIGIT >= ? "
		aAdd(aParamSQL,dTos(dDtIni))
	EndIf
	If ( lConsFim )
		cQuery += " and SB6.B6_DTDIGIT <= ? "
		aAdd(aParamSQL,dTos(dDtFim))
	EndIf
	If !Empty(cTPCF)
		cQuery += " and SB6.B6_TPCF= ? "
		aAdd(aParamSQL,cTPCF)
	EndIf
	cQuery += " and SB6.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY 5,1,2,3" // as notas de poder3 de devoluç?o devem vir antes das remessas

	cMD5 := MD5(cQuery)
	oStatSB6 := oJGrpQrySB6[cMD5]

	// Monta FWPreparedStatement e ChangeQuery apenas 1x para cada variacao da query
	If oStatSB6 == NIL
		cQuery := ChangeQuery(cQuery)
		
		If __lEstcVLib
			oStatSB6 := FwExecStatement():New()
		Else
			oStatSB6 := FWPreparedStatement():New()
		EndIf 
		oStatSB6:SetQuery(cQuery)
		oJGrpQrySB6[cMD5] := oStatSB6
	EndIf

	// Seta as variaveis na query
	For nX := 1 To Len(aParamSQL)
		oStatSB6:SetString(nX, aParamSQL[nX])
	Next nX

	// Recupera a query transformada
	If __lEstcVLib
		oStatSB6:OpenAlias(cAliasSB6)
	Else
		cQuery := oStatSB6:getFixQuery()
		// Abre um alias com a query e ja executa o TCSetField nos campos
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.T.)
	EndIf 

	For nX := 1 To Len(aStruSB6)
		If ( aStruSB6[nX][2] <> "C" )
			TcSetField(cAliasSB6,aStruSB6[nX][1],aStruSB6[nX][2],aStruSB6[nX][3],aStruSB6[nX][4])
		EndIf
	Next nX

	cFilialSD1 := xFilial("SD1")
	SD1->(dbSetOrder(1))
	While (cAliasSB6)->(!Eof())

		If (cAliasSB6)->F4_PODER3 == "R"
			aSaldo[1]+= (cAliasSB6)->B6_QUANT
			aSaldo[2]+= (cAliasSB6)->B6_QULIB

			If (cAliasSB6)->B6_QUANT == 0
				aSaldo[5]+= (cAliasSB6)->B6_PRUNIT
			Else
				aSaldo[5]+= (cAliasSB6)->B6_PRUNIT * (cAliasSB6)->B6_QUANT
				aSaldo[6]:= (cAliasSB6)->B6_QUANT
			EndIf

			If l103
				aSaldo[3] += ((cAliasSB6)->B6_PRUNIT*(cAliasSB6)->B6_QUANT)-aSaldo[4]
			Else
				aSaldo[3] += ((cAliasSB6)->B6_PRUNIT*IIF((cAliasSB6)->B6_QUANT==0,1,aSaldo[1]))
			EndIf

		ElseIf (cAliasSB6)->F4_PODER3 == "D"
			aSaldo[1]-= (cAliasSB6)->B6_QUANT

			cAliasSD1  := GetNextAlias()

			If aStruSD1==NIL
				aStruSD1   := SD1->(dbStruct())
			EndIf

			If _cQrySD1== NIL
				cQrySD1 := ""
				cQrySD1 += "select "
				cQrySD1 += "SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_VALDESC, SD1.D1_TOTAL, "
				cQrySD1 += "SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM "
				cQrySD1 += "from "+RetSqlName("SD1")+" SD1 "
				cQrySD1 += "where "
				cQrySD1 += "SD1.D1_FILIAL = ? "
				cQrySD1 += "AND SD1.D1_DOC = ? "
				cQrySD1 += "AND SD1.D1_SERIE = ? "
				cQrySD1 += "AND SD1.D1_FORNECE = ? "
				cQrySD1 += "AND SD1.D1_LOJA = ? "
				cQrySD1 += "AND SD1.D1_COD = ? "
				cQrySD1 += "AND SD1.D1_IDENTB6 = ? "
				cQrySD1 += "AND SD1.D_E_L_E_T_ = ' ' "

				_cQrySD1 := ChangeQuery(cQrySD1)
			EndIf

			aWhereValue := {;
					cFilialSD1,;
					(cAliasSB6)->B6_DOC,;
					(cAliasSB6)->B6_SERIE,;
					(cAliasSB6)->B6_CLIFOR,;
					(cAliasSB6)->B6_LOJA,;
					(cAliasSB6)->B6_PRODUTO,;
					(cAliasSB6)->B6_IDENT;
			}

			// Abre um alias com a query e ja executa o TCSetField nos campos
			dbUseArea(.T.,"TOPCONN",TCGenQry2(NIL,NIL,_cQrySD1, aWhereValue ),cAliasSD1,.T.,.T.)

			aStruTMP := (cAliasSD1)->(dbStruct())
			For nX := 1 To Len(aStruTMP)
				If ( aStruTMP[nX][2] <> "C" )
					nPos := aScan(aStruSD1,{|Field|Field[1]==aStruTMP[nX,1]})
					If nPos >0 .AND. aStruSD1[nX][2] <> "C"
						TcSetField(cAliasSD1,aStruSD1[nPos][1],aStruSD1[nPos][2],aStruSD1[nPos][3],aStruSD1[nPos][4])
					EndIf
				EndIf
			Next nX

			While (cAliasSD1)->(!Eof())
				// Verifica se o Item já não está somado para não duplicar a soma //
				cNF:= cFilialSD1+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEM
					If Ascan(aNF,cNF) = 0
						If l103
						aSaldo[4]+= (((cAliasSD1)->D1_QUANT * (cAliasSD1)->D1_VUNIT) - (cAliasSD1)->D1_VALDESC)
						Else
						aSaldo[4]+= ((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC)
						EndIf
						aadd(aNF,cNF)
					EndIf

				(cAliasSD1)->(dbSkip())
			EndDo
			dbSelectArea(cAliasSD1)
			dbCloseArea()

		EndIf
		DbSelectArea(cAliasSB6)
		DbSkip()
	EndDo

	//
	// Calculo do valor unitario
	//
	aSaldo[3] := A410Arred(If(aSaldo[1]==0,aSaldo[3],Round(aSaldo[3]/aSaldo[1],TamSX3("D2_PRCVEN")[2])),"D2_PRCVEN")

	dbSelectArea(cAliasSB6)
	dbCloseArea()
	dbSelectArea("SB6")

	If aStruSD1<>NIL
		For nX := 1 To len(aStruSD1)
			aSize(aStruSD1[nX],0)
			aStruSD1[nX]:=NIL
		Next nX
		aSize(aStruSD1,0)
	EndIf
	aStruSD1 := NIL

	For nX := 1 To len(aStruSB6)
		aSize(aStruSB6[nX],0)
		aStruSB6[nX] := NIL
	Next nX
	aSize(aStruSB6,0)
	aStruSB6:=NIL

	For nX := 1 To len(aStruTMP)
		aSize(aStruTMP[nX],0)
		aStruTMP[nX] := NIL
	Next nX
	aSize(aStruTMP,0)
	aStruTMP:=NIL

	aSize(aParamSQL,0)
	aParamSQL:=NIL

	aSize(aNF,0)
	aNF:=NIL

	aSize(aWhereValue,0)
	aWhereValue:=NIL

	RestArea(aArqSD1)
	RestArea(aArq)

EndIf

Return(aSaldo)
