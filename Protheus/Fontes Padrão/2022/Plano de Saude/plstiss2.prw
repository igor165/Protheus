#INCLUDE "plstiss.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'fileio.ch'
#DEFINE lSrvUnix IsSrvUnix()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSD  ³ Autor ³ Bruno Iserhardt       ³ Data ³ 20.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3.00.01 (Guia de Consulta )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela     ³±±
±±³          ³           de configuracao/preview do relatorio              ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		     3 - Formato Carta (216x279mm)         			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTISSD(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW)
	Local nLinMax
	Local nColMax
	Local nLinIni	:= 0	// Linha Lateral (inicial) Esquerda
	Local nColIni	:= 0	// Coluna Lateral (inicial) Esquerda
	Local nColA4  := 0   // Para implementar layout A4
	Local nLinA4  := 0   // Para implementar layout A4
	Local cFileLogo
	Local nI, nX
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local oFont05
	LOCAL cFileName	:= ""
	LOCAL cRel      := "guicons"
	LOCAL cPathSrvJ := GETMV("MV_RELT")
	LOCAL nAL		:= 0.25
	LOCAL nAC		:= 0.24
	LOCAL nLinObs	:= 0
	
	LOCAL nEsq	:= 200
	LOCAL nDist	:= 0050
	LOCAL nCamp := 0010
	LOCAL nBai 	:= (-50)
	LOCAL nDir 	:= 600
	LOCAL nAltFt  := 0020
	local nVlrAp := 0	
	
	DEFAULT lGerTXT 	:= .F.
	DEFAULT nLayout 	:= 2
	DEFAULT cLogoGH 	:= ""
	DEFAULT lWeb		:= .F.
	DEFAULT cPathRelW 	:= ""
	DEFAULT aDados := { {;
		"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- Nº Guia no Prestador
	"12345678901234567890",; //3 - Número da Guia Atribuído pela Operadora
	"12345678901234567892",; //4 - Número da Carteira
	CtoD("12/12/07"),; //5 - Validade da Carteira
	"N",; //6 – Atendimento a RN (Sim ou Não)
	Replicate("M",70),; //7 – Nome
	"123456789012345",; //8 - Cartão Nacional de Saúde
	"12345678901234",; //9- Código na Operadora
	Replicate("M",70),; //10 - Nome do Contratado
	"1234567",; //11 - Código CNES
	Replicate("M",70),; //12 - Nome do Profissional Executante
	"AA",; //13 - Conselho Profissional
	"123456789012345",; //14 - Número no Conselho
	"RS",; //15 - UF
	"123456",; //16 - Código CBO
	"A",; //17 - Indicação de Acidente(acidente ou doença relacionada)
	CtoD("12/12/07"),; //18 - Data do Atendimento
	"A",; //19 - Tipo de Consulta
	"00",; //20 - Tabela
	"1234567890",; //21 - Código do Procedimento
	11111.78,; //22 - Valor do Procedimento
	Replicate("M",100)+Replicate("A",100)+Replicate("B",100)+Replicate("D",100)+Replicate("C",100)} } //23 - Observação / Justificativa

	oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 10, 10, , .F., , , , .T., .F.) // Normal

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
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
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
	oPrint:SetLandscape()

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
		If !(oPrint:nModalResult == 1)
			Return
		Endif
	EndIf

	If oPrint:nPaperSize  == 9 // Papél A4
		nLinMax	:= 1134 //1134
		nColMax	:= 2335 //2335
		nLayout 	:= 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04	:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Elseif oPrint:nPaperSize == 1 // Papel Carta
		nLinMax	:= 0925
		nColMax	:= 2400
		nLayout 	:= 3
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		nLinMax	:= 1184
		nColMax	:= 2400
		nLayout 	:= 1
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04	:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Endif

	For nX := 1 To Len(aDados)

		If Len(aDados[nX]) == 0
			Loop
		EndIf

		If oPrint:Cprinter == "PDF" .OR. lWeb
			nLinIni	:= 065  //000
			nColIni 	:= 065  //000
		Else
			nLinIni := 100
		Endif
		nColIni := 0065
		nLinA4  := 0065 //000
		nColA4  := 0065 //000

		oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + nEsq /*0010*/ )*nAC, (nLinIni +  nDist + 500 + nLinMax)*nAL, (nColIni +nEsq + nDir + nColMax)*nAC)//(nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0040)*nAL, (nColIni + 00220 /*0020*/)*nAC, cFileLogo, (400)*nAL, (090)*nAC) // Tem que estar abaixo do RootPath
		EndIf

		if nLayout == 2 // Papél A4
			nColA4:= -0065
			nLinA4:= 0
		Elseif nLayout ==3 //Carta
			nLinA4:= -0010
		Endif

		oPrint:Say((nLinIni + 0090)*nAL + nLinA4, (nColIni + nEsq + 300 +(nColMax*0.4))*nAC, "GUIA DE CONSULTA", oFont02n,,,, 2) //"GUIA DE CONSULTA"
		oPrint:Say((nLinIni + 0090)*nAL + nLinA4, (nColIni + nEsq + 300 +(nColMax*0.67))*nAC, "2- Nº Guia no Prestador", oFont01) //"2- Nº Guia no Prestador"
		oPrint:Say((nLinIni + 0090)*nAL + nLinA4, (nColIni + nEsq + 300 +(nColMax*0.78))*nAC, aDados[nX, 02], oFont03n)
                                                           
		oPrint:Box((nLinIni + 0165)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni + 0225)*nAL + nLinA4 + nCamp, (nColIni + nEsq  + (nColMax*0.16) - 0010)*nAC)
		oPrint:Say((nLinIni + 0185)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "1 - Registro ANS", oFont01) //1 - Registro ANS
		oPrint:Say((nLinIni + 0217 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 0040)*nAC, aDados[nX, 01], oFont05)
		oPrint:Box((nLinIni + 0165)*nAL + nLinA4, (nColIni + nEsq + (nColMax*0.16))*nAC, (nLinIni + 0225)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 1440 + (nColMax*0.64) - 0010)*nAC)
		oPrint:Say((nLinIni + 0185)*nAL + nLinA4, (nColIni + nEsq + (nColMax*0.16) + 0010)*nAC, "3 - Número da Guia Atribuído pela Operadora", oFont01) //3 - Número da Guia Atribuído pela Operadora
		oPrint:Say((nLinIni + 0217)*nAL + nLinA4, (nColIni + nEsq + (nColMax*0.16) + 0020)*nAC, aDados[nX, 03], oFont05)
                                                            
		oPrint:Say((nLinIni + nDist + 0245)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, "Dados do Beneficiário", oFont01) //Dados do Beneficiário
		oPrint:Box((nLinIni + nDist + 0255)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni + nDist + 0315)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 862 + (nColMax*0.48) - 0010)*nAC)
		oPrint:Say((nLinIni + nDist + 0275)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "4 - Número da Carteira", oFont01) //4 - Número da Carteira
		oPrint:Say((nLinIni + nDist + 0307 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 0040)*nAC, aDados[nX, 04], oFont05)
		oPrint:Box((nLinIni + nDist + 0255)*nAL + nLinA4, (nColIni + nEsq + 862 + (nColMax*0.48))*nAC, (nLinIni + nDist + 0315)*nAL + nLinA4+ nCamp, (nColIni + nEsq + 862 + (nColMax*0.70) - 0010)*nAC)
		oPrint:Say((nLinIni + nDist + 0275)*nAL + nLinA4, (nColIni + nEsq + 862 + (nColMax*0.48) + 0010)*nAC, "5 - Validade da Carteira", oFont01) //5 - Validade da Carteira
		oPrint:Say((nLinIni + nDist + 0307 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 862 + (nColMax*0.48) + 0020)*nAC, DtoC(aDados[nX, 05]), oFont05)
		oPrint:Box((nLinIni + nDist + 0255)*nAL + nLinA4, (nColIni + nEsq + 862 + (nColMax*0.70))*nAC, (nLinIni + nDist + 0315)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 862 + (nColMax*0.92) - 0090)*nAC)
		oPrint:Say((nLinIni + nDist + 0275)*nAL + nLinA4, (nColIni + nEsq + 862 + (nColMax*0.70) + 0010)*nAC, "6 - Atendimento a RN (Sim ou Não)", oFont01) //6 - Atendimento a RN (Sim ou Não)
		oPrint:Say((nLinIni + nDist + 0307 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 862 + (nColMax*0.70) + 0020)*nAC, aDados[nX, 06], oFont05)
        
                                               
		oPrint:Box((nLinIni + (nDist * 2) + 0325)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni + (nDist * 2) + 0385)*nAL + nLinA4 + nCamp , (nColIni + nEsq + 595 +(nColMax*0.70) - 0005)*nAC)
		oPrint:Say((nLinIni + (nDist * 2) + 0345)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "7 - Nome", oFont01) //7 - Nome
		oPrint:Say((nLinIni + (nDist * 2) + 0377 + 20 )*nAL + nLinA4, (nColIni + nEsq + 0040)*nAC, aDados[nX, 07], oFont05)
		oPrint:Box((nLinIni + (nDist * 2) + 0325)*nAL + nLinA4, (nColIni + nEsq + 595 + (nColMax*0.70))*nAC, (nLinIni + (nDist * 2) + 0385)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 595 + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 2) + 0345)*nAL + nLinA4, (nColIni + nEsq + 595 + (nColMax*0.70) + 0010)*nAC, "8 - Cartão Nacional de Saúde", oFont01) //8 - Cartão Nacional de Saúde
		oPrint:Say((nLinIni + (nDist * 2) + 0377 + 20)*nAL + nLinA4, (nColIni + nEsq + 595 + (nColMax*0.70) + 0020)*nAC, aDados[nX, 08], oFont05)
                                              
		oPrint:Say((nLinIni + (nDist * 3) + 0405)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, "Dados do Contratado", oFont01) //Dados do Contratado
		oPrint:Box((nLinIni + (nDist * 3) + 0415)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni +  (nDist *3 ) + 0475)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 595 + (nColMax*0.20) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 3) + 0435)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "9 - Código na Operadora", oFont01) //9 - Código na Operadora
		oPrint:Say((nLinIni + (nDist * 3) + 0467 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 0040)*nAC, aDados[nX, 09], oFont05)
		oPrint:Box((nLinIni + (nDist * 3) + 0415)*nAL + nLinA4, (nColIni + nEsq + 595 + (nColMax*0.20))*nAC, (nLinIni +  (nDist * 3 )+ 0475)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 595 + (nColMax*0.85) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 3) + 0435)*nAL + nLinA4, (nColIni + nEsq + 595 +(nColMax*0.20) + 0010)*nAC, "10 - Nome do Contratado", oFont01) //10 - Nome do Contratado
		oPrint:Say((nLinIni + (nDist * 3) + 0467 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 595 +(nColMax*0.20) + 0020)*nAC, aDados[nX, 10], oFont05)
		oPrint:Box((nLinIni + (nDist * 3) + 0415)*nAL + nLinA4, (nColIni + nEsq + 595 +(nColMax*0.85))*nAC, (nLinIni +  (nDist * 3 )  + 0475)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 595 + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 3) + 0435)*nAL + nLinA4, (nColIni + nEsq + 595 +(nColMax*0.85) + 0010)*nAC, "11 - Código CNES", oFont01) //11 - Código CNES
		oPrint:Say((nLinIni + (nDist * 3) + 0467 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 595 +(nColMax*0.85) + 0020)*nAC, aDados[nX, 11], oFont05)
		

		oPrint:Box((nLinIni + (nDist * 4 ) + 0485)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni +  (nDist * 4) + 0545)*nAL + nLinA4 + nCamp , (nColIni + nEsq + 80 + (nColMax*0.51) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 4 ) + 0505)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "12 - Nome do Profissional Executante", oFont01) //12 - Nome do Profissional Executante
		oPrint:Box((nLinIni + (nDist * 4 ) + 0485)*nAL + nLinA4, (nColIni + nEsq +  80 + (nColMax*0.51))*nAC, (nLinIni +  (nDist * 4) + 0545)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 595 + (nColMax*0.60) - 0010 +(50))*nAC)			
		oPrint:Say((nLinIni + (nDist * 4 ) + 0506)*nAL + nLinA4, (nColIni + nEsq +  80 + (nColMax*0.51) + 0010)*nAC, "13 - Conselho Profissional", oFont01) //13 - Conselho Profissional
		oPrint:Box((nLinIni + (nDist * 4 ) + 0485)*nAL + nLinA4, (nColIni + nEsq + 45 + 600 + (nColMax*0.60))*nAC, (nLinIni +  (nDist * 4 ) + 0545)*nAL + nLinA4 + nCamp, (nColIni + nEsq +  600 + (nColMax*0.81) - 0006)*nAC)			
		oPrint:Say((nLinIni + (nDist * 4 ) + 0505)*nAL + nLinA4, (nColIni + nEsq + 45 + 600 + (nColMax*0.60) + 0010)*nAC, "14 - Número no Conselho", oFont01) //14 - Número no Conselho
		oPrint:Box((nLinIni + (nDist * 4 ) + 0485)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.81))*nAC, (nLinIni +  (nDist * 4) + 0545)*nAL + nLinA4 +  nCamp, (nColIni + nEsq +  600 + (nColMax*0.87) - 0010)*nAC)			
		oPrint:Say((nLinIni + (nDist * 4 ) + 0505)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.81) + 0010)*nAC, "15 - UF", oFont01) //15 - UF
		oPrint:Box((nLinIni + (nDist * 4 ) + 0485)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.87))*nAC, (nLinIni +  (nDist * 4) + 0545)*nAL + nLinA4 +  nCamp, (nColIni + nEsq +  600 + nColMax - 0010)*nAC)			
		oPrint:Say((nLinIni + (nDist * 4 ) + 0505)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.87) + 0010)*nAC, "16 - Código CBO", oFont01) //16 - Código CBO
		
		If aDados[nX][12] != NIL			
			oPrint:Say((nLinIni + (nDist * 4 ) + 0537 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 0040)*nAC, aDados[nX, 12], oFont05)			
		// 	oPrint:Say((nLinIni + (nDist * 4 ) + 0517)*nAL + nLinA4, (nColIni + dif  +  80 + (nColMax*0.51) + 0010)*nAC, "Profissional", oFont01) //Profissional
			oPrint:Say((nLinIni + (nDist * 4 ) + 0540  + nAltFt )*nAL + nLinA4, (nColIni + nEsq +  80 + (nColMax*0.51) + 0020)*nAC, aDados[nX, 13], oFont05)			
			oPrint:Say((nLinIni + (nDist * 4 ) + 0537  + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 45 + 600 + (nColMax*0.60) + 0020)*nAC, aDados[nX, 14], oFont05)			
			oPrint:Say((nLinIni + (nDist * 4 ) + 0537  + nAltFt)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.81) + 0020)*nAC, aDados[nX, 15], oFont05)			
		Endif
		
		/*
		If !EMPTY(aDados[nX, 04])
			cQuery := "SELECT BTU_CDTERM "
			cQuery += "FROM " + RetSqlName("BTU") + " "
			cQuery += "WHERE BTU_VLRSIS LIKE '%" + ALLTRIM(aDados[nX, 16]) + "%' AND D_E_L_E_T_ <> '*' "

	   // Compatibiliza a sintaxe da query para o banco de dados em uso.
			cQuery := ChangeQuery(cQuery)

	   // Executa a query e retorna o conjunto de registros numa WorkArea denominada MOVIM,
	   // contendo os registros filtrados pela clausula WHERE.
			dbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "MOVIM", .F., .T.)

			aDados[nX, 16] := MOVIM->BTU_CDTERM

			dbSelectArea("MOVIM")
			MOVIM->( DbCloseArea() )
		EndIf*/
		
		if !EMPTY(aDados[nX, 16])
			aDados[nX, 16] := PLSGETVINC("BTU_CDTERM", "BAQ" , .F., "24",  ALLTRIM(aDados[nX, 16]),.F.)
		endif
		
		oPrint:Say((nLinIni + (nDist * 4.1) + 0537 + nAltFt)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.87) + 0020)*nAC, aDados[nX, 16], oFont05)
                                                           
		oPrint:Say((nLinIni + (nDist * 5) + 0565)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, "Hipóteses Diagnósticas", oFont01) //Hipóteses Diagnósticas
		oPrint:Box((nLinIni + (nDist * 5) + 0575)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni + (nDist * 5) + 0635)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 200 + (nColMax*0.23) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 5.2) + 0590)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "17 - Indicação de Acidente (acidente ou doença relacionada)", oFont01) //17 - Indicação de Acidente
		//oPrint:Say((nLinIni + (nDist * 5.3) + 0605)*nAL + nLinA4, (nColIni + nEsq + 0040)*nAC, "(acidente ou doença relacionada)", oFont01) //(acidente ou doença relacionada)
		oPrint:Say((nLinIni + (nDist * 5.5) + 0630)*nAL + nLinA4, (nColIni + nEsq + (nColMax*0.11))*nAC, aDados[nX, 17], oFont05)
                                                            
		oPrint:Say((nLinIni + (nDist * 6) + 0655)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, "Dados do Atendimento / Procedimento Realizado", oFont01) //Dados do Atendimento / Procedimento Realizado
		oPrint:Box((nLinIni + (nDist * 6) + 0665)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni + (nDist * 6) + 0725)*nAL + nLinA4 + nCamp, (nColIni + nEsq + (nColMax*0.23) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 6) + 0685)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "18 - Data do Atendimento", oFont01) //18 - Data do Atendimento
		oPrint:Say((nLinIni + (nDist * 6) + 0717 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 0040)*nAC, DtoC(aDados[nX, 18]), oFont05)
		oPrint:Box((nLinIni + (nDist * 6) + 0665)*nAL + nLinA4, (nColIni + nEsq + (nColMax*0.23))*nAC, (nLinIni + (nDist * 6) + 0725)*nAL + nLinA4 + nCamp, (nColIni + nEsq + (nColMax*0.35) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 6) + 0685)*nAL + nLinA4, (nColIni + nEsq + (nColMax*0.23) + 0010)*nAC, "19 - Tipo de Consulta", oFont01) //19 - Tipo de Consulta
		oPrint:Say((nLinIni + (nDist * 6) + 0717 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + (nColMax*0.23) + 0020)*nAC, aDados[nX, 19], oFont05)
		oPrint:Box((nLinIni + (nDist * 6) + 0665)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.46))*nAC, (nLinIni + (nDist * 6) + 0725)*nAL + nLinA4+ nCamp, (nColIni + nEsq + 600 + (nColMax*0.53) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 6) + 0685)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.46) + 0010)*nAC, "20 - Tabela", oFont01) //20 - Tabela
		oPrint:Say((nLinIni + (nDist * 6) + 0717  + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.46) + 0020)*nAC, aDados[nX, 20], oFont05)
		oPrint:Box((nLinIni + (nDist * 6) + 0665)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.53))*nAC, (nLinIni + (nDist * 6) + 0725)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 600 + (nColMax*0.78) - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 6) + 0685)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.53) + 0010)*nAC, "21 - Código do Procedimento", oFont01) //21 - Código do Procedimento
		oPrint:Say((nLinIni + (nDist * 6) + 0717 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.53) + 0020)*nAC, aDados[nX, 21], oFont05)
		oPrint:Box((nLinIni + (nDist * 6) + 0665)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.78))*nAC, (nLinIni + (nDist * 6) + 0725)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 600 + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 6) + 0685)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.78) + 0010)*nAC, "22 - Valor do Procedimento", oFont01) //22 - Valor do Procedimento
		nVlrAp := iif( valtype(aDados[nX, 22]) == "C", val(aDados[nX, 22]), aDados[nX, 22] )
		oPrint:Say((nLinIni + (nDist * 6) + 0717 + nAltFt )*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax*0.78) + 0020)*nAC, Transform(nVlrAp, "@E 99,999,999.99"), oFont05)

		oPrint:Box((nLinIni + (nDist * 7) + 0735)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni + (nDist * 7) + 1000)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 600 + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 7) + 0755)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "23 - Observação / Justificativa", oFont01) //23 - Observação / Justificativa
		
		For nI := 1 To MlCount(aDados[nX, 23], 100)
			cObs := MemoLine(aDados[nX, 23], 100, nI)
			oPrint:Say((nLinIni + 0800 + 400 + nLinObs)*nAL + nLinA4, (nColIni + 0240)*nAC, cObs, oFont05)
			nLinObs+=40
		Next nI
		
		oPrint:Box((nLinIni + (nDist * 8) + 1010)*nAL + nLinA4, (nColIni + nEsq + 0020)*nAC, (nLinIni + (nDist * 8) + 1120)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 300+ (nColMax/2) - 0005)*nAC)
		oPrint:Say((nLinIni + (nDist * 8) + 1030)*nAL + nLinA4, (nColIni + nEsq + 0030)*nAC, "24 - Assinatura do Profissional Executante", oFont01) //24 - Assinatura do Profissional Executante
		oPrint:Box((nLinIni + (nDist * 8) + 1010)*nAL + nLinA4, (nColIni + nEsq + 300 + (nColMax/2) + 0005)*nAC, (nLinIni + (nDist * 8) + 1120)*nAL + nLinA4 + nCamp, (nColIni + nEsq + 600 + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + (nDist * 8) + 1030)*nAL + nLinA4, (nColIni + nEsq + 600 + (nColMax/2) + 0015)*nAC, "25 - Assinatura do Beneficiário ou Responsável", oFont01) //25 - Assinatura do Beneficiário ou Responsável
		*/
		oPrint:EndPage()	// Finaliza a pagina

	Next nX


	If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:Print()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:Preview()
	EndIf

Return (cFileName)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSE  ³ Autor ³ Bruno Iserhardt       ³ Data ³ 21.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3.00.01 (Guia Sol. Internaçao)     ³±±
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

Function PLSTISSE(aDados, lGerTXT, nLayout, cLogoGH, lMail, lWeb, cPathRelW, lProrrog, lAuto)

	Local nLinMax
	Local nColMax
	Local nLinIni		:= 0	// Linha Lateral (inicial) Esquerda
	Local nColIni		:= 0	// Coluna Lateral (inicial) Esquerda
	Local nColA4    	:= 0
	Local nLinA4    	:= 0
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
	Local lImpnovo  	:= .T.
	Local nVolta    	:= 0
	Local cFile 		:= GetNewPar("MV_RELT",'\SPOOL\')
	Local lRet			:= .T.
	Local lOk			:= .T.
	LOCAL cFileName	:= ""
	LOCAL cRel      	:= "GUICONS"
	LOCAL cPathSrvJ 	:= GETMV("MV_RELT")
	LOCAL nAL			:= 0.25
	LOCAL nAC			:= 0.24
	Local lImpPrc   	:= .T.
	Local cCodTab 	:= ""
	Local cCodPro 	:= ""
	Local cDescri		:= ""
	Local lImpNAut	:= IIf(GetNewPar("MV_PLNAUT",0) == 0, .F., .T.) // 0 = Nao imprime procedimento nao autorizado 1 = Sim imprime
	LOCAL nLinObs		:= 0
	LOCAL cIndic    	:= ""
	LOCAL cErro		:= ""
	LOCAL cArq			:= ""
	Local bError		:= ErrorBlock( {|e| TrataErro(e,@cErro) } )
	Local lPlsGTiss 	:= ExistBlock("PLSGTISS")

	Local nIdxEvo		:= 0
	Local cCodMedGen    := GetNewPar("MV_PLMEDPT","")
	Local cCodMatGen    := GetNewPar("MV_PLMATPT","")
	Local cCodTaxGen    := GetNewPar("MV_PLTAXPT","")
	Local cCodOpmGen    := GetNewPar("MV_PLOPMPT","")
	Local cTdsCodG      := ""

	DEFAULT lProrrog 	:= ".F."
	DEFAULT lGerTXT 	:= .F.
	DEFAULT nLayout 	:= 2
	DEFAULT cLogoGH 	:= ""
	DEFAULT lMail		:= .F.
	DEFAULT lWeb		:= .F.
	DEFAULT cPathRelW 	:= ""
	DEFAULT lAuto       := .F.
	DEFAULT aDados 	:= { { ;
		"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- Nº Guia no Prestador
	"12345678901234567890",; //3 - Número da Guia Atribuído pela Operadora
	CtoD("01/01/07"),; //4 - Data da Autorização
	"12345678901234567890",; //5 - Senha
	CtoD("01/01/07"),; //6 – Data de Validade da Senha
	"12345678901234567890",; //7 - Número da Carteira
	CtoD("12/12/07"),; //8 - Validade da Carteira
	"S",; //9-Atendimento de RN
	Replicate("M",70),; //10 - Nome
	"123456789012345",; //11 - Cartão Nacional de Saúde
	"12345678901234",; //12 – Código na Operadora
	Replicate("M",70),; //13 - Nome do Contratado
	Replicate("M",70),; //14 - Nome do Profissional Solicitante
	"MM",; //15 - Conselho Profissional
	"123456789012345",; //16 - Número no Conselho
	"RS",; //17 - UF
	"123456",; //18 - Código CBO
	"12345678901234",; //19- Código na Operadora / CNPJ
	Replicate("M",70),; //20 - Nome do Hospital/Local Solicitado
	CtoD("12/12/07"),; //21 - Data sugerida para internação
	"U",; //22 - Caráter do Atendimento
	"1",; //23-Tipo de Internação
	"1",; //24 - Regime de Internação
	999,; //25 - Qtde. Diárias Solicitadas
	"A",; //26 – Previsão de uso de OPME
	"N",; //27 – Previsão de uso de quimioterápico
	Replicate("M",480),; //28 - Indicação Clínica
	"1234",; //29-CID 10 Principal (opcional)
	"1234",; //30 - CID 10 (2) (opcional)
	"1234",; //31 - CID 10 (3) (opcional)
	"1234",; //32 - CID 10 (4) (opcional)
	"1",; //33 - Indicação de Acidente (acidente ou doença relacionada)
	{ "10","20","30","40","50","60","70","80","90","99","00","11", "11" },; //34-Tabela
	{ "1234567890","2345678901","3456789012","4567890123","5678901234","1234567890","2345678901","3456789012","4567890123","5678901234","4567890123","5678901234","5678901234" },; //35 - Código do Procedimento
	{ Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("C",150),Replicate("D",150),Replicate("D",150) },; //36 - Descrição
	{ 999,888,777,666,555,444,333,222,111,999,888,777,777 },; //37 - Qtde Solic
	{ 111,222,333,444,555,1212,111,222,333,444,555,1212,1212 },; //38 – Qtde Aut
	CtoD("12/12/07"),; //39 - Data Provável da Admissão Hospitalar
	123,; //40 - Qtde. Diarias Autorizadas
	"AA",;//41 - Tipo da Acomodação Autorizada
	"12345678901234",; //42 - Código na Operadora / CNPJ autorizado
	Replicate("M",70),; //43 - Nome do Hospital / Local Autorizado
	"1234567",; //44 - Código CNES
	Replicate("O",1000),; //45 – Observação / Justificativa
	CtoD("12/12/07") } } //46-Data da Solicitação

	If nLayout  == 1 // Ofício 2
		nLinMax	:=	3705	// Numero maximo de Linhas (31,5 cm)
		nColMax	:=	2400	// Numero maximo de Colunas (21 cm)
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2350
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
		cFileName := cRel+CriaTrab(NIL,.F.)+".pdf"
	EndIf

	//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
	oPrint := FWMSPrinter():New ( cFileName			,	IMP_PDF		,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
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
		If !(oPrint:nModalResult == 1)
			lRet := .F.
			lMail := .F.
		Else
			lImpnovo:=(oPrint:nModalResult == 1)
		Endif
	EndIf

	If lProrrog == '.T.'
		lProrrog := PPLVERPRR(@aDados)
	Else
		lProrrog := .F.
	EndIf

	cTdsCodG:=(cCodMedGen+ "-" +cCodMatGen+ "-" +cCodTaxGen+ "-" +cCodOpmGen)
	BEGIN SEQUENCE
	
		While lImpnovo

			lImpnovo:=.F.
			nVolta  += 1
			nT      += 12
			nT1     += 2
			nT3     += 3

			For nX := 1 To Len(aDados)

				If Len(aDados[nX]) == 0
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

				If oPrint:Cprinter == "PDF" .OR. lWeb
					nLinIni	:= 150
				Else
					nLinIni := 000
				Endif

				nColIni := 060
				nColA4  := 000
				nLinA4  := 000

				oPrint:StartPage()		// Inicia uma nova pagina

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0010)*nAC, (nLinIni + nLinMax - 10)*nAL, (nColIni + nColMax)*nAC)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fLogoEmp(@cFileLogo,, cLogoGH)

				If File(cFilelogo)
					oPrint:SayBitmap((nLinIni + 0040)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
				EndIf

				If nLayout == 2 // Papél A4
					nColA4    := -0065
				Elseif nLayout == 3// Carta
					nLinA4    := -0085
				Endif

				If lProrrog
					oPrint:Say((nLinIni+ 0050)*nAL, (nColIni + (nColMax*0.35))*nAC, "GUIA  DE SOLICITAÇÃO", oFont02n) //"GUIA DE SOLICITAÇÃO DE PRORROGAÇÃO DE "
					oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.30))*nAC, "DE PRORROGAÇÃO DE INTERNAÇÃO", oFont02n) //"DE INTERNAÇÃO"
					oPrint:Say((nLinIni + 0150)*nAL, (nColIni + (nColMax*0.28))*nAC, "OU COMPLEMENTAÇÃO DO TRATAMENTO", oFont02n) //"DE INTERNAÇÃO"
				Else
					oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.40))*nAC, "GUIA DE SOLICITAÇÃO", oFont02n) //"GUIA DE SOLICITAÇÃO"
					oPrint:Say((nLinIni + 0150)*nAL, (nColIni + (nColMax*0.42))*nAC, "DE INTERNAÇÃO", oFont02n) //"DE INTERNAÇÃO"
				EndIf
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.70))*nAC, "2- Nº Guia no Prestador", oFont01) //"2- Nº Guia no Prestador"
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.79))*nAC, aDados[nX, 02], oFont03n)

				oPrint:Box((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.15)- 0010)*nAC)
				oPrint:Say((nLinIni + 0200)*nAL, (nColIni + 0030)*nAC, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
				oPrint:Say((nLinIni + 0232)*nAL, (nColIni + 0040)*nAC, aDados[nX, 01], oFont04)
				oPrint:Box((nLinIni + 0180)*nAL, (nColIni + (nColMax*0.15))*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
				oPrint:Say((nLinIni + 0200)*nAL, (nColIni + (nColMax*0.15) + 0010)*nAC, "3 - Número da Guia Atribuído pela Operadora", oFont01) //"3 - Número da Guia Atribuído pela Operadora"
				oPrint:Say((nLinIni + 0232)*nAL, (nColIni + (nColMax*0.15) + 0020)*nAC, aDados[nX, 03], oFont04)

				oPrint:Box((nLinIni + 0250)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.25) - 0010)*nAC)
				oPrint:Say((nLinIni + 0270)*nAL, (nColIni + 0030)*nAC, "4 - Data da Autorização", oFont01) //"4 - Data da Autorização"
				oPrint:Say((nLinIni + 0302)*nAL, (nColIni + 0040)*nAC, DtoC(aDados[nX, 04]), oFont04)
				oPrint:Box((nLinIni + 0250)*nAL, (nColIni + (nColMax*0.25))*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.70)- 0010)*nAC)
				oPrint:Say((nLinIni + 0270)*nAL, (nColIni + (nColMax*0.25) + 0010)*nAC, "5 - Senha", oFont01) //"5 - Senha"
				oPrint:Say((nLinIni + 0302)*nAL, (nColIni + (nColMax*0.25) + 0020)*nAC, aDados[nX, 05], oFont04)
				oPrint:Box((nLinIni + 0250)*nAL, (nColIni + (nColMax*0.70))*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.95)- 0010)*nAC)
				oPrint:Say((nLinIni + 0270)*nAL, (nColIni + (nColMax*0.70) + 0010)*nAC, "6 - Data de Validade da Senha", oFont01) //"6 - Data de Validade da Senha"
				oPrint:Say((nLinIni + 0302)*nAL, (nColIni + (nColMax*0.70) + 0020)*nAC, DtoC(aDados[nX, 06]), oFont04)

				oPrint:Say((nLinIni + 0330)*nAL, (nColIni + 0020)*nAC, "Dados do Beneficiário", oFont01) //Dados do Beneficiário
				oPrint:Box((nLinIni + 0340)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.50) - 0010)*nAC)
				oPrint:Say((nLinIni + 0360)*nAL, (nColIni + 0030)*nAC, "7 - Número da Carteira", oFont01) //"7 - Número da Carteira"
				oPrint:Say((nLinIni + 0392)*nAL, (nColIni + 0040)*nAC, aDados[nX, 07], oFont04)
				oPrint:Box((nLinIni + 0340)*nAL, (nColIni + (nColMax*0.50))*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.73) - 0010)*nAC)
				oPrint:Say((nLinIni + 0360)*nAL, (nColIni + (nColMax*0.50) + 0010)*nAC, "8 - Validade da Carteira", oFont01) //"8 - Validade da Carteira"
				oPrint:Say((nLinIni + 0392)*nAL, (nColIni + (nColMax*0.50) + 0020)*nAC, DtoC(aDados[nX, 08]), oFont04)
				oPrint:Box((nLinIni + 0340)*nAL, (nColIni + (nColMax*0.73))*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.85) - 0010)*nAC)
				oPrint:Say((nLinIni + 0360)*nAL, (nColIni + (nColMax*0.73) + 0010)*nAC, "9 - Atendimento de RN", oFont01) //"9 - Atendimento de RN"
				oPrint:Say((nLinIni + 0392)*nAL, (nColIni + (nColMax*0.78))*nAC, aDados[nX, 09], oFont04)
				
				If PLSTISSVER() < "4"
					oPrint:Box((nLinIni + 0410)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0470)*nAL, (nColIni + (nColMax*0.68) - 0010)*nAC)
					oPrint:Say((nLinIni + 0430)*nAL, (nColIni + 0030)*nAC, "10 - Nome", oFont01) //"10 - Nome"
					oPrint:Say((nLinIni + 0462)*nAL, (nColIni + 0040)*nAC, aDados[nX, 10], oFont04)
					oPrint:Box((nLinIni + 0410)*nAL, (nColIni + (nColMax*0.68))*nAC, (nLinIni + 0470)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0430)*nAL, (nColIni + (nColMax*0.68) + 0010)*nAC, "11 - Cartão Nacional de Saúde", oFont01) //"11 - Cartão Nacional de Saúde"
					oPrint:Say((nLinIni + 0462)*nAL, (nColIni + (nColMax*0.68) + 0020)*nAC, aDados[nX, 11], oFont04)

					oPrint:Say((nLinIni + 0490)*nAL, (nColIni + 0020)*nAC, "Dados do Contratado Solicitante", oFont01) //Dados do Contratado Solicitante
					oPrint:Box((nLinIni + 0500)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.30) - 0010)*nAC)
					oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 0030)*nAC, "12 - Código na Operadora", oFont01) //"12 - Código na Operadora"
					oPrint:Say((nLinIni + 0552)*nAL, (nColIni + 0040)*nAC, aDados[nX, 12], oFont04)
					oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0560)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "13 - Nome do Contratado", oFont01) //"13 - Nome do Contratado"
					oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, aDados[nX, 13], oFont04)

					oPrint:Box((nLinIni + 0570)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.47) - 0010)*nAC)
					oPrint:Say((nLinIni + 0590)*nAL, (nColIni + 0030)*nAC, "14 - Nome do Profissional Solicitante", oFont01) //"14 - Nome do Profissional Solicitante"
					oPrint:Say((nLinIni + 0622)*nAL, (nColIni + 0040)*nAC, aDados[nX, 14], oFont04)
					oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.47))*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.57) - 0010)*nAC)
					oPrint:Say((nLinIni + 0586)*nAL, (nColIni + (nColMax*0.47) + 0010)*nAC, "15 - Conselho", oFont01) //"15 - Conselho"
					oPrint:Say((nLinIni + 0603)*nAL, (nColIni + (nColMax*0.47) + 0015)*nAC, "Profissional", oFont01) //"Profissional"
					oPrint:Say((nLinIni + 0628)*nAL, (nColIni + (nColMax*0.47) + 0020)*nAC, aDados[nX, 15], oFont04)
					oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.57))*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.82) - 0010)*nAC)
					oPrint:Say((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.57) + 0010)*nAC, "16 - Número no Conselho", oFont01) //"16 - Número no Conselho"
					oPrint:Say((nLinIni + 0622)*nAL, (nColIni + (nColMax*0.57) + 0020)*nAC, aDados[nX, 16], oFont04)
					oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.82))*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.86) - 0010)*nAC)
					oPrint:Say((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.82) + 0010)*nAC, "17 - UF", oFont01) //"17 - UF"
					oPrint:Say((nLinIni + 0622)*nAL, (nColIni + (nColMax*0.82) + 0020)*nAC, aDados[nX, 17], oFont04)
					oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.86))*nAC, (nLinIni + 0630)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.86) + 0010)*nAC, "18 - Código CBO", oFont01) //"18 - Código CBO"
					oPrint:Say((nLinIni + 0622)*nAL, (nColIni + (nColMax*0.86) + 0020)*nAC, aDados[nX, 18], oFont04)

					oPrint:Say((nLinIni + 0650)*nAL, (nColIni + 0020)*nAC, "Dados do Hospital /Local Solicitado / Dados da Internação", oFont01) //Dados do Hospital /Local Solicitado / Dados da Internação
					oPrint:Box((nLinIni + 0660)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0720)*nAL, (nColIni + (nColMax*0.25) - 0010)*nAC)
					oPrint:Say((nLinIni + 0680)*nAL, (nColIni + 0030)*nAC, "19- Código na Operadora / CNPJ", oFont01) //"19- Código na Operadora / CNPJ"
					oPrint:Say((nLinIni + 0712)*nAL, (nColIni + 0040)*nAC, aDados[nX, 19], oFont04)
					oPrint:Box((nLinIni + 0660)*nAL, (nColIni + (nColMax*0.25))*nAC, (nLinIni + 0720)*nAL, (nColIni + (nColMax*0.78) - 0010)*nAC)
					oPrint:Say((nLinIni + 0680)*nAL, (nColIni + (nColMax*0.25) + 0010)*nAC, "20 - Nome do Hospital/Local Solicitado", oFont01) //"20 - Nome do Hospital/Local Solicitado"
					oPrint:Say((nLinIni + 0712)*nAL, (nColIni + (nColMax*0.25) + 0020)*nAC, aDados[nX, 20], oFont04)
					oPrint:Box((nLinIni + 0660)*nAL, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0720)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0680)*nAL, (nColIni + (nColMax*0.78) + 0010)*nAC, "21 - Data sugerida para internação", oFont01) //"20 - Nome do Hospital/Local Solicitado"
					oPrint:Say((nLinIni + 0712)*nAL, (nColIni + (nColMax*0.78) + 0020)*nAC, DtoC(aDados[nX, 21]), oFont04)

					oPrint:Box((nLinIni + 0730)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.17) - 0010)*nAC)
					oPrint:Say((nLinIni + 0750)*nAL, (nColIni + 0030)*nAC, "22 - Caráter do Atendimento", oFont01) //"22 - Caráter do Atendimento"
					oPrint:Say((nLinIni + 0782)*nAL, (nColIni + 0185)*nAC, aDados[nX, 22], oFont04)
					oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.17))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.29) - 0010)*nAC)
					oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.17) + 0010)*nAC, "23 - Tipo de Internação", oFont01) //"23-Tipo de Internação"
					oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.225))*nAC, aDados[nX, 23], oFont04)
					oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.29))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.44) - 0010)*nAC)
					oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.29) + 0010)*nAC, "24 - Regime de Internação", oFont01) //"24 - Regime de Internação"
					oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.36))*nAC, aDados[nX, 24], oFont04)
					oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.44))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
					oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.44) + 0010)*nAC, "25 - Qtde. Diárias Solicitadas", oFont01) //"25 - Qtde. Diárias Solicitadas"
					oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.51))*nAC, IIf(Empty(aDados[nX, 25]), "", Transform(aDados[nX, 25], "@E 999")), oFont04)
					oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.60))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.78) - 0010)*nAC)
					oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.60) + 0010)*nAC, "26 - Previsão de uso de OPME", oFont01) //"26 – Previsão de uso de OPME"
					oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.68))*nAC, aDados[nX, 26], oFont04)
					oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0790)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.78) + 0010)*nAC, "27 - Previsão de uso de quimioterápico", oFont01) //"27 – Previsão de uso de quimioterápico"
					oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.85))*nAC, aDados[nX, 27], oFont04)

					oPrint:Box((nLinIni + 0800)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1040)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0820)*nAL, (nColIni + 0030)*nAC, "28 - Indicação Clínica", oFont01) //"28 - Indicação Clínica"
					For nI := 1 To MlCount(aDados[nX, 28], 100)
						cIndic := MemoLine(aDados[nX, 28], 100, nI)
						oPrint:Say((nLinIni + 0852 + nLinObs)*nAL, (nColIni + 0040)*nAC, cIndic, oFont04)
						nLinObs+=40
					Next nI



				Else
					
					// tiss 4.00.01
					oPrint:Box((nLinIni + 0410)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0470)*nAL, (nColIni + (nColMax*0.85) - 0010)*nAC)
					oPrint:Say((nLinIni + 0430)*nAL, (nColIni + 0030)*nAC, "50 - Nome Social", oFont01) //"10 - Nome"
					oPrint:Say((nLinIni + 0462)*nAL, (nColIni + 0040)*nAC, aDados[nX, 50], oFont04)
					

					oPrint:Box((nLinIni + 0480)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0530)*nAL, (nColIni + (nColMax*0.85) - 0010)*nAC)
					oPrint:Say((nLinIni + 0500)*nAL, (nColIni + 0030)*nAC, "10 - Nome", oFont01) //"10 - Nome"
					oPrint:Say((nLinIni + 0521)*nAL, (nColIni + 0040)*nAC, aDados[nX, 10], oFont04)
					

					oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0020)*nAC, "Dados do Contratado Solicitante", oFont01) //Dados do Contratado Solicitante
					oPrint:Box((nLinIni + 0560)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0620)*nAL, (nColIni + (nColMax*0.30) - 0010)*nAC)
					oPrint:Say((nLinIni + 0580)*nAL, (nColIni + 0030)*nAC, "12 - Código na Operadora", oFont01) //"12 - Código na Operadora"
					oPrint:Say((nLinIni + 0604)*nAL, (nColIni + 0040)*nAC, aDados[nX, 12], oFont04)
					oPrint:Box((nLinIni + 0560)*nAL, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0620)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0580)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "13 - Nome do Contratado", oFont01) //"13 - Nome do Contratado"
					oPrint:Say((nLinIni + 0604)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, aDados[nX, 13], oFont04)

					oPrint:Box((nLinIni + 0640)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0710)*nAL, (nColIni + (nColMax*0.47) - 0010)*nAC)
					oPrint:Say((nLinIni + 0670)*nAL, (nColIni + 0030)*nAC, "14 - Nome do Profissional Solicitante", oFont01) //"14 - Nome do Profissional Solicitante"
					oPrint:Say((nLinIni + 0696)*nAL, (nColIni + 0040)*nAC, aDados[nX, 14], oFont04)
					oPrint:Box((nLinIni + 0640)*nAL, (nColIni + (nColMax*0.47))*nAC, (nLinIni + 0710)*nAL, (nColIni + (nColMax*0.57) - 0010)*nAC)
					oPrint:Say((nLinIni + 0660)*nAL, (nColIni + (nColMax*0.47) + 0010)*nAC, "15 - Conselho", oFont01) //"15 - Conselho"
					oPrint:Say((nLinIni + 0676)*nAL, (nColIni + (nColMax*0.47) + 0015)*nAC, "Profissional", oFont01) //"Profissional"
					oPrint:Say((nLinIni + 0696)*nAL, (nColIni + (nColMax*0.47) + 0020)*nAC, aDados[nX, 15], oFont04)
					oPrint:Box((nLinIni + 0640)*nAL, (nColIni + (nColMax*0.57))*nAC, (nLinIni + 0710)*nAL, (nColIni + (nColMax*0.82) - 0010)*nAC)
					oPrint:Say((nLinIni + 0670)*nAL, (nColIni + (nColMax*0.57) + 0010)*nAC, "16 - Número no Conselho", oFont01) //"16 - Número no Conselho"
					oPrint:Say((nLinIni + 0696)*nAL, (nColIni + (nColMax*0.57) + 0020)*nAC, aDados[nX, 16], oFont04)
					oPrint:Box((nLinIni + 0640)*nAL, (nColIni + (nColMax*0.82))*nAC, (nLinIni + 0710)*nAL, (nColIni + (nColMax*0.86) - 0010)*nAC)
					oPrint:Say((nLinIni + 0670)*nAL, (nColIni + (nColMax*0.82) + 0010)*nAC, "17 - UF", oFont01) //"17 - UF"
					oPrint:Say((nLinIni + 0696)*nAL, (nColIni + (nColMax*0.82) + 0020)*nAC, aDados[nX, 17], oFont04)
					oPrint:Box((nLinIni + 0640)*nAL, (nColIni + (nColMax*0.86))*nAC, (nLinIni + 0720)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0670)*nAL, (nColIni + (nColMax*0.86) + 0010)*nAC, "18 - Código CBO", oFont01) //"18 - Código CBO"
					oPrint:Say((nLinIni + 0696)*nAL, (nColIni + (nColMax*0.86) + 0020)*nAC, aDados[nX, 18], oFont04)


					oPrint:Say((nLinIni + 0735)*nAL, (nColIni + 0020)*nAC, "Dados do Hospital /Local Solicitado / Dados da Internação", oFont01) //Dados do Hospital /Local Solicitado / Dados da Internação
					oPrint:Box((nLinIni + 0740)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0810)*nAL, (nColIni + (nColMax*0.25) - 0010)*nAC)
					oPrint:Say((nLinIni + 0765)*nAL, (nColIni + 0030)*nAC, "19- Código na Operadora / CNPJ", oFont01) //"19- Código na Operadora / CNPJ"
					oPrint:Say((nLinIni + 0795)*nAL, (nColIni + 0040)*nAC, aDados[nX, 19], oFont04)
					oPrint:Box((nLinIni + 0740)*nAL, (nColIni + (nColMax*0.25))*nAC, (nLinIni + 0810)*nAL, (nColIni + (nColMax*0.78) - 0010)*nAC)
					oPrint:Say((nLinIni + 0765)*nAL, (nColIni + (nColMax*0.25) + 0010)*nAC, "20 - Nome do Hospital/Local Solicitado", oFont01) //"20 - Nome do Hospital/Local Solicitado"
					oPrint:Say((nLinIni + 0795)*nAL, (nColIni + (nColMax*0.25) + 0020)*nAC, aDados[nX, 20], oFont04)
					oPrint:Box((nLinIni + 0740)*nAL, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0810)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0765)*nAL, (nColIni + (nColMax*0.78) + 0010)*nAC, "21 - Data sugerida para internação", oFont01) //"20 - Nome do Hospital/Local Solicitado"
					oPrint:Say((nLinIni + 0795)*nAL, (nColIni + (nColMax*0.78) + 0020)*nAC, DtoC(aDados[nX, 21]), oFont04)

					oPrint:Box((nLinIni + 0830)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0900)*nAL, (nColIni + (nColMax*0.17) - 0010)*nAC)
					oPrint:Say((nLinIni + 0850)*nAL, (nColIni + 0030)*nAC, "22 - Caráter do Atendimento", oFont01) //"22 - Caráter do Atendimento"
					oPrint:Say((nLinIni + 0882)*nAL, (nColIni + 0185)*nAC, aDados[nX, 22], oFont04)
					oPrint:Box((nLinIni + 0830)*nAL, (nColIni + (nColMax*0.17))*nAC, (nLinIni + 0900)*nAL, (nColIni + (nColMax*0.29) - 0010)*nAC)
					oPrint:Say((nLinIni + 0850)*nAL, (nColIni + (nColMax*0.17) + 0010)*nAC, "23 - Tipo de Internação", oFont01) //"23-Tipo de Internação"
					oPrint:Say((nLinIni + 0882)*nAL, (nColIni + (nColMax*0.225))*nAC, aDados[nX, 23], oFont04)
					oPrint:Box((nLinIni + 0830)*nAL, (nColIni + (nColMax*0.29))*nAC, (nLinIni + 0900)*nAL, (nColIni + (nColMax*0.44) - 0010)*nAC)
					oPrint:Say((nLinIni + 0850)*nAL, (nColIni + (nColMax*0.29) + 0010)*nAC, "24 - Regime de Internação", oFont01) //"24 - Regime de Internação"
					oPrint:Say((nLinIni + 0882)*nAL, (nColIni + (nColMax*0.36))*nAC, aDados[nX, 24], oFont04)
					oPrint:Box((nLinIni + 0830)*nAL, (nColIni + (nColMax*0.44))*nAC, (nLinIni + 0900)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
					oPrint:Say((nLinIni + 0850)*nAL, (nColIni + (nColMax*0.44) + 0010)*nAC, "25 - Qtde. Diárias Solicitadas", oFont01) //"25 - Qtde. Diárias Solicitadas"
					oPrint:Say((nLinIni + 0882)*nAL, (nColIni + (nColMax*0.51))*nAC, IIf(Empty(aDados[nX, 25]), "", Transform(aDados[nX, 25], "@E 999")), oFont04)
					oPrint:Box((nLinIni + 0830)*nAL, (nColIni + (nColMax*0.60))*nAC, (nLinIni + 0900)*nAL, (nColIni + (nColMax*0.78) - 0010)*nAC)
					oPrint:Say((nLinIni + 0850)*nAL, (nColIni + (nColMax*0.60) + 0010)*nAC, "26 - Previsão de uso de OPME", oFont01) //"26 – Previsão de uso de OPME"
					oPrint:Say((nLinIni + 0882)*nAL, (nColIni + (nColMax*0.68))*nAC, aDados[nX, 26], oFont04)
					oPrint:Box((nLinIni + 0830)*nAL, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0900)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0850)*nAL, (nColIni + (nColMax*0.78) + 0010)*nAC, "27 - Previsão de uso de quimioterápico", oFont01) //"27 – Previsão de uso de quimioterápico"
					oPrint:Say((nLinIni + 0882)*nAL, (nColIni + (nColMax*0.85))*nAC, aDados[nX, 27], oFont04)

					oPrint:Box((nLinIni + 0910)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1040)*nAL, (nColIni + nColMax- 0005 )*nAC)
					oPrint:Say((nLinIni + 0930)*nAL, (nColIni + 0030)*nAC, "28 - Indicação Clínica", oFont01) //"28 - Indicação Clínica"
					For nI := 1 To MlCount(aDados[nX, 28], 100)
						cIndic := MemoLine(aDados[nX, 28], 100, nI)
						oPrint:Say((nLinIni + 0955 + nLinObs)*nAL, (nColIni + 0040)*nAC, cIndic, oFont04)
						nLinObs+=40
					Next nI
				Endif

				oPrint:Say((nLinIni + 1060)*nAL, (nColIni + 0020)*nAC, "Hipóteses Diagnósticas", oFont01) //Hipóteses Diagnósticas
				oPrint:Box((nLinIni + 1070)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.15) - 0010)*nAC)
				oPrint:Say((nLinIni + 1090)*nAL, (nColIni + 0030)*nAC, "29 - CID 10 Principal (opcional)", oFont01) //"29 - CID 10 Principal"
				oPrint:Say((nLinIni + 1122)*nAL, (nColIni + 0040)*nAC, aDados[nX, 29], oFont04)
				oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.15))*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.30) - 0010)*nAC)
				oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.15) + 0010)*nAC, "30 - CID 10 (2) (opcional)", oFont01) //"30 - CID 10 (2)"
				oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.15) + 0020)*nAC, aDados[nX, 30], oFont04)
				oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.45) - 0010)*nAC)
				oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "31 - CID 10 (3) (opcional)", oFont01) //"31 - CID 10 (3)"
				oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, aDados[nX, 31], oFont04)
				oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.45))*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
				oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.45) + 0010)*nAC, "32 - CID 10 (4) (opcional)", oFont01) //"32 - CID 10 (4)"
				oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.45) + 0020)*nAC, aDados[nX, 32], oFont04)
				oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.60))*nAC, (nLinIni + 1130)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.60) + 0010)*nAC, "33 - Indicação de Acidente (acidente ou doença relacionada)", oFont01) //"33 - Indicação de Acidente (acidente ou doença relacionada)"
				oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.60) + 0020)*nAC, aDados[nX, 33], oFont04)

				oPrint:Say((nLinIni + 1150)*nAL, (nColIni + 0020)*nAC, "Procedimentos Solicitados", oFont01) //Procedimentos Solicitados
				oPrint:Box((nLinIni + 1160)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1670)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.02))*nAC, "34 - Tabela", oFont01) //34-Tabela
				oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.08))*nAC, "35 - Código do Procedimento", oFont01) //35 - Código do Procedimento
				oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.19))*nAC, "36 - Descrição", oFont01) //36 - Descrição
				oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.80))*nAC, "37 - Qtde Solic", oFont01) //37 - Qtde Solic
				oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.90))*nAC, "38 - Qtde Aut", oFont01) //38 – Qtde Aut

				nOldLinIni := nLinIni

				if nVolta=1
					nV1:=1
				Endif


				cOper := substr(aDados[nX, 2],1,4)
				cAno  := substr(aDados[nX, 2],6,4)
				cMes  := substr(aDados[nX, 2],11,2)
				cAut  := substr(aDados[nX, 2],14,8)

				DbSelectArea("BEA")
				BEA->(dbSetOrder(1))
				If BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))
					If BEA->BEA_LIBERA == '0'
					//se eh uma execucao eu tenho que refazer os procedimentos que foram solicitados
						If !Empty(BEA->BEA_NRLBOR)
							xChave := alltrim(BEA->BEA_NRLBOR)
						Else
							xChave := alltrim(cOper+cAno+cMes+cAut)
						Endif
					Else
					//se eh uma solicitacao eu tenho que refazer os procedimentos que foram solicitados e autorizados
						xChave := alltrim(cOper+cAno+cMes+cAut)
					Endif

					BEJ->(DbSetORder(1))//BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN
					if !Empty(xChave) .and. BEJ->(MsSeek(xFilial('BEJ')+alltrim(xChave)))
						aDados[nX, 34] := {}
						aDados[nX, 35] := {}
						aDados[nX, 36] := {}
						aDados[nX, 37] := {}
						aDados[nX, 38] := {}
						While !BEJ->(Eof()) .and. xFilial('BEJ')+xChave == BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)
							If (BEJ->BEJ_STATUS == '0' .And. lImpNAut) .Or. BEJ->BEJ_STATUS == '1'

								BD6->(DbSetOrder(6))
								If BD6->(MsSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+'1'+BEJ->(BEJ_CODPAD+BEJ_CODPRO))) .and. !Empty(BD6->BD6_SLVPAD)
									cCodTab := PLSIMPVINC("BR4","87"	,	BD6->BD6_CODPAD					,.F.)
									cCodPro := PLSIMPVINC("BR8",cCodTab	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.F.)
									cDescri := PLSIMPVINC("BR8",cCodTab	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.T.)
								Else
									cCodTab := PLSIMPVINC("BR4","87"	,	BEJ->BEJ_CODPAD					,.F.)
									cCodPro := PLSIMPVINC("BR8",cCodTab	,	BEJ->BEJ_CODPAD+BEJ->BEJ_CODPRO	,.F.)
									cDescri := PLSIMPVINC("BR8",cCodTab	,	BEJ->BEJ_CODPAD+BEJ->BEJ_CODPRO	,.T.)
								Endif
						      
								IF ALLTRIM(cCodPro) $ cTdsCodG
									cDescri:= BEJ->BEJ_DESPRO
								EndIf
                            
								If Empty(cCodTab) .Or. Empty(cCodPro) .Or. Empty(cDescri)
									cCodTab := BEJ->BEJ_CODPAD
									cCodPro := BEJ->BEJ_CODPRO
									cDescri := Posicione("BR8",1, xFilial("BR8")+BEJ->(BEJ_CODPAD+BEJ_CODPRO), "BR8_DESCRI")
								Endif
    
								aAdd(aDados[nX, 34], cCodTab)
								aAdd(aDados[nX, 35], cCodPro)
								aAdd(aDados[nX, 36], cDescri)
								aAdd(aDados[nX, 37], BEJ->BEJ_QTDSOL)
								aAdd(aDados[nX, 38], IIf(BEJ->BEJ_STATUS = '1', BEJ->BEJ_QTDPRO, 0))
                        
							EndIf
                           
							BEJ->(DbSkip())
						Enddo
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
					Endif
				Endif

				If lPlsGTiss
					lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"03",lImpPrc})
				EndIf

				If lImpPrc

					For nP := nV1 To nT
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.03))*nAC, aDados[nX, 34, nP], oFont04)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.08))*nAC, aDados[nX, 35, nP], oFont04)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.19))*nAC, aDados[nX, 36, nP], oFont01)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.82))*nAC, if (aDados[nX, 37, nP]=0,"",Transform(aDados[nX, 37, nP], "@E 999")), oFont04,,,,1)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.92))*nAC, getException(aDados[nX, 37, nP],aDados[nX, 38, nP]), oFont04,,,,1)
						nLinIni += 40
					Next nP
				EndIF

				if nT < Len(aDados[nX, 35]).or. lImpnovo
					nV1:=nP
					lImpnovo:=.T.
				Endif

				nLinIni := nOldLinIni

				oPrint:Say((nLinIni + 1690)*nAL, (nColIni + 0020)*nAC, "Dados da Autorização", oFont01) //Dados da Autorização
				oPrint:Box((nLinIni + 1700)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1760)*nAL, (nColIni + (nColMax*0.26) - 0010)*nAC)
				oPrint:Say((nLinIni + 1720)*nAL, (nColIni + 0030)*nAC, "39 - Data Provável da Admissão Hospitalar", oFont01) //"39 - Data Provável da Admissão Hospitalar"
				oPrint:Say((nLinIni + 1752)*nAL, (nColIni + 0040)*nAC, DtoC(aDados[nX, 39]), oFont04)
				oPrint:Box((nLinIni + 1700)*nAL, (nColIni + (nColMax*0.26))*nAC, (nLinIni + 1760)*nAL, (nColIni + (nColMax*0.44) - 0010)*nAC)
				oPrint:Say((nLinIni + 1720)*nAL, (nColIni + (nColMax*0.26) + 0010)*nAC, "40 - Qtde. Diarias Autorizadas", oFont01) //"40 - Qtde. Diarias Autorizadas"
				oPrint:Say((nLinIni + 1752)*nAL, (nColIni + (nColMax*0.34))*nAC, if (aDados[nX, 40]=0,"",Transform(aDados[nX, 40], "@E 999")), oFont04)
				oPrint:Box((nLinIni + 1700)*nAL, (nColIni + (nColMax*0.44))*nAC, (nLinIni + 1760)*nAL, (nColIni + (nColMax*0.66) - 0010)*nAC)
				oPrint:Say((nLinIni + 1720)*nAL, (nColIni + (nColMax*0.44) + 0010)*nAC, "41 - Tipo da Acomodação Autorizada", oFont01) //"41 - Tipo da Acomodação Autorizada"
				oPrint:Say((nLinIni + 1752)*nAL, (nColIni + (nColMax*0.54))*nAC, aDados[nX, 41], oFont04)

				oPrint:Box((nLinIni + 1770)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1830)*nAL, (nColIni + (nColMax*0.27) - 0010)*nAC)
				oPrint:Say((nLinIni + 1790)*nAL, (nColIni + 0030)*nAC, "42 - Código na Operadora / CNPJ autorizado", oFont01) //"42 - Código na Operadora / CNPJ autorizado"
				oPrint:Say((nLinIni + 1822)*nAL, (nColIni + 0040)*nAC, aDados[nX, 42], oFont04)
				oPrint:Box((nLinIni + 1770)*nAL, (nColIni + (nColMax*0.27))*nAC, (nLinIni + 1830)*nAL, (nColIni + (nColMax*0.82) - 0010)*nAC)
				oPrint:Say((nLinIni + 1790)*nAL, (nColIni + (nColMax*0.27) + 0010)*nAC, "43 - Nome do Hospital / Local Autorizado", oFont01) //"43 - Nome do Hospital / Local Autorizado"
				oPrint:Say((nLinIni + 1822)*nAL, (nColIni + (nColMax*0.27) + 0020)*nAC, aDados[nX, 43], oFont04)
				oPrint:Box((nLinIni + 1770)*nAL, (nColIni + (nColMax*0.82))*nAC, (nLinIni + 1830)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1790)*nAL, (nColIni + (nColMax*0.82) + 0010)*nAC, "44 - Código CNES", oFont01) //"44 - Código CNES"
				oPrint:Say((nLinIni + 1822)*nAL, (nColIni + (nColMax*0.82) + 0020)*nAC, aDados[nX, 44], oFont04)

				oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2260)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0030)*nAC, "45 - Observação / Justificativa", oFont01) //"45 – Observação / Justificativa"

				nLinObs := 0
				For nI := 1 To MlCount(aDados[nX, 45], 100)
					cObs := MemoLine(aDados[nX, 45], 100, nI)
					oPrint:Say((nLinIni + 1892 + nLinObs)*nAL, (nColIni + 0040)*nAC, cObs, oFont04)
					nLinObs+=38
				Next nI

				oPrint:Box((nLinIni + 2270)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2330)*nAL, (nColIni + (nColMax/4) - 0010)*nAC)
				oPrint:Say((nLinIni + 2290)*nAL, (nColIni + 0030)*nAC, "46 - Data da Solicitação", oFont01) //"46 - Data da Solicitação"
				oPrint:Say((nLinIni + 2322)*nAL, (nColIni + 0040)*nAC, DtoC(aDados[nX, 46]), oFont04)
				oPrint:Box((nLinIni + 2270)*nAL, (nColIni + (nColMax/4))*nAC, (nLinIni + 2330)*nAL, (nColIni + ((nColMax/4)*2) - 0010)*nAC)
				oPrint:Say((nLinIni + 2290)*nAL, (nColIni + (nColMax/4) + 0010)*nAC, "47-Assinatura do Profissional Solicitante", oFont01) //"47-Assinatura do Profissional Solicitante"
				oPrint:Box((nLinIni + 2270)*nAL, (nColIni + ((nColMax/4)*2))*nAC, (nLinIni + 2330)*nAL, (nColIni + ((nColMax/4)*3) - 0010)*nAC)
				oPrint:Say((nLinIni + 2290)*nAL, (nColIni + ((nColMax/4)*2) + 0010)*nAC, "48-Assinatura do Beneficiário ou Responsável", oFont01) //"48-Assinatura do Beneficiário ou Responsável"
				oPrint:Box((nLinIni + 2270)*nAL, (nColIni + ((nColMax/4)*3))*nAC, (nLinIni + 2330)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 2290)*nAL, (nColIni + ((nColMax/4)*3) + 0010)*nAC, "49-Assinatura do Responsável pela Autorização", oFont01) //"49-Assinatura do Responsável pela Autorização"

				oPrint:EndPage()	// Finaliza a pagina

			Next nX

		enddo
	END SEQUENCE
	ErrorBlock( bError )

	If !Empty(cErro)
		cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
		MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
		cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
			"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
			"Tipos de Guias." + CRLF + CRLF + ;
			cErro
		PLSLogFil(cErro,cArq)
	EndIf

	If (lGerTXT .And. !lWeb) .Or. lAuto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:Print()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If lRet

			oPrint:Preview()
		Endif

		If lMail .And. (lRet:=Aviso("Atenção","Confirma o envio do relatório por e-mail?",{"Sim","Não"},1)== 1)

			If File(cFile)
				lOk := (FErase(cFile)==0)
			EndIf

			If lOk
				CpyT2S(oPrint:CPATHPDF+LOWER(cFileName),cFile,.T.)
			Else
				Aviso("Atenção","Não foi possível criar o arquivo "+cFile,{"Ok"},1)
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return {lRet,cFile+cFileName,cFileName}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSF  ³ Autor ³ Bruno Iserhardt       ³ Data ³ 25.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3.00.01 (Guia Res. Internaçao)     ³±±
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

Function PLSTISSF(aDados, lGerTXT, nLayout, cLogoGH,lWeb, cPathRelW)

	Local nLinMax
	Local nColMax
	Local nLinIni := 0		// Linha Lateral (inicial) Esquerda
	Local nColIni := 0		// Coluna Lateral (inicial) Esquerda
	Local nColA4  := 0
	Local nCol2A4 := 0
	Local cFileLogo
	Local lPrinter
	Local nLin 	:= 0
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
	Local nAte    := 22
	Local nAte1   := 26
	Local nAte2   := 5

	LOCAL nLwebC := 0
	LOCAL nLweb  := 0
	LOCAl nTweb  := 1
	LOCAL nWeb	  := 0
	local oPrint  := nil	//07-12
	LOCAL cPathSrvJ := GETMV("MV_RELT") //07-12
	LOCAL cFileName := "" //07-12
	LOCAL cErro		:= ""
	LOCAL cArq			:= ""
	LOCAL cRel      := "resinte"
	//Local bError		:= ErrorBlock( {|e| TrataErro(e,@cErro) } )

	Default lGerTXT := .F.
	Default nLayout := 2
	Default cLogoGH := ''
	DEFAULT lWeb		:= .F. /*07-12*/
	DEFAULT cPathRelW 	:= ""  /*07-12*/

	Default aDados := { { ;
		"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- Nº Guia no Prestador
	"12345678901234567890",; //3 - Número da Guia de Solicitação de Internação
	CtoD("01/01/07"),; //4 - Data da Autorização
	"12345678901234567890",; //5 - Senha
	CtoD("01/01/07"),; //6 - Data de Validade da Senha
	"12345678901234567890",; //7- Número da Guia Atribuído pela Operadora
	"12345678901234567890",; //8 - Número da Carteira
	CtoD("12/12/07"),; //9 - Validade da Carteira
	Replicate("M",70),; //10- Nome
	"123456789012345",; //11 - Cartão Nacional de Saúde
	"S",; //12-Atendimento a RN
	"12345678901234",; //13 - Código na Operadora
	Replicate("M",70),; //14 - Nome do Contratado
	"1234567",; //15 - Código CNES
	"U",; //16 - Caráter do Atendimento
	"T",; //17 - Tipo de Faturamento
	CtoD("12/12/07"),; //18- Data do Início do Faturamento
	"00:00",; //19- Hora do Início do Faturamento
	CtoD("12/12/07"),; //20- Data do Fim do Faturamento
	"99:99",; //21- Hora do Fim do Faturamento
	"I",; //22- Tipo de Internação
	"E",; //23- Regime de Internação
	"0000",; //24 - CID 10 Principal
	"1111",; //25 - CID 10 (2)
	"2222",; //26 - CID 10 (3)
	"3333",; //27 - CID 10 (4)
	"1",; //28 - Indicação de Acidente (acidente ou doença relacionada)
	"00",; //29 - Motivo de Encerramento da Internação
	"12345678901",; //30-Número da declaração de nascido vivo
	"4444",; //31 - CID 10 Óbito
	"12345678901",; //32 - Numero da declaração de óbito
	"N",; //33 -Indicador D.O. de RN
	{ CtoD("12/01/06"),CtoD("12/02/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06")},; //34-Data
	{ "0107","0207","0307","0407","0507"},; //35-Hora Inicial
	{ "0607","0707","0807","0907","1007"},; //36-Hora Final
	{ "10", "20", "30", "40", "50", "60" },; //37-Tabela
	{ "1234567890","2345678901","3456789012","4567890123","5678901234","5678901234"},; //38-Código do Procedimento
	{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60),Replicate("E",60)},; //39-Descrição
	{ "0", "1", "2", "3", "4"},; //40-Qtde.
	{ "0", "1", "2", "3", "4"},; //41-Via
	{ "0", "1", "2", "3", "4"},; //42-Téc
	{ 111.00,222.00,333.00,444.00,999.99},; //43-Fator Red/Acresc
	{ 99999.99,22222.22,33.33,44444.44},; //44-Valor Unitário (R$)
	{ 111111.11,555555.00,666666.00,777777.00,888888.00},; //45-Valor Total (R$)
	{ "01", "02", "03", "04", "05"},; //46-Seq.Ref
	{ "02", "03", "04", "05", "06"},; //47-Grau Part.
	{ Replicate("M",14), Replicate("D",14), Replicate("C",14), Replicate("A",14)},; //48-Código na Operadora/CPF
	{ Replicate("A", 70), Replicate("B", 70), Replicate("C", 70), Replicate("D", 70), Replicate("E", 70)},; //49-Nome do Profissional
	{ "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01"},; //50-Conselho Profissional
	{ "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345"},; //51-Número no Conselho
	{ "01", "02", "03", "04", "05"},; //52-UF
	{ "123456", "123456", "123456", "123456", "123456"},; //53-Código CBO
	19999900.99,; //54 - Total de Procedimentos (R$)
	19999900.99,; //55 - Total de Diárias (R$)
	19999900.99,; //56 - Total de Taxase Aluguéis (R$)
	19999900.99,; //57 - Total de Materiais (R$)
	19999900.99,; //59- Total de OPME (R$)
	19999900.99,; //58 - Total de Medicamentos (R$)
	19999900.99,; //60 - Total de Gases Medicinais (R$)
	19999900.99,; //61 - Total Geral (R$)
	CtoD("01/01/07"),; //62- Data da assinatura do contratado
	Replicate("M",500) } } //65 – Observações / Justificativa

	If nLayout  == 1 // Ofício 2
		nLinMax := 2385
		nColMax := 3705	//3765
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2325
		nColMax	:=	3370 //3365
	Else //Carta
		nLinMax	:=	2385
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  6,  5, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
		oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	if !lWeb
		oPrint	:= TMSPrinter():New("GUIA DE RESUMO DE INTERNACAO") //"GUIA DE RESUMO DE INTERNACAO"
	else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
		nTweb		:= 3.9
		nLweb		:= 10
		nLwebC		:= -3
		nColMax		:= 3100
		nWeb		:= 25
		oPrint:lServer := lWeb
	Endif

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Device
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		oPrint:setDevice(IMP_PDF)
	Else
	// Verifica se existe alguma impressora configurada para Impressao Grafica
		lPrinter := oPrint:IsPrinterActive()

		If ! lPrinter
			oPrint:Setup()
		EndIf
	Endif

	BEGIN SEQUENCE
		While lImpnovo

			lImpnovo:=.F.
			nVolta  += 1
			nAte    += nP
			nAte1   += nP1
			nAte2   += nP4

			For nX := 1 To Len(aDados)

				If Len(aDados[nX]) == 0
					Loop
				EndIf

				For nI := 34 To 45
					If Len(aDados[nX, nI]) < nAte
						For nJ := Len(aDados[nX, nI]) + 1 To nAte
							If AllTrim(Str(nI)) $ "34"
								aAdd(aDados[nX, nI], StoD(""))
							ElseIf AllTrim(Str(nI)) $ "40,43,44,45"
								aAdd(aDados[nX, nI], 0)
							Else
								aAdd(aDados[nX, nI], "")
							EndIf
						Next nJ
					EndIf
				Next nI

				For nI := 46 To 53
					If Len(aDados[nX, nI]) < nAte1
						For nJ := Len(aDados[nX, nI]) + 1 To nAte1
							aAdd(aDados[nX, nI], "")
						Next nJ
					EndIf
				Next nI

				nLinIni := 080
				nColIni := 080
				nLin 	:= 000
				nColA4  := 000
				nCol2A4 := 000

				oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fLogoEmp(@cFileLogo,, cLogoGH)

				If File(cFilelogo)
					oPrint:SayBitmap((nLinIni + 0040)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (080)/nTweb)
				EndIf

				If nLayout == 2 // Papél A4
					nColA4    := -0335
				Elseif nLayout == 3// Carta
					nColA4    := -0530
				Endif

				oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "GUIA DE RESUMO DE INTERNAÇÃO", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
				oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 750)/nTweb, "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
				oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02], oFont03n)

				oPrint:Box((nLinIni + 0150 -nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0220 - nWeb) /nTweb, (nColIni + (nColMax*0.10) - 0010) /nTweb)
				oPrint:Say((nLinIni + 0155) /nTweb, (nColIni + 0030) /nTweb, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
				oPrint:Say((nLinIni + 0185) /nTweb, (nColIni + 0040) /nTweb, aDados[nX, 01], oFont04)
				oPrint:Box((nLinIni + 0150 - nWeb) /nTweb, (nColIni + (nColMax*0.10)) /nTweb, (nLinIni + 0220 - nWeb) /nTweb, (nColIni + (nColMax*0.36) - 0010) /nTweb)
				oPrint:Say((nLinIni + 0155) /nTweb, (nColIni + (nColMax*0.10) + 0010) /nTweb, "3 - Número da Guia de Solicitação de Internação", oFont01) //"3 - Número da Guia de Solicitação de Internação"
				oPrint:Say((nLinIni + 0185) /nTweb, (nColIni + (nColMax*0.10) + 0020) /nTweb, aDados[nX, 03], oFont04)

				oPrint:Box((nLinIni + 0230 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.14) - 0010) /nTweb)
				oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + 0030) /nTweb, "4 - Data da Autorização", oFont01) //"4 - Data da Autorização"
				oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + 0040) /nTweb, DtoC(aDados[nX, 04]), oFont04)
				oPrint:Box((nLinIni + 0230 - nWeb) /nTweb, (nColIni + (nColMax*0.14)) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.42) - 0010) /nTweb)
				oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + (nColMax*0.14) + 0010) /nTweb, "5 - Senha", oFont01) //"5 - Senha"
				oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + (nColMax*0.14) + 0020) /nTweb, aDados[nX, 05], oFont04)
				oPrint:Box((nLinIni + 0230 - nWeb) /nTweb, (nColIni + (nColMax*0.42)) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.55) - 0010) /nTweb)
				oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + (nColMax*0.42) + 0010) /nTweb, "6 - Data de Validade da Senha", oFont01) //"6 - Data de Validade da Senha"
				oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + (nColMax*0.42) + 0020) /nTweb, DtoC(aDados[nX, 06]), oFont04)
				oPrint:Box((nLinIni + 0230 -nWeb) /nTweb, (nColIni + (nColMax*0.55)) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.82) - 0010) /nTweb)
				oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + (nColMax*0.55) + 0010) /nTweb, "7- Número da Guia Atribuído pela Operadora", oFont01) //"7- Número da Guia Atribuído pela Operadora"
				oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + (nColMax*0.55) + 0020) /nTweb, aDados[nX, 07], oFont04)

				If !lWeb
					AddTBrush(oPrint, nLinIni + 0307, nColIni + 0010, nLinIni + 0337, nColIni + nColMax)
				EndIf

				oPrint:Say((nLinIni + 0310) /nTweb, (nColIni + 0020) /nTweb, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
				oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.15) - 00100 /nTweb))
				oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + 0030) /nTweb, "8 - Número da Carteira", oFont01) //"8 - Número da Carteira"
				oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + 0040) /nTweb, aDados[nX, 08], oFont04)
				oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.15)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.26) - 0010) /nTweb)
				oPrint:Say((nLinIni + 0345) /nTweb , (nColIni + (nColMax*0.15) + 0010) /nTweb, "9 - Validade da Carteira", oFont01) //"9 - Validade da Carteira"
				oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.15) + 0020) /nTweb, DtoC(aDados[nX, 09]), oFont04)

				If PLSTISSVER() < "4"
					oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.26)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.74) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + (nColMax*0.26) + 0010) /nTweb, "10- Nome", oFont01) //"10- Nome"
					oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.26) + 0020) /nTweb, aDados[nX, 10], oFont04)
					oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.74)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.92) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + (nColMax*0.74) + 0010) /nTweb, "11 - Cartão Nacional de Saúde", oFont01) //"11 - Cartão Nacional de Saúde"
					oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.74) + 0020) /nTweb, aDados[nX, 11], oFont04)
					oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + (nColMax*0.92) + 0010) /nTweb, "12 - Atendimento a RN", oFont01) //"12 - Atendimento a RN"
					oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.92) + 0020) /nTweb, aDados[nX, 12], oFont04)

					If !lWeb
						AddTBrush(oPrint, nLinIni + 0417, nColIni + 0010, nLinIni + 0447, nColIni + nColMax)
					Endif

					oPrint:Say((nLinIni + 0420) /nTweb, (nColIni + 0020) /nTweb, "Dados do Contratado Executante", oFont01) //"Dados do Contratado Executante"
					oPrint:Box((nLinIni + 0450 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0520 - nWeb) /nTweb, (nColIni + (nColMax*0.20) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + 0030) /nTweb, "13 - Código na Operadora", oFont01) //"13 - Código na Operadora"
					oPrint:Say((nLinIni + 0485) /nTweb, (nColIni + 0040) /nTweb, aDados[nX, 13], oFont04)
					oPrint:Box((nLinIni + 0450 - nWeb) /nTweb, (nColIni + (nColMax*0.20)) /nTweb, (nLinIni + 0520 - nWeb) /nTweb,  (nColIni + (nColMax*0.90) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + (nColMax*0.20) + 0010) /nTweb, "14 - Nome do Contratado", oFont01) //"14 - Nome do Contratado"
					oPrint:Say((nLinIni + 0485) /nTweb, (nColIni + (nColMax*0.20) + 0020) /nTweb, aDados[nX, 14], oFont04)
					oPrint:Box((nLinIni + 0450 - nWeb) /nTweb, (nColIni + (nColMax*0.90)) /nTweb, (nLinIni + 0520 - nWeb) /nTweb,  (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + (nColMax*0.90) + 0010) /nTweb, "15 - Código CNES", oFont01) //"15 - Código CNES"
					oPrint:Say((nLinIni + 0485) /nTweb, (nColIni + (nColMax*0.90) + 0020) /nTweb, aDados[nX, 15], oFont04)

					If !lWeb
						AddTBrush(oPrint, nLinIni + 0527, nColIni + 0010, nLinIni + 0557, nColIni + nColMax)
					EndIf

					oPrint:Say((nLinIni + 0530) /nTweb, (nColIni + 0020) /nTweb, "Dados da Internação", oFont01) //"Dados da Internação"
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.10) - 0010) /nTweb)
					oPrint:Say((nLinIni + 05650) /nTweb, (nColIni + 0030) /nTweb, "16 - Caráter do Atendimento", oFont01) //"16 - Caráter do Atendimento"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + 0140) /nTweb, aDados[nX, 16], oFont04)
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.10)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.20) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.10) + 0010) /nTweb, "17 - Tipo de Faturamento", oFont01) //"17 - Tipo de Faturamento"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.10) + 0020) /nTweb, aDados[nX, 17], oFont04)
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.20)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.35) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.20) + 0010) /nTweb, "18- Data do Início do Faturamento", oFont01) //"18- Data do Início do Faturamento"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.20) + 0020) /nTweb, DtoC(aDados[nX, 18]), oFont04)
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.35)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.47) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.35) + 0010) /nTweb, "19- Hora do Início do Faturamento", oFont01) //"19- Hora do Início do Faturamento"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.35) + 0020) /nTweb, IIf(Empty(aDados[nX, 19]), "", Transform(aDados[nX, 19], "@R 99:99")), oFont04)
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.47)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.62) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.47) + 00100) /nTweb, "20- Data do Fim do Faturamento", oFont01) //"20- Data do Fim do Faturamento"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.47) + 0020) /nTweb, DtoC(aDados[nX, 20]), oFont04)
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.62)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.74) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.62) + 0010) /nTweb, "21- Hora do Fim do Faturamento", oFont01) //"21- Hora do Fim do Faturamento"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.62) + 0020) /nTweb, IIf(Empty(aDados[nX, 21]), "", Transform(aDados[nX, 21], "@R 99:99")), oFont04)
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.74)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.82) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.74) + 00100) /nTweb, "22- Tipo de Internação", oFont01) //"22- Tipo de Internação"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.74) + 0020) /nTweb, aDados[nX, 22], oFont04)
					oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.82)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.91) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.82) + 0010) /nTweb, "23- Regime de Internação", oFont01) //"23- Regime de Internação"
					oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.82) + 0020) /nTweb, aDados[nX, 23], oFont04)

					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.07) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + 0022) /nTweb, "24-CID 10 Principal", oFont01) //"24 - CID 10 Principal"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + 0040) /nTweb, aDados[nX, 24], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.07)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.14) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.07) + 0010) /nTweb, "25 - CID 10 (2)", oFont01) //"25 - CID 10 (2)"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.07) + 0020) /nTweb, aDados[nX, 25], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.14)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.21) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.14) + 0010) /nTweb, "26 - CID 10 (3)", oFont01) //"26 - CID 10 (3)"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.14) + 0020) /nTweb, aDados[nX, 26], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.21)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.28) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.21) + 0010) /nTweb, "27 - CID 10 (4)", oFont01) //"27 - CID 10 (4)"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.21) + 00200) /nTweb, aDados[nX, 27], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.28)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.39) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0642) /nTweb, (nColIni + (nColMax*0.28) + 001) /nTweb, "28 - Indicação de Acidente", oFont01) //"28 - Indicação de Acidente"
					oPrint:Say((nLinIni + 0657) /nTweb, (nColIni + (nColMax*0.28) + 0010) /nTweb, "(acidente ou doença relacionada)", oFont01) //"acidente ou doença relacionada)"
					oPrint:Say((nLinIni + 0677) /nTweb, (nColIni + (nColMax*0.28) + 0020) /nTweb, aDados[nX, 28], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.39)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.52) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.39) + 0010) /nTweb, "29-Motivo de Encerramento da Internação", oFont01) //"29 - Motivo de Encerramento da Internação"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.39) + 0020) /nTweb, aDados[nX, 29], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.52)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.68) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.52) + 0010) /nTweb, "30-Número da declaração de nascido vivo", oFont01) //"30-Número da declaração de nascido vivo"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.52) + 0020) /nTweb, aDados[nX, 30], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.68)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.76) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.68) + 0010) /nTweb, "31 - CID 10 Óbito", oFont01) //"31 - CID 10 Óbito"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.68) + 0020) /nTweb, aDados[nX, 31], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.76)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.92) - 00100 )/nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.76) + 0010) /nTweb, "32 - Numero da declaração de óbito", oFont01) //"32 - Numero da declaração de óbito"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.76) + 0020) /nTweb, aDados[nX, 32], oFont04)
					oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.92) + 0010) /nTweb, "33 -Indicador D.O. de RN", oFont01) //"33 -Indicador D.O. de RN"
					oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.92) + 0020) /nTweb, aDados[nX, 33], oFont04)

					If !lWeb
						AddTBrush(oPrint, nLinIni + 0717, nColIni + 0010, nLinIni + 0747, nColIni + nColMax)
					EndIf

					oPrint:Say((nLinIni + 0720) /nTweb, (nColIni + 0020) /nTweb, "Procedimentos e Exames Realizados", oFont01) //"Procedimentos e Exames Realizados"
					oPrint:Box((nLinIni + 0750 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 1310 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, "34-Data", oFont01) //"34-Data"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.08)) /nTweb, "35-Hora Inicial", oFont01) //"35-Hora Inicial"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.13)) /nTweb, "36-Hora Final", oFont01) //"36-Hora Final"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.18)) /nTweb, "37-Tabela", oFont01) //"37-Tabela"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.22)) /nTweb, "38-Código do Procedimento", oFont01) //"38-Código do Procedimento"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.30)) /nTweb, "39-Descrição", oFont01) //"39-Descrição"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.69)) /nTweb, "40-Qtde.", oFont01) //"40-Qtde."
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.73)) /nTweb, "41-Via", oFont01) //"41-Via"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.76)) /nTweb, "42-Téc", oFont01) //"42-Téc"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.79)) /nTweb, "43-Fator Red/Acresc", oFont01) //"43-Fator Red/Acresc"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.86)) /nTweb, "44-Valor Unitário (R$)", oFont01) //"44-Valor Unitário (R$)"
					oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.93)) /nTweb, "45-Valor Total (R$)", oFont01) //"45-Valor Total (R$)"

					nOldLinIni := nLinIni
					if nVolta=1
						nP:=1
					Endif
					nT:=nP+9
					For nI := nP To nT
						if nVolta <> 1
							nN:=nI-(15*nVolta-15)
							oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nN)) + " - ", oFont01)
						else
							oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nI)) + " - ", oFont01)
						Endif
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, IIf(Valtype(aDados[nX, 34, nI])== "D", DtoC(aDados[nX, 34, nI]),aDados[nX, 34, nI]), oFont04) //"34-Data"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.087)) /nTweb, IIf(Empty(aDados[nX, 35, nI]), "", Transform(aDados[nX, 35, nI], "@R 99:99")), oFont04) //"35-Hora Inicial"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.137)) /nTweb, IIf(Empty(aDados[nX, 36, nI]), "", Transform(aDados[nX, 36, nI], "@R 99:99")), oFont04) //"36-Hora Final"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.185)) /nTweb, aDados[nX, 37, nI], oFont04) //"37-Tabela"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.22)) /nTweb, aDados[nX, 38, nI], oFont04) //"38-Código do Procedimento"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.30)) /nTweb, aDados[nX, 39, nI], oFont04) //"39-Descrição"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.705)) /nTweb, IIf(Empty(aDados[nX, 40, nI]), "", Transform(aDados[nX, 40, nI], "@E 999")), oFont04,,,,1) //"40-Qtde."
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.733)) /nTweb, aDados[nX, 41, nI], oFont04) //"41-Via"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.765)) /nTweb, aDados[nX, 42, nI], oFont04) //"42-Téc"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.82)) /nTweb, IIf(Empty(aDados[nX, 43, nI]), "", Transform(aDados[nX, 43, nI], "@E 999.99")), oFont04,,,,1) //"43-Fator Red/Acresc"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, IIf(Empty(aDados[nX, 44, nI]), "", Transform(aDados[nX, 44, nI], "@E 99,999,999.99")), oFont04,,,,1) //"44-Valor Unitário (R$)"
						oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.99)) /nTweb, IIf(Empty(aDados[nX, 45, nI]), "", Transform(aDados[nX, 45, nI], "@E 99,999,999.99")), oFont04,,,,1) //45-Valor Total (R$)
						nLinIni += 50
					Next nI

				Else
					oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.26)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.74) ) /nTweb)	
					oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + (nColMax*0.26) + 0010) /nTweb, "66 - Nome Socia", oFont01) //"66 - Nome Socia"
					oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.26) + 0020) /nTweb, aDados[nX, 66], oFont04)
					oPrint:Box((nLinIni + 0420 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0490 - nWeb) /nTweb, (nColIni + (nColMax*0.92) /nTweb))
					oPrint:Say((nLinIni + 0425) /nTweb, (nColIni + 0030) /nTweb, "10- Nome", oFont01) //"10- Nome"
					oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + 0040) /nTweb, aDados[nX, 10], oFont04)
			
					oPrint:Box((nLinIni + 0420 - nWeb) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, (nLinIni + 0490 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0425) /nTweb, (nColIni + (nColMax*0.92) + 0010) /nTweb, "12 - Atendimento a RN", oFont01) //"12 - Atendimento a RN"
					oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + (nColMax*0.92) + 0020) /nTweb, aDados[nX, 12], oFont04)


					oPrint:Say((nLinIni + 0500) /nTweb, (nColIni + 0020) /nTweb, "Dados do Contratado Executante", oFont01) //"Dados do Contratado Executante"
					oPrint:Box((nLinIni + 0530 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0600 - nWeb) /nTweb, (nColIni + (nColMax*0.20) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0535) /nTweb, (nColIni + 0030) /nTweb, "13 - Código na Operadora", oFont01) //"13 - Código na Operadora"
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + 0040) /nTweb, aDados[nX, 13], oFont04)
					oPrint:Box((nLinIni + 0530 - nWeb) /nTweb, (nColIni + (nColMax*0.20)) /nTweb, (nLinIni + 0600 - nWeb) /nTweb,  (nColIni + (nColMax*0.90) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0535) /nTweb, (nColIni + (nColMax*0.20) + 0010) /nTweb, "14 - Nome do Contratado", oFont01) //"14 - Nome do Contratado"
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.20) + 0020) /nTweb, aDados[nX, 14], oFont04)
					oPrint:Box((nLinIni + 0530 - nWeb) /nTweb, (nColIni + (nColMax*0.90)) /nTweb, (nLinIni + 0600 - nWeb) /nTweb,  (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0535) /nTweb, (nColIni + (nColMax*0.90) + 0010) /nTweb, "15 - Código CNES", oFont01) //"15 - Código CNES"
					oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.90) + 0020) /nTweb, aDados[nX, 15], oFont04)

					

					oPrint:Say((nLinIni + 0600) /nTweb, (nColIni + 0020) /nTweb, "Dados da Internação", oFont01) //"Dados da Internação"
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0690 - nWeb) /nTweb, (nColIni + (nColMax*0.10) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0635) /nTweb, (nColIni + 0030) /nTweb, "16 - Caráter do Atendimento", oFont01) //"16 - Caráter do Atendimento"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + 0140) /nTweb, aDados[nX, 16], oFont04)
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + (nColMax*0.10)) /nTweb, (nLinIni + 0690 - nWeb) /nTweb, (nColIni + (nColMax*0.20) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0625) /nTweb, (nColIni + (nColMax*0.10) + 0010) /nTweb, "17 - Tipo de Faturamento", oFont01) //"17 - Tipo de Faturamento"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + (nColMax*0.10) + 0020) /nTweb, aDados[nX, 17], oFont04)
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + (nColMax*0.20)) /nTweb, (nLinIni + 0690 - nWeb) /nTweb, (nColIni + (nColMax*0.35) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0635) /nTweb, (nColIni + (nColMax*0.20) + 0010) /nTweb, "18- Data do Início do Faturamento", oFont01) //"18- Data do Início do Faturamento"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + (nColMax*0.20) + 0020) /nTweb, DtoC(aDados[nX, 18]), oFont04)
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + (nColMax*0.35)) /nTweb, (nLinIni + 0690 - nWeb) /nTweb, (nColIni + (nColMax*0.47) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0625) /nTweb, (nColIni + (nColMax*0.35) + 0010) /nTweb, "19- Hora do Início do Faturamento", oFont01) //"19- Hora do Início do Faturamento"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + (nColMax*0.35) + 0020) /nTweb, IIf(Empty(aDados[nX, 19]), "", Transform(aDados[nX, 19], "@R 99:99")), oFont04)
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + (nColMax*0.47)) /nTweb, (nLinIni + 0690 - nWeb) /nTweb, (nColIni + (nColMax*0.62) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0625) /nTweb, (nColIni + (nColMax*0.47) + 00100) /nTweb, "20- Data do Fim do Faturamento", oFont01) //"20- Data do Fim do Faturamento"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + (nColMax*0.47) + 0020) /nTweb, DtoC(aDados[nX, 20]), oFont04)
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + (nColMax*0.62)) /nTweb, (nLinIni + 0690 - nWeb) /nTweb, (nColIni + (nColMax*0.74) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0625) /nTweb, (nColIni + (nColMax*0.62) + 0010) /nTweb, "21- Hora do Fim do Faturamento", oFont01) //"21- Hora do Fim do Faturamento"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + (nColMax*0.62) + 0020) /nTweb, IIf(Empty(aDados[nX, 21]), "", Transform(aDados[nX, 21], "@R 99:99")), oFont04)
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + (nColMax*0.74)) /nTweb, (nLinIni + 0690 - nWeb) /nTweb, (nColIni + (nColMax*0.82) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0625) /nTweb, (nColIni + (nColMax*0.74) + 00100) /nTweb, "22- Tipo de Internação", oFont01) //"22- Tipo de Internação"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + (nColMax*0.74) + 0020) /nTweb, aDados[nX, 22], oFont04)
					oPrint:Box((nLinIni + 0620 - nWeb) /nTweb, (nColIni + (nColMax*0.82)) /nTweb, (nLinIni + 690 - nWeb) /nTweb, (nColIni + (nColMax*0.91) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0625) /nTweb, (nColIni + (nColMax*0.82) + 0010) /nTweb, "23- Regime de Internação", oFont01) //"23- Regime de Internação"
					oPrint:Say((nLinIni + 0655) /nTweb, (nColIni + (nColMax*0.82) + 0020) /nTweb, aDados[nX, 23], oFont04)

					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.07) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + 0032) /nTweb, "24-CID 10 Principal", oFont01) //"24 - CID 10 Principal"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + 0040) /nTweb, aDados[nX, 24], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.07)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.14) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.07) + 0010) /nTweb, "25 - CID 10 (2)", oFont01) //"25 - CID 10 (2)"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.07) + 0020) /nTweb, aDados[nX, 25], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.14)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.21) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.14) + 0010) /nTweb, "26 - CID 10 (3)", oFont01) //"26 - CID 10 (3)"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.14) + 0020) /nTweb, aDados[nX, 26], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.21)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.28) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.21) + 0010) /nTweb, "27 - CID 10 (4)", oFont01) //"27 - CID 10 (4)"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.21) + 00200) /nTweb, aDados[nX, 27], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.28)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.39) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.28) + 001) /nTweb, "28 - Indicação de Acidente", oFont01) //"28 - Indicação de Acidente"
					oPrint:Say((nLinIni + 0730) /nTweb, (nColIni + (nColMax*0.28) + 0010) /nTweb, "(acidente ou doença relacionada)", oFont01) //"acidente ou doença relacionada)"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.28) + 0020) /nTweb, aDados[nX, 28], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.39)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.52) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.39) + 0010) /nTweb, "29-Motivo de Encerramento da Internação", oFont01) //"29 - Motivo de Encerramento da Internação"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.39) + 0020) /nTweb, aDados[nX, 29], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.52)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.68) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.52) + 0010) /nTweb, "30-Número da declaração de nascido vivo", oFont01) //"30-Número da declaração de nascido vivo"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.52) + 0020) /nTweb, aDados[nX, 30], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.68)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.76) - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.68) + 0010) /nTweb, "31 - CID 10 Óbito", oFont01) //"31 - CID 10 Óbito"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.68) + 0020) /nTweb, aDados[nX, 31], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.76)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + (nColMax*0.92) - 00100 )/nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.76) + 0010) /nTweb, "32 - Numero da declaração de óbito", oFont01) //"32 - Numero da declaração de óbito"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.76) + 0020) /nTweb, aDados[nX, 32], oFont04)
					oPrint:Box((nLinIni + 0700 - nWeb) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, (nLinIni + 0770 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0710) /nTweb, (nColIni + (nColMax*0.92) + 0010) /nTweb, "33 -Indicador D.O. de RN", oFont01) //"33 -Indicador D.O. de RN"
					oPrint:Say((nLinIni + 0735) /nTweb, (nColIni + (nColMax*0.92) + 0020) /nTweb, aDados[nX, 33], oFont04)


					oPrint:Say((nLinIni + 0770) /nTweb, (nColIni + 0020) /nTweb, "Procedimentos e Exames Realizados", oFont01) //"Procedimentos e Exames Realizados"
					oPrint:Box((nLinIni + 0800 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 1310 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, "34-Data", oFont01) //"34-Data"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.08)) /nTweb, "35-Hora Inicial", oFont01) //"35-Hora Inicial"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.13)) /nTweb, "36-Hora Final", oFont01) //"36-Hora Final"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.18)) /nTweb, "37-Tabela", oFont01) //"37-Tabela"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.22)) /nTweb, "38-Código do Procedimento", oFont01) //"38-Código do Procedimento"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.30)) /nTweb, "39-Descrição", oFont01) //"39-Descrição"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.69)) /nTweb, "40-Qtde.", oFont01) //"40-Qtde."
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.73)) /nTweb, "41-Via", oFont01) //"41-Via"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.76)) /nTweb, "42-Téc", oFont01) //"42-Téc"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.79)) /nTweb, "43-Fator Red/Acresc", oFont01) //"43-Fator Red/Acresc"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.86)) /nTweb, "44-Valor Unitário (R$)", oFont01) //"44-Valor Unitário (R$)"
					oPrint:Say((nLinIni + 0810) /nTweb, (nColIni + (nColMax*0.93)) /nTweb, "45-Valor Total (R$)", oFont01) //"45-Valor Total (R$)"

					nOldLinIni := nLinIni
					if nVolta=1
						nP:=1
					Endif
					nT:=nP+9
					For nI := nP To nT
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nI)) + " - ", oFont01)
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, IIf(Valtype(aDados[nX, 34, nI])== "D", DtoC(aDados[nX, 34, nI]),aDados[nX, 34, nI]), oFont04) //"34-Data"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.087)) /nTweb, IIf(Empty(aDados[nX, 35, nI]), "", Transform(aDados[nX, 35, nI], "@R 99:99")), oFont04) //"35-Hora Inicial"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.137)) /nTweb, IIf(Empty(aDados[nX, 36, nI]), "", Transform(aDados[nX, 36, nI], "@R 99:99")), oFont04) //"36-Hora Final"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.185)) /nTweb, aDados[nX, 37, nI], oFont04) //"37-Tabela"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.22)) /nTweb, aDados[nX, 38, nI], oFont04) //"38-Código do Procedimento"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.30)) /nTweb, aDados[nX, 39, nI], oFont04) //"39-Descrição"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.705)) /nTweb, IIf(Empty(aDados[nX, 40, nI]), "", Transform(aDados[nX, 40, nI], "@E 999")), oFont04,,,,1) //"40-Qtde."
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.733)) /nTweb, aDados[nX, 41, nI], oFont04) //"41-Via"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.765)) /nTweb, aDados[nX, 42, nI], oFont04) //"42-Téc"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.82)) /nTweb, IIf(Empty(aDados[nX, 43, nI]), "", Transform(aDados[nX, 43, nI], "@E 999.99")), oFont04,,,,1) //"43-Fator Red/Acresc"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, IIf(Empty(aDados[nX, 44, nI]), "", Transform(aDados[nX, 44, nI], "@E 99,999,999.99")), oFont04,,,,1) //"44-Valor Unitário (R$)"
						oPrint:Say((nLinIni + 0825) /nTweb, (nColIni + (nColMax*0.99)) /nTweb, IIf(Empty(aDados[nX, 45, nI]), "", Transform(aDados[nX, 45, nI], "@E 99,999,999.99")), oFont04,,,,1) //45-Valor Total (R$)
						nLinIni += 50
					Next nI


				EndIF

				nLinIni := nOldLinIni
				nP:=nI

				If !lWeb
					AddTBrush(oPrint, nLinIni + 1317, nColIni + 0010, nLinIni + 1347, nColIni + nColMax)
				EndIf

				oPrint:Say((nLinIni + 1320) /nTweb, (nColIni + 0020) /nTweb, "Identificação da Equipe", oFont01) //"Identificação da Equipe"
				oPrint:Box((nLinIni + 1350 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 1830 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.01)) /nTweb, "46-Seq.Ref", oFont01) //"46-Seq.Ref"
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.05)) /nTweb, "47-Grau Part.", oFont01) //"47-Grau Part."
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.10)) /nTweb, "48-Código na Operadora/CPF", oFont01) //"48-Código na Operadora/CPF"
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.20)) /nTweb, "49-Nome do Profissional", oFont01) //"49-Nome do Profissional"
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.69)) /nTweb, "50-Conselho Profissional", oFont01) //"50-Conselho Profissional"
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.77)) /nTweb, "51-Número no Conselho", oFont01) //"51-Número no Conselho"
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.88)) /nTweb, "52-UF", oFont01) //"52-UF"
				oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, "53-Código CBO", oFont01) //"53-Código CBO"

				nOldLinIni := nLinIni
				if nVolta=1
					nP1:=1
				Endif
				nT1:=nP1+7
				For nI := nP1 To nT1
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, aDados[nX, 46, nI], oFont04) //"46-Seq.Ref"
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.06)) /nTweb, aDados[nX, 47, nI], oFont04) //"47-Grau Part."
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.10)) /nTweb, aDados[nX, 48, nI], oFont04) //"48-Código na Operadora/CPF"
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.20)) /nTweb, aDados[nX, 49, nI], oFont04) //"49-Nome do Profissional"
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.72)) /nTweb, aDados[nX, 50, nI], oFont04) //"50-Conselho Profissional"
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.77)) /nTweb, aDados[nX, 51, nI], oFont04) //"51-Número no Conselho"
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.883)) /nTweb, aDados[nX, 52, nI], oFont04) //"52-UF"
					oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, aDados[nX, 53, nI], oFont04) //"53-Código CBO"
					nLinIni += 50
				Next nI

				nP1:=nI
				nLinIni := nOldLinIni

				oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + 0030) /nTweb, "54 - Total de Procedimentos (R$)", oFont01) //"54 - Total de Procedimentos (R$)"
				oPrint:Say((nLinIni + 1885)/nTweb, (nColIni + (nColMax/8) - 0030) /nTweb, IIf(Empty(aDados[nX, 54]), "", Transform(aDados[nX, 54], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8)) /nTweb , (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*2) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8) + 0010) /nTweb, "55 - Total de Diárias (R$)", oFont01) //"55 - Total de Diárias (R$)"
				oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8*2) - 0030) /nTweb, IIf(Empty(aDados[nX, 55]), "", Transform(aDados[nX, 55], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Box((nLinIni + 1840 - nWeb)  /nTweb, (nColIni + (nColMax/8*2)) /nTweb, (nLinIni + 1930 - nWeb)  /nTweb, (nColIni + (nColMax/8*3) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*2) + 0010)  /nTweb, "56 - Total de Taxase Aluguéis (R$)", oFont01) //"56 - Total de Taxase Aluguéis (R$)"
				oPrint:Say((nLinIni + 1890) /nTweb, (nColIni + (nColMax/8*3) - 0030) /nTweb, IIf(Empty(aDados[nX, 56]), "", Transform(aDados[nX, 56], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8*3)) /nTweb , (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*4) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*3) + 0010) /nTweb, "57 - Total de Materiais (R$)", oFont01) //"57 - Total de Materiais (R$)"
				oPrint:Say((nLinIni + 1875) /nTweb, (nColIni + (nColMax/8*4) - 0030) /nTweb, IIf(Empty(aDados[nX, 57]), "", Transform(aDados[nX, 57], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Box((nLinIni + 1840 - nWeb)  /nTweb, (nColIni + (nColMax/8*4)) /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*5) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*4) + 0010) /nTweb, "58 - Total de OPME (R$)", oFont01) //"58- Total de OPME (R$)"
				oPrint:Say((nLinIni + 1875) /nTweb, (nColIni + (nColMax/8*5) - 0030) /nTweb, IIf(Empty(aDados[nX, 58]), "", Transform(aDados[nX, 58], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8*5)) /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*6) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*5) + 0010) /nTweb, "59 - Total de Medicamentos (R$)", oFont01) //"59 - Total de Medicamentos (R$)"
				oPrint:Say((nLinIni + 1875) /nTweb, (nColIni + (nColMax/8*6) - 0030) /nTweb, IIf(Empty(aDados[nX, 59]), "", Transform(aDados[nX, 59], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Box((nLinIni + 1840 - nWeb)  /nTweb, (nColIni + (nColMax/8*6)) /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*7) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*6) + 0010) /nTweb, "60 - Total de Gases Medicinais (R$)", oFont01) //"60 - Total de Gases Medicinais (R$)"
				oPrint:Say((nLinIni + 1875) /nTweb, (nColIni + (nColMax/8*7) - 0030) /nTweb, IIf(Empty(aDados[nX, 60]), "", Transform(aDados[nX, 60], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8*7))  /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
				oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*7) + 0010) /nTweb, "61 - Total Geral (R$)", oFont01) //"61 - Total Geral (R$)"
				oPrint:Say((nLinIni + 1875) /nTweb, (nColIni + nColMax - 0030) /nTweb		, IIf(Empty(aDados[nX, 61]), "", Transform(aDados[nX, 61], "@E 99,999,999.99")), oFont04,,,,1)

				oPrint:Box((nLinIni + 1940 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 2030 - nWeb) /nTweb, (nColIni + (nColMax*0.15) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1945) /nTweb, (nColIni + 0030) /nTweb, "62- Data da assinatura do contratado", oFont01) //"62- Data da assinatura do contratado"
				oPrint:Say((nLinIni + 1975) /nTweb, (nColIni + 0040) /nTweb, DtoC(aDados[nX, 62]), oFont04)
				oPrint:Box((nLinIni + 1940 - nWeb) /nTweb, (nColIni + (nColMax*0.15)) /nTweb, (nLinIni + 2030 - nWeb) /nTweb, (nColIni + (nColMax*0.525) - 0010) /nTweb)
				oPrint:Say((nLinIni + 1945) /nTweb, (nColIni + (nColMax*0.15) + 0010) /nTweb, "63- Assinatura do contratado", oFont01) //"63- Assinatura do contratado"
				oPrint:Box((nLinIni + 1940 - nWeb) /nTweb, (nColIni + (nColMax*0.525)) /nTweb, (nLinIni + 2030 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
				oPrint:Say((nLinIni + 1945) /nTweb, (nColIni + (nColMax*0.525) + 0010) /nTweb, "64-Assinatura do(s) Auditor(es) da Operadora", oFont01) //"64-Assinatura do(s) Auditor(es) da Operadora"

			//AddTBrush(oPrint, nLinIni + 2040, nColIni + 0020, nLinIni + 2270, nColIni + nColMax - 0010)
				oPrint:Box((nLinIni + 2040 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 2270 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
				oPrint:Say((nLinIni + 2050) /nTweb, (nColIni + 0030) /nTweb, "65 – Observações / Justificativa", oFont01) //"65 – Observações / Justificativa"
				For nI := 1 To MlCount(aDados[nX, 63], 130)
					cObs := MemoLine(aDados[nX, 63], 130, nI)
					oPrint:Say((nLinIni + 2080 + nLin) /nTweb, (nColIni + 0040) /nTweb, cObs, oFont04)
					nLin += 50
				Next nI

				oPrint:EndPage()	// Finaliza a pagina

			//  Verso da Guia
				oPrint:StartPage()	// Inicia uma nova pagina

				nLinIni := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Box((nLinIni + 0010) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + nLinMax) /nTweb, (nColIni + nColMax) /nTweb)

				If !lWeb
					AddTBrush(oPrint, nLinIni + 0017, nColIni + 0030, nLinIni + 0047, nColIni + nColMax)
				EndIf

				oPrint:Say((nLinIni + 0020) /nTweb, (nColIni + 0030) /nTweb, "Procedimentos e Exames Realizados", oFont01) //"Procedimentos e Exames Realizados"
				oPrint:Box((nLinIni + 0050 - nWeb) /nTweb, (nColIni + 0030) /nTweb, (nLinIni + (nLinMax*0.3) - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, "34-Data", oFont01) //"34-Data"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.08)) /nTweb, "35-Hora Inicial", oFont01) //"35-Hora Inicial"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.13)) /nTweb, "36-Hora Final", oFont01) //"36-Hora Final"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.18)) /nTweb, "37-Tabela", oFont01) //"37-Tabela"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.21)) /nTweb, "38-Código do Procedimento", oFont01) //"38-Código do Procedimento"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.30)) /nTweb, "39-Descrição", oFont01) //"39-Descrição"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.66)) /nTweb, "40-Qtde.", oFont01) //"40-Qtde."
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.69)) /nTweb, "41-Via", oFont01) //"41-Via"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.72)) /nTweb, "42-Téc", oFont01) //"42-Téc"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.76)) /nTweb, "43-Fator Red/Acresc", oFont01) //"43-Fator Red/Acresc"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.86)) /nTweb, "44-Valor Unitário (R$)", oFont01) //"44-Valor Unitário (R$)"
				oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.93)) /nTweb, "45-Valor Total (R$)", oFont01) //"45-Valor Total (R$)"

				nOldLinIni := nLinIni

				if nVolta =1
					nP:=11
				Endif
				nT2:=nP+11

				For nI := nP To nT2
					if nVolta<>1
						nN:=nI-((15*nVolta)-15)
						oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nN)) + " - ", oFont01)
					Else
						oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nI)) + " - ", oFont01)
					Endif
				
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, IIf(Valtype(aDados[nX, 34, nI])== "D", DtoC(aDados[nX, 34, nI]),aDados[nX, 34, nI]), oFont04) //"34-Data"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.087)) /nTweb, IIf(Empty(aDados[nX, 35, nI]), "", Transform(aDados[nX, 35, nI], "@R 99:99")), oFont04) //"35-Hora Inicial"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.137)) /nTweb, IIf(Empty(aDados[nX, 36, nI]), "", Transform(aDados[nX, 36, nI], "@R 99:99")), oFont04) //"36-Hora Final"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.185)) /nTweb, aDados[nX, 37, nI], oFont04) //"37-Tabela"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.21)) /nTweb, aDados[nX, 38, nI], oFont04) //"38-Código do Procedimento"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.30)) /nTweb, aDados[nX, 39, nI], oFont04) //"39-Descrição"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.68)) /nTweb, IIf(Empty(aDados[nX, 40, nI]), "", Transform(aDados[nX, 40, nI], "@E 999")), oFont04,,,,1) //"40-Qtde."
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.695)) /nTweb, aDados[nX, 41, nI], oFont04) //"41-Via"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.725)) /nTweb, aDados[nX, 42, nI], oFont04) //"42-Téc"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.80)) /nTweb, IIf(Empty(aDados[nX, 43, nI]), "", Transform(aDados[nX, 43, nI], "@E 999.99")), oFont04,,,,1) //"43-Fator Red/Acresc"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, IIf(Empty(aDados[nX, 44, nI]), "", Transform(aDados[nX, 44, nI], "@E 99,999,999.99")), oFont04,,,,1) //"44-Valor Unitário (R$)"
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.99)) /nTweb, IIf(Empty(aDados[nX, 45, nI]), "", Transform(aDados[nX, 45, nI], "@E 99,999,999.99")), oFont04,,,,1) //45-Valor Total (R$)
					nLinIni += 50
				Next nI

				nP:=nI

				if nVolta=1
					nP3:=len(aDados[nX,34])
				Endif

				if nP3 >nI-1
					lImpnovo:=.T.
				Endif

				nLinIni := nOldLinIni

				If !lWeb
					AddTBrush(oPrint, nLinIni + (nLinMax*0.3) + 0017, nColIni + 0030, nLinIni + (nLinMax*0.3) + 0047, nColIni + nColMax)
				EndIf

				oPrint:Say((nLinIni + (nLinMax*0.3) + 0020) /nTweb, (nColIni + 0030) /nTweb, "Identificação da Equipe (Continuação)", oFont01) //"Identificação da Equipe (Continuação)"
				oPrint:Box((nLinIni + (nLinMax*0.3) + 0050 - nWeb) /nTweb , (nColIni + 0030) /nTweb, (nLinIni + (nLinMax*0.73) - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.01)) /nTweb, "46-Seq.Ref", oFont01) //"46-Seq.Ref"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.05)) /nTweb, "47-Grau Part.", oFont01) //"47-Grau Part."
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.09)) /nTweb, "48-Código na Operadora/CPF", oFont01) //"48-Código na Operadora/CPF"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.18)) /nTweb, "49-Nome do Profissional", oFont01) //"49-Nome do Profissional"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.70)) /nTweb, "50-Conselho Profissional", oFont01) //"50-Conselho Profissional"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.80)) /nTweb, "51-Número no Conselho", oFont01) //"51-Número no Conselho"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.90)) /nTweb, "52-UF", oFont01) //"52-UF"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.94)) /nTweb, "53-Código CBO", oFont01) //"53-Código CBO"

				nOldLinIni := nLinIni
				if nVolta =1
					nP1:=9
				Endif
				nT3:=nP1+17

				For nI := nP1 To nT3
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.018)) /nTweb, aDados[nX, 46, nI], oFont04) //"46-Seq.Ref"
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.058)) /nTweb, aDados[nX, 47, nI], oFont04) //"47-Grau Part."
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.09)) /nTweb, aDados[nX, 48, nI], oFont04) //"48-Código na Operadora/CPF"
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.18)) /nTweb, aDados[nX, 49, nI], oFont04) //"49-Nome do Profissional"
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.728)) /nTweb, aDados[nX, 50, nI], oFont04) //"50-Conselho Profissional"
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.80)) /nTweb, aDados[nX, 51, nI], oFont04) //"51-Número no Conselho"
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.903)) /nTweb, aDados[nX, 52, nI], oFont04) //"52-UF"
					oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.94)) /nTweb, aDados[nX, 53, nI], oFont04) //"53-Código CBO"
					nLinIni += 50
				Next nI

				nP1:=nI

				if nVolta=1
					nP2:=len(aDados[nX,46])
				Endif

				if nP2 >nI-1
					lImpnovo:=.T.
				Endif

				nLinIni := nOldLinIni

				oPrint:EndPage()	// Finaliza a pagina

			Next nX

		Enddo
	END SEQUENCE
//ErrorBlock( bError )

	If !Empty(cErro)
		cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
		MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
		cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
			"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
			"Tipos de Guias." + CRLF + CRLF + ;
			cErro
		PLSLogFil(cErro,cArq)
	EndIf

	If lWeb .OR. lGerTXT
		oPrint:Print()
	Else
		oPrint:Preview()
	Endif

Return cFileName

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSH  ³ Autor ³ Bruno Iserhardt       ³ Data ³ 28.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3.00.01 (Guia Outras Despesas)     ³±±
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
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Manutenção³ Anderson ³ Substituiu TMSPRINTER pela nova FWMSPRINTER com  ³±±
±±³          ³ A. Tome  ³ ajustes para o layout para 3.0                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function PLSTISSH( aDados,nLayout,cLogoGH,lWeb,cPathRelW,lUnicaImp,lGerTXT )
	Local nLinMax
	Local nColMax
	Local nLinIni		:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni		:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    	:=  0
	Local cFileLogo
	Local nOldLinIni
	Local nI, nJ, nX
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local oFont05
	Local lImpNovo		:= .T.
	Local nAte 		:= 0
	Local nIni			:= 0
	Local lProrrog
	Local cFileName  	:= "outras" + lower( criaTrab( NIL,.F. ) )
	Local cPathSrvJ := GETMV("MV_RELT")
	
	Default lGerTXT  := .F.
	Default lWeb		:= .F.
	Default nLayout 	:= 2
	Default cLogoGH 	:= ''
	Default aDados 	:= { { ;
		"123456",; //1 - Registro ANS
	"12345678901234567890",; //2 – Número da Guia Referenciada
	"12345678901234",; //3 - Código na Operadora
	Replicate("M",70),; //4 - Nome do Contratado
	"1234567",; //5 – Código CNES
	{ "1","1","1","1","1","1","1","1","1","1","1","1","1" },; //6-CD
	{ CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06")},; //7-Data
	{ "0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507" },; //8-Hora Inicial
	{ "0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507" },; //9-Hora Final
	{ "MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD","DD"},; //10-Tabela
	{ "5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234"},; //11-Código do Item
	{ 111.1111,222.2222,333.3333,444.4444,555.5555,666.6666,777.7777,888.8888,999.9999,101.0101,202.0202,303.0303,404.0404},; //12-Qtde.
	{ "AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA","HHH","AAA","AAA","OOO" },; //13-Unidade de Medida
	{ 1.11, 2.22, 3.33, 4.44, 5.55, 6.66, 7.77, 8.88, 9.99, 1.01, 2.02, 3.03, 4.04 },; //14- Fator Red. / Acresc
	{ 111111.11, 222222.22, 333333.33, 444444.44, 555555.55, 666666.66, 777777.77, 888888.88, 999999.99, 101010.10, 202020.20, 303030.30, 404040.40 },; //15-Valor Unitário - R$
	{ 111111.11, 222222.22, 333333.33, 444444.44, 555555.55, 666666.66, 777777.77, 888888.88, 999999.99, 101010.10, 202020.20, 303030.30, 404040.40 },; //16-Valor Total – R$
	{ "123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345","123456789012345" },; //17-Registro ANVISA do Material
	{ "123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890" },; //18-Referência do material no fabricante
	{ "123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890","123456789012345678901234567890" },; //19-Nº Autorização de Funcionamento
	{ Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150) },; //20-Descrição
	39999999.99,; //21 - Total de Gases Medicinais (R$)
	39999999.99,; //22 - Total de Medicamentos (R$)
	39999999.99,; //23 - Total de Materiais (R$)
	39999999.99,; //24 - Total de OPME (R$)
	39999999.99,; //25 - Total de Taxas e Aluguéis (R$)
	39999999.99,; //26 - Total de Diárias (R$)
	39999999.99 } } //27 - Total Geral (R$)

	if ( lWeb )
		cPathSrvJ := cPathRelW
		cFileName := cFileName + ".pdf"
	endIf

	oPrint := FWMSPrinter():New ( cFileName,,.F.,cPathSrvJ,.T.,,,,,.F.,, )

	if ( lWeb )
		oPrint:lServer := lWeb
	endIf

	oPrint:SetLandscape()		// Modo paisagem

	if ( lWeb )
		oPrint:setDevice(IMP_PDF)
	endIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Setup()

	If oPrint:nPaperSize  == 9 // Papél A4
		nLinMax	:= 570
		nColMax	:= 820
		nLayout 	:= 2
		oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Elseif oPrint:nPaperSize == 1 // Papel Carta
		nLinMax	:= 570
		nColMax	:= 820
		nLayout 	:= 3
		oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		nLinMax	:= 570
		nColMax	:= 820
		nLayout 	:= 1
		oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Endif

	For nX := 1 To Len(aDados)

		nAte := 0
		nIni := 1

		If Len(aDados[nX]) == 0
			Loop
		EndIf

		If lUnicaImp
			If nX <= Len(aDados)
				lImpNovo := .T.
			EndIf
		EndIf

		While lImpNovo

			lImpNovo := .F.
			nAte += 10

			For nI := 6 To 20
				If Len(aDados[nX, nI]) < nAte
					For nJ := Len(aDados[nX, nI]) + 1 To nAte
						If AllTrim(StrZero(nI, 2, 0)) $ "07"
							aAdd(aDados[nX, nI], StoD(''))
						ElseIf AllTrim(StrZero(nI, 2, 0)) $ "12,14,15,16"
							aAdd(aDados[nX, nI], 0)
						Else
							aAdd(aDados[nX, nI], "")
						EndIf
					Next nJ
				EndIf
			Next nI

			nLinIni := 010
			nColIni := 005
			nColA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Box Principal                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega e Imprime Logotipo da Empresa                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap(nLinIni + 0015, nColIni + 0015, cFileLogo, 060, 040) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			if( ! isInCallStack( "PLIMPGUIB" ) )

				//"ANEXO DE OUTRAS DESPESAS"
				oPrint:Say(nLinIni + 0030, nColIni + (nColMax * 0.40) , "ANEXO DE OUTRAS DESPESAS", oFont02n,,,,2)

				//"(para Guia de SP/SADT e Resumo de Internação)"
				oPrint:Say(nLinIni + 0040, nColIni + (nColMax * 0.37) , "(para Guia de SP/SADT e Resumo de Internação)", oFont05,,,,2)

				//"1 - Registro ANS"
				oPrint:Box(nLinIni + 0070, nColIni + 0020, nLinIni + 0100, nColIni + (nColMax*0.14))
				oPrint:Say(nLinIni + 0080, nColIni + 0030, "1 - Registro ANS", oFont01)
				oPrint:Say(nLinIni + 0090, nColIni + 0040, aDados[nX, 01], oFont04)

				//"2 – Número da Guia Referenciada"
				oPrint:Box(nLinIni + 0070, nColIni + (nColMax * 0.15), nLinIni + 0100, nColIni + (nColMax*0.42))
				oPrint:Say(nLinIni + 0080, nColIni + (nColMax * 0.15) + 0010, "2 – Número da Guia Referenciada", oFont01)
				oPrint:Say(nLinIni + 0090, nColIni + (nColMax * 0.15) + 0020, aDados[nX, 02], oFont04)

				//Linha cinza
				AddTBrush(oPrint,nLinIni + 0105, nColIni + (nColMax * 0.02432), nLinIni + 0115, nColIni + nColMax - 0010)

				//"Dados do Contratado Executante"
				oPrint:Say(nLinIni + 0110, nColIni + 0020, "Dados do Contratado Executante", oFont01)

				//"3 - Código na Operadora"
				oPrint:Box(nLinIni + 0120, nColIni + 0020, nLinIni + 0150, nColIni + (nColMax*0.18) - 0010)
				oPrint:Say(nLinIni + 0130, nColIni + 0030, "3 - Código na Operadora", oFont01)
				oPrint:Say(nLinIni + 0140, nColIni + 0040, aDados[nX, 03], oFont04)

				//"4 - Nome do Contratado"
				oPrint:Box(nLinIni + 0120, nColIni + (nColMax * 0.18), nLinIni + 0150, nColIni + (nColMax*0.9) - 0010)
				oPrint:Say(nLinIni + 0130, nColIni + (nColMax * 0.18) + 0010, "4 - Nome do Contratado", oFont01)
				oPrint:Say(nLinIni + 0140, nColIni + (nColMax * 0.18) + 0020, aDados[nX, 04], oFont04)

				//"5 – Código CNES"
				oPrint:Box(nLinIni + 0120, nColIni + (nColMax * 0.9), nLinIni + 0150, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0130, nColIni + (nColMax * 0.9) + 0010, "5 – Código CNES", oFont01)
				oPrint:Say(nLinIni + 0140, nColIni + (nColMax * 0.9) + 0020, aDados[nX, 05], oFont04)

				//Linha cinza
				AddTBrush(oPrint, nLinIni + 0153, nColIni + (nColMax * 0.02432), nLinIni + 0166, nColIni + nColMax - 0010)

				//"Despesas Realizadas"
				oPrint:Say(nLinIni + 0160, nColIni + (nColMax * 0.02432), "Despesas Realizadas", oFont01)

				//Box da "Despesas Realizadas"
				oPrint:Box(nLinIni + 0170, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.90) , nColIni + nColMax - 0010)

				//"6-CD"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.025), "6-CD"					, oFont01)

				//"7-Data"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.065), "7-Data"				, oFont01)

				//"8-Hora Inicial"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.14), "8-Hora Inicial"			, oFont01)

				//"9-Hora Final"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.195), "9-Hora Final"			, oFont01)

				//"10-Tabela"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.252), "10-Tabela"				, oFont01)

				//"11-Código do Item"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.32), "11-Código do Item"		, oFont01)

				//"12-Qtde."
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.50), "12-Qtde."				, oFont01)

				//"13-Unidade"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.68), "13-Unidade"				, oFont01)

				//"de Medida"
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax * 0.685), "de Medida"				, oFont01)

				//"14- Fator Red."
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.76), "14- Fator Red."			, oFont01)
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax * 0.765), "/ Acresc"				, oFont01)

				//"15-Valor Unitário - R$"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.83), "15-Valor Unitário - R$"	, oFont01)

				//"16-Valor Total – R$"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.92), "16-Valor Total – R$"	, oFont01)

				//"17-Registro ANVISA do Material"
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax * 0.025), "17-Registro ANVISA do Material"		, oFont01)

				//"18-Referência do material no fabricante"
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax*0.195), "18-Referência do material no fabricante"	, oFont01)

				//"19-Nº Autorização de Funcionamento"
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax*0.83), "19-Nº Autorização de Funcionamento"		, oFont01)

				nOldLinIni := nLinIni
				For nI := nIni To nAte
					oPrint:Say(nLinIni + 0200, nColIni + 0030, AllTrim(Str(nI)) + " - ", oFont04)

					//6-CD
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.025), aDados[nX, 6, nI], oFont04)

					//7-Data
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.06) , IIf(Empty(DtoC(aDados[nX, 7, nI])),'|_|_|/|_|_|/|_|_|_|_|',DtoC(aDados[nX, 7, nI])), oFont04) // "|_|_|/|_|_|/|_|_|_|_|"

					//8-Hora Inicial
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.146), IIf(Empty(aDados[nX, 8, nI]), "", Transform(aDados[nX, 8, nI], "@R 99:99")), oFont04)

				 	//9-Hora Final
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.196), IIf(Empty(aDados[nX, 9, nI]), "", Transform(aDados[nX, 9, nI], "@R 99:99")), oFont04)

					//10-Tabela
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.255), aDados[nX, 10, nI], oFont04)

					//11-Código do Item
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.32) , aDados[nX, 11, nI], oFont04)

					//12-Qtde.
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.51) , IIf(Empty(aDados[nX, 12, nI]), "", Transform(aDados[nX, 12, nI], '@E 9999')), oFont04,,,,1)

					//13-Unidade de Medida
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.68) , aDados[nX, 13, nI], oFont04)//

					//14- Fator Red. / Acresc
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.78) , IIf(Empty(aDados[nX, 14, nI]), "", Transform(aDados[nX, 14, nI], "@E 9.99")), oFont04,,,,1)

					//15-Valor Unitário -
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.84) , IIf(Empty(aDados[nX, 15, nI]), "", Transform(aDados[nX, 15, nI], "@E 999,999.99")), oFont04,,,,1)

					//16-Valor Total -
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.93) , IIf(Empty(aDados[nX, 16, nI]), "", Transform(aDados[nX, 16, nI], "@E 999,999.99")), oFont04,,,,1)

					// Pula uma linha
					nLinIni += 10

					// 17-Registro ANVISA do Material
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.025), aDados[nX, 17, nI], oFont04)

					// 18-Referência do material no fabricante
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.195), aDados[nX, 18, nI], oFont04)

					// 19-Nº Autorização de Funcionamento
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.83 ), aDados[nX, 19, nI], oFont04)

					// Pula uma linha
					nLinIni += 10

					//"20-Descrição"
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.025), "20-Descrição", oFont01)

					//"20-Descrição"
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.07 ), aDados[nX, 20, nI], oFont04)

					// Pula uma linha
					nLinIni += 10

				Next nI

				nLinIni := nOldLinIni

				If nAte < Len(aDados[nX][6])
					lImpNovo 	:= .T.
					nIni 		:= nAte + 1
				EndIf

				//"21 - Total de Gases Medicinais (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + 0020, nLinIni + (nLinMax * 0.972), nColIni + (nColMax/7) - 0008)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + 0021, "21 - Total de Gases Medicinais (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.94), nColIni + (nColMax* 0.1062), IIf(Empty(aDados[nX, 21]), "", Transform(aDados[nX, 21], "@E 99,999,999.99")), oFont04,,,,1)

				//"22 - Total de Medicamentos (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + (nColMax* 0.14286), nLinIni + (nLinMax * 0.972), nColIni + (nColMax/7*2) - 0010)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + (nColMax* 0.145), "22 - Total de Medicamentos (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.94), nColIni + (nColMax* 0.165), IIf(Empty(aDados[nX, 22]), "", Transform(aDados[nX, 22], "@E 99,999,999.99")), oFont04,,,,1)

				 //"23 - Total de Materiais (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + (nColMax* 0.285), nLinIni + (nLinMax * 0.972), nColIni + (nColMax/7*3) - 0010)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + (nColMax* 0.288), "23 - Total de Materiais (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.94), nColIni + (nColMax* 0.300), IIf(Empty(aDados[nX, 23]), "", Transform(aDados[nX, 23], "@E 99,999,999.99")), oFont04,,,,1)

				//"24 - Total de OPME (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + (nColMax/7*3), nLinIni + (nLinMax * 0.972), nColIni + (nColMax/7*4) - 0010)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + (nColMax/7*3) + 0002, "24 - Total de OPME (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.94), nColIni + (nColMax/7*3) + 0006, IIf(Empty(aDados[nX, 24]), "", Transform(aDados[nX, 24], "@E 99,999,999.99")), oFont04,,,,1)

				//"25 - Total de Taxas e Aluguéis (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + (nColMax/7*4), nLinIni + (nLinMax * 0.972), nColIni + (nColMax/7*5) - 0010)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + (nColMax/7*4) + 0002, "25 - Total de Taxas e Aluguéis (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.94), nColIni + (nColMax/7*4) + 0006, IIf(Empty(aDados[nX, 25]), "", Transform(aDados[nX, 25], "@E 99,999,999.99")), oFont04,,,,1)

				//"26 - Total de Diárias (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + (nColMax/7*5), nLinIni + (nLinMax * 0.972), nColIni + (nColMax/7*6) - 0010)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + (nColMax/7*5) + 0002, "26 - Total de Diárias (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.94), nColIni + (nColMax/7*5) + 0006, IIf(Empty(aDados[nX, 26]), "", Transform(aDados[nX, 26], "@E 99,999,999.99")), oFont04,,,,1)

				//"27 - Total Geral (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + (nColMax/7*6), nLinIni + (nLinMax * 0.972), nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + (nColMax/7*6) + 0002, "27 - Total Geral (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.94), nColIni + (nColMax/7*6) + 0006, IIf(Empty(aDados[nX, 27]), "", Transform(aDados[nX, 27], "@E 99,999,999.99")), oFont04,,,,1)

				//oPrint:Say(nLinIni + (nLinMax * 1), nColIni + 0021, 'Padrão TISS - Componente de Conteúdo e Estrutura - Janeiro 2015', oFont01) //'Padrão TISS - Componente de Conteúdo e Estrutura - Janeiro 2015'
			else

				//"ANEXO DE OUTRAS DESPESAS"
				oPrint:Say(nLinIni + 0030, nColIni + (nColMax * 0.40) , "ANEXO DE OUTRAS DESPESAS", oFont02n,,,,2)

				//"(para Guia de SP/SADT e Resumo de Internação)"
				oPrint:Say(nLinIni + 0040, nColIni + (nColMax * 0.37) , "(para Guia de SP/SADT e Resumo de Internação)", oFont05,,,,2)

				//"1 - Registro ANS"
				oPrint:Box(nLinIni + 0070, nColIni + 0020, nLinIni + 0100, nColIni + (nColMax*0.14))
				oPrint:Say(nLinIni + 0080, nColIni + 0030, "1 - Registro ANS", oFont01)
				oPrint:Say(nLinIni + 0093, nColIni + 0030, aDados[nX, 01]/*replicate( "|__",6 ) + "|"*/, oFont04)

				//"2 – Número da Guia Referenciada"
				oPrint:Box(nLinIni + 0070, nColIni + (nColMax * 0.15), nLinIni + 0100, nColIni + (nColMax*0.42))
				oPrint:Say(nLinIni + 0080, nColIni + (nColMax * 0.15) + 0010, "2 - Número da Guia Referenciada", oFont01)
				oPrint:Say(nLinIni + 0093, nColIni + (nColMax * 0.15) + 0010, replicate( "|__",20 ) + "|", oFont04)

				//Linha cinza
				AddTBrush(oPrint,nLinIni + 0105, nColIni + (nColMax * 0.02432), nLinIni + 0115, nColIni + nColMax - 0010)

				//"Dados do Contratado Executante"
				oPrint:Say(nLinIni + 0110, nColIni + 0020, "Dados do Contratado Executante", oFont01)

				//"3 - Código na Operadora"
				oPrint:Box(nLinIni + 0120, nColIni + 0020, nLinIni + 0150, nColIni + (nColMax*0.21) )
				oPrint:Say(nLinIni + 0130, nColIni + 0030, "3 - Código na Operadora", oFont01)
				oPrint:Say(nLinIni + 0143, nColIni + 0030, replicate( "|__",14 ) + "|", oFont04)

				//"4 - Nome do Contratado"
				oPrint:Box(nLinIni + 0120, nColIni + (nColMax * 0.22), nLinIni + 0150, nColIni + (nColMax*0.87) )
				oPrint:Say(nLinIni + 0130, nColIni + (nColMax * 0.22) + 0010, "4 - Nome do Contratado", oFont01)
				oPrint:Say(nLinIni + 0140, nColIni + (nColMax * 0.22) + 0020, aDados[nX, 04], oFont04)

				//"5 – Código CNES"
				oPrint:Box(nLinIni + 0120, nColIni + (nColMax * 0.88), nLinIni + 0150, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0130, nColIni + (nColMax * 0.88) + 0010, "5 - Código CNES", oFont01)
				oPrint:Say(nLinIni + 0143, nColIni + (nColMax * 0.88) + 0005, replicate( "|__",7 ) + "|", oFont04)

				//Linha cinza
				AddTBrush(oPrint, nLinIni + 0153, nColIni + (nColMax * 0.02432), nLinIni + 0166, nColIni + nColMax - 0010)

				//"Despesas Realizadas"
				oPrint:Say(nLinIni + 0160, nColIni + (nColMax * 0.02432), "Despesas Realizadas", oFont01)

				//Box da "Despesas Realizadas"
				oPrint:Box(nLinIni + 0170, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.90) , nColIni + nColMax - 0010)

				//"6-CD"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.025), "6-CD"					, oFont01)

				//"7-Data"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.075), "7-Data"				, oFont01)

				//"8-Hora Inicial"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.190), "8-Hora Inicial"			, oFont01)

				//"9-Hora Final"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.230), "9-Hora Final"			, oFont01)

				//"10-Tabela"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.270), "10-Tabela"				, oFont01)

				//"11-Código do Item"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.305), "11-Código do Item"		, oFont01)

				//"12-Qtde."
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.430), "12-Qtde."				, oFont01)

				//"13-Unidade de Medida"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.525), "13-Unidade"				, oFont01)
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax * 0.525), "de Medida"				, oFont01)

				//"14- Fator Red. / Acresc"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.575), "14- Fator Red."			, oFont01)
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax * 0.575), "/ Acresc"				, oFont01)


				//"15-Valor Unitário - R$"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.635), "15-Valor Unitário - R$"	, oFont01)

				//"16-Valor Total – R$"
				oPrint:Say(nLinIni + 0175, nColIni + (nColMax * 0.750), "16-Valor Total - R$"	, oFont01)

				//"17-Registro ANVISA do Material"
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax * 0.025), "17-Registro ANVISA do Material"		, oFont01)

				//"18-Referência do material no fabricante"
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax*0.210), "18-Referência do material no fabricante"	, oFont01)

				//"19-Nº Autorização de Funcionamento"
				oPrint:Say(nLinIni + 0185, nColIni + (nColMax*0.800), "19-Nº Autorização de Funcionamento"		, oFont01)

				nOldLinIni := nLinIni
				For nI := nIni To nAte
					//oPrint:Say(nLinIni + 0200, nColIni + 0030, AllTrim(Str(nI)) + " - ", oFont04)

					//6-CD
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.025), allTrim( strZero( nI,2 ) ) + " - " + replicate( "|__",2 ) + "|", oFont04)

					//7-Data
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.075) , IIf(Empty(strTran(DtoC(aDados[nX, 7, nI]),"/","")),'|__|__|/|__|__|/|__|__|__|__|',DtoC(aDados[nX, 7, nI])), oFont04 )

					//8-Hora Inicial
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.190), IIf(Empty(aDados[nX, 8, nI]), "|__|:|__|", Transform(aDados[nX, 8, nI], "@R 99:99")), oFont04)
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.223), "a", oFont04)

			 		//9-Hora Final
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.230), IIf(Empty(aDados[nX, 9, nI]), "|__|:|__|", Transform(aDados[nX, 9, nI], "@R 99:99")), oFont04)

					//10-Tabela
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.270), replicate( "|__",2 ) + "|", oFont04)

					//11-Código do Item
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.305) , replicate( "|__",10 ) + "|", oFont04)

					//12-Qtde.
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.430) , IIf(Empty(aDados[nX, 12, nI]), "|__|__|__|,|__|__|__|__|", Transform(aDados[nX, 12, nI], '@E 9999')), oFont04,,,,1)

					//13-Unidade de Medida
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.525) , replicate( "|__",3 ) + "|", oFont04)//

					//14- Fator Red. / Acresc
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.575) , IIf(Empty(aDados[nX, 14, nI]), "|__|,|__|__|", Transform(aDados[nX, 14, nI], "@E 9.99")), oFont04,,,,1)

					//15-Valor Unitário -
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.635) , IIf(Empty(aDados[nX, 15, nI]), "|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 15, nI], "@E 999,999.99")), oFont04,,,,1)

					//16-Valor Total -
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.750) , IIf(Empty(aDados[nX, 16, nI]), "|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 16, nI], "@E 999,999.99")), oFont04,,,,1)

					// Pula uma linha
					nLinIni += 10

					// 17-Registro ANVISA do Material
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.025), replicate( "|__",15 ) + "|", oFont04)

					// 18-Referência do material no fabricante
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.210), "|" + replicate( "__",60 ) + "|", oFont04)

					// 19-Nº Autorização de Funcionamento
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.800 ), replicate( "|__",15 ) + "|", oFont04)

					// Pula uma linha
					nLinIni += 10

					//"20-Descrição"
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.025), "20-Descrição", oFont01)
					oPrint:Say(nLinIni + 0200, nColIni + (nColMax * 0.07 ), replicate( "__",96 ), oFont04)

					// Pula uma linha
					nLinIni += 10
				Next nI

				nLinIni := nOldLinIni

				If nAte < Len(aDados[nX][6])
					lImpNovo 	:= .T.
					nIni 		:= nAte + 1
				EndIf

				nTam	:= 110
				nMarg	:= 020

				//"21 - Total de Gases Medicinais (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nMarg, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam )
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nMarg + 03, "21 - Total de Gases Medicinais (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nMarg + 05, IIf(Empty(aDados[nX, 21]), "|__|__|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 21], "@E 99,999,999.99")), oFont04,,,,1)

				//"22 - Total de Medicamentos (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nTam + nMarg + 03, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam*2 + 03 )
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nTam + nMarg + 05, "22 - Total de Medicamentos (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nTam + nMarg + 07, IIf(Empty(aDados[nX, 22]), "|__|__|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 22], "@E 99,999,999.99")), oFont04,,,,1)

				 //"23 - Total de Materiais (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nMarg + nTam*2 + 06, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam*3 + 06 )
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nMarg + nTam*2 + 08, "23 - Total de Materiais (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nMarg + nTam*2 + 10, IIf(Empty(aDados[nX, 23]), "|__|__|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 23], "@E 99,999,999.99")), oFont04,,,,1)

				//"24 - Total de OPME (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nMarg + nTam*3 + 09, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam*4 + 09 )
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nMarg + nTam*3 + 11, "24 - Total de OPME (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nMarg + nTam*3 + 12, IIf(Empty(aDados[nX, 24]), "|__|__|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 24], "@E 99,999,999.99")), oFont04,,,,1)

				//"25 - Total de Taxas e Aluguéis (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nMarg + nTam*4 + 12, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam*5 + 12)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nMarg + nTam*4 + 14, "25 - Total de Taxas e Aluguéis (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nMarg + nTam*4 + 16, IIf(Empty(aDados[nX, 25]), "|__|__|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 25], "@E 99,999,999.99")), oFont04,,,,1)

				//"26 - Total de Diárias (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nMarg + nTam*5 + 15, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam*6 + 15)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nMarg + nTam*5 + 17, "26 - Total de Diárias (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nMarg + nTam*5 + 19, IIf(Empty(aDados[nX, 26]), "|__|__|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 26], "@E 99,999,999.99")), oFont04,,,,1)

				//"27 - Total Geral (R$)"
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nMarg + nTam*6 + 18, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam*7 + 18)
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nMarg + nTam*6 + 20, "27 - Total Geral (R$)", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nMarg + nTam*6 + 22, IIf(Empty(aDados[nX, 27]), "|__|__|__|__|__|__|__|__|,|__|__|", Transform(aDados[nX, 27], "@E 99,999,999.99")), oFont04,,,,1)

				//oPrint:Say(nLinIni + (nLinMax * 1), nColIni + 0021, 'Padrão TISS - Componente de Conteúdo e Estrutura - Janeiro 2015', oFont01) //'Padrão TISS - Componente de Conteúdo e Estrutura - Janeiro 2015'
			endIf

			oPrint:EndPage()	// Finaliza a pagina
		End

	Next nX

	If lGerTXT .OR. lWeb
		oPrint:Print()		// Imprime Relatorio
	Else
		oPrint:Preview()	// Visualiza impressao grafica antes de imprimir
	EndIf
Return cFileName


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS7B ³ Autor ³ Luciano Aparecido     ³ Data ³ 26.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Demons An. Contas Med)-BOPS 095189³±±
±±³          ³ TISS 3                                                      ³±±
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
Function PLSTISS7B(aDados, nLayout, cLogoGH, lAuto)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=  0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local nInfGui   :=  0
	Local nProcGui  :=  0
	Local nLibGui   :=  0
	Local nGloGui   :=  0
	Local nInfGer   :=  0
	Local nProcGer  :=  0
	Local nLibGer   :=  0
	Local nGloGer   :=  0
	Local nInfFat   :=  0
	Local nProcFat  :=  0
	Local nLibFat   :=  0
	Local nGloFat   :=  0
	Local cFileLogo
	Local lPrinter := .F.
	Local nI, nJ
	Local nX,nX1,nX2,nX3,nX4,nX5
	Local oFont01
	Local oFont02n
	Local oFont04
	Local nT := 0
	Local nVolta := 0
	Local nV := 1
	Local lImpnovo := .T.
	Local cFileName := ""
	
	Default nLayout := 2
	Default cLogoGH := ''
	Default lAuto   := .F.
	Default aDados  := { { ;
		"123456",; //1
	{"123456789102"},; //2
	Replicate("M",70),; //3
	"14.141.114/00001-35",; //4
	{CtoD("12/01/06")},; //5
	{"14.141.114/00001-35"},; //6
	{Replicate("M",70)},; //7
	{"1234567"},; //8
	{{"123456789012"}},; //9
	{{ "123456789012" }},; //10
	{{ CtoD("12/01/06") }},; //11
	{{ "1234" }},; //12
	{{ "12345678901234567890" }},; //13
	{{ { "12345678901234567890" } }},; //14
	{{ { "12345678901234567890" } }},; //15
	{{ { "12345678901234567890" } }},; //16
	{{ { Replicate("M",70) } }},; //17
	{{ { "12345678901234567890" } }},; //18
	{{ { CtoD("12/01/06") } }},; //19
	{{ { "00:00" } }},; //20
	{{ { CtoD("12/01/06") } }},; //21
	{{ { "00:00" } }},; //22
	{{ { "1234" } }},; //23
	{{ { "01" } }},; //24
	{{ { { CtoD("12/01/06"), CtoD("12/01/06") } } }},; //25
	{{ { { "MM", "MM" } } }},; //26
	{{ { { "1234567890", "1234567890" } } }},; //27
	{{ { { Replicate("M",150), Replicate("M",150) } } }},; //28
	{{ { { "MM", "MM" } } }},; //29
	{{ { { 123456.78, 123456.78 } } }},; //30
	{{ { { 123, 123 } } }},; //31
	{{ { { 123456.78, 123456.78 } } }},; //32
	{{ { { 123456.78, 123456.78 } } }},; //33
	{{ { { 123456.78, 123456.78 } } }},; //34
	{{ { { "1234", "1234" } } }},; //35	
	} }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2310
		nColMax	:=	3190
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
		oPrint	:= TMSPrinter():New("DEMONSTRATIVO DE ANALISE DA CONTA") //"DEMONSTRATIVO DE ANALISE DA CONTA"
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
	IF lPrinter
		lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se irá alterar a Impressora Ativa
	ENDIF
	
	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf !lPrinter
		oPrint:Setup()
	EndIf

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 25 To 35
			If Len(aDados[nX, nI]) < nT
				For nJ := Len(aDados[nX, nI]) + 1 To 17
					If AllTrim(Str(nI)) $ "25"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "30,31,32,33,34"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nX1 := 1 To Len(aDados[nX, 02])

			If nX1 > 1
				oPrint:EndPage()
			Endif


			nInfGer := 0
			nProcGer := 0
			nLibGer  := 0
			nGloGer  := 0
			nInfFat := 0
			nProcFat := 0
			nLibFat  := 0
			nGloFat  := 0

			For nX2 := 1 To Len(aDados[nX, 9, nX1])

				If nX2 > 1
					oPrint:EndPage()
				Endif

				nInfGui := 0
				nProcGui := 0
				nLibGui  := 0
				nGloGui  := 0
				nVolta := 0

				For nX3 := 1 To Len(aDados[nX, 14, nX1, nX2])


					lImpnovo:= .T.
					nT := 0


					While lImpnovo

						lImpnovo:= .F.
						nVolta  += 1
						nT += 17

						If nVolta > 1
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
							oPrint:SayBitmap(nLinIni + 0040, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
						EndIf

						If nLayout == 2 // Papél A4
							nColA4    := -0335
						Elseif nLayout == 3// Carta
							nColA4    := -0530
						Endif

						oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIF(nLayout == 2 .Or. nLayout == 3,nColA4+250,0), "DEMONSTRATIVO DE ANALISE DA CONTA", oFont02n,,,, 2) //"DEMONSTRATIVO DE ANÁLISE DA CONTA MÉDICA"

						oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.80, 		  "2- Nº", oFont01)
						oPrint:Say(nLinIni + 0080, (nColIni + nColMax)*0.80 + 0050, aDados[nX, 02, nX1], oFont03n)

						nLinIni += 60
						oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, (nColIni + nColMax)*0.1 - 0010)
						oPrint:Say(nLinIni + 0185, nColIni + 0020, "1 - Registro ANS", oFont01) //1-Registro ANS
						oPrint:Say(nLinIni + 0220, nColIni + 0030, aDados[nX, 01], oFont04)
						oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.1, nLinIni + 0269, (nColIni + nColMax)*0.67 - 0010)
						oPrint:Say(nLinIni + 0185, (nColIni + nColMax)*0.1 + 0010, "3 - Nome da Operadora", oFont01) //"3-Nome da Operadora
						oPrint:Say(nLinIni + 0220, (nColIni + nColMax)*0.1 + 0020, aDados[nX, 03], oFont04)
						oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.67, nLinIni + 0269, (nColIni + nColMax)*0.87 - 0010)
						oPrint:Say(nLinIni + 0185, (nColIni + nColMax)*0.67 + 0010, "4 - CNPJ da Operadora", oFont01) //4-CNPJ da Operadora
						oPrint:Say(nLinIni + 0220, (nColIni + nColMax)*0.67 + 0020, aDados[nX, 04], oFont04)
						oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.87, nLinIni + 0269, nColIni + nColMax - 0010)
						oPrint:Say(nLinIni + 0185, (nColIni + nColMax)*0.87 + 0010, "5 - Data de Emissao", oFont01) //5-Data de Emissao
						oPrint:Say(nLinIni + 0220, (nColIni + nColMax)*0.87 + 0020, DtoC(aDados[nX, 05, nX1]), oFont04)

						AddTBrush(oPrint, nLinIni + 0281, nColIni + 0010, nLinIni + 0312, nColIni + nColMax)
						oPrint:Say(nLinIni + 0284, nColIni + 0020, "Dados do Prestador", oFont01) //Dados do Prestador
						oPrint:Box(nLinIni + 0314, nColIni + 0010, nLinIni + 0408, (nColIni + nColMax)*0.22 - 0010)
						oPrint:Say(nLinIni + 0324, nColIni + 0020, "6 - Coódigo na Operadora", oFont01) //6 - Código na Operadora
						oPrint:Say(nLinIni + 0359, nColIni +  0030, aDados[nX, 06, nX1], oFont04)
						oPrint:Box(nLinIni + 0314, (nColIni + nColMax)*0.22, nLinIni + 0408, (nColIni + nColMax)*0.90 - 0010)
						oPrint:Say(nLinIni + 0324, (nColIni + nColMax)*0.22 + 0010, "7 - Nome do Contratado", oFont01) //7- Nome do Contratado
						oPrint:Say(nLinIni + 0359, (nColIni + nColMax)*0.22 + 0020, aDados[nX, 07, nX1], oFont04)
						oPrint:Box(nLinIni + 0314, (nColIni + nColMax)*0.90, nLinIni + 0408, nColIni + nColMax - 0010)
						oPrint:Say(nLinIni + 0324, (nColIni + nColMax)*0.90 + 0010, "8 - Código CNES", oFont01) //8 - Código CNES
						oPrint:Say(nLinIni + 0359, (nColIni + nColMax)*0.90 + 0020, aDados[nX, 08, nX1], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 270, 40)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 40)
						AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
						oPrint:Say(nLinIni + 0003, nColIni + 0020, "Dados do Lote/Protocolo", oFont01) //Dados do Lote/Protocolo
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127, (nColIni + nColMax)*0.18 - 0010)
						oPrint:Say(nLinIni + 0043, nColIni + 0020, "9 - Número do Lote", oFont01) //9 - Número do Lote
						oPrint:Say(nLinIni + 0073, nColIni + 0030, aDados[nX, 9, nX1, nX2], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.18, nLinIni + 0127, (nColIni + nColMax)*0.35 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.18 + 0010, "10 - Número do Protocolo", oFont01) //10 - Número do Protocolo
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.18 + 0020, aDados[nX, 10, nX1, nX2], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.35, nLinIni + 0127, (nColIni + nColMax)*0.48 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.35 + 0010, "11 - Data do Protocolo", oFont01) //11 - Data do Protocolo
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.35 + 0010, DtoC(aDados[nX, 11, nX1, nX2]), oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.48, nLinIni + 0127, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.48 + 0010, "12 - Código da Glosa do Protocolo", oFont01) //12 - Código da Glosa do Protocolo
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.48 + 0010, aDados[nX, 12, nX1, nX2], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.60, nLinIni + 0127, (nColIni + nColMax)*0.75 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.60 + 0010, "13 - Código da Situação do Protocolo", oFont01) //13 - Código da Situação do Protocolo
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.60 + 0010, aDados[nX, 13, nX1, nX2], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 40)
						AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
						oPrint:Say(nLinIni + 0003, nColIni + 0020, "Dados da Guia", oFont01) //Dados da Guia
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0043, nColIni + 0020, "14 - Número da Guia no Prestador", oFont01) //14 - Número da Guia no Prestador
						oPrint:Say(nLinIni + 0073, nColIni +  0030, aDados[nX, 14, nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0127,(nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.30 + 0010, "15 - Número da Guia Atribuído pela Operadora", oFont01) //15 - Número da Guia Atribuído pela Operadora
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.30 + 0020, aDados[nX, 15,nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.60, nLinIni + 0127, (nColIni + nColMax)*0.85 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.60 + 0010, "16 - Senha", oFont01) //16 -Senha
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.60 + 0020, aDados[nX, 16, nX1,nX2, nX3], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127,(nColIni + nColMax)*0.55 - 0010)
						oPrint:Say(nLinIni + 0043, nColIni + 0020, "17 - Nome do beneficiário", oFont01) //17 - Nome do beneficiário
						oPrint:Say(nLinIni + 0073, nColIni + 0030, aDados[nX, 17,nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.55, nLinIni + 0127, (nColIni + nColMax)*0.85 - 0010)
						oPrint:Say(nLinIni + 043, (nColIni + nColMax)*0.55 + 0010, "18 - Número da Carteira", oFont01) //18 - Número da Carteira
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.55 + 0020, aDados[nX, 18, nX1,nX2, nX3], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127,(nColIni + nColMax)*0.15 - 0010)
						oPrint:Say(nLinIni + 0043, nColIni + 0020, "19 - Data do Início do Faturamento", oFont01) //19 - Data do Início do Faturamento
						oPrint:Say(nLinIni + 0073, nColIni + 0030, IIf(Empty(aDados[nX, 19,nX1, nX2, nX3]), "", DtoC(aDados[nX, 19,nX1, nX2, nX3])), oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0127, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.15 + 0010, "20 - Hora do Início do Faturamento", oFont01) //20 - Hora do Início do Faturamento
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.15 + 0020, aDados[nX, 20, nX1,nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0127, (nColIni + nColMax)*0.45 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.30 + 0010, "21 - Data do Fim do Faturamento", oFont01) //21 - Data do Fim do Faturamento
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.30 + 0020, IIf(Empty(aDados[nX, 21, nX1,nX2, nX3]), "", DtoC(aDados[nX, 21, nX1,nX2, nX3])), oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0127, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.45 + 0010, "22 - Hora do Fim do Faturamento", oFont01) //22 - Hora do Fim do Faturamento
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.45 + 0020, aDados[nX, 22, nX1,nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.60, nLinIni + 0127, (nColIni + nColMax)*0.75 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.60 + 0010, "23 - Código da Glosa da Guia", oFont01) //23 - Código da Glosa da Guia
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.60 + 0020, aDados[nX, 23, nX1,nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.75, nLinIni + 0127, (nColIni + nColMax)*0.90 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.75 + 0010, "24 - Código da Situação da Guia", oFont01) //24 - Código da Situação da Guia
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.75 + 0020, aDados[nX, 24, nX1,nX2, nX3], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
						oPrint:Box(nLinIni + 0035, nColIni + 0010, nLinIni + 110 + (16 * 50), nColIni + nColMax -0010)
						oPrint:Say(nLinIni + 0040, nColIni + 0015, "", oFont01) //Índice
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.04, "25-Data de realização", oFont01) 		//25-Data de realização
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.10, "26-Tabela", oFont01) 			//26-Tabela
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.14, "27-Código do procedimento/", oFont01) //27-Código do procedimento/
						oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.14, "Item assistencial", oFont01) 			//Item assistencial
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.23, "28-Descrição", oFont01) 			//28-Descrição
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.55, "29-Grau de", oFont01) 				//29-Grau de
						oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.55, "Participação", oFont01) 			//Participação
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.65, "30-Valor Informado", oFont01,,,,1) //30-Valor Informado
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.69, "31-Quant.", oFont01,,,,1) 			//31-Quant.
						oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.69, "Executada", oFont01,,,,1) 			//Executada
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.76, "32-Valor Processado", oFont01,,,,1) //32-Valor Processado
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.83, "33-Valor Liberado", oFont01,,,,1) //33-Valor Liberado
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.90, "34-Valor Glosa", oFont01,,,,1) 	//34-Valor Glosa
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.91, "35-Código", oFont01) 				//35-Código
						oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.91, "da Glosa", oFont01) 				//da Glosa

						if nVolta = 1
							nV:=1
						Endif


						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 15, 40)
						For nX4 := nV To Len(aDados[nX, 25, nX1,nX2, nX3])
							If nX4 <= nT
								fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
								oPrint:Say(nLinIni + 0025, nColIni + 0015, AllTrim(Str(nX4)), oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.04, IIf(Empty(aDados[nX, 25, nX1,nX2, nX3, nX4]), "", DtoC(aDados[nX, 25, nX1,nX2, nX3, nX4])), oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.10, aDados[nX, 26, nX1,nX2, nX3, nX4], oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.14, aDados[nX, 27, nX1,nX2, nX3, nX4], oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.23, aDados[nX, 28, nX1,nX2, nX3, nX4], oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.55, aDados[nX, 29, nX1,nX2, nX3, nX4], oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.65, IIf(Empty(aDados[nX, 30, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 30, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.69, IIf(Empty(aDados[nX, 31, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 31, nX1, nX2, nX3, nX4], "@E 9999")), oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.76, IIf(Empty(aDados[nX, 32, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 32, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.83, IIf(Empty(aDados[nX, 33, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 33, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.83, IIf(Empty(aDados[nX, 34, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 34, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.91, aDados[nX, 35,nX1,nX2, nX3, nX4], oFont04)

								nInfGui += aDados[nX, 30, nX1, nX2, nX3, nX4]
								nProcGui += aDados[nX, 32, nX1, nX2, nX3, nX4]
								nLibGui  += aDados[nX, 33, nX1, nX2, nX3, nX4]
								nGloGui  += aDados[nX, 34, nX1, nX2, nX3, nX4]
							Endif
						Next nX4

						If nX4 <= nT
							For nX5 := nX4 To nT
								fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
								oPrint:Say(nLinIni + 0025, nColIni + 0015, AllTrim(Str(nX5)), oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.04, "" ,oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.10, "", oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.14, "", oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.23, "", oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.55, "", oFont04)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.65, "", oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.69, "", oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.76, "", oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.83, "", oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.83, "", oFont04,,,,1)
								oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.91, "", oFont04)
							Next nX5
						Endif

						if Len(aDados[nX, 25, nX1,nX2, nX3]) > nT
							nVolta += 1
							nV := (nT * (nVolta-1)) + 1
							lImpnovo:= .T.
						Endif

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 40)
						AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
						oPrint:Say(nLinIni + 0003, nColIni + 0020, "Total Guia", oFont01) //Total Guia
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0137, (nColIni + nColMax)*0.15 - 0010)
						oPrint:Say(nLinIni + 0043, nColIni + 0020, "36 - Valor Informado da Guia (R$)", oFont01) //34 - Valor Informado da Guia (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.15 - 0030, Transform(nInfGui, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0137, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.15 + 0010, "37 - Valor Processado da Guia (R$)", oFont01) //35 - Valor Processado da Guia (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.30 - 0030, Transform(nProcGui, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0137, (nColIni + nColMax)*0.45 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.30 + 0010, "38 - Valor Liberado da Guia (R$)", oFont01) //36 - Valor Liberado da Guia (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.45 - 0030, Transform(nLibGui, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0137, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.45 + 0010, "39 - Valor Glosa da Guia (R$)", oFont01) //37 - Valor Glosa da Guia (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.60 - 0030, Transform(nGloGui, "@E 999,999,999.99"), oFont04,,,,1)

						nInfFat += nInfGui
						nProcFat += nProcGui
						nLibFat  += nLibGui
						nGloFat  += nGloGui

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 145, 40)
						AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
						oPrint:Say(nLinIni + 0003, nColIni + 0020, "Total do Protocolo", oFont01) //Total do Protocolo
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0137, (nColIni + nColMax)*0.15 - 0010)
						oPrint:Say(nLinIni + 0043, nColIni + 0020, "40 - Valor Informado do Protocolo (R$)", oFont01) //38 - Valor Informado do Protocolo (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.15 - 0030, Transform(nInfFat, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0137, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.15 + 0010, "41 - Valor Processado do Protocolo (R$)", oFont01) //39 - Valor Processado do Protocolo (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.30 - 0030, Transform(nProcFat, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0137, (nColIni + nColMax)*0.45 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.30 + 0010, "42 - Valor Liberado do Protocolo (R$)", oFont01) //40 - Valor Liberado do Protocolo (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.45 - 0030, Transform(nLibFat, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0137, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.45 + 0010, "43 - Valor Glosa do Protocolo (R$)", oFont01) //41 - Valor Glosa do Protocolo (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.60 - 0030, Transform(nGloFat, "@E 999,999,999.99"), oFont04,,,,1)

						nInfGer += nInfFat
						nProcGer += nProcFat
						nLibGer  += nLibFat
						nGloGer  += nGloFat

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 40)
						AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
						oPrint:Say(nLinIni + 0003, nColIni + 0020, "Total Geral", oFont01) //Total Geral
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0137, (nColIni + nColMax)*0.15 - 0010)
						oPrint:Say(nLinIni + 0043, nColIni + 0020, "44 - Valor Informado Geral (R$)", oFont01) //42 - Valor Informado Geral (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.15 - 0030, Transform(nInfGer, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0137, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.15 + 0010, "45 - Valor Processado Geral (R$)", oFont01) //43 - Valor Processado Geral (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.30 - 0030, Transform(nProcGer, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0137, (nColIni + nColMax)*0.45 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.30 + 0010, "46 - Valor Liberado Geral (R$)", oFont01) //44 - Valor Liberado Geral (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.45 - 0030, Transform(nLibGer, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0137, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0043, (nColIni + nColMax)*0.45 + 0010, "47 - Valor Glosa Geral (R$)", oFont01) //45 - Valor Glosa Geral (R$)
						oPrint:Say(nLinIni + 0073, (nColIni + nColMax)*0.60 - 0030, Transform(nGloGer, "@E 999,999,999.99"), oFont04,,,,1)
					EndDo
				Next nX3
			Next nX2
		Next nX1
		oPrint:EndPage()	// Finaliza a pagina
	Next nX
	
	if lAuto
		oPrint:Print()		// Imprime Relatorio
	else
		oPrint:Preview() // Visualiza impressao grafica antes de imprimir
	endIf

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSBB ³ Autor ³ Luciano Aparecido     ³ Data ³ 11.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Odontológica - Pagamento )   ³±±
±±³          ³ TISS 3                                                      ³±±
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

Function PLSTISSBB(aDados, nLayout, cLogoGH, lAuto) //Guia Odontológica - Pagamento

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nOldCol	:=	0
	Local nColA4    := 	0
	Local cFileLogo
	Local lPrinter := .F.
	Local nI, nJ
	Local nX, nX1, nX2, nX3, nX4
	Local nCount := 0
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local nProcGer,nProcLot,nProcGui
	Local nLibGer,nLiblot,nLibGui
	Local nGloGer,nGlolot,nGloGui
	Local lBox
	Local cObs
	Local cFileName := ""

	Default nLayout := 2
	Default cLogoGH := ''
	Default lAuto   := .F.
	Default	aDados  := { {;
		"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - Nº
	{Replicate("M",70)},; //3 - Nome da Operadora
	{"14.141.114/00001-35"},; //4 - CNPJ Operadora
	{CtoD("05/03/07")},; //5 - Data de Início do Processamento
	{CtoD("05/03/07")},; //6 - Data de Fim do Processamento
	{"1234567"},; //7 - Código na Operadora
	{Replicate("M", 70)},; //8 - Nome do Contratado
	{"14.141.114/00001-35"},; //9 - CPF / CNPJ Contratado
	{{{CtoD("05/03/07")}}},; //10 - Data do Pagamento
	{{{"0001"}}},; //11 - Banco
	{{{"1234567"}}},; //12 - Agência
	{{{"01234567890123456789"}}},; //13 - Conta
	{{{"123456789012"}}},; //14 - Número do lote
	{{{"123456789012"}}},; //15 - Número do Protocolo
	{{{"12345678901234567890"}}},; //16 - Número da guia no prestador
	{{{"12345678901234567890"}}},; //17 - Número da Carteira
	{{{Replicate("M",70)}}},; //18 -Nome do Beneficiário
	{{{{"00"}}}},; //19-Tabela
	{{{{"0123456789"}}}},; //20- Código do Procedimento
	{{{{Replicate("M", 150)}}}},; //21 - Descrição
	{{{{"1234"}}}},; //22-Dente/Região
	{{{{"12345"}}}},; //23-Face
	{{{{CtoD("01/01/01")}}}},; //24-Data de Realização
	{{{{99}}}},; //25-Qtde
	{{{{999999.99}}}},; //26-Valor Informado(R$)
	{{{{999999.99}}}},; //27-Valor Processado (R$)
	{{{{999999.99}}}},; //28-Valor Glosa/Estorno (R$)
	{{{{999999.99}}}},; //29- Valor Franquia (R$)
	{{{{999999.99}}}},; //30-Valor Liberado (R$)
	{{{{"1234"}}}},; //31-Código da Glosa
	{{{Replicate("M", 500)}}},; //32-Observação / Justificativa
	{{{99999999.99}}},; //33- Valor Total Informado Guia (R$)
	{{{99999999.99}}},; //34 - Valor Total Processado Guia (R$)
	{{{99999999.99}}},; //35 - Valor Total Glosa Guia (R$)
	{{{99999999.99}}},; //36 - Valor Total Franquia Guia (R$)
	{{{99999999.99}}},; //37 - Valor Total Liberado Guia (R$)
	{{99999999.99}},; //38 - Valor Total Informado Protocolo (R$)
	{{99999999.99}},; //39 - Valor Total Processado Protocolo (R$)
	{{99999999.99}},; //40 - Valor Total Glosa Protocolo (R$)
	{{99999999.99}},; //41 - Valor Total Franquia Protocolo (R$)
	{{99999999.99}},; //42 - Valor Total Liberado Protocolo (R$)
	{{"1"}},; //43-Indicação
	{{"01"}},; //44-Código do débito/crédito
	{{Replicate("M", 40)}},; //45-Descrição do débito/crédito
	{{999999.99}},; //46-Valor
	{{"1"}},; //47-Indicação
	{{"01"}},; //48-Código do débito/crédito
	{{Replicate("M", 40)}},; //49-Descrição do débito/crédito
	{{999999.99}},; //50-Valor
	{{"1"}},; //51-Indicação
	{{"01"}},; //52-Código do débito/crédito
	{{Replicate("M", 40)}},; //53-Descrição do débito/crédito
	{{999999.99}},; //54-Valor
	{99999999.99},; //55 - Valor Total Tributável (R$)
	{99999999.99},; //56- Valor Total Impostos Retidos (R$)
	{99999999.99},; //57 - Valor Total Não Tributável (R$)
	{99999999.99},; //58 - Valor Final a Receber (R$)
	{Replicate("M", 500)} } }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2275
		nColMax	:=	3270
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
		oPrint	:= TMSPrinter():New("GUIA ODONTOLÓGICA - DEMONSTRATIVO PAGAMENTO") //"GUIA ODONTOLÓGICA - DEMONSTRATIVO PAGAMENTO"
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
	IF lPrinter
		lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se irá alterar a Impressora Ativa
	ENDIF

	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf !lPrinter
		oPrint:Setup()
	EndIf

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI:= 19 To 28
			If Len(aDados[nX, nI]) < 6
				For nJ := Len(aDados[nX, nI]) + 1 To 6
					If AllTrim(Str(nI)) $ "25,27,28,29,30"
						aAdd(aDados[nX, nI], 0)
					ElseiF AllTrim(Str(nI)) $ "24"
						aAdd(aDados[nX, nI], CToD(""))
					Else
						aAdd(aDados[nX, nI],"")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 43 To 46
			If Len(aDados[nX, nI]) < 2
				For nJ := Len(aDados[nX, nI]) + 1 To 2
					If AllTrim(Str(nI)) == "46"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next
			EndIf
		Next nI

		For nI := 47 To 54
			If Len(aDados[nX, nI]) < 3
				For nJ := Len(aDados[nX, nI]) + 1 To 3
					If AllTrim(Str(nI)) $ "50,54"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next
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

				oPrint:SayBitmap(nLinIni + 0040, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIF(nLayout ==2 .Or. nLayout ==3,nColA4+260,0), "DEMONSTRATIVO DE PAGAMENTO - TRATAMENTO ODONTOLÓGICO", oFont02n,,,, 2) //DEMONSTRATIVO DE PAGAMENTO - TRATAMENTO ODONTOLÓGICO
			oPrint:Say(nLinIni + 0090, nColIni + 3000 + nColA4, "2 - Nº", oFont01) //"Nº"
			oPrint:Say(nLinIni + 0070, nColIni + 3096 + nColA4, aDados[nX, 02, nX1], oFont03n)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 40)
			oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, (nColIni + nColMax)*0.1 - 0010)
			oPrint:Say(nLinIni + 0180, nColIni + 0020, "1 - Registro ANS", oFont01) //1 - Registro ANS
			oPrint:Say(nLinIni + 0210, nColIni + 0030, aDados[nX, 01], oFont04)
			oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.1, nLinIni + 0269, (nColIni + nColMax)*0.4 - 0010)
			oPrint:Say(nLinIni + 0180, (nColIni + nColMax)*0.1 + 0020, "3 - Nome da Operadora", oFont01) //3 - Nome da Operadora
			oPrint:Say(nLinIni + 0210, (nColIni + nColMax)*0.1 + 0030, aDados[nX, 03, nX1], oFont04)
			oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.4, nLinIni + 0269, (nColIni + nColMax)*0.6 - 0010)
			oPrint:Say(nLinIni + 0180, (nColIni + nColMax)*0.4 + 0020, "4 - CNPJ Operadora", oFont01) //4 - CNPJ Operadora
			oPrint:Say(nLinIni + 0210, (nColIni + nColMax)*0.4 + 0030, aDados[nX, 04, nX1], oFont04)
			oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.6, nLinIni + 0269, (nColIni + nColMax)*0.8 - 0010)
			oPrint:Say(nLinIni + 0180, (nColIni + nColMax)*0.6 + 0020, "5 - Data de Início do Processamento", oFont01) //5 – Data de Início do Processamento
			oPrint:Say(nLinIni + 0210, (nColIni + nColMax)*0.6 + 0030, DToC(aDados[nX, 05, nX1]), oFont04)
			oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.8, nLinIni + 0269, nColIni + nColMax - 0010)
			oPrint:Say(nLinIni + 0180, (nColIni + nColMax)*0.8 + 0020, "6 - Data de Fim do Processamento", oFont04) //6 - Data de Fim do Processamento
			oPrint:Say(nLinIni + 0210, (nColIni + nColMax)*0.8 + 0030, DToC(aDados[nX, 06, nX1]), oFont04)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 0, 40)
			AddTBrush(oPrint, nLinIni + 0271, nColIni + 0010, nLinIni + 0301, nColIni + nColMax)
			oPrint:Say(nLinIni + 0274, nColIni + 0020, "Dados do Prestador", oFont01) //Dados do Prestador
			oPrint:Box(nLinIni + 0304, nColIni + 0010, nLinIni + 0398, (nColIni + nColMax)*0.2 - 0010)
			oPrint:Say(nLinIni + 0309, nColIni + 0020, "7 - Código na Operadora", oFont01) //7 - Código na Operadora
			oPrint:Say(nLinIni + 0339, nColIni + 0030, aDados[nX, 07, nX1], oFont04)
			oPrint:Box(nLinIni + 0304, (nColIni + nColMax)*0.2, nLinIni + 0398, (nColIni + nColMax)*0.77 - 0010)
			oPrint:Say(nLinIni + 0309, (nColIni + nColMax)*0.2 + 0020, "8 - Nome do Contratado", oFont01) //8 - Nome do Contratado
			oPrint:Say(nLinIni + 0339, (nColIni + nColMax)*0.2 + 0030, aDados[nX, 08, nX1], oFont04)
			oPrint:Box(nLinIni + 0304, (nColIni + nColMax)*0.77, nLinIni + 0398, nColIni + nColMax - 0010)
			oPrint:Say(nLinIni + 0309, (nColIni + nColMax)*0.77 + 0020, "9 - CPF / CNPJ Contratado", oFont01) //9 - CPF / CNPJ Contratado
			oPrint:Say(nLinIni + 0339, (nColIni + nColMax)*0.77 + 0030, aDados[nX, 09, nX1], oFont04)


			nProcGer := 0
			nLibGer  := 0
			nGloGer  := 0

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 300, 40)

			For nX2 := 1 To Len(aDados[nX, 10,nX1])

				For nX3 := 1 To Len(aDados[nX, 10,nX1, nX2])

					nProcLot := 0
					nGloLot  := 0
					nLibLot  := 0

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 40)
					AddTBrush(oPrint, nLinIni + 0004, nColIni + 0010, nLinIni + 0034, nColIni + nColMax)
					oPrint:Say(nLinIni + 0007, nColIni + 0020, "Dados do Pagamento", oFont01) //Dados do Pagamento

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
					oPrint:Box(nLinIni + 0000, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
					oPrint:Say(nLinIni + 0005, nColIni + 0020, "10 - Data do Pagamento", oFont01) //10 - Data do Pagamento
					oPrint:Say(nLinIni + 0035, nColIni + 0030, DtoC(aDados[nX, 10, nX1, nX2, nX3]), oFont04)
					oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.23 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.15 + 0010, "11 - Banco", oFont01) //11 - Banco
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.15 + 0020, aDados[nX, 11, nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.23, nLinIni + 0094, (nColIni + nColMax)*0.35 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.23 + 0010, "12 - Agência", oFont01) //12 - Agência
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.23 + 0020, aDados[nX, 12, nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.35, nLinIni + 0094, (nColIni + nColMax)*0.65 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.35 + 0010, "13 - Conta", oFont01) //13 - Conta
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.35 + 0020, aDados[nX, 13,nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.65, nLinIni + 0094, (nColIni + nColMax)*0.8 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.65 + 0010, "14 - Número do lote", oFont01) //14 - Número do lote
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.65 + 0020, aDados[nX, 14, nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.8, nLinIni + 0094, nColIni + nColMax - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.8 + 0010, "15 - Número do Protocolo", oFont01) //15 - Número do Protocolo
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.8 + 0020, aDados[nX, 15,nX1, nX2, nX3], oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
					oPrint:Box(nLinIni + 0000, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.25 - 0010)
					oPrint:Say(nLinIni + 0005, nColIni + 0020, "16 - Número da guia no prestador", oFont01) //16 - Número da guia no prestador
					oPrint:Say(nLinIni + 0035, nColIni + 0030, aDados[nX, 16, nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.25, nLinIni + 0094, (nColIni + nColMax)*0.50 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.25 + 0010, "17 - Número da Carteira", oFont01) //17 - Número da Carteira
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.25 + 0020, aDados[nX, 17, nX1, nX2, nX3], oFont04)
					oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.50, nLinIni + 0094, nColIni + nColMax - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.50 + 0010, "18 - Nome do Beneficiário", oFont01) //18 - Nome do Beneficiário
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.50 + 0020, aDados[nX, 18, nX1, nX2, nX3], oFont04)

					lBox:=.F.

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
					if (nLinIni + (Len(aDados[nX, 19,nX1, nX2, nX3]) * 75)) < nLinMax
						oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 60 + (Len(aDados[nX, 19,nX1, nX2, nX3]) * 75), nColIni + nColMax - 0010)
					Else
						oPrint:Line(nLinIni, nColIni + 0010, nLinIni + 0045, nColIni + 0010)
						oPrint:Line(nLinIni, nColIni + 0010, nLinIni, nColIni + nColMax)
						oPrint:Line(nLinIni, nColIni + nColMax, nLinIni + 0045, nColIni + nColMax)
						lBox:=.T.
					Endif

					oPrint:Say(nLinIni + 0002, nColIni + 0020, "19-Tabela", oFont01) //19-Tabela
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.06, "20-Código do Procedimento", oFont01) //20-Código do Procedimento
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.15, "21-Descrição", oFont01) //21-Descrição
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.35, "22-Dente/Região", oFont01) //22-Dente/Região
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.40, "23-Face", oFont01) //23-Face
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.47, "24-Data de Realização", oFont01) //24-Data de Realização
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.55, "25-Qtde", oFont01) //25-Qtde
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.62, "26-Valor Informado(R$)", oFont01) //26-Valor Informado(R$)
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.75, "27-Valor Processado(R$)", oFont01) //27-Valor Processado (R$)
					oPrint:Say(nLinIni + 0002, (nColIni + nColMax)*0.88, "28-Valor Glosa/Estorno(R$)", oFont01) //28-Valor Glosa/Estorno (R$)
					oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.06, "29-Valor Franquia(R$)", oFont01) //29-Valor Franquia(R$)
					oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.15, "30-Valor Liberado(R$)", oFont01) //30-Valor Liberado (R$)
					oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.35, "31-Código da Glosa", oFont01) //31-Código da Glosa

					nProcGui := 0
					nGloGui  := 0
					nLibGui  := 0

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60, 40)
					For nX4 := 1 To Len(aDados[nX, 19, nX1, nX2, nX3])

						if lBox
							oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0055, nColIni  + 0010)
							oPrint:Line(nLinIni + 0010, nColIni  + 3695 + nColA4, nLinIni + 0055, nColIni  + 3695 + nColA4)
						Endif

						oPrint:Say(nLinIni, nColIni + 0020, aDados[nX, 19, nX1, nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.06, aDados[nX, 20, nX1, nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.15, aDados[nX, 21, nX1, nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.35, aDados[nX, 22, nX1, nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.40, aDados[nX, 23, nX1, nX2, nX3, nX4], oFont04)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.47, DtoC(aDados[nX, 24, nX1, nX2, nX3, nX4]), oFont04)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.55, IIF(Empty(aDados[nX, 25, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 25, nX1, nX2, nX3, nX4], "99")), oFont04)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.62 + 200, IIF(Empty(aDados[nX, 26, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 26, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.75 + 200, IIF(Empty(aDados[nX, 27, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 27, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni, (nColIni + nColMax)*0.88 + 200, IIF(Empty(aDados[nX, 28, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 28, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)

						oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.06 + 200, IIF(Empty(aDados[nX, 29, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 29, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.15 + 200, IIF(Empty(aDados[nX, 30, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 30, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.35, aDados[nX, 31, nX1, nX2, nX3, 1], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 75, 40)
					Next nX4

					if lBox
						oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0010, nColIni + 3695 + nColA4)
					Endif

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20, 40)
					AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
					oPrint:Box(nLinIni + 0000, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
					oPrint:Say(nLinIni + 0005, nColIni + 0020, "32-Observação / Justificativa", oFont01) //32-Observação / Justificativa

					For nI := 1 To MlCount(aDados[nX, 32,nX1,nX2,nX3], 130)
						cObs := MemoLine(aDados[nX, 32,nX1,nX2,nX3], 130, nI)
						oPrint:Say(nLinIni + (nI*45), nColIni + 0030, cObs, oFont04)
					Next nI

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 230, 40)
					AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
					oPrint:Say(nLinIni + 0003, nColIni + 0020, "Total da Guia", oFont01) //Dados do Pagamento

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
					oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
					oPrint:Say(nLinIni + 0005, nColIni + 0020, "33- Valor Total Informado Guia (R$)", oFont01) //33- Valor Total Informado Guia (R$)
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.15 - 0020, Transform(aDados[nX, 33, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.30 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.15 + 0010, "34 - Valor Total Processado Guia (R$)", oFont01) //34 - Valor Total Processado Guia (R$)
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.30 - 0020, Transform(aDados[nX, 34, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.30, nLinIni + 0094, (nColIni + nColMax)*0.45 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.30 + 0010, "35 - Valor Total Glosa Guia (R$)", oFont01) //35 - Valor Total Glosa Guia (R$)
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.45 - 0020, Transform(aDados[nX, 35, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.45, nLinIni + 0094, (nColIni + nColMax)*0.60 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.45 + 0010, "36 - Valor Total Franquia Guia (R$)", oFont01) //36 - Valor Total Franquia Guia (R$)
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.60 - 0020, Transform(aDados[nX, 36, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.60, nLinIni + 0094, (nColIni + nColMax)*0.75 - 0010)
					oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.60 + 0010, "37 - Valor Total Liberado Guia (R$)", oFont01) //37 - Valor Total Liberado Guia (R$)
					oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.75 - 0020, Transform(aDados[nX, 37, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)

				Next nX3

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 40)
				AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
				oPrint:Say(nLinIni + 0003, nColIni + 0020, "Total do Protocolo", oFont01) //Total do Protocolo

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
				oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
				oPrint:Say(nLinIni + 0005, nColIni + 0020, "38 - Valor Total Informado Protocolo (R$)", oFont01) //38 - Valor Total Informado Protocolo (R$)
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.15 - 0020, Transform(aDados[nX, 38, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.30 - 0010)
				oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.15 + 0010, "39 - Valor Total Processado Protocolo (R$)", oFont01) //39 - Valor Total Processado Protocolo (R$)
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.30 - 0020, Transform(aDados[nX, 39, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni, (nColIni + nColMax)*0.30, nLinIni + 0094, (nColIni + nColMax)*0.45 - 0010)
				oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.30 + 0010, "40 - Valor Total Glosa Protocolo (R$)", oFont01) //40 - Valor Total Glosa Protocolo (R$)
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.45 - 0020, Transform(aDados[nX, 40, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni, (nColIni + nColMax)*0.45, nLinIni + 0094, (nColIni + nColMax)*0.60 - 0010)
				oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.45 + 0010, "41 - Valor Total Franquia Protocolo (R$)", oFont01) //41 - Valor Total Franquia Protocolo (R$)
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.60 - 0020, Transform(aDados[nX, 41, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni, (nColIni + nColMax)*0.60, nLinIni + 0094, (nColIni + nColMax)*0.75 - 0010)
				oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.60 + 0010, "42 - Valor Total Liberado Protocolo (R$)", oFont01) //42 - Valor Total Liberado Protocolo (R$)
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.75 - 0020, Transform(aDados[nX, 42, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)

			Next nX2

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
			AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
			oPrint:Say(nLinIni + 0003, nColIni + 0020, "Demais débitos / créditos", oFont01) //Demais débitos / créditos

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
			oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 40 + (Len(aDados[nX, 43,nX1]) * 45), nColIni + nColMax - 0010)
			oPrint:Say(nLinIni, nColIni + 0020, "43-Indicação", oFont01) //43-Indicação
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.10, "44-Código do débito/crédito", oFont01)  //44-Código do débito/crédito
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.20, "45-Descrição do débito/crédito", oFont01)  //45-Descrição do débito/crédito
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.85, "46-Valor", oFont01,,,,1)  //46-Valor

			For nI := 1 To Len(aDados[nX, 43,nX1])
				oPrint:Say(nLinIni + 0030, nColIni + 0020, aDados[nX, 43,nX1, nI], oFont04)
				oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.10, aDados[nX, 44,nX1, nI], oFont04)
				oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.20, aDados[nX, 45,nX1, nI], oFont04)
				oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.85, IIf(Empty(aDados[nX, 46,nX1, nI]), "", Transform(aDados[nX, 46,nX1, nI], "@E 999,999,999.99")), oFont04,,,,1)
				fSomaLin(nLinMax, nColMax, @nLinIni, nOldCol, 45, 40)
			Next nI

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
			AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, (nColIni + nColMax)*0.5 - 0010)
			oPrint:Say(nLinIni + 0003, nColIni + 0020, "Demais débitos / créditos não tributáveis", oFont01) //Demais débitos / créditos não tributáveis

			AddTBrush(oPrint, nLinIni, (nColIni + nColMax)*0.5 + 0010, nLinIni + 0030, nColIni + nColMax)
			oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.5 + 0020, "Impostos", oFont01) //Impostos

			nCount := Len(aDados[nX, 47,nX1])
			If (nCount < Len(aDados[nX, 51,nX1]))
				nCount := Len(aDados[nX, 51,nX1])
			EndIf

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
			oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 40 + (nCount * 45), (nColIni + nColMax)*0.5 - 0010)
			oPrint:Say(nLinIni, nColIni + 0020, "47-Indicação", oFont01) //47-Indicação
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.07, "48-Código do débito/crédito", oFont01) //48-Código do débito/crédito
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.17, "49-Descrição do débito/crédito", oFont01) //49-Descrição do débito/crédito
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.48, "50-Valor", oFont01,,,,1) //50-Valor

			oPrint:Box(nLinIni, (nColIni + nColMax)*0.5 + 0010, nLinIni + 40 + (nCount * 45), nColIni + nColMax - 0010)
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.5 + 0020, "51-Indicação", oFont01) //51-Indicação
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.57, "52-Código do débito/crédito", oFont01) //52-Código do débito/crédito
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.67, "53-Descrição do débito/crédito", oFont01) //53-Descrição do débito/crédito
			oPrint:Say(nLinIni, (nColIni + nColMax)*0.98, "54-Valor", oFont01,,,,1) //54-Valor

			If (nCount > 0)
				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 40)

				For nI := 1 To nCount
					If (Len(aDados[nX, 47, nX1]) >= nI)
						oPrint:Say(nLinIni + 0003, nColIni + 0020, aDados[nX, 47, nX1, nI], oFont04) //47-Indicação
						oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.07, aDados[nX, 48, nX1, nI], oFont04) //48-Código do débito/crédito
						oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.17, aDados[nX, 49, nX1, nI], oFont04) //49-Descrição do débito/crédito
						oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.48, IIf(Empty(aDados[nX, 50,nX1, nI]), "", Transform(aDados[nX, 50,nX1, nI], "@E 999,999,999.99")), oFont04,,,,1) //50-Valor
					EndIf

					If (Len(aDados[nX, 51, nX1]) >= nI)
						oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.5 + 0020, aDados[nX, 51, nX1, nI], oFont04) //51-Indicação
						oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.57, aDados[nX, 52, nX1, nI], oFont04) //52-Código do débito/crédito
						oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.67, aDados[nX, 53, nX1, nI], oFont04) //53-Descrição do débito/crédito
						oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.98, IIf(Empty(aDados[nX, 54,nX1, nI]), "", Transform(aDados[nX, 54,nX1, nI], "@E 999,999,999.99")), oFont04,,,,1) //54-Valor
					EndIf
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
				Next nI
			EndIf

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, IIF(nCount > 0, 25,50), 40)
			AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
			oPrint:Say(nLinIni + 0003, nColIni + 0020, "Totais", oFont01) //Total do Protocolo

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
			oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
			oPrint:Say(nLinIni + 0005, nColIni + 0020, "55 - Valor Total Tributável (R$)", oFont01) //55 - Valor Total Tributável (R$)
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.15 - 0020, Transform(aDados[nX, 55, nX1], "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box(nLinIni, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.30 - 0010)
			oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.15 + 0010, "56- Valor Total Impostos Retidos (R$)", oFont01) //56- Valor Total Impostos Retidos (R$)
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.30 - 0020, Transform(aDados[nX, 56, nX1], "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box(nLinIni, (nColIni + nColMax)*0.30, nLinIni + 0094, (nColIni + nColMax)*0.45 - 0010)
			oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.30 + 0010, "57 - Valor Total Não Tributável (R$)", oFont01) //57 - Valor Total Não Tributável (R$)
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.45 - 0020, Transform(aDados[nX, 57, nX1], "@E 999,999,999.99"), oFont04,,,,1)
			oPrint:Box(nLinIni, (nColIni + nColMax)*0.45, nLinIni + 0094, (nColIni + nColMax)*0.60 - 0010)
			oPrint:Say(nLinIni + 0005, (nColIni + nColMax)*0.45 + 0010, "58 - Valor Final a Receber (R$)", oFont01) //58 - Valor Final a Receber (R$)
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.60 - 0020, Transform(aDados[nX, 58, nX1], "@E 999,999,999.99"), oFont04,,,,1)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 105, 40)
			AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
			oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
			oPrint:Say(nLinIni + 0005, nColIni + 0020, "59 - Observação", oFont01) //59 - Observação

			For nI := 1 To MlCount(aDados[nX, 59, nX1], 130)
				cObs := MemoLine(aDados[nX, 59, nX1], 130, nI)
				oPrint:Say(nLinIni + (nI*40), nColIni + 0030, cObs, oFont04)
			Next nI

		Next nX1
		oPrint:EndPage()	// Finaliza a pagina

	Next nX

	if lAuto
		oPrint:Print()		// Imprime Relatorio
	else
		oPrint:Preview()	// Visualiza impressao grafica antes de imprimir
	endIf

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSC  ³ Autor ³ Bruno Iserhardt       ³ Data ³ 18.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3.00.01 (Guia de Serv/SADT)        ³±±
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

Function PLSTISSC(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW, lPreview, lProced, lAuto)

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
	Local nI, nJ, nX//, nN
	Local nV := 1
	local nV1, nV2 :=1
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local oFont05
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
	LOCAL cFileName := ""
	LOCAL cRel      := "guisadt"
	LOCAL cPathSrvJ := GETMV("MV_RELT")
	LOCAL nAL		  := 0.25
	LOCAL nAC		  := 0.24
	Local lImpPrc   := .T.
	Local cCodTab   := ""
	Local cCodPro   := ""
	Local cDescri	  := ""
	Local lImpNAut  := IIf(GetNewPar("MV_PLNAUT",0) == 0, .F., .T.) // 0 = Nao imprime procedimento nao autorizado 1 = Sim imprime
	Local nLinSeq	  := 0
	Local nSeq		  := 0
	Local nTotProc  := 0
	Local nTotDad	  := 0
	Local nTotDad65 := 0
	Local nTotGeral := 0
	Local lPlsGTiss := ExistBlock("PLSGTISS")
	Local cCodMedGen    := GetNewPar("MV_PLMEDPT","")
	Local cCodMatGen    := GetNewPar("MV_PLMATPT","")
	Local cCodTaxGen    := GetNewPar("MV_PLTAXPT","")
	Local cCodOpmGen    := GetNewPar("MV_PLOPMPT","")
	Local cTdsCodG      := ""
	Local cVlTiss		:= GetNewPar("MV_VLTISS","")
	Local aSubsTotais		:={} 
	Local nContrBd6     := 0
	Local nConSub       := 0    
	Local nM            := 0
	Local nCtnRel       := 0
	PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))

	DEFAULT lGerTXT 	:= .F.
	DEFAULT nLayout 	:= 2
	DEFAULT cLogoGH 	:= ""
	DEFAULT lWeb		:= .F.
	DEFAULT lPreview	:= .T.
	DEFAULT cPathRelW 	:= ""
	DEFAULT lProced		:= .F.
	Default lAuto		:= .F.
	DEFAULT aDados 	:= { {;
		"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- Nº Guia no Prestador
	"12345678901234567890",; //3- Número da guia principal
	CtoD("01/01/07"),; //4 - Data da Autorização
	"12345678901234567890",; //5-Senha
	CtoD("01/01/07"),; //6 - Data de Validade da Senha
	"12345678901234567890",; //7 - Número da Guia Atribuído pela Operadora
	"12345678901234567890",; //8 - Número da Carteira
	CtoD("12/12/07"),; //9 - Validade da Carteira
	Replicate("N",70),; //10 - Nome
	"123456789012345",; //11 - Cartão Nacional de Saúde
	"N",; //12 -Atendimento a RN
	"12345678901234",; //13 - Código na Operadora
	Replicate("N",70),; //14 - Nome do Contratado
	Replicate("N",70),; //15 - Nome do Profissional Solicitante
	"00",; //16 - Conselho Profissional
	"123456789012345",; //17 - Número no Conselho
	"UF",; //18 - UF
	"123456",; //19 - Código CBO
	"",; //20 - Assinatura do Profissional Solicitante
	"A",; //21 - Caráter do Atendimento
	CtoD("12/12/07"),; //22 - Data da Solicitação
	Replicate("A",500),; //23 - Indicação Clínica
	{ "10", "20", "30", "40", "50", "60" } ,; //24-Tabela
	{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234", "1111111111" },; //25- Código do Procedimento
	{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60),Replicate("E",60) },; //26 - Descrição
	{ 111,111,11,1,1,2 },; //27-Qtde. Solic.
	{ 999,999,99,9,9,1 },; //28-Qtde. Aut.
	"123456789012345",; //29-Código na operadora
	Replicate("M",70),; //30-Nome do contratado
	"9999999",; //31-Código CNES
	"TA",; //32-Tipo de Atendimento
	"A",; //33 - Indicação de Acidente
	"C",; //34 - Tipo de consulta
	"AA",; //35 - Motivo de Encerramento do Atendimento
	{ CtoD("12/12/07"),CtoD("12/12/07"),CtoD("12/12/07"),CtoD("12/12/07"),CtoD("12/12/07") },; //36 - Data
	{ "00:00","01:00","02:00","03:00","04:00" },; //37 - Hora Inicial
	{ "02:00","04:00","06:00","99:00","00:99" },; //38 - Hora Final
	{ "TT","TT","TT","TT","TT" },; //39 - Tabela
	{ "1234567890","1234567890","1234567890","1234567890","1234567890" },;//40-Código do Procedimento
	{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60) },;//41-Descrição
	{ 111, 222, 333, 444, 555},; //42 - Qtde.
	{ "0", "1", "2", "3", "4"},; //43-Via
	{ "0", "1", "2", "3", "4"},; //44-Tec.
	{ 0.99, 1.65 , 2.58 , 3.11 , 4.22},;//45- Fator Red./Acresc.
	{ 111111.99, 222222.65 , 333333.58 , 444444.11 , 555555.22},;//46-Valor Unitário (R$)
	{ 111111.99, 999999.65 , 888888.58 , 777777.11 , 666666.22},;//47-Valor Total (R$)
	{ "44", "33", "22", "11"},; //48-Seq.Ref
	{ "00", "11", "22", "33"},; //49-Grau Part.
	{ Replicate("M",14), Replicate("D",14), Replicate("C",14), Replicate("A",14)},; //50-Código na Operadora/CPF
	{ Replicate("B",70), Replicate("E",70), Replicate("X",70), Replicate("Z",70)},; //51-Nome do Profissional
	{ "12", "34", "56", "78"},; //52-Conselho Profissional
	{ Replicate("0",15), Replicate("1",15), Replicate("2",15), Replicate("3",15)},; //53-Número no Conselho
	{ "RS", "RJ", "SP", "RS"},; //54-UF
	{ "000000", "111111", "222222", "333333", "aaaaaa"},; //55-Código CBO
	{ CtoD("01/01/07"),CtoD("02/01/07"),CtoD("03/01/07"),CtoD("04/01/07"),CtoD("05/01/07"),CtoD("06/01/07"),CtoD("07/01/07"),CtoD("08/01/07"),CtoD("09/01/07"),CtoD("10/01/07")},; //56-Data de Realização de Procedimentos em Série
	"",;//57-Assinatura do Beneficiário ou Responsável
	Replicate("0",500),; //58-Observação / Justificativa
	12345678.90,; //59 - Total de Procedimentos (R$)
	12345678.90,; //60 - Total de Taxas e Aluguéis (R$)
	11111111.55,; //61 - Total de Materiais (R$)
	58745458.11,; //62- Total de OPME (R$)
	77777777.00,; //63 - Total de Medicamentos (R$)
	22222222.99,; //64 - Total de Gases Medicinais (R$)
	99999999.99 } } //65 - Total Geral (R$)

	oFont01	:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Nao permite acionar a impressao quando for na web.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb .Or. lAuto
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 	lPreview			)
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
	If lWeb .Or. lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
		nColMax	:=	3365 //3508 //3380 //3365
		nLayout 	:= 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 05, 05, , .F., , , , .T., .F.) // Normal
		oFont05		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Elseif oPrint:nPaperSize == 1 // Papel Carta
		nLinMax	:=	2000
		nColMax	:=	3175
		nLayout 	:= 3
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
		oFont05		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		nLinMax	:=	2435
		nColMax	:=	3765
		nLayout 	:= 1
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
		oFont05		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	cTdsCodG:=(cCodMedGen+ "-" +cCodMatGen+ "-" +cCodTaxGen+ "-" +cCodOpmGen)
	While lImpnovo

		lImpnovo:=.F.
		nVolta  += 1
		nT      += 5
		nT1     += 5
		nT2     += 5
		nT3     += 9
		nT4     += 9
		nProx   += 1

		For nX := 1 To Len(aDados)

			If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
				Loop
			EndIf
		
			If nV == 1 //signifiga que ja carrego os itens e ja esta imprimindo as paginas seguintes da guia
				For nI := 24 To 28
					If aDados[nX, nI] != NIL .and.  Len(aDados[nX, nI]) < nT
						For nJ := Len(aDados[nX, nI]) + 1 To nT
							If AllTrim(Str(nI)) $ "27,28"
								aAdd(aDados[nX, nI], 0)
							Else
								aAdd(aDados[nX, nI], "")
							EndIf
						Next nJ
					EndIf
				Next nI
	
				If Valtype(aDados[nX,40]) <> "U" // posso nao ter BD6 gravado, um autorização negada por exemplo
					For nI := 36 To 47
						If ValType(aDados[nX, nI]) == "U"
							aDados[nX, nI] := {}
						EndIf
						If Len(aDados[nX, nI]) < nT1
							For nJ := Len(aDados[nX, nI]) + 1 To Len(aDados[nX,40])
								If AllTrim(Str(nI)) $ "36"
									aAdd(aDados[nX, nI], StoD(""))
								ElseIf AllTrim(Str(nI)) $ "42,45,46,47"
									aAdd(aDados[nX, nI], 0)
								Else
									aAdd(aDados[nX, nI], "")
								EndIf
							Next nJ
						EndIf
					
					Next nI
				Else
					aDados[nX,39] := {}
					aDados[nX,40] := {}
					aDados[nX,45] := {}
					aDados[nX,46] := {}
					aDados[nX,47] := {}
				EndIf
	
				For nI := 48 To 55
					If aDados[nX][nI] != NIL
						If Len(aDados[nX, nI]) < nT2
							For nJ := Len(aDados[nX, nI]) + 1 To nT2
								aAdd(aDados[nX, nI], "")
							Next nJ
						EndIf
					EndIf
				Next nI
			Endif

			If oPrint:Cprinter == "PDF" .OR. lWeb
				nLinIni	:= 90
				nLimFim	:= 350
			Else
				nLinIni	:= 050
				nLimFim	:= 300
			Endif


			nColIni	:= 080
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
				oPrint:SayBitmap((nLinIni + 0030)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 	// Tem que estar abaixo do RootPath
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

			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.30))*nAC, "GUIA DE SERVIÇO PROFISSIONAL / SERVIÇO AUXILIAR DE", oFont02n,,,, 2) //GUIA DE SERVIÇO PROFISSIONAL / SERVIÇO AUXILIAR DE
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.36))*nAC, "DIAGNÓSTICO E TERAPIA - SP/SADT", oFont02n,,,, 2) //DIAGNÓSTICO E TERAPIA - SP/SADT
			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.70))*nAC, "2- Nº Guia no Prestador", oFont01) //"Nº"
			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.79))*nAC, aDados[nX, 02], oFont03n)

			oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0250)*nAL + nLinA4, (nColIni + (nColMax*0.1) - 0010)*nAC)
			oPrint:Say((nLinIni + 0170 + nLinA4)*nAL, (nColIni + 0015)*nAC, "1 - "+STR0003, oFont01) //"Registro ANS"
			oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 01], oFont04)
			oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + (nColMax*0.1))*nAC, (nLinIni + 0250)*nAL + nLinA4, (nColIni + (nColMax*0.37))*nAC)
			oPrint:Say((nLinIni + 0170 + nLinA4)*nAL, (nColIni + (nColMax*0.1) + 0010)*nAC, "3 - "+STR0061, oFont01) //"Nº Guia Principal"
			oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + (nColMax*0.1) + 0020)*nAC, aDados[nX, 03], oFont04)

			oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.14) - 0014)*nAC)
			oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + 0020)*nAC, "4 - Data da Autorização", oFont01) //"Data da Autorização"
			oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + 0030)*nAC, DtoC(aDados[nX, 04]), oFont04)
			oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + (nColMax*0.14))*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.42) - 0010)*nAC)
			oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + (nColMax*0.14) + 0010)*nAC, "5 - Senha", oFont01) //"Senha"
			oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + (nColMax*0.14) + 0020)*nAC, aDados[nX, 05], oFont04)
			oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + (nColMax*0.42))*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.54) - 0010)*nAC)
			oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + (nColMax*0.42) + 0010)*nAC, "6 - Data de Validade da Senha", oFont01) //"6 - Data de Validade da Senha"
			oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + (nColMax*0.42) + 0020)*nAC, DtoC(aDados[nX, 06]), oFont04)
			oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + (nColMax*0.54))*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.82) - 0010)*nAC)
			oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + (nColMax*0.54) + 0010)*nAC, "7 - Número da Guia Atribuído pela Operadora", oFont01) //"7 - Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + (nColMax*0.54) + 0020)*nAC, aDados[nX, 07], oFont04)

			AddTBrush(oPrint, (nLinIni + 0310 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0365)*nAL + nLinA4, (nColIni + nColMax)*nAC)
			oPrint:Say((nLinIni + 0330 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
			oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.20) - 0010)*nAC)
			oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + 0020)*nAC, "8 - Número da Carteira", oFont01) //"8 - Número da Carteira"
			oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 08], oFont04)
			oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.30) - 0010)*nAC)
			oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "9 - Validade da Carteira", oFont01) //"9 - Validade da Carteira"
			oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0020)*nAC, DtoC(aDados[nX, 09]), oFont04)
			
			If PLSTISSVER() < "4"			
				oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.75) - 0010)*nAC)
				oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "10 - Nome", oFont01) //"10 - Nome"
				oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, aDados[nX, 10], oFont04)
				oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.75))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.93) - 0010)*nAC)
				oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.75) + 0010)*nAC, "11 - Cartão Nacional de Saúde", oFont01) //"11 - Cartão Nacional de Saúde"
				oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.75) + 0020)*nAC, aDados[nX, 11], oFont04)
				oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.93))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.93) + 0010)*nAC, "12 -Atendimento a RN", oFont01) //"12 -Atendimento a RN"
				oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.93) + 0020)*nAC, aDados[nX, 12], oFont04)

				AddTBrush(oPrint, (nLinIni + 0420 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0475)*nAL + nLinA4, (nColIni + nColMax)*nAC)
				oPrint:Say((nLinIni + 0440 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Solicitante", oFont01) //"Dados do Solicitante"
				oPrint:Box((nLinIni + 0480)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0557)*nAL + nLinA4, (nColIni + (nColMax*0.20) - 0010)*nAC)
				oPrint:Say((nLinIni + 0475 + nLinA4)*nAL, (nColIni + 0020)*nAC, "13 - Código na Operadora", oFont01) //"13 - Código na Operadora"
				oPrint:Say((nLinIni + 0515 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 13], oFont04)
				oPrint:Box((nLinIni + 0480)*nAL + nLinA4, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 0557)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 0475 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "14 - Nome do Contratado", oFont01) //"14 - Nome do Contratado"
				oPrint:Say((nLinIni + 0515 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0020)*nAC, aDados[nX, 14], oFont04)
			Else

				If BA1->( FieldPos("BA1_NOMSOC") ) > 0
					oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.95) - 0010)*nAC)
					oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "89 - Nome Social ", oFont01) //"10 - Nome"
					oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, aDados[nX, 89], oFont04)
				Endif	


				oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.93))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.93) + 0010)*nAC, "12 -Atendimento a RN", oFont01) //"12 -Atendimento a RN"
				oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.93) + 0020)*nAC, aDados[nX, 12], oFont04)

				oPrint:Box((nLinIni + 0460)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0557)*nAL + nLinA4, (nColIni + (nColMax*0.30) - 0010)*nAC)
				oPrint:Say((nLinIni + 0455 + nLinA4)*nAL, (nColIni + 0020)*nAC, "10 - Nome", oFont01) //"10 - Nome"
				oPrint:Say((nLinIni + 0495 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 10], oFont04)


				AddTBrush(oPrint, (nLinIni + 0519 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0475)*nAL + nLinA4, (nColIni + nColMax)*nAC)

				oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Solicitante", oFont01) //"Dados do Solicitante"
				
				oPrint:Box((nLinIni + 0570)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0557)*nAL + nLinA4, (nColIni + (nColMax*0.20) - 0010)*nAC)
				oPrint:Say((nLinIni + 0575 + nLinA4)*nAL, (nColIni + 0020)*nAC, "13 - Código na Operadora", oFont01) //"13 - CÃ³digo na Operadora"
				oPrint:Say((nLinIni + 0605 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 13], oFont04)
				
				oPrint:Box((nLinIni + 0570)*nAL + nLinA4, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 0557)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 0575 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "14 - Nome do Contratado", oFont01) //"14 - Nome do Contratado"
				oPrint:Say((nLinIni + 0605 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0020)*nAC, aDados[nX, 14], oFont04)

			Endif

			oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.38) - 0010)*nAC)
			oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + 0020)*nAC, "15 - Nome do Profissional Solicitante", oFont01) //"15 - Nome do Profissional Solicitante"
			oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 15], oFont04)
			oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.38))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.43) - 0010)*nAC)
			oPrint:Say((nLinIni + 0550 + nLinA4)*nAL, (nColIni + (nColMax*0.38) + 0010)*nAC, "16 - Conselho", oFont01) //"16 - Conselho Profissional"
			oPrint:Say((nLinIni + 0570 + nLinA4)*nAL, (nColIni + (nColMax*0.38) + 0010)*nAC, "Profissional", oFont01) //"16 - Conselho Profissional"
			oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.38) + 0020)*nAC, aDados[nX, 16], oFont04)
			oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.43))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.56) - 0010)*nAC)
			oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.43) + 0010)*nAC, "17 - Número no Conselho", oFont01) //"17 - Número no Conselho"
			oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.43) + 0020)*nAC, aDados[nX, 17], oFont04)
			oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.56))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.59) - 0010)*nAC)
			oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.56) + 0010)*nAC, "18 - UF", oFont01) //"18 - UF"
			oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.56) + 0020)*nAC, aDados[nX, 18], oFont04)
			oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.59))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.67) - 0010)*nAC)
			oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.59) + 0010)*nAC, "19 - Código CBO", oFont01) //"19 - Código CBO"


			oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.59) + 0020)*nAC, aDados[nX, 19], oFont04)
			oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.67))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.67) + 0010)*nAC, "20 - Assinatura do Profissional Solicitante", oFont01) //"20 - Assinatura do Profissional Solicitante"

			AddTBrush(oPrint, (nLinIni + 0615 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0670)*nAL + nLinA4, (nColIni + nColMax)*nAC)
			oPrint:Say((nLinIni + 0635 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados da Solicitação / Procedimentos e Exames Solicitados", oFont01) //"Dados da Solicitação / Procedimentos e Exames Solicitados"
			oPrint:Box((nLinIni + 0675)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0752)*nAL + nLinA4, (nColIni + (nColMax*0.08) - 0010)*nAC)
			oPrint:Say((nLinIni + 0665 + nLinA4)*nAL, (nColIni + 0020)*nAC, "21 - Caráter do", oFont01) //"21 - Caráter do "
			oPrint:Say((nLinIni + 0685 + nLinA4)*nAL, (nColIni + 0020)*nAC, "Atendimento", oFont01) //"8 - Número da Carteira"
			oPrint:Say((nLinIni + 0710 + nLinA4)*nAL, (nColIni + 0080)*nAC, aDados[nX, 21], oFont04)
			oPrint:Box((nLinIni + 0675)*nAL + nLinA4, (nColIni + (nColMax*0.08))*nAC, (nLinIni + 0752)*nAL + nLinA4, (nColIni + (nColMax*0.17) - 0010)*nAC)
			oPrint:Say((nLinIni + 0665 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0010)*nAC, "22 - Data da Solicitação", oFont01) //"22 - Data da Solicitação"
			oPrint:Say((nLinIni + 0710 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0020)*nAC, DtoC(aDados[nX, 22]), oFont04)
			oPrint:Box((nLinIni + 0675)*nAL + nLinA4, (nColIni + (nColMax*0.17))*nAC, (nLinIni + 0752)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0665 + nLinA4)*nAL, (nColIni + (nColMax*0.17) + 0010)*nAC, "23 - Indicação Clínica", oFont01) //"23 - Indicação Clínica"
			oPrint:Say((nLinIni + 0710 + nLinA4)*nAL, (nColIni + (nColMax*0.17) + 0020)*nAC, aDados[nX, 23], oFont04)

			oPrint:Box((nLinIni + 0760)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1000)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.02))*nAC, "24-Tabela", oFont01) //"24-Tabela"
			oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.06))*nAC, "25- Código do Procedimento", oFont01) //"25- Código do Procedimento"
			oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.16))*nAC, "26 - Descrição", oFont01) //"26 - Descrição"
			oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.85))*nAC, "27-Qtde. Solic.", oFont01) //"27-Qtde. Solic."
			oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, "28-Qtde. Aut.", oFont01) //"28-Qtde. Aut."

			nOldLinIni := nLinIni

			if nVolta = 1
				nV:=1
			Endif

			cOper := substr(aDados[nX, 2],1,4)
			cAno  := substr(aDados[nX, 2],6,4)
			cMes  := substr(aDados[nX, 2],11,2)
			cAut  := substr(aDados[nX, 2],14,8)
		
			if nV == 1
				lLibera := .F.
			endif
        
		//Realizo a consulta na BEA
			DbSelectArea("BEA")
			BEA->(dbSetOrder(1))
			If  nV == 1 .and. BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))  // nV > 1 signifiga que ja carrego os itens e ja esta imprimindo as paginas seguintes da guia
				If BEA->BEA_LIBERA == '0'
				//se eh uma execucao eu tenho que refazer os procedimentos que foram solicitados
					If !Empty(BEA->BEA_NRLBOR)
						xChave := alltrim(BEA->BEA_NRLBOR)
					Else
						xChave := alltrim(cOper+cAno+cMes+cAut)
					Endif
				Else
				//se eh uma solicitacao eu tenho que refazer os procedimentos que foram solicitados e autorizados
					xChave := alltrim(cOper+cAno+cMes+cAut)
					lLibera := .t.
				Endif

				BE2->(DbSetORder(1))
				if !Empty(xChave) .and. BE2->(MsSeek(xFilial('BE2')+alltrim(xChave)))
					aDados[nX, 24] := {}
					aDados[nX, 25] := {}
					aDados[nX, 26] := {}
					aDados[nX, 27] := {}
					aDados[nX, 28] := {}
					While !BE2->(Eof()) .and. xFilial('BE2')+xChave == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
						If (BE2->BE2_STATUS == '0' .And. lImpNAut) .Or. BE2->BE2_STATUS == '1'

							BD6->(DbSetOrder(6))
							If BD6->(MsSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+'1'+BE2->(BE2_CODPAD+BE2_CODPRO))) .and. !Empty(BD6->BD6_SLVPAD)

								cPadBkp := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  BD6->BD6_CODPAD,.F.)
							
								BTP->(DbSetOrder(1))
								If BTP->(Msseek(xFilial("BTP")+cPadBkp)) .AND. BTP->BTP_BUSDIR == "1"
									cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., cPadBkp,  BD6->BD6_CODPRO, .F. ,aTabDup, @cPadBkp)
								else
									cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., '',  BD6->BD6_CODPRO, .F. ,aTabDup, @cPadBkp,alltrim(cPadBkp)+BD6->BD6_CODPRO)
								endif
							
								cCodTab := cPadBkp
							
								If ALLTRIM(cCodPro) $ cTdsCodG .And. ALLTRIM(cCodPro) == ALLTRIM(BE2->BE2_CODPRO)
									cDescri:= BE2->BE2_DESPRO
								Else
									cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., cCodTab,  cCodPro)
								EndIf
							

							Else

								cPadBkp := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  BE2->BE2_CODPAD,.F.)

							
								BTP->(DbSetOrder(1))
								If BTP->(Msseek(xFilial("BTP")+cPadBkp)) .AND. BTP->BTP_BUSDIR == "1"
									cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., cPadBkp,  alltrim(BE2->BE2_CODPRO), .F. ,aTabDup, @cPadBkp)
								else
									cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., cPadBkp , alltrim(BE2->BE2_CODPRO), .F. ,aTabDup, @cPadBkp  /*,alltrim(cPadBkp)+BE2->BE2_CODPRO*/)
								endif
							
							
								cCodTab := cPadBkp
							
								If ALLTRIM(cCodPro) $ cTdsCodG .And. ALLTRIM(cCodPro) == ALLTRIM(BE2->BE2_CODPRO)
									cDescri:= BE2->BE2_DESPRO
								Else
									cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., cCodTab,  cCodPro)
									if(cDescri == cCodPro)
										for nI = 1 to len(aTabDup)
											if(BE2->BE2_CODPAD == aTabDup[nI][2])
												cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., aTabDup[nI][1],  cCodPro)
												if(cDescri != cCodPro)
													 cCodTab := aTabDup[nI][1]
												     exit
											    EndIf
											EndIf
										next
									EndIf
								EndIf
							Endif
					                     
							aAdd(aDados[nX, 24], cCodTab)
							aAdd(aDados[nX, 25], cCodPro)
							aAdd(aDados[nX, 26], IIF(ALLTRIM(cCodPro) $ cTdsCodG,BE2->BE2_DESPRO,cDescri))
							aAdd(aDados[nX, 27], BE2->BE2_QTDSOL)
						
							//Validação necessária pois a forma de exibição desses campos na guia de liberação e execução são diferentes
							//ATENÇÃO ESSA PARTE NA GUIA SADT DEVE IMPRIMIR SEMPRE OS DADOS DA SOLICITAÇÃO!!!
							//TANTO QUE A SEÇÃO SE CHAMA DADOS DA SOLICITAÇÃO / PROCEDIMENTOS E EXAMES SOLICITADOS
							//se for execuão direto (sem liberação) posso imprimir o qtdpro, se não preciso imprimir os procedimentos da liberação
							//ou se for liberação mas o saldo, o qtd pro e qtd sol estiver com o mesmo valor (o sistema grava quando autoriza direto no remote)
							//se eu solicitei qtd 10, o sistema grava (no remote) 10 no qtd sol  10 no qtd pro e 10 no saldo
							aAdd(aDados[nX, 28], IIf(BE2->BE2_STATUS = '1', BE2->BE2_QTDPRO, 0))
						Endif

						BE2->(DbSkip())
					Enddo
					For nI := 24 To 28
						If Len(aDados[nX, nI]) < nT
							For nJ := Len(aDados[nX, nI]) + 1 To nT
								If AllTrim(Str(nI)) $ "27,28"
									aAdd(aDados[nX, nI], 0)
								Else
									aAdd(aDados[nX, nI], "")
								EndIf
							Next nJ
						EndIf
					Next nI
				Endif
			Endif

        //Imprime procedimentos solicitados
			For nP := nV To nT
			
				If nP > Len(aDados[nX, 24])
					Exit
				Endif
			
				oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
				oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.020))*nAC, aDados[nX, 24, nP], oFont04)
				oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.06))*nAC, aDados[nX, 25, nP], oFont04)
				oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.16))*nAC, aDados[nX, 26, nP], oFont04)
				oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.85))*nAC, IIf(Empty(aDados[nX, 27, nP]) .AND. EMPTY(aDados[nX, 25, nP]), "", Transform(aDados[nX, 27, nP], "@E 9999.99")), oFont04,,,,1)
				oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, IIf(Empty(aDados[nX, 28, nP]) .AND. EMPTY(aDados[nX, 25, nP]), "", Transform(aDados[nX, 28, nP], "@E 9999.99")), oFont04,,,,1)

				nLinIni += 40
			Next nP

			if nT < Len(aDados[nX, 24]).or. lImpnovo
				nV := nP
				lImpnovo := .T.
			Endif

			nLinIni := nOldLinIni

			AddTBrush(oPrint, (nLinIni + 0980 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1035)*nAL + nLinA4, (nColIni + nColMax)*nAC)
			oPrint:Say((nLinIni + 1000 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Contratado Executante", oFont01) //"Dados do Contratado Executante"
			oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1118)*nAL + nLinA4, (nColIni + (nColMax*0.20) - 0010)*nAC)
			oPrint:Say((nLinIni + 1035 + nLinA4)*nAL, (nColIni + 0020)*nAC, "29 - Código na Operadora", oFont01) //"29 - Código na Operadora"

			If !lLibera
				oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 29], oFont04)
			Endif

			oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 1118)*nAL + nLinA4, (nColIni + (nColMax*0.87) - 0010)*nAC)
			oPrint:Say((nLinIni + 1035 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "30 - Nome do Contratado", oFont01) //"30 - Nome do Contratado"

			If !lLibera
				oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + (nColMax*0.20) + 0020)*nAC, aDados[nX, 30], oFont04)
			Endif

			oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + (nColMax*0.87))*nAC, (nLinIni + 1118)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1035 + nLinA4)*nAL, (nColIni + (nColMax*0.87) + 0010)*nAC, "31 - Código CNES", oFont01) //"31 - Código CNES"
			oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + (nColMax*0.87) + 0020)*nAC, aDados[nX, 31], oFont04)

			AddTBrush(oPrint, (nLinIni + 1095 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1149.1)*nAL + nLinA4, (nColIni + nColMax)*nAC)
			oPrint:Say((nLinIni + 1110 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Atendimento", oFont01) //"Dados do Atendimento"
			oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.08) - 0010)*nAC)
			oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + 0020)*nAC, "32-Tipo de Atendimento", oFont01) //"32-Tipo de Atendimento"
			oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + 0100)*nAC, aDados[nX, 32], oFont04)
			oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.08))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.29) - 0010)*nAC)
			oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0010)*nAC, "33 - Indicação de Acidente (acidente ou doença relacionada", oFont01) //"33 - Indicação de Acidente (acidente ou doença relacionada"
			oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0020)*nAC, aDados[nX, 33], oFont04)

			oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.29))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.36) - 0010)*nAC)
			oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.29) + 0010)*nAC, "34 - Tipo de Consulta", oFont01) //"34 - Tipo de Consulta"
			oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.29) + 0020)*nAC, aDados[nX, 34], oFont04)

			oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.36))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.53) - 0010)*nAC)
			oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.36) + 0010)*nAC, "35 - Motivo de Encerramento do Atendimento", oFont01) //"35 - Motivo de Encerramento do Atendimento"
			oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.36) + 0020)*nAC, aDados[nX, 35], oFont04)

			If PLSTISSVER() >= "4"

				If BEA->( FieldPos("BEA_TMREGA") ) > 0
					oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.53))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.63) - 0010)*nAC)
					oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.53) + 0010)*nAC, "91 - Regime de atendimento", oFont01) //"91 - Regime de atendimento"
					oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.53) + 0020)*nAC, aDados[nX, 91], oFont04)
				Endif

				
				If BEA->( FieldPos("BEA_SAUOCU") ) > 0
					oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.63))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.72) - 0010)*nAC)
					oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.63) + 0010)*nAC, "92 - Saúde Ocupacional", oFont01) //"92 - Saúde Ocupacional"
					oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.63) + 0020)*nAC, aDados[nX, 92], oFont04)
				Endif
			Endif	

			AddTBrush(oPrint, (nLinIni + 1200 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1260)*nAL + nLinA4, (nColIni + nColMax)*nAC)
			oPrint:Say((nLinIni + 1220 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados da Execução / Procedimentos e Exames Realizados", oFont01) //Dados da Execução / Procedimentos e Exames Realizados
			oPrint:Box((nLinIni + 1265)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1500)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.02))*nAC, "36-Data", oFont01) //"36-Data"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.09))*nAC, "37-Hora Inicial", oFont01) //"37-Hora Inicial"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.14))*nAC, "38-Hora Final", oFont01) //"38-Hora Final"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.19))*nAC, "39-Tabela", oFont01) //"39-Tabela"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.22))*nAC, "40-Código do Procedimento", oFont01) //"40-Código do Procedimento"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.31))*nAC, "41-Descrição", oFont01) //"41-Descrição"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.66))*nAC, "42 - Qtde.", oFont01) //"42 - Qtde."
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.69))*nAC, "43-Via", oFont01) //"43-Via"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.715))*nAC, "44-Tec.", oFont01) //"44-Tec."
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.74))*nAC, "45- Fator Red./Acresc.", oFont01) //"45- Fator Red./Acresc."
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.81))*nAC, "46-Valor Unitário (R$)", oFont01) //"46-Valor Unitário (R$)"
			oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.90))*nAC, "47-Valor Total (R$)", oFont01) //"47-Valor Total (R$)"

			nOldLinIni := nLinIni

			if nVolta == 1
				nV1 := 1
			Endif

			If lPlsGTiss
				lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"02",lImpPrc})
			EndIf

			If lImpPrc
				aDados[nX, 59] := 0
				aDados[nX, 60] := 0
				aDados[nX, 61] := 0
				aDados[nX, 62] := 0
				aDados[nX, 63] := 0
				aDados[nX, 64] := 0
				aDados[nX, 65] := {}
			
				//Procedimentos execução			
				If !lLibera .And. Len(aDados[nX, 40]) > 0
					//aqui ocorre um outro problema.. la na b7a e b7b no plsa446 ele busca primeiro o codpad.. mas o codpad as vezes pode vir errado
					//pois pode ter mais de um de-para entao aqui tem q se fazer a busca pelo codigo pad correto
					//ou seja, vou desconsiderar o de-para feito no 466 e vou fazer o de-para denovo por aqui
					DbSelectArea("BEA")
					BEA->(dbSetOrder(1))
					If BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))
						cCodLdp := BEA->BEA_CODLDP
						cCodPeg := BEA->BEA_CODPEG
						cNumero := BEA->BEA_NUMGUI
						cOriMov := BEA->BEA_ORIMOV
						BR8->(dbSetOrder(3))
						BD6->(DbSetORder(1))
						if  BD6->(MsSeek(xFilial('BD6')+cOper+cCodLdp+cCodPeg+cNumero+cOriMov))
							nItemBd6:=1
							nContrBd6:=Len(aDados[nX, 36])
							If Len(aSubsTotais) == 0
								While !BD6->(Eof()) .and.  nItemBd6 <= nContrBd6 .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial('BD6')+cOper+cCodLdp+cCodPeg+cNumero+cOriMov 
									BR8->(MsSeek(xFilial("BR8")+BD6->(BD6_CODPRO+BD6_CODPAD)))
									cPadBkp := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  BD6->BD6_CODPAD,.F.)
									cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., cPadBkp , alltrim (BD6->BD6_CODPRO), .F. ,aTabDup, @cPadBkp/*,alltrim(cPadBkp)+BD6->BD6_CODPRO*/)
									cCodPad := cPadBkp
									cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., cCodPad,  cCodPro)
									if(cDescri == cCodPro)
										for nI = 1 to len(aTabDup)
											if(BD6->BD6_CODPAD == aTabDup[nI][2])
												cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., aTabDup[nI][1],  cCodPro)
												if(cDescri != cCodPro)
													 cCodPad := aTabDup[nI][1]
												     exit
											    EndIf
											EndIf
										next
									EndIf
			
									aDados[nX, 36,nItemBd6] := BD6->BD6_DATPRO
									aDados[nX, 37,nItemBd6] := BD6->BD6_HORPRO
									aDados[nX, 38,nItemBd6] := BD6->BD6_HORFIM
									aDados[nX, 39,nItemBd6] := cCodPad
									aDados[nX, 40,nItemBd6] := cCodPro
									aDados[nX, 41,nItemBd6] := Substr(cDescri,1,77)
									aDados[nX, 42,nItemBd6] := BD6->BD6_QTDPRO
									aDados[nX, 43,nItemBd6] := BD6->BD6_VIA
									aDados[nX, 46,nItemBd6] := IIF(BD6->BD6_VLRAPR > 0,BD6->BD6_VLRAPR,BD6->BD6_VLRPAG / BD6->BD6_QTDPRO)
									aDados[nX, 47,nItemBd6] := IIF(BD6->BD6_VLRAPR > 0,BD6->BD6_VLRAPR * BD6->BD6_QTDPRO,BD6->BD6_VLRPAG)
								
									aadd(aSubsTotais,BD6->(RECNO()))
									nItemBd6++
									BD6->(dbskip())
								Enddo
							Endif
			
							//Procedimentos execução
							For nP1 := nV1 To nT1  
								nConSub:=Len(aSubsTotais)
								
								If nP1 > Len(aDados[nX, 24]) .or.  nP1 > Len(aDados[nX,40]) .Or. nP1>nConSub
									Exit
								Endif
							
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + 0015)*nAC, AllTrim(Str(nP1)) + " - ", oFont01)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.020))*nAC, IIf(Empty(aDados[nX, 36, nP1]), "", DtoC(aDados[nX, 36, nP1])), oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.090))*nAC, IIf(Empty(aDados[nX, 37, nP1]), "", Transform(aDados[nX, 37, nP1], "@R 99:99")), oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.140))*nAC, IIf(Empty(aDados[nX, 38, nP1]), "", Transform(aDados[nX, 38, nP1], "@R 99:99")), oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.190))*nAC, aDados[nX, 39, nP1], oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.22))*nAC, aDados[nX, 40, nP1], oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.31))*nAC, aDados[nX, 41, nP1], oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.660))*nAC, IIf(Empty(aDados[nX, 42, nP1]), "", Transform(aDados[nX, 42, nP1], "@E 9999.99")), oFont04,,,,1)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.690))*nAC, aDados[nX, 43, nP1], oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.72))*nAC, aDados[nX, 44, nP1], oFont04)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.755))*nAC, IIf(Empty(aDados[nX, 45, nP1]), "", Transform(aDados[nX, 45, nP1], "@E 9999.99")), oFont04,,,,1)
								
								If cVlTiss == "1"
									oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.82))*nAC, IIf(Empty(aDados[nX, 46, nP1]), "", Transform(aDados[nX, 46, nP1], "@E 99,999,999.99")), oFont04,,,,1)
									oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.91))*nAC, IIf(Empty(aDados[nX, 47, nP1]), "", Transform(aDados[nX, 47, nP1], "@E 99,999,999.99")), oFont04,,,,1)
								EndIf
							
								BD6->(DbGoTo(aSubsTotais[nP1]))
							
							
								If BR8->(MsSeek(xFilial("BR8")+BD6->(BD6_CODPRO+BD6_CODPAD)))
																
									If BR8->BR8_TPPROC == '0' //Procedimentos
										aDados[nX, 59] :=  aDados[nX, 59] + (aDados[nX, 47, nP1])
									ELSEIf BR8->BR8_TPPROC == '1' //Material
										aDados[nX, 61] :=  aDados[nX, 61] + (aDados[nX, 47, nP1])
									ELSEIf BR8->BR8_TPPROC == '2' //Medicamento
										aDados[nX, 63] :=  aDados[nX, 63] + (aDados[nX, 47, nP1])
									ELSEIf BR8->BR8_TPPROC == '3' //Taxa
										aDados[nX, 60] :=  aDados[nX, 60] + (aDados[nX, 47, nP1])
									ELSEIf BR8->BR8_TPPROC == '5' //OPME
										aDados[nX, 62] :=  aDados[nX, 62] + (aDados[nX, 47, nP1])
									ELSEIf BR8->BR8_TPPROC == '7' //Gas Medicinal
										aDados[nX, 64] :=  aDados[nX, 64] + (aDados[nX, 47, nP1])
									Else
										aDados[nX, 59] :=  aDados[nX, 59] + (aDados[nX, 47, nP1])
									EndIf
									nTotGeral :=  nTotGeral + (aDados[nX, 47, nP1])
								Endif
								nLinIni += 40
							Next nP1
						Endif
					ElseIf lProced //Indica que os procedimentos apresentados na guia estão no array aDados[nX,36] até aDados[nX,47]. Não busca na BD6. Ex: Origem HSP   
						//Procedimentos execução
						For nP1 := nV1 To nT1  
							
							If nP1 > Len(aDados[nX, 24]) .or.  nP1 > Len(aDados[nX,40])
								Exit
							Endif
						
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + 0015)*nAC, AllTrim(Str(nP1)) + " - ", oFont01)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.020))*nAC, IIf(Empty(aDados[nX, 36, nP1]), "", DtoC(aDados[nX, 36, nP1])), oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.090))*nAC, IIf(Empty(aDados[nX, 37, nP1]), "", Transform(aDados[nX, 37, nP1], "@R 99:99")), oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.140))*nAC, IIf(Empty(aDados[nX, 38, nP1]), "", Transform(aDados[nX, 38, nP1], "@R 99:99")), oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.190))*nAC, aDados[nX, 39, nP1], oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.22))*nAC, aDados[nX, 40, nP1], oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.31))*nAC, aDados[nX, 41, nP1], oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.660))*nAC, IIf(Empty(aDados[nX, 42, nP1]), "", Transform(aDados[nX, 42, nP1], "@E 9999.99")), oFont04,,,,1)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.690))*nAC, aDados[nX, 43, nP1], oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.72))*nAC, aDados[nX, 44, nP1], oFont04)
							oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.755))*nAC, IIf(Empty(aDados[nX, 45, nP1]), "", Transform(aDados[nX, 45, nP1], "@E 9999.99")), oFont04,,,,1)
							
							If cVlTiss == "1"
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.82))*nAC, IIf(Empty(aDados[nX, 46, nP1]), "", Transform(aDados[nX, 46, nP1], "@E 99,999,999.99")), oFont04,,,,1)
								oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.91))*nAC, IIf(Empty(aDados[nX, 47, nP1]), "", Transform(aDados[nX, 47, nP1], "@E 99,999,999.99")), oFont04,,,,1)
							EndIf
						
							nTotGeral :=  nTotGeral + (aDados[nX, 47, nP1])
							
							nLinIni += 40
						Next nP1	
					EndIf
				endif
				nCtnRel := 0
				For nM:=1 to LEN(aDados[nX, 25]) 
					If !Empty(aDados[nX, 25, nM])
						nCtnRel++
					EndIf
				Next

				if nT1 < nCtnRel .or. lImpnovo
					nV1 	 := nP1
					lImpnovo := .T.
					
				Endif

				nLinIni := nOldLinIni

				AddTBrush(oPrint, (nLinIni + 1480 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1535)*nAL + nLinA4, (nColIni + nColMax)*nAC)
				oPrint:Say((nLinIni + 1500 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Identificação do(s) Profissional(is) Executante(s)", oFont01) //Identificação do(s) Profissional(is) Executante(s)
				oPrint:Box((nLinIni + 1540)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1775)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.008))*nAC, "48-Seq.Ref", oFont01) //"48-Seq.Ref"
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.04))*nAC, "49-Grau Part.", oFont01) //"49-Grau Part."
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.09))*nAC, "50-Código na Operadora/CPF", oFont01) //"50-Código na Operadora/CPF"
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.25))*nAC, "51-Nome do Profissional", oFont01) //"51-Nome do Profissional"
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.64))*nAC, "52-Conselho", oFont01) //"52-Conselho"
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.68))*nAC, "53-Número no Conselho", oFont01) //"53-Número no Conselho"
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.88))*nAC, "54-UF", oFont01) //"54-UF"
				oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, "55-Código CBO", oFont01) //"55-Código CBO"

				if nVolta == 1
					nV2 := 1
				Endif

				For nP2 := nV2 To nT2
					
					nSeq := 1
					
					if valType(aDados[nX, 49]) == 'U' .or. len(aDados[nX, 49]) < nP2 .Or. len(aDados[nX, 55]) < nP2 
						exit
					endIf
					
					If aDados[nX, 50] != NIL
					
						If !lLibera .and. !Empty(aDados[nX, 50, nP2])
					
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.017))*nAC, cValToChar(val(aDados[nX, 48, nP2])) + " - ", oFont04)
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.051))*nAC, aDados[nX, 49, nP2], oFont04)
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.09))*nAC, aDados[nX, 50, nP2], oFont04)
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.25))*nAC, aDados[nX, 51, nP2], oFont04)
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.64))*nAC, aDados[nX, 52, nP2], oFont04)
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.68))*nAC, If (Empty(aDados[nX, 53, nP2]), "", Transform(aDados[nX, 53, nP2], "999999999999999")), oFont04)
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.883))*nAC, aDados[nX, 54, nP2], oFont04)
					
							If FUNNAME() == "HSPAHM30"
								oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, "", oFont04)
							Else
								oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, aDados[nX, 55, nP2], oFont04)
							EndIf
							
							nLinIni += 40
							
						Endif
						
					EndIf
					
					nSeq++
				Next nP2
		
			   
				If aDados[nX, 48] != NIL
					If nT2 < Len(aDados[nX, 48]).or. lImpnovo
						nV2:=nP2
					Endif
				Endif
	
				nLinIni := nOldLinIni
				oPrint:Box((nLinIni + 1785)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1920)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1780 + nLinA4)*nAL, (nColIni + 0020)*nAC, "56-Data de Realização de Procedimentos em Série 57-Assinatura do Beneficiário ou Responsável", oFont01) //56-Data de Realização de Procedimentos em Série 57-Assinatura do Beneficiário ou Responsável
				if Len(aDados[nX])>69 //Necessário Estar coma B7B atualizada referente a Issue DSAUBE-2126
					oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + 0020)*nAC, "1-  "+If (Empty(aDados[nX, 70]), "", dToc(aDados[nX, 70]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + 0020)*nAC, "2-  "+If (Empty(aDados[nX, 71]), "", dToc(aDados[nX, 71]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5))*nAC, "3-  "+If (Empty(aDados[nX, 72]), "", dToc(aDados[nX, 72]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5))*nAC, "4-  "+If (Empty(aDados[nX, 73]), "", dToc(aDados[nX, 73]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5*2))*nAC, "5-  "+If (Empty(aDados[nX, 74]), "", dToc(aDados[nX, 74]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5*2))*nAC, "6-  "+If (Empty(aDados[nX, 75]), "", dToc(aDados[nX, 75]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5*3))*nAC, "7-  "+If (Empty(aDados[nX, 76]), "", dToc(aDados[nX, 76]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5*3))*nAC, "8-  "+If (Empty(aDados[nX, 77]), "", dToc(aDados[nX, 77]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5*4))*nAC, "9-  "+If (Empty(aDados[nX, 78]), "", dToc(aDados[nX, 78]))+"   ____________________________", oFont04)
					oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5*4))*nAC, "10-  "+Iif(Len(aDados[nX]) > 78, If (Empty(aDados[nX, 79]), "", dToc(aDados[nX, 79])), "")+"   ____________________________", oFont04)
				Endif

				oPrint:Line((nLinIni + 1930)*nAL + nLinA4, (nColIni + 0010)*nAC,(nLinIni + 1930)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Line((nLinIni + 1930)*nAL + nLinA4, (nColIni + 0010)*nAC,(nLinIni + 2110)*nAL + nLinA4, (nColIni + 0010)*nAC)
				oPrint:Line((nLinIni + 1930)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC, (nLinIni + 2110)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Line((nLinIni + 2110)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 2110)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1925 + nLinA4)*nAL, (nColIni + 0020)*nAC, "58-Observação / Justificativa", oFont01) //58-Observação / Justificativa
		
				nLin := 0
		       //Defino as variáveis para a consultada na BEA
				cOper := substr(aDados[nX, 2],1,4)
				cAno  := substr(aDados[nX, 2],6,4)
				cMes  := substr(aDados[nX, 2],11,2)
				cAut  := substr(aDados[nX, 2],14,8)
		
				//Realizo a consulta na BEA
				DbSelectArea("BEA")
				BEA->(dbSetOrder(1))
				BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))
		
				//acrescento na posição da observação o resultado da busca, pois estava vindo errado
				If PGETTISVER() < '3'//No caso da Tiss 3, considero a parametrizacao da estrutura de impressao B7B para o campo 58 - Observacao / Justificativa
					aDados[nX, 58] := BEA->BEA_MSG01 + BEA->BEA_MSG02
				EndIf

				For nI := 1 To MlCount(aDados[nX, 58])
					cObs := MemoLine(aDados[nX, 58], 200, nI)
					If cObs == ""
						exit
					Endif
					oPrint:Say((nLinIni + 1965 + nLinA4 + nLin)*nAL, (nColIni + 0030)*nAC, LOWERACE(cObs), oFont05)
					nLin += 50
				Next nI

				oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + (nColMax/7) - 0010)*nAC)
				oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + 0020)*nAC, "59 - Total de Procedimentos (R$)", oFont01) //59 - Total de Procedimentos (R$)
				
				If cVlTiss == "1"
					oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + 0030)*nAC, IIf(Empty(aDados[nX, 59]), "", Transform(aDados[nX, 59], "@E 99,999,999.99")), oFont04)
				EndIf

				oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + nColMax/7)*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*2) - 0010)*nAC)
				oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + (nColMax/7) + 0010)*nAC, "60 - Total de Taxas e Aluguéis (R$)", oFont01) //60 - Total de Taxas e Aluguéis (R$)
				
				If cVlTiss == "1"
					oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + (nColMax/7) + 0020)*nAC, IIf(Empty(aDados[nX, 60]), "", Transform(aDados[nX, 60], "@E 99,999,999.99")), oFont04)
				EndIf
				
				oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*2))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*3) - 0010)*nAC)
				oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*2) + 0010)*nAC, "61 - Total de Materiais (R$)", oFont01) //61 - Total de Materiais (R$)
				
				If cVlTiss == "1"
					oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*2) + 0020)*nAC, IIf(Empty(aDados[nX, 61]), "", Transform(aDados[nX, 61], "@E 99,999,999.99")), oFont04)
				EndIf
				
				oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*3))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*4) - 0010)*nAC)
				oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*3) + 0010)*nAC, "62- Total de OPME (R$)", oFont01) //62- Total de OPME (R$)
			
				If cVlTiss == "1"
					oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*3) + 0020)*nAC, IIf(Empty(aDados[nX, 62]), "", Transform(aDados[nX, 62], "@E 99,999,999.99")), oFont04)
				EndIf
			
				oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*4))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*5) - 0010)*nAC)
				oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*4) + 0010)*nAC, "63 - Total de Medicamentos (R$)", oFont01) //63 - Total de Medicamentos (R$)
				
				If cVlTiss == "1"
					oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*4) + 0020)*nAC, IIf(Empty(aDados[nX, 63]), "", Transform(aDados[nX, 63], "@E 99,999,999.99")), oFont04)
				EndIf
				
				oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*5))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*6) - 0010)*nAC)
				oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*5) + 0010)*nAC, "64 - Total de Gases Medicinais (R$)", oFont01) //64 - Total de Gases Medicinais (R$)
				
				If cVlTiss == "1"
					oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*5) + 0020)*nAC, IIf(Empty(aDados[nX, 64]), "", Transform(aDados[nX, 64], "@E 99,999,999.99")), oFont04)
				EndIf
				
				oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*6))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*6) + 0010)*nAC, "65 - Total Geral (R$)", oFont01) //65 - Total Geral (R$)
				
				If cVlTiss == "1"
					If(Empty(aDados[nX, 65])) 
						oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*6) + 0020)*nAC, Transform(nTotGeral, "@E 99,999,999.99"), oFont04)
					Else
						aEval(aDados[nX, 65], {|x| nTotGeral += if(ValType(x) == "N", x, 0) })
						oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*6) + 0020)*nAC, Transform(nTotGeral, "@E 99,999,999.99"), oFont04)
					EndIf
				EndIf
		
				oPrint:Box((nLinIni + 2206)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 2284)*nAL + nLinA4, (nColIni + (nColMax/3) - 0010)*nAC)
				oPrint:Say((nLinIni + 2201 + nLinA4)*nAL, (nColIni + 0020)*nAC, "66 - Assinatura do Responsável pela Autorização", oFont01) //66 - Assinatura do Responsável pela Autorização
				oPrint:Box((nLinIni + 2206)*nAL + nLinA4, (nColIni + (nColMax/3))*nAC, (nLinIni + 2284)*nAL + nLinA4, (nColIni + ((nColMax/3)*2) - 0010)*nAC)
				oPrint:Say((nLinIni + 2201 + nLinA4)*nAL, (nColIni + (nColMax/3) + 0010)*nAC, "67 - Assinatura do Beneficiário ou Responsável", oFont01) //67 - Assinatura do Beneficiário ou Responsável
				oPrint:Box((nLinIni + 2206)*nAL + nLinA4, (nColIni + ((nColMax/3)*2))*nAC, (nLinIni + 2284)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 2201 + nLinA4)*nAL, (nColIni + ((nColMax/3)*2) + 0010)*nAC, "68 - Assinatura do Contratado", oFont01) //68 - Assinatura do Contratado
				
								
				aDados[nX, 59] 	:=0
				aDados[nX, 60]	:=0
				aDados[nX, 61]	:=0
				aDados[nX, 62] 	:=0
				aDados[nX, 63] 	:=0
				aDados[nX, 64] 	:=0
				nTotGeral 			:=0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Finaliza a pagina
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				oPrint:EndPage()
			//Endif
			Endif
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
		oPrint:Preview()
	EndIf

Return(cFileName)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLTISAOPME³ Autor ³ Bruno Iserhardt       ³ Data ³ 03.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3 (Anexo de Solicitacao de Ortese, ³±±
±±³          ³ Proteses e Materiais Especiais)                             ³±±
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
Function PLTISAOPME(aDados, nLayout, cLogoGH,lWeb, cPathRelW,lUnicaImp)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    := 	0
	Local nLinOld	:=	0
	Local nWeb		:=  0
	Local lImpNovo := .T.
	Local cFileLogo
	Local lPrinter := .F.
	Local nAte := 0
	Local nI, nJ, nN, nV
	Local nX, nX1
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local oFont07
	Local cObs
	Local cRel      := "guiopme"
	Local cPathSrvJ := GETMV("MV_RELT")
	Local nTweb		:= 1
	Local nLweb		:= 0
	Local nLwebC	:= 0
	Local oPrint	:= NIL

	Default lUnicaImp := .F.
	Default lWeb    := .F.
	Default cPathRelW := ''
	Default nLayout := 2
	Default cLogoGH := ''
	Default	aDados  := { {;
		"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - N Guia no Prestador
	{"01234567890123456789"},; //3 - Numero da Guia Referenciada
	{"01234567890123456789"},; //4 - Senha
	{CtoD("03/02/14")},; //5 - Data da Autorizacao
	{"01234567890123456789"},; //6 - Numero da Guia Atribuido pela Operadora
	{"01234567890123456789"},; //7 - Numero da Carteira
	{Replicate("M", 70)},; //8 - Nome
	{Replicate("M", 70)},; //9- Nome do Profissional Solicitante
	{"01234567890"},; //10 - Telefone
	{Replicate("M", 60)},; //11 - E-mail
	{Replicate("M", 1000)},; //12 - Justificativa Tecnica
	{{"99", "01","99", "01","99", "01"}},; //13-Tabela
	{{"0123456789", "0123456789","0123456789", "0123456789","0123456789", "0123456789"}},; //14-Codigo do Material
	{{Replicate("M", 150), Replicate("M", 150),Replicate("M", 150), Replicate("M", 150),Replicate("M", 150), Replicate("M", 150)}},; //15-Descricao
	{{"0", "9","0", "9","0", "9"}},; //16-Opcao
	{{123, 999, 123, 999, 123, 999}},; //17-Qtde. Solicitada
	{{123456.78, 999999.99,123456.78, 999999.99,123456.78, 999999.99}},; //18-Valor Unitario Solicitado
	{{123, 999, 123, 999, 123, 999}},; //19-Qtde. Autorizada
	{{123456.78, 999999.99, 123456.78, 999999.99, 123456.78, 999999.99}},; //20-Valor Unitario Autorizado
	{{"012345678901234","012345678901234","012345678901234","012345678901234","012345678901234","012345678901234"}},; //21-Registro ANVISA do Material
	{{Replicate("M", 30), Replicate("9", 30), Replicate("M", 30), Replicate("9", 30), Replicate("M", 30), Replicate("9", 30)}},; //22-Referencia do material no fabricante
	{{Replicate("M", 30), Replicate("9", 30), Replicate("M", 30), Replicate("9", 30), Replicate("9", 30), Replicate("9", 30)}},; //23-N Autorizacao de Funcionamento
	{Replicate("M", 500)},; //24 - Especificacao do Material
	{Replicate("M", 500)},; //25- Observacao / Justificativa
	{CtoD("03/02/14")},; //26 - Data da Solicitacao
	{""},; //27- Assinatura do Profissional Solicitante
	{""},; //28- Assinatura do Responsavel pela Autorizacao
	{""} } } //29- Nome Social

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2275
		nColMax	:=	3270
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
	oFont07		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	if !lWeb
		oPrint	:= TMSPrinter():New("ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E MATERIAIS ESPECIAIS - OPME") //ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E MATERIAIS ESPECIAIS - OPME
	else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
		oPrint:cPathPDF := cPathSrvJ
		nTweb		:= 3.9
		nLweb		:= 10
		nLwebC		:= -3
		nColMax		:= 3100
		nWeb		:= 25
		oPrint:lServer := lWeb
	Endif


	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		oPrint:setDevice(IMP_PDF)
	Else
		// Verifica se existe alguma impressora configurada para Impressao Grafica
		lPrinter := oPrint:IsPrinterActive()
		IF lPrinter
			lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se irá alterar a Impressora Ativa
		ENDIF
		If ! lPrinter
			oPrint:Setup()
		EndIf
	Endif

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf



		For nX1 := 1 To Len(aDados[nX, 02])

			nAte := 6
			nV := 1

		//Esta parte do código faz com que
		//imprima mais de uma guia.
		//INICIO
			If lUnicaImp
				If nX1 <= Len(aDados)
					lImpNovo := .T.
				EndIf
			EndIf
		//FIM

			While lImpNovo

				lImpNovo := .F.

				For nI:= 13 To 23
					If Len(aDados[nX, nI, nX1]) < nAte
						For nJ := Len(aDados[nX, nI, nX1]) + 1 To nAte
							If AllTrim(Str(nI)) $ "17,18,19,20"
								aAdd(aDados[nX, nI, nX1], 0)
							Else
								aAdd(aDados[nX, nI, nX1],"")
							EndIf
						Next nJ
					EndIf
				Next nI

				nLinIni  := 080
				nColIni  := 080
				nColA4   := 000

				oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fLogoEmp(@cFileLogo,, cLogoGH)

				If File(cFilelogo)
					oPrint:SayBitmap((nLinIni + 0040)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, 400/nTweb, 090/nTweb) 		// Tem que estar abaixo do RootPath
				EndIf

				If nLayout == 2 // Papél A4
					nColA4    := -0335
				Elseif nLayout == 3// Carta
					nColA4    := -0530
				Endif

				oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.46)/nTweb, "ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E MATERIAIS ESPECIAIS - OPME
				oPrint:Say((nLinIni + 0120)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "MATERIAIS ESPECIAIS - OPME", oFont02n,,,, 2)
				oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 750)/nTweb, "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
				oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02, nX1], oFont03n)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
				oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 0269 -nWeb)/nTweb, ((nColIni + nColMax)*0.1 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, (nColIni + 0020)/nTweb, "1 - Registro ANS", oFont01) //1 - Registro ANS
				oPrint:Say((nLinIni + 0220)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 01], oFont04)
				oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, ((nColIni + nColMax)*0.1)/nTweb, (nLinIni + 0269 - nWeb)/nTweb, ((nColIni + nColMax)*0.35 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.1 + 0020)/nTweb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.1 + 0030)/nTweb, aDados[nX, 03, nX1], oFont04)
				oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, ((nColIni + nColMax)*0.35)/nTweb, (nLinIni + 0269 - nWeb)/nTweb, ((nColIni + nColMax)*0.6 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.35 + 0020)/nTweb, "4 - Senha", oFont01) //4 - Senha
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.35 + 0030)/nTweb, aDados[nX, 04, nX1], oFont04)
				oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, (nLinIni + 0269 - nWeb)/nTweb, ((nColIni + nColMax)*0.75 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.6 + 0020)/nTweb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.6 + 0030)/nTweb, DToC(aDados[nX, 05, nX1]), oFont04)
				oPrint:Box((nLinIni + 0175 -nWeb)/nTweb, ((nColIni + nColMax)*0.75)/nTweb, (nLinIni + 0269 -nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.75 + 0020)/nTweb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.75 + 0030)/nTweb, aDados[nX, 06, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 0)
				AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Beneficiário", oFont01) //Dados do Prestador
				oPrint:Box((nLinIni + 207 - nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300- nWeb)/nTweb, ((nColIni + nColMax)*0.25 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 07, nX1], oFont04)
				oPrint:Box((nLinIni + 207 - nWeb)/nTweb, ((nColIni + nColMax)*0.25)/nTweb, (nLinIni + 300- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.25 + 0020)/nTweb, "29 - Nome Social", oFont01) //8 - Nome
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.25 + 0030)/nTweb, aDados[nX, 29, nX1], oFont04)


				oPrint:Box((nLinIni + 307 - nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400- nWeb)/nTweb, ((nColIni + nColMax) * 1.00 -0010)/nTweb)
				oPrint:Say((nLinIni + 312)/nTweb, (nColIni + 0020)/nTweb, "8 - Nome", oFont01) //8 - Nome
				oPrint:Say((nLinIni + 352)/nTweb, (nColIni  + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)



				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 230, 80)
				AddTBrush(oPrint,  (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante
				oPrint:Box((nLinIni + 207- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300- nWeb)/nTweb, ((nColIni + nColMax)*0.5 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "9- Nome do Profissional Solicitante", oFont01) //9- Nome do Profissional Solicitante
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 09, nX1], oFont04)
				oPrint:Box((nLinIni + 207- nWeb)/nTweb, ((nColIni + nColMax)*0.5)/nTweb, (nLinIni + 300- nWeb)/nTweb, ((nColIni + nColMax)*0.6 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.5 + 0020)/nTweb, "10 - Telefone", oFont01) //10 - Telefone
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.5 + 0030)/nTweb, aDados[nX, 10, nX1], oFont04)
				oPrint:Box((nLinIni + 207- nWeb)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, (nLinIni + 300- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.6 + 0020)/nTweb, "11 - E-mail", oFont01) //11 - E-mail
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.6 + 0030)/nTweb, aDados[nX, 11, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
				AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados da Cirurgia", oFont01) //Dados da Cirurgia
				oPrint:Box((nLinIni + 209- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 660- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "12 - Justificativa Técnica", oFont01) //12 - Justificativa Técnica

				nLinOld := nLinIni

				For nI := 1 To MlCount(aDados[nX, 12, nX1], 130)
					cObs := MemoLine(aDados[nX, 12, nX1], 130, nI)
					oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont04)
					nLinIni += 40
					If nI == 10
						exit //trunco para nao desconfigurar o relatorio
					Endif
				Next nI

				nLinIni := nLinOld + 400

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
				AddTBrush(oPrint, (nLinIni + 165)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 200)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 168)/nTweb, (nColIni + 0020)/nTweb, "OPME Solicitadas", oFont01) //OPME Solicitadas

				oPrint:Box((nLinIni + 204- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 680- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0040)/nTweb, "13-Tabela", oFont01) //13-Tabela
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.07)/nTweb, "14-Código do Material", oFont01) //14-Código do Material
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, "15-Descrição", oFont01) //15-Descrição
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.46)/nTweb, "16-Opção", oFont01) //16-Opção
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.54)/nTweb, "17- Qtde. Sol.", oFont01,,,,1) //17- Qtde. Solicitada
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.63)/nTweb, "18- Valor Unitário Solicitado", oFont01,,,,1) //18- Valor Unitário Solicitado
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.72)/nTweb, "19- Qtde. Aut.", oFont01,,,,1) //19- Qtde. Autorizada
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.80)/nTweb, "20- Valor Unitário Autorizado", oFont01,,,,1) //20- Valor Unitário Autorizado

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20, 60)
				oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0040)/nTweb, "21-Registro ANVISA do Material", oFont01) //21-Registro ANVISA do Material
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, "22-Referência do material no fabricante", oFont01) //22-Referência do material no fabricante
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.85)/nTweb, "23-Nº Autorização de Funcionamento", oFont01) //23-Nº Autorização de Funcionamento

				For nN := nV To nAte
					if !Empty(aDados[nX, 14, nX1, nN])
					oPrint:Say((nLinIni + 270)/nTweb, (nColIni + 0015)/nTweb, AllTrim(Str(nN)) + " - ", oFont01)
					oPrint:Say((nLinIni + 270)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 13, nX1, nN], oFont07)
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.07)/nTweb, aDados[nX, 14, nX1, nN], oFont07)
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, aDados[nX, 15, nX1, nN], oFont07) // Descricao
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.46)/nTweb, aDados[nX, 16, nX1, nN], oFont07) // Opcao
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.54)/nTweb, Alltrim(IIf(Empty(aDados[nX, 17, nX1, nN]), "", Transform(aDados[nX, 17, nX1, nN], "@E 9999.99"))), oFont07,,,,1)
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.63)/nTweb, Alltrim(IIf(Empty(aDados[nX, 18, nX1, nN]), "", Transform(aDados[nX, 18, nX1, nN], "@E 999,999,999.99"))), oFont07,,,,1)
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.72)/nTweb, Alltrim(getException(aDados[nX, 17, nX1, nN],aDados[nX, 19, nX1, nN],"@E 9999.99")), oFont07,,,,1)
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.80)/nTweb, Alltrim(getException(aDados[nX, 18, nX1, nN],aDados[nX, 20, nX1, nN],"@E 999,999,999.99")), oFont07,,,,1)
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 60)

					oPrint:Say((nLinIni + 270)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 21, nX1, nN], oFont07)
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, aDados[nX, 22, nX1, nN], oFont07)
					oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.85)/nTweb, aDados[nX, 23, nX1, nN], oFont07)
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 35, 60)
					Endif
				Next

				If nAte < Len(aDados[nX, 13, nX1])
					lImpNovo := .T.
					nAte += 6
					nV := nN
				EndIf

				nLinIni := 1530

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 120, 80)
				oPrint:Box((nLinIni + 178- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 370- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 183)/nTweb, (nColIni + 0020)/nTweb, "24 - Especificação do Material", oFont01) //24 - Especificação do Material

				nLinOld := nLinIni

				For nI := 1 To MlCount(aDados[nX, 24, nX1], 130)
					cObs := MemoLine(aDados[nX, 24, nX1], 130, nI)
					oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont04)
					nLinIni += 40
					If nI == 4
						exit //trunco para nao desconfigurar o relatorio
					Endif
				Next nI

				nLinIni := nLinOld + 160

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
				AddTBrush(oPrint, (nLinIni + 178)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 370)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Box((nLinIni + 178- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 370- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 183)/nTweb, (nColIni + 0020)/nTweb, "25- Observação / Justificativa", oFont01) //25- Observação / Justificativa

				nLinOld := nLinIni

				For nI := 1 To MlCount(aDados[nX, 25, nX1], 130)
					cObs := MemoLine(aDados[nX, 25, nX1], 130, nI)
					oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont04)
					nLinIni += 40
					If nI == 4
						exit //trunco para nao desconfigurar o relatorio
					Endif
				Next nI

				nLinIni := nLinOld + 160

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
				oPrint:Box((nLinIni + 178- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 272- nWeb)/nTweb, ((nColIni + nColMax)*0.15 - 0010)/nTweb)
				oPrint:Say((nLinIni + 183)/nTweb, (nColIni + 0020)/nTweb, "26 - Data da Solicitação", oFont01) //26 - Data da Solicitação
				oPrint:Say((nLinIni + 223)/nTweb, (nColIni + 0030 + 0030)/nTweb, DtoC(aDados[nX, 26, nX1]), oFont04)
				oPrint:Box((nLinIni + 178- nWeb)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 272- nWeb)/nTweb, ((nColIni + nColMax)*0.55 - 0010)/nTweb)
				oPrint:Say((nLinIni + 183)/nTweb, ((nColIni + nColMax)*0.15 + 0020)/nTweb, "27- Assinatura do Profissional Solicitante", oFont01) //27- Assinatura do Profissional Solicitante
				oPrint:Box((nLinIni + 178- nWeb)/nTweb, ((nColIni + nColMax)*0.55)/nTweb, (nLinIni + 272- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 183)/nTweb, ((nColIni + nColMax)*0.55 + 0020)/nTweb, "28- Assinatura do Responsável pela Autorização", oFont01) //28- Assinatura do Responsável pela Autorização

				oPrint:EndPage()	// Finaliza a pagina

			EndDo

		Next nX1


	Next nX

	If lWeb
		oPrint:Print()
	Else
		oPrint:Preview()
	Endif

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLTISAQUIM³ Autor ³ Bruno Iserhardt       ³ Data ³ 05.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3 (Anexo de Solicitacao de         ³±±
±±³          ³ Quimioterapia)                                               ³±±
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
Function PLTISAQUIM(aDados, nLayout, cLogoGH,lWeb, cPathRelW,lUnicaImp)
	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nOldLin	:=	0
	Local nColA4    := 	0
	Local nWeb		:= 0
	Local cFileLogo
	Local lImpNovo := .T.
	Local lPrinter := .F.
	Local nI, nJ, nN, nV
	Local nX, nX1
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local cObs
	Local cRel      := "guiaquim"
	Local cPathSrvJ := GETMV("MV_RELT")
	Local nTweb		:= 1
	Local nLweb		:= 0
	Local nLwebC	:= 0
	Local oPrint	:= NIL

	Default lUnicaImp := .F.
	Default lWeb    := .F.
	Default cPathRelW := ''
	Default nLayout := 2
	Default cLogoGH := ''
	Default	aDados  := { {;
		"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - N Guia no Prestador
	{"01234567890123456789"},; //3 - Numero da Guia Referenciada
	{"01234567890123456789"},; //4 - Senha
	{CtoD("03/02/14")},; //5 - Data da Autorizacao
	{"01234567890123456789"},; //6 - Numero da Guia Atribuido pela Operadora
	{"01234567890123456789"},; //7 - Número da Carteira
	{Replicate("M", 70)},; //8 - Nome
	{999.99},; //9 - Peso (Kg)
	{999.99},; //10 - Altura (Cm)
	{99.99},; //11 - Superfície Corporal (m²)
	{999},; //12 - Idade
	{"M"},; //13 - Sexo
	{Replicate("M", 70)},; //14 - Nome do Profissional Solicitante
	{"01234567890"},; //15 - Telefone
	{Replicate("M", 60)},; //16 - E-mail
	{CtoD("05/02/2014")},; //17 - Data do diagnóstico
	{"9999"},; //18 - CID 10 Principal
	{"9999"},; //19 - CID 10 (2)
	{"9999"},; //20 - CID 10 (3)
	{"9999"},; //21 - CID 10 (4)
	{"1"},; //22 - Estadiamento
	{"1"},; //23 - Tipo de Quimioterapia
	{"1"},; //24 - Finalidade
	{"1"},; //25 - ECOG
	{"1"},; //26 - TUMOR
	{"1"},; //27 - NODULO
	{"1"},; //28 - METASTASE
	{Replicate("M", 1000)},; //29 - PlanoTerapêutico
	{Replicate("M", 1000)},; //30 - Diagnóstico Cito/Histopatológico
	{Replicate("M", 1000)},; //31 - Informações relevantes
	{{CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014")}},; //32-Data Prevista para Administração
	{{"99","99","99","99","99","99","99","99"}},; //33-Tabela
	{{"0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789"}},; //34-Código do Medicamento
	{{Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150)}},; //35-Descrição
	{{99999.99, 99999.99, 99999.99, 99999.99, 99999.99, 99999.99, 11111.11, 22222.22}},; //36-Doses
	{{"999", "999", "999", "999", "999", "999", "999", "999"}},; //37-Unidade de medida
	{{"99", "99", "99", "99", "99", "99", "99", "99"}},; //38-Via Adm
	{{99, 99, 99, 99, 99, 99, 11, 22}},; //39-Frequência
	{Replicate("M", 40)},; //40- Cirurgia
	{CtoD("05/02/2014")},; //41 - Data da Realização
	{Replicate("M", 40)},; //42 - Área Irradiada
	{CtoD("05/02/2014")},; //43 - Data da Aplicação
	{Replicate("M", 500)},; //44 - Observação
	{99},; //45 - Número de Ciclos Previstos
	{99},; //46 - Ciclo Atual
	{99},; //47 - Dias Ciclo Atual
	{999},; //48-Intervalo entre Ciclos ( em dias)
	{CtoD("05/02/2014")},; //49 - Data da Solicitação
	{""},; //50-Assinatura do Profissional Solicitante
	{""},; //51-Assinatura do Responsável pela Autorização
	{""} } } //52-Mome Social

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2275
		nColMax	:=	3270
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	if lWeb
		oFont01		:= TFont():New("Arial",  4,  4, , .F., , , , .T., .F.) // Normal
	else
		oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
	End if
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
		oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Nao permite acionar a impressao quando for na web.
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	if !lWeb
		oPrint	:= TMSPrinter():New("ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA") //ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA
		nWeb	:= 0
	else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
		oPrint:cPathPDF := cPathSrvJ
		nTweb		:= 3.9
		nLweb		:= 10
		nLwebC		:= -3
		nColMax		:= 3100
		nWeb		:= 25
		oPrint:lServer := lWeb
	Endif


	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Device
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		oPrint:setDevice(IMP_PDF)
	Else
			// Verifica se existe alguma impressora configurada para Impressao Grafica
		lPrinter := oPrint:IsPrinterActive()
		IF lPrinter
			lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se irá alterar a Impressora Ativa
		ENDIF
		If ! lPrinter
			oPrint:Setup()
		EndIf
	Endif

	if( ! isInCallStack( "PLIMPGUIB" ) )
		For nX := 1 To Len(aDados)

			If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
				Loop
			EndIf

			For nX1 := 1 To Len(aDados[nX, 02])

				nAte := 8
				nV := 1

				//Esta parte do código faz com que
				//imprima mais de uma guia.
				//INICIO
				If lUnicaImp
					If nX1 <= Len(aDados)
						lImpNovo := .T.
					EndIf
				EndIf
				//FIM

				While lImpNovo

					lImpNovo := .F.

					For nI:= 32 To 39
						If Len(aDados[nX, nI, nX1]) < nAte
							For nJ := Len(aDados[nX, nI, nX1]) + 1 To nAte
								If AllTrim(Str(nI)) $ "36,39"
									aAdd(aDados[nX, nI, nX1], 0)
								ElseIf AllTrim(Str(nI)) $ "32"
									aAdd(aDados[nX, nI, nX1], CtoD(""))
								Else
									aAdd(aDados[nX, nI, nX1],"")
								EndIf
							Next nJ
						EndIf
					Next nI

					nLinIni  := 080
					nColIni  := 080
					nColA4   := 000

					oPrint:StartPage()		// Inicia uma nova pagina
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Box Principal                                                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oPrint:Box((nLinIni + 0000)/nTWeb, (nColIni + 0000)/nTWeb, (nLinIni + nLinMax)/nTWeb, (nColIni + nColMax)/nTWeb)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Carrega e Imprime Logotipo da Empresa                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					fLogoEmp(@cFileLogo,, cLogoGH)

					If File(cFilelogo)
						oPrint:SayBitmap((nLinIni + 0040)/nTWeb, (nColIni + 0020)/nTWeb, cFileLogo, (400)/nTWeb, (090)/nTWeb) 		// Tem que estar abaixo do RootPath
					EndIf

					If nLayout == 2 // Papél A4
						nColA4    := -0335
					Elseif nLayout == 3		// Carta
						nColA4    := -0530
					Endif

					nLinIni += 70

					oPrint:Say((nLinIni + 0010)/nTWeb, ((nColIni + nColMax)*0.47)/nTWeb, "ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA
					oPrint:Say((nLinIni + 0030)/nTWeb, (nColMax - 750)/nTWeb, "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
					oPrint:Say((nLinIni + 0020)/nTWeb, (nColMax - 480)/nTWeb, aDados[nX, 02, nX1], oFont03n)

						//fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
					nLinIni -= 80
					oPrint:Box((nLinIni + 0175 -nWeb)/nTWeb,( nColIni + 0010)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.1 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( nColIni + 0020)/nTWeb, "1 - Registro ANS", oFont01) //1 - Registro ANS
					oPrint:Say((nLinIni + 0220)/nTWeb,( nColIni + 0030)/nTWeb, aDados[nX, 01], oFont04)
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.1)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.35 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.1 + 0020)/nTWeb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
					oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.1 + 0030)/nTWeb, aDados[nX, 03, nX1], oFont04)
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.35)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.6 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.35 + 0020)/nTWeb, "4 - Senha", oFont01) //4 - Senha
					oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.35 + 0030)/nTWeb, aDados[nX, 04, nX1], oFont04)
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.6)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.75 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.6 + 0020)/nTWeb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
					oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.6 + 0030)/nTWeb, DToC(aDados[nX, 05, nX1]), oFont04)
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.75)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.75 + 0020)/nTWeb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
					oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.75 + 0030)/nTWeb, aDados[nX, 06, nX1], oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
					AddTBrush(oPrint, (nLinIni + 175)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 206)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Beneficiário", oFont01) //Dados do Prestador
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.25 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
					oPrint:Say((nLinIni + 252)/nTWeb, (nColIni + 0030)/nTWeb, aDados[nX, 07, nX1], oFont04)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.25)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.25 + 0020)/nTWeb, "52 - Nome Social", oFont01) //52 - Nome social
					oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.25 + 0030)/nTWeb, aDados[nX, 52, nX1], oFont04)



					oPrint:Box((nLinIni + 307 - nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400- nWeb)/nTweb, ((nColIni + nColMax) * 1.00 -0010)/nTweb)
					oPrint:Say((nLinIni + 312)/nTweb, (nColIni + 0020)/nTweb, "8 - Nome", oFont01) //8 - Nome
					oPrint:Say((nLinIni + 352)/nTweb, (nColIni  + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)


					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 230, 80)

					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.1 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, (nColIni + 0020)/nTWeb, "9 - Peso (Kg)", oFont01) //9 - Peso (Kg)
					oPrint:Say((nLinIni + 223)/nTWeb, (nColIni + 0030)/nTWeb, IIf(aDados[nX, 09, nX1]>0,Transform(aDados[nX, 09, nX1], "@E 999.99"),""), oFont04)
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.1)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.2 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.1 + 0020)/nTWeb, "10 - Altura (Cm)", oFont01) //10 - Altura (Cm)
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.1 + 0030)/nTWeb, IIf(aDados[nX, 10, nX1]>0,Transform(aDados[nX, 10, nX1], "@E 999.99"),""), oFont04)
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.2 + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.33 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.2 + 0020)/nTWeb, "11 - Superfície Corporal (m²)", oFont01) //11 - Superfície Corporal (m²)
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.2 + 0030)/nTWeb, IIf(aDados[nX, 11, nX1]>0,Transform(aDados[nX, 11, nX1], "@E 99.99"),""), oFont04)
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.33 + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.4 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.33 + 0020)/nTWeb, "12 - Idade", oFont01) //12 - Idade
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.33 + 0030)/nTWeb, IIf(aDados[nX, 12, nX1]>0,Transform(aDados[nX, 12, nX1], "@E 999"),""), oFont04)
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.4 + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.4 + 0020)/nTWeb, "13 - Sexo", oFont01) //13 - Sexo
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.4 + 0030)/nTWeb, aDados[nX, 13, nX1], oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
					AddTBrush(oPrint,  (nLinIni + 174)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 205)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "14 - Nome do Profissional Solicitante", oFont01) //14 - Nome do Profissional Solicitante
					oPrint:Say((nLinIni + 252)/nTWeb, (nColIni + 0030)/nTWeb, aDados[nX, 14, nX1], oFont04)
					oPrint:Box((nLinIni + 209-nWeb)/nTWeb, ((nColIni + nColMax)*0.5)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.6 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.5 + 0020)/nTWeb, "15 - Telefone", oFont01) //15 - Telefone
					oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.5 + 0030)/nTWeb, aDados[nX, 15, nX1], oFont04)
					oPrint:Box((nLinIni + 210-nWeb)/nTWeb, ((nColIni + nColMax)*0.6)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.6 + 0020)/nTWeb, "16 - E-mail", oFont01) //16 - E-mail
					oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.6 + 0030)/nTWeb, aDados[nX, 16, nX1], oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 80)
					AddTBrush(oPrint, (nLinIni + 174)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 205)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Diagnóstico Oncológico", oFont01) //Diagnóstico Oncológico
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.12 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "17 - Data do diagnóstico", oFont01) //17 - Data do diagnóstico
					oPrint:Say((nLinIni + 252)/nTWeb, (nColIni + 0030)/nTWeb, DtoC(aDados[nX, 17, nX1]), oFont04)
					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.12)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.2 - 0010)/nTWeb)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.12)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.2 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.12 + 0020)/nTWeb, "18 - CID 10 Principal (opcional)", oFont01) //18 - CID 10 Principal
					oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.12 + 0030)/nTWeb, aDados[nX, 18, nX1], oFont04)

					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.2)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.26 - 0010)/nTWeb)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.2)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.26 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.2 + 0020)/nTWeb, "19 - CID 10 (2)(opcional)", oFont01) //19 - CID 10 (2)
					oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.2 + 0030)/nTWeb, aDados[nX, 19, nX1], oFont04)

					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.26)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.32 - 0010)/nTWeb)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.26)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.32 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.26 + 0020)/nTWeb, "20 - CID 10 (3)(opcional)", oFont01) //20 - CID 10 (3)
					oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.26 + 0030)/nTWeb, aDados[nX, 20, nX1], oFont04)

					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.32)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.38 - 0010)/nTWeb)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.32)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.38 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.32 + 0020)/nTWeb, "21 - CID 10 (4)(opcional)", oFont01) //21 - CID 10 (4)
					oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.32 + 0030)/nTWeb, aDados[nX, 21, nX1], oFont04)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.38)/nTWeb, (nLinIni + 400-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.38 + 0020)/nTWeb, "29 - Plano Terapêutico", oFont01) //29 - PlanoTerapêutico

					nOldLin := nLinIni

					For nI := 1 To MlCount(aDados[nX, 29, nX1], If(!lWeb,180,120))
						cObs := MemoLine(aDados[nX, 29, nX1], If(!lWeb,180,120), nI)
						oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.38 + 0020)/nTWeb, cObs, oFont01)
						nLinIni += 30
						If nI == 5
							exit //trunco para nao desconfigurar o relatorio
						Endif
					Next nI

					nLinIni := nOldLin

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.08 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, (nColIni + 0020)/nTWeb, "22 - Estadiamento", oFont01) //22 - Estadiamento
					oPrint:Say((nLinIni + 223)/nTWeb, (nColIni + 0030)/nTWeb, aDados[nX, 22, nX1], oFont04)

					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.082)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.082 + 0020)/nTWeb, "23 - Tipo de Quimioterapia", oFont01) //23 - Tipo de Quimioterapia
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.082 + 0030)/nTWeb, aDados[nX, 23, nX1], oFont04)

					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 + 2 )/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.20 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.15 + 0022)/nTWeb, "24 - Finalidade", oFont01) //24 - Finalidade
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.15 + 0032)/nTWeb, aDados[nX, 24, nX1], oFont04)

					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.2)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.24 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.2 + 0020)/nTWeb, "25 - ECOG", oFont01) //25 - ECOG
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.2 + 0030)/nTWeb, aDados[nX, 25, nX1], oFont04)

					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.24)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.28 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.24 + 0020)/nTWeb, "26 - TUMOR", oFont01) //26 - TUMOR
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.24 + 0030)/nTWeb, aDados[nX, 26, nX1], oFont04)

					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.28)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.32 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.28 + 0020)/nTWeb, "27 - NÓDULO", oFont01) //27 - NÓDULO
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.28 + 0030)/nTWeb, aDados[nX, 27, nX1], oFont04)

					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.32)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.38 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.32 + 0020)/nTWeb, "28 - Metástase", oFont01) //28 - Metástase
					oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.32 + 0030)/nTWeb, aDados[nX, 28, nX1], oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 300, 80)
					oPrint:Box((nLinIni + 28-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 500-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni +33)/nTWeb, (nColIni + 0020)/nTWeb, "30 - Diagnóstico Cito/Histopatológico", oFont01) //30 - Diagnóstico Cito/Histopatológico
					oPrint:Box((nLinIni + 28-nWeb)/nTWeb, ((nColIni + nColMax)*0.5)/nTWeb, (nLinIni + 500-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 33)/nTWeb, ((nColIni + nColMax)*0.5 + 0020)/nTWeb, "31 - Informações relevantes", oFont01) //31 - Informações relevantes

					nOldLin := nLinIni

					For nI := 1 To MlCount(aDados[nX, 30, nX1], If(!lWeb,120,90))
						cObs := MemoLine(aDados[nX, 30, nX1], If(!lWeb,120,90), nI)
						oPrint:Say((nLinIni + 80)/nTWeb, (nColIni + 0020)/nTWeb, cObs, oFont01)
						nLinIni += 30
					Next nI

					nLinIni := nOldLin

					For nI := 1 To MlCount(aDados[nX, 31, nX1], If(!lWeb,120,90))
						cObs := MemoLine(aDados[nX, 31, nX1], If(!lWeb,120,90), nI)
						oPrint:Say((nLinIni + 80)/nTWeb, ((nColIni + nColMax)*0.5 + 0030)/nTWeb, cObs, oFont01)
						nLinIni += 30
					Next nI

					nLinIni := nOldLin
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 500, 80)
					nOldLin := nLinIni

					AddTBrush(oPrint,  (nLinIni + 97)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 230)/nTWeb, ((nColIni + nColMax)*0.8 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 50)/nTWeb, (nColIni + 0020)/nTWeb, "Medicamentos e Drogas solicitadas", oFont01) //Medicamentos e Drogas solicitadas

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 570-nWeb)/nTWeb, ((nColIni + nColMax)*0.8 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 60)/nTWeb, (nColIni + 0040)/nTWeb, "32-Data Prevista para Administração", oFont01) //32-Data Prevista para Administração
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.16)/nTWeb, "33-Tabela", oFont01) //33-Tabela
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.20)/nTWeb, "34-Código do Medicamento", oFont01) //34-Código do Medicamento
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.29)/nTWeb, "35-Descrição", oFont01) //35-Descrição
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.53)/nTWeb, "36-Dosagem total no ciclo", oFont01,,,,1) //36-Dosagem total no ciclo
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.61 + 0020)/nTWeb, "37-Unidade de medida", oFont01,,,,1) //37-Unidade de medida
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.69 + 0020)/nTWeb, "38-Via Adm", oFont01) //38-Via Adm
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.75 - 0020)/nTWeb + IIF(lWeb,0,100), "39-Frequência", oFont01,,,,1) //39-Frequência

					For nN := nV To nAte

						oPrint:Say((nLinIni + 100)/nTWeb, (nColIni + 0012)/nTWeb, AllTrim(Str(nN)) + " - ", oFont01)

						oPrint:Say((nLinIni + 100)/nTWeb, (nColIni + 0040)/nTWeb, DtoC(aDados[nX, 32, nX1, nN]), oFont04)
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.16)/nTWeb, aDados[nX, 33, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.20)/nTWeb, aDados[nX, 34, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.29)/nTWeb, aDados[nX, 35, nX1, nN], oFont01)
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.53)/nTWeb, getException(Iif(!Empty(aDados[nX, 33, nX1, nN]),1,0),aDados[nX, 36, nX1, nN],"@E 99999.99"), oFont04,,,,1)
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.61 + 0020)/nTWeb, aDados[nX, 37, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.69 + 0020)/nTWeb, aDados[nX, 38, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.75 - 0020)/nTWeb + IIF(lWeb,0,100), IIf(Empty(aDados[nX, 39, nX1, nN]), "", Transform(aDados[nX, 39, nX1, nN], "@E 99")), oFont04,,,,1)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
					Next

					If nAte < Len(aDados[nX, 32, nX1])
						lImpNovo := .T.
						nAte += 8
						nV := nN
					EndIf

					nLinIni := nOldLin

					AddTBrush(oPrint,  (nLinIni + 97)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 50)/nTWeb, ((nColIni + nColMax)*0.8 + 0010)/nTWeb, "Tratamentos Anteriores", oFont01) //Tratamentos Anteriores

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "40 - Cirurgia", oFont01) //40- Cirurgia

					nLinZZ := nLinIni

					For nI := 1 To MlCount(aDados[nX, 40, nX1], 30)
						cObs := MemoLine(aDados[nX, 40, nX1], 30, nI)
						oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, cObs, oFont04)
						nLinIni += 30
						If nI == 5
							exit // trunco para nao desconfigurar o relatorio
						Endif
					Next nI

					nLinIni := nLinZZ + 150

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 130-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "41 - Data da Realização", oFont01) //41 - Data da Realização
					oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, DtoC(aDados[nX, 41, nX1]), oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "42 - Área Irradiada", oFont01) //42 - Área Irradiada

					nLinZZ := nLinIni

					For nI := 1 To MlCount(aDados[nX, 42, nX1], 30)
						cObs := MemoLine(aDados[nX, 42, nX1], 30, nI)
						oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, cObs, oFont04)
						nLinIni += 30
						If nI == 5
							exit // trunco para nao desconfigurar o relatorio
						Endif
					Next nI

					nLinIni := nLinZZ + 150

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 130-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "43 - Data da Aplicação", oFont01) //43 - Data da Aplicação
					oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, DtoC(aDados[nX, 43, nX1]), oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
					AddTBrush(oPrint, (nLinIni + 54)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 400)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Box((nLinIni + 50 -nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 200-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 50)/nTWeb, (nColIni + 0020)/nTWeb, "44 - Observação / Justificativa", oFont01) //38 - Área Irradiada

					nLinZZ := nLinIni

					For nI := 1 To MlCount(aDados[nX, 44, nX1], If(!lWeb,155,120))
						cObs := MemoLine(aDados[nX, 44, nX1], If(!lWeb,155,120), nI)
						oPrint:Say((nLinIni + 70)/nTWeb, (nColIni + 0030)/nTWeb, cObs, oFont04)
						nLinIni += 30
						If nI == 4
							exit
						Endif
					Next nI

					nLinIni := 1980

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.12 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, (nColIni + 0020)/nTWeb, "45- Número de Ciclos", oFont01) //45- Número de Ciclos
					oPrint:Say((nLinIni + 229)/nTWeb, (nColIni + 0020)/nTWeb, "Previstos", oFont01) //Previstos
					oPrint:Say((nLinIni + 254)/nTWeb, (nColIni + 0030)/nTWeb, IIf(Empty(aDados[nX, 45, nX1]), "", Transform(aDados[nX, 45, nX1], "@E 99")), oFont04)
					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.12)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.18 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.12 + 0020)/nTWeb, "46 - Ciclo Atual", oFont01) //46 - Ciclo Atual
					oPrint:Say((nLinIni + 254)/nTWeb, ((nColIni + nColMax)*0.12 + 0030)/nTWeb, IIf(Empty(aDados[nX, 46, nX1]), "", Transform(aDados[nX, 46, nX1], "@E 99")), oFont04)

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.18)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.23 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.18 + 0020)/nTWeb, "47-Nº de dias do", oFont01) //45- Número de Ciclos
					oPrint:Say((nLinIni + 229)/nTWeb, ((nColIni + nColMax)*0.18 + 0020)/nTWeb, "Ciclo Atual", oFont01) //Previstos
					oPrint:Say((nLinIni + 254)/nTWeb, ((nColIni + nColMax)*0.18 + 0030)/nTWeb,IIf(Len(aDados[nX, 47])>0,IIf(Empty(aDados[nX, 47, nX1]), "", Transform(aDados[nX, 47, nX1], "@E 99")),"" ), oFont04)

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.23)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.28 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "48-Intervalo entre", oFont01) //48-Intervalo entre
					oPrint:Say((nLinIni + 229)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "Ciclos ( em dias)", oFont01) //Ciclos ( em dias)
					oPrint:Say((nLinIni + 254)/nTWeb, ((nColIni + nColMax)*0.23 + 0030)/nTWeb, IIf(Empty(aDados[nX, 48, nX1]), "", Transform(aDados[nX, 48, nX1], "@E 999")), oFont04)

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.28)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.38 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.28 + 0020)/nTWeb, "49 - Data da Solicitação", oFont01) //49 - Data da Solicitação
					oPrint:Say((nLinIni + 254)/nTWeb, ((nColIni + nColMax)*0.28 + 0030)/nTWeb, DtoC(aDados[nX, 49, nX1]), oFont04)

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.38)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.71 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.38 + 0020)/nTWeb, "50-Assinatura do Profissional Solicitante", oFont01) //50-Assinatura do Profissional Solicitante

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.71)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.71 + 0020)/nTWeb, "51-Assinatura do Responsável pela Autorização", oFont01) //51-Assinatura do Responsável pela Autorização


					oPrint:EndPage()	// Finaliza a pagina

				EndDo

			Next

			oPrint:EndPage()	// Finaliza a pagina

		Next

	else
		For nX := 1 To Len(aDados)

			If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
				Loop
			EndIf

			For nX1 := 1 To Len(aDados[nX, 02])

				nAte := 8
				nV := 1

				//Esta parte do código faz com que
				//imprima mais de uma guia.
				//INICIO
				If lUnicaImp
					If nX1 <= Len(aDados)
						lImpNovo := .T.
					EndIf
				EndIf
				//FIM

				While lImpNovo

					lImpNovo := .F.

					For nI:= 32 To 39
						If Len(aDados[nX, nI, nX1]) < nAte
							For nJ := Len(aDados[nX, nI, nX1]) + 1 To nAte
								If AllTrim(Str(nI)) $ "36,39"
									aAdd(aDados[nX, nI, nX1], 0)
								ElseIf AllTrim(Str(nI)) $ "32"
									aAdd(aDados[nX, nI, nX1], CtoD(""))
								Else
									aAdd(aDados[nX, nI, nX1],"")
								EndIf
							Next nJ
						EndIf
					Next nI

					nLinIni  := 080
					nColIni  := 080
					nColA4   := 000

					oPrint:StartPage()		// Inicia uma nova pagina
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Box Principal                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oPrint:Box((nLinIni + 0000)/nTWeb, (nColIni + 0000)/nTWeb, (nLinIni + nLinMax)/nTWeb, (nColIni + nColMax)/nTWeb)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrega e Imprime Logotipo da Empresa                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					fLogoEmp(@cFileLogo,, cLogoGH)

					If File(cFilelogo)
						oPrint:SayBitmap((nLinIni + 0040)/nTWeb, (nColIni + 0020)/nTWeb, cFileLogo, (400)/nTWeb, (090)/nTWeb) 		// Tem que estar abaixo do RootPath
					EndIf

					If nLayout == 2 // Papél A4
						nColA4    := -0335
					Elseif nLayout == 3// Carta
						nColA4    := -0530
					Endif

					nLinIni += 70

					//ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA
					oPrint:Say((nLinIni + 0010)/nTWeb, ((nColIni + nColMax)*0.47)/nTWeb, "ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA
					oPrint:Say((nLinIni + 0030)/nTWeb, (nColMax - 750)/nTWeb, "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
					oPrint:Say((nLinIni + 0020)/nTWeb, (nColMax - 480)/nTWeb, aDados[nX, 02, nX1], oFont03n)

					//1 - Registro ANS
					nLinIni -= 80
					oPrint:Box((nLinIni + 0175 -nWeb)/nTWeb,( nColIni + 0010)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.08 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( nColIni + 0020)/nTWeb, "1 - Registro ANS", oFont01) //1 - Registro ANS
					oPrint:Say((nLinIni + 0230)/nTWeb,( nColIni + 0030)/nTWeb, aDados[nX, 01], oFont04)

					//3 - Número da Guia Referenciada
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.08)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.34 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.08 + 0020)/nTWeb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
					oPrint:Say((nLinIni + 0230)/nTWeb,( (nColIni + nColMax)*0.08 + 0020)/nTWeb, replicate( "|__",20 ) + "|", oFont04)

					//4 - Senha
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.34)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.6 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.34 + 0020)/nTWeb, "4 - Senha", oFont01) //4 - Senha
					oPrint:Say((nLinIni + 0230)/nTWeb,( (nColIni + nColMax)*0.34 + 0020)/nTWeb, replicate( "|__",20 ) + "|", oFont04)

					//5 - Data da Autorização
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.6)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.73 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.6 + 0020)/nTWeb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
					oPrint:Say((nLinIni + 0230)/nTWeb,( (nColIni + nColMax)*0.6 + 0030)/nTWeb, "|__|__|/|__|__|/|__|__|__|__|", oFont04)

					//6 - Número da Guia Atribuído pela Operadora
					oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.73)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.73 + 0020)/nTWeb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
					oPrint:Say((nLinIni + 0230)/nTWeb,( (nColIni + nColMax)*0.73 + 0030)/nTWeb, replicate( "|__",20 ) + "|", oFont04)

					//Dados do Beneficiário - linha divisoria
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
					AddTBrush(oPrint, (nLinIni + 175)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 206)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Beneficiário", oFont01) //Dados do Prestador

					//7 - Número da Carteira
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.30 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
					oPrint:Say((nLinIni + 262)/nTWeb, (nColIni + 0030)/nTWeb, replicate( "|__",20 ) + "|", oFont04)

					//8 - Nome
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.30)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.30 + 0020)/nTWeb, "8 - Nome", oFont01) //8 - Nome

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)

					//9 - Peso (Kg)
					oPrint:Box((nLinIni + 188-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 282-nWeb)/nTWeb, ((nColIni + nColMax)*0.11 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 193)/nTWeb, (nColIni + 0020)/nTWeb, "9 - Peso (Kg)", oFont01) //9 - Peso (Kg)
					oPrint:Say((nLinIni + 243)/nTWeb, (nColIni + 0030)/nTWeb, "|__|__|__|,|__|__|", oFont04)

					//10 - Altura (Cm)
					oPrint:Box((nLinIni + 188-nWeb)/nTWeb, ((nColIni + nColMax)*0.11)/nTWeb, (nLinIni + 282-nWeb)/nTWeb, ((nColIni + nColMax)*0.20 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 193)/nTWeb, ((nColIni + nColMax)*0.11 + 0020)/nTWeb, "10 - Altura (Cm)", oFont01) //10 - Altura (Cm)
					oPrint:Say((nLinIni + 243)/nTWeb, ((nColIni + nColMax)*0.11 + 0030)/nTWeb, "|__|__|__|,|__|__|", oFont04)

					//11 - Superfície Corporal (m²)
					oPrint:Box((nLinIni + 188-nWeb)/nTWeb, ((nColIni + nColMax)*0.20)/nTWeb, (nLinIni + 282-nWeb)/nTWeb, ((nColIni + nColMax)*0.30 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 193)/nTWeb, ((nColIni + nColMax)*0.20 + 0020)/nTWeb, "11 - Superfície Corporal (m²)", oFont01) //11 - Superfície Corporal (m²)
					oPrint:Say((nLinIni + 243)/nTWeb, ((nColIni + nColMax)*0.20 + 0030)/nTWeb, "|__|__|,|__|__|", oFont04)

					//12 - Idade
					oPrint:Box((nLinIni + 188-nWeb)/nTWeb, ((nColIni + nColMax)*0.30)/nTWeb, (nLinIni + 282-nWeb)/nTWeb, ((nColIni + nColMax)*0.4 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 193)/nTWeb, ((nColIni + nColMax)*0.30 + 0020)/nTWeb, "12 - Idade", oFont01) //12 - Idade
					oPrint:Say((nLinIni + 243)/nTWeb, ((nColIni + nColMax)*0.30 + 0030)/nTWeb, replicate( "|__",3 ) + "|", oFont04)

					//13 - Sexo
					oPrint:Box((nLinIni + 188-nWeb)/nTWeb, ((nColIni + nColMax)*0.4)/nTWeb, (nLinIni + 282-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 193)/nTWeb, ((nColIni + nColMax)*0.4 + 0020)/nTWeb, "13 - Sexo", oFont01) //13 - Sexo
					oPrint:Say((nLinIni + 243)/nTWeb, ((nColIni + nColMax)*0.4 + 0030)/nTWeb, "|__|", oFont04)

					//Dados do Profissional Solicitante - linha divisoria
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
					AddTBrush(oPrint,  (nLinIni + 174)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 205)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante

					//14 - Nome do Profissional Solicitante
					oPrint:Box((nLinIni + 209-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "14 - Nome do Profissional Solicitante", oFont01) //14 - Nome do Profissional Solicitante

					//15 - Telefone
					oPrint:Box((nLinIni + 209-nWeb)/nTWeb, ((nColIni + nColMax)*0.5)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.65 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.5 + 0020)/nTWeb, "15 - Telefone", oFont01) //15 - Telefone
					oPrint:Say((nLinIni + 262)/nTWeb, ((nColIni + nColMax)*0.5 + 0020)/nTWeb, "(|__|__|)|__|__|__|__|-|__|__|__|__|", oFont04)

					//16 - E-mail
					oPrint:Box((nLinIni + 209-nWeb)/nTWeb, ((nColIni + nColMax)*0.65)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.65 + 0020)/nTWeb, "16 - E-mail", oFont01) //16 - E-mail

					//Diagnóstico Oncológico - linha divisoria
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 80)
					AddTBrush(oPrint, (nLinIni + 174)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 205)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Diagnóstico Oncológico", oFont01) //Diagnóstico Oncológico

					//17 - Data do diagnóstico
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "17 - Data do diagnóstico", oFont01) //17 - Data do diagnóstico
					oPrint:Say((nLinIni + 262)/nTWeb, (nColIni + 0030)/nTWeb, "|__|__|/|__|__|/|__|__|__|__|", oFont04)

					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.15)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.23 - 0010)/nTWeb)

					//18 - CID 10 Principal (opcional)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.15)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.23 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.15 + 0020)/nTWeb, "18 - CID 10 Principal (opcional)", oFont01) //18 - CID 10 Principal
					oPrint:Say((nLinIni + 262)/nTWeb, ((nColIni + nColMax)*0.15 + 0030)/nTWeb, replicate( "|__",4 ) + "|", oFont04)

					//19 - CID 10 (2)(opcional)
					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.23)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.31 - 0010)/nTWeb)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.23)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.31 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "19 - CID 10 (2)(opcional)", oFont01) //19 - CID 10 (2)
					oPrint:Say((nLinIni + 262)/nTWeb, ((nColIni + nColMax)*0.23+ 0030)/nTWeb, replicate( "|__",4 ) + "|", oFont04)

					//20 - CID 10 (3)(opcional)
					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.31)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.39 - 0010)/nTWeb)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.31)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.39 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.31 + 0020)/nTWeb, "20 - CID 10 (3)(opcional)", oFont01) //20 - CID 10 (3)
					oPrint:Say((nLinIni + 262)/nTWeb, ((nColIni + nColMax)*0.31 + 0030)/nTWeb, replicate( "|__",4 ) + "|", oFont04)

					//21 - CID 10 (4)(opcional)
					AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.39)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.39)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.39 + 0020)/nTWeb, "21 - CID 10 (4)(opcional)", oFont01) //21 - CID 10 (4)
					oPrint:Say((nLinIni + 262)/nTWeb, ((nColIni + nColMax)*0.39 + 0030)/nTWeb, replicate( "|__",4 ) + "|", oFont04)

					//29 - Plano Terapêutico
					oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.5)/nTWeb, (nLinIni + 402-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.5 + 0020)/nTWeb, "29 - Plano Terapêutico", oFont01) //29 - PlanoTerapêutico

					nOldLin := nLinIni

					//For nI := 1 To MlCount(aDados[nX, 26, nX1], If(!lWeb,180,120))
					//	cObs := MemoLine(aDados[nX, 26, nX1], If(!lWeb,180,120), nI)
					//	oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.38 + 0020)/nTWeb, cObs, oFont01)
					//	nLinIni += 30
					//	If nI == 5
					//		exit //trunco para nao desconfigurar o relatorio
					//	Endif
					//Next nI

					nLinIni := nOldLin

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)

					//22 - Estadiamento
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.08 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, (nColIni + 0020)/nTWeb, "22 - Estadiamento", oFont01) //22 - Estadiamento
					oPrint:Say((nLinIni + 233)/nTWeb, (nColIni + 0030)/nTWeb, "|__|", oFont04)

					//23 - Tipo de Quimioterapia
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.082)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.082 + 0020)/nTWeb, "23 - Tipo de Quimioterapia", oFont01) //23 - Tipo de Quimioterapia
					oPrint:Say((nLinIni + 233)/nTWeb, ((nColIni + nColMax)*0.082 + 0030)/nTWeb, "|__|", oFont04)

					//24 - Finalidade
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 )/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.19 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.15 + 0012)/nTWeb, "24 - Finalidade", oFont01) //24 - Finalidade
					oPrint:Say((nLinIni + 233)/nTWeb, ((nColIni + nColMax)*0.15 + 0032)/nTWeb, "|__|", oFont04)

					//25 - ECOG
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.19)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.23 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.19 + 0020)/nTWeb, "25 - ECOG", oFont01) //25 - ECOG
					oPrint:Say((nLinIni + 233)/nTWeb, ((nColIni + nColMax)*0.19 + 0030)/nTWeb, "|__|", oFont04)

					//26 - TUMOR
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.23)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.31 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "26 - TUMOR", oFont01) //26 - TUMOR
					oPrint:Say((nLinIni + 233)/nTWeb, ((nColIni + nColMax)*0.23 + 0030)/nTWeb, "|__|", oFont04)

					//27 - NÓDULO
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.31)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.39 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.31 + 0020)/nTWeb, "27 - NÓDULO", oFont01) //27 - NÓDULO
					oPrint:Say((nLinIni + 233)/nTWeb, ((nColIni + nColMax)*0.31 + 0030)/nTWeb, "|__|", oFont04)

					//28 - Metástase
					oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.39)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.39 + 0020)/nTWeb, "28 - Metástase", oFont01) //28 - Metástase
					oPrint:Say((nLinIni + 233)/nTWeb, ((nColIni + nColMax)*0.39 + 0030)/nTWeb, "|__|", oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 300, 80)

					//30 - Diagnóstico Cito/Histopatológico
					oPrint:Box((nLinIni + 28-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 500-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
					oPrint:Say((nLinIni +33)/nTWeb, (nColIni + 0020)/nTWeb, "30 - Diagnóstico Cito/Histopatológico", oFont01) //30 - Diagnóstico Cito/Histopatológico

					//31 - Informações relevantes
					oPrint:Box((nLinIni + 28-nWeb)/nTWeb, ((nColIni + nColMax)*0.5)/nTWeb, (nLinIni + 500-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 33)/nTWeb, ((nColIni + nColMax)*0.5 + 0020)/nTWeb, "31 - Informações relevantes", oFont01) //31 - Informações relevantes

					//nOldLin := nLinIni

					//For nI := 1 To MlCount(aDados[nX, 30, nX1], If(!lWeb,120,90))
					//	cObs := MemoLine(aDados[nX, 30, nX1], If(!lWeb,120,90), nI)
					//	oPrint:Say((nLinIni + 80)/nTWeb, (nColIni + 0020)/nTWeb, cObs, oFont01)
					//	nLinIni += 30
					//Next nI

					//nLinIni := nOldLin

					//For nI := 1 To MlCount(aDados[nX, 31, nX1], If(!lWeb,120,90))
					//	cObs := MemoLine(aDados[nX, 31, nX1], If(!lWeb,120,90), nI)
					//	oPrint:Say((nLinIni + 80)/nTWeb, ((nColIni + nColMax)*0.5 + 0030)/nTWeb, cObs, oFont01)
					//	nLinIni += 30
					//Next nI

					//nLinIni := nOldLin

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 500, 80)
					nOldLin := nLinIni

					AddTBrush(oPrint,  (nLinIni + 97)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 230)/nTWeb, ((nColIni + nColMax)*0.8 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 50)/nTWeb, (nColIni + 0020)/nTWeb, "Medicamentos e Drogas solicitadas", oFont01) //Medicamentos e Drogas solicitadas

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 570-nWeb)/nTWeb, ((nColIni + nColMax)*0.8 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 60)/nTWeb, (nColIni + 0040)/nTWeb, "32-Data Prevista para Administração", oFont01)			//32-Data Prevista para Administração
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.16)/nTWeb, "33-Tabela", oFont01)							//33-Tabela
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.20)/nTWeb, "34-Código do Medicamento", oFont01)				//34-Código do Medicamento
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.33)/nTWeb, "35-Descrição", oFont01)							//35-Descrição
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.53)/nTWeb, "36-Dosagem total no ciclo", oFont01,,,,1)		//36-Dosagem total no ciclo
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.63 + 0020)/nTWeb, "37-Unidade de medida", oFont01,,,,1)		//37-Unidade de medida
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.69 + 0020)/nTWeb, "38-Via Adm", oFont01)					//38-Via Adm
					oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.75 - 0020)/nTWeb + IIF(lWeb,0,100), "39-Frequência", oFont01,,,,1) //39-Frequência

					For nN := nV To nAte

						oPrint:Say((nLinIni + 100)/nTWeb, (nColIni + 0012)/nTWeb, AllTrim(Str(nN)) + " - ", oFont01)

						oPrint:Say((nLinIni + 100)/nTWeb, (nColIni + 0040)/nTWeb, "|__|__|/|__|__|/|__|__|__|__|", oFont04)				//32-Data Prevista para Administração
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.16)/nTWeb, "|__|__|", oFont04)							//33-Tabela
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.20)/nTWeb, replicate( "|__",10 ) + "|", oFont04)		//34-Código do Medicamento
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.33)/nTWeb, replicate( "__",40 ), oFont01)				//35-Descrição
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.53)/nTWeb, "|__|__|__|__|__|,|__|__|", oFont04,,,,1)	//36-Dosagem total no ciclo
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.63 + 0020)/nTWeb, replicate( "|__",3 ) + "|", oFont04)	//37-Unidade de medida
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.69 + 0020)/nTWeb, replicate( "|__",2 ) + "|", oFont04)	//38-Via Adm
						oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.75 - 0020)/nTWeb + IIF(lWeb,0,100), replicate( "|__",2 ) + "|" , oFont04,,,,1)	//39-Frequência

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
					Next

					If nAte < Len(aDados[nX, 32, nX1])
						lImpNovo := .T.
						nAte += 8
						nV := nN
					EndIf

					nLinIni := nOldLin

					//Tratamentos Anteriores - linha divisoria
					AddTBrush(oPrint,  (nLinIni + 97)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230)/nTWeb, (nColIni + nColMax)/nTWeb)
					oPrint:Say((nLinIni + 50)/nTWeb, ((nColIni + nColMax)*0.8 + 0010)/nTWeb, "Tratamentos Anteriores", oFont01) //Tratamentos Anteriores

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)

					//40 - Cirurgia
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "40 - Cirurgia", oFont01) //40- Cirurgia

					nLinZZ := nLinIni

					//For nI := 1 To MlCount(aDados[nX, 40, nX1], 30)
					//	cObs := MemoLine(aDados[nX, 40, nX1], 30, nI)
					//	oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, cObs, oFont04)
					//	nLinIni += 30
					//	If nI == 5
					//		exit // trunco para nao desconfigurar o relatorio
					//	Endif
					//Next nI

					nLinIni := nLinZZ + 150

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)

					//41 - Data da Realização
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 130-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "41 - Data da Realização", oFont01) //41 - Data da Realização
					oPrint:Say((nLinIni + 84)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, "|__|__|/|__|__|/|__|__|__|__|", oFont04)

					//42 - Área Irradiada
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "42 - Área Irradiada", oFont01) //42 - Área Irradiada

					nLinZZ := nLinIni

					//For nI := 1 To MlCount(aDados[nX, 42, nX1], 30)
					//	cObs := MemoLine(aDados[nX, 42, nX1], 30, nI)
					//	oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, cObs, oFont04)
					//	nLinIni += 30
					//	If nI == 5
					//		exit // trunco para nao desconfigurar o relatorio
					//	Endif
					//Next nI

					nLinIni := nLinZZ + 150

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
					oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 130-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "43 - Data da Aplicação", oFont01) //43 - Data da Aplicação
					oPrint:Say((nLinIni + 84)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, "|__|__|/|__|__|/|__|__|__|__|", oFont04)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
					AddTBrush(oPrint, (nLinIni + 54)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 400)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Box((nLinIni + 50 -nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 200-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
					oPrint:Say((nLinIni + 50)/nTWeb, (nColIni + 0020)/nTWeb, "44 - Observação / Justificativa", oFont01) //38 - Área Irradiada

					nLinZZ := nLinIni

					//For nI := 1 To MlCount(aDados[nX, 44, nX1], If(!lWeb,155,120))
					//	cObs := MemoLine(aDados[nX, 44, nX1], If(!lWeb,155,120), nI)
					//	oPrint:Say((nLinIni + 70)/nTWeb, (nColIni + 0030)/nTWeb, cObs, oFont04)
					//	nLinIni += 30
					//	If nI == 4
					//		exit
					//	Endif
					//Next nI

					nLinIni := 1980

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

					//45- Número de Ciclos
					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.10 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, (nColIni + 0020)/nTWeb, "45- Número de Ciclos", oFont01) //45- Número de Ciclos
					oPrint:Say((nLinIni + 229)/nTWeb, (nColIni + 0020)/nTWeb, "Previstos", oFont01) //Previstos
					oPrint:Say((nLinIni + 264)/nTWeb, (nColIni + 0030)/nTWeb, "|__|__|", oFont04)

					//46 - Ciclo Atual
					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.10)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.16 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.10 + 0020)/nTWeb, "46 - Ciclo Atual", oFont01) //46 - Ciclo Atual
					oPrint:Say((nLinIni + 264)/nTWeb, ((nColIni + nColMax)*0.10 + 0030)/nTWeb, "|__|__|", oFont04)

					//47-Nº de dias do Ciclo Atual
					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.16)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.23 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.16 + 0020)/nTWeb, "47-Nº de dias do", oFont01) //45- Número de Ciclos
					oPrint:Say((nLinIni + 229)/nTWeb, ((nColIni + nColMax)*0.16 + 0020)/nTWeb, "Ciclo Atual", oFont01) //Previstos
					oPrint:Say((nLinIni + 264)/nTWeb, ((nColIni + nColMax)*0.16 + 0030)/nTWeb, "|__|__|__|", oFont04)

					//48-Intervalo entre Ciclos (em dias)
					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.23)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.29 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "48-Intervalo entre", oFont01) //48-Intervalo entre
					oPrint:Say((nLinIni + 229)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "Ciclos ( em dias)", oFont01) //Ciclos ( em dias)
					oPrint:Say((nLinIni + 264)/nTWeb, ((nColIni + nColMax)*0.23 + 0030)/nTWeb, "|__|__|__|", oFont04)

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.29)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.42 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.29 + 0020)/nTWeb, "49 - Data da Solicitação", oFont01) //49 - Data da Solicitação
					oPrint:Say((nLinIni + 264)/nTWeb, ((nColIni + nColMax)*0.29 + 0030)/nTWeb, "|__|__|/|__|__|/|__|__|__|__|", oFont04)

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.42)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.71 - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.42 + 0020)/nTWeb, "50-Assinatura do Profissional Solicitante", oFont01) //50-Assinatura do Profissional Solicitante

					oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.71)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
					oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.71 + 0020)/nTWeb, "51-Assinatura do Responsável pela Autorização", oFont01) //51-Assinatura do Responsável pela Autorização


					oPrint:EndPage()	// Finaliza a pagina

				EndDo

			Next

			oPrint:EndPage()	// Finaliza a pagina

		Next
	endIf

	If lWeb
		oPrint:Print()
	Else
		oPrint:Preview()
	Endif

Return cFileName


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLTISARADI³ Autor ³ Bruno Iserhardt       ³ Data ³ 06.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3 (Anexo de Solicitacao de         ³±±
±±³          ³ Radioterapia)                                               ³±±
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
Function PLTISARADI(aDados, nLayout, cLogoGH,lWeb, cPathRelW, lUnicaImp)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nOldLin	:=	0
	Local nColA4    := 	0
	Local nWeb		:=  0
	Local cFileLogo
	Local lPrinter := .F.
	Local lImpNovo := .T.
	Local nI, nJ, nN, nV
	Local nX, nX1, nCount
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local cObs
	Local cRel      := "guiaradi"
	Local cPathSrvJ := GETMV("MV_RELT")
	Local nTweb		:= 1
	Local nLweb		:= 0
	Local nLwebC	:= 0
	Local oPrint	:= NIL

	Default lUnicaImp := .F.
	Default lWeb    := .F.
	Default cPathRelW := ''
	Default nLayout := 2
	Default cLogoGH := ''
	Default	aDados  := { {;
		"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - N Guia no Prestador
	{"01234567890123456789"},; //3 - Numero da Guia Referenciada
	{"01234567890123456789"},; //4 - Senha
	{CtoD("06/02/14")},; //5 - Data da Autorizacao
	{"01234567890123456789"},; //6 - Numero da Guia Atribuido pela Operadora
	{"01234567890123456789"},; //7 - Número da Carteira
	{Replicate("M", 70)},; //8 - Nome
	{999},; //9 - Idade
	{"M"},; //10 - Sexo
	{Replicate("M", 70)},; //11 - Nome do Profissional Solicitante
	{"01234567890"},; //12 - Telefone
	{Replicate("M", 60)},; //13 - E-mail
	{CtoD("06/02/2014")},; //14 - Data do diagnóstico
	{"1111"},; //15 - CID 10 Principal
	{"2222"},; //16 - CID 10 (2)
	{"3333"},; //17 - CID 10 (3)
	{"4444"},; //18 - CID 10 (4)
	{"1"},; //19 - Diagnóstico por Imagem
	{"2"},; //20 - Estadiamento
	{"3"},; //21 - ECOG
	{"4"},; //22 - Finalidade
	{Replicate("M", 1000)},; //23 - Diagnóstico Cito/Histopatológico
	{Replicate("M", 1000)},; //24 - Informações relevantes
	{Replicate("M", 40)},; //25 - Cirurgia
	{CtoD("06/02/2014")},; //26 - Data da Realização
	{Replicate("M", 40)},; //27 - Quimioterapia
	{CtoD("06/02/2014")},; //28 - Data da Aplicação
	{111},; //29 - Número de Campos
	{2222},; //30 - Dose por dia (em Gy)
	{3333},; //31 - Dose Total ( em Gy)
	{444},; //32 - Número de Dias
	{CtoD("06/02/2014")},; //33 - Data Prevista para Início da Administração
	{Replicate("M", 500)},; //34-Observação/Justificativa
	{CtoD("06/02/2014")},; //35 - Data da Solicitação
	{},; //36-Assinatura do Profissional Solicitante
	{},; //37-Assinatura do Autorizador da Operadora
	{} } } //38-Nome Social

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2275
		nColMax	:=	3270
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
		oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	if !lWeb
		oPrint	:= TMSPrinter():New("ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA") //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
	else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
		oPrint:cPathPDF := cPathSrvJ
		nTweb		:= 3.9
		nLweb		:= 10
		nLwebC		:= -3
		nWeb		:= 25
		nColMax		:= 3100
		oPrint:lServer := lWeb
	Endif

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		oPrint:setDevice(IMP_PDF)
	Else
		// Verifica se existe alguma impressora configurada para Impressao Grafica
		lPrinter := oPrint:IsPrinterActive()
		IF lPrinter
			lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se irá alterar a Impressora Ativa
		ENDIF
		If ! lPrinter
			oPrint:Setup()
		EndIf
	Endif

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nX1 := 1 To Len(aDados[nX, 02])

			nAte := 12
			nV := 1

		//Esta parte do código faz com que
		//imprima mais de uma guia.
		//INICIO
			If lUnicaImp
				If nX1 <= Len(aDados)
					lImpNovo := .T.
				EndIf
			EndIf
		//FIM

			While lImpNovo

				lImpNovo := .F.

				nLinIni  := 080
				nColIni  := 080
				nColA4   := 000

				oPrint:StartPage()		// Inicia uma nova pagina
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Box Principal                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega e Imprime Logotipo da Empresa                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fLogoEmp(@cFileLogo,, cLogoGH)

				If File(cFilelogo)
					oPrint:SayBitmap((nLinIni + 0040)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (090)/nTweb) 		// Tem que estar abaixo do RootPath
				EndIf

				If nLayout == 2 // Papél A4
					nColA4    := -0335
				Elseif nLayout == 3// Carta
					nColA4    := -0530
				Endif

				oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
				oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 750)/nTweb, "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
				oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02, nX1], oFont03n)

				//fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
				oPrint:Box((nLinIni + 0175 -nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.1 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, (nColIni + 0020)/nTweb, "1 - Registro ANS", oFont01) //1 - Registro ANS
				oPrint:Say((nLinIni + 0220)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 01], oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.1)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.35 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.1 + 0020)/nTweb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.1 + 0030)/nTweb, aDados[nX, 03, nX1], oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.35)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.6 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.35 + 0020)/nTweb, "4 - Senha", oFont01) //4 - Senha
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.35 + 0030)/nTweb, aDados[nX, 04, nX1], oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.75 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.6 + 0020)/nTweb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.6 + 0030)/nTweb, DToC(aDados[nX, 05, nX1]), oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.75)/nTweb, (nLinIni + 0269-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.75 + 0020)/nTweb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.75 + 0030)/nTweb, aDados[nX, 06, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
				AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Beneficiário", oFont01) //Dados do Prestador
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.25 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 07, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.25)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
				
				If PLSTISSVER() < "4"
					oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.25 + 0020)/nTweb, "8 - Nome", oFont01) //8 - Nome
					oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.25 + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)
				Else	
					oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.25 + 0020)/nTweb, "38 - Nome Social", oFont01) //38 - Nome Social
					oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.25 + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)
				Endif
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.85 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.92 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.85 + 0020)/nTweb, "9 - Idade", oFont01) //12 - Idade
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.85 + 0030)/nTweb, Transform(aDados[nX, 9, nX1], "@E 999"), oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.92 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.92 + 0020)/nTweb, "10 - Sexo", oFont01) //13 - Sexo
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.92 + 0030)/nTweb, aDados[nX, 10, nX1], oFont04)

				If PLSTISSVER() >= "4"
					oPrint:Box((nLinIni + 307 - nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400- nWeb)/nTweb, ((nColIni + nColMax) * 1.00 -0010)/nTweb)
					oPrint:Say((nLinIni + 312)/nTweb, (nColIni + 0020)/nTweb, "8 - Nome", oFont01) //8 - Nome
					oPrint:Say((nLinIni + 352)/nTweb, (nColIni  + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 230, 80)
				Else
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)	
				Endif
	
			
				AddTBrush(oPrint,  (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.5 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "11 - Nome do Profissional Solicitante", oFont01) //14 - Nome do Profissional Solicitante
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 11, nX1], oFont04)
				oPrint:Box((nLinIni + 209-nWeb)/nTweb, ((nColIni + nColMax)*0.5)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.6 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.5 + 0020)/nTweb, "12 - Telefone", oFont01) //15 - Telefone
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.5 + 0030)/nTweb, aDados[nX, 12, nX1], oFont04)
				oPrint:Box((nLinIni + 210-nWeb)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.6 + 0020)/nTweb, "13 - E-mail", oFont01) //16 - E-mail
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.6 + 0030)/nTweb, aDados[nX, 13, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
				AddTBrush(oPrint, (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Diagnóstico Oncológico", oFont01) //Diagnóstico Oncológico
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.15 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "14 - Data do diagnóstico", oFont01) //14 - Data do diagnóstico
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, DtoC(aDados[nX, 14, nX1]), oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.23 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.23 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.15 + 0020)/nTweb, "15 - CID 10 Principal (opcional)", oFont01) //15 - CID 10 Principal
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.15 + 0030)/nTweb, aDados[nX, 15, nX1], oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.23)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.31 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.23)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.31 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.23 + 0020)/nTweb, "16 - CID 10 (2)(opcional)", oFont01) //16 - CID 10 (2)
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.23 + 0030)/nTweb, aDados[nX, 16, nX1], oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.31)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.39 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.31)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.39 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.31 + 0020)/nTweb, "17 - CID 10 (3)(opcional)", oFont01) //17 - CID 10 (3)
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.31 + 0030)/nTweb, aDados[nX, 17, nX1], oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.39)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.47 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.39)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.47 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.39 + 0020)/nTweb, "18 - CID 10 (4)(opcional)", oFont01) //18 - CID 10 (4)
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.39 + 0030)/nTweb, aDados[nX, 18, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.59 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.47 + 0020)/nTweb, "19 - Diagnóstico por Imagem", oFont01) //19 - Diagnóstico por Imagem
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.47 + 0030)/nTweb, aDados[nX, 19, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.59)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.69 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.59 + 0020)/nTweb, "20 - Estadiamento", oFont01) //20 - Estadiamento
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.59 + 0030)/nTweb, aDados[nX, 20, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.69)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.79 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.69 + 0020)/nTweb, "21 - ECOG", oFont01) //21 - ECOG
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.69 + 0030)/nTweb, aDados[nX, 21, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.79)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.89 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.79 + 0020)/nTweb, "22 - Finalidade", oFont01) //22 - Finalidade
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.79 + 0030)/nTweb, aDados[nX, 22, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)

				nOldLin := nLinIni

				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 900-nWeb)/nTweb, ((nColIni + nColMax)*0.4 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "23 - Diagnóstico Cito/Histopatológico", oFont01) //23 - Diagnóstico Cito/Histopatológico
				For nI := 1 To MlCount(aDados[nX, 23, nX1], 110)
					cObs := MemoLine(aDados[nX, 23, nX1], 110, nI)
					oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont01)
					nLinIni += 30
				Next nI

				nLinIni := nOldLin

				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.4 + 0010)/nTweb, (nLinIni + 900-nWeb)/nTweb, ((nColIni + nColMax)*0.8 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.4 + 0020)/nTweb, "24 - Informações relevantes", oFont01) //24 - Informações relevantes
				For nI := 1 To MlCount(aDados[nX, 24, nX1], 120)
					cObs := MemoLine(aDados[nX, 24, nX1], 120, nI)
					oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.4 + 0020)/nTweb, cObs, oFont01)
					nLinIni += 30
				Next nI

				nLinIni := nOldLin

				AddTBrush(oPrint,  (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 240)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.8 + 0010)/nTweb, "Tratamentos Anteriores", oFont01) //Tratamentos Anteriores

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 380-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "25 - Cirurgia", oFont01) //36- Cirurgia

				For nI := 1 To MlCount(aDados[nX, 25, nX1], 30)
					cObs := MemoLine(aDados[nX, 25, nX1], 30, nI)
					oPrint:Say((nLinIni + 240)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, cObs, oFont04)
					nLinIni += 30
					If nI == 5
						exit
					Endif
				Next nI

				nLinIni := 670

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 280-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "26 - Data da Realização", oFont01) //26 - Data da Realização
				oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, DtoC(aDados[nX, 26, nX1]), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 90, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 380-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "27 - Quimioterapia", oFont01) //27 - Quimioterapia

				For nI := 1 To MlCount(aDados[nX, 27, nX1], 30)
					cObs := MemoLine(aDados[nX, 27, nX1], 30, nI)
					oPrint:Say((nLinIni + 240)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, cObs, oFont04)
					nLinIni += 30
					If nI == 5
						exit
					Endif
				Next nI

				nLinIni := 960

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 290-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "28 - Data da Aplicação", oFont01) //28 - Data da Aplicação
				oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, DtoC(aDados[nX, 28, nX1]), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 200, 80)


				If nAte < Len(aDados[nX, 29])
					lImpNovo := .T.
					nAte += 12
					nV := nN
				EndIf

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)

				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.12 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "29 - Número de Campos", oFont01) //29 - Número de Campos
				oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0030)/nTweb, IIf(Empty(aDados[nX, 29, nX1]), "", Transform(aDados[nX, 29, nX1], "@E 999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.12 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.22 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.12 + 0020)/nTweb, "30 - Dose por dia (em Gy)", oFont01) //30 - Dose por dia (em Gy)
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.12 + 0030)/nTweb, IIf(Empty(aDados[nX, 30, nX1]), "", Transform(aDados[nX, 30, nX1], "@E 9999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.22 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.32 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.22 + 0020)/nTweb, "31 - Dose Total ( em Gy)", oFont01) //31 - Dose Total ( em Gy)
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.22 + 0030)/nTweb, IIf(Empty(aDados[nX, 31, nX1]), "", Transform(aDados[nX, 31, nX1], "@E 9999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.32 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.40 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.32 + 0020)/nTweb, "32 - Número de Dias", oFont01) //32 - Número de Dias
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.32 + 0030)/nTweb, IIf(Empty(aDados[nX, 32, nX1]), "", Transform(aDados[nX, 32, nX1], "@E 999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.40 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.58 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.40 + 0020)/nTweb, "33 - Data Prevista para Início da Administração", oFont01) //33 - Data Prevista para Início da Administração
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.40 + 0030)/nTweb, DtoC(aDados[nX, 33, nX1]), oFont04)
				nLinIni := 1350
				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
				AddTBrush(oPrint,  (nLinIni + 204)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 204)/nTweb, (nColIni + 0020)/nTweb, "34 - Observação / Justificativa", oFont01) //34 - Observação / Justificativa

				nOldLin := nLinIni

				For nI := 1 To MlCount(aDados[nX, 34, nX1], 235)
					cObs := MemoLine(aDados[nX, 34, nX1], 235, nI)
					oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 0030)/nTweb, cObs, oFont04)
					nLinIni += 30
					If nI == 5
						exit
					Endif
				Next nI

				nLinIni := nOldLin

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 230, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.12 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "35 - Data da Solicitação", oFont01) //35 - Data da Solicitação
				oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0030)/nTweb, DtoC(aDados[nX, 35, nX1]), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.12 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.55 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.12 + 0020)/nTweb, "36-Assinatura do Profissional Solicitante", oFont01) //36-Assinatura do Profissional Solicitante
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.55 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.55 + 0020)/nTweb, "37-Assinatura do Autorizador da Operadora", oFont01) //37-Assinatura do Autorizador da Operadora

				oPrint:EndPage()	// Finaliza a pagina

			EndDo
		Next

		oPrint:EndPage()	// Finaliza a pagina

	Next

	If lWeb
		oPrint:Print()
	Else
		oPrint:Preview()
	Endif

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLTISARAD2³ Autor ³ Francisco Edcarlo    ³ Data ³ 09/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3.02.01 (Anexo de Solicitacao de   ³±±
±±³          ³ Radioterapia)                                               ³±±
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
Function PLTISARAD2(aDados, nLayout, cLogoGH,lWeb, cPathRelW, lUnicaImp)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nOldLin	:=	0
	Local nColA4    := 	0
	Local nWeb		:=  0
	Local cFileLogo
	Local lPrinter := .F.
	Local lImpNovo := .T.
	Local nI, nJ, nN, nV
	Local nX, nX1, nCount
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local cObs
	Local cRel      := "guiaradi"
	Local cPathSrvJ := GETMV("MV_RELT")
	Local nTweb		:= 1
	Local nLweb		:= 0
	Local nLwebC	:= 0
	Local oPrint	:= NIL


	Default lUnicaImp := .F.
	Default lWeb    := .F.
	Default cPathRelW := ''
	Default nLayout := 2
	Default cLogoGH := ''
	Default	aDados  := { {;
		"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - N Guia no Prestador
	{"01234567890123456789"},; //3 - Numero da Guia Referenciada
	{"01234567890123456789"},; //4 - Senha
	{CtoD("06/02/14")},; //5 - Data da Autorizacao
	{"01234567890123456789"},; //6 - Numero da Guia Atribuido pela Operadora
	{"01234567890123456789"},; //7 - Número da Carteira
	{Replicate("M", 70)},; //8 - Nome
	{999},; //9 - Idade
	{"M"},; //10 - Sexo
	{Replicate("M", 70)},; //11 - Nome do Profissional Solicitante
	{"01234567890"},; //12 - Telefone
	{Replicate("M", 60)},; //13 - E-mail
	{CtoD("06/02/2014")},; //14 - Data do diagnóstico
	{"1111"},; //15 - CID 10 Principal
	{"2222"},; //16 - CID 10 (2)
	{"3333"},; //17 - CID 10 (3)
	{"4444"},; //18 - CID 10 (4)
	{"1"},; //19 - Diagnóstico por Imagem
	{"2"},; //20 - Estadiamento
	{"3"},; //21 - ECOG
	{"4"},; //22 - Finalidade
	{Replicate("M", 1000)},; //23 - Diagnóstico Cito/Histopatológico
	{Replicate("M", 1000)},; //24 - Informações relevantes
	{Replicate("M", 40)},; //25 - Cirurgia
	{CtoD("06/02/2014")},; //26 - Data da Realização
	{Replicate("M", 40)},; //27 - Quimioterapia
	{CtoD("06/02/2014")},; //28 - Data da Aplicação
	{{CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014")}},; //29-Data Prevista
	{{"14","99","99","99","99","88","99","99","77","99","99","25"}},; //30-Tabela
	{{"0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789"}},; //31-Código do Procedimento
	{{Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150)}},; //32-Descrição
	{{111.99, 999.99, 333.99, 999.99, 555.99, 999.99, 777.99, 999.99, 999.99, 100.99, 999.99, 999.99}},; //33-Qtde.
	{111},; //34 - Número de Campos
	{2222},; //35 - Dose por dia (em Gy)
	{3333},; //36 - Dose Total ( em Gy)
	{444},; //37 - Número de Dias
	{CtoD("06/02/2014")},; //38 - Data Prevista para Início da Administração
	{Replicate("M", 500)},; //39-Observação/Justificativa
	{CtoD("06/02/2014")},; //40 - Data da Solicitação
	{},; //41-Assinatura do Profissional Solicitante
	{} } } //42-Assinatura do Autorizador da Operadora

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2275
		nColMax	:=	3270
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
		oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	if !lWeb
		oPrint	:= TMSPrinter():New("ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA") //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
	else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
		oPrint:cPathPDF := cPathSrvJ
		nTweb		:= 3.9
		nLweb		:= 10
		nLwebC		:= -3
		nWeb		:= 25
		nColMax		:= 3100
		oPrint:lServer := lWeb
	Endif


	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		oPrint:setDevice(IMP_PDF)
	Else
		// Verifica se existe alguma impressora configurada para Impressao Grafica
		lPrinter := oPrint:IsPrinterActive()
		IF lPrinter
			lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se irá alterar a Impressora Ativa
		ENDIF
		If ! lPrinter
			oPrint:Setup()
		EndIf
	Endif
 

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nX1 := 1 To Len(aDados[nX, 02])

			nAte := 12
			nV := 1

		//Esta parte do código faz com que
		//imprima mais de uma guia.
		//INICIO
			If lUnicaImp
				If nX1 <= Len(aDados)
					lImpNovo := .T.
				EndIf
			EndIf
		//FIM

			While lImpNovo

				lImpNovo := .F.

				For nI:= 29 To 33
					If Len(aDados[nX, nI, nX1]) < nAte
						For nJ := Len(aDados[nX, nI, nX1]) + 1 To nAte
							If AllTrim(Str(nI)) $ "33"
								aAdd(aDados[nX, nI, nX1], 0)
							ElseIf AllTrim(Str(nI)) $ "29"
								aAdd(aDados[nX, nI, nX1], CtoD(""))
							Else
								aAdd(aDados[nX, nI, nX1],"")
							EndIf
						Next nJ
					EndIf
				Next nI

				nLinIni  := 080
				nColIni  := 080
				nColA4   := 000

				oPrint:StartPage()		// Inicia uma nova pagina
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Box Principal                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega e Imprime Logotipo da Empresa                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fLogoEmp(@cFileLogo,, cLogoGH)

				If File(cFilelogo)
					oPrint:SayBitmap((nLinIni + 0040)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (090)/nTweb) 		// Tem que estar abaixo do RootPath
				EndIf

				If nLayout == 2 // Papél A4
					nColA4    := -0335
				Elseif nLayout == 3// Carta
					nColA4    := -0530
				Endif

				oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
				oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 750)/nTweb, "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
				oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02, nX1], oFont03n)

				//fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
				oPrint:Box((nLinIni + 0175 -nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.1 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, (nColIni + 0020)/nTweb, "1 - Registro ANS", oFont01) //1 - Registro ANS
				oPrint:Say((nLinIni + 0220)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 01], oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.1)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.35 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.1 + 0020)/nTweb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.1 + 0030)/nTweb, aDados[nX, 03, nX1], oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.35)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.6 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.35 + 0020)/nTweb, "4 - Senha", oFont01) //4 - Senha
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.35 + 0030)/nTweb, aDados[nX, 04, nX1], oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.75 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.6 + 0020)/nTweb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.6 + 0030)/nTweb, DToC(aDados[nX, 05, nX1]), oFont04)
				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.75)/nTweb, (nLinIni + 0269-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.75 + 0020)/nTweb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.75 + 0030)/nTweb, aDados[nX, 06, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
				AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Beneficiário", oFont01) //Dados do Prestador
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.25 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 07, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.25)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.25 + 0020)/nTweb, "8 - Nome", oFont01) //8 - Nome
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.25 + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.85 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.92 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.85 + 0020)/nTweb, "9 - Idade", oFont01) //12 - Idade
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.85 + 0030)/nTweb, Transform(aDados[nX, 9, nX1], "@E 999"), oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.92 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.92 + 0020)/nTweb, "10 - Sexo", oFont01) //13 - Sexo
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.92 + 0030)/nTweb, aDados[nX, 10, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
				AddTBrush(oPrint,  (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.5 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "11 - Nome do Profissional Solicitante", oFont01) //14 - Nome do Profissional Solicitante
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 11, nX1], oFont04)
				oPrint:Box((nLinIni + 209-nWeb)/nTweb, ((nColIni + nColMax)*0.5)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.6 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.5 + 0020)/nTweb, "12 - Telefone", oFont01) //15 - Telefone
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.5 + 0030)/nTweb, aDados[nX, 12, nX1], oFont04)
				oPrint:Box((nLinIni + 210-nWeb)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.6 + 0020)/nTweb, "13 - E-mail", oFont01) //16 - E-mail
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.6 + 0030)/nTweb, aDados[nX, 13, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
				AddTBrush(oPrint, (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Diagnóstico Oncológico", oFont01) //Diagnóstico Oncológico
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.15 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "14 - Data do diagnóstico", oFont01) //14 - Data do diagnóstico
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, DtoC(aDados[nX, 14, nX1]), oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.23 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.23 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.15 + 0020)/nTweb, "15 - CID 10 Principal (opcional)", oFont01) //15 - CID 10 Principal
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.15 + 0030)/nTweb, aDados[nX, 15, nX1], oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.23)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.31 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.23)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.31 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.23 + 0020)/nTweb, "16 - CID 10 (2)(opcional)", oFont01) //16 - CID 10 (2)
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.23 + 0030)/nTweb, aDados[nX, 16, nX1], oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.31)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.39 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.31)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.39 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.31 + 0020)/nTweb, "17 - CID 10 (3)(opcional)", oFont01) //17 - CID 10 (3)
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.31 + 0030)/nTweb, aDados[nX, 17, nX1], oFont04)
				AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.39)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.47 - 0010)/nTweb)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.39)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.47 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.39 + 0020)/nTweb, "18 - CID 10 (4)(opcional)", oFont01) //18 - CID 10 (4)
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.39 + 0030)/nTweb, aDados[nX, 18, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.59 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.47 + 0020)/nTweb, "19 - Diagnóstico por Imagem", oFont01) //19 - Diagnóstico por Imagem
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.47 + 0030)/nTweb, aDados[nX, 19, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.59)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.69 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.59 + 0020)/nTweb, "20 - Estadiamento", oFont01) //20 - Estadiamento
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.59 + 0030)/nTweb, aDados[nX, 20, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.69)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.79 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.69 + 0020)/nTweb, "21 - ECOG", oFont01) //21 - ECOG
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.69 + 0030)/nTweb, aDados[nX, 21, nX1], oFont04)
				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.79)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.89 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.79 + 0020)/nTweb, "22 - Finalidade", oFont01) //22 - Finalidade
				oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.79 + 0030)/nTweb, aDados[nX, 22, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)

				nOldLin := nLinIni

				oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 900-nWeb)/nTweb, ((nColIni + nColMax)*0.4 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "23 - Diagnóstico Cito/Histopatológico", oFont01) //23 - Diagnóstico Cito/Histopatológico
				For nI := 1 To MlCount(aDados[nX, 23, nX1], 110)
					cObs := MemoLine(aDados[nX, 23, nX1], 110, nI)
					oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont01)
					nLinIni += 30
				Next nI

				nLinIni := nOldLin

				oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.4 + 0010)/nTweb, (nLinIni + 900-nWeb)/nTweb, ((nColIni + nColMax)*0.8 - 0010)/nTweb)
				oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.4 + 0020)/nTweb, "24 - Informações relevantes", oFont01) //24 - Informações relevantes
				For nI := 1 To MlCount(aDados[nX, 24, nX1], 120)
					cObs := MemoLine(aDados[nX, 24, nX1], 120, nI)
					oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.4 + 0020)/nTweb, cObs, oFont01)
					nLinIni += 30
				Next nI

				nLinIni := nOldLin

				AddTBrush(oPrint,  (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 240)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.8 + 0010)/nTweb, "Tratamentos Anteriores", oFont01) //Tratamentos Anteriores

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 380-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "25 - Cirurgia", oFont01) //36- Cirurgia

				For nI := 1 To MlCount(aDados[nX, 25, nX1], 30)
					cObs := MemoLine(aDados[nX, 25, nX1], 30, nI)
					oPrint:Say((nLinIni + 240)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, cObs, oFont04)
					nLinIni += 30
					If nI == 5
						exit
					Endif
				Next nI

				nLinIni := 670

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 280-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "26 - Data da Realização", oFont01) //26 - Data da Realização
				oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, DtoC(aDados[nX, 26, nX1]), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 90, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 380-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "27 - Quimioterapia", oFont01) //27 - Quimioterapia

				For nI := 1 To MlCount(aDados[nX, 27, nX1], 30)
					cObs := MemoLine(aDados[nX, 27, nX1], 30, nI)
					oPrint:Say((nLinIni + 240)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, cObs, oFont04)
					nLinIni += 30
					If nI == 5
						exit
					Endif
				Next nI

				nLinIni := 960

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 290-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "28 - Data da Aplicação", oFont01) //28 - Data da Aplicação
				oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, DtoC(aDados[nX, 28, nX1]), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 200, 80)

				AddTBrush(oPrint,  (nLinIni + 197)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 230)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 200)/nTweb, (nColIni + 0020)/nTweb, "Procedimentos Complementares", oFont01) //Procedimentos Complementares

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 600-nWeb)/nTweb, ((nColIni + nColMax)*0.5 - 0010)/nTweb)
				oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0040)/nTweb, "29-Data Prevista", oFont01) //29-Data Prevista
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.09)/nTweb, "30-Tabela", oFont01) //30-Tabela
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.13)/nTweb, "31-Código do Procedimento", oFont01) //31-Código do Procedimento
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.22)/nTweb, "32-Descrição", oFont01) //32-Descrição
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.40)/nTweb, "33-Qtde.", oFont01,,,,1) //33-Qtde.

				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.5 + 0010)/nTweb, (nLinIni + 600-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.5 + 0040)/nTweb, "29-Data Prevista", oFont01) //29-Data Prevista
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.58)/nTweb, "30-Tabela", oFont01) //30-Tabela
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.63)/nTweb, "31-Código do Procedimento", oFont01) //31-Código do Procedimento
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.72)/nTweb, "32-Descrição", oFont01) //32-Descrição
				oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.89)/nTweb, "33-Qtde.", oFont01,,,,1) //33-Qtde.

				nCount := 0
				nOldLin := nLinIni

				For nN := nV To nAte

					If nCount < 6
						oPrint:Say((nLinIni + 250)/nTweb, (nColIni + 0012)/nTweb, AllTrim(Str(nN)) + " - ", oFont01)
						oPrint:Say((nLinIni + 250)/nTweb, (nColIni + 0040)/nTweb, DtoC(aDados[nX, 29, nX1, nN]), oFont04)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.09)/nTweb, aDados[nX, 30, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.13)/nTweb, aDados[nX, 31, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.22)/nTweb, aDados[nX, 32, nX1, nN], oFont01)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.40)/nTweb, IIf(Empty(aDados[nX, 33, nX1, nN]), "", Transform(aDados[nX, 33, nX1, nN], "@E 999.99")), oFont04,,,,1)
					Else
						If nCount == 6
							nLinIni := nOldLin
						EndIf
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.5 + 0012)/nTweb, AllTrim(Str(nN)) + " - ", oFont01)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.5 + 0040)/nTweb, DtoC(aDados[nX, 29, nX1, nN]), oFont04)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.58)/nTweb, aDados[nX, 30, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.63)/nTweb, aDados[nX, 31, nX1, nN], oFont04)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.72)/nTweb, aDados[nX, 32, nX1, nN], oFont01)
						oPrint:Say((nLinIni + 250)/nTweb, ((nColIni + nColMax)*0.89)/nTweb, IIf(Empty(aDados[nX, 33, nX1, nN]), "", Transform(aDados[nX, 33, nX1, nN], "@E 999.99")), oFont04,,,,1)
					EndIf
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60, 80)
					nCount++
				Next

				If nAte < Len(aDados[nX, 29, nX1])
					lImpNovo := .T.
					nAte += 12
					nV := nN
				EndIf

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60, 80)

				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.12 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "34 - Número de Campos", oFont01) //34 - Número de Campos
				oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0030)/nTweb, IIf(Empty(aDados[nX, 34, nX1]), "", Transform(aDados[nX, 34, nX1], "@E 999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.12 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.22 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.12 + 0020)/nTweb, "35 - Dose por dia (em Gy)", oFont01) //35 - Dose por dia (em Gy)
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.12 + 0030)/nTweb, IIf(Empty(aDados[nX, 35, nX1]), "", Transform(aDados[nX, 35, nX1], "@E 9999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.22 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.32 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.22 + 0020)/nTweb, "36 - Dose Total ( em Gy)", oFont01) //36 - Dose Total ( em Gy)
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.22 + 0030)/nTweb, IIf(Empty(aDados[nX, 36, nX1]), "", Transform(aDados[nX, 36, nX1], "@E 9999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.32 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.40 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.32 + 0020)/nTweb, "37 - Número de Dias", oFont01) //37 - Número de Dias
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.32 + 0030)/nTweb, IIf(Empty(aDados[nX, 37, nX1]), "", Transform(aDados[nX, 37, nX1], "@E 999")), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.40 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.58 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.40 + 0020)/nTweb, "38 - Data Prevista para Início da Administração", oFont01) //38 - Data Prevista para Início da Administração
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.40 + 0030)/nTweb, DtoC(aDados[nX, 38, nX1]), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
				AddTBrush(oPrint,  (nLinIni + 204)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 204)/nTweb, (nColIni + 0020)/nTweb, "39 - Observação / Justificativa", oFont01) //39 - Observação / Justificativa



				For nI := 1 To MlCount(aDados[nX, 39, nX1], 235)
					cObs := MemoLine(aDados[nX, 39, nX1], 235, nI)
					oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 0030)/nTweb, cObs, oFont04)
					nLinIni += 30
					If nI == 5
						exit
					Endif
				Next nI

				nLinIni := 1990

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.12 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "40 - Data da Solicitação", oFont01) //39 - Data da Solicitação
				oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0030)/nTweb, DtoC(aDados[nX, 40, nX1]), oFont04)
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.12 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.55 - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.12 + 0020)/nTweb, "41-Assinatura do Profissional Solicitante", oFont01) //40-Assinatura do Profissional Solicitante
				oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.55 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.55 + 0020)/nTweb, "42-Assinatura do Autorizador da Operadora", oFont01) //41-Assinatura do Autorizador da Operadora

				oPrint:EndPage()	// Finaliza a pagina

			EndDo
		Next

		oPrint:EndPage()	// Finaliza a pagina

	Next

	If lWeb
		oPrint:Print()
	Else
		oPrint:Preview()
	Endif

Return cFileName

//-------------------------------------------------------------------
/*/{Protheus.doc} PLTISRGLO
Estrutura para montar a guia de recurso de glosa

@author  PLS TEAM
@version P11
@since   16.04.00
/*/
//-------------------------------------------------------------------
Function PLTISRGLO(aDados, nLayout, cLogoGH,lWeb, cPathRelW)

	Local nN,nV,nX,nX1	//nI,
	Local nLinMax	:= 0
	Local nColMax	:= 0
	Local nLinIni	:= 0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:= 0		// Coluna Lateral (inicial) Esquerda
	Local nOldLin	:= 0
	Local nColA4    := 0
	Local nWeb		:= 25
	Local cFileLogo	:= ''
	Local lImpNovo 	:= .t.
	Local oFont01	:= nil
	Local oFont02n	:= nil
	Local oFont03n	:= nil
	Local oFont04	:= nil
	Local cRel      := "guiareglo"
	Local cPathSrvJ := GETMV("MV_RELT")
	Local nTweb		:= 3.9
	Local nLweb		:= 0
	Local nLwebC	:= 0
	Local oPrint	:= NIL

	default lWeb    	:= .f.
	default cPathRelW 	:= ''
	default nLayout 	:= 2
	default cLogoGH 	:= ''
	default	aDados  	:= { {;
		"123456",; //1 - Registro ANS
	"01234567890123456789",; //2 - N Guia no Prestador
	Replicate("M", 70),; //3 - Nome da Operadora
	"1",; //4 - Objeto do Recurso
	"01234567890123456789",; //5 - Numero da Guia de Recurso de Glosas Atribuido pela Operadora
	"01234567890123",; //6 - Codigo na Operadora
	Replicate("M", 70),; //7 - Nome do Contratado
	"012345678901",; //8 - Numero do Lote
	"012345678901",; //9 - Numero do protocolo
	"0123",; //10 - Codigo da Glosa do Protocolo
	Replicate("M", 150),; //11 - Justificativa (no caso de recurso integral do protocolo)
	"S",; //12 - Acatado
	Replicate("M", 20),; //13 - Numero da guia no prestador
	Replicate("M", 20),; //14 - Numero da guia atribuido pela operadora
	Replicate("M", 20),; //15 - Senha
	"2222",; //16 - codigo da glosa da guia
	Replicate("M", 150),; //17 - justificativa (nocaso de recurso integral da guia)
	"S",; //18 - Acatado
	{CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014")},; //19 - Data de realizacao
	{CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014"),CtoD("06/02/2014")},; //20 - Data final periodo
	{"14","99","99","99","99","88","99","99","77","99","99","25"},; //21 - Tabela
	{"0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789"},; //22 - Procedimento/item assistencial
	{Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150)},; //23 - Descricao
	{"H1","O1","C1","U1","C1","C1","H1","11","21","S1","G1","D1"},; //24 - Grau de Participação
	{"0011","0012","0013","0013","0013","0013","0013","0031","0031","0031","0031","0031"},; //25 - Codigo
	{111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99},; //26 - Valor Recursado
	{Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150)},; //27 - Justificativa do Prestador
	{111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99, 111111.99},; //28 - Valor Acatado
	{Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450),Replicate("M", 450)},; //29 - Justificativa da Operadora
	11111111.99,; //30 - Valor Total Recursado (R$)
	11111111.99,; //31 - Valor Total Acatado (R$)
	CtoD("06/02/2014"),; //32 - Data do Recurso
	'',; //33-Assinatura do Contratado
	CtoD("06/02/2014"),; //34 - Data da Assinatura da Operadora
	'' } } //35-Assinatura da Operadora

	oFont01 := TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal


//Nao permite acionar a impressao quando for na web.
	if lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	else
		cFileName := cRel+CriaTrab(NIL,.F.)
	endIf
//New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
	if lWeb
		oPrint := FWMSPrinter():New( cFileName,,.f.,cPathSrvJ,.t.,,@oPrint,,,.f.,.f.)

		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
		oPrint:cPathPDF 	:= cPathSrvJ
		nColMax			:= 2980
	else
		oPrint := FWMSPrinter():New( cFileName,,.f.,cPathSrvJ,.t.,,,,,.f.,,)
	endIf

	oPrint:lServer 	:= lWeb

	oPrint:setLandscape()		// Modo paisagem

	if nLayout == 2
		oPrint:setPaperSize(9)// Papél A4
	elseIf nLayout == 3
		oPrint:setPaperSize(1)// Papél Carta
	endif

//Device
	if lWeb
		oPrint:setDevice(IMP_PDF)
	else
		oPrint:Setup()

		if !(oPrint:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
			return
		else
			lImpnovo := (oPrint:nModalResult == 1)
		endif
	endif

	If oPrint:nPaperSize  == 9 // Papel A4
		nLinMax	:= 2270
		nColMax	:= 3100
		nLayout 	:= 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04	:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Elseif oPrint:nPaperSize == 1 // Papel Carta
		nLinMax	:= 2275
		nColMax	:= 2950
		nLayout 	:= 3
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04	:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		nLinMax	:= 2150
		nColMax	:= 2800
		nLayout 	:= 1
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04	:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Endif

	if lWeb
		nColMax := 2980
	EndIf

	For nX := 1 To Len(aDados)
		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nX1 := 1 To Len(aDados[nX, 02])

			nAte:= 12
			nV 	:= 1

			While lImpNovo

				lImpNovo := .F.

				nLinIni  := 080
				nColIni  := 080
				nColA4   := 000

			//Inicia uma nova pagina
				oPrint:StartPage()

			//Box Principal
				oPrint:Box((nLinIni/nTweb), nColIni/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

			//Carrega e Imprime Logotipo da Empresa
				fLogoEmp(@cFileLogo,, cLogoGH)

				If File(cFilelogo)
					oPrint:SayBitmap((nLinIni + 0040)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (090)/nTweb) 		// Tem que estar abaixo do RootPath
				EndIf

			// Papél A4
				If nLayout == 2
					nColA4    := -0335
			// Carta
				Elseif nLayout == 3
					nColA4    := -0530
				Endif

				oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "GUIA DE RECURSO DE GLOSAS", oFont02n,,,, 2)
				oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 750)/nTweb, "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
				oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02], oFont03n)

				oPrint:Box((nLinIni + 0175 -nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.1 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, (nColIni + 0020)/nTweb, "1 - Registro ANS", oFont01) //1 - Registro ANS
				oPrint:Say((nLinIni + 0220)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 01], oFont04)

				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.1)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.65 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.1 + 0020)/nTweb, "3 - Nome da Operadora", oFont01) //3 - Nome da Operadora
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.1 + 0030)/nTweb, aDados[nX, 03], oFont04)

				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.65)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.73 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.65 + 0020)/nTweb, "4 - Objeto do Recurso", oFont01) //4 - Objeto do Recurso
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.65 + 0030)/nTweb, aDados[nX, 04], oFont04)

				oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.73)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.97 - 0010)/nTweb)
				oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.73 + 0020)/nTweb, "5 - Número da Guia de Recurso de Glosas Atribuido pela Operadora", oFont01) //5 - Número da Guia de Recurso de Glosas Atribuido pela Operadora
				oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.73 + 0030)/nTweb, aDados[nX, 05], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
				AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 0020)/nTweb, "Dados do Contratado", oFont01) //Dados do Contratado

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.25 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0020)/nTweb, "6 - Código na Operadora", oFont01) //6 - Código na Operadora
				oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 06], oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.25)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.25 + 0020)/nTweb, "7 - Nome do Contratado", oFont01) //7 - Nome do Contratado
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.25 + 0030)/nTweb, aDados[nX, 07], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 150, 80)

				AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 0020)/nTweb, "Dados do recurso do protocolo", oFont01) //Dados do recurso do protocolo

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.100 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0020)/nTweb, "8 - Número do Lote", oFont01) //8 - Número do Lote
				oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 08], oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.100 + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.20 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.100 + 0020)/nTweb, "9 - Número do Protocolo", oFont01) //9 - Número do Protocolo
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.100 + 0030)/nTweb, aDados[nX, 09], oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.20 + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.35 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.20 + 0020)/nTweb, "10 - Código da Glosa do Protocolo", oFont01) //10 - Código da Glosa do Protocolo
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.20 + 0030)/nTweb, iif(aDados[nX, 04] == "1", aDados[nX, 10],""), oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.35 + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.94 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.35 + 0020)/nTweb, "11 - Justificativa (no caso de recurso integral do protocolo)", oFont01) //11 - Justificativa (no caso de recurso integral do protocolo)
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.35 + 0030)/nTweb, left(aDados[nX, 11],75), oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.94 + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.94 + 0020)/nTweb, "12 -  Acatado", oFont01) //12 -  Acatado
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.94 + 0030)/nTweb, aDados[nX, 12], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 150, 80)

				AddTBrush(oPrint,  (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 0020)/nTweb, "Dados do recurso da guia", oFont01) //Dados do recurso da guia

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.20 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0020)/nTweb, "13- Número da guia no prestador", oFont01) //13- Número da guia no prestador
				oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 13], oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.20 + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.60 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.20 + 0020)/nTweb, "14- Número da guia atribuído pela operadora", oFont01) //14- Número da guia atribuído pela operadora
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.20 + 0030)/nTweb, aDados[nX, 14], oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.60)/nTweb, (nLinIni + 330-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.60 + 0020)/nTweb, "15-Senha", oFont01) //15-Senha
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.60 + 0030)/nTweb, aDados[nX, 15], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 105, 80)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.12 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0020)/nTweb, "16-Código da glosa da guia", oFont01) //16-Código da glosa da guia
				oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0020)/nTweb, iif(aDados[nX, 04] == "2", aDados[nX, 16],""), oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.12)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.94 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.12 + 0020)/nTweb, "17-Justificativa (no caso de recurso integral da guia)", oFont01) //17-Justificativa (no caso de recurso integral da guia)
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.12 + 0030)/nTweb, left(aDados[nX, 17],105), oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.94)/nTweb, (nLinIni + 330-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.94 + 0020)/nTweb, "18-Acatado", oFont01) //18-Acatado
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.94 + 0030)/nTweb, aDados[nX, 18], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 150, 80)

				AddTBrush(oPrint,  (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
				oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 0020)/nTweb, "Dados do recurso do procedimento ou item assistencial", oFont01) //Dados do recurso do procedimento ou item assistencial

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 1200-nWeb)/nTweb, ( (nColIni + nColMax)-0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0040)/nTweb, "19-Data de realização", oFont01) //19-Data de realização
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.11)/nTweb, "20-Data final período", oFont01) //20-Data final período
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, "21-Tabela", oFont01) //21-Tabela
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.22)/nTweb, "22-Procedimento/Item assistencial", oFont01) //22-Procedimento/Item assistencial
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.33)/nTweb, "23-Descrição", oFont01,,,,1) //23-Descrição
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.90)/nTweb, "24-Grau de Participação", oFont01,,,,1) //24-Grau de Participação

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20, 80)

				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0040)/nTweb, "25-Código da glosa", oFont01,,,,1) //25-Código da glosa
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.11)/nTweb, "26-Valor Recursado", oFont01,,,,1) //26-Valor Recursado
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, "27-Justificativa do Prestador", oFont01,,,,1) //27-Justificativa do Prestador
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.57)/nTweb, "28-Valor Acatado", oFont01,,,,1) //28-Valor Acatado
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.63)/nTweb, "29-Justificativa da Operadora", oFont01,,,,1) //29-Justificativa da Operadora

				nOldLin := nLinIni

				for nN := nV to nAte

					if nN > len(aDados[nX, 19])
						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 25, 80)
						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
						loop
					endIf

					oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0012)/nTweb, AllTrim(Str(nN)) + " - ", oFont01)

					oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0040)/nTweb, DtoC(aDados[nX, 19, nN]), oFont04)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.11)/nTweb, Dtoc(aDados[nX, 20, nN]), oFont04)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, aDados[nX, 21, nN], oFont04)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.22)/nTweb, aDados[nX, 22, nN], oFont01)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.33)/nTweb, left(aDados[nX, 23, nN],98), oFont01)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.90)/nTweb, aDados[nX, 24, nN], oFont01)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 25, 80)

					oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 25, nN], oFont01)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.11)/nTweb, Transform(aDados[nX, 26, nN], "@E 99,999,999.99"), oFont01)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, left(aDados[nX, 27, nN],67), oFont01)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.57)/nTweb, Transform(aDados[nX, 28, nN], "@E 99,999,999.99"), oFont01)
					oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.63)/nTweb, left(aDados[nX, 29, nN],63), oFont01)

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

				next

				if nAte < len(aDados[nX, 19])
					lImpNovo := .T.
					nAte += 12
					nV := nN
				endIf

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60, 80)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.14 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0020)/nTweb, "30 - Valor Total Recursado (R$)", oFont01) //30 - Valor Total Recursado (R$)
				oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0030)/nTweb, IIf(Empty(aDados[nX, 30]), "", Transform(aDados[nX, 30], "@E 99,999,999.99")), oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.14)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.30 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.14 + 0020)/nTweb, "31 - Valor Total  Acatado (R$)", oFont01) //31 - Valor Total  Acatado (R$)
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.14 + 0030)/nTweb, IIf(Empty(aDados[nX, 31]), "", Transform(aDados[nX, 31], "@E 99,999,999.99")), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 109, 80)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.11 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, (nColIni + 0020)/nTweb, "32 - Data do Recurso", oFont01) //32 - Data do Recurso
				oPrint:Say((nLinIni + 282)/nTweb, (nColIni + 0030)/nTweb, DtoC(aDados[nX, 32]), oFont04)

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.11)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax)*0.40 - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.11 + 0020)/nTweb, "33 - Assinatura do Contratado", oFont01) //33 - Assinatura do Contratado

				oPrint:Box((nLinIni + 238-nWeb)/nTweb, ((nColIni + nColMax)*0.40)/nTweb, (nLinIni + 330-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 242)/nTweb, ((nColIni + nColMax)*0.40 + 0020)/nTweb, "34 - Data da Assinatura da Operadora", oFont01) //34 - Data da Assinatura da Operadora
				oPrint:Say((nLinIni + 282)/nTweb, ((nColIni + nColMax)*0.40 + 0030)/nTweb, DtoC(aDados[nX, 34]), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 80)

				oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
				oPrint:Say((nLinIni + 204)/nTweb, (nColIni + 0020)/nTweb, "35 -  Assinatura da Operadora", oFont01) //35 -  Assinatura da Operadora

				oPrint:EndPage()	// Finaliza a pagina

			EndDo
		Next

		oPrint:EndPage()	// Finaliza a pagina

	Next

	if lWeb
		oPrint:Print()
	else
		oPrint:Preview()
	endif

return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISSP  ³ Autor ³ MAICON SANTOS        ³ Data ³ 16.10.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3.00.01 (Guia Prog. Internaçao)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela	 ³±±
±±³          ³			 de configuracao/preview do relatorio 		        ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 	3 - Formato Carta (216x279mm)     			        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISSP(aDados, lGerTXT, nLayout, cLogoGH, lMail, lWeb, cPathRelW )

	Local nLinMax
	Local nColMax
	Local nLinIni		:=	0	// Linha Lateral (inicial) Esquerda
	Local nColIni		:=	0	// Coluna Lateral (inicial) Esquerda
	Local nColA4    	:=  0
	Local nLinA4    	:=  0
	Local cFileLogo
	Local nLin
	Local nP:=0
	Local nT:=0
	Local nT1:=0
	Local nT3:=0
	Local nI,nJ,nK,nX
	Local nR,nV,nV1,nV2,nN
	Local cObs
	Local cTexto
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local lImpnovo  	:= .T.
	Local nVolta    	:= 0
	Local cFile 		:= GetNewPar("MV_RELT",'\SPOOL\')+'PLSR421N.HTM'
	Local lRet			:= .T.
	Local lOk			:= .T.
	LOCAL cFileName	:= ""
	LOCAL cRel      	:= "GUICONS"
	LOCAL cPathSrvJ 	:= GETMV("MV_RELT")
	LOCAL nAL			:= 0.25
	LOCAL nAC			:= 0.24
	Local lImpPrc   	:= .T.
	LOCAL nLinObs		:= 0
	LOCAL cIndic    	:= ""
	LOCAL I				:= 0
	LOCAL J				:= 0
	Local nCnt          := 0
	LOCAL cErro			:= ""
	LOCAL cArq			:= ""
	Local bError		:= ErrorBlock( {|e| TrataErro(e,@cErro) } )
	Local nLinB			:= 0
	Local lPlsGTiss 	:= ExistBlock("PLSGTISS")
	Local cCodTab   	:= ""
	Local cCodPro   	:= ""
	Local cDescri		:= ""
	Local cGuiaPres     := ""
	Local cCodMedGen    := GetNewPar("MV_PLMEDPT","")
	Local cCodMatGen    := GetNewPar("MV_PLMATPT","")
	Local cCodTaxGen    := GetNewPar("MV_PLTAXPT","")
	Local cCodOpmGen    := GetNewPar("MV_PLOPMPT","")
	Local cTdsCodG      := ""	
	Local lAchou        := .F.
	
	PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
		
	DEFAULT lGerTXT 	:= .F.
	DEFAULT nLayout 	:= 2
	DEFAULT cLogoGH 	:= ""
	DEFAULT lMail		:= .F.
	DEFAULT lWeb		:= .F.
	DEFAULT cPathRelW	:= ""
	DEFAULT aDados 	:= { { ;
		"123456",; 				 //1 - Registro ANS
	"12345678901234567890",; //2 - Nº Guia no Prestador
	"12345678901234567890",; //3 - Número da Guia de Solicitação de Internação
	CtoD("01/01/07"),; 		 //4 - Data da Autorização
	"12345678901234567890",; //5 - Senha
	"12345678901234567890",; //6 - Número da Guia Atribuído pela Operadora
	"123456789012345678901234567890",; //7 - Número da Carteira
	Replicate("M",70),; //8 - Nome
	"12345678901234",; //9 – Código na Operadora
	Replicate("M",70),; //10 - Nome do Contratado
	Replicate("M",70),; //11 - Nome do Profissional Solicitante
	"MM",; //12 - Conselho Profissional
	"123456789012345",; //13 - Número no Conselho
	"RS",; //14 - UF
	"123456",; //15 - Código CBO
	999,; //16 - Qtde. diárias adicionais solicitadas
	"AA",; //17 - Tipo da acomodação solicitada
	Replicate("M",500),; //18 - Indicação Clínica
	{ "10","20","30","40","50","60","70","80","90","99","00","11", "11" },; //19-Tabela
	{ "1234567890","2345678901","3456789012","4567890123","5678901234","1234567890","2345678901","3456789012","4567890123","5678901234","4567890123","5678901234","5678901234" },; //20 - Código do Procedimento
	{ Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("C",150),Replicate("D",150),Replicate("D",150) },; //21 - Descrição
	{ 999,888,777,666,555,444,333,222,111,999,888,777,777 },; //22 - Qtde Solic
	{ 111,222,333,444,555,1212,111,222,333,444,555,1212,1212 },; //23 – Qtde Aut
	"123",; //24 - Qtde. diárias adicionais autorizadas
	"AA",;//25 - Tipo da Acomodação Autorizada
	Replicate("O",500),; //26 - Justificativa da Operadora
	Replicate("O",500),; //27 – Observação / Justificativa
	CtoD("12/12/07") } } //28 - Data da Solicitação

	If nLayout  == 1 // Ofício 2
		nLinMax	:=	3705	// Numero maximo de Linhas (31,5 cm)
		nColMax	:=	2400	// Numero maximo de Colunas (21 cm)
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2478
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
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
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
		If !(oPrint:nModalResult == 1)
			lRet := .F.
			lMail := .F.
			lImpnovo:=.F.
		Else
			lImpnovo:=(oPrint:nModalResult == 1)
		Endif
	EndIf
	For I:=1 to Len(aDados)    // Prevenindo de erros log
		For J:=1 To Len(aDados[I])
			If ValType(aDados[I,J])=="U"
			//lImpnovo:=.F.
				aDados[I,J] := " - "
			Endif
		Next J
	Next I

	BEGIN SEQUENCE
		While lImpnovo

			lImpnovo:=.F.
			nVolta  += 1
			nT      += 9
			nT1     += 2
			nT3     += 3


			For nX := 1 To Len(aDados)

				If Len(aDados[nX]) == 0
					Loop
				EndIf

				For nI := 19 To 23
					If Len(aDados[nX, nI]) < nT
						For nJ := Len(aDados[nX, nI]) + 1 To nT
							If AllTrim(Str(nI)) $ "22,23"
								aAdd(aDados[nX, nI], 0)
							Else
								aAdd(aDados[nX, nI], "")
							EndIf
						Next nJ
					EndIf
				Next nI

				If oPrint:Cprinter == "PDF" .OR. lWeb
					nLinIni := 150
				Else
					nLinIni := 000
				Endif

				nColIni := 060
				nColA4  := 000
				nLinA4  := 000

				oPrint:StartPage()		// Inicia uma nova pagina

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0010)*nAC, (nLinIni + nLinMax - 10)*nAL, (nColIni + nColMax)*nAC)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fLogoEmp(@cFileLogo,, cLogoGH)

				If File(cFilelogo)
					oPrint:SayBitmap((nLinIni + 0040)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
				EndIf

				If nLayout == 2 // Papél A4
					nColA4    := -0065
				Elseif nLayout == 3// Carta
					nLinA4    := -0085
				Endif

				oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.40))*nAC, "GUIA DE SOLICITAÇÃO", oFont02n) //"GUIA DE SOLICITAÇÃO"
				oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.69))*nAC, "2- Nº Guia no Prestador", oFont01) //"2- Nº Guia no Prestador"
				oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.78))*nAC, aDados[nX, 02], oFont03n)
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.34))*nAC, "DE PRORROGAÇÃO DE INTERNAÇÃO", oFont02n) //"DE PRORROGAÇÃO DE INTERNAÇÃO"
				oPrint:Say((nLinIni + 0150)*nAL, (nColIni + (nColMax*0.32))*nAC, "OU COMPLEMENTAÇÃO DO TRATAMENTO", oFont02n) //"OU COMPLEMENTAÇÃO DO TRATAMENTO"

		//Linha 1
				oPrint:Box((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.15)- 0010)*nAC)
				oPrint:Say((nLinIni + 0200)*nAL, (nColIni + 0030)*nAC, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
				oPrint:Say((nLinIni + 0232)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 01],1,6), oFont04)
				oPrint:Box((nLinIni + 0180)*nAL, (nColIni + (nColMax*0.15))*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
				oPrint:Say((nLinIni + 0200)*nAL, (nColIni + (nColMax*0.15) + 0010)*nAC, "3 - Número da Guia de Solicitação de Internação", oFont01) //"3 - Número da Guia de Solicitação de Internação"
				oPrint:Say((nLinIni + 0232)*nAL, (nColIni + (nColMax*0.15) + 0020)*nAC, aDados[nX, 03], oFont04)
				oPrint:Box((nLinIni + 0180)*nAL, (nColIni + (nColMax*0.60))*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.85) - 0010)*nAC)
				oPrint:Say((nLinIni + 0200)*nAL, (nColIni + (nColMax*0.60) + 0010)*nAC, "4 - Data da Autorização", oFont01) //"4 - Data da Autorização"
				oPrint:Say((nLinIni + 0232)*nAL, (nColIni + (nColMax*0.60) + 0020)*nAC, IIF( ValType(aDados[nX, 04]) == "D", DtoC(aDados[nX, 04]), aDados[nX, 04]), oFont04)

		//Linha 2
				oPrint:Box((nLinIni + 0250)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.50) - 0010)*nAC)
				oPrint:Say((nLinIni + 0270)*nAL, (nColIni + 0030)*nAC, "5 - Senha", oFont01) //"5 - Senha"
				oPrint:Say((nLinIni + 0302)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 05],1,20), oFont04)
				oPrint:Box((nLinIni + 0250)*nAL, (nColIni + (nColMax*0.50))*nAC, (nLinIni + 0310)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 0270)*nAL, (nColIni + (nColMax*0.50) + 0010)*nAC, "6 - Número da Guia Atribuído pela Operadora", oFont01) //"6 - Número da Guia Atribuído pela Operadora"
				oPrint:Say((nLinIni + 0302)*nAL, (nColIni + (nColMax*0.50) + 0020)*nAC, aDados[nX, 06], oFont04)

		//Linha 3
				oPrint:Say((nLinIni + 0330)*nAL, (nColIni + 0020)*nAC, "Dados do Beneficiário", oFont01) //Dados do Beneficiário*/

		//Linha 4
				oPrint:Box((nLinIni + 0340)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.30) - 0010)*nAC)
				oPrint:Say((nLinIni + 0360)*nAL, (nColIni + 0030)*nAC, "7 - Número da Carteira", oFont01) //"7 - Número da Carteira"
				oPrint:Say((nLinIni + 0392)*nAL, (nColIni + 0040)*nAC, aDados[nX, 07], oFont04)
				If PLSTISSVER() < "4"
					oPrint:Box((nLinIni + 0340)*nAL, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0400)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0360)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "8 - Nome", oFont01) //"8 - Nome"
					oPrint:Say((nLinIni + 0392)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, SUBSTR(aDados[nX, 8],1,70), oFont04)

					//Linha 5
					oPrint:Say((nLinIni + 0420)*nAL, (nColIni + 0020)*nAC, "Dados do Contratado Solicitante", oFont01) //Dados do Contratado Solicitante

					//Linha 6
					oPrint:Box((nLinIni + 0430)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0490)*nAL, (nColIni + (nColMax*0.25) - 0010)*nAC)
					oPrint:Say((nLinIni + 0450)*nAL, (nColIni + 0030)*nAC, "9 - Código na Operadora", oFont01) //"9 - Código na Operadora"
					oPrint:Say((nLinIni + 0482)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 9],1,19), oFont04)
					oPrint:Box((nLinIni + 0430)*nAL, (nColIni + (nColMax*0.25))*nAC, (nLinIni + 0490)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0450)*nAL, (nColIni + (nColMax*0.25) + 0010)*nAC, "10 - Nome do Contratado", oFont01) //"10 - Nome do Contratado"
					oPrint:Say((nLinIni + 0482)*nAL, (nColIni + (nColMax*0.25) + 0020)*nAC, SUBSTR(aDados[nX, 10],1,70), oFont04)

					//Linha 7
					oPrint:Box((nLinIni + 0500)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.69) - 0010)*nAC)
					oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 0030)*nAC, "11 - Nome do Profissional Solicitante", oFont01) //"11 - Nome do Profissional Solicitante"
					oPrint:Say((nLinIni + 0552)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 11],1,70), oFont04)
					oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.69))*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.75) - 0010)*nAC)
					oPrint:Say((nLinIni + 0518)*nAL, (nColIni + (nColMax*0.69) + 0010)*nAC, "12 - Conselho", oFont01) //"12 - Conselho"
					oPrint:Say((nLinIni + 0532)*nAL, (nColIni + (nColMax*0.69) + 0015)*nAC, "Profissional", oFont01) //"Profissional"
					oPrint:Say((nLinIni + 0558)*nAL, (nColIni + (nColMax*0.69) + 0020)*nAC, SUBSTR(aDados[nX, 12],1,3), oFont04)
					oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.75))*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.88) - 0010)*nAC)
					oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.75) + 0010)*nAC, "13 - Número no Conselho", oFont01) //"13 - Número no Conselho"
					oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.75) + 0020)*nAC, SUBSTR(aDados[nX, 13],1,15), oFont04)
					oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.88))*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.93) - 0010)*nAC)
					oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.88) + 0010)*nAC, "14 - UF", oFont01) //"14 - UF"
					oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.88) + 0020)*nAC, SUBSTR(aDados[nX, 14],1,2), oFont04)
					oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.93))*nAC, (nLinIni + 0560)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.93) + 0010)*nAC, "15 - Código CBO", oFont01) //"15 - Código CBO"
					oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.93) + 0020)*nAC, SUBSTR(aDados[nX, 15],1,6), oFont04)

					//Linha 8
					oPrint:Say((nLinIni + 0580)*nAL, (nColIni + 0020)*nAC, "Dados da Internação", oFont01) //Dados da Internação

					//Linha 9
					oPrint:Box((nLinIni + 0590)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0650)*nAL, (nColIni + (nColMax*0.20) - 0010)*nAC)
					oPrint:Say((nLinIni + 0610)*nAL, (nColIni + 0030)*nAC, "16 - Qtde. Diárias Adicionais Solicitadas", oFont01) //"16 - Qtde. Diárias Adicionais Solicitadas / CNPJ"
					oPrint:Say((nLinIni + 0642)*nAL, (nColIni + 0040)*nAC, IIf(Empty(aDados[nX, 16]), "", Transform(aDados[nX, 16], "@E 999")), oFont04)
					oPrint:Box((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 0650)*nAL, (nColIni + (nColMax*0.45) - 0010)*nAC)
					oPrint:Say((nLinIni + 0610)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "17 - Tipo da Acomodação Solicitada", oFont01) //"17-Tipo de Internação"
					oPrint:Say((nLinIni + 0642)*nAL, (nColIni + (nColMax*0.21))*nAC, aDados[nX, 17], oFont04)

					//Linha 10
					oPrint:Box((nLinIni + 0660)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1200)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0680)*nAL, (nColIni + 0030)*nAC, "18 - Indicação Clínica", oFont01) //"18 - Indicação Clínica"
					//oPrint:Say((nLinIni + 0712 + nLinObs)*nAL, (nColIni + 0040)*nAC,  aDados[nX, 18], oFont04)

					nLinB := nLinIni
				
					cTexto := LOWER(Rtrim(Ltrim(aDados[nX, 18])))
					cTexto := StrTran(cTexto, "  ", " ")
				
					For nI := 1 To MlCount(cTexto, 155,,.F.)
						cObs := MemoLine(cTexto, 155, nI)
						oPrint:Say((nLinB + 0712)*nAl, (nColIni + 0040)*nAC, cObs, oFont04)
						nLinB += 30
						If nI == 15
							exit
						Endif
					Next nI

				Else
					oPrint:Box((nLinIni + 0340)*nAL, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0400)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0360)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "31 - Nome Social", oFont01) //""31 - Nome Social""
					oPrint:Say((nLinIni + 0392)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, SUBSTR(aDados[nX, 31],1,70), oFont04)

					oPrint:Box((nLinIni + 0420)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0480)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0440)*nAL, (nColIni + 0030)*nAC, "8 - Nome", oFont01) //"8 - Nome"
					oPrint:Say((nLinIni + 0472)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 8],1,70), oFont04)


					//Linha 5
					oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 0020)*nAC, "Dados do Contratado Solicitante", oFont01) //Dados do Contratado Solicitante

					//Linha 6
					oPrint:Box((nLinIni + 0530)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0600)*nAL, (nColIni + (nColMax*0.25) - 0010)*nAC)
					oPrint:Say((nLinIni + 0550)*nAL, (nColIni + 0030)*nAC, "9 - Código na Operadora", oFont01) //"9 - Código na Operadora"
					oPrint:Say((nLinIni + 0582)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 9],1,19), oFont04)
					oPrint:Box((nLinIni + 0530)*nAL, (nColIni + (nColMax*0.25))*nAC, (nLinIni + 0600)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0550)*nAL, (nColIni + (nColMax*0.25) + 0010)*nAC, "10 - Nome do Contratado", oFont01) //"10 - Nome do Contratado"
					oPrint:Say((nLinIni + 0582)*nAL, (nColIni + (nColMax*0.25) + 0020)*nAC, SUBSTR(aDados[nX, 10],1,70), oFont04)

					//Linha 7
					oPrint:Box((nLinIni + 0600)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0660)*nAL, (nColIni + (nColMax*0.69) - 0010)*nAC)
					oPrint:Say((nLinIni + 0620)*nAL, (nColIni + 0030)*nAC, "11 - Nome do Profissional Solicitante", oFont01) //"11 - Nome do Profissional Solicitante"
					oPrint:Say((nLinIni + 0652)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 11],1,70), oFont04)
					oPrint:Box((nLinIni + 0600)*nAL, (nColIni + (nColMax*0.69))*nAC, (nLinIni + 0660)*nAL, (nColIni + (nColMax*0.75) - 0010)*nAC)
					oPrint:Say((nLinIni + 0618)*nAL, (nColIni + (nColMax*0.69) + 0010)*nAC, "12 - Conselho", oFont01) //"12 - Conselho"
					oPrint:Say((nLinIni + 0632)*nAL, (nColIni + (nColMax*0.69) + 0015)*nAC, "Profissional", oFont01) //"Profissional"
					oPrint:Say((nLinIni + 0658)*nAL, (nColIni + (nColMax*0.69) + 0020)*nAC, SUBSTR(aDados[nX, 12],1,3), oFont04)
					oPrint:Box((nLinIni + 0600)*nAL, (nColIni + (nColMax*0.75))*nAC, (nLinIni + 0660)*nAL, (nColIni + (nColMax*0.88) - 0010)*nAC)
					oPrint:Say((nLinIni + 0620)*nAL, (nColIni + (nColMax*0.75) + 0010)*nAC, "13 - Número no Conselho", oFont01) //"13 - Número no Conselho"
					oPrint:Say((nLinIni + 0652)*nAL, (nColIni + (nColMax*0.75) + 0020)*nAC, SUBSTR(aDados[nX, 13],1,15), oFont04)
					oPrint:Box((nLinIni + 0600)*nAL, (nColIni + (nColMax*0.88))*nAC, (nLinIni + 0660)*nAL, (nColIni + (nColMax*0.93) - 0010)*nAC)
					oPrint:Say((nLinIni + 0620)*nAL, (nColIni + (nColMax*0.88) + 0010)*nAC, "14 - UF", oFont01) //"14 - UF"
					oPrint:Say((nLinIni + 0652)*nAL, (nColIni + (nColMax*0.88) + 0020)*nAC, SUBSTR(aDados[nX, 14],1,2), oFont04)
					oPrint:Box((nLinIni + 0600)*nAL, (nColIni + (nColMax*0.93))*nAC, (nLinIni + 0660)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0620)*nAL, (nColIni + (nColMax*0.93) + 0010)*nAC, "15 - Código CBO", oFont01) //"15 - Código CBO"
					oPrint:Say((nLinIni + 0652)*nAL, (nColIni + (nColMax*0.93) + 0020)*nAC, SUBSTR(aDados[nX, 15],1,6), oFont04)

					//Linha 8
					oPrint:Say((nLinIni + 0700)*nAL, (nColIni + 0020)*nAC, "Dados da Internação", oFont01) //Dados da Internação

					//Linha 9
					oPrint:Box((nLinIni + 0710)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0770)*nAL, (nColIni + (nColMax*0.20) - 0010)*nAC)
					oPrint:Say((nLinIni + 0730)*nAL, (nColIni + 0030)*nAC, "16 - Qtde. Diárias Adicionais Solicitadas", oFont01) //"16 - Qtde. Diárias Adicionais Solicitadas / CNPJ"
					oPrint:Say((nLinIni + 0762)*nAL, (nColIni + 0040)*nAC, IIf(Empty(aDados[nX, 16]), "", Transform(aDados[nX, 16], "@E 999")), oFont04)
					oPrint:Box((nLinIni + 0710)*nAL, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 0770)*nAL, (nColIni + (nColMax*0.45) - 0010)*nAC)
					oPrint:Say((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "17 - Tipo da Acomodação Solicitada", oFont01) //"17-Tipo de Internação"
					oPrint:Say((nLinIni + 0762)*nAL, (nColIni + (nColMax*0.21))*nAC, aDados[nX, 17], oFont04)

					//Linha 10
					oPrint:Box((nLinIni + 0780)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1200)*nAL, (nColIni + nColMax - 0010)*nAC)
					oPrint:Say((nLinIni + 0800)*nAL, (nColIni + 0030)*nAC, "18 - Indicação Clínica", oFont01) //"18 - Indicação Clínica"
					//oPrint:Say((nLinIni + 0712 + nLinObs)*nAL, (nColIni + 0040)*nAC,  aDados[nX, 18], oFont04)

					nLinB := nLinIni
				
					cTexto := LOWER(Rtrim(Ltrim(aDados[nX, 18])))
					cTexto := StrTran(cTexto, "  ", " ")
				
					For nI := 1 To MlCount(cTexto, 155,,.F.)
						cObs := MemoLine(cTexto, 155, nI)
						oPrint:Say((nLinB + 0822)*nAl, (nColIni + 0040)*nAC, cObs, oFont04)
						nLinB += 30
						If nI == 15
							exit
						Endif
					Next nI
				Endif

				//Linha 11
				oPrint:Say((nLinIni + 1228)*nAL, (nColIni + 0020)*nAC, "Procedimentos Solicitados", oFont01) //Procedimentos Solicitados
				//Linha 12
				oPrint:Box((nLinIni + 1238)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1638)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.02))*nAC, "19 - Tabela", oFont01) //19-Tabela
				oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.07))*nAC, "20 - Código do Procedimento", oFont01) //20 - Código do Procedimento
				oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.18))*nAC, "21 - Descrição", oFont01) //21 - Descrição
				oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.86))*nAC, "22 - Qtde Solic", oFont01) //22 - Qtde Solic
				oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.93))*nAC, "23 - Qtde Aut", oFont01) //23 – Qtde Aut

				nOldLinIni := nLinIni

				if nVolta == 1
					nV1 := 1
				Endif
		
			    nCnt := 0
                cGuiaPres := strtran(strtran(aDados[nX,2],'-',''),'.','')
                cTdsCodG  := (cCodMedGen+ "-" +cCodMatGen+ "-" +cCodTaxGen+ "-" +cCodOpmGen)
                //Verifico se tem procedimentos generico se achou olho a BQV 
                If !empty(cTdsCodG)               
	                for I :=1 To len(aDados[nX, 20])
			            if (aDados[nX, 20, I] $ cTdsCodG)
				            lAchou := .T. 
				            EXIT 
				        endIf
				    Next I
			    EndIf    
		        If (lAchou)
		            BQV->(DbSetOrder(1))
			        If (BQV->(DbSeek(xFilial('BQV') + cGuiaPres))) 
			        	 While (!BQV->(Eof()) .and.  BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == xFilial('BQV')+cGuiaPres)
			        	        nCnt++
								if Alltrim(BQV->BQV_CODPRO) $ cTdsCodG
									aDados[nX,21,nCnt] := Alltrim(BQV->BQV_DESPRO)
								endIf	
			        	     BQV->(DbSkip())
			        	 Enddo
	                EndIf
                EndIf

				If lPlsGTiss
					lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"03",lImpPrc})
				EndIf

				If lImpPrc

					For nP := nV1 To nT
						If !Empty(Alltrim(aDados[nx,19,nP]))
						
							cCodTab := ""  
 	 						cCodTab := aDados[nX, 19,nP]//AllTrim(PLSVARVINC('87','BR4', aDados[nX, 19,nP]))
 							cCodPro := aDados[nX, 20,nP]//PLSGETVINC("BTU_CDTERM", "BR8", .F. ,  ,cCodTab+aDados[nX, 20,nP],.F.    ,  aTabDup, @cCodTab)
                			cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., cCodTab,  cCodPro)
                			
                			if !lAchou
								aDados[nX, 21, nP] 	:= cDescri
							endif 
							
							oPrint:Say((nLinIni + 1298)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
							oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.03))*nAC, cCodTab/*aDados[nX, 19, nP]*/, oFont04)
							oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.07))*nAC, aDados[nX, 20, nP], oFont04)
							oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.18))*nAC, SUBSTR(aDados[nX, 21, nP],1,300), oFont01)
							oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.88))*nAC, if (aDados[nX, 22, nP]=0,"",Transform(aDados[nX, 22, nP], "@E 999")), oFont04,,,,1)
							oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.95))*nAC, getException(aDados[nX, 22, nP],aDados[nX, 23, nP],"@E 999"), oFont04,,,,1)
							nLinIni += 40
						Endif
					Next nP

				EndIf

				if nT < Len(aDados[nX, 20]).or. lImpnovo
					nV1:=nP
					lImpnovo:=.T.
				Endif

				nLinIni := nOldLinIni

		//Linha 13
				oPrint:Say((nLinIni + 1666)*nAL, (nColIni + 0020)*nAC, "Dados da Autorização", oFont01) //Dados da Autorização

		//Linha 14
				oPrint:Box((nLinIni + 1676)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1736)*nAL, (nColIni + (nColMax*0.20) - 0010)*nAC)

				oPrint:Say((nLinIni + 1696)*nAL, (nColIni + 0030)*nAC, "24 - Qtde. Diárias Adicionais Autorizadas", oFont01) //"24 - Data Provável da Admissão Hospitalar"
				oPrint:Say((nLinIni + 1728)*nAL, (nColIni + 0040)*nAC, aDados[nX, 24], oFont04)
				oPrint:Box((nLinIni + 1676)*nAL, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 1736)*nAL, (nColIni + (nColMax*0.45) - 0040)*nAC)

				oPrint:Say((nLinIni + 1696)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "25 - Tipo da Acomodação Autorizada", oFont01) //"25 - Tipo da Acomodação Autorizada"
				oPrint:Say((nLinIni + 1728)*nAL, (nColIni + (nColMax*0.21))*nAC, aDados[nX, 25], oFont04)

		//Linha 15
				oPrint:Box((nLinIni + 1746)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2058)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 1766)*nAL, (nColIni + 0030)*nAC, "26 - Justificativa da Operadora", oFont01) //"26 - Código na Operadora / CNPJ autorizado"

				nLinB := 0
				nLinB := nLinIni
				For nI := 1 To MlCount(aDados[nX, 26], 180)
					cObs := MemoLine(aDados[nX, 26], 180, nI)
					oPrint:Say((nLinB + 1798)*nAl, (nColIni + 0040)*nAC, cObs, oFont04)
					nLinB += 30
					If nI == 9
						exit
					Endif
				Next nI


		//Linha 16
				oPrint:Box((nLinIni + 2068)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2388)*nAL, (nColIni + nColMax - 0010)*nAC)
				oPrint:Say((nLinIni + 2088)*nAL, (nColIni + 0030)*nAC, "27 - Observação / Justificativa", oFont01) //"27 – Observação / Justificativa"

				nLinB := 0
				nLinB := nLinIni
				For nI := 1 To MlCount(aDados[nX, 27], 180)
					cObs := MemoLine(aDados[nX, 27], 180, nI)
					oPrint:Say((nLinB + 2120)*nAl, (nColIni + 0040)*nAC, cObs, oFont04)
					nLinB += 30
					If nI == 9
						exit
					Endif
				Next nI

		//Linha 17
				oPrint:Box((nLinIni + 2398)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2458)*nAL, (nColIni + (nColMax/3) - 0010)*nAC)
				oPrint:Say((nLinIni + 2418)*nAL, (nColIni + 0030)*nAC, "28 - Data da Solicitação", oFont01) //"28 - Data da Solicitação"
				oPrint:Say((nLinIni + 2450)*nAL, (nColIni + 0040)*nAC, IIF( ValType(aDados[nX, 28]) == "D", DtoC(aDados[nX, 28]), aDados[nX, 28]), oFont04)
				oPrint:Box((nLinIni + 2398)*nAL, (nColIni + (nColMax/3))*nAC, (nLinIni + 2458)*nAL, (nColIni + ((nColMax/3)*2) - 0010)*nAC)
				oPrint:Say((nLinIni + 2418)*nAL, (nColIni + (nColMax/3) + 0010)*nAC, "29-Assinatura do Profissional Solicitante", oFont01) //"29-Assinatura do Profissional Solicitante"
				oPrint:Box((nLinIni + 2398)*nAL, (nColIni + ((nColMax/3)*2))*nAC, (nLinIni + 2458)*nAL, (nColIni + ((nColMax/3)*3) - 0010)*nAC)
				oPrint:Say((nLinIni + 2418)*nAL, (nColIni + ((nColMax/3)*2) + 0010)*nAC, "30-Assinatura do Responsável pela Autorização", oFont01) //"30-Assinatura do Beneficiário ou Responsável"

				oPrint:EndPage()	// Finaliza a pagina

			Next nX

		enddo
	END SEQUENCE
	ErrorBlock( bError )

	If !Empty(cErro)
		cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
		MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
		cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
			"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
			"Tipos de Guias." + CRLF + CRLF + ;
			cErro
		PLSLogFil(cErro,cArq)
	EndIf

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

			oPrint:Preview()
		Endif

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcDiriaEvoºAutor  ³Microsiga         º Data ³  04/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Calcula as Diarias autorizadas ou não para a Evolução de  º±±
±±º          ³   internação                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function CalcDiriaEvo(nTipo)

	Local nDiasDiari:=0
	Local lAchouGuia:=.F.

	Default nTipo:= 1 // 1 autorizados 2 solicitador

	If !lAchouGuia
		BQV->(DbSetOrder(1))
		If BQV->(DbSeek(xFilial('BQV')+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ))
			While !BQV->(Eof()) .and.  BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
				If BQV->BQV_STATUS  $ "1,2" .and. nTipo == 1		//autorizada, parcialmente ou nao
					If BR8->( MsSeek(xFilial("BR8")+BQV->BQV_CODPAD+BQV->BQV_CODPRO) )
						If BR8->BR8_TPPROC=='4' //DIARIAS
							nDiasDiari:= BQV->BQV_QTDPRO
							lAchouGuia:=.T.
						Endif
					Endif
				Else // Não Autorizado
					IF BE4->BE4_DIASSO> 0
						nDiasDiari:=BE4->BE4_DIASSO
						lAchouGuia:=.T.
					Else
						If BR8->( MsSeek(xFilial("BR8")+BQV->BQV_CODPAD+BQV->BQV_CODPRO) )
							If BR8->BR8_TPPROC=='4' //DIARIAS
								nDiasDiari:= BQV->BQV_QTDSOL
								lAchouGuia:=.T.
							Endif
						Endif
					Endif
				Endif
				BQV->(DbSkip())
			Enddo
		Endif
	Endif


	If !lAchouGuia // IMPRESSÃO DA PRORROGAÇÃO PELA B4Q
		If nTipo == 1
			nDiasDiari:= B4Q->B4Q_QTDADA
		Else
			nDiasDiari:= B4Q->B4Q_QTDADD
		Endif
	Endif

	
	nDiasDiari:=StrZero(nDiasDiari,3)

Return(nDiasDiari)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLVERPRR
Adiciona prorrogações para exibição no portal

@author  Lucas de Azevedo Nonato
@version P11
@since   03/11/2015
/*/
//-------------------------------------------------------------------

Function PPLVERPRR(aDados)

	Local lRet := .F.
	Local cCodMedGen    := GetNewPar("MV_PLMEDPT","")
	Local cCodMatGen    := GetNewPar("MV_PLMATPT","")
	Local cCodTaxGen    := GetNewPar("MV_PLTAXPT","")
	Local cCodOpmGen    := GetNewPar("MV_PLOPMPT","")
	Local cTdsCodG      := ""
	Local cDescri       := ""

	aDados[1][34] := {}
	aDados[1][35] := {}
	aDados[1][36] := {}
	aDados[1][37] := {}
	aDados[1][38] := {}

	cTdsCodG:=(cCodMedGen+ "-" +cCodMatGen+ "-" +cCodTaxGen+ "-" +cCodOpmGen)

	dbSelectArea("BQV")
	dbSetOrder(1)
	dbGoTop()
	While !BQV->(EOF())

		If BQV->(BQV_FILIAL + BQV_CODOPE +"."+ BQV_ANOINT +"."+ BQV_MESINT +"-"+ BQV_NUMINT) == xFilial("BQV") + aDados[1][2]

			If ALLTRIM(BQV->(BQV_CODPRO)) $ cTdsCodG 
				cDescri:= BQV->BQV_DESPRO
			EndIf
			
			aAdd(aDados[1][34], AllTrim(BQV->BQV_CODPAD))
			aAdd(aDados[1][35], AllTrim(BQV->BQV_CODPRO))
			aAdd(aDados[1][36], If(!Empty(cDescri),cDescri, AllTrim(BQV->BQV_DESPRO)))
			aAdd(aDados[1][37], BQV->BQV_QTDSOL)
			aAdd(aDados[1][38], BQV->BQV_QTDPRO)
			lRet := .T.
		EndIf
		dbSkip()
	EndDo
	BQV->(dbCloseArea())

Return lRet
//-----------------------------------------------------------------------------------------
Static Function fLogoEmp(cLogo, cTipo, cLogoGH)

	Local cStartPath	:= GetSrvProfString("STARTPATH","")

	Default cTipo	:= "1"
	Default cLogoGH := ""

	If ValType(cLogoGH) <> "U" .And. !Empty(cLogoGH) .And. File(cLogoGH) //logo a partir do campo do Gestao Hospitalar
		cLogo := cLogoGH
	Else // Logotipo da Empresa
		If cTipo == "1"
			cLogo := cStartPath + "\LGRL" + FWCompany() + FWCodFil() + ".BMP"	// Empresa+Filial
		Else
			cLogo := cStartPath + "\LGRL" + FWCompany() + ".BMP"				// Empresa
		EndIf
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSSOLINI  ³ Autor ³ Thiago Ribas     ³ Data ³ 17.12.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS 3 Guia Odontológica - Solicitação)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Imprime sem seleção de impressora
			 ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±³          ³ cPathRelW - caminho onde será gravado o relatório	       ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSSOLINI(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW) //Guia Odontológica - Solicitação
	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local cFileLogo
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
	LOCAL cRel      := "TRTODONT"
	LOCAL cPathSrvJ := GETMV("MV_RELT")
	Local lRet 		:= .T.
	Local oPrint := NIL
	Local nAL		:= 0.25
	Local nAC		:= 0.24
	Local nEspGrid  := 0
	Local nLinVert  := 0
	Local nVert     := 0
	Local cFileName := NIL
	Local cFile     := GetNewPar("MV_RELT",'\SPOOL\')+'PLSR421N.HTM'

	Default lGerTXT := .F.
	Default nLayout := 2
	Default cLogoGH := ''
	Default lWeb	:= .F.
	Default cPathRelW 	:= ""
	Default aDados  := { { ;
		"123456",; 				 //1 - Registro ANS
	"12345678901234567892",; //2 - Nº Guia no Prestador
	"12345678901234567892",; //3 - Número da Guia Principal de Tratamento Odontológico
	"12345678901234567892",; //4 - Número da Guia Atribuído pela Operadora
	Replicate("M",70),;      //5 - Nome
	Replicate("M",20),;		 //6 - Número da Carteira
	"",;			         //7 - Dente
	"",;					 //8 - Situação Dentária Inicial
	"",;   		 			 //9 - Sinais Clínicos de Doença Periodontal
	"",;				 	 //10 - Alteração dos Tecidos Moles
	Replicate("M",500),;  	 //11 - Observação/Justificativa
	CtoD("30/12/07"),;   	 //12 - Local e Data
	"",;			     	 //13 - Assinatura do Cirurgião-Dentista
	CtoD("30/12/07"),; 		 //14 - Local e Data
	"",;					 //15 - Assinatura do Beneficiário/Responsável
	CtoD("30/12/07")} } 	 //16 - Local, Data e Carimbo da Empresa

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2150
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ, .T.,, @oPrint,,, .F.,.F.)

	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:lServer := lWeb

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:cPathPDF := cPathSrvJ

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
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
		lImpnovo:=(oPrint:nModalResult == 1)
	EndIf

	If oPrint:Cprinter == "PDF" .OR. lWeb
		nLinIni := 150
		nColMax -= 15
	Else
		nLinIni := 080
	Endif

	nColIni := 080

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0 .Or. (!lWeb .And. !lImpNovo)
			Loop
		EndIf

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
			oPrint:SayBitmap((nLinIni + 0040)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
		EndIf

		if( isInCallStack( "PLIMPGUIB" ) )
			oPrint:Say((nLinIni + 0080)*nAL, (nColIni + (nColMax*0.3))*nAC,STR0391, oFont02n,,,, 2)  //"GUIA TRATAMENTO ODONTOLÓGICO - SITUAÇÃO INICIAL"
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.76))*nAC, "2 - "+STR0002, oFont01) //"Nº"
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.79))*nAC, aDados[nX, 02], oFont03n)

			oPrint:Box((nLinIni + 0175)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0269)*nAL, (nColIni + (nColMax*0.1) - 0010)*nAC)
			oPrint:Say((nLinIni + 0210)*nAL, (nColIni + 0020)*nAC, "1 - " + STR0003, oFont01) //"Registro ANS"
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + 0030)*nAC, aDados[nX, 01], oFont04)

			oPrint:Box((nLinIni + 0175)*nAL, (nColIni + (nColMax*0.1))*nAC, (nLinIni + 0269)*nAL , (nColIni + (nColMax*0.40) - 0010)*nAC)
			oPrint:Say((nLinIni + 0210)*nAL, (nColIni + (nColMax*0.1) + 0010)*nAC, "3 - " + STR0472, oFont01) //"Número da Guia Principal de Tratamento Odontológico"
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + (nColMax*0.1) + 0020)*nAC, replicate( "|__",20 ) + "|", oFont04)

			oPrint:Box((nLinIni + 0175)*nAL, (nColIni + (nColMax*0.40))*nAC, (nLinIni + 0269)*nAL , (nColIni + (nColMax*0.72) - 0010)*nAC)
			oPrint:Say((nLinIni + 0210)*nAL, (nColIni + (nColMax*0.40) + 0020)*nAC, "4 - " + STR0473, oFont01) //"Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0248)*nAL, (nColIni + (nColMax*0.40) + 0030)*nAC, replicate( "|__",20 ) + "|", oFont04)

			oPrint:Say((nLinIni + 0305)*nAL, (nColIni + 0010)*nAC, STR0005, oFont01) //"Dados do Beneficiário"

			oPrint:Box((nLinIni + 0320)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0398)*nAL, (nColIni + 1700 - 0010)*nAC)
			oPrint:Say((nLinIni + 0355)*nAL, (nColIni + 0020)*nAC, "5 - "+STR0009, oFont01) //"Nome"

			oPrint:Box((nLinIni + 0320)*nAL, (nColIni + 3200)*nAC, (nLinIni + 0398)*nAL, (nColIni + 1700)*nAC)
			oPrint:Say((nLinIni + 0355)*nAL, (nColIni + 1710)*nAC, "6 - " + STR0006, oFont01) //"Número da Carteira"
			oPrint:Say((nLinIni + 0385)*nAL, (nColIni + 1710)*nAC, replicate( "|__",20 ) + "|", oFont04)

			oPrint:Say((nLinIni + 0437)*nAL, (nColIni + 0010)*nAC, STR0340, oFont01) //"Situação Inicial"

			//Monta GRID e informações da situação inicial
			//Início
			nEspGrid := 515

			oPrint:Box((nLinIni + 0455)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1147)*nAL, (nColIni + 0240)*nAC)
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0340, oFont04) //"Situação Inicial"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0341, oFont04) //"Permanentes"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0342, oFont04) //"Decíduos"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0342, oFont04) //"Decíduos"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0341, oFont04) //"Permanentes"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0340, oFont04) //"Situação Inicial"*/

			nCol  :=245
			nColf :=350
			nLinVert := 455

			For nI:=1 to 16
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)

				nCol     += 0100
				nColf 	 += 0100
				nLinVert := 0455
			Next nI

			nCol  := 0268
			nVert := 0640
			aNum1:={"18","17","16","15","14","13","12","11","21","22","23","24","25","26","27","28"}

			For nI:=1 to Len(aNum1)
				oPrint:Say((nLinIni + 0640)*nAL, (nColIni + nCol)*nAC, aNum1[nI], oFont03n)
				nCol  +=0100
			Next nI

			nVert += 0120
			nCol  := 0570
			aNum2:={"55","54","53","52","51","61","62","63","64","65"}

			For nI:=1 to Len(aNum2)
				oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum2[nI], oFont03n)
				nCol  +=0100
			Next nI

			nVert += 0110
			nCol  := 0570
			aNum3:={"85","84","83","82","81","71","72","73","74","75"}

			For nI:=1 to Len(aNum3)
				oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum3[nI], oFont03n)
				nCol  +=0100
			Next nI

			nVert += 0115
			nCol  := 0268
			aNum4:={"48","47","46","45","44","43","42","41","31","32","33","34","35","36","37","38"}

			For nI:=1 to Len(aNum4)
				oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum4[nI], oFont03n)
				nCol  +=0100
			Next nI
			//FIM

			//Monta os quadros referente a parte pertencente
			//a LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL

			oPrint:Say((nLinIni + 0465)*nAL, (nColIni + 1910)*nAC, STR0347, oFont01)	 //"LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL"

			//Montagem do quadro Sinais Clínicos de doença periodontal ?
			//INÍCIO
			oPrint:Box((nLinIni + 0485)*nAL, (nColIni + 2250)*nAC, (nLinIni + 0650)*nAL, (nColIni + 2770)*nAC)

			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 2290)*nAC, "9 - " + STR0343, oFont01) //"Sinais Clínicos de doença periodontal ?"

			oPrint:Line((nLinIni + 0560)*nAL,(nColIni + 2320)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2320)*nAC)
			oPrint:Line((nLinIni + 0600)*nAL,(nColIni + 2320)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2380)*nAC)
			oPrint:Line((nLinIni + 0560)*nAL,(nColIni + 2380)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2380)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL, (nColIni + 2400)*nAC, STR0344, oFont04)  //"Sim"
			//oPrint:Say((nLinIni + 0560)*nAL, (nColIni + 2335)*nAC, IIf(((aDados[nX, 9]) =="1"),"X",""), oFont04)

			oPrint:Line((nLinIni + 0560)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2550)*nAC)
			oPrint:Line((nLinIni + 0600)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2610)*nAC)
			oPrint:Line((nLinIni + 0560)*nAL, (nColIni + 2610)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2610)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL,  (nColIni + 2630)*nAC, STR0345, oFont04) //"Não"
			//oPrint:Say((nLinIni + 0560)*nAL,  (nColIni + 2560)*nAC, IIf (((aDados[nX, 9]) == "0"),"X",""), oFont04)
			//FIM

			//Montagem do quadro alteração dos Tecidos Moles
			//INÍCIO
			oPrint:Box((nLinIni + 0965)*nAL, (nColIni + 2250)*nAC, (nLinIni + 0800)*nAL, (nColIni + 2770)*nAC)

			oPrint:Say((nLinIni + 0838)*nAL, (nColIni + 2290)*nAC, "10 - "+STR0346, oFont01) //"Alteração dos Tecidos Moles ?"

			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2320)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2320)*nAC)
			oPrint:Line((nLinIni + 0920)*nAL, (nColIni + 2320)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2380)*nAC)
			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2380)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2380)*nAC)
			oPrint:Say((nLinIni + 0910)*nAL, (nColIni + 2400)*nAC, STR0344, oFont04)  //"Sim"
			//oPrint:Say((nLinIni + 0880)*nAL, (nColIni + 2335)*nAC, IIf(((aDados[nX, 10]) =="1"),"X",""), oFont04)

			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2550)*nAC,( nLinIni + 0920)*nAL, (nColIni + 2550)*nAC)
			oPrint:Line((nLinIni + 0920)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2610)*nAC)
			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2610)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2610)*nAC)
			oPrint:Say((nLinIni + 0910)*nAL, (nColIni + 2630)*nAC, STR0345, oFont04) //"Não"
			//oPrint:Say((nLinIni + 0880)*nAL, (nColIni + 2560)*nAC, IIf (((aDados[nX, 10]) =="0"),"X",""), oFont04)
			//FIM

			//Montagem do quadro SITUAÇÃO INICIAL
			//INÍCIO
			oPrint:Box((nLinIni + 0560)*nAL, (nColIni + 1910)*nAC, (nLinIni + 0900)*nAL, (nColIni + 2220)*nAC)
			oPrint:Say((nLinIni + 0608)*nAL, (nColIni + 1960)*nAC, "8 - " + STR0340, oFont01) //"SITUAÇÃO INICIAL"
			oPrint:Say((nLinIni + 0658)*nAL, (nColIni + 1960)*nAC, STR0348, oFont01) //"A - Ausente"
			oPrint:Say((nLinIni + 0708)*nAL, (nColIni + 1960)*nAC, STR0349, oFont01) //"E - Extração Indicada"
			oPrint:Say((nLinIni + 0758)*nAL, (nColIni + 1960)*nAC, STR0350, oFont01) //"H - Hígido"
			oPrint:Say((nLinIni + 0808)*nAL, (nColIni + 1960)*nAC, STR0351, oFont01) //"C - Cariado"
			oPrint:Say((nLinIni + 0858)*nAL, (nColIni + 1960)*nAC, STR0352, oFont01) //"R - Restaurado"
			//FIM

			oPrint:Box((nLinIni + 1180)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1810)*nAL, (nColIni + 3320)*nAC)
			oPrint:Say((nLinIni + 1210)*nAL, (nColIni + 0020)*nAC, "11 - " + STR0474, oFont01) //"Observação / Justificativa"

			nLin := 1270

			For nI := 1 To MlCount(aDados[nX, 11], 130)
				cObs := MemoLine(aDados[nX, 11], 130, nI)
				oPrint:Say((nLinIni + nLin)*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
				nLin += 50
			Next nI

			//Início da montagem  dos campos inferiores.
			oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1980)*nAL, (nColIni + 0850)*nAC)
			oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0020)*nAC, "12 - " + STR0475, oFont01) //"Local e Data"
			oPrint:Say((nLinIni + 1960)*nAL, (nColIni + 00450)*nAC, "|__|__|/|__|__|/|__|__|__|__|", oFont04)
			//oPrint:Say((nLinIni + 2060)*nAL, (nColIni + 0030)*nAC, "|__|__|/|__|__|/|__|__|__|__|", oFont04,,,,1)

			oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 0870)*nAC, (nLinIni + 1980)*nAL, (nColIni + 1710)*nAC)
			oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0880)*nAC, "13 - " + STR0428, oFont01) //"Assinatura do Cirurgião-Dentista"

			oPrint:Box((nLinIni + 1990)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2140)*nAL, (nColIni + 0850)*nAC)
			oPrint:Say((nLinIni + 2020)*nAL, (nColIni + 0020)*nAC, "14 - "+STR0475, oFont01) //"Local e Data"
			oPrint:Say((nLinIni + 2120)*nAL, (nColIni + 00450)*nAC, "|__|__|/|__|__|/|__|__|__|__|", oFont04)
			//oPrint:Say((nLinIni + 2140)*nAL, (nColIni + 0030)*nAC, "|__|__|/|__|__|/|__|__|__|__|", oFont04,,,,1)

			oPrint:Box((nLinIni + 1990)*nAL, (nColIni + 0870)*nAC, (nLinIni + 2140)*nAL, (nColIni + 1710)*nAC)
			oPrint:Say((nLinIni + 2020)*nAL, (nColIni + 0880)*nAC, "15 - " + STR0476, oFont01) //"Assinatura do Beneficiário / Responsável"

			oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 1730)*nAC, (nLinIni + 2140)*nAL, (nColIni + 3320)*nAC)
			oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 1740)*nAC, "16 - " + STR0477, oFont01) //"Local, Data e Carimbo da Empresa"
			//oPrint:Say((nLinIni + 2120)*nAL, (nColIni + 3100)*nAC, "|__|__|/|__|__|/|__|__|__|__|", oFont04)
			oPrint:Say((nLinIni + 2120)*nAL, (nColIni + (nColMax*0.70) + 0020)*nAC, "|__|__|/|__|__|/|__|__|__|__|", oFont04,,,,1)
			//FIM
		else
			oPrint:Say((nLinIni + 0080)*nAL, (nColIni + (nColMax*0.3))*nAC,STR0391, oFont02n,,,, 2)  //"GUIA TRATAMENTO ODONTOLÓGICO - SITUAÇÃO INICIAL"
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.76))*nAC, "2 - "+STR0002, oFont01) //"Nº"
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.79))*nAC, aDados[nX, 02], oFont03n)

			oPrint:Box((nLinIni + 0175)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0269)*nAL, (nColIni + (nColMax*0.1) - 0010)*nAC)
			oPrint:Say((nLinIni + 0210)*nAL, (nColIni + 0020)*nAC, "1 - " + STR0003, oFont01) //"Registro ANS"
			oPrint:Say((nLinIni + 0243)*nAL, (nColIni + 0030)*nAC, aDados[nX, 01], oFont04)

			oPrint:Box((nLinIni + 0175)*nAL, (nColIni + (nColMax*0.1))*nAC, (nLinIni + 0269)*nAL , (nColIni + (nColMax*0.40) - 0010)*nAC)
			oPrint:Say((nLinIni + 0210)*nAL, (nColIni + (nColMax*0.1) + 0010)*nAC, "3 - " + STR0472, oFont01) //"Número da Guia Principal de Tratamento Odontológico"
			oPrint:Say((nLinIni + 0243)*nAL, (nColIni + (nColMax*0.1) + 0020)*nAC, aDados[nX, 03], oFont04)

			oPrint:Box((nLinIni + 0175)*nAL, (nColIni + (nColMax*0.40))*nAC, (nLinIni + 0269)*nAL , (nColIni + (nColMax*0.72) - 0010)*nAC)
			oPrint:Say((nLinIni + 0210)*nAL, (nColIni + (nColMax*0.40) + 0020)*nAC, "4 - " + STR0473, oFont01) //"Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0243)*nAL, (nColIni + (nColMax*0.40) + 0030)*nAC, aDados[nX, 04], oFont04)

			oPrint:Say((nLinIni + 0305)*nAL, (nColIni + 0010)*nAC, STR0005, oFont01) //"Dados do Beneficiário"

			oPrint:Box((nLinIni + 0320)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0398)*nAL, (nColIni + 1700 - 0010)*nAC)
			oPrint:Say((nLinIni + 0355)*nAL, (nColIni + 0020)*nAC, "5 - "+STR0009, oFont01) //"Nome"
			oPrint:Say((nLinIni + 0385)*nAL, (nColIni + 0030)*nAC, SUBSTR(aDados[nX, 05],1,50), oFont04)

			oPrint:Box((nLinIni + 0320)*nAL, (nColIni + 3200)*nAC, (nLinIni + 0398)*nAL, (nColIni + 1700)*nAC)
			oPrint:Say((nLinIni + 0355)*nAL, (nColIni + 1710)*nAC, "6 - " + STR0006, oFont01) //"Número da Carteira"
			oPrint:Say((nLinIni + 0385)*nAL, (nColIni + 1710)*nAC, aDados[nX, 06], oFont04)

			oPrint:Say((nLinIni + 0437)*nAL, (nColIni + 0010)*nAC, STR0340, oFont01) //"Situação Inicial"

			//Monta GRID e informações da situação inicial
			//Início
			nEspGrid := 515

			oPrint:Box((nLinIni + 0455)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1147)*nAL, (nColIni + 0240)*nAC)
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0340, oFont04) //"Situação Inicial"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0341, oFont04) //"Permanentes"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0342, oFont04) //"Decíduos"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0342, oFont04) //"Decíduos"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0341, oFont04) //"Permanentes"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)

			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, STR0340, oFont04) //"Situação Inicial"*/

			nCol  :=245
			nColf :=350
			nLinVert := 455

			For nI:=1 to 16
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115

				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)

				nCol     += 0100
				nColf 	 += 0100
				nLinVert := 0455
			Next nI

			nCol  := 0268
			nVert := 0640
			aNum1:={"18","17","16","15","14","13","12","11","21","22","23","24","25","26","27","28"}

			For nI:=1 to Len(aNum1)
				oPrint:Say((nLinIni + 0640)*nAL, (nColIni + nCol)*nAC, aNum1[nI], oFont03n)
				nCol  +=0100
			Next nI

			nVert += 0120
			nCol  := 0570
			aNum2:={"55","54","53","52","51","61","62","63","64","65"}

			For nI:=1 to Len(aNum2)
				oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum2[nI], oFont03n)
				nCol  +=0100
			Next nI

			nVert += 0110
			nCol  := 0570
			aNum3:={"85","84","83","82","81","71","72","73","74","75"}

			For nI:=1 to Len(aNum3)
				oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum3[nI], oFont03n)
				nCol  +=0100
			Next nI

			nVert += 0115
			nCol  := 0268
			aNum4:={"48","47","46","45","44","43","42","41","31","32","33","34","35","36","37","38"}

			For nI:=1 to Len(aNum4)
				oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum4[nI], oFont03n)
				nCol  +=0100
			Next nI
			//FIM

			//Monta os quadros referente a parte pertencente
			//a LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL

			oPrint:Say((nLinIni + 0465)*nAL, (nColIni + 1910)*nAC, STR0347, oFont01)	 //"LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL"

			//Montagem do quadro Sinais Clínicos de doença periodontal ?
			//INÍCIO
			oPrint:Box((nLinIni + 0485)*nAL, (nColIni + 2250)*nAC, (nLinIni + 0650)*nAL, (nColIni + 2770)*nAC)

			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 2290)*nAC, "9 - " + STR0343, oFont01) //"Sinais Clínicos de doença periodontal ?"

			oPrint:Line((nLinIni + 0560)*nAL,(nColIni + 2320)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2320)*nAC)
			oPrint:Line((nLinIni + 0600)*nAL,(nColIni + 2320)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2380)*nAC)
			oPrint:Line((nLinIni + 0560)*nAL,(nColIni + 2380)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2380)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL, (nColIni + 2400)*nAC, STR0344, oFont04)  //"Sim"
			oPrint:Say((nLinIni + 0560)*nAL, (nColIni + 2335)*nAC, IIf(((aDados[nX, 9]) =="1"),"X",""), oFont04)

			oPrint:Line((nLinIni + 0560)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2550)*nAC)
			oPrint:Line((nLinIni + 0600)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2610)*nAC)
			oPrint:Line((nLinIni + 0560)*nAL, (nColIni + 2610)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2610)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL,  (nColIni + 2630)*nAC, STR0345, oFont04) //"Não"
			oPrint:Say((nLinIni + 0560)*nAL,  (nColIni + 2560)*nAC, IIf (((aDados[nX, 9]) == "0"),"X",""), oFont04)
			//FIM

			//Montagem do quadro alteração dos Tecidos Moles
			//INÍCIO
			oPrint:Box((nLinIni + 0965)*nAL, (nColIni + 2250)*nAC, (nLinIni + 0800)*nAL, (nColIni + 2770)*nAC)

			oPrint:Say((nLinIni + 0838)*nAL, (nColIni + 2290)*nAC, "10 - "+STR0346, oFont01) //"Alteração dos Tecidos Moles ?"

			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2320)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2320)*nAC)
			oPrint:Line((nLinIni + 0920)*nAL, (nColIni + 2320)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2380)*nAC)
			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2380)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2380)*nAC)
			oPrint:Say((nLinIni + 0910)*nAL, (nColIni + 2400)*nAC, STR0344, oFont04)  //"Sim"
			oPrint:Say((nLinIni + 0880)*nAL, (nColIni + 2335)*nAC, IIf(((aDados[nX, 10]) =="1"),"X",""), oFont04)

			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2550)*nAC,( nLinIni + 0920)*nAL, (nColIni + 2550)*nAC)
			oPrint:Line((nLinIni + 0920)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2610)*nAC)
			oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2610)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2610)*nAC)
			oPrint:Say((nLinIni + 0910)*nAL, (nColIni + 2630)*nAC, STR0345, oFont04) //"Não"
			oPrint:Say((nLinIni + 0880)*nAL, (nColIni + 2560)*nAC, IIf (((aDados[nX, 10]) =="0"),"X",""), oFont04)
			//FIM

			//Montagem do quadro SITUAÇÃO INICIAL
			//INÍCIO
			oPrint:Box((nLinIni + 0560)*nAL, (nColIni + 1910)*nAC, (nLinIni + 0900)*nAL, (nColIni + 2220)*nAC)
			oPrint:Say((nLinIni + 0608)*nAL, (nColIni + 1960)*nAC, "8 - " + STR0340, oFont01) //"SITUAÇÃO INICIAL"
			oPrint:Say((nLinIni + 0658)*nAL, (nColIni + 1960)*nAC, STR0348, oFont01) //"A - Ausente"
			oPrint:Say((nLinIni + 0708)*nAL, (nColIni + 1960)*nAC, STR0349, oFont01) //"E - Extração Indicada"
			oPrint:Say((nLinIni + 0758)*nAL, (nColIni + 1960)*nAC, STR0350, oFont01) //"H - Hígido"
			oPrint:Say((nLinIni + 0808)*nAL, (nColIni + 1960)*nAC, STR0351, oFont01) //"C - Cariado"
			oPrint:Say((nLinIni + 0858)*nAL, (nColIni + 1960)*nAC, STR0352, oFont01) //"R - Restaurado"
			//FIM

			oPrint:Box((nLinIni + 1180)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1810)*nAL, (nColIni + 3320)*nAC)
			oPrint:Say((nLinIni + 1210)*nAL, (nColIni + 0020)*nAC, "11 - " + STR0474, oFont01) //"Observação / Justificativa"

			nLin := 1270

			For nI := 1 To MlCount(aDados[nX, 11], 130)
				cObs := MemoLine(aDados[nX, 11], 130, nI)
				oPrint:Say((nLinIni + nLin)*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
				nLin += 50
			Next nI

			//Início da montagem  dos campos inferiores.
			oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1980)*nAL, (nColIni + 0850)*nAC)
			oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0020)*nAC, "12 - " + STR0475, oFont01) //"Local e Data"
			oPrint:Say((nLinIni + 1960)*nAL, (nColIni + 00630)*nAC, DtoC(aDados[nX, 12]), oFont04)

			oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 0870)*nAC, (nLinIni + 1980)*nAL, (nColIni + 1710)*nAC)
			oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0880)*nAC, "13 - " + STR0428, oFont01) //"Assinatura do Cirurgião-Dentista"

			oPrint:Box((nLinIni + 1990)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2140)*nAL, (nColIni + 0850)*nAC)
			oPrint:Say((nLinIni + 2020)*nAL, (nColIni + 0020)*nAC, "14 - "+STR0475, oFont01) //"Local e Data"
			oPrint:Say((nLinIni + 2120)*nAL, (nColIni + 00630)*nAC, DtoC(aDados[nX, 14]), oFont04)

			oPrint:Box((nLinIni + 1990)*nAL, (nColIni + 0870)*nAC, (nLinIni + 2140)*nAL, (nColIni + 1710)*nAC)
			oPrint:Say((nLinIni + 2020)*nAL, (nColIni + 0880)*nAC, "15 - " + STR0476, oFont01) //"Assinatura do Beneficiário / Responsável"

			oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 1730)*nAC, (nLinIni + 2140)*nAL, (nColIni + 3320)*nAC)
			oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 1740)*nAC, "16 - " + STR0477, oFont01) //"Local, Data e Carimbo da Empresa"
			oPrint:Say((nLinIni + 2120)*nAL, (nColIni + 3100)*nAC, DtoC(aDados[nX, 16]), oFont04)
			//FIM
		endIf
		oPrint:EndPage()	// Finaliza a pagina

	Next nX

	If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:Print()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		if lWeb
			oPrint:Print()
		else
			oPrint:Preview()
		endif
	EndIf
Return { lRet,cFile,cFileName }

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSTISCOMP
Impressao da Guia de Comprovante Presencial

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     31/10/2016
/*/
//------------------------------------------------------------------------------------------
Function PLSTISCOMP( aDados,nLayout,cLogoGH,lWeb,cPathRelW,lUnicaImp,lGerTXT )
	Local nLinMax
	Local nColMax
	Local nLinIni		:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni		:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    	:=  0
	Local cFileLogo
	Local nOldLinIni
	Local nI, nJ, nX
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local oFont05
	Local lImpNovo		:= .T.
	Local nAte 			:= 0
	Local nIni			:= 0
	Local lProrrog
	Local cFileName  	:= "compres" + lower( criaTrab( NIL,.F. ) )
	Local cPathSrvJ 	:= getMV( "MV_RELT" )
	local cNumPres		:= getMV( "MV_TISSGCP" )

	Default lGerTXT 	:= .F.
	Default lWeb 		:= .F.
	Default nLayout 	:= 2
	Default cLogoGH 	:= ''
	Default aDados := { { ;
		"123456",; 							//1 - Registro ANS
	"12345678901234567890",;			//2 – Número da Guia no Prestador
	"",; 								//3 - Código na Operadora
	Replicate( " ",70 ),;				//4 - Nome do Contratado
	"",; 								//5 – Código CNES
	Replicate( " ",70 ),;				//6 - Nome do profissional executante
	"",;								//7 - Conseho Profissional
	"",;	 							//8 - Numero no conselho
	"",; 								//9 - UF
	"",; 								//10 - Codigo CBO
	{ CToD( "   /   /   " ) },;			//11 - Data do atendimento
	{ "" },;							//12 - Numero da carteira
	{ Replicate( " ",70 ) },;			//13 - Nome do beneficiario
	{ "" },;							//14 - Numero da guia principal
	{ "" },;							//15 - Assinatura
	CToD( "   /   /   " ),;				//16 - Data
	"" } }								//17 - Assinatura do contratado

	if ( lWeb )
		cPathSrvJ := cPathRelW
		cFileName := cFileName + ".pdf"
	endIf

	oPrint := FWMSPrinter():New( cFileName,,.F.,cPathSrvJ,.T.,,,,,.F.,, )

	if ( lWeb )
		oPrint:lServer := lWeb
	endIf

	oPrint:SetLandscape()		// Modo paisagem

	if ( lWeb )
		oPrint:setDevice( IMP_PDF )
	endIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Setup()

	If oPrint:nPaperSize  == 9 // Papél A4
		nLinMax	:= 570
		nColMax	:= 820
		nLayout 	:= 2
		oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Elseif oPrint:nPaperSize == 1 // Papel Carta
		nLinMax	:= 570
		nColMax	:= 820
		nLayout 	:= 3
		oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		nLinMax	:= 570
		nColMax	:= 820
		nLayout 	:= 1
		oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Endif

	For nX := 1 To Len( aDados )
		nAte := 0
		nIni := 1

		If Len( aDados[ nX ] ) == 0
			Loop
		EndIf

		If lUnicaImp
			If nX <= Len( aDados )
				lImpNovo := .T.
			EndIf
		EndIf

		While lImpNovo
			lImpNovo := .F.
			nAte += 25

			nLinIni := 010
			nColIni := 005
			nColA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap(nLinIni + 0015, nColIni + 0015, cFileLogo, 060, 040) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			if( isInCallStack( "PLIMPGUIB" ) )
				//"ANEXO DE OUTRAS DESPESAS"
				oPrint:Say(nLinIni + 0030, nColIni + (nColMax * 0.40) , "GUIA COMPROVANTE PRESENCIAL", oFont02n,,,,2)

				//"1 - Registro ANS"
				oPrint:Box(nLinIni + 0070, nColIni + 0020, nLinIni + 0100, nColIni + (nColMax*0.14))
				oPrint:Say(nLinIni + 0080, nColIni + 0030, "1 - Registro ANS", oFont01)
				oPrint:Say(nLinIni + 0093, nColIni + 0030, aDados[ nX,01 ] /*replicate( "|__",6 ) + "|"*/, oFont04)

				oPrint:Say(nLinIni + 0030, nColIni + (nColMax * 0.78), "2- Nº Guia no Prestador", oFont01) //2- Nº Guia no Prestador
				oPrint:Say(nLinIni + 0030, nColIni + (nColMax * 0.86) , cNumPres /*"12345678901234567890"*/, oFont02n,,,,2)

				//--< Controle de numeracao de impressao >---
				begin sequence
					cNumPres := soma1( cNumPres )
					putMV( "MV_TISSGCP",cNumPres )
				end sequence

				//Linha cinza
				AddTBrush(oPrint,nLinIni + 0105, nColIni + (nColMax * 0.02432), nLinIni + 0115, nColIni + nColMax - 0010)

				//Dados do Contratado Executante
				oPrint:Say(nLinIni + 0110, nColIni + 0020, "Dados do Contratado Executante", oFont01)

				//3 - Código na Operadora
				oPrint:Box(nLinIni + 0120, nColIni + 0020, nLinIni + 0150, nColIni + (nColMax*0.21) )
				oPrint:Say(nLinIni + 0130, nColIni + 0030, "3 - Código na Operadora", oFont01)
				oPrint:Say(nLinIni + 0143, nColIni + 0030, replicate( "|__",14 ) + "|", oFont04)

				//4 - Nome do Contratado
				oPrint:Box(nLinIni + 0120, nColIni + (nColMax * 0.22), nLinIni + 0150, nColIni + (nColMax*0.87) )
				oPrint:Say(nLinIni + 0130, nColIni + (nColMax * 0.22) + 0010, "4 - Nome do Contratado", oFont01)
				oPrint:Say(nLinIni + 0140, nColIni + (nColMax * 0.22) + 0020, aDados[nX, 04], oFont04)

				//5 – Código CNES
				oPrint:Box(nLinIni + 0120, nColIni + (nColMax * 0.88), nLinIni + 0150, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0130, nColIni + (nColMax * 0.88) + 0010, "5 - Código CNES", oFont01)
				oPrint:Say(nLinIni + 0143, nColIni + (nColMax * 0.88) + 0005, replicate( "|__",7 ) + "|", oFont04)

				//6 - Nome do Profissional Executante
				oPrint:Box(nLinIni + 0155, nColIni + 0020, nLinIni + 0185, nColIni + (nColMax*0.50) )
				oPrint:Say(nLinIni + 0165, nColIni + 0030, "6 - Nome do Profissional Executante", oFont01)

				//7 - Conselho Profissional
				oPrint:Box(nLinIni + 155, nColIni + (nColMax * 0.51), nLinIni + 185, nColIni + (nColMax*0.60) )
				oPrint:Say(nLinIni + 165, nColIni + (nColMax * 0.51)+ 0010, "7 - Conselho", oFont01)
				oPrint:Say(nLinIni + 170, nColIni + (nColMax * 0.51)+ 0010, "Profissional", oFont01)
				oPrint:Say(nLinIni + 180, nColIni + (nColMax * 0.51)+ 0025, replicate( "|__",2 ) + "|", oFont04)

				//8 - Numero no conselho
				oPrint:Box(nLinIni + 155, nColIni + (nColMax * 0.61), nLinIni + 185, nColIni + (nColMax*0.81) )
				oPrint:Say(nLinIni + 165, nColIni + (nColMax * 0.61)+ 0010, "8 - Numero no conselho", oFont01)
				oPrint:Say(nLinIni + 180, nColIni + (nColMax * 0.61)+ 0010, replicate( "|__",15 ) + "|", oFont04)

				//9 - UF
				oPrint:Box(nLinIni + 155, nColIni + (nColMax * 0.82), nLinIni + 185, nColIni + (nColMax*0.87) )
				oPrint:Say(nLinIni + 165, nColIni + (nColMax * 0.82)+ 0010, "9 - UF", oFont01)
				oPrint:Say(nLinIni + 180, nColIni + (nColMax * 0.82)+ 0010, replicate( "|__",2 ) + "|", oFont04)

				//10 - Código CBO
				oPrint:Box(nLinIni + 155, nColIni + (nColMax * 0.88), nLinIni + 185, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 165, nColIni + (nColMax * 0.88) + 0010, "10 - Código CBO", oFont01)
				oPrint:Say(nLinIni + 180, nColIni + (nColMax * 0.88) + 0015, replicate( "|__",6 ) + "|", oFont04)

				//Linha cinza
				AddTBrush(oPrint, nLinIni + 0192, nColIni + (nColMax * 0.02432), nLinIni + 0166, nColIni + nColMax - 0010)

				//Beneficiários
				oPrint:Say(nLinIni + 0197, nColIni + (nColMax * 0.02432), "Beneficiários", oFont01)

				//Box da "Beneficiários"
				oPrint:Box(nLinIni + 0207, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.90) , nColIni + nColMax - 0010)

				//11 - Data do atendimento
				oPrint:Say( nLinIni + 0212,nColIni + (nColMax * 0.025) + 008,"11 - Data do atendimento",oFont01 )

				//12 - Número da carteira
				oPrint:Say( nLinIni + 0212,nColIni + (nColMax * 0.150),"12 - Número da carteira",oFont01 )

				//13 - Nome do Beneficiário
				oPrint:Say( nLinIni + 0212,nColIni + (nColMax * 0.400),"13 - Nome do Beneficiário",oFont01 )

				//14 - Número da Guia Principal
				oPrint:Say( nLinIni + 0212,nColIni + (nColMax * 0.600),"14 - Número da Guia Principal",oFont01 )

				//15 - Assinatura
				oPrint:Say( nLinIni + 0212,nColIni + (nColMax * 0.850),"15 - Assinatura",oFont01 )

				nOldLinIni := nLinIni

				For nI := nIni To nAte
					//11 - Data do atendimento
					oPrint:Say( nLinIni + 0224,nColIni + (nColMax * 0.025),strZero( nI,2 ) + "-",oFont01 )
					oPrint:Say( nLinIni + 0225,nColIni + (nColMax * 0.025) + 008, "|__|__|/|__|__|/|__|__|__|__|", oFont04)

					//12 - Número da carteira
					oPrint:Say( nLinIni + 0225,nColIni + (nColMax * 0.150), replicate( "|__",20 ) + "|", oFont04)

					//13 - Nome do Beneficiário
					oPrint:Say( nLinIni + 0225,nColIni + (nColMax * 0.400), replicate( "__",20 ) , oFont04)

					//14 - Número da Guia Principal
					oPrint:Say( nLinIni + 0225,nColIni + (nColMax * 0.600), replicate( "|__",20 ) + "|", oFont04)

					//15 - Assinatura
					oPrint:Say( nLinIni + 0225,nColIni + (nColMax * 0.850), replicate( "__",13 ) , oFont04)

					// Pula uma linha
					nLinIni += 11
				Next nI

				nLinIni := nOldLinIni

				nTam	:= 110
				nMarg	:= 020

				//16 - Data
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nMarg, nLinIni + (nLinMax * 0.972), nColIni + nMarg + nTam )
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nMarg + 03, "16 - Data", oFont01)
				oPrint:Say(nLinIni + (nLinMax * 0.96), nColIni + nMarg + 05, "|__|__|/|__|__|/|__|__|__|__|",oFont04,,,,1 )

				//17- Assinatura do Contratado
				oPrint:Box(nLinIni + (nLinMax * 0.91), nColIni + nTam + nMarg + 03, nLinIni + (nLinMax * 0.972), nColIni + nColMax - 0010 )
				oPrint:Say(nLinIni + (nLinMax * 0.93), nColIni + nTam + nMarg + 05, "17- Assinatura do Contratado", oFont01)
			endIf

			oPrint:EndPage()	// Finaliza a pagina
		EndDo
	Next nX

	If lGerTXT .OR. lWeb
		oPrint:Print()		// Imprime Relatorio
	Else
		oPrint:Preview()	// Visualiza impressao grafica antes de imprimir
	EndIf
Return cFileName


//-------------------------------------------------------------------
/*/{Protheus.doc} TrataErro
Trata erro em tempo de execução

@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function TrataErro(e, cErro)

	Local lRet := e:gencode > 0

	If lRet
		cErro += "Descrição: " + e:Description + CRLF
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getException
Define regra de exibição de itens negados.

@author  Lucas Nonato
@version P12
@since   15/03/2017
/*/
//-------------------------------------------------------------------

Static Function getException(nQtdSol, nQtdAut, cMask)
	Local cRet 	:= ""

	DEFAULT cMask := "@E 999"
	If nQtdSol == 0
		cRet := Iif (nQtdAut = 0 ,"",Transform(nQtdAut,cMask))
	Else
		cRet := Transform(nQtdAut, cMask)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AjusPath

Ajuste provisorio do path do objeto 

@Observ  Solucao de contorno ate sair o path do frame
@version P12
@since   25/09/2020
/*/
//-------------------------------------------------------------------
Static Function AjusPath(oPrint)

	oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"\","/",1)
	oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"\","/",1)
	oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"//","/",1)
	oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"//","/",1)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AjusPath

IMPRESSÃO DAS GUIAS DE HONORARIO INDIVIDUAL

@Observ  
@version P12
@since   30/08/2021
/*/
//-------------------------------------------------------------------

Function PLSTISSG(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW, lUnicaImp)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local nCol2A4   :=  0
	Local cFileLogo
	Local lPrinter := .F.
	Local nOldLinIni
	Local nI, nJ, nX
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local nAte		:= 10
	Local nAte2	:= 0
	Local lImpNovo	:= .T.
	Local nIni		:= 1
	Local nIni2	:= 1
	Local cRel      := "guihon"
	Local oPrint	:= nil
	Local cPathSrvJ := GETMV("MV_RELT")
	Local nTweb		:= 1
	Local nLweb		:= 0
	Local nLwebC	:= 0
	LOCAL cErro		:= ""
	LOCAL cArq			:= ""
	Local nTamBox	:= 0

	Default lGerTXT := .F.
	Default nLayout := 2
	Default cLogoGH := ''
	Default lWeb    := .F.
	Default cPathRelW := ''
	Default lUnicaImp := .F.
	Default aDados := { { ;
		"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- N?Guia no Prestador.
	"12345678901234567890",; //3- N?Guia de Solicita?o de Interna?o.
	"12345678901234567890",; //4 - Senha
	"12345678901234567890",; //5 - Numeroo da Guia Atribu?o pela Operadora
	"12345678901234567890",; //6 - Numero da Carteira
	Replicate("M",70),; //7 - Nome
	"S",; //8 - Atendimento a RN
	"12345678901234",; //9 - Código na Operadora
	Replicate("H",70),; //10 - Nome do Hospital/Local
	"1234567",; //11-Código CNES
	"12345678901234",; //12 - Código na Operadora
	Replicate("M",70),; //13 - Nome do Contratado
	"1234567",; //14 - Códogo CNES
	CtoD("12/03/06"),; //15 - Data do Inicio do Faturamento
	CtoD("12/03/06"),; //16 - Data do Fim do Faturamento
	{ CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06")},; //17-Data
	{ "0107","0207","0307","0407","0507","0507","0507","0507","0507","0507","0507","0507" },; //18-Hora Inicial
	{ "0607","0707","0807","0907","1007","0507","0507","0507","0507","0507","0507","0507" },; //19-Hora Final
	{ "MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD" },; //20-Tabela
	{ "5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234"},; //21-C?igo do Procedimento
	{ Replicate("M",10),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150)},; //22-C?igo do Procedimento
	{ 120,1,22,322,4,444,4,444,4,4,411,111 },; //23-Qtde.
	{ "D","D","D","D","D","D","D","D","D","D","D","D"},; //24-Via
	{ "M","E","F","G","H","D","D","D","D","D","D","D" },; //25-Tec
	{ 1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99 },; //26- Fator Red / Acresc
	{ 999999.99,22222.22,33.33,44444.44,11111.11,111111.11,11111.11,11111.11,211111.11,11111.11,311111.11,999999.99 },; //27-Valor Unit?io - R$
	{ 999999.99,22222.22,33.33,44444.44,11111.11,111111.11,11111.11,11111.11,211111.11,11111.11,311111.11,999999.99 },; //28-Valor Total ?R$
	{ "01", "99", "01", "99", "01" },; //29-Seq.Ref
	{ "02", "88", "02", "88", "02" },; //30-Grau Part.
	{ "01234567890123", "01234567890123", "01234567890123", "01234567890123", "01234567890123" },; //31-Código na Operadora/CPF
	{ Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70) },; //32-Nome do Profissional
	{ "00", "02", "00", "02", "00" },; //33-Conselho Profissional
	{ "012345678901234", "012345678901234", "012345678901234", "012345678901234", "012345678901234" },; //34-Número no Conselho
	{ "AA", "AA", "AA", "AA", "AA" },; //35-UF
	{ "123456", "123456", "123456", "123456", "123456" },; //36-Código CBO
	Replicate("M", 500),; //37- Observação/ Justificativa
	987564.32,; //38- Valor total dos honorários
	CtoD("01/01/07") ,; //39 - Data de emissão
	'',;
	'' } }//41 NOME SOCIAL

	If nLayout  == 1 // Oficio 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // PapelA4
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
	Else  // Pap? A4 ou Carta
		oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif


	//Nao permite acionar a impressao quando for na web.
	
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	oPrint := FWMSPrinter():New ( cFileName	,IMP_PDF,.F.,cPathSrvJ,.T.,		,@oPrint,	,		,	.F.,.f.	 )

	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
	oPrint:cPathPDF := cPathSrvJ

	nTweb	 := 3.9 //2 //3.9
	nLweb	 := 10 //5 //10
	nLwebC	 := -3
	nTamBox := 25

	oPrint:lServer := lWeb

	oPrint:SetLandscape()		// Modo paisagem

	if nLayout == 2
		oPrint:SetPaperSize(9)// Papel A4
	Elseif nLayout == 3
		oPrint:SetPaperSize(1)// Papel Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	oPrint:setDevice(IMP_PDF)

	For nX := 1 To Len(aDados)

		nAte 	:= 10
		nAte2 	:= 4
		nI		:= 0
		nIni	:= 1
		nIni2	:= 1

		//Esta parte do código faz com que
		//imprima mais de uma guia.
		//INICIO
		If lUnicaImp
			If nX <= Len(aDados)
				lImpNovo := .T.
			EndIf
		EndIf
		//FIM

		While lImpNovo

			lImpNovo 	:= .F.

			If  ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
				Loop
			EndIf

			For nI := 17 To 28
				If Len(aDados[nX, nI]) < nAte
					For nJ := Len(aDados[nX, nI]) + 1 To nAte
						If AllTrim(Str(nI)) $ "17"
							aAdd(aDados[nX, nI], StoD(""))
						ElseIf AllTrim(Str(nI)) $ "23,26,27,28"
							aAdd(aDados[nX, nI], 0)
						Else
							aAdd(aDados[nX, nI], "")
						EndIf
					Next nJ
				EndIf
			Next nI

			For nI := 29 To 36
				If Len(aDados[nX, nI]) < nAte2
					For nJ := Len(aDados[nX, nI]) + 1 To nAte2
						aAdd(aDados[nX, nI], "")
					Next nJ
				EndIf
			Next nI

			nLinIni := 000
			nColIni := 000
			nColA4  := 000
			nCol2A4 := 000

			nColMax := 3175

			oPrint:StartPage()		// Inicia uma nova pagina
			// Principal   
			oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

			//crrega e Imprime Logotipo da Empresa 
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (090)/nTweb) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // PapelA4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
				nCol2A4   := -0400
			Endif

			nColA4 := -550

			oPrint:Say(3*nLweb+(nLinIni + 0050)/nTweb, (nColIni + 1852 + IIf(nLayout == 2,nColA4,nCol2A4))/nTweb, "GUIA DE HONORÁRIOS", oFont03n,,,, 2) //GUIA DE HONOR?IOS
			oPrint:Say(3*nLweb+(nLinIni + 0085)/nTweb, (nColIni + 1780 + IIf(nLayout == 2,nColA4,nCol2A4))/nTweb, "(Somente para pacientes internados)", oFont02n,,,, 2) //"(Somente para pacientes internados"
			oPrint:Say(3*nLweb+(nLinIni + 0060)/nTweb, (nColIni + 2900 + IIf(nLayout == 2,nColA4,nCol2A4))/nTweb, "2- Nº Guia no Prestador", oFont01) //"2- N?Guia no Prestador"
			oPrint:Say(3*nLweb+(nLinIni + 0060)/nTweb, (nColIni + 3200 + IIf(nLayout == 2,nColA4,nCol2A4))/nTweb, aDados[nX, 02], oFont03n)

			oPrint:Box(3*nLweb+(nLinIni + 0240 - nTamBox)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0250 - nTamBox)/nTweb, ((nColIni + nColMax)*0.15 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0155)/nTweb, (nColIni + 0030)/nTweb, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
			oPrint:Say(3*nLweb+(nLinIni + 0190)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 01], oFont04)
			oPrint:Box(3*nLweb+(nLinIni + 0240 - nTamBox)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 0250 - nTamBox)/nTweb, ((nColIni + nColMax)*0.44- 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0155)/nTweb, ((nColIni + nColMax)*0.15 + 0010)/nTweb, "3- Nº Guia de Solicitação de Internação", oFont01) //"3- Nº Guia de Solicitação de Internação"
			oPrint:Say(3*nLweb+(nLinIni + 0200)/nTweb, ((nColIni + nColMax)*0.15 + 0020)/nTweb, aDados[nX, 03], oFont04)
			oPrint:Box(3*nLweb+(nLinIni + 0240 - nTamBox)/nTweb, ((nColIni + nColMax)*0.44)/nTweb, (nLinIni + 0250 - nTamBox)/nTweb, ((nColIni + nColMax)*0.72- 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0155)/nTweb, ((nColIni + nColMax)*0.44 + 0010)/nTweb, "4 - Senha", oFont01) //"4 - Senha"
			oPrint:Say(3*nLweb+(nLinIni + 0200)/nTweb, ((nColIni + nColMax)*0.44 + 0020)/nTweb, aDados[nX, 04], oFont04)
			oPrint:Box(3*nLweb+(nLinIni + 0240 - nTamBox)/nTweb, ((nColIni + nColMax)*0.72)/nTweb, (nLinIni + 0250 - nTamBox)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0155)/nTweb, ((nColIni + nColMax)*0.72 + 0010)/nTweb, "5 - Número da Guia Atribuído pela Operadora", oFont01) //"5 - Número da Guia Atribuído pela Operadora"
			oPrint:Say(3*nLweb+(nLinIni + 0200)/nTweb, ((nColIni + nColMax)*0.72 + 0020)/nTweb, aDados[nX, 05], oFont04)

			AddTBrush(oPrint,  (nLinIni + 0370)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0340)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0247)/nTweb, (nColIni + 0020)/nTweb, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
			oPrint:Box(3*nLweb+(nLinIni + 0380)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0380)/nTweb, ((nColIni + nColMax)*0.25 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0305)/nTweb, (nColIni + 0030)/nTweb, "6 - Número da Carteira", oFont01) //"6 - Número da Carteira"
			oPrint:Say(3*nLweb+(nLinIni + 0340)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 06], oFont04)
			oPrint:Box(3*nLweb+(nLinIni + 0380)/nTweb, ((nColIni + nColMax)*0.25)/nTweb, (nLinIni + 0380)/nTweb, ((nColIni + nColMax)*1.0 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0305)/nTweb, ((nColIni + nColMax)*0.25 + 0010)/nTweb, "41 - Nome Social", oFont01) //"7 - Nome"
			oPrint:Say(3*nLweb+(nLinIni + 0340)/nTweb, ((nColIni + nColMax)*0.25 + 0020)/nTweb, aDados[nX, 41], oFont04)

			AddTBrush(oPrint,  (nLinIni + 0500)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0500)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Box(3*nLweb+(nLinIni + 0510)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0510)/nTweb, ((nColIni + nColMax)*0.25 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0420)/nTweb, (nColIni + 0030)/nTweb, "8 - Atendimento a RN", oFont01) //"8 - Atendimento a RN
			oPrint:Say(3*nLweb+(nLinIni + 0465)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 08], oFont04)
			oPrint:Box(3*nLweb+(nLinIni + 0510)/nTweb, ((nColIni + nColMax)*0.25)/nTweb, (nLinIni + 0510)/nTweb, ((nColIni + nColMax)*1.0 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0420)/nTweb, ((nColIni + nColMax)*0.25 + 0010)/nTweb, "7 - Nome", oFont01) //"7 - Nome"
			oPrint:Say(3*nLweb+(nLinIni + 0465)/nTweb, ((nColIni + nColMax)*0.25 + 0020)/nTweb, aDados[nX, 7], oFont04)


			AddTBrush(oPrint,  (nLinIni + 0650)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0650)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0550)/nTweb, (nColIni + 0020)/nTweb, "Dados do Contratado (onde foi executado o procedimento)", oFont01) //"Dados do Contratado (onde foi executado o procedimento)"
			oPrint:Box(3*nLweb+(nLinIni + 0680)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0680)/nTweb, ((nColIni + nColMax)*0.20 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0580)/nTweb, (nColIni + 0030)/nTweb, "9 - Código na Operadora", oFont01) //"9 - Código na Operadora"
			oPrint:Say(3*nLweb+(nLinIni + 0630)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 09], oFont04)
				
			oPrint:Box(3*nLweb+(nLinIni + 0680)/nTweb, ((nColIni + nColMax)*0.20)/nTweb, (nLinIni + 0680)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0580)/nTweb, ((nColIni + nColMax)*0.20 + 0010)/nTweb, "10 - Nome do Hospital/Local", oFont01) //"10 - Nome do Hospital/Local"
			oPrint:Say(3*nLweb+(nLinIni + 0630)/nTweb, ((nColIni + nColMax)*0.20 + 0020)/nTweb, aDados[nX, 10], oFont04)

			oPrint:Box(3*nLweb+(nLinIni + 0680)/nTweb, ((nColIni + nColMax)*0.85)/nTweb, (nLinIni + 0680)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0580)/nTweb, ((nColIni + nColMax)*0.85 + 0010)/nTweb, "11 - Código CNES", oFont01) //"11 - Código CNES"
			oPrint:Say(3*nLweb+(nLinIni + 0630)/nTweb, ((nColIni + nColMax)*0.85 + 0020)/nTweb, aDados[nX, 11], oFont04)


			AddTBrush(oPrint,  (nLinIni + 0800)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0800)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0750)/nTweb, (nColIni + 0020)/nTweb, "Dados do Contratado Executante", oFont01) //"Dados do Contratado Executante"
			oPrint:Box(3*nLweb+(nLinIni + 0810)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0810)/nTweb, ((nColIni + nColMax)*0.18 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0730)/nTweb, (nColIni + 0030)/nTweb, "12 - Código na Operadora", oFont01) //"12 - Código na Operadora"
			oPrint:Say(3*nLweb+(nLinIni + 0780)/nTweb, (nColIni + 0040)/nTweb, aDados[nX, 12], oFont04)
				
			oPrint:Box(3*nLweb+(nLinIni + 0810)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, (nLinIni + 0810)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0730)/nTweb, ((nColIni + nColMax)*0.18 + 0010)/nTweb, "13 - Nome do Contratado", oFont01) //"13 - Nome do Contratado"
			oPrint:Say(3*nLweb+(nLinIni + 0780)/nTweb, ((nColIni + nColMax)*0.18 + 0020)/nTweb, aDados[nX, 13], oFont04)
				
			oPrint:Box(3*nLweb+(nLinIni + 0810)/nTweb, ((nColIni + nColMax)*0.85)/nTweb, (nLinIni + 0810)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0730)/nTweb, ((nColIni + nColMax)*0.85 + 0010)/nTweb, "14 - Código CNES", oFont01) //"14 - Código CNES"
			oPrint:Say(3*nLweb+(nLinIni + 0780)/nTweb, ((nColIni + nColMax)*0.85 + 0020)/nTweb, aDados[nX, 14], oFont04)


			AddTBrush(oPrint,  (nLinIni + 0940)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0940)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0835)/nTweb, (nColIni + 0020)/nTweb, "Dados da internação", oFont01) //"Dados da internação"
			oPrint:Box(3*nLweb+(nLinIni + 0965)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 0965)/nTweb, ((nColIni + nColMax)*0.18 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0885)/nTweb, (nColIni + 0030)/nTweb, "15 - Data do Início do Faturamento", oFont01) //"20 ?Data do Início do Faturamento"
			oPrint:Say(3*nLweb+(nLinIni + 0935)/nTweb, (nColIni + 0040)/nTweb, DtoC(aDados[nX, 15]), oFont04)
			oPrint:Box(3*nLweb+(nLinIni + 0965)/nTweb, ((nColIni + nColMax)*0.18)/nTweb, (nLinIni + 0965)/nTweb, ((nColIni + nColMax)*0.36 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0885)/nTweb, ((nColIni + nColMax)*0.18 + 0010)/nTweb, "16 - Data do Fim do Faturamento", oFont01) //"21 ?Data do Fim do Faturamento"
			oPrint:Say(3*nLweb+(nLinIni + 0935)/nTweb, ((nColIni + nColMax)*0.18 + 0020)/nTweb, DtoC(aDados[nX, 16]), oFont04)

			AddTBrush(oPrint,  (nLinIni + 1035)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 1035)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 0990)/nTweb, (nColIni + 0020)/nTweb, "Procedimentos Realizados", oFont01) //"Procedimentos Realizados"
			oPrint:Box(3*nLweb+(nLinIni + 1010)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 1645)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.005), "17 - Data", oFont01) //"17 - Data"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.015), "18 - Hora Inicial", oFont01) //"18 - Hora Inicial"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.030), "19 - Hora Final", oFont01) //"19 - Hora Final"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.045), "20 - Tabela", oFont01) //"20 - Tabela"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.055), "21 - Código do Procedimento", oFont01) //"21 - Código do Procedimento"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.080), "22 - Descrição", oFont01) //"22 - Descrição
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.150), "23 - Qtde", oFont01) //"23 - Qtde"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.165), "24 - Via", oFont01) //"34 - Via"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.175), "25 - Tec", oFont01) //"25 - Tec"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.185), "26 - Fator Red", oFont01) //"26 - Fator Red"
			oPrint:Say(3*nLweb+(nLinIni + 1050)/nTweb, ((nColIni + nColMax)*0.185), "/ Acresc", oFont01) //"/ Acresc"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.200), "27 - Valor Unitário - R$", oFont01) //"33 - Valor Unitário - R$"
			oPrint:Say(3*nLweb+(nLinIni + 1040)/nTweb, ((nColIni + nColMax)*0.230), "28 - Valor Total ?R$", oFont01) //"34-Valor Total ?R$"

			nOldLinIni := nLinIni

			For nI := nIni To nAte
				oPrint:Say(3*nLweb+(nLinIni + 1062)/nTweb, (nColIni + (nColMax)*0.009)/nTweb, AllTrim(Str(nI)) + " - ", oFont01)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.005), DtoC(aDados[nX, 17, nI]), oFont04)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.015), IIf(Empty(aDados[nX, 18, nI]), "", Transform(aDados[nX, 18, nI], "@R 99:99")), oFont04)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.030), IIf(Empty(aDados[nX, 19, nI]), "", Transform(aDados[nX, 19, nI], "@R 99:99")), oFont04)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.045), aDados[nX, 20, nI], oFont04)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.055), aDados[nX, 21, nI], oFont04)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.080), aDados[nX, 22, nI], oFont04)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.150), IIf(aDados[nX, 23, nI]=0, "", Transform(aDados[nX, 23, nI], "@E 999")), oFont04,,,,1)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.165), aDados[nX, 24, nI], oFont04)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.175), aDados[nX, 25, nI], oFont04,,,,1)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.185), IIf(Empty(aDados[nX, 26, nI]), "", Transform(aDados[nX, 26, nI], "@E 9.99")), oFont04,,,,1)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.200), IIf(Empty(aDados[nX, 27, nI]), "", Transform(aDados[nX, 27, nI], "@E 99,999,999.99")), oFont04,,,,1)
				oPrint:Say(3*nLweb+(nLinIni + 1067)/nTweb, ((nColIni + nColMax)*0.230), IIf(Empty(aDados[nX, 28, nI]), "", Transform(aDados[nX, 28, nI], "@E 99,999,999.99")), oFont04,,,,1)
				nLinIni += 50
			Next nI

			nLinIni := nOldLinIni

			nIni		:= nAte + 1
			If nAte < Len(aDados[nX][17])
				lImpNovo 	:= .T.
				nAte		+= 10
			EndIf

			nLinIni -= 100

			AddTBrush(oPrint,  (nLinIni + 1785)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 1785)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 1660)/nTweb, (nColIni + 0020)/nTweb, "Identificação do(s) Profissional(is) Executante(s)", oFont01) //"Identificação do(s) Profissional(is) Executante(s)"
			oPrint:Box(3*nLweb+(nLinIni + 1675)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 2060)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, (nColIni + 0030)/nTweb, "29-Seq. Ref", oFont01) //"29-Seq. Ref"
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, ((nColIni + nCOlMax)*0.07)/nTweb, "30-Grau Part.", oFont01) //"30-Grau Part."
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, ((nColIni + nCOlMax)*0.15)/nTweb, "31-Código na Operadora/CPF", oFont01) //"31-Código na Operadora/CPF"
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, ((nColIni + nCOlMax)*0.25)/nTweb, "32-Nome do Profissional", oFont01) //"32-Nome do Profissional"
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, ((nColIni + nCOlMax)*0.7)/nTweb, "33-Conselho", oFont01) //"33-Conselho"
			oPrint:Say(3*nLweb+(nLinIni + 1725)/nTweb, ((nColIni + nCOlMax)*0.7)/nTweb, "Profissional", oFont01) //"Profissional"
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, ((nColIni + nCOlMax)*0.78)/nTweb, "34-Número do Conselho", oFont01) //"34-Número do Conselho"
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, ((nColIni + nCOlMax)*0.87)/nTweb, "35-UF", oFont01) //"35-UF"
			oPrint:Say(3*nLweb+(nLinIni + 1700)/nTweb, ((nColIni + nCOlMax)*0.92)/nTweb, "36-Código CBO", oFont01) //"36-Código CBO"

			nOldLinIni := nLinIni

			For nI := nIni2 To nAte2
				If !Empty(aDados[nX, 32, nI])
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, (nColIni + 0030)/nTweb, AllTrim(Str(val(aDados[nX, 29, nI]))), oFont04)
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, ((nColIni + nColMax)*0.07)/nTweb, aDados[nX, 30, nI], oFont04)
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, aDados[nX, 31, nI], oFont04)
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, ((nColIni + nColMax)*0.25)/nTweb, aDados[nX, 32, nI], oFont04)
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, ((nColIni + nColMax)*0.7)/nTweb, aDados[nX, 33, nI], oFont04)
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, ((nColIni + nColMax)*0.78)/nTweb, aDados[nX, 34, nI], oFont04)
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, ((nColIni + nColMax)*0.87)/nTweb, aDados[nX, 35, nI], oFont04)
					oPrint:Say(3*nLweb+(nLinIni + 1745)/nTweb, ((nColIni + nColMax)*0.92)/nTweb, aDados[nX, 36, nI], oFont04)
				EndIf

				nLinIni += 50
			Next nI

			nLinIni := nOldLinIni

			nIni2		:= nAte2 + 1
			If nAte2 < Len(aDados[nX][29])
				lImpNovo 	:= .T.
				nAte2		+= 5
			EndIf

			nLinIni += 410

			oPrint:Box(3*nLweb+(nLinIni + 1560)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 1890)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
			AddTBrush(oPrint, (nLinIni + 1687)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 1888)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 1590)/nTweb, (nColIni + 0030)/nTweb, "37- Observação / Justificativa", oFont01) //"35- Observação / Justificativa"

			nOldLinIni := nLinIni
			For nI := 1 To MlCount(aDados[nX, 37], 100)
				cObs := MemoLine(aDados[nX, 37], 100, nI)
				oPrint:Say(3*nLweb+(nLinIni + 1620)/nTweb, (nColIni + 0040)/nTweb, cObs, oFont04)
				nLinIni += 50
			Next nI
			nLinIni := nOldLinIni

			oPrint:Box(3*nLweb+(nLinIni + 1560)/nTweb, ((nColIni + nColMax)*0.85)/nTweb, (nLinIni + 1800)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 1590)/nTweb, ((nColIni + nColMax)*0.85 + 0010)/nTweb, "38 - Valor total dos honorários", oFont01) //"36 - Valor total dos honorários"
			oPrint:Say(3*nLweb+(nLinIni + 1620)/nTweb, ((nColIni + nColMax)*0.85 + 0020)/nTweb, IIf(Empty(aDados[nX, 38]), "", Transform(aDados[nX, 38], "@E 99,999,999.99")), oFont04)

			oPrint:Box(3*nLweb+(nLinIni + 1885)/nTweb, (nColIni + 0020)/nTweb, (nLinIni + 1900)/nTweb, ((nColIni + nColMax)*0.1 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 1815)/nTweb, (nColIni + 0030)/nTweb, "39 - Data de emissão", oFont01) //"37 - Data de emissão
			oPrint:Say(3*nLweb+(nLinIni + 1845)/nTweb, (nColIni + 0040)/nTweb, DtoC(aDados[nX, 39]), oFont04)
			oPrint:Box(3*nLweb+(nLinIni + 1885)/nTweb, ((nColIni + nColMax)*0.1)/nTweb, (nLinIni + 1900)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
			oPrint:Say(3*nLweb+(nLinIni + 1815)/nTweb, ((nColIni + nColMax)*0.1 + 0010)/nTweb, "40 - Assinatura do Profissional Executante", oFont01) //"38 - Assinatura do Profissional Executante"

			oPrint:EndPage()	// Finaliza a pagina

		EndDo

	Next nX

	//END SEQUENCE
	//ErrorBlock( bError )

	If !Empty(cErro)
		cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
		MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
		cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
			"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
			"Tipos de Guias." + CRLF + CRLF + ;
			cErro
		PLSLogFil(cErro,cArq)
	EndIf

	oPrint:Print()		// Imprime Relatorio

Return cFileName
