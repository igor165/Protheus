#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER012COL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³GPER012COL³Autor  ³ Laura Medina         ³ Fecha ³06/08/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Reporte "parametrizado" de conceptos de nomina a Archivo   ³±±
±±³           ³ Excel.                                                     ³±±
±±³           ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ GPER012COL()                                               ³±±
±±³           ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alex Hdez.  ³13/01/16³PCREQ-³Se paso a la v12 a partir del fuente de v11³±±
±±³            ³        ³7944  ³con la fecha 29/05/15                      ³±±
±±³Alf. Medrano³01/08/16³TSIZ87³Se agrega las func ReOrdena(),BuscaCve() y ³±±
±±³            ³        ³      ³fCampSRA() para mostrar la consulta de los ³±±
±±³            ³        ³      ³campos de la SRA en pregunta MV_PAR14      ³±±
±±³            ³        ³      ³En Fun. AgregaCon() se agrega consulta para³±±
±±³            ³        ³      ³obtener conceptos de SRM. se agrega Func.  ³±±
±±³            ³        ³      ³ConvQry() obtiene Val. separados por comas.³±±
±±³            ³        ³      ³se agrega Func. fDesCam() para obtener Titu³±±
±±³            ³        ³      ³lo de Campos SRA. en la func TodoOK() se   ³±±
±±³            ³        ³      ³agrega las preguntas MV_PAR13 y MV_PAR14 y ³±±
±±³            ³        ³      ³llamada a la función Gpr012Cmp() que valida³±±
±±³            ³        ³      ³existencia de campos en SRA. En func.      ³±±
±±³            ³        ³      ³GenReport() ordenan conceptos por tipo y se³±±
±±³            ³        ³      ³muestra el encabezado y detalle de         ³±±
±±³            ³        ³      ³percepciones y deducciones y el valor neto ³±±
±±³            ³        ³      ³muestar los datos seleccionados de la SRA. ³±±
±±³            ³        ³      ³se agrega AjustaSXB() crea consulta CPSRA  ³±±
±±³            ³        ³      ³se agrega AjustaSx1()crea MV_PAR13 MV_PAR14³±±
±±³Alf. Medrano³24/08/16³TSIZ87³En func. GenReport para filtra el proceso  ³±±
±±³            ³        ³      ³se toman los campos RC_PROCES y RD_PROCES  ³±±
±±³Alf. Medrano³27/09/16³TVQXNJ³Se unifica Fuente. Se quita distinción de  ³±±
±±³            ³        ³      ³paises                                     ³±±
±±³Alf. Medrano³10/10/16³      ³se agrega filtro Procedimiento  RC_ROTEIR/ ³±±
±±³            ³        ³      ³RD_ROTEIR a query en Func  GenReport       ³±±
±±³Alf. Medrano³09/11/16³TSSERMI01-64³Merge V12.1.07 vs 12.1.14            ³±±
±±³Josè Glez.  ³20/05/20³DMINA ³Se agrega Paràmetro MV_PAR15 ¿Directorio?  ³±±
±±³            ³        ³-9181 ³y se cambia el guardado del informe a la   ³±±
±±³            ³        ³      ³ruta indicada en el paràmetro.             ³±±
±±³LuisEnríquez³29/09/20³DMINA ³Se localiza el uso de los campos RA_CIC y  ³±±
±±³            ³        ³-10151³RA_DEPTO en lugar de RA_RG y RA_KEYLOC res-³±±
±±³            ³        ³      ³pectivamente (PER).                        ³±±
±±³Vero Flores ³01/12/20³DMINA ³Se localiza el uso de las preguntas de la  ³±±
±±³            ³        ³-10610³MV_PAR14 a la MV_PAR17 (PER|COL|MEX)       ³±±
±±³Diego Rivera³19/02/21³DMINA ³En la func TodoOK() se agrega la pregunta  ³±±
±±³            ³        ³-10886³MV_PAR18 y tratamiento para combinaciones  ³±±
±±³            ³        ³      ³de respuestas entre las preguntas MV_PAR10,³±±
±±³            ³        ³      ³MV_PAR12, MV_PAR13, MV_PAR15 y MV_PAR18.   ³±±
±±³            ³        ³      ³Se agrega la función ConcNomin() para la   ³±±
±±³            ³        ³      ³selección de conceptos donde RV_IMPRIPD=1. ³±±
±±³            ³        ³      ³En la función GenReport() se agrega trata- ³±±
±±³            ³        ³      ³miento para que sean mostrados los totales ³±±
±±³            ³        ³      ³en las columnas de cada concepto mostrado. ³±±
±±³            ³        ³      ³En la función GenReport() se agrega trata- ³±±
±±³            ³        ³      ³iento para que no sean mostradas las colum-³±±
±±³            ³        ³      ³nas que se encuentren en ceros, y se agrega³±±
±±³            ³        ³      ³marca distintiva para la fila de totales.  ³±±
±±³ARodriguez  ³26/02/21³DMINA ³Correcciones en tratamiento de arreglos    ³±±
±±³            ³        ³-10886³cuando imprime Horas y Valores. Limpieza de³±±
±±³            ³        ³      ³fuente por buenas prácticas.               ³±±
±±³ARodriguez  ³27/05/21³DMINA ³Merge de modificaciones César B. en fuente ³±±
±±³            ³        ³-12094³del 29/12/2018 Changeset 558045 - Perú     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER012COL()
	Local aArea				:= GetArea()
	Local cPerg				:= "GPER012COL"
	Local cMsg1				:= STR0002 //"Rutina que permite generar un reporte de conceptos a un archivo Excel, dependiendo "
	Local cMsg2				:= STR0003 //"de los parámetros seleccionados. El archivo se guarda con el nombre de Conceptos en el "
	Local nOpcA				:= 0

	Private aCmpSRA			:= {}
	Private __cCmpSRa		:= ""
	Private cLisSuc			:= "" //Lista de Sucursales
	Private cLisMat			:= "" //Lista de matricula
	Private cLisCT			:= "" //Lista de Centros de Trabajo
	Private cLisCC			:= "" //Lista de Centros de costos
	Private cLisPro			:= "" //Lista de Procesos
	Private cLisPrc			:= "" //Lista de Procedimientos
	Private cPeriodo		:= "" //Periodo
	Private cNoPago			:= "" //No. Pago
	Private cLisSit			:= "" //Lista de situaciones
	Private cConcep			:= "" //Todos los conceptos? 1=Si;2=No
	Private cCampos			:= "" //Campo que se imprimen? V=Valor;H=Horas;A=Ambos
	Private cLisCon			:= "" //Lista de Conceptos
	Private cLisCo2			:= "" //Lista de Conceptos
	Private cLiCoNom		:= "" //Lista de Conceptos Nomina
	Private cLisCam			:= "" //Lista de Campos SRA
	Private cAcum			:= "" //Acumulativo
	Private aConceptos		:= {} //Arreglo con los conceptos
	Private oDlg
	Private cTitulo			:= STR0001 //"Reporte de Conceptos de Nómina"
	Private oBoton1,oBoton2,oBoton3
	Private oProc, oNom, oRuta, cRuta
	Private cCamposEmp		:= ""
	Private aEncabConc		:= {} //Encabezados conceptos (Hrs, Val y subtotales)

	dbselectarea("SRA")
	If !isBlind()
		FormBatch(cTitulo,{OemToAnsi(cMsg1),OemToAnsi(cMsg2)},;
			{ { 5,.T.,{|o| Pergunte(cPerg,.T.) }},;
			{ 1,.T.,{|o| nOpcA := 1,o:oWnd:End()}},;
			{ 2,.T.,{|o| nOpca := 2,o:oWnd:End()}}})

		If ( nOpcA==1 )
			IF TodoOK(cPerg)
			  Processa({||genReport()})
			Endif
		EndIf
	Else
		IF TodoOK(cPerg)
			genReport()
		Endif
	EndIf

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ GenReport  ³ Autor ³ Laura Medina        ³ Fecha³07/08/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Funcion que genera el reporte de conceptos.                ³±±
±±³           ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ GPER012COL()                                               ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GenReport()
	Local aArea			:= GetArea()
	Local cAliasTmp		:= CriaTrab(Nil,.F.)
	Local cSRAName		:= RetSqlName("SRA")
	Local cSRCName		:= RetSqlName("SRC")
	Local cSRDName		:= RetSqlName("SRD")
	Local cSRVName		:= RetSqlName("SRV")
	Local oExcel		:= FWMSEXCELEx():New()
	Local nloop			:= 0
	Local nloop1		:= 0
	Local nTamCon		:= 0
	Local nConcepto		:= 0
	Local nPosTP		:= 0
	Local nPosTD		:= 0
	Local nPosN			:= 0
	local nTotM			:= 0
	Local nTCamp		:= 0
	Local nCon			:= 0
	Local nVPerc		:= 0
	Local nVDedu		:= 0
	local nPosTpx		:= 0
	local nPosTdx		:= 0
	local nPosnx		:= 0
	Local aRegistros	:= {}
	Local aNumCols	    := {}
	Local cQuery		:= ""
    Local cCpoNoId		:= IIf(cPaisLoc == "PER",'RA_CIC','RA_RG')
    Local cCpoCTrab		:= IIf(cPaisLoc == "PER",'RA_DEPTO','RA_KEYLOC')
    Local cAux1			:= ""
    Local cAuxPer		:= Substring(MV_PAR07,1,4)+"01"
    Local cPerSRC		:= ""
    Local cPerSRD		:= ""
	Local nx			:= 0
	Local ny			:= 0
	Local nFilx			:= 0
	Local nColy			:= 0
	Local nCols			:= 0
	Local nBandera		:= 0
	Local nOtros		:= 0

	If !ExistDir(cRuta)
		Aviso(STR0018,StrTran( STR0038, '###', Alltrim(cRuta) ) + GetClientDir(),{ STR0019 }) //"Atencion" //"No se encontró la carpeta ###, el archivo se creara en la ruta: " //"OK"
		cRuta:= GetClientDir()+STR0015+".xls"  //Grabar en la ruta del smartclient (cuando el path no exista)
	Else
		cRuta +=STR0015+".xls" //+".xlsx"
	Endif

	oExcel:CFRCOLORHEADER := "#000000"
	oExcel:CFRCOLORTITLE  := "#000000"
	oExcel:CBGCOLORHEADER := "#FFFFFF"
	oExcel:CBGCOLORLINE   := "#FFFFFF"
	oExcel:CBGCOLOR2LINE  := "#FFFFFF"

	If cAcum == 1
		cPerSRC:="AND RC_PERIODO BETWEEN "+cAuxPer+" AND " + cPeriodo
		cPerSRD:="AND RD_PERIODO BETWEEN "+cAuxPer+" AND " + cPeriodo
	EndIf

	If cPaisLoc == "PER"
		cQuery := "SELECT RC_FILIAL, RA_FILIAL, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_MAT, RA_CC, RA_NOME, RA_CIC, RA_ADMISSA, RA_DEMISSA, RA_CODAFP, RA_DEPTO, RA_CIC, RC_PD, RV_TIPOCOD, SUM(RC_HORAS) RC_HORAS, SUM(RC_VALOR) RC_VALOR "
	Else
		cQuery := "SELECT RC_FILIAL, RA_FILIAL, RA_MAT, RA_CC, RA_NOME, RA_KEYLOC, RA_RG, RC_PD, RV_TIPOCOD, SUM(RC_HORAS) RC_HORAS, SUM(RC_VALOR) RC_VALOR "
	EndIf
	cQuery += " FROM " + cSRAName + " SRA, " + cSRCName + " SRC, " + cSRVName + " SRV "
	cQuery += " WHERE RA_FILIAL = RC_FILIAL "
	cQuery += " AND RA_MAT = RC_MAT AND RC_PD=RV_COD AND SRV.D_E_L_E_T_ = '' "
	cQuery += " AND  SRA.D_E_L_E_T_ = '' "
	cQuery += " AND  SRC.D_E_L_E_T_ = '' "
	If  !Empty(cLisSuc)  //Sucursales
		cQuery += "   AND " +cLisSuc
	Endif
	If  !Empty(cLisMat)  //Matriculas
		cQuery += "   AND " +cLisMat
	Endif
	If  !Empty(cLisCT)  //Centros de Trabajo
		cQuery += "   AND " +cLisCT
	Endif
	If  !Empty(cLisCC) //Centros de Costo
		cQuery += "   AND " +cLisCC
	Endif
	If  !Empty(cLisSit) //Situacion
		cQuery += "   AND RA_SITFOLH IN ("+cLisSit+")"
	Endif
	If  !Empty(cLisPro) //Procesos
			cQuery += "   AND RC_PROCES IN ("+cLisPro+")"
	Endif
	If Empty (cAcum) .Or. cAcum ==2
		cQuery += "   AND RC_PERIODO = '"+ cPeriodo+"'"  //Periodo
	Else
		cQuery += cPerSRC
	EndIf
	If !Empty(cNoPago)  //No. de Pago
		cQuery += "   AND RC_SEMANA  = '"+ cNoPago+"'"
	Endif
	If  cCampos == 1    //1=Horas;2=Valor;3=Ambos
		cQuery += " AND RC_HORAS <> 0 "
	Elseif cCampos == 2
		cQuery += " AND RC_VALOR <> 0 "
	Elseif cCampos == 3
		cQuery += " AND ( RC_HORAS <> 0 OR  RC_VALOR <> 0 ) "
	Endif
	If  !Empty(cLisPrc) //Procedimiento
		cQuery += " AND " + cLisPrc
	Endif
	If  cConcep!=1 .And. !Empty(cLisCon)     //Imprime conceptos? 1.Si; 2.No; 3.Estructura
		cQuery += "   AND " +cLisCon
	Endif
	If cPaisLoc == "PER"
		cQuery += " GROUP BY RC_FILIAL,RA_FILIAL,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME,RA_MAT,RA_CC,RA_NOME,RA_CIC,RA_ADMISSA,RA_DEMISSA,RA_CODAFP,RA_DEPTO,RA_CIC,RC_PD,RV_TIPOCOD "
	Else
		cQuery += " GROUP BY RC_FILIAL,RA_FILIAL,RA_MAT,RA_CC,RA_NOME,RA_KEYLOC,RA_RG,RC_PD,RV_TIPOCOD "
	EndIf

	cQuery += " UNION "

	If cPaisLoc == "PER"
		cQuery += " SELECT RD_FILIAL, RA_FILIAL, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_MAT, RA_CC, RA_NOME, RA_CIC, RA_ADMISSA, RA_DEMISSA, RA_CODAFP, RA_DEPTO, RA_CIC, RD_PD RC_PD, RV_TIPOCOD, SUM(RD_HORAS) RC_HORAS, SUM(RD_VALOR) RC_VALOR "
	Else
		cQuery += " SELECT RD_FILIAL, RA_FILIAL, RA_MAT, RA_CC, RA_NOME, RA_KEYLOC, RA_RG, RD_PD RC_PD, RV_TIPOCOD, SUM(RD_HORAS) RC_HORAS, SUM(RD_VALOR) RC_VALOR "
	EndIf

	cQuery += " FROM " + cSRAName + " SRA, " + cSRDName + " SRD, " + cSRVName + " SRV "
	cQuery += " WHERE RA_FILIAL = RD_FILIAL "
	cQuery += " AND RA_MAT = RD_MAT AND RD_PD=RV_COD AND SRV.D_E_L_E_T_ = '' "
	cQuery += " AND  SRA.D_E_L_E_T_ = '' "
	cQuery += " AND  SRD.D_E_L_E_T_ = '' "
	If  !Empty(cLisSuc)  //Sucursales
		cQuery += "   AND " +cLisSuc
	Endif
	If  !Empty(cLisMat)  //Matriculas
		cQuery += "   AND " +cLisMat
	Endif
	If  !Empty(cLisCT)  //Centros de Trabajo
		cQuery += "   AND " +cLisCT
	Endif
	If  !Empty(cLisCC) //Centros de Costo
		cQuery += "   AND " +cLisCC
	Endif
	If  !Empty(cLisSit) //Situacion
		cQuery += "   AND RA_SITFOLH IN ("+cLisSit+")"
	Endif
	If  !Empty(cLisPro) //Procesos
		cQuery += "   AND RD_PROCES IN ("+cLisPro+")"
	Endif
	If Empty (cAcum) .Or. cAcum ==2
		cQuery += "   AND RD_PERIODO = '"+ cPeriodo+"'"  //Periodo
	Else
		cQuery += cPerSRD
	EndIf
	If !Empty(cNoPago)  //No. de Pago
		cQuery += "   AND RD_SEMANA  = '"+ cNoPago+"'"
	Endif
	If  cCampos == 1    //1=Horas;2=Valor;3=Ambos
		cQuery += " AND RD_HORAS <> 0 "
	Elseif cCampos == 2
		cQuery += " AND RD_VALOR <> 0 "
	Elseif cCampos == 3
		cQuery  += " AND ( RD_HORAS <> 0 OR  RD_VALOR <> 0 ) "
	Endif
	If  !Empty(cLisPrc) //Procedimiento
		cQuery += " AND " + REPLACE(cLisPrc,"RC_ROTEIR","RD_ROTEIR")
	Endif
	If  cConcep!=1 .And. !Empty(cLisCon)       //Imprime conceptos? 1.Si; 2.No; 3.Estructura
		cLisSRD := REPLACE(cLisCon,"RC_PD","RD_PD")
		cQuery += "   AND "+cLisSRD
	Endif
	If cPaisLoc == "PER"
		cQuery += " GROUP BY RD_FILIAL,RA_FILIAL,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME,RA_MAT,RA_CC,RA_NOME,RA_CIC,RA_ADMISSA,RA_DEMISSA,RA_CODAFP,RA_DEPTO,RA_CIC,RD_PD,RV_TIPOCOD "
		cQuery += " ORDER BY RA_FILIAL,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME,RA_MAT,RV_TIPOCOD,RC_PD "
	Else
		cQuery += " GROUP BY RD_FILIAL,RA_FILIAL,RA_MAT,RA_CC,RA_NOME,RA_KEYLOC,RA_RG,RD_PD,RV_TIPOCOD "
		cQuery += " ORDER BY RA_FILIAL,RA_MAT,RV_TIPOCOD,RC_PD "
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliastmp,.T.,.T.)

	nTamCon := IIf(cCampos==1 .Or. cCampos==2, len(aConceptos), len(aConceptos)*2)    //3-Imprimir ambos (horas y valor)
	nOtros  := IIf(cPaisLoc == "PER", 9, 6)
	nTCamp  := len(aCmpSRA) + nOtros
	nPosTP  := Ascan(aConceptos,{|x| x[3]=='TP'} ) // posicion de Total Percepcion
	nPosTD  := Ascan(aConceptos,{|x| x[3]=='TD'} ) // posicion de Total Deduccion
	nPosN   := Ascan(aConceptos,{|x| x[3]=='N'} ) // posicion del Neto

	If cCampos == 3
		nPosTP := (nPosTP * 2 ) - 1
		If nPosTP > 0
			nPosTD := (nPosTD * 2) - 2
		Else
			nPosTD := (nPosTD * 2) - 1
		EndIf

		If nPosTD > 0 .and. nPosTP > 0
			nPosN := (nPosN * 2) - 3
		ElseIf (nPosTD < 0 .and. nPosTP > 0) .OR. (nPosTD > 0 .and. nPosTP < 0)
			nPosN := (nPosN * 2) - 2
		EndIf

		IIF(nPosTP> 0, nTotM++, )
		IIF(nPosTD> 0, nTotM++, )
		IIF(nPosN > 0, nTotM++, )
		nTamCon := nTamCon - nTotM
	EndIf

	While !(cAliastmp)->(Eof())
		nloop := aScan(aRegistros, {|aDetReg| aDetReg[1]=(cAliastmp)->RA_FILIAL .And. aDetReg[2]=(cAliastmp)->RA_MAT} )

		If  nBandera < 1 .Or. nloop == 0
			//Inicializar el primero registro para el filtro
			aAdd(aRegistros,Array(nTamCon+nTCamp))
			aRegistros[len(aRegistros),1]:=(cAliastmp)->RA_FILIAL
			aRegistros[len(aRegistros),2]:=(cAliastmp)->RA_MAT
			If cPaisLoc == "PER"
				aRegistros[len(aRegistros),3]:=(cAliastmp)->(AllTrim(RA_PRISOBR) + " " + AllTrim(RA_SECSOBR) + " " + AllTrim(RA_PRINOME) + " " + AllTrim(RA_SECNOME))
				aRegistros[len(aRegistros),4]:=(cAliastmp)->RA_CIC
				aRegistros[len(aRegistros),6]:=(cAliastmp)->RA_DEPTO
				aRegistros[len(aRegistros),7]:=FDESCRCC("ST11",(cAliastmp)->RA_CODAFP, 1,2,63,30)
				aRegistros[len(aRegistros),8]:=DtoC(StoD((cAliastmp)->RA_ADMISSA)) // substr((cAliastmp)->RA_ADMISSA,7,2)+"/"+Substr((cAliastmp)->RA_ADMISSA,5,2)+"/"+Substr((cAliastmp)->RA_ADMISSA,1,4)
				aRegistros[len(aRegistros),9]:=IIf(Empty((cAliastmp)->RA_DEMISSA), "", DtoC(StoD((cAliastmp)->RA_DEMISSA))) // AllTrim(substr((cAliastmp)->RA_DEMISSA,7,2)+"/"+Substr((cAliastmp)->RA_DEMISSA,5,2)+"/"+Substr((cAliastmp)->RA_DEMISSA,1,4))
			Else
				aRegistros[len(aRegistros),3]:=(cAliastmp)->RA_NOME
				aRegistros[len(aRegistros),4]:=(cAliastmp)->RA_RG
				aRegistros[len(aRegistros),6]:=(cAliastmp)->RA_KEYLOC
			EndIf
			aRegistros[len(aRegistros),5]:=(cAliastmp)->RA_CC

			If len(aCmpSRA)>0
				//agrega Campos de SRA
				For nCon := 1 to len(aCmpSRA)
					cAux1 := REPLACE( aCmpSRA[nCon], "'", "" )
					aRegistros[len(aRegistros), nOtros + nCon ] := Posicione("SRA", 1, (cAliastmp)->RA_FILIAL+(cAliastmp)->RA_MAT,(cAliastmp)->(cAux1))
				Next
			EndIf

			For nloop1 := 1 to nTamCon
				aRegistros[len(aRegistros), nloop1 + nTCamp] := 0.00
			Next

			nloop := len(aRegistros)

		Endif

		//Encuentra primera ocurrencia del concepto; puede haber 2 (si cCampos = 3 - Horas y valores)
		nConcepto := aScan(aEncabConc,{|x| x[1]==(cAliastmp)->RC_PD} )

		If nConcepto > 0   //Solo actualiza si el concepto de SRC/SRD existe en SRV
			If cCampos == 1 .Or. cCampos == 3	//1=Horas;2=Valor;3=Ambos
				aRegistros[nloop,nConcepto+nTCamp] := (cAliastmp)->RC_HORAS
			EndIf

			ny := IIf(cCampos == 3, 1, 0)

			If cCampos == 2 .Or. cCampos == 3
				aRegistros[nloop,nConcepto+nTCamp+ny] := (cAliastmp)->RC_VALOR
			EndIf

			If nPosTP > 0 .And. aEncabConc[nConcepto,3] == '1'
				aRegistros[nloop,nPosTP+nTCamp] := aRegistros[nloop,nPosTP+nTCamp] + (cAliastmp)->RC_VALOR
			EndIf

			If nPosTD > 0 .And. aEncabConc[nConcepto,3] == '2'
				aRegistros[nloop,nPosTD+nTCamp] := aRegistros[nloop,nPosTD+nTCamp] + (cAliastmp)->RC_VALOR
			EndIf

			If nPosN > 0
				IIf( nPosTP > 0, nVPerc:=aRegistros[nloop,nPosTP+nTCamp], nVPerc:=0 )
				IIf( nPosTD > 0, nVDedu:=aRegistros[nloop,nPosTD+nTCamp], nVDedu:=0 )
				aRegistros[nloop,nPosN+nTCamp] := nVPerc - nVDedu
			EndIf
		Endif

		nBandera++

		(cAliastmp)->(dbskip())
	Enddo

	(cAliastmp)->( dbCloseArea())

	If nBandera > 0
		aAdd(aRegistros,Array(nTamCon+nTCamp))

		For nloop := 1 to nTamCon
			aRegistros[Len(aRegistros),nloop+nTCamp] := 0.0
		Next

		nFilx := len(aRegistros)
		nColy := nTamCon+nTCamp
		nTamConOri := nTamCon

		For nx := 1 to nTCamp
			If nx < nTCamp
				aRegistros[Len(aRegistros),nx] := "-"
			ElseIf nx == nTCamp
				aRegistros[Len(aRegistros),nx] := "TOTALES GENERAL"
			EndIf
		Next

		For ny := nTCamp + 1 to nColy
			For nx := 1 to nFilx - 1
				aRegistros[Len(aRegistros),ny] := IIf(empty(aRegistros[Len(aRegistros),ny]), 0, aRegistros[Len(aRegistros),ny]) + IIf(empty(aRegistros[nx,ny]), 0, aRegistros[nx,ny])
			Next
		Next

		// Examinar si hay columnas con todas las líneas en cero; eliminarlas de la matriz de datos y de encabezados
		nPosTPx := Ascan(aEncabConc,{|x| x[3]=='TP'} ) // posicion de Total Percepcion
		nPosTDx := Ascan(aEncabConc,{|x| x[3]=='TD'} ) // posicion de Total Deduccion
		nPosNx  := Ascan(aEncabConc,{|x| x[3]=='N'} ) // posicion del Neto

		For nColy := (nTamCon + nTCamp) to (nTCamp + 1) Step -1
			If (nColy != (nPosTPx+nTCamp) .And.  nColy != (nPosTDx+nTCamp) .And. nColy != (nPosNx+nTCamp))
				If aRegistros[Len(aRegistros),nColy] == 0
					//Deletar columna
					For nx := 1 to nFilx
						ADEL(aRegistros[nx],nColY)
					Next
					//Deletar encabezado de columna
					ADEL(aEncabConc, (nColY-nTCamp))
					nTamConOri--
				EndIf
			EndIf
		Next

		nNumCols := nTamConOri+nTCamp

		If !(nTamConOri == nTamCon)
			//redimensiona aRegistros
			For nx := 1 to nFilx
				ASIZE(aRegistros[nx],nNumCols)
			Next

			//redimensiona encabezados de conceptos
			ASIZE(aEncabConc,nTamConOri)
		EndIf

		For nCols := 1 to nNumCols
			AADD(aNumCols, nCols)
		Next

		If !Empty(aRegistros)
			oExcel:AddworkSheet(STR0006) // "Conceptos"
			nPosTP	:= Ascan(aConceptos,{|x| x[3]=='TP'} ) // posicion de Total Percepcion
			nPosTD	:= Ascan(aConceptos,{|x| x[3]=='TD'} ) // posicion de Total Deduccion
			nPosN	:= Ascan(aConceptos,{|x| x[3]=='N'} ) // posicion del Neto

			For nloop := 0 to len(aRegistros)
				If  nloop == 0     //Titulos
					//Titulo de tabla
					oExcel:AddTable (STR0006,STR0005) //"Reporte de Conceptos de Nómina"

					//Titulo de columnas
					oExcel:AddColumn(STR0006,STR0005,FWX3Titulo("RC_FILIAL"),1,1) //"Conceptos","Reporte de Conceptos de Nómina","Sucursal"
					oExcel:AddColumn(STR0006,STR0005,FWX3Titulo("RC_MAT"),1,1)    //"Matricula"
					oExcel:AddColumn(STR0006,STR0005,FWX3Titulo("RA_NOME"),1,1)   //"Nombre"
					oExcel:AddColumn(STR0006,STR0005,FWX3Titulo(cCpoNoId),1,1)    //"No. Id"
					oExcel:AddColumn(STR0006,STR0005,FWX3Titulo("RC_CC"),1,1)     //"C. Costos"
					oExcel:AddColumn(STR0006,STR0005,FWX3Titulo(cCpoCTrab),1,1)   //"C. Trabajo"
					If cPaisLoc == "PER"
						oExcel:AddColumn(STR0006,STR0005,FWX3Titulo("RA_CODAFP"),1,1) //"C. Trabajo"
						oExcel:AddColumn(STR0006,STR0005,FWX3Titulo("RA_ADMISSA"),1,1) //"C. Ingreso"
						oExcel:AddColumn(STR0006,STR0005,FWX3Titulo("RA_DEMISSA"),1,1) //"C. Despido"
					EndIf

					If len(aCmpSRA) > 0
						//agrega Campos de SRA
						For nCon := 1 to len(aCmpSRA)
							cAux1 := REPLACE(AllTrim(aCmpSRA[nCon]), "'", "" )
							oExcel:AddColumn(STR0006,STR0005,FWX3Titulo(cAux1),1,1)
						Next
					EndIf

					For nloop1 := 1 to len(aEncabConc)
						oExcel:AddColumn(STR0006,STR0005,aEncabConc[nloop1,2],1,2)
					Next

				Else
					If nloop == Len(aRegistros)
						oExcel:SetLineBgColor("#88D4F3")//Color fila Totales
						oExcel:AddRow(STR0006,STR0005,aRegistros[nloop],aNumCols)//Fila totales
					Else
						oExcel:AddRow(STR0006,STR0005,aRegistros[nloop])
					EndIf

				Endif
			Next

			oExcel:Activate()
			oExcel:GetXMLFile(cRuta)

			If !isBlind()
				If File(cRuta)
					Aviso(STR0018,STR0016+cRuta,{STR0019})   //"Atención","Archivo generado con éxito en la ruta: ","OK"
				Else
					Aviso(STR0018,STR0017,{STR0019})   //"Atención","No se creo el archivo, verifique los parámetros!!","OK"
				Endif
			EndIf
		Endif

	ElseIf !isBlind()
		Aviso(STR0018,STR0020,{STR0019}) //"No se encontraron registros con los parámetros seleccionados."

	Endif

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ TodoOK     ³ Autor ³ Laura Medina        ³ Fecha³07/08/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Funcion que valida las preguntas.                          ³±±
±±³           ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ GPER012COL()                                               ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TodoOK(cPerg)

	Pergunte(cPerg,.F.)

	cLisPro	:= Alltrim(MV_PAR05) //Lista de Procesos
	cRuta	:= Alltrim(MV_PAR16) // Directorio
	cCamposEmp	:= MV_PAR14 //Lista de Conceptos 2

	makesqlExpr(cPerg)
	cLisPrc	:= Alltrim(MV_PAR06) //Lista de Procedimientos
	cLisSuc	:= MV_PAR01 //Lista de Sucursales
	cLisMat	:= MV_PAR02 //Lista de matricula
	cLisCT  := MV_PAR03 //Lista de Centros de Trabajo
	cLisCC	:= MV_PAR04 //Lista de Centros de costos
	cPeriodo:= MV_PAR07 //Periodo
	cNoPago := MV_PAR08 //No. Pago
	cLisSit	:= MV_PAR09 //Lista de situaciones
	cConcep	:= MV_PAR10 //Todos los conceptos? 1=Si;2=No;3=Estructura
	cCampos	:= MV_PAR11 //Campo que se imprimen? 1=Horas;2=Valor;3=Ambos
	cLisCon	:= MV_PAR12 //Lista de Conceptos
	cLisCo2	:= MV_PAR13 //Lista de Conceptos 2
	cConNom	:= MV_PAR18 //Conceptos del Recibo de Nomina? 1=Si;2=No

	If Len(aCmpSRA) == 0
		Gpr012Cmp(cCamposEmp)
	EndIf

	cEstruc	:= Substring(MV_PAR15,1,LEN(MV_PAR15)-1) //Estructura
	cAcum	:= MV_PAR17 //Acumulativo
	cLisPro	:= Iif(!Empty(cLisPro),ConvQry(cLisPro,"RC_PROCES"),cLisPro)   //Procesos
	cLisSit	:= ConvQry(cLisSit,"RA_SITFOLH")//Lista de situaciones

	IF Empty(cEstruc)
		IF cConcep > 1
			If  cConcep == 2 // seleccionar conceptos
				If !Empty(cLisCon)
					If !Empty(cLisCo2)
						npos	:=	AT("N", cLisCo2) + 2
						cLisCo2 := Substr(cLisCo2,npos, len(cLisCo2) - npos - 1  )
						cLisCon := Substr(cLisCon,1, len(cLisCon) - 2) + "," + cLisCo2 + "))"
					EndIf
					If cConNom == 1
						cLiCoNom := ConcNomin()
						npos	:=	AT(")", cLisCon)
						cLisCon :=	Substr(cLisCon,1,npos-1) +","+ cLiCoNom+"))"
					EndIf
				ElseIf cConNom == 1
					cLiCoNom := ConcNomin()
					cLisCon :=	" RC_PD IN(" + CLiCoNom + ")"
				EndIf
			EndIf
		EndIf
	Else //Estructura
		clisCon := ConcEstru(cEstruc)
		cLisCon	:= cLiscon+"'"				   				//Agregamos comilla simple al Final
		clisCon := " RC_PD IN('"+ cLisCon + ")"
	EndIf

	AgregaCon()  //Función para agregar los conceptos

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ConvQry    ³ Autor ³ Alfredo Medrano     ³ Data ³28/07/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Convierte a expreción sql un campo separado por comas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ConvQry(cExp,cExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp: Cadena de caracteres que retorna el litbox             ³±±
±±³          ³ cExp1: Campo del diccionario de datos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  TodoOK()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvQry(cLista,cCampo)

	Local cTxt   := ''
	Local nTamReg	:= TamSX3(cCampo)[1]
	Local nCont  := 0

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Genera texto para usar  para usar despues en Query             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	For nCont := 1 To Len( cLista ) Step nTamReg
		cTxt += "'" + SubStr( cLista , nCont , nTamReg ) + "',"
	Next

	cTxt := Substr(cTxt,1, Len(cTxt)-1)

Return ( cTxt )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ AgregaCon  ³ Autor ³ Laura Medina        ³ Fecha³12/08/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Funcion que agrega los conceptos a un arreglo para presen- ³±±
±±³           ³ tarlos en el archivo de excel.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ GPER012COL()                                               ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AgregaCon()
	Local cQuery    := ""
	Local cAliasTmp := CriaTrab(Nil,.F.)
	Local cSRVName  := RetSqlName("SRV")
	Local aCpyCon   := {}
	Local aConcp	:= {}
	Local cFilSRV	:= ""
	Local cTotal	:= ""
	Local cTipoC	:= '0'
	Local nCon		:= 0
	Local nPosP		:= 0
	Local nPosD		:= 0
	Local nBan		:= 0

	//Selecciona los valores de la tabla SRM
	cQuery := " SELECT  DISTINCT  RM_VERBA, RV_DESC, RV_TIPOCOD "
	cQuery += " FROM " + RetSqlName("SRM") + " SRM "
	cQuery += " INNER JOIN " + cSRVName + " SRV ON RM_VERBA = RV_COD "
	cQuery += "	WHERE SRM.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_ = ''"
	cQuery += "	AND RV_FILIAL = '"+ XFILIAL("SRV")+"'"
	cQuery += "	AND RM_FILIAL = '"+ XFILIAL("SRM")+"'"

	If  cConcep!=1 .and. !Empty(cLisCon)   //Solo  unos conceptos
		cFilSRV := REPLACE(cLisCon,"RC_PD","RV_COD")
		cQuery += " AND "+cFilSRV
	Endif

	If  !Empty(cLisPro) //Procesos
		cQuery += " AND RM_PROCES IN ("+cLisPro+")"
	Endif

	If  !Empty(cLisPrc) //Procedimiento
		cQuery += " AND " + REPLACE(cLisPrc,"RC_ROTEIR","RM_CALCULO")
	Endif

	cQuery += " ORDER BY RV_TIPOCOD, RM_VERBA "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliastmp,.T.,.T.)

	While !(cAliastmp)->(Eof())
		aAdd(aCpyCon,{(cAliastmp)->RM_VERBA, (cAliastmp)->RV_DESC, (cAliastmp)->RV_TIPOCOD})
		(cAliastmp)->(dbskip())
	Enddo

	(cAliastmp)->( dbCloseArea())

	nPosP := aScan(aCpyCon,{|x| x[3] = '1'}) //verifica si hay Percepciones
	nPosD := aScan(aCpyCon,{|x| x[3] = '2'}) //verifica si hay Deducciones

	For nCon:= 1 to len(aCpyCon)

		If (aCpyCon[ncon,3] != cTipoC .and. VAL(cTipoC) > 0 .and. VAL(cTipoC) <= 2) .OR. ((cTipoC == '1' .OR. cTipoC == '2')  .AND. nCon == len(aCpyCon) )
			nBan++
			If (cTipoC == '1')
				cTotal := OemToAnsi(STR0033) //"Total Percep."
				cTipoT	:= "TP"
			ELseIf (cTipoC == '2')
				cTotal := OemToAnsi(STR0034) //"Total Deducc."
				cTipoT	:= "TD"
			EndIf
			aAdd(aConcp,{"", cTotal, cTipoT}) // agrega espacio para totales de Percepcion y Deduccion
			aAdd(aEncabConc,{"", cTotal, cTipoT})
			If (nPosP > 0 .and. nPosD <= 1 .and. cTipoC == '1') .OR. (nPosD > 0 .and. cTipoC == '2')
				aAdd(aConcp,{"", OemToAnsi(STR0035), 'N'})	// "Neto"   agrega espacio para totales de neto
				aAdd(aEncabConc,{"", OemToAnsi(STR0035), 'N'})
			EndIf

		EndIf

		AADD(aConcp, {aCpyCon[ncon,1], aCpyCon[ncon,2], aCpyCon[ncon,3]} )

		If cCampos == 1 .Or. cCampos == 3
			aAdd(aEncabConc, {aCpyCon[ncon,1], STR0024 + " " + aCpyCon[ncon,1] + "-" + aCpyCon[ncon,2], aCpyCon[ncon,3]} )
		EndIf
		If cCampos == 2 .Or. cCampos == 3
			aAdd(aEncabConc, {aCpyCon[ncon,1], STR0025 + " " + aCpyCon[ncon,1] + "-" + aCpyCon[ncon,2], aCpyCon[ncon,3]} )
		EndIf

		cTipoC :=  aCpyCon[ncon,3]
	Next

	If !Empty(aConcp)
		aConceptos:= aConcp
	Endif

Return

//Funcion para Retornar los conceptos definidos en la Estructura
Static Function ConcEstru(cEstruc)
	Local cConcEstr     := ""
	Local cAliasRCC     := GetNextAlias()

	If alltrim(cEstruc) <> ""
  		cConten := ""+alltrim(cEstruc)+"%"
  	Else
  		cConten := "%'%"+alltrim(cEstruc)+"%'%"
  	EndIf

	//Selecciona los valores de la tabla RCC
	BeginSql Alias cAliasRCC
		SELECT RCC_CONTEU FROM %table:RCC% RCC
		WHERE RCC.RCC_CODIGO = 'S073' AND RCC.%NotDel% AND RCC.RCC_FILIAL = %Exp:(xFilial("RCC"))%
		AND RCC_CONTEU LIKE %Exp:cConten%
	EndSql

	While !(cAliasRCC)->(Eof())
		cConcEstr	+= Alltrim(SUBSTRING((cAliasRCC)->RCC_CONTEU,18,233))+"/" 	//El campo esta definido de 250 posiciones por eso leo las
		(cAliasRCC)->(dbskip())
	Enddo

	cConcEstr	:= Substring(cConcEstr,1,Len(cConcEstr)-1)		//Elimino el ultimo /
	cConcEstr	:= Strtran(cConcEstr,"/","','")					//Sustitucion de  / por ,
	(cAliasRCC)->(DbCloseArea())

Return cConcEstr

//Funcion para Retornar los conceptos de Nomina donde RV_IMPRIPD = 1
Static Function ConcNomin()
	Local cConcNomi	:= ""
	Local cSrvCod	:= GetNextAlias()

	//Selecciona los valores de la tabla SRV
	BeginSQL Alias cSrvCod
		SELECT RV_COD
		FROM %Table:SRV% SRV
		WHERE SRV.RV_IMPRIPD = 1
		AND SRV.%NotDel%
	EndSQL

	(cSrvCod)->(DBGoTop())

	While (cSrvCod)->(!Eof())
		cConcNomi += "'"+(cSrvCod)->RV_COD+"'"
		(cSrvCod) ->(dbSkip())
    	cConcNomi +=IIf((cSrvCod)->(EOF()),"",",")	//Se le agrega coma si no es el último registro
	EndDo

	(cSrvCod) ->(dbCloseArea())

Return cConcNomi

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fCampSRA   ³ Autor ³ Alfredo Medrano       ³ Data ³28/07/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Genera dialogo para consulta Campos de  SRA                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCampSRA()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NA                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ __cCmpSRa = Campos seleccionados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X1_F3 de MV_PAR14 Preg. GPER012COL                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fCampSRA()

	Local aArea		:= getArea()
	Local cCamp		:= ""
	Local cDesc		:= ""
	Local cNomCam	:= ""
	Local cCampSRA	:= ""
	Local oDlgRec	:= NIL
	Local oBoton	:= NIL
	Local oBusca	:= NIL
	Local aRCampo	:= {}
	Local aOrdenes	:= {1}
	Local lRet		:= .T.
	Local nPos		:= 0
	Local nPosLbx	:= 0
	Local nCont		:= 0
	Local nOrd		:= 1
	Local cBusca	:= Space(80)
	Local cClave	:= MV_PAR14

	Private cIndx	:= ""
	Private bLinea	:= {||}
	Private aIndx	:= {}
	Private aItems	:= {}
	Private oLbx	:= Nil

	cClave := rtrim(cClave)
	__cCmpSRa := cClave

	CursorWait()
	//-- Campos por los que hara las busquedas
	aAdd(aIndx, OemToAnsi(STR0026))
	aAdd(aIndx, OemToAnsi(STR0027))
	cCampSRA:= fTablesBox(2, "SRA")
	//Se obtienen los campos
	aRCampo := STRTOKARR(ALLTRIM(cCampSRA), ';')
	If Len(aRCampo) > 0
		For nCont := 1 to Len(aRCampo)
			cCamp:= SUBSTR(aRCampo[nCont],1, AT("=",aRCampo[nCont])-1)
			cDesc:= SUBSTR(aRCampo[nCont],AT("=",aRCampo[nCont]) + 1, Len(aRCampo[nCont]) )
			AADD(aItems,{cCamp,cDesc } )
		Next
	EndIf
	CursorArrow()

	//Si no existen Campos se envía mensaje en pantalla
	If Valtype(aItems) <> 'A'//Len(aItems) == 0
		Aviso(OemToAnsi(STR0030),OemToAnsi(STR0031),{OemToAnsi(STR0032)})//"Atencion" "No hay informaci¢n para consultar." 'Ok'
		lRet:= .F.
		Return lRet
	ElseIf	 Len(aItems) == 0
		Aviso(OemToAnsi(STR0030),OemToAnsi(STR0031),{OemToAnsi(STR0032)})//"Atencion" "No hay informaci¢n para consultar." 'Ok'
		lRet:= .F.
		RestArea(aArea)
		Return lRet
	Endif

	bLinea := {|| {	aItems[oLbx1:nAt,1], aItems[oLbx1:nAt,2]}}

	//-- Posicion en el arreglo donde esta la actual clave de producto
	If !Empty(cClave)
		nPos := aScan(aItems,{|x| x[1] = cClave}) //posiciona en el producto contenid en el campo ReadVar
	EndIf

	//-- Despliega consulta
	DEFINE MSDIALOG oDlgRec Title OemToAnsi(STR0029) From 000,000 To 421,522 Pixel //"Campos SRA"

		@ 02,05 MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx size 210,08 PIXEL OF oDlgRec
		oIndx:bChange := {|| (nOrd:=oIndx:nAt, Reordena(@oLbx1, aItems, nOrd)) }

		@ 02,220 BUTTON oBoton PROMPT OemToAnsi(STR0028) SIZE 35,10 ; //"Buscar"
				ACTION (oLbx1:nAT := BuscaCve(oLbx1, aItems, nOrd, aOrdenes, cBusca), ;
						oLbx1:bLine := bLinea, ;
						oLbx1:SetFocus());
				PIXEL OF oDlgRec
		@ 14,05 MSGET oBusca VAR cBusca PICTURE "@!" SIZE 210,08 PIXEL OF oDlgRec
		@ 28,05 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER OemToAnsi(STR0026),  OemToAnsi(STR0027),; //"Campo","Descripción"
									SIZE 255,149 OF oDlgRec PIXEL
		oLbx1:SetArray(aItems)

		If nPos > 0
			oLbx1:nAt := nPos
		Endif

		oLbx1:bLine:= if(len(aItems)>0,bLinea,{||})
		oLbx1:BlDblClick := {||(lRet:=.T.,nPos:=oLbx1:nAt,oDlgRec:End())}
		oLbx1:Refresh()

		DEFINE SBUTTON FROM 195, 05 TYPE 1 ENABLE OF oDlgRec ACTION (lRet:=.T.,nPos:=oLbx1:nAt,oDlgRec:End())
		DEFINE SBUTTON FROM 195, 36 TYPE 2 ENABLE OF oDlgRec ACTION (lRet:=.F.,nPos:=0,oDlgRec:End())

	ACTIVATE MSDIALOG oDlgRec CENTERED

	If lRet .and. nPos <> 0
		cNomCam := aItems[nPos][1]
	EndIf

	__cCmpSRa := cNomCam

	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaCve  ºAutor  ³Alfredo Medrano     º Data ³ 28/07/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca la posición de una clave en el listbox y retorna      º±±
±±º          ³su posición                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CTBA093                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscaCve(oLbx1, aItems, nOrd, aOrdenes, cBusca)
	Local nPos := 0
	Local nCol := aOrdenes[nOrd]

	cBusca := Upper(Trim(cBusca))
	nPos := ASCAN(aItems, {|aVal| aVal[nCol]=cBusca} )

	If nPos == 0
		nPos := oLbx1:nAt
	EndIf

Return nPos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReOrdena  ºAutor  ³Alfredo Medrano     º Data ³ 28/07/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Re Ordena los elementos de un listbox según el índice.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CTBA093                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Reordena(oLbx1,aItems,nOrd)

	CursorWait()

	If nOrd == 1
		aItems := aSort(aItems,,,{|x,y| x[1]+x[2] <= y[1]+y[2] })
	ElseIf nOrd == 2
		aItems := aSort(aItems,,,{|x,y| x[2]+x[1] <= y[2]+y[1] })
	Endif

	oLbx1:SetArray(aItems)
	oLbx1:nAt := 1
	oLbx1:bLine := bLinea
	oLbx1:Refresh()

	CursorArrow()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Gpr012Cmp  ³ Autor ³ Alfredo Medrano       ³ Data ³27/07/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida que los campos existan en SRA                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gpr012Cmp(ExpC1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TodoOK() Y X1_VALID de MV_PAR14 Preg. GPER012COL              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gpr012Cmp(cLtaCam)
	Local aArea 	:= getArea()
	Local nCon 		:= 0
	Local lRet 		:= .T.
	Local cCpoSRA	:= ""
	Local cCmpRet 	:= ""
	Local cCmpNE 	:= ""
	Local cCampo    := ""

	cLtaCam := StrTran(cLtaCam,'"','')
	cLtaCam := StrTran(cLtaCam,"'","")
	cLtaCam := "'" + AllTrim(cLtaCam) + "'"

	aCmpSRA:={}

	If !Empty(cLtaCam)
		dbselectarea("SRA")
		aCmpSRA := STRTOKARR(ALLTRIM(cLtaCam), ';')

		For nCon := 1 to len(aCmpSRA)
			If !Empty(aCmpSRA[nCon])
				cCpoSRA += aCmpSRA[nCon] + ","
				cCampo := StrTran(aCmpSRA[nCon],"'","")
				cCampo := StrTran(cCampo,";","")
				If GetSx3Cache(AllTrim(cCampo),"X3_ARQUIVO") == "SRA"
					cCmpRet += AllTrim(cCampo) + ", "
				ElseIf !Empty(AllTrim(cCampo))
					cCmpNE += AllTrim(cCampo) + ", "
				EndIf
			EndIf
		Next

		If !Empty(cCmpNE)
			MSGALERT( OemToAnsi(STR0036) + cCmpNE + OemToAnsi(STR0037),  OemToAnsi(STR0018) ) // "Los campos" + " no existen en la Tabla SRA " +   "Atencion"
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

return lRet
