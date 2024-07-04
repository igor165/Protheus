#INCLUDE "Protheus.ch"
#INCLUDE "FileIO.ch"
#INCLUDE "GPEM005DOM.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPEM005DOM³ Autor ³ Alfredo Medrano Breña ³    Data    ³   19/06/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de Archivo Anual sobre los asalariados del período DGT-3 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM005DOM()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³      FNC      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alf Medrano³07/08/17³DMINA-155      ³se elimina la func GenArch el contenido se³±±
±±³            ³        ³               ³fusiona con Func ObtHisAcum para optimizar³±±
±±³            ³        ³               ³el proceso                                ³±±
±±³Marco A. Glz³11/08/17³   DMINA-171   ³Se realiza replica para V12.1.14 de       ³±±
±±³            ³        ³               ³DMINA-51 Archivo DGT-3.                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM005DOM()

	Local aSays		:= { }
	Local aButtons	:= { }
	Local aGetArea	:= GetArea()
	Local cPerg		:= "GPM005DOM" 
	Local nOpca		:= 0  
	
	Private cCadastro	:= OemtoAnsi(STR0001)//"Archivo DGT-3 "
	Private cAliasTmp	:= CriaTrab(Nil,.F.)	  
	//Variables de entrada (parámetros) 
	Private cFilIni		:= ""   //De Sucursal
	Private cFilFin		:= ""	//A Sucursal
	Private cProIni		:= ""   //De Proceso
	Private cProFin		:= ""   //A Proceso
	Private cMatIni		:= ""	//De Matricula
	Private cMatFin		:= ""	//A Matricula
	Private cPerAut		:= ""	//Periodo 
	Private cArchivo	:= '' //Archivo 
	Private cEOL		:= CHR(13)+CHR(10) //Salto linea
	Private lExisArc	:= .F.
	Private nMax		:= 0

	DBSelectArea("SRA")  //Empleados
	DBSelectArea("SQ3")  //Cargos
	DBSelectArea("SRV")  //Conceptos 
	
	aAdd(aSays, OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos de formulario DGT-3"

	aAdd(aButtons, {5, .T., {|| Pergunte(cPerg, .T.)}})
	aAdd(aButtons, {1, .T., {|o| nOpca := 1, If(TodoOK(cPerg), FechaBatch(), nOpca := 0)}})
	aAdd(aButtons, {2, .T., {|o| FechaBatch()}})

	FormBatch(cCadastro, aSays, aButtons)

	If nOpca == 1 //Ejecuta el proceso
		Processa({|| ObtHisAcum()})
		If nMax == 0             
			If !lExisArc
				MsgInfo(STR0005 )//"Proceso Finalizado! No encontro registros..."
			EndIf
		Else
			MsgInfo(STR0006 + cEOL + cArchivo)   //"Proceso Finalizado, Genero los archivos: "
		EndIf
	EndIf

	RestArea(aGetArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPR002DQ  ³ Autor ³ Alf Medrano           ³ Data ³24/07/2017³±±
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
Function GPM005DQ()
   
	Local cQuery		:= ""   
	Local cFecIni			:= cPerAut + "0101"   
	Local cFecFin			:= cPerAut + "1231"   

	cQuery := "SELECT RA_FILIAL,RCP_FILIAL, RA_MAT, RA_NUMINSC, RA_CIC, RA_PASSPOR, RA_PRINOME, RA_KEYLOC, "
	cQuery += " RA_SECNOME, RA_SALARIO, RA_PRISOBR, RA_SECSOBR, RA_SEXO, RA_NASC, RA_ADMISSA," 
	cQuery += " RA_DEMISSA,RA_SITFOLH, Q3_OCUPAC, Q3_DESCSUM, RA_NACIONA, RCP_MAT, RCP_DTMOV, RCP_TPMOV  " 
	cQuery += "FROM " + RetSqlName("SRA") + " SRA INNER JOIN " +  RetSqlName("SQ3") + " SQ3 ON SRA.RA_CARGO = SQ3.Q3_CARGO "
	cQuery += " LEFT OUTER JOIN " + RetSqlName("RCP") + " RCP ON SRA.RA_FILIAL = RCP.RCP_FILIAL AND SRA.RA_MAT = RCP.RCP_MAT AND RCP.D_E_L_E_T_ = ' ' " 
	cQuery += " AND RCP.RCP_DTMOV >='" + cFecIni + "' AND RCP.RCP_DTMOV <='" + cFecFin + " ' " 
	cQuery += "WHERE"
	cQuery += "	RA_FILIAL BETWEEN '" + cFilIni + "' AND '" + cFilFin + "'"  
	cQuery += "	AND RA_MAT BETWEEN '" + cMatIni + "' AND '" + cMatFin + "'"
	cQuery += "	AND RA_PROCES BETWEEN '" + cProIni + "' AND '" + cProFin + "'"
	cQuery += "	AND (( RA_ADMISSA <= '" + cFecFin + "' AND RA_SITFOLH <> 'D' ) " 
	cQuery += "	OR ( RA_DEMISSA >= '" + cFecIni + "'  AND RA_SITFOLH = 'D' ))" 
	cQuery += "   AND Q3_FILIAL = '" + xfilial('SQ3') +"'"
	cQuery += "   AND SRA.D_E_L_E_T_ = ' '"   
	cQuery += "   AND SQ3.D_E_L_E_T_ = ' '"   
	cQuery += "ORDER BY RA_FILIAL, RA_MAT, RCP_DTMOV DESC"    
	cQuery := ChangeQuery(cQuery) 
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTmp, .T., .T.)

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ GPM796GERA³ Autor ³ Alfredo Medrano     ³ Data ³ 19/06/17 ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Generacion de los archivos.                               ³±± 
±±³           ³                                                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ ObtHisAcum()                                              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³  Ninguno                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ GPM05GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtHisAcum()       
	
	Local nReg		:= 0   
	Local nloop		:= 0   
	Local lRet		:= .T.
	Local nArchivo	:= 0 
	Local cCedula	:= ""  
	Local cTipoDoc	:= " "
	Local cDocto	:= ""    
	Local lCedula	:= .F.
	Local dFecSal	:= CTOD("//") // Fecha Salario
	Local aFecRcp	:= {}   
	Local dFecFin	:= CTOD("31/12/" + cPerAut )
	Local cTipM		:= ""
	Local cFech		:= ""
	Local dFInVac	:= STOD("//")
	Local cMat		:= ""
	Local cNombre	:= ""
	Local cPrimAp	:= ""
	Local cSeguAp	:= ""
	Local cFecNac	:= ""
	Local cSex		:="" 
	Local cSalario	:= ""
	Local cFechIn	:= ""	
	Local cOcupac	:= ""	
	Local cDescr	:= ""
	Local cLocal	:= ""
	Local cNacio	:= ""
	Local nban		:= 0
	Local lAct		:= .f.

	GPM005DQ()
	Count To nReg
	(cAliasTmp)->(DBGoTop())
	ProcRegua(nReg)
	
	// Verifica si el archivo existe y si hay registros a procesar
	cArchivo	:= IIf(At(".txt", cArchivo) > 0, cArchivo, Alltrim(cArchivo) + '.txt')
	lExisArc	:= .F.
	
	cCedula	:=  PADR(fTabela("S012", 1, 5),11,'0') //RNC ó Cédula del empleador.
	If File(cArchivo) .AND. nReg > 0  //Si el archivo ya existe
		If MsgYesNo(OemToAnsi(STR0008  + Alltrim(cArchivo) + STR0009 ))   //"El archivo "+XXX+" ya existe, ¿Desea eliminarlo?"
			FErase(cArchivo) 		
		Else 
			lRet     := .F.   
			lExisArc := .T.  
			fClose(nArchivo) 
		EndIf 
	EndIf  

	If lRet
		//Creacion de archivo
		nArchivo  := MSfCreate(cArchivo,0)
		ProcRegua(nReg)  
	
		While (cAliasTmp)->(!EOF())
			IncProc()
			nloop++          
			
			lCedula	:= .F.
			lAct	:= .f.
			cTipM	:= "I"
			aFecRcp	:= {}
			dFecSal	:= CTOD("//")
			nban	:= 0
			
			cMat	:= (cAliasTmp)->RA_MAT
			cNombre	:= PADR(Alltrim((cAliasTmp)->RA_PRINOME) + " " + Alltrim((cAliasTmp)->RA_SECNOME),50)
			cPrimAp	:= PADR((cAliasTmp)->RA_PRISOBR , 40)
			cSeguAp	:= PADR((cAliasTmp)->RA_SECSOBR, 40)
			cFecNac	:= (cAliasTmp)->RA_NASC
			cSex	:= PADR((cAliasTmp)->RA_SEXO, 1 )
			cSalario:= StrZero(Val(Transform((cAliasTmp)->RA_SALARIO, "9999999999999")), 16)
			cFechIn	:= (cAliasTmp)->RA_ADMISSA
			cOcupac	:= PADR((cAliasTmp)->Q3_OCUPAC, 6 ) 
			cDescr	:= PADR((cAliasTmp)->Q3_DESCSUM, 150 ) 
			cLocal	:= PADR((cAliasTmp)->RA_KEYLOC, 6 ) 
			cNacio	:= PADL((cAliasTmp)->RA_NACIONA, 3 )

			//Genere encabezado 
			If nloop == 1          
				FWrite(nArchivo, "ET3" + cCedula + "01" + cPerAut + cEOL)
			EndIf   
			  
			//Validar si es Cedula de identidad/No. Pasaporte                      
			If !Empty((cAliasTmp)->RA_CIC)
				cDocto		:= (cAliasTmp)->RA_CIC //Cedula
				cTipoDoc	:= 'C'  
				lCedula		:= .T.
			ElseIf !Empty((cAliasTmp)->RA_PASSPOR)
				cDocto		:= (cAliasTmp)->RA_PASSPOR //Pasaporte
				cTipoDoc	:= 'P'
			EndIf
						
			//Tipo de novedad
			If (cAliasTmp)->RA_SITFOLH == 'D' //situación 
				If  STOD((cAliasTmp)->RA_DEMISSA ) <  dFecFin
					AADD(aFecRcp,{ STOD((cAliasTmp)->RA_DEMISSA ),"S"}) // fecha Baja
					lAct := .T.
				EndIf
			Else 
				AADD(aFecRcp,{ STOD((cAliasTmp)->RA_ADMISSA ),"I"}) // Fecha Ingreso
			EndIf	
			//si empleado tiene baja en el periodo no toma en cuenta los demás movimientos	
			While (cAliasTmp)->(!EOF()) .AND. ((cAliasTmp)->RA_FILIAL == (cAliasTmp)->RCP_FILIAL .OR. empty((cAliasTmp)->RCP_FILIAL) ) .AND. cMat == (cAliasTmp)->RA_MAT    
				If (cAliasTmp)->RCP_TPMOV == '05' .AND. !lAct 
					AADD(aFecRcp,{STOD((cAliasTmp)->RCP_DTMOV),"M"})
				EndIF
				(cAliasTmp)->(DBSkip())
			EndDo
	
			If Len(aFecRcp) > 0
				Asort(aFecRcp ,,, {|x,y| x[1] > y[1] })
				dFecSal:= aFecRcp[1,1]
				cTipM := aFecRcp[1,2]
			EndIf
			
			cFech:= GravaData(STOD(cFechIn),.F.,5)
			dFInVac:= STOD( cPerAut + SubStr(cFechIn,5,4)) 
			
			//Tipo Registro + Tipo Novedad + Tipo Documento + Numero documento
			FWrite(nArchivo, "D" + PADR(cTipM, 3) + cTipoDoc + PADL(cDocto, 25) +; 
			cNombre +; //Nombres
			cPrimAp +; //primer apellido
			cSeguAp +; // segundo apellido 
			PADR(GravaData(STOD(cFecNac),.F.,5), 8 ) +; //Fecha nacimiento
			cSex +; // sexo
			cSalario +; // Salario 
			IIf(lCedula, PADR("", 8 ), PADR(cFech, 8 )) +;  // fecha Ingreso
			cOcupac +; //ocupacion
			cDescr +; //Descripción
			PADR(SubStr(cFech,1,4) + cPerAut,8) +; //inicio Vacaciones
			PADR(GPM005DH(dFInVac,14), 8 ) +; //Fin de vacaciones
			PADL('2', 6 ) +;//Turno
			cLocal +;//Localidad
			cNacio +;//Nacionalidad
			PADR('', 150 ) +;//Observaciones
			cEOL ) // salto linea
			
		EndDo
		(cAliasTmp)->(DBCloseArea())
			
	EndIf		
			
	//Para cerrar el archivo creado
	If nloop > 0  
		//Registro sumario
		FWrite(nArchivo, "S" + StrZero(nloop, 6) + cEOL)
		fClose(nArchivo)  
		nMax := nloop  
	EndIf     
	 	 	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TodoOK   ³ Autor ³ Alfredo Medrano       ³ Data ³ 19/06/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que valida los parámetros de entrada para la obten-³±±  
±±³          ³ ción de la informacion.                                    ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TodoOK(cExp1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cExp1.-Nombre de grupo de pregunta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM796GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
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
	cPerAut   := AllTrim(Str(MV_PAR07))   //año
	cArchivo  := MV_PAR08   //Ubicacion del archivo de salida

	If Empty(cArchivo)
		MsgInfo(STR0007) //"¡Informe el directorio y el nombre del archivo!"
		lRet := .F.  
	ElseIf Empty(cPerAut)  
		MsgInfo(STR0010) //"¡Informe el año del periodo a calcular!"
		lRet := .F. 
	Else
		If Len(cPerAut) != 4
			MsgInfo(STR0011) //" Informe un año valido "
			lRet := .F. 
		EndIf
	EndIf	  

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPM005DH ³ Autor ³ Alfredo Medrano       ³ Data ³ 24/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Suma n días a una fecha tomando en cuenta los días hábiles ³±±  
±±³          ³                                                            ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM005DH(dExp1,nExp2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  dExp1 = Fecha   nExp = número a sumar                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GenArch                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function GPM005DH(dFecha,nDias)

	Local nDia		:= 0
	Local nI		:= 0
	Local ldFer		:= .F.
	Local cFecRet	:= ''
	Local dFecDia	:= CTOD("//")
	
	Default dFecha	:= CTOD("//")
	Default nDias	:= 0
	
	dFecDia := dFecha
	SP3->(dbselectarea('SP3')) // dias Feriados
	While nI < nDias
		ldFer := .F.
		dFecDia := dFecDia + 1
		nDia := DOW(dFecDia) //numero de dia
		If nDia <> 7  .AND. nDia<> 1 //Sabado y Domingo
			If SP3->(dbseek(xFilial("SP3")+DTOS(dFecDia))) //P3_FILIAL+DTOS(P3_DATA)
				ldFer := .T.
			EndIf
			If !ldFer
				nI++	
			Endif
		EndIf
	EndDo
	cFecRet := GravaData(dFecDia,.F.,5)
	
Return cFecRet