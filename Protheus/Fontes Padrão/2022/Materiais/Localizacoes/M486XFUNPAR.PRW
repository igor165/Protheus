#INCLUDE "TOTVS.CH"
#INCLUDE "MATA486.CH"
#include "xmlxfun.ch"
#include "fileio.ch"
#DEFINE BASE_DATE    "1900"
#DEFINE _BUFFER 16384
#DEFINE _SEPARADOR 		CHR(13) //09
#DEFINE _SALTO	chr(13) + chr(10)
Function M486GENCDC(cTipDoc,cRuc, cDigV,cEst,cPtoEmis,cNDoc,cTpCont,dFecEmi,cTpEmi,cCodSec,cEspecie)
	Local cRet := ""
	Local cAliasSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC|RFN|RTS',"SF2","SF1")
	Local cFUUID	:= IIf(alltrim(cEspecie) $ 'NF|NDC|RFN|RTS',"F2_UUID","F1_UUID")
	If Empty((cAliasSD)->&(cFUUID)) 
		cRet := cTipDoc 
		cRet += STRZERO(VAL(cRuc),8)
		cRet += cDigV
		cRet += STRZERO(VAL(cEst),3)
		cRet += STRZERO(VAL(cPtoEmis),3) 
		cRet += STRZERO(VAL(cNDoc),7) 
		cRet += cTpCont
		cRet += DTOS(dFecEmi)
		cRet += cTpEmi
		cRet += cCodSec
		cRet += AllTrim(STR(CalcMod11(cRet)))
		
		RecLock((cAliasSD) , .F.)
			(cAliasSD)->&(cFUUID) := cRet
		(cAliasSD)->(MsUnlock())
	Else
		cRet := (cAliasSD)->&(cFUUID)
	EndIf
		
Return cRet 
/*/{Protheus.doc} M486SecCod
Genera código de secuencia
@type
@author mayra.camargo
@since 22/08/2019
@version 1.0
@param cTime, string, Tiempo
@param dDate, date  , fecha de emision del documento
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486SecCod(cTime,dDate)
	Local cRet := ""
	Local nAux := 0 
	Local cAux := ""
	nAux := TD2JUL( CTIME, DDATE ) 
	nAux := round(round(nAux,2)+ val(STRTRAN(TIME(),":","")),0)
	cAux := STRZERO(nAux ,8) 
	cRet := cAux + AllTrim(STR(CalcMod11(cAux)))
Return cRet 

/*/{Protheus.doc} TD2JUL( CTIME, DDATE )
Convierte una fecha en fecha juliana
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cTime, string, Tiempo
@param dDate, fecha , Fecha 
@return xRet, Fecha juliana en número
@example
(examples)
@see (links_or_references)
/*/
Static Function TD2JUL( CTIME, DDATE )
	Local xRet := (DDATE - ctod( '01/01/' + BASE_DATE ) )+ ( TTOS( CTIME ) / 100000 )
return xRet

/*/{Protheus.doc} TTOS(CTIME)
(long_description)
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function TTOS( CTIME )
	Local xRet :=( val( substr( CTIME, 7, 2 ) )        ) + ;
       ( val( substr( CTIME, 4, 2 ) ) * 60   ) + ;
       ( val( substr( CTIME, 1, 2 ) ) * 3600) 
return xRet
//
/*/{Protheus.doc} M486VLDPAGOS
Genera elemento <gCamCond>
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cDocfil		, string	, codigo de Filial
@param cDocumento	, string	, número de documento
@param cSerDoc		, string	, Serie del documento
@param cCodCli		, string	, código de cliente
@param cCodLoj		, string	, código de tienda
@param cDocEsp		, string	, Especie del documento
@param cCond		, string	, Condición de Pago del documento
@param cMoeDoc		, string	, Moneda del Documento
@param nTxMoe		, numérico	, Tipo de Cambio del documento
@return cXML		, string	, XML formado.
@example
(examples)
@see (links_or_references)
/*/
Function M486CONDPAG(cDocfil, cNumDoc, cDocSer, cDocCli,cDocLoj,cDocEsp,cCond,cMoeDoc,nTxMoe )
	Local cXML	  := ""
	Local aArea   := GetArea()
	Local aCuotas := {}
	Local cTpCond := ""
	Local cCodMoe := ""	
	Local ni 	  := 0
	Local nDias	  := 0 
	
	cTpCond := POSICIONE("SE4",1,XFILIAL("SE4") + cCond, "E4_BXTITAV")	// si es tyítulo a baja automática
	If !Empty(cTpCond)	
		cXML := '        	<gCamCond>' + chr(13) + chr(10)
		cXML += '    			<iCondOpe>' + cTpCond +'</iCondOpe> ' + chr(13) + chr(10)
		cXML += '    			<dDCondOpe>' + IIF(cTpCond == "1", "Contado","Crédito") +'</dDCondOpe>' + chr(13) + chr(10)
		Do case
			case cTpCond == "1" // Contado
				// Buscar los datos del pago de Contado
				aPagos := M486GETPAG(cNumDoc, cDocSer, cDocCli,cDocLoj)
				cCodMoe :=  M486GETMOEDA(cMoeDoc)
				For nI := 1 To len(aPagos)
					cXML += '    			<gPaConEIni>'  + chr(13) + chr(10)
					cXML += '    				<iTiPago>' + AllTrim(aPagos[nI,1]) + '</iTiPago>'  + chr(13) + chr(10)
					cXML += '    				<dDesTiPag>' + alltrim(ObtColSAT("S013", aPagos[nI,1] , 1, 2, 3,80)) + '</dDesTiPag>'  + chr(13) + chr(10)
					cXML += '    				<dMonTiPag>' + ALLTRIM(TRANSFORM(aPagos[nI,2], "999999999999999.99999"))+ '</dMonTiPag> '  + chr(13) + chr(10)
					cXML += '    				<cMoneTiPag>' + cCodMoe + '</cMoneTiPag> '  + chr(13) + chr(10)
					cXML += '    				<dDMoneTiPag>'+ ObtColSAT("S004",cCodMoe , 1, 3, 4,30) + '</dDMoneTiPag> '  + chr(13) + chr(10)
					If cCodMoe <> "PYG"
						cXML += '    				<dTiCamTiPag>' + ALLTRIM(STR(nTxMoe)) + '</dTiCamTiPag>'  + chr(13) + chr(10)
					EndIf
					// Si es pago con Tarjeta
					If aPagos[nI,1] $ "3 |4 | "
						cXML += '    			<gPagTarCD>' + chr(13) + chr(10)
						cXML += '    				<iDenTarj>' 	+ aPagos[nI,3] + '</iDenTarj>' + chr(13) + chr(10)
						cXML += '    				<dDesDenTarj>' 	+ alltrim(ObtColSAT("S014", aPagos[nI,3] , 1, 1, 2,20)) + '</dDesDenTarj>' + chr(13) + chr(10)
						cXML += '    				<iForProPa>' 	+ aPagos[nI,4] + '</iForProPa>' + chr(13) + chr(10)
						cXML += '    				<dCodAuOpe>' 	+ AllTrim(aPagos[nI,5]) + '</dCodAuOpe>' + chr(13) + chr(10)
						cXML += '    				<dNumTarj>' 	+ aPagos[nI,6] + '</dNumTarj>' + chr(13) + chr(10)	
						cXML += '    			</gPagTarCD>' + chr(13) + chr(10)
					ElseIf aPagos[nI,1] $ "2 " // Si es pago con Cheque
						cXML += '    				<gPagCheq>' + chr(13) + chr(10)
						cXML += '    					<dNumCheq>' + aPagos[nI,7] + '</dNumCheq>' + chr(13) + chr(10)
						cXML += '    					<dBcoEmi>' + aPagos[nI,8] + '</dBcoEmi>' + chr(13) + chr(10)
						cXML += '    				</gPagCheq>' + chr(13) + chr(10)
					EndIf
					cXML += '    			</gPaConEIni>' + chr(13) + chr(10)
				Next nI				
			Case cTpCond == "2" // Crédito
				// Buscar las cuotas en financiero
				aCuotas := M486GETFIN( cNumdoc , cDocSer , cDocCli , cDocLoj,cDocEsp)
				// Genera nodo en XML
				cXML += '    			<gPagCred>' + chr(13) + chr(10)
				If LEN(aCuotas) > 1
					cXML += '    				<iCondCred>2</iCondCred>' + chr(13) + chr(10) // 2= Cuota
					cXML += '    				<dDCondCred>Cuota</dDCondCred>' + chr(13) + chr(10) // 2= Cuota
					cXML += '    				<dCuotas>' + alltrim(STR(LEN(aCuotas)))+ '</dCuotas>' + chr(13) + chr(10)
					
					For nI := 1 to len(aCuotas)
						cCodMoe :=  M486GETMOEDA(aCuotas[nI,8])
						cXML += '    				<gCuotas>' + chr(13) + chr(10)					
						cXML += '    					<cMoneCuo>'  + cCodMoe + '</cMoneCuo>' + chr(13) + chr(10)
						cXML += '    					<dDMoneCuo>' + ObtColSAT("S004",cCodMoe , 1, 3, 4,30)+ '</dDMoneCuo>' + chr(13) + chr(10)
						cXML += '    					<dMonCuota>' + ALLTRIM(TRANSFORM(aCuotas[nI,9],"999999999999999.9999"))+ '</dMonCuota>' + chr(13) + chr(10)
						cXML += '    					<dVencCuo>'  + STRZERO(YEAR(aCuotas[nI,10]),4) +"-" + STRZERO(MONTH(aCuotas[nI,10]),2) + "-" + STRZERO(DAY(aCuotas[nI,10]),2) + '</dVencCuo>'   + chr(13) + chr(10)
						cXML += '    				</gCuotas>' + chr(13) + chr(10)
					Next nI
				Else
					nDias := POSICIONE("SE4",1,XFILIAL("SE4") + cCond, "E4_COND")
					cXML += '    				<iCondCred>1</iCondCred>' + chr(13) + chr(10) // 1= Plazo
					cXML += '    				<dDCondCred>Plazo</dDCondCred>' + chr(13) + chr(10) // 1= Plazo
					cXML += '    				<dPlazoCre>' + AllTrim(nDias) + ' dias</dPlazoCre>' + chr(13) + chr(10)
				EndIf
				//cXML += '    				<dMonEnt>0.00</dMonEnt>' + chr(13) + chr(10)
				
				cXML += '    			</gPagCred>' + chr(13) + chr(10)
			Otherwise
				cXML += ""
		End Case
		cXML += '        	</gCamCond>' 
	EndIf
	RestArea(aArea)
	
Return cXML
/*/{Protheus.doc} m486getMoeda
Obtiene registro de las cuotas generadas en cuentas por cobrar para el documento
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cNumdoc		, string	, numero documento
@param cDocSer		, string	, serie  documento
@param cDocCli		, string	, cliente documento
@param cDocLoj		, string	, tienda  documento
@param cEsp			, string	, especie documento
@return aRet		, array		, srray con datos de cuentas por cobrar
@example
(examples)
@see (links_or_references)
/*/
Static Function M486GETFIN( cNumdoc , cDocSer , cDocCli , cDocLoj, cEsp)
	Local aRet := {}
	Local cSE1Tmp := getNextAlias()
	
	BEGINSQL ALIAS cSE1Tmp
		SELECT E1_FILIAL, E1_NUM, E1_PREFIXO, E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_MOEDA,E1_VALOR,E1_VENCREA
		FROM %Table:SE1% SE1
		WHERE SE1.E1_FILIAL = %xfilial:SE1% 
			AND SE1.E1_NUM = %EXP:cNumdoc%
			AND SE1.E1_PREFIXO =%EXP:cDocSer%
			AND SE1.E1_CLIENTE =  %EXP:cDocCli%
			AND SE1.E1_LOJA = %EXP:cDocLoj%
			AND SE1.E1_TIPO = %EXP:cEsp%
			AND SE1.%notDel%
	ENDSQL
	TCSetField(cSE1Tmp,"E1_VENCREA","D")
	count to nCount
	lRet := nCount > 0
	(cSE1Tmp)->(dbGoTop())
	
	While (!(cSE1Tmp)->(EOF()))
			aAdd(aRet, {(cSE1Tmp)->E1_FILIAL,;
						(cSE1Tmp)->E1_NUM,;
						(cSE1Tmp)->E1_PREFIXO,;
						(cSE1Tmp)->E1_PARCELA,;
						(cSE1Tmp)->E1_TIPO,;
						(cSE1Tmp)->E1_CLIENTE,;
						(cSE1Tmp)->E1_LOJA,;
						(cSE1Tmp)->E1_MOEDA,;
						(cSE1Tmp)->E1_VALOR,;
						(cSE1Tmp)->E1_VENCREA})
		(cSE1Tmp)->(DBSKIP())
	EndDo
	(cSE1Tmp)->(dbCloseArea())
Return aRet
/*/{Protheus.doc} m486getMoeda
Obtiene moneda segun catalogo de la SET
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param nMoeda		, numerico	, numero de moneda
@return cMoeda		, string	, código de moneda 
@example
(examples)
@see (links_or_references)
/*/
Static function m486getMoeda(nMoeda)
	Local cMoeda := ""
	dbSelectArea("CTO")
	CTO->(dbSetOrder(1)) // CTO_FILIAL + CTO_MOEDA
	If CTO->(MsSeek(xFilial("CTO")+Strzero(nMoeda,2)))
		cMoeda := CTO->CTO_MOESAT
	EndIf	
Return cMoeda
/*/{Protheus.doc} M486IMPDPAR
Genera nodo de Impuestos por detalle.
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cEspecie		, string	, Especie del documento
@param cDoc			, string	, número de documento
@param cSerie		, string	, Serie del documento
@param cCliente		, string	, código de cliente
@param cLoja		, string	, código de tienda
@param cMoeda		, string	, código de Moneda
@param cTpTrans		, string	, código de tipo de transacción
@param cTxMoeda		, string	, tasa de la moneda
@return cRet		, logico	, XML de 
@example
(examples)
@see (links_or_references)
/*/
Function M486IMPPAR(cEspecie,cDoc,cSerie,cCliente,cLoja, cMoeda, cTpTrans,cTxMoeda )
	Local cRet 		:= ""
	Local cQryImp 	:= getNextAlias()
	Local cCampos 	:= ""
	Local cCond 	:= ""
	Local cOrder 	:= ""
	Local cGroup 	:= ""
	Local cAliasSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"SD2","SD1")
	Local cTesD    := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_TES","D1_TES")
	Local cSerieSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_SERIE","D1_SERIE")
	Local cDocSD   := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DOC","D1_DOC")
	Local cClieSD  := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_CLIENTE","D1_FORNECE")
	Local cLojaSD  := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_LOJA","D1_LOJA")
	Local aOpeCom	:= {}
	Local nPos		:= 0

	
	cCampos	:= "% SFB.FB_CODIMP %"
	cTablas	:= "% " + RetSqlName(cAliasSD) + " "+cAliasSD+", "  + RetSqlName("SFC") + " SFC, "  + RetSqlName("SFB") + " SFB %"
	cCond	:= "% " + cAliasSD + "." + cDocSD + " = '" + cDoc + "' AND " + cAliasSD+"." + cSerieSD+" = '" + cSerie + "'"
	cCond  	+= " AND " + cAliasSD + "." + cClieSD + " = '" + cCliente + "' AND " + cAliasSD + "." + cLojaSD + " = '" + cLoja + "'"
	cCond  	+= " AND " + cAliasSD + "." + cTesD + " = SFC.FC_TES "
	cCond 	+= " AND SFC.FC_IMPOSTO = SFB.FB_CODIGO "
	cCond	+= " AND SFC.FC_FILIAL = '" + xFilial("SFC") + "'"
	cCond	+= " AND SFB.FB_FILIAL = '" + xFilial("SFB") + "'"
	cCond	+= " AND SFC.D_E_L_E_T_  = ' ' "
	cCond	+= " AND SFB.D_E_L_E_T_  = ' ' "
	cCond	+= " AND SFB.FB_CLASSE='I' "
	cCond	+= " AND "+ cAliasSD + ".D_E_L_E_T_  = ' ' %"
	cGroup 	:= "% SFB.FB_CODIMP, SFB.FB_ALIQ ,SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO,SFC.FC_INCDUPL %"
	cOrder 	:= "% SFB.FB_CODIMP,SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO,SFC.FC_INCDUPL %"
	
	BEGINSQL ALIAS cQryImp
		SELECT  SFB.FB_CODIMP, SFB.FB_ALIQ, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO, SFC.FC_INCDUPL
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
		ORDER BY %exp:cOrder%
	ENDSQL

	dbSelectArea(cQryImp)
	cRet += '			<gOpeCom>'  +  chr(13) + chr(10)
	If !Empty(cTpTrans)
		cRet += '				<iTipTra>' + cTpTrans + '</iTipTra>'  +  chr(13) + chr(10)
		cRet += '				<dDesTipTra>' +  ALLTRIM(ObtColSAT("S016",cTpTrans , 1, 2, 3,36)) + '</dDesTipTra>'  + chr(13) + chr(10)
	Endif
	If (cQryImp)->(!Eof())
		(cQryImp)->(DbGoTop())	
		While (cQryImp)->(!Eof())
			nPos := aScan(aOpeCom, { |x| x[1] == (cQryImp)->FB_CODIMP .and. x[2] == cMoeda })
			If nPos == 0
				cRet += '				<iTImp>' + (cQryImp)->FB_CODIMP + '</iTImp>'  + chr(13) + chr(10)
				cRet += '				<dDesTImp>' +  ALLTRIM(ObtColSAT("S017",(cQryImp)->FB_CODIMP , 1, 1, 2,11))  + '</dDesTImp>'  + chr(13) + chr(10)
			AADD(aOpeCom,{(cQryImp)->FB_CODIMP, cMoeda})
			EndIf 
			(cQryImp)->(DBSkip())
		EndDo
	Else
		cRet += '				<iTImp>4</iTImp>'  + chr(13) + chr(10)
		cRet += '				<dDesTImp>Ninguno</dDesTImp>'  + chr(13) + chr(10)
	EndIf
	cRet += '				<cMoneOpe>' + cMoeda + '</cMoneOpe>'  + chr(13) + chr(10)
	cRet += '				<dDesMoneOpe>' + ALLTRIM(ObtColSAT("S004",cMoeda , 1, 3, 4,30)) + '</dDesMoneOpe>'  + chr(13) + chr(10)
	If cMoeda <> "PYG"
		cRet += '				<dCondTiCam>1</dCondTiCam>'  + chr(13) + chr(10) // Global
		cRet += '				<dTiCam>' + alltrim(STR(cTxMoeda)) + '</dTiCam>'  + chr(13) + chr(10)
	EndIf
	cRet += '			</gOpeCom>'
	(cQryImp)->(DBCloseArea())
Return cRet 
/*/{Protheus.doc} M486IMPDPAR
Genera nodo de Impuestos por detalle.
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cEspecie		, string	, Especie del documento
@param cDoc			, string	, número de documento
@param cSerie		, string	, Serie del documento
@param cCliente		, string	, código de cliente
@param cLoja		, string	, código de tienda
@param cTES			, string	, código de TES
@param cItem		, string	, código de item
@param cProd		, string	, código de producto
@return cXML		, logico	, T si la validación está ok, false si no cumple validación
@example
(examples)
@see (links_or_references)
/*/
Function M486IMPDPAR(cEspecie,cDoc,cSerie,cCliente,cLoja, cTES, cItem, cProd, aDesc, aTotales)
	Local cRet 		:= ""
	Local aArea		:= getArea()
	Local cQryImp 	:= getNextAlias()
	Local cCampos 	:= ""
	Local cCond 	:= ""
	Local cOrder 	:= ""
	Local cGroup 	:= ""
	Local cAliasSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"SD2","SD1")
	Local cTesD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_TES","D1_TES")
	Local cSerieSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_SERIE","D1_SERIE")
	Local cDocSD  	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DOC","D1_DOC")
	Local cClieSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_CLIENTE","D1_FORNECE")
	Local cLojaSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_LOJA","D1_LOJA")
	Local cCantSD  := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_QUANT","D1_QUANT")
	Local cTotalSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_TOTAL","D1_TOTAL")
	Local cPreVtaSD	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_PRCVEN","D1_VUNIT")
	Local cBasimpSD	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_BASIMP","D1_BASIMP")
	Local cValimpSD	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_VALIMP","D1_VALIMP")
	Local cDescSD  := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DESCON","D1_VALDESC")
	Local cDescPor	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DESC","D1_DESC")
	Local cCodProSD	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_COD","D1_COD")
	Local cItmProSD	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_ITEM","D1_ITEM")
	Local cPict		:= "99999999999999.9999999"
	Local nTotItem	:= 0
	Local nTotImp	:= 0
	Local aImposto	:= {}
	Local nPrvUnit	:= 0
	Local nValimpSD	:= 0
	Local nBasimpSD	:= 0	
	Local nI := 0
	Local cRet2 := ""
	Local nDescItem	:= 0
	Local nPorcDesc	:= 0
	Local nTotOpIt	:= 0
	Local nBasGravI	:= 0
	Local nLiqIVA	:= 0
	Local aAuxImp	:= {}
	Local nFactor	:= 0
		
	cCampos	:= "% SFB.FB_CODIMP, SFB.FB_ALIQ, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO, SFC.FC_INCDUPL    %"
	cTablas	:= "% " + RetSqlName(cAliasSD) + " "+cAliasSD+", "  + RetSqlName("SFC") + " SFC, "  + RetSqlName("SFB") + " SFB %"
	cCond	:= "% " + cAliasSD + "." + cDocSD + " = '" + cDoc + "' AND " + cAliasSD+"." + cSerieSD+" = '" + cSerie + "'"
	cCond  	+= " AND " + cAliasSD + "." + cClieSD + " = '" + cCliente + "' AND " + cAliasSD + "." + cLojaSD + " = '" + cLoja + "'"
	cCond  	+= " AND " + cAliasSD + "." + cTesD + " = SFC.FC_TES "
	cCond 	+= " AND " + cAliasSD + "." + cItmProSD + " = '" + cItem+ "' " 
	cCond 	+= " AND " + cAliasSD + "." + cCodProSD + " = '" + cProd+ "' "
	cCond 	+= " AND SFC.FC_IMPOSTO = SFB.FB_CODIGO "
	cCond	+= " AND SFC.FC_FILIAL = '" + xFilial("SFC") + "'"
	cCond	+= " AND SFB.FB_FILIAL = '" + xFilial("SFB") + "'"
	cCond	+= " AND SFC.D_E_L_E_T_  = ' ' "
	cCond	+= " AND SFB.D_E_L_E_T_  = ' ' "
	cCond	+= " AND "+ cAliasSD + ".D_E_L_E_T_  = ' ' "
	cCond	+= " AND SFB.FB_CLASSE='I' %"
	
	cGroup 	:= "% SFB.FB_CODIMP, SFB.FB_ALIQ ,SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO,SFC.FC_INCDUPL %"
	cOrder 	:= "% SFB.FB_CODIMP,SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO,SFC.FC_INCDUPL %"
	
	BEGINSQL ALIAS cQryImp
		SELECT  SFB.FB_CODIMP, SFB.FB_ALIQ, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO, SFC.FC_INCDUPL
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
		ORDER BY %exp:cOrder%
	ENDSQL

	dbSelectArea(cQryImp)
	(cQryImp)->(DbGoTop())
		
	While (cQryImp)->(!Eof())
		If (cQryImp)->FB_CODIMP == "1"		
 			cValimpSD := cValimpSD + (cQryImp)->FB_CPOLVRO
 			cBasimpSD := cBasimpSD + (cQryImp)->FB_CPOLVRO
 			nValimpSD := (cAliasSD)->&(cValimpSD)
 			nBasimpSD := (cAliasSD)->&(cBasimpSD)
 			aAdd(aAuxImp,{(cQryImp)->FB_ALIQ,nBasimpSD,nValimpSD})
 			cRet2 += '				<gCamIVA>'  +  chr(13) + chr(10)
			cRet2 += '    				<iAfecIVA>1</iAfecIVA>' +  chr(13) + chr(10)
			cRet2 += '    				<dDesAfecIVA>Gravado IVA</dDesAfecIVA>' +  chr(13) + chr(10)
			cRet2 += '    				<dPropIVA>100</dPropIVA>'  +  chr(13) + chr(10)
			cRet2 += '    				<dTasaIVA>' + alltrim(TRANSFORM((cQryImp)->FB_ALIQ,"999")) + '</dTasaIVA>'  +  chr(13) + chr(10)           // Alícuota
			cRet2 += '    				<dBasGravIVA>' + alltrim(TRANSFORM(nBasimpSD,cPict)) + '</dBasGravIVA>'  +  chr(13) + chr(10)// Base del impuesto 
			cRet2 += '    				<dLiqIVAItem>' + alltrim(TRANSFORM(nValimpSD,cPict)) + '</dLiqIVAItem>' +  chr(13) + chr(10)  // Valor del impuesto
			cRet2 += '				</gCamIVA>' 
 		EndIf	
 		If (cQryImp)->FC_INCDUPL <> "3"
			nPrvUnit := (cAliasSD)->&(cPreVtaSD)+ (nValimpSD/(cAliasSD)->&(cCantSD))
		Else
			nPrvUnit := (cAliasSD)->&(cPreVtaSD)
		EndIf
		(cQryImp)->(DbSkip())
	EndDo
	(cQryImp)->(DBCloseArea())
	
	If nPrvUnit == 0
		nPrvUnit := (cAliasSD)->&(cPreVtaSD)
	EndIf
	
	
	nFactor		:= nPrvUnit/(cAliasSD)->&(cPreVtaSD) //*
	nDescItem	:= Iif((cAliasSD)->&(cDescSD)> 0,((cAliasSD)->&(cDescSD)/(cAliasSD)->&(cCantSD))* nFactor,0) //*
	nPrvUnit 	+= nDescItem  
	nPorcDesc	:= Iif(nDescItem>0,(nDescItem*100)/nPrvUnit,0)
	nTotItem	:= nPrvUnit * (cAliasSD)->&(cCantSD)
	nTotOpIt	:= (nPrvUnit-nDescItem)*(cAliasSD)->&(cCantSD)
	
	If Empty(cRet2)
		cRet2 += '				<gCamIVA>'  +  chr(13) + chr(10)
		cRet2 += '    				<iAfecIVA>3</iAfecIVA>' +  chr(13) + chr(10)
		cRet2 += '    				<dDesAfecIVA>Exento</dDesAfecIVA>' +  chr(13) + chr(10)
		cRet2 += '    				<dPropIVA>0</dPropIVA>'  +  chr(13) + chr(10)
		cRet2 += '    				<dTasaIVA>0</dTasaIVA>'  +  chr(13) + chr(10)           // Alícuota
		cRet2 += '    				<dBasGravIVA>0</dBasGravIVA>'  +  chr(13) + chr(10)// Base del impuesto 
		cRet2 += '    				<dLiqIVAItem>0</dLiqIVAItem>' +  chr(13) + chr(10)  // Valor del impuesto
		cRet2 += '				</gCamIVA>'
		aTotales[1] += nTotOpIt
		aTotales[5] += nTotOpIt
	EndIf

	
	cRet += '    			<gValorItem>' +  chr(13) + chr(10)
	cRet += '    				<dPUniProSer>' + alltrim(TRANSFORM(nPrvUnit,cPict)) + '</dPUniProSer>'  +  chr(13) + chr(10)
	cRet += '    				<dTotBruOpeItem>'	+ alltrim(TRANSFORM(nTotItem,cPict)) + '</dTotBruOpeItem>'  +  chr(13) + chr(10)
	cRet += '    				<gValorRestaItem>'	+  chr(13) + chr(10) 
	cRet += '    					<dDescItem>' + alltrim(Transform(nDescItem,cPict)) + '</dDescItem>'	+  chr(13) + chr(10)
	//cRet += '    					<dDescItem>' + alltrim(Transform((cAliasSD)->&(cDescSD) * nFactor,cPict)) + '</dDescItem>'	+  chr(13) + chr(10)
	If (cAliasSD)->&(cDescSD) > 0
		cRet += '    					<dPorcDesIt>' + alltrim(Transform(nPorcDesc,"999.99999999")) + '</dPorcDesIt>'	+  chr(13) + chr(10)
		//cRet += '    					<dPorcDesIt>' + alltrim(Transform((cAliasSD)->&(cDescPor),"999.99999999")) + '</dPorcDesIt>'	+  chr(13) + chr(10)
	EndIf 
	cRet += '    					<dTotOpeItem>' + alltrim(Transform(nTotOpIt,cPict)) + '</dTotOpeItem>'	+  chr(13) + chr(10)
	//cRet += '    					<dTotOpeItem>' + alltrim(Transform(nTotItem,cPict)) + '</dTotOpeItem>'	+  chr(13) + chr(10)
	cRet += '    				</gValorRestaItem>'	+  chr(13) + chr(10) 
	cRet += '    			</gValorItem>' +  chr(13) + chr(10)
	cRet += cRet2
	
	aDesc[1] += nDescItem * (cAliasSD)->&(cCantSD)
	aDesc[2] += nPorcDesc	
	    
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} M486SUBTOT
Genera nodo de subtotales.
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cEspecie		, string	, Especie del documento
@param cDocumento	, string	, número de documento
@param cSerDoc		, string	, Serie del documento
@param cCodCli		, string	, código de cliente
@param cCodLoj		, string	, código de tienda
@return cXML		, logico	, T si la validación está ok, false si no cumple validación
@example
(examples)
@see (links_or_references)
/*/
Function  M486SUBTOT(cEspecie,cDoc,cSerie,cCliente,cLoja)
	Local aImposto	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local aArea		:= getArea()
	Local cQryImp 	:= getNextAlias()
	Local cCampos 	:= ""
	Local cCond 	:= ""
	Local cOrder 	:= ""
	Local cAliasSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"SD2","SD1")
	Local cTesD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_TES","D1_TES")
	Local cSerieSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_SERIE","D1_SERIE")
	Local cDocSD  	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DOC","D1_DOC")
	Local cClieSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_CLIENTE","D1_FORNECE")
	Local cLojaSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_LOJA","D1_LOJA")
	Local cBasimpSD	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_BASIMP","D1_BASIMP")
	Local cValimpSD	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_VALIMP","D1_VALIMP")	
	Local nPos2 := 0
	Local nPos 	 := 0
	Local nPos1		:= 0
	Local nAux:=0
	Local lImpTes:=ImpTES(cTESD,cClieSD,cEspecie,cDoc,cSerie,cCliente,cLoja)	
	Local cAux:=''
	cCampos	:= "% SFB.FB_CODIMP, SFB.FB_ALIQ, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO, SFC.FC_INCDUPL, " + cAliasSD+ ".*    %"
	cTablas	:= "% " + RetSqlName(cAliasSD)  +" "+cAliasSD+ " %" 
	cCond	:= "% " + cAliasSD + "." + cDocSD + " = '" + cDoc + "' AND " + cAliasSD+"." + cSerieSD+" = '" + cSerie + "'"
	cCond  	+= " AND " + cAliasSD + "." + cClieSD + " = '" + cCliente + "' AND " + cAliasSD + "." + cLojaSD + " = '" + cLoja + "'"
	If lImpTes
		cCond  	+= " AND " + cAliasSD + "." + cTesD + " = SFC.FC_TES "
		cCond 	+= " AND SFC.FC_IMPOSTO = SFB.FB_CODIGO "
		cCond	+= " AND SFC.FC_FILIAL = '" + xFilial("SFC") + "'"
		cCond	+= " AND SFB.FB_FILIAL = '" + xFilial("SFB") + "'"
		cCond	+= " AND SFC.D_E_L_E_T_  = ' ' "
		cCond	+= " AND SFB.D_E_L_E_T_  = ' ' "
		cCond	+= " AND SFB.FB_CLASSE='I' AND FB_CODIMP = '1'" // pOR EL MOMENTO SOLO SACAMOS iva
	ENDIF
	cCond	+= " AND "+ cAliasSD + ".D_E_L_E_T_  = ' ' %"
	cOrder 	:= "% SFB.FB_CODIMP,SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO,SFC.FC_INCDUPL %"
	cAux:='%'+cAliasSD+"."+cTESD+'%'
	BEGINSQL ALIAS cQryImp
		SELECT  %exp:cCampos%
		FROM  %exp:cTablas%
		LEFT JOIN %Table:SFC% SFC  ON SFC.FC_TES =%exp:cAux%
		LEFT JOIN %Table:SFB% SFB  ON SFB.FB_CODIGO = SFC.FC_IMPOSTO
		WHERE %exp:cCond%
		ORDER BY %exp:cOrder%
	ENDSQL

	dbSelectArea(cQryImp)
	(cQryImp)->(DbGoTop())		
	While (cQryImp)->(!Eof())
		
		/*
		1. Total Op Exentas
		2. Total exoneraciones
		3. Subtotal iva al 5%
		4. subtotal IVA la 10%
		5. Total suma de ivas
		6. Total descuentos globales
		7. total líquido iva 5
		8. total Líquido iva 10
		9. total de iva
		10. total base gravada iva al 5
		11. Total base IVA gravada al 10
		12. Total base iba gravada		
		*/
		If (cQryImp)->FB_ALIQ == 10
			nPos 	:= 4
			nPos1 	:= 8
			nPos2 	:= 11
		ElseIf (cQryImp)->FB_ALIQ == 5
			nPos 	:= 3
			npos1 	:= 7
			nPos2	:= 10
		EndIf
		
		IF !Empty((cQryImp)->FB_CPOLVRO) .AND.  lImpTes
			aImposto[nPos]	+= (cQryImp)-> &(cBasimpSD +(cQryImp)->FB_CPOLVRO) + (cQryImp)-> &(cValimpSD +(cQryImp)->FB_CPOLVRO)
			aImposto[nPos1] += (cQryImp)-> &(cValimpSD +(cQryImp)->FB_CPOLVRO)
			aImposto[nPos2]	+= (cQryImp)-> &(cBasimpSD +(cQryImp)->FB_CPOLVRO)
		ELSE
			nAux+=(cQryImp)->(&(STRTRAN(cAliasSD, "S", "")+"_TOTAL"))
		ENDIF
		
		(cQryImp)->(DbSkip())
	EndDo
	(cQryImp)->(DBCloseArea())
	RestArea(aArea)
	
	aImposto[1] 	:= nAux
	aImposto[5] 	:= aImposto[3] + aImposto[4]+nAux
	aImposto[9] 	:= aImposto[7] + aImposto[8]
	aImposto[12]	:= aImposto[10] + aImposto[11]
	
Return aImposto


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³   M486ASOC  ³ Autor ³ Verónica Flores      ³ Data ³ 08.08.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Documento Asociados para XML de acuerdo ³±±
±±³          ³ a la estructura del SET (PARAGUAY)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486ASOC(cEspecie,cDoc,cSerie,cCli,cLoja,cTipAso)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEspecie .-  Especie del documento (NF,NDC o NCC)            ³±±
±±³          ³ cDoc .- Numero de documento.                                 ³±±
±±³          ³ cSerie .- Serie del Documento.                               ³±±
±±³          ³ cCli .- Codigo del cliente.                                  ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ cTipAso .- Tipo de asociación del documento. (1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLRef .- Nodo de referencia para XML de estandar UBL 2.0   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486ASOC(cEspecie,cDoc,cSerie,cCli,cLoja,cTipAso,lXML)
	Local cAliasRef  := getNextAlias()
	Local cCampos := ""
	Local cTablas := ""
	Local cGroup := ""
	Local aReferen := {}
	Local cTpDoc := ""
	Local cTpDocA1 := ""
	Local cSerie2 := ""
	Local cEspe := ""
	Local cNFOri  := ""
	Local cSeriOri := ""
	Local nX     := 0
	Local cXMLRef := ""
	Local cCRLF	 := (chr(13)+chr(10))
	Local aArea := GetArea()
	Local aAreaF2 := SF2->(GetArea())
	Local cCond	:= ""
	Local cCDC	:= ""
	Local cNumTim :=""
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA

	If SA1->(dbSeek(xFilial("SA1") + cCli + cLoja))
		cTpDocA1 := SA1->A1_TIPDOC
	EndIf

	IF alltrim(cEspecie) $ 'NF|NDC'
		cCampos  := "% SD2.D2_SERIORI, SD2.D2_NFORI %"
		cTablas  := "% " + RetSqlName("SD2") + " SD2, "  + RetSqlName("SF2") + " SF2 %"
		cCond    := "% SD2.D2_DOC = '" + cDoc + "'"
		cCond    += " AND SD2.D2_SERIE = '" + cSerie + "'"
		cCond    += " AND SD2.D2_CLIENTE = '" + cCli + "'"
		cCond    += " AND SD2.D2_LOJA = '" + cLoja + "'"
        cCond	 += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cCond	 += " AND SD2.D_E_L_E_T_  = ' ' %"
		cGroup := "% SD2.D2_SERIORI, SD2.D2_NFORI %"

	Else
		cCampos  := "% SD1.D1_SERIORI, SD1.D1_NFORI %"
		cTablas  := "% " + RetSqlName("SD1") + " SD1 %"
		cCond    := "% SD1.D1_DOC = '" + cDoc + "'"
		cCond    += " AND SD1.D1_SERIE = '" + cSerie + "'"
		cCond    += " AND SD1.D1_FORNECE = '" + cCli + "'"
		cCond    += " AND SD1.D1_LOJA = '" + cLoja + "'"
	    cCond	 += " AND SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
		cCond	 += " AND SD1.D_E_L_E_T_  = ' ' %"
		cGroup := "% SD1.D1_SERIORI, SD1.D1_NFORI %"
	EndIf

	BeginSql alias cAliasRef
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
	EndSql

	dbSelectArea(cAliasRef)

	(cAliasRef)->(DbGoTop())

	While (cAliasRef )->(!Eof())
		dbSelectArea("SF2")
		//SF2->(SetFilter("",1))
		SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(DbGoTop())
		cNFOri := IIf(alltrim(cEspecie) $ 'NF|NDC',(cAliasRef)->D2_NFORI, (cAliasRef)->D1_NFORI)
		cSeriOri := IIf(alltrim(cEspecie) $ 'NF|NDC',(cAliasRef)->D2_SERIORI, (cAliasRef)->D1_SERIORI)
		If SF2->(dbSeek(xFilial("SF2")+ cNfori + cSeriori + cCli + cLoja))
			cSerie2 := SF2->F2_SERIE2
			cEspe := alltrim(SF2->F2_ESPECIE)
			cCDC  := SF2->F2_UUID
			cNumTim := SF2->F2_NUMTIM
		ElseIf !GetDocOri(cNfori, cSeriori, cCli, cLoja, @cSerie2, @cEspe, @cCDC, @cNumTim)
			If alltrim(cEspecie) $ "NDC"
				SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
				IF SFP->(DBSEEK(XFILIAL("SFP")+xFilial("SF2")+cSeriori+'1'))
					cSerie2:= SFP->FP_SERIE2
				ELSE
					cSerie2:= ''
				ENDIF
				cEspe := "NF"
			Else
				cSerie2 := ""
				cEspe := ""
			EndIf
		EndIf

		If cEspe $ 'NF' .AND. Substr(cSerie2,1,1) $ 'F'  // Factura
			cTpDoc := '01'
		ElseIf cEspe $ 'NF' .AND. Substr(cSerie2,1,1) $ 'B' .AND. cTpDocA1 <> "06"  // Boleta de Venta
			cTpDoc := '03'
		EndIf
		aAdd(aReferen,{RTRIM(cSerie2),RTRIM(cNFOri),cTpDoc,cNumTim,cCDC})
		(cAliasRef)->(dbskip())
	EndDo
	//Referencia
	IF lXML
		For nX := 1 To Len(aReferen)
			cXMLRef += '			<iTipDocAso>'+ cTipAso +'</iTipDocAso>' + cCRLF
			cXMLRef += '			<dDesTipDocAso>Electrónico</dDesTipDocAso>' + cCRLF
			cXMLRef += '			<dCdCDERef>' + aReferen[nX][5] + '</dCdCDERef>' + cCRLF
		Next nX
	ENDIF
    RestArea(aArea)
    RestArea(aAreaF2)
Return IIF(lXML, cXMLRef,aReferen)
 /*/{Protheus.doc} M486GETPAG
Valida DETALLE DE productos e impuestos por TES de item de una factura de venta 
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cDocumento	, string	, número de documento
@param cSerDoc		, string	, Serie del documento
@param cCodCli		, string	, código de cliente
@param cCodLoj		, string	, código de tienda
@param cCond		, string	, codigo condición de Pago
@param nTipdoc		, numérico	, 0 entrada 1 salida
@param nTipdoc		, numérico	, 0 entrada 1 salida
@return aRet		, array		, T si la validación está ok, false si no cumple validación
/*/
Static Function M486GETPAG(cNumDoc, cDocSer, cDocCli,cDocLoj)
 	Local aRet := {}
 	Local aArea := getArea() 	
 	DbSelectArea("F7L")
 	F7L->(DbSetOrder(1)) // F7L_FILIAL+F7L_DOC+F7L_SERIE+F7L_CLIENT+F7L_LOJA                       	
 	If F7L->(dbSeek(xFilial("F7L") + cNumDoc + cDocSer + cDocCli + cDocLoj ))
 		While !( F7L->(eof())) .AND. F7L->( F7L_FILIAL+F7L_DOC+F7L_SERIE+F7L_CLIENT+F7L_LOJA ) == xFilial("F7L") + cNumDoc + cDocSer + cDocCli + cDocLoj
 			aAdd(aRet,{F7L->F7L_TPPAGO,;
 				 F7L->F7L_MONTO ,;
 				 F7L->F7L_TPTAR ,;
 				 F7L->F7L_FRMPRO,;
 				 F7L->F7L_CODOPE,;
 				 F7L->F7L_NUMTRJ,;
 				 "",; //F7L->F7L_NUMCQH
 				 POSICIONE("SA6",1, XFILIAL("SA6") + F7L->F7L_CODBCO, "A6_NOME") })
 			F7L->(dbskip())	 
 		EndDo
 	EndIf
 	F7L->(dbcloseArea())
 	RestArea(aArea) 	
Return aRet
 /*/{Protheus.doc} M486VLDPAR
Valida DETALLE DE productos e impuestos por TES de item de una factura de venta 
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cCodCli		, string	, código de cliente
@param cCodLoj		, string	, código de tienda
@param cDocumento	, string	, número de documento
@param cSerDoc		, string	, Serie del documento
@param aError		, array		, array donde se almacenan los errores de los documentos
@param nTipdoc		, numérico	, 0 entrada 1 salida
@param nTipdoc		, numérico	, 0 entrada 1 salida
@return lRet		, logico	, T si la validación está ok, false si no cumple validación
@example
(examples)
@see (links_or_references)
/*/
 Function M486VLDPAR(cCodCli, cCodLoj,cDocumento,cSerDoc,aError,nTipoDoc)
	Local aArea	:= getArea()
	Local nPos 	:= 0
	Local aTES 	:= {}
	Local cUM	:= ""
	Local lRet 	:= .T.
	Local nI	:= 0
	Local cMsg	:= ""
	
	If nTipodoc == 0 // SD1
		DBSELECTAREA("SD1")
		SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_CLIENTE+D1_LOJA 		
		If SD1->(dbSeek(xfilial("SD1")+cDocumento+cSerDoc + cCodCli+cCodLoj, .T.)) //
			While SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == xfilial("SD1")+cDocumento+cSerDoc + cCodCli+cCodLoj  //			
				If len(aTES) > 0
					nPos := aScan(aTES, { |x| x == SD1->D1_TES  })
					If nPos == 0
						aAdd(aTES,SD1->D1_TES)
					EndIf
				Else
					aAdd(aTES,SD1->D1_TES)
				EndIF
				dbSelectArea("SB1")
				SB1->(dbGoTop())
				SB1->(dbsetorder(1)) // B1_FILIAL+B1_COD
				If SB1->(Dbseek(xFilial("SB1")+SD1->D1_COD))
					If Empty(SB1->B1_UM)
						aadd(aError ,{cSerDoc,cDocumento, STR0141 + SB1->B1_COD + "-" + STR0142 + SD1->D1_ITEM + STR0143}) // "Producto" "ITEM" "Sin Unidad de Medida(B1_UM)"
						lRet := .F.  
					Else
						cUM:= POSICIONE("SAH",1,xFilial("SAH") + SB1->B1_UM,"AH_COD_CO")
						If Empty(cUM)
							aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD2->D2_ITEM + STRTRAN(STR0144,"UNECE", "SET")}) // "Producto" "ITEM""Sin Unidad de Medida UNECE (AH_COD_CO)"
							lRet := .F.  
						Else
							lRet := ValidF3I("S002", cUM,1,3)
							If !lRet
								aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD2->D2_ITEM + STRTRAN(STR0144,"UNECE", "SET")}) // "Producto" "ITEM""Sin Unidad de Medida UNECE (AH_COD_CO)"								
							EndIf
						EndIf	
					EndIf				
				Else
					aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0140 + SB1->B1_COD}) // "Producto sin registro Código: "
					lRet := .F. 
				EndIF			
				SD1->(dbSkip())
			EndDo
		EndIf
	Else // SD2
		DBSELECTAREA("SD2")
		SD2->(dbSetOrder(3)) //  D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ITEM
		If SD2->(dbSeek(xfilial("SD2")+cDocumento+cSerDoc + cCodCli+cCodLoj,.F.)) 
			While SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == xfilial("SD2")+cDocumento+cSerDoc + cCodCli+cCodLoj  //
				If len(aTES) > 0
					nPos := aScan(aTES, { |x| x == SD2->D2_TES  })
					If nPos == 0
						aAdd(aTES,SD2->D2_TES)
					EndIf
				Else
					aAdd(aTES,SD2->D2_TES)
				EndIF
				dbSelectArea("SB1")
				SB1->(dbGoTop())
				SB1->(dbsetorder(1)) // B1_FILIAL + B1_COD
				If SB1->(Dbseek(xFilial("SB1")+SD2->D2_COD))
					If Empty(SB1->B1_UM)
						aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD2->D2_ITEM + STR0143}) // "Producto" "ITEM" "Sin Unidad de Medida(B1_UM)"
						lRet := .F.  
					Else
						cUM:= POSICIONE("SAH",1,xFilial("SAH") + SB1->B1_UM,"AH_COD_CO")
						If Empty(cUM)
							aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD2->D2_ITEM + STRTRAN(STR0144,"UNECE", "SET")}) // "Producto" "ITEM""Sin Unidad de Medida UNECE (AH_COD_CO)"
							lRet := .F.  
						Else
							lRet := ValidF3I("S002", cUM,1,3)
							If !lRet
								aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD2->D2_ITEM + STRTRAN(STR0144,"UNECE", "SET")}) // "Producto" "ITEM""Sin Unidad de Medida UNECE (AH_COD_CO)"								
							EndIf
						EndIf	
					EndIf				
				Else
					aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0140 + SB1->B1_COD}) // "Producto sin registro Código: "
					lRet := .F. 
				EndIF			
				SD2->(dbSkip())
			EndDo
		EndIf
	EndIf

	// Procesamiento de TES	
	If len(aTES) > 0
		dbSelectArea("SFC")
		SFC->(dbSetOrder(1)) //FC_FILIAL+FC_TES+FC_SEQ+FC_IMPOSTO
		
		For nI := 1  to len(aTES)
			If SFC->(dbSeek(xFilial("SFC") + aTES[nI]))	
				dbSelectArea("SFB")
				SFB->(dbSetOrder(1)) // FB_FILIAL + FB_COD
				If SFB->(dbSeek(xfilial("SFB")+SFC->FC_IMPOSTO))
					If SFB->FB_CLASSE == "I"
						If Empty(SFB->FB_CODIMP)
							aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STRTRAN(STR0259,"#IMP#",SFC->FC_IMPOSTO) + SFB->FB_CODIMP}) // "Impuesto #IMP# sin Código (FB_CODIMP): "							
						Else
							lRet := ValidF3I("S017", SFB->FB_CODIMP,1,1)
							If !lRet
								cMsg := STRTRAN(STR0241,"#CAMPO#","(FB_CODIMP)")
 								cMsg := STRTRAN(STR0241,"#TABLA#","S017")
 								cMsg := STRTRAN(STR0241,"#CCOD#", SFB->FB_CODIMP)
								aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, cMsg}) // "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf		
		Next nI						
	EndIf
	RestArea(aArea)
Return lRet
/*/{Protheus.doc} M486VLDPAGOS
Valida que se hayan realizado los pagos a una factura de venta de pago de contado
@type
@author mayra.camargo
@since 21/08/2019
@version 1.0
@param cCodCli		, string	, código de cliente
@param cCodLoj		, string	, código de tienda
@param cDocumento	, string	, número de documento
@param cSerDoc		, string	, Serie del documento
@param aError		, array		, array donde se almacenan los errores de los documentos
@param nTipdoc		, numérico	, 0 entrada 1 salida
@param nTipdoc		, numérico	, 0 entrada 1 salida
@return lRet		, logico	, T si la validación está ok, false si no cumple validación
@example
(examples)
@see (links_or_references)
/*/
Function M486VLDPAGOS(cCodCli, cCodLoj,cDocumento,cSerDoc,aError,nTipoDoc, nTotFact)
	Local lRet := .T.
	Local nTotal := 0
	dbSelectArea("F7L")
	F7L->(dbSetOrder(1)) // F7L_FILIAL+F7L_DOC+F7L_SERIE+F7L_CLIENT+F7L_LOJA   	
	If F7L->(dbSeek(xfilial("F7L")+cDocumento+cSerdoc+cCodCli+cCodLoj))
		While F7L-> F7L_FILIAL+F7L_DOC+F7L_SERIE+F7L_CLIENT+F7L_LOJA == xfilial("F7L")+cDocumento+cSerdoc+cCodCli+cCodLoj 
			nTotal += F7L->F7L_MONTO		
			F7L->(dbSkip())
		EndDo
		If nTotal <> nTotFact
			aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0261 }) // "El monto total de la factura, difiere del total pagado"
		EndIF	
	Else
		// Se escribe error en log de errores
		aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0260 }) // "El documento no tiene Pagos registrados."
	EndIf
	F7L->(dbCloseArea())
Return lRet


/*/{Protheus.doc} ValidCat
Valida si un registro  para una tabla dada existe en el catálogo registrado
en f3i y f3h
@type
@author mayra.camargo
@since 24/10/2018
@version 1.0
@param cCodigo	, caracter, Código de la Tabla
@param cConteudo, caracter, Cadena a buscar
@param nPos1, numérico, Posición de inicio de búsqueda
@param nPos2, numérico, Posición de fin de búsqueda
@return lRet, verdadero si encuentra el registro, falso si no lo encuentra
@example
lRet := ValidCat("S006", SA1->A1_TIPDOC,1,1) 
@see (links_or_references)
/*/
Function VldCatPar(cCodigo,cConteudo,nPos1,nPos2)
	Local lRet := .F.
	Local cTRB := ""
	Local cQry := ""

	Default nPos1 := 0
	Default nPos2 := 0
	
	If cCodigo <> Nil .And. cConteudo <> Nil
		
		If Select("TRBF3I")>0
			TRBF3I->(dbCloseArea())
		EndIf
		
		cQry := " SELECT F3I_CODIGO,F3I_SEQUEN,F3I_CONTEU "
		cQry += " FROM " + RetsqlName("F3I") + " F3I "
		cQry += " WHERE F3I_FILIAL = '" + xFilial("F3I") + "' "
		cQry += " AND F3I_CODIGO = '" + cCodigo + "' "
		cQry +=" AND F3I.D_E_L_E_T_='' "
		
		cTRB := ChangeQuery(cQry)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRB ) ,"TRBF3I", .T., .F.)
		
		dbSelectArea( "TRBF3I" )
		TRBF3I->(dbGoTop())	
		
		While TRBF3I->(!Eof())
			If Alltrim(Substr(TRBF3I->F3I_CONTEUDO,nPos1,nPos2)) == Alltrim(cConteudo)
				lRet := .T.
				Exit
			EndIf
			TRBF3I->(dBSkip())
		EndDo
	EndIf

Return(lRet)

/*/{Protheus.doc} M486FPAREN
Realiza la transmisión de documentos para Paraguay al SIFEN por medio web services
@author raul.medina
@param aDocs, array, Contenido de los documentos a transmitir
@param cTipo, caracter, T- Transmisión, CA - Cancelación
@param aError, array, Arreglo usado para guardar los errores
@param aTrans, array, Arreglo usado para guardar las transmisiones
@return lRet
/*/
Function M486FPAREN(aDocs, cTipo, aError, aTrans)
Local lRet	:= .T.
Local cMsg		:= ""
Local nI 		:= 0
Local cNomArc	:= ""
Local lProc		:= .T.
Local cStatus	:= "5"
Local cLote:= ""
Local nMaxLote:= SuperGetMV("MV_ASYNLOT",,50)//limite acutal de 50(SIFEN)
Local nCuentaLote:=1
Local aLotes:={}
Local cXMLLote:=""
Local aDocPorLote:={}

Local cAmbiente:=""  
Local cRutaSMR	:="" 
Local cSIFEEXE :="" 
Local cPathDocSave:="" 
Local cCertificado:="" 
Local cPassCert:="" 
Local cIDENV:=""
Local cIDPASCLI:=""
Local cPASCLI	:="" 
Local cTIPTRAN :="" 
Local cPathExe:=""
Local cPath 	:= &(SuperGetMV("MV_CFDDOCS",,""))  //Documentos
Local lSeguir:=.T.
Local nTotEnv:=nEnvio:=0
Local cMainLote:=""
Default cTipo  := "" 
Default aDocs  := {} 
Default aError  := {} 
Default aTrans  := {} 

lProc:=getParamExe(@cAmbiente,@cRutaSMR,@cSIFEEXE,@cPathDocSave,@cCertificado,@cPassCert,@cIDENV,@cIDPASCLI,@cPASCLI,@cTIPTRAN,@cPathExe,@cMainLote)
lSeguir:= VLDCAMPASY(cTIPTRAN,cPathDocSave, cMainLote)
	If lProc .AND. lSeguir
		IF cTIPTRAN=="A" // tipo de transmisión(A=asincrona,S=sincrona) PAR
			cLote:=ULTNDOC("AQ2","AQ2_NUMLOT")
			
			IF NEWFOLDER(cRUTASMR,cLote) // se crea folder del lote consecutivo en samartclient

				IF NEWFOLDER(cPathDocSave+"\"+cMainLote+"\",cLote) // Se crea folder del lote consecutivo en el appaserver
					
					Aadd(aLotes,cLote)
			
				ENDIF	
			ENDIF			
			
		ENDIF
		nTotEnv:=  Len(aDocs)
		ProcRegua(nTotEnv)
		For nI := 1 To nTotEnv
			
			cNomArc := AllTrim(aDocs[nI][1]) + AllTrim(aDocs[nI][2]) + AllTrim(aDocs[nI][10])
			lProc := IIf(cTipo == "T", File(cPathDocSave + cNomArc + '.xml'), .T.) 

			If lProc
				If cTipo == "T" 

					IF cTIPTRAN=="A" // tipo de transmisión(A=asincrona) PAR
						
						IF nCuentaLote>nMaxLote
							cLote:=Soma1(cLote)
							IF NEWFOLDER(cRUTASMR,cLote)
								IF	NEWFOLDER(cPathDocSave+"\"+cMainLote+"\",cLote)
									nCuentaLote:=1
									Aadd(aLotes,cLote)
								ENDIF
							ENDIF  
						ENDIF
						nCuentaLote++
					ENDIF
 
					CpyS2T(cPathDocSave + cNomArc + '.xml', cRUTASMR+cLote) // copia al smarclient

				EndIf
				nEnvio++
				IncProc(STR0400+(IIF(cTIPTRAN=="S",STR0401+":",":")) + cValToChar(nEnvio) + " de " + cValToChar(nTotEnv) + "...")
				// firmando documentos con el EXE se envía si es síncrona la transmisión, si es asíncrona solo firma y guarda en LOTE
				EXE(cAmbiente,cRutaSMR,cSIFEEXE,cPathDocSave,cCertificado,cPassCert,cIDENV,cIDPASCLI,cPASCLI,cTIPTRAN,cPathExe,cTipo,cNomArc,Iif(!Empty(aDocs[nI][11]),AllTrim(aDocs[nI][11]),"X"),cLote+"\")	

				IF cTIPTRAN!="A" // tipo de transmisión(S=sincrona) 
					
					//Verificancion sincrona
					//Se hace la copia del archivo .out
					If File(cRUTASMR + cNomArc + '.xml.out')
						// Procesar archivo out
						CpyT2S(cRutaSMR + cNomArc + '.xml.out' , cPath)
						Ferase( cRutaSMR + cNomArc + '.xml.out')
					EndIf
					
					//Veriricar exitencia en la ruta del .out
					If File(cPath + cNomArc + '.xml.out')
						If VeriXmlOut(cPath, cNomArc, @cMsg, cTipo, @aError, aDocs[nI], aTrans, @cStatus)
							//ActDocum(aDocs[nI][10], aDocs[nI][2], aDocs[nI][1], aDocs[nI][3], aDocs[nI][4], cTipo)
							If cTipo == "T" //Timbrado
								If File(cRUTASMR + cNomArc + '.xml')
									CpyT2S(cRutaSMR + cNomArc + '.xml' , cPath+"\autorizados\")
									Ferase( cRutaSMR + cNomArc + '.xml')
								EndIf
							EndIf
							PutMvPar("MV_IDCONEN",AllTrim(Str(Val(cIDENV)+1))) //Actualización de identificador de envío.
						Else
							If cTipo == "T" //Timbrado
								//Se hace la copia del archivo ._firmado.xml
								If File(cRUTASMR + cNomArc + '.xml')
									frename(cRUTASMR + cNomArc + '.xml' , cRUTASMR + cNomArc + '_firmado.xml' )
									CpyT2S(cRutaSMR + cNomArc + '_firmado.xml' , cPath)
									Ferase( cRutaSMR + cNomArc + '_firmado.xml')
								EndIf
							EndIf
						EndIf
						//cEspecie, cFatura, cSerie, cCodigo, cLoja, cTipo, cStatus
						ActDocum(aDocs[nI][10], aDocs[nI][2], aDocs[nI][1], aDocs[nI][3], aDocs[nI][4], cTipo, cStatus)
					Else
						//"No se encontró el archivo: "
						aAdd(aError, {aDocs[nI,1],aDocs[nI,2],aDocs[nI,3],aDocs[nI,4], STR0334 + cNomArc  + ".xml.out"})
					EndIf
				else
				     				  //cEspecie,    cFatura,        cSerie,      cCodigo,       cLoja,      cTipo, clote
					Aadd(aDocPorLote, {aDocs[nI][10], aDocs[nI][2], aDocs[nI][1], aDocs[nI][3], aDocs[nI][4],cTipo,cLote})
					CpyT2S(cRutaSMR + cLote+"\"+ cNomArc + '.xml' , cPathDocSave+"\"+cMainLote+"\"+cLote+"\")
				ENDIF
				
			Else
				//"No fue posible realizar el envio."
				//"No se encontró el archivo: "
				aAdd(aError, {aDocs[nI,1],aDocs[nI,2],aDocs[nI,3],aDocs[nI,4], STR0334 + cNomArc  + ".xml"})
			EndIf
		Next nI
		
		// solo aplica  asíncrono 
		IF cTIPTRAN=="A" // tipo de transmisión(A=asincrona,S=sincrona) PAR
				nEnvio:=0
				nTotEnv:= Len(aLotes)
				ProcRegua(nTotEnv)
				For nI := 1 To nTotEnv
					
					cXMLLote:="<rLoteDE>"+_SALTO+GETXMLMIX(cRUTASMR+aLotes[nI])+"</rLoteDE>"
				
					fWriteLocal(cXMLLote,cRUTASMR+aLotes[nI]+"\", aLotes[nI] + ".xml", 1)

					// Creadno ZIP del xml lote y enviando a SIFEN
					nEnvio++
					IncProc(STR0402+":" + cValToChar(nEnvio) + STR0403 + cValToChar(nTotEnv) + "...")
					EXE(cAmbiente,cRutaSMR,cSIFEEXE,cPathDocSave,cCertificado,cPassCert,cIDENV,cIDPASCLI,cPASCLI,"ZIP",cPathExe,cTipo,aLotes[nI],aLotes[nI],aLotes[nI])	
						
				
					If File(cRUTASMR + aLotes[nI] + '.xml.out')
						// Procesar archivo out
						CpyT2S(cRutaSMR + aLotes[nI] + '.xml.out' , cPathDocSave+"\"+cMainLote)
						Ferase( cRutaSMR + aLotes[nI] + '.xml.out')
						Ferase( cRutaSMR + aLotes[nI] + '.zip')
						
					EndIf
						
					//verificando lote
					If File(cPathDocSave+"\"+cMainLote+"\" + aLotes[nI] + '.xml.out')
						aDatosLote=	VeriLoteOut(cPathDocSave+"\"+cMainLote+"\", aLotes[nI], @cMsg, cTipo, @aError,aDocPorLote, aTrans, @cStatus,aLotes[nI])
					
						If aDatosLote[1]
									
							IF len(aDatosLotes)>0 // actualiza todos los documentos del lote
								ActDocLote(aDocPorLote,aLotes[nI],aDatosLote)
								aSize(aDatosLotes,0)
							ENDIF
							PutMvPar("MV_IDCONEN",AllTrim(Str(Val(cIDENV)+1))) //Actualización de identificador de envío.
								
						EndIf
							
					Else
							//"No se encontró el archivo: "
							aAdd(aError, {aDocs[nI,1],aDocs[nI,2],aDocs[nI,3],aDocs[nI,4], STR0334 + aLotes[nI]  + ".xml.out"})
					EndIf
					
					
				NEXT nI
			
		ENDIF // fin envio asincrono
	ENDIF

Return(lRet)

/*/{Protheus.doc} VeriXmlOut
Realiza la lectura de las respuestas de las transmisiones para Paraguay del SIFEN 
@author raul.medina
@param cRuta, caracter, Ruta del archivo para lectura
@param cNomArc, caracter, Nombre del archivo .out
@param cMsg, caracter, Variable para informar la respuesta 
@param cTipo, caracter, T- Transmisión, CA - Cancelación
@param aError, array, Arreglo usado para guardar los errores
@param aDocs, array, Arreglo que contiene la información del documento en proceso de validación
@param aTrans, array, Arreglo usado para guardar las transmisiones
@param cStatus, caracter, Variable uada para retornar el status del proceso
@return lRet
/*/
Static Function VeriXmlOut(cRuta, cNomArc, cMsg, cTipo, aError, aDocs, aTrans, cStatus )
Local lRet 		:= .F.
Local oXML

Local cArchiOUT	:= cRuta + cNomArc + ".xml.out"
Local cXML     	:= ""
Local cError	:= ""
Local cDetalle	:= ""
Local cCRLF		:= (chr(13)+chr(10))
Local nI		:= 0
Local cCodigo	:= ""
Local cDescrip	:= ""
Local cFilTab	:= Iif(AllTrim(aDocs[10]) $ "NF|NDC", xFilial("SF2"), xFilial("SF1"))

	oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )
	
	If valType(oXml) == "O"
		SAVE oXml XMLSTRING cXML
		If AT( "<ERROR" , Upper(cXML) ) > 0 .and. AT( "<TEXT" , Upper(cXML) ) > 0
			If ValType(oXml:_ERROR:_TEXT) == "O"
				cStatus		:= "X"
				cCodigo := STR0333
				cDescrip := oXml:_ERROR:_TEXT:TEXT
				aAdd(aError, {aDocs[1],aDocs[2],aDocs[3], aDocs[4], cCodigo +" "+ ALLTRIM(cDescrip)})
			EndIf
		Else
			If cTipo == "T"
				If AT( "<NS2:DESTRES" , Upper(cXML) ) > 0 
					If ValType(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_DESTRES) == "O"
						cMsg += cCRLF
						cMsg += cNomArc
						cMsg += cCRLF
						cMsg += STR0336 + oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_DESTRES:TEXT
					EndIf
				EndIf
				
				If AT( "<NS2:GRESPROC" , Upper(cXML) ) > 0 //UPPER(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_DESTRES:TEXT) == "RECHAZADO"
					If ValType(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC) == "O"
						If oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC:_NS2_DCODRES:TEXT == "0260"
							lRet 		:= .T.
							cStatus		:= "6"
							aAdd(aTrans, {cFilTab,aDocs[1],aDocs[2],aDocs[3],aDocs[4]})
						EndIf
						cCodigo := oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC:_NS2_DCODRES:TEXT
						cDescrip := oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC:_NS2_DMSGRES:TEXT
						aAdd(aError, {aDocs[1],aDocs[2],aDocs[3], aDocs[4], cCodigo +" "+ ALLTRIM(cDescrip)})
					ElseIf ValType(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC) == "A"
						For nI := 1 To Len(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC)
							cCodigo := oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC[nI]:_NS2_DCODRES:TEXT
							cDescrip := oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIDE:_NS2_RPROTDE:_NS2_GRESPROC[nI]:_NS2_DMSGRES:TEXT
							aAdd(aError, {aDocs[1],aDocs[2],aDocs[3], aDocs[4], cCodigo +" "+ ALLTRIM(cDescrip)})
						Next nI
					EndIf
				EndIf
			ElseIf cTipo == "CA"
				If AT( "<NS2:GRESPROC" , Upper(cXML) ) > 0 //
					If ValType(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIEVENTODE:_NS2_GRESPROCEVE:_NS2_GRESPROC) == "O"
						If oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIEVENTODE:_NS2_GRESPROCEVE:_NS2_GRESPROC:_NS2_DCODRES:TEXT == "0600"
							lRet 		:= .T.
							cStatus		:= "8"
							aAdd(aTrans, {cFilTab,aDocs[1],aDocs[2],aDocs[3],aDocs[4]})
						Else
							cStatus		:= "6"
						EndIf
						cCodigo := oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIEVENTODE:_NS2_GRESPROCEVE:_NS2_GRESPROC:_NS2_DCODRES:TEXT
						cDescrip := oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRETENVIEVENTODE:_NS2_GRESPROCEVE:_NS2_GRESPROC:_NS2_DMSGRES:TEXT
						aAdd(aError, {aDocs[1],aDocs[2],aDocs[3], aDocs[4], cCodigo +" "+ ALLTRIM(cDescrip)})
					EndIf
				EndIf
			EndIf
		EndIf
	Else								// Regresar contenido del archivo como texto del error
		cError := MemoRead( cArchiOUT)
		aAdd(aError, {aDocs[1],aDocs[2],aDocs[3], aDocs[4], cError})
		cStatus		:= "X"
	Endif
Return lRet

/*/{Protheus.doc} CalcMod11
Función de calculo para el digito verificador por medio del modulo11
@author raul.medina
@param cNumero, caracter, dato para realizar calcular digito verificador por medio del modulo 11
@return nDigito
/*/
Function CalcMod11(cNumero)
Local nCodigo		:= 0
Local nNumero_al	:= ""
Local nI			:= 0
Local xC		
Local nK			:= 2
Local nTotal		:= 0
Local nBaseMax		:= 11
Local nNum_aux		:= 0
Local nResto		:= 0
Local nDigito		:= 0

	For nI := 1 To Len(cNumero)
		xC := Substr(cNumero, nI, 1)
		nCodigo	:= ASC(UPPER(xC))
		If !(nCodigo >= 48 .and. nCodigo <=57)
			nNumero_al := nNumero_al + AllTrim(Str(nCodigo))
		Else
			nNumero_al := nNumero_al + xC
		EndIf
	Next nI
	
	For nI := Len(nNumero_al) To 1 Step -1
		If (nK > nBasemax)
			nK := 2
		EndIF
		
		nNum_aux := Val(Substr(nNumero_al,nI,1))
		nTotal := nTotal + (nNum_aux * nK)
		nK := nK + 1
	Next nI 
	
	nResto := Mod(nTotal,11)
	
	If (nResto > 1)
		nDigito := 11 - nResto
	Else
		nDigito	:= 0
	EndIf

Return nDigito

/*/{Protheus.doc} FecIniTimb
Función para obtener la fecha de inicio de timbrado
@author raul.medina
@param cSerie, caracter, Serie del documento
@param cEspecie, caracter, Especie del documento
@return cFecha
/*/
Function FecIniTimb(cSerie, cEspecie)
Local aArea    	:= GetArea()
Local cFecha	:= ""
Local cFechaAux	:= ""
Local cEsp		:= ""

	If AllTrim(cEspecie) == "NF"
		cEsp		:= "1"
	ElseIf AllTrim(cEspecie) == "NDC"
		cEsp		:= "5"
	ElseIf AllTrim(cEspecie) == "NCC"
		cEsp		:= "4"
	ElseIf AllTrim(cEspecie) $ "RFN|RTS"
		cEsp		:= "6"
	EndIF
	
	SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
     IF SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+cSerie+cEsp))
     	If SFP->(ColumnPos("FP_FINITIM")) > 0 
     		cFechaAux 	:= DTOS(SFP->FP_FINITIM)
     		cFecha		:= SUBSTR(cFechaAux,1,4) + "-" + SUBSTR(cFechaAux,5,2) + "-" + SUBSTR(cFechaAux,7,2)
     	EndIf
     EndIf

RestArea(aArea)

Return cFecha

/*/{Protheus.doc} ActDocum
Actualización de campos de timbrado y actualización de status
@author raul.medina
@param cEspecie, carácter, Especie del documento
@param cFatura, carácter, Numero de documento
@param cSerie, carácter, Serie del documento
@param cCodigo, carácter, Código del cliente
@param cLoja, carácter, Loja del cliente
@param cTipo, carácter, T- Transmisión, CA - Cancelación
@param cStatus, carácter, Status del proceso
@param lDatLote, booleano,.T. = indica si actualiza datos de las tablas de lote
@param aDatLote, arreglo, datos correspondientes al lote
@param lInLot,booleano, Indica si se incluye un registro en las tablas(AQ2 y AQ3)
@param cAnt, carácter, lote anterior
@param cPath, carácter, lugar donde se guardan los documentos
@return lRet, booleano, Indica si se actualizo el documento
/*/

Static Function ActDocum(cEspecie, cFatura, cSerie, cCodigo, cLoja, cTipo, cStatus,lDatLote,aDatLote,lInLot,cAnt,cPath)

Local cSF	:= ""
Local cCpo	:= ""
Local aAreaSF
Local aAreQ
Local cAct:=""
Local cMainLote:="lotes"

DEFAULT  cEspecie:= cFatura:=cSerie:=cCodigo:=cLoja:= cTipo:=cStatus:=cAnt:=""
DEFAULT  aDatLote:={}
DEFAULT  lDatLote:=lInLot:=.F. 
DEFAULT  cPath:=""

	If cTipo == "T"
		cCpo	:= "FECTIMB"
	ElseIf cTipo == "CA"
		cCpo	:= "FECANTF"
	EndIf
	
	If AllTrim(cEspecie) $ "NCI|NCC"
		cSF := "F1"
	Else
		cSF := "F2"
	EndIF

	aAreaSF:= ("S"+cSF)->(GetArea())
	("S"+cSF)->(DbSetOrder(1))
	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO 
	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If ("S"+cSF)->(DbSeek(xFilial("S"+cSF)+cFatura+cSerie+cCodigo+cLoja)) 
		RecLock("S"+cSF,.F.)

			
			// se actualiza fecha de timbrado
			If (cTipo == "T" .and. cStatus == "6") // TIMNRADO
				("S"+cSF)->(&(cSF+"_"+cCpo)) := dDataBase
			ElseIf (cTipo == "CA" .and. cStatus == "8") // CANCELACIÓN 
				("S"+cSF)->(&(cSF+"_"+cCpo)) := dDataBase
			EndIF

			//se actualiza campo de estatus
			If cStatus <> "X"
				("S"+cSF)->(&(cSF+"_"+"FLFTEX")) := cStatus
			EndIf
			IF lDatLote .AND. lInLot
				("S"+cSF)->(&(cSF+"_"+"LOTEASY")) := aDatLote[5]
			ENDIF

		("S"+cSF)->(MsUnlock())
	EndIf
	RestArea(aAreaSF)
				 
	IF lDatLote // Actualiza datos referente al lote 
		
			IF lInLot
				/*Lote*/
				aAreQ:=AQ2->(GetArea())
				DbSelectArea("AQ2")
				cAct:=aDatLote[5]
				IF(cAct<>cAnt) // Se evita que se vuelva a grabar el lote si ya se grabo proviene de ActDocLote
					AQ2->(RECLOCK("AQ2", .T.))
						AQ2->AQ2_FILIAL:=xFilial("AQ2")
						AQ2->AQ2_NUMLOT:=aDatLote[5]
						AQ2->AQ2_CODRES:=aDatLote[2]
						AQ2->AQ2_NUMSIF:=aDatLote[3]
						AQ2->AQ2_STARES:=aDatLote[4]  
						AQ2->AQ2_ESPLOT:=cEspecie
						AQ2->AQ2_FECENV:= DTOS(dDataBase)
						cAnt:=aDatLote[5]
					AQ2->(MSUNLOCK())
				ENDIF
				RestArea(aAreQ)
				
				
				/*Detalle lote */
				aAreQ:=AQ3->(GetArea())
				DbSelectArea("AQ3")
				AQ3->(RECLOCK("AQ3", .T.))
					AQ3->AQ3_FILIAL:=xFilial("AQ3")
					AQ3->AQ3_NUMLOT:=ALLTRIM(aDatLote[5])
					AQ3->AQ3_NUMDOC:=ALLTRIM(cFatura)
					AQ3->AQ3_SPECIE:=cEspecie
					AQ3->AQ3_SERIE:=cSerie
					AQ3->AQ3_CLIENT:=ALLTRIM(cCodigo)
					AQ3->AQ3_LOJA:=cLoja
				AQ3->(MSUNLOCK())
				RestArea(aAreQ)
			ELSE
				aAreQ:=AQ3->(GetArea())
				DbSelectArea("AQ3")
				AQ3->(DbSetOrder(1)) //AQ3_FILIAL+AQ3_NUMLOT+AQ3_NUMDOC+AQ3_SPECIE+AQ3_SERIE+AQ3_CLIENT+AQ3_LOJA
				                      //AQ3_FILIAL   +AQ3_NUMLOT +AQ3_NUMDOC +AQ3_SPECIE+AQ3_SERIE+AQ3_CLIENT+AQ3_LOJA                                                                                       
					If (AQ3->(MsSeek(xFilial("AQ3")+aDatLote[5]+cFatura+cEspecie+cSerie+cCodigo+cLoja))) 
						AQ3->(RECLOCK("AQ3", .F.))
						AQ3->AQ3_CODRES:=aDatLote[2]
						AQ3->AQ3_OBSDOC:=aDatLote[6]
						AQ3->(MSUNLOCK())
					ENDIF
				RestArea(aAreQ)

				aAreQ:=AQ2->(GetArea())
				DbSelectArea("AQ2")
				AQ2->(DbSetOrder(1)) //AQ2_FILIAL+STR(AQ2_NUMLOT)                      
					If AQ2->(MsSeek(xFilial("AQ2")+aDatLote[5])) 
						AQ2->(RECLOCK("AQ2", .F.))
						AQ2->AQ2_STARES:=aDatLote[4] 
						AQ2->AQ2_FECCON:=DTOS(dDataBase)
						AQ2->(MSUNLOCK())
					ENDIF
				RestArea(aAreQ)
	
				If cTipo == "T" //Timbrado
					If File(cPath+"\"+cMainLote+"\"+ALLTRIM(aDatLote[5])+"\"  +LOWER(ALLTRIM(cSerie)+ALLTRIM(cFatura)+ALLTRIM(cEspecie)) + '.xml')
						IF cStatus == "6"
							
							frename(cPath+cMainLote+"\"+ALLTRIM(aDatLote[5])+"\" +LOWER(ALLTRIM(cSerie)+ALLTRIM(cFatura)+ALLTRIM(cEspecie))+ '.xml', cPath+"\autorizados\"+LOWER( ALLTRIM(cSerie)+ALLTRIM(cFatura)+ALLTRIM(cEspecie)) +'.xml' )
							Ferase( cPath+cMainLote+"\"+cMainLote+"\"+ALLTRIM(aDatLote[5])+"\" + LOWER(ALLTRIM(cSerie)+ALLTRIM(cFatura)+ALLTRIM(cEspecie))  + '.xml')
							
						ENDIF
						IF cStatus == "5"
							frename(cPath+cMainLote+"\"+ALLTRIM(aDatLote[5])+"\" +LOWER(ALLTRIM(cSerie)+ALLTRIM(cFatura)+ALLTRIM(cEspecie))+ '.xml', cPath+LOWER( ALLTRIM(cSerie)+ALLTRIM(cFatura)+ALLTRIM(cEspecie)) +'_firmado.xml' )
							Ferase( cPath+cMainLote+"\"+ALLTRIM(aDatLote[5])+"\" + LOWER(ALLTRIM(cSerie)+ALLTRIM(cFatura)+ALLTRIM(cEspecie))+ '.xml')
						ENDIF
					EndIf
				EndIf 
			ENDIF
		
	ENDIF


Return nil

/*/{Protheus.doc} M486CANCDE
Proceso de cancelación de DE
@author raul.medina
@param nTDTras, caracter, tipo de documento a transmistir
@param aError, array, Arreglo usado para guardar los errores
@param aTrans, array, Arreglo usado para guardar las transmisiones
@return Nil
/*/
Function M486CANCDE(nTDTras,aError, aTrans)
Local aFact		:= {}
Local cMsgLog	:= ""

Default aError	:= {}
Default aTrans	:= {}
	
	If nTDTras == 3
		aAdd(aFact,{SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_EMISSAO,SF1->F1_FILIAL,.F.,"",SF1->F1_SERIE2,SF1->F1_ESPECIE, SF1->F1_UUID })
	Else
		aAdd(aFact,{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SF2->F2_FILIAL,.F.,"",SF2->F2_SERIE2,SF2->F2_ESPECIE, SF2->F2_UUID })
	EndIF
	
	Processa({|lEnd| lRet := M486FPAREN(aFact, "CA",aError, aTrans)})
	
	If len(aError) <> len(aTrans)
		cMsgLog := STR0052 + cCRLF + STR0100	// "Ocurrieron inconvenientes al momento de la transmisión" // "¿Desea visualizar log de Transmisión?"
	Else
		cMsgLog := STR0055 + cCRLF + STR0100	// "Transmisión a TSS exitosa" // "¿Desea visualizar log de Transmisión?"
	EndIf
	
	If MsgYESNO(cMsgLog)
		M486GENLOG(aError,Len(aFact),len(aTrans))
	EndIf

Return


/*/{Protheus.doc} GetDocOri
Obtiene el documento original
@author raul.medina
@param cDoc, caracter, Numero de documento
@param cSerie, caracter, Serie del documento
@param cCli, caracter, Codigo del cliente
@param cLoja, caracter, Loja del cliente
@param cSerie2, caracter, Serie usada para documentos electronicos
@param cEspecie, caracter, Especie del documento
@param cUUID, caracter, codigo CDC del documento
@param cNumTim, caracter, numero de timbrado
@return lRet
/*/
Static Function GetDocOri(cDoc, cSerie, cCli, cLoja, cSerie2, cEspecie, cUUID, cNumTim)
Local lRet			:= .F.
Local cAliasDocO	:= getNextAlias()
Local cCampos		:= ""
Local cTablas		:= ""

		cCampos  := "% SF2.F2_DOC, SF2.F2_SERIE2, SF2.F2_ESPECIE, SF2.F2_UUID, SF2.F2_NUMTIM %"
		cTablas  := "% " + RetSqlName("SF2") + " SF2 %"
		cCond    := "% SF2.F2_DOC = '" + cDoc + "'"
		cCond    += " AND SF2.F2_SERIE = '" + cSerie + "'"
		cCond    += " AND SF2.F2_CLIENTE = '" + cCli + "'"
		cCond    += " AND SF2.F2_LOJA = '" + cLoja + "'"
        cCond	 += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cCond	 += " AND SF2.D_E_L_E_T_  = ' ' %"

	BeginSql alias cAliasDocO
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
	EndSql

	dbSelectArea(cAliasDocO)

	(cAliasDocO)->(DbGoTop())


	If (cAliasDocO )->(!Eof())
		cSerie2 	:= (cAliasDocO )->F2_SERIE2
		cEspecie 	:= (cAliasDocO )->F2_ESPECIE
		cUUID		:= (cAliasDocO )->F2_UUID
		cNumTim 	:= (cAliasDocO )->F2_NUMTIM
		lRet		:= .T.
	EndIf
	
	(cAliasDocO)->(dbCloseArea())

Return lRet


/*/{Protheus.doc} M486XMLPAR
Detona generación de XML
@type
@author raul.medina
@since 10/2021
@version 1.0
@param aFact, array, Array con los documentos de los cuales se generarán los XML
@param aError, array, Array con Errores
@return lRet, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486XMLPAR(aFact,aError)
Local nI,nA := 0
Local lRet := .F.
Local aAux:={}
Local cAux:=""
Local cAux1:=""
Local lTIPRAN:=IIf( ALLTRIM(SuperGetMV("MV_TIPTRAN",,"S")) == "S",.T.,.F.) 
	ProcRegua(len(aFact))
	For nI := 1 to len(aFact)
		IncProc()
		IF AllTrim(cEspecie) $ "NCI|NCC|NDC|NDI" .AND. lTIPRAN
		aAux:=M486ASOC(cEspecie,aFact[nI,2],aFact[nI,1],aFact[nI,3],aFact[nI,4],1,.F.)
			FOR nA := 1 to len(aAux)
				IF Empty(ALLTRIM(aAux[nA,2]))//valida si trae documentos origen
					cAux+=STR0345 //"Sin documentos origen vinculados"
				ENDIF
				IF Empty(ALLTRIM(aAux[nA,5]))//valida si los documentos origen fueron timbrados
					cAux1+=aAux[nA,2]+", "
				ENDIF
			NEXT nA
			IF !Empty(cAux)
				Help(STR0350,1, STR0346+aFact[nI,2], NIL,cAux, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0347}) //STR0346"Documento:"   STR0347"Agregue documentos origen"
				lRet:=.F.
				RETURN .F.
			ENDIF
			IF !Empty(cAux1)
				cAux1=STR0348+cAux1+"                     " //"Documentos origen no timbrados: "
				Help(STR0350, 1,STR0346+aFact[nI,2],STR0346+aFact[nI,2],cAux1, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0349})//STR0349 "Transmita primero dichos documentos"
				lRet:=.F.
				RETURN .F.
			ENDIF
		ENDIF
		If AllTrim(cEspecie) $ "NCI|NCC"
			lRet := XMLPARENT(cEspecie,aFact[nI,3],aFact[nI,4],aFact[nI,2],aFact[nI,1])
		Else
			lRet := XMLPARSAL(cEspecie,aFact[nI,3],aFact[nI,4],aFact[nI,2],aFact[nI,1])
		EndIf
		aFact[nI,7] := lRet
		If !lRet // Si No se generó XML, se agrega Error a Log
			aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0147  }) // "Error al Generar XML"
		EndIf
	Next nI
Return lRet

/*/{Protheus.doc} XMLPARSAL
Crea el archivo XML para documentos de salida.
@author raul.medina
@param cEspecie, caracter, Especie del documento
@param cCodigo, caracter, Codigo del cliente
@param cLoja, caracter, Loja del cliente
@param cFatura, caracter, Numero de documento
@param cSerie, caracter, Serie del documento
@return lRet
/*/
Static Function XMLPARSAL(cEspecie, cCodigo, cLoja, cFatura, cSerie)
Local lRet		:= .F.
Local cSalto	:= _SALTO
Local cPicture	:= "999999999999999.9999"
Local cID		:= ""
Local cSecCod	:= ""
Local cdDVId	:= ""
Local cFeEmiDE	:= ""
Local cNumCasa	:= ""
Local cDepEmi	:= ""
Local cDisEmi	:= ""
Local cCiuEmi	:= ""
Local cIniTras	:= ""
Local cFinTras	:= ""
Local aTotales	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}
Local aDesc		:= {0,0}
Local lProd		:= SuperGetMV("MV_CFDI_AM",,"") == "P"
Local cEmail	:= SuperGetMV("MV_RELACNT",,"")
Local cXMLFile	:= AllTrim(cSerie) + AllTrim(cFatura) + AllTrim(cEspecie)
Local cXml		:= ""
Local cRuta		:= &(GetNewPar("MV_CFDDOCS",""))
Local cAliasTmp	:= ""
Local aArea		:= GetArea()
Local aSF		:= {}
Local cTabla	:="SA1"
Local cPrefi	:="A1"


	DbSelectArea("SF2")
	aSF := GetArea()
	DbSetOrder(1)//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	lOK := DbSeek(xFilial("SF2")+cFatura+cSerie+cCodigo+cLoja) 

	
	cSecCod  := M486SecCod(Time(),SF2->F2_EMISSAO)
	cID 	 := IIF(AllTrim(SF2->F2_ESPECIE)=="NF",M486GENCDC("01",SUBSTR(SM0->M0_CGC,1,RAT("-",SM0->M0_CGC)-1),Substr(SM0->M0_CGC,RAT("-",SM0->M0_CGC)+ 1,1),SUBSTR(SF2->F2_DOC,1,3),SUBSTR(SF2->F2_DOC,4,3),RIGHT(SF2->F2_DOC,7),"1",SF2->F2_EMISSAO,"1",cSecCod,SF2->F2_ESPECIE),"")
	cID 	 := IIF(AllTrim(SF2->F2_ESPECIE)=="NDC",M486GENCDC("06",SUBSTR(SM0->M0_CGC,1,RAT("-",SM0->M0_CGC)-1),Substr(SM0->M0_CGC,RAT("-",SM0->M0_CGC)+ 1,1),SUBSTR(SF2->F2_DOC,1,3),SUBSTR(SF2->F2_DOC,4,3),RIGHT(SF2->F2_DOC,7),"1",SF2->F2_EMISSAO,"1",cSecCod,SF2->F2_ESPECIE),cID)
	cID 	 := IIF(AllTrim(SF2->F2_ESPECIE)$"RFN|RTS",M486GENCDC("07",SUBSTR(SM0->M0_CGC,1,RAT("-",SM0->M0_CGC)-1),Substr(SM0->M0_CGC,RAT("-",SM0->M0_CGC)+ 1,1),SUBSTR(SF2->F2_DOC,1,3),SUBSTR(SF2->F2_DOC,4,3),RIGHT(SF2->F2_DOC,7),"1",SF2->F2_EMISSAO,"1",cSecCod,SF2->F2_ESPECIE),cID)
	cdDVId	 := AllTrim(STR(CalcMod11(SUBSTR(cID,1,43))))
	cFeEmiDE := SUBSTR(DTOS(SF2->F2_EMISSAO),0,4) + "-" + SUBSTR(DTOS(SF2->F2_EMISSAO),5,2) + "-" + SUBSTR(DTOS(SF2->F2_EMISSAO),7,2) + "T" + SF2->F2_HORA
	cNumCasa := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 11,6)
	cNumCasa := Iif(Empty(cNumCasa), "0", cNumCasa )
	cDepEmi  := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 18,2) 
	cDisEmi  := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 20,3)
	cCiuEmi  := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 23,4)

	cXml := '<rDE' + cSalto
	cXml += ' xmlns="http://ekuatia.set.gov.py/sifen/xsd" ' + cSalto
	cXml += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + cSalto
	cXml += ' xsi:schemaLocation="http://ekuatia.set.gov.py/sifen/xsd/ siRecepDE_v150.xsd">' + cSalto
	cXml += ' <dVerFor>150</dVerFor>' + cSalto
	cXml += '	<DE Id="' + cID + '">' + cSalto
	cXml += '		<dDVId>' + cdDVId + '</dDVId>' + cSalto
	cXml += '		<dFecFirma></dFecFirma> ' + cSalto
	cXml += '		<dSisFact>1</dSisFact>' + cSalto
	cXml += '		<gOpeDE>' + cSalto
	cXml += '        	<iTipEmi>1</iTipEmi>' + cSalto
	cXml += '        	<dDesTipEmi>Normal</dDesTipEmi>' +cSalto
	cXml += '			<dCodSeg>' + SUBSTR(cID,35,9) + '</dCodSeg>' + cSalto
	cXml += '		</gOpeDE>' + cSalto
	cXml += '		<gTimb>' + cSalto
	If AllTrim(SF2->F2_ESPECIE) == "NF"
		cXml += '        	<iTiDE>1</iTiDE>' + cSalto
		cXml += '        	<dDesTiDE>Factura electrónica</dDesTiDE>' + cSalto
	ElseIf AllTrim(SF2->F2_ESPECIE) == "NDC"
		cXml += '        	<iTiDE>6</iTiDE>' + cSalto
		cXml += '        	<dDesTiDE>Nota de débito electrónica</dDesTiDE>' + cSalto
	Else
		cXml += '        	<iTiDE>7</iTiDE>' + cSalto
		cXml += '        	<dDesTiDE>Nota de remisión electrónica</dDesTiDE>'	+ cSalto
	EndIf
	cXml += '        	<dNumTim>'+ AllTrim(SF2->F2_NUMTIM) +'</dNumTim>' + cSalto
	cXml += '        	<dEst>' + SUBSTR(SF2->F2_DOC,1,3) + '</dEst>' + cSalto
	cXml += '        	<dPunExp>' + SUBSTR(SF2->F2_DOC,4,3) + '</dPunExp>' + cSalto
	cXml += '        	<dNumDoc>' + RIGHT(SF2->F2_DOC,7) + '</dNumDoc>' + cSalto
	cXml += '        	<dSerieNum>' + AllTrim(SF2->F2_SERIE2) + '</dSerieNum>' + cSalto
	cXml += '			<dFeIniT>' +FecIniTimb(SF2->F2_SERIE, SF2->F2_ESPECIE) + '</dFeIniT>' + cSalto
	cXml += '		</gTimb>' + cSalto
	cXml += '		<gDatGralOpe>' + cSalto
	cXml += '			<dFeEmiDE>' + cFeEmiDE + '</dFeEmiDE>' + cSalto
	
	// Campos inherentes a la operación comercial (D010-D099)
	If !AllTrim(SF2->F2_ESPECIE) $ "RFN|RTS"
		CTO->(DbSetOrder(1)) //CTO_FILIAL+CTO_MOEDA
		CTO->(MsSeek(xFilial("CTO")+Strzero(SF2->F2_MOEDA,2)))
		cXml += M486IMPPAR(AllTrim(SF2->F2_ESPECIE),SF2->F2_DOC,SF2->F2_SERIE, SF2->F2_CLIENTE,SF2->F2_LOJA, CTO->CTO_MOESAT, AllTrim(SF2->F2_TPTRANS),SF2->F2_TXMOEDA) + cSalto
	EndIf
	//EMISOR
	cXml += '			<gEmis>' + cSalto
	cXml += '				<dRucEm>' + SUBSTR(SM0->M0_CGC,1,RAT("-",SM0->M0_CGC)-1)+'</dRucEm>' + cSalto
	cXml += '				<dDVEmi>' + Substr(SM0->M0_CGC,RAT("-",SM0->M0_CGC)+ 1,1) + '</dDVEmi>' + cSalto
	cXml += '				<iTipCont>1</iTipCont>' + cSalto
	cXml += '				<cTipReg>'+ ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 17,1) +'</cTipReg>' + cSalto
	If lProd
		cXml += '				<dNomEmi>'+ AllTrim(SM0->M0_NOME) + '</dNomEmi>' + cSalto
	Else
		cXml += '				<dNomEmi>'+  "DE generado en ambiente de prueba - sin valor comercial ni fiscal" + '</dNomEmi>' + cSalto
	EndIf
	cXml += '				<dNomFanEmi>'+ AllTrim(SM0->M0_NOMECOM) + '</dNomFanEmi>' + cSalto
	cXml += '				<dDirEmi>'+ AllTrim(SM0->M0_ENDENT) + '</dDirEmi>' + cSalto
	cXml += '				<dNumCas>' + cNumCasa + '</dNumCas>' + cSalto
	cXml += '				<cDepEmi>' + cDepEmi+ '</cDepEmi>' + cSalto
	cXml += '				<dDesDepEmi>' + AllTrim(ObtColSAT("S003",cDepEmi, 1, 2, 3,28)) + '</dDesDepEmi>' + cSalto
	cXml += '				<cDisEmi>' + AllTrim(cDisEmi) + '</cDisEmi>' + cSalto
	cXml += '				<dDesDisEmi>' + AllTrim(ObtColSAT("S031",cDisEmi, 1, 3, 4,30))+ '</dDesDisEmi>' + cSalto
	cXml += '				<cCiuEmi>' +  AllTrim(cCiuEmi)  + '</cCiuEmi>' + cSalto
	cXml += '				<dDesCiuEmi>' +  AllTrim(ObtColSAT("S012",cCiuEmi, 48, 4, 52,30))+ '</dDesCiuEmi>' + cSalto
	If !Empty(SM0->M0_TEL)
		cXml += '				<dTelEmi>' + AllTrim(SM0->M0_TEL) + '</dTelEmi>' + cSalto
	EndIf
	cXml += '				<dEmailE>' +  ALLTRIM(cEmail)  + '</dEmailE>' + cSalto //Quitar
	cXml += '				<gActEco>' + cSalto
	cXml += '					<cActEco>' + AllTrim(SM0->M0_DSCCNA) + '</cActEco>' + cSalto
	cXml += '					<dDesActEco>'+ ObtColSAT("S006",SUBSTR(SM0->M0_DSCCNA,1,6) , 2, 5, 7,166)+'</dDesActEco>' + cSalto
	cXml += '				</gActEco>' +  cSalto
	cXml += '			</gEmis>' + cSalto
	//RECEPTOR
	IF (AllTrim(SF2->F2_ESPECIE)=="RTS")
		cTabla:="SA2"
		cPrefi:="A2"
	ENDIF
	
	(cTabla)->(DbSetOrder(1))
	(cTabla)->(MSSeek(xFilial(cTabla)+SF2->F2_CLIENTE+SF2->F2_LOJA))
	SYA->(DbSetOrder(1))
	// DATOS CLIENTE
	SYA->(MsSeek(xFilial("SYA")+(cTabla)->&(cPrefi+"_PAIS")))

	cXml += '			<gDatRec>' + cSalto
	
	cXml += '				<iNatRec>'+IIF (!Empty((cTabla)->&(cPrefi+"_CGC")),"1","2")+'</iNatRec>' + cSalto
	cXml += '				<iTiOpe>1</iTiOpe>' + cSalto
	cXml += '				<cPaisRec>' + SYA->YA_CODERP + '</cPaisRec>' + cSalto
	cXml += '				<dDesPaisRe>'+ ObtColSAT("S005",SYA->YA_CODERP, 1, 3, 4,52)+'</dDesPaisRe>' +cSalto
	If !Empty((cTabla)->&(cPrefi+"_CGC"))
		
		cXml += '				<iTiContRec>' + IIF((cTabla)->&(cPrefi+"_PESSOA") $ "F","1","2") + '</iTiContRec>' + cSalto
		cXml += '				<dRucRec>' +  SUBSTR((cTabla)->&(cPrefi+"_CGC"),1,RAT("-",(cTabla)->&(cPrefi+"_CGC"))-1) + '</dRucRec>' + cSalto
		cXml += '				<dDVRec>' + Substr((cTabla)->&(cPrefi+"_CGC"),RAT("-",(cTabla)->&(cPrefi+"_CGC"))+ 1,1) + '</dDVRec>' + cSalto
	ElseIF (AllTrim(SF2->F2_ESPECIE)<>"RTS")// No aplica lo de sin RUC para RTS adicional estos campos no se agregaron en la SA2
		cXml += '				<iTipIDRec>' + AllTrim(SA1->A1_TIPDOC) + '</iTipIDRec>' + cSalto
		cXml += '				<dDTipIDRec>' +  ObtColSAT("S018", SA1->A1_TIPDOC, 1, 1, 2,41) + '</dDTipIDRec>' + cSalto
		cXml += '				<dNumIDRec>' +  IIF(AllTrim(SA1->A1_TIPDOC)=="5","0",ALLTRIM(SA1->A1_NIF)) + '</dNumIDRec>' +cSalto
	EndIf
	cXml += '				<dNomRec>' + AllTrim((cTabla)->&(cPrefi+"_NOME"))+ '</dNomRec>' + cSalto
	cXml += '				<dNomFanRec>' + AllTrim((cTabla)->&(cPrefi+"_NREDUZ"))+ '</dNomFanRec>' + cSalto
	cXml += '				<dDirRec>' + AllTrim((cTabla)->&(cPrefi+"_END")) + '</dDirRec>' + cSalto
	cXml += '				<dNumCasRec>' + AllTrim((cTabla)->&(cPrefi+"_NUM")) + '</dNumCasRec>' + cSalto
	cXml += '				<cDepRec>' +  AllTrim((cTabla)->&(cPrefi+"_DEPTO")) + '</cDepRec>' + cSalto
	cXml += '				<dDesDepRec>' + AllTrim(ObtColSAT("S003",(cTabla)->&(cPrefi+"_DEPTO"), 1, 2, 3,28)) +'</dDesDepRec>' + cSalto
	cXml += '				<cDisRec>' +  AllTrim((cTabla)->&(cPrefi+"_DISTR"))+ '</cDisRec>' + cSalto
	cXml += '				<dDesDisRec>'+ AllTrim(ObtColSAT("S031",(cTabla)->&(cPrefi+"_DISTR"), 1, 3, 4,30)) + '</dDesDisRec>' + cSalto
	cXml += '				<cCiuRec>' + AllTrim((cTabla)->&(cPrefi+"_CIUDAD")) + '</cCiuRec>' + cSalto
	cXml += '				<dDesCiuRec>' + AllTrim(ObtColSAT("S012",(cTabla)->&(cPrefi+"_CIUDAD"), 48, 4, 52,30)) + '</dDesCiuRec>' + cSalto
	If !Empty((cTabla)->&(cPrefi+"_TEL"))
		cXml += '				<dTelRec>' + AllTrim((cTabla)->&(cPrefi+"_TEL")) + '</dTelRec>' + cSalto
	EndIf
	If !Empty((cTabla)->&(cPrefi+"_EMAIL"))
		cXml += '				<dEmailRec>' + ALLTRIM((cTabla)->&(cPrefi+"_EMAIL")) + '</dEmailRec>' + cSalto
	EndIf
	cXml += '				<dCodCliente>' + AllTrim((cTabla)->&(cPrefi+"_COD")) + '</dCodCliente>' + cSalto
	cXml += '			</gDatRec>' + cSalto
	cXml += '		</gDatGralOpe>' + cSalto

	//TIPO DE PRESENCIA
	cXml += '		<gDtipDE>' + cSalto
	If AllTrim(SF2->F2_ESPECIE)=="NF"
		cXml += '        	<gCamFE>' + cSalto
		cXml += '    			<iIndPres>' + AllTrim(SF2->F2_TIPONF) + '</iIndPres>' + cSalto
		cXml += '        		<dDesIndPres>'+ ObtColSAT("S019",SF2->F2_TIPONF, 1, 1, 2,30)+'</dDesIndPres>' + cSalto
		cXml += '        	</gCamFE>' + cSalto
		// CONDICIONES DE PAGO
		cXml += M486CONDPAG(SF2->F2_FILIAL, SF2->F2_DOC,SF2->F2_SERIE, SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_ESPECIE,SF2->F2_COND,SF2->F2_MOEDA,SF2->F2_TXMOEDA) + cSalto
	ElseIf AllTrim(SF2->F2_ESPECIE)=="NDC"
		cXml += '        	<gCamNCDE>' + cSalto
		cXml += '    			<iMotEmi>' + AllTrim(SF2->F2_TIPREF) + '</iMotEmi>' + cSalto
		cXml += '        		<dDesMotEmi>'+ ObtColSAT("S021",SF2->F2_TIPREF, 1, 1, 2,30)+'</dDesMotEmi>' + cSalto
		cXml += '        	</gCamNCDE>' + cSalto
	ElseIf AllTrim(SF2->F2_ESPECIE)$ "RFN|RTS"
		cXml += '        	<gCamNRE>' + cSalto
		cXml += '    			<iMotEmiNR>' + AllTrim(SF2->F2_MOTEMIR) + '</iMotEmiNR>' + cSalto
		cXml += '        		<dDesMotEmiNR>'+ ObtColSAT("S022",SF2->F2_MOTEMIR, 1, 2, 3,60)+'</dDesMotEmiNR>' + cSalto
		cXml += '    			<iRespEmiNR>1</iRespEmiNR>'+ cSalto
		cXml += '    			<dDesRespEmiNR>Emisor de la factura</dDesRespEmiNR>' + cSalto
		If AllTrim(SF2->F2_MOTEMIR) == "1"
			cXml += '    			<dFecEm>' + SUBSTR(DTOS(SF2->F2_FECHSE),0,4) + "-" + SUBSTR(DTOS(SF2->F2_FECHSE),5,2) + "-" + SUBSTR(DTOS(SF2->F2_FECHSE),7,2) + '</dFecEm>' + cSalto
		EndIf
		cXml += '        	</gCamNRE>' + cSalto
	EndIf

	cAliasTmp := QueryItems("SD2", "D2_COD, D2_QUANT, D2_TES, D2_ITEM, SD2.R_E_C_N_O_", "D2_DOC='" + SF2->F2_DOC + "' AND D2_SERIE='" + SF2->F2_SERIE + "' AND D2_CLIENTE='" + SF2->F2_CLIENTE + "' AND D2_LOJA='" + SF2->F2_LOJA + "'",  "D2_ITEM") 
	
	While (cAliasTmp)->(!EOF())
		cXml += '        	<gCamItem>' + cSalto
		cXml += '    			<dCodInt>' + Alltrim((cAliasTmp)->B1_COD) + '</dCodInt>' + cSalto
		cXml += '    			<dDesProSer>' + AllTrim((cAliasTmp)->B1_DESC) + '</dDesProSer>' + cSalto
		cXml += '    			<cUniMed>' + AllTrim((cAliasTmp)->AH_COD_CO) + '</cUniMed>' + cSalto
		cXml += '    			<dDesUniMed>' + ObtColSAT("S002",(cAliasTmp)->AH_COD_CO, 1, 3, 29,6) + '</dDesUniMed>' + cSalto
		cXml += '    			<dCantProSer>' + AllTrim(TRANSFORM((cAliasTmp)->D2_QUANT,"9999999999.9999") )+ '</dCantProSer>' + cSalto
		If !AllTrim(SF2->F2_ESPECIE) $ "RFN|RTS"
			If (cAliasTmp)->R_E_C_N_O_ > 0
				SD2->(dbgoto((cAliasTmp)->R_E_C_N_O_))
			EndIf
			cXml += M486IMPDPAR(AllTrim(SF2->F2_ESPECIE),SF2->F2_DOC,SF2->F2_SERIE, SF2->F2_CLIENTE,SF2->F2_LOJA, (cAliasTmp)->D2_TES,(cAliasTmp)->D2_ITEM,(cAliasTmp)->D2_COD,@aDesc,@aTotales) + cSalto
		EndIf
		cXml += '        	</gCamItem>' + cSalto
		(cAliasTmp)->(dbSkip())
	End
	(cAliasTmp)->(dbcloseArea())
	
	//Nodos de Guia de Remisión
	If AllTrim(SF2->F2_ESPECIE) $ "RFN|RTS"
		DbSelectArea("DA3")
		DA3->(DbSetOrder(1)) //DA3_FILIAL+DA3_COD
		If DA3->(DbSeek(xFilial("DA3") + SF2->F2_VEICULO))
			cXml += '        	<gTransp>' + cSalto
			cXml += '    			<iTipTrans>' + AllTrim(DA3->DA3_TIPTR2) + '</iTipTrans>' + cSalto
			If AllTrim(AllTrim(DA3->DA3_FROVEI)) == "1"
				cXml += '    			<dDesTipTrans>Propio</dDesTipTrans>' + cSalto
			Else
				cXml += '    			<dDesTipTrans>Tercero</dDesTipTrans>' + cSalto
			EndIf
			cXml += '    			<iModTrans>' + AllTrim(DA3->DA3_TIPTR2) + '</iModTrans>' + cSalto
			cXml += '    			<dDesModTrans>' + AllTrim(ObtColSAT("S026", AllTrim(DA3->DA3_TIPTR2), 1, 1, 2,10)) + '</dDesModTrans>' + cSalto
			cXml += '    			<iRespFlete>' + AllTrim(SF2->F2_TPRESFL) + '</iRespFlete>' + cSalto
			cXml += '    			<cCondNeg>' + AllTrim(SF2->F2_INCOTER) + '</cCondNeg>' +  cSalto
			cIniTras := SUBSTR(DTOS(SF2->F2_FECDSE),0,4) + "-" + SUBSTR(DTOS(SF2->F2_FECDSE),5,2) + "-" + SUBSTR(DTOS(SF2->F2_FECDSE),7,2)
			cXml += '    			<dIniTras>' + cIniTras + '</dIniTras>' + cSalto
			cFinTras := SUBSTR(DTOS(SF2->F2_FECHSE),0,4) + "-" + SUBSTR(DTOS(SF2->F2_FECHSE),5,2) + "-" + SUBSTR(DTOS(SF2->F2_FECHSE),7,2)
			cXml += '    			<dFinTras>' + cFinTras  + '</dFinTras>' + cSalto
			cXml += '    			<gCamSal>' + cSalto
			cXml += '    				<dDirLocSal>' + AllTrim(SM0->M0_ENDENT) + '</dDirLocSal>' + cSalto
			cXml += '    				<dNumCasSal>' + cNumCasa + '</dNumCasSal>' + cSalto 
			If !Empty(SM0->M0_COMPENT)
				cXml += '    				<dComp1Sal>' + AllTrim(SM0->M0_COMPENT) + '</dComp1Sal>' + cSalto
			EndIf
			cXml += '    				<cDepSal>' + cDepEmi + '</cDepSal>' + cSalto
			cXml += '    				<dDesDepSal>' + AllTrim(ObtColSAT("S003",cDepEmi, 1, 2, 3,28)) + '</dDesDepSal>' + cSalto
			cXml += '    				<cDisSal>' + AllTrim(cDisEmi) + '</cDisSal>' + cSalto
			cXml += '    				<dDesDisSal>' + AllTrim(ObtColSAT("S031",cDisEmi, 1, 3, 4,30)) + '</dDesDisSal>' +cSalto
			cXml += '    				<cCiuSal>' + AllTrim(cCiuEmi) + '</cCiuSal>' + cSalto
			cXml += '    				<dDesCiuSal>' + AllTrim(ObtColSAT("S012",cCiuEmi, 48, 4, 52,30)) + '</dDesCiuSal>' + cSalto
			cXml += '    			</gCamSal>' + cSalto
			cXml += '    			<gCamEnt>' + cSalto
			cXml += '    				<dDirLocEnt>' + AllTrim((cTabla)->&(cPrefi+"_END"))  + '</dDirLocEnt>' + cSalto
			cXml += '    				<dNumCasEnt>' + AllTrim((cTabla)->&(cPrefi+"_NUM")) + '</dNumCasEnt>' + cSalto
			cXml += '    				<cDepEnt>' +  AllTrim((cTabla)->&(cPrefi+"_DEPTO"))  + '</cDepEnt>' + cSalto
			cXml += '    				<dDesDepEnt>' + Alltrim(ObtColSAT("S003",(cTabla)->&(cPrefi+"_DEPTO"), 1, 2, 3,28)) + '</dDesDepEnt>' + cSalto
			cXml += '    				<cDisEnt>' + AllTrim((cTabla)->&(cPrefi+"_DISTR")) + '</cDisEnt>' +cSalto
			cXml += '    				<dDesDisEnt>' + AllTrim(ObtColSAT("S031",(cTabla)->&(cPrefi+"_DISTR"), 1, 3, 4,30)) + '</dDesDisEnt>' + cSalto
			cXml += '    				<cCiuEnt>' + AllTrim((cTabla)->&(cPrefi+"_CIUDAD")) + '</cCiuEnt>' + cSalto
			cXml += '    				<dDesCiuEnt>' +  AllTrim(ObtColSAT("S012",(cTabla)->&(cPrefi+"_CIUDAD"), 48, 4, 52,30)) + '</dDesCiuEnt>' + cSalto
			If !Empty(SA1->A1_TEL)
				cXml += '    				<dTelEnt>' + AllTrim(SA1->A1_TEL) + '</dTelEnt>' + cSalto
			EndIf
			cXml += '    			</gCamEnt>' + cSalto
			cXml += '    			<gVehTras>' + cSalto
			cXml += '    				<dTiVehTras>' + Alltrim(ObtColSAT("S026", AllTrim(DA3->DA3_TIPTR2), 1, 1, 2,10)) + '</dTiVehTras>' + cSalto
			cXml += '    				<dMarVeh>' + AllTrim(DA3->DA3_DESC) + '</dMarVeh>' +cSalto
			cXml += '    				<dTipIdenVeh>' + AllTrim(DA3->DA3_TIPID) + '</dTipIdenVeh>' + cSalto
			If AllTrim(DA3->DA3_TIPID) == "1"
				cXml += '    				<dNroIDVeh>' + AllTrim(DA3->DA3_CHASSI) + '</dNroIDVeh>' + cSalto
			Else
				cXml += '    				<dNroMatVeh>' + AllTrim(DA3->DA3_PLACA) + '</dNroMatVeh>' + cSalto
			EndIf
			If AllTrim(DA3->DA3_TIPTR2) == "3"
				cXml += '    				<dNroVuelo>' + AllTrim(SF2->F2_RASTR) + '</dNroVuelo>' + cSalto
			EndIf
			cXml += '    			</gVehTras>' + cSalto
			DbSelectArea("SA4")
			SA4->(DbSetOrder(1)) //A4_FILIAL+A4_COD
			If SA4->(MsSeek(xFilial("SA4") + SF2->F2_TRANSP))
				cXml += '    			<gCamTrans>' + cSalto
				cXml += '    				<iNatTrans>' + AllTrim(SA4->A4_TIPCON) + '</iNatTrans>' + cSalto
				cXml += '    				<dNomTrans>' + AllTrim(SA4->A4_NOME) + '</dNomTrans>' + cSalto
				If AllTrim(SA4->A4_TIPCON) == "1"
					cXml += '    				<dRucTrans>' + SUBSTR(SA4->A4_CGC,1,RAT("-",SA4->A4_CGC)-1) + '</dRucTrans>' + cSalto
					cXml += '    				<dDVTrans>' + SUBSTR(SA4->A4_CGC,RAT("-",SA4->A4_CGC)+ 1,1) + '</dDVTrans>' + cSalto
				Else
					cXml += '    				<iTipIDTrans>' + Alltrim(SA4->A4_TIPID) + '</iTipIDTrans>' + cSalto
					cXml += '    				<dDTipIDTrans>' +  Alltrim(ObtColSAT("S018", ALLTRIM(SA4->A4_TIPID), 1, 1, 2,41))  + '</dDTipIDTrans>' + cSalto
					cXml += '    				<dNumIDTrans>' + AllTrim(SA4->A4_CGC) + '</dNumIDTrans>' + cSalto
				EndIf
				cXml += '    				<dNumIDChof>' + AllTrim(SA4->A4_CGC) + '</dNumIDChof>' + cSalto
				cXml += '    				<dNomChof>' + AllTrim(SA4->A4_NOME) + '</dNomChof>' + cSalto
				cXml += '    			</gCamTrans>' + cSalto
			EndIf
			cXml += '        	</gTransp>' + cSalto
		EndIf
	EndIf

	cXml += '		</gDtipDE>' + cSalto
	If !AllTrim(SF2->F2_ESPECIE) $ "RFN|RTS"
		aTotales := M486SUBTOT(AllTrim(SF2->F2_ESPECIE),SF2->F2_DOC,SF2->F2_SERIE, SF2->F2_CLIENTE,SF2->F2_LOJA)
		cXml += '		<gTotSub>' + cSalto
		cXml += '        	<dSubExe>'+ AllTrim(TRANSFORM(aTotales[1],cPicture))+'</dSubExe>' + cSalto
		cXml += '        	<dSubExo>'+ AllTrim(TRANSFORM(aTotales[2],cPicture))+'</dSubExo>' + cSalto
		cXml += '        	<dSub5>'+ AllTrim(TRANSFORM(aTotales[3],cPicture))+'</dSub5>' + cSalto
		cXml += '        	<dSub10>'+ AllTrim(TRANSFORM(aTotales[4],cPicture))+'</dSub10>' + cSalto
		cXml += '        	<dTotOpe>'+ AllTrim(TRANSFORM(aTotales[5],cPicture))+'</dTotOpe>' + cSalto
		cXml += '        	<dTotDesc>'+ AllTrim(TRANSFORM(aDesc[1],cPicture))+'</dTotDesc>' + cSalto
		cXml += '        	<dTotDescGlotem>'+ AllTrim(TRANSFORM(aTotales[6],cPicture))+'</dTotDescGlotem>' + cSalto
		cXml += '        	<dTotAntItem>0</dTotAntItem>' + cSalto
		cXml += '        	<dTotAnt>0</dTotAnt>' + cSalto
		cXml += '        	<dPorcDescTotal>0</dPorcDescTotal>' + cSalto
		cXml += '        	<dDescTotal>'+ AllTrim(TRANSFORM(aDesc[1],cPicture))+'</dDescTotal>' + cSalto
		cXml += '        	<dAnticipo>0</dAnticipo>' + cSalto
		cXml += '        	<dRedon>0.0</dRedon>' + cSalto
		cXml += '        	<dTotGralOpe>'+ AllTrim(TRANSFORM(SF2->F2_VALBRUT,cPicture))+'</dTotGralOpe>' + cSalto
		cXml += '        	<dIVA5>'+ AllTrim(TRANSFORM(aTotales[7],cPicture))+'</dIVA5>' + cSalto
		cXml += '        	<dIVA10>'+ AllTrim(TRANSFORM(aTotales[8],cPicture))+'</dIVA10>' + cSalto
		cXml += '        	<dTotIVA>'+ AllTrim(TRANSFORM(aTotales[9],cPicture))+'</dTotIVA>' + cSalto
		cXml += '        	<dBaseGrav5>'+ AllTrim(TRANSFORM(aTotales[10],cPicture))+'</dBaseGrav5>' + cSalto
		cXml += '			<dBaseGrav10>'+ AllTrim(TRANSFORM(aTotales[11],cPicture))+'</dBaseGrav10>' + cSalto
		cXml += '			<dTBasGraIVA>'+ AllTrim(TRANSFORM(aTotales[12],cPicture))+'</dTBasGraIVA>' + cSalto
		If AllTrim(STR(SF2->F2_MOEDA)) <> "1"
			cXml += '			<dTotalGs>'+ AllTrim(TRANSFORM(SF2->F2_VALBRUT*SF2->F2_TXMOEDA,cPicture))+'</dTotalGs>' + cSalto
		EndIf
		cXml += '		</gTotSub>' +cSalto
	EndIf
	
	//DOCUMENTO ASOCIADO
	If AllTrim(SF2->F2_ESPECIE)=="NDC"
		cXml += '		<gCamDEAsoc>' + cSalto
		cXml += M486ASOC(SF2->F2_ESPECIE,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,"1",.T.) 
		cXml += '		</gCamDEAsoc>' + cSalto
	EndIf
	cXml += '	</DE>' + cSalto
	cXml += '</rDE>' + cSalto

	If ExistBlock("M486PESXML")
		cXML	:= ExecBlock("M486PESXML",.F.,.F.,{SF2->F2_FILIAL, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_ESPECIE, cXml})
	EndIf

	cXml := ENCODEUTF8(cXml)

	fWriteLocal(cXml, cRuta, cXMLFile + ".xml", 1)

	RestArea(aSF)
	RestArea(aArea)

	If File(cRuta+cXMLFile+".xml")
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} XMLPARENT
Crea el archivo XML para documentos de entrada.
@author raul.medina
@param cEspecie, caracter, Especie del documento
@param cCodigo, caracter, Codigo del cliente
@param cLoja, caracter, Loja del cliente
@param cFatura, caracter, Numero de documento
@param cSerie, caracter, Serie del documento
@return lRet
/*/
Static Function XMLPARENT(cEspecie, cCodigo, cLoja, cFatura, cSerie)
Local lRet		:= .F.
Local cSalto	:= chr(13) + chr(10)
Local cPicture	:= "999999999999999.9999"
Local cID		:= ""
Local cSecCod	:= ""
Local cdDVId	:= ""
Local cFeEmiDE	:= ""
Local cNumCasa	:= ""
Local cDepEmi	:= ""
Local cDisEmi	:= ""
Local cCiuEmi	:= ""
Local aTotales	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}
Local aDesc		:= {0,0}
Local lProd		:= SuperGetMV("MV_CFDI_AM",,"") == "P"
Local cEmail	:= SuperGetMV("MV_RELACNT",,"")
Local cXMLFile	:= AllTrim(cSerie) + AllTrim(cFatura) + AllTrim(cEspecie)
Local cXml		:= ""
Local cRuta		:= &(GetNewPar("MV_CFDDOCS",""))
Local cAliasTmp	:= ""
Local aArea		:= GetArea()
Local aSF		:= {}

	DbSelectArea("SF1")
	aSF := GetArea()
	DbSetOrder(1)//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO 
	DbSeek(xFilial("SF1")+cFatura+cSerie+cCodigo+cLoja)

	
	cSecCod  := M486SecCod(Time(),SF1->F1_EMISSAO)
	cID		 := M486GENCDC("05",SUBSTR(SM0->M0_CGC,1,RAT("-",SM0->M0_CGC)-1),Substr(SM0->M0_CGC,RAT("-",SM0->M0_CGC)+ 1,1),SUBSTR(SF1->F1_DOC,1,3),SUBSTR(SF1->F1_DOC,4,3),SUBSTR(SF1->F1_DOC,7),"1",SF1->F1_EMISSAO,"1",cSecCod,SF1->F1_ESPECIE)
	cdDVId	 := AllTrim(STR(CalcMod11(SUBSTR(cID,1,43))))
	cFeEmiDE := SUBSTR(DTOS(SF1->F1_EMISSAO),0,4) + "-" + SUBSTR(DTOS(SF1->F1_EMISSAO),5,2) + "-" + SUBSTR(DTOS(SF1->F1_EMISSAO),7,2) + "T" + SF1->F1_HORA
	cNumCasa := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 11,6)
	cNumCasa := Iif(Empty(cNumCasa), "0", cNumCasa )
	cDepEmi  := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 18,2) 
	cDisEmi  := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 20,3)
	cCiuEmi  := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 23,4)

	cXml := '<rDE' + cSalto
	cXml += ' xmlns="http://ekuatia.set.gov.py/sifen/xsd" ' + cSalto
	cXml += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + cSalto
	cXml += ' xsi:schemaLocation="http://ekuatia.set.gov.py/sifen/xsd/ siRecepDE_v150.xsd">' + cSalto
	cXml += ' <dVerFor>150</dVerFor>' + cSalto
	cXml += '	<DE Id="' + cID + '">' + cSalto
	cXml += '		<dDVId>' + cdDVId + '</dDVId>' + cSalto
	cXml += '		<dFecFirma></dFecFirma> ' + cSalto
	cXml += '		<dSisFact>1</dSisFact>' + cSalto
	cXml += '		<gOpeDE>' + cSalto
	cXml += '        	<iTipEmi>1</iTipEmi>' + cSalto
	cXml += '        	<dDesTipEmi>Normal</dDesTipEmi>' +cSalto
	cXml += '			<dCodSeg>' + SUBSTR(cID,35,9) + '</dCodSeg>' + cSalto
	cXml += '		</gOpeDE>' + cSalto
	cXml += '		<gTimb>' + cSalto
	cXml += '        	<iTiDE>5</iTiDE>' + cSalto
	cXml += '        	<dDesTiDE>Nota de crédito electrónica</dDesTiDE>' + cSalto
	cXml += '        	<dNumTim>'+ AllTrim(SF1->F1_NUMTIM) +'</dNumTim>' + cSalto
	cXml += '        	<dEst>' + SUBSTR(SF1->F1_DOC,1,3) + '</dEst>' + cSalto
	cXml += '        	<dPunExp>' + SUBSTR(SF1->F1_DOC,4,3) + '</dPunExp>' + cSalto
	cXml += '        	<dNumDoc>' + RIGHT(SF1->F1_DOC,7) + '</dNumDoc>' + cSalto
	cXml += '        	<dSerieNum>' + AllTrim(SF1->F1_SERIE2) + '</dSerieNum>' + cSalto
	cXml += '			<dFeIniT>' + FecIniTimb(SF1->F1_SERIE, SF1->F1_ESPECIE) + '</dFeIniT>' + cSalto
	cXml += '		</gTimb>' + cSalto
	cXml += '		<gDatGralOpe>' + cSalto
	cXml += '			<dFeEmiDE>' + cFeEmiDE + '</dFeEmiDE>' + cSalto

	// Campos inherentes a la operación comercial (D010-D099)
	CTO->(DbSetOrder(1)) //CTO_FILIAL+CTO_MOEDA
	CTO->(MsSeek(xFilial("CTO")+Strzero(SF1->F1_MOEDA,2)))
	cXml += M486IMPPAR(ALLTRIM(SF1->F1_ESPECIE),SF1->F1_DOC,SF1->F1_SERIE, SF1->F1_FORNECE,SF1->F1_LOJA, CTO->CTO_MOESAT,"","") + cSalto

	//EMISOR
	cXml += '			<gEmis>' + cSalto
	cXml += '				<dRucEm>' + SUBSTR(SM0->M0_CGC,1,RAT("-",SM0->M0_CGC)-1)+'</dRucEm>' + cSalto
	cXml += '				<dDVEmi>' + Substr(SM0->M0_CGC,RAT("-",SM0->M0_CGC)+ 1,1) + '</dDVEmi>' + cSalto
	cXml += '				<iTipCont>1</iTipCont>' + cSalto
	cXml += '				<cTipReg>'+ ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 17,1) +'</cTipReg>' + cSalto
	If lProd
		cXml += '				<dNomEmi>'+ AllTrim(SM0->M0_NOME) + '</dNomEmi>' + cSalto
	Else
		cXml += '				<dNomEmi>'+  "DE generado en ambiente de prueba - sin valor comercial ni fiscal" + '</dNomEmi>' + cSalto
	EndIf
	cXml += '				<dNomFanEmi>'+ AllTrim(SM0->M0_NOMECOM) + '</dNomFanEmi>' + cSalto
	cXml += '				<dDirEmi>'+ AllTrim(SM0->M0_ENDENT) + '</dDirEmi>' + cSalto
	cXml += '				<dNumCas>' + cNumCasa + '</dNumCas>' + cSalto
	cXml += '				<cDepEmi>' + cDepEmi+ '</cDepEmi>' + cSalto
	cXml += '				<dDesDepEmi>' + AllTrim(ObtColSAT("S003",cDepEmi, 1, 2, 3,28)) + '</dDesDepEmi>' + cSalto
	cXml += '				<cDisEmi>' + AllTrim(cDisEmi) + '</cDisEmi>' + cSalto
	cXml += '				<dDesDisEmi>' + AllTrim(ObtColSAT("S031",cDisEmi, 1, 3, 4,30))+ '</dDesDisEmi>' + cSalto
	cXml += '				<cCiuEmi>' +  AllTrim(cCiuEmi)  + '</cCiuEmi>' + cSalto
	cXml += '				<dDesCiuEmi>' +  AllTrim(ObtColSAT("S012",cCiuEmi, 48, 4, 52,30))+ '</dDesCiuEmi>' + cSalto
	If !Empty(SM0->M0_TEL)
		cXml += '				<dTelEmi>' + AllTrim(SM0->M0_TEL) + '</dTelEmi>' + cSalto
	EndIf
	cXml += '				<dEmailE>' +  ALLTRIM(cEmail)  + '</dEmailE>' + cSalto //Quitar
	cXml += '				<gActEco>' + cSalto
	cXml += '					<cActEco>' + AllTrim(SM0->M0_DSCCNA) + '</cActEco>' + cSalto
	cXml += '					<dDesActEco>'+ ObtColSAT("S006",SUBSTR(SM0->M0_DSCCNA,1,6) , 2, 5, 7,166)+'</dDesActEco>' + cSalto
	cXml += '				</gActEco>' +  cSalto
	cXml += '			</gEmis>' + cSalto
	//RECEPTOR
	SA1->(DbSetOrder(1))
	SA1->(MSSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
	SYA->(DbSetOrder(1))
	SYA->(MsSeek(xFilial("SYA")+SA1->A1_PAIS))

	cXml += '			<gDatRec>' + cSalto
	cXml += '				<iNatRec>'+IIF (!Empty(SA1->A1_CGC),"1","2")+'</iNatRec>' + cSalto
	cXml += '				<iTiOpe>1</iTiOpe>' + cSalto
	cXml += '				<cPaisRec>' + SYA->YA_CODERP + '</cPaisRec>' + cSalto
	cXml += '				<dDesPaisRe>'+ ObtColSAT("S005",SYA->YA_CODERP, 1, 3, 4,52)+'</dDesPaisRe>' +cSalto
	If !Empty(SA1->A1_CGC)
		cXml += '				<iTiContRec>' + IIF(SA1->A1_PESSOA $ "F","1","2") + '</iTiContRec>' + cSalto
		cXml += '				<dRucRec>' +  SUBSTR(SA1->A1_CGC,1,RAT("-",SA1->A1_CGC)-1) + '</dRucRec>' + cSalto
		cXml += '				<dDVRec>' + Substr(SA1->A1_CGC,RAT("-",SA1->A1_CGC)+ 1,1) + '</dDVRec>' + cSalto
	Else
		cXml += '				<iTipIDRec>' + AllTrim(SA1->A1_TIPDOC) + '</iTipIDRec>' + cSalto
		cXml += '				<dDTipIDRec>' +  ObtColSAT("S018", SA1->A1_TIPDOC, 1, 1, 2,41) + '</dDTipIDRec>' + cSalto
		cXml += '				<dNumIDRec>' +  IIF(AllTrim(SA1->A1_TIPDOC)=="5","0",ALLTRIM(SA1->A1_NIF)) + '</dNumIDRec>' +cSalto
	EndIf
	cXml += '				<dNomRec>' + AllTrim(SA1->A1_NOME)+ '</dNomRec>' + cSalto
	cXml += '				<dNomFanRec>' + AllTrim(SA1->A1_NREDUZ)+ '</dNomFanRec>' + cSalto
	cXml += '				<dDirRec>' + AllTrim(SA1->A1_END) + '</dDirRec>' + cSalto
	cXml += '				<dNumCasRec>' + AllTrim(SA1->A1_NUM) + '</dNumCasRec>' + cSalto
	cXml += '				<cDepRec>' + ALLTRIM(SA1->A1_DEPTO) + '</cDepRec>' + cSalto
	cXml += '				<dDesDepRec>' + AllTrim(ObtColSAT("S003",SA1->A1_DEPTO, 1, 2, 3,28)) +'</dDesDepRec>' + cSalto
	cXml += '				<cDisRec>' + ALLTRIM(SA1->A1_DISTR)+ '</cDisRec>' + cSalto
	cXml += '				<dDesDisRec>'+ AllTrim(ObtColSAT("S031",SA1->A1_DISTR, 1, 3, 4,30)) + '</dDesDisRec>' + cSalto
	cXml += '				<cCiuRec>' + AllTrim(SA1->A1_CIUDAD) + '</cCiuRec>' + cSalto
	cXml += '				<dDesCiuRec>' + AllTrim(ObtColSAT("S012",SA1->A1_CIUDAD, 48, 4, 52,30)) + '</dDesCiuRec>' + cSalto
	If !Empty(SA1->A1_TEL)
		cXml += '				<dTelRec>' + AllTrim(SA1->A1_TEL) + '</dTelRec>' + cSalto
	EndIf
	If !Empty(SA1->A1_EMAIL)
		cXml += '				<dEmailRec>' + ALLTRIM(SA1->A1_EMAIL) + '</dEmailRec>' + cSalto
	EndIf
	cXml += '				<dCodCliente>' + AllTrim(SA1->A1_COD) + '</dCodCliente>' + cSalto
	cXml += '			</gDatRec>' + cSalto
	cXml += '		</gDatGralOpe>' + cSalto

	//TIPO DE PRESENCIA
	cXml += '		<gDtipDE>' + cSalto
	cXml += '        	<gCamNCDE>' + cSalto
	cXml += '    			<iMotEmi>' + AllTrim(SF1->F1_TIPREF) + '</iMotEmi>' + cSalto
	cXml += '        		<dDesMotEmi>'+ ObtColSAT("S021",SF1->F1_TIPREF, 1, 1, 2,30)+'</dDesMotEmi>' + cSalto
	cXml += '        	</gCamNCDE>' + cSalto

	cAliasTmp := QueryItems("SD1", "D1_COD, D1_QUANT, D1_TES, D1_ITEM, SD1.R_E_C_N_O_", "D1_DOC='" + SF1->F1_DOC + "' AND D1_SERIE='" + SF1->F1_SERIE + "' AND D1_FORNECE='" + SF1->F1_FORNECE + "' AND D1_LOJA='" + SF1->F1_LOJA + "'",  "D1_ITEM") 
	
	While (cAliasTmp)->(!EOF())
		cXml += '        	<gCamItem>' + cSalto
		cXml += '    			<dCodInt>' + Alltrim((cAliasTmp)->B1_COD) + '</dCodInt>' + cSalto
		cXml += '    			<dDesProSer>' + AllTrim((cAliasTmp)->B1_DESC) + '</dDesProSer>' + cSalto
		cXml += '    			<cUniMed>' + AllTrim((cAliasTmp)->AH_COD_CO) + '</cUniMed>' + cSalto
		cXml += '    			<dDesUniMed>' + ObtColSAT("S002",(cAliasTmp)->AH_COD_CO, 1, 3, 29,6) + '</dDesUniMed>' + cSalto
		cXml += '    			<dCantProSer>' + AllTrim(TRANSFORM((cAliasTmp)->D1_QUANT,"9999999999.9999") )+ '</dCantProSer>' + cSalto
		If (cAliasTmp)->R_E_C_N_O_ > 0
			SD1->(dbgoto((cAliasTmp)->R_E_C_N_O_))
		EndIf
		cXml += M486IMPDPAR(ALLTRIM(SF1->F1_ESPECIE),SF1->F1_DOC,SF1->F1_SERIE, SF1->F1_FORNECE,SF1->F1_LOJA, (cAliasTmp)->D1_TES,(cAliasTmp)->D1_ITEM,(cAliasTmp)->D1_COD,@aDesc,@aTotales) + cSalto
		cXml += '        	</gCamItem>' + cSalto
		(cAliasTmp)->(dbSkip())
	End
	(cAliasTmp)->(dbcloseArea())
	cXml += '		</gDtipDE>' + cSalto

	aTotales := M486SUBTOT(ALLTRIM(SF1->F1_ESPECIE),SF1->F1_DOC,SF1->F1_SERIE, SF1->F1_FORNECE,SF1->F1_LOJA)
	cXml += '		<gTotSub>' + cSalto
	cXml += '        	<dSubExe>'+ AllTrim(TRANSFORM(aTotales[1],cPicture))+'</dSubExe>' + cSalto
	cXml += '        	<dSubExo>'+ AllTrim(TRANSFORM(aTotales[2],cPicture))+'</dSubExo>' + cSalto
	cXml += '        	<dSub5>'+ AllTrim(TRANSFORM(aTotales[3],cPicture))+'</dSub5>' + cSalto
	cXml += '        	<dSub10>'+ AllTrim(TRANSFORM(aTotales[4],cPicture))+'</dSub10>' + cSalto
	cXml += '        	<dTotOpe>'+ AllTrim(TRANSFORM(aTotales[5],cPicture))+'</dTotOpe>' + cSalto
	cXml += '        	<dTotDesc>'+ AllTrim(TRANSFORM(aDesc[1],cPicture))+'</dTotDesc>' + cSalto
	cXml += '        	<dTotDescGlotem>'+ AllTrim(TRANSFORM(aTotales[6],cPicture))+'</dTotDescGlotem>' + cSalto
	cXml += '        	<dTotAntItem>0</dTotAntItem>' + cSalto
	cXml += '        	<dTotAnt>0</dTotAnt>' + cSalto
	cXml += '        	<dPorcDescTotal>0</dPorcDescTotal>' + cSalto
	cXml += '        	<dDescTotal>'+ AllTrim(TRANSFORM(aDesc[1],cPicture))+'</dDescTotal>' + cSalto
	cXml += '        	<dAnticipo>0</dAnticipo>' + cSalto
	cXml += '        	<dRedon>0.0</dRedon>' + cSalto
	cXml += '        	<dTotGralOpe>'+ AllTrim(TRANSFORM(SF1->F1_VALBRUT,cPicture))+'</dTotGralOpe>' + cSalto
	cXml += '        	<dIVA5>'+ AllTrim(TRANSFORM(aTotales[7],cPicture))+'</dIVA5>' + cSalto
	cXml += '        	<dIVA10>'+ AllTrim(TRANSFORM(aTotales[8],cPicture))+'</dIVA10>' + cSalto
	cXml += '        	<dTotIVA>'+ AllTrim(TRANSFORM(aTotales[9],cPicture))+'</dTotIVA>' + cSalto
	cXml += '        	<dBaseGrav5>'+ AllTrim(TRANSFORM(aTotales[10],cPicture))+'</dBaseGrav5>' + cSalto
	cXml += '			<dBaseGrav10>'+ AllTrim(TRANSFORM(aTotales[11],cPicture))+'</dBaseGrav10>' + cSalto
	cXml += '			<dTBasGraIVA>'+ AllTrim(TRANSFORM(aTotales[12],cPicture))+'</dTBasGraIVA>' + cSalto
	If AllTrim(STR(SF1->F1_MOEDA)) <> "1"
		cXml += '			<dTotalGs>'+ AllTrim(TRANSFORM(SF1->F1_VALBRUT*SF1->F1_TXMOEDA,cPicture))+'</dTotalGs>' + cSalto
	EndIf
	cXml += '		</gTotSub>' +cSalto
	
	//DOCUMENTO ASOCIADO
	cXml += '		<gCamDEAsoc>' + cSalto
	cXml += M486ASOC(SF1->F1_ESPECIE,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,"1",.T.) + cSalto
	cXml += '		</gCamDEAsoc>' + cSalto
	cXml += '	</DE>' + cSalto
	cXml += '</rDE>' + cSalto

	If ExistBlock("M486PEEXML")
		cXML	:= ExecBlock("M486PEEXML",.F.,.F.,{SF1->F1_FILIAL, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_DOC, SF1->F1_ESPECIE, cXml})
	EndIf
	
	cXml := ENCODEUTF8(cXml)

	fWriteLocal(cXml, cRuta, cXMLFile + ".xml", 1)

	RestArea(aSF)
	RestArea(aArea)

	If File(cRuta+cXMLFile+".xml")
		lRet := .T.
	EndIf


Return lRet


/*/{Protheus.doc} QueryItems
Se genera un query para obetener los datos correspondientes a los items.
@author raul.medina
@param cAlias, caracter, Alias de la tabla.
@param cCpos, caracter, Capos a ser usados en el query.
@param cWhere, caracter, Condición a ser usada en el query.
@param cOrder, caracter, Campo a ser usado en el orden,
@return cAliasTmp, Alias de la tabla temporal.
/*/
Static Function QueryItems(cAlias, cCpos, cWhere, cOrder)
Local cQuery 	:= ""
Local cAliasTmp	:= getNextAlias()

	cQuery := "Select "
	cQuery += cCpos
	cQuery += " ,B1_COD, B1_DESC, B1_UM, AH_COD_CO" 
	cQuery += " from "+RetSqlName(cAlias)+ " " + cAlias + " "
	cQuery += " Left Join " +RetSqlName("SB1")+ " SB1 ON " + IIf(cAlias == "SD2","D2_COD","D1_COD") + " = B1_COD AND B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += " Left Join " +RetSqlName("SAH")+ " SAH ON B1_UM = AH_UNIMED AND AH_FILIAL = '" + xFilial("SAH") + "'"
	cQuery += " Where "
	cQuery += cWhere
	cQuery += " AND " + cAlias + ".D_E_L_E_T_ = ''"
	cQuery += " AND SB1.D_E_L_E_T_ = ''"
	cQuery += " AND SAH.D_E_L_E_T_ = ''"
	If !Empty(cOrder)
		cQuery += " ORDER BY "+ SqlOrder(cOrder)
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	(cAliasTmp)->(dbGoTop())

Return cAliasTmp

/*/{Protheus.doc} ImpTES
Se valida sin la TES tiene impuestos.
@author adrian.perez
@param cTESD, caracter, campo de la TES en la tabla SD1/SD2
@param cClieSD, caracter, campo deL CLIENTE en la tabla SD1/SD2
@param cEspecie, caracter, especie del documento.
@param cDoc, caracter,numero del documento,
@param  cSerie,caracter,Serie del documento.
@param  cCliente,caracter,codigo del cliente usado.
@param  cLoja,caracter,codigo del tienda usado.
@return lImpTes,booleano,.T. si la tes cuenta con impuestos .F. si la TES no cuenta con impuestos.
/*/
Static Function ImpTES(cTESD,cClieSD,cEspecie,cDoc,cSerie,cCliente,cLoja)

	Local cSF4    := GetNextAlias()
	Local cSD    := GetNextAlias()
	Local aArea       := GetArea() 
	Local nReg:=0
	Local lImpTes:=.F.
	Local cTabla:=''
	Local cTes
	Local cWhere:=''
	Local nConIVA:=0

	DEFAULT cTESD:=cClieSD:=cEspecie:=cDoc:=cSerie:=cCliente:=cLoja:=""

	If "1" $cTESD
		cTabla:='D1'
	ELSE
		cTabla:='D2'
	ENDIF

	cWhere+="%TABLA."+cTabla+"_FILIAL ='"+XFILIAL("S"+cTabla)+"' AND "
	cWhere+="TABLA."+cTabla+"_DOC ='"+cDoc+"'  AND " 
	cWhere+="TABLA."+cTabla+"_SERIE ='"+cSerie+"' AND "
	cWhere+="TABLA."+cClieSD+" ='"+cCliente+"' AND "
	cWhere+="TABLA."+cTabla+"_LOJA = '"+cLoja+"' AND "
	cWhere+="TABLA.D_E_L_E_T_ <> '*'%"
	cTabla:= "%"+ RetSqlName("S"+cTabla) +"%"
	cTESD:= "%TABLA."+cTESD+"%"
	BeginSQL Alias cSD
		SELECT
		%Exp:cTESD% TES
		FROM %Exp:cTabla% TABLA
		WHERE 
		%Exp:cWhere% 
	EndSQL
	Count to nReg
	If nReg > 0
		(cSD)->(dbGoTop())
		While (cSD)->(!EoF())
			cTes=(cSD)->(TES)
			(cSD)->(DbSkip())
		EndDo
		(cSD)->(dbCloseArea())

		BeginSQL Alias cSF4
			SELECT
			SF4.F4_CODIGO COD,SFC.FC_IMPOSTO IMP
			FROM %Table:SF4% SF4
			JOIN %Table:SFC% SFC on SFC.FC_TES= SF4.F4_CODIGO
			WHERE 
			SF4.F4_FILIAL= %xfilial:SF4% AND
			SFC.FC_FILIAL= %xfilial:SFC% AND
			SF4.F4_CODIGO=%Exp:cTes%
			AND SF4.%NotDel%
			AND SFC.%NotDel%
		
		EndSQL

		Count to nReg
		
		If nReg > 0
			
			(cSF4)->(DbGoTop())
			While (cSF4)->(!EoF())
			IF "IV" $(cSF4)->(IMP)
				nConIVA++
			ENDIF
			(cSF4)->(DbSkip())
			EndDo
			(cSF4)->(dbCloseArea())

			IF nConIVA >0
				lImpTes:=.T.
			ENDIF

		ENDIF
	ENDIF
	RestArea(aArea)
Return lImpTes


/*/{Protheus.docn NEWFOLDER
    Sirve para crear carpetas
    @type  Static Function
    @author adrian.perez
    @since 07/07/2022
    @param cPath, carácter, ruta donde se creará la carpeta
    @param cFolder, carácter, nombre de la carpeta a crear
    @return cFolder,carácter, nombre de la carpeta creada
/*/

Static Function NEWFOLDER(cPath,cFolder)
	
	Local cFolNew:= ""
	Local lRet:=.T.
	DEFAULT cPath:=""
	DEFAULT cFolder:=""

	cFolNew:=cPath+cFolder
	IF  !ExistDir( cFolNew )
		IF (MakeDir( cFolNew ))!=0
			lRet:=.F.
			Help(STR0385,1,STR0385 , NIL,STR0377+ " "+cFolNew, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0405})
		ENDIF
	ENDIF
	
Return lRet

/*/{Protheus.doc} GETXMLMIX
    Lee todos los xml de la carpeta indicada y los mezcla en un solo xml(xml lote)
    @type  Static Function
    @author adrian.perez
    @since 09/07/2022
    @param cDir, carácter, carpeta a leer
    @return cXML, carácter, una cadena de caracteres que contiene los datos de todos los XML dentro del directorio leído
/*/
Static Function GETXMLMIX(cDir)
Local aFiles := {}
local nCount:=0
Local nX:=0
Local cXML := ""
	
DEFAULT cDir:=""

	IF  ExistDir( cDir )
		nCount:=ADir( cDir+"\*.*",aFiles)
		
		FOR nX := 1 to nCount

			IF AT(".XML",UPPER(aFiles[nX]))>0
				cXML+=LEEXML(cDir+"\"+aFiles[nX])
				FERASE(cDir+"\"+aFiles[nX]) 
			ENDIF
			
		NEXT nX
		
	ENDIF	
Return cXML

/*/{Protheus.doc} LEEXML
	Extrae el contenido de un archivo XML para retornar en forma de cadena
	@type  Static Function
	@author adrian.perez
	@since 09/07/2022
	@param cArchivo, carácter, archivo xml a leer
	@return cXML, carácter, contenido del XML
/*/
Static Function LEEXML(cArchivo)
	Local aInforma	:= {} 
	Local cXML:=""
	DEFAULT cArchivo:=""
	
	If File(cArchivo)
		oFile := ZFWReadTXT():New(cArchivo,,_BUFFER)
		If oFile:Open()

			While oFile:ReadArray(@aInforma,_SEPARADOR)
				cXML+=aInforma[1]+_SALTO
				aSize(aInforma,0)
			EndDo
			
			oFile:Close()	
		EndIf 
	ENDIF

Return cXML


/*/{Protheus.doc} M486FILPAR 
Función para llamar los parámetros y filtrar los rangos de los documentos a visualizar(MONITOR)en caso de ser necesario
se puede usar sin visualizar la pantalla de parámetros
@type function
@author adrian.perez
@since 11/07/2022
@version 1.0
@param lAut, booleano, (Si es .T. no se muestra la pantalla de parámetros, .F.  muestra la pantalla para informar parámetros)
@param aPar, arreglo, (Solo se usa cuando lAut es .T. ) se reciben los parametros del filtrado al usar este parámetro no muestra
la pantalla de filtrado
@return nil, nil, nil
/*/
Function M486FILPAR(lAut)
Local cDocIni	:= ''
Local cDocFin	:= ''
Local cDocSer	:= ''
Local aDocs		:={}
Default lAut	:= .F.
	
	If !lAut
		If Pergunte(cPergFac, .T.)
			cDocSer 	:= MV_PAR01
			cDocIni 	:= MV_PAR02
			cDocFin 	:= MV_PAR03
			Processa({|lEnd| aDocs := M486INFGET(cDocSer,cDocIni,cDocFin)}, STR0103) // "Obteniendo Información"
		EndIf
	EndIF

	If LEN(aDocs)>0
		M486MONPAR(aDocs)// Abre monitor con parámetros dados.
	ELSE

		Help(STR0385,1,STR0385 , NIL,STR0386, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0387}) // "Transmisión asíncrona" //"No existen lotes en proceso con el rango y serie informados" //"Verificar rango y serie."
	
	ENDIF

Return NIL

/*/{Protheus.doc} M486MONPAR
Muestra pantalla gráfica del monitor 
@type function
@author adrian.perez
@since 10/07/2022
@param aDocs, array, (Array original con los datos de los documentos a consultar)
@return nil, nil, nil
/*/
Function M486MONPAR(aDocs)

Local oDlg, oList, oButton0, oButton2
Local aItems:= {}
DEFAULT aDocs:={} 

	If LEN(aDocs)>0
		aItems:=aDocs
		
		DEFINE MSDIALOG oDlg FROM 0,0 TO 347,958 PIXEL TITLE STR0051 //Monitor
				
		@ 01,01 LISTBOX oList FIELDS;
		HEADER "",STR0200, STR0060  ,STR0204+"/"+ STR0083 ,STR0378, STR0379 , STR0381  ; //"","Serie", "N. Documento" , "Cliente/Proveedor" ,"Lote Interno", "Lote SIFEN" , "Estatus SIFEN"  
		SIZE 480,130 OF oDlg PIXEL			

		oList:SetArray(aItems)
		If len(aItems) > 0
				//"Documento:"						//"Lote interno: "					 //"Lote SIFEN: "					//Código respuesta:
			oList:bLine := {|| {GetStatus(VAL(aItems[oList:nAt,7])),aItems[oList:nAt,2],aItems[oList:nAt,3],aItems[oList:nAt,4],aItems[oList:nAt,8],aItems[oList:nAt,9],aItems[oList:nAt,10]}} 	//aItems[oList:nAt,11]		
		EndIf
		
		oButton0 := TButton():New(140, 338,STR0382,oDlg,{||Processa({|| SITLOTSIFEN(ALLTRIM(aItems[oList:nAt,9]),ALLTRIM(aItems[oList:nAt,8]),ALLTRIM(aItems[oList:nAt,7]),@aItems)}, STR0383)},46,17,,,,.T.) //Consultar  "Consultando..."
		oButton1 := TButton():New(140, 390,STR0384,oDlg,{||M486XDET(aItems[oList:nAt,11],(STR0346 +aItems[oList:nAt,3] +_SALTO+STR0378+" "+aItems[oList:nAt,8]+_SALTO+STR0379+" "+aItems[oList:nAt,9] +_SALTO+STR0380+aItems[oList:nAt,12]+_SALTO))},46,17,,,,.T.) //Detalle	
		oButton2 := TButton():New(140, 442,STR0105,oDlg,{||oDlg:End()},33,17,,,,.T.) //"Salir"
						
		ACTIVATE MSDIALOG oDlg CENTERED

	
	ENDIF

Return nil

/*/{Protheus.doc} M486XDET
Muestra detalla del documento es útil cuando existen varios errores en el documento
@type function
@author adrian.perez
@since 15/07/2022
@param cDoc, carácter, número documento
@param cObs, carácter,  observaciones del documento (pueden venir varias separadas por coma)
@param cExtra, carácter,  comentarios adicionales
@return nil, nulo, retorno nulo
/*/
Static Function M486XDET(cObs,cExtra)

Local oDlg,oButton2
Local aDat:={}
Local cAux:=""
Local nA:=0

DEFAULT cObs:=""
DEFAULT cExtra:=""

	cAux:=cExtra
	IF   AT( ",", cObs ) 
		aDat:=StrTokArr(cObs,"," )
		FOR nA:= 1 to LEN (aDat)
			cAux+=CVALTOCHAR(nA)+".-"+aDat[nA]+"."+_SALTO
		NEXT nA
	ELSE
		cAux+=cObs
	ENDIF

	DEFINE MSDIALOG oDlg FROM 0,0 TO 347,458 PIXEL TITLE STR0051 //Monitor
	oFont := TFont():New('Courier new',,-11,.T.)
	oSay:= TSay():New(01,01,{|| '' },oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,350)
	oSay:CtrlRefresh()
	oSay:SetText( cAux )
	oSay:SetTextAlign( 0, 0 )
	oSay:lTransparent = .T.
	oSay:lWordWrap = .F.
	oButton2 := TButton():New(140, 442,STR0105,oDlg,{||oDlg:End()},33,17,,,,.T.) //"Salir"
					
	ACTIVATE MSDIALOG oDlg CENTERED

Return nil

/*/{Protheus.doc} M486INFGET
Consulta información sobre los documentos contenidos en el rango datos
@type function
@author adrian.perez
@since 10/07/2022
@version 1.0
@param cSerie, carácter, Serie de los documentos
@param cFacIn, carácter, Número inicial
@param cFacFi, carácter, número final
@return aRet, arreglo, información de los documentos

/*/
Static function M486INFGET(cSerie,cFacIn,cFacFi)

Local aArea    := getArea()
Local cTempF   :=getNextAlias()
Local aDocs:={}
Local nCount:=0
DEFAULT cSerie:=""
DEFAULT cFacIn:=""
DEFAULT cFacFi:=""

	If nTipoDoc == 0 
		cQuery := "SELECT F1_FILIAL FILIAL,F1_FORNECE CLIFOR, F1_LOJA TIENDA, F1_DOC DOC, F1_SERIE SERIE "
		cQuery+= " ,F1_LOTEASY loteinterno " 	
		cQuery += ", F1_FLFTEX STATUS, F1_UUID UUID "
		cQuery+= " ,AQ2_CODRES, AQ2_NUMSIF loteSIFEN, AQ2_STARES statusSIFEN , AQ3_OBSDOC  OBS, AQ3_CODRES CODRESDOC"
		
		cQuery += " FROM "+RetSqlName("SF1")+" SF1 "
		cQuery += " INNER JOIN "+RetSqlName("AQ2")+" AQ2 ON SF1.F1_LOTEASY = AQ2_NUMLOT "
		cQuery+= "  INNER JOIN "+RetSqlName("AQ3")+" AQ3 ON F1_DOC=AQ3_NUMDOC AND F1_ESPECIE=AQ3_SPECIE AND F1_SERIE= AQ3_SERIE AND F1_FORNECE= AQ3_CLIENT AND F1_LOJA= AQ3_LOJA AND AQ2_NUMLOT= AQ3_NUMLOT AND AQ2_ESPLOT= AQ3_SPECIE "

		cQuery += " WHERE F1_SERIE = '" + cSerie + "' AND F1_ESPECIE = '" + cEspecie + "' AND F1_DOC BETWEEN '" + cFacIn + "' AND '" + cFacFi +"'"
		cQuery += " AND SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cQuery += " AND AQ2.AQ2_FILIAL = '" + xFilial("AQ2") + "'"
		cQuery += " AND AQ3.AQ3_FILIAL = '" + xFilial("AQ3") + "'"
		cQuery +="  AND NOT F1_LOTEASY='' "
		cQuery += " AND SF1.D_E_L_E_T_ = '' "
		cQuery +="  AND AQ2.D_E_L_E_T_='' "
		cQuery +="  AND AQ3.D_E_L_E_T_='' "
	Else
		cQuery := "SELECT F2_FILIAL FILIAL, F2_CLIENTE CLIFOR, F2_LOJA TIENDA, F2_DOC DOC, F2_SERIE SERIE "
		cQuery+= " ,F2_LOTEASY loteinterno " 
		cQuery += ", F2_FLFTEX STATUS, F2_UUID UUID "
		cQuery+= " ,AQ2_CODRES, AQ2_NUMSIF loteSIFEN, AQ2_STARES statusSIFEN , AQ3_OBSDOC  OBS, AQ3_CODRES CODRESDOC"
		cQuery += " FROM "+RetSqlName("SF2")+" SF2 "
		cQuery += " INNER JOIN  "+RetSqlName("AQ2")+" AQ2 ON SF2.F2_LOTEASY = AQ2_NUMLOT "
		cQuery+= "  INNER JOIN  "+RetSqlName("AQ3")+" AQ3 ON F2_DOC=AQ3_NUMDOC AND F2_ESPECIE=AQ3_SPECIE AND F2_SERIE= AQ3_SERIE AND F2_CLIENTE= AQ3_CLIENT AND F2_LOJA= AQ3_LOJA AND AQ2_NUMLOT= AQ3_NUMLOT AND AQ2_ESPLOT= AQ3_SPECIE "
		cQuery += " WHERE F2_SERIE = '" + cSerie + "' AND F2_ESPECIE = '" + cEspecie + "' AND F2_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"'"
		cQuery += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cQuery += " AND AQ2.AQ2_FILIAL = '" + xFilial("AQ2") + "'"
		cQuery += " AND AQ3.AQ3_FILIAL = '" + xFilial("AQ3") + "'"
		cQuery +="  AND NOT F2_LOTEASY='' "
		cQuery += " AND  SF2.D_E_L_E_T_ = '' "
		cQuery +="  AND AQ2.D_E_L_E_T_='' "
		cQuery +="  AND AQ3.D_E_L_E_T_='' "

	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	count to nCount
	IF nCount>0
		(cTempF)->(dbGoTop())
		While (!(cTempF)->(EOF()))
			aAdd(aDocs, {(cTempF)->FILIAL,(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, (cTempF)->UUID,(cTempF)->STATUS,(cTempF)->loteinterno,(cTempF)->loteSIFEN,(cTempF)->statusSIFEN,(cTempF)->OBS,(cTempF)->CODRESDOC  })
			(cTempF)->(dbSkip())
		EndDo
		(cTempF)->(dbcloseArea())
	ENDIF

	RestArea(aArea)
	
	
Return aDocs

/*/{Protheus.doc} GetStatus
Muestra el color del estatus del documento en la pantalla del MONITOR
@type function
@author adrian.perez
@since 15/07/2022
@param nStatus, numérico, estatus del documento
@return oStatus, objeto, regresa el objeto bitmap al color que corresponde
/*/

Static Function GetStatus(nStatus)
	Local oStatus
	DEFAULT nStatus:=0
	If nStatus == 0
		oStatus := LoadBitmap(GetResources(), "BR_CINZA")  //Sin enviar
	ElseIf nStatus == 4 .or. nStatus == 2
		oStatus := LoadBitmap(GetResources(), "BR_AMARELO") //Aguardando procesamiento
	ElseIf nStatus == 5 .or. nStatus == 3
		oStatus := LoadBitmap(GetResources(), "BR_VERMELHO") //Documento rechazado
	ElseIf nStatus == 6
		oStatus := LoadBitmap(GetResources(), "BR_VERDE") //Autorizado
	EndIf
Return oStatus

/*/{Protheus.doc} VeriLoteOut
Verifica el estatus del LOTE después del envió
@type function
@author adrian.perez
@since 08/07/2022
@param cRuta, carácter, Ruta del archivo para lectura
@param cNomArc, carácter, Nombre del archivo .out
@param cMsg, carácter, Variable para informar la respuesta 
@param cTipo, carácter, T- Transmisión, CA - Cancelación
@param aError, array, Arreglo usado para guardar los errores
@param aDocs, array, Arreglo que contiene la información del documento en proceso de validación
@param aTrans, array, Arreglo usado para guardar las transmisiones
@param cStatus, caracter, Variable usada para retornar el status del proceso
@param cLoteInt, caracter, Número de lote interno
@return aRet, arreglo, datos del lote enviado
/*/

Static Function VeriLoteOut(cRuta, cNomArc, cMsg, cTipo, aError, aDocs, aTrans, cStatus,cLoteInt )
                        
Local lRet 		:= .F.
Local oXML
Local cArchiOUT	:= cRuta+ cNomArc + ".xml.out"
Local cXML     	:= ""
Local cError	:= ""
Local cDetalle	:= ""
Local cCRLF		:= (chr(13)+chr(10))
Local cCodigo	:= ""
Local cDescrip	:= ""
Local cLoteSIFEN:=""
Local aRet:={}
Local nA:=0
Local nLen:=0

DEFAULT cRuta:=cNomArc:=cMsg:=cTipo:=cStatus:=cLoteInt:=""
DEFAULT aError:= aDocs:= aTrans:={}

	Aadd(aRet,lRet )// 1 .T.
	Aadd(aRet,"0")//2 codigo
	Aadd(aRet,"0")//3 Lote SIFEN
	Aadd(aRet,"0")//4 Descripción del estatus del lote
	Aadd(aRet,"0")//5 Lote Int
	Aadd(aRet, "0")//6 OBSERVACIONES

	oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )
	
	If valType(oXml) == "O"
		SAVE oXml XMLSTRING cXML
		If AT( "<ERROR" , Upper(cXML) ) > 0 .and. AT( "<TEXT" , Upper(cXML) ) > 0
			If ValType(oXml:_ERROR:_TEXT) == "O"
				cStatus		:= "X"
				cCodigo := STR0333
				cDescrip := oXml:_ERROR:_TEXT:TEXT
				nLen:=Len(aDocs)
				
				FOR nA := 1 To nLen

					IF aDocs[nA,7] == cLoteInt 
									 //aDoc,  cEspecie, cFatura, cSerie, cCodigo, cLoja, cTipo, cLote
						aAdd(aError, {aDocs[nA,1],aDocs[nA,2],aDocs[nA,3], aDocs[nA,4], cLoteInt +" "+ cCodigo +" "+ ALLTRIM(cDescrip)}) //Lote:

					ENDIF
				NEXT nA
				
			EndIf
		Else
			If cTipo == "T"
				If AT( "<NS2:DCODRES" , Upper(cXML) ) > 0 
					
					cCodigo:=ALLTRIM ( oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVILOTEDE:_NS2_DCODRES:TEXT)
					cDescrip := ALLTRIM(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVILOTEDE:_NS2_DMSGRES:TEXT)
					nLen:=Len(aDocs)
					If cCodigo=="0300" //Lote recibido en SIFEN
						
						If AT( "<NS2:DPROTCONSLOTE" , Upper(cXML) ) > 0 
							cLoteSIFEN:=ALLTRIM(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVILOTEDE:_NS2_DPROTCONSLOTE:TEXT)
						ENDIF

						cMsg += cCRLF
						cMsg += cNomArc
						cMsg += cCRLF
						cMsg += cLoteSIFEN
						cMsg += cCRLF
						cMsg += STR0336 + cDescrip
						lRet 		:= .T.
						
						FOR nA := 1 To nLen

							IF aDocs[nA,7] == cLoteInt 
									 //aDoc,  cEspecie, cFatura, cSerie, cCodigo, cLoja, cTipo, cLote
							aAdd(aTrans, {aDocs[nA,1],aDocs[nA,2],aDocs[nA,3], aDocs[nA,4], cLoteSIFEN +" "+ ALLTRIM(cDescrip)}) //Lote:

							ENDIF
						NEXT nA
						
						aSize(aRet,0)
						Aadd(aRet,lRet )// 1 .T.
						Aadd(aRet,cCodigo)//2 codigo
						Aadd(aRet,cLoteSIFEN)//3 Lote SIFEN
						Aadd(aRet,cDescrip)//4 Descripción del estatus del lote
						Aadd(aRet,cLoteInt)//5 Lote Int
						Aadd(aRet, "")//6 OBSERVACIONES
						
					EndIf
					aError:=aTrans // deben coincidir en ala mata486 tomo como transmisión exitosa que ambos arreglos tenga el mismo tamaño
										
				EndIf
			EndIf
		EndIf
	
	Endif
Return aRet

/*/{Protheus.doc} ActDocLote
	// una vez que fue enviado el lote se actualiza la tabla relacionado a los lotes 
	// y la tablas de los documentos(SF2,SF1)
	@type  Static Function
	@author adrian.perez
	@since 10/07/2022
	@param aDocs, array, Array con los datos de los documentos a actualizar una vez enviado el LOTE se cambian a esperando procesamiento
	@param cLote, caracter, Número de lote interno
	@param aDatosLote, arreglo, datos del lote enviado
	@return nil, nil, nil
/*/
Static Function ActDocLote(aDocs,cLote,aDatosLote)
	Local nI:=0
	Local cAnt:=""

	DEFAULT aDocs:={}
	DEFAULT cLote:=""
	DEFAULT aDatosLote:={}

	FOR nI := 1 To Len(aDocs)

		IF aDocs[nI,7] == cLote 
						//cEspecie, cFatura,       cSerie,       cCodigo,    cLoja,        cTipo,     cStatus,lDatLote,aDatLote,lInLot,cAnt)
			ActDocum(aDocs[nI][1], aDocs[nI][2], aDocs[nI][3], aDocs[nI][4], aDocs[nI][5], aDocs[nI][6],"4",.T.,aDatosLote,.T.,@cAnt)    
			
		ENDIF

	NEXT nI
Return nil

/*/{Protheus.doc} SITLOTSIFEN
    // Consulta la situación del lote del SIFEN y en caso de haber sido procesado
    // verifica el estatus devuelto para cada documento del lote
    // para actualizar la tablas de los documentos(SF2,SF1) así como las tablas de los LOTES
    @type  Static Function
    @author adrian.perez
    @since 11/07/2022
    @param cLoteSIFEN, carácter, número de lote asignado por SIFEN al realizar el envió del lote
    @param cLoteInterno, carácter, numero de control de lote interno
    @param cStatusInt, caracter, estatus interno del documento (aprobado,rechazado,etc)
    @param aItems, arreglo, datos de las filas del Monitor
    @return nil, nil, nil
/*/
static function SITLOTSIFEN(cLoteSIFEN,cLoteInterno,cStatusInt,aItems)

Local cXML     	:= ""
Local cStatus:= "5"
Local cCodigo := ""
Local cDescrip := ""
Local cArchiOUT:=cError:= cDetalle:=""
Local cTipo:="T" 

Local nX:=0
Local oXmlLote

Local cAmbiente:=""  
Local cRutaSMR	:="" 
Local cSIFEEXE :="" 
Local cPathDocSave:="" 
Local cCertificado:="" 
Local cPassCert:="" 
Local cIDENV:=""
Local cIDPASCLI:=""
Local cPASCLI	:="" 
Local cTIPTRAN :="" 
Local cPathExe:=""
Local lProc:=.F.
Local nPos:=""
Local nEnvio:=0
Local nTotEnv:=0
Local cMainlote:=""
DEFAULT cLoteSIFEN:=cLoteInterno:=""
DEFAULT cStatusInt:="5"
DEFAULT aItems:={}

	CURSORWAIT()
	If cStatusInt <>"5" .and. cStatusInt<>"6"
		
		lProc:=getParamExe(@cAmbiente,@cRutaSMR,@cSIFEEXE,@cPathDocSave,@cCertificado,@cPassCert,@cIDENV,@cIDPASCLI,@cPASCLI,@cTIPTRAN,@cPathExe,@cMainlote)
		IF lProc
			
			EXE(cAmbiente,cRutaSMR,cSIFEEXE,cPathDocSave,cCertificado,cPassCert,cIDENV,cIDPASCLI,cPASCLI,"CONSULTA",cPathExe,cTipo,cLoteInterno+"c" ,cLoteInterno,cLoteSIFEN)	

			If File(cRUTASMR + cLoteInterno + 'c.xml.out')
				
				CpyT2S(cRutaSMR +cLoteInterno+ 'c.xml.out' ,cPathDocSave+"\"+cMainlote+"\")
				Ferase( cRutaSMR +cLoteInterno+ 'c.xml.out')
				cArchiOUT:=cPathDocSave+"\"+cMainlote+"\"+cLoteInterno+ 'c.xml.out'
				
				/*LEER .OUT*/
				oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )
				If valType(oXml) == "O"
					SAVE oXml XMLSTRING cXML
					If AT( "<ERROR" , Upper(cXML) ) > 0 .and. AT( "<TEXT" , Upper(cXML) ) > 0
						If ValType(oXml:_ERROR:_TEXT) == "O"
							cStatus		:= "X"
							cCodigo := STR0333
							cDescrip := oXml:_ERROR:_TEXT:TEXT
							Help(STR0385,1,STR0385 , NIL,cCodigo+" "+cDescrip, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0391})
						EndIf
					Else
						If cTipo == "T"
							If AT( "<NS2:DCODRESLOT" , Upper(cXML) ) > 0 
								cStatusLote:=  oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVICONSLOTEDE:_NS2_DMSGRESLOT:TEXT
								IF ALLTRIM ( oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVICONSLOTEDE:_NS2_DCODRESLOT:TEXT)=="0362"

									oXmlLote:=oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVICONSLOTEDE:_NS2_GRESPROCLOTE
									
									IF VALTYPE(oXmlLote)=="O" // un solo documento
										nTotEnv:=  1
										ProcRegua(nTotEnv)
										If oXmlLote:_NS2_GRESPROC:_NS2_DCODRES:TEXT == "0260"
											cStatus		:= "6"
										ENDIF
											
										cCodigo :=  oXmlLote:_NS2_GRESPROC:_NS2_DCODRES:TEXT 
										cDescrip := oXmlLote:_NS2_GRESPROC:_NS2_DMSGRES:TEXT //cuando hay varios errores SIFEN regresa separado por coma
										nEnvio++
										IncProc(STR0404+":" + cValToChar(nEnvio) + STR0403 + cValToChar(nTotEnv) + "...")
										ActDocUUID( oXmlLote:_NS2_ID:TEXT,cStatus,{.T.,cCodigo,cLoteSIFEN,cStatusLote,cLoteInterno,cDescrip},cPathDocSave)
										nPos:=Ascan(aItems,{ |x| x[6] == oXmlLote:_NS2_ID:TEXT} )//obtener posición de UUID
										aItems[nPos,7]:=cStatus
										aItems[nPos,10]:=cStatusLote
										aItems[nPos,11]:=cDescrip
										aItems[nPos,12]:=cCodigo
										
									ENDIF
									IF VALTYPE(oXmlLote)=="A"// varios documentos en el lote
										nTotEnv:=  LEN(oXmlLote)
										ProcRegua(nTotEnv)
										FOR nX:=1 to LEN(oXmlLote) // obtener inforación de los documentos del lote

											If oXmlLote[nX]:_NS2_GRESPROC:_NS2_DCODRES:TEXT == "0260"
												cStatus		:= "6"
											Else
												cStatus:= "5"
											ENDIF
											
											cCodigo :=  oXmlLote[nX]:_NS2_GRESPROC:_NS2_DCODRES:TEXT 
											cDescrip := oXmlLote[nX]:_NS2_GRESPROC:_NS2_DMSGRES:TEXT //cuando hay varios errores se separa por coma
											nEnvio++
											IncProc(STR0404+":" + cValToChar(nEnvio) + STR0403 + cValToChar(nTotEnv) + "...")
											ActDocUUID( oXmlLote[nX]:_NS2_ID:TEXT,cStatus,{.T.,cCodigo,cLoteSIFEN,cStatusLote,cLoteInterno,cDescrip},cPathDocSave)
											nPos:=Ascan(aItems,{ |x| x[6] == oXmlLote[nX]:_NS2_ID:TEXT } )//obtener posición de UUID
											aItems[nPos,7]:=cStatus
											aItems[nPos,10]:=cStatusLote
											aItems[nPos,11]:=cDescrip
											aItems[nPos,12]:=cCodigo
											
										NEXT nX

									ENDIF
									DirRemove( (&(SuperGetMV("MV_CFDDOCS",,"")) )+cMainlote+"\"+cLoteInterno+"\" )
								ELSE
									cCodigo:=	ALLTRIM (oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVICONSLOTEDE:_NS2_DCODRESLOT:TEXT)
									cDescrip:=   ALLTRIM(oXml:_ENV_ENVELOPE:_ENV_BODY:_NS2_RRESENVICONSLOTEDE:_NS2_DMSGRESLOT:TEXT) 
									Help(STR0385,1,STR0385 , NIL,cCodigo+" "+cDescrip, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0392})
								ENDIF
							EndIf
							
						EndIf
					EndIf
				
				Endif
				/*FIN LEER .OUT*/
				
			ENDIF
		ENDIF

	ELSE
	
		Help(STR0385,1,STR0385 , NIL,STR0393+" "+IIF(ALLTRIM(cStatusInt)=="5",STR0395,STR0396), 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0394}) //STR0395 "rechazado"  STR0396 "aprobado"
	EndIf	
	CURSORARROW()

Return nil


/*/{Protheus.doc} ejecutarExe
	Ejecuta el SIFENWS.EXE
	@type  Static Function
	@author adrian.perez
	@since 10/07/2022
	@param  cAmbiente   ,   carácter    , Indica si el ambiente es T-Teste o P-Produccion
    @param  cRutaSMR    ,   carácter    , ruta donde reside el cliente de WS  GetClientDir() en este caso el SMARTCLIENT
    @param  cSIFEEXE    ,   carácter    , Nombre del ejecutable del servicio web a utilizar.
    @param  cPathDocSave    ,   carácter    , Ruta donde se guardan los XML
    @param  cCertificado    ,   carácter    ,Archivo certificado pfx
    @param  cPassCert   ,   carácter    , Contraseña del certificado digital para firmado de los XML y comunicación con el SIFEN
    @param  cIDENV  ,   carácter    ,    Identificador control de envío Factura electrónica (consecutivo interno).
    @param  cIDPASCLI   ,   carácter    , Identificador del código secreto del contribuyente.
    @param  cPASCLI ,   carácter    ,    Código secreto del contribuyente.
    @param  cTIPTRAN    ,   carácter    , Tipo de transmisión(A=asincrona,S=sincrona,ZIP= Indica que solo firme y comprima sin enviar) 
    @param  cPathExe    ,   carácter    , Ruta completa del ejecutable 
	@param  cTipo    ,   carácter    , acción a realizar (T:= transmistir C:= cancelar) para eldocumento 
	@param  cNomArc ,   carácter    ,Nombre del documento a enviar a SIFEN 
	@param  cUUID,		carácter    ,UUID del documento
	@param  cLote,	carácter    ,Nombre del lote
	@param  cMsg,	carácter , mensaje a imprimir para que se ejeucte el waitrun a veces sin el mensaje no se ejecuta
	@return nil, nil, nil
/*/
Static Function EXE(cAmbiente,cRutaSMR,cSIFEEXE,cPathDocSave,cCertificado,cPassCert,cIDENV,cIDPASCLI,cPASCLI,cTIPTRAN,cPathExe,cTipo,cNomArc,cUUID,cLote,cMsg)

Local cParametros 

DEFAULT cAmbiente:="X"
DEFAULT cRutaSMR:="X"
DEFAULT cSIFEEXE:="X"
DEFAULT cPathDocSave:="X"
DEFAULT cCertificado:="X"
DEFAULT cPassCert:="X"
DEFAULT cIDENV:="X"
DEFAULT cIDPASCLI:="X"
DEFAULT cPASCLI:="X"
DEFAULT cTIPTRAN:="X"
DEFAULT cPathExe:="X"
DEFAULT cTipo:="T" //T- Transmisión, CA - Cancelación
DEFAULT cNomArc:="X"
DEFAULT cUUID:="X"
DEFAULT cLote:="X"
DEFAULT cMsg:=STR0397
	
	//Parametros
	cParametros := cRutaSMR	 + " "
	cParametros += cNomArc + '.xml'	 + " "
	cParametros += cCertificado	 + " "
	cParametros += cPassCert	 + " "
	cParametros += cAmbiente	+ " "
	cParametros += cIDENV	+ " "
	cParametros += cIDPASCLI	+ " "
	cParametros += cPASCLI + " "
	cParametros += cTipo + " "
	cParametros += cUUID
	cParametros +=" "+ALLTRIM(cTIPTRAN)// tipo de transmisión(A=asincrona,S=sincrona) PAR
	cParametros +=" "+cLote//nombre del lote 
		
	WAITRUN( cPathExe + cParametros, 1 )// Se ejecuta EXE cuando es síncrono (firma y envía), cuando es asíncrono solo firma
	Conout(cMsg)// se recurre a imprimir este mensaje porque en ocasiones el waitrun no se ejecuta si no hay una ejecución siguiente   		

Return nil


/*/{Protheus.doc} getParamExe
    Obtiene los parámetros para la transmisión FE
    @type  Static Function
    @author adrian.perez
    @since 11/07/2022
    @param  cAmbiente   ,   carácter    , Indica si el ambiente es T-Teste o P-Produccion
    @param  cRutaSMR    ,   carácter    , ruta donde reside el cliente de WS  GetClientDir() en este caso el SMARTCLIENT
    @param  cSIFEEXE    ,   carácter    , Nombre del ejecutable del servicio web a utilizar.
    @param  cPathDocSave    ,   carácter    , Ruta donde se guardan los XML
    @param  cCertificado    ,   carácter    ,Archivo certificado pfx
    @param  cPassCert   ,   carácter    , Contraseña del certificado digital para firmado de los XML y comunicación con el SIFEN
    @param  cIDENV  ,   carácter    ,    Identificador control de envío Factura electrónica (consecutivo interno).
    @param  cIDPASCLI   ,   carácter    , Identificador del código secreto del contribuyente.
    @param  cPASCLI ,   carácter    ,    Código secreto del contribuyente.
    @param  cTIPTRAN    ,   carácter    , Tipo de transmisión(A=asincrona,S=sincrona) 
    @param  cPathExe    ,   carácter    , Ruta completa del ejecutable
	@param  cMainLote    ,   carácter    , Ruta lotes
    @return lProc, booleano, Indica si existe el ejecutable del servicio web a utilizar (SIFENWS.exe).
/*/

Static Function getParamExe(cAmbiente,cRutaSMR,cSIFEEXE,cPathDocSave,cCertificado,cPassCert,cIDENV,cIDPASCLI,cPASCLI,cTIPTRAN,cPathExe,cMainLote)

Local  lProc:=.T.

DEFAULT cAmbiente:=""
DEFAULT cRutaSMR:=""
DEFAULT cSIFEEXE:=""
DEFAULT cPathDocSave:=""
DEFAULT cCertificado:=""
DEFAULT cPassCert:=""
DEFAULT cIDENV:=""
DEFAULT cIDPASCLI:=""
DEFAULT cPASCLI:=""
DEFAULT cTIPTRAN:=""
DEFAULT cPathExe:=""
DEFAULT cMainLote:="lotes"


	cAmbiente := SuperGetMV("MV_CFDI_AM",,"") //Ambiente T-Teste o P-Produccion  
	cRutaSMR	:= &(SuperGetMV("MV_CFDSMAR",,""))//ruta donde reside el cliente de WS  GetClientDir()
	cSIFEEXE :=   SuperGetMV("MV_CFDI_PA",,"") //Nombre del ejecutable del servicio web a utiliza.   
	cPathDocSave := &(SuperGetMV("MV_CFDDOCS",,""))  //Documentos
	cCertificado := SuperGetMV("MV_CFDI_PX",,"") //Archivo certificado pfx
	cPassCert:= SuperGetMV("MV_CFDICVE",,"") // Contraseña del certificado digital para firmado de los XML y comunicación con el SIFEN
	cIDENV:= SuperGetMV("MV_IDCONEN",,"") // Identificador control de envío Factura electrónica.
	cIDPASCLI	:= SuperGetMV("MV_IDCSC",,"") // Identificador del código secreto del contribuyente.
	cPASCLI	:= SuperGetMV("MV_CSC",,"") // Código secreto del contribuyente.
	cTIPTRAN := ALLTRIM(SuperGetMV("MV_TIPTRAN",,"S")) // tipo de transmisión(A=asincrona,S=sincrona) PAR
	cPathExe	:= cRutaSMR + cSIFEEXE+"\"+cSIFEEXE + ".exe " // ejecutable
	cMainLote:="lotes"

	If !( File(cRutaSMR+cSIFEEXE+".exe") ) // si no esta el exe en la raíz del smart 
		
		If !( File(cPathExe) )// checa si existe la carpera SIFENWS
			cMsg := STR0333 + cCRLF //"No fue posible realizar el envio."
			cMsg += STR0334 + cPathExe  //"No se encontró el archivo: "
			 Help(STR0398,1,STR0398 , NIL,cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0399})
			lProc := .F.
		EndIf

	EndIf
	

Return lProc

/*/{Protheus.doc} ActDocUUID
	Actualiza documento de acuerod al UUID 
	@type  Static Function
	@author adrian.perez
	@since 12/07/2022
	@param cUUID, carácter, UUID del documento electrónico 
	@param cStatus, carácter, estatus del documento 
	@param aDat, arreglo, el arreglo contiene datos referente al lote
	@param cPathDocSave, caracter , ruta de guardado de xml
	@return lRet,booleano, indica si se actualizaron registros por la busqueda del UUIID

/*/
Static Function ActDocUUID(cUUID,cStatus,aDat,cPathDocSave)


Local cSFTmp :=getNextAlias() 
Local cCampos:=""
Local cTablas:=""
Local cCond:=""
Local aArea  := GetArea()
Local nCount:=0

DEFAULT aDat:={}
DEFAULT cStatus:=""
DEFAULT cUUID:=""
DEFAULT cPathDocSave:=""

	If AllTrim(cEspecie) $ "NCI|NCC"
		
		cCampos	:= "% F1_UUID UUID,F1_ESPECIE ESPECIE,F1_DOC DOC,F1_SERIE SERIE, F1_FORNECE CLIENTE,F1_LOJA LOJA  %"
		cTablas	:= "% " + RetSqlName("SF1")  +" "+"SF1 "+ " %" 
		cCond	 += "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cCond    += " AND SF1.F1_UUID='"+cUUID+"' "
		cCond	 += " AND SF1.D_E_L_E_T_  = '' %"

	Else
	
		cCampos	:= "% F2_UUID UUID,F2_ESPECIE ESPECIE,F2_DOC DOC,F2_SERIE SERIE, F2_CLIENTE CLIENTE,F2_LOJA LOJA  %"
		cTablas	:= "% " + RetSqlName("SF2")  +" "+"SF2 "+ " %" 
        cCond	 += "% SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cCond    += " AND SF2.F2_UUID='"+cUUID+"' "
		cCond	 += " AND SF2.D_E_L_E_T_  = '' %"

	EndIF

	BEGINSQL ALIAS cSFTmp
		SELECT  %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
	ENDSQL
	count to nCount
	
	IF nCount > 0
		
		(cSFTmp)->(dbGoTop())
		
		While (!(cSFTmp)->(EOF()))
			ActDocum((cSFTmp)->ESPECIE,(cSFTmp)->DOC,(cSFTmp)->SERIE, (cSFTmp)->CLIENTE,(cSFTmp)->LOJA, "T", cStatus,.T.,aDat,.F.,"",cPathDocSave)
			(cSFTmp)->(DBSKIP())
		EndDo
		(cSFTmp)->(dbCloseArea())
	ENDIF
	RestArea(aArea)
Return nil

/*/{Protheus.doc} ULTNDOC
    Regresa el  número máximo de un campo 
    @type  Static Function
    @author adrian.perez
    @since 12/07/2022
    @param cTabla, carácter, UUID del documento electrónico 
    @param cCampo, carácter, estatus del documento 
    @return cNDOC, carácter, numero máximo encontrado
/*/

Static Function ULTNDOC(cTabla,cCampo)

Local cSFTmp :=getNextAlias() 
Local cCampos:=""
Local cTablas:=""
Local aArea  := GetArea()
Local cNDOC:=""
Local nCount:=0

DEFAULT cTabla:="X"
DEFAULT cCampo:="X"

	cCampos	:= "% MAX("+cCampo+") NDOC  %"
	cTablas	:= "% " + RetSqlName(cTabla)  +" "
	cTablas +=" TABLA "+ " WHERE " 
	cTablas +=" TABLA."+cTabla+"_FILIAL = '" + xFilial(cTabla) + "'"
	cTablas +=" AND TABLA.D_E_L_E_T_ =''%" 

	BEGINSQL ALIAS cSFTmp
		SELECT  %exp:cCampos%
		FROM  %exp:cTablas%
	ENDSQL
	count to nCount

	IF nCount > 0
		
		(cSFTmp)->(dbGoTop())
		While (!(cSFTmp)->(EOF()))
			cNDOC:= ALLTRIM((cSFTmp)->NDOC)
			(cSFTmp)->(DBSKIP())
		EndDo

		(cSFTmp)->(dbCloseArea())
	
	ENDIF

	IF cNDOC== ""
		cNDOC:=GetSxeNum(cTabla,cCampo)
	ENDIF
	cNDOC:=Soma1(cNDOC)

	RestArea(aArea)
Return cNDOC

/*/{Protheus.doc} VLDCAMPASY
    Valida los campos referentes a las tablas de transmisión asíncrona
    @type  Static Function
    @author adrian.perez
    @since 18/07/2022
    @param cTIPTRAN, carácter, tipo de transmisión 
	@param cPathDocSave, ,   carácter    ,folder donde se almacenan los xml
	@param cMainLote, ,   carácter    ,folder donde se almacenan los lotes
    @return lRet, booleano, indica si todos los campos existen(.T.)
   
/*/

Static Function VLDCAMPASY(cTIPTRAN,cPathDocSave, cMainLote)
Local lRet:=.F.

DEFAULT cTIPTRAN:=cPathDocSave:=cMainLote:=""

IF cTIPTRAN=="A"
	IF  (AQ2->(ColumnPos("AQ2_FILIAL")) > 0) .AND. (AQ2->(ColumnPos("AQ2_NUMSIF")) > 0) .AND. (AQ2->(ColumnPos("AQ2_NUMLOT")) > 0);
		.AND. (AQ2->(ColumnPos("AQ2_ESPLOT")) > 0) .AND. (AQ2->(ColumnPos("AQ2_CODRES")) > 0) .AND. (AQ2->(ColumnPos("AQ2_STARES")) > 0);
		.AND. (AQ2->(ColumnPos("AQ2_FECENV")) > 0) .AND.  (AQ2->(ColumnPos("AQ2_FECCON")) > 0) 
  
		IF (AQ3->(ColumnPos("AQ3_FILIAL")) > 0) .AND. (AQ3->(ColumnPos("AQ3_NUMLOT")) > 0) .AND. (AQ3->(ColumnPos("AQ3_NUMDOC")) > 0);
		.AND. (AQ3->(ColumnPos("AQ3_SPECIE")) > 0) .AND. (AQ3->(ColumnPos("AQ3_SERIE")) > 0) .AND. (AQ3->(ColumnPos("AQ3_CLIENT")) > 0);
		.AND. (AQ3->(ColumnPos("AQ3_LOJA")) > 0) .AND. (AQ3->(ColumnPos("AQ3_CODRES")) > 0) .AND. (AQ3->(ColumnPos("AQ3_OBSDOC")) > 0);

			IF ( SF1->(ColumnPos("F1_LOTEASY")) > 0) .AND. ( SF2->(ColumnPos("F2_LOTEASY")) > 0)
				
				lRet:=.T.
			
			ENDIF

		ENDIF 

	ENDIF
	IF !lRet
		Help(STR0385,1,STR0385 , NIL,STR0389, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0390}) // STR0389 "Faltan campos "	//STR0390"Verifique campos de las tablas AQ2,AQ3, SF1 y SF2 "
	ENDIF

	IF !NEWFOLDER(cPathDocSave, cMainLote) 
			lRet:=.F.
	ENDIF


ELSE
	lRet:=.T.
ENDIF

Return lRet



