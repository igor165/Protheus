#include 'totvs.ch'
#include 'GPER950COL.ch'

/*/{Protheus.doc}GPER950COL
función principal que genera reporte UGPP
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@return 
/*/
Function GPER950COL()

	Local aArea := getArea()
	Local cPerg := "GP950COL"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local lRun		:= .F.
	Private cCadastro 	:= OemToAnsi(STR0001) //"Generación de Plantilla UGPP"	 
	
	Pergunte(cPerg, .F.)	
	
	AAdd(aSays, OemToAnsi(STR0002))  // "Rutina para Generar Archivo: "
	AAdd(aSays, OemToAnsi(STR0003))  // "Unidad Administrativa Especial de Gestión Pensional "
	AAdd(aSays, OemToAnsi(STR0010))  // "y Contribuciones Parafiscales de la Protección Social (UGPP)"
	AAdd(aSays, OemToAnsi(STR0006))  // "Antes de ejecutar la generación del reporte UGPP, asegúrese de lo siguiente:  "
	AAdd(aSays, "")  // " "
	AAdd(aSays, OemToAnsi(STR0004))  // "- Tablas alfanuméricas: S010, S011, S012 "
	AAdd(aSays, OemToAnsi(STR0005))  // "- Movimientos e Histórico de movimientos de nómina "
	
	// Para Gestao Corporativa.	                                                             
	AAdd(aButtons, {5, .T., {|| Pergunte(cPerg, .T.)  } } ) 
	AAdd(aButtons, {1, .T., {|| lRun:= .T., FechaBatch() } } )
	AAdd(aButtons, {2, .T., {|| lRun:= .F., FechaBatch() } } )
		
	FormBatch(cCadastro, aSays, aButtons)

	If lRun
		Proc2BarGauge(	{|| GP950Proc() }	,;	// Acao a ser Executada
							STR0007			,;	// "Generación Reporte UGPP"        
							STR0008			,;	// "Generando registros"
							STR0009			,;	// "Seleccionando información ..."
							.T.				,;	// Se habilitara o botao para "Abortar" o processo
							.T.				,;	// Se havera controle de estimativa de tempo na 1a. BarGauge
							.T.				,;	// Se havera conteole de estimativa de tempo na 2a. BarGauge
							.T.				 ;	// Se ira mostrar a 2a. BarGauge / Caso parametro esteja para todas as empreas
						)
	EndIf
	RestArea(aArea)

Return

/*/{Protheus.doc} GP950Proc
Función que ejecuta los procesos de extracción y generación de archivo ugpp
@type function
@author mayra.camargo
@since 10/04/2019
@version 1.0
/*/
Static function GP950Proc()
	Local nI  		:= 0
	Local aPer		:= {}
	Local aEnc		:= {}
	Local aDet		:= {}
	Local cQrySRA  := ""
	Local cQryDet	:= ""
	Local cNomEmp	:= ""
	Local lAdmis	:= .f.
	Local lRetiro  := .f.
	Local cCargo	:= ""
	Local cCol08	:= ""	
	Local aEmpDet	:= {}
	Local nPos		:= 0
	Local nCol		:= 0
	Local cIDCal	:= ""
	Local dFecha	:= CTOD(" / / ")
	Local dDtFin	:= CTOD(" / / ")
	Local dAdmis	:= CTOD(" / / ")
	Local dDemis	:= CTOD(" / / ")
	Local nDayWork	:= 0
	Local nDayTot	:= 0
	Local nDayOut	:= 0
	Local cCondEsp	:= ""
	Local nX		:= 0
	
	Private cProcedim 	:= StrTran(MV_PAR03, "'", "") //Se eliminan comillas sencillas
	Private cProcesos 	:= StrTran(MV_PAR02, "'", "") //Se eliminan comillas sencillas
	Private cFils		:= ""
	
	Pergunte("GP950COL", .F.)
	
	BarGauge1Set(2)
	cTime1 := Time()
	
	IncPrcG1Time(STR0023 , 1, cTime1, .T., 2, 1) // "Preparando Información ..."
	
	// Se obtienen los datos de la sección 01 - Dat
	aEnc := G950GETENC(MV_PAR01)

	// Se obtienen los periodos involucrados segun parámetro MV_PAR04 Y MV_PAR05 
	aPer := fGetPer(MV_PAR04,MV_PAR05) 	
	If len(aPer) > 0
		// Se obtienen los datos de los conceptos que será nreportados en el periodo
		aConc := fGetPD(aPer)
		cQrySRA := fgetEmpl(aPer)
		DBSelectArea(cQrySRA)
		count to nRegistros	
		IncPrcG1Time(STR0021, 1, cTime1, .T., 3, 1) // "Procesando..."	
		
		cTime2	:= Time()                
		BarGauge2Set(nRegistros)	
		(cQrySRA)->(dbGoTop()) 	
		If nRegistros >0
			While (cQrySRA)->(!Eof()) 
				nX+= 1
				aEmpDet := {}
				nDayTot := 0
				nDayOut := 0
				nDayWork:= 0
				cNomEmp := RTRIM((cQrySRA)->RA_PRISOBR) + " " + RTRIM((cQrySRA)->RA_SECSOBR) + " " + RTRIM((cQrySRA)->RA_PRINOME) + " " + RTRIM((cQrySRA)->RA_SECNOME)			
				IncPrcG2Time(STR0021+ cNomEmp,nI, cTime2, .T., nI, 1) // "Procesando..."		
				aMat := fFindMatAdic((cQrySRA)->RA_CIC)			
				If !(len(aMat)>0)
					AADD(aMat,{(cQrySRA)->RA_FILIAL,(cQrySRA)->RA_MAT})
				EndIf 
				dDemis 	:= STOD((cQrySRA)->RA_DEMISSA)
				dAdmis	:= STOD((cQrySRA)->RA_ADMISSA)
				dFecha 	:= STOD(mv_par05 + mv_par04 + "01")
				dDtFin	:= STOD(mv_par05 + mv_par04 + STR(Last_Day(dFecha),2))
				lAdmis	:= dAdmis >= dFecha .and. dAdmis <= dDtFin
				lRetiro	:= dDemis >= dFecha .and. dDemis <= dDtFin				
				cCargo 	:= POSICIONE("SQ3",1,XFILIAL("SQ3") +(cQrySRA)->RA_CARGO, "Q3_DESCSUM")
				cCol08 	:= IIF(Empty((cQrySRA)->RA_PORAFP), "",GetParameter("S044",(cQrySRA)->RA_PORAFP,4,5))
				cCondEsp:= fGetCond((cQrySRA)->RA_PROCES,dFecha,MV_PAR08) 
				
				// Se calcula número de días trabajados 
				If dAdmis < dFecha
					If Empty(dDemis) 
						nDayTot := 30
					ElseIf !Empty(dDemis) .and. lAdmis
						nDayTot := Day(dDemis)						
					EndIf
				ElseIf lAdmis
					If Empty(dDemis) 
						nDayTot := 30
					ElseIf !Empty(dDemis) 
						nDayTot := Day(dDemis)	- Day(dAdmis) + 1 					
					EndIf
				EndIf
				// Proceso por empleado. Se genera array con detalle del empleado, en esta primera parte se llenan las novedades.
				// y se crean las posiciones dinámicas de los conceptos que se calcularon en el periodo.
				
				aAdd(aEmpDet,STR(nX))   															// 1. Secuencia
				aAdd(aEmpDet,(cQrySRA)->RA_TIPCOT)													// 2. Tipo de Cotizante
				aAdd(aEmpDet,(cQrySRA)->RA_SUBCOT)													// 3. Subtipo Cotizante
				aAdd(aEmpDet,cCondEsp)																// 4. Cond Especial Empresa --> Obtener por proceso del empleado y MV_PAR08 -- PENDIENTE OBTENER
				aAdd(aEmpDet,"")																	// 5. Reservado UGP
				aAdd(aEmpDet,IIF((cQrySRA)->RA_PGAPORT == "1","X","")) 								// 6. Extranjero no obligado a cotizar a pensión
				aAdd(aEmpDet,IIF((cQrySRA)->RA_RESEXT  == "1","X","")) 								// 7. Colombiano en el exterior
				aAdd(aEmpDet,cCol08) 																// 8. Actividad alto riesgo pensión 
				aAdd(aEmpDet,(cQrySRA)->RA_TPCIC)													// 9. Tipo documento actual del cotizante 
				aAdd(aEmpDet,(cQrySRA)->RA_CIC)														// 10.Número de documento actual del cotizante
				aAdd(aEmpDet,(cQrySRA)->RA_TPCIC)													// 11.Tipo de documento con el que realizó aportes del cotizante
				aAdd(aEmpDet,(cQrySRA)->RA_CIC)														// 12.Número de documento con el que realizó aportes del cotizante
				aAdd(aEmpDet,cNomEmp)																// 13.Nombre Cotizante
				aAdd(aEmpDet,cCargo)																// 14.Cargo del Trabajador 
				aAdd(aEmpDet,MV_PAR05)																// 15.Año
				aAdd(aEmpDet,MV_PAR04)																// 16.Mes
				aAdd(aEmpDet,IIF((cQrySRA)->RA_TIPOSAL $ "2|4","X",""))								// 17.Salario Integral
				aAdd(aEmpDet,"")																	// 18.Novedad Incapacidad 
				aAdd(aEmpDet,"")																	// 19.Novedad Lic Maternidad o Paternidad 
				aAdd(aEmpDet,"")																	// 20.Novedad Permiso o Licencia Remunerada 
				aAdd(aEmpDet,"")																	// 21.Novedad Suspensión
				aAdd(aEmpDet,"")																	// 22.Novedades Vacaciones 
				aAdd(aEmpDet,nDayWork)																// 23.Número de días trabajados en el mes 
				aAdd(aEmpDet,0)																		// 24.Número de días de incapacidad en el mes 
				aAdd(aEmpDet,0)																		// 25.Número de días de licencia maternidad o paternidad en el mes 
				aAdd(aEmpDet,0)																		// 26.Número de días de permiso o licencia remunerada en el mes 
				aAdd(aEmpDet,0)																		// 27.Número de días de suspensión, permiso o licencia no remunerada en el mes 
				aAdd(aEmpDet,0)																		// 28.Número de días de vacaciones disfrutadas en el mes
				aAdd(aEmpDet,IIF(Empty(MV_PAR06),0,MV_PAR06))										// 29.Número de días de huelga declarada legalmente en el mes 
				aAdd(aEmpDet,nDayTot)																// 30.Número total de días reportados en el mes 
				aAdd(aEmpDet,IIF(lAdmis,"X",""))													// 31.Ingreso 
				aAdd(aEmpDet,IIF(lAdmis,DateToStr((cQrySRA)->RA_ADMISSA,"YYYY-MM-DD"),Space(10))) 	// 32.Fecha Ingreso
				aAdd(aEmpDet,IIF(lRetiro,"X","")) 												  	// 33.Retiro 		
				aAdd(aEmpDet,IIF(lRetiro,DateToStr((cQrySRA)->RA_DEMISSA,"YYYY-MM-DD"),Space(10)))	// 34.Fecha Retiro
				For nI := 1 to 15 // Se generan columnas en blanco de uso exclusivo UGPP
					aAdd(aEmpDet,"")					
				Next nI
				For nI:= 1 to len(aConc)
					aAdd(aEmpDet,0)
				Next nI
				
				// Se obtendrá registro de los movimientos del empleado en el mes y se llenará el array con los valores del concepto.
				cQryDet := fgetMovPer(aMat,aConc,aPer)
				While (cQryDet)->(!Eof()) 
					nPos := aScan(aConc, { |x,y| x[2] == (cQryDet)->PD })					
					If nPos > 0 // Si se encontró el concepto
						nCol	:= aConc[nPos,1]
						aEmpDet[nCol] := (cQryDet)->VALOR	
					EndIf
					cIDCal := (cQryDet)->IDCALC
					If cIDCal $ "0041|0042" .and. (cQryDet)->HORAS > 0
						aEmpDet[18] := "X"
						aEmpDet[24] += (cQryDet)->HORAS // 24.Número de días de incapacidad en el mes
						nDayOut += 	(cQryDet)->HORAS		
					ElseIf cIDCal $ "0040|1034" .and. (cQryDet)->HORAS > 0
						aEmpDet[19] := "X"				// 19.Novedad Lic Maternidad o Paternidad 
						aEmpDet[25] += (cQryDet)->HORAS	// 24.Número de días de incapacidad en el mes
						nDayOut += 	(cQryDet)->HORAS		
					ElseIf cIDCal $ "0443" .and. (cQryDet)->HORAS > 0
						aEmpDet[20] := "X"				// 20.Novedad Permiso o Licencia Remunerada
						aEmpDet[26] += (cQryDet)->HORAS	// 26.Número de días de permiso o licencia remunerada en el mes 
						nDayOut += 	(cQryDet)->HORAS		
					ElseIf cIDCal $ "1362|0444|0054|0442" .and. (cQryDet)->HORAS > 0
						aEmpDet[21] := "X"				// 21.Novedad Suspensión
						aEmpDet[27] += (cQryDet)->HORAS	// 27.Número de días de suspensión, permiso o licencia no remunerada en el mes 
						nDayOut += 	(cQryDet)->HORAS		
					ElseIf cIDCal $ "0072" .and. (cQryDet)->HORAS > 0
						aEmpDet[22] := "X"				// 22.Novedades Vacaciones 
						aEmpDet[28] += (cQryDet)->HORAS	// 28.Número de días de vacaciones disfrutadas en el mes	
						nDayOut += 	(cQryDet)->HORAS																				
					EndIf																
					(cQryDet)->(dbSkip()) 
				EndDo 
				
				// Días Trabajados 
				aEmpDet[23] += nDayTot - nDayOut

				(cQryDet)->(DBCloseArea()) 					
				(cQrySRA)->(dbSkip())
				aAdd(aDet,aEmpDet) 
			EndDo
			
			If len(aDet)>0
				IncPrcG2Time(STR0011 ,len(aDet), time(), .T., 1, 1) // "Generando archivo Excel..."	
				If BuildFile(MV_PAR07,aEnc,aDet,aConc)
					MsgInfo(STR0012 + MV_PAR07) // "Archivo generado exitosamente en: "
				Else
					MsgAlert(STR0013) // "Ocurrió un error al Generar el archivo, por favor intente nuevamente."
				EndIf
			EndIf
			MsgInfo(STR0014) // "Proceso Finalizado ugpp..."
		Else
			MsgAlert(STR0015) // "No se encontraron registros con los parámetros de búsuqeda informados."
		EndIf
		(cQrySRA)->(DBCloseArea())
	Else
		MsgAlert(STR0016 + MV_PAR04 + "/" + MV_PAR05 + CHR(13) + CHR(10) + STR0017) // "No existen periodos registrados para el mes/ año: " " - No Se puede continuar con el proceso."
	EndIf
Return 
/*/{Protheus.doc} G950GETENC
@type G950GETENC
@author mayra.camargo
@since 08/04/2019
@version 1.0
@return aRet, Array con la información del Aportante.
@example
(examples)
@see (links_or_references)
/*/
//Función para obtener los datos del encabezado
Static function G950GETENC(cRacSoc)
	Local aRet := {}
	Local aSM0 := FWLoadSM0()
	Local nI 	:= 0
	Local nLin := 0
	Local nLin2:= 0
	Local aFils:= {}
	Local cNumNIT := ""
	Default cRacSoc := MV_PAR01
	
	cRacSoc += Space(200-len(cRacSoc))
	
	// Obtener CGC de la Razón social
	nLin := FPOSTAB('S011',cRacSoc, '=', 4) 
	If nLin == 0
		MsgAlert(STR0018 + mv_par01) // "No existe registro en S011 para razón Social "
	Else
		// Obtener CGC
		cNumNIT	:= fTabela('S011',nLin,5)
		nLin2 	:= FPOSTAB('S010',cNumNIT, '=', 4) // Posición en S010
		nLin3 	:= FPOSTAB('S012',cNumNIT, '=', 4)  // Posición en S012
		
		//Buscar todas filiales con mismo CGCAD
		For nI := 1 to len(aSM0)	
			If alltrim(cNumNIT) == alltrim(aSM0[nI,18])
				aAdd(aFils,aSM0[nI,2])
				cFils +=  aSM0[nI,2] +";"
			EndIf
		Next nI
		// Una vez encontradas, se realiza búsqueda de información de la empresa para generar encabezado		
		aAdd(aRet,fTabela('S011',nLin,11))
		aAdd(aRet,cNumNIT)
		aAdd(aRet,cRacSoc)
		aAdd(aRet,fTabela('S011',nLin,7))
		aAdd(aRet,fTabela('S010',nLin2,16))
		aAdd(aRet,"")
		aAdd(aRet,IIF(fTabela('S012',nLin3,13) == '1','S','N'))
		aAdd(aRet,"")
		aAdd(aRet,"")
	EndIf 
		
Return aRet


/*/{Protheus.doc} BuildFile
función que genera archivo en Excel 
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param cArq, character, Ruta dónde será generado el archivo
@param aEnc, array, Array con los Datos del Aportante
@param aDet, array, Array con el detalle por empleado
@param aPD, array, Array con Detalle por Concepto
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function BuildFile(cArq, aEnc, aDet,aPD)
	Local aXML		:= {}
	Local lRet		:= .F.
	Local nI		:= 0
	Local nJ		:= 0
	Local cDato		:= ""
	Local cCellS63	:= '    <Cell ss:StyleID="s63"/>'
	Local cCellS67	:= '    <Cell ss:StyleID="s67"/>'
	Local cCellS68	:= '    <Cell ss:StyleID="s68"/>'
	Local cCellS91	:= '    <Cell ss:StyleID="s91"/>'
	Local cUGPPS65	:= '    <Cell ss:StyleID="s65"><Data ss:Type="String">CAMPO RESERVADO PARA LA UGPP</Data></Cell>'
	
	Default cArq := ""
	Default aEnc := {}
	Default aDet := {}
	Default aPD  := {}
	
	If len(aEnc)>0 .and. len(aDet) > 0
		aAdd( aXML, '<?xml version="1.0"?>')
		aAdd( aXML, '<?mso-application progid="Excel.Sheet"?>')
		aAdd( aXML, '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
		aAdd( aXML, ' xmlns:o="urn:schemas-microsoft-com:office:office"')
		aAdd( aXML, ' xmlns:x="urn:schemas-microsoft-com:office:excel"')
		aAdd( aXML, ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"')
		aAdd( aXML, ' xmlns:html="http://www.w3.org/TR/REC-html40">')
		aAdd( aXML, ' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">')
		aAdd( aXML, '  <Author>Microsiga Protheus</Author>')
		aAdd( aXML, '  <LastAuthor>Hub Norte Developer Team</LastAuthor>')
		aAdd( aXML, '  <Created>2011-11-11T00:00:00Z</Created>')
		aAdd( aXML, '  <Version>15.00</Version>')
		aAdd( aXML, ' </DocumentProperties>')
		aAdd( aXML, ' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">')
		aAdd( aXML, '  <AllowPNG/>')
		aAdd( aXML, ' </OfficeDocumentSettings>')
		aAdd( aXML, ' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">')
		aAdd( aXML, '  <WindowHeight>5340</WindowHeight>')
		aAdd( aXML, '  <WindowWidth>9210</WindowWidth>')
		aAdd( aXML, '  <WindowTopX>0</WindowTopX>')
		aAdd( aXML, '  <WindowTopY>0</WindowTopY>')
		aAdd( aXML, '  <ProtectStructure>False</ProtectStructure>')
		aAdd( aXML, '  <ProtectWindows>False</ProtectWindows>')
		aAdd( aXML, ' </ExcelWorkbook>')
		aAdd( aXML, ' <Styles>')
		aAdd( aXML, '  <Style ss:ID="Default" ss:Name="Normal">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom"/>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="m2661035840304">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="m2661035840324">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="m2661035840344">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="m2661035840364">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s62">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s63">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s64">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s65">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s66">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s67">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s68">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom"/>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s82">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom"/>')
		aAdd( aXML, '   <Borders>')
		aAdd( aXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '   </Borders>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s90">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom"/>')
		aAdd( aXML, '   <Borders>')
		aAdd( aXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '   </Borders>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s91">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom"/>')
		aAdd( aXML, '   <Borders>')
		aAdd( aXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '   </Borders>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s92">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom"/>')
		aAdd( aXML, '   <Borders>')
		aAdd( aXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '   </Borders>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s93">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>')
		aAdd( aXML, '   <Borders>')
		aAdd( aXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '</Borders>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s94">')
		aAdd( aXML, '   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>')
		aAdd( aXML, '   <Borders>')
		aAdd( aXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
		aAdd( aXML, '   </Borders>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s95">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>')
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '   <NumberFormat ss:Format="0"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s96">')
		aAdd( aXML, '   <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>')
		fAddBorder(@aXML)
		aAdd( aXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>')
		aAdd( aXML, '   <NumberFormat ss:Format="0"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s103">')
		aAdd( aXML, '   <Alignment ss:Vertical="Center"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, '  <Style ss:ID="s108">')
		aAdd( aXML, '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>')
		aAdd( aXML, '  </Style>')
		aAdd( aXML, ' </Styles>')
		aAdd( aXML, ' <Worksheet ss:Name="UGPP">')
		aAdd( aXML, '  <Table x:FullColumns="1"')
		aAdd( aXML, '   x:FullRows="1" ss:DefaultColumnWidth="60" ss:DefaultRowHeight="15">')
		aAdd( aXML, '   <Column ss:Index="49" ss:AutoFitWidth="0" ss:Width="133.5"/>')
		// Encabezado títulos 
		
		aAdd( aXML, '   <Row ss:AutoFitHeight="0" ss:Height="56.25">')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">TIPO DOCUMENTO APORTANTE</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DOCUMENTO APORTANTE') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">' + EncodeUTF8('RAZÓN SOCIAL') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">' + EncodeUTF8('NATURALEZA JURÍDICA')+'</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">TIPO DE APORTANTE</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">CAMPO RESERVADO PARA LA UGPP</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">SUJETO PASIVO DEL IMPUESTO SOBRE LA RENTA PARA LA EQUIDAD CREE</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">CAMPO RESERVADO PARA LA UGPP</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">CAMPO RESERVADO PARA LA UGPP</Data></Cell>')
		fAddAtrib(15, cCellS63, @aXML)
		aAdd( aXML, '    <Cell ss:StyleID="s64"/>')
		fAddAtrib(23, cCellS63, @aXML)
		aAdd( aXML, cUGPPS65)
		aAdd( aXML, '   </Row>')
		// Encabezado Detalle
		aAdd( aXML, '   <Row ss:AutoFitHeight="0">')
		aAdd( aXML, '    <Cell ss:StyleID="s67"><Data ss:Type="String">' + EncodeUTF8(aEnc[1]) + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s67"><Data ss:Type="String">' + EncodeUTF8(aEnc[2]) + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s67"><Data ss:Type="String">' + EncodeUTF8(aEnc[3]) + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s67"><Data ss:Type="String">' + EncodeUTF8(aEnc[4]) + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s67"><Data ss:Type="String">' + EncodeUTF8(aEnc[5]) + '</Data></Cell>')
		aAdd( aXML, cCellS67)
		aAdd( aXML, '    <Cell ss:StyleID="s67"><Data ss:Type="String">' + EncodeUTF8(aEnc[7]) + '</Data></Cell>')
		fAddAtrib(2, cCellS67, @aXML)
		fAddAtrib(39, cCellS68, @aXML)
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">TIPO DE PAGO</Data></Cell>')
		/*
			CICLO PARA EL TIPO DE PAGO
		*/ 
		For nI := 1 to len(aPD)
			aAdd( aXML, '    <Cell ss:StyleID="s95"><Data ss:Type="String">'+ aPD[nI,7]+'</Data></Cell>')
		Next nI
		
		aAdd( aXML, '   </Row>')
		aAdd( aXML, '   <Row ss:AutoFitHeight="0" ss:Height="11.25">')
		fAddAtrib(48, cCellS68, @aXML)
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String"> CAMPO RESERVADO PARA LA UGPP</Data></Cell>')
		aAdd( aXML, '	</Row>')
		aAdd( aXML, '	<Row ss:AutoFitHeight="0" ss:Height="21.75">')
		fAddAtrib(48, cCellS68, @aXML)
		aAdd( aXML, cUGPPS65)
		aAdd( aXML, '   </Row>')
		aAdd( aXML, '   <Row ss:AutoFitHeight="0">')
		aAdd( aXML, '    <Cell ss:MergeAcross="13" ss:StyleID="m2661035840304"><Data ss:Type="String">' + EncodeUTF8('DATOS BÁSICOS DEL TRABAJADOR O ASOCIADO') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:MergeAcross="1" ss:StyleID="m2661035840324"><Data ss:Type="String">' + EncodeUTF8('PERIODO NÓMINA') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s82"/>')
		aAdd( aXML, '    <Cell ss:MergeAcross="4" ss:StyleID="m2661035840344"><Data ss:Type="String">NOVEDADES</Data></Cell>')
		aAdd( aXML, '    <Cell ss:MergeAcross="7" ss:StyleID="m2661035840364"><Data ss:Type="String">' + EncodeUTF8('REPORTE DE DÍAS') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s90"/>')
		fAddAtrib(16, cCellS91, @aXML)
		aAdd( aXML, '    <Cell ss:StyleID="s92"/>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">CUENTA CONTABLE</Data></Cell>')
		For nI := 1 to len(aPD)
			If Empty(aPD[nI,5])
				aAdd( aXML, '    <Cell ss:StyleID="s94"><Data ss:Type="String">'+ aPD[nI,6]+'</Data></Cell>')
			Else
				aAdd( aXML, '    <Cell ss:StyleID="s94"><Data ss:Type="String">'+ aPD[nI,5]+'</Data></Cell>')
			EndIf
		Next nI
		aAdd( aXML, '   </Row>')
		
		aAdd( aXML, '   <Row ss:AutoFitHeight="0" ss:Height="67.5">')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">ORDEN</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">TIPO COTIZANTE</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">SUBTIPO COTIZANTE</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('CONDICIÓN ESPECIAL EMPRESA') + '</Data></Cell>')
		aAdd( aXML, cUGPPS65)
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('EXTRANJERO NO OBLIGADO A COTIZAR A PENSIÓN') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">COLOMBIANO EN EL EXTERIOR</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('ACTIVIDAD ALTO RIESGO PENSIÓN') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">TIPO DOCUMENTO ACTUAL DEL COTIZANTE</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DOCUMENTO ACTUAL DEL COTIZANTE') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('TIPO DE DOCUMENTO CON EL QUE REALIZÓ APORTES DEL COTIZANTE') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DOCUMENTO CON EL QUE REALIZÓ APORTES DEL COTIZANTE') + ' </Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">NOMBRE COTIZANTE</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">CARGO DEL TRABAJADOR</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">ANIO</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">MES</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">SALARIO INTEGRAL</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">NOVEDAD INCAPACIDAD</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">NOVEDAD LIC MATERNIDAD O PATERNIDAD</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">NOVEDAD PERMISO O LICENCIA REMUNERADA</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NOVEDAD SUSPENSIÓN') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">NOVEDADES VACACIONES</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DÍAS TRABAJADOS EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DÍAS DE INCAPACIDAD EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DÍAS DE LICENCIA MATERNIDAD O PATERNIDAD EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DÍAS DE PERMISO O LICENCIA REMUNERADA EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DÍAS DE SUSPENSIÓN, PERMISO O LICENCIA NO REMUNERADA EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DÍAS DE VACACIONES DISFRUTADAS EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO DE DÍAS DE HUELGA DECLARADA LEGALMENTE EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">' + EncodeUTF8('NÚMERO TOTAL DE DÍAS REPORTADOS EN EL MES') + '</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">INGRESO</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">FECHA INGRESO</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">RETIRO</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">FECHA RETIRO</Data></Cell>')
		fAddAtrib(6, cUGPPS65, @aXML)
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">OBSERVACIONES APORTANTE</Data></Cell>')
		fAddAtrib(6, cUGPPS65, @aXML)
		aAdd( aXML, '    <Cell ss:StyleID="s94"><Data ss:Type="String">CAMPO RESERVADO PARA LA UGPP</Data></Cell>')
		aAdd( aXML, '    <Cell ss:StyleID="s65"><Data ss:Type="String">NOMBRE CONCEPTO PAGO APORTANTE</Data></Cell>')
		For nI := 1 to len(aPD)
			aAdd( aXML, '    <Cell ss:StyleID="s95"><Data ss:Type="String">'+ aPD[nI,3]+'</Data></Cell>')
		Next nI
		aAdd( aXML, '</Row>')
		/* 
		 INSERTAR DETALLE AQUI
		*/
		For nI := 1 to len(aDet)
			aAdd( aXML,' <Row ss:AutoFitHeight="0">')
			For nJ:= 1 To len(aDet[nI])	
				cDato := aDet[nI, nJ]
				If	Valtype(cDato) == "N"
					cDato := ALLTRIM(STR(cDato))
				EndIf				
				aAdd( aXML,'    <Cell><Data ss:Type="String">' + EncodeUTF8(cDato) + '</Data></Cell>')
			Next nJ		
			aAdd( aXML, '</Row>')
		Next nI
		// Fin detalle
		aAdd( aXML, '</Table>')
		aAdd( aXML, '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
		aAdd( aXML, '<PageSetup>')
		aAdd( aXML, '<Header x:Margin="0.3"/>')
		aAdd( aXML, '<Footer x:Margin="0.3"/>')
		aAdd( aXML, '<PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>')
		aAdd( aXML, '</PageSetup>')
		aAdd( aXML, '<Unsynced/>')
		aAdd( aXML, '<Print>')
		aAdd( aXML, '<ValidPrinterInfo/>')
		aAdd( aXML, '<PaperSizeIndex>5</PaperSizeIndex>')
		aAdd( aXML, '<HorizontalResolution>600</HorizontalResolution>')
		aAdd( aXML, '<VerticalResolution>0</VerticalResolution>')
		aAdd( aXML, '   </Print>')
		aAdd( aXML, '   <Selected/>')
		aAdd( aXML, '   <Panes>')
		aAdd( aXML, '    <Pane>')
		aAdd( aXML, '  <Number>3</Number>')
		aAdd( aXML, ' <ActiveRow>6</ActiveRow>')
		aAdd( aXML, ' <RangeSelection>R7:R49</RangeSelection>')
		aAdd( aXML, ' </Pane>')
		aAdd( aXML, '</Panes>')
		aAdd( aXML, '<ProtectObjects>False</ProtectObjects>')
		aAdd( aXML, '<ProtectScenarios>False</ProtectScenarios>')
		aAdd( aXML, '</WorksheetOptions>')
		aAdd( aXML, '</Worksheet>')
		aAdd( aXML, '</Workbook>')		
		
		lRet := WriteFile(cArq,aXML)
	EndIf
	
Return lRet 
/*/{Protheus.doc} WriteFile
función que escribe el archivo excel en una ruta dada
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param cArquivo, Ruta del Archivo a generar
@param aLines, Array con la información que será vaciada en el archivo a generar
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function WriteFile(cArquivo,aLines) 
	Local nHandle	:= MSFCREATE(cArquivo, 0)
	Local nCount	:= 0
	Default aLines	:= {}	
	
	IF FError() != 0 .AND. nHandle = -1 
		MsgInfo(STR0019 + STR(FError(), 3), STR0020) // "Erro de Gravacao do Arquivo - Codigo DOS: " "Error"
		Return .F.
	EndIf
	
	If File( cArquivo )
		fErase( cArquivo )
	EndIf
	
	For nCount := 1 To Len(aLines)
	    Fwrite(nHandle, aLines[nCount] )
	Next nCount

	FClose(nHandle)
Return .T.
/*/{Protheus.doc} fgetPer
Obtiene los periodos en un mes y año dados
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param cMEs, caracter, Mes 
@param cYear, Año 
@return cYear, Año 
@example
(examples)
@see (links_or_references)
/*/
Static function fgetPer(cMes,cYear)

	Local aPer := {}
	Local aArea := getArea()
	
	Default cMes 	:= ""
	Default cYear 	:= ""
	
	If !Empty(cMes) .or. !Empty(cYear)
		cMes := strZero(Val(cMes),2) 
		
		dbselectarea("RCH")
		dbSetOrder(7)
		
		If RCH->(dbSeek(XFILIAL("RCH")+cYear+cMes))	
			Do While RCH->(!EOF()) 
				If RCH->RCH_MES == cMes .AND. RCH->RCH_ANO == cYear .and. RCH->RCH_ROTEIR $ cProcedim ;
				.and. rTrim(RCH->RCH_PROCES) $ cProcesos
					aAdd(aPer,{RCH->RCH_PER,RCH->RCH_ROTEIR,RCH->RCH_PROCES,RCH->RCH_DTINI,RCH->RCH_DTFIM})
				EndIf
				RCH->(DBSkip())
			EndDo
		EndIf
	Else
		MsgAlert(STR0022 + cMex + " /" + cYear) // "Periodo dado no esválido - " 
	EndIf
	RestArea(aArea)		
Return aPer

/*/{Protheus.doc} FgetEmpl
Obtiene los empleados com movimientos en SRC/SRD para 
el proceso, procedimientos, periodos, sucursales dadas
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param aPer,  array, Periodos del mes y año dado en aprámetros
@return cAliasMov, Tabla temporal generada con los resultados del Query.
@example
(examples)
@see (links_or_references)
/*/
Static Function FgetEmpl(aPer)
	Local aArea		:= GetArea()
	Local cAliasMov	:= GetNextAlias()
	Local nI 		:= 0
	Local cRotSRD	:= "% SRD." + rangeSX1("RD_ROTEIR",cProcedim) + " %"
	Local cRotSRC	:= "% SRC." + rangeSX1("RC_ROTEIR",cProcedim) + " %"
	Local cExpFils	:= "% SRA." + rangeSX1("RA_FILIAL",cFils) + " %" 
	Local cExpProc 	:= "% SRA." + rangeSX1("RA_PROCES",cProcesos) + " %"
	Local cOrdem	:= "%SRA.RA_FILIA, SRA.RA_MAT % "
	
	Private cExpPer := ""
	DEFAULT aPer 		:= {}

	cExpPer :="% IN ("
	For nI := 1 to len(aPer)
		cExpPer += "'" + aPer[nI,1] + "'"
		
		If nI < len(aPer)
			cExpPer += ","
		End If
	Next nI	
	cExpPer+= ")%"

	If !(len(aPer) <> 0)
		cExpPer:= "% IN (' ') %"
	EndIF
	If MV_PAR09 == 1
		cOrdem := "% SRA.RA_PRISOBR,SRA.RA_SECSOBR,SRA.RA_PRINOME,SRA.RA_SECNOME %"
	ElseIf MV_PAR09 == 2
		cOrdem := "% SRA.RA_TPCIC, SRA.RA_CIC %"
	EndIf

	BeginSql alias cAliasMov
		SELECT SRA.*
		FROM %Table:SRA% SRA
		WHERE %exp:cExpFils%
			AND (SRA.RA_MAT IN (
			SELECT DISTINCT SRC.RC_MAT
			FROM %table:SRC% SRC
			WHERE   %exp:cRotSRC% AND SRC.RC_PERIODO %exp:cExpPer% AND SRC.%notDel%) OR
			SRA.RA_MAT IN (
			SELECT DISTINCT SRD.RD_MAT
			FROM %table:SRD% SRD
			WHERE %exp:cRotSRD% AND SRD.RD_PERIODO %exp:cExpPer% AND SRD.%notDel%))
			AND %exp:cExpProc%
			AND SRA.RA_CIC <> ' '
			AND SRA.%notDel%	 
			ORDER BY %exp:cOrdem%
	EndSql

	RestArea(aArea)
Return cAliasMov
/*/{Protheus.doc} DateToStr
Función para convertir una fecha en un formato dado
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param dDate, date, fecha a formatear
@param cformat, string, Formato al cuá lserá convertido una fecha
@return cReturn, Fecha a tipo caracter convertida al formado estabelcido
@example
(examples)
@see (links_or_references)
/*/
Static Function DateToStr(dDate, cFormat)
	Local cReturn := ""

	If cFormat == "YYYY-MM"
		cReturn := Year2Str(dDate) +"-"+ Month2Str(dDate)
	Elseif cFormat == "YYYYMM"
		cReturn := Year2Str(dDate) + Month2Str(dDate)
	Else
		cReturn := Year2Str(dDate) +"-"+ Month2Str(dDate) +"-"+ Day2Str(dDate)
	EndIf
Return cReturn

/*/{Protheus.doc} GetParameter
oBTIENE VALORES DE LAS TABLAS ALFANUMERICAS
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param cTab, caracter, Tabla alfanumérica
@param cCod, caracter, Código de Búsqueda
@param nPosCol, numerico, Poscición de la columna de b´squeda
@param nPosCol, numerico, Poscición de la columna de retorno
@return cReturn, Resultado obtenido de la posición indicada
@example
(examples)
@see (links_or_references)
/*/
Static Function GetParameter(cTab,cCod,nPosCol,nPosRet)
	Local nLin 		:= 0
	Local cReturn	:= ""
	Local aArea 	:= getArea()
	
	nLin 	:= fPostab(cTab,cCod,"=",nPosCol)
	If nLin > 0
		cReturn := fTabela(cTab, nLin, nPosRet) 
	EndIf		
	RestArea(aArea)
Return cReturn
/*/{Protheus.doc} fGetCond
Obtiene con el número de años de antigüedad de un empleado. la condicion de la empresa
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param cProc, Caracter, ${param_descr}
@param cYear, Caracter}, ${param_descr}
@param nOpc, numerico, ${param_descr}
@return nYears, número de Año de Antiogüedad
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetCond(cProc,dDtPar,cOpc)

	Local nYears:= 0
	Local dDtRCJ:= CTOD(" / / ")
	Local cCond := ""
	
	Default cProc := ""
	Default dDtPar := ddatabase
	Default cOpc := ""
	
	dDtRCJ := POSICIONE("RCJ",1,XFILIAL("RCJ") + cProc, "RCJ_FCHMAT")
	If !Empty(dDtRCJ)
		nYears := DateDiffYear(dDtRCJ,dDtPar)
	EndIf
	Do case
		Case cOpc == "01"
			Do case
				Case nYears <= 3 .and. nYears > 0
					cCond := STR0024 + STR(nYears,1) //"Ley 590/2000 año "
				Case nYears > 3
					cCond := ""
			End Case
		Case cOpc == "02"
			Do case
				Case nYears <= 3
					cCond := STR0025 //"Ley 1429 Col años 1 y 2"
				Case nYears <= 5
					cCond := STR0026 + STR(nYears,1) //"Ley 1429 Col año "
				Otherwise
					cCond := ""
			End Case
		Case cOpc == "03"
			Do case
				Case nYears <= 8
					cCond := STR0027 //"Ley 1429 AGV años 1 al 8"
				Case nYears <= 10
					cCond := STR0028 + STR(nYears,1) //"Ley 1429 AGV año "
				Otherwise
					cCond := ""
			End Case
		Otherwise
			DBSelectArea("SX5")
			If SX5->(MsSeek(xFilial("SX5") + "SH" + cOpc))
				cCond := X5Descri()
			EndIf
	End Case
		
Return cCond

/*/{Protheus.doc} FgetMovPer
(long_description)
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param aMat,array, Array de matrículas de un empleado
@param aPD ,array, array de conceptos a seleccionar
@param aPer,array, array de periodos 
@return calisMov, Alias de la tabla temporal que será examinada para revisar los movimeints del empleado.
@example
(examples)
@see (links_or_references)
/*/
Static Function FgetMovPer(aMat,aPD,aPer)

	Local aArea			:= GetArea()
	Local cAliasMov		:= GetNextAlias()
	Local cMats			:= "%("
	Local cFils1		:= "%("
	Local nI 			:= 0
	Local cRotSRD		:= "% SRD." + rangeSX1("RD_ROTEIR",cProcedim) + " %"
	Local cRotSRC		:= "% SRC." + rangeSX1("RC_ROTEIR",cProcedim) + " %"
	Local cPD			:= "" 
	Local cPer			:= "%"
	Local cProcSRC		:= IIF(Empty(cProcesos),"","% AND SRC." + rangeSX1("RC_PROCES",cProcesos) +" %" )
	Local cProcSRD		:= IIF(Empty(cProcesos),"","% AND SRD." + rangeSX1("RD_PROCES",cProcesos) +" %")
	
	DEFAULT aMat 	   	:= {SRA->RA_FILIAL,SRA->RA_MAT}
	DEFAULT aPd		:= {}
	//- Carregar somente os itens gerados pelo select
	cPD := "% ("
	For nI:=1 to len(aPD)
		cPD +="'" + aPD[nI,2] + "' " 
		If nI < len(aPD)
			cPD += ","
		Else 
			cPD+= ") %"
		End If
	Next nI
	
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils1 += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils1 += ","
		Else 
			cMats+= ")%"
			cFils1+= ")%"
		End If
	Next nI			

	cPer :="% ("
	For nI := 1 to len(aPer)
		cPer += "'" + aPer[nI,1] + "'"		
		If nI < len(aPer)
			cPer += ","
		End If
	Next nI	
	cPer+= ")%"
	
	BeginSql alias cAliasMov
		SELECT SUM(VALOR) AS VALOR, SUM(HORAS) AS HORAS, PD, IDCALC
		FROM (	
			SELECT sum(SRC.RC_VALOR) AS VALOR,sum(SRC.RC_HORAS) AS HORAS, RC_PD AS PD, RV_CODFOL AS IDCALC
			FROM %table:SRA% SRA	INNER JOIN %table:SRC% SRC  
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT	
			INNER JOIN  %table:SRV% SRV ON SRC.RC_PD=SRV.RV_COD 
				AND SRV.RV_FILIAL=%EXP:xFilial("SRV")% AND SRV.%notDel%	
			WHERE  SRA.RA_FILIAL IN %exp:cFils1%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND %exp:cRotSRC%
			  AND SRC.RC_PERIODO IN %exp:cPer%
			  AND SRA.%notDel% %exp:cProcSRC% AND SRC.%notDel% 
			  GROUP BY SRC.RC_PD,RV_CODFOL 
		UNION 
			SELECT sum(SRD.RD_VALOR) AS VALOR,sum(SRD.RD_HORAS) AS HORAS, SRD.RD_PD AS PD, RV_CODFOL AS IDCALC
			FROM %table:SRA% SRA	INNER JOIN %table:SRD% SRD  
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT	
			INNER JOIN  %table:SRV% SRV ON SRD.RD_PD=SRV.RV_COD 
			AND SRV.RV_FILIAL=%EXP:xFilial("SRV")% AND SRV.%notDel% 	
			WHERE  SRA.RA_FILIAL IN %exp:cFils1%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND %exp:cRotSRD%
			  AND SRD.RD_PERIODO IN %exp:cPer%
			  AND SRA.%notDel% %exp:cProcSRD% AND SRD.%notDel% 	
			  GROUP BY SRD.RD_PD,RV_CODFOL 	
		  ) V GROUP BY VALOR, HORAS, PD ,IDCALC
	EndSql
	
	RestArea(aArea)

Return cAliasMov
/*/{Protheus.doc} fFindMatAdic
función que retorna las matríclas en caso de que un empleado 
pertenezca a más de un sucursal.
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param cNIT, string, 
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function fFindMatAdic(cNIT)
	Local aArea		:= GetArea()
	Local cFields	:= ""
	Local cAliasSRA	:= GetNextAlias()
	Local aDados	:= {}
	
	DEFAULT cNIT	:= SRA->RA_RG
	
	cFields := "%RA_FILIAL,RA_MAT,RA_PROCES%"			

	//-- Selección de regsitros en SRA para el mismo empleado.
	BeginSql alias cAliasSRA
		SELECT %exp:cFields%
		FROM %table:SRA%
		WHERE RA_RG = %exp:cNIT%
		  AND %notDel%
		  ORDER BY RA_MAT 
	EndSql
	
	//-- Geracao das informacoes no array 
	While (cAliasSRA)->(!Eof())
		If rTrim((cAliasSRA)->RA_PROCES) $ cProcesos
			aadd(aDados,{(cAliasSRA)-> RA_FILIAL,(cAliasSRA)->RA_MAT ,(cAliasSRA)->RA_PROCES})
		End If
		(cAliasSRA)->( DbSkip() )			
	EndDo
	(cAliasSRA)->( DbCloseArea() )
	
	RestArea(aArea)
Return aDados
/*/{Protheus.doc} fgetPD
Obtiene los conceptos e ndónde rv_tipocod=1 del catálogo de conceptos para
el periodo, procedimiento y proceso dados. Estos conceptos deberán haber sido cálculados en el mes y año indicados.
@type function
@author mayra.camargo
@since 08/04/2019
@version 1.0
@param aPer, array, Periodos en dónde se realizará el filtro de conceptos
@return aDados, array con los conceptos encontrados
@example
(examples)
@see (links_or_references)
/*/
Static function fgetPD(aPer)
	Local aArea		:= GetArea()
	Local cAliasPD	:= GetNextAlias()
	Local aDados	:= {}
	Local nX		:= 49
	Local cPer		:= ""
	Local nI		:= 0
	Local cFilsSRC	:= "% SRC." + RangeSX1("RC_FILIAL", cFils) + " %" 
	Local cFilsSRD	:= "% SRD." + RangeSX1("RD_FILIAL", cFils) + " %"
	Local cRotSRD	:= "% SRD." + RangeSX1("RD_ROTEIR", cProcedim) + " %"
	Local cRotSRC	:= "% SRC." + RangeSX1("RC_ROTEIR", cProcedim) + " %"
	Local cTpPago	:= ""
	
	cPer :="% ("
	For nI := 1 to len(aPer)
		cPer += "'" + aPer[nI,1] + "'"		
		If nI < len(aPer)
			cPer += ","
		End If
	Next nI	
	cPer+= ")%"
	
	//-- mOVIMIENTOS DE NOMINA E HIST´ROICO DE NOMINA
	BeginSql alias cAliasPD
		SELECT RC_FILIAL as FILIAL, RC_PD AS PD, RV_DESCDET AS DESCRI, RV_CODFOL AS IDCALC, 
		RV_CTACAR AS CARGO, RV_CTAABO AS ABONO , RV_SALARIA AS SALARIA
		FROM %Table:SRC% SRC INNER JOIN %Table:SRV% SRV ON RC_PD=RV_COD AND RV_TIPOCOD='1' 
		AND RV_FILIAL = %exp:xFilial("SRV")% AND SRV.D_E_L_E_T_=' '
		WHERE  SRC.RC_PERIODO  IN %exp:cPer%
		AND %exp:cFilsSRC%
		and (RC_VALOR >0 OR RC_HORAS > 0)
		AND %exp:cRotSRC%
		AND SRC.%notDel%
		UNION
		SELECT RD_FILIAL AS FILIAL, RD_PD AS PD, RV_DESCDET AS DESCRI, RV_CODFOL AS IDCALC,
		RV_CTACAR AS CARGO, RV_CTAABO AS ABONO, RV_SALARIA AS SALARIA
		FROM %Table:SRD% SRD INNER JOIN %Table:SRV% SRV ON SRD.RD_PD=RV_COD AND SRV.RV_TIPOCOD='1' 
		AND SRV.RV_FILIAL = %exp:xFilial("SRV")%  AND SRV.%notDel%
		WHERE SRD.RD_PERIODO  IN %exp:cPer%
		AND %exp:cFilsSRD%
		AND (SRD.RD_VALOR >0 OR SRD.RD_HORAS > 0)
		AND %exp:cRotSRD%
		AND SRD.%notDel%  
		ORDER BY PD
	EndSql
	
	//-- Selección del tipo de pago del empleado.
	While (cAliasPD)->(!Eof())
		nX++
		If (cAliasPD)->IDCALC $ "0072|1088|0087|0086|0088"
			cTpPago := STR0029 //"TP Vacaciones" 
		ElseIf (cAliasPD)->IDCALC $ "0043"
			cTpPago := STR0030 //"TP Licencia Remunerada"
		ElseIf (cAliasPD)->IDCALC $ "0444|0054|0442"
			cTpPago := STR0031 //"TP No compensación"
		ElseIf (cAliasPD)->IDCALC $ "0041|0042"
			cTpPago := STR0032 //"TP Incapacidad"
		ElseIf (cAliasPD)->SALARIA $ "1"
			cTpPago := STR0033 //"TP Salarial"
		ElseIf (cAliasPD)->SALARIA $ "2|3"
			cTpPago := STR0034 //"TP NO Salarial"
		EndIf
		aAdd(aDados,{nX,(cAliasPD)-> PD,(cAliasPD)->DESCRI ,(cAliasPD)->IDCALC,(cAliasPD)->CARGO,(cAliasPD)->ABONO,EncodeUTF8(cTpPago) })
		(cAliasPD)->(DbSkip())			
	EndDo
	(cAliasPD)->( DbCloseArea() )
	
	RestArea(aArea)
Return aDados

/*/{Protheus.doc} fAddAtrib
Agrega al array aXML el atributo indicado n veces.

@type Static Function
@author Marco Augusto González Rivera
@since 29/05/2021
@version 1.0
@param nVecesAdd, Numérico, Indica las veces que se agregará el atributo al array aXML
@param cStringXML, Caracter, Atributo que será agregado al array aXML
@param aXML, array, Parametro pasado por referencia al cual se agregara n veces el atributo informado.
@example fAddAtrib(nVecesAdd, cStringXML, @aXML)
@see (links_or_references)
/*/
Static function fAddAtrib(nVecesAdd, cStringXML, aXML)

	Local nIteracion	:= 0

	Default nVecesAdd	:= 0
	Default cStringXML	:= ""
	Default aXML		:= {}
	
	For nIteracion := 1 To nVecesAdd
		aAdd(aXML, cStringXML)
	Next nIteracion

Return

/*/{Protheus.doc} fAddBorder
Agrega al array aXML el nodo Borders.

@type Static Function
@author Marco Augusto González Rivera
@since 29/05/2021
@version 1.0
@param aXML, array, Array con estructura del XML.
@example fAddBorder(@aXML)
@see (links_or_references)
/*/
Static Function fAddBorder(aXML) 
	
	Default aXML := {}

	aAdd( aXML, '   <Borders>')
	aAdd( aXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
	aAdd( aXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
	aAdd( aXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
	aAdd( aXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
	aAdd( aXML, '   </Borders>')

Return
