#INCLUDE "VDFR360.ch"
#Include "Totvs.Ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR360  ³ Autor ³ Alexandre Florentino  ³ Data ³  25.02.14      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demonstrativo Analítico do Lotacionograma                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR360(void)                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VDFR360()

Local aRegs := {}
	
Private oReport
Private cString	   := "SRA"
Private cPerg	   := "VDFR360"
Private nomeProg   := cPerg
Private Titulo	   := STR0001 //'Demonstrativo analítico do lotacionograma'
Private nSeq 	   := 0

	PtSetAcento(.T.)
	
	If Pergunte(cPerg, .T.)
		Titulo += STR0002 + Trans(mv_par02, "@R 99/9999") //" - Mês/Ano: "
		ReportPrint()
	EndIf
	PtSetAcento(.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Alexandre Florentino ³ Data ³ 25.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR360                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR360 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint()
    
Local lin 	 	 	:= 0
Local nPos 		:= 0
Local nAux 		:= 0
Local cWhere 	 	:= "%"
Local cStartPath 	:= GetSrvProfString("Startpath","")
Local cNameFile	:= "", CabFil := "", CabTit := AllTrim(MV_PAR03) //Texto do Titulo

Local oPrint, cRelName := "VDFR360"
Local lAdjust		:= .T.
Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION
Local nLocal		:= 1		// Local
Local nOrient		:= 1		// Retrato
Local nPrintType	:= 6		// PDF
Local oSetup		:= Nil
Local nSomaLin    := 40, nRMargem := 30, nLMargem := 2800

Private oFont16, oFont08, oFont10 , oFont14

	cStartPath := AjuBarPath(cStartPath)
	cNameFile  := cStartPath+"lgrl"+cEmpAnt+cFilAnt+".bmp"
	If !File(cNameFile)
		cNameFile := cStartPath+"lgrl"+cEmpAnt+".bmp"
	Endif
	
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
	oFont14	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
	oFont14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	oFont16	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
	
	oPrint		:= FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T.)
	oSetup		:= FWPrintSetup():New (nFlags,cRelName)
	
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrient)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	
	If oSetup:Activate() == PD_OK 
		oPrint:lServer := oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER	
		oPrint:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
		oPrint:SetLandscape()
		oPrint:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
		oPrint:setCopies(Val(oSetup:cQtdCopia))
		
		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oPrint:nDevice  := IMP_SPOOL
			oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]
		Else 
			oPrint:nDevice  := IMP_PDF
			oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE] 
			oPrint:SetViewPDF(.T.)
		Endif
	Else 
		MsgInfo("Relatório cancelado pelo usuário.")
		oPrint:Cancel()
		
		Return
	EndIf
	
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + StrTran(MV_PAR01, "RA_FILIAL", "SRA.RA_FILIAL")
	EndIf
	cWhere += "%"

	BeginSql Alias "QRYOCU"
	    SELECT CASE WHEN RCC.RCC_FIL = ' ' THEN %Exp:xFilial("RCC")% ELSE RCC.RCC_FIL END AS RCC_FIL,
		       SUM(CASE WHEN SQ3.Q3_CATEG IN (%Exp:'0'%,%Exp:'1'%) THEN CAST(SUBSTRING(RCC.RCC_CONTEU, 12, 5) AS INTEGER) ELSE 0 END) AS Q3_MEMBROS,
			   SUM(CASE WHEN SQ3.Q3_CATEG IN (%Exp:'2'%) THEN CAST(SUBSTRING(RCC.RCC_CONTEU, 12, 5) AS INTEGER) ELSE 0 END) AS Q3_EFETIVOS,
			   SUM(CASE WHEN SQ3.Q3_CATEG IN (%Exp:'3'%,%Exp:'6'%) THEN CAST(SUBSTRING(RCC.RCC_CONTEU, 12, 5) AS INTEGER) ELSE 0 END) AS Q3_COMISSAO,
			   SUM(CASE WHEN SQ3.Q3_CATEG IN (%Exp:'M'%) THEN CAST(SUBSTRING(RCC.RCC_CONTEU, 12, 5) AS INTEGER) ELSE 0 END) AS Q3_CONTRATA
		  FROM %table:RCC% RCC
		  LEFT JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SUBSTRING(RCC_CONTEU, 1, 5)
		 WHERE RCC.%notDel% AND RCC.RCC_FILIAL = %Exp:xFilial("RCC")% AND RCC.RCC_CODIGO = %Exp:'S111'%
           AND RCC.R_E_C_N_O_ IN (%Exp:QryUtRCC({5,6}, Right(mv_par02, 4) + left(mv_par02, 2))%)
           AND CASE WHEN RCC.RCC_CHAVE = %Exp:' '% THEN %Exp:Right(mv_par02, 4) + left(mv_par02, 2)% 
                    ELSE RCC.RCC_CHAVE END <= %Exp:Right(mv_par02, 4) + left(mv_par02, 2)%
		 GROUP BY CASE WHEN RCC.RCC_FIL = %Exp:' '% THEN %Exp:xFilial("RCC")% ELSE RCC.RCC_FIL END
	EndSql
	
	BeginSql Alias "QRY"
		SELECT SRA.RA_FILIAL, 
		       COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'0'%,%Exp:'1'%) THEN 1 ELSE NULL END) AS Q3_MEMBROS, 
               COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'2'%,%Exp:'3'%) THEN 1 ELSE NULL END) AS Q3_EFETIVOS,
               COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'3'%,%Exp:'6'%) THEN 1 ELSE NULL END) AS Q3_COMISSAO,
               COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'M'%) AND SRA.RA_TPCONTR = %Exp:'2'% THEN 1 ELSE NULL END) AS Q3_CONTRATA,
		       MAX(ADM.Q3_MEMBROS) AS AD_MEMBROS, MAX(ADM.Q3_EFETIVOS) AS AD_EFETIVOS, 
		       MAX(ADM.Q3_COMISSAO) AS AD_COMISSAO, MAX(ADM.Q3_CONTRATA) AS AD_CONTRATA,
		       MAX(DEM.Q3_MEMBROS) AS DM_MEMBROS, MAX(DEM.Q3_EFETIVOS) AS DM_EFETIVOS, 
		       MAX(DEM.Q3_COMISSAO) AS DM_COMISSAO, MAX(DEM.Q3_CONTRATA) AS DM_CONTRATA
		  FROM %table:SRA% SRA
          LEFT JOIN (SELECT SRA.RA_FILIAL, COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'0'%,%Exp:'1'%) THEN 1 ELSE NULL END) AS Q3_MEMBROS,
	                        COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'2'%, %Exp:'3'%) THEN 1 ELSE NULL END) AS Q3_EFETIVOS, 
	                        COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'3'%, %Exp:'6'%) THEN 1 ELSE NULL END) AS Q3_COMISSAO,  
	    	                COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'M'%) AND SRA.RA_TPCONTR = %Exp:'2'% THEN 1 ELSE NULL END) AS Q3_CONTRATA  
	                  FROM (SELECT SRA.RA_FILIAL, SRA.RA_CATFUNC, SRA.RA_TPCONTR  
	                          FROM %table:SRA% SRA  
	                          JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO  
	                         WHERE SRA.%notDel% %Exp:cWhere%
  	                           AND SRA.RA_ADMISSA BETWEEN %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '01'%  
 	                                                  AND %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '31'%
	                         UNION ALL
	                        SELECT SRA.RA_FILIAL, SRA.RA_CATFUNC, SRA.RA_TPCONTR  
	                          FROM %table:SR7% SR7  
	                          JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT   
	                          JOIN %table:SR3% SR3 ON SR3.%notDel% AND SR3.R3_FILIAL = SR7.R7_FILIAL AND SR3.R3_MAT = SR7.R7_MAT   
	                           AND SR3.R3_DATA = SR7.R7_DATA AND SR3.R3_TIPO = %Exp:'004'%
	                          JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO   
	                         WHERE SR7.%notDel% %Exp:cWhere%
	                           AND SR7.R7_DATA BETWEEN %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '01'%  
	                                               AND %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '31'% AND SR7.R7_TIPO = %Exp:'004'%) SRA  
	                      GROUP BY SRA.RA_FILIAL) ADM ON ADM.RA_FILIAL = SRA.RA_FILIAL
	      LEFT JOIN (SELECT SRA.RA_FILIAL, COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'0'%,%Exp:'1'%) THEN 1 ELSE NULL END) AS Q3_MEMBROS, 
	                        COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'2'%, %Exp:'3'%) THEN 1 ELSE NULL END) AS Q3_EFETIVOS, 
	                        COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'3'%, %Exp:'6'%) THEN 1 ELSE NULL END) AS Q3_COMISSAO, 
	                        COUNT(CASE WHEN SRA.RA_CATFUNC IN (%Exp:'M'%) AND SRA.RA_TPCONTR = %Exp:'2'% THEN 1 ELSE NULL END) AS Q3_CONTRATA 
	                   FROM (SELECT SRA.RA_FILIAL, SRA.RA_CATFUNC, SRA.RA_TPCONTR 
	                           FROM %table:SRA% SRA 
	                           JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO  
	                          WHERE SRA.%notDel% %Exp:cWhere%
 	                            AND SRA.RA_DEMISSA BETWEEN %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '01'%  
	                                                   AND %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '31'%
	                          UNION ALL 
	                         SELECT SRA.RA_FILIAL, SRA.RA_CATFUNC, SRA.RA_TPCONTR 
	                           FROM %table:SR7% SR7 
	                           JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT  
	                           JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO  
	                          WHERE SRA.%notDel% %Exp:cWhere%
	                            AND SR7.R7_DATA BETWEEN %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '01'%  
	                                                AND %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '31'% AND SR7.R7_TIPO = %Exp:'005'%) SRA  
	                       GROUP BY SRA.RA_FILIAL) DEM ON DEM.RA_FILIAL = SRA.RA_FILIAL
         WHERE SRA.%notDel% %Exp:cWhere%
           AND SRA.RA_ADMISSA < %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '01'%  
		   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:Right(mv_par02, 4) + Left(mv_par02, 2) + '01'% ) 
         GROUP BY SRA.RA_FILIAL
         ORDER BY SRA.RA_FILIAL
	EndSql

	While ! QRY->(Eof())
		//-- Filtra pela filial do funcionário
		DbSelectArea("QRYOCU")
		Set Filter To RCC_FIL = QRY->RA_FILIAL
		DbGoTop()
		If Eof()
			//-- Se não encontrar procura pela filial corrente pois foi configurado como compartilhado
			Set Filter To RCC_FIL = xFilial("RCC")
			DbGoTop()
		EndIf
			
		oPrint:StartPage() 		// Inicia uma nova pagina
		oPrint:Box(075 + nSomaLin,030,275 + nSomaLin,nLMargem ) //
		oPrint:SayBitmap(095 + nSomaLin,050,cNameFile,300,070) // Tem que estar abaixo do RootPath
		CabFil := AllTrim(QRY->RA_FILIAL) + " - " + AllTrim(fDesc("SM0", cEmpAnt + QRY->(RA_FILIAL), "M0_NOMECOM"))
		oPrint:Say(115 + nSomaLin,(2750 - (Len(CabFil) * 16))/2,CabFil,oFont14 )
		oPrint:Say(165 + nSomaLin,(2750 - (Len(CabTit) * 16))/2,CabTit,oFont14N )
		oPrint:Say(225 + nSomaLin,(2750 - (Len(Titulo) * 16))/2,titulo,oFont14N )
		oPrint:Say(245 + nSomaLin,050,RptHora +time(),oFont08)
		oPrint:Say(245 + nSomaLin,2600,RptEmiss+DTOC(dDataBase),oFont08)

		oPrint:Box(325,nRMargem,605,nLMargem )
		oPrint:Line(325,260,605,260 )   	// Vertical
		oPrint:Line(420,260,420,nLMargem )   	// horizontal
		oPrint:Line(500,260,500,nLMargem )   	// horizontal

		oPrint:Say(340 + nSomaLin,480,STR0004,oFont14N ) //"QTDE AUTORIZADAS PCCS"
		oPrint:Line(325,1100,605,1100 )   	// Vertical
		oPrint:Say(340 + nSomaLin,1330,STR0005,oFont14N ) //"QTDE VAGAS OCUPADAS"
		oPrint:Line(325,2000,605,2000 )   	// Vertical
		oPrint:Say(340 + nSomaLin,2200,STR0006,oFont14N ) //"QTDE VAGAS DISPONIVEIS"

		nAux := 0
		For nPos := 1 To 3
			If nPos = 2
				nAux := 870
			ElseIf nPos = 3
				nAux := 1730
			EndIf
			oPrint:Say(425 + nSomaLin,320 + nAux,STR0007,oFont10 ) //"Membros"
			If nPos == 1			//-- Quantidade Autorizadas PCCS  - Membros
				oPrint:Say(540 + nSomaLin,350 + nAux,Trans(QRYOCU->Q3_MEMBROS, "@E 99999"),oFont10 )
			ElseIf nPos == 2		//-- Quantidade Vagas Ocupadas    - Membros
				oPrint:Say(540 + nSomaLin,350 + nAux,Trans(QRY->Q3_MEMBROS, "@E 99999"),oFont10 )
			ElseIf nPos == 3		//-- Quantidade Vagas Disponíveis - Membros
				oPrint:Say(540 + nSomaLin,350 + nAux,Trans(QRYOCU->Q3_MEMBROS - QRY->Q3_MEMBROS, "@E 99999"),oFont10 )
			EndIf			
			oPrint:Line(420,450 + nAux,605,450 + nAux )   	// Vertical

			oPrint:Say(425 + nSomaLin,500 + nAux,STR0008,oFont10 ) //"Efetivo"
			If nPos == 1			//-- Quantidade Autorizadas PCCS  - Membros
				oPrint:Say(540 + nSomaLin,515 + nAux,Trans(QRYOCU->Q3_EFETIVOS, "@E 99999"),oFont10 )
			ElseIf nPos == 2		//-- Quantidade Vagas Ocupadas    - Membros
				oPrint:Say(540 + nSomaLin,515 + nAux,Trans(QRY->Q3_EFETIVOS, "@E 99999"),oFont10 )
			ElseIf nPos == 3		//-- Quantidade Vagas Disponíveis - Membros
				oPrint:Say(540 + nSomaLin,515 + nAux,Trans(QRYOCU->Q3_EFETIVOS - QRY->Q3_EFETIVOS, "@E 99999"),oFont10 )
			EndIf			
			oPrint:Line(420,600 + nAux,605,600 + nAux )   	// Vertical

			oPrint:Say(425 + nSomaLin,650 + nAux,STR0009,oFont10 ) //"Comissionado"
			If nPos == 1			//-- Quantidade Autorizadas PCCS  - Membros
				oPrint:Say(540 + nSomaLin,720 + nAux,Trans(QRYOCU->Q3_COMISSAO, "@E 99999"),oFont10 )
			ElseIf nPos == 2		//-- Quantidade Vagas Ocupadas    - Membros
				oPrint:Say(540 + nSomaLin,720 + nAux,Trans(QRY->Q3_COMISSAO, "@E 99999"),oFont10 )
			ElseIf nPos == 3		//-- Quantidade Vagas Disponíveis - Membros
				oPrint:Say(540 + nSomaLin,720 + nAux,Trans(QRYOCU->Q3_COMISSAO - QRY->Q3_COMISSAO, "@E 99999"),oFont10 )
			EndIf			
			oPrint:Line(420,850 + nAux,605,850 + nAux )   	// Vertical

			oPrint:Say(425 + nSomaLin,900 + nAux,STR0010,oFont10 ) //"Contratado"
			If nPos == 1			//-- Quantidade Autorizadas PCCS  - Membros
				oPrint:Say(540 + nSomaLin,950 + nAux,Trans(QRYOCU->Q3_CONTRATA, "@E 99999"),oFont10 )
			ElseIf nPos == 2		//-- Quantidade Vagas Ocupadas    - Membros
				oPrint:Say(540 + nSomaLin,950 + nAux,Trans(QRY->Q3_CONTRATA, "@E 99999"),oFont10 )
			ElseIf nPos == 3		//-- Quantidade Vagas Disponíveis - Membros
				oPrint:Say(540 + nSomaLin,950 + nAux,Trans(QRYOCU->Q3_CONTRATA - QRY->Q3_CONTRATA, "@E 99999"),oFont10 )
			EndIf			
		Next

		oPrint:Say(360 + nSomaLin,050,STR0011,oFont10N ) //"CARGO/"
		oPrint:Say(440 + nSomaLin,050,STR0012,oFont10N ) //"FUNÇÃO/"
		oPrint:Say(520 + nSomaLin,050,STR0013,oFont10N ) //"EMPREGO"

		oPrint:Box(700,nRMargem,985,nLMargem )

		oPrint:Say(715 + nSomaLin,310,STR0007,oFont14N ) //"MEMBROS"
		oPrint:Line(795,370,985,370 )   	// Vertical
		oPrint:Line(700,770,985,770 )   	// Vertical

		oPrint:Say(715 + nSomaLin,1050,STR0008,oFont14N ) //"EFETIVO"
		oPrint:Line(795,1110,985,1110 )   	// Vertical
		oPrint:Line(700,1510,985,1510 )   	// Vertical

		oPrint:Say(715 + nSomaLin,1750,STR0009,oFont14N ) //"COMISSIONADO"
		oPrint:Line(795,1830,985,1830 )   	// Vertical
		oPrint:Line(700,2220,985,2220 )   	// Vertical

		oPrint:Say(715 + nSomaLin,2380,STR0010,oFont14N ) //"CONTRATADO"
		oPrint:Line(795,2470,985,2470 )   	// Vertical

		oPrint:Line(795,nRMargem,795,nLMargem )   	// horizontal
		
		oPrint:Say(810 + nSomaLin,080,STR0014,oFont14 ) //"ADMITIDOS"
		oPrint:Say(910 + nSomaLin,220,Trans(QRY->AD_MEMBROS, "@E 99999"),oFont14 )

		oPrint:Say(810 + nSomaLin,440,STR0015,oFont14 ) //"EXONERADOS"
		oPrint:Say(910 + nSomaLin,570,Trans(QRY->DM_MEMBROS, "@E 99999"),oFont14 )

		oPrint:Say(810 + nSomaLin,840,STR0014,oFont14 ) //"ADMITIDOS"
		oPrint:Say(910 + nSomaLin,960,Trans(QRY->AD_EFETIVOS, "@E 99999"),oFont14 )
		oPrint:Say(810 + nSomaLin,1170,STR0015,oFont14 ) //"EXONERADOS"
		oPrint:Say(910 + nSomaLin,1330,Trans(QRY->DM_EFETIVOS, "@E 99999"),oFont14 )

		oPrint:Say(810 + nSomaLin,1580,STR0014,oFont14 ) //"ADMITIDOS"
		oPrint:Say(910 + nSomaLin,1700,Trans(QRY->AD_COMISSAO, "@E 99999"),oFont14 )
		oPrint:Say(810 + nSomaLin,1900,STR0015,oFont14 ) //"EXONERADOS"
		oPrint:Say(910 + nSomaLin,2050,Trans(QRY->DM_COMISSAO, "@E 99999"),oFont14 )

		oPrint:Say(810 + nSomaLin,2250,STR0014,oFont14 ) //"ADMITIDOS"
		oPrint:Say(910 + nSomaLin,2320,Trans(QRY->AD_CONTRATA, "@E 99999"),oFont14 )
		oPrint:Say(810 + nSomaLin,2520,STR0015,oFont14 ) //"EXONERADOS"
		oPrint:Say(910 + nSomaLin,2620,Trans(QRY->DM_CONTRATA, "@E 99999"),oFont14 )

		oPrint:Line(890,nRMargem,890,nLMargem )   	// horizontal

		oPrint:Say(1195,080,STR0016 + Dtoc(dDataBase),oFont14 )		// 'Data: '

		oPrint:SayAlign(1295,0440,AllTrim(mv_par04),oFont14N, 1100,100,, 2)
		oPrint:SayAlign(1395,0440,AllTrim(mv_par05),oFont14,  1100,100,, 2)

		oPrint:SayAlign(1295,1630,AllTrim(mv_par06),oFont14N, 1000,100,, 2)
		oPrint:SayAlign(1395,1630,AllTrim(mv_par07),oFont14 , 1000,100,, 2)
		
		oPrint:EndPage() 		// Finaliza a pagina
		QRY->(DbSkip())
	EndDo

	QRY->(DbCloseArea())
	QRYOCU->(DbCloseArea())

oPrint:Preview()  				// Visualiza antes de imprimir
	
Return