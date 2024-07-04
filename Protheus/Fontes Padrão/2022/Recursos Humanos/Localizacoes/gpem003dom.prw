#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "GPEM003DOM.CH"

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEM003DOM� Autor � Laura Medina Prado             � Data � 19/07/11 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de Archivos de Dependientes adicionales                  ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM003DOM()                                                        ���
����������������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
����������������������������������������������������������������������������������Ĵ��
���Programador � Data   �      FNC      �  Motivo da Alteracao                     ���
����������������������������������������������������������������������������������Ĵ��
���Christiane V�06/02/12�0000018875/2011� Corre��o do error log                    ���
���            �        �               �                                          ���
���Mohanad Odeh�03/07/12�0000016848/2012� Corre��o na impress�o de valores no      ���
���            �        �         TFHCW3� cabe�alho e altera��o da query para      ���
���            �        �               � evitar que sejam impressos funcion�rios  ���
���            �        �               � demitidos e/ou transferidos              ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������L������������*/

Function GPEM003DOM()

Local aSays	      := { }
Local aButtons    := { }
Local aGetArea	  := GetArea()
Local cPerg       := "GPM003DOM"                    
Local nOpca     

Private cCadastro := OemtoAnsi(STR0001)//"Archivo de Dependientes"                                            

//Variables de entrada (par�metros) 
Private cFilIni   := ""   //De Sucursal
Private cFilFin   := ""	  //A Sucursal
Private cProIni   := ""   //De Proceso
Private cProFin   := ""   //A Proceso
Private cMatIni   := ""   //De Matricula
Private cMatFin   := ""   //A Matricula
Private cPerAut   := ""   //Periodo de Dependientes
Private cArchivo  := ""   //Ruta y nombre del archivo
Private cEOL    := CHR(13)+CHR(10)

Private lExisArc  := .F.
Private lError    := .f.

Private nMax:=0

dbSelectArea("SRA")  //Empleados
dbSelectArea("SRB")  //Dependientes
dbSelectArea("RCJ")  //Procesos
DbSetOrder(1)


AADD(aSays,OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos de Dependientes adicionales"	

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If  nOpca == 1 //Ejecuta el proceso
	Processa({|| GPM798GERA() },OemToAnsi(STR0003))  //"Procesando..."
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
���Funci�n    � GPM798GERA� Autor � Laura Medina        � Data � 19/07/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Generacion de los archivos de Dependientes adicionales.   ��� 
���           �                                                           ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � GPM798GERA()			                                  ��� 
�������������������������������������������������������������������������Ĵ��  
���Parametros �  Ninguno                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM798                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function GPM798GERA
Local aAcumula := {}


//Obtener los registros con los cuales se va a generar el archivo de Dependientes
aAcumula := ObtHisAcum()

If  !Empty(aAcumula)   //Encontro registros para procesar
	GenArch(aAcumula)  //Rutina que genera el archivo de Dependientes
Endif

Return                  
                       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GPM798GERA� Autor � Laura Medina        � Data � 20/07/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Obtenci�n de la informaci�n para generar los archivos.    ��� 
���           �                                                           ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � ObtHisAcum()  		                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros �  Ninguno                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPM798GERA                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtHisAcum()       
Local cAliasTmp := CriaTrab(Nil,.F.)	   
Local cSRAName  := InitSqlName("SRA")    
Local cSRBName  := InitSqlName("SRB")
Local cQuery    := ""  
Local cFechEnv  := DTOS(CTOD("//")) 
Local cDemissa  := DTOS(CTOD("//")) 
Local cHoje 	:= DTOS(Date())
Local aHistoric := {}
Local nReg 		:= 0               

cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NUMINSC, RA_CIC, RA_NSEGURO, RA_PASSPOR, RB_NOME, "
cQuery += " RB_SECNOME, RB_PRISOBR,RB_SECSOBR, RB_TPCIC, RB_CIC, SRB.R_E_C_N_O_ RB_RECNO "
cQuery += " FROM "+cSRAName+" SRA, "+cSRBName+ " SRB "
cQuery += " WHERE "
cQuery += "	RA_FILIAL BETWEEN '" + cFilIni+ "' AND '"+ cFilFin+ "' "  
cQuery += "	AND RA_MAT  BETWEEN '" + cMatIni+ "' AND '"+ cMatFin+ "' "
cQuery += "	AND RA_PROCES  BETWEEN '" + cProIni+ "' AND '"+ cProFin+ "' "
cQuery += "	AND RA_MAT = RB_MAT AND RA_FILIAL = RB_FILIAL "       
cQuery += " AND RB_FILIAL = '" +xFilial( "SRB", SRA->RA_FILIAL)+"' " 
cQuery += "	AND RB_DTENV  = '"+ cFechEnv+ "' "
cQuery += "	AND (RA_DEMISSA  = '"+ cDemissa+ "' " + " OR RA_DEMISSA > '" + cHoje + "') "
cQuery += " AND SRA.D_E_L_E_T_=' '"   
cQuery += " AND SRB.D_E_L_E_T_=' '"   
cQuery += " ORDER BY RA_FILIAL, RA_NUMINSC, RA_MAT "    
cQuery := ChangeQuery(cQuery)      
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc()          
	    
		aAdd(aHistoric,{(cAliasTmp)->RA_FILIAL,;
			(cAliasTmp)->RA_MAT,;
			(cAliasTmp)->RA_NUMINSC,;   
			(cAliasTmp)->RA_CIC,; 
			(cAliasTmp)->RA_NSEGURO,;    
			(cAliasTmp)->RA_PASSPOR,;     
			(cAliasTmp)->RB_NOME,; 
			(cAliasTmp)->RB_SECNOME,; 
			(cAliasTmp)->RB_PRISOBR,; 
			(cAliasTmp)->RB_SECSOBR,;  
			(cAliasTmp)->RB_TPCIC,;
			(cAliasTmp)->RB_CIC,; 
			(cAliasTmp)->RB_RECNO,; 
			})  
			 	      
	 	(cAliasTmp)->(dbSkip())
	Enddo
	(cAliasTmp)->( dbCloseArea()) 	
Return aHistoric



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GenArch  � Autor � Laura Medina          � Data � 20/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que va a generar los registros para el archivo TXT ���  
���          � dependiendo de los par�etros selecccionados.               ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GenArch(aExp1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  aExp1.-Registros que se colocaran en el archivo de salida ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM798GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function GenArch(aAcumula)       
Local nloop   	:= 0   
Local nArchivo  := 0 
Local nIdx      := 1 //Solo va a existir un registro 
Local lRet      := .T.
Local lCedula   := .F.
Local cCedula   := ""
Local cTipoDoc  := " "
Local cDocto    := ""    

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
			FWrite(nArchivo,"E"+"RD"+PADR(cCedula,11)+cEOL)
		Endif         
		
		//Validar si es Cedula de identidad/No. Seg social/No. Pasaporte                      
		If !Empty(aAcumula[nloop,4])
			cDocto   := aAcumula[nloop,4]
			cTipoDoc := 'C'  
			lCedula  := .T.
		Elseif  !Empty(aAcumula[nloop,5])
			cDocto:= aAcumula[nloop,5] 
			cTipoDoc := 'N'
		Elseif !Empty(aAcumula[nloop,6])
			cDocto:= aAcumula[nloop,6]    
			cTipoDoc := 'P'
		Endif

		FWrite(nArchivo,"D"+PADR(aAcumula[nloop,3],3)+cTipoDoc+PADL(cDocto,11)+;
			   PADR(Alltrim(aAcumula[nloop,7])+" "+Alltrim(aAcumula[nloop,8]),50)+;
			   PADR(aAcumula[nloop,9],40)+;
			   PADR(aAcumula[nloop,10],40)+;
			   Iif(aAcumula[nloop,11]=='1','C',IIF(aAcumula[nloop,11]=='2',"N","P"))+;
			   PADR(aAcumula[nloop,12],11)+cEOL)		
		
		//Actualizar la fecha de envio de los dependientes adicionales
		SRB->(DBGOTO(aAcumula[nloop,13])) 
		If  !SRB->(EOF()) 
			SRB->(RECLOCK("SRB",.F.))
			SRB->RB_DTENV := DDATABASE
			SRB->(MSUNLOCK() )  
		Endif
		
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
���Funcao    � TodoOK   � Autor � Laura Medina          � Data � 20/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que valida los par�metros de entrada para la obten-���  
���          � ci�n de la informacion.                                    ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TodoOK(cExp1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.-Nombre de grupo de pregunta                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM798GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function TodoOK(cPerg)

Local lRet := .T.     
        
Pergunte(cPerg,.F.)

cFilIni   := MV_PAR01   //De Sucursal
cFilFin   := MV_PAR02	//A Sucursal
cProIni   := MV_PAR03   //De Proceso
cProFin   := MV_PAR04   //A Proceso
cMatIni   := MV_PAR05   //De Matricula
cMatFin   := MV_PAR06   //A Matricula
cArchivo  := MV_PAR07   //Ubicacion del archivo de salida

If  Empty(cArchivo)
	msginfo(STR0007)//"Debe proporcionar la ruta y nombre del archivo!"
	lRet := .F.  
Endif	  

Return lRet