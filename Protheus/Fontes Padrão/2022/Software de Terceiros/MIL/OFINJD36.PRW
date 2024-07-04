//////////////////
// versao 0005  //
//////////////////

#include 'protheus.ch'
#include 'tbiconn.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007723_1"

/*/{Protheus.doc} OFINJD36 "Versão atual DPM"

    Pontos de entrada:
		N/A		
	Parametros:
		N/A

    @author Vinicius Gati
    @since  16/10/2015
/*/
Function OFINJD36()
	Local aRet      := {}
	Local aParamBox := {}
	Local nIdx      := 1
	Local cExt      := ""
	Local aDate
	Local cHtmlPage, oButton, oDlg
	Local aTime

	// MATA297M
	aRet := GetFuncArray("MATA297M",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	// U_IMPXML
	aRet := GetFuncArray("U_IMPXML",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	// OFINJD06 ATÉ OFINJD10
	//
	// OFINJD12, OFINJD14, OFINJD19, OFINJD22, OFINJD24, OFINJD25, OFINJD27, OFINJD28
	//
	// OFINJD30 ATÉ OFINJD36
	//
	// OFINJD44, OFINJD45
	aRet := GetFuncArray("OFINJD06",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD07",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD08",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD09",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD10",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD12",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD14",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD19",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD22",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD24",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD25",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD27",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD28",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD30",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD31",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD32",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD33",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD34",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD35",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD36",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD44",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	aRet := GetFuncArray("OFINJD45",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	// U_UPDOFIN9
	aRet := GetFuncArray("U_UPDOFIN9",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)

	// VEICLS*
	aRet := GetFuncArray("VEICLS*",,,, aDate, aTime)
	cExt += RetExt(aRet, aDate, aTime)


	If GetVersao(.f.) $ "12"
		cHtmlPage := 'http://www.itmil.com.br/versao12.php?extrato=' + cExt
	Else
		cHtmlPage := 'http://www.itmil.com.br/versao.php?extrato=' + cExt
	EndIf


	DEFINE MSDIALOG oDlg FROM 0,0 TO 650,1000 PIXEL TITLE 'Extrato de versão - DPM John Deere'

	oTIBrowser := TWebEngine():New(oDlg, 0, 0, 500, 300, cHtmlPage)

	oButton := TButton():New(310, 0070, 'OK', oDlg, { || oDlg:End(), lContinue := .T. }, 40, 10,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED
Return NIL

/*/{Protheus.doc} RetExt

    @author Vinicius Gati
    @since  16/10/2015
/*/
Static Function RetExt(aArqs, aDates, aTimes)
	Local nIdx := 1
	Local cExt := ""

	For nIdx := 1 to LEN(aArqs)
		cExt += aArqs[nIdx] + ";" + DtoS(aDates[nIdx]) + "|"
	Next
Return cExt