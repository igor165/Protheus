#include 'protheus.ch'
#include 'parmtype.ch'
//#include 'OGAR160.ch'  não tem string de tradução relatório em inglês

/*/{Protheus.doc} OGAR160
//Relatório WEIGHT REPORT
@author marina.muller
@since 27/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
function OGAR160()
	Local oReport	:= Nil	
	Private _cPergunta    := "OGAR160001"
	Private cAliasQryPri  := GetNextAlias() 
	Private _cNrNotas     := ""
	Private _cBlocos      := ""
    
    If TRepInUse()            
        If Pergunte(_cPergunta,.T.)
            oReport := ReportDef()
            oReport:PrintDialog()
        EndIf
    EndIf    
	
return .t.

/*/{Protheus.doc} ReportDef
//Montagem das colunas do relatório
@author marina.muller
@since 27/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()
	Local oReport		:= Nil
    Local oBreakFaz     := Nil
    Local oSection0     := Nil
    Local oSection1     := Nil    
    Local oSection2     := Nil    
    
 	oReport 	:= TReport():New("OGAR160","WEIGHT REPORT","",{|oReport| PrintReport(oReport)},"WEIGHT REPORT")
	oReport:SetLandScape()       	
	oReport:HideHeader()
	oReport:HideParamPage()
	oReport:HideFooter() 
    oReport:SetTotalInLine(.F.)
    oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:oPage:nPapersize := 9     

	//cabeçalho do relatório
	oSection0 := TRSection():New( oReport, "", {"(cAliasQryPri)"} ) 
	oSection0:lLineStyle := .T. 
	TRCell():New( oSection0, "N91_FILORG", "(cAliasQryPri)", "SHIPPER ",  "@!", 200, .T., {|| ALLTRIM(FWFilialName(,(cAliasQryPri)->N91_FILORG,1)) + " / INSTRUCTION: "+ (cAliasQryPri)->N7Q_DESINE }, , , "LEFT", .T.)
	
	//listagem das colunas do relatório para cada uma das visões
	oSection1 := TRSection():New(oReport, "", {"(cAliasQryPri)"} ) 
	
	If MV_PAR11 == 1 //1 - por container
		TRCell():New( oSection1, "N91_DTCERT", "(cAliasQryPri)", "Date",         PesqPict("N91","N91_DTCERT"), 10, /*lPixel*/, {|| getDtCert((cAliasQryPri)->N91_DTCERT)}) //Date        
		TRCell():New( oSection1, "N91_CONTNR", "(cAliasQryPri)", "Container",    PesqPict("N91","N91_CONTNR"), TamSX3("N91_CONTNR" )[1], /*lPixel*/, {|| (cAliasQryPri)->N91_CONTNR}) //Container
		TRCell():New( oSection1, "QUANT",     , "No. of Bale",   PesqPict("N91","N91_QTDFRD"), TamSX3("N91_QTDFRD" )[1], /*lPixel*/, {|| (cAliasQryPri)->QUANT}) //No. of Bale
		TRCell():New( oSection1, "TARA",      , "ContainerTare", PesqPict("N91","N91_TARA"),   TamSX3("N91_TARA" )[1],   /*lPixel*/, {|| (cAliasQryPri)->TARA})       //ContainerTare	
		TRCell():New( oSection1, "PS_BRUTO",  , "GrossWeight",   "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->PS_BRUTO})   //GrossWeight
	    TRCell():New( oSection1, "TARECARGO", , "TareCargo",     "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->TARECARGO})  //TareCargo
	    TRCell():New( oSection1, "PS_LIQ",    , "NetWeight",     "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->PS_LIQ})     //NetWeight
	    TRCell():New( oSection1, "AVERAGE",   , "Average",       "@E 99999999999999.99", 16 , /*lPixel*/, {|| IF((cAliasQryPri)->QUANT > 0, (cAliasQryPri)->PS_BRUTO / (cAliasQryPri)->QUANT,(cAliasQryPri)->PS_BRUTO / 1)}) //Average
    	TRCell():New( oSection1, "VGM",       , "VGM",           "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->VGM})  //VGM
	    TRCell():New( oSection1, "NOTAS",     , "NFNumber",      PesqPict("N9I","N9I_DOC"),    25,  /*lPixel*/, {|| _cNrNotas}, ,.T.) //NFNumber
	    TRCell():New( oSection1, "BLOCOS",    , "Lots",          PesqPict("N9D","N9D_BLOCO"),  25,  /*lPixel*/, {|| _cBlocos},  ,.T.)  //Lots
	
	ElseIf MV_PAR11 == 2 //2 - por container detalhado
		TRCell():New( oSection1, "N91_DTCERT", "(cAliasQryPri)", "Date",         PesqPict("N91","N91_DTCERT"), 10, /*lPixel*/, {|| getDtCert((cAliasQryPri)->N91_DTCERT)}) //Date
		TRCell():New( oSection1, "N91_CONTNR", "(cAliasQryPri)", "Container",    PesqPict("N91","N91_CONTNR"), TamSX3("N91_CONTNR" )[1], /*lPixel*/, {|| (cAliasQryPri)->N91_CONTNR}) //Container
		TRCell():New( oSection1, "QUANT",     , "No. of Bale",   PesqPict("N91","N91_QTDFRD"), TamSX3("N91_QTDFRD" )[1], /*lPixel*/, {|| (cAliasQryPri)->QUANT}) //No. of Bale
		TRCell():New( oSection1, "PS_BRUTO",  , "GrossWeight",   "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->PS_BRUTO})   //GrossWeight
	    TRCell():New( oSection1, "TARECARGO", , "TareCargo",     "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->TARECARGO})  //TareCargo
	    TRCell():New( oSection1, "PS_LIQ",    , "NetWeight",     "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->PS_LIQ})     //NetWeight
	    TRCell():New( oSection1, "AVERAGE",   , "Average",       "@E 99999999999999.99", 16 , /*lPixel*/, {|| IF((cAliasQryPri)->QUANT > 0, (cAliasQryPri)->PS_BRUTO / (cAliasQryPri)->QUANT,(cAliasQryPri)->PS_BRUTO / 1)}) //Average
	    TRCell():New( oSection1, "NOTAS",     , "NFNumber",      PesqPict("N9I","N9I_DOC"),    25,  /*lPixel*/, {|| _cNrNotas}, ,.T.) //NFNumber
	    TRCell():New( oSection1, "BLOCOS",    , "Lots",          PesqPict("N9D","N9D_BLOCO"),  25,  /*lPixel*/, {|| _cBlocos},  ,.T.)  //Lots
    	TRCell():New( oSection1, "DXI_CLACOM", "(cAliasQryPri)" , "Type Bale", PesqPict("DXI","DXI_CLACOM"),  TamSX3("DXI_CLACOM" )[1],  /*lPixel*/, {|| (cAliasQryPri)->DXI_CLACOM})  //Type Bale
	
	ElseIf MV_PAR11 == 3 //3 - por bloco
		TRCell():New( oSection1, "BLOCOS",    , "Lots",          PesqPict("N9D","N9D_BLOCO"),  25,  /*lPixel*/, {|| _cBlocos},  ,.T.)  //Lots
		TRCell():New( oSection1, "QUANT",     , "No. of Bale",   PesqPict("N91","N91_QTDFRD"), TamSX3("N91_QTDFRD" )[1], /*lPixel*/, {|| (cAliasQryPri)->QUANT}) //No. of Bale
		TRCell():New( oSection1, "PS_BRUTO",  , "GrossWeight",   "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->PS_BRUTO})   //GrossWeight
	    TRCell():New( oSection1, "TARECARGO", , "TareCargo",     "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->TARECARGO})  //TareCargo
	    TRCell():New( oSection1, "PS_LIQ",    , "NetWeight",     "@E 99999999999999.99", 16 , /*lPixel*/, {|| (cAliasQryPri)->PS_LIQ})     //NetWeight
	    TRCell():New( oSection1, "AVERAGE",   , "Average",       "@E 99999999999999.99", 16 , /*lPixel*/, {|| IF((cAliasQryPri)->QUANT > 0, (cAliasQryPri)->PS_BRUTO / (cAliasQryPri)->QUANT,(cAliasQryPri)->PS_BRUTO / 1)}) //Average
	EndIf
	
	//totalizador do relatório
    oSection2 := TRSection():New(oReport, "", {"(cAliasQryPri)"})
    oBreakFaz   := TRBreak():New(oSection2, { ||  },"", .F., 'NOMEBRKCF',  .T.)	//Total
    oBreakFaz:OnPrintTotal({|| oReport:skipLine(2)})

    TRFunction():New(oSection1:Cell("QUANT"),     , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSection1)    		
    TRFunction():New(oSection1:Cell("PS_BRUTO"),  , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSection1)
    TRFunction():New(oSection1:Cell("TARECARGO"), , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSection1)
    TRFunction():New(oSection1:Cell("PS_LIQ"),    , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSection1)
    TRFunction():New(oSection1:Cell("AVERAGE"),   , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSection1)
    
    If MV_PAR11 == 1 //1 - por container
    	TRFunction():New(oSection1:Cell("TARA"),      , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSection1)
    	TRFunction():New(oSection1:Cell("VGM"),       , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSection1)
    EndIf	
    

Return( oReport )

/*/{Protheus.doc} PrintReport
//Montagem do SQL e impressão do relatório
@author marina.muller
@since 27/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport( oReport ) 	
	Local oS1		   := oReport:Section(1)
	Local oS2		   := oReport:Section(2)
	Local oS3		   := oReport:Section(3)
	Local cQueryPri    := ""
	Local cFilOri      := ""
    Local cIEorig      := ""
	
	If MV_PAR11 == 1 //1 - por container
		cQueryPri := "    SELECT N7Q.N7Q_DESINE, N91.N91_CODINE, N91.N91_DTCERT, N91.N91_FILORG, N91.N91_CONTNR, N91.N91_QTDFRD AS QUANT, "
		cQueryPri += "           SUM(N91.N91_TARA)   AS TARA, "   
		cQueryPri += "           SUM(N91.N91_BRTCER) AS PS_BRUTO, "
		cQueryPri += "           SUM(N91.N91_QTDCER) AS PS_LIQ, "
		cQueryPri += "           SUM(N91.N91_BRTCER) - SUM(N91.N91_QTDCER) AS TARECARGO, "
		cQueryPri += "           SUM(N91.N91_BRTCER) + SUM(N91.N91_TARA) AS VGM " 
	
	ElseIf MV_PAR11 == 2 //2 - por container detalhado
		cQueryPri := "    SELECT N7Q.N7Q_DESINE, N91.N91_CODINE, N91.N91_DTCERT, N91.N91_FILORG, N91.N91_CONTNR, "
		cQueryPri += "           COUNT(DXI_CODIGO) AS QUANT, "
		cQueryPri += "           (SUM(DXI.DXI_PSBRUT) - SUM(DXI.DXI_PSLIQU)) + SUM(DXI.DXI_PESCER) AS PS_BRUTO, " 
		cQueryPri += "           SUM(DXI.DXI_PESCER) AS PS_LIQ, "
		cQueryPri += "           SUM(DXI.DXI_PSBRUT) - SUM(DXI.DXI_PSLIQU) AS TARECARGO, "
		cQueryPri += "           N9I.N9I_DOC, N9D.N9D_BLOCO, DXI.DXI_CLACOM "
	
	ElseIf MV_PAR11 == 3 //3 - por bloco
		cQueryPri := "    SELECT N7Q.N7Q_DESINE, N91.N91_CODINE, N9D.N9D_BLOCO, N91.N91_FILORG, "
		cQueryPri += "           COUNT(DXI_CODIGO) AS QUANT, "
		cQueryPri += "           (SUM(DXI.DXI_PSBRUT) - SUM(DXI.DXI_PSLIQU)) + SUM(DXI.DXI_PESCER) AS PS_BRUTO, " 
		cQueryPri += "           SUM(DXI.DXI_PESCER) AS PS_LIQ, "
		cQueryPri += "           SUM(DXI.DXI_PSBRUT) - SUM(DXI.DXI_PSLIQU) AS TARECARGO "
	EndIf
	
	cQueryPri += "   FROM " + RetSqlName('N91') + " N91 "
	cQueryPri += "  INNER JOIN " + RetSqlName('N7Q') + " N7Q "
    cQueryPri += "     ON N7Q.N7Q_CODINE = N91.N91_CODINE "
    cQueryPri += "    AND N7Q.D_E_L_E_T_ = ' ' "
	
	If MV_PAR11 == 2 //2 - por container detalhado
		cQueryPri += "   LEFT OUTER JOIN " + RetSqlName('N9I') + " N9I "
		cQueryPri += "     ON N9I.N9I_FILORG = N91.N91_FILORG "
		cQueryPri += "    AND N9I.N9I_CONTNR = N91.N91_CONTNR "
		cQueryPri += "    AND N9I.N9I_CODINE = N91.N91_CODINE "  
		cQueryPri += "    AND N9I.D_E_L_E_T_ = ' ' "
	EndIf	

	cQueryPri += "   LEFT OUTER JOIN  " + RetSqlName('N9D') + " N9D "
	cQueryPri += "     ON N9D.N9D_FILORG = N91.N91_FILORG "
	cQueryPri += "    AND N9D.N9D_CONTNR = N91.N91_CONTNR "
	cQueryPri += "    AND N9D.N9D_CODINE = N91.N91_CODINE "
	cQueryPri += "    AND N9D.D_E_L_E_T_ = ' ' "
	cQueryPri += "   LEFT OUTER JOIN " + RetSqlName('DXI') + " DXI "
	cQueryPri += "     ON DXI.DXI_BLOCO  = N9D.N9D_BLOCO  "
	cQueryPri += "    AND DXI.DXI_CODIGO = N9D.N9D_CODFAR " 
	cQueryPri += "    AND DXI.D_E_L_E_T_ = ' '
	cQueryPri += "  WHERE N91.D_E_L_E_T_ = ' ' "
	
	If !Empty(MV_PAR01) //Filial de
		cQueryPri += " AND N91.N91_FILORG >= '"+MV_PAR01+"'"
	EndIf

	If !Empty(MV_PAR02)//Filial Até
		cQueryPri += " AND N91.N91_FILORG <= '"+MV_PAR02+"'"
	EndIf
	
	If !Empty(MV_PAR03)//IE de
		cQueryPri += " AND N91.N91_CODINE >= '"+MV_PAR03+"'"
	EndIf
	
	If !Empty(MV_PAR05)//IE até
		cQueryPri += " AND N91.N91_CODINE <= '"+MV_PAR05+"'"
	EndIf

	If !Empty(MV_PAR07)//Safra de
		cQueryPri += " AND N7Q.N7Q_CODSAF >= '"+MV_PAR07+"'"
	EndIf

	If !Empty(MV_PAR08)//Safra até
		cQueryPri += " AND N7Q.N7Q_CODSAF <= '"+MV_PAR08+"'"
	EndIf

	If !Empty(MV_PAR09)//Período DL Draft de 
		cQueryPri += " AND N7Q.N7Q_DDELDR >= '"+dtos(MV_PAR09)+"'"
	EndIf

	If !Empty(MV_PAR10)//Período DL Draft até 
		cQueryPri += " AND N7Q.N7Q_DDELDR <= '"+dtos(MV_PAR10)+"'"
	EndIf

	If MV_PAR11 == 1 //1 - por container
		cQueryPri += "     GROUP BY N7Q.N7Q_DESINE, N91.N91_CODINE, N91.N91_DTCERT, N91.N91_FILORG, N91.N91_CONTNR, N91.N91_QTDFRD "
		cQueryPri += "     ORDER BY N7Q.N7Q_DESINE, N91.N91_FILORG, N91.N91_DTCERT, N91.N91_CONTNR "
		
	ElseIf MV_PAR11 == 2 //2 - por container detalhado
		cQueryPri += "     GROUP BY N7Q.N7Q_DESINE, N91.N91_CODINE, N91.N91_DTCERT, N91.N91_FILORG, N91.N91_CONTNR, " 
		cQueryPri += "              N9I.N9I_DOC, N9D.N9D_BLOCO, DXI.DXI_CLACOM " 
		cQueryPri += "     ORDER BY N7Q.N7Q_DESINE, N91.N91_FILORG, N91.N91_DTCERT, N91.N91_CONTNR "
	
	ElseIf MV_PAR11 == 3 //3 - por bloco	
		cQueryPri += "     GROUP BY N7Q.N7Q_DESINE, N91.N91_CODINE, N9D.N9D_BLOCO, N91.N91_FILORG " 
		cQueryPri += "     ORDER BY N7Q.N7Q_DESINE, N91.N91_FILORG, N9D.N9D_BLOCO "
	EndIf
	
 
	cQueryPri := ChangeQuery(cQueryPri)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryPri),cAliasQryPri,.T.,.T.)
	DbSelectArea( cAliasQryPri ) 	
	
	If .Not. (cAliasQryPri)->(Eof())
		
		While .Not. (cAliasQryPri)->(Eof())
			_cNrNotas     := ""
			_cBlocos      := ""
			
			//se mudar a filial inicia nova página com cabeçalho
			If (cFilOri + cIEorig ) <> ( (cAliasQryPri)-> N91_FILORG + (cAliasQryPri)-> N91_CODINE )
				cFilOri := (cAliasQryPri)->N91_FILORG
                cIEorig := (cAliasQryPri)->N91_CODINE
				
				//imprime cabeçalho com logo
				PrintCabec(oReport)
				
				oS1:Init()
				oS1:PrintLine()
				oS1:Finish()
			EndIf
			
			oS2:Init()
			
			If MV_PAR11 == 1 //1 - por container
				//busca informações nota remessa / blocos visão por container
				VIS_CONTAI((cAliasQryPri)->N91_FILORG, (cAliasQryPri)->N91_CONTNR, (cAliasQryPri)->N91_CODINE)
			
			ElseIf MV_PAR11 == 2 //2 - por container detalhado 
				_cNrNotas     := (cAliasQryPri)-> N9I_DOC
				_cBlocos      := (cAliasQryPri)-> N9D_BLOCO
			
			ElseIf MV_PAR11 == 3 //3 - por bloco
				_cBlocos      := (cAliasQryPri)-> N9D_BLOCO
			EndIf	
			
			oS2:PrintLine()
			
			(cAliasQryPri)->(dbSkip())

			//se ainda tiver registros no loop
			If .Not. (cAliasQryPri)->(Eof())
				//se mudar a filial pula página
				If (cFilOri + cIEorig ) <> ( (cAliasQryPri)-> N91_FILORG + (cAliasQryPri)-> N91_CODINE )
					//imprime totalizador
					oS3:Init()
					oS3:PrintLine()
					oS3:Finish()
					
					oS2:Finish()

					oReport:EndPage()
				EndIf
			EndIf		
		EndDo
		(cAliasQryPri)->( dbCloseArea() )

		//imprime totalizador última página
		oS3:Init()
		oS3:PrintLine()
		oS3:Finish()
		
		oS2:Finish()
	EndIf
	
Return .t.

/*/{Protheus.doc} VIS_CONTAI
//Busca nota de remessa e blocos para relatório visão por container
@author marina.muller
@since 27/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilOrg, characters, descricao
@param cContNr, characters, descricao
@type function
/*/
Static Function VIS_CONTAI(cFilOrg, cContNr, cIE) 
	Local cQuerySec    := ""
	Local cQueryTer    := ""
	Local cAliasQrySec := ""
	Local cAliasQryTer := ""

	//-----------------------------------------//
	//busca as notas de remessa do container
	//-----------------------------------------//
	cQuerySec := " SELECT DISTINCT N9I.N9I_DOC "
	cQuerySec += "   FROM " + RetSqlName("N9I") + " N9I " 
	cQuerySec += "  WHERE N9I.D_E_L_E_T_ = ' ' " 
	cQuerySec += "    AND N9I.N9I_FILORG = '" + cFilOrg  + "' "
	cQuerySec += "    AND N9I.N9I_CONTNR = '" + cContNr  + "' "
    cQuerySec += "    AND N9I.N9I_CODINE = '" + cIE  + "' "
	cQuerySec += "    AND N9I_INDSLD IN ('2', '3') " //2=Vinculado conteiner; 3=Vinculado conteiner anticipado                                                   
	cQuerySec += "  ORDER BY N9I.N9I_DOC " 
	
	cAliasQrySec := GetNextAlias()
	cQuerySec := ChangeQuery(cQuerySec)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySec),cAliasQrySec,.T.,.T.)
	DbSelectArea( cAliasQrySec ) 	
	
	If .Not. (cAliasQrySec)->(Eof())
		While .Not. (cAliasQrySec)->(Eof())	
			
			_cNrNotas += ALLTRIM((cAliasQrySec)-> N9I_DOC)
			
			(cAliasQrySec)->( dbSkip() )
			
			// se ainda tiver registros incluir separador virgula (,)
			If .Not. (cAliasQrySec)->(Eof())
				_cNrNotas += ", "
			EndIf 
		EndDo
		(cAliasQrySec)->( dbCloseArea() )
	EndIf	
	//-----------------------------------------//

	//-----------------------------//
	//busca os blocos do container 
	//-----------------------------//
	cQueryTer := "SELECT DISTINCT N9D.N9D_BLOCO "
	cQueryTer += "  FROM " + RetSqlName("N9D") + " N9D "
	cQueryTer += " WHERE N9D.D_E_L_E_T_ = ' ' "
	cQueryTer += "   AND N9D.N9D_FILORG = '" + cFilOrg  + "' "
	cQueryTer += "   AND N9D.N9D_CONTNR = '" + cContNr  + "' " 
    cQueryTer += "   AND N9D.N9D_CODINE = '" + cIE  + "' " 
	cQueryTer += " ORDER BY N9D.N9D_BLOCO " 
	
	cAliasQryTer := GetNextAlias()
	cQueryTer := ChangeQuery(cQueryTer)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryTer),cAliasQryTer,.T.,.T.)
	DbSelectArea( cAliasQryTer ) 	
	
	If .Not. (cAliasQryTer)->(Eof())
		While .Not. (cAliasQryTer)->(Eof())	
			
			_cBlocos += (cAliasQryTer)->N9D_BLOCO
			
			(cAliasQryTer)->( dbSkip() )

			// se ainda tiver registros incluir separador virgula (,)
			If .Not. (cAliasQryTer)->(Eof())
				_cBlocos += ", "
			EndIf 
		EndDo
		(cAliasQryTer)->( dbCloseArea() )
	EndIf	
	//-----------------------------------------//

Return .T.

/*/{Protheus.doc} getDtCert
//Formatação data certificação em dd/mm/aaaa
@author marina.muller
@since 27/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cDtCert, characters, descricao
@type function
/*/
Static Function getDtCert(cDtCert)	
	
	cDtCert := SubStr(cDtCert, 7, 2) + '/' + SubStr(cDtCert, 5, 2) + '/' + SubStr(cDtCert, 1, 4)
	
Return cDtCert

/*/{Protheus.doc} OGAR160IED
//Busca descrição da IE para pergunte de
@author marina.muller
@since 27/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGAR160IED()
	Local aArea := GetArea()
	Local lRet  := .T.
	
	If EMPTY(MV_PAR03)
	   MV_PAR04 := SPACE(TamSX3("N7Q_DESINE")[1])
	
	ElseIf !(EMPTY(MV_PAR03))
		lRet := ExistCpo('N7Q',MV_PAR03,1)
		
		If lRet
		   MV_PAR04 := Posicione("N7Q",1,(FWXFilial("N7Q")+MV_PAR03),"N7Q_DESINE") 
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} OGAR160IEA
//Busca descrição da IE para pergunte até
@author marina.muller
@since 27/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGAR160IEA()
	Local aArea := GetArea()
	Local lRet  := .T.
	
	If EMPTY(MV_PAR05)
	   MV_PAR06 := SPACE(TamSX3("N7Q_DESINE")[1])
	
	ElseIf !(EMPTY(MV_PAR05))
		lRet := ExistCpo('N7Q',MV_PAR05,1)
		
		If lRet
		   MV_PAR06 := Posicione("N7Q",1,(FWXFilial("N7Q")+MV_PAR05),"N7Q_DESINE") 
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} PrintCabec
//Cabeçaho do relatório
@author marina.muller
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function PrintCabec(oReport)
   Local oFont11N := TFont():New( "Arial" ,,11,,.t.,,,,,.f. )
   Local nColuna  := 1200
   
   If MV_PAR11 == 3 //3 - por bloco
   	  nColuna  := 800
   EndIf
   
   oReport:SayBitmap(00,00, MV_PAR12, 500, 250)
   oReport:Say(100, nColuna, oReport:cRealTitle, oFont11N)
   oReport:SkipLine(8)
   	   
Return 



