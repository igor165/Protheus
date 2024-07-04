#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M485XFUNPER ³ Autor ³ Luis Enríquez              ³ Data ³ 20.19.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Esta rutina permite generar una cadena de caracteres que          ³±±
±±³          ³ define un XML el cual contiene los datos correspondientes         ³±±
±±³          ³ al documento electronico solicitado (Fact. Venta, Nta debito      ³±±
±±³          ³ y Nta credito) segun el esquema DTE_v1, que sera trasmitido       ³±±
±±³          ³ a TSS para su envio a traves de Signature.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ NFAEXmlPER(ExpN1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpN7,ExpC8)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tipo de documento 0= Nta Cred. 1= Fact Venta/Nta Deb.     ³±±
±±³          ³ ExpC2 = Serie del documento.                                      ³±±
±±³          ³ ExpC3 = Cod. Cliente / Proveedor.                                 ³±±
±±³          ³ ExpC4 = Codigo de la tienda (Cliente/Proveedor).                  ³±±
±±³          ³ ExpC5 = Numero documento.                                         ³±±
±±³          ³ ExpC6 = Especie de documento (NCC,NDC,NF).                        ³±±
±±³          ³ ExpN7 = Ambte confg. en TSS 1 = Homologacion 2 = Produccion       ³±±
±±³          ³ Expc8 = Serie del documento que será enviada asunat 4 carct.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA485                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Luis Enríquez ³13/02/21³DMINA-     ³Se crean func. M485TPPAG y M485CUOTA para ³±±
±±³              ³        ³11131      ³funcionalidad de Forma de Pago para NF y  ³±±
±±³              ³        ³           ³NCC Fact. Electrónica. (PER)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*/{Protheus.doc} $M485DETIMP
Obtiene impuestos por detalle dado un documento
@type function
@author mayra.camargo
@since 05/02/2019
@version 1.0
@param cSerie, c, serie del documento
@param cCltProv}, c,código cliente del documento
@param cTienda, c,Tienda del cliente
@param cNumDoc, c, número de documento
@param ctem, c, número de ítem
@param cEspDoc, c,especie del documento
@param cCodPro, c,código del producto del item
@param nTipDoc, n, tipo de document 1 salida 0 entrada
@Return aDet, array con los datos del detalle x ítem
@example
(examples)
@see (links_or_references)
/*/
Function M485DETIMP(cSerie, cCltProv, cTienda,cNumDoc,cItem,cEspDoc,cCodPro,nTipDoc)
	Local aArea		:= GetArea()
	Local cCRLF		:= (chr(13)+chr(10))
	Local aImpDet	:= {}
	Local aExtImp	:= {}
	Local nC		:= 0
	Local cImpD		:= ""
	Local cSubImp	:= ""
	Local aDet		:= {}
	Local nPrcUnit	:= 0
	Local nPrcNetIt	:= 0
	Local nQtdItem	:= 0
	Local cCposQuery:= ""
	Local cCposFrom	:= ""
	Local cWhere	:= ""
	Local cAliasXML	:= getNextAlias()
	Local nUnit		:= 0
	Local nImp		:= 0
	Local lDocEx	:= .F.
	Local cTESGrat	:= getMV("MV_TESEXE") // TES para factura Gratuita
	Local lGrat		:= .F.
	Local lImpIncl  := .F.
	Local cDescSai  := GetNewPar('MV_DESCSAI', '1')
	Local nSubMontMerc := 0
	Local cDetXML   := "" // Nodo Detalle de los Items	      
	Local cfilSF1	:= xFilial("SF1")
	Local cFilSD1	:= xFilial("SD1")
	Local cFilSF2	:= xFilial("SF2")
	Local cFilSD2	:= xFilial("SD2")
	Local cFilSB1	:= xFilial("SB1")
	Local cFilSA1	:= xFilial("SA1")
	Local cFilSYA	:= xFilial("SYA")
	Local cFilSAH   := xFilial("SAH")
	Local cPict		:= "99999999999999.99"
	Local nPrcNeto	:= 0
	
	If (nTipDoc <= 0) //Documentos Nota de Credito
		cCposQuery := "% SF1.F1_FILIAL, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_ESPECIE, SF1.F1_SERIE, SF1.F1_DOC, SF1.F1_EMISSAO, SF1.F1_HORA, SF1.F1_MOEDA, " 
		cCposQuery += "  SF1.F1_VALMERC, SF1.F1_DESCONT, SF1.F1_VALBRUT, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_CEP, SA1.A1_CGC, SA1.A1_GLN,SA1.A1_EMAIL,SA1.A1_CONTATO , SB1.B1_UM, SB1.B1_PRODSAT, "
		cCposQuery += "  SB1.B1_COD, SB1.B1_DESC, SD1.D1_ITEM, SD1.D1_QUANT, SD1.D1_TOTAL, SD1.D1_VUNIT, SD1.D1_DESC, SD1.D1_TES, SD1.D1_NFORI, "
		cCposQuery += "  SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SF1.F1_TIPO, SYA.YA_DESCR,  " 
		cCposQuery += "  SF1.F1_MOTIVO,SA1.A1_TIPDOC,SD1.D1_VALDESC,SA1.A1_EST,SA1.A1_BAIRRO, SF1.F1_SERIE2,SD1.D1_SERIORI, SF1.F1_TIPREF,SA1.A1_PFISICA, SA1.A1_EST,SA1.A1_PAIS  %"
	
		cCposFrom	:= "% " + RetSqlName("SF1") + " SF1, "
		cCposFrom	+= RetSqlName("SD1")+ " SD1, "
		cCposFrom	+= RetSqlName("SA1")+ " SA1, "
		cCposFrom	+= RetSqlName("SYA")+ " SYA, "
		cCposFrom	+= RetSqlName("SB1")+ " SB1 %"
	
		cWhere	:= "% SF1.F1_FORNECE = '"+ cCltProv +"' AND SF1.F1_LOJA = '"+ cTienda +"' AND SF1.F1_SERIE = '"+ cSerie +"'   "
		cWhere	+= "  AND SF1.F1_DOC = '"+ cNumDoc +"' AND SF1.F1_ESPECIE = '"+ cEspDoc +"' AND SF1.F1_FORNECE = SD1.D1_FORNECE   "
		cWhere 	+= "  AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_DOC = SD1.D1_DOC AND SA1.A1_COD = SF1.F1_FORNECE "
		cWhere 	+= "  AND SA1.A1_LOJA = SF1.F1_LOJA AND SF1.F1_ESPECIE = SD1.D1_ESPECIE AND SB1.B1_COD = SD1.D1_COD " 
		cWhere  += " AND SD1.D1_ITEM='" + cItem + "' AND SD1.D1_COD='" + cCodPro + "' "
		cWhere	+= "  AND SYA.YA_CODGI = SA1.A1_PAIS "
	
		cWhere	+= " AND SF1.F1_FILIAL = '"+cfilSF1+"'"
		cWhere	+= " AND SD1.D1_FILIAL = '"+cFilSD1+"'"
		cWhere	+= " AND SA1.A1_FILIAL = '"+cFilSA1+"'"
		cWhere	+= " AND SYA.YA_FILIAL = '"+cFilSYA+"'"
		cWhere	+= " AND SB1.B1_FILIAL = '"+cFilSB1+"'"
	
		If ( TcSrvType()=="AS/400" )
			cWhere	+="     AND SF1.@DELETED@  = ' ' "
			cWhere	+="		 AND SD1.@DELETED@  = ' ' "
			cWhere	+="		 AND SA1.@DELETED@  = ' ' "
			cWhere	+="		 AND SYA.@DELETED@  = ' ' "
			cWhere	+="     AND SB1.@DELETED@  = ' ' %"
		Else
			cWhere	+="     AND SF1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SD1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SA1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SYA.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SB1.D_E_L_E_T_  = ' ' %"
		EndIf
	
		BeginSql alias cAliasXML
			SELECT %exp:cCposQuery%
			FROM  %exp:cCposFrom%
			WHERE %exp:cWhere%
			ORDER BY SD1.D1_ITEM
		EndSql
		
		TCSetField(cAliasXML,"F1_EMISSAO","D") //Los campos tipo fecha se quedan como tipo fecha, pues por query son recuperados como string
	
		dbSelectArea(cAliasXML)
		
		(cAliasXML)->(DbGoTop())
		
		While (cAliasXML)->(!Eof()) .and. cSerie ==(cAliasXML)->F1_SERIE .AND. cNumDoc ==(cAliasXML)->F1_DOC .AND. cEspDoc == (cAliasXML)->F1_ESPECIE .AND. (cAliasXML)->D1_ITEM == cItem
			nUnit 	:= (cAliasXML)->D1_TOTAL
			aImpDet := NFAEDetImp(nTipDoc,(cAliasXML)->D1_DOC+(cAliasXML)->D1_SERIE+(cAliasXML)->D1_FORNECE+(cAliasXML)->D1_LOJA+(cAliasXML)->D1_COD+(cAliasXML)->D1_ITEM,(cAliasXML)->D1_TES, .T.)
			cImpD 	:= ""
			nImp	:= 0
			lGrat	:= 	(cAliasXML)->D1_TES $ cTESGrat		
			If !lDocEx // Tratamiento documentos Nacionales
				For nC:=1 To Len(aImpDet)
					aExtImp := ExtImp(aImpDet[nC][1], (cAliasXML)->D1_TES)
					If Len(aExtImp) > 0
						cImpD += '		<ImpuestosDet>'+ cCRLF
						cImpD += '			<TipoImp>'+ aExtImp[1][3] +'</TipoImp>'+ cCRLF
						cImpD += '			<CodTasaImp>'+ Alltrim(Str(val(aExtImp[1][2]))) +'</CodTasaImp>'+ cCRLF
						cImpD += '			<TasaImp>'+ Alltrim(aImpDet[nC][2]) +'</TasaImp>'+ cCRLF
						cImpD += '			<MontoImp>'+ Alltrim(aImpDet[nC][4]) +'</MontoImp>'+ cCRLF
						cImpD += '		</ImpuestosDet>'+ cCRLF
						lImpIncl:= aImpDet[nC][5]
						nImp += Val(aImpDet[nC][4])
					EndIf
				Next
				If Len(aImpDet) == 0 // cuando la TES no tiene impuestos asociados
					aExtImp := ExtImp("0", (cAliasXML)->D1_TES,.F.)	
					If Len(aExtImp) > 0
						cImpD += '		<ImpuestosDet>'+ cCRLF
						cImpD += '			<TipoImp>'+ aExtImp[1][3] +'</TipoImp>'+ cCRLF
						cImpD += '			<CodTasaImp>' + Alltrim(Str(val(aExtImp[1][2])))+ '</CodTasaImp>'+ cCRLF
						cImpD += '			<TasaImp>'+ Alltrim(STR(aExtImp[1][4])) +'</TasaImp>'+ cCRLF
						cImpD += '			<MontoBaseImp>0</MontoBaseImp>'+ cCRLF
						cImpD += '			<MontoImp>0</MontoImp>'+ cCRLF
						cImpD += '		</ImpuestosDet>'+ cCRLF
						nImp += 0
					EndIf
				EndIf				
			Else // Impuestos Detalle Documentos Exportación
				aExtImp := ExtImp('0', (cAliasXML)->D1_TES,lDocEx)
				If Len(aExtImp) > 0
					cImpD += '	<ImpuestosDet>'+ cCRLF
					cImpD += '		<TipoImp>'+ aExtImp[1][3] +'</TipoImp>'+ cCRLF
					cImpD += '		<CodTasaImp>40</CodTasaImp>'+ cCRLF
					cImpD += '		<TasaImp>'+ Alltrim(str(aExtImp[1,4]))+'</TasaImp>'+ cCRLF
					cImpD += '		<MontoImp>0</MontoImp>'+ cCRLF
					cImpD += '	</ImpuestosDet>'+ cCRLF
					nImp += 0
				EndIf
			EndIf
			
			nQtdItem	:= (cAliasXML)->D1_QUANT
			nPrcUnit	:= (cAliasXML)->D1_VUNIT 
			nPrcNetIt	:= (cAliasXML)->D1_TOTAL
			nUnit 		:= (cAliasXML)->D1_TOTAL				 
			If lImpIncl
				nPrcUnit:= nPrcUnit - (nImp/nQtdItem)
			EndIf
	
			If !lGrat
				If cDescSai $ "1"
					nPrcUnit:= nPrcUnit + ((cAliasXML)->D1_VALDESC/nQtdItem)
				ElseIf cDescSai $ "2"
					nPrcUnit:= nPrcUnit - ((cAliasXML)->D1_VALDESC/nQtdItem)
					nPrcNetIt:= nPrcNetIt - ((cAliasXML)->D1_VALDESC/nQtdItem)
				EndIf
				nPrcBruto := nPrcUnit
				If nImp > 0 .and. !lImpIncl
					
					nPrcNeto := (nPrcNetIt+nImp)/nQtdItem
				Else
					nPrcNeto := nUnit/nQtdItem
					If lImpIncl				
						nPrcUnit:= nPrcUnit - ((cAliasXML)->D1_VALDESC/nQtdItem)
						nSubMontMerc := nUnit
						nUnit := nUnit - nImp	
						nPrcNetIt := nSubMontMerc
						nPrcUnit := nSubMontMerc
					EndIf
				EndIf
			Else
				nPrcBruto := 0
				nPrcNeto := 0 					
			EndIf
			// UBL 2.1 Descuentos por item
			If (cAliasXML)->D1_VALDESC  > 0
				cDetXML += '		<SubDscto>'+ cCRLF
				cDetXML += '			<TipoDscto>00</TipoDscto>' + cCRLF
				cDetXML += '			<GlosaDscto>' + Alltrim(TRANSFORM( 0,cPict)) + '</GlosaDscto>' + cCRLF
				cDetXML += '			<MntDscto>' + Alltrim(TRANSFORM( 0,cPict)) + '</MntDscto>' + cCRLF
				cDetXML += '		</SubDscto>'  + cCRLF
			EndIf
			If lGrat 							
				// Solamente para operaciones gratuitas se genera este nodo							
				cSubImp := "	<SubMonto>" +  cCRLF
				cSubImp += "		<Tipo>NOO</Tipo>" +  cCRLF
				cSubImp += "		<MontoConcepto>" + Alltrim(TRANSFORM(nUnit,cPict)) + "</MontoConcepto>" +  cCRLF
				cSubImp += "	</SubMonto>" +  cCRLF
			EndIf
										
			If cDescSai $ "2"
				nPrcUnit:= nPrcUnit + ((cAliasXML)->D1_VALDESC/nQtdItem)
				nUnit := nPrcNetIt * nQtdItem
			EndIf
			
			aDet := {nPrcUnit, nPrcNeto, cDetXML, nUnit, cImpD, cSubImp, lGrat}

			(cAliasXML)->(dbskip())
		EndDo
	
		(cAliasXML)->(dbCloseArea())
		
	Else //Documentos de Factura de Venta/Nota de Debito
		cCposQuery := "% SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SF2.F2_HORA, SF2.F2_MOEDA,SF2.F2_NFREF,SF2.F2_SERREF, " //querry para las notas debitos y facturas de venta.
		cCposQuery += "  SF2.F2_VALMERC, SF2.F2_DESCONT, SF2.F2_VALBRUT, SF2.F2_MOTIVO, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_CEP, SA1.A1_CGC, SA1.A1_GLN,SA1.A1_EMAIL,SA1.A1_CONTATO , SB1.B1_UM, SB1.B1_PRODSAT, "
		cCposQuery += "  SD2.D2_ITEM, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_DESC, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_NFORI, SD2.D2_LOJA, "
		cCposQuery += "  SD2.D2_COD, SD2.D2_TES, SB1.B1_UM, SB1.B1_COD, SB1.B1_DESC, SYA.YA_DESCR, "
		cCposQuery += "  SA1.A1_TIPDOC, SD2.D2_DESCON,SA1.A1_EST,SA1.A1_BAIRRO, SD2.D2_VALBRUT, SF2.F2_SERIE2,SA1.A1_PFISICA, SA1.A1_EST, SA1.A1_PAIS %"
		
		cCposFrom	:= "% " + RetSqlName("SF2") + " SF2, "
		cCposFrom	+= RetSqlName("SD2")+ " SD2, "
		cCposFrom	+= RetSqlName("SA1")+ " SA1, "
		cCposFrom	+= RetSqlName("SYA")+ " SYA, "
		cCposFrom	+= RetSqlName("SB1")+ " SB1 %"
	
		cWhere	:= "% SF2.F2_SERIE = '"+ cSerie +"' AND SF2.F2_DOC = '"+ cNumDoc +"' AND SF2.F2_CLIENTE = '"+ cCltProv +"' "
		cWhere	+= "  AND SF2.F2_LOJA = '"+ cTienda +"' AND SF2.F2_ESPECIE = '"+ cEspDoc +"' AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
		cWhere	+= "  AND SF2.F2_LOJA = SD2.D2_LOJA AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_DOC = SD2.D2_DOC "
		cWhere	+= "  AND SF2.F2_ESPECIE = SD2.D2_ESPECIE AND SB1.B1_COD = SD2.D2_COD AND SA1.A1_COD = SF2.F2_CLIENTE "
		cWhere	+= "  AND SA1.A1_LOJA = SF2.F2_LOJA AND  SYA.YA_CODGI = SA1.A1_PAIS " 
		cWhere  += " AND SD2.D2_ITEM='" + cItem + "' AND SD2.D2_COD='" + cCodPro + "' "
		cWhere	+= " AND SF2.F2_FILIAL = '"+cFilSF2+"'"
		cWhere	+= " AND SD2.D2_FILIAL = '"+cFilSD2+"'"
		cWhere	+= " AND SA1.A1_FILIAL = '"+cFilSA1+"'"
		cWhere	+= " AND SB1.B1_FILIAL = '"+cFilSB1+"'"
		cWhere	+= " AND SYA.YA_FILIAL = '"+cFilSYA+"'"
	
		If ( TcSrvType()=="AS/400" )
			cWhere	+="		 AND SD2.@DELETED@  = ' ' "
			cWhere	+="     AND SF2.@DELETED@  = ' ' "
			cWhere	+="		 AND SA1.@DELETED@  = ' ' "
			cWhere	+="		 AND SYA.@DELETED@  = ' ' "
			cWhere	+="     AND SB1.@DELETED@  = ' ' %"
		Else
			cWhere	+="     AND SD2.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SF2.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SA1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SYA.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SB1.D_E_L_E_T_  = ' ' %"
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
		
		While (cAliasXML)->(!Eof()) .and. cSerie ==(cAliasXML)->F2_SERIE .AND. cNumDoc ==(cAliasXML)->F2_DOC .AND. cEspDoc == (cAliasXML)->F2_ESPECIE .AND. (cAliasXML)->D2_ITEM == cItem				
				cImpD	:= ""
				nImp	:= 0
				lDocEx	:= (Alltrim((cAliasXML)->A1_EST) == "EX")	
				lGrat	:= 	(cAliasXML)->D2_TES $ cTESGrat
				//Genera de impuestos detalle
				aImpDet := NFAEDetImp(nTipDoc,(cAliasXML)->D2_DOC+(cAliasXML)->D2_SERIE+(cAliasXML)->D2_CLIENTE+(cAliasXML)->D2_LOJA+(cAliasXML)->D2_COD+(cAliasXML)->D2_ITEM,(cAliasXML)->D2_TES,.T.)
				If !lDocEx				
					For nC:=1 To Len(aImpDet)
						aExtImp := ExtImp(aImpDet[nC][1], (cAliasXML)->D2_TES)
						If Len(aExtImp) > 0
							cImpD += '	<ImpuestosDet>'+ cCRLF
							cImpD += '		<TipoImp>'+ aExtImp[1][3] +'</TipoImp>'+ cCRLF
							cImpD += '		<CodTasaImp>'+ Alltrim(aExtImp[1][2]) +'</CodTasaImp>'+ cCRLF
							cImpD += '		<TasaImp>'+ Alltrim(aImpDet[nC][2]) +'</TasaImp>'+ cCRLF
							cImpD += '		<MontoBaseImp>'+ Alltrim(aImpDet[nC][3]) +'</MontoBaseImp>'+ cCRLF
							cImpD += '		<MontoImp>'+ Alltrim(aImpDet[nC][4]) +'</MontoImp>'+ cCRLF
							cImpD += '	</ImpuestosDet>'+ cCRLF
							lImpIncl:= aImpDet[nC][5]
							nImp += Val(Alltrim(aImpDet[nC][4]))
						EndIf
					Next
				Else //Exportación
					aExtImp := ExtImp("0", (cAliasXML)->D2_TES,.T.)						
					If len(aExtImp) > 0
						cImpD += '	<ImpuestosDet>'+ cCRLF
						cImpD += '		<TipoImp>'+ aExtImp[1][3] +'</TipoImp>'+ cCRLF
						cImpD += '		<CodTasaImp>40</CodTasaImp>'+ cCRLF
						cImpD += '		<TasaImp>'+ Alltrim(STR(aExtImp[1][4])) +'</TasaImp>'+ cCRLF
						cImpD += '		<MontoBaseImp>0</MontoBaseImp>'+ cCRLF
						cImpD += '		<MontoImp>0</MontoImp>'+ cCRLF
						cImpD += '	</ImpuestosDet>'+ cCRLF
						nImp += 0
					EndIf
				EndIf
				
				nQtdItem	:= (cAliasXML)->D2_QUANT
				cUmItem		:= Posicione("SAH",1,cFilSAH + (cAliasXML)->B1_UM,"AH_COD_CO")		
				nUnit 		:= (cAliasXML)->D2_TOTAL
				cPrdDesc	:= (cAliasXML)->B1_DESC
				cCodProd	:= Alltrim((cAliasXML)->B1_COD)
				cTpCod		:= cUmItem
				
				If lImpIncl
					nPrcUnit	:= (cAliasXML)->D2_PRCVEN - (nImp/nQtdItem)				
				Else
					nPrcUnit	:= (cAliasXML)->D2_PRCVEN
				EndIf
				
				If !lGrat
					nPrcUnit:= nPrcUnit + ((cAliasXML)->D2_DESCON/nQtdItem)
					IF nImp > 0 .and. !lImpIncl
						nPrcNeto := (nUnit + nImp)/nQtdItem
					Else
						nPrcNeto := nUnit/nQtdItem
						If lImpIncl				
							nPrcUnit:= nPrcUnit - ((cAliasXML)->D2_DESCON/nQtdItem)
							nSubMontMerc := nUnit		
							nUnit := nUnit - nImp
							nPrcUnit := nSubMontMerc
						EndIf						
					EndIf
				EndIf
				// UBL 2.1 Descuentos por item
				If (cAliasXML)->D2_DESCON  > 0
					cDetXML += '	<SubDscto>'+ cCRLF
					cDetXML += '		<TipoDscto>00</TipoDscto>' + cCRLF
					cDetXML += '		<GlosaDscto>' +  Alltrim(TRANSFORM( nPrcUnit,cPict))  + '</GlosaDscto>' + cCRLF
					cDetXML += '		<MntDscto>' + Alltrim(TRANSFORM( (cAliasXML)->D2_DESCON,cPict)) + '</MntDscto>' + cCRLF					
					cDetXML += '	</SubDscto>
				EndIf
				
				If lGrat 							
					// Solamente para operaciones gratuitas se genera este nodo							
					cSubImp := "	<SubMonto>" +  cCRLF
					cSubImp += "		<Tipo>NOO</Tipo>" +  cCRLF
					cSubImp += "		<MontoConcepto>" + Alltrim(TRANSFORM(nUnit,cPict)) + "</MontoConcepto>" +  cCRLF
					cSubImp += "	</SubMonto>" +  cCRLF
				EndIf
								
				aDet := {nPrcUnit,nPrcNeto,cDetXML,nUnit,cImpD,cSubImp,lGrat}
				(cAliasXML)->(dbskip())
			EndDo						
		(cAliasXML)->(dbCloseArea())		
	EndIf
	RestArea(aArea)	
Return aDet

/*/{Protheus.doc} M485TOTENC
Obtiene datos del encabezado dado un documento
@type function
@author mayra.camargo
@since 05/02/2019
@version 1.0
@param nTipDoc, c, Tipo de Documento 0 entrada 1 salida
@param cSerie, c, Serie del documento
@param cCltProv, c, código de cliente
@param cTienda, c, codigo de tienda
@param cNumDoc, c, Número de documento
@param cEspDoc, c, especie del documento
@param nAmbte, c, Ambiente utilizado
@param cSerie2, c, Serie del documento a 4 caracteres
@Return aEnc, array con datos del encabezado
@example
(examples)
@see (links_or_references)
/*/
Function M485TotEnc(nTipDoc, cSerie, cCltProv, cTienda, cNumDoc, cEspDoc, nAmbte,cSerie2)
	Local aEnc      := {}
	Local aArea		:= GetArea()
	Local aAreaSF1	:= SF1->(GetArea())
	Local cCRLF		:= (chr(13)+chr(10) )
	Local aImp		:= {}
	Local aImpDet	:= {}
	Local aExtImp	:= {}
	Local nA		:= 0
	Local nC		:= 0
	Local cDocument	:= ""
	Local nValor    := 0
	Local nDesc     := 0
	Local cImpD		:= ""
	Local cClave	:= ""
	Local lImpIncl  := .F.
	Local cTpDoc 	:= ""
	Local nPrcUnit	:= 0
	Local nPrcNetIt	:= 0
	Local nQtdItem	:= 0
	Local cCposQuery:= ""
	Local cCposFrom	:= ""
	Local cWhere	:= ""
	Local cAliasXML	:= getNextAlias()
	Local nUnit		:= 0
	Local nImp		:= 0
	Local lDocEx	:= .F.
	Local cTESGrat	:= getMV("MV_TESEXE") // TES para factura Gratuita
	Local lGrat		:= .F.
	Local cDescSai  := GetNewPar('MV_DESCSAI', '1')
	Local nSubMontMerc := 0
	Local nSubTot	:= 0
	Local nMoneda	:= 1
	Local cImpXML   := "" // Impuestos generales
	Local cTotXML   := "" // Nodo Subtotales
	Local cMoneda   := ""
	Local lAplDesc  := .T.
	Local aDetra    := {}
	Local lDetra    := .F. //Existen detracciones en el documento
	Local nTotDetra := 0 //Valor tota de detracciones
	Local aReten := {} // Retenciones

	Private nTamDoc := TamSX3("F1_DOC")[1]
	Private cfilSF1	:= xFilial("SF1")
	Private cFilSD1	:= xFilial("SD1")
	Private cFilSF2	:= xFilial("SF2")
	Private cFilSD2	:= xFilial("SD2")
	Private cFilSFB	:= xFilial("SFB")
	Private cFilSB1	:= xFilial("SB1")
	Private cFilSA1	:= xFilial("SA1")
	Private cFilSFC	:= xFilial("SFC")
	Private cFilSF4	:= xFilial("SF4")
	Private cFilCTO	:= xFilial("CTO")
	Private cFilSYA	:= xFilial("SYA")
	Private cPict	:= "99999999999999.99"
	
	//Tipos de Documento				
	If Alltrim(cEspDoc)=="NF" .AND. 'F' $ Substr(cSerie2,1,1) // Factura
		cTpDoc := '01'
	ElseIF Alltrim(cEspDoc)=="NCC" // Nota de Crédito
		cTpDoc   := '07'
		lAplDesc := .F. //No aplica descuentos
	ElseIf Alltrim(cEspDoc)=="NDC" // Nota de Débito
		cTpDoc   := '08'
	ElseIf Alltrim(cEspDoc)=="NF" .AND. 'B' $ Substr(cSerie2,1,1) // Boleta de Venta
		cTpDoc := '03'
	EndIf
	
	If(nTipDoc <= 0) //Documentos Nota de Credito
		cCposQuery := "% SF1.F1_FILIAL, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_ESPECIE, SF1.F1_SERIE, SF1.F1_DOC, SF1.F1_EMISSAO, SF1.F1_HORA, SF1.F1_MOEDA, " 
		cCposQuery += "  SF1.F1_VALMERC, SF1.F1_DESCONT, SF1.F1_VALBRUT, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_CEP, SA1.A1_CGC, SA1.A1_GLN,SA1.A1_EMAIL,SA1.A1_CONTATO , SB1.B1_UM, SB1.B1_PRODSAT, "
		cCposQuery += "  SB1.B1_COD, SB1.B1_DESC, SD1.D1_ITEM, SD1.D1_QUANT, SD1.D1_TOTAL, SD1.D1_VUNIT, SD1.D1_DESC, SD1.D1_TES, SD1.D1_NFORI, "
		cCposQuery += "  SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SF1.F1_TIPO, SYA.YA_DESCR,  " 
		cCposQuery += "  SF1.F1_MOTIVO,SA1.A1_TIPDOC,SD1.D1_VALDESC,SA1.A1_EST,SA1.A1_BAIRRO, SF1.F1_SERIE2,SD1.D1_SERIORI, SF1.F1_TIPREF,SA1.A1_PFISICA, SA1.A1_EST,SA1.A1_PAIS  %"
	
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
		cWhere		+= " AND SA1.A1_FILIAL = '"+cFilSA1+"'"
		cWhere		+= " AND SYA.YA_FILIAL = '"+cFilSYA+"'"
		cWhere		+= " AND SB1.B1_FILIAL = '"+cFilSB1+"'"
	
		If ( TcSrvType()=="AS/400" )
			cWhere	+="     AND SF1.@DELETED@  = ' ' "
			cWhere	+="		 AND SD1.@DELETED@  = ' ' "
			cWhere	+="		 AND SA1.@DELETED@  = ' ' "
			cWhere	+="		 AND SYA.@DELETED@  = ' ' "
			cWhere	+="     AND SB1.@DELETED@  = ' ' %"
		Else
			cWhere	+="     AND SF1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SD1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SA1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SYA.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SB1.D_E_L_E_T_  = ' ' %"
		EndIf
	
		BeginSql alias cAliasXML
			SELECT %exp:cCposQuery%
			FROM  %exp:cCposFrom%
			WHERE %exp:cWhere%
			ORDER BY SD1.D1_ITEM
		EndSql
		
		TCSetField(cAliasXML,"F1_EMISSAO","D") //Los campos tipo fecha se quedan como tipo fecha, pues por query son recuperados como string
	
		dbSelectArea(cAliasXML)
		
		(cAliasXML)->(DbGoTop())
		
		While (cAliasXML )->(!Eof())		
			cDocument 	:= (cAliasXML)->F1_DOC
			lDocEx		:= (Alltrim((cAliasXML)->A1_EST) == "EX")		// Si el A1_EST == EX  es un cliente Extrangero por tanto se trata de documento de Exportación
			cClave 		:= (cAliasXML)->F1_DOC + (cAliasXML)->F1_SERIE + (cAliasXML)->F1_FORNECE + (cAliasXML)->F1_LOJA + (cAliasXML)->F1_TIPO
			nDesc := (cAliasXML)->F1_DESCONT
					
			// Tabla de Monedas: Se obtiene código moneda ISO-4217 TABLA XF 
			nMoneda := (cAliasXML)->F1_MOEDA
			
			nValor 	:= (cAliasXML)->F1_VALBRUT			
			lGrat	:= (cAliasXML)->D1_TES $ cTESGrat					
			aImp    := NFAEXmlImp(nTipDoc,(cAliasXML)->F1_FORNECE,(cAliasXML)->F1_LOJA,(cAliasXML)->F1_DOC,(cAliasXML)->F1_SERIE,lDocEx,@aReten)

			For nA :=1 To Len(aImp)
				cImpXML += ' <Impuestos>'+ cCRLF
				cImpXML += '		<TipoImp>'+ aImp[Na][2] +'</TipoImp>'+ cCRLF
				cImpXML += '		<TasaImp>'+ Alltrim(aImp[Na][1]) +'</TasaImp>'+ cCRLF
				cImpXML += '		<MontoImp>'+ Alltrim(aImp[Na][5]) +'</MontoImp>'+ cCRLF
				cImpXML += '	</Impuestos>'+ cCRLF
			Next nA

			For nA:=1 To Len(aReten)
				cImpXML += '	<Retenciones>'+ cCRLF
				cImpXML += '		<TipoRet>'+ Alltrim(aReten[Na][2]) +'</TipoRet>'+ cCRLF
				cImpXML += '		<TasaRet>'+ TRANSFORM(Alltrim(STR(VAL(Alltrim(aReten[Na][1])) / 100)),"9.99") +'</TasaRet>'+ cCRLF
				cImpXML += '		<MontoBaseRet>'+ Alltrim(aReten[Na][4]) +'</MontoBaseRet>'+ cCRLF
				cImpXML += '		<MontoRet>'+ Alltrim(aReten[Na][5]) +'</MontoRet>'+ cCRLF
				cImpXML += '	</Retenciones>'+ cCRLF
			Next
							
			While (cAliasXML)->(!Eof()) .and. cSerie ==(cAliasXML)->F1_SERIE .AND. cNumDoc ==(cAliasXML)->F1_DOC .AND. cEspDoc == (cAliasXML)->F1_ESPECIE

				nUnit 	:= (cAliasXML)->D1_TOTAL
				aImpDet := NFAEDetImp(nTipDoc,(cAliasXML)->D1_DOC+(cAliasXML)->D1_SERIE+(cAliasXML)->D1_FORNECE+(cAliasXML)->D1_LOJA+(cAliasXML)->D1_COD+(cAliasXML)->D1_ITEM,(cAliasXML)->D1_TES )
				cImpD 	:= ""
				nImp	:= 0
					
				If !lDocEx // Tratamiento documentos Nacionales
					For nC:=1 To Len(aImpDet)
						aExtImp := ExtImp(aImpDet[nC][1], (cAliasXML)->D1_TES)
						If len(aExtImp) > 0
							lImpIncl:= aImpDet[nC][5]
							nImp += Val(aImpDet[nC][4])
						EndIf
					Next
					If len(aImpDet) == 0 // cuando la TES no tiene impuestos asociados
						aExtImp := ExtImp("0", (cAliasXML)->D1_TES,.F.)	
						If len(aExtImp) > 0
							nImp += 0
						EndIf
					EndIf				
				Else // Impuestos Detalle Documentos Exportación
					aExtImp := ExtImp('0', (cAliasXML)->D1_TES,lDocEx)
					If len(aExtImp) > 0
						nImp += 0
					EndIf
				EndIf
				
				If !lGrat
					If cDescSai $ "1"
						nPrcUnit:= nPrcUnit + ((cAliasXML)->D1_VALDESC/nQtdItem)
					ElseIf cDescSai $ "2"
						nPrcUnit:= nPrcUnit - ((cAliasXML)->D1_VALDESC/nQtdItem)
						nPrcNetIt:= nPrcNetIt - ((cAliasXML)->D1_VALDESC/nQtdItem)
					EndIf
					If nImp > 0 .and. !lImpIncl
						nPrcNeto := (nPrcNetIt+nImp)/nQtdItem
					Else
						nPrNeto := nUnit/nQtdItem 
						If lImpIncl				
							nPrcUnit:= nPrcUnit - ((cAliasXML)->D1_VALDESC/nQtdItem)
							nSubMontMerc := nUnit
							nUnit := nUnit - nImp	
							nPrcNetIt := nSubMontMerc
							nPrcUnit := nSubMontMerc
						EndIf
					EndIf
				Else
					nPrcBruto := 0
					nPrcNeto := 0 				
				EndIf

				If cDescSai $ "2"
					nPrcUnit:= nPrcUnit + ((cAliasXML)->D1_VALDESC/nQtdItem)
					nUnit := nPrcNetIt * nQtdItem
				EndIf
				nSubTot += nUnit
								
				(cAliasXML)->(dbskip())
			EndDo
			
			// Aqui van los submontos			
			cTotXML += fGetSubTot(cClave,nDesc, nSubTot, lDocEx,lGrat,lAplDesc)						
		EndDo
				
		aEnc:= {cTpDoc,nSubTot,lGrat,cTotXML,cImpXML}
		(cAliasXML)->(dbCloseArea())	
	Else //Documentos de Factura de Venta/Nota de Debito
	
		cCposQuery := "% SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SF2.F2_HORA, SF2.F2_MOEDA,SF2.F2_NFREF,SF2.F2_SERREF, " //querry para las notas debitos y facturas de venta.
		cCposQuery += "  SF2.F2_VALMERC, SF2.F2_DESCONT, SF2.F2_VALBRUT, SF2.F2_MOTIVO, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_CEP, SA1.A1_CGC, SA1.A1_GLN,SA1.A1_EMAIL,SA1.A1_CONTATO , SB1.B1_UM, SB1.B1_PRODSAT, "
		cCposQuery += "  SD2.D2_ITEM, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_DESC, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_NFORI, SD2.D2_LOJA, "
		cCposQuery += "  SD2.D2_COD, SD2.D2_TES, SB1.B1_UM, SB1.B1_COD, SB1.B1_DESC, SYA.YA_DESCR, "
		cCposQuery += "  SA1.A1_TIPDOC, SD2.D2_DESCON,SA1.A1_EST,SA1.A1_BAIRRO, SD2.D2_VALBRUT, SF2.F2_SERIE2,SA1.A1_PFISICA, SA1.A1_EST, SA1.A1_PAIS %"
		
		cCposFrom	:= "% " + RetSqlName("SF2") + " SF2, "
		cCposFrom	+= RetSqlName("SD2")+ " SD2, "
		cCposFrom	+= RetSqlName("SA1")+ " SA1, "
		cCposFrom	+= RetSqlName("SYA")+ " SYA, "
		cCposFrom	+= RetSqlName("SB1")+ " SB1 %"
	
		cWhere	:= "% SF2.F2_SERIE = '"+ cSerie +"' AND SF2.F2_DOC = '"+ cNumDoc +"' AND SF2.F2_CLIENTE = '"+ cCltProv +"' "
		cWhere	+= "  AND SF2.F2_LOJA = '"+ cTienda +"' AND SF2.F2_ESPECIE = '"+ cEspDoc +"' AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
		cWhere	+= "  AND SF2.F2_LOJA = SD2.D2_LOJA AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_DOC = SD2.D2_DOC "
		cWhere	+= "  AND SF2.F2_ESPECIE = SD2.D2_ESPECIE AND SB1.B1_COD = SD2.D2_COD AND SA1.A1_COD = SF2.F2_CLIENTE "
		cWhere	+= "  AND SA1.A1_LOJA = SF2.F2_LOJA AND  SYA.YA_CODGI = SA1.A1_PAIS " 
	
		cWhere	+= " AND SF2.F2_FILIAL = '"+cFilSF2+"'"
		cWhere	+= " AND SD2.D2_FILIAL = '"+cFilSD2+"'"
		cWhere	+= " AND SA1.A1_FILIAL = '"+cFilSA1+"'"
		cWhere	+= " AND SB1.B1_FILIAL = '"+cFilSB1+"'"
		cWhere	+= " AND SYA.YA_FILIAL = '"+cFilSYA+"'"
	
		If ( TcSrvType()=="AS/400" )
			cWhere	+="		 AND SD2.@DELETED@  = ' ' "
			cWhere	+="     AND SF2.@DELETED@  = ' ' "
			cWhere	+="		 AND SA1.@DELETED@  = ' ' "
			cWhere	+="		 AND SYA.@DELETED@  = ' ' "
			cWhere	+="     AND SB1.@DELETED@  = ' ' %"
		Else
			cWhere	+="     AND SD2.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SF2.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SA1.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SYA.D_E_L_E_T_  = ' ' "
			cWhere	+="     AND SB1.D_E_L_E_T_  = ' ' %"
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
			cClave  := (cAliasXML)->F2_CLIENTE + (cAliasXML)->F2_LOJA + (cAliasXML)->F2_DOC + (cAliasXML)->F2_SERIE			
			lDocEx	:= (Alltrim((cAliasXML)->A1_EST) == "EX")						
			nValor 	:= (cAliasXML)->F2_VALBRUT
			nDesc  	:= (cAliasXML)->F2_DESCONT
			//Se obtiene código moneda ISO-4217 TABLA XF
			cMoneda := Alltrim(fGetSX5("XQ" + STR((cAliasXML)->F2_MOEDA,2)))
			lGrat	:= 	(cAliasXML)->D2_TES $ cTESGrat
			
			aImp := NFAEXmlImp(nTipDoc,(cAliasXML)->F2_CLIENTE, (cAliasXML)->F2_LOJA, (cAliasXML)->F2_DOC, (cAliasXML)->F2_SERIE, lDocEx,@aReten)							
				
			For nA:=1 To Len(aImp)
				cImpXML += '	<Impuestos>'+ cCRLF
				cImpXML += '		<TipoImp>'+ aImp[Na][2] +'</TipoImp>'+ cCRLF
				cImpXML += '		<TasaImp>'+ Alltrim(aImp[Na][1]) +'</TasaImp>'+ cCRLF
				cImpXML += '		<MontoImp>'+ Alltrim(aImp[Na][5]) +'</MontoImp>'+ cCRLF
				cImpXML += '	</Impuestos>'+ cCRLF
			Next


			For nA:=1 To Len(aReten)
				cImpXML += '	<Retenciones>'+ cCRLF
				cImpXML += '		<TipoRet>'+ Alltrim(aReten[Na][2]) +'</TipoRet>'+ cCRLF
				cImpXML += '		<TasaRet>'+ TRANSFORM(Alltrim(STR(VAL(Alltrim(aReten[Na][1])) / 100)),"9.99") +'</TasaRet>'+ cCRLF
				cImpXML += '		<MontoBaseRet>'+ Alltrim(aReten[Na][4]) +'</MontoBaseRet>'+ cCRLF
				cImpXML += '		<MontoRet>'+ Alltrim(aReten[Na][5]) +'</MontoRet>'+ cCRLF
				cImpXML += '	</Retenciones>'+ cCRLF
			Next
					
			While (cAliasXML)->(!Eof()) .and. cSerie ==(cAliasXML)->F2_SERIE .AND. cNumDoc ==(cAliasXML)->F2_DOC .AND. cEspDoc == (cAliasXML)->F2_ESPECIE				
				nImp	:= 0
				//Generación de impuestos detalle
				aImpDet := NFAEDetImp(nTipDoc,(cAliasXML)->D2_DOC+(cAliasXML)->D2_SERIE+(cAliasXML)->D2_CLIENTE+(cAliasXML)->D2_LOJA+(cAliasXML)->D2_COD+(cAliasXML)->D2_ITEM,(cAliasXML)->D2_TES,.F.,@aDetra, @nTotDetra)
				If !lDocEx				
					For nC:=1 To Len(aImpDet)
						aExtImp := ExtImp(aImpDet[nC][1], (cAliasXML)->D2_TES)
						If len(aExtImp) > 0
							lImpIncl:= aImpDet[nC][5]
							nImp += Val(Alltrim(aImpDet[nC][4]))
						EndIf
					Next
				Else //Exportación
					aExtImp := ExtImp("0", (cAliasXML)->D2_TES,.T.)						
					If len(aExtImp) > 0
						nImp += 0
					EndIf
				EndIf
				
				nQtdItem	:= (cAliasXML)->D2_QUANT	
				nUnit 		:= (cAliasXML)->D2_TOTAL

				If lImpIncl
					nPrcUnit	:= (cAliasXML)->D2_PRCVEN - (nImp/nQtdItem)				
				Else
					nPrcUnit	:= (cAliasXML)->D2_PRCVEN
				EndIf
				
				If !lGrat
					nPrcUnit:= nPrcUnit + ((cAliasXML)->D2_DESCON/nQtdItem)
					If lImpIncl				
						nPrcUnit:= nPrcUnit - ((cAliasXML)->D2_DESCON/nQtdItem)
						nSubMontMerc := nUnit		
						nUnit := nUnit - nImp
						nPrcUnit := nSubMontMerc						
					EndIf
					nSubTot += nUnit  
				Else
					nSubTot += nUnit  
					nPrcUnit:= 0 
					nUnit  := 0
				EndIf
				
				(cAliasXML)->(dbskip())
			EndDo
			//Submontos
			cTotXML += fGetSubTot(cClave,nDesc,nSubTot,lDocEx,lGrat,lAplDesc,aDetra)
		EndDo		
		(cAliasXML)->(dbCloseArea())
		aEnc:= {cTpDoc,IIf(lGrat,0,nSubTot),lGrat,cTotXML,cImpXML,IIf(Len(aDetra)>0,.T.,.F.),nTotDetra}	
	EndIf 
	RestArea(aArea)	
	RestArea(aAreaSF1)
Return aEnc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ NFAEXmlImp ³ Autor ³ Jonathan Gonzalez   ³ Data ³ 12.01.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene impuestos de la Factura venta, Nta Deb. y Nta Cred.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ NFAEXmlImp(nTipDoc,cClave)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aImpsto                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1:= Tip documento 0= Nta Cred. 1= Fact Venta/Nta Deb.  ³±±
±±³          ³ cExp2:= Clave de Factura, Nta Debito y Nta Credito.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NFAEXmlImp(nTipDoc,cCliente,cLoja,cDoc,cSerie,lExp,aReten)
	Local nValImp	:= 0
	Local nBasImp	:= 0
	Local cCodImp	:= ""
	Local cCodTar	:= ""
	Local aArea 	:= getArea()
	Local aSFB		:= {'0'}
	Local aImpsto   := {}
	Local cImp	    := ""
	Local cPic      := "99999999999999999999.99"
	Local cAliasSD  := ""
	Local cBasImpSD := ""
	Local cValImpSD := ""
	Local cValImpAL := ""
	Local cValImpSF := ""
	Local cTesD     := ""
	Local cAliasImp := getNextAlias()
	Local cCampos   := ""
	Local cTablas   := ""
	Local cGroup    := ""
	Local cOrder    := ""
	
	Private nTamDoc := TamSX3("F1_DOC")[1]
	Private cfilSF1	:= xFilial("SF1")
	Private cFilSD1	:= xFilial("SD1")
	Private cFilSF2	:= xFilial("SF2")
	Private cFilSD2	:= xFilial("SD2")
	Private cFilSFB	:= xFilial("SFB")
	Private cFilSB1	:= xFilial("SB1")
	Private cFilSA1	:= xFilial("SA1")
	Private cFilSFC	:= xFilial("SFC")
	Private cFilSF4	:= xFilial("SF4")
	Private cFilCTO	:= xFilial("CTO")
	Private cFilSYA	:= xFilial("SYA")
	Private cPict	:= "99999999999999.99"
	
	Default lExp     := .F. // Si es de exportacion
	Default cCliente := ""
	Default cLoja    := ""
	Default cDoc     := ""
	Default cSerie   := ""

	dbSelectArea("SFB")
	SFB->(dbSetOrder(1)) //FB_FILIAL + FB_CODIGO
	
	If (nTipDoc <= 0) //Documentos de Entrada
		cAliasSD  := "SD1"
		cBasImpSD := "D1_BASIMP"
		cValImpSD := "D1_VALIMP"
		cValImpAL := "D1_ALQIMP"
		cValImpSF := "F1_VALIMP"
		cTesD     := "D1_TES"
		cCond	  := "% SD1.D1_DOC = '" + cDoc + "' AND SD1.D1_SERIE = '" + cSerie + "'"
		cCond     += " AND SD1.D1_FORNECE = '" + cCliente + "' AND SD1.D1_LOJA = '" + cLoja + "'"
		cCond  	  += " AND SD1.D1_TES = SFC.FC_TES "
	Else //Documentos de Salida
		cAliasSD  := "SD2"
		cBasImpSD := "D2_BASIMP"
		cValImpSD := "D2_VALIMP"
		cValImpAL := "D2_ALQIMP"
		cValImpSF := "F2_VALIMP"
		cTesD     := "D2_TES"
		cCond	  := "% SD2.D2_DOC = '" + cDoc + "' AND SD2.D2_SERIE = '" + cSerie + "'"
		cCond  	  += " AND SD2.D2_CLIENTE = '" + cCliente + "' AND SD2.D2_LOJA = '" + cLoja + "'"
		cCond  	  += " AND SD2.D2_TES = SFC.FC_TES "
	EndIf

	//Impuestos de documento
	cCampos	:= "% SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFB.FB_DESCR, SFB.FB_ALIQ, SFB.FB_CODIMP, SFC.FC_IMPOSTO, SFC.FC_INCDUPL  %"
	cTablas	:= "% " + RetSqlName(cAliasSD) + " " + cAliasSD + ", "  + RetSqlName("SFC") + " SFC, "  + RetSqlName("SFB") + " SFB %"

	cCond 	+= " AND SFC.FC_IMPOSTO = SFB.FB_CODIGO"
	cCond	+= " AND SFC.FC_FILIAL = '" + cFilSFB + "'"
	cCond	+= " AND SFB.FB_FILIAL = '" + cFilSFC + "'"
	cCond	+= " AND SFC.D_E_L_E_T_  = ' ' "
	cCond	+= " AND SFB.D_E_L_E_T_  = ' ' %"
	cGroup 	:= "% SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFB.FB_DESCR, SFB.FB_ALIQ, SFB.FB_CODIMP, SFC.FC_IMPOSTO, SFC.FC_INCDUPL %"
	cOrder 	:= "% SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFB.FB_DESCR, SFB.FB_ALIQ, SFB.FB_CODIMP, SFC.FC_IMPOSTO, SFC.FC_INCDUPL %"

	BeginSql alias cAliasImp
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
		ORDER BY %exp:cOrder%
	EndSql

	dbSelectArea(cAliasImp)
	(cAliasImp)->(DbGoTop())

	While (cAliasImp)->(!Eof())
		//Impuestos Variables
		If SFB->(dbSeek(cFilSFB + (cAliasImp)->FB_CODIGO))
			cImp    := (cAliasImp)->FB_CPOLVRO
			nPor    := (cAliasImp)->FB_ALIQ
			cCodImp := (cAliasImp)->FB_CODIMP
			cCodTar := ""
			
			If(nTipDoc <= 0) //Documentos Nota de Credito
				nBasImp := POSICIONE("SF1",1,cfilSF1 + cDoc + cSerie + cCliente + cLoja,"F1_BASIMP" + cImp)
				nValImp := POSICIONE("SF1",1,cfilSF1 + cDoc + cSerie + cCliente + cLoja,"F1_VALIMP" + cImp)
			Else
				nBasImp := POSICIONE("SF2",2,cfilSF2 + cCliente + cLoja + cDoc + cSerie,"F2_BASIMP" + cImp)
				nValImp := POSICIONE("SF2",2,cfilSF2 + cCliente + cLoja + cDoc + cSerie,"F2_VALIMP" + cImp)
			EndIf

			If nBasImp > 0 .and. aScan(aSFB,{|x| x == cImp}) == 0 .and. (cAliasImp)->FB_CLASSE == 'I'
				aAdd(aSFB,SFB->FB_CPOLVRO) 
				aAdd(aImpsto,{TRANSFORM(nPor,"999.99"),Alltrim(cCodImp),Alltrim(cCodTar),TRANSFORM(nBasImp,cPic),TRANSFORM(nValImp,cPic)})
			EndIf

			If nBasImp > 0 .and. aScan(aSFB,{|x| x == cImp}) == 0 .and. (cAliasImp)->FB_CLASSE == 'R'
				aAdd(aReten,{TRANSFORM(nPor,"999.99"),'62',Alltrim(cCodTar),TRANSFORM(nBasImp,cPic),TRANSFORM(nValImp,cPic)})
			EndIf
			
			If lExp .and. (cAliasImp)->FB_CODIGO == "IGV" .and. Len(aImpsto) == 0
				aAdd(aImpsto,{TRANSFORM(nPor,"999.99"),Alltrim(cCodImp),Alltrim(cCodTar),TRANSFORM(nBasImp,cPic),TRANSFORM(nValImp,cPic)})
				Exit				
			EndIf
			nBasImp:= 0
			nValImp:=0
		EndIf
		(cAliasImp)->(dbskip())
	EndDo

	(cAliasImp)->(DBCloseArea())
	RestArea(aArea)
Return aImpsto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ NFAEDetImp ³ Autor ³ Jonathan Gonzalez   ³ Data ³ 12.01.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene el detalle de los impuestos de la Factura venta,   ³±±
±±³          ³ Nta Deb. y Nta Cred.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ NFAEDetImp(nTipDoc,cClave)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aImp2                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1:= Tip documento 0= Nta Cred. 1= Fact Venta/Nta Deb.  ³±±
±±³          ³ cExp2:= Clave de Factura, Nta Debito y Nta Credito.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NFAEDetImp(nTipDoc,cClave,cTES,lDet,aDetra,nVlrDetra)
	Local nValImp	:= 0
	Local nBasImp	:= 0
	Local aArea 	:= getArea()
	Local aSFB		:= {'0'}
	Local aImp2		:= {}
	Local cImp		:= ""
	Local lIncluido	:= .F.
	Local cPic		:= "99999999999999999999.99"
	Local cFilSD1	:= xFilial("SD1")
	Local cFilSD2	:= xFilial("SD2")
	Local cFilSFB	:= xFilial("SFB")
	Local cFilSFC	:= xFilial("SFC")
	
	Default lDet := .F.
	Default cTES := ""
	Default aDetra := {}
	Default nVlrDetra := 0

	dbSelectArea("SFC")
	SFC->(dbSetOrder(2)) //FC_FILIAL + FC_TES + FC_IMPOSTO
	dbSelectArea("SFB")
	SFB->(dbSetOrder(1)) //FB_FILIAL + FB_CODIGO

	If SFC->(dbSeek(cFilSFC + cTES))
		While !(SFC->(Eof())) .And. SFC->FC_FILIAL + SFC->FC_TES == cFilSFC + cTES
			//Impuestos Variables
			If SFB->(dbSeek(cFilSFB + SFC->FC_IMPOSTO))
				cImp := SFB->FB_CPOLVRO
				nPor := SFB->FB_ALIQ
				
				If(nTipDoc <= 0)
					If lDet
						nBasImp := SD1->&("D1_BASIMP" + cImp )
						nValImp := SD1->&("D1_VALIMP" + cImp )
					Else
						nBasImp := POSICIONE( "SD1" , 1 , cFilSD1+cClave , "D1_BASIMP" + cImp )
						nValImp := POSICIONE( "SD1" , 1 , cFilSD1+cClave , "D1_VALIMP" + cImp )
					EndIf			
				Else
					If lDet
						nBasImp := SD2->&("D2_BASIMP" + cImp) 
						nValImp := SD2->&("D2_VALIMP" + cImp)
					Else
						nBasImp := POSICIONE( "SD2" , 3 , cFilSD2+cClave , "D2_BASIMP" + cImp )
						nValImp := POSICIONE( "SD2" , 3 , cFilSD2+cClave , "D2_VALIMP" + cImp )
					EndIf
				EndIf
				
				IF nBasImp > 0 .and. aScan(aSFB,{|x| x == cImp}) == 0 .AND. SFB->FB_CLASSE == 'I'
					If !Empty(cTES)
						lIncluido := POSICIONE("SFC",2,cFilSFC+cTES+SFB->FB_CODIGO,"FC_INCDUPL") $ "3"
					EndIf
					aAdd(aSFB,SFB->FB_CPOLVRO)
					aAdd( aImp2 , { SFB->FB_CPOLVRO , TRANSFORM(nPor,"999.99") , TRANSFORM(nBasImp,cPic) , TRANSFORM(nValImp,cPic), lIncluido,SFB->FB_CODIGO} )
				EndIf

				//Detracciones
				If  nTipDoc .And. nBasImp > 0 .And. SFB->FB_CLASSE == 'D'
					cTasa   := Alltrim(TRANSFORM(nPor,"999.99"))
					nPosDet := aScan(aDetra,{|x| x[1] == cTasa}) 
					lIncluido := POSICIONE("SFC",2,cFilSFC+cTES+SFB->FB_CODIGO,"FC_INCDUPL") $ "3"
					If lIncluido
						nVlrDetra += nValImp
					EndIf 
					If nPosDet == 0
						aAdd(aDetra,{cTasa,nValImp})
					Else
						aDetra[nPosDet][2] += nValImp
					EndIf
				EndIf
				nBasImp := 0
				nValImp := 0
			EndIf
			SFC->(dbSkip())
		EndDo
	EndIf
	RestArea(aArea)
Return aImp2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ExtImp     ³ Autor ³ Guadalupe Santacruz ³ Data ³ 06.03.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene el Codigo de la tasa y el codigo del impuesto segun³±±
±±³          ³ SRI de acuerdo a la TES de los items de la Factura,  Nta   ³±±
±±³          ³ Deb. y Nta Cred.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExtImp(nNumImp, cTES)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aImpuestos                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1:= Numero base del impuesto                           ³±±
±±³          ³ cExp2:= TES del impuesto.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function ExtImp(nNumImp, cTES, lEx)
	Local aImpuestos	:= {}      
	Local cNumImp		:= Alltrim(nNumImp)
	Local cFilSFB		:= xFilial("SFB")
	Local cFisSFC		:= xFilial("SFC")
	
	Default lEx := .F.
	
	SFC->(dbSetOrder(1)) //FC_FILIAL + FC_TES + FC_SEQ + FC_IMPOSTO
	SFB->(dbSetOrder(1)) //FB_FILIAL + FB_CODIGO
	
	If !lEx
		IF SFC->(dbSeek(cFisSFC + cTES))
			While !(SFC->(Eof())) .And. SFC->FC_TES == cTes
				IF SFB->(dbSeek(cFilSFB + SFC->FC_IMPOSTO))
					IF Alltrim(cNumImp)==Alltrim(SFB->FB_CPOLVRO) .and. SFB->FB_CLASSE =='I'
						aAdd(aImpuestos,{ SFB->FB_CODIGO , IIf(SFB->FB_CODIMP $ "1000",SFC->FC_TIPOIGV,SFC->FC_TIPOISC),Alltrim(SFB->FB_CODIMP)})
					exit
					EndIf
				EndIf
				SFC->(DBSKIP())
			ENDDO
		EndIf
	EndIf
	If len(aImpuestos) == 0 
		IF SFB->(dbSeek(cFilSFB + "IGV"))
			aAdd(aImpuestos,{ SFB->FB_CODIGO , SFC->FC_TIPOIGV,Alltrim(SFB->FB_CODIMP),SFB->FB_ALIQ})
		EndIf
	EndIf
Return aImpuestos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ getRef     ³ Autor ³ Mayra.Camargo       ³ Data ³ 02.07.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene los documentos ligados a la NCC|NDC según corres-  ³±±
±±³          ³ ponda en SE5                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ getRef(ExpC01,ExpC02,ExpC03,ExpC04,ExpC05)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aImpuestos                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01:= Numero documento                                  ³±±
±±³          ³ ExpC02:= Serie del Documento                               ³±±
±±³          ³ ExpC03:= Proveedor                                         ³±±
±±³          ³ ExpC04:= Tienda                                            ³±±
±±³          ³ ExpC05:= Especie del documento (NCC/NDC)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M485GetRef(cDoc,cDocSerie,cProv,cTienda,cEspecie,lSE5,cMotivo,cTipRef)
	Local aArea	:= getArea()
	Local cRet 	:= ""
	Local aFac 	:= {}
	Local cClave:= ""
	Local nI	:= 0
	Local cNF	:= ""
	Local cPar	:= Space(TamSx3("E5_PARCELA")[1])
	Local cFech	:= ""
	Local nTamDoc:= Tamsx3("F2_DOC")[1]
	Local cNFac	:= ""
	Local cHora	:= "00:00:00"
	Local cTabSF2:= getNextAlias()
	Local cEspNF:= "NF%"
	Local cEst	:= ""
	Local aRet	:= {}
	Local nK	:= 0
	Local cTabPref := "SF2"
	Local cPrefijo := "F2_"
	Local cTipoDoc := "01"
	Local cEspRef  := "NF"
	Local cFilSF   := ""
	
	Default lSE5 := .F.
	Default cTipRef := "1"
	
	If Alltrim(cEspecie) = "NCC"
		cTipoDoc := "01"
		cClave := cDocSerie + cDoc + cPar+ Alltrim(cEspecie) + cTienda 
		If lSE5
			dbSelectArea("SE5")
			SE5->(dbSetOrder(10)) //E5_FILIAL + E5_DOCUMEN
		
			If SE5->(dbSeek( xFilial("SE5") + cClave,.T.))			
				While SFB->(!EOF()) .and. Alltrim(cClave) $ SE5->E5_DOCUMEN .and. SE5->E5_TIPODOC='CP' .and. SE5->E5_MOTBX='CMP'	.and. SE5->E5_FILIAL == xFilial("SE5")		
				
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
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			
			If SF2->(dbSeek(cNF))				
				If ! Empty(SF2->F2_HORA)
					If len(Alltrim(SF2->F2_HORA)) == 5
						cHora := SF2->F2_HORA + ":00"
					Else
						cHora := SF2->F2_HORA
					EndIf
				EndIf
				cTipoDoc := IIf(sUBSTR(SF2->F2_SERIE2,1,1) $ "F", '01',IIf(sUBSTR(SF2->F2_SERIE2,1,1) $ "B",'03',"01"))
				cFech := SUBSTR(DTOS(SF2->F2_EMISSAO),0,4) + "-" +;
						  SUBSTR(DTOS(SF2->F2_EMISSAO),5,2) + "-" +;
						  SUBSTR(DTOS(SF2->F2_EMISSAO),7,2) + "T" + cHora +"Z"
				cNFac := substr(SF2->F2_DOC,(nTamDoc-8),9)

				aAdd(aRet,{cEst	,;
							IIf(Empty(SF2->F2_SERIE2),"0"+SF2->F2_SERIE ,SF2->F2_SERIE2) 	,;
							cNFac				,;
							cFech				})
			EndIf
		Next		
	ElseIf Alltrim(cEspecie) == "NDC"
		cNF := xFilial(cTabPref) + cDoc + cDocSerie + cProv + cTienda  
		cEspNF := cEspRef + "%"
		If Alltrim(cEspRef) == "NF"
			cTabPref := "SF2"
			cFilSF := xFilial("SF2")
			cTipoDoc := "01"
			BEGINSQL ALIAS cTabSF2
				SELECT  *
				FROM %TABLE:SF2% SF2
				WHERE F2_FILIAL = %EXP:cFilSF%
				AND F2_DOC = %EXP:cDoc%
				AND F2_SERIE = %EXP:cDocSerie%
				AND F2_CLIENTE = %EXP:cProv%
				AND F2_LOJA = %EXP:cTienda%
				AND F2_ESPECIE LIKE %EXP:CESPNF%
				AND SF2.%NOTDEL%			
			ENDSQL
		
			TCSetField(cTabSF2,"F2_EMISSAO","D")
		Else
			cTabPref := "SF1"
			cTipoDoc := "07"
			cPrefijo := "F1_"
			BEGINSQL ALIAS cTabSF2
				SELECT  *
				FROM %TABLE:SF1% SF1
				WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA=%EXP:CNF%
				AND F1_ESPECIE LIKE %EXP:CESPNF%
				AND SF1.%NOTDEL%
			ENDSQL
		
			TCSetField(cTabSF2,"F1_EMISSAO","D")
		EndIf

		dbSelectArea(cTabSF2)
	
		(cTabSF2)->(DbGoTop())
		
		cTipoDoc := IIf(Alltrim(cEspRef) == "NF",'01','07')
		
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
			cTipoDoc := IIf(sUBSTR((cTabSF2 )->&(cPrefijo+"SERIE2"),1,1) $ "F", '01','03')
			aAdd(aRet,{ 					,;
						IIf(Empty((cTabSF2 )->&(CPrefijo + "SERIE2")),"0"+(cTabSF2 )->&(CPrefijo + "SERIE"),(cTabSF2 )->&(CPrefijo + "SERIE2")) 					,;
						cNFac				,;
						cFech				})
			(cTabSF2 )->(dbSkip())
		EndDo
		(cTabSF2 )->(dbCloseArea())
	EndIf

	For nK := 1 to len (aRet)
		cRet += '<Referencia>'+ cCRLF
		cRet += '	<NroLinRef>'+ Alltrim(STR(nK))+'</NroLinRef>'+ cCRLF
		cRet += '	<TpoDocRef>' + cTipoDoc + '</TpoDocRef>'+ cCRLF
		cRet += '	<SerieRef>' + aRet[nK,2] + '</SerieRef>' + cCRLF
		cRet += '	<NumeroRef>'+ Alltrim(STR(VAL(aRet[nK,3]))) + '</NumeroRef>'+ cCRLF
		cRet += '	<FechaRef>' + aRet[nK,4] + '</FechaRef>'+ cCRLF
		cRet += '	<CodRef>' + cTipRef + '</CodRef>' + cCRLF
		cRet += '	<RazonRef>' + cMotivo + '</RazonRef>'+ cCRLF
		cRet += '</Referencia>'+ cCRLF			
	Next			

	RestArea(aArea)
Return cRet

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
Function fGetSX5(cClave)
	Local cRet := ""
	cRet := Alltrim(POSICIONE("SX5",1,xFilial("SX5")+cClave,"X5_DESCSPA"))
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fGetSubTot ³ Autor ³ Jonathan Gonzalez   ³ Data ³ 12.01.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene impuestos de la Factura venta, Nta Deb. y Nta Cred.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGetSubTot(nTipDoc,cClave)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1:= Tip documento 0= Nta Cred. 1= Fact Venta/Nta Deb.  ³±±
±±³          ³ cExp2:= Clave de Factura, Nta Debito y Nta Credito.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGetSubTot(cClave,nDescont,nValMerc,lEx,lGrat,lAplDesc,aDetra) 
	Local cRET := ""
	Local cValMer := Alltrim(Transform(nValMerc,cPict))
	Local nX := 0

	Default lEx      := .F.
	Default lGrat    := .F.
	Default lAplDesc := .T.
	Default aDetra   := {}
	
	// Ventas Gravadas
	cRet += "			<TotSubMonto>"    + cCRLF
	cRet += "				<Tipo>1001</Tipo> " + cCRLF           
	cRet += "				<MontoConcepto>"+ IIf(lEx,"0.00",IIf(lGrat,"0.00",cValMer)) +"</MontoConcepto>" + cCRLF
 	cRet += "			</TotSubMonto>"+ cCRLF
 	
	// Operaciones Inafectas
	cRet += "			<TotSubMonto>"    + cCRLF
	cRet += "				<Tipo>1002</Tipo> " + cCRLF           
	cRet += "				<MontoConcepto>"+ IIf(lEx,cValMer,"0.00")+"</MontoConcepto>" + cCRLF
 	cRet += "			</TotSubMonto>"+ cCRLF
	
	// Ventas Exoneradas
	cRet += "			<TotSubMonto>"    + cCRLF
	cRet += "				<Tipo>1003</Tipo> " + cCRLF           
	cRet += "				<MontoConcepto>0.00</MontoConcepto>" + cCRLF
 	cRet += "			</TotSubMonto>"+ cCRLF
	
	// Subtotal Operaciones Gratuitas
	cRet += "			<TotSubMonto>"    + cCRLF
	cRet += "				<Tipo>1004</Tipo> " + cCRLF           
	cRet += "				<MontoConcepto>" + IIf(lGrat,cValMer,"0.00") + "</MontoConcepto>" + cCRLF
 	cRet += "			</TotSubMonto>"+ cCRLF
		
	// Subtotal de Venta	
	cRet += "			<TotSubMonto>" + cCRLF
	cRet += "				<Tipo>1005</Tipo>" + cCRLF
	cRet += "				<MontoConcepto>" + IIf(!lGrat,cValMer,"0.00") + "</MontoConcepto>"+ cCRLF
	cRet += "			</TotSubMonto>" + cCRLF
		
	//Detracciones
	If Len(aDetra) > 0
		For nX := 1 To Len(aDetra)
			cRet += "			<TotSubMonto>" + cCRLF
			cRet += "				<Tipo>2003</Tipo>" + cCRLF
			//Código del bien o servicio sujeto a detracción (Catálogo 54)
			If SF2->(ColumnPos("F2_CODDOC")) > 0
				cRet += "				<CodTipoMonto>" + Alltrim(SF2->F2_CODDOC) + "</CodTipoMonto>" + cCRLF
			EndIf
			cRet += "				<TasaConcepto>" + aDetra[nX][1] + "</TasaConcepto>" + cCRLF
			cRet += "				<MontoConcepto>" + Alltrim(Transform(aDetra[nX][2],cPict)) + "</MontoConcepto>"+ cCRLF
			cRet += "			</TotSubMonto>" + cCRLF
		Next nX
	EndIf

	//Descuentos	
	IF nDescont > 0 
		cRet += "			<TotSubMonto>" + cCRLF
		cRet += "				<Tipo>2005</Tipo>" + cCRLF
		cRet += "				<MontoConcepto>" + Alltrim(Transform(IIf(lAplDesc,nDescont,0),cPict)) + "</MontoConcepto>"+ cCRLF
		cRet += "			</TotSubMonto>" + cCRLF
	EndIf
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fCero2Text ³ Autor ³ Mayra Camargo       ³ Data ³ 24.03.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Coloca moneda a texto para valor 0                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCero2Text(nPar01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fCero2Txt(nMdn)
	Local cText 	:= ""
	Local cIdMoedaS := GetMV("MV_MOEDA" + Alltrim(Str(nMdn)))
	Default nMdn    := 1
	
	cText := "CERO " + cIdMoedaS + " Y 0 CENTAVOS"
Return cText

/*/{Protheus.doc} M486TPPAG
Obtiene el tipo de pago configurado para la Condición de Pago
@type function
@author luis.enríquez
@since 12/02/2021
@version 1.0
@param cFilSE4, caracter, Alias de la tabla SE4
@param cCondPago, caracter, Código de la Condición de Pago
@return cTPago, caracter, Opción de tipo de pago 1-Contado o 2-Crédito
/*/
Function M485TPPAG(cFilSE4, cCondPago)
	Local aArea   := getArea()
	Local cTPago  := ""
	Local lTipoPago := SE4->(ColumnPos("E4_MPAGSAT")) > 0

	Default cFilSE4 := xFilial("SE4")
	Default cCondPago := ""

	If lTipoPago
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1)) //E4_FILIAL + E4_CODIGO
		If SE4->(MsSeek(cFilSE4 + cCondPago))
			cTPago := SE4->E4_MPAGSAT
		EndIf
		RestArea(aArea)
	EndIf
Return cTPago

/*/{Protheus.doc} M485CUOTA
Obtiene datos requeridos para las cuotas y el saldo acumulado de todas las cuotas del documento
@type function
@author luis.enríquez
@since 12/02/2021
@version 1.0
@param cFilOri, caracter, Filial del documento
@param cCliente, caracter, Código del cliente del documento
@param cLoja, caracter, Código de tienda del documento
@param cSerie, caracter, Serie del documento
@param cDoc, caracter, Folio del documento
@param cEspecie, caracter, Especie del documento
@param cHora, caracter, Valor de hora de vencimientoL
@return Return, array, [1] = Nodo de cuotas de referencia y [2] = Acumulado del saldo de las cuotas
/*/
Function M485CUOTA(cFilOri,cCliente,cLoja,cSerie,cDoc,cEspecie,cHora,nDscDetra)
	Local aArea     := getArea()
	Local cTRBSE1   := getNextAlias()
	Local nCuota    := 0
	Local cStrCuota := ""
	Local cFecPar   := ""
	Local aParcelas := {}
	Local nSalAcum  := 0
	Local cXMLTPago := ""
	Local nP        := 0
	Local nMonto    := 0
	Local nTotNeto  := 0
	Local nTotForm  := 0

	Default nDscDetra := 0

	BeginSql alias cTRBSE1
		SELECT E1_FILORIG, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO FECVEN, E1_VALOR VALOR, E1_SALDO SALDO
		FROM  %table:SE1% SE1
		WHERE E1_FILORIG = %exp:cFilOri%
			AND E1_CLIENTE = %exp:cCliente%
			AND E1_LOJA = %exp:cLoja%
			AND E1_PREFIXO = %exp:cSerie%
			AND E1_NUM = %exp:cDoc%
			AND E1_TIPO = %exp:cEspecie%
			AND SE1.%notDel%
		ORDER BY E1_FILORIG, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	EndSql

	TCSetField(cTRBSE1,'FECVEN','D')

	dbSelectArea(cTRBSE1)
	
	While (cTRBSE1)->(!EOF()) 
		nCuota += 1
		cStrCuota := "Cuota" + Padl(Alltrim(Str(nCuota)),3,'0') 
		cFecPar := Alltrim(Str(YEAR((cTRBSE1)->FECVEN))) + "-" + Padl(Alltrim(Str(MONTH((cTRBSE1)->FECVEN))),2,'0') + "-" +;
		Padl(Alltrim(Str(DAY((cTRBSE1)->FECVEN))),2,'0')	
		nSalAcum += (cTRBSE1)->SALDO
		aAdd(aParcelas, {cStrCuota, (cTRBSE1)->VALOR, cFecPar})
		(cTRBSE1)->(dbSkip())
	EndDo

	//Descuentos a cuotas
	If Len(aParcelas) > 0
		nParcDed := nDscDetra / Len(aParcelas)
		nTotForm := nSalAcum - nDscDetra
	EndIf
	For nP := 1 to Len(aParcelas)
		nMonto := Round(aParcelas[nP][2] - nParcDed,2)
		nTotNeto += nMonto
		If nP == Len(aParcelas)
			If  !(nTotForm == nTotNeto)
				nMonto += (nTotForm - nTotNeto)
			Endif
		EndIf
		cXMLTPago += '<Referencia>' + cCRLF
		cXMLTPago += '    <NroLinRef>' + Alltrim(Str(nP)) + '</NroLinRef>' + cCRLF
		cXMLTPago += '    <TpoDocRef>CU</TpoDocRef>'+ cCRLF
		cXMLTPago += '    <NumeroRef>' + aParcelas[nP][1] + '</NumeroRef>'+ cCRLF
		cXMLTPago += '    <FechaRef>' + aParcelas[nP][3] + '</FechaRef>'+ cCRLF
		cXMLTPago += '    <MontosRef>'+ cCRLF
		cXMLTPago += '        <Monto>' + Alltrim(Transform(nMonto,"999999999999.99")) + '</Monto>'+ cCRLF
		cXMLTPago += '    </MontosRef>'+ cCRLF
		cXMLTPago += '</Referencia>'+ cCRLF		
	Next nP	
	
	(cTRBSE1)->(dbcloseArea())

	RestArea(aArea)
Return {cXMLTPago,nSalAcum}
