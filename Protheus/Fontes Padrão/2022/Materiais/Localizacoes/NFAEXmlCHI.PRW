#include "Protheus.ch"
#include "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪哪哪哪履哪哪哪哪目北
北矲un噮o    砃FAEXmlChi  ?Autor ?Luis Enr韖uez Mata         ?Data ?5/10/2018潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪拇北
北矰escri噮o ?Esta rutina permite generar una cadena de caracteres que          潮?
北?         ?define un XML el cual contiene los datos correspondientes         潮?
北?         ?al documento electronico solicitado (Fact. Venta, Nta debito      潮?
北?         ?y Nta credito) segun el esquema DTE_v1, que sera trasmitido       潮?
北?         ?a TSS para su envio a traves de Signature.                        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砈intaxe   ?NFAEXmlCHI(ExpN1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpN7)             潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?ExpN1 = Tipo de documento 0= Nta Cred. 1= Fact Venta/Nta Deb.     潮?
北?         ?ExpC2 = Serie del documento.                                      潮?
北?         ?ExpC3 = Cod. Cliente / Proveedor.                                 潮?
北?         ?ExpC4 = Codigo de la tiente (Cliente/Proveedor).                  潮?
北?         ?ExpC5 = Numero documento.                                         潮?
北?         ?ExpC6 = Especie de documento (NCC,NDC,NF).                        潮?
北?         ?ExpN7 = Ambte confg. en TSS 1 = Homologacion 2 = Produccion       潮?
北?         ?ExpL8 = Por Referencia si el documento es NF Excenta              潮?
北?         ?ExpL9 = Por referencia, si el documento es de Exportacion         潮?
北?         ?ExpL10= Si el documento es una guia de Despacho                   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?MATA485                                                           潮?
北媚哪哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅rogramador   ?Data   ?BOPS/FNC  ? Motivo da Alteracao                     潮?
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矼.Camargo     ?8.02.19矰MINA-5958 砈e implementa uso de tags OtrMoneda en do-潮?
北?             ?       ?          砪umentos de exportacion cuando moneda es  潮?
北?             ?       ?          砫iferente a pesos chilenos.               潮?
北矼Camargo      ?       ?          砪ompilacion d-1                           潮?
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function NFAEXmlCHI(nTipDoc, cSerie, cCltProv, cTienda, cNumDoc, cEspDoc, nAmbte, lFacExc, lExport,lGDesp, cTpMod)
	Local aArea		:= GetArea()
	Local cCRLF		:= (chr(13)+chr(10) )
	Local cXML		:= ''
	Local aImp		:= {}
	Local aImpDet	:= {}
	Local aExtImp 	:= {}
	Local nA		:= 0
	Local nC		:= 0
	Local cFchaEmis := ""
	Local cDocument := ""
	Local cDocRef   := ""
	Local cDocum    := ""
	Local cMotivo   := ""
	Local cTipoRef	:= ""	
	Local cEspecie  := ""
	Local nValor    := 0
	Local nDesc     := 0 

	//emisor
	Local cFecPago	:= ""
	Local cModVen	:= '0'
	
	// Var PE 
	Local cDocPe	:= ""
	Local cSerPE    := ""
	Local cFilPE    := ""
	Local cCliPe	:= ""
	Local cLojPe	:= ""
	Local cEspPE	:= ""
	
	//Variables Query
	Local cCposQuery  := ""
	Local cCposFrom	  := ""
	Local cWhere	  := ""
	Local cAliasXML	  := "QRYXML"
	Local nUnit		  := 0
	Local nFlete      := 0
	Local nSeguro	  := 0
	Local nGasto	  := 0
	Local cRef		  := ""
	Local cEspRef	  := ""
	Local cTESExc	  := getMV("MV_TESEXE",,"") // TES para factura Excenta
	Local cSERBol	  := getMV("MV_SERBV",,"")  // Series utilizadas para Boleta de Venta
	Local lBolVent	  := .F. // Indicar?si el documento se trata de una boleta de Venta 
	Local cTpDoc	  := ""
	Local lDocExp	  := .F.
	Local cRUTEx	  := "555555555"
	Local aRef		  := {}
	Local nPos		  := 0
	Local nL		  := 0
	
	Default lFacExc   := .F.
	Default lGDesp 	  := .F.
	Default cTpMod	  := IIF(Valtype(cModelo) <> "U" ,cModelo ,"")
	
	Private nTamDoc := TamSX3("F1_DOC")[1]
	Private cfilSF1	:= xfilial("SF1")
	Private cFilSD1	:= xfilial("SD1")
	Private cFilSF2	:= xfilial("SF2")
	Private cFilSD2	:= xfilial("SD2")
	Private cFilSFB	:= xfilial("SFB")
	Private cFilSB1	:= xfilial("SB1")
	Private cFilSA1	:= xfilial("SA1")
	Private cFilSFC	:= xfilial("SFC")
	Private cFilSF4	:= xfilial("SF4")
	Private cFilCTO	:= xfilial("CTO")
	Private cFilSYA	:= xfilial("SYA")
	Private cPict	:= "99999999999999.99"

	If(nTipDoc <= 0) //Documentos Nota de Credito / gu韆 Despacho
	
		cCposQuery := "% SF1.F1_FILIAL, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_ESPECIE, SF1.F1_SERIE, SF1.F1_DOC, SF1.F1_EMISSAO, SF1.F1_HORA, SF1.F1_MOEDA, SF1.F1_TXMOEDA," //querry para las notas credito
		cCposQuery += "  SF1.F1_VALMERC, SF1.F1_DESCONT, SF1.F1_VALBRUT, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_CEP, SA1.A1_CGC,SA1.A1_BAIRRO, SB1.B1_UM, "
		cCposQuery += "  SB1.B1_COD, SB1.B1_DESC, SD1.D1_ITEM, SD1.D1_QUANT, SD1.D1_TOTAL, SD1.D1_VUNIT, SD1.D1_DESC, SD1.D1_TES, SD1.D1_NFORI, "
		cCposQuery += "  SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SF1.F1_TIPO, SYA.YA_DESCR, SF1.F1_COND, " //  CTO.CTO_SIMB,
		cCposQuery += "  SF1.F1_MOTIVO,SA1.A1_TIPDOC, SA1.A1_CEP, SD1.D1_VALDESC, SD1.D1_SERIORI,SF1.F1_FRETE, SF1.F1_DESPESA, SF1.F1_SEGURO, SF1.F1_COND, SF1.F1_TIPREF, SF1.F1_DUPL, SA1.A1_GIRO, SA1.A1_EST  %"	
			
		cCposFrom	:= "% " + RetSqlName("SF1") + " SF1, "
		cCposFrom	+= RetSqlName("SD1")+ " SD1, "
		cCposFrom	+= RetSqlName("SA1")+ " SA1, "
		cCposFrom	+= RetSqlName("SYA")+ " SYA, "
		cCposFrom	+= RetSqlName("SB1")+ " SB1 %"
	
		cWhere		:= "% SF1.F1_FORNECE = '"+ cCltProv +"' AND SF1.F1_LOJA = '"+ cTienda +"' AND SF1.F1_SERIE = '"+ cSerie +"'   "
		cWhere		+= "  AND SF1.F1_DOC = '"+ cNumDoc +"' AND SF1.F1_ESPECIE = '"+ cEspDoc +"' AND SF1.F1_FORNECE = SD1.D1_FORNECE   "
		cWhere 	+= "  AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_DOC = SD1.D1_DOC AND SA1.A1_COD = SF1.F1_FORNECE "
		cWhere 	+= "  AND SA1.A1_LOJA = SF1.F1_LOJA AND SF1.F1_ESPECIE = SD1.D1_ESPECIE AND SB1.B1_COD = SD1.D1_COD " 
		cWhere		+= "  AND SYA.YA_CODGI = SA1.A1_PAIS "
	
		cWhere		+= " AND SF1.F1_FILIAL = '"+cfilSF1+"'"
		cWhere		+= " AND SD1.D1_FILIAL = '"+cFilSD1+"'"
		cWhere		+= " AND SA1.A1_FILIAL = '"+cFilSA1+"                                                                                                                                                                 '"
		cWhere		+= " AND SYA.YA_FILIAL = '"+cFilSYA+"'"
		cWhere		+= " AND SB1.B1_FILIAL = '"+cFilSB1+"'"
	
		If ( TcSrvType()=="AS/400" )
			cWhere		+="     AND SF1.@DELETED@  = ' ' "
			cWhere		+="		 AND SD1.@DELETED@  = ' ' "
			cWhere		+="		 AND SA1.@DELETED@  = ' ' "
			cWhere		+="		 AND SYA.@DELETED@  = ' ' "
			cWhere		+="     AND SB1.@DELETED@  = ' ' %"
		ELSE
			cWhere		+="     AND SF1.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SD1.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SA1.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SYA.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SB1.D_E_L_E_T_  = ' ' %"
		ENDIF
	
		BeginSql alias cAliasXML
			SELECT %exp:cCposQuery%
			FROM  %exp:cCposFrom%
			WHERE %exp:cWhere%
		EndSql
	
		TCSetField(cAliasXML,"F1_EMISSAO","D") //Los campos tipo fecha se quedan como tipo fecha, pues por query son recuperados como string
	
		dbSelectArea(cAliasXML)
		
		(cAliasXML)->(DbGoTop())
		
		While (cAliasXML )->(!Eof())
		
			cFchaEmis := 	SUBSTR(DTOS((cAliasXML)->F1_EMISSAO),0,4) + "-" +;
							SUBSTR(DTOS((cAliasXML)->F1_EMISSAO),5,2) + "-" +;
							SUBSTR(DTOS((cAliasXML)->F1_EMISSAO),7,2) + "T" +(cAliasXML)->F1_HORA+"Z"
			cDocum      := strZero(VAL((cAliasXML)->F1_DOC),10)
			cDocument 	:= (cAliasXML)->F1_DOC
			cTipoRef	:= (cAliasXML)->F1_TIPREF
			cFecPago 	:= fGetSE1((cAliasXML)->F1_DUPL,(cAliasXML)->F1_SERIE,(cAliasXML)->F1_ESPECIE)
			nDesc	  	:= (cAliasXML)->F1_DESCONT
			nFlete		:= (cAliasXML)->F1_FRETE
			nGasto		:= (cAliasXML)->F1_DESPESA
			nSeguro	    := (cAliasXML)->F1_SEGURO
			
			// Utilizadas Puntos de Entrada
			cDocPe := (cAliasXML)->F1_DOC
			cSerPE := (cAliasXML)->F1_SERIE
			cFilPE := (cAliasXML)->F1_FILIAL
			cCliPe := (cAliasXML)->F1_FORNECE
			cLojPe := (cAliasXML)->F1_LOJA
			cEspPE := (cAliasXML)->F1_ESPECIE
			
			If Alltrim(cEspDoc) $ "NCC"
				cTpDoc := "61"
				If ExistBlock("M485DOCEXP")
					lDocExp := ExecBlock("M485DOCEXP",.F.,.F.,{(cAliasXML)->F1_FILIAL,(cAliasXML)->F1_DOC,(cAliasXML)->F1_SERIE,(cAliasXML)->F1_ESPECIE,(cAliasXML)->F1_FORNECE,(cAliasXML)->F1_LOJA})
					If lDocExp 
						If Alltrim((cAliasXML)->F1_ESPECIE)=="NCC"
							cTpDoc := "112"
						EndIf
					EndIf
				EndIf
				lExport := lDocExp
			EndIf
			
			cXML := '<?xml version="1.0" encoding="iso-8859-1"?>' + cCRLF
			cXML += '<DTE version="1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="DTE_v1.0.xsd">'+ cCRLF
			cXML += '<Documento ID="comprobante">'+ cCRLF
			cXML += '	<Encabezado>'+ cCRLF
		
			cXML += '		<IdDoc>'+ cCRLF
			cXML += '			<Ambiente>'+ if(nAmbte == 1,"2","1")+'</Ambiente>'+ cCRLF
			cXML += '			<TipoEmision>N</TipoEmision>'+ cCRLF
			cXML += '			<ContenidoTC></ContenidoTC>'+ cCRLF
			cXML += '			<Tipo>' + cTpDoc+ '</Tipo>'+ cCRLF
			cXML += '			<Serie>'+ Alltrim((cAliasXML)->F1_SERIE) +'</Serie>'+ cCRLF
			cXML += '			<Numero>' + Alltrim(str(val((cAliasXML)->F1_DOC))) + '</Numero>'+ cCRLF
			cXML += '			<Estado>ORIGINAL</Estado>'+ cCRLF
			cXML += '			<NumeroInterno>' + Alltrim(substr((cAliasXML)->F1_DOC,(nTamDoc-8),9)) + '</NumeroInterno>'+ cCRLF					
			cXML += '			<FechaEmis>'+ cFchaEmis +'</FechaEmis>'+ cCRLF
			If Alltrim(cEspDoc) $ "NCC"
				cXML += '			<FechaPago>'+ cFecPago +'</FechaPago>'+ cCRLF
			EndIf
			cXML += '		</IdDoc>'+ cCRLF
		
			cXML += getEmisor()
						
			cXML += '		<Receptor>'+ cCRLF
			cXML += '			<DocRecep>'+ cCRLF
			cXML += '				<TipoDocRecep>'+ Alltrim((cAliasXML)->A1_TIPDOC) +'</TipoDocRecep>'+ cCRLF
			
			If ((cAliasXML)->A1_EST) <> "EX"
				cXML += '				<NroDocRecep>'+ TRANSFORM(Alltrim((cAliasXML)->A1_CGC), "@R XX999999-X") +'</NroDocRecep>'+ cCRLF
			Else
				cXML += '				<NroDocRecep>'+ TRANSFORM(Alltrim(cRUTEx), "@R XX999999-X") +'</NroDocRecep>'+ cCRLF				
			EndIf
			cXML += '			</DocRecep>'+ cCRLF
			cXML += '			<NmbRecep><![CDATA['+ RTRIM((cAliasXML)->A1_NOME) +']]></NmbRecep>'+ cCRLF
			cXML += '			<NombreRecep>' + cCRLF
			cXML += '				<PrimerNombre>'+ RTRIM((cAliasXML)->A1_GIRO) +'</PrimerNombre>'+ cCRLF
			cXML += '			</NombreRecep>'+ cCRLF
			cXml += '			<DomFiscalRcp>' + cCRLF
     	    cXml += '				<Calle><![CDATA[' + Alltrim( (cAliasXML)->A1_END) + ']]></Calle>'  + cCRLF     	   
			cXML += '				<Ciudad><![CDATA[' + Alltrim( (cAliasXML)->A1_MUN) + ']]></Ciudad>' + cCRLF
         	cXML += '				<Municipio><![CDATA[' + Alltrim( (cAliasXML)->A1_BAIRRO) + ']]></Municipio>' + cCRLF
			cXML += '				<Pais>' + Alltrim((cAliasXML)->YA_DESCR) + '</Pais>' + cCRLF
			cXML += '				<CodigoPostal>' + Alltrim((cAliasXML)->A1_CEP) + '</CodigoPostal>' + cCRLF
   			cXML += '			</DomFiscalRcp>'	+ cCRLF	
   			cXml += '			<LugarRecep>' + cCRLF
     	    cXml += '				<Calle><![CDATA[' + Alltrim((cAliasXML)->A1_END) + ']]></Calle>'  + cCRLF     	   
			cXML += '				<Ciudad><![CDATA[' + Alltrim( (cAliasXML)->A1_MUN) + ']]></Ciudad>' + cCRLF
          	cXML +=	'				<Municipio><![CDATA[' + Alltrim( (cAliasXML)->A1_BAIRRO) + ']]></Municipio>' + cCRLF
			cXML += '				<Pais>' + Alltrim((cAliasXML)->YA_DESCR) + '</Pais>' + cCRLF
   			cXML += '			</LugarRecep>'	+ cCRLF		 
			cXML += '		</Receptor>'+ cCRLF
			
			cXML += fgetTrans()		
			
			cXML += '		<Totales>'+ cCRLF
			If lDocExp 
				cXML += '			<Moneda>'+ getMoeda((cAliasXML)->F1_MOEDA)+'</Moneda>'+ cCRLF	
			EndIf
			cXML += '			<SubTotal>'+ Alltrim(TRANSFORM((cAliasXML)->F1_VALMERC - (cAliasXML)->F1_DESCONT,cPict)) +'</SubTotal>'+ cCRLF
			cXML += '			<MntDcto>'+ Alltrim(STR((cAliasXML)->F1_DESCONT)) +'</MntDcto>'+ cCRLF
			cXML += '			<MntBase>' +  Alltrim(TRANSFORM((cAliasXML)->F1_VALMERC,cPict)) + '</MntBase>'+ cCRLF
			cXML += '			<VlrPagar>'+ Alltrim(TRANSFORM((cAliasXML)->F1_VALBRUT,cPict)) +'</VlrPagar>'+ cCRLF
			cXML += '			<VlrPalabras>' + EXTENSO((cAliasXML)->F1_VALBRUT,,(cAliasXML)->F1_MOEDA) + '</VlrPalabras>' + cCRLF
			cXML += '			<MontoPropina>0.00</MontoPropina>'+ cCRLF
			cXML += '		</Totales>'+ cCRLF
			
			aImp := NFAEXmlImp(nTipDoc,(cAliasXML)->F1_DOC + (cAliasXML)->F1_SERIE + (cAliasXML)->F1_FORNECE + (cAliasXML)->F1_LOJA + (cAliasXML)->F1_TIPO)
			
			cDocR := (cAliasXML)->F1_DOC
			cSerR := (cAliasXML)->F1_SERIE
			cProvR:= (cAliasXML)->F1_FORNECE
			cLojR := (cAliasXML)->F1_LOJA
			cEspR := (cAliasXML)->F1_ESPECIE
			 
			For nA:=1 To Len(aImp)
				cXML += '		<Impuestos>'+ cCRLF
				cXML += '			<TipoImp>'+ aImp[Na][2] +'</TipoImp>'+ cCRLF
				cXML += '			<CodTasamp>'+ Alltrim(Str(val(aImp[Na][3]))) +'</CodTasamp>'+ cCRLF
				cXML += '			<TasaImp>'+ Alltrim(aImp[Na][1]) +'</TasaImp>'+ cCRLF
				cXML += '			<MontoBAseImp>'+ Alltrim(aImp[Na][4]) +'</MontoBAseImp>'+ cCRLF
				cXML += '			<MontoImp>'+ Alltrim(aImp[Na][5]) +'</MontoImp>'+ cCRLF
				cXML += '		</Impuestos>'+ cCRLF
			Next
			// Otras monedas
			If lDocExp .and. getMoeda((cAliasXML)->F1_MOEDA) <> "CL"
				cXML += '		<OtraMoneda>'+ cCRLF
				cXML += '			<TpoMoneda>PESO CL</TpoMoneda>'+ cCRLF
				cXML += '			<TpoCambio>'+ alltrim(TRANSFORM((cAliasXML)->F1_TXMOEDA,"9999.999999")) +'</TpoCambio>'+ cCRLF
				cXML += '			<MntExeOtrMnda>'+ Alltrim(TRANSFORM((cAliasXML)->F1_VALBRUT * (cAliasXML)->F1_TXMOEDA ,cPict)) +'</MntExeOtrMnda>'+ cCRLF
				cXML += '			<MntTotOtrMnda>'+ Alltrim(TRANSFORM((cAliasXML)->F1_VALBRUT * (cAliasXML)->F1_TXMOEDA ,cPict)) +'</MntTotOtrMnda>'+ cCRLF
				cXML += '		</OtraMoneda>'+ cCRLF
			EndIf	
			
			// Descuentos Globales
			cXML += fGenDscGbl(nDesc,nFlete,nGasto,nSeguro)		
			cXML += '	</Encabezado>'+ cCRLF
			cMotivo := Alltrim((cAliasXML)->F1_MOTIVO)
			While (cAliasXML)->(!Eof()) .and. cSerie ==(cAliasXML)->F1_SERIE .AND. cNumDoc ==(cAliasXML)->F1_DOC .AND. cEspDoc == ALLTRIM((cAliasXML)->F1_ESPECIE)
				
				nUnit := ((cAliasXML)->D1_TOTAL - (cAliasXML)->D1_VALDESC)//(cAliasXML)->D1_QUANT
				cXML += '	<Detalle>'+ cCRLF
				cXML += '		<NroLinDet>'+ (cAliasXML)->D1_ITEM +'</NroLinDet>'+ cCRLF
				cXML += '		<CdgItem>'+ cCRLF
				cXML += '			<TpoCodigo>'+ (cAliasXML)->B1_UM +'</TpoCodigo>'+ cCRLF
				cXML += '			<VlrCodigo>'+ (cAliasXML)->B1_COD +'</VlrCodigo>'+ cCRLF
				cXML += '		</CdgItem>'+ cCRLF
				cXML += '		<DscLang>ES</DscLang>'+ cCRLF
				cXML += '		<DscItem><![CDATA['+ Alltrim((cAliasXML)->B1_DESC) +']]></DscItem>'+ cCRLF
				cXML += '		<QtyItem>'+ Alltrim(TRANSFORM((cAliasXML)->D1_QUANT,cPict)) +'</QtyItem>'+ cCRLF
				cXML += '		<PrcNetoItem>'+ Alltrim(TRANSFORM((cAliasXML)->D1_VUNIT,cPict)) +'</PrcNetoItem>'+ cCRLF
				cXML += '		<DescuentoMonto>'+ Alltrim(TRANSFORM((cAliasXML)->D1_VALDESC,cPict)) +'</DescuentoMonto>'+ cCRLF		
				cDocRef := (cAliasXML)->D1_NFORI
				If ! Empty(cDocRef)
					cDocR := (cAliasXML)->D1_NFORI
					cSerR := (cAliasXML)->D1_SERIORI
					cProvR:= (cAliasXML)->F1_FORNECE
					cLojR := (cAliasXML)->F1_LOJA
					cEspR := (cAliasXML)->F1_ESPECIE
				EndIf
				
				aImpDet := NFAEDetImp(nTipDoc,(cAliasXML)->D1_DOC+(cAliasXML)->D1_SERIE+(cAliasXML)->D1_FORNECE+(cAliasXML)->D1_LOJA+(cAliasXML)->D1_COD+(cAliasXML)->D1_ITEM)
				For nC:=1 To Len(aImpDet)
					aExtImp := ExtImp(aImpDet[nC][1], (cAliasXML)->D1_TES)
					If Len(aExtImp) > 0
						cXML += '		<ImpuestosDet>'+ cCRLF
						cXML += '			<TipoImp>'                                                                                                                                                                                           + aExtImp[1][3] +'</TipoImp>'+ cCRLF
						cXML += '			<TasaImp>'+ Alltrim(aImpDet[nC][2]) +'</TasaImp>'+ cCRLF
						cXML += '			<MontoBaseImp>'+ Alltrim(aImpDet[nC][3]) +'</MontoBaseImp>'+ cCRLF
						cXML += '			<MontoImp>'+ Alltrim(aImpDet[nC][4]) +'</MontoImp>'+ cCRLF
						cXML += '		</ImpuestosDet>'+ cCRLF
					EndIf
				Next
				
				cXML += '		<MontoNetoItem>'+ Alltrim(TRANSFORM(nUnit,cPict)) +'</MontoNetoItem>'+ cCRLF				
				cXML += '	</Detalle>'+ cCRLF			
				
				If Len(aRef)>0
					nPos :=  aScan(aRef, { |x,y| x[1] == cDocR .and. x[2] == cSerR })				
				EndIf
				
				If nPos == 0 					
					AADD(aRef,{cDocR,cSerR,cProvR,cLojR,cEspR,.F.,cMotivo,cTipoRef,"NF",lDocExp,ALLTRIM(cSerR) $ cSERBol,(cAliasXML)->D1_TES$cTESExc})
				EndIf
				(cAliasXML)->(dbskip())
			EndDo
							
			// Elemento Referencia
			
			For nL := 1 To Len(aRef)
					cRef += getRef(aRef[nL,1],aRef[nL,2],aRef[nL,3],aRef[nL,4],aRef[nL,5],.F.,aRef[nL,7],aRef[nL,8],aRef[nL,9],aRef[nL,10],nL,aRef[nL,11])
					If Len(cRef) == 0
						cRef += getRef(aRef[nL,1],aRef[nL,2],aRef[nL,3],aRef[nL,4],aRef[nL,5],.T.,aRef[nL,7],aRef[nL,8],aRef[nL,9],aRef[nL,10],nL,aRef[nL,11])				
					EndIf
			Next nL

			cXml += cRef
			cXML += fCAE(cDocument,cFchaEmis)		
			cXML += '		<TimeStamp>'+ cFchaEmis +'</TimeStamp>'+ cCRLF
			cXML += '	</Documento>'+ cCRLF
			// Punto de Entrada para agregar campos personalizados Noda de Cr閐ito.
			If ExistBlock("M485NCC") .AND. Alltrim(cEspDoc) $ "NCC"
				cXML += ExecBlock("M485NCC",.F.,.F.,{cFilPE,cDocPE,cSerPE,cEspPE,cCliPe,cLojPE})
			EndIf
			cXML += '</DTE>'+ cCRLF
		EndDo		
		(cAliasXML)->(dbCloseArea())
	
	Else //Documentos de Factura de Venta/Nota de Debito
	
		cCposQuery := "% SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SF2.F2_HORA, SF2.F2_MOEDA,SF2.F2_NFREF,SF2.F2_SERREF,SF2.F2_TXMOEDA, " //querry para las notas debitos y facturas de venta.
		cCposQuery += "  SF2.F2_VALMERC, SF2.F2_DESCONT, SF2.F2_VALBRUT, SF2.F2_MOTIVO, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_CEP, SA1.A1_CGC,SA1.A1_BAIRRO, SD2.D2_ITEM, "
		cCposQuery += "  SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_DESC, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_NFORI, SD2.D2_LOJA, "
		cCposQuery += "  SD2.D2_COD, SD2.D2_TES, SB1.B1_UM, SB1.B1_COD, SB1.B1_DESC, SYA.YA_DESCR, A1_PAIS, SF2.F2_VALFAT, SF2.F2_MODVEN, " 		
		cCposQuery += "  SA1.A1_TIPDOC, SD2.D2_DESCON, SF2.F2_FRETE, SF2.F2_DESPESA, SF2.F2_SEGURO, SF2.F2_COND, SF2.F2_TIPREF,SF2.F2_ESPREF, SF2.F2_DUPL, SA1.A1_GIRO, SA1.A1_EST %"
		
		cCposFrom	:= "% " + RetSqlName("SF2") + " SF2, "
		cCposFrom	+= RetSqlName("SD2")+ " SD2, "
		cCposFrom	+= RetSqlName("SA1")+ " SA1, "
		cCposFrom	+= RetSqlName("SYA")+ " SYA, "
		cCposFrom	+= RetSqlName("SB1")+ " SB1 %"
	
		cWhere		:= "% SF2.F2_SERIE = '"+ cSerie +"' AND SF2.F2_DOC = '"+ cNumDoc +"' AND SF2.F2_CLIENTE = '"+ cCltProv +"' "
		cWhere		+= "  AND SF2.F2_LOJA = '"+ cTienda +"' AND SF2.F2_ESPECIE = '"+ cEspDoc +"' AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
		cWhere 	+= "  AND SF2.F2_LOJA = SD2.D2_LOJA AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_DOC = SD2.D2_DOC "
		cWhere 	+= "  AND SF2.F2_ESPECIE = SD2.D2_ESPECIE AND SB1.B1_COD = SD2.D2_COD AND SA1.A1_COD = SF2.F2_CLIENTE "
		cWhere 	+= "  AND SA1.A1_LOJA = SF2.F2_LOJA AND  SYA.YA_CODGI = SA1.A1_PAIS " 
	
		cWhere		+= " AND SF2.F2_FILIAL = '"+cFilSF2+"'"
		cWhere		+= " AND SD2.D2_FILIAL = '"+cFilSD2+"'"
		cWhere		+= " AND SA1.A1_FILIAL = '"+cFilSA1+"'"
		cWhere		+= " AND SB1.B1_FILIAL = '"+cFilSB1+"'"
		cWhere		+= " AND SYA.YA_FILIAL = '"+cFilSYA+"'"
	
		If ( TcSrvType()=="AS/400" )
			cWhere		+="		 AND SD2.@DELETED@  = ' ' "
			cWhere		+="     AND SF2.@DELETED@  = ' ' "
			cWhere		+="		 AND SA1.@DELETED@  = ' ' "
			cWhere		+="		 AND SYA.@DELETED@  = ' ' "
			cWhere		+="     AND SB1.@DELETED@  = ' ' %"
		Else
			cWhere		+="     AND SD2.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SF2.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SA1.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SYA.D_E_L_E_T_  = ' ' "
			cWhere		+="     AND SB1.D_E_L_E_T_  = ' ' %"
		EndIf
	
		BeginSql alias cAliasXML
			SELECT %exp:cCposQuery%
			FROM  %exp:cCposFrom%
			WHERE %exp:cWhere%
			ORDER BY SD2.D2_ITEM
		EndSql
	
		TCSetField(cAliasXML,"F2_EMISSAO","D")
	
		dbSelectArea(cAliasXML)
		
		(cAliasXML)->(DbGoTop())
		
		While (cAliasXML )->(!Eof())
		
			cFchaEmis   := SUBSTR(DTOS((cAliasXML)->F2_EMISSAO),0,4) + "-" +;
		             	SUBSTR(DTOS((cAliasXML)->F2_EMISSAO),5,2) + "-" +;
		             	SUBSTR(DTOS((cAliasXML)->F2_EMISSAO),7,2) + "T" +(cAliasXML)->F2_HORA+":00Z"
			
			cDocum      := Alltrim(substr((cAliasXML)->F2_DOC,(nTamDoc-8),9))
			cDocument	:= Alltrim((cAliasXML)->F2_DOC)
			cEspecie 	:= Alltrim((cAliasXML)->F2_ESPECIE)
			nDesc	  	:= (cAliasXML)->F2_DESCONT
			nFlete		:= (cAliasXML)->F2_FRETE
			nGasto		:= (cAliasXML)->F2_DESPESA
			nSeguro	    := (cAliasXML)->F2_SEGURO		
			nValor 	    := (cAliasXML)->F2_VALMERC			
			cFecPago 	:= IIF(!lGDesp,fGetSE1((cAliasXML)->F2_DUPL,(cAliasXML)->F2_SERIE,(cAliasXML)->F2_ESPECIE), Substr(cFchaEmis,1,10))
			cDocR 		:= (cAliasXML)->F2_NFREF
			cSerR 		:= (cAliasXML)->F2_SERREF
			cProvR		:= (cAliasXML)->F2_CLIENTE
			cLojR 		:= (cAliasXML)->F2_LOJA
			cEspR 		:= (cAliasXML)->F2_ESPECIE
			cFormaPag	:= getFrmPago((cAliasXML)->F2_COND,(cAliasXML)->F2_FILIAL,(cAliasXML)->F2_DOC,(cAliasXML)->F2_SERIE,(cAliasXML)->F2_ESPECIE,(cAliasXML)->F2_CLIENTE,(cAliasXML)->F2_LOJA)
			cEspRef	    := (cAliasXML)->F2_ESPREF
			cTipoRef 	:= (cAliasXML)->F2_TIPREF
			lFacExc 	:= IIf((cAliasXML)->D2_TES $ cTESExc, .T., .F.)
			lBolVent	:= IIf(ALLTRIM((cAliasXML)->F2_SERIE) $ cSERBol .and. Alltrim((cAliasXML)->F2_ESPECIE)=="NF" , .T., .F.) // Indica si el documento es una boleta de Venta
			cModVen 	:= 	(cAliasXML)->F2_MODVEN		
			
			If !lBolVent
			cTpDoc		:= IIf(Alltrim((cAliasXML)->F2_ESPECIE)=="NF",;
								IIf(lFacExc,"34", "33" ),;
								IIf(Alltrim((cAliasXML)->F2_ESPECIE)=="NDC","56",""))
			Else				
				// Si es boleta de Venta, se evaluar?si es afecta o no para indicar modelo
				cTpDoc	:= IIf(lFacExc,"41","39") // 38 - Boleta Exenta Electr髇ica 39 - Boleta Electr髇ica
				cTpMod	:= IIF(lFacExc, "SG","SF")
			EndIf
														
			// Utilizadas Puntos de Entrada
			cDocPe	:= (cAliasXML)->F2_DOC
			cSerPE 	:= (cAliasXML)->F2_SERIE
			cFilPE 	:= (cAliasXML)->F2_FILIAL
			cCliPe	:= (cAliasXML)->F2_CLIENTE
			cLojPe	:= (cAliasXML)->F2_LOJA
			cEspPE	:= (cAliasXML)->F2_ESPECIE
			
			/*	Punto entrada para evaluar si es un documento de exportaci髇
				No aplica para Guias de Despacho ya que por Ley la gu韆 de Despacho debe ser solo Nacional.
			*/
			If ExistBlock("M485DOCEXP") .and. !lGDesp
				lDocExp := ExecBlock("M485DOCEXP",.F.,.F.,{(cAliasXML)->F2_FILIAL,(cAliasXML)->F2_DOC,(cAliasXML)->F2_SERIE,(cAliasXML)->F2_ESPECIE,(cAliasXML)->F2_CLIENTE,(cAliasXML)->F2_LOJA})
				If lDocExp 
					If Alltrim((cAliasXML)->F2_ESPECIE)=="NF"
						cTpDoc := "110"
					Else
						cTpDoc := "111"
					EndIf
				EndIf		 	
			EndIf
			lExport := lDocExp
			
			If lGDesp
				cTpDoc := "52"
			EndIf
						
			cXML := '<?xml version="1.0" encoding="iso-8859-1"?>' + cCRLF
			cXML += '<DTE version="1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="DTE_v1.0.xsd">'+ cCRLF
			cXML += '<Documento ID="comprobante">'+ cCRLF
			cXML += '	<Encabezado>'+ cCRLF
		
			cXML += '		<IdDoc>'+ cCRLF
			cXML += '			<Ambiente>'+ if(nAmbte == 1,"2","1")+'</Ambiente>'+ cCRLF
			cXML += '			<TipoEmision>N</TipoEmision>'+ cCRLF // N= NORMAL T= TICKET
			cXML += '			<ContenidoTC></ContenidoTC>'+ cCRLF
			cXML += '			<Tipo>'+ cTpDoc +'</Tipo>'+ cCRLF
			cXML += '			<Serie>'+ Alltrim((cAliasXML)->F2_SERIE) +'</Serie>'+ cCRLF
			cXML += '			<Numero>' + Alltrim(str(val((cAliasXML)->F2_DOC))) + '</Numero>'+ cCRLF
			cXML += '			<Estado>ORIGINAL</Estado>'+ cCRLF
			cXML += '			<NumeroInterno>' + Alltrim(substr((cAliasXML)->F2_DOC,(nTamDoc-8),9)) + '</NumeroInterno>'+ cCRLF
			cXML += '			<FechaEmis>' + cFchaEmis + '</FechaEmis>'+ cCRLF		
			cXML += '			<FormaPago>' + cFormaPag + '</FormaPago>' + cCRLF
			cXML += '			<FechaVenc>' + cFecPago + '</FechaVenc>' + cCRLF
			cXML += '			<FechaPago>' + cFecPago + '</FechaPago>'+ cCRLF
			cXML += '		</IdDoc>'+ cCRLF
		
			cXML += getEmisor()
			cXML += '		<Receptor>'+ cCRLF
			cXML += '			<DocRecep>'+ cCRLF
			cXML += '				<TipoDocRecep>'+ Alltrim((cAliasXML)->A1_TIPDOC) +'</TipoDocRecep>'+ cCRLF
		
			If (cAliasXML)->A1_EST <> "EX"
				cXML += '				<NroDocRecep>'+ TRANSFORM(Alltrim((cAliasXML)->A1_CGC), "@R XX999999-X") +'</NroDocRecep>'+ cCRLF
			Else // Si el cliente es extranjero, debe ponerse un rut universal 55555555-5
				cXML += '				<NroDocRecep>'+ TRANSFORM(Alltrim(cRUTEx), "@R XX999999-X") +'</NroDocRecep>'+ cCRLF
				If lGDesp
					lDocExp := .t.
				EndIf				
			EndIf
			cXML += '			</DocRecep>'+ cCRLF
			cXML += '			<NmbRecep><![CDATA['+ RTRIM((cAliasXML)->A1_NOME) +']]></NmbRecep>'+ cCRLF
			cXML += '				<NombreRecep>' + cCRLF
			cXML += '				<PrimerNombre>'+ RTRIM((cAliasXML)->A1_GIRO) +'</PrimerNombre>'+ cCRLF
			cXML += '			</NombreRecep>'+ cCRLF
			cXML += '			<CodigoReceptor>' + cCRLF
			cXML += '				<TpoCdgIntRecep>' + SA1->A1_COD + '</TpoCdgIntRecep>' + cCRLF
			cXML += '			</CodigoReceptor>' + cCRLF
			cXml += '			<DomFiscalRcp>' + cCRLF
     	   	cXml += '				<Calle><![CDATA[' + Alltrim((cAliasXML)->A1_END) + ']]></Calle>'  + cCRLF
     	   	cXML += '				<Ciudad><![CDATA[' + Alltrim( (cAliasXML)->A1_MUN) + ']]></Ciudad>' + cCRLF
          	cXML +=	'				<Municipio><![CDATA[' + Alltrim( (cAliasXML)->A1_BAIRRO) + ']]></Municipio>' + cCRLF
	       cXml +=	'				<Pais>' + Alltrim(POSICIONE("SYA",1,XFILIAL("SYA") + (cAliasXML)->A1_PAIS, "YA_DESCR")) + '</Pais>'  + cCRLF
          	cXML +=	'				<CodigoPostal>' + Alltrim((cAliasXML)->A1_CEP) + '</CodigoPostal>'+ cCRLF
   			cXML += '			</DomFiscalRcp>'	+ cCRLF
   			cXML += '			<LugarRecep>' + cCRLF
   			cXml += '				<Calle><![CDATA[' + Alltrim((cAliasXML)->A1_END) + ']]></Calle>'  + cCRLF
   			cXML += '				<Ciudad><![CDATA[' + Alltrim( (cAliasXML)->A1_MUN) + ']]></Ciudad>' + cCRLF
          	cXML +=	'				<Municipio><![CDATA[' + Alltrim( (cAliasXML)->A1_BAIRRO) + ']]></Municipio>' + cCRLF
	       cXml +=	'				<Pais>' + Alltrim(POSICIONE("SYA",1,XFILIAL("SYA") + (cAliasXML)->A1_PAIS, "YA_DESCR")) + '</Pais>'  + cCRLF
          	cXML +=	'				<CodigoPostal>' + Alltrim((cAliasXML)->A1_CEP) + '</CodigoPostal>'+ cCRLF
   			cXML += '			</LugarRecep>' + cCRLF
			cXML += '		</Receptor>'+ cCRLF
			// Nodo Transportista
			If ExistBlock("M485TRANS") .and. lGDesp .and. lDocExp
				//PE por si el ciente requiere enviar datos del transportista
				cXML += ExecBlock("M485TRANS",.F.,.F.,{(cAliasXML)->F2_FILIAL,(cAliasXML)->F2_DOC,(cAliasXML)->F2_SERIE,(cAliasXML)->F2_ESPECIE,(cAliasXML)->F2_CLIENTE,(cAliasXML)->F2_LOJA})
			Else
				cXML += fgetTrans()		
			EndIf
						
			cXML += '		<Totales>'+ cCRLF
			If lDocExp 
				cXML += '			<Moneda>'+ getMoeda((cAliasXML)->F2_MOEDA)+'</Moneda>'+ cCRLF	
				If lGDesp
					cXML += '			<FctConv>'+ TRANSFORM((cAliasXML)->F2_TXMOEDA,"999.99")+'</FctConv>'+ cCRLF
				EndIF	
			EndIf
			cXML += '			<SubTotal>'+ Alltrim(TRANSFORM((cAliasXML)->F2_VALMERC + (cAliasXML)->F2_DESCONT,cPict)) +'</SubTotal>'+ cCRLF
			cXML += '			<MntDcto>' + Alltrim(STR((cAliasXML)->F2_DESCONT)) +'</MntDcto>'+ cCRLF
			cXML += '			<MntBase>' + Alltrim(STR((cAliasXML)->F2_VALMERC))  + '</MntBase>'+ cCRLF
			cXML += '			<VlrPagar>'+ Alltrim(TRANSFORM((cAliasXML)->F2_VALBRUT,cPict)) +'</VlrPagar>'+ cCRLF
			cXML += '			<VlrPalabras>' + EXTENSO((cAliasXML)->F2_VALBRUT,.f.,(cAliasXML)->F2_MOEDA) + '</VlrPalabras>' + cCRLF
			cXML += '			<MontoPropina>0.00</MontoPropina>'+ cCRLF
			cXML += '		</Totales>'+ cCRLF
			If !lFacExc
				aImp := NFAEXmlImp(nTipDoc,(cAliasXML)->F2_CLIENTE + (cAliasXML)->F2_LOJA + (cAliasXML)->F2_DOC + (cAliasXML)->F2_SERIE, IIF(cTpDoc $ "34",.T.,.F.))
		
				For nA:=1 To Len(aImp)
					cXML += '		<Impuestos>'+ cCRLF
					cXML += '			<TipoImp>'+ aImp[Na][2] +'</TipoImp>'+ cCRLF
					cXML += '			<TasaImp>'+ Alltrim(aImp[Na][1]) +'</TasaImp>'+ cCRLF
					cXML += '			<MontoImp>'+ Alltrim(aImp[Na][5]) +'</MontoImp>'+ cCRLF
					cXML += '		</Impuestos>'+ cCRLF
				Next
			EndIf
			If lDocExp .and. getMoeda((cAliasXML)->F2_MOEDA) <> "CL"
				cXML += '		<OtraMoneda>'+ cCRLF
				cXML += '			<TpoMoneda>PESO CL</TpoMoneda>'+ cCRLF
				cXML += '			<TpoCambio>'+ alltrim(TRANSFORM((cAliasXML)->F2_TXMOEDA,"9999.999999")) +'</TpoCambio>'+ cCRLF
				cXML += '			<MntExeOtrMnda>'+ Alltrim(TRANSFORM((cAliasXML)->F2_VALBRUT * (cAliasXML)->F2_TXMOEDA ,cPict)) +'</MntExeOtrMnda>'+ cCRLF
				cXML += '			<MntTotOtrMnda>'+ Alltrim(TRANSFORM((cAliasXML)->F2_VALBRUT * (cAliasXML)->F2_TXMOEDA ,cPict)) +'</MntTotOtrMnda>'+ cCRLF
				cXML += '		</OtraMoneda>'+ cCRLF
			EndIf						
			// Descuentos Globales
			cXML += fGenDscGbl(nDesc,nFlete,nGasto,nSeguro)	
			
			// PE para detalles de Aduana
			If ExistBlock("M485ADUANA") .and. lGDesp .and. lDocExp
				cXML += ExecBlock("M485ADUANA",.F.,.F.,{(cAliasXML)->F2_FILIAL,(cAliasXML)->F2_DOC,(cAliasXML)->F2_SERIE,(cAliasXML)->F2_ESPECIE,(cAliasXML)->F2_CLIENTE,(cAliasXML)->F2_LOJA})	
			EndIf
			
			cXML += '	</Encabezado>'+ cCRLF
			cMotivo := Alltrim((cAliasXML)->F2_MOTIVO)
			
			While (cAliasXML)->(!Eof()) .and. cSerie ==(cAliasXML)->F2_SERIE .AND. cNumDoc ==(cAliasXML)->F2_DOC .AND. cEspDoc == ALLTRIM((cAliasXML)->F2_ESPECIE)
				
				nUnit := ((cAliasXML)->D2_TOTAL + (cAliasXML)->D2_DESCON)/(cAliasXML)->D2_QUANT
				
				cXML += '	<Detalle>'+ cCRLF
				cXML += '		<NroLinDet>'+ (cAliasXML)->D2_ITEM +'</NroLinDet>'+ cCRLF
				cXML += '		<CdgItem>'+ cCRLF
				cXML += '			<TpoCodigo>'+ (cAliasXML)->B1_UM +'</TpoCodigo>'+ cCRLF
				cXML += '			<VlrCodigo>'+ (cAliasXML)->B1_COD +'</VlrCodigo>'+ cCRLF
				cXML += '		</CdgItem>'+ cCRLF
				cXML += '		<DscLang>ES</DscLang>'+ cCRLF
				cXML += '		<DscItem><![CDATA['+ Alltrim((cAliasXML)->B1_DESC) +']]></DscItem>'+ cCRLF
				cXML += '		<QtyItem>'+ Alltrim(TRANSFORM((cAliasXML)->D2_QUANT,cPict)) +'</QtyItem>'+ cCRLF
				cXML += '		<PrcNetoItem>'+ Alltrim(TRANSFORM(nUnit,cPict)) +'</PrcNetoItem>'+ cCRLF
				cXML += '		<DescuentoMonto>'+ Alltrim(TRANSFORM((cAliasXML)->D2_DESCON,cPict)) +'</DescuentoMonto>'+ cCRLF
				
				cDocRef := (cAliasXML)->F2_NFREF
				aImpDet := NFAEDetImp(nTipDoc,(cAliasXML)->D2_DOC+(cAliasXML)->D2_SERIE+(cAliasXML)->D2_CLIENTE+(cAliasXML)->D2_LOJA+(cAliasXML)->D2_COD+(cAliasXML)->D2_ITEM)
				For nC:=1 To Len(aImpDet)
					aExtImp := ExtImp(aImpDet[nC][1], (cAliasXML)->D2_TES)
					
					If Len(aExtImp) > 0
						cXML += '		<ImpuestosDet>'+ cCRLF
						cXML += '			<TipoImp>'+ aExtImp[1][3] +'</TipoImp>'+ cCRLF
						cXML += '			<TasaImp>'+ Alltrim(aImpDet[nC][2]) +'</TasaImp>'+ cCRLF
						cXML += '			<MontoBaseImp>'+ Alltrim(aImpDet[nC][3]) +'</MontoBaseImp>'+ cCRLF
						cXML += '			<MontoImp>'+ Alltrim(aImpDet[nC][4]) +'</MontoImp>'+ cCRLF
						cXML += '		</ImpuestosDet>'+ cCRLF
					EndIf
				Next
				
				cXML += '		<MontoNetoItem>'+ Alltrim(TRANSFORM((nUnit * (cAliasXML)->D2_QUANT) - (cAliasXML)->D2_DESCON,cPict)) +'</MontoNetoItem>'+ cCRLF
				
				cXML += '	</Detalle>'+ cCRLF
				(cAliasXML)->(dbskip())
			EndDo

			
			If cEspecie == "NDC"				
				cXml += getRef(cDocR,cSerR,cProvR,cLojR,cEspR,.F.,cMotivo,cTipoRef,cEspRef,lDocExp)
			ElseIf Alltrim(cEspecie) $ "NF|RFN"
				// PE para agregar documentos de referencia a Facturas y Gu韆s de Despacho
				// Como por ejemplo orden de compra o gu韆s de despacho que dan origen a factura o gu韆 de Despacho.
				If ExistBlock("M485REFNF")
					cXML += ExecBlock("M485REFNF",.F.,.F.,{cFilPE,cDocPE,cSerPE,cEspPE,cCliPe,cLojPE})
				EndIf
			EndIf
			
			cXML += fCAE(cDocument,cFchaEmis)
			cXML += '		<TimeStamp>'+ cFchaEmis +'</TimeStamp>'+ cCRLF
			cXML += '	</Documento>'+ cCRLF
			
			If cEspecie == "NDC"
				// Punto de Entrada para agregar campos personalizados Nota de D閎ito.
				If ExistBlock("M485NDC")
					cXML += ExecBlock("M485NDC",.F.,.F.,{cFilPE,cDocPE,cSerPE,cEspPE,cCliPe,cLojPE})
				EndIf
			Else 
				// Punto de Entrada para agregar campos personalizados Factura| Gu韆 de Despacho.
				If ExistBlock("M485NF")
					cXML += ExecBlock("M485NF",.F.,.F.,{cFilPE,cDocPE,cSerPE,cEspPE,cCliPe,cLojPE,cModVen})
				EndIf
			EndIf
			cXML += '</DTE>'+ cCRLF			
			(cAliasXML)->(dbSkip())
		EndDo
		
		(cAliasXML)->(dbCloseArea())
		
	EndIf
	
	RestArea(aArea)

return cXML

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  ?NFAEXmlImp ?Autor ?Luis Enr韖uez       ?Data ?15.10.18 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Obtiene impuestos de la Factura venta, Nta Deb. y Nta Cred.潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?NFAEXmlImp(nTipDoc,cClave)                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?aImpsto                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?NFAEXmlEcu                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?nExp1:= Tip documento 0= Nta Cred. 1= Fact Venta/Nta Deb.  潮?
北?         ?cExp2:= Clave de Factura, Nta Debito y Nta Credito.        潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
static function NFAEXmlImp(nTipDoc,cClave,lExcento)
	Local nCont 	:= 0
	Local nI		:= 0
	Local nValImp	:= 0
	Local nPorImp	:= 0
	Local nBasImp	:= 0
	Local cCodImp	:= ""
	Local cCodTar	:= ""
	Local aArea 	:= getArea()
	Local aSFB		:= {'0'}
	Local aImpsto   := {}
	Local cImp	    := ""

	Default lExcento := .F.
	dbSelectArea("SFB")
	dbSetOrder(1) //FB_FILIAL + FB_CODIGO
	Count to nCont

	SFB->(dbGotop())
	ProcRegua(nCont)

	While SFB->(!EOF())
		cImp := SFB->FB_CPOLVRO
		nPor := SFB->FB_ALIQ
		cCodImp := SFB->FB_CODIMP
		cCodTar := "001"

		If (nTipDoc <= 0) //Documentos Nota de Credito
				nBasImp := POSICIONE("SF1",1,cfilSF1+cClave,"F1_BASIMP" +cImp)
				nValImp := POSICIONE("SF1",1,cfilSF1+cClave,"F1_VALIMP" +cImp)
		Else
				nBasImp := POSICIONE("SF2",2,cfilSF2+cClave,"F2_BASIMP" +cImp)
				nValImp := POSICIONE("SF2",2,cfilSF2+cClave,"F2_VALIMP" +cImp)
		EndIf

		If (nBasImp > 0 .and. aScan(aSFB,{|x| x == cImp}) == 0) 
			aAdd(aSFB,SFB->FB_CPOLVRO)
			AADD(aImpsto,{TRANSFORM(nPor,"999.99"),Alltrim(cCodImp),Alltrim(cCodTar),TRANSFORM(nBasImp,"999999999999.99"),TRANSFORM(nValImp,"999999999999.99")})
		
		EndIf

		SFB->(dbSkip())
		nBasImp:= 0
		nValImp:=0
	EndDo
	
	SFB->(dbCloseArea())
	
	If lExcento .and. len(aImpsto) == 0
		AADD(aImpsto,{TRANSFORM(nPor,"999.99"),"14",Alltrim(cCodTar),TRANSFORM(nBasImp,"999999999999.99"),TRANSFORM(nValImp,"999999999999.99")})		
	EndIf
	RestArea(aArea)
return aImpsto

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  ?NFAEDetImp ?Autor ?Luis Enr韖uez       ?Data ?15.10.18 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Obtiene el detalle de los impuestos de la Factura venta,   潮?
北?         ?Nta Deb. y Nta Cred.                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?NFAEDetImp(nTipDoc,cClave)                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?aImp2                                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?NFAEXmlEcu                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?nExp1:= Tip documento 0= Nta Cred. 1= Fact Venta/Nta Deb.  潮?
北?         ?cExp2:= Clave de Factura, Nta Debito y Nta Credito.        潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
static function NFAEDetImp(nTipDoc,cClave)
	Local nCont 	:= 0
	Local nI		:= 0
	Local nValImp	:= 0
	Local nPorImp	:= 0
	Local nBasImp	:= 0
	Local aArea 	:= getArea()
	Local aSFB		:= {'0'}
	Local aImp2     := {}
	Local cImp		:= ""

	dbSelectArea("SFB")
	dbSetOrder(1) //FB_FILIAL + FB_CODIGO
	Count to nCont

	SFB->(dbGotop())
	ProcRegua(nCont)

	While SFB->(!EOF())
		cImp := SFB->FB_CPOLVRO
		nPor := SFB->FB_ALIQ
		
		If(nTipDoc <= 0)
				nBasImp := POSICIONE( "SD1" , 1 , cFilSD1+cClave , "D1_BASIMP" + cImp )
				nValImp := POSICIONE( "SD1" , 1 , cFilSD1+cClave , "D1_VALIMP" + cImp )
		Else
				nBasImp := POSICIONE( "SD2" , 3 , cFilSD2+cClave , "D2_BASIMP" + cImp )
				nValImp := POSICIONE( "SD2" , 3 , cFilSD2+cClave , "D2_VALIMP" + cImp )
		EndIf

		If nBasImp > 0 .and. aScan(aSFB,{|x| x == cImp}) == 0 
			aAdd(aSFB,SFB->FB_CPOLVRO)
			AADD( aImp2 , { SFB->FB_CPOLVRO , TRANSFORM(nPor,"999.99") , TRANSFORM(nBasImp,"999999999999.99") , TRANSFORM(nValImp,"999999999999.99") } )
		EndIf

		SFB->(dbSkip())
		nBasImp := 0
		nValImp := 0
	EndDo

	SFB->(dbCloseArea())
	RestArea(aArea)
return aImp2

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  ?ExtImp     ?Autor ?Luis Enr韖uez       ?Data ?15.10.18 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Obtiene el Codigo de la tasa y el codigo del impuesto segun潮?
北?         ?SRI de acuerdo a la TES de los items de la Factura,  Nta   潮?
北?         ?Deb. y Nta Cred.                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?ExtImp(nNumImp, cTES)                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?aImpuestos                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?NFAEXmlEcu                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?nExp1:= Numero base del impuesto                           潮?
北?         ?cExp2:= TES del impuesto.                                  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
static function ExtImp(nNumImp,cTES)
	Local aImpuestos :={}      
	Local cNumImp    := Alltrim(nNumImp)
	
		SFC->(dbSetOrder(1)) //FC_FILIAL + FC_TES + FC_SEQ + FC_IMPOSTO
		SFB->(dbSetOrder(1)) //FB_FILIAL + FB_CODIGO
		
		If SFC->(DbSeek(xFilial("SFC") + cTES))
			While !(SFC->(Eof())) .And. SFC->FC_TES == cTES
				If SFB->(DbSeek(xFilial("SFB") + SFC->FC_IMPOSTO))
					If Alltrim(cNumImp)==Alltrim(SFB->FB_CPOLVRO)
						aadd(aImpuestos,{ SFB->FB_CODIGO , "001",Alltrim(SFB->FB_CODIMP)})
					exit
					EndIf
				EndIf
				SFC->(DBSKIP())
			EndDo
		EndIf
return aImpuestos

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  砯GetSE1   ?Autor 矻uis Enr韖uez          ?Data ?5/10.2018潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 砄btiene fecha de pago                                       潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function fGetSE1(cDoc,cSer,cTipo)
	Local aArea 	:= getArea()
	Local cRet	:= ""
	Local cTab 	:= geTNextAlias()
			
	BeginSQL alias cTab
		SELECT MAX(E1_VENCTO)AS E1_VENCTO
		FROM %table:SE1%  SE1
		WHERE E1_FILIAL=%EXP:xFilial("SE1")%
		AND E1_NUM= %exp:cDoc%
		AND E1_PREFIXO= %exp:cSer%
		AND E1_TIPO= %exp:cTipo%
		AND SE1.%notdel%		
	EndSQL

	While (cTab )->(!Eof())
		cRet := (cTab )->E1_VENCTO
		(cTab )->(DBsKIP())
	EndDo	
	(cTab )->(dbCloseArea())
	
	cRet := Substr(cRet,1,4) + "-" + Substr(cRet,5,2)+ "-" + Substr(cRet,7,2)
	
	RestArea(aArea)
Return cRet

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  ?getRef     ?Autor ?Luis Enr韖uez       ?Data ?15.10.18 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Obtiene los documentos ligados a la NCC|NDC seg鷑 corres-  潮?
北?         ?ponda en SE5                                               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?getRef(ExpC01,ExpC02,ExpC03,ExpC04,ExpC05)                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?aImpuestos                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?NFAEXmlEcu                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?ExpC01:= Numero documento                                  潮?
北?         ?ExpC02:= Serie del Documento                               潮?
北?         ?ExpC03:= Proveedor                                         潮?
北?         ?ExpC04:= Tienda                                            潮?
北?         ?ExpC05:= Especie del documento (NCC/NDC)                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function getRef(cDoc,cDocSerie,cProv,cTienda,cEspecie,lSE5,cMotivo,cTipRef,cEspRef, lExpDoc,nL,lBoletaV,LExec)
	Local aArea	   := getArea()
	Local cRet 	   := ""
	Local aFac     := {}
	Local cClave   := ""
	Local nI	   := 0
	Local cNF	   := ""
	Local cPar	   := Space(TamSx3("E5_PARCELA")[1])
	Local cFech	   := ""
	Local nTamDoc  := Tamsx3("F2_DOC")[1]
	Local cNFac	   := ""
	Local cHora	   := "00:00:00"
	Local cTabSF2  := getNextAlias()
	Local cEspNF   := "NF%"
	Local cPto	   := ""
	Local cEst	   := ""
	Local aRet	   := {}
	Local nK	   := 0
	Local cTabPref := "SF2"
	Local cPrefijo := "F2_"
	Local cTipoDoc := "33"
	
	Default lBoletaV := .F.	
	Default lExe := .F.
	Default lSE5    := .F.
	Default cTipRef := "1"
	Default cEspRef := "NF"
	Default lExpDoc := .F.
	Default nL      := 1
	
	If Alltrim(cEspecie) = "NCC"
		cTipoDoc := IIF(!lExpDoc, "33", "110")
		
		If lBoletaV 
			If lExec
				cTipodoc := "41"
			Else
				cTipoDoc := "39"
			EndIf
		EndIf
		cClave := cDocSerie + cDoc + cPar+ Alltrim(cEspecie) + cTienda 
		If lSE5
			dbSelectArea("SE5")
			SE5->(dbSetOrder(10)) //E5_FILIAL + E5_DOCUMEN
		
			If SE5->(dbSeek( xFilial("SE5") + cClave,.T.))
			
				While SFB->(!EOF()) .and. Alltrim(cClave) $ SE5->E5_DOCUMEN .and. SE5->E5_TIPODOC='CP' .and. SE5->E5_MOTBX='CMP'	;
				.and. SE5->E5_FILIAL == xFilial("SE5")		
				
					aAdd(aFac,{SE5->E5_PREFIXO	,;	// Serie
								SE5->E5_NUMERO	,;	// Documento
								SE5->E5_TIPO		,;	// Especie
								SE5->E5_CLIFOR	,;	// Proveedor
								SE5->E5_LOJA		})	// Tienda 
					SE5->(dbSkip())				
				EndDo
			EndIf
		Else
			aAdd(aFac,{cDocSerie	,;	// Serie
							cDoc	,;	// Documento
							cEspecie	,;	// Especie
							cProv	,;	// Proveedor
							cTienda})	// Tienda 
		EndIf	
		
		For nI:= 1 to len(aFac)
			cNF := xFilial("SF2") + aFac[nI,2] + aFac[nI,1] + aFac[nI,4] + aFac[nI,5]
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO 
			
			If SF2->(dbSeek(cNF))
				If ! Empty(SF2->F2_HORA)
					If len(Alltrim(SF2->F2_HORA)) == 5
						cHora := SF2->F2_HORA + ":00"
					Else
						cHora := SF2->F2_HORA
					EndIf
				EndIf
				cFech := SUBSTR(DTOS(SF2->F2_EMISSAO),0,4) + "-" +;
						  SUBSTR(DTOS(SF2->F2_EMISSAO),5,2) + "-" +;
						  SUBSTR(DTOS(SF2->F2_EMISSAO),7,2) + "T" + cHora +"Z"
				cNFac := substr(SF2->F2_DOC,(nTamDoc-8),9)

				aADD(aRet,{cEst	,;
							cPto	,;
							cNFac				,;
							cFech				})
			EndIf
		Next		
	ElseIf Alltrim(cEspecie) == "NDC"
		cNF := xFilial(cTabPref) + cDoc + cDocSerie + cProv + cTienda  
		cEspNF := cEspRef + "%"
		If Alltrim(cEspRef) == "NF"
			cTabPref := "SF2"
			cTipoDoc := IIf(!lExpDoc, "33", "110")
			
			If lBoletaV 
				If lExec
					cTipodoc := "41"
				Else
					cTipoDoc := "39"
				EndIf
			EndIf
			cTipoDoc := IIF(lBoletaV .and. lExec,"41", cTipoDoc)
			BEGINSQL ALIAS cTabSF2
				SELECT  *
				FROM %TABLE:SF2% SF2 //WHERE F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA=%EXP:CNF%
				WHERE F2_FILIAL = %EXP:xFilial(cTabPref)%
				AND F2_DOC=%EXP:cDoc%
				AND F2_SERIE=%EXP:cDocSerie%
				AND F2_CLIENTE=%EXP:cProv%
				AND F2_LOJA=%EXP:cTienda%
				AND F2_ESPECIE LIKE %EXP:CESPNF%
				AND SF2.%NOTDEL%			
			ENDSQL
		
			TCSetField(cTabSF2,"F2_EMISSAO","D")
		Else
			cTabPref := "SF1"
			cTipoDoc := IIf(!lExpDoc, "61", "112")
			cPrefijo := "F1_"
			BEGINSQL ALIAS cTabSF2
				SELECT  *
				FROM %TABLE:SF1% SF1
				WHERE	F1_FILIAL = %EXP:xFilial(cTabPref)%
				AND F1_DOC=%EXP:cDoc%
				AND F1_SERIE=%EXP:cDocSerie%
				AND F1_FORNECE=%EXP:cProv%
				AND F1_LOJA=%EXP:cTienda% //WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA=%EXP:CNF%f
				AND F1_ESPECIE LIKE %EXP:CESPNF%
				AND SF1.%NOTDEL%
			ENDSQL
		
			TCSetField(cTabSF2,"F1_EMISSAO","D")
		EndIf

		dbSelectArea(cTabSF2)
	
		(cTabSF2)->(DbGoTop())
		
		while (cTabSF2 )->(!Eof())
			If ! Empty((cTabSF2 )->&(CPrefijo + "HORA"))
				If len(Alltrim((cTabSF2 )->&(CPrefijo + "HORA"))) == 5
					cHora := (cTabSF2 )->&(CPrefijo + "HORA") + ":00"
				Else
					cHora := (cTabSF2 )->&(CPrefijo + "HORA")
				EndIf
			EndIf
			cFech := SUBSTR(DTOS((cTabSF2 )-> &(cPrefijo + "EMISSAO")),0,4) + "-" +;
					  SUBSTR(DTOS((cTabSF2 )->&(cPrefijo + "EMISSAO")),5,2) + "-" +;
					  SUBSTR(DTOS((cTabSF2 )->&(cPrefijo + "EMISSAO")),7,2) + "T" + cHora +"Z"
			
			cNFac := substr((cTabSF2 )->&(cPrefijo + "DOC"),(nTamDoc-7),8)
			aADD(aRet,{ 					,;
						 					,;
						cNFac				,;
						cFech				})
			(cTabSF2 )->(dbSkip())
		EndDo
		(cTabSF2 )->(dbCloseArea())
	EndIf

	For nK := 1 To Len (aRet)
		cRet += '	<Referencia>'+ cCRLF
		cRet += '		<NroLinRef>'+ Alltrim(STR(nL))+'</NroLinRef>'+ cCRLF
		cRet += '		<TpoDocRef>' + cTipoDoc + '</TpoDocRef>'+ cCRLF
		cRet += '		<NumeroRef>'+ Alltrim(STR(VAL(aRet[nK,3]))) + '</NumeroRef>'+ cCRLF
		cRet += '		<FechaRef>' + aRet[nK,4] + '</FechaRef>'+ cCRLF
		cRet += ' 		<CodRef>' + cTipRef + '</CodRef>' + cCRLF
		cRet += '		<RazonRef>' + cMotivo + '</RazonRef>'+ cCRLF
		cRet += '	</Referencia>'+ cCRLF			
	Next			
	RestArea(aArea)
Return cRet

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  砱etEmisor ?Autor 矻uis Enr韖uez          ?Data ?5/10.2018潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 矴enera nodo Emisor                                          潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function getEmisor()
	local cXML		:= ""
	local cRFC		:= RTRIM(SM0->M0_CGC)
	local cNome		:= RTRIM(SM0->M0_NOME)
	local cNomeCom	:= RTRIM(SM0->M0_NOMECOM)
	local cEndent	:= RTRIM(SM0->M0_ENDENT)
	Local cDepto	:= RTRIM(SM0->M0_CIDENT)
	Local cCp		:= RTRIM(SM0->M0_CEPENT)
	Local cPais		:= "152"
	
	cXML += '		<Emisor>'+ cCRLF
	cXML += '			<RegimenContable></RegimenContable>'+ cCRLF
	cXML += '			<IDEmisor>'+ TRANSFORM(cRFC, "@R XX999999-X") +'</IDEmisor>'+ cCRLF
	cXML += '			<NmbEmisor>'+ cNome +'</NmbEmisor>'+ cCRLF
	cXML += '			<NombreEmisor>'+ cCRLF
	cXML += '				<PrimerNombre>'+ cNomeCom +'</PrimerNombre>'+ cCRLF
	cXML += '			</NombreEmisor>'+ cCRLF
	cXML += '			<CodigoEmisor></CodigoEmisor>' + cCRLF
	cXML += '			<FechaInicioActividades>2016-01-01</FechaInicioActividades>'+ cCRLF
	cXML += '			<DomFiscal>'+ cCRLF
	cXML += '				<Calle>'+ cEndent +'</Calle>'+ cCRLF
	cXML += '				<Departamento>'+ cDepto + '</Departamento>' + cCRLF
	cXML += '				<Distrito>' + cDepto + '</Distrito>' + cCRLF
	cXML += '				<Ciudad>' + cDepto + '</Ciudad>' + cCRLF
	cXML += '				<Municipio>' + cDepto+ '</Municipio>' + cCRLF
	cXML += '				<Pais>' + cPais + '</Pais>' + cCRLF
	cXML += '				<CodigoPostal>' + cCp + '</CodigoPostal>' + cCRLF
	cXML += '			</DomFiscal>'+ cCRLF
	cXML += '			<LugarExped>'+ cCRLF
	cXML += '				<Calle>'+ cEndent+'</Calle>'+ cCRLF		
	cXML += '			</LugarExped>'+ cCRLF
	cXML += '		</Emisor>'+ cCRLF
Return cXML

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  砯CAE      ?Autor 矻uis Enr韖uez          ?Data ?5/10.2018潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 矴enera elemento CAE                                         潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function fCAE(cDocument,cFechaEmis)
	Local cXML := ""
	
	cXML += '	<CAE>'+ cCRLF
	cXML += '		<Tipo>String</Tipo>'+ cCRLF
	cXML += '		<NumeroInicial>'+ cDocument +'</NumeroInicial>'+ cCRLF
	cXML += '		<NumeroFinal>'+ cDocument +'</NumeroFinal>'+ cCRLF
	cXML += '		<NroResolucion>'+ cDocument +'</NroResolucion>'+ cCRLF
	cXML += '		<FechaResolucion>'+ substr(cFechaEmis,1,10) +'</FechaResolucion>'+ cCRLF
	cXML += '	</CAE>'+ cCRLF
Return cXML

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  砯GetTrans ?Autor 矻uis Enr韖uez          ?Data ?5/10.2018潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 矴enera elemento Transporte                                  潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  砯GenDscGbl?Autor 矻uis Enr韖uez          ?Data ?5/10.2018潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 矴enera Elemento Descuentos Globales                         潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function fGenDscGbl(nDesc,nFlete,nGasto,nSeguro)
	Local cXML 	:= ""
	Local nItem	:= 0
	Local cTipo := "$"
	Default nDesc   := 0
	Default nFlete  := 0
	Default nGasto  := 0
	Default nSeguro := 0
	
	If nDesc > 0
		nItem+=1
		cXML += "		<DscRcgGlobal>" + cCRLF
		cXML += "			<NroLinDR>"+ strZero(nItem,2) +"</NroLinDR>" + cCRLF
		cXML += "			<TpoMov>D</TpoMov>" + cCRLF
		cXML += "			<GlosaDR>Descuentos</GlosaDR>" + cCRLF
		cXML += "			<TpoValor>" + cTipo + "</TpoValor>" + cCRLF
		cXML += "			<ValorDR>" + Alltrim(Transform(nDesc, "99999999999999.99")) + "</ValorDR>" + cCRLF			
		cXML += "		</DscRcgGlobal>" + cCRLF
	EndIf
	
	If nFlete > 0
		nItem+=1
		cXML += "		<DscRcgGlobal>" + cCRLF
		cXML += "			<NroLinDR>"+ strZero(nItem,2) +"</NroLinDR>" + cCRLF
		cXML += "			<TpoMov>R</TpoMov>" + cCRLF
		cXML += "			<GlosaDR>Flete</GlosaDR>" + cCRLF
		cXML += "			<TpoValor>" + cTipo + "</TpoValor>" + cCRLF
		cXML += "			<ValorDR>" + Alltrim( Transform(nFlete, "99999999999999.99")) + "</ValorDR>" + cCRLF			
		cXML += "		</DscRcgGlobal>" + cCRLF
	EndIf
	
	If nGasto > 0
		nItem+=1
		cXML += "		<DscRcgGlobal>" + cCRLF
		cXML += "			<NroLinDR>"+ strZero(nItem,2) +"</NroLinDR>" + cCRLF
		cXML += "			<TpoMov>R</TpoMov>" + cCRLF
		cXML += "			<GlosaDR>Otros Gastos</GlosaDR>" + cCRLF
		cXML += "			<TpoValor>" + cTipo + "</TpoValor>" + cCRLF
		cXML += "			<ValorDR>" + Alltrim(Transform(nGasto, "99999999999999.99")) + "</ValorDR>" + cCRLF			
		cXML += "		</DscRcgGlobal>" + cCRLF
	EndIf
	
	If nSeguro > 0
		nItem+=1
		cXML += "		<DscRcgGlobal>" + cCRLF
		cXML += "			<NroLinDR>"+ strZero(nItem,2) +"</NroLinDR>" + cCRLF
		cXML += "			<TpoMov>R</TpoMov>" + cCRLF
		cXML += "			<GlosaDR>Seguro</GlosaDR>" + cCRLF
		cXML += "			<TpoValor>" + cTipo + "</TpoValor>" + cCRLF
		cXML += "			<ValorDR>" + Alltrim(Transform(nSeguro, "99999999999999.99")) + "</ValorDR>" + cCRLF			
		cXML += "		</DscRcgGlobal>" + cCRLF
	EndIf
Return cXml

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  砱etFrmPago?Autor 矻uis Enr韖uez          ?Data ?5/10.2018潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 砄btiene forma de Pago                                       潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static function getFrmPago(cCond)
	Local cRet  := "1"
	Local aArea := getArea()

	dbSelectArea("SE4")
	dbSetOrder(1) //E4_FILIAL + E4_CODIGO
	If SE4->(dbSeek(xFilial("SE4") + cCond))
		If SE4->E4_TIPO == '1' .AND. VAL(SE4->E4_COND) > 0
			cRet := '2'			
		EndIf
	EndIf
	If Empty(cCond)
		cRet := '3'
	EndIF

	RestArea(aArea)
Return cRet

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  矴etMoeda  ?Autor 矻uis Enr韖uez          ?Data ?5/10.2018潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 砄btiene SIGLA DE MONEDA SEGUN SII                           潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function GetMoeda(cMoneda)
	Local cRet      := ""
	Local cParam    := "MV_MOEDA" 
	Local cMon	    := ""
	Default cMoneda := 1
	
	cParam := cParam + Alltrim(STR(cMoneda))
	cMon:= Alltrim(&cParam)
	
	If cMon $ "DOLAR|USD"
		cRet := "USD"
	ElseIf cMon $ "EUROS|EURO"
		cRet := "EUR"
	ElseIf cMon $ "PESO|PESOS"
		cRet := "CLP"
	Else
		cRet := Substr(cMon,1,3)
	EndIf	
Return cRet
