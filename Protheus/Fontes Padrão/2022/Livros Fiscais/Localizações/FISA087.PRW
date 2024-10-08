#INCLUDE "FISA087.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FISA087  � Autor �Mayra Camargo          � Data � 21/04/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generaci�n del archivo de Declaraciones Informativas de    ���
���          � operacioes con Terceros correspondients al 2014.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FISA087()                                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Alf. Medrano�17/05/18�DMINA-2612�En Fun SELMOVCE8 por cada sucursal se ���
���            �        �          �crea un query asignando UNION ALL para���
���            �        �          �el uso de Xfilial en tablas con dif.  ��� 
���            �        �          �permisos SA2 vs CE8 (Exclusivas vs Com��� 
���            �        �          �-partidas) En Fun TodoOk se agrega    ���
���            �        �          �Valid para Filial Null                ���
���Alf. Medrano�21/05/18�DMINA-3163�En fun SelMovCE8 se asigna Order by al���
���            �        �          �Final de query para Union ALL         ���
���Alf. Medrano�30/01/19�DMINA-5571�En fun vldCaract() no se considera la ���
���            �        �          �la letra �є para la validaci�n de la ���
���            �        �          �raz�n social de los proveedores.      ���
���LuisEnr�quez�14/03/19�DMINA-6191�Se modifican funs. SelMovCE8 y GenArch���
���            �        �          �para colocar en la posicion 13 el acu-���
���            �        �          �mulado del campo CE8_BASE8 y se agrega���
���            �        �          �el valor vac�o en la posicion 15 (MEX)���
���  Marco A.  �30/08/19�DMINA-7263�Se modifican la funcion SelMovCE8,    ���
���            �        �          �para acumular los valores de las bases���
���            �        �          �por RFC de Proveedores. (MEX)         ���
���  Marco A.  �11/09/19�DMINA-7474�Se modifican la funcion SelMovCE8,    ���
���            �        �          �para acumular los valores de las bases���
���            �        �          �por RFC de Proveedores Extranjeros.   ���
���            �        �          �Tambien se permite el caracter & en el���
���            �        �          �Nombre (A2_NOME).                     ���
���  Marco A.  �04/10/19�DMINA-7514�Se modifica la funcion SelMovCE8, para���
���            �        �          �acumular los valores de las bases en  ���
���            �        �          �base al Tipo Tercero en el proveedor. ���
���  Marco A.  �24/10/19�DMINA-7649�Se realizan multiples correcciones    ���
���            �        �          �para estabilizar el DIOT en ambientes ���
���            �        �          �con financiero compartido.            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FISA087()

	Local aGetArea	:= GetArea()
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cPerg		:= "FISA087"
	Local cCadastro	:= STR0001 	//"Generaci�n del archivo de DIOT"
	
	Private cMes		:= ""
	Private cAnio		:= ""
	Private cMesAno		:= ""
	Private cSucur		:= ""
	Private cArchivo	:= ""
	Private cRuta		:= ""
	Private dFecIni		:= CToD("  /  /  ")
	Private dFecFin		:= CToD("  /  /  ")
	Private aTmpMov		:= {}
	Private aErrores	:= {}
	Private nTotREg		:= 0
	
	aAdd(aSays,OemToAnsi(STR0002) ) // "Esta rutina genera el archivo de Declaraciones Informativas de Operaciones con "
	aAdd(aSays,OemToAnsi(STR0003) ) // "Terceros correspondientes al 2008, con la versi�n del DIOT completa 2008. "
	
	aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } }  )
	aAdd(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		
	FormBatch( cCadastro, aSays, aButtons )
	
	If nOpca == 1 
		Processa({|| FS087GERA() },OemToAnsi(STR0004)) //"Procesando..." 
	Endif
	
	RestArea(aGetArea)
	
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FS087GERA� Autor � Mayra Camargo         � Data � 21/04/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para generar el proceso para obtencion de registros���  
���          � y generacion del archivo.                                  ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FS087GERA()                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function FS087GERA()
	
	Local lRet := .T.  //(F=No se genero el archivo)
	
	nTotREg := 0
	
	IncProc(STR0005) // "Obteniendo informacion..."
	aTmpMov := SelMovCE8()
	
	If !Empty(aTmpMov)
		IncProc(STR0006) // "Generando archivo..."
		lRet := GenArch()
	Else 
	    MsgInfo(STR0007) // "No encontro registros para generar el archivo!"
	    lRet := .F.
	EndIf
	
	If lRet
		If Len(aErrores) > 0
			If MsgYesNo(STR0008) // "Errores encotrados, �Quiere verificar el LOG?"
				ImprimeLog()
			EndIf
		Else
			Aviso(STR0009, STR0010 + AllTrim(MV_PAR04) + AllTrim(MV_PAR03) + ".txt", {STR0011})    // "Atenci�n" "Proceso concluido con �xito, se genero el archivo en la siguiente ruta: " "OK"
			If MsgYesNo(STR0012) // "�Quiere verificar el LOG del Proceso?"
				ImprimeLog()
			EndIf
		EndIf 
	Else
		MsgInfo(STR0013)     // "No se genero el archivo, proceso concluido!"
	EndIf
	
Return                     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �SelMovCE8 � Autor � Mayra Camargo         � Data � 21/04/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para seleccionar los movimientos de la tabla CE8,  ���  
���          � acuerdo a los par�metros de entrada.                       ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � SelMovCE8()                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function SelMovCE8()       
	
	Local cAliasTmp		:= CriaTrab(Nil,.F.)
	Local cCE8Name		:= InitSqlName("CE8")
	Local cSA2Name		:= InitSqlName("SA2")
	Local cQuery		:= ""
	Local aMovimien		:= {}
	Local aFils			:= {}
	Local nTamFil		:= 0
	Local cXfils		:= ""
	Local nCont			:= 0
	Local aEncabeMov	:= {}
	Local aTotalMovs	:= {}
	Local lProvNac		:= .F.
	Local lProvExt		:= .F.
	
	If !Empty(cSucur)
		aFils := StrToKArr(cSucur, ',')
		nTamFil := len(aFils)
		For nCont := 1 to nTamFil
	
			If nCont > 1
				cQuery += " UNION ALL "
			Else
				cQuery := " " 
			EndIf
			
			cXfils = aFils[nCont] 
			
			cQuery += "SELECT CE8_TIPTER, CE8_TIPOPE, CE8_RFC, CE8_IDFISC, A2_NOME, CE8_PAIS,  CE8_PROV, CE8_TIENDA, "
			cQuery += "        SUM(CE8_BA1516) CE8_BA1516, SUM(CE8_BASE15) CE8_BASE15, SUM(CE8_BA1011) CE8_BA1011, SUM(CE8_BASE10) CE8_BASE10,"
			cQuery += "        SUM(CE8_BI1516) CE8_BI1516, SUM(CE8_BI1011) CE8_BI1011, SUM(CE8_BASIEX) CE8_BASIEX, SUM(CE8_BASE0) CE8_BASE0,"
			cQuery += "        SUM(CE8_BASEEX) CE8_BASEEX, SUM(CE8_IVARET) CE8_IVARET, SUM(CE8_IVADEV) CE8_IVADEV  " 
			If CE8->(ColumnPos("CE8_BASE8")) > 0
				cQuery += ", SUM(CE8_BASE8) CE8_BASE8 "
			EndIf
			cQuery += " FROM "  + cCE8Name + " CE8, " + cSA2Name + " SA2 "
			cQuery += " WHERE " 
			cQuery += " CE8_MESANO = '" + cMesAno+ "'"  
			cQuery += " AND CE8_FILIAL = " + cXfils + "  AND  A2_FILIAL = '" + xFilial("SA2" , STRTRAN( aFils[nCont], "'", "")) + "'"
			cQuery += " AND CE8_PROV = A2_COD " 
			cQuery += " AND CE8_TIENDA = A2_LOJA "                      
			cQuery += " AND CE8.D_E_L_E_T_= ' '"   
			cQuery += " AND SA2.D_E_L_E_T_= ' '"   
			cQuery += " GROUP BY CE8_TIPTER, CE8_RFC, CE8_TIPOPE, CE8_IDFISC, A2_NOME, CE8_PAIS, CE8_PROV, CE8_TIENDA"
			
			If nCont == nTamFil
				cQuery += " ORDER BY CE8_TIPTER, CE8_RFC, CE8_TIPOPE, CE8_IDFISC, A2_NOME, CE8_PAIS, CE8_PROV, CE8_TIENDA "
			EndIf
		Next
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	Count to nTotREg
	
	(cAliasTmp)->(DBGoTop())
	ProcRegua(nTotREg)

	While (cAliasTmp)->(!EOF())
		
		IncProc()
		
		aEncabeMov	:= {}
		aTotalMovs	:= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		lProvNac	:= .F.
		lProvExt	:= .F.
		
		If AllTrim((cAliasTmp)->CE8_TIPTER) == "04" .And. AllTrim((cAliasTmp)->CE8_PAIS) == "493" //Si el Proveedor es Nacional
			lProvNac := .T.
		ElseIf AllTrim((cAliasTmp)->CE8_TIPTER) == "05" .And. AllTrim((cAliasTmp)->CE8_PAIS) <> "493" //Si el Proveedor es Extranjero
			lProvExt := .T.
		EndIf
		
		aAdd(aEncabeMov, {(cAliasTmp)->CE8_TIPTER,;
						(cAliasTmp)->CE8_TIPOPE,;
						IIf(lProvNac .Or. lProvExt, AllTrim((cAliasTmp)->CE8_RFC), ""),;
						IIf(lProvExt, AllTrim((cAliasTmp)->CE8_IDFISC), ""),;
						IIf(lProvExt, AllTrim((cAliasTmp)->A2_NOME), ""),;
						IIf(lProvExt, AllTrim(Posicione("SYA", 1, xFilial("SYA") + (cAliasTmp)->CE8_PAIS, "YA_SGLMEX")), ""),;
						IIF(lProvExt, AllTrim(Posicione("SYA", 1, xFilial("SYA") + (cAliasTmp)->CE8_PAIS, "YA_NASCIO")), ""),;
						AllTrim((cAliasTmp)->CE8_PROV),;
						AllTrim((cAliasTmp)->CE8_TIENDA)})
		
		
		While (cAliasTmp)->(!EoF()) .And. IIf(lProvNac, AllTrim((cAliasTmp)->CE8_RFC) == AllTrim(aEncabeMov[1,3]), ; //Valida con RFC
											IIf(lProvExt, AllTrim((cAliasTmp)->CE8_IDFISC) == AllTrim(aEncabeMov[1,4]), ; //Valida con Identificador Fiscal
												AllTrim((cAliasTmp)->CE8_TIPTER) == AllTrim(aEncabeMov[1,1]))) //Valida Tipo Tercero igual a 15
			
			aTotalMovs[1] += (cAliasTmp)->CE8_BA1516
			aTotalMovs[2] += (cAliasTmp)->CE8_BASE15
			aTotalMovs[3] += (cAliasTmp)->CE8_BA1011
			aTotalMovs[4] += (cAliasTmp)->CE8_BASE10
			aTotalMovs[5] += (cAliasTmp)->CE8_BI1516
			aTotalMovs[6] += (cAliasTmp)->CE8_BI1011
			aTotalMovs[7] += (cAliasTmp)->CE8_BASIEX
			aTotalMovs[8] += (cAliasTmp)->CE8_BASE0
			aTotalMovs[9] += (cAliasTmp)->CE8_BASEEX
			aTotalMovs[10] += (cAliasTmp)->CE8_IVARET
			aTotalMovs[11] += (cAliasTmp)->CE8_IVADEV
			aTotalMovs[12] += IIf(CE8->(ColumnPos("CE8_BASE8")) > 0, (cAliasTmp)->CE8_BASE8, 0)
		 	      
			(cAliasTmp)->(DBSkip())
	 	EndDo
	 	
	 	//Estructura del array de movimientos
		          
		//+-------------------------+
		//| 1.- Tipo de tercero		|
		//| 2.- tipo Operacion		|
		//| 3.- RFC					|
		//| 4.- ID FISCAL PROV EXTR	|
		//| 5.- Nombre				| 
		//| 6.- Pais				|
		//| 7.- nacionalidad   		|
		//| 8.- Base 15/16 nac		|
		//| 9.- Base 15				|
		//|10.- base 10/11 nac		|
		//|11.- Base 10 			|
		//|12.- Base Imp 15/16		|
		//|13.- Base Imp 10/11		|
		//|14.- Base imp Exenta		|
		//|15.- Base 0				|
		//|16.- Base Exenta         |
		//|17.- Iva retenci�n		|
		//|18.- Iva devuelto		|
		//|19.- Documento		    |
		//|20.- Serie				|
		//|21.- Proveedor			|
		//|22.- Tienda				|
		//|23.- Base 8			    |
		//+-------------------------+ 
		
	 	aAdd(aMovimien, {aEncabeMov[1,1],;
	 					aEncabeMov[1,2],;
	 					aEncabeMov[1,3],;
	 					aEncabeMov[1,4],;
	 					aEncabeMov[1,5],;
	 					aEncabeMov[1,6],;
	 					aEncabeMov[1,7],;
	 					aTotalMovs[1],;
	 					aTotalMovs[2],;
	 					aTotalMovs[3],;
	 					aTotalMovs[4],;
	 					aTotalMovs[5],;
	 					aTotalMovs[6],;
	 					aTotalMovs[7],;
	 					aTotalMovs[8],;
	 					aTotalMovs[9],;
	 					aTotalMovs[10],;
	 					aTotalMovs[11],;
	 					'',;
	 					'',;
	 					aEncabeMov[1,8],;
	 					aEncabeMov[1,9],;
	 					aTotalMovs[12]})
	 	
	EndDo
	
	(cAliasTmp)->( dbCloseArea())
	
Return aMovimien

/*                  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GenArch  � Autor � Mayra Camargo         � Data � 25/04/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que va a generar los registros para el archivo de  ���  
���          � texto plano.                                               ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GenArch()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/   
Static Function GenArch()       

	Local nLoop		:= 0
	Local cArcDIOT	:= ""
	Local lRet		:= .T.
	Local nArchivo	:= 0
	Local nEnter	:= Chr(13) + Chr(10)
	
	cRuta := AllTrim(cRuta)
	
	cRuta := IIf(SubStr(cRuta, Len(cRuta), 1) == "\", cRuta, cRuta + "\")
	
	cArcDIOT  := cRuta + AllTrim(cArchivo) + ".txt"   //Nombre_archivo.txt
	
	If File(cArcDIOT)  //Si el archivo ya existe
	  	If MsgYesNo(OemToAnsi(STR0014 + Alltrim(cArcDIOT) + STR0015))   //"El archivo "+XXX+" ya existe, �Desea eliminarlo?"
			FErase(cArchivo)
		Else
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		nArchivo := MSfCreate(cArcDIOT,0)
		
		ProcRegua(Len(aTmpMov))
		
		For nLoop := 1 To Len(aTmpMov)
			
			IncProc()
			
			If Empty(aTmpMov[nLoop][2])
				aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0030})  // "      CE8_TIPOPE - Tipo de operaci�n vacio"
				Loop
			EndIf
			
			If Empty(aTmpMov[nLoop][3]) .and. aTmpMov[nLoop][1]=='04'
				aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0031})// "      A2_CGC - R.F.C. Vacio"
				Loop 
			EndIf
			
		    If !Empty(aTmpMov[nLoop][4])
				If !vldCaract(aTmpMov[nLoop][4], 1) 
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0032})//  "      CE8_IDFISC - Contiene caracteres no permitidos"
					Loop
				EndIf
			EndIf
			
			If !Empty(aTmpMov[nLoop][5])
				If !vldCaract(aTmpMov[nLoop][5], 2)
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0033})//"      A2_NOME - Contiene caracteres no permitidos"
					Loop
				EndIf
			Else
				IF !Empty(aTmpMov[nLoop][5]) .and.	aTmpMov[nLoop][1] == '05'
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0034 })// "      A2_NOME - Nombre extranjero obligatorio para tipo tercero 05"
					Loop
				EndIf
			EndIf
			
			If !Empty(aTmpMov[nLoop][7])
				If !vldCaract(aTmpMov[nLoop][7], 3)
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0035})// "      A2_NASCIO - Contiene caracteres no permitidos"
					Loop
				EndIf
			EndIf
			
			IF Empty(aTmpMov[nLoop][6]) .and. aTmpMov[nLoop][1]=='05'
				aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0036})// "      CE8_PAIS - Pais obliagtorio para tipo tercero 05"
				Loop
			EndIf
	
			IF Empty(aTmpMov[nLoop][7]) .and. !Empty(aTmpMov[nLoop][5]) .and. aTmpMov[nLoop][1]=='05'
				aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0039}) // "      YA_NASCIO - Nacionalidad obliagtoria Si hay nombre extranjero"
				Loop
			EndIf
			       
			cLinea := AllTrim(aTmpMov[nLoop][1]) + "|" //CE8_TIPTER
			cLinea += AllTrim(aTmpMov[nLoop][2]) + "|" //CE8_TIPOPE
			cLinea += AllTrim(aTmpMov[nLoop][3]) + "|" //CE8_RFC
			cLinea += AllTrim(aTmpMov[nLoop][4]) + "|" //CE8_IDFISC
			cLinea += AllTrim(aTmpMov[nLoop][5]) + "|" //A2_NOME
			cLinea += AllTrim(aTmpMov[nLoop][6]) + "|" //CE8_PAIS
			cLinea += AllTrim(aTmpMov[nLoop][7]) + "|" //A2_PAIS
			cLinea += IIf(aTmpMov[nLoop][8] > 0, AllTrim(Str(Round(aTmpMov[nLoop][8],0))), '') + "|" //CE8_BA1516
			cLinea += IIf(aTmpMov[nLoop][9] > 0, AllTrim(Str(Round(aTmpMov[nLoop][9],0))), '') + "|" //CE8_BASE15
			cLinea += ""+"|" //No-Aplica
			cLinea += IIf(aTmpMov[nLoop][10] > 0, AllTrim(Str(Round(aTmpMov[nLoop][10],0))), '') + "|" //CE8_BA1110
			cLinea += IIf(aTmpMov[nLoop][11] > 0, AllTrim(Str(Round(aTmpMov[nLoop][11],0))), '') + "|" //CE8_BASE10
			cLinea += IIf(aTmpMov[nLoop][23] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23],0))), '') + "|" //CE8_BASE8 
			cLinea += ""+"|" //No-Aplica
			cLinea += ""+"|" //No-Aplica (Opcional)
			cLinea += IIf(aTmpMov[nLoop][12] > 0, AllTrim(Str(Round(aTmpMov[nLoop][12],0))), '') + "|" //CE8_BI1516
			cLinea += ""+"|" //No-Aplica
			cLinea += IIf(aTmpMov[nLoop][13] > 0, AllTrim(Str(Round(aTmpMov[nLoop][13],0))), '') + "|" //CE8_BI1011
			cLinea += ""+"|" //No-Aplica
			cLinea += IIf(aTmpMov[nLoop][14] > 0, AllTrim(Str(Round(aTmpMov[nLoop][14],0))), '') + "|" //CE8_BASIEX
			cLinea += IIf(aTmpMov[nLoop][15] > 0, AllTrim(Str(Round(aTmpMov[nLoop][15],0))), '') + "|" //CE8_BASE0
			cLinea += IIf(aTmpMov[nLoop][16] > 0, AllTrim(Str(Round(aTmpMov[nLoop][16],0))), '') + "|" //CE8_BASEEX
			cLinea += IIf(aTmpMov[nLoop][17] > 0, AllTrim(Str(Round(aTmpMov[nLoop][17],0))), '') + "|" //CE8_IVARET
			cLinea += IIf(aTmpMov[nLoop][18] > 0, AllTrim(Str(Round(aTmpMov[nLoop][18],0))), '') + "|" //CE8_IVADEV	
			FWrite(nArchivo, cLinea + nEnter)
	    Next nLoop
	    
	   	//Para cerrar el archivo creado
		If Len(aTmpMov) > 0
			fClose(nArchivo)
		EndIf         
	EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TodoOK    �Autor  �M.Camargo           � Data �  21/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacion de los datos antes de Ejecutar el proceso        ���
�������������������������������������������������������������������������͹��
���Uso       �FISA087                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TodoOK(cPerg)
	
	Local nLoop := 0
	
	//����������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros         �
	//� MV_PAR01 // Mes y A�o del periodo a procesar �
	//� MV_PAR02 // Sucursales a procesar            �
	//� MV_PAR03 // Nombre del archivo               �
	//� MV_PAR04 // Ubicaci�n del archivo            �
	//������������������������������������������������
	Pergunte(cPerg, .F.)
	
	cMesAno := MV_PAR01
	cSucur  := MV_PAR02    
	cArchivo:= Alltrim(MV_PAR03)
	cRuta   := MV_PAR04
	
	cMes	:= StrZero(Val(Left(CMESANO,2)),2)
	cAnio	:= Right(CMESANO,4)
	cLisSuc	:= AllTrim(cSucur)
	   	
	If Val(cMes) < 1 .Or. Val(cMes) > 12
		MsgInfo(STR0016) // "El mes debe ser de 1 a 12!"
		Return .F.
	EndIf  
	
	If Empty(cMesAno)
		MsgInfo(STR0017) // "Debe indicar el Mes y A�o!"
		Return .F.
	EndIf		             
	
	If Val(cAnio) < 1900
		MsgInfo(STR0018) // "El a�o debe ser mayor a 1900!"
		Return .F.
	EndIf	             
	      
	If Empty(cArchivo) 
		MsgInfo(STR0019) // "Debe indicar nombre del archivo!"
		Return .F.
	EndIf    
	   
	For nLoop := 1 To Len(cArchivo)    
		If SubStr(cArchivo,nLoop,1) $"@/%/'/!/./$/&/�/?/�/�/,/ /" 
			MsgInfo(STR0020) // "El nombre del archivo contiene caracteres que no son validos!"
			Return .F.
		EndIf     
	Next nLoop
	
	If Empty(cRuta) 
		MsgInfo(STR0020) // "La Ruta esta vacia, verifique!"
		Return .F.
	EndIf
	
	If !ExistDir(cRuta)
		MsgInfo(STR0022) // "Atenci�n" "La Ruta seleccionada no existe" "OK"
		Return .F.
	EndIf  
	
	If !Empty(cLisSuc)
	    cSucur := FS088Traduce(cLisSuc)
	Else
	    MsgInfo(STR0038) // "Seleccione al menos una sucursal"
	    Return .F.
	EndIf       
	
	dFecIni := CToD("01/"+ cmes+ "/" +Substr(cAnio,3,2)+"/")
	dFecFin := CToD(StrZero(f_UltDia(dFecIni),02)+ "/"+cMes+"/"+substr(cAnio,3,2))

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldRuta   �Autor  �M.Camargo           � Data �  21/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacion del path seleccionado para el grabado del archivo���
�������������������������������������������������������������������������͹��
���Uso       �Generacion Archivo DIOT                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldRuta() 
	
	Local lRet := .T.
	 
	cPath := MV_PAR03
	
	If !ExistDir(cPath)
		Aviso(STR0009, STR0022, {STR0011}) // "Atenci�n" "La Ruta seleccionada no existe" "OK"
		lRet := .F.
	Endif     
                      
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �vldCaract �Autor  �M.Camargo           � Data �  21/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacion y tratamiento de caracteres especiales.          ���
�������������������������������������������������������������������������͹��
���Uso       �Generacion Archivo DIOT                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function vldCaract(cPalabra,nOpc) 
	
	Local nLoop   := 0
	Local lRet    := .T.
	Local cCaract := IIf(nOpc == 1, "@/%/'/!/./$/&/�/?/�/�", IIf(nOpc == 2, "@%'!$�?�", "'/&/�"))
	
	For nLoop := 1 To Len(cPalabra)
		If SubStr(cPalabra, nLoop, 1) $ cCaract
			lRet := .F.
			Exit
		Endif
	Next nLoop

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImprimeLog  � Autor �GSANTACRUZ          � Data � 21/04/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ejecuta rutina para Visualizar/Imprimir log del proceso.   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FISA087                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function ImprimeLog()

	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra��o"
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0028 // "LOG  de DIOT"
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:= {}
	Local aLog		:= {}
	
	aAdd(aLog, STR0023 + AllTrim(Str(Len(aTmpMov)))) 					//"Registros procesados: " 
	aAdd(aLog, STR0024 + AllTrim(Str(Len(aTmpMov) - Len(aErrores)))) 	//"Registros cargados: "
	aAdd(aLog, STR0025 + AllTrim(Str(Len(aErrores))))   				//"Registros con error: "
	aAdd(aLog, "")
	aAdd(aLog, "")
	aAdd(aLog, STR0026) // "Detalle de los registros con error:" 
	aAdd(aLog, "")
	aAdd(aLog, STR0040) // "Prov/Tienda  Observaci�n "
	
	For nX := 1 To Len(aErrores)                                            
	    aAdd(aLog,aErrores[nX,1])
	Next nX
	
	aNewLog	:= aClone(aLog)
	nTamLog	:= Len(aLog)
	
	aLog := {}
	
	If !Empty( aNewLog )
		aAdd(aLog, aClone(aNewLog))
	EndIf
	
	/*
	1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
	2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
	3 -	cPerg		//Pergunte a Ser Listado
	4 -	lShowLog	//Se Havera "Display" de Tela
	5 -	cLogName	//Nome Alternativo do Log
	6 -	cTitulo		//Titulo Alternativo do Log
	7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
	8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
	9 -	aRet		//Array com a Mesma Estrutura do aReturn
	10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0029) // "Generando Log de errores..."

Return 
