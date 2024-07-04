#include "protheus.ch"
#include "Atflpgl.ch"
STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfLOnl01 ³ Autor ³ Claudio Donizete Souza³ Data ³ 27/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bens nao classificados - por filial               		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfLOnl01  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[n][1] = Quantidade de bens nao classificados          ³±±
±±³          ³ aRet[n][2] = Valor dos bens nao classificados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfLOnl01
Local aRet 			:= {}

Local cFilAte		:= Replicate("z",Len(cFilAnt))
Local cAliasQry
Local cAlias		:= Alias()
Local cFilOld 		:= cFilAnt
Local nQtde 		:= 0
Local nValor 		:= 0
Local cMoeda  		:= AllTrim(GetMv("MV_ATFMOED"))
Local cDescMoeda	:= AllTrim(GETMV("MV_SIMB" + cMoeda))
Local cSum
Local nInc			:= 0
Local aSM0			:= AdmAbreSM0()
Local cFilProc		:= ""
Local lExclusivo	:= AdmTabExc("SN3") //Analisa se a tabela esta exclusiva

cSum := "%Sum(SN3.N3_VORIG"+cMoeda+")%"

// Processa todo o arquivo de filiais ou apenas a filial atual
For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. aSM0[nInc][2] <= cFilAte
		cFilAnt	:= aSM0[nInc][2]
		nQtde	:= 0
		nValor	:= 0

		//Tratamento Gestao Corporativa
		If Len(AllTrim(xFilial("SN3")) ) > 2
			If Alltrim(cFilProc) != Alltrim(xFilial("SN3"))
				cFilProc:= xFilial("SN3")
			Else
				Loop
			EndIf
		EndIf

		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			COLUMN QTDBENS   AS NUMERIC(10,4)
			COLUMN VLRBENS	  AS NUMERIC(17,4)
			SELECT
				Sum(SN1.N1_QUANTD) QTDBENS, %Exp:cSum% VLRBENS
			FROM %table:SN3% SN3
			LEFT JOIN %table:SN1% SN1 ON
				SN1.N1_FILIAL =  %xfilial:SN1% AND
				SN1.N1_CBASE = SN3.N3_CBASE AND
				SN1.N1_ITEM  = SN3.N3_ITEM  AND
				SN1.%notDel%
			WHERE
				SN3.N3_FILIAL = %xfilial:SN3% AND
				SN3.N3_CCONTAB = ' ' AND
				SN3.N3_BAIXA = '0' AND
				SN3.%notDel%
		EndSql
		nQtde		:= (cAliasQry)->QTDBENS
		nValor	:= (cAliasQry)->VLRBENS
		(cAliasQry)->(DbCloseArea())

		Aadd( aRet,	{ aSM0[nInc][2] + "-" + aSM0[nInc][7],; // Combo
			 			{	{ STR0001, Transform(nQtde, "@E 999999,999,999,999"),CLR_RED, },; // "Quantidade"
							{ STR0002 + " em " + cDescMoeda, Transform(nValor, "@E 999,999,999,999.99"), CLR_RED, } } } ) // "Valor"

		// Se o arquivo for compartilhado, processa apenas uma vez
		If !lExclusivo
			Exit
		Endif
	EndIf
Next

cFilAnt := cFilOld

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfLOnl02 ³ Autor ³ Claudio Donizete Souza³ Data ³ 02/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bens próximos do final da depreciacao - por filial         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfLOnl02  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[n][1] = Quantidade de bens nao classificados          ³±±
±±³          ³ aRet[n][2] = Valor dos bens nao classificados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfLOnl02
Local aRet 			:= {}
Local cFilDe		:= "" // mv_par01
Local cFilAte		:= Replicate("z",Len(cFilAnt)) // mv_par02
Local cAliasQry
Local aAreaSm0 		:= SM0->(GetArea())
Local cAlias		:= Alias()
Local cFilOld 		:= cFilAnt
Local nQtde 		:= 0
Local nValor 		:= 0
Local cAliasSn3
Local cAliasSn1
LocaL nPerc 		:= 0
Local cMoeda  		:= AllTrim(GetMv("MV_ATFMOED"))
Local cQuery
Local aStru 		:= SN3->(DbStruct())
Local cDescMoeda	:= AllTrim(GETMV("MV_SIMB" + cMoeda))
Local nInc			:= 0
Local aSM0			:= AdmAbreSM0()
Local cFilProc		:= ""
Local lExclusivo	:= AdmTabExc("SN3") //Analisa se a tabela esta exclusiva

Pergunte("ATFPGL01",.F.)

cFilDe	:= mv_par01
cFilAte	:= mv_par02

// Processa todo o arquivo de filiais ou apenas a filial atual
For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. aSM0[nInc][2] <= cFilAte
		cFilAnt := aSM0[nInc][2]

		//Tratamento Gestao Corporativa
		If Len(AllTrim(xFilial("SN3")) ) > 2
			If Alltrim(cFilProc) != Alltrim(xFilial("SN3"))
				cFilProc:= xFilial("SN3")
			Else
				Loop
			EndIf
		EndIf

		cAliasQry := GetNextAlias()
		cQuery := "SELECT * "
		cQuery += "FROM " + RetSqlName("SN3") + " SN3 "
		cQuery += "LEFT JOIN "+ RetSqlName("SN1") + " SN1 ON "
		cQuery += "SN1.N1_FILIAL =  '" + xFilial("SN1") + "' AND "
		cQuery += "		SN1.N1_CBASE = SN3.N3_CBASE AND "
		cQuery += "		SN1.N1_ITEM  = SN3.N3_ITEM  AND "
		cQuery += "		SN1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "		SN3.N3_FILIAL = '" + xFilial("SN3") + "' AND "
		cQuery += "		SN3.N3_CCONTAB <> ' ' AND "
		cQuery += "		SN3.N3_CCDEPR <> ' ' AND "
		cQuery += "		SN3.N3_CDEPREC <> ' ' AND "
		cQuery += "		SN3.N3_BAIXA = '0' AND "
		cQuery += "		SN3.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		cAliasSn3 := cAliasQry
		cAliasSn1 := cAliasQry
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		aEval(aStru, { |e|	If(e[2] <> "C", TcSetField(cAliasQry,e[1],e[2],e[3],e[4]),) } )

		While (cAliasSn3)->(!Eof()) .And.;
				(cAliasSn3)->N3_FILIAL == xFilial("SN3")

			nPerc := ((cAliasSn3)->&("N3_VRDACM"+cMoeda + If(cMoeda="1","+N3_VRCDA"+cMoeda,"")) / (cAliasSn3)->&("N3_VORIG"+cMoeda + If(cMoeda="1","+N3_VRCACM"+cMoeda,"") + "+N3_AMPLIA"+cMoeda)) * 100

			If !Empty( (cAliasSn3)->N3_CCONTAB ) .And.;
				!Empty( (cAliasSn3)->N3_CCDEPR ) .And.;
				!Empty( (cAliasSn3)->N3_CDEPREC )	.And.;
				nPerc > mv_par03

				nQtde		+= (cAliasSn1)->N1_QUANTD
				nValor	+= (cAliasSn3)->&("N3_VORIG"+cMoeda + If(cMoeda="1","+N3_VRCACM"+cMoeda,"") + "+N3_AMPLIA"+cMoeda)
			Endif

			(cAliasSn3)->(DbSkip())
		End

		(cAliasQry)->(DbCloseArea())

		// Se o arquivo for compartilhado, processa apenas uma vez
		If !lExclusivo
			Exit
		Endif
	EndIf
Next

Aadd( aRet, { STR0001, Transform(nQtde, "@E 999999,999,999,999"),CLR_RED,  } ) 			// "Quantidade"
Aadd( aRet, { STR0002 + " em " + cDescMoeda, Transform(nValor, "@E 999,999,999,999.99"), CLR_RED  ,  } ) 	// "Valor"

cFilAnt := cFilOld

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfLOnl03 ³ Autor ³ Claudio Donizete Souza³ Data ³ 17/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Data da ultima depreciacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfLOnl03  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[1][1] = Data da ultima depreciacao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function	AtfLOnl03
Local aRet 		:= {}
Local dUltDepr := GetMv("MV_ULTDEPR")

Aadd( aRet, { STR0003, Transform(dUltDepr, ""),CLR_RED,  } ) 			// "Data da ultima depreciação"

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfLOnl04 ³ Autor ³ Claudio Donizete Souza³ Data ³ 22/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tempo medio de classificacaso - por filial        		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfLOnl04  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[n][1] = Quantidade de bens nao classificados          ³±±
±±³          ³ aRet[n][2] = Valor dos bens nao classificados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfLOnl04
Local aRet			:= {}
Local cFilDe		:= ""
Local cFilAte		:= Replicate("z",Len(cFilAnt))
Local cAliasQry
Local aAreaSm0		:= SM0->(GetArea())
Local cAlias		:= Alias()
Local cFilOld		:= cFilAnt
Local nPrzxVlr		:= 0
Local nValor		:= 0
Local cMoeda		:= AllTrim(GetMv("MV_ATFMOED"))
Local cAliasSn3
Local cAliasSn1
Local nInc			:= 0
Local aSM0			:= AdmAbreSM0()
Local cFilProc		:= ""
Local lExclusivo	:= AdmTabExc("SN3") //Analisa se a tabela esta exclusiva

// Processa todo o arquivo de filiais ou apenas a filial atual
For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. aSM0[nInc][2] <= cFilAte
		cFilAnt		:= aSM0[nInc][2]
		nPrzxVlr	:= 0
		nValor 		:= 0

		//Tratamento Gestao Corporativa
		If Len(AllTrim(xFilial("SN3")) ) > 2
			If Alltrim(cFilProc) != Alltrim(xFilial("SN3"))
				cFilProc:= xFilial("SN3")
			Else
				Loop
			EndIf
		EndIf

		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			COLUMN N1_DTCLASS AS DATE
			COLUMN N1_AQUISIC AS DATE
			COLUMN N1_QUANTD AS NUMERIC(10,4)
			COLUMN N3_VORIG1 AS NUMERIC(17,4)
			COLUMN N3_VORIG2 AS NUMERIC(17,4)
			COLUMN N3_VORIG3 AS NUMERIC(17,4)
			COLUMN N3_VORIG4 AS NUMERIC(17,4)
			COLUMN N3_VORIG5 AS NUMERIC(17,4)
			SELECT  *
			FROM %table:SN3% SN3
			LEFT JOIN %table:SN1% SN1 ON
				SN1.N1_FILIAL =  %xfilial:SN1% AND
				SN1.N1_CBASE = SN3.N3_CBASE AND
				SN1.N1_ITEM  = SN3.N3_ITEM  AND
				SN1.%notDel%
			WHERE
				SN3.N3_FILIAL = %xfilial:SN3% AND
				SN3.N3_CCONTAB <> ' ' AND
				SN3.N3_BAIXA = '0' AND
				SN1.N1_DTCLASS  <> ' '  AND
				SN3.%notDel%
		EndSql
		cAliasSn3 := cAliasQry
		cAliasSn1 := cAliasQry


		While (cAliasSn3)->(!Eof())
			If !Empty((cAliasSn1)->N1_DTCLASS) .And.;
				!Empty((cAliasSn1)->N3_CCONTAB)
				nPrzxVlr	+= ((cAliasSn1)->(N1_DTCLASS-N1_AQUISIC)*(cAliasSn3)->&("N3_VORIG"+cMoeda))
				nValor	+= SN3->&("N3_VORIG"+cMoeda)
			Endif
			(cAliasSn3)->(DbSkip())
		End

		Aadd( aRet,	{ aSM0[nInc][2] + "-" + aSM0[nInc][7],; // Combo
			 			{	{ STR0004, If(nPrzxVlr > 0 .And. nValor > 0,Transform(nPrzxVlr / nValor, "@E 999999,999,999.9999"),"-"), CLR_RED, } } } )  // "Média ponderada em dias"

		// Se o arquivo for compartilhado, processa apenas uma vez
		If !lExclusivo
			Exit
		Endif
	EndIf
Next

cFilAnt := cFilOld

(cAliasQry)->(DbCloseArea())

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfLOnl05 ³ Autor ³ Claudio Donizete Souza³ Data ³ 24/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bens de maior valor                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfLOnl05  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[1][1] = Data da ultima depreciacao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfLOnl05
Local aRet 			:= {}
Local cFilDe		:= "" // mv_par01
Local cFilAte		:= Replicate("z",Len(cFilAnt)) // mv_par02
Local cAliasQry
Local aAreaSm0 		:= SM0->(GetArea())
Local cAlias		:= Alias()
Local cFilOld 		:= cFilAnt
Local nQtde 		:= 0
Local nValor 		:= 0
Local cAliasSn3
Local cAliasSn1
LocaL nPerc 		:= 0
Local cMoeda  		:= AllTrim(GetMv("MV_ATFMOED"))
Local cQuery
Local aStru 		:= SN3->(DbStruct())
Local cDescMoeda	:= AllTrim(GETMV("MV_SIMB" + cMoeda))
Local nIndFil
Local nIndGrupo
Local lTemBem 		:= .F.
Local bFor
Local bWhile
Local nInc			:= 0
Local aSM0			:= AdmAbreSM0()
Local cFilProc		:= ""
Local lExclusivo	:= AdmTabExc("SN3") //Analisa se a tabela esta exclusiva

Local cTypes10	:= "" // CAZARINI - 29/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10	:= {}
Local nTypes10	:= 0

Local cTypesNM	:= "" // CAZARINI - 29/03/2017 - If is Russia, add new valuations models - main models
Local aTypesNM	:= {}
Local nTypesNM	:= 0
Pergunte("ATFPGL02",.F.)

cFilDe	:= mv_par01
cFilAte	:= mv_par02

// Processa todo o arquivo de filiais ou apenas a filial atual
For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. aSM0[nInc][2] <= cFilAte
		cFilAnt := aSM0[nInc][2]

		//Tratamento Gestao Corporativa
		If Len(AllTrim(xFilial("SN3")) ) > 2
			If Alltrim(cFilProc) != Alltrim(xFilial("SN3"))
				cFilProc:= xFilial("SN3")
			Else
				Loop
			EndIf
		EndIf

		cAliasQry := GetNextAlias()
		cQuery := "SELECT SN1.N1_GRUPO, SNG.NG_DESCRIC, SUM(N3_VORIG"+cMoeda+") N3_VORIG"+cMoeda + " "
		cQuery += "FROM " + RetSqlName("SN3") + " SN3 "
		cQuery += "JOIN "+ RetSqlName("SN1") + " SN1 ON "
		cQuery += "SN1.N1_FILIAL =  '" + xFilial("SN1") + "' AND "
		cQuery += "		SN1.N1_CBASE = SN3.N3_CBASE AND "
		cQuery += "		SN1.N1_ITEM  = SN3.N3_ITEM  AND "
		cQuery += "		SN1.D_E_L_E_T_ = ' ' "
		cQuery += "JOIN "+ RetSqlName("SNG") + " SNG ON "
		cQuery += "SNG.NG_FILIAL =  '" + xFilial("SNG") + "' AND "
		cQuery += "		SNG.NG_GRUPO = SN1.N1_GRUPO AND "
		cQuery += "		SNG.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "		SN3.N3_FILIAL = '" + xFilial("SN3") + "' AND "
		If !lIsRussia
			cQuery += "		SN3.N3_TIPO IN ( '01','10','16','17' ) AND "
		Else
			cTypes10 := AtfNValMod({1}, "|") // CAZARINI - 29/03/2017 - If is Russia, add new valuations models - main models
			cTypesNM := AtfNValMod({3,4}, "|") // CAZARINI - 29/03/2017 - If is Russia, add new valuations models - 17 and 16 models

			aTypes10 := Separa(cTypes10, '|', .f.)
			aTypesNM := Separa(cTypesNM, '|', .f.)
			
			If len(aTypes10) = 0 .AND. len(aTypesNM) = 0
				cQuery += "			SN3.N3_TIPO IN ('01','10','16','17') AND "
			Else
				cQuery += "			SN3.N3_TIPO IN ('01','10','16','17'"
				
				For nTypes10 := 1 to len(aTypes10)
					cQuery += ",'" + aTypes10[nTypes10] + "' "
				Next nTypes10
				
				For nTypesNM := 1 to len(aTypesNM)
					cQuery += ",'" + aTypesNM[nTypesNM] + "' "
				Next nTypesNM
				
				cQuery += "			) AND "
			Endif
		Endif
		cQuery += "		SN3.N3_BAIXA = '0' AND "
		cQuery += "		SN1.N1_GRUPO <> ' ' AND "
		cQuery += "		SN3.D_E_L_E_T_ = ' ' "
		cQuery += "GROUP BY N1_GRUPO, NG_DESCRIC "

		cQuery := ChangeQuery(cQuery)
		cAliasSn3 := cAliasQry
		cAliasSn1 := cAliasQry
		cAliasSng := cAliasQry
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		aEval(aStru, { |e|	If(e[2] <> "C" .And. FieldPos(e[1]) > 0, ;
									TcSetField(cAliasQry,e[1],e[2],e[3],e[4]),) } )
		bFor := { || .T. }
		bWhile := { || .T. }

		lTemBem := .F.
		While (cAliasSn3)->(!Eof()) .And.;
				Eval(bWhile)

			If Eval(bFor)
				nValor := (cAliasSn3)->&("N3_VORIG"+cMoeda)

				// Pesquisa a filial
				If (nIndFil := Ascan(aRet, {|e| e[1] == aSM0[nInc][2] + "-" + aSM0[nInc][7] } )) > 0
					// Pesquisa o grupo dentro da filial
					nIndGrupo := Ascan(aRet[nIndFil], {|e| ValType(e)=="A" .And. e[1] == (cAliasSn1)->N1_GRUPO + "-" + (cAliasSng)->NG_DESCRIC } )
					If nIndGrupo > 0
						aRet[nIndFil][nIndGrupo][2] +=  nValor
					Else
						Aadd( aRet[nIndFil][2],	 { (cAliasSn1)->N1_GRUPO + "-" + (cAliasSng)->NG_DESCRIC, nValor,CLR_RED, } )
					Endif
				Else
					lTemBem := .T.
					Aadd( aRet,	{ aSM0[nInc][2] + "-" + aSM0[nInc][7],; // Combo
			 						{ { (cAliasSn1)->N1_GRUPO + "-" + (cAliasSng)->NG_DESCRIC, nValor,CLR_RED, } } } ) // "Valor"
				Endif
			Endif

			(cAliasSn3)->(DbSkip())
		End

		If !lTemBem
			Aadd( aRet,	{ aSM0[nInc][2] + "-" + aSM0[nInc][7],; // Combo
							{ { "", "",CLR_RED, } } } ) // "Valor"
		Endif

		(cAliasQry)->(DbCloseArea())

		// Se o arquivo for compartilhado, processa apenas uma vez
		If lExclusivo
			Exit
		Endif
	EndIf
Next

// Ordena por valor
For nIndFil := 1 To Len(aRet)
	If ValType(aRet[nIndFil][2]) == "A"
		aSort(aRet[nIndFil][2],,,{|x,y| x[2] > y[2] } )
		aEval(aRet[nIndFil][2], { |e| If(ValType(e[2]) == "N",e[2] := Transform(e[2],"@E 999999,999,999,999.99"),Nil) } )
	Endif
Next

cFilAnt := cFilOld

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfLOnl06 ³ Autor ³ Claudio Donizete Souza³ Data ³ 13/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valor dos bens adquiridos nos ultimos meses                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfLOnl06  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[1][1] = Valor dos bens adquiridos nos ultimos meses   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function	AtfLOnl06
Local aRet := {}
Local cAliasQry
Local cQuery
Local cMoeda  := AllTrim(GetMv("MV_ATFMOED"))
Local dDtIni
Local nAscan
Local aMeses := {	STR0005,;	// "Janeiro"
						STR0006,;	// "Fevereiro"
						STR0007,;	// "Março"
						STR0008,;	// "Abril"
						STR0009,;	// "Maio"
						STR0010,;	// "Junho"
						STR0011,;	// "Julho"
						STR0012,;	// "Agosto"
						STR0013,;	// "Setembro"
						STR0014,;	// "Outubro"
						STR0015,;	// "Novembro"
						STR0016 }	// "Dezembro"
Local aStru := SN4->(DbStruct())
Local nX

Pergunte("ATFPGL03",.F.)

dDtIni := FirstDay(MsSomaMes(dDatabase,mv_par01*(-1)))

cAliasQry := GetNextAlias()
cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("SN4") + " SN4 "
cQuery += "WHERE "
cQuery += "		SN4.N4_FILIAL = '" + xFilial("SN4") + "' AND "
cQuery += "		SN4.N4_OCORR = '05' AND "
cQuery += "		SN4.N4_DATA >= '" + DTOS(dDtIni) + "' AND "
cQuery += "		SN4.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
aEval(aStru, { |e|	If(e[2] <> "C" .And. FieldPos(e[1]) > 0, ;
							TcSetField(cAliasQry,e[1],e[2],e[3],e[4]),) } )

While (cAliasQry)->(!Eof())
	nAscan := Ascan(aRet, { |e| e[1] == Left(DTOS((cAliasQry)->N4_DATA),6) } )
	If nAscan > 0
		aRet[nAscan][2] += (cAliasQry)->&("N4_VLROC"+cMoeda)
	Else
		Aadd( aRet, { Left(DTOS((cAliasQry)->N4_DATA),6), (cAliasQry)->&("N4_VLROC"+cMoeda), CLR_RED, } )
	Endif
	(cAliasQry)->(DbSkip())
End

// Converte os dados no formato do Painel
For nX := 1 To Len(aRet)
	nAscan := Val(Right(aRet[nX][1],2))
	If nAscan > 0	.And. nAscan <= 12
		aRet[nX][1] := aMeses[nAscan] + "/" + Left(aRet[nX][1],4)
	Endif
	aRet[nX][2] := Transform(aRet[nX][2], PesqPict("SN4","N4_VLROC"+cMoeda) )
Next

(cAliasQry)->(DbCloseArea())

Return aRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfLOnl07 ³ Autor ³ Claudio Donizete Souza³ Data ³ 16/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aquisicoes por grupo nos ultimos meses                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfLOnl07  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[1][1] = Valor dos bens adquiridos nos ultimos meses   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function	AtfLOnl07
Local aRet := {}
Local cAliasQry
Local cQuery
Local cMoeda  := AllTrim(GetMv("MV_ATFMOED"))
Local dDtIni
Local nAscan
Local nIndMes
Local nIndGrupo
Local aMeses := {	STR0005,;	// "Janeiro"
						STR0006,;	// "Fevereiro"
						STR0007,;	// "Março"
						STR0008,;	// "Abril"
						STR0009,;	// "Maio"
						STR0010,;	// "Junho"
						STR0011,;	// "Julho"
						STR0012,;	// "Agosto"
						STR0013,;	// "Setembro"
						STR0014,;	// "Outubro"
						STR0015,;	// "Novembro"
						STR0016  }	// "Dezembro"
Local aStru := SN4->(DbStruct())
Local nX

Pergunte("ATFPGL04",.F.)

dDtIni := FirstDay(MsSomaMes(dDatabase,mv_par01*(-1)))

cAliasQry := GetNextAlias()
cQuery := "SELECT N4_DATA, N4_VLROC1, N4_VLROC2, N4_VLROC3, N4_VLROC4, N4_VLROC5, N1_GRUPO, NG_DESCRIC "
cQuery += "FROM " + RetSqlName("SN4") + " SN4 "
cQuery += "JOIN "+ RetSqlName("SN1") + " SN1 ON "
cQuery += "SN1.N1_FILIAL =  '" + xFilial("SN1") + "' AND "
cQuery += "		SN1.N1_CBASE = SN4.N4_CBASE AND "
cQuery += "		SN1.N1_ITEM  = SN4.N4_ITEM  AND "
cQuery += "		SN1.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+ RetSqlName("SNG") + " SNG ON "
cQuery += "SNG.NG_FILIAL =  '" + xFilial("SNG") + "' AND "
cQuery += "		SNG.NG_GRUPO = SN1.N1_GRUPO AND "
cQuery += "		SNG.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery += "		SN4.N4_FILIAL = '" + xFilial("SN4") + "' AND "
cQuery += "		SN4.N4_OCORR = '05' AND "
cQuery += "		SN4.N4_DATA >= '" + DTOS(dDtIni) + "' AND "
cQuery += "		SN1.N1_GRUPO <> ' ' AND "
cQuery += "		SN4.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
aEval(aStru, { |e|	If(e[2] <> "C" .And. FieldPos(e[1]) > 0, ;
							TcSetField(cAliasQry,e[1],e[2],e[3],e[4]),) } )

While (cAliasQry)->(!Eof())
	// Pesquisa a filial
	If (nIndMes := Ascan(aRet, { |e| e[1] == Left(DTOS((cAliasQry)->N4_DATA),6) } ) ) > 0
		// Pesquisa o grupo dentro da filial
		nIndGrupo := 0 // Ascan(aRet[nIndMes], {|e| ValType(e)=="A" .And. e[1] == (cAliasQry)->N1_GRUPO + "-" + (cAliasQry)->NG_DESCRIC } )
		For nX := 1 To Len(aRet[nIndMes])
			If ValType(aRet[nIndMes][nX])=="A"
				nIndGrupo := Ascan(aRet[nIndMes][nX], {|e| e[1] == (cAliasQry)->N1_GRUPO + "-" + (cAliasQry)->NG_DESCRIC } )
			Endif
		Next
		If nIndGrupo > 0
			aRet[nIndMes][nIndMes+1][nIndGrupo][2] +=  (cAliasQry)->&("N4_VLROC"+cMoeda)
		Else
			Aadd( aRet[nIndMes][2],	 { (cAliasQry)->N1_GRUPO + "-" + (cAliasQry)->NG_DESCRIC, (cAliasQry)->&("N4_VLROC"+cMoeda),CLR_RED, } )
		Endif
	Else
		Aadd( aRet,	{ Left(DTOS((cAliasQry)->N4_DATA),6),; // Combo
 						{ { (cAliasQry)->N1_GRUPO + "-" + (cAliasQry)->NG_DESCRIC, (cAliasQry)->&("N4_VLROC"+cMoeda),CLR_RED, } } } ) // "Valor"
	Endif
	(cAliasQry)->(DbSkip())
End

// Converte os dados no formato do Painel
For nX := 1 To Len(aRet)
	nAscan := Val(Right(aRet[nX][1],2))
	If nAscan > 0	.And. nAscan <= 12
		aRet[nX][1] := aMeses[nAscan] + "/" + Left(aRet[nX][1],4)
	Endif
	aEval(aRet[nX][2], { |e| If(ValType(e[2]) == "N",e[2] := Transform(e[2],PesqPict("SN4","N4_VLROC"+cMoeda)),Nil) } )
Next

(cAliasQry)->(DbCloseArea())

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0
