#INCLUDE "Protheus.ch"
#INCLUDE "FileIO.ch"
#INCLUDE "GPEM001DOM.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPEM001DOM³ Autor ³ Laura Medina Prado    ³    Data    ³   05/07/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de Archivos de Autodeterminacion Mensual                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM001DOM()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³      FNC      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina³31/08/11³               ³ Cambio para no considerar reingresos.    ³±±
±±³Christiane V³06/02/12³0000018871/2011³ Correção do error log                    ³±±
±±³Christiane V³08/02/12³0000018871/2011³ Correção para geração em ambiente DB2.   ³±±
±±³Mohanad Odeh³02/07/12³0000016814/2012³ Correção na impressão de valores no      ³±±
±±³            ³        ³         TFHBT9³cabeçalho e detalhe do arquivo.           ³±±
±±³  Marco A.  ³22/09/16³     TW5457    ³ Replica V12.1.7 a partir del llamado     ³±±
±±³            ³        ³               ³ TVQMZC para Republica Dominicana.        ³±±
±±³  Marco A.  ³27/10/16³    TWJZLB     ³ Se modifica la impresion de la columna   ³±±
±±³            ³        ³               ³ Salario Cotizable (RV_CODFOL = 0019) para³±±
±±³            ³        ³               ³ que se imprima en su lugar el valor del  ³±±
±±³            ³        ³               ³ RA_SALARIO por empleado. (DOM)           ³±±
±±³alf. Medrano³13/07/17³    MMI-6326   ³ Replica MMI-5977 Se sustituyó RA_SALARIO ³±±
±±³            ³        ³               ³a RG7_RA_ACUMXX donde XX es el mes selecci³±±
±±³            ³        ³               ³ -onado en periodo cuando RV_CODFOL = 0019³±±
±±³alf. Medrano³04/08/17³    DMINA-4    ³En func ObtHisAcum se quita query y se    ³±±
±±³            ³        ³               ³utiliza Func GPR002DQ también se genera   ³±±
±±³            ³        ³               ³cada línea del archivo de txt directamente³±±
±±³            ³        ³               ³en el ciclo del query. Se elimina GenArch ³±±
±±³            ³        ³               ³Se elimina la ObtAusen y se utiliza la    ³±±
±±³            ³        ³               ³func GPR002DI                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM001DOM()

	Local aSays		:= { }
	Local aButtons	:= { }
	Local aGetArea	:= GetArea()
	Local cPerg		:= "GPM001DOM"                    
	Local nOpca		:= 0     

	Private cAliasTmp	:= CriaTrab(Nil,.F.)	  
	Private cCadastro	:= OemtoAnsi(STR0001)//"Archivo de Autodeterminacion"
	
	//Variables de entrada (parámetros) 
	Private cSucI		:= ""   //De Sucursal
	Private cSucF		:= ""	//A Sucursal
	Private cProI		:= ""   //De Proceso
	Private cProF		:= ""   //A Proceso
	Private cMatI		:= ""	//De Matricula
	Private cMatF		:= ""	//A Matricula
	Private cPerAut		:= ""	//Periodo de autodeterminacion
	Private cTipArch	:= ""	//Tipo de autodeterminacion
	Private cArchivo	:= '' 
	Private cEOL		:= CHR(13)+CHR(10)
	Private cAnio		:= ""
	Private cMes		:= ""

	Private lExisArc	:= .F.
	Private lError		:= .F.

	Private nMax		:= 0

	DBSelectArea("SRA")  //Empleados
	DBSelectArea("RG7")  //Historico de acumulados
	DBSelectArea("SRV")  //Conceptos 
	DBSelectArea("RCJ")  //Procesos
	DbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³mv_par01 - ¿De Filial?                ³
	//³mv_par02 - ¿A Filial?                 ³
	//³mv_par03 - ¿De Proceso?               ³
	//³mv_par04 - ¿A Proceso?                ³
	//³mv_par05 - ¿De Matricula?             ³
	//³mv_par06 - ¿A Matricula?              ³
	//³mv_par07 - ¿Periodo Autodeterminacion?³
	//³mv_par08 - ¿Tipo Autodeterminacion?   ³
	//³mv_par09 - ¿Archivo?                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aAdd(aSays, OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos de Autodeterminación Mensual"	

	aAdd(aButtons, {5, .T., {|| Pergunte(cPerg, .T.)}})
	aAdd(aButtons, {1, .T., {|o| nOpca := 1, If(TodoOK(cPerg), FechaBatch(), nOpca := 0)}})
	aAdd(aButtons, {2, .T., {|o| FechaBatch()}})

	FormBatch(cCadastro, aSays, aButtons)

	If nOpca == 1 //Ejecuta el proceso
		Processa({|| ObtHisAcum()})
		If lError
			Msgalert(STR0004) //"Hubo problemas durante el proceso, y el archivo generado puede tener inconsistencias!!"
		Else	                      
			If nMax == 0             
				If !lExisArc
					MsgInfo(STR0005)//"Proceso Finalizado! No encontro registros..."
				EndIf
			Else
				MsgInfo(STR0006 + cEOL + cArchivo)   //"Proceso Finalizado, Genero los archivos: "
			EndIf
		EndIf
	EndIf

	RestArea(aGetArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ GPM796GERA³ Autor ³ Laura Medina        ³ Data ³ 05/07/11 ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Generacion de los archivos.                               ³±± 
±±³           ³                                                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ ObtHisAcum()  		                                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³  Ninguno                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ GPEM796                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtHisAcum()

	Local aHistoric		:= {}    
	Local nReg			:= 0   
	Local cEmpleado		:= Space(TamSX3("RA_FILIAL")[1] + TamSX3("RA_MAT")[1])
	Local nloop			:= 0   
	Local lRet			:= .T.
	Local nArchivo		:= 0 
	Local cCedula		:= ""
	Local nIdx			:= 1 //Solo va a existir un registro
	Local cTipoDoc		:= " "
	Local cDocto		:= ""    
	Local lCedula		:= .F.
	Local nAcum			:= ""
	Local nSalCoti		:= 0
	Local nFol1040		:= 0
	Local nFol0015		:= 0
	Local nFol0084		:= 0
	Local nFol1118		:= 0
	Local nFol0544		:= 0
	Local nFol0477		:= 0
	Local nFol1179		:= 0
	Local cNombre		:= ""
	Local cPrimAp		:= ""
	Local cSeguAp		:= ""
	Local cFecNac		:= ""
	Local cSex			:="" 
	Local cNumIns		:= ""
	Local cCIC			:= ""
	Local cPassP		:= ""
	Local cTipAdm		:= ""
	
	cAnio	:= SubStr(cPerAut, 3, 6) 
	cMes	:= StrZero(Val(SubStr(cPerAut, 1, 2)), 2)  
	
	/*
	ID de Calculo	Descripcion
	1040			Aporte Ordinario Voluntario
	0019			Salario SS
	0015			Salario ISR
	0084			Otras remuneraciones del trabajador en el mes aplicables ISR
	1118			Remuneraciones de otros empleados
	0544			Ingresos exentos de ISR
	0477			Saldo a favor del periodo
	*/

	GPR002DQ()
	
	Count To nReg
	(cAliasTmp)->(DBGoTop())
	ProcRegua(nReg)

	cArchivo	:= IIf(At(".txt", cArchivo) > 0, cArchivo, Alltrim(cArchivo) + '.txt')
	lExisArc	:= .F.
	cCedula		:= If(nIdx > 0, fTabela("S012", nIdx, 5), "")

	If File(cArchivo)  //Si el archivo ya existe
		If MsgYesNo(OemToAnsi(STR0008 + Alltrim(cArchivo) + STR0009))   //"El archivo "+XXX+" ya existe, ¿Desea eliminarlo?"
			FErase(cArchivo) 		
		Else 
			lRet     := .F.   
			lExisArc := .T.  
			fClose(nArchivo) 
		EndIf 
	EndIf     
	   
	If lRet
		nArchivo  := MSfCreate(cArchivo,0)
		ProcRegua(nReg)   	   
		While (cAliasTmp)->(!EOF())
			IncProc()
			nloop++

			lCedula		:= .F.
			cEmpleado	:= (cAliasTmp)->RA_CIC+(cAliasTmp)->RA_PASSPOR+(cAliasTmp)->RA_NUMINSC
			nSalCoti	:= 0
			nFol1040	:= 0
			nFol0015	:= 0
			nFol0084	:= 0
			nFol1118	:= 0
			nFol0544	:= 0
			nFol0477	:= 0
			nFol1179	:= 0
			//Genere encabezado 
			If nloop == 1          
				FWrite(nArchivo, "E" + IIf(cTipArch == 1, "AM", "AR") + PADR(cCedula, 11) + cPerAut + cEOL)
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
			
			cNumIns	:= (cAliasTmp)->RA_NUMINSC  
			cCIC	:= (cAliasTmp)->RA_CIC
			cPassP	:= (cAliasTmp)->RA_PASSPOR     
			cNombre	:= PADR(Alltrim((cAliasTmp)->RA_PRINOME) + " " + Alltrim((cAliasTmp)->RA_SECNOME),50) 
			cPrimAp	:= PADR((cAliasTmp)->RA_PRISOBR , 40)
			cSeguAp	:= PADR((cAliasTmp)->RA_SECSOBR, 40)
			cSex	:= PADR((cAliasTmp)->RA_SEXO, 1 )
			cFecNac	:= PADR((cAliasTmp)->RA_NASC, 8 )
			cTipAdm	:= (cAliasTmp)->RA_TIPOADM
			
			While cEmpleado == (cAliasTmp)->RA_CIC+(cAliasTmp)->RA_PASSPOR+(cAliasTmp)->RA_NUMINSC
				//Grabar ID de Calculo
				
				nAcum := (cAliasTmp)->RA_ACUMXX
				
				IIf((cAliasTmp)->RV_CODFOL == "0019",nSalCoti := nAcum,)//Salario Cotizable						
				IIf((cAliasTmp)->RV_CODFOL == "1040",nFol1040 := nAcum,)//Aporte Volinaro
				IIf((cAliasTmp)->RV_CODFOL == "0015", nFol0015 := nAcum,)//Salario ISR
				IIf((cAliasTmp)->RV_CODFOL == "0084",nFol0084 := nAcum,)	//Otras Remuneraciones						
				IIf((cAliasTmp)->RV_CODFOL == "1118",nFol1118 := nAcum,)	//Remuneraciones de Otros Empleadores		
				IIf((cAliasTmp)->RV_CODFOL == "0544",nFol0544 := nAcum,)	//Ingresos Exentos			
				IIf((cAliasTmp)->RV_CODFOL == "0477",nFol0477 := nAcum,)	//Saldo a Favor
				IIf((cAliasTmp)->RV_CODFOL == "1179",nFol1179 := nAcum,)	//Salario Infotep
				
				(cAliasTmp)->(DBSkip())
			EndDo //Fin de archivo 
			
			//nombrar los alias de los campos en variables para los valores principales
			FWrite(nArchivo, "D" + cNumIns + cTipoDoc + PADL(cDocto, 25) +;
			IIf(lCedula, PADR("", 50), cNombre) +;
			IIf(lCedula, PADR("", 40), cPrimAp) +; 
			IIf(lCedula, PADR("", 40), cSeguAp) +; 
			IIf(lCedula, PADR("", 1 ), cSex) +; 
			IIf(lCedula, PADR("", 8 ), cFecNac) +; 
			SubStr(StrZero((Val(Transform(nSalCoti, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nSalCoti, "9999999999999.99")) * 100), 15), 14, 15) +; // Salario Cotizable - RA_SALARIO
			SubStr(StrZero((Val(Transform(nFol1040, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nFol1040, "9999999999999.99")) * 100), 15), 14, 15) +; // Aporte voluntario - RV_CODFOL = 1040
			SubStr(StrZero((Val(Transform(nFol0015, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nFol0015, "9999999999999.99")) * 100), 15), 14, 15) +; // Salario ISR - RV_CODFOL = 0015
			SubStr(StrZero((Val(Transform(nFol0084, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nFol0084, "9999999999999.99")) * 100), 15), 14, 15) +; // Remuneraciones extras al ISR - RV_CODFOL = 0084
			PADR("", 11) +;
			SubStr(StrZero((Val(Transform(nFol1118, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nFol1118, "9999999999999.99")) * 100), 15), 14, 15) +; // Remuneraciones de otros empleadores - RV_CODFOL = 1118
			SubStr(StrZero((Val(Transform(nFol0544, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nFol0544, "9999999999999.99")) * 100), 15), 14, 15) +; // Ingresos exentos de ISR - RV_CODFOL = 0544
			SubStr(StrZero((Val(Transform(nFol0477, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nFol0477, "9999999999999.99")) * 100), 15), 14, 15) +; // Saldo a favor del periodo - RV_CODFOL = 0477
			SubStr(StrZero((Val(Transform(nFol1179, "9999999999999.99")) * 100), 15), 1 , 13) + "." +;
			SubStr(StrZero((Val(Transform(nFol1179, "9999999999999.99")) * 100), 15), 14, 15) +; // Salario cotizable INFOTEP - RV_CODFOL = 1179
			IIf(GPR002DI(cCIC,cPassP,cNumIns), '0004', cTipAdm) + cEOL)
			
		EndDo
		
		//Para cerrar el archivo creado
		If nloop > 0  
			//Registro sumario
			FWrite(nArchivo, "S" + StrZero(nloop, 6) + cEOL)
			fClose(nArchivo)  
			nMax := nloop 
		EndIf         
		
	EndIf
	(cAliasTmp)->(DBCloseArea())
	 	 	
Return aHistoric

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TodoOK   ³ Autor ³ Laura Medina          ³ Data ³ 06/07/11 ³±±
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
	Local cAno := ""
	
	Pergunte(cPerg, .F.)

	cSucI		:= MV_PAR01   //De Sucursal
	cSucF		:= MV_PAR02	//A Sucursal
	cProI		:= MV_PAR03   //De Proceso
	cProF		:= MV_PAR04   //A Proceso
	cMatI		:= MV_PAR05   //De Matricula
	cMatF		:= MV_PAR06   //A Matricula
	cPerAut		:= StrZero(MV_PAR07,6)   //Periodo de autodeterminacion
	cTipArch	:= MV_PAR08   //Tipo de autodeterminacion
	cArchivo	:= MV_PAR09   //Ubicacion del archivo de salida

	If Empty(cArchivo)
		MsgInfo(STR0007) //"Debe proporcionar la ruta y nombre del archivo!"
		lRet := .F.  
	ElseIf Empty(cPerAut)  
		MsgInfo(STR0010) //"Debe proporcionar la ruta y nombre del archivo!"
		lRet := .F. 
	Else
		cAno := SubStr(StrZero(MV_PAR07, 6), 3, 6)
		If Len(cAno) != 4
			MsgInfo(STR0012) //"Debe proporcionar un año valido"
			lRet := .F. 
		EndIf
	EndIf	  

Return lRet            

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPM01DOM01³ Autor ³ Laura Medina          ³ Data ³ 06/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que valida el mes del periodo de los parametros de ³±±  
±±³          ³ entrada.                                                   ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM01DOM01()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM01DOM01                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function GPM01DOM01() 

	Local cMes := SubStr(StrZero(MV_PAR07, 6), 1, 2)

	If  Val(cMes) < 1 .Or. Val(cMes) > 13
		MsgInfo(STR0011) //"Debe proporcionar un mes valido"
		Return .F.
	EndIf

Return (.T.)