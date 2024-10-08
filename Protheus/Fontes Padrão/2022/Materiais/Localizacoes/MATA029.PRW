#include "Protheus.ch"
#include "MATA029.ch"
#include "TbiConn.ch"  //PARA SCHEDULLER

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Programa  � MATA029  � Autor  � Gpe. Santacruz           � Data � 28.02.14 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �DESCARGAS DE ARCHIVOS DEL SAT                                   ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA029()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � GENERAL                                                        ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS     �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������Ĵ��
���M.Camargo   �11.01.17|          �Modificacion en generaci+�n de archivo de ���
���            �        �          �certificados para que genere como tabla de���
���            �        �          �la BD.                                    ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/


Function MATA029(aEmp)  //Pasa datos al Arreglo si es ejecutado desde el Server (Scheduller)
Local aArea 	:= GetArea()


Local lDrive	:= .t.
Local lVar		:= .T.
Local lRet		:= .T.

Local aSays	:={ }
Local aButtons:= { }
Local nOpca 	:=0

Private cMsg:=''
Private cNomFte:="MATA029: "  
Private cCadastro 	:= STR0001   //"Archivos del SAT"

Private cArchivo:= "CSD.txt"
Private cDIRCSD :=''
Private cFTPSAT :=''
Private cDIRSAT := ''
Private lWorkFlow := .f.
DEFAULT aEmp := {.F.}  


  
lWorkFlow := aEmp[1]

if lWorkFlow
	CONOUT(cNomFte + STR0002)  //--"Prepare Environment"
	Prepare Environment Empresa aEmp[2] Filial aEmp[3] Modulo "COM"
	SetModulo( "SIGACOM" , "COM" ) 
	dbselectarea("SX6")
	
endif
      	  
cDIRCSD :=alltrim(SuperGetMv("MV_DIRCSD",,"0"))
cFTPSAT := alltrim(SuperGetMv("MV_FTPSAT",,"0"))
cDIRSAT := alltrim(SuperGetMv("MV_DIRSAT",,"0"))

if !lWorkFlow   
	
	AADD(aSays,OemToAnsi(STR0003) )  //---Descarga el archivo de Certificados (csd.txt) del FTP del SAT. Verifique la siguiente configuraci�n, antes de ejecutar el proceso:"
	AADD(aSays,OemToAnsi(STR0004) ) //---"   MV_FTPSAT, Direcci�n IP del servidor FTP del SAT ."
	AADD(aSays,OemToAnsi(STR0005 + alltrim(getmv("MV_FTPSAT")) ))  //"              Contenido actual :"
	AADD(aSays,OemToAnsi(STR0006) ) //--"   MV_DIRSAT, Directorio dentro del servidor FTP donde se encuentra el archivo CSD.TXT"
	AADD(aSays,OemToAnsi(STR0007)+alltrim(getmv("MV_DIRSAT"))   ) //---"              Contenido actual :"
	AADD(aSays,OemToAnsi(STR0008) ) //--"   MV_DIRCSD, Directorio dentro del Protheus_data, donde se depositara el archivo TXT."
	AADD(aSays,OemToAnsi(STR0009)+alltrim(getmv("MV_DIRCSD"))   ) //---"              Contenido actual :"
	
		
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(),FechaBatch(),nOpca:=0) }} )
	AADD(aButtons, { 2,.T.,{|o| nOpca:=0,FechaBatch() }} )
		
	FormBatch( cCadastro, aSays, aButtons,,250,750 )
		
else
	nOpca:= 1
	
endif

If nOpca == 1 //Ejecuta el proceso
	cTIni	:= Time()
	Processa( {|lEnd| MT29ARC()}, STR0010)  //---"Espere..."   
	CTFin   := Time()
	cDuracion:=ElapTime( cTIni , cTFin )
	
	cMsg:= STR0011 + alltrim(cDuracion)  //---"Tiempo Transcurrido : "
	
	if ! lWorkFlow
		MSGINFO(cMsg)    
		
	else	 	
		CONOUT(cNomFte+cMsg)
	endif	
endif


RestArea( aArea	   )
RETURN 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �TodoOk     � Autor �Gpe. Santacruz			� Data �18/02/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Valida la existencia del directorio local                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TodoOK(     )                                               ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA029                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION TodoOK()
Local lRet:= .t.
 
cMsg:=STR0012+" "+cDIRCSD //  El directorio no existe

if ! ExistDir(cDIRCSD)
   if !lWorkFlow
		Help( ,, STR0013,,cMsg ,1, 0 )   // Aviso  
	else
		CONOUT(cNomFte+cMsg)
	endif
	lRet:= .f.
endif	
RETURN lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �MT29ARC    � Autor �Gpe. Santacruz       .� Data �11/03/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Descargar archivos del SAT                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MT29ARC(     )                                              ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA029                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function MT29ARC 
  
Local aRetdir	  := {}

Local lBien:= .f.
Local aStruP:={}

ProcRegua(4)

if  lWorkFlow 
	CONOUT(cNomFte+STR0014+" "+cFTPSAT)   //"Inicio a la conexion "
ENDIF


if  file(cDIRCSD+"CSD.txt")
		FERASE(cDIRCSD+"CSD.txt") 
endif	

If FTPCONNECT(cFTPSAT)
	FTPDirChange(cDIRSAT)
		
	aRetDir := FTPDIRECTORY( cArchivo , )  
	If !Empty(aRetDir)
	    cMsg:=STR0015 + " " + cArchivo    //--Descargando Archivo
	    if  lWorkFlow 
			CONOUT(cNomFte+cMsg)
		else
	 		incproc(cMsg ) 
	 	endif
	    If !FTPdownLOAD(cDIRCSD+cArchivo, cArchivo )
	         cMsg:= STR0017+" "+cDIRSAT+cArchivo+" "+STR0018  // "Problemas al bajar el archivo"  "Al servidor"
      		 if  lWorkFlow 
				CONOUT(cNomFte+cMsg )
			else
			 	help( ,, STR0013,,cMsg ,1, 0 ) 
			EndIf
		ELSE       
		    lBien:= .t.
		    FTPDisconnect()
		    cMsg:=STR0019 +" "+cArchivo+" "+ STR0020  //---ARCHIVO, descarga relizada con exito
		    if  lWorkFlow 
				CONOUT(cNomFte+cMsg)
			else	
				incproc(cMsg )
			 	  
			EndIf
		ENDIF

	Else
		cMsg:= STR0021+" "+cArchivo //"Archivo no encontrado:"	
		if  !lWorkFlow
			Help( ,,STR0013,,cMsg, 1, 0 ) 
		ELSE
			CONOUT(cNomFte+cMsg)
		ENDIF	
	  	 
	EndIF	
Else
	if  !lWorkFlow
		cMsg:=STR0022 // "No se pudo realizar la conexion al servidor FTP "
		Help(, ,STR0013,, cMsg, 1, 0 ) 
	ELSE
		CONOUT(cnomfte+ STR0022)
	ENDIF	
ENDIF	

if !lBien
	FTPDisconnect()
endif	

//--- Si descargo correctamente, sube a un archivo en el SYSTEM el TXT     

if lBien
    cMsg:=STR0023+cDIRCSD
    if  lWorkFlow
		CONOUT(cNomFte+cMsg )
	else
	    IncProc(cMsg)	
	ENDIF	
		
	AADD(aStruP, {"SERIE"   ,"C",21,0}) 
	AADD(aStruP, {"FEC_INI" ,"C",20,0}) 
	AADD(aStruP, {"FEC_FIN" ,"C",20,0})
	AADD(aStruP, {"RFC"     ,"C",13,0})
	AADD(aStruP, {"EDO_CERT","C",2,0})
	
	If TcCanOpen("CSDSAT")
		TCDelFile ("CSDSAT") // Se borra la tabla de la BD 
	EndIf
	// Se regenera la tabla 
	DBCREATE("CSDSAT",aStruP,"TOPCONN")		
	dbUseArea(.T.,"TOPCONN","CSDSAT","CSDSAT",.F.,.F.) //LAS ABRE DE TIPO EXCLUSIVO
	DbCreateInd("CSDSAT","RFC",{|| "RFC" })
	dbSelectArea("CSDSAT" )
	// Se llena la tabla con respecto al archivo del sAT
	If file(cDIRCSD+cArchivo)
		CURSORWAIT()
	   append from &(cDIRCSD+cArchivo)  SDF
		CURSORARROW()
	Endif	
	CSDSAT->(DBCLOSEAREA())
	
	 cMsg:=STR0024  //"Descarga realizada con �xito"
	 if  lWorkFlow
		CONOUT(cNomFte+cMsg)
		
	else
		INCPROC("")	
		MSGINFO(cMsg)  	
	ENDIF
		
endif

Return