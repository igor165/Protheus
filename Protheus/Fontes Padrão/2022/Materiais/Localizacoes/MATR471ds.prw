#include "protheus.ch"
#include "Birtdataset.ch"
#include "matr471.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR471ds³ Autor ³Jesus Peñaloza         ³ Data ³ 21/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Data set de nota de credito en formato birt                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset M471ds
	title STR0027
	description STR0027
	PERGUNTE "MATR471"
columns
	define column SERIE		type character size 03	label STR0025 //like F1_SERIE
	define column DOCUM		like F1_DOC
	define column FECHA		type character size 10  label STR0006 //Fecha Emision
	define column IMPUE		type character size 20  label STR0007 //Vlr. Mercad.
	define column VALOR		type character size 20  label STR0008 //Valor Bruto
	define column VALET		type character size 100 label STR0009 //Importe Letra
	define column NOME		like A1_NOME
	define column DIREC		type character size 150 label STR0010 //Direccion
	define column ESTAD		like A1_ESTADO
	define column MUNIC		like A1_MUN
	define column PAIS		type character size 100 label "Pais"
	define column RFC			like A1_CGC
	define column CANTI		like D1_QUANT
	define column UMEDI		like D1_UM
	define column DESCR		like B1_DESC
	define column VUNIT		type character size 20  label STR0011 //"Valor Unit."
	define column TOTAL		type character size 20  label STR0012 //"Valor Total"
	define column IMPS		type character size 100 label STR0013 //"Impuestos"
	define column VALS		type character size 100 label STR0014 //"Sub. Impuestos"
	define Column CERTSAT	type CHARACTER size 100 label STR0015 //"Certificado Sat"
	define column CERTDIG	type CHARACTER size 100 label STR0016 //"Certificado Digital"
	define column CADORI		type CHARACTER size 450 label STR0017 //"Cadena Original"
	define column SELLOCFDI	type CHARACTER size 450 label STR0018 //"Sello CFDI"
	define column SELLOSAT	type CHARACTER size 450 label STR0019 //"Sello SAT"
	define column FECTIM		type CHARACTER size 10  label STR0021 //"Fecha Timbrado"
	define column FOLIOFIS	type CHARACTER size 100 label STR0022 //"Folio Fiscal"
	define column IMAGE		type character size 20  label "IMAGEN" //Imagen

define query "SELECT SERIE, DOCUM, FECHA, IMPUE, VALOR, VALET, NOME, DIREC, ESTAD, MUNIC, "+;
             "PAIS, RFC, CANTI, UMEDI, DESCR, VUNIT, TOTAL, IMPS, VALS, CERTSAT, CERTDIG, "+;
             "CADORI, SELLOSAT, SELLOCFDI, FECTIM, FOLIOFIS, IMAGE FROM %WTable:1%"

process dataset
	Local cWTabAlias
	Local cNotai := self:execParamValue("MV_PAR01")
	Local cNotaf := self:execParamValue("MV_PAR02")
	Local cSerie := self:execParamValue("MV_PAR03")
	Local lRet   := .F.

	if ::isPreview()
	endif

   cWTabAlias := ::createWorkTable()
   chkFile("SF1")
	Processa({|_lEnd| lRet := CreaRepo(cWTabAlias,cNotai,cNotaf,cSerie)}, ::title())

	if !lRet
        MsgInfo(STR0005) //"No hay datos que cumplan la condicion "
	else
		MsgInfo("Impresion Terminada")
	endif

return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  CreaRepo ³Autor ³ Jesus Peñaloza        ³ Data ³21/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Crea el Reporte de Notas de Credito                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CreaRepo(cExp1, cExp2, cExp3, cExp4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ cExp1.- Nombre de tabla temporal que guardara las notas    ³±±
±±³Parametros³ cExp2.- Numero de Nota de credito inicial                  ³±±
±±³          ³ cExp3.- Numero de Nota de credito final                    ³±±
±±³          ³ cExp4.- Numero de Serie                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR472                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CreaRepo(cWTabAlias, cNotai, cNotaf, cSerie)
	Local cnt         := 0
	Local lRet        := .F.
	Local cDesc		:= ""
	Local cVal			:= ""
	Local lImp 		:= .F.
	Local nMerc       := 0
	Local cDoc        := ''
	Local nCount      := 0
	Local oXML        := Nil
	Local cAviso      := ""
	Local cErro       := ""
	Local cCaminhoXML := ''
	Local lTim        := .F.
	Local cCerSAT	    := ""
	Local cCerEmi	    := ""
	Local cCadOri     := ""
	Local cSelloCFD   := ""
	Local cSelloSAT   := ""
	Local cFechaTim   := ""
	Local cUUIDTim    := ""
	Local cParName    := "" //  Nombre XML de la factura de venta para México
	Local cFileN      := ''
	Local cQuery      := ''
	Local cTempF      := CriaTrab(nil, .f.)
	Local cSDoc		  := SerieNFID("SF1", 3, "F1_SERIE")//incluido em 23/04/2015 projeto chave unica
	cQuery := "SELECT F1_ESPECIE, F1_SERIE, F1_DOC, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_VALMERC, F1_VALBRUT, A1_NOME, A1_END, "
	If cPaisLoc == 'MEX'
		cQuery += "A1_NR_END, A1_NROINT, "
	EndIf
	cQuery += "A1_BAIRRO, A1_EST, A1_PAIS, A1_MUN, A1_CEP, A1_CGC, D1_QUANT, D1_UM, B1_DESC, D1_VUNIT, D1_TOTAL "
	cQuery += "FROM "+RetSqlName("SF1")+" SF1, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SD1")+" SD1, "+RetSqlName("SB1")+" SB1 "
	cQuery += "WHERE F1_FORNECE = A1_COD AND F1_LOJA = A1_LOJA "
	cQuery += "AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA "
	cQuery += "AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE "
	cQuery += "AND D1_COD = B1_COD "
	cQuery += "AND F1_FILIAL = '"+xFilial("SF1")+"' "
	cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND D1_FILIAL = '"+xFilial("SD1")+"' "
	cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "AND F1_DOC BETWEEN '"+cNotai+"' AND '"+cNotaf+"' "
	cQuery += "AND "+cSDoc+" = '"+cSerie+"' " // "AND F1_SERIE = '"+cSerie+"' " modificado em 23/04/15 PRJ Chave Unica. 
	cQuery += "AND F1_ESPECIE = 'NCC' "
	If cPaisLoc == 'MEX' .and. FieldPos("F1_TIMBRE") > 0
		cQuery += "AND F1_TIMBRE <> '' "
	EndIf
	cQuery += "AND SF1.D_E_L_E_T_ = '' "
	cQuery += "AND SA1.D_E_L_E_T_ = '' "
	cQuery += "AND SD1.D_E_L_E_T_ = '' "
	cQuery += "AND SB1.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY F1_DOC "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	TCSetField(cTempF, "F1_EMISSAO", "D")

	count to nCount

	(cTempF)->(dbGoTop())
	ProcRegua(nCount)

	SF1->(dbSelectArea("SF1"))
	SF1->(dbSetOrder(1)) //Filial + No. Documento + Serie + Proveedor + Tienda

	While (!(cTempF)->(EOF()))
		cDesc     := ""
		cVal      := ""
		nMerc     := 0
		cDoc      := (cTempF)->F1_DOC
		cAviso    := ""
		cErro     := ""
		lTim      := .F.
		cCerSAT   := ""
		cCerEmi   := ""
		cCadOri   := ""
		cSelloCFD := ""
		cSelloSAT := ""
		cFechaTim := ""
		cUUIDTim  := ""
		cParName  := ""
		cFileN    := ""

		If cPaisLoc == 'MEX'
			cCaminhoXML 	:= &(GetMv("MV_CFDDOCS"))
		EndIf
		//Obtiene los impuestos
		lImp := GetImp((cTempF)->F1_FORNECE+(cTempF)->F1_LOJA+(cTempF)->F1_DOC+(cTempF)->F1_SERIE,@cDesc,@cVal,(cTempF)->F1_DOC+;
		        (cTempF)->F1_SERIE+(cTempF)->F1_FORNECE+(cTempF)->F1_LOJA)

		While (!(cTempF)->(EOF())) .and. cDoc == (cTempF)->F1_DOC
			nMerc += (cTempF)->F1_VALMERC
			Incproc()
			IF cPaisLoc == "MEX"
				//Datos del SAT CFD
				SF1->(dbSeek(xFilial("SF1")+cDoc+(cTempF)->F1_SERIE+(cTempF)->F1_FORNECE+(cTempF)->F1_LOJA))
				cParName:= &(SuperGetmv( "MV_CFDNAF1" , .F. , "" ))
				cFileN	:= cCaminhoXML + cParName
				oXML := XmlParserFile(cFileN, "_", @cAviso,@cErro )

				if ( !Empty(cAviso) .or. !Empty(cErro) )
					lTim :=.F.
				Else
					// Verificar si está timbrado para obtener fecha del TFD.
					if ( XMLChildEx( oXML:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO" ) == NIL )
						lTim := .F.
					else
						cFechaTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
						cFechaTim	:= (SubStr(cFechaTim,9,2)+"/"+SubStr(cFechaTim,6,2)+"/"+SubStr(cFechaTim,1,4))//+" "+SubStr(cFechaTim,12,8))
						cCerSat	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
						cCerEmi	:= OemToAnsi(oXML:_CFDI_COMPROBANTE:_NOCERTIFICADO:TEXT) // Cer Dig
						cSelloSAT 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT
						cSelloCFD	:= oXML:_CFDI_COMPROBANTE:_SELLO:TEXT
						cUUIDTim	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
						cCadOri	:= 	CadCFDI(oXML)
						lTim := .T.
						cnt++
					endif
				endif
			Else
				// Para argentina no aplica por lo que siempre se imprime.
				cnt++
				lTim := .T.
			EndIF
			If lTim
				RecLock(cWTabAlias, .T.)
					(cWTabAlias)->SERIE     := (cTempF)->F1_SERIE
					(cWTabAlias)->DOCUM     := (cTempF)->F1_DOC
					(cWTabAlias)->FECHA     := DTOC((cTempF)->F1_EMISSAO)
					(cWTabAlias)->IMPUE     := Alltrim(Transform((cTempF)->F1_VALMERC, "@E 999,999,999.99"))
					(cWTabAlias)->VALOR     := Alltrim(Transform((cTempF)->F1_VALBRUT, "@E 999,999,999.99"))
					(cWTabAlias)->VALET     := extenso((cTempF)->F1_VALBRUT)
					(cWTabAlias)->NOME      := (cTempF)->A1_NOME
					If cPaisLoc == 'MEX'
						(cWTabAlias)->DIREC := Alltrim((cTempF)->A1_END)+" Num "+Alltrim((cTempF)->A1_NR_END)+", "+Alltrim((cTempF)->A1_NROINT)+;
						                       ", "+Alltrim((cTempF)->A1_BAIRRO)
					Else
						(cWTabAlias)->DIREC := (cTempF)->A1_END
					EndIf
					(cWTabAlias)->ESTAD     := Alltrim(POSICIONE("SX5",1,XFILIAL("SX5")+"12"+(cTempF)->A1_EST,"X5_DESCSPA"))
					(cWTabAlias)->MUNIC     := (cTempF)->A1_MUN
					(cWTabAlias)->PAIS      := Alltrim(POSICIONE("SYA",1,xFilial("SYA")+(cTempF)->A1_PAIS,"YA_DESCR"))+", C.P. "+Alltrim((cTempF)->A1_CEP)
					(cWTabAlias)->RFC       := (cTempF)->A1_CGC
					(cWTabAlias)->CANTI     := (cTempF)->D1_QUANT
					(cWTabAlias)->UMEDI     := (cTempF)->D1_UM
					(cWTabAlias)->DESCR     := (cTempF)->B1_DESC
					(cWTabAlias)->VUNIT     := Alltrim(Transform((cTempF)->D1_VUNIT, "@E 999,999,999.99"))
					(cWTabAlias)->TOTAL     := Alltrim(Transform((cTempF)->D1_TOTAL, "@E 999,999,999.99"))
					(cWTabAlias)->IMPS      := cDesc
					(cWTabAlias)->VALS      := cVal
					(cWTabAlias)->CERTSAT   := cCerSat
					(cWTabAlias)->CERTDIG   := cCerEmi
					(cWTabAlias)->CADORI    := cCaDOri
					(cWTabAlias)->SELLOCFDI := cSelloCFD
					(cWTabAlias)->SELLOSAT  := cSelloSAT
					(cWTabAlias)->FECTIM    := cFechaTim
					(cWTabAlias)->FOLIOFIS  := cUUIDTim
					(cWTabAlias)->IMAGE     := "lgrl"+cEmpAnt+".bmp"
				(cWTabAlias)->(MsUnlock())
			EndIf
			(cTempF)->(dbSkip())
		EndDo
	EndDo
	(cTempF)->(dbCloseArea())
	SF1->(dbCloseArea())
	lRet := cnt > 0
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CadCFDI  ³ Autor ³ Mayra Camargo         ³ Data ³20/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Construye la cadena original del complemento de            ³±±
±±³          ³ certificación del SAT que en el caso de CFDI sustituye a la³±±
±±³          ³ cadena original en la impresión del CFDI.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CadCFDI(oXML)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cExp:= String cadena original                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR552DS                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp := Objeto con XML timbrado                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CadCFDI(oXML)
Local cFechaTim	:= ""
Local cUUIDTim	:= ""
Local cCerTim		:= ""
Local cSelloCFDI	:= ""

if ( XMLChildEx( oXML:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO" ) == NIL )
	cCadOrig := ""
else
	cFechaTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
	cUUIDTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
	cCerTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
	cSelloCFDI	:= oXML:_CFDI_COMPROBANTE:_SELLO:TEXT

	cCadOrig := "||"
	cCadOrig += "1.0|" 				//	Version
	cCadOrig += cUUIDTim + "|"		// 	UUID
	cCadOrig += cFechaTim + "|"		// 	Fecha y hora de certificación
	cCadOrig += cSelloCFDI + "|"	// 	Sello digital del CFDI
	cCadOrig += cCerTim + "||"		//	Número de certificado
Endif
Return cCadOrig

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GetImp   ³ Autor ³ Mayra Camargo         ³ Data ³20/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtiene impuestos de la nota de cargo.						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetImp(cClave,cDesc,cVal)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR552DS                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1:= Clave de la factura                                ³±±
±±³          ³ cExp2:= Por referencia cadena con desccripción a retornar  ³±±
±±³          ³ cExp3:= Por referencia cadena con valores de imp a retornar³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function GetImp(cClave,cDesc,cVal,cClaveImp)
	Local aArea   := getArea()
	Local aImp    := {}
	Local nValImp := 0
	Local nPor    := 0
	Local nBasImp := 0
	Local cImp    := ""
	Local nX      := 0

		SF3->(dbSelectArea("SF3"))
		SFC->(dbSelectArea("SFC"))

		SF3->(dbSetOrder(4))
		SFC->(dbSetOrder(1))

		SF3->(dbGotop())

		IF SF3->(DbSeek(xFilial("SF3") + cClave))
			While SF3->(!EOF()) .and. SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cClave
				IF SFC->(DbSeek(xFilial("SFC") + SF3->F3_TES))
					While !(SFC->(Eof())) .and. SFC->FC_TES == SF3->F3_TES
						IF aScan(aImp,{|x| x == SFC->FC_IMPOSTO}) == 0
							AADD(aImp,SFC->FC_IMPOSTO)
						EndIF
						SFC->(DBSKIP())
					ENDDO
				ENDIF
				SFC->(dbGotop())
				SF3->(dbSkip())
			EndDo
		ENDIF

		SF3->(dbCloseArea())
		SFC->(dbCloseArea())

		//impuestos.
		SFB->(dbSelectArea("SFB"))
		SFB->(dbSetOrder(1))

		for nX :=1 to Len(aImp)
			SFB->(dbGotop())
			IF SFB->(DbSeek(xFilial("SFB") + aImp[nX]))
				cImp := SFB->FB_CPOLVRO
				nPor := SFB->FB_ALIQ
				nBasImp := POSICIONE("SF1",1,xfilial("SF1")+cClaveImp,"F1_BASIMP" +cImp)
				nValImp := POSICIONE("SF1",1,xfilial("SF1")+cClaveImp,"F1_VALIMP" +cImp)

				IF nBasImp > 0
					cDesc	+= alltrim(SFB->FB_CODIGO) + " " + TRANSFORM(nPor,"999.99")+ " % (" + STR0008 + TRANSFORM(nBasImp,"999,999.99") +;
					          ")" +CHR(13)+CHR(10)
					cVal	+=  TRANSFORM(nValImp,"999,999.99") + CHR(13)+CHR(10)
				EndIF

			ENDIF
		next

		SFB->(dbCloseArea())

	RestArea(aArea)
return .T.
