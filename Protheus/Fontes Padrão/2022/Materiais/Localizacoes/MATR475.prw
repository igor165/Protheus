#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MATR475.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR475  ³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de PDF para Documentos Fiscales de Entrada/Salida.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ FECHA  ³     BOPS    ³        MOTIVO DA ALTERACAO              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³27/12/18³DMINA-1644³En fun MATR475Enc se asigna la Fun F815LinCar ³±±
±±³            ³        ³          ³ a la Forma de Pago para  recorta y dividir en³±±
±±³            ³        ³          ³ lineas la descripcion. se asigna la descripc.³±±
±±³            ³        ³          ³ del Régimen Fiscal obtenida de la tabla S010 ³±±
±±³Oscar Garcia³25/02/19³DMINA-6068³Creación de PE M475IMPPER para impresion usan-³±±
±±³            ³        ³          ³do formato personalizado.(MEX)                ³±±
±±³Alf. Medrano³02/07/19³DMINA-6599³En fun MATR475Det a precio unitario cValUniItm³±±
±±³            ³        ³          ³ se quita la fun trasnform() y solo se asigna ³±±
±±³            ³        ³          ³ un ALLTRIM() para quitar espacios.           ³±±
±±³Alf. Medrano³09/07/19³DMINA-6966³Se crea Fun UTf8ToChr() para el control de ca-³±±
±±³            ³        ³          ³-racteres especciales(uff8 a Char). Dentro de ³±±
±±³            ³        ³          ³la func MATR475Enc se asigna UTf8ToChr al nom-³±±
±±³            ³        ³          ³-bre del Emisor, Cliente y descrip de producto³±±
±±³Alf. Medrano³15/10/20³DMINA-9957³En Fun MATR475Enc() se asigna tratamiento para³±±
±±³            ³        ³          ³identificar tipo de dato que contiene el nodo ³±±
±±³            ³        ³          ³_CFDI_CFDIRELACIONADO, si es array entonces   ³±±
±±³            ³        ³          ³contiene mas de un valor                      ³±±
±±³            ³18/05/20³          ³En Fun MATR475Enc() se valida la existencia de³±±
±±³            ³        ³          ³nodo _CFDI_CFDIRELACIONADO                    ³±±
±±³Oscar Garcia³25/03/21³DMINA-    ³Ajuste en fun. MTR475CanL() para tratamiento  ³±±
±±³            ³        ³     11641³de Notas de Crédito.(MEX)                     ³±±
±±³Oscar Garcia³05/04/21³DMINA-    ³Ajuste en fun. MTR475CanL() para enviar param.³±±
±±³            ³        ³     12005³a fun. Extenso() segun lenguaje de RPO.(MEX)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR475()

	Local cPerg			:= "MTR475"
	Local cQuery		:= ""
	Local cEspecie		:= ""
	Local cTipoFact		:= ""
	Local nNumRegs		:= 0
	Local nNumDocImp	:= 0
	Local lTabSF2		:= .T.
	Local lVisualPDF	:= .F.
	Local cAliasQry		:= GetNextAlias()
	Local lImpPer		:= ExistBlock("M475IMPPER")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variables utilizadas como parámetros                  ³
	//³ mv_par01 - Tipo de Documento: NF, NDC y NCC           ³
	//³ mv_par02 - Tipo de Factura: Normal, Traslado y Ambas  ³
	//³ mv_par03 - De fecha                                   ³
	//³ mv_par04 - A Fecha                                    ³
	//³ mv_par05 - De Serie                                   ³
	//³ mv_par06 - A Serie                                    ³
	//³ mv_par07 - De Documento                               ³
	//³ mv_par08 - A Documento                                ³
	//³ mv_par09 - Imprime Timbrados: Si, No y Ambos          ³
	//³ mv_par10 - Visualizar PDF: Si y No                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Pergunte(cPerg,.T.)
		Return
	Endif

	If MV_PAR01 == 1 //Factura de Venta
		cEspecie := "NF"
	ElseIf MV_PAR01 == 2 //Nota de Debito
		cEspecie := "NDC"
	ElseIf MV_PAR01 == 3 //Nota de Credito
		cEspecie := "NCC"
		lTabSF2 := .F.
	EndIf

	If MV_PAR02 == 1 //Factura Normal
		cTipoFact := "01"
	ElseIf MV_PAR02 == 2 //Factura de Traslado
		cTipoFact := "21"
	ElseIf MV_PAR02 == 3 //Ambas
		cTipoFact := "'01', '21'"
	EndIf
	
	If MV_PAR10 == 1
		lVisualPDF := .T.
	EndIf

	If MV_PAR01 == 1 .Or. MV_PAR01 == 2
		cQuery := "SELECT R_E_C_N_O_ RECNO "
		cQuery += "FROM " + RetSqlName('SF2') + " SF2 "
		cQuery += "WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
		cQuery += "AND F2_ESPECIE = '" + cEspecie + "' "
		If MV_PAR01 == 1 //Facturas
			If MV_PAR02 == 1 //Factura Normal
				cQuery += "AND F2_TIPODOC = '" + cTipoFact + "' "
			ElseIf MV_PAR02 == 2 //Factura de Traslado
				cQuery += "AND F2_TIPODOC = '" + cTipoFact + "' "
			ElseIf MV_PAR02 == 3 //Ambas
				cQuery += "AND F2_TIPODOC IN (" + cTipoFact + ") "
			EndIf
		EndIf
		cQuery += "AND F2_EMISSAO >= '" + DTOS(MV_PAR03) + "' "
		cQuery += "AND F2_EMISSAO <= '" + DTOS(MV_PAR04) + "' "
		cQuery += "AND F2_SERIE >= '" + MV_PAR05 + "' "
		cQuery += "AND F2_SERIE <= '" + MV_PAR06 + "' "
		cQuery += "AND F2_DOC >= '" + MV_PAR07 + "' "
		cQuery += "AND F2_DOC <= '" + MV_PAR08 + "' "
		If MV_PAR09 == 1 //Documentos Timbrados
			cQuery += "AND F2_UUID <> '' "
			cQuery += "AND F2_FECTIMB <> '' "
		ElseIf MV_PAR09 == 2 //Documentos sin Timbre
			cQuery += "AND F2_UUID = '' "
			cQuery += "AND F2_FECTIMB = '' "
		EndIf
		cQuery += "AND SF2.D_E_L_E_T_= ' ' "
		cQuery += "ORDER BY F2_SERIE, F2_DOC"
	Else
		cQuery := "SELECT R_E_C_N_O_ RECNO "
		cQuery += "FROM " + RetSqlName('SF1') + " SF1 "
		cQuery += "WHERE F1_FILIAL = '" + xFilial("SF1") + "' "
		cQuery += "AND F1_ESPECIE = '" + cEspecie + "' "
		cQuery += "AND F1_EMISSAO >= '" + DTOS(MV_PAR03) + "' "
		cQuery += "AND F1_EMISSAO <= '" + DTOS(MV_PAR04) + "' "
		cQuery += "AND F1_SERIE >= '" + MV_PAR05 + "' "
		cQuery += "AND F1_SERIE <= '" + MV_PAR06 + "' "
		cQuery += "AND F1_DOC >= '" + MV_PAR07 + "' "
		cQuery += "AND F1_DOC <= '" + MV_PAR08 + "' "
		If MV_PAR09 == 1 //Documentos Timbrados
			cQuery += "AND F1_UUID <> '' "
			cQuery += "AND F1_FECTIMB <> '' "
		ElseIf MV_PAR09 == 2 //Documentos sin Timbre
			cQuery += "AND F1_FECTIMB = '' "
			cQuery += "AND F1_FECTIMB = '' "
		EndIf
		cQuery += "AND SF1.D_E_L_E_T_= ' ' "
		cQuery += "ORDER BY F1_SERIE, F1_DOC"
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasQry, .T., .T.)

	Count to nNumRegs
	
	If nNumRegs > 0
		(cAliasQry)->(DBGoTop()) //Se posiciona en el primer registro de la tabla
		
		If lTabSF2 //NF, NF Traslado y NDC
			DBSelectArea("SF2")
		Else //Nota de Credito
			DBSelectArea("SF1")
		EndIf
		
		While (cAliasQry)->(!Eof())
			nNumDocImp++
			
			If lTabSF2 //NF, NF Traslado y NDC
				SF2->(DBGoTo((cAliasQry)->RECNO))
				If lImpPer //PE para impresion de formato personalizado
					Processa({ |lEnd| ExecBlock("M475IMPPER",.F.,.F.,{SF2->F2_ESPECIE, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_TIPODOC, SF2->F2_CLIENTE, SF2->F2_LOJA, lVisualPDF})}, STR0053 + AllTrim(Str(nNumDocImp)) + "/" + AllTrim(Str(nNumRegs))) //"Imprimiendo documentos... "
                Else
                	Processa({ |lEnd| MATR475Gen(SF2->F2_ESPECIE, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_TIPODOC, SF2->F2_CLIENTE, SF2->F2_LOJA, lVisualPDF)}, STR0053 + AllTrim(Str(nNumDocImp)) + "/" + AllTrim(Str(nNumRegs))) //"Imprimiendo documentos... "
				EndIf
			Else //Nota de Credito
				SF1->(DBGoTo((cAliasQry)->RECNO))
				If lImpPer //PE para impresion de formato personalizado
					Processa({ |lEnd| ExecBlock("M475IMPPER",.F.,.F.,{SF1->F1_ESPECIE, SF1->F1_SERIE, SF1->F1_DOC, SF1->F1_TIPODOC, SF1->F1_FORNECE, SF1->F1_LOJA, lVisualPDF})}, STR0053 + AllTrim(Str(nNumDocImp)) + "/" + AllTrim(Str(nNumRegs))) //"Imprimiendo documentos... "
				Else
					Processa({ |lEnd| MATR475Gen(SF1->F1_ESPECIE, SF1->F1_SERIE, SF1->F1_DOC, SF1->F1_TIPODOC, SF1->F1_FORNECE, SF1->F1_LOJA, lVisualPDF)}, STR0053 + AllTrim(Str(nNumDocImp)) + "/" + AllTrim(Str(nNumRegs))) //"Imprimiendo documentos... "
				EndIf
			EndIf
			(cAliasQry)->(DBSkip())
		EndDo
	Else
		MsgInfo(STR0001) //"No se encontraron coincidencias con los parámetros informados, modifiquelos e intente nuevamente."
	EndIf
	
	(cAliasQry)->(DBCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR475Gen³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de PDF para Documentos Fiscales de Entrada/Salida.      ³±±
±±³          ³ Mediante rutina automatica o rutina manual.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR475Gen(ExpC1, ExpC2, ExpC3, ExpC4, ExpC5, ExpC6, ExpC7, ExpL1) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Especie del Documento (NF, NDC y NCC)                      ³±±
±±³          ³ ExpC2 = Serie del Documento                                        ³±±
±±³          ³ ExpC3 = Folio del Documento                                        ³±±
±±³          ³ ExpC4 = Tipo de Documento                                          ³±±
±±³          ³ ExpC5 = Cliente del Documento                                      ³±±
±±³          ³ ExpC6 = Tienda del Documento                                       ³±±
±±³          ³ ExpL1 = Informa si visualizara PDF tras Impresion.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATR475, MATA467N, MATA468N y MATA465N.                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR475Gen(cEspecie, cSerie, cNumDoc, cTipoDoc, cCliente, cTienda, lVisualPDF)

	Local aArea			:= GetArea()
	Local oXml			:= Nil
	Local cDirClient	:= GetClientDir()+ "pdf\"

	Private cFileName	:= ""
	Private nLin		:= 500
	Private oPrint		:= 	Nil
	Private cPathDocs	:= &(SuperGetmv("MV_CFDDOCS", .F., "\cfd\facturas\")) // Ruta donde se encuentran las facturas.xml (servidor)
	
	//Declaracion de variables privadas para mantenerlas hasta el final del proceso.
	Private cParamEspD	:= cEspecie		//Parametro para Especie de Documento
	Private cParamSerD	:= cSerie		//Parametro para Serie de Documento
	Private cParamDocD	:= cNumDoc		//Parametro para Folio de Documento
	Private cParamTpoD	:= cTipoDoc		//Parametro para Tipo de Documento
	Private cParamCliD	:= cCliente		//Parametro para Cliente de Documento
	Private cParamLojD	:= cTienda		//Parametro para Tienda de Documento

	cFileName := Lower(AllTrim(cParamEspD)) + '_' + Lower(AllTrim(cParamSerD)) + '_' + Lower(AllTrim(cParamDocD)) //Nombre de Archivo, en base a nomenclatura del archivo XML.
	
	If !ExistDir(cDirClient) //Valida que exista directorio auxiliar para crear PDF
		MakeDir(cDirClient)
	EndIf
	
	If File(cDirClient + cFileName + ".pdf") //Si existe una version impresa del Comprobante Fiscal, se elimina. (Directorio Auxiliar)
		FErase(cDirClient + cFileName + ".pdf")
	Endif
	
	If File(cPathDocs + cFileName + ".pdf") //Si existe una version impresa del Comprobante Fiscal, se elimina. (Directorio MV_CFDDOCS)
		FErase(cPathDocs + cFileName + ".pdf")
	Endif
	
	/*
	FWMsPrinter(): New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] ) --> oPrinter 
	------------------|---------------|------------------------------------------------------------------------------------------------------------------------
	Nombre				Tipo			Descripción
	------------------|---------------|------------------------------------------------------------------------------------------------------------------------
	cFilePrintert		Caracter		Nome do arquivo de relatório a ser criado. 	X 	
	nDevice				Numérico		Tipos de Saída aceitos: IMP_SPOOL Envia para impressora. IMP_PDF Gera arquivo PDF à partir do relatório. Default é IMP_SPOOL 		
	lAdjustToLegacy		Lógico			Se .T. recalcula as coordenadas para manter o legado de proporções com a classe TMSPrinter. Default é .T. IMPORTANTE: Este cálculos não funcionam corretamente quando houver retângulos do tipo BOX e FILLRECT no relatório, podendo haver distorções de algumas pixels o que acarretará no encavalamento dos retângulos no momento da impressão. 		
	cPathInServer		Caracter		Diretório onde o arquivo de relatório será salvo 		
	lDisabeSetup		Lógico			Se .T. não exibe a tela de Setup, ficando à cargo do programador definir quando e se será feita sua chamada. Default é .F. 		
	lTReport			Lógico			Indica que a classe foi chamada pelo TReport. Default é .F. 		
	oPrintSetup			Objeto			Objeto FWPrintSetup instanciado pelo usuário. 		X
	cPrinter			Caracter		Impressora destino "forçada" pelo usuário. Default é "" 		
	lServer				Lógico			Indica impressão via Server (.REL Não será copiado para o Client). Default é .F. 		
	lPDFAsPNG			Lógico			.T. Indica que será gerado o PDF no formato PNG. O Default é .T. 		
	lRaw				Lógico			.T. indica impressão RAW/PCL, enviando para o dispositivo de impressão caracteres binários(RAW) ou caracteres programáveis específicos da impressora(PCL) 
	------------------|---------------|------------------------------------------------------------------------------------------------------------------------
	*/
	
	oPrint := FWMsPrinter():New(AllTrim(cFileName) + ".pdf", 6, .T., , .T.)
	oPrint:SetViewPDF(lVisualPDF) //Define si se visualiza PDF
	oPrint:SetResolution(72)
	oPrint:SetPortrait()
	oPrint:SetPaperSize(1)
	oPrint:cPathPDF := cDirClient

	oXml := MATR475Xml() //Genera objeto a partir del XML del documento

	If oXml == Nil
		FreeObj(oPrint)
		Return .F.
	EndIf

	MATR575Imp(oXml) //Realiza Impresion de PDF
	
	nLin := 0
	
	oPrint:Print()
	COPY FILE (cDirClient + cFileName + ".pdf") TO (cPathDocs + cFileName + ".pdf")

	FreeObj(oPrint)
	oPrint := Nil
	FreeObj(oXml)
	oXml := Nil

	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR475Xml³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de PDF para Documentos Fiscales de Entrada/Salida.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR475Xml()

	Local cPathXML	:= ""
	Local cAviso	:= ""
	Local cErro		:= ""
	Local oXml		:= Nil

	cPathXML := cPathDocs + cFileName + '.xml'

	If !File(cPathXML)
		MsgAlert(STR0002 + AllTrim(cParamSerD) + "-" + AllTrim(cParamDocD) + STR0003) //"El archivo XML del documento: " - " no fué localizado. No será posible realizar la impresión del mismo."
		Return Nil
	EndIf

	oXml := XmlParserFile(cPathXML, "_", @cAviso,@cErro )

	If !Empty(cAviso) .Or. !Empty(cErro)
		MsgAlert(STR0004 + Chr(13)+Chr(10) + Upper(cAviso) + Chr(13)+Chr(10) + Upper(cErro)) //"Se detectaron problemas con el archivo XML: "
		Return(Nil)
	EndIf	

Return oXml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR575Imp³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de PDF para Documentos Fiscales de Entrada/Salida.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR575Imp(oXml)

	Private nPagNum		:= 1		// Indica el número de página actual.

	Private	 nEmiY 		:= 80		// Coordenadas de línea en donde inician los datos del emisor
	Private	 nFacX		:= 1700   	// Columna de inicio de datos de factura en encabezado
	Private nFacY		:= 80		// Línea de inicio de datos de factura en enabezado
	Private nCliX		:= 100		// Columna de inicio de datos del cliente en encabezado
	Private nCliY		:= 330		// Línea de inicio de datos del cliente en encabezado

	Private nDetX		:= 100 		// Columna de inicio de datos del detalle de la factura
	Private nDetCPX		:= 80 		// Columna de inicio de datos del detalle de la Carta Porte
	Private nDetY		:= 600		// Línea de inicio de datos del detalle de la factura.
	Private nTamSalto	:= 30		// Tamaño del salto

	// Fuentes
	Private oAr07R  	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
	Private oAr08R  	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	Private oAr09B  	:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
	Private oAr10R  	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	Private oAr10B  	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	Private oAr12B  	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
	Private oAr14B  	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	
	//Datos del Documento
	Private cCerEmi		:= ""
	
	//Datos del Emisor
	Private	 cRFCEmisor	:= ""
	Private cNomEmisor	:= ""
	Private cRegFisEmi	:= ""
	
	//Datos del Receptor
	Private	 cUsoCFDI	:= ""
	Private cDesUsoCFD	:= ""
	Private cClientNom	:= ""
	Private cClientRFC	:= ""
	
	//Totales del documento
	Private cTotalDocu	:= ""
	Private nDescTot	:= 0
	Private cSubTot		:= ""
	Private nSubTot		:= ""
	
	Default oXml		:= Nil

	oPrint:StartPage() //Inicia nueva Pagina

	MATR475Enc(oXml) //Imprimir Encabezado de Documento
	MATR475Det(oXml) //Imprimir Detalle de Documento
	MATR475Pie(oXml) //Imprimir Pie de Documento
	MR475DETCP(oXml) //Imprimir Complento de Carta Porte

	oPrint:EndPage()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR475Enc³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de PDF para Documentos Fiscales de Entrada/Salida.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR475Enc(oXml)

	Local cFileLogoR	:=  GetSrvProfString("Startpath","") + "lgrl.bmp" // Logo
	Local cFranja		:=  GetSrvProfString("Startpath","") + "Franja_factura10.bmp" // Franja de fondo de la factura
	
	// Datos de la Factura
	Local cFolio		:= ""
	Local cFechaXml		:= ""
	Local cFechaFac		:= ""
	Local cUUIDRel		:= ""
	Local cTpoRelSAT	:= ""
	Local cTpoCompro	:= ""
	Local cDescCompr	:= ""
	Local cLugarExpe	:= ""
	Local cTpoForPgo	:= ""
	Local cDesForPgo	:= ""
	Local cMetodoPgo	:= ""
	Local cDesMtdPgo	:= ""
	Local nLinSal 		:= 0
	// Datos del Cliente - genericos
	Local cClientDir	:= ""
	Local cClientCol	:= ""
	Local cCliNumExt	:= "S/N"
	Local cCliNumInt	:= "S/N"
	Local cClientMun	:= ""
	Local cClientEst	:= ""
	Local cClientPai	:= ""
	Local cClienteCP	:= ""
	Local cUUidsal 		:= ""
	Local nX 			:= 0
	Local nY            := 0
	Local aUUIdsal 		:= {}
	Local aCfdiRelac     := {}
	Local nSalto		:= 0
	
	// Datos del Timbrado Fiscal Digital
	Local cFechaTim		:= STR0005 // Fecha del Timbre Fiscal Digital		//"-- Sin Timbre Fiscal Digital --"
	Local cVerTim		:= STR0006 // Versión del Timbre Fiscal Digital		//"Documento Inválido."
	Local cUUIDTim		:= STR0006 // Folio Fiscal							//"Documento Inválido."
	Local cCerTim		:= STR0006 // No. Certificado Timbre Fiscal Digital	//"Documento Inválido."
	
	//Valida que exista atributo Folio Fiscal
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_FOLIO") <> Nil
		cFolio := OemToAnsi(oXml:_CFDI_COMPROBANTE:_FOLIO:TEXT)
	EndIf
	//Valida que exista atributo Fecha
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_FECHA") <> Nil
		cFechaXml := oXml:_CFDI_COMPROBANTE:_FECHA:TEXT
		cFechaFac := SubStr(cFechaXml,9,2)+"/"+SubStr(cFechaXml,6,2)+"/"+SubStr(cFechaXml,1,4)+" "+SubStr(cFechaXml,12,8)
	EndIf
	//Valida que exista atributo Tipo de Comprobante
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_TIPODECOMPROBANTE") <> Nil
		cTpoCompro := oXml:_CFDI_COMPROBANTE:_TIPODECOMPROBANTE:TEXT
	EndIf
	//Valida que exista atributo Lugar de Expedicion
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_LUGAREXPEDICION") <> Nil
		cLugarExpe := oXml:_CFDI_COMPROBANTE:_LUGAREXPEDICION:TEXT
	EndIf
	//Valida que exista atributo Total
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_TOTAL") <> Nil
		cTotalDocu := oXml:_CFDI_COMPROBANTE:_TOTAL:TEXT
	EndIf
	//Valida que exista atributo Descuento
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_DESCUENTO") <> Nil
		nDescTot := Val(OemToAnsi(oXml:_CFDI_COMPROBANTE:_DESCUENTO:TEXT))
	EndIf
	//Valida que exista atributo SubTotal
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_SUBTOTAL") <> Nil
		cSubTot := Transform(Val(OemToAnsi(oXML:_CFDI_COMPROBANTE:_SUBTOTAL:TEXT)),"999,999,999.99")
		nSubTot := Val(OemToAnsi(oXML:_CFDI_COMPROBANTE:_SUBTOTAL:TEXT))
	EndIf
	//Valida que exista atributo Numero de Certificado
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_NOCERTIFICADO") <> Nil
		cCerEmi := OemToAnsi(oXml:_CFDI_COMPROBANTE:_NOCERTIFICADO:TEXT)
	EndIf
	
	//Valida que exista Nodo con Informacion del Emisor
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_EMISOR") <> Nil
		cRFCEmisor := oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT
		cNomEmisor := oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_NOMBRE:TEXT
		cRegFisEmi := oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_REGIMENFISCAL:TEXT
	EndIf
	
	//Valida que exista Nodo con Informacion del Receptor
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_RECEPTOR") <> Nil
		cUsoCFDI := oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_USOCFDI:TEXT
		cDesUsoCFD := ObtColSAT("S013",AllTrim(cUsoCFDI),1,3,4,90)
		cClientNom := MTR475CarE(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_NOMBRE:TEXT)
		cClientRFC := MTR475CarE(AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT))
	EndIf	
	
	//Valida que exista Nodo de UUID Relacionados
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_CFDIRELACIONADOS") <> Nil
		If ValType(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS) == "A"
			For nY := 1 To Len(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS)
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS[nY], "_CFDI_CFDIRELACIONADO") <> Nil
					cTpoRelSAT := oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS[nY]:_TIPORELACION:TEXT
					IF ValType(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS[nY]:_CFDI_CFDIRELACIONADO) == "A"
						For nX := 1 To Len(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS[nY]:_CFDI_CFDIRELACIONADO)
							cUUidsal := &("oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS[" + Str(nY) + "]:_CFDI_CFDIRELACIONADO[" + Str(nX) + "]:_UUID:TEXT")
							aadd(aUUIdsal,cUUidsal)
						Next nX
					EndIf
					If Len(aUUIdsal) > 0
						Aadd(aCfdiRelac, {cTpoRelSat,aUUIdsal})
					Else
						Aadd(aCfdiRelac, {cTpoRelSat,{oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS[nY]:_CFDI_CFDIRELACIONADO:_UUID:TEXT}})
					Endif
					aUUIdsal := {}
					cTpoRelSAT := ""
				EndIf
			Next nY
		Else
			If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS, "_CFDI_CFDIRELACIONADO") <> Nil
				cTpoRelSAT := oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_TIPORELACION:TEXT
				IF ValType(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_CFDI_CFDIRELACIONADO) == "A"
					For nX := 1 To Len(oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_CFDI_CFDIRELACIONADO)
						cUUidsal := &("oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_CFDI_CFDIRELACIONADO[" + Str(nX) + "]:_UUID:TEXT")
						aadd(aUUIdsal,cUUidsal)
					Next nX
				EndIf
				If Len(aUUIdsal) > 0
					Aadd(aCfdiRelac, {cTpoRelSat,aUUIdsal})
				Else
					Aadd(aCfdiRelac, {cTpoRelSat,{oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_CFDI_CFDIRELACIONADO:_UUID:TEXT}})
				Endif
			EndIf
		Endif
	EndIf
	
	If AllTrim(cParamTpoD) != "21"
		cTpoForPgo := oXml:_CFDI_COMPROBANTE:_FORMAPAGO:TEXT
		cDesForPgo := ObtColSAT("S005",AllTrim(cTpoForPgo),1,2,3,40)
		cMetodoPgo := oXml:_CFDI_COMPROBANTE:_METODOPAGO:TEXT
		cDesMtdPgo := ObtColSAT("S007",AllTrim(cMetodoPgo),1,3,4,38)
	EndIf
	
	If nPagNum == 1
		If cTpoCompro == "I"
			cDescCompr := STR0007 //"Ingreso"
		ElseIf cTpoCompro == "E"
			cDescCompr := STR0008 //"Egreso"
		ElseIf cTpoCompro == "T"
			cDescCompr := STR0009 //"Traslado"
		EndIf
	EndIf

	// Verificar si está timbrado para obtener fecha del TFD.
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO") <> Nil
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO, "_TFD_TIMBREFISCALDIGITAL") <> Nil
			cFechaTim 	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
			cFechaTim	:= (SubStr(cFechaTim, 9, 2) + "/" + SubStr(cFechaTim, 6, 2) + "/" + SubStr(cFechaTim, 1, 4) + " " + SubStr(cFechaTim, 12, 8))
			cVerTim 	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_VERSION:TEXT
			cUUIDTim 	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			cCerTim 	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
		EndIf
	EndIf

	DBSelectArea("SA1")
	SA1->(DBSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(MsSeek(xFilial("SA1") + cParamCliD + cParamLojD))
		cClientDir	:= RTrim(SA1->A1_END)
		cCliNumExt	:= AllTrim(SA1->A1_NR_END)
		cCliNumInt	:= AllTrim(SA1->A1_NROINT)
		cClientCol	:= Rtrim(SA1->A1_BAIRRO)
		cClientMun	:= RTrim(SA1->A1_MUN)
		cClientEst	:= RTrim(SA1->A1_ESTADO)
		cClientPai	:= RTrim(Posicione("SYA", 1, xFilial("SYA")+SA1->A1_PAIS, "YA_DESCR"))
		cClienteCP	:= AllTrim(SA1->A1_CEP)
	Else
		MsgInfo(STR0054 + cParamSerD + " - " +  cParamDocD) //"No se ha encontrado el Cliente utilizado en el Documento Fiscal: "
	EndIf

	// Imprimir Logo de emisor
	// ---------------------------------------------------------------------
	oPrint:SayBitmap(85	, 100	, cFileLogoR	, 200, 200	) //y, x, archivo, ancho, alto
	oPrint:SayBitmap(1	, 1750	, cFranja		, 565, 3050	) //y, x, archivo, ancho, alto

	// Datos de la empresa
	// ---------------------------------------------------------------------
	oPrint:SayAlign(nEmiY					, 1, UTf8ToChr(cNomEmisor)									, oAr12B, 2300, 70, , 2, 0)
	oPrint:SayAlign(nEmiY + (nTamSalto*1)	, 1, RTRIM(SM0->M0_ENDENT) + ", " + RTRIM(SM0->M0_BAIRENT)	, oAr10R, 2300, 70, , 2, 0)
	oPrint:SayAlign(nEmiY + (nTamSalto*2)	, 1, RTRIM(SM0->M0_CIDENT) + ", " + RTRIM(SM0->M0_CEPENT)	, oAr10R, 2300, 70, , 2, 0)
	oPrint:SayAlign(nEmiY + (nTamSalto*3)	, 1, "R.F.C. " + cRFCEmisor									, oAr10R, 2300, 70, , 2, 0)

	// Layout del encabezado
	// -----------------------------------------------------------------------	
	If AllTrim(cParamEspD) == "NF" //Factura
		oPrint:SayAlign(nFacY - 40	, nFacX, STR0010, oAr14B, 500, 50, , 2, 0) //"FACTURA"
		oPrint:SayAlign(nFacY		, nFacX, STR0011, oAr12B, 500, 50, , 2, 0) //"SERIE/FOLIO INTERNO"
	ElseIf AllTrim(cParamEspD) == "NDC" //Nota de Debito
		oPrint:SayAlign(nFacY - 40	, nFacX, STR0012, oAr14B, 500, 50, , 2, 0) //"NOTA DE CARGO"
		oPrint:SayAlign(nFacY		, nFacX, STR0011, oAr12B, 500, 50, , 2, 0) //"SERIE/FOLIO INTERNO"
	ElseIf AllTrim(cParamEspD) == "NCC" //Nota de Credito
		oPrint:SayAlign(nFacY - 40	, nFacX, STR0013, oAr14B, 500, 50, , 2, 0) //"NOTA DE CRÉDITO"
		oPrint:SayAlign(nFacY		, nFacX, STR0011, oAr12B, 500, 50, , 2, 0) //"SERIE/FOLIO INTERNO"
	EndIf

	oPrint:SayAlign(nFacY + (nTamSalto*1)	, nFacX, AllTrim(cParamSerD) + " - " + AllTrim(cFolio)	, oAr10R, 500, 30, , 2, 0)
	oPrint:SayAlign(nFacY + (nTamSalto*3)	, nFacX, STR0014 + cFechaFac 							, oAr10B, 500, 30, , 2, 0) //"Fecha de emisión: "
	oPrint:SayAlign(nFacY + (nTamSalto*5)	, nFacX, STR0015 + "(" + cTpoCompro + ") " + cDescCompr	, oAr10R, 500, 30, , 2, 0) //"Tipo de Comprobante: "

	oPrint:Line(nFacY + (nTamSalto*8), 100, nFacY + (nTamSalto*8), 2200)

	// Datos del Receptor
	oPrint:Say(nCliY + (nTamSalto*1)	, nCliX + 20, UTf8ToChr(cClientNom)															        , oAr12B, , CLR_BLACK, , 2)
	oPrint:Say(nCliY + (nTamSalto*3)	, nCliX + 20, STR0016 + cClientRFC															, oAr10R, , CLR_BLACK, , 2) //"RFC: "
	oPrint:Say(nCliY + (nTamSalto*4)	, nCliX + 20, STR0017																		, oAr10R, , CLR_BLACK, , 2) //"Domicilio: "
	oPrint:Say(nCliY + (nTamSalto*5)	, nCliX + 20, cClientDir + STR0018 + cCliNumExt + "-" + cCliNumInt + STR0019 + cClientCol	, oAr10R, , CLR_BLACK, , 2) //" No. " - " Col. "
	oPrint:Say(nCliY + (nTamSalto*6)	, nCliX + 20, STR0020 + cClientMun + ", " + STR0021 + cClienteCP							, oAr10R, , CLR_BLACK, , 2) //"Municipio " - "C.P. "
	oPrint:Say(nCliY + (nTamSalto*7)	, nCliX + 20, STR0022 + cUsoCFDI + " - " + RTrim(cDesUsoCFD)								, oAr10R, , CLR_BLACK, , 2) //"Uso del CFDI: "
	If Len(aCfdiRelac) > 0 
		nSalto := 8
		For nY := 1 To Len(aCfdiRelac)
			For nX := 1 To Len(aCfdiRelac[nY][2])
				oPrint:Say(nCliY + (nTamSalto*nSalto), nCliX + 20, IIf(nX == 1,STR0023,Space(Len(STR0023)+17)) + aCfdiRelac[nY][2][nX]	, oAr10R, , CLR_BLACK, , 2) //"UUID CFDI relacionado: "
				nSalto += 1
			Next nX
			oPrint:Say(nCliY + (nTamSalto*nSalto), nCliX + 20, STR0024 + aCfdiRelac[nY][1]	, oAr10R, , CLR_BLACK, , 2) //"Tipo de Relacion: "
			nSalto += 2
		Next nY
	EndIf
	// Folio Fiscal
	oPrint:Say(nCliY					, nCliX			, ""		, oAr08R, , CLR_BLACK, , 2)
	oPrint:Say(nCliY + (nTamSalto*1)	, nCliX + 1500	, STR0025	, oAr12B, , CLR_BLACK, , 2) //"Folio fiscal"
	oPrint:Say(nCliY + (nTamSalto*2)	, nCliX + 1500	, cUUIDTim	, oAr10R, , CLR_BLACK, , 2)

	// Lugar de expedición
	oPrint:Say(nCliY					, nCliX			, ""												, oAr08R, , CLR_BLACK, , 2)
	nLinSal := 6
	If AllTrim(cParamTpoD) != "21"
		oPrint:Say(nCliY + (nTamSalto * nLinSal), nCliX + 1500	, STR0026	, oAr10R, , CLR_BLACK, , 2) //"Forma de Pago: "
		F815LinCar(oPrint,nCliY + (nTamSalto * nLinSal),nCliX + 1680, cTpoForPgo + " - " + RTrim(cDesForPgo), 31, 20, 2, oAr10R,@nLinSal)	
		nLinSal := nLinSal + 6
	EndIf
	nLinSal := nLinSal + 1
	oPrint:Say(nCliY + (nTamSalto * nLinSal)	, nCliX + 1500	, STR0027 + cLugarExpe								, oAr10R, , CLR_BLACK, , 2) //"Lugar de Expedición: "
	If AllTrim(cParamTpoD) != "21"
		nLinSal := nLinSal + 1
		oPrint:Say(nCliY + (nTamSalto * nLinSal), nCliX + 1500	, STR0028 + cMetodoPgo + " - " + RTrim(cDesMtdPgo)	, oAr10R, , CLR_BLACK, , 2) //"Método de Pago: "
	EndIf
	nLinSal := nLinSal + 1
	oPrint:Say(nCliY + (nTamSalto * nLinSal)	, nCliX + 1500	, STR0029 + cRegFisEmi + " - " + ObtColSAT("S010",cRegFisEmi,1,3,4,80) 	, oAr10R, , CLR_BLACK, , 2) //"Régimen Fiscal: "
	
	If nSalto > 0
		nDetY := nCliY + (nTamSalto*nSalto+2)
	EndIF
	// Encabezado de las columnas de datos de los Productos.
	oPrint:Say(nDetY + (nTamSalto*2),	nDetX,"",oAr09B,,CLR_BLACK,,2)
	
	oPrint:SayAlign(nDetY + (nTamSalto*3), nDetX		, STR0030 , oAr12B, 200		, 60, , 2, 0) //"Cantidad"
	oPrint:SayAlign(nDetY + (nTamSalto*3), nDetX + 200	, STR0031 , oAr12B, 200		, 60, , 2, 0) //"Unidad"
	oPrint:SayAlign(nDetY + (nTamSalto*3), nDetX + 400	, STR0032 , oAr12B, 1000	, 60, , 2, 0) //"Concepto"
	oPrint:SayAlign(nDetY + (nTamSalto*3), nDetX + 1400	, STR0033 , oAr12B, 300		, 60, , 2, 0) //"P.Unitario"
	oPrint:SayAlign(nDetY + (nTamSalto*3), nDetX + 1700	, STR0034 , oAr12B, 300		, 60, , 2, 0) //"Importe"

	oPrint:Line(nDetY+(nTamSalto*4)+15,100,nDetY+(nTamSalto*4)+15,2200)
	hdrHeight := (nTamSalto*4)	
	nFall := 4
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR475Det³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de PDF para Documentos Fiscales de Entrada/Salida.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR475Det(oXml)

	Local nCurLine		:= nDetY
	Local nCurItem		:= 1
	Local nFall			:= 4
	Local nSaltoItem	:= 35	// Salto entre items
  	Local nItems		:= 0
  	Local cPagina		:= AllTrim(Str(oPrint:nPageCount))
  	Local aItems		:= {}
  	Local nIteration	:= 0
  	
  	// Datos del detalle
  	Local cCantiItem	:= "" //Cantidad Item	
  	Local cUnidaItem	:= "" //Unitad Item
  	Local cConceItem	:= "" //Concepto Item
  	Local cValUniItm	:= "" //Valor Unitario Item
  	Local cImporItem	:= "" //Importe Item
  	
  	// Quiebre de Textos
  	Local _lQuebra 	:= .F.
  	Local _nQuebra	:= 0
  	Local _nX		:= 0
  	Local _nTam		:= 0
  	
  	//Valida que exista Nodo de UUID Relacionados
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_CONCEPTOS") <> Nil
		If ValType(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO) == "A"
			aItems := aAdd(aItems, {oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO})
			nItems := Len(aItems[1])
		Else
			nItems := 1
		EndIf
	Else
		nItems := 1
	EndIf
	
	For nIteration := 1 To nItems
		
		If (nCurLine > 1900) // Se define el tamano maximo que tendran la seccion de items.
			oPrint:SayAlign(3000, 1750, STR0050 + cPagina	, oAr10R, 550, 30, , 2, 0) //"Pagina: "
			MTR475NewP(oXml)
			hdrHeight := (nTamSalto*2)
			nFall := 4
			nCurLine := nDetY
		EndIf
		
		//Datos del cuerpo de la factura  	  
		If nItems > 1 // Mas de un producto por documento fiscal
			cCantiItem := Transform(Val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO[nIteration]:_CANTIDAD:TEXT),"999,999.99")
			cUnidaItem := oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO[nIteration]:_UNIDAD:TEXT
			cConceItem := UTf8ToChr(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO[nIteration]:_DESCRIPCION:TEXT)
			cValUniItm := ALLTRIM(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO[nIteration]:_VALORUNITARIO:TEXT)
			cImporItem := Transform(Val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO[nIteration]:_IMPORTE:TEXT),"999,999,999.99")
		Else
			cCantiItem := Transform(Val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_CANTIDAD:TEXT),"999,999.99")
			cUnidaItem := oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_UNIDAD:TEXT
			cConceItem := UTf8ToChr(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_DESCRIPCION:TEXT)
			cValUniItm := ALLTRIM(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_VALORUNITARIO:TEXT)
			cImporItem := Transform(Val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_IMPORTE:TEXT),"999,999,999.99")
		EndIf
		
		//Salto de Linea para los Productos
		If Len(AllTrim(cConceItem)) > 80 // Valida que la descripcion del producto sea de 80 caracteres
			_lQuebra := .T.
			
			If Mod(Len(AllTrim(cConceItem)), 80) == 0
				_nQuebra := Len(AllTrim(cConceItem)) / 80
			Else	
				_nQuebra := Int((Len(AllTrim(cConceItem)))/80) + 1			
			EndIf
		EndIf
		// Resaliza saldo de linea en base al tamano de descripcion del producto (80)
		If _lQuebra
			oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX		, cCantiItem, oAr10R, 200, 30, , 1, 0)
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX+200	, cUnidaItem, oAr10R, 200, 30, , 2, 0)
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX+1400	, cValUniItm, oAr10R, 300, 30, , 1, 0)
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX+1700	, cImporItem, oAr10R, 300, 30, , 1, 0)
		    
		    For _nX := 1 To _nQuebra
		    	If _nX == 1
		    		_nTam := 1
		    	Else
		    		_nTam := ((_nX - 1) * 80) + 1
		    		nFall ++
		    	EndIf	
		    	oPrint:SayAlign(nDetY+(nSaltoItem*nFall),	nDetX+400,	SubStr(cConceItem,_nTam,80),	oAr10R,1500	,30,,0,0)
		    Next _nX			
		Else			   
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX		, cCantiItem, oAr10R, 200	, 30, , 1, 0)
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX+200	, cUnidaItem, oAr10R, 200	, 30, , 2, 0)
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX+400	, cConceItem, oAr10R, 1500	, 30, , 0, 0)
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX+1400	, cValUniItm, oAr10R, 300	, 30, , 1, 0)
		    oPrint:SayAlign(nDetY + (nSaltoItem*nFall),	nDetX+1700	, cImporItem, oAr10R, 300	, 30, , 1, 0)
	   	EndIf

		nCurLine += nSaltoItem
   		
   		nCurItem++
		nFall++
		_lQuebra := .F.
	Next nIteration
	
	nCurLine += 10

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR475Pie³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de PDF para Documentos Fiscales de Entrada/Salida.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR475Pie(oXml)

	Local nFall			:= 1
	Local nCadLn		:= 0
	Local cCadOrig 		:= ""
	Local cImpEnLetr	:= ""
	Local cTotal		:= ""
	Local cTasaCuota	:= ""
	Local cImporTras	:= ""
	Local aImpTras      := {}
	Local cImporRete	:= ""
	Local nFotX			:= 100  // Columna en donde comienza la impresion del Pie del Documento.
	Local nFotY			:= 1900 // Linea en donde comienza la impresion del Pie del Documento.
	Local cPagina		:= AllTrim(Str(oPrint:nPageCount))
	Local cCerSAT		:= STR0006 //"Documento Inválido." 
	Local cCertQR		:= ""
	Local nIteration	:= 0
	Local cFechaTim		:= ""
	Local cSelloSAT		:= ""
	Local cSello		:= ""
	Local cUUID			:= ""
	Local nX            := 0
	Local cTsa          := ""
	Local cVeriCFD      := AllTrim(SuperGetMV("MV_VERICFD", .F., "")) //Url de Verificación de Comprobantes Fiscales Digitales por Internet.
	
	If AllTrim(cParamTpoD) != "21"
		// Verificar que exista nodo de Traslados
		If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_IMPUESTOS") <> Nil
			If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS, "_CFDI_TRASLADOS") <> Nil 
				If Valtype(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO) == "A"
					For nX := 1 To Len(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO)
						If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO[" + Str(nX) + "]"), "_TASAOCUOTA") <> Nil
					    	cTsa := &("oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO[" + Str(nX) + "]:_TASAOCUOTA:TEXT")	
							cTasaCuota := AllTrim(Str(Val(cTsa) * 100))
						EndIf
						If XMLChildEx(&("oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO[" + Str(nX) + "]"), "_IMPORTE") <> Nil
							cImporTras := &("oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO[" + Str(nX) + "]:_IMPORTE:TEXT")
						EndIf						
						If !Empty(cTasaCuota) .And. !Empty(cImporTras)
							Aadd(aImpTras,{cTasaCuota, cImporTras})
						EndIf
					Next nX	
				Else
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO, "_TASAOCUOTA") <> Nil
						cTasaCuota	:= AllTrim(Str(Val(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO:_TASAOCUOTA:TEXT) * 100))
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO, "_IMPORTE") <> Nil
						cImporTras	:= oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_TRASLADOS:_CFDI_TRASLADO:_IMPORTE:TEXT
					EndIf
					If !Empty(cTasaCuota) .And. !Empty(cImporTras)
						Aadd(aImpTras,{cTasaCuota, cImporTras})	
					EndIf			
				EndIf

			EndIf
		EndIf
	EndIf
	
	// Verificar si está timbrado para obtener Fecha / Certificado SAT / Sello SAT / UUID
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO") <> Nil
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO, "_TFD_TIMBREFISCALDIGITAL") <> Nil
			cFechaTim := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
			cCerSAT	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
			cSelloSAT := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT
			cUUID := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
		EndIf
	EndIf

	If AllTrim(cParamTpoD) != "21"
		// Verificar que exista nodo de Impuestos
		If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_IMPUESTOS") <> Nil
			If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS, "_TOTALIMPUESTOSRETENIDOS") <> Nil
				cImporRete := Alltrim(Transform(Val(OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_TOTALIMPUESTOSRETENIDOS:TEXT)),"999,999,999.99"))
			EndIf
		EndIf
	EndIf

	// Importe y totales
	cImpEnLetr	:= MTR475CanL(cTotalDocu, cParamDocD, cParamSerD, cParamCliD, cParamLojD, cParamEspD) // Obtener la cantidad en Letra
	cTotal		:= Transform(Val(cTotalDocu), "999,999,999.99")
	
	// Impresion Certificados
	oPrint:Line(nFotY+(nTamSalto*0),100,nFotY+(nTamSalto*0),2200)
	
	oPrint:Say(nFotY + (nTamSalto*18), nFotX+20	, STR0036		, oAr12B, , CLR_BLACK, , 2) //"Importe con letra"
	oPrint:Say(nFotY + (nTamSalto*19), nFotX+20	, cImpEnLetr	, oAr10R, , CLR_BLACK, , 2)
	
	oPrint:Say(nFotY + (nTamSalto*21), nFotX+20	, STR0035		, oAr12B, , CLR_BLACK, , 2) //"No. Certificado Digital"
	oPrint:Say(nFotY + (nTamSalto*22), nFotX+20	, cCerEmi		, oAr10R, , CLR_BLACK, , 2) 

	oPrint:Say(nFotY + (nTamSalto*21), nFotX+400, STR0037		, oAr12B, , CLR_BLACK, , 2) //"No. de Certificado del SAT"
	oPrint:Say(nFotY + (nTamSalto*22), nFotX+400, cCerSAT		, oAr10R, , CLR_BLACK, , 2)
	
	oPrint:Say(nFotY + (nTamSalto*21), nFotX+800, STR0052		, oAr12B, , CLR_BLACK, , 2) //"Fecha y Hora de Certificación"
	oPrint:Say(nFotY + (nTamSalto*22), nFotX+800, cFechaTim		, oAr10R, , CLR_BLACK, , 2)
	
	//Seccion de Totales
	oPrint:SayAlign(nFotY + (nTamSalto*2),	nFotX+1300,	STR0038	, oAr10R, 700, 30, , 0, 0) //"Subtotal"
	oPrint:SayAlign(nFotY +( nTamSalto*2),	nFotX+1700,	cSubTot	, oAr10R, 300, 30, , 1, 0)  
	           
	k := 0
	If (nDescTot > 0) 
		oPrint:SayAlign(nFotY + (nTamSalto*3), nFotX+1300, STR0039												, oAr10R, 700, 30, , 0, 0) //"Descuentos"	
		oPrint:SayAlign(nFotY + (nTamSalto*3), nFotX+1700, Transform(nDescTot, "@E 999,999,999.99")			, oAr10R, 300, 30, , 1, 0)
		
		oPrint:SayAlign(nFotY + (nTamSalto*5), nFotX+1300, STR0040												, oAr10R, 700, 30, , 0, 0) //"Subtotal c/desc"	   
		oPrint:SayAlign(nFotY + (nTamSalto*5), nFotX+1700, Transform((nSubTot - nDescTot), "@E 999,999,999.99"), oAr10R, 300, 30, , 1, 0)
		k += 3
	EndIf
	
	For nX := 1 To Len(aImpTras)
		oPrint:SayAlign(nFotY + (nTamSalto*(4+k)), nFotX+1300, STR0041 + aImpTras[nX,1] + "%"							, oAr10R, 700, 30, , 0, 0) //"IVA "	
		oPrint:SayAlign(nFotY + (nTamSalto*(4+k)), nFotX+1700, Transform(Val(aImpTras[nX,2]), "@E 999,999,999.99")		, oAr10R, 300, 30, , 1, 0)
		k++	
    Next nX                        
	If (!Empty(cImporRete))
		k++
		oPrint:SayAlign(nFotY + (nTamSalto*(4+k)), nFotX+1300, STR0042											, oAr10R, 700, 30, , 0, 0) //"Retenciones "	
		oPrint:SayAlign(nFotY + (nTamSalto*(4+k)), nFotX+1700, Alltrim(cImporRete), oAr10R, 300, 30, , 1, 0)	
	EndIf
	
	oPrint:Line(nFotY + (nTamSalto*10),1300, nFotY+(nTamSalto*10),2200)
	oPrint:SayAlign(nFotY + (nTamSalto*10)+5, nFotX+1300, STR0043												, oAr10R, 700, 30, , 0, 0) //"Total"	
	oPrint:SayAlign(nFotY + (nTamSalto*10)+5, nFotX+1700, cTotal												, oAr10R, 300, 30, , 1, 0)	
		                   	
	// Datos de Sellado
	nFall += 22	//Indica la posicion donde se imprimiran los datos del sellado	
	MTR475CadO(@cCadOrig, oXml) // Construir la cadena original

    // Cadena Original del Complemento de certificación digital del SAT
	oPrint:Line(nFotY+(nTamSalto*nFall),100,nFotY+(nTamSalto*nFall),2200)
	oPrint:Say(	nFotY+(nTamSalto*(nFall+1)),	nFotX+20,	STR0044,	oAr09B,,CLR_BLACK,,2) //"Cadena Original del Complemento de Certificación Digital del SAT"
	
	nFall += 2                                                      
	
	For nIteration := 1 To Len(cCadOrig) Step 200
		oPrint:Say(	nFotY+(nTamSalto*(nFall+nCadLn)),	nFotX+20,	SubStr(cCadOrig, nIteration, 200), oAr07R, , CLR_BLACK, , 2)
		nCadLn++
		If (nCadLn == 10)
			Exit
		EndIf
	Next nIteration
         
    // Sello Digital del Emisor
    nFall += 3
    nCadLn := 0           
    
	oPrint:Line(nFotY+(nTamSalto*nFall),100,nFotY+(nTamSalto*nFall),2200)
	oPrint:Say(	nFotY+(nTamSalto*(nFall+1)),	nFotX+20,	STR0045,	oAr09B,,CLR_BLACK,,2) //"Sello Digital del CFDI"
	nFall += 2
	
	//Valida que exista atributo Folio Fiscal
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_SELLO") <> Nil
		cSello := OemToAnsi(oXml:_CFDI_COMPROBANTE:_SELLO:TEXT)
	EndIf                                                   

	For nIteration := 1 To Len(cSello) Step 200
		oPrint:Say(nFotY + (nTamSalto*(nFall+nCadLn)), nFotX+20, SubStr(cSello,nIteration,200),oAr07R,,CLR_BLACK,,2)
		nCadLn++
		If (nCadLn == 4)
			Exit
		EndIf
	Next nIteration

    // Sello Digital del SAT
    nFall += 2
    nCadLn := 0           
    
	oPrint:Line(nFotY+(nTamSalto*nFall),100,nFotY+(nTamSalto*nFall),2200)
	oPrint:Say(	nFotY+(nTamSalto*(nFall+1)),	nFotX+20,	STR0046,	oAr09B,,CLR_BLACK,,2) //"Sello Digital del SAT"
	nFall += 2                                                      
    
	If XMLChildEx( oXml:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO" ) == Nil
		oPrint:Say(	nFotY+(nTamSalto*(nFall+nCadLn)), nFotX+20, STR0047, oAr07R, , CLR_BLACK, , 2) //"-- Éste documento no ha sido Timbrado. --"
		cCertQR := ""
	Else	
		For nIteration := 1 To Len(cSelloSAT) Step 200
			oPrint:Say(	nFotY + (nTamSalto*(nFall+nCadLn)), nFotX+20, SubStr(cSelloSAT, nIteration, 200), oAr07R,,CLR_BLACK,,2)
			nCadLn++
			If (nCadLn == 4)
				Exit
			EndIf
		Next nIteration
		cCertQR := cVeriCFD + "?id=" + AllTrim(cUUID) + "&re=" + cRFCEmisor + "&rr=" + cClientRFC + "&tt=" + cTotalDocu + "&fe=" + Right(oXML:_CFDI_COMPROBANTE:_SELLO:TEXT,8)
	EndIf

	//CODIGO QR en Base a Certificado SAT
	oPrint:QRCode(2400, 100, cCertQR, 100)
	
 	oPrint:SayAlign(nFotY + (nTamSalto*20) + 400, 1750, STR0048				, oAr10R, 550, 30, , 2, 0) //"Éste documento es una representación "
 	oPrint:SayAlign(nFotY + (nTamSalto*20) + 440, 1750, STR0049				, oAr10R, 550, 30, , 2, 0) //"impresa de un CFDI"
 	
 	oPrint:SayAlign(nFotY + (nTamSalto*22) + 440, 1750, STR0050 + cPagina	, oAr10R, 550, 30, , 2, 0) //"Pagina: "
 	
	nFall += 1
	oPrint:EndPage()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR475NewP³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion utilizada para realizar saldo de pagina, cuando hay mas de ³±±
±±³Descri‡…o ³ 15 items por Documento Fiscal.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MTR475NewP(oXml,lCPorte)

	Default oXml := Nil
	Default lCPorte := .F.
	
	oPrint:EndPage()
	oPrint:StartPage()

	If lCPorte
		MR475ENCCP(oXml) //Encabezado para Carta Porte
	Else
		MATR475Enc(oXml)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR475CanL³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion utilizada para tranformar cantidad en letra.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MTR475CanL(cCantidad, cFolio, cSerie, cCliente, cTienda, cEspecie)
	
	Local cRet		:= ""
	Local nMoneda	:= 1
	Local aArea		:= GetArea()
	Local cIdiom	:= Upper(SubStr(Alltrim(FwRetIdiom()),1,2))
	Local cIdiomImp	:= 1
	
	Default cCantidad	:= ""
	Default cFolio		:= ""
	Default cSerie		:= ""
	Default cCliente	:= ""
	Default cTienda		:= ""
	Default cEspecie	:= ""
	
	cEspecie :=  RTrim(cEspecie)
	
	If cEspecie == "NCC"
		SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If SF1->(MsSeek(xFilial("SF1") + cFolio + cSerie + cCliente + cTienda + "D"))
			nMoneda := SF1->F1_MOEDA
		EndIf
	Else
		SF2->(DbSetOrder(2)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
		If SF2->(MsSeek(xFilial("SF2") + cCliente + cTienda + cFolio + cSerie + IIf (cEspecie == "NF", "N", "C") + cEspecie))
			nMoneda := SF2->F2_MOEDA
		EndIf
	EndIf
	
	If cIdiom == 'PT'
		cIdiomImp := "1"
	ElseIf cIdiom == 'ES'
		cIdiomImp := "2"
	Else
		cIdiomImp := "3"
	EndIf
	
	cRet := Extenso(Val(cCantidad), .F., nMoneda, '', cIdiomImp, .T., .T. )
	
	RestArea(aArea)
	
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR475CarE³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamiento de caracteres especiales en Cadena Original.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MTR475CarE(cCad)

	Local cRet			:= ""
	Local aTags			:= {"&amp;"	, "&quot;"	, "&lt;"	, "&gt;"	, "&#36;"	, "&#38;"	}
	Local aText			:= {"&"		, '"'		, "<"		, ">"		, "'"		, "&"		}
	Local nIteration	:= 0
	
	Default cCad	:= ""
	
	cRet := cCad
	
	For nIteration := 1 To Len(aTags)
		cRet := StrTran(cRet, aTags[nIteration], aText[nIteration])
	Next nIteration
			
	cRet := AllTrim(cRet)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR475CadO³ Autor ³ Marco Augusto Gonzalez Rivera ³ Data ³28/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Cadena Original en caso de existir Timbre, con formato:     ³±±
±±³          ³||Version|UUID|Fecha/Hora de Certificación|Sello digital del CFDI|  ³±±
±±³          ³Numero de certificado||                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MTR475CadO(cCadOrig, oXML)

	Local cFechaTim		:= ""
	Local cUUIDTim		:= ""
	Local cCerTim		:= ""
	Local cSelloCFDI	:= ""
	
	Default cCadOrig	:= ""
	Default oXml		:= Nil

	If XMLChildEx( oXML:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO" ) == Nil
		cCadOrig := STR0051 //"-- Documento inválido (Sin Timbre Fiscal Digital). --"
	Else
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO, "_TFD_TIMBREFISCALDIGITAL") <> Nil
			cFechaTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
			cUUIDTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			cCerTim 	:= oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
		EndIf
		cSelloCFDI	:= oXML:_CFDI_COMPROBANTE:_SELLO:TEXT

		cCadOrig := "||"
		cCadOrig += "1.0|" 				//	Version
		cCadOrig += cUUIDTim + "|"		// 	UUID
		cCadOrig += cFechaTim + "|"     // 	Fecha y hora de certificación
		cCadOrig += cSelloCFDI + "|"	// 	Sello digital del CFDI
		cCadOrig += cCerTim + "||"		//	Número de certificado		
	EndIf
	
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UTf8ToChr  ³ Autor ³ Alf. Medrano         ³ Data ³ 09/07/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle de caracteres especiais                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CFD - Mexico                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTf8ToChr(cTexto)
	Local cRet := ""                    
	Local nChar := 0
	Local aCarEsp := {}
	Default cTexto := ""

	If !Empty(cTexto)
		cRet := cTexto
		Aadd(aCarEsp,{"&","&#38;"})
		Aadd(aCarEsp,{'"',"&#34;"})
		Aadd(aCarEsp,{"<","&#60;"})
		Aadd(aCarEsp,{">","&#62;"})
		Aadd(aCarEsp,{"'","&#39;"})
			
		For nChar := 1 To Len(aCarEsp)
			cRet := StrTran(cRet,aCarEsp[nChar,2],aCarEsp[nChar,1])
		Next

	EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR475CP³ Autor ³ Luis Enríquez                  ³ Data ³03/09/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impresión del detalle para Complemento de Carta porte.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MR475DETCP(oXml)	
	Local nSalto	:= 0
	Local nCurLine	:= nDetY
	Local nI        := 0

	//Datos Carta Porte
	Local cTransInt  := ""
	Local cTotDist   := "0.00"
	Local cEntSalM   := ""
	Local cViaEntSal := ""
	Local cNomRem    := ""
	Local cRFCRem    := ""
	Local cFecHrSal  := ""
	Local cCalleOri := ""
	Local cNumExtOri:= ""
	Local cNumIntOri:= "S/N"
	Local cColOri   := ""
	Local cLocOri   := ""
	Local cMunOri   := ""
	Local cEdoOri   := ""
	Local cCPOri    := ""
	Local cPaisOri  := ""
	Local cNomDes   := ""
	Local cRFCDes   := ""
	Local cFecHrDes := ""
	Local cCalleDes := ""
	Local cNumExtDes:= ""
	Local cNumIntDes:= "S/N"
	Local cColDes   := ""
	Local cLocDes   := ""
	Local cMunDes   := ""
	Local cEdoDes   := ""
	Local cCPDes    := ""
	Local cPaisDes  := ""
	Local cPermSTC   := ""
	Local cNumPerSCT := ""
	Local cNomAseg   := ""
	Local cNumPolSeg := ""
	Local cPlacaMV   := ""
	Local cAnoModMV  := ""
	Local cConfVeh   := ""
	Local cSubRemol  := ""
	Local cPlacaRem  := ""
	Local aOperador  := {}
	Local aPropie    := {}
	Local cCveTra    := ""
	Local cCanMer    := ""
	Local cUniMer    := ""
	Local cDesMer    := ""
	Local cPesoMer   := ""
	Local cVlrMer    := ""
	Local cMatPel    := ""
	Local cCveMatPel := ""
	Local cPagina	 := AllTrim(Str(oPrint:nPageCount))

	//Datos Carta Porte
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO") <> Nil .And. XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO, "_CARTAPORTE20_CARTAPORTE") <> Nil
		MTR475NewP(oXml,.T.)
		//Valida que exista atributo Transporte Internacional
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE, "_TRANSPINTERNAC") <> Nil
			cTransInt := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_TRANSPINTERNAC:TEXT)
		EndIf

		//Valida que exista atributo Total Distancia Recorrida:
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE, "_TOTALDISTREC") <> Nil
			cTotDist := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_TOTALDISTREC:TEXT)
		EndIf

		//Valida que exista atributo Entrada/Salida de Mercancía:
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE, "_ENTRADASALIDAMERC") <> Nil
			cEntSalM := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_ENTRADASALIDAMERC:TEXT)
		EndIf

		//Valida que exista atributo Vía de Entrada:
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE, "_VIAENTRADASALIDA") <> Nil
			cViaEntSal := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_VIAENTRADASALIDA:TEXT)
		EndIf
	
		oPrint:Say(nCliY + (nTamSalto*1), nCliX + 20, STR0056 + cTransInt, oAr10R, , CLR_BLACK, , 2) //"Transporte Internacional: "
		If !Empty(cEntSalM) 
			oPrint:Say(nCliY + (nTamSalto*2), nCliX + 20, STR0057 + cEntSalM, oAr10R, , CLR_BLACK, , 2) //"Entrada/Salida de Mercancia: "
		EndIf

		oPrint:Say(nCliY + (nTamSalto*1), nCliX + 1200	, STR0058	+ TRANSFORM(Val(cTotDist),"999999.99"), oAr10R, , CLR_BLACK, , 2) //"Total Distancia Recorrida: "
		oPrint:Say(nCliY + (nTamSalto*2), nCliX + 1200	, STR0059 + cViaEntSal, oAr10R, , CLR_BLACK, , 2) //"Vía de Entrada: "

		oPrint:Line(nFacY + (nTamSalto*11), 100, nFacY + (nTamSalto*11), 2200)

		oPrint:Say(nCliY + (nTamSalto*4), nCliX + 20, STR0060, oAr12B, , CLR_BLACK, , 2) //"ORIGEN: "

		//UBICACIONES
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE,"_CARTAPORTE20_UBICACIONES") <> Nil
			If ValType(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION) == "A"
				//origen
				If OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_TIPOUBICACION:TEXT) == "Origen"
					//Remitente
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1],"_NOMBREREMITENTEDESTINATARIO") <> Nil
						cNomRem := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_NOMBREREMITENTEDESTINATARIO:TEXT)
					EndIf
					//RFC Remitente
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1],"_RFCREMITENTEDESTINATARIO") <> Nil
						cRFCRem := CFDCarEspInv(OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_RFCREMITENTEDESTINATARIO:TEXT))
					EndIf

					//Fecha/Hora de Salida
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1],"_FECHAHORASALIDALLEGADA") <> Nil
						cFecHrSal := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_FECHAHORASALIDALLEGADA:TEXT)
					EndIf
				EndIf

				//Domicilio
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1],"_CARTAPORTE20_DOMICILIO") <> Nil
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_CALLE") <> Nil
						cCalleOri := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_CALLE:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_NUMEROEXTERIOR") <> Nil
						cNumExtOri := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_NUMEROEXTERIOR:TEXT 
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_NUMEROINTERIOR") <> Nil
						cNumIntOri := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_NUMEROINTERIOR:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_COLONIA") <> Nil
						cColOri  := ObtColSAT("S015",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_COLONIA:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_CODIGOPOSTAL:TEXT),1,9,10,50)
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_LOCALIDAD") <> Nil
						cLocOri  := ObtColSAT("S023",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_LOCALIDAD:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_ESTADO:TEXT),1,5,6,40)
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_MUNICIPIO") <> Nil
						cMunOri  := ObtColSAT("S024",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_MUNICIPIO:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_ESTADO:TEXT),1,6,7,40)
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_ESTADO") <> Nil
						cEdoOri  := ObtColSAT("S025",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_ESTADO:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_PAIS:TEXT),1,6,7,40)
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_CODIGOPOSTAL") <> Nil
						cCPOri   := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_CODIGOPOSTAL:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO,"_PAIS") <> Nil
						cPaisOri := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[1]:_CARTAPORTE20_DOMICILIO:_PAIS:TEXT
					EndIf
				EndIf

				//Destino
				If OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_TIPOUBICACION:TEXT) == "Destino"
					//Destinatario
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2],"_NOMBREREMITENTEDESTINATARIO") <> Nil
						cNomDes := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_NOMBREREMITENTEDESTINATARIO:TEXT)
					EndIf
					//RFC Destinatario
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2],"_RFCREMITENTEDESTINATARIO") <> Nil
						cRFCDes := CFDCarEspInv(OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_RFCREMITENTEDESTINATARIO:TEXT))
					EndIf

					//Fecha/Hora de Llegada
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2],"_FECHAHORASALIDALLEGADA") <> Nil
						cFecHrDes := OemToAnsi(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_FECHAHORASALIDALLEGADA:TEXT)
					EndIf
				EndIf

				//Domicilio Destino
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2],"_CARTAPORTE20_DOMICILIO") <> Nil
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_CALLE") <> Nil
						cCalleDes := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_CALLE:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_NUMEROEXTERIOR") <> Nil
						cNumExtDes := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_NUMEROEXTERIOR:TEXT 
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_NUMEROINTERIOR") <> Nil
						cNumIntDes := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_NUMEROINTERIOR:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_COLONIA") <> Nil
						cColDes  := ObtColSAT("S015",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_COLONIA:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_CODIGOPOSTAL:TEXT),1,9,10,50)
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_LOCALIDAD") <> Nil
						cLocDes  := ObtColSAT("S023",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_LOCALIDAD:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_ESTADO:TEXT),1,5,6,40)	
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_MUNICIPIO") <> Nil
						cMunDes  := ObtColSAT("S024",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_MUNICIPIO:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_ESTADO:TEXT),1,6,7,40)
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_ESTADO") <> Nil
						cEdoDes  := ObtColSAT("S025",AllTrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_ESTADO:TEXT) + ;
						Alltrim(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_PAIS:TEXT),1,6,7,40)	
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_CODIGOPOSTAL") <> Nil
						cCPDes   := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_CODIGOPOSTAL:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO,"_PAIS") <> Nil
						cPaisDes := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_UBICACIONES:_CARTAPORTE20_UBICACION[2]:_CARTAPORTE20_DOMICILIO:_PAIS:TEXT
					EndIf
				EndIf
			EndIf
		EndIf

		oPrint:Say(nCliY + (nTamSalto*5), nCliX + 20, STR0061 + cNomRem, oAr10R, , CLR_BLACK, , 2) //"Nombre Remitente: "
		oPrint:Say(nCliY + (nTamSalto*5), nCliX + 1200, STR0062 + cRFCRem, oAr10R, , CLR_BLACK, , 2) //"RFC Remitente: "
		oPrint:Say(nCliY + (nTamSalto*6), nCliX + 20, STR0063 + cFecHrSal, oAr10R, , CLR_BLACK, , 2) //"Fecha/Hora de Salida: "

		oPrint:Say(nCliY + (nTamSalto*7), nCliX + 20, STR0064, oAr12B, , CLR_BLACK, , 2) //"DOMICILIO: "

		oPrint:Say(nCliY + (nTamSalto*8), nCliX + 20, STR0065 + cCalleOri, oAr10R, , CLR_BLACK, , 2) //"Calle: "
		oPrint:Say(nCliY + (nTamSalto*8), nCliX + 1200, STR0066 + cNumExtOri , oAr10R, , CLR_BLACK, , 2) //"No. Ext.: "
		oPrint:Say(nCliY + (nTamSalto*8), nCliX + 1500, STR0067 + cNumIntOri , oAr10R, , CLR_BLACK, , 2) //"No. Int.: "   

		oPrint:Say(nCliY + (nTamSalto*9), nCliX + 20, STR0068 + cColOri, oAr10R, , CLR_BLACK, , 2) //"Colonia: "
		oPrint:Say(nCliY + (nTamSalto*9), nCliX + 1200, STR0069 + cLocOri , oAr10R, , CLR_BLACK, , 2) //"Localidad: "

		oPrint:Say(nCliY + (nTamSalto*10), nCliX + 20, STR0070 + cMunOri, oAr10R, , CLR_BLACK, , 2) //"Municipio: "
		oPrint:Say(nCliY + (nTamSalto*10), nCliX + 1200, STR0071 + cEdoOri , oAr10R, , CLR_BLACK, , 2) //"Estado: "

		oPrint:Say(nCliY + (nTamSalto*11), nCliX + 20, STR0072 + cCPOri, oAr10R, , CLR_BLACK, , 2) //"Código Postal: " 
		oPrint:Say(nCliY + (nTamSalto*11), nCliX + 1200, STR0073 + cPaisOri , oAr10R, , CLR_BLACK, , 2) //"País: "

		oPrint:Line(nFacY + (nTamSalto*20), 100, nFacY + (nTamSalto*20), 2200)

		oPrint:Say(nCliY + (nTamSalto*13), nCliX + 20, STR0074, oAr12B, , CLR_BLACK, , 2) //"DESTINO: "

		oPrint:Say(nCliY + (nTamSalto*14), nCliX + 20, STR0075 + cNomDes, oAr10R, , CLR_BLACK, , 2) //"Nombre Destinatario: "
		oPrint:Say(nCliY + (nTamSalto*14), nCliX + 1200, STR0076 + cRFCDes, oAr10R, , CLR_BLACK, , 2) // "RFC Destinatario: "
		oPrint:Say(nCliY + (nTamSalto*15), nCliX + 20, STR0077 + cFecHrDes, oAr10R, , CLR_BLACK, , 2) //"Fecha/Hora de Llegada: "

		oPrint:Say(nCliY + (nTamSalto*16), nCliX + 20, STR0064, oAr12B, , CLR_BLACK, , 2) //"DOMICILIO: "

		oPrint:Say(nCliY + (nTamSalto*17), nCliX + 20, STR0065 + cCalleDes, oAr10R, , CLR_BLACK, , 2) //"Calle: "
		oPrint:Say(nCliY + (nTamSalto*17), nCliX + 1200, STR0066 + cNumExtDes , oAr10R, , CLR_BLACK, , 2) //"No. Ext.: "
		oPrint:Say(nCliY + (nTamSalto*17), nCliX + 1500, STR0067 + cNumIntDes , oAr10R, , CLR_BLACK, , 2) //"No. Int.: "

		oPrint:Say(nCliY + (nTamSalto*18), nCliX + 20, STR0068 + cColDes, oAr10R, , CLR_BLACK, , 2) //"Colonia: "
		oPrint:Say(nCliY + (nTamSalto*18), nCliX + 1200, STR0069 + cLocDes , oAr10R, , CLR_BLACK, , 2) //"Localidad: "

		oPrint:Say(nCliY + (nTamSalto*19), nCliX + 20, STR0070 + cMunDes, oAr10R, , CLR_BLACK, , 2) //"Municipio: "
		oPrint:Say(nCliY + (nTamSalto*19), nCliX + 1200, STR0071 + cEdoDes , oAr10R, , CLR_BLACK, , 2) //"Estado: "

		oPrint:Say(nCliY + (nTamSalto*20), nCliX + 20, STR0072 + cCPDes, oAr10R, , CLR_BLACK, , 2) //"Código Postal: " 
		oPrint:Say(nCliY + (nTamSalto*20), nCliX + 1200, STR0073 + cPaisDes , oAr10R, , CLR_BLACK, , 2) //"País: "


		If nSalto > 0
			nDetY := nDetY + nSalto
		EndIF

		oPrint:Line(nFacY + (nTamSalto*29), 100, nFacY + (nTamSalto*29), 2200)

		// Encabezado de las columnas de datos de los Productos.
		oPrint:Say(nDetY + (nTamSalto*21),	nDetCPX,"",oAr09B,,CLR_BLACK,,2)
		
		oPrint:SayAlign(nDetY + (nTamSalto*12), nDetCPX		, STR0030 , oAr12B, 200		, 60, , 2, 0)     //"Cantidad"
		oPrint:SayAlign(nDetY + (nTamSalto*12), nDetCPX + 150	, STR0031 , oAr12B, 200		, 60, , 2, 0) //"Unidad"
		oPrint:SayAlign(nDetY + (nTamSalto*12), nDetCPX + 320	, STR0078 , oAr12B, 1000	, 60, , 0, 0) //"Descripción"
		oPrint:SayAlign(nDetY + (nTamSalto*12), nDetCPX + 1020	, STR0079 , oAr12B, 300		, 60, , 2, 0) //"Peso en Kg"
		oPrint:SayAlign(nDetY + (nTamSalto*12), nDetCPX + 1200	, STR0080 , oAr12B, 300		, 60, , 2, 0) //"Vlr Merc."
		oPrint:SayAlign(nDetY + (nTamSalto*12), nDetCPX + 1500	, STR0081 , oAr12B, 300		, 60, , 2, 0) //"Mat. Peligroso"
		oPrint:SayAlign(nDetY + (nTamSalto*12), nDetCPX + 1800	, STR0082 , oAr12B, 300		, 60, , 2, 0) //"Cve. Mat. Peligroso" 

		oPrint:Line(nFacY + (nTamSalto*31), 100, nFacY + (nTamSalto*31), 2200)

		nPos := 13
		If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE,"_CARTAPORTE20_MERCANCIAS") <> Nil
			If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS,"_CARTAPORTE20_AUTOTRANSPORTE") <> Nil
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE,"_CARTAPORTE20_SEGUROS") <> Nil
					cNomAseg := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_SEGUROS:_ASEGURARESPCIVIL:TEXT
				EndIf
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE,"_NUMPERMISOSCT") <> Nil
					cNumPerSCT:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_NUMPERMISOSCT:TEXT
				EndIf
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE,"_CARTAPORTE20_SEGUROS") <> Nil
					cNumPolSeg := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_SEGUROS:_POLIZARESPCIVIL:TEXT
				EndIf
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE,"_PERMSCT") <> Nil
					cPermSTC := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_PERMSCT:TEXT
				EndIf
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE,"_CARTAPORTE20_IDENTIFICACIONVEHICULAR") <> Nil
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_IDENTIFICACIONVEHICULAR,"_ANIOMODELOVM") <> Nil
						cAnoModMV := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_IDENTIFICACIONVEHICULAR:_ANIOMODELOVM:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_IDENTIFICACIONVEHICULAR,"_PLACAVM") <> Nil
						cPlacaMV := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_IDENTIFICACIONVEHICULAR:_PLACAVM:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_IDENTIFICACIONVEHICULAR,"_CONFIGVEHICULAR") <> Nil
						cConfVeh := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_IDENTIFICACIONVEHICULAR:_CONFIGVEHICULAR:TEXT
					EndIf
				EndIf
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE,"_CARTAPORTE20_REMOLQUES") <> Nil
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_REMOLQUES:_CARTAPORTE20_REMOLQUE,"_SUBTIPOREM") <> Nil
						cSubRemol := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_REMOLQUES:_CARTAPORTE20_REMOLQUE:_SUBTIPOREM:TEXT
					EndIf
					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_REMOLQUES:_CARTAPORTE20_REMOLQUE,"_PLACA") <> Nil
						cPlacaRem := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_AUTOTRANSPORTE:_CARTAPORTE20_REMOLQUES:_CARTAPORTE20_REMOLQUE:_PLACA:TEXT
					EndIf			
				EndIf
			EndIf
			If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE,"_CARTAPORTE20_FIGURATRANSPORTE") <> Nil
				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE,"_CARTAPORTE20_TIPOSFIGURA") <> Nil 	
					If ValType(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA) == "A"
						For nI:=1 To Len(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA)
							cCveTra := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA[nI]:_TIPOFIGURA:TEXT
							If cCveTra == "01"
								aAdd(aOperador,{cCveTra,oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA[nI]:_NUMLICENCIA:TEXT, ;
								CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA[nI]:_NOMBREFIGURA:TEXT), ;
								CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA[nI]:_RFCFIGURA:TEXT)})
							ElseIf cCveTra $ "02|03"
								aAdd(aPropie, {CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA[nI]:_NOMBREFIGURA:TEXT), ;
								CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA[nI]:_RFCFIGURA:TEXT)})
							EndIF
						Next nI
					Else 
						cCveTra := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA:_TIPOFIGURA:TEXT
						If cCveTra == "01"
							aAdd(aOperador,{cCveTra,oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA:_NUMLICENCIA:TEXT, ;
							CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA:_NOMBREFIGURA:TEXT), ;
							CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA:_RFCFIGURA:TEXT)})
						ElseIf cCveTra $ "02|03"
							aAdd(aPropie, {CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA:_NOMBREFIGURA:TEXT), ;
							CFDCarEspInv(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_FIGURATRANSPORTE:_CARTAPORTE20_TIPOSFIGURA:_RFCFIGURA:TEXT)})
						EndIF
					EndIf
				EndIf
			EndIf
			If ValType(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA) == "A"
				For nI := 1 To Len(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA)
					nPos += 1
					nCurLine += nTamSalto
					cMatPel := ""
					cCveMatPel := ""
					If (nCurLine > 2500) // Se define el tamano maximo que tendran la seccion de items.
						oPrint:SayAlign(3000, 1750, "Pagina: " + cPagina	, oAr10R, 550, 30, , 2, 0) 
						MTR475NewP(oXml,.T.)
						hdrHeight := (nTamSalto*2)
						nFall := 4
						nDetY := 10
						nPos := 11
						nCurLine := nDetY
					EndIf
					cCanMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI]:_CANTIDAD:TEXT
					cUniMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI]:_CLAVEUNIDAD:TEXT
					cDesMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI]:_DESCRIPCION:TEXT
					cPesoMer := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI]:_PESOENKG:TEXT
					cVlrMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI]:_VALORMERCANCIA:TEXT

					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI],"_MATERIALPELIGROSO") <> Nil
						cMatPel := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI]:_MATERIALPELIGROSO:TEXT
					EndIf

					If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI],"_CVEMATERIALPELIGROSO") <> Nil
						cCveMatPel := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA[nI]:_CVEMATERIALPELIGROSO:TEXT
					EndIf
					
					oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX		, cCanMer , oAr10R, 200		, 60, , 2, 0) 
					oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 150	, cUniMer , oAr10R, 200		, 60, , 2, 0) 
					oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 320	, cDesMer , oAr10R, 1000	, 60, , 0, 0) 
					oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 920	, TRANSFORM(Val(cPesoMer),"999,999,999.99") , oAr10R, 300		, 60, , 1, 0) 
					oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 1200, TRANSFORM(Val(cVlrMer),"999,999,999,999.99") , oAr10R, 300		, 60, , 1, 0) 
					oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 1500	, cMatPel , oAr10R, 300		, 60, , 2, 0) 
					oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 1800	, cCveMatPel , oAr10R, 300		, 60, , 2, 0) 
				Next nI
			Else
				nPos += 1
				cCanMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA:_CANTIDAD:TEXT
				cUniMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA:_CLAVEUNIDAD:TEXT
				cDesMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA:_DESCRIPCION:TEXT
				cPesoMer := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA:_PESOENKG:TEXT
				cVlrMer  := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA:_VALORMERCANCIA:TEXT

				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA,"_MATERIALPELIGROSO") <> Nil
					cMatPel := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA:_MATERIALPELIGROSO:TEXT
				EndIf

				If XMLChildEx(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA,"_CVEMATERIALPELIGROSO") <> Nil
					cCveMatPel := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_CARTAPORTE20_CARTAPORTE:_CARTAPORTE20_MERCANCIAS:_CARTAPORTE20_MERCANCIA:_CVEMATERIALPELIGROSO:TEXT
				EndIf
				
				oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX		, cCanMer , oAr10R, 200		, 60, , 2, 0) 
				oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 150	, cUniMer , oAr10R, 200		, 60, , 2, 0) 
				oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 320	, cDesMer , oAr10R, 1000	, 60, , 0, 0) 
				oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 920	, TRANSFORM(Val(cPesoMer),"999,999,999.99") , oAr10R, 300		, 60, , 1, 0) 
				oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 1200, TRANSFORM(Val(cVlrMer),"999,999,999,999.99") , oAr10R, 300		, 60, , 1, 0) 
				oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 1500	, cMatPel , oAr10R, 300		, 60, , 2, 0) 
				oPrint:SayAlign(nDetY + (nTamSalto*nPos), nDetCPX + 1800	, cCveMatPel , oAr10R, 300		, 60, , 2, 0) 
			EndIf
		EndIf

		nPos += 2
		
		oPrint:Line(nDetY + (nTamSalto*nPos), 100, nDetY + (nTamSalto*nPos), 2200)

		nPos += 2
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0083, oAr12B, , CLR_BLACK, , 2) //"INFORMACIÓN DE AUTOTRANSPORTE"
		nPos += 2
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0084 + cPermSTC, oAr10R, , CLR_BLACK, , 2) //"Tipo de Permiso SCT: "
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 1200, STR0085 + cNumPerSCT, oAr10R, , CLR_BLACK, , 2) //"Núm. de Permiso: " 
		nPos += 1
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0086 + cNomAseg, oAr10R, , CLR_BLACK, , 2) //"Nombre Aseguradora: "
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 1200, STR0087 + cNumPolSeg, oAr10R, , CLR_BLACK, , 2) //"Número de Póliza: "
		nPos += 1
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0088 + cConfVeh, oAr10R, , CLR_BLACK, , 2) //"Clave de Autotransporte: "
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 1200, STR0089 + cPlacaMV, oAr10R, , CLR_BLACK, , 2) //"Placa Vehículo: "
		nPos += 1
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0090 + cAnoModMV, oAr10R, , CLR_BLACK, , 2) //"Año Modelo: "

		//Remolque
		nPos += 1
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0091, oAr12B, , CLR_BLACK, , 2) //"DATOS DEL REMOLQUE"
		nPos += 1
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0092 + cSubRemol, oAr10R, , CLR_BLACK, , 2) //"Clave Tipo de Remolque: "
		oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 1200, STR0093 + cPlacaRem, oAr10R, , CLR_BLACK, , 2) //"Placa: "
		nPos += 1
		oPrint:Line(nDetY + (nTamSalto*nPos), 100, nDetY + (nTamSalto*nPos), 2200) 

		//Operadores
		If Len(aOperador) > 0
			nPos += 2
			oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0094, oAr12B, , CLR_BLACK, , 2) //"INFORMACIÓN DEL OPERADOR"
				nPos += 1
			For nI := 1 To Len(aOperador)
				nPos += 1
				oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0095 + aOperador[nI][1], oAr10R, , CLR_BLACK, , 2) //"Clave del Transporte: "
				oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 1200, STR0096 + aOperador[nI][2], oAr10R, , CLR_BLACK, , 2) //"No. Licencia: "
				nPos += 1
				oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0097 + aOperador[nI][3], oAr10R, , CLR_BLACK, , 2) //"Operador: "
				oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 1200, STR0098 + aOperador[nI][4], oAr10R, , CLR_BLACK, , 2) //"RFC Operador: "
			Next nI
		EndIf
		nPos += 1
		oPrint:Line(nDetY + (nTamSalto*nPos), 100, nDetY + (nTamSalto*nPos), 2200) 

		//Propietarios
		If Len(aPropie) > 0
			nPos += 2
			oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0099, oAr12B, , CLR_BLACK, , 2) //"INFORMACIÓN DEL PROPIETARIO/ARRENDATARIO"
				nPos += 1
			For nI := 1 To Len(aPropie)
				nPos += 1
				oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 20, STR0100 + aPropie[nI][1], oAr10R, , CLR_BLACK, , 2) //"Propietario: "
				oPrint:Say(nDetY + (nTamSalto*nPos), nCliX + 1200, STR0101 + aPropie[nI][2], oAr10R, , CLR_BLACK, , 2) //"RFC Propietario: "
			Next nI
		EndIf
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR475ECP³ Autor ³ Luis Enríquez                 ³ Data ³03/09/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impresión del encabezado para Complemento de Carta porte.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturacion - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MR475ENCCP(oXml)
	Local cFileLogoR	:=  GetSrvProfString("Startpath","") + "lgrl.bmp" // Logo
	Local cFranja		:=  GetSrvProfString("Startpath","") + "Franja_factura10.bmp" // Franja de fondo de la factura
	Local cFolio		:= ""
	Local cFechaXml		:= ""
	Local cFechaFac		:= ""
	Local cTpoCompro	:= ""
	Local cDescCompr	:= ""

	//Valida que exista Nodo con Informacion del Emisor
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_CFDI_EMISOR") <> Nil
		cRFCEmisor := oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT
		cNomEmisor := oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_NOMBRE:TEXT
	EndIf

	//Valida que exista atributo Folio Fiscal
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_FOLIO") <> Nil
		cFolio := OemToAnsi(oXml:_CFDI_COMPROBANTE:_FOLIO:TEXT)
	EndIf
	//Valida que exista atributo Fecha
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_FECHA") <> Nil
		cFechaXml := oXml:_CFDI_COMPROBANTE:_FECHA:TEXT
		cFechaFac := SubStr(cFechaXml,9,2)+"/"+SubStr(cFechaXml,6,2)+"/"+SubStr(cFechaXml,1,4)+" "+SubStr(cFechaXml,12,8)
	EndIf
	//Valida que exista atributo Tipo de Comprobante
	If XMLChildEx(oXml:_CFDI_COMPROBANTE, "_TIPODECOMPROBANTE") <> Nil
		cTpoCompro := oXml:_CFDI_COMPROBANTE:_TIPODECOMPROBANTE:TEXT
	EndIf

	If nPagNum == 1
		If cTpoCompro == "I"
			cDescCompr := STR0007 //"Ingreso"
		ElseIf cTpoCompro == "E"
			cDescCompr := STR0008 //"Egreso"
		ElseIf cTpoCompro == "T"
			cDescCompr := STR0009 //"Traslado"
		EndIf
	EndIf

	// Imprimir Logo de emisor
	// ---------------------------------------------------------------------
	oPrint:SayBitmap(85	, 100	, cFileLogoR	, 200, 200	) //y, x, archivo, ancho, alto
	oPrint:SayBitmap(1	, 1750	, cFranja		, 565, 3050	) //y, x, archivo, ancho, alto

	// Datos de la empresa
	// ---------------------------------------------------------------------
	oPrint:SayAlign(nEmiY					, 1, UTf8ToChr(cNomEmisor)									, oAr12B, 2300, 70, , 2, 0)
	oPrint:SayAlign(nEmiY + (nTamSalto*1)	, 1, RTRIM(SM0->M0_ENDENT) + ", " + RTRIM(SM0->M0_BAIRENT)	, oAr10R, 2300, 70, , 2, 0)
	oPrint:SayAlign(nEmiY + (nTamSalto*2)	, 1, RTRIM(SM0->M0_CIDENT) + ", " + RTRIM(SM0->M0_CEPENT)	, oAr10R, 2300, 70, , 2, 0)
	oPrint:SayAlign(nEmiY + (nTamSalto*3)	, 1, "R.F.C. " + cRFCEmisor									, oAr10R, 2300, 70, , 2, 0)
	oPrint:SayAlign(nEmiY + (nTamSalto*5)	, 1, STR0055, oAr12B, 2300, 70, , 2, 0) //"COMPLEMENTO DE CARTA PORTE"

	// Layout del encabezado
	// -----------------------------------------------------------------------	
	If AllTrim(cParamEspD) == "NF" //Factura
		oPrint:SayAlign(nFacY - 40	, nFacX, STR0010, oAr14B, 500, 50, , 2, 0) //"FACTURA"
		oPrint:SayAlign(nFacY		, nFacX, STR0011, oAr12B, 500, 50, , 2, 0) //"SERIE/FOLIO INTERNO"
	ElseIf AllTrim(cParamEspD) == "NDC" //Nota de Debito
		oPrint:SayAlign(nFacY - 40	, nFacX, STR0012, oAr14B, 500, 50, , 2, 0) //"NOTA DE CARGO"
		oPrint:SayAlign(nFacY		, nFacX, STR0011, oAr12B, 500, 50, , 2, 0) //"SERIE/FOLIO INTERNO"
	ElseIf AllTrim(cParamEspD) == "NCC" //Nota de Credito
		oPrint:SayAlign(nFacY - 40	, nFacX, STR0013, oAr14B, 500, 50, , 2, 0) //"NOTA DE CRÉDITO"
		oPrint:SayAlign(nFacY		, nFacX, STR0011, oAr12B, 500, 50, , 2, 0) //"SERIE/FOLIO INTERNO"
	EndIf

	oPrint:SayAlign(nFacY + (nTamSalto*1)	, nFacX, AllTrim(cParamSerD) + " - " + AllTrim(cFolio)	, oAr10R, 500, 30, , 2, 0)
	oPrint:SayAlign(nFacY + (nTamSalto*3)	, nFacX, STR0014 + cFechaFac 							, oAr10B, 500, 30, , 2, 0) //"Fecha de emisión: "
	oPrint:SayAlign(nFacY + (nTamSalto*5)	, nFacX, STR0015 + "(" + cTpoCompro + ") " + cDescCompr	, oAr10R, 500, 30, , 2, 0) //"Tipo de Comprobante: "

	oPrint:Line(nFacY + (nTamSalto*8), 100, nFacY + (nTamSalto*8), 2200)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    CFDCarEspInv Autor ³ Oswaldo Diego Jacobo          ³ Data ³23/06/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Convierte las coficiaciones decimales de ", &, ', < y > a           ³±±
±±³          ³caracteres imprimibles                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Facturación - Mexico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CFDCarEspInv(cTexto)
	Local cRet := ""                    
	Local nChar := 0
	Local aCarEsp := {}

	If !Empty(cTexto)
		cRet := cTexto
		Aadd(aCarEsp,{"&#34;",'"'})
		Aadd(aCarEsp,{"&#38;","&"})
		Aadd(aCarEsp,{"&#39;","'"})
		Aadd(aCarEsp,{"&#60;","<"})
		Aadd(aCarEsp,{"&#62;",">"})
		
		For nChar := 1 To Len(aCarEsp)
			cRet := StrTran(cRet,aCarEsp[nChar,1],aCarEsp[nChar,2])
		Next
	EndIf
Return(cRet)
