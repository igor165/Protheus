#INCLUDE 'XMLXFUN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PCPA700.CH'
#INCLUDE 'FILEIO.CH'

/*	Autor:  Yuri Lima
	E-mail: yuri.lima@totvs.com.br
	Data: 	 01/09/2014  */

#DEFINE ENDLINE CHR(13)+CHR(10)

Static lToggle
Static aProdList
Static cProdAlias
Static fSOPLogFile// Arquivo de log
Static aMonthParams
Static aTotMonthDays

Static oMtTotal, oProg, oProdList, oCheckBox //Barra e Say de progresso, TWBrose, CheckBox mestre.


Main Function PCPA700(cAction, cImportKey)

	Default cAction		:= 'include'
	Default cImportKey	:= ''

	Do Case
		Case cAction == 'exclude'
			excludeSOP(cImportKey)
		Otherwise
			includeSOP()
	End Do

Return Nil

Static Function excludeSOP(cImportKey)

	Local nTot := 0

	If cImportKey = 'IMPORTSOP'
		DbSelectArea("SC4")
		
		SET FILTER TO C4_OBS = cImportKey
		dbGoTop()
		
		While !EOF()
			nTot++
			dbSkip()
		End

		If MsgNoYes(STR0028+ENDLINE+STR0029+": "+cImportKey+ENDLINE+STR0030+": "+toStr(nTot))
			showDeleteMeter(cImportKey, nTot)
		End

		dbClearFilter()
	Else
		MsgInfo(STR0031)
	EndIf

Return Nil

Static Function delSC4Reg(nTot)

	Local nProg := 0

	dbGoTop()

	While !EOF()
		RecLock("SC4", .F.)
		dbDelete()
		dbSkip()
		MsUnLock()

		oProg:cCaption := STR0017+" "+toStr(++nProg)+" "+STR0018+" "+toStr(nTot)
		oMtTotal:Set(nProg)
	End

Return .T.

Static Function includeSOP()

	Local aSOP		   := {}
	Local cRawPath	   := ""
	Default lAutoMacao := .F.

	lToggle			:= .T. //Toggle que controla o state do CheckBox mestre
	aProdList		:= {}  // Array usada pela TWBrowse.
	cProdAlias		:= ""  // Alias para query de info. do prod.
	aMonthParams	:= {28, 1}//Grava os parametros da função distPrdMonth.
	aTotMonthDays	:= { 31, { |nYear| getFevLDay(nYear) }, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}//Total de dias por mes.

	IF !lAutoMacao
		cRawPath	:= getRawFilePath()
	ENDIF
	fSOPLogFile	:= createLog(cRawPath)
	writeOnLog(STR0019/*"Assitente de importação S&OP iniciado."*/)

	If cRawPath != ""
		writeOnLog(STR0020/*"Arquivo escolhido ->"*/+" "+cRawPath)
		aSOP := showProcFileMeter(cRawPath)

		If aSOP != {}
			buildMainWnd(aSOP)
		Else
			MsgInfo("Não foi possível utilizar o Arquivo "+SUBSTR(cRawPath, 0, (RAT('\', cRawPath))))
		EndIf
	Else
		writeOnLog(STR0032/*"Arquivo não localizado."*/)
	EndIf

	FClose(fSOPLogFile)

Return Nil

//Construtor da tela.
Static Function buildMainWnd(aXML)

	Local lCanImport := .T.
	Default lAutoMacao := .F.

	IF !lAutoMacao
		DEFINE DIALOG oDlgMain TITLE STR0001/*"Importação S&OP"*/ FROM 0, 0 TO 22, 75 SIZE 750, 450 PIXEL	

		buildPerRadio(oDlgMain)// Grupo do radio
		lCanImport := createListProd(oDlgMain, aXML)//Monta a lista.
		buildStepBts(oDlgMain)// Cria os botões.

		ACTIVATE MSDIALOG oDlgMain CENTER ON INIT Eval({|| If(lCanImport,,oDlgMain:End())})
	ENDIF	
	writeOnLog(STR0033/*"Processo finalizado normalmente."*/)

Return Nil

Static Function buildPerRadio(oPainel)

	Local nRadio := 4
	Local oGroupRadio
	Default lAutoMacao := .F.

	IF !lAutoMacao
		oGroupRadio := TGroup():New(25, 15, 85, 75, STR0002/*"Periocidade"*/, oPainel,,, .T.)

		@ 38, 25 RADIO oPerRadio VAR nRadio ITEMS STR0003/*'Diário'*/, STR0004/*'Semanal'*/, STR0005/*'Quinzenal'*/, STR0006/*'Mensal'*/ OF oGroupRadio;
		ON CHANGE { || organizeList(nRadio) } SIZE 40, 30 PIXEL
	ENDIF
Return Nil

Static Function buildStepBts(oPainel)

	@ 75, 285 BUTTON oBtnCancelar PROMPT STR0007/*"Cancelar"*/  SIZE 35, 12 ACTION (cancelImport(oPainel)) OF oPainel PIXEL
	@ 75, 325 BUTTON oBtnAvanca   PROMPT STR0008/*"Avançar"*/   SIZE 35, 12 ACTION (If(showImportMeter() == .T., finishImport(oPainel), Nil))  OF oPainel PIXEL

Return Nil

Static Function createListProd(oPainel, aXML)

	Local oCheckT	:= LoadBitmap( GetResources(), "LBOK" )
	Local oCheckF	:= LoadBitmap( GetResources(), "LBNO" )
	Local oCheckHolder, oListPainel
	Local lCanImport   := .T.
	Default lAutoMacao := .F.

	aProdList := processArrXML(aXML)//Processa o XML para criar uma estrutura utilizavel pela TWBorse()
	aXML := Nil

	If Len(aProdList) == 0
		lCanImport := .F.
		msgInfo(STR0009/*"Nenhum item valido para exportação."*/)
		writeOnLog(STR0009)
		aProdList := {{.F., "", 0, DATE(), 0 }}
	EndIf

	IF !lAutoMacao
		oListPainel := TPanel():New( 95, 0, , oPainel, , , , , , 360, 135, .F., .F. )

		oProdList := TWBrowse():New( 0, 15, 345, 130,,,,oListPainel,,,,,,,,,,,,,,.T.)
		oProdList:SetArray(aProdList)

		oProdList:bLine	:= 	{|| xCheckType := aProdList[oProdList:nAT][1],;
								{;
									If(ValType(xCheckType) == "L" , If(xCheckType, oCheckT, oCheckF), ""),;
									aProdList[oProdList:nAt][2],;
									aProdList[oProdList:nAt][3],;
									aProdList[oProdList:nAt][4],;
									aProdList[oProdList:nAt][5];
								};
							}
		oProdList:lVScroll		:= .T.
		oProdList:lHScroll		:= .F.
		oProdList:aHeaders		:= { "" , STR0010/*"Produto"*/, STR0011/*"Quantidade"*/, STR0012/*"Data"*/, STR0013/*"Período"*/}
		oProdList:aColSizes		:= { 030 , 030, 100}
		oProdList:bLDblClick	:= {||  xCheckType := aProdList[oProdList:nAT][1], If(ValType(xCheckType) == "L" , aProdList[oProdList:nAt][1] := !aProdList[oProdList:nAt][1] , "") , controlCheckAllState(aProdList)}

		oCheckHolder := TPanel():New( 1, 16, ,oListPainel, , , , , , 8, 9, .F., .F. )
		@ 0, 0 CHECKBOX oCheckBox VAR lToggle PROMPT "" WHEN PIXEL OF oCheckHolder SIZE 015,015 MESSAGE ""
		oCheckBox:bChange := {|| toggleListCheck(oProdList, lToggle)}
	ENDIF
	lToggle := .T.

Return lCanImport

Static Function toggleListCheck(oBrw, lFixedBool)

	Local bSeek := {|x| If(ValType(x[1]) == "L",  x[1] == .F., .F. ) }
	Local lSet  := .F.

	Default lFixedBool := Nil
	Default lAutoMacao := .F.

	If lFixedBool != Nil
		lSet := lFixedBool
	ElseIf aScan(@oBrw:aArray, bSeek) > 0
		lSet := .T.
	EndIf

	IF !lAutoMacao
		aEval(@oBrw:aArray, {|x| If(ValType(x[1]) == "L",  x[1] := lSet, x[1] := "" )})
		oBrw:Refresh()
	ENDIF
Return Nil

Static Function controlCheckAllState(aArray)

	Local bSeek := {|x| If(ValType(x[1]) == "L",  x[1] == .F., .F. ) }
	Default lAutoMacao := .F.

	@lToggle := If(aScan(aArray, bSeek) > 0, .F., .T.)
	IF !lAutoMacao
		oCheckBox:Refresh()
	ENDIF
Return Nil

Static Function getRawFilePath()
Return cGetFile( "Electronic Data Interchange(.edi)|*.edi|Extensible Markup Language(.xml)|*.xml", STR0014/*"Selecione o arquivo para importação"*/, 1, "C:\", .T.,  , .T.)

/* Processa o arquivo xml e gera um array. */
Static Function rawXMLToArray(cRawPath, nBuffer)

	Local aXML			:= {}
	Local aXMLChunck	:= {}

	Local cBuffer		:= ""
	Local cFileSize		:= ""
	Local cXMLChunk		:= ""
	Local cXMLHeader	:= ""

	Local nI			:= 0
	Local nPos			:= 0
	Local nStart		:= 0
	Local nHandle		:= 0
	Local nFileSize		:= 0
	Local nChunckLen	:= 0

	Local cFind 		:= "</PLANODEMANDACOL>"
	Local cGroupOpen	:= "<PLANODEMANDA>"
	Local cGroupClose	:= "</PLANODEMANDA>"
	Local cProgTitle	:= " Processando arquivo: "+SUBSTR(cRawPath, RAT('\', cRawPath)+1)+CHR(10)

	Local nFindLen		:= Len(cFind)-1

	Default nBuffer	:= 1000000// 1mb
	Default lAutoMacao := .F.

	IF !lAutoMacao
		oProg:cCaption := cProgTitle	

		nHandle		:= FOPEN(cRawPath, FO_DENYWRITE)
		nFileSize	:= FSEEK(nHandle, 0, FS_END)
		
		cFileSize	:= lTrim(Str(nFileSize))

		FSEEK(nHandle, 0, FS_SET)// Posiciona no inicio do arquivo.
		FREAD(nHandle, @cBuffer, nBuffer)
	

		cXMLHeader := SubStr(cBuffer, At('<?', cBuffer), At('?>', cBuffer)+Len('?>')-1)
		nStart := At('<PLANODEMANDA>', cBuffer)+Len('<PLANODEMANDA>')-1

		FSEEK(nHandle, nStart, FS_SET)	

		While FREAD(nHandle, @cBuffer, nBuffer) > 0
			If (nPos := rAt(cFind, cBuffer)) > 0
				nPos += nFindLen

				cXMLChunk := cXMLHeader + cGroupOpen + SubStr(cBuffer, 0, nPos) + cGroupClose
				aXMLChunck := processXMLChunk(cXMLChunk)

				nChunckLen := Len(aXMLChunck)
				For nI := 1 To nChunckLen
					aAdd(aXML, aXMLChunck[nI])
				Next nI
					
				nStart += nPos
				FSEEK(nHandle, nStart, FS_SET)
			Else 
				Exit
			EndIf
			
			oMtTotal:Set(Int(((nStart/nFileSize)*100)/10))
			
			oProg:cCaption := cProgTitle +" "+ Ltrim(Str(nStart)) +" de "+ cFileSize +" bytes analisados."//TODO "STR00??" 
		EndDo
	EndIf
	FClose(nHandle)
	
Return aXML

/* Processa parte do XML utilizando o XMLParser. O limite e 1mb */
Static Function processXMLChunk(cXML)

	Local cParserError := cParserWarn := ""
	Local aXMLChunck := {}
	Local oXML := Nil
	Default lAutoMacao := .F.

	oXML := XmlParser(cXML, "_" , @cParserError, @cParserWarn)
	IF !lAutoMacao
		aXMLChunck := extractXML(oXML)
	ENDIF
	DelClassInt(oXML)// Limpa memória consumida pelo oXML

Return aXMLChunck
/* Com base nos dados do XML, as demais informações sao geradas.  */
Static Function processArrXML(aXML)

	Local nIt		:=	1//Posição inicial
	Local xCheckBox :=	.T.
	Local aXMLList	:=	{}
	Local dPrevDate	:=	DATE()
	Local cPrevCod	:=	cCurrCod :=	""
	Local nXMLLen	:=	nCurrPer :=	nPrevPer :=	nQtd :=	0	
	Local dToday

	treatArrXML(aXML)

	SET DATE FRENCH// A função date() irá gerar datas no formato francês. DD/MM/YYYY
	dToday		:=	DATE() + 1

	nXMLLen		:=	Len(aXML)
	cPrevCod	:= 	aXML[nIt][1]
	nPrevPer	:= 	aXML[nIt][2]

	For nIt := nIt To nXMLLen

		cCurrCod := aXML[nIt][1]
		nCurrPer := aXML[nIt][2]

		If cCurrCod != cPrevCod .or. nPrevPer != nCurrPer .or. nIt == nXMLLen

			If(nIt == nXMLLen .and. cCurrCod == cPrevCod .and. nPrevPer == nCurrPer, nQtd += aXML[nIt][3], nQtd)// Precisa incrementar quando for a última iteração.

			dPrevDate := calcProdDate(dToday, nPrevPer)
			mngXMLLine(@aXMLList, xCheckBox, cPrevCod, nQtd, dPrevDate, nPrevPer)

			nQtd := aXML[nIt][3]
			If(nIt == nXMLLen .and. (cCurrCod != cPrevCod .or. nPrevPer != nCurrPer))// Se for a ultima, porém tiver mudado o produto/periodo também insere a corrente.
				dPrevDate := calcProdDate(dToday, nCurrPer)
				mngXMLLine(@aXMLList, xCheckBox, cCurrCod, nQtd, dPrevDate, nCurrPer)
			EndIf

		Else
			nQtd += aXML[nIt][3]
		EndIf

		cPrevCod := cCurrCod
		nPrevPer := nCurrPer

	Next nIt

	SET DATE AMERICAN//Volta para o formato default do sistema.

Return aXMLList

/* Extrai apenas as informacoes do xml que serao utilizadas pelo programa e transfere para uma array. 
	[1] -> Codigo do produto.
	[2] -> Periodo. 
	[3] -> Quantidade. */
Static Function extractXML(oXML)

	Local nIt 			:= 0
	Local aExtracted	:= {}
	Default lAutoMacao  := .F.

	IF !lAutoMacao
		If ValType(oXML:_PLANODEMANDA:_PLANODEMANDACOL) == "A"
			For nIt := 1 To Len(oXML:_PLANODEMANDA:_PLANODEMANDACOL)
				AADD(aExtracted,;
					{;
						getCodXmlNode(oXML:_PLANODEMANDA:_PLANODEMANDACOL[nIt]:_CODITEM:TEXT),;
						Val(oXML:_PLANODEMANDA:_PLANODEMANDACOL[nIt]:_PERIODO:TEXT),;
						Val(oXML:_PLANODEMANDA:_PLANODEMANDACOL[nIt]:_PREVCONFIRMADA:TEXT);
					})
			Next
		Else
			AADD(aExtracted,;
				{;
					getCodXmlNode(oXML:_PLANODEMANDA:_PLANODEMANDACOL:_CODITEM:TEXT),;
					Val(oXML:_PLANODEMANDA:_PLANODEMANDACOL:_PERIODO:TEXT),;
					Val(oXML:_PLANODEMANDA:_PLANODEMANDACOL:_PREVCONFIRMADA:TEXT);
				})
		EndIf
	ENDIF
Return aExtracted

// Filtra o codigo da node no xml, pois pode vir com / indicando opcional.
Static Function getCodXmlNode(cCod)

	Local nDelimiterPos := AT("/", cCod)
	If( nDelimiterPos > 0 , cCod := Substr(cCod,  1 , nDelimiterPos - 1), Nil )

Return cCod

// Realiza os tratamentos necessarios para a funcao processArrXML trabalhar com o conteudo extraido.
Static Function treatArrXML(aXML)

	Local cCod		:= aXML[1][1]
	Local nMax		:= Len(aXML)
	Local nStart	:= 1 
	Local nIt		:= 1

	//Algoritmo para ordenar os itens por produto/periodo.
	For nIt := 1 To nMax
		If cCod != aXML[nIt][1] .or. nIt == nMax
			aSort(aXML, nStart, nIt-nStart, { |x, y| x[2] < y[2] })
			nStart := nIt + 1
		EndIf
		cCod := aXML[nIt][1]
	Next nIt

Return Nil

Static Function mngXMLLine( aTgt, xCheckBox, cProdCod, nQtd, dPrevDate, nPer)

	Local cProdAlias	:= getProdInfo(cProdCod)

	If (cProdAlias)->(EOF())
		writeOnLog(STR0023/*"Node com o codigo de produto "*/+" "+cProdCod+" "+STR0024/*"não localizado."*/)
	ElseIf (cProdAlias)->(HASOPC) == 1
		writeOnLog(STR0023/*"Node com o codigo de produto "*/+" "+cProdCod+" "+STR0025/*"não incluido por possuir opcionais."*/)
	ElseIf nQtd > 0
		AADD(aTgt, buildLine(xCheckBox, cProdCod, nQtd, dPrevDate, nPer, (cProdAlias)->(LOCPAD)))
	EndIf

Return Nil

//SQL Que deve buscar as informacoes pendentes na estrutura do produto. SB1
Static Function getProdInfo(cProdCod)

	If cProdAlias != ""
		(cProdAlias)->( DbCloseArea() )
	Else
		cProdAlias := getNextAlias()
	EndIf

	If	Upper(TcGetDb()) $ 'ORACLE'
		
		BeginSql Alias cProdAlias 
			SELECT SB1.B1_LOCPAD LOCPAD,
				CASE WHEN HASOPC.COD IS NULL THEN 0 ELSE 1 END AS HASOPC
			FROM %table:SB1% SB1 
			LEFT JOIN (
				SELECT  G1_COD COD
					FROM %table:SG1%
					WHERE G1_COD = %exp:cProdCod% AND (G1_GROPC != %exp:""% OR G1_OPC != %exp:""%)
					AND G1_FILIAL = %xFilial:SG1%  AND D_E_L_E_T_ = %exp:" "%
				)  HASOPC ON HASOPC.COD = SB1.B1_COD
			WHERE SB1.B1_COD = %exp:cProdCod%
					AND B1_FILIAL = %xFilial:SB1% AND D_E_L_E_T_ = %exp:" "%
					AND ROWNUM <= %exp:1%
		EndSql
		
	Else
	
		BeginSql Alias cProdAlias 
			SELECT SB1.B1_LOCPAD LOCPAD,
				CASE WHEN HASOPC.COD IS NULL THEN 0 ELSE 1 END AS HASOPC
			FROM %table:SB1% SB1 
			LEFT JOIN (
				SELECT TOP 1 G1_COD COD
					FROM %table:SG1%
					WHERE G1_COD = %exp:cProdCod% AND (G1_GROPC != %exp:""% OR G1_OPC != %exp:""%)
					AND G1_FILIAL = %xFilial:SG1%  AND D_E_L_E_T_ = %exp:" "%
				) AS HASOPC ON HASOPC.COD = SB1.B1_COD
			WHERE SB1.B1_COD = %exp:cProdCod%
					AND B1_FILIAL = %xFilial:SB1% AND D_E_L_E_T_ = %exp:" "%
		EndSql
	
	endif

Return cProdAlias

/*	Estrutura da linha =	[1] - Checkbox, se vazio nao possui marcacao.
							[2] - Codigo do produto.
							[3] - Quantidade.
							[4] - Data.
							[5] - Periodo.
							[6] - Armazem (SB1) */
Static Function buildLine(lCheck, cProdCod, nQtd, dDate, nPer, cLocPad)

	Local aLine := {}

	//Visiveis na TWBrowse()
	AADD(aLine, lCheck)
	AADD(aLine, cProdCod)
	AADD(aLine, nQtd)
	AADD(aLine, "  "+DTOC(dDate))
	AADD(aLine, nPer)

	//Informações extras necessarias para cadastro na SB4.
	AADD(aLine, cLocPad)

Return aLine

/*
	Retorna quantos dias feveiro ira ter no ano do parametro xDate.
	Aceita uma data ou o ano(inteiro)
*/
Static Function getFevLDay(xDate)

	Local nVal := 28

	If ValType(xDate) == 'D'
		xDate := Year(xDate)
	End

	If xDate % 400 == 0 .AND. xDate % 4 == 0 .AND. xDate % 100 != 0
		nVal++
	EndIf

Return nVal

// Calcula a data do produto de acordo com a data do Periodo(Node periodo no XML).
Static Function calcProdDate(dPrevDate, nPrevPer)

	Local nRemainingDays	:= 0
	Local nIt				:= 0

	If nPrevPer > 0

		nRemainingDays	:= getRemainingDays(dPrevDate)
		dPrevDate		:= dPrevDate + (nRemainingDays + 1)// Posiciona a data no prox mes.

		For nIt := 2 To nPrevPer
			If ValType(aTotMonthDays[Month(dPrevDate)]) == 'B'
				dPrevDate += Eval(aTotMonthDays[Month(dPrevDate)], Year(dPrevDate))
			Else
				dPrevDate += aTotMonthDays[Month(dPrevDate)]
			EndIf
		Next nIt

	EndIf

Return dPrevDate

// Retornar quantos dias faltam para o ultimo dia do mês.
Static Function getRemainingDays(dDate)

	Local nDays := aTotMonthDays[Month(dDate)]

	If ValType(nDays) == 'B'
		nDays := Eval(nDays, Year(dDate) )
	Else
		nDays -= Day(dDate)
	EndIf

Return nDays

// Gerencia a chamada do change do Radio.
Static Function organizeList(nType)

	Do Case
		Case nType == 1 // Diario.
			distPrdMonth(1, 30)
		Case nType == 2 // Semanal.
			distPrdMonth(7, 4)
		Case nType == 3 // Quinzenal.
			distPrdMonth(14, 2)
		Case nType == 4 // Mensal.
			distPrdMonth()
	End

Return Nil

/* Algoritimo para distribuir a producao dentro do mes.
	nElapsingDays = Quantidade maxima de dias entre cada data.
	nMaxTimes 	= Quantidade maxima de datas. */
Static Function distPrdMonth(nElapsingDays, nMaxTimes)

	Local aTarget := {}
	Local nRegs, nWeek, nIt, nQtd, nQtdDefict, nElapsedDays
	Local dWeek

	Default nElapsingDays	:= 28
	Default nMaxTimes		:= 1

	If aMonthParams[1] == nElapsingDays .and. aMonthParams[2] == nMaxTimes
		Return Nil
	Else
		restoreToOri()
		aMonthParams := {nElapsingDays, nMaxTimes}
	EndIf

	SET DATE FRENCH

	For nIt := 1 To Len(aProdList)

		nQtd := aProdList[nIt][3]
		dWeek = toDate(aProdList[nIt][4])

		nDays := getRemainingDays(dWeek)
		nElapsedDays := aMonthParams[1]
		
		While nDays/nElapsingDays < 1
			nElapsingDays--
			If nElapsingDays == 0
				Exit
			EndIf
		EndDo

		If nQtd/nMaxTimes >= 1
			nQtdDefict := Int(nQtd/nMaxTimes)
			For nWeek := 1 to nMaxTimes

				AADD(aTarget, buildLine(aProdList[nIt][1], aProdList[nIt][2], nQtdDefict, dWeek, aProdList[nIt][5], aProdList[nIt][6]))				
				nQtd -= nQtdDefict
				
				If Month(dWeek) != Month(dWeek+nElapsingDays) .OR. nElapsedDays == 0
					Exit
				Else
					dWeek := dWeek+nElapsingDays
				EndIf

			Next

			If(nWeek == nMaxTimes+1, nWeek--, nWeek)

			nRegs :=  nWeek
			While nQtd > 0
				While nRegs >= 0
					If nRegs > 0
						nRegs--
					EndIf
					aTarget[Len(aTarget) - (nRegs)][3]++
					nQtd--
					If nQtd == 0
						Exit
					EndIf
				EndDo
				nRegs := nWeek
			EndDo
		Else
			nElapsedDays := nDays + 1
			While nDays >= 0
				AADD(aTarget, buildLine(aProdList[nIt][1], aProdList[nIt][2], 1, dWeek, aProdList[nIt][5], aProdList[nIt][6]))
				dWeek += nElapsingDays
				nQtd--
				nDays--
				If nQtd == 0 
					Exit
				EndIf
			EndDo

			nDays := nElapsedDays
			While nQtd > 0

				If nDays > 0
					nDays--
				EndIf

				aTarget[Len(aTarget) - (nDays)][3]++
				nQtd--
			EndDo
		EndIf
	Next nIt

	SET DATE AMERICAN

	setListContent(aTarget)

Return Nil

//Algoritmo para restaurar a organizacao original do array.
Static Function restoreToOri()

	Local nQtd			:=	0
	Local nIt			:=	1
	Local aDefault		:=	{}
	Local lCheckState	:=	.T.
	Local cPrevCod		:=	aProdList[nIt][2]
	Local nPrevPer		:=	aProdList[nIt][5]
	Local nListLen		:=	Len(aProdList)
	Local dFDate
	Default lAutoMacao  := .F.

	SET DATE FRENCH

	dFDate := toDate(aProdList[1][4])

	For nIt := 1 To nListLen

		If lCheckState == .T. .and. aProdList[nIt][1] == .F.
			lCheckState := .F.
		EndIf

		If cPrevCod != aProdList[nIt][2] .or. nPrevPer != aProdList[nIt][5] .or. nIt == nListLen

			If(nIt == nListLen .and. cPrevCod == aProdList[nIt][2] .and. nPrevPer == aProdList[nIt][5], nQtd += aProdList[nIt][3], nQtd)

			If nIt > 1
				AADD(aDefault, buildLine(lCheckState, cPrevCod, nQtd, dFDate, nPrevPer, aProdList[nIt-1][6]))
			Else
				IF !lAutoMacao
					AADD(aDefault, buildLine(lCheckState, cPrevCod, nQtd, dFDate, nPrevPer, aProdList[nIt][6]))
				ENDIF
			EndIf

			nQtd		:= aProdList[nIt][3]
			dFDate		:= toDate(aProdList[nIt][4])
			lCheckState	:= .T.

			If(nIt == nListLen .and. (cPrevCod != aProdList[nIt][2] .or. nPrevPer != aProdList[nIt][5]))
				AADD(aDefault, buildLine(aProdList[nIt][1], aProdList[nIt][2], nQtd, dFDate, aProdList[nIt][5], aProdList[nIt][6] ))
			EndIf

		Else
			nQtd += aProdList[nIt][3]
		EndIf

		cPrevCod := aProdList[nIt][2]
		nPrevPer := aProdList[nIt][5]

	Next nIt

	aProdList := aDefault

	SET DATE AMERICAN

Return Nil

//Altera a lista visivel no TWBrose.
Static Function setListContent(aMatrix)
	Default lAutoMacao := .F.
	aProdList 			:= aMatrix
	IF !lAutoMacao
		oProdList:aArray	:= aMatrix
		oProdList:Refresh()
	ENDIF
Return Nil

Static Function showProcFileMeter(cRawPath)

	Local oMeterProg
	Local xRet
	Local xMeter
	Local cImportProg := "Processando arquivo"//TODO STR00??
	Default lAutoMacao := .F.
	
	IF !lAutoMacao
		DEFINE DIALOG oMeterProg TITLE STR0001/*"Importacao S&OP"*/ FROM 0, 0 TO 22, 75 SIZE 410, 135 PIXEL

		@ 010,010 SAY oSay VAR "Processamento:"/*//TODO STR00??*/ OF oMeterProg PIXEL FONT (TFont():New('Arial', 0, -11, .T., .T.))

		oMtTotal := TMeter():Create(oMeterProg, { |u| if(Pcount()>0,xMeter:=u,xMeter)}, 020, 010, Len(aProdList), 190, 15,, .T.)
		oMtTotal:Set(0)

		@  40,015 SAY oProg VAR cImportProg OF oMeterProg PIXEL

		ACTIVATE MSDIALOG oMeterProg CENTER ON INIT Eval({ || xRet := rawXMLToArray(cRawPath), oMeterProg:End() })
	ENDIF
Return xRet

Static Function showImportMeter()

	Local oMeterProg
	Local xRet
	Local xMeter
	Local cImportProg := STR0015/*"Iniciando importacao."*/
	Default lAutoMacao := .F.

	IF !lAutoMacao
		DEFINE DIALOG oMeterProg TITLE STR0001/*"Importacao S&OP"*/ FROM 0, 0 TO 22, 75 SIZE 410, 130 PIXEL

		@ 010, 010 SAY oSay VAR STR0016/*"Importacoes Realizadas:"*/ OF oMeterProg PIXEL FONT (TFont():New('Arial', 0, -11, .T., .T.))

		oMtTotal := TMeter():Create(oMeterProg, { |u| if(Pcount()>0,xMeter:=u,xMeter)}, 020, 010, Len(aProdList), 190, 15,, .T.)
		oMtTotal:Set(0)

		@  40, 015 SAY oProg VAR cImportProg OF oMeterProg PIXEL

		ACTIVATE MSDIALOG oMeterProg CENTER ON INIT Eval({ || xRet := importList(), oMeterProg:End() })
	ENDIF
Return xRet

Static Function showDeleteMeter(cImpKey, nMax)

	Local oMeterProg
	Local xMeter
	Local xRet
	Local cImportProg := STR0034+":" /*Exclusoes realizadas*/
	Default lAutoMacao := .F.

	IF !lAutoMacao
		DEFINE DIALOG oMeterProg TITLE STR0035+". "+STR0029+": "+cImpKey FROM 0, 0 TO 22, 75 SIZE 410, 130 PIXEL/*Exclusao importacao S&OP. Chave*/

		@ 010,010 SAY oSay VAR STR0036/*Excluindo registros*/ OF oMeterProg PIXEL FONT (TFont():New('Arial', 0, -11, .T., .T.))

		oMtTotal := TMeter():Create(oMeterProg, { |u| if(Pcount()>0,xMeter:=u,xMeter)}, 020, 010, nMax, 190, 15,, .T.)
		oMtTotal:Set(0)

		@  40,010 SAY oProg VAR cImportProg OF oMeterProg PIXEL	

		ACTIVATE MSDIALOG oMeterProg CENTER ON INIT Eval({ || xRet := delSC4Reg(nMax), oMeterProg:End() })
	ENDIF
Return xRet

// Realiza a importacao.
Static Function importList()

	Local nIt := 0
	Local importKey// Key para identificacao dos registros criados pela importacao

	DbSelectArea("SC4")

	importKey := genImpKey()

	writeOnLog(STR0015)/*"Iniciando importacao."*/	
	writeOnLog(STR0037+": "+importKey)

	SET DATE FRENCH

	For nIt := 1 To Len(aProdList)

		oProg:cCaption := STR0017/*"Realizando:"*/+" "+toStr(nIt)+" "+STR0018/*"de"*/+" "+toStr(Len(aProdList))
		oMtTotal:Set(nIt)

		If(aProdList[nIt][1] == .T.)
			RecLock("SC4", .T.)

			SC4->C4_FILIAL	:= xFilial('SC4')
			SC4->C4_PRODUTO	:= getProdCod(aProdList[nIt][2]) // c Codigo produto [2]
			SC4->C4_LOCAL	:= aProdList[nIt][6] // c Estoque - sb1 [6]
			SC4->C4_QUANT	:= aProdList[nIt][3] // n Quantidade [3]
			SC4->C4_DATA	:= toDate(aProdList[nIt][4])// d Data [4]
			SC4->C4_OBS		:= importKey

			/*
			Regras de montagem de opcs feitas em base do arquivo sigacusb.prx -> MarkOpc() e SeleOpc()
			If GetNewPar("MV_REPGOPC","N") == "N"
				SC4->C4_OPC	:= PADR( aProdList[nIt][7]+aProdList[nIt][8]+"  /", 10)
			Else
				SC4->C4_MOPC := buildStrTree(SC4->C4_PRODUTO, aProdList[nIt][7], aProdList[nIt][8])
			EndIf  */

			MsUnlock()
		EndIf
		writeOnLog(STR0026/*"Importacao finalizada."*/+" "+toStr(Len(aProdList))+" "+STR0027/*"registros criados na tabela SC4."*/)

	Next nIt

Return .T.

Static Function getProdCod(cParamCod)

	Local cProdCod
	Local nAt	:= At('/', cParamCod)

	If nAt > 0
		cProdCod := subStr( cParamCod, 0, nAt-1 )
	Else
		cProdCod := cParamCod
	EndIf

Return cProdCod

// Monta a tree para o campo MOPC quando o parametro MV_REPGOPC estiver ativo. "S"
Static Function buildStrTree(cCdProd, cGrpOpc, cOpc)

	Local aProdTree	:= {}
	Local nNvl		:= 0

	buildATree(@aProdTree, cCdProd, cGrpOpc, cOpc)
	clearTreeByOpc(@aProdTree)

Return Array2Str(aProdTree, .F.)

// Funcao recursiva para construir o array de branchs.
Static Function buildATree(aTree, cProd, cGrpOpc, cOpc, cPrevLine)

	Local cAliasQry	  := getNextAlias()
	Local cTreeBranch := ""
	Local lIsAncestor := .F.

	Default cPrevLine := ""

	If(cPrevLine == "", lIsAncestor := .T., Nil)	

	BeginSql Alias cAliasQry
		SELECT SG1.G1_COMP, SG1.G1_COD, SG1.G1_TRT, SG1.G1_GROPC, SG1.G1_OPC, SG1.G1_FIM
			FROM %table:SG1% SG1
			WHERE SG1.G1_COD  = %exp:cProd%
			AND SG1.G1_FILIAL = %xFilial:SG1% AND D_E_L_E_T_ = %exp:" "%
	EndSql

	While (cAliasQry)->(!EOF())

		If(STOD((cAliasQry)->(G1_FIM)) <= Date())
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		If(lIsAncestor)
			cTreeBranch := (cAliasQry)->(G1_COD)+(cAliasQry)->(G1_COMP)+(cAliasQry)->(G1_TRT)
		Else
			cTreeBranch := cPrevLine+(cAliasQry)->(G1_COMP)+(cAliasQry)->(G1_TRT)
		EndIf

		AADD(aTree, {cTreeBranch, PADR((cAliasQry)->(G1_GROPC)+(cAliasQry)->(G1_OPC)+"  /", 10)})
		buildATree(@aTree, (cAliasQry)->(G1_COMP), cGrpOpc, cOpc, cTreeBranch)
		(cAliasQry)->(dbSkip())

	EndDo

Return Nil

//Limpa a lista, deixando apenas branchs/linhas que possuem opcional.
Static Function clearTreeByOpc(aTree)

	Local nALen		:= Len(aTree)
	Local nDelSize	:= 0

	While nALen > 0
		If(AllTrim(aTree[nAlen][2]) == "/")
			ADEL(aTree, nAlen)
			nDelSize++
		EndIf
		nAlen--
	EndDo

	ASIZE(aTree, Len(aTree) - nDelSize)

Return Nil

//Realiza as preparações para sair do programa ao finalizar a importacao.
Static Function finishImport(oPainel)
	Default lAutoMacao := .F.
	
	IF !lAutoMacao
		oPainel:End()
	ENDIF

	lToggle			:= Nil
	aProdList		:= Nil
	aTotMonthDays	:= Nil
	aMonthParams	:= Nil
	FreeObj(oProdList)
	FreeObj(oCheckBox)

Return Nil

Static Function cancelImport(oPainel)

	finishImport(oPainel)
	FClose(fSOPLogFile)

Return Nil

//Helpers
Static Function toDate(cDate)
Return CTOD(AllTrim(cDate))

Static Function toStr(nStr)
Return AllTrim(Str(nStr))

Static Function createLog(cFilePath)
Return FCreate(SUBSTR(cFilePath, 0, (RAT('\', cFilePath)))+"importSOP_"+DTOS(DATE())+toStr(INT(SECONDS()))+".log")

Static Function writeOnLog(fMsg)
	Local cDate := DTOC(Date())
	FWrite(fSOPLogFile, cDate+" "+TIME()+" "+fMsg+CHR(13)+CHR(10))
Return Nil

Static Function genImpKey()
Return "IMPORTSOP-"+STRTRAN(DTOC(Date()), '/', '')+"-"+STRTRAN(TIME(), ':', '')
