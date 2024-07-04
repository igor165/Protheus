#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "GPER882.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                                                     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER882   ºAutor  ³TOTVS                ºFecha ³  24/11/2017º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CERTIFICADO DE PARTICIPACION  DE UTILIDADES                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PERU                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER882()

	Private oReport	:= Nil

	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

/*/{Protheus.doc} ReportDef
	Definición del objeto del Informe personalizable y de secciones
	que serán utilizadas.

	@type  Static Function
	@author marco.rivera
	@since 20/05/2022
	@version 1.0
	@return oReport, Objeto, Objeto del informe.
	@example
	ReportDef()
/*/
Static Function ReportDef()
	
	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis Utilizadas na funcao IMPR                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private cProcedi 	:= ""
	Private cMes 	  	:= ""
	Private cAno 	  	:= ""
	Private cOrdem 		:= ""
	Private cSemana		:= ""
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros                         ³
	³ mv_par01        //  Procesos                                 ³
	³ mv_par02        //  Procedimiento                            ³
	³ mv_par03        //  Periodo                                  ³
	³ mv_par04        //  Numero de Pago                           ³
	³ mv_par05        //  Sucursales                               ³
	³ mv_par06        //  Centros de Costo                         ³
	³ mv_par07        //  Matrícula                                ³
	³ mv_par08        //  Nombre                                   ³
	³ mv_par09        //  Placa                                    ³
	³ mv_par10        //  Situación                                ³
	³ mv_par11        //  Categoría                                ³
	³ mv_par12        //  Área                                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	oReport := TReport():New("GPER882", STR0001, "GPER882",{|oReport| IMPGPER882()},"") //"Liquidación de Distribución de Utilidades"

	oSection1 := TRSection():New(oReport,"","")
	oSection2 := TRSection():New(oSection1,"", "")

	oSection3 := TRSection():New(oSection2, "")
	oSection4 := TRSection():New(oSection3, "")
	oSection5 := TRSection():New(oSection4, "")

	oSection1:PrintLine()
	oSection2:PrintLine()
	oSection3:PrintLine()
	oSection4:PrintLine()
	oSection5:PrintLine()

Return oReport

/*/{Protheus.doc} PrintReport
	Impresión de información.

	@type  Static Function
	@author marco.rivera
	@since 20/05/2022
	@version 1.0
	@param oReport, Objeto, Objeto del informe.
	@example
	PrintReport(oReport)
/*/
Static Function PrintReport(oReport)
	
	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(1):Section(1)
	Local oSection3 	:= oReport:Section(1):Section(1):Section(1)
	Local oSection4 	:= oReport:Section(1):Section(1):Section(1):Section(1)
	Local cNOmbre		:= ""
	Local nX			:= 10
	Local cPicture		:= "@E 99,999,999,999.99"
	Local cDestReman	:= SuperGetMV("MV_REMDEST", .F., "FONDOCALPROEM") //Parámetro para indicar la organización, fondo, etc. destino del remanente.

	Private cacti		:= ""
	Private cRenta		:= ""
	Private cRentaporc	:= ""
	Private cdiastot	:= ""
	Private cArquivo	:= "firmarep.bmp" //Nombre del archivo Bitmap(BMP) que será impreso en la primera página.

	oReport:StartPage()

	oFont09		:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont12n	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)

	cacti		:= fTabela( "S014", 01, 1)
	cRenta		:= fTabela( "S004", 01, 5)
	cRentaPorc	:= fTabela( "S004", 1, 6)
	cMonto		:= fTabela( "S004", 1, 8)
	cdiastot	:= fTabela( "S004", 1, 7)

	oSection1:Init()
	nlin := 350
	ncolmax := 2100
	oSection1:Say( nlin, 600,STR0002, oFont12n ) //"LIQUIDACION DE DISTRIBUCION DE UTILIDADES"
	nlin+=150
	cNOmbre := AllTrim((cAliasX)->RA_PRISOBR) + " " + AllTrim((cAliasX)->RA_SECSOBR) + " " + AllTrim((cAliasX)->RA_PRINOME) + " " + AllTrim((cAliasX)->RA_SECNOME)
	oSection1:Say( nlin, 080, STR0003 + cNombre + STR0004 + AllTrim((cAliasX)->RA_CIC) + ", " + STR0005 + AllTrim(SM0->M0_NOMECOM) + ", " , oFont10 ) //"Señor(a) " - " con número de identificación " - " la empresa "
	nlin+=50
	oSection1:Say( nlin, 080, STR0006 + AllTrim(SM0->M0_CGC) + STR0007 + AllTrim(SM0->M0_ENDENT) + STR0008 + AllTrim(cacti), oFont10 ) //"con RUC no. " - "domiciliado en " - " dedicada a la actividad "
	nlin+=50
	oSection1:Say( nlin, 080, STR0009 + UPPER(cNomeRep), oFont10 ) //"debidamente representado por "
	nlin+=50
	oSection1:Say( nlin, 080, STR0010 + AllTrim(STR(cRenta)) + STR0011 + Alltrim(STR(cRentaPorc)) + " %", oFont10 ) //"ha obtenido una renta anual antes de impuestos ascendente al monto " - ". De dicho monto, le correponde distribuir el porcentaje de "
	nlin+=50
	oSection1:Say( nlin, 080, STR0012, oFont10 ) //"con respecto a lo establecido en el artículo 2° del decreto Legislativo N° 892 y el D.S. N° 009-98-TR. El cálculo de la partición de utilidades"
	nlin+=50
	oSection1:Say( nlin, 080, STR0013 + cAno + STR0014, oFont10 ) //"del ejercicio económico correspondiente al año de " - ", ha sido efectuado en base a los siguiente datos generales:"
	nlin+=100
	oSection1:Say( nlin, 080, STR0015, oFont10n ) //"1.Utilidad por distribuir"
	nlin+=50
	oSection1:Say( nlin, 080, STR0016, oFont10 ) //"-Renta anual de la empresa antes de impuestos:"
	oSection1:Say( nlin, 2000, STR0017 + Transform( cRenta, cPicture), oFont10,,,,1 ) //"S/. "
	nlin+=50
	oSection1:Say( nlin, 080, STR0018, oFont10 ) //"-Porcentaje a distribuir:"
	oSection1:Say( nlin, 1850, Str(cRentaporc) + " %", oFont10 )
	nlin+=50
	oSection1:Say( nlin, 080, STR0019, oFont10 ) //"-Monto a distribuir:"
	oSection1:Say( nlin, 2000,Transform( cMonto, cPicture), oFont10 ,,,,1)
	nlin+=50
	oSection1:Say( nlin, 080, STR0020, oFont10n ) //"2.Cálculo de la participación"
	nlin+=50
	oSection1:Say( nlin, 080, STR0021, oFont10n ) //"2.1. Según los días laborados"
	nlin+=50
	oSection1:Say( nlin, 080, STR0022, oFont10 ) //"-Número total de días laborados por todos los trabajadores de la empresa:"
	oSection1:Say( nlin, 2000,Transform( cdiastot, cPicture), oFont10,,,,1 )
	nlin+=50
	oSection1:Say( nlin, 080, STR0023, oFont10 ) //"-Número de días laborados durante el ejercicio por el trabajador:"
	oSection1:Say( nlin, 2000,Transform( n15H, cPicture), oFont10,,,,1 )
	nlin+=50
	oSection1:Say( nlin, 080, STR0024, oFont10 ) //"-Participación del trabajador según los días laborados:"
	oSection1:Say( nlin, 2000,Transform( n16V, cPicture), oFont10 ,,,,1)
	nlin+=50
	oSection1:Say( nlin, 080, STR0025, oFont10n ) //"2.2.Según las remuneraciones percibidas"
	nlin+=50
	oSection1:Say( nlin, 080, STR0026, oFont10 ) //"-Remuneración computable total pagada a todos los trabajadores de la empresa:"
	oSection1:Say( nlin, 2000,Transform( cMonto, cPicture), oFont10,,,,1 )
	nlin+=50
	oSection1:Say( nlin, 080, STR0027, oFont10 ) //"-Remuneración computable percibida durante el ejercicio por el trabajador:"
	oSection1:Say( nlin, 2000,Transform( n18V, cPicture), oFont10 ,,,,1)
	nlin+=50
	oSection1:Say( nlin, 080, STR0028, oFont10 ) //"-Participación del trabajador según las remuneraciones percibidas:"
	oSection1:Say( nlin, 2000,Transform(n19V, cPicture), oFont10,,,,1 )
	nlin+=50
	oSection1:Say( nlin, 080, STR0029, oFont10n ) //"3.Monto de la participación a percibir por el trabajador"
	nlin+=50
	oSection1:Say( nlin, 080, STR0030, oFont10 ) //"-Participación según los días laborados:"
	oSection1:Say( nlin, 2000,Transform( n20V, cPicture), oFont10 ,,,,1)
	nlin+=50
	oSection1:Say( nlin, 080, STR0031, oFont10 ) //"-Participación según las remuneraciones percibidas:"
	oSection1:Say( nlin, 2000,Transform( n21V, cPicture), oFont10,,,,1 )
	nlin+=50
	oSection1:Say( nlin, 080, STR0032, oFont10 ) //"-Deducciones aplicables en la participación de utilidades:"
	oSection1:Say( nlin, 2000,Transform( n22V, cPicture), oFont10,,,,1 )
	nlin+=50
	oSection1:Say( nlin, 080, STR0033, oFont10 ) //"-Total de la participación del trabajador en las utilidades:"
	oSection1:Say( nlin, 2000,Transform( n23V, cPicture), oFont10 ,,,,1)
	nlin+=50
	oSection1:Say( nlin, 080, STR0034, oFont10n ) //"4.Monto del remanente generado por el trabajador"
	nlin+=50
	oSection1:Say( nlin, 080, STR0035, oFont10 ) //"-Total de la participación del trabajador en las utilidades:"
	oSection1:Say( nlin, 2000,Transform( n24V, cPicture), oFont10 ,,,,1)
	nlin+=50
	oSection1:Say( nlin, 080, STR0036, oFont10 ) //"-Tope de 18 remuneraciones del trabajador:"
	oSection1:Say( nlin, 2000,Transform( n25V, cPicture), oFont10 ,,,,1)
	nlin+=50
	oSection1:Say( nlin, 080, STR0037 + AllTrim(cDestReman), oFont10 ) //"-Remanente destinado a " + MV_REMDEST
	oSection1:Say( nlin, 2000,Transform( n26V, cPicture), oFont10 ,,,,1)

	oSection2:Init()
	oSection3:Init()
	oSection4:Init()

	nlin+=200
	oSection1:Say( nlin, 080, STR0038 + ", " + Alltrim(Str(Day(dDataBase))) + " " + STR0039 + " " +  MesExtenso(month(dDataBase)) + " " + STR0040 + " " + AllTrim(Str(Year(dDataBase))), oFont10 ) //"LIMA" - "de" - "del"
	nlin+=600
	osection4:SayBitmap(nlin-250, 050, cArquivo, 500, 300,,.F.) //Archivo que contiene la firma y que debe estar en el Rootpath (system)
	osection4:Line(nlin,050,nlin,700)
	osection4:Line(nlin,1400,nlin,ncolmax)
	oSection4:Say( nlin+nX, 100, Upper(cNomeRep), oFont10 )
	oSection4:Say( nlin+nX, 1500, cNombre, oFont10 )
	nlin+=50
	oSection4:Say( nlin+nX, 100, AllTrim(SM0->M0_NOME), oFont10 )

	oReport:Endpage()

Return 

/*/{Protheus.doc} ImpGPER882
	Función para buscar la información que será impresa en el informe.

	@type  Static Function
	@author marco.rivera
	@since 20/05/2022
	@version 1.0
	@example
	ImpGPER882()
/*/
Static Function ImpGPER882()

	Local X				:= 0
	Local cFiltro		:= ""
	Local cSitQuery		:= ""
	Local cCatQuery		:= ""
	Local cSituacao		:= ""
	Local cCategoria	:= ""
	Local nCont			:= 0

	Private aPerFechado	:= {}
	Private aPerAberto	:= {}
	Private aPerTodos	:= {}

	//Vaviaveis private para impressao
	Private aInfo		:= {} 
	Private aVerbasCTS	:= {} 
	Private cCargoRep	:= ""
	Private cNomeRep	:= ""
	Private cDataPago	:= ""
	Private cRuc		:= c15 := ""
	Private n15H		:= 0   
	Private c16			:= c18 := c19 := c20 := c21 := c22 := c23 := c24:= c25 := c26 := ""
	Private n16V		:= n18V := n19V := n20V := n21V := n22V := n23V := n24V := n25V := n26V := 0
	Private cAliasX		:= GetNextAlias()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oFont09, oFont10, oFont10n, oFont12n

	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)     //Negrito//
	oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)     //Negrito//
	
	Pergunte (oReport:uParam,.f.)
	
	cProcedi	:= mv_par02
	cMes 	  	:= Substr(mv_par03, 5, 2)
	cAno 	  	:= Substr(mv_par03, 1, 4)
	cSemana 	:= mv_par04
	cSituacao	:= mv_par10
	cCategoria	:= mv_par11
	
	MakeSqlExpr(oReport:uParam)

	If !Empty(MV_PAR01)
		IIf (!Empty(cFiltro), cFiltro+=" AND ",)
	 	cFiltro += MV_PAR01
	EndIf
	If !Empty(MV_PAR05)
	    IIf (!Empty(cFiltro), cFiltro+=" AND ",)
	 	cFiltro += MV_PAR05
	EndIf
	If !Empty(MV_PAR06)
		IIf (!Empty(cFiltro), cFiltro+=" AND ",)
	 	cFiltro += MV_PAR06
	EndIf
	If !Empty(MV_PAR07)
		IIf (!Empty(cFiltro), cFiltro+=" AND ",)
	 	cFiltro +=  MV_PAR07
	EndIf
	If !Empty(MV_PAR08)
	 	IIf (!Empty(cFiltro), cFiltro+=" AND ",)
	 	cFiltro +=  MV_PAR08
	EndIf
	If !Empty(MV_PAR09)
		IIf (!Empty(cFiltro), cFiltro+=" AND ",)
	 	cFiltro +=  MV_PAR09
	EndIf

	//Situaciones del Empleado - MV_PAR10
	If !Empty(cSituacao)
	
		For nCont := 1 To Len(cSituacao)
			cSitQuery += "'" + Subs(cSituacao, nCont, 1) + "'"
			If (nCont + 1) <= Len(cSituacao)
				cSitQuery += ","
			EndIf
		Next nCont

		If !Empty(cSitQuery)
			IIf(!Empty(cFiltro), cFiltro += " AND ", .T.)
	 		cFiltro += "RA_SITFOLH IN (" + cSitQuery + ")"
		EndIf
	EndIf

	//Categorías del Empleado - MV_PAR11
	If !Empty(cCategoria)
	
		For nCont := 1 To Len(cCategoria)
			cCatQuery += "'" + Subs(cCategoria, nCont, 1) + "'"
			If (nCont + 1) <= Len(cCategoria)
				cCatQuery += ","
			EndIf
		Next nCont

		If !Empty(cCatQuery)
			IIf(!Empty(cFiltro), cFiltro += " AND ", .T.)
	 		cFiltro += "RA_CATFUNC IN (" + cCatQuery + ")"
		EndIf
	EndIf

	If !Empty(MV_PAR12)
	 	IIf (!Empty(cFiltro), cFiltro+=" AND ",)
	 	cFiltro +=  MV_PAR12
	EndIf

	If !Empty(cFiltro)
		cFiltro := "%" + cFiltro + "%"
	EndIf

	cOrdem := "%RA_FILIAL, RA_MAT%"

	BeginSql alias cAliasX
		SELECT RA_FILIAL, RA_MAT, RA_PROCES, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_NOMECMP, RA_CIC
		FROM %table:SRA% SRA
		WHERE %exp:cFiltro% AND
			SRA.%notDel%
		ORDER BY %exp:cOrdem%
	EndSql

	(cAliasX)->(DBGoTop())

	While (cAliasX)->( !EOF() )
		
		fInfo(@aInfo, (cAliasX)->RA_FILIAL)

		cNomeRep	:= RTRIM(LTRIM(fTabela("S002", 1, 7))) + " " + RTRIM(LTRIM(fTabela("S002", 1, 8))) + " " + RTRIM(LTRIM(fTabela("S002", 1, 9)))
		cCargoRep	:= fTabela("S002", 1, 10)
		cRuc		:= fTabela("S002", 1, 4)

		c15:= fDescRCC("S019","000115", 1,6,7,90)
		c16:= fDescRCC("S019","000216", 1,6,7,90)
		c18:= fDescRCC("S019","000218", 1,6,7,90)
		c19:= fDescRCC("S019","000319", 1,6,7,90)
		c20:= fDescRCC("S019","000420", 1,6,7,90)
		c21:= fDescRCC("S019","000521", 1,6,7,90)
		c22:= fDescRCC("S019","000622", 1,6,7,90)
		c23:= fDescRCC("S019","000723", 1,6,7,90)
		c24:= fDescRCC("S019","000723", 1,6,7,90)
		c25:= fDescRCC("S019","000825", 1,6,7,90)
		c26:= fDescRCC("S019","000926", 1,6,7,90)

		fRetPerComp( cMes, cAno, , (cAliasX)->RA_PROCES, cProcedi, @aPerAberto, @aPerFechado, @aPerTodos)

		If !( len(aPerFechado) < 1 )
			aSort(aPerFechado,,,{|x,y| x[2] < y[2] })
			cDataPago:= DtoC(aPerFechado[1,9])                                                                                 
			aVerbasCTS:= BuscaPercerrado(cAno , aPerFechado[1,7], aPerFechado[1,8], (cAliasX)->RA_MAT)	
		Endif
		If !( len(aPerAberto) < 1 )
			aSort(aPerAberto,,,{|x,y| x[2] < y[2] })
			cDataPago:= DtoC(aPerAberto[1,9])                                                                                 
			aVerbasCTS:= BuscaPerAberto( aPerAberto[1,1],aPerAberto[1,7] ,aPerAberto[1,8],(cAliasX)->RA_MAT)	

		Endif

		FOR X := 1 TO LEN(aVerbasCTS)        
			IF averbasCts[x][1] $ c15
				n15H := n15H + averbasCts[x][2] //HORAS			
				n16V := n16V + averbasCts[x][3] //VALOR
			ENDIF                                  
			IF averbasCts[x][1] $ c18
				n18V := n18V + averbasCts[x][3]
			ENDIF
			IF averbasCts[x][1] $ c19
				n19V := n19V + averbasCts[x][3]
			ENDIF
			IF averbasCts[x][1] $ c20
				n20V := n20V + averbasCts[x][3]
			ENDIF
			IF averbasCts[x][1] $ c21
				n21V := n21V + averbasCts[x][3]
			ENDIF
			IF averbasCts[x][1] $ c22
				n22V := n22V + averbasCts[x][3]
			ENDIF
			IF averbasCts[x][1] $ c23
				n23V := n23V + averbasCts[x][2]
			ENDIF
			IF averbasCts[x][1] $ c24
				n24V := n24V + averbasCts[x][3]
			ENDIF
			IF averbasCts[x][1] $ c25
				n25V := n25V + averbasCts[x][3]
			ENDIF
			IF averbasCts[x][1] $ c26
				n26V := n26V + averbasCts[x][3]
			ENDIF
		NEXT X
		PrintReport(oReport)

		(cAliasX)->(dbSkip())

	EndDo

	(cAliasX)->(dbCloseArea())

Return

/*/{Protheus.doc} BuscaPerCe
	Función utilizada para buscar información en periodos cerrados.

	@type  Static Function
	@author marco.rivera
	@since 20/05/2022
	@version 1.0
	@param cPeriodo, Caracter, Código del periodo.
	@param cProceso, Caracter, Código del proceso.
	@param cRoteir, Caracter, Código del procedimiento.
	@param cMat, Caracter, Matrícula del empleado.
	@return aVerbas, Arreglo, Conceptos encontrados en SRD.
	@example
	BuscaPerCe(cPeriodo, cProceso, cRoteir, cMat )
/*/
Static Function BuscaPerCe(cPeriodo, cProceso, cRoteir, cMat)

	Local cQuery	:= ""
	Local aVerbasAc	:= {}
	Local cAliasSRD	:= GetNextAlias()

	cQuery := "SELECT RD_PD, SUM(RD_HORAS) AS HORAS, SUM(RD_VALOR) AS VALOR "
	cQuery +=  " FROM  "  + RetSqlName("SRD") + " SRD" 
	cQuery +=  " WHERE  SRD.RD_MAT    	= '"+cMat+"' "
	cQuery +=  " AND  SRD.RD_PROCES    	= '"+cProceso+"' "	
	cQuery +=  " AND  SRD.RD_DATPGT 	= '"+cPeriodo+"' "	
	cQuery +=  " AND  SRD.RD_ROTEIR   	= '"+cRoteir+"' "	
	cQuery +=  " AND D_E_L_E_T_ = ''  "
	cQuery +=  " GROUP BY SRD.RD_PD  "
	cQuery +=  " ORDER BY SRD.RD_PD  "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRD, .F., .T.)
	
	(cAliasSRD)->(DBGoTop())

	While (cAliasSRD)->(!EoF())
		
		aadd(aVerbasAc, {	(cAliasSRD)->RD_PD, ;
							(cAliasSRD)->HORAS,;
							(cAliasSRD)->VALOR})

		(cAliasSRD)->(DBSkip())

	EndDo
	(cAliasSRD)->(DBCloseArea())

Return (aVerbasAc)

/*/{Protheus.doc} BuscaPerAb
	Función utilizada para buscar información en periodos abiertos.

	@type  Static Function
	@author marco.rivera
	@since 20/05/2022
	@version 1.0
	@param cPeriodo, Caracter, Código del periodo.
	@param cProceso, Caracter, Código del proceso.
	@param cRoteir, Caracter, Código del procedimiento.
	@param cMat, Caracter, Matrícula del empleado.
	@return aVerbasAc, Arreglo, Conceptos encontrados en SRC.
	@example
	BuscaPerAb(cPeriodo, cProceso, cRoteir, cMat )
/*/
Static Function BuscaPerAb(cPeriodo, cProceso, cRoteir, cMat)

	Local cQuery	:= ""
	Local aVerbasAc	:= {}
	Local cAliasSRC	:= GetNextAlias()
	
	cQuery := "SELECT RC_PD, SUM(RC_HORAS) AS HORAS, SUM(RC_VALOR) AS VALOR "
	cQuery +=  " FROM  "  + RetSqlName("SRC") + " SRC" 
	cQuery +=  " WHERE  SRC.RC_MAT   	 = '"+cMat+"' "
	cQuery +=  " AND  SRC.RC_PROCES   	 = '"+cProceso+"' "	
	cQuery +=  " AND  SRC.RC_PERIODO   	 = '"+cPeriodo+"' "	
	cQuery +=  " AND  SRC.RC_ROTEIR    	 = '"+cRoteir+"' "	
	cQuery +=  " AND D_E_L_E_T_ = ''  "
	cQuery +=  " GROUP BY SRC.RC_PD  "
	cQuery +=  " ORDER BY SRC.RC_PD  "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRC, .F., .T.)
	
	(cAliasSRC)->(DBGoTop())

	While (cAliasSRC)->(!EoF())
		
		aAdd(aVerbasAc, {	(cAliasSRC)->RC_PD,;
							(cAliasSRC)->RC_HORAS,;
							(cAliasSRC)->RC_VALOR})
		
		(cAliasSRC)->( DBSkip() )

	EndDo
	(cAliasSRC)->( DBCloseArea() )

Return (aVerbasAc)
