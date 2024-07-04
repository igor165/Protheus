#INCLUDE "PROTHEUS.ch"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "report.ch"
#INCLUDE "GPER887.CH"



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³GPER887³ Autor ³  Luis EnrÍquez                              ³ Data ³ 17/04/2021    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ INFORMACIÓN DE RENTAS DE TRABAJO Y PENSIONES                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GPER887()                                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Peru                                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                       ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data      ³ Issue      ³  Motivo da Alteracao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³           ³            ³                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER887()
	Local aArea     := GetArea()
	Local lRet      := .F.
	Local lFaltaCpos:= .F.

	Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
	Private nLastKey 	:= 0
	Private cPerg       := "GPER887"
	Private oReport     := NIL
	Private lAuto       := IsBlind()

	//Códigos para conceptos
	Private cSalario   := ""
	Private cEmolumen  := ""
	Private cHonorario := ""
	Private cServicio  := ""
	Private cComision  := ""
	Private cPrestacio := ""
	Private cViaticos  := ""
	Private cGastos    := ""
	Private cCompensa  := ""
	Private cOtrosPag  := ""
	Private cCesantia  := ""
	Private cPensiones := ""
	Private cTIngresos := ""
	Private cASalud    := ""
	Private cAFondos   := ""
	Private cCVolReg   := ""
	Private cAVolunta  := ""
	Private cACtaAFC   := ""
	Private cACtaAVC   := ""
	Private cRetencion := ""
	Private cBonos     := ""
	Private cApoyos    := ""
	Private cAlimen1   := ""
	Private cAlimen2   := ""

	Private cAno       := ""
	Private cConsec    := ""
	Private cCodCpt    := ""
	Private nTipoArc   := 1
	Private cXML       := ""
	Private dFecha     := Stod(" / / ")
	Private cFecha     := ""
	Private aMsgs  	   := {}

	Private aEmpleado  := {}
	Private nOpcImp    := 1 
	Private nCount	   := 0

	If Pergunte(cPerg,.T.)

		//Parámetros
		//MV_PAR01 = ¿Año a reportar?
		//MV_PAR02 = ¿Matrículas?
		//MV_PAR03 = ¿Número de envío?
		//MV_PAR04 = ¿Reemplazo?
		//MV_PAR05 = ¿Fecha Envío?
		//MV_PAR06 = ¿Tipo de Salida? 
		//MV_PAR07 = ¿Ruta XML?

		cAno     := MV_PAR01 //Año
		cConsec  := MV_PAR03 //Consecutivo por año
		cCodCpt  := IIf(MV_PAR04 == 1,"2","1") //"2" Si es reemplazo "1" Si NO es un reemplazo
		dFecha   := Stod(cAno + "1231")
		cFecha   := SUBSTR(CMONTH(dFecha), 1, 3) + "-" + Padl(AllTrim(Str(DAY(dFecha))),2,'0') + "-" + AllTrim(Str(YEAR(dFecha)))
		nTipoArc := MV_PAR06

		If nTipoArc == 1
			If !lAuto
				Processa({|lEnd| lRet := GPR887CONC()},STR0024) //"Obteniendo configuración de la tabla S092 - 2276 INF. RENTA DE TRAB Y PENS..."
				Processa({|lEnd| lRet := GPR887TMP()} ,STR0025) //"Acumulando valores por conceptos..."
			Else
				GPR887CONC()
				GPR887TMP()
			EndIf

			lFaltaCpos := GPR887VAL(@aMsgs)
			If !lFaltaCpos
				If !lAuto
						Processa({|lEnd| lRet := GPR887XML(@cXML)},STR0027) //"Creando estructura del XML..."				
				Else
					GPR887XML(@cXML)
				EndIf
			EndIf
			If !Empty(cXML) .And. lRet .And. nCount > 0
				If Empty(MV_PAR07)
					If !lAuto
						MsgAlert(STR0034) //"Es necesario informar la ruta donde será almacenado el archivo XML, del formato 2276 - Información de Rentas de Trabajo y Pensiones."
					Else
						Conout(STR0034) //"Es necesario informar la ruta donde será almacenado el archivo XML, del formato 2276 - Información de Rentas de Trabajo y Pensiones."
					EndIf
				Else
					cArcNom := "Dmuisca_" + ;
					Padl(AllTrim(cCodCpt),2,'0') + ;      //02 Si es reemplazo, 01 si NO es reemplazo
					"02276" + ;                           //Código de Formato
					"03" + ;                              //Versión
					cAno + ;                              //Año de envío
					Padl(AllTrim(Str(cConsec)),8,'0') + ; //Consecutivo de año por envío
					".xml"
					If !lAuto
						Processa({|lEnd| lRet := GPR887CARC(cXML,cArcNom,MV_PAR07)},STR0028) //"Guardando archivo XML..."
					Else
						GPR887CARC(cXML,cArcNom,MV_PAR07)
					EndIf
				EndIf
			EndIf		
		Else	
			oReport := ReportDef()
			oReport:PrintDialog()
		EndIf
	EndIf

	RestArea( aArea )
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³ReportDef ³ Autor ³ Luis EnrÍquez         ³ Data ³ 09/04/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. del reporte y defincion de secciones del reporte.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ReportDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER887                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
	Local aArea     := GetArea()	
	Local cTitulo   := OemToAnsi(STR0001) //"2276 Info de Rtas Trab y Pen"
	Local cDesc     := OemToAnsi(STR0002) //"2276 - Información de rentas de trabajo y pensiones"
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local nTamImp   := 18
	Local cPicture  := "@E 999,999,999,999,999,999.99"

	oReport := TReport():New("GPER887", cTitulo ,cPerg, {|oReport| PrintReport(oReport)}, cDesc)

	nOpcImp := oReport:nDevice //Opción de impresión del informe, opciones: 1-Archivo, 2-Impressora,3-Email,4-Planilla, 5-Html y 6-PDF

	oSection1 := TRSection():New(oReport,"","")	 
	oSection1:SetHeaderPage(.T.)
	oSection1:SetReadOnly() 
	TRCell():New(oSection1,"CEDNIT"	  ,"cArqTmp",STR0003,/*Picture*/,nTamImp,/*lPixel*/,/*{|| }*/)	//"Cédula/NIT"
	If nOpcImp == 4
		TRCell():New(oSection1,"PRNOM"	  ,"cArqTmp",STR0004,/*Picture*/,nTamImp,/*lPixel*/,/*{|| }*/)	//"Nombre"
		TRCell():New(oSection1,"SEGNOM"	  ,"cArqTmp",""     ,/*Picture*/,nTamImp,/*lPixel*/,/*{|| }*/)	
		TRCell():New(oSection1,"APPAT"	  ,"cArqTmp",""     ,/*Picture*/,nTamImp,/*lPixel*/,/*{|| }*/)	
		TRCell():New(oSection1,"APMAT"	  ,"cArqTmp",""     ,/*Picture*/,nTamImp,/*lPixel*/,/*{|| }*/)	
		TRCell():New(oSection1,"CODMUN"   ,"cArqTmp",STR0030,/*Picture*/,nTamImp,/*lPixel*/,/*{|| }*/) //"Municipio"
		TRCell():New(oSection1,"NOMMUN"	  ,"cArqTmp",""     ,/*Picture*/,nTamImp,/*lPixel*/,/*{|| }*/)
	Else
		TRCell():New(oSection1,"PRNOM"	  ,"cArqTmp",STR0004,/*Picture*/,100,/*lPixel*/,/*{|| }*/)	//"Nombre"
		TRCell():New(oSection1,"CODMUN"   ,"cArqTmp",STR0030,/*Picture*/,60,/*lPixel*/,/*{|| }*/) //"Municipio"
	EndIf
	
	oSection2 := TRSection():New(oReport,"","")	
	oSection2:SetHeaderPage(.T.)
	oSection2:SetReadOnly()
	TRCell():New(oSection2,"SALARIO"	 ,"cArqTmp",STR0005,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")  //"Pagos"
	TRCell():New(oSection2,"EMOLUMEN"    ,"cArqTmp",STR0006,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Emolumentos"
	TRCell():New(oSection2,"HONORARIOS"	 ,"cArqTmp",STR0007,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Honorarios"
	TRCell():New(oSection2,"SERVICIO"	 ,"cArqTmp",STR0008,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Servicios"
	TRCell():New(oSection2,"COMISIONES"	 ,"cArqTmp",STR0009,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Comisiones"
	TRCell():New(oSection2,"PRESTACIONES","cArqTmp",STR0010,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Prestaciones"
	TRCell():New(oSection2,"VIATICOS"	 ,"cArqTmp",STR0011,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Viáticos"
	TRCell():New(oSection2,"GASTOS"  	 ,"cArqTmp",STR0012,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Representación"
	TRCell():New(oSection2,"COMPENSA"	 ,"cArqTmp",STR0013,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Compensaciones"
	TRCell():New(oSection2,"OTROS"	     ,"cArqTmp",STR0014,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Otros Pagos"
	TRCell():New(oSection2,"BONOS"	     ,"cArqTmp",STR0015,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Bonos Electrónicos"

	oSection3 := TRSection():New(oReport,"","")	
	oSection3:SetHeaderPage(.T.)
	oSection3:SetReadOnly()
	TRCell():New(oSection3,"CESANTIA" ,"cArqTmp",STR0016,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")  //"Cesantías"
	TRCell():New(oSection3,"PENSIONES","cArqTmp",STR0017,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Jubilación"
	TRCell():New(oSection3,"TOTAL"    ,"cArqTmp",STR0018,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Total"
	TRCell():New(oSection3,"ASALUD"	  ,"cArqTmp",STR0019,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Salud"   
	TRCell():New(oSection3,"AFONDOS"  ,"cArqTmp",STR0020,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"AFP-FSP" 
	TRCell():New(oSection3,"AVOLUNTA" ,"cArqTmp",STR0021,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Pensión Vol." 
	TRCell():New(oSection3,"ACTAAFC"  ,"cArqTmp",STR0022,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"AFC"
	TRCell():New(oSection3,"RETENCION","cArqTmp",STR0023,cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"Retención"    
	TRCell():New(oSection3,"VACIO1"   ,"cArqTmp","",cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//"" 
	TRCell():New(oSection3,"VACIO2"   ,"cArqTmp","",cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//""
	TRCell():New(oSection3,"VACIO3"   ,"cArqTmp","",cPicture,nTamImp,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")	//""                                            
	
	RestArea(aArea)
Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³PrintReport ³ Autor ³ Luis EnrÍquez       ³ Data ³ 09/04/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para imprimir el reporte.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ReportDef                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER887                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport)
	Local aArea     := GetArea()
	Local cArcNom   := ""
	Local nX        := 0
	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(2)
	Local oSection3	:= oReport:Section(3)
	Local lRet      := .F.
	Local nTotal    := 0
	Local lFaltaCpos:= .F.

	If !lAuto
		Processa({|lEnd| lRet := GPR887CONC()},STR0024) //"Obteniendo configuración de la tabla S092 - 2276 INF. RENTA DE TRAB Y PENS..."
		Processa({|lEnd| lRet := GPR887TMP()} ,STR0025) //"Acumulando valores por conceptos..."
	Else
		GPR887CONC()
		GPR887TMP()
	EndIf

	oReport:SetCustomText( {|| GPR887ENC(STR0026 + cAno,cFecha)}) //"INFORMACIÓN DE RENTAS DE TRABAJO Y PENSIONES "

	//Informe
	oSection1:Init()
	oSection2:Init()
	oSection3:Init()
	For nX:=1 To Len(aEmpleado)
		nTotal := NoRound(aEmpleado[nX][12],0) + NoRound(aEmpleado[nX][13],0) + NoRound(aEmpleado[nX][14],0) + NoRound(aEmpleado[nX][15],0) + NoRound(aEmpleado[nX][16],0) + NoRound(aEmpleado[nX][17],0) + ;
		          NoRound(aEmpleado[nX][18],0) + NoRound(aEmpleado[nX][19],0) + NoRound(aEmpleado[nX][20],0) + NoRound(aEmpleado[nX][21],0) + NoRound(aEmpleado[nX][32],0) + NoRound(aEmpleado[nX][22],0) + NoRound(aEmpleado[nX][23],0)
		oSection1:Cell("CEDNIT"):SetValue( { || aEmpleado[nX][3] } )
		If (nOpcImp == 4) //Opción de impresión - Planilla
			oSection1:Cell("PRNOM"):SetValue( { || aEmpleanTotaldo[nX][6] } )
			oSection1:Cell("SEGNOM"):SetValue( { || aEmpleado[nX][7] } )
			oSection1:Cell("APPAT"):SetValue( { || aEmpleado[nX][4] } )
			oSection1:Cell("APMAT"):SetValue( { || aEmpleado[nX][5] } )
			oSection1:Cell("CODMUN"):SetValue( { || aEmpleado[nX][9] + aEmpleado[nX][10]} )
			oSection1:Cell("NOMMUN"):SetValue( { || aEmpleado[nX][40] } )
		Else
			oSection1:Cell("PRNOM"):SetValue( { || aEmpleado[nX][6] + " " + aEmpleado[nX][7] + " " + aEmpleado[nX][4] + " " + aEmpleado[nX][5] } )
			oSection1:Cell("CODMUN"):SetValue( { || aEmpleado[nX][9] + aEmpleado[nX][10] + " " + aEmpleado[nX][40]} )
		EndIf
	
		oSection1:PrintLine()

		oSection2:Cell("SALARIO"):SetValue( { || NoRound(aEmpleado[nX][12],0) } )
		oSection2:Cell("EMOLUMEN"):SetValue( { || NoRound(aEmpleado[nX][13],0) } )
		oSection2:Cell("HONORARIOS"):SetValue( { || NoRound(aEmpleado[nX][14],0) } )
		oSection2:Cell("SERVICIO"):SetValue( { || NoRound(aEmpleado[nX][15],0) } )
		oSection2:Cell("COMISIONES"):SetValue( { || NoRound(aEmpleado[nX][16],0) } )
		oSection2:Cell("PRESTACIONES"):SetValue( { || NoRound(aEmpleado[nX][17],0) } )
		oSection2:Cell("VIATICOS"):SetValue( { || NoRound(aEmpleado[nX][18],0) } )
		oSection2:Cell("GASTOS"):SetValue( { || NoRound(aEmpleado[nX][19],0) } )
		oSection2:Cell("COMPENSA"):SetValue( { || NoRound(aEmpleado[nX][20],0) } )
		oSection2:Cell("OTROS"):SetValue( { || NoRound(aEmpleado[nX][21],0) } )
		oSection2:Cell("BONOS"):SetValue( { || NoRound(aEmpleado[nX][32],0) } )

		oSection2:PrintLine()

		oSection3:Cell("CESANTIA"):SetValue( { || NoRound(aEmpleado[nX][22],0) } )
		oSection3:Cell("PENSIONES"):SetValue( { || NoRound(aEmpleado[nX][23],0) } )
		oSection3:Cell("TOTAL"):SetValue( { || NoRound(nTotal,0) } ) 
		oSection3:Cell("ASALUD"):SetValue( { || NoRound(aEmpleado[nX][25],0) } )
		oSection3:Cell("AFONDOS"):SetValue( { || NoRound(aEmpleado[nX][26],0) } )
		oSection3:Cell("AVOLUNTA"):SetValue( { || NoRound(aEmpleado[nX][28],0) } )
		oSection3:Cell("ACTAAFC"):SetValue( { || NoRound(aEmpleado[nX][29],0) } )
		oSection3:Cell("RETENCION"):SetValue( { || NoRound(aEmpleado[nX][31],0) } )

		oSection3:PrintLine()
	Next nX

	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()

	//Generación de archivo XML
	If MV_PAR06 == 1 .Or. MV_PAR06 == 3
		
		lFaltaCpos := GPR887VAL(@aMsgs)
		If !lFaltaCpos
			If !lAuto
					Processa({|lEnd| lRet := GPR887XML(@cXML)},STR0027) //"Creando estructura del XML..."				
			Else
				GPR887XML(@cXML)
			EndIf
		EndIf
		If !Empty(cXML) .And. lRet .And. nCount >0
			If Empty(MV_PAR07)
				If !lAuto
					MsgAlert(STR0034) //"Es necesario informar la ruta donde será almacenado el archivo XML, del formato 2276 - Información de Rentas de Trabajo y Pensiones."
				Else
					Conout(STR0034) //"Es necesario informar la ruta donde será almacenado el archivo XML, del formato 2276 - Información de Rentas de Trabajo y Pensiones."
				EndIf
			Else
				cArcNom := "Dmuisca_" + ;
				Padl(AllTrim(cCodCpt),2,'0') + ;       //02 Si es reemplazo, 01 si NO es reemplazo
				"02276" + ;                           //Código de Formato
				"03" + ;                              //Versión
				cAno + ;                              //Año de envío
				Padl(AllTrim(Str(cConsec)),8,'0') + ; //Consecutivo de año por envío
				".xml"
				If !lAuto
					Processa({|lEnd| lRet := GPR887CARC(cXML,cArcNom,MV_PAR07)},STR0028) //"Guardando archivo XML..."
				Else
					GPR887CARC(cXML,cArcNom,MV_PAR07)
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} GPR887TMP
(Concentrado de información por empleado para el formato 2267)
@type function
@author luis.enríquez
@since 18/04/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GPR887TMP()
	Local aArea      := GetArea()
	Local cAliasTmp  := GetNextAlias()
	Local cFilSQLSRC := ""
	Local cEmp       := ""
	Local nPos       := 0
	Local cTpDoc     := ""
	Local cFilCC2    := xFilial("CC2")
	Local cNomMun    := ""

	//Transforma los parámetros de tipo rango en expresión ADVPL para ser utilizados en los filtros
	makesqlExpr(cPerg)

	//-- Tratamiento parametros Rango
	cFilSQLSRC := "% "
	If !Empty(MV_PAR02) //-- Matrícula
		cFilSQLSRC += " AND " + MV_PAR02
	EndIf
	cFilSQLSRC += " %"

	BeginSql alias cAliasTmp
		SELECT RD_FILIAL, RD_MAT, RD_PD, RD_DATARQ, RD_VALOR, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, ;
		RA_ENDEREC, RA_RG, RA_TPCIC, RA_MUNICIP, RA_ESTADO
		FROM %table:SRD% SRD
		INNER JOIN %table:SRA% SRA
		ON SRD.RD_MAT = SRA.RA_MAT
		WHERE SRD.RD_FILIAL = %exp:xFilial("SRD")% AND
				YEAR(RD_DATPGT) = %exp:cAno% AND 
				SRD.%notDel%	
				%exp:cFilSQLSRC%								
		ORDER BY RD_MAT, RD_PD
	EndSql

	count to nCount

	If nCount == 0
		If !lAuto
			MsgAlert(STR0033) //"No se encontraron registros en el Historial de Movimientos (SRD), para los parámetros informados."
		Else
			Conout(STR0033) //"No se encontraron registros en el Historial de Movimientos (SRD), para los parámetros informados."
		EndIf
	Else
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(dbGoTop())

		dbSelectArea("CC2")
		CC2->(dbSetOrder(3)) //CC2_FILIAL + CC2_CODMUN

		While (cAliasTmp)->(!Eof())
			IncProc(STR0029 + Alltrim((cAliasTmp)->RD_MAT)) //"Procesando empleado"
			If (cAliasTmp)->RD_MAT != cEmp
				CC2->(dbGoTop())
				If CC2->(MsSeek( cFilCC2 + (cAliasTmp)->RA_MUNICIP, .T. ))
					cNomMun := CC2->CC2_MUN
				Else	
					cNomMun := ""
				EndIf
				cTpDoc := GPR887RCC("S022",(cAliasTmp)->RA_TPCIC,1,2,38,2)
				aAdd(aEmpleado, {"1", ;              //1. Atributo entinfo
				cTpDoc, ;                            //2. Atributo tdocb
				(cAliasTmp)->RA_RG , ;               //3. Atributo nitb
				Alltrim((cAliasTmp)->RA_PRISOBR), ;  //4. Atributo pap
				Alltrim((cAliasTmp)->RA_SECSOBR), ;  //5. Atributo sap
				Alltrim((cAliasTmp)->RA_PRINOME), ;  //6. Atributo pno
				Alltrim((cAliasTmp)->RA_SECNOME), ;  //7. Atributo ono
				Alltrim((cAliasTmp)->RA_ENDEREC), ;  //8. Atributo dir
				Alltrim((cAliasTmp)->RA_ESTADO),   ; //9. Atributo dpto
				RIGHT((cAliasTmp)->RA_MUNICIP, 3), ; //10. Atributo mun
				"169", ;                             //11. Atributo pais
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, ;
				"", ;                                //36. Atributo identfc
				"", ;                                //37. Atributo tdocpcc
				"", ;                                //38. Atributo nitpcc
				"2", ;                               //39. Atributo depec
				cNomMun,;                            //40. Nombre del Municipio
				Alltrim((cAliasTmp)->RD_MAT)})       //41. Matricula del Empleado

				cEmp := (cAliasTmp)->RD_MAT
				nPos += 1
			EndIf

			If (cAliasTmp)->RD_PD $ cSalario       //12. Atributo pasa
				aEmpleado[nPos][12] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cEmolumen  //13. Atributo paec
				aEmpleado[nPos][13] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cHonorario //14. Atributo paho
				aEmpleado[nPos][14] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cServicio  //15. Atributo pase
				aEmpleado[nPos][15] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cComision  //16. Atibuto paco
				aEmpleado[nPos][16] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cPrestacio //17. Atributo papre
				aEmpleado[nPos][17] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cViaticos  //18. Atributo pavia
				aEmpleado[nPos][18] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cGastos    //19. Atributo paga
				aEmpleado[nPos][19] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cCompensa  //20. Atributo patra
				aEmpleado[nPos][20] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cOtrosPag  //21. Atributo potro
				aEmpleado[nPos][21] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cCesantia  //22. Atributo cein
				aEmpleado[nPos][22] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cPensiones //23. Atributo peju
				aEmpleado[nPos][23] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cTIngresos //24. Atributo tingbtp
				aEmpleado[nPos][24] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cASalud    //25. Atributo apos
				aEmpleado[nPos][25] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cAFondos   //26. Atributo apof
				aEmpleado[nPos][26] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cCVolReg   //27. Atributo cvrais
				aEmpleado[nPos][27] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cAVolunta  .Or. (cAliasTmp)->RD_PD $ cACtaAFC  
				If (cAliasTmp)->RD_PD $ cAVolunta //28. Atributo apov
					aEmpleado[nPos][28] += (cAliasTmp)->RD_VALOR
				EndIf
				If (cAliasTmp)->RD_PD $ cACtaAFC //29. Atributo apafc
					aEmpleado[nPos][29] += (cAliasTmp)->RD_VALOR
				EndIf
			ElseIf (cAliasTmp)->RD_PD $ cACtaAVC  //30. Atributo apavc
				aEmpleado[nPos][30] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cRetencion //31. Atributo vare
				aEmpleado[nPos][31] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cBonos     //32. Atributo pabo
				aEmpleado[nPos][32] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cApoyos //33. Atributo apecofpe
				aEmpleado[nPos][33] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cAlimen1 //34. Atributo pagamuvt
				aEmpleado[nPos][34] += (cAliasTmp)->RD_VALOR
			ElseIf (cAliasTmp)->RD_PD $ cAlimen2 //35. Atributo pagahuvt
				aEmpleado[nPos][35] += (cAliasTmp)->RD_VALOR
			EndIf 


			(cAliasTmp)->(dbSkip())
		EndDo
	EndIf

	//Cierre de tablas temporales
	(cAliasTmp)->(dbCloseArea())

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} GPR887XML
(Armado de estructura del XML del formato 2267)
@type function
@author luis.enríquez
@since 18/04/2021
@version 1.0
@param cXML, character, (Actualización de estructura del XML para el formato 2276)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GPR887XML(cXML)	
	Local cCRLF	  := (chr(13)+chr(10))
	Local nI      := 0
	
	Local cFechaI := cAno + "-01-01"
	Local cFechaF := cAno + "-12-31"
	Local cFecEnv :=  AllTrim(Str(YEAR(MV_PAR05))) + "-" + Padl(AllTrim(Str(MONTH(MV_PAR05))),2,'0') + "-" +;
			        Padl(AllTrim(Str(DAY(MV_PAR05))),2,'0')

	cXML := '<?xml version="1.0" encoding="ISO-8859-1"?>' + cCRLF
	cXML += '<mas xsi:noNamespaceSchemaLocation="2276.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + cCRLF
	cXML += '	<Cab>' + cCRLF
	cXML += '		<Ano>' + cAno +'</Ano>' + cCRLF
	cXML += '		<CodCpt>' + cCodCpt + '</CodCpt>' + cCRLF
	cXML += '		<Formato>2276</Formato>' + cCRLF
	cXML += '		<Version>3</Version>' + cCRLF
	cXML += '		<NumEnvio>' + AllTrim(Str(cConsec)) + '</NumEnvio>' + cCRLF
	cXML += '		<FecEnvio>' + cFecEnv + 'T' + Time() + '</FecEnvio>' + cCRLF //Formato AAAA-MM-DDTHH:MM:SS
	cXML += '		<FecInicial>' + cFechaI + '</FecInicial>' + cCRLF
	cXML += '		<FecFinal>' + cFechaF + '</FecFinal>' + cCRLF
	cXML += '		<ValorTotal>31</ValorTotal>' + cCRLF
	cXML += '		<CantReg>' + Alltrim(Str(Len(aEmpleado))) + '</CantReg>' + cCRLF
	cXML += '	</Cab>' + cCRLF

	For nI:=1 To Len(aEmpleado)
		cXML += '	<rentra entinfo="' + Alltrim(aEmpleado[nI][1]) + '" tdocb="' + Alltrim(aEmpleado[nI][2]) + '" nitb="' + Alltrim(aEmpleado[nI][3]) + '" pap="' + Alltrim(aEmpleado[nI][4]) + '" sap="' + Alltrim(aEmpleado[nI][5]) + '" pno="' + Alltrim(aEmpleado[nI][6]) + '" ono="' + Alltrim(aEmpleado[nI][7]) + '" dir="' + Alltrim(aEmpleado[nI][8]) + '" dpto="' + Alltrim(aEmpleado[nI][9]) + '" mun="' + Alltrim(aEmpleado[nI][10]) + '" pais="' + Alltrim(aEmpleado[nI][11]) + '"' + cCRLF
		cXML += '    pasa="' + Alltrim(Str(NoRound(aEmpleado[nI][12],0))) + '" paec="' + Alltrim(Str(NoRound(aEmpleado[nI][13],0))) + '" paho="' + Alltrim(Str(NoRound(aEmpleado[nI][14],0))) + '" pase="' + Alltrim(Str(NoRound(aEmpleado[nI][15],0))) + '" paco="' + Alltrim(Str(NoRound(aEmpleado[nI][16],0))) + '" papre="' + Alltrim(Str(NoRound(aEmpleado[nI][17],0))) + '" pavia="' + Alltrim(Str(NoRound(aEmpleado[nI][18],0))) + '"' + cCRLF
		cXML += '    paga="' + Alltrim(Str(NoRound(aEmpleado[nI][19],0))) + '" patra="' + Alltrim(Str(NoRound(aEmpleado[nI][20],0))) + '" potro="' + Alltrim(Str(NoRound(aEmpleado[nI][21],0))) + '" cein="' + Alltrim(Str(NoRound(aEmpleado[nI][22],0))) + '" peju="' + Alltrim(Str(NoRound(aEmpleado[nI][23],0))) + '" tingbtp ="' + Alltrim(Str(NoRound(aEmpleado[nI][24],0))) + '" apos="' + Alltrim(Str(NoRound(aEmpleado[nI][25],0))) + '" apof="' + Alltrim(Str(NoRound(aEmpleado[nI][26],0))) + '" cvrais="' + Alltrim(Str(NoRound(aEmpleado[nI][27],0))) + '"' + cCRLF
		cXML += '    apov="' + Alltrim(Str(NoRound(aEmpleado[nI][28],0))) + '" apafc="' + Alltrim(Str(NoRound(aEmpleado[nI][29],0))) + '" apavc="' + Alltrim(Str(NoRound(aEmpleado[nI][30],0))) + '" vare="' + Alltrim(Str(NoRound(aEmpleado[nI][31],0))) + '" pabo="' + Alltrim(Str(NoRound(aEmpleado[nI][32],0))) + '" apecofpe="' + Alltrim(Str(NoRound(aEmpleado[nI][33],0))) + '" pagamuvt="' + Alltrim(Str(NoRound(aEmpleado[nI][34],0))) + '" pagahuvt="' + Alltrim(Str(NoRound(aEmpleado[nI][35],0))) + '" identfc="' + Alltrim(aEmpleado[nI][36]) + '" tdocpcc="' + Alltrim(aEmpleado[nI][37]) + '" nitpcc="' + Alltrim(aEmpleado[nI][38]) + '" depec="' + Alltrim(aEmpleado[nI][39]) + '"/>' + cCRLF
	Next nI
	cXML += '</mas>'
Return .T.

/*/{Protheus.doc} GPR887CARC
(Función que escribe el archivo XML en una ruta especifíca)
@type function
@author luis.enríquez
@since 18/04/2021
@version 1.0
@param cTexto, character, (contenido del archivo a escribir)
@param cNomArc, character, (nombre y extensión del archivo a escribir)
@param cPathFile, character, (ruta donde será creado el archivo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GPR887CARC(cTexto, cNomArc, cPathFile)
	Local nHandle := 0
	Local cRuta   := ""

	cRuta := cPathFile
	cPathFile := Alltrim(cPathFile) + cNomArc

	Ferase(cPathFile)
	nHandle	:=	FCreate(cPathFile)
	If nHandle == -1		
		If !lAuto
			MsgAlert(StrTran(STR0031, '###', cPathFile) + STR(FERROR())) //"No fue posible crear el archivo XML: ### error: "
		Else
			Conout(StrTran(STR0031, '###', cPathFile) + STR(FERROR())) //"No fue posible crear el archivo XML: ### error: "
		EndIf
	Else
		FWrite(nHandle,cTexto)
		If !lAuto
			MsgInfo(StrTran(STR0032, '###', cNomArc) + cRuta) //"El archivo ### ha sido creado en la ruta: "
		Else
			Conout(StrTran(STR0032, '###', cNomArc) + cRuta) //"El archivo ### ha sido creado en la ruta: "
		EndIf
	EndIf
	FClose(nHandle)
Return .T.

/*/{Protheus.doc} GPR887CONC
(Actualiza variables con la configuración de conceptos para la estructura de importes)
@type function
@author luis.enríquez
@since 18/04/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GPR887CONC()
	Local nPosIni := 1
	Local nPosFin := 15
	Local nRetIni := 064
	Local nRetFin := 187

	cSalario   := GPR887RCC("S092","SALARIO",nPosIni,nPosFin,nRetIni,nRetFin)
	cEmolumen  := GPR887RCC("S092","EMOLUMENTO",nPosIni,nPosFin,nRetIni,nRetFin)
	cHonorario := GPR887RCC("S092","HONORARIOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cServicio  := GPR887RCC("S092","SERVICIOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cComision  := GPR887RCC("S092","COMISIONES",nPosIni,nPosFin,nRetIni,nRetFin)
	cPrestacio := GPR887RCC("S092","PRESTACIONES",nPosIni,nPosFin,nRetIni,nRetFin)
	cViaticos  := GPR887RCC("S092","VIATICOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cGastos    := GPR887RCC("S092","GASTOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cCompensa  := GPR887RCC("S092","COMPENSA",nPosIni,nPosFin,nRetIni,nRetFin)
	cOtrosPag  := GPR887RCC("S092","OTROS",nPosIni,nPosFin,nRetIni,nRetFin)
	cBonos     := GPR887RCC("S092","BONOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cCesantia  := GPR887RCC("S092","CESANTIA",nPosIni,nPosFin,nRetIni,nRetFin)
	cPensiones := GPR887RCC("S092","PENSIONES",nPosIni,nPosFin,nRetIni,nRetFin)
	cASalud    := GPR887RCC("S092","ASALUD",nPosIni,nPosFin,nRetIni,nRetFin)
	cAFondos   := GPR887RCC("S092","AFONDOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cRetencion := GPR887RCC("S092","RETENCION",nPosIni,nPosFin,nRetIni,nRetFin)
	cTIngresos := GPR887RCC("S092","TINGRESOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cApoyos    := GPR887RCC("S092","APOYOS",nPosIni,nPosFin,nRetIni,nRetFin)
	cAlimen1   := GPR887RCC("S092","ALIMEN1",nPosIni,nPosFin,nRetIni,nRetFin)
	cAlimen2   := GPR887RCC("S092","ALIMEN2",nPosIni,nPosFin,nRetIni,nRetFin)
	cACtaAFC   := GPR887RCC("S092","ACTAAFC",nPosIni,nPosFin,nRetIni,nRetFin)
	cACtaAVC   := GPR887RCC("S092","ACTAAVC",nPosIni,nPosFin,nRetIni,nRetFin)
	cAVolunta  := GPR887RCC("S092","AVOLUNTA",nPosIni,nPosFin,nRetIni,nRetFin) + "|" + cACtaAFC
	cCVolReg   := GPR887RCC("S092","CVOLREG",nPosIni,nPosFin,nRetIni,nRetFin)
Return .T.

/*/{Protheus.doc} GPR887RCC
(Obtiene configuración de mantenimiento de tablas RCC)
@type function
@author luis.enríquez
@since 18/04/2021
@version 1.0
@param cCodigo, character, (Código de la tabla)
@param cConteudo, character, (Código de busqueda)
@param nPos1, numeric, (Número inicial para busqueda)
@param nPos2, numeric, (Número final para busqueda)
@param nPos1Ret, numeric, (Número inicial para retorno)
@param nPos2Ret, numeric, (Número final para retorno)
@return ${cValor}, ${Valor de la tabla RCC}
@example
(examples)
@see (links_or_references)
/*/
Function GPR887RCC(cCodigo,cConteudo,nPos1,nPos2,nPos1Ret,nPos2Ret)
	Local cTRB := ""
	Local cQry := ""
	Local cValor := ""
	Local lGetDB  := AllTrim(Upper(TCGetDB())) == "ORACLE"  //.T. - Oracle, .F. - Otros manejadores
	
	Default nPos1 := 0
	Default nPos2 := 0	
	
	If cCodigo <> Nil .And. cConteudo <> Nil		
		cQry := " SELECT RCC_CODIGO,RCC_SEQUEN,RCC_CONTEU "
		cQry += " FROM " + RetsqlName("RCC") + " RCC "
		cQry += " WHERE RCC_FILIAL = '" + xFilial("RCC") + "' "
		cQry += " AND RCC_CODIGO = '" + cCodigo + "' "
		If  lGetDB //Es Oracle
			cQry += " AND SUBSTR(RCC_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ") = '" + Alltrim(cConteudo) + "'			
		Else
			cQry += " AND SUBSTRING(RCC_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ") = '" + Alltrim(cConteudo) + "'	
		EndIf
		cQry +=" AND RCC.D_E_L_E_T_='' "
		
		cTRB := ChangeQuery(cQry)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRB ) ,"TRBRCC", .T., .F.)
		
		dbSelectArea( "TRBRCC" )
		TRBRCC->(dbGoTop())	
		
		While TRBRCC->(!Eof())
			If Alltrim(Substr(TRBRCC->RCC_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
				cValor := Alltrim(Substr(TRBRCC->RCC_CONTEU,nPos1Ret,nPos2Ret))
				Exit
			EndIf
			TRBRCC->(dBSkip())
		EndDo
	EndIf	

	TRBRCC->(dbCloseArea())
Return (cValor)

/*/{Protheus.doc} GPR887ENC
(Concatena datos para impresión del encabezado del informe)
@type function
@author luis.enríquez
@since 18/04/2021
@version 1.0
@param cTitulo, character, (Título del informe)
@param cFecEnc, character, (Fecha del informe - último día del año de envío)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GPR887ENC(cTitulo, cFecEnc)	
	Local aEnc := {}
	Local cChar			:= chr(160)

	aEnc := { cChar + "         " +  AllTrim(cTitulo)     + "         " + cChar;
			  , cChar + "         " + cFecEnc             + "         " + cChar }
Return aEnc 

/*/{Protheus.doc} GPR887VAL
(Valida los campos faltantes en los empleados)
@type function
@author veronica.flores
@since 08/09/2021
@version 1.0
@param aMsgs, array, (Mensaje y matricula del empleado con campos faltantes)
@return lRet , logico , (Indica si faltan campos obligatorios en el empleado)
@example
(examples)
@see (links_or_references)
/*/
Static Function GPR887VAL(aMsgs)	
	Local nI     := 0
	Local cMsg   := ""
	Local lRet	 := .F.

		For nI:=1 To Len(aEmpleado)
			If Empty(aEmpleado[nI][2])
				cMsg += STR0035 // "Tipo ID (RA_TPCIC)"
			EndIf

			If Empty(aEmpleado[nI][3])
				cMsg += STR0036 //" NIT (RA_RG)" 
			EndIf

			If Empty(aEmpleado[nI][4])
				cMsg += STR0037 // "Primer Apellido (RA_PRISOBR) "
			EndIf

			If Empty(aEmpleado[nI][6])
				cMsg += STR0038 // "Primer Nombre (RA_PRINOME) "
			EndIf	

			IF !Empty(cMsg)
				aAdd(aMsgs,{aEmpleado[nI][41],cMsg})
				cMsg :=""
			EndIf

		Next nI

		If Len(aMsgs) > 0
			GPR887Msg(aMsgs)
			lRet := .T.
		EndIf	

Return lRet

/*/{Protheus.doc} GPR887Msg
(Muestra si falta algún campo obligatorio para la generación del XML)
@type function
@author veronica.flores
@since 08/09/2021
@version 1.0
@param aMsgs, array, (Mensaje y matricula del empleado con campos faltantes)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Function GPR887Msg(aMsgs)
	Local nI       := 0
	Local oDlg     := Nil
	Local oSay     := Nil
	Local oMemo    := Nil
	Local oButton  := Nil
	Local cMsg     := ""
	Local cEnc     := ""
	Local cCRLF	   := (chr(13)+chr(10))

	If !lAuto

		CURSORWAIT()

		cEnc += StrTran( STR0039 + cCRLF + STR0040 , "###", cCRLF ) // "El archivo no se generará. ### Faltan indicar campos en los siguientes empleados"
		For nI := 1 To Len(aMsgs)
			cMsg += STR0041 + aMsgs[nI][1] + cCRLF + STR0042 + aMsgs[nI][2] + cCRLF // "Matricula: ### Campos:  "
		Next nI

		CURSORARROW()
			DEFINE MSDIALOG oDlg FROM 0,0 TO 390,440 PIXEL TITLE STR0043 //"Atención"
			oDlg:lMaximized := .F.
			oSay := TSay():New(05,05,{||OemToAnsi(cEnc)},oDlg,,,,,,.T.)
			oMemo:= tMultiget():New(20,05,{|u|IIf(Pcount() > 0, cMsg:=u, cMsg)} ,oDlg,213,155,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
			oButton := TButton():New(177, 187,STR0044,oDlg,{||oDlg:End()},30,15,,,,.T.) //"Salir"
			ACTIVATE MSDIALOG oDlg CENTERED
	Else
		ConOut(STR0039 + STR0040) // "El archivo no se generara. ### Faltan indicar campos en los siguientes empleados"
		For nI := 1 To Len(aMsgs)
			cMsg := STR0041 + aMsgs[nI][1] + " " + STR0042 + aMsgs[nI][2] // "Matricula: ### Campos:  "
			ConOut(cMsg)
		Next nI			
	EndIf

Return Nil

