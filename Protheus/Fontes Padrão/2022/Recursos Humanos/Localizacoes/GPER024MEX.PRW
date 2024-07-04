#INCLUDE "GPER024MEX.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "prtopdef.ch"    
#INCLUDE "totvs.ch"    
#INCLUDE "font.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER024MEX³ Autor ³ M.Camargo		       ³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Genera carátula de determinación de primas de Riesgo de    ³±±
±±³          ³ trabajo.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPE                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/


Function GPER024MEX()

	Local lVal := .F.
	Private cRegPat 	:= ""
	Private nYear	:= 0
	Private cCARIMS	:= GetMV("MV_CARIMS")
	
	
	IF Pergunte("GPER024MEX",.T.)		// Pantalla para configuración de parámetros
		
		Pergunte("GPER024MEX",.F.)
		
		nYear	:= MV_PAR01		// aÑO
		cRegPAt:= MV_PAR02		// Registro Patronal
		
		//Valida que los parámetros estén configurados.
		lVal := fValParams()
				
		If lVal 
			Processa({|| GP024MEXRUN()  },) 			
		EndIf
		
	EndIF

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GP024MEXRUN³ Autor³M.Camargo              ³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Generación de carátula en pdf                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP024MEXRUN()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER024MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GP024MEXRUN()
	
	Local aArea 		:= getArea()
	Local cRegs 		:= ""
	Local nCont		:= 0
	Local cExpAnio	:= alltrim(STR(nYear)) 
	Local cFilRIU		:= xfilial("RIU")
	Local cFilRCO		:= xfilial("RCO")
	Local cfileName	:= STR0008					//"CARATULA_"
	Local cTmpFile	:= ""
	Local cRegPRCO	:= ""
	Local nHoja		:= 0
	Local aFiles		:= {}
	Local cMensaje	:= ""
	Local nI			:= 0
	Local  cStartPath:= GetSrvProfString("Startpath","")
		
	Private oAr10R  	:= TFont():New("Arial",10,12,,.F.,,,,.T.,.F.)
	Private oAr20R  	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	Private oPrint 	:= Nil
	Private cAliasMov:= GetNextAlias()

	
	cRegs :="%(" + fRegPat(cRegPat) +") %"
	
	//Obtener los registros del RIU para los reg patronales elegidos y el año elegido.
	
	BeginSql alias cAliasMov
		SELECT RIU.*,RCO.*
		FROM %table:RIU% RIU INNER JOIN %table:RCO% RCO on RCO.RCO_CODIGO=RIU.RIU_CODRPA
		WHERE RIU.RIU_FILIAL=%exp:cFilRIU%
			AND RCO.RCO_FILIAL=%exp:cFilRCO%
			AND RIU.RIU_CODRPA IN %exp:cRegs%
			AND RIU.RIU_ANIO =%exp:cExpAnio%
			AND RCO.%notDel%	 
			AND RIU.%notDel%	  
	EndSql
	
	Count to nCont
	
	ProcRegua(nCont)
	(cAliasMov)->(dbGotop())
	While (cAliasMov)->(!EOF())
		nHoja++
		IncProc(STR0007)		//"Procesando..."
			
		cRegPRCO:=(cAliasMov)->RCO_NREPAT
		
		cTmpFile:= substr(cRegPRCO,1,10)
		oPrint:= FWMsPrinter():New(cFileName+ cTmpFile+".PDF",6,.T.,cCarIMS,.T.)
		oPrint:SetViewPDF(.F.)		
		oPrint:SetResolution(72)
		oPrint:SetLandscape()
		oPrint:SetPaperSize(1)
		oPrint:cPathPDF:= cCARIMS
		Imprime()
		oPrint:Print()   
		AADD(aFiles,cFileName+ cTmpFile+".PDF")      
		(cAliasMov)->(dbSkip())		
	EndDo		
	
	If !(nCont > 0)
		MsgAlert(STR0019 + CHR(10)+ CHR(13) + STR0020,STR0005) // "No existe información a procesar." "Archivos no generados." "Atención"
	Else
		cMensaje := STR0016 + CHR(10)+ CHR(13)
		cMensaje += STR0021 + cStartPath + cCARIMS + CHR(10)+ CHR(13)
		cMensaje += STR0018 + CHR(10)
		For nI := 1 to len(aFiles)
			cMensaje += aFiles[nI] + CHR(10)
		Next
		
		MsgInfo(cMensaje) //"Proceso terminado"
	EndIf	
	(cAliasMov)->(dbCloseArea())	
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRegPat   ³ Autor ³M.Camargo              ³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera cadena para procesar los registros patronales        ³±±
±±³          ³seleccionados en el parámeto mv_par02.                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRegPat(cRegPtr)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01:= Registros patronales MV_PAR02                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER024MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
// 
Static Function fRegPat(cRegPtr)
	Local cRet := ""
	Local cReg := ""
	Local nTam := TamSX3("RCO_CODIGO")[1]	
	Local nReg := 0
	
	For nReg:=1 to Len(cRegPtr)Step nTam
		cRet += "'"+Subs(cRegPat,nReg,nTam)+"'"
		If ( nReg+nTam ) <= Len(cRegPtr)
			cRet += "," 
		Endif
	Next nReg

Return cRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fValParams³ Autor ³M.Camargo              ³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida que los parámetros iniciales no esdtpen vaciós       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fValParams()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01:= Registros patronales MV_PAR02                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER024MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//
Static Function fValParams()
	Local lRet := .T.
	
	If Empty(nYear)
		// "Atención" "El parámetro año no debe estar vació." 
		Help( ,, OemToAnsi(STR0005),, OemToAnsi(STR0003) ,1, 0 )
		lRet := .F.
	EndIF
	
	If Empty(cRegPat)
		// "Atención" "El parámetro Registro Patronal no debe estar vació."
		Help( ,, OemToAnsi(STR0005),, OemToAnsi(STR0004) ,1, 0 )
		lRet := .F.
	EndIf
	
	If Empty(cCARIMS)
		// "Atención" "Configure parámetro MV_CARIMS."
		Help( ,, OemToAnsi(STR0005),, OemToAnsi(STR0006) ,1, 0 )
		lRet := .F.
	EndIf
	
	If !FILE(cCARIMS+"\CLEM-22.JPG")
		// "Atención" "Verifique que exista el archivo: " 
		Help( ,, OemToAnsi(STR0005),, OemToAnsi(STR0017) + cCARIMS+"\CLEM-22.JPG" ,1, 0 )
		lRet := .F.
	EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Imprime   ³ Autor ³M.Camargo              ³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime los datos del reporte hoja x hoja.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fValParams()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01:= Registros patronales MV_PAR02                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER024MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Imprime()
	
	Local cFondo 	:= cCARIMS+"\CLEM-22.JPG"
	Local nWith	:= oPrint:nPageWidth-400
	Local nHeight	:= oPrint:nPageHeight
	Local cMunic	:= ""
	Local nS		:= 0
	Local nI		:= 0
	Local nD		:= 0
	Local nF		:= 0
	Local nN		:= 0
	Local nM		:= 0
	Local nR		:= 0	
	Local cRPatr := ""
	Local cDV		:= ""
	Local cFecha := ""
	Local cDir	:= ""
	Local cRisk	:= ""
	Local lRisk	:= .F.
	Local cAux	:= ""
	
	oPrint:StartPage()												// Inicia nueva página	
	oPrint:SayBitMap(1,1,cFondo,nWith,nHeight)					//Formato emitido por el imss
	//Descripción del Municipio
	cMunic := POSICIONE("CC2",3,xfilial("CC2")+(cAliasMov)->RCO_MUNIC,"CC2_MUN")
	//Encabezado
	cFecha := strZero(DAY(ddatabase),2) + strZero(Month(dDatabase),2) + strZero(Year(ddatabase),4)	//Fecha
	cRPatr := Substr((cAliasMov)->RCO_NREPAT,1,10)															// Registro Patronal
	cDV		:= Substr((cAliasMov)->RCO_NREPAT,11)																// Dígito Verificador
	cDir 	:= alltrim((cAliasMov)->RCO_END)+" "+ ALLTRIM((cAliasMov)->RCO_NUMEXT) + STR0010 + " "+(cAliasMov)->RCO_BAIRRO	//Domicilio
	
	fPCad(cFecha,10,"",0,.T.,oPrint,0365,2300,oAr10R)							//Impresión de Fecha
	oPrint:Say(0255,nWith-200,STR0009								,oAr10R,,,,2)	//Número de página
	fPCad(cRPatr,10,"",0,.T.,oPrint,0855,0220,oAr10R)							//Registro Patronal
	oPrint:Say(0855,0650,cDV											,oAr10R,,,,2)	//Dígito Verificador
	oPrint:Say(0950,0225,(cAliasMov)->RCO_NOME					,oAr10R,,,,2)	//Razón Social
	oPrint:Say(1050,0225,(cAliasMov)->RCO_ATIVID					,oAr10R,,,,2)	//Actividad Económica
	oPrint:Say(0905,1650,cDir 										,oAr10R,,,,2)	//Domicilo
	oPrint:Say(0905,2500,STR0011 + (cAliasMov)->RCO_CEP			,oAr10R,,,,2)	//Código Postal
	oPrint:Say(0950,1340,STR0013 + UPPER(cMunic)					,oAr10R,,,,2)	//Municipio/Delegación
	oPrint:Say(0950,2300,STR0012 + 	(cAliasMov)->RCO_FONE		,oAr10R,,,,2) //Tel.	
	oPrint:Say(1050,1520,(cAliasMov)->RCO_TPRSC					,oAr10R,,,,2)	//clase de Riesgo
	oPrint:Say(1050,1900,(cAliasMov)->RCO_FRACAO					,oAr10R,,,,2)	//Fracción con número
	oPrint:Say(1050,2400,ALLTRIM(STR((cAliasMov)->RIU_PRIANT))	,oAr10R,,,,2)	//Prima Anterior
	oPrint:Say(1218,0850,(cAliasMov)->RIU_ANIO					,oAr10R,,,,2)	//Periodo
		
		
	// DATOS BASE PARA DETERMINAR LA PRIMA
	
	nS := (cAliasMov)->RIU_S		 	
	nD := (cAliasMov)->RIU_D		 	
	nI := (cAliasMov)->RIU_I		 	
	nN := (cAliasMov)->RIU_N		 	
	nF := (cAliasMov)->RIU_FACTOR	
	nM := (cAliasMov)->RIU_PRIMIN	

	fPCad(nS,6,"999999"	,0,.F.,oPrint,1370,0810,oAr10R)		// S
	fPCad(nI,7,"9999.99"	,2,.F.,oPrint,1500,0810,oAr10R)		// I
	fPCad(nD,5,"99999"	,0,.F.,oPrint,1605,0850,oAr10R)		// D
	fPCad(nN,7,"99999.9"	,1,.F.,oPrint,1720,0810,oAr10R)		// N
	fPCad(nF,3,"9.9"		,1,.F.,oPrint,1910,0970,oAr10R)		// F
	fPCad(nM,6,"9.9999"	,4,.F.,oPrint,1975,0850,oAr10R)		// M

	
	// RESULTADOS DE LA DETERMINACIÓN DE LA PRIMA
	
	oPrint:SayAlign(1265, 1295, TRANSFORM(nS,"999999")	,oAr20R,100,08, ,1 , 2 )// S
	oPrint:SayAlign(1265, 1570, TRANSFORM(nI,"9999.99")	,oAr20R,100,08, ,1 , 2 )// I	
	oPrint:SayAlign(1265, 1700, TRANSFORM(nD,"999999")	,oAr20R,100,08, ,1 , 2 )// D	
	oPrint:SayAlign(1265, 1890, TRANSFORM(nF,"9.9")		,oAr20R,100,08, ,1 , 2 )// F	
	oPrint:SayAlign(1265, 2000, TRANSFORM(nN,"9999.9")	,oAr20R,100,08, ,1 , 2 )// N		
	oPrint:SayAlign(1265, 2200, TRANSFORM(nM,"9.9999")	,oAr20R,100,08, ,1 , 2 )// M	
	
	//Sustitución de valores
	
	nS := nS/365
	nI := nI +nD
	nF := nF/nN
	nR := (nS +(28 * nI)) * nF + nM
	cR := nR * 100
	
	oPrint:SayAlign(1350, 1250, TRANSFORM(nS,"9999.999999")			,oAr20R,200,08, ,1 , 2 )// S
	oPrint:SayAlign(1350, 1570, TRANSFORM(nI,"9999.99")				,oAr20R,200,08, ,1 , 2 )// I + D	
	oPrint:SayAlign(1350, 1900, TRANSFORM(nF,"999999.999999")		,oAr20R,200,08, ,1 , 2 )// F / N		
	oPrint:SayAlign(1350, 2200, TRANSFORM(nM,"9.9999")				,oAr20R,100,08, ,1 , 2 )// M	
	oPrint:SayAlign(1350, 2250, TRANSFORM(nR,"99999.99999999")		,oAr20R,300,08, ,1 , 2 )// Resultado
	
	//Desarrollo
	oPrint:SayAlign(1475, 1080, TRANSFORM(nR			,"99999.99999999"),oAr20R,300,08, ,1 , 2 )	
	oPrint:SayAlign(1475, 1450, TRANSFORM((nR * 100)	,"99999.99999999"),oAr20R,500,08, ,1 , 2 )
	
	//cAux := Substr(alltrim(STR(cR)),1,at(".",alltrim(STR(cR)))-1)
	cR:= (cAliasMov)->RIU_PRINVA
	cAux := Substr(alltrim(STR(cR)),1,at(".",alltrim(STR(cR)))-1)
	
	IF len(cAux) > 2
		fPCad(cR,10,"9999.99999"	,5,.F.,oPrint,1540,2190,oAr20R)	
	else
		fPCad(cR,8,"99.99999"	,5,.F.,oPrint,1540,2275,oAr20R)	
	EndIf	
	
	
	// Pie de Reporte
	
	//Verificar si tiene casos de riesgo laboral en el año
	lRisk := fLabRis((cAliasMov)->RCO_CODIGO)
	cRisk := IIf(lRisk,STR0014,STR0015) 		// "SI" "NO"
	
	oPrint:Say(1590,2540,cRisk,oAr20R,,,,2)	
	oPrint:Say(1640,1480,cRisk,oAr20R,,,,2)
	
	oPrint:Say(1795,2265,TRANSFORM(nYear + 1, "9999"),oAr20R,,,,2)		// De año 
	oPrint:Say(1840,1310,TRANSFORM(nYear + 2, "9999"),oAr20R,,,,2)		// a año
	
	
	oPrint:EndPage() 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fPCad     ³ Autor ³M.Camargo              ³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime los datos del reporte hoja x hoja.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fPCad(nVal,nLen,cPic,nDec,lCad,oPrint,nY,nX,oFont)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp01 := Valor(C/N) a imprimir.                            ³±±
±±³          ³nExp02 := Tamaño del campo a imprimir.                      ³±±
±±³          ³cExp03 := Picture o formato                                 ³±±
±±³          ³nExp04 := Número de decimales                               ³±±    
±±³          ³lExp05 := Indica si es número o es una cadena               ³±±
±±³          ³oExp06 := Objeto de impresión                               ³±±
±±³          ³nExp07 := Línea en la que se imprimirá la cadena o valor.   ³±±
±±³          ³nExp08 := Columna en la que se comenzará a imprimir.        ³±±
±±³          ³oExp09 := Fuente en la que se imprimirá el valor.           ³±±      
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER024MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fPCad(nVal,nLen,cPic,nDec,lCad,oPrint,nY,nX,oFont)
	Local cRet 	:= ""
	Local cCadena	:= "" 
	Local nI := 0
	Local cCar
	Local nSalto:= 40
	Local nIni :=  nX
	
	Default lCad := .F.
	
	cCadena := IIF(lCad,nVal,Transform(strZero(nVal,nLen,nDec),cPic))

	For nI:= 1 to len(cCadena)
	 	cCar :=  Substr(cCadena,nI,1)
	 	If !(cCar $ ".") 
	 		oPrint:Say(nY,nIni,cCar,oFont,,,,2)	 	
	 		nIni+=nSalto
	 	EndIf
	Next nI
	
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fLabRis   ³ Autor ³M.Camargo              ³ Data ³11/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica si el Reg patronal tuvo incidencias en el año      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fLabRis(cRegistro)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01:= Registros patronales MV_PAR02                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER024MEX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fLabRis(cRegistro)
	
	Local lRet 		:= .F.
	Local aArea 		:= getArea()
	Local cAliasRit 	:= GetNextalias()
	Local cFilRIT		:= xFilial("RIT")
	Local cRegs		:= cRegistro 
	Local cExpAnio 	:= STR(nYear,4)
	Default cRegistro := ""
	
	BeginSql alias cAliasRIT
		SELECT COUNT(*) as NUMREGS
		FROM %table:RIT% RIT
		WHERE RIT.RIT_FILIAL=%exp:cFilRIT%
			AND RIT.RIT_CODRPA = %exp:cRegs%
			AND RIT.RIT_ANIO =%exp:cExpAnio% 
			AND RIT.%notDel%	  
	EndSql
	
	(cAliasRIT)->(dbGotop())
	While (cAliasRIT)->(!EOF())
		IF 	(cAliasRIT)->NUMREGS > 0
			lRet := .T.
		EndIf
		(cAliasRIT)->(dbSkip())
	EndDo
	(cAliasRIT)->(dbCloseArea())
	RestArea(aArea)
	
Return lRet