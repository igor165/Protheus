#INCLUDE "OGAR120.ch"
#include "protheus.ch"
#include "report.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __oFnt07C  := TFont():New("Arial", 07, 07, , .F., , , , .T., .F., .F.)
Static __oFnt07N  := TFont():New("Arial", 07, 07, , .T., , , , .T., .F., .F.)
Static __oFnt08C  := TFont():New("Arial", 08, 08, , .F., , , , .T., .F., .F.)
Static __oFnt08N  := TFont():New("Arial", 08, 08, , .T., , , , .T., .F., .F.)
Static __oFnt10C  := TFont():New("Arial", 10, 10, , .F., , , , .T., .F., .F.)
Static __oFnt10N  := TFont():New("Arial", 10, 10, , .T., , , , .T., .F., .F.)
Static __oFnt12C  := TFont():New("Arial", 12, 12, , .F., , , , .T., .F., .F.)
Static __oFnt12N  := TFont():New("Arial", 12, 12, , .T., , , , .T., .F., .F.)
Static __oFnt14C  := TFont():New("Arial", 14, 14, , .F., , , , .T., .F., .F.)
Static __oFnt14N  := TFont():New("Arial", 14, 14, , .T., , , , .T., .F., .F.)
Static __oFnt18N  := TFont():New("Arial", 18, 18, , .T., , , , .T., .F., .F.)
Static __oFnt18NU := TFont():New("Arial", 18, 18, , .T., , , , .T., .T., .F.)

Static __nColIni  := 10
Static __nTotIni  := 450

//Inicio da impressão dos cabeçalhos da tabela 1
Static __nIniT1C2 := 70
Static __nIniT1C3 := 350
Static __nIniT1C4 := 450
Static __nIniT1C5 := 550
Static __nIniT1C6 := 650

//Inicio da impressão dos cabeçalhos da tabela 2
Static __nIniT2C1 := 830
Static __nIniT2C2 := 900
Static __nIniT2C3 := 1170
Static __nIniT2C4 := 1270
Static __nIniT2C5 := 1370
Static __nIniT2C6 := 1470

//Inicio da impressão dos cabeçalhos da tabela 3
Static __nIniT3C1 := 1670
Static __nIniT3C2 := 1740
Static __nIniT3C3 := 2010
Static __nIniT3C4 := 2110
Static __nIniT3C5 := 2210
Static __nIniT3C6 := 2310

/*/{Protheus.doc} OGAR120()
Função principai do relatório PACKING LIST BALE BY BALE
@type  Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGAR120()

	Local oReport := Nil

	//Verifica se o tipo de commiditie é algodão.
 	if Posicione("SB5",1,fwxFilial("SB5")+N7Q->N7Q_CODPRO,"B5_TPCOMMO") <> '2'			                             	
		HELP(' ',1,STR0002,,STR0003,2,0,,,,,, {STR0004})
		//##Titulo: "Tipo de Produto" 
		//##Problema: "O produto da instrução de embarque não é do tipo Algodão." 
		//##Solução: "Esta funcionalidade esta disponível apenas para produtos do tipo Algodão."
		Return .T.
	EndIf

	//Verifica se existem fardos estufados nos CNT's da IE.
	If !fExistFar()
		HELP(' ',1,STR0005,,STR0006,2,0,,,,,, {STR0007})
		//##Titulo: "Estufagem" 
		//##Problema: "Não há fardos vinculados aos contêineres da instrução de embarque." 
		//##Solução: "Certifique-se de ter vinculado fardos aos contêineres da instrução de embarque."
		Return .T.
	EndIf

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

	Static oReport := Nil

	oReport := TReport():New("OGAR120", STR0001, , {|oReport| PrintReport(oReport)}, STR0001) //"PACKING LIST BALE BY BALE"
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
	Local nLin 	   := 150
	Local cNomeEmp := ""
	Local cNmFil   := ""

	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

    DbSelectArea("N91")
    N91->(DbSetOrder(1))
    If N91->(DbSeek(FwxFilial("N91")+N7Q->N7Q_CODINE))
        While !N91->(EOF()) .AND. N91->N91_FILIAL+N91->N91_CODINE = FwxFilial("N91")+N7Q->N7Q_CODINE
			
			//Imprime os totalizadores antes da tabela de fardos, deve estar posicionado no contêiner(N91).
			nLin := fImpTots(nLin)

			//Busca os fardos e imprime a lista, deve estar posicionado no contêiner(N91).
			nLin := fImpDados(nLin)

			//Imprime o rodapé do relatório.
			fImpRod()
            
			//Imprime o rodapé do relatório.
            nLin := QbrPg(nLin, oReport)
            N91->(DbSkip())
        EndDo
    EndIf
	N91->(DbCloseArea())

Return Nil

/*/{Protheus.doc} AGRARCabec
//Cabecalho customizado do report
@author janaina.duarte
@since 31/03/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function AGRARCabec(cNmEmp, cNmFilial)
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
	/* aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + STR0008 + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, STR0009 + ":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio */

Return aCabec

/*/{Protheus.doc} QbrPg
Quebra a pagina e posiciona na linha abaixo do cabeçalho padrão.
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

    oReport:EndPage()
    nLinRet := 200

Return nLinRet

/*/{Protheus.doc} fImpTots()
Imprime os totalizadores antes da tabela de fardos, deve estar posicionado no contêiner.
@type  Static Function
@author rafael.kleestadt
@since 17/12/2018
@version 1.0
@param oReport, object, objeto principal do relatório
@param nLin, numeric, número da linha onde a impressão vai começar.
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpTots(nLin)
	Local aArea   := GetArea()
	Local nQtdFar := 0
	Local nPesBrt := 0
	Local nPesLiq := 0

	//TReport():Say( <nRow> , <nCol> , <cText> , <oFont> , <nWidth> , <nClrText> , <nBkMode> , <nPad> )
	oReport:Say(nLin, 890,  STR0001, __oFnt18N,,) //"PACKING LIST BALE BY BALE"

	oReport:SkipLine(3)
	nLin := oReport:Row()

	oReport:Say(nLin, __nColIni, "CNTR NO.:", __oFnt12N) //"CNTR NO.:"
	oReport:Say(nLin, __nTotIni, AllTrim(N91->N91_CONTNR), __oFnt12C) //"CNTR NO.:"

	oReport:SkipLine(2)
	nLin := oReport:Row()

	oReport:Say(nLin, __nColIni, "TOTAL OF BALES:", __oFnt12N) //"TOTAL OF BALES:"
	nQtdFar := AllTrim(cValToChar(Transform(N91->N91_QTDFRD, PesqPict('N91','N91_QTDFRD'))))
	oReport:Say(nLin, __nTotIni, nQtdFar, __oFnt12C) //"TOTAL OF BALES:"

	oReport:SkipLine(2)
	nLin := oReport:Row()

	oReport:Say(nLin, __nColIni, "TOTAL GROSS WEIGHT:", __oFnt12N) //"TOTAL GROSS WEIGHT:"
	nPesBrt := AllTrim(cValToChar(Transform(N91->N91_BRTCER, PesqPict('N91','N91_BRTCER'))))
	oReport:Say(nLin, __nTotIni, nPesBrt, __oFnt12C) //"TOTAL GROSS WEIGHT:"

	oReport:SkipLine(2)
	nLin := oReport:Row()

	oReport:Say(nLin, __nColIni, "TOTAL TARE WEIGHT:", __oFnt12N) //"TOTAL TARE WEIGHT:"
	oReport:Say(nLin, __nTotIni, cValToChar(N91->N91_BRTCER - N91->N91_QTDCER), __oFnt12C) //"TOTAL TARE WEIGHT:"

	oReport:SkipLine(2)
	nLin := oReport:Row()

	oReport:Say(nLin, __nColIni, "TOTAL NET WEIGHT:", __oFnt12N) //"TOTAL NET WEIGHT:"
	nPesLiq := AllTrim(cValToChar(Transform(N91->N91_QTDCER, PesqPict('N91','N91_QTDCER'))))
	oReport:Say(nLin, __nTotIni, nPesLiq, __oFnt12C) //"TOTAL NET WEIGHT:"

	oReport:SkipLine(2)
	nLin := oReport:Row()	

	RestArea(aArea)	

Return nLin

/*/{Protheus.doc} fImpDados(nLin)
Busca os fardos e imprime a lista, deve estar posicionado no contêiner(N91).
@type  Static Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param nLin, numeric, linha onde deveiniciar a impressão dos dados.
@return nLin, numeric, numero da ultima linha impressa
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpDados(nLin)
	Local cAliasN9D := GetNextAlias()
	Local cQryN9D  	:= "" 
	local nSeq      := 0
	local nLinBkp   := nLin
	local nLinBrk   := 50 //registros por tabela

	//Imprime o cabeçalho fixo das colunas das tabelas dos fardos.
	nLin := fImpCab(nLin) + 3

	nLinBkp := nLin

	cQryN9D := "     SELECT N9D.N9D_FARDO, DXI.DXI_PSBRUT, DXI.DXI_PSTARA, DXI.DXI_PSLIQU, DXI.DXI_BLOCO "
	cQryN9D += "       FROM " + RetSqlName("N9D") + " N9D "
	cQryN9D += " INNER JOIN " + RetSqlName("DXI") + " DXI ON DXI.DXI_ETIQ = N9D.N9D_FARDO "
	cQryN9D += "        AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
	cQryN9D += "        AND DXI.DXI_SAFRA = N9D.N9D_SAFRA "
	cQryN9D += "        AND DXI.D_E_L_E_T_ = '' "
	cQryN9D += "      WHERE N9D.N9D_CONTNR = '" + N91->N91_CONTNR + "' "
	cQryN9D += "        AND N9D.N9D_FILIAL = '" + FwxFilial("N9D") + "' "
	cQryN9D += "        AND N9D.N9D_CODINE = '" + N7Q->N7Q_CODINE + "' "
	cQryN9D += "        AND N9D.N9D_TIPMOV = '05' "
	cQryN9D += "        AND N9D.N9D_STATUS = '2' "
	cQryN9D += "        AND N9D.N9D_TIPOPE = '1' "
	cQryN9D += "        AND N9D.D_E_L_E_T_ = '' "
	cQryN9D += "   ORDER BY N9D.N9D_BLOCO "

	cQryN9D := ChangeQuery( cQryN9D )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9D), cAliasN9D, .F., .T.)

	//Seleciona a tabela 
	DbSelectArea(cAliasN9D)
	DbGoTop()
	While (cAliasN9D)->(!Eof()) 

		nSeq ++

		If nSeq <= nLinBrk
			nLin := fImpDTab1(nSeq, nLin, (cAliasN9D)->(N9D_FARDO), (cAliasN9D)->(DXI_PSBRUT), (cAliasN9D)->(DXI_PSTARA), (cAliasN9D)->(DXI_PSLIQU), (cAliasN9D)->(DXI_BLOCO))
		ElseIf nSeq > nLinBrk .And. nSeq <= nLinBrk * 2
			If nSeq == nLinBrk + 1
				nLin := nLinBkp
			EndIf
			nLin := fImpDTab2(nSeq, nLin, (cAliasN9D)->(N9D_FARDO), (cAliasN9D)->(DXI_PSBRUT), (cAliasN9D)->(DXI_PSTARA), (cAliasN9D)->(DXI_PSLIQU), (cAliasN9D)->(DXI_BLOCO))
		Else
			If nSeq == (nLinBrk * 2) + 1
				nLin := nLinBkp
			EndIf
			nLin := fImpDTab3(nSeq, nLin, (cAliasN9D)->(N9D_FARDO), (cAliasN9D)->(DXI_PSBRUT), (cAliasN9D)->(DXI_PSTARA), (cAliasN9D)->(DXI_PSLIQU), (cAliasN9D)->(DXI_BLOCO))
		EndIf
		
		(cAliasN9D)->(DbSkip())
	EndDo

	(cAliasN9D)->(DbCloseArea())


Return nLin

/*/{Protheus.doc} nomeStaticFunction
Imprime o cabeçalho fixo das colunas das tabelas dos fardos.
@type  Static Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param nLin, numeric, linha onde deve iniciar a impressão do relatório.
@return nLin, numeric, numero da ultima linha impressa no relatório.
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpCab(nLin)
	Local nLinBkp := nLin

	//Cabeçalho tabela 1
	oReport:Say(nLin, __nIniT1C3, "GROSS",  __oFnt07C) //"GROSS"
	oReport:Say(nLin, __nIniT1C4, "TARE",   __oFnt07C) //"TARE"
	oReport:Say(nLin, __nIniT1C5, "NET",    __oFnt07C) //"NET"
	oReport:SkipLine(1)
	nLin := oReport:Row()
	oReport:Say(nLin, __nColIni,  "SEQ",    __oFnt07N) //"SEQ"
	oReport:Say(nLin, __nIniT1C2, "BALE",   __oFnt07C) //"BALE"
	oReport:Say(nLin, __nIniT1C3, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT1C4, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT1C5, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT1C6, "LOT",    __oFnt07C) //"LOT"
	oReport:SkipLine(1)
	nLin := oReport:Row()   
	oReport:Say(nLin, __nIniT1C3, "(KGS)",  __oFnt07C) //"(KGS)"
	oReport:Say(nLin, __nIniT1C4, "(KGS)",  __oFnt07C) //"(KGS)"
	oReport:Say(nLin, __nIniT1C5, "(KGS)",  __oFnt07C) //"(KGS)"

	nLin := nLinBkp

	//Cabeçalho tabela 2
	oReport:Say(nLin, __nIniT2C3, "GROSS",  __oFnt07C) //"GROSS"
	oReport:Say(nLin, __nIniT2C4, "TARE",   __oFnt07C) //"TARE"
	oReport:Say(nLin, __nIniT2C5, "NET",    __oFnt07C) //"NET"
	oReport:nRow := nLin
	oReport:SkipLine(1)
	nLin := oReport:Row()
	oReport:Say(nLin, __nIniT2C1, "SEQ",    __oFnt07N) //"SEQ"
	oReport:Say(nLin, __nIniT2C2, "BALE",   __oFnt07C) //"BALE"
	oReport:Say(nLin, __nIniT2C3, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT2C4, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT2C5, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT2C6, "LOT",    __oFnt07C) //"LOT"
	oReport:SkipLine(1)
	nLin := oReport:Row()   
	oReport:Say(nLin, __nIniT2C3, "(KGS)",  __oFnt07C) //"(KGS)"
	oReport:Say(nLin, __nIniT2C4, "(KGS)",  __oFnt07C) //"(KGS)"
	oReport:Say(nLin, __nIniT2C5, "(KGS)",  __oFnt07C) //"(KGS)"

	nLin := nLinBkp

	//Cabeçalho tabela 3
	oReport:Say(nLin, __nIniT3C3, "GROSS",  __oFnt07C) //"GROSS"
	oReport:Say(nLin, __nIniT3C4, "TARE",   __oFnt07C) //"TARE"
	oReport:Say(nLin, __nIniT3C5, "NET",    __oFnt07C) //"NET"
	oReport:nRow := nLin
	oReport:SkipLine(1)
	nLin := oReport:Row()
	oReport:Say(nLin, __nIniT3C1, "SEQ",    __oFnt07N) //"SEQ"
	oReport:Say(nLin, __nIniT3C2, "BALE",   __oFnt07C) //"BALE"
	oReport:Say(nLin, __nIniT3C3, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT3C4, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT3C5, "WEIGHT", __oFnt07C) //"WEIGHT"
	oReport:Say(nLin, __nIniT3C6, "LOT",    __oFnt07C) //"LOT"
	oReport:SkipLine(1)
	nLin := oReport:Row()   
	oReport:Say(nLin, __nIniT3C3, "(KGS)",  __oFnt07C) //"(KGS)"
	oReport:Say(nLin, __nIniT3C4, "(KGS)",  __oFnt07C) //"(KGS)"
	oReport:Say(nLin, __nIniT3C5, "(KGS)",  __oFnt07C) //"(KGS)"

	oReport:SkipLine(1)
	oReport:ThinLine() //Imprime uma linha fina
	nLin := oReport:Row()

Return nLin

/*/{Protheus.doc} fImpDTab1()
Imprime os dados dinamicos da tabela 1.
@type  Static Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param nSeq, numeric, sequencial a ser impresso na primeira coluna da tabela 1.
@param nLin, numeric, linha onde os dados devem ser impressos.
@param cFardo, caractere, etiqueta do fardo.
@param nPsBrut, numeric, peso bruto do fardo.
@param nTara, numeric, peso bruto - peso liquido do fardo.
@param nPsLiqu, numeric, peso liquido do fardo.
@param cBloco, caractere, bloco do fardo.
@return nLin, numeric, ultima linha disponivel a ser utilizada.
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpDTab1(nSeq, nLin, cFardo, nPsBrut, nTara, nPsLiqu, cBloco)
    
    cFardo := RIGHT(cFardo, 11) 
	oReport:Say(nLin, __nColIni,  cValToChar(nSeq),    __oFnt07N) //"SEQ"
	oReport:Say(nLin, __nIniT1C2, AllTrim(cFardo),     __oFnt07C) //"BALE"
	oReport:Say(nLin, __nIniT1C3, cValToChar(nPsBrut), __oFnt07C) //"GROSS WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT1C4, cValToChar(nTara),   __oFnt07C) //"TARE WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT1C5, cValToChar(nPsLiqu), __oFnt07C) //"NET WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT1C6, AllTrim(cBloco),     __oFnt07C) //"LOT"

	oReport:SkipLine(1)
	nLin := oReport:Row()   

Return nLin

/*/{Protheus.doc} fImpDTab2()
Imprime os dados dinamicos da tabela 2.
@type  Static Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param nSeq, numeric, sequencial a ser impresso na primeira coluna da tabela 2.
@param nLin, numeric, linha onde os dados devem ser impressos.
@param cFardo, caractere, etiqueta do fardo.
@param nPsBrut, numeric, peso bruto do fardo.
@param nTara, numeric, peso bruto - peso liquido do fardo.
@param nPsLiqu, numeric, peso liquido do fardo.
@param cBloco, caractere, bloco do fardo.
@return nLin, numeric, ultima linha disponivel a ser utilizada.
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpDTab2(nSeq, nLin, cFardo, nPsBrut, nTara, nPsLiqu, cBloco)
	
	oReport:nRow := nLin
    
    cFardo := RIGHT(cFardo, 11) 
	oReport:Say(nLin, __nIniT2C1, cValToChar(nSeq),    __oFnt07N) //"SEQ"
	oReport:Say(nLin, __nIniT2C2, AllTrim(cFardo),     __oFnt07C) //"BALE"
	oReport:Say(nLin, __nIniT2C3, cValToChar(nPsBrut), __oFnt07C) //"GROSS WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT2C4, cValToChar(nTara),   __oFnt07C) //"TARE WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT2C5, cValToChar(nPsLiqu), __oFnt07C) //"NET WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT2C6, AllTrim(cBloco),     __oFnt07C) //"LOT"

	oReport:SkipLine(1)
	nLin := oReport:Row()   

Return nLin

/*/{Protheus.doc} fImpDTab3()
Imprime os dados dinamicos da tabela 3.
@type  Static Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param nSeq, numeric, sequencial a ser impresso na primeira coluna da tabela 3.
@param nLin, numeric, linha onde os dados devem ser impressos.
@param cFardo, caractere, etiqueta do fardo.
@param nPsBrut, numeric, peso bruto do fardo.
@param nTara, numeric, peso bruto - peso liquido do fardo.
@param nPsLiqu, numeric, peso liquido do fardo.
@param cBloco, caractere, bloco do fardo.
@return nLin, numeric, ultima linha disponivel a ser utilizada.
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpDTab3(nSeq, nLin, cFardo, nPsBrut, nTara, nPsLiqu, cBloco)
	
	oReport:nRow := nLin
    
    cFardo := RIGHT(cFardo, 11) 
	oReport:Say(nLin, __nIniT3C1, cValToChar(nSeq),    __oFnt07N) //"SEQ"
	oReport:Say(nLin, __nIniT3C2, AllTrim(cFardo),     __oFnt07C) //"BALE"
	oReport:Say(nLin, __nIniT3C3, cValToChar(nPsBrut), __oFnt07C) //"GROSS WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT3C4, cValToChar(nTara),   __oFnt07C) //"TARE WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT3C5, cValToChar(nPsLiqu), __oFnt07C) //"NET WEIGHT (KGS)"
	oReport:Say(nLin, __nIniT3C6, AllTrim(cBloco),     __oFnt07C) //"LOT"

	oReport:SkipLine(1)
	nLin := oReport:Row()   

Return nLin

/*/{Protheus.doc} fImpRod()
Imprime o rodapé do relatório.
@type  Static Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpRod()
	Local cEnd   := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_END"))
	Local cMun   := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_MUN"))
	Local cEst   := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_EST"))
	Local cCep   := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_CEP"))
	Local cDDD   := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_DDD"))
	Local cFon   := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_TEL"))
	Local cFax   := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_FAX"))
	Local cEmail := AllTrim(Posicione("SA1",3,FwxFilial("SA1")+FwArrFilAtu()[18], "A1_EMAIL"))
	Local cStr   := "" 

	oReport:nRow := oReport:PageHeight( .T. ) - 100

	oReport:PrtCenter( AllTrim(FWCompanyName(cEmpAnt, cFilAnt)) )

	oReport:nRow := oReport:PageHeight( .T. ) - 50

	//endereço. municipio - UF. ##CEP: cep ###" Brazil " ###"Fone " (DDD) telefone ###" Fax " (DDD) fax
	cStr := cEnd + ". " + cMun + " - " + cEst + ". " + "CEP: " + cCep + " Brazil " + "Fone " + "(" + cDDD + ") " + cFon +  " Fax " + "(" + cDDD + ")" + cFax

	oReport:PrtCenter( AllTrim(cStr) )

	oReport:nRow := oReport:PageHeight( .T. )

	oReport:PrtCenter( AllTrim(cEmail) )

Return NIL

/*/{Protheus.doc} fExistFar()
Verifica se existem fardos estufados nos CNT's da IE.
@type  Static Function
@author rafael.kleestadt
@since 19/12/2018
@version 1.0
@param param, param_type, param_descr
@return .f., logycal, true or false.
@example
(examples)
@see (links_or_references)
/*/
Static Function fExistFar()

DbSelectArea("N91")
N91->(DbSetOrder(1)) //N91_FILIAL+N91_CODINE+N91_CONTNR
If N91->(DbSeek(FwxFilial("N91")+N7Q->N7Q_CODINE))
	While N91->(!EOF()) .And. N91->(N91_FILIAL+N91_CODINE) = FwxFilial("N91")+N7Q->N7Q_CODINE

		If N91->N91_QTDFRD > 0
			Return .T.
		EndIf

		N91->(DbSkip())
	EndDo
EndIf

Return .F.
