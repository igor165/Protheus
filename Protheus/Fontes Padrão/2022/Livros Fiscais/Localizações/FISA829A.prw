#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA829A.CH"

  /*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   �Archivo   ?Autor ?Alejandro Perret      ?Data ?30/10/10 ��?
��������������������������������������������������������������������������Ĵ��
���Descrip.   ?Fucionalidades para archivos de texto.                     ��?
��������������������������������������������������������������������������Ĵ��
���Uso        ?VARIOS.                                                    ��?
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/

CLASS Archivo 

	DATA nHnd 			As Numeric
	DATA lAbierto		As Boolean
	DATA cDisco			As Character
	DATA cDir			As Character
	DATA cNomArch		As Character
	DATA cExtension		As Character
	DATA cNomCompleto	As Character
		
	METHOD New() CONSTRUCTOR
	METHOD CreaArch()
	METHOD AbreTxt()
	METHOD CierraTxt()
	METHOD EOFTxt()
	METHOD LeeLinTxt()
	METHOD AvLinTxt()
	METHOD CantTotLinTxt()
	METHOD IrAlInicioTxt()
	METHOD ArchToArr()
	METHOD MueveArch()
	METHOD Escribir()
	METHOD EscribComp()
	METHOD CierraArch()
		
ENDCLASS

//---------------------------------------------------------------------------------------------------------------------------------------
METHOD New() CLASS Archivo
	::nHnd		:= 0
	::lAbierto	:= .F.
RETURN SELF    


/*������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ
�Metodo     ?CreaArch ?Autor ?Alejandro Perret      ?Fecha?30/10/13 ?
������������������������������������������������������������������������Ĵ
�Descrip.   ?Crea un archivo (puede ser de texto o binario).            ?
������������������������������������������������������������������������Ĵ
?     cNom ?Nombre del archivo con la ruta incluida y la extension.    ?
?   nAtrib ?Constante	Valor 	Descripci�n                            ?
?          ?FC_NORMAL   0 		Creaci�n normal del Archivo (est�ndar).?
?          ?FC_READONLY 1 		Crea el archivo protegido para grabaci�n.
?          ?FC_HIDDEN   2 		Crea el archivo como oculto.           ?
?          ?FC_SYSTEM   4 		Crea el archivo como sistema.          ?
��������������������������������������������������������������������������
������������������������������������������������������������������������*/ 

METHOD CreaArch(cNom, nAtrib) CLASS Archivo
	
	Local lRet	:= .T.
	
	::nHnd := FCreate(cNom, nAtrib)

	If ::nHnd == -1
		ConOut(STR0001)
		ConOut(STR0002 + cNom)
		ConOut(STR0003 + CValToChar(FError()) )
		lRet := .F.
	Else
		::lAbierto := .T.
		::cNomCompleto := cNom 
		SplitPath (cNom, @::cDisco, @::cDir, @::cNomArch, @::cExtension)
	EndIf
	
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD AbreTxt(cNombre, cMsgError) CLASS Archivo	

	Local lRet	:= .T.

	::nHnd := FT_FUSE(cNombre)
	If ::nHnd == -1						
		lRet := .F.
		cMsgError :=  STR0004 + cNombre
	Else
		::cNomCompleto := cNombre 
		SplitPath (cNombre, @::cDisco, @::cDir, @::cNomArch, @::cExtension)	
	EndIf
	
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD CierraTxt() CLASS Archivo
	FT_FUSE()
RETURN 

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD EOFTxt() CLASS Archivo
RETURN (FT_FEOF())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD LeeLinTxt() CLASS Archivo
RETURN (FT_FREADLN())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD AvLinTxt(nLineas) CLASS Archivo
RETURN (FT_FSKIP(nLineas))

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD CantTotLinTxt() CLASS Archivo
RETURN (FT_FLASTREC())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD IrAlInicioTxt() CLASS Archivo
RETURN (FT_FGOTOP())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD ArchToArr(cCodParse,cToken) CLASS Archivo


RETURN aRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD MueveArch(cOrig,cDest) CLASS Archivo
	Local lRet	:= .T.

	If lRet := __CopyFile(cOrig,cDest)
		If FErase(cOrig) == -1	
			lRet := .F.
		EndIf
	EndIf
	
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD Escribir(cLinea, cFinLinea) CLASS Archivo
	
	Default cFinLinea := CRLF
	
	FWrite(::nHnd, cLinea + cFinLinea)

RETURN

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD EscribComp(cLinea, cFinLinea, nQtdBytes) CLASS Archivo	
																
	Default cFinLinea := CRLF									
	
	FWrite(::nHnd, cLinea + cFinLinea, nQtdBytes)

RETURN


 //--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD CierraArch() CLASS Archivo
	
	If ::lAbierto
		If !FClose(::nHnd)
			ConOut(STR0005)
			ConOut(STR0006 + ::cNomCompleto)
			ConOut(STR0007 + CValToChar(FError()))
		EndIf
	Else
		ConOut(STR0008)
		ConOut(STR0009 + ::cNomCompleto + STR0010 )
	EndIf
	
RETURN