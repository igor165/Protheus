#INCLUDE "Protheus.ch"
#INCLUDE "FileIO.ch"
#INCLUDE "GPEM001DOM.CH"

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEM001DOM� Autor � Laura Medina Prado    �    Data    �   05/07/11  ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de Archivos de Autodeterminacion Mensual                 ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM001DOM()                                                        ���
����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                      ���
����������������������������������������������������������������������������������Ĵ��
���Programador � Data   �      FNC      �  Motivo da Alteracao                     ���
����������������������������������������������������������������������������������Ĵ��
���Laura Medina�31/08/11�               � Cambio para no considerar reingresos.    ���
���Christiane V�06/02/12�0000018871/2011� Corre��o do error log                    ���
���Christiane V�08/02/12�0000018871/2011� Corre��o para gera��o em ambiente DB2.   ���
���Mohanad Odeh�02/07/12�0000016814/2012� Corre��o na impress�o de valores no      ���
���            �        �         TFHBT9�cabe�alho e detalhe do arquivo.           ���
���  Marco A.  �22/09/16�     TW5457    � Replica V12.1.7 a partir del llamado     ���
���            �        �               � TVQMZC para Republica Dominicana.        ���
���  Marco A.  �27/10/16�    TWJZLB     � Se modifica la impresion de la columna   ���
���            �        �               � Salario Cotizable (RV_CODFOL = 0019) para���
���            �        �               � que se imprima en su lugar el valor del  ���
���            �        �               � RA_SALARIO por empleado. (DOM)           ���
���alf. Medrano�13/07/17�    MMI-6326   � Replica MMI-5977 Se sustituy� RA_SALARIO ���
���            �        �               �a RG7_RA_ACUMXX donde XX es el mes selecci���
���            �        �               � -onado en periodo cuando RV_CODFOL = 0019���
���alf. Medrano�04/08/17�    DMINA-4    �En func ObtHisAcum se quita query y se    ���
���            �        �               �utiliza Func GPR002DQ tambi�n se genera   ���
���            �        �               �cada l�nea del archivo de txt directamente���
���            �        �               �en el ciclo del query. Se elimina GenArch ���
���            �        �               �Se elimina la ObtAusen y se utiliza la    ���
���            �        �               �func GPR002DI                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function GPEM001DOM()

	Local aSays		:= { }
	Local aButtons	:= { }
	Local aGetArea	:= GetArea()
	Local cPerg		:= "GPM001DOM"                    
	Local nOpca		:= 0     

	Private cAliasTmp	:= CriaTrab(Nil,.F.)	  
	Private cCadastro	:= OemtoAnsi(STR0001)//"Archivo de Autodeterminacion"
	
	//Variables de entrada (par�metros) 
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
	
	//��������������������������������������Ŀ
	//�mv_par01 - �De Filial?                �
	//�mv_par02 - �A Filial?                 �
	//�mv_par03 - �De Proceso?               �
	//�mv_par04 - �A Proceso?                �
	//�mv_par05 - �De Matricula?             �
	//�mv_par06 - �A Matricula?              �
	//�mv_par07 - �Periodo Autodeterminacion?�
	//�mv_par08 - �Tipo Autodeterminacion?   �
	//�mv_par09 - �Archivo?                  �
	//����������������������������������������

	aAdd(aSays, OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos de Autodeterminaci�n Mensual"	

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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GPM796GERA� Autor � Laura Medina        � Data � 05/07/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Generacion de los archivos.                               ��� 
���           �                                                           ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � ObtHisAcum()  		                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros �  Ninguno                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM796                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		If MsgYesNo(OemToAnsi(STR0008 + Alltrim(cArchivo) + STR0009))   //"El archivo "+XXX+" ya existe, �Desea eliminarlo?"
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TodoOK   � Autor � Laura Medina          � Data � 06/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que valida los par�metros de entrada para la obten-���  
���          � ci�n de la informacion.                                    ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TodoOK(cExp1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.-Nombre de grupo de pregunta                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM796GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/ 
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
			MsgInfo(STR0012) //"Debe proporcionar un a�o valido"
			lRet := .F. 
		EndIf
	EndIf	  

Return lRet            

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPM01DOM01� Autor � Laura Medina          � Data � 06/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que valida el mes del periodo de los parametros de ���  
���          � entrada.                                                   ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPM01DOM01()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM01DOM01                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/ 
Function GPM01DOM01() 

	Local cMes := SubStr(StrZero(MV_PAR07, 6), 1, 2)

	If  Val(cMes) < 1 .Or. Val(cMes) > 13
		MsgInfo(STR0011) //"Debe proporcionar un mes valido"
		Return .F.
	EndIf

Return (.T.)