#Include "Protheus.ch"
#Include "shell.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCodBarQR  บAutor  ณAlberto Rodriguez   บFecha ณ 25/04/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEjecuta Exe - DLL para generar imagen de codigo de barras QRบฑฑ
ฑฑบ          ณFactura electronica										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGeneral	                                                  บฑฑ
ฑฑฬออออออออออฯอออัออออออออัอออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Programador  ณ Fecha  ณ Comentario									  บฑฑ
ฑฑฬออออออออออออออุออออออออุอออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบLuis Samaniegoณ28/04/14ณCambio en nombre del archivo CodbarQR_xxx.txt  บฑฑ
ฑฑบ              ณ        ณTPJTSG                                         บฑฑ
ฑฑศออออออออออออออฯออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
		MsgStop( OemToAnsi( "No se ha instalado el programa para crear imagen de c๓digo de barras QR." ), OemToAnsi( "Error" ) )
		lRet := .F.
		Break
	Endif

	Ferase(cArchivo)

	// Crea archivo de texto con parแmetros de la imagen a crear
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
				MsgStop( OemToAnsi( "No se cre๓ el archivo de imagen." ), OemToAnsi( "Error" ) )
				lRet := .F.
			Endif
		Else
			MsgStop( OemToAnsi( "No se pudo ejecutar QRCode.exe, verifique la causa y reintente."), OemToAnsi( "Error" ) )
			lRet := .F.
		Endif
	Endif

End Sequence

Return lRet
