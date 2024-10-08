#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "GPEM006COS.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEM006COS� Autor � Flor Monroy                � Data � 21/07/11 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Generar Planilla RT                                             ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM006COS()                                                    ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ĵ��
���Programador � Data   �    FNC    �  Motivo da Alteracao                     ���
������������������������������������������������������������������������������Ĵ��
���Christiane V�14/12/11�024241/2011� Corre��o da gera��o do arquivo.          ���
���Christiane V�18/01/12�024241/2011� Corre��o da gera��o do arquivo.          ���
���Raquel Hager�12/02/12�012122/2012� Correcao na query na funcao GetRows.     ��� 
���Raquel Hager�25/02/12�012122/2012� Correcao na query na funcao getAbsence.  ���   
��|Emerson D.  �10/01/12�		    �Alteracao da chamada do alias VAM para    ���
��|            �        �			�CC2 p/ padronizacao da tabela de municipio���
���            �        �           �                                          ���
��|Emerson Camp�27/06/12�  REQ182/01�Corre��o na alteracao da chamada do alias ���
��|            �        �			�VAM para CC2 p/ padronizacao              ��� 
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Function GPEM006COS()

Local aSays			:=	{ }
Local aButtons		:=	{ }
Local aGetArea		:=	GetArea()

Local cPerg			:=	"GPM006COS"
Local cFileLog		:=	""
Local cPathlog		:=	""

Local nOpca			:=	0

Private cCadastro	:=	OemtoAnsi(STR0001)//"Planilla RT"
Private cSucursal	:=	""// Empresa (consulta est�ndar de empresas). En Costa Rica las sucursales pueden ser Razones Sociales o Sucursales.
Private cRegPat		:=	""// Registro Patronal (Consulta Est�ndar: RCO)
Private cEOL		:=	CHR(13)+CHR(10)
Private cAnio		:=	""// A�o de planilla a reportar: (con 4 d�gitos)
Private cMes		:=	""// Mes de planilla a reportar: (con 2 d�gitos)

Private cPath		:=	""//Ubicaci�n del archivo

Private nTipoPlan	:=	0// Tipo de Planilla: Mensual (M) / Adicional (A)
Private nMesA		:=	0
Private nMFile		:=	0// Marcar como enviado: 1=Si; 2=No
Private nMax		:=	0

Private lExisArc	:=	.F.
Private lError		:=	.F.

dbSelectArea("RCO")//Registros Patronales
dbSelectArea("RCC")//Tablas Alfanumericas
dbSelectArea("SRA")//Maestro de Empleados
dbSelectArea("RCP")//Trayectoria Laboral
dbSelectArea("SR8")//Ausentismos
dbSelectArea("RCM")//Tipos de Ausencias
dbSelectArea("RCJ")//Funciones

DbSetOrder(1)

AADD(aSays,OemToAnsi(STR0002) )//"Esta rutina genera la Planilla RT"

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If	nOpca == 1 //Ejecuta el proceso
	AutoGrLog(Replicate("-",40))
	AutoGrLog(STR0003)//"Iniciando Proceso"
	Processa({|| RUNPROC() }, STR0004,STR0005, .T.)//"Espere..."//"Ejecutando rutina."
	cFileLog := NomeAutoLog()
	If	nMax==0
		If	!lExisArc
			AutoGrLog(STR0006)//"ERROR: No encontro registros..."
			AutoGrLog(STR0007)//"Finalizando Proceso"
		Endif
	Else
		AutoGrLog(STR0008+cEOL+cPath)   //"Gnero los Archivos:"
   		AutoGrLog(STR0009)//"Finalizando Proceso"	
	Endif
	AutoGrLog(Replicate("-",40))
	If cFileLog <> ""
		MostraErro(cPathlog,cFileLog)
	Endif 
	
Endif
RestArea(aGetArea)
Return ( Nil )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � RUNPROC   � Autor � FMonroy             � Data � 16/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Detonar las funciones necesarias para generar el archivo. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � RUNPROC()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros �                                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM006COS                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function RUNPROC ()
Local	aRows	:=	{ }

aRows	:=	GetRows()
If !Empty(aRows)	//Encontro registros para procesar
	buildFile(aRows)	//Rutina que construye la plantilla RT
Endif

Return ( Nil )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GetRows   � Autor � FMonroy             � Data � 16/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Obtener los registros de la DB, seg�n la especificai�n.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � GetRows()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros �                                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM006COS                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GetRows()       
Local cAliasTmp :=	CriaTrab(Nil,.F.)	   
Local cSRAName  :=	InitSqlName("SRA")    
Local cRCPName  :=	InitSqlName("RCP")
Local cQuery    :=	"" 
Local cTpMov	:=	"'01','02','03','04','06'"
Local cCic := 	""
Local cFilRCP   := 	xFilial( "RCP", SRA->RA_FILIAL)
Local cDTMOV	:=	""
Local cMat		:=	""
Local CTJRNDA	:=	""
Local cJorn		:=  ""

Local NAUX01	:=	0
Local nDur		:=	30   
Local nReg 		:=	0   
Local nPos      :=	0
Local nAbsence	:=	0
Local nHoll		:=	0
Local nCnt		:=	0

Local aMvtos	:=	{ }
Local aTabFer   :=	{}

Local lIngreso	:=	.F.
Local lBaja		:=	.F.
Local lINS		:=	.F.
Local lCCSS		:=	.F.
Local lAus		:=	.F. 


cQuery := "	SELECT	SRA.RA_FILIAL,		SRA.RA_MAT,		SRA.RA_CIC,		SRA.RA_RG,	"
cQuery += "			SRA.RA_TJRNDA,		SRA.RA_CODFUNC,	SRA.RA_NOME,	SRA.RA_PRINOME,	"
cQuery += "			SRA.RA_SECNOME,		SRA.RA_PRISOBR,	SRA.RA_SECSOBR,	SRA.RA_SALARIO,"
cQuery += "			RCP.RCP_DTMOV,		RCP.RCP_TPMOV,	RCP.RCP_TJRNDA,	RCP.RCP_CODFUN"
cQuery += "	FROM	"+cSRAName+" SRA"
cQuery += "	INNER JOIN "+cRCPName+" RCP ON RCP.RCP_FILIAL='"+cFilRCP +"' AND RCP.RCP_MAT=SRA.RA_MAT	"
cQuery += "	WHERE	"
cQuery += "			SRA.RA_FILIAL = '"+ cSucursal +"'	"
cQuery += "			AND SRA.RA_SITFOLH  <> 'D'	"
cQuery += "			AND RCP.RCP_TPMOV IN ("+cTpMov+")	"  
cQuery += "			AND RCP.RCP_PERMOV = '"+ cAnio+cMes +"'	"
cQuery += "			AND RCP.D_E_L_E_T_=' '	"
cQuery += "			AND SRA.D_E_L_E_T_=' '	"
IIF(nTipoPlan==2,cQuery += "			AND RCP.RCP_DTMT =' '",)//Que el tipo de planilla sea Adicional
cQuery += "	ORDER BY SRA.RA_FILIAL, SRA.RA_CIC"
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc()          
		cCic := (cAliasTmp)->RA_CIC
		cMat:=(cAliasTmp)->RA_MAT
		If SUBSTR(ALLTRIM((cAliasTmp)->RA_CIC),1,1)=="0"
			AutoGrLog(STR0010)//"ERROR : El n�mero de identificaci�n del empleado no es una c�dula f�sica, favor de modificarla en el Maestro de Empleados"	    
		EndIf
		If Empty((cAliasTmp)->RA_RG)  
			AutoGrLog(STR0011)//"ERROR : No existe N� de Asegurado favor de registrala en el Maestro de Empleados"	    
		EndIf
		//Jornada                   
		cJorn := RCP->RCP_TJRNDA
		cJorn += Space(4 - Len(cJorn))
		NAUX01:=FPOSTAB("S021",cJorn,"=",4)
		CTJRNDA:="0"+IIF(NAUX01>0, FTABELA("S021",NAUX01,6), "1")

		aAdd(aMvtos,{(cAliasTmp)->RA_CIC,;
					(cAliasTmp)->RA_RG,;
					RTRIM((cAliasTmp)->RA_PRINOME)+SPACE(1)+RTRIM((cAliasTmp)->RA_SECNOME),;
					(cAliasTmp)->RA_PRISOBR,; 
					(cAliasTmp)->RA_SECSOBR,; 
					ROUND((cAliasTmp)->RA_SALARIO,0),;//(cAliasTmp)->RA_SALARIO,;
					0,;//Dias Laborados
					0,;//Horas Laboradas    
					CTJRNDA,; 
					"",; 
					POSICIONE("SRJ",1,XFILIAL("SRJ")+(cAliasTmp)->RCP_CODFUN,"RJ_CODMTSS"),;					
					}) 
		
								
		While (cAliasTmp)->(!EOF()).And. cCic == (cAliasTmp)->RA_CIC

			Do Case
				Case	(cAliasTmp)->RCP_TPMOV=='01' .OR. (cAliasTmp)->RCP_TPMOV=='03' .OR. (cAliasTmp)->RCP_TPMOV=='06' 
					lIngreso:=.T.
					cDtMov:=(cAliasTmp)->RCP_DTMOV
					
				Case 	(cAliasTmp)->RCP_TPMOV=='02'.OR. (cAliasTmp)->RCP_TPMOV=='04'
					lBaja:=.T.		
			EndCase
			
			(cAliasTmp)->(dbSkip())
		EndDo
		nAbsence:=getAbsence(CCIC,@lINS,@lCCSS,@lAus)//Obtiene ausncias
		If lIngreso
			nDur:=F_UltDia(CTOD("01/" + cMes + "/" + cAnio))-(VAL(SUBSTR(cDtMov,7,2))-1)
			If (nDur>30,nDur:=30,"")	
		EndIf	
		//Validas d�as festivos		
		nHoll:=0
		fRetTab( @aTabFer  , "S017", , , , , .T.)
		For nCnt:=1 to len(aTabFer) 
			If SUBSTR(dtos(aTabFer[nCnt,5]),1,6)==cAnio+cMes
				nHoll++
			EndIf
		Next
		aMvtos[len(aMvtos),7]:=nDur-nAbsence-nHoll
		aMvtos[len(aMvtos),10]:= getCondit(lIngreso, lBaja,lINS,lCCSS,lAus) //
	EndDo	

	(cAliasTmp)->( dbCloseArea()) 	
Return ( aMvtos )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � buildFile� Autor � FMonroy               � Data � 13/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que va a generar los registros para el archivo TXT ���
���          � dependiendo de los par�etros selecccionados.               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � buildFile(aExp1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  aExp1.-Registros que se colocaran en el archivo de salida ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM006COS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function buildFile(aRows)       
Local lRet			:=	.T.

Local nArchivo		:=	0 
Local nloop			:= 	0   
Local nIdx			:=	0   

Local cPolrt		:=	""
Local cFilOri		:=	SM0->M0_CODFIL
Local cDistrito		:=	""
Local cCanton		:=	""
Local cProvincia	:=	"" 
Local cTel			:=  ""
Local cFax			:=  ""

DBSELECTAREA("RCO")
cPolrt:=POSICIONE("RCO",/*DBSETORDER("RCO_FILIAL+RCO_CODIGO")*/1,XFILIAL("RCO")+cRegPat,'RCO_POLRT')
IF substr(cPath,len(alltrim(cPath)),1)=="\"
	cPath  := Alltrim(cPath)+upper('INS')+cPolrt+IIF(nTipoPlan==1,'M','A')+cAnio+cMes+'.txt'//
else
	cPath  := Alltrim(cPath)+"\"+upper('INS')+cPolrt+IIF(nTipoPlan==1,'M','A')+cAnio+cMes+'.txt'//
EndIf
lExisArc  := .F.

If  File(cPath)  //Si el archivo ya existe
	If  MsgYesNo(oemtoansi(STR0012+Alltrim(cPath)+STR0013))   //"El archivo "+XXX+" ya existe, �Desea eliminarlo?"
		FErase(cPath) 		
	Else 
		lRet     := .F.   
		lExisArc := .T.  
		fClose(cPath) 
		AutoGrLog(STR0014)//"ERROR: El Archivo ya existe!!"
	EndIf 
Endif     

If  lRet  
	//Creacion de archivo
	nArchivo  := MSfCreate(cPath,0)
  
	ProcRegua(len(aRows))    
	nloop:=1
	
	If Empty(cPolrt)  
		AutoGrLog(STR0015)//"ERROR : No existe N�mero de P�liza del patrono, capturarlo en Registros Pat"	    
	EndIf
	//���������������������������������������������������Ŀ
	//� Escribe Registro 1                                �
	//�����������������������������������������������������          
	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt+cSucursal,.T.))
	If Empty(SM0->M0_CGC)  
		AutoGrLog(STR0016)//"ERROR : No existe N�mero de Identificaci�n del patrono, favor de registrarla en el SIGAMAT"	    
	EndIf
	
	cTel := AllTrim(Replace(SM0->M0_TEL, "-",""))
	cFax := AllTrim(Replace(SM0->M0_FAX, "-",""))

	FWrite(nArchivo,Strzero(val( transform(cPolrt,"9999999")),7)+;
	                IIF(nTipoPlan==1,'M','A')+;
					cAnio+cMes+Space(1)+;
					padl(alltrim(SM0->M0_CGC),15," ")+;
				    Strzero(val(transform(cTel,"99999999")),8)+;
					Strzero(val(transform(cFax,"99999999")),8)+;
					cEOL)
					
	//���������������������������������������������������Ŀ
	//� Escribe Registro 2                                �
	//�����������������������������������������������������          
	If Empty(SM0->M0_ENDENT).Or. Empty(SM0->M0_COMPENT).Or. Empty(SM0->M0_BAIRENT) .Or. Empty(SM0->M0_CIDENT).Or. Empty(SM0->M0_ESTENT)
		AutoGrLog(STR0017)//"ERROR : No existe direcci�n del patrono, favor de registrarla en el SIGAMAT"	  
	EndIf  
	
	//Clave de Distrito
	If len(alltrim(SM0->M0_BAIRENT)) >8 
		cDistrito:=PADR(SUBSTR(SM0->M0_BAIRENT,1,40),40)
	Else
		cDistrito:=POSICIONE("CC2",3,xFilial("CC2")+SM0->M0_BAIRENT,"CC2_MUN")			
	EndIf
	cDistrito := AllTrim(cDistrito) + " " 
	
	//Clave de Canton
	//If len(alltrim(SM0->M0_CIDENT)) >5 
		cCanton:=PADR(SUBSTR(SM0->M0_CIDENT,1,40),40)
	/*Else
		nIdx:=FPOSTAB("S013",SM0->M0_CIDENT,"=",4)
		cCanton:=PADR(SUBSTR(If( nIdx > 0, fTabela("S013",nIdx,5),""),1,40),40)
	EndIf */     
	cCanton := AllTrim(cCanton) + " "
	
	//Clave de Provincia
	/*If len(alltrim(SM0->M0_ESTENT)) >0 .AND. len(alltrim(SM0->M0_ESTENT)) <8 
	   	SX5->(DBSETORDER(1))
		SX5->(DBSEEK(XFILIAL("SX5")+"12"+SM0->M0_ESTENT))	
		cProvincia:=PADR(SUBSTR(X5DESCRI(),1,22),22)
	Else*/
		cProvincia:=PADR(SUBSTR(SM0->M0_ESTENT,1,22),22)
	//EndIf                            
	cProvincia := AllTrim(cProvincia) + " " 
	
	FWrite(nArchivo,padr(substr(AllTrim(SUBSTR(SM0->M0_ENDENT,1,100)) + " " +;
	                AllTrim(SUBSTR(SM0->M0_COMPENT,1,30)) + " "+;
					cDistrito+;
					cCanton+;
					cProvincia,1,200),200)+;
					cEOL)
	//������������������������������������������Ŀ
	//�Escribe Registro 3. Linea Vacia           �
	//��������������������������������������������				
		FWrite(nArchivo,Space(1)+;
					cEOL)				
	//������������������������������������������Ŀ
	//�Volta a empresa anteriormente selecionada.�
	//��������������������������������������������
	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
	cFilAnt := SM0->M0_CODFIL
	
	While nloop<=len(aRows) 
		IncProc()           
       					
		FWrite(nArchivo,PADR(aRows[nLoop,1],15)+;
				PADR(aRows[nLoop,2],25)+;
				PADR(aRows[nLoop,3],15)+;
				PADR(aRows[nLoop,4],15)+;
				PADR(aRows[nLoop,5],15)+;       
				Substr(Strzero(val(transform(aRows[nloop,6],"9999999999.99")),10),1,10)+"."+Substr(Strzero(val(transform(aRows[nloop,6],"9999999999.99")),13),12,13)+;
				Strzero(val(transform(aRows[nloop,7],"999")),3)+; 	
				Strzero(val(transform(aRows[nloop,8],"9999")),4)+;
				PADR(aRows[nLoop,9],2)+;
				PADR(aRows[nLoop,10],2)+;
				PADR(aRows[nLoop,11],5)+; 
				cEOL)


				nLoop++

    EndDo
   	//Para cerrar el archivo creado
	If  Len(aRows)>0  
		fClose(nArchivo)  
		nMax:=Len(aRows)   
	Endif         
Endif            

Return ( Nil )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GetAus   � Autor � FMonroy               � Data � 17/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obtener las Ausencias de los Emplados que tienen alg�n     ���
���          � movimiento en trayectoria laboral                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � getAbsence(cCic,cSuca,@lINS,@lCCSS,@lAus)                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GEPEMXX4                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function getAbsence(cCic,lINS,lCCSS,lAus)
Local cAliasTmp := 	CriaTrab(Nil,.F.)	   
Local cSR8Name  := 	InitSqlName("SR8")     
Local cRCMName  := 	InitSqlName("RCM")     
Local cSRAName  := 	InitSqlName("SRA")     
Local cFilRCM   := 	xFilial( "RCM", SR8->R8_FILIAL)
Local cFilSRA   := 	xFilial( "SRA", SRA->RA_FILIAL)
Local cQuery    := 	""                                                                                     
Local cIniMes   := 	DTOS( CTOD( '01/'+cMes+'/'+cAnio) )
Local cFinMes   := 	DTOS( ctod(StrZero(F_UltDia(CTOD("01/" + cMes + "/" + cAnio)),2,0)+ "/"+cMes+"/"+cAnio) )
Local cTpImss	:=	"'G','A','M','F'"
Local nAbsence	:=	0

cQuery := " SELECT SR8.R8_FILIAL, SR8.R8_MAT,RCM.RCM_TPIMSS, SR8.R8_DURACAO, SRA.RA_CIC" 
cQuery += " FROM "+cSR8Name+" SR8 "
cQuery += "	INNER JOIN "+cRCMName+" RCM ON RCM.RCM_FILIAL='"+cFilRCM +"' AND RCM.RCM_TIPO=SR8.R8_TIPOAFA	"
cQuery += "	INNER JOIN "+cSRAName+" SRA ON SRA.RA_FILIAL='"+cFilSRA +"' AND SRA.RA_MAT=SR8.R8_MAT	"
cQuery += " WHERE "
cQuery += "			SR8.R8_FILIAL  ='"+cSucursal+"'"  
cQuery += "		AND SRA.RA_CIC  = '"+ cCic+ "'"
cQuery += "		AND SR8.R8_DATAINI  BETWEEN  '"+ cIniMes+ "' AND '"+ cFinMes+ "' "
cQuery += "		AND SR8.R8_DATAFIM  BETWEEN  '"+ cIniMes+ "' AND '"+ cFinMes+ "' "
cQuery += "	    AND RCM.RCM_TPIMSS IN ("+cTpImss+")"
cQuery += " 	AND SR8.D_E_L_E_T_=' '"    
cQuery += " ORDER BY SR8.R8_FILIAL, SRA.RA_CIC, SR8.R8_MAT"    
cQuery := ChangeQuery(cQuery)      

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
   
While (cAliasTmp)->(!EOF())
    nAbsence+=(cAliasTmp)->R8_DURACAO
	Do Case
		Case	(cAliasTmp)->RCM_TPIMSS=='IG' .Or. (cAliasTmp)->RCM_TPIMSS=='IM'
			lCCSS:=.T.
		Case	(cAliasTmp)->RCM_TPIMSS=='IA' 
			lINS:=.T.
		Case	(cAliasTmp)->RCM_TPIMSS=='F' 
			lAus:=.T.
	EndCase
		
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->( dbCloseArea()) 

Return ( nAbsence )    


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
��� Uso      � RUNPROC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function TodoOK(cPerg)
Local lRet := .T.             
Pergunte(cPerg,.F.)

cSucursal := MV_PAR01   //De Sucursal
cRegPat   := MV_PAR02	//A Sucursal
cMes	  := SUBSTR(strZERO(MV_PAR04,6),1,2)
cAnio	  := SUBSTR(strZERO(MV_PAR04,6),3,4)
cPath	  := MV_PAR06 //Ubicaci�n del archivo
nTipoPlan := MV_PAR03   //De Proceso
nMesA	  := MV_PAR04      //Periodo de Aplicaci�n de la novedad
nMFile	  := MV_PAR05    // Marcar como enviado: 1=Si; 2=No


IF !ExistDir(cPath)
    msginfo(STR0018)//"El directorio no existe"
	lRet := .F. 
EndIf

Return ( lRet )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPM006COS01� Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacion de las preguntas                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPM006COS01()										      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�      						                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X1_VALID - GPM006COS En X1_ORDEM = 7                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPM006COS01() 

Local  cMes:=SUBSTR(STRZERO(MV_PAR04,6),1,2)
                
IF  val(cMes)<1 .or.val(cMes)>13
	msginfo(STR0019) //"El mes debe ser de 1 a 12!"
    Return .F.
ENDIF                  

Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �getCondit � Autor � FMonroy               � Data � 18/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obetner la combinaci�n seg�n la plantilla RT.              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � getCondit(lExp1,lExp2,lExp3,lExp4,lExp5)                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  lExp1.-Ingreso (T/F)                                      ���
���          �  lExp2.-Baja (T/F)                                         ���
���          �  lExp3.-INS (T/F)                                          ���
���          �  lExp4.-INC (T/F)                                          ���
���          �  lExp5.-AUS (T/F)                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM006COS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function getCondit(lIngreso, lBaja,lINS,lCCSS,lAus)
// 1.-Ingreso dtmov
// 2.-Baja dtmov
// 3.-Inc INS
// 4.-INC ccss mt Y eg
// 5.-Ausentismo
Local cCondition:=""


//Todos los que tienen un Ingreso
IF lIngreso
	If lBaja
		cCondition:="05"
		If lINS .AND. !lCCSS .AND. lAus
			cContition:=""
		ENDIF
	Else
		cCondition:="01"
		If lINS .AND. !lCCSS .AND. lAus
			cContition:=""
		ENDIF
	EndIf
Else
	cCondition:="02"
	If !lBaja .and. !lINS .AND. lCCSS
		cCondition:="03"
	ENDIF
	If !lBaja .and. lINS .AND. !lCCSS
		cCondition:="04"
	ENDIF
	If !lBaja .and. !lINS .AND. !lCCSS .AND. lAus
		cCondition:="06"
	ENDIF
	If !lBaja .and. !lcINS .AND. !lCCSS .AND. !cAus
		cCondition:="00"
	ENDIF
	
ENDIF

Return ( cCondition )
