#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER886.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ GPER886    ³ Autor ³ Luis Samaniego            ³ Data ³ 30/10/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Planillas Mensuales de Sueldos, Salarios y Accidentes de Trabajo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER886()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAGPE                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³  Data   ³    BOPS    ³         Motivo da Alteracao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marco A. Glz³06/12/18 ³DMICNS-4710 ³Se replica issue DMICNS-3795 (12.1.14) y ³±±
±±³            ³         ³            ³se realizan correcciones en impresion de ³±±
±±³            ³         ³            ³columnas. (BOL)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER886()
Local aArea   := GetArea()
Local oReport := Nil

Private lBolPais	:= ChkFile("SRA") .And. SRA->(ColumnPos("RA_CPAISOR")) > 0
Private lBolAtu		:= If (FieldPos("RA_TUTORDF") > 0, .T., .F.)

	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea(aArea)

Return

/*/{Protheus.doc}ReportDef()
Definicion de Informe
@author Luis Arturo Samaniego Guzman
@since 30/10/2018
@version P12
/*/
Static Function ReportDef()
Local oReport   := Nil
Local oSectionA := Nil
Local cNomeProg := FunName()
Local oSX1		:= FWSX1Util():New()
Local cPerg     := ""
Local nTamValor := TamSx3("RD_VALOR")[1]
Local nTamHoras := TamSx3("RD_HORAS")[1]
Local nTamNome  := TamSX3("RA_PRINOME")[1] + TamSX3("RA_SECNOME")[1]
Local cQrySRA   := GetNextAlias()

	oSX1:AddGroup("GPER886")
	oSX1:SearchGroup()

	cPerg	:=  "GPER886"
	oReport := TReport():New(cNomeProg, STR0047, cPerg, {|oReport| PrintReport(oReport, oSectionA, cQrySRA)}, STR0047)
	oReport:SetLandscape(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:lPageBreak := .F.
	oReport:lHeaderVisible := .F.
	oReport:lFooterVisible := .F.
	oReport:lParamPage := .F.

	Pergunte(oReport:uParam,.F.)

	oSectionA := TRSection():New(oReport, STR0047, cQrySRA)
	oSectionA:SetTotalInLine(.F.)
	oSectionA:SetHeaderSection(.F.)
	oSectionA:SetHeaderPage(.T.)
	oSectionA:SetLineStyle(.F.)

	TRCell():New(oSectionA,"Nro",        " ", STR0001, , 7                        ,,,,,"RIGHT")//Nro - 01
	TRCell():New(oSectionA,"TipoDoc",    " ", STR0002, , TamSX3("RA_TIPODOC")[1]  ,,,,,"LEFT")//Tipo de documento de identidad - 02
	TRCell():New(oSectionA,"NumDoc",     " ", STR0003, , TamSX3("RA_CIC")[1]      ,,,,,"LEFT")//Número de documento de identidad - 03
	TRCell():New(oSectionA,"LugarExp",   " ", STR0004, , TamSX3("RA_UFCI")[1]     ,,,,,"LEFT")//Lugar de expedición - 04
	TRCell():New(oSectionA,"FchNac",     " ", STR0005, , TamSX3("RA_NASC")[1]     ,,,,,"LEFT")//Fecha de nacimiento - 05
	TRCell():New(oSectionA,"Paterno",    " ", STR0006, , TamSX3("RA_PRISOBR")[1]  ,,,,,"LEFT")//Apellido paterno - 06
	TRCell():New(oSectionA,"Materno",    " ", STR0007, , TamSX3("RA_SECSOBR")[1]  ,,,,,"LEFT")//Apellido materno - 07
	TRCell():New(oSectionA,"Nombre",     " ", STR0008, , nTamNome                 ,,,,,"LEFT")//Nombres - 08
	TRCell():New(oSectionA,"Pais",       " ", STR0009, , TamSX3("X5_DESCSPA")[1]  ,,,,,"LEFT")//País de nacionalidad - 09
	TRCell():New(oSectionA,"Sexo",       " ", STR0010, , TamSX3("RA_SEXO")[1]     ,,,,,"LEFT")//Sexo - 10
	TRCell():New(oSectionA,"Jubilado",   " ", STR0011, , TamSX3("RA_JUBILAC")[1]  ,,,,,"LEFT")//Jubilado - 11
	TRCell():New(oSectionA,"AportaAFP",  " ", STR0012, , TamSX3("RA_AFPOPC")[1]   ,,,,,"LEFT")//¿Aporte a la AFP? - 12
	TRCell():New(oSectionA,"Discapac",   " ", STR0013, , TamSX3("RA_TPDEFFI")[1]  ,,,,,"LEFT")//¿Persona con discapacidad? - 13
	If lBolAtu
		TRCell():New(oSectionA,"TutorDisc",  " ", STR0014, , TamSX3("RA_TUTORDF")[1]  ,,,,,"LEFT")//Tutor de persona con discapacidad - 14
	EndIf
	TRCell():New(oSectionA,"FchIngreso", " ", STR0015, , TamSX3("RA_ADMISSA")[1]  ,,,,,"LEFT")//Fecha de ingreso - 15
	TRCell():New(oSectionA,"FchRetiro",  " ", STR0016, , TamSX3("RA_DEMISSA")[1]  ,,,,,"LEFT")//Fecha de retiro - 16
	TRCell():New(oSectionA,"MotRetiro",  " ", STR0017, , TamSX3("RG_TIPORES")[1]  ,,,,,"LEFT")//Motivo de retiro - 17 *
	TRCell():New(oSectionA,"CajaSalud",  " ", STR0018, , TamSX3("RA_CAJSAL")[1]   ,,,,,"LEFT")//Caja de salud - 18
	TRCell():New(oSectionA,"AFPAporta",  " ", STR0019, , TamSX3("RA_TPAFP")[1]    ,,,,,"LEFT")//AFP a la que aporta - 19 *
	TRCell():New(oSectionA,"NuaCua",     " ", STR0020, , TamSX3("RA_NRNUA")[1]    ,,,,,"LEFT")//NUA/CUA - 20*
	TRCell():New(oSectionA,"Sucursal",   " ", STR0021, , TamSX3("RA_SUCUBIC")[1]  ,,,,,"LEFT")//Sucursal o ubicación adicional - 21*
	TRCell():New(oSectionA,"ClasfLab",   " ", STR0022, , TamSX3("RA_CLASLAB")[1]  ,,,,,"LEFT")//Clasificación laboral - 22*
	TRCell():New(oSectionA,"Cargo",      " ", STR0023, , TamSX3("RJ_DESC")[1]     ,,,,,"LEFT")//Cargo - 23
	TRCell():New(oSectionA,"ModContrat", " ", STR0024, , TamSX3("RA_TPCONTM")[1]  ,,,,,"LEFT")//Modalidad de contrato - 24*
	TRCell():New(oSectionA,"TipoContr",  " ", STR0025, , TamSX3("RA_TIPCONT")[1]  ,,,,,"LEFT")//Tipo de contrato - 25*
	TRCell():New(oSectionA,"DiasPag",    " ", STR0026, , nTamHoras                ,,,,,"LEFT")//Días pagados - 26
	TRCell():New(oSectionA,"HoraPag",    " ", STR0027, , TamSX3("RA_HRSDIA")[1]   ,,,,,"RIGHT")//Horas pagadas - 27
	TRCell():New(oSectionA,"HaberBas",   " ", STR0028, , nTamValor                ,,,,,"RIGHT")//Haber básico - 28
	TRCell():New(oSectionA,"BonoAntig",  " ", STR0029, , nTamValor                ,,,,,"RIGHT")//Bono de antigüedad - 29
	TRCell():New(oSectionA,"HoraExt",    " ", STR0030, , nTamHoras                ,,,,,"RIGHT")//Horas extra - 30
	TRCell():New(oSectionA,"MontoHExt",  " ", STR0031, , nTamValor                ,,,,,"RIGHT")//Monto horas extra - 31
	TRCell():New(oSectionA,"HrsRecNoc",  " ", STR0032, , nTamHoras                ,,,,,"RIGHT")//Horas recargo nocturno - 32
	TRCell():New(oSectionA,"MonHExtN",   " ", STR0033, , nTamValor                ,,,,,"RIGHT")//Monto horas extra nocturnas - 33
	TRCell():New(oSectionA,"HExtDomin",  " ", STR0034, , nTamHoras                ,,,,,"RIGHT")//Horas extra dominicales - 34
	TRCell():New(oSectionA,"MonHExtDom", " ", STR0035, , nTamValor                ,,,,,"RIGHT")//Monto horas extra dominicales - 35
	TRCell():New(oSectionA,"DominTrab",  " ", STR0036, , nTamHoras                ,,,,,"RIGHT")//Domingos trabajados - 36
	TRCell():New(oSectionA,"MontDomTra", " ", STR0037, , nTamValor                ,,,,,"RIGHT")//Monto domingos trabajados - 37
	TRCell():New(oSectionA,"NroDominic", " ", STR0038, , nTamHoras                ,,,,,"RIGHT")//Nro. dominicales - 38
	TRCell():New(oSectionA,"SalDominc",  " ", STR0039, , nTamValor                ,,,,,"RIGHT")//Salario dominical - 39
	TRCell():New(oSectionA,"BonoProd",   " ", STR0040, , nTamValor                ,,,,,"RIGHT")//Bono producción - 40
	TRCell():New(oSectionA,"SubFront",   " ", STR0041, , nTamValor                ,,,,,"RIGHT")//Subsidio frontera - 41
	TRCell():New(oSectionA,"OtrosBon",   " ", STR0042, , nTamValor                ,,,,,"RIGHT")//Otros bonos y pagos - 42
	TRCell():New(oSectionA,"RC-Iva",     " ", STR0043, , nTamValor                ,,,,,"RIGHT")//RC-IVA - 43
	TRCell():New(oSectionA,"AporteCaja", " ", STR0044, , nTamValor                ,,,,,"RIGHT")//Aporte caja de salud - 44
	TRCell():New(oSectionA,"AporteAFP",  " ", STR0045, , nTamValor                ,,,,,"RIGHT")//Aporte AFP - 45
	TRCell():New(oSectionA,"OtrosDesc",  " ", STR0046, , nTamValor                ,,,,,"RIGHT")//Otros descuentos - 46

	FreeObj(oSX1)

Return oReport

/*/{Protheus.doc}PrintReport()
Imprime reporte de Sueldos, salarios y accidentes de trabajo
@author Luis Arturo Samaniego Guzman
@since 30/10/2018
@version P12
/*/
Static Function PrintReport(oReport, oSectionA, cQrySRA)
Local nNro        := 1
Local nReg        := 0
Local nPos        := 0
Local cQuery      := ""
//Valor Columnas
Local cMotRetir   := 0
Local nDiasPag    := 0
Local nHoraPag    := 0
Local nHaberBas   := 0
Local nBonoAntig  := 0
Local nHoraExt    := 0
Local nMontoHExt  := 0
Local nHrsRecNoc  := 0
Local nMonHExtN   := 0
Local nHExtDomin  := 0
Local nMonHExtDom := 0
Local nDominTrab  := 0
Local nMontDomTra := 0
Local nNroDominic := 0
Local nSalDominc  := 0
Local nBonoProd   := 0
Local nSubFront   := 0
Local nOtrosBon   := 0
Local nRcIVa      := 0
Local nAporteCaja := 0
Local nAporteAFP  := 0
Local nOtrosDesc  := 0
//Periodos y Conceptos
Local cCat			:= ""
Local aVerbasFunc	:= {}
Local aConceps		:= {}
Local aVerbasFilter	:= {}
Local aPerAbe		:= {}
Local aPerFec		:= {}
Local cPictNro		:= "@E 9999999"
Local cPictVlr		:= "@E 9999999.99"
Local cPictDate		:= "99/99/9999"
Local aCposNum		:= {"MontoHExt", "MonHExtN", "MonHExtDom", "MontDomTra", "SalDominc", "BonoProd",;
				 		"SubFront", "OtrosBon", "RC-Iva", "AporteCaja", "AporteAFP", "OtrosDesc"}
Local aCposFch		:= {"FchIngreso", "FchRetiro", "FchNac"}
Local cListCon		:= ""

Default oReport   := Nil
Default oSectionA := Nil
Default cQrySRA   := GetNextAlias()

Private cProcesso  := ""
Private cRoteiro   := ""
Private cPeriodo   := ""
Private cSemana    := ""
Private cFilDe     := ""
Private cFilAte    := ""
Private cMatDe     := ""
Private cMatAte    := ""
Private cCategoria := ""

	cProcesso   := MV_PAR01 //Proceso
	cRoteiro    := MV_PAR02 //Procedimiento
	cPeriodo    := MV_PAR03 //De Periodo
	cSemana     := MV_PAR04 //Numero de Pago
	cFilDe      := MV_PAR05 //De Sucursal
	cFilAte     := MV_PAR06 //A Sucursal
	cMatDe      := MV_PAR07 //De Matricula
	cMatAte     := MV_PAR08 //A Matricula
	cSituacao	:= MV_PAR09 //A Situação
	cCategoria  := MV_PAR10 //Categorías por Impr.

	cSit     := fSqlIn(cSituacao,1)
	cCat     := fSqlIn(cCategoria,1)
	ObtConcSRV(@aVerbasFilter, @aConceps)

	cQuery := " SELECT "
	cQuery += " RA_FILIAL, RA_MAT, RA_TIPODOC, RA_CIC, RA_UFCI, RA_NASC, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_NACIONA, RA_SEXO, RA_JUBILAC, "
	cQuery += " RA_AFPOPC, RA_TPDEFFI, RA_ADMISSA, RA_DEMISSA, RA_CAJSAL, RA_TPAFP, RA_NRNUA, RA_SUCUBIC, RA_CLASLAB, RA_CODFUNC, RA_TPCONTM, "
	cQuery += " RA_TIPCONT, RA_SITFOLH, RA_CATFUNC, RA_HRSDIA,RA_SALARIO "
	If lBolAtu
		cQuery	+=", RA_TUTORDF"
	EndIf
	If lBolPais
		cQuery += ", RA_CPAISOR"
	EndIf
	cQuery += " FROM " + RetSqlName("SRA")
	cQuery += " WHERE "
	cQuery += " RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "'"
	cQuery += " AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += " AND RA_PROCES = '" + cProcesso + "'"
	cQuery += " AND RA_SITFOLH IN (" + cSit + ") "
	cQuery += " AND RA_CATFUNC IN (" + cCat + ") "

	If TcSrvType() == "AS/400"
		cQuery += "AND @DELETED@ = ' ' "
	Else
		cQuery += "AND D_E_L_E_T_ = ' ' "
	Endif

	cQuery += "ORDER BY RA_FILIAL, RA_MAT "

	cQuery := ChangeQuery(cQuery)

	If Select(cQrySRA) > 0
		(cQrySRA)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
	TCSetField(cQrySRA,"RA_ADMISSA",   "D",8,0)
	TCSetField(cQrySRA,"RA_DEMISSA","D",8,0)
	TCSetField(cQrySRA,"RA_NASC","D",8,0)

	oReport:StartPage()
	oReport:SetTitle(UPPER(STR0001))
	oSectionA:Init()

	oSectionA:Cell("Nro"):SetValue(STR0001) //01
	oSectionA:Cell("TipoDoc"):SetValue(STR0002) //02
	oSectionA:Cell("NumDoc"):SetValue(STR0003) //03
	oSectionA:Cell("LugarExp"):SetValue(STR0004) //04
	oSectionA:Cell("FchNac"):SetValue(STR0005) //05
	oSectionA:Cell("Paterno"):SetValue(STR0006) //06
	oSectionA:Cell("Materno"):SetValue(STR0007) //07
	oSectionA:Cell("Nombre"):SetValue(STR0008) //08
	oSectionA:Cell("Pais"):SetValue(STR0009) //09
	oSectionA:Cell("Sexo"):SetValue(STR0010) //10
	oSectionA:Cell("Jubilado"):SetValue(STR0011) //11
	oSectionA:Cell("AportaAFP"):SetValue(STR0012) //12
	oSectionA:Cell("Discapac"):SetValue(STR0013) //13
	If lBolAtu
		oSectionA:Cell("TutorDisc"):SetValue(STR0014) //14
	EndIf
	oSectionA:Cell("FchIngreso"):SetValue(STR0015) //15
	oSectionA:Cell("FchRetiro"):SetValue(STR0016) //16
	oSectionA:Cell("MotRetiro"):SetValue(STR0017) //17
	oSectionA:Cell("CajaSalud"):SetValue(STR0018) //18
	oSectionA:Cell("AFPAporta"):SetValue(STR0019) //19
	oSectionA:Cell("NuaCua"):SetValue(STR0020) //20
	oSectionA:Cell("Sucursal"):SetValue(STR0021) //21
	oSectionA:Cell("ClasfLab"):SetValue(STR0022) //22
	oSectionA:Cell("Cargo"):SetValue(STR0023) //23
	oSectionA:Cell("ModContrat"):SetValue(STR0024) //24
	oSectionA:Cell("TipoContr"):SetValue(STR0025) //25
	oSectionA:Cell("DiasPag"):SetValue(STR0026) //26
	oSectionA:Cell("HoraPag"):SetValue(STR0027) //27
	oSectionA:Cell("HaberBas"):SetValue(STR0028) //28
	oSectionA:Cell("BonoAntig"):SetValue(STR0029) //29
	oSectionA:Cell("HoraExt"):SetValue(STR0030) //30
	oSectionA:Cell("MontoHExt"):SetValue(STR0031) //31
	oSectionA:Cell("HrsRecNoc"):SetValue(STR0032) //32
	oSectionA:Cell("MonHExtN"):SetValue(STR0033) //33
	oSectionA:Cell("HExtDomin"):SetValue(STR0034) //34
	oSectionA:Cell("MonHExtDom"):SetValue(STR0035) //35
	oSectionA:Cell("DominTrab"):SetValue(STR0036) //36
	oSectionA:Cell("MontDomTra"):SetValue(STR0037) //37
	oSectionA:Cell("NroDominic"):SetValue(STR0038) //38
	oSectionA:Cell("SalDominc"):SetValue(STR0039) //39
	oSectionA:Cell("BonoProd"):SetValue(STR0040) //40
	oSectionA:Cell("SubFront"):SetValue(STR0041) //41
	oSectionA:Cell("OtrosBon"):SetValue(STR0042) //42
	oSectionA:Cell("RC-Iva"):SetValue(STR0043) //43
	oSectionA:Cell("AporteCaja"):SetValue(STR0044) //44
	oSectionA:Cell("AporteAFP"):SetValue(STR0045) //45
	oSectionA:Cell("OtrosDesc"):SetValue(STR0046) //46
	oSectionA:PrintLine()

	//Formato de Celdas
	G886Format(oSectionA, aCposNum, cPictVlr)
	G886Format(oSectionA, aCposFch, cPictDate)
	G886Format(oSectionA, {"Nro"}, cPictNro)

	cListCon := fGetConVig() //Se obtienen Conceptos Vigentes de S011.

	(cQrySRA)->(dbGoTop())

	While !(cQrySRA)->(EOF())
		//VALIDA OS DEMITIDOS NO PERÍODO SOLICITADO NOS PARÂMETROS.
		If !Empty((cQrySRA)->RA_DEMISSA) .And.  AnoMes((cQrySRA)->RA_DEMISSA) <> cPeriodo
			(cQrySRA)->(dbSkip())
			loop
		EndIf

		nDiasPag    := 0.00
		nHoraPag    := 0.00
		nHaberBas   := 0.00
		nBonoAntig  := 0.00
		nHoraExt    := 0.00
		nMontoHExt  := 0.00
		nHrsRecNoc  := 0.00
		nMonHExtN   := 0.00
		nHExtDomin  := 0.00
		nMonHExtDom := 0.00
		nDominTrab  := 0.00
		nMontDomTra := 0.00
		nNroDominic := 0.00
		nSalDominc  := 0.00
		nBonoProd   := 0.00
		nSubFront   := 0.00
		nOtrosBon   := 0.00
		nRcIVa      := 0.00
		nAporteCaja := 0.00
		nAporteAFP  := 0.00
		nOtrosDesc  := 0.00
		cMotRetir   := ""

		aPerAbe := {}
		aPerFec := {}

		RetPerAbertFech( 	cProcesso ,; // Processo selecionado na Pergunte.
							cRoteiro ,; // Roteiro selecionado na Pergunte.
							cPeriodo ,;// Periodo selecionado na Pergunte.
							cSemana ,;// Numero de Pagamento selecionado na Pergunte.
							NIL ,;   // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
							NIL ,;  // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
							@aPerAbe ,;// Retorna array com os Periodos e NrPagtos Abertos
							@aPerFec )            // Retorna array com os Periodos e NrPagtos Fechados

		aVerbasFunc	:= RetornaVerbasFunc(	(cQrySRA)->RA_FILIAL,; // Filial do funcionario corrente
											(cQrySRA)->RA_MAT,; // Matricula do funcionario corrente
											NIL,;               //
											cRoteiro,;          // Roteiro selecionado na pergunte
											aVerbasFilter,;     // aVerbasFilter
											aPerAbe,;           // Array com os Periodos e Numero de pagamento abertos
											aPerFec)            // Array com os Periodos e Numero de pagamento fechados
		For nReg := 1 To Len(aVerbasFunc)
			nPos := aScan( aConceps,{|x| x[1] == aVerbasFunc[nReg][03]} )

			If Alltrim(aVerbasFunc[nReg][3]) $ cListCon //Conceptos calculados adicionales, que estan configurados en S011.
				nAporteAFP += aVerbasFunc[nReg][7]
			EndIf

			If nPos > 0
				If Alltrim(aConceps[nPos][3]) $ "0031/0048" //Días pagados (26)
					nDiasPag += aVerbasFunc[nReg][6]
				ElseIf Alltrim(aConceps[nPos][3]) == "0671" //Bono de antigüedad (29)
					nBonoAntig += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][3]) == "1276" //Subsidio frontera (41)
					nSubFront += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][3]) == "0066" //RC-IVA (43)
					nRcIVa += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][3]) == "0736" //Aporte caja de salud (44)
					nAporteCaja += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][3]) == "0769" //Aporte AFP (45)
					nAporteAFP += aVerbasFunc[nReg][7]
				EndIf

				If Alltrim(aConceps[nPos][2]) == "28" //Haber básico (28)
					nHaberBas += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "30" //Horas extra (30) y Monto horas extra (31)
					nHoraExt += aVerbasFunc[nReg][6]
					nMontoHExt += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "32" //Horas recargo nocturno (32) y Monto horas extra nocturnas (33)
					nHrsRecNoc += aVerbasFunc[nReg][6]
					nMonHExtN += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "34" //Horas extra dominicales (34) y Monto horas extra dominicales (35)
					nHExtDomin += aVerbasFunc[nReg][6]
					nMonHExtDom += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "36" //Domingos trabajados (36) y Monto domingos trabajados (37)
					nDominTrab += aVerbasFunc[nReg][6]
					nMontDomTra += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "38" //Nro. dominicales (38) y Salario dominical (39)
					nNroDominic += aVerbasFunc[nReg][6]
					nSalDominc += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "40" //Bono producción (40)
					nBonoProd += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "42" //Otros bonos y pagos (42)
					nOtrosBon += aVerbasFunc[nReg][7]
				ElseIf Alltrim(aConceps[nPos][2]) == "46" //Otros descuentos (46)
					nOtrosDesc += aVerbasFunc[nReg][7]
				EndIf
			EndIf
		Next nReg

		If !Empty((cQrySRA)->RA_DEMISSA)
			cMotRetir := fObtMotRet((cQrySRA)->RA_FILIAL, (cQrySRA)->RA_MAT)//Obtiene Motivo de Retiro
			oSectionA:Cell("FchRetiro"):Show() //17
		Else
			oSectionA:Cell("FchRetiro"):Hide() //17
		EndIf

		oSectionA:Cell("Nro"):SetValue(nNro) //01
		oSectionA:Cell("TipoDoc"):SetValue((cQrySRA)->RA_TIPODOC) //02
		oSectionA:Cell("NumDoc"):SetValue((cQrySRA)->RA_CIC) //03
		oSectionA:Cell("LugarExp"):SetValue((cQrySRA)->RA_UFCI) //04
		oSectionA:Cell("FchNac"):SetValue(Transform((cQrySRA)->RA_NASC, cPictDate)) //05
		oSectionA:Cell("Paterno"):SetValue((cQrySRA)->RA_PRISOBR) //06
		oSectionA:Cell("Materno"):SetValue((cQrySRA)->RA_SECSOBR) //07
		oSectionA:Cell("Nombre"):SetValue((cQrySRA)->(Alltrim(RA_PRINOME) + " " + Alltrim(RA_SECNOME))) //08
		If lBolPais
			oSectionA:Cell("Pais"):SetValue(fDesc("SX5", "SW" + (cQrySRA)->RA_CPAISOR, "X5_DESCSPA")) //09
		EndIf
		oSectionA:Cell("Sexo"):SetValue((cQrySRA)->RA_SEXO) //10
		oSectionA:Cell("Jubilado"):SetValue(IIf((cQrySRA)->RA_JUBILAC == "1", "1", "0")) //11
		oSectionA:Cell("AportaAFP"):SetValue(IIf(Empty((cQrySRA)->RA_AFPOPC), "0", "1")) //12
		oSectionA:Cell("Discapac"):SetValue(IIf((cQrySRA)->RA_TPDEFFI == "0", "0", "1")) //13
		If lBolAtu
			oSectionA:Cell("TutorDisc"):SetValue(IIf(Empty((cQrySRA)->RA_TUTORDF), 0, (cQrySRA)->RA_TUTORDF)) //14
		EndIf
		oSectionA:Cell("FchIngreso"):SetValue(Transform((cQrySRA)->RA_ADMISSA, cPictDate)) //15
		oSectionA:Cell("FchRetiro"):SetValue(Transform((cQrySRA)->RA_DEMISSA, cPictDate)) //16
		oSectionA:Cell("MotRetiro"):SetValue(cMotRetir) //17
		oSectionA:Cell("CajaSalud"):SetValue((cQrySRA)->RA_CAJSAL) //18
		oSectionA:Cell("AFPAporta"):SetValue((cQrySRA)->RA_TPAFP) //19
		oSectionA:Cell("NuaCua"):SetValue((cQrySRA)->RA_NRNUA) //20
		oSectionA:Cell("Sucursal"):SetValue((cQrySRA)->RA_SUCUBIC) //21
		oSectionA:Cell("ClasfLab"):SetValue(Val((cQrySRA)->RA_CLASLAB)) //22
		oSectionA:Cell("Cargo"):SetValue(IIf(!Empty((cQrySRA)->RA_CODFUNC), fObtDesCar((cQrySRA)->RA_CODFUNC), "")) //23
		oSectionA:Cell("ModContrat"):SetValue((cQrySRA)->RA_TPCONTM) //24
		oSectionA:Cell("TipoContr"):SetValue((cQrySRA)->RA_TIPCONT) //25
		oSectionA:Cell("DiasPag"):SetValue(nDiasPag) //26
		oSectionA:Cell("HoraPag"):SetValue((cQrySRA)->RA_HRSDIA) //27
		oSectionA:Cell("HaberBas"):SetValue(Transform(nHaberBas, cPictVlr)) //28
		oSectionA:Cell("BonoAntig"):SetValue(Transform(nBonoAntig, cPictVlr)) //29
		oSectionA:Cell("HoraExt"):SetValue(nHoraExt) //30
		oSectionA:Cell("MontoHExt"):SetValue(Transform(nMontoHExt, cPictVlr)) //31
		oSectionA:Cell("HrsRecNoc"):SetValue(nHrsRecNoc) //32
		oSectionA:Cell("MonHExtN"):SetValue(Transform(nMonHExtN, cPictVlr)) //33
		oSectionA:Cell("HExtDomin"):SetValue(nHExtDomin) //34
		oSectionA:Cell("MonHExtDom"):SetValue(Transform(nMonHExtDom, cPictVlr)) //35
		oSectionA:Cell("DominTrab"):SetValue(nDominTrab) //36
		oSectionA:Cell("MontDomTra"):SetValue(Transform(nMontDomTra, cPictVlr)) //37
		oSectionA:Cell("NroDominic"):SetValue(nNroDominic) //38
		oSectionA:Cell("SalDominc"):SetValue(Transform(nSalDominc, cPictVlr)) //39
		oSectionA:Cell("BonoProd"):SetValue(Transform(nBonoProd, cPictVlr)) //40
		oSectionA:Cell("SubFront"):SetValue(Transform(nSubFront, cPictVlr)) //41
		oSectionA:Cell("OtrosBon"):SetValue(Transform(nOtrosBon, cPictVlr)) //42
		oSectionA:Cell("RC-Iva"):SetValue(Transform(nRcIVa, cPictVlr)) //43
		oSectionA:Cell("AporteCaja"):SetValue(Transform(nAporteCaja, cPictVlr)) //44
		oSectionA:Cell("AporteAFP"):SetValue(Transform(nAporteAFP, cPictVlr)) //45
		oSectionA:Cell("OtrosDesc"):SetValue(Transform(nOtrosDesc, cPictVlr)) //46
		oSectionA:PrintLine()

		nNro += 1
		(cQrySRA)->(DbSkip())
	EndDo

	oSectionA:Finish()
	(cQrySRA)->(dbCloseArea())

Return Nil

/*/{Protheus.doc}G886Format()
Da formato a Celdas
@author Luis Arturo Samaniego Guzman
@since 31/10/2018
@version P12
/*/
Static Function G886Format(oSectionA, aCells, cPict)
Local nCel := 0

	For nCel := 1 To Len(aCells)
		oSectionA:Cell(aCells[nCel]):SetPicture(cPict)
	Next nCel
Return Nil

/*/{Protheus.doc}fObtMotRet()
Obtiene motivo de retiro
@author Luis Arturo Samaniego Guzman
@since 31/10/2018
@version P12
/*/
Static Function fObtMotRet(cFilEmp, cMatEmp)
Local cMotRetir := ""

	dbSelectArea("SRG")
	SRG->(dbSetOrder(2)) //RG_FILIAL+RG_MAT+RG_ROTEIR+DTOS(RG_DATAHOM)
	If SRG->(msSeek(xFilial("SRG",cFilEmp) + cMatEmp + "FIN"))
		cMotRetir := SRG->RG_TIPORES
	EndIf

Return cMotRetir

/*/{Protheus.doc}fObtDesCar()
Obtiene descripcion de Cargo en base a Codigo de Funcion (RA_CODFUNC).
@author Marco Augusto Gonzalez Rivera
@since 29/11/2018
@version P12
/*/
Static Function fObtDesCar(cCodFunc)

	Local cFilSRJ		:= xFilial("SRJ")
	Local cDescCargo	:= ""

	DBSelectArea("SRJ")
	SRJ->(DBSetOrder(1)) //RJ_FILIAL+RJ_FUNCAO
	If SRJ->(MSSeek(cFilSRJ + cCodFunc))
		cDescCargo := SRJ->RJ_DESC
	EndIf

Return cDescCargo

/*/{Protheus.doc}ObtConcSRV()
Obtiene Conceptos
@author Luis Arturo Samaniego Guzman
@since 30/10/2018
@version P12
/*/
Static Function ObtConcSRV(aVerbasFilter, aConceps)
Local cFilSRV	   := xFilial("SRV")

	SRV->(DBSetOrder(1)) //RV_FILIAL+RV_COD
	SRV->(MsSeek(cFilSRV))

	aConceps := {}
	aVerbasFilter := {}
	SRV->(DBEval( {|| IF(!Empty(SRV->RV_CODFOL) .Or. Empty(SRV->RV_CODFOL) .Or. !Empty(SRV->RV_INFMES), AAdd(aVerbasFilter, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	SRV->(DBEval( {|| IF(!Empty(SRV->RV_CODFOL) .Or. Empty(SRV->RV_CODFOL) .Or. !Empty(SRV->RV_INFMES), AAdd(aConceps, {SRV->RV_COD, SRV->RV_INFMES, SRV->RV_CODFOL}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )

Return Nil

/*/{Protheus.doc}G886TpConc()
Opciones de Tipo de Conceptos
Sueldos, Salarios y Accidentes de Trabajo
@author Luis Arturo Samaniego Guzman
@since 30/10/2018
@version P12
/*/
Function G886TpConc()
Local cTitulo  := ""
Local MvParDef := ""
Local lRet     := .T.
Local MvPar
Local cHaberBas := STR0048 //"28 - Haber básico"
Local cHrsExtra := STR0049 //"30 - Horas Extras"
Local cHrsExNoc := STR0050 //"32 - Horas Extras Nocturnas"
Local cHrsExDom := STR0051 //"34 - Horas Extras Dominicales"
Local cDiaDomTr := STR0052 //"36 - Días domingos trabajados"
Local cDominGan := STR0066 //"38 - Dominicales Ganados."
Local cBonoProd := STR0053 //"40 - Bono de Producción"
Local cConcIngr := STR0054 //"42 - Conceptos de Ingreso"
Local cConcDesc := STR0055 //"46 - Conceptos de Descuento"

Private aInc	:= {}

	aInc := {cHaberBas, cHrsExtra, cHrsExNoc, cHrsExDom, cDiaDomTr, cDominGan, cBonoProd, cConcIngr, cConcDesc}

	MvParDef := "283032343638404246"
	cTitulo  := STR0047  //"Sueldos, Salarios y Accidentes de Trabajo"

	f_Opcoes(@MvPar,cTitulo,aInc,MvParDef,12,101,.T.,2)

	VAR_IXB := MvPar

Return .T.

/*/{Protheus.doc}G886ClsLab()
Opciones de Clasificación laboral
Sueldos, Salarios y Accidentes de Trabajo
@author Luis Arturo Samaniego Guzman
@since 31/10/2018
@version P12
/*/
Function G886ClsLab()
Local cTitulo  := ""
Local MvParDef := ""
Local lRet     := .T.
Local MvPar

Private aInc	:={}

	aInc := {STR0056, STR0057, STR0058, STR0059, STR0060, STR0061, STR0062, STR0063, STR0064, STR0065}

	MvParDef := "01020304050607080910"
	cTitulo  := STR0047  //"Sueldos, Salarios y Accidentes de Trabajo"

	f_Opcoes(@MvPar,cTitulo,aInc,MvParDef,12,101,.T.,2)

	VAR_IXB := MvPar

Return .T.

/*/{Protheus.doc}fGetConVig()
Obtiene conceptos vigentes especificados en la tabla S011.
@author Marco Augusto Gonzalez Rivera
@return String con conceptos vigentes
@since 29/11/2018
@version P12
/*/
Static Function fGetConVig()

	Local cConceptos	:= ""
	Local cQueryRCC		:= ""
	Local cFilRCC		:= xFilial("RCC")
	Local cTempTab		:= GetNextAlias()
	Local nTamConten	:= 0

	cQueryRCC := "SELECT RCC_CHAVE, RCC_CONTEU "
	cQueryRCC += "FROM " + RetSqlName("RCC") + " RCC "
	cQueryRCC += "WHERE RCC_FILIAL = '" + cFilRCC + "' "
	cQueryRCC += "AND RCC_CODIGO = 'S011' "
	cQueryRCC += "AND RCC.D_E_L_E_T_ = ' '"

	cQueryRCC := ChangeQuery(cQueryRCC)
	DBUseArea(.T., "TOPCONN", TCGENQRY( , , cQueryRCC), cTempTab, .F., .T.)

	While (cTempTab)->(!Eof())
		If Empty((cTempTab)->RCC_CHAVE) //Si esta vacio, indica que es vigente.
			nTamConten := Len(RTrim((cTempTab)->RCC_CONTEU))
			cConceptos += SubStr((cTempTab)->RCC_CONTEU, nTamConten - 2, 3) + ","
		EndIf
		(cTempTab)->(DBSkip())
	EndDo

	(cTempTab)->(DBCloseArea())

Return cConceptos
