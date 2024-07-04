#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "GPER019MEX.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³GPER019MEX³ Autor ³ Jonathan Gonzalez     ³Fecha ³27/03/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Impr. de Informe de Riesgo de Trabajo(Sintetico/analitico)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ (void)                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  SIGAGPE                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ACTUALIZACIONES SUFRIDAS DESDE LA CREACION INICIAL             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha    ³ BOPS ³  Motivo de alteracion                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Veronica F. ³06/11/2019³DMINA-³En la función PrintReport se realiza mod. ³±±
±±³            ³          ³ 7669 ³de la extracción de Rangos de Empleado y  ³±±
±±³            ³          ³      ³Registro patronal                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER019MEX()

Local	oReport   
Local	aArea 	 	:= GetArea()
Local  lSalir		:= .F.

Private cNomeProg	:= "GPER019MEX"
Private cPerg		:= cNomeProg

Private dFchIni 	//del periodo
Private dFchFin 	//al periodo
Private cRegPat 	:= ""//Tipo de Reporte
Private cRanEmp 	:= ""//Rango de empleados
Private cTipoInf	:= 1//Tipo de Reporte

Private cRanPat	:= "" //Rango de registros patronales
Private nTamReg	:= TamSX3("RCO_CODIGO")[1]
Private nCont		:= 0

dbSelectArea("RIT") // tabla Casos de Riesgo
dbSelectArea("RS2") // tabla Detalle de Casos de Riesgo
dbSelectArea("RCO") // tabla Registro Patronal 
dbSelectArea("SRA") // tabla Empleados


If !TRepInUse()	//verifica se a opção relatórios personalizáveis está disponível
	MSGSTOP(OEMTOANSI(STR0001)) //"Para usar este inform debe tener MP8 R4 en adelante!"
	lSalir:=.t.
endif

if lSalir 
	RestArea(aArea)
	Return
endif

	oReport := Report_Def()
	
	oReport:PrintDialog()
	
RestArea(aArea)

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ Report_Def        ³ Autor ³ Jonathan Gonzalez     ³ Data ³27/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Definicion del Informe de Riesgo de Trabajo - Sintetico/Analitico   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPE                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function Report_Def()

Local	aArea		:= GetArea()
 
Local	oReport

Local	oSection1 
Local	oSection2
Local 	oSection3
Local	oSection4
Local	oSection5
Local 	oSection6
Local	oSection7

Private cTitulo	:=OEMTOANSI(STR0003) //reporte de riesgos de trabajo
Private aOrd		:= {OemToAnsi(STR0004)}	//registro patronal

cursorwait()
cTitulo := Trim(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajuste General de TReport        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 



oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo),CPERG ,{|oReport| PrintReport(oReport)})


oReport:SetPortrait()     // Define a orientacao de pagina do relatorio como retrato.
oReport:Setlandscape(.F.)//Pag Horizontal
oReport:nColSpace:=1
oReport:nFontBody	:= 8 // Define o tamanho da fonte.
oReport:nLineHeight	:= 40 // Define a altura da linha.
oReport:cFontBody:="COURIER NEW"
oReport:EndPage(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seccion de Encabezado            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1:= TRSection():New(oReport,oemtoansi("Encabezado"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.T.)   //Pone titulo del campo y aun lado el y valor
OSection1:SetCharSeparator(" ")    
oSection1:SetHeaderBreak(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Periodo de proceso del:  ³
//³ Fecha                    ³
//³ Registro Patronal        ³
//³ RFC                      ³
//³ Nombre o Razon Social    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
TRCell():New(oSection1,"PERIODO"	,/*alias*/,STR0005,/*Picture*/,26,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection1:Cell("PERIODO"):SetCellBreak(.T.)
TRCell():New(oSection1,"FECHA",/*alias*/,STR0006,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
TRCell():New(oSection1,"RCO_NREPAT",/*alias*/,STR0007,PesqPict("RCO","RCO_NREPAT"),TamSx3("RCO_NREPAT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
TRCell():New(oSection1,"SM0_CGC",/*alias*/,STR0008,,TamSx3("RA_CIC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection1:Cell("SM0_CGC"):SetCellBreak(.T.)
TRCell():New(oSection1,"RCO_NOME",/*alias*/,STR0009,PesqPict("RCO","RCO_NOME"),TamSx3("RCO_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"RIGHT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection1:Cell("RCO_NOME"):SetCellBreak(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seccion Detalle                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2:= TRSection():New(oReport,oemtoansi("Detalle"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ numero de seguridad social     ³
//³ nombre del asegurado           ³
//³ Fecha de inicio                ³
//³ Tipo Rgo.                      ³
//³ Con. Sec.                      ³
//³ Dias Subs.                     ³
//³ Porc. Incap                    ³
//³ Fecha Termino                  ³
//³ observaciones                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
TRCell():New(oSection2,"RA_RG"		,/*alias*/,STR0010,PesqPict("SRA","RA_RG")	 ,TamSx3("RA_RG")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,"RA_NOME"	,/*alias*/,STR0011,PesqPict("SRA","RA_NOME")	 ,TamSx3("RA_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
TRCell():New(oSection2,"FCH_INICIO",/*alias*/,STR0012,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,"RIT_TIPRIE",/*alias*/,STR0013,PesqPict("RIT","RIT_TIPRIE"),TamSx3("RIT_TIPRIE")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,"RIT_CONSEC",/*alias*/,STR0014,PesqPict("RIT","RIT_CONSEC"),TamSx3("RIT_CONSEC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,"RIT_DIAS"	,/*alias*/,STR0015,PesqPict("RIT","RIT_DIAS")	  ,TamSx3("RIT_DIAS")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,"RIT_PORINC",/*alias*/,STR0016,PesqPict("RIT","RIT_PORINC"),TamSx3("RIT_PORINC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,"FCH_TERMIN",/*alias*/,STR0017,/*Picture*/ ,15,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,"OBSERVACION",/*alias*/,STR0018,/*Picture*/,20,/*lPixel*/  ,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

//TRBORDER():New(oSection2,2, ,2,255255255)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seccion SubDetalle             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3:= TRSection():New(oSection2,oemtoansi("SubDetalle"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folio                          ³
//³ Fecha inicio                   ³
//³ Dias                           ³
//³ Fecha Fin                      ³
//³ Consec.                        ³
//³ Riesgo Probable                ³
//³ Tipo de Riesgo                 ³
//³ Result. de la incapacidad      ³
//³ Control de incapacidad         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
TRCell():New(oSection3,"RS2_NCERIN",/*alias*/,STR0026,PesqPict("RS2","RS2_NCERIN"),TamSx3("RS2_NCERIN")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection3,"DATAINI"	,/*alias*/,STR0027,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
TRCell():New(oSection3,"RS2_DURACA",/*alias*/,STR0028,PesqPict("RS2","RS2_DURACA"),TamSx3("RS2_DURACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection3,"DATAFIN"	,/*alias*/,STR0029,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection3,"RS2_CONTIN",/*alias*/,STR0030,PesqPict("RS2","RS2_CONTIN"),TamSx3("RS2_CONTIN")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection3,"RS2_PRORSC",/*alias*/,STR0031,PesqPict("RS2","RS2_PRORSC"),TamSx3("RS2_PRORSC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection3,"RS2_TIPORS",/*alias*/,STR0032,PesqPict("RS2","RS2_TIPORS"),TamSx3("RS2_TIPORS")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection3,"RS2_RESINC",/*alias*/,STR0033,PesqPict("RS2","RS2_RESINC"),TamSx3("RS2_RESINC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection3,"RS2_CONINC",/*alias*/,STR0034,PesqPict("RS2","RS2_CONINC"),TamSx3("RS2_CONINC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seccion Detalle Total          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection4:= TRSection():New(oReport,oemtoansi("Total Detalle"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"Detalle total"
oSection4:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el valor
oSection4:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Casos tipo riesgo 1 y 3        ³
//³ Casos tipo riesgo 2            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
TRCell():New(oSection4,"TIPO_1_3"	 ,/*alias*/,STR0019, /*Picture*/,5,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection4,"TIPO_2"		 ,/*alias*/,STR0020, /*Picture*/,5,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

oSection5:= TRSection():New(oSection4,oemtoansi("Total Detalle "),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"Detalle total"
oSection5:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el valor
oSection5:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderBreak(.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³----- tipo risgo 1 Y 3 -----    ³
//³ Casos                          ³
//³ Dias Sunsidiados               ³
//³ Porcentaje incapacidad         ³
//³ Defunciones                    ³
//³----- tipo risgo 2 -----        ³
//³ Casos                          ³
//³ Dias Sunsidiados               ³
//³ Porcentaje incapacidad         ³
//³ Defunciones                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection5,"CASOS"		 ,/*alias*/,STR0022, "999,999"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection5,"DIAS_SUB"	 ,/*alias*/,STR0023, "999,999"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
TRCell():New(oSection5,"SUMA_PORC"	 ,/*alias*/,STR0024, "9999.99"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection5,"SUMA_DEFUNC",/*alias*/,STR0025, "999,999"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection5,"VACIO"			,/*alias*/," ",,5,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection5,"CASOS2"			,/*alias*/,STR0022, "999,999"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection5,"DIAS_SUB2"		,/*alias*/,STR0023, "999,999"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
TRCell():New(oSection5,"SUMA_PORC2"	,/*alias*/,STR0024, "9999.99"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection5,"SUMA_DEFUNC2"	,/*alias*/,STR0025, "999,999"		,14,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seccion Totales                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection6:= TRSection():New(oReport,oemtoansi("Totales"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"Totales"
oSection6:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el valor
oSection6:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection6:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection6,"TOTAL_RIESGOS"	,/*alias*/,STR0021, /*Picture*/	,5,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

oSection7:= TRSection():New(oSection6,oemtoansi("Totales"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"Totales"
oSection7:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el valor
oSection7:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection7:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection7:SetLeftMargin(50)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo (Total Riesgos Trabajo)  ³
//³ Casos                          ³
//³ Dias Sunsidiados               ³
//³ Porcentaje incapacidad         ³
//³ Defunciones                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
TRCell():New(oSection7,"CASOST"			,/*alias*/,STR0022, "999,999"	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection7,"DIAS_SUBT"		,/*alias*/,STR0023, "999,999"	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
TRCell():New(oSection7,"SUMA_PORCT"	,/*alias*/,STR0024, "9999.99"	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection7,"SUMA_DEFUNCT"	,/*alias*/,STR0025, "999,999"	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
cursorarrow()	

OSECTION1:NLINESBEFORE:=0
OSECTION2:NLINESBEFORE:=0
OSECTION3:NLINESBEFORE:=0
OSECTION4:NLINESBEFORE:=0
OSECTION5:NLINESBEFORE:=0
OSECTION6:NLINESBEFORE:=0
OSECTION7:NLINESBEFORE:=0

Return (oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³PrintReport ³ Autor ³ Jonathan Gonzalez     ³ Data ³27/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impresion Informe de Riesgo de Trabajo Sintetico/Analitico   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPE                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function PrintReport(oReport)
//encabezado
Local oSection1  := oReport:Section(1)
//detalle
Local oSection2  := oReport:Section(2)
Local oSection3  := oReport:Section(2):Section(1)
//total detalle
Local oSection4  := oReport:Section(3)
Local oSection5  := oReport:Section(3):Section(1)
//totales
Local oSection6  := oReport:Section(4)
Local oSection7  := oReport:Section(4):Section(1)


Local cTitle		:= ""     
Local cAliasRIT	:= "QRYRIT"
Local cAliasRS2	:= "QRYRS2"

Local cFilRIT		:= xfilial("RIT")
Local cFilRCO		:= xfilial("RCO")
Local cFilSRA		:= xfilial("SRA")
Local cFilRS2 	:= xfilial("RS2")

Local cCposQuery	:= ""
Local cCposFrom	:= ""
Local cWhere		:= ""
Local cOrdem		:= ""

//RIT
Local cTmpRegPat	:= ""
Local cTmpFilial	:= ""
Local nTotal		:= 0

Local nCasos		:= 0
Local nDiasSub	:= 0
Local nSumaPrc	:= 0
Local nSumaDFC	:= 0

Local nCasos2		:= 0
Local nDiasSub2	:= 0
Local nSumaPrc2	:= 0
Local nSumaDFC2	:= 0

Local nCasosT		:= 0
Local nDiasSubT	:= 0
Local nSumaPrcT	:= 0
Local nSumaDFCT	:= 0

//Casos 1 y 3 
Local nCountC13	:= 0
Local nCountD13	:= 0
//Casos 2
Local nCountC2	:= 0
Local nCountD2	:= 0
Local nCont:=0

Pergunte(oReport:GetParam(),.F.)
	dFchIni	:= MV_PAR01 //del anio
	dFchFin	:= MV_PAR02 //al anio
	cTipoInf	:= MV_PAR05 //Tipo de Informe

If empty (dFchIni) .OR. empty (dFchFin)
	MSGALERT (STR0040,STR0039)
	oReport:CancelPrint()
Else 
		
	MakeSQLExpr(oReport:uParam)
	
	IF EMPTY (MV_PAR03)
	 	cRanPat := "BETWEEN '0000' AND 'ZZZZ'"
	Else
		cRanPat := SUBSTR(ALLTRIM(MV_PAR03),12,LEN(ALLTRIM(MV_PAR03))-12)//Rango de Registro patronal	
	EndIf
	
	IF EMPTY (MV_PAR04)
	 	cRanEmp := "BETWEEN '000000' AND '999999'"
	Else
		cRanEmp := SUBSTR(ALLTRIM(MV_PAR04),8,LEN(ALLTRIM(MV_PAR04))-8)//Rango de empleados
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera el titulo del reporte comforme a los parametros seleccionados        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
	oReport:SetTitle(cTitle) 
	
	#IFDEF TOP
	
	cursorwait()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Query para la obtencion de informacion de para la relacion de casos de riesgo    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCposQuery := "% RIT_FILIAL, RIT_CODRPA, RCO_NOME, RCO_NREPAT, RA_RG, RA_NOME,RIT_MAT, "
		cCposQuery += "  RIT_ITEM, RIT_ANIO, RIT_FECACC, RIT_TIPRIE, RIT_CONSEC,RIT_DIAS, "
		cCposQuery += "  RIT_DEFUNC, RIT_PORINC, RIT_FECALT, RIT_OBSERV, RS2_NCERIN, RS2_DATAIN,"
		cCposQuery += "  RS2_DURACA, RS2_DATAFI, RS2_CONTIN, RS2_PRORSC, RS2_TIPORS,RS2_RESINC, RS2_CONINC  %"
			
		cCposFrom	:= "% " + RetSqlName("RIT") + " RIT, " 
		cCposFrom	+=  RetSqlName("RCO")+ " RCO, "
		cCposFrom	+=  RetSqlName("RS2")+ " RS2, "
		cCposFrom	+=  RetSqlName("SRA")+ " SRA  %"
			
		cWhere	:="%    RIT_CODRPA "+ cRanPat +" " // Registro Patronal 
		cWhere	+="     AND RIT_CODRPA = RCO_CODIGO"
		cWhere	+="     AND RIT_CODRPA = RA_CODRPAT"
		cWhere +="     AND RCO_CODIGO = RA_CODRPAT"
		
		cWhere +="     AND RIT_MAT "+ cRanEmp +" "
		cWhere +="     AND RIT_MAT = RA_MAT"
		
		cWhere +="     AND RIT_FECACC BETWEEN '"+DTOS(dFchIni)+"' AND '"+DTOS(dFchFin)+"'"
		
		cWhere	+="     AND RS2_MAT = RIT_MAT "
		cWhere	+="     AND RS2_ITEM = RIT_ITEM "
		cWhere +="     AND RS2_ANIO = RIT_ANIO"
				
		cWhere +="     AND RIT_FILIAL = '"+cFilRIT+"'"
		cWhere +="     AND RCO_FILIAL = '"+cFilRCO+"'"
		cWhere +="     AND RA_FILIAL  = '"+cFilSRA+"'"
		cWhere +="     AND RS2_FILIAL = '"+cFilRS2+"'"
		
		cWhere +="     AND RIT_FILIAL = RA_FILIAL "
		cWhere	+="     AND RIT_FILIAL = RS2_FILIAL "
	
	    If ( TcSrvType()=="AS/400" )
			cWhere	+="     AND RIT.@DELETED@  = ' ' " 
			cWhere	+="     AND RCO.@DELETED@  = ' ' "
			cWhere	+="     AND SRA.@DELETED@  = ' ' " 
			cWhere	+="     AND RS2.@DELETED@  = ' '%" 
		ELSE 
			cWhere	+="     AND RIT.D_E_L_E_T_  = ' ' " 
			cWhere	+="     AND RCO.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SRA.D_E_L_E_T_  = ' ' " 
			cWhere	+="     AND RS2.D_E_L_E_T_  = ' ' %" 				
		ENDIF

		cOrdem		:= "%  RIT_FILIAL, RIT_CODRPA, RCO_NOME, RCO_NREPAT, RA_RG, RIT_FECACC %"
		
		BeginSql alias cAliasRIT 
			SELECT %exp:cCposQuery%
			FROM  %exp:cCposFrom% 
			WHERE %exp:cWhere%
			ORDER BY %exp:cOrdem%
		EndSql
		
		TCSetField(cAliasRIT,"RIT_FECACC","D")
		TCSetField(cAliasRIT,"RIT_FECALT","D")
		TCSetField(cAliasRIT,"RS2_DATAIN","D")
		TCSetField(cAliasRIT,"RS2_DATAFI","D")
	
	cursorarrow()

	#ELSE
		MSGERROR(OemToAnsi(STR0035))
	#ENDIF
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia el llenado del reporte            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( cAliasRIT )
		count to nTotal
	    oReport:SetMeter(nTotal)
	    
		(cAliasRIT)->(DbGoTop())
		
		While (cAliasRIT)->(!Eof())	  
				//Casos tipo 1 y 3
				nCasos		:=0
				nDiasSub	:=0
				nSumaPrc	:=0
				nSumaDFC	:=0
					
				//Total Caso 2
				nCasos2	:=0
				nDiasSub2	:=0
				nSumaPrc2	:=0
				nSumaDFC2	:=0
				
				//TOTAL GENERAL
				nCasosT	:=0
				nDiasSubT	:=0
				nSumaPrcT	:=0
				nSumaDFCT	:=0
				
			//Encabezado de reporte
			oSection1:Init()
				oSection1:Cell("PERIODO"):SetValue(DTOC(dFchIni)+ " al "+DTOC(dFchFin))
				oSection1:Cell("FECHA"):SetValue(DDATABASE)
				oSection1:Cell("RCO_NREPAT"):SetValue((cAliasRIT)->RCO_NREPAT)
				oSection1:Cell("SM0_CGC"):SetValue(alltrim(SM0->M0_CGC))
				oSection1:Cell("RCO_NOME"):SetValue((cAliasRIT)->RCO_NOME)
			oSection1:printline()
			oReport:Fatline()
			oSection1:Finish()	
		
			//Datos de los empleados.
			oSection2:Init()
		
			cTmpRegPat := (cAliasRIT)->RCO_NREPAT
			cTmpFilial := (cAliasRIT)->RIT_FILIAL
						
			While (cAliasRIT )->(!Eof()) .AND. cTmpRegPat == (cAliasRIT)->RCO_NREPAT .AND. cTmpFilial ==(cAliasRIT)->RIT_FILIAL
			
					oSection2:Cell("RA_RG"):SetValue((cAliasRIT)->RA_RG)
					oSection2:Cell("RA_NOME"):SetValue((cAliasRIT)->RA_NOME)
					
					oSection2:Cell("FCH_INICIO"):SetValue(SUBSTR(DTOS((cAliasRIT)->RIT_FECACC),7,2);
													+"/"+SUBSTR(DTOS((cAliasRIT)->RIT_FECACC),5,2);
													+"/"+SUBSTR(DTOS((cAliasRIT)->RIT_FECACC),1,4))
					
					oSection2:Cell("RIT_TIPRIE"):SetValue((cAliasRIT)->RIT_TIPRIE)
					oSection2:Cell("RIT_CONSEC"):SetValue((cAliasRIT)->RIT_CONSEC)
					oSection2:Cell("RIT_DIAS"):SetValue((cAliasRIT)->RIT_DIAS)
					oSection2:Cell("RIT_PORINC"):SetValue((cAliasRIT)->RIT_PORINC)
					
					oSection2:Cell("FCH_TERMIN"):SetValue(SUBSTR(DTOS((cAliasRIT)->RIT_FECALT),7,2);
													+"/"+SUBSTR(DTOS((cAliasRIT)->RIT_FECALT),5,2);
													+"/"+SUBSTR(DTOS((cAliasRIT)->RIT_FECALT),1,4))
			
					IF ((cAliasRIT)->RIT_OBSERV) != "1"
						oSection2:Cell("OBSERVACION"):SetValue(STR0037)
					else 
						oSection2:Cell("OBSERVACION"):SetValue(STR0036)
					endif
					oSection2:Printline()
					
					
			//--------------------------------------------SUBDETALLE---------------------------------------------------------------
					IF cTipoInf == 2
				
						oSection3:Init()
				
								oSection3:Cell("RS2_NCERIN"):SetValue((cAliasRIT)->RS2_NCERIN)
										
								oSection3:Cell("DATAINI"):SetValue(SUBSTR(DTOS((cAliasRIT)->RS2_DATAIN),7,2);
															 +"/"+SUBSTR(DTOS((cAliasRIT)->RS2_DATAIN),5,2)+"/"+SUBSTR(DTOS((cAliasRIT)->RS2_DATAIN),1,4))
										
								oSection3:Cell("RS2_DURACA"):SetValue((cAliasRIT)->RS2_DURACA)
										
								oSection3:Cell("DATAFIN"):SetValue(SUBSTR(DTOS((cAliasRIT)->RS2_DATAFI),7,2);
															 +"/"+SUBSTR(DTOS((cAliasRIT)->RS2_DATAFI),5,2)+"/"+SUBSTR(DTOS((cAliasRIT)->RS2_DATAFI),1,4))
										
								oSection3:Cell("RS2_CONTIN"):SetValue((cAliasRIT)->RS2_CONTIN)
								oSection3:Cell("RS2_PRORSC"):SetValue((cAliasRIT)->RS2_PRORSC)
								oSection3:Cell("RS2_TIPORS"):SetValue((cAliasRIT)->RS2_TIPORS)
								oSection3:Cell("RS2_RESINC"):SetValue((cAliasRIT)->RS2_RESINC)
								oSection3:Cell("RS2_CONINC"):SetValue((cAliasRIT)->RS2_CONINC)
								oSection3:Printline()
						oSection3:Finish()
					ENDIF
			//---------------------------------------------------------------------------------------------------------------------
			
	 
			//LLENADO DE LAS VARIABLES A IMPRIMIR EN TOTALES.	
				//TOTALES PARA LOS CASOS 1 Y 3
					IF (cAliasRIT)->RIT_TIPRIE == "1"
					
						nDiasSub		+= (cAliasRIT)->RIT_DIAS
						nSumaPrc		+= (cAliasRIT)->RIT_PORINC
						nCountC13++
						
						IF (cAliasRIT)->RIT_DEFUNC == "D"
							nCountD13++
						ENDIF
					ENDIF
						
					IF (cAliasRIT)->RIT_TIPRIE == "3"
					
						nDiasSub		+= (cAliasRIT)->RIT_DIAS
						nSumaPrc		+= (cAliasRIT)->RIT_PORINC
						nCountC13++
						
						IF (cAliasRIT)->RIT_DEFUNC == "D"
							nCountD13++
						ENDIF
					ENDIF
						
				//TOTALES PARA EL CASO 2
					IF (cAliasRIT)->RIT_TIPRIE == "2"
					
						nDiasSub2		+= (cAliasRIT)->RIT_DIAS
						nSumaPrc2		+= (cAliasRIT)->RIT_PORINC
						nCountC2++
						
						IF (cAliasRIT)->RIT_DEFUNC == "D"
							nCountD2++
						ENDIF	
					ENDIF
			
				//TOTAL PARA  LOS CASOS 1,2 Y 3
					nDiasSubT		+= (cAliasRIT)->RIT_DIAS
					nSumaPrcT		+= (cAliasRIT)->RIT_PORINC
			//TERMINA LLENADO
		
				(cAliasRIT)->(dbskip())
				oReport:IncMeter()
			
			EndDo	
				oReport:Fatline()
				oSection2:Finish()
				
				//Casos tipo 1 y 3
				nCasos			:= nCountC13
				nSumaDFC		:= nCountD13
				//Casos tipo 2
				nCasos2		:= nCountC2
				nSumaDFC2		:= nCountD2
				//Casos 1,2 y 3
				nCasosT		:= (nCountC13 + nCountC2)
				nSumaDFCT		:= (nCountD13 + nCountD2)
				
				//Casos tipo 1 y 3
				nCountC13		:= 0
				nCountD13		:= 0
				//Casos tipo 2
				nCountC2		:= 0
				nCountD2		:= 0
				
				//Totales	
				oSection4:Init()
				oSection5:Init()
				oSection6:Init()
				oSection7:Init()
				
					oSection4:Cell("TIPO_1_3"):SetValue()
					oSection4:Cell("TIPO_2"):SetValue()
				//inicializacion
					//Casos 1 y 3
					oSection5:Cell("CASOS"):SetValue(0)
					oSection5:Cell("DIAS_SUB"):SetValue(0)
					oSection5:Cell("SUMA_PORC"):SetValue(0)
					oSection5:Cell("SUMA_DEFUNC"):SetValue(0)
					//Caso 2
					oSection5:Cell("CASOS2"):SetValue(0)
					oSection5:Cell("DIAS_SUB2"):SetValue(0)
					oSection5:Cell("SUMA_PORC2"):SetValue(0)
					oSection5:Cell("SUMA_DEFUNC2"):SetValue(0)
				//Total Caso 1 y 3
					oSection5:Cell("CASOS"):SetValue(nCasos)
					oSection5:Cell("DIAS_SUB"):SetValue(nDiasSub)
					oSection5:Cell("SUMA_PORC"):SetValue(nSumaPrc) 
					oSection5:Cell("SUMA_DEFUNC"):SetValue(nSumaDFC)
					oSection5:Cell("VACIO"):SetValue()
				//Total Caso 2
					oSection5:Cell("CASOS2"):SetValue(nCasos2)
					oSection5:Cell("DIAS_SUB2"):SetValue(nDiasSub2)
					oSection5:Cell("SUMA_PORC2"):SetValue(nSumaPrc2) 
					oSection5:Cell("SUMA_DEFUNC2"):SetValue(nSumaDFC2) 		
				//Suma Totlales (total de casos (1,2 y 3)	
				
					//impresion
					oSection6:Cell("TOTAL_RIESGOS"):SetValue()
					//inicializacion
					oSection7:Cell("CASOST"):SetValue(0)
					oSection7:Cell("DIAS_SUBT"):SetValue(0)
					oSection7:Cell("SUMA_PORCT"):SetValue(0)
					oSection7:Cell("SUMA_DEFUNCT"):SetValue(0)
					//impresion
					oSection7:Cell("CASOST"):SetValue(nCasosT)
					oSection7:Cell("DIAS_SUBT"):SetValue(nDiasSubT)
					oSection7:Cell("SUMA_PORCT"):SetValue(nSumaPrcT) 
					oSection7:Cell("SUMA_DEFUNCT"):SetValue(nSumaDFCT) 
				
				oSection4:PrintLine()
				oSection5:PrintLine()	
				oSection6:PrintLine()	
				oSection7:PrintLine()
				
				oSection4:Finish()
				oSection5:Finish()
				oSection6:Finish()
				oSection7:Finish()

				oReport:EndPage() //-- Salta Pagina	 
			
		EndDo

	(cAliasRIT)->(dbCloseArea())
endif
return ( Nil )