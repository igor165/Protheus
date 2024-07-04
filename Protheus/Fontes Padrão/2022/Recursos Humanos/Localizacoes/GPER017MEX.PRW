#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "gper017mex.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³GPER017MEX³ Autor ³ Jonathan Gonzalez     ³Fecha ³14/03/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Reporte de Dias Cotizados y trabajadores promedio            ³±±
±±³          ³ expuestos al riesgo                                          ³±±
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
±±³            ³          ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER017MEX()

Local		oReport   
Local		aArea		:= GetArea()
Local		lSalir		:= .F.

Private	cNomeProg	:= "GPER017MEX" //Nombre del Programa: Sera mostrado en el cuadro de dialogo de Impresion
Private	cPerg		:= cNomeProg //Nombre del grupo de preguntas.
Private	cAnio		:= "" //Anio
Private	cRegPat	:= "" //Registro Patronal
Private	cLisPat	:= "" //Lista de Registros Patronales

If !TRepInUse()	//Verifica de la opcion de reportes personalizados este disponible
	MSGSTOP(OEMTOANSI(STR0001) )//"Para usar este inform debe tener MP8 R4 en adelante!" 
	lSalir:=.t.
endif   
       
if lSalir 
	RestArea(aArea)
	Return
endif

oReport := ReportDef() //Llamado de la funcion ReportDef
oReport:PrintDialog() //Cuadro de dialogo para la impresion
	
RestArea(aArea)

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ ReportDef  ³ Autor ³ Jonathan Gonzalez     ³ Data ³14/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Definicion reporte de dias trab. y Prom. de trabajadores     ³±±
±±³          ³ expuestos al riesgo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPE                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local 	aArea      := GetArea() 
Local 	oReport

Local	oSection1
Local 	oSection2     
Local 	oSection3       
Local 	oSection4

Private cTitulo := OemToAnsi(STR0003) //"Reporte de Días Cotizados y trabajadores promedio expuestos al riesgo"
Private aOrd	  := {OemToAnsi(STR0004)}	//Registro patronal

cTitulo := Trim(cTitulo)

//Bloque de codigo para la comfirmacion de impresion
oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), CPERG ,{|oReport| PrintReport(oReport)})


	
oReport:SetPortrait()     // Define a orientacao de pagina do relatorio como retrato.
oReport:nColSpace	:=1
oReport:nFontBody	:= 12 // Define el tamaño de la fuente
oReport:nLineHeight	:= 40 // Define a altura da linea
oReport:cFontBody	:="COURIER NEW"
oReport:Setlandscape(.T.)//Pag Horizontal
oReport:SetTotalInLine(.F.)
 
// Primera seccion  Desc: Encabezado del Reporte
oSection1:= TRSection():New(oReport,oemtoansi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection1:SetHeaderPage(.T.)	//Muestra le titulo de la seccion
oSection1:SetLineStyle(.T.)   //Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(" ")    
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"ANIO",,STR0005 ,,4,,,"LEFT")//Año Computo
oSection1:Cell("ANIO"):SetCellBreak(.T.)

TRCell():New(oSection1,"FECHA",,STR0006 ,,10,,,"LEFT" ) //Fecha
oSection1:Cell("FECHA"):SetCellBreak(.T.)


TRCell():New(oSection1,"RHC_CODRPA",,STR0007 ,,TamSx3("RHC_CODRPA")[1],,,"LEFT")//Registro Patronal
TRCell():New(oSection1,"RFC",,STR0008 ,,TamSx3("RA_CIC")[1],,,"LEFT")//"RFC:"
oSection1:Cell("RFC"):SetCellBreak(.T.)

TRCell():New(oSection1,"RCO_NOME",,STR0009,,TamSx3("RCO_NOME")[1],,,"LEFT")//"Nombre o Razón Social "
oSection1:Cell("RCO_NOME"):SetCellBreak(.T.)

//Segunda Seccion     Desc: Pone el Titulo de la seccion de detalle                             
oSection2:= TRSection():New(oReport,oemtoansi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection2:SetTotalInLine(.f.)
oSection2:SetHeaderSection(.f.)	//Muestra le titulo de la seccion
oSection2:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection2:SetLineStyle(.T.)   //Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderBreak(.T.)

TRCell():New(oSection2,"DETALLE",,STR0010,,400)
oSection2:Cell("DETALLE"):SetCellBreak(.T.)

//Tercera Seccion     Desc: Detalles                             
oSection3:= TRSection():New(oReport,oemtoansi("EncPrograma"),,aOrd,/*Campos do SX3* /,/*Campos do SIX*/) //"EncPrograma"
oSection3:SetTotalInLine(.f.)  
oSection3:SetHeaderSection(.f.)	//Muestra le titulo de la seccion
oSection3:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderBreak(.T.)

TRCell():New(oSection3,"MES",,,,15)
TRCell():New(oSection3,"DIACOTIZADO",  , ,"99,999,999"     ,10)
oSection3:Cell("DIACOTIZADO"):SetCellBreak(.T.)

//Cuarta Seccion     Desc: Totales de los dias trabajados y Promedio de tabajadores expuesto al riesgo                              
oSection4:= TRSection():New(oReport,oemtoansi("EncPrograma"),,aOrd,/*Campos do SX3* /,/*Campos do SIX*/) //"EncPrograma"
oSection4:SetHeaderPage(.F.)	 //Exibe Cabecalho da Secao
oSection4:SetHeaderSection(.F.) //Muestra le titulo de la seccion
oSection4:SetLineStyle(.T.)     //Pone titulo del campo y aun lado el y valor
oSection4:SetCharSeparator(" ")    
oSection4:SetHeaderBreak(.T.)

TRCell():New(oSection4,"TOTALDIAS",  ,STR0011 ,"99,999,999"     ,10)
oSection4:Cell("TOTALDIAS"):SetCellBreak(.T.)
TRCell():New(oSection4,"PROMEDIODIAS",  ,STR0012 ,"9,999,999.9"     ,11)
TRCell():New(oSection4,"NOTA",,STR0013,,10)
oSection4:Cell("NOTA"):SetCellBreak(.T.)

OSECTION1:NLINESBEFORE:=0
OSECTION2:NLINESBEFORE:=0
OSECTION3:NLINESBEFORE:=0
OSECTION4:NLINESBEFORE:=0

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³PrintReport ³ Autor ³ Jonathan Gonzalez     ³ Data ³14/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Llenado del reporte de dias trab. y Prom. de trabajadores    ³±±
±±³          ³ expuestos al riesgo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPE                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local oSection3  := oReport:Section(3)
Local oSection4  := oReport:Section(4)

Local cTitle			:= ""     
Local cOrdem			:= ""
Local cGroup			:= "" 
Local cAliasDIA		:= "QRYDIA" 
Local cFilRHC			:= xfilial("RHC")
Local cFilRCO			:= xfilial("RCO")
Local cCposQuery		:= ""
Local cCposFrom		:= ""
Local cWhere			:= ""
Local cMesIni			:= "01"
Local cMesFin			:= "12"
Local cMes				:= ""
Local nSUMADIA			:= 0
Local nSUMAPROMEDIO	:= 0
local cRegPat			:=""
local cTmpRHC			:=""
Local nCont			:= 0
Local nTamReg			:= TamSX3("RCO_CODIGO")[1]
Local nTotal			:= 0


Pergunte(oReport:GetParam(),.F.)
 
cAnio :=	MV_PAR01 //Anio
cRegPat := MV_PAR02 //registro patronal
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Genera una lista de registros patronales      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nCont := 1 To Len(cRegPat) Step nTamReg

		if empty(SubStr( cRegPat , nCont , nTamReg ))
		   exit
		endif
		
		cLisPat+="'"+SubStr( cRegPat , nCont , nTamReg )+"',"		
Next
cLisPat:=Substr(cLisPat,1,len(cLisPat)-1)  	   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera el titulo del reporte comforme a los parametros seleccionados        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle) 

#IFDEF TOP
cursorwait()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para la obtencion del Año/Mes, Num. de días Trab. Y Promedio de trabajadores expuestos al riesgo       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCposQuery := "% RHC_FILIAL, RHC_CODRPA, RCO_NOME, RHC_ANOMES, SUM(RHC_NDTRAB-RHC_NDINC-RHC_NDFAL) AS 'RHC_DCOT',"
		cCposQuery += " SUM((RHC_NDTRAB-RHC_NDINC-RHC_NDFAL)/365) AS 'RHC_DCOTP' %"
		
		cCposFrom	:= "%" + RetSqlName("RHC") + " RHC, " 
		cCposFrom	+=  RetSqlName("RCO")+ " RCO %"
		cWhere		:="%    RHC_CODRPA IN ("+CLISPAT+")"		
		cWhere		+="     AND RCO_CODIGO=RHC_CODRPA"
		cWhere		+="     AND RHC_ANOMES BETWEEN '"+alltrim(str(cAnio))+cMesIni+"' AND '"+alltrim(str(cAnio))+cMesFin +"' "//AnioMes	
		cWhere		+="     AND RHC_FILIAL  ='"+cFilRHC+"'"
		cWhere		+="     AND RCO_FILIAL= '"  + cFilRCO +"' "
			If ( TcSrvType()=="AS/400" )
				cWhere		+="     AND RCO.@DELETED@  = ' ' " 
				cWhere		+="     AND RHC.@DELETED@  = ' ' %" 
			ELSE 
				cWhere		+="     AND RCO.D_E_L_E_T_  = ' ' " 		
				cWhere		+="     AND RHC.D_E_L_E_T_  = ' ' %" 				
			ENDIF                    
		cGroup		:= "%  RHC_FILIAL, RHC_CODRPA, RCO_NOME, RHC_ANOMES %"
		cOrdem		:= "% RHC_FILIAL, RHC_CODRPA, RCO_NOME, RHC_ANOMES %"	
		
		BeginSql alias cAliasDIA 
			SELECT DISTINCT   %exp:cCposQuery%
			FROM  %exp:cCposFrom% 
			WHERE %exp:cWhere%     
			GROUP BY %exp:cGroup%
			ORDER BY %exp:cOrdem%
		EndSql
cursorarrow()
#ELSE
	MSGERROR(OemToAnsi(STRO014))
#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia el llenado del reporte            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAliasDIA )
	count to ntotal
    oReport:SetMeter(nTotal) 
	
	(cAliasDIA)->(DbGoTop())
	
       
	
While (cAliasDIA)->(!Eof())	  
			nSUMADIA			:= 0
			nSUMAPROMEDIO     := 0

			oSection1:Init() 
				oSection1:Cell("ANIO"):SetValue(alltrim(str(cAnio))) //PERIODO DE COMPUTO
				oSection1:Cell("FECHA"):SetValue(DDATABASE) //FECHA
				oSection1:Cell("RHC_CODRPA"):SetValue(alltrim((cAliasDIA)->RHC_CODRPA))//Registro Patronal
				oSection1:Cell("RFC"):SetValue(alltrim(SM0->M0_CGC))//RFC.
				oSection1:Cell("RCO_NOME"):SetValue(alltrim((cAliasDIA)->RCO_NOME))//"Nombre o Razón Social:
			oSection1:printline()
			oReport:Fatline()
			oSection1:Finish()	
			
			//Encabezado de Detalle
			oSection2:Init()
				oSection2:Cell("DETALLE"):Show()
				oSection2:Cell("DETALLE"):SetValue(STR0016)
			oSection2:Printline()
			oReport:Fatline()
			oSection2:Finish()
			

			cRegPat := (cAliasDIA)-> RHC_CODRPA
			cTmpRHC := (cAliasDIA)-> RHC_Filial
		
			//DETALLE DE LOS MESES Y LOS DIAS
			oSection3:Init()
										
				While (cAliasDIA )->(!Eof()) .and. cRegPat==(cAliasDIA)-> RHC_CODRPA .and. cTmpRHC==(cAliasDIA)->RHC_Filial
				
					IF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="01"
						cMes:=OemToAnsi(STR0017)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="02"
						cMes:=OemToAnsi(STR0018)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="03"
						cMes:=OemToAnsi(STR0019)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="04"
						cMes:=OemToAnsi(STR0020)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="05"
						cMes:=OemToAnsi(STR0021)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="06"
						cMes:=OemToAnsi(STR0022)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="07"
						cMes:=OemToAnsi(STR0023)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="08"
						cMes:=OemToAnsi(STR0024)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="09"
						cMes:=OemToAnsi(STR0025)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="10"
						cMes:=OemToAnsi(STR0026)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="11"
						cMes:=OemToAnsi(STR0027)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ELSEIF SUBSTR((cAliasDIA)->RHC_ANOMES,5,2)=="12"
						cMes:=OemToAnsi(STR0028)
						oSection3:Cell("MES"):SetValue(cMes)
						oSection3:Cell("DIACOTIZADO"):SetValue((cAliasDIA)->RHC_DCOT)
						oSection3:Printline()
					ENDIF
					
					nSUMADIA += (cAliasDIA)->RHC_DCOT
					nSUMAPROMEDIO += (cAliasDIA)->RHC_DCOTP
					(cAliasDIA)->(dbskip())
					oReport:IncMeter()
					
				EndDo
			oReport:Fatline()
			oSection3:Finish()
			
			//Totales
			oSection4:Init()
				oSection4:Cell("TOTALDIAS"):Show()
				oSection4:Cell("PROMEDIODIAS"):Show()
				oSection4:Cell("NOTA"):Show()
				//inicializacion
				oSection4:Cell("TOTALDIAS"):SetValue(0)
				oSection4:Cell("PROMEDIODIAS"):SetValue(0)
				oSection4:Cell("TOTALDIAS"):SetValue(nSUMADIA)//"Total de dias trabajados"
				oSection4:Cell("PROMEDIODIAS"):SetValue(nSUMAPROMEDIO) //"prodemio de trabajadores expuestos al riesgo"
				oSection4:Cell("NOTA"):SetValue()
			oSection4:PrintLine()
			oSection4:Finish()
			
		oReport:EndPage() //-- Salta Pagina	 
EndDo
(cAliasDIA)->(dbCloseArea())
Return ( Nil )