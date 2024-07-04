#INCLUDE "OGR253.ch"
#include "protheus.ch"
#include "report.ch"

/*/{Protheus.doc} OGR253
//TODO Descrição auto-gerada.
@author rafael.kleestadt
@since 10/04/2017
@version undefined

@type function
/*/
Function OGR253()

	Local oReport
	//Local cNome 	:= 'OGR253' // Nome da Rotina
	Local cPerg 	:= PadR('OGR253',10) // Nome do Pergunte

	Pergunte(cPerg, .T.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author rafael.kleestadt
@since 10/04/2017
@version undefined

@type function
/*/
Static Function ReportDef()

	Local oReport	:= Nil

	oReport := TReport():New("OGR253", STR0001, , {|oReport| PrintReport(oReport)}, STR0001) 
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 08 // Tamanho da fonte

Return oReport

/*/{Protheus.doc} PrintReport
//TODO Descrição auto-gerada.
@author rafael.kleestadt
@since 10/04/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)

	Local aArrayMast	:= OGR253QRY()
	Local aArrayOri	    := {}
	Local aArrayDes	    := {}
	Local nLin 	        := 0
	Local nLinDes       := 0
	Local nPageWidth 	:= 118
	Local cNomeEmp      := ""
	Local cNmFil        := ""
	Local nX            := 0
	Local nY            := 0
	Local dDataRom      := ""
	Local nTotDes       := 0
	Local cEntCont      := ""
	Local cEntContAnt   := ""

	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

	For nX := 1 To Len(aArrayMast)

		dDataRom  := SubStr(aArrayMast[nX][7], 7, 02 ) + "/" + SubStr(aArrayMast[nX][7], 5, 02 ) + "/" + SubStr(aArrayMast[nX][7], 0, 04 )
		cEntCont  := AllTrim(aArrayMast[nX][1] + aArrayMast[nX][3])
		nCodRom   := AllTrim(aArrayMast[nX][6])
		aArrayDes := QryClass(nCodRom, '1')
		aArrayOri := QryClass(nCodRom, '2')

		nLin := oReport:Row()	
		If cEntCont != cEntContAnt
			oReport:SkipLine()
			oReport:PrintText(Replicate("=", nPageWidth), nLin, 10)
			oReport:SkipLine()
			oReport:PrtLeft(STR0002 + ": " + AllTrim(aArrayMast[nX][1]) + " " + STR0004 + ": " + AllTrim(aArrayMast[nX][3]))
			oReport:SkipLine()
			oReport:PrtLeft(STR0010 + ": " + AllTrim(aArrayMast[nX][9]) + " " + STR0009 + ": " + AllTrim(aArrayMast[nX][8]) + " " + STR0006 + ": " + AllTrim(aArrayMast[nX][5]))
			oReport:SkipLine(2)
		Else
			oReport:SkipLine(2)
		EndIf

		cEntContAnt := cEntCont
		nLin := oReport:Row()
		If nLin < 200
			nLin := 200
		ElseIf nLin >= 2830
			oReport:EndPage()
			nLin := 200
		EndIf
		oReport:PrintText( STR0007 , nLin, 10)          //Romaneio
		oReport:PrintText( " | " + STR0008 , nLin, 180) //Data
		oReport:PrintText( " | " + STR0011 , nLin, 450) //Qtd Física
		oReport:PrintText( " | " + STR0012 , nLin, 720) //Pesagem 1
		oReport:PrintText( " | " + STR0013 , nLin, 1000)//Peso liquido
		oReport:PrintText( " | " + STR0020 , nLin, 1280)//TOTAL DESCONTO
		oReport:SkipLine()
		nLin := oReport:Row()
		If nLin < 200
			nLin := 200
		EndIf

		oReport:PrintText( AllTrim(aArrayMast[nX][6]) , nLin, 10)
		oReport:PrintText( " | " + dDataRom  , nLin, 180)
		oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayMast[nX][10],"@E 999,999,999.99")) , nLin, 450)
		oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayMast[nX][11],"@E 999,999,999.99")) , nLin, 720)
		oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayMast[nX][12],"@E 999,999,999.99")) , nLin, 1000)
		oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayMast[nX][13],"@E 999,999,999.99")) , nLin, 1280)

		oReport:SkipLine(2)
		nLin := oReport:Row()
		If nLin < 200
			nLin := 200
		ElseIf nLin >= 2830
			oReport:EndPage()
			nLin := 200
		EndIf

		oReport:PrintText(STR0014, nLin, 10)          //Física
		oReport:PrintText( " | " + STR0015, nLin, 180)//%DESC
		oReport:PrintText( " | " + STR0016, nLin, 315)//PESO BASE
		oReport:PrintText( " | " + STR0017, nLin, 535)//RESULTADO
		oReport:PrintText( " | " + STR0018, nLin, 750)//QT DESCONTO

		If Len(aArrayOri) > 0
			oReport:PrintText( " || " + STR0019, nLin, 1005)//Fiscal
			oReport:PrintText( " | "  + STR0015, nLin, 1256)//%DESC
			oReport:PrintText( " | "  + STR0016, nLin, 1394)//PESO BASE
			oReport:PrintText( " | "  + STR0017, nLin, 1615)//RESULTADO
			oReport:PrintText( " | "  + STR0018, nLin, 1837)//QT DESCONTO
		EndIf

		oReport:SkipLine()

		For nY := 1 To Len(aArrayDes)
			nLinDes := oReport:Row()
			If nLinDes < 200
				nLinDes := 200
			EndIf

			oReport:PrintText(SubStr( AllTrim(aArrayDes[nY][2]), 0, 10 ), nLinDes, 10)
			oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayDes[nY][3],"@E 999,999,999.99")), nLinDes, 180)
			oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayDes[nY][4],"@E 999,999,999.99")), nLinDes, 315)
			oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayDes[nY][5],"@E 999,999,999.99")), nLinDes, 535)
			oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayDes[nY][6],"@E 999,999,999.99")), nLinDes, 750)

			If Len(aArrayOri) > 0
				oReport:PrintText(" || " + SubStr( AllTrim(aArrayOri[nY][2]), 0, 10 ), nLinDes, 1005)
				oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayOri[nY][3],"@E 999,999,999.99")), nLinDes, 1256)
				oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayOri[nY][4],"@E 999,999,999.99")), nLinDes, 1394)
				oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayOri[nY][5],"@E 999,999,999.99")), nLinDes, 1615)
				oReport:PrintText( " | " + AllTrim(TRANSFORM(aArrayOri[nY][6],"@E 999,999,999.99")), nLinDes, 1837)
			EndIf

			oReport:SkipLine()

		Next nY

		nTotDes := 0
		oReport:SkipLine()		
	Next nX

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
	aCabec[3] += Space(9) + STR0021 +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, STR0022 +":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio

Return aCabec


/*/{Protheus.doc} OGR253QRY
//TODO Descrição auto-gerada.
@author rafael.kleestadt
@since 10/04/2017
@version undefined

@type function
/*/
Static Function OGR253QRY()

	Local aArrayMast	:= {}
	Local cAliasNJJ 	:= GetNextAlias()
	Local cQryNJJ  	    := "" 
	Local cTypeDB		:= Upper( TcGetDb() )
    Local cConcat	    := IIf(cTypeDB $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")

	cQryNJJ := " Select Distinct " 
	cQryNJJ += "                 NJ0_LOJENT " + cConcat + "' - '" + cConcat +  "NJ0_NOME AS Entidade,"	
	cQryNJJ += "                 NJJ_LOJENT,"
	cQryNJJ += "                 NJJ_CODCTR,
	cQryNJJ += "                 CASE NJK_TPCLAS "
	cQryNJJ += "                     WHEN '1' THEN '" + STR0014 + "'"
	cQryNJJ += "                     WHEN '2' THEN '" + STR0019 + "'"
	cQryNJJ += "                 END as Classificado,"
	cQryNJJ += "                 CASE NJJ_TIPO"
	cQryNJJ += "                     WHEN '1' THEN 'Entrada por Produção'"
	cQryNJJ += "                     WHEN '2' THEN 'Remessa para Deposito'"
	cQryNJJ += "                     WHEN '3' THEN 'Entrada para Deposito'"
	cQryNJJ += "                     WHEN '4' THEN 'Saida por Venda'"
	cQryNJJ += "                     WHEN '5' THEN 'Entrada por Compra'"
	cQryNJJ += "                     WHEN '6' THEN 'Devolução de Deposito'"
	cQryNJJ += "                     WHEN '7' THEN 'Devolução de Remessa'"
	cQryNJJ += "                     WHEN '8' THEN 'Devolução de Compra'"
	cQryNJJ += "                     WHEN '9' THEN 'Devolução de Venda'"
	cQryNJJ += "                 END as Tipo,"
	cQryNJJ += "                 NJJ_CODROM,"
	cQryNJJ += "                 NJJ_DATA,"
	cQryNJJ += "                 NJU_DESCRI,"
	cQryNJJ += "                 B1_DESC,"
	cQryNJJ += "                 NJJ_PESO3,"
	cQryNJJ += "                 NJJ_PESO1,"
	cQryNJJ += "                 NJJ_PSLIQU,"
	cQryNJJ += "                 NJJ_PSDESC"
	cQryNJJ += " from "+ RetSqlName("NJJ") + " NJJ "
	cQryNJJ += " Inner Join "+ RetSqlName("NJ0") + " NJ0 "
	cQryNJJ += " on NJJ_CODENT = NJ0_CODENT"
	cQryNJJ += " Inner Join "+ RetSqlName("NJR") + " NJR " 
	cQryNJJ += " on NJJ_CODCTR = NJR_CODCTR"
	cQryNJJ += " Inner Join "+ RetSqlName("NJU") + " NJU " 
	cQryNJJ += " on NJJ_CODSAF = NJU_CODSAF"
	cQryNJJ += " Inner Join "+ RetSqlName("SB1") + " SB1 "
	cQryNJJ += " on NJJ_CODPRO = B1_COD"
	cQryNJJ += " Inner Join "+ RetSqlName("NJK") + " NJK "
	cQryNJJ += " on NJJ_CODROM = NJK_CODROM And NJK_TPCLAS = NJR_CLASSP"
	cQryNJJ += " WHERE NJJ.NJJ_CODCTR >= '" + MV_PAR01 + "' And NJJ.NJJ_CODCTR <= '" + MV_PAR02 + "' "
	cQryNJJ += " And NJJ.NJJ_CODENT >= '" + MV_PAR03 + "' And NJJ.NJJ_CODENT <= '" + MV_PAR04 + "' "
	cQryNJJ += " And NJJ.NJJ_CODROM >= '" + MV_PAR05 + "' And NJJ.NJJ_CODROM <= '" + MV_PAR06 + "' "
	cQryNJJ += " And NJJ.NJJ_CODSAF >= '" + MV_PAR07 + "' And NJJ.NJJ_CODSAF <= '" + MV_PAR08 + "' "
	cQryNJJ += " And NJJ.NJJ_CODPRO >= '" + MV_PAR09 + "' And NJJ.NJJ_CODPRO <= '" + MV_PAR10 + "' "
	cQryNJJ += " And NJJ.NJJ_DATA   >= '" + DtoS( MV_PAR11 ) + "' And NJJ.NJJ_DATA    <= '" + DtoS( MV_PAR12 ) + "' "

	If Select(cAliasNJJ) > 0
		(cAliasNJJ)->( dbCloseArea() )
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryNJJ ), cAliasNJJ, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasNJJ)
	dbGoTop()

	While (cAliasNJJ)->(!Eof()) 
		aAdd( aArrayMast, { (cAliasNJJ)->Entidade, (cAliasNJJ)->NJJ_LOJENT, (cAliasNJJ)->NJJ_CODCTR, (cAliasNJJ)->Classificado, ;
		(cAliasNJJ)->Tipo,     (cAliasNJJ)->NJJ_CODROM, (cAliasNJJ)->NJJ_DATA,   (cAliasNJJ)->NJU_DESCRI, ; 
		(cAliasNJJ)->B1_DESC,  (cAliasNJJ)->NJJ_PESO3,  (cAliasNJJ)->NJJ_PESO1,  (cAliasNJJ)->NJJ_PSLIQU, ;
		(cAliasNJJ)->NJJ_PSDESC } )		
		(cAliasNJJ)->(DbSkip())
	EndDo

	(cAliasNJJ)->(DbCloseArea())	
Return aArrayMast

/*/{Protheus.doc} QryClass
//TODO Descrição auto-gerada.
@author rafael.kleestadt
@since 10/04/2017
@version undefined
@param nCodRom, numeric, descricao
@param cClass, characters, descricao
@type function
/*/
Static Function QryClass(nCodRom, cClass)

	Local aItensClas 	:= {}
	Local cAliasClas 	:= GetNextAlias()
	Local cQryClas  	    := "" 

	cQryClas := "select "
	cQryClas += "       NJK_TPCLAS, "
	cQryClas += "       NNH_DESCRI, "
	cQryClas += " 	    NJK_READES, " 
	cQryClas += " 	    NJK_BASDES, " 
	cQryClas += "       NJK_PERDES, " 
	cQryClas += "   	NJK_QTDDES  "
	cQryClas += "from "+ RetSqlName("NJK") + " NJK " 
	cQryClas += "Inner Join "+ RetSqlName("NNH") + " NNH " 
	cQryClas += " on NJK_CODDES = NNH_CODIGO "
	cQryClas += "where NJK_TPCLAS = '" + cClass + "' and NJK_CODROM = '" + nCodRom + "' "

	If Select(cAliasClas) > 0
		(cQryClas)->( dbCloseArea() )
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryClas ), cAliasClas, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasClas)
	dbGoTop()

	While (cAliasClas)->(!Eof()) 

		aAdd( aItensClas, { (cAliasClas)->NJK_TPCLAS, (cAliasClas)->NNH_DESCRI, (cAliasClas)->NJK_READES, ;
		(cAliasClas)->NJK_BASDES, (cAliasClas)->NJK_PERDES, (cAliasClas)->NJK_QTDDES} )	

		(cAliasClas)->(DbSkip())
	EndDo

	(cAliasClas)->(DbCloseArea())

Return aItensClas
