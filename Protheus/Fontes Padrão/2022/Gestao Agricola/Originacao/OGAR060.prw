#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGAR060.ch'

/*{Protheus.doc} OGAR060
Relatório Take-up
@author felipe.mendes / marina.muller
@since 29/11/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGAR060()
	Local oReport	:= Nil	
	Private _cPergunta := "OGAR060001"
	Private cAliasQrySec
	//Variavéis das Strings
    Private cStrTitulo    := ''
    Private cStrCliente   := ''
    Private cStrContrato  := ''
    Private cStrTakeup    := ''
    Private cStrClassif   := ''
    Private cStrPeríodo   := ''
    Private cStrFazend    := ''
    Private cStrBloco     := ''
    Private cStrFards     := ''
    Private cStrPeso      := ''
    Private cStrTipo      := ''
    Private cStrTotFaz    := ''
    Private cStrSafra     := ''
    Private cStrFardo     := ''
	Private cStrTotMed    := ''
	Private cStrTotalF    := ''

    If !isBlind()
        If TRepInUse()            
            If Pergunte(_cPergunta,.T.)
            	IF MV_PAR12 == 3 //3 - Detalhado  
            		oReport := RptDefDetail()
	                oReport:PrintDialog()
            	Else                         
	                oReport := ReportDef()
	                oReport:PrintDialog()
                EndIf
            EndIf
        EndIf
    Else               
        oReport := ReportDef()
        oReport:PrintDialog()            
    EndIf
	
return .t.

/*{Protheus.doc} RptDefDetail
Constrói o layout do relatório caso seja detalhado por fardo
@author felipe.mendes
@since 20/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static Function RptDefDetail()
	Local oReport		:= Nil
    Local oBreakFaz     := Nil    
    Local oSection1     := Nil    
    Local oSection2     := Nil
    
    //Tradução de String - INICIO  ------------------------------------------------	
        
    TraduzString()

	oReport 	:= TReport():New("OGAR060",cStrTitulo,"",{|oReport| PrtRprtDetail(oReport)},cStrTitulo)
	oReport:SetLandScape()       	
	oReport:HideFooter() 
    oReport:SetTotalInLine(.F.)
    oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:oPage:nPapersize := 9     

	//Seção 1 - Cabeçalho
	oSection1 := TRSection():New( oReport, "", {"DXI"} ) 
	oSection1:lLineStyle := .T. 
	TRCell():New( oSection1, "FAZENDA",  ,/*"Fazenda"*/       cStrFazend  ,      "@!", 30, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "CLIENTE",  ,/*"Cliente"*/       cStrCliente ,      "@!", 30, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "TAKEUP",   ,/*"Take-up"*/       cStrTakeup  ,      "@!", 30, .T., /*Block*/, , , "LEFT", .T.)		
	TRCell():New( oSection1, "CONTRATO", ,/*"Contrtato"*/     cStrContrato,      "@!", 30, .T., /*Block*/, , , "LEFT", .T.)		
	TRCell():New( oSection1, "CLASSIF",  ,/*"Clssificador"*/  cStrClassif ,		 "@!", 30, .T., /*Block*/, , , "LEFT", .T.)		
	TRCell():New( oSection1, "BLOCO",    ,/*"Bloco"*/         cStrBloco   , 	 "@!", 30, .T., /*Block*/, , , "LEFT", .T.)	
	TRCell():New( oSection1, "SAFRA",    ,/*"SAFRA"*/         cStrSafra   , 	 "@!", 30, .T., /*Block*/, , , "RIGHT", .T.)	
	
	
	//dados do relatório
    oSection2 := TRSection():New( oReport, "", {"DXQ"})
	oSection2:lLineStyle := .F.
	oSection2:lAutoSize  := .F.
    TRCell():New(oSection2,"DXI_ETIQ"   , "DXI", cStrFardo, PesqPict("DXI","DXI_ETIQ" )  , 30) 		
    TRCell():New(oSection2,"DXI_BLOCO"  , "DXI", cStrBloco, PesqPict("DXI","DXI_BLOCO")  , 20) 		
    TRCell():New(oSection2,"DXQ_TIPO"   , "DXQ", cStrTipo , PesqPict("DXQ","DXQ_TIPO" )  , 20)	   
    TRCell():New(oSection2,"DX7_FIBRA"  , "DX7", "Fiber"  , PesqPict("DX7","DX7_FIBRA" ) , 20)	   
 //   TRCell():New(oSection2,"DXI_PSESTO" , "DXI", cStrPeso , PesqPict("DXI","DXI_PSESTO" ), 40)	   
    TRCell():New(oSection2,"DXI_PSESTO" , "DXI", cStrPeso , "@E 9999999999999.99", 15) 		
    TRCell():New(oSection2,"DX7_MIC"    , "DX7", STR0015  , PesqPict("DX7","DX7_MIC" )   , 20)	   
    TRCell():New(oSection2,"DX7_UHM"    , "DX7", STR0013  , PesqPict("DX7","DX7_UHM" )   , 20)	   
    TRCell():New(oSection2,"DX7_RES"    , "DX7", STR0014  , PesqPict("DX7","DX7_RES" )   , 20)	   
    TRCell():New(oSection2,"DX7_SFI"    , "DX7", "Sfc"    , PesqPict("DX7","DX7_SFI" )   , 20)	   
    TRCell():New(oSection2,"DX7_UI"     , "DX7", "Ui"     , PesqPict("DX7","DX7_UI" )    , 20)	   
    TRCell():New(oSection2,"DX7_CSP"    , "DX7", "Csp"    , PesqPict("DX7","DX7_CSP" )   , 20)	   
    TRCell():New(oSection2,"DX7_ELONG"  , "DX7", "Elng"   , PesqPict("DX7","DX7_ELONG" ) , 20)	   
    TRCell():New(oSection2,"DX7_AREA"   , "DX7", "Area"   , PesqPict("DX7","DX7_AREA" )  , 20)	   
    TRCell():New(oSection2,"DX7_COUNT"  , "DX7", "Count"  , PesqPict("DX7","DX7_COUNT" ) , 20)	   
    
    //totalização do relatório
    oBreakFaz   := TRBreak():New(oSection2, { || (cAliasQrySec)->DXI_BLOCO} , cStrTotMed, .F., 'NOMEBRKFAZ',  .F.)	//"Total Fazenda"
    oBreakFaz:OnPrintTotal({|| oReport:skipLine(2)})

    TRFunction():New(oSection2:Cell("DXI_PSESTO"),,   "SUM",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
 
    TRFunction():New(oSection2:Cell("DX7_MIC"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_UHM"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_RES"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_SFI"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_UI"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_CSP"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_ELONG"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_AREA"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("DX7_COUNT"),,   "AVERAGE",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)

    //totalização do relatório
    oBreak2   := TRBreak():New(oSection2, { || (cAliasQrySec)->DXI_BLOCO} , cStrTotalF, .F., 'NOMEBRK2',  .T.)	
    oBreak2:OnPrintTotal({|| oReport:skipLine(2)})

 	oSum1 := TRFunction():New(oSection2:Cell("DXI_ETIQ") , cStrTotalF , "COUNT" , oBreak2 , , , , .f., .f. )
    oSum1:SetEndReport(.F.)
    
Return( oReport )

/*/{Protheus.doc} PrtRprtDetail
//Imprime o relatório
@author felipe.mendes 
@since 12/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cClass, characters, descricao
@type function
/*/
Static Function PrtRprtDetail(oReport)
	Local oS1		   := oReport:Section(1)
	Local oS2		   := oReport:Section(2)
					
	cQueryPri := " SELECT distinct N9A.N9A_FILORG, DXP.DXP_CODIGO, DXQ.* , NJR.NJR_CODENT, NJR.NJR_LOJENT, NJR.NJR_CTREXT, DXP.DXP_CLAINT, N9A.N9A_DATINI, N9A.N9A_DATFIM "  
	cQueryPri += "   FROM  " + RetSqlName('DXP') + " DXP "
	cQueryPri += " 	 INNER JOIN " + RetSqlName('DXQ') + " DXQ ON DXP.DXP_CODIGO = DXQ.DXQ_CODRES AND DXQ.D_E_L_E_T_  = 	''"
	cQueryPri += " 	 INNER JOIN " + RetSqlName('NJR') + " NJR ON DXP.DXP_CODCTP = NJR.NJR_CODCTR AND NJR.D_E_L_E_T_ = 	'' "
	cQueryPri += " 	 LEFT  JOIN " + RetSqlName('N9A') + " N9A ON N9A.N9A_CODCTR = NJR.NJR_CODCTR AND N9A.D_E_L_E_T_ = 	'' "
	cQueryPri += "  WHERE DXP.D_E_L_E_T_ = ' ' "
	
	If !Empty(MV_PAR01) //Filial de
		cQueryPri += " AND N9A.N9A_FILORG >= '"+MV_PAR01+"'"
	EndIf
	If !Empty(MV_PAR02)//Filial Até
		cQueryPri += " AND N9A.N9A_FILORG <= '"+MV_PAR02+"'"
	EndIf
	If !Empty(MV_PAR03)// Ctr Externo de
		cQueryPri += " AND NJR.NJR_CTREXT  >=  '"+MV_PAR03+"'"
	EndIf
	If !Empty(MV_PAR04)//Ctr Externo até 
		cQueryPri += " AND NJR.NJR_CTREXT <=  '"+MV_PAR04+"'"
	EndIf
	If !Empty(MV_PAR05)//Entidade de
		cQueryPri += " AND NJR.NJR_CODENT  >=  '"+MV_PAR05+"'"
	EndIf
	If !Empty(MV_PAR06)//Loja de
		cQueryPri += " AND NJR.NJR_LOJENT  >=  '"+MV_PAR06+"'"
	EndIf
	If !Empty(MV_PAR07)//Entidade até
		cQueryPri += " AND NJR.NJR_CODENT <=  '"+MV_PAR07+"'"
	EndIf
	If !Empty(MV_PAR08)// loja até
		cQueryPri += " AND NJR.NJR_LOJENT <=  '"+MV_PAR08+"'"
	EndIf
	If !Empty(MV_PAR09)//Período Embarque de
		cQueryPri += " AND (N9A.N9A_DATINI >= '"+dtos(MV_PAR09)+"' OR N9A.N9A_DATFIM >= '"+dtos(MV_PAR09)+"' ) "
	EndIf
	If !Empty(MV_PAR10)//Período Embarque até
		cQueryPri += " AND (N9A.N9A_DATINI <= '"+dtos(MV_PAR10)+"' OR N9A.N9A_DATFIM <= '"+dtos(MV_PAR10)+"' ) "
	EndIf
		
	cAliasQryPri := GetNextAlias()
	cQueryPri := ChangeQuery(cQueryPri)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryPri),cAliasQryPri,.T.,.T.)
	DbSelectArea( cAliasQryPri ) 	

	If .Not. (cAliasQryPri)->(Eof())
		
		While .Not. (cAliasQryPri)->(Eof())		
			
			oS1:Init()
			
			//atribui valor cabeçalho
			oS1:aCell[1]:SetValue(FWFilialName(,(cAliasQryPri)->N9A_FILORG ,1 ))
			oS1:aCell[2]:SetValue(getCliente((cAliasQryPri)->NJR_CODENT, (cAliasQryPri)->NJR_LOJENT))
			oS1:aCell[3]:SetValue((cAliasQryPri)->DXP_CODIGO)
			oS1:aCell[4]:SetValue((cAliasQryPri)->NJR_CTREXT)
			oS1:aCell[5]:SetValue(getClassif((cAliasQryPri)->DXP_CLAINT))
			oS1:aCell[6]:SetValue((cAliasQryPri)->DXQ_BLOCO )
			oS1:aCell[7]:SetValue((cAliasQryPri)->DXQ_SAFRA )
			
			//imprime cabeçalho
			oS1:PrintLine()			
	
			cQuerySec := " SELECT DXI_ETIQ  ,DXI_BLOCO , DX7_FIBRA ,DXI_PSESTO,DX7_MIC,DX7_UHM,DX7_RES ,DX7_SFI,DX7_UI,DX7_CSP,DX7_ELONG,DX7_AREA,DX7_COUNT "
			cQuerySec += " FROM " + RetSqlName('DXI') + " DXI "
			cQuerySec += " LEFT JOIN  " + RetSqlName('DX7') + " DX7 ON DX7.D_E_L_E_T_ = ' ' AND DX7_FILIAL = DXI_FILIAL AND DX7_SAFRA  = DXI_SAFRA AND DX7_ETIQ = DXI_ETIQ "
			cQuerySec += " WHERE DXI.D_E_L_E_T_ = ' ' AND "
			cQuerySec += " 		 DXI.DXI_FILIAL = '"+(cAliasQryPri)->DXQ_FILORG+"' AND 
			cQuerySec += " 		 DXI.DXI_CODRES = '"+(cAliasQryPri)->DXQ_CODRES+"' AND 
			cQuerySec += " 		 DXI.DXI_ITERES = '"+(cAliasQryPri)->DXQ_ITEM+"'   AND 
			cQuerySec += " 		 DXI.DXI_BLOCO  = '"+(cAliasQryPri)->DXQ_BLOCO+"'  AND 
			cQuerySec += " 		 DXI.DXI_SAFRA  = '"+(cAliasQryPri)->DXQ_SAFRA+"' "
			
			cAliasQrySec := GetNextAlias()
			cQuerySec := ChangeQuery(cQuerySec)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySec),cAliasQrySec,.T.,.T.)
			DbSelectArea( cAliasQrySec ) 	
			
			oReport:SkipLine(2)
			oS2:Init()	
					
			While .Not. (cAliasQrySec)->(Eof())

		
				oS2:aCell[1]:SetValue( (cAliasQrySec)->DXI_ETIQ 	)					
				oS2:aCell[2]:SetValue( (cAliasQrySec)->DXI_BLOCO 	)					
				oS2:aCell[3]:SetValue( (cAliasQryPri)->DXQ_TIPO 	)					
				oS2:aCell[4]:SetValue( (cAliasQrySec)->DX7_FIBRA 	)					
				oS2:aCell[5]:SetValue( (cAliasQrySec)->DXI_PSESTO 	)					
				oS2:aCell[6]:SetValue( (cAliasQrySec)->DX7_MIC 	    )					
				oS2:aCell[7]:SetValue( (cAliasQrySec)->DX7_UHM 		)					
				oS2:aCell[8]:SetValue( (cAliasQrySec)->DX7_RES 		)					
				oS2:aCell[9]:SetValue( (cAliasQrySec)->DX7_SFI 		)					
				oS2:aCell[10]:SetValue( (cAliasQrySec)->DX7_UI 		)					
				oS2:aCell[11]:SetValue( (cAliasQrySec)->DX7_CSP 	)					
				oS2:aCell[12]:SetValue( (cAliasQrySec)->DX7_ELONG 	)					
				oS2:aCell[13]:SetValue( (cAliasQrySec)->DX7_AREA 	)					
				oS2:aCell[14]:SetValue( (cAliasQrySec)->DX7_COUNT 	)					
				
				oS2:PrintLine()
				
				
				(cAliasQrySec)->(DbSkip())
			
			EndDo
			(cAliasQryPri)->(dbSkip())
			
			oS2:Finish()
			oS1:Finish()
			
			//se tiver mais registros quando muda cabeçalho pula página 
			If .Not. (cAliasQryPri)->(Eof())
				oReport:EndPage()
			EndIf
			
		EndDo
		
		(cAliasQryPri)->( dbCloseArea() )
	EndIf

Return( oReport )


/*{Protheus.doc} ReportDef
Constrói o layout do relatório
@author felipe.mendes / marina.muller
@since 20/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static Function ReportDef()
	Local oReport		:= Nil
    Local oBreakFaz     := Nil
    Local oSection1     := Nil    
    Local oSection2     := Nil
    
    //Tradução de String - INICIO  ------------------------------------------------	
        
    TraduzString()

 	oReport 	:= TReport():New("OGAR060",cStrTitulo,"",{|oReport| PrintReport(oReport)},cStrTitulo)
	oReport:SetLandScape()       	
	oReport:HideFooter() 
    oReport:SetTotalInLine(.F.)
    oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:oPage:nPapersize := 9     

	//Seção 1 - Cabeçalho
	oSection1 := TRSection():New( oReport, "", {"DXI"} ) 
	oSection1:lLineStyle := .T. 
	TRCell():New( oSection1, "CLIENTE",  ,/*"Cliente"*/ cStrCliente ,      "@!", 30, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "CONTRATO", ,/*"Contrtato"*/ cStrContrato,      "@!", 30, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "TAKEUP",   ,/*"Take-up"*/ cStrTakeup,      "@!", 30, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "CLASSIF",  ,/*"Clssificador"*/ cStrClassif, "@!", 30, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "PERIODO",  ,/*"Período de Embarque"*/cStrPeríodo, "@!", 30, .T., /*Block*/, , , "LEFT", .T.)
 

    //dados do relatório
    oSection2 := TRSection():New( oReport, "", {"DXQ"})
	oSection2:lLineStyle := .F.
	oSection2:lAutoSize  := .F.
    TRCell():New(oSection2,"DXQ_FILORG", "DXQ", cStrFazend, PesqPict("DXQ","DXQ_FILORG"), 20) 		
    TRCell():New(oSection2,"DXQ_BLOCO",  "DXQ", cStrBloco,  PesqPict("DXQ","DXQ_BLOCO"), TamSX3("DXQ_BLOCO" )[1])     
    TRCell():New(oSection2,"QUANT",          ,  cStrFards,  "@E 99999", 4) 		    	    
    TRCell():New(oSection2,"PESO",           ,  cStrPeso,   "@E 9999999999999.99", 15) 		 	
    TRCell():New(oSection2,"DXQ_TIPO",  "DXQ",  cStrTipo,   PesqPict("DXQ","DXQ_TIPO"), TamSX3("DXQ_TIPO" )[1])      
    
    //colunas exibidas de acordo com tipo do relatório
    If MV_PAR12 == 2 //2 - Analítico
	    TRCell():New(oSection2,"UHM", "DX7",  /*"Uhm"*/ STR0013, PesqPict("DX7","DX7_UHM")  ,TamSX3("DX7_UHM" )[1])      
		TRCell():New(oSection2,"RES", "DX7",  /*"Res"*/ STR0014, PesqPict("DX7","DX7_RES")  ,TamSX3("DX7_RES" )[1])      
	    TRCell():New(oSection2,"MIC", "DX7",  /*"Mic"*/ STR0015, PesqPict("DX7","DX7_MIC")  ,TamSX3("DX7_MIC" )[1])      
	 EndIF
    

    //totalização do relatório
    oBreakFaz   := TRBreak():New(oSection2, { || DXQ->DXQ_FILORG} , cStrTotFaz, .F., 'NOMEBRKFAZ',  .F.)	//"Total Fazenda"
    oBreakFaz:OnPrintTotal({|| oReport:skipLine(2)})

    TRFunction():New(oSection2:Cell("QUANT"),,   "SUM",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    TRFunction():New(oSection2:Cell("PESO"),,    "SUM",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
    
    //total fazenda exibido de acordo com tipo do relatório
    If MV_PAR12 == 2 //2 - Analítico
	    TRFunction():New(oSection2:Cell("UHM"),, "SUM",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
	    TRFunction():New(oSection2:Cell("RES"),, "SUM",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
	    TRFunction():New(oSection2:Cell("MIC"),, "SUM",oBreakFaz,,,,.F.,.F.,.F.,   oSection2)
	EndIf
   
 	oSum1 := TRFunction():New(oSection2:Cell("QUANT"), Nil, "SUM" , , , , , .f., .f. )
    oSum1:SetEndReport(.T.)

    oSum2 := TRFunction():New(oSection2:Cell("PESO") , Nil, "SUM" , , , , , .f., .f. )
    oSum2:SetEndReport(.T.)
    
    //total geral exibido de acordo com tipo do relatório
    If MV_PAR12 == 2 //2 - Analítico
	    oSum3 := TRFunction():New(oSection2:Cell("UHM") , Nil, "SUM" , , , , , .f., .f. )
	    oSum3:SetEndReport(.T.)
    
     	oSum4 := TRFunction():New(oSection2:Cell("RES") , Nil, "SUM" , , , , , .f., .f. )
     	oSum4:SetEndReport(.T.)
    
     	oSum5 := TRFunction():New(oSection2:Cell("MIC") , Nil, "SUM" , , , , , .f., .f. )
     	oSum5:SetEndReport(.T.)
	EndIf
       
Return( oReport )


/*/{Protheus.doc} PrintReport
//Imprime o relatório
@author felipe.mendes / marina.muller
@since 12/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport( oReport ) 	
    Local cNomeEmp      := ""
	Local cNmFil        := ""
	Local oS1		   := oReport:Section(1)
	Local oS2		   := oReport:Section(2)
	Local cQueryPri    := ""
	Local cQuerySec    := ""
	Local cAliasQryPri := ""
	Local cAliasQrySec := ""
	Local cDataIni     := ""
	Local cDataFim     := ""

    oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

	cQueryPri := " SELECT distinct N9A.N9A_FILORG, DXP.DXP_CODIGO, NJR.NJR_CODENT, NJR.NJR_LOJENT, NJR.NJR_CTREXT, DXP.DXP_CLAINT, N9A.N9A_DATINI, N9A.N9A_DATFIM "  
	cQueryPri += "   FROM  " + RetSqlName('DXP') + " DXP "
	cQueryPri += " 	INNER JOIN " + RetSqlName('NJR') + " NJR ON DXP.DXP_CODCTP = NJR.NJR_CODCTR AND NJR.D_E_L_E_T_ = 	'' "
	cQueryPri += " 	 LEFT  JOIN " + RetSqlName('N9A') + " N9A ON N9A.N9A_CODCTR = NJR.NJR_CODCTR AND N9A.D_E_L_E_T_ = 	'' "
	cQueryPri += "  WHERE DXP.D_E_L_E_T_ = ' ' "

	If !Empty(MV_PAR01) //Filial de
		cQueryPri += " AND N9A.N9A_FILORG >= '"+MV_PAR01+"'"
	EndIf
	If !Empty(MV_PAR02)//Filial Até
		cQueryPri += " AND N9A.N9A_FILORG <= '"+MV_PAR02+"'"
	EndIf
	If !Empty(MV_PAR03)// Ctr Externo de
		cQueryPri += " AND NJR.NJR_CTREXT  >=  '"+MV_PAR03+"'"
	EndIf
	If !Empty(MV_PAR04)//Ctr Externo até 
		cQueryPri += " AND NJR.NJR_CTREXT <=  '"+MV_PAR04+"'"
	EndIf
	If !Empty(MV_PAR05)//Entidade de
		cQueryPri += " AND NJR.NJR_CODENT  >=  '"+MV_PAR05+"'"
	EndIf
	If !Empty(MV_PAR06)//Loja de
		cQueryPri += " AND NJR.NJR_LOJENT  >=  '"+MV_PAR06+"'"
	EndIf
	If !Empty(MV_PAR07)//Entidade até
		cQueryPri += " AND NJR.NJR_CODENT <=  '"+MV_PAR07+"'"
	EndIf
	If !Empty(MV_PAR08)// loja até
		cQueryPri += " AND NJR.NJR_LOJENT <=  '"+MV_PAR08+"'"
	EndIf
	If !Empty(MV_PAR09)//Período Embarque de
		cQueryPri += " AND (N9A.N9A_DATINI >= '"+dtos(MV_PAR09)+"' OR N9A.N9A_DATFIM >= '"+dtos(MV_PAR09)+"' ) "
	EndIf
	If !Empty(MV_PAR10)//Período Embarque até
		cQueryPri += " AND (N9A.N9A_DATINI <= '"+dtos(MV_PAR10)+"' OR N9A.N9A_DATFIM <= '"+dtos(MV_PAR10)+"' ) "
	EndIf
	
	cAliasQryPri := GetNextAlias()
	cQueryPri := ChangeQuery(cQueryPri)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryPri),cAliasQryPri,.T.,.T.)
	DbSelectArea( cAliasQryPri ) 	

	If .Not. (cAliasQryPri)->(Eof())
		
		While .Not. (cAliasQryPri)->(Eof())
			oS1:Init()
			
			cDataIni := (cAliasQryPri)->N9A_DATINI
			cDataIni := SubStr(cDataIni, 7, 2) + '/' + SubStr(cDataIni, 5, 2) + '/' + SubStr(cDataIni, 1, 4)
			cDataFim := (cAliasQryPri)->N9A_DATFIM
			cDataFim := SubStr(cDataFim, 7, 2) + '/' + SubStr(cDataFim, 5, 2) + '/' + SubStr(cDataFim, 1, 4)
			
			//atribui valor cabeçalho
			oS1:aCell[1]:SetValue(getCliente((cAliasQryPri)->NJR_CODENT, (cAliasQryPri)->NJR_LOJENT))
			oS1:aCell[2]:SetValue((cAliasQryPri)->NJR_CTREXT)
			oS1:aCell[3]:SetValue((cAliasQryPri)->DXP_CODIGO)
			oS1:aCell[4]:SetValue(getClassif((cAliasQryPri)->DXP_CLAINT))
			oS1:aCell[5]:SetValue(cDataIni + " - " + cDataFim)
			
			//imprime cabeçalho
			oS1:PrintLine()

			If MV_PAR12 == 1 // 1 - Sintético 
			
				cQuerySec := " Select DXQ_FILORG, DXQ_BLOCO, Count(DXI_CODIGO) AS QUANT, SUM(DXI_PSESTO) AS PESO, DXQ_TIPO from " + RetSqlName("DXI") + " DXI "
				cQuerySec += " INNER JOIN " + RetSqlName("DXQ") + " DXQ ON DXQ.DXQ_CODRES =  DXI.DXI_CODRES AND DXQ.DXQ_FILORG = DXI.DXI_FILIAL AND DXQ.DXQ_BLOCO = DXI.DXI_BLOCO "
				cQuerySec += " WHERE DXQ.DXQ_CODRES = '" + (cAliasQryPri)->DXP_CODIGO  + "'  AND DXQ.D_E_L_E_T_	= 	'' "
				cQuerySec += " GROUP BY DXQ_FILORG, DXQ_BLOCO, DXQ_TIPO "
				
			ElseIf MV_PAR12 == 2 // 2 - Analítico
			
				cQuerySec := " SELECT DXQ_FILORG, DXQ_BLOCO, DXQ_TIPO, COUNT(DXI_ETIQ) AS QUANT, SUM(DXI_PSLIQU) AS PESO, AVG(DX7_MIC) AS MIC, AVG(DX7_RES) AS RES, AVG(DX7_UHM) AS UHM "
				cQuerySec += " FROM " + RetSqlName('DXQ') + " DXQ "
				cQuerySec += "  INNER JOIN " + RetSqlName('DXI') + " DXI ON DXI.D_E_L_E_T_ = ' ' AND DXI_FILIAL = DXQ_FILORG AND DXI_CODRES = DXQ_CODRES AND DXI_ITERES = DXQ_ITEM AND DXI_BLOCO = DXQ_BLOCO AND DXI_SAFRA = DXQ_SAFRA "
				cQuerySec += "  LEFT JOIN  " + RetSqlName('DX7') + " DX7 ON DX7.D_E_L_E_T_ = ' ' AND DX7_FILIAL = DXI_FILIAL AND DX7_SAFRA = DXI_SAFRA AND DX7_ETIQ = DXI_ETIQ "
				cQuerySec += " WHERE DXQ.D_E_L_E_T_ = ' ' "
				cQuerySec += "  AND DXQ.DXQ_CODRES = '" +(cAliasQryPri)->DXP_CODIGO+ "'"
				cQuerySec += " GROUP BY DXQ_FILORG, DXQ_BLOCO, DXQ_TIPO "

			EndIf
		
			cAliasQrySec := GetNextAlias()
			cQuerySec := ChangeQuery(cQuerySec)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySec),cAliasQrySec,.T.,.T.)
			DbSelectArea( cAliasQrySec ) 	
			
			If .Not. (cAliasQrySec)->(Eof())
				oReport:SkipLine(2)
				oS2:Init()
				
				While .Not. (cAliasQrySec)->(Eof())	
					oS2:aCell[1]:SetValue(FWFilialName(,(cAliasQrySec)->DXQ_FILORG ,1 ))
					oS2:aCell[3]:SetValue((cAliasQrySec)->QUANT)
					oS2:aCell[4]:SetValue((cAliasQrySec)->PESO)
					
					If MV_PAR12 == 2 // 2 - Analítico
						oS2:aCell[6]:SetValue((cAliasQrySec)->UHM)
						oS2:aCell[7]:SetValue((cAliasQrySec)->RES)
						oS2:aCell[8]:SetValue((cAliasQrySec)->MIC)
						
					Endif
					oS2:PrintLine()
					
					(cAliasQrySec)->( dbSkip() )
					
				EndDo
				(cAliasQrySec)->( dbCloseArea() )
				
				oS2:Finish()
			EndIf	

			
			(cAliasQryPri)->(dbSkip())
			
			//se tiver mais registros quando muda cabeçalho pula página 
			If .Not. (cAliasQryPri)->(Eof())
				oReport:EndPage()
			EndIf

			oS1:Finish()
			
		EndDo
		(cAliasQryPri)->( dbCloseArea() )
	EndIf
	
Return .t.
	
/*/{Protheus.doc} AGRARCabec
//Cabecalho customizado do report
@author felipe.mendes / marina.muller
@since 12/12/2018
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function AGRARCabec(oReport, cNmEmp , cNmFilial)
	Local aCabec := {}
	Local cChar	 := CHR(160)  // caracter dummy para alinhamento do cabeçalho

	If SM0->(Eof())
		SM0->( MsSeek( cEmp/Ant + cFilAnt , .T. ))
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
	AADD(aCabec, STR0018 + ":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio

Return aCabec

/*/{Protheus.doc} getCliente
//Busca pela entidade/loja o cliente/loja/descrição
@author felipe.mendes / marina.muller
@since 12/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cEntidade, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Static Function getCliente(cEntidade, cLoja)
	Local cRet     := ""
	Local cCliente := ""
	Local cLojCli    := ""
	
	If !Empty(cEntidade)
		cCliente := Posicione("NJ0",1,FWxFilial("NJ0")+cEntidade+cLoja,"NJ0_CODCLI")
		cLojCli  := Posicione("NJ0",1,FWxFilial("NJ0")+cEntidade+cLoja,"NJ0_LOJCLI")
		cRet     := cCliente + "/" + cLojCli + " - " + Posicione("SA1",1,FWxFilial("SA1")+cCliente+cLojCli,"A1_NOME")
	EndIf	
	
Return cRet

/*/{Protheus.doc} getClassif
//Busca o nome do classificador
@author felipe.mendes / marina.muller
@since 12/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cClass, characters, descricao
@type function
/*/
Static Function getClassif(cClass)
	Local cRet     := ""
	Local cNomeCla := ""
	
	If !Empty(cClass)
		cNomeCla := Posicione("NNA",1,FWxFilial("NNA")+cClass,"NNA_NOME")  
		cRet     := cClass + " - " + cNomeCla 
	EndIf	
	
Return cRet

/*/{Protheus.doc} TraduzString
//Busca o nome do classificador
@author felipe.mendes
@since 12/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cClass, characters, descricao
@type function
/*/
Static Function TraduzString()

    If MV_PAR11 == 1 //Português
        
        If MV_PAR12 == 1 //1 - Sintético
        	cStrTitulo := STR0002 // "Resultado Take-Up Sintético"
		
		ElseIF MV_PAR12 == 2 //2 - Analítico
			cStrTitulo := STR0001 //"Resultado Take-Up Analítico"
		
		ElseIF MV_PAR12 == 3 //3 - Detalhado
			cStrTitulo := STR0019 //"Resultado Take-Up Detalhado"
		EndIf
	    
	    cStrCliente   := STR0003 //'Cliente: '
	    cStrContrato  := STR0004 //'Contrato: '
	    cStrTakeup    := STR0005 //'Take-up: '
	    cStrClassif   := STR0006 //'Classificador: '
	    cStrPeríodo   := STR0007 //'Período de Embarque: '
	    cStrFazend    := STR0008 //'Fazenda'
	    cStrBloco     := STR0009 //'Bloco'
	    cStrFards     := STR0010 //'Fds.'
	    cStrPeso      := STR0011 //'Peso Liq. (kg)'
	    cStrTipo      := STR0012 //'Tipo'
	    
	    cStrTotFaz    := STR0016 //"Total Fazenda"
	    cStrFardo     := STR0020 //'Fardo'
	    cStrSafra     := STR0021 //"Safra"
	    cStrTotMed    := STR0022
	    cStrTotalF    := STR0023
	    
    ElseIf MV_PAR11 = 2 // Inglês
    
        If MV_PAR12 == 1 //1 - Sintético
        	cStrTitulo := "Quality Report"
		
		ElseIF MV_PAR12 == 2 //2 - Analítico
			cStrTitulo := "Quality Report"
		
		ElseIF MV_PAR12 == 3 //3 - Detalhado
			cStrTitulo := "Quality Report - Bale by Bale "
		EndIf
	    cStrCliente   := 'Client '
	    cStrContrato  := 'Contract Number '
	    cStrTakeup    := 'Reservation Number '
	    cStrClassif   := 'Classifier '
	    cStrPeríodo   := 'Shipment '
	    cStrFazend    := 'Farm'
	    cStrBloco     := 'Lot'
	    cStrFards     := 'N. of Bales.'
	    cStrPeso      := 'Net Weight'
	    cStrTipo      := 'Quality'    
	    
	    cStrTotFaz    := "Total Farm"
	    cStrSafra     := "Crop"
	    cStrFardo     := 'Bale'
	    cStrTotMed    := 'Total/Average'
	    cStrTotalF    := "Total of Classified Bales"
    EndIf
	
Return 
