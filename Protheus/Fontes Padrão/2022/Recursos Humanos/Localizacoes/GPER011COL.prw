#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#Include "GPER011COL.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � GPER011COL  � Autor � Alfredo Medrano    � Data � 17/07/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir el Certificado de Pago de Intereses de Cesant�as  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GPER011COL()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
/*                                                                      
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcion    �GPER011COL�Autor  � Alfredo Medrano      � Fecha �17/07/13  ���
��������������������������������������������������������������������������Ĵ��
���Descripcion� Imprimir el Certificado de Pago de Intereses de Cesant�as  ���  
��������������������������������������������������������������������������Ĵ��
���Sintaxis   � GPER011COL()                                               ���
���           �                                                            ���  
��������������������������������������������������������������������������Ĵ��
���         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ���                
��������������������������������������������������������������������������Ĵ��
���Programador � Fecha  � BOPS �  Motivo de alteracion                     ���
��������������������������������������������������������������������������Ĵ��
���M.Camargo   �03/03/14�TIKRCN�Se modifica query para que considere       ���
���            �        �      �RA_SITFOLH vac�a.                          ���
���M.Camargo   �05/03/14�TIKRCN�Se modifica proceso para obtener cesantia e���
���            �        �      �intereses para generar 2 reportes en 1 hoja���
���Alex Hdez.  �23/02/16�PCREQ �Merge para 12.1.9. Se cambia GETNEXTAREA   ��� 
���            �        �-9393 �por GETNEXTALIAS, la otra no existe en RPO.���
���            �        �      �Se corrige para el qry de la SRD.          ���
���            �        �      �Se obtiene Lugar - Ciudad de SM0 para agre-���
���            �        �      �gar en informe.                            ���
���            �        �      �Se muestra Valor Auxilio de Cesant�a y     ���
���            �        �      ��Valor de los intereses de Cesantias en    ���
���            �        �      �en la misma impresi�n.                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/


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
	Local 	 nResImpr := 0 				// resultado de impresi�n
	Local 	 cRGC		:= RETORDEM("RGC","RGC_FILIAL+RGC_KEYLOC") // regresa el �ndice
	Local 	 cSRV		:= RETORDEM("SRV","RV_FILIAL+RV_COD") 		 // regresa el �ndice
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
	Private nTmpDIni  := 0 			// D�a Inicio
	Private nTmpMIni  := 0 			// Mes Inicio
	Private nTmpDiaF  := 0			// D�a Fin
	Private cTmpMesF  := ""			// Mes Fin
	Private nTmpAniF  := 0			// A�o Fin 
	Private nDiaCesa	:= 0			// Dias Cesant�a
	Private nValCesa	:= 0			// Valor Cesant�a
	Private nValInte	:= 0			// Valor interes
	Private cTmpTpcic := ""
	Private cTmpCic   :=""
	
   
	If pergunte("GPER011COL",.T.)
	
		//convierte parametros tipo Range a expresion sql
		//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
		MakeSqlExpr("GPER011COL")

		cSuc := trim(MV_PAR01) //�Sucursal ?
		cMat := trim(MV_PAR02) //�Matricula ?
		cCet := trim(MV_PAR03) //�Centro de Trabajo ?
		cPrc := trim(MV_PAR04) //�Proceso ?
		cPeriodo := MV_PAR05 		  //�Procedimiento ?
		cPdo := MV_PAR06 		  //�Periodo ?
		cNpa := MV_PAR07 		  //�N�mero de Pago ?
		cOrd := MV_PAR09 		  //�Orden ?    
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
		//si esta vac�a asigna un "*"
		if empty(cSit)
			cSit := "'*',"
		endif
		cSit := SubStr(cSit,1,len(cSit)-1) //�Situciones ?
					    
//���������������������������������������������Ŀ
//� Selecciona los datos de la tabla SRC y SRA �
//�����������������������������������������������		   

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
    	
//���������������������������������������������Ŀ
//�Si la consulta a la tabla SRC esta vac�a    �
//�Selecciona los datos de la tabla SRD y SRA  �
//�����������������������������������������������	  	
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
    	
//���������������������������������������������Ŀ
//� se inicializa el objeto FWMSPrinter 		  �
//� solo si hay registros para procesar		  �
//�����������������������������������������������
		If 	nTotalR > 0
			oPrinter      	 := FWMSPrinter():New('GPER011COL',6,.F.,,.T.,,,,,.F.) //inicializa el objeto
			oPrinter:Setup() 				    	//abre el objeto
			//oPrinter:setDevice( IMP_PDF )   		//selecciona el medio de impresi�n
			oPrinter:SetMargin(40,10,40,10) 	//margenes del documento
			oPrinter:SetPortrait()           	//orientaci�n de p�gina modo retrato =  Horizontal
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
				   			 nTmpDIni := DAY( dDiaIni ) 					  // D�a Inicio
				   			 nTmpMIni := MESEXTENSO( MONTH( dDiaIni ) )  // Mes Inicio
			   			 EndIf
			   			 	
			   			 //Obtiene Dia Inicio y el Mes Inicio
			   			 //Si la fecha de ingreso es mayor o igual a la fecha inicial del periodo
			   			 If (cAliasBus)->RA_ADMISSA  >= dDiaIni
			   			 	 nTmpDIni := DAY( (cAliasBus)->RA_ADMISSA  )   				 // D�a Inicio
				   			 nTmpMIni :=  MESEXTENSO( MONTH( (cAliasBus)->RA_ADMISSA  ) ) // Mes Inicio
			   			 EndIf
			   			 	
			   		EndIf 
			   			
			   		If (cAliasBus)->RA_SITFOLH != "D"
				   		nTmpDiaF   := DAY( dDiaFim ) 	 			  //D�a Fin
						cTmpMesF   := MESEXTENSO( MONTH( dDiaFim ) ) //Mes Fin
						nTmpAniF   := YEAR( dDiaFim )  				  //A�o Fin
			   		EndIf
			   			
			   		If (cAliasBus)->RA_SITFOLH == "D"
				   		nTmpDiaF   := DAY( (cAliasBus)->RA_DEMISSA )   				//D�a Fin
						cTmpMesF   := MESEXTENSO( MONTH( (cAliasBus)->RA_DEMISSA ) ) //Mes Fin
						nTmpAniF   := YEAR( (cAliasBus)->RA_DEMISSA )  				//A�o Fin
		   			EndIf
		   			
		    		(cAliasBus)-> (dbskip())
		    	EndDo
   			    	
			
				lImpre := .F.
				ImpPagCes(oPrinter)	
				lImpre := .T.		    		    		
	    		ImpPagCes(oPrinter)    //funci�n para impresi�n, se env�a el objeto inicializado
		    					  
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ObtFecPer � Autor � Alfredo Medrano     � Data � 18/07/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � �Obtiene la Fecha de pago, fecha inicio y final de periodos���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtFecPer()                                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���			   �		�      �            							 		    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
  	cQuery += " AND RCH_NUMPAG='"+ cNpaTmp +"' " 		//N�mero de Pago
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ImpPagCes � Autor � Alfredo Medrano      � Data � 19/07/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � �Imprime comprobante de pago de Cesant�as				    ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpPagCes()                                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���			   �		�      �            							  			 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
	Local cDme   	:= " d�as del mes de "
	Local cDe    	:= " de "
	Local cEnt   	:= "Se hace entrega al trabajador "
	Local cTpCic    := "Con tipo de Id "
	Local cCic      := " e Id "
	Local cTpCic2   := "Tipo Id "
	Local cDia   	:= "D�as laborados en el a�o "
	Local cPun   	:= ": "
	Local cEnd   	:= "Comprendidos entre el d�a "
	Local cHel   	:= " hasta el "
	Local cVac   	:= "Valor del Auxilio Cesant�a $ "    
	Local cDan   	:= " del a�o "
	Local cBlc   	:= " que se toma como base para liquidar los Intereses de las Cesant�as."
	Local cVaI   	:= "Valor de los Intereses de las Cesant�as causadas en el "
	Local cEnL   	:= " en letra  ($ "
	Local cPar   	:= " )"
	Local cRes   	:= "Recib� conforme los Intereses de las Cesant�as a los "
	Local cDmd   	:= " del mes de "	
	Local cCC    	:= " C.C. "
	Local cElt   	:= " (El trabajador) "	  

		oPrinter   := oPrintDoc
		cValInL	:= space(90)
		cLineas	:= space(50)							 
		oFontT 		:= TFont():New('Arial',,-15,.T.,.T.)//Fuente del Titulo
		oFontP 		:= TFont():New('Arial',,-12,.T.)     //Fuente del P�rrafo
				
		If lImpre == .F.
			oPrinter:StartPage() // se agrega una nueva p�gina a la impresi�n
			nEsp := 50   			// posici�n inicial del 1er formato de impresi�n
		Else
			nEsp := 430 			// posici�n inicial del 2do formato de impresi�n
		EndIf
				
			oPrinter:Say(nEsp,100,cTit,oFontT) // agrega el titulo
			//llena array que contendr� la posici�n vertical de las l�neas del formato de impresi�n
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
		oPrinter:EndPage() // Finaliza la p�gina
		EndIf	
							
return     
