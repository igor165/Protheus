#INCLUDE "OGAR250.ch"
#include "protheus.ch"
#include "report.ch"

Static oFnt08C  := TFont():New("Arial", 08, 08, , .F., , , , .T., .F., .F.)
Static oFnt08N  := TFont():New("Arial", 08, 08, , .T., , , , .T., .F., .F.)
Static oFnt10C  := TFont():New("Arial", 10, 10, , .F., , , , .T., .F., .F.)
Static oFnt10N  := TFont():New("Arial", 10, 10, , .T., , , , .T., .F., .F.)
Static oFnt12C  := TFont():New("Arial", 12, 12, , .F., , , , .T., .F., .F.)
Static oFnt12N  := TFont():New("Arial", 12, 12, , .T., , , , .T., .F., .F.)
Static oFnt14C  := TFont():New("Arial", 14, 14, , .F., , , , .T., .F., .F.)
Static oFnt14N  := TFont():New("Arial", 14, 14, , .T., , , , .T., .F., .F.)
Static oFnt18N  := TFont():New("Arial", 18, 18, , .T., , , , .T., .F., .F.)
Static oFnt18NU := TFont():New("Arial", 18, 18, , .T., , , , .T., .T., .F.)

/*/{Protheus.doc} OGAR250
Impressão da lista de fardos de algodão do romaneio.
@author rafael.kleestadt
@since 02/05/2018
@version 1.0

@type function
/*/
Function OGAR250()

	Local oReport := Nil	
	Local cPerg   := PadR('OGAR250',10) // Nome do Pergunte
    Private _lAutoTest := .F. //variável tb declara nos scripts de automação    
	
	N9D->(DbSetorder(6))
	If !N9D->(dbSeek(FwxFilial("NJJ") + NJJ->NJJ_CODROM + '07'))//Empty(_aArrayMast)
		Help(" ", 1, ".OGAR25000001.") //##Problema: Não há fardos vinculados a este romaneio. //##Solução: Certifique-se de ter vinculado os fardos ao romaneio ou escolha outro romaneio.				                           
		Return .T.
	EndIf

	Pergunte(cPerg, .T.)	

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author rafael.kleestadt
@since 02/05/2018
@version 1.0

@type Static function
/*/
Static Function ReportDef()

	Local oReport := Nil	

    oReport := TReport():New("OGAR250", STR0001, , {|oReport| PrintReport(oReport)}, STR0001) //"Lista Fardos Romaneio"
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 08 // Tamanho da fonte
	oReport:nDevice := 6 // Tipo de impressão 6-PDF

Return oReport

/*/{Protheus.doc} PrintReport
Imprime o conteudo do relatório
@author rafael.kleestadt
@since 02/05/2018
@version undefined
@param oReport, object, objeto do relatório
@type function
/*/
Static Function PrintReport(oReport)

	Local nLin 	        := 200
	Local nLinhas       := 0
	Local cNomeEmp      := ""
	Local cNmFil        := ""
	Local nX            := 0
	Local nY            := 0
	Local nZ            := 0
	Local nContIes      := 0

	Local cNmEntida     := POSICIONE('NJ0',1,XFILIAL('NJ0')+NJJ->NJJ_CODENT+NJJ->NJJ_LOJENT,'NJ0_NOME')
	Local cNmTransp     := POSICIONE('SA4',1,XFILIAL('SA4')+NJJ->NJJ_CODTRA,'A4_NOME')
	Local cNmMotori     := POSICIONE('DA4',1,XFILIAL('DA4')+NJJ->NJJ_CODMOT,'DA4_NOME')
	Local cNpjTrans     := Transform( POSICIONE('SA4',1,XFILIAL('SA4')+NJJ->NJJ_CODTRA,'A4_CGC'), "@R 99.999.999/9999-99" ) 
	Local nToFrds       := 0 
	Local nTotPsB       := 0 
	Local nTotPsL       := 0 
	Local cFazenda      := Posicione("NN2",3,xFilial("NN2")+NJJ->(NJJ_CODENT+NJJ_LOJENT+NJJ_FAZ),"NN2_NOME")
	Local cDescIe       := ""
    
    Private _aArrayMast := {}

	_aArrayMast := OGAR250QRY()
	
	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

	//Infos Romaneio
	cTxRoman := STR0002 + NJJ->NJJ_CODROM //"Romaneio de Embarque Nº "
	cTxSafra := RetTitle("NJJ_CODSAF") + AllTrim(NJJ->NJJ_CODSAF) //"SAFRA "

	printLinha(nLin, 10,   cTxRoman, oFnt18N, @oReport) //"Romaneio de Embarque Nº "
	printLinha(nLin, 2000, cTxSafra, oFnt14N, @oReport) //"SAFRA "

	oReport:SkipLine(3)
	nLin := oReport:Row()

	printLinha(nLin, 10, cFazenda, oFnt14N, @oReport) //"Fazenda "
	printLinha(nLin, 2000, DTOC(NJJ->NJJ_DATA), oFnt14N, @oReport) //"Data  "

	oReport:SkipLine(2)
	nLin := oReport:Row()

	printLinha(nLin, 2000, cValToChar(NJJ->NJJ_HRULAL), oFnt14N, @oReport) //"Hora Atualização "

	oReport:SkipLine(2)
	nLin := oReport:Row()

	oReport:ThinLine() //Imprime uma linha fina

	oReport:SkipLine(2)
	nLin := oReport:Row()

	//Sub-Infos Romaneio
	printLinha(nLin, 10,  RetTitle("NJJ_NOMENT"), oFnt14N, @oReport) //"Nome Entidad "
	printLinha(nLin, 400, cNmEntida, oFnt12C, @oReport) //"Nome Entidad "

	oReport:SkipLine(2)
	nLin := oReport:Row()

	printLinha(nLin, 10,  RetTitle("NJJ_CODCTR"), oFnt14N, @oReport) //"Contrato "
	printLinha(nLin, 250, getCtrExt(), oFnt12C, @oReport) //"Contratos Externos conforme NJM "

	printLinha(nLin, 1100, RetTitle("N7Q_DESINE"), oFnt14N, @oReport) //"Instr. Emb. "

	dbSelectArea("N9E")
	dbSetOrder(1)
	If dbSeek(NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM)

		While N9E->(!(Eof()) .And. N9E->N9E_FILIAL+N9E->N9E_CODROM == NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM ) .And. !Empty(N9E->(N9E_CODINE))

			cDescIe := AllTrim(Posicione("N7Q",1,xFilial("N7Q")+N9E->(N9E_CODINE),"N7Q_DESINE"))

			nContIes ++

			If nContIes > 1
				oReport:SkipLine(2)
				nLin := oReport:Row()
			EndIf
			
			printLinha(nLin, 1350,   cDescIe, oFnt12C, @oReport) //"Instr. Emb. "

			N9E->(dbSkip())
		EndDo

	EndIf
	N9E->(dbCloseArea())

	oReport:SkipLine(2)
	nLin := oReport:Row()

	printLinha(nLin, 10,   RetTitle("NJJ_NOMTRA"), oFnt14N, @oReport) //"Nome Transp. "
	printLinha(nLin, 400,  cNmTransp, oFnt12C, @oReport) //"Nome Transp. "

	printLinha(nLin, 1100,  RetTitle("NJJ_NOMMOT"), oFnt14N, @oReport) //"Nome Motor. "
	printLinha(nLin, 1420, cNmMotori, oFnt12C, @oReport) //"Nome Motor. "

	printLinha(nLin, 2050, RetTitle("NJJ_PLACA"), oFnt14N, @oReport) //"Placa "
	printLinha(nLin, 2200, NJJ->NJJ_PLACA, oFnt12C, @oReport) //"Placa "

	oReport:SkipLine(2)
	nLin := oReport:Row()

	printLinha(nLin, 400, AllTrim(RetTitle("A4_CGC")) + ": " , oFnt12C, @oReport) //"CNPJ/CPF "
	printLinha(nLin, 650, cNpjTrans, oFnt12C, @oReport) //"CNPJ/CPF "

	oReport:SkipLine(2)
	nLin := oReport:Row()

	//Fardinhos Romaneio
	For nX := 1 To Len(_aArrayMast)

		nLin := QbrPg(nLin, oReport) //Quebra a pagina e posiciona o cursor abaixo do cabeçalho

		If nX > 1 .And. nLin <> 200
			nLin := nLin + 80
		EndIf

		cDescIe := AllTrim(Posicione("N7Q",1,xFilial("N7Q")+_aArrayMast[nX][5],"N7Q_DESINE"))

		If MV_PAR02 == 1
			printLinha(nLin, 10,  RetTitle("DXI_BLOCO"), oFnt14N, @oReport) //"Bloco "
			printLinha(nLin, 200, _aArrayMast[nX][1], oFnt12C, @oReport)
		EndIf

		printLinha(nLin, 600,  RetTitle("DXI_CLACOM"), oFnt14N, @oReport) //"Tipo  "
		printLinha(nLin, 1000, _aArrayMast[nX][2], oFnt12C, @oReport)
		printLinha(nLin, 1250, RetTitle("N7Q_DESINE"), oFnt14N, @oReport) //"Instr.Embarq "
		printLinha(nLin, 1650, cDescIe, oFnt12C, @oReport)

		oReport:SkipLine(2)
		nLin := oReport:Row()

		//Cabeçalho Coluna 1
		printLinha(nLin, 10,  STR0003, oFnt10N, @oReport) //"Item"
		printLinha(nLin, 90,  RetTitle("N9D_FARDO"), oFnt10C, @oReport) //"Cód. Fardinho  "
		printLinha(nLin, 420, RetTitle("DXI_PSLIQU"), oFnt10C, @oReport) //"Peso Liquido"
		printLinha(nLin, 650, RetTitle("DXI_BLOCO"), oFnt10C, @oReport) //"Bloco"

		//Cabeçalho Coluna 2
		printLinha(nLin, 850,  STR0003, oFnt10N, @oReport) //"Item"
		printLinha(nLin, 930,  RetTitle("N9D_FARDO"), oFnt10C, @oReport) //"Cód. Fardinho  "
		printLinha(nLin, 1260, RetTitle("DXI_PSLIQU"), oFnt10C, @oReport) //"Peso Liquido"
		printLinha(nLin, 1480, RetTitle("DXI_BLOCO"), oFnt10C, @oReport) //"Bloco"

 		//Cabeçalho Coluna 3
		printLinha(nLin, 1650, STR0003, oFnt10N, @oReport) //"Item"
		printLinha(nLin, 1730, RetTitle("N9D_FARDO"), oFnt10C, @oReport) //"Cód. Fardinho  "
		printLinha(nLin, 2060, RetTitle("DXI_PSLIQU"), oFnt10C, @oReport) //"Peso Liquido"
		printLinha(nLin, 2280, RetTitle("DXI_BLOCO"), oFnt10C, @oReport) //"Bloco"

		oReport:SkipLine(2)
		oReport:ThinLine() //Imprime uma linha fina

		oReport:SkipLine(1)
		nLin := oReport:Row()

		nLinhas := Ceiling( Len(_aArrayMast[nX][6]) / 3 )
		nLinFim := nLinhas

 		For nY := 1 To nLinhas

		 	nLin := QbrPg(nLin, oReport) //Quebra a pagina e posiciona o cursor abaixo do cabeçalho
			
			printLinha(nLin, 10,  cValToChar(nY), oFnt08N, @oReport) //"Item"
			
			If MV_PAR03 == 2
				printLinha(nLin, 90,  SUBSTR(_aArrayMast[nX][6][nY][1],-11), oFnt08C, @oReport) //"Cód. Fardinho Resumido "
			Else
				printLinha(nLin, 90,  _aArrayMast[nX][6][nY][1], oFnt08C, @oReport) //"Cód. Fardinho  "				
			EndIf
			printLinha(nLin, 420, cValToChar(_aArrayMast[nX][6][nY][2]), oFnt08C, @oReport) //"Peso Liq."
			printLinha(nLin, 650, _aArrayMast[nX][6][nY][3], oFnt08C, @oReport) //"Bloco"

			If nY + nLinhas <= Len(_aArrayMast[nX][6])

				printLinha(nLin, 850,  cValToChar(nY + nLinhas), oFnt08N, @oReport) //"Item"
				
				If MV_PAR03 == 2
					printLinha(nLin, 930,  SUBSTR(_aArrayMast[nX][6][nY + nLinhas][1],-11), oFnt08C, @oReport) //"Cód. Fardinho Resumido "
				Else
					printLinha(nLin, 930,  _aArrayMast[nX][6][nY + nLinhas][1], oFnt08C, @oReport) //"Cód. Fardinho  "
				EndIf
				printLinha(nLin, 1260, cValToChar(_aArrayMast[nX][6][nY + nLinhas][2]), oFnt08C, @oReport) //"Peso Liq."
				printLinha(nLin, 1480, _aArrayMast[nX][6][nY + nLinhas][3], oFnt08C, @oReport) //"Bloco"

			EndIf

			If nY + (nLinhas * 2) <= Len(_aArrayMast[nX][6])
			
				printLinha(nLin, 1650, cValToChar(nY + (nLinhas * 2)), oFnt08N, @oReport) //"Item"
				If MV_PAR03 == 2
					printLinha(nLin, 1730, SUBSTR(_aArrayMast[nX][6][nY + (nLinhas * 2)][1],-11), oFnt08C, @oReport) //"Cód. Fardinho Resumido "
				Else
					printLinha(nLin, 1730, _aArrayMast[nX][6][nY + (nLinhas * 2)][1], oFnt08C, @oReport) //"Cód. Fardinho  "
				Endif
				printLinha(nLin, 2060, cValToChar(_aArrayMast[nX][6][nY + (nLinhas * 2)][2]), oFnt08C, @oReport) //"Peso Liq."
				printLinha(nLin, 2280, _aArrayMast[nX][6][nY + (nLinhas * 2)][3], oFnt08C, @oReport) //"Bloco"

			EndIf

			oReport:SkipLine(2)
			nLin := oReport:Row()

		Next nY

		nLin := oReport:Row() + 1

		printLinha(nLin, 10,   STR0004 + ": ", oFnt14N, @oReport) //"Fardinhos: "
		printLinha(nLin, 300,  cValToChar(Len(_aArrayMast[nX][6])), oFnt12C, @oReport)
		printLinha(nLin, 700,  AllTrim(RetTitle("DXI_PSBRUT")) + ": ", oFnt14N, @oReport) //"Peso Bru.:  "
		printLinha(nLin, 1000, cValToChar(_aArrayMast[nX][4]), oFnt12C, @oReport)
		printLinha(nLin, 1350, AllTrim(RetTitle("DXI_PSLIQU")) + ": ", oFnt14N, @oReport) //"Peso Liquido:  "
		printLinha(nLin, 1750, cValToChar(_aArrayMast[nX][3]), oFnt12C, @oReport)

		oReport:SkipLine(2)
		oReport:ThinLine() //Imprime uma linha fina

		nToFrds += Len(_aArrayMast[nX][6])
		nTotPsB += _aArrayMast[nX][4]
		nTotPsL += _aArrayMast[nX][3]

	Next nX

	oReport:SkipLine(2)
	nLin := oReport:Row()

	printLinha(nLin, 10,   STR0005 + ": ", oFnt14N, @oReport) //"Total de Fardinhos: "
	printLinha(nLin, 500,  cValToChar(nToFrds), oFnt12C, @oReport)
 	printLinha(nLin, 700,  STR0006 + " " + AllTrim(RetTitle("DXI_PSBRUT")) + ": ", oFnt14N, @oReport) //"Total Peso Bru.: "
	printLinha(nLin, 1100,  cValToChar(nTotPsB), oFnt12C, @oReport)
	printLinha(nLin, 1350, STR0006 + " " + AllTrim(RetTitle("DXI_PSLIQU")) + ": ", oFnt14N, @oReport) //"Total Peso Liquido: "
	printLinha(nLin, 1850, cValToChar(nTotPsL), oFnt12C, @oReport)

	oReport:SkipLine(2)
	oReport:ThinLine() //Imprime uma linha fina

	oReport:SkipLine(2)
	nLin := oReport:Row()

	nLin := QbrPg(nLin, oReport) //Quebra a pagina e posiciona o cursor abaixo do cabeçalho

	printLinha(nLin, 890, STR0008, oFnt18NU, @oReport) //"Resumo dos Blocos"

	oReport:SkipLine(3)
	nLin := oReport:Row()

	//Cabeçalho Totalizadores
	If MV_PAR02 == 1
		printLinha(nLin, 10,  RetTitle("DXI_BLOCO"), oFnt14N, @oReport) //"Bloco "
	EndIf
	printLinha(nLin, 200, RetTitle("DXI_CLACOM"), oFnt14N, @oReport) //"Tipo  "
	printLinha(nLin, 600, RetTitle("N7Q_DESINE"), oFnt14N, @oReport) //"Instr.Embarq "
	printLinha(nLin, 1600, STR0009, oFnt14N, @oReport) //"Qtde.  "
	printLinha(nLin, 2000, RetTitle("DXI_PSLIQU"), oFnt14N, @oReport) //"Peso Liquido"

	oReport:SkipLine(2)
	nLin := oReport:Row()

	//Itens totalizadores
	For nZ := 1 To Len(_aArrayMast)

		nLin := QbrPg(nLin, oReport) //Quebra a pagina e posiciona o cursor abaixo do cabeçalho

		cDescIe := AllTrim(Posicione("N7Q",1,xFilial("N7Q")+_aArrayMast[nZ][5],"N7Q_DESINE"))

		printLinha(nLin, 10,  _aArrayMast[nZ][1], oFnt12C, @oReport) //"Bloco "
		printLinha(nLin, 200, _aArrayMast[nZ][2], oFnt12C, @oReport) //"Tipo"
		printLinha(nLin, 600, cDescIe, oFnt12C, @oReport) //"Instr.Embarq "
		printLinha(nLin, 1600, cValToChar(Len(_aArrayMast[nZ][6])), oFnt12C, @oReport) //"Qtde."
		printLinha(nLin, 2000, cValToChar(_aArrayMast[nZ][3]), oFnt12C, @oReport) //"Peso Liq."

		oReport:SkipLine(2)
		nLin := oReport:Row()

	Next nZ

	If MV_PAR01 == 1

		oReport:SkipLine(5)
		nLin := oReport:Row()

		nLin := QbrPg(nLin, oReport) //Quebra a pagina e posiciona o cursor abaixo do cabeçalho

		printLinha(nLin, 100,  "________________________________________", oFnt12C, @oReport)
		printLinha(nLin, 1500, "________________________________________", oFnt12C, @oReport)

		oReport:SkipLine(2)
		nLin := oReport:Row()

		printLinha(nLin, 100,  STR0011, oFnt12C, @oReport) //"Assinatura do Emissor"
		printLinha(nLin, 1500, STR0012, oFnt12C, @oReport) //"Assinatura do Motorista"
	EndIf

Return Nil

/*/{Protheus.doc} AGRARCabec
//Cabecalho customizado do report
@author janaina.duarte
@since 31/03/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function AGRARCabec(oReport, cNmEmp , cNmFilial)
	Local aCabec := {}
	Local cChar	 := CHR(160)  // caracter dummy para alinhamento do cabeçalho

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

	// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

	// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, STR0010 + ":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio

Return aCabec


/*/{Protheus.doc} OGAR250QRY
busca os dados e monta o array com os fardos do romaneio
@type  Static Function
@author rafael.kleestadt	
@since 02/05/2018
@version 1.0
@param param, param type, param desc
@return aArrayMast, array, array com os fardos do romaneio
@example
(examples)
@see (links_or_references)
/*/
Static Function OGAR250QRY()

	Local aArrayMast	:= {}
	Local cAliasN9D 	:= GetNextAlias()
	Local cQryN9D  	    := "" 

	cQryN9D := "     SELECT N9D.N9D_FARDO, N9D.N9D_PESFIM, ((DXI.DXI_PSBRUT - DXI.DXI_PSLIQU) + N9D.N9D_PESFIM) AS PSBRUT, N9D.N9D_BLOCO, DXI.DXI_CLACOM, N9D.N9D_SAFRA, N9D.N9D_CODINE "
	cQryN9D += "       FROM " + RetSqlName("N9D") + " N9D "
	cQryN9D += " INNER JOIN " + RetSqlName("DXI") + " DXI ON DXI.DXI_ETIQ = N9D.N9D_FARDO "
	cQryN9D += "        AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
	cQryN9D += "        AND DXI.DXI_SAFRA = N9D.N9D_SAFRA "
	cQryN9D += "        AND DXI.D_E_L_E_T_ = '' "
	cQryN9D += "      WHERE N9D.N9D_CODROM = '" + NJJ->NJJ_CODROM + "' "
	cQryN9D += "        AND N9D.N9D_FILIAL= '" + FwxFilial("NJJ") + "' "
	cQryN9D += "        AND N9D.N9D_TIPMOV = '07' "
	cQryN9D += "        AND N9D.N9D_STATUS = '2' "
	cQryN9D += "        AND N9D.D_E_L_E_T_ = '' "
	cQryN9D += "   ORDER BY N9D.N9D_BLOCO "

	cQryN9D := ChangeQuery( cQryN9D )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9D), cAliasN9D, .F., .T.)

	//Seleciona a tabela 
	dbSelectArea(cAliasN9D)
	dbGoTop()

	While (cAliasN9D)->(!Eof()) 

		If MV_PAR02 == 1
			nPos := aScan( aArrayMast, { |x| x[1] + x[2] + x[5] == (cAliasN9D)->N9D_BLOCO + (cAliasN9D)->DXI_CLACOM + (cAliasN9D)->N9D_CODINE } )
		Else
			nPos := aScan( aArrayMast, { |x| x[2] + x[5] == (cAliasN9D)->DXI_CLACOM + (cAliasN9D)->N9D_CODINE } )
		EndIf

		If nPos == 0  
			aAdd( aArrayMast, { Iif(MV_PAR02 == 1, (cAliasN9D)->N9D_BLOCO, ""), (cAliasN9D)->DXI_CLACOM, (cAliasN9D)->N9D_PESFIM, (cAliasN9D)->PSBRUT, (cAliasN9D)->N9D_CODINE, { { (cAliasN9D)->N9D_FARDO,  (cAliasN9D)->N9D_PESFIM, (cAliasN9D)->N9D_BLOCO, (cAliasN9D)->DXI_CLACOM, (cAliasN9D)->N9D_SAFRA  } } } )
		Else
			aAdd( aArrayMast[nPos][6], { (cAliasN9D)->N9D_FARDO,  (cAliasN9D)->N9D_PESFIM, (cAliasN9D)->N9D_BLOCO, (cAliasN9D)->DXI_CLACOM, (cAliasN9D)->N9D_SAFRA  })
			aArrayMast[nPos,3] += (cAliasN9D)->N9D_PESFIM //Peso Liquído
			aArrayMast[nPos,4] += (cAliasN9D)->PSBRUT     //Peso Bruto
		EndIf
		
		(cAliasN9D)->(DbSkip())
	EndDo

	(cAliasN9D)->(DbCloseArea())	
Return aArrayMast

/*/{Protheus.doc} QbrPg
Quebra a pagina e posiciona na linha abaixo do cabeçalho padrão
@type  Static Function
@author rafael.kleestadt	
@since 02/05/2018
@version 1.0
@param nLin, numeric, numero da linha posicionada
@param oReport, object, objeto do relatório
@return nLinRet, numeric, numero da linha após o ajuste
@example
(examples)
@see (links_or_references)
/*/
Static Function QbrPg(nLin, oReport)

	Local nLinRet := nLin

	If nLin < 200
		nLinRet := 200
	ElseIf nLin >= 3000
		oReport:EndPage()
		nLinRet := 200
	EndIf

Return nLinRet

/*/{Protheus.doc} getCtrExt()
Cria uma String com os contrator externos conforme os contratos da NJM
@type  Static Function
@author rafael.kleestadt
@since 16/05/2018
@version version
@param param, param_type, param_descr
@return cCtrExt, caractere, String com os contrator externos conforme os contratos da NJM
@example
(examples)
@see (links_or_references)
/*/
Static Function getCtrExt()
Local cCtrExt := ""

DbSelectArea("NJM")
DbSetOrder(1)
If DbSeek(NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM)

	While NJM->(!(Eof()) .AND. NJM->NJM_FILIAL+NJM->NJM_CODROM == NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM )

		If Empty(cCtrExt)
			cCtrExt := AllTrim(Posicione("NJR",1,xFilial("NJR")+NJM->(NJM_CODCTR),"NJR_CTREXT"))
		Else
			cCtrExt += ", " + AllTrim(Posicione("NJR",1,xFilial("NJR")+NJM->(NJM_CODCTR),"NJR_CTREXT"))
		EndIf
		
		NJM->(dbSkip())
	EndDo

EndIf

Return cCtrExt

//-------------------------------------------------------------------
/*/{Protheus.doc} printLinha
Função para impressão da linha no relatório. Devido a automação de teste 
não considerar o comando Say foi necessário incluir essa tratativa.
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function printLinha(nLin, nCol, nTexto, oFonte, oReport)

    If !_lAutoTest
        oReport:Say(nLin, nCol, nTexto, oFonte)
    Else
        oReport:PrintText(nTexto, nLin, nCol)
    EndIf

Return
