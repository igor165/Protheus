#include "Protheus.ch"
#include "topconn.ch"
#include "FISA815.ch"
#include "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#Include "RPTDEF.CH"


#DEFINE _SERREC     1
#DEFINE _NORECIBO   2
#DEFINE _FECHA      3
#DEFINE _RECIBIDO   4
#DEFINE _SALDO      5
#DEFINE _CLIENTE    6
#DEFINE _LOJA       7
#DEFINE _TASA       8

#DEFINE _TIPO       1
#DEFINE _NUMERO     2
#DEFINE _PREFIXO    3
#DEFINE _PARCELA    4
#DEFINE _VALOR      5
#DEFINE _MOEDA      6
#DEFINE _EMISSAO    7

/*/{Protheus.doc} FISA815A
Metodo responsable por realizar la creación de archivos xml y pdf.
@type 		Method

@param 		cNumero		,caracter	,numero del recibo
@param 		cSerie 	    ,caracter	,serie del recibo
@param 		nOpc	 	,numerico	,opción 0-xml y pdf, 1-xml, 2-pdf
@param 		aResponse	,array  	,arreglo para información
@param 		lResponse	,logico  	,informa si es llamado desde un un json y debe agregar la información a aResponse
@param      jData       ,JsonObject ,manda datos desde la FINA998

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/06/2021 
/*/
Function FISA815A(cNumero, cSerie, nOpc, aResponse, lResponse, jData)
Local cExtXML	:= ".xml"
Local cNomXML	:= OemToAnsi(STR0009) + Alltrim(cSerie) + Alltrim(cNumero)  + ".xml"    //"ReciboPago"
Local cNomTmp	:= OemToAnsi(STR0009) + Alltrim(cSerie) + Alltrim(cNumero)              //"ReciboPago"
Local aAreaSEL	:= SEL->(GetArea())
Local nArchXML	:= 0
Local cMsjError := ""
Local cEmailCli := ""

Local aRecibo   := {}
Local aRecibos  := {}
Local aTemp     := {}
Local aPagos    := {}
Local aDoctos   := {}
Local cXml      := ""
local cCarpeta:= ""
Local aFilesEnv := {}
local i         := 1
Local aCarp:= {}
Local cDir      := &(SuperGetmv( "MV_CFDRECP" , .F. , "GetSrvProfString('startpath','')+'\cfd\recpagos\'" ))
Local lImpReci	:= ExistBLock("F998IMPREC")

Default nOpc        := 0
Default aResponse   := {}
Default lResponse   := .F.
Default	aDocuments	:= 	{}
Default jData       := JsonObject():New()
Default cCliente	:= 	""

If !ExistDir( cDir )
    aCarp := separa(cDir, "\")
    cCarpeta :=  "\"
    for i:=1 to len(aCarp)
        If aCarp[i] <>  ""
            cCarpeta += aCarp[i] + "\"
            Makedir( cCarpeta)
        EndIf
    Next
EndIf
    If nOpc == 0 .Or. nOpc == 1
        GetDatos(cNumero, cSerie, @aRecibo,@aPagos, @aDoctos)
        cXml := CreaXML(cNumero, cSerie, aRecibo, aPagos, aDoctos)
        nArchXML := CreaArch(cNomXML, cExtXML, cDir, @cMsjError)
		If Empty(cMsjError)
			GrabaTexto(cXml, nArchXML, .T.)
		EndIf

		If File( cDir+ cNomXML) .And. jData['sendemail'] ==  .T.
			If jData['joindocuments'] == .T.
				Aadd(aDocuments, cDir+cNomXML)
			Else
				Aadd(aFilesEnv, cDir+cNomXML)//Se agrega xml para el envío.
			EndIf
		Else
			aAdd(aResponse,{.F.,400, STR0131 +" "+cNomXML , ""})
		Endif
    EndIf
    
    Aadd(aTemp,{aPagos,aDoctos})
    Aadd(aRecibos, {cNomXML, "", "", aTemp, cNumero, cSerie})

    If (nOpc == 0 .Or. nOpc == 2) .and. Empty(cMsjError)
        If File( cDir + cNomXML)
            IF lImpReci
				//PE para impresión personalizada de totvs recibos
				Execblock("F998IMPREC",.f.,.f.,aRecibos)
			ELSE
                ImpPDF(cNomXML, Replace(cNomXML, ".xml", ".pdf"), cNomTmp, cDir, jData)
            ENDIF
			If File( cDir + cNomTmp+".pdf") .And. jData['sendemail'] ==  .T.
				If jData['joindocuments'] == .T.
					Aadd(aDocuments, cDir +cNomTmp+".pdf")
				Else
					Aadd(aFilesEnv, cDir +cNomTmp+".pdf")//Se agrega xml para el envío.
				EndIf
			Else
				aAdd(aResponse,{.F.,400, STR0131 +" "+cNomTmp+".pdf" , ""})
			Endif
        Else
            cMsjError := OemToAnsi(STR0132) //"Los siguientes archivos no se encontrado en el directorio "
            cMsjError += cNomXML
        EndIf
        If Empty(cMsjError) .and. !File( cDir + Replace(cNomXML, ".xml", ".pdf"))
            cMsjError := Replace(cNomXML, ".xml", ".pdf") + " - " + OemToAnsi(STR0074) //"Archivo no generado."
		EndIf
	EndIf

	If jData['origin'] ==  "FINA998" .AND. jData['sendemail'] ==  .T.
		cEmailCli := jData['email']
		If jData['joindocuments'] == .T.
			IF jData['latest'] == .T.
				If EnvRecMail(cEmailCli,aDocuments,jData,aResponse)
					If jData['origin'] ==  "FINA998"
						AADD(aResponse,{.T.,200,STR0125 + " - cliente: "+jData['client'],""})
					Else
						MsgInfo(STR0125,STR0124) // Envío de complemento de recepción de pago exitoso.
					EndIf
				Else
					If jData['origin'] ==  "FINA998"
						AADD(aResponse,{.F.,400,STR0126 + " - cliente: "+jData['client'],""})
					Else
						MsgAlert(STR0126,STR0124) // El Complemento de recepción de pago no fue enviado.
					EndIf
				Endif
			EndIf
		Else
			If EnvRecMail(cEmailCli,aFilesEnv,jData,aResponse)
				If jData['origin'] ==  "FINA998"
					AADD(aResponse,{.T.,200,STR0125,""})
				Else
					MsgInfo(STR0125,STR0124) // Envío de complemento de recepción de pago exitoso.
				EndIf
			Else
				If jData['origin'] ==  "FINA998"
					AADD(aResponse,{.F.,400,STR0126,""})
				Else
					MsgAlert(STR0126,STR0124) // El Complemento de recepción de pago no fue enviado.
				EndIf
			Endif
		Endif
	EndIf

    If lResponse .and. !Empty(cMsjError)
        aAdd(aResponse,{.F.,400, cMsjError , ""})
    EndIf

    RestArea(aAreaSEL)
Return

/*/{Protheus.doc} GetDatos
Metodo responsable por obtener los datos del recibo
@type 		Method

@param 		cNumero		,caracter	,numero del recibo
@param 		cSerie 	    ,caracter  	,serie del recibo
@param 		aRecibo	 	,array  	,arreglo para la información del encabezado del recibo
@param 		aPagos	 	,array  	,arreglo para la información de los pagos
@param 		aDoctos	 	,array  	,arreglo para la información de los documentos

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/06/2021 
/*/
Static Function GetDatos(cNumero, cSerie, aRecibo, aPagos, aDoctos)
Local cFilSEL	:= xFilial("SEL")
Local cCliente  := ""
Local cLoja     := ""
Local cFecha    := ""
Local nRec      := 0
Local nComp     := 0
Local nTB       := 0
Local nDecs     := MsDecimais(1)

Default cNumero	:= ""
Default cSerie	:= ""
Default aPagos	:= {}
Default aImp	:= {}

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8))//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(DbSeek(cFilSEL + cSerie + cNumero))
        cCliente    := SEL->EL_CLIORIG 
        cLoja       := SEL->EL_LOJORIG
        cFecha      := DTOC(SEL->EL_DTDIGIT)
		While !(SEL->(EOF())) .And. SEL->(EL_FILIAL + EL_SERIE + EL_RECIBO  ) == cFilSEL + cSerie + cNumero
			If AllTrim(SEL->EL_TIPODOC) == "TB" .OR. AllTrim(SEL->EL_TIPODOC) = "RA"
                aAdd(aDoctos, {SEL->EL_TIPO, SEL->EL_NUMERO, SEL->EL_PREFIXO, SEL->EL_PARCELA, SEL->EL_VALOR, SEL->EL_MOEDA, DTOC(SEL->EL_EMISSAO)})
                //Se asigna la tasa
		        DO CASE	
			        CASE VAL(SEL->EL_MOEDA) == 2 
				        aAdd(aDoctos[LEN(aDoctos)],EL_TXMOE02)
			        CASE VAL(SEL->EL_MOEDA) == 3 
				        aAdd(aDoctos[LEN(aDoctos)],EL_TXMOE03)
			        CASE VAL(SEL->EL_MOEDA) == 4 
				        aAdd(aDoctos[LEN(aDoctos)],EL_TXMOE04)
			        CASE VAL(SEL->EL_MOEDA) == 5
				        aAdd(aDoctos[LEN(aDoctos)],EL_TXMOE05)
			        OTHERWISE
				        aAdd(aDoctos[LEN(aDoctos)],1)
		        ENDCASE
                If SEL->EL_TIPO $ MVRECANT+"/"+MV_CRNEG    // "RA /NCC"
                    nComp	+= SEL->EL_VLMOED1
                Else
                    nTB	+= SEL->EL_VLMOED1
                Endif
            ElseIf AllTrim(SEL->EL_TIPODOC) $ "CH|TF|EF|RI|RB|RG|RS|RM|RR|CC|DC"
                aAdd(aPagos, {SEL->EL_TIPO, SEL->EL_NUMERO, SEL->EL_PREFIXO, SEL->EL_PARCELA, SEL->EL_VALOR, SEL->EL_MOEDA, DTOC(SEL->EL_EMISSAO)})
                //Se asigna la tasa
		        DO CASE	
			        CASE VAL(SEL->EL_MOEDA) == 2 
				        aAdd(aPagos[LEN(aPagos)],EL_TXMOE02)
			        CASE VAL(SEL->EL_MOEDA) == 3 
				        aAdd(aPagos[LEN(aPagos)],EL_TXMOE03)
			        CASE VAL(SEL->EL_MOEDA) == 4 
				        aAdd(aPagos[LEN(aPagos)],EL_TXMOE04)
			        CASE VAL(SEL->EL_MOEDA) == 5
				        aAdd(aPagos[LEN(aPagos)],EL_TXMOE05)
			        OTHERWISE
				        aAdd(aPagos[LEN(aPagos)],1)
		        ENDCASE
                If  Subs(SEL->EL_TIPODOC,1,2)$"RI|RG|RB|RS|RM|RR"
                    nRec	+= SEL->EL_VLMOED1
                ElseIf Alltrim(SEL->EL_TIPODOC) $ "EF|CH|TF|CC"
                    nComp	+= SEL->EL_VLMOED1
                    nRec	+= SEL->EL_VLMOED1
                Endif
            EndIf
			SEL->(DbSkip())
		EndDo
         aAdd(aRecibo,{cSerie, cNumero, cFecha, Round(nRec,nDecs) , Round(nComp-nTB,nDecs) , cCliente, cLoja})
	EndIf

Return

/*/{Protheus.doc} CreaXML
Metodo responsable por crear la información para
@type 		Method

@param 		cNumero		,caracter	,numero del recibo
@param 		cSerie 	    ,caracter  	,serie del recibo
@param 		aRecibo	 	,array  	,arreglo para la información del encabezado del recibo
@param 		aPagos	 	,array  	,arreglo para la información de los pagos
@param 		aDoctos	 	,array  	,arreglo para la información de los documentos

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/06/2021 
/*/
Static Function CreaXML(cNumero, cSerie, aRecibo, aPagos, aDoctos)
Local cXml      := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
Local nX        := 0
Local cPict     := "@E 999,999,999.99"
Local cFilCTO		:= xFilial("CTO")
Local CMoeda := ""

    //Datos del comprobante
    cXml += '<Comprobante '
    If !Empty(cSerie)
        cXml += 'Serie="' + aRecibo[1][_SERREC]     + '" ' 
    EndIf
    cXml += 'Folio="'    + AllTrim(aRecibo[1][_NORECIBO])    + '" ' 
    cXml += 'Fecha="'    + aRecibo[1][_FECHA]                + '" ' 
    cXml += 'Recibido="' + AllTrim(Transform(aRecibo[1][_RECIBIDO], cPict))  + '" >' + CRLF

    //Emisor
    cXml += '<Emisor '
    cXml += 'ID="'       + AllTrim(SM0->M0_CGC)       + '" ' 
    cXml += 'Nombre="'   + AllTrim(SM0->M0_NOMECOM)   + '" ' 
    cXml += '/>' + CRLF
    
    //Receptor
    If SA1->(MsSeek(xFilial("SA1") + aRecibo[1][_CLIENTE] + aRecibo[1][_LOJA]))
        cXml += '<Receptor '
        cXml += 'ID="'       + AllTrim(SA1->A1_CGC)   + '" '
        cXml += 'Nombre="'   + AllTrim(SA1->A1_NOME)  + '" '
        cXml += '/>' + CRLF
    EndIf

    //Documentos
    cXml += '<Documentos> ' + CRLF

    For nX := 1 To Len(aDoctos)
        CMoeda := Posicione("CTO", 1, cFilCTO  + StrZero(IIf(ValType(aDoctos[nX][_MOEDA]) == "C", Val(aDoctos[nX][_MOEDA]),aDoctos[nX][_MOEDA]),2),"CTO_DESC")

        cXml += '<Documento '
        
        cXml += 'Tipo="' +       AllTrim(aDoctos[nX][_TIPO])      + '" ' 
        cXml += 'Numero="' +     AllTrim(aDoctos[nX][_NUMERO])    + '" ' 
        cXml += 'Prefijo="' +    AllTrim(aDoctos[nX][_PREFIXO])   + '" ' 
        cXml += 'Parcela="' +    AllTrim(aDoctos[nX][_PARCELA])   + '" ' 
        cXml += 'Valor="' +      AllTrim(Transform(aDoctos[nX][_VALOR], cPict))  + '" ' 
        cXml += 'Moneda="' +     CMoeda + '" ' 
        IF Val(aDoctos[nX][_MOEDA]) != 1
            cXml += 'Tasa="' + AllTrim(Transform(aDoctos[nX][_TASA], cPict))+ '" ' 
        ENDIF
        cXml += 'Emision="' +    AllTrim(aDoctos[nX][_EMISSAO])   + '" ' 

        cXml += '/> ' + CRLF
    Next nX

    cXml += '</Documentos>' + CRLF

    //Pagos
    cXml += '<Pagos> ' + CRLF

    For nX := 1 To Len(aPagos)
        CMoeda := Posicione("CTO", 1, cFilCTO  + StrZero(IIf(ValType(aPagos[nX][_MOEDA]) == "C", Val(aPagos[nX][_MOEDA]),aPagos[nX][_MOEDA]),2),"CTO_DESC")
        cXml += '<Pago '
        
        cXml += 'Tipo="' +       AllTrim(aPagos[nX][_TIPO])      + '" ' 
        cXml += 'Numero="' +     AllTrim(aPagos[nX][_NUMERO])    + '" ' 
        cXml += 'Prefijo="' +    AllTrim(aPagos[nX][_PREFIXO])   + '" ' 
        cXml += 'Parcela="' +    AllTrim(aPagos[nX][_PARCELA])   + '" ' 
        cXml += 'Valor="' +      AllTrim(Transform(aPagos[nX][_VALOR], cPict)) + '" ' 
        cXml += 'Moneda="' +     CMoeda + '" '
        IF Val(aPagos[nX][_MOEDA]) != 1
            cXml += 'Tasa="' + AllTrim(Transform(aPagos[nX][_TASA], cPict))+ '" ' 
        ENDIF
        cXml += 'Emision="' +    AllTrim(aPagos[nX][_EMISSAO])   + '" ' 

        cXml += '/> ' + CRLF
    Next nX

    cXml += '</Pagos>' + CRLF

    cXml += '</Comprobante>' 
    
Return cXml

/*/{Protheus.doc} CreaArch
Metodo responsable por crear el archivo xml
@type 		Method

@param 		cNomArch	,numeri		,nombre del archivo
@param 		cExt 	    ,caracter	,extensión del archivo
@param 		cDir	 	,caracter	,dirección para crear el archivo

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/06/2021 
/*/
Static Function CreaArch(cNomArch, cExt, cDir, cMsjError)
	Local nHdle     := 0
	Local cDrive    := ""
	Local cNewFile  := cDir + cNomArch

	SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
	cDir := cDrive + cDir
	Makedir(cDir)
	cNomArc := cDir + cNomArch + cExt

    If !(ExistDir( cDir ) )
        cDir := Replace( cDir, "\\", "\" )
        cDir := Replace( cDir, "\", "/" )
        cMsjError := OemToAnsi(STR0138 + cDir )
    Else   
        nHdle := FCreate (cNomArc,0)
        If nHdle == -1
            cNomArc := Replace( cNomArc, "\\", "\" )
            cNomArc := Replace( cNomArc, "\", "/" )
            cMsjError := OemToAnsi(STR0007 + cNomArc)
        EndIf
    EndIf

	
Return nHdle

/*/{Protheus.doc} GrabaTexto
Metodo responsable por realizar el grabado del archivo xml
@type 		Method

@param 		cXmlNom		,caracter	,nombre del archivo xml
@param 		nHdle 	    ,numerico	,handle del archivo creado
@param 		lClose	 	,logico 	,indica si realiza el cierre del archivo
@param 		lEncode	 	,logico 	,indica si realiza condificación UTF8

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/06/2021 
/*/
Static Function GrabaTexto(cArcXml, nHdle, lClose, lEncode)
	Default lClose := .F.
	Default lEncode := .F.

    If lEncode
		cArcXml := ENCODEUTF8(cArcXml)
	EndIf
	FWrite(nHdle, cArcXml)
	If lClose
		FClose (nHdle)
	EndIf
Return

/*/{Protheus.doc} ImpPDF
Metodo responsable por realizar la impresión del archivo PDF
@type 		Method

@param 		cXmlNom		,caracter	,nombre del archivo xml
@param 		cPdfNom 	,caracter	,nombre del archivo pdf
@param 		cNomTmp	 	,caracter	,nombre del archivo del recibo
@param 		cDir	 	,caracter	,dirección del archivo xml

@author 	raul.medina
@version	12.1.27 / Superior
@since		04/06/2021 
/*/
Static Function ImpPDF(cXmlNom, cPdfNom, cNomTmp, cDir ,jData)
Local cCaminhoXML	:= ""
Local cPath 		:= Replace( cDir, "\\", "\" )
Local oXML			:= NIL
Local oPrinter
Local cError		:= ""
Local cDetalle	    := ""
local cXml := ""
Local cRutaSmr      := IIF(Empty(SuperGetmv( "MV_CFDSMAR" , .F., "")), GetClientDir(), &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" )))

Default jData := JsonObject():New()

    cCaminhoXML := Replace(cDir + cXmlNom, "\\", "\")

	IF ISSRVUNIX()
		cCaminhoXML := Replace( cCaminhoXML, "\", "/" )
		cPath := Replace( cPath, "\", "/" )
	EndIf

    oPrinter := FWMsPrinter():New(AllTrim(cPdfNom), 6, .F.,cPath , .T.)

    If FILE(cCaminhoXML) 
        cXml := XmlRead(cCaminhoXML)
        cXML := STRTRAN(cXML,'<?xml version="1.0" encoding="utf-8"?>' ,'<?xml version="1.0"?>')
	    oXml := xmlParser(encodeUTF16(cXML), "", @cDetalle, @cError)
	EndIf

    If oXML == NIL
		Return ""
	EndIf

    oPrinter:setDevice(IMP_PDF)
    oPrinter:lServer := .T.
	oPrinter:cPathPDF := cRutaSmr

	oPrinter:StartPage()
	ImprRec(oPrinter, oXml)
	oPrinter:EndPage()

    If jData['origin'] ==  "FINA998" .And. jData['imppdf'] != .F.
	    oPrinter:SetViewPDF(.T.)
    Else
	    oPrinter:SetViewPDF(.F.)
    EndIf

    IF jData['origin'] ==  "FINA998" 
	    IF !FILE(cRutaSmr + cPdfNom)
	    	oPrinter:Print()
		    COPY FILE (cRutaSmr + cPdfNom ) TO (cPath + cPdfNom )
	    Else
            IF jData['imppdf'] == .T. .and. jData['sendemail'] == .F.
                oPrinter:Print()
		        COPY FILE (cRutaSmr + cPdfNom ) TO (cPath + cPdfNom )
            ENDIF
        ENDIF
    ELSE
	    oPrinter:Print()
	    COPY FILE (cRutaSmr + cPdfNom ) TO (cPath + cPdfNom )
    ENDIF

	FreeObj(oPrinter)
	oPrinter := Nil

Return

/*/{Protheus.doc} ImprRec
Metodo responsable por realizar la llamada de funciones de impresión
@type 		Method

@param 		oPrinter	,object		,Objeto para la impresión
@param 		oXML 	    ,object	    ,Objeto xml con la información del recibo

@author 	raul.medina
@version	12.1.27 / Superior
@since		04/06/2021 
/*/
Static Function ImprRec(oPrinter, oXml)
Local nLine := 0

    ImpEnc(oPrinter,oXml,@nLine)
    fLanca(oPrinter,oXML, @nLine)
    fRodape(oPrinter,oXML, @nLine)

Return

/*/{Protheus.doc} ImpEnc
Metodo responsable por realizar la impresión del encabezado del archivo.
@type 		Method

@param 		oPrinter	,object		,Objeto para la impresión
@param 		oXML 	    ,object 	,Objeto xml con la información del recibo
@param 		nLine	 	,numerico	,Linea de impresión

@author 	raul.medina
@version	12.1.27 / Superior
@since		04/06/2021 
/*/
Static Function ImpEnc(oPrinter, oXml, nLine)
Local cFileLogo	:= ""
Local cSerie	:= ""

Local oFont3 := TFont():New( "ARIAL", , 12, .T., .T.)
Local oFont8 := TFont():New("Arial",,15,.T., .T.)

	oPrinter:Line(5, 5, 790, 5, , "-2") //Linea lateral izquierda
	oPrinter:Line(5, 585, 790, 585, , "-4") //Linea lateral derecha
	oPrinter:Line(5, 5, 5, 585, , "-4")//Linea horizontal de marco

	nLine += 40
	oPrinter:Say(nLine, 195, OemToAnsi(STR0025), oFont8) //Recibo Electrónico de Pago

	nLine -= 20
	cFileLogo := fCarLogo()
	If File(cFileLogo)
		oPrinter:SayBitmap(nLine, 15, cFileLogo, 50, 50)
	Endif

	nLine += 30
	oPrinter:Say(nLine, 370, OemToAnsi(STR0026), oFont3) //Recibo no.:
	
	If XMLChildEX(oXml:_COMPROBANTE, "_SERIE") <> Nil
		cSerie := AllTrim(oXml:_COMPROBANTE:_SERIE:TEXT) + " "
	EndIf
	
	oPrinter:Say(nLine, 480, cSerie + oXml:_COMPROBANTE:_FOLIO:TEXT, oFont3)

	nLine += 12
	oPrinter:Say(nLine, 370, OemToAnsi(STR0076), oFont3) //Tipo de Comprobante
	oPrinter:Say(nLine, 480, OemToAnsi(STR0051), oFont3) //"Pago "
	nLine += 20
	oPrinter:Say(nLine, 370, OemToAnsi(STR0133), oFont3) //Lugar, Fecha y hora de emisión
	oPrinter:Say(nLine, 480, &("oXml:_COMPROBANTE:_FECHA:TEXT"), oFont3) //oXml:_COMPROBANTE:_FECHA:TEXT
    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")//Linea horizontal de marco
Return Nil

/*/{Protheus.doc} fLanca
Metodo responsable por realizar la impresión el cuerpo del archivo.
@type 		Method

@param 		oPrinter	,object		,Objeto para la impresión
@param 		oXML 	    ,object 	,Objeto xml con la información del recibo
@param 		nLine	 	,numerico	,Linea de impresión

@author 	raul.medina
@version	12.1.27 / Superior
@since		04/06/2021 
/*/
Static Function fLanca(oPrinter,oXML, nLine)
Local nI			:= 0
Local oFont         := TFont():New( "ARIAL", , 07, .T., .F.)
Local oFont3        := TFont():New( "ARIAL", , 12, .T., .T.)
Local oFont4        := TFont():New( "ARIAL", , 07, .T., .T.)
Local oXmlDocs      := Nil
Local oXmlpagos     := Nil

    
    
	nLine += 20
	oPrinter:Line(nLine, 5, nLine, 585, , "-4")
	oPrinter:Say(nLine -= 5, 10, OemToAnsi(STR0028), oFont3)//Datos de identificación del emisor

	nLine += 15
	oPrinter:Say(nLine, 10, OemToAnsi(STR0029), oFont4) //Nombre o razon social
	oPrinter:Say(nLine, 120, oXml:_COMPROBANTE:_EMISOR:_NOMBRE:TEXT, oFont)

	oPrinter:Say(nLine, 350, OemToAnsi(STR0134), oFont4)//"Identificación"
	oPrinter:Say(nLine, 450, oXml:_COMPROBANTE:_EMISOR:_ID:TEXT, oFont)

    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")

    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")

	oPrinter:Say(nLine -= 5, 10, OemToAnsi(STR0032) ,oFont3)//Datos de identificacion del receptor

	nLine += 15
	oPrinter:Say(nLine, 10, OemToAnsi(STR0029), oFont4)//Nombre o razon social
	oPrinter:SAY(nLine, 120, oXml:_COMPROBANTE:_RECEPTOR:_NOMBRE:TEXT, oFont)

	oPrinter:Say(nLine, 350, OemToAnsi(STR0134), oFont4)//"Identificación"
	oPrinter:SAY(nLine, 450, oXml:_COMPROBANTE:_RECEPTOR:_ID:TEXT, oFont)

    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")

    
    //Documentos
    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")

    oPrinter:Say(nLine -= 5, 10, OemToAnsi(STR0135), oFont3)//Documentos

    If XmlChildEx(oXml:_COMPROBANTE:_DOCUMENTOS, '_DOCUMENTO') <> Nil
        oXmlDocs := oXml:_COMPROBANTE:_DOCUMENTOS:_DOCUMENTO
    EndIf

    If ValType(oXmlDocs) == "O"
		ImpcDocs(oPrinter, oXmlDocs, @nLine)
	ElseIf ValType(oXmlDocs) == "A"
		For nI := 1 To Len(oXmlDocs)
			ImpcDocs(oPrinter, oXmlDocs[nI], @nLine)
		Next nI
	EndIf

    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")

    //Pagos
    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")

    oPrinter:Say(nLine -= 5, 10, OemToAnsi(STR0044), oFont3)//Pagos

    If XmlChildEx(oXml:_COMPROBANTE:_PAGOS, '_PAGO') <> Nil
        oXmlpagos := oXml:_COMPROBANTE:_PAGOS:_PAGO
    EndIf

    If ValType(oXmlpagos) == "O"
		ImpcDocs(oPrinter, oXmlpagos, @nLine, .T.)
	ElseIf ValType(oXmlpagos) == "A"
		For nI := 1 To Len(oXmlpagos)
			ImpcDocs(oPrinter, oXmlpagos[nI], @nLine, .T.)
		Next nI
	EndIf
    
    nLine += 20
    oPrinter:Line(nLine, 5, nLine, 585, , "-4")

Return Nil

/*/{Protheus.doc} ImpcDocs
Metodo responsable por realizar la impresión de documentos y pagos.
@type 		Method

@param 		oPrinter	,object		,Objeto para la impresión
@param 		oXML 	    ,object 	,Objeto xml con la información del recibo
@param 		nLine	 	,numerico	,Linea de impresión

@author 	raul.medina
@version	12.1.27 / Superior
@since		04/06/2021 
/*/
Static Function ImpcDocs(oPrinter, oXmlDoc, nLine, lPago)
Local oFont         := TFont():New( "ARIAL", , 07, .T., .F.)
Local oFont4        := TFont():New( "ARIAL", , 07, .T., .T.)
Local cTipoPago     := ""

Default oXmlDoc := Nil
Default lPago   := .F.

    nLine += 15
    If lPago
        oPrinter:Say(nLine, 10, OemToAnsi(STR0051), oFont4)//Pago
    Else
        oPrinter:Say(nLine, 10, OemToAnsi(STR0048), oFont4)//Documento
    EndIf
    
    If XmlChildEx(oXmlDoc, '_NUMERO') <> Nil
        oPrinter:SAY(nLine, 90, &("oXmlDoc:_NUMERO:TEXT"), oFont)
    EndIf

    nLine += 15
	If lPago
        oPrinter:Say(nLine, 10, OemToAnsi(STR0054), oFont4)//"Forma de pago"
    Else
        oPrinter:Say(nLine, 10, OemToAnsi(STR0136), oFont4)//Tipo documento
    EndIf
    If XmlChildEx(oXmlDoc, '_TIPO') <> Nil
        cTipoPago := &("oXmlDoc:_TIPO:TEXT")
        If  cTipoPago $ "CH"
            cTipoPago := OemToAnsi(STR0045)
        ElseIf cTipoPago $ "EF"
            cTipoPago := OemToAnsi(STR0046)
        ElseIf cTipoPago $ "TF"
            cTipoPago := OemToAnsi(STR0047)
        EndIf
        oPrinter:SAY(nLine, 80, cTipoPago, oFont)
    EndIf
    
	oPrinter:Say(nLine, 110 , OemToAnsi(STR0061), oFont4)//Serie
    If XmlChildEx(oXmlDoc, '_PREFIJO') <> Nil
        oPrinter:SAY(nLine, 130, &("oXmlDoc:_PREFIJO:TEXT"), oFont) 
    EndIf

    oPrinter:Say(nLine, 160, OemToAnsi(STR0063), oFont4)//Parcialidad
    If XmlChildEx(oXmlDoc, '_PARCELA') <> Nil
        oPrinter:SAY(nLine, 210, &("oXmlDoc:_PARCELA:TEXT"), oFont)
    EndIf

    oPrinter:Say(nLine, 230, OemToAnsi(STR0108), oFont4)//Valor 
    If XmlChildEx(oXmlDoc, '_VALOR') <> Nil
        oPrinter:SAY(nLine, 260, &("oXmlDoc:_VALOR:TEXT"), oFont) 
    EndIf

    oPrinter:Say(nLine, 320, OemToAnsi(STR0055), oFont4)//Moneda 
    If XmlChildEx(oXmlDoc, '_MONEDA') <> Nil
        oPrinter:SAY(nLine, 370, &("oXmlDoc:_MONEDA:TEXT"), oFont) 
    EndIf

    If XmlChildEx(oXmlDoc, '_TASA') <> Nil
        oPrinter:Say(nLine, 400, OemToAnsi(STR0056), oFont4)//Moneda 
        oPrinter:SAY(nLine, 450, &("oXmlDoc:_TASA:TEXT"), oFont) 
    EndIf

    oPrinter:Say(nLine, 490, OemToAnsi(STR0137), oFont4)//"Emisión"
    If XmlChildEx(oXmlDoc, '_EMISION') <> Nil
        oPrinter:SAY(nLine, 520, &("oXmlDoc:_EMISION:TEXT"), oFont) //520
    EndIf

Return Nil

/*/{Protheus.doc} fRodape
Metodo responsable por realizar el pie de pagina
@type 		Method

@param 		oPrinter	,object		,Objeto para la impresión
@param 		oXML 	    ,object 	,Objeto xml con la información del recibo
@param 		nLine	 	,numerico	,Linea de impresión

@author 	raul.medina
@version	12.1.27 / Superior
@since		04/06/2021 
/*/
Static Function fRodape(oPrinter, oXML, nLine)
Local oFont     := TFont():New( "ARIAL", , 07, .T., .F.)
Local oFont4    := TFont():New( "ARIAL", , 07, .T., .T.)

    nLine += 15

	oPrinter:Say(nLine, 380, OemToAnsi(STR0144), oFont4) //Pagos
	oPrinter:Say(nLine, 520, &("oXml:_COMPROBANTE:_RECIBIDO:TEXT"), oFont)

Return Nil

/*/{Protheus.doc} fCarLogo
Obtiene la imagen para el logo del la impresión
@type 		Method

@author 	raul.medina
@version	12.1.27 / Superior
@since		04/06/2021 
/*/
Static Function fCarLogo()
Local cStartPath    := GetSrvProfString("Startpath", "")
Local cLogo         := ""

	cLogo	:= cStartPath + "\LGRL"+ SM0->M0_CODIGO + SM0->M0_CODFIL + ".BMP" // Empresa+Filial
	//-- Logotipo da Empresa
	If !File( cLogo )
		cLogo := cStartPath + "\LGRL" + SM0->M0_CODIGO + ".BMP" // Empresa
	Endif
Return cLogo

//En esta entrega no es utilizada esta función,
Static Function borraPdf(cNumRec)
Local cRutaSmr 	    := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))
Local cNomXml		:= "recibopago" + cNumRec + ".pdf"
    If File(cRutaSmr + cNomXml)
		Ferase(cRutaSmr + cNomXml)
	EndIf
Return

Static Function XmlRead(cFile)
Local nHandle	:= 0
Local nLast		:= 0
Local cXml		:= ""

	nHandle := FT_FUse(cFile)

	nLast := FT_FLastRec()
	FT_FGoTop()

	 While !FT_FEOF()
		cXml  += FT_FReadLn()
		// Pula para próxima linha
		FT_FSKIP()
	End
	// Fecha o Arquivo
	FT_FUSE()

Return cXml
