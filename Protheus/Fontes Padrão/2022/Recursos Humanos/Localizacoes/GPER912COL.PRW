#INCLUDE "PROTHEUS.CH"   
#INCLUDE "report.ch"    
#INCLUDE "GPER912COL.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER912COL³ Autor ³ Tiago Malta           ³ Data ³ 24/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Contribuições - Colombia                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER911COL                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Ademar Jr. ³04/10/12³      ³-Ajustes nos filtros das Selects          ³±±
±±³Jonathan Glz³10/02/16³PCREQ-³Localizacion GPE v12 Colombia.            ³±±
±±³            ³        ³  9393³Se modifica la funcion PrintReport en el  ³±±
±±³            ³        ³      ³Qry principal,se elimina filtro rc_roteir ³±±
±±³            ³        ³      ³= 'PAT'.                                  ³±±
±±³            ³        ³      ³Modificacion en la funcion fLinePrint se  ³±±
±±³            ³        ³      ³soluciona error con la creacion de los box³±±
±±³            ³        ³      ³para las columnas.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/
Function GPER912COL()   

Local	aArea 		:= GetArea()            

Private	oReport                             
Private cString	   	:= "SRA"				// alias do arquivo principal (Base)
Private cFilQuery	:= ""
Private lCorpManage	:= fIsCorpManage( FWGrpCompany() )

If lCorpManage
	Private lEmpFil	  	:= !Empty(FWSM0Layout(cEmpAnt, 1)) 
	Private cLayoutGC 	:= FWSM0Layout(cEmpAnt)
	Private nStartEmp	:= At("E",cLayoutGC)
	Private nStartUnN	:= At("U",cLayoutGC)
	Private nEmpLength := Len(FWSM0Layout(cEmpAnt, 1))
	Private nUnNLength := Len(FWSM0Layout(cEmpAnt, 2))
EndIf

	oReport := ReportDef()
	oReport:PrintDialog()                      

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef ³ Autor ³ Tiago Malta           ³ Data ³ 24.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function ReportDef()
Local oReport
Local oBreakPg                                    
Local oSection1
Local cTitulo := STR0001
Local cPerg   := "GPER912COL"

Pergunte( cPerg , .F. )

//Objeto Function               
	//-- Inicio definicao do Relatorio
	DEFINE REPORT oReport NAME "GPER912COL" TITLE OemToAnsi(cTitulo)  PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION ""
 	
		oReport:SetLandscape()     
		
		IF MV_PAR01 == 1 .OR.  MV_PAR01 == 3
			oReport:oPage:nPaperSize	:= 1 // Impressão em papel A4 - LandScape 9=a4,1=Carta,5=Oficio,8=A3
		ELSE
			oReport:oPage:nPaperSize	:= 5 // Impressão em papel A4 - LandScape 9=a4,1=Carta,5=Oficio,8=A3	 
		ENDIF
		//-- Section de Funcionario
		DEFINE SECTION oSection1 OF oReport TABLES "SRA" TITLE OemToAnsi(cTitulo) TOTAL IN COLUMN
		
			oSection1:SetHeaderBreak(.T.)                                          
			
			// CELL HEADER BORDER  
			DEFINE CELL HEADER BORDER OF oSection1 EDGE_BOTTOM WEIGHT 0
			
		    DEFINE CELL NAME "RA_FILIAL"	OF oSection1 ALIAS cString
		    DEFINE CELL NAME "RA_CODEPS"	OF oSection1 ALIAS cString
		    DEFINE CELL NAME "RA_CODAFP"	OF oSection1 ALIAS cString
			DEFINE CELL NAME "RA_TPCIC"		OF oSection1 ALIAS cString Title "Tipo ID"
			DEFINE CELL NAME "RA_CIC"		OF oSection1 ALIAS cString Title STR0002
			DEFINE CELL NAME "RA_PRISOBR"   OF oSection1 ALIAS cString Title STR0003  HEADER ALIGN RIGHT
			DEFINE CELL NAME "RA_SECSOBR"   OF oSection1 ALIAS cString Title " "
			DEFINE CELL NAME "RA_PRINOME"   OF oSection1 ALIAS cString Title STR0004  HEADER ALIGN RIGHT
			DEFINE CELL NAME "RA_SECNOME"   OF oSection1 ALIAS cString Title " "
			DEFINE CELL NAME "DIAS"		    OF oSection1 ALIAS cString Title STR0005 SIZE 5 ALIGN CENTER
			DEFINE CELL NAME "ING"		    OF oSection1 ALIAS cString Title "ING" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "RET"		    OF oSection1 ALIAS cString Title "RET" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "TDE"		    OF oSection1 ALIAS cString Title "TDE" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "TAE"		    OF oSection1 ALIAS cString Title "TAE" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "TDP"		    OF oSection1 ALIAS cString Title "TDP" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "TAP"		    OF oSection1 ALIAS cString Title "TAP" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "VSP"		    OF oSection1 ALIAS cString Title "VSP" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "VTE"		    OF oSection1 ALIAS cString Title "VTE" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "VST1"		    OF oSection1 ALIAS cString Title "VST" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "SLN"		    OF oSection1 ALIAS cString Title "SLN" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "IGE"		    OF oSection1 ALIAS cString Title "IGE" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "LMA"		    OF oSection1 ALIAS cString Title "LMA" SIZE 3 ALIGN CENTER 
			DEFINE CELL NAME "VAC"		    OF oSection1 ALIAS cString Title "VAC" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "AVP"		    OF oSection1 ALIAS cString Title "AVP" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "VCT"		    OF oSection1 ALIAS cString Title "VCT" SIZE 3 ALIGN CENTER
			DEFINE CELL NAME "IRP"		    OF oSection1 ALIAS cString Title "IRP" SIZE 3 ALIGN CENTER

			oSection1:Cell("RA_FILIAL"):Disable() 
			oSection1:Cell("RA_CODEPS"):Disable() 
			oSection1:Cell("RA_CODAFP"):Disable() 						
			
Return oReport   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReport ºAutor  ³Tiago Malta         º Data ³  09/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function PrintReport(oReport)     
Local oSection1 := oReport:Section(1) 
Local cQrySRA  	:= "SRA"  
Local i
Local cFiltro	:= ""
Local cSitQuery := ""
Local cCatQuery := ""
Local cOrdem    := ""
Local nReg		:= 0
Local cSituacao := MV_PAR06
Local cCategoria:= MV_PAR07
Local cTitFun   := ""
Local cTitEFil	:= ""
Local cPrefx    := "" 
Local cAliasAux := ""
Local oBreakEFil
Local oBreakFil

Private cProcesso		:= MV_PAR08                              
Private cPeriodo		:= MV_PAR09
Private cNrPgto  		:= MV_PAR10
Private dDataRef		:= Ctod("//")
Private nFlag     := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        //  Tipo de Relatorio                        ³	
	//³ mv_par02        //  Filial                                   ³
	//³ mv_par03        //  Centro de Custo                          ³
	//³ mv_par04        //  Matricula                                ³
	//³ mv_par05        //  Nome                                     ³
	//³ mv_par06        //  Situacao                                 ³
	//³ mv_par07        //  Categoria                                ³
	//³ mv_par08        //  Processo                                 ³
	//³ mv_par09        //  Periodo                                  ³
	//³ mv_par10        //  Nr Pagto                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Dbselectarea("RCH")
	dbgotop()
	Dbseek(xFilial("RCH")+cProcesso+cPeriodo+cNrPgto)

	dDataRef := RCH->RCH_DTFIM

	IF EMPTY(RCH->RCH_DTFECH)
		cPrefx    := "RC"
		cAliasAux := "SRC"
	ELSE
		cPrefx    := "RD" 
		cAliasAux := "SRD"
	ENDIF

    
	If !Empty(MV_PAR02)
		cFiltro += "AND SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR02)
	EndIf
	
	If !Empty(MV_PAR03)
		cFiltro += "AND SRA."+RANGESX1("RA_CC"      ,MV_PAR03)
	EndIf
	
	If !Empty(MV_PAR04)
		cFiltro += "AND SRA."+RANGESX1("RA_MAT"     ,MV_PAR04)
	EndIf 
	
	If !Empty(MV_PAR05)
		cFiltro += "AND SRA."+RANGESX1("RA_NOME"    ,MV_PAR05)
	EndIf
		
	For nReg:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next nReg        
	
	For nReg:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCategoria)
			cCatQuery += "," 
		Endif
	Next nReg                                
				
	cQuery := "SELECT RA_FILIAL,RA_MAT,RA_CIC,RA_TPCIC,RA_ADMISSA,RA_DEMISSA,RA_SEXO,RA_CODEPS,RA_CODAFP,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME "
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0042')+"' THEN "+cPrefx+"_HORAS ELSE 0 END) AS IRP "
		 			
	IF MV_PAR01 == 1 // Informe tipo ARL
		
		oReport:CTITLE := STR0001+ " ARL "+RCH->RCH_MES+"/"+RCH->RCH_ANO
		DEFINE CELL NAME "IBC"   		OF oSection1 ALIAS cString Title "IBC" 		SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "APORTE"  		OF oSection1 ALIAS cString Title STR0006+ " ARL" 	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "TOTAL" 		OF oSection1 ALIAS cString Title STR0010			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER					
		
		cQuery += " ,( SELECT SUM(CASE WHEN RV_ACUMAUX LIKE '%003%' THEN "+cAliasAux+"."+cPrefx+"_HORAS ELSE 0 END) "
		cQuery += " FROM " + RetSqlName(cAliasAux) + " "+cAliasAux
		cQuery += " INNER JOIN "+RetSqlName("SRV")+" ON RV_COD = "+cAliasAux+"."+cPrefx+"_PD "
		cQuery += "	WHERE "+cAliasAux+"."+cPrefx+"_FILIAL = SRA.RA_FILIAL   AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_MAT = SRA.RA_MAT         AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_PERIODO = '"+cPeriodo+"' AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_ROTEIR  = 'LIQ'          AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_SEMANA  = '"+cNrPgto +"' AND " 
		cQuery += " "+      cAliasAux+".D_E_L_E_T_ = ' ' ) AS DIAS"		                                          
		
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0874')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS IBC "    // ingreso base de cotización
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0883')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS APORTE " //total de arl por la empresa
	
	ELSEIF MV_PAR01 == 2 // Informe tipo pensión
		
		oReport:CTITLE := STR0001+ " "+STR0017+" "+RCH->RCH_MES+"/"+RCH->RCH_ANO
		DEFINE CELL NAME "IBC"   	OF oSection1 ALIAS cString Title "IBC" 			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER	
		DEFINE CELL NAME "APORTE" 		OF oSection1 ALIAS cString Title STR0006 + "Empl" 	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "APORTECIA" 	OF oSection1 ALIAS cString Title STR0006 + "Cia" 	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "FONSOL" 		OF oSection1 ALIAS cString Title STR0007 			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "APORTEAFC" 	OF oSection1 ALIAS cString Title "Vol AFC" 			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "VOLFUNC" 		OF oSection1 ALIAS cString Title STR0008 			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "VOLEMP" 		OF oSection1 ALIAS cString Title STR0009 			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER		
		DEFINE CELL NAME "VOLOBL" 		OF oSection1 ALIAS cString Title STR0019			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER					
		DEFINE CELL NAME "TOTAL" 		OF oSection1 ALIAS cString Title STR0010			SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER					

 		cQuery += " ,( SELECT SUM(CASE WHEN RV_ACUMAUX LIKE '%001%' THEN "+cAliasAux+"."+cPrefx+"_HORAS ELSE 0 END) "
		cQuery += " FROM " + RetSqlName(cAliasAux) + " "+cAliasAux
		cQuery += " INNER JOIN "+RetSqlName("SRV")+" ON RV_COD = "+cAliasAux+"."+cPrefx+"_PD "
		cQuery += "	WHERE "+cAliasAux+"."+cPrefx+"_FILIAL = SRA.RA_FILIAL   AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_MAT = SRA.RA_MAT         AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_PERIODO = '"+cPeriodo+"' AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_ROTEIR  = 'LIQ'          AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_SEMANA  = '"+cNrPgto +"' AND " 
		cQuery += " "+      cAliasAux+".D_E_L_E_T_ = ' ' ) AS DIAS"		                                          
		
		cQuery += " ,( SELECT SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0860')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) "
		cQuery += " FROM " + RetSqlName(cAliasAux) + " "+cAliasAux
		cQuery += " INNER JOIN "+RetSqlName("SRV")+" ON RV_COD = "+cAliasAux+"."+cPrefx+"_PD "
		cQuery += "	WHERE "+cAliasAux+"."+cPrefx+"_FILIAL = SRA.RA_FILIAL   AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_MAT = SRA.RA_MAT         AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_PERIODO = '"+cPeriodo+"' AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_ROTEIR  = 'LIQ'          AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_SEMANA  = '"+cNrPgto +"' AND " 
		cQuery += " "+      cAliasAux+".D_E_L_E_T_ = ' ' ) AS FONSOL " 
		
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0869')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS IBC "		//-FGETCODFOL('1106') 
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0859')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS APORTE "	//-FGETCODFOL('0859') es el total empleado y empresa
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0872')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS APORTECIA "	//-FGETCODFOL('0859')
	
	ELSEIF MV_PAR01 == 3 // Informe tipo Salud                     
	
		oReport:CTITLE := STR0001+ " "+STR0018+" "+RCH->RCH_MES+"/"+RCH->RCH_ANO
		DEFINE CELL NAME "IBC"   		OF oSection1 ALIAS cString Title "IBC" 		SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "APORTE" 		OF oSection1 ALIAS cString Title "Salud Empleado" 		SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "APORTECIA" 		OF oSection1 ALIAS cString Title "Salud Cia" 		SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "TOTAL" 	OF oSection1 ALIAS cString Title STR0010 	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER					
			
		cQuery += " ,( SELECT SUM(CASE WHEN RV_ACUMAUX LIKE '%002%' THEN "+cAliasAux+"."+cPrefx+"_HORAS ELSE 0 END) "
		cQuery += " FROM " + RetSqlName(cAliasAux) + " "+cAliasAux
		cQuery += " INNER JOIN "+RetSqlName("SRV")+" ON RV_COD = "+cAliasAux+"."+cPrefx+"_PD "
		cQuery += "	WHERE "+cAliasAux+"."+cPrefx+"_FILIAL = SRA.RA_FILIAL   AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_MAT = SRA.RA_MAT         AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_PERIODO = '"+cPeriodo+"' AND " 
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_ROTEIR  = 'LIQ'          AND " 
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_SEMANA  = '"+cNrPgto +"' AND " 
		cQuery += "	"+      cAliasAux+".D_E_L_E_T_ = ' ' ) AS DIAS"

		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0868')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS IBC "		//-FGETCODFOL('0013') 
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0857')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS APORTE " 	// SALUD EMPRESA
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0871')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS APORTECIA " 	// SALUD EMPRESA
	
	ELSEIF MV_PAR01 == 4 // Informe tipo PARAFISCALES                     
		oReport:CTITLE := STR0001+ " PARAFISCALES "+RCH->RCH_MES+"/"+RCH->RCH_ANO
		DEFINE CELL NAME "IBC"   		OF oSection1 ALIAS cString Title "IBC" 		SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "APORTE" 		OF oSection1 ALIAS cString Title "CCF" 		SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "ICBF" 	OF oSection1 ALIAS cString Title STR0022 	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER
		DEFINE CELL NAME "SENA" 	OF oSection1 ALIAS cString Title STR0023 	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER		
		DEFINE CELL NAME "ESAP" 	OF oSection1 ALIAS cString Title STR0024	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER					
		DEFINE CELL NAME "MEN" 		OF oSection1 ALIAS cString Title STR0025	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER					
		DEFINE CELL NAME "TOTAL" 	OF oSection1 ALIAS cString Title STR0010 	SIZE 16 PICTURE "@E 999,999,999,999.99" HEADER ALIGN CENTER					
	
		cQuery += " ,( SELECT SUM(CASE WHEN RV_ACUMAUX LIKE '%004%' THEN "+cAliasAux+"."+cPrefx+"_HORAS ELSE 0 END) "
		cQuery += " FROM " + RetSqlName(cAliasAux) + " "+cAliasAux
		cQuery += " INNER JOIN "+RetSqlName("SRV")+" ON RV_COD = "+cAliasAux+"."+cPrefx+"_PD "
		cQuery += "	WHERE "+cAliasAux+"."+cPrefx+"_FILIAL = SRA.RA_FILIAL   AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_MAT = SRA.RA_MAT         AND "
		cQuery += "	"+      cAliasAux+"."+cPrefx+"_PERIODO = '"+cPeriodo+"' AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_ROTEIR  = 'LIQ'          AND " 
		cQuery += " "+      cAliasAux+"."+cPrefx+"_SEMANA  = '"+cNrPgto +"' AND " 
		cQuery += " "+      cAliasAux+".D_E_L_E_T_ = ' ' ) AS DIAS"		                                          
		
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0369')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS IBC "
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0373')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS APORTE " 	//-FGETCODFOL('0064')
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0377')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS ICBF " 
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0381')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS SENA " 
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0385')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS ESAP " 
		cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0389')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS MEN " 
	
	
	ENDIF
	
	cQuery += "	FROM "	+ RetSqlName("SRA") + " SRA " 	
	
	cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
	cQuery += " "+cAliasAux+"."+cPrefx+"_FILIAL  = SRA.RA_FILIAL  AND " 
	cQuery += "	"+cAliasAux+"."+cPrefx+"_MAT     = SRA.RA_MAT     AND " 
	cQuery += "	"+cAliasAux+"."+cPrefx+"_PERIODO = '"+cPeriodo+"' AND " 
	cQuery += "	"+cAliasAux+"."+cPrefx+"_SEMANA  = '"+cNrPgto +"' AND " 
	cQuery += "	"+cAliasAux+".D_E_L_E_T_ = ' ' "		 
	
	cQuery += "	WHERE SRA.RA_SITFOLH IN	("+cSitQuery+") AND " 
	cQuery += "		  SRA.RA_CATFUNC IN	("+cCatQuery+") AND " 
	cQuery += "		  SRA.RA_PROCES  =  '"+cProcesso+"' AND " 
	cQuery += "	 	  SRA.D_E_L_E_T_ = ' ' "
	
	IF !EMPTY(cFiltro)
		cQuery += cFiltro
	ENDIF

	cQuery += "	GROUP BY RA_FILIAL,RA_MAT,RA_CIC,RA_TPCIC,RA_ADMISSA,RA_DEMISSA,RA_SEXO,RA_CODEPS,RA_CODAFP,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME " 

	IF MV_PAR01 == 1
		cQuery += "	ORDER BY RA_FILIAL,RA_MAT " 	
	ELSEIF MV_PAR01 == 2                                                
		cQuery += "	ORDER BY RA_CODAFP, RA_FILIAL,RA_MAT " 	
	ELSEIF MV_PAR01 == 3
		cQuery += "	ORDER BY RA_CODEPS, RA_FILIAL,RA_MAT " 	
	ELSEIF MV_PAR01 == 4
		cQuery += "	ORDER BY RA_FILIAL,RA_MAT "  	

	ENDIF
	
	cQuery := ChangeQuery(cQuery)
		
	IF Select(cQrySRA) > 0
		(cQrySRA)->( DBCLOSEAREA() )
	ENDIF
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)	
	TCSetField(cQrySRA, "RA_ADMISSA", "D", 8, 0)
	TCSetField(cQrySRA, "RA_DEMISSA", "D", 8, 0)					
	
	//-- Define o total da regua da tela de processamento do relatorio
	oSection1:SetLineCondition({|| fLinePrint() })
	
	oReport:SetMeter((cQrySRA)->( RecCount() ))

	IF MV_PAR01 == 1
		DEFINE BREAK oBreakFil  OF oSection1  WHEN  oSection1:Cell("RA_FILIAL" )
		DEFINE FUNCTION NAME "IBC"    FROM oSection1:Cell("IBC" )    FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "APORTE" FROM oSection1:Cell("APORTE" ) FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
		DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							

	ELSEIF MV_PAR01 == 2
		DEFINE BREAK oBreakFil  OF oSection1  WHEN  oSection1:Cell("RA_CODAFP" )
		DEFINE FUNCTION NAME "IBC"    FROM oSection1:Cell("IBC" )    	 FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "APORTE" FROM oSection1:Cell("APORTE" ) 	 FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "APORTECIA" FROM oSection1:Cell("APORTECIA" ) 	 FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "FONSOL"   FROM oSection1:Cell("FONSOL" )   FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "APORTEAFC"  FROM oSection1:Cell("APORTEAFC" )  FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "VOLFUNC"  FROM oSection1:Cell("VOLFUNC" )  FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "VOLEMP"   FROM oSection1:Cell("VOLEMP" )   FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "VOLOBL"    FROM oSection1:Cell("VOLOBL" )  FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							
		DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							

	ELSEIF MV_PAR01 == 3
		DEFINE BREAK oBreakFil  OF oSection1  WHEN  oSection1:Cell("RA_CODEPS" )	
		DEFINE FUNCTION NAME "IBC"    	FROM oSection1:Cell("IBC" )   		 		FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "APORTE" 	FROM oSection1:Cell("APORTE" ) 				FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"		
		DEFINE FUNCTION NAME "APORTECIA"   	FROM oSection1:Cell("APORTECIA" )   	FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    			FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"								

	ELSEIF MV_PAR01 == 4
	
		DEFINE BREAK oBreakFil  OF oSection1  WHEN  oSection1:Cell("RA_FILIAL" )	
		DEFINE FUNCTION NAME "IBC"    	FROM oSection1:Cell("IBC" )    		FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "APORTE" 	FROM oSection1:Cell("APORTE" ) 		FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"		
	
		DEFINE FUNCTION NAME "ICBF"  FROM oSection1:Cell("ICBF" )  FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "SENA"   FROM oSection1:Cell("SENA" )   FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "ESAP"    FROM oSection1:Cell("ESAP" )  FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							
		DEFINE FUNCTION NAME "MEN"    FROM oSection1:Cell("MEN" )    FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							
		DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							

	ENDIF
	
	IF MV_PAR01 == 1
		oBreakFil:OnBreak({|x,y| cTitFun := OemToAnsi(STR0013)+" "+x})
	ELSEIF MV_PAR01 == 2
		oBreakFil:OnBreak({|x,y| cTitFun := OemToAnsi(STR0014)+" "+x})		
	ELSEIF MV_PAR01 == 3
		oBreakFil:OnBreak({|x,y| cTitFun := OemToAnsi(STR0015)+" "+x})			
	ELSEIF MV_PAR01 == 4
		oBreakFil:OnBreak({|x,y| cTitFun := OemToAnsi(STR0013)+" "+x})			
	
	ENDIF

   	oBreakFil:SetTotalText({||cTitFun}) 
   	oBreakFil:SetTotalInLine(.f.)   	
    
	If lCorpManage
		DEFINE BREAK oBreakEFil OF oReport   WHEN  { || Substr((cQrySRA)->RA_FILIAL, nStartEmp, nEmpLength) }
		DEFINE FUNCTION NAME "IBC"    FROM oSection1:Cell("IBC" )    FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "APORTE" FROM oSection1:Cell("APORTE" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	


		IF  MV_PAR01 == 1
			DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							
		
		ELSEIF MV_PAR01 == 2
			DEFINE FUNCTION NAME "APORTECIA"  FROM oSection1:Cell("APORTECIA" )  FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			DEFINE FUNCTION NAME "FONSOL"   FROM oSection1:Cell("FONSOL" )   FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			DEFINE FUNCTION NAME "APORTEAFC"  FROM oSection1:Cell("APORTEAFC" )  FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			DEFINE FUNCTION NAME "VOLFUNC"  FROM oSection1:Cell("VOLFUNC" )  FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			DEFINE FUNCTION NAME "VOLEMP"   FROM oSection1:Cell("VOLEMP" )   FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			DEFINE FUNCTION NAME "VOLOBL"    FROM oSection1:Cell("VOLOBL" )  FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							
			DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							

		ELSEIF MV_PAR01 == 3
			DEFINE FUNCTION NAME "APORTECIA"   	FROM oSection1:Cell("APORTECIA" )   		FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			
			DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    	FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"								

		ELSEIF MV_PAR01 == 4
			
			DEFINE FUNCTION NAME "ICBF"  FROM oSection1:Cell("ICBF" )  FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			DEFINE FUNCTION NAME "SENA"   FROM oSection1:Cell("SENA" )   FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
			DEFINE FUNCTION NAME "ESAP"    FROM oSection1:Cell("ESAP" )  FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							
			DEFINE FUNCTION NAME "MEN"    FROM oSection1:Cell("MEN" )    FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							
			DEFINE FUNCTION NAME "TOTAL"    FROM oSection1:Cell("TOTAL" )    FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"							

	
		ENDIF
			
		oBreakEFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0016) + " " + x })	
		oBreakEFil:SetTotalText({ || cTitEFil })
		oBreakEFil:SetTotalInLine(.F.)		
	EndIf                          
	
	//-- Impressao do Relatorio
	oSection1:Print()


	IF SELECT("RCH") > 0
		RCH->( DBCLOSEAREA() )
	ENDIF
			
	IF SELECT("SRA") > 0
		SRA->( DBCLOSEAREA() )
	ENDIF

Return NIL                               


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER912COLºAutor  ³Microsiga           º Data ³  08/24/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fLinePrint()

Local i
Local ncol 			:= 0
Local nRow			:= 0
Local oSection1 	:= oReport:Section(1)                        
Local aPers   		:= {}
Local aVerbas		:= {}
Local nPos			:= 0
Local nVerba		:= 0
Local lRefApor		:= .F.
Local nValAFPEmp    := 0
Local nValAFPVol    := 0
Local nValAFPFunc   := 0
Local nValIncap		:= 0
Local nValLic		:= 0
Local cCpo			:= ""
Local nValAFCFunc   := 0

	If MesAno(SRA->RA_ADMISSA) == MesAno(dDataRef)
		oSection1:Cell("ING"):SetValue("X")
	ELSE
		oSection1:Cell("ING"):SetValue(" ")
	ENDIF
	
	If MesAno(SRA->RA_DEMISSA) == MesAno(dDataRef)
		oSection1:Cell("RET"):SetValue("X")                                                       
	ELSE
		oSection1:Cell("RET"):SetValue(" ")                                                       	
	ENDIF
	
  	IF fVerAfas(SRA->RA_FILIAL, SRA->RA_MAT, dDataRef)
	  	oSection1:Cell("SLN"):SetValue("X")
	ELSE
		oSection1:Cell("SLN"):SetValue(" ")
	ENDIF
	
	fRetPerComp(Month2Str(dDataRef),Year2Str(dDataRef),NIL,NIL,NIL,NIL,@aPers)
	aVerbas := RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, NIL, NIL, NIL, NIL, aPers)	 

	//AUXILIO ENFERMIDADE
	nPos := Ascan(aVerbas,{|x| x[3] == fGetCodFol("0041") })
	
	If (nPos > 0)
		dbSelectArea("SR8")
		dbSetOrder(5)
		dbSeek(SRA->RA_FILIAL  + aVerbas[nPos][16] )	 //pesquisa pelo Num. ID
		
		nValIncap := aVerbas[nPos][7]		
		
	  	oSection1:Cell("IGE"):SetValue("X")
	Else
	  	oSection1:Cell("IGE"):SetValue(" ")
	EndIf         
	
		
	//AUXILIO MATERNIDADE/PATERNIDADE
	If SRA->RA_SEXO == "F"
		nPos := Ascan(aVerbas,{|x| x[3] == fGetCodFol("0040") })		//Busca Aux. Maternidade
	Else
		nPos := Ascan(aVerbas,{|x| x[3] == fGetCodFol("1034") })		//Busca Aux. Paternidade
	EndIf

	If (nPos > 0)			
		dbSelectArea("SR8")
		dbSetOrder(5)
		dbSeek(SRA->RA_FILIAL + aVerbas[nPos][16])	 //pesquisa pelo NUM. ID
        
        nValLic := aVerbas[nPos][7]   	
	
		oSection1:Cell("LMA"):SetValue("X")
	Else
		oSection1:Cell("LMA"):SetValue(" ")
	EndIf

	//FERIAS
	nPos := Ascan(aVerbas,{|x| x[3] == fGetCodFol("0072") })
	If (nPos > 0)
		oSection1:Cell("VAC"):SetValue("X")	
	ELSE
		oSection1:Cell("VAC"):SetValue(" ")	
	ENDIF

	//APORTE VOLUNTARIO
	For nVerba = 1 To Len(aVerbas)
		If ( PosSRV( aVerbas[nVerba][3] , SRA->RA_FILIAL , "RV_REFAPOR" ) == "1" )

			lRefApor := .T.
						
			IF MV_PAR01 == 2
				If (PosSRV( aVerbas[nVerba][3] , SRA->RA_FILIAL , "RV_CODFOL" ) == "1356")//aVerbas[nVerba][4] == "4"			//Verba Tipo Base Desconto EmpresA
					nValAFPEmp += aVerbas[nVerba][7]		//Valor AFP Empresa
				ElseIf (PosSRV( aVerbas[nVerba][3] , SRA->RA_FILIAL , "RV_CODFOL" ) == "1343") //aVerbas[nVerba][4] == "2"		//Verba Tipo Desconto Func
				    nValAFCFunc += aVerbas[nVerba][7]		//Valor AFC Funcionario
				ElseIf (PosSRV( aVerbas[nVerba][3] , SRA->RA_FILIAL , "RV_CODFOL" ) == "1344") //aVerbas[nVerba][4] == "2"		//Verba Tipo Desconto Func
					nValAFPFunc += aVerbas[nVerba][7]		//Valor AFP Funcionario
				ElseIf (PosSRV( aVerbas[nVerba][3] , SRA->RA_FILIAL , "RV_CODFOL" ) == "1521") //aVerbas[nVerba][4] == "X"		//Verba Tipo Desconto Voluntario
					nValAFPVol += aVerbas[nVerba][7]		//Valor aporte voluntario obligatorio Funcionario
				EndIf
			ELSE
				nVerba := Len(aVerbas)
			ENDIF
					
		EndIf
	Next
	
	IF lRefApor     
		oSection1:Cell("AVP"):SetValue("X")	
	ELSE
		oSection1:Cell("AVP"):SetValue(" ")
	ENDIF
	
	IF MV_PAR01 == 2
		oSection1:Cell("APORTEAFC"):SetValue(nValAFCFunc)
		oSection1:Cell("VOLEMP"):SetValue(nValAFPEmp)
		oSection1:Cell("VOLOBL"):SetValue(nValAFPVol)
		oSection1:Cell("VOLFUNC"):SetValue(nValAFPFunc) 
		
	ENDIF 	
					
	IF MV_PAR01 == 1
		oSection1:Cell("TOTAL"):SetValue(SRA->APORTE+SRA->IBC)
	ELSEIF MV_PAR01 == 2
		oSection1:Cell("TOTAL"):SetValue(SRA->APORTE+SRA->APORTECIA+SRA->FONSOL+nValAFPFunc+nValAFPEmp+nValAFPVol+nValAFCFunc)
	ELSEIF MV_PAR01 == 3
		oSection1:Cell("TOTAL"):SetValue(SRA->APORTE+SRA->APORTECIA)	
	ELSEIF MV_PAR01 == 4
		oSection1:Cell("TOTAL"):SetValue(SRA->APORTE+SRA->ICBF+SRA->SENA+SRA->ESAP+SRA->MEN)	
	ENDIF

	//////// Box ////////
	IF MV_PAR01 == 1	
		cCpo := "SRA->RA_FILIAL"
	ELSEIF MV_PAR01 == 2
		cCpo := "SRA->RA_CODAFP"
	ELSEIF MV_PAR01 == 3
		cCpo := "SRA->RA_CODEPS"	
	ELSEIF MV_PAR01 == 4	
		cCpo := "SRA->RA_FILIAL"
	ENDIF
			
	oReport:Box( 0 , 0 , 0 , 0 )   //ATUALIZA O NUMERO DA LINHA
	ncol := oSection1:Cell("ING"):col()
	nRow := oReport:Row()
	nFlag ++

	IF MV_PAR01 == 1 //Realiza espacios ARL
		IF Empty(cFilQuery) 
			nRow +=60
			cFilQuery := &cCpo
		ELSEIF cFilQuery <> &cCpo
			nRow += 190
			cFilQuery := &cCpo
		ELSE
			nRow += 15
		ENDIF
	ELSEIF MV_PAR01 == 2 //Realiza espacios Pension
		IF Empty(cFilQuery) .and. nFlag <= 1
			nRow += 60
			cFilQuery := &cCpo
	
		ELSEIF cFilQuery <> &cCpo
			nRow += 195
			cFilQuery := &cCpo
		ELSE
			nRow += 15
		ENDIF
	ElSE //Realiza espacios para reporte de Salud
		IF Empty(cFilQuery) .and. nFlag <= 1
			nRow += 63
			cFilQuery := &cCpo

		ELSEIF cFilQuery <> &cCpo
			nRow += 193
			cFilQuery := &cCpo
		ELSE
			nRow += 13
		ENDIF
	ENDIF

	//Crea box para las columnas
	For i:=1 to 16
		oReport:Box( nRow - 15 , ncol , nRow + 10 , ncol + 43)
		IF MV_PAR01 == 1 .or. MV_PAR01 == 3
	 		ncol += 56
	 	ELSEIF MV_PAR01 == 2 
	 		ncol += 82
	 	ELSEIF MV_PAR01 == 4	
	 		ncol += 56	 	
	 	ENDIF
	 	
	 	
	Next i                                                              	

Return(.T.)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³fVerAfas  ³Autor³Abel Ribeiro               ³Data³04/03/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³VerIfica afastamentos Funcionarios         			        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³GPER880			                    	   					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function fVerAfas(cFilSRA, cMat, dPerPag)
	Local lAfast	:= .F.
	Local cQuery	:= ""
	Local cAlias	:= ""
	Local cTipoAf 	:= ""
	Local dDtIni1 	:= CTOD("//")
	Local dDtIni2  	:= CTOD("//")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca os dias de afastamento do periodo corrente.  			 |
	//³ 5=Suspensao de Contrato de Trabalho ou 1=Ausencia sem Pagto  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSR8Dados  := {}   //ARRAY para armazenar os dias de afastamento para posterior tratamento de dias aplicados
	nDiasAf := 0
	
	dDtInIfec:= FirstDate(dPerPag)
	dDtFimFec:= LastDate(dPerPag)
	
#IFDEF TOP
	cAlias := "Q1"
	cQuery := " SELECT RCM_TIPO FROM " + RetSqlName("RCM")

	cQuery += " WHERE RCM_TIPOAF IN ( '1','2','5' ) AND "
	cQuery += " D_E_L_E_T_ = '' "
	             
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	While (cAlias)->(!Eof())
		cTipoAf += "'" + (cAlias)->RCM_TIPO + "'"
		(cAlias)->(DbSkip())
		If (cAlias)->(!Eof())
			cTipoAf += ","
		EndIf
	Enddo
	
	(cAlias)->(DbCloseArea())
	
	If !Empty(cTipoAf) 
	    If Empty(cTipoAf)
	    	cTipoAf:= "''"
	    EndIf

		cAlias := "Q2"
		cQuery := " SELECT * FROM " + RetSqlName("SR8") + " SR8 "
		cQuery += " WHERE R8_FILIAL = '" + cFilSRA + "' AND "
		cQuery += "       R8_MAT = '" + cMat + "' AND "
		cQuery += "       R8_TIPOAFA IN ( " + cTipoAf + ") AND "
		cQuery += "       D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		lAfast := IIf(RECCOUNT() > 0,.T.,.F.)

		While (cAlias)->(!Eof()) .And. (cAlias)->( R8_FILIAL + R8_MAT ) = cFilSra + cMat               
			If (cAlias)->R8_DATAFIM < DTOS(dDtInIfec)
			   (cAlias)->(DbSkip() )       
			   LOOP
			EndIf
			
			If (cAlias)->R8_DATAINI > DTOS(dDtInIfec) 
			   dDTIni1 := (cAlias)->R8_DATAINI
			Else
			   dDTIni1 := dDtInIfec
			EndIf
			
			If (cAlias)->R8_DATAFIM < DTOS(dDtFimFec) 
			   dDTIni2 := (cAlias)->R8_DATAFIM
			Else
			   dDTIni2 := dDtFimFec
			EndIf
			
			If VALTYPE(dDTIni2) == 'C' 
				dDtIni2 := STOD(dDTIni2)
			EndIf
			    
			If VALTYPE(dDTIni1) == 'C'   
				dDtIni1 := STOD(dDTIni1)
			EndIf     
			    
			nDiasAf += SR8->R8_DURACAO	          
			lAfast := .T.	
			(cAlias)->(DbSkip() )
		EndDo	

		(cAlias)->(DbCloseArea())
	EndIf
#ENDIF
Return lAfast