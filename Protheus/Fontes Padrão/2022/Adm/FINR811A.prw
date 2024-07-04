#INCLUDE 'Protheus.ch'
#INCLUDE 'FINR811.CH'

Static __cTabFWT	:= ""
Static __cTabSE1A	:= ""
Static __cTabSE1B	:= ""

/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FINR811
Relatório de Conciliação de EBTA
@author Rodrigo Pirolo
@since 17/08/15
/*/ 
/*--------------------------------------------------------------------------------------------------------------------*/

Function FINR811A( lProcesso As Logical, cComboVenc As Character ) As Logical

	Local oReport		As Object
	Local aArea			As Array

	Private dBaixa		As Date
	Private lFina811	As Logical
	Private cLayout		As Character

	Default lProcesso  := .F.
	Default cComboVenc := ''

	If !TableInDic("FWP") .OR. !TableInDic("FWQ") .OR. !TableInDic("FWS") .OR. !TableInDic("FWT") 
        MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
        Return()	
	EndIf

	If !lProcesso .And. GetHlpLGPD({"A1_NOME", "E1_NOMCLI"})
		Return .F.
	Endif

	aArea	:= GetArea()

	lFina811 := lProcesso

	oReport := ReportDef()
	oReport:PrintDialog()


	RestArea(aArea)

Return .T.

/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que serao utilizadas.
@return oReport 
@author Jacomo Lisa
@since 17/08/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function ReportDef() As Object

	Local oReport	As Object 
	Local oSection	As Object
	Local oSection1	As Object
	Local oSection2	As Object
	Local cReport	As Character
	Local cTitulo	As Character
	Local cDescri	As Character
	Local cPerg		As Character
	Local n1		As Numeric
	Local aCels		As Array

	cReport := "FINR811"	// Nome do relatorio
	cTitulo := STR0001		//"Carta de Cobrança"
	cDescri := STR0001		//"Carta de Cobrança"
	cPerg	:= "FINR810"	// Nome do grupo de perguntas
	n1		:= 0
	aCels	:=	{}

	__cTabFWT := GetNextAlias()
	__cTabSE1A:= GetNextAlias()
	__cTabSE1B:= GetNextAlias()

	/***************************************\
	|* MV_PAR01 = Layout de:               *|
	|* MV_PAR02 = Layout Até:              *|
	|* MV_PAR03 = Dt Envio de:             *|
	|* MV_PAR04 = Dt Envio até:            *|
	|* MV_PAR05 = Cliente de:              *|
	|* MV_PAR06 = Loja de:                 *|
	|* MV_PAR07 = Cliente até:             *|
	|* MV_PAR08 = Loja até:                *|
	|* MV_PAR09 = Imprime: 1=Analitico     *|
	|*					   2=Sintetico	   *|
	\***************************************/
	Pergunte(cPerg,.F.)

	oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescri)
	oReport:HideHeader()	//Oculta o cabecalho do relatorio
	oReport:SetPortrait()	//Imprime o relatorio no formato retrato
	oReport:HideFooter()	//Oculta o rodape do relatorio
	oReport:SetLeftMargin(08)

	If lFina811
		oReport:lParamPage 		:= .F.
		oReport:lParamReadOnly	:= .T.
	EndIf

	aCels := MontaCel()

	// Secao principal
	oSection := TRSection():New(oReport, STR0002 , {"FWT","SE1"})	//"CABECALHO"
	oSection:SetHeaderSection(.F.)	//Não imprime o cabecalho da secao
	oSection:SetPageBreak(.T.)		//Salta a pagina na quebra da secao

	// Secao 01
	oSection1 := TRSection():New(oSection, STR0003 , {"FWT","SE1"})	//"Titulos Vencidos"
	FOR N1 := 1 TO LEN (aCels)
		TRCell():New(oSection1, aCels[N1][1], aCels[N1][2], aCels[N1][3], aCels[N1][4], aCels[N1][5],/*lPixel*/,/*CodeBlock*/)
	NEXT

	// Secao 02
	oSection2 := TRSection():New(oSection, STR0004 , {"FWT","SE1"})
	FOR N1 := 1 TO LEN (aCels)
		TRCell():New(oSection2, aCels[N1][1], aCels[N1][2], aCels[N1][3], aCels[N1][4], aCels[N1][5],/*lPixel*/,/*CodeBlock*/)
	NEXT

	TRBreak():New(oSection, {|| (__cTabFWT)->FWT_PROCES },/**/,/*lTotalInLine*/.F.,/*cNameBrk*/,.T.,.F.,.T.)

	oSection2:Cell("DIAS"):SetTitle(STR0005)

	oSection1:Cell("TOTAL"):SetHeaderAlign("RIGHT")
	oSection2:Cell("TOTAL"):SetHeaderAlign("RIGHT")

Return oReport

/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} ReportPrint
Imprime o objeto oReport definido na funcao ReportDef
@author Jacomo Lisa
@param oReport - Objeto para impressão definido pela função ReportDef
@return oReport 
@since 17/08/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function ReportPrint( oReport As Object )

	Local oSection		As Object
	Local oSection1 	As Object
	Local oSection2 	As Object
	Local cQuery		As Character
	Local nJuros		As Numeric
	Local nMulta		As Numeric
	Local cConcat		As Character
	Local cMvPar01		As Character
	Local cMvPar02		As Character
	Local dMvPar03		As Date
	Local dMvPar04		As Date
	Local cMvPar05		As Character
	Local cMvPar06		As Character
	Local cMvPar07		As Character
	Local cMvPar08		As Character
	Local nX			As Numeric
	Local nAbat			As Numeric
	Local nPosProc		As Numeric

	Private cProcess	As Character

	oSection	:= oReport:Section(STR0002) //Cabeçalho
	oSection1	:= oReport:Section(STR0002):Section(STR0003)//"Titulos Vencidos"
	oSection2	:= oReport:Section(STR0002):Section(STR0004) //"Titulo à Vencer"
	cQuery		:= ""
	nJuros		:= 0
	nMulta		:= 0
	cConcat		:= If( Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX", "||", "+")
	cMvPar01	:= MV_PAR01
	cMvPar02	:= MV_PAR02
	dMvPar03	:= MV_PAR03
	dMvPar04	:= MV_PAR04
	cMvPar05	:= MV_PAR05
	cMvPar06	:= MV_PAR06
	cMvPar07	:= MV_PAR07
	cMvPar08	:= MV_PAR08
	nX			:= 0
	nAbat		:= 0
	nPosProc	:= 0
	
	cProcess	:= ''

	If lFina811
		cMvPar01 := aReport[1][4]
		cMvPar02 := aReport[Len(aReport)][4]
		dMvPar03 := dDataBase
		dMvPar04 := dDataBase
		cMvPar05 := aReport[1][1]
		cMvPar06 := aReport[1][2]
		cMvPar07 := aReport[Len(aReport)][1]
		cMvPar08 := aReport[Len(aReport)][2]
	EndIf

	SE1->(DbGoTop())
	FK7->(DbGoTop())

	If oReport:lXlsTable
		ApMsgAlert(STR0006) //"Formato de impressão Tabela não suportado neste relatório"
		oReport:CancelPrint()
		Return
	Endif

	cQuery += " AND SE1.E1_FILIAL + '|' + SE1.E1_PREFIXO + '|' + SE1.E1_NUM + '|' + SE1.E1_PARCELA +"
	cQuery += " '|' +  SE1.E1_TIPO + '|' +  SE1.E1_CLIENTE + '|' +  SE1.E1_LOJA = FK7.FK7_CHAVE "
	cQuery := "%"+strtran(cQuery,"+",cConcat)+"%"

	//Inicia query de processos
	oSection:BeginQuery()
	BeginSql Alias __cTabFWT
		SELECT DISTINCT
		FWT.FWT_FILIAL,
		FWT.FWT_LAYOUT,
		FWT.FWT_PROCES,
		FWT.FWT_DTREFE,
		FWT.FWT_STATUS,
		FWT.FWT_FILLYT,
		FWT.FWT_DTENVI,
		SE1.E1_CLIENTE,
		SE1.E1_FILORIG
		FROM
		%table:SE1% SE1, %table:FWT% FWT, %table:FK7% FK7
		WHERE
		FWT.FWT_LAYOUT	BETWEEN %Exp:cMvPar01% and %Exp:cMvPar02% AND
		FWT.FWT_DTENVI	BETWEEN %Exp:dMvPar03% and %Exp:dMvPar04% AND
		SE1.E1_CLIENTE	BETWEEN %Exp:cMvPar05% and %Exp:cMvPar07% AND
		SE1.E1_LOJA   	BETWEEN %Exp:cMvPar06% and %Exp:cMvPar08% AND
		FWT.FWT_CHAVE = FK7.FK7_IDDOC AND
		SE1.%notDel% AND FWT.%notDel% AND FK7.%notDel%
		%Exp:cQuery%
		ORDER BY E1_CLIENTE, FWT.FWT_PROCES
	EndSql
	oSection:EndQuery()

	oSection1:BeginQuery()  ////  Vencidos
	BeginSql Alias __cTabSE1A
		SELECT
		FWT.FWT_FILIAL,
		FWT.FWT_LAYOUT,
		FWT.FWT_PROCES,
		FWT.FWT_DTREFE,
		FWT.FWT_STATUS,
		SE1.E1_VENCREA,
		SE1.R_E_C_N_O_ AS RecNoSE1
		FROM
		%table:SE1% SE1, %table:FWT% FWT, %table:FK7% FK7
		WHERE
		FWT.FWT_LAYOUT	BETWEEN %Exp:cMvPar01% and %Exp:cMvPar02% AND
		FWT.FWT_DTENVI	BETWEEN %Exp:dMvPar03% and %Exp:dMvPar04% AND
		SE1.E1_CLIENTE	BETWEEN %Exp:cMvPar05% and %Exp:cMvPar07% AND
		SE1.E1_LOJA   	BETWEEN %Exp:cMvPar06% and %Exp:cMvPar08% AND
		FWT.FWT_CHAVE = FK7.FK7_IDDOC AND
		SE1.E1_VENCREA < FWT.FWT_DTREFE AND
		SE1.%notDel% AND FWT.%notDel% AND FK7.%notDel%
		%Exp:cQuery%
		ORDER BY SE1.E1_CLIENTE, FWT.FWT_PROCES, FWT.FWT_DTENVI, SE1.E1_VENCREA
	EndSql
	oSection1:EndQuery()

	oSection2:BeginQuery() /// a Vencer
	BeginSql Alias __cTabSE1B
		SELECT
		FWT.FWT_FILIAL,
		FWT.FWT_LAYOUT,
		FWT.FWT_PROCES,
		FWT.FWT_DTREFE,
		FWT.FWT_STATUS,
		SE1.E1_VENCREA,
		SE1.R_E_C_N_O_ AS RecNoSE1
		FROM
		%table:SE1% SE1, %table:FWT% FWT, %table:FK7% FK7
		WHERE
		FWT.FWT_LAYOUT	BETWEEN %Exp:cMvPar01% and %Exp:cMvPar02% AND
		FWT.FWT_DTENVI	BETWEEN %Exp:dMvPar03% and %Exp:dMvPar04% AND
		SE1.E1_CLIENTE	BETWEEN %Exp:cMvPar05% and %Exp:cMvPar07% AND
		SE1.E1_LOJA   	BETWEEN %Exp:cMvPar06% and %Exp:cMvPar08% AND
		FWT.FWT_CHAVE = FK7.FK7_IDDOC AND
		SE1.E1_VENCREA >= FWT.FWT_DTREFE AND
		SE1.%notDel% AND FWT.%notDel% AND FK7.%notDel%
		%Exp:cQuery%
		ORDER BY SE1.E1_CLIENTE, FWT.FWT_PROCES, FWT.FWT_DTENVI, SE1.E1_VENCREA
	EndSql
	oSection2:EndQuery()

	If MV_PAR09 == 1 .Or. lFina811
		oSection1:Cell("FWT_STATUS"):Disable()
		oSection2:Cell("FWT_STATUS"):Disable()
	EndIf

	While (__cTabFWT)->(!eof())

		If lFina811
			//Busca os que serão impressos os processos
			nPosProc := aScan(aReport, { |x| x[3] == (__cTabFWT)->FWT_PROCES } )
		
			If nPosProc = 0
				(__cTabFWT)->(dbskip())
				Loop
			EndIf
		EndIf

		cLayout	:= (__cTabFWT)->FWT_LAYOUT
		dBaixa	:= (__cTabFWT)->FWT_DTREFE
	
		If (__cTabFWT)->FWT_PROCES <> cProcess
			cProcess := (__cTabFWT)->FWT_PROCES
			F811Cabec(oReport)
		ElseIf (__cTabFWT)->FWT_PROCES == cProcess
			(__cTabFWT)->(DbSkip())
			Loop
		EndIf
	
		oReport:SkipLine()
	
		oSection:Init()
	
		lFirstTime := .T.
		While (__cTabSE1A)->(!EoF())
			If	(__cTabSE1A)->FWT_PROCES == cProcess .and. (__cTabSE1A)->FWT_LAYOUT == cLayout
				If lFirstTime
					oReport:SkipLine()
					oReport:PrintText(STR0009)//"Seguem os titulos vencidos:"
					oReport:ThinLine()
					oReport:SkipLine()
					oSection1:Init()
					lFirstTime := .F.
				EndIf
			
				SE1->(DbGoTo((__cTabSE1A)->RecNoSE1))
			
				nAbat := F811AbatRec()
			
				nJuros := fa070Juros(SE1->E1_MOEDA,SE1->E1_SALDO - nAbat,,)
				nMulta := F811RMul(SE1->E1_VALOR,SE1->E1_SALDO - nAbat,SE1->E1_VENCREA,dBaixa,SE1->(Recno()))

				oSection1:Cell("E1_SALDO"):SetBlock( { || SE1->E1_SALDO - nAbat })
				oSection1:Cell("E1_MULTA"):SetBlock( { || nMulta } )
				oSection1:Cell("E1_JUROS"):SetBlock( { || nJuros } )
				oSection1:Cell("TOTAL"	 ):SetBlock( { || (nMulta+nJuros+SE1->(E1_SALDO+E1_MULTA+E1_SDACRES-E1_SDDECRE)) - nAbat} )
				oSection1:Cell("DIAS"	 ):SetBlock( { || FRClcDias(SE1->E1_VENCREA,(__cTabFWT)->FWT_DTREFE) } )

				oSection1:PrintLine(.T.)
			EndIf
			(__cTabSE1A)->(dbskip())
		EndDo
		
		(__cTabSE1A)->(DbGoTop())
		
		oSection1:Finish()
    
		lFirstTime := .T.

		While (__cTabSE1B)->(!eof())
			SE1->(DBGOTO((__cTabSE1B)->RecNoSE1))
			If	(__cTabSE1B)->FWT_PROCES == cProcess .and. (__cTabSE1B)->FWT_LAYOUT == cLayout
				If lFirstTime
					oReport:SkipLine()
					oReport:PrintText(STR0010)//"Seguem os vencimentos proximos:"
					oReport:ThinLine()
					oSection2:Init()
					lFirstTime := .F.
				EndIf

				nAbat := F811AbatRec()
			
				nJuros := fa070Juros(SE1->E1_MOEDA,SE1->E1_SALDO - nAbat,,)
				nMulta := F811RMul(SE1->E1_VALOR,SE1->E1_SALDO - nAbat,SE1->E1_VENCREA,dBaixa )

				oSection2:Cell("E1_SALDO"):SetBlock({|| SE1->E1_SALDO - nAbat })
				oSection2:Cell("E1_MULTA"):SetBlock( { || nMulta } )
				oSection2:Cell("E1_JUROS"):SetBlock( { || nJuros})
				oSection2:Cell("TOTAL"	 ):SetBlock( { || (nMulta+nJuros+SE1->(E1_SALDO+E1_MULTA+E1_SDACRES-E1_SDDECRE)) - nAbat} )
				oSection2:Cell("DIAS"	 ):SetBlock( { || FRClcDias(SE1->E1_VENCREA,(__cTabFWT)->FWT_DTREFE) } )

				oSection2:PrintLine(.T.)
			EndIf
			(__cTabSE1B)->(dbskip())
		EndDo

		(__cTabSE1B)->(DbGoTop())

		oSection2:Finish()
		F811PgFoot(oReport)
		oReport:StartPage(.T.)
	
		oSection:Finish()
		
		(__cTabFWT)->(dbskip())
	EndDo

Return

/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} MontaCel
Monta um Array de Acordo com o tipo de Relatório
@author Jacomo Lisa
@since 17/08/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function MontaCel() As Array
	Local aCels	As Array

	aCels := {}

	aADD(aCels, {"E1_PREFIXO","SE1" ,SX3->(RetTitle("E1_PREFIXO")),PesqPict("SE1","E1_PREFIXO"),TamSX3("E1_PREFIXO")[1]		})
	aADD(aCels, {"E1_NUM"    ,"SE1" ,SX3->(RetTitle("E1_NUM"    )),PesqPict("SE1","E1_NUM"    ),TamSX3("E1_NUM"    )[1] + 8	})
	aADD(aCels, {"E1_PARCELA","SE1" ,SX3->(RetTitle("E1_PARCELA")),PesqPict("SE1","E1_PARCELA"),TamSX3("E1_PARCELA")[1]		})
	aADD(aCels, {"E1_EMISSAO","SE1" ,SX3->(RetTitle("E1_EMISSAO")),PesqPict("SE1","E1_EMISSAO"),TamSX3("E1_EMISSAO")[1]	+ 8	})
	aADD(aCels, {"E1_VENCREA","SE1" ,SX3->(RetTitle("E1_VENCREA")),PesqPict("SE1","E1_VENCREA"),TamSX3("E1_VENCREA")[1]	+ 8	})
	aADD(aCels, {"DIAS"      ,"SE1" ,STR0007					  ,"@999"                      ,3                      		})
	aADD(aCels, {"E1_VALOR"  ,"SE1" ,SX3->(RetTitle("E1_VALOR"  )),PesqPict("SE1","E1_VALOR"  ),TamSX3("E1_VALOR"  )[1]		})
	aADD(aCels, {"E1_SALDO"  ,"SE1" ,SX3->(RetTitle("E1_SALDO"  )),PesqPict("SE1","E1_SALDO"  ),TamSX3("E1_SALDO"  )[1]		})
	aADD(aCels, {"E1_MULTA"  ,"SE1" ,SX3->(RetTitle("E1_MULTA"  )),PesqPict("SE1","E1_MULTA"  ),TamSX3("E1_MULTA"  )[1]		})
	aADD(aCels, {"E1_JUROS"  ,"SE1" ,SX3->(RetTitle("E1_JUROS"  )),PesqPict("SE1","E1_JUROS"  ),TamSX3("E1_JUROS"  )[1]		})
	aADD(aCels, {"E1_SDACRES","SE1" ,SX3->(RetTitle("E1_SDACRES")),PesqPict("SE1","E1_SDACRES"),TamSX3("E1_SDACRES")[1]		})
	aADD(aCels, {"E1_SDDECRE","SE1" ,SX3->(RetTitle("E1_SDDECRE")),PesqPict("SE1","E1_SDDECRE"),TamSX3("E1_SDDECRE")[1]		})
	aADD(aCels, {"TOTAL"	 ,"SE1" ,STR0008					  ,PesqPict("SE1","E1_SALDO"  ),TamSX3("E1_SALDO"  )[1]		})
	aADD(aCels, {"FWT_STATUS","FWT" ,SX3->(RetTitle("FWT_STATUS")),PesqPict("FWT","FWT_STATUS"),							})
	
Return aCels

/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F811Cabec
Construção do cabeçalho do relatório
@author Jacomo Lisa
@since 17/08/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function F811Cabec( oReport As Object ) As Logical
	Local n1			As Numeric
	Local cSpace		As Character
	Local cCliName		As Character
	Local cEndere1		As Character
	Local cEndere2		As Character
	Local cFilLayout	As Character
	Local cCliente		As Character
	Local cFilOrig		As Character
	Local nMvPar09		As Numeric
	Local cStartPath	As Character
	Local cLogo			As Character

	n1			:= 0
	cSpace		:= ""
	cCliName	:= ""
	cEndere1	:= ""
	cEndere2	:= ""
	cFilLayout	:= (__cTabFWT)->FWT_FILLYT
	cCliente	:= (__cTabFWT)->E1_CLIENTE
	cFilOrig	:= (__cTabFWT)->E1_FILORIG
	nMvPar09	:= MV_PAR09
	cStartPath	:= GetSrvProfString("Startpath","")
	cLogo		:= ''

	cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + FWGETCODFILIAL + ".BMP" 	// Empresa+Filial

	If !File( cLogo )
		cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ".BMP" // Empresa
	EndIf

	If lFina811
		nMvPar09 := 1
	EndIf

	DbSelectArea("SA1")
	If MsSeek(xFilial("SA1",cFilOrig) + cCliente)
	
		cCliName := A1_NOME

		If !Empty(A1_ENDCOB) .And. !Empty(A1_MUNC) .And. !Empty(A1_CEPC) .And. !Empty(A1_ESTC) .And. !Empty(A1_BAIRROC)
			cEndere1 := Capital(AllTrim(A1_ENDCOB))
			cEndere2 := Capital(AllTrim(A1_BAIRROC)) + " - " + Capital(AllTrim(A1_MUNC)) + " - " + A1_ESTC + " - " + Transform(A1_CEPC,"@R 99999-999")
		Else
			cEndere1 := Capital(AllTrim(A1_END))
			cEndere2 := Capital(AllTrim(A1_BAIRRO)) + " - " + Capital(AllTrim(A1_MUN)) + " - " + A1_EST + " - " + Transform(A1_CEP,"@R 99999-999")
		EndIf
	EndIf

	DbSelectArea("FWP")

	If MsSeek( xFilial("FWP",cFilLayout) + cLayout) .AND. FWP->FWP_STATUS == '1'
	
		oReport:SayBitmap(080,150,cLogo,679,137)
	
		For n1 := 1 To 10
			oReport:SkipLine()
		Next n1

		For n1 := 1 To FWP->FWP_POSVER
			oReport:SkipLine()
		Next
		cSpace := Space(FWP->FWP_POSHOR)
	
		oReport:PrintText(Capital(AllTrim(SM0->M0_CIDCOB)) + ", " + AllTrim(Str(Day((__cTabFWT)->FWT_DTENVI))) + STR0023 +;
			MesExtenso(Month((__cTabFWT)->FWT_DTENVI)) + STR0023 + AllTrim(Str(Year((__cTabFWT)->FWT_DTENVI))) + "." )
	
		For n1 := 1 To 2
			oReport:SkipLine()
		Next

		oReport:PrintText(cSpace + cCliName)
	
		oReport:PrintText(cSpace + cEndere1)
		oReport:PrintText(cSpace + cEndere2)
	
		oReport:SkipLine()
		oReport:SkipLine()
	
		oReport:PrintText(ALLTRIM(FWP->FWP_TXTSAU) + Space(1) + cCliName)
	
		oReport:SkipLine()
		oReport:SkipLine()
	
		cConteudo := FWP->FWP_TXTCRT
		aQuebra := StrToKarr(cConteudo,Chr(10))

		F811LinPg(oReport,aQuebra)

		oReport:SkipLine()
	
	EndIf

Return .T.

/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FRClcDias
Cálculo de dias
@author Jacomo Lisa
@since 17/08/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FRClcDias( dDataRef As Date, dDataVenc As Date ) As Numeric

	Local nRet	As Numeric
	
	nRet := 0

	If dDataRef > dDataVenc
		nRet := dDataRef - dDataVenc
	Else
		nRet := dDataVenc - dDataRef
	Endif

	nRet := Abs( nRet )

Return nRet

/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F811PgFoot
Construção do rodapé
@author Jacomo Lisa
@since 17/08/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function F811PgFoot( oReport As Object )

	Local cConteudo	As Character
	Local nMvPar09	As Numeric
	Local aQuebra	As Array

	cConteudo	:= ''
	nMvPar09	:= MV_PAR09
	aQuebra		:= {}

	If lFina811
		nMvPar09 := 1
	EndIf

	DbSelectArea("FWP")
	If MsSeek( xFilial("FWP",(__cTabFWT)->FWT_FILLYT) + cLayout) .And. !Empty(FWP->FWP_TXTCON)
		//Pulo três linhas após a última relação de títulos
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:SkipLine()

		cConteudo := FWP->FWP_TXTCON
		aQuebra := StrToKarr(cConteudo,Chr(10))

		F811LinPg(oReport, aQuebra)

	Endif

Return


/*--------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F811LinPg
Define o tamanho da linha do corpo da Carta de Cobrança
@author Adriano Sato
@since 29/01/2021
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function F811LinPg(oReport As Object, aQuebra As Array)
Local nTamLin 	As Numeric
Local nX 		As Numeric
Local nY 		As Numeric
Local nLinha 	As Numeric

nTamLin := 160
nX		:= 0
nY		:= 0
nLinha  := 0

Do Case 
	Case oReport:NFONTBODY > 6 .and. oReport:NFONTBODY <= 9
		nTamLin := 130
	Case oReport:NFONTBODY > 9 .and. oReport:NFONTBODY <= 12
		nTamLin := 100
	Case oReport:NFONTBODY > 12 .and. oReport:NFONTBODY <= 15
		nTamLin := 80
	Otherwise
		nTamLin := 60
EndCase

If !Empty(aQuebra)
	For nX := 1 To Len(aQuebra)
		nLinha := MLCount(aQuebra[nX],nTamLin)
		For nY := 1 To nLinha
			oReport:PrintText(MemoLine(aQuebra[nx],nTamLin,nY))
		Next nY
		oReport:SkipLine()
	Next nX
Else
	nLinha := MLCount(cConteudo,nTamLin)
	For nY := 1 To nLinha
		oReport:PrintText(Memoline(cConteudo,nTamLin,nY))
	Next nY
EndIf

Return
