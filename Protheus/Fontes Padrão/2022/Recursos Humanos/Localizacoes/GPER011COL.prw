#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#Include "GPER011COL.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³ GPER011COL  ³ Autor ³ Alfredo Medrano    ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir el Certificado de Pago de Intereses de Cesantías  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GPER011COL()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³GPER011COL³Autor  ³ Alfredo Medrano      ³ Fecha ³17/07/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Imprimir el Certificado de Pago de Intereses de Cesantías  ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ GPER011COL()                                               ³±±
±±³           ³                                                            ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo   ³03/03/14³TIKRCN³Se modifica query para que considere       ³±±
±±³            ³        ³      ³RA_SITFOLH vacía.                          ³±±
±±³M.Camargo   ³05/03/14³TIKRCN³Se modifica proceso para obtener cesantia e³±±
±±³            ³        ³      ³intereses para generar 2 reportes en 1 hoja³±±
±±³Alex Hdez.  ³23/02/16³PCREQ ³Merge para 12.1.9. Se cambia GETNEXTAREA   ³±± 
±±³            ³        ³-9393 ³por GETNEXTALIAS, la otra no existe en RPO.³±±
±±³            ³        ³      ³Se corrige para el qry de la SRD.          ³±±
±±³            ³        ³      ³Se obtiene Lugar - Ciudad de SM0 para agre-³±±
±±³            ³        ³      ³gar en informe.                            ³±±
±±³            ³        ³      ³Se muestra Valor Auxilio de Cesantía y     ³±±
±±³            ³        ³      ³“Valor de los intereses de Cesantias en    ³±±
±±³            ³        ³      ³en la misma impresión.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Function GPER011COL()
			
	Local   oPrinter
	Local   cAliasBus := criatrab( nil, .f. )
	Local   cQuery 	:= ""
	Local 	 aAreaLoc 	:= getArea()    
	Local	 cSuc   	:= ""   
	Local 	 cMat   	:= ""
	Local 	 cCet   	:= ""
	Local 	 cPrc   	:= ""
	Local 	 cPeriodo	:= ""
	Local 	 cPdo   	:= ""
	Local 	 cNPa   	:= ""
	Local 	 cSit   	:= ""
	Local 	 cOrd   	:= ""
	Local 	 cCaract  := ""
	Local 	 aDat 		:= {} 
	Local 	 nConta	:= 0
	Local	 nEntero	:= 0
	Local 	 nTotalR	:= 0
	Local 	 nTmpCod	:= 0
	Local 	 nResImpr := 0 				// resultado de impresión
	Local 	 cRGC		:= RETORDEM("RGC","RGC_FILIAL+RGC_KEYLOC") // regresa el índice
	Local 	 cSRV		:= RETORDEM("SRV","RV_FILIAL+RV_COD") 		 // regresa el índice
   	Local 	 cMsgNoRe := OemToAnsi(STR0021) // Sin registros para mostrar.
	Local 	 dDiaIni  := CTOD("  /  /  ") 
	Local 	 dDiaFim  := CTOD("  /  /  ")
	Local 	 cMatAnt	:=Space(TamSx3("RA_MAT")[1])
	Local  nI 		:= 1
	Local aInfo := {}
	Private dDiaPag   := CTOD("  /  /  ") 
   	Private lImpre		:= .F. 
   	Private cTmpNom  	:= "" 			// Nombre del Empleado
	Private cTmpLoc 	:= "" 			// Localidad de Pago
	Private nTmpDIni  := 0 			// Día Inicio
	Private nTmpMIni  := 0 			// Mes Inicio
	Private nTmpDiaF  := 0			// Día Fin
	Private cTmpMesF  := ""			// Mes Fin
	Private nTmpAniF  := 0			// Año Fin 
	Private nDiaCesa	:= 0			// Dias Cesantía
	Private nValCesa	:= 0			// Valor Cesantía
	Private nValInte	:= 0			// Valor interes
	Private cTmpTpcic := ""
	Private cTmpCic   :=""
	
   
	If pergunte("GPER011COL",.T.)
	
		//convierte parametros tipo Range a expresion sql
		//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
		MakeSqlExpr("GPER011COL")

		cSuc := trim(MV_PAR01) //¿Sucursal ?
		cMat := trim(MV_PAR02) //¿Matricula ?
		cCet := trim(MV_PAR03) //¿Centro de Trabajo ?
		cPrc := trim(MV_PAR04) //¿Proceso ?
		cPeriodo := MV_PAR05 		  //¿Procedimiento ?
		cPdo := MV_PAR06 		  //¿Periodo ?
		cNpa := MV_PAR07 		  //¿Número de Pago ?
		cOrd := MV_PAR09 		  //¿Orden ?    
		cSuc :=Substr(cSuc,2,len(cSuc)-2) 
		cMat :=Substr(cMat,2,len(cMat)-2)
		cCet :=Substr(cCet,2,len(cCet)-2)  
		
		//separa con comas los caracteres obtenidos de la cadena "situaciones"
		nConta	 := 1
		while nConta <= len(MV_PAR08)
		cCaract := SubStr(MV_PAR08,nConta,1)
			if cCaract != "*" //.And.  cCaract != " "
				cSit += "'"+ cCaract +"',"
			endif
			nConta++
		end	
		//si esta vacía asigna un "*"
		if empty(cSit)
			cSit := "'*',"
		endif
		cSit := SubStr(cSit,1,len(cSit)-1) //¿Situciones ?
					    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecciona los datos de la tabla SRC y SRA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		   

		cSQL := " SELECT RC_FILIAL FILIAL, RC_MAT, RC_PD, RC_HORAS, RC_VALOR, RA_NOME,  " 
		cSQL += " RA_KEYLOC, RA_ADMISSA, RA_SITFOLH, RA_DEMISSA, RA_TPCIC, RA_CIC "  
		cSQL += " FROM " + RetSqlName("SRC") + " SRC, " + RetSqlName("SRA") + " SRA "
		cSQL +=	 " WHERE RC_PROCES='" + cPrc + "' "
		cSQL +=	 " AND RC_ROTEIR='"+ cPeriodo +"' "
		cSQL +=	 " AND RC_PERIODO='"+ cPdo +"' "
		cSQL +=	 " AND RC_SEMANA='"+ cNpa +"' "
		If	!Empty( cSuc )
			cSQL += " AND " + cSuc 
		EndIf
		If	!Empty( cMat )
			cSQL +=	 " AND " + cMat 
		EndIf
    	cSQL += " AND RC_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL IN ('1027','1028')) "
    	cSQL += " AND RC_MAT=RA_MAT "
    	If	!Empty( cCet )
			cSQL +=	 " AND " + cCet
		EndIf  	
    	cSQL +=	 " AND RA_SITFOLH IN (" + cSit + ") "	
    	cSQL += " AND SRC.D_E_L_E_T_ = ' ' "
		cSQL += " AND SRA.D_E_L_E_T_ = ' ' "
    	If cOrd==1
    		cSQL += " ORDER BY RC_FILIAL,RC_MAT "
    		Else
    		cSQL += " ORDER BY RC_FILIAL,RA_KEYLOC,RC_MAT "
    	EndIf
    	cSQL := ChangeQuery(cSQL)
    	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasBus, .T., .F. )
    	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Si la consulta a la tabla SRC esta vacía    ³
//³Selecciona los datos de la tabla SRD y SRA  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  	
    	If (cAliasBus)->( Eof() )
    	
	      (cAliasBus)->( dbCloseArea())
			//restArea(aAreaLoc) 
    		cAliasBus := getNextAlias()

			cSQL := " SELECT RD_FILIAL FILIAL, RD_MAT AS RC_MAT, RD_PD as RC_PD, RD_HORAS AS RC_HORAS, RD_VALOR AS RC_VALOR, RA_NOME, " 
			cSQL += " RA_KEYLOC, RA_ADMISSA, RA_SITFOLH, RA_DEMISSA, RA_TPCIC, RA_CIC "  
			cSQL += " FROM " + RetSqlName("SRD") + " SRD, " + RetSqlName("SRA") + " SRA "
			cSQL +=	 " WHERE RD_PROCES='" + cPrc + "' "
			cSQL +=	 " AND RD_ROTEIR='"+ cPeriodo +"' "
			cSQL +=	 " AND RD_PERIODO='"+ cPdo +"' "
			cSQL +=	 " AND RD_SEMANA='"+ cNpa +"' "
			If	!Empty( cSuc )
					cSuc :=Substr(cSuc,10,len(cSuc))  
				cSQL += " AND RD_FILIAL " + cSuc  
			EndIf
			If	!Empty( cMat )
				cMat := Substr(cMat,8,len(cMat))
				cSQL +=	 " AND RD_MAT " + cMat 
			EndIf
	    	cSQL += " AND RD_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL IN ('1027','1028')) "
	    	cSQL += " AND RD_MAT=RA_MAT "
	    	If	!Empty( cCet )
	    		cCet :=Substr(cCet,10,len(cCet))
				cSQL +=	 " AND RA_KEYLOC " + cCet
			EndIf 	
	    	cSQL +=	 " AND RA_SITFOLH IN (" + cSit + ") "	
	    	cSQL += " AND SRD.D_E_L_E_T_ = ' ' "
			cSQL += " AND SRA.D_E_L_E_T_ = ' ' "
	    	If cOrd==1
	    			cSQL += " ORDER BY RD_FILIAL,RD_MAT "
	    		Else
	    			cSQL += " ORDER BY RD_FILIAL,RA_KEYLOC,RD_MAT "
	    	EndIf
	    	cSQL := ChangeQuery(cSQL)
	    	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasBus, .T., .F. )
	 
	    	If (cAliasBus)->( Eof() )   	 
    			MsgStop( cMsgNoRe ) // Sin registros para mostrar.
    		EndIf
		EndIf
		TCSetField(cAliasBus,"RA_ADMISSA","D",8,0) // Formato de fecha
    	TCSetField(cAliasBus,"RA_DEMISSA","D",8,0) // Formato de fecha
    	TCSetField(cAliasBus,"RA_DEMISSA","D",8,0) // Formato de fecha
    	Count to nTotalR  							 // obtiene el total de registros
    	dbGoTop()
    	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ se inicializa el objeto FWMSPrinter 		  ³
//³ solo si hay registros para procesar		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	nTotalR > 0
			oPrinter      	 := FWMSPrinter():New('GPER011COL',6,.F.,,.T.,,,,,.F.) //inicializa el objeto
			oPrinter:Setup() 				    	//abre el objeto
			//oPrinter:setDevice( IMP_PDF )   		//selecciona el medio de impresión
			oPrinter:SetMargin(40,10,40,10) 	//margenes del documento
			oPrinter:SetPortrait()           	//orientación de página modo retrato =  Horizontal
			nResImpr := oPrinter:nModalResult 	//obtiene nModalResult=1 confimada --- nModalResult=2 cancelada 
		EndIf
			
		If nResImpr == 1  
    	
		    While (cAliasBus)->(!Eof())
		    	nEntero++
		    	if NeNTERO = 1
		    		cMatant := ( cAliasBus )->RC_MAT
		    	eNDif
		    	While !(cMatAnt <> ( cAliasBus )->RC_MAT)		    	
		    		If !fInfo(@aInfo,( cAliasBus )->Filial)
						Exit
					Endif
		    		cMatant := ( cAliasBus )->RC_MAT
					cTmpNom  := ( cAliasBus )->RA_NOME // Obtiene el Nombre de Empleado
					cTmpTpcic := ( cAliasBus )->RA_TPCIC
					cTmpCic   := ( cAliasBus )->RA_CIC
			    	cTmpLoc  := PADR(aInfo[5]  ,30) //Retorna la Localidad de pago
			    	nTmpCod  := POSICIONE( "SRV", cSRV,XFILIAL("SRV") + ( cAliasBus )->RC_PD, "RV_CODFOL" ) //Retorna el valor RV_CODFOL 
			    	aDat	  := ObtFecPer( cPrc, cPeriodo, cPdo, cNpa, cSuc ) // Obtiene la fecha de pago, fecha de Inicio y final de periodos
		    		
		    		If nTmpCod == '1027'
				   		nValCesa += ( cAliasBus )->RC_VALOR
				   		nDiaCesa += ( cAliasBus )->RC_HORAS
			   		EndIf
			
			   		If nTmpCod == '1028'
			   			nValInte += ( cAliasBus )->RC_VALOR		   			
			   		EndIf
			   		
			   			
			   		If Len( aDat ) == 3
			   			 dDiaPag := aDat[1] // Fecha Pago
			   			 dDiaIni := aDat[2] // Fecha Inicio de periodos
			   			 dDiaFim := aDat[3] // Fecha Fin de periodos
			   			 	
						//Obtiene Dia Inicio y el Mes Inicio
			   			 //Si la fecha de ingreso es menor a la fecha inicial del periodo
			   			 If (cAliasBus)->RA_ADMISSA  < dDiaIni
				   			 nTmpDIni := DAY( dDiaIni ) 					  // Día Inicio
				   			 nTmpMIni := MESEXTENSO( MONTH( dDiaIni ) )  // Mes Inicio
			   			 EndIf
			   			 	
			   			 //Obtiene Dia Inicio y el Mes Inicio
			   			 //Si la fecha de ingreso es mayor o igual a la fecha inicial del periodo
			   			 If (cAliasBus)->RA_ADMISSA  >= dDiaIni
			   			 	 nTmpDIni := DAY( (cAliasBus)->RA_ADMISSA  )   				 // Día Inicio
				   			 nTmpMIni :=  MESEXTENSO( MONTH( (cAliasBus)->RA_ADMISSA  ) ) // Mes Inicio
			   			 EndIf
			   			 	
			   		EndIf 
			   			
			   		If (cAliasBus)->RA_SITFOLH != "D"
				   		nTmpDiaF   := DAY( dDiaFim ) 	 			  //Día Fin
						cTmpMesF   := MESEXTENSO( MONTH( dDiaFim ) ) //Mes Fin
						nTmpAniF   := YEAR( dDiaFim )  				  //Año Fin
			   		EndIf
			   			
			   		If (cAliasBus)->RA_SITFOLH == "D"
				   		nTmpDiaF   := DAY( (cAliasBus)->RA_DEMISSA )   				//Día Fin
						cTmpMesF   := MESEXTENSO( MONTH( (cAliasBus)->RA_DEMISSA ) ) //Mes Fin
						nTmpAniF   := YEAR( (cAliasBus)->RA_DEMISSA )  				//Año Fin
		   			EndIf
		   			
		    		(cAliasBus)-> (dbskip())
		    	EndDo
   			    	
			
				lImpre := .F.
				ImpPagCes(oPrinter)	
				lImpre := .T.		    		    		
	    		ImpPagCes(oPrinter)    //función para impresión, se envía el objeto inicializado
		    					  
			   	nValCesa := 0
			   	nDiaCesa := 0
			   	nValInte := 0
			   	cMatAnt := ( cAliasBus )->RC_MAT
			   		
	    	EndDo
	    	
	    Else
	    
	    	(cAliasBus)->( dbCloseArea())
			restArea(aAreaLoc) 
	    	return	
	
    	EndIf
		
    	(cAliasBus)->( dbCloseArea())
		restArea(aAreaLoc) 
		
		If 	nTotalR > 0 
			oPrinter:Preview()   // previsualiza el archivo PDF
		EndIf
	   		
	EndIf
		
return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ObtFecPer ³ Autor ³ Alfredo Medrano     ³ Data ³ 18/07/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ •Obtiene la Fecha de pago, fecha inicio y final de periodos³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtFecPer()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³		³      ³            							 		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtFecPer(cPrcTmp, cPeriodoTmp, cPdoTmp, cNpaTmp, cSucTmp) 
	Local	 aDatos	  := {}   
	Local 	 aArea	  := getArea()        
	Local	 cTmpPer := CriaTrab(Nil,.F.)
	Local   cQuery	  := ""    
	Default cPrcTmp := ""
	Default cPeriodoTmp := ""
	Default cPdoTmp := ""
	Default cNpaTmp := ""
	Default cSucTmp := ""
	
	cQuery := " SELECT RCH_DTPAGO,RCH_DTINI, RCH_DTFIM 
	CQuery += " FROM " + RetSqlName("RCH") +" RCH "
 	cQuery += " WHERE RCH_PROCES='"+ cPrcTmp +"' " 	//Proceso
    cQuery += " AND RCH_ROTEIR='"+ cPeriodoTmp +"' " 		//Procedimiento
    cQuery += " AND RCH_PER='"+ cPdoTmp +"' " 			//Periodo
  	cQuery += " AND RCH_NUMPAG='"+ cNpaTmp +"' " 		//Número de Pago
  	cQuery += " AND D_E_L_E_T_ = ' ' "

  	
  	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
 	TCSetField(cTmpPer,"RCH_DTPAGO","D",8,0) // Formato de fecha
    TCSetField(cTmpPer,"RCH_DTINI","D",8,0)  // Formato de fecha
    TCSetField(cTmpPer,"RCH_DTFIM","D",8,0)  // Formato de fecha
    
	(cTmpPer)->(dbgotop())//primer registro de tabla
	If  (cTmpPer)->(!EOF())
	
			AADD(aDatos,(cTmpPer)->RCH_DTPAGO )
			AADD(aDatos, (cTmpPer)->RCH_DTINI )   
			AADD(aDatos, (cTmpPer)->RCH_DTFIM )
		    (cTmpPer)-> (dbskip())
	Endif
	
	(cTmpPer)->( dbCloseArea())
	restArea(aArea) 
		
Return aDatos    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImpPagCes ³ Autor ³ Alfredo Medrano      ³ Data ³ 19/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ •Imprime comprobante de pago de Cesantías				    ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpPagCes()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³		³      ³            							  			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpPagCes(oPrintDoc)
			
	Local oPrinter
	Local oFontT			
	Local oFontP
	Local aLinea	:= {} 
	Local nSalto  	:= 0	
	Local nEsp  	:= 0	
	Local nX  		:= 0 
	Local cDiaPago	:= ""
	Local cAnioPag	:= "" 
	Local cMesPago	:= ""  
	Local cTDIni  	:= "" 			
	Local cTMIni  	:= "" 			
	Local cTDiaF  	:= ""			
	Local cTMesF  	:= ""			
	Local cTAniF  	:= ""
	Local cValInt	:= ""	
	Local cValCes	:= ""	
	Local cValInL	:= ""
	Local cDiasAn	:= "" 	
	Local cTit   	:= "COMPROBANTE DE PAGO DE INTERESES DE LAS CESANTIAS"
	Local cEnC   	:= "En la ciudad de "
	Local cAlo   	:= " a los "
	Local cDme   	:= " días del mes de "
	Local cDe    	:= " de "
	Local cEnt   	:= "Se hace entrega al trabajador "
	Local cTpCic    := "Con tipo de Id "
	Local cCic      := " e Id "
	Local cTpCic2   := "Tipo Id "
	Local cDia   	:= "Días laborados en el año "
	Local cPun   	:= ": "
	Local cEnd   	:= "Comprendidos entre el día "
	Local cHel   	:= " hasta el "
	Local cVac   	:= "Valor del Auxilio Cesantía $ "    
	Local cDan   	:= " del año "
	Local cBlc   	:= " que se toma como base para liquidar los Intereses de las Cesantías."
	Local cVaI   	:= "Valor de los Intereses de las Cesantías causadas en el "
	Local cEnL   	:= " en letra  ($ "
	Local cPar   	:= " )"
	Local cRes   	:= "Recibí conforme los Intereses de las Cesantías a los "
	Local cDmd   	:= " del mes de "	
	Local cCC    	:= " C.C. "
	Local cElt   	:= " (El trabajador) "	  

		oPrinter   := oPrintDoc
		cValInL	:= space(90)
		cLineas	:= space(50)							 
		oFontT 		:= TFont():New('Arial',,-15,.T.,.T.)//Fuente del Titulo
		oFontP 		:= TFont():New('Arial',,-12,.T.)     //Fuente del Párrafo
				
		If lImpre == .F.
			oPrinter:StartPage() // se agrega una nueva página a la impresión
			nEsp := 50   			// posición inicial del 1er formato de impresión
		Else
			nEsp := 430 			// posición inicial del 2do formato de impresión
		EndIf
				
			oPrinter:Say(nEsp,100,cTit,oFontT) // agrega el titulo
			//llena array que contendrá la posición vertical de las líneas del formato de impresión
			For nX=1 to 14 step 1
				nSalto := 20
				If nX==1 .Or. nX==11 .Or. nX==10
					nSalto := 40
				EndIf
				nEsp = nEsp + nSalto
				AADD(aLinea, nEsp)
			Next	
	
			cTmpNom  := alltrim( cTmpNom )
			cTmpTpcic := alltrim(cTmpTpcic)
			cTmpCic := alltrim(cTmpCic) 
			cTmpLoc  := alltrim( cTmpLoc )
			cDiaPago := alltrim( str( DAY(dDiaPag) ))
			cAnioPag := alltrim( str( YEAR(dDiaPag) ))
			cMesPago := alltrim( MESEXTENSO(MONTH(dDiaPag)))
			cTDIni	  := alltrim( str(nTmpDIni) )	
			cTMIni	  := alltrim( nTmpMIni )	 
			cTMesF	  := alltrim( cTmpMesF )
			cTDiaF	  := alltrim( str(nTmpDiaF) ) 	
			cTAniF	  := alltrim( str(nTmpAniF) )
			cDiasAn  := alltrim( str(nDiaCesa) )		
			cValInt  := alltrim( Transform(nValInte, "@E 99,999,999,999,999.99"))
			cValInL  := alltrim( Extenso(nValInte))
			cValCes  := alltrim( Transform(nValCesa, "@E 99,999,999,999,999.99"))
			cElt	  := alltrim( cElt )
			cCC		  := alltrim( cCC )
			
			oPrinter:Say(aLinea[1],  70, cEnC + cTmpLoc + cAlo +  cDiaPago + cDme + cMesPago + cDe + cAnioPag , oFontP)
			oPrinter:Say(aLinea[2],  70, cEnt  + cPun + cTmpNom , oFontP)
			oPrinter:Say(aLinea[3],  70, cTpCic + cTmpTpcic + cCic + cTmpCic , oFontP)
			oPrinter:Say(aLinea[4],  70, cDia + cAnioPag + cPun + cDiasAn , oFontP)
			oPrinter:Say(aLinea[5],  70, cEnd  + cTDIni + cDmd + cTMIni + "," + cHel + cTDiaF + cDmd , oFontP)
			oPrinter:Say(aLinea[6],  70, cTMesF + cDan + cTAniF + "." , oFontP)
			oPrinter:Say(aLinea[7],  70, cVac  + cValCes +  cDan + cTAniF + substr( cBlc, 0, 22 ) , oFontP)
			oPrinter:Say(aLinea[8],  70, substr( cBlc, 24, 45 )  , oFontP)
			oPrinter:Say(aLinea[9],  70, cVaI + cTAniF + cPun , oFontP)
			oPrinter:Say(aLinea[10],  70, cValInt + cEnL + cValInL + cPar, oFontP)
			oPrinter:Say(aLinea[11], 70, cRes + cDiaPago  + cDme + cMesPago + cDe + cAnioPag , oFontP)
			oPrinter:Say(aLinea[12], 70, replace(cLineas, " ", "_") + cElt, oFontP)
			oPrinter:Say(aLinea[13], 70, cCC + cTmpNom, oFontP) 
			oPrinter:Say(aLinea[14],  70, cTpCic2 + cTmpTpcic + cCic + cTmpCic , oFontP)
			
		If lImpre == .T.
		oPrinter:EndPage() // Finaliza la página
		EndIf	
							
return     
