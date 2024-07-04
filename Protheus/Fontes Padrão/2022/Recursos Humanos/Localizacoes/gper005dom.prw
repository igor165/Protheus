#INCLUDE "PROTHEUS.CH"  
#INCLUDE "GPER005DOM.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER002DOM ³ Autor ³  Alfredo Medrano               ³ Data ³ 30/06/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reporte DGT 3                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER005DOM()                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³      FNC      ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marco A. Glz³11/08/17³   DMINA-171   ³Se realiza replica para V12.1.14 de        ³±±
±±³            ³        ³               ³DMINA-53 Reporte DGT-3.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER005DOM()

	Local cPerg		:= "GPR005DOM"
	Local oReport	:= Nil
	Local aGetArea	:= GetArea()

	Private cNomeProg	:= "GPER005DOM"
	Private cAliasTmp	:= CriaTrab(Nil,.F.)	  
	
	//Variables de entrada (parámetros) 
	Private cFilIni	:= ""   //De Sucursal
	Private cFilFin	:= ""	//A Sucursal
	Private cProIni	:= ""   //De Proceso
	Private cProFin	:= ""   //A Proceso
	Private cMatIni	:= ""	//De Matricula
	Private cMatFin	:= ""	//A Matricula
	Private cPerAut	:= ""	//Periodo 

	Pergunte(cPerg, .F.)
	
	If !TodoOk()
		Return
	EndIf

	oReport := ReportDef(cPerg)  
	oReport:PrintDialog() 

	RestArea(aGetArea)	

Return (Nil)
   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef ³ Autor ³  Alfredo Medrano      ³ Data ³ 30/06/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Def. Reporte de personal fijo DGT-3                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportDef(cExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.-Nombre de la pregunta                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER862                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(cPerg)

	Local aArea		:= GetArea()
	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil

	Private cTitulo := OemToAnsi(STR0002)//"Reporte DGT 3" 
	
	cTitulo := Trim(cTitulo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New(cNomeProg, OemToAnsi(cTitulo), cPerg, {|oReport| PrintReport(oReport)})
	oReport:nColSpace	:= 0
	oReport:nFontBody	:= 7 // Define o tamanho da fonte.
	oReport:cFontBody	:= "COURIER NEW"
	oReport:SetLandScape(.T.)//Pag Horizontal
	oReport:lHeaderVisible	:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                  ³
	//³TRCell():New                                              ³
	//³ExpO1 : Objeto TSection que a secao pertence              ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado³
	//³ExpC3 : Nome da tabela de referencia da celula            ³
	//³ExpC4 : Titulo da celula                                  ³
	//³        Default : X3Titulo()                              ³
	//³ExpC5 : Picture                                           ³
	//³        Default : X3_PICTURE                              ³
	//³ExpC6 : Tamanho                                           ³
	//³        Default : X3_TAMANHO                              ³
	//³ExpL7 : Informe se o tamanho esta em pixel                ³
	//³        Default : False                                   ³
	//³ExpB8 : Bloco de código para impressao.                   ³
	//³        Default : ExpC2                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Creación de la Primera Sección:  Encabezado 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection1 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection1:SetHeaderSection(.F.) //Exibe Cabecalho da Secao
	oSection1:SetHeaderPage(.F.) //Exibe Cabecalho da Secao
	oSection1:SetLeftMargin(3)

	TRCell():New(oSection1, "TITLE1", , , , )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Creación de la Segunda Sección:  Encabezado de detalle ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection2 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection2:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	oSection2:SetLeftMargin(1)

	TRCell():New(oSection2, "TipMov"		, , "", , 8 , , , "LEFT", , )
	TRCell():New(oSection2, "TipDoc"		, , "", , 8 , , , "LEFT", , )
	TRCell():New(oSection2, "NumDoc"		, , "", , 11, , , "LEFT", , )
	TRCell():New(oSection2, "Nombre"		, , "", , 15, , , "LEFT", , )
	TRCell():New(oSection2, "1erApellido"	, , "", , 15, , , "LEFT", , )
	TRCell():New(oSection2, "2doApellido"	, , "", , 15, , , "LEFT", , )
	TRCell():New(oSection2, "Sexo"			, , "", , 5 , , , "LEFT", , )
	TRCell():New(oSection2, "Nacio"			, , "", , 30, , , "LEFT", , )
	TRCell():New(oSection2, "FecNac"		, , "", , 10, , , "LEFT", , )
	TRCell():New(oSection2, "SalCot"		, , "", , 14, , , "CENTER", , )
	TRCell():New(oSection2, "FechIng"		, , "", , 10, , , "LEFT", , )
	TRCell():New(oSection2, "FechSal"		, , "", , 10, , , "LEFT", , )
	TRCell():New(oSection2, "Ocupac"		, , "", , 7 , , , "LEFT", , )
	TRCell():New(oSection2, "Descri"		, , "", , 15, , , "LEFT", , )
	TRCell():New(oSection2, "IniVac"		, , "", , 10, , , "LEFT", , )
	TRCell():New(oSection2, "FinVac"		, , "", , 10, , , "LEFT", , )
	TRCell():New(oSection2, "Turno"			, , "", , 6 , , , "LEFT", , )
	TRCell():New(oSection2, "IdEst"			, , "", , 7 , , , "LEFT", , )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Creación de la Tercera Sección: Detalle ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection3 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection3:SetHeaderSection(.F.) //Exibe Cabecalho da Secao
	oSection3:SetHeaderPage(.F.) //Exibe Cabecalho da Secao
	oSection3:SetLeftMargin(1)
	oSection3:SetLineStyle(.F.) //Pone titulo del campo y aun lado el y valor
	
	TRCell():New(oSection3, "TipMov"		, , STR0007, 					, 8 , , , , , "LEFT")
	TRCell():New(oSection3, "TipDoc"		, , STR0008, 					, 2 , , , , , "LEFT")
	TRCell():New(oSection3, "NumDoc"		, , STR0009, 					, TamSX3("RA_CIC")[1], , , , , "LEFT")
	TRCell():New(oSection3, "Nombre"		, , STR0010, 					, 15, , , , , "LEFT")
	TRCell():New(oSection3, "1erApellido"	, , STR0011, 					, 15, , , , , "LEFT")
	TRCell():New(oSection3, "2doApellido"	, , STR0012, 					, 15, , , , , "LEFT")
	TRCell():New(oSection3, "Sexo"			, , STR0013, 					, 5 , , , , , "LEFT")
	TRCell():New(oSection3, "Nacio"			, , STR0014, 					, 30, , , , , "LEFT") //Nacionalidad
	TRCell():New(oSection3, "FecNac"		, , STR0015, 					, 10, , , , , "LEFT") //Fecha de Nacimiento
	TRCell():New(oSection3, "SalCot"		, , STR0016, "999,999,999.99"	, 14, , , , , "LEFT") //Salario
	TRCell():New(oSection3, "FechIng"		, , STR0017, 					, 10, , , , , "LEFT") //Fecha Ingreso
	TRCell():New(oSection3, "FechSal"		, , STR0018, 					, 10, , , , , "LEFT") //Fecha Baja
	TRCell():New(oSection3, "Ocupac"		, , STR0019, 					, 6 , , , , , "LEFT") //Ocupacion/Cargo
	TRCell():New(oSection3, "Descri"		, , STR0020, 					, 15, , , , , "LEFT") //Descripcion de Ocupacion/Cargo
	TRCell():New(oSection3, "IniVac"		, , STR0021, 					, 10, , , , , "LEFT") //Fecha de Inicio de Vacaciones
	TRCell():New(oSection3, "FinVac"		, , STR0022, 					, 10, , , , , "LEFT") //Fecha de Fin de Vacaciones
	TRCell():New(oSection3, "Turno"			, , STR0023, 					, 6 , , , , , "LEFT") //Turno
	TRCell():New(oSection3, "IdEst"			, , STR0024, 					, TamSX3("RA_KEYLOC")[1], , , , , "LEFT")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Creación de la Quinta Sección:  Pie de Pagina ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection4 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection4:SetHeaderSection(.F.) //Exibe Cabecalho da Secao
	oSection4:SetHeaderPage(.F.) //Exibe Cabecalho da Secao
	oSection4:SetLeftMargin(3)

	TRCell():New(oSection4, "TITLE", , , , /*Tamañano de la hoja*/) //"Atención"

	oSection1:nLinesBefore	:= 0	
	oSection2:nLinesBefore	:= 0	
	oSection3:nLinesBefore	:= 0	
	oSection4:nLinesBefore	:= 0

Return (oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintReport³Autor ³ FMonroy               ³ Data ³29/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impresion del Informe                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PrintReport(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1.-Objeto del reporte                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER862                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport) 

	Local oSection3	:= oReport:Section(3)	 
	Local oSection1	:= oReport:Section(1)    
	Local aHistoric	:= {}    
	Local nReg		:= 0
	Local nCont		:= 0
	Local aFecRcp	:= {}
	Local dFecSal	:= CTOD("//") // Fecha Salario
	Local cNac 		:= ""
	Local dEmpVac	:= STOD("//")
	Local dFecIni	:= CTOD("01/01/" + cPerAut)
	Local dFecFin	:= CTOD("31/12/" + cPerAut)
	Local cMat		:= ""
	Local cTipMov	:= ""
	Local cSucAnt	:= ""
	Local cSucInt	:= ""
	Local lAct		:= .f.
	Local nloop		:= 0
	
	GPM005DQ()
	
	TcSetField(cAliasTmp, "RA_ADMISSA"	, "D", 8, 0)
	TcSetField(cAliasTmp, "RA_DEMISSA"	, "D", 8, 0)
	TcSetField(cAliasTmp, "RA_NASC"		, "D", 8, 0)
	TcSetField(cAliasTmp, "RCP_DTMOV"	, "D", 8, 0)
	
	Count To nReg
	(cAliasTmp)->(DBGoTop())
	oReport:SetMeter(nReg)  
	If (cAliasTmp)->(!Eof())
		//Imprime Encabezado  
		oReport:OnPageBreak({|| Gper862En2(oReport,1,(cAliasTmp)->RA_FILIAL), Gper862En3(oReport), oReport:FatLine()}, .F.)
		oSection3:Init()
		oSection1:Init()
		SX5->(dbselectArea('SX5'))
		SX5->(dbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
		While (cAliasTmp)->(!EOF())
			
			nCont++		
			If nCont == 1 .Or. cSucAnt != (cAliasTmp)->RA_FILIAL
				oReport:EndPage(.T.)//termina y salta página
			EndIf
			cSucInt := (cAliasTmp)->RA_FILIAL
			cSucAnt := (cAliasTmp)->RA_FILIAL
			nloop:= 0
			While (cAliasTmp)->(!EOF()) .AND. cSucInt == (cAliasTmp)->RA_FILIAL
				cTipMov	:= STR0029 // Ingreso 	
				cNac	:= ""
				aFecRcp	:= {}
				cMat	:= (cAliasTmp)->RA_MAT
				lAct	:= .f.
				nloop++
				
				//Validar si es Cedula de identidad/No. Pasaporte
				If !Empty((cAliasTmp)->RA_CIC)
					cDocto		:= (cAliasTmp)->RA_CIC //Cedula
					cTipoDoc	:= 'C'
				ElseIf !Empty((cAliasTmp)->RA_PASSPOR)
					cDocto		:= (cAliasTmp)->RA_PASSPOR //Pasaporte
					cTipoDoc	:= 'P'
				EndIf
				
				If SX5->(dbseek( xFilial('SX5') + '34' + AllTrim((cAliasTmp)->RA_NACIONA)))
					cNac := RTrim(SubStr(X5Descri(), 1, 20)) + " - " + AllTrim(SX5->X5_CHAVE)
				EndIf
				
				dEmpVac	:= STOD(cPerAut + MesDia((cAliasTmp)->RA_ADMISSA))
				
				oSection3:Cell("TipDoc"			):SetValue(cTipoDoc)//Tipo Doc
				oSection3:Cell("NumDoc"			):SetValue(cDocto)//Num Docto
				oSection3:Cell("Nombre"			):SetValue((cAliasTmp)->RA_PRINOME)//Nombe
				oSection3:Cell("1erApellido"	):SetValue((cAliasTmp)->RA_PRISOBR)//1er apellido
				oSection3:Cell("2doApellido"	):SetValue((cAliasTmp)->RA_SECSOBR)//2do apellido
				oSection3:Cell("Sexo"			):SetValue((cAliasTmp)->RA_SEXO)//sexo
				oSection3:Cell("Nacio"			):SetValue(cNac)//Nacionalidad
				oSection3:Cell("FecNac"			):SetValue((cAliasTmp)->RA_NASC)//Fecha Nacimiento
				oSection3:Cell("SalCot"			):SetValue((cAliasTmp)->RA_SALARIO)//Salario
				oSection3:Cell("FechIng"		):SetValue((cAliasTmp)->RA_ADMISSA)//Fecha ingreso
				oSection3:Cell("FechSal"		):SetValue((cAliasTmp)->RA_DEMISSA)//Fecha Salida
				oSection3:Cell("Ocupac"			):SetValue((cAliasTmp)->Q3_OCUPAC)//ocupacion
				oSection3:Cell("Descri"			):SetValue((cAliasTmp)->Q3_DESCSUM)//Descripción de ocupación
				oSection3:Cell("IniVac"			):SetValue(STOD(cPerAut + MesDia((cAliasTmp)->RA_ADMISSA)))//Fecha Inicio Vacaciones
				oSection3:Cell("FinVac"			):SetValue(GPM005DH(dEmpVac, 14))//Fecha Fin Vacaciones
				oSection3:Cell("Turno"			):SetValue('2')//Turno
				oSection3:Cell("IdEst"			):SetValue((cAliasTmp)->RA_KEYLOC)//Id Establecimiento
				
				//Tipo de Movimiento
				If (cAliasTmp)->RA_SITFOLH == 'D' //situación 
					If (cAliasTmp)->RA_DEMISSA  <  dFecFin
						aAdd(aFecRcp,{(cAliasTmp)->RA_DEMISSA, STR0028}) // "Baja"
						lAct := .T.
					EndIf
				Else 
					aAdd(aFecRcp,{(cAliasTmp)->RA_ADMISSA, STR0029}) // "Ingreso"
				EndIf
				
				While (cAliasTmp)->(!Eof()) .AND. ((cAliasTmp)->RA_FILIAL == (cAliasTmp)->RCP_FILIAL .OR. Empty((cAliasTmp)->RCP_FILIAL) ) .AND. cMat == (cAliasTmp)->RA_MAT    
					If (cAliasTmp)->RCP_TPMOV == '05' .AND. !lAct 
						aAdd(aFecRcp,{(cAliasTmp)->RCP_DTMOV, STR0030}) // "Cambio"
					Endif
					(cAliasTmp)->(DBSkip())
				EndDo
				
				If Len(aFecRcp) > 0
					Asort(aFecRcp, , , {|x, y| x[1] > y[1]})
					cTipMov := aFecRcp[1,2]
				EndIf
				
				oSection3:Cell("TipMov"):SetValue(cTipMov)//Tipo Movimiento
				
				oSection3:PrintLine()
				oReport:IncMeter()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Total Registros ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			Gper862Ob(oReport, nloop)
		EndDo
	EndIf
	
	oReport:EndPage()
	(cAliasTmp)->(DBCloseArea()) 

Return (Nil)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gper862En2³ Autor ³ Alfredo Medrano       ³ Data ³30/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Gper862En2(oExp1,nExp1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport                                       ³±±
±±³          ³nExp1: Bandera(1 Imprime Encabezado 2 Imprime Pie de Pag.)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gper862En2(oReport, nT, cFilialRa)

	Local oSection1	:= oReport:Section(1)
	Local nPosS012	:= 0
	Local nPosS112	:= 0
	Local nPosS001	:= 0
	Local nIdx		:= 1

	Local cFilOri	:= SM0->M0_CODFIL
	Local cCedula	:= "" 
		
	cCedula := IIf(nIdx > 0, fTabela("S012", nIdx, 5), "")

	DBSelectArea("SM0")
	SM0->(DBSeek(cEmpAnt+cFilialRa,.T.))

	nPosS001 := FPosTab("S001", Val(ALLTRIM(SM0->M0_CEPENT)), "=", 4)
	nPosS012 := FPosTab("S012", cFilialRa, "=", 1)
	
	If nPosS012 == 0
		nPosS012 := FPosTab("S012", Space(Len(xFilial("RCB"))), "=", 1)
	Endif

	nPosS112 := FPosTab("S112", cFilialRa, "=", 1)
	If nPosS112 == 0
		nPosS112 := FPosTab("S112", Space(Len(xFilial("RCB"))), "=", 1)
	Endif

	IF nT == 1
		oSection1:Init()
		
		oSection1:Cell("TITLE1"):SetSize((oReport:GetWidth() / 3) / 14)
		oSection1:Cell("TITLE1"):SetValue(" ")
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0032) //"MINISTERIO DE TRABAJO"
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(" ")
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0001) //"Planilla de ARchivos DGT-3 "
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(" ")
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0003 + PADR(cCedula, 11)) //"    RNC o Cédula: " 
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0004 + "01" + AllTrim(Str(MV_PAR07))) //"         Período: "
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0005 +  STR0027 ) //"Tipo de Planilla: " - "DGT3"
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(" ")
		oSection1:PrintLine()

		oSection1:Finish()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Volta a empresa anteriormente selecionada.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("SM0")
	SM0->(DBSeek(cEmpAnt+cFilOri, .T.))
	cFilAnt := SM0->M0_CODFIL
	
Return (Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³Microsiga           º Data ³  05/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TodoOK(cPerg)

	Local lRet := .T.             
	
	Pergunte(cPerg, .F.)

	cFilIni   := MV_PAR01   //De Sucursal
	cFilFin   := MV_PAR02	//A Sucursal
	cProIni   := MV_PAR03   //De Proceso
	cProFin   := MV_PAR04   //A Proceso
	cMatIni   := MV_PAR05   //De Matricula
	cMatFin   := MV_PAR06   //A Matricula
	cPerAut   := AllTrim(str(MV_PAR07))   //año
	
	If Empty(cPerAut)  
		MsgInfo(STR0025) //"¡Informe el año del periodo a calcular!"
		lRet := .F. 
	Else
		If Len(cPerAut) != 4
			MsgInfo(STR0026) //" Informe un año valido "
			lRet := .F. 
		EndIf
	EndIf	  
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gper862En3³ Autor ³ Alfredo Medrano       ³ Data ³30/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado  2                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Gper862En3(oExp1)    			     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER862                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gper862En3(oReport)

	Local oSection2	:= oReport:Section(2)
	
	oSection2:Init()	

	oSection2:Cell("TipMov"			):SetValue(STR0007) //Tipo Movimiento
	oSection2:Cell("TipDoc"			):SetValue(STR0008) //Tipo Documento
	oSection2:Cell("NumDoc"			):SetValue(STR0009) // Nuimero documento	
	oSection2:Cell("Nombre"			):SetValue(STR0010) //"Nombres"
	oSection2:Cell("1erApellido"	):SetValue(STR0011) //"1er. Apellido"
	oSection2:Cell("2doApellido"	):SetValue(STR0012) //"2do. Apellido"   
	oSection2:Cell("Sexo"			):SetValue(STR0013) //"Sexo"
	oSection2:Cell("Nacio"			):SetValue(STR0014) //Nacionalidad
	oSection2:Cell("FecNac"			):SetValue(STR0015) //Fecha Nacimiento
	oSection2:Cell("SalCot"			):SetValue(STR0016) //Salario
	oSection2:Cell("FechIng"		):SetValue(STR0017) //Fecha ingreso
	oSection2:Cell("FechSal"		):SetValue(STR0018) //Fecha Salida
	oSection2:Cell("Ocupac"			):SetValue(STR0019) //ocupacion
	oSection2:Cell("Descri"			):SetValue(STR0020) //Descripción de ocupación
	oSection2:Cell("IniVac"			):SetValue(STR0021) //Fecha Inicio Vacaciones
	oSection2:Cell("FinVac"			):SetValue(STR0022) //Fecha Fin Vacaciones
	oSection2:Cell("Turno"			):SetValue(STR0023) //Turno
	oSection2:Cell("IdEst"			):SetValue(STR0024) //Id Establecimiento
	oSection2:PrintLine()	

	oSection2:Finish()

Return (Nil)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gper862Ob ³ Autor ³ Alf Medrano           ³ Data ³02/08/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Pie de Reporte                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Gper862Ob(oExp1, nExp1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER862                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gper862Ob(oReport, nI)

	Local oSection4	:= oReport:Section(4)
	
	Default nI	:= 0
	
	oSection4:Init()	
	oReport:SkipLine(1)
	
	oSection4:Cell("TITLE"):SetSize(oReport:GetWidth(), .T.)
	oSection4:Cell("TITLE"):SetValue(STR0031 + AllTrim(STR(nI))) //"Numero de Registros: "
	oSection4:PrintLine()

	oSection4:Finish()

Return (Nil)