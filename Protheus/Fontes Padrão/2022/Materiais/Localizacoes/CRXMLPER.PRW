#include "Protheus.ch"
#include "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CRXmlPer    ³ Autor ³ Mayra Camargo         ³ Data ³ 10.10.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Esta rutina permite generar una cadena de caracteres que     ³±±
±±³          ³ define un XML el cual contiene los datos correspondientes    ³±±
±±³          ³ al comprobante de retención que sera trasmitido              ³±±
±±³          ³ a TSS para su envio a traves de Signature.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CRXmlPer(ExpN1,ExpC2,ExpC3,ExpC4,ExpC5,Expc6,Expn7)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = No. de Certificado                                   ³±±
±±³          ³ ExpC2 = Número de Fatcura relacionada al documento.          ³±±
±±³          ³ ExpC3 = Serie del documento.                                 ³±±
±±³          ³ ExpC4 = Cod. Cliente / Proveedor.                            ³±±
±±³          ³ ExpC5 = Codigo de la tiente (Cliente/Proveedor).             ³±±
±±³          ³ ExpC6 = Serie 2 del documento a 4 digitos                    ³±±
±±³          ³ ExpN7 = Numero de Registro en SFE                            ³±±
±±³          ³ ExpN8 = Ambte confg. en TSS 1 = Homologacion 2 = Produccion  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA485                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nombre    ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo ³18/09/17³DMINA-451  |Migración a versión 12.1.14              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CRXmlPER(cNroCert, cNfiscal, cSerie, cFornece, cLoja, cSerieCert,nRecSFE,nAmbient)
	Local aArea		:= GetArea()
	Local cCRLF		:= (chr(13)+chr(10) )
	Local cXML		:= ''

	//emisor
	Local cTpDocRec		:= ""

	//Variables Query
	Local cAliasXML	:= getNextAlias()
	Local cPerFisc	:= ""
	Local cFchaEmis	:= ""
	Local cFechaRes	:= ""
	Local cMoneda		:= ""
	Local cPicPrc		:= "@E 99999.99"

	Local nTam		:= iif(Tamsx3("F1_DOC")[1] > 9,Tamsx3("F1_DOC")[1] ,1)
	Local cEmissao	:= ""
	Local cEmidata	:= ""
	Private cfilSF1	:= xfilial("SF1")
	Private cfilSFB	:= xfilial("SFB")
	Private cFilSA2	:= xfilial("SA2")
	Private cFilSFE	:= xfilial("SFE")
	Private cPict	:= "@E 99999999999999999999.99"

	cEmiData := getEmisor()

		BeginSql alias cAliasXML
			SELECT SF1.*,SA2.A2_NOME,SA2.A2_CGC,SA2.A2_TIPDOC,SA2.A2_END, SA2.A2_EST,SA2.A2_BAIRRO,SA2.A2_MUN,SA2.A2_PAIS,SA2.A2_CEP//%exp:cCposQuery%
			FROM  %Table:SF1% SF1 	INNER JOIN
					%Table:SA2% SA2
					ON SF1.F1_FORNECE=SA2.A2_COD AND SF1.F1_LOJA=SA2.A2_LOJA
			WHERE 	SF1.F1_FILIAL=%exp:xFilial("SF1")%
				AND SA2.A2_FILIAL=%exp:xFilial("SA2")%
				AND SF1.%notDel%
				AND SA2.%notDel%
				AND SF1.F1_DOC=%exp:cNFiscal%
				AND SF1.F1_SERIE=%exp:cSerie%
				AND SF1.F1_FORNECE=%exp:cFornece%
				AND SF1.F1_LOJA=%exp:cLoja%
		EndSql

		//Los campos tipo fecha se quedan como tipo fecha, pues por query son recuperados como string
		TCSetField(cAliasXML,"F1_EMISSAO","D")

		// Posicionarse sobre el Registro en SFE
		dbSelectArea("SFE")
		SFE->(dbSetOrder(1))
		SFE->(DbGoto(nRecSFE))


		dbSelectArea(cAliasXML)

		(cAliasXML)->(DbGoTop())


		While (cAliasXML )->(!Eof())

			cPerFisc 	:= STRZERO(MONTH((cAliasXML )->F1_EMISSAO),2) + "/" + STRZERO(YEAR((cAliasXML )->F1_EMISSAO),4)
			cFchaEmis	:= STRZERO(YEAR((cAliasXML )->F1_EMISSAO),4)  + "-" + STRZERO(MONTH((cAliasXML )->F1_EMISSAO),2) + "-" + STRZERO(DAY((cAliasXML )->F1_EMISSAO),2)  + "T" +(cAliasXML)->F1_HORA+"Z"
			cMoneda  	:= (cAliasXML )->F1_MOEDA
			cFechaRes	:= STRZERO(YEAR((cAliasXML )->F1_EMISSAO),4)  + "-" + STRZERO(MONTH((cAliasXML )->F1_EMISSAO),2) + "-" + STRZERO(DAY((cAliasXML )->F1_EMISSAO),2)


			cXML := '<?xml version="1.0" encoding="iso-8859-1"?>' + cCRLF
			cXML += '<DTE version="1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="DTE_v1.0.xsd">'+ cCRLF
			cXML += '<Documento ID="'+ cSerieCert + cNroCert +'">'+ cCRLF
			cXML += '<Encabezado>'+ cCRLF
			cXML += '	<IdDoc>'+ cCRLF
			cXML += '		<Ambiente>'+ if(nAmbient == 1,"2","1")+'</Ambiente>'+ cCRLF
			cXML += '		<TipoEmision>NORMAL</TipoEmision>'+ cCRLF
			cXML += '		<ContenidoTC></ContenidoTC>'+ cCRLF
			cXML += '		<Tipo>20</Tipo>'+ cCRLF
			cXML += '		<Serie>'+ cSerieCert  +'</Serie>'+ cCRLF
			cXML += '		<Numero>'+ cNroCert +'</Numero>'+ cCRLF
			cXML += '		<Estado>ORIGINAL</Estado>'+ cCRLF
			cXML += '		<NumeroInterno>'+ cNroCert +'</NumeroInterno>'+ cCRLF
			cXML += '		<FechaEmis>'+ cFchaEmis +'</FechaEmis>'+ cCRLF
			cXML += '	</IdDoc>'+ cCRLF

			cXML += cEmiData
			// Catálogo de Tipos de documentos 01 SUNAT Tabla XD
			If ! Empty((cAliasXML)->A2_TIPDOC)
				cTpDocRec := ALLTRIM(fGetSX5("XN"+(cAliasXML)->A2_TIPDOC))
			EndIF


			cXML += '	<Receptor>'+ cCRLF
			cXML += '		<DocRecep>'+ cCRLF
			cXML += '			<TipoDocRecep>'+ ALLTRIM(cTpDocRec) +'</TipoDocRecep>'+ cCRLF
			cXML += '			<NroDocRecep>'+ iif(cTpDocRec $ "6",ALLTRIM((cAliasXML)->A2_CGC),"6") +'</NroDocRecep>'+ cCRLF
			cXML += '		</DocRecep>' + cCRLF
			cXML += '		<NmbRecep>' + RTRIM((cAliasXML)->A2_NOME) +'</NmbRecep>'+ cCRLF
			cXML += '		<DomFiscalRcp>'+ cCRLF
			cXML += '			<Calle>'+ (cAliasXML)->A2_END +'</Calle>'+ cCRLF
			cXML += '			<Departamento>'+fGetSX5("12"+(cAliasXML)->A2_EST) + '</Departamento>'+ cCRLF
			cXML += '			<Distrito>' + alltrim((cAliasXML)->A2_BAIRRO) + '</Distrito>'+ cCRLF
			cXML += '			<Ciudad>' + alltrim((cAliasXML)->A2_BAIRRO) + '</Ciudad>'+ cCRLF
			cXML += '			<Municipio>' + alltrim((cAliasXML)->A2_MUN) + '</Municipio>'+ cCRLF
			cXML += '			<Pais>' + fgetPais(ALLTRIM((cAliasXML)->A2_PAIS)) + '</Pais>'+ cCRLF
			cXML += '			<CodigoPostal>' + (cAliasXML)->A2_CEP+ '</CodigoPostal>'+ cCRLF
			cXML += '		</DomFiscalRcp>'+ cCRLF
			cXML += '	</Receptor>'+ cCRLF
			cXML += fgetTrans()
			cMoneda := alltrim(fGetSX5("XQ" + STR((cAliasXML)->F1_MOEDA,2)))
			//Totales
			cXML += '			<Totales>' + cCRLF
			cXML += '				<Moneda>' + cMoneda + '</Moneda>' + cCRLF
			cXML += '				<SubTotal>' 	+  ALLTRIM(TRANSFORM((cAliasXML)->F1_VALMERC,cPict))+ '</SubTotal>' + cCRLF
			cXML += '				<MntDcto>'		+  ALLTRIM(TRANSFORM((cAliasXML)-> F1_DESCONT,cPicPrc)) + '</MntDcto>' + cCRLF
			cXML += '				<VlrPagar>' 	+  ALLTRIM(TRANSFORM((cAliasXML)->F1_VALBRUT,cPict)) + '</VlrPagar>' + cCRLF
			cXML += '				<MontoPropina>0</MontoPropina>' + cCRLF
			cXML += '				<TotSubMonto>'
			cXML += '					<Tipo>01</Tipo>' + cCRLF
			cXML += '					<CodTipoMonto>01</CodTipoMonto>' + cCRLF
			cXML += '					<TasaConcepto>3.00</TasaConcepto>' + cCRLF      // Debe obtenerla de SFB y por la TES
			cXML += '					<MontoBase>'+ ALLTRIM(TRANSFORM(SFE->FE_VALBASE ,cPict))+'</MontoBase>' + cCRLF
			cXML += '					<MontoConcepto>'+ ALLTRIM(TRANSFORM(SFE->FE_VALBASE,cPict)) +'</MontoConcepto>' + cCRLF
			cXML += '				</TotSubMonto>' + cCRLF
			cXML += '			</Totales>' + cCRLF
			cXML += '		</Encabezado>' + cCRLF
			//detalle de la retencion

			// Obtener Detalle de Retenciones
			cEmissao:=	STRZERO(YEAR(SFE->FE_EMISSAO),4)  + "-" +;
						STRZERO(MONTH(SFE->FE_EMISSAO),2) + "-" + ;
						STRZERO(DAY(SFE->FE_EMISSAO),2)

				cXML += '		<Detalle>' + cCRLF
				cXML += '			<NroLinDet>1</NroLinDet>' + cCRLF
				cXML += '			<DscLang>ES</DscLang>' + cCRLF
				cXML += '			<DscItem>Desc</DscItem>' + cCRLF
				cXML += '			<QtyItem>1</QtyItem>' + cCRLF
				cXML += ' 			<FchElabor>' + cEmissao + '</FchElabor>'+ cCRLF
				cXML += ' 			<FchVencim>' + cEmissao + '</FchVencim>'+ cCRLF
				cXML += '			<PrcNetoItem>' + ALLTRIM(TRANSFORM(SFE->FE_VALBASE ,cPict)) +'</PrcNetoItem>' + cCRLF
				cXML += '			<MontoBrutoItem>' + ALLTRIM(TRANSFORM(SFE->FE_VALBASE ,cPict)) +'</MontoBrutoItem>' + cCRLF
				cXML += '			<MontoNetoItem>'+ ALLTRIM(TRANSFORM(SFE->FE_RETENC ,cPict)) +'</MontoNetoItem>' + cCRLF
				cXML += '		</Detalle>' + cCRLF

			nTam := len(alltrim((cAliasXML)->F1_DOC))
			// Datos Documento de Referencia que originó la retención
			cXML += '		<Referencia>' 	+ cCRLF
			cXML += '			<NroLinRef>1</NroLinRef>' + cCRLF
			cXML += '			<TpoDocRef>01</TpoDocRef>' + cCRLF
			cXML += '			<NumeroRef>'	+  Substr(alltrim((cAliasXML)->F1_DOC),nTam-9,8) +'</NumeroRef>' + cCRLF
			cXML += '			<FechaRef>'	+ cFchaEmis + '</FechaRef>' + cCRLF
			cXML += '		</Referencia>'	+ cCRLF

			cXML+= fCAE((cAliasXML)->F1_DOC,cFchaEmis)
			//Fecha y hora en que se generó el documento con formato dd-MM-yyyyTHH:MI:SSZ.
			cXML += '		<TimeStamp>' + cFchaEmis + '</TimeStamp>' + cCRLF
			cXML += '	</Documento>' + cCRLF

			If ExistBlock("M485CRPER") .AND. lDocEx
				cXML += ExecBlock("M485CRPER",.F.,.F.,{(cAliasXML)->F1_FILIAL,cNfiscal,(cAliasXML)->F1_SERIE,(cAliasXML)->F1_ESPECIE,cFornece,cLoja, cNroCert,cSerieCer})
			EndIf

			(cAliasXML)->(dbSkip())
			cXML += '</DTE>'+ cCRLF
		EndDo

		(cAliasXML)->(dbCloseArea())

	RestArea(aArea)

return cXMl


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ getEmisor()| Autor ³ Mayra Camargo       ³ Data ³ 12.01.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera elemento Emisor a partir de datos del sigamat       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ getEmisor()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function getEmisor()
	local cXML			:= ""
	local cRFC		:= RTRIM(SM0->M0_CGC)
	local cNome		:= RTRIM(SM0->M0_NOME)
	local cNomeCom	:= RTRIM(SM0->M0_NOMECOM)
	local cEndent		:= RTRIM(SM0->M0_ENDENT)
	Local cDepto		:= RTRIM(SM0->M0_CIDENT)
	Local cCp			:= RTRIM(SM0->M0_CEPENT)
	Local cPais		:= "PE"//"604" según ISO 3666-1 ADMITIDO POR SUNAT PARA PERÚ DEBE SER PE

	cXML += '		<Emisor>'+ cCRLF
	cXML += '			<TipoContribuyente></TipoContribuyente>'+ cCRLF
	cXML += '			<RegimenContable></RegimenContable>'+ cCRLF
	cXML += '			<IDEmisor>'+ cRFC +'</IDEmisor>'+ cCRLF
	cXML += '			<NmbEmisor>'+ cNome +'</NmbEmisor>'+ cCRLF
	cXML += '			<NombreEmisor>'+ cCRLF
	cXML += '				<PrimerNombre>'+ cNomeCom +'</PrimerNombre>'+ cCRLF
	cXML += '			</NombreEmisor>'+ cCRLF
	cXML += '			<FechaInicioActividades>2016-01-01</FechaInicioActividades>'+ cCRLF
	cXML += '			<DomFiscal>'+ cCRLF
	cXML += '				<Calle>'+ cEndent +'</Calle>'+ cCRLF
	cXML += '				<Departamento>'+ cDepto + '</Departamento>'+ cCRLF
	cXML += '				<Distrito>' + cDepto + '</Distrito>'+ cCRLF
	cXML += '				<Ciudad>' + cDepto + '</Ciudad>'+ cCRLF
	cXML += '				<Municipio>' + cDepto+ '</Municipio>'+ cCRLF
	cXML += '				<Pais>' + cPais + '</Pais>'+ cCRLF
	cXML += '				<CodigoPostal>' + cCP+ '</CodigoPostal>'+ cCRLF
	cXML += '			</DomFiscal>'+ cCRLF
	cXML += '			<LugarExped>'+ cCRLF
	cXML += '				<Calle>'+ cEndent+'</Calle>'+ cCRLF
	cXML += '			</LugarExped>'+ cCRLF
	cXML += '		</Emisor>'+ cCRLF

Return cXML
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fCAE()     ³ Autor ³ Mayra Camargo       ³ Data ³ 12.01.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera elemento CAE                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCAE(ExpN1,Expc2)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 =Número de Fatcura relacionada al documento.         ³±±
±±³          ³ Expd2 = Fecha Emision del documento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fCAE(cDocument,cFechaEmis)
	Local cXML := ""
	cDocument := ALLTRIM(cDocument)
	cXML += '	<CAE>'+ cCRLF
	cXML += '		<Tipo>String</Tipo>'+ cCRLF
	cXML += '		<NumeroInicial>'+ cDocument +'</NumeroInicial>'+ cCRLF
	cXML += '		<NumeroFinal>'+ cDocument +'</NumeroFinal>'+ cCRLF
	cXML += '		<NroResolucion>'+ cDocument +'</NroResolucion>'+ cCRLF
	cXML += '		<FechaResolucion>'+ substr(cFechaEmis,1,10) +'</FechaResolucion>'+ cCRLF
	cXML += '	</CAE>'+ cCRLF

Return cXML

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fGetTrans()³ Autor ³ Mayra Camargo       ³ Data ³ 12.01.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera elemento Transportista                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGetTrans()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGetTrans()
	Local cXML := ""
	cXML += '		<Transporte>'+ cCRLF
	cXML += '			<MedioTransporte>'+ cCRLF
	cXML += '			<MetodoTransp>MetodoTransp</MetodoTransp>'+ cCRLF
	cXML += '			</MedioTransporte>'+ cCRLF
	cXML += '		</Transporte>'+ cCRLF
Return cXML

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fGetSX5    ³ Autor ³ Mayra Camargo       ³ Data ³ 12.01.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene Descripción de item en SX5                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGetSX5(cClave), donde CClave = tabla en SX5               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGetSX5(cClave)
	Local cRet := ""
	cRET := POSICIONE("SX5",1,XFILIAL("SX5")+cClave,"X5_DESCSPA")
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fgetPais   ³ Autor ³ Jonathan Gonzalez   ³ Data ³ 12.01.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene COD PAIS DE iso 3666-1 alfa 2                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fgetPais(cCodPais)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Código del país segun Protheus                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fgetPais(cCodPais)
	Local cCodISO := "PE"

	If cCodPais == "158"
		cCodISO := 'CL'
	ElseIf cCodPais == '493'
		cCodISO := 'MX'
	ElseIf cCodPais == '063'
		cCodISO := 'AR'
	ElseIf cCodPais == '105'
		cCodISO := 'BR'
	ElseIf cCodPais == '169'
		cCodISO := 'CO'
	ElseIf cCodPais == '097'
		cCodISO := 'BO'
	ElseIf cCodPais == '239'
		cCodISO := 'EC'
	ElseIf cCodPais == '249'
		cCodISO := 'US'
	EndIf

Return cCodIso
