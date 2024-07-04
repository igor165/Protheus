#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

#DEFINE ARIAL_6		01
#DEFINE ARIAL_7		02
#DEFINE ARIAL_8		03
#DEFINE ARIAL_9		04
#DEFINE ARIAL_10	05
#DEFINE ARIAL_11	06
#DEFINE ARIAL_12	07
#DEFINE ARIAL_13	08
#DEFINE ARIAL_14	09
#DEFINE ARIAL_15	10
#DEFINE ARIAL_16	11
#DEFINE ARIAL_17	12
#DEFINE ARIAL_18	13
#DEFINE ARIAL_19	14
#DEFINE ARIAL_20	15

#DEFINE ARIAL_6B	16
#DEFINE ARIAL_7B	17
#DEFINE ARIAL_8B	18
#DEFINE ARIAL_9B	19
#DEFINE ARIAL_10B	20
#DEFINE ARIAL_11B	21
#DEFINE ARIAL_12B	22
#DEFINE ARIAL_13B	23
#DEFINE ARIAL_14B	24
#DEFINE ARIAL_15B	25
#DEFINE ARIAL_16B	26
#DEFINE ARIAL_17B	27
#DEFINE ARIAL_18B	28
#DEFINE ARIAL_19B	29
#DEFINE ARIAL_20B	30

#DEFINE COURIER_6	31
#DEFINE COURIER_7	32
#DEFINE COURIER_8	33
#DEFINE COURIER_9	34
#DEFINE COURIER_10	35
#DEFINE COURIER_11	36
#DEFINE COURIER_12	37
#DEFINE COURIER_13	38
#DEFINE COURIER_14	39
#DEFINE COURIER_15	40
#DEFINE COURIER_16	41
#DEFINE COURIER_17	42
#DEFINE COURIER_18	43
#DEFINE COURIER_19	44
#DEFINE COURIER_20	45

#DEFINE COURIER_6B	46
#DEFINE COURIER_7B	47
#DEFINE COURIER_8B	48
#DEFINE COURIER_9B	49
#DEFINE COURIER_10B	50
#DEFINE COURIER_11B	51
#DEFINE COURIER_12B	52
#DEFINE COURIER_13B	53
#DEFINE COURIER_14B	54
#DEFINE COURIER_15B	55
#DEFINE COURIER_16B	56
#DEFINE COURIER_17B	57
#DEFINE COURIER_18B	58
#DEFINE COURIER_19B	59
#DEFINE COURIER_20B	60

#DEFINE SEGOE_6		61
#DEFINE SEGOE_7		62
#DEFINE SEGOE_8		63
#DEFINE SEGOE_9		64
#DEFINE SEGOE_10	65
#DEFINE SEGOE_11	66
#DEFINE SEGOE_12	67
#DEFINE SEGOE_13	68
#DEFINE SEGOE_14	69
#DEFINE SEGOE_15	70
#DEFINE SEGOE_16	71
#DEFINE SEGOE_17	72
#DEFINE SEGOE_18	73
#DEFINE SEGOE_19	74
#DEFINE SEGOE_20	75

#DEFINE SEGOE_6B	76
#DEFINE SEGOE_7B	77
#DEFINE SEGOE_8B	78
#DEFINE SEGOE_9B	79
#DEFINE SEGOE_10B	80
#DEFINE SEGOE_11B	81
#DEFINE SEGOE_12B	82
#DEFINE SEGOE_13B	83
#DEFINE SEGOE_14B	84
#DEFINE SEGOE_15B	85
#DEFINE SEGOE_16B	86
#DEFINE SEGOE_17B	87
#DEFINE SEGOE_18B	88
#DEFINE SEGOE_19B	89
#DEFINE SEGOE_20B	90

#DEFINE DEJAVU_6	91
#DEFINE DEJAVU_7	92
#DEFINE DEJAVU_8	93
#DEFINE DEJAVU_9	94
#DEFINE DEJAVU_10	95
#DEFINE DEJAVU_11	96
#DEFINE DEJAVU_12	97
#DEFINE DEJAVU_13	98
#DEFINE DEJAVU_14	99
#DEFINE DEJAVU_15	100
#DEFINE DEJAVU_16	101
#DEFINE DEJAVU_17	102
#DEFINE DEJAVU_18	103
#DEFINE DEJAVU_19	104
#DEFINE DEJAVU_20	105

#DEFINE DEJAVU_6B	106
#DEFINE DEJAVU_7B	107
#DEFINE DEJAVU_8B	108
#DEFINE DEJAVU_9B	109
#DEFINE DEJAVU_10B	110
#DEFINE DEJAVU_11B	111
#DEFINE DEJAVU_12B	112
#DEFINE DEJAVU_13B	113
#DEFINE DEJAVU_14B	114
#DEFINE DEJAVU_15B	115
#DEFINE DEJAVU_16B	116
#DEFINE DEJAVU_17B	117
#DEFINE DEJAVU_18B	118
#DEFINE DEJAVU_19B	119
#DEFINE DEJAVU_20B	120
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT  | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
| Descripcion: Clase para manejar las impresiones PDF.                |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ADPRINT

	DATA lPDF
	DATA oPrn
	
	DATA cPathPdf
	DATA cPathRel
	DATA cNombre
	DATA cDirPDF
	DATA aFontes
	DATA aString
	DATA lVerCoor
	
	DATA nTamFila
	DATA nTamCol
	
	DATA nAjuFil	
	DATA nAjuCol
	
	DATA nHorizontal
	DATA nVertical

	METHOD New() CONSTRUCTOR
	METHOD setDesplazamiento()
	METHOD setPrinter()
	METHOD setPDF()
	METHOD imprimePDF()
	METHOD mueve()
	METHOD borra()
	METHOD visualiza()
	METHOD guardaCoordenadas()
	METHOD setCoordenadas()
	METHOD F()
	METHOD C()
	
	METHOD StartPage()
	METHOD EndPage()	
	METHOD Say()
	METHOD SayAlign()
	METHOD SayBitmap()
	METHOD Box()
	METHOD Line()
	METHOD CodBar()
	METHOD QrCode()
	
ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT  | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(lPDF, nPorcAju, nTamFila, nTamCol, lVerCoor) CLASS ADPRINT 

	Local nX			
	Local nPorc	:= IIf(nPorcAju<>Nil, nPorcAju/100, 1) * IIf(lPDF, 1, 1)
	
	::lPDF		:= lPDF
	::oPrn		:= Nil
	::cPathPdf	:= GetTempPath()
	::cPathRel	:= "\spool\"
	::aFontes	:= {}
	::aString	:= {}
	::nAjuFil	:= IIf(lPDF, 0.90, 1)
	::nAjuCol	:= IIf(lPDF, 0.98, 1)
	::nTamFila	:= IIf(nTamFila <> Nil, nTamFila, 50) * ::nAjuFil
	::nTamCol	:= IIf(nTamCol <> Nil, nTamCol, 50) * ::nAjuCol
	::lVerCoor	:= IIf(lVerCoor <> Nil, lVerCoor, .F.)
	
	::setPrinter()
	::setDesplazamiento(0,0)
	
	// Del 01 a 15 Arial Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Arial",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX

	// Del 16 a 30 Arial Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Arial",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX

	// Del 31 a 45 Courier New Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Courier New",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX

	// Del 46 a 60 Courier New Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Courier New",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX
	
	// Del 61 a 75 Segoe UI Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Segoe UI",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX	

	// Del 76 a 90 Segoe UI Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Segoe UI",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX	

	// Del 61 a 75 DejaVu Sans Mono Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "DejaVu Sans Mono",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX	

	// Del 76 a 90 DejaVu Sans Mono Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "DejaVu Sans Mono",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX		
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT  | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setPrinter() CLASS ADPRINT 
	
	If !::lPDF .And. ::oPrn == Nil
		/*
		::oPrn := TMSPrinter():New()		
		::oPrn:SetPage(9)
		::oPrn:Setup()
		::oPrn:SetPortrait()		
		*/

		::oPrn:=FwMSPrinter():New("Spool",2)
		::oPrn:SetResolution(78)	// GDC - 78
		::oPrn:SetPortrait()
		::oPrn:SetPaperSize(DMPAPER_A4)
		::oPrn:SetMargin(10,10,10,10)
	EndIf
	
RETURN ::oPrn

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setPDF(cNombre, cDirPDF) CLASS ADPRINT

	If ::lPDF
		If cNombre != Nil			
			::cNombre := cNombre
			::cDirPDF := cDirPDF + IIf(Right(Alltrim(cDirPDF),1) <> "\", "\", "")
			
			::oPrn:=FwMSPrinter():New(cNombre,6,.T.,::cPathRel,.T.,,,,.T.)
			::oPrn:SetResolution(72)	// GDC - 78
			::oPrn:SetPortrait()
			::oPrn:SetPaperSize(DMPAPER_A4)
			::oPrn:SetMargin(10,10,10,10)

			::oPrn:CPATHPDF	:= ::cPathPdf
			::oPrn:LVIEWPDF	:= .F. 
			::oPrn:CPRINTER	:= "PDF"
			::oPrn:NDEVICE	:= 6                                                            
			::oPrn:CPATHPRINT	:= ::cPathPdf
		EndIf
	EndIf
	
RETURN ::oPrn

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDesplazamiento(nHorizontal, nVertical) CLASS ADPRINT 

	If nHorizontal <> Nil
		::nHorizontal := nHorizontal
	EndIf
	
	If nVertical <> Nil
		::nVertical := nVertical
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD imprimePDF() CLASS ADPRINT 
		
	If ::lPDF .And. ::oPrn <> Nil
		::oPrn:Print()
		::mueve()
		::borra()
		Ms_Flush()
		
		If ::lVerCoor
			::guardaCoordenadas()
		EndIf
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD mueve() CLASS ADPRINT

	Local aArchOld 	:= {}
	Local cNomTmp		:= ""
	Local nI 		:= 0

	Local lCopio	:= .F.

	aArchOld := Directory( ::cPathPdf + ::cNombre + "*.PDF" )

	For nI := 1 to Len( aArchOld )
		cNomTmp := AllTrim(aArchOld[nI][1])
		lCopio := __CopyFile(::cPathPdf + cNomTmp, ::cDirPDF + cNomTmp)
	Next nI 

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borra() CLASS ADPRINT

	Local cTmp		:= ::cPathPdf
	Local aArchOld	:= Directory( cTmp + "*.PDF" )
	Local nI		:= 1

	For nI := 1 to Len( aArchOld )
		FErase( cTmp + aArchOld[nI][1])
	Next nI

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD visualiza() CLASS ADPRINT

	If !::lPDF
		::oPrn:Preview()
		Ms_Flush()
		
		If ::lVerCoor
			::guardaCoordenadas()
		EndIf		
	EndIf

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setCoordenadas(nFila, nCol, cTexto) CLASS ADPRINT

	If ::lVerCoor
		aAdd(::aString, cTexto + " => F="+cValToChar(nFila)+";C="+cValToChar(nCol)+"")	
	EndIf

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardaCoordenadas() CLASS ADPRINT

	Local nX
	Local cString := ""
	
	For nX := 1 To Len(::aString)
		cString += ::aString[nX] + CHR(13)+CHR(10)
	Next nX
	
	MemoWrite("\spool\coordenadas.txt", cString)

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD StartPage() CLASS ADPRINT

	::oPrn:StartPage()

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD EndPage() CLASS ADPRINT

	::oPrn:EndPage()

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Say(nFila, nCol, cTexto, nFont) CLASS ADPRINT

	::setCoordenadas(nFila, nCol, cTexto)
	::oPrn:Say(::F(nFila), ::C(nCol), cTexto, ::aFontes[nFont], 100)

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD SayAlign(nFila, nCol, cTexto, nFont, nWidth, nAlign) CLASS ADPRINT
	
	::setCoordenadas(nFila, nCol, cTexto)
	::oPrn:SayAlign(::F(nFila), ::C(nCol), cTexto, ::aFontes[nFont], nWidth, 200, Nil, nAlign)

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD SayBitmap(nFila, nCol, cBMP, nWidth, nHeight) CLASS ADPRINT

	::setCoordenadas(nFila, nCol, cBMP)
	::oPrn:SayBitmap(::F(nFila), ::C(nCol), cBMP, nWidth, nHeight)

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Box(nTop, nLeft, nBottom, nRight) CLASS ADPRINT

	::setCoordenadas(nTop, nLeft, "Top="+cValToChar(nTop)+";Left="+cValToChar(nLeft)+";Bottom="+cValToChar(nBottom)+";Right="+cValToChar(nRight)+"")	
	::oPrn:Box(::F(nTop), ::C(nLeft), ::F(nBottom), ::C(nRight))
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Line(nTop, nLeft, nBottom, nRight) CLASS ADPRINT

	::setCoordenadas(nTop, nLeft, "Top="+cValToChar(nTop)+";Left="+cValToChar(nLeft)+";Bottom="+cValToChar(nBottom)+";Right="+cValToChar(nRight)+"")	
	::oPrn:Line(::F(nTop), ::C(nLeft), ::F(nBottom), ::C(nRight))
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD F(nFila) CLASS ADPRINT
RETURN ( nFila * ::nTamFila ) + ::nVertical

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD C(nCol) CLASS ADPRINT
RETURN ( nCol * ::nTamCol ) + ::nHorizontal

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD CodBar(cCod, nFil, nCol) CLASS ADPRINT

::oPrn:FWMsBar("INT25", nFil*::nAjuFil, nCol*::nAjuCol, cCod, ::oPrn, .F., Nil, Nil, 0.017, 0.8, .F., Nil, Nil,.F.)

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
User Function AD_PCuad()

	Local nX
	Local nY
	Local oPrn
	Local oFont
	
	RpcSetType( 2 )
	RpcSetEnv("99","01")	
	
	oPrn := ADPRINT():New(.F., 50)
	oPrn:StartPage()
	
	For nX := 1 To 100
		For nY := 1 To 100
			oPrn:Box( nX, nY, nX + 1, nY + 1 )
			If nY > 1
				oPrn:Say( nX , nY + 0.1, cValToChar(nY), COURIER_6)
			EndIf
		Next
		oPrn:Say( nX , 1.1, cValToChar(nX), COURIER_6)
	Next

	oPrn:EndPage()
	oPrn:visualiza()
	
	RpcClearEnv()
	
Return Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ADPRINT | Autor: Andres Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD QRCode( nFil, nCol,cCod,nTam) CLASS ADPRINT

::oPrn:QrCode( nFil*::nAjuFil, nCol*::nAjuCol, cCod, nTam)

RETURN Nil





