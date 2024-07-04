#INCLUDE "plstiss.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#include 'fileio.ch'

#define cPicCNES	PesqPict("BB8","BB8_CNES")
#define __aCdCri049 {"020","O valor contratato e diferente do valor informado/apresentado."}
#define lSrvUnix IsSrvUnix()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS1  ³ Autor ³ Luciano Aparecido     ³ Data ³ 08.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia de Consulta ) -BOPS 095189   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela 	   ³±±
±±³          ³			 de configuracao/preview do relatorio 	           ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³    	 	 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTISS1(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW)

Local nLinMax		:= 0
Local nColMax		:= 0
Local nLinIni		:= 0		// Linha Lateral (inicial) Esquerda
Local nColIni		:= 0		// Coluna Lateral (inicial) Esquerda
Local nColA4    	:= 0      // Para implementar layout A4
Local nLinA4    	:= 0      // Para implementar layout A4
Local cFileLogo		:= ""
Local nLin			:= 0
Local nI, nX		:= 0
Local cObs			:= ""
Local oFont01		:= nil
Local oFont02n		:= nil
Local oFont03n		:= nil
Local oFont04		:= nil
Local oFont05		:= nil
Local oPrint    	:= Nil
LOCAL cFileName		:= ""
LOCAL cRel			:= "guicons"
LOCAL cPathSrvJ 	:= GETMV("MV_RELT")
LOCAL nAL			:= 0.25
LOCAL nAC			:= 0.24
LOCAL cTissVer  	:= PLSTISSVER()
local nVlrApG		:= 0

DEFAULT lGerTXT 	:= .F.
DEFAULT nLayout 	:= 2
DEFAULT cLogoGH 	:= ""
DEFAULT lWeb		:= .F.
DEFAULT cPathRelW 	:= ""
DEFAULT aDados := { {;
	"123456",;
	"12345678901234567892",;
	CtoD("01/01/07"),;
	"12345678901234567892",;
	Replicate("M",40),;
	CtoD("12/12/07"),;
	Replicate("M",70),;
	"123456789102345",;
	"14.141.114/00001-35",;
	Replicate("M",70),;
	"1234567",;
	"123",;
	Replicate("M",40),;
	"12345",;
	Replicate("M",15),;
	Replicate("M",40),;
	"ES",;
	"1234567",;
	"29800-000",;
	Replicate("M",70),;
	"MMMMMMM",;
	"123456789102345",;
	"ES",;
	"12345",;
	"M",;
	{ 12,"M" },;
	"0",;
	"12345",;
	"23456",;
	"34567",;
	"45678",;
	CtoD("12/12/06"),;
	"12",;
	"1234567890",;
	"1",;
	"1",;
	Replicate("M", 240),;
	CtoD("12/12/12"),;
	CtoD("12/12/12") } }

oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

	//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
If !lWeb
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
Else
	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:lServer := lWeb

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Modo retrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:SetPortrait()

If nLayout ==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Papél A4
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(9)
ElseIf nLayout ==3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Papél Carta
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(1)
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(14)
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lWeb
	oPrint:setDevice(IMP_PDF)
		//oPrint:lPDFAsPNG := .T.
EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If  !lWeb
	oPrint:Setup()
	If !(oPrint:nModalResult == 1)
		Return
	Endif
EndIf

If oPrint:nPaperSize  == 9 // Papél A4
	nLinMax	:= 1754
	nColMax	:= 2335
	nLayout 	:= 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 05, 05, , .F., , , , .T., .F.) // Normal
Elseif oPrint:nPaperSize == 1 // Papel Carta
	nLinMax	:= 1545
	nColMax	:= 2400
	nLayout 	:= 3
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 05, 05, , .F., , , , .T., .F.) // Normal
Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	nLinMax	:= 1764
	nColMax	:= 2400
	nLayout 	:= 1
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04	:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	oFont05	:= TFont():New("Arial", 05, 05, , .F., , , , .T., .F.) // Normal
Endif

If (cTissVer <"4.00.01" )
	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		If oPrint:Cprinter == "PDF" .OR. lWeb
			nLinIni	:= 150
		Else
			nLinIni := 100
		Endif
		nColIni := 065
		nLinA4  := 000
		nColA4  := 000

		oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) // Tem que estar abaixo do RootPath
		EndIf

		if nLayout == 2 // Papél A4
			nColA4:= -0065
			nLinA4:= 0
		Endif

		oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1000 + nColA4)*nAC, STR0001, oFont02n,,,, 2) //"GUIA DE CONSULTA"
		oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1700 + nColA4)*nAC, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1801 + nColA4)*nAC, aDados[nX, 02], oFont03n)

		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0249)*nAL + nLinA4, (nColIni + 0415)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0030)*nAC, aDados[nX, 01], oFont04)
		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0420)*nAC, (nLinIni + 0249)*nAL + nLinA4, (nColIni + 0830)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0430)*nAC, "3 - "+STR0004, oFont01) //"Data de Emissão da Guia"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0440)*nAC, DtoC(aDados[nX, 03]), oFont04)

		oPrint:Say((nLinIni + 0274 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0005, oFont01) //"Dados do Beneficiário"
		oPrint:Box((nLinIni + 0284)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0378)*nAL + (2*nLinA4), (nColIni + 0585)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0020)*nAC, "4 - "+STR0006, oFont01) //"Número da Carteira"
		oPrint:Say((nLinIni + 0349 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 04], oFont04)
		oPrint:Box((nLinIni + 0284)*nAL + nLinA4, (nColIni + 0590)*nAC, (nLinIni + 0378)*nAL + (2*nLinA4), (nColIni + 2112 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0600)*nAC, "5 - "+STR0007, oFont01) //"Plano"
		oPrint:Say((nLinIni + 0349 + nLinA4)*nAL, (nColIni + 0610)*nAC, aDados[nX, 05], oFont04)
		oPrint:Box((nLinIni + 0284)*nAL + nLinA4, (nColIni + 2117)*nAC + nColA4, (nLinIni + 0378)*nAL + (2*nLinA4), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 2127 + nColA4)*nAC, "6 - "+STR0008, oFont01) //"Validade da Carteira"
		oPrint:Say((nLinIni + 0349 + nLinA4)*nAL, (nColIni + 2137 + nColA4)*nAC, DtoC(aDados[nX, 06]), oFont04)

		oPrint:Box((nLinIni + 0383)*nAL + (2*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0477)*nAL + (3*nLinA4), (nColIni + 1965 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0408 + (2*nLinA4))*nAL, (nColIni + 0020)*nAC, "7 - "+STR0009, oFont01) //"Nome"
		oPrint:Say((nLinIni + 0448 + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, aDados[nX, 07], oFont04)
		oPrint:Box((nLinIni + 0383)*nAL + (2*nLinA4), (nColIni + 1970 + nColA4)*nAC, (nLinIni + 0477)*nAL + (3*nLinA4), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0408 + (2*nLinA4))*nAL, (nColIni + 1980 + nColA4)*nAC, "8 - "+STR0010, oFont01) //"Número do Cartão Nacional de Saúde"
		oPrint:Say((nLinIni + 0448 + (2*nLinA4))*nAL, (nColIni + 1990 + nColA4)*nAC, aDados[nX, 08], oFont04)

		oPrint:Say((nLinIni + 0502 + (3*nLinA4))*nAL, (nColIni + 0010)*nAC, STR0011, oFont01) //"Dados do Contratado"
		oPrint:Box((nLinIni + 0512)*nAL + (3*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0606)*nAL + (4*nLinA4), (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 0537 + (3*nLinA4))*nAL, (nColIni + 0020)*nAC, "9 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say((nLinIni + 0577 + (3*nLinA4))*nAL, (nColIni + 0030)*nAC, aDados[nX, 09], oFont04)
		oPrint:Box((nLinIni + 0512)*nAL + (3*nLinA4), (nColIni + 0431)*nAC, (nLinIni + 0606)*nAL + (4*nLinA4), (nColIni + 2165 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0537 + (3*nLinA4))*nAL, (nColIni + 0441)*nAC, "10 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say((nLinIni + 0577 + (3*nLinA4))*nAL, (nColIni + 0451)*nAC, SubStr(aDados[nX, 10], 1, 65), oFont04)
		oPrint:Box((nLinIni + 0512)*nAL + (3*nLinA4), (nColIni + 2170 + nColA4)*nAC, (nLinIni + 0606)*nAL + (4*nLinA4), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0537 + (3*nLinA4))*nAL, (nColIni + 2180 + nColA4)*nAC, "11 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 0577 + (3*nLinA4))*nAL, (nColIni + 2190 + nColA4)*nAC, aDados[nX, 11], oFont04)

		oPrint:Box((nLinIni + 0611)*nAL + (4*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0705)*nAL + (5*nLinA4), (nColIni + 0132)*nAC)
		oPrint:Say((nLinIni + 0636 + (4*nLinA4))*nAL, (nColIni + 0020)*nAC, "12 - "+STR0015, oFont01) //"T.L."
		oPrint:Say((nLinIni + 0676 + (4*nLinA4))*nAL, (nColIni + 0030)*nAC, aDados[nX, 12], oFont04)
		oPrint:Box((nLinIni + 0611)*nAL + (4*nLinA4), (nColIni + 0137)*nAC, (nLinIni + 0705)*nAL + (5*nLinA4), (nColIni + 1050 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636 + (4*nLinA4))*nAL, (nColIni + 0147)*nAC, "13-14-15 - "+STR0016, oFont01) //"Logradouro - Número - Complemento"
		oPrint:Say((nLinIni + 0676 + (4*nLinA4))*nAL, (nColIni + 0157)*nAC, SubStr(AllTrim(aDados[nX, 13]) + IIf(!Empty(aDados[nX, 14]), ", ","") + AllTrim(aDados[nX, 14]) + IIf(!Empty(aDados[nX, 15]), " - ","") + AllTrim(aDados[nX, 15]), 1, 34), oFont04)
		oPrint:Box((nLinIni + 0611)*nAL + (4*nLinA4), (nColIni + 1055 + nColA4)*nAC, (nLinIni + 0705)*nAL + (5*nLinA4), (nColIni + 1830 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636 + (4*nLinA4))*nAL, (nColIni + 1065 + nColA4)*nAC, "16 - "+STR0017, oFont01) //"Município"
		oPrint:Say((nLinIni + 0676 + (4*nLinA4))*nAL, (nColIni + 1075 + nColA4)*nAC, SubStr(aDados[nX, 16], 1, 29), oFont04)
		oPrint:Box((nLinIni + 0611)*nAL + (4*nLinA4), (nColIni + 1835 + nColA4)*nAC, (nLinIni + 0705)*nAL + (5*nLinA4), (nColIni + 1940 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636 + (4*nLinA4))*nAL, (nColIni + 1845 + nColA4)*nAC, "17 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 0676 + (4*nLinA4))*nAL, (nColIni + 1860 + nColA4)*nAC, aDados[nX, 17], oFont04)
		oPrint:Box((nLinIni + 0611)*nAL + (4*nLinA4), (nColIni + 1945 + nColA4)*nAC, (nLinIni + 0705)*nAL + (5*nLinA4), (nColIni + 2165 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636 + (4*nLinA4))*nAL, (nColIni + 1955 + nColA4)*nAC, "18 - "+STR0019, oFont01) //"Código IBGE"
		oPrint:Say((nLinIni + 0676 + (4*nLinA4))*nAL, (nColIni + 1965 + nColA4)*nAC, aDados[nX, 18], oFont04)
		oPrint:Box((nLinIni + 0611)*nAL + (4*nLinA4), (nColIni + 2170 + nColA4)*nAC, (nLinIni + 0705)*nAL + (5*nLinA4), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636 + (4*nLinA4))*nAL, (nColIni + 2180 + nColA4)*nAC, "19 - "+STR0020, oFont01) //"CEP"
		oPrint:Say((nLinIni + 0676 + (4*nLinA4))*nAL, (nColIni + 2190 + nColA4)*nAC, aDados[nX, 19], oFont04)

		oPrint:Box((nLinIni + 0710)*nAL + (5*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0804)*nAL + (6*nLinA4), (nColIni + 1455 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0735 + (5*nLinA4))*nAL, (nColIni + 0020)*nAC, "20 - "+STR0021, oFont01) //"Nome do Profissional Executante"
		oPrint:Say((nLinIni + 0775 + (5*nLinA4))*nAL, (nColIni + 0030)*nAC, SubStr(aDados[nX, 20], 1, 54), oFont04)
		oPrint:Box((nLinIni + 0710)*nAL + (5*nLinA4), (nColIni + 1460 + nColA4)*nAC, (nLinIni + 0804)*nAL + (6*nLinA4), (nColIni + 1735 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0735 + (5*nLinA4))*nAL, (nColIni + 1470 + nColA4)*nAC, "21 - "+STR0022, oFont01) //"Conselho Profissional"
		oPrint:Say((nLinIni + 0775 + (5*nLinA4))*nAL, (nColIni + 1480 + nColA4)*nAC, aDados[nX, 21], oFont04)
		oPrint:Box((nLinIni + 0710)*nAL + (5*nLinA4), (nColIni + 1740 + nColA4)*nAC, (nLinIni + 0804)*nAL + (6*nLinA4), (nColIni + 2065 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0735 + (5*nLinA4))*nAL, (nColIni + 1750 + nColA4)*nAC, "22 - "+STR0023, oFont01) //"Número no Conselho"
		oPrint:Say((nLinIni + 0775 + (5*nLinA4))*nAL, (nColIni + 1760 + nColA4)*nAC, aDados[nX, 22], oFont04)
		oPrint:Box((nLinIni + 0710)*nAL + (5*nLinA4), (nColIni + 2070 + nColA4)*nAC, (nLinIni + 0804)*nAL + (6*nLinA4), (nColIni + 2165 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0735 + (5*nLinA4))*nAL, (nColIni + 2080 + nColA4)*nAC, "23 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 0775 + (5*nLinA4))*nAL, (nColIni + 2090 + nColA4)*nAC, aDados[nX, 23], oFont04)
		oPrint:Box((nLinIni + 0710)*nAL + (5*nLinA4), (nColIni + 2170 + nColA4)*nAC, (nLinIni + 0804)*nAL + (6*nLinA4), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0735 + (5*nLinA4))*nAL, (nColIni + 2180 + nColA4)*nAC, "24 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say((nLinIni + 0775 + (5*nLinA4))*nAL, (nColIni + 2190 + nColA4)*nAC, aDados[nX, 24], oFont04)

		oPrint:Say((nLinIni  + 0829 + (6*nLinA4))*nAL, (nColIni + 0010)*nAC, STR0025, oFont01) //"Hipóteses Diagnósticas"
		oPrint:Box((nLinIni  + 0839)*nAL + (6*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0933)*nAL + (7*nLinA4), (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni  + 0864 + (6*nLinA4))*nAL, (nColIni + 0020)*nAC, "25 - "+STR0026, oFont01) //"Tipo de Doença"
		oPrint:Line((nLinIni + 0874)*nAL + (6*nLinA4), (nColIni + 0030)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0030)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0077)*nAC)
		oPrint:Line((nLinIni + 0874)*nAL + (6*nLinA4), (nColIni + 0077)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0077)*nAC)
		oPrint:Say((nLinIni  + 0904 + (6*nLinA4))*nAL, (nColIni + 0043)*nAC, aDados[nX, 25], oFont04)
		oPrint:Say((nLinIni  + 0904 + (6*nLinA4))*nAL, (nColIni + 0090)*nAC, STR0027+"    "+STR0028, oFont01)  //"A-Aguda"###"C-Crônica"
		oPrint:Box((nLinIni  + 0839)*nAL + (6*nLinA4), (nColIni + 0320)*nAC, (nLinIni + 0933)*nAL + (7*nLinA4), (nColIni + 0765)*nAC)
		oPrint:Say((nLinIni  + 0864 + (6*nLinA4))*nAL, (nColIni + 0330)*nAC, "26 - "+STR0029, oFont01) //"Tempo de Doença"
		oPrint:Line((nLinIni + 0874)*nAL + (6*nLinA4), (nColIni + 0340)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0340)*nAC)
		oPrint:Line((nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0340)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0426)*nAC)
		oPrint:Line((nLinIni + 0874)*nAL + (6*nLinA4), (nColIni + 0426)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni  + 0904 + (6*nLinA4))*nAL, (nColIni + 0353)*nAC, IIF((StrZero(aDados[nX, 26,1], 2, 0))=="00","",(StrZero(aDados[nX, 26,1], 2, 0))), oFont04)
		oPrint:Say((nLinIni  + 0899 + (6*nLinA4))*nAL, (nColIni + 0434)*nAC, "-", oFont01)
		oPrint:Line((nLinIni + 0874)*nAL + (6*nLinA4), (nColIni + 0447)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0447)*nAC)
		oPrint:Line((nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0447)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0494)*nAC)
		oPrint:Line((nLinIni + 0874)*nAL + (6*nLinA4), (nColIni + 0494)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0494)*nAC)
		oPrint:Say((nLinIni  + 0904 + (6*nLinA4))*nAL, (nColIni + 0457)*nAC, aDados[nX, 26,2], oFont04)
		oPrint:Say((nLinIni  + 0904 + (6*nLinA4))*nAL, (nColIni + 0510)*nAC, STR0030+"  "+STR0031+"  "+STR0032, oFont01) //"A-Anos"###"M-Meses"###"D-Dias"
		oPrint:Box((nLinIni + 0839)*nAL  + (6*nLinA4), (nColIni + 0770)*nAC, (nLinIni + 0933)*nAL + (7*nLinA4), (nColIni + 1807)*nAC)
		oPrint:Say((nLinIni + 0864  + (6*nLinA4))*nAL, (nColIni + 0780)*nAC, "27 - "+STR0033, oFont01) //"Indicação de Acidente"
		oPrint:Line((nLinIni+ 0869)*nAL  + (6*nLinA4), (nColIni + 0790)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0790)*nAC)
		oPrint:Line((nLinIni+ 0921)*nAL  + (7*nLinA4), (nColIni + 0790)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0832)*nAC)
		oPrint:Line((nLinIni+ 0869)*nAL  + (6*nLinA4), (nColIni + 0832)*nAC, (nLinIni + 0921)*nAL + (7*nLinA4), (nColIni + 0832)*nAC)
		oPrint:Say((nLinIni + 0904  + (6*nLinA4))*nAL, (nColIni + 0803)*nAC, aDados[nX, 27], oFont04)
		oPrint:Say((nLinIni + 0904  + (6*nLinA4))*nAL, (nColIni + 0850)*nAC, "0 - "+STR0034+"     "+"1 - "+STR0035+"     "+"2 - "+STR0036, oFont01) //"Acidente ou doença relacionado ao trabalho"###"Trânsito"###"Outros"

		oPrint:Box((nLinIni + 0938)*nAL + (7*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 1032)*nAL + (8*nLinA4), (nColIni + 0285)*nAC)
		oPrint:Say((nLinIni + 0963 + (7*nLinA4))*nAL, (nColIni + 0020)*nAC, "28 - "+STR0037, oFont01) //"CID Principal"
		oPrint:Say((nLinIni + 1003 + (7*nLinA4))*nAL, (nColIni + 0030)*nAC, aDados[nX, 28], oFont04)
		oPrint:Box((nLinIni + 0938)*nAL + (7*nLinA4), (nColIni + 0290)*nAC, (nLinIni + 1032)*nAL + (8*nLinA4), (nColIni + 0565)*nAC)
		oPrint:Say((nLinIni + 0963 + (7*nLinA4))*nAL, (nColIni + 0300)*nAC, "29 - "+STR0038, oFont01) //"CID (2)"
		oPrint:Say((nLinIni + 1003 + (7*nLinA4))*nAL, (nColIni + 0310)*nAC, aDados[nX, 29], oFont04)
		oPrint:Box((nLinIni + 0938)*nAL + (7*nLinA4), (nColIni + 0570)*nAC, (nLinIni + 1032)*nAL + (8*nLinA4), (nColIni + 0845)*nAC)
		oPrint:Say((nLinIni + 0963 + (7*nLinA4))*nAL, (nColIni + 0580)*nAC, "30 - "+STR0039, oFont01) //"CID (3)"
		oPrint:Say((nLinIni + 1003 + (7*nLinA4))*nAL, (nColIni + 0590)*nAC, aDados[nX, 30], oFont04)
		oPrint:Box((nLinIni + 0938)*nAL + (7*nLinA4), (nColIni + 0850)*nAC, (nLinIni + 1032)*nAL + (8*nLinA4), (nColIni + 1115)*nAC)
		oPrint:Say((nLinIni + 0963 + (7*nLinA4))*nAL, (nColIni + 0860)*nAC, "31 - "+STR0040, oFont01) //"CID (4)"
		oPrint:Say((nLinIni + 1003 + (7*nLinA4))*nAL, (nColIni + 0870)*nAC, aDados[nX, 31], oFont04)

		oPrint:Say((nLinIni + 1057 + (8*nLinA4))*nAL, (nColIni + 0010)*nAC, STR0041+" / "+STR0042, oFont01) //"Dados do Atendimento"###"Procedimento Realizado"
		oPrint:Box((nLinIni + 1067)*nAL + (8*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 1161)*nAL + (9*nLinA4), (nColIni + 0305)*nAC)
		oPrint:Say((nLinIni + 1092 + (8*nLinA4))*nAL, (nColIni + 0020)*nAC, "32 - "+STR0043, oFont01) //"Data do Atendimento"
		oPrint:Say((nLinIni + 1132 + (8*nLinA4))*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 32]), oFont04)
		oPrint:Box((nLinIni + 1067)*nAL + (8*nLinA4), (nColIni + 0310)*nAC, (nLinIni + 1161)*nAL + (9*nLinA4), (nColIni + 0565)*nAC)
		oPrint:Say((nLinIni + 1092 + (8*nLinA4))*nAL, (nColIni + 0320)*nAC, "33 - "+STR0044, oFont01) //"Código Tabela"
		oPrint:Say((nLinIni + 1132 + (8*nLinA4))*nAL, (nColIni + 0330)*nAC, aDados[nX, 33], oFont04)
		oPrint:Box((nLinIni + 1067)*nAL + (8*nLinA4), (nColIni + 0570)*nAC, (nLinIni + 1161)*nAL + (9*nLinA4), (nColIni + 0900)*nAC)
		oPrint:Say((nLinIni + 1092 + (8*nLinA4))*nAL, (nColIni + 0580)*nAC, "34 - "+STR0045, oFont01) //"Código Procedimento"
		oPrint:Say((nLinIni + 1132 + (8*nLinA4))*nAL, (nColIni + 0590)*nAC, aDados[nX, 34], oFont04)

		oPrint:Box((nLinIni + 1166)*nAL  + (9*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 1260)*nAL + (10*nLinA4), (nColIni + 0505)*nAC)
		oPrint:Say((nLinIni + 1191  + (9*nLinA4))*nAL, (nColIni + 0020)*nAC, "35 - "+STR0046, oFont01) //"Tipo de Consulta"
		oPrint:Line((nLinIni + 1206)*nAL + (9*nLinA4), (nColIni + 0030)*nAC, (nLinIni + 1253)*nAL + (10*nLinA4), (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni + 1253)*nAL +(10*nLinA4), (nColIni + 0030)*nAC, (nLinIni + 1253)*nAL + (10*nLinA4), (nColIni + 0077)*nAC)
		oPrint:Line((nLinIni + 1206)*nAL + (9*nLinA4), (nColIni + 0077)*nAC, (nLinIni + 1253)*nAL + (10*nLinA4), (nColIni + 0077)*nAC)
		oPrint:Say((nLinIni + 1231  + (9*nLinA4))*nAL, (nColIni + 0043)*nAC, aDados[nX, 35], oFont04)
		oPrint:Say((nLinIni + 1231  + (9*nLinA4))*nAL, (nColIni + 0090)*nAC, "1-"+STR0047+"   "+"2-"+STR0048+"   "+"3-"+STR0049, oFont01) //"Primeira"###"Seguimento"###"Pré-Natal"
		oPrint:Box((nLinIni + 1166)*nAL  + (9*nLinA4), (nColIni + 0510)*nAC, (nLinIni + 1260)*nAL + (10*nLinA4), (nColIni + 1250)*nAC)
		oPrint:Say((nLinIni + 1191  + (9*nLinA4))*nAL, (nColIni + 0520)*nAC, "36 - "+STR0050, oFont01) //"Tipo de Saída"
		oPrint:Line((nLinIni + 1206)*nAL + (9*nLinA4), (nColIni + 0530)*nAC, (nLinIni + 1253)*nAL + (10*nLinA4), (nColIni + 0530)*nAC)
		oPrint:Line((nLinIni + 1253)*nAL +(10*nLinA4), (nColIni + 0530)*nAC, (nLinIni + 1253)*nAL + (10*nLinA4), (nColIni + 0577)*nAC)
		oPrint:Line((nLinIni + 1206)*nAL + (9*nLinA4), (nColIni + 0577)*nAC, (nLinIni + 1253)*nAL + (10*nLinA4), (nColIni + 0577)*nAC)
		oPrint:Say((nLinIni + 1231  + (9*nLinA4))*nAL, (nColIni + 0543)*nAC, aDados[nX, 36], oFont04)
		oPrint:Say((nLinIni + 1231  + (9*nLinA4))*nAL, (nColIni + 0590)*nAC, "1-"+STR0051+"   "+"2-"+STR0052+"   "+"3-"+STR0053+"   "+"4-"+STR0054+"   "+"5-"+STR0055, oFont01) //"Retorno"###"Retorno SADT"###"Referência"###"Internação"###"Alta"

		oPrint:Box((nLinIni + 1265)*nAL + (10*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 1557)*nAL + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1290 + (10*nLinA4))*nAL, (nColIni + 0020)*nAC, "37 - "+STR0056, oFont01) //"Observação"
		nLin := 1335

		For nI := 1 To MlCount(aDados[nX, 37], 80)
			cObs := MemoLine(aDados[nX, 37], 80, nI)
			oPrint:Say((nLinIni + nLin + (10*nLinA4))*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
			nLin += 35
		Next nI

		oPrint:Box((nLinIni + 1562)*nAL + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)), (nColIni + 0010)*nAC, (nLinIni + 1734)*nAL + IIf(nLayout ==2,(14*nLinA4),(22*nLinA4)), (nColIni + 1185 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1587 + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)))*nAL, (nColIni + 0020)*nAC, "38 - "+STR0057, oFont01) //"Data e Assinatura do Profissional"
		oPrint:Say((nLinIni + 1627 + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)))*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 38]), oFont04)
		oPrint:Box((nLinIni + 1562)*nAL + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)), (nColIni + 1190 + nColA4)*nAC, (nLinIni + 1734)*nAL + IIf(nLayout ==2,(14*nLinA4),(22*nLinA4)), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1587 + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)))*nAL, (nColIni + 1200 + nColA4)*nAC, "39 - "+STR0058, oFont01) //"Data e Assinatura do Beneficiário ou Responsável"
		oPrint:Say((nLinIni + 1627 + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)))*nAL, (nColIni + 1210 + nColA4)*nAC, DtoC(aDados[nX, 39]), oFont04)

		oPrint:EndPage()	// Finaliza a pagina

	Next nX
Else

	// TISS 4.00.01

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		IIf ((oPrint:Cprinter == "PDF" .OR. lWeb),nLinIni	:= 150,nLinIni := 100)

		nColIni := 065
		nLinA4  := 000
		nColA4  := 000

		oPrint:StartPage()		// Inicia uma nova pagina.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If (File(cFilelogo),	oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC),)

		if nLayout == 2 // Papél A4
			nColA4:= -0065
			nLinA4:= 0
		Endif

		oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1000 + nColA4)*nAC, STR0001, oFont02n,,,, 2) //"GUIA DE CONSULTA"
		oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1700 + nColA4)*nAC, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1801 + nColA4)*nAC, aDados[nX, 02], oFont03n)

		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0249)*nAL + nLinA4, (nColIni + 0415)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0030)*nAC, aDados[nX, 01], oFont04)

		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0420)*nAC, (nLinIni + 0249)*nAL + nLinA4, (nColIni + 0930)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0430)*nAC, "3 - Numero da Guia Atribuído pela Operadora", oFont01) //"3 - Numero da Guia Atribuído pela Operadora"         
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0440)*nAC, aDados[nX, 03], oFont04)

		oPrint:Say((nLinIni + 0274 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0005, oFont01) //"Dados do Beneficiário"
		oPrint:Box((nLinIni + 0284)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0378)*nAL + (2*nLinA4), (nColIni + 0585)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0020)*nAC, "4 - "+STR0006, oFont01) //"Número da Carteira"
		oPrint:Say((nLinIni + 0349 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 04], oFont04)
		
		oPrint:Box((nLinIni + 0284)*nAL + nLinA4, (nColIni + 0590)*nAC, (nLinIni + 0378)*nAL + (2*nLinA4), (nColIni + 1200 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0600)*nAC, "5 - "+STR0008, oFont01) //"Validade da Carteira"
		oPrint:Say((nLinIni + 0349 + nLinA4)*nAL, (nColIni + 0610)*nAC, DtoC(aDados[nX, 05]), oFont04)
		
		oPrint:Box((nLinIni + 0284)*nAL + nLinA4, (nColIni + 1205)*nAC + nColA4, (nLinIni + 0378)*nAL + (2*nLinA4), (nColIni + 1900 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 1215 + nColA4)*nAC, "6 – Atendimento a RN (Sim ou Não) ", oFont01) //"6 – Atendimento a RN (Sim ou Não) "
		oPrint:Say((nLinIni + 0349 + nLinA4)*nAL, (nColIni + 1425 + nColA4)*nAC, aDados[nX, 06], oFont04)
		
		If BA1->( FieldPos("BA1_NOMSOC") ) > 0		
			oPrint:Box((nLinIni + 0383)*nAL + (2*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0477)*nAL + (3*nLinA4), (nColIni + 1900 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0408 + (2*nLinA4))*nAL, (nColIni + 0020)*nAC, "26 – Nome Social", oFont01) //"26 – Nome Social"
			oPrint:Say((nLinIni + 0448 + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, aDados[nX, 26], oFont04)
		Endif


		oPrint:Box((nLinIni + 0482)*nAL + (2*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0577)*nAL + (3*nLinA4), (nColIni + 1900 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0503 + (2*nLinA4))*nAL, (nColIni + 0020)*nAC, "7 - "+STR0009, oFont01) //"Nome"
		oPrint:Say((nLinIni + 0548 + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, aDados[nX, 07], oFont04)


		oPrint:Say((nLinIni + 0605 + (3*nLinA4))*nAL, (nColIni + 0010)*nAC, STR0011, oFont01) //"Dados do Contratado"

		oPrint:Box((nLinIni + 0615)*nAL + (3*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0706)*nAL + (4*nLinA4), (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 0640 + (3*nLinA4))*nAL, (nColIni + 0020)*nAC, "9 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say((nLinIni + 0685 + (3*nLinA4))*nAL, (nColIni + 0030)*nAC, aDados[nX, 09], oFont04)
		
		oPrint:Box((nLinIni + 0615)*nAL + (3*nLinA4), (nColIni + 0431)*nAC, (nLinIni + 0706)*nAL + (4*nLinA4), (nColIni + 2065 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0640 + (3*nLinA4))*nAL, (nColIni + 0441)*nAC, "10 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say((nLinIni + 0685 + (3*nLinA4))*nAL, (nColIni + 0451)*nAC, SubStr(aDados[nX, 10], 1, 65), oFont04)

		oPrint:Box((nLinIni + 0615)*nAL + (3*nLinA4), (nColIni + 2070 + nColA4)*nAC, (nLinIni + 0706)*nAL + (4*nLinA4), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0640 + (3*nLinA4))*nAL, (nColIni + 2080 + nColA4)*nAC, "11 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 0685 + (3*nLinA4))*nAL, (nColIni + 2090 + nColA4)*nAC, aDados[nX, 11], oFont04)

		oPrint:Box((nLinIni + 0710)*nAL + (4*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0800)*nAL + (5*nLinA4), (nColIni + 1100)*nAC)
		oPrint:Say((nLinIni + 0747 + (4*nLinA4))*nAL, (nColIni + 0020)*nAC, "12 - "+STR0021, oFont01) //"12 - Nome do Profissional Executante "
		oPrint:Say((nLinIni + 0794 + (4*nLinA4))*nAL, (nColIni + 0030)*nAC, Iif(Valtype(aDados[nX, 12])=="C",aDados[nX, 12],''), oFont04) // Para os casos de consula que não tem executante preenchido


		oPrint:Box((nLinIni + 0710)*nAL + (4*nLinA4), (nColIni + 01105)*nAC, (nLinIni + 0800)*nAL + (5*nLinA4), (nColIni + 1500 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0747 + (4*nLinA4))*nAL, (nColIni + 01110)*nAC, "13-"+STR0022, oFont01) //""Conselho Profissional""
		oPrint:Say((nLinIni + 0794 + (4*nLinA4))*nAL, (nColIni + 01115)*nAC, Iif(Valtype(aDados[nX, 13])=="C",aDados[nX, 13],'') , oFont04)

		oPrint:Box((nLinIni + 0710)*nAL + (4*nLinA4), (nColIni + 01505)*nAC, (nLinIni + 0800)*nAL + (5*nLinA4), (nColIni + 2000 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0747 + (4*nLinA4))*nAL, (nColIni + 01515)*nAC, "14-"+STR0023, oFont01) //"14-Número no Conselho"
		oPrint:Say((nLinIni + 0794 + (4*nLinA4))*nAL, (nColIni + 01525)*nAC, Iif(Valtype(aDados[nX, 14])=="C",aDados[nX, 14],'') , oFont04)


		oPrint:Box((nLinIni + 0710)*nAL + (4*nLinA4), (nColIni + 2005 + nColA4)*nAC, (nLinIni + 0800)*nAL + (5*nLinA4), (nColIni + 2385 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0735 + (4*nLinA4))*nAL, (nColIni + 2015 + nColA4)*nAC, "15 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 0775 + (4*nLinA4))*nAL, (nColIni + 2025 + nColA4)*nAC, Iif(Valtype(aDados[nX, 15])=="C",aDados[nX, 15],''), oFont04)

		
		oPrint:Box((nLinIni + 0710)*nAL + (4*nLinA4), (nColIni + 2175 + nColA4)*nAC, (nLinIni + 0800)*nAL + (5*nLinA4), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0747 + (4*nLinA4))*nAL, (nColIni + 2185 + nColA4)*nAC, "16 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say((nLinIni + 0794 + (4*nLinA4))*nAL, (nColIni + 2195 + nColA4)*nAC, Iif(Valtype(aDados[nX, 16])=="C",aDados[nX, 16],''), oFont04)

		oPrint:Say((nLinIni + 0829 + (5*nLinA4))*nAL, (nColIni + 0010)*nAC, STR0041+" / "+STR0042, oFont01) //"Dados do Atendimento"###"Procedimento Realizado"
		
		oPrint:Box((nLinIni + 0839)*nAL + (5*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 0940)*nAL + (5*nLinA4), (nColIni + 700)*nAC)
		oPrint:Say((nLinIni + 0874 + (5*nLinA4))*nAL, (nColIni + 0020)*nAC, "17 - "+STR0033, oFont01) //"17 - Indicação de Acidente (acidente ou doença relacionada) "
		oPrint:Say((nLinIni + 0919 + (5*nLinA4))*nAL, (nColIni + 0030)*nAC, Iif(Valtype(aDados[nX, 17])=="C",aDados[nX, 17],''), oFont04) // Para os casos de consula que não tem executante preenchido

		
		oPrint:Box((nLinIni + 0839)*nAL + (5*nLinA4), (nColIni + 0705)*nAC, (nLinIni + 0940)*nAL + (5*nLinA4), (nColIni + 1100)*nAC)
		oPrint:Say((nLinIni + 0874 + (5*nLinA4))*nAL, (nColIni + 0715)*nAC, '27 - Indicador de Cobertura Especial', oFont01) //"27 - Indicador de Cobertura Especial "
		oPrint:Say((nLinIni + 0919 + (5*nLinA4))*nAL, (nColIni + 0725)*nAC, Iif(Valtype(aDados[nX, 27])=="C",aDados[nX, 27],''), oFont04) // Para os casos de consula que não tem executante preenchido

		If BEA->( FieldPos("BEA_TMREGA") ) > 0
			oPrint:Box((nLinIni + 0839)*nAL + (5*nLinA4), (nColIni + 1105)*nAC, (nLinIni + 0940)*nAL + (5*nLinA4), (nColIni + 1600)*nAC)
			oPrint:Say((nLinIni + 0874 + (5*nLinA4))*nAL, (nColIni + 1110)*nAC, "28 -Regime de Atendimento", oFont01) //"28 -Regime de Atendimento " STR0534
			oPrint:Say((nLinIni + 0919 + (5*nLinA4))*nAL, (nColIni + 1120)*nAC, Iif(Valtype(aDados[nX, 28])=="C",aDados[nX, 28],''), oFont04) // Para os casos de consula que não tem executante preenchido
		Endif

		If BEA->( FieldPos("BEA_SAUOCU") ) > 0
			oPrint:Box((nLinIni + 0839)*nAL + (5*nLinA4), (nColIni + 1605)*nAC, (nLinIni + 0940)*nAL + (5*nLinA4), (nColIni + 1900)*nAC)
			oPrint:Say((nLinIni + 0874 + (5*nLinA4))*nAL, (nColIni + 1615)*nAC, "29 – Saúde Ocupacional", oFont01) //"29 – Saúde Ocupacional " 
			oPrint:Say((nLinIni + 0919 + (5*nLinA4))*nAL, (nColIni + 1625)*nAC, PLSGETVINC('BTU_CDTERM','BEA',.F.,'77',aDados[nX, 29]) , oFont04) // Para os casos de consula que não tem executante preenchido
		Endif	

		oPrint:Box((nLinIni + 0968)*nAL + (6*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 1067)*nAL + (6*nLinA4), (nColIni + 600)*nAC)
		oPrint:Say((nLinIni + 1003 + (6*nLinA4))*nAL, (nColIni + 0020)*nAC, "18 - "+STR0043, oFont01) //"DT. ATEND."
		oPrint:Say((nLinIni + 1048 + (6*nLinA4))*nAL, (nColIni + 0030)*nAC, Dtoc(aDados[nX, 18]), oFont04) // Para os casos de consula que não tem executante preenchido

		oPrint:Box((nLinIni + 0968)*nAL + (4*nLinA4), (nColIni + 0605)*nAC, (nLinIni + 1067)*nAL + (5*nLinA4), (nColIni + 900)*nAC)
		oPrint:Say((nLinIni + 1003 + (4*nLinA4))*nAL, (nColIni + 0615)*nAC, "19 - "+STR0046, oFont01) //"19 - Tipo de Consulta "
		oPrint:Say((nLinIni + 1048 + (4*nLinA4))*nAL, (nColIni + 0625)*nAC, aDados[nX, 19], oFont04) // Para os casos de consula que não tem executante preenchido

		oPrint:Box((nLinIni + 0968)*nAL + (4*nLinA4), (nColIni + 0905)*nAC, (nLinIni + 1067)*nAL + (5*nLinA4), (nColIni + 1300)*nAC)
		oPrint:Say((nLinIni + 1003 + (4*nLinA4))*nAL, (nColIni + 0915)*nAC, "20 - "+STR0044, oFont01) //"20 - Tabela"
		oPrint:Say((nLinIni + 1048 + (4*nLinA4))*nAL, (nColIni + 0925)*nAC, aDados[nX, 20], oFont04) // Para os casos de consula que não tem executante preenchido

		
		oPrint:Box((nLinIni + 0968)*nAL + (4*nLinA4), (nColIni + 1305)*nAC, (nLinIni + 1067)*nAL + (5*nLinA4), (nColIni + 1600)*nAC)
		oPrint:Say((nLinIni + 1003 + (4*nLinA4))*nAL, (nColIni + 1315)*nAC, "21 - "+STR0045, oFont01) //"20 - Tabela"
		oPrint:Say((nLinIni + 1048 + (4*nLinA4))*nAL, (nColIni + 1320)*nAC, aDados[nX, 21], oFont04) // Para os casos de consula que não tem executante preenchido


		oPrint:Box((nLinIni + 0968)*nAL + (4*nLinA4), (nColIni + 1605)*nAC, (nLinIni + 1067)*nAL + (5*nLinA4), (nColIni + 1900)*nAC)
		oPrint:Say((nLinIni + 1003 + (4*nLinA4))*nAL, (nColIni + 1610)*nAC, "22 - Valor do Procedimento", oFont01) //"22 - Valor do Procedimento"
		nVlrApG := iif( valtype(aDados[nX, 22]) == "C", val(aDados[nX, 22]), aDados[nX, 22] )
		oPrint:Say((nLinIni + 1048 + (4*nLinA4))*nAL, (nColIni + 1615)*nAC, Transform(nVlrApG, "@E 99,999,999.99"), oFont04) // Para os casos de consula que não tem executante preenchido

		oPrint:Box((nLinIni + 1075)*nAL + (10*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 1407)*nAL + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1105 + (10*nLinA4))*nAL, (nColIni + 0020)*nAC, "23 - "+STR0056, oFont01) //"Observação"
		nLin := 1150

		For nI := 1 To MlCount(aDados[nX, 23], 80)
			cObs := MemoLine(aDados[nX, 23], 80, nI)
			oPrint:Say((nLinIni + nLin + (10*nLinA4))*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
			nLin += 35
		Next nI

		oPrint:Box((nLinIni + 1412)*nAL + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)), (nColIni + 0010)*nAC, (nLinIni + 1514)*nAL + IIf(nLayout ==2,(14*nLinA4),(22*nLinA4)), (nColIni + 1185 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1437 + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)))*nAL, (nColIni + 0020)*nAC, "24 - "+STR0057, oFont01) //"Data e Assinatura do Profissional"
		oPrint:Box((nLinIni + 1412)*nAL + IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)), (nColIni + 1190 + nColA4)*nAC, (nLinIni + 1514)*nAL + IIf(nLayout ==2,(14*nLinA4),(22*nLinA4)), (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1437+ IIf(nLayout ==2,(13*nLinA4),(20*nLinA4)))*nAL, (nColIni + 1200 + nColA4)*nAC, "25 - "+STR0058, oFont01) //"Data e Assinatura do Beneficiário ou Responsável"

		oPrint:EndPage()	// Finaliza a pagina

	Next nX

Endif

If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Print()
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Print()
EndIf


Return (cFileName)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS2  ³ Autor ³ Luciano Aparecido     ³ Data ³ 08.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia de Serv/SADT ) - BOPS 095189 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela	   ³±±
±±³          ³			 de configuracao/preview do relatorio 		       ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISS2(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW)

Local nLinMax
Local nColMax
Local nLinIni	:= 0 // Linha Lateral (inicial) Esquerda
Local nColIni	:= 0 // Coluna Lateral (inicial) Esquerda
Local nLimFim	:= 0
Local nColA4    := 0
Local nColSoma  := 0
Local nColSoma2 := 0
Local nLinA4	:= 0
Local cFileLogo
Local nLin
Local nOldLinIni
Local nOldColIni
Local nI, nJ, nX, nN
Local nV, nV1, nV2, nV3, nV4
Local cObs
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local oFont05
Local oPrint    := Nil
Local lImpnovo  :=.T.
Local nVolta    := 0
Local nP        := 0
Local nP1       := 0
Local nP2       := 0
Local nP3       := 0
Local nP4       := 0
Local nT        := 0
Local nT1       := 0
Local nT2       := 0
Local nT3       := 0
Local nT4       := 0
Local nTotOPM   := 0
Local nProx     := 0
LOCAL cFileName	:= ""
LOCAL cRel      := "guisadt"
LOCAL cPathSrvJ := GETMV("MV_RELT")
LOCAL nAL		:= 0.25
LOCAL nAC		:= 0.24
Local lImpPrc   := .T.
Local cTissVer  := "2.02.03" //PLSTISSVER()
Local lPLSGTISS	:= ExistBlock("PLSGTISS")

If FindFunction("PLSTISSVER")
	cTissVer	:= PLSTISSVER()
EndIf


DEFAULT lGerTXT 	:= .F.
DEFAULT nLayout 	:= 2
DEFAULT cLogoGH 	:= ""
DEFAULT lWeb		:= .F.
DEFAULT cPathRelW 	:= ""
DEFAULT aDados 	:= { {;
					"123456",;
					"12345678901234567892",;
					"12345678901234567892",;
					CtoD("01/01/07"),;
					"12345678901234567892",;
					CtoD("01/01/07"),;
					CtoD("01/01/07"),;
					"12345678901234567892",;
					Replicate("M",20),;
					CtoD("12/12/07"),;
					Replicate("M",70),;
					"123456789102345",;
					"14.141.114/00001-35",;
					Replicate("M",70),;
					"1234567",;
					Replicate("M",70),;
					"1234567",;
					"123456789102345",;
					"ES",;
					"12345",;
					{ CtoD("12/12/07"), "2210" },;
					"E",;
					"12345",;
					Replicate("M",70),;
					{ "10", "20", "30", "40", "50" } ,;
					{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234" },;
					{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60) },;
					{ 111,111,11,1,1 },;
					{ 999,999,99,9,9 },;
					"14.141.114/00001-35",;
					Replicate("M",70),;
					"999",;
					Replicate("M",40),;
					"MMMMM",;
					Replicate("M",15),;
					Replicate("M",40),;
					"MM",;
					"1234567",;
					"12345-678",;
					{ "1234567", "27.456.658/0001-35" },;
					Replicate("M",70),;
					"1234567",;
					"123456789102345",;
					"MM",;
					{ "12345", "01" },;
					"01",;
					"1",;
					"1",;
					"1",;
					{ 12,"M" },;
					{ CtoD("01/01/07"),CtoD("01/02/07"),CtoD("01/03/07"),CtoD("01/04/07"),CtoD("01/05/07")},;
					{ "0107","0207","0307","0407","0507" },;
					{ "0607","0707","0807","0907","1007" },;
					{ "MM","AA","BB","CC","DD"},;
					{ "1234567890","2345678901","3456789012","4567890123","5678901234"},;
					{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60)},;
					{ 12,1,2,3,4},;
					{ "M","A","B","C","D"},;
					{ "M","E","F","G","H"},;
					{ 111.00,222.00,333.00,444.00,999.99 },;
					{ 99999999.99,22222.22,33333.33,44444.44,11111.11 },;
					{ 11111111.11,55555.00,66666.00,77777.00,88888.00 },;
					{ CtoD("01/01/07"),CtoD("02/01/07"),CtoD("03/01/07"),CtoD("04/01/07"),CtoD("05/01/07"),CtoD("06/01/07"),CtoD("07/01/07"),CtoD("08/01/07"),CtoD("09/01/07"),CtoD("10/01/07")},;
					Replicate("M", 240),;
					{1333333.22},;
					{2333333.22},;
					{3333333.22},;
					{4333333.22},;
					{5333333.22},;
					{6333333.22},;
					{73333333.22},;
					{ "11", "22", "33", "44", "55", "66", "77", "88", "99" },;
					{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234", "6789012345", "7890123456", "8901234567", "9012345678" },;
					{ Replicate ("M", 60), Replicate ("A", 60), Replicate ("B", 60), Replicate ("C", 60), Replicate ("D", 60), Replicate ("E", 60), Replicate ("F", 60), Replicate ("G", 60), Replicate ("H", 60) },;
					{ 01, 1, 2, 03, 04, 05, 06, 7, 99 }, ;
					{ Replicate ("I", 40), Replicate ("J", 40), Replicate ("K", 40), Replicate ("L", 40), Replicate ("M", 40), Replicate ("N", 40), Replicate ("O", 40), Replicate ("P", 40), Replicate ("Q", 40) },;
					{ 999999.99, 111111.99, 222229.99, 333999.99, 444449.99, 555559.99, 666669,99, 777779.99, 888899.99 },;
					{ "11", "12", "13", "14", "15", "16", "17", "18", "19" },;
					{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234", "6789012345", "7890123456", "8901234567", "9012345678" },;
					{ Replicate ("A", 60), Replicate ("B", 60), Replicate ("C", 60), Replicate ("D", 60), Replicate ("E", 60), Replicate ("F", 60), Replicate ("G", 60), Replicate ("H", 60), Replicate ("I", 60) },;
					{ 01, 2, 3, 04, 05, 06, 07, 8, 99 }, ;
					{ Replicate ("J", 20), Replicate ("K", 20), Replicate ("L", 20), Replicate ("M", 20), Replicate ("N", 20), Replicate ("O", 20), Replicate ("P", 20), Replicate ("Q", 20), Replicate ("R", 20) },;
					{ 199999.99, 299999.99, 399999.99, 499999.99, 599999.99, 699999.99, 799.99, 899999.99, 99.99 },;
					{ 399999999.99, 499999999.99, 599999999.99, 699999.99, 799999.99, 899999.99, 99.99, 09.99, 19.99 },;
					{1999999.99},;
					CtoD("01/01/07"),;
					CtoD("02/01/07"),;
					CtoD("03/01/07"),;
					CtoD("04/01/07") } }

oFont01	:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Nao permite acionar a impressao quando for na web.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
if !lWeb
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
else
	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Tratamento para impressao via job
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//oPrint:lInJob  := lWeb
oPrint:lServer := lWeb
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Caminho do arquivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:cPathPDF := cPathSrvJ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Modo paisagem
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:SetLandscape()

if nLayout ==2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Papél A4
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(9)
Elseif nLayout ==3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Papél Carta
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(1)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(14)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Device
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lWeb
	oPrint:setDevice(IMP_PDF)
	//oPrint:lPDFAsPNG := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄ
//³Verifica se existe alguma impressora configurada para Impressao Grafica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If  !lWeb
	oPrint:Setup()
	If !(oPrint:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
		Return
	Else
		lImpnovo:=(oPrint:nModalResult == 1)
	Endif
EndIf

If oPrint:nPaperSize  == 9 // Papél A4
	nLinMax	:=	2000
	nColMax	:=	3355 //3508 //3380 //3365
	nLayout 	:= 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 06, 06, ,.F., , , , .T., .F.) // Normal
Elseif oPrint:nPaperSize == 1 // Papel Carta
	nLinMax	:=	2000
	nColMax	:=	3175
	nLayout 	:= 3
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	nLinMax	:=	2435
	nColMax	:=	3765
	nLayout 	:= 1
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Endif

While lImpnovo

	lImpnovo:=.F.
	nVolta  += 1
	nT      += 5
	nT1     += 5
	nT2     +=10
	nT3     += 9
	nT4     += 9
	nProx   += 1

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 25 To 29
			If Len(aDados[nX, nI]) < nT
				For nJ := Len(aDados[nX, nI]) + 1 To nT
					If AllTrim(Str(nI)) $ "28,29"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 51 To 62
			If Len(aDados[nX, nI]) < nT1
				For nJ := Len(aDados[nX, nI]) + 1 To nT1
					If AllTrim(Str(nI)) $ "51"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "57,60,61,62"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 63 To 63
			If Len(aDados[nX, nI]) < nT2
				For nJ := Len(aDados[nX, nI]) + 1 To nT2
					aAdd(aDados[nX, nI], StoD(""))
				Next nJ
			EndIf
		Next nI

		For nI := 65 To 71
			If Len(aDados[nX, nI]) < nVolta
				For nJ := Len(aDados[nX, nI]) + 1 To nVolta
					If AllTrim(Str(nI)) $ "65,66,67,68,69,70,71"
						aAdd(aDados[nX, nI], 0)
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 72 To 77
			If Len(aDados[nX, nI]) < nT3
				For nJ := Len(aDados[nX, nI]) + 1 To nT3
					If AllTrim(Str(nI)) $ "75,77"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 78 To 84
			If Len(aDados[nX, nI]) < nT4
				For nJ := Len(aDados[nX, nI]) + 1 To nT4
					If AllTrim(Str(nI)) $ "81,83,84"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 85 To 85
			If Len(aDados[nX, nI]) < nVolta
				For nJ := Len(aDados[nX, nI]) + 1 To nVolta
					aAdd(aDados[nX, nI], 0)
				Next nJ
			EndIf
		Next nI
		If oPrint:Cprinter == "PDF" .OR. lWeb
			nLinIni	:= 150
			nLimFim	:= 400
		Else
			nLinIni	:= 060
			nLimFim	:= 230
		Endif


		nColIni		:= 068
		nColA4		:= 000
		nLinA4		:= 000
		nColSoma	:= 000
		nColSoma2	:= 000

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Inicia uma nova pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:StartPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLimFim + nLinMax)*nAL, (nColIni + nColMax)*nAC)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 	// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
			nColA4    := -0395
			nLinA4    := -0010
			nColSoma  := -0300
			nColSoma2 := -0190
		Elseif nLayout == 3// Carta
			nColA4    := -0590
			nLinA4    := -0010
			nColSoma  := -0300
			nColSoma2 := -0190
		Endif

		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 1702)*nAC + (nColA4/2), STR0060, oFont02n,,,, 2) //"GUIA DE SERVIÇO PROFISSIONAL / SERVIÇO AUXILIAR DE DIAGNÓSTICO E TERAPIA - SP/SADT"
		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 2930 + IIf (nLayout == 3,(nColA4/2+(nColSoma/3)),(nColA4/2)))*nAC, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 3026 + IIf (nLayout == 3,(nColA4/2+(nColSoma/3)),(nColA4/2)))*nAC, aDados[nX, 02], oFont03n)

		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 01], oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 0320			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 1035)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 0330			)*nAC, "3 - "+STR0061, oFont01) //"Nº Guia Principal"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 0340			)*nAC, aDados[nX, 03], oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 1040			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 1345)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 1050			)*nAC, "4 - "+STR0062, oFont01) //"Data da Autorização"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 1060			)*nAC, DtoC(aDados[nX, 04]), oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 1350			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 1755)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 1360			)*nAC, "5 - "+STR0063, oFont01) //"Senha"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 1370			)*nAC, aDados[nX, 05], oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 1760			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 2165)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 1770			)*nAC, "6 - "+STR0064, oFont01) //"Data Validade da Senha"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 1780			)*nAC, DtoC(aDados[nX, 06]), oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 2170			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 2465)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 2180			)*nAC, "7 - "+STR0004, oFont01) //"Data de Emissão da Guia"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 2190			)*nAC, DtoC(aDados[nX, 07]), oFont04)

		oPrint:Say((nLinIni + 0274 + nLinA4)*nAL, (nColIni + 0010			)*nAC, STR0005, oFont01) //"Dados do Beneficiário"
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 0425)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "8 - "+STR0006, oFont01) //"Número da Carteira"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 08], oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 0430			)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 1572 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0440			)*nAC, "9 - "+STR0007, oFont01) //"Plano"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 0450			)*nAC, aDados[nX, 09], oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 1577 + nColA4	)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 1835 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 1587 + nColA4	)*nAC, "10 - "+STR0008, oFont01) //"Validade da Carteira"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 1597 + nColA4	)*nAC, DtoC(aDados[nX, 10]), oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 1840 + nColA4	)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 3290 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 1850 + nColA4	)*nAC, "11 - "+STR0009, oFont01) //"Nome"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 1860 + nColA4	)*nAC, SubStr(aDados[nX, 11], 1, 52), oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 3295 + nColA4	)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 3305 + nColA4	)*nAC, "12 - "+STR0010, oFont01) //"Número do Cartão Nacional de Saúde"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 3315 + nColA4	)*nAC, aDados[nX, 12], oFont04)

		oPrint:Say((nLinIni + 0403 + nLinA4)*nAL, (nColIni + 0010			)*nAC, STR0065, oFont01) //"Dados do Contratado Solicitante"
		oPrint:Box((nLinIni + 0433)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0527)*nAL + nLinA4, (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 0438 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "13 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say((nLinIni + 0468 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 13], oFont04)
		oPrint:Box((nLinIni + 0433)*nAL + nLinA4, (nColIni + 0431			)*nAC, (nLinIni + 0527)*nAL + nLinA4, (nColIni + 2245)*nAC)
		oPrint:Say((nLinIni + 0438 + nLinA4)*nAL, (nColIni + 0441			)*nAC, "14 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say((nLinIni + 0468 + nLinA4)*nAL, (nColIni + 0451			)*nAC, SubStr(aDados[nX, 14], 1, 65), oFont04)
		oPrint:Box((nLinIni + 0433)*nAL + nLinA4, (nColIni + 2250			)*nAC, (nLinIni + 0527)*nAL + nLinA4, (nColIni + 2480)*nAC)
		oPrint:Say((nLinIni + 0438 + nLinA4)*nAL, (nColIni + 2260			)*nAC, "15 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 0468 + nLinA4)*nAL, (nColIni + 2270			)*nAC, aDados[nX, 15], oFont04)

		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 1824)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "16 - "+STR0066, oFont01) //"Nome do Profissional Solicitante"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 0030			)*nAC, SubStr(aDados[nX, 16], 1, 66), oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 1829			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2122)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 1839			)*nAC, "17 - "+STR0022, oFont01) //"Conselho Profissional"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 1849			)*nAC, aDados[nX, 17], oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 2127			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2480)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 2137			)*nAC, "18 - "+STR0023, oFont01) //"Número no Conselho"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 2147			)*nAC, aDados[nX, 18], oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 2485			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2575)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 2495			)*nAC, "19 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 2505			)*nAC, aDados[nX, 19], oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 2580			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2790)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 2590			)*nAC, "20 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 2600			)*nAC, aDados[nX, 20], oFont04)

		oPrint:Say((nLinIni + 0631 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0067, oFont01) //"Dados da Solicitação / Procedimentos e Exames Solicitados"
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0020)*nAC, "21 - "+STR0068, oFont01) //"Data/Hora da Solicitação"
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 21,1]) + " " + Transform(aDados[nX, 21,2], "@R 99:99"), oFont04)
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0320)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 0735)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0330)*nAC, "22 - "+STR0069, oFont01) //"Caráter da Solicitação"
		oPrint:Line((nLinIni + 0691)*nAL+ nLinA4, 		(nColIni + 0340)*nAC, (nLinIni + 0728)*nAL + (nLinA4/2), (nColIni + 0340)*nAC)
		oPrint:Line((nLinIni + 0728)*nAL+ (nLinA4/2), 	(nColIni + 0340)*nAC, (nLinIni + 0728)*nAL + (nLinA4/2), (nColIni + 0387)*nAC)
		oPrint:Line((nLinIni + 0691)*nAL+ nLinA4, 		(nColIni + 0387)*nAC, (nLinIni + 0728)*nAL + (nLinA4/2), (nColIni + 0387)*nAC)
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0353)*nAC, aDados[nX, 22], oFont04)
		oPrint:Say((nLinIni + 0703 + nLinA4)*nAL, (nColIni + 0400)*nAC, STR0070+"  "+STR0071, oFont01) //"E-Eletiva"###"U-Urgência/Emergência"
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0740)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 0905)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0750)*nAC, "23 - "+STR0072, oFont01) //"CID 10"
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0760)*nAC, aDados[nX, 23], oFont04)
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0910)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0920)*nAC, "24 - "+STR0073, oFont01) //"Indicação Clínica (obrigatório se pequena cirurgia, terapia, consulta referenciada e alto custo)"
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0930)*nAC, aDados[nX, 24], oFont04)

		oPrint:Box((nLinIni + 0760)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 1005)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "25 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 0150			)*nAC, "26 - "+STR0075, oFont01) //"Código do Procedimento"
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 0450			)*nAC, "27 - "+STR0076, oFont01) //"Descrição"
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 3400 + nColA4	)*nAC, "28 - "+STR0077, oFont01,,,,1) //"Qt.Solic."
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 3610 + nColA4	)*nAC, "29 - "+STR0078, oFont01,,,,1) //"Qt.Autoriz."

		nOldLinIni := nLinIni

		if nVolta = 1
			nV:=1
		Endif

		For nP := nV To nT
			if nVolta <> 1
				nN:=nP-((5*nVolta)-5)
				oPrint:Say((nLinIni + 0805 + nLinA4)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			else
				oPrint:Say((nLinIni + 0805 + nLinA4)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
			endif
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0065)*nAC			, aDados[nX, 25, nP], oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0150)*nAC			, aDados[nX, 26, nP], oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0450)*nAC			, aDados[nX, 27, nP], oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 3425 + nColA4)*nAC, IIf(Empty(aDados[nX, 28, nP]), "", Transform(aDados[nX, 28, nP], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 3635 + nColA4)*nAC, IIf(Empty(aDados[nX, 29, nP]), "", Transform(aDados[nX, 29, nP], "@E 9999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nP

		if nT < Len(aDados[nX, 26]).or. lImpnovo
			  nV:=nP
			  lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		oPrint:Say((nLinIni + 1000 + nLinA4)*nAL, (nColIni + 0010			)*nAC, STR0079, oFont01) //"Dados do Contratado Executante"
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 0416)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "30 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 30], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 0421			)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 1316 + nColSoma)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 0431			)*nAC, "31 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 0441			)*nAC, SubStr(aDados[nX, 31], 1, 32), oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 1321 + nColSoma)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 1433 + nColSoma)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 1331 + nColSoma)*nAC, "32 - "+STR0015, oFont01) //"T.L."
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 1341 + nColSoma)*nAC, aDados[nX, 32], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 1438 + nColSoma)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 2413 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 1448 + nColSoma)*nAC, "33-34-35 - "+STR0016, oFont01) //"Logradouro - Número - Complemento"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 1458 + nColSoma)*nAC, SubStr(AllTrim(aDados[nX, 33]) + IIf(!Empty(aDados[nX, 34]), ", ","") + AllTrim(aDados[nX, 34]) + IIf(!Empty(aDados[nX, 35]), " - ","") + AllTrim(aDados[nX, 35]), 1, 35), oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 2418 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3023 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 2428 + nColA4	)*nAC, "36 - "+STR0017, oFont01) //"Município"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 2438 + nColA4	)*nAC, SubStr(aDados[nX, 36], 1, 21), oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3028 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3130 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3038 + nColA4	)*nAC, "37 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3048 + nColA4	)*nAC, aDados[nX, 37], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3135 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3320 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3145 + nColA4	)*nAC, "38 - "+STR0080, oFont01) //"Cód.IBGE"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3155 + nColA4	)*nAC, aDados[nX, 38], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3325 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3510 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3335 + nColA4	)*nAC, "39 - "+STR0020, oFont01) //"CEP"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3345 + nColA4	)*nAC, aDados[nX, 39], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3515 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3525 + nColA4	)*nAC, "40 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3535 + nColA4	)*nAC, aDados[nX, 40, 1], oFont04)

		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 0590)*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 0020)*nAC, "40a - "+STR0081, oFont01) //"Código na Operadora / CPF do exec. complementar"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 0030)*nAC, SubStr(aDados[nX, 40, 2], 1, 68), oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 0595)*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 2436 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 0605)*nAC, "41 - "+STR0082, oFont01) //"Nome do Profissional Executante/Complementar"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 0615)*nAC, SubStr(aDados[nX, 41], 1, 68), oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 2441 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 2715 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 2451 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "42 - "+STR0022, oFont01) //"Conselho Profissional"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 2461 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 42], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 2720 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3055 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 2730 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "43 - "+STR0023, oFont01) //"Número no Conselho"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 2740 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 43], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 3060 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3160 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 3070 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "44 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 3080 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 44], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 3165 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3372 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 3175 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "45 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 3185 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 45, 1], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 3377 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 3387 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "45a - "+STR0083, oFont01) //"Grau de Participação"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 3397 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 45, 2], oFont04)

		oPrint:Say((nLinIni + 1236 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0041, oFont01) //"Dados do Atendimento"
		oPrint:Box((nLinIni + 1268)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1362)*nAL + nLinA4, (nColIni + 1185)*nAC)
		oPrint:Say((nLinIni + 1273 + nLinA4)*nAL, (nColIni + 0020)*nAC, "46 - "+STR0084, oFont01) //"Tipo Atendimento"
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni + 1348)*nAL+ nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 0087)*nAC)
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 0087)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 0087)*nAC)
		oPrint:Say((nLinIni + 1303 + nLinA4)*nAL, (nColIni + 0043)*nAC, aDados[nX, 46], oFont04)
		oPrint:Say((nLinIni + 1298 + nLinA4)*nAL, (nColIni + 0100)*nAC, "01 - "+STR0085+"    "+"02 - "+STR0086+"    "+"03 - "+STR0087+"    "+"04 - "+STR0088+"    "+"05 - "+STR0089+"    "+"06 - "+STR0090, oFont01) //"Remoção"###"Pequena Cirurgia"###"Terapias"###"Consulta"###"Exame"###"Atendimento Domiciliar"
		oPrint:Say((nLinIni + 1328 + nLinA4)*nAL, (nColIni + 0100)*nAC, "07 - "+STR0091+"    "+"08 - "+STR0092+"    "+"09 - "+STR0093+"    "+"10 - "+STR0094, oFont01) //"SADT Internado"###"Quimioterapia"###"Radioterapia"###"TRS-Terapia Renal Substitutiva"
		oPrint:Box((nLinIni + 1268)*nAL + nLinA4, (nColIni + 1190)*nAC, (nLinIni + 1362)*nAL + nLinA4, (nColIni + 2450 + nColA4/2)*nAC)
		oPrint:Say((nLinIni + 1273 + nLinA4)*nAL, (nColIni + 1200)*nAC, "47 - "+STR0033, oFont01) //"Indicação de Acidente"
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 1210)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 1210)*nAC)
		oPrint:Line((nLinIni + 1348)*nAL+ nLinA4, (nColIni + 1210)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 1257)*nAC)
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 1257)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 1257)*nAC)
		oPrint:Say((nLinIni + 1303 + nLinA4)*nAL, (nColIni + 1223)*nAC, aDados[nX, 47], oFont04)
		oPrint:Say((nLinIni + 1313 + nLinA4)*nAL, (nColIni + 1270)*nAC, "0 - "+STR0034+"   "+"1 - "+STR0035+"   "+"2 - "+STR0036, oFont01) //"Acidente ou doença relacionado ao trabalho"###"Trânsito"###"Outros"
		oPrint:Box((nLinIni + 1268)*nAL + nLinA4, (nColIni + 2455 + nColA4/2)*nAC, (nLinIni + 1362)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1273 + nLinA4)*nAL, (nColIni + 2465 + nColA4/2)*nAC, "48 - "+STR0050, oFont01) //"Tipo de Saída"
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 2475 + nColA4/2)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 2475 + nColA4/2)*nAC)
		oPrint:Line((nLinIni + 1348)*nAL+ nLinA4, (nColIni + 2475 + nColA4/2)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 2522 + nColA4/2)*nAC)
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 2522 + nColA4/2)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 2522 + nColA4/2)*nAC)
		oPrint:Say((nLinIni + 1303 + nLinA4)*nAL, (nColIni + 2488 + nColA4/2)*nAC, aDados[nX, 48], oFont04)
		oPrint:Say((nLinIni + 1313 + nLinA4)*nAL, (nColIni + 2535 + nColA4/2)*nAC, "1 - "+STR0051+"    "+"2 - "+STR0052+"    "+"3 - "+STR0053+"    "+"4 - "+STR0054+"    "+"5 - "+STR0055+"    "+"6 - "+STR0095, oFont01) //"Retorno"###"Retorno SADT"###"Referência"###"Internação"###"Alta"###"Óbito"

		oPrint:Say((nLinIni + 1367 + nLinA4)*nAL , (nColIni + 0010)*nAC, STR0096, oFont01) //"Consulta Referência"
		oPrint:Box((nLinIni + 1397)*nAL + nLinA4 , (nColIni + 0010)*nAC, (nLinIni + 1491)*nAL + nLinA4, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 1402 + nLinA4)*nAL , (nColIni + 0020)*nAC, "49 - "+STR0026, oFont01) //"Tipo de Doença"
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni + 1477)*nAL + nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0077)*nAC)
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0077)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0077)*nAC)
		oPrint:Say((nLinIni + 1432  + nLinA4)*nAL, (nColIni + 0043)*nAC, aDados[nX, 49], oFont04)
		oPrint:Say((nLinIni + 1442  + nLinA4)*nAL, (nColIni + 0090)*nAC, STR0027+"    "+STR0028, oFont01) //"A-Aguda"###"C-Crônica"
		oPrint:Box((nLinIni + 1397)*nAL  + nLinA4, (nColIni + 0320)*nAC, (nLinIni + 1491)*nAL + nLinA4, (nColIni + 0770)*nAC)
		oPrint:Say((nLinIni + 1402  + nLinA4)*nAL, (nColIni + 0330)*nAC, "50 - "+STR0029, oFont01) //"Tempo de Doença"
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0340)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0340)*nAC)
		oPrint:Line((nLinIni + 1477)*nAL + nLinA4, (nColIni + 0340)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0426)*nAC)
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0426)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0426)*nAC)
		If aDados[nX,50,1] > 0
			oPrint:Say((nLinIni + 1432 + nLinA4)*nAL, (nColIni + 0353)*nAC, IIF((StrZero(aDados[nX, 50,1], 2, 0))=="00","",(StrZero(aDados[nX, 50,1], 2, 0))), oFont04)
		Endif
		oPrint:Say((nLinIni + 1442 + nLinA4)*nAL, (nColIni + 0434)*nAC, "-", oFont01)
		oPrint:Line((nLinIni+ 1427)*nAL + nLinA4, (nColIni + 0447)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0447)*nAC)
		oPrint:Line((nLinIni+ 1477)*nAL + nLinA4, (nColIni + 0447)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0494)*nAC)
		oPrint:Line((nLinIni+ 1427)*nAL + nLinA4, (nColIni + 0494)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0494)*nAC)
		oPrint:Say((nLinIni + 1432 + nLinA4)*nAL, (nColIni + 0457)*nAC, aDados[nX, 50,2], oFont04)
		oPrint:Say((nLinIni + 1442 + nLinA4)*nAL, (nColIni + 0510)*nAC, STR0030+"  "+STR0031+"  "+STR0032, oFont01) //"A-Anos"###"M-Meses"###"D-Dias"

		oPrint:Say((nLinIni + 1478 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0097, oFont01) //"Procedimentos e Exames realizados"
		oPrint:Box((nLinIni + 1526)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1766)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0020)*nAC, "51 - "+STR0098, oFont01) //"Data"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0210)*nAC, "52 - "+STR0099, oFont01) //"Hora Inicial"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0380)*nAC, "53 - "+STR0100, oFont01) //"Hora Final"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0540)*nAC, "54 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0660)*nAC, "55 - "+STR0075, oFont01) //"Código do Procedimento"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0940)*nAC, "56 - "+STR0076, oFont01) //"Descrição"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 3675)*nAC + nColA4, "57 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 3795)*nAC + nColA4, "58 - "+STR0102, oFont01) //"Via"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4040)*nAC + nColA4, "59 - "+STR0103, oFont01) //"Tec."
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4260)*nAC + nColA4, "60 - "+STR0104, oFont01,,,,1) //"% Red./Acresc."
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4500)*nAC + nColA4, "61 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4745)*nAC + nColA4, "62 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nV1:=1
		Endif

		If lPLSGTISS
			lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"02",lImpPrc})
		EndIf

		If lImpPrc

			For nP1 := nV1 To nT1
				if nVolta <> 1
					nN:=nP1-((5*nVolta)-5)
					oPrint:Say((nLinIni + 1566 + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
				else
					oPrint:Say((nLinIni + 1566 + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP1)) + " - ", oFont01)
				endif
					oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0065)*nAC, IIf(Empty(aDados[nX, 51, nP1]), "", DtoC(aDados[nX, 51, nP1])), oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0210)*nAC, IIf(Empty(aDados[nX, 52, nP1]), "", Transform(aDados[nX, 52, nP1], "@R 99:99")), oFont04)
			 	oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0380)*nAC, IIf(Empty(aDados[nX, 53, nP1]), "", Transform(aDados[nX, 53, nP1], "@R 99:99")), oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0540)*nAC, aDados[nX, 54, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0660)*nAC, aDados[nX, 55, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0940)*nAC, SUBSTR(aDados[nX, 56, nP1],1,51), oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 2445 + nColA4)*nAC, IIf(Empty(aDados[nX, 57, nP1]), "", Transform(aDados[nX, 57, nP1], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 2560 + nColA4)*nAC, aDados[nX, 58, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 2840 + nColA4)*nAC, aDados[nX, 59, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 3050 + nColA4)*nAC, IIf(Empty(aDados[nX, 60, nP1]), "", Transform(aDados[nX, 60, nP1], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 3240 + nColA4)*nAC, IIf(Empty(aDados[nX, 61, nP1]), "", Transform(aDados[nX, 61, nP1], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 3510 + nColA4)*nAC, IIf(Empty(aDados[nX, 62, nP1]), "", Transform(aDados[nX, 62, nP1], "@E 99,999,999.99")), oFont04,,,,1)
				nLinIni += 40
			Next nP1

		EndIf

		if nT1 < Len(aDados[nX, 55]).or. lImpnovo
			  nV1:=nP1
			  lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		oPrint:Box((nLinIni + 1771)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1971)*nAL + (2*nLinA4), (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1766 + nLinA4)*nAL, (nColIni + 0020)*nAC, "63 - "+STR0107, oFont01) //"Data e Assinatura de Procedimentos em Série"

		nOldColIni := nColIni

		if nVolta=1
			nV2:=1
		Endif

		For nP2 := nV2 To nT2 Step 2
			if nVolta <> 1
				nN:=nP2-((10*nVolta)-10)
				oPrint:Say((nLinIni + 1816 + nLinA4)*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 1816 + nLinA4)*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nP2)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 1816 + nLinA4)*nAL, (nColIni + 0070)*nAC, DtoC(aDados[nX, 63, nP2]), oFont04)
			oPrint:Line((nLinIni + 1861)*nAL + nLinA4,(nColIni + 0230)*nAC, (nLinIni + 1861)*nAL + nLinA4, (nColIni + 0757 + nColSoma2)*nAC)
			if nLayout ==1
				nColIni += 727
			Elseif nLayout ==2
				nColIni += 670
			Else
				nColIni += 630
			Endif
		Next nP2

		nColIni := nOldColIni

		nOldColIni := nColIni

		if nVolta=1
			nV2:=1
		Endif

		For nP2 := nV2+1 To nT2+1 Step 2
			if nVolta <> 1
				nN:=nP2-((10*nVolta)-10)
				oPrint:Say((nLinIni + 1890 + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 1890 + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nP2)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 1890 + (2*nLinA4))*nAL, (nColIni + 0070)*nAC, DtoC(aDados[nX, 63, nP2]), oFont04)
			oPrint:Line((nLinIni + 1945)*nAL + (2*nLinA4),(nColIni + 0230)*nAC, (nLinIni + 1945)*nAL + (2*nLinA4), (nColIni + 0757 + nColSoma2)*nAC)
			if nLayout ==1
				nColIni += 727
			Elseif nLayout ==2
				nColIni += 670
			Else
				nColIni += 630
			Endif
		Next nP2

		nColIni := nOldColIni

	    if nT2 < Len(aDados[nX, 63]).or. lImpnovo
			  nV2:=nP2-1
			  lImpnovo:=.T.
		Endif

		oPrint:Box((nLinIni + 1976)*nAL + (2*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 2136)*nAL + (3*nLinA4), (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1950 + (2*nLinA4))*nAL, (nColIni + 0020)*nAC, "64 - "+STR0056, oFont01) //"Observação"

		If nModulo == 51    //Gestão Hospitalar
			if nVolta=1
				nV1:=1
			Endif

			nLin := 1988
			For nP1 := nV1 To nT1
				if nVolta <> 1
					nN:=nP1-((5*nVolta)-5)
					oPrint:Say((nLinIni + nLin + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
				else
					oPrint:Say((nLinIni + nLin + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP1)) + " - ", oFont01)
				endif
				oPrint:Say((nLinIni + nLin + nLinA4)*nAL, (nColIni + 0065)*nAC, aDados[nX, 64, nP1], oFont04)

				nLin += 35
			Next nP1

			if nT1 < Len(aDados[nX, 64]).or. lImpnovo
				  nV1:=nP1
				  lImpnovo:=.T.
			Endif
		Else
			nLin := 1991

		cOper := substr(aDados[nX, 2],1,4)
		cAno  := substr(aDados[nX, 2],6,4)
		cMes  := substr(aDados[nX, 2],11,2)
		cAut  := substr(aDados[nX, 2],14,8)

		//Realizo a consulta na BEA
		DbSelectArea("BEA")
		BEA->(dbSetOrder(1))
		BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))

		//acrescento na posição da observação o resultado da busca, pois estava vindo errado
			//Correção TISS 2.02.03
			If !Empty(cTissVer) .AND. cTissVer >= "3"
				aDados[nX, 58] := BEA->BEA_MSG01 + BEA->BEA_MSG02 + BEA->BEA_MSG03
			EndIf



			For nI := 1 To MlCount(aDados[nX, 64])
				cObs := MemoLine(aDados[nX, 64], 250, nI)
				If cObs == ""
					exit
				Endif
				oPrint:Say((nLinIni + nLin + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, LOWERACE(cObs), oFont05)
				nLin += 20 //dennis
			Next nI

		Endif
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 0010)*nAC			 		, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 0591 + (nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 0020)*nAC				 	, "65 - "+STR0108, oFont01) //"Total Procedimentos R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 0220 + (nColA4/6))*nAC 	, Transform(aDados[nX, 65,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 0596 + (nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 1117 + 2*(nColA4/7))*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 0606 + (nColA4/7))*nAC	, "66 - "+STR0109, oFont01) //"Total Taxas e Aluguéis R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 0806 + 2*(nColA4/6))*nAC	, Transform(aDados[nX, 66,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 1122 + 2*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 1643  + 3*(nColA4/7))*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 1132 + 2*(nColA4/7))*nAC	, "67 - "+STR0110, oFont01) //"Total Materiais R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 1332 + 3*(nColA4/6))*nAC	, Transform(aDados[nX, 67,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 1648 + 3*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 2169 + 4*(nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 1658 + 3*(nColA4/7))*nAC	, "68 - "+STR0111, oFont01) //"Total Medicamentos R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 1858 + 4*(nColA4/6))*nAC	, Transform(aDados[nX, 68,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 2174 + 4*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 2695 + 5*(nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 2184 + 4*(nColA4/7))*nAC	, "69 - "+STR0112, oFont01) //"Total Diárias R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 2384 + 5*(nColA4/6))*nAC	, Transform(aDados[nX, 69,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 2700 + 5*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 3221 + 6*(nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 2710 + 5*(nColA4/7))*nAC	, "70 - "+STR0113, oFont01) //"Total Gases Medicinais R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 2910 + 6*(nColA4/6))*nAC	, Transform(aDados[nX, 70,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 3226 + 6*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 3745  + 7*(nColA4/7))*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 3236 + 6*(nColA4/7))*nAC	, "71 - "+STR0114, oFont01) //"Total Geral da Guia R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 3436 + 7*(nColA4/6))*nAC	, Transform(aDados[nX, 71,nProx], "@E 999,999,999.99"), oFont04,,,,1)


		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 0010)*nAC					, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 0986 + (nColA4/4) )*nAC)
	   	oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 0020)*nAC 				, "86 - "+STR0115, oFont01) //"Data e Assinatura do Solicitante"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 0030)*nAC 				, DtoC(aDados[nX, 86]), oFont04)
		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 0991  +(nColA4/4))*nAC	, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 1907 + 2*(nColA4/4) )*nAC)
		oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 1001  +(nColA4/4))*nAC	, "87 - "+STR0116, oFont01) //"Data e Assinatura do Responsável pela Autorização"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 1011  +(nColA4/4))*nAC	, DtoC(aDados[nX, 87]), oFont04)
		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 1912  +2*(nColA4/4))*nAC	, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 2828 + 3*(nColA4/4) )*nAC)
		oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 1922  +2*(nColA4/4))*nAC	, "88 - "+STR0058, oFont01) //"Data e Assinatura do Beneficiário ou Responsável"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 1932  +2*(nColA4/4))*nAC	, DtoC(aDados[nX, 88]), oFont04)
		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 2833  +3*(nColA4/4))*nAC	, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 3745 + 4*(nColA4/4) )*nAC)
		oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 2843  +3*(nColA4/4))*nAC	, "89 - "+STR0117, oFont01) //"Data e Assinatura do Prestador Executante"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 2853  +3*(nColA4/4))*nAC	, DtoC(aDados[nX, 89]), oFont04)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Finaliza a pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:EndPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Verso da Guia - Inicia uma nova pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:StartPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

		oPrint:Box((nLinIni + 0010)*nAL, (nColIni + 0010)*nAC			, (nLinIni + 0490)*nAL, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0030)*nAL, (nColIni + 0020)*nAC			, STR0118, oFont01) //"OPM Solicitados"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 0020)*nAC			, "72 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 0160)*nAC			, "73 - "+STR0119, oFont01) //"Código do OPM"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 0410)*nAC		 	, "74 - "+STR0120, oFont01) //"Descrição OPM"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 2400 + nColA4)*nAC	, "75 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 2550 + nColA4)*nAC	, "76 - "+STR0121, oFont01) //"Fabricante"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 3530 + nColA4)*nAC	, "77 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nV3:=1
		Endif

		For nP3 := nV3 To nT3
			if nVolta <> 1
				nN:=nP3-((9*nVolta)-9)
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP3)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0065)*nAC			, aDados[nX, 72, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0160)*nAC			, aDados[nX, 73, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0410)*nAC			, aDados[nX, 74, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 2400 + nColA4)*nAC	, IIf(Empty(aDados[nX, 75, nP3]), "", Transform(aDados[nX, 75, nP3], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 2550 + nColA4)*nAC	, aDados[nX, 76, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 3550 + nColA4)*nAC	, IIf(Empty(aDados[nX, 77, nP3]), "", Transform(aDados[nX, 77, nP3], "@E 999,999,999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nP3

		nLinIni := nOldLinIni

	    if nT3 < Len(aDados[nX, 73]).or. lImpnovo
			  nV3:=nP3
			  lImpnovo:=.T.
		Endif

		oPrint:Box((nLinIni + 0495)*nAL, (nColIni + 0010)*nAC			, (nLinIni + 0990)*nAL, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0515)*nAL, (nColIni + 0020)*nAC			, STR0122, oFont01) //"OPM Utilizados"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0020)*nAC			, "78 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0160)*nAC			, "79 - "+STR0119, oFont01) //"Código do OPM"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0410)*nAC			, "80 - "+STR0120, oFont01) //"Descrição OPM"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 2400 + nColA4)*nAC	, "81 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 2550 + nColA4)*nAC	, "82 - "+STR0123, oFont01) //"Código de Barras"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 3250 + nColA4)*nAC	, "83 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 3560 + nColA4)*nAC	, "84 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nV4:=1
		Endif

		For nP4 := nV4 To nT4
			if nVolta <> 1
				nN:=nP4-((9*nVolta)-9)
				oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP4)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0065)*nAC			, aDados[nX, 78, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0160)*nAC			, aDados[nX, 79, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0410)*nAC			, aDados[nX, 80, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 2400 + nColA4)*nAC	, IIf(Empty(aDados[nX, 81, nP4]), "", Transform(aDados[nX, 81, nP4], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 2550 + nColA4)*nAC	, aDados[nX, 82, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 3260 + nColA4)*nAC	, IIf(Empty(aDados[nX, 83, nP4]), "", Transform(aDados[nX, 83, nP4], "@E 999,999,999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 3540 + nColA4)*nAC	, IIf(Empty(aDados[nX, 84, nP4]), "", Transform(aDados[nX, 84, nP4], "@E 999,999,999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nP4

		nLinIni := nOldLinIni

	    nTotOPM:=nV4

	    if nT4 < Len(aDados[nX, 79]).or. lImpnovo
			  nV4:=nP4
			  lImpnovo:=.T.
		Endif

		oPrint:Box((nLinIni + 1005)*nAL, (nColIni + 3395 + nColA4)*nAC, (nLinIni + 1089)*nAL, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1025)*nAL, (nColIni + 3405 + nColA4)*nAC, "85 - "+STR0124, oFont01) //"Total OPM R$"
		oPrint:Say((nLinIni + 1055)*nAL, (nColIni + 3555 + nColA4)*nAC, Transform(aDados[nX, 85,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Finaliza a pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	   	oPrint:EndPage()

	Next nX
EndDo

If lGerTXT .And. !lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Imprime Relatorio
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Print()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Visualiza impressao grafica antes de imprimir
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Print()
EndIf

Return(cFileName)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSSADT1  ³ Autor ³ Luciano Aparecido     ³ Data ³ 08.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia de Serv/SADT ) - BOPS 095189
±±             Impressão apenas da primeira pagina guia sadt
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela	  ³±±
±±³          ³			 de configuracao/preview do relatorio 		         ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSSADT1(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW)

Local nLinMax
Local nColMax
Local nLinIni	:= 0 // Linha Lateral (inicial) Esquerda
Local nColIni	:= 0 // Coluna Lateral (inicial) Esquerda
Local nLimFim	:= 0
Local nColA4    := 0
Local nColSoma  := 0
Local nColSoma2 := 0
Local nLinA4	:= 0
Local cFileLogo
Local nLin
Local nOldLinIni
Local nOldColIni
Local nI, nJ, nX, nN
Local nV, nV1, nV2
Local cObs
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local oPrint    := Nil
Local lImpnovo  :=.T.
Local nVolta    := 0
Local nP        := 0
Local nP1       := 0
Local nP2       := 0
Local nT        := 0
Local nT1       := 0
Local nT2       := 0
Local nT3       := 0
Local nT4       := 0
Local nProx     := 0
LOCAL cFileName	:= ""
LOCAL cRel      := "guisadt"
LOCAL cPathSrvJ := GETMV("MV_RELT")
LOCAL nAL		:= 0.25
LOCAL nAC		:= 0.24
Local lImpPrc   := .T.
Local lPLSGTISS	:= ExistBlock("PLSGTISS")

DEFAULT lGerTXT 	:= .F.
DEFAULT nLayout 	:= 2
DEFAULT cLogoGH 	:= ""
DEFAULT lWeb		:= .F.
DEFAULT cPathRelW 	:= ""
DEFAULT aDados 	:= { {;
					"123456",;
					"12345678901234567892",;
					"12345678901234567892",;
					CtoD("01/01/07"),;
					"12345678901234567892",;
					CtoD("01/01/07"),;
					CtoD("01/01/07"),;
					"12345678901234567892",;
					Replicate("M",20),;
					CtoD("12/12/07"),;
					Replicate("M",70),;
					"123456789102345",;
					"14.141.114/00001-35",;
					Replicate("M",70),;
					"1234567",;
					Replicate("M",70),;
					"1234567",;
					"123456789102345",;
					"ES",;
					"12345",;
					{ CtoD("12/12/07"), "2210" },;
					"E",;
					"12345",;
					Replicate("M",70),;
					{ "10", "20", "30", "40", "50" } ,;
					{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234" },;
					{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60) },;
					{ 111,111,11,1,1 },;
					{ 999,999,99,9,9 },;
					"14.141.114/00001-35",;
					Replicate("M",70),;
					"999",;
					Replicate("M",40),;
					"MMMMM",;
					Replicate("M",15),;
					Replicate("M",40),;
					"MM",;
					"1234567",;
					"12345-678",;
					{ "1234567", "27.456.658/0001-35" },;
					Replicate("M",70),;
					"1234567",;
					"123456789102345",;
					"MM",;
					{ "12345", "01" },;
					"01",;
					"1",;
					"1",;
					"1",;
					{ 12,"M" },;
					{ CtoD("01/01/07"),CtoD("01/02/07"),CtoD("01/03/07"),CtoD("01/04/07"),CtoD("01/05/07")},;
					{ "0107","0207","0307","0407","0507" },;
					{ "0607","0707","0807","0907","1007" },;
					{ "MM","AA","BB","CC","DD"},;
					{ "1234567890","2345678901","3456789012","4567890123","5678901234"},;
					{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60)},;
					{ 12,1,2,3,4},;
					{ "M","A","B","C","D"},;
					{ "M","E","F","G","H"},;
					{ 111.00,222.00,333.00,444.00,999.99 },;
					{ 99999999.99,22222.22,33333.33,44444.44,11111.11 },;
					{ 11111111.11,55555.00,66666.00,77777.00,88888.00 },;
					{ CtoD("01/01/07"),CtoD("02/01/07"),CtoD("03/01/07"),CtoD("04/01/07"),CtoD("05/01/07"),CtoD("06/01/07"),CtoD("07/01/07"),CtoD("08/01/07"),CtoD("09/01/07"),CtoD("10/01/07")},;
					Replicate("M", 240),;
					{1333333.22},;
					{2333333.22},;
					{3333333.22},;
					{4333333.22},;
					{5333333.22},;
					{6333333.22},;
					{73333333.22},;
					{ "11", "22", "33", "44", "55", "66", "77", "88", "99" },;
					{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234", "6789012345", "7890123456", "8901234567", "9012345678" },;
					{ Replicate ("M", 60), Replicate ("A", 60), Replicate ("B", 60), Replicate ("C", 60), Replicate ("D", 60), Replicate ("E", 60), Replicate ("F", 60), Replicate ("G", 60), Replicate ("H", 60) },;
					{ 01, 1, 2, 03, 04, 05, 06, 7, 99 }, ;
					{ Replicate ("I", 40), Replicate ("J", 40), Replicate ("K", 40), Replicate ("L", 40), Replicate ("M", 40), Replicate ("N", 40), Replicate ("O", 40), Replicate ("P", 40), Replicate ("Q", 40) },;
					{ 999999.99, 111111.99, 222229.99, 333999.99, 444449.99, 555559.99, 666669,99, 777779.99, 888899.99 },;
					{ "11", "12", "13", "14", "15", "16", "17", "18", "19" },;
					{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234", "6789012345", "7890123456", "8901234567", "9012345678" },;
					{ Replicate ("A", 60), Replicate ("B", 60), Replicate ("C", 60), Replicate ("D", 60), Replicate ("E", 60), Replicate ("F", 60), Replicate ("G", 60), Replicate ("H", 60), Replicate ("I", 60) },;
					{ 01, 2, 3, 04, 05, 06, 07, 8, 99 }, ;
					{ Replicate ("J", 20), Replicate ("K", 20), Replicate ("L", 20), Replicate ("M", 20), Replicate ("N", 20), Replicate ("O", 20), Replicate ("P", 20), Replicate ("Q", 20), Replicate ("R", 20) },;
					{ 199999.99, 299999.99, 399999.99, 499999.99, 599999.99, 699999.99, 799.99, 899999.99, 99.99 },;
					{ 399999999.99, 499999999.99, 599999999.99, 699999.99, 799999.99, 899999.99, 99.99, 09.99, 19.99 },;
					{1999999.99},;
					CtoD("01/01/07"),;
					CtoD("02/01/07"),;
					CtoD("03/01/07"),;
					CtoD("04/01/07") } }

oFont01	:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Nao permite acionar a impressao quando for na web.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
if !lWeb
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
else
	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Tratamento para impressao via job
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//oPrint:lInJob  := lWeb
oPrint:lServer := lWeb
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Caminho do arquivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:cPathPDF := cPathSrvJ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Modo paisagem
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:SetLandscape()

if nLayout ==2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Papél A4
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(9)
Elseif nLayout ==3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Papél Carta
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(1)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPaperSize(14)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Device
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lWeb
	oPrint:setDevice(IMP_PDF)
	//oPrint:lPDFAsPNG := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄ
//³Verifica se existe alguma impressora configurada para Impressao Grafica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If  !lWeb
	oPrint:Setup()
	If !(oPrint:nModalResult == 1)
		Return
	Else
		lImpnovo:=(oPrint:nModalResult == 1)
	Endif
EndIf

If oPrint:nPaperSize  == 9 // Papél A4
	nLinMax	:=	2000
	nColMax	:=	3355 //3508 //3380 //3365
	nLayout 	:= 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
Elseif oPrint:nPaperSize == 1 // Papel Carta
	nLinMax	:=	2000
	nColMax	:=	3175
	nLayout 	:= 3
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	nLinMax	:=	2435
	nColMax	:=	3765
	nLayout 	:= 1
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
Endif

While lImpnovo

	lImpnovo:=.F.
	nVolta  += 1
	nT      += 5
	nT1     += 5
	nT2     +=10
	nT3     += 9
	nT4     += 9
	nProx   += 1

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 25 To 29
			If Len(aDados[nX, nI]) < nT
				For nJ := Len(aDados[nX, nI]) + 1 To nT
					If AllTrim(Str(nI)) $ "28,29"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 51 To 62
			If Len(aDados[nX, nI]) < nT1
				For nJ := Len(aDados[nX, nI]) + 1 To nT1
					If AllTrim(Str(nI)) $ "51"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "57,60,61,62"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 63 To 63
			If Len(aDados[nX, nI]) < nT2
				For nJ := Len(aDados[nX, nI]) + 1 To nT2
					aAdd(aDados[nX, nI], StoD(""))
				Next nJ
			EndIf
		Next nI

		For nI := 65 To 71
			If Len(aDados[nX, nI]) < nVolta
				For nJ := Len(aDados[nX, nI]) + 1 To nVolta
					If AllTrim(Str(nI)) $ "65,66,67,68,69,70,71"
						aAdd(aDados[nX, nI], 0)
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 72 To 77
			If Len(aDados[nX, nI]) < nT3
				For nJ := Len(aDados[nX, nI]) + 1 To nT3
					If AllTrim(Str(nI)) $ "75,77"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 78 To 84
			If Len(aDados[nX, nI]) < nT4
				For nJ := Len(aDados[nX, nI]) + 1 To nT4
					If AllTrim(Str(nI)) $ "81,83,84"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 85 To 85
			If Len(aDados[nX, nI]) < nVolta
				For nJ := Len(aDados[nX, nI]) + 1 To nVolta
					aAdd(aDados[nX, nI], 0)
				Next nJ
			EndIf
		Next nI
		If oPrint:Cprinter == "PDF" .OR. lWeb
			nLinIni	:= 150
			nLimFim	:= 400
		Else
			nLinIni	:= 060
			nLimFim	:= 230
		Endif


		nColIni		:= 068
		nColA4		:= 000
		nLinA4		:= 000
		nColSoma	:= 000
		nColSoma2	:= 000

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Inicia uma nova pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:StartPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLimFim + nLinMax)*nAL, (nColIni + nColMax)*nAC)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 	// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
			nColA4    := -0395
			nLinA4    := -0010
			nColSoma  := -0300
			nColSoma2 := -0190
		Elseif nLayout == 3// Carta
			nColA4    := -0590
			nLinA4    := -0010
			nColSoma  := -0300
			nColSoma2 := -0190
		Endif

		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 1702)*nAC + (nColA4/2), STR0060, oFont02n,,,, 2) //"GUIA DE SERVIÇO PROFISSIONAL / SERVIÇO AUXILIAR DE DIAGNÓSTICO E TERAPIA - SP/SADT"
		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 2930 + IIf (nLayout == 3,(nColA4/2+(nColSoma/3)),(nColA4/2)))*nAC, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 3026 + IIf (nLayout == 3,(nColA4/2+(nColSoma/3)),(nColA4/2)))*nAC, aDados[nX, 02], oFont03n)

		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 01], oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 0320			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 1035)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 0330			)*nAC, "3 - "+STR0061, oFont01) //"Nº Guia Principal"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 0340			)*nAC, aDados[nX, 03], oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 1040			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 1345)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 1050			)*nAC, "4 - "+STR0062, oFont01) //"Data da Autorização"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 1060			)*nAC, DtoC(aDados[nX, 04]), oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 1350			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 1755)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 1360			)*nAC, "5 - "+STR0063, oFont01) //"Senha"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 1370			)*nAC, aDados[nX, 05], oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 1760			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 2165)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 1770			)*nAC, "6 - "+STR0064, oFont01) //"Data Validade da Senha"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 1780			)*nAC, DtoC(aDados[nX, 06]), oFont04)
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 2170			)*nAC, (nLinIni + 0269)*nAL + nLinA4, (nColIni + 2465)*nAC)
		oPrint:Say((nLinIni + 0180 + nLinA4)*nAL, (nColIni + 2180			)*nAC, "7 - "+STR0004, oFont01) //"Data de Emissão da Guia"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 2190			)*nAC, DtoC(aDados[nX, 07]), oFont04)

		oPrint:Say((nLinIni + 0274 + nLinA4)*nAL, (nColIni + 0010			)*nAC, STR0005, oFont01) //"Dados do Beneficiário"
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 0425)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "8 - "+STR0006, oFont01) //"Número da Carteira"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 08], oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 0430			)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 1572 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 0440			)*nAC, "9 - "+STR0007, oFont01) //"Plano"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 0450			)*nAC, aDados[nX, 09], oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 1577 + nColA4	)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 1835 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 1587 + nColA4	)*nAC, "10 - "+STR0008, oFont01) //"Validade da Carteira"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 1597 + nColA4	)*nAC, DtoC(aDados[nX, 10]), oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 1840 + nColA4	)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 3290 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 1850 + nColA4	)*nAC, "11 - "+STR0009, oFont01) //"Nome"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 1860 + nColA4	)*nAC, SubStr(aDados[nX, 11], 1, 52), oFont04)
		oPrint:Box((nLinIni + 0304)*nAL + nLinA4, (nColIni + 3295 + nColA4	)*nAC, (nLinIni + 0398)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0309 + nLinA4)*nAL, (nColIni + 3305 + nColA4	)*nAC, "12 - "+STR0010, oFont01) //"Número do Cartão Nacional de Saúde"
		oPrint:Say((nLinIni + 0339 + nLinA4)*nAL, (nColIni + 3315 + nColA4	)*nAC, aDados[nX, 12], oFont04)

		oPrint:Say((nLinIni + 0403 + nLinA4)*nAL, (nColIni + 0010			)*nAC, STR0065, oFont01) //"Dados do Contratado Solicitante"
		oPrint:Box((nLinIni + 0433)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0527)*nAL + nLinA4, (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 0438 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "13 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say((nLinIni + 0468 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 13], oFont04)
		oPrint:Box((nLinIni + 0433)*nAL + nLinA4, (nColIni + 0431			)*nAC, (nLinIni + 0527)*nAL + nLinA4, (nColIni + 2245)*nAC)
		oPrint:Say((nLinIni + 0438 + nLinA4)*nAL, (nColIni + 0441			)*nAC, "14 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say((nLinIni + 0468 + nLinA4)*nAL, (nColIni + 0451			)*nAC, SubStr(aDados[nX, 14], 1, 65), oFont04)
		oPrint:Box((nLinIni + 0433)*nAL + nLinA4, (nColIni + 2250			)*nAC, (nLinIni + 0527)*nAL + nLinA4, (nColIni + 2480)*nAC)
		oPrint:Say((nLinIni + 0438 + nLinA4)*nAL, (nColIni + 2260			)*nAC, "15 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 0468 + nLinA4)*nAL, (nColIni + 2270			)*nAC, aDados[nX, 15], oFont04)

		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 1824)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "16 - "+STR0066, oFont01) //"Nome do Profissional Solicitante"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 0030			)*nAC, SubStr(aDados[nX, 16], 1, 66), oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 1829			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2122)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 1839			)*nAC, "17 - "+STR0022, oFont01) //"Conselho Profissional"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 1849			)*nAC, aDados[nX, 17], oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 2127			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2480)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 2137			)*nAC, "18 - "+STR0023, oFont01) //"Número no Conselho"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 2147			)*nAC, aDados[nX, 18], oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 2485			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2575)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 2495			)*nAC, "19 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 2505			)*nAC, aDados[nX, 19], oFont04)
		oPrint:Box((nLinIni + 0532)*nAL + nLinA4, (nColIni + 2580			)*nAC, (nLinIni + 0626)*nAL + nLinA4, (nColIni + 2790)*nAC)
		oPrint:Say((nLinIni + 0537 + nLinA4)*nAL, (nColIni + 2590			)*nAC, "20 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say((nLinIni + 0567 + nLinA4)*nAL, (nColIni + 2600			)*nAC, aDados[nX, 20], oFont04)

		oPrint:Say((nLinIni + 0631 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0067, oFont01) //"Dados da Solicitação / Procedimentos e Exames Solicitados"
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0020)*nAC, "21 - "+STR0068, oFont01) //"Data/Hora da Solicitação"
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 21,1]) + " " + Transform(aDados[nX, 21,2], "@R 99:99"), oFont04)
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0320)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 0735)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0330)*nAC, "22 - "+STR0069, oFont01) //"Caráter da Solicitação"
		oPrint:Line((nLinIni + 0691)*nAL+ nLinA4, 		(nColIni + 0340)*nAC, (nLinIni + 0728)*nAL + (nLinA4/2), (nColIni + 0340)*nAC)
		oPrint:Line((nLinIni + 0728)*nAL+ (nLinA4/2), 	(nColIni + 0340)*nAC, (nLinIni + 0728)*nAL + (nLinA4/2), (nColIni + 0387)*nAC)
		oPrint:Line((nLinIni + 0691)*nAL+ nLinA4, 		(nColIni + 0387)*nAC, (nLinIni + 0728)*nAL + (nLinA4/2), (nColIni + 0387)*nAC)
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0353)*nAC, aDados[nX, 22], oFont04)
		oPrint:Say((nLinIni + 0706 + nLinA4)*nAL, (nColIni + 0400)*nAC, STR0070+"  "+STR0071, oFont01) //"E-Eletiva"###"U-Urgência/Emergência"
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0740)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 0905)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0750)*nAC, "23 - "+STR0072, oFont01) //"CID 10"
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0760)*nAC, aDados[nX, 23], oFont04)
		oPrint:Box((nLinIni + 0661)*nAL + nLinA4, (nColIni + 0910)*nAC, (nLinIni + 0755)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0660 + nLinA4)*nAL, (nColIni + 0920)*nAC, "24 - "+STR0073, oFont01) //"Indicação Clínica (obrigatório se pequena cirurgia, terapia, consulta referenciada e alto custo)"
		oPrint:Say((nLinIni + 0696 + nLinA4)*nAL, (nColIni + 0930)*nAC, aDados[nX, 24], oFont04)

		oPrint:Box((nLinIni + 0760)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 1005)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "25 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 0150			)*nAC, "26 - "+STR0075, oFont01) //"Código do Procedimento"
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 0450			)*nAC, "27 - "+STR0076, oFont01) //"Descrição"
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 3400 + nColA4	)*nAC, "28 - "+STR0077, oFont01,,,,1) //"Qt.Solic."
		oPrint:Say((nLinIni + 0765 + nLinA4)*nAL, (nColIni + 3610 + nColA4	)*nAC, "29 - "+STR0078, oFont01,,,,1) //"Qt.Autoriz."

		nOldLinIni := nLinIni

		if nVolta = 1
			nV:=1
		Endif

		For nP := nV To nT
			if nVolta <> 1
				nN:=nP-((5*nVolta)-5)
				oPrint:Say((nLinIni + 0805 + nLinA4)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			else
				oPrint:Say((nLinIni + 0805 + nLinA4)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
			endif
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0065)*nAC			, aDados[nX, 25, nP], oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0150)*nAC			, aDados[nX, 26, nP], oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0450)*nAC			, aDados[nX, 27, nP], oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 3425 + nColA4)*nAC, IIf(Empty(aDados[nX, 28, nP]), "", Transform(aDados[nX, 28, nP], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 3635 + nColA4)*nAC, IIf(Empty(aDados[nX, 29, nP]), "", Transform(aDados[nX, 29, nP], "@E 9999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nP

		if nT < Len(aDados[nX, 26]).or. lImpnovo
			  nV:=nP
			  lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		oPrint:Say((nLinIni + 1000 + nLinA4)*nAL, (nColIni + 0010			)*nAC, STR0079, oFont01) //"Dados do Contratado Executante"
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 0010			)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 0416)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 0020			)*nAC, "30 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 0030			)*nAC, aDados[nX, 30], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 0421			)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 1316 + nColSoma)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 0431			)*nAC, "31 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 0441			)*nAC, SubStr(aDados[nX, 31], 1, 32), oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 1321 + nColSoma)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 1433 + nColSoma)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 1331 + nColSoma)*nAC, "32 - "+STR0015, oFont01) //"T.L."
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 1341 + nColSoma)*nAC, aDados[nX, 32], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 1438 + nColSoma)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 2413 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 1448 + nColSoma)*nAC, "33-34-35 - "+STR0016, oFont01) //"Logradouro - Número - Complemento"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 1458 + nColSoma)*nAC, SubStr(AllTrim(aDados[nX, 33]) + IIf(!Empty(aDados[nX, 34]), ", ","") + AllTrim(aDados[nX, 34]) + IIf(!Empty(aDados[nX, 35]), " - ","") + AllTrim(aDados[nX, 35]), 1, 35), oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 2418 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3023 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 2428 + nColA4	)*nAC, "36 - "+STR0017, oFont01) //"Município"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 2438 + nColA4	)*nAC, SubStr(aDados[nX, 36], 1, 21), oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3028 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3130 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3038 + nColA4	)*nAC, "37 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3048 + nColA4	)*nAC, aDados[nX, 37], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3135 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3320 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3145 + nColA4	)*nAC, "38 - "+STR0080, oFont01) //"Cód.IBGE"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3155 + nColA4	)*nAC, aDados[nX, 38], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3325 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3510 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3335 + nColA4	)*nAC, "39 - "+STR0020, oFont01) //"CEP"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3345 + nColA4	)*nAC, aDados[nX, 39], oFont04)
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 3515 + nColA4	)*nAC, (nLinIni + 1134)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1045 + nLinA4)*nAL, (nColIni + 3525 + nColA4	)*nAC, "40 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 3535 + nColA4	)*nAC, aDados[nX, 40, 1], oFont04)

		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 0590)*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 0020)*nAC, "40a - "+STR0081, oFont01) //"Código na Operadora / CPF do exec. complementar"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 0030)*nAC, SubStr(aDados[nX, 40, 2], 1, 68), oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 0595)*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 2436 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 0605)*nAC, "41 - "+STR0082, oFont01) //"Nome do Profissional Executante/Complementar"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 0615)*nAC, SubStr(aDados[nX, 41], 1, 68), oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 2441 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 2715 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 2451 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "42 - "+STR0022, oFont01) //"Conselho Profissional"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 2461 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 42], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 2720 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3055 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 2730 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "43 - "+STR0023, oFont01) //"Número no Conselho"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 2740 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 43], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 3060 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3160 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 3070 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "44 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 3080 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 44], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 3165 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3372 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 3175 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "45 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 3185 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 45, 1], oFont04)
		oPrint:Box((nLinIni + 1139)*nAL + nLinA4, (nColIni + 3377 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, (nLinIni + 1233)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1144 + nLinA4)*nAL, (nColIni + 3387 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, "45a - "+STR0083, oFont01) //"Grau de Participação"
		oPrint:Say((nLinIni + 1174 + nLinA4)*nAL, (nColIni + 3397 + IIf(nLayout == 2,nColA4,nColSoma+nColSoma2))*nAC, aDados[nX, 45, 2], oFont04)

		oPrint:Say((nLinIni + 1236 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0041, oFont01) //"Dados do Atendimento"
		oPrint:Box((nLinIni + 1268)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1362)*nAL + nLinA4, (nColIni + 1185)*nAC)
		oPrint:Say((nLinIni + 1273 + nLinA4)*nAL, (nColIni + 0020)*nAC, "46 - "+STR0084, oFont01) //"Tipo Atendimento"
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni + 1348)*nAL+ nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 0087)*nAC)
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 0087)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 0087)*nAC)
		oPrint:Say((nLinIni + 1303 + nLinA4)*nAL, (nColIni + 0043)*nAC, aDados[nX, 46], oFont04)
		oPrint:Say((nLinIni + 1298 + nLinA4)*nAL, (nColIni + 0100)*nAC, "01 - "+STR0085+"    "+"02 - "+STR0086+"    "+"03 - "+STR0087+"    "+"04 - "+STR0088+"    "+"05 - "+STR0089+"    "+"06 - "+STR0090, oFont01) //"Remoção"###"Pequena Cirurgia"###"Terapias"###"Consulta"###"Exame"###"Atendimento Domiciliar"
		oPrint:Say((nLinIni + 1328 + nLinA4)*nAL, (nColIni + 0100)*nAC, "07 - "+STR0091+"    "+"08 - "+STR0092+"    "+"09 - "+STR0093+"    "+"10 - "+STR0094, oFont01) //"SADT Internado"###"Quimioterapia"###"Radioterapia"###"TRS-Terapia Renal Substitutiva"
		oPrint:Box((nLinIni + 1268)*nAL + nLinA4, (nColIni + 1190)*nAC, (nLinIni + 1362)*nAL + nLinA4, (nColIni + 2450 + nColA4/2)*nAC)
		oPrint:Say((nLinIni + 1273 + nLinA4)*nAL, (nColIni + 1200)*nAC, "47 - "+STR0033, oFont01) //"Indicação de Acidente"
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 1210)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 1210)*nAC)
		oPrint:Line((nLinIni + 1348)*nAL+ nLinA4, (nColIni + 1210)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 1257)*nAC)
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 1257)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 1257)*nAC)
		oPrint:Say((nLinIni + 1303 + nLinA4)*nAL, (nColIni + 1223)*nAC, aDados[nX, 47], oFont04)
		oPrint:Say((nLinIni + 1313 + nLinA4)*nAL, (nColIni + 1270)*nAC, "0 - "+STR0034+"   "+"1 - "+STR0035+"   "+"2 - "+STR0036, oFont01) //"Acidente ou doença relacionado ao trabalho"###"Trânsito"###"Outros"
		oPrint:Box((nLinIni + 1268)*nAL + nLinA4, (nColIni + 2455 + nColA4/2)*nAC, (nLinIni + 1362)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1273 + nLinA4)*nAL, (nColIni + 2465 + nColA4/2)*nAC, "48 - "+STR0050, oFont01) //"Tipo de Saída"
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 2475 + nColA4/2)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 2475 + nColA4/2)*nAC)
		oPrint:Line((nLinIni + 1348)*nAL+ nLinA4, (nColIni + 2475 + nColA4/2)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 2522 + nColA4/2)*nAC)
		oPrint:Line((nLinIni + 1298)*nAL+ nLinA4, (nColIni + 2522 + nColA4/2)*nAC, (nLinIni + 1348)*nAL + nLinA4, (nColIni + 2522 + nColA4/2)*nAC)
		oPrint:Say((nLinIni + 1303 + nLinA4)*nAL, (nColIni + 2488 + nColA4/2)*nAC, aDados[nX, 48], oFont04)
		oPrint:Say((nLinIni + 1313 + nLinA4)*nAL, (nColIni + 2535 + nColA4/2)*nAC, "1 - "+STR0051+"    "+"2 - "+STR0052+"    "+"3 - "+STR0053+"    "+"4 - "+STR0054+"    "+"5 - "+STR0055+"    "+"6 - "+STR0095, oFont01) //"Retorno"###"Retorno SADT"###"Referência"###"Internação"###"Alta"###"Óbito"

		oPrint:Say((nLinIni + 1367 + nLinA4)*nAL , (nColIni + 0010)*nAC, STR0096, oFont01) //"Consulta Referência"
		oPrint:Box((nLinIni + 1397)*nAL + nLinA4 , (nColIni + 0010)*nAC, (nLinIni + 1491)*nAL + nLinA4, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 1402 + nLinA4)*nAL , (nColIni + 0020)*nAC, "49 - "+STR0026, oFont01) //"Tipo de Doença"
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni + 1477)*nAL + nLinA4, (nColIni + 0030)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0077)*nAC)
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0077)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0077)*nAC)
		oPrint:Say((nLinIni + 1432  + nLinA4)*nAL, (nColIni + 0043)*nAC, aDados[nX, 49], oFont04)
		oPrint:Say((nLinIni + 1442  + nLinA4)*nAL, (nColIni + 0090)*nAC, STR0027+"    "+STR0028, oFont01) //"A-Aguda"###"C-Crônica"
		oPrint:Box((nLinIni + 1397)*nAL  + nLinA4, (nColIni + 0320)*nAC, (nLinIni + 1491)*nAL + nLinA4, (nColIni + 0770)*nAC)
		oPrint:Say((nLinIni + 1402  + nLinA4)*nAL, (nColIni + 0330)*nAC, "50 - "+STR0029, oFont01) //"Tempo de Doença"
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0340)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0340)*nAC)
		oPrint:Line((nLinIni + 1477)*nAL + nLinA4, (nColIni + 0340)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0426)*nAC)
		oPrint:Line((nLinIni + 1427)*nAL + nLinA4, (nColIni + 0426)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0426)*nAC)
		If aDados[nX,50,1] > 0
			oPrint:Say((nLinIni + 1432 + nLinA4)*nAL, (nColIni + 0353)*nAC, IIF((StrZero(aDados[nX, 50,1], 2, 0))=="00","",(StrZero(aDados[nX, 50,1], 2, 0))), oFont04)
		Endif
		oPrint:Say((nLinIni + 1442 + nLinA4)*nAL, (nColIni + 0434)*nAC, "-", oFont01)
		oPrint:Line((nLinIni+ 1427)*nAL + nLinA4, (nColIni + 0447)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0447)*nAC)
		oPrint:Line((nLinIni+ 1477)*nAL + nLinA4, (nColIni + 0447)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0494)*nAC)
		oPrint:Line((nLinIni+ 1427)*nAL + nLinA4, (nColIni + 0494)*nAC, (nLinIni + 1477)*nAL + nLinA4, (nColIni + 0494)*nAC)
		oPrint:Say((nLinIni + 1432 + nLinA4)*nAL, (nColIni + 0457)*nAC, aDados[nX, 50,2], oFont04)
		oPrint:Say((nLinIni + 1442 + nLinA4)*nAL, (nColIni + 0510)*nAC, STR0030+"  "+STR0031+"  "+STR0032, oFont01) //"A-Anos"###"M-Meses"###"D-Dias"

		oPrint:Say((nLinIni + 1478 + nLinA4)*nAL, (nColIni + 0010)*nAC, STR0097, oFont01) //"Procedimentos e Exames realizados"
		oPrint:Box((nLinIni + 1526)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1766)*nAL + nLinA4, (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0020)*nAC, "51 - "+STR0098, oFont01) //"Data"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0210)*nAC, "52 - "+STR0099, oFont01) //"Hora Inicial"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0380)*nAC, "53 - "+STR0100, oFont01) //"Hora Final"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0540)*nAC, "54 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0660)*nAC, "55 - "+STR0075, oFont01) //"Código do Procedimento"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 0940)*nAC, "56 - "+STR0076, oFont01) //"Descrição"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 3675)*nAC + nColA4, "57 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 3795)*nAC + nColA4, "58 - "+STR0102, oFont01) //"Via"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4040)*nAC + nColA4, "59 - "+STR0103, oFont01) //"Tec."
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4260)*nAC + nColA4, "60 - "+STR0104, oFont01,,,,1) //"% Red./Acresc."
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4500)*nAC + nColA4, "61 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say((nLinIni + 1531 + nLinA4)*nAL, (nColIni + 4745)*nAC + nColA4, "62 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nV1:=1
		Endif

		If lPLSGTISS
			lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"02",lImpPrc})
		EndIf

		If lImpPrc

			For nP1 := nV1 To nT1
				if nVolta <> 1
					nN:=nP1-((5*nVolta)-5)
					oPrint:Say((nLinIni + 1566 + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
				else
					oPrint:Say((nLinIni + 1566 + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP1)) + " - ", oFont01)
				endif
					oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0065)*nAC, IIf(Empty(aDados[nX, 51, nP1]), "", DtoC(aDados[nX, 51, nP1])), oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0210)*nAC, IIf(Empty(aDados[nX, 52, nP1]), "", Transform(aDados[nX, 52, nP1], "@R 99:99")), oFont04)
			 	oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0380)*nAC, IIf(Empty(aDados[nX, 53, nP1]), "", Transform(aDados[nX, 53, nP1], "@R 99:99")), oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0540)*nAC, aDados[nX, 54, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0660)*nAC, aDados[nX, 55, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 0940)*nAC, SUBSTR(aDados[nX, 56, nP1],1,51), oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 2445 + nColA4)*nAC, IIf(Empty(aDados[nX, 57, nP1]), "", Transform(aDados[nX, 57, nP1], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 2560 + nColA4)*nAC, aDados[nX, 58, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 2840 + nColA4)*nAC, aDados[nX, 59, nP1], oFont04)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 3050 + nColA4)*nAC, IIf(Empty(aDados[nX, 60, nP1]), "", Transform(aDados[nX, 60, nP1], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 3240 + nColA4)*nAC, IIf(Empty(aDados[nX, 61, nP1]), "", Transform(aDados[nX, 61, nP1], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 1561 + nLinA4)*nAL, (nColIni + 3510 + nColA4)*nAC, IIf(Empty(aDados[nX, 62, nP1]), "", Transform(aDados[nX, 62, nP1], "@E 99,999,999.99")), oFont04,,,,1)
				nLinIni += 40
			Next nP1

		EndIf

		if nT1 < Len(aDados[nX, 55]).or. lImpnovo
			  nV1:=nP1
			  lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		oPrint:Box((nLinIni + 1771)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1971)*nAL + (2*nLinA4), (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1766 + nLinA4)*nAL, (nColIni + 0020)*nAC, "63 - "+STR0107, oFont01) //"Data e Assinatura de Procedimentos em Série"

		nOldColIni := nColIni

		if nVolta=1
			nV2:=1
		Endif

		For nP2 := nV2 To nT2 Step 2
			if nVolta <> 1
				nN:=nP2-((10*nVolta)-10)
				oPrint:Say((nLinIni + 1816 + nLinA4)*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 1816 + nLinA4)*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nP2)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 1816 + nLinA4)*nAL, (nColIni + 0070)*nAC, DtoC(aDados[nX, 63, nP2]), oFont04)
			oPrint:Line((nLinIni + 1861)*nAL + nLinA4,(nColIni + 0230)*nAC, (nLinIni + 1861)*nAL + nLinA4, (nColIni + 0757 + nColSoma2)*nAC)
			if nLayout ==1
				nColIni += 727
			Elseif nLayout ==2
				nColIni += 670
			Else
				nColIni += 630
			Endif
		Next nP2

		nColIni := nOldColIni

		nOldColIni := nColIni

		if nVolta=1
			nV2:=1
		Endif

		For nP2 := nV2+1 To nT2+1 Step 2
			if nVolta <> 1
				nN:=nP2-((10*nVolta)-10)
				oPrint:Say((nLinIni + 1890 + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 1890 + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, AllTrim(Str(nP2)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 1890 + (2*nLinA4))*nAL, (nColIni + 0070)*nAC, DtoC(aDados[nX, 63, nP2]), oFont04)
			oPrint:Line((nLinIni + 1945)*nAL + (2*nLinA4),(nColIni + 0230)*nAC, (nLinIni + 1945)*nAL + (2*nLinA4), (nColIni + 0757 + nColSoma2)*nAC)
			if nLayout ==1
				nColIni += 727
			Elseif nLayout ==2
				nColIni += 670
			Else
				nColIni += 630
			Endif
		Next nP2

		nColIni := nOldColIni

	    if nT2 < Len(aDados[nX, 63]).or. lImpnovo
			  nV2:=nP2-1
			  lImpnovo:=.T.
		Endif

		oPrint:Box((nLinIni + 1976)*nAL + (2*nLinA4), (nColIni + 0010)*nAC, (nLinIni + 2136)*nAL + (3*nLinA4), (nColIni + 3745 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1950 + (2*nLinA4))*nAL, (nColIni + 0020)*nAC, "64 - "+STR0056, oFont01) //"Observação"

		If nModulo == 51    //Gestão Hospitalar
			if nVolta=1
				nV1:=1
			Endif

			nLin := 1988
			For nP1 := nV1 To nT1
				if nVolta <> 1
					nN:=nP1-((5*nVolta)-5)
					oPrint:Say((nLinIni + nLin + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
				else
					oPrint:Say((nLinIni + nLin + nLinA4)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP1)) + " - ", oFont01)
				endif
				oPrint:Say((nLinIni + nLin + nLinA4)*nAL, (nColIni + 0065)*nAC, aDados[nX, 64, nP1], oFont04)

				nLin += 35
			Next nP1

			if nT1 < Len(aDados[nX, 64]).or. lImpnovo
				  nV1:=nP1
				  lImpnovo:=.T.
			Endif
		Else
			nLin := 1991

			For nI := 1 To MlCount(aDados[nX, 64], 130)
				cObs := MemoLine(aDados[nX, 64], 130, nI)
				oPrint:Say((nLinIni + nLin + (2*nLinA4))*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
				nLin += 35
			Next nI

		Endif
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 0010)*nAC			 		, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 0591 + (nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 0020)*nAC				 	, "65 - "+STR0108, oFont01) //"Total Procedimentos R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 0220 + (nColA4/6))*nAC 	, Transform(aDados[nX, 65,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 0596 + (nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 1117 + 2*(nColA4/7))*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 0606 + (nColA4/7))*nAC	, "66 - "+STR0109, oFont01) //"Total Taxas e Aluguéis R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 0806 + 2*(nColA4/6))*nAC	, Transform(aDados[nX, 66,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 1122 + 2*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 1643  + 3*(nColA4/7))*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 1132 + 2*(nColA4/7))*nAC	, "67 - "+STR0110, oFont01) //"Total Materiais R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 1332 + 3*(nColA4/6))*nAC	, Transform(aDados[nX, 67,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 1648 + 3*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 2169 + 4*(nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 1658 + 3*(nColA4/7))*nAC	, "68 - "+STR0111, oFont01) //"Total Medicamentos R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 1858 + 4*(nColA4/6))*nAC	, Transform(aDados[nX, 68,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 2174 + 4*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 2695 + 5*(nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 2184 + 4*(nColA4/7))*nAC	, "69 - "+STR0112, oFont01) //"Total Diárias R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 2384 + 5*(nColA4/6))*nAC	, Transform(aDados[nX, 69,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 2700 + 5*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 3221 + 6*(nColA4/7) )*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 2710 + 5*(nColA4/7))*nAC	, "70 - "+STR0113, oFont01) //"Total Gases Medicinais R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 2910 + 6*(nColA4/6))*nAC	, Transform(aDados[nX, 70,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box((nLinIni + 2141)*nAL + (3*nLinA4), (nColIni + 3226 + 6*(nColA4/7))*nAC	, (nLinIni + 2235)*nAL + (3*nLinA4), (nColIni + 3745  + 7*(nColA4/7))*nAC)
		oPrint:Say((nLinIni + 2159)*nAL + (3*nLinA4), (nColIni + 3236 + 6*(nColA4/7))*nAC	, "71 - "+STR0114, oFont01) //"Total Geral da Guia R$"
		oPrint:Say((nLinIni + 2210)*nAL + (3*nLinA4), (nColIni + 3436 + 7*(nColA4/6))*nAC	, Transform(aDados[nX, 71,nProx], "@E 999,999,999.99"), oFont04,,,,1)


		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 0010)*nAC					, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 0986 + (nColA4/4) )*nAC)
	   	oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 0020)*nAC 				, "86 - "+STR0115, oFont01) //"Data e Assinatura do Solicitante"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 0030)*nAC 				, DtoC(aDados[nX, 86]), oFont04)
		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 0991  +(nColA4/4))*nAC	, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 1907 + 2*(nColA4/4) )*nAC)
		oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 1001  +(nColA4/4))*nAC	, "87 - "+STR0116, oFont01) //"Data e Assinatura do Responsável pela Autorização"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 1011  +(nColA4/4))*nAC	, DtoC(aDados[nX, 87]), oFont04)
		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 1912  +2*(nColA4/4))*nAC	, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 2828 + 3*(nColA4/4) )*nAC)
		oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 1922  +2*(nColA4/4))*nAC	, "88 - "+STR0058, oFont01) //"Data e Assinatura do Beneficiário ou Responsável"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 1932  +2*(nColA4/4))*nAC	, DtoC(aDados[nX, 88]), oFont04)
		oPrint:Box((nLinIni + 2240)*nAL + (3*nLinA4), (nColIni + 2833  +3*(nColA4/4))*nAC	, (nLinIni + 2385)*nAL + (4*nLinA4), (nColIni + 3745 + 4*(nColA4/4) )*nAC)
		oPrint:Say((nLinIni + 2185 + (4*nLinA4))*nAL, (nColIni + 2843  +3*(nColA4/4))*nAC	, "89 - "+STR0117, oFont01) //"Data e Assinatura do Prestador Executante"
		oPrint:Say((nLinIni + 2225 + (4*nLinA4))*nAL, (nColIni + 2853  +3*(nColA4/4))*nAC	, DtoC(aDados[nX, 89]), oFont04)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Finaliza a pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:EndPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Verso da Guia - Inicia uma nova pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		/*
		oPrint:StartPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

		oPrint:Box((nLinIni + 0010)*nAL, (nColIni + 0010)*nAC			, (nLinIni + 0490)*nAL, (nColIni + 3755 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0030)*nAL, (nColIni + 0020)*nAC			, STR0118, oFont01) //"OPM Solicitados"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 0020)*nAC			, "72 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 0160)*nAC			, "73 - "+STR0119, oFont01) //"Código do OPM"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 0410)*nAC		 	, "74 - "+STR0120, oFont01) //"Descrição OPM"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 2400 + nColA4)*nAC	, "75 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 2550 + nColA4)*nAC	, "76 - "+STR0121, oFont01) //"Fabricante"
		oPrint:Say((nLinIni + 0065)*nAL, (nColIni + 3530 + nColA4)*nAC	, "77 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nV3:=1
		Endif

		For nP3 := nV3 To nT3
			if nVolta <> 1
				nN:=nP3-((9*nVolta)-9)
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP3)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0065)*nAC			, aDados[nX, 72, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0160)*nAC			, aDados[nX, 73, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 0410)*nAC			, aDados[nX, 74, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 2400 + nColA4)*nAC	, IIf(Empty(aDados[nX, 75, nP3]), "", Transform(aDados[nX, 75, nP3], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 2550 + nColA4)*nAC	, aDados[nX, 76, nP3], oFont04)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + 3550 + nColA4)*nAC	, IIf(Empty(aDados[nX, 77, nP3]), "", Transform(aDados[nX, 77, nP3], "@E 999,999,999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nP3

		nLinIni := nOldLinIni

	    if nT3 < Len(aDados[nX, 73]).or. lImpnovo
			  nV3:=nP3
			  lImpnovo:=.T.
		Endif

		oPrint:Box((nLinIni + 0495)*nAL, (nColIni + 0010)*nAC			, (nLinIni + 0990)*nAL, (nColIni + 3755 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0515)*nAL, (nColIni + 0020)*nAC			, STR0122, oFont01) //"OPM Utilizados"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0020)*nAC			, "78 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0160)*nAC			, "79 - "+STR0119, oFont01) //"Código do OPM"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0410)*nAC			, "80 - "+STR0120, oFont01) //"Descrição OPM"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 2400 + nColA4)*nAC	, "81 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 2550 + nColA4)*nAC	, "82 - "+STR0123, oFont01) //"Código de Barras"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 3250 + nColA4)*nAC	, "83 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 3560 + nColA4)*nAC	, "84 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nV4:=1
		Endif

		For nP4 := nV4 To nT4
			if nVolta <> 1
				nN:=nP4-((9*nVolta)-9)
				oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP4)) + " - ", oFont01)
			Endif
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0065)*nAC			, aDados[nX, 78, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0160)*nAC			, aDados[nX, 79, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 0410)*nAC			, aDados[nX, 80, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 2400 + nColA4)*nAC	, IIf(Empty(aDados[nX, 81, nP4]), "", Transform(aDados[nX, 81, nP4], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 2550 + nColA4)*nAC	, aDados[nX, 82, nP4], oFont04)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 3260 + nColA4)*nAC	, IIf(Empty(aDados[nX, 83, nP4]), "", Transform(aDados[nX, 83, nP4], "@E 999,999,999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0585)*nAL, (nColIni + 3540 + nColA4)*nAC	, IIf(Empty(aDados[nX, 84, nP4]), "", Transform(aDados[nX, 84, nP4], "@E 999,999,999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nP4

		nLinIni := nOldLinIni

	    nTotOPM:=nV4

	    if nT4 < Len(aDados[nX, 79]).or. lImpnovo
			  nV4:=nP4
			  lImpnovo:=.T.
		Endif

		oPrint:Box((nLinIni + 1005)*nAL, (nColIni + 3395 + nColA4)*nAC, (nLinIni + 1089)*nAL, (nColIni + 3755 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1025)*nAL, (nColIni + 3405 + nColA4)*nAC, "85 - "+STR0124, oFont01) //"Total OPM R$"
		oPrint:Say((nLinIni + 1055)*nAL, (nColIni + 3555 + nColA4)*nAC, Transform(aDados[nX, 85,nProx], "@E 999,999,999.99"), oFont04,,,,1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Finaliza a pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	   	oPrint:EndPage()
		*/
	Next nX
EndDo

If lGerTXT .And. !lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Imprime Relatorio
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Print()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Visualiza impressao grafica antes de imprimir
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Print()
EndIf

Return(cFileName)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS3  ³ Autor ³ Luciano Aparecido     ³ Data ³ 08.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Sol. Internaçao)-BOPS 095189 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela 	   ³±±
±±³          ³			 de configuracao/preview do relatorio 		       ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISS3(aDados, lGerTXT, nLayout, cLogoGH, lMail, lWeb, cPathRelW )
	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0	// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0	// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local nLinA4    :=  0
	Local cFileLogo
	Local nLin
	Local nP:=0
	Local nT:=0
	Local nT1:=0
	Local nT3:=0
	Local nI,nJ,nK,nX
	Local nR,nV,nV1,nV2,nN
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local oPrint    := Nil
	Local lImpnovo  :=.T.
	Local nVolta    :=0
	Local cFile 	:= GetNewPar("MV_RELT",'\SPOOL\')+'PLSR420N.HTM'
	Local lRet		:= .T.
	Local lOk		:= .T.
	LOCAL cFileName	:= ""
	LOCAL cRel      := "GUICONS"
	LOCAL cPathSrvJ := GETMV("MV_RELT")
	LOCAL nAL		:= 0.25
	LOCAL nAC		:= 0.24
	Local lImpPrc   := .T.
	Local lPLSGTISS	:= ExistBlock("PLSGTISS")
	
	DEFAULT lGerTXT 	:= .F.
	DEFAULT nLayout 	:= 2
	DEFAULT cLogoGH 	:= ""
	DEFAULT lMail		:= .F.
	DEFAULT lWeb		:= .F.
	DEFAULT cPathRelW 	:= ""
	DEFAULT aDados 	:= { { ;
						"123456",;
						"12345678901234567892",;
						CtoD("01/01/07"),;
						"12345678901234567892",;
						CtoD("01/01/07"),;
						CtoD("01/01/07"),;
						"12345678901234567892",;
						Replicate("M",40),;
						CtoD("12/12/07"),;
						Replicate("M",70),;
						"123456789102345",;
						"14.141.114/00001-35",;
						Replicate("M",70),;
						"1234567",;
						Replicate("M",70),;
						"1234567",;
						"123456789102345",;
						"ES",;
						"12345",;
						"14.141.114/00001-35",;
						Replicate("M",70),;
						"U",;
						"1",;
						"1",;
						999,;
						Replicate("M",500),;
						"A",;
						{ 12,"M" },;
						"0",;
						"12345",;
						"22345",;
						"32345",;
						"42345",;
						{ "10","20","30","40","50" },;
						{ "1234567890","2345678901","3456789012","4567890123","5678901234" },;
						{ Replicate("M",60),Replicate("A",60),Replicate("B",60),Replicate("C",60),Replicate("D",60) },;
						{ 01,02,03,04,99 },;
						{ 05,06,07,08,09 },;
						{ "10","20","30","40","50" },;
						{ "1234567890","2345678901","3456789012","4567890123","5678901234" },;
						{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60) },;
						{ 99,99,99,99,99 },;
						{ Replicate("M",40),Replicate("B",40),Replicate("C",40),Replicate("D",40),Replicate("E",40) },;
						{ 199999999.99,999999999.99,299999999.99,3.99,49.99 },;
						CtoD("12/01/06"),;
						999,;
						{ "01", "APARTAMENTO" },;
						"14.141.114/00001-35",;
						Replicate("M",70),;
						"1234567",;
						Replicate("M",240),;
						CtoD("12/01/06"),;
						CtoD("12/02/06"),;
						CtoD("12/02/06"),;
						{ CtoD("12/01/06"),CtoD("12/02/06"),CtoD("12/03/06") },;
						{ "12345678910234567892","23456789102345678921","34567891023456789212" },;
						{ Replicate("M",70),Replicate("B",70),Replicate("C",70) },;
						{ "01","02","03" },;
						{ Replicate("M",40),Replicate("B",40),Replicate("C",40) },;
						{ 01,02,99 },;
						{ { "01","02" },{ "03","04" },{ "05","06" } },;
						{ { "1234567891","2345678911" },{ "3456789112","4567891123" },{ "5678911234","6789112345" } },;
						{ { Replicate("M",60),Replicate("A",60) },{ Replicate("B",60),Replicate("C",60) },{ Replicate("D",60),Replicate("E",60) } },;
						{ { 01,02 },{ 03,04 },{ 05,06 } },;
						{ { 07,08 },{ 09,10 },{ 11,99 } },;
						{ { "01","02" },{ "03","04" },{ "05","06" } },;
						{ { "1234567891","2345678911" },{ "3456789112","4567891123" },{ "5678911234","6789112345" } },;
						{ { Replicate("M",60),Replicate("A",60) },{ Replicate("B",60),Replicate("C",60) },{ Replicate("D",60),Replicate("E",60) } },;
						{ { 07,08 },{ 09,10 },{ 11,99 } },;
						{ { Replicate("F",40),Replicate("G",40) },{ Replicate("H",40),Replicate("I",40) },{ Replicate("J",40),Replicate("K",40) } },;
						{ { 199999.99, 299999.99 },{ 399999.99, 499999.99 },{ 599999.99, 999999.99 } } } }

	If nLayout  == 1 // Ofício 2
	 	nLinMax	:=	3705	// Numero maximo de Linhas (31,5 cm)
		nColMax	:=	2400	// Numero maximo de Colunas (21 cm)
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	3225
		nColMax	:=	2335
	Else //Carta
		nLinMax	:=	3155
		nColMax	:=	2400
	Endif

	oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
		oFont02n := TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n := TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04	 := TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+CriaTrab(NIL,.F.)+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
	If !lWeb
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
	Else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//oPrint:lInJob  := lWeb
	oPrint:lServer := lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Modo retrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:SetPortrait()	// Modo retrato

	If nLayout ==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Papél A4
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:SetPaperSize(9)
	ElseIf nLayout ==3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Papél Carta
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:SetPaperSize(1)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:SetPaperSize(14)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If  !lWeb
		oPrint:Setup()
		If (oPrint:nModalResult == 2)
			lRet := .F.
			lMail := .F.
			Return()
		Else
			lImpnovo:=(oPrint:nModalResult == 1)
		Endif
	EndIf


While lImpnovo

	lImpnovo:=.F.
	nVolta  += 1
	nT      += 5
	nT1     += 2
	nT3     += 3


	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 34 To 38
			If Len(aDados[nX, nI]) < nT
				For nJ := Len(aDados[nX, nI]) + 1 To nT
					If AllTrim(Str(nI)) $ "37,38"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 39 To 44
			If Len(aDados[nX, nI]) < nT
				For nJ := Len(aDados[nX, nI]) + 1 To nT
					If AllTrim(Str(nI)) $ "42,44"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 55 To 71
			If Len(aDados[nX, nI]) < nT3
				For nJ := Len(aDados[nX, nI]) + 1 To nT3
					If AllTrim(Str(nI)) $ "55"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "60"
						aAdd(aDados[nX, nI], 0)
					ElseIf AllTrim(Str(nI)) $ "56,57,58,59"
						aAdd(aDados[nX, nI], "")
					Else
						aAdd(aDados[nX, nI], {})
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 61 To 71
			For nK := 1 To nT3
				If Len(aDados[nX, nI, nK]) < nT1
					For nJ := Len(aDados[nX, nI, nK]) + 1 To nT1
						If AllTrim(Str(nI)) $ "64,65,69,71"
							aAdd(aDados[nX, nI, nK], 0)
						Else
							aAdd(aDados[nX, nI, nK], "")
						EndIf
					Next nJ
				EndIf
			Next nK
		Next nI

		If oPrint:Cprinter == "PDF" .OR. lWeb
			nLinIni	:= 150
		Else
			nLinIni := 000
		Endif

		nColIni := 000
		nColA4  := 000
		nLinA4  := 000

		oPrint:StartPage()		// Inicia uma nova pagina

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
			nColA4    := -0065
		Elseif nLayout == 3// Carta
			nLinA4    := -0085
		Endif

		oPrint:Say((nLinIni + 0120)*nAL, (nColIni + 0975 + nColA4)*nAC, STR0126, oFont02n,,,, 2) //"GUIA DE SOLICITAÇÃO"
		oPrint:Say((nLinIni + 0170)*nAL, (nColIni + 1030 + nColA4)*nAC, STR0127, oFont02n,,,, 2) //"DE INTERNAÇÃO"
		oPrint:Say((nLinIni + 0120)*nAL, (nColIni + 1705 + nColA4)*nAC, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say((nLinIni + 0120)*nAL, (nColIni + 1801 + nColA4)*nAC, aDados[nX, 02], oFont03n)

		nLinIni+= 150
		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0249)*nAL, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0030)*nAC, aDados[nX, 01], oFont04)
		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0320)*nAC, (nLinIni + 0249)*nAL, (nColIni + 0625)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0330)*nAC, "3 - "+STR0062, oFont01) //"Data da Autorização"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0340)*nAC, DtoC(aDados[nX, 03]), oFont04)
		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0630)*nAC, (nLinIni + 0249)*nAL, (nColIni + 1035)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0640)*nAC, "4 - "+STR0063, oFont01) //"Senha"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0650)*nAC, aDados[nX, 04], oFont04)
		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 1040)*nAC, (nLinIni + 0249)*nAL, (nColIni + 1445)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 1050)*nAC, "5 - "+STR0064, oFont01) //"Data Validade da Senha"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 1060)*nAC, DtoC(aDados[nX, 05]), oFont04)
		oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 1450)*nAC, (nLinIni + 0249)*nAL, (nColIni + 1745)*nAC)
		oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 1460)*nAC, "6 - "+STR0004, oFont01) //"Data de Emissão da Guia"
		oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 1470)*nAC, DtoC(aDados[nX, 06]), oFont04)

		nLinIni += 20
		oPrint:Say((nLinIni + 0274)*nAL, (nColIni + 0010)*nAC, STR0005, oFont01) //"Dados do Beneficiário"
		oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0378)*nAL, (nColIni + 0425)*nAC)
		oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 0020)*nAC, "7 - "+STR0006, oFont01) //"Número da Carteira"
		oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 0030)*nAC, aDados[nX, 07], oFont04)
		oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 0430)*nAC, (nLinIni + 0378)*nAL, (nColIni + 1542)*nAC)
		oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 0440)*nAC, "8 - "+STR0007, oFont01) //"Plano"
		oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 0450)*nAC, aDados[nX, 08], oFont04)
		oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 1547)*nAC, (nLinIni + 0378)*nAL, (nColIni + 1835)*nAC)
		oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 1557)*nAC, "9 - "+STR0008, oFont01) //"Validade da Carteira"
		oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 1567)*nAC, DtoC(aDados[nX, 09]), oFont04)

		oPrint:Box((nLinIni + 0383)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0477)*nAL, (nColIni + 1965 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0407)*nAL, (nColIni + 0020)*nAC, "10 - "+STR0009, oFont01) //"Nome"
		oPrint:Say((nLinIni + 0447)*nAL, (nColIni + 0030)*nAC, aDados[nX, 10], oFont04)
		oPrint:Box((nLinIni + 0383)*nAL, (nColIni + 1970 + nColA4)*nAC, (nLinIni + 0477)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0407)*nAL, (nColIni + 1980 + nColA4)*nAC, "11 - "+STR0010, oFont01) //"Número do Cartão Nacional de Saúde"
		oPrint:Say((nLinIni + 0447)*nAL, (nColIni + 1990 + nColA4)*nAC, aDados[nX, 11], oFont04)

		nLinIni += 20
		oPrint:Say((nLinIni + 0502)*nAL, (nColIni + 0010)*nAC, STR0065, oFont01) //"Dados do Contratado Solicitante"
		oPrint:Box((nLinIni + 0512)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0606)*nAL, (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 0537)*nAL, (nColIni + 0020)*nAC, "12 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say((nLinIni + 0577)*nAL, (nColIni + 0030)*nAC, aDados[nX, 12], oFont04)
		oPrint:Box((nLinIni + 0512)*nAL, (nColIni + 0431)*nAC, (nLinIni + 0606)*nAL, (nColIni + 2175 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0537)*nAL, (nColIni + 0441)*nAC, "13 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say((nLinIni + 0577)*nAL, (nColIni + 0451)*nAC, SubStr(aDados[nX, 13], 1, 65), oFont04)
		oPrint:Box((nLinIni + 0512)*nAL, (nColIni + 2180 + nColA4)*nAC, (nLinIni + 0606)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0537)*nAL, (nColIni + 2190 + nColA4)*nAC, "14 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 0577)*nAL, (nColIni + 2200 + nColA4)*nAC, aDados[nX, 14], oFont04)

		oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0705)*nAL, (nColIni + 1459 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 0020)*nAC, "15 - "+STR0066, oFont01) //"Nome do Profissional Solicitante"
		oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 0030)*nAC, SubStr(aDados[nX, 15], 1, 55), oFont04)
		oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 1464 + nColA4)*nAC, (nLinIni + 0705)*nAL, (nColIni + 1737 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 1474 + nColA4)*nAC, "16 - "+STR0022, oFont01) //"Conselho Profissional"
		oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 1484 + nColA4)*nAC, aDados[nX, 16], oFont04)
		oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 1742 + nColA4)*nAC, (nLinIni + 0705)*nAL, (nColIni + 2056 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 1752 + nColA4)*nAC, "17 - "+STR0023, oFont01) //"Número no Conselho"
		oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 1762 + nColA4)*nAC, aDados[nX, 17], oFont04)
		oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 2061 + nColA4)*nAC, (nLinIni + 0705)*nAL, (nColIni + 2160 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 2071 + nColA4)*nAC, "18 - "+STR0018, oFont01) //"UF"
		oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 2081 + nColA4)*nAC, aDados[nX, 18], oFont04)
		oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 2165 + nColA4)*nAC, (nLinIni + 0705)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 2175 + nColA4)*nAC, "19 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 2185 + nColA4)*nAC, aDados[nX, 19], oFont04)

		nLinIni += 20
		oPrint:Say((nLinIni + 0730)*nAL, (nColIni + 0010)*nAC, STR0128, oFont01) //"Dados do Contratado Solicitante / Dados da Internação"
		oPrint:Box((nLinIni + 0740)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0834)*nAL, (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 0765)*nAL, (nColIni + 0020)*nAC, "20 - "+STR0129, oFont01) //"Código na Operadora / CNPJ"
		oPrint:Say((nLinIni + 0805)*nAL, (nColIni + 0030)*nAC, aDados[nX, 20], oFont04)
		oPrint:Box((nLinIni + 0740)*nAL, (nColIni + 0431)*nAC, (nLinIni + 0834)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 0765)*nAL, (nColIni + 0441)*nAC, "21 - "+STR0130, oFont01) //"Nome do Prestador"
		oPrint:Say((nLinIni + 0805)*nAL, (nColIni + 0451)*nAC, SubStr(aDados[nX, 21], 1, 65), oFont04)

		oPrint:Box((nLinIni + 0839)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0933)*nAL, (nColIni + 0465)*nAC)
		oPrint:Say((nLinIni + 0864)*nAL, (nColIni + 0020)*nAC, "22 - "+STR0131, oFont01) //"Caráter da Internação"
		oPrint:Line((nLinIni+ 0869)*nAL, (nColIni + 0030)*nAC, (nLinIni + 0916)*nAL, (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni+ 0916)*nAL, (nColIni + 0030)*nAC, (nLinIni + 0916)*nAL, (nColIni + 0077)*nAC)
		oPrint:Line((nLinIni+ 0869)*nAL, (nColIni + 0077)*nAC, (nLinIni + 0916)*nAL, (nColIni + 0077)*nAC)
		oPrint:Say((nLinIni + 0904)*nAL, (nColIni + 0043)*nAC, aDados[nX, 22], oFont04)
		oPrint:Say((nLinIni + 0904)*nAL, (nColIni + 0090)*nAC, STR0132+"  "+STR0133, oFont01) //"E - Eletiva"###"U - Urgência/Emergência"
		oPrint:Box((nLinIni + 0839)*nAL, (nColIni + 0470)*nAC, (nLinIni + 0933)*nAL, (nColIni + 2000)*nAC)
		oPrint:Say((nLinIni + 0864)*nAL, (nColIni + 0480)*nAC, "23 - "+STR0134, oFont01) //"Tipo de Internação"
		oPrint:Line((nLinIni+ 0869)*nAL, (nColIni + 0490)*nAC, (nLinIni + 0916)*nAL, (nColIni + 0490)*nAC)
		oPrint:Line((nLinIni+ 0916)*nAL, (nColIni + 0490)*nAC, (nLinIni + 0916)*nAL, (nColIni + 0537)*nAC)
		oPrint:Line((nLinIni+ 0869)*nAL, (nColIni + 0537)*nAC, (nLinIni + 0916)*nAL, (nColIni + 0537)*nAC)
		oPrint:Say((nLinIni + 0904)*nAL, (nColIni + 0503)*nAC, aDados[nX, 23], oFont04)
		oPrint:Say((nLinIni + 0904)*nAL, (nColIni + 0550)*nAC, "1 - "+STR0135+"    "+"2 - "+STR0136+"    "+"3 - "+STR0137+"    "+"4 - "+STR0138+"    "+"5 - "+STR0139, oFont01) //"Clínica"###"Cirúrgica"###"Obstétrica"###"Pediátrica"###"Psiquiátrica"

		oPrint:Box((nLinIni + 0938)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1032)*nAL, (nColIni + 0635)*nAC)
		oPrint:Say((nLinIni + 0963)*nAL, (nColIni + 0020)*nAC, "24 - "+STR0140, oFont01) //"Regime de Internação"
		oPrint:Line((nLinIni+ 0968)*nAL, (nColIni + 0030)*nAC, (nLinIni + 1015)*nAL, (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni+ 1015)*nAL, (nColIni + 0030)*nAC, (nLinIni + 1015)*nAL, (nColIni + 0077)*nAC)
		oPrint:Line((nLinIni+ 0968)*nAL, (nColIni + 0077)*nAC, (nLinIni + 1015)*nAL, (nColIni + 0077)*nAC)
		oPrint:Say((nLinIni + 1003)*nAL, (nColIni + 0043)*nAC, aDados[nX, 24], oFont04)
		oPrint:Say((nLinIni + 1003)*nAL, (nColIni + 0090)*nAC, "1 - "+STR0141+"    "+"2 - "+STR0142+"    "+"3 - "+STR0143, oFont01) //"Hospitalar"###"Hospital-dia"###"Domiciliar"
		oPrint:Box((nLinIni + 0938)*nAL, (nColIni + 0640)*nAC, (nLinIni + 1032)*nAL, (nColIni + 0940)*nAC)
		oPrint:Say((nLinIni + 0963)*nAL, (nColIni + 0650)*nAC, "25 - "+STR0144, oFont01) //"Qtde. Diárias Solicitadas"
		oPrint:Say((nLinIni + 1003)*nAL, (nColIni + 0810)*nAC, Transform(aDados[nX, 25], "@E 9999.99"), oFont04,,,,1)

		oPrint:Box((nLinIni + 1037)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1329)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1067)*nAL, (nColIni + 0020)*nAC, "26 - "+STR0145, oFont01) //"Indicação Clínica"
		nLin := 1112

		For nI := 1 To MlCount(aDados[nX, 26], 79)
			cObs := MemoLine(aDados[nX, 26], 79, nI)
			oPrint:Say((nLinIni + nLin)*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
			nLin += 35
		Next nI

		nLinIni += 20
		oPrint:Say((nLinIni + 1354)*nAL, (nColIni + 0010)*nAC, STR0025, oFont01) //"Hipóteses Diagnósticas"
		oPrint:Box((nLinIni + 1364)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1458)*nAL, (nColIni + 0315)*nAC)
		oPrint:Say((nLinIni + 1389)*nAL, (nColIni + 0020)*nAC, "27 - "+STR0146, oFont01) //"Tipo Doença"
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0030)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0030)*nAC)
		oPrint:Line((nLinIni+ 1441)*nAL, (nColIni + 0030)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0077)*nAC)
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0077)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0077)*nAC)
		oPrint:Say((nLinIni + 1429)*nAL, (nColIni + 0043)*nAC, aDados[nX, 27], oFont04)
		oPrint:Say((nLinIni + 1429)*nAL, (nColIni + 0090)*nAC, STR0027+"    "+STR0028, oFont01) //"A-Aguda"###"C-Crônica"
		oPrint:Box((nLinIni + 1364)*nAL, (nColIni + 0320)*nAC, (nLinIni + 1458)*nAL, (nColIni + 0795)*nAC)
		oPrint:Say((nLinIni + 1389)*nAL, (nColIni + 0330)*nAC, "28 - "+STR0147, oFont01) //"Tempo de Doença Referida pelo Paciente"
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0340)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0340)*nAC)
		oPrint:Line((nLinIni+ 1441)*nAL, (nColIni + 0340)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0426)*nAC)
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0426)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 1429)*nAL, (nColIni + 0353)*nAC, IIF((StrZero(aDados[nX, 28,1], 2, 0))=="00","",(StrZero(aDados[nX, 28,1], 2, 0))), oFont04)
		oPrint:Say((nLinIni + 1424)*nAL, (nColIni + 0434)*nAC, "-", oFont01)
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0447)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0447)*nAC)
		oPrint:Line((nLinIni+ 1441)*nAL, (nColIni + 0447)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0494)*nAC)
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0494)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0494)*nAC)
		oPrint:Say((nLinIni + 1429)*nAL, (nColIni + 0457)*nAC, aDados[nX, 28, 2], oFont04)
		oPrint:Say((nLinIni + 1429)*nAL, (nColIni + 0510)*nAC, STR0030+"  "+STR0031+"  "+STR0032, oFont01) //"A-Anos"###"M-Meses"###"D-Dias"
		oPrint:Box((nLinIni + 1364)*nAL, (nColIni + 0800)*nAC, (nLinIni + 1458)*nAL, (nColIni + 1807)*nAC)
		oPrint:Say((nLinIni + 1389)*nAL, (nColIni + 0810)*nAC, "29 - "+STR0033, oFont01) //"Indicação de Acidente"
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0820)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0820)*nAC)
		oPrint:Line((nLinIni+ 1441)*nAL, (nColIni + 0820)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0862)*nAC)
		oPrint:Line((nLinIni+ 1394)*nAL, (nColIni + 0862)*nAC, (nLinIni + 1441)*nAL, (nColIni + 0862)*nAC)
		oPrint:Say((nLinIni + 1429)*nAL, (nColIni + 0833)*nAC, aDados[nX, 29], oFont04)
		oPrint:Say((nLinIni + 1429)*nAL, (nColIni + 0880)*nAC, "0 - "+STR0148+"     "+"1 - "+STR0035+"     "+"2 - "+STR0036, oFont01) //"Acidente ou doença relacionada ao Trabalho"###"Trânsito"###"Outros"

		oPrint:Box((nLinIni + 1463)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1557)*nAL, (nColIni + 0285)*nAC)
		oPrint:Say((nLinIni + 1492)*nAL, (nColIni + 0020)*nAC, "30 - "+STR0149, oFont01) //"CID 10 Principal"
		oPrint:Say((nLinIni + 1532)*nAL, (nColIni + 0030)*nAC, aDados[nX, 30], oFont04)
		oPrint:Box((nLinIni + 1463)*nAL, (nColIni + 0290)*nAC, (nLinIni + 1557)*nAL, (nColIni + 0565)*nAC)
		oPrint:Say((nLinIni + 1492)*nAL, (nColIni + 0300)*nAC, "31 - "+STR0150, oFont01) //"CID 10 (2)"
		oPrint:Say((nLinIni + 1532)*nAL, (nColIni + 0310)*nAC, aDados[nX, 31], oFont04)
		oPrint:Box((nLinIni + 1463)*nAL, (nColIni + 0570)*nAC, (nLinIni + 1557)*nAL, (nColIni + 0845)*nAC)
		oPrint:Say((nLinIni + 1492)*nAL, (nColIni + 0580)*nAC, "32 - "+STR0151, oFont01) //"CID 10 (3)"
		oPrint:Say((nLinIni + 1532)*nAL, (nColIni + 0590)*nAC, aDados[nX, 32], oFont04)
		oPrint:Box((nLinIni + 1463)*nAL, (nColIni + 0850)*nAC, (nLinIni + 1557)*nAL, (nColIni + 1115)*nAC)
		oPrint:Say((nLinIni + 1492)*nAL, (nColIni + 0860)*nAC, "33 - "+STR0152, oFont01) //"CID 10 (4)"
		oPrint:Say((nLinIni + 1532)*nAL, (nColIni + 0870)*nAC, aDados[nX, 33], oFont04)

		nLinIni += 20
		oPrint:Say((nLinIni + 1582)*nAL, (nColIni + 0010)*nAC, STR0153, oFont01) //"Procedimentos Solicitados"
		oPrint:Box((nLinIni + 1592)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1867)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1617)*nAL, (nColIni + 0020)*nAC, "34 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 1617)*nAL, (nColIni + 0150)*nAC, "35 - "+STR0075, oFont01) //"Código do Procedimento"
		oPrint:Say((nLinIni + 1617)*nAL, (nColIni + 0450)*nAC, "36 - "+STR0076, oFont01) //"Descrição"
		oPrint:Say((nLinIni + 1617)*nAL, (nColIni + 2000 + nColA4)*nAC, "37 - "+STR0154, oFont01,,,,1) //"Qtde.Solict"
		oPrint:Say((nLinIni + 1617)*nAL, (nColIni + 2210 + nColA4)*nAC, "38 - "+STR0155, oFont01,,,,1) //"Qtde.Aut"

		nOldLinIni := nLinIni

		if nVolta=1
			nV1:=1
		Endif

		If lPLSGTISS
			lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"03",lImpPrc})
		EndIf

		If lImpPrc

			For nP := nV1 To nT
				if nVolta <> 1
					nN:=nP-((5*nVolta)-5)
					oPrint:Say((nLinIni + 1667)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
				else
					oPrint:Say((nLinIni + 1667)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
				endif
				oPrint:Say((nLinIni + 1662)*nAL, (nColIni + 0070)*nAC, aDados[nX, 34, nP], oFont04)
				oPrint:Say((nLinIni + 1662)*nAL, (nColIni + 0150)*nAC, aDados[nX, 35, nP], oFont04)
				oPrint:Say((nLinIni + 1662)*nAL, (nColIni + 0450)*nAC, aDados[nX, 36, nP], oFont04)
				oPrint:Say((nLinIni + 1662)*nAL, (nColIni + 2000 + nColA4)*nAC, if (aDados[nX, 37, nP]=0,If(Empty(aDados[nX, 35, nP]),"","0,00"),Transform(aDados[nX, 37, nP], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 1662)*nAL, (nColIni + 2210 + nColA4)*nAC, if (aDados[nX, 38, nP]=0,If(Empty(aDados[nX, 35, nP]),"","0,00"),Transform(aDados[nX, 38, nP], "@E 9999.99")), oFont04,,,,1)
				nLinIni += 40
			Next nP

		EndIf

		if nT < Len(aDados[nX, 35]).or. lImpnovo
			  nV1:=nP
			  lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		nLinIni += 20
		oPrint:Say((nLinIni + 1892)*nAL, (nColIni + 0010)*nAC, STR0118, oFont01) //"OPM Solicitados"
		oPrint:Box((nLinIni + 1902)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2177)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 1927)*nAL, (nColIni + 0020)*nAC, "39 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say((nLinIni + 1927)*nAL, (nColIni + 0160)*nAC, "40 - "+STR0119, oFont01) //"Código do OPM"
		oPrint:Say((nLinIni + 1927)*nAL, (nColIni + 0410)*nAC, "41 - "+STR0120, oFont01) //"Descrição OPM"
		oPrint:Say((nLinIni + 1927)*nAL, (nColIni + 1270 + nColA4)*nAC, "42 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say((nLinIni + 1927)*nAL, (nColIni + 1420 + nColA4)*nAC, "43 - "+STR0121, oFont01) //"Fabricante"
		oPrint:Say((nLinIni + 1927)*nAL, (nColIni + 2140 + nColA4)*nAC, "44 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nV2:=1
		Endif

		For nP := nV2 To nT
			if nVolta <> 1
				nN:=nP-((5*nVolta)-5)
				oPrint:Say((nLinIni + 1977)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
			else
				oPrint:Say((nLinIni + 1977)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
			endif
			oPrint:Say((nLinIni + 1972)*nAL, (nColIni + 0065)*nAC, aDados[nX, 39, nP], oFont04)
			oPrint:Say((nLinIni + 1972)*nAL, (nColIni + 0160)*nAC, aDados[nX, 40, nP], oFont04)
			oPrint:Say((nLinIni + 1972)*nAL, (nColIni + 0410)*nAC, SubStr(aDados[nX, 41, nP], 1, 36), oFont04)
			oPrint:Say((nLinIni + 1972)*nAL, (nColIni + 1270 + nColA4)*nAC, if (aDados[nX, 42, nP]=0,If(Empty(aDados[nX, 40, nP]),"","0,00"),Transform(aDados[nX, 42, nP], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 1972)*nAL, (nColIni + 1420 + nColA4)*nAC, Substr(aDados[nX, 43, nP], 1, 25), oFont04)
			oPrint:Say((nLinIni + 1972)*nAL, (nColIni + 2140 + nColA4)*nAC, if (aDados[nX, 44, nP]=0,If(Empty(aDados[nX, 40, nP]),"","0,00"),Transform(aDados[nX, 44, nP], "@E 999,999,999.99")), oFont04,,,,1)
			nLinIni += 40

		Next nP

		if nT < Len(aDados[nX, 40]) .or. lImpnovo
			  nV2:=nP
			  lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		nLinIni += 20
		oPrint:Say((nLinIni + 2197)*nAL, (nColIni + 0010)*nAC, STR0156, oFont01) //"Dados da Autorização"
		oPrint:Box((nLinIni + 2207)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2301)*nAL, (nColIni + 0610)*nAC)
		oPrint:Say((nLinIni + 2232)*nAL, (nColIni + 0020)*nAC, "45 - "+STR0157, oFont01) //"Data Provável da Admissão Hospitalar"
		oPrint:Say((nLinIni + 2272)*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 45]), oFont04)
		oPrint:Box((nLinIni + 2207)*nAL, (nColIni + 0615)*nAC, (nLinIni + 2301)*nAL, (nColIni + 1115)*nAC)
		oPrint:Say((nLinIni + 2232)*nAL, (nColIni + 0625)*nAC, "46 - "+STR0158, oFont01) //"Qtde.Diárias Autorizadas"
		oPrint:Say((nLinIni + 2272)*nAL, (nColIni + 0695)*nAC, Transform(aDados[nX, 46], "@E 9999.99"), oFont04,,,, 1)
		oPrint:Box((nLinIni + 2207)*nAL, (nColIni + 1120)*nAC, (nLinIni + 2301)*nAL, (nColIni + 2120)*nAC)
		oPrint:Say((nLinIni + 2232)*nAL, (nColIni + 1130)*nAC, "47 - "+STR0159, oFont01) //"Tipo da Acomodação Autorizada"
		oPrint:Say((nLinIni + 2272)*nAL, (nColIni + 1140)*nAC, aDados[nX, 47, 1] + " - " + aDados[nX, 47, 2], oFont04)

		oPrint:Box((nLinIni + 2311)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2405)*nAL, (nColIni + 0426)*nAC)
		oPrint:Say((nLinIni + 2336)*nAL, (nColIni + 0020)*nAC, "48 - "+STR0129, oFont01) //"Código na Operadora / CNPJ"
		oPrint:Say((nLinIni + 2376)*nAL, (nColIni + 0030)*nAC, aDados[nX, 48], oFont04)
		oPrint:Box((nLinIni + 2311)*nAL, (nColIni + 0431)*nAC, (nLinIni + 2405)*nAL, (nColIni + 2175 + nColA4)*nAC)
		oPrint:Say((nLinIni + 2336)*nAL, (nColIni + 0441)*nAC, "49 - "+STR0160, oFont01) //"Nome do Prestador Autorizado"
		oPrint:Say((nLinIni + 2376)*nAL, (nColIni + 0451)*nAC, SubStr(aDados[nX, 49], 1, 65), oFont04)
		oPrint:Box((nLinIni + 2311)*nAL, (nColIni + 2180 + nColA4)*nAC, (nLinIni + 2405)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 2336)*nAL, (nColIni + 2190 + nColA4)*nAC, "50 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say((nLinIni + 2376)*nAL, (nColIni + 2200 + nColA4)*nAC, aDados[nX, 50], oFont04)

		oPrint:Box((nLinIni + 2410)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2692 + nLinA4)*nAL, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 2435)*nAL, (nColIni + 0020)*nAC, "51 - "+STR0056, oFont01) //"Observação"
		nLin := 2480

		For nI := 1 To MlCount(aDados[nX, 51], 78)
			cObs := MemoLine(aDados[nX, 51], 78, nI)
			oPrint:Say((nLinIni + nLin)*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
			nLin += 35
		Next nI

		oPrint:Box((nLinIni + 2697)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 2855)*nAL + nLinA4, (nColIni + 0754 + nColA4)*nAC)
		oPrint:Say((nLinIni + 2731 + nLinA4)*nAL, (nColIni + 0020)*nAC, "52 - "+STR0161, oFont01) //"Data e Assinatura do Profissional Solicitante"
		oPrint:Say((nLinIni + 2771 + nLinA4)*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 52]), oFont04)
		oPrint:Box((nLinIni + 2697)*nAL + nLinA4, (nColIni + 0759 + nColA4)*nAC, (nLinIni + 2855)*nAL + nLinA4, (nColIni + 1573 + nColA4)*nAC)
		oPrint:Say((nLinIni + 2731 + nLinA4)*nAL, (nColIni + 0769 + nColA4)*nAC, "53 - "+STR0058, oFont01) //"Data e Assinatura do Beneficiário ou Responsável"
		oPrint:Say((nLinIni + 2771 + nLinA4)*nAL, (nColIni + 0779 + nColA4)*nAC, DtoC(aDados[nX, 53]), oFont04)
		oPrint:Box((nLinIni + 2697)*nAL + nLinA4, (nColIni + 1578 + nColA4)*nAC, (nLinIni + 2855)*nAL + nLinA4, (nColIni + 2390 + nColA4)*nAC)
		oPrint:Say((nLinIni + 2731 + nLinA4)*nAL, (nColIni + 1588 + nColA4)*nAC, "54 - "+STR0116, oFont01) //"Data e Assinatura do Responsável pela Autorização"
		oPrint:Say((nLinIni + 2771 + nLinA4)*nAL, (nColIni + 1598 + nColA4)*nAC, DtoC(aDados[nX, 54]), oFont04)

		oPrint:EndPage()	// Finaliza a pagina

		//  Verso da Guia
		oPrint:StartPage()	// Inicia uma nova pagina

		nLinIni := 100
		nColIni := 0
		nTot55	:=0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni-nLinIni)*nAL, (nColIni)*nAC, ((nLinIni-nLinIni) + nLinMax)*nAL, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 0010)*nAL, (nColIni + 0010)*nAC, STR0162, oFont01) //"Prorrogações"

	    if nVolta=1
			nV:=1
		Endif

		nT3:=Len(aDados[nx,55])

		For nR := nV To nT3

			oPrint:Box((nLinIni + 0020)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0503)*nAL, (nColIni + 2390 + nColA4)*nAC)
			oPrint:Box((nLinIni + 0025)*nAL, (nColIni + 0015)*nAC, (nLinIni + 0119)*nAL, (nColIni + 0405)*nAC)
			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 0025)*nAC, "55 - "+STR0098, oFont01) //"Data"
			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 0035)*nAC, DtoC(aDados[nX, 55, nR]), oFont04)
			oPrint:Box((nLinIni + 0025)*nAL, (nColIni + 0410)*nAC, (nLinIni + 0119)*nAL, (nColIni + 1005)*nAC)
			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 0420)*nAC, "56 - "+STR0063, oFont01) //"Senha"
			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 0430)*nAC, aDados[nX, 56, nR], oFont04)
			oPrint:Box((nLinIni + 0025)*nAL, (nColIni + 1010)*nAC, (nLinIni + 0119)*nAL, (nColIni + 2385 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + 1020)*nAC, "57 - "+STR0163, oFont01) //"Responsável pela Autorização"
			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1030)*nAC, SubStr(aDados[nX, 57, nR], 1, 52), oFont04)

			oPrint:Box((nLinIni + 0124)*nAL, (nColIni + 0015)*nAC, (nLinIni + 0218)*nAL, (nColIni + 0305)*nAC)
			oPrint:Say((nLinIni + 0149)*nAL, (nColIni + 0025)*nAC, "58 - "+STR0164, oFont01) //"Tipo Acomod"
			oPrint:Say((nLinIni + 0189)*nAL, (nColIni + 0035)*nAC, aDados[nX, 58, nR], oFont04)
			oPrint:Box((nLinIni + 0124)*nAL, (nColIni + 0310)*nAC, (nLinIni + 0218)*nAL, (nColIni + 1445)*nAC)
			oPrint:Say((nLinIni + 0149)*nAL, (nColIni + 0320)*nAC, "59 - "+STR0165, oFont01) //"Acomodação"
			oPrint:Say((nLinIni + 0189)*nAL, (nColIni + 0330)*nAC, aDados[nX, 59, nR], oFont04)
			oPrint:Box((nLinIni + 0124)*nAL, (nColIni + 1450)*nAC, (nLinIni + 0218)*nAL, (nColIni + 1685)*nAC)
			oPrint:Say((nLinIni + 0149)*nAL, (nColIni + 1460)*nAC, "60 - "+STR0166, oFont01) //"Qtde.Autorizada"

			nTotAut:=0

			If ValType(aDados[nX][60][nR]) == "N" .And. aDados[nX][60][nR] > 0
				nTotAut := aDados[nX][60][nR]
			Else
				For nJ := 1 To  Len( aDados[nX, 65, nR])
					nTotAut:=aDados[nX, 65, nR, nJ]
	  			Next nj
            EndIf

			oPrint:Say((nLinIni + 0189)*nAL, (nColIni + 1530)*nAC, If(Empty(nTotAut),"0,00",Transform(nTotAut, "@E 9999.99")), oFont04,,,,1)

			oPrint:Box((nLinIni + 0223)*nAL, (nColIni + 0015)*nAC, (nLinIni + 0358)*nAL, (nColIni + 2385 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + 0025)*nAC, "61 - "+STR0074, oFont01) //"Tabela"
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + 0155)*nAC, "62 - "+STR0075, oFont01) //"Código do Procedimento"
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + 0455)*nAC, "63 - "+STR0076, oFont01) //"Descrição"
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + 2025 + nColA4)*nAC, "64 - "+STR0167, oFont01,,,,1) //"Qtde.Solic"
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + 2235 + nColA4)*nAC, "65 - "+STR0155, oFont01,,,,1) //"Qtde.Aut"

			nOldLinIni := nLinIni

			For nJ := 1 To 1
				oPrint:Say((nLinIni + 0288)*nAL, (nColIni + 0025)*nAC, aDados[nX, 61, nR, nJ], oFont04)
				oPrint:Say((nLinIni + 0288)*nAL, (nColIni + 0155)*nAC, aDados[nX, 62, nR, nJ], oFont04)
				oPrint:Say((nLinIni + 0288)*nAL, (nColIni + 0455)*nAC, SubStr(aDados[nX, 63, nR, nJ],1,92), oFont04)
				oPrint:Say((nLinIni + 0288)*nAL, (nColIni + 2025 + nColA4)*nAC, IIf(aDados[nX, 64, nR, nJ]=0, If(Empty(aDados[nX, 62, nR, nJ]),"","0,00"), Transform(aDados[nX, 64, nR, nJ], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 0288)*nAL, (nColIni + 2235 + nColA4)*nAC, IIf(aDados[nX, 65, nR, nJ]=0, If(Empty(aDados[nX, 62, nR, nJ]),"","0,00"), Transform(aDados[nX, 65, nR, nJ], "@E 9999.99")), oFont04,,,,1)
				nLinIni += 40
			Next nJ

			nLinIni := nOldlinIni

			oPrint:Box((nLinIni + 0363)*nAL, (nColIni + 0015)*nAC, (nLinIni + 0498)*nAL, (nColIni + 2385 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0388)*nAL, (nColIni + 0025)*nAC, "66 - "+STR0074, oFont01) //"Tabela"
			oPrint:Say((nLinIni + 0388)*nAL, (nColIni + 0165)*nAC, "67 - "+STR0119, oFont01) //"Código do OPM"
			oPrint:Say((nLinIni + 0388)*nAL, (nColIni + 0400)*nAC, "68 - "+STR0120, oFont01) //"Descrição OPM"
			oPrint:Say((nLinIni + 0388)*nAL, (nColIni + 1375 + nColA4)*nAC, "69 - "+STR0101, oFont01,,,,1) //"Qtde."
			oPrint:Say((nLinIni + 0388)*nAL, (nColIni + 1495 + nColA4)*nAC, "70 - "+STR0121, oFont01) //"Fabricante"
			oPrint:Say((nLinIni + 0388)*nAL, (nColIni + 2125 + nColA4)*nAC, "71 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"

			nOldLinIni := nLinIni

			For nJ := 1 To Len( aDados[nX, 66, nR])
				oPrint:Say((nLinIni + 0428)*nAL, (nColIni + 0025)*nAC, aDados[nX, 66, nR, nJ], oFont04)
				oPrint:Say((nLinIni + 0428)*nAL, (nColIni + 0165)*nAC, aDados[nX, 67, nR, nJ], oFont04)
				oPrint:Say((nLinIni + 0428)*nAL, (nColIni + 0400)*nAC, SubStr(aDados[nX, 68, nR, nJ], 1, 36), oFont04)
				oPrint:Say((nLinIni + 0428)*nAL, (nColIni + 1375 + nColA4)*nAC, IIf(aDados[nX, 69, nR, nJ]=0,If(Empty(aDados[nX, 67, nR, nJ]),"","0,00") , Transform(aDados[nX, 69, nR, nJ], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 0428)*nAL, (nColIni + 1495 + nColA4)*nAC, SubStr(aDados[nX, 70, nR, nJ], 1, 25), oFont04)
				oPrint:Say((nLinIni + 0428)*nAL, (nColIni + 2125 + nColA4)*nAC, IIf(aDados[nX, 71, nR, nJ]=0, If(Empty(aDados[nX, 67, nR, nJ]),"","0,00"), Transform(aDados[nX, 71, nR, nJ], "@E 999,999,999.99")), oFont04,,,,1)
				nLinIni += 40
			Next nJ

			nLinIni := nOldlinIni
			nTot55 ++

			If nTot55 > 5
			  	oPrint:EndPage()	// Finaliza a pagina
		  		oPrint:StartPage()	// Inicia uma nova pagina
				nLinIni := 100
				nColIni := 0
				nTot55	:=0
			Else
				nLinIni += 500
			Endif

		Next nR

		if (Len(aDados[nX, 55])>nR-1) .or. (Len(aDados[nX, 55])>nR-1).or. lImpnovo
			  nV       :=nR
			  nV1      :=nP
			  nV2      :=nP
			  lImpnovo :=.T.
		Endif

		oPrint:EndPage()	// Finaliza a pagina

	Next nX

enddo
	If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:Print()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
       If lRet
		oPrint:Print()
		EndIf

		If lMail .And. (lRet:=Aviso("Atenção","Confirma o envio do relatório por e-mail?",{"Sim","Não"},1)== 1)

			If File(cFile)
				lOk := (FErase(cFile)==0)
			EndIf

			If lOk
				oPrint:SaveAsHTML(cFile)
			Else
				Aviso("Atenção","Não foi possível criar o arquivo "+cFile,{"Ok"},1)
				lRet := .F.
			EndIf

		EndIf

	EndIf

Return {lRet,cFile,cFileName}
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS4  ³ Autor ³ Luciano Aparecido     ³ Data ³ 22.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Res. Internaçao)-BOPS 095189 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela 	   ³±±
±±³          ³			 de configuracao/preview do relatorio 		       ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISS4(aDados, lGerTXT, nLayout, cLogoGH, lAuto)

	Local nLinMax
	Local nColMax
	Local nLinIni := 0		// Linha Lateral (inicial) Esquerda
	Local nColIni := 0		// Coluna Lateral (inicial) Esquerda
    Local nColA4  := 0
    Local nCol2A4 := 0
	Local cFileLogo
	Local lPrinter
	Local nLin
	Local nOldLinIni
	Local nI, nJ, nX, nN
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local lImpnovo:=.T.
	Local nVolta  := 0
	Local nP   	  := 0
	Local nP1     := 0
	Local nP2     := 0
	Local nP3     := 0
	Local nP4     := 0
	Local nP5     := 0
	Local nT      := 0
	Local nT1     := 0
	Local nT2     := 0
	Local nT3     := 0
	Local nT4     := 0
	Local nAte    :=15
	Local nAte1   :=20
	Local nAte2   := 5
	Local cFileName := ""

	Default lGerTXT := .F.
	Default nLayout := 2
	Default cLogoGH := ''
	Default lAuto   := .F.
	Default aDados := { { ;
						"123456",;
						"12345678901234567892",;
						"12345678901234567892",;
						CtoD("01/01/07"),;
						"12345678901234567892",;
						CtoD("01/01/07"),;
						CtoD("01/01/07"),;
						"12345678901234567892",;
						Replicate("M",40),;
						CtoD("12/12/07"),;
						Replicate("M",70),;
						"123456789102345",;
						"14.141.114/00001-35",;
						Replicate("M",70),;
						"1234567",;
						"999",;
						Replicate("M",40),;
						"MMMMM",;
						Replicate("M",15),;
						Replicate("M",40),;
						"MM",;
						"1234567",;
						"12345-678",;
						"E",;
						{ "00", "COLETIVO" },;
						{ CtoD("12/12/07"), "2210" },;
						{ CtoD("12/12/07"), "2210" },;
						"1",;
						"1",;
						{ "X","X","X","X","X","X","X","X","X" },;
						"1",;
						{ 1, 1 },;
						"123456789102345",;
						99,;
						01,;
						01,;
						"12345",;
						"12345",;
						"12345",;
						"12345",;
						"1",;
						"01",;
						"12345",;
						"1234567",;
						{ CtoD("12/01/06"),CtoD("12/02/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06") },;
						{ "0107","0207","0307","0407","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507" },;
						{ "0607","0707","0807","0907","1007","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507" },;
						{ "MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD"},;
						{ "1234567890","2345678901","3456789012","4567890123","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234"},;
						{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60)},;
						{ 12,1,2,3,4,4,4,4,4,4,4,4,4,4,4},;
						{ "M","A","B","C","D","D","D","D","D","D","D","D","D","D","D"},;
						{ "M","E","F","G","H","D","D","D","D","D","D","D","D","D","D"},;
						{ 111.00,222.00,333.00,444.00,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99 },;
						{ 99999.99,22222.22,33.33,44444.44,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11 },;
						{ 11111.11,55555.00,66666.00,77777.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00 },;
						{ "03", "04", "05", "06", "07","08","08","08","08","08","08","08","08","08","08","08","08","08","08","08","08" },;
						{ "02", "03", "04", "05", "06","07","08","08","08","08","08","08","08","08","08","08","08","08","08","08","08" },;
						{ "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102", "123456789102" },;
						{ Replicate("A", 70), Replicate("B", 70), Replicate("C", 70), Replicate("D", 70), Replicate("E", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70) },;
						{ "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567", "1234567" },;
						{ "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345" },;
						{ "ES", "DF", "MM", "GO", "SP","SC", "DF", "MM", "GO", "SP","SC", "DF", "MM", "GO", "SP","SC", "DF", "MM", "GO", "SP","SC", "DF", "MM", "GO", "SP" },;
						{ "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910", "12345678910" },;
						{ "11", "12", "13", "14", "15", "16", "17", "18", "19" },;
						{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234", "6789012345", "7890123456", "8901234567", "9012345678" },;
						{ Replicate ("A", 60), Replicate ("B", 60), Replicate ("C", 60), Replicate ("D", 60), Replicate ("E", 60), Replicate ("F", 60), Replicate ("G", 60), Replicate ("H", 60), Replicate ("I", 60) },;
						{ 01, 2, 3, 04, 05, 06, 07, 8, 99 }, ;
						{ Replicate ("J", 20), Replicate ("K", 20), Replicate ("L", 20), Replicate ("M", 20), Replicate ("N", 20), Replicate ("O", 20), Replicate ("P", 20), Replicate ("Q", 20), Replicate ("R", 20) },;
						{ 199999.99, 299999.99, 399999.99, 499999.99, 599999.99, 699999.99, 799.99, 899999.99, 99.99 },;
						{ 199999.99, 299999.99, 399999.99, 499999.99, 599999.99, 699999.99, 799.99, 899999.99, 99.99 },;
						3999999.99,;
						{ "X","X" },;
						199999.99,;
						199999.99,;
						199999.99,;
						199999.99,;
						199999.99,;
						199999.99,;
						199999.99,;
						Replicate("M", 240),;
						CtoD("01/01/07"),;
						CtoD("04/01/07") } }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705	//3765
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2375
		nColMax	:=	3370 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	If lAuto	
		cPathSrvJ := GETMV("MV_RELT")
		cFileName := "pdfauto"+lower(CriaTrab(NIL,.F.))+".pdf"
		oPrint    := FWMSPrinter():New ( cFileName,,.F., cPathSrvJ,.T.,nil,@oPrint,nil,nil,.F.,.F.)
		oPrint:lServer := .T.
		oPrint:cPathPDF := cPathSrvJ
	else
		oPrint	:= TMSPrinter():New(STR0168) //"GUIA DE RESUMO DE INTERNACAO"
	endif

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()

	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf ! lPrinter
		oPrint:Setup()
	EndIf


While lImpnovo

	lImpnovo:=.F.
	nVolta  += 1
	nAte    += nP
	nAte1   += nP1
	nAte2   += nP4


	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 45 To 56
			If Len(aDados[nX, nI]) < nAte
				For nJ := Len(aDados[nX, nI]) + 1 To nAte
					If AllTrim(Str(nI)) $ "45"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "51,54,55,56"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 57 To 64
			If Len(aDados[nX, nI]) < nAte1
				For nJ := Len(aDados[nX, nI]) + 1 To nAte1
					aAdd(aDados[nX, nI], "")
				Next nJ
			EndIf
		Next nI

		For nI := 65 To 71
			If Len(aDados[nX, nI]) < nAte2
				For nJ := Len(aDados[nX, nI]) + 1 To nAte2
					If AllTrim(Str(nI)) $ "68,70,71"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		nLinIni := 000
		nColIni := 000
		nColA4  := 000
		nCol2A4 := 000

		oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
			nColA4    := -0335
			nCol2A4   := -0180
		Elseif nLayout == 3// Carta
			nColA4    := -0530
			nCol2A4   := -0180
		Endif

		oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIf(nLayout == 2 .Or. nLayout == 3,nColA4+230,nColA4), STR0169, oFont02n,,,, 2) //"GUIA DE RESUMO DE INTERNAÇÃO"
		oPrint:Say(nLinIni + 0090, nColIni + 3000 + nColA4, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say(nLinIni + 0070, nColIni + 3096 + nColA4, aDados[nX, 02], oFont03n)

		nLinIni += 60
		oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, nColIni + 0315)
		oPrint:Say(nLinIni + 0180, nColIni + 0020, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say(nLinIni + 0210, nColIni + 0030, aDados[nX, 01], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 0320, nLinIni + 0269, nColIni + 1035)
		oPrint:Say(nLinIni + 0180, nColIni + 0330, "3 - "+STR0170, oFont01) //"Nº Guia de Solicitação"
		oPrint:Say(nLinIni + 0210, nColIni + 0340, aDados[nX, 03], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 1040, nLinIni + 0269, nColIni + 1345)
		oPrint:Say(nLinIni + 0180, nColIni + 1050, "4 - "+STR0062, oFont01) //"Data da Autorização"
		oPrint:Say(nLinIni + 0210, nColIni + 1060, DtoC(aDados[nX, 04]), oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 1350, nLinIni + 0269, nColIni + 1755)
		oPrint:Say(nLinIni + 0180, nColIni + 1360, "5 - "+STR0063, oFont01) //"Senha"
		oPrint:Say(nLinIni + 0210, nColIni + 1370, aDados[nX, 05], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 1760, nLinIni + 0269, nColIni + 2165)
		oPrint:Say(nLinIni + 0180, nColIni + 1770, "6 - "+STR0064, oFont01) //"Data Validade da Senha"
		oPrint:Say(nLinIni + 0210, nColIni + 1780, DtoC(aDados[nX, 06]), oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 2170, nLinIni + 0269, nColIni + 2465)
		oPrint:Say(nLinIni + 0180, nColIni + 2180, "7 - "+STR0004, oFont01) //"Data de Emissão da Guia"
		oPrint:Say(nLinIni + 0210, nColIni + 2190, DtoC(aDados[nX, 07]), oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0274, nColIni + 0010, STR0005, oFont01) //"Dados do Beneficiário"
		oPrint:Box(nLinIni + 0304, nColIni + 0010, nLinIni + 0398, nColIni + 0425)
		oPrint:Say(nLinIni + 0309, nColIni + 0020, "8 - "+STR0006, oFont01) //"Número da Carteira"
		oPrint:Say(nLinIni + 0339, nColIni + 0030, aDados[nX, 08], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 0430, nLinIni + 0398, nColIni + 1572)
		oPrint:Say(nLinIni + 0309, nColIni + 0440, "9 - "+STR0007, oFont01) //"Plano"
		oPrint:Say(nLinIni + 0339, nColIni + 0450, aDados[nX, 09], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 1577, nLinIni + 0398, nColIni + 1835)
		oPrint:Say(nLinIni + 0309, nColIni + 1587, "10 - "+STR0008, oFont01) //"Validade da Carteira"
		oPrint:Say(nLinIni + 0339, nColIni + 1597, DtoC(aDados[nX, 10]), oFont04)

		oPrint:Box(nLinIni + 0403, nColIni + 0010, nLinIni + 0497, nColIni + 3090 + nColA4)
		oPrint:Say(nLinIni + 0408, nColIni + 0020, "11 - "+STR0009, oFont01) //"Nome"
		oPrint:Say(nLinIni + 0438, nColIni + 0030, aDados[nX, 11], oFont04)
		oPrint:Box(nLinIni + 0403, nColIni + 3095 + nColA4, nLinIni + 0497, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0408, nColIni + 3105 + nColA4, "12 - "+STR0010, oFont01) //"Número do Cartão Nacional de Saúde"
		oPrint:Say(nLinIni + 0438, nColIni + 3115 + nColA4, aDados[nX, 12], oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0502, nColIni + 0010, STR0079, oFont01) //"Dados do Contratado Executante"
		oPrint:Box(nLinIni + 0532, nColIni + 0010, nLinIni + 0626, nColIni + 0426)
		oPrint:Say(nLinIni + 0537, nColIni + 0020, "13 - "+STR0129, oFont01) //"Código na Operadora / CNPJ"
		oPrint:Say(nLinIni + 0567, nColIni + 0030, aDados[nX, 13], oFont04)
		oPrint:Box(nLinIni + 0532, nColIni + 0431, nLinIni + 0626, nColIni + 2245)
		oPrint:Say(nLinIni + 0537, nColIni + 0441, "14 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say(nLinIni + 0567, nColIni + 0451, SubStr(aDados[nX, 14], 1, 65), oFont04)
		oPrint:Box(nLinIni + 0532, nColIni + 2250, nLinIni + 0626, nColIni + 2460)
		oPrint:Say(nLinIni + 0537, nColIni + 2260, "15 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say(nLinIni + 0567, nColIni + 2270, aDados[nX, 15], oFont04)

		oPrint:Box(nLinIni + 0631, nColIni + 0010, nLinIni + 0725, nColIni + 0132)
		oPrint:Say(nLinIni + 0636, nColIni + 0020, "16 - "+STR0015, oFont01) //"T.L."
		oPrint:Say(nLinIni + 0666, nColIni + 0030, aDados[nX, 16], oFont04)
		oPrint:Box(nLinIni + 0631, nColIni + 0137, nLinIni + 0725, nColIni + 2032 + nColA4)
		oPrint:Say(nLinIni + 0636, nColIni + 0147, "17-18-19 - "+STR0016, oFont01) //"Logradouro - Número - Complemento"
		oPrint:Say(nLinIni + 0666, nColIni + 0157, SubStr(AllTrim(aDados[nX, 17]) + IIf(!Empty(aDados[nX, 18]), ", ","") + AllTrim(aDados[nX, 18]) + IIf(!Empty(aDados[nX, 19]), " - ","") + AllTrim(aDados[nX, 19]), 1, 76), oFont04)
		oPrint:Box(nLinIni + 0631, nColIni + 2037 + nColA4, nLinIni + 0725, nColIni + 3165 + nColA4)
		oPrint:Say(nLinIni + 0636, nColIni + 2047 + nColA4, "20 - "+STR0017, oFont01) //"Município"
		oPrint:Say(nLinIni + 0666, nColIni + 2057 + nColA4, SubStr(aDados[nX, 20], 1, 39), oFont04)
		oPrint:Box(nLinIni + 0631, nColIni + 3170 + nColA4, nLinIni + 0725, nColIni + 3269 + nColA4)
		oPrint:Say(nLinIni + 0636, nColIni + 3180 + nColA4, "21 - "+STR0018, oFont01) //"UF"
		oPrint:Say(nLinIni + 0666, nColIni + 3190 + nColA4, aDados[nX, 21], oFont04)
		oPrint:Box(nLinIni + 0631, nColIni + 3274 + nColA4, nLinIni + 0725, nColIni + 3502 + nColA4)
		oPrint:Say(nLinIni + 0636, nColIni + 3284 + nColA4, "22 - "+STR0171, oFont01) //"Cód. IBGE"
		oPrint:Say(nLinIni + 0666, nColIni + 3294 + nColA4, aDados[nX, 22], oFont04)
		oPrint:Box(nLinIni + 0631, nColIni + 3507 + nColA4, nLinIni + 0725, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0636, nColIni + 3517 + nColA4, "23 - "+STR0020, oFont01) //"CEP"
		oPrint:Say(nLinIni + 0666, nColIni + 3527 + nColA4, aDados[nX, 23], oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0730, nColIni + 0010, STR0172, oFont01) //"Dados da Internação"
		oPrint:Box(nLinIni + 0760, nColIni + 0010, nLinIni + 0854, nColIni + 0465)
		oPrint:Say(nLinIni + 0765, nColIni + 0020, "24 - "+STR0131, oFont01) //"Caráter da Internação"
		oPrint:Line(nLinIni + 0790, nColIni + 0030 + nColA4, nLinIni + 0837, nColIni + 0030 + nColA4)
		oPrint:Line(nLinIni + 0837, nColIni + 0030 + nColA4, nLinIni + 0837, nColIni + 0077 + nColA4)
		oPrint:Line(nLinIni + 0790, nColIni + 0077 + nColA4, nLinIni + 0837, nColIni + 0077 + nColA4)
		oPrint:Say(nLinIni + 0795, nColIni + 0043, aDados[nX, 24], oFont04)
		oPrint:Say(nLinIni + 0805, nColIni + 0090, STR0132+"  "+STR0133, oFont01) //"E - Eletiva"###"U - Urgência/Emergência"
		oPrint:Box(nLinIni + 0760, nColIni + 0470, nLinIni + 0854, nColIni + 1445 + nColA4)
		oPrint:Say(nLinIni + 0765, nColIni + 0480, "25 - "+STR0173, oFont01) //"Tipo Acomodação Autorizada"
		oPrint:Say(nLinIni + 0795, nColIni + 0490, aDados[nX, 25, 1] + "-" + aDados[nX, 25, 2], oFont04)
		oPrint:Box(nLinIni + 0760, nColIni + 1450 + nColA4, nLinIni + 0854, nColIni + 1865 + nColA4)
		oPrint:Say(nLinIni + 0765, nColIni + 1460 + nColA4, "26 - "+STR0174, oFont01) //"Data/Hora da Internação"
		oPrint:Say(nLinIni + 0795, nColIni + 1470 + nColA4, DtoC(aDados[nX, 26,1]) + " " + Transform(aDados[nX, 26,2], "@R 99:99"), oFont04)
		oPrint:Box(nLinIni + 0760, nColIni + 1870 + nColA4, nLinIni + 0854, nColIni + 2285 + nColA4)
		oPrint:Say(nLinIni + 0765, nColIni + 1880 + nColA4, "27 - "+STR0175, oFont01) //"Data/Hora da Saída Internação"
		oPrint:Say(nLinIni + 0795, nColIni + 1890 + nColA4, DtoC(aDados[nX, 27,1]) + " " + Transform(aDados[nX, 27,2], "@R 99:99"), oFont04)
		oPrint:Box(nLinIni + 0760, nColIni + 2290 + nColA4, nLinIni + 0854, nColIni + 3055 + nColA4)
		oPrint:Say(nLinIni + 0765, nColIni + 2300 + nColA4, "28 - "+STR0176, oFont01) //"Tipo Internação"
		oPrint:Line(nLinIni + 0790, nColIni + 2310 + nColA4, nLinIni + 0837, nColIni + 2310 + nColA4)
		oPrint:Line(nLinIni + 0837, nColIni + 2310 + nColA4, nLinIni + 0837, nColIni + 2357 + nColA4)
		oPrint:Line(nLinIni + 0790, nColIni + 2357 + nColA4, nLinIni + 0837, nColIni + 2357 + nColA4)
		oPrint:Say(nLinIni + 0795, nColIni + 2323 + nColA4, aDados[nX, 28], oFont04)
		oPrint:Say(nLinIni + 0805, nColIni + 2370 + nColA4, "1 - "+STR0135+"  "+"2 - "+STR0136+"  "+"3 - "+STR0137+"  "+"4 - "+STR0138+"  "+"5 - "+STR0139, oFont01) //"Clínica"###"Cirúrgica"###"Obstétrica"###"Pediátrica"###"Psiquiátrica"
		oPrint:Box(nLinIni + 0760, nColIni + 3060 + nColA4, nLinIni + 0854, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0765, nColIni + 3070 + nColA4, "29 - "+STR0140, oFont01) //"Regime de Internação"
		oPrint:Line(nLinIni + 0790, nColIni + 3080 + nColA4, nLinIni + 0837, nColIni + 3080 + nColA4)
		oPrint:Line(nLinIni + 0837, nColIni + 3080 + nColA4, nLinIni + 0837, nColIni + 3127 + nColA4)
		oPrint:Line(nLinIni + 0790, nColIni + 3127 + nColA4, nLinIni + 0837, nColIni + 3127 + nColA4)
		oPrint:Say(nLinIni + 0795, nColIni + 3093 + nColA4, aDados[nX, 29], oFont04)
		oPrint:Say(nLinIni + 0805, nColIni + 3140 + nColA4, "1 - "+STR0141+"  "+"2 - "+STR0142+"  "+"3- "+STR0143, oFont01) //"Hospitalar"###"Hospital-dia"###"Domiciliar"

		oPrint:Box(nLinIni + 0859, nColIni + 0010, nLinIni + 0948, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0864, nColIni + 0020, '30 - '+STR0177, oFont01) //'Internação Obstétrica - (selecione mais de um se necessário com "X")'
		oPrint:Line(nLinIni + 0889, nColIni + 0030, nLinIni + 0936, nColIni + 0030)
		oPrint:Line(nLinIni + 0936, nColIni + 0030, nLinIni + 0936, nColIni + 0077)
		oPrint:Line(nLinIni + 0889, nColIni + 0077, nLinIni + 0936, nColIni + 0077)
		oPrint:Say(nLinIni + 0894, nColIni + 0043, aDados[nX, 30,1], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 0090, "- "+STR0178, oFont01) //"Em gestação"
		oPrint:Line(nLinIni + 0889, nColIni + 0240, nLinIni + 0936, nColIni + 0240)
		oPrint:Line(nLinIni + 0936, nColIni + 0240, nLinIni + 0936, nColIni + 0287)
		oPrint:Line(nLinIni + 0889, nColIni + 0287, nLinIni + 0936, nColIni + 0287)
		oPrint:Say(nLinIni + 0894, nColIni + 0253, aDados[nX, 30,2], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 0300, "- "+STR0179, oFont01) //"Aborto"
		oPrint:Line(nLinIni + 0889, nColIni + 0390, nLinIni + 0936, nColIni + 0390)
		oPrint:Line(nLinIni + 0936, nColIni + 0390, nLinIni + 0936, nColIni + 0437)
		oPrint:Line(nLinIni + 0889, nColIni + 0437, nLinIni + 0936, nColIni + 0437)
		oPrint:Say(nLinIni + 0894, nColIni + 0403, aDados[nX, 30,3], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 0450, "- "+STR0180, oFont01) //"Transtorno materno relacionado a gravidez"
		oPrint:Line(nLinIni + 0889, nColIni + 0880, nLinIni + 0936, nColIni + 0880)
		oPrint:Line(nLinIni + 0936, nColIni + 0880, nLinIni + 0936, nColIni + 0927)
		oPrint:Line(nLinIni + 0889, nColIni + 0927, nLinIni + 0936, nColIni + 0927)
		oPrint:Say(nLinIni + 0894, nColIni + 0893, aDados[nX, 30,4], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 0940, "- "+STR0181, oFont01) //"Complic. Puerpério"
		oPrint:Line(nLinIni + 0889, nColIni + 1160, nLinIni + 0936, nColIni + 1160)
		oPrint:Line(nLinIni + 0936, nColIni + 1160, nLinIni + 0936, nColIni + 1207)
		oPrint:Line(nLinIni + 0889, nColIni + 1207, nLinIni + 0936, nColIni + 1207)
		oPrint:Say(nLinIni + 0894, nColIni + 1173, aDados[nX, 30,5], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 1220, "- "+STR0182, oFont01) //"Atend. ao RN na sala de parto"
		oPrint:Line(nLinIni + 0889, nColIni + 1540, nLinIni + 0936, nColIni + 1540)
		oPrint:Line(nLinIni + 0936, nColIni + 1540, nLinIni + 0936, nColIni + 1587)
		oPrint:Line(nLinIni + 0889, nColIni + 1587, nLinIni + 0936, nColIni + 1587)
		oPrint:Say(nLinIni + 0894, nColIni + 1553, aDados[nX, 30,6], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 1600, "- "+STR0183, oFont01) //"Complicação Neonatal"
		oPrint:Line(nLinIni + 0889, nColIni + 1850, nLinIni + 0936, nColIni + 1850)
		oPrint:Line(nLinIni + 0936, nColIni + 1850, nLinIni + 0936, nColIni + 1897)
		oPrint:Line(nLinIni + 0889, nColIni + 1897, nLinIni + 0936, nColIni + 1897)
		oPrint:Say(nLinIni + 0894, nColIni + 1863, aDados[nX, 30,7], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 1910, "- "+STR0184, oFont01) //"Bx. Peso < 2,5 Kg"
		oPrint:Line(nLinIni + 0889, nColIni + 2130, nLinIni + 0936, nColIni + 2130)
		oPrint:Line(nLinIni + 0936, nColIni + 2130, nLinIni + 0936, nColIni + 2177)
		oPrint:Line(nLinIni + 0889, nColIni + 2177, nLinIni + 0936, nColIni + 2177)
		oPrint:Say(nLinIni + 0894, nColIni + 2143, aDados[nX, 30,8], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 2190, "- "+STR0185, oFont01) //"Parto Cesáreo"
		oPrint:Line(nLinIni + 0889, nColIni + 2380, nLinIni + 0936, nColIni + 2380)
		oPrint:Line(nLinIni + 0936, nColIni + 2380, nLinIni + 0936, nColIni + 2427)
		oPrint:Line(nLinIni + 0889, nColIni + 2427, nLinIni + 0936, nColIni + 2427)
		oPrint:Say(nLinIni + 0894, nColIni + 2393, aDados[nX, 30,9], oFont04)
		oPrint:Say(nLinIni + 0904, nColIni + 2440, "- "+STR0186, oFont01) //"Parto Normal"

		oPrint:Box(nLinIni + 0953, nColIni + 0010, nLinIni + 1047, nColIni + 1060)
		oPrint:Say(nLinIni + 0958, nColIni + 0020, "31 - "+STR0187, oFont01) //"Se óbito em mulher"
		oPrint:Line(nLinIni + 0983, nColIni + 0030, nLinIni + 1030, nColIni + 0030)
		oPrint:Line(nLinIni + 1030, nColIni + 0030, nLinIni + 1030, nColIni + 0077)
		oPrint:Line(nLinIni + 0983, nColIni + 0077, nLinIni + 1030, nColIni + 0077)
		oPrint:Say(nLinIni + 0988, nColIni + 0043, aDados[nX, 31], oFont04)
		oPrint:Say(nLinIni + 0998, nColIni + 0090, "1 - "+STR0188+"  "+"2 - "+STR0189+"  "+"3 - "+STR0190, oFont01) //"Grávida"###"até 42 dias após término gestação"###"de 43 dias a 12 meses após término gestação"
		oPrint:Box(nLinIni + 0953, nColIni + 1065, nLinIni + 1047, nColIni + 1800)
		oPrint:Say(nLinIni + 0958, nColIni + 1075, "32 - "+STR0191, oFont01) //"Se óbito neonatal"
		oPrint:Line(nLinIni + 0983, nColIni + 1085, nLinIni + 1030, nColIni + 1085)
		oPrint:Line(nLinIni + 1030, nColIni + 1085, nLinIni + 1030, nColIni + 1132)
		oPrint:Line(nLinIni + 0983, nColIni + 1132, nLinIni + 1030, nColIni + 1132)
		oPrint:Say(nLinIni + 0988, nColIni + 1125, Transform(aDados[nX, 32,1], "@E 99"), oFont04,,,,1)
		oPrint:Say(nLinIni + 0998, nColIni + 1145, "- "+STR0192, oFont01) //"Qtde. óbito neonatal precoce"
		oPrint:Line(nLinIni + 0983, nColIni + 1455, nLinIni + 1030, nColIni + 1455)
		oPrint:Line(nLinIni + 1030, nColIni + 1455, nLinIni + 1030, nColIni + 1502)
		oPrint:Line(nLinIni + 0983, nColIni + 1502, nLinIni + 1030, nColIni + 1502)
		oPrint:Say(nLinIni + 0988, nColIni + 1495, Transform(aDados[nX, 32,2], "@E 99"), oFont04,,,,1)
		oPrint:Say(nLinIni + 0998, nColIni + 1515, "- "+STR0193, oFont01) //"Qtde. óbito neonatal tardio"
		oPrint:Box(nLinIni + 0953, nColIni + 1805, nLinIni + 1047, nColIni + 2125 + IIf(nLayout == 2 .Or. nLayout ==3,nCol2A4/2+30,0))
		oPrint:Say(nLinIni + 0958, nColIni + 1815, "33 - "+STR0194, oFont01) //"Nº Decl.Nasc.Vivos"
		oPrint:Say(nLinIni + 0988, nColIni + 1825 + IIf(nLayout == 2 .Or. nLayout ==3,nCol2A4/2+80,0), aDados[nX, 33], oFont04)
		oPrint:Box(nLinIni + 0953, nColIni + 2130 + IIf(nLayout == 2 .Or. nLayout ==3,nCol2A4/2+30,0), nLinIni + 1047, nColIni + 2530 + nCol2A4/2)
		oPrint:Say(nLinIni + 0958, nColIni + 2140 + IIf(nLayout == 2 .Or. nLayout ==3,nCol2A4/2+30,0), "34 - "+STR0195, oFont01) //"Qtde.Nasc.Vivos a Termo"
		oPrint:Say(nLinIni + 0988, nColIni + 2350 + IIf(nLayout == 2 .Or. nLayout ==3,nCol2A4/2+30,0), Transform(aDados[nX, 34], "@E 9999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 0953, nColIni + 2535 + nCol2A4/2, nLinIni + 1047, nColIni + 2935 + nCol2A4/2)
		oPrint:Say(nLinIni + 0958, nColIni + 2545 + nCol2A4/2, "35 - "+STR0196, oFont01) //"Qtde.Nasc.Mortos"
		oPrint:Say(nLinIni + 0988, nColIni + 2755 + nCol2A4/2, Transform(aDados[nX, 35], "@E 9999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 0953, nColIni + 2940 + nCol2A4/2, nLinIni + 1047, nColIni + 3340 + IIf(nLayout == 2 .Or. nLayout ==3,nCol2A4+5,0))
		oPrint:Say(nLinIni + 0958, nColIni + 2950 + nCol2A4/2, "36 - "+STR0197, oFont01) //"Qtde.Nasc.Vivos Prematuro"
		oPrint:Say(nLinIni + 0988, nColIni + 3160 + nCol2A4/2, Transform(aDados[nX, 36], "@E 9999.99"), oFont04,,,,1)

		nLinIni += 20
		oPrint:Say(nLinIni + 1052, nColIni + 0010, STR0198, oFont01) //"Dados da Saída da Internação"
		oPrint:Box(nLinIni + 1082, nColIni + 0010, nLinIni + 1176, nColIni + 0285)
		oPrint:Say(nLinIni + 1087, nColIni + 0020, "37 - "+STR0149, oFont01) //"CID 10 Principal"
		oPrint:Say(nLinIni + 1117, nColIni + 0030, aDados[nX, 37], oFont04)
		oPrint:Box(nLinIni + 1082, nColIni + 0290, nLinIni + 1176, nColIni + 0565)
		oPrint:Say(nLinIni + 1087, nColIni + 0300, "38 - "+STR0150, oFont01) //"CID 10 (2)"
		oPrint:Say(nLinIni + 1117, nColIni + 0310, aDados[nX, 38], oFont04)
		oPrint:Box(nLinIni + 1082, nColIni + 0570, nLinIni + 1176, nColIni + 0845)
		oPrint:Say(nLinIni + 1087, nColIni + 0580, "39 - "+STR0151, oFont01) //"CID 10 (3)"
		oPrint:Say(nLinIni + 1117, nColIni + 0590, aDados[nX, 39], oFont04)
		oPrint:Box(nLinIni + 1082, nColIni + 0850, nLinIni + 1176, nColIni + 1115)
		oPrint:Say(nLinIni + 1087, nColIni + 0860, "40 - "+STR0152, oFont01) //"CID 10 (4)"
		oPrint:Say(nLinIni + 1117, nColIni + 0870, aDados[nX, 40], oFont04)
		oPrint:Box(nLinIni + 1082, nColIni + 1120, nLinIni + 1176, nColIni + 1900)
		oPrint:Say(nLinIni + 1087, nColIni + 1130, "41 - "+STR0199, oFont01) //"Indicador de Acidente"
		oPrint:Line(nLinIni + 1112, nColIni + 1140, nLinIni + 1159, nColIni + 1140)
		oPrint:Line(nLinIni + 1159, nColIni + 1140, nLinIni + 1159, nColIni + 1182)
		oPrint:Line(nLinIni + 1112, nColIni + 1182, nLinIni + 1159, nColIni + 1182)
		oPrint:Say(nLinIni + 1117, nColIni + 1153, aDados[nX, 41], oFont04)
		oPrint:Say(nLinIni + 1127, nColIni + 1200, "0 - "+STR0034+"   "+"1 - "+STR0035+"   "+"2 - "+STR0036, oFont01) //"Acidente ou doença relacionado ao trabalho"###"Trânsito"###"Outros"
		oPrint:Box(nLinIni + 1082, nColIni + 1905, nLinIni + 1176, nColIni + 2205)
		oPrint:Say(nLinIni + 1087, nColIni + 1915, "42 - "+STR0200, oFont01) //"Motivo Saída"
		oPrint:Say(nLinIni + 1117, nColIni + 1925, aDados[nX, 42], oFont04)
		oPrint:Box(nLinIni + 1082, nColIni + 2210, nLinIni + 1176, nColIni + 2510)
		oPrint:Say(nLinIni + 1087, nColIni + 2220, "43 - "+STR0201, oFont01) //"CID 10 Óbito"
		oPrint:Say(nLinIni + 1117, nColIni + 2230, aDados[nX, 43], oFont04)
		oPrint:Box(nLinIni + 1082, nColIni + 2515, nLinIni + 1176, nColIni + 3000)
		oPrint:Say(nLinIni + 1087, nColIni + 2525, "44 - "+STR0202, oFont01) //"Nº Declaração do Óbito"
		oPrint:Say(nLinIni + 1117, nColIni + 2535, aDados[nX, 44], oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 1181, nColIni + 0010, STR0097, oFont01) //"Procedimentos e Exames Realizados"
		oPrint:Box(nLinIni + 1211, nColIni + 0010, nLinIni + 1501, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 1216, nColIni + 0020, "45 - "+STR0098, oFont01) //"Data"
		oPrint:Say(nLinIni + 1216, nColIni + 0205, "46 - "+STR0099, oFont01) //"Hora Inicial"
		oPrint:Say(nLinIni + 1216, nColIni + 0380, "47 - "+STR0100, oFont01) //"Hora Final"
		oPrint:Say(nLinIni + 1216, nColIni + 0540, "48 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say(nLinIni + 1216, nColIni + 0660, "49 - "+STR0075, oFont01) //"Código do Procedimento"
		oPrint:Say(nLinIni + 1216, nColIni + 0940, "50 - "+STR0076, oFont01) //"Descrição"
		oPrint:Say(nLinIni + 1216, nColIni + 2825 + nColA4, "51 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say(nLinIni + 1216, nColIni + 2855 + nColA4, "52 - "+STR0102, oFont01) //"Via"
		oPrint:Say(nLinIni + 1216, nColIni + 2945 + nColA4, "53 - "+STR0103, oFont01) //"Tec."
		oPrint:Say(nLinIni + 1216, nColIni + 3235 + nColA4, "54 - "+STR0104, oFont01,,,,1) //"% Red./Acresc."
		oPrint:Say(nLinIni + 1216, nColIni + 3465 + nColA4, "55 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say(nLinIni + 1216, nColIni + 3675 + nColA4, "56 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni
		if nVolta=1
			nP:=1
		Endif
		nT:=nP+4
		For nI := nP To nT
			if nVolta <> 1
				nN:=nI-(15*nVolta-15)
				oPrint:Say(nLinIni + 1271, nColIni + 0020, AllTrim(Str(nN)) + " - ", oFont01)
			else
				oPrint:Say(nLinIni + 1271, nColIni + 0020, AllTrim(Str(nI)) + " - ", oFont01)
			Endif
			oPrint:Say(nLinIni + 1266, nColIni + 0065, IIf(Empty(aDados[nX, 45, nI]), "", DtoC(aDados[nX, 45, nI])), oFont04)
			oPrint:Say(nLinIni + 1266, nColIni + 0205, IIf(Empty(aDados[nX, 46, nI]), "", Transform(aDados[nX, 46, nI], "@R 99:99")), oFont04)
		   	oPrint:Say(nLinIni + 1266, nColIni + 0380, IIf(Empty(aDados[nX, 47, nI]), "", Transform(aDados[nX, 47, nI], "@R 99:99")), oFont04)
			oPrint:Say(nLinIni + 1266, nColIni + 0540, aDados[nX, 48, nI], oFont04)
			oPrint:Say(nLinIni + 1266, nColIni + 0660, aDados[nX, 49, nI], oFont04)
			oPrint:Say(nLinIni + 1266, nColIni + 0940, aDados[nX, 50, nI], oFont04)
			oPrint:Say(nLinIni + 1266, nColIni + 2825 + nColA4, IIf((aDados[nX, 51, nI])=0, "", Transform(aDados[nX, 51, nI], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 1266, nColIni + 2855 + nColA4, aDados[nX, 52, nI], oFont04)
			oPrint:Say(nLinIni + 1266, nColIni + 2945 + nColA4, aDados[nX, 53, nI], oFont04)
			oPrint:Say(nLinIni + 1266, nColIni + 3235 + nColA4, IIf((aDados[nX, 54, nI])=0, "", Transform(aDados[nX, 54, nI], "@E 999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 1266, nColIni + 3465 + nColA4, IIf((aDados[nX, 55, nI])=0, "", Transform(aDados[nX, 55, nI], "@E 99,999,999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 1266, nColIni + 3675 + nColA4, IIf((aDados[nX, 56, nI])=0, "", Transform(aDados[nX, 56, nI], "@E 99,999,999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nI

		nLinIni := nOldLinIni
	    nP:=nI

		nLinIni += 20
		oPrint:Say(nLinIni + 1506, nColIni + 0010, STR0203, oFont01) //"Identificação da Equipe"
		oPrint:Box(nLinIni + 1536, nColIni + 0010, nLinIni + 1866, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 1541, nColIni + 0020, "57 - "+STR0204, oFont01) //"Seq.Ref"
		oPrint:Say(nLinIni + 1541, nColIni + 0180, "58 - "+STR0205, oFont01) //"Gr.Part."
		oPrint:Say(nLinIni + 1541, nColIni + 0320, "59 - "+STR0206, oFont01) //"Código na Operadora/CPF"
		oPrint:Say(nLinIni + 1541, nColIni + 0670, "60 - "+STR0207, oFont01) //"Nome do Profissional"
		oPrint:Say(nLinIni + 1541, nColIni + 2640 + nColA4, "61 - "+STR0208, oFont01) //"Conselho Prof."
		oPrint:Say(nLinIni + 1541, nColIni + 2990 + nColA4, "62 - "+STR0209, oFont01) //"Número Conselho"
		oPrint:Say(nLinIni + 1541, nColIni + 3340 + nColA4, "63 - "+STR0018, oFont01) //"UF"
		oPrint:Say(nLinIni + 1541, nColIni + 3440 + nColA4, "64 - "+STR0210, oFont01) //"CPF"

		nOldLinIni := nLinIni
		if nVolta=1
			nP1:=1
		Endif
		nT1:=nP1+5
		For nI := nP1 To nT1
			oPrint:Say(nLinIni + 1591, nColIni + 0020, aDados[nX, 57, nI], oFont04)
			oPrint:Say(nLinIni + 1591, nColIni + 0180, aDados[nX, 58, nI], oFont04)
			oPrint:Say(nLinIni + 1591, nColIni + 0320, aDados[nX, 59, nI], oFont04)
			oPrint:Say(nLinIni + 1591, nColIni + 0670, aDados[nX, 60, nI], oFont04)
			oPrint:Say(nLinIni + 1591, nColIni + 2640 + nColA4, aDados[nX, 61, nI], oFont04)
			oPrint:Say(nLinIni + 1591, nColIni + 2990 + nColA4, aDados[nX, 62, nI], oFont04)
			oPrint:Say(nLinIni + 1591, nColIni + 3340 + nColA4, aDados[nX, 63, nI], oFont04)
			oPrint:Say(nLinIni + 1591, nColIni + 3440 + nColA4, IIf(Empty(aDados[nX, 64, nI]), "", Transform(aDados[nX, 64, nI], "@R 999.999.999-99")), oFont04)
			nLinIni += 40
		Next nI

		nP1:=nI
		nLinIni := nOldLinIni

		oPrint:Box(nLinIni + 1871, nColIni + 0010, nLinIni + 1965, nColIni + 0350)
		oPrint:Say(nLinIni + 1876, nColIni + 0020, "73 - "+STR0211, oFont01) //"Tipo Faturamento R$"
		oPrint:Line(nLinIni + 1901, nColIni + 0030, nLinIni + 1948, nColIni + 0030)
		oPrint:Line(nLinIni + 1948, nColIni + 0030, nLinIni + 1948, nColIni + 0077)
		oPrint:Line(nLinIni + 1901, nColIni + 0077, nLinIni + 1948, nColIni + 0077)
		oPrint:Say(nLinIni + 1906, nColIni + 0043, aDados[nX, 73,1], oFont04)
		oPrint:Say(nLinIni + 1916, nColIni + 0090, "- "+STR0212, oFont01) //"Total"
		oPrint:Line(nLinIni + 1901, nColIni + 0180, nLinIni + 1948, nColIni + 0180)
		oPrint:Line(nLinIni + 1948, nColIni + 0180, nLinIni + 1948, nColIni + 0227)
		oPrint:Line(nLinIni + 1901, nColIni + 0227, nLinIni + 1948, nColIni + 0227)
		oPrint:Say(nLinIni + 1906, nColIni + 0193, aDados[nX, 73,2], oFont04)
		oPrint:Say(nLinIni + 1916, nColIni + 0240, "- "+STR0213, oFont01) //"Parcial"

		oPrint:Box(nLinIni + 1871, nColIni + 0355, nLinIni + 1965, nColIni + 0827 + nColA4/3)
		oPrint:Say(nLinIni + 1876, nColIni + 0365, "74 - "+STR0108, oFont01) //"Total Procedimentos R$"
		oPrint:Say(nLinIni + 1906, nColIni + 0807 + nColA4/3, Transform(aDados[nX, 74], "@E 999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1871, nColIni + 0832 + nColA4/3, nLinIni + 1965, nColIni + 1304 + nColA4/2)
		oPrint:Say(nLinIni + 1876, nColIni + 0842 + nColA4/3, "75 - "+STR0112, oFont01) //"Total Diárias R$"
		oPrint:Say(nLinIni + 1906, nColIni + 1284 + nColA4/2, Transform(aDados[nX, 75], "@E 999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1871, nColIni + 1309 + nColA4/2, nLinIni + 1965, nColIni + 1781 + nColA4/2)
		oPrint:Say(nLinIni + 1876, nColIni + 1319 + nColA4/2, "76 - "+STR0109, oFont01) //"Total Taxas e Aluguéis R$"
		oPrint:Say(nLinIni + 1906, nColIni + 1761 + nColA4/2, Transform(aDados[nX, 76], "@E 999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1871, nColIni + 1786 + nColA4/2, nLinIni + 1965, nColIni + 2258 + nColA4/2)
		oPrint:Say(nLinIni + 1876, nColIni + 1796 + nColA4/2, "77 - "+STR0110, oFont01) //"Total Materiais R$"
		oPrint:Say(nLinIni + 1906, nColIni + 2238 + nColA4/2, Transform(aDados[nX, 77], "@E 999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1871, nColIni + 2263 + nColA4/2, nLinIni + 1965, nColIni + 2735 + nColA4/2)
		oPrint:Say(nLinIni + 1876, nColIni + 2273 + nColA4/2, "78 - "+STR0111, oFont01) //"Total Medicamentos R$"
		oPrint:Say(nLinIni + 1906, nColIni + 2715 + nColA4/2, Transform(aDados[nX, 78], "@E 999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1871, nColIni + 2740 + nColA4/2, nLinIni + 1965, nColIni + 3212 + IIF(nLayout == 2,(nCol2A4*2)+70,nCol2A4*2))
		oPrint:Say(nLinIni + 1876, nColIni + 2750 + nColA4/2, "79 - "+STR0113, oFont01) //"Total Gases Medicinais R$"
		oPrint:Say(nLinIni + 1906, nColIni + 3192 + IIF(nLayout == 2,(nCol2A4*2)+70,nCol2A4*2), Transform(aDados[nX, 79], "@E 999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1871, nColIni + 3217 + IIF(nLayout == 2,(nCol2A4*2)+70,nCol2A4*2), nLinIni + 1965, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 1876, nColIni + 3227 + IIF(nLayout == 2,(nCol2A4*2)+70,nCol2A4*2), "80 - "+STR0214, oFont01) //"Total Geral R$"
		oPrint:Say(nLinIni + 1906, nColIni + 3675 + nColA4, Transform(aDados[nX, 80], "@E 999,999.99"), oFont04,,,,1)

		oPrint:Box(nLinIni + 1970, nColIni + 0010, nLinIni + 2158, nColIni + 1340)
		oPrint:Say(nLinIni + 1975, nColIni + 0020, "82 - "+STR0215, oFont01) //"Data e Assinatura do Contratado"
		oPrint:Say(nLinIni + 2005, nColIni + 0030, DtoC(aDados[nX, 82]), oFont04)
		oPrint:Box(nLinIni + 1970, nColIni + 1345, nLinIni + 2158, nColIni + 2695)
		oPrint:Say(nLinIni + 1975, nColIni + 1355, "83 - "+STR0216, oFont01) //"Data e Assinatura do(s) Auditor(es) da Operadora"
		oPrint:Say(nLinIni + 2005, nColIni + 1365, DtoC(aDados[nX, 83]), oFont04)

		oPrint:EndPage()	// Finaliza a pagina

		//  Verso da Guia
		oPrint:StartPage()	// Inicia uma nova pagina

		nLinIni := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

		nLinIni += 20
		oPrint:Say(nLinIni + 0010, nColIni + 0010, STR0217, oFont01) //"Procedimentos e Exames Realizados (Continuação)"
		oPrint:Box(nLinIni + 0040, nColIni + 0010, nLinIni + 0530, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0045, nColIni + 0020, "45 - "+STR0098, oFont01) //"Data"
		oPrint:Say(nLinIni + 0045, nColIni + 0205, "46 - "+STR0099, oFont01) //"Hora Inicial"
		oPrint:Say(nLinIni + 0045, nColIni + 0380, "47 - "+STR0100, oFont01) //"Hora Final"
		oPrint:Say(nLinIni + 0045, nColIni + 0540, "48 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say(nLinIni + 0045, nColIni + 0660, "49 - "+STR0075, oFont01) //"Código do Procedimento"
		oPrint:Say(nLinIni + 0045, nColIni + 0940, "50 - "+STR0076, oFont01) //"Descrição"
		oPrint:Say(nLinIni + 0045, nColIni + 2855 + nColA4, "51 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say(nLinIni + 0045, nColIni + 2885 + nColA4, "52 - "+STR0102, oFont01) //"Via"
		oPrint:Say(nLinIni + 0045, nColIni + 2975 + nColA4, "53 - "+STR0103, oFont01) //"Tec."
		oPrint:Say(nLinIni + 0045, nColIni + 3245 + nColA4, "54 - "+STR0104, oFont01,,,,1) //"% Red./Acresc."
		oPrint:Say(nLinIni + 0045, nColIni + 3465 + nColA4, "55 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say(nLinIni + 0045, nColIni + 3675 + nColA4, "56 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni

		if nVolta =1
			nP:=6
		Endif
		nT2:=nP+9

		For nI := nP To nT2
			if nVolta<>1
				nN:=nI-((15*nVolta)-15)
				oPrint:Say(nLinIni + 0100, nColIni + 0020, AllTrim(Str(nN)) + " - ", oFont01)
			Else
				oPrint:Say(nLinIni + 0100, nColIni + 0020, AllTrim(Str(nI)) + " - ", oFont01)
			Endif
			oPrint:Say(nLinIni + 0095, nColIni + 0065, if (Empty(aDados[nX, 45, nI]),"",DtoC(aDados[nX, 45, nI])), oFont04)
			oPrint:Say(nLinIni + 0095, nColIni + 0205, if (Empty(aDados[nX, 46, nI]),"",Transform(aDados[nX, 46, nI], "@R 99:99")), oFont04)
		   	oPrint:Say(nLinIni + 0095, nColIni + 0380, if (Empty(aDados[nX, 47, nI]),"",Transform(aDados[nX, 47, nI], "@R 99:99")), oFont04)
			oPrint:Say(nLinIni + 0095, nColIni + 0540, aDados[nX, 48, nI], oFont04)
			oPrint:Say(nLinIni + 0095, nColIni + 0660, aDados[nX, 49, nI], oFont04)
			oPrint:Say(nLinIni + 0095, nColIni + 0940, aDados[nX, 50, nI], oFont04)
			oPrint:Say(nLinIni + 0095, nColIni + 2855 + nColA4, IIf((aDados[nX, 51, nI])=0, "", Transform(aDados[nX, 51, nI], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0095, nColIni + 2885 + nColA4, aDados[nX, 52, nI], oFont04)
			oPrint:Say(nLinIni + 0095, nColIni + 2975 + nColA4, aDados[nX, 53, nI], oFont04)
			oPrint:Say(nLinIni + 0095, nColIni + 3245 + nColA4, IIf((aDados[nX, 54, nI])=0, "", Transform(aDados[nX, 54, nI], "@E 999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0095, nColIni + 3465 + nColA4, IIf((aDados[nX, 55, nI])=0, "", Transform(aDados[nX, 55, nI], "@E 99,999,999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0095, nColIni + 3675 + nColA4, IIf((aDados[nX, 56, nI])=0, "", Transform(aDados[nX, 56, nI], "@E 99,999,999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nI

		nP:=nI

		if nVolta=1
			nP3:=len(aDados[nX,49])
		Endif

		if nP3 >nI-1
			lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		nLinIni += 20
		oPrint:Say(nLinIni + 0535, nColIni + 0010, STR0218, oFont01) //"Identificação da Equipe (Continuação)"
		oPrint:Box(nLinIni + 0565, nColIni + 0010, nLinIni + 1215, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0570, nColIni + 0020, "57 - "+STR0204, oFont01) //"Seq.Ref"
		oPrint:Say(nLinIni + 0570, nColIni + 0180, "58 - "+STR0205, oFont01) //"Gr.Part."
		oPrint:Say(nLinIni + 0570, nColIni + 0320, "59 - "+STR0206, oFont01) //"Código na Operadora/CPF"
		oPrint:Say(nLinIni + 0570, nColIni + 0670, "60 - "+STR0207, oFont01) //"Nome do Profissional"
		oPrint:Say(nLinIni + 0570, nColIni + 2640 + nColA4, "61 - "+STR0208, oFont01) //"Conselho Prof."
		oPrint:Say(nLinIni + 0570, nColIni + 2990 + nColA4, "62 - "+STR0209, oFont01) //"Número Conselho"
		oPrint:Say(nLinIni + 0570, nColIni + 3340 + nColA4, "63 - "+STR0018, oFont01) //"UF"
		oPrint:Say(nLinIni + 0570, nColIni + 3440 + nColA4, "64 - "+STR0210, oFont01) //"CPF"

		nOldLinIni := nLinIni
		if nVolta =1
			nP1:=7
		Endif
		nT3:=nP1+13

		For nI := nP1 To nT3
			oPrint:Say(nLinIni + 0620, nColIni + 0020, aDados[nX, 57, nI], oFont04)
			oPrint:Say(nLinIni + 0620, nColIni + 0180, aDados[nX, 58, nI], oFont04)
			oPrint:Say(nLinIni + 0620, nColIni + 0320, aDados[nX, 59, nI], oFont04)
			oPrint:Say(nLinIni + 0620, nColIni + 0670, aDados[nX, 60, nI], oFont04)
			oPrint:Say(nLinIni + 0620, nColIni + 2640 + nColA4, aDados[nX, 61, nI], oFont04)
			oPrint:Say(nLinIni + 0620, nColIni + 2990 + nColA4, aDados[nX, 62, nI], oFont04)
			oPrint:Say(nLinIni + 0620, nColIni + 3340 + nColA4, aDados[nX, 63, nI], oFont04)
			oPrint:Say(nLinIni + 0620, nColIni + 3440 + nColA4, IIf(Empty(aDados[nX, 57, nI]), "", Transform(aDados[nX, 64, nI], "@R 999.999.999-99")), oFont04)
			nLinIni += 40
		Next nI

		nP1:=nI

		if nVolta=1
			nP2:=len(aDados[nX,57])
		Endif

		if nP2 >nI-1
			lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		nLinIni += 20
		oPrint:Say(nLinIni + 1220, nColIni + 0020, STR0122, oFont01) //"OPM Utilizados"
		oPrint:Box(nLinIni + 1250, nColIni + 0010, nLinIni + 1540, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 1255, nColIni + 0020, "65 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say(nLinIni + 1255, nColIni + 0160, "66 - "+STR0119, oFont01) //"Código do OPM"
		oPrint:Say(nLinIni + 1255, nColIni + 0410, "67 - "+STR0120, oFont01) //"Descrição OPM"
		oPrint:Say(nLinIni + 1255, nColIni + 2465 + nColA4, "68 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say(nLinIni + 1255, nColIni + 2505 + nColA4, "69 - "+STR0123, oFont01) //"Código de Barras"
		oPrint:Say(nLinIni + 1255, nColIni + 3390 + nColA4, "70 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say(nLinIni + 1255, nColIni + 3665 + nColA4, "71 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni

		if nVolta=1
			nP4:=1
		Endif
		nT4:=nP4+4

		For nI := nP4 To nT4
			if nVolta <> 1
				nN:=nI-((nVolta*5)-5)
				oPrint:Say(nLinIni + 1305, nColIni + 0020, AllTrim(Str(nN)) + " - ", oFont01)
			else
				oPrint:Say(nLinIni + 1305, nColIni + 0020, AllTrim(Str(nI)) + " - ", oFont01)
            Endif
			oPrint:Say(nLinIni + 1300, nColIni + 0065, aDados[nX, 65, nI], oFont04)
			oPrint:Say(nLinIni + 1300, nColIni + 0160, aDados[nX, 66, nI], oFont04)
			oPrint:Say(nLinIni + 1300, nColIni + 0410, aDados[nX, 67, nI], oFont04)
			oPrint:Say(nLinIni + 1300, nColIni + 2465 + nColA4, IIf(Empty(aDados[nX, 68, nI]), "", Transform(aDados[nX, 68, nI], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 1300, nColIni + 2505 + nColA4, aDados[nX, 69, nI], oFont04)
			oPrint:Say(nLinIni + 1300, nColIni + 3390 + nColA4, IIf(Empty(aDados[nX, 70, nI]), "", Transform(aDados[nX, 70, nI], "@E 999,999,999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 1300, nColIni + 3665 + nColA4, IIf(Empty(aDados[nX, 71, nI]), "", Transform(aDados[nX, 71, nI], "@E 999,999,999.99")), oFont04,,,,1)
			nLinIni += 40
		Next nI

		nP4:=nI

		if nVolta=1
			nP5:=len(aDados[nX,66])
		Endif

		if nP5 >nI-1
			lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		oPrint:Box(nLinIni + 1545, nColIni + 3295 + nColA4, nLinIni + 1639, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 1550, nColIni + 3305 + nColA4, "72 - "+STR0214, oFont01) //"Total Geral R$"
		oPrint:Say(nLinIni + 1580, nColIni + 3675 + nColA4, Transform(aDados[nX, 72], "@E 999,999,999.99"), oFont04,,,,1)

		oPrint:Box(nLinIni + 1644, nColIni + 0010, nLinIni + 1864, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 1649, nColIni + 0020, "81 - "+STR0056, oFont01) //"Observação"

		nLin := 1684

		For nI := 1 To MlCount(aDados[nX, 81], 130)
			cObs := MemoLine(aDados[nX, 81], 130, nI)
			oPrint:Say(nLinIni + nLin, nColIni + 0030, cObs, oFont04)
			nLin += 35
		Next nI

		oPrint:EndPage()	// Finaliza a pagina

	Next nX

Enddo

If lGerTXT .Or. lAuto
	oPrint:Print()		// Imprime Relatorio
Else
	oPrint:Preview()	// Visualiza impressao grafica antes de imprimir
EndIf

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS7  ³ Autor ³ Luciano Aparecido     ³ Data ³ 26.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Demons An. Contas Med)-BOPS 095189³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISS7(aDados, nLayout, cLogoGH, lAuto)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=  0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local nProcGui  :=  0
	Local nLibGui   :=  0
	Local nGloGui   :=  0
	Local nProcGer  :=  0
	Local nLibGer   :=  0
	Local nGloGer   :=  0
	Local nProcFat  :=  0
	Local nLibFat   :=  0
	Local nGloFat   :=  0
	Local cFileLogo
	Local lPrinter
	Local nI, nJ
	Local nX,nX1,nX2,nX3,nX4
	Local oFont01
	Local oFont02n
	Local oFont04
	Local lBox
	Local cFileName := ""

	Default nLayout := 2
	Default cLogoGH := ''
	Default lAuto   := .F.
	Default aDados  := { { ;
						"123456",;
						Replicate("M",70),;
						"14.141.114/00001-35",;
						{"123456789102"},;
						{CtoD("12/01/06")},;
						{"14.141.114/00001-35"},;
						{Replicate("M",70)},;
						{"1234567"},;
						{"123456789102"},;
						{{ "123456789102" }},;
						{{ CtoD("12/01/06") }},;
						{{ "123456789102" }},;
						{{ 999999999.99 }},;
						{{ 999999999.99 }},;
						{{ "99" }},;
						{{ { "12345678910234567892" } }},;
						{{ { Replicate("M",70) } }},;
					    {{ { "12345678910234567892" } }},;
						{{ { { CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/02/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06") } } }},;
						{{ { { Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("B",70),Replicate("C",70),Replicate("D",70),Replicate("E",70),Replicate("E",70),Replicate("E",70),Replicate("E",70),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",70),Replicate("E",70),Replicate("E",70),Replicate("E",70),Replicate("E",70) } } }},;
						{{ { { "MM","MM","MM","MM","MM","MM","MM","MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD" } }} },;
						{{ { { "1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","2345678901","3456789012","4567890123","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234" } }} },;
						{{ { { "MM","MM","MM","MM","MM","MM","MM","MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD" } }} },;
						{{ { { 312,312,312,312,312,312,312,312,1,2,3,4,4,4,4,4,4,4,4,4,4,4,4,4 } }} },;
						{{ { { 999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,222.00,333.00,444.00,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99 } } }},;
						{{ { { 999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,22222.22,33.33,44444.44,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,911111.11,911111.11,911111.11 } }} },;
						{{ { { 999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,22222.22,33.33,44444.44,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,911111.11,911111.11,911111.11 } } }},;
						{{ { { "MM","MM","MM","MM","MM","MM","MM","MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD","DD" } }} },;
						 } }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2375
		nColMax	:=	3370 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	if lAuto
		cPathSrvJ := GETMV("MV_RELT")
		cFileName := "pdfauto"+lower(CriaTrab(NIL,.F.))+".pdf"
		oPrint    := FWMSPrinter():New ( cFileName,,.F., cPathSrvJ,.T.,nil,@oPrint,nil,nil,.F.,.F.)
		oPrint:lServer := .T.
		oPrint:cPathPDF := cPathSrvJ
	else
		oPrint	:= TMSPrinter():New(STR0245) //"DEMONSTRATIVO DE ANALISE DA CONTA MEDICA"
	endIf

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()

	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf ! lPrinter
		oPrint:Setup()
	EndIf

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 19 To 28
			If Len(aDados[nX, nI]) < 1
				For nJ := Len(aDados[nX, nI]) + 1 To 5
					If AllTrim(Str(nI)) $ "19"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "24,25,26,27"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nX1 := 1 To Len(aDados[nX, 04])

			If nX1 > 1
			 	oPrint:EndPage()
			Endif

			nLinIni := 040
			nColIni := 060
			nColA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
			  	nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIF(nLayout == 2 .Or. nLayout == 3,nColA4+250,0), STR0246, oFont02n,,,, 2) //"DEMONSTRATIVO DE ANÁLISE DA CONTA MÉDICA"

			nLinIni += 60
			oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, nColIni + 0315)
			oPrint:Say(nLinIni + 0180, nColIni + 0020, "1 - "+STR0003, oFont01) //"Registro ANS"
			oPrint:Say(nLinIni + 0210, nColIni + 0030, aDados[nX, 01], oFont04)
			oPrint:Box(nLinIni + 0175, nColIni + 0320, nLinIni + 0269, nColIni + 2265 + nColA4)
			oPrint:Say(nLinIni + 0180, nColIni + 0330, "2 - "+STR0247, oFont01) //"Nome da Operadora"
			oPrint:Say(nLinIni + 0210, nColIni + 0340, aDados[nX, 02], oFont04)
			oPrint:Box(nLinIni + 0175, nColIni + 2270 + nColA4, nLinIni + 0269, nColIni + 2735 + nColA4)
			oPrint:Say(nLinIni + 0180, nColIni + 2280 + nColA4, "3 - "+STR0248, oFont01) //"CNPJ Operadora"
			oPrint:Say(nLinIni + 0210, nColIni + 2290 + nColA4, aDados[nX, 03], oFont04)
			oPrint:Box(nLinIni + 0175, nColIni + 2740 + nColA4, nLinIni + 0269, nColIni + 3290 + nColA4)
			oPrint:Say(nLinIni + 0180, nColIni + 2750 + nColA4, "4 - "+STR0249, oFont01) //"Número do Demonstrativo"
			oPrint:Say(nLinIni + 0210, nColIni + 2760 + nColA4, aDados[nX, 04,nX1], oFont04)
			oPrint:Box(nLinIni + 0175, nColIni + 3295 + nColA4, nLinIni + 0269, nColIni + 3695 + nColA4)
			oPrint:Say(nLinIni + 0180, nColIni + 3305 + nColA4, "5 - "+STR0250, oFont01) //"Data Emissão do Demonstrativo"
			oPrint:Say(nLinIni + 0210, nColIni + 3315 + nColA4, DtoC(aDados[nX, 05,nX1]), oFont04)

			nLinIni += 20
			oPrint:Say(nLinIni + 0274, nColIni + 0010, STR0251, oFont01) //"Dados do Prestador"
			oPrint:Box(nLinIni + 0304, nColIni + 0010, nLinIni + 0398, nColIni + 0426)
			oPrint:Say(nLinIni + 0309, nColIni + 0020, "6 - "+STR0252, oFont01) //"Código Prestador / CNPJ / CPF"
			oPrint:Say(nLinIni + 0339, nColIni + 0030, aDados[nX, 06,nX1], oFont04)
			oPrint:Box(nLinIni + 0304, nColIni + 0431, nLinIni + 0398, nColIni + 2365)
			oPrint:Say(nLinIni + 0309, nColIni + 0441, "7 - "+STR0009, oFont01) //"Nome"
			oPrint:Say(nLinIni + 0339, nColIni + 0451, aDados[nX, 07,nX1], oFont04)
			oPrint:Box(nLinIni + 0304, nColIni + 2370, nLinIni + 0398, nColIni + 2580)
			oPrint:Say(nLinIni + 0309, nColIni + 2380, "8 - "+STR0014, oFont01) //"Código CNES"
			oPrint:Say(nLinIni + 0339, nColIni + 2390, aDados[nX, 08,nX1], oFont04)

			nProcGer := 0
			nLibGer  := 0
			nGloGer  := 0
			nProcFat := 0
			nLibFat  := 0
			nGloFat  := 0
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 360)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60)
			oPrint:Say(nLinIni + 0003, nColIni + 0010, STR0253, oFont01) //"Dados da Conta"
			oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127, nColIni + 0526)
			oPrint:Say(nLinIni + 0038, nColIni + 0020, "9 - "+STR0254, oFont01) //"Número da Fatura"
			oPrint:Say(nLinIni + 0068, nColIni + 0030, aDados[nX, 09,nX1], oFont04)

			For nX2 := 1 To Len(aDados[nX, 10, nX1])

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
				oPrint:Box(nLinIni + 0032, nColIni + 0010, nLinIni + 0126, nColIni + 0620 + (nColA4/6))
				oPrint:Say(nLinIni + 0037, nColIni + 0020, "10 - "+STR0255, oFont01) //"Número do Lote"
				oPrint:Say(nLinIni + 0067, nColIni + 0030, aDados[nX, 10, nX1,nX2], oFont04)
				oPrint:Box(nLinIni + 0032, nColIni + 0625 + (nColA4/6), nLinIni + 0126, nColIni + 1235 + (2*(nColA4/6)))
				oPrint:Say(nLinIni + 0037, nColIni + 0635 + (nColA4/6), "11 - "+STR0256, oFont01) //"Data de Envio do Lote"
				oPrint:Say(nLinIni + 0067, nColIni + 0645 + (nColA4/6), DtoC(aDados[nX, 11,nX1, nX2]), oFont04)
				oPrint:Box(nLinIni + 0032, nColIni + 1240 + (2*(nColA4/6)), nLinIni + 0126, nColIni + 1850 + (3*(nColA4/6)))
				oPrint:Say(nLinIni + 0037, nColIni + 1250 + (2*(nColA4/6)), "12 - "+STR0257, oFont01) //"Número do Protocolo"
				oPrint:Say(nLinIni + 0067, nColIni + 1260 + (2*(nColA4/6)), aDados[nX, 12, nX1,nX2], oFont04)
				oPrint:Box(nLinIni + 0032, nColIni + 1855 + (3*(nColA4/6)), nLinIni + 0126, nColIni + 2465 + (4*(nColA4/6)))
				oPrint:Say(nLinIni + 0037, nColIni + 1865 + (3*(nColA4/6)), "13 - "+STR0258, oFont01) //"Valor Protocolo (R$)"
				oPrint:Say(nLinIni + 0067, nColIni + 2445 + (4*(nColA4/6)), Transform(aDados[nX, 13,nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni + 0032, nColIni + 2470 + (4*(nColA4/6)), nLinIni + 0126, nColIni + 3080 + (5*(nColA4/6)))
				oPrint:Say(nLinIni + 0037, nColIni + 2480 + (4*(nColA4/6)), "14 - "+STR0259, oFont01) //"Valor Glosa Protocolo (R$)"
				oPrint:Say(nLinIni + 0067, nColIni + 3060 + (5*(nColA4/6)), Transform(aDados[nX, 14,nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni + 0032, nColIni + 3085 + (5*(nColA4/6)), nLinIni + 0126, nColIni + 3695 + (6*(nColA4/6)))
				oPrint:Say(nLinIni + 0037, nColIni + 3095 + (5*(nColA4/6)), "15 - "+STR0260, oFont01) //"Código Glosa Protocolo"
				oPrint:Say(nLinIni + 0067, nColIni + 3105 + (5*(nColA4/6)), aDados[nX, 15, nX1,nX2], oFont04)

				For nX3 := 1 To Len(aDados[nX, 16, nX1,nX2])

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
					oPrint:Box(nLinIni + 0031, nColIni + 0010, nLinIni + 0125, nColIni + 0426)
					oPrint:Say(nLinIni + 0036, nColIni + 0020, "16 - "+STR0261, oFont01) //"Número da Guia/Senha"
					oPrint:Say(nLinIni + 0066, nColIni + 0030, aDados[nX, 16, nX1,nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0031, nColIni + 0431, nLinIni + 0125, nColIni + 2365)
					oPrint:Say(nLinIni + 0036, nColIni + 0441, "17 - "+STR0262, oFont01) //"Nome do Beneficiário"
					oPrint:Say(nLinIni + 0066, nColIni + 0451, aDados[nX, 17,nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0031, nColIni + 2370, nLinIni + 0125, nColIni + 2786)
					oPrint:Say(nLinIni + 0036, nColIni + 2380, "18 - "+STR0263, oFont01) //"Código do Beneficiário"
					oPrint:Say(nLinIni + 0066, nColIni + 2390, aDados[nX, 18, nX1,nX2, nX3], oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
					lBox:=.F.
					if (nLinIni + 110 + (Len(aDados[nX, 19, nX1,nX2, nX3]) * 45)) < nLinMax
						oPrint:Box(nLinIni + 0030, nColIni + 0010, nLinIni + 110 + (Len(aDados[nX, 19, nX1,nX2, nX3]) * 45), nColIni + 3695 + nColA4)
					Else
				   		oPrint:Line(nLinIni + 0030, nColIni + 0010, nLinIni + 0030, nColIni + 3695 + nColA4)
				  	 	oPrint:Line(nLinIni + 0030, nColIni + 0010, nLinIni + 0150, nColIni + 0010)
			  	   		oPrint:Line(nLinIni + 0030, nColIni + 3695 + nColA4, nLinIni + 0150, nColIni + 3695 + nColA4)
					  	lBox:=.T.
					Endif
					oPrint:Say(nLinIni + 0035, nColIni + 0020, "19 - "+STR0264, oFont01) //"Data Realização"
					oPrint:Say(nLinIni + 0035, nColIni + 0230, "20 - "+STR0265, oFont01) //"Descrição do Serviço"
					oPrint:Say(nLinIni + 0035, nColIni + 1695 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+100,nColA4), "21 - "+STR0044, oFont01) //"Código Tabela"
					oPrint:Say(nLinIni + 0035, nColIni + 1900 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+90,nColA4), "22 - "+STR0266, oFont01) //"Código Serviço"
					oPrint:Say(nLinIni + 0035, nColIni + 2135 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+80,nColA4), "23 - "+STR0225, oFont01) //"Grau Part."
					oPrint:Say(nLinIni + 0035, nColIni + 2450 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+90,nColA4), "24 - "+STR0267, oFont01,,,,1) //"Qtde Exec."
					oPrint:Say(nLinIni + 0035, nColIni + 2720 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+90,nColA4), "25 - "+STR0268, oFont01,,,,1) //"Valor Processado (R$)"
					oPrint:Say(nLinIni + 0035, nColIni + 3050 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+90,nColA4), "26 - "+STR0269, oFont01,,,,1) //"Valor Liberado (R$)"
					oPrint:Say(nLinIni + 0035, nColIni + 3400 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+70,nColA4), "27 - "+STR0270, oFont01,,,,1) //"Valor Glosa (R$)"
					oPrint:Say(nLinIni + 0035, nColIni + 3445 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+60,nColA4), "28 - "+STR0271, oFont01) //"Código Glosa"

					nProcGui := 0
					nLibGui  := 0
					nGloGui  := 0

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60)

					For nX4 := 1 To Len(aDados[nX, 19, nX1,nX2, nX3])

						if lBox
				   			oPrint:Line(nLinIni + 0035, nColIni + 0010, nLinIni + 0090, nColIni  + 0010)
				   			oPrint:Line(nLinIni + 0035, nColIni  + 3695 + nColA4, nLinIni + 0090, nColIni  + 3695 + nColA4)
				   		Endif

						oPrint:Say(nLinIni + 0035, nColIni + 0020, IIf(Empty(aDados[nX, 19, nX1,nX2, nX3, nX4]), "", DtoC(aDados[nX, 19, nX1,nX2, nX3, nX4])), oFont04)
						oPrint:Say(nLinIni + 0035, nColIni + 0230, SubStr(aDados[nX, 20, nX1,nX2, nX3, nX4], 1, 54), oFont04)
						oPrint:Say(nLinIni + 0035, nColIni + 1745 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+100,nColA4), aDados[nX, 21, nX1,nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni + 0035, nColIni + 1905 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+100,nColA4), aDados[nX, 22, nX1,nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni + 0035, nColIni + 2115 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+120,nColA4), aDados[nX, 23, nX1,nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni + 0035, nColIni + 2420 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+100,nColA4), IIf(Empty(aDados[nX, 24, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 24, nX1, nX2, nX3, nX4], "@E 9999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0035, nColIni + 2700 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+100,nColA4), IIf(Empty(aDados[nX, 25, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 25, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0035, nColIni + 3050 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+100,nColA4), IIf(Empty(aDados[nX, 26, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 26, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0035, nColIni + 3400 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+100,nColA4), IIf(Empty(aDados[nX, 27, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 27, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0035, nColIni + 3445 + IIf(nLayout == 2 .Or.nLayout == 3,nColA4+110,nColA4), aDados[nX, 28,nX1,nX2, nX3, nX4], oFont04)
						nProcGui += aDados[nX, 25, nX1, nX2, nX3, nX4]
						nLibGui  += aDados[nX, 26, nX1, nX2, nX3, nX4]
						nGloGui  += aDados[nX, 27, nX1, nX2, nX3, nX4]
					   	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)

					Next nX4

					//Para arrumar o Box qdo tem muitos procedimentos e ultrapassam o tamanho da folha ->Luciano
					if lBox
				  	 	oPrint:Line(nLinIni + 0035, nColIni + 0010, nLinIni + 0045, nColIni + 0010)
			  	   		oPrint:Line(nLinIni + 0035, nColIni + 3695 + nColA4, nLinIni + 0045, nColIni + 3695 + nColA4)
			  	   		oPrint:Line(nLinIni + 0045, nColIni + 0010, nLinIni + 0045, nColIni + 3695 + nColA4)
					Endif

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30)
					oPrint:Box(nLinIni + 0038, nColIni + 0010, nLinIni + 0142, nColIni + 3695 + nColA4)
					oPrint:Say(nLinIni + 0043, nColIni + 0020, STR0272, oFont01) //"Total Guia"
					oPrint:Box(nLinIni + 0043, nColIni + 2375 + nColA4, nLinIni + 0137, nColIni + 2720 + nColA4)
					oPrint:Say(nLinIni + 0048, nColIni + 2385 + nColA4, "29 - "+STR0273, oFont01) //"Valor Processado Guia (R$)"
					oPrint:Say(nLinIni + 0078, nColIni + 2700 + nColA4, Transform(nProcGui, "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni + 0043, nColIni + 2725 + nColA4, nLinIni + 0137, nColIni + 3070 + nColA4)
					oPrint:Say(nLinIni + 0048, nColIni + 2735 + nColA4, "30 - "+STR0274, oFont01) //"Valor Liberado Guia (R$)"
					oPrint:Say(nLinIni + 0078, nColIni + 3050 + nColA4, Transform(nLibGui, "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni + 0043, nColIni + 3075 + nColA4, nLinIni + 0137, nColIni + 3420 + nColA4)
					oPrint:Say(nLinIni + 0048, nColIni + 3085 + nColA4, "31 - "+STR0275, oFont01) //"Valor Glosa Guia (R$)"
					oPrint:Say(nLinIni + 0078, nColIni + 3400 + nColA4, Transform(nGloGui, "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni + 0043, nColIni + 3425 + nColA4, nLinIni + 0137, nColIni + 3690 + nColA4)
					oPrint:Say(nLinIni + 0048, nColIni + 3435 + nColA4, "32 - "+STR0276, oFont01) //"Código Glosa Guia"
					oPrint:Say(nLinIni + 0078, nColIni + 3445 + nColA4, "", oFont04)
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, IIf(nLayout == 2,30,100))

					nProcFat += nProcGui
					nLibFat  += nLibGui
					nGloFat  += nGloGui
				Next nX3

			Next nX2

		  	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
			oPrint:Box(nLinIni + 0047, nColIni + 0010, nLinIni + 0151, nColIni + 3695 + nColA4)
			oPrint:Say(nLinIni + 0052, nColIni + 0020, STR0277, oFont01) //"Total Fatura"
			oPrint:Box(nLinIni + 0052, nColIni + 2375 + nColA4, nLinIni + 0146, nColIni + 2720 + nColA4)
			oPrint:Say(nLinIni + 0057, nColIni + 2385 + nColA4, "33 - "+STR0278, oFont01) //"Valor Processado Fatura (R$)"
			oPrint:Say(nLinIni + 0087, nColIni + 2700 + nColA4, Transform(nProcFat, "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box(nLinIni + 0052, nColIni + 2725 + nColA4, nLinIni + 0146, nColIni + 3070 + nColA4)
			oPrint:Say(nLinIni + 0057, nColIni + 2735 + nColA4, "34 - "+STR0279, oFont01) //"Valor Liberado Fatura (R$)"
			oPrint:Say(nLinIni + 0087, nColIni + 3050 + nColA4, Transform(nLibFat, "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box(nLinIni + 0052, nColIni + 3075 + nColA4, nLinIni + 0146, nColIni + 3420 + nColA4)
			oPrint:Say(nLinIni + 0057, nColIni + 3085 + nColA4, "35 - "+STR0280, oFont01) //"Valor Glosa Fatura (R$)"
			oPrint:Say(nLinIni + 0087, nColIni + 3400 + nColA4, Transform(nGloFat, "@E 999,999,999.99"), oFont04,,,,1)


			nProcGer += nProcFat
			nLibGer  += nLibFat
			nGloGer  += nGloFat

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
			oPrint:Box(nLinIni + 0056, nColIni + 0010, nLinIni + 0160, nColIni + 3695 + nColA4)
			oPrint:Say(nLinIni + 0061, nColIni + 0020, STR0281, oFont01) //"Total Geral"
			oPrint:Box(nLinIni + 0061, nColIni + 2375 + nColA4, nLinIni + 0155, nColIni + 2720 + nColA4)
			oPrint:Say(nLinIni + 0066, nColIni + 2385 + nColA4, "36 - "+STR0282, oFont01) //"Valor Processado Geral (R$)"
			oPrint:Say(nLinIni + 0096, nColIni + 2700 + nColA4, Transform(nProcGer, "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box(nLinIni + 0061, nColIni + 2725 + nColA4, nLinIni + 0155, nColIni + 3070 + nColA4)
			oPrint:Say(nLinIni + 0066, nColIni + 2735 + nColA4, "37 - "+STR0283, oFont01) //"Valor Liberado Geral (R$)"
			oPrint:Say(nLinIni + 0096, nColIni + 3050 + nColA4, Transform(nLibGer, "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box(nLinIni + 0061, nColIni + 3075 + nColA4, nLinIni + 0155, nColIni + 3420 + nColA4)
			oPrint:Say(nLinIni + 0066, nColIni + 3085 + nColA4, "38 - "+STR0284, oFont01) //"Valor Glosa Geral (R$)"
			oPrint:Say(nLinIni + 0096, nColIni + 3400 + nColA4, Transform(nGloGer, "@E 999,999,999.99"), oFont04,,,,1)

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)

		Next nX1


	oPrint:EndPage()	// Finaliza a pagina

	Next nX

	if lAuto
		oPrint:Print()
	else
		oPrint:Preview() // Visualiza impressao grafica antes de imprimir
	endIf

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS8  ³ Autor ³ Luciano Aparecido     ³ Data ³ 05.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Demons Pagamento)-BOPS 095189³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISS8(aDados, nLayout, cLogoGH, lAuto)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local cFileLogo
	Local lPrinter
	Local nI, nJ, nX, nX1
	Local oFont01
	Local oFont02n
	Local oFont04
	Local lBox
	Local  cStartPath	:= GetSrvProfString("Startpath","")
	Local cFileName := ""

	Default nLayout := 2
	Default cLogoGH := ''
	Default lAuto   := .F.
	Default aDados  := { { ;
						"123456",;
						Replicate("M",70),;
						"14.141.114/00001-35",;
						{"123456789102"},;
						{CtoD("12/01/06")},;
						{"14.141.114/00001-35"},;
						{Replicate("M",70)},;
						{"1234567"},;
						{CtoD("12/01/06")},;
						{{ "X", "X", "X" }},;
						{"1234567890"},;
						{"1234567890"},;
						{"12345678910234567892"},;
						{{ Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("B",12),Replicate("C",12),Replicate("D",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12)}},;
						{{ Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("B",12),Replicate("C",12),Replicate("D",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12)}},;
						{{ CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/01/06"),CtoD("12/02/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06") }},;
						{{ Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("9",12),Replicate("B",12),Replicate("C",12),Replicate("D",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12),Replicate("E",12)}},;
						{{ 999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,222.00,333.00,444.00,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99 }},;
						{{ 999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,222.00,333.00,444.00,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99 }},;
						{{ 999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,22222.22,33.33,44444.44,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,911111.11,911111.11,911111.11,911111.11,911111.11,911111.11 }},;
						{{ 999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,999999999.99,22222.22,33.33,44444.44,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,911111.11,911111.11,911111.11,911111.11,911111.11,911111.11 }},;
						{999999999.99},;
						{999999999.99},;
						{999999999.99},;
						{999999999.99},;
						{999999999.99},;
						{{ { Replicate("M", 70), 999999999.99 },{ Replicate("M", 70), 999999999.99 },{ Replicate("M", 70), 999999999.99 },;
						  { Replicate("M", 70), 999999999.99 },{ Replicate("M", 70), 999999999.99 },{ Replicate("M", 70), 999999999.99 },;
						  { Replicate("M", 70), 999999999.99 },{ Replicate("M", 70), 999999999.99 },{ Replicate("M", 70), 999999999.99 },{ Replicate("M", 70), 999999999.99 }} },;
						{999999999.99} } }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2375
		nColMax	:=	3370 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  08,  08, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	If lAuto
		cPathSrvJ := GETMV("MV_RELT")
		cFileName := "pdfauto"+lower(CriaTrab(NIL,.F.))+".pdf"
		oPrint    := FWMSPrinter():New ( cFileName,,.F., cPathSrvJ,.T.,nil,@oPrint,nil,nil,.F.,.F.)
		oPrint:lServer := .T.
		oPrint:cPathPDF := cPathSrvJ
	Else
		oPrint	:= TMSPrinter():New(STR0285) //"DEMONSTRATIVO DE PAGAMENTO"
	EndIf

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()

	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf ! lPrinter
		oPrint:Setup()
	EndIf

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 14 To 21
			If Len(aDados[nX, nI]) < 1
				For nJ := Len(aDados[nX, nI]) + 1 To 20
					If AllTrim(Str(nI)) $ "16"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "18,19,20,21"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 27 To 27
			If Len(aDados[nX, nI]) < 1
				aAdd(aDados[nX, nI], { "", 0 })
			EndIf
		Next nI

	For nX1 := 1 To Len(aDados[nX, 04])

		If nX1 > 1
		 	oPrint:EndPage()
		Endif

		nLinIni := 0
		nColIni := 0
		nColA4  := 0

		oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//fLogoEmp(@cFileLogo,, cLogoGH)
		//fLogoEmp(@cFileLogo,"1",)
		cCompany := FWGrpCompany()
		cFileLogo  := cStartPath + "LGRL"+cCompany+FWCodFil()+".BMP" 	// Empresa+Filial
		cFileLogo1 := cStartPath + "LGRL"+cCompany+".BMP" 				// Empresa

		If File(cFilelogo)
			oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
		Else
		    oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, cFileLogo1, 400, 090) 		// Tem que estar abaixo do RootPath
		EndIf

		//If !File(cFileLogo) .OR. !File(cFileLogo1)
		//	oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, "\SYSTEM\LGRL.BMP", 400, 090) 		// Tem que estar abaixo do RootPath
	    //EndIf

		If nLayout == 2 // Papél A4
		  	nColA4    := -0335
		Elseif nLayout == 3// Carta
			nColA4    := -0530
		Endif

		oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIF(nLayout == 2 .Or. nLayout == 3,nColA4+250,0), STR0285, oFont02n,,,, 2) //"DEMONSTRATIVO DE PAGAMENTO"

		nLinIni += 60
		oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, nColIni + 0315)
		oPrint:Say(nLinIni + 0180, nColIni + 0020, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say(nLinIni + 0210, nColIni + 0030, aDados[nX, 01], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 0320, nLinIni + 0269, nColIni + 2265 + nColA4)
		oPrint:Say(nLinIni + 0180, nColIni + 0330, "2 - "+STR0247, oFont01) //"Nome da Operadora"
		oPrint:Say(nLinIni + 0210, nColIni + 0340, aDados[nX, 02], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 2270 + nColA4, nLinIni + 0269, nColIni + 2735 + nColA4)
		oPrint:Say(nLinIni + 0180, nColIni + 2280 + nColA4, "3 - "+STR0248, oFont01) //"CNPJ Operadora"
		oPrint:Say(nLinIni + 0210, nColIni + 2290 + nColA4, aDados[nX, 03], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 2740 + nColA4, nLinIni + 0269, nColIni + 3290 + nColA4)
		oPrint:Say(nLinIni + 0180, nColIni + 2750 + nColA4, "4 - "+STR0249, oFont01) //"Número do Demonstrativo"
	   	oPrint:Say(nLinIni + 0210, nColIni + 2760 + nColA4, aDados[nX, 04, nX1], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 3295 + nColA4, nLinIni + 0269, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0180, nColIni + 3305 + nColA4, "5 - "+STR0250, oFont01) //"Data Emissão do Demonstrativo"
		oPrint:Say(nLinIni + 0210, nColIni + 3315 + nColA4, DtoC(aDados[nX, 05, nX1]), oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0274, nColIni + 0010, STR0251, oFont01) //"Dados do Prestador"
		oPrint:Box(nLinIni + 0304, nColIni + 0010, nLinIni + 0398, nColIni + 0426)
		oPrint:Say(nLinIni + 0309, nColIni + 0020, "6 - "+STR0252, oFont01) //"Código Prestador / CNPJ / CPF"
		oPrint:Say(nLinIni + 0339, nColIni + 0030, aDados[nX, 06, nX1], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 0431, nLinIni + 0398, nColIni + 2365)
		oPrint:Say(nLinIni + 0309, nColIni + 0441, "7 - "+STR0009, oFont01) //"Nome"
		oPrint:Say(nLinIni + 0339, nColIni + 0451, aDados[nX, 07, nX1], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 2370, nLinIni + 0398, nColIni + 2580)
		oPrint:Say(nLinIni + 0309, nColIni + 2380, "8 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say(nLinIni + 0339, nColIni + 2390, aDados[nX, 08, nX1], oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0403, nColIni + 0010, STR0286, oFont01) //"Dados do Pagamento"
		oPrint:Box(nLinIni + 0433, nColIni + 0010, nLinIni + 0527, nColIni + 0526)
		oPrint:Say(nLinIni + 0438, nColIni + 0020, "9 - "+STR0287, oFont01) //"Data do Pagamento"
		oPrint:Say(nLinIni + 0468, nColIni + 0030, DtoC(aDados[nX, 09, nX1]), oFont04)
		oPrint:Box(nLinIni + 0433, nColIni + 0531, nLinIni + 0527, nColIni + 1201)
		oPrint:Say(nLinIni + 0438, nColIni + 0541, "10 - "+STR0288, oFont01) //"Forma de Pagamento"
		oPrint:Line(nLinIni + 0463, nColIni + 0541, nLinIni + 0510, nColIni + 0541)
		oPrint:Line(nLinIni + 0510, nColIni + 0541, nLinIni + 0510, nColIni + 0588)
		oPrint:Line(nLinIni + 0463, nColIni + 0588, nLinIni + 0510, nColIni + 0588)
		oPrint:Say(nLinIni + 0468, nColIni + 0554, aDados[nX, 10, nX1,1], oFont04)
		oPrint:Say(nLinIni + 0478, nColIni + 0611, STR0289, oFont01) //"Crédito em Conta"
		oPrint:Line(nLinIni + 0463, nColIni + 0791, nLinIni + 0510, nColIni + 0791)
		oPrint:Line(nLinIni + 0510, nColIni + 0791, nLinIni + 0510, nColIni + 0838)
		oPrint:Line(nLinIni + 0463, nColIni + 0838, nLinIni + 0510, nColIni + 0838)
		oPrint:Say(nLinIni + 0468, nColIni + 0804, aDados[nX, 10, nX1,2], oFont04)
		oPrint:Say(nLinIni + 0478, nColIni + 0861, STR0290, oFont01) //"Carteira"
		oPrint:Line(nLinIni + 0463, nColIni + 0961, nLinIni + 0510, nColIni + 0961)
		oPrint:Line(nLinIni + 0510, nColIni + 0961, nLinIni + 0510, nColIni + 1008)
		oPrint:Line(nLinIni + 0463, nColIni + 1008, nLinIni + 0510, nColIni + 1008)
		oPrint:Say(nLinIni + 0468, nColIni + 0974, aDados[nX, 10, nX1,3], oFont04)
		oPrint:Say(nLinIni + 0478, nColIni + 1031, STR0291, oFont01) //"Boleto Bancário"
		oPrint:Box(nLinIni + 0433, nColIni + 1206, nLinIni + 0527, nColIni + 1456)
		oPrint:Say(nLinIni + 0438, nColIni + 1216, "11 - "+STR0292, oFont01) //"Banco"
		oPrint:Say(nLinIni + 0468, nColIni + 1226, aDados[nX, 11, nX1], oFont04)
		oPrint:Box(nLinIni + 0433, nColIni + 1461, nLinIni + 0527, nColIni + 1711)
		oPrint:Say(nLinIni + 0438, nColIni + 1471, "12 - "+STR0293, oFont01) //"Agência"
		oPrint:Say(nLinIni + 0468, nColIni + 1481, aDados[nX, 12, nX1], oFont04)
		oPrint:Box(nLinIni + 0433, nColIni + 1716, nLinIni + 0527, nColIni + 2130)
		oPrint:Say(nLinIni + 0438, nColIni + 1726, "13 - "+STR0294, oFont01) //"Número da conta/Cheque"
		oPrint:Say(nLinIni + 0468, nColIni + 1736, aDados[nX, 13, nX1], oFont04)

   		lBox:=.F.
		oPrint:Say(nLinIni + 0532, nColIni + 0010, STR0295, oFont01) //"Dados do Resumo"

		if (nLinIni + 645 + (Len(aDados[nX, 14, nX1]) * 45)) < nLinMax
			oPrint:Box(nLinIni + 0562, nColIni + 0010, nLinIni + 645 + (Len(aDados[nX, 14, nX1]) * 45), nColIni + 3695 + nColA4)
		Else
			oPrint:Line(nLinIni + 0562, nColIni + 0010, nLinIni + 0045, nColIni + 3695 + nColA4)
		 	oPrint:Line(nLinIni + 0562, nColIni + 0010, nLinIni + 0090, nColIni + 0010)
		 	oPrint:Line(nLinIni + 0562, nColIni + 3695 + nColA4, nLinIni + 0090, nColIni + 3695 + nColA4)
		  	lBox:=.T.
		Endif

		oPrint:Say(nLinIni + 0567, nColIni + 0020, "14 - "+STR0254, oFont01) //"Número da Fatura"
		oPrint:Say(nLinIni + 0567, nColIni + 0520, "15 - "+STR0255, oFont01) //"Número do Lote"
		oPrint:Say(nLinIni + 0567, nColIni + 1020, "16 - "+STR0256, oFont01) //"Data de Envio do Lote"
		oPrint:Say(nLinIni + 0567, nColIni + 1320, "17 - "+STR0257, oFont01) //"Número do Protocolo"
		oPrint:Say(nLinIni + 0567, nColIni + 2173 + nColA4/2, "18 - "+STR0296, oFont01,,,,1) //"Valor Informado (R$)"
		oPrint:Say(nLinIni + 0567, nColIni + 2582 + nColA4/2, "19 - "+STR0268, oFont01,,,,1) //"Valor Processado (R$)"
		oPrint:Say(nLinIni + 0567, nColIni + 2991 + nColA4/2, "20 - "+STR0269, oFont01,,,,1) //"Valor Liberado (R$)"
		oPrint:Say(nLinIni + 0567, nColIni + 3350 + nColA4/2, "21 - "+STR0297, oFont01,,,,1) //"Valor da Glosa (R$)"

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 600)

		For nI := 1 To Len(aDados[nX, 14, nX1])

			if lBox
				oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0115, nColIni  + 0010)
				oPrint:Line(nLinIni + 0010, nColIni  + 3695 + nColA4, nLinIni + 0115, nColIni  + 3695 + nColA4)
			Endif

			oPrint:Say(nLinIni + 0010, nColIni + 0020, aDados[nX, 14, nX1, nI], oFont04)
			oPrint:Say(nLinIni + 0010, nColIni + 0520, aDados[nX, 15, nX1, nI], oFont04)
			oPrint:Say(nLinIni + 0010, nColIni + 1020, IIf(Empty(aDados[nX, 14, nX1, nI]), "", DtoC(aDados[nX, 16, nX1, nI])), oFont04)
			oPrint:Say(nLinIni + 0010, nColIni + 1320, aDados[nX, 17, nX1, nI], oFont04)
			oPrint:Say(nLinIni + 0010, nColIni + 2173 + nColA4/2, IIf(Empty(aDados[nX, 14, nX1, nI]), "", Transform(aDados[nX, 18, nX1, nI], "@E 999,999,999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0010, nColIni + 2582 + nColA4/2, IIf(Empty(aDados[nX, 14, nX1, nI]), "", Transform(aDados[nX, 19, nX1, nI], "@E 999,999,999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0010, nColIni + 2991 + nColA4/2, IIf(Empty(aDados[nX, 14, nX1, nI]), "", Transform(aDados[nX, 20, nX1, nI], "@E 999,999,999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0010, nColIni + 3350 + nColA4/2, IIf(Empty(aDados[nX, 14, nX1, nI]), "", Transform(aDados[nX, 21, nX1, nI], "@E 999,999,999.99")), oFont04,,,,1)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
		Next nI

		//Para arrumar o Box qdo tem muitas faturas ->Luciano
		if lBox
		 	oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0090, nColIni + 0010)
			oPrint:Line(nLinIni + 0010, nColIni + 3695 + nColA4, nLinIni + 0090, nColIni + 3695 + nColA4)
			oPrint:Line(nLinIni + 0020, nColIni + 0010, nLinIni + 0020, nColIni + 3695 + nColA4)
		Endif

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
		oPrint:Box(nLinIni + 0027, nColIni + 0010, nLinIni + 0131, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0032, nColIni + 0020, STR0281, oFont01) //"Total Geral"
		oPrint:Box(nLinIni + 0032, nColIni + 1789 + nColA4, nLinIni + 0126, nColIni + 2193 + nColA4)
		oPrint:Say(nLinIni + 0036, nColIni + 1799 + nColA4, "22 - " + STR0298, oFont01) //"Total Geral Valor Informado (R$)"
		oPrint:Say(nLinIni + 0066, nColIni + 2173 + nColA4, Transform(aDados[nX, 22, nX1], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 0032, nColIni + 2198 + nColA4, nLinIni + 0126, nColIni + 2602 + nColA4)
		oPrint:Say(nLinIni + 0036, nColIni + 2208 + nColA4, "23 - "+STR0299, oFont01) //"Total Geral Valor Processado (R$)"
		oPrint:Say(nLinIni + 0066, nColIni + 2582 + nColA4, Transform(aDados[nX, 23, nX1], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 0032, nColIni + 2607 + nColA4, nLinIni + 0126, nColIni + 3011 + nColA4)
		oPrint:Say(nLinIni + 0036, nColIni + 2617 + nColA4, "24 - "+STR0300, oFont01) //"Total Geral Valor Liberado (R$)"
		oPrint:Say(nLinIni + 0066, nColIni + 2991 + nColA4, Transform(aDados[nX, 24, nX1], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 0032, nColIni + 3016 + nColA4, nLinIni + 0126, nColIni + 3420 + nColA4)
		oPrint:Say(nLinIni + 0036, nColIni + 3026 + nColA4, "25 - "+STR0301, oFont01) //"Total Geral Glosa (R$)"
		oPrint:Say(nLinIni + 0066, nColIni + 3400 + nColA4, Transform(aDados[nX, 25, nX1], "@E 999,999,999.99"), oFont04,,,,1)

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
		oPrint:Box(nLinIni + 0036, nColIni + 0010, nLinIni + 0140, nColIni + 3695 + nColA4)
		oPrint:Box(nLinIni + 0041, nColIni + 3016 + nColA4, nLinIni + 0135, nColIni + 3420 + nColA4)
		oPrint:Say(nLinIni + 0046, nColIni + 0020 + nColA4, "26 - "+STR0302, oFont01) //"Total Valor"
		oPrint:Say(nLinIni + 0076, nColIni + 3400 + nColA4, Transform(aDados[nX, 26, nX1], "@E 999,999,999.99"), oFont04,,,,1)

		lBox:=.F.
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)

		if (nLinIni + 110 + (Len(aDados[nX, 27, nX1]) * 45)) < nLinMax
			oPrint:Box(nLinIni + 0045, nColIni + 0010, nLinIni + 110 + (Len(aDados[nX, 27, nX1]) * 45), nColIni + 3695 + nColA4)
		Else
			oPrint:Line(nLinIni + 0045, nColIni + 0010, nLinIni + 0045, nColIni + 3695 + nColA4)
		 	oPrint:Line(nLinIni + 0045, nColIni + 0010, nLinIni + 0090, nColIni + 0010)
		 	oPrint:Line(nLinIni + 0045, nColIni + 3695 + nColA4, nLinIni + 0090, nColIni + 3695 + nColA4)
		  	lBox:=.T.
		Endif

		oPrint:Say(nLinIni + 0050, nColIni + 0020, "27 - "+STR0303, oFont01) //"Demais Descontos ou Créditos"

		For nI := 1 To Len(aDados[nX, 27, nX1])

			if lBox
				oPrint:Line(nLinIni + 0045, nColIni + 0010, nLinIni + 0115, nColIni  + 0010)
				oPrint:Line(nLinIni + 0045, nColIni  + 3695 + nColA4, nLinIni + 0115, nColIni  + 3695 + nColA4)
			Endif

			oPrint:Say(nLinIni + 0085, nColIni + 0030, aDados[nX, 27, nX1, nI, 1], oFont04)
			oPrint:Say(nLinIni + 0085, nColIni + 3400 + nColA4, IIf(Empty(aDados[nX, 27, nX1, nI, 1]), "", Transform(aDados[nX, 27, nX1, nI, 2], "@E 999,999,999,999.99")), oFont04,,,,1)
		   	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)

		Next nI

		//Para arrumar o Box qdo tem muitos demais descontos ou créditos ->Luciano
		if lBox
		 	oPrint:Line(nLinIni + 0045, nColIni + 0010, nLinIni + 0090, nColIni + 0010)
			oPrint:Line(nLinIni + 0045, nColIni + 3695 + nColA4, nLinIni + 0090, nColIni + 3695 + nColA4)
			oPrint:Line(nLinIni + 0090, nColIni + 0010, nLinIni + 0090, nColIni + 3695 + nColA4)
		Endif

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60)
		oPrint:Box(nLinIni + 0056, nColIni + 0010, nLinIni + 0160, nColIni + 3695 + nColA4)
		oPrint:Box(nLinIni + 0061, nColIni + 3016 + nColA4, nLinIni + 0155, nColIni + 3420 + nColA4)
		oPrint:Say(nLinIni + 0066, nColIni + 0020 + nColA4, "28 - "+STR0304, oFont01) //"Total Valor Liberado"
		oPrint:Say(nLinIni + 0096, nColIni + 3400 + nColA4, Transform(aDados[nX, 28, nX1], "@E 999,999,999,999.99"), oFont04,,,,1)

	Next nX1

	oPrint:EndPage()	// Finaliza a pagina


Next nX

	if lAuto
		oPrint:Print()
	else
		oPrint:Preview() // Visualiza impressao grafica antes de imprimir
	endIf

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS9  ³ Autor ³ Luciano Aparecido     ³ Data ³ 10.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Odontológica - Cobrança)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISS9(aDados, nLayout, cLogoGH, lGerTXT, lWeb, cPathRelW) //Guia Odontológica - Cobrança

	Local nLinMax		:= 0
	Local nColMax		:= 0
	Local nLinIni		:= 0		// Linha Lateral (inicial) Esquerda
	Local nColIni		:= 0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    	:= 0
	Local cFileLogo		:= ""
  	Local nLin			:= 0
	Local nX			:= 0
	Local nI, nJ		:= 0
	Local cObs			:= ""
	Local oFont01		:= nil
	Local oFont02n		:= nil
	Local oFont03n		:= nil
	Local oFont04		:= nil
	Local oPrint    	:= Nil
	Local nT        	:= 0
	Local nP			:= 0
	Local nAte 			:= 20
	Local lImpnovo 		:= .T.
	Local nVolta		:= 0
	Local cMsg 			:= ""
	LOCAL cFileName		:= ""
	LOCAL cRel      	:= "GUICONS"
	LOCAL cPathSrvJ 	:= GETMV("MV_RELT")
	LOCAL nAL			:= 0.25
	LOCAL nAC			:= 0.24
	LOCAL cImpDatRea	:= IIF(BD5->BD5_LIBERA=="0","S",GetNewPar("MV_PLSIMDR","S")) //Habilita/Desabilita a impressão do campo (Data Realização) na Guia Odontológica (S ou N).
	local aBoxCab		:= {0/*nBoxIni*/, 0/*nBoxFim*/, 0/*nSaylbl*/, 0/*nSayTxt*/}
	local lTiss4Rel		:= PLSTISSVER() >= "4"
	DEFAULT lGerTXT 	:= .F.
	DEFAULT nLayout 	:= 2
	DEFAULT cLogoGH 	:= ""
	DEFAULT lWeb		:= .F.
	DEFAULT cPathRelW 	:= ""
	DEFAULT aDados  	:= { { ;
							"123456",;                      //1 - Registro ANS
							"12345678901234567892",;
							CtoD("05/03/07"),;
							CtoD("05/03/07"),;
							"12345678901234567892",;        //5 - Senha
							CtoD("01/12/07"),;
							"12345678901234567892",;
							"12345678901234567892",;
							Replicate("M",40),;
							Replicate("M",40),;             //10 - Empresa
							CtoD("01/12/07"),;
							"123456789012345",;
							Replicate("M",70),;
							"1199999999",;
							Replicate("M",40),;             //15 - Nome do títular do plano
							Replicate("M",70),;
							"123456789012345",;
							"SP",;
							"12345",;
							"14.141.114/00001-35",;			//20 - Código na Operadora / CNPJ / CPF
							Replicate("M",70),;
							"123456789012345",;
							"SP",;
							"1234567",;
							Replicate("M",70),;             //25 - Profissional Executante
							"123456789012345",;
							"SP",;
							"12345",;
							{"AA","BB","CC","DD","EE","FF","GG","HH","II","JJ","KK","LL","MM","NN","OO","PP"},;
					    	{"1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890"},;
							{Replicate("M",40),Replicate("M",40),Replicate("M",40),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70)},;
							{"1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234"},;
							{"ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE"},;
							{10,20,30,40,50,60,70,80,90,15,25,35,45,55,65,75},;
							{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99},;
							{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99},;
							{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99},;
							{"A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A"},;
							{CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07")},;
							{"","","","","","","","","","","","","","","",""},;             //Posição 40
							CtoD("01/04/07"),;
							"1",;
							"1",;
				   			999999.99,;
							999999.99,;
							999999.99,;
							Replicate("M", 240),;
					 		CtoD("30/12/07"),;
					 		Replicate("M",30),;
							CtoD("30/12/07"),;
							Replicate("M",30),;
							CtoD("30/12/07"),;
							Replicate("M",30),;
							CtoD("30/12/07"),;
							Replicate("M",30)} }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2290
		nColMax	:=	3350 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  4,  4, , .F., , , , .T., .F.) // Normal
	oFontSt		:= TFont():New("Arial",  4,  5, , .t., , , , .f., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n := TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n := TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04	 := TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Endif

	//Nao permite acionar a impressao quando for na web.
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+CriaTrab(NIL,.F.)+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	If !lWeb
		oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
	Else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
	EndIf
	
	//Tratamento para impressao via job
	oPrint:lServer := lWeb

	//Caminho do arquivo
	oPrint:cPathPDF := cPathSrvJ

	//Modo paisagem
	oPrint:SetLandscape()

	If nLayout ==2
		//Papél A4
		oPrint:SetPaperSize(9)
	ElseIf nLayout ==3
		//Papél Carta
		oPrint:SetPaperSize(1)
	Else
		//Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		oPrint:SetPaperSize(14)
	Endif
	
	//Device
	If lWeb
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	EndIf

	//Verifica se existe alguma impressora configurada para Impressao Grafica
	If  !lWeb
		oPrint:Setup()
		If (oPrint:nModalResult == 2) // Clicou no botao cancelar
			lRet := .F.
			lMail := .F.
			Return
		Else
			lImpnovo:=(oPrint:nModalResult == 1)
		Endif
	EndIf

	While lImpnovo
	 	
		lImpnovo:=.F.
	 	nVolta 	+= 1
		nT         += 20 
		
		For nX := 1 To Len(aDados)

			If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
				Loop
			EndIf
			
			If nP == 1 //signifiga que ja carrego os itens e ja esta imprimindo as paginas seguintes da guia
				For nI := 30 To 42
					If Len(aDados[nX, nI]) < nAte
						For nJ := Len(aDados[nX, nI]) + 1 To nAte
							If AllTrim(Str(nI)) $ "35,36,37,38"
								aAdd(aDados[nX, nI], 0)
							ElseiF AllTrim(Str(nI)) $ "41"
								aAdd(aDados[nX, nI], StoD(""))
							Else
								aAdd(aDados[nX, nI],"")
							EndIf
						Next nJ
					EndIf
				Next nI
			EndIf

	   		If oPrint:Cprinter == "PDF" .OR. lWeb
				nLinIni := 130
				nColMax -= 15
			Else
				nLinIni := 080
			Endif
			nColIni := 080
			nColA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina

			//Box Principal
			oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

			//Carrega e Imprime Logotipo da Empresa
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
			  	nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1482 + IIF(nLayout ==2 .Or. nLayout ==3,nColA4+160,0))*nAC, STR0384, oFont02n,,,, 2) //"GUIA TRATAMENTO ODONTOLÓGICO"
			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 2900 + nColA4)*nAC, "2-"+STR0002, oFont01) //"Nº da guia no prestador"
			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 3096 + nColA4)*nAC, aDados[nX, 02], oFont03n)

			nLinIni+= 10
			aBoxCab := {145, 225, 170, 205} // {nBoxIni, nBoxFim, nSaylbl, nSayTxt}
			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0010)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 0315)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0020)*nAC, "1 - "+STR0003, oFont01) //"Registro ANS"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0030)*nAC, aDados[nX, 01], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0320)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 0700)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0330)*nAC, "3 - "+STR0308, oFont01) //"Número da Guia Principal"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0340)*nAC, aDados[nX, 03], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0705)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 1035)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0715)*nAC, "4 - "+STR0062, oFont01) //"Data da Autorização"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0725)*nAC, DtoC(aDados[nX, 04]), oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 1040)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 1395)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 1050)*nAC, "5 - "+STR0063, oFont01) //"Senha"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 1060)*nAC, aDados[nX, 05], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 1400)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 1765)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 1410)*nAC, "6 - "+STR0064, oFont01) //"Data Validade da Senha"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 1420)*nAC, DtoC(aDados[nX, 06]), oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 1770)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2375)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 1780)*nAC, "7 - "+STR0452, oFont01) //"Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 1790)*nAC, aDados[nX, 07], oFont04)

		    nLinIni += 10
			aBoxCab := {260, 340, 285, 320} // {nBoxIni, nBoxFim, nSaylbl, nSayTxt}
			oPrint:Say((nLinIni + 0250)*nAL, (nColIni + 0010)*nAC, STR0005, oFontSt) //"Dados do Beneficiário"
			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0010)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 0415)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0020)*nAC, "8 - "+STR0006, oFont01) //"Número da Carteira"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0030)*nAC, aDados[nX, 08], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0420)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 1770 + nColA4)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0430)*nAC, "9 - "+STR0007, oFont01) //"Plano"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0440)*nAC, aDados[nX, 09], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 1775 + nColA4)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2835 + nColA4)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 1785 + nColA4)*nAC, "10 - "+STR0309, oFont01) //"Empresa"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 1795 + nColA4)*nAC, aDados[nX, 10], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2840 + nColA4)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 3145 + nColA4)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2850 + nColA4)*nAC, "11 - "+STR0310, oFont01) //"Data Validade da Carteira"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2860 + nColA4)*nAC, DtoC(aDados[nX, 11]), oFont04)

			if !lTiss4Rel
				oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 3150 + nColA4)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 3590 + nColA4)*nAC)
				oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 3160 + nColA4)*nAC, "12 - " + STR0535, oFont01) //"Número do Cartão Nacional de Saúde"
				oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 3170 + nColA4)*nAC, aDados[nX, 12], oFont04)
			endif
			if lTiss4Rel .and. BA1->( FieldPos("BA1_NOMSOC") ) > 0
				oPrint:Box((nLinIni + 0350)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0430)*nAL, (nColIni + 1800 + nColA4)*nAC)
				oPrint:Say((nLinIni + 0375)*nAL, (nColIni + 0020)*nAC, "57 - " + STR0536, oFont01) //"Nome Social"
				oPrint:Say((nLinIni + 0410)*nAL, (nColIni + 0030)*nAC, aDados[nX, 58], oFont04)
			endif 

			aBoxCab := {440, 512, 465, 500} // {nBoxIni, nBoxFim, nSaylbl, nSayTxt}
			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0010)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 1800 + nColA4)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0020)*nAC, "13 - "+STR0009, oFont01) //"Nome"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0030)*nAC, aDados[nX, 13], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 1805 + nColA4)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2135 + nColA4)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 1815 + nColA4)*nAC, "14 - "+STR0311, oFont01) //"Telefone"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 1825 + nColA4)*nAC, aDados[nX, 14], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2140 + nColA4)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 3185 + nColA4)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2150 + nColA4)*nAC, "15 - "+STR0312, oFont01) //"Nome do Titular do Plano"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2160 + nColA4)*nAC, aDados[nX, 15], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 3195 + nColA4)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 3590 + nColA4)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 3205 + nColA4)*nAC, "16 - "+STR0423, oFont01) //"Atendimento a RN"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 3215 + nColA4)*nAC, aDados[nX, 16], oFont04)

			nLinIni += 10
			aBoxCab := {540, 620, 565, 600} // {nBoxIni, nBoxFim, nSaylbl, nSayTxt}
			oPrint:Say((nLinIni + 0530)*nAL, (nColIni + 0010)*nAC, STR0385, oFontSt) 		 //"Dados do Contratado Responsável pelo Tratamento"
			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0010)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2410)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0020)*nAC, "17 - " + STR0066, oFont01) //"Nome do Profissional Solicitante"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0030)*nAC, aDados[nX, 17], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2415)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2745)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2425)*nAC, "18 - " + STR0313, oFont01) //"Número no CRO"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2435)*nAC, aDados[nX, 18], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2750)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2850)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2760)*nAC, "19 - " + STR0018, oFont01) //"UF"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2770)*nAC, aDados[nX, 19], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2855)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 3065)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2865)*nAC, "20 - " + STR0024, oFont01) //"Código CBO S"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2875)*nAC, aDados[nX, 20], oFont04)

			aBoxCab := {630, 710, 655, 690} // {nBoxIni, nBoxFim, nSaylbl, nSayTxt}
			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0010)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 0426)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0020)*nAC, "21 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0030)*nAC, aDados[nX, 21], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0431)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2410)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0441)*nAC, "22 - "+STR0224, oFont01) //"Nome do Contratado Executante"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0451)*nAC, SubStr(aDados[nX, 22], 1, 65), oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2415)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2745)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2425)*nAC, "23 - "+STR0313, oFont01) //"Número no CRO"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2435)*nAC, aDados[nX, 23], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2750)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2850)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2760)*nAC, "24 - "+STR0018, oFont01) //"UF"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2770)*nAC, aDados[nX, 24], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2855)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 3065)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2865)*nAC, "25 - "+STR0014, oFont01) //"Código CNES"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2875)*nAC, aDados[nX, 25], oFont04)

			aBoxCab := {720, 800, 745, 780} // {nBoxIni, nBoxFim, nSaylbl, nSayTxt}
			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 0010)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2410)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 0020)*nAC, "26 - "+STR0021, oFont01) //"Nome do Profissional Executante"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 0030)*nAC, aDados[nX, 26], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2415)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2745)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2425)*nAC, "27 - "+STR0313, oFont01) //"Número no CRO"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2435)*nAC, aDados[nX, 27], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2750)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 2850)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2760)*nAC, "28 - "+STR0018, oFont01) //"UF"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2770)*nAC, aDados[nX, 28], oFont04)

			oPrint:Box((nLinIni + aBoxCab[1])*nAL, (nColIni + 2855)*nAC, (nLinIni + aBoxCab[2])*nAL, (nColIni + 3065)*nAC)
			oPrint:Say((nLinIni + aBoxCab[3])*nAL, (nColIni + 2865)*nAC, "29 - "+STR0024, oFont01) //"Código CBO S"
			oPrint:Say((nLinIni + aBoxCab[4])*nAL, (nColIni + 2875)*nAC, aDados[nX, 29], oFont04)

			nLinIni += 110
			oPrint:Say((nLinIni + 0730)*nAL, (nColIni + 0010)*nAC, STR0314, oFontSt) //"Procedimentos Executados"
			oPrint:Box((nLinIni + 0740)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1580)*nAL, (nColIni + nColMax - 15)*nAC)
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 0020)*nAC, "30 - " + STR0074, oFont01) //"Tabela"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 0130)*nAC, "31 - " + STR0075, oFont01) //"Código do Procedimento"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 0422)*nAC, "32 - " + STR0076, oFont01) //"Descrição"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 1680 + nColA4)*nAC, "33 - " + STR0315, oFont01) //"Dente/Região"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 1830 + nColA4)*nAC, "34 - " + STR0316, oFont01) //"Face"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2020 + nColA4)*nAC, "35 - " + STR0317, oFont01) //"Qtd"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2130 + nColA4)*nAC, "36 - " + STR0318, oFont01,,,,1) //"Quantidade US"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2350 + nColA4)*nAC, "37 - " + STR0319, oFont01) //"Valor"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2590 + nColA4)*nAC, "38 - " + STR0320, oFont01) //"Franquia/Co-participação R$"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2880 + nColA4)*nAC, "39 - " + STR0355, oFont01,,,,1)  //"Aut"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 3025 + nColA4)*nAC, "40 - " + STR0424, oFont01,,,,1) //"Cód. Negativa"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 3175 + nColA4)*nAC, "41 - " + STR0264, oFont01,,,,1) //"Data Realização"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 3330 + nColA4)*nAC, "42 - " + STR0321, oFont01,,,,1) //"Assinatura"

			nOldLinIni := nLinIni

			If nVolta == 1
			  nP := 1
			Endif
			
			For nI := nP To nT
				
				If nI > Len(aDados[nX, 30])
					Exit
				Endif
				
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nI)) + " - ", oFont01)

				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0060)*nAC, aDados[nX, 30, nI], oFont04)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0130)*nAC, aDados[nX, 31, nI], oFont04)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0422)*nAC, aDados[nX, 32, nI], oFont04)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 1680 + nColA4)*nAC, aDados[nX, 33, nI], oFont04)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 1830 + nColA4)*nAC, aDados[nX, 34, nI], oFont04)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2010 + nColA4)*nAC, IIF(Empty(aDados[nX, 35, nI]), "", Transform(aDados[nX, 35, nI], "@E 9999.99")), oFont04,,,,1)

				If GetNewPar("MV_PLSMUS","2") == "2"
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2120 + nColA4)*nAC, IIf(Empty(aDados[nX, 36, nI]), "", ""), oFont04,,,,1)
				Else
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2120 + nColA4)*nAC, IIf(Empty(aDados[nX, 36, nI]), "", Transform(aDados[nX, 36, nI], "@E 99,999,999.99")), oFont04,,,,1)//dennis
				Endif
				
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2350 + nColA4)*nAC, IIf(Empty(aDados[nX, 37, nI]), "", Transform(aDados[nX, 37, nI], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2590 + nColA4)*nAC, IIf(Empty(aDados[nX, 38, nI]), "", Transform(aDados[nX, 38, nI], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2880 + nColA4)*nAC, aDados[nX, 39, nI], oFont04)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 3025 + nColA4)*nAC, aDados[nX, 40, nI], oFont04)
			   	If cImpDatRea == "S"
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 3175 + nColA4)*nAC, IIf(Empty(aDados[nX, 41, nI]), "", DtoC(aDados[nX, 41, nI])), oFont04)
			   	Else
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 3175 + nColA4)*nAC, IIf(Empty(aDados[nX, 41, nI]), "", ""                       ), oFont04)
			   	EndIf
			   	oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 3330 + nColA4)*nAC, aDados[nX, 42, nI], oFont04)

				nLinIni += 40
			Next nI
			
			if nT < Len(aDados[nX, 30]).or. lImpnovo
				nP := nI
				lImpnovo := .T.
			Endif

		 	nLinIni := nOldLinIni - 30

			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1719)*nAL, (nColIni + 0450)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 0020)*nAC, "43 - "+STR0322, oFont01) //"Data Previsão Término do Tratamento"
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 43]), oFont04)
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 0455)*nAC, (nLinIni + 1719)*nAL, (nColIni + 1710)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 0465)*nAC, "44 - "+STR0323, oFont01) //"Tipo de Atendimento"
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 0465)*nAC, (nLinIni + 1700)*nAL, (nColIni + 0465)*nAC)
			oPrint:Line((nLinIni+ 1700)*nAL, (nColIni + 0465)*nAC, (nLinIni + 1700)*nAL, (nColIni + 0500)*nAC)
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 0500)*nAC, (nLinIni + 1700)*nAL, (nColIni + 0500)*nAC)
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 0477)*nAC, aDados[nX, 44], oFont04)
			oPrint:Say((nLinIni + 1685)*nAL, (nColIni + 0520)*nAC, "1 - "+STR0324+"     "+"2 - "+STR0325+"     "+"3 - "+STR0326+"     "+"4 - "+STR0327, oFont01) //"Tratamento Odontológico"###"Exame Radiológico"###"Ortodontia"###"Urgência/Emergência "
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 1715)*nAC, (nLinIni + 1719)*nAL, (nColIni + 2010)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 1725)*nAC, "45 - "+STR0328, oFont01) //"Tipo de Faturamento"
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 1725)*nAC, (nLinIni + 1700)*nAL, (nColIni + 1725)*nAC)
			oPrint:Line((nLinIni+ 1700)*nAL, (nColIni + 1725)*nAC, (nLinIni + 1700)*nAL, (nColIni + 1760)*nAC)
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 1760)*nAC, (nLinIni + 1700)*nAL, (nColIni + 1760)*nAC)
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 1737)*nAC, aDados[nX, 45], oFont04)
			oPrint:Say((nLinIni + 1685)*nAL, (nColIni + 1780)*nAC, "1 - "+STR0212+"     "+"2 - "+STR0329, oFont01) //"Total"###"Parcial "
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 2015)*nAC, (nLinIni + 1719)*nAL, (nColIni + 2415)*nAC)
			
			If GetNewPar("MV_PLSMUS","2") == "2"
				oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 2025)*nAC, "46 - "+STR0330, oFont01) //"Total Quantidade US"
				oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 2205)*nAC, "", oFont04,,,,1)
			Else
				oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 2025)*nAC, "46 - "+STR0330, oFont01) 
				oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 2205)*nAC, Transform(aDados[nX, 46], "@E 999,999,999.99"), oFont04,,,,1)
			EndIf
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 2420)*nAC, (nLinIni + 1719)*nAL, (nColIni + 2720)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 2430)*nAC, "47 - "+STR0331, oFont01) //"Valor Total R$"
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 2510)*nAC, Transform(aDados[nX, 47], "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 2725)*nAC, (nLinIni + 1719)*nAL, (nColIni + 3165)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 2735)*nAC, "48 - "+STR0332, oFont01) //"Total Franquia / Co-Participação R$"
			oPrint:Say((nLinIni + 1685)*nAL, (nColIni + 2935)*nAC, Transform(aDados[nX, 48], "@E 999,999,999.99"), oFont04,,,,1)

		 	nLinIni+=05
		 	cMsg := STR0453//"Declaro, que após ter sido devidamente esclarecido sobre os propósitos, riscos, custos e alternativas de tratamento, conforme acima apresentados, aceito e autorizo a execução do tratamento, comprometendo-me a cumprir as orientações do profissional assistente" 
		 	oPrint:Say((nLinIni + 1735)*nAL, (nColIni + 0010)*nAC, cMsg, oFont04)

		 	cMsg := STR0454//"e arcar com os custos previstos em contrato. Declaro, ainda, que o(s) procedimento(s) descrito(s) acima, e por mim assinado(s), foi/foram realizado(s) com meu consentimento e de forma satisfatória. Autorizo a Operadora a pagar em meu nome e por minha conta, " 
		 	oPrint:Say((nLinIni + 1770)*nAL, (nColIni + 0010)*nAC, cMsg, oFont04)

		 	cMsg := STR0455//"ao profissional contratado que assina esse documento, os valores referentes ao tratamento realizado, "
		 	oPrint:Say((nLinIni + 1800)*nAL, (nColIni + 0010)*nAC, cMsg, oFont04)

		   	nLinIni += 50
		   	oPrint:Box((nLinIni + 1755)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1895)*nAL, (nColIni + nColMax - 15)*nAC)
			oPrint:Say((nLinIni + 1865)*nAC, (nColIni + 0020)*nAC, "49 - "+STR0056, oFont01) //"Observação/Justificativa"

			nLin := 1825

			For nI := 1 To MlCount(aDados[nX, 49], 220)
				cObs := MemoLine(aDados[nX, 49], 220, nI)
				oPrint:Say((nLinIni + nLin)*nAL, (nColIni + 0020)*nAC, cObs, oFont04)
				nLin += 35
			Next nI

			nLinIni+=65

			oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1935)*nAL, (nColIni + 0825)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 0025)*nAC, "50 - "+STR0425, oFont01) //"Data, local e Assinatura do Cirurgião Dentista Solicitante"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 0035)*nAC, DtoC(aDados[nX, 50]), oFont04)

		 	oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 0830)*nAC, (nLinIni + 1935)*nAL, (nColIni + 1600)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 0845)*nAC, "51 - "+STR0426, oFont01) //"Assinatura do Cirurgião Dentista"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 0855)*nAC, (aDados[nX, 51]), oFont04)

			oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 1605)*nAC, (nLinIni + 1935)*nAL, (nColIni + 2375)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 1620)*nAC, "52 - "+STR0427, oFont01) //"Data Assinatura do Associado / Responsável"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 1630)*nAC, DtoC(aDados[nX, 52]), oFont04)

			oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 2380)*nAC, (nLinIni + 1935)*nAL, (nColIni + 3165)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 2385)*nAC, "53 - "+STR0428, oFont01) //"Assinatura do Associado / Responsável"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 2395)*nAC, aDados[nX, 53], oFont04)

			nLinIni+=10
			oPrint:Box((nLinIni + 1940)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2035)*nAL, (nColIni + 0825)*nAC)
			oPrint:Say((nLinIni + 1965)*nAL, (nColIni + 0025)*nAC, "54 - "+STR0429, oFont01) //"Data, local e Assinatura do Cirurgião Dentista Solicitante"
			oPrint:Say((nLinIni + 2005)*nAL, (nColIni + 0035)*nAC, DtoC(aDados[nX, 54]), oFont04)

		 	oPrint:Box((nLinIni + 1940)*nAL, (nColIni + 0830)*nAC, (nLinIni + 2035)*nAL, (nColIni + 1600)*nAC)
			oPrint:Say((nLinIni + 1965)*nAL, (nColIni + 0845)*nAC, "55 - "+STR0450, oFont01) //"Data, Local e Assinatura do Cirurgião Dentista"
			oPrint:Say((nLinIni + 2005)*nAL, (nColIni + 0855)*nAC, (aDados[nX, 55]), oFont04)

			if !lTiss4Rel
				oPrint:Box((nLinIni + 1940)*nAL, (nColIni + 1605)*nAC, (nLinIni + 2035)*nAL, (nColIni + 2375)*nAC)
				oPrint:Say((nLinIni + 1965)*nAL, (nColIni + 1620)*nAC, "56 - "+STR0451, oFont01) //"Data, Local e Assinatura do Associado / Responsável"
				oPrint:Say((nLinIni + 2005)*nAL, (nColIni + 1630)*nAC, DtoC(aDados[nX, 56]), oFont04)
			endif
			oPrint:EndPage()	// Finaliza a pagina
		Next nX
	Enddo

If lGerTXT .And. !lWeb
	//Imprime Relatorio
	oPrint:Print()
Else
	//Visualiza impressao grafica antes de imprimir
	oPrint:Print()
EndIf

Return(cFileName)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSA  ³ Autor ³ Luciano Aparecido     ³ Data ³ 12.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Odontológica - Solicitação)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISSA(aDados, nLayout, cLogoGH, lAuto) //Guia Odontológica - Solicitação

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local nLinA4    :=  0
	Local cFileLogo
	Local lPrinter
  	Local nLin
	Local nX , nI
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local nCol  	:=	0
	Local nColf 	:=	0
	Local aNum1,aNum2,aNum3,aNum4 :={}

	Default nLayout := 2
	Default cLogoGH := ''
	Default lAuto   := .F.
	Default aDados  := { { ;
						"123456",;
						"12345678901234567892",;
						"12345678901234567892",;
						"12345678901234567892",;
						Replicate("M",40),;
						Replicate("M",40),;
						CtoD("01/12/07"),;
						Replicate("M",70),;
						"1199999999",;
						Replicate("M",40),;
						"14.141.114/00001-35",;
						Replicate("M",70),;
						"123456789012345",;
						"SP",;
						"1234567",;
						Replicate("M",70),;
						"123456789012345",;
						"SP",;
						"00199",;
						"1",;
						"0",;
						Replicate("M", 240),;
					 	CtoD("30/12/07"),;
					 	Replicate("M",30),;
						CtoD("30/12/07"),;
						Replicate("M",30),;
						CtoD("30/12/07"),;
						Replicate("M",30)} }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2335
		nColMax	:=	3350 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	If lAuto
		cPathSrvJ := GETMV("MV_RELT")

		oPrint  := FWMSPrinter():New ( "pdfauto"+lower(CriaTrab(NIL,.F.))+".pdf",,.F., cPathSrvJ,.T.,nil,@oPrint,nil,nil,.F.,.F.)
		oPrint:lServer := .T.
		oPrint:cPathPDF := cPathSrvJ
	else
		oPrint	:= TMSPrinter():New(STR0338) //"GUIA ODONTOLÓGICA - SOLICITAÇÃO"
	endIf

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()

	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf ! lPrinter
		oPrint:Setup()
	EndIf


	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		nLinIni := 080
		nColIni := 080
		nColA4  := 000
		nLinA4  := 000

		oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
		  	nColA4    := -0335
		  	nLinA4    := -0025
		Elseif nLayout == 3// Carta
			nColA4    := -0530
		Endif

		oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIF(nLayout ==2 .Or. nLayout ==3,nColA4+260,0),STR0391, oFont02n,,,, 2)  //"GUIA TRATAMENTO ODONTOLÓGICO - SITUAÇÃO INICIAL"
		oPrint:Say(nLinIni + 0090, nColIni + 3000 + nColA4, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say(nLinIni + 0070, nColIni + 3096 + nColA4, aDados[nX, 02], oFont03n)

		nLinIni+= 300
		oPrint:Box(nLinIni + 0175 + nLinA4, nColIni + 0010, nLinIni + 0269 + nLinA4, nColIni + 0315)
		oPrint:Say(nLinIni + 0180 + nLinA4, nColIni + 0020, "1 - " + STR0003, oFont01) //"Registro ANS"
		oPrint:Say(nLinIni + 0210 + nLinA4, nColIni + 0030, aDados[nX, 01], oFont04)
		oPrint:Box(nLinIni + 0175 + nLinA4, nColIni + 0320, nLinIni + 0269 + nLinA4, nColIni + 0625)
		oPrint:Say(nLinIni + 0180 + nLinA4, nColIni + 0330, "3 - " + STR0308, oFont01) //"Número da guia principal"
		oPrint:Say(nLinIni + 0210 + nLinA4, nColIni + 0340, aDados[nX, 03], oFont04)

		nLinIni += 50
		oPrint:Say(nLinIni + 0274 + nLinA4, nColIni + 0010, STR0005, oFont01) //"Dados do Beneficiário"
		oPrint:Box(nLinIni + 0304 + nLinA4, nColIni + 0010, nLinIni + 0398 + nLinA4, nColIni + 0415)
		oPrint:Say(nLinIni + 0309 + nLinA4, nColIni + 0020, "4 - "+STR0006, oFont01) //"Número da Carteira"
		oPrint:Say(nLinIni + 0339 + nLinA4, nColIni + 0030, aDados[nX, 04], oFont04)
		oPrint:Box(nLinIni + 0304 + nLinA4, nColIni + 0420, nLinIni + 0398 + nLinA4, nColIni + 1590 + IIF(nLayout ==3,nColA4/2,0))
		oPrint:Say(nLinIni + 0309 + nLinA4, nColIni + 0430, "5 - "+STR0007, oFont01) //"Plano"
		oPrint:Say(nLinIni + 0339 + nLinA4, nColIni + 0440, aDados[nX, 05], oFont04)
		oPrint:Box(nLinIni + 0304 + nLinA4, nColIni + 1595 + IIF(nLayout ==3,nColA4/2,0), nLinIni + 0398 + nLinA4, nColIni + 2765 + nColA4/2 + IIF(nLayout ==3,nColA4/2,0))
		oPrint:Say(nLinIni + 0309 + nLinA4, nColIni + 1605 + IIF(nLayout ==3,nColA4/2,0), "6 - "+STR0309, oFont01) //"Empresa"
		oPrint:Say(nLinIni + 0339 + nLinA4, nColIni + 1615 + IIF(nLayout ==3,nColA4/2,0), aDados[nX, 06], oFont04)
		oPrint:Box(nLinIni + 0304 + nLinA4, nColIni + 2770 + nColA4/2 + IIF(nLayout ==3,nColA4/2,0), nLinIni + 0398 + nLinA4, nColIni + 3075 + nColA4/2 + IIF(nLayout ==3,nColA4/2,0))
		oPrint:Say(nLinIni + 0309 + nLinA4, nColIni + 2780 + nColA4/2 + IIF(nLayout ==3,nColA4/2,0), "7 - "+STR0310, oFont01) //"Data Validade da Carteira"
		oPrint:Say(nLinIni + 0339 + nLinA4, nColIni + 2790 + nColA4/2 + IIF(nLayout ==3,nColA4/2,0), DtoC(aDados[nX, 07]), oFont04)

		oPrint:Box(nLinIni + 0403 + nLinA4, nColIni + 0010, nLinIni + 0497 + nLinA4, nColIni + 1990 + nColA4)
		oPrint:Say(nLinIni + 0407 + nLinA4, nColIni + 0020, "8 - "+STR0009, oFont01) //"Nome"
		oPrint:Say(nLinIni + 0437 + nLinA4, nColIni + 0030, aDados[nX, 08], oFont04)
		oPrint:Box(nLinIni + 0403 + nLinA4, nColIni + 1995 + nColA4, nLinIni + 0497 + nLinA4, nColIni + 2325 + nColA4)
		oPrint:Say(nLinIni + 0407 + nLinA4, nColIni + 2005 + nColA4, "9 - "+STR0311, oFont01) //"Telefone"
		oPrint:Say(nLinIni + 0437 + nLinA4, nColIni + 2015 + nColA4, aDados[nX, 09], oFont04)
		oPrint:Box(nLinIni + 0403 + nLinA4, nColIni + 2330 + nColA4, nLinIni + 0497 + nLinA4, nColIni + 3500 + nColA4)
		oPrint:Say(nLinIni + 0407 + nLinA4, nColIni + 2340 + nColA4, "10 - "+STR0312, oFont01) //"Nome do Titular do Plano"
		oPrint:Say(nLinIni + 0437 + nLinA4, nColIni + 2350 + nColA4, aDados[nX, 10], oFont04)

		nLinIni += 50
		oPrint:Say(nLinIni + 0502 + nLinA4, nColIni + 0010, STR0390, oFont01) //"Dados do contatado"
		oPrint:Box(nLinIni + 0532 + nLinA4, nColIni + 0010, nLinIni + 0626 + nLinA4, nColIni + 0426)
		oPrint:Say(nLinIni + 0537 + nLinA4, nColIni + 0020, "11 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say(nLinIni + 0567 + nLinA4, nColIni + 0030, aDados[nX, 11], oFont04)
		oPrint:Box(nLinIni + 0532 + nLinA4, nColIni + 0431, nLinIni + 0626 + nLinA4, nColIni + 2410)
		oPrint:Say(nLinIni + 0537 + nLinA4, nColIni + 0441, "12 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say(nLinIni + 0567 + nLinA4, nColIni + 0451, SubStr(aDados[nX, 12], 1, 65), oFont04)
		oPrint:Box(nLinIni + 0532 + nLinA4, nColIni + 2415, nLinIni + 0626 + nLinA4, nColIni + 2745)
		oPrint:Say(nLinIni + 0537 + nLinA4, nColIni + 2425, "13 - "+STR0313, oFont01) //"Número no CRO"
		oPrint:Say(nLinIni + 0567 + nLinA4, nColIni + 2435, aDados[nX, 13], oFont04)
		oPrint:Box(nLinIni + 0532 + nLinA4, nColIni + 2750, nLinIni + 0626 + nLinA4, nColIni + 2850)
		oPrint:Say(nLinIni + 0537 + nLinA4, nColIni + 2760, "14 - "+STR0018, oFont01) //"UF"
		oPrint:Say(nLinIni + 0567 + nLinA4, nColIni + 2770, aDados[nX, 14], oFont04)
		oPrint:Box(nLinIni + 0532 + nLinA4, nColIni + 2855, nLinIni + 0626 + nLinA4, nColIni + 3065)
		oPrint:Say(nLinIni + 0537 + nLinA4, nColIni + 2865, "15 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say(nLinIni + 0567 + nLinA4, nColIni + 2875, aDados[nX, 15], oFont04)

		oPrint:Box(nLinIni + 0631 + nLinA4, nColIni + 0010, nLinIni + 0725 + nLinA4, nColIni + 1990)
		oPrint:Say(nLinIni + 0636 + nLinA4, nColIni + 0020, "16 - "+STR0207, oFont01) //"Nome do profissional"
		oPrint:Say(nLinIni + 0666 + nLinA4, nColIni + 0030, aDados[nX, 16], oFont04)
		oPrint:Box(nLinIni + 0631 + nLinA4, nColIni + 1995, nLinIni + 0725 + nLinA4, nColIni + 2310)
		oPrint:Say(nLinIni + 0636 + nLinA4, nColIni + 2005, "17 - "+STR0313, oFont01) //"Número no CRO"
		oPrint:Say(nLinIni + 0666 + nLinA4, nColIni + 2015, aDados[nX, 17], oFont04)
		oPrint:Box(nLinIni + 0631 + nLinA4, nColIni + 2315, nLinIni + 0725 + nLinA4, nColIni + 2425)
		oPrint:Say(nLinIni + 0636 + nLinA4, nColIni + 2325, "18 - "+STR0018, oFont01) //"UF"
		oPrint:Say(nLinIni + 0666 + nLinA4, nColIni + 2335, aDados[nX, 18], oFont04)
		oPrint:Box(nLinIni + 0631 + nLinA4, nColIni + 2430, nLinIni + 0725 + nLinA4, nColIni + 2645)
		oPrint:Say(nLinIni + 0636 + nLinA4, nColIni + 2440, "19 - "+STR0024, oFont01) //"Código CBO S"
		oPrint:Say(nLinIni + 0666 + nLinA4, nColIni + 2450, aDados[nX, 19], oFont04)

		nLinIni += 50
		oPrint:Say(nLinIni + 0731 + nLinA4, nColIni + 0010, STR0340, oFont01) //"Situação Inicial"
		oPrint:Box(nLinIni + 0761 + nLinA4, nColIni + 0010, nLinIni + 0819 + nLinA4, nColIni + 0295)
		oPrint:Say(nLinIni + 0771 + nLinA4, nColIni + 0020, STR0340, oFont04) //"Situação Inicial"
		oPrint:Box(nLinIni + 0819 + nLinA4, nColIni + 0010, nLinIni + 0877 + nLinA4, nColIni + 0295)
		oPrint:Say(nLinIni + 0829 + nLinA4, nColIni + 0020, STR0341, oFont04) //"Permanentes"
		oPrint:Box(nLinIni + 0877 + nLinA4, nColIni + 0010, nLinIni + 0935 + nLinA4, nColIni + 0295)
		oPrint:Say(nLinIni + 0887 + nLinA4, nColIni + 0020, STR0342, oFont04) //"Decíduos"
		oPrint:Box(nLinIni + 0935 + nLinA4, nColIni + 0010, nLinIni + 0993 + nLinA4, nColIni + 0295)
		oPrint:Say(nLinIni + 0945 + nLinA4, nColIni + 0020, STR0342, oFont04) //"Decíduos"
		oPrint:Box(nLinIni + 0993 + nLinA4, nColIni + 0010, nLinIni + 1051 + nLinA4, nColIni + 0295)
		oPrint:Say(nLinIni + 1003 + nLinA4, nColIni + 0020, STR0341, oFont04) //"Permanentes"
		oPrint:Box(nLinIni + 1051 + nLinA4, nColIni + 0010, nLinIni + 1109 + nLinA4, nColIni + 0295)
		oPrint:Say(nLinIni + 1061 + nLinA4, nColIni + 0020, STR0340, oFont04) //"Situação Inicial"

		nCol	:=0300
		nColf	:=0400

		For nI:=1 to 16
			oPrint:Box(nLinIni + 0761 + nLinA4, nColIni + nCol , nLinIni + 0819 + nLinA4, nColIni + 	nColf)
			oPrint:Box(nLinIni + 0819 + nLinA4, nColIni + nCol , nLinIni + 0877 + nLinA4, nColIni + 	nColf)
			oPrint:Box(nLinIni + 0877 + nLinA4, nColIni + nCol , nLinIni + 0935 + nLinA4, nColIni + 	nColf)
			oPrint:Box(nLinIni + 0935 + nLinA4, nColIni + nCol , nLinIni + 0993 + nLinA4, nColIni + 	nColf)
			oPrint:Box(nLinIni + 0993 + nLinA4, nColIni + nCol , nLinIni + 1051 + nLinA4, nColIni + 	nColf)
			oPrint:Box(nLinIni + 1051 + nLinA4, nColIni + nCol , nLinIni + 1109 + nLinA4, nColIni + 	nColf)
		    nCol  +=0100
		    nColf +=0100
		Next nI

		aNum1:={"18","17","16","15","14","13","12","11","21","22","23","24","25","26","27","28"}
		nCol	:=0325
		For nI:=1 to Len(aNum1)
		oPrint:Say(nLinIni + 0829 + nLinA4, nColIni + nCol, aNum1[nI], oFont04)
		 nCol  +=0100
		Next nI

		nCol    :=630
		aNum2:={"55","54","53","52","51","61","62","63","64","65"}
		For nI:=1 to Len(aNum2)
		oPrint:Say(nLinIni + 0887 + nLinA4, nColIni + nCol, aNum2[nI], oFont04)
		 nCol  +=0100
		Next nI

		nCol    :=630
		aNum3:={"85","84","83","82","81","71","72","73","74","75"}
		For nI:=1 to Len(aNum3)
		oPrint:Say(nLinIni + 0945 + nLinA4, nColIni + nCol, aNum3[nI], oFont04)
		 nCol  +=0100
		Next nI

		aNum4:={"48","47","46","45","44","43","42","41","31","32","33","34","35","36","37","38"}
		nCol	:=0325
		For nI:=1 to Len(aNum4)
		oPrint:Say(nLinIni + 1003 + nLinA4, nColIni + nCol, aNum4[nI], oFont04)
		 nCol  +=0100
		Next nI

		oPrint:Box(nLinIni + 0761 + nLinA4, nColIni + 1905, nLinIni + 0850 + nLinA4, nColIni + 2330)
		oPrint:Say(nLinIni + 0766 + nLinA4, nColIni + 1910, "20 - "+STR0343, oFont01) //"Sinais Clínicos de doença periodontal ?"

		oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 1920, nLinIni + 0840 + nLinA4, nColIni + 1920)
		oPrint:Line(nLinIni + 0840 + nLinA4, nColIni + 1920, nLinIni + 0840 + nLinA4, nColIni + 1955)
		oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 1955, nLinIni + 0840 + nLinA4, nColIni + 1955)
		oPrint:Say(nLinIni + 0805 + nLinA4, nColIni + 1970, STR0344, oFont04)  //"Sim"
		oPrint:Say(nLinIni + 0800 + nLinA4, nColIni + 1930, IIf(((aDados[nX, 20]) =="1"),"X",""), oFont04)

	   	oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 2050, nLinIni + 0840 + nLinA4, nColIni + 2050)
		oPrint:Line(nLinIni + 0840 + nLinA4, nColIni + 2050, nLinIni + 0840 + nLinA4, nColIni + 2085)
		oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 2085, nLinIni + 0840 + nLinA4, nColIni + 2085)
		oPrint:Say(nLinIni + 0805 + nLinA4, nColIni + 2100, STR0345, oFont04) //"Não"
		oPrint:Say(nLinIni + 0800 + nLinA4, nColIni + 2060, IIf (((aDados[nX, 20]) =="0"),"X",""), oFont04)

		oPrint:Box(nLinIni + 0761 + nLinA4, nColIni + 2335, nLinIni + 0850 + nLinA4, nColIni + 2690)
		oPrint:Say(nLinIni + 0766 + nLinA4, nColIni + 2345, "21 - "+STR0346, oFont01) //"Alteração dos Tecidos Moles ?"

		oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 2355, nLinIni + 0840 + nLinA4, nColIni + 2355)
		oPrint:Line(nLinIni + 0840 + nLinA4, nColIni + 2355, nLinIni + 0840 + nLinA4, nColIni + 2395)
		oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 2395, nLinIni + 0840 + nLinA4, nColIni + 2395)
		oPrint:Say(nLinIni + 0805 + nLinA4, nColIni + 2410, STR0344, oFont04)  //"Sim"
		oPrint:Say(nLinIni + 0800 + nLinA4, nColIni + 2365, IIf(((aDados[nX, 21]) =="1"),"X",""), oFont04)

		oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 2490, nLinIni + 0840 + nLinA4, nColIni + 2490)
		oPrint:Line(nLinIni + 0840 + nLinA4, nColIni + 2490, nLinIni + 0840 + nLinA4, nColIni + 2525)
		oPrint:Line(nLinIni + 0800 + nLinA4, nColIni + 2525, nLinIni + 0840 + nLinA4, nColIni + 2525)
		oPrint:Say(nLinIni + 0805 + nLinA4, nColIni + 2540, STR0345, oFont04) //"Não"
		oPrint:Say(nLinIni + 0800 + nLinA4, nColIni + 2500, IIf (((aDados[nX, 21]) =="0"),"X",""), oFont04)

		oPrint:Say(nLinIni + 0860 + nLinA4, nColIni + 1905, STR0347, oFont01)	 //"LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL"
		oPrint:Box(nLinIni + 0890 + nLinA4, nColIni + 1905, nLinIni + 1109 + nLinA4, nColIni + 2150)
		oPrint:Say(nLinIni + 0900 + nLinA4, nColIni + 1920, STR0340, oFont01) //"SITUAÇÃO INICIAL"
		oPrint:Say(nLinIni + 0935 + nLinA4, nColIni + 1920, STR0348, oFont01) //"A - Ausente"
		oPrint:Say(nLinIni + 0970 + nLinA4, nColIni + 1920, STR0349, oFont01) //"E - Extração Indicada"
		oPrint:Say(nLinIni + 1005 + nLinA4, nColIni + 1920, STR0350, oFont01) //"H - Hígido"
		oPrint:Say(nLinIni + 1040 + nLinA4, nColIni + 1920, STR0351, oFont01) //"C - Cariado"
		oPrint:Say(nLinIni + 1075 + nLinA4, nColIni + 1920, STR0352, oFont01) //"R - Restaurado"


		oPrint:Box(nLinIni + 1160 + nLinA4, nColIni + 0010, nLinIni + 1400 + nLinA4, nColIni + 3500 + nColA4)
		oPrint:Say(nLinIni + 1165 + nLinA4, nColIni + 0020, "22 - "+STR0056, oFont01) //"Observação"

		nLin := 1940

		For nI := 1 To MlCount(aDados[nX, 22], 130)
			cObs := MemoLine(aDados[nX, 22], 130, nI)
			oPrint:Say(nLinIni + nLin + nLinA4, nColIni + 0030, cObs, oFont04)
			nLin += 35
		Next nI



		oPrint:Box(nLinIni + 1450 + nLinA4, nColIni + 0010, nLinIni + 1600 + nLinA4, nColIni + 0850)
		oPrint:Say(nLinIni + 1455 + nLinA4, nColIni + 0020, "23 - "+STR0335, oFont01) //"Data, Local e Assinatura do Cirurgião Dentista"
		oPrint:Say(nLinIni + 1485 + nLinA4, nColIni + 0030, DtoC(aDados[nX, 23]), oFont04)
		oPrint:Say(nLinIni + 1485 + nLinA4, nColIni + 0180, (aDados[nX, 24]), oFont04)
		oPrint:Box(nLinIni + 1450 + nLinA4, nColIni + 0855, nLinIni + 1600 + nLinA4, nColIni + 1695)
		oPrint:Say(nLinIni + 1455 + nLinA4, nColIni + 0865, "24 - "+STR0336, oFont01) //"Data, Local e Assinatura do Associado / Responsável"
		oPrint:Say(nLinIni + 1485 + nLinA4, nColIni + 0875, DtoC(aDados[nX, 25]), oFont04)
		oPrint:Say(nLinIni + 1485 + nLinA4, nColIni + 1025, (aDados[nX, 26]), oFont04)
		oPrint:Box(nLinIni + 1450 + nLinA4, nColIni + 1700, nLinIni + 1600 + nLinA4, nColIni + 2540)
		oPrint:Say(nLinIni + 1455 + nLinA4, nColIni + 1710, "25 - "+STR0337, oFont01) //"Data, Local e Carimbo da Empresa"
		oPrint:Say(nLinIni + 1485 + nLinA4, nColIni + 1720, DtoC(aDados[nX, 27]), oFont04)
		oPrint:Say(nLinIni + 1485 + nLinA4, nColIni + 1870, (aDados[nX, 28]), oFont04)

		oPrint:EndPage()	// Finaliza a pagina

	Next nX
	
	oPrint:Print()	// Visualiza impressao grafica antes de imprimir

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSB  ³ Autor ³ Luciano Aparecido     ³ Data ³ 13.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Odontológica - Pagamento )   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISSB(aDados, nLayout, cLogoGH, lAuto) //Guia Odontológica - Pagamento

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nOldCol	:=	0
	Local nOldLin	:=	0
	Local nColA4    := 	0
	Local nLinFin	:=	0
    Local nTotVlrT  := 0
	Local cFileLogo
	Local lPrinter
	Local nI, nJ
	Local nX, nX1, nX2, nX3, nX4
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local nProcGer,nProcLot,nProcGui
	Local nLibGer,nLiblot,nLibGui
	Local nGloGer,nGlolot,nGloGui
    Local lBox
	Local cFileName := ""

    Default nLayout := 2
    Default cLogoGH := ''
	Default lAuto   := .F.
	Default	aDados  := { {;
						"123456",;
						{"12345678901234567892"},;
						{Replicate("M",70)},;
						{"14.141.114/00001-35"},;
						{{CtoD("05/03/07"),CtoD("05/03/07")}},;
						{"14.141.114/00001-35"},;
						{Replicate("M",70)},;
						{"14.141.114/00001-35"},;
						{{"123456789012"}},;
						{{{"12345678901234567890"}}},;
						{{{Replicate("M",70)}}},;
						{{{"123456789012"}}},;
						{{{{"AA","BB","CC","DD","EE","FF","GG","HH","II","JJ","KK","LL","MM","NN","OO"}}}},;
					    {{{{"1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890"}}}},;
						{{{{Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),;
							Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70)}}}},;
						{{{{"12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345"}}}},;
						{{{{"ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD"}}}},;
						{{{{CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07")}}}},;
						{{{{10,20,30,40,50,60,70,80,90,15,25,35,45,55,65}}}},;
						{{{{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99}}}},;
						{{{{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99}}}},;
						{{{{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99}}}},;
						{{{{"1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234"}}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
						{{{999999.99}}},;
				     	{{{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
						  { Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
						  { Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 } }},;
						{{{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
						  { Replicate("M", 40), 999999999.99 } }},;
						{{{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
						  { Replicate("M", 40), 999999999.99 } }},;
						{CtoD("30/12/07")},;
					 	{999999.99},;
						{999999.99},;
						{999999.99},;
						{{999999.99}},;
						{{999999.99}}  }}

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2375
		nColMax	:=	3370 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	If lAuto	
		cPathSrvJ := GETMV("MV_RELT")
		cFileName := "pdfauto"+lower(CriaTrab(NIL,.F.))+".pdf"
		oPrint    := FWMSPrinter():New ( cFileName,,.F., cPathSrvJ,.T.,nil,@oPrint,nil,nil,.F.,.F.)
		oPrint:lServer := .T.
		oPrint:cPathPDF := cPathSrvJ
	else
		oPrint	:= TMSPrinter():New(STR0359) //"GUIA ODONTOLÓGICA - DEMONSTRATIVO PAGAMENTO"
	endIf

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()

	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf ! lPrinter
		oPrint:Setup()
	EndIf


	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI:= 13 To 23
			If Len(aDados[nX, nI]) < 15
				For nJ := Len(aDados[nX, nI]) + 1 To 15
					If AllTrim(Str(nI)) $ "19,20,21,22"
						aAdd(aDados[nX, nI], 0)
					ElseiF AllTrim(Str(nI)) $ "18"
						aAdd(aDados[nX, nI], CToD(""))
					Else
						aAdd(aDados[nX, nI],"")
					EndIf
				Next nJ
			EndIf
		Next nI

	  For nI := 33 To 33
			If Len(aDados[nX, nI]) < 1
				aAdd(aDados[nX, nI], { "", 0 })
			EndIf
	  Next nI


  For nX1 := 1 To Len(aDados[nX, 02])

		If nX1 > 1
	 		oPrint:EndPage()
		Endif

		nLinIni  := 040
		nColIni  := 060
		nColA4   := 000

		oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)

			oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
		  	nColA4    := -0335
		Elseif nLayout == 3// Carta
			nColA4    := -0530
		Endif

		oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIF(nLayout ==2 .Or. nLayout ==3,nColA4+260,0), STR0360, oFont02n,,,, 2) //"GUIA TRATAMENTO ODONTOLÓGICO - DEMONSTRATIVO DE PAGAMENTO"
		oPrint:Say(nLinIni + 0090, nColIni + 3000 + nColA4, "2 - "+STR0002, oFont01) //"Nº"
		oPrint:Say(nLinIni + 0070, nColIni + 3096 + nColA4, aDados[nX, 02,nX1], oFont03n)

		nLinIni+= 80
		oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, nColIni + 0315)
		oPrint:Say(nLinIni + 0180, nColIni + 0020, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say(nLinIni + 0210, nColIni + 0030, aDados[nX, 01], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 0320, nLinIni + 0269, nColIni + 2355 + IIf(nLayout == 3,nColA4/2,0))
		oPrint:Say(nLinIni + 0180, nColIni + 0330, "3 - "+STR0247, oFont01) //"Nome da Operadora"
		oPrint:Say(nLinIni + 0210, nColIni + 0340, aDados[nX, 03,nX1], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 2360 + IIf(nLayout == 3,nColA4/2,0), nLinIni + 0269, nColIni + 2776 + IIf(nLayout == 3,nColA4/2,0))
		oPrint:Say(nLinIni + 0180, nColIni + 2370 + IIf(nLayout == 3,nColA4/2,0), "4 - "+STR0248, oFont01) //"CNPJ Operadora"
		oPrint:Say(nLinIni + 0210, nColIni + 2380 + IIf(nLayout == 3,nColA4/2,0), aDados[nX, 04,nX1], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 2781 + IIf(nLayout == 3,nColA4/2,0), nLinIni + 0269, nColIni + 3200 + IIf(nLayout == 3,nColA4/2,0))
		oPrint:Say(nLinIni + 0180, nColIni + 2791 + IIf(nLayout == 3,nColA4/2,0), "5 - "+STR0361, oFont01) //"Período de Processamento"
		oPrint:Say(nLinIni + 0210, nColIni + 2801 + IIf(nLayout == 3,nColA4/2,0), DToC(aDados[nX, 05,nX1,1]), oFont04)
		oPrint:Say(nLinIni + 0210, nColIni + 2950 + IIf(nLayout == 3,nColA4/2,0), STR0362, oFont04) //" à "
		oPrint:Say(nLinIni + 0210, nColIni + 3020 + IIf(nLayout == 3,nColA4/2,0), DToC(aDados[nX, 05,nX1,2]), oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0274, nColIni + 0010, STR0251, oFont01) //"Dados do Prestador"
		oPrint:Box(nLinIni + 0304, nColIni + 0010, nLinIni + 0398, nColIni + 0415)
		oPrint:Say(nLinIni + 0309, nColIni + 0020, "6 - "+STR0363, oFont01) //"Código na Operadora"
		oPrint:Say(nLinIni + 0339, nColIni + 0030, aDados[nX, 06,nX1], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 0420, nLinIni + 0398, nColIni + 2455)
		oPrint:Say(nLinIni + 0309, nColIni + 0430, "7 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say(nLinIni + 0339, nColIni + 0440, aDados[nX, 07,nX1], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 2460, nLinIni + 0398, nColIni + 2875)
		oPrint:Say(nLinIni + 0309, nColIni + 2470, "8 - "+STR0364, oFont01) //"CPF/ CNPJ Contratado"
		oPrint:Say(nLinIni + 0339, nColIni + 2480, aDados[nX, 08,nX1], oFont04)

		nProcGer := 0
		nLibGer  := 0
		nGloGer  := 0


	   For nX2 := 1 To Len(aDados[nX, 09,nX1])

	   fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20)

			nProcLot := 0
	   		nGloLot  := 0
	   		nLibLot  := 0

			oPrint:Say(nLinIni + 0403, nColIni + 0010, STR0286, oFont01) //"Dados do Pagamento"
			oPrint:Box(nLinIni + 0433, nColIni + 0010, nLinIni + 0527, nColIni + 0370)
			oPrint:Say(nLinIni + 0438, nColIni + 0020, "9 - "+STR0255, oFont01) //"Número do Lote"
			oPrint:Say(nLinIni + 0468, nColIni + 0030, aDados[nX, 09,nX1, nX2], oFont04)


		  	For nX3 := 1 To Len(aDados[nX, 12,nX1, nX2])
		  			if nX3 <> 1
		  		   		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
					Endif
					oPrint:Box(nLinIni + 0433, nColIni + 0375, nLinIni + 0527, nColIni + 0820)
					oPrint:Say(nLinIni + 0438, nColIni + 0385, "10 - "+STR0263, oFont01) //"Código do Beneficiário"
					oPrint:Say(nLinIni + 0468, nColIni + 0395, aDados[nX, 10,nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0433, nColIni + 0825, nLinIni + 0527, nColIni + 2835 + IIf(nLayout == 3,nColA4/2,0))
					oPrint:Say(nLinIni + 0438, nColIni + 0835, "11 - "+STR0262, oFont01) //"Nome do Beneficiário"
					oPrint:Say(nLinIni + 0468, nColIni + 0845, aDados[nX, 11,nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0433, nColIni + 2840 + IIf(nLayout == 3,nColA4/2,0), nLinIni + 0527, nColIni + 3200 + IIf(nLayout == 3,nColA4/2,0))
					oPrint:Say(nLinIni + 0438, nColIni + 2850 + IIf(nLayout == 3,nColA4/2,0), "12 - "+STR0365, oFont01) //"Número da Guia"
					oPrint:Say(nLinIni + 0468, nColIni + 2860 + IIf(nLayout == 3,nColA4/2,0), aDados[nX, 12 ,nX1, nX2, nX3], oFont04)
					lBox:=.F.

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)

					if (nLinIni + 600 + (Len(aDados[nX, 13,nX1, nX2, nX3]) * 45)) < nLinMax
						oPrint:Box(nLinIni + 0518, nColIni + 0010, nLinIni + 600 + (Len(aDados[nX, 13,nX1, nX2, nX3]) * 45), nColIni + 3695 + nColA4)
						Else
						oPrint:Line(nLinIni + 0518, nColIni + 0010, nLinIni + 0563, nColIni + 0010)
					 	oPrint:Line(nLinIni + 0518, nColIni + 0010, nLinIni + 0518, nColIni + 3695 + nColA4)
					 	oPrint:Line(nLinIni + 0518, nColIni + 3695 + nColA4, nLinIni + 0563, nColIni + 3695 + nColA4)
					  	lBox:=.T.
					Endif

					oPrint:Say(nLinIni + 0528, nColIni + 0020, "13 - "+STR0074, oFont01) //"Tabela"
					oPrint:Say(nLinIni + 0528, nColIni + 0155, "14 - "+STR0075, oFont01) //"Código do Procedimento"
					oPrint:Say(nLinIni + 0528, nColIni + 0430, "15 - "+STR0076, oFont01) //"Descrição"
					oPrint:Say(nLinIni + 0528, nColIni + 1950 + nColA4, "16 - "+STR0315, oFont01) //"Dente/Região"
					oPrint:Say(nLinIni + 0528, nColIni + 2150 + nColA4, "17 - "+STR0316, oFont01) //"Face"
					oPrint:Say(nLinIni + 0528, nColIni + 2510 + nColA4, "18 - "+STR0366, oFont01,,,,1) //"Data de Realização"
					oPrint:Say(nLinIni + 0528, nColIni + 2560 + nColA4, "19 - "+STR0317, oFont01) //"Qtd"
					oPrint:Say(nLinIni + 0528, nColIni + 2910 + nColA4, "20 - "+STR0367, oFont01,,,,1) //"Valor Processado(R$)"
					oPrint:Say(nLinIni + 0528, nColIni + 2950 + nColA4, "21 - "+STR0368, oFont01) //"Valor Glosa/Estorno(R$)"
					oPrint:Say(nLinIni + 0528, nColIni + 3245 + nColA4, "22 - "+STR0369, oFont01) //"Valor Liberado(R$)"
					oPrint:Say(nLinIni + 0528, nColIni + 3665 + nColA4, "23 - "+STR0370, oFont01,,,,1) //"Motivo da Glosa"

					nProcGui := 0
					nGloGui  := 0
					nLibGui  := 0

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 555)

					For nX4 := 1 To Len(aDados[nX, 13,nX1, nX2, nX3])

						if lBox
							oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0055, nColIni  + 0010)
							oPrint:Line(nLinIni + 0010, nColIni  + 3695 + nColA4, nLinIni + 0055, nColIni  + 3695 + nColA4)
						Endif

						oPrint:Say(nLinIni + 0010, nColIni + 0065, aDados[nX, 13,nX1,  nX2, nX3 , nX4], oFont04) //0573
						oPrint:Say(nLinIni + 0010, nColIni + 0170, aDados[nX, 14,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:Say(nLinIni + 0010, nColIni + 0430, aDados[nX, 15,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:Say(nLinIni + 0010, nColIni + 1990 + IIf(nLayout == 3,nColA4+20,nColA4), aDados[nX, 16,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:Say(nLinIni + 0010, nColIni + 2150 + IIf(nLayout == 3,nColA4+20,nColA4), aDados[nX, 17,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:Say(nLinIni + 0010, nColIni + 2350 + IIf(nLayout == 3,nColA4+20,nColA4), DtoC(aDados[nX, 18,nX1 , nX2, nX3 , nX4]), oFont04)
						oPrint:Say(nLinIni + 0010, nColIni + 2610 + IIf(nLayout == 3,nColA4+20,nColA4), IIF(Empty(aDados[nX, 19 ,nX1, nX2, nX3 , nX4]), "", Transform(aDados[nX, 19,nX1, nX2, nX3 , nX4], "@E 9999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0010, nColIni + 2855 + IIf(nLayout == 3,nColA4+20,nColA4), IIF(Empty(aDados[nX, 20 ,nX1, nX2, nX3 , nX4]), "", Transform(aDados[nX, 20,nX1, nX2, nX3 , nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0010, nColIni + 3125 + IIf(nLayout == 3,nColA4+20,nColA4), IIf(Empty(aDados[nX, 21 ,nX1, nX2, nX3 , nX4]), "", Transform(aDados[nX, 21,nX1, nX2, nX3 , nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0010, nColIni + 3400 + IIf(nLayout == 3,nColA4+20,nColA4), IIf(Empty(aDados[nX, 22 ,nX1, nX2, nX3 , nX4]), "", Transform(aDados[nX, 22,nX1, nX2, nX3 , nX4], "@E 99,999,999.99")), oFont04,,,,1)
					   	oPrint:Say(nLinIni + 0010, nColIni + 3525 + IIf(nLayout == 3,nColA4+20,nColA4), aDados[nX, 23,nX1, nX2, nX3 , nX4], oFont04)

		 		   		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)

					Next nX4

				    if lBox
						oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0010, nColIni + 3695 + nColA4)
					Endif

				    fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)

				 	oPrint:Box(nLinIni + 0010, nColIni + 2485 + nColA4, nLinIni + 0104, nColIni + 2885 + nColA4)
					oPrint:Say(nLinIni + 0015, nColIni + 2495 + nColA4, "24 - "+STR0371, oFont01) //"Valor Total Processado Guia(R$)"
					oPrint:Say(nLinIni + 0045, nColIni + 2705 + nColA4, Transform(aDados[nX, 24,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)

				    oPrint:Box(nLinIni + 0010, nColIni + 2890 + nColA4, nLinIni + 0104, nColIni + 3290 + nColA4)
					oPrint:Say(nLinIni + 0015, nColIni + 2900 + nColA4, "25 - "+STR0372, oFont01) //"Valor Total Glosa Guia(R$)"
					oPrint:Say(nLinIni + 0045, nColIni + 3110 + nColA4, Transform(aDados[nX, 25,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)

				    oPrint:Box(nLinIni + 0010, nColIni + 3295 + nColA4, nLinIni + 0104, nColIni + 3695 + nColA4)
					oPrint:Say(nLinIni + 0015, nColIni + 3305 + nColA4, "26 - "+STR0373, oFont01) //"Valor Total Liberado Guia (R$)"
					oPrint:Say(nLinIni + 0045, nColIni + 3515 + nColA4, Transform(aDados[nX, 26,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)


					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 030)
		    		nLinIni-=300
		    		oPrint:Box(nLinIni + 0385, nColIni + 1270 + nColA4, nLinIni + 0479, nColIni + 1670 + nColA4)
					oPrint:Say(nLinIni + 0390, nColIni + 1280 + nColA4, "27 - "+STR0374, oFont01) //"Valor Total Processado Lote(R$)"
					oPrint:Say(nLinIni + 0420, nColIni + 1590 + nColA4, Transform(aDados[nX, 27,nX1,nX2], "@E 999,999,999.99"), oFont04,,,,1)

				    oPrint:Box(nLinIni + 0385, nColIni + 1675 + nColA4, nLinIni + 0479, nColIni + 2075 + nColA4)
					oPrint:Say(nLinIni + 0390, nColIni + 1685 + nColA4, "28 - "+STR0375, oFont01) //"Valor Total Glosa Lote(R$)"
					oPrint:Say(nLinIni + 0420, nColIni + 1895 + nColA4, Transform(aDados[nX, 28,nX1,nX2], "@E 999,999,999.99"), oFont04,,,,1)

				    oPrint:Box(nLinIni + 0385, nColIni + 2080 + nColA4, nLinIni + 0479, nColIni + 2480 + nColA4)
					oPrint:Say(nLinIni + 0390, nColIni + 2090 + nColA4, "29 - "+STR0376, oFont01) //"Valor Total Liberado Lote (R$)"
					oPrint:Say(nLinIni + 0420, nColIni + 2300 + nColA4, Transform(aDados[nX, 29,nX1,nX2], "@E 999,999,999.99"), oFont04,,,,1)

				    oPrint:Box(nLinIni + 0385, nColIni + 2485 + nColA4, nLinIni + 0479, nColIni + 2885 + nColA4)
					oPrint:Say(nLinIni + 0390, nColIni + 2495 + nColA4, "30 - " + STR0392, oFont01)  //"Valor Geral Processado (R$)"
  					oPrint:Say(nLinIni + 0420, nColIni + 2705 + nColA4, Transform(aDados[nX, 30,nX1,1], "@E 999,999,999.99"), oFont04,,,,1)

				    oPrint:Box(nLinIni + 0385, nColIni + 2890 + nColA4, nLinIni + 0479, nColIni + 3290 + nColA4)
					oPrint:Say(nLinIni + 0390, nColIni + 2900 + nColA4, "31 - " + STR0393, oFont01)  //"Valor Geral Glosa (R$)"
					oPrint:Say(nLinIni + 0420, nColIni + 3110 + nColA4, Transform(aDados[nX, 31,nX1], "@E 999,999,999.99"), oFont04,,,,1)

				    oPrint:Box(nLinIni + 0385, nColIni + 3295 + nColA4, nLinIni + 0479, nColIni + 3695 + nColA4)
					oPrint:Say(nLinIni + 0390, nColIni + 3305 + nColA4, "32 - " + STR0394, oFont01) //"Valor Total Liberado Lote (R$)" //"Valor Geral Liberado (R$)"
					oPrint:Say(nLinIni + 0420, nColIni + 3515 + nColA4, Transform(aDados[nX, 32,nX1], "@E 999,999,999.99"), oFont04,,,,1)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 045)

			Next nX3

		Next nX2

	 	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
		oPrint:Say(nLinIni + 0420, nColIni + 0010, STR0395, oFont01) //"Demais débitos / Créditos"

	 	oPrint:Box(nLinIni + 0450, nColIni + 0010, nLinIni + 0520 + ((Len(aDados[nX, 33,nX1])/4) * 45), nColIni + 3695 + nColA4)

        nOldCol := nColIni
        nColIni := 0

		oPrint:Say(nLinIni + 0455, nColIni + 0020, "33 - " + STR0076, oFont01) //"Descrição"
		oPrint:Say(nLinIni + 0455, nColIni + 0650, "34 - " + STR0396, oFont01)  //"Valor (R$)"

		nColIni := 0

	 	For nI := 1 To Len(aDados[nX, 33,nX1])
			oPrint:Say(nLinIni + 0495, nColIni + 0020, aDados[nX, 33,nX1, nI, 1], oFont01)
			oPrint:Say(nLinIni + 0495, nColIni + 0780, IIf(Empty(aDados[nX, 33,nX1, nI, 1]), "", Transform(aDados[nX, 33,nX1, nI, 2], "@E 999,999,999.99")), oFont01,,,,1)
		   	nColini += 775
		  	If Mod(nI,4)== 0
		  		nColIni := nOldCol
			  	fSomaLin(nLinMax, nColMax, @nLinIni, nOldCol, 45)
			EndIf
		Next nI

		nColIni := nOldCol

		If (If(Empty(aDados[nX, 34,nX1]),0,Len(aDados[nX, 34,nX1]))) >;
		   (If(Empty(aDados[nX, 35,nX1]),0,Len(aDados[nX, 35,nX1])))
			nLinFin := Len(aDados[nX, 34,nX1])
		Else
			nLinFin := Len(aDados[nX, 35,nX1])
		EndIf


		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130)

		oPrint:Say(nLinIni + 0420, nColIni + 0010, STR0397, oFont01)               //"Demais débitos / créditos não tributáveis"
		oPrint:Say(nLinIni + 0420, nColIni + 1565, STR0398, oFont01)               //"Impostos"

		oPrint:Box(nLinIni + 0450, nColIni + 0010, nLinIni + 0520 + ((nLinFin/2) * 45), nColIni + 1561)
		oPrint:Box(nLinIni + 0450, nColIni + 1564, nLinIni + 0520 + ((nLinFin/2) * 45), nColIni + 3695 + nColA4)


        nColIni := 0

		oPrint:Say(nLinIni + 0455, nColIni + 0020, "35 - " + STR0076, oFont01) //"Descrição"
		oPrint:Say(nLinIni + 0455, nColIni + 0650, "36 - " + STR0396, oFont01)  //"Valor (R$)"


		nColIni += (2*775)

		oPrint:Say(nLinIni + 0455, nColIni + 0020, "37 - " + STR0076, oFont01) //"Descrição"
		oPrint:Say(nLinIni + 0455, nColIni + 0650, "38 - " + STR0396, oFont01)  //"Valor (R$)"

		nColIni := 0
		nOldLin := nLinIni
	 	For nI := 1 To Len(aDados[nX, 34,nX1])
			oPrint:Say(nLinIni + 0495, nColIni + 0020, aDados[nX, 34,nX1, nI, 1], oFont01)
			oPrint:Say(nLinIni + 0495, nColIni + 0780, IIf(Empty(aDados[nX, 34,nX1, nI, 2]), "", Transform(aDados[nX, 34,nX1, nI, 2], "@E 999,999,999.99")), oFont01,,,,1)
		   	nColini += 775
		  	If Mod(nI,2)== 0
		  		nColIni := nOldCol
			  	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
			EndIf
		Next nI

		nColIni:=0
        nLinIni := nOldLin
        nTotVlrT := 0

	 	For nI := 1 To Len(aDados[nX, 35, nX1])
			oPrint:Say(nLinIni + 0495, nColIni + 1570, aDados[nX,35,nX1,nI,1], oFont01)
			oPrint:Say(nLinIni + 0495, nColIni + 2330, Transform((aDados[nX,35,nX1,nI,2]*aDados[nX,40,nX1,1]/aDados[nX,41,nX1,1]), "@E 999,999,999.99"), oFont01,,,,1)
		   	nTotVlrT += (aDados[nX,35,nX1,nI,2]*aDados[nX,40,nX1,1]/aDados[nX,41,nX1,1])
		   	nColini += 775
		  	If Mod(nI,2)== 0
		  		nColIni := nOldCol
			  	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
			EndIf
		Next nI


		nColIni := nOldCol

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)

	   	oPrint:Say(nLinIni + 0475, nColIni + 0010, STR0399, oFont01)  //"Totais"

		oPrint:Box(nLinIni + 0505, nColIni + 0010, nLinIni + 0599, nColIni + 0395)
		oPrint:Say(nLinIni + 0510, nColIni + 0020, "39 - " + STR0287, oFont01) //"Data do Pagamento"
		oPrint:Say(nLinIni + 0540, nColIni + 0030, DtoC(aDados[nX, 36,nX1]), oFont04)

		oPrint:Box(nLinIni + 0505, nColIni + 0400, nLinIni + 0599, nColIni + 0800)
		oPrint:Say(nLinIni + 0510, nColIni + 0415, "40 - " + STR0400, oFont01) //"Valor Total Tributável (R$)"
		oPrint:Say(nLinIni + 0540, nColIni + 0425, Transform(aDados[nX, 37,nX1], "@E 999,999,999.99"), oFont04)

		oPrint:Box(nLinIni + 0505, nColIni + 0805, nLinIni + 0599, nColIni + 1205)
		oPrint:Say(nLinIni + 0510, nColIni + 0815, "41 - " + STR0401, oFont01)  //"Valor Total Impostos Retidos (R$)"
		oPrint:Say(nLinIni + 0540, nColIni + 0825, Transform(nTotVlrT, "@E 999,999,999.99"), oFont04)

		oPrint:Box(nLinIni + 0505, nColIni + 1210, nLinIni + 0599, nColIni + 1610)
		oPrint:Say(nLinIni + 0510, nColIni + 1220, "42 - " + STR0402, oFont01)  //"Valor Total Não Tributável (R$)"
		oPrint:Say(nLinIni + 0540, nColIni + 1230, Transform(aDados[nX, 39, nX1], "@E 999,999,999.99"), oFont04)

		oPrint:Box(nLinIni + 0505, nColIni + 3295 + nColA4, nLinIni + 0599, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0510, nColIni + 3305 + nColA4, "43 -  "+ STR0403, oFont01)  //"Valor Final a Receber (R$)"
    	oPrint:Say(nLinIni + 0540, nColIni + 3515 + nColA4, Transform(aDados[nX, 32,nX1], "@E 99,999,999.99"), oFont04,,,,1)

	  	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)

		oPrint:Box(nLinIni + 0510, nColIni + 0010, nLinIni + 780, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0515, nColIni + 0020, "44 - "+STR0056, oFont01) //"Observação"
		oPrint:Say(nLinIni + 0540, nColIni + 3515 + nColA4, AllTrim(BEA->BEA_MSG01) + " " + AllTrim(BEA->BEA_MSG02)+ " " + AllTrim(BEA->BEA_MSG03), oFont04,,,,1)


	Next nX1
	oPrint:EndPage()	// Finaliza a pagina

Next nX

If lAuto
	oPrint:Print()
Else
	oPrint:Preview()	// Visualiza impressao grafica antes de imprimir
EndIf

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSGSADT  ³ Autor ³ Luciano Aparecido     ³ Data ³ 10.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Consulta e SP/SADT )             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nGuia ( Informe 1- Guia de Consulta e 2-Guia de SP/SADT )   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSGSADT(nGuia)

	Local aDados := {}
	Local cTissVer	:= "2.02.03"
	
	cTissVer := PLSTISSVER()

	If ! empty(cTissVer) .and. cTissVer >= "3"
		aDados := PL446DAD(nGuia)
	EndIf

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSGREGL
Estrutura para montar a guia de recurso de glosa 

@author  PLS TEAM
@version P11
@since   25.09.15
/*/
//-------------------------------------------------------------------
function PLSGREGL()
local nTotRec:= 0
local nTotAca:= 0
local aDados := {}
local aCpo19 := {}
local aCpo20 := {}
local aCpo21 := {}
local aCpo22 := {}
local aCpo23 := {}
local aCpo24 := {}
local aCpo25 := {}
local aCpo26 := {}
local aCpo27 := {}
local aCpo28 := {}
local aCpo29 := {}

aDados := {}

//Posiciona Operadora                                         
BA0->(dbSetOrder(1))
BA0->(dbSeek(xFilial("BA0")+B4D->B4D_OPEUSR))

// Cabecalho
aAdd(aDados, BA0->BA0_SUSEP) 	// 1
aAdd(aDados, B4D->(B4D_OPEMOV+"."+B4D_ANOAUT+"."+B4D_MESAUT+"-"+B4D_NUMAUT)) // 2
aAdd(aDados, BA0->BA0_NOMINT) 	// 3
aAdd(aDados, B4D->B4D_OBJREC) 	// 4
aAdd(aDados, Transform(allTrim(B4D->(B4D_OPEMOV+B4D_NGLOPE)), "@R 9999.9999.99999999-99999999")) 	// 5
aAdd(aDados, B4D->B4D_CODRDA) 	// 6

//Posiciona Rede de Atendimento                                
BAU->(dbSetOrder(1))
BAU->(dbSeek(xFilial("BAU")+B4D->B4D_CODRDA))

aAdd(aDados, BAU->BAU_NOME) 	// 7
aAdd(aDados, B4D->B4D_NUMLOT) 	// 8
aAdd(aDados, B4D->B4D_CODPEG) 	// 9
aAdd(aDados, B4D->B4D_GLOPRT) 	// 10
aAdd(aDados, B4D->B4D_JUSPRO) 	// 11
aAdd(aDados, B4D->B4D_ACAPRO) 	// 12
aAdd(aDados, B4D->B4D_GUIPRE) 	// 13
aAdd(aDados, B4D->B4D_ATROPE) 	// 14
aAdd(aDados, B4D->B4D_SENHA)	// 15
aAdd(aDados, PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  B4D->B4D_GLOGUI ))	// 16
aAdd(aDados, B4D->B4D_JUSGUI) 	// 17
aAdd(aDados, B4D->B4D_ACAGUI) 	// 18

BR8->(dbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
B4E->(dbSetOrder(1))//B4E_FILIAL+B4E_OPEMOV+B4E_ANOAUT+B4E_MESAUT+B4E_NUMAUT+B4E_SEQUEN

cChave := xFilial("B4E")+B4D->(B4D_OPEMOV+B4D_ANOAUT+B4D_MESAUT+B4D_NUMAUT)

if B4E->(dbSeek(cChave))

	do while !B4E->(eof()) .and. cChave == B4E->(B4E_FILIAL+B4E_OPEMOV+B4E_ANOAUT+B4E_MESAUT+B4E_NUMAUT)

		If B4D->B4D_CODPEG <> B4E->B4E_CODPEG
			B4E->(Dbskip())
			Loop
		endIf
		
		aAdd(aCpo19, B4E->B4E_DATPRO)	// 19
	  	aAdd(aCpo20, B4E->B4E_DATFIN) 	// 20
		aAdd(aCpo21, B4E->B4E_CODPAD) 	// 21
		aAdd(aCpo22, B4E->B4E_CODPRO) 	// 22
		
		BR8->( dbSeek( xFilial("BR8") + B4E->(B4E_CODPAD+B4E_CODPRO) ) )
		
		aAdd(aCpo23, BR8->BR8_DESCRI) 	// 23
		aAdd(aCpo24, B4E->B4E_GRAUPA) 	// 24
		If AllTrim(B4E->B4E_GLOTIS) ==  AllTrim(B4E->B4E_CODGLO)
			aAdd(aCpo25, PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  B4E->B4E_CODGLO )) 	// 25
		Else
			aAdd(aCpo25, B4E->B4E_GLOTIS) 	// 25
		EndIf
		
		aAdd(aCpo26, B4E->B4E_VLRREC) 	// 26
		aAdd(aCpo27, B4E->B4E_JUSPRE) 	// 27
		aAdd(aCpo28, B4E->B4E_VLRACA) 	// 28
		aAdd(aCpo29, B4E->B4E_JUSOPE) 	// 29
		
		nTotRec += B4E->B4E_VLRREC
		nTotAca += B4E->B4E_VLRACA
		
	B4E->(dbSkip())	
	endDo
	
	// 19 a 29
	aAdd(aDados, aCpo19)
	aAdd(aDados, aCpo20)
	aAdd(aDados, aCpo21)
	aAdd(aDados, aCpo22)
	aAdd(aDados, aCpo23)
	aAdd(aDados, aCpo24)
	aAdd(aDados, aCpo25)
	aAdd(aDados, aCpo26)
	aAdd(aDados, aCpo27)
	aAdd(aDados, aCpo28)
	aAdd(aDados, aCpo29)
		
	aAdd(aDados, nTotRec) 	// 30
	aAdd(aDados, nTotAca) 	// 31
	aAdd(aDados, B4D->B4D_DATREC) // 32
	aAdd(aDados, '') 		// 33
	aAdd(aDados, date()) 	// 34
	aAdd(aDados, '') 		// 35
endIf	

return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSGINT   ³ Autor ³ Luciano Aparecido     ³ Data ³ 15.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Solicitação e Resumo Internação )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nGuia ( Informe 1- Guia de Solicitação e 2-Guia de Resumo ) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSGINT(nGuia,lOldPror)

	Local aDados    := {}
	Local cTissVer := "2.02.03"
	Default lOldPror := .F.

	If FindFunction("PLSA443")
		cTissVer := PLSTISSVER()
	EndIf

	If !Empty(cTissVer) .AND. cTissVer >= "3"
		If nGuia == 1
			aDados := PL446DAD("3")
		ElseiF nGuia == 2
			aDados := PL446DAD("5")
		Else
			if !lOldPror
	   			aDados := PL446DAD("11")
			else
				aDados := PL446OLDPR()
			endIf	   
		EndIf
	EndIf

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSGHONI  ³ Autor ³ Luciano Aparecido     ³ Data ³ 01.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Hon. Individual e Guia Despesas )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nGuia (Informe 1- Guia honorario Indiv.e 2-Guia de Despesas)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSGHONI(nGuia)

Local aCpo23
Local aCpo24
Local aCpo25
Local aCpo26
Local aCpo27
Local aCpo28
Local aCpo29
Local aCpo30
Local aCpo31
Local aCpo32
Local aCpo33
Local aCpo34
Local aDados := {}
Local cChave := ""
Local cTissVer := "3.05.00" //PLSTISSVER()

If FindFunction("PLSTISSVER")
	cTissVer := PLSTISSVER()
EndIf
aDados := {}

If !Empty(cTissVer) .and. cTissVer >= "3" .and. nGuia == 1
	//Tem que posicionar na BA1 para pegar o nome correto
	BA1->(dbsetorder(2)) //BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO
	BA1->( DbSeek(xFilial("BA1") + BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)) )
	
	// Cabecalho
	aAdd(aDados, BA0->BA0_SUSEP) //1
	aAdd(aDados, BD5->(BD5_CODOPE+'.'+BD5_ANOAUT+'.'+BD5_MESAUT+'.'+BD5_NUMAUT)) //2
	BE4->(DbSetOrder(2))
	BE4->(MsSeek(xFilial('BE4')+BD5->BD5_GUIPRI))
	aAdd(aDados, BE4->(BE4_CODOPE+'.'+BE4_ANOINT+'.'+BE4_MESINT+'.'+BE4_NUMINT)) //3 Nr Guia Solicitacao
	aAdd(aDados, BD5->BD5_SENHA) //4
	aAdd(aDados, BD5->(BD5_CODOPE+'.'+BD5_ANOAUT+'.'+BD5_MESAUT+'.'+BD5_NUMAUT)) //5

	// Dados do Beneficiario
	aAdd(aDados, BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO))  //6
	aAdd(aDados, BA1->BA1_NOMUSR) //7
	aAdd(aDados, 'N') //8

	// Dados do Contratado (onde foi executado o procedimento)

	//Posiciona Rede de Atendimento                                
	BAU->(dbSetOrder(1))
	BAU->(dbSeek(xFilial("BAU")+BD5->BD5_CODRDA))

	aAdd(aDados, IIf(Len(AllTrim(BAU->BAU_CPFCGC)) == 11, Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) //9
	aAdd(aDados, BAU->BAU_NOME) //10

	//Posiciona Locais de Rede Atendimento                                
	BB8->(dbSetOrder(1))
	BB8->(dbSeek(xFilial("BB8")+BD5->(BD5_CODRDA+BD5_CODOPE+BD5_CODLOC+BD5_LOCAL)))

	aAdd(aDados, Transform(BB8->BB8_CNES, cPicCNES)) //11

	// Dados do Contratado Executante

	//Posiciona Rede de Atendimento                                ?
	BAU->(dbSetOrder(1))
	BAU->(dbSeek(xFilial("BAU")+BD5->BD5_CODRDA))
	aAdd(aDados, IIf(Len(AllTrim(BAU->BAU_CPFCGC)) == 11, Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) //12
	aAdd(aDados, BAU->BAU_NOME) //13

	//Posiciona Locais de Rede Atendimento                                
	BB8->(dbSetOrder(1))
	BB8->(dbSeek(xFilial("BB8")+BD5->(BD5_CODRDA+BD5_CODOPE+BD5_CODLOC+BD5_LOCAL)))

	aAdd(aDados, Transform(BB8->BB8_CNES, cPicCNES)) //14

	aAdd(aDados, BD5->BD5_DTFTIN) //15
	aAdd(aDados, BD5->BD5_DTFTFN) //16

	// Dados do Procedimento
	aCpo17 := {}
	aCpo18 := {}
	aCpo19 := {}
	aCpo20 := {}
	aCpo21 := {}
	aCpo22 := {}
	aCpo23 := {}
	aCpo24 := {}
	aCpo25 := {}
	aCpo26 := {}
	aCpo27 := {}
	aCpo28 := {}
	aCpo29 := {}
	aCpo30 := {}
	aCpo31 := {}
	aCpo32 := {}
	aCpo33 := {}
	aCpo34 := {}
	aCpo35 := {}
	aCpo36 := {}
	aCpo37 := {}
	aCpo38 := {}
	aCpo39 := {}
	aCpo40 := {}
	nVrTot := 0


	BD6->(dbSetOrder(1))//BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, BD6_CODPAD, BD6_CODPRO, R_E_C_N_O_, D_E_L_E_T_
	BD7->(dbSetOrder(1))//BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODUNM, BD7_NLANC, R_E_C_N_O_, D_E_L_E_T_
	cChave	:= BD5->(BD5_FILIAL+ BD5_CODOPE+ BD5_CODLDP+ BD5_CODPEG + BD5_NUMERO)

	If BD6->(MsSeek( cChave ) )
		Do While !BD6->(Eof()) .And. cChave == BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP+ BD6_CODPEG+ BD6_NUMERO)
		

			If BD6->BD6_STATUS <> '0'
				aAdd(aCpo17, BD6->BD6_DATPRO)
				aAdd(aCpo18, BD6->BD6_HORPRO)
				aAdd(aCpo19, BD6->BD6_HORFIM)
				aAdd(aCpo20, BD6->BD6_CODPAD)
				aAdd(aCpo21, BD6->BD6_CODPRO)
				aAdd(aCpo22, BD6->BD6_DESPRO)
				aAdd(aCpo23, BD6->BD6_QTDPRO)
				aAdd(aCpo24, BD6->BD6_VIA)
				aAdd(aCpo25, BD6->BD6_TECUTI)
				aAdd(aCpo26, '')
				aAdd(aCpo27, BD6->BD6_VLRPAG)
				aAdd(aCpo28, BD6->BD6_VLRPAG)
				nVrTot += BD6->BD6_VLRPAG

				cChaveBD7	:= BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				If BD7->(MsSeek( cChaveBD7 ) )
					While !BD7->(Eof()) .And. cChaveBD7 == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
						aAdd(aCpo29, BD7->BD7_SEQUEN)
						BWT->(DbSetORder(1))
						BWT->(MsSeek(xFilial("BWT")+PlsIntPAd()+BD7->BD7_CODTPA))
						If PLSTISSVER() >= "3"
							cCpo30 := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", BWT->BWT_CODEDI)
						ENDIF
						IF EMPTY(cCpo30)
							cCpo30 := aAdd(aCpo30, BWT->BWT_CODEDI)
						ENDIF
						aAdd(aCpo30, cCpo30)	//GRAU DE PARTICIPACAO DO PROFISSIONAL NA EQUIPE  17
						aAdd(aCpo31, BD7->BD7_REGPRE)
						aAdd(aCpo32, BD7->BD7_NOMPRE)
						aAdd(aCpo33, BD7->BD7_SIGLA)
						aAdd(aCpo34, BD7->BD7_CDPFPR)
						aAdd(aCpo35, BD7->BD7_ESTPRE)
						aAdd(aCpo36, BD7->BD7_CBOEXE)
						BD7->(dbSkip())
					Enddo
				EndIf	


			Endif

			BD6->(dbSkip())
		Enddo
	EndIf

	aAdd(aDados, aCpo17)
	aAdd(aDados, aCpo18)
	aAdd(aDados, aCpo19)
	aAdd(aDados, aCpo20)
	aAdd(aDados, aCpo21)
	aAdd(aDados, aCpo22)
	aAdd(aDados, aCpo23)
	aAdd(aDados, aCpo24)
	aAdd(aDados, aCpo25)
	aAdd(aDados, aCpo26)
	aAdd(aDados, aCpo27)
	aAdd(aDados, aCpo28)


	aAdd(aDados, aCpo29)
	aAdd(aDados, aCpo30)
	aAdd(aDados, aCpo31)
	aAdd(aDados, aCpo32)
	aAdd(aDados, aCpo33)
	aAdd(aDados, aCpo34)
	aAdd(aDados, aCpo35)
	aAdd(aDados, aCpo36)


	aAdd(aDados, Alltrim(BD5->BD5_OBSGUI))
	aAdd(aDados, nVrTot) // Valor final do Honorario Medico considerando o somatorio do campo valor total
	aAdd(aDados, BD5->BD5_DATPRO)
	aAdd(aDados, { dDataBase, Time() })
	aAdd(aDados, BE4->BE4_NOMSOC)

	
EndIf


Return aDados


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSDACM   ³ Autor ³ Luciano Aparecido     ³ Data ³ 03.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Demonst. Análise Contas Médicas )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodRda - Código da RDA a ser processado o Relatório        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSDACM(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cLocRda , cNFSSDe, cNFSSAte,cNmTitPg,cPEGDe, cPEGAte,cAlias)
Local aCpo04,aCpo05,aCpo06,aCpo07,aCpo08,aCpo09,aCpo10, aCpo11, aCpo12, aCpo13, aCpo14, aCpo15
local aCpo16, aCpo17, aCpo18, aCpo19, aCpo20, aCpo21, aCpo22, aCpo23, aCpo24, aCpo25, aCpo26
local aCpo27, aCpo28, aCpo29

Local nInd1, nInd2,nInd3
Local aDados :={}
Local cSQL
LOCAL lAchouUm := .F.
local nProcGui := 0
LOCAL nLibGui  := 0
LOCAL nGloGui  := 0
LOCAL nProcFat := 0
LOCAL nLibFat  := 0
LOCAL nGloFat  := 0
LOCAL nProcGer := 0
LOCAL nLibGer  := 0
LOCAL nGloGer  := 0
LOCAL lFlag	   := .F.
LOCAL cNmLotPg		:= ""
LOCAL cRdaLote		:= ""

DEFAULT cLocRda 	:= ""
DEFAULT cNFSSDe 	:= ""
DEFAULT cNFSSAte 	:= ""
DEFAULT cNmTitPg 	:= ""
DEFAULT cPEGDe		:= " "
DEFAULT cPEGAte		:= Replicate("Z",Len(BD7->BD7_CODPEG))

// Peg Final não pode ser em branco.
If Empty(cPEGAte)
	cPEGAte		:= Replicate("Z",Len(BD7->BD7_CODPEG))
Endif

If !Empty(cNmTitPg)
	If cAlias == "SE2"
		SE2->(dbSetorder(01))
		If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
			cCodOpe  := SE2->E2_PLOPELT
			cNmLotPg := SE2->E2_PLLOTE
			cRdaLote := SE2->E2_CODRDA
			cAno 	 := SE2->E2_ANOBASE
			cMes	 := SE2->E2_MESBASE
		Endif
	Else
		SC7->(dbSetorder(01))
		If SC7->(dbSeek(xFilial("SC7")+cNmTitPg))
			cCodOpe  := If(SC7->(FieldPos("C7_PLOPELT"))>0,SC7->C7_PLOPELT,PLSINTPAD())
			cNmLotPg := SC7->C7_LOTPLS
			cRdaLote := SC7->C7_CODRDA
			cFornece:= SC7->C7_FORNECE
			cLoja    := SC7->C7_LOJA
			cAno := Substr(SC7->C7_LOTPLS,1,4)
			cMes := Substr(SC7->C7_LOTPLS,5,2)
		Endif
	Endif
Endif
cSQL := "SELECT BD7_CODEMP, BD7_CODLDP, BD7_CODOPE, BD7_CODPAD, BD7_CODPEG, BD7_CODPRO, BD7_CODRDA, BD7_CODTPA, BD7_DATPRO, BD7_MATRIC, BD7_NOMRDA, BD7_NOMUSR, BD7_NUMERO, BD7_NUMLOT, BD7_OPELOT, BD7_ORIMOV, BD7_SEQUEN, BD7_TIPREG, BD7_MOTBLO, BD7_VLRMAN, BD7_VLRPAG, BD7_VLRGLO, BD7_ANOPAG, BD7_MESPAG, R_E_C_N_O_ AS RECNO "
cSQL += "  FROM " + RetSqlName("BD7")
cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
cSQL += " BD7_OPELOT = '"+cCodOpe+"' AND "

cSQL += "( BD7_CODPEG >= '" + cPEGDe    + "' AND BD7_CODPEG <= '" + cPEGAte + "' ) AND "
If !Empty(cNmLotPg)
	cSQL += "BD7_CODRDA = '"+ cRdaLote +"' AND "
	cSQL += "BD7_NUMLOT = '"+ cNmLotPg +"' AND "

Else
	If Len(AllTrim(cAno+cMes)) == 6
		cSQL += "( BD7_CODRDA >= '" + cRdaDe    + "' AND BD7_CODRDA <= '" + cRdaAte    + "' ) AND "
		cSQL += " BD7_NUMLOT LIKE '"+cAno+cMes+"%' AND "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente pega as guias de um mesma NFSS							  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Else
		If BD7->(FieldPos("BD7_SEQNFS")) > 0
			If !Empty(cNFSSAte)
				cSQL += "( BD7_SEQNFS >= '"+cNFSSDe+"' AND BD7_SEQNFS <= '"+cNFSSAte+"' ) AND "
				cSQL += "( BD7_CODRDA >= '" + cRdaDe    + "' AND BD7_CODRDA <= '" + cRdaAte    + "' ) AND "
				cSQL += "BD7_FASE IN ('3','4') AND "
			EndIf
		Endif
	EndIf
Endif

cSql += RetSQLName("BD7")+".D_E_L_E_T_ = ' '"
cSQL += " ORDER BY BD7_NUMLOT, BD7_CODRDA, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_SEQUEN "
PlsQuery(cSQL,"TrbBD7")

// BA0 - Operadoras de Saude
BA0->(dbSetOrder(1))
BA0->(msSeek(xFilial("BA0")+TrbBD7->(BD7_CODOPE)))

Do While ! TrbBD7->(Eof())

	aCpo04 := {}
	aCpo05 := {}
	aCpo06 := {}
	aCpo07 := {}
	aCpo08 := {}
	aCpo09 := {}
	aCpo10 := {}
	aCpo11 := {}
	aCpo12 := {}
	aCpo13 := {}
	aCpo14 := {}
	aCpo15 := {}
	aCpo16 := {}
	aCpo17 := {}
	aCpo18 := {}
	aCpo19 := {}
	aCpo20 := {}
	aCpo21 := {}
	aCpo22 := {}
	aCpo23 := {}
	aCpo24 := {}
	aCpo25 := {}
	aCpo26 := {}
	aCpo27 := {}
	aCpo28 := {}
	aCpo29 := {}

	aAdd(aDados, BA0->BA0_SUSEP) // 1
	aAdd(aDados, BA0->BA0_NOMINT) // 2
	aAdd(aDados, Transform(BA0->BA0_CGC, "@R 99.999.999/9999-99")) // 3

	Do While ! TrbBD7->(Eof())

		// BAU - Redes de Atendimento
		BAU->(dbSetOrder(1))
		BAU->(msSeek(xFilial("BAU")+TrbBD7->BD7_CODRDA))

		// BAF - Lotes de Pagamentos RDA
		BAF->(dbSetOrder(1))
		BAF->(msSeek(xFilial("BAF")+TrbBD7->(BD7_OPELOT+BD7_NUMLOT)))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Contas Medicas                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BD5->(dbSetOrder(1)) //BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA, R_E_C_N_O_, D_E_L_E_T_
		BD5->(MsSeek(xFilial("BD5")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Na Web o relatorio e por local de atendimento				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(AllTrim(cAno+cMes)) == 6
			//If !Empty(cLocRda) .And. !BD5->BD5_LOCAL == cLocRda //
			If !Empty(cLocRda) .And. !BD5->BD5_CODLOC == cLocRda
				TrbBD7->( dbSkip() )
				Loop
			Endif
		EndIf

		lAchouUm := .T.
		nProcGer :=0
		nLibGer  :=0
		nGloGer  :=0

		If Empty(cNmTitPg) .and. Empty(cNmLotPg)
			cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO "
			cSQL += "  FROM " + RetSQLName("SE2")
			cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
			cSQL += "    AND E2_PLOPELT = '" + TrbBD7->BD7_OPELOT + "'"
			cSQL += "    AND E2_PLLOTE = '" + TrbBD7->BD7_NUMLOT + "'"
			cSQL += "    AND E2_CODRDA = '" + TrbBD7->BD7_CODRDA + "'"
			cSQL += "    AND D_E_L_E_T_ = ' ' "

			PlsQuery(cSQL,"TrbSE2")

			If ! TrbSE2->(Eof())
				SE2->(dbGoTo(TrbSE2->(E2_RECNO)))
			EndIf

			TrbSE2->(DbCloseArea())
		Endif

		aAdd(aCpo04, BAF->(BAF_ANOLOT+BAF_MESLOT+BAF_NUMLOT)) // 4
		aAdd(aCpo05, BAF->BAF_DTDIGI) // 5
		aAdd(aCpo06, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) // 6
		aAdd(aCpo07, BAU->BAU_NOME) // 7

		BB8->(dbSetOrder(1))
		BB8->(dbSeek(xFilial("BB8")+TrbBD7->(BD7_CODRDA+BD7_CODOPE)+BD5->BD5_CODLOC))

		aAdd(aCpo08, Transform(BB8->BB8_CNES, cPicCNES)) // 8
		aAdd(aCpo09, If(cAlias=="SE2",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA),SC7->C7_NUM)) // 9

		aAdd(aCpo10,{})
		aAdd(aCpo11,{})
		aAdd(aCpo12,{})
		aAdd(aCpo13,{})
		aAdd(aCpo14,{})
		aAdd(aCpo15,{})
		aAdd(aCpo16,{})
		aAdd(aCpo17,{})
		aAdd(aCpo18,{})
		aAdd(aCpo19,{})
		aAdd(aCpo20,{})
		aAdd(aCpo21,{})
		aAdd(aCpo22,{})
		aAdd(aCpo23,{})
		aAdd(aCpo24,{})
		aAdd(aCpo25,{})
		aAdd(aCpo26,{})
		aAdd(aCpo27,{})
		aAdd(aCpo28,{})
		nInd1 := Len(aCpo04)

		cChRDA := TrbBD7->(BD7_NUMLOT+BD7_CODRDA)
		Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA) ==  cChRDA

			// BCI - PEGS ??????????
			BCI->(dbSetOrder(5))
			BCI->(msSeek(xFilial("BCI")+TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)))

			aAdd(aCpo10[nInd1], TrbBD7->(BD7_CODLDP+BD7_CODPEG)) // 10
			aAdd(aCpo11[nInd1], BCI->BCI_DATREC) // 11
			aAdd(aCpo12[nInd1], BCI->BCI_CODPEG) // 12
			aAdd(aCpo13[nInd1], BCI->BCI_VLRGUI) // 13
			aAdd(aCpo14[nInd1], TrbBD7->BD7_VLRGLO) // 14 (VALOR GLOSA PROTOCOLO)
			aAdd(aCpo15[nInd1], "") // 15 (CODIGO GLOSA PROTOCOLO)   ?????

			nProcGer+=TrbBD7->BD7_VLRPAG
			nLibGer +=TrbBD7->BD7_VLRPAG
			nGloGer +=TrbBD7->BD7_VLRGLO

			aAdd(aCpo16[nInd1], {})
			aAdd(aCpo17[nInd1], {})
			aAdd(aCpo18[nInd1], {})
			aAdd(aCpo19[nInd1], {})
			aAdd(aCpo20[nInd1], {})
			aAdd(aCpo21[nInd1], {})
			aAdd(aCpo22[nInd1], {})
			aAdd(aCpo23[nInd1], {})
			aAdd(aCpo24[nInd1], {})
			aAdd(aCpo25[nInd1], {})
			aAdd(aCpo26[nInd1], {})
			aAdd(aCpo27[nInd1], {})
			aAdd(aCpo28[nInd1], {})

			nInd2 := Len(aCpo10[nInd1])

			nProcFat:=0
			nLibFat :=0
			nGloFat :=0
			cChFat := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG)
			Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG) ==  cChFat

				BA1->(dbSetOrder(2))
				BA1->(msSeek(xFilial("BA1")+TrbBD7->(BD7_CODOPE+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)))

				aAdd(aCpo16[nInd1, nInd2], TrbBD7->BD7_NUMERO) // 16
				aAdd(aCpo17[nInd1, nInd2], TrbBD7->BD7_NOMUSR) // 17
				If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT)
					aAdd(aCpo18[nInd1, nInd2], BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"-"+BA1_DIGITO)	) // 18
				Else
					aAdd(aCpo18[nInd1, nInd2], BA1->BA1_MATANT) // 18
				EndIf

				nProcFat+=TrbBD7->BD7_VLRPAG
				nLibFat +=TrbBD7->BD7_VLRPAG
				nGloFat +=TrbBD7->BD7_VLRGLO

				aAdd(aCpo19[nInd1, nInd2], {})
				aAdd(aCpo20[nInd1, nInd2], {})
				aAdd(aCpo21[nInd1, nInd2], {})
				aAdd(aCpo22[nInd1, nInd2], {})
				aAdd(aCpo23[nInd1, nInd2], {})
				aAdd(aCpo24[nInd1, nInd2], {})
				aAdd(aCpo25[nInd1, nInd2], {})
				aAdd(aCpo26[nInd1, nInd2], {})
				aAdd(aCpo27[nInd1, nInd2], {})
				aAdd(aCpo28[nInd1, nInd2], {})
				nInd3 := Len(aCpo16[nInd1, nInd2])

				nProcGui:=0
				nLibGui :=0
				nGloGui :=0
				cChGuia := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
				Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) ==  cChGuia
					// BR8 - Tabela Padrao
					BR8->(dbSetOrder(1))
					BR8->(msSeek(xFilial("BR8")+TrbBD7->(BD7_CODPAD+BD7_CODPRO)))
					// BWT - Tipo de Participacao
					BWT->(dbSetOrder(1))
					BWT->(msSeek(xFilial("BWT")+TrbBD7->(BD7_CODOPE+BD7_CODTPA)))
					aAdd(aCpo19[nInd1, nInd2, nInd3], TrbBD7->BD7_DATPRO) //19
					aAdd(aCpo20[nInd1, nInd2, nInd3], BR8->BR8_DESCRI)    //20

					BD6->(dbSetOrder(1))
					BD6->(msSeek(xFilial("BD6")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)))

					aAdd(aCpo21[nInd1, nInd2, nInd3],Posicione("BF8", 2, xFilial("BF8")+BD6->(BD6_CODPAD+BD6_CODOPE+BD6_CODTAB), "BF8_TABTIS"))//21

					//	aAdd(aCpo21[nInd1, nInd2, nInd3], TrbBD7->BD7_CODPAD)  //21
					aAdd(aCpo22[nInd1, nInd2, nInd3], PLSPICPRO(TrbBD7->BD7_CODPAD, TrbBD7->BD7_CODPRO))//22

					BWT->(dbSetOrder(1))
					BWT->(MsSeek(xFilial("BWT")+TrbBD7->(BD7_CODOPE+BD7_CODTPA)))

					aAdd(aCpo23[nInd1, nInd2, nInd3], BWT->BWT_CODEDI) 	//23
					aAdd(aCpo24[nInd1, nInd2, nInd3], BD6->BD6_QTDPRO) 	// 24
					aAdd(aCpo25[nInd1, nInd2, nInd3], Iif (!Empty(TrbBD7->BD7_VLRPAG),TrbBD7->BD7_VLRPAG,0) + Iif (!Empty(TrbBD7->BD7_VLRGLO),TrbBD7->BD7_VLRGLO,0)) //25
					nProcGui+=Iif (!Empty(TrbBD7->BD7_VLRPAG),TrbBD7->BD7_VLRPAG,0) + Iif (!Empty(TrbBD7->BD7_VLRGLO),TrbBD7->BD7_VLRGLO,0)
					aAdd(aCpo26[nInd1, nInd2, nInd3], Iif (!Empty(TrbBD7->BD7_VLRPAG),TrbBD7->BD7_VLRPAG,0)) //26
					nLibGui+=TrbBD7->BD7_VLRPAG
					aAdd(aCpo27[nInd1, nInd2, nInd3], Iif (!Empty(TrbBD7->BD7_VLRGLO),TrbBD7->BD7_VLRGLO,0)) //27
					nGloGui+=TrbBD7->BD7_VLRGLO
					// BDX - Glosas das Movimentacoes
					cCpo28 := ""
					lFlag  := .F.
					BDX->(dbSetOrder(1))
					If  BDX->(msSeek(xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)))
						Do While ! BDX->(eof()) .And. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == ;
							xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)

							BCT->(dbSetOrder(1))
							If BCT->(msSeek(xFilial("BCT")+BDX->(BDX_CODOPE+BDX_CODGLO))) .And.;
								At(BCT->BCT_GLTISS,cCpo28)==0

								If BDX->BDX_TIPREG == "1" .Or. (BDX->BDX_CODGLO==__aCdCri049[1] .And. !lFlag)
									cCpo28 += IIf(Empty(cCpo28), "", ", ") + AllTrim(BCT->BCT_GLTISS)
								Endif

							EndIf

							If BDX->BDX_CODGLO == __aCdCri049[1]
								lFlag := .T.
							EndIf

							BDX->(dbSkip())
						EndDo
					EndIf
					aAdd(aCpo28[nInd1, nInd2, nInd3], cCpo28)
					aAdd(aCpo29,TrbBD7->RECNO) //29
					TrbBD7->(dbSkip())
				EndDo
			Enddo
		EndDo
	EndDo
	aAdd(aDados, aCpo04)
	aAdd(aDados, aCpo05)
	aAdd(aDados, aCpo06)
	aAdd(aDados, aCpo07)
	aAdd(aDados, aCpo08)
	aAdd(aDados, aCpo09)
	aAdd(aDados, aCpo10)
	aAdd(aDados, aCpo11)
	aAdd(aDados, aCpo12)
	aAdd(aDados, aCpo13)
	aAdd(aDados, aCpo14)
	aAdd(aDados, aCpo15)
	aAdd(aDados, aCpo16)
	aAdd(aDados, aCpo17)
	aAdd(aDados, aCpo18)
	aAdd(aDados, aCpo19)
	aAdd(aDados, aCpo20)
	aAdd(aDados, aCpo21)
	aAdd(aDados, aCpo22)
	aAdd(aDados, aCpo23)
	aAdd(aDados, aCpo24)
	aAdd(aDados, aCpo25)
	aAdd(aDados, aCpo26)
	aAdd(aDados, aCpo27)
	aAdd(aDados, aCpo28)
	aAdd(aDados, nProcGui)//29 Valor Processado Guia
	aAdd(aDados, nLibGui)//30 Valor Liberado Guia
	aAdd(aDados, nGloGui)//31 Valor Glosa Guia
	aAdd(aDados, "")	  //32 Codigo Glosa Guia
	aAdd(aDados, nProcFat)//33 Valor Processado Fatura
	aAdd(aDados, nLibFat)//34 Valor Liberado Fatura
	aAdd(aDados, nGloFat)//35 Valor Glosa Fatura
	aAdd(aDados, nProcGer)//36 Valor Processado Fatura
	aAdd(aDados, nLibGer)//37 Valor Liberado Fatura
	aAdd(aDados, nGloGer)//38 Valor Glosa Fatura
	aAdd(aDados, aCpo29) //39 recnos

	If !lAchouUm
		aDados := {}
	EndIf
Enddo
TrbBD7->(DbCloseArea())

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSDPGT   ³ Autor ³ Luciano Aparecido     ³ Data ³ 05.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Demonstrativo de Pagamento )     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodOpe - Código da Operadora                               ³±±
±±³          ³ cRdaDe  - Código da RDA a ser processada (de)               ³±±
±±³          ³ cRdaAte - Código da RDA a ser processada (Até)              ³±±
±±³          ³ cAno    - Informe o Ano a ser processado                    ³±±
±±³          ³ cMes    - Informe o Mês a ser processado                    ³±±
±±³          ³ cClaPre - Classe RDA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSDPGT(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre,cNFSSDe,cNFSSAte,cNmTitPg,cAlias)

	Local aCpo04,aCpo05, aCpo06, aCpo07, aCpo08, aCpo09, aCpo10, aCpo11, aCpo12, aCpo13
	Local aCpo14, aCpo15, aCpo16, aCpo17, aCpo18, aCpo19, aCpo20, aCpo21, aCpo22
	Local aCpo23, aCpo24, aCpo25, aCpo26, aCpo27,aCpo28
	Local aDados
	Local cSQL
	Local nInd1, nCont:=0
	LOCAL cNmLotPg		:= ""
	LOCAL cRdaLote		:= ""

	DEFAULT cNFSSDe 	:= ""
	DEFAULT cNFSSAte 	:= ""
	DEFAULT cNmTitPg 	:= ""
	DEFAULT cAlias := "SE2"

	DBSELECTAREA(cAlias)
	// Variaveis para buscar o BMR pelo numero do titulo.
	If !Empty(cNmTitPg)
		If cAlias ="SE2"
			SE2->(dbSetorder(01))
			If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
				cCodOpe  := SE2->E2_PLOPELT
				cNmLotPg := Subs(SE2->E2_PLLOTE,7,4)
				cRdaLote := SE2->E2_CODRDA
	            cFornece:= SE2->E2_FORNECE
	            cLoja    := SE2->E2_LOJA
				cAno := SE2->E2_ANOBASE
				cMes := SE2->E2_MESBASE
			Endif
		Else
			SC7->(dbSetorder(01))
			If SC7->(dbSeek(xFilial("SC7")+cNmTitPg))
				cCodOpe  := If(SC7->(FieldPos("C7_PLOPELT"))>0,SC7->C7_PLOPELT,PLSINTPAD())
				cNmLotPg := Subs(SC7->C7_LOTPLS,7,4)
				cRdaLote := SC7->C7_CODRDA
				cFornece:= SC7->C7_FORNECE
	            cLoja    := SC7->C7_LOJA

				cAno := Substr(SC7->C7_LOTPLS,1,4)
				cMes := Substr(SC7->C7_LOTPLS,5,2)
			Endif


		Endif
	Else
		cFornece:=SE2->E2_FORNECE
		cLoja := SE2->E2_LOJA

	Endif
	aDados := {}

	cSQL := "SELECT BMR_ANOLOT, BMR_CODLAN, BMR_CODRDA, BMR_DEBCRE, BMR_FILIAL, BMR_MESLOT, BMR_NUMLOT, BMR_OPELOT, BMR_OPERDA, BMR_VLRPAG"
	cSQL += "  FROM " + RetSqlName("BMR")
	cSQL += " WHERE BMR_FILIAL = '" + xFilial("BMR") + "' AND "
	cSQL += "  BMR_OPELOT = '" + cCodOpe + "' AND "
	If !Empty(cNmLotPg)
	    cSQL += "BMR_CODRDA = '" + cRdaLote + "' AND "
		cSQL += "BMR_NUMLOT = '" + cNmLotPg + "' AND "

	Else
	    cSQL += "( BMR_CODRDA >= '" + cRdaDe + "' AND BMR_CODRDA <= '" + cRdaAte + "' ) AND "
	Endif

	cSQL += " BMR_ANOLOT = '" + cAno + "' AND "
	cSQL += " BMR_MESLOT = '" + cMes + "' AND "
	cSql += RetSQLName("BMR")+".D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY BMR_FILIAL, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT, BMR_OPERDA, BMR_CODRDA, BMR_CODLAN "

	PlsQuery(cSQL,"TrbBMR")

	// BA0 - Operadoras de Saude
	BA0->(dbSetOrder(1))
	BA0->(msSeek(xFilial("BA0")+TrbBMR->(BMR_OPERDA)))

   	Do While ! TrbBMR->(Eof())
	    nCont+=1
		// BAU - Redes de Atendimento
		BAU->(dbSetOrder(1))
		BAU->(msSeek(xFilial("BAU")+TrbBMR->BMR_CODRDA))

		// BAF - Lotes plsde Pagamentos RDA
		BAF->(dbSetOrder(1))
		BAF->(msSeek(xFilial("BAF")+TrbBMR->(BMR_OPERDA+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)))

		If Empty(cNmTitPg) .and. Empty(cNmLotPg)
			cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO,E2_VENCTO,E2_FORNECE,E2_LOJA "
			cSQL += "  FROM " + RetSQLName("SE2")
			cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
			cSQL += "    AND E2_PLOPELT = '" + TrbBMR->BMR_OPELOT + "'"
			cSQL += "    AND E2_PLLOTE = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
			cSQL += "    AND E2_CODRDA = '" + TrbBMR->BMR_CODRDA + "'"
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			PlsQuery(cSQL,"TrbSE2")

			If ! TrbSE2->(Eof())
				SE2->(dbGoTo(TrbSE2->(E2_RECNO)))
			EndIf

			TrbSE2->(DbCloseArea())
		Endif

		// SA2 - Cadastro de Fornecedores
		SA2->(dbSetOrder(1))
		SA2->(msSeek(xFilial("SA2")+cFornece+cLoja))

		If nCont == 1
			aAdd(aDados, BA0->BA0_SUSEP) // 1
			aAdd(aDados, BA0->BA0_NOMINT) // 2
			aAdd(aDados, Transform(BA0->BA0_CGC, "@R 99.999.999/9999-99")) // 3
			aCpo04 := {}
			aCpo05 := {}
			aCpo06 := {}
			aCpo07 := {}
			aCpo08 := {}
			aCpo09 := {}
			aCpo10 := {}
			aCpo11 := {}
			aCpo12 := {}
			aCpo13 := {}
			aCpo14 := {}
			aCpo15 := {}
			aCpo16 := {}
			aCpo17 := {}
			aCpo18 := {}
			aCpo19 := {}
			aCpo20 := {}
			aCpo21 := {}
			aCpo22 := {}
			aCpo23 := {}
			aCpo24 := {}
			aCpo25 := {}
			aCpo26 := {}
			aCpo27 := {}
			aCpo28 := {}
		Endif

		cSQL := "SELECT BD7_CODOPE, BD7_CODRDA, BD7_CODOPE, BD7_CODLDP,BD7_NUMERO, BD7_CODPEG, BD7_ORIMOV,BD7_SEQUEN,BD7_CODPAD, BD7_VLRAPR,BD7_CODPRO, BD7_VLRPAG, BD7_VLRGLO "
		cSQL += "  FROM " + RetSqlName("BD7")
		cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "'"
		cSQL += "   AND BD7_NUMLOT = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
		cSQL += "   AND BD7_CODRDA = '" + TrbBMR->(BMR_CODRDA)+ "'"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente pega as guias de um mesma NFSS							  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BD7->(FieldPos("BD7_SEQNFS")) > 0
		  	If !Empty(cNFSSAte)
		  		cSQL += "AND ( BD7_SEQNFS >= '"+cNFSSDe+"' AND BD7_SEQNFS <= '"+cNFSSAte+"' ) "
		  	EndIf
		Endif
		cSQL += "   AND D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY BD7_CODLDP,BD7_CODPEG"

		PlsQuery(cSQL,"TrbBD7")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Contas Medicas                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BD5->(dbSetOrder(1))
		BD5->(MsSeek(xFilial("BD5")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))

		aAdd(aCpo04, BAF->(BAF_ANOLOT+BAF_MESLOT+BAF_NUMLOT)) // 4
		aAdd(aCpo05, BAF->BAF_DTDIGI) // 5
		aAdd(aCpo06, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) // 6
		aAdd(aCpo07, BAU->BAU_NOME) // 7

		BB8->(dbSetOrder(1))
		BB8->(dbSeek(xFilial("BB8")+BD7->(BD7_CODRDA+BD7_CODOPE)+BD5->BD5_CODLOC))

		aAdd(aCpo08, Transform(BB8->BB8_CNES, cPicCNES)) // 8
		aAdd(aCpo09, If(cAlias=="SE2",SE2->E2_VENCTO,CTOD(" / / "))) // 9   DATA DO PAGAMENTO
		aAdd(aCpo10, { IF (BAU->BAU_FORPGT =='1',"X",""),;  //Credito em conta
						IF (BAU->BAU_FORPGT =='2',"X",""),;  //Carteira
		               IF (BAU->BAU_FORPGT =='3',"X","")})  // Boleto Bancário   10   FORMA DE PAGAMENTO
		aAdd(aCpo11, IF (BAU->BAU_FORPGT =='1',SA2->A2_BANCO,""))  // 11   BANCO
		aAdd(aCpo12, IF (BAU->BAU_FORPGT =='1',SA2->A2_AGENCIA,"")) // 12   AGENCIA
		aAdd(aCpo13, IF (BAU->BAU_FORPGT =='1',SA2->A2_NUMCON,""))  // 13   NUMERO DA CONTA/CHEQUE

		aAdd(aCpo14,{})
		aAdd(aCpo15,{})
		aAdd(aCpo16,{})
		aAdd(aCpo17,{})
		aAdd(aCpo18,{})
		aAdd(aCpo19,{})
		aAdd(aCpo20,{})
		aAdd(aCpo21,{})
		aAdd(aCpo27,{})

		nGerInf  := 0
		nGerProc := 0
		nGerLib  := 0
		nGerGlo  := 0
		nVrInf   := 0
		nVrProc  := 0
		nVrLib   := 0
		nVrGlo   := 0

		nInd1 := Len(aCpo04)

		TrbBD7->(dbGoTop())
		Do While !TrbBD7->(Eof())

			nVrInf   := 0
			nVrProc  := 0
			nVrLib   := 0
			nVrGlo   := 0

			// BCI - PEGS
			BCI->(dbSetOrder(5)) //BCI_FILIAL + BCI_OPERDA + BCI_CODRDA + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
			BCI->(msSeek(xFilial("BCI")+TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)))

			aAdd(aCpo14[nInd1], If(cAlias=="SE2",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA),SC7->C7_NUM))
			aAdd(aCpo15[nInd1], TrbBD7->(BD7_CODLDP+BD7_CODPEG))
			aAdd(aCpo16[nInd1], BCI->BCI_DATREC)
			aAdd(aCpo17[nInd1], BCI->BCI_CODPEG)

			cChRDA  := TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG)
			Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG) ==  cChRDA

				nVrInf  += TrbBD7->BD7_VLRAPR
				nVrProc += TrbBD7->BD7_VLRPAG + TrbBD7->BD7_VLRGLO
				nVrLib  += TrbBD7->BD7_VLRPAG
				nVrGlo  += TrbBD7->BD7_VLRGLO

				TrbBD7->(dbSkip())
			EndDo

			aAdd(aCpo18[nInd1], nVrInf)
			aAdd(aCpo19[nInd1], nVrProc)
			aAdd(aCpo20[nInd1], nVrLib)
			aAdd(aCpo21[nInd1], nVrGlo)
			nGerInf  += nVrInf
			nGerProc += nVrProc
			nGerLib  += nVrLib
			nGerGlo  += nVrGlo
		EndDo

		aAdd(aCpo22, nGerInf)
		aAdd(aCpo23, nGerProc)
		aAdd(aCpo24, nGerLib)
		aAdd(aCpo25, nGerGlo)
		aAdd(aCpo26,(nGerProc-nGerGlo))
		TrbBD7->(dbCloseArea())
		aAdd(aDados, aCpo04)
		aAdd(aDados, aCpo05)
		aAdd(aDados, aCpo06)
		aAdd(aDados, aCpo07)
		aAdd(aDados, aCpo08)
		aAdd(aDados, aCpo09)
		aAdd(aDados, aCpo10)
		aAdd(aDados, aCpo11)
		aAdd(aDados, aCpo12)
		aAdd(aDados, aCpo13)
		aAdd(aDados, aCpo14)
		aAdd(aDados, aCpo15)
		aAdd(aDados, aCpo16)
		aAdd(aDados, aCpo17)
		aAdd(aDados, aCpo18)
		aAdd(aDados, aCpo19)
		aAdd(aDados, aCpo20)
		aAdd(aDados, aCpo21)
		aAdd(aDados, aCpo22) // 22
		aAdd(aDados, aCpo23) // 23
		aAdd(aDados, aCpo24) // 24
		aAdd(aDados, aCpo25) // 25
		aAdd(aDados, aCpo26) // 26

		nDeb :=0
		nCred:=0
		cChBMR := TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA)
		Do While ! TrbBMR->(Eof()) .And. TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA) == cChBMR

			If TrbBMR->BMR_CODLAN $ "102,103,104,105" // Debitos/Creditos Fixos e Variaveis
				BMS->(dbSetOrder(1))
				BMS->(msSeek(TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)))
				Do While ! BMS->(Eof()) .And. ;
						BMS->(BMS_FILIAL+BMS_OPERDA+BMS_CODRDA+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT+BMS_CODLAN) == ;
						TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)
					aAdd(aCpo27[nInd1], { IIf(BMS->BMS_DEBCRE == "1", "(-) ", "(+) ") + BMS->BMS_CODSER + " - " + Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI"), BMS->BMS_VLRPAG })
					if BMS->BMS_DEBCRE == "1"
						nDeb+=BMS->BMS_VLRPAG
					else
						nCred+=BMS->BMS_VLRPAG
					Endif
					BMS->(dbSkip())
				EndDo
			ElseIf TrbBMR->BMR_CODLAN <> "101" .And. TrbBMR->BMR_DEBCRE <> "3"
				aAdd(aCpo27[nInd1], { IIf(TrbBMR->BMR_DEBCRE == "1", "(-) ", "(+) ") + TrbBMR->BMR_CODLAN + " - " + Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN), "BLR_DESCRI"), TrbBMR->BMR_VLRPAG })
				If TrbBMR->BMR_DEBCRE == "1"
					nDeb+=TrbBMR->BMR_VLRPAG
				else
					nCred+=TrbBMR->BMR_VLRPAG
				Endif
			EndIf

		TrbBMR->(dbSkip())
		EndDo

		aAdd(aDados, aCpo27)
		aAdd(aCpo28, ((nGerProc-nGerGlo)+nCred)-nDeb)
		aAdd(aDados, aCpo28) // 28

	EndDo

	TrbBMR->(DbCloseArea())

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSDPGTB  ³ Autor ³ Luciano Aparecido     ³ Data ³ 05.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Demonstrativo de Pagamento )     ³±±
±±³          ³ TISS 3                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodOpe - Código da Operadora                               ³±±
±±³          ³ cRdaDe  - Código da RDA a ser processada (de)               ³±±
±±³          ³ cRdaAte - Código da RDA a ser processada (Até)              ³±±
±±³          ³ cAno    - Informe o Ano a ser processado                    ³±±
±±³          ³ cMes    - Informe o Mês a ser processado                    ³±±
±±³          ³ cClaPre - Classe RDA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSDPGTB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre,cNFSSDe,cNFSSAte,cNmTitPg,cAliasP,lWeb,cDataPag)

Local aCpo14, aCpo15, aCpo16
Local aCpo17, aCpo18, aCpo19, aCpo20, aCpo21, aCpo22, aCpo23, aCpo24, aCpo25, aCpo26, aCpo27, aCpo28 
Local aDados	:= {}
Local aDadosTot	:= {}
Local aVetTmp	:= {}
Local aDecPad	:= {}
Local cSQL		:= ""
Local nCont		:= 0
local nPercen	:= 0
Local nInd1		:= 0
Local cNmLotPg	:= ""
Local lAdd14	:= .F.
Local lAdd17 	:= .F.
Local nI		:= 1
Local cDePara25	:= ""
Local cDePara26	:= ""
Local cDePara27	:= ""
Local nGerLib	:= 0
Local cCodRdaLoop	:= ""
Local cCodLan	:= ""
Local nDeb		:= 0
Local nCred		:= 0
//Variáveis de Imposto
Local nCIRRF 	:= 0
Local nCISS  	:= 0
Local nCPIS  	:= 0
Local nCINSS 	:= 0
Local nCCOFINS 	:= 0
Local nCCSLL   	:= 0
Local nGerInf  := 0
Local nGerProc := 0
Local nGerGlo := 0
Local dRetCalen := NIL
Local nLiDeCr := 1
Local nTamTit := 1

DEFAULT cNFSSDe 	:= ""
DEFAULT cNFSSAte 	:= ""
DEFAULT cNmTitPg 	:= ""
DEFAULT cAliasP		:= "SE2"
Default cDataPag	:= ""
DBSELECTAREA("SE2")

cSQL := "SELECT DISTINCT BMR_CODRDA, BMR_ANOLOT, BMR_CODLAN, BMR_DEBCRE, BMR_FILIAL, BMR_MESLOT, BMR_NUMLOT, BMR_OPELOT, BMR_OPERDA, BMR_VLRPAG"  


	
	// BAU - Redes de Atendimento
	BAU->(dbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+cRdaDe))
	
	If BAU->BAU_CALIMP ==  '1' 
		// Variaveis para buscar o BMR pelo numero do titulo.
    	If cAliasP == "SE2"
			SE2->(dbSetorder(01)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               
			If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
				//Quando o prestador usa integração com o pedido de compras mas já tem a nota/titulo
				cSQL += " FROM " + RetSqlName("SE2") + " SE2 "

				cSQL += " INNER JOIN " + RetSqlName("SD1")+ " SD1 "
				cSQL += "  ON D1_FILIAL = '" + xFilial("SD1") + "' "
				cSQL += "  AND D1_DOC = E2_NUM "
				cSQL += "  AND D1_FORNECE = E2_FORNECE "
				cSQL += "  AND D1_LOJA 	= E2_LOJA "
				cSQL += "  AND D1_DTDIGIT = SE2.E2_EMIS1 "
				cSQL += "  AND SD1.D_E_L_E_T_ = ' ' "
	
				cSQL += " INNER JOIN " + RetSqlName("SC7") + " SC7  "
				cSQL += "   ON C7_FILIAL = '" + xFilial("SC7") + "' "
				cSQL += "   AND C7_NUM 	  = D1_PEDIDO "
				cSQL += "   AND C7_ITEM   = D1_ITEMPC "
				cSQL += "   AND SC7.D_E_L_E_T_ = ' ' "
	
				cSQL += " INNER JOIN " + RetSqlName("BMR") + " BMR "
				cSQL += "   ON BMR_FILIAL = '" + xFilial("BMR") + "' "
				cSQL += "   AND BMR_OPERDA = C7_PLOPELT "
				cSQL += "   AND BMR_CODRDA = C7_CODRDA "
				cSQL += "   AND BMR_OPELOT = C7_PLOPELT "
				cSQL += "   AND BMR_ANOLOT = SubString(C7_LOTPLS,1,4) "
				cSQL += "   AND BMR_MESLOT = SubString(C7_LOTPLS,5,2) "
				cSQL += "   AND BMR_NUMLOT = SubString(C7_LOTPLS,7,4) "
				cSQL += "   AND BMR.D_E_L_E_T_ = ' ' "
				
				cSQL += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
				cSQL += " AND E2_PREFIXO 	= '"+SubString(cNmTitPg,01,TamSx3("E2_PREFIXO")[1])+"' "
				nTamTit := nTamTit + TamSx3("E2_PREFIXO")[1]
				cSQL += " AND E2_NUM 		= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_NUM")[1])+"' "
				nTamTit := nTamTit + TamSx3("E2_NUM")[1]
				cSQL += " AND E2_PARCELA 	= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_PARCELA")[1])+"' "
				nTamTit := nTamTit + TamSx3("E2_PARCELA")[1]
				cSQL += " AND E2_TIPO 	= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_TIPO")[1])+"' "
				nTamTit := nTamTit + TamSx3("E2_TIPO")[1]
				cSQL += " AND E2_FORNECE = '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_FORNECE")[1])+"' "
				nTamTit := nTamTit + TamSx3("E2_FORNECE")[1]
				cSQL += " AND E2_LOJA 	= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_LOJA")[1]) + " ' "
				cSQL += " AND SE2.D_E_L_E_T_ = ' '	
				
				//Valor dos Impostos para sair nos campos de 25 a 28
				nCIRRF		:= SE2->E2_IRRF
				nCISS		:= SE2->E2_ISS
				nCPIS		:= SE2->E2_PIS
				nCINSS		:= SE2->E2_INSS
				nCCOFINS 	:= SE2->E2_COFINS
				nCCSLL   	:= SE2->E2_CSLL
			EndIf
		Else
			//Quando o prestador utiliza integração com pedido de compras, mas ainda não tem nota/titulo, tem somente o pedido SC7
			SC7->(DbSetOrder(1))
			If SC7->(msSeek(xFilial("SC7")+cNmTitPg)) .or. SC7->(DBSeek(xFilial("SC7")+alltrim(cNmTitPg)))

				cSQL += " FROM " + RetSqlName("SC7") + " SC7 "
	
				cSQL += " INNER JOIN " + RetSqlName("BMR") + " BMR "
				cSQL += "    ON BMR_FILIAL = '"+xFilial("BMR")+"' "
				cSQL += "   AND BMR_OPERDA = C7_PLOPELT "
				cSQL += "   AND BMR_CODRDA = C7_CODRDA "
				cSQL += "   AND BMR_OPELOT = C7_PLOPELT "
				cSQL += "   AND BMR_ANOLOT = SubString(C7_LOTPLS,1,4) "
				cSQL += "   AND BMR_MESLOT = SubString(C7_LOTPLS,5,2) "
				cSQL += "   AND BMR_NUMLOT = SubString(C7_LOTPLS,7,4) "
	
				cSQL += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
				cSQL += "   AND C7_NUM 	= '"+cNmTitPg+"' "
				cSQL += "   AND SC7.D_E_L_E_T_ = ' ' "
				
				//Valor dos Impostos para sair nos campos de 25 a 28
				nCIRRF		:= SC7->C7_VALIR
				nCISS		:= SC7->C7_VALISS
				nCPIS		:= SC7->C7_VALIMP6 //Conforme boletim TEUS65
				nCINSS		:= SC7->C7_VALINS
				nCCOFINS 	:= SC7->C7_VALIMP5 //Conforme boletim TEUS65
				nCCSLL   	:= SC7->C7_VALCSL
		
			EndIf
		EndIf
	Else
		//Quando o prestador está configurado para gerar financeiro
		cSQL += " FROM " + RetSqlName("SE2") + " SE2 "	

		cSQL += " INNER JOIN " + RetSqlName("BMR") + " BMR
		cSQL += "    ON BMR_FILIAL = '" + xFilial("BMR") + "' "
		cSQL += "   AND BMR_OPERDA = E2_PLOPELT "
		cSQL += "   AND BMR_CODRDA = E2_CODRDA "
		cSQL += "   AND BMR_OPELOT = E2_PLOPELT "
		cSQL += "   AND BMR_ANOLOT = SubString(E2_PLLOTE ,1,4) " 
		cSQL += "   AND BMR_MESLOT = SubString(E2_PLLOTE ,5,2) "
		cSQL += "   AND BMR_NUMLOT = SubString(E2_PLLOTE ,7,4) "
		cSQL += "   AND BMR.D_E_L_E_T_ = ' ' "

		cSQL += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cSQL += " AND E2_PREFIXO 	= '"+SubString(cNmTitPg,01,TamSx3("E2_PREFIXO")[1])+"' "
		nTamTit := nTamTit + TamSx3("E2_PREFIXO")[1]
		cSQL += " AND E2_NUM 		= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_NUM")[1])+"' "
		nTamTit := nTamTit + TamSx3("E2_NUM")[1]
		cSQL += " AND E2_PARCELA 	= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_PARCELA")[1])+"' "
		nTamTit := nTamTit + TamSx3("E2_PARCELA")[1]
		cSQL += " AND E2_TIPO 	= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_TIPO")[1])+"' "
		nTamTit := nTamTit + TamSx3("E2_TIPO")[1]
		cSQL += " AND E2_FORNECE = '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_FORNECE")[1])+"' "
		nTamTit := nTamTit + TamSx3("E2_FORNECE")[1]
		cSQL += " AND E2_LOJA 	= '"+SubString(cNmTitPg,nTamTit,TamSx3("E2_LOJA")[1]) + " ' "
		cSQL += " AND SE2.D_E_L_E_T_ = ' '	
		
	EndIf		
	
cSql += " AND BMR.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY BMR_CODRDA, BMR_CODLAN, BMR_OPERDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "

cSQL	:= ChangeQuery(cSQL)
PlsQuery(cSQL,"TrbBMR")

	// BA0 - Operadoras de Saude
BA0->(dbSetOrder(1))
BA0->(msSeek(xFilial("BA0")+TrbBMR->(BMR_OPERDA)))

nGerInf  := 0
nGerProc := 0
nGerLib  := 0
nGerGlo  := 0

While ! TrbBMR->(Eof())
	cCodRdaLoop := TrbBMR->(BMR_CODRDA)
	While ! TrbBMR->(Eof()) .And. cCodRdaLoop == TrbBMR->(BMR_CODRDA)
		nCont+=1
		// BAU - Redes de Atendimento
		BAU->(dbSetOrder(1))
		BAU->(msSeek(xFilial("BAU")+TrbBMR->BMR_CODRDA))
	
		// BAF - Lotes plsde Pagamentos RDA
		BAF->(dbSetOrder(1))
		BAF->(msSeek(xFilial("BAF")+TrbBMR->(BMR_OPERDA+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)))
	
		If Empty(cNmTitPg) .and. Empty(cNmLotPg)
			cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO,E2_VENCTO,E2_FORNECE,E2_LOJA "
			cSQL += "  FROM " + RetSQLName("SE2")
			cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
			cSQL += "    AND E2_PLOPELT = '" + TrbBMR->BMR_OPELOT + "'"
			cSQL += "    AND E2_PLLOTE = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
			cSQL += "    AND E2_CODRDA = '" + TrbBMR->BMR_CODRDA + "'"
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			PlsQuery(cSQL,"TrbSE2")
	
			If ! TrbSE2->(Eof())
				SE2->(dbGoTo(TrbSE2->(E2_RECNO)))
			EndIf
	
			TrbSE2->(DbCloseArea())
		EndIf
	
		// SA2 - Cadastro de Fornecedores
		SA2->(dbSetOrder(1))
		SA2->(msSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
		
		//BB8
		BB8->(dbSetOrder(1))
		BB8->(msSeek(xFilial("BB8")+BAU->BAU_CODIGO+cCodOpe))
		
		nCountLoc := 0
		
		while !BB8->(EoF()) .and. BB8->BB8_CODIGO == BAU->BAU_CODIGO .and. BB8->BB8_CODINT == cCodOpe
			cCodCnes := BB8->BB8_CNES
			nCountLoc++
			BB8->(dbSkip())
		enddo	
		
		//Caso exista mais de um CNES (devido há mais de um local de atendimento) ou esteja vazio no cadastro, preenche com "9999999"
		if nCountLoc <> 1 .or. Empty(cCodCnes)
			cCodCnes := "9999999"
		endif
		
		If nCont == 1
			aAdd(aDados, BA0->BA0_SUSEP) // 1
			aAdd(aDados, BAF->(BAF_ANOLOT+BAF_MESLOT+BAF_NUMLOT)) // 2
			aAdd(aDados, BA0->BA0_NOMINT) // 3
			aAdd(aDados, Transform(BA0->BA0_CGC, "@R 99.999.999/9999-99") ) // 4
			aAdd(aDados, dDataBase) // 5 - Data de emissao do demonstrativo
			aAdd(aDados, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) // 6 - Codigo identificador do prestador contratado executante junto a operadora, conforme contrato estabelecido
			aAdd(aDados, BAU->BAU_NOME) // 7 - Razao Social, nome fantasia ou nome do prestador contratado da operadora que executou o procedimento
			aAdd(aDados, cCodCnes) // 8 - CNES. Orientacao: Caso o prestador ainda nao possua o codigo do CNES ou exista mais de um cnes para o prestador, preencher o campo com 9999999
			//Se for SC7, não tem data de vencimento do título, busco então no calendário de pagamento	
			if cAliasP == "SC7
				//Busca dados do calendário de pagamento
				dRetCalen := PLSCHKNCAL(StrZero(Month(SC7->C7_EMISSAO), 2), AllTrim(Str(Year(SC7->C7_EMISSAO))))
				aAdd(aDados, dRetCalen)
			else
				//Verifica se tem baixa no título
				if Empty(SE2->E2_BAIXA)
					//Caso não tenha baixa, obtém o vencimento real
					aAdd(aDados, SE2->E2_VENCREA) // 9   Data do pagamento ou data prevista para o pagamento
				else
					//Caso tenha baixa, já foi pago, obtemos a data da baixa
					aAdd(aDados, SE2->E2_BAIXA) // 9   Data do pagamento
				endif		
			endif
			aAdd(aDados, BAU->BAU_FORPGT)  // 10   Codigo da forma como sera efetuado o pagamento dos servicos ao prestador, conforme tabela de dominio no 34 - ok Protheus 1,2,3 iguais
			aAdd(aDados, IF (BAU->BAU_FORPGT =='1',SA2->A2_BANCO,""))  // 11   BANCO
			aAdd(aDados, IF (BAU->BAU_FORPGT =='1',SA2->A2_AGENCIA,"")) // 12   AGENCIA
			aAdd(aDados, IF (BAU->BAU_FORPGT =='1',SA2->A2_NUMCON,""))  // 13   NUMERO DA CONTA/CHEQUE		
			aCpo14 := {}
			aCpo15 := {}
			aCpo16 := {}
			aCpo17 := {}
			aCpo18 := {}
			aCpo19 := {}
			aCpo20 := {}
			aCpo21 := {}
			aCpo22 := {}
			aCpo23 := {}
			aCpo24 := {}
			aCpo25 := {}
			aCpo26 := {}
			aCpo27 := {}
			aCpo28 := {}
			aCpo29 := {}
			aCpo30 := {}
			aCpo31 := {}
			aCpo32 := {}
	
		EndIf	
					
		If TrbBMR->BMR_CODLAN == "101"
			cCodLan := TrbBMR->BMR_CODLAN 
			nInd1 := 0
			
			aAdd(aCpo14,{}) //Data que a operadora recebeu o lote de guias de cobranca do prestador.
			aAdd(aCpo15,{}) //Numero atribuido pela operadora ao lote de guias encaminhado pelo prestador.
			aAdd(aCpo16,{}) //Numero atribuido pelo prestador ao enviar um conjunto de guias para a operadora
			aAdd(aCpo17,{})
			aAdd(aCpo18,{})
			aAdd(aCpo19,{})
			aAdd(aCpo20,{})
			While ! TrbBMR->(Eof()) .And. cCodRdaLoop == TrbBMR->(BMR_CODRDA) .And. TrbBMR->BMR_CODLAN == "101"  
				cSQL := "SELECT BD7_CODOPE, BD7_CODRDA, BD7_CODOPE, BD7_CODLDP,BD7_NUMERO, BD7_CODPEG, BD7_ORIMOV,BD7_SEQUEN,BD7_CODPAD, BD7_VLRAPR,BD7_CODPRO, BD7_VLRPAG, BD7_VLRGLO, BD7_PERCEN, BD7_VLRBPR "
				cSQL += "  FROM " + RetSqlName("BD7") + " BD7 "
				cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "'"
				cSQL += "   AND BD7_CODOPE = '" + cCodOpe + "' "	
				cSQL += "   AND BD7_OPELOT = '" + TrbBMR->(BMR_OPELOT) + "'"	
				cSQL += "   AND BD7_NUMLOT = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
				cSQL += "   AND BD7_CODRDA = '" + TrbBMR->(BMR_CODRDA)+ "'"				
				If BD7->(FieldPos("BD7_SEQNFS")) > 0
					If !Empty(cNFSSAte)
						cSQL += "AND ( BD7_SEQNFS >= '"+cNFSSDe+"' AND BD7_SEQNFS <= '"+cNFSSAte+"' ) "
					EndIf
				EndIf
				cSQL += " AND BD7_SITUAC = '1' "
				cSQL += "   AND BD7.D_E_L_E_T_ = ' '"	
				cSQL += " ORDER BY BD7_CODLDP,BD7_CODPEG"
			
				PlsQuery(cSQL,"TrbBD7")
			
				If !TrbBD7->(Eof())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona Contas Medicas                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BD5->(dbSetOrder(1))
					BD5->(MsSeek(xFilial("BD5")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))
									
					BB8->(dbSetOrder(1))
					BB8->(dbSeek(xFilial("BB8")+BD7->(BD7_CODRDA+BD7_CODOPE)+BD5->BD5_CODLOC))
														
										
					nVrInf   := 0
					nVrProc  := 0
					nVrLib   := 0
					nVrGlo   := 0
				
					lAdd14 := .F.
					lAdd17 := .F.
					
					TrbBD7->(dbGoTop())
					While !TrbBD7->(Eof())									
						
						//Zera o valor em cada iteração.
						nVrInf   := 0
						nVrProc  := 0
						nVrLib   := 0
						nVrGlo   := 0
				
						// BCI - PEGS
						BCI->(dbSetOrder(5)) //BCI_FILIAL + BCI_OPERDA + BCI_CODRDA + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
						BCI->(msSeek(xFilial("BCI")+TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)))
						lAdd14 := .T.
										
						cChRDA  := TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG)
						While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG) ==  cChRDA				
							lAdd17 := .T.
														
							//Seekar BD6 para pegar o BD6_VLRAPR do procedimento. Calcula o valor informado de acordo com a BD6_VLRAPR * Qtd apresentada
							BD6->(dbSetOrder(1))
							BD6->(MsSeek(xFilial("BD6")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)))
							
							//Para guias de consulta
							if (TrbBD7->BD7_VLRAPR > 0 .and. (TrbBD7->BD7_PERCEN == 0 .or. TrbBD7->BD7_PERCEN == 100))
								nVrInf  += TrbBD7->BD7_VLRAPR
								nVrProc += TrbBD7->BD7_VLRAPR //Valor processado é o mesmo que o valor informado
							else
								nPercen := PLGETPCEN(BD6->BD6_VLRBPR, TrbBD7->BD7_VLRBPR)
								
								nVrInf  += ( BD6->BD6_VALORI * nPercen ) / 100 
								nVrProc += ( BD6->BD6_VALORI * nPercen ) / 100 //Valor processado é o mesmo que o valor informado
							endif
							 
							nVrLib  += TrbBD7->BD7_VLRPAG
							nVrGlo  += TrbBD7->BD7_VLRGLO
				
							TrbBD7->(dbSkip())
						End
						
						nInd1++
						
						If nInd1 == 1
							aAdd(aCpo14[nInd1], BCI->BCI_DATREC)
							aAdd(aCpo15[nInd1], BCI->BCI_CODPEG)
							aAdd(aCpo16[nInd1], BCI->BCI_LOTGUI) //IIF(Empty(BCI->BCI_PROTOC),TrbBD7->(BD7_CODLDP+BD7_CODPEG),BCI->BCI_PROTOC)) //Numero atribuido pelo prestador ao enviar um conjunto de guias para a operadora						
							aAdd(aCpo17[nInd1], nVrInf)
							aAdd(aCpo18[nInd1], nVrProc)
							aAdd(aCpo19[nInd1], nVrLib)
							aAdd(aCpo20[nInd1], nVrGlo)
						Else
							aAdd(aCpo14,{}) //Data que a operadora recebeu o lote de guias de cobranca do prestador.
							aAdd(aCpo15,{}) //Numero atribuido pela operadora ao lote de guias encaminhado pelo prestador.
							aAdd(aCpo16,{}) //Numero atribuido pelo prestador ao enviar um conjunto de guias para a operadora
							aAdd(aCpo17,{})
							aAdd(aCpo18,{})
							aAdd(aCpo19,{})
							aAdd(aCpo20,{})
							aAdd(aCpo14[nInd1], BCI->BCI_DATREC)
							aAdd(aCpo15[nInd1], BCI->BCI_CODPEG)
							aAdd(aCpo16[nInd1], BCI->BCI_LOTGUI) //IIF(Empty(BCI->BCI_PROTOC),TrbBD7->(BD7_CODLDP+BD7_CODPEG),BCI->BCI_PROTOC)) //Numero atribuido pelo prestador ao enviar um conjunto de guias para a operadora						
							aAdd(aCpo17[nInd1], nVrInf)
							aAdd(aCpo18[nInd1], nVrProc)
							aAdd(aCpo19[nInd1], nVrLib)
							aAdd(aCpo20[nInd1], nVrGlo)
						EndIf
						nGerInf  += nVrInf
						nGerProc += nVrProc
						nGerLib  += nVrLib
						nGerGlo  += nVrGlo
					End
				
					If (!lAdd14)
						aAdd(aCpo14, {""})
						aAdd(aCpo15, {""})
						aAdd(aCpo16, {""})
					ElseIf (!lAdd17)
						aAdd(aCpo17, {""})
						aAdd(aCpo18, {""})
						aAdd(aCpo19, {""})
						aAdd(aCpo20, {""})
					EndIf
					
					TrbBD7->(dbCloseArea())
				EndIf
				TrbBMR->(dbskip()) 
			End
			
			aAdd(aCpo21, nGerInf) //Valor total informado pelo prestador, correspondendo ao somatorio dos valores informados de todos os lotes/protocolos apresentados na data de pagamento
			aAdd(aCpo22, nGerProc) //Valor total utilizado como base pela operadora para o processamento do pagamento a ser efetuado, correspondendo ao somatorio dos valores processados de todos os lotes/protocolos apresentados na data de pagamento
			aAdd(aCpo23, nGerLib) //Valor total previsto para pagamento ao prestador. Corresponde ao somatorio dos valores liberados de todos os lotes/protocolos apresentados na data de pagamento.
			aAdd(aCpo24, nGerGlo) //Valor total glosado pela operadora, correspondendo ao somatorio dos valores glosados de todos os lotes/protocolos apresentados na data de pagamento.						

			IIF(Len(aDados) >= 14,aAdd(aDados[14], aCpo14),aAdd(aDados, aCpo14))
			IIF(Len(aDados) >= 15,aAdd(aDados[15], aCpo15),aAdd(aDados, aCpo15))
			IIF(Len(aDados) >= 16,aAdd(aDados[16], aCpo16),aAdd(aDados, aCpo16))
			IIF(Len(aDados) >= 17,aAdd(aDados[17], aCpo17),aAdd(aDados, aCpo17))
			IIF(Len(aDados) >= 18,aAdd(aDados[18], aCpo18),aAdd(aDados, aCpo18))
			IIF(Len(aDados) >= 19,aAdd(aDados[19], aCpo19),aAdd(aDados, aCpo19))
			IIF(Len(aDados) >= 20,aAdd(aDados[20], aCpo20),aAdd(aDados, aCpo20))
			IIF(Len(aDados) >= 21,aAdd(aDados[21], aCpo21),aAdd(aDados, aCpo21))
			IIF(Len(aDados) >= 22,aAdd(aDados[22], aCpo22),aAdd(aDados, aCpo22))
			IIF(Len(aDados) >= 23,aAdd(aDados[23], aCpo23),aAdd(aDados, aCpo23))
			IIF(Len(aDados) >= 24,aAdd(aDados[24], aCpo24),aAdd(aDados, aCpo24)) 
			
			//Imprimir os valores obtidos dos impostos de forma direta no relatório, através do SE2 ou SC7
			//Isso foi feito pois nem sempre um título gerado estava gravando a BMR correspondente aos tributos abaixos e para
			//garantir que sai no relatório, foram colocados manualmente, conforme tabela de Domínio 27 da TISS
			//Assim no aDecPad temos a Descrição e o Código TISS correto para sair no relatório e antes de inserir no relatório,
			//é feito um Ascan no campo 26, para ter a certeza que este valor já não foi inserido, evitando duplicação.
			nLenDC 	:= Len(aCpo25)	
			
			if nLenDC == 0
				aadd(aCpo25, {""})
				aadd(aCpo26, {""})
				aadd(aCpo27, {""})
				aadd(aCpo28, {""})
				
				nLenDC := 1
			endif
			
			nLiDeCr := 1
			aVetTmp := {nCIRRF,nCISS,nCPIS,nCINSS,nCCOFINS,nCCSLL}
			
			For nI := 1 to len(aVetTmp)
				If aVetTmp[nI] > 0
					aDecPad := {}			
					//Percorre o campo de descrição para não		
					Do Case //r7
						Case nI == 1 //IRRF
							If ( aScan(aCpo26,{|x| x[1]=="01"}) <= 0  )
								aDecPad   := {"Imposto de renda retido na fonte (IRRF)", "01"}	
							EndIf						
						Case nI == 2 //ISS
							If ( aScan(aCpo26,{|x| x[1]=="02"}) <= 0  )
								aDecPad   := {"Imposto sobre serviços (ISS)", "02"}
							EndIf							
						Case nI == 3 //PIS
							If ( aScan(aCpo26,{|x| x[1]=="04"}) <= 0  )
								aDecPad   := {"Programa de integração social (PIS)", "04"}	
							EndIf					
						Case nI == 4 //INSS
							If ( aScan(aCpo26,{|x| x[1]=="03"}) <= 0  )
								aDecPad   := {"Instituto nacional de seguridade social (INSS)", "03"}			
							EndIf					
						Case nI == 5 //COFINS						
							If ( aScan(aCpo26,{|x| x[1]=="05"}) <= 0  )		
								aDecPad	:= {"Contribuição sobre o financiamento da seguridade social","05"}		
							EndIf				
						Case nI == 6 //CSLL
							If ( aScan(aCpo26,{|x| x[1]=="06"}) <= 0  )
								aDecPad	:= {"Contribuição sobre o lucro liquido (CSLL)","06"}	
							EndIf					
					Endcase
					
					If ((nLiDeCr <= 5) .AND. (Len(aDecPad) > 0))
						
						aCpo25[nLiDeCr][1] :=  Iif( !Empty( cDePara25 ), cDePara25 ,"1" ) // //Indicador de debito ou credito conforme tabela de dominio no 37
						aCpo26[nLiDeCr][1] :=  Iif( !Empty( cDePara26 ), cDePara26 ,aDecPad[2] ) //Codigo do debito ou credito, conforme tabela de dominio no 27
						aCpo27[nLiDeCr][1] :=  Iif( !Empty( cDePara27 ), cDePara27, aDecPad[1] ) //Descricao de valores debitados ou creditados por data de pagamento
						aCpo28[nLiDeCr][1] :=  aVetTmp[nI] //Valor
						
						//Incrementar apenas se houve inclusão, evitando espaço vazio, bem como a somatória dos débitos aqui gerados.
						nLiDeCr++
						nDeb += aVetTmp[nI]
						
						aAdd(aCpo25, {""})
						aAdd(aCpo26, {""})
						aAdd(aCpo27, {""})
						aAdd(aCpo28, {""})						
					EndIf	
				EndIf
			Next
			
			IIF(Len(aDados) >= 25,aAdd(aDados[25], aCpo25),aAdd(aDados, aCpo25))
			IIF(Len(aDados) >= 26,aAdd(aDados[26], aCpo26),aAdd(aDados, aCpo26))
			IIF(Len(aDados) >= 27,aAdd(aDados[27], aCpo27),aAdd(aDados, aCpo27))
			IIF(Len(aDados) >= 28,aAdd(aDados[28], aCpo28),aAdd(aDados, aCpo28))
			
		ElseIf TrbBMR->BMR_CODLAN $ "102,103,104,105"
		
			/*nInd1 := 1
			If nInd1 > 0
				For nI := Len(aCpo25[nInd1]) To 5
					aAdd(aCpo25[nInd1], "")
					aAdd(aCpo26[nInd1], "")
					aAdd(aCpo27[nInd1], "")
					aAdd(aCpo28[nInd1], "")
				Next
			EndIf*/
			nDeb :=0
			nCred:=0
			nLiDeCr := 1
			nLenDC := Len(aCpo25)
			cChBMR := TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA)
			//While ! TrbBMR->(Eof()) .And. TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA) == cChBMR
		
			//If TrbBMR->BMR_CODLAN $ "102,103,104,105" // Debitos/Creditos Fixos e Variaveis
			BMS->(dbSetOrder(1)) //BMS_FILIAL+BMS_OPERDA+BMS_CODRDA+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT+BMS_CODLAN+BMS_CODPLA+BMS_CC
			BMS->(msSeek(TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)))
			While ! BMS->(Eof()) .And. ;
					BMS->(BMS_FILIAL+BMS_OPERDA+BMS_CODRDA+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT+BMS_CODLAN) == ;
					TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)
					
				cDePara25 := PLSIMPVINC('BLR', '37', BMS->BMS_DEBCRE)
				cDePara26 := PLSIMPVINC('BLR', '27', BMS->BMS_CODSER)
				cDePara27 := PLSIMPVINC('BLR', '27', BMS->BMS_CODSER,.T.)

				If nLiDeCr <= 5 .AND. nLenDC > 0
					If LEN(aCpo25[nLenDC]) < nLiDeCr
						AADD(aCpo25[nLenDC],"")
					EndIf
					If LEN(aCpo26[nLenDC]) < nLiDeCr
						AADD(aCpo26[nLenDC],"")
					EndIf
					If LEN(aCpo27[nLenDC]) < nLiDeCr
						AADD(aCpo27[nLenDC],"")
					EndIf
					If LEN(aCpo28[nLenDC]) < nLiDeCr
						AADD(aCpo28[nLenDC],"")
					EndIf
					aCpo25[nLenDC][nLiDeCr] := Iif(!Empty( cDePara25 ),cDePara25,BMS->BMS_DEBCRE) //Indicador de debito ou credito conforme tabela de dominio no 37 (PROTHEUS COINCIDE)
					aCpo26[nLenDC][nLiDeCr] := Iif(!Empty( cDePara26 ),cDePara26,BMS->BMS_CODSER) //Codigo do debito ou credito, conforme tabela de dominio no 27
					aCpo27[nLenDC][nLiDeCr] := Iif(!Empty( cDePara27 ),cDePara27,Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI") )  //Descricao de valores debitados ou creditados por data de pagamento
					aCpo28[nLenDC][nLiDeCr] := BMS->BMS_VLRPAG
				EndIf
				nLiDeCr++
				aAdd(aCpo25, {""})
				aAdd(aCpo26, {""})
				aAdd(aCpo27, {""})
				aAdd(aCpo28, {""})
				if BMS->BMS_DEBCRE == "1"
					nDeb += BMS->BMS_VLRPAG
				else
					nCred += BMS->BMS_VLRPAG
				Endif
				BMS->(dbSkip())
			End
			
			IIF(Len(aDados) >= 25,aAdd(aDados[25], aCpo25),aAdd(aDados, aCpo25))
			IIF(Len(aDados) >= 26,aAdd(aDados[26], aCpo26),aAdd(aDados, aCpo26))
			IIF(Len(aDados) >= 27,aAdd(aDados[27], aCpo27),aAdd(aDados, aCpo27))
			IIF(Len(aDados) >= 28,aAdd(aDados[28], aCpo28),aAdd(aDados, aCpo28))
			
		ElseIf TrbBMR->BMR_CODLAN <> "101" .And. TrbBMR->BMR_DEBCRE <> "3"
		
			/*nInd1 := 1
			If nInd1 > 0
				For nI := Len(aCpo25[nInd1]) To 5
					aAdd(aCpo25[nInd1], "")
					aAdd(aCpo26[nInd1], "")
					aAdd(aCpo27[nInd1], "")
					aAdd(aCpo28[nInd1], "")
				Next
			EndIf*/
			nDeb :=0
			nCred:=0
			nLiDeCr := 1
				
			cDePara25 := PLSIMPVINC('BLR', '37', TrbBMR->BMR_DEBCRE)
			cDePara26 := PLSIMPVINC('BLR', '27', TrbBMR->BMR_CODLAN)
			cDePara27 := PLSIMPVINC('BLR', '27', TrbBMR->BMR_CODLAN,.T.)
			
			If nLiDeCr <= 5
				If LEN(aCpo25[nLenDC]) < nLiDeCr
					AADD(aCpo25[nLenDC],"")
				EndIf
				If LEN(aCpo26[nLenDC]) < nLiDeCr
					AADD(aCpo26[nLenDC],"")
				EndIf
				If LEN(aCpo27[nLenDC]) < nLiDeCr
					AADD(aCpo27[nLenDC],"")
				EndIf
				If LEN(aCpo28[nLenDC]) < nLiDeCr
					AADD(aCpo28[nLenDC],"")
				EndIf
				aCpo25[nLenDC][nLiDeCr] :=  Iif(!Empty( cDePara25 ), cDePara25 ,TrbBMR->BMR_DEBCRE) // //Indicador de debito ou credito conforme tabela de dominio no 37
				aCpo26[nLenDC][nLiDeCr] :=  Iif(!Empty( cDePara26 ), cDePara26 ,TrbBMR->BMR_CODLAN ) //Codigo do debito ou credito, conforme tabela de dominio no 27
				aCpo27[nLenDC][nLiDeCr] :=  Iif(!Empty( cDePara27 ) ,cDePara27, Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN), "BLR_DESCRI")  ) //Descricao de valores debitados ou creditados por data de pagamento
				aCpo28[nLenDC][nLiDeCr] :=  TrbBMR->BMR_VLRPAG
			Endif
			
			nLiDeCr++

			If TrbBMR->BMR_DEBCRE == "1"
				nDeb+=TrbBMR->BMR_VLRPAG
			Else
				nCred+=TrbBMR->BMR_VLRPAG
			EndIf
			
			IIF(Len(aDados) >= 25,aAdd(aDados[25], aclone(aCpo25[1])),aAdd(aDados, aclone(aCpo25)))
			IIF(Len(aDados) >= 26,aAdd(aDados[26], aclone(aCpo26[1])),aAdd(aDados, aclone(aCpo26)))
			IIF(Len(aDados) >= 27,aAdd(aDados[27], aclone(aCpo27[1])),aAdd(aDados, aclone(aCpo27)))
			IIF(Len(aDados) >= 28,aAdd(aDados[28], aclone(aCpo28[1])),aAdd(aDados, aclone(aCpo28)))
			
			aAdd(aCpo25, {""})
			aAdd(aCpo26, {""})
			aAdd(aCpo27, {""})
			aAdd(aCpo28, {""})
			
		EndIf
		
		TrbBMR->(dbSkip())			
    End
    		
	aAdd(aCpo29, nDeb)  //Total de debitos
	aAdd(aCpo30, nCred) //Total de creditos
	aAdd(aCpo31, ((nGerLib-nDeb)+nCred)) // Total geral

	aAdd(aDados, aCpo29)
	aAdd(aDados, aCpo30)
	aAdd(aDados, aCpo31)

	DbSelectArea("BH1")
	DbSelectArea("BH2")
	BH1->(dbSetOrder(1))
	BH2->(dbSetOrder(1))

	/*
	If BH1->(MsSeek(xFilial("BH1")))
		While ! BH1->(Eof())
			If (Empty(Alltrim(cRdaDe)) .or. BH1->BH1_RDADE >= TrbBMR->BMR_CODRDA) .and. ;
				(Empty(Alltrim(cRdaAte)) .or. BH1->BH1_RDAATE <= TrbBMR->BMR_CODRDA) //.and. ;
					
				If BH2->(MsSeek(xFilial("BH2")+BH1->BH1_CODIGO))
					While ! BH2->(Eof()) .And. (BH1->BH1_CODIGO == BH2->BH2_CODIGO)
						aAdd(aCpo32, BH2->BH2_MSG01)
						BH2->(dbSkip())
					End
				EndIf
			Else
				aAdd(aCpo32, "")
			EndIf
			BH1->(dbSkip())
		End
	EndIf
	*/
	
	//TODO: Alterar a mensagem e incluir novo tipo 'Demonstrativo prest.'
	aAdd(aCpo32, "")
	
	aAdd(aDados, aCpo32)
    
    aAdd(aDadosTot,aDados)
    aDados := {}
    nCont := 0
End

TrbBMR->(DbCloseArea())

Return aDadosTot
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSGODCO  ³ Autor ³ Luciano Aparecido     ³ Data ³ 07.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Odontológica - Cobrança )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSGODCO()

	Local lImpNAut	:= IIf(GetNewPar("MV_PLNAUT",0) == 0, .F., .T.) // 0 = Nao imprime procedimento nao autorizado 1 = Sim imprime
    Local lBE2Aut
	Local aDados    := {}
	Local aCpo30, aCpo31, aCpo32, aCpo33, aCpo34, aCpo35, aCpo36, aCpo37, aCpo38, aCpo39, aCpo40, aCpo41, aCpo42
	Local nQtdUS
	Local nVrTot
	Local nVrTotFr
	Local cChave
	Local nProx   := 0 
   	Local aArea     := {}
	Local lVlTiss := GetNewPar("MV_VLTISS","1") == "1"
	Local cTissVer:= "2.02.03"
	Local cCodPro := ""
	Local cDescri := ""
	Local cTermFac:= ""
	Local cTermDen:= ""
	Local nControl:= 0
	Local nValCont:= 0
	Local lAchou  :=.F.
	Local lBD6    :=.F.
	Local dDatFim :=""
	Local cCodProc:=""
	Local cProCAud:=""
	Local cRecMov :=""
	Local cSQL    := ""

	cTissVer	:= PLSTISSVER()

	lSemDados := BD5->(eof()) //Verifica se tem Dados na tabela BD5, senão puxa os dados através da tabela BEA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Operadora                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA0->(dbSetOrder(1))
	if !lSemDados
		BA0->(dbSeek(xFilial("BA0")+BD5->(BD5_OPEUSR)))
	else
		BA0->(dbSeek(xFilial("BA0")+BEA->(BEA_OPEUSR)))
	endIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Usuario                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA1->(dbSetOrder(2))
	if !lSemDados
		BA1->(dbSeek(xFilial("BA1")+BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG)))
	else
		BA1->(dbSeek(xFilial("BA1")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)))
	endIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Sub-Contrato                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BQC->(dbSetOrder(1))
	BQC->(dbSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Vidas                                  			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BTS->(dbSetOrder(1))
	BTS->(dbSeek(xFilial("BTS")+BA1->BA1_MATVID))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Familias/Usuarios                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA3->(dbSetorder(01))
	BA3->(dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Produtos de Saude - Plano                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BI3->(dbSetOrder(1))
	If !Empty(BA1->BA1_CODPLA)
		BI3->(dbSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
	Else
		BI3->(dbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Rede de Atendimento                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAU->(dbSetOrder(1))
	if !lSemDados
		BAU->(dbSeek(xFilial("BAU")+BD5->BD5_CODRDA))
	else
		BAU->(dbSeek(xFilial("BAU")+BEA->BEA_CODRDA))
	endIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Especialidade                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAQ->(dbSetOrder(1))
	if !lSemDados
		BAQ->(MsSeek(xFilial("BAQ")+BD5->(BD5_CODOPE+BD5_CODESP)))
	else
		BAQ->(MsSeek(xFilial("BAQ")+BEA->(BEA_OPEMOV+BEA_CODESP)))
	endIf
  /*
	BEA->(dbGoTop())
	Do While ! BEA->(Eof())

 */

 	If !BEA->(Found())
 		dbSelectArea("BEA")
 	Endif
	
	    //BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
		if !lSemDados //seeka na bea para copiar as informações, se tiver uma row para essa guia na tabela BD5
	 		BEA->(dbSetOrder(12))
			BEA->(MsSeek(xFilial("BEA")+BD5->(BD5_CODOPE+BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_ORIMOV))) 
			BE2->(dbSetOrder(1))
			If BE2->(MsSeek(xFilial("BE2")+BD5->(BD5_CODOPE+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)))
				cCodProc:= BE2->BE2_CODPRO
			EndIf
		else
			//Ja esta posicionado na BEA, vou posicionar na BE2
			BE2->(dbSetOrder(1))
			If BE2->(MsSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
				cCodProc:= BE2->BE2_CODPRO
			EndIf
		endif

	    //Cabeçalho, só passa quando está em Autorização Odonto
		B53->(dbSetOrder(1))
		If !lSemDados //se não tiver dados na tabela BD5 vai puxa da tabela BEA
			If B53->(MsSeek(xFilial("B53")+BD5->BD5_NRLBOR))
				lAchou:= .T.
				dDatFim := B53->B53_DATFIM
				cRecMov	:= B53->B53_RECMOV
				cSQL := ""
				If 'MSSQL' $ AllTrim(TcGetDB())
					cSQL := "SELECT TOP 1 B72_DATMOV, B72_RECMOV, B72_CODPRO "
				Else
					cSQL := "SELECT B72_DATMOV, B72_RECMOV, B72_CODPRO "
				EndIf
				cSQL += " FROM " + RetSqlName("B72")
				cSQL += " WHERE B72_RECMOV = '" + cRecMov + "'"
				cSQL += " AND B72_PARECE = '0' "
				cSQL += " ORDER BY B72_DATMOV"
				If 'DB2' $ AllTrim(TcGetDB())
					cSQL += " FETCH FIRST 1 ROW ONLY"
				EndIf	
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbB72",.F.,.T.)
				cProCAud :=TrbB72->(B72_CODPRO)
				TrbB72->(DbCloseArea())
			EndIf
		Else
			If B53->(MsSeek(xFilial("B53")+BEA->BEA_NRLBOR))
				lAchou:= .T.
				dDatFim := B53->B53_DATFIM
				cRecMov	:= B53->B53_RECMOV
				cSQL := ""
				If 'MSSQL' $ AllTrim(TcGetDB())
					cSQL := "SELECT TOP 1 B72_DATMOV, B72_RECMOV, B72_CODPRO "
				Else
					cSQL := "SELECT B72_DATMOV, B72_RECMOV, B72_CODPRO "
				EndIf
				cSQL += " FROM " + RetSqlName("B72")
				cSQL += " WHERE B72_RECMOV = '" + cRecMov + "'"
				cSQL += " AND B72_PARECE = '0' "
				cSQL += " ORDER BY B72_DATMOV"
				If 'DB2' $ AllTrim(TcGetDB())
					cSQL += " FETCH FIRST 1 ROW ONLY"
				EndIf	
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbB72",.F.,.T.)
				cProCAud :=TrbB72->(B72_CODPRO)
				TrbB72->(DbCloseArea())
			EndIf
		endIf

		aAdd(aDados, BA0->BA0_SUSEP) // 1
		if !lSemDados
			aAdd(aDados, BD5->(BD5_CODOPE+"."+BD5_ANOAUT+"."+BD5_MESAUT+"-"+BD5_NUMAUT)) // 2
			aAdd(aDados, BD5->BD5_NUMERO) // 3
		else
			aAdd(aDados, BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"-"+BEA_NUMAUT)) // 2
			aAdd(aDados, BEA->BEA_NUMGUI) // 3
		endIf

    	If lAchou .and. cCodProc == cProCAud	
			aAdd(aDados, dDatFim)//4
		Else
			if !lSemDados
				aAdd(aDados, IIF(Empty(BD5->BD5_NRLBOR), BD5->BD5_DATPRO, BD5->BD5_DATSOL)) //4
			else
				aAdd(aDados, IIF(Empty(BEA->BEA_NRLBOR), BEA->BEA_DATPRO, BEA->BEA_DATSOL)) //4
			endIf
		EndIf

		if !lSemDados	
			aAdd(aDados, BD5->BD5_SENHA) // 5
			aAdd(aDados, IIf(Empty(BD5->BD5_SENHA), StoD(""), BD5->BD5_VALSEN)) // 6
		else
			aAdd(aDados, BEA->BEA_SENHA) // 5
			aAdd(aDados, IIf(Empty(BEA->BEA_SENHA), StoD(""), BEA->BEA_VALSEN)) // 6
		endIf	
		aAdd(aDados, "") // 7

		// Dados do Beneficiario
		If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT) // 8
			aAdd(aDados, BEA->(SubStr(BEA_OPEMOV,1,1)+SubStr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO)	)
		Else
			aAdd(aDados, BA1->BA1_MATANT)
		EndIf
		aAdd(aDados, BI3->BI3_NREDUZ) // 9
		aAdd(aDados, BQC->BQC_DESCRI) //10
		aAdd(aDados, BA1->BA1_DTVLCR) // 11
		aAdd(aDados, BTS->BTS_NRCRNA) // 12
		aAdd(aDados, BEA->BEA_NOMUSR) // 13
		aAdd(aDados, BA1->(+"( "+BA1_DDD+" ) "+BA1_TELEFO)) //14
		aAdd(aDados, BEA->BEA_NOMTIT) //15
		If ! Empty(BE4->BE4_ATENRN)
			If BE4->BE4_ATENRN == "1"
				aAdd(aDados, "S" ) //16
			Else
				aAdd(aDados, "N" ) //16
			EndIf
		Else
			aAdd(aDados, "" ) //16
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no solicitante                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aArea := GetArea()
            DbSelectArea("BB0")
            DbSetOrder(4)//BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE
            BB0->(DbSeek(xFilial("BB0")+BEA->(BEA_ESTSOL+BEA_REGSOL+BEA_SIGLA)))
		    aAdd(aDados, BB0->BB0_NOME   ) // 17
		    aAdd(aDados, BB0->BB0_NUMCR  ) // 18
		    aAdd(aDados, BB0->BB0_ESTADO ) // 19
		    aAdd(aDados, BAQ->BAQ_CBOS   ) // 20
		RestArea(aArea)

		// Dados do Contratado Executante
		lTemPFExe := .F. // Tem Profissional Executante informado na Guia
		lExecPF   := .F. // O executante (RDA) eh pessoa fisica
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Rede de Atendimento                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BAU->(dbSetOrder(1))
		BAU->(MsSeek(xFilial("BAU")+BEA->BEA_CODRDA))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Profissional de Saude                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Empty(BEA->BEA_REGEXE)
			BB0->(dbSetOrder(4) )
			lTemPFExe := BB0->(dbSeek(xFilial("BB0")+BEA->(BEA_ESTEXE+BEA_REGEXE+BEA_SIGEXE)))
		Else
			If BAU->BAU_TIPPE == "F"
				BB0->(dbSetOrder(1))
				lExecPF := BB0->(dbSeek(xFilial("BB0")+BAU->BAU_CODBB0))
			EndIf
		EndIf
		aAdd(aDados, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) // 21
		aAdd(aDados, BAU->BAU_NOME)  // 22
		aAdd(aDados, BAU->BAU_CONREG)// 23
		BB8->(dbSetOrder(1))
		BB8->(dbSeek(xFilial("BB8")+BAU->BAU_CODIGO+BEA->(BEA_OPEMOV+BEA_CODLOC)))
		aAdd(aDados, BB8->BB8_EST)   // 24
		aAdd(aDados, Transform(BB8->BB8_CNES, cPicCNES)) // 25

		If lTemPFExe .Or. lExecPF
			aAdd(aDados, IIf(lTemPFExe .Or. lExecPF, BB0->BB0_NOME, "")) // 26
			aAdd(aDados, IIf(lTemPFExe .Or. lExecPF, BB0->BB0_NUMCR, "")) // 27
			aAdd(aDados, IIf(lTemPFExe .Or. lExecPF, BB0->BB0_ESTADO, "")) // 28
			aAdd(aDados, IIf(lTemPFExe .Or. lExecPF, BAQ->BAQ_CBOS, ""))//29
		Else
			aAdd(aDados, "") // 26
			aAdd(aDados, "") // 27
			aAdd(aDados, "") // 28
			aAdd(aDados, "") // 29
		EndIf

		aCpo30 := {}
		aCpo31 := {}
		aCpo32 := {}
		aCpo33 := {}
		aCpo34 := {}
		aCpo35 := {}
		aCpo36 := {}
		aCpo37 := {}
		aCpo38 := {}
		aCpo39 := {}
		aCpo40 := {}
		aCpo41 := {}
		aCpo42 := {}

		nQtdUS   :=0
		nVrTot   :=0
		nVrTotFr :=0

		BE2->(dbSetOrder(1))
		cChave	:= xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
		If BE2->(dbSeek(cChave))
			Do While !BE2->(Eof()) .And. cChave == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Nao imprime procedimento negado	conforme parametro			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If !lImpNAut .And. BE2->BE2_STATUS == "0"   //1-Autorizado
					BE2->(dbSkip())
					Loop
				EndIf

				lBE2Aut := BE2->BE2_QTDPRO > 0

				BR8->(dbSetOrder(1))
				BR8->(dbSeek(xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO)))

				BD6->(dbSetOrder(1)) // BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
				lBD6 := BD6->(dbSeek(xFilial("BD6")+BE2->BE2_OPEMOV+BEA->BEA_CODLDP+ BEA->BEA_CODPEG +BE2->BE2_NUMERO+BEA->BEA_ORIMOV+BE2->BE2_SEQUEN+BE2->BE2_CODPAD+BE2->BE2_CODPRO))
					If lBE2Aut .And. BR8->BR8_ODONTO == "1" // PROCEDIMENTO ODONTO

							cCodTab := PLSIMPVINC("BR4","87"	,	BE2->BE2_CODPAD					,.F.)
							cCodPro := PLSIMPVINC("BR8",cCodTab	,	BE2->BE2_CODPAD+BE2->BE2_CODPRO	,.F.)
							cDescri := PLSIMPVINC("BR8",cCodTab	,	BE2->BE2_CODPAD+BE2->BE2_CODPRO	,.T.)

							If Empty(cCodTab) .Or. Empty(cCodPro) .Or. Empty(cDescri)
								cCodTab := BE2->BE2_CODPAD
								cCodPro := BE2->BE2_CODPRO
								cDescri := Posicione("BR8",1, xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO), "BR8_DESCRI")
							Endif

							aAdd(aCpo30, cCodTab) //30-Tabela
							aAdd(aCpo31, cCodPro) //31-Codigo do Prodecimento/Item assistencial
							aAdd(aCpo32, cDescri) //32-Descricao

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona Dente/Região                             			 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							BYT->(dbSetOrder(1))
							BYT->(dbSeek(xFilial("BYT")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SEQUEN)))
							If lBD6 .and. !Empty(BYT->BYT_CODIGO)
								cTermDen := PLSIMPVINC('B04', '28', BYT->BYT_CODIGO)
								If Empty(cTermDen)
									cTermDen := BYT->BYT_CODIGO
								Endif
							Else
								cTermDen := PLSIMPVINC('B04', '42', BE2->BE2_DENREG)
								If Empty(cTermDen)
									cTermDen := BE2->BE2_DENREG
								Endif
							Endif

							aAdd(aCpo33, cTermDen)// 33 - Dente/Região

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona Face		                             			 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							BYS->(dbSetOrder(1))
							BYS->(dbSeek(xFilial("BYS")+BYT->BYT_CODOPE+BE2->(BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)+BYT->(BYT_SEQUEN+BYT_CODIGO)))
							If !Empty(BYS->BYS_FACES)
								cTermFac:= PLSIMPVINC('B04', '32', BYS->BYS_FACES)
								If Empty(cTermFac)
									cTermFac := BYS->BYS_FACES
								Endif
							Else
								cTermFac:= PLSIMPVINC('B09', '32', BE2->BE2_FADENT)
								If Empty(cTermFac)
									cTermFac := BE2->BE2_FADENT
								Endif
							Endif

							aAdd(aCpo34, cTermFac)// 34 - Face
							aAdd(aCpo35, iif(lBD6,BD6->BD6_QTDPRO,BE2->BE2_QTDPRO))// 35

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona Part Hon Med. Itens		               			 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						   //	BD7->(dbSetOrder(4))
							//BD7->(dbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_ANOPAG+BD6_MESPAG+BD6_SITUAC+BD6_FASE+BD6_CODRDA)))
							//BD7->(dbSetOrder(2))
							//BD7->(dbSeek(xFilial("BD7")+BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_CODPAD + BD6_CODPRO ) ))
							//aAdd(aCpo31, BD7->BD7_REFTDE)//31
							//nQtdUS+=BD7->BD7_REFTDE
							nControl :=0
							nRefPro := 0
							if lBD6
								BD7->(dbSetOrder(1))
								BD7->(dbSeek(xFilial("BD7")+BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN ) ))
								While !BD7->(eof()) .and. xFilial("BD7")+BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN) ==;
								             				BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN)
									nRefPro += BD7->BD7_REFTDE
									If nControl = 0
										nValCont:= BD7->BD7_COEFUT  
										nControl ++ 
									Else
										nControl ++ 
									EndIf	
									BD7->(dbSkip())
								Enddo
							endif
							aAdd(aCpo36,IIF(nControl > 1, nRefPro,nValCont))//36
							
							//------------------------------------
							// Adicionando a quantidade de US
							nProx := Len(aCpo36)
							nQtdUS += aCpo36[nProx]						 

							If lVlTiss .and. lBD6
								aAdd(aCpo37, IIF(BD6->BD6_VLRAPR>0,BD6->BD6_VLRAPR,BD6->BD6_VLRPAG)) // 37
							Else
								aAdd(aCpo37, 0) // 36
							EndIf

							if lBD6
								If(BD6->BD6_VLRAPR > 0)
								       nVrTot+= BD6->BD6_VLRAPR * BD6->BD6_QTDPRO
								else
								       nVrTot+= BD6->BD6_VLRPAG 
								EndIf
							endif
							aAdd(aCpo38, iif(lBD6,BD6->BD6_VLRTPF,0)) // 38
							if lBD6
								nVrTotFr +=BD6->BD6_VLRTPF
							endif
							aAdd(aCpo39, IIf(BE2->BE2_STATUS =="1" ,"S","N")) // 39

							BEG->(dbSetOrder(1))
							BEG->(DbSeek(xFilial("BEG")+BE2->BE2_OPEMOV+BE2->BE2_ANOAUT+BE2->BE2_MESAUT+BE2->BE2_NUMAUT+BE2->BE2_SEQUEN))
							aAdd(aCpo40, PLSIMPVINC('BCT', '38', BEG->BEG_CODGLO)) // 40

							aAdd(aCpo41, iif(lBD6,BD6->BD6_DATPRO,BE2->BE2_DATPRO)) // 41
							aAdd(aCpo42, "") //42

					Else
						aAdd(aCpo30, "") // 30
						aAdd(aCpo31, "") // 31
						aAdd(aCpo32, "") // 32
						aAdd(aCpo33, "") // 33
						aAdd(aCpo34, "") // 34
						aAdd(aCpo35, "") // 35
						aAdd(aCpo36, 0) // 36
						aAdd(aCpo37, 0) // 37
						aAdd(aCpo38, 0) // 38
						aAdd(aCpo39, "") // 39
						aAdd(aCpo40, "") // 40
						aAdd(aCpo41, CToD("")) // 41
						aAdd(aCpo42, "") // 42

					EndIf
				BE2->(dbSkip())
			Enddo
		Endif
		aAdd(aDados,aCpo30)
		aAdd(aDados,aCpo31)
		aAdd(aDados,aCpo32)
		aAdd(aDados,aCpo33)
		aAdd(aDados,aCpo34)
		aAdd(aDados,aCpo35)
		aAdd(aDados,aCpo36)
		aAdd(aDados,aCpo37)
		aAdd(aDados,aCpo38)
		aAdd(aDados,aCpo39)
		aAdd(aDados,aCpo40)
		aAdd(aDados,aCpo41)
		aAdd(aDados,aCpo42)
		// Rodape
		aAdd(aDados,BEA->BEA_DPTETA)// 43
		aAdd(aDados, BEA->BEA_TIPATO) // 44
		aAdd(aDados,BEA->BEA_TIPFAT) // 45
		aAdd(aDados,nQtdUS)//46
		If lVlTiss
			aAdd(aDados,nVrTot)//47
		Else
			aAdd(aDados,0)//47
		EndIf
		aAdd(aDados,nVrTotFr)//48
		aAdd(aDados, AllTrim(BEA->BEA_MSG01) + " " + AllTrim(BEA->BEA_MSG02)+ " " + AllTrim(BEA->BEA_MSG03)) // 48
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Local Atendimento 		               			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BB8->(dbSetOrder(1))
		BB8->(dbSeek(xFilial("BB8")+BD6->(BD6_CODRDA+BD6_CODLOC+BD6_LOCAL)))

		aAdd(aDados, dDataBase)	  	// 50
		aAdd(aDados,BB8->BB8_MUN) 	// 51
		aAdd(aDados, dDataBase) 		// 52
		aAdd(aDados,BB8->BB8_MUN)	// 53
		aAdd(aDados, dDataBase) 		// 54
		aAdd(aDados,BB8->BB8_MUN) 	// 55
		aAdd(aDados, dDataBase)  	// 56
		aAdd(aDados,BB8->BB8_MUN) 	// 57
		iif( (BA1->(FieldPos("BA1_NOMSOC")) > 0), aAdd(aDados, BA1->BA1_NOMSOC), '') //57 na guia (58 no array) Adiciona Nome Social

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSGODSO  ³ Autor ³ Luciano Aparecido     ³ Data ³ 12.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Odontológica - Solicitação )     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSGODSO(nGuia)

	Local aDados    := {}
	Local cVerTISS  := PLSTISSVER()
	
	If cVerTISS >= "3" .AND. FindFunction("PLSSOLINI")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Operadora                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial("BA0")+BEA->(BEA_OPEUSR)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Usuario                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA1->(dbSetOrder(2))
		BA1->(dbSeek(xFilial("BA1")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Sub-Contrato                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BQC->(dbSetOrder(1))
		BQC->(dbSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Vidas                                  			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BTS->(dbSetOrder(1))
		BTS->(dbSeek(xFilial("BTS")+BA1->BA1_MATVID))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Familias/Usuarios                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA3->(dbSetorder(01))
		BA3->(dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Produtos de Saude - Plano                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BI3->(dbSetOrder(1))
		If !Empty(BA1->BA1_CODPLA)
			BI3->(dbSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
		Else
			BI3->(dbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Rede de Atendimento                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BAU->(dbSetOrder(1))
		BAU->(dbSeek(xFilial("BAU")+BEA->BEA_CODRDA))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Especialidade                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BAQ->(dbSetOrder(1))
		BAQ->(MsSeek(xFilial("BAQ")+BEA->(BEA_OPEMOV+BEA_CODESP)))
	
	
 	    //Cabeçalho
		aAdd(aDados, BA0->BA0_SUSEP) // 1
		aAdd(aDados, BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"-"+BEA_NUMAUT)) // 2
		aAdd(aDados, BEA->BEA_NUMGUI) // 3
		
		aAdd(aDados, "") // 4
		aAdd(aDados, BEA->BEA_NOMUSR) // 5
		
		// Dados do Beneficiario
		If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT) // 6
			aAdd(aDados, BEA->(SubStr(BEA_OPEMOV,1,1)+SubStr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO)	)
		Else
			aAdd(aDados, BA1->BA1_MATANT)
		EndIf
		
		aAdd(aDados, "") //7
		aAdd(aDados, "") //8
		aAdd(aDados, BEA->BEA_SCDPER) // 9
		aAdd(aDados, BEA->BEA_ALTMOL) // 10
		aAdd(aDados, "") //11
		
		BB8->(dbSetOrder(1))
		BB8->(dbSeek(xFilial("BB8")+BAU->BAU_CODIGO+BEA->(BEA_OPEMOV+BEA_CODLOC)))
		
		aAdd(aDados, dDataBase) //12 
		aAdd(aDados, "") //13
		aAdd(aDados, dDataBase)//14 	
		aAdd(aDados, "") //15
		aAdd(aDados, dDataBase) //16 	
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Operadora                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial("BA0")+BEA->(BEA_OPEUSR)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Usuario                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA1->(dbSetOrder(2))
		BA1->(dbSeek(xFilial("BA1")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Sub-Contrato                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BQC->(dbSetOrder(1))
		BQC->(dbSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Vidas                                  			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BTS->(dbSetOrder(1))
		BTS->(dbSeek(xFilial("BTS")+BA1->BA1_MATVID))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Familias/Usuarios                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA3->(dbSetorder(01))
		BA3->(dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Produtos de Saude - Plano                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BI3->(dbSetOrder(1))
		If !Empty(BA1->BA1_CODPLA)
			BI3->(dbSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
		Else
			BI3->(dbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Rede de Atendimento                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BAU->(dbSetOrder(1))
		BAU->(dbSeek(xFilial("BAU")+BEA->BEA_CODRDA))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Especialidade                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BAQ->(dbSetOrder(1))
		BAQ->(MsSeek(xFilial("BAQ")+BEA->(BEA_OPEMOV+BEA_CODESP)))
	
	
	 	    //Cabeçalho
			aAdd(aDados, BA0->BA0_SUSEP) // 1
			aAdd(aDados, BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"-"+BEA_NUMAUT)) // 2
			aAdd(aDados, BEA->BEA_NUMGUI) // 3
	
			// Dados do Beneficiario
			If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT) // 4
				aAdd(aDados, BEA->(SubStr(BEA_OPEMOV,1,1)+SubStr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO)	)
			Else
				aAdd(aDados, BA1->BA1_MATANT)
			EndIf
			aAdd(aDados, BI3->BI3_NREDUZ) // 5
			aAdd(aDados, BQC->BQC_DESCRI) // 6
			aAdd(aDados, BA1->BA1_DTVLCR) // 7
			//aAdd(aDados, BTS->BTS_NRCRNA)
	
			aAdd(aDados, BEA->BEA_NOMUSR) // 8
			aAdd(aDados, BA1->(+"( "+BA1_DDD+" ) "+BA1_TELEFO)) //9
			aAdd(aDados, BEA->BEA_NOMTIT) //10
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Profissional de Saude                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aDados, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) // 11
			aAdd(aDados, BAU->BAU_NOME)  // 12
			aAdd(aDados, BEA->BEA_CODRDA)// 13
			BB8->(dbSetOrder(1))
			BB8->(dbSeek(xFilial("BB8")+BAU->BAU_CODIGO+BEA->(BEA_OPEMOV+BEA_CODLOC)))
			aAdd(aDados, BB8->BB8_EST)   // 14
			aAdd(aDados, Transform(BB8->BB8_CNES, cPicCNES)) // 15
			aAdd(aDados, BEA->BEA_NOMSOL) //16
			aAdd(aDados, BEA->BEA_REGSOL)//17
			aAdd(aDados, BEA->BEA_ESTSOL)//18
			aAdd(aDados, BAQ->BAQ_CBOS) // 19
			aAdd(aDados, BEA->BEA_SCDPER) // 20
			aAdd(aDados, BEA->BEA_ALTMOL) // 21
			aAdd(aDados, "") // 22 //Criar Campo Observção Inicial ????????
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Local Atendimento 		               			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BB8->(dbSetOrder(1))
			BB8->(dbSeek(xFilial("BB8")+BD6->(BD6_CODRDA+BD6_CODLOC+BD6_LOCAL)))
	
			aAdd(aDados, dDataBase) // 23
			aAdd(aDados,BB8->BB8_MUN)
			aAdd(aDados, dDataBase) // 24
			aAdd(aDados,BB8->BB8_MUN)
			aAdd(aDados, dDataBase) // 25
			aAdd(aDados,BB8->BB8_MUN)
		EndIf
Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSDPGTOD ³ Autor ³ Luciano Aparecido     ³ Data ³ 14.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Odontológica - Demon. Pagamento )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodOpe - Código da Operadora                               ³±±
±±³          ³ cRdaDe  - Código da RDA a ser processada (de)               ³±±
±±³          ³ cRdaAte - Código da RDA a ser processada (Até)              ³±±
±±³          ³ cAno    - Informe o Ano a ser processado                    ³±±
±±³          ³ cMes    - Informe o Mês a ser processado                    ³±±
±±³          ³ cClaPre - Classe RDA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSDPGTOD(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cNmTitPg)

Local aCpo08,aCpo09,aCpo10,aCpo11,aCpo12,aCpo13,aCpo14,aCpo15,aCpo16,aCpo17,aCpo18,aCpo19,aCpo20,aCpo21,aCpo22,aCpo23,aCpo30,aCpo38,aCpo39,aCpo40
Local aCpo02,aCpo03,aCpo04,aCpo05,aCpo06,aCpo07,aCpo24,aCpo25,aCpo26,aCpo27,aCpo28,aCpo29,aCpo31,aCpo32,aCpo33,aCpo34,aCpo35,aCpo36,aCpo37,aCpo41
Local nInd1, nInd2 , nInd3
Local nCont:=0
Local nValorDC 	:= 0
Local aDados
Local cSQL, cSQL1
Local nDeb,nCred,nDebNT,nCredNT
Local nProcGui,nGloGui,nLibGui
Local nProcLot,nGloLot,nLibLot
Local nProcGer,nGloGer,nLibGer
Local cChRDA,cChLot,cChGuia
LOCAL cNmLotPg		:= ""
LOCAL cRdaLote		:= ""
DEFAULT cNmTitPg := ""

aDados := {}
DBSELECTAREA("SE2")
// Variaveis para buscar o BMR pelo numero do titulo.
If !Empty(cNmTitPg)
	SE2->(dbSetorder(01))
	If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
		cCodOpe  := SE2->E2_PLOPELT
		cNmLotPg := substr(SE2->E2_PLLOTE,7,4) //SE2->E2_PLLOTE
		cRdaLote := SE2->E2_CODRDA
		cAno	 := SE2->E2_ANOBASE
		cMes	 := SE2->E2_MESBASE
	Endif
Endif

cSQL := "SELECT BMR_ANOLOT, BMR_CODLAN, BMR_CODRDA, BMR_DEBCRE, BMR_FILIAL, BMR_MESLOT, BMR_NUMLOT, BMR_OPELOT, BMR_OPERDA, BMR_VLRPAG"
cSQL += "  FROM " + RetSqlName("BMR")
cSQL += " WHERE BMR_FILIAL = '" + xFilial("BMR") + "' AND "
cSQL += " BMR_OPELOT = '" + cCodOpe + "' AND "

If !Empty(cNmLotPg)
	cSQL += " BMR_CODRDA = '" + cRdaLote + "' AND "
	cSQL += " BMR_NUMLOT = '" + cNmLotPg + "' AND "

Else
	cSQL += " ( BMR_CODRDA >= '" + cRdaDe    + "' AND BMR_CODRDA <= '" + cRdaAte    + "' ) AND "

Endif
cSQL += " BMR_ANOLOT = '" + cAno + "' AND "
cSQL += " BMR_MESLOT = '" + cMes + "' AND "

cSql += RetSQLName("BMR")+".D_E_L_E_T_ = ' '"
cSQL += " ORDER BY BMR_FILIAL, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT, BMR_OPERDA, BMR_CODRDA, BMR_CODLAN "

PlsQuery(cSQL,"TrbBMR")

// BA0 - Operadoras de Saude
BA0->(dbSetOrder(1))
BA0->(msSeek(xFilial("BA0")+TrbBMR->(BMR_OPERDA)))

Do While ! TrbBMR->(Eof())
	nValorDC := 0

	nCont+=1
	// BAU - Redes de Atendimento
	BAU->(dbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+TrbBMR->BMR_CODRDA))

	// BAF - Lotes de Pagamentos RDA
	BAF->(dbSetOrder(1))
	BAF->(msSeek(xFilial("BAF")+TrbBMR->(BMR_OPERDA+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)))
	If Empty(cNmTitPg) .and. Empty(cNmLotPg)
		cSQL := " SELECT R_E_C_N_O_ E2_RECNO,E2_VENCTO, E2_VALOR "
		cSQL += "  FROM " + RetSQLName("SE2")
		cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cSQL += "    AND E2_PLOPELT = '" + TrbBMR->BMR_OPELOT + "'"
		cSQL += "    AND E2_PLLOTE = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
		cSQL += "    AND E2_CODRDA = '" + TrbBMR->BMR_CODRDA + "'"
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		PlsQuery(cSQL,"TrbSE2")

		If ! TrbSE2->(Eof())
			SE2->(dbGoTo(TrbSE2->(E2_RECNO)))
		EndIf

		TrbSE2->(DbCloseArea())
	Endif

	cSQL := "SELECT BD7_CODEMP, BD7_CODLDP, BD7_CODOPE, BD7_CODPAD, BD7_CODPEG, BD7_CODPRO, BD7_CODRDA, BD7_CODTPA, BD7_DATPRO, BD7_MATRIC, BD7_NOMRDA,BD7_NOMUSR, BD7_NUMERO, BD7_NUMLOT, BD7_OPELOT, BD7_ORIMOV, BD7_SEQUEN, BD7_TIPREG, BD7_MOTBLO, BD7_VLRGLO, BD7_VLRPAG,BD7_ANOPAG, BD7_MESPAG "
	cSQL += "  FROM " + RetSqlName("BD7")
	cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "'"
	cSQL += "   AND BD7_NUMLOT = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
	cSQL += "   AND BD7_CODRDA = '" + TrbBMR->(BMR_CODRDA)+ "'"
	cSQL += "   AND D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY BD7_CODLDP, BD7_CODPEG"
	PlsQuery(cSQL,"TrbBD7")

	If nCont == 1

		aCpo02 := {}
		aCpo03 := {}
		aCpo04 := {}
		aCpo05 := {}
		aCpo06 := {}
		aCpo07 := {}
		aCpo08 := {}
		aCpo09 := {}
		aCpo10 := {}
		aCpo11 := {}
		aCpo12 := {}
		aCpo13 := {}
		aCpo14 := {}
		aCpo15 := {}
		aCpo16 := {}
		aCpo17 := {}
		aCpo18 := {}
		aCpo19 := {}
		aCpo20 := {}
		aCpo21 := {}
		aCpo22 := {}
		aCpo23 := {}
		aCpo24 := {}
		aCpo25 := {}
		aCpo26 := {}
		aCpo27 := {}
		aCpo28 := {}
		aCpo29 := {}
		aCpo30 := {}
		aCpo31 := {}
		aCpo32 := {}
		aCpo33 := {}
		aCpo34 := {}
		aCpo35 := {}
		aCpo36 := {}
		aCpo37 := {}
		aCpo38 := {}
		aCpo39 := {}
		aCpo40 := {}
		aCpo41 := {}

		aAdd(aCpo09,{})
		aAdd(aCpo10,{})
		aAdd(aCpo11,{})
		aAdd(aCpo12,{})
		aAdd(aCpo13,{})
		aAdd(aCpo14,{})
		aAdd(aCpo15,{})
		aAdd(aCpo16,{})
		aAdd(aCpo17,{})
		aAdd(aCpo18,{})
		aAdd(aCpo19,{})
		aAdd(aCpo20,{})
		aAdd(aCpo21,{})
		aAdd(aCpo22,{})
		aAdd(aCpo23,{})
		aAdd(aCpo24,{})
		aAdd(aCpo25,{})
		aAdd(aCpo26,{})
		aAdd(aCpo27,{})
		aAdd(aCpo28,{})
		aAdd(aCpo29,{})
		aAdd(aCpo30,{})
		aAdd(aCpo33,{})
		aAdd(aCpo34,{})
		aAdd(aCpo35,{})
		aAdd(aCpo38,{})
		aAdd(aCpo40,{})
		aAdd(aCpo41,{})

	Endif
	nInd1 :=nCont
	nProcGer:=0
	nLibGer :=0
	nGloGer :=0

	// BDT - Calendário de Pagamento
	BDT->(dbSetOrder(1))
	BDT->(msSeek(xFilial("BDT")+TrbBD7->(BD7_CODOPE+BD7_ANOPAG+BD7_MESPAG)))
	If nCont == 1
		aAdd(aDados, BA0->BA0_SUSEP) // 1
	Endif

	aAdd(aCpo02, BAF->(BAF_ANOLOT+BAF_MESLOT+BAF_NUMLOT))
	aAdd(aCpo03, BA0->BA0_NOMINT)
	aAdd(aCpo04, Transform(BA0->BA0_CGC, "@R 99.999.999/9999-99"))
	aAdd(aCpo05, {(BDT->BDT_DATINI),(BDT->BDT_DATFIN)})
	aAdd(aCpo06, BAU->(BAU_CODIGO))
	aAdd(aCpo07, BAU->BAU_NOME)
	aAdd(aCpo08, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99")))
	aAdd(aCpo09,{})
	aAdd(aCpo10,{})
	aAdd(aCpo11,{})
	aAdd(aCpo12,{})
	aAdd(aCpo13,{})
	aAdd(aCpo14,{})
	aAdd(aCpo15,{})
	aAdd(aCpo16,{})
	aAdd(aCpo17,{})
	aAdd(aCpo18,{})
	aAdd(aCpo19,{})
	aAdd(aCpo20,{})
	aAdd(aCpo21,{})
	aAdd(aCpo22,{})
	aAdd(aCpo23,{})
	aAdd(aCpo24,{})
	aAdd(aCpo25,{})
	aAdd(aCpo26,{})
	aAdd(aCpo27,{})
	aAdd(aCpo28,{})
	aAdd(aCpo29,{})
	aAdd(aCpo30,{})
	aAdd(aCpo33,{})
	aAdd(aCpo34,{})
	aAdd(aCpo35,{})
	aAdd(aCpo38,{})
	aAdd(aCpo40,{})
	aAdd(aCpo41,{})
	nInd1 := Len(aCpo02)

	nProcLot:=0
	nLibLot :=0
	nGloLot :=0
	nProcGer:=0
	nLibGer :=0
	nGloGer :=0

	cChRDA  := TrbBD7->(BD7_NUMLOT+BD7_CODRDA)
	Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA) ==  cChRDA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tabela Padrão                                    			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BR8->(dbSetOrder(1))
		BR8->(msSeek(xFilial("BR8")+TrbBD7->(BD7_CODPAD+BD7_CODPRO)))

		If BR8->BR8_ODONTO == "1"

			aAdd(aCpo09[nInd1], TrbBD7->(BD7_CODLDP+BD7_CODPEG))
			aAdd(aCpo10[nInd1],{})
			aAdd(aCpo11[nInd1],{})
			aAdd(aCpo12[nInd1],{})
			aAdd(aCpo13[nInd1],{})
			aAdd(aCpo14[nInd1],{})
			aAdd(aCpo15[nInd1],{})
			aAdd(aCpo16[nInd1],{})
			aAdd(aCpo17[nInd1],{})
			aAdd(aCpo18[nInd1],{})
			aAdd(aCpo19[nInd1],{})
			aAdd(aCpo20[nInd1],{})
			aAdd(aCpo21[nInd1],{})
			aAdd(aCpo22[nInd1],{})
			aAdd(aCpo23[nInd1],{})
			aAdd(aCpo24[nInd1],{})
			aAdd(aCpo25[nInd1],{})
			aAdd(aCpo26[nInd1],{})
			nInd2 := Len(aCpo09[nInd1])

			nProcLot:=0
			nLibLot :=0
			nGloLot :=0
			cChLot := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG)
			Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG) ==  cChLot
				BA1->(dbSetOrder(2))
				BA1->(msSeek(xFilial("BA1")+TrbBD7->(BD7_CODOPE+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)))

				If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT)
					aAdd(aCpo10[nInd1,nInd2], BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"-"+BA1_DIGITO)	)
				Else
					aAdd(aCpo10[nInd1,nInd2], BA1->BA1_MATANT)
				EndIf
				aAdd(aCpo11[nInd1,nInd2], TrbBD7->BD7_NOMUSR)
				aAdd(aCpo12[nInd1,nInd2], TrbBD7->BD7_NUMERO)
				aAdd(aCpo13[nInd1, nInd2], {})
				aAdd(aCpo14[nInd1, nInd2], {})
				aAdd(aCpo15[nInd1, nInd2], {})
				aAdd(aCpo16[nInd1, nInd2], {})
				aAdd(aCpo17[nInd1, nInd2], {})
				aAdd(aCpo18[nInd1, nInd2], {})
				aAdd(aCpo19[nInd1, nInd2], {})
				aAdd(aCpo20[nInd1, nInd2], {})
				aAdd(aCpo21[nInd1, nInd2], {})
				aAdd(aCpo22[nInd1, nInd2], {})
				aAdd(aCpo23[nInd1, nInd2], {})

				nInd3 := Len(aCpo12[nInd1, nInd2])

				nProcGui:=0
				nLibGui :=0
				nGloGui :=0
				cChGuia := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
				Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) ==  cChGuia
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tipo de Participação                             			 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BWT->(dbSetOrder(1))
					BWT->(msSeek(xFilial("BWT")+TrbBD7->(BD7_CODOPE+BD7_CODTPA)))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tabela Padrão                                    			 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BR8->(dbSetOrder(1))
					BR8->(msSeek(xFilial("BR8")+TrbBD7->(BD7_CODPAD+BD7_CODPRO)))

					If BR8->BR8_ODONTO == "1"

						BD6->(dbSetOrder(1))
						BD6->(msSeek(xFilial("BD6")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)))

						aAdd(aCpo13[nInd1, nInd2, nInd3], Posicione("BF8", 2, xFilial("BF8")+BD6->(BD6_CODPAD+BD6_CODOPE+BD6_CODTAB), "BF8_TABTIS"))
						aAdd(aCpo14[nInd1, nInd2, nInd3], TrbBD7->BD7_CODPRO)
						aAdd(aCpo15[nInd1, nInd2, nInd3], BR8->BR8_DESCRI)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona Dente/Região                             			 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BYT->(dbSetOrder(1))
						BYT->(dbSeek(xFilial("BYT")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SEQUEN)))
						aAdd(aCpo16[nInd1, nInd2, nInd3], BYT->BYT_CODIGO)

						cSQL1 := " SELECT BE2_ANOAUT,BE2_MESAUT,BE2_NUMAUT "
						cSQL1 += "  FROM " + RetSQLName("BE2")
						cSQL1 += "  WHERE BE2_FILIAL = '" + xFilial("BE2") + "' "
						cSQL1 += "    AND BE2_OPEMOV = '" + TrbBD7->BD7_CODOPE + "'"
						cSQL1 += "    AND BE2_ANOAUT = '" + TrbBD7->BD7_ANOPAG + "'"
						cSQL1 += "    AND BE2_MESAUT = '" + TrbBD7->BD7_MESPAG + "'"
						cSQL1 += "    AND BE2_NUMERO = '" + TrbBD7->BD7_NUMERO + "'"
						cSQL1 += "    AND BE2_CODLDP = '" + TrbBD7->BD7_CODLDP + "'"
						cSQL1 += "    AND BE2_CODPEG = '" + TrbBD7->BD7_CODPEG + "'"
						cSQL1 += "    AND BE2_SEQUEN = '" + TrbBD7->BD7_SEQUEN + "'"
						cSQL1 += "    AND BE2_CODPAD = '" + TrbBD7->BD7_CODPAD + "'"
						cSQL1 += "    AND BE2_CODPRO = '" + TrbBD7->BD7_CODPRO + "'"
						cSQL1 += "    AND D_E_L_E_T_ = ' ' "

						PlsQuery(cSQL1,"TrbBE2")

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona Face		                             			 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BYS->(dbSetOrder(1))
						BYS->(dbSeek(xFilial("BYS")+BYT->BYT_CODOPE+TrbBD7->(BD7_ANOPAG+BD7_MESPAG+BD7_NUMERO)+BYT->(BYT_SEQUEN+BYT_CODIGO)))

						TrbBE2->(dbCloseArea())

						If !Empty(BYS->BYS_FACES)
							aAdd(aCpo17[nInd1, nInd2, nInd3],BYS->BYS_FACES)    //17
						Else
							dbSelectArea("BYT")
							BYT->(dbSetOrder(1))
							BYT->(dbSeek((xFilial("BYT")+TrbBD7->BD7_CODOPE+TrbBD7->BD7_CODLDP+TrbBD7->BD7_CODPEG+TrbBD7->BD7_NUMERO+TrbBD7->BD7_SEQUEN)))
							aAdd(aCpo17[nInd1, nInd2, nInd3],BYT->BYT_FACES)    //17
						EndIf

						aAdd(aCpo18[nInd1, nInd2, nInd3], TrbBD7->BD7_DATPRO) //18
						aAdd(aCpo19[nInd1, nInd2, nInd3], BD6->BD6_QTDPRO) // 19  ???????
						aAdd(aCpo20[nInd1, nInd2, nInd3], TrbBD7->BD7_VLRPAG + TrbBD7->BD7_VLRGLO) //20
						nProcGui+=TrbBD7->BD7_VLRPAG + TrbBD7->BD7_VLRGLO
						aAdd(aCpo21[nInd1, nInd2, nInd3], TrbBD7->BD7_VLRGLO) //21
						nGloGui+=TrbBD7->BD7_VLRGLO
						aAdd(aCpo22[nInd1, nInd2, nInd3], TrbBD7->BD7_VLRPAG) //22
						nLibGui+=TrbBD7->BD7_VLRPAG

						// BCT - Motivos de Glosas
						cCpo23 := ""
						BDX->(dbSetOrder(1))
						If BDX->(msSeek(xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)))
							Do While ! BDX->(eof()) .And. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == ;
								xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)
								// BDX - Glosas das Movimentacoes
								BCT->(dbSetOrder(1))
								If BCT->(msSeek(xFilial("BCT")+BDX->(BDX_CODOPE+BDX_CODGLO)))
									If At(BCT->BCT_GLTISS, cCpo23) == 0
										cCpo23 += IIf(Empty(cCpo23), "", ",") + BCT->BCT_GLTISS
									EndIf
								EndIf
								BDX->(dbSkip())
							EndDo
						EndIf
					Endif
					aAdd(aCpo23[nInd1, nInd2, nInd3], cCpo23)
					TrbBD7->(dbSkip())
				EndDo
				aAdd(aCpo24[nInd1, nInd2],nProcGui)
				nProcLot+=nProcGui
				aAdd(aCpo25[nInd1, nInd2],nGloGui)
				nGloLot+=nGloGui
				aAdd(aCpo26[nInd1, nInd2],(nProcGui-nGloGui))
				nLibLot+=(nProcGui-nGloGui)
			EndDo

			aAdd(aCpo27[nInd1],nProcLot)
			nProcGer+=nProcLot
			aAdd(aCpo28[nInd1],nGloLot)
			nGloGer+=nGloLot
			aAdd(aCpo29[nInd1],(nProcLot-nGloLot))
			nLibGer+=(nProcLot-nGloLot)

		Endif
		TrbBD7->(dbSkip())
	EndDo

	TrbBD7->(DbCloseArea())
	aAdd(aDados, aCpo02)
	aAdd(aDados, aCpo03)
	aAdd(aDados, aCpo04)
	aAdd(aDados, aCpo05)
	aAdd(aDados, aCpo06)
	aAdd(aDados, aCpo07)
	aAdd(aDados, aCpo08)
	aAdd(aDados, aCpo09)
	aAdd(aDados, aCpo10)
	aAdd(aDados, aCpo11)
	aAdd(aDados, aCpo12)
	aAdd(aDados, aCpo13)
	aAdd(aDados, aCpo14)
	aAdd(aDados, aCpo15)
	aAdd(aDados, aCpo16)
	aAdd(aDados, aCpo17)
	aAdd(aDados, aCpo18)
	aAdd(aDados, aCpo19)
	aAdd(aDados, aCpo20)
	aAdd(aDados, aCpo21)
	aAdd(aDados, aCpo22)
	aAdd(aDados, aCpo23)
	aAdd(aDados, aCpo24)//24 Valor Processado Guia
	aAdd(aDados, aCpo25)//25 Valor Glosa Guia
	aAdd(aDados, aCpo26)//26 Valor Liberado Guia
	aAdd(aDados, aCpo27)//27 Valor Processado Lote
	aAdd(aDados, aCpo28)//28 Valor Glosa Lote
	aAdd(aDados, aCpo29)//29 Valor Liberado Lote

	nDeb 	:= 0
	nDebNT 	:= 0
	nCred	:= 0
	nCredNT	:= 0
	nValorDC:= 0

	BGQ->(dbSetOrder(4))//BGQ_FILIAL+BGQ_CODOPE+BGQ_CODIGO+BGQ_ANO+BGQ_MES+BGQ_CODLAN+BGQ_OPELOT+BGQ_NUMLOT
	cChBMR := TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA)
	Do While ! TrbBMR->(Eof()) .And. TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA) == cChBMR

		If TrbBMR->BMR_CODLAN $ "102,103,104,105" // Debitos/Creditos Fixos e Variaveis
			BMS->(dbSetOrder(1))
			BMS->(msSeek(TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)))
			Do While ! BMS->(Eof()) .And. ;
				BMS->(BMS_FILIAL+BMS_OPERDA+BMS_CODRDA+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT+BMS_CODLAN) == ;
				TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)

				If Len(CalcImp(BMS->BMS_VLRPAG)) > 0
					//aAdd(aCpo35[nInd1], { IIf(BMS->BMS_DEBCRE == "1", "(-) ", "(+) ") + BMS->BMS_CODSER + " - " + Posicione("BGQ", 4, xFilial("BGQ")+BMS->(BMS_OPERDA+BMS_CODRDA+BMS_ANOLOT+BMS_MESLOT+BMS_CODSER+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT), "BGQ_OBS"), BMS->BMS_VLRPAG })
					aTmpCpo35 := CalcImp(BMS->BMS_VLRPAG)
					aAdd(aCpo35[nInd1], {aTmpCpo35[1,1],aTmpCpo35[1,2]})
					nValorDC += BMS->BMS_VLRPAG
				Else
					If BGQ->(MsSeek(xFilial("BGQ")+ BMS->(BMS_OPERDA + BMS_CODRDA + BMS_ANOLOT + BMS_MESLOT + BMS_CODSER + BMS_OPELOT + BMS_ANOLOT + BMS_MESLOT + BMS_NUMLOT )))
						If BGQ->BGQ_INCIR  == "1" .Or. BGQ->BGQ_INCINS == "1" .Or. BGQ->BGQ_INCPIS == "1" .Or.;
							BGQ->BGQ_INCCOF == "1" .Or. BGQ->BGQ_INCCSL == "1"
							aAdd(aCpo33[nInd1], { IIf(BMS->BMS_DEBCRE == "1", "(-) ", "(+) ") + BMS->BMS_CODSER + " - " + Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI"), BMS->BMS_VLRPAG })
							If BMS->BMS_DEBCRE == "1"
								nDeb += BMS->BMS_VLRPAG
							else
								nCred += BMS->BMS_VLRPAG
							Endif
						Else
							aAdd(aCpo34[nInd1], { IIf(BMS->BMS_DEBCRE == "1", "(-) ", "(+) ") + BMS->BMS_CODSER + " - " + Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI"), BMS->BMS_VLRPAG })
							If BMS->BMS_DEBCRE == "1"
								nDebNT += BMS->BMS_VLRPAG
							else
								nCredNT += BMS->BMS_VLRPAG
							Endif

						EndIf
					EndIf
				EndIf

				BMS->(dbSkip())

			EndDo
		ElseIf TrbBMR->BMR_CODLAN <> "101" .And. TrbBMR->BMR_DEBCRE <> "3"

			If Len(CalcImp(TrbBMR->BMR_VLRPAG)) > 0
				//aAdd(aCpo35[nInd1], {IIf(TrbBMR->BMR_DEBCRE == "1", "(-) ", "(+) ") + TrbBMR->BMR_CODLAN + " - " + Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN),"BLR_DESCRI"),   TrbBMR->BMR_VLRPAG })
				aTmpCpo35 := CalcImp(TrbBMR->BMR_VLRPAG)
				aAdd(aCpo35[nInd1], {aTmpCpo35[1,1],aTmpCpo35[1,2]})
				nValorDC += TrbBMR->BMR_VLRPAG
			Else
				If TrbBMR->BMR_CODLAN < "170"
					aAdd(aCpo34, {IIf(TrbBMR->BMR_DEBCRE == "1", "(-) ", "(+) ") + TrbBMR->BMR_CODLAN + " - " + Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN),"BLR_DESCRI"),   TrbBMR->BMR_VLRPAG })

					If BMS->BMS_DEBCRE == "1"
						nDebNT += TrbBMR->BMR_VLRPAG
					else
						nCredNT += TrbBMR->BMR_VLRPAG
					Endif
				Else
					aAdd(aCpo33[nInd1], {IIf(TrbBMR->BMR_DEBCRE == "1", "(-) ", "(+) ") + TrbBMR->BMR_CODLAN + " - " + Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN),"BLR_DESCRI"),   TrbBMR->BMR_VLRPAG })
					If TrbBMR->BMR_DEBCRE == "1"
						nDeb += TrbBMR->BMR_VLRPAG
					else
						nCred += TrbBMR->BMR_VLRPAG
					Endif
				EndIf
			EndIf
		EndIf
		TrbBMR->(dbSkip())
	EndDo

	aAdd(aCpo30[nInd1], nProcGer)
	aAdd(aDados, aCpo30)//30 Valor Processado Geral

	aAdd(aCpo31, nGloGer)
	aAdd(aDados, aCpo31)//31 Valor Glosa Geral

	aAdd(aCpo32, (nLibGer+((nCred-nDeb)+(nCredNT-nDebNT))))
	aAdd(aDados, aCpo32)//32 Valor Liberado Geral

	aAdd(aDados, aCpo33)//33 e 34

	aAdd(aDados, aCpo34)//35 e 36

	aAdd(aDados, aCpo35)//37 e 38

	aAdd(aCpo36, SE2->E2_VENCTO) // 39  DATA DO PAGAMENTO
	aAdd(aDados, aCpo36)

	aAdd(aCpo37, nCred-nDeb) 		// 40 VALOR TOTAL TRIBUTAVEL
	aAdd(aDados, aCpo37)

	aAdd(aCpo38[nInd1], nValorDC) 	// 41 VALOR TOTAL IMPOSTOS RETIDOS
	aAdd(aDados, aCpo38)

	aAdd(aCpo39, nCredNT-nDebNT) 	// 42 VALOR TOTAL NAO TRIBUTAVEL
	aAdd(aDados, aCpo39)

	aAdd(aCpo40[nInd1], ((nCred-nDeb)+(nCredNT-nDebNT))) 	// 43 VALOR FINAL A RECEBER
	aAdd(aDados, aCpo40)

	aAdd(aCpo41[nInd1], (SE2->E2_VALOR+nValorDC))
	aAdd(aDados, aCpo41)

EndDo
TrbBMR->(DbCloseArea())

Return aDados

//******************************************************************************************************************************

Static Function fLogoEmp(cLogo, cTipo, cLogoGH)

	Local cStartPath	:= GetSrvProfString("STARTPATH","")

	Default cTipo	:= "1"
	Default cLogoGH := ""

	If ValType(cLogoGH) <> "U" .And. !Empty(cLogoGH) .And. File(cLogoGH) //logo a partir do campo do Gestao Hospitalar
		 cLogo := cLogoGH
	Else // Logotipo da Empresa
		 If cTipo == "1"
	 		cLogo := cStartPath + "LGRL"+FWCompany()+FWCodFil()+".BMP"	// Empresa+Filial
		 	//If !File(cLogo)
		 	//	cLogo := cStartPath + "LGRL"+FWCompany()+".BMP"				// Empresa
	 		//EndIf
		 Else
		 	//cLogo := cStartPath + "LogoSiga.bmp"
		 	cLogo := cStartPath + "LGRL"+FWCompany()+".BMP"				// Empresa
		 EndIf
	EndIf

Return(Nil)

//******************************************************************************************************************************

Function fSomaLin(nLinMax, nColMax, nLinIni, nColIni, nValor, nIniDefault)
DEFAULT nIniDefault := 0
	nLinIni += nValor
	If nLinIni + 100 > nLinMax
		nLinIni := nIniDefault
		oPrint:EndPage()
		oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)
		nLinIni += 10
	EndIf
Return

Static Function CalcImp(nVlrPag)
Local nIss      := 0
Local nPis      := 0
Local nCofins   := 0
Local nIR       := 0
Local nCSLL     := 0
Local nINSSPF   := 0
Local nINSSPJ   := 0
Local nINSSJF   := 0
Local nPINSSPJ  := 0
Local nPINSSPF  := 0
Local nCrPINSS  := 0
Local aTabRes	:= {}
Local lInssUnic := .F.

Do Case
	Case TrbBMR->BMR_CODLAN == "182"
		nBINSSPJ  += nVlrPAg
		lInssUnic := .T.
	Case TrbBMR->BMR_CODLAN == "183"
		nINSSPJ   += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "184"
		nBIss     += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "185"
		nIss      += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "186"
		nBPis     += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "187"
		nPis      += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "188"
		nBCofins  += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "189"
		nCofins   += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "190"
		nBCSLL    += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "191"
		nCSLL     += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "192"
		nBINSSPF  += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "193"
		nINSSPF   += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "194"
		nBINSSPJ  += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "195"
		nINSSPJ   += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "196"
		nBINSSPF  += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "197"
		nINSSPF   += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "198"
		nBIR      += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "199"
		nIR       += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "179"
		nPINSSPJ  += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "180"
		nPINSSPF  += nVlrPAg
	Case TrbBMR->BMR_CODLAN == "181"
		nCrPINSS  += nVlrPAg

EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta resumo                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  nIss > 0
	aadd(aTabRes,{"ISS", nIss})
Endif
If  nPis > 0
	aadd(aTabRes,{"PIS", nPis})
Endif
If  nCofins > 0
	aadd(aTabRes,{"COFINS", nCofins})
Endif
If  nCSLL   > 0
	aadd(aTabRes,{"CSLL", nCSLL})
Endif
If  nPINSSPF > 0
	aadd(aTabRes,{"Prov INSS PF", nPINSSPF})
Endif
If  nPINSSPJ > 0
	aadd(aTabRes,{"Prov INSS PJ", nPINSSPJ})
Endif
If  nINSSPF > 0
	aadd(aTabRes,{"INSS PF", nINSSPF})
Endif
If  nINSSPJ > 0
	If  lInssUnic
		aadd(aTabRes,{"INSS", nINSSPJ})
	Else
		aadd(aTabRes,{"INSS PJ", nINSSPJ})
	Endif
Endif
If  nINSSJF > 0
	aadd(aTabRes,{"INSS JF", nINSSJF})
Endif
If  nIR > 0
	aadd(aTabRes,{"I.R", nIR})
Endif
If  nCrPINSS > 0
	aadd(aTabRes,{"Cred Prov INSS",nCrPINSS})
Endif

Return(aTabRes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLVINCTIS ³ Autor ³ Bruno Iserhardt       ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Chama a tela para vincular um item qualquer com um elemento ³±±
±±³          ³da TISS ou exclui o vínculo com a TISS, de acordo com o      ³±±
±±³          ³parÂmetro cOpc                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTabPLS (caracter, obrigatório) - Recebera o código do alias³±±
±±³          ³de origem de onde esta sendo chamada a função de vinculo,    ³±±
±±³          ³ou seja, se a função esta sendo chamada de um ações          ³±±
±±³          ³relacionadas do browse da tabela padrão (BR8), devera ser    ³±±
±±³          ³passado o conteúdo "BR8" neste parâmetro, através do valor   ³±±
±±³          ³deste parâmetro será possível descobrir a terminologia       ³±±
±±³          ³vinculada a esta tabela posicionando na tabela               ³±±
±±³          ³"BTP (Cabeçalho de terminologias)", para o campo BTP_ALIAS   ³±±
±±³          ³igual ao valor do parâmetro cTabPLS.                         ³±±
±±³          ³                                                             ³±±
±±³          ³ cChvTab (caracter, opcional): Recebera o valor dos campos   ³±±
±±³          ³que compõem a chave do índice (SIX) principal da tabela,     ³±±
±±³          ³ex: BR8_FILIAL+BR8_CODPAD+BR8_CODSPA = 010110101012 onde     ³±±
±±³          ³01= filial, 01 = tabela e 10101012 = procedimento, essa chave³±±
±±³          ³é para localização do item da tabela em questão, não é       ³±±
±±³          ³necessário a composição inteira de um índice, apenas os      ³±±
±±³          ³campos para posicionamento no registro, tabelas mais simples,³±±
±±³          ³terão apenas filial+código, a tabela de procedimento se      ³±±
±±³          ³trata de uma das exceções existentes, porque o código do     ³±±
±±³          ³procedimento esta associado a tabela de procedimentos        ³±±
±±³          ³(BR8_CODPAD), dessa forma só com o código do procedimento não³±±
±±³          ³seria possível ter uma chave única do mesmo, pois o mesmo    ³±±
±±³          ³procedimento pode estar em uma ou mais tabelas .             ³±±
±±³          ³                                                             ³±±
±±³          ³ cCpoPri (caracter, obrigatório):  Valor do campo principal  ³±±
±±³          ³que faz o vinculo, no exemplo citado acima seria o valor do  ³±±
±±³          ³campo BR8_CODPSA.                                            ³±±
±±³          ³      				                                   	     ³±±
±±³          ³ cOpc: Indica qual ação o método deve tomar, se é de incluir ³±±
±±³          ³um vínculo(1) ou se é para excluir(0)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLVINCTIS(cTabPLS, cCpoPri, cOpc)
Local cCodTab 		:= ""   //Código da TERMINOLOGIA
Local lHasVinc 	:= .F. //indica se o item tem vinculo na tiss
Local lAltVinc 	:= .F. //indica se o usuário deseja alterar o vinculo da tiss do item
Local cCodTerm	 	:= ''  //código do termo que será vinculado
Local cDescTerm 	:= '' //descrição do termo que ja está vinculado
Local cTerminolo 	:= '' //descrição da Terminologia
Local nIncluir	 	:= 1
Local nExcluir 	:= 0
Local nOpca      	:= 0
Local nLin		 	:= 1
Local bOK			:= { ||nLin := oBrowUsr:nAt, nOpca := 1,oDlgPes:End() }
Local bCancel 		:= { || nOpca := 3,oDlgPes:End() }
Local aBrowUsr 	:= PLGetTermi(cTabPLS)
Local cTissVer  := PLSTISSVER()
Local cChvTab := ""

// variaveis lgpd 
local objCENFUNLGP  := CENFUNLGP():New()
local aCamposCen  	:= {}
local aBls  		:= {}

Private aHBOB   	:= {}
Private aCBOB   	:= {}
Private cChv445	:= ""

If Empty(cTissVer)
	MsgAlert(STR0417)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 10, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DbSelectArea("BTP")
BTP->(DbSetOrder(2))
DbSelectArea("BVL")
BVL->(DbSetOrder(2))

	If BTP->(MsSeek(xFilial("BTP")+cTabPLS))
		cChvTab := &(ALLTRIM(cTabPLS+"->("+cTabPLS+"_FILIAL+"+ALLTRIM(BTP->BTP_CHVTAB)+")"))

		Else
			If BVL->(MsSeek(xFilial("BVL")+cTabPLS))
				cChvTab := &(ALLTRIM(cTabPLS+"->("+cTabPLS+"_FILIAL+"+ALLTRIM(BVL->BVL_CHVTAB)+")"))
			Else
				MsgAlert("Não foi encontrada terminologia TISS vinculada a tabela: " + cTabPLS)
			EndIf
	EndIf

//Se o Alias enviado tem mais de uma tabela de domínio
If (Len(aBrowUsr) > 0)
	If Len(aBrowUsr) == 1
		//Código da TERMINOLOGIA
		cCodTab := aBrowUsr[1,1]
		//Descrição da Terminologia
		cTerminolo = aBrowUsr[1,2]
	Else
		//Dialogo de pesquisa de terminologia
		DEFINE MSDIALOG oDlgPes TITLE STR0416 From 009,000 TO 250,780 OF GetWndDefault() PIXEL //"Seleção de Terminologia"
		//Cria a Grid
		//Determina a grid de acordo com a resolução da tela
		If aPosObj[1][4] > 780  //1600x900
			oBrowUsr := TcBrowse():New( aPosObj[1][1]+2, aPosObj[1][2], aPosObj[1][3], aPosObj[1][4]/10,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )
		ElseIf aPosObj[1][4] > 701 .AND. aPosObj[1][4] <= 780  //1440x900
			oBrowUsr := TcBrowse():New( aPosObj[1][1]+2, aPosObj[1][2], aPosObj[1][3], aPosObj[1][4]/9,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )
		ElseIf aPosObj[1][4] > 661 .AND. aPosObj[1][4] <= 700  //1360x768
			oBrowUsr := TcBrowse():New( aPosObj[1][1]+2, aPosObj[1][2], aPosObj[1][3]+80, aPosObj[1][4]/9,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )
		ElseIf aPosObj[1][4] > 621 .AND. aPosObj[1][4] <= 660  //1280x1024 e 1280x800
			oBrowUsr := TcBrowse():New( aPosObj[1][1]+2, aPosObj[1][2], IIf(aPosObj[1][3] = 427,aPosObj[1][3]-50,aPosObj[1][3]+60), aPosObj[1][4]/8,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )
		ElseIf aPosObj[1][4] > 500 .AND. aPosObj[1][4] <= 620  //1024x768
			oBrowUsr := TcBrowse():New( aPosObj[1][1]+2, aPosObj[1][2], aPosObj[1][3]+80, aPosObj[1][4]/6,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )
		EndIf
		//oBrowUsr := TcBrowse():New( 035, 008, 378, 075,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )
		//Coluna Código
		oBrowUsr:AddColumn(TcColumn():New(STR0409,nil,;
		         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
		         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,1] }
		//Coluna Descrição
		oBrowUsr:AddColumn(TcColumn():New(STR0410,nil,;
		         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
		         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,2] }

		oBrowUsr:nAt := 1 //seta o primeiro item da grid como default
		oBrowUsr:SetArray(aBrowUsr) //seta os itens que irão conter na grid
		oBrowUsr:Refresh()
		oBrowUsr:SetFocus()
		oBrowUsr:BLDBLCLICK := bOK

		if objCENFUNLGP:isLGPDAt()
			aCamposCen := {"BTP_CODTAB", "BTP_DESCRI"}
			aBls := objCENFUNLGP:getTcBrw(aCamposCen)

			oBrowUsr:aObfuscatedCols := aBls
		endif

		ACTIVATE MSDIALOG oDlgPes ON INIT Eval({ || EnChoiceBar(oDlgPes, bOK, bCancel,.F.) })

		//se o usuário selecionou algum registro
		If nOpca == K_OK
			//verifica se o registro não está em branco
		   	If !Empty(aBrowUsr[nLin,1])
		      	//Código da TERMINOLOGIA
				cCodTab := aBrowUsr[nLin,1]
				//Descrição da Terminologia
				cTerminolo = aBrowUsr[nLin,2]
		   Endif
		Endif
	EndIf
EndIf

//Se achou alguma tabela de terminologia
IF ( cCodTab != "" )
	//Seeka novamente a BTP para não se perder ao salvar registro na BTU
DbSelectArea("BTP")
BTP->(DbSetOrder(2))
DbSelectArea("BVL")
BVL->(DbSetOrder(2))

If BTP->(MsSeek(xFilial("BTP")+cTabPLS+cCodTab))
	cChvTab := &(ALLTRIM(cTabPLS+"->("+cTabPLS+"_FILIAL+"+ALLTRIM(BTP->BTP_CHVTAB)+")"))
Else
	If BVL->(MsSeek(xFilial("BVL")+cTabPLS+cCodTab))
		cChvTab := &(ALLTRIM(cTabPLS+"->("+cTabPLS+"_FILIAL+"+ALLTRIM(BVL->BVL_CHVTAB)+")"))
	EndIf
EndIf
	//verifica se o item tem vinculo na tabela de depara
	dbSelectArea("BTU")
	dbSetOrder(2) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
	lHasVinc := MsSeek(xFilial("BTU")+cCodTab+cTabPLS+cChvTab)

	//se tem vinculo verifica se o usuário realmente quer alterar o vinculo
	if ( lHasVinc )
		//seleciona o item que ja está vinculado para exibir a sua descrição
		dbSelectArea("BTQ")
		dbSetOrder(1)
		if (MsSeek(xFilial("BTQ")+cCodTab+BTU->BTU_CDTERM))
			cDescTerm := BTQ->BTQ_DESTER
		EndIf

		//se for exclusão
		if (cOpc) == nExcluir
			//pergunta se o usuário deseja excluir o vínculo
			if (MsgYesNo(STR0412+"<br>"+STR0409+': '+BTU->BTU_CDTERM+'<br>'+STR0410+': '+cDescTerm)) //Deseja reamente excluir o vínculo com a TISS deste item? Código: XXXXX Descrição: XXXXX
				cCodTerm := BTU->BTU_CDTERM
				cCodTab := BTU->BTU_CODTAB
				BTU->(RecLock('BTU',.F.))
					BTU->(DbDelete())
					BTU->(DbSkip())
				BTU->( MsUnlock() )

				//CHAMA A FUNÇAO QUE ATUALIZA O CAMPO BTU_HASVIN
				PLSAHASVIN(cCodTab, cCodTerm, cTabPLS)

				MsgInfo(STR0415) //"Vínculo excluido com sucesso."
			EndIf
		//se não é inclusão
		Else
			//seleciona o item que ja está vinculado para exibir a sua descrição
			dbSelectArea("BTQ")
			dbSetOrder(1)
			if (MsSeek(xFilial("BTQ")+cCodTab+BTU->BTU_CDTERM))
				cDescTerm := BTQ->BTQ_DESTER
			EndIf

			//verifica se o usuário deseja alterar o vínculo
			lAltVinc := MsgYesNo(STR0404+'<br>'+STR0409+': '+BTU->BTU_CDTERM+'<br>'+STR0410+': '+cDescTerm) //Item já tem Vinculo com a TISS, deseja alterar este vínculo? Código: XXXXX Descrição: XXXXX
		EndIf
    ElseIf (cOpc) == nExcluir
    	MsgInfo(STR0408) //Item não tem vínculo com a TISS.
    EndIf

	//se for inclusão e (não tem vinculo ou o usuário deseja alterar o vinculo)
	if ((cOpc) == nIncluir .And. ( !lHasVinc .Or. lAltVinc ) )
		//pesquisa o termo para vincular, se ja tem vinculo passa o código do item vinculado da TISS
		cCodTerm := PLSPESTISS(IIf(lHasVinc, BTU->BTU_CDTERM, ""), cCodTab, cTerminolo)


		//verifica se foi selecionado algum registro na pesquisa
		if ( cCodTerm != '' )
			If (lHasVinc)//se já tem vínculo, ALTERA o vínculo
				//realiza alteração somente se o item selecionado não for o mesmo do que o que esta selecionado
				If ( BTU->BTU_CDTERM != cCodTerm )
					BTU->(RecLock("BTU",.F.))
						BTU->BTU_CDTERM := cCodTerm
					BTU->( MsUnlock() )

					MsgInfo(STR0414)
				EndIf
			Else //caso contrário INCLUI o vínculo
				BTU->(RecLock('BTU',.T.))
					BTU->BTU_FILIAL := xFilial("BTU")
					BTU->BTU_CODTAB := cCodTab
					BTU->BTU_VLRSIS := cChvTab
					BTU->BTU_VLRBUS := cCpoPri
					BTU->BTU_CDTERM := cCodTerm
					BTU->BTU_ALIAS  := cTabPLS
				BTU->( MsUnlock() )

				MsgInfo(STR0413) //Vínculo incluido com sucesso.
			EndIf

			//CHAMA A FUNÇAO QUE ATUALIZA O CAMPO BTU_HASVIN
			PLSAHASVIN(cCodTab, cCodTerm, cTabPLS)
		EndIf
	EndIf
ElseIf (nOpca == K_OK)
	MsgInfo(STR0405) //Tabela de Domínio não encontrada.
EndIf

Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLGetTermi ³ Autor ³ Bruno Iserhardt    ³ Data ³ 09.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna um array com todas as terminologias do alias      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLGetTermi(cTabPLS)
Local aTerminolo := {}
Local cTissVer  := PLSTISSVER()

If Empty(cTissVer)
 	MsgAlert(STR0417)
Else
	//seleciona todas as terminologias que utilziam o alias cadastrados na tabela BTP
	BTP->(DbSelectArea("BTP"))
	BTP->(DbSetOrder(2)) //BTP_FILIAL+BTP_ALIAS
	If (BTP->(MsSeek(xFilial("BTP")+cTabPLS)))
		While (!BTP->(Eof()) .AND. BTP->(BTP_FILIAL+BTP_ALIAS) == xFilial("BTP")+cTabPLS)
			BTP->(aadd(aTerminolo, { BTP_CODTAB, BTP_DESCRI }))
			BTP->(DbSkip())
		EndDo
	EndIf

	//agora seleciona as terminologias que utilizam o alias cadastrados na tabela BVL
	BVL->(DbSelectArea("BVL"))
	BVL->(DbSetOrder(2)) //BVL_FILIAL+BVL_ALIAS
	If (BVL->(MsSeek(xFilial("BVL")+cTabPLS)))
		BTP->(DbSetOrder(1)) //BTP_FILIAL+BTP_CODTAB
		While (!BVL->(Eof()) .AND. BVL->(BVL_FILIAL+BVL_ALIAS) == xFilial("BVL")+cTabPLS)
			//seleciona na BTP a descriçao e o codigo da tabela
			If (BTP->(MsSeek(xFilial("BTP")+BVL->BVL_CODTAB)))
				BTP->(aadd(aTerminolo, { BTP_CODTAB, BTP_DESCRI }))
			EndIf
			BVL->(DbSkip())
		EndDo
	EndIf
EndIf

Return aTerminolo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESUSER ³ Autor ³ Bruno Iserhardt    ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de itens das tabelas de dominio TISS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESTISS(cCodVinc, cCodTab, cTerminolo)
LOCAL cChave     := IIF (!Empty(cCodVinc), cCodVinc, Space(100))
LOCAL oDlgPesTis
LOCAL oTipoPes
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"",""} }
LOCAL oBrowUsr
LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPTISPq(AllTrim(cChave),Subs(cTipoPes,1,1),cCodTab,lChkChk,aBrowUsr,aVetPad,oBrowUsr),.T.), If( Empty(aBrowUsr[1,2]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || IIF(FunName() == "TMKA271", (nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesTis:End()), IIF(!Empty(cChave),(nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesTis:End()),Help("",1,"PLSMCON"))) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesTis:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL oChkChk
LOCAL lChkChk    := .F.
LOCAL nLin       := 1
LOCAL aButtons 	 := {}
LOCAL cSQL
LOCAL cRet       := ''

// variaveis lgpd 
local objCENFUNLGP  := CENFUNLGP():New()
local aCamposCen  	:= {}
local aBls  		:= {}

aBrowUsr := aClone(aVetPad)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Itens do combo do tipo de pesquisa...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTipoPes   := {STR0406,STR0407} //Código Terminologia || Decrição Item Terminologia

DbSelectArea("BTQ")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesTis TITLE cTerminolo FROM 009,000 TO 280,780 OF GetWndDefault() PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetChave := TGet():New(37,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesTis,210,10 ,"",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr := TcBrowse():New( 055,008,378,075,,,, oDlgPesTis,,,,,,,,,,,, .F.,, .T.,, .F., ) //23-10

//Código
oBrowUsr:AddColumn(TcColumn():New(STR0409,nil,;
         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,1] }
//Descrição
oBrowUsr:AddColumn(TcColumn():New(STR0410,nil,;
         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,2] }

@ 37,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,13 OF oDlgPesTis PIXEL COLOR CLR_HBLUE

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK := bOK

if objCENFUNLGP:isLGPDAt()
	aCamposCen := {"BTQ_CDTERM", "BTQ_DESTER"}
	aBls := objCENFUNLGP:getTcBrw(aCamposCen)

	oBrowUsr:aObfuscatedCols := aBls
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesTis ON INIT Eval({ || EnChoiceBar(oDlgPesTis,bOK,bCanc,.F.,aButtons), EVAL(bRefresh), oGetChave:SetFocus() })

//se o usuário selecionou algum registro
If nOpca == K_OK
	//verifica se o registro não está em branco
   	If !Empty(aBrowUsr[nLin,1])
   		//atribui o código do item da terminologia a variável de retorno
      	cRet := aBrowUsr[nLin,1]
   Endif
Endif

If ValType(cChv445) <> 'U'
	cChv445 := cRet
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPTISPq ³ Autor ³ Bruno Iserhardt    ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa detalhes das tarminologias TISS na base de dados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSAPTISPq(cChave,cTipoPes,cCodTab,lChkChk,aBrowUsr,aVetPad,oBrowUsr)
Local aArea     	:= GetArea()
LOCAL cSQL      	:= ""

If ( '"' $ cChave .Or. "'" $ cChave )
   Aviso( STR0418, STR0419, { STR0420 }, 2 )
   Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowUsr := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua busca...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BTQ.BTQ_CDTERM, BTQ.BTQ_DESTER "
cSQL += "FROM "+RetSqlName("BTQ")+" BTQ "
cSQL += "WHERE D_E_L_E_T_ = ' ' "
cSQL += "AND (BTQ_VIGDE = '" + DTOS(STOD("")) + "' OR BTQ_VIGDE <= '" + DTOS(Date()) + "') "
cSQL += "AND (BTQ_VIGATE = '" + DTOS(STOD("")) + "' OR BTQ_VIGATE >= '" + DTOS(Date()) + "') "
cSQL += "AND BTQ_CODTAB = '" + cCodTab + "' "

If ( cChave != '_' )
	cSQL += "AND "
	IF (cTipoPes == 'C')
		cSQL += "BTQ_CDTERM LIKE '"+cChave+"%'"
	Else
		cSQL += "BTQ_DESTER LIKE '%"+cChave+"%'"
	EndIf
EndIf

PLSQuery(cSQL,"TrbPes")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Popula a grid de pesquisa...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TrbPes->(DbGoTop())
While ! TrbPes->(Eof())
	TrbPes->(aadd(aBrowUsr, { BTQ_CDTERM, BTQ_DESTER }))
	TrbPes->(DbSkip())
Enddo

TrbPes->(DbCloseArea())
RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowUsr) == 0
	MsgInfo(STR0411) //Nenhum item encontrado com o filtro ou não existe tabela vigente para a Terminologia.
   	aBrowUsr := aClone(aVetPad)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:Refresh()
oBrowUsr:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAHASVIN ³ Autor ³ Bruno Iserhardt    ³ Data ³ 08.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funçao que atualiza o banco indicando se o termo tem      ³±±
±±³          ³ vinculo com algum item do protheus na BTU.				   ³±±
±±³          ³ ATENÇAO: FUNÇAO TAMBEM UTILIZADA NO FONTE PLSA444.PRW	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSAHASVIN(cCodTab, cCodTerm, cAlias, nCount)
Local lHasVin := "0" //indica se o termo já tem vinculo com a tabela de de/para
Default nCount := 0

BTU->(dbSelectArea("BTU"))
BTU->(dbSetOrder(3)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_CDTERM

//verifica se o código enviado tem registro na tabela de de/para
lHasVin := If(BTU->(MsSeek(xFilial("BTU")+cCodTab+cAlias+cCodTerm)), "1", "0")

BTQ->(dbSelectArea("BTQ"))
BTQ->(dbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

//posiciona no registro que sera alterado
IF (BTQ->(MsSeek(xFilial("BTQ")+cCodTab+cCodTerm)))
	If (nCount > 0 .AND. nCount == HS_CountTB("BTU", "BTU_FILIAL='"+xFilial('BTU')+"' AND BTU_CODTAB='"+cCodTab+"' AND BTU_CDTERM='"+cCodTerm+"' AND BTU_ALIAS='"+cAlias+"'"))
		//indica que não tem vinculo
		lHasVin := "0"
	EndIf
	//realiza o update no registro informando se ja tem ou não o vinculo na tabela de de/para
	BTQ->(RecLock("BTQ",.F.))
		BTQ->BTQ_HASVIN := lHasVin
	BTQ->( MsUnlock() )
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSGETVINC ³ Autor ³ Bruno Iserhardt    ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a descrição ou o código do vínculo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGETVINC (cColuna, cAlias, lMsg, cCodTab , cVlrTiss, lPortal, aTabDup, cPadBkp )

Local cRet := ''
Local cChave := ''
Local lAchou := .T.
Local cTip := ''
Local nCT := 0
Local cAux := ''
Local cBtuVlrSis :=""
Default cVlrTiss := ""
Default lMsg := .F.
Default cCodTab := ''
Default lPortal := .F.
Default aTabDup := {}

cVlrTiss := AllTrim(cVlrTiss)
cRet := cVlrTiss

If !FWAliasInDic("BTP", .F.)
	If lPortal == .T.		
		Return(cRet)
	Else
		MsgAlert(STR0422) //"Para esta funcionalidade é necessário executar os procedimentos referente ao chamado: THQGIW"
		Return(cRet)
	Endif
EndIf

//Tratamento para os campos 35 e 29 - Motivo de Encerramento do Atendimento e da internação - SADT Execucao/Guia Resumo de Internação
If cCodTab == "39" .or. lPortal
	BTU->(DbSelectArea("BTU"))
	BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
	BTU->(DbSelectArea("BVL"))
	BVL->(dbSetOrder(2)) //BVL_FILIAL+BVL_ALIAS+BVL_CODTAB
	If BVL->(MsSeek(xFilial("BVL")+cAlias+cCodTab))
		cChave := cAlias+"->(xFilial('"+cAlias+"')+"+BVL->BVL_CHVTAB+")"
		If lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+cCodTab+cAlias+&(cChave)))
			cRet := BTU->BTU_CDTERM
			Return (cRet)
		ElseIf lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+ cCodTab+cAlias+(xFilial(cAlias)+cVlrTiss)))
			cRet := BTU->BTU_CDTERM
			Return (cRet)
		EndIf
	EndIf
Endif

//Se a função for chamada das guias do portal realiza função inversa, buscando código do protheus
If lPortal == .T.
	dbSelectArea("BTU")
	BTU->(dbSetOrder(3)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_CDTERM
	If BTU->(MsSeek(xFilial("BTU")+cCodTab+cAlias+cVlrTiss))
		cRet := BTU->BTU_VLRBUS
		Return (cRet)
	EndIf
Endif

dbSelectArea("BTP")
BTP->(dbSetOrder(2)) //BTP_FILIAL+BTP_ALIAS+BTP_CODTAB

dbSelectArea("BTU")
BTU->(dbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS

dbSelectArea("BTQ")
BTQ->(dbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

dbSelectArea("BVL")
BVL->(dbSetOrder(2)) //BVL_FILIAL+BVL_ALIAS+BVL_CODTAB

dbSelectArea("BE2")
BE2->(dbSetOrder(1))

If	BTP->(MsSeek(xFilial("BTP")+Iif(Empty(cAlias), space(3), cAlias)+cCodTab)) .And. !Empty(cAlias)
	cChave := cAlias+"->(xFilial('"+cAlias+"')+"+BTP->BTP_CHVTAB+")"
	cTip := BTP->BTP_TIPVIN

	If Empty(cCodTab) .AND. cAlias == "BR8" // Busco a tabela
		//"0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Di¯rias;5=-rtese/Pr¥tese;6=Pacote;7=Gases Medicinais;8=Alugu+is"
		Do Case
		Case BR8->BR8_TPPROC $ "06"
			cCodTab := "22"
		Case BR8->BR8_TPPROC $ "347"
			cCodTab := "18"
		Case BR8->BR8_TPPROC $ "15"
			cCodTab := "19"
		Case BR8->BR8_TPPROC == "2"
			cCodTab := "20"
		OtherWise
			cCodTab := "22"
		EndCase
	EndIf

ElseIf BVL->(MsSeek(xFilial("BVL")+cAlias+cCodTab))
	cChave := cAlias+"->(xFilial('"+cAlias+"')+"+BVL->BVL_CHVTAB+")"
	cTip :=  BVL->BVL_TIPVIN
Else
	lAchou := .F.
EndIf

If cTip == '0' //TABELA
	If (cColuna == "BTU_CDTERM")
		If Empty(cVlrTiss)
			If lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+cCodTab+cAlias+&(cChave)))
				cRet := BTU->BTU_CDTERM
			Endif
		ElseIf !Empty(aTabDup)
			For nCT := 1 to Len(aTabDup)
				If lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+ Alltrim(aTabDup[nCT,1])+ cAlias+ (xFilial(cAlias)+cVlrTiss)))
					cRet := BTU->BTU_CDTERM
					@cPadBkp := Alltrim(aTabDup[nCT,1])
				EndIf
			Next nCT
		ElseIf lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+ AllTrim(cCodTab)+ cAlias+ (xFilial(cAlias)+cVlrTiss)))
			cRet := BTU->BTU_CDTERM
		EndIf
	ElseIf (cColuna == "BTQ_DESTER")
		If Empty(cVlrTiss)
			If lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+cCodTab+cAlias+&(cChave)))
				cVlrTiss := BTU->BTU_CDTERM
				If BTQ->(MsSeek(xFilial("BTQ")+cCodTab+cVlrTiss))
					cRet := BTQ->BTQ_DESTER
				EndIf
			EndIf
		ElseIf lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+ Alltrim(cCodTab)+ cAlias+ (xFilial(cAlias)+cVlrTiss+Space(TamSX3("BTU_VLRSIS")[1]-Len(cVlrTiss)))))
			cVlrTiss := BTU->BTU_CDTERM
			If BTQ->(MsSeek(xFilial("BTQ")+AllTrim(cCodTab)+cVlrTiss))
				cRet := BTQ->BTQ_DESTER
			EndIf
		ElseIF BTQ->(MsSeek(xFilial("BTQ")+AllTrim(cCodTab)+cVlrTiss))
				cRet := BTQ->BTQ_DESTER
		EndIf
	EndIf

Else //COMBO

	If (cColuna == "BTU_CDTERM")
		If !Empty(cVlrTiss)
			If BTU->(MsSeek(xFilial("BTU")+ cCodTab+ cAlias+ cVlrTiss))
				cRet := BTU->BTU_CDTERM
			EndIf
		EndIf
	EndIf

EndIf

If (Empty(cRet) .and. lMsg == .T.)
	cRet := (STR0421)
else
	cAux := decodeUTF8(cRet)
	If cAux != nil
		cRet := cAux
	EndIf
EndIf

If cRet == cVlrTiss .and. funname() == ("HSPAHM52") .AND. cCodTab == "19"
	cRet := ' '
Endif

If cRet != BTU->BTU_CDTERM .AND. cColuna == "BTU_CDTERM"
	BTU->(DbSetOrder(2))//BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
		If BTU->(MsSeek(xFilial("BTU")+AllTrim(cCodTab)+cAlias+XFILIAL(CALIAS)+cCodTab+cVlrTiss))// Ex do ultimo parametro: "M SP    0143000010"(XFILIAL(CALIAS)+BE2->BE2_CODPAD+cVlrTiss)
			cRet := BTU->BTU_CDTERM
			Else
				If BTU->(MsSeek(xFilial("BTU")+cCodTab+(xFilial(cAlias)+cVlrTiss+Space(TamSX3("BTU_VLRSIS")[1]-Len(cVlrTiss)-8))+cAlias))
					cRet := BTU->BTU_CDTERM
				Else
					//BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
					If BTU->(MsSeek(xFilial("BTU")+cCodtab+xFilial(cAlias)+cVlrTiss))
					cRet := BTU->BTU_CDTERM
				else
					If BTU->(MsSeek(xFilial("BTU")+cCodtab+cAlias+cVlrTiss))
						cRet := BTU->BTU_CDTERM
					EndIf
				EndIf
				
			EndIf
		EndIf
EndIf

If (cColuna == "BTQ_CDTERM")
	If ! Empty(cVlrTiss)
		If lAchou == .T. .AND. BTU->(MsSeek(xFilial("BTU")+AllTrim(cCodTab)+cAlias+XFILIAL(CALIAS)+cCodTab+cVlrTiss))
			cBtuVlrSis := BTU->BTU_CDTERM
			If BTQ->(MsSeek(xFilial("BTQ")+cCodTab+cBtuVlrSis))
				cRet := BTQ->BTQ_DESTER
			EndIf
		EndIf
	EndIf
EndIf

Return (Alltrim(cRet))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PSRETCART  ³ Autor ³ Everton M. Fernandes Data ³ 08.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o numero da carteirinha do usuario para a         ³±±
±±³          ³ impressão da guia SADT padrão TISS 3.0.      			   ³±±
±±³          ³                                                      	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PSRETCART()
Local cRet
If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT) // 8
	cRet := BEA->(SubStr(BEA_OPEMOV,1,1)+SubStr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO)
Else
	cRet := POSICIONE("BA1",2,XFILIAL("BA1")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),"BA1_MATANT")
EndIf

Return cRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSVLDATA  ³ Autor ³ Caio C L Maciente Data ³ 20.04.17    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ		´±±
±±³Descricao ³ Retorna a data de autorização da guia de internação       		³±±
±±³          ³ caso o beneficiario tenha procedimentos em auditoria      		³±±
±±³          ³ a data que será impressa na guia TISS será a data da      		³±±
±±³          ³ auditoria. Caso seja autorizada, imprimi a data de digitação	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDATA(cAlias,cChave)
	
Local cData := ""
LOCAL cSQL  := ""
Local cAudito := ""
Local cDtProBQV := ""
Local cStatus	:= ""
Local cRECNO := ""
Local cCodOpe := Substr(cChave,0,4)
Local cAnoInt := Substr(cChave,5,4)
Local cMesInt := Substr(cChave,9,2)
Local lApvBQV	:= .F.
Local cNumInt := Substr(cChave,11) 
Local lAudBQV := .F.
Local cSeq		:= ""
Local lAchou  := .F.
Local cRecMov := ""
Local cCodPro := ""

If cAlias == "BE4"

	dbSelectArea("BE4")
	BE4->(dbSetOrder(2)) //BE4_FILIAL, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT

	dbSelectArea("BQV")
	BQV->(dbSetOrder(1)) //BQV_FILIAL, BQV_CODOPE, BQV_ANOINT, BQV_MESINT, BQV_NUMINT, BQV_SEQUEN
		
//Posiciono na BE4 Internação para saber se existe auditoria para a guia a ser impressa 
	If BE4->(MsSeek(xFilial('BE4')+cCodOpe+cAnoInt+cMesInt+cNumInt))
		cAudito 	:= BE4->BE4_AUDITO
		cStatus	:= BE4->BE4_STATUS
		cRECNO		:= ALLTRIM(STR(BE4->(Recno())))
	EndIf
	
	// Verifico se existe Prorrogação de Internação. Pois a impressão tem que seguir o mesmo padrão.
	If BQV->(MsSeek(xFilial('BQV')+cCodOpe+cAnoInt+cMesInt+cNumInt))
				
		While (!BQV->(Eof()) .AND. BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == cCodOpe+cAnoInt+cMesInt+cNumInt)
		
			If BQV->BQV_AUDITO == "1" .and. BQV->BQV_STATUS == "0"
				lAudBQV	:= .T.
				cSeq		:= 	BQV->BQV_SEQUEN
			Elseif BQV->BQV_STATUS == "1"
				lAudBQV	:= .F.	
				lApvBQV	:= .T.		
				cDtProBQV := 	BQV->BQV_DATPRO				 
			EndIf
			BQV->(DbSkip())		
			
		EndDo
	EndIf
Else 
	dbSelectArea("BEA")
	BEA->(dbSetOrder(1)) //BEA_FILIAL, BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT, BEA_DATPRO, BEA_HORPRO
	
	If BE2->(MsSeek(xFilial('BE2')+cCodOpe+cAnoInt+cMesInt+cNumInt))
		cCodPro	:= BE2->BE2_CODPRO
	EndIf

	B53->(dbSetOrder(1))
		If B53->(MsSeek(xFilial("B53")+BEA->(BEA_NRLBOR)))
			lAchou	:= .T.
			dDatFim := B53->B53_DATFIM
			cRecMov	:= B53->B53_RECMOV
		EndIf

	//Posiciono na BEA SADT para saber se existe auditoria para a guia a ser impressa 
	If BEA->(MsSeek(xFilial('BEA')+cCodOpe+cAnoInt+cMesInt+cNumInt))
		cAudito 	:= BEA->BEA_AUDITO
		cStatus	:= BEA->BEA_STATUS
		cRECNO		:= ALLTRIM(STR(BEA->(Recno())))
	EndIf
	
EndIf
	
	cSQL := ""
	
	If 'MSSQL' $ AllTrim(TcGetDB())
		cSQL := "SELECT TOP 1 BVX_DATPAR "
	Else
		cSQL := "SELECT BVX_DATPAR "
	EndIf
	
	cSQL += " FROM " + RetSqlName("BVX")
	cSQL += " WHERE BVX_OPEMOV = '" + cCodOpe +"' "
	cSQL += " AND BVX_ANOAUT = '"+ cAnoInt + "' AND BVX_MESAUT = '" + cMesInt + "' AND BVX_NUMAUT = '" + cNumInt + "' "
	cSQL += " AND BVX_PARECE = '0' "
	cSQL += " ORDER BY BVX_DATPAR DESC"
	
	If 'DB2' $ AllTrim(TcGetDB())
		cSQL += " FETCH FIRST 1 ROW ONLY"
	EndIf	
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBVX",.F.,.T.)
	
	If !TrbBVX->(Eof())
		cData := StoD(TrbBVX->(BVX_DATPAR))
	EndIf
	
	TrbBVX->(DbCloseArea())
	
	if empty(cData)
	
    	cSQL := ""
    
    	If 'MSSQL' $ AllTrim(TcGetDB())
    		cSQL := "SELECT TOP 1 B72_DATMOV, B72_RECMOV, B72_CODPRO "
    	Else
    		cSQL := "SELECT B72_DATMOV, B72_RECMOV, B72_CODPRO "
    	EndIf
    	
    	cSQL += " FROM " + RetSqlName("B72")
    	cSQL += " WHERE B72_RECMOV = '" + cRecMov + "'"
    	
    	If lAudBQV
    		cSQL += " AND B72_PARECE = '0' and B72_SEQPRO = " + cSeq
    	Else
    		cSQL += " AND B72_PARECE = '0' "
    	EndIf
    		
    	cSQL += " ORDER BY B72_DATMOV"
    	
    	If 'DB2' $ AllTrim(TcGetDB())
    		cSQL += " FETCH FIRST 1 ROW ONLY"
    	EndIf	
    	
    	cSQL := ChangeQuery(cSQL)
    	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbB72",.F.,.T.)
    	
    	If !TrbB72->(Eof()) 
    		If lApvBQV
    			cData := cDtProBQV
    		Else
    			If lAchou .and. cCodPro == TrbB72->(B72_CODPRO)	
					cData:=	dDatFim
				Else
					cData:= IIF(Empty(BEA->BEA_NRLBOR),BEA->BEA_DATPRO, BEA->BEA_DATSOL)
				EndIf
    		EndIf
    	ElseIf cStatus <> "2" .and. (cAudito == "1" .Or. cStatus == "3")  
    		cData := CtoD(cData)
    	ElseIf lAudBQV .Or. lApvBQV
    		cData := cDtProBQV 
    	Else
			If lAchou .and. cCodPro == TrbB72->(B72_CODPRO)	
				cData:=	dDatFim
			Else
				cData:= IIF(Empty(BEA->BEA_NRLBOR),BEA->BEA_DATPRO, BEA->BEA_DATSOL)
			EndIf
    	EndIf
    	
    	TrbB72->(DbCloseArea())
    	
    endif              
            
Return cData



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PSRETSOL   ³ Autor ³Everton M. Fernandes³ Data ³ 08.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o CPF/CNPJ do solicitante.                        ³±±
±±³          ³                                              			   ³±±
±±³          ³                                                      	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PSRETSOL(nCampo)
Local cRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva Recnos												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nRecBAU := BAU->(Recno())
Local nOrdBAU := BAU->(IndexOrd())
Local nRecBB0 := BB0->(Recno())
Local nOrdBB0 := BB0->(IndexOrd())
Local nRecBB8 := BB8->(Recno())
Local nOrdBB8 := BB8->(IndexOrd())

DEFAULT nCampo := 1 //nCampo -> 1-Codigo; 2-Nome; 3-Cod. CNES

BB0->(dbSetOrder(4) )
BB0->(dbSeek(xFilial("BB0")+BEA->(BEA_ESTSOL+BEA_REGSOL+BEA_SIGLA)))
If  BEA->(FieldPos("BEA_RDACON")) > 0 .and. !Empty(BEA->BEA_RDACON)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Rede de Atendimento                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAU->(dbSetOrder(1))
	BAU->(dbSeek(xFilial("BAU")+BEA->BEA_RDACON))

	If nCampo == 1
		cRet := IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99")) // 13
	ElseIf nCampo == 2
		cRet := BAU->BAU_NOME // 14
	ElseIf nCampo == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Como no nosso sistema não existe local de atendimento para   ³
		//| o contratado solicitante, o CNES esta sendo enviado em branco|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BB8->(dbSetOrder(1))
		BB8->(dbSeek(xFilial("BB8")+BAU->BAU_CODIGO+BEA->(BEA_OPEMOV+BEA_CODLOC)))
		aAdd(aDados, Transform('', cPicCNES)) // 15
	EndIf

Else
	If nCampo == 1
		cRet := IIf(Len(AllTrim(BB0->BB0_CGC)) == 11, Transform(BB0->BB0_CGC, "@R 999.999.999-99"), Transform(BB0->BB0_CGC, "@R 99.999.999/9999-99")) // 13
	ElseIf nCampo == 2
		cRet := BB0->BB0_NOME // 14
	ElseIf nCampo == 3
		BB8->(dbSetOrder(1))
		BB8->(dbSeek(xFilial("BB8")+BAU->BAU_CODIGO+BEA->(BEA_OPEMOV+BEA_CODLOC)))
		cRet := Transform(BB8->BB8_CNES, cPicCNES) // 15
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetOrder(nOrdBAU))
BAU->(DbGoTo(nRecBAU))
BB0->(DbSetOrder(nOrdBB0))
BB0->(DbGoTo(nRecBB0))
BB8->(DbSetOrder(nOrdBB8))
BB8->(DbGoTo(nRecBB8))

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PSRETSOL  ³ Autor ³ Everton M. Fernandes Data ³ 08.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o CPF/CNPJ do solicitante.                        ³±±
±±³          ³                                              			   ³±±
±±³          ³                                                      	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PSRETTAB(cVlrSis,lCodTab)
Local cRet

DbSelectArea("BTU")
BTU->(DbSetOrder(4))

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PSRETINT  ³ Autor ³ Everton M. Fernandes Data ³ 08.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o tipo de internação                              ³±±
±±³          ³                                              			   ³±±
±±³          ³                                                      	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PSRETINT(cGrupInt, cTipInt)
Local cRet

	Do Case
	Case cGrupInt == "1" .And. cTipInt == "01"
		cRet := "1" // Internacao Clinica
	Case cGrupInt == "1" .And. cTipInt == "02"
		cRet := "6" // Pediatrica
	Case cGrupInt == "1" .And. cTipInt == "03"
		cRet := "7" // Psiquiatrica
	Case cGrupInt == "1" .And. cTipInt == "05"
		cRet := "3" // Internacao Obstetrica
	Case cGrupInt == "1" .And. cTipInt == "06"
		cRet := "4" // Hospital Dia
	Case cGrupInt == "1" .And. cTipInt == "07"
		cRet := "5" // Domiciliar
	Case cGrupInt == "2" .And. cTipInt == "01"
		cRet := "2" // Internacao Cirurgica
	Case cGrupInt == "2" .And. cTipInt == "03"
		cRet := "3" // Internacao Obstetrica
	Otherwise
		cRet := cGrupInt + "." + cTipInt
	EndCase
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PSCGCRDA  ³ Autor ³ Everton M. Fernandes Data ³ 08.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o CGC/CPF da RDA                                  ³±±
±±³          ³                                              			   ³±±
±±³          ³                                                      	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PSCGCRDA()
Return IIf(Len(AllTrim(BAU->BAU_CPFCGC)) == 11,Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"),Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESTIS2 ³ Autor ³ Bruno Iserhardt    ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de itens das tabelas de dominio TISS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESTIS2(cCodVinc, cCodTab, cTerminolo)
LOCAL lRet       := .T.

cChv445 := PLSPESTISS(cCodVinc, cCodTab, cTerminolo)
lRet := !Empty(cChv445)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PFileReady ³ Autor ³ Rogério Tabosa     ³ Data ³ 31.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza as verificaçoes necessarias para geraçao de       ³±±
±±³          ³ PDF pelo portal ou demais rotinas via JOB                 ³±±
±±³          ³ (Necessário para que nenhum objeto, sintaxe ou instruçao  ³±±
±±³          ³ que espera o arquivo pronto para utilização seja pra envio³±±
±±³          ³ de e-mail ou impressao no portal etc, para garantir que o ³±±
±±³          ³ arquivo estara terminado e criado na pasta.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³        ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPath - caminho do arquivo (folder)                       ³±±
±±³          ³ cFile - nome do arquivo com extensao                	   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PFileReady(cPath, cFile, nQtdLoop) 
Local nHIn := 0
Local nJ := 0
Local lInFolder := .F.
Local lKeepLoop := .T.
Local nTamAtu := 0
Local nTamRet := 0
Local nTentat := 100

Default nQtdLoop := 1000

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Primeiro o tratamento se o arquivo ja existe na pasta                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHIn := -1
nJ   := 1
While nHIn <=0 .and. nJ < nQtdLoop  
	nHIn := fopen(cPath+cFile) //somente abre quando puder abrir exclusivo
	If nHIn <> -1
		fClose(nHIn)
		lInFolder := .T. // Sei que o arquivo ja esta na pasta
		EXIT
	Endif
	sleep(1000)
	nJ++
enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para verificar se o arquivo esta pronto e terminou a criaçao  ³
// de acordo com o tamanho															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nJ   := 1
If lInFolder // Agora eu verifico se o arquivo já esta pronto comparando o tamanho dele apos o Sleep
	While lKeepLoop
		If nJ == nTentat
			lKeepLoop := .F. // sai fora na enezima tentativa
		ElseIf nJ < nTentat .and. (nTamAtu == 0 .and. nTamRet == 0) // Continua verificando o arquivo se o tamaho esta zerado ainda
			Sleep(1000) // aguarda montagem do arquivo
			nTamAtu := nTamRet
			nTamRet := PSetTamFile(cPath, cFile)
		ElseIf nTamRet > 0 .and. (nTamAtu <> nTamRet) // Continua verificando o arquivo se o tamanho anterior esta diferente do tamanho recente
			Sleep(1000) // aguarda montagem do arquivo
			nTamAtu := nTamRet
			nTamRet := PSetTamFile(cPath, cFile)
		ElseIf nTamAtu > 0 .and. (nTamAtu == nTamRet)
			lKeepLoop := .F. // o arquivo esta pronto
		EndIf
		nJ++
	EndDo
EndIf

Return()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico os tamanhos com a funçao Directory                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function PSetTamFile(cPath, cFile)
Local aFilesDir 	:= Directory(PLSMUDSIS(cPath+cFile))
Local nRet 		:= 0

If Len(aFilesDir) > 0
	nRet := aFilesDir[1,2]
EndIf
Return(nRet)

//ajuste provisorio do path do objeto - solucao de contorno ate sair o path do frame
Static Function AjusPath(oPrint)
oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"\","/",1)
oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"\","/",1)
oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"//","/",1)
oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"//","/",1)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSDACMB  ³ Autor ³ Bruno Iserhardt       ³ Data ³ 09.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Demonst. Análise Contas Médicas )³±±
±±³          ³ TISS 3                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodRda - Código da RDA a ser processado o Relatório        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSDACMB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cLocRda , cNFSSDe, cNFSSAte,cNmTitPg,cPEGDe, cPEGAte, lSoGlosas)

Local aCpo02,aCpo05,aCpo06,aCpo07,aCpo08,aCpo09,aCpo10, aCpo11, aCpo12, aCpo13, aCpo14, aCpo15
local aCpo16, aCpo17, aCpo18, aCpo19, aCpo20, aCpo21, aCpo22, aCpo23, aCpo24, aCpo25, aCpo26
local aCpo27, aCpo28, aCpo29, aCpo30, aCpo31, aCpo32, aCpo33, aCpo46
Local aDados 			:= {}
Local aValProc			:= {}
Local ADadosT			:= {}

Local nInd1,nInd2,nInd3 := 0
local nInfGui 			:= 0
Local nProcGui 			:= 0
LOCAL nLibGui   		:= 0
LOCAL nGloGui   		:= 0
LOCAL nInfFat   		:= 0
LOCAL nProcFat  		:= 0
LOCAL nLibFat  			:= 0
LOCAL nGloFat   		:= 0
LOCAL nInfGer   		:= 0
LOCAL nProcGer  		:= 0
LOCAL nLibGer   		:= 0
LOCAL nGloGer   		:= 0
Local nIndValPro		:= 0
local nPercen			:= 0

LOCAL cNmLotPg			:= ""
LOCAL cRdaLote			:= ""
Local cDescri  			:= ""
Local cCodPro  			:= ""
Local cSQL				:= ""
local cSqlAux 			:= ""

LOCAL lAchouUm 			:= .F.
Local lFlag	   			:= .F.
Local lInter   			:= .F.
Local lHouveGlosaGuia	:= .F.
Local lHouveGlosaItem 	:= .F.
Local lAglutTPA			:= GetNewPar("MV_PLACTPA",.F.)
Local cCodOpeLote		:= ""

local cCodGlo 			:= ""
local cGloGui 			:= ""
local cGloPeg 			:= ""
local cDataIniF			:= ""
local cDataFimF			:= ""

Local cCodLDPExc		:= GetNewPar("MV_PLEXDAC", "")
Local aCpo48	:= {}

DEFAULT cLocRda 	 	:= ""
DEFAULT cNFSSDe 		:= ""
DEFAULT cNFSSAte 	 	:= ""
DEFAULT cNmTitPg 		:= ""
DEFAULT cPEGDe			:= " "
DEFAULT cPEGAte			:= Replicate("Z",Len(BD7->BD7_CODPEG))
DEFAULT cAno			:= ""
DEFAULT cMes			:= "" //No caso da solicitação vir de WebService TISS, não temos no xml a informação de data da solicitação de mes e ano
DEFAULT lSoGlosas		:= .F.

//Peg Final não pode ser em branco.
If Empty(cPEGAte)
	cPEGAte := Replicate("Z",Len(BD7->BD7_CODPEG))
Endif

DBSELECTAREA("SE2")

//Variaveis para buscar o BMR pelo numero do titulo.
If !Empty(cNmTitPg)
	SE2->(dbSetorder(01))
	If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
		//cCodOpe  := SE2->E2_PLOPELT
		
		cCodOpeLote := SE2->E2_PLOPELT
		
		cNmLotPg := SE2->E2_PLLOTE
		cRdaLote := SE2->E2_CODRDA
		cAno 	 := SE2->E2_ANOBASE
		cMes	 := SE2->E2_MESBASE
	Endif
Endif

if !empty(cCodLDPExc)
	cCodLDPExc := ConvStr(cCodLDPExc)
endif
//Busca itens da BD7
cSQL := "SELECT BD7_CODUNM, BD7_CODEMP, BD7_CODLDP, BD7_CODOPE, BD7_CODPAD, BD7_CODPEG, BD7_CODPRO, BD7_CODRDA, BD7_CODTPA, BD7_DATPRO, BD7_MATRIC, BD7_NOMRDA, BD7_NOMUSR, BD7_NUMERO, BD7_NUMLOT, BD7_OPELOT, BD7_ORIMOV, BD7_SEQUEN, BD7_TIPREG, BD7_MOTBLO, BD7_VLRMAN, BD7_VLRPAG, BD7_VLRAPR, BD7_VLRGLO, BD7_VLRBPR, BD7_PERCEN, BD7_ANOPAG, BD7_MESPAG, BD7_TIPGUI, BD7_VALORI, BD7_VLTXAP, BD7_VLTXPG, BD7_VLRGTX, " + RetSqlName("BD7") + ".R_E_C_N_O_ AS RECNO "
cSQL += "  FROM " + RetSqlName("BD7")
cSql += " RIGHT JOIN " + RetSqlName("BCI") + " BCI ON "
cSQL += " BCI_FILIAL = '" + xFilial("BCI") + "' AND "
cSQL += " BCI_OPERDA = '" + cCodOpe + "' AND "
cSQL += " BCI_CODLDP = BD7_CODLDP AND "
cSQL += " BCI_CODPEG = BD7_CODPEG AND "
cSQL += " (BCI_CODRDA >= '" + cRdaDe + "' AND BCI_CODRDA <= '" + cRdaAte + "' ) AND "
if (!empty(cAno))
	cSQL += " BCI_ANO = '" + cAno + "' AND "
endif
if (!empty(cMes))
	cSQL += " BCI_MES = '" + cMes + "' AND "
endif
cSQL += " BCI_FASE IN ('2','3','4') AND "
cSQL += " BCI_CODLDP NOT IN ('" + PLSRETLDP(4) + "','" + PLSRETLDP(9) + "'" + cCodLDPExc + " ) AND "
cSQL += " BCI_SITUAC = '1' AND "
cSQL += " BCI.D_E_L_E_T_ = ' ' "

cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "

if !empty(cCodOpeLote)
	cSQL += " BD7_OPELOT = '"+cCodOpeLote+"' AND "
endif

cSQL += " BD7_CODOPE = '"+cCodOpe+"' AND "
cSQL += "( BD7_CODPEG >= '" + cPEGDe    + "' AND BD7_CODPEG <= '" + cPEGAte + "' ) AND "

If !Empty(cNmLotPg)
	cSQL += "BD7_CODRDA = '"+ cRdaLote +"' AND "
	cSQL += "BD7_NUMLOT = '"+ cNmLotPg +"' AND "
Else
	If BD7->(FieldPos("BD7_SEQNFS")) > 0 .and. !Empty(cNFSSAte)
		cSQL += "( BD7_SEQNFS >= '"+cNFSSDe+"' AND BD7_SEQNFS <= '"+cNFSSAte+"' ) AND "
		cSQL += "BD7_FASE IN ('3','4') AND "
	Endif
Endif

cSQL += " BD7_SITUAC = '1' AND " //Somente guias ativas, exclui as canceladas/bloqueadas
cSQL += "( BD7_CODRDA >= '" + cRdaDe + "' AND BD7_CODRDA <= '" + cRdaAte + "' ) AND "
cSql += RetSQLName("BD7")+".D_E_L_E_T_ = ' '"
cSQL += " ORDER BY BD7_NUMLOT, BD7_CODRDA, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_SEQUEN, BD7_CODPRO, BD7_CODTPA "

PlsQuery(cSQL,"TrbBD7")

//Iteração nos registros obtidos.
while !TrbBD7->(Eof())
	//Inicializa campos para relatório
	aCpo02 := {}
	aCpo05 := {}
	aCpo06 := {}
	aCpo07 := {}
	aCpo08 := {}
	aCpo09 := {}
	aCpo10 := {}
	aCpo11 := {}
	aCpo12 := {}
	aCpo13 := {}
	aCpo14 := {}
	aCpo15 := {}
	aCpo16 := {}
	aCpo17 := {}
	aCpo18 := {}
	aCpo19 := {}
	aCpo20 := {}
	aCpo21 := {}
	aCpo22 := {}
	aCpo23 := {}
	aCpo24 := {}
	aCpo25 := {}
	aCpo26 := {}
	aCpo27 := {}
	aCpo28 := {}
	aCpo29 := {}
	aCpo30 := {}
	aCpo31 := {}
	aCpo32 := {}
	aCpo33 := {}
	aCpo34 := {}
	aCpo35 := {}
	aCpo36 := {}
	aCpo37 := {}
	aCpo38 := {}
	aCpo39 := {}
	aCpo46 := {}
	aCpo48 := {}
	lInter := .F.
	
	nInfGer  := 0
	nProcGer := 0
	nLibGer  := 0
	nGloGer  := 0
	
	//Posiciona na BA0 - Operadoras de Saude
	BA0->(dbSetOrder(1))
	BA0->(msSeek(xFilial("BA0")+TrbBD7->(BD7_CODOPE)))
	
	//Posiciona na BAU - Redes de Atendimento
	BAU->(dbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+TrbBD7->(BD7_CODRDA)))
	
	//Posiciona na BCL - Tipos de Guia
	BCL->( DbSetOrder(1) )
	BCL->(MsSeek(xFilial("BCL")+TrbBD7->(BD7_CODOPE+BD7_TIPGUI)))
	_cAlias := Alltrim(BCL->BCL_ALIAS)
			
	//Posiciona Contas Medicas - tipo de guia	
	If _cAlias == "BE4"
		//Internação
		lInter := .T.
		BE4->(DbSetOrder(1)) //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
		BE4->(MsSeek(xFilial('BE4')+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))
		cCodLoc := BE4->BE4_CODLOC		
	Else
		//Atendimento (BD5)
		BD5->(dbSetOrder(1)) //BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA, R_E_C_N_O_, D_E_L_E_T_
		BD5->(MsSeek(xFilial("BD5")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))
		cCodLoc := BD5->BD5_CODLOC
	Endif
	
	//Posiciona na BB8 para pegar o CNES
	BB8->(dbSetOrder(1))
	BB8->(dbSeek(xFilial("BB8")+TrbBD7->(BD7_CODRDA+BD7_CODOPE)+cCodLoc))
		
	//*******************************
	//******** CABEÇALHO ************
	//*******************************
	aAdd(aCpo02, AllTrim(Str(Year(dDataBase)))+StrZero(Month(dDataBase), 2)+TrbBD7->(BD7_CODLDP+BD7_CODPEG))// 2-Numero do Demonstrativo
	aAdd(aCpo05, dDataBase) // 5-Data de Emissao
	aAdd(aCpo06, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) // 6-Codigo da Operadora
	aAdd(aCpo07, BAU->BAU_NOME) // 7-Nome do Contratado
	aAdd(aCpo08, IIF(!EMPTY(BB8->BB8_CNES), Transform(BB8->BB8_CNES, cPicCNES), "9999999")) // 8-Codigo CNES Obrigatório. Caso o prestador ainda não possua o código do CNES preencher o campo com 9999999.
	
	aAdd(aDados, BA0->BA0_SUSEP) // 1-Registro ANS	
	aAdd(aDados, aCpo02) //2 - Número do demonstrativo
	aAdd(aDados, BA0->BA0_NOMINT) // 3-Nome da Operadora
	aAdd(aDados, Transform(BA0->BA0_CGC, "@R 99.999.999/9999-99")) // 4-CNPJ da Operadora
	aAdd(aDados, aCpo05) //5 - Data de emissão
	aAdd(aDados, aCpo06) //6 - Codigo na operadora
	aAdd(aDados, aCpo07) //7 - Nome do contratado
	aAdd(aDados, aCpo08) //8 - Codigo CNES
				
	//***** CABEÇALHO ATÉ CAMPO 8 PREENCHIDO *******		
	//Na Web o relatorio e por local de atendimento
	If Len(AllTrim(cAno+cMes)) == 6
		If !Empty(cLocRda) .And. cCodLoc <> cLocRda
			TrbBD7->(dbSkip())
			Loop
		Endif
	EndIf

	//Zera totais
	lAchouUm := .T.

	//Se tem título de pagamento, posiciona na SE2 (contas a pagar)
	If Empty(cNmTitPg) .and. Empty(cNmLotPg)
		cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO "
		cSQL += "  FROM " + RetSQLName("SE2")
		cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cSQL += "    AND E2_PLOPELT = '" + TrbBD7->BD7_OPELOT + "'"
		cSQL += "    AND E2_PLLOTE = '" + TrbBD7->BD7_NUMLOT + "'"
		cSQL += "    AND E2_CODRDA = '" + TrbBD7->BD7_CODRDA + "'"
		cSQL += "    AND D_E_L_E_T_ = ' ' "

		PlsQuery(cSQL,"TrbSE2")

		If !TrbSE2->(Eof())
			SE2->(dbGoTo(TrbSE2->(E2_RECNO)))
		EndIf

		TrbSE2->(DbCloseArea())
	Endif

	aAdd(aCpo09,{})
	aAdd(aCpo10,{})
	aAdd(aCpo11,{})
	aAdd(aCpo12,{})
	aAdd(aCpo13,{})
	aAdd(aCpo14,{})
	aAdd(aCpo15,{})
	aAdd(aCpo16,{})
	aAdd(aCpo17,{})
	aAdd(aCpo18,{})
	aAdd(aCpo19,{})
	aAdd(aCpo20,{})
	aAdd(aCpo21,{})
	aAdd(aCpo22,{})
	aAdd(aCpo23,{})
	aAdd(aCpo24,{})
	aAdd(aCpo25,{})
	aAdd(aCpo26,{})
	aAdd(aCpo27,{})
	aAdd(aCpo28,{})
	aAdd(aCpo29,{})
	aAdd(aCpo30,{})
	aAdd(aCpo31,{})
	aAdd(aCpo32,{})
	aAdd(aCpo33,{})
	aAdd(aCpo34,{})
	aAdd(aCpo35,{})
	aAdd(aCpo36,{})
	aAdd(aCpo37,{})
	aAdd(aCpo38,{})
	aAdd(aCpo39,{})
	aAdd(aCpo48,{})
	
	nInd1 := Len(aCpo02)
	cChRDA := TrbBD7->(BD7_NUMLOT+BD7_CODRDA)
	
	//***********************************************************************
	// *************** BUSCA DE DADOS DA RDA PARA CABEÇALHO *****************
	//***********************************************************************
	Do While !TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA) == cChRDA	
		//Posiciona no protocolo/PEG do item da composição
		BCI->(dbSetOrder(5)) //BCI_FILIAL + BCI_OPERDA + BCI_CODRDA + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC                                                             
		BCI->(msSeek(xFilial("BCI")+TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)))
		
		//Posiciona na BCL - Tipos de Guia
		BCL->(MsSeek(xFilial("BCL")+TrbBD7->(BD7_CODOPE+BD7_TIPGUI)))
		_cAlias := Alltrim(BCL->BCL_ALIAS)

		aAdd(aCpo09[nInd1], BCI->BCI_LOTGUI) // 09-Numero do Lote
		aAdd(aCpo10[nInd1], BCI->BCI_CODPEG) // 10-Numero do Protocolo
		aAdd(aCpo11[nInd1], BCI->BCI_DATREC) // 11-Data do Protocolo
		if(!empty(allTrim(BCI->(BCI_CODGLO))))
			cGloPeg := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  BCI->(BCI_CODGLO) )
		endif
		aAdd(aCpo12[nInd1], iif(empty(cGloPeg), iif(!empty(allTrim(BCI->(BCI_CODGLO))), retCodGlo(TrbBD7->(BD7_CODOPE), BCI->BCI_CODGLO), "" ), cGloPeg )) // 12-Codigo da Glosa do Protocolo
		aAdd(aCpo13[nInd1], IIF(Empty(PLSIMPVINC('BCT', '47', BCI->BCI_FASE)), BCI->BCI_STTISS, PLSIMPVINC('BCT', '47', BCI->BCI_FASE))) // 13 - Código da Situação do Protocolo

		aAdd(aCpo14[nInd1], {})
		aAdd(aCpo15[nInd1], {})
		aAdd(aCpo16[nInd1], {})
		aAdd(aCpo17[nInd1], {})
		aAdd(aCpo18[nInd1], {})
		aAdd(aCpo19[nInd1], {})
		aAdd(aCpo20[nInd1], {})
		aAdd(aCpo21[nInd1], {})
		aAdd(aCpo22[nInd1], {})
		aAdd(aCpo23[nInd1], {})
		aAdd(aCpo24[nInd1], {})
		aAdd(aCpo25[nInd1], {})
		aAdd(aCpo26[nInd1], {})
		aAdd(aCpo27[nInd1], {})
		aAdd(aCpo28[nInd1], {})
		aAdd(aCpo29[nInd1], {})
		aAdd(aCpo30[nInd1], {})
		aAdd(aCpo31[nInd1], {})
		aAdd(aCpo32[nInd1], {})
		aAdd(aCpo33[nInd1], {})
		aAdd(aCpo34[nInd1], {})
		aAdd(aCpo35[nInd1], {})				
		aAdd(aCpo36[nInd1], {})
		aAdd(aCpo37[nInd1], {})		
		aAdd(aCpo38[nInd1], {})		
		aAdd(aCpo39[nInd1], {})
		aAdd(aCpo48[nInd1], {})		
		
		nInd2 := Len(aCpo09[nInd1])

		nInfFat 	:= 0
		nProcFat	:= 0
		nLibFat 	:= 0
		nGloFat 	:= 0
		
		cChFat 	:= TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG)

		lHouveGlosaGuia := .F.
		lHouveGlosaItem := .F.

		//***********************************************************************************************
		// ************************************* BUSCA DE ITENS DA PEG **********************************
		//***********************************************************************************************
		Do While !TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG) ==  cChFat
			
			If _cAlias == "BE4"	
				lInter := .t.
				BE4->(MsSeek(xFilial('BE4')+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))					
			Else			
				lInter := .f.	
				BD5->(MsSeek(xFilial("BD5")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))				
			Endif
				
			lHouveGlosaGuia := (!empty(BD5->BD5_VLRGLO) .and.  BD5->BD5_VLRGLO > 0)
			
			//Posiciona BA1
			BA1->(dbSetOrder(2))
			BA1->(msSeek(xFilial("BA1")+TrbBD7->(BD7_CODOPE+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)))
			
			aAdd(aCpo14[nInd1, nInd2], &((_cAlias)->(_cAlias + "->" + _cAlias + "_NUMIMP"))) // 14-Numero da Guia no Prestador				
			aAdd(aCpo17[nInd1, nInd2], TrbBD7->BD7_NOMUSR) // 17-Nome do Beneficiario
			
			If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT)
				aAdd(aCpo18[nInd1, nInd2], BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"-"+BA1_DIGITO)	) // 18-Numero da Carteira
			Else
				aAdd(aCpo18[nInd1, nInd2], BA1->BA1_MATANT) // 18-Numero da Carteira
			EndIf
			
			aAdd(aCpo48[nInd1, nInd2], BA1->BA1_NOMSOC) // 48 - Nome Social

			cGloGui := ""
			if lInter								
				aAdd(aCpo15[nInd1, nInd2], iif(empty(BE4->(BE4_ANOINT+BE4_MESINT+BE4_NUMINT)), BE4->(BE4_CODPEG + BE4_NUMERO), BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))  // 15-Numero da Guia Atribuido pela Operadora					
				aAdd(aCpo16[nInd1, nInd2], BE4->(BE4_SENHA)) // 16-Senha
				
				//Verifica se campo hora está no formato correto
				if ":" $ BE4->(BE4_HRINIF)
					cHoraInif := BE4->(BE4_HRINIF)
				else
					cHoraInif := SubStr(BE4->(BE4_HRINIF),1,2) + ":" + SubStr(BE4->(BE4_HRINIF),3,2)						
				endif
										
				if ":" $ BE4->(BE4_HRFIMF)
					cHoraFimF := BE4->(BE4_HRFIMF)
				else
					cHoraFimF := SubStr(BE4->(BE4_HRFIMF),1,2) + ":" + SubStr(BE4->(BE4_HRFIMF),3,2)						
				endif

				// formatamos para o padrão solicitado pela tiss
				If !(EmpTy(BE4->BE4_DTINIF))
					cDataIniF := DtoS(BE4->BE4_DTINIF)
					cDataIniF := substr(cDataIniF, 1, 4) + "-" + substr(cDataIniF, 5, 2) + "-" + substr(cDataIniF, 7, 2)
				endif

				If !(EmpTy(BE4->BE4_DTINIF))
					cDataFimF := DtoS(BE4->BE4_DTINIF)
					cDataFimF := substr(cDataFimF, 1, 4) + "-" + substr(cDataFimF, 5, 2) + "-" + substr(cDataFimF, 7, 2)
				endif
					
				aAdd(aCpo19[nInd1, nInd2], cDataIniF) // 19-Data do Inicio do Faturamento
				aAdd(aCpo20[nInd1, nInd2], cHoraInif) // 20-Hora do Inicio do Faturamento
				aAdd(aCpo21[nInd1, nInd2], cDataFimF) // 21-Data do Fim do Faturamento	
				aAdd(aCpo22[nInd1, nInd2], cHoraFimF) // 22-Hora do Fim do Faturamento
				if(!empty(allTrim(BE4->(BE4_CODGLO))))
					cGloGui := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  BE4->(BE4_CODGLO) )
				endif
				aAdd(aCpo23[nInd1, nInd2], iif( empty(cGloGui), iif(!empty(allTrim(BE4->(BE4_CODGLO))), retCodGlo(TrbBD7->(BD7_CODOPE), BE4->(BE4_CODGLO)), "" ) , cGloGui ) ) // 23-Codigo da Glosa da Guia
			else				
				aAdd(aCpo15[nInd1, nInd2], iif(empty(BD5->(BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)), BD5->(BD5_CODPEG+BD5_NUMERO), BD5->(BD5_CODOPE+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)) ) // 15-Numero da Guia Atribuido pela Operadora					
				aAdd(aCpo16[nInd1, nInd2], BD5->(BD5_SENHA)) // 16-Senha
					
				aAdd(aCpo19[nInd1, nInd2], CTOD("")) // 19-Data do Inicio do Faturamento
				aAdd(aCpo20[nInd1, nInd2], "") // 20-Hora do Inicio do Faturamento
				aAdd(aCpo21[nInd1, nInd2], CTOD("")) // 21-Data do Fim do Faturamento
				aAdd(aCpo22[nInd1, nInd2], "") // 22-Hora do Fim do Faturamento
				if(!empty(allTrim(BD5->(BD5_CODGLO))))
					cGloGui := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38", BD5->(BD5_CODGLO) )
				endif
				aAdd(aCpo23[nInd1, nInd2], iif( empty(cGloGui), iif(!empty(allTrim(BD5->(BD5_CODGLO))), retCodGlo(TrbBD7->(BD7_CODOPE),BD5->(BD5_CODGLO)), "" ) , cGloGui ) ) // 23-Codigo da Glosa da Guia
			endif
								
			aAdd(aCpo24[nInd1, nInd2], IIF(Empty(PLSIMPVINC('BCT', '47', BCI->BCI_FASE)), BCI->BCI_STTISS, PLSIMPVINC('BCT', '47', BCI->BCI_FASE)))//PLSIMPVINC('BCT', '47', IIF(lInter,BE4->(BE4_FASE),BD5->(BD5_FASE))))
			
			//Inicializa array para valores das guias
			aAdd(aCpo25[nInd1, nInd2], {})
			aAdd(aCpo26[nInd1, nInd2], {})
			aAdd(aCpo27[nInd1, nInd2], {})
			aAdd(aCpo28[nInd1, nInd2], {})
			aAdd(aCpo29[nInd1, nInd2], {})
			aAdd(aCpo30[nInd1, nInd2], {})
			aAdd(aCpo31[nInd1, nInd2], {})
			aAdd(aCpo32[nInd1, nInd2], {})
			aAdd(aCpo33[nInd1, nInd2], {})
			aAdd(aCpo34[nInd1, nInd2], {})
			aAdd(aCpo35[nInd1, nInd2], {})
			aAdd(aCpo36[nInd1, nInd2], {""})
			aAdd(aCpo37[nInd1, nInd2], {""})
			aAdd(aCpo38[nInd1, nInd2], {""})
			aAdd(aCpo39[nInd1, nInd2], {""})
			
			cChGuia := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
				
			nInd3 	:= Len(aCpo14[nInd1, nInd2])
			
			nInfGui := 0
			nProcGui:= 0
			nLibGui := 0
			nGloGui := 0
			dCmp25 := ""
			cCmp26 := ""
			cCmp27 := ""
			cCmp28 := ""
			cCmp29 := ""
			nCmp30 := 0
			nCmp31 := 0
			nCmp32 := 0
			nCmp33 := 0
			nCmp34 := 0
			cCmp35 := ""
			nCmp46 := 0
			cChvAux := iif(lAglutTPA, TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN), TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN+BD7_CODTPA))
			cChGuia := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)

			lHouveGlosaItem := .F.

			//*********************************************************************************************************************
			// ************* BUSCA DE ITENS DA BD7 - COMPOSIÇÃO DOS  PROCEDIMENTOS DA GUIA QUE ESTÁ NO WHILE ANTERIOR *************
			//*********************************************************************************************************************
			Do While !TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) == cChGuia										

				lHouveGlosaItem := (!empty(TrbBD7->BD7_VLRGLO) .and. TrbBD7->BD7_VLRGLO > 0)					
				
				//Posiciona na BD6 - evento dessa composição
				BD6->(dbSetOrder(1))
				BD6->(msSeek(xFilial("BD6")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)))
				cSlvPad := Posicione("BF8", 2, xFilial("BF8")+BD6->(BD6_CODPAD+BD6_CODOPE+BD6_CODTAB), "BF8_CODPAD")

				//BWT - Tipo de Participacao
				BWT->(dbSetOrder(1))
				BWT->(msSeek(xFilial("BWT")+TrbBD7->(BD7_CODOPE+BD7_CODTPA)))		
						
				//BR8 - Tabela Padrao
				BR8->(dbSetOrder(1))
				BR8->(msSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
				
				cCodPad := PLSGETVINC("BTU_CDTERM", "BR4",.F., "87", BD6->BD6_CODPAD)
				cCodPro := PLSGETVINC("BTU_CDTERM", "BR8",.F., cCodPad,BD6->BD6_CODPRO)
				cDescri := PLSGETVINC("BTQ_DESTER", "BR8",.F., cCodPad, cCodPro)
				
				//25-Data de realização
				If Empty(dCmp25)
					dCmp25 := TrbBD7->BD7_DATPRO
				EndIf				

				//26-Tabela
				If Empty(cCmp26)
					cCmp26 := cCodPad
				EndIf
				
				//27-Codigo do Prodecimento/Item assistencial
				If Empty(cCmp27)
					cCmp27 := cCodPro
				EndIf
				
				//28-Descricao
				If Empty(cCmp28)
					cCmp28 := cDescri
				EndIf

				//29-Grau de Participacao
				If !lAglutTPA .and. Empty(cCmp29)
					cCmp29 := BWT->BWT_CODEDI
				EndIf
				
				//30-Valor Informado
				if (TrbBD7->BD7_VALORI > 0 .and. (TrbBD7->BD7_PERCEN == 0 .or. TrbBD7->BD7_PERCEN == 100))
					nCmp30  := TrbBD7->BD7_VALORI + TrbBD7->BD7_VLTXAP
					nInfGui += nCmp30
				else
					nPercen := PLGETPCEN(BD6->BD6_VLRBPR, TrbBD7->BD7_VLRBPR)
								
					nCmp30  := (( BD6->BD6_VALORI * nPercen ) / 100 ) + BD6->BD6_VLTXAP
					nInfGui += nCmp30
				endif						

				//31-Quantidade Executada
				If nCmp31 == 0
					nCmp31 := BD6->BD6_QTDPRO						
				EndIf
					
				//32-Valor Processado - mesmo valor da coluna valor informado
				nCmp32   := Iif (!Empty(TrbBD7->BD7_VLRMAN),TrbBD7->BD7_VLRMAN,0) + TrbBD7->BD7_VLTXPG
				nProcGui += nCmp32 //Total processado
					
				//33-Valor Liberado
				nCmp33  := Iif (!Empty(TrbBD7->BD7_VLRPAG),TrbBD7->BD7_VLRPAG,0)
				nLibGui += nCmp33 //Total liberado 
					
				//34-Valor Glosa
				nCmp34  := Iif (!Empty(TrbBD7->BD7_VLRGLO + TrbBD7->BD7_VLRGTX), TrbBD7->BD7_VLRGLO + TrbBD7->BD7_VLRGTX, 0)
				nGloGui += nCmp34 //Total valor glosa

				//BDX - Glosas das Movimentacoes
				cCpo35 := ""
				lFlag  := .F.					
				
				// em casos que possuia mais de um BD7, porém só um deles tem valor de glosa
				// não entrava no while abaixo
				cSqlAux := " SELECT BD7_VLRGLO FROM " + RetSQLName("BD7")
				cSqlAux += " WHERE "
				cSqlAux += " BD7_FILIAL = '" + xFilial("BD7") + "' AND "
				cSqlAux += " BD7_CODOPE = '" + TrbBD7->(BD7_CODOPE) + "' AND "
				cSqlAux += " BD7_CODLDP = '" + TrbBD7->(BD7_CODLDP) + "' AND "
				cSqlAux += " BD7_CODPEG = '" + TrbBD7->(BD7_CODPEG) + "' AND "
				cSqlAux += " BD7_NUMERO = '" + TrbBD7->(BD7_NUMERO) + "' AND "
				cSqlAux += " BD7_ORIMOV = '" + TrbBD7->(BD7_ORIMOV) + "' AND "
				cSqlAux += " BD7_CODPAD = '" + TrbBD7->(BD7_CODPAD) + "' AND "
				cSqlAux += " BD7_CODPRO = '" + TrbBD7->(BD7_CODPRO) + "' AND "
				cSqlAux += " BD7_SEQUEN = '" + TrbBD7->(BD7_SEQUEN) + "' AND "
				cSqlAux += " BD7_VLRGLO > 0 AND "
				cSqlAux += " D_E_L_E_T_ = ' ' "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSqlAux),"TRBGLO",.f.,.t.)

				BDX->(dbSetOrder(1))
				If (TrbBD7->(BD7_VLRGLO) > 0 .or. TRBGLO->(BD7_VLRGLO) > 0 ) .and. BDX->(msSeek(xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)))
					Do While ! BDX->(eof()) .And. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == ;
													xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)

						BCT->(dbSetOrder(1))
						If BCT->(msSeek(xFilial("BCT")+BDX->(BDX_CODOPE+BDX_CODGLO))) .And. At(BCT->BCT_GLTISS,cCpo35)==0
							If BDX->BDX_TIPREG == "1" .Or. (BDX->BDX_CODGLO==__aCdCri049[1] .And. !lFlag)
								cCodGlo := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  BDX->BDX_CODGLO )
								if(empty(cCodGlo))
									cCodGlo := AllTrim(BCT->BCT_GLTISS)
								endif
								cCpo35 += IIf(Empty(cCpo35), "", ", ") + cCodGlo
							Endif
						EndIf

						If BDX->BDX_CODGLO == __aCdCri049[1]
							lFlag := .T.
						EndIf

						BDX->(dbSkip())
					EndDo
				EndIf

				TRBGLO->(DbCloseArea())
			
				//35-Codigo da Glosa
				If Empty(cCmp35)
					cCmp35 := cCpo35  
				EndIf
					
				If nCmp46 == 0
					nCmp46 := TrbBD7->RECNO
				EndIf							
						
				//Totalização da guia
				aCpo36[nInd1, nInd2, nInd3] := nInfGui	
				aCpo37[nInd1, nInd2, nInd3] := nProcGui
				aCpo38[nInd1, nInd2, nInd3] := nLibGui
				aCpo39[nInd1, nInd2, nInd3] := nGloGui
								
				//Nova implementação: parâmetro MV_PLACCOM. Se .T., continua verificando o BD7_CODTPA. Se .F., aglutina todas as composições e graus de participação na mesma linha.			
				//Aglutina/agrupa a participação e composição. Isto é, não considera o BD7_CODTPA na chave auxiliar			
				if lAglutTPA					
					//Se for opção só glosas 
					if lSoGlosas
						//Adiciono o sequencial armazenando todos os valores consolidados dos procedimentos (com glosa ou não, essa verificação será feita posteriormente)
						if len(aValProc) == 0
							aadd(aValProc, { TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN) })							
						endif
						
						//Busca no array o sequen da BD7 atual
						nPosValPro := aScan(aValProc, {|x| x[1] == TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)})
						
						if (nPosValPro > 0)
							//Adiciona os valores no índice encontrado
							if len(aValProc[nPosValPro]) >= 2 .and. len(aValProc[nPosValPro][2]) == 11
								aValProc[nPosValPro][2][6] += nCmp30  								
								aValProc[nPosValPro][2][8] += nCmp32
								aValProc[nPosValPro][2][9] += nCmp33
								aValProc[nPosValPro][2][10] += nCmp34
								if empty(aValProc[nPosValPro][2][11]) .and. !empty(cCmp35)
									aValProc[nPosValPro][2][11] := cCmp35
								endif
							else
								aadd(aValProc[nPosValPro],;
									{	dCmp25,;
										cCmp26,;
										cCmp27,;
										cCmp28,;
										cCmp29,;
										nCmp30,;
										nCmp31,;
										nCmp32,;
										nCmp33,;
										nCmp34,;
										cCmp35 })
							endif
						else
							aadd(aValProc,;
								{	TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN),;
									{	dCmp25,;
										cCmp26,;
										cCmp27,;
										cCmp28,;
										cCmp29,;
										nCmp30,;
										nCmp31,;
										nCmp32,;
										nCmp33,;
										nCmp34,;
										cCmp35 }})
						endif
						
						//Armazena a chave da composição atual para comparar com o próximo
						cChvAux := TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)					
						
						//Loop e verificação se está finalizado											
						TrbBD7->(dbSkip())
						If TrbBD7->(EoF()) .or. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) <> cChGuia
							//Percorre cada item do array para preencher os dados dos procedimentos da guia dentro da PEG
							for nIndValPro := 1 to len(aValProc)
								if aValProc[nIndValPro][2][10] > 0
									aAdd(aCpo25[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][1])
									aAdd(aCpo26[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][2])
									aAdd(aCpo27[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][3])
									aAdd(aCpo28[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][4])
									aAdd(aCpo29[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][5])
									aAdd(aCpo30[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][6])
									aAdd(aCpo31[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][7])
									aAdd(aCpo32[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][8])
									aAdd(aCpo33[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][9])
									aAdd(aCpo34[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][10])
									aAdd(aCpo35[nInd1, nInd2, nInd3],aValProc[nIndValPro][2][11])
								endif								
							next nIndValPro
							
							//Limpa array para o próximo
							aValProc := NIL
							aValProc := {}
						endif						
						
						//Zera tudo para o próximo					
						dCmp25 := ""
						cCmp26 := ""
						cCmp27 := ""
						cCmp28 := ""
						cCmp29 := ""
						nCmp30 := 0
						nCmp31 := 0
						nCmp32 := 0
						nCmp33 := 0
						nCmp34 := 0
						cCmp35 := ""
						nCmp46 := 0
							
						//Loop para percorrer os BD7
						if !TrbBD7->(EoF())
							Loop
						endif							
					Else											
						//Se o último incluído no relatório for diferente do sequencial atual, inclui no relatório. 
						If cChvAux != TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN) .OR. ;
							len(aCpo25[nInd1, nInd2, nInd3]) = 0 .OR.;
							TrbBD7->(Eof())
							
							aAdd(aCpo25[nInd1, nInd2, nInd3],dCmp25)
							aAdd(aCpo26[nInd1, nInd2, nInd3],cCmp26)
							aAdd(aCpo27[nInd1, nInd2, nInd3],cCmp27)
							aAdd(aCpo28[nInd1, nInd2, nInd3],cCmp28)
							aAdd(aCpo29[nInd1, nInd2, nInd3],cCmp29)
							aAdd(aCpo30[nInd1, nInd2, nInd3],nCmp30)
							aAdd(aCpo31[nInd1, nInd2, nInd3],nCmp31)
							aAdd(aCpo32[nInd1, nInd2, nInd3],nCmp32)
							aAdd(aCpo33[nInd1, nInd2, nInd3],nCmp33)
							aAdd(aCpo34[nInd1, nInd2, nInd3],nCmp34)
							aAdd(aCpo35[nInd1, nInd2, nInd3],cCmp35)
							aAdd(aCpo46,nCmp46)
							dCmp25 := ""
							cCmp26 := ""
							cCmp27 := ""
							cCmp28 := ""
							cCmp29 := ""
							nCmp30 := 0
							nCmp31 := 0
							nCmp32 := 0
							nCmp33 := 0
							nCmp34 := 0
							cCmp35 := ""
							nCmp46 := 0
							
							//cChvAux := TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)						
						Else
							//Se for o mesmo sequencial que o anterior, acumula o valor na linha do sequencial (somando os graus de participação)
							nTamItens := len(aCpo30[nInd1,nInd2,nInd3])
							
							aCpo30[nInd1, nInd2, nInd3, nTamItens] += nCmp30
							aCpo32[nInd1, nInd2, nInd3, nTamItens] += nCmp32
							aCpo33[nInd1, nInd2, nInd3, nTamItens] += nCmp33
							aCpo34[nInd1, nInd2, nInd3, nTamItens] += nCmp34
							if empty(aCpo35[nInd1, nInd2, nInd3, nTamItens]) .and. !empty(cCmp35)
								aCpo35[nInd1, nInd2, nInd3, nTamItens] := cCmp35
							endif
							
							//Zera tudo para o próximo					
							dCmp25 := ""
							cCmp26 := ""
							cCmp27 := ""
							cCmp28 := ""
							cCmp29 := ""
							nCmp30 := 0
							nCmp31 := 0
							nCmp32 := 0
							nCmp33 := 0
							nCmp34 := 0
							cCmp35 := ""
							nCmp46 := 0									
						Endif
							
						cChvAux := TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)
					EndIf
					
				else
					//Não aglutina, preenche todos as linhas de acordo com o grau de participação dentro do procedimento (BD7_CODTPA)
					//Checagens para considerar o registro no relatório ou não:
					//Se for somente glosas e o registro não tiver nenhuma glosa, não é adicionado no relatório, porem os valores são somados
					//Caso contrário, se o grau de participação for diferente do anterior, adiciona nova linha no relatório
					//Se for o mesmo grau de participação do anterior, apenas soma os valores (consolidando a participação), não incluindo um novo registro.						
					
					if lSoGlosas .and. (!lHouveGlosaItem .or. !lHouveGlosaGuia)
						if len(aCpo25[nInd1, nInd2, nInd3]) == 0 .or. (cChvAux != TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN+BD7_CODTPA))							
							//Zera tudo para o próximo					
							dCmp25 := ""
							cCmp26 := ""
							cCmp27 := ""
							cCmp28 := ""
							cCmp29 := ""
							nCmp30 := 0
							nCmp31 := 0
							nCmp32 := 0
							nCmp33 := 0
							nCmp34 := 0
							cCmp35 := ""
							nCmp46 := 0
							
							cChvAux := TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN+BD7_CODTPA)										
							TrbBD7->(dbSkip())
							Loop					
						endif			
					endif
					
					If len(aCpo25[nInd1, nInd2, nInd3]) = 0 .Or.;
						cChvAux != TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN+BD7_CODTPA) .Or.;
						TrbBD7->(Eof())
						
						aAdd(aCpo25[nInd1, nInd2, nInd3],dCmp25)
						aAdd(aCpo26[nInd1, nInd2, nInd3],cCmp26)
						aAdd(aCpo27[nInd1, nInd2, nInd3],cCmp27)
						aAdd(aCpo28[nInd1, nInd2, nInd3],cCmp28)
						aAdd(aCpo29[nInd1, nInd2, nInd3],cCmp29)
						aAdd(aCpo30[nInd1, nInd2, nInd3],nCmp30)
						aAdd(aCpo31[nInd1, nInd2, nInd3],nCmp31)
						aAdd(aCpo32[nInd1, nInd2, nInd3],nCmp32)
						aAdd(aCpo33[nInd1, nInd2, nInd3],nCmp33)
						aAdd(aCpo34[nInd1, nInd2, nInd3],nCmp34)
						aAdd(aCpo35[nInd1, nInd2, nInd3],cCmp35)
						aAdd(aCpo46,nCmp46)
						dCmp25 := ""
						cCmp26 := ""
						cCmp27 := ""
						cCmp28 := ""
						cCmp29 := ""
						nCmp30 := 0
						nCmp31 := 0
						nCmp32 := 0
						nCmp33 := 0
						nCmp34 := 0
						cCmp35 := ""
						nCmp46 := 0
					Else
						nTamItens := len(aCpo30[nInd1,nInd2,nInd3])
						
						aCpo30[nInd1, nInd2, nInd3, nTamItens] += nCmp30
						aCpo32[nInd1, nInd2, nInd3, nTamItens] += nCmp32
						aCpo33[nInd1, nInd2, nInd3, nTamItens] += nCmp33
						aCpo34[nInd1, nInd2, nInd3, nTamItens] += nCmp34
						
						//Zera tudo para o próximo					
						dCmp25 := ""
						cCmp26 := ""
						cCmp27 := ""
						cCmp28 := ""
						cCmp29 := ""
						nCmp30 := 0
						nCmp31 := 0
						nCmp32 := 0
						nCmp33 := 0
						nCmp34 := 0
						cCmp35 := ""
						nCmp46 := 0									
					Endif
						
					cChvAux := TrbBD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN+BD7_CODTPA)
				
				endif				
														
				TrbBD7->(dbSkip())
			EndDo//Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) ==  cChGuia
			
			//Adiciona totais da guia ao total da PEG
			nInfFat += nInfGui
			nProcFat += nProcGui
			nLibFat += nLibGui
			nGloFat += nGloGui
			
		Enddo//Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG) ==  cChFat
				
		//Adiciona totais do PEG ao total geral da fatura
		nInfGer += nInfFat	//44-Valor informado Fatura
		nProcGer += nProcFat	//45-Valor Processado Fatura
		nLibGer += nLibFat	//46-Valor Liberado Fatura
		nGloGer += nGloFat	//47-Valor Glosa Fatura
		
	EndDo//Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA) ==  cChRDA
		
	aAdd(aDados, aCpo09)
	aAdd(aDados, aCpo10)
	aAdd(aDados, aCpo11)
	aAdd(aDados, aCpo12)
	aAdd(aDados, aCpo13)
	aAdd(aDados, aCpo14)
	aAdd(aDados, aCpo15)
	aAdd(aDados, aCpo16)
	aAdd(aDados, aCpo17)
	aAdd(aDados, aCpo18)
	aAdd(aDados, aCpo19)
	aAdd(aDados, aCpo20)
	aAdd(aDados, aCpo21)
	aAdd(aDados, aCpo22)
	aAdd(aDados, aCpo23)
	aAdd(aDados, aCpo24)
	aAdd(aDados, aCpo25)
	aAdd(aDados, aCpo26)
	aAdd(aDados, aCpo27)
	aAdd(aDados, aCpo28)
	aAdd(aDados, aCpo29)
	aAdd(aDados, aCpo30)
	aAdd(aDados, aCpo31)
	aAdd(aDados, aCpo32)
	aAdd(aDados, aCpo33)
	aAdd(aDados, aCpo34)
	aAdd(aDados, aCpo35)
	
	//Guia
	aAdd(aDados, aCpo36)	//36-Valor Informado da Guia
	aAdd(aDados, aCpo37)	//37-Valor Processado da Guia
	aAdd(aDados, aCpo38)	//38-Valor Liberado da Guia
	aAdd(aDados, aCpo39)	//39-Valor Glosa da Guia
	
	//PEG
	aAdd(aDados, nInfFat)	//40-Valor Informado do Protocolo
	aAdd(aDados, nProcFat)	//41-Valor Processado do Protocolo
	aAdd(aDados, nLibFat)	//42-Valor Liberado do Protocolo
	aAdd(aDados, nGloFat)	//43-Valor Glosa Protocolo
	
	//Geral
	aAdd(aDados, nInfGer)	//44-Valor informado Fatura
	aAdd(aDados, nProcGer)	//45-Valor Processado Fatura
	aAdd(aDados, nLibGer)	//46-Valor Liberado Fatura
	aAdd(aDados, nGloGer)	//47-Valor Glosa Fatura
	
	aAdd(aDados, aCpo46) 	//48-recnos
	aAdd(aDados, aCpo48)	//49-Nome social (campo 48 do relatório)

	aadd(ADadosT,ADados)
	aDados := {}
	//Não encontrou dados
	If !lAchouUm
		aDados := {}
		ADadosT:={}
	EndIf
Enddo

TrbBD7->(DbCloseArea())

Return ADadosT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AddTBrush ³ Autor ³ Bruno Iserhardt       ³ Data ³ 03.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria um retângulo se a chave estiver habilitada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AddTBrush(oPrint, nLinIni, nColIni, nLinFim, nColFim, clrColor)
Default clrColor := CLR_GRAY
If (GETMV("MV_PLFCTIS") == .T.)
	oPrint:FillRect( {nLinIni, nColIni, nLinFim, nColFim}, TBrush():New( , clrColor ) )
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSDPGTODB³ Autor ³ Bruno Iserhardt       ³ Data ³ 11.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dados Relatório TISS (Guia Odontológica - Demon. Pagamento )³±±
±±³          ³ TISS 3                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodOpe - Código da Operadora                               ³±±
±±³          ³ cRdaDe  - Código da RDA a ser processada (de)               ³±±
±±³          ³ cRdaAte - Código da RDA a ser processada (Até)              ³±±
±±³          ³ cAno    - Informe o Ano a ser processado                    ³±±
±±³          ³ cMes    - Informe o Mês a ser processado                    ³±±
±±³          ³ cClaPre - Classe RDA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSDPGTODB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cNmTitPg, cDataPag)

Local aCpo08,aCpo09,aCpo10,aCpo11,aCpo12,aCpo13,aCpo14,aCpo15,aCpo16,aCpo17,aCpo18,aCpo19,aCpo20,aCpo21,aCpo22,aCpo23,aCpo30,aCpo38,aCpo39,aCpo40
Local aCpo02,aCpo03,aCpo04,aCpo05,aCpo06,aCpo07,aCpo24,aCpo25,aCpo26,aCpo27,aCpo28,aCpo29,aCpo31,aCpo32,aCpo33,aCpo34,aCpo35,aCpo36,aCpo37,aCpo41
Local aCpo42,aCpo43,aCpo44,aCpo45,aCpo46,aCpo47,aCpo48,aCpo49,aCpo50,aCpo51,aCpo52,aCpo53,aCpo54,aCpo55,aCpo56,aCpo57,aCpo58,aCpo59,aCpo60,aCpo61
Local aCpo62
Local nInd1, nInd2 , nInd3
Local nCont:=0
Local nValorDC 	:= 0
Local aDados
Local cSQL, cSQL1
Local nDeb,nCred,nDebNT,nCredNT
Local nProcGui,nGloGui,nLibGui
Local nProcLot,nGloLot,nLibLot
Local nProcGer,nGloGer,nLibGer
Local cChRDA,cChLot,cChGuia
LOCAL cNmLotPg		:= ""
LOCAL cRdaLote		:= ""
Local lRecGlo	:= .F.
local cChaProc := ""
local cCpo23 := ""
DEFAULT cNmTitPg 	:= ""
Default cDataPag 	:= "" 

aDados := {}
DBSELECTAREA("SE2")
// Variaveis para buscar o BMR pelo numero do titulo.
If !Empty(cNmTitPg)
	SE2->(dbSetorder(01))
	If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
		cCodOpe  := SE2->E2_PLOPELT
		cNmLotPg := substr(SE2->E2_PLLOTE,7,4) //SE2->E2_PLLOTE
		cRdaLote := SE2->E2_CODRDA
		cAno	 := SE2->E2_ANOBASE
		cMes	 := SE2->E2_MESBASE	
		// SA2 - Cadastro de Fornecedores
		SA2->(dbSetOrder(1))
		SA2->(msSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
	Endif
Endif

cSQL := "SELECT BMR_ANOLOT, BMR_CODLAN, BMR_CODRDA, BMR_DEBCRE, BMR_FILIAL, BMR_MESLOT, BMR_NUMLOT, BMR_OPELOT, BMR_OPERDA, BMR_VLRPAG"
cSQL += "  FROM " + RetSqlName("BMR")
If !Empty(cDataPag)
	cSQL += "INNER JOIN " + RetSqlName("BAF") + " BAF ON "
	cSQL += "BMR_ANOLOT = BAF_ANOLOT AND BMR_MESLOT = BAF_MESLOT AND BMR_NUMLOT = BAF_NUMLOT AND BAF_DTDIGI = '" + cDataPag + "' AND BAF.D_E_L_E_T_ = '' "
Endif
cSQL += " WHERE BMR_FILIAL = '" + xFilial("BMR") + "' AND "
cSQL += " BMR_OPELOT = '" + cCodOpe + "' AND "

If !Empty(cNmLotPg)
	cSQL += " BMR_CODRDA = '" + cRdaLote + "' AND "
	cSQL += " BMR_NUMLOT = '" + cNmLotPg + "' AND "

Else
	cSQL += " ( BMR_CODRDA >= '" + cRdaDe    + "' AND BMR_CODRDA <= '" + cRdaAte    + "' ) AND "

Endif
cSQL += " BMR_ANOLOT = '" + cAno + "' AND "
cSQL += " BMR_MESLOT = '" + cMes + "' AND "

cSql += RetSQLName("BMR")+".D_E_L_E_T_ = ' '"
cSQL += " ORDER BY BMR_FILIAL, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT, BMR_OPERDA, BMR_CODRDA, BMR_CODLAN "

PlsQuery(cSQL,"TrbBMR")

// BA0 - Operadoras de Saude
BA0->(dbSetOrder(1))
BA0->(msSeek(xFilial("BA0")+TrbBMR->(BMR_OPERDA)))

Do While ! TrbBMR->(Eof())
	nValorDC := 0

	nCont+=1
	// BAU - Redes de Atendimento
	BAU->(dbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+TrbBMR->BMR_CODRDA))

	// BAF - Lotes de Pagamentos RDA
	BAF->(dbSetOrder(1))
	BAF->(msSeek(xFilial("BAF")+TrbBMR->(BMR_OPERDA+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)))
	If Empty(cNmTitPg) .and. Empty(cNmLotPg)
		cSQL := " SELECT R_E_C_N_O_ E2_RECNO,E2_VENCTO, E2_VALOR "
		cSQL += "  FROM " + RetSQLName("SE2")
		cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cSQL += "    AND E2_PLOPELT = '" + TrbBMR->BMR_OPELOT + "'"
		cSQL += "    AND E2_PLLOTE = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
		cSQL += "    AND E2_CODRDA = '" + TrbBMR->BMR_CODRDA + "'"
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		PlsQuery(cSQL,"TrbSE2")

		If ! TrbSE2->(Eof())
			SE2->(dbGoTo(TrbSE2->(E2_RECNO)))

			// SA2 - Cadastro de Fornecedores
			SA2->(dbSetOrder(1))
			SA2->(msSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
		EndIf

		TrbSE2->(DbCloseArea())
	Endif

	cSQL := "SELECT BD7_CODEMP, BD7_CODLDP, BD7_CODOPE, BD7_CODPAD, BD7_CODPEG, BD7_CODPRO, BD7_CODRDA, BD7_CODTPA, BD7_DATPRO, BD7_MATRIC, "
	cSql += "BD7_NOMRDA,BD7_NOMUSR, BD7_NUMERO, BD7_NUMLOT, BD7_OPELOT, BD7_ORIMOV, BD7_SEQUEN, BD7_TIPREG, BD7_MOTBLO, BD7_VLRGLO, BD7_VLRPAG, "
	cSql += "BD7_ANOPAG, BD7_MESPAG, BD7_ESTPRE, BD7_REGPRE, BD7_SIGLA "
	cSQL += "  FROM " + RetSqlName("BD7")
	cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "'"
	cSQL += "   AND BD7_NUMLOT = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
	cSQL += "   AND BD7_CODRDA = '" + TrbBMR->(BMR_CODRDA)+ "'"
	cSQL += "   AND D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY BD7_CODLDP, BD7_CODPEG"
	PlsQuery(cSQL,"TrbBD7")

	If nCont == 1

		aCpo02 := {}
		aCpo03 := {}
		aCpo04 := {}
		aCpo05 := {}
		aCpo06 := {}
		aCpo07 := {}
		aCpo08 := {}
		aCpo09 := {}
		aCpo10 := {}
		aCpo11 := {}
		aCpo12 := {}
		aCpo13 := {}
		aCpo14 := {}
		aCpo15 := {}
		aCpo16 := {}
		aCpo17 := {}
		aCpo18 := {}
		aCpo19 := {}
		aCpo20 := {}
		aCpo21 := {}
		aCpo22 := {}
		aCpo23 := {}
		aCpo24 := {}
		aCpo25 := {}
		aCpo26 := {}
		aCpo27 := {}
		aCpo28 := {}
		aCpo29 := {}
		aCpo30 := {}
		aCpo31 := {}
		aCpo32 := {}
		aCpo33 := {}
		aCpo34 := {}
		aCpo35 := {}
		aCpo36 := {}
		aCpo37 := {}
		aCpo38 := {}
		aCpo39 := {}
		aCpo40 := {}
		aCpo41 := {}
		aCpo42 := {}
		aCpo43 := {}
		aCpo44 := {}
		aCpo45 := {}
		aCpo46 := {}
		aCpo47 := {}
		aCpo48 := {}
		aCpo49 := {}
		aCpo50 := {}
		aCpo51 := {}
		aCpo52 := {}
		aCpo53 := {}
		aCpo54 := {}
		aCpo55 := {}
		aCpo56 := {}
		aCpo57 := {}
		aCpo58 := {}
		aCpo59 := {}
		aCpo60 := {}
		aCpo61 := {}
		aCpo62 := {}
	Endif

	nProcGer:=0
	nLibGer :=0
	nGloGer :=0

	// BDT - Calendário de Pagamento
	BDT->(dbSetOrder(1))
	BDT->(msSeek(xFilial("BDT")+TrbBD7->(BD7_CODOPE+BD7_ANOPAG+BD7_MESPAG)))

	If nCont == 1
		aAdd(aDados, BA0->BA0_SUSEP) //1 - Registro ANS
	EndIf

	aAdd(aCpo02, BAF->(BAF_ANOLOT+BAF_MESLOT+BAF_NUMLOT)) //2- Nº
	aAdd(aCpo03, BA0->BA0_NOMINT) //3 - Nome da Operadora
	aAdd(aCpo04, Transform(BA0->BA0_CGC, "@R 99.999.999/9999-99")) //4 - CNPJ Operadora
	aAdd(aCpo05, BDT->BDT_DATINI) //5 - Data de Início do Processamento
	aAdd(aCpo06, BDT->BDT_DATFIN) //6 - Data de Fim do Processamento
	aAdd(aCpo07, BAU->(BAU_CODIGO)) //7 - Código na Operadora
	aAdd(aCpo08, BAU->BAU_NOME) //8- Nome do Contratado
	aAdd(aCpo09, IIf(BAU->BAU_TIPPE == "F", Transform(BAU->BAU_CPFCGC, "@R 999.999.999-99"), Transform(BAU->BAU_CPFCGC, "@R 99.999.999/9999-99"))) //9 - CPF / CNPJ Contratado
	aAdd(aCpo10,{})
	aAdd(aCpo11,{})
	aAdd(aCpo12,{})
	aAdd(aCpo13,{})
	aAdd(aCpo14,{})
	aAdd(aCpo15,{})
	aAdd(aCpo16,{})
	aAdd(aCpo17,{})
	aAdd(aCpo18,{})
	aAdd(aCpo19,{})
	aAdd(aCpo20,{})
	aAdd(aCpo21,{})
	aAdd(aCpo22,{})
	aAdd(aCpo23,{})
	aAdd(aCpo24,{})
	aAdd(aCpo25,{})
	aAdd(aCpo26,{})
	aAdd(aCpo27,{})
	aAdd(aCpo28,{})
	aAdd(aCpo29,{})
	aAdd(aCpo30,{})
	aAdd(aCpo31,{})
	aAdd(aCpo32,{})
	aAdd(aCpo33,{})
	aAdd(aCpo34,{})
	aAdd(aCpo35,{})
	aAdd(aCpo36,{})
	aAdd(aCpo37,{})
	aAdd(aCpo38,{})
	aAdd(aCpo39,{})
	aAdd(aCpo40,{})
	aAdd(aCpo41,{})
	aAdd(aCpo42,{})
	aAdd(aCpo43,{})
	aAdd(aCpo44,{})
	aAdd(aCpo45,{})
	aAdd(aCpo46,{})
	aAdd(aCpo47,{})
	aAdd(aCpo48,{})
	aAdd(aCpo49,{})
	aAdd(aCpo50,{})
	aAdd(aCpo51,{})
	aAdd(aCpo52,{})
	aAdd(aCpo53,{})
	aAdd(aCpo54,{})
	aAdd(aCpo60,{})
	aAdd(aCpo61,{})
	aAdd(aCpo62,{})
	nInd1 := Len(aCpo02)

	nProcLot:=0
	nLibLot :=0
	nGloLot :=0
	nProcGer:=0
	nLibGer :=0
	nGloGer :=0

	cChRDA  := TrbBD7->(BD7_NUMLOT+BD7_CODRDA)
	Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA) ==  cChRDA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tabela Padrão                                    			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BR8->(dbSetOrder(1))
		BR8->(msSeek(xFilial("BR8")+TrbBD7->(BD7_CODPAD+BD7_CODPRO)))

		If BR8->BR8_ODONTO == "1"

			aAdd(aCpo10[nInd1],{})
			aAdd(aCpo11[nInd1],{})
			aAdd(aCpo12[nInd1],{})
			aAdd(aCpo13[nInd1],{})
			aAdd(aCpo14[nInd1],{})
			aAdd(aCpo15[nInd1],{})
			aAdd(aCpo16[nInd1],{})
			aAdd(aCpo17[nInd1],{})
			aAdd(aCpo18[nInd1],{})
			aAdd(aCpo19[nInd1],{})
			aAdd(aCpo20[nInd1],{})
			aAdd(aCpo21[nInd1],{})
			aAdd(aCpo22[nInd1],{})
			aAdd(aCpo23[nInd1],{})
			aAdd(aCpo24[nInd1],{})
			aAdd(aCpo25[nInd1],{})
			aAdd(aCpo26[nInd1],{})
			aAdd(aCpo27[nInd1],{})
			aAdd(aCpo28[nInd1],{})
			aAdd(aCpo29[nInd1],{})
			aAdd(aCpo30[nInd1],{})
			aAdd(aCpo31[nInd1],{})
			aAdd(aCpo32[nInd1],{})
			aAdd(aCpo33[nInd1],{})
			aAdd(aCpo34[nInd1],{})
			aAdd(aCpo35[nInd1],{})
			aAdd(aCpo36[nInd1],{})
			aAdd(aCpo37[nInd1],{})
			aAdd(aCpo60[nInd1],{})
			aAdd(aCpo61[nInd1],{})
			aAdd(aCpo62[nInd1],{})
			nInd2 := Len(aCpo10[nInd1])

			nProcLot:=0
			nLibLot :=0
			nGloLot :=0
			cChLot := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG)

			Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG) ==  cChLot
				BA1->(dbSetOrder(2))
				BA1->(msSeek(xFilial("BA1")+TrbBD7->(BD7_CODOPE+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)))

				BCI->(dbSetOrder(5))
				BCI->(msSeek(xFilial("BCI")+TrbBD7->(BD7_CODOPE+BD7_CODRDA+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)))

				BD5->(DbSetOrder(1))
				BD5->(DbSeek(xFilial("BD5")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))
				
				BVO->(DbSetOrder(2))//BVO_FILIAL+BVO_CODOPE+BVO_CODLDP+BVO_CODPEG+BVO_NUMERO+BVO_ORIMOV+BVO_SEQUEN+BVO_CODPAD+BVO_CODPRO+BVO_SEQREC                                                   
				If BVO->(DbSeek(xFilial("BVO")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)))
					lRecGlo := .T.
				Else
					lRecGlo := .F.
				EndIf
				
				aAdd(aCpo10[nInd1,nInd2], SE2->E2_VENCTO) //10 - Data do Pagamento
				aAdd(aCpo11[nInd1,nInd2], SA2->A2_BANCO) //11 - Banco
				aAdd(aCpo12[nInd1,nInd2], SA2->A2_AGENCIA) //12 - Agência
				aAdd(aCpo13[nInd1,nInd2], SA2->A2_NUMCON) //13 - Conta
				aAdd(aCpo14[nInd1,nInd2], TrbBD7->(BD7_CODLDP+BD7_CODPEG)) //14 - Número do lote
				aAdd(aCpo15[nInd1,nInd2], BCI->BCI_CODPEG) //15-Número do Protocolo
				aAdd(aCpo16[nInd1,nInd2], BD5->BD5_CODOPE+BD5->BD5_ANOAUT) //16-Número da guia no prestador
				aAdd(aCpo60[nInd1,nInd2], TrbBD7->BD7_NUMERO) //17-Número da guia atribuído pela operadora
				aAdd(aCpo61[nInd1,nInd2], Iif(lRecGlo,"S","N")) //18-Recurso
				aAdd(aCpo62[nInd1,nInd2], Posicione("BB0",4,xFilial("BB0")+TrbBD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA),"BB0_NOME")) //19-Nome do Profissional Executante
				If BA1->BA1_CODINT == BA1->BA1_OPEORI .Or. empty(BA1->BA1_MATANT)
					aAdd(aCpo17[nInd1,nInd2], BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"-"+BA1_DIGITO)	) //20 - Número da Carteira
				Else
					aAdd(aCpo17[nInd1,nInd2], BA1->BA1_MATANT) //20 - Número da Carteira
				EndIf
				aAdd(aCpo18[nInd1,nInd2], TrbBD7->BD7_NOMUSR) //21 -Nome do Beneficiário

				aAdd(aCpo19[nInd1, nInd2], {})
				aAdd(aCpo20[nInd1, nInd2], {})
				aAdd(aCpo21[nInd1, nInd2], {})
				aAdd(aCpo22[nInd1, nInd2], {})
				aAdd(aCpo23[nInd1, nInd2], {})
				aAdd(aCpo24[nInd1, nInd2], {})
				aAdd(aCpo25[nInd1, nInd2], {})
				aAdd(aCpo26[nInd1, nInd2], {})
				aAdd(aCpo27[nInd1, nInd2], {})
				aAdd(aCpo28[nInd1, nInd2], {})
				aAdd(aCpo29[nInd1, nInd2], {})
				aAdd(aCpo30[nInd1, nInd2], {})
				aAdd(aCpo31[nInd1, nInd2], {})
				nInd3 := Len(aCpo10[nInd1, nInd2])

				nProcGui:=0
				nLibGui :=0
				nGloGui :=0
				cChGuia := TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
				Do While ! TrbBD7->(Eof()) .And. TrbBD7->(BD7_NUMLOT+BD7_CODRDA+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) ==  cChGuia
					if TrbBD7->(BD7_CODPEG+BD7_CODLDP+BD7_NUMERO+BD7_SEQUEN) == cChaProc
						TrbBD7->(DbSkip())
						loop
					else
						cChaProc := TrbBD7->(BD7_CODPEG+BD7_CODLDP+BD7_NUMERO+BD7_SEQUEN)
					endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tipo de Participação                             			 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BWT->(dbSetOrder(1))
					BWT->(msSeek(xFilial("BWT")+TrbBD7->(BD7_CODOPE+BD7_CODTPA)))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tabela Padrão                                    			 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BR8->(dbSetOrder(1))
					BR8->(msSeek(xFilial("BR8")+TrbBD7->(BD7_CODPAD+BD7_CODPRO)))

					If BR8->BR8_ODONTO == "1"

						BD6->(dbSetOrder(1))
						BD6->(msSeek(xFilial("BD6")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)))

						aAdd(aCpo19[nInd1, nInd2, nInd3], Posicione("BF8", 2, xFilial("BF8")+BD6->(BD6_CODPAD+BD6_CODOPE+BD6_CODTAB), "BF8_TABTIS")) //19-Tabela
						aAdd(aCpo20[nInd1, nInd2, nInd3], TrbBD7->BD7_CODPRO) //20- Código do Procedimento
						aAdd(aCpo21[nInd1, nInd2, nInd3], BR8->BR8_DESCRI) //21 - Descrição
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona Dente/Região                             			 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BYT->(dbSetOrder(1))
						BYT->(dbSeek(xFilial("BYT")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SEQUEN)))
						aAdd(aCpo22[nInd1, nInd2, nInd3], BYT->BYT_CODIGO) //22-Dente/Região

						cSQL1 := " SELECT BE2_ANOAUT,BE2_MESAUT,BE2_NUMAUT "
						cSQL1 += "  FROM " + RetSQLName("BE2")
						cSQL1 += "  WHERE BE2_FILIAL = '" + xFilial("BE2") + "' "
						cSQL1 += "    AND BE2_OPEMOV = '" + TrbBD7->BD7_CODOPE + "'"
						cSQL1 += "    AND BE2_ANOAUT = '" + TrbBD7->BD7_ANOPAG + "'"
						cSQL1 += "    AND BE2_MESAUT = '" + TrbBD7->BD7_MESPAG + "'"
						cSQL1 += "    AND BE2_NUMERO = '" + TrbBD7->BD7_NUMERO + "'"
						cSQL1 += "    AND BE2_CODLDP = '" + TrbBD7->BD7_CODLDP + "'"
						cSQL1 += "    AND BE2_CODPEG = '" + TrbBD7->BD7_CODPEG + "'"
						cSQL1 += "    AND BE2_SEQUEN = '" + TrbBD7->BD7_SEQUEN + "'"
						cSQL1 += "    AND BE2_CODPAD = '" + TrbBD7->BD7_CODPAD + "'"
						cSQL1 += "    AND BE2_CODPRO = '" + TrbBD7->BD7_CODPRO + "'"
						cSQL1 += "    AND D_E_L_E_T_ = ' ' "

						PlsQuery(cSQL1,"TrbBE2")

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona Face		                             			 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BYS->(dbSetOrder(1))
						BYS->(dbSeek(xFilial("BYS")+BYT->BYT_CODOPE+TrbBD7->(BD7_ANOPAG+BD7_MESPAG+BD7_NUMERO)+BYT->(BYT_SEQUEN+BYT_CODIGO)))

						TrbBE2->(dbCloseArea())

						If !Empty(BYS->BYS_FACES)
							aAdd(aCpo23[nInd1, nInd2, nInd3],BYS->BYS_FACES) //23-Face
						Else
							dbSelectArea("BYT")
							BYT->(dbSetOrder(1))
							BYT->(dbSeek((xFilial("BYT")+TrbBD7->BD7_CODOPE+TrbBD7->BD7_CODLDP+TrbBD7->BD7_CODPEG+TrbBD7->BD7_NUMERO+TrbBD7->BD7_SEQUEN)))
							aAdd(aCpo23[nInd1, nInd2, nInd3],BYT->BYT_FACES) //23-Face
						EndIf

						aAdd(aCpo24[nInd1, nInd2, nInd3], TrbBD7->BD7_DATPRO) //24-Data de Realização
						aAdd(aCpo25[nInd1, nInd2, nInd3], BD6->BD6_QTDPRO) //25-Qtde
						aAdd(aCpo26[nInd1, nInd2, nInd3], 0) //26-Valor Informado(R$)
						aAdd(aCpo27[nInd1, nInd2, nInd3], BD6->BD6_VLRPAG + BD6->BD6_VLRGLO) //27-Valor Processado (R$)
						nProcGui+=BD6->BD6_VLRPAG + BD6->BD6_VLRGLO
						aAdd(aCpo28[nInd1, nInd2, nInd3], BD6->BD6_VLRGLO) //28-Valor Glosa/Estorno (R$)
						aAdd(aCpo29[nInd1, nInd2, nInd3], 0) //29- Valor Franquia( R$)
						nGloGui+=BD6->BD6_VLRGLO
						aAdd(aCpo30[nInd1, nInd2, nInd3], BD6->BD6_VLRPAG) //30-Valor Liberado (R$)
						nLibGui+=BD6->BD6_VLRPAG

						// BCT - Motivos de Glosas
						cCpo31 := ""
						BDX->(dbSetOrder(1))
						If BDX->(msSeek(xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)))
							Do While ! BDX->(eof()) .And. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == ;
								xFilial("BDX")+TrbBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)
								// BDX - Glosas das Movimentacoes
								BCT->(dbSetOrder(1))
								If BCT->(msSeek(xFilial("BCT")+BDX->(BDX_CODOPE+BDX_CODGLO)))
									If At(BCT->BCT_GLTISS, cCpo23) == 0
										cCpo31 += IIf(Empty(cCpo23), "", ",") + BCT->BCT_GLTISS
									EndIf
								EndIf
								BDX->(dbSkip())
							EndDo
						EndIf
					Endif
					aAdd(aCpo31[nInd1, nInd2, nInd3], cCpo31) //31-Código da Glosa
					TrbBD7->(dbSkip())
				EndDo

				aAdd(aCpo32[nInd1, nInd2], "") //32-Observação / Justificativa

				aAdd(aCpo33[nInd1, nInd2],0) //33- Valor Total Informado Guia (R$)
				aAdd(aCpo34[nInd1, nInd2],nProcGui) //34 - Valor Total Processado Guia (R$)
				nProcLot+=nProcGui
				aAdd(aCpo35[nInd1, nInd2],nGloGui) //35 - Valor Total Glosa Guia (R$)
				aAdd(aCpo36[nInd1, nInd2],0) //36 - Valor Total Franquia Guia (R$)
				nGloLot+=nGloGui
				aAdd(aCpo37[nInd1, nInd2],(nProcGui-nGloGui)) //37 - Valor Total Liberado Guia (R$)
				nLibLot+=(nProcGui-nGloGui)
			EndDo

			aAdd(aCpo38[nInd1],0) //38 - Valor Total Informado Protocolo (R$)
			aAdd(aCpo39[nInd1],nProcLot) //39 - Valor Total Processado Protocolo (R$)
			nProcGer+=nProcLot
			aAdd(aCpo40[nInd1],nGloLot) //40 - Valor Total Glosa Protocolo (R$)
			nGloGer+=nGloLot
			aAdd(aCpo41[nInd1],0) //41 - Valor Total Franquia Protocolo (R$)
			aAdd(aCpo42[nInd1],(nProcLot-nGloLot)) //42 - Valor Total Liberado Protocolo (R$)
			nLibGer+=(nProcLot-nGloLot)

		Endif
		TrbBD7->(dbSkip())
	EndDo

	TrbBD7->(DbCloseArea())

	aAdd(aDados, aCpo02)
	aAdd(aDados, aCpo03)
	aAdd(aDados, aCpo04)
	aAdd(aDados, aCpo05)
	aAdd(aDados, aCpo06)
	aAdd(aDados, aCpo07)
	aAdd(aDados, aCpo08)
	aAdd(aDados, aCpo09)
	aAdd(aDados, aCpo10)
	aAdd(aDados, aCpo11)
	aAdd(aDados, aCpo12)
	aAdd(aDados, aCpo13)
	aAdd(aDados, aCpo14)
	aAdd(aDados, aCpo15)
	aAdd(aDados, aCpo16)
	aAdd(aDados, aCpo17)
	aAdd(aDados, aCpo18)
	aAdd(aDados, aCpo19)
	aAdd(aDados, aCpo20)
	aAdd(aDados, aCpo21)
	aAdd(aDados, aCpo22)
	aAdd(aDados, aCpo23)
	aAdd(aDados, aCpo24)
	aAdd(aDados, aCpo25)
	aAdd(aDados, aCpo26)
	aAdd(aDados, aCpo27)
	aAdd(aDados, aCpo28)
	aAdd(aDados, aCpo29)
	aAdd(aDados, aCpo30)
	aAdd(aDados, aCpo31)
	aAdd(aDados, aCpo32)
	aAdd(aDados, aCpo33)
	aAdd(aDados, aCpo34)
	aAdd(aDados, aCpo35)
	aAdd(aDados, aCpo36)
	aAdd(aDados, aCpo37)
	aAdd(aDados, aCpo38)
	aAdd(aDados, aCpo39)
	aAdd(aDados, aCpo40)
	aAdd(aDados, aCpo41)
	aAdd(aDados, aCpo42)

	nDeb 	:= 0
	nDebNT 	:= 0
	nCred	:= 0
	nCredNT	:= 0
	nValorDC:= 0

	BGQ->(dbSetOrder(4))//BGQ_FILIAL+BGQ_CODOPE+BGQ_CODIGO+BGQ_ANO+BGQ_MES+BGQ_CODLAN+BGQ_OPELOT+BGQ_NUMLOT
	cChBMR := TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA)
	Do While ! TrbBMR->(Eof()) .And. TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA) == cChBMR

		If TrbBMR->BMR_CODLAN $ "102,103,104,105" // Debitos/Creditos Fixos e Variaveis
			BMS->(dbSetOrder(1))
			BMS->(msSeek(TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)))
			Do While ! BMS->(Eof()) .And. ;
				BMS->(BMS_FILIAL+BMS_OPERDA+BMS_CODRDA+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT+BMS_CODLAN) == ;
				TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)

				If Len(CalcImp(BMS->BMS_VLRPAG)) > 0
					aTmpCpo35 := CalcImp(BMS->BMS_VLRPAG)
					aAdd(aCpo51[nInd1], TrbBMR->BMR_DEBCRE) //51-Indicação
					aAdd(aCpo52[nInd1], TrbBMR->BMR_CODLAN) //52-Código do débito/crédito
					aAdd(aCpo53[nInd1], aTmpCpo35[1,1]) //53-Descrição do débito/crédito
					aAdd(aCpo54[nInd1], aTmpCpo35[1,2]) //54-Valor
					nValorDC += BMS->BMS_VLRPAG
				Else
					If BGQ->(MsSeek(xFilial("BGQ")+ BMS->(BMS_OPERDA + BMS_CODRDA + BMS_ANOLOT + BMS_MESLOT + BMS_CODSER + BMS_OPELOT + BMS_ANOLOT + BMS_MESLOT + BMS_NUMLOT )))
						If BGQ->BGQ_INCIR  == "1" .Or. BGQ->BGQ_INCINS == "1" .Or. BGQ->BGQ_INCPIS == "1" .Or.;
							BGQ->BGQ_INCCOF == "1" .Or. BGQ->BGQ_INCCSL == "1"
							aAdd(aCpo43[nInd1], TrbBMR->BMR_DEBCRE) //43-Indicação
							aAdd(aCpo44[nInd1], TrbBMR->BMR_CODLAN) //44-Código do débito/crédito
							aAdd(aCpo45[nInd1], Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI")) //45-Descrição do débito/crédito
							aAdd(aCpo46[nInd1], BMS->BMS_VLRPAG) //46-Valor
							If BMS->BMS_DEBCRE == "1"
								nDeb += BMS->BMS_VLRPAG
							else
								nCred += BMS->BMS_VLRPAG
							Endif
						Else
							aAdd(aCpo47[nInd1], TrbBMR->BMR_DEBCRE) //47-Indicação
							aAdd(aCpo48[nInd1], TrbBMR->BMR_CODLAN) //48-Código do débito/crédito
							aAdd(aCpo49[nInd1], Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI")) //49-Descrição do débito/crédito
							aAdd(aCpo50[nInd1], BMS->BMS_VLRPAG) //50-Valor
							If BMS->BMS_DEBCRE == "1"
								nDebNT += BMS->BMS_VLRPAG
							else
								nCredNT += BMS->BMS_VLRPAG
							Endif
						EndIf
					EndIf
				EndIf

				BMS->(dbSkip())

			EndDo
		ElseIf TrbBMR->BMR_CODLAN <> "101" .And. TrbBMR->BMR_DEBCRE <> "3"

			If Len(CalcImp(TrbBMR->BMR_VLRPAG)) > 0
				//aAdd(aCpo35[nInd1], {IIf(TrbBMR->BMR_DEBCRE == "1", "(-) ", "(+) ") + TrbBMR->BMR_CODLAN + " - " + Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN),"BLR_DESCRI"),   TrbBMR->BMR_VLRPAG })
				aTmpCpo35 := CalcImp(TrbBMR->BMR_VLRPAG)
				aAdd(aCpo51[nInd1], TrbBMR->BMR_DEBCRE) //51-Indicação
				aAdd(aCpo52[nInd1], TrbBMR->BMR_CODLAN) //52-Código do débito/crédito
				aAdd(aCpo53[nInd1], aTmpCpo35[1,1]) //53-Descrição do débito/crédito
				aAdd(aCpo54[nInd1], aTmpCpo35[1,2]) //54-Valor
				nValorDC += TrbBMR->BMR_VLRPAG
			Else
				If TrbBMR->BMR_CODLAN < "170"
					aAdd(aCpo47[nInd1], TrbBMR->BMR_DEBCRE) //47-Indicação
					aAdd(aCpo48[nInd1], TrbBMR->BMR_CODLAN) //48-Código do débito/crédito
					aAdd(aCpo49[nInd1], Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN),"BLR_DESCRI")) //49-Descrição do débito/crédito
					aAdd(aCpo50[nInd1], TrbBMR->BMR_VLRPAG) //50-Valor

					If BMS->BMS_DEBCRE == "1"
						nDebNT += TrbBMR->BMR_VLRPAG
					else
						nCredNT += TrbBMR->BMR_VLRPAG
					Endif
				Else
					aAdd(aCpo43[nInd1], TrbBMR->BMR_DEBCRE) //43-Indicação //
					aAdd(aCpo44[nInd1], TrbBMR->BMR_CODLAN) //44-Código do débito/crédito
					aAdd(aCpo45[nInd1], Posicione("BLR", 1, xFilial("BLR")+TrbBMR->(BMR_OPELOT+BMR_CODLAN),"BLR_DESCRI")) //45-Descrição do débito/crédito
					aAdd(aCpo46[nInd1], TrbBMR->BMR_VLRPAG) //46-Valor
					If TrbBMR->BMR_DEBCRE == "1"
						nDeb += TrbBMR->BMR_VLRPAG
					else
						nCred += TrbBMR->BMR_VLRPAG
					Endif
				EndIf
			EndIf
		EndIf
		TrbBMR->(dbSkip())
	EndDo

	//Demais débitos / créditos
	aAdd(aDados, aCpo43) //43-Indicação
	aAdd(aDados, aCpo44) //44-Código do débito/crédito
	aAdd(aDados, aCpo45) //45-Descrição do débito/crédito
	aAdd(aDados, aCpo46) //46-Valor

	//Demais débitos / créditos não tributáveis
	aAdd(aDados, aCpo47) //47-Indicação
	aAdd(aDados, aCpo48) //48-Código do débito/crédito
	aAdd(aDados, aCpo49) //49-Descrição do débito/crédito
	aAdd(aDados, aCpo50) //50-Valor

	//Impostos
	aAdd(aDados, aCpo51) //51-Indicação
	aAdd(aDados, aCpo52) //52-Código do débito/crédito
	aAdd(aDados, aCpo53) //53-Descrição do débito/crédito
	aAdd(aDados, aCpo54) //54-Valor

	//Totais
	aAdd(aCpo55, nCred-nDeb)
	aAdd(aDados, aCpo55) //55 - Valor Total Tributável (R$)
	aAdd(aCpo56, nValorDC)
	aAdd(aDados, aCpo56) //56- Valor Total Impostos Retidos (R$)
	aAdd(aCpo57, nCredNT-nDebNT)
	aAdd(aDados, aCpo57) //57 - Valor Total Não Tributável (R$)
	aAdd(aCpo58, ((nCred-nDeb)+(nCredNT-nDebNT)))
	aAdd(aDados, aCpo58) //58 - Valor Final a Receber (R$)

	aAdd(aCpo59, "")
	aAdd(aDados, aCpo59) //59 - Observação

	//numeroGuiaOperadora, recurso e nome do profissional executante
	aAdd(aDados, aCpo60)
	aAdd(aDados, aCpo61)
	aAdd(aDados, aCpo62)
	
EndDo
TrbBMR->(DbCloseArea())

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetProTiss³ Autor ³ Totvs                 ³ Data ³ 13.05.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna Procedimento DEPARA  							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPad - Código da Tabela Padrao                             ³±±
±±³          ³ cCodPro  - Código do Procedimento			               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetProTiss(cCodPad,cCodPro) 
Local cTabPro := GetNewPar("MV_PLTABPR","00,90,98") // Tabelas Proprias. 
Local lAchou  := .F.

BR8->(dbSetOrder(1))
BR8->(dbSeek(xFilial("BR8")+cCodPad+cCodPro))
	
cCodPad := Alltrim(BR8->BR8_CODPAD)
cCodPro := Alltrim(BR8->BR8_CODPSA)

SIX->(DbSetOrder(1))
If SIX->(MsSeek("BTU7")) 
	// Para otimizar ja vou direto BTU
	BTU->(dbSetOrder(7))//BTU_FILIAL+BTU_ALIAS+BTU_VLRSIS+BTU_CODTAB
	If BTU->(dbSeek(xFilial("BTU")+"BR8"+BR8->(BR8_FILIAL+BR8_CODPAD+BR8_CODPSA)))
		cCodPad := Alltrim(BTU->BTU_CODTAB)
		cCodPro := Alltrim(BTU->BTU_CDTERM)
		lAchou := .T.
	Endif
Endif					
If !lAchou
	BTU->(dbSetOrder(2))//BTU_FILIAL, BTU_CODTAB, BTU_ALIAS, BTU_VLRSIS					
	If BTU->(dbSeek(xFilial("BTU")+"87"+"BR4"+BR8->(BR8_FILIAL+BR8_CODPAD)))
		While !BTU->(Eof()) .And. BTU->(BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS);
			= xFilial("BTU")+"87"+"BR4"+BR8->(BR8_FILIAL+BR8_CODPAD)
		   
			cCodPad := Alltrim(BTU->BTU_CDTERM) 
			// se for tabela Propria nao tem BTQ
			If cCodPad $ cTabPro
				lAchou := .T.
			Else
				//verifica se encontra procedimento no cadastro de Itens e portanto nao necessita Depara
				BTQ->(dbSetOrder(1))//BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
				If BTQ->(dbSeek(xFilial("BTQ")+cCodPad+Alltrim(BR8->BR8_CODPSA)))
					lAchou := .T.
				Endif
			Endif
			// Se encontrou Sai Loop
			If lAchou
				Exit
			Endif
		 	BTU->(dbSkip())
		End 
	Endif	
Endif

Return({lAchou,cCodPad,cCodPro})			

/*Implementação futura - Calculo abatimento do titulo no relatorio do demonstrativo de pagamento
//Calcula abatimento do valor do lote de pagamento
Function PLCalcDemP(nVlrPrinc,nRecno)

Local  nAbatim   := 0
Local  nVlrTot   := 0

DEFAULT nVlrPrinc := 0
DEFAULT nRecno 	:= 0

if nRecno > 0
	SE2->(dbGoTo(nRecno))	
else
	return 0
endif
	
nAbatim    := SOMAABAT(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,NIL,SE2->E2_FORNECE,SE2->E2_LOJA)
           
nVlrTot    := (nVlrPrinc - nAbatim) + SE2->E2_SDACRES - SE2->E2_SDDECRE

Return(nVlrTot)
*/


//-------------------------------------------------------------------
/*/{Protheus.doc} retCodGlo
De/para com a terminologia 38 - Codigo de Glosa.

@author  Lucas Nonato
@version P12
@since   22/03/2017
/*/
//-------------------------------------------------------------------
Function retCodGlo(cCodOpe, cCodGlo)

Local cRet	:= ""

	BCT->(dbSetOrder(1))
	If BCT->(msSeek(xFilial("BCT")+cCodOpe + cCodGlo)) 	
		cRet += AllTrim(BCT->BCT_GLTISS)	
	EndIf

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRDACON
Retorna CPF/CNPJ formatado baseado na busca pelo código da RDA passado por parâmetro.

@author  Rodrigo Morgon
@version P11
@since   18.07.2017
/*/
//-------------------------------------------------------------------
Function PLSRDACON(cCodRda)

Local cRet			:= ""
Local aAreaBAU	:= BAU->(GetArea())
Default cCodRda	:= ""

cRet := Posicione("BAU",1,xFilial("BAU")+cCodRda,"BAU_CPFCGC")

RestArea(aAreaBAU)

Return IIF(LEN(ALLTRIM(cRet)) == 11,TRANSFORM(cRet,'@R 999.999.999-99'),TRANSFORM(cRet,'@R 99.999.999/9999-99'))

//converte valor para uso na query
Static function ConvStr(cCodLDPExc)
Local cret := ""
Local nI := 0
Local aConteudo := {}

aConteudo := Separa(cCodLDPExc, ",")

For nI := 1 To len(aConteudo)
	cRet += ", "
	cRet += "'" + AllTrim(aConteudo[nI]) + "'"
Next

return cRet
