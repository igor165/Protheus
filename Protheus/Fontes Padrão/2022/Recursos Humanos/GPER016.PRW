#INCLUDE "PROTHEUS.CH"   
#INCLUDE "report.ch"    
#INCLUDE "GPER016.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER016   ºAutor  ³Claudinei Soares    º Data ³ 22/05/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para comparação de valores onerados/desonerados   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Folha de pagamento  - Brasil                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador³ Data     ³    FNC     | Motivo da Alteracao                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºClaudinei S.|26/05/2017|DRHPAG-2218|Inclusao do relatorio               º±±
±±ºClaudinei S.|30/05/2017|DRHPAG-2485|Ajustada a geração Gráfico ou Relat.º±±
±±º            |          |           |Incluídas nova dicas no gráfico.    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GPER016()
 	Local		oReport                             
 	Local		aArea 			:= GetArea()
  	Local aSays		   	:= {}
	Local aButtons	   	:= {}
	Local nOpcA		  	:= 0.00

	Private	aInssEmpR		:= {}
	Private  	cPerg        	:= "GPER016"
 	Private 	cString		:= GetNextAlias()	// Alias do Arquivo Principal
 	Private 	lCorpManage	:= fIsCorpManage(FWGrpCompany())
	Private 	cQrySRA		:= ""
	Private	nPerEmp		:= 0
	Private  	cRecFatEmp		:= ""
	Private	nPerE			:= ""
	Private	nPerR			:= ""
	Private 	nTotal			:= 0
	Private	nTotDeson		:= 0
	Private 	nTotOnera		:= 0
  	Private 	nTotalGral		:= 0
	Private	nPerFatEmp		:= 0
	Private	nContrDev		:= 0
	Private 	lDissidio		:= .T.
  	Private 	cPagtoR016		:= ""
 	If lCorpManage
		Private lEmpFil		:= !Empty(FWSM0Layout(cEmpAnt, 1))  
		Private cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		Private nStartEmp	   	:= At("E",cLayoutGC)
		Private nStartUnN	   	:= At("U",cLayoutGC)
		Private nEmpLength   	:= Len(FWSM0Layout(cEmpAnt, 1))
		Private nUnNLength   	:= Len(FWSM0Layout(cEmpAnt, 2))
 	EndIf

Private aAreaSRA		:= SRA->( GetArea() )
Private cCadastro 	:= OemToAnsi(STR0001) //"Valores de Desoneração/Oneração por Funcionário"

Private cSraFilter	:= ""
Private aRetFiltro	:= {}
Private aFilterExp	:= {} 

Pergunte(cPerg, .F.)

aAdd(aSays,OemToAnsi(STR0016))			//"Esta rotina tem por objetivo gerar um comparativo dos valores com a desoneração "
aAdd(aSays,OemToAnsi(STR0017))			//"e sem a desoneração, seja em um gráfico, relatório ou em ambos."
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
FormBatch( cCadastro, aSays, aButtons )

IF nOpcA == 1
	Processa({|lEnd| fGR016Proc(cPerg),STR0001})  ////"Valores de Desoneração/Oneração por Funcionário"
EndIF

//Restaura os Dados de Entrada						   	        
RestArea( aAreaSRA ) 
RestArea( aArea )
Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fGR016Proc ³ Autor ³ Claudinei Soares      ³ Data ³29/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Chama a impressão do relatório, do gráfico ou ambos, conforme³±±
±±³          ³ a parametrização.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER016                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fGR016Proc(cPerg)

	Local aArea		:= GetArea()
	Private nTipGera	:= MV_PAR07 //Opção de Processamento       
	
	If Empty(cPagtoR016) .Or. cPagtoR016 == "00" 
		cPagtoR016 := "01"
	Endif

	If nTipGera == 1 //Impressão do Relatório
	
		oReport := ReportDef()
	 	oReport:PrintDialog()
	
	Elseif nTipGera == 2 // Geração do Gráfico 
	
		fGeraGraf(nTotDeson,nTotOnera,nTotalGral)
	
	Else
	
		oReport := ReportDef() //Impressão do Relatório e Geração do Gráfico
	 	oReport:PrintDialog()
	 	fGeraGraf(nTotDeson,nTotOnera,nTotalGral)
	
	EndIf
	
	RestArea( aArea )
 	 	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Claudinei Soares      ³ Data ³22/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio para comparação de valores onerados/desonerados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER016                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()   
	Local oReport
 	Local oBreakPg                                    
 	Local oSection1
 	Local oSection2
 	Local cTitulo := STR0001
 	//Local cPerg   := "GPER016"
 	//Pergunte( cPerg , .F. )
	
	//Definição do Relatório
  	DEFINE REPORT oReport NAME "GPER016" TITLE OemToAnsi(cTitulo)  PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION ""
 	oReport:SetLandscape()
	//-- Dados do Funcionário
	DEFINE SECTION oSection1 OF oReport TABLES "SRA" TITLE OemToAnsi(cTitulo) TOTAL IN COLUMN
	oSection1 :SetHeaderSection()
	//--- CELL HEADER BORDER
  	DEFINE CELL NAME "RA_FILIAL"  	OF oSection1 TITLE oemToAnsi(STR0002) SIZE 08 PICTURE "@!"	;	//"Filial"
 	BLOCK {||(cQrySRA)->RA_FILIAL}

	DEFINE CELL NAME "RA_CC"			OF oSection1 TITLE oemToansi(STR0006) SIZE 13 PICTURE "@!"	;	//"Nome"
	BLOCK {||(cQrySRA)->RA_CC}
 	
 	DEFINE CELL NAME "RA_MAT"  		OF oSection1 TITLE OemToAnsi(STR0003) SIZE 08 PICTURE "@!"	;	//"Matrícula"
	BLOCK {||(cQrySRA)->RA_MAT}
 	
 	DEFINE CELL NAME "RA_NOME" 	    OF oSection1 TITLE oemToansi(STR0004) SIZE 30 PICTURE "@!"	;	//"Nome"
	BLOCK {||(cQrySRA)->RA_NOME}
	
		//-- oSection2
	DEFINE SECTION oSection2 		OF oSection1 TABLES " " TITLE " "
    oSection2 :SetHeaderSection()

Return oReport   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PrintReport³ Autor ³ Claudinei Soares      ³ Data ³22/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio para comparação de valores onerados/desonerados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER016                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PrintReport(oReport)     
	//-- Objetos Section para montagem do Relatório
  	Local oSection1 := oReport:Section(1) 		// Detalhe
  	Local oSection2 := oReport:Section(1):Section(1) 		// Dados do Funcionário
	//-- Variaveis
  	Local oValor1
  	Local oSumVal
  	Local oBreakFil	   
  	Local oBreakEFilLocal
  	Local oTotFunc
  	Local aTabS033 		:= {}
  	Local cFiltro    		:= ""
  	Local cSitQuery  		:= ""
  	Local cCatQuery  		:= ""
  	Local cFilR016   		:= ""
  	Local cCtoCusto 		:= ""
  	Local cMatricula    	:= ""
  	Local cNome    	   	:= ""
  	Local cSituac   		:= MV_PAR05
  	Local cCategoria 		:= MV_PAR06
  	Local cProcR016		:= IIF(ValType("MV_PAR08")=="N",STRZERO(MV_PAR08,6),MV_PAR08)
  	Local cRotR016 		:= MV_PAR09
  	Local cPerR016 		:= MV_PAR10
  	Local cPrefx     		:= "" 
  	Local cAliasAux  		:= ""
  	Local cTitEFil  		:= ""
  	Local cStPer1 		:= ""
  	Local lImprimir 		:= .T.      
  	Local nValor 			:= 0
  	Local cFilImpr 		:= 0
  	Local cCod    		:= ""
  	Local cTpC				:= ""
  	Local nReg				:= 0
  	Local nS33				:= 0
  	Local cFilR016SRA 	:= xFilial("SRA")
  	Local cFilR016SRV 	:= xFilial("SRV")
	//--- Variaveis para totalizar por funcionário  
  	Local nSumVal 		:= 0                   
  	Local nValOne 		:= 0
  	Local nValDes			:= 0
	//--- Totais Gerais  
  	Local nTotalDes		:= 0
  	Local dDataParam		:= CTOD("01/"+ Substr(MV_PAR10,5,2)+"/"+Substr(MV_PAR10,1,4))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Perguntas selecionadas - GPER016                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	//Local cPerg   := "GPER016"
 	//Pergunte( cPerg , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Variaveis utilizadas para parametros                                  	//
// mv_par01     // Filial?                                             	//
// mv_par02     // Centro de Custo?                                     	//
// mv_par03     // Matrícula?                                            	//
// mv_par04     // Nome?                                               	//
// mv_par05     // Situações?                                          	//
// mv_par06     // Categorias?                                         	//
// mv_par07     // Processo?                                            	//
// mv_par08     // Roteiro?                                        		//
// mv_par09     // Periodo?                                            	//
// mv_par10     // Nº Pagamento?                                         	//
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(cPerg)

  	cFilR016 	:= MV_PAR01
  	cCtoCusto	:= MV_PAR02
  	cMatricula	:= MV_PAR03
  	cNome    	:= MV_PAR04
 	cPagtoR016	:= MV_PAR11
	cQrySRA	:= GetNextAlias()

   	If !Empty(cFilR016)
        	cFiltro += " AND SRA."+ substr(cFilR016,2,len(cFilR016)-2)// Filtro Filial
   	EndIf

   	If !Empty(cCtoCusto)
			cFiltro += " AND SRA."+ substr(cCtoCusto,2,len(cCtoCusto)-2)// Filtro de Centro de Custo
   	EndIf

   	If !Empty(cMatricula)
			cFiltro += " AND SRA."+ substr(cMatricula,2,len(cMatricula)-2)// Filtro Matricula
   	EndIf 
 	
   	If !Empty(cNome)
			cFiltro += " AND SRA."+ substr(cNome,2,len(cNome)-2)// Filtro Nome
   	EndIF

   	For nReg:=1 to Len(cSituac) 	//-- Filtro para Situações
			cSitQuery += "'"+Subs(cSituac,nReg,1)+"'"
			If ( nReg+1 ) <= Len(cSituac)
				cSitQuery += "," 
			Endif
   	Next nReg        
	
   	cCategoria = Alltrim(cCategoria) //-- Filtro para Categorias	                               
   	For nReg:=1 to Len(cCategoria)
     		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	   		If ( nReg+1 ) <= Len(cCategoria)
				cCatQuery += "," 
	   		Endif
   	Next nReg

	//--- Título a ser impresso no relatório 	
   	oReport:CTITLE := STR0001+" " +STR0021+" "+cPerR016
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Verifica se existe o periodo na RCH e define    ?
	//?que tabela usar SRC ou SRD.                     ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
	//--- Verifica se o periodo existe na RCH  
   	
   	If lImprimir      
     	Dbselectarea("RCH")                                                 
	 	RCH ->(DBSETORDER(1)) 
	 	
	 	If Empty(cProcR016)
	 		cProcR016 := ""
		Endif

	 	If !Empty(cRotR016)
	 		RCH ->(	Dbseek(xFilial("RCH")+cProcR016+cPerR016+cPagtoR016+cRotR016)) // Determina se o Periodo 1 esta Aberto ou Fechado
	 	Else
	 		RCH ->(	Dbseek(xFilial("RCH")+cProcR016+cPerR016+cPagtoR016)) // Determina se o Periodo 1 esta Aberto ou Fechado
	 	Endif
	
	 	IF (EMPTY(RCH->RCH_DTFECH) .AND.(!EOF()))                                 
			cPrefx    	:= "RC"    //  Valor se o periodo estiver aberto
			cAliasAux 	:= "SRC"
			cStPer1 	:="A"
	 	ELSE
	    	IF !EOF()
		  		cPrefx    	:= "RD"    //  Valor se o periodo estiver fechado 
		  		cAliasAux 	:= "SRD"
		  		cStPer1 	:="C"
		  		lImprimir 	:= .t.
	    	ELSE
		  		lImprimir := .f.  // Se não encontrar dados na RCH manda um Aviso
//		  		Aviso( STR0024,STR0023+cPerR016+" "+cPagtoR016, {"Ok"} )
			ENDIF
     	ENDIF
   	ENDIF   ///   Fim da Verificação do período na RCH  
   	If !lImprimir
		return NIL
	EndIf
	//--- Monta a Query para o Relatório   
  	If lImprimir
		DEFINE CELL NAME "BASEINSS"  	OF oSection1 ALIAS cString TITLE oemToansi(STR0011) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "PERCONERA"	OF oSection1 ALIAS cString TITLE oemToansi(STR0012) SIZE 6  PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALONERADO"	OF oSection1 ALIAS cString TITLE oemToansi(STR0005) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "PERCDESON"	OF oSection1 ALIAS cString TITLE oemToansi(STR0013) SIZE 6  PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT		
		DEFINE CELL NAME "VALDESONER"	OF oSection1 ALIAS cString TITLE oemToansi(STR0007) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "CONTDEVID"	OF oSection1 ALIAS cString TITLE oemToansi(STR0014) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALTOTBAS"	OF oSection1 ALIAS cString TITLE "" SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALTOTONE"	OF oSection1 ALIAS cString TITLE "" SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALTOTDES"	OF oSection1 ALIAS cString TITLE "" SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		
		//--- Monta a Query se os dados estiverem na mesma tabela (SRD, SRC) dependendo se os periodos estiverem abertos ou fechados   
 		cQuery := " 	SELECT  RA_FILIAL,RA_MAT,RA_NOME,RA_CC, RA_TPCONTR,"
		cQuery += "	SUM(CASE WHEN "+cPreFx+"_PERIODO = '"+cPerR016+"' AND "+cPreFx+"_SEMANA = '"+cPagtoR016+"' THEN "+cPreFx+"_VALOR ELSE 0 END) AS REFVAL1 " //Column 10	
		cQuery += "	FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA "
		cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
		cQuery += "  	"+cAliasAux+"."+cPrefx+"_FILIAL     = SRA.RA_FILIAL      AND "
		cQuery += "	"+cAliasAux+"."+cPrefx+"_MAT        = SRA.RA_MAT         AND " 
		cQuery += "	"+cAliasAux+".D_E_L_E_T_ = ' ' "
		cQuery += "	WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
		cQuery += "	SRV.RV_CODFOL IN ('0013','0014','0019','0020','0221','0225') AND "
		cQuery += "	SRV.RV_COD 		="+cAliasAux+"."+cPreFX+"_PD    AND"		      
	   	cQuery += "  	SRV.RV_FILIAL 	= '"+cFilR016SRV+"'            AND  "
	  	cQuery += "  	SRA.RA_FILIAL 	= '"+cFilR016SRA+"'            AND  " 
	   	cQuery += "	SRA.RA_CATFUNC	IN	("+cCatQuery+") 	  AND " 
	   	If !Empty(MV_PAR07)
	   		cQuery += "	SRA.RA_PROCES    	=  '"+cProcR016+"'  AND "
	   	Endif
	   	If !Empty(cRotR016)
	   		cQuery += "  	"+cAliasAux+"."+cPrefx+"_ROTEIR     = '"+cRotR016+"'      AND "
	   	Endif
	   	cQuery += "  	"+cAliasAux+"."+cPrefx+"_SEMANA     = '"+cPagtoR016+"'      AND "
	   	cQuery += "	SRA.D_E_L_E_T_  	= ' '      AND"
	   	cQuery += "	SRV.D_E_L_E_T_  	= ' '      "
		//--- Junta os filtros a Query    
   		If !EMPTY(cFiltro)    
	    		cQuery += cFiltro
		Endif
   		cQuery += " GROUP BY RA_FILIAL,RA_MAT,RA_NOME, RA_CC, RA_TPCONTR "
		cQuery += "  ORDER BY RA_FILIAL,RA_CC,RA_MAT, RA_TPCONTR"
    	cQuery := ChangeQuery(cQuery) 	
    	IF Select(cQrySRA) > 0
				(cQrySRA)->( DBCLOSEAREA() )		
    	ENDIF
    	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
    	nReg := 0
    	Count to nReg
		If lCorpManage
			//--- Totais por Centro de Custo
    		DEFINE BREAK oBreakEFil OF oReport WHEN oSection1:Cell("RA_CC")
			DEFINE FUNCTION oValor1 	FROM oSection1:Cell("BASEINSS")		FUNCTION ONPRINT  OF oSection1 FORMULA {|| nValOne  } BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
			DEFINE FUNCTION oValor1 	FROM oSection1:Cell("VALONERADO")	FUNCTION ONPRINT  OF oSection1 FORMULA {|| nValOne * nPerEmp } BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
			DEFINE FUNCTION oValor1 	FROM oSection1:Cell("VALDESONER")	FUNCTION ONPRINT  OF oSection1 FORMULA {|| nValDes * nPerFatEmp} BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
			oBreakEFil:OnBreak({ |x,y| cTitEFil := Space(70) + OemToAnsi(STR0018)})	
    		oBreakEFil:SetTotalText({ || cTitEFil })
    		oBreakEFil:SetTotalInLine(.F.)
    
			//--- Total Geral
    		DEFINE BREAK oBreakFil OF oReport WHEN oSection1:Cell("RA_FILIAL")
    		DEFINE FUNCTION NAME "VALORPER1"  FROM oSection1:Cell("BASEINSS" ) 	FUNCTION ONPRINT  FORMULA {|| nTotalGral }   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
			DEFINE FUNCTION NAME "VALTOTONE"  FROM oSection1:Cell("VALONERADO" )	FUNCTION ONPRINT  FORMULA {|| nTotalGral * nPerEmp }   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
			DEFINE FUNCTION NAME "VALTOTDES"  FROM oSection1:Cell("VALDESONER" ) 	FUNCTION ONPRINT  FORMULA {|| nTotalGral * nPerFatEmp}   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
			DEFINE FUNCTION NAME "CONTDEVID"  FROM oSection1:Cell("CONTDEVID" ) 	FUNCTION ONPRINT  FORMULA {|| nContrDev}   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
			oBreakFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0019)})	
    		oBreakFil:SetTotalText({ || cTitEFil })
    		oBreakFil:SetTotalInLine(.F.)
		EndIf
		//--- Obtem a quantidade de registros a imprimir e posiciona no primeiro registro do arquivo
		oReport:SetMeter(nReg)
   		( cQrySRA )->(DBGOTOP()) 
		//--- Inicializa Variaveis para controle de totais em quebras
    	nSumVal	:= 0
    	nValOne	:= 0
    	nValDes	:= 0
    	cCod 	  	:= ""
    	cFiliAnt	:= ""
		aTabS033 := {}
		RstGpexIni()
		fCarrTab( @aTabS033, "S033", dDataParam, .T.,, .T. )

		//--- Impressão do relatório
    	WHILE ( cQrySRA )->(!eof())
			oReport:IncMeter()
			//--- Atribui os dados do Funcionário para as variáveis para impressão.
   			cFilImpr 	:= ( cQrySRA )->(RA_FILIAL)
   			cMatImpr 	:= ( cQrySRA )->(RA_MAT)
   			cNomImpr 	:= ( cQrySRA )->(RA_NOME)
   			cCCImpr 	:= ( cQrySRA )->(RA_CC)
   			nValor		:= ( cQrySRA )->(REFVAL1)
			//nTotal 	:= nValOne1
								
			If cFiliAnt <> cFilImpr   
  				fInssEmp(cFilImpr,@aInssEmpR,,cPerR016)
  				
  				If ( cQrySRA )->(RA_TPCONTR) $ " *1"
					cTpC  := "1"
				Else	
					cTpC  := "2"
				EndIf
			
				nPerEmp 	:= aInssEmpR[1, Val(cTpc)]//_%EMP
				cRecFatEmp	:= aInssEmpR[27,Val(cTpc)]//_RECFAT
  				
  				//Calcula a aliquota reduzida que sera aplicada na base do INSS e os valores das receitas
				aCalcDes 	:= fPerFatEmp( cRecFatEmp, 0, aInssEmpR[ 1, Val( cTpC ) ], aTabS033, dDataParam )
	         	nPerFatEmp	:= aCalcDes[1]//Aliquota reduzida
				nRecOut	:= aCalcDes[2]//Receitas de outras atividades
				nRecBruto	:= aCalcDes[3]//Receita bruta
				nRecDes	:= aCalcDes[4]//Receitas de atividades desoneradas
				nExpDes	:= aCalcDes[9]//total das exportações tipo 1
				nExpNDes	:= aCalcDes[10]//total das exportações tipo 2
  				cFiliAnt := cFilImpr   
  				
  				If Len(aTabS033) > 0
	  				For nS33 := 1 To Len(aTabS033)
	  					If aTabS033[nS33,6] == "1"
	  						nContrDev += aTabS033[nS33,9]
	  					Endif
	  				Next nS33
	  			Endif     
  			Endif
			
   			oSection1:cell("BASEINSS"):SetValue(nValor)            		// - Base apurada de INSS
   			oSection1:cell("PERCONERA"):SetValue(nPerEmp * 100)			// - Aliquota apurada onerada (%Empresa)
   			oSection1:cell("VALONERADO"):SetValue(nValor * nPerEmp)		// - Valor Onerado
   			oSection1:cell("PERCDESON"):SetValue(nPerFatEmp * 100)		// - Aliquota reduzida(Percentual Desonerado)	
   			oSection1:cell("VALDESONER"):SetValue(nValor * nPerFatEmp)	// - Valor Desonerado
			//--- Condições para totalizar por Centro de Custo
   			If cCod == (cQrySRA)->(RA_CC)
  				nSumVal := nSumVal + nValor       
  			Endif
			//--- Controle de quebra por Centro de Custo    
   			If cCod <> (cQrySRA)->(RA_CC)
	 			nValOne 	:= nSumVal
	 			If cRecFatEmp <> "S"
	 				nValDes	:= nSumVal
	 			Endif
	 			oSection2:Init()
	 			oSection2:PrintLine()
	 			oSection2:Finish()
	 			oSection1:Finish()
	 			cCod 		:= (cQrySRA)->(RA_CC)         			
	 			nTotalGral	:= nTotalGral + nValOne
	 			If cRecFatEmp <> "S"
	 				 nTotalDes := nTotalGral
	 			Endif
	 			nSumVal	:= nValor
   			Endif
			oSection1:Init()
			oSection1:PrintLine()
  			( cQrySRA )->(dbSkip())
    	ENDDO  
		//--- Finaliza o relatório   
   		oSection1:Finish()
		//--- Imprime Totais Gerais    
   		nValOne 	:= nSumVal       
    	nTotalGral	:= nTotalGral + nValOne
    	If cRecFatEmp <> "S"
    		nValDes 	:= nSumVal
    		nTotalDes	:= ntotalGral + nValDes
    	Endif
		nTotDeson	:= (nTotalGral * nPerFatEmp) + nContrDev
		nTotOnera	:= nTotalGral * nPerEmp

		nPere := nPerEmp * 100
		nPerr := nPerFatEmp * 100

  	Endif  /// Endif da validação dos periodos 
Return NIL


Function fGeraGraf(nTotDeson,nTotOnera,nTotalGral)

  	Local aTabS033 		:= {}
  	Local cFiltro    		:= ""
  	Local cSitQuery  		:= ""
  	Local cCatQuery  		:= ""
  	Local cFilR016   		:= ""
  	Local cCtoCusto 		:= ""
  	Local cMatricula    	:= ""
  	Local cNome    	   	:= ""
  	Local cSituac   		:= MV_PAR05
  	Local cCategoria 		:= MV_PAR06
  	Local cProcR016		:= IIF(ValType("MV_PAR08")=="N",STRZERO(MV_PAR08,6),MV_PAR08)
  	Local cRotR016 		:= MV_PAR09
  	Local cPerR016 		:= MV_PAR10
  	Local cPagtoR016 	  	:= MV_PAR11
  	Local cPrefx     		:= "" 
  	Local cAliasAux  		:= ""
  	Local cTitEFil  		:= ""
  	Local cStPer1 		:= ""
  	Local lImprimir 		:= .T.      
  	Local nValor 			:= 0
  	Local cFilImpr 		:= 0
  	Local cCod    		:= ""
  	Local cTpC				:= ""
  	Local nReg				:= 0
  	Local nS33				:= 0
  	Local cFilR016SRA 	:= xFilial("SRA")
  	Local cFilR016SRV 	:= xFilial("SRV")
  	
  	//--- Variaveis utilizadas nos parametros do gráfico
  	Local cCcDe			:= ""
  	Local cCcAte			:= ""
  	Local cParCc			:= ""
  	Local cFilDe			:= ""
  	Local cFilAte			:= ""
  	Local cParFil			:= ""
	Local cTotGraf		:= ""
  	Local cTotOner		:= "" 
	Local cTotDeso		:= ""
	Local cDiferen		:= ""
 	Local cPerEmp			:= ""
 	Local cPerDes			:= ""
 	Local cPerPagPro		:= ""
 	Local nDiferen		:= 0 	
  	Local nPosFil			:= 0
  	Local nTamFil			:= 0
  	  	
	//--- Variaveis para totalizar por funcionário  
  	Local nSumVal 		:= 0                   
  	Local nValOne 		:= 0
  	Local nValDes			:= 0

	//--- Totais Gerais  
  	Local nTotalDes		:= 0
  	Local dDataParam		:= CTOD("01/"+ Substr(MV_PAR10,5,2)+"/"+Substr(MV_PAR10,1,4))

	//---Fontes
	Local oTFont
	Local oTFont1
	Local oTFont2	

	/*Variaveis para Dimensionar Tela*/	
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aTotais		:= {0,0,0,0,0,0}
	Local oDlg
	Local oFWChart
	Local oFont
	Local oFont1
	Local oFont2

	//Se for gerar somente o gráfico o cálculo precisa ser executado na função do gráfico.
	If nTipGera == 2
	
		MakeSqlExpr(cPerg)
	
	  	cFilR016 	:= MV_PAR01
	  	cCtoCusto	:= MV_PAR02
	  	cMatricula	:= MV_PAR03
	  	cNome    	:= MV_PAR04
	
		cQrySRA	:= GetNextAlias()
	
	   	If !Empty(cFilR016)
	        	cFiltro += " AND SRA."+ substr(cFilR016,2,len(cFilR016)-2)// Filtro Filial
	   	EndIf
	
	   	If !Empty(cCtoCusto)
				cFiltro += " AND SRA."+ substr(cCtoCusto,2,len(cCtoCusto)-2)// Filtro de Centro de Custo
	   	EndIf
	
	   	If !Empty(cMatricula)
				cFiltro += " AND SRA."+ substr(cMatricula,2,len(cMatricula)-2)// Filtro Matricula
	   	EndIf 
	 	
	   	If !Empty(cNome)
				cFiltro += " AND SRA."+ substr(cNome,2,len(cNome)-2)// Filtro Nome
	   	EndIF
	
	   	For nReg:=1 to Len(cSituac) 	//-- Filtro para Situações
				cSitQuery += "'"+Subs(cSituac,nReg,1)+"'"
				If ( nReg+1 ) <= Len(cSituac)
					cSitQuery += "," 
				Endif
	   	Next nReg        
		
	   	cCategoria = Alltrim(cCategoria) //-- Filtro para Categorias	                               
	   	For nReg:=1 to Len(cCategoria)
	     		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
		   		If ( nReg+1 ) <= Len(cCategoria)
					cCatQuery += "," 
		   		Endif
	   	Next nReg
	
		//--- Verifica se o periodo existe na RCH  
	   	
	   	If lImprimir      
	     	Dbselectarea("RCH")                                                 
		 	RCH ->(DBSETORDER(1)) 
		 	If Empty(cPerR016)
		 		cPerR016:= ""
		 	EndIf
		 	If Empty(cProcR016)
		 		cProcR016 := "	"
			Endif			 		
		 	
		 	If Empty(cPagtoR016) .Or. cPagtoR016 == "00" 
		 		cPagtoR016 := ""
		 	Endif
		 	
		 	If !Empty(cRotR016)
		 		RCH ->(	Dbseek(xFilial("RCH")+cProcR016+cPerR016+cPagtoR016+cRotR016)) // Determina se o Periodo 1 esta Aberto ou Fechado
		 	Else
		 		RCH ->(	Dbseek(xFilial("RCH")+cProcR016+cPerR016+cPagtoR016)) // Determina se o Periodo 1 esta Aberto ou Fechado
		 	Endif
		
		 	IF (EMPTY(RCH->RCH_DTFECH) .AND.(!EOF()))                                 
				cPrefx    	:= "RC"    //  Valor se o periodo estiver aberto
				cAliasAux 	:= "SRC"
				cStPer1 	:="A"
		 	ELSE
		    	IF !EOF()
			  		cPrefx    	:= "RD"    //  Valor se o periodo estiver fechado 
			  		cAliasAux 	:= "SRD"
			  		cStPer1 	:="C"
			  		lImprimir 	:= .t.
		    	ELSE
			  		lImprimir := .f.  // Se não encontrar dados na RCH manda um Aviso
			  		Aviso( STR0024,STR0023+cPerR016+" "+cPagtoR016, {"Ok"} )
				ENDIF
	     	ENDIF
	   	ENDIF   ///   Fim da Verificação do período na RCH  
	   	
		//--- Monta a Query para o Relatório   
	  	If lImprimir
			//--- Monta a Query se os dados estiverem na mesma tabela (SRD, SRC) dependendo se os periodos estiverem abertos ou fechados   
	 		cQuery := " 	SELECT  RA_FILIAL,RA_MAT,RA_NOME,RA_CC, RA_TPCONTR,"
			cQuery += "	SUM(CASE WHEN "+cPreFx+"_PERIODO = '"+cPerR016+"' AND "+cPreFx+"_SEMANA = '"+cPagtoR016+"' THEN "+cPreFx+"_VALOR ELSE 0 END) AS REFVAL1 " //Column 10	
			cQuery += "	FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA "
			cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
			cQuery += "  	"+cAliasAux+"."+cPrefx+"_FILIAL     = SRA.RA_FILIAL      AND "
			cQuery += "	"+cAliasAux+"."+cPrefx+"_MAT        = SRA.RA_MAT         AND " 
			cQuery += "	"+cAliasAux+".D_E_L_E_T_ = ' ' "
			cQuery += "	WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
			cQuery += "	SRV.RV_CODFOL IN ('0013','0014','0019','0020','0221','0225') AND "
			cQuery += "	SRV.RV_COD 		="+cAliasAux+"."+cPreFX+"_PD    AND"		      
		   	cQuery += "  	SRV.RV_FILIAL 	= '"+cFilR016SRV+"'            AND  "
		  	cQuery += "  	SRA.RA_FILIAL 	= '"+cFilR016SRA+"'            AND  " 
		   	cQuery += "	SRA.RA_CATFUNC	IN	("+cCatQuery+") 	  AND " 
		   	If !Empty(MV_PAR07)
		   		cQuery += "	SRA.RA_PROCES    	=  '"+cProcR016+"'  AND "
		   	Endif
		   	If !Empty(cRotR016)
		   		cQuery += "  	"+cAliasAux+"."+cPrefx+"_ROTEIR     = '"+cRotR016+"'      AND "
		   	Endif
		   	cQuery += "  	"+cAliasAux+"."+cPrefx+"_SEMANA     = '"+cPagtoR016+"'      AND "
		   	cQuery += "	SRA.D_E_L_E_T_  	= ' '      AND"
		   	cQuery += "	SRV.D_E_L_E_T_  	= ' '      "
			//--- Junta os filtros a Query    
	   		If !EMPTY(cFiltro)    
		    		cQuery += cFiltro
			Endif
	   		cQuery += " GROUP BY RA_FILIAL,RA_MAT,RA_NOME, RA_CC, RA_TPCONTR "
			cQuery += "  ORDER BY RA_FILIAL,RA_CC,RA_MAT, RA_TPCONTR"
	    	cQuery := ChangeQuery(cQuery) 	
	    	IF Select(cQrySRA) > 0
					(cQrySRA)->( DBCLOSEAREA() )		
	    	ENDIF
	    	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
	    	nReg := 0
	    	Count to nReg
	   		( cQrySRA )->(DBGOTOP()) 
			//--- Inicializa Variaveis para controle de totais em quebras
	    	nSumVal	:= 0
	    	nValOne	:= 0
	    	nValDes	:= 0
	    	cCod 	  	:= ""
	    	cFiliAnt	:= ""
			aTabS033 := {}
			RstGpexIni()
			fCarrTab( @aTabS033, "S033", dDataParam, .T.,, .T. )
	
			//--- Impressão do relatório
	    	WHILE ( cQrySRA )->(!eof())
				//--- Atribui os dados do Funcionário para as variáveis para impressão.
	   			cFilImpr 	:= ( cQrySRA )->(RA_FILIAL)
	   			cMatImpr 	:= ( cQrySRA )->(RA_MAT)
	   			cNomImpr 	:= ( cQrySRA )->(RA_NOME)
	   			cCCImpr 	:= ( cQrySRA )->(RA_CC)
	   			nValor		:= ( cQrySRA )->(REFVAL1)
				//nTotal 	:= nValOne1
									
				If cFiliAnt <> cFilImpr   
	  				fInssEmp(cFilImpr,@aInssEmpR,,cPerR016)
	  				
	  				If ( cQrySRA )->(RA_TPCONTR) $ " *1"
						cTpC  := "1"
					Else	
						cTpC  := "2"
					EndIf
				
					nPerEmp 	:= aInssEmpR[1, Val(cTpc)]//_%EMP
					cRecFatEmp	:= aInssEmpR[27,Val(cTpc)]//_RECFAT
	  				
	  				//Calcula a aliquota reduzida que sera aplicada na base do INSS e os valores das receitas
					aCalcDes 	:= fPerFatEmp( cRecFatEmp, 0, aInssEmpR[ 1, Val( cTpC ) ], aTabS033, dDataParam )
		         	nPerFatEmp	:= aCalcDes[1]//Aliquota reduzida
					nRecOut	:= aCalcDes[2]//Receitas de outras atividades
					nRecBruto	:= aCalcDes[3]//Receita bruta
					nRecDes	:= aCalcDes[4]//Receitas de atividades desoneradas
					nExpDes	:= aCalcDes[9]//total das exportações tipo 1
					nExpNDes	:= aCalcDes[10]//total das exportações tipo 2
	  				cFiliAnt := cFilImpr   
	  				
	  				If Len(aTabS033) > 0
		  				For nS33 := 1 To Len(aTabS033)
		  					If aTabS033[nS33,6] == "1"
		  						nContrDev += aTabS033[nS33,9]
		  					Endif
		  				Next nS33
		  			Endif     
	  			Endif
				//--- Condições para totalizar por Centro de Custo
	   			If cCod == (cQrySRA)->(RA_CC)
	  				nSumVal := nSumVal + nValor       
	  			Endif
				//--- Controle de quebra por Centro de Custo    
	   			If cCod <> (cQrySRA)->(RA_CC)
		 			nValOne 	:= nSumVal
		 			If cRecFatEmp <> "S"
		 				nValDes	:= nSumVal
		 			Endif
		 			cCod 		:= (cQrySRA)->(RA_CC)         			
		 			nTotalGral	:= nTotalGral + nValOne
		 			If cRecFatEmp <> "S"
		 				 nTotalDes := nTotalGral
		 			Endif
		 			nSumVal	:= nValor
	   			Endif
	  			( cQrySRA )->(dbSkip())
	    	ENDDO  
			//--- Totais Gerais    
	   		nValOne 	:= nSumVal       
	    	nTotalGral	:= nTotalGral + nValOne
	    	If cRecFatEmp <> "S"
	    		nValDes 	:= nSumVal
	    		nTotalDes	:= ntotalGral + nValDes
	    	Endif
			nTotDeson	:= (nTotalGral * nPerFatEmp) + nContrDev
			nTotOnera	:= nTotalGral * nPerEmp
			
			nPere := nPerEmp * 100
			nPerr := nPerFatEmp * 100

  		Endif  /// Endif da validação dos periodos 
	Endif
	If !lImprimir .OR. nTotalGral == 0 
		return .F.
	EndIf
	/**************************************************************
	* Monta as Dimensoes dos Objetos                              *
	**************************************************************/
	
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )  

	DEFINE MSDIALOG oDlg TITLE oemToansi(STR0008) FROM  0,0 TO aAdvSize[1]+ 780, aAdvSize[1] + 800 OF oMainWnd PIXEL

  	//Fontes
  	oTFont := TFont():New('Courier new',,14,.T.) // Geral
  	oTFont1 := TFont():New('Courier new',,16,.T.) // Parâmetros Título
  	oTFont1:Bold
  	oTFont2 := TFont():New('Courier new',,160,.T.) // Parâmetros Conteúdo
 	
 	//Posição do painel com o gráfico
 	oPanel:= tPanel():New(10,0,"",oDlg,oTFont,.T.,,,,400,200)
 
	oFWChart := FWChartFactory():New()
	oFWChart := oFWChart:getInstance( BARCHART )    
   	oFWChart:init( oPanel, .F. )
	oFWChart:setTitle( space(6) + oemToansi(STR0009) + space(6) , CONTROL_ALIGN_CENTER )
	oFWChart:setLegend( CONTROL_ALIGN_BOTTOM )
	oFWChart:setPicture( "@E 999,999,999.99" )
	
	oFWChart:addSerie( "Onerado" , nTotOnera)
	oFWChart:addSerie( "Desonerado" , nTotDeson)		
	oFWChart:build() 	
	
	//Montagem dos campos dos parâmetros
	nDiferen 	:= nTotOnera - nTotDeson //Valor do Campo Diferença	  
	
	//Filial
	nPosFil := AT("'",MV_PAR01)
	nTamFil:= AT("'",SUBSTR(MV_PAR01,nPosFil+1,LEN(MV_PAR01)))-1
	
	If Len(Alltrim(MV_PAR01)) > 25
		cFilDe  := substr(mv_par01,AT("'",MV_PAR01)+1,nTamFil)
		cFilAte := substr(mv_par01,RAT("'",MV_PAR01)-nTamFil,nTamFil)
		If cFilDe == cFilAte
			cParFi := substr(mv_par01,AT("'",MV_PAR01)+1,nTamFil)
		Else
			cParFil := Alltrim(cFilDe) + " Até "+ Alltrim(cFilAte)
		Endif
	ElseIf Empty(Alltrim(MV_PAR01))
		cParFil := "Todas"
	Else
		cParFil := substr(mv_par01,AT("'",MV_PAR01)+1,nTamFil)
	Endif	
	
	// Centro de Custo
	If Len(Alltrim(MV_PAR02)) > 24
		cCcDe  := substr(MV_PAR02,AT("'",MV_PAR02)+1,9)
		cCcAte := substr(MV_PAR02,RAT ("'",MV_PAR02)-9,9)
		cCcPar := Alltrim(cCcDe) + " Até "+ Alltrim(cCcAte)
	ElseIf Empty(Alltrim(MV_PAR02))
		cCcPar := "Todos"
	Else
		cCcPar := substr(MV_PAR02,AT("'",MV_PAR02)+1,9)	
	Endif

	cTotGraf:= Transform(nTotalGral	,"@E 999,999,999.99")
	cTotOner:= Transform(nTotOnera	,"@E 999,999,999.99")
	cTotDeso:= Transform(nTotDeson	,"@E 999,999,999.99")
	cDiferen:= Transform(nDiferen	,"@E 999,999,999.99")
	cPerEmp := Transform(nPere		,"@E 999.99%")
	cPerDes := Transform(nPerr		,"@E 999.99%")
	cPerPagPro := IIF(ValType("MV_PAR08")=="N",STRZERO(MV_PAR08,6),MV_PAR08) +"/"+cPagtoR016+"/"+MV_PAR10

	//Parâmetros da Esquerda
	oPanel:= tPanel():New(212,30,oemToansi(STR0035)	,oDlg,oTFont1,.F.,,,,80,7) // PARÂMETROS SOLICITADOS:
	oPanel:= tPanel():New(225,30,oemToansi(STR0036)	,oDlg,oTFont1,.F.,,,,50,7) // Filial:
	oPanel:= tPanel():New(235,30,oemToansi(STR0037)	,oDlg,oTFont1,.F.,,,,77,7) // Centro de Custo:
	oPanel:= tPanel():New(245,30,oemToansi(STR0038)	,oDlg,oTFont1,.F.,,,,90,7) // Período/Pagto/Processo:
	oPanel:= tPanel():New(255,30,oemToansi(STR0039)	,oDlg,oTFont1,.F.,,,,90,7) // Base INSS Folha + 13º:
	
	//Conteúdo dos Parâmetros da Esquerda
	oPanel:= tPanel():New(225,130,AllTrim(cParFil)	,oDlg,oTFont,.F.,,,,75,7) // Filial:
	oPanel:= tPanel():New(235,130,AllTrim(cCcPar)		,oDlg,oTFont,.F.,,,,89,7) // Centro de Custo:
	oPanel:= tPanel():New(245,130,AllTrim(cPerPagPro),oDlg,oTFont,.F.,,,,75,7) // Período:
	oPanel:= tPanel():New(255,130,cTotGraf				,oDlg,oTFont,.F.,,,,89,7) // Base INSS Folha + 13º:
	
	//Barra Lateral
	oPanel:= tPanel():New(210,215,"|"					,oDlg,oTFont2,.T.,,CLR_GRAY,,15,55) // Barra lateral:
	
	//Parâmetros da Direita
	oPanel:= tPanel():New(215,230,oemToansi(STR0040),oDlg,oTFont1,.F.,,,,50,7) // INSS:
	oPanel:= tPanel():New(225,230,oemToansi(STR0041),oDlg,oTFont1,.F.,,,,50,7) // Redutor:
	oPanel:= tPanel():New(235,230,oemToansi(STR0042),oDlg,oTFont1,.F.,,,,50,7) // Onerado:
	oPanel:= tPanel():New(245,230,oemToansi(STR0043),oDlg,oTFont1,.F.,,,,50,7) // Desonerado:
	oPanel:= tPanel():New(255,230,oemToansi(STR0044),oDlg,oTFont1,.F.,,,,75,7) // Diferença:
	
	//Conteúdo dos Parâmetros da Direita
	oPanel:= tPanel():New(215,315,cPerEmp	,oDlg,oTFont,.F.,,,,50,7) // %Empresa
	oPanel:= tPanel():New(225,315,cPerDes	,oDlg,oTFont,.F.,,,,50,7) // %Desonerado
	oPanel:= tPanel():New(235,290,cTotOner	,oDlg,oTFont,.F.,,,,50,7) // Onerado
	oPanel:= tPanel():New(245,290,cTotDeso	,oDlg,oTFont,.F.,,,,50,7) // Desonerado
	oPanel:= tPanel():New(255,290,cDiferen	,oDlg,oTFont,.F.,,,,50,7) // Diferença
	
	//Dicas
	oPanel:= tPanel():New(277,07,oemToansi(STR0010),oDlg,oTFont,.F.,,,,50,8) // Dicas

	oPanel:= tPanel():New(287,06,"a-",oDlg,oTFont,.F.,,,,10,8) // a -
	oPanel:= tPanel():New(287,15,oemToansi(STR0015)+oemToansi(STR0020),oDlg,oTFont,.F.,,,,370,8) //"Verifique como está o turnover da sua empresa, " //a fim de auxiliar a controlar o custo que está tendo como:
	oPanel:= tPanel():New(295,15,oemToansi(STR0022),oDlg,oTFont,.F.,,,,300,8) // Custo de Recrutamento, seleção, treinamento e desligamento.

	oPanel:= tPanel():New(307,06,"b-",oDlg,oTFont,.F.,,,,10,8) // b -	
	oPanel:= tPanel():New(307,15,oemToansi(STR0025),oDlg,oTFont,.F.,,,,300,8) // Hora extra é um ponto que também deve ter atenção.
	oPanel:= tPanel():New(315,15,oemToansi(STR0026),oDlg,oTFont,.F.,,,,320,8) // Verifique a quantidade de horas extras feitas e veja a possibilidade de reduzir.

	oPanel:= tPanel():New(325,06,"c-",oDlg,oTFont,.F.,,,,10,8) // c -
	oPanel:= tPanel():New(325,15,oemToansi(STR0027),oDlg,oTFont,.F.,,,,370,8) // Verifique como estão as férias a vencer da sua empresa, a fim de evitar férias em dobro.
	oPanel:= tPanel():New(332,15,oemToansi(STR0028),oDlg,oTFont,.F.,,,,370,8) // Para visualizar informações sobre férias vencidas da sua empresa, você pode utilizar,
	oPanel:= tPanel():New(339,15,oemToansi(STR0029),oDlg,oTFont,.F.,,,,370,8) // o seguinte relatório disponível no nosso produto: GPER390 - Férias Vencidas no Mês.
	
	oPanel:= tPanel():New(349,06,"d-",oDlg,oTFont,.F.,,,,10,8) // d -
	oPanel:= tPanel():New(349,15,oemToansi(STR0030),oDlg,oTFont,.F.,,,,370,8) // Confira se na dedução da GPS são considerados os salários das funcionárias em licença maternidade.
	oPanel:= tPanel():New(356,15,oemToansi(STR0031),oDlg,oTFont,.F.,,,,370,8) // Para visualizar informações compare os relatórios GPER980 (Histórico de Afastamentos) para identificar as 
	oPanel:= tPanel():New(363,15,oemToansi(STR0032),oDlg,oTFont,.F.,,,,370,8) // funcionárias nesta situação X GPER106 (Folha de Pagamento).

	oPanel:= tPanel():New(373,06,"e-",oDlg,oTFont,.F.,,,,10,8) // e -
	oPanel:= tPanel():New(373,15,oemToansi(STR0033),oDlg,oTFont,.F.,,,,370,8) // Entregue as obrigações legais em dia a fim de evitar multa, como a GPS: Prazo de Pagamento, 
	oPanel:= tPanel():New(380,15,oemToansi(STR0034),oDlg,oTFont,.F.,,,,370,8) // até o dia 20 do mês subsequente.
	
	ACTIVATE DIALOG oDlg CENTERED
	
Return 