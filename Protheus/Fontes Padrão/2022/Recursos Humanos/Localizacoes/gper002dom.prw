#INCLUDE "PROTHEUS.CH"  
#INCLUDE "GPER002DOM.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER002DOM ³ Autor ³  FMonroy                       ³ Data ³ 05/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reporte DGT 4                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER002DOM()                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³      FNC      ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V³02/02/12³0000018889/2011³ Correção do error log                     ³±±
±±³Christiane V³07/02/12³0000018889/2011³ Correção para geração em ambiente DB2     ³±±
±±³Raquel Hager³22/06/12³0000016148/2012³ Correcao na query devido a alteracao do   ³±±
±±³            ³        ³         TFFTV5³ campo RA_DATAALT para virtual.            ³±±
±±³  Marco A.  ³22/09/16³     TW8100    ³ Replica V12.1.7 a partir del llamado      ³±±
±±³            ³        ³               ³ TVRBWJ para Republica Dominicana.         ³±±
±±³  Marco A.  ³27/10/16³    TWJZLB     ³ Se modifica la impresion de la columna    ³±±
±±³            ³        ³               ³ Salario Cotizable (RV_CODFOL = 0019) para ³±±
±±³            ³        ³               ³ que se imprima en su lugar el valor del   ³±±
±±³            ³        ³               ³ RA_SALARIO por empleado. (DOM)            ³±±
±±³Alf. Medrano³14/07/17³    MMI-6365   ³ Replica MMI-5778 Se asigna RG7_RA_ACUMXX  ³±±
±±³            ³        ³               ³ al Salario Cotizable donde XX es el mes   ³±±
±±³            ³        ³               ³ seleccionado en el periodo cuando         ³±±
±±³            ³        ³               ³ RV_CODFOL = 0019                          ³±±
±±³Alf. Medrano³04/08/17³    DMINA-4    ³Se Modifica func PrintReport se quita query³±±
±±³            ³        ³               ³y se asigna en func GPR002DQ. Se incluye   ³±±
±±³            ³        ³               ³filtro de RA_CIC + RA_PASSPOR+ RA_NUMINSC  ³±±
±±³            ³        ³               ³se elimina func ObtIngresoy crea GPR002DI  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER002DOM()

	Local cPerg		:= "GPR002DOM"
	Local oReport	:= Nil 
	Local aGetArea	:= GetArea()

	Private cNomeProg	:= "GPER002DOM"
	Private cAliasTmp	:= CriaTrab(Nil, .F.)
	Private cSucI		:= ""
	Private cSucF		:= ""
	Private cProI		:= ""
	Private cProF		:= ""
	Private cMatI		:= ""
	Private cMatF		:= ""
	Private cMes		:= ""
	Private cAnio		:= ""
	Private nMesA		:= 0
	Private cPerAut		:= ""	//Periodo de autodeterminacion
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³mv_par01 - ¿De Filial?              ³
	//³mv_par02 - ¿A Filial?               ³
	//³mv_par03 - ¿De Proceso?             ³
	//³mv_par04 - ¿A Proceso?              ³
	//³mv_par05 - ¿De Matricula?           ³
	//³mv_par06 - ¿A Matricula?            ³
	//³mv_par07 - ¿Mes/Año Reportado       ³
	//³mv_par08 - ¿Tipo Autodeterminacion? ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg, .F.)

	oReport := ReportDef(cPerg)  
	oReport:PrintDialog() 

	RestArea(aGetArea)	

Return (Nil)
   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef ³ Autor ³ FMonroy               ³ Data ³29/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Def. Reporte de citas pendientes.                           ³±±
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

	Local aArea	:= GetArea() 

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil

	Private cTitulo := OemToAnsi(STR0078)//"Reporte DGT 4" 
	
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Creación de la Segunda Sección:  Encabezado 2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection2 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection2:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	oSection2:SetLeftMargin(3)

	TRCell():New(oSection2, "Clave"			, , , , 7	)
	TRCell():New(oSection2, "TipDoc"		, , , , 4	)
	TRCell():New(oSection2, "NumDoc"		, , , , 12	)		
	TRCell():New(oSection2, "Nombre"		, , , , 30	)
	TRCell():New(oSection2, "1erApellido"	, , , , 20	)
	TRCell():New(oSection2, "2doApellido"	, , , , 20	)
	TRCell():New(oSection2, "Sexo"			, , , , 5	)
	TRCell():New(oSection2, "FecNac"		, , , , 11	)
	TRCell():New(oSection2, "SalCot"		, , , , 14	)
	TRCell():New(oSection2, "AportVol"		, , , , 14	)
	TRCell():New(oSection2, "SalISR"		, , , , 14	)
	TRCell():New(oSection2, "OtrosRem"		, , , , 14	)
	TRCell():New(oSection2, "Remunerac"		, , , , 14	)
	TRCell():New(oSection2, "IngresosEx"	, , , , 14	)
	TRCell():New(oSection2, "SaldoFavor"	, , , , 14	)
	TRCell():New(oSection2, "SalInfotep"	, , , , 14	)
	TRCell():New(oSection2, "TipoIngr"		, , , , 5	)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Creación de la Tercer Sección: Detalle  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection3 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection3:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	oSection3:SetLeftMargin(3)
	oSection3:SetLineStyle(.F.)		//Pone titulo del campo y aun lado el y valor

	TRCell():New(oSection3, "Clave"			, cAliasTmp, , 						, 7		)
	TRCell():New(oSection3, "TipDoc"		, cAliasTmp, , 						, 4		)
	TRCell():New(oSection3, "NumDoc"		, cAliasTmp, , 						, 12	)
	TRCell():New(oSection3, "Nombre"		, cAliasTmp, , 						, 30	) //Nombre
	TRCell():New(oSection3, "1erApellido"	, cAliasTmp, , 						, 20	) //1er Apellido
	TRCell():New(oSection3, "2doApellido"	, cAliasTmp, , 						, 20	) //2do Apellido
	TRCell():New(oSection3, "Sexo"			, cAliasTmp, , 						, 5		) //Sexo
	TRCell():New(oSection3, "FecNac"		, cAliasTmp, , 						, 11	) //Fecha Nacimiento
	TRCell():New(oSection3, "SalCot"		, cAliasTmp, , "999,999,999.99"		, 14	) //Salario Cotizable
	TRCell():New(oSection3, "AportVol"		, cAliasTmp, , "999,999,999.99"		, 14	) //Aporte Volinaro
	TRCell():New(oSection3, "SalISR"		, cAliasTmp, , "999,999,999.99"		, 14	) //Salario ISR
	TRCell():New(oSection3, "OtrosRem"		, cAliasTmp, , "999,999,999.99"		, 14	) //Otras Remuneraciones
	TRCell():New(oSection3, "Remunerac"		, cAliasTmp, , "999,999,999.99"		, 14	) //Remuneraciones de Otros Empleados
	TRCell():New(oSection3, "IngresosEx"	, cAliasTmp, , "999,999,999.99"		, 14	) //Ingresos Exentos
	TRCell():New(oSection3, "SaldoFavor"	, cAliasTmp, , "999,999,999.99"		, 14	) //Saldo Favor
	TRCell():New(oSection3, "SalInfotep"	, cAliasTmp, , "999,999,999.99"		, 14	) //Salario Infotep
	TRCell():New(oSection3, "TipoIngr"		, cAliasTmp, , 						, 5		) //Tipo Ingreso
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Creación de la Cuarta Sección:  Pie de Pagina ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection4 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection4:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection4:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
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

	Local oSection3		:= oReport:Section(3)
	
	Local cSucActu		:= ""
	Local cTipoDoc		:= ""
	Local nTotal		:= 0
	Local nI			:= 0
	Local nConta		:= 0
	Local cLlaveUn		:= ""
	
	Private nSalCoti	:= 0
	Private nFol1040	:= 0
	Private nFol0015	:= 0
	Private nFol0084	:= 0
	Private nFol1118	:= 0
	Private nFol0544	:= 0
	Private nFol0477	:= 0
	Private nFol1179	:= 0

	TodoOk()
	Pergunte(oReport:GetParam(), .F.)
	
	GPR002DQ() //OBTIENE VALORES DE BASE DE DATOS
	
	Begin Sequence  
		DBSelectArea(cAliasTmp)
		Count To nTotal
		(cAliasTmp)->(DbGoTop()) 
		oReport:SetMeter(nTotal)  
		If (cAliasTmp)->(!Eof())
			//Imprime Encabezado  
			oReport:OnPageBreak({|| Gper862En2(oReport,1,(cAliasTmp)->RA_FILIAL), Gper862En3(oReport), oReport:FatLine()}, .F.)
			oReport:SkipLine(2)
			While (cAliasTmp)->(!Eof())
				nConta++	
				If nConta == 1 .Or. cSucActu != (cAliasTmp)->RA_FILIAL
					oReport:EndPage(.T.) //termina y salta página
				EndIf
				cSucActu := (cAliasTmp)->RA_FILIAL
				nI := 0
				//Imprime Detalle 
				cLlaveUn := ""
				
				oSection3:Init() 
				While (cAliasTmp)->(!Eof()) .And. cSucActu == (cAliasTmp)->RA_FILIAL
					IF cLlaveUn != (cAliasTmp)->RA_CIC + (cAliasTmp)->RA_PASSPOR + (cAliasTmp)->RA_NUMINSC
						nI++

						If !Empty(cLlaveUn)
							oSection3:PrintLine()
							oReport:IncMeter()
							nSalCoti := 0
							nFol1040 := 0
							nFol0015 := 0
							nFol0084 := 0
							nFol1118 := 0
							nFol0544 := 0
							nFol0477 := 0
							nFol1179 := 0
						EndIf 
						
						//Clave Nomina
						oSection3:Cell("Clave"):SetValue((cAliasTmp)->RA_NUMINSC)
						//Tipo Documento
						If !Empty((cAliasTmp)->RA_CIC)
							oSection3:Cell("TipDoc"):SetValue("C")
							cTipoDoc := "C"
						ElseIf !Empty((cAliasTmp)->RA_PASSPOR)
							oSection3:Cell("TipDoc"):SetValue("P")
							cTipoDoc := "P"
						Else
							oSection3:Cell("TipDoc"):SetValue("           ")
						EndIf
						//Numero de Documento
						If cTipoDoc == "C"
							oSection3:Cell("NumDoc"):SetValue((cAliasTmp)->RA_CIC)
						ElseIf cTipoDoc == "P"
							oSection3:Cell("NumDoc"):SetValue((cAliasTmp)->RA_PASSPOR)
						Else
							oSection3:Cell("NumDoc"):SetValue("")
						EndIf
						//Nombre Empleado
						oSection3:Cell("Nombre"):SetValue(AllTrim((cAliasTmp)->RA_PRINOME) + " " + AllTrim((cAliasTmp)->RA_SECNOME))
						//Primer Apellido Empleado
						oSection3:Cell("1erApellido"):SetValue((cAliasTmp)->RA_PRISOBR)
						//Segundo Apellido Empleado
						oSection3:Cell("2doApellido"):SetValue((cAliasTmp)->RA_SECSOBR)
						//Sexo del Empleado
						If (cAliasTmp)->RA_SEXO == "M"
							oSection3:Cell("Sexo"):SetValue("M")
						Else
							oSection3:Cell("Sexo"):SetValue("F")
						EndIf
						//Fecha de Nacimiento del Empleado
						oSection3:Cell("FecNac"):SetValue(STOD((cAliasTmp)->RA_NASC))
						oSection3:Cell("TipoIngr"):SetValue(IIf(GPR002DI((cAliasTmp)->RA_CIC, (cAliasTmp)->RA_PASSPOR, (cAliasTmp)->RA_NUMINSC ), "0004", (cAliasTmp)->RA_TIPOADM))
				
					EndIf
					obtValSal((cAliasTmp)->RV_CODFOL, (cAliasTmp)->RA_ACUMXX, oSection3 )
					cLlaveUn := (cAliasTmp)->RA_CIC + (cAliasTmp)->RA_PASSPOR + (cAliasTmp)->RA_NUMINSC 
		
				(cAliasTmp)->(DBSkip())	  

				EndDo //Fin de archivo
				
				oSection3:PrintLine()
				oReport:IncMeter()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime Total Registros ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
				Gper862Ob(oReport, nI)
				oReport:EndPage()
			EndDo
		EndIf //If fin de archivo 
	End Sequence
	(cAliasTmp)->(DBCloseArea()) 

Return (Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³obtValSal ³ Autor ³ Alf Medrano           ³ Data ³18/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtiene los montos de RG7                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³obtValSal(oExp1,nExp2,oExp3)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1: Codigo de Concepto                                   ³±±
±±³          ³nExp:  Valor Monetario                                      ³±±
±±³          ³oExp3: Objeto Treport                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function obtValSal(cCodFol, nAcum, oSection3 )
						
	IIf(cCodFol == "0019", nSalCoti := nAcum,)//Salario Cotizable						
	IIf(cCodFol == "1040", nFol1040 := nAcum,)//Aporte Volinaro
	IIf(cCodFol == "0015", nFol0015 := nAcum,)//Salario ISR
	IIf(cCodFol == "0084", nFol0084 := nAcum,)	//Otras Remuneraciones						
	IIf(cCodFol == "1118", nFol1118 := nAcum,)	//Remuneraciones de Otros Empleadores		
	IIf(cCodFol == "0544", nFol0544 := nAcum,)	//Ingresos Exentos			
	IIf(cCodFol == "0477", nFol0477 := nAcum,)	//Saldo a Favor
	IIf(cCodFol == "1179", nFol1179 := nAcum,)	//Salario Infotep
					
	oSection3:Cell("SalCot"		):SetValue(nSalCoti)
	oSection3:Cell("AportVol"	):SetValue(nFol1040)
	oSection3:Cell("SalISR"		):SetValue(nFol0015)
	oSection3:Cell("OtrosRem"	):SetValue(nFol0084)
	oSection3:Cell("Remunerac"	):SetValue(nFol1118)
	oSection3:Cell("IngresosEx"	):SetValue(nFol0544)
	oSection3:Cell("SaldoFavor"	):SetValue(nFol0477)
	oSection3:Cell("SalInfotep"	):SetValue(nFol1179)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gper862En2³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Gper862En2(oExp1,nExp1)     	     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     					      ³±±
±±³          ³nExp1: Bandera(1 Imprime Encabezado 2 Imprime Pie de Pag.)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER862                                                    ³±±
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
		
	cCedula	:= If(nIdx > 0, fTabela("S012", nIdx, 5), "")

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
		oSection1:Cell("TITLE1"):SetValue(STR0080) //"Plantilla de Archivo AutoDeterminación"
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0081 + IIf(MV_PAR08 == 1, "AM", "AR")) //"Tipo de Archivo: "
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0082 + PADR(cCedula, 11)) //"RNC o Cédula: 
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0083 + AllTrim(STR(MV_PAR07))) //"Período: "
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
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gper862En3³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado  2                                       ³±±
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

	oSection2:Cell("Clave"			):SetValue(STR0084) //"Clave"
	oSection2:Cell("TipDoc"			):SetValue(STR0085) //"Tipo"
	oSection2:Cell("NumDoc"			):SetValue(STR0086) //"Número"			
	oSection2:Cell("Nombre"			):SetValue(STR0087) //"Nombres"
	oSection2:Cell("1erApellido"	):SetValue(STR0088) //"1er. Apellido"
	oSection2:Cell("2doApellido"	):SetValue(STR0089) //"2do. Apellido"   
	oSection2:Cell("Sexo"			):SetValue(STR0090) //"Sexo"
	oSection2:Cell("FecNac"			):SetValue(STR0091) //"Fecha"
	oSection2:Cell("SalCot"			):SetValue(STR0092) //"Salario"
	oSection2:Cell("AportVol"		):SetValue(STR0093) //"Aporte"
	oSection2:Cell("SalISR"			):SetValue(STR0092) //"Salario"
	oSection2:Cell("OtrosRem"		):SetValue(STR0094) //"Otros"
	oSection2:Cell("Remunerac"		):SetValue(STR0110) //"Remune"
	oSection2:Cell("IngresosEx"		):SetValue(STR0095) //"Ingresos"
	oSection2:Cell("SaldoFavor"		):SetValue(STR0096) //"Saldo"
	oSection2:Cell("SalInfotep"		):SetValue(STR0092) //"Salario"
	oSection2:Cell("TipoIngr"		):SetValue(STR0085) //"Tipo"
	oSection2:PrintLine()

	oSection2:Cell("Clave"			):SetValue(STR0097) //"Nómina"
	oSection2:Cell("TipDoc"			):SetValue(STR0098) //"Doc."
	oSection2:Cell("NumDoc"			):SetValue(STR0099)	//"Documento"	
	oSection2:Cell("Nombre"			):SetValue(Space(1))
	oSection2:Cell("1erApellido"	):SetValue(Space(1))
	oSection2:Cell("2doApellido"	):SetValue(Space(1))  
	oSection2:Cell("Sexo"			):SetValue(Space(1))	
	oSection2:Cell("FecNac"			):SetValue(STR0100) //"Nacim"
	oSection2:Cell("SalCot"			):SetValue(STR0101) //"Cotizable"
	oSection2:Cell("AportVol"		):SetValue(STR0102) //"Volinaro"
	oSection2:Cell("SalISR"			):SetValue(STR0103) //"ISR"
	oSection2:Cell("OtrosRem"		):SetValue(STR0104) //"Resume"
	oSection2:Cell("Remunerac"		):SetValue(STR0111) //"Otros Emp"
	oSection2:Cell("IngresosEx"		):SetValue(STR0105) //"Exentos"
	oSection2:Cell("SaldoFavor"		):SetValue(STR0106) //"Favor"
	oSection2:Cell("SalInfotep"		):SetValue(STR0107) //"Infotep"
	oSection2:Cell("TipoIngr"		):SetValue(STR0108) //"Ingreso"
	oSection2:PrintLine()

	oSection2:Finish()

Return (Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gper862Ob ³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Pie de Reporte                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Gper862Ob(oExp1, nExp1)		     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER862                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gper862Ob(oReport, nI)

	Local oSection4	:= oReport:Section(4)
	Default nI		:= 0
	
	oSection4:Init()	
	oReport:SkipLine(1)
	
	oSection4:Cell("TITLE"):SetSize(oReport:GetWidth(), .T.)
	oSection4:Cell("TITLE"):SetValue(STR0109 + AllTrim(STR(nI))) //"Numero de Registros: "
	oSection4:PrintLine()

	oSection4:Finish()

Return (Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPR02DOM01³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacion de las preguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPR02DOM01()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X1_VALID - GPER862 En X1_ORDEM = 7                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPR02DOM01() 

	Local cMes := SubStr(StrZero(MV_PAR07, 6), 1, 2)

	IF Val(cMes) < 1 .Or. Val(cMes) > 12
		MsgInfo(STR0077) //"El mes debe ser de 1 a 12!"
		Return .F.
	EndIf                  

Return (.T.)

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

	Pergunte(cPerg, .F.)
	
	cSucI	:= MV_PAR01
	cSucF	:= MV_PAR02
	cProI	:= MV_PAR03
	cProF	:= MV_PAR04
	cMatI	:= MV_PAR05
	cMatF	:= MV_PAR06
	cMes	:= SubStr(StrZero(MV_PAR07, 6), 1, 2)
	cAnio	:= SubStr(StrZero(MV_PAR07, 6), 3, 4)
	nMesA	:= MV_PAR07
	cTipArch:= MV_PAR08
	cPerAut	:= StrZero(MV_PAR07,6)   //Periodo de autodeterminacion
	
Return (.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPR002DI  ³ Autor ³ Marco Augusto         ³ Data ³ 28/07/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que valida el tipo de ingreso del Empleado. (DOM)  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtAusen(cExp1, cExp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cExp1.- CIC del empleado.                                 ³±±
±±³          ³  cExp2.- Num Pasaporte.                                    ³±±
±±³          ³  cExp3.- tipo Nomina .                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER002DOM - Reporte Archivo DGT-4                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function GPR002DI(cCICEmp, cPaspor, cNumins)
	
	Local cAliasAus	:= CriaTrab(Nil,.F.)
	Local cAliasEmp	:= ""	   
	Local cSR8Name	:= InitSqlName("SR8")     
	Local cSRAName	:= InitSqlName("SRA") 
	Local cQuery	:= ""      
	Local nRegSR8	:= 0
	Local nRegSRA	:= 0    
	Local lRet		:= .F.                                                                               
	Local cUltDia	:= SubStr(DTOC(LastDay(CTOD('01/' + StrZero(Val(SubStr(cPerAut, 1, 2)), 2) + '/' + SubStr(cPerAut, 3, 6)))), 1, 2)
	Local cIniMes	:= DTOS(CTOD('01/' + StrZero(Val(SubStr(cPerAut, 1, 2)), 2) + '/' + SubStr(cPerAut, 3, 6)))
	Local cFinMes	:= DTOS(CTOD(cUltDia + '/' + StrZero(Val(SubStr(cPerAut, 1, 2)), 2) + '/' + SubStr(cPerAut, 3, 6)))      

	cQuery := "SELECT R8_FILIAL, R8_MAT"
	cQuery += " FROM " + cSR8Name + " SR8, " + cSRAName + " SRA"
	cQuery += " WHERE"
	cQuery += "	RA_CIC = '" + cCICEmp + "'"
	cQuery += "	AND RA_PASSPOR = '" + cPaspor + "'"
	cQuery += "	AND RA_NUMINSC = '" + cNumins + "'"
	cQuery += " AND R8_FILIAL = '" + xFilial("SR8", SRA->RA_FILIAL) + "'"
	cQuery += "	AND R8_FILIAL = RA_FILIAL"
	cQuery += "	AND R8_MAT = RA_MAT"
	cQuery += "	AND ((R8_DATAINI BETWEEN '" + cIniMes + "' AND '" + cFinMes + "')"
	cQuery += "	OR (R8_DATAFIM BETWEEN '" + cIniMes + "' AND '" + cFinMes + "'))"
	cQuery += "	AND R8_STATUS  = 'C'"
	cQuery += " AND SRA.D_E_L_E_T_= ' '"
	cQuery += " AND SR8.D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)      

	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAus,.T.,.T.)  
	Count To nRegSR8        

	//Hubo algun ausentismo 
	If nRegSR8 > 0
		lRet := .T.
		(cAliasAus)->(DbCloseArea())
	Else
		(cAliasAus)->(DbCloseArea())
		cAliasEmp := CriaTrab(Nil,.F.)
		
		cQuerySRA := "SELECT RA_MAT, RA_CIC, RA_PASSPOR"
		cQuerySRA += " FROM " + cSRAName + " SRA"
		cQuerySRA += " WHERE"
		cQuerySRA += " RA_CIC = '" + cCICEmp + "'" 
		cQuerySRA 	+= " AND RA_PASSPOR = '" + cPaspor + "'"
		cQuerySRA	+= " AND RA_NUMINSC = '" + cNumins + "'"
		cQuerySRA += " AND ((RA_ADMISSA BETWEEN '" + cIniMes + "' AND '" + cFinMes + "')"
		cQuerySRA += " OR (RA_FECREI BETWEEN '" + cIniMes + "' AND '" + cFinMes + "')"
		cQuerySRA += " OR (RA_DEMISSA BETWEEN '" + cIniMes + "' AND '" + cFinMes + "'))"
		cQuerySRA += " AND SRA.D_E_L_E_T_= ' '"
		cQuerySRA := ChangeQuery(cQuerySRA)      
	
		DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuerySRA), cAliasEmp, .T., .T.)  
		Count To nRegSRA
		        
	  If nRegSRA > 0
	  	lRet := .T.
	  EndIf
	  
	  (cAliasEmp)->(DbCloseArea())
	  
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPR002DQ  ³ Autor ³ Alf Medrano           ³ Data ³18/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ obtiene valores de la base de datos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPR002DQ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PrintReport                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPR002DQ()

	Local cSRAName	:= InitSqlName("SRA")
	Local cRG7Name	:= InitSqlName("RG7")
	Local cSRVName	:= InitSqlName("SRV")
	Local cQuery	:= ""     
	Local cCriterio	:= '01'
	Local cCodFol	:= "'1040', '0015', '0084', '1118', '0544', '0477', '1179', '0019'"
	
	cQuery := " SELECT RA_FILIAL, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_CIC, RA_NACIONA, RA_SEXO, RA_NASC, "
	cQuery += " RA_PASSPOR, RA_TIPOADM, RA_NUMINSC, RA_PROCES, RV_CODFOL, SUM(RG7_ACUM" + cMes + ") RA_ACUMXX" 
	cQuery += " FROM " + cSRAName + " SRA," + cRG7Name + " RG7," + cSRVName + " SRV"
	cQuery += " WHERE"
	cQuery += "	RG7_FILIAL BETWEEN '" + cSucI + "' AND '" + cSucF + "'"  
	cQuery += "	AND RA_MAT BETWEEN '" + cMatI + "' AND '" + cMatF + "'"
	cQuery += "	AND RG7_PROCES BETWEEN '" + cProI + "' AND '" + cProF + "'"
	cQuery += "	AND RA_MAT = RG7_MAT AND RA_FILIAL = RG7_Filial "
	cQuery += "	AND RG7_ANOINI = '" + cAnio + "'" 
	cQuery += "	AND RG7_CODCRI = '" + cCriterio + "'" 
	cQuery += "	AND RG7_PD = RV_COD" 
	cQuery += "	AND RV_CODFOL IN (" + cCodFol + ")" 
	cQuery += " 	AND SRA.D_E_L_E_T_ = ' '"   
	cQuery += " 	AND SRV.D_E_L_E_T_ = ' '"   
	cQuery += " 	AND RG7.D_E_L_E_T_ = ' '"   
	cQuery += " Group by RA_FILIAL,RA_CIC,RA_PASSPOR,RV_CODFOL,RA_NUMINSC,RA_PRINOME, RA_SECNOME, RA_PRISOBR, "   
	cQuery += " RA_SECSOBR, RA_NACIONA, RA_SEXO, RA_NASC, RA_TIPOADM, RA_PROCES " 
	cQuery += " ORDER BY RA_FILIAL, RA_CIC,RA_PASSPOR, RA_NUMINSC "
	cQuery := ChangeQuery(cQuery)	
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTmp, .T., .T.)

Return .T.