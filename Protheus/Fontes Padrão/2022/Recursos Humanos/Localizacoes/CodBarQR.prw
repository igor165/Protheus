#Include "Protheus.ch"
#Include "shell.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CodBarQR  �Autor  �Alberto Rodriguez   �Fecha � 25/04/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     �Ejecuta Exe - DLL para generar imagen de codigo de barras QR���
���          �Factura electronica										  ���
�������������������������������������������������������������������������͹��
���Uso       �General	                                                  ���
�������������������������������������������������������������������������͹��
��� Programador  � Fecha  � Comentario									  ���
�������������������������������������������������������������������������͹��
���Luis Samaniego�28/04/14�Cambio en nombre del archivo CodbarQR_xxx.txt  ���
���              �        �TPJTSG                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CodBarQR( cCodigo , cImgFile )
Local cArchivo := ""
Local cExt := If( Upper(Right(cImgFile,4)) $ ".BMP/.JPG/.PNG" , "" , ".jpg" )
Local nHdl := 0
Local aParam := { cCodigo, cImgFile }
Local cLinea := ""
Local nLoop := 0
Local lRet := .T.
Local cPatron := ""

If FunName() == "IMPRECXML"
	cPatron := "_" + Trim(MV_PAR01)	// Proceso
	cPatron += Trim(MV_PAR02)	// Procedimiento
	cPatron += Trim(MV_PAR03)	// Periodo
	cPatron += Trim(MV_PAR04)	// Numero de pago

	cArchivo := GetClientDir() + "\codbarqr" + cPatron + ".txt"
Else
	cArchivo := GetClientDir() + "\codbarqr.txt"
EndIf

Begin Sequence

	If !File( GetClientDir() + "QRCode.exe" )
		MsgStop( OemToAnsi( "No se ha instalado el programa para crear imagen de c�digo de barras QR." ), OemToAnsi( "Error" ) )
		lRet := .F.
		Break
	Endif

	Ferase(cArchivo)

	// Crea archivo de texto con par�metros de la imagen a crear
	nHdl  := fCreate(cArchivo)
	If  nHdl == -1 
		MsgAlert( "El archivo " + cArchivo + " no pudo ser creado" )
		lRet := .F.
		Break
	Endif

	For nLoop := 1 To Len(aParam)
		cLinea := aParam[nLoop] + CRLF
		If fWrite(nHdl, cLinea, Len(cLinea)) != Len(cLinea)
			If !MsgAlert( "No fue posible grabar el archivo " + cArchivo )
				lRet := .F.
				Exit
			Endif
		Endif
	Next nLoop

	fClose(nHdl)
	
	If lRet
		// Ejecuta programa externo para generar la imagen
		nHdl := WaitRun(GetClientDir() + "QRCode.exe " + "codbarqr" + cPatron + ".txt", SW_HIDE )
		If nHdl == 0
			If !File( GetClientDir() + aParam[2] + cExt )
				MsgStop( OemToAnsi( "No se cre� el archivo de imagen." ), OemToAnsi( "Error" ) )
				lRet := .F.
			Endif
		Else
			MsgStop( OemToAnsi( "No se pudo ejecutar QRCode.exe, verifique la causa y reintente."), OemToAnsi( "Error" ) )
			lRet := .F.
		Endif
	Endif

End Sequence

Return lRet
