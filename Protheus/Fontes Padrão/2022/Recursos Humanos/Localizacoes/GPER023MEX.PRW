#include "Protheus.ch"
#INCLUDE "report.ch" 
#include "GPER023MEX.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GPER023MEX³ Autor  ³ Alfredo Medrano Breña    ³ Data ³ 08.04.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³COMPARATIVO MENSUAL SUA                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER023MEX()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Localización Mexico                                            ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³          ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER023MEX()
Local oReport   
Local aArea	:= GetArea()

Private cNomeProg := "GPER023MEX"
Private cPerg     := "GPER023MEX" 
Private nMesAnio  := 0 	//Mes/Anio
Private cRegPat   := ""	// Registro Patronal
Private cArch1    := ""	// Ruta de Archivo Mens. Movimeintos
Private cArch2    := ""	// Ruta de Archivo Mens. Dat. Personales
Private cTipRep   := ""	// Tipo de Reporte
Private aImpresion := {}	// Array que contendra los datos de TM y TP
Private cTMSUAMEN	:= "TMSUAMEN" // nombre Tabla Temporal Detalle Mensual
Private cTPSUAMEN	:= "TPSUAMEN" // nombre Tabla Temporal Personal
	
oReport := ReportDef() // Define el Reporteadmin
oReport:PrintDialog()

RestArea( aArea )
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ReportDef  ³ Autor ³Alfredo Medrano Breña ³ Data ³10/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Definicion del reporte                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportDef(   )                                              ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER023MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()   

Local oReport
Local oBreakPg                              
Local oSection1  //---Encabezado Patron  
Local oSection2  //---Datos Personal
Local oSection4  //---Datos Personal no procesados
Local oSection3  //---Detalle.
Local oSection5  //---Detalle Registros no Procesados.
Local cTitulo := OemToAnsi(STR0004)//--- COMPARATIVO DE CUOTAS OBRERO-PATRONALES - MENSUAL -

Pergunte(cPerg,.F.)

//--- Definición del Reporte
DEFINE REPORT oReport NAME cNomeProg TITLE OemToAnsi(cTitulo)  PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION ""
oReport:nColSpace 	:= 1			// Espacio entre columnas
oReport:nFontBody	:= 5 			// Define o tamanho da fonte.
oReport:nLineHeight	:= 40 			// Define a altura da linha.
oReport:cFontBody	:= "COURIER NEW"// Define Tipo de Letra 
oReport:Setlandscape(.T.)			// Pag Horizontal
oReport:SetTotalInLine(.F.)


//-- oSection1 Para encabezado del registro Patronal RCO
DEFINE SECTION oSection1 OF oReport TABLES "" TITLE OemToAnsi(cTitulo) 
oSection1 :SetHeaderSection() 
oSection1:SetLineStyle(.T.)   //Pone titulo del campo y aun lado el y valor 
	DEFINE CELL NAME "RCO_NREPAT"  	OF oSection1 ALIAS "RCO" SIZE TamSX3("RCO_NREPAT")[1]	TITLE oemToAnsi(STR0010)	//--- Registro patronal
	DEFINE CELL NAME "RCO_NOME"  	OF oSection1 ALIAS "RCO" SIZE TamSX3("RCO_NOME")[1] 	TITLE oemToAnsi(STR0012)	//--- Nombre o razon social
	DEFINE CELL NAME "TIT_RFC"  	OF oSection1 ALIAS "RCO" SIZE TamSX3("RCV_RFC")[1] + 5	TITLE oemToAnsi(STR0011)	//--- RFC
	DEFINE CELL NAME "RCH_ANOMES"  	OF oSection1 ALIAS "RCH" SIZE 10					 	TITLE oemToAnsi(STR0013)	//--- Mes y anio de proceso		
	
//-- oSection2 Para encabezado del Personal	
DEFINE SECTION oSection2 OF oReport TABLES "" TITLE OemToAnsi(cTitulo) 
oSection2:SetTotalInLine(.F.)  
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:nColSpace := 10
	DEFINE CELL NAME "TIT_PROV"		OF oSection2 ALIAS "SRA" 	SIZE 10 					TITLE oemToAnsi(STR0005)	//--- Proviene de   
	DEFINE CELL NAME "RA_RG"		OF oSection2 ALIAS "SRA"	SIZE TamSX3("RA_RG")[1] 	TITLE oemToAnsi(STR0006)	//--- Numero de seguridad social
	DEFINE CELL NAME "AST_RG"		OF oSection2 ALIAS ""	  	SIZE 2 						TITLE ""    
	DEFINE CELL NAME "RA_NOME"		OF oSection2 ALIAS "SRA" 	SIZE 50 					TITLE oemToAnsi(STR0007)	//--- Nombre
	DEFINE CELL NAME "AST_NOME"		OF oSection2 ALIAS ""	  	SIZE 2 						TITLE ""
	DEFINE CELL NAME "RA_MAT"		OF oSection2 ALIAS "SRA" 	SIZE TamSX3("RA_MAT")[1] 	TITLE oemToAnsi(STR0009)	//--- Empleado
	DEFINE CELL NAME "RA_CURP"		OF oSection2 ALIAS "SRA" 	SIZE TamSX3("RA_CURP")[1] 	TITLE oemToAnsi(STR0008)	//--- CURP
	DEFINE CELL NAME "AST_CURP"		OF oSection2 ALIAS ""	  	SIZE 2 						TITLE ""

//--- oSection3 Encabezado del Detalle del Reporte 
DEFINE SECTION oSection3 OF oReport TABLES "" TITLE OemToAnsi(cTitulo)
oSection3 :SetHeaderSection(.T.)
//-- oSection3 Para encabezado detalle de Empleados  
//--- CELL HEADER BORDER
	DEFINE CELL NAME "RHC_MAT"		OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_MAT")[1] 	TITLE oemToAnsi(STR0007)	//--- Mat	
	DEFINE CELL NAME "AST_MAT"		OF oSection3 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_CODPT"	OF oSection3 ALIAS "RHC" SIZE 6 						TITLE oemToAnsi(STR0010)	//--- Registro Patronal
	DEFINE CELL NAME "AST_CODPT"	OF oSection3 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "PROVIENE"		OF oSection3 ALIAS "RHC" SIZE 10						TITLE oemToAnsi(STR0005)	//--- Proviene de
	DEFINE CELL NAME "RHC_TPMOV"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_TPMOV")[1] 	TITLE oemToAnsi(STR0017)	//--- T.M.
	DEFINE CELL NAME "AST_TPMOV"	OF oSection3 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_DTMOV"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_DTMOV")[1]+2 TITLE oemToAnsi(STR0014)	//--- Fecha
	DEFINE CELL NAME "AST_DTMOV"	OF oSection3 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_NDTRAB"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_NDTRAB")[1] 	TITLE oemToAnsi(STR0015)	//--- Dias
	DEFINE CELL NAME "AST_NDTRAB"	OF oSection3 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_SALDII"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_SALDII")[1] 	TITLE oemToAnsi(STR0016)	PICTURE PesqPict("RHC","RHC_SALDII")//--- SDI
	DEFINE CELL NAME "AST_SALDII"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_CFPAT"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_CFPAT")[1] 	TITLE oemToAnsi(STR0018)	PICTURE PesqPict("RHC","RHC_CFPAT")//--- CF
	DEFINE CELL NAME "AST_CFPAT"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_EXEPAT"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_EXEPAT")[1] 	TITLE oemToAnsi(STR0027)	PICTURE PesqPict("RHC","RHC_EXEPAT")//--- EM.Pat
	DEFINE CELL NAME "AST_EXEPAT"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_EXETRA"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_EXETRA")[1]	TITLE oemToAnsi(STR0028)	PICTURE PesqPict("RHC","RHC_EXETRA")//--- EM.Obr
	DEFINE CELL NAME "AST_EXETRA"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""	
	DEFINE CELL NAME "RHC_PDPAT"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_PDPAT")[1] 	TITLE oemToAnsi(STR0030)	PICTURE PesqPict("RHC","RHC_PDPAT")//--- PD.Pat
	DEFINE CELL NAME "AST_PDPAT"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_PDTRA"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_PDTRA")[1] 	TITLE oemToAnsi(STR0031)	PICTURE PesqPict("RHC","RHC_PDTRA")//--- PD.Obr
	DEFINE CELL NAME "AST_PDTRA"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""	
	DEFINE CELL NAME "RHC_GMPPAT"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_GMPPAT")[1] 	TITLE oemToAnsi(STR0032)	PICTURE PesqPict("RHC","RHC_GMPPAT")//--- GMP.Pat
	DEFINE CELL NAME "AST_GMPPAT"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""  
	DEFINE CELL NAME "RHC_GMPTRA"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_GMPTRA")[1] 	TITLE oemToAnsi(STR0033)	PICTURE PesqPict("RHC","RHC_GMPTRA")//--- GMP.Obr 
	DEFINE CELL NAME "AST_GMPTRA"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""    
	DEFINE CELL NAME "RHC_RTPAT"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_RTPAT")[1] 	TITLE oemToAnsi(STR0022)	PICTURE PesqPict("RHC","RHC_RTPAT")//--- R.T.	
	DEFINE CELL NAME "AST_RTPAT"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_IVPAT"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_IVPAT")[1] 	TITLE oemToAnsi(STR0034)	PICTURE PesqPict("RHC","RHC_IVPAT")//--- IV.Pat
	DEFINE CELL NAME "AST_IVPAT"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_IVTRA"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_IVTRA")[1] 	TITLE oemToAnsi(STR0035)	PICTURE PesqPict("RHC","RHC_IVTRA")//--- IV.Obr
	DEFINE CELL NAME "AST_IVTRA"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""	
	DEFINE CELL NAME "RHC_GPSPAT"	OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_GPSPAT")[1] 	TITLE oemToAnsi(STR0024)	PICTURE PesqPict("RHC","RHC_GPSPAT")//--- G.P.S.
	DEFINE CELL NAME "AST_GPSPAT"	OF oSection3 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "TOTAL"		OF oSection3 ALIAS "RHC" SIZE TamSX3("RHC_IVTRA")[1] 	TITLE oemToAnsi(STR0026)	PICTURE PesqPict("RHC","RHC_IVTRA")//--- Total.

//-- oSection4 Para encabezado del Personal	(para registros no procesados)
DEFINE SECTION oSection4 OF oReport TABLES "" TITLE OemToAnsi(cTitulo) 
oSection4:SetTotalInLine(.F.)  
oSection4:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
oSection4:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection4:nColSpace := 10
	
	DEFINE CELL NAME "TIT_PROV"		OF oSection4 ALIAS "" 	SIZE 10 					TITLE oemToAnsi(STR0005)	//--- Proviene de   
	DEFINE CELL NAME "RA_RG"		OF oSection4 ALIAS ""	SIZE TamSX3("RA_RG")[1] 	TITLE oemToAnsi(STR0006)	//--- Numero de seguridad social
	DEFINE CELL NAME "AST_RG"		OF oSection4 ALIAS ""	SIZE 2 						TITLE ""    
	DEFINE CELL NAME "RA_NOME"		OF oSection4 ALIAS "" 	SIZE 50 					TITLE oemToAnsi(STR0007)	//--- Nombre
	DEFINE CELL NAME "AST_NOME"		OF oSection4 ALIAS ""	SIZE 2 						TITLE ""
	DEFINE CELL NAME "RA_MAT"		OF oSection4 ALIAS "" 	SIZE TamSX3("RA_MAT")[1] 	TITLE oemToAnsi(STR0009)	//--- Empleado
	DEFINE CELL NAME "RA_CURP"		OF oSection4 ALIAS "" 	SIZE TamSX3("RA_CURP")[1] 	TITLE oemToAnsi(STR0008)	//--- CURP
	DEFINE CELL NAME "AST_CURP"		OF oSection4 ALIAS ""	SIZE 2 						TITLE ""
	
	

//--- oSection5 Encabezado del Detalle del Reporte (para registros no procesados)
DEFINE SECTION oSection5 OF oReport TABLES "" TITLE ""
oSection5 :SetHeaderSection(.T.)

	DEFINE CELL NAME "RHC_MAT"		OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_MAT")[1] 	TITLE oemToAnsi(STR0007)	//--- Mat	
	DEFINE CELL NAME "AST_MAT"		OF oSection5 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_CODPT"	OF oSection5 ALIAS "RHC" SIZE 6 						TITLE oemToAnsi(STR0010)	//--- Registro Patronal
	DEFINE CELL NAME "AST_CODPT"	OF oSection5 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "PROVIENE"		OF oSection5 ALIAS "RHC" SIZE 10						TITLE oemToAnsi(STR0005)	//--- Proviene de
	DEFINE CELL NAME "RHC_TPMOV"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_TPMOV")[1] 	TITLE oemToAnsi(STR0017)	//--- T.M.
	DEFINE CELL NAME "AST_TPMOV"	OF oSection5 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_DTMOV"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_DTMOV")[1]+2 TITLE oemToAnsi(STR0014)	//--- Fecha
	DEFINE CELL NAME "AST_DTMOV"	OF oSection5 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_NDTRAB"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_NDTRAB")[1] 	TITLE oemToAnsi(STR0015)	//--- Dias
	DEFINE CELL NAME "AST_NDTRAB"	OF oSection5 ALIAS ""	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_SALDII"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_SALDII")[1] 	TITLE oemToAnsi(STR0016)	PICTURE PesqPict("RHC","RHC_SALDII")//--- SDI
	DEFINE CELL NAME "AST_SALDII"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_CFPAT"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_CFPAT")[1] 	TITLE oemToAnsi(STR0018)	PICTURE PesqPict("RHC","RHC_CFPAT")//--- CF
	DEFINE CELL NAME "AST_CFPAT"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_EXEPAT"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_EXEPAT")[1] 	TITLE oemToAnsi(STR0027)	PICTURE PesqPict("RHC","RHC_EXEPAT")//--- EM.Pat
	DEFINE CELL NAME "AST_EXEPAT"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_EXETRA"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_EXETRA")[1]	TITLE oemToAnsi(STR0028)	PICTURE PesqPict("RHC","RHC_EXETRA")//--- EM.Obr
	DEFINE CELL NAME "AST_EXETRA"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""	
	DEFINE CELL NAME "RHC_PDPAT"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_PDPAT")[1] 	TITLE oemToAnsi(STR0030)	PICTURE PesqPict("RHC","RHC_PDPAT")//--- PD.Pat
	DEFINE CELL NAME "AST_PDPAT"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_PDTRA"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_PDTRA")[1] 	TITLE oemToAnsi(STR0031)	PICTURE PesqPict("RHC","RHC_PDTRA")//--- PD.Obr
	DEFINE CELL NAME "AST_PDTRA"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""	
	DEFINE CELL NAME "RHC_GMPPAT"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_GMPPAT")[1] 	TITLE oemToAnsi(STR0032)	PICTURE PesqPict("RHC","RHC_GMPPAT")//--- GMP.Pat
	DEFINE CELL NAME "AST_GMPPAT"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""  
	DEFINE CELL NAME "RHC_GMPTRA"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_GMPTRA")[1] 	TITLE oemToAnsi(STR0033)	PICTURE PesqPict("RHC","RHC_GMPTRA")//--- GMP.Obr 
	DEFINE CELL NAME "AST_GMPTRA"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""    
	DEFINE CELL NAME "RHC_RTPAT"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_RTPAT")[1] 	TITLE oemToAnsi(STR0022)	PICTURE PesqPict("RHC","RHC_RTPAT")//--- R.T.	
	DEFINE CELL NAME "AST_RTPAT"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_IVPAT"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_IVPAT")[1] 	TITLE oemToAnsi(STR0034)	PICTURE PesqPict("RHC","RHC_IVPAT")//--- IV.Pat
	DEFINE CELL NAME "AST_IVPAT"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "RHC_IVTRA"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_IVTRA")[1] 	TITLE oemToAnsi(STR0035)	PICTURE PesqPict("RHC","RHC_IVTRA")//--- IV.Obr
	DEFINE CELL NAME "AST_IVTRA"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""	
	DEFINE CELL NAME "RHC_GPSPAT"	OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_GPSPAT")[1] 	TITLE oemToAnsi(STR0024)	PICTURE PesqPict("RHC","RHC_GPSPAT")//--- G.P.S.
	DEFINE CELL NAME "AST_GPSPAT"	OF oSection5 ALIAS "" 	  SIZE 2 						TITLE ""
	DEFINE CELL NAME "TOTAL"		OF oSection5 ALIAS "RHC" SIZE TamSX3("RHC_IVTRA")[1] 	TITLE oemToAnsi(STR0026)	PICTURE PesqPict("RHC","RHC_IVTRA")//--- Total.

//--- oSection5 Encabezado del Detalle del Reporte (para registros no procesados)
DEFINE SECTION oSection6 OF oReport TABLES "" TITLE ""
//oSection6 :SetHeaderSection(.T.)
DEFINE CELL NAME "NOPROS"		OF oSection6 ALIAS "" SIZE 100 	TITLE " "	//--- Mat		
oSection6:SetTotalInLine(.F.)  
oSection6:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection6:SetLineStyle(.F.)   	//Pone titulo del campo y aun lado el y valor 
oSection6:SetTotalText(" ") 	//Texto que será impreso antes de los totalizadores
oSection6:SetHeaderSection(.F.)	//Define de imprime cabeçalho das células na quebra de seção

oSection3:Cell("RHC_MAT"):Disable()
oSection3:Cell("RHC_CODPT"):Disable()
oSection5:Cell("RHC_MAT"):Disable()
oSection5:Cell("RHC_CODPT"):Disable()		

Return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³GP023MVAL  ³ Autor ³Alfredo Medrano Breña ³ Data ³23/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Validación Para Archivos y Campo vacío de Registro patronal ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GP023MVAL(   )                                              ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GP023MVAL()
Local lRet 			:= .T.
Local cRutas		:= ""
Local lRetAr1		:= .T.
Local lRetAr2		:= .T.


	If Len(AllTrim(cRegPat)) == 0
		AVISO(oemToAnsi(STR0036)) //"Seleccione un Registro Patronal"
		Return .F.
	EndIf
	// validacion de Archivos
	If !File(cArch1)	
		lRetAr1 := .f.	
	EndIF
	If !File(cArch2)
		lRetAr2 := .f.	
	EndIF
	If !lRetAr1 .OR. !lRetAr2
		cRutas := IF(!lRetAr1 .And. !lRetAr2, oemToAnsi(STR0044) + cArch1 + Chr(13)+ Chr(10) + oemToAnsi(STR0045) + cArch2,'')  
		cRutas += IF(!lRetAr1 .And. lRetAr2, oemToAnsi(STR0044)  + cArch1,'')
		cRutas += IF(lRetAr1 .And.  !lRetAr2, oemToAnsi(STR0045) + cArch2,'')
		Aviso( oemToAnsi(STR0002),OemToAnsi(STR0043)+ Chr(13)+ Chr(10) + cRutas, {OemToAnsi(STR0046)} ) //--- Aviso // "Los Siquientes Archivos no fueron encontrados:"  
		Return .F.
	EndIf
return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³PrintReport³ Autor ³Alfredo Medrano Freña ³ Data ³10/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Impresion del reporte                                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PrintReport( oExpO1 )                                       ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExpO1 :=  objeto del Reporte                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER023MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±	
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport)
Local aArea	:= GetArea()
//--- Secciones para impresion     
Local oSection1		:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oSection3		:= oReport:Section(3)
Local oSection4		:= oReport:Section(4)
Local oSection5		:= oReport:Section(5)
Local oSection6		:= oReport:Section(6)
//-- Variables
Local nX			:= 0
Local nCont			:= 0
Local nReg			:= 0		
Local cCod			:= ""
Local nI			:= 1
Local cAuxMat 		:= ""
Local nTam			:= TamSX3("RHC_CODRPA")[1]
Local cAnioMes		:= Alltrim(Str(nMesAnio))
Local cPeriodo		:= ""
Local cFilRCO		:= xFilial("RCO")
Local cNombre		:= ""
Local cAst			:= " *" // Para marcar las diferencias
Local cTpMV			:= ""
Local nTamReg		:= TamSX3("RCO_CODIGO")[1]
Local cLisPat		:= ""
Local aRegPat		:= {}
Local cAnioS 		:= ""
Local cMesS 		:= ""
Local cTitulo 		:= OemToAnsi(STR0004)//--- COMPARATIVO DE CUOTAS OBRERO-PATRONALES - MENSUAL -
Local cTipoR		:= ""
Local nContx		:= 0

Private cAliasRHC	:= "QRYRHC" 
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Preguntas selecionadas - GPER023MEX          ³
³ mv_par01     // Mes/Año?                     ³
³ mv_par02     // Registro patronal?           ³
³ mv_par03     // Arch Mens. Movimientos       ³
³ mv_par04     // Arch Mens. dat. personales   ³
³ mv_par05     // Informar?                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

nMesAnio:= MV_PAR01
cRegPat	:= Alltrim(MV_PAR02)
nTam 	:= nTam - Len(cRegPat)
cRegPat	:= cRegPat + Space(nTam)	
cArch1 	:= MV_PAR03
cArch2 	:= MV_PAR04  	
cTipRep	:= MV_PAR05  

//Validacion de Preguntas
IF !GP023MVAL()
	Return .F.
EndIf

For nCont := 1 To Len( cRegPat ) Step nTamReg       
	IF EMPTY(SubStr( cRegPat , nCont , nTamReg ))
	   EXIT
	ENDIF   
    cLisPat+="'"+SubStr( cRegPat , nCont , nTamReg )+"',"
    aAdd(aRegPat, SubStr( cRegPat , nCont , nTamReg ))
Next       

cLisPat:=substr(cLisPat,1,len(cLisPat)-1)
If cTipRep == 1
cTipoR := OemToAnsi(STR0041) + OemToAnsi(STR0039) + " " + OemToAnsi(STR0042) //"COMPARATIVO DE CUOTAS OBRERO-PATRONALES - MENSUAL - ( TODOS )"
ElseIf cTipRep == 2
cTipoR := OemToAnsi(STR0041) + OemToAnsi(STR0040) + " " + OemToAnsi(STR0042) //"COMPARATIVO DE CUOTAS OBRERO-PATRONALES - MENSUAL - ( DIFERENCIAS )"
EndIf

//Titulo del Reporte
oReport:SetTitle(cTitulo + cTipoR)

lRet 	:= GP23MXTBL() // Crea Las tablas Temporales
if lRet
   lRet := GP23MXLEE(cArch1,cArch2,aRegPat)	// Llenado de las tablas temporales TM / TP
   if !lRet
	   Return
	EndIF   	
Else
   Return
Endif
      	
//Totalizadores del reporte (IMSS)
DEFINE BREAK oBreakPrj OF oSection3 WHEN   oSection3:Cell("" )  TITLE oemToAnsi(STR0037) //"Total IMSS"  	
DEFINE FUNCTION oTFil 	 	NAME "oTFil"	 FROM oSection3:Cell("RHC_SALDII")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil2 	NAME "oTFil2" 	 FROM oSection3:Cell("RHC_CFPAT")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil3 	NAME "oTFil3" 	 FROM oSection3:Cell("RHC_EXEPAT")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil4 	NAME "oTFil4" 	 FROM oSection3:Cell("RHC_EXETRA")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil5  	NAME "oTFil5"	 FROM oSection3:Cell("RHC_PDPAT")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil6 	NAME "oTFil6" 	 FROM oSection3:Cell("RHC_PDTRA")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil7 	NAME "oTFil7" 	 FROM oSection3:Cell("RHC_GMPPAT")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil8 	NAME "oTFil8" 	 FROM oSection3:Cell("RHC_GMPTRA")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil9		NAME "oTFil9"	 FROM oSection3:Cell("RHC_RTPAT")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil10	NAME "oTFil10" 	 FROM oSection3:Cell("RHC_IVPAT")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" } 
DEFINE FUNCTION oTFil11 	NAME "oTFil11" 	 FROM oSection3:Cell("RHC_IVTRA")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil12 	NAME "oTFil12" 	 FROM oSection3:Cell("RHC_GPSPAT")	FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }
DEFINE FUNCTION oTFil13 	NAME "oTFil13" 	 FROM oSection3:Cell("TOTAL")		FUNCTION SUM BREAK oBreakPrj NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "IMSS" }

//Totalizadores del reporte (PROTHEUS)
DEFINE BREAK oBreakPrj2 OF oSection3 WHEN   oSection3:Cell("RHC_CODPT" )  TITLE oemToAnsi(STR0038) // "Total PROTHEUS"  
DEFINE FUNCTION oTFilp 	NAME "oTFilp1"	FROM oSection3:Cell("RHC_SALDII")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp1 	NAME "oTFilp2" 	FROM oSection3:Cell("RHC_CFPAT")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp2 	NAME "oTFilp3" 	FROM oSection3:Cell("RHC_EXEPAT")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp3 	NAME "oTFilp4" 	FROM oSection3:Cell("RHC_EXETRA")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp4  	NAME "oTFilp5"	FROM oSection3:Cell("RHC_PDPAT")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp5 	NAME "oTFilp6" 	FROM oSection3:Cell("RHC_PDTRA")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp6 	NAME "oTFilp7" 	FROM oSection3:Cell("RHC_GMPPAT")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp7 	NAME "oTFilp8" 	FROM oSection3:Cell("RHC_GMPTRA")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp8	NAME "oTFilp9"	FROM oSection3:Cell("RHC_RTPAT")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp9 	NAME "oTFilp10" FROM oSection3:Cell("RHC_IVPAT")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp10 	NAME "oTFilp11" FROM oSection3:Cell("RHC_IVTRA")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp11 	NAME "oTFilp12" FROM oSection3:Cell("RHC_GPSPAT")	FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }
DEFINE FUNCTION oTFilp12 	NAME "oTFilp13" FROM oSection3:Cell("TOTAL")		FUNCTION SUM BREAK oBreakPrj2 NO END SECTION WHEN {|| oSection3:Cell("PROVIENE" ):GetText() == "PROTHEUS" }

// Sustrae el periodo, año y mes de la cadena 
cAnioMes := Alltrim(Str(nMesAnio))
If Len(cAnioMes)<6
   cAnioMes := "0"+cAnioMes   
EndIf   
cPeriodo	:= SubStr(cAnioMes,1,2) + "/" + SubStr(cAnioMes,3,4)
cAnioMes	:= SubStr(cAnioMes,3,4) +  SubStr(cAnioMes,1,2)

//--- Impresión del reporte
DbSelectArea("RCO")
RCO->(DbSetOrder(1))
For nCont := 1 to Len(aRegPat)		// Recorre los Registro Patronales seleccionados
	nx:= 0
	If 	RCO-> (Dbseek(XFILIAL('RCO')+ aRegPat[nCont]))	// verifica que el código patronal existe
		
		IF GPER023QRY(cAnioMes,aRegPat[nCont],oReport) // genera query con el filtro del Registro Patronal
			oSection1:Init() // Datos Patronal
			oSection2:Init() // Datos Personal
			oSection3:Init() // Detalle
			//Separa el Mes y Año de la cadena cAnioMes
			cMesS	:= substr(cAnioMes, 5, 2) 
			cAnioS	:= substr(cAnioMes, 1, 4)
			//--- Seccion 4 datos patronales
			oSection1:Cell("RCO_NREPAT"):SetValue(RCO->RCO_NREPAT)			//--- Registro Patronal
			oSection1:Cell("RCO_NOME"):SetValue(RCO->RCO_NOME)				//--- Razon Social
			oSection1:Cell("TIT_RFC"):SetValue(" " + Alltrim(SM0->M0_CGC) )	//--- RFC
			oSection1:Cell("RCH_ANOMES"):SetValue(cMesS+"/"+cAnioS)			//--- Mes/Año 	
			oSection1:PrintLine() 											//--- Imprime Linea	  
		
		
			While (cAliasRHC)->(!Eof())// Recorre los registros Obtenidos
				If nx == 0
					GP23MXINC(oSection2, oSection3, Nil, Nil) //Inicializa el reporte con una línea vacía y no visualiza los valores	  
					GP23MXSHW(oSection3,Nil)//Activa o visualiza los valores del detalle
				EndIf
				/* Se imprime el valor de Tipo movimeinto
					 	deacuerdo a la siguiente tabla
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   	
					³    RHC_TPMOV	Imprimir	³
					³		00			9		³
					³		01			8		³
					³		02			2		³
					³		05			7		³
					³		06			8		³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   	
				Do Case
					Case (cAliasRHC)->RHC_TPMOV=="00"  
						cTpMV := "9"
					Case (cAliasRHC)->RHC_TPMOV=="01"  
						cTpMV := "8"
					Case (cAliasRHC)->RHC_TPMOV=="02"  
						cTpMV := "2"
					Case (cAliasRHC)->RHC_TPMOV=="05"  
						cTpMV := "7"		
					Case (cAliasRHC)->RHC_TPMOV=="06"  
						cTpMV := "8"			
				EndCase
						
				If cTpMV == "9" //si el tipo de movimiento es 9 la fecha estará vacía
					cFecha := space(10)
				Else
					cFecha := DtoS((cAliasRHC)->RHC_DTMOV)
				EndIF
				
			   If cTipRep == 1 // Tipo Reporte = Todos
			    	
					//Obtiene el Nombre completo separado por un espacio.
					cNombre := RTRIM((cAliasRHC)->RA_PRISOBR) + Space(1) +  RTRIM((cAliasRHC)->RA_SECSOBR) + Space(1) + RTRIM((cAliasRHC)->RA_PRINOME) + Space(1) + RTRIM((cAliasRHC)->RA_SECNOME)
					
					//Imprime Datos de Personal Protheus
					oSection2:Cell("TIT_PROV"):SetValue("PROTHEUS")				//--- Proviene de  Protheus
					oSection2:Cell("RA_RG"):SetValue((cAliasRHC)->RA_RG		)	//--- Numero SS
					oSection2:Cell("RA_NOME"):SetValue(cNombre				)	//--- Nombre del empleado
					oSection2:Cell("RA_MAT"):SetValue((cAliasRHC)->RA_MAT	)  	//--- Matricula 
					oSection2:Cell("RA_CURP"):SetValue((cAliasRHC)->RA_CURP	)	//--- Curp
					oSection2:Cell("AST_RG"):SetValue("") 	//--- Numero SS
					oSection2:Cell("AST_NOME"):SetValue("")	//--- Nombre del empleado
					oSection2:Cell("AST_CURP"):SetValue("") 	//--- Curp
					oSection2:PrintLine()
				
					//Busca e Imprime Datos de Personal IMSS (TP)
					If (cTPSUAMEN)->(DbSeek((cAliasRHC)->RA_MAT))					//TM_MAT
						oSection2:Cell("TIT_PROV"):SetValue("IMSS")			//--- Proviene de  Protheus/Imss
						oSection2:Cell("RA_MAT"):SetValue((cTPSUAMEN)->TP_MAT		)  		//--- Matricula 
			       		oSection2:Cell("RA_NOME"):SetValue((cTPSUAMEN)->TP_NOMBRE	) //--- Nombre del empleado
			       		oSection2:Cell("RA_RG"):SetValue((cTPSUAMEN)->TP_NSS		) //--- Numero SS
						oSection2:Cell("RA_CURP"):SetValue((cTPSUAMEN)->TP_CURP		) //--- Curp
						
						oSection2:Cell("AST_RG"):SetValue(  IF((cTPSUAMEN)->TP_NSS 	!= (cAliasRHC)->RA_RG,				cAst,'' )) 	//--- Numero SS
						oSection2:Cell("AST_NOME"):SetValue(IF(AllTrim((cTPSUAMEN)->TP_NOMBRE)	!= AllTrim(cNombre), 	cAst,'' ))	//--- Nombre del empleado
						oSection2:Cell("AST_CURP"):SetValue(IF((cTPSUAMEN)->TP_CURP 	!= (cAliasRHC)->RA_CURP, 		cAst,'' )) 	//--- Curp
						
						
						oSection2:PrintLine()	  
			    	
			    		
			
			    	EndIf 
			    	   	
			    		//Imprime Detalle de Personal Protheus
			    		oSection3:Cell("PROVIENE"):SetValue("PROTHEUS")						//--- Proviene Protheus
						oSection3:Cell("RHC_MAT"):SetValue((cAliasRHC)->RA_MAT)				//--- Matricula 
						oSection3:Cell("RHC_TPMOV"):SetValue(cTpMV)							//--- TM
						oSection3:Cell("RHC_DTMOV"):SetValue(cFecha)						//--- Fecha
						oSection3:Cell("RHC_NDTRAB"):SetValue((cAliasRHC)->RHC_NDTRAB	)	//--- Dias
						oSection3:Cell("RHC_SALDII"):SetValue((cAliasRHC)->RHC_SALDII	)	//--- SDI
						oSection3:Cell("RHC_CFPAT"):SetValue((cAliasRHC)->RHC_CFPAT		)	//--- CF	
						oSection3:Cell("RHC_EXEPAT"):SetValue((cAliasRHC)->RHC_EXEPAT	)	//--- Dias Enf. y mat exc. Patron
						oSection3:Cell("RHC_EXETRA"):SetValue((cAliasRHC)->RHC_EXETRA	)	//--- Dias Enf. y mat exc. trabjador
						oSection3:Cell("RHC_PDPAT"):SetValue((cAliasRHC)->RHC_PDPAT		)	//--- PD Patron
						oSection3:Cell("RHC_PDTRA"):SetValue((cAliasRHC)->RHC_PDTRA		)	//--- PD Trabajador
						oSection3:Cell("RHC_GMPPAT"):SetValue((cAliasRHC)->RHC_GMPPAT	)	//--- GMP Patron
						oSection3:Cell("RHC_GMPTRA"):SetValue((cAliasRHC)->RHC_GMPTRA	)	//--- GMP Trabajador
						oSection3:Cell("RHC_RTPAT"):SetValue((cAliasRHC)->RHC_RTPAT		)	//--- RT Patron
						oSection3:Cell("RHC_IVPAT"):SetValue((cAliasRHC)->RHC_IVPAT		)	//--- IV Patron
						oSection3:Cell("RHC_IVTRA"):SetValue((cAliasRHC)->RHC_IVTRA		)	//--- IV Trabajador
						oSection3:Cell("RHC_GPSPAT"):SetValue((cAliasRHC)->RHC_GPSPAT	)	//--- GPS Patron
						oSection3:Cell("TOTAL"):SetValue((cAliasRHC)->SUMA)					//--- Total
						
						oSection3:Cell("AST_MAT"):SetValue("")			//--- Matricula
						oSection3:Cell("AST_TPMOV"):SetValue("")		//--- TM
						oSection3:Cell("AST_DTMOV"):SetValue("")		//--- Fecha
						oSection3:Cell("AST_NDTRAB"):SetValue("")		//--- Dias
						oSection3:Cell("AST_SALDII"):SetValue("")		//--- SDI
						oSection3:Cell("AST_CFPAT"):SetValue("")		//--- CF	
						oSection3:Cell("AST_EXEPAT"):SetValue("")		//--- Dias Enf. y mat exc. Patron
						oSection3:Cell("AST_EXETRA"):SetValue("")		//--- Dias Enf. y mat exc. trabjador
						oSection3:Cell("AST_PDPAT"):SetValue("")		//--- PD Patron
						oSection3:Cell("AST_PDTRA"):SetValue("")		//--- PD Trabajador
						oSection3:Cell("AST_GMPPAT"):SetValue("")		//--- GMP Patron
						oSection3:Cell("AST_GMPTRA"):SetValue("")		//--- GMP Trabajador
						oSection3:Cell("AST_RTPAT"):SetValue("")		//--- RT Patron
						oSection3:Cell("AST_IVPAT"):SetValue("")		//--- IV Patron
						oSection3:Cell("AST_IVTRA"):SetValue("")		//--- IV Trabajador
						oSection3:Cell("AST_GPSPAT"):SetValue("")		//--- GPS Patron			
						
			    		oSection3:PrintLine()
			    		//Busca e Imprime Detalle IMSS (TM)
			    		If (cTMSUAMEN)->(DbSeek((cAliasRHC)->RA_MAT +DTOS((cAliasRHC)->RHC_DTMOV) + cTpMV)) //TM_MAT+TM_DTMOV+TM_TPMOV
				    		
				    		oSection3:Cell("PROVIENE"):SetValue("IMSS")				//--- Proviene Imss
				    		oSection3:Cell("RHC_MAT"):SetValue(ALLTRIM((cTMSUAMEN)->TM_MAT) )	//--- Matricula
							oSection3:Cell("RHC_TPMOV"):SetValue(ALLTRIM(cTpMV)				)	//--- TM
							oSection3:Cell("RHC_DTMOV"):SetValue(DTOC((cTMSUAMEN)->TM_DTMOV))	//--- Fecha
							oSection3:Cell("RHC_NDTRAB"):SetValue((cTMSUAMEN)->TM_NDTRAB	)	//--- Dias
							oSection3:Cell("RHC_SALDII"):SetValue((cTMSUAMEN)->TM_SALDII	)	//--- SDI
							oSection3:Cell("RHC_CFPAT"):SetValue((cTMSUAMEN)->TM_CFPAT		)	//--- CF	
							oSection3:Cell("RHC_EXEPAT"):SetValue((cTMSUAMEN)->TM_EXEPAT	)	//--- Dias Enf. y mat exc. Patron
							oSection3:Cell("RHC_EXETRA"):SetValue((cTMSUAMEN)->TM_EXETRA	)	//--- Dias Enf. y mat exc. trabjador
							oSection3:Cell("RHC_PDPAT"):SetValue((cTMSUAMEN)->TM_PDPAT 		)	//--- PD Patron
							oSection3:Cell("RHC_PDTRA"):SetValue((cTMSUAMEN)->TM_PDTRA 		)	//--- PD Trabajador
							oSection3:Cell("RHC_GMPPAT"):SetValue((cTMSUAMEN)->TM_GMPPAT	)	//--- GMP Patron
							oSection3:Cell("RHC_GMPTRA"):SetValue((cTMSUAMEN)->TM_GMPTRA	)	//--- GMP Trabajador
							oSection3:Cell("RHC_RTPAT"):SetValue((cTMSUAMEN)->TM_RTPAT 		)	//--- RT Patron
							oSection3:Cell("RHC_IVPAT"):SetValue((cTMSUAMEN)->TM_IVPAT 		)	//--- IV Patron
							oSection3:Cell("RHC_IVTRA"):SetValue((cTMSUAMEN)->TM_IVTRA 		)	//--- IV Trabajador
							oSection3:Cell("RHC_GPSPAT"):SetValue((cTMSUAMEN)->TM_GPSPAT 	)	//--- GPS Patron
							oSection3:Cell("TOTAL"):SetValue((cTMSUAMEN)->TM_GPSPAT + (cTMSUAMEN)->TM_IVTRA) //--- Total    	
								
				    		oSection3:Cell("AST_MAT"):SetValue(		IF((cTMSUAMEN)->TM_MAT 		!= (cAliasRHC)->RA_MAT, cAst, ''))			//--- Matricula
							oSection3:Cell("AST_TPMOV"):SetValue(	IF((cTMSUAMEN)->TM_TPMOV	!= cTpMV,	cAst, ''))					//--- TM
							oSection3:Cell("AST_DTMOV"):SetValue(	IF((cTMSUAMEN)->TM_DTMOV	!= (cAliasRHC)->RHC_DTMOV, 	cAst, ''))	//--- Fecha
							oSection3:Cell("AST_NDTRAB"):SetValue(	IF((cTMSUAMEN)->TM_NDTRAB	!= (cAliasRHC)->RHC_NDTRAB,	cAst, ''))	//--- Dias
							oSection3:Cell("AST_SALDII"):SetValue(	IF((cTMSUAMEN)->TM_SALDII	!= (cAliasRHC)->RHC_SALDII,	cAst, ''))	//--- SDI
							oSection3:Cell("AST_CFPAT"):SetValue(	IF((cTMSUAMEN)->TM_CFPAT	!= (cAliasRHC)->RHC_CFPAT,	cAst, ''))	//--- CF	
							oSection3:Cell("AST_EXEPAT"):SetValue(	IF((cTMSUAMEN)->TM_EXEPAT	!= (cAliasRHC)->RHC_EXEPAT,	cAst, ''))	//--- Dias Enf. y mat exc. Patron
							oSection3:Cell("AST_EXETRA"):SetValue(	IF((cTMSUAMEN)->TM_EXETRA	!= (cAliasRHC)->RHC_EXETRA,	cAst, ''))	//--- Dias Enf. y mat exc. trabjador
							oSection3:Cell("AST_PDPAT"):SetValue(	IF((cTMSUAMEN)->TM_PDPAT	!= (cAliasRHC)->RHC_PDPAT, 	cAst, ''))	//--- PD Patron
							oSection3:Cell("AST_PDTRA"):SetValue(	IF((cTMSUAMEN)->TM_PDTRA	!= (cAliasRHC)->RHC_PDTRA, 	cAst, ''))	//--- PD Trabajador
							oSection3:Cell("AST_GMPPAT"):SetValue(	IF((cTMSUAMEN)->TM_GMPPAT	!= (cAliasRHC)->RHC_GMPPAT,	cAst, ''))	//--- GMP Patron
							oSection3:Cell("AST_GMPTRA"):SetValue(	IF((cTMSUAMEN)->TM_GMPTRA	!= (cAliasRHC)->RHC_GMPTRA,	cAst, ''))	//--- GMP Trabajador
							oSection3:Cell("AST_RTPAT"):SetValue(	IF((cTMSUAMEN)->TM_RTPAT	!= (cAliasRHC)->RHC_RTPAT,	cAst, ''))	//--- RT Patron
							oSection3:Cell("AST_IVPAT"):SetValue(	IF((cTMSUAMEN)->TM_IVPAT	!= (cAliasRHC)->RHC_IVPAT, 	cAst, ''))	//--- IV Patron
							oSection3:Cell("AST_IVTRA"):SetValue(	IF((cTMSUAMEN)->TM_IVTRA	!= (cAliasRHC)->RHC_IVTRA, 	cAst, ''))	//--- IV Trabajador
							oSection3:Cell("AST_GPSPAT"):SetValue(	IF((cTMSUAMEN)->TM_GPSPAT	!= (cAliasRHC)->RHC_GPSPAT, cAst, ''))	//--- GPS Patron
							
							oSection3:PrintLine()
								
				    		//Marca los Registros que Fueron Leídos
			    			RECLOCK(cTMSUAMEN,.F.)
			          	   	(cTMSUAMEN)->TM_LEIDO	:= "S"
							(cTMSUAMEN)->(MSUNLOCK())		  
			    		EndIf
			    		
			    	ElseIf cTipRep == 2 // Tipo Reporte = Diferencias
			    
			    		
							
								//Busca e Imprime Datos de Personal IMSS (TP)
							If (cTPSUAMEN)->(DbSeek((cAliasRHC)->RA_MAT))					//TM_MAT
								//Obtiene el Nombre completo separado por un espacio.
								cNombre := RTRIM((cAliasRHC)->RA_PRISOBR) + Space(1) +  RTRIM((cAliasRHC)->RA_SECSOBR) + Space(1) + RTRIM((cAliasRHC)->RA_PRINOME) + Space(1) + RTRIM((cAliasRHC)->RA_SECNOME)
								
								If (cTPSUAMEN)->TP_NSS 	!= (cAliasRHC)->RA_RG .OR. ALLTRIM((cTPSUAMEN)->TP_NOMBRE)	!= ALLTRIM(cNombre) .OR. (cTPSUAMEN)->TP_CURP 	!= (cAliasRHC)->RA_CURP
										
									//Imprime Datos de Personal Protheus
									oSection2:Cell("TIT_PROV"):SetValue("PROTHEUS")				//--- Proviene de  Protheus
									oSection2:Cell("RA_RG"):SetValue((cAliasRHC)->RA_RG		)  	//--- Numero SS
									oSection2:Cell("RA_NOME"):SetValue(cNombre				)	//--- Nombre del empleado
									oSection2:Cell("RA_MAT"):SetValue((cAliasRHC)->RA_MAT	)  //--- Matricula 
									oSection2:Cell("RA_CURP"):SetValue((cAliasRHC)->RA_CURP	)	//--- Curp
									oSection2:Cell("AST_RG"):SetValue("") 	//--- Numero SS
									oSection2:Cell("AST_NOME"):SetValue("")	//--- Nombre del empleado
									oSection2:Cell("AST_CURP"):SetValue("") //--- Curp
									oSection2:PrintLine()
								
									oSection2:Cell("TIT_PROV"):SetValue("IMSS")					//--- Proviene de  Protheus/Imss
									oSection2:Cell("RA_MAT"):SetValue((cTPSUAMEN)->TP_MAT		)  		//--- Matricula 
						       		oSection2:Cell("RA_NOME"):SetValue((cTPSUAMEN)->TP_NOMBRE	) //--- Nombre del empleado
						       		oSection2:Cell("RA_RG"):SetValue((cTPSUAMEN)->TP_NSS		) //--- Numero SS
									oSection2:Cell("RA_CURP"):SetValue((cTPSUAMEN)->TP_CURP		) //--- Curp
									
									oSection2:Cell("AST_RG"):SetValue(	IF((cTPSUAMEN)->TP_NSS 		!= (cAliasRHC)->RA_RG,		cAst,'' )) 	//--- Numero SS
									oSection2:Cell("AST_NOME"):SetValue(IF(AllTrim((cTPSUAMEN)->TP_NOMBRE)	!= AllTrim(cNombre),cAst,'' ))	//--- Nombre del empleado
									oSection2:Cell("AST_CURP"):SetValue(IF((cTPSUAMEN)->TP_CURP 	!= (cAliasRHC)->RA_CURP, 	cAst,'' )) 	//--- Curp
									
									oSection2:PrintLine()	
									
									nContx := 1
									
								EndIF  
						   EndIf 
						    	   	
			    		//Busca e Imprime Detalle IMSS (TM)
			    		If (cTMSUAMEN)->(DbSeek((cAliasRHC)->RA_MAT +DTOS((cAliasRHC)->RHC_DTMOV) + cTpMV)) //TM_MAT+TM_DTMOV+TM_TPMOV
				    		// si hay diferencias se imprimen
				    		IF (cTMSUAMEN)->TM_MAT != (cAliasRHC)->RA_MAT .OR. (cTMSUAMEN)->TM_TPMOV != cTpMV .OR.	(cTMSUAMEN)->TM_DTMOV != (cAliasRHC)->RHC_DTMOV .OR. (cTMSUAMEN)->TM_NDTRAB != (cAliasRHC)->RHC_NDTRAB ;
				    			.OR. (cTMSUAMEN)->TM_SALDII != (cAliasRHC)->RHC_SALDII .OR. (cTMSUAMEN)->TM_CFPAT	!= (cAliasRHC)->RHC_CFPAT .OR. (cTMSUAMEN)->TM_EXEPAT != (cAliasRHC)->RHC_EXEPAT .OR. ;
				    			(cTMSUAMEN)->TM_EXETRA != (cAliasRHC)->RHC_EXETRA .OR. (cTMSUAMEN)->TM_PDPAT	!= (cAliasRHC)->RHC_PDPAT .OR. (cTMSUAMEN)->TM_PDTRA	!= (cAliasRHC)->RHC_PDTRA .OR. ;
								(cTMSUAMEN)->TM_GMPPAT != (cAliasRHC)->RHC_GMPPAT .OR. (cTMSUAMEN)->TM_GMPTRA	!= (cAliasRHC)->RHC_GMPTRA .OR. (cTMSUAMEN)->TM_RTPAT != (cAliasRHC)->RHC_RTPAT .OR. ;
								(cTMSUAMEN)->TM_IVPAT != (cAliasRHC)->RHC_IVPAT .OR. (cTMSUAMEN)->TM_IVTRA != (cAliasRHC)->RHC_IVTRA .OR. (cTMSUAMEN)->TM_GPSPAT	!= (cAliasRHC)->RHC_GPSPAT
							
								If nContx == 0
									//Obtiene el Nombre completo separado por un espacio.
									cNombre := RTRIM((cAliasRHC)->RA_PRISOBR) + Space(1) +  RTRIM((cAliasRHC)->RA_SECSOBR) + Space(1) + RTRIM((cAliasRHC)->RA_PRINOME) + Space(1) + RTRIM((cAliasRHC)->RA_SECNOME)
									//Imprime Datos de Personal Protheus
									oSection2:Cell("TIT_PROV"):SetValue("PROTHEUS")				//--- Proviene de  Protheus
									oSection2:Cell("RA_RG"):SetValue((cAliasRHC)->RA_RG		)  	//--- Numero SS
									oSection2:Cell("RA_NOME"):SetValue(cNombre				)	//--- Nombre del empleado
									oSection2:Cell("RA_MAT"):SetValue((cAliasRHC)->RA_MAT	)  //--- Matricula 
									oSection2:Cell("RA_CURP"):SetValue((cAliasRHC)->RA_CURP	)	//--- Curp
									oSection2:Cell("AST_RG"):SetValue("") 	//--- Numero SS
									oSection2:Cell("AST_NOME"):SetValue("")	//--- Nombre del empleado
									oSection2:Cell("AST_CURP"):SetValue("") 	//--- Curp
									oSection2:PrintLine()
									
								EndIf
								
								
						    		//Imprime Detalle de Personal Protheus
					    			oSection3:Cell("PROVIENE"):SetValue("PROTHEUS")						//--- Proviene Protheus
									oSection3:Cell("RHC_MAT"):SetValue((cAliasRHC)->RA_MAT)				//--- Matricula 
									oSection3:Cell("RHC_TPMOV"):SetValue(cTpMV)							//--- TM
									oSection3:Cell("RHC_DTMOV"):SetValue(cFecha)						//--- Fecha
									oSection3:Cell("RHC_NDTRAB"):SetValue((cAliasRHC)->RHC_NDTRAB	)	//--- Dias
									oSection3:Cell("RHC_SALDII"):SetValue((cAliasRHC)->RHC_SALDII	)	//--- SDI
									oSection3:Cell("RHC_CFPAT"):SetValue((cAliasRHC)->RHC_CFPAT		)	//--- CF	
									oSection3:Cell("RHC_EXEPAT"):SetValue((cAliasRHC)->RHC_EXEPAT	)	//--- Dias Enf. y mat exc. Patron
									oSection3:Cell("RHC_EXETRA"):SetValue((cAliasRHC)->RHC_EXETRA	)	//--- Dias Enf. y mat exc. trabjador
									oSection3:Cell("RHC_PDPAT"):SetValue((cAliasRHC)->RHC_PDPAT		)	//--- PD Patron
									oSection3:Cell("RHC_PDTRA"):SetValue((cAliasRHC)->RHC_PDTRA		)	//--- PD Trabajador
									oSection3:Cell("RHC_GMPPAT"):SetValue((cAliasRHC)->RHC_GMPPAT	)	//--- GMP Patron
									oSection3:Cell("RHC_GMPTRA"):SetValue((cAliasRHC)->RHC_GMPTRA	)	//--- GMP Trabajador
									oSection3:Cell("RHC_RTPAT"):SetValue((cAliasRHC)->RHC_RTPAT		)	//--- RT Patron
									oSection3:Cell("RHC_IVPAT"):SetValue((cAliasRHC)->RHC_IVPAT		)	//--- IV Patron
									oSection3:Cell("RHC_IVTRA"):SetValue((cAliasRHC)->RHC_IVTRA		)	//--- IV Trabajador
									oSection3:Cell("RHC_GPSPAT"):SetValue((cAliasRHC)->RHC_GPSPAT	)	//--- GPS Patron
									oSection3:Cell("TOTAL"):Hide()										//--- Total
								
									oSection3:Cell("AST_MAT"):SetValue("")		//--- Matricula
									oSection3:Cell("AST_TPMOV"):SetValue("")	//--- TM
									oSection3:Cell("AST_DTMOV"):SetValue("")	//--- Fecha
									oSection3:Cell("AST_NDTRAB"):SetValue("")	//--- Dias
									oSection3:Cell("AST_SALDII"):SetValue("")	//--- SDI
									oSection3:Cell("AST_CFPAT"):SetValue("")	//--- CF	
									oSection3:Cell("AST_EXEPAT"):SetValue("")	//--- Dias Enf. y mat exc. Patron
									oSection3:Cell("AST_EXETRA"):SetValue("")	//--- Dias Enf. y mat exc. trabjador
									oSection3:Cell("AST_PDPAT"):SetValue("")	//--- PD Patron
									oSection3:Cell("AST_PDTRA"):SetValue("")	//--- PD Trabajador
									oSection3:Cell("AST_GMPPAT"):SetValue("")	//--- GMP Patron
									oSection3:Cell("AST_GMPTRA"):SetValue("")	//--- GMP Trabajador
									oSection3:Cell("AST_RTPAT"):SetValue("")	//--- RT Patron
									oSection3:Cell("AST_IVPAT"):SetValue("")	//--- IV Patron
									oSection3:Cell("AST_IVTRA"):SetValue("")	//--- IV Trabajador
									oSection3:Cell("AST_GPSPAT"):SetValue("")	//--- GPS Patron			
								
					    			oSection3:PrintLine()
					    		
					    		
					    			oSection3:Cell("PROVIENE"):SetValue("IMSS")							//--- Proviene Imss
					    			oSection3:Cell("RHC_MAT"):SetValue(ALLTRIM((cTMSUAMEN)->TM_MAT) )	//--- Matricula
									oSection3:Cell("RHC_TPMOV"):SetValue(ALLTRIM(cTpMV)				)	//--- TM
									oSection3:Cell("RHC_DTMOV"):SetValue(DTOC((cTMSUAMEN)->TM_DTMOV))	//--- Fecha
									oSection3:Cell("RHC_NDTRAB"):SetValue((cTMSUAMEN)->TM_NDTRAB	)	//--- Dias
									oSection3:Cell("RHC_SALDII"):SetValue((cTMSUAMEN)->TM_SALDII	)	//--- SDI
									oSection3:Cell("RHC_CFPAT"):SetValue((cTMSUAMEN)->TM_CFPAT		)	//--- CF	
									oSection3:Cell("RHC_EXEPAT"):SetValue((cTMSUAMEN)->TM_EXEPAT	)	//--- Dias Enf. y mat exc. Patron
									oSection3:Cell("RHC_EXETRA"):SetValue((cTMSUAMEN)->TM_EXETRA	)	//--- Dias Enf. y mat exc. trabjador
									oSection3:Cell("RHC_PDPAT"):SetValue((cTMSUAMEN)->TM_PDPAT 		)	//--- PD Patron
									oSection3:Cell("RHC_PDTRA"):SetValue((cTMSUAMEN)->TM_PDTRA 		)	//--- PD Trabajador
									oSection3:Cell("RHC_GMPPAT"):SetValue((cTMSUAMEN)->TM_GMPPAT	)	//--- GMP Patron
									oSection3:Cell("RHC_GMPTRA"):SetValue((cTMSUAMEN)->TM_GMPTRA	)	//--- GMP Trabajador
									oSection3:Cell("RHC_RTPAT"):SetValue((cTMSUAMEN)->TM_RTPAT 		)	//--- RT Patron
									oSection3:Cell("RHC_IVPAT"):SetValue((cTMSUAMEN)->TM_IVPAT 		)	//--- IV Patron
									oSection3:Cell("RHC_IVTRA"):SetValue((cTMSUAMEN)->TM_IVTRA 		)	//--- IV Trabajador
									oSection3:Cell("RHC_GPSPAT"):SetValue((cTMSUAMEN)->TM_GPSPAT 	)	//--- GPS Patron
									oSection3:Cell("TOTAL"):Hide()										//--- Total    	
								
										
						    		oSection3:Cell("AST_MAT"):SetValue(		IF((cTMSUAMEN)->TM_MAT 		!= (cAliasRHC)->RA_MAT, cAst, ''))		//--- Matricula
									oSection3:Cell("AST_TPMOV"):SetValue(	IF((cTMSUAMEN)->TM_TPMOV	!= cTpMV,	cAst, ''))					//--- TM
									oSection3:Cell("AST_DTMOV"):SetValue(	IF((cTMSUAMEN)->TM_DTMOV	!= (cAliasRHC)->RHC_DTMOV, 	cAst, ''))	//--- Fecha
									oSection3:Cell("AST_NDTRAB"):SetValue(	IF((cTMSUAMEN)->TM_NDTRAB	!= (cAliasRHC)->RHC_NDTRAB,	cAst, ''))	//--- Dias
									oSection3:Cell("AST_SALDII"):SetValue(	IF((cTMSUAMEN)->TM_SALDII	!= (cAliasRHC)->RHC_SALDII,	cAst, ''))	//--- SDI
									oSection3:Cell("AST_CFPAT"):SetValue(	IF((cTMSUAMEN)->TM_CFPAT	!= (cAliasRHC)->RHC_CFPAT,	cAst, ''))	//--- CF	
									oSection3:Cell("AST_EXEPAT"):SetValue(	IF((cTMSUAMEN)->TM_EXEPAT	!= (cAliasRHC)->RHC_EXEPAT,	cAst, ''))	//--- Dias Enf. y mat exc. Patron
									oSection3:Cell("AST_EXETRA"):SetValue(	IF((cTMSUAMEN)->TM_EXETRA	!= (cAliasRHC)->RHC_EXETRA,	cAst, ''))	//--- Dias Enf. y mat exc. trabjador
									oSection3:Cell("AST_PDPAT"):SetValue(	IF((cTMSUAMEN)->TM_PDPAT	!= (cAliasRHC)->RHC_PDPAT, 	cAst, ''))	//--- PD Patron
									oSection3:Cell("AST_PDTRA"):SetValue(	IF((cTMSUAMEN)->TM_PDTRA	!= (cAliasRHC)->RHC_PDTRA, 	cAst, ''))	//--- PD Trabajador
									oSection3:Cell("AST_GMPPAT"):SetValue(	IF((cTMSUAMEN)->TM_GMPPAT	!= (cAliasRHC)->RHC_GMPPAT,	cAst, ''))	//--- GMP Patron
									oSection3:Cell("AST_GMPTRA"):SetValue(	IF((cTMSUAMEN)->TM_GMPTRA	!= (cAliasRHC)->RHC_GMPTRA,	cAst, ''))	//--- GMP Trabajador
									oSection3:Cell("AST_RTPAT"):SetValue(	IF((cTMSUAMEN)->TM_RTPAT	!= (cAliasRHC)->RHC_RTPAT,	cAst, ''))	//--- RT Patron
									oSection3:Cell("AST_IVPAT"):SetValue(	IF((cTMSUAMEN)->TM_IVPAT	!= (cAliasRHC)->RHC_IVPAT, 	cAst, ''))	//--- IV Patron
									oSection3:Cell("AST_IVTRA"):SetValue(	IF((cTMSUAMEN)->TM_IVTRA	!= (cAliasRHC)->RHC_IVTRA, 	cAst, ''))	//--- IV Trabajador
									oSection3:Cell("AST_GPSPAT"):SetValue(	IF((cTMSUAMEN)->TM_GPSPAT	!= (cAliasRHC)->RHC_GPSPAT, cAst, ''))	//--- GPS Patron
									
									oSection3:PrintLine()
									nContx := 0
										
				    		EndIf
				    				//Marca los Registros que Fueron Leídos
									RECLOCK(cTMSUAMEN,.F.)
				          	   		(cTMSUAMEN)->TM_LEIDO	:= "S"
									(cTMSUAMEN)->(MSUNLOCK())
			    		EndIf
			    	EndIf
			    	nx++	
			    //EndIf
		     	oReport:IncMeter()   //regla de avance
				(cAliasRHC)->(dbSkip())
			EndDo
		EndIF 	
	EndIf
		(cAliasRHC)->(DbCloseArea())
		oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
		oReport:EndPage()
Next		

//imprimir los movimientos de IMSS que no tuvieron coincidencia con la tabla RHC.
GPR023ISC(oSection4,oSection5,oSection6)

(cTPSUAMEN)->(DbCloseArea())
(cTMSUAMEN)->(DbCloseArea())
		
RestArea( aArea )
Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GPER023QRY³ Autor ³ Alfredo Medrano       ³ Data ³10/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtiene los Registros de la consulta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER023QRY(cExpO1,cExpO2,oExpO3)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpO1 :  Año y mes                                        ³±±
±±³          ³ cExpO2 :  Registro Patronal                          	  ³±±
±±³          ³ oExpO3 :  objeto del Reporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function GPER023QRY(cAnioMes,cRegP,oReport)

Local cFilRHC		:= xFilial("RHC")
Local cFilRCO		:= xFilial("RCO")
Local cFilSRA		:= xFilial("SRA")
Local cFilRHD		:= xFilial("RHD")
Local cCposQuery 	:= ""
Local cCposFrom  	:= ""
Local cWhere 		:= ""
Local cOrdem     	:= "" 
Local lRet 			:= .F.
Local nTotal		:= 0

	//Transforma los parametros de tipo Rango en expresion SQL para ser utilizada en query 
	cCposQuery 	:="%RHC.*,RHC_CODRPA, RA_RG, RA_MAT, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_CURP, (RHC_IVTRA + RHC_GPSPAT) SUMA%" 
	cCposFrom  	:="%" + RetSqlName("RHD") + " RHD, " 
	cCposFrom   +=  RetSqlName("RCO")+ " RCO, "
	cCposFrom  	+=	RetSqlName("SRA")+ " SRA, "
	cCposFrom  	+= 	RetSqlName("RHC")+ " RHC%"
	cWhere 		:="%RCO_CODIGO=RHD_CODRPA"
	cWhere 		+=" AND RA_MAT=RHD_MAT"
	cWhere 		+=" AND RA_FILIAL=RHD_FILIAL"
	cWhere 		+=" AND RHD_FILIAL=RHC_FILIAL"
	cWhere 		+=" AND RHC_MAT=RHD_MAT"
	cWhere 		+=" AND RHC_ANOMES=RHD_ANOMES"
   	cWhere 		+=" AND RHD_CODRPA ='" + cRegP + "'"  //Registro Patronal 
   	cWhere 		+=" AND RHC_ANOMES ='" + cAnioMes + "'" // Año Mes
	cWhere 		+=" AND RHC_FILIAL  ='"+ cFilRHC  + "'"
	cWhere 		+="	AND RA_FILIAL  ='" + cFilSRA  + "'"
	cWhere 		+="	AND RHD_FILIAL  ='"+ cFilRHD  + "'"
	cWhere 		+=" AND RCO_FILIAL= '" + xFilial("RCO" , cFilRHD) +"' "
	cWhere 		+="	AND RHC_CFPAT <> 0"
	cWhere		+=" AND RHD.D_E_L_E_T_  = ' ' " 		
	cWhere		+=" AND SRA.D_E_L_E_T_  = ' ' " 						
	cWhere		+=" AND RHC.D_E_L_E_T_  = ' '%"
	cOrdem 		:="%RHC_MAT,RHC_SEQMVT%"
	
	BeginSql alias cAliasRHC 
		SELECT	%exp:cCposQuery%
		FROM	%exp:cCposFrom% 
		WHERE	%exp:cWhere%  
		ORDER BY %exp:cOrdem%
	EndSql
TCSetField(cAliasRHC,"RHC_DTMOV","D")  
DbSelectArea( cAliasRHC )
Count to nTotal
oReport:SetMeter(nTotal)	
(cAliasRHC)->(DbGoTop())
If (cAliasRHC)->(!Eof())
	lRet := .T.
EndIF

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GPR023ISC³ Autor ³ Alfredo Medrano       ³ Data ³14/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³imprime los movimientos de IMSS que no tuvieron             ³±±
±±³          ³coincidencia con la tabla RHC                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPR023ISC(oExpO1,ocExpO2,ocExpO3)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExpO1 :  objeto de la Celda                               ³±±
±±³          ³ oExpO2 :  objeto de la Celda                          	  ³±±
±±³          ³ oExpO3 :  objeto de la Celda                          	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function GPR023ISC(oSection4,oSection5,oSection6)
Local 	 aArea	  := getArea() 

oSection4:Init() // Personal No procesado
oSection5:Init() // Detalle No procesado
oSection6:init() // mensaje de Registros no procesados
GP23MXINC(NIL,NIL, oSection4,oSection5)
(cTMSUAMEN)->(DbGoTop())
If (cTMSUAMEN)->(!Eof())
	oSection6:Cell("NOPROS"):SetValue(OemToAnsi(STR0048)) //"Registros existentes en el archivo del IMSS que no se encontraron en Protheus"	
	oSection6:PrintLine()
	oSection6:Finish()
EndIF

While (cTMSUAMEN)->(!Eof())	
//Activa o visualiza los valores del detalle
GP23MXSHW(Nil,oSection5)
	If (cTMSUAMEN)->TM_LEIDO != "S"
		//Busca e Imprime Datos de Personal IMSS (TP)
		If (cTPSUAMEN)->(DbSeek((cTMSUAMEN)->TM_MAT))						//TP_MAT		
			oSection4:Cell("TIT_PROV"):SetValue("IMSS")						//--- Proviene de  Protheus/Imss
			oSection4:Cell("RA_MAT"):SetValue((cTPSUAMEN)->TP_MAT		)  	//--- Matricula 
			oSection4:Cell("RA_NOME"):SetValue((cTPSUAMEN)->TP_NOMBRE	) 	//--- Nombre del empleado
			oSection4:Cell("RA_RG"):SetValue((cTPSUAMEN)->TP_NSS		) 	//--- Numero SS
			oSection4:Cell("RA_CURP"):SetValue((cTPSUAMEN)->TP_CURP		)	//--- Curp
			
			oSection4:Cell("AST_RG"):SetValue("") 	//--- Numero SS
			oSection4:Cell("AST_NOME"):SetValue("")	//--- Nombre del empleado
			oSection4:Cell("AST_CURP"):SetValue("") 	//--- Curp
			oSection4:PrintLine()	  
		EndIf 
			
			oSection5:Cell("PROVIENE"):SetValue("IMSS")						 //--- Proviene Imss
		   	oSection5:Cell("RHC_MAT"):SetValue(ALLTRIM((cTMSUAMEN)->TM_MAT) )//--- Matricula
			oSection5:Cell("RHC_TPMOV"):SetValue((cTMSUAMEN)->TM_TPMOV		)//--- TM
			oSection5:Cell("RHC_DTMOV"):SetValue(DTOC((cTMSUAMEN)->TM_DTMOV))//--- Fecha
			oSection5:Cell("RHC_NDTRAB"):SetValue((cTMSUAMEN)->TM_NDTRAB	)//--- Dias
			oSection5:Cell("RHC_SALDII"):SetValue((cTMSUAMEN)->TM_SALDII	)//--- SDI
			oSection5:Cell("RHC_CFPAT"):SetValue((cTMSUAMEN)->TM_CFPAT		)//--- CF	
			oSection5:Cell("RHC_EXEPAT"):SetValue((cTMSUAMEN)->TM_EXEPAT	)//--- Dias Enf. y mat exc. Patron
			oSection5:Cell("RHC_EXETRA"):SetValue((cTMSUAMEN)->TM_EXETRA	)//--- Dias Enf. y mat exc. trabjador
			oSection5:Cell("RHC_PDPAT"):SetValue((cTMSUAMEN)->TM_PDPAT 		)//--- PD Patron
			oSection5:Cell("RHC_PDTRA"):SetValue((cTMSUAMEN)->TM_PDTRA 		)//--- PD Trabajador
			oSection5:Cell("RHC_GMPPAT"):SetValue((cTMSUAMEN)->TM_GMPPAT	)//--- GMP Patron
			oSection5:Cell("RHC_GMPTRA"):SetValue((cTMSUAMEN)->TM_GMPTRA	)//--- GMP Trabajador
			oSection5:Cell("RHC_RTPAT"):SetValue((cTMSUAMEN)->TM_RTPAT 		)//--- RT Patron
			oSection5:Cell("RHC_IVPAT"):SetValue((cTMSUAMEN)->TM_IVPAT 		)//--- IV Patron
			oSection5:Cell("RHC_IVTRA"):SetValue((cTMSUAMEN)->TM_IVTRA 		)//--- IV Trabajador
			oSection5:Cell("RHC_GPSPAT"):SetValue((cTMSUAMEN)->TM_GPSPAT 	)//--- GPS Patron
			oSection5:Cell("TOTAL"):SetValue((cTMSUAMEN)->TM_GPSPAT + (cTMSUAMEN)->TM_IVTRA)	
			
			oSection5:Cell("AST_MAT"):SetValue("")		//--- Matricula
			oSection5:Cell("AST_TPMOV"):SetValue("")	//--- TM
			oSection5:Cell("AST_DTMOV"):SetValue("")	//--- Fecha
			oSection5:Cell("AST_NDTRAB"):SetValue("")	//--- Dias
			oSection5:Cell("AST_SALDII"):SetValue("")	//--- SDI
			oSection5:Cell("AST_CFPAT"):SetValue("")	//--- CF	
			oSection5:Cell("AST_EXEPAT"):SetValue("")	//--- Dias Enf. y mat exc. Patron
			oSection5:Cell("AST_EXETRA"):SetValue("")	//--- Dias Enf. y mat exc. trabjador
			oSection5:Cell("AST_PDPAT"):SetValue("")	//--- PD Patron
			oSection5:Cell("AST_PDTRA"):SetValue("")	//--- PD Trabajador
			oSection5:Cell("AST_GMPPAT"):SetValue("")	//--- GMP Patron
			oSection5:Cell("AST_GMPTRA"):SetValue("")	//--- GMP Trabajador
			oSection5:Cell("AST_RTPAT"):SetValue("")	//--- RT Patron
			oSection5:Cell("AST_IVPAT"):SetValue("")	//--- IV Patron
			oSection5:Cell("AST_IVTRA"):SetValue("")	//--- IV Trabajador
			oSection5:Cell("AST_GPSPAT"):SetValue("")	//--- GPS Patron						
			oSection5:PrintLine()											
		EndIf
		(cTMSUAMEN)->(dbskip())
	EndDo
oSection4:Finish()
oSection5:Finish()
restArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GP23MXINC³ Autor ³ Alfredo Medrano       ³ Data ³16/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa el reporte con una línea vacía                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP23MXINC(oExpO1,ocExpO2,ocExpO3,ocExpO4,ocExpO5)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExpO1 :  objeto de la Celda                               ³±±
±±³          ³ oExpO2 :  objeto de la Celda                          	  ³±±
±±³          ³ oExpO3 :  objeto de la Celda                          	  ³±±
±±³          ³ oExpO4 :  objeto de la Celda                          	  ³±±
±±³          ³ oExpO5 :  objeto de la Celda                          	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function GP23MXINC(oSection2,oSection3,oSection4,oSection5)


If !Empty(oSection2)
	oSection2:Cell("TIT_PROV"):SetValue("")	//--- Proviene de  Protheus
	oSection2:Cell("RA_RG"):SetValue("") 	//--- Numero SS
	oSection2:Cell("RA_NOME"):SetValue("")	//--- Nombre del empleado
	oSection2:Cell("RA_MAT"):SetValue("")  	//--- Matricula 
	oSection2:Cell("RA_CURP"):SetValue("") 	//--- Curp
		
	oSection2:Cell("AST_RG"):SetValue("") 	//--- Numero SS
	oSection2:Cell("AST_NOME"):SetValue("")	//--- Nombre del empleado
	oSection2:Cell("AST_CURP"):SetValue("") 	//--- Curp
	oSection2:PrintLine()
EndIf
If !Empty(oSection4)
	oSection4:Cell("TIT_PROV"):SetValue("")	//--- Proviene de  Protheus
	oSection4:Cell("RA_RG"):SetValue("") 	//--- Numero SS
	oSection4:Cell("RA_NOME"):SetValue("")	//--- Nombre del empleado
	oSection4:Cell("RA_MAT"):SetValue("")  	//--- Matricula 
	oSection4:Cell("RA_CURP"):SetValue("") 	//--- Curp
	
	oSection4:Cell("AST_RG"):SetValue("") 	//--- Numero SS
	oSection4:Cell("AST_NOME"):SetValue("")	//--- Nombre del empleado
	oSection4:Cell("AST_CURP"):SetValue("") 	//--- Curp
	oSection4:PrintLine()
EndIf

If !Empty(oSection3)
		
	oSection3:Cell("PROVIENE"):SetValue("")			//--- Proviene Protheus
	oSection3:Cell("RHC_MAT"):SetValue("")			//--- Matricula 
	oSection3:Cell("RHC_TPMOV"):SetValue("")		//--- TM
	oSection3:Cell("RHC_DTMOV"):SetValue("")		//--- Fecha
	oSection3:Cell("RHC_NDTRAB"):SetValue("")		//--- Dias
	oSection3:Cell("RHC_SALDII"):SetValue("")		//--- SDI
	oSection3:Cell("RHC_CFPAT"):SetValue("")		//--- CF	
	oSection3:Cell("RHC_EXEPAT"):SetValue("")		//--- Dias Enf. y mat exc. Patron
	oSection3:Cell("RHC_EXETRA"):SetValue("")		//--- Dias Enf. y mat exc. trabjador
	oSection3:Cell("RHC_PDPAT"):SetValue("")		//--- PD Patron
	oSection3:Cell("RHC_PDTRA"):SetValue("")		//--- PD Trabajador
	oSection3:Cell("RHC_GMPPAT"):SetValue("")		//--- GMP Patron
	oSection3:Cell("RHC_GMPTRA"):SetValue("")		//--- GMP Trabajador
	oSection3:Cell("RHC_RTPAT"):SetValue("")		//--- RT Patron
	oSection3:Cell("RHC_IVPAT"):SetValue("")		//--- IV Patron
	oSection3:Cell("RHC_IVTRA"):SetValue("")		//--- IV Trabajador
	oSection3:Cell("RHC_GPSPAT"):SetValue("")		//--- GPS Patron
	oSection3:Cell("TOTAL"):SetValue("")			//--- Total

	oSection3:Cell("AST_MAT"):SetValue("")			//--- Matricula
	oSection3:Cell("AST_TPMOV"):SetValue("")		//--- TM
	oSection3:Cell("AST_DTMOV"):SetValue("")		//--- Fecha
	oSection3:Cell("AST_NDTRAB"):SetValue("")		//--- Dias
	oSection3:Cell("AST_SALDII"):SetValue("")		//--- SDI
	oSection3:Cell("AST_CFPAT"):SetValue("")		//--- CF	
	oSection3:Cell("AST_EXEPAT"):SetValue("")		//--- Dias Enf. y mat exc. Patron
	oSection3:Cell("AST_EXETRA"):SetValue("")		//--- Dias Enf. y mat exc. trabjador
	oSection3:Cell("AST_PDPAT"):SetValue("")		//--- PD Patron
	oSection3:Cell("AST_PDTRA"):SetValue("")		//--- PD Trabajador
	oSection3:Cell("AST_GMPPAT"):SetValue("")		//--- GMP Patron
	oSection3:Cell("AST_GMPTRA"):SetValue("")		//--- GMP Trabajador
	oSection3:Cell("AST_RTPAT"):SetValue("")		//--- RT Patron
	oSection3:Cell("AST_IVPAT"):SetValue("")		//--- IV Patron
	oSection3:Cell("AST_IVTRA"):SetValue("")		//--- IV Trabajador
	oSection3:Cell("AST_GPSPAT"):SetValue("")		//--- GPS Patron	

	oSection3:Cell("PROVIENE"):hide()		//--- Proviene Protheus
	oSection3:Cell("RHC_MAT"):hide()		//--- Matricula 
	oSection3:Cell("RHC_TPMOV"):hide()		//--- TM
	oSection3:Cell("RHC_DTMOV"):Hide()		//--- Fecha
	oSection3:Cell("RHC_NDTRAB"):Hide()		//--- Dias
	oSection3:Cell("RHC_SALDII"):Hide()		//--- SDI
	oSection3:Cell("RHC_CFPAT"):Hide()		//--- CF	
	oSection3:Cell("RHC_EXEPAT"):Hide()		//--- Dias Enf. y mat exc. Patron
	oSection3:Cell("RHC_EXETRA"):Hide()		//--- Dias Enf. y mat exc. trabjador
	oSection3:Cell("RHC_PDPAT"):Hide()		//--- PD Patron
	oSection3:Cell("RHC_PDTRA"):Hide()		//--- PD Trabajador
	oSection3:Cell("RHC_GMPPAT"):Hide()		//--- GMP Patron
	oSection3:Cell("RHC_GMPTRA"):Hide()		//--- GMP Trabajador
	oSection3:Cell("RHC_RTPAT"):Hide()		//--- RT Patron
	oSection3:Cell("RHC_IVPAT"):Hide()		//--- IV Patron
	oSection3:Cell("RHC_IVTRA"):Hide()		//--- IV Trabajador
	oSection3:Cell("RHC_GPSPAT"):Hide()		//--- GPS Patron
	oSection3:Cell("TOTAL"):Hide()			//--- Total

	oSection3:Cell("AST_MAT"):Hide()		//--- Matricula
	oSection3:Cell("AST_TPMOV"):Hide()		//--- TM
	oSection3:Cell("AST_DTMOV"):Hide()		//--- Fecha
	oSection3:Cell("AST_NDTRAB"):Hide()		//--- Dias
	oSection3:Cell("AST_SALDII"):Hide()		//--- SDI
	oSection3:Cell("AST_CFPAT"):Hide()		//--- CF	
	oSection3:Cell("AST_EXEPAT"):Hide()		//--- Dias Enf. y mat exc. Patron
	oSection3:Cell("AST_EXETRA"):Hide()		//--- Dias Enf. y mat exc. trabjador
	oSection3:Cell("AST_PDPAT"):Hide()		//--- PD Patron
	oSection3:Cell("AST_PDTRA"):Hide()		//--- PD Trabajador
	oSection3:Cell("AST_GMPPAT"):Hide()		//--- GMP Patron
	oSection3:Cell("AST_GMPTRA"):Hide()		//--- GMP Trabajador
	oSection3:Cell("AST_RTPAT"):Hide()		//--- RT Patron
	oSection3:Cell("AST_IVPAT"):Hide()		//--- IV Patron
	oSection3:Cell("AST_IVTRA"):Hide()		//--- IV Trabajador
	oSection3:Cell("AST_GPSPAT"):Hide()		//--- GPS Patron	
	
	oSection3:PrintLine()
EndIf

If !Empty(oSection5)		
	oSection5:Cell("PROVIENE"):SetValue("")			//--- Proviene Protheus
	oSection5:Cell("RHC_MAT"):SetValue("")			//--- Matricula 
	oSection5:Cell("RHC_TPMOV"):SetValue("")		//--- TM
	oSection5:Cell("RHC_DTMOV"):SetValue("")		//--- Fecha
	oSection5:Cell("RHC_NDTRAB"):SetValue("")		//--- Dias
	oSection5:Cell("RHC_SALDII"):SetValue("")		//--- SDI
	oSection5:Cell("RHC_CFPAT"):SetValue("")		//--- CF	
	oSection5:Cell("RHC_EXEPAT"):SetValue("")		//--- Dias Enf. y mat exc. Patron
	oSection5:Cell("RHC_EXETRA"):SetValue("")		//--- Dias Enf. y mat exc. trabjador
	oSection5:Cell("RHC_PDPAT"):SetValue("")		//--- PD Patron
	oSection5:Cell("RHC_PDTRA"):SetValue("")		//--- PD Trabajador
	oSection5:Cell("RHC_GMPPAT"):SetValue("")		//--- GMP Patron
	oSection5:Cell("RHC_GMPTRA"):SetValue("")		//--- GMP Trabajador
	oSection5:Cell("RHC_RTPAT"):SetValue("")		//--- RT Patron
	oSection5:Cell("RHC_IVPAT"):SetValue("")		//--- IV Patron
	oSection5:Cell("RHC_IVTRA"):SetValue("")		//--- IV Trabajador
	oSection5:Cell("RHC_GPSPAT"):SetValue("")		//--- GPS Patron
	oSection5:Cell("TOTAL"):SetValue("")			//--- Total

	oSection5:Cell("AST_MAT"):SetValue("")			//--- Matricula
	oSection5:Cell("AST_TPMOV"):SetValue("")		//--- TM
	oSection5:Cell("AST_DTMOV"):SetValue("")		//--- Fecha
	oSection5:Cell("AST_NDTRAB"):SetValue("")		//--- Dias
	oSection5:Cell("AST_SALDII"):SetValue("")		//--- SDI
	oSection5:Cell("AST_CFPAT"):SetValue("")		//--- CF	
	oSection5:Cell("AST_EXEPAT"):SetValue("")		//--- Dias Enf. y mat exc. Patron
	oSection5:Cell("AST_EXETRA"):SetValue("")		//--- Dias Enf. y mat exc. trabjador
	oSection5:Cell("AST_PDPAT"):SetValue("")		//--- PD Patron
	oSection5:Cell("AST_PDTRA"):SetValue("")		//--- PD Trabajador
	oSection5:Cell("AST_GMPPAT"):SetValue("")		//--- GMP Patron
	oSection5:Cell("AST_GMPTRA"):SetValue("")		//--- GMP Trabajador
	oSection5:Cell("AST_RTPAT"):SetValue("")		//--- RT Patron
	oSection5:Cell("AST_IVPAT"):SetValue("")		//--- IV Patron
	oSection5:Cell("AST_IVTRA"):SetValue("")		//--- IV Trabajador
	oSection5:Cell("AST_GPSPAT"):SetValue("")		//--- GPS Patron	
	
	oSection5:Cell("PROVIENE"):hide()		//--- Proviene Protheus
	oSection5:Cell("RHC_MAT"):hide()		//--- Matricula 
	oSection5:Cell("RHC_TPMOV"):hide()		//--- TM
	oSection5:Cell("RHC_DTMOV"):Hide()		//--- Fecha
	oSection5:Cell("RHC_NDTRAB"):Hide()		//--- Dias
	oSection5:Cell("RHC_SALDII"):Hide()		//--- SDI
	oSection5:Cell("RHC_CFPAT"):Hide()		//--- CF	
	oSection5:Cell("RHC_EXEPAT"):Hide()		//--- Dias Enf. y mat exc. Patron
	oSection5:Cell("RHC_EXETRA"):Hide()		//--- Dias Enf. y mat exc. trabjador
	oSection5:Cell("RHC_PDPAT"):Hide()		//--- PD Patron
	oSection5:Cell("RHC_PDTRA"):Hide()		//--- PD Trabajador
	oSection5:Cell("RHC_GMPPAT"):Hide()		//--- GMP Patron
	oSection5:Cell("RHC_GMPTRA"):Hide()		//--- GMP Trabajador
	oSection5:Cell("RHC_RTPAT"):Hide()		//--- RT Patron
	oSection5:Cell("RHC_IVPAT"):Hide()		//--- IV Patron
	oSection5:Cell("RHC_IVTRA"):Hide()		//--- IV Trabajador
	oSection5:Cell("RHC_GPSPAT"):Hide()		//--- GPS Patron
	oSection5:Cell("TOTAL"):Hide()			//--- Total

	oSection5:Cell("AST_MAT"):Hide()		//--- Matricula
	oSection5:Cell("AST_TPMOV"):Hide()		//--- TM
	oSection5:Cell("AST_DTMOV"):Hide()		//--- Fecha
	oSection5:Cell("AST_NDTRAB"):Hide()		//--- Dias
	oSection5:Cell("AST_SALDII"):Hide()		//--- SDI
	oSection5:Cell("AST_CFPAT"):Hide()		//--- CF	
	oSection5:Cell("AST_EXEPAT"):Hide()		//--- Dias Enf. y mat exc. Patron
	oSection5:Cell("AST_EXETRA"):Hide()		//--- Dias Enf. y mat exc. trabjador
	oSection5:Cell("AST_PDPAT"):Hide()		//--- PD Patron
	oSection5:Cell("AST_PDTRA"):Hide()		//--- PD Trabajador
	oSection5:Cell("AST_GMPPAT"):Hide()		//--- GMP Patron
	oSection5:Cell("AST_GMPTRA"):Hide()		//--- GMP Trabajador
	oSection5:Cell("AST_RTPAT"):Hide()		//--- RT Patron
	oSection5:Cell("AST_IVPAT"):Hide()		//--- IV Patron
	oSection5:Cell("AST_IVTRA"):Hide()		//--- IV Trabajador
	oSection5:Cell("AST_GPSPAT"):Hide()		//--- GPS Patron	
	
	oSection5:PrintLine()
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GP23MXSHW³ Autor ³ Alfredo Medrano       ³ Data ³16/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Activa o visualiza los valores del detalle                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP23MXSHW(oExpO1,ocExpO2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExpO1 :  objeto de la Celda                               ³±±
±±³          ³ oExpO2 :  objeto de la Celda                          	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GP23MXSHW(oSection3,oSection5)

If !Empty(oSection3)
	oSection3:Cell("PROVIENE"):Show()		//--- Proviene Protheus
	oSection3:Cell("RHC_MAT"):Show()		//--- Matricula 
	oSection3:Cell("RHC_TPMOV"):Show()		//--- TM
	oSection3:Cell("RHC_DTMOV"):Show()		//--- Fecha
	oSection3:Cell("RHC_NDTRAB"):Show()		//--- Dias
	oSection3:Cell("RHC_SALDII"):Show()		//--- SDI
	oSection3:Cell("RHC_CFPAT"):Show()		//--- CF	
	oSection3:Cell("RHC_EXEPAT"):Show()		//--- Dias Enf. y mat exc. Patron
	oSection3:Cell("RHC_EXETRA"):Show()		//--- Dias Enf. y mat exc. trabjador
	oSection3:Cell("RHC_PDPAT"):Show()		//--- PD Patron
	oSection3:Cell("RHC_PDTRA"):Show()		//--- PD Trabajador
	oSection3:Cell("RHC_GMPPAT"):Show()		//--- GMP Patron
	oSection3:Cell("RHC_GMPTRA"):Show()		//--- GMP Trabajador
	oSection3:Cell("RHC_RTPAT"):Show()		//--- RT Patron
	oSection3:Cell("RHC_IVPAT"):Show()		//--- IV Patron
	oSection3:Cell("RHC_IVTRA"):Show()		//--- IV Trabajador
	oSection3:Cell("RHC_GPSPAT"):Show()		//--- GPS Patron
	oSection3:Cell("TOTAL"):Show()			//--- Total

	oSection3:Cell("AST_MAT"):Show()		//--- Matricula
	oSection3:Cell("AST_TPMOV"):Show()		//--- TM
	oSection3:Cell("AST_DTMOV"):Show()		//--- Fecha
	oSection3:Cell("AST_NDTRAB"):Show()		//--- Dias
	oSection3:Cell("AST_SALDII"):Show()		//--- SDI
	oSection3:Cell("AST_CFPAT"):Show()		//--- CF	
	oSection3:Cell("AST_EXEPAT"):Show()		//--- Dias Enf. y mat exc. Patron
	oSection3:Cell("AST_EXETRA"):Show()		//--- Dias Enf. y mat exc. trabjador
	oSection3:Cell("AST_PDPAT"):Show()		//--- PD Patron
	oSection3:Cell("AST_PDTRA"):Show()		//--- PD Trabajador
	oSection3:Cell("AST_GMPPAT"):Show()		//--- GMP Patron
	oSection3:Cell("AST_GMPTRA"):Show()		//--- GMP Trabajador
	oSection3:Cell("AST_RTPAT"):Show()		//--- RT Patron
	oSection3:Cell("AST_IVPAT"):Show()		//--- IV Patron
	oSection3:Cell("AST_IVTRA"):Show()		//--- IV Trabajador
	oSection3:Cell("AST_GPSPAT"):Show()		//--- GPS Patron	
EndIf

If !Empty(oSection5)
	oSection5:Cell("PROVIENE"):Show()		//--- Proviene Protheus
	oSection5:Cell("RHC_MAT"):Show()		//--- Matricula 
	oSection5:Cell("RHC_TPMOV"):Show()		//--- TM
	oSection5:Cell("RHC_DTMOV"):Show()		//--- Fecha
	oSection5:Cell("RHC_NDTRAB"):Show()		//--- Dias
	oSection5:Cell("RHC_SALDII"):Show()		//--- SDI
	oSection5:Cell("RHC_CFPAT"):Show()		//--- CF	
	oSection5:Cell("RHC_EXEPAT"):Show()		//--- Dias Enf. y mat exc. Patron
	oSection5:Cell("RHC_EXETRA"):Show()		//--- Dias Enf. y mat exc. trabjador
	oSection5:Cell("RHC_PDPAT"):Show()		//--- PD Patron
	oSection5:Cell("RHC_PDTRA"):Show()		//--- PD Trabajador
	oSection5:Cell("RHC_GMPPAT"):Show()		//--- GMP Patron
	oSection5:Cell("RHC_GMPTRA"):Show()		//--- GMP Trabajador
	oSection5:Cell("RHC_RTPAT"):Show()		//--- RT Patron
	oSection5:Cell("RHC_IVPAT"):Show()		//--- IV Patron
	oSection5:Cell("RHC_IVTRA"):Show()		//--- IV Trabajador
	oSection5:Cell("RHC_GPSPAT"):Show()		//--- GPS Patron
	oSection5:Cell("TOTAL"):Show()			//--- Total

	oSection5:Cell("AST_MAT"):Show()		//--- Matricula
	oSection5:Cell("AST_TPMOV"):Show()		//--- TM
	oSection5:Cell("AST_DTMOV"):Show()		//--- Fecha
	oSection5:Cell("AST_NDTRAB"):Show()		//--- Dias
	oSection5:Cell("AST_SALDII"):Show()		//--- SDI
	oSection5:Cell("AST_CFPAT"):Show()		//--- CF	
	oSection5:Cell("AST_EXEPAT"):Show()		//--- Dias Enf. y mat exc. Patron
	oSection5:Cell("AST_EXETRA"):Show()		//--- Dias Enf. y mat exc. trabjador
	oSection5:Cell("AST_PDPAT"):Show()		//--- PD Patron
	oSection5:Cell("AST_PDTRA"):Show()		//--- PD Trabajador
	oSection5:Cell("AST_GMPPAT"):Show()		//--- GMP Patron
	oSection5:Cell("AST_GMPTRA"):Show()		//--- GMP Trabajador
	oSection5:Cell("AST_RTPAT"):Show()		//--- RT Patron
	oSection5:Cell("AST_IVPAT"):Show()		//--- IV Patron
	oSection5:Cell("AST_IVTRA"):Show()		//--- IV Trabajador
	oSection5:Cell("AST_GPSPAT"):Show()		//--- GPS Patron	
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³GP23MXTBL  ³ Autor ³ Alfredo Medrano      ³ Data ³09/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Crea la tablas temporales TM y TP                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GP23MXTBL(   )                                              ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER023MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function GP23MXTBL()

Local lRet 		:= .t.
Local nNomb		:= 0
Local aTblTM 	:= {}
Local aTblTP 	:= {}	
Local aRaRg		:= {}
Local aRpat		:= {}
Local aMat		:= {}
Local aTpMv		:= {}
Local aDtMv		:= {}
Local aNdtrab	:= {}
Local aSaldii	:= {}
Local aCfpat	:= {}
Local aExept	:= {}
Local aExetr	:= {}
Local aPdPat	:= {}
Local aPdTra	:= {}
Local aGmpPt	:= {}
Local aGmptr	:= {}
Local aRtpat	:= {}
Local aIvPat	:= {}
Local aIvTra	:= {}
Local aGpsPt	:= {}
Local aNomb		:= {}
Local aCurp		:= {}
Private oTmpT1
Private oTmpT2

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Obtiene Caracteristicas del campo 			³
³TAMSX3(Campo)[1] = Tamaño 	-- Numerico		³
³TAMSX3(Campo)[2] = Decimal -- Numerico     ³ 
³TAMSX3(Campo)[3] = Tipo    -- Caracter     ³    
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aRaRg	:= TAMSX3('RA_RG') 
	aRpat	:= TAMSX3('RCO_NREPAT')
	aMat	:= TAMSX3('RHC_MAT')
	aTpMv	:= TAMSX3('RHC_TPMOV')
	aDtMv	:= TAMSX3('RHC_DTMOV')
	aNdtrab := TAMSX3('RHC_NDTRAB')
	aSaldii	:= TAMSX3('RHC_SALDII')
	aCfpat	:= TAMSX3('RHC_CFPAT')
	aExept	:= TAMSX3('RHC_EXEPAT')
	aExetr	:= TAMSX3('RHC_EXETRA') 
	aPdPat	:= TAMSX3('RHC_PDPAT') 
	aPdTra	:= TAMSX3('RHC_PDTRA') 
	aGmpPt	:= TAMSX3('RHC_GMPPAT') 
	aGmptr	:= TAMSX3('RHC_GMPTRA') 
	aRtpat	:= TAMSX3('RHC_RTPAT')
	aIvPat	:= TAMSX3('RHC_IVPAT')
	aIvTra	:= TAMSX3('RHC_IVTRA')
	aGpsPt	:= TAMSX3('RHC_GPSPAT')
	
	AADD(aTblTM, {"TM_NSS"   ,aRaRg[3]	,aRaRg[1] 	,aRaRg[2]	} ) 
	AADD(aTblTM, {"TM_RPAT"  ,aRpat[3]	,aRpat[1]	,aRpat[2]	} )
	AADD(aTblTM, {"TM_MAT"   ,aMat[3]	,aMat[1] 	,aMat[2]	} )
	AADD(aTblTM, {"TM_TPMOV" ,aTpMv[3]	,aTpMv[1] 	,aTpMv[2]	} )
	AADD(aTblTM, {"TM_DTMOV" ,aDtMv[3]	,aDtMv[1] 	,aDtMv[2]	} )
	AADD(aTblTM, {"TM_NDTRAB",aNdtrab[3],aNdtrab[1] ,aNdtrab[2]	} )
	AADD(aTblTM, {"TM_SALDII",aSaldii[3],aSaldii[1]	,aSaldii[2]	} )
	AADD(aTblTM, {"TM_CFPAT" ,aCfpat[3]	,aCfpat[1]	,aCfpat[2]	} ) 
	AADD(aTblTM, {"TM_EXEPAT",aExept[3]	,aExept[1]	,aExept[2]	} )
	AADD(aTblTM, {"TM_EXETRA",aExetr[3]	,aExetr[1]	,aExetr[2]	} )
	AADD(aTblTM, {"TM_PDPAT" ,aPdPat[3]	,aPdPat[1]	,aPdPat[2]	} )
	AADD(aTblTM, {"TM_PDTRA" ,aPdTra[3]	,aPdTra[1]	,aPdTra[2]	} )
	AADD(aTblTM, {"TM_GMPPAT",aGmpPt[3]	,aGmpPt[1]	,aGmpPt[2]	} )
	AADD(aTblTM, {"TM_GMPTRA",aGmptr[3]	,aGmptr[1]	,aGmptr[2]	} )
	AADD(aTblTM, {"TM_RTPAT" ,aRtpat[3]	,aRtpat[1]	,aRtpat[2]	} )
	AADD(aTblTM, {"TM_IVPAT" ,aIvPat[3]	,aIvPat[1]	,aIvPat[2]	} )
	AADD(aTblTM, {"TM_IVTRA" ,aIvTra[3]	,aIvTra[1]	,aIvTra[2]	} )
	AADD(aTblTM, {"TM_GPSPAT",aGpsPt[3]	,aGpsPt[1]	,aGpsPt[2]	} )
	AADD(aTblTM, {"TM_LEIDO", "C",1,0})
	//--- Crear tabla temporal TM
	
	
	If oTmpT1 <> Nil
		oTmpT1:Delete()
	EndIf
	
	oTmpT1 := FWTemporaryTable():New(cTMSUAMEN) 
	oTmpT1:SetFields( aTblTM ) 	
	oTmpT1:AddIndex("T1", {"TM_MAT","TM_DTMOV","TM_TPMOV"}) 
	oTmpT1:Create()
	
	//--- Arreglo para la tabla TP
	//Obtiene Caracteristicas del campo 
	aMat	:={}
	aMat	:= TAMSX3('RA_MAT')
	aNomb	:= TAMSX3('RA_PRINOME')
	nNomb	:= TAMSX3('RA_PRISOBR')[1]+TAMSX3('RA_SECSOBR')[1]+TAMSX3('RA_PRINOME')[1]+TAMSX3('RA_SECNOME')[1] + 4
	aCurp	:= TAMSX3('RA_CURP') 
	AADD(aTblTP, {"TP_NSS"   ,aRaRg[3]	,aRaRg[1] 	,aRaRg[2]	} ) 
	AADD(aTblTP, {"TP_MAT"   ,aMat[3]	,aMat[1] 	,aMat[2]	} )
	AADD(aTblTP, {"TP_NOMBRE",aNomb[3]	,nNomb		,aNomb[2]	} )
	AADD(aTblTP, {"TP_CURP"  ,aCurp[3]	,aCurp[1]	,aCurp[2]	} )

	//--- Crear tabla temporal TP
	If oTmpT2 <> Nil
		oTmpT2:Delete()
	EndIf
	
	oTmpT2 := FWTemporaryTable():New(cTPSUAMEN) 
	oTmpT2:SetFields( aTblTP ) 	
	oTmpT2:AddIndex("T1", {"TP_MAT"}) 
	oTmpT2:Create()
	
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ GP23MXLEE ³ Autor ³ Alfredo Medrano      ³ Data ³09/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Lee los archivos TXT CDEMM099 y CDEMAS99 y carga las tablas ³±±
±±³          ³temporales TPSUABIM y TMSUABIM                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GP23MXLEE(ExpC1,ExpC2,ExpA3)                                ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1  : Ruta donde esta el archivo CDEMMO99.TXT            ³±±
±±³          ³ExpC2  : Ruta donde esta el archivo CDEMAS99.TXT            ³±±
±±³          ³ExpA3  : Array con los Registros PAtronales                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1  : .t./.f. Carga de datos.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER023MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function GP23MXLEE(cArch1,cArch2,aRegPat)
Local	aArea 	:= GetArea()
Local lRet		:= .t.
Local cBuffer 	:= ""
Local cRgPt		:= ""
Local nx		:= 0
Local cCadRegP	:= ""
Local cTmpPer	:= CriaTrab(Nil,.F.)
Local nIndSRA	:= 0
Local cFilSRA	:= XFILIAL("SRA")


//Crea el Indice temporal
dbSelectArea("SRA")
IndRegua("SRA",cTmpPer,"RA_FILIAL+RA_RG",,"RA_FILIAL == '"+cFilSRA+"'",OemToAnsi(STR0047))
nIndSRA := RetIndex("SRA")// restaura los indices
nIndSRA++
DbSetOrder(nIndSRA)

For nx := 1 To Len(aRegPat)
	cCadRegP += ALLTRIM(aRegPat[nx]) + "|"
Next
cCadRegP:= substr(cCadRegP,1,len(cCadRegP)-1)

dbselectarea("RCO")
RCO ->(DBSETORDER(2))    // RCO_FILIAL+RCO_NREPAT

	FT_FUSE(cArch1)				//Abre Archivo
	FT_FGOTOP() 				//Mueve el Puntero al inicio del archivo para su la Lectura 
	ProcRegua(FT_FLASTREC()) 	//Número Total de Lineas
	While !FT_FEOF()			//--- Mientras no sea Fin de Archivo IncProc()
		IncProc()
		cBuffer := FT_FREADLN() 		//--- Guarda la linea
		cRgPt 	:= SubStr(cBuffer,1,10)	// obtiene Registro Patronal 
		//Valida que el registro patronal sea igual al solicitado  
		If 	RCO-> (Dbseek(XFILIAL('RCO')+cRgPt))
			If ALLTRIM(RCO->RCO_CODIGO) $ cCadRegP 	
				GP23MXRGP(cBuffer,cTMSUAMEN)	//Obtiene y guarda en la Tabla Temporal TM
			EndIf
		EndIf
		FT_FSKIP()	//próximo registro del txt
	EndDo
	FT_FUse() 		//cierra Archivo


	FT_FUSE(cArch2)				//Abre Archivo
	FT_FGOTOP() 				//Mueve el Puntero al inicio del archivo para su la Lectura
	ProcRegua(FT_FLASTREC()) 	//Número Total de Lineas	
	While !FT_FEOF()					//Mientras no sea Fin de Archivo IncProc()
		cBuffer := FT_FREADLN() 		//Guarda la linea
		cRgPt  := SubStr(cBuffer,1,10) // obtiene Registro Patronal
		//Valida que el registro patronal sea igual al solicitado  
		If 	RCO-> (Dbseek(XFILIAL('RCO')+cRgPt))	
			If  ALLTRIM(RCO->RCO_CODIGO) $ cCadRegP 
				GP23MXRGP(cBuffer,cTPSUAMEN) //Obtiene y guarda en la Tabla Temporal TP
			EndIF
		EndIf
		FT_FSKIP() //próximo registro del txt
	EndDo	
	FT_FUse() 		//cierra Archivo
RetIndex("SRA")
Ferase(cTmpPer+OrdBagext()) // Elimina el archivo en el cliente
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ GP23MXRGP ³ Autor ³Alfredo Medrano       ³Data  ³08/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Carga las tablas temporales TPSUABIM y TMSUABIM            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP23MXRGP(@ExpC1,@ExpC2)                                   ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Línea extraída del archivo TXT                    ³±±
±±³          ³ ExpC2  : Tabla temporal que cargara (TM o TP)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GP23MXLEE                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GP23MXRGP(cBuffer,cTmp)
Local aArea		:= GetArea()
Local aValores	:= {}
Local cNombre	:= ""
Local cCont		:= ""
Local cNSS		:= ""
Local cMat		:= ""
Local cTpMov	:= ""
Local cFechMv	:= ""
Local nDias		:= 0
Local nSaldii	:= 0
Local nCfpat	:= 0
Local nExpPat	:= 0
Local nExpTra	:= 0
Local nPdPat	:= 0
Local nPdTra	:= 0
Local nGmpPat	:= 0
Local nGmpTra	:= 0
Local nRtPat	:= 0
Local nIVPat	:= 0
Local nIVTra	:= 0
Local nGpsPat	:= 0
Local nI		:= 0
Local cRgPt		:= ""
Local cFilSRA	:= XFILIAL("SRA")
Default cBuffer:= ""
Default cTmp 	:= ""



//De la Linea extrae los caracteres según las posiciones especificadas
If cTmp==cTMSUAMEN .And. !Empty(cBuffer)
	DbSelectArea(cTMSUAMEN)
	cRgPt 	:= SubStr(cBuffer,1,10)// obtiene Registro Patronal 
	cNSS 	:= SubStr(cBuffer,24,11)

	If SRA->(dbSeek(cFilSRA+cNSS))
		cMat := SRA->RA_MAT
	Else
	   	cMat := ""
	EndIf
	
	cTpMov 	:= SubStr(cBuffer,36,1)
	cFechMV	:= SubStr(cBuffer,37,10)
	nDias	:= Val(SubStr(cBuffer,47,2))
	nSaldii	:= Val(SubStr(cBuffer,49,4)	+ "." + SubStr(cBuffer,53,2))
	nCfPat 	:= Val(SubStr(cBuffer,55,6)	+ "." + SubStr(cBuffer,61,2))
	nExpPat	:= Val(SubStr(cBuffer,63,6)	+ "." + SubStr(cBuffer,69,2))
	nExpTra	:= Val(SubStr(cBuffer,71,6)	+ "." + SubStr(cBuffer,77,2))
	nPdPat 	:= Val(SubStr(cBuffer,79,6)	+ "." + SubStr(cBuffer,85,2))
   	nPdTra 	:= Val(SubStr(cBuffer,87,6)	+ "." + SubStr(cBuffer,93,2))
   	nGmpPat	:= Val(SubStr(cBuffer,95,6)	+ "." + SubStr(cBuffer,101,2))
   	nGmpTra	:= Val(SubStr(cBuffer,103,6)+ "." + SubStr(cBuffer,109,2))
   	nRtPat 	:= Val(SubStr(cBuffer,111,6)+ "." + SubStr(cBuffer,117,2))
   	nIVPat 	:= Val(SubStr(cBuffer,119,6)+ "." + SubStr(cBuffer,125,2))
   	nIVTra 	:= Val(SubStr(cBuffer,127,6)+ "." + SubStr(cBuffer,133,2))
   	nGpsPat	:= Val(SubStr(cBuffer,135,6)+ "." + SubStr(cBuffer,141,2))		
		
	///--- Guarda datos en la tabla TM
	RECLOCK(cTMSUAMEN,.T.)		  				
	(cTMSUAMEN)->TM_NSS 	:= cNSS
	(cTMSUAMEN)->TM_MAT 	:= cMat
	(cTMSUAMEN)->TM_RPAT 	:= cRgPt  
	(cTMSUAMEN)->TM_TPMOV  	:= cTpMov
	(cTMSUAMEN)->TM_DTMOV  	:= CtoD(cFechMv)
	(cTMSUAMEN)->TM_NDTRAB 	:= nDias
	(cTMSUAMEN)->TM_SALDII 	:= nSaldii
	(cTMSUAMEN)->TM_CFPAT  	:= nCfPat
	(cTMSUAMEN)->TM_EXEPAT 	:= nExpPat
	(cTMSUAMEN)->TM_EXETRA 	:= nExpTra
	(cTMSUAMEN)->TM_PDPAT  	:= nPdPat
	(cTMSUAMEN)->TM_PDTRA  	:= nPdTra
	(cTMSUAMEN)->TM_GMPPAT 	:= nGmpPat
	(cTMSUAMEN)->TM_GMPTRA 	:= nGmpTra
	(cTMSUAMEN)->TM_RTPAT  	:= nRtPat
	(cTMSUAMEN)->TM_IVPAT  	:= nIVPat
	(cTMSUAMEN)->TM_IVTRA  	:= nIVTra
	(cTMSUAMEN)->TM_GPSPAT 	:= nGpsPat
	(cTMSUAMEN)->TM_LEIDO	:= "N"
	(cTMSUAMEN)->(MSUNLOCK())
	
ElseIf cTmp==cTPSUAMEN .And. !Empty(cBuffer)
	DbSelectArea(cTPSUAMEN)
	cNSS := SubStr(cBuffer,24,11)
	cCont := SubStr(cBuffer,89,18)
	If SRA->(dbSeek(cFilSRA+cNSS))
		cMat	:= SRA->RA_MAT
	Else
	   	cMat := ""
	EndIf

	cNombre := SubStr(cBuffer,35,50)
	//sustituye el símbolo $ por espacio
	aValores:=separa(cNombre,"$")
	cNombre := ""
	For nI := 1 to Len(aValores)
		cNombre += aValores[ni]+" "		
	Next nI
		
	RECLOCK(cTPSUAMEN,.T.)		  				
	(cTPSUAMEN)->TP_NSS 		:= cNSS
	(cTPSUAMEN)->TP_MAT 		:= cMat
	(cTPSUAMEN)->TP_NOMBRE  	:= cNombre
	(cTPSUAMEN)->TP_CURP 		:= cCont
	(cTPSUAMEN)->(MSUNLOCK())		

EndIf
RestArea(aArea)
Return .T.

