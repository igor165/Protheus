#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "GPEM830.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM830  � Autor � Guadalupe Santacruz A � Data � 03/05/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � GENERACION DE ARCHIVOS DE AVISOS IMSS                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM830()                                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �Se coloco formato a los salarios.         ���
���gsantacruz  �28/07/11� Corr �                                          ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �Se coloco formato a los salarios.         ���
���gsantacruz  �11/10/11� Mej  �Se agrego la funcion GPM830DIR y GPM830RET���
�������������������������������������������������������������������������Ĵ��
���gsantacruz  �11/10/11� Mej  �Se cambio el formato RCO_NUMGAV			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPEM830()

Local aSays		:={ }
Local aButtons	:= { }
Local aGetArea	:= GetArea()

Local cPerg		:="GPEM830"

Local nOpca

Private aCodRpat	:= {}  

Private cCadastro 	:= OemtoAnsi(STR0001)//"Archivos IDSE"
Private cAviAlt		:= "'01','03','06'" //Tipo de avisos de Altas o reingresos
Private cAviMod		:= "'05'" //Tipo de avisos de Modificacion de salarios
Private cAviBaj		:= "'02','04'" //Tipo de avisos de bajas
Private cTipAvi		:= ''    
Private cFilIni		:= ''
Private cFilFin		:= ''
Private cMatIni		:= ''
Private cMatFin		:= ''
Private cEnviados	:= ''
Private cLisPat		:= ''
Private cLisReg		:= ''
Private cArqTXT		:= ''
Private cEOL    	:= CHR(13)+CHR(10)
Private cArchivos	:= ''

Private dFecIni		:= Ctod("  /  /  ")
Private dFecFin		:= Ctod("  /  /  ")

Private lProblema	:= .f.

Private nMax		:= 0

dbSelectArea("SRA")  //Empleados
dbSelectArea("RCO")  //Registro patronal  
dbSelectArea("RCP")  //Trayectoria laboral
DbSetOrder(1)

AADD(aSays,OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos de Avisos para el IMSS, "de:  Altas /Reingresos/Modificaci�n de Salario y Bajas, "	
AADD(aSays,OemToAnsi(STR0003) ) //"de Empleados de un determinado periodo."		

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1 //Ejecuta el proceso
	Processa({|| GPM830GERA() },OemToAnsi(STR0004))  //"Procesando..."
	If lProblema
	    Msgalert(STR0008)//"Hubo problemas durante el proceso, y el archivo generado puede tener inconsistencias!!"
    Else	                      

		If nMax==0
		   msgInfo(STR0009)//"Proceso Fianlizado! No encontro registros..."
		Else
		   msgInfo(STR0010+cEOL+cArchivos)   //"Proceso Finalizado, Genero los archivos: "
		Endif
	EndIf	
EndIf

RestArea(aGetArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TodoOK    �Autor  �Microsiga           � Data �  03/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacion de los datos antes de Ejecutar el proceso        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TodoOK(cPerg)

	Local nCont		:= 0                                     
	Local nTamReg	:= TamSX3("RCO_CODIGO")[1]

	Pergunte(cPerg,.F.)
    cTipAvi		:= Alltrim(Str(MV_PAR01))
	cFilIni		:= MV_PAR02
	cFilFin		:= MV_PAR03
	cMatIni		:= MV_PAR04
	cMatFin		:= MV_PAR05
	dFecIni		:= MV_PAR06
	dFecFin		:= MV_PAR07
	cEnviados	:= Alltrim(str(MV_PAR08))
	cLisReg		:= Alltrim(MV_PAR09)
	cArqTXT		:= MV_PAR10

	If Empty(cLisReg)
		Msginfo(STR0014)//"Debe seleccionar al menos un registro patronal!"
		Return(.F.)
	EndIf

	/*
	//���������������������������������������������������������������Ŀ
	//�Genera lista de registros patronales para usar despues en Query�
	//�����������������������������������������������������������������
	*/
	cLisPat:=""
	For nCont := 1 To Len( cLisReg ) Step nTamReg
	    cLisPat+="'"+SubStr( cLisReg , nCont , nTamReg )+"',"
	Next
	cLisPat:=substr(cLisPat,1,len(cLisPat)-1)                                   

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPM830GERA� Autor � Gpe Santacruz         � Data �03/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de los archivos                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPM830GERA                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Ninguno                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM830                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Gpm830Gera()

Local aControl:={}

Local cQuery	:= ''
Local cAliasTmp	:= Criatrab(nil,.f.)

Local nx		:= 0
Local nNum		:= 0
Local nNUMGAV	:= 0

Private aArcsGen:= {}

Private nHdl  	:= 1

lProblema := .F.

/*
������������������������Ŀ
�Seleccion de Informaci�n�
��������������������������*/
cQuery := "SELECT RA_RG, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_CURP, RA_UMEDFAM,  RCO_NUMGAV, RCO_NREPAT,RCP_CODRPA, RCP_SALDII,RCP_SALIVC, "
cQuery += " RCP_FILIAL, RCP.R_E_C_N_O_ RCPRECNO,RCP_MAT, RCP_TEIMSS,RCP_TSIMSS,RCP_TJRNDA,RCP_DTMOV,RCP_CBIMSS "
cQuery += " FROM " + initsqlname("RCP") + " RCP, "+initsqlname("SRA")+" SRA , "+initsqlname("RCO")+" RCO WHERE "
cQuery += " RCP_FILIAL  BETWEEN '"+cFilIni+"' AND '"+cFilFin+"' "
cQuery += "AND RCP_MAT=RA_MAT AND RCP_CODRPA=RCO_CODIGO "
cQuery += "AND RCP_MAT  BETWEEN '"+cMatIni+"' AND '"+cMatFin+"' "
cQuery += "AND RCP_DTMOV  BETWEEN '"+DTOS(dFecini)+"' AND '"+DTOS(dFecFin)+"' "
cQuery += "AND RCP_CODRPA IN ("+CLISPAT+") "
cQuery += "AND  RCP_FILIAL = RA_FILIAL AND RCO_FILIAL= '"  + xFilial("RCO" , SRA->RA_FILIAL) +"' "
Do case
   Case cTipAvi == '1'//Altas 
		cQuery += " AND   RCP_TPMOV IN ("+cAviAlt+") "
   Case cTipAvi == '2' //Bajas
		cQuery += " AND   RCP_TPMOV IN ("+cAviBaj+") "
   Case cTipAvi =='3' //Modificaciones
		cQuery += " AND   RCP_TPMOV IN ("+cAviMod+") "
EndCase
If cEnviados == '1' //Enviados    
	cQuery += " AND   RCP_DTIMSS <>' ' AND  RCP_HRIMSS <> '  ' "
Else //por enviar                                              
	cQuery += " AND   RCP_DTIMSS = ' ' AND  RCP_HRIMSS = '  ' "
EndIf
cQuery += " AND RCP.D_E_L_E_T_ = ' ' AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY RCP_FILIAL,RCP_CODRPA,RCP_MAT"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp,"RCP_DTMOV","D")  
Count TO nMax               
ProcRegua(nMax) // N�mero de registros a procesar

/*
�����������������������������������������Ŀ
�Genera archivo por cada registro patronal�
�������������������������������������������*/
(cAliasTmp)->(dbgotop())
nMax := 0

While !(cAliasTmp)->(EOF())           
    
    nNum	:= 0
    nNUMGAV	:= 0
    
	cFilTmp	:= (cAliasTmp)->RCP_FILIAL
	cRegPat	:= (cAliasTmp)->RCP_CODRPA   
	
	CreaArc((cAliasTmp)->RCO_NREPAT) //Abre el nuevo archivo
	nTamLin := 168
	Do while !(cAliasTmp)->(EOF()) .and. cFilTmp+cRegPat==(cAliasTmp)->RCP_FILIAL+(cAliasTmp)->RCP_CODRPA
		nMax++;nNum++                                                                               
	    cLin    := Space(nTamLin)

  	    nNUMGAV:= (cAliasTmp)->RCO_NUMGAV
   		Do case
		   Case cTipAvi=='1'//Altas 
				ArcAltas(@cLin,cAliasTmp)
		   Case cTipAvi=='2' //Bajas
				ArcBajas(@cLin,cAliasTmp)
		   Case cTipAvi=='3' //Modificaciones
				ArcMods(@cLin,cAliasTmp)
		EndCase        

		cLin +=cEOL

	    //�������������������������������������������������������������������������������Ŀ
	    //� Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   �
	    //� linea montada.                                                                �
	    //���������������������������������������������������������������������������������
	    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	        If !MsgAlert(STR0005,STR0006)//10-"Ocurri� un error en la grabaci�n del archivo. �Contin�a?",11-"�Atenci�n!"
		        lProblema:= .t.
	            Exit
	        EndIf
	    EndIf
	    
	    If cEnviados=='2'
		     aadd(aControl,(cAliasTmp)->RCPRECNO)
		EndIf     
	    IncProc()	     
	    (cAliasTmp)->(dbSkip())
    Enddo

	Gpm830Cifra(nNum,nNUMGAV)

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert(STR0005,STR0006)//"Ocurri� un error en la grabaci�n del archivo. �Contin�a?","�Atenci�n!"
			lProblema:= .t.
			Exit
		Endif
    EndIf
    fClose(nHdl)
    
EndDo

(cAliasTmp)->(dbclosearea())

/*
����������������������������������������������������������Ŀ
�Actualiza RCP si la opcion fue de los pendiente por Enviar�
������������������������������������������������������������*/
ProcRegua(Len(aControl)) // N�mero de registros a procesar

For nx := 1 To Len(aControl)
    Incproc(STR0007)//"Actualizando Trayectoria Laboral"
    
    RCP->(dbgoto(aControl[nx]))
    If !RCP->(EOF())
        Reclock("RCP",.f.)
        RCP->RCP_DTIMSS:=DDATABASE
        RCP->RCP_HRIMSS:=TIME()
        RCP->(MSUNLOCK())
    EndIf
Next

/*
�������������������������������������������������������������������������Ŀ
�Envio de pantalla con la lista de todos los archivos generados (aArcsGen)�
���������������������������������������������������������������������������*/
cArchivos:=''
For nx:=1 to len(aArcsGen)          
	cArchivos+=alltrim(aArcsGen[nx])+cEOL
Next

Return                  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ArcAltas  � Autor � Gpe Santacruz         � Data �03/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formato de Archivo de Altas o Reingresos                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ArcAltas (cExp1,cExp2)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.- Linea a generar en el archivo                      ���
���          � cExp2.- Nombre del alias                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM830GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ArcAltas(cLin,cAliasTmp)	
	
/*
�������������������������������������������������������������������������������������������������������Ŀ
�Registro patronal	N(10)	1 a 10	substring(RCO_NREPAT,1,10)                              			�
�Digito verificador	N(1)	11	substring(RCO_NREPAT,11,1)                                  			�
�N�mero de seguridad social	N(10)	12 a 21	substring(RA_RG,1,10)                          				�
�D�gito verificador NSS	N(1)	22	substring(RA_RG,11,1)                                   			�
�Apellido paterno	C(27)	23 a 49	substring(RA_PRISOBR,1,27)                                  		�
�Apellido materno	C(27)	50 a 76	substring(RA_SECSOBR,1,27)                                    		�
�Nombre del asegurado	C(27)	77 a 103	substring((rtrim(RA_PRINOME)+" "+rtrim(RA_SECNOME)),1,27)	�
�Salario diario integrado	N(6)	104 a 109	RCP_SALDII                                           	�
�Salario INFONAVIT	N(6)	110 a 115	RCP_SALIVC                                                  	�
�Tipo de trabajador	N(1)	116	RCP_TEIMSS                                                       		�
�Tipo de salario	N(1)	117	RCP_TSIMSS                                                          	�
�Reducci�n / Tipo de pago	N(1)	118	RCP_TJRNDA                                                 		�
�Fecha de movimiento	N(8)	119 a 126	RCP_DTMOV                                               	�
�Unidad de Medicina Familiar	N(3)	127 a 129	RA_UMEDFAM                                        	�
�Filler	C(2)	130 a 131	SPACE(2)                                                               		�
�Tipo de movimiento	N(2)	132 a 133	"08"                                                       		�
�Gu�a	N(5)	134 a 138	RCO_NUMGAV                                                               	�
�Clave del trabajador	N(10)	139 a 148	RCP_MAT+SPACE(4)                                        	�
�Filler	C(1)	149	SPACE(1)                                                                     		�
�Clave �nica de Registro de Poblaci�n	C(18)	150 a 167	RA_CURP                                 	�
�Identificador de Formato	N(1)	168	"9"                                                        		�
���������������������������������������������������������������������������������������������������������*/ 
cLin := Stuff(cLin,01,10,substr((cAliasTmp)->RCO_NREPAT,1,10))
cLin := Stuff(cLin,11,1,substr((cAliasTmp)->RCO_NREPAT,11,1))
cLin := Stuff(cLin,12,10,substr((cAliasTmp)->RA_RG,1,10))
cLin := Stuff(cLin,22,1,substr((cAliasTmp)->RA_RG,11,1))
cLin := Stuff(cLin,23,27,substr((cAliasTmp)->RA_PRISOBR,1,27))
cLin := Stuff(cLin,50,27,substr((cAliasTmp)->RA_SECSOBR,1,27))
cLin := Stuff(cLin,77,27,padr(substr((alltrim(RA_PRINOME)+" "+alltrim(RA_SECNOME)),1,27),27))
   
cLin := Stuff(cLin,104,6,FormatSal((cAliasTmp)->RCP_SALDII))                                       
cLin := Stuff(cLin,110,6,FormatSal((cAliasTmp)->RCP_SALIVC))
cLin := Stuff(cLin,116,1,alltrim((cAliasTmp)->RCP_TEIMSS))
cLin := Stuff(cLin,117,1,alltrim((cAliasTmp)->RCP_TSIMSS))
cLin := Stuff(cLin,118,1,alltrim((cAliasTmp)->RCP_TJRNDA))
cLin := Stuff(cLin,119,8,ForFecha((cAliasTmp)->RCP_DTMOV))
cLin := Stuff(cLin,127,3,substr((cAliasTmp)->RA_UMEDFAM,1,3))
cLin := Stuff(cLin,130,2,space(2))
cLin := Stuff(cLin,132,2,"08")
cLin := Stuff(cLin,134,5,strzero((cAliasTmp)->RCO_NUMGAV,5))  
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR((cAliasTmp)->RCO_NUMGAV)),1,5))
cLin := Stuff(cLin,139,10,PADR((cAliasTmp)->RCP_MAT,10))                                  
cLin := Stuff(cLin,149,1,space(1))
cLin := Stuff(cLin,150,18,(cAliasTmp)->RA_CURP)
cLin := Stuff(cLin,168,1,"9")  

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ArcMods   � Autor � Gpe Santacruz         � Data �03/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formato de Archivo de Modificacion de Salario              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ArcMods(cExp1,cExp2)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.- Linea a generar en el archivo                      ���
���          � cExp2.- Nombre del alias                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM830GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ArcMods(cLin,cAliasTmp)	

/*
�������������������������������������������������������������������������������������������������������Ŀ
�Registro patronal	C(10)	1 a 10	substring(RCO_NREPAT,1,10)                                    		�
�D�gito verificador	N(1)	11	substring(RCO_NREPAT,11,1)                                        		�
�N�mero de seguridad social	N(10)	12 a 21	substring(RA_RG,1,10)                              	 		�
�D�gito verificador del NSS	N(1)	22	substring(RA_RG,11,1)                                     		�
�Apellido paterno	C(27)	23 a 49	substring(RA_PRISOBR,1,27)                                    		�
�Apellido materno	C(27)	50 a 76	substring(RA_SECSOBR,1,27)                                    		�
�Nombre del asegurado	C(27)	77 a 103	substring((rtrim(RA_PRINOME)+" "+rtrim(RA_SECNOME)),1,27)	�
�Salario diario integrado	N(6)	104 a 109	RCP_SALDII                                           	�
�Salario INFONAVIT	N(6)	110 a 115	RCP_SALIVC                                                  	�
�Tipo de trabajador	N(1)	116	RCP_TEIMSS                                                       		�
�Tipo de salario	N(1)	117	RCP_TSIMSS                                                          	�
�Reducci�n / Tipo de pago	N(1)	118	RCP_TJRNDA                                                 		�
�Fecha de movimiento	N(8)	119 a 126	RCP_DTMOV                                                 	�
�Filler	C(5)	127 a 131	SPACE(5)                                                               		�
�Tipo de movimiento	N(2)	132 a 133	"07"                                                       		�
�Gu�a	N(5)	134 a 138	RCO_NUMGAV                                                               	�
�Clave del trabajador	N(10)	139 a 148	RCP_MAT+SPACE(4)                                        	�
�Filler	C(1)	149	SPACE(1)                                                                     		�
�Clave �nica de Registro de Poblaci�n	C(18)	150 a 167	RA_CURP                                 	�
�Identificador de Formato	N(1)	168	"9"                                                        		�
���������������������������������������������������������������������������������������������������������*/
cLin := Stuff(cLin,01,10,substr((cAliasTmp)->RCO_NREPAT,1,10))
cLin := Stuff(cLin,11,1,substr((cAliasTmp)->RCO_NREPAT,11,1))
cLin := Stuff(cLin,12,10,substr((cAliasTmp)->RA_RG,1,10))
cLin := Stuff(cLin,22,1,substr((cAliasTmp)->RA_RG,11,1))
cLin := Stuff(cLin,23,27,substr((cAliasTmp)->RA_PRISOBR,1,27))
cLin := Stuff(cLin,50,27,substr((cAliasTmp)->RA_SECSOBR,1,27))
cLin := Stuff(cLin,77,27,padr(substr((alltrim(RA_PRINOME)+" "+alltrim(RA_SECNOME)),1,27),27))
cLin := Stuff(cLin,104,6,FormatSal((cAliasTmp)->RCP_SALDII))
cLin := Stuff(cLin,110,6,FormatSal((cAliasTmp)->RCP_SALIVC))
cLin := Stuff(cLin,116,1,alltrim((cAliasTmp)->RCP_TEIMSS))
cLin := Stuff(cLin,117,1,alltrim((cAliasTmp)->RCP_TSIMSS))
cLin := Stuff(cLin,118,1,alltrim((cAliasTmp)->RCP_TJRNDA))
cLin := Stuff(cLin,119,8,ForFecha((cAliasTmp)->RCP_DTMOV))
cLin := Stuff(cLin,127,3,substr((cAliasTmp)->RA_UMEDFAM,1,3))
cLin := Stuff(cLin,130,2,space(2))
cLin := Stuff(cLin,132,2,"07")                                     
cLin := Stuff(cLin,134,5,strzero((cAliasTmp)->RCO_NUMGAV,5))  
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR((cAliasTmp)->RCO_NUMGAV)),1,5))
cLin := Stuff(cLin,139,10,PADR((cAliasTmp)->RCP_MAT,10))
cLin := Stuff(cLin,149,1,space(1))
cLin := Stuff(cLin,150,18,(cAliasTmp)->RA_CURP)
cLin := Stuff(cLin,168,1,"9")

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ArcBajas  � Autor � Gpe Santacruz         � Data �03/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formato de Archivo de Bajas                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ArcBajas(cExp1,cExp2)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.- Linea a generar en el archivo                      ���
���          � cExp2.- Nombre del alias                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM830GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/       
Static Function ArcBajas(cLin,cAliasTmp)	

/*
�������������������������������������������������������������������������������������������������������Ŀ
�Registro patronal	C(10)	1 a 10	substring(RCO_NREPAT,1,10)                                    		�
�D�gito verificador	N(1)	11	substring(RCO_NREPAT,11,1)                                        		�
�N�mero de seguridad social	N(10)	12 a 21	substring(RA_RG,1,10)                               		�
�D�gito verificador NSS	N(1)	22	substring(RA_RG,11,1)                                         		�
�Apellido paterno	C(27)	23 a 49	substring(RA_PRISOBR,1,27)                                    		�
�Apellido materno	C(27)	50 a 76	substring(RA_SECSOBR,1,27)                                    		�
�Nombre del asegurado	C(27)	77 a 103	substring((rtrim(RA_PRINOME)+" "+rtrim(RA_SECNOME)),1,27)	�
�Filler	N(15)	104 a 118	Space(15)                                                             		�
�Fecha de movimiento	N(8)	119 a 126	RCP_DTMOV                                                 	�
�Filler	C(5)	127 a 131	SPACE(5)                                                               		�
�Tipo de movimiento	N(2)	132 a 133	"02"                                                       		�
�Gu�a	N(5)	134 a 138	RCO_NUMGAV                                                               	�
�Clave del trabajador	N(10)	139 a 148	RCP_MAT+SPACE(4)                                        	�
�Causa de baja	N(1)	149	RCP_CBIMSS                                                            		�
�Filler	C(1)	150 a 167	Space(18)                                                              		�
�Identificador de Formato	N(1)	168	"9"                                                        		�
���������������������������������������������������������������������������������������������������������*/
cLin := Stuff(cLin,01,10,substr((cAliasTmp)->RCO_NREPAT,1,10))
cLin := Stuff(cLin,11,1,substr((cAliasTmp)->RCO_NREPAT,11,1))
cLin := Stuff(cLin,12,10,substr((cAliasTmp)->RA_RG,1,10))
cLin := Stuff(cLin,22,1,substr((cAliasTmp)->RA_RG,11,1))
cLin := Stuff(cLin,23,27,substr((cAliasTmp)->RA_PRISOBR,1,27))
cLin := Stuff(cLin,50,27,substr((cAliasTmp)->RA_SECSOBR,1,27))
cLin := Stuff(cLin,77,27,padr(substr((alltrim(RA_PRINOME)+" "+alltrim(RA_SECNOME)),1,27),27))
cLin := Stuff(cLin,104,15,space(15))
cLin := Stuff(cLin,119,8,ForFecha((cAliasTmp)->RCP_DTMOV))
cLin := Stuff(cLin,127,5,space(5))
cLin := Stuff(cLin,132,2,"02")
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR((cAliasTmp)->RCO_NUMGAV)),1,5))
cLin := Stuff(cLin,134,5,strzero((cAliasTmp)->RCO_NUMGAV,5))  
cLin := Stuff(cLin,139,10,PADR((cAliasTmp)->RCP_MAT,10))
cLin := Stuff(cLin,149,1,SUBSTR(ALLTRIM((cAliasTmp)->RCP_CBIMSS),1,1))
cLin := Stuff(cLin,150,18,space(18))
cLin := Stuff(cLin,168,1,"9")

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPM830CIFRA � Autor � Gpe Santacruz       � Data �03/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cifras de Cosntrol                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPM830CIFRA(nExp1,nExp2)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nExp1.- Numero totol de registro contenido en el archivo   ���
���          � nExp2.- Guia del Patron                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM830GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/       
Static Function Gpm830Cifra(nNum,nNumGav)  
      
/*
�������������������������������������������������������������������������������������������������������������������Ŀ
�Asteriscos	C(13)	1 a 13	"*************"                                                                    		�
�Filler	C(43)	14 a 56	Space(43)                                                                             		�
�Total de reingresos	N(6)	57 a 62	N�mero  total de registro que contiene el archivo  (por registro patronal)	�
�Filler	C(71)	63 a 133	Space(71)                                                                            	�
�Gu�a	N(5)	134 a 138	RCO_NUMGAV                                                                             	�
�Filler	C(29)	139 a 167	Space(29)                                                                           	�
�Identificador de Formato	N(1)	168	"9"                                                                      	�
���������������������������������������������������������������������������������������������������������������������*/
cLin := Stuff(cLin,1,13,replicate("*",13))  
cLin := Stuff(cLin,14,43,space(43))  
cLin := Stuff(cLin,57,6,strzero(nNum,6))  
cLin := Stuff(cLin,63,71,space(71))   
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR(nNumGav)),1,5)   )
cLin := Stuff(cLin,134,5,strzero(nNUMGAV,5)   )
cLin := Stuff(cLin,139,29,space(29))  
cLin := Stuff(cLin,168,1,"9")  


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CreaArc   � Autor � Gpe Santacruz           Data �03/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Crea el archivo                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CreaArc(cExp1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.- Registro patronal                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM830GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/  
Static Function CreaArc(cNomPat)

Local cNomArc:=alltrim(cArqTxt)

Do Case
   Case cTipAvi=='1'//Altas
	     cNomArc    +="Reingresos_"+alltrim(cNomPat)+"_"+ForFecha(ddatabase)+"_"+substr(strtran(time(),":",""),1,4)//
   Case cTipAvi=='2'//Bajas
	     cNomArc    +="Bajas_"+alltrim(cNomPat)+"_"+ForFecha(ddatabase)+"_"+substr(strtran(time(),":",""),1,4)//
   Case cTipAvi=='3'//Modificacion
	    cNomArc    +="Modificacion_"+alltrim(cNomPat)+"_"+ForFecha(ddatabase)+"_"+substr(strtran(time(),":",""),1,4)//
EndCase

nHdl    := fCreate(cNomArc)
//If Empty(cEOL)
//    cEOL := CHR(13)+CHR(10)
//Else
//    cEOL := Trim(cEOL)
//    cEOL := &cEOL
//EndIf
If nHdl == -1
    MsgAlert(STR0011+alltrim(cArqTxt)+STR0012,STR0006)//20-"El archivo  "," no puede ser creado! .","Atenci�n!"
    Return
EndIf
aadd(aArcsGen,cNomArc)

Return        
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ForFecha  � Autor � Gpe Santacruz           Data �04/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formatea una Fecha a DDMMAAAA (string)                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ForFecha(dExp1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� dExp1.- Fecha a tranformar                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cExp1.-Fecha en formato DDMMAAAA                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM830GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/  
Static Function ForFecha(dFec)

cFec	:=	Dtoc(dFec)
cAnio	:=	Alltrim(str(year(dFec)))
cFec	:=	Substr(cFec,1,2)+substr(cFec,4,2)+cAnio

Return( cFec )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FormatSal � Autor � Gpe Santacruz           Data �28/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formatea los Salarios a 6 pisiciones                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FormatSal(nExp1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nExp1.- Salario a tranformar  9999.99999                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cExp1.-Salario formato 999999                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM830GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/  
static function FormatSal(nSalario)

Local cSalar:=transform(round(nSalario,2)  ,"9999.99")
Local cSaldia:=padl(alltrim(substr(csalar,1,4)),4,"0")+substr(csalar,6,2)

return cSaldia

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GPM830RPAT  � Autor �Gpe Santacruz A.     � Data � 05/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Genera el arreglo con los Registros Patronales  para la     ���
���          � consulta en la pregunta                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lExp1.- .t. Valido .f. No valido                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �x1_valid   pregunta GPEM830                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Gpm830RPat()

Local aBim := {}

Local cTitulo:=  STR0013 //"Registro Patronal"

Local lRet

Local MvPar
Local MvParDef:=""

Local nCampo	:= TamSx3("RCO_CODIGO")[1] //4

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

RCO->(DbSetOrder(1))
If RCO->(DbSeek(xFilial("RCO")))       
   Do While !RCO->(Eof())
       aAdd(aBim, RCO->RCO_CODIGO+" "+alltrim(RCO->RCO_NOME))
       MvParDef += RCO->RCO_CODIGO
	   RCO->(DbSkip())
   EndDo
EndIf


If f_Opcoes(@MvPar,cTitulo,aBim,MvParDef,,,.f.,nCampo)  // Chama funcao f_Opcoes
                                          
	&MvRet := StrTran(mvpar,"*","")	//regresa resultado eliminando todos los asteriscos

EndIf

Return  lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GPM830DIR   � Autor �Gpe Santacruz A.     � Data � 07/10/11 ���
���          �GPM830RET   �       �                     �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Consulta especial MEXDIR, permite selecciona el directorio  ���
���          � unicamente, sin obligar a colocar un archivo               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MEXDIR  -SXB                                                ���
��������������������������������������������������������������������������ٱ�            w
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/


Function GPM830DIR()

 Local aArea	   := GetArea()
 Local cTipo			 := ""
 Local cCpoVld  := ReadVar()

 &(cCpoVld) := cGetFile( cTipo , OemToAnsi("Selecione o Directorio"),,,.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)

 RestArea(aArea)
Return(.T.)

Function GPM830RET()
Return( &(ReadVar()) )