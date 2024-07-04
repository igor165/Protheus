#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "GPER018MEX.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³GPER018MEX³ Autor ³ Jonathan Gonzalez     ³Fecha ³20/03/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Informe de Relacion de Casos de Riesgo de Trabajo            ³±±
±±³          ³ Terminado.                                                   ³±±
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
Function GPER018MEX()

Local		oReport   
Local		aArea		:= GetArea()
Local		lSalir		:= .F.

Private	cNomeProg	:= "GPER018MEX" //Nombre del Programa: Sera mostrado en el cuadro de dialogo de Impresion
Private	cPerg		:= cNomeProg //Nombre del grupo de preguntas.
Private	cAnio		:= "" //Anio
Private	cRegPat	:= "" //Registro Patronal
Private	cLisPat	:= "" //Lista de Registros Patronales

dbSelectArea("RIT") // tabla de Casos de Riesgo de Trabajo  
dbSelectArea("RCO") // tabla de Registro Patronal
dbSelectArea("SRA") // Tabla de empreados

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
±±³Funcion   ³ ReportDef  ³ Autor ³ Jonathan Gonzalez     ³ Data ³20/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Definicion del Informe de Relacion de Casos de Riesgo        ³±±
±±³          ³ de Trabajo Terminado.                                        ³±±
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
Local 	oSection3       

Private cTitulo := OemToAnsi(STR0003)
Private aOrd	  := {OemToAnsi(STR0004)}	//REGISTRO PATRONAL

cTitulo := Trim(cTitulo)

//Bloque de codigo para la comfirmacion de impresion
oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), CPERG ,{|oReport| PrintReport(oReport)})	
oReport:SetPortrait()     // Define a orientacao de pagina do relatorio como retrato.
oReport:nColSpace	:=1
oReport:nLineHeight	:= 40 // Define a altura da linea
oReport:cFontBody	:="COURIER NEW"
oReport:nFontBody	:= 9 // Define el tamaño de la fuente  
oReport:Setlandscape(.F.)//Pag Horizontal
oReport:SetTotalInLine(.F.)
oReport:SetDescription (OemToAnsi(STR0025))


// Primera seccion  Desc: Datos de la empresa 
oSection1:= TRSection():New(oReport,oemtoansi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderPage(.t.)	//Muestra le titulo de la seccion
oSection1:SetLineStyle(.t.)   //Pone titulo del campo y al lado el valor
oSection1:SetCharSeparator(" ")    
oSection1:SetHeaderBreak(.T.)

//Durante el periodo de 01 de enero al 31 de diciembre de 9999
TRCell():New(oSection1,"PERIODO"	,/*alias*/,STR0015,/*Picture*/,4,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection1:Cell("PERIODO"):SetCellBreak(.T.)
//REGISTRO PATRONAL
TRCell():New(oSection1,"RCO_NREPAT",/*alias*/,STR0017,PesqPict("RCO","RCO_NREPAT")	,TamSx3("RCO_NREPAT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
//DIG. VERIFICADOR
TRCell():New(oSection1,"DV"			,/*alias*/,STR0018,,9,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
// Fecha de Proceso
TRCell():New(oSection1,"FECHA_PRO"	,/*alias*/,STR0016,,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"RIGHT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
oSection1:Cell("FECHA_PRO"):SetCellBreak(.T.)
//Den. o R.S
TRCell():New(oSection1,"RCO_NOME"	,/*alias*/,STR0019,PesqPict("RCO","RCO_NOME"),TamSx3("RCO_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
// Domicilio
TRCell():New(oSection1,"DOMICILIO"	,/*alias*/,STR0020,								,50						,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
//C.P.
TRCell():New(oSection1,"RCO_CEP"	,/*alias*/,STR0022,PesqPict("RCO","RCO_CEP")	,TamSx3("RCO_CEP")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"RIGHT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/) 
oSection1:Cell("RCO_CEP"):SetCellBreak(.T.)
// Mpio./Del.
TRCell():New(oSection1,"RCO_MUNIC"	,/*alias*/,STR0021,PesqPict("RCO","RCO_MUNIC"),TamSx3("RCO_MUNIC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"RIGHT",.T./*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
// TELEFONO
TRCell():New(oSection1,"RCO_FONE"	,/*alias*/,STR0023,PesqPict("RCO","RCO_FONE")	,TamSx3("RCO_FONE")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"RIGHT",.T./*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection1:Cell("RCO_FONE"):SetCellBreak(.T.)


//Tercera Seccion     Desc: Detalles                             
oSection3:= TRSection():New(oReport,oemtoansi("DetallePrograma"),,aOrd,/*Campos do SX3* /,/*Campos do SIX*/)
oSection3:SetTotalInLine(.f.)  
oSection3:SetHeaderSection(.t.)	//Muestra le titulo de la seccion
oSection3:SetHeaderPage(.f.) //Exibe Cabecalho da Secao
oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderBreak(.T.)

//NSS
TRCell():New(oSection3,"RA_RG"	,,STR0005,PesqPict("SRA","RA_RG")		,TamSx3("RA_RG")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//CURP
TRCell():New(oSection3,"RA_CURP",,STR0006,PesqPict("SRA","RA_CURP")	,TamSx3("RA_CURP")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//NOMBRE DEL ASEGURADO
TRCell():New(oSection3,"RA_NOME",,STR0007,PesqPict("SRA","RA_NOME")	,TamSx3("RA_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//RECAIDA O REVALUACION
TRCell():New(oSection3,"RIT_REC"	,,STR0008,PesqPict("RIT","RIT_REC")	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//FECHA ACCIDENTE O ENFERMEDAD
TRCell():New(oSection3,"RIT_FECACC",,STR0009,									,13,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//TIPO DE RIESGO
TRCell():New(oSection3,"RIT_TIPRIE",,STR0010,PesqPict("RIT","RIT_TIPRIE")	,11,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//DIAS SUBSIDIADOS
TRCell():New(oSection3,"RIT_DIAS"	,,STR0011,PesqPict("RIT","RIT_DIAS")	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//PORCENTAJE DE INCAPACIDAD
TRCell():New(oSection3,"RIT_PORINC",,STR0012,PesqPict("RIT","RIT_PORINC")	,16,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//DEFUCNION (D)
TRCell():New(oSection3,"RIT_DEFUNC",,STR0013,PesqPict("RIT","RIT_DEFUNC")	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//FECHA DE ALTA
TRCell():New(oSection3,"FECHA_ALTA",,STR0014,									,10,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"LEFT",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection3:Cell("FECHA_ALTA"):SetCellBreak(.T.)


OSECTION1:NLINESBEFORE:=0
OSECTION3:NLINESBEFORE:=0

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³PrintReport ³ Autor ³ Jonathan Gonzalez     ³ Data ³20/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impresion  del Informe de Relacion de Casos de Riesgo        ³±±
±±³          ³ de Trabajo Terminado.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPE                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport)

Local oSection1  := oReport:Section(1)
Local oSection3  := oReport:Section(2)

Local cTitle			:= ""     
Local cOrdem			:= ""
Local cAliasEMP		:= "QRYEMP" 
Local cFilRIT			:= xfilial("RIT")
Local cFilRCO			:= xfilial("RCO")
Local cFilSRA			:= xfilial("SRA")
Local cCposQuery		:= ""
Local cCposFrom		:= ""
Local cWhere			:= ""
Local nCont			:= 0
Local nTamReg			:= TamSX3("RCO_CODIGO")[1]
Local cTmpRegPat		:=""
Local cTmpFilial		:=""
Local cDireccion		:=""
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para la obtencion de informacion de para la relacion de casos de riesgo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCposQuery := "% RIT_FILIAL, RCO_NREPAT, RCO_NOME, RCO_END, RCO_NUMEXT, "
	cCposQuery += "  RCO_CEP, RCO_MUNIC, RCO_FONE, RA_RG, RA_CURP, RA_NOME, "
	cCposQuery += "  RIT_CODRPA, RIT_REC, RIT_FECACC, RIT_TIPRIE, RIT_DIAS, "
	cCposQuery += "  RIT_PORINC, RIT_DEFUNC, RIT_FECALT %"
		
	cCposFrom   := "% " + RetSqlName("RIT") + " RIT, " 
	cCposFrom   +=  RetSqlName("RCO")+ " RCO, "
	cCposFrom   +=  RetSqlName("SRA")+ " SRA  %"
		
	cWhere :="%    RIT_CODRPA IN ("+CLISPAT+")" // Registro Patronal 
	cWhere +="     AND RIT_CODRPA=RCO_CODIGO"
	cWhere +="     AND RIT_CODRPA=RA_CODRPAT"
	cWhere +="     AND RCO_CODIGO=RA_CODRPAT"
	cWhere +="     AND RIT_MAT=RA_MAT"
	cWhere +="     AND RIT_OBSERV='1'"
	cWhere +="     AND RIT_ANIO='"+alltrim(str(cAnio))+"'"

	cWhere +="     AND RIT_FILIAL  ='"+cFilRIT+"'"
	cWhere +="     AND RCO_FILIAL  ='"+cFilRCO+"'"
	cWhere +="     AND RA_FILIAL	   ='"+cFilSRA+"'"
	cWhere +="		 AND RIT_FILIAL=RA_FILIAL"

    If ( TcSrvType()=="AS/400" )
		cWhere+="     AND RIT.@DELETED@  = ' ' " 
		cWhere+="     AND RCO.@DELETED@  = ' ' " 
		cWhere+="     AND SRA.@DELETED@  = ' '%" 
	ELSE 
		cWhere+="     AND RIT.D_E_L_E_T_  = ' ' " 
		cWhere+="     AND RCO.D_E_L_E_T_  = ' ' " 		
		cWhere+="     AND SRA.D_E_L_E_T_  = ' '%" 				
	ENDIF                   

	cOrdem := "%  RCO_NREPAT, RA_RG, RIT_FECACC %"
	

	BeginSql alias cAliasEMP 
		SELECT   %exp:cCposQuery%
		FROM  %exp:cCposFrom% 
		WHERE %exp:cWhere%     
		ORDER BY %exp:cOrdem%
	EndSql
	
	//Los campo tipo fecha los deje como tipo fecha, pues por query son recuperados como string
	TCSetField(cAliasEMP,"RIT_FECACC","D")
	TCSetField(cAliasEMP,"RIT_FECALT","D")
cursorarrow()	
#ELSE
	MSGERROR(OemToAnsi(STRO024))
#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia el llenado del reporte            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAliasEMP )
	count to nTotal
    oReport:SetMeter(nTotal)
    
	(cAliasEMP)->(DbGoTop())	
     
While (cAliasEMP)->(!Eof())	  
  
cDireccion := (cAliasEMP)->RCO_END +"  " +(cAliasEMP)->RCO_NUMEXT
	//Encabezado de reporte
	oSection1:Init()
		oSection1:Cell("PERIODO"):SetValue(alltrim(str(cAnio)))
		oSection1:Cell("FECHA_PRO"):SetValue(DDATABASE)
		
		oSection1:Cell("RCO_NREPAT"):SetValue(SUBSTR(ALLTRIM((cAliasEMP)->RCO_NREPAT),1,;
												   LEN(ALLTRIM((cAliasEMP)->RCO_NREPAT))-1))
												   
		oSection1:Cell("DV"):SetValue(SUBSTR(ALLTRIM((cAliasEMP)->RCO_NREPAT),;
										  LEN(ALLTRIM((cAliasEMP)->RCO_NREPAT)),;
										  LEN(ALLTRIM((cAliasEMP)->RCO_NREPAT))))
										  
		oSection1:Cell("RCO_NOME"):SetValue((cAliasEMP)->RCO_NOME)
		oSection1:Cell("DOMICILIO"):SetValue(cDireccion)
		oSection1:Cell("RCO_MUNIC"):SetValue((cAliasEMP)->RCO_MUNIC)
		oSection1:Cell("RCO_CEP"):SetValue((cAliasEMP)->RCO_CEP)
		oSection1:Cell("RCO_FONE"):SetValue((cAliasEMP)->RCO_FONE)				
	oSection1:printline()
	oReport:Fatline()
	oSection1:Finish()	

	//Datos de los empleados.
	oSection3:Init()
	cTmpRegPat := (cAliasEMP)->RCO_NREPAT
	cTmpFilial := (cAliasEMP)->RIT_FILIAL	
						
	While (cAliasEMP )->(!Eof()) .AND. cTmpRegPat == (cAliasEMP)->RCO_NREPAT .AND. cTmpFilial ==(cAliasEMP)->RIT_FILIAL
			
		oSection3:Cell("RA_RG"):SetValue((cAliasEMP)->RA_RG)
		oSection3:Cell("RA_CURP"):SetValue((cAliasEMP)->RA_CURP)
		oSection3:Cell("RA_NOME"):SetValue((cAliasEMP)->RA_NOME)
		oSection3:Cell("RIT_REC"):SetValue((cAliasEMP)->RIT_REC)
		
		oSection3:Cell("RIT_FECACC"):SetValue(SUBSTR(DTOS((cAliasEMP)->RIT_FECACC),1,4);
										+" "+SUBSTR(DTOS((cAliasEMP)->RIT_FECACC),5,2)+" "+;
										SUBSTR(DTOS((cAliasEMP)->RIT_FECACC),7,2))
		
		oSection3:Cell("RIT_TIPRIE"):SetValue((cAliasEMP)->RIT_TIPRIE)
		oSection3:Cell("RIT_DIAS"):SetValue((cAliasEMP)->RIT_DIAS)
		oSection3:Cell("RIT_PORINC"):SetValue((cAliasEMP)->RIT_PORINC)
		oSection3:Cell("RIT_DEFUNC"):SetValue((cAliasEMP)->RIT_DEFUNC)
		
		oSection3:Cell("FECHA_ALTA"):SetValue(SUBSTR(DTOS((cAliasEMP)->RIT_FECALT),1,4);
										+" "+SUBSTR(DTOS((cAliasEMP)->RIT_FECALT),5,2)+" "+;
										SUBSTR(DTOS((cAliasEMP)->RIT_FECALT),7,2))
										
		oSection3:Printline()
		
	(cAliasEMP)->(dbskip())
	oReport:IncMeter()
	EndDo	
	
	oReport:Fatline()
	oSection3:Finish()

	oReport:EndPage() //-- Salta Pagina	 
EndDo
(cAliasEMP)->(dbCloseArea())
Return ( Nil )