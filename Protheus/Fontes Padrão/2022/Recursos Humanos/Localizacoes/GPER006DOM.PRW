#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "GPER006DOM.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER006DOM³ Autor ³ Jonathan Gonzalez             ³ Data ³14/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcion principal para impresion del reporte IR3.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER006DOM()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER006DOM                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR    ³ DATA   ³    BOPS     ³  MOTIVO DA ALTERACAO                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Marco A. Glez ³18/12/17³  DMINA-377  ³Se replica para V12.1.17, el issue     ³±±
±±³                ³        ³             ³DMINA-57 de V11.8. Que contiene funcio-³±±
±±³                ³        ³             ³nalidad de Reporte IR3 (Mod 2). (DOM)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER006DOM()

	Local aArea   := GetArea()
	Local cPerg   := "GPR006DOM"
	Local oReport := NIL

	Private cNomeProg := "GPER006DOM"

	Pergunte(cPerg, .F.)

	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef ³ Autor ³ Jonathan Gonzalez     ³ Data ³14/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza la definicion del reporte IR3.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportDef(cExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.- Grupo de preguntas GRP006DOM                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER006DOM                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(cPerg)

	Local aArea	:= GetArea()
	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3

	Private cTitulo := STR0001 //"Reporte IR-3"

	oReport := TReport():New(cNomeProg, cTitulo, cPerg, {|oReport| ImpReport(oReport)})
	oReport:lHeaderVisible := .F.

	//³ Creación de la Primera Sección:  Encabezado
	oSection1 := TRSection():New(oReport,STR0002,,,,,,,,,,,,,,,,,,,,)//"Encabezado"
	oSection1:SetHeaderSection(.F.) //Exibe Cabecalho da Secao
	oSection1:SetHeaderPage(.F.) //Exibe Cabecalho da Secao
	oSection1:SetLeftMargin(3)

	TRCell():New(oSection1, "TITLE1" , ,"Titulo 1", "!@",50,,,"LEFT",,"LEFT",,,,,,.T.)

	// Creación de la Segunda Sección:  Datos empleados
	oSection2 := TRSection():New(oReport,STR0003,,,,,,,,,,,,,,,,,,,,) //"Datos Empleador"
	oSection2:SetLineStyle(.T.) //Exibe Cabecalho da Secao
	oSection2:SetHeaderPage(.F.) //Exibe Cabecalho da Secao
	oSection2:SetLeftMargin(3)

	TRCell():New(oSection2,"Periodo"   , ,STR0004 ,"!@", 15 ,,,"LEFT",,"LEFT",,,,,,.F.) //"No. Periodo"
	oSection2:Cell("Periodo"):SetCellBreak(.T.)
	TRCell():New(oSection2,"RNC"       , ,STR0005 ,"!@", 45 ,,,"LEFT",,"LEFT",,,,,,.F.) //"RNC"
	oSection2:Cell("RNC"):SetCellBreak(.T.)
	TRCell():New(oSection2,"RaSocial"  , ,STR0006 ,"!@", 60 ,,,"LEFT",,"LEFT",,,,,,.F.) //"Razon Social"
	oSection2:Cell("RaSocial"):SetCellBreak(.T.)
	TRCell():New(oSection2,"Periodo1"  , ,STR0007 ,"!@", 15 ,,,"LEFT",,"LEFT",,,,,,.F.) //"No. Periodo"

	//Creación de la Tercera Sección: Detalle
	oSection3 := TRSection():New(oReport,STR0008 ,,,,,,,,,,,,,,,,,,,,) //"Detalle"
	oSection3:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	oSection3:SetLeftMargin(3)
	oSection3:SetLineStyle(.F.)		//Pone titulo del campo y aun lado el y valor

	TRCell():New(oSection3,"Descripcion" , ,"" ,"!@"                  , 100 ,,,"LEFT"   ,,"LEFT",,,,,,.F.)
	TRCell():New(oSection3,"Separador"   , ,"" ,"!@"                  ,  5  ,,,"CENTER" ,,"LEFT",,,,,,.F.)
	TRCell():New(oSection3,"Concepto"    , ,"" ,"!@"                  ,  5  ,,,"CENTER" ,,"LEFT",,,,,,.F.)
	TRCell():New(oSection3,"Secuencia"   , ,"" ,"@E 999"              ,  5  ,,,"RIGHT"  ,,"LEFT",,,,,,.F.)
	TRCell():New(oSection3,"Importe"     , ,"" ,"@E 99,999,999,999.99", 30  ,,,"RIGHT"  ,,"LEFT",,,,,,.F.)

	oSection1:nLinesBefore	:= 0
	oSection2:nLinesBefore	:= 0
	oSection3:nLinesBefore	:= 0

	RestArea(aArea)
	
Return (oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpReport ³ Autor ³ Jonathan Gonzalez     ³ Data ³14/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza la impresion de reporte IR3.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ImpReport(oExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1.- Objeto con la definicion del reporte.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ReportDef                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpReport(oReport)

	Local aArea     := GetArea()
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := oReport:Section(3)
	Local cAliasRG7 := "QRYRG7"
	Local cCposFrom := ""
	Local cWhere    := ""
	Local cOrdem    := ""
	Local cFilAnt   := ""
	Local nX        := 0
	Local nCount    := 0
	Local cMatric   := ""
	Local cAuxCpo   := ""
	Local nTotal    := 0
	Local nIdx      := 1
	Local cFilOri   := SM0->M0_CODFIL

	Private cFilIni    := ""
	Private cFilFin    := ""
	Private cProcIni   := ""
	Private cProcFin   := ""
	Private cMatIni    := ""
	Private cMatFin    := ""
	Private cAno       := ""

	Private nConceptA  := 0
	Private nConceptB  := 0
	Private nConceptC  := 0
	Private nConceptD  := 0
	Private nConceptL  := 0
	Private nConceptM  := 0
	Private nConceptO  := 0
	Private nConceptP  := 0
	Private nCreEduca  := 0
	Private nConceptX  := 0
	Private nConcept11 := 0
	Private cConcept16 := 0
	Private nConcept17 := 0

	Private nTotGral3  := 0
	Private nTotGral4  := 0
	Private nTotGral6  := 0
	Private nTotGral7  := 0
	Private nTotGral8  := 0
	Private nTotGral9  := 0
	Private nTotGral10 := 0
	Private nTotGral11 := 0
	Private nTotGral13 := 0
	Private nTotGral15 := 0
	Private nTotGral16 := 0
	Private nTotGral17 := 0
	Private nTotGral20 := 0

	Pergunte(oReport:GetParam(), .F.)
	cFilIni  := MV_PAR01
	cFilFin  := MV_PAR02
	cProcIni := MV_PAR03
	cProcFin := MV_PAR04
	cMatIni  := MV_PAR05
	cMatFin  := MV_PAR06
	cAno     := ALLTRIM(STR(MV_PAR07))

	cCposFrom := "% " + RetSqlName("RG7") + " RG7, "
	cCposFrom += RetSqlName("SRV") + " SRV %"

	cWhere := "% RG7.RG7_FILIAL BETWEEN '" + cFilIni + "' AND '" + cFilFin + "' "
	cWhere += "  AND RG7.RG7_PROCES BETWEEN '" + cProcIni + "' AND '" + cProcFin + "' "
	cWhere += "  AND RG7.RG7_MAT BETWEEN '" + cMatIni + "' AND '" + cMatFin + "' "
	cWhere += "  AND RG7.RG7_ANOINI >= '" + cAno + "' AND RG7.RG7_ANOFIM <= '" + cAno + "' "
	cWhere += "  AND SRV.RV_CODFOL IN ('0066','0031','0165','0533','9341','0065','0446','0447','0455','0547','0154','0156','0020','0103','0107','0013','0638','0224') "
	cWhere += "  AND RG7.RG7_PD = SRV.RV_COD "

	If ( TcSrvType()=="AS/400" )
		cWhere += " AND RG7.@DELETED@  = ' ' "
		cWhere += " AND SRV.@DELETED@  = ' ' %"
	ELSE
		cWhere += " AND RG7.D_E_L_E_T_  = ' ' "
		cWhere += " AND SRV.D_E_L_E_T_  = ' ' %"
	ENDIF
	cOrdem := "% RG7.RG7_FILIAL, RG7.RG7_MAT %"

	BeginSql alias cAliasRG7
		SELECT RG7.*, SRV.RV_CODFOL, SRV.RV_COD
		FROM  %exp:cCposFrom%
		WHERE %exp:cWhere%
		ORDER BY %exp:cOrdem%
	EndSql

	Begin Sequence
		DBSelectArea(cAliasRG7)
		count to nTotal
		oReport:SetMeter(nTotal)
		(cAliasRG7)->(DbGoTop())

		While (cAliasRG7)->(!Eof())
			nCount++

			If cFilAnt != (cAliasRG7)->RG7_FILIAL
				If nCount <> 1
					oReport:EndPage(.T.)
				EndIf
				oSection1:Init()
				
				oSection1:Cell("TITLE1"):SetValue(SPACE(12)+STR0009) //"DIRECCIÓN GENERAL DE IMPUESTOS INTERNOS"
				oSection1:printline()
				oSection1:Cell("TITLE1"):SetValue(SPACE(12)+STR0010) //"DECLARACIÓN Y/O PAGO DE RETENCIONES DE ASALARIADOS"
				oSection1:printline()
				oSection1:Cell("TITLE1"):SetValue(SPACE(12)+STR0011) //"(Valores en RD$)"
				oSection1:printline()
				oSection1:Finish()
				oReport:SkipLine(1)
			EndIf

			cFilAnt := (cAliasRG7)->RG7_FILIAL
			While (cAliasRG7)->(!Eof()) .AND. (cAliasRG7)->RG7_FILIAL ==  cFilAnt

				cMatric := (cAliasRG7)->RG7_MAT
				nConceptA += 1
				While (cAliasRG7)->(!Eof()) .AND. (cAliasRG7)->RG7_FILIAL ==  cFilAnt .AND. cMatric == (cAliasRG7)->RG7_MAT

					Do Case
						Case (cAliasRG7)->RV_CODFOL == "0066"
						For nX := 1 To 12
							cAuxCpo := "RG7_ACUM"+PADL( ALLTRIM(STR(nX)),2,"0")
							If (cAliasRG7)->&(cAuxCpo) > 0
								nConceptB += 1
								nX := 13
							EndIf
						Next

						For nX := 1 To 12
							cAuxCpo := "RG7_ACUM"+PADL( ALLTRIM(STR(nX)),2,"0")
							If (cAliasRG7)->&(cAuxCpo) > 0
								nConceptM += (cAliasRG7)->&(cAuxCpo)
							EndIf
						Next

						Case (cAliasRG7)->RV_CODFOL $ "0031|0165|0533|9341"
						For nX := 1 To 12
							cAuxCpo := "RG7_ACUM"+PADL( ALLTRIM(STR(nX)),2,"0")
							If (cAliasRG7)->&(cAuxCpo) > 0
								nConceptC += (cAliasRG7)->&(cAuxCpo)
							EndIf
						Next

						Case (cAliasRG7)->RV_CODFOL $ "0065|0446|0447|0455|0547|0154|0156|0020|0103|0107"
						For nX := 1 To 12
							cAuxCpo := "RG7_ACUM"+PADL( ALLTRIM(STR(nX)),2,"0")
							If (cAliasRG7)->&(cAuxCpo) > 0
								nConceptD += (cAliasRG7)->&(cAuxCpo)
							EndIf
						Next

						Case (cAliasRG7)->RV_CODFOL == "0013"
						For nX := 1 To 12
							cAuxCpo := "RG7_ACUM"+PADL( ALLTRIM(STR(nX)),2,"0")
							If (cAliasRG7)->&(cAuxCpo) > 0
								nConceptL += (cAliasRG7)->&(cAuxCpo)
							EndIf
						Next

						Case (cAliasRG7)->RV_CODFOL == "0638"
						For nX := 1 To 12
							cAuxCpo := "RG7_ACUM"+PADL( ALLTRIM(STR(nX)),2,"0")
							If (cAliasRG7)->&(cAuxCpo) > 0
								nConceptO += (cAliasRG7)->&(cAuxCpo)
							EndIF
						Next

						nConceptX := GetValSRK((cAliasRG7)->RG7_FILIAL,(cAliasRG7)->RG7_MAT,(cAliasRG7)->RG7_PROCES,(cAliasRG7)->RV_CODFOL)
						If nConceptX > 0
							nConceptP += nConceptX
						EndIf

						Case (cAliasRG7)->RV_CODFOL == "0224"
						For nX := 1 To 12
							cAuxCpo := "RG7_ACUM"+PADL( ALLTRIM(STR(nX)),2,"0")
							If (cAliasRG7)->&(cAuxCpo) > 0
								nCreEduca += (cAliasRG7)->&(cAuxCpo)
							EndIF
						Next

					EndCase

					oReport:IncMeter()
					(cAliasRG7)->(dbskip())

				EndDo
				//Totaliza variables de sucursal
				nTotGral3  += nConceptC
				nTotGral4  += nConceptD
				nTotGral6  += (nConceptC + nConceptD)
				nTotGral7  += nConceptL
				nTotGral8  += nConceptM
				nTotGral9  += nConceptO
				nTotGral10 += nConceptP
				nConcept11 := IIF( (nConceptM - nConceptO) > 0 , (nConceptM - nConceptO) , 0 )
				nTotGral11 += nConcept11
				nTotGral13 += nCreEduca
				nTotGral15 += nConceptP
				cConcept16 := IIF( (nConcept11 - nCreEduca - nConceptP ) > 0 , (nConcept11 - nCreEduca - nConceptP ) , 0 )
				nTotGral16 += cConcept16
				nConcept17 := IIF( (nConcept11 - nCreEduca - nConceptP ) > 0 , (nConcept11 - nCreEduca - nConceptP ) , 0 )
				nTotGral17 += nConcept17
				nTotGral20 += cConcept16

				//Limpia variables de empleado
				nConceptC  := 0
				nConceptD  := 0
				nConceptL  := 0
				nConceptM  := 0
				nConceptO  := 0
				nConceptP  := 0
				nCreEduca  := 0
				nConcept11 := 0
				cConcept16 := 0
				nConcept17 := 0

			EndDo

			DBSelectArea("SM0")
			SM0->(DBSeek(cEmpAnt+cFilAnt,.T.))

			//Datos Empresa
			oSection2:Init()
			oSection2:Cell("Periodo"  ):SetValue(cAno+"12")
			oSection2:Cell("RNC"      ):SetValue(IIf(nIdx > 0, fTabela("S012", nIdx, 5), ""))
			oSection2:Cell("RaSocial" ):SetValue(SM0->M0_NOME)
			oSection2:Cell("Periodo1"  ):SetValue(cAno+"12")
			oSection2:printline()
			oSection2:Finish()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volta a empresa anteriormente selecionada.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea("SM0")
			SM0->(DBSeek(cEmpAnt+cFilOri, .T.))

			//Detalle.
			oSection3:Init()
			oReport:SkipLine(1)
			For nX := 1 To 24
				Do Case
					Case nX == 1
					oSection3:Cell("Descripcion"):SetValue(STR0012) //"B. ASALARIADOS"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("")
					oSection3:Cell("Secuencia"  ):SetValue("")
					oSection3:Cell("Importe"    ):SetPicture("@!")
					oSection3:Cell("Importe"    ):SetValue(STR0013) //"TOTAL"
					oSection3:printline()
					oSection3:Cell("Importe"    ):SetPicture("@E 99,999,999,999.99")
					Case nX == 2
					oSection3:Cell("Descripcion"):SetValue(STR0014) //"1.- Total asalariados"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("A")
					oSection3:Cell("Secuencia"  ):SetValue("1")
					oSection3:Cell("Importe"    ):SetValue(nConceptA)
					oSection3:printline()
					Case nX == 3
					oSection3:Cell("Descripcion"):SetValue(STR0015) //"2.- Asalariados sujetos a Retención"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("B")
					oSection3:Cell("Secuencia"  ):SetValue("2")
					oSection3:Cell("Importe"    ):SetValue(nConceptB)
					oSection3:printline()
					Case nX == 4
					oSection3:Cell("Descripcion"):SetValue(STR0016) //"3.- Sueldos Pagados por el Agente"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("C")
					oSection3:Cell("Secuencia"  ):SetValue("3")
					oSection3:Cell("Importe"    ):SetValue(nTotGral3)
					oSection3:printline()
					Case nX == 5
					oSection3:Cell("Descripcion"):SetValue(STR0017) //"4.- Otras Remuneraciones"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("D")
					oSection3:Cell("Secuencia"  ):SetValue("4")
					oSection3:Cell("Importe"    ):SetValue(nTotGral4)
					oSection3:printline()
					Case nX == 6
					oSection3:Cell("Descripcion"):SetValue(STR0018) //"5.- Remuneraciones de Otros Agentes"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("E")
					oSection3:Cell("Secuencia"  ):SetValue("5")
					oSection3:Cell("Importe"    ):SetValue(0)
					oSection3:printline()
					Case nX == 7
					oSection3:Cell("Descripcion"):SetValue(STR0019) //"6.- Total Pagado (Sumar casillas 3 + 4 + 5)"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("F")
					oSection3:Cell("Secuencia"  ):SetValue("6")
					oSection3:Cell("Importe"    ):SetValue(nTotGral6)
					oSection3:printline()
					Case nX == 8
					oSection3:Cell("Descripcion"):SetValue(STR0020) //"7.- Pago Total Sujeto a Retencion"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("L")
					oSection3:Cell("Secuencia"  ):SetValue("7")
					oSection3:Cell("Importe"    ):SetValue(nTotGral7)
					oSection3:printline()
					Case nX == 9
					oSection3:Cell("Descripcion"):SetValue(STR0021) //"8.- Impuesto sobre la Renta"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("M")
					oSection3:Cell("Secuencia"  ):SetValue("8")
					oSection3:Cell("Importe"    ):SetValue(nTotGral8)
					oSection3:printline()
					Case nX == 10
					oSection3:Cell("Descripcion"):SetValue(STR0022) //"9.- Saldo Compensado Autorizado"
					oSection3:Cell("Separador"  ):SetValue("-")
					oSection3:Cell("Concepto"   ):SetValue("O")
					oSection3:Cell("Secuencia"  ):SetValue("9")
					oSection3:Cell("Importe"    ):SetValue(nTotGral9)
					oSection3:printline()
					Case nX == 11
					oSection3:Cell("Descripcion"):SetValue(STR0023) //"10.- Saldo por Compensar"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("P")
					oSection3:Cell("Secuencia"  ):SetValue("10")
					oSection3:Cell("Importe"    ):SetValue(nTotGral10)
					oSection3:printline()
					Case nX == 12
					oSection3:Cell("Descripcion"):SetValue(STR0024) //"C. LIQUIDACION"
					oSection3:Cell("Separador"  ):Disable()
					oSection3:Cell("Concepto"   ):Disable()
					oSection3:Cell("Secuencia"  ):Disable()
					oSection3:Cell("Importe"    ):Disable()
					oSection3:printline()
					oSection3:Cell("Separador"  ):Enable()
					oSection3:Cell("Concepto"   ):Enable()
					oSection3:Cell("Secuencia"  ):Enable()
					oSection3:Cell("Importe"    ):Enable()
					Case nX == 13
					oSection3:Cell("Descripcion"):SetValue(STR0025) //"11.- Impuesto a Pagar (Si el valor de la casilla 8 - 9 es positivo"
					oSection3:Cell("Separador"  ):SetValue("=")
					oSection3:Cell("Concepto"   ):SetValue("Q")
					oSection3:Cell("Secuencia"  ):SetValue("11")
					oSection3:Cell("Importe"    ):SetValue(nTotGral11)
					oSection3:printline()
					Case nX == 14
					oSection3:Cell("Descripcion"):SetValue(STR0026) //"12.- Credito Autorizado"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("-")
					oSection3:Cell("Secuencia"  ):SetValue("12")
					oSection3:Cell("Importe"    ):SetValue(0)
					oSection3:printline()
					Case nX == 15
					oSection3:Cell("Descripcion"):SetValue(STR0027) //"13.- Credito Gastos Educativos IR-18"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("-")
					oSection3:Cell("Secuencia"  ):SetValue("13")
					oSection3:Cell("Importe"    ):SetValue(nTotGral13)
					oSection3:printline()
					Case nX == 16
					oSection3:Cell("Descripcion"):SetValue(STR0028) //"14.- Pagos Computables a Cuenta"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("-")
					oSection3:Cell("Secuencia"  ):SetValue("14")
					oSection3:Cell("Importe"    ):SetValue(0)
					oSection3:printline()
					Case nX == 17
					oSection3:Cell("Descripcion"):SetValue(STR0029) //"15.- Saldo a Favor Anterior"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("-")
					oSection3:Cell("Secuencia"  ):SetValue("15")
					oSection3:Cell("Importe"    ):SetValue(nTotGral15)
					oSection3:printline()
					Case nX == 18
					oSection3:Cell("Descripcion"):SetValue(STR0030) //"16.- Diferencia a Pagar (Si el valor de casilla 11 - 12 - 13 - 14 - 15 es positivo)"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("=")
					oSection3:Cell("Secuencia"  ):SetValue("16")
					oSection3:Cell("Importe"    ):SetValue(nTotGral16)
					oSection3:printline()
					Case nX == 19
					oSection3:Cell("Descripcion"):SetValue(STR0031) //"17.- Saldos a Favor (Si el valor de casilla 11 - 12 - 13 - 14 - 15 es negativo)"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("=")
					oSection3:Cell("Secuencia"  ):SetValue("17")
					oSection3:Cell("Importe"    ):SetValue(nTotGral17)
					oSection3:printline()
					Case nX == 20
					oSection3:Cell("Descripcion"):SetValue(STR0032) //"D. PENALIDADES"
					oSection3:Cell("Separador"  ):Disable()
					oSection3:Cell("Concepto"   ):Disable()
					oSection3:Cell("Secuencia"  ):Disable()
					oSection3:Cell("Importe"    ):Disable()
					oSection3:printline()
					oSection3:Cell("Separador"  ):Enable()
					oSection3:Cell("Concepto"   ):Enable()
					oSection3:Cell("Secuencia"  ):Enable()
					oSection3:Cell("Importe"    ):Enable()
					Case nX == 21
					oSection3:Cell("Descripcion"):SetValue(STR0033) //"18.- Recargos"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("+")
					oSection3:Cell("Secuencia"  ):SetValue("18")
					oSection3:Cell("Importe"    ):SetValue(0)
					oSection3:printline()
					Case nX == 22
					oSection3:Cell("Descripcion"):SetValue(STR0034) //"19.- Interes Indemnizatorio"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("+")
					oSection3:Cell("Secuencia"  ):SetValue("19")
					oSection3:Cell("Importe"    ):SetValue(0)
					oSection3:printline()
					Case nX == 23
					oSection3:Cell("Descripcion"):SetValue(STR0035) //"E. MONTO A PAGAR"
					oSection3:Cell("Separador"  ):Disable()
					oSection3:Cell("Concepto"   ):Disable()
					oSection3:Cell("Secuencia"  ):Disable()
					oSection3:Cell("Importe"    ):Disable()
					oSection3:printline()
					oSection3:Cell("Separador"  ):Enable()
					oSection3:Cell("Concepto"   ):Enable()
					oSection3:Cell("Secuencia"  ):Enable()
					oSection3:Cell("Importe"    ):Enable()
					Case nX == 24
					oSection3:Cell("Descripcion"):SetValue(STR0036) //"20.- Total a Pagar (Sumar casillas 16 + 18 + 19)"
					oSection3:Cell("Separador"  ):SetValue("")
					oSection3:Cell("Concepto"   ):SetValue("=")
					oSection3:Cell("Secuencia"  ):SetValue("20")
					oSection3:Cell("Importe"    ):SetValue(nTotGral20)
					oSection3:printline()
				EndCase
			Next
			oSection3:Finish()

			nConceptA  := 0
			nConceptB  := 0
			nTotGral3  := 0
			nTotGral4  := 0
			nTotGral6  := 0
			nTotGral7  := 0
			nTotGral8  := 0
			nTotGral9  := 0
			nTotGral10 := 0
			nTotGral11 := 0
			nTotGral13 := 0
			nTotGral15 := 0
			nTotGral16 := 0
			nTotGral17 := 0
			nTotGral20 := 0

		EndDo

		(cAliasRG7)->(DBCloseArea())
	End Sequence

	RestArea(aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetValSRK ³ Autor ³ Jonathan Gonzalez     ³ Data ³14/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³obtiene el valor de prestamos del empleado para el rango del³±±
±±³          ³ año informado en los parametros.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetValSRK(cExp1,cExp2,cExp3,cExp4)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.- Filial de trabajo                                   ³±±
±±³          ³cExp2.- Matricula del empleado                              ³±±
±±³          ³cExp3.- Codigo de proceso                                   ³±±
±±³          ³cExp4.- Codigo de identificador de calculo                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ImpReport                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetValSRK(cFilSRK,cMat,cProces,cCodFol)

	Local aArea     := GetArea()
	Local cAliasSRK := "QRYSRK"
	Local cCposFrom := ""
	Local cWhere    := ""
	Local nValor    := 0

	Default cFilSRK := ""
	Default cMat    := ""
	Default cProces := ""
	Default cCodFol := ""

	cCposFrom	:= "% " + RetSqlName("SRK") + " SRK, "
	cCposFrom	+=  RetSqlName("SRV") + " SRV %"

	cWhere := "% SRK.RK_FILIAL = '" + cFilSRK + "' "
	cWhere += "  AND SRK.RK_MAT = '" + cMat + "' "
	cWhere += "  AND SRK.RK_PROCES = '" + cProces + "' "
	cWhere += "  AND SRK.RK_DTMOVI BETWEEN '" + cAno + "0101' AND '" + cAno + "1231' "
	cWhere += "  AND SRV.RV_CODFOL IN ('" + cCodFol + "') "
	cWhere += "  AND SRK.RK_PD = SRV.RV_COD "

	If ( TcSrvType()=="AS/400" )
		cWhere += " AND SRK.@DELETED@  = ' ' %"
	Else
		cWhere += " AND SRK.D_E_L_E_T_  = ' '
		cWhere += " AND SRV.D_E_L_E_T_  = ' ' %"
	EndIf

	BeginSql alias cAliasSRK
		SELECT SRK.RK_VLSALDO, SRV.RV_CODFOL, SRV.RV_COD
		FROM  %exp:cCposFrom%
		WHERE %exp:cWhere%
	EndSql

	DBSelectArea(cAliasSRK)
	(cAliasSRK)->(DbGoTop())
	While (cAliasSRK)->(!Eof())
		If (cAliasSRK)->RK_VLSALDO > 0
			nValor += (cAliasSRK)->RK_VLSALDO
		EndIf
	EndDo
	(cAliasSRK)->(DBCloseArea())

	RestArea(aArea)
	
Return nValor