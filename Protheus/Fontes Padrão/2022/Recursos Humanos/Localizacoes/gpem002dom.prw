#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "GPEM002DOM.CH"

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEM002DOM� Autor � Laura Medina Prado             � Data � 13/07/11 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de Archivos de Bonificaci�n Infotep                      ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM002DOM()                                                        ���
����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                      ���
����������������������������������������������������������������������������������Ĵ��
���Programador � Data   �      FNC      �  Motivo da Alteracao                     ���
����������������������������������������������������������������������������������Ĵ��
���Laura Medina�01/09/11�               � Cambio en obtencion de informacion porque���
���            �        �               � no existiran reingresos.                 ���
���Christiane V�09/02/12�0000018876/2011� Corre��o para gera��o em ambiente DB2.   ���
���Mohanad Odeh�02/07/12�0000016831/2012� Corre��o na impress�o de valores no      ���
���            �        �         TFHCMU�cabe�alho e altera��o dos ID's de calculo ���
���            �        �               �Infotep Nomina e Infotep Utilidades       ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/

Function GPEM002DOM()

Local aSays	      := { }
Local aButtons    := { }
Local aGetArea	  := GetArea()
Local cPerg       := "GPM002DOM"                    
Local nOpca     

Private cCadastro := OemtoAnsi(STR0001)//"Archivo de Bonificacion"
//Variables de entrada (par�metros) 
Private cFilIni   := ""   //De Sucursal
Private cFilFin   := ""	  //A Sucursal
Private cProIni   := ""   //De Proceso
Private cProFin   := ""   //A Proceso
Private cMatIni   := ""   //De Matricula
Private cMatFin   := ""   //A Matricula
Private cPerAut   := ""   //Periodo de Bonificacion
Private cArchivo  := ""   //Ruta y nombre del archivo
Private cEOL    := CHR(13)+CHR(10)

Private lExisArc  := .F.
Private lError    := .f.

Private nMax:=0

dbSelectArea("SRA")  //Empleados
dbSelectArea("RG7")  //Historico de acumulados
dbSelectArea("SRV")  //Conceptos 
dbSelectArea("RCJ")  //Procesos
DbSetOrder(1)


AADD(aSays,OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos de Bonificacion Mensual"	

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If  nOpca == 1 //Ejecuta el proceso
	Processa({|| GPM796GERA() },OemToAnsi(STR0003))  //"Procesando..."
	If  lError
	    Msgalert(STR0004) //"Hubo problemas durante el proceso, y el archivo generado puede tener inconsistencias!!"
    Else	                      
		If  nMax==0             
			If  !lExisArc
		   		msgInfo(STR0005)//"Proceso Fianlizado! No encontro registros..."
		 	Endif
		Else
		   msgInfo(STR0006+cEOL+cArchivo)   //"Proceso Finalizado, Genero los archivos: "
		Endif
	ENDIF	
Endif

RestArea(aGetArea)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GPM796GERA� Autor � Laura Medina        � Data � 13/07/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Generacion de los archivos de Bonificacion Infotep.       ��� 
���           �                                                           ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � GPM796GERA()			                                  ��� 
�������������������������������������������������������������������������Ĵ��  
���Parametros �  Ninguno                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM797                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function GPM796GERA
Local aAcumula := {}


//Obtener los registros con los cuales se va a generar el archivo de Bonificacion
aAcumula := ObtHisAcum()

If  !Empty(aAcumula)  //Encontro registros para procesar
	GenArch(aAcumula)  //Rutina que genera el archivo de Bonificacion
Endif

Return                  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GPM796GERA� Autor � Laura Medina        � Data � 13/07/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Generacion de los archivos.                               ��� 
���           �                                                           ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � ObtHisAcum()  		                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros �  Ninguno                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM797                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtHisAcum()       
Local cAliasTmp := CriaTrab(Nil,.F.)	   
Local cSRAName  := InitSqlName("SRA")    
Local cRG7Name  := InitSqlName("RG7")
Local cSRVName  := InitSqlName("SRV") 
Local cQuery    := ""   
Local cMes      := Strzero(val(Substr(cPerAut,1,2)),2)
Local cAno      := Substr(cPerAut,3,6)    
Local cCriterio := '01'  
Local cCodFol   := "'1270','1271'"
Local cEmpleado := Space(TAMSX3("RA_FILIAL")[1]+TAMSX3("RA_MAT")[1])
Local nReg 		:= 0
Local aHistoric := {}

/*
ID de Calculo	Descripcion
1270			INFOTEP Nomina
1271			INFOTEP Utilidades
*/

cQuery := " SELECT RA_NUMINSC, RA_CIC, RA_NSEGURO, RA_PASSPOR, RA_PRINOME, "
cQuery += " RA_SECNOME, RA_PRISOBR,RA_SECSOBR, RA_SEXO, RA_NASC," 
cQuery += " RG7_ACUM" +cMes+" RA_ACUMXX" 
cQuery += " From "+cSRAName+" SRA, "+cRG7Name+ " RG7, "+cSRVName+ " SRV "
cQuery += " WHERE "
cQuery += "	RA_FILIAL BETWEEN '" + cFilIni+ "' AND '"+ cFilFin+ "' "  
cQuery += "	AND RA_MAT  BETWEEN '" + cMatIni+ "' AND '"+ cMatFin+ "' "
cQuery += "	AND RA_PROCES  BETWEEN '" + cProIni+ "' AND '"+ cProFin+ "' "
cQuery += "	AND RA_MAT = RG7_MAT AND  RA_PROCES = RG7_PROCES "       
                    
cQuery += " AND RA_FILIAL = RG7_FILIAL " 

cQuery += "	AND RG7_ANOINI = '"+ cAno+ "' " 
cQuery += "	AND RG7_CODCRI = '"+ cCriterio+ "' " 
cQuery += "	AND RG7_PD = RV_COD " 
cQuery += "	AND RV_CODFOL IN ("+cCodFol+") " 
cQuery += " AND SRA.D_E_L_E_T_=' '"   
cQuery += " AND SRV.D_E_L_E_T_=' '"   
cQuery += " AND RG7.D_E_L_E_T_=' '"   
cQuery += " GROUP BY RA_NUMINSC, RA_CIC, RA_NSEGURO, RA_PASSPOR, RA_PRINOME, "
cQuery += " RA_SECNOME, RA_PRISOBR,RA_SECSOBR, RA_SEXO, RA_NASC,RG7_ACUM" +cMes+ " "
cQuery += " ORDER BY RA_NUMINSC, RA_CIC, RA_NSEGURO, RA_PASSPOR "    
cQuery := ChangeQuery(cQuery)      
	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     

	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc()          
  
		If  cEmpleado != (cAliasTmp)->RA_CIC+(cAliasTmp)->RA_NSEGURO+(cAliasTmp)->RA_PASSPOR+(cAliasTmp)->RA_NUMINSC
			aAdd(aHistoric,{(cAliasTmp)->RA_NUMINSC,;   
					(cAliasTmp)->RA_CIC,; 
					(cAliasTmp)->RA_NSEGURO,;    
					(cAliasTmp)->RA_PASSPOR,;     
					(cAliasTmp)->RA_PRINOME,; 
					(cAliasTmp)->RA_SECNOME,; 
					(cAliasTmp)->RA_PRISOBR,; 
					(cAliasTmp)->RA_SECSOBR,; 
					(cAliasTmp)->RA_SEXO,; 
					SUBSTR((cAliasTmp)->RA_NASC,7,2) + SUBSTR((cAliasTmp)->RA_NASC,5,2) +SUBSTR((cAliasTmp)->RA_NASC,1,4),; 
					(cAliasTmp)->RA_ACUMXX,;
					})  
		Else  
	   		//Grabar ID de Calculo
			aHistoric[len(aHistoric),11]+= (cAliasTmp)->RA_ACUMXX   //Acumular 
		Endif

		cEmpleado := (cAliasTmp)->RA_CIC+(cAliasTmp)->RA_NSEGURO+(cAliasTmp)->RA_PASSPOR+(cAliasTmp)->RA_NUMINSC
	 	(cAliasTmp)->(dbSkip())
	Enddo
	(cAliasTmp)->( dbCloseArea()) 	
Return aHistoric


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GenArch  � Autor � Laura Medina          � Data � 13/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que va a generar los registros para el archivo TXT ���  
���          � dependiendo de los par�etros selecccionados.               ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GenArch(aExp1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  aExp1.-Registros que se colocaran en el archivo de salida ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM796GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function GenArch(aAcumula)
Local nloop   	:= 0   
Local lRet      := .T.
Local nArchivo  := 0 
Local cCedula   := ""
Local nIdx      := 1 //Solo va a existir un registro
Local cTipoDoc  := " "
Local cDocto    := ""
Local lCedula   := .F.
cArchivo  := Iif(At(".txt",cArchivo)>0,cArchivo,Alltrim(cArchivo)+'.txt')
lExisArc  := .F.
cCedula   := If( nIdx > 0, fTabela("S012",nIdx,5),"")


If  File(cArchivo)  //Si el archivo ya existe
	If  MsgYesNo(oemtoansi(STR0008+Alltrim(cArchivo)+STR0009))   //"El archivo "+XXX+" ya existe, �Desea eliminarlo?"
		FErase(cArchivo) 		
	Else 
		lRet     := .F.   
		lExisArc := .T.  
		fClose(nArchivo) 
	EndIf 
Endif     

If  lRet
	//Creacion de archivo
	nArchivo  := MSfCreate(cArchivo,0)
  
	ProcRegua(len(aAcumula))    
	
	For nloop:=1 to len(aAcumula) 
		IncProc()           
		lCedula   := .F.
		
		//Genere encabezado 
		If  nloop==1          
			FWrite(nArchivo,"E"+"BO"+PADR(cCedula,11)+cPerAut+cEOL)
		Endif         
		
		//Validar si es Cedula de identidad/No. Seg social/No. Pasaporte
		If !Empty(aAcumula[nloop,2])
			cDocto   := RTrim(aAcumula[nloop,2])
			cTipoDoc := 'C'  
			lCedula  := .T.
		Elseif  !Empty(aAcumula[nloop,3])
			cDocto:= RTrim(aAcumula[nloop,3])
			cTipoDoc := 'N'
		Elseif !Empty(aAcumula[nloop,4])
			cDocto:= RTrim(aAcumula[nloop,4])
			cTipoDoc := 'P'
		Endif

		FWrite(nArchivo,"D"+cTipoDoc+PADL(cDocto,25)+;
			   PADR(Alltrim(aAcumula[nloop,5])+" "+Alltrim(aAcumula[nloop,6]),50)+;
			   PADR(aAcumula[nloop,7],40)+;
			   PADR(aAcumula[nloop,8],40)+;
			   PADR(aAcumula[nloop,9],1)+;
			   PADR(aAcumula[nloop,10],8)+;
			   Substr(Strzero((val(transform(aAcumula[nloop,11],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,11],"9999999999999.99"))*100),15),14,15)+cEOL)			
    Next nloop
    
   	//Para cerrar el archivo creado
	If  Len(aAcumula)>0  
		//Registro sumario
		FWrite(nArchivo,"S"+strzero(len(aAcumula)+2,6)+cEOL)
		fClose(nArchivo)  
		nMax:=Len(aAcumula)   
	Endif         
Endif            

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TodoOK   � Autor � Laura Medina          � Data � 13/07/11 ���
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
�����������������������������������������������������������������������������*/ 
Static Function TodoOK(cPerg)
Local lRet := .T.             
Local cAno := ""  
Pergunte(cPerg,.F.)

cFilIni   := MV_PAR01   //De Sucursal
cFilFin   := MV_PAR02	//A Sucursal
cProIni   := MV_PAR03   //De Proceso
cProFin   := MV_PAR04   //A Proceso
cMatIni   := MV_PAR05   //De Matricula
cMatFin   := MV_PAR06   //A Matricula
cPerAut   := STRZERO(MV_PAR07,6)   //Periodo de Bonificacion
cArchivo  := MV_PAR08   //Ubicacion del archivo de salida

If  Empty(cArchivo)
	msginfo(STR0007)//"Debe proporcionar la ruta y nombre del archivo!"
	lRet := .F.  
Elseif Empty(cPerAut)  
	msginfo(STR0010)//"Debe proporcionar la ruta y nombre del archivo!"
	lRet := .F. 
Else 
	cAno := SUBSTR(STRZERO(MV_PAR07,6),3,6)
	IF len(cAno)!=4
		msginfo(STR0012)//"Debe proporcionar un a�o valido"
		lRet := .F. 
	Endif

Endif	  

Return lRet




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPM02DOM01� Autor � Laura Medina          � Data � 13/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que valida el mes del periodo de los parametros de ���  
���          � entrada.                                                   ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPM02DOM01()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM02DOM01                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Function GPM02DOM01() 
                                   
Local  cMes:=SUBSTR(STRZERO(MV_PAR07,6),1,2)
                
IF  val(cMes)<1 .or.val(cMes)>13
	msginfo(STR0011) //"Debe proporcionar un mes valido"
    Return .F.
ENDIF                  

Return (.T.)
