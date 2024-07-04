#include 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "MATA486.CH"

Static _a_DatDoc := {}	// Array de retorno para consulta estándar SF2DS

//Funciones para generación de XML
/*/{Protheus.doc} GetTaxasEq
Genera elemento de Impuestos generales de documento electrónico
@type function
@author luis.enriquez
@since 24/Septiembre/2018
@version 1.0
@param cDoc, character, Número de documento
@param cSerie, character, Serie
@param cCliente, character, Código de Cliente
@param cLoja, character, Código de tienda
@param cEspecie, character, Especie del documeto
@return ${return}, ${cTaxas}
/*/
Function GetTaxasEq(cDoc, cSerie, cCliente, cLoja, lSignature, lLiqComp)
	Local aArea  	:= GetArea()
	Local aImp   	:= {}
	Local aImpAux   := {}
	Local cTmp   	:= getNextAlias()
	Local cTaxas 	:= ""	
	Local cSalto 	:= (chr(13)+chr(10))
	Local nX		:= 0
	Local cTabDet 	:= IIf(ALLTRIM(cEspecie) <> "NCC","SD2","SD1")
	Local nDetOrd	:= IIf(ALLTRIM(cEspecie) <> "NCC", 3, 1)
	Local cPref		:= IIf(ALLTRIM(cEspecie) <> "NCC", "D2_", "D1_")
	Local aTagImp   := {}
	Local nImpInc   := 0 
	Local nLibroF   := 0
	Local lRet      := .F.
	Local lTes      := .F.
	Local cCodProd  := ""
	
	Default lSignature := .F.
	Default lLiqComp := .F.
	
	aTagImp   := IIf(ALLTRIM(cEspecie) $ "NF|NCC" .or. lLiqComp ,{"totalConImpuestos", "totalImpuesto"},{"impuestos", "impuesto"})

	If Alltrim(cEspecie) $ "NF/NDC"
		BeginSql alias cTmp
			SELECT FC_TES, FB_CODIMP, FB_CODIGO, FB_CPOLVRO, FB_ALIQ, FC_INCDUPL, F4_CALCIVA, F4_TARIVA, FB_CLASSE
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO = FC_IMPOSTO
			INNER JOIN %table:SF4% SF4 ON SFC.FC_TES = SF4.F4_CODIGO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND F4_FILIAL = %exp:xfilial("SF4")%
			AND FB_CLASSE='I'
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SF4.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD2.D2_TES FROM %table:SD2% SD2
				WHERE SD2.D2_FILIAL = %exp:xfilial("SD2")%
					AND SD2.D2_DOC =  %exp:cDoc%
					AND SD2.D2_SERIE =  %exp:cSerie%
					AND SD2.D2_CLIENTE = %exp:cCliente%
					AND SD2.D2_LOJA = %exp:cLoja%
					AND SD2.%notDel%
				GROUP BY SD2.D2_TES 
			)
		EndSql
	ElseIf Alltrim(cEspecie) $ "NCC"
		BeginSql alias cTmp
			SELECT FC_TES, FB_CODIMP, FB_CODIGO, FB_CPOLVRO, FB_ALIQ, FC_INCDUPL, F4_CALCIVA, F4_TARIVA, FB_CLASSE
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO = FC_IMPOSTO
			INNER JOIN %table:SF4% SF4 ON SFC.FC_TES = SF4.F4_CODIGO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND F4_FILIAL = %exp:xfilial("SF4")%
			AND FB_CLASSE='I'
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SF4.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD1.D1_TES FROM %table:SD1% SD1
				WHERE SD1.D1_FILIAL = %exp:xfilial("SD1")%
					AND SD1.D1_DOC =  %exp:cDoc%
					AND SD1.D1_SERIE =  %exp:cSerie%
					AND SD1.D1_FORNECE = %exp:cCliente%
					AND SD1.D1_LOJA = %exp:cLoja%
					AND SD1.%notDel%
				GROUP BY SD1.D1_TES
			)
		EndSql
	EndIf
	
	dbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (!(cTmp)->(EOF()))
		AADD( aImp , { (cTmp)->FC_TES, ;      //[1]Código TES
		               (cTmp)->FB_CODIMP, ;   //[2]Código Impuesto SRI
		               (cTmp)->FB_CODIGO, ;   //[3]Código Impuesto
		               (cTmp)->FB_CPOLVRO, ;  //[4]Número Libro Fiscal
		               (cTmp)->FB_ALIQ, ;     //[5]Alícuota
		               (cTmp)->FC_INCDUPL, ;  //[6]1 (suma), 2 (resta), 3 (impuesto incluido en precio)
		                "", ;                 //[7]Cód. Tarifa SRI
		                0.00, ;               //[8]Base Impuesto
		                0.00, ;               //[9]Importe Impuesto
		                (cTmp)->F4_CALCIVA, ; //[10]Calcula IVA
		                (cTmp)->F4_TARIVA })  //[11]Tarifa IVA
		(cTmp)->(dbskip())
	EndDo                                                                                                
	                                                                                               
	dbSelectArea(cTabDet)
	// Para SF2: D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM  
	// Para SF1: D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM     
	&(cTabDet)->(dbSetOrder(nDetOrd))                                                                                                     
	                                                                                                
	If &(cTabDet)->(DbSeek(xFilial(cTabDet) + cDoc + cSerie + cCliente + cLoja),.t.)
		While (!&(cTabDet)->(EOF())) .and. ;
		(cTabDet)->&(cPref+"FILIAL") + (cTabDet)->&(cPref + "DOC") + (cTabDet)->&(cPref + "SERIE") + IIf(Alltrim(cEspecie) <> "NCC", (cTabDet)->&("D2_CLIENTE"), (cTabDet)->&("D1_FORNECE")) + (cTabDet)->&(cPref+"LOJA") == ;
		 xFilial(cTabDet) + cDoc + cSerie + cCliente + cLoja		
			For nX := 1 To Len(aImp)	
				lTes := IIf((cTabDet)->&(cPref + "TES") == aImp[nX,1], .T., .F.)
				lRet     := M486IMPEQ(aImp[nX,3],(cTabDet)->&(cPref + "TES"))
				nBaseImp := (cTabDet)->&(cPref + "BASIMP" + aImp[nX,4])
				nValImp  := (cTabDet)->&(cPref + "VALIMP" + aImp[nX,4])
				nAliqImp := (cTabDet)->&(cPref + "ALQIMP" + aImp[nX,4])
				
				If (nBaseImp > 0 .or. nValImp > 0) .And. lRet .And. lTes	
					If aImp[nX,2] == "2"       //IVA
						If aImp[nX,10] == "1" //Calculado
							aImp[nX,7] := ObtColSAT("S017",Str(Int(nAliqImp)) + "%",2,30,1,1)
						Else
							aImp[nX,7] := aImp[nX,11]
						EndIf
					ElseIf aImp[nX,2] == "3"   //ICE
						aProdSRI   := TarifaSRI(cCodProd)
						aImp[nX,7] := aProdSRI[1]
					EndIf
					aImp[nX,5] := nAliqImp
					aImp[nX,8] := nBaseImp
					aImp[nX,9] := nValImp
					
					//Acumulado de impuestos
					If len(aImpAux) > 0 
						nPos := Ascan(aImpAux,{|x| x[2] == aImp[nX,2] .and. x[7] == aImp[nX,7]} )
						If nPos == 0
							aAdd(aImpAux,{aImp[nX,1],aImp[nX,2],aImp[nX,3],aImp[nX,4],aImp[nX,5],aImp[nX,6],aImp[nX,7],aImp[nX,8],aImp[nX,9],aImp[nX,10],aImp[nX,11]})						
						Else
							aImpAux[nPos,8] += nBaseImp
							aImpAux[nPos,9] += nValImp 
						EndIf
					Else
						aAdd(aImpAux,{aImp[nX,1],aImp[nX,2],aImp[nX,3],aImp[nX,4],aImp[nX,5],aImp[nX,6],aImp[nX,7],aImp[nX,8],aImp[nX,9],aImp[nX,10],aImp[nX,11]})
					EndIf
					
					//Iva incluido
					If aImp[nX,6] == "3"
						nImpInc += nValImp
					EndIf					
				EndIf	
			Next nX
			(cTabDet)->(dbskip())
		EndDo				
	EndIf
	
	If lSignature
		If Len(aImpAux) > 0
			For nX := 1 To Len(aImpAux)
				cTaxas += '    <Impuestos>'  + cSalto
				cTaxas += '        <TipoImp>'+  Alltrim(aImpAux[nX,2]) + '</TipoImp>' + cSalto
				cTaxas += '        <CodTasamp>' +  Alltrim(aImpAux[nX,7]) + '</CodTasamp>' + cSalto
				If Alltrim(aImpAux[nX,2]) <> "3"
					cTaxas += '        <TasaImp>'+  Alltrim(STR(aImpAux[nX,5],14,2)) + '</TasaImp>' + cSalto
				EndIf
				cTaxas += '        <MontoBAseImp>'+  Alltrim(STR(aImpAux[nX,8],14,2)) + '</MontoBAseImp>' + cSalto
				cTaxas += '        <MontoImp>'+  Alltrim(STR(aImpAux[nX,9],14,2)) + '</MontoImp>' + cSalto
				cTaxas += '    </Impuestos>'  + cSalto
			Next
		EndIf	
	Else
		If Len(aImpAux) > 0
			cTaxas := '        <' + Alltrim(aTagImp[1]) + '>' + cSalto
			For nX := 1 To Len(aImpAux)
				cTaxas += '            <' + Alltrim(aTagImp[2]) + '>'  + cSalto
				cTaxas += '                <codigo>'+  Alltrim(aImpAux[nX,2]) + '</codigo>' + cSalto
				cTaxas += '                <codigoPorcentaje>' +  Alltrim(aImpAux[nX,7]) + '</codigoPorcentaje>' + cSalto
				If Alltrim(cEspecie) == "NDC"
					cTaxas += '                <tarifa>'+  Alltrim(STR(aImpAux[nX,5],14,2)) + '</tarifa>' + cSalto
				EndIf
				cTaxas += '                <baseImponible>'+  Alltrim(STR(aImpAux[nX,8],14,2)) + '</baseImponible>' + cSalto
				cTaxas += '                <valor>'+  Alltrim(STR(aImpAux[nX,9],14,2)) + '</valor>' + cSalto
				cTaxas += '            </' + Alltrim(aTagImp[2]) + '>'  + cSalto
			Next
			cTaxas += '        </' + Alltrim(aTagImp[1]) + '>' + cSalto
		EndIf
	EndIf
	  
	RestArea(aArea)
Return {cTaxas, nImpInc}

/*/{Protheus.doc} TaxDetEcu
Genera elemento de Impuestos por cada item del documento electrónico
@type function
@author luis.enriquez
@since 10/Septiembre/2018
@version 1.0
@param cDoc, character, Número de documento
@param cSerie, character, Serie
@param cCliente, character, Código de Cliente
@param cLoja, character, Código de tienda
@param cTES, character, Código de tipo entrada/salida
@param cEspecie, character, Especie del documeto
@param cCodProd, character, Código de producto
@param lSignature, Logico, Activa impuestos
@param lReembolso, Logico, Activa impuestos Reembolso
@return ${return}, ${cTaxas}
/*/
Function TaxDetEcu(cDoc, cSerie, cCliente, cLoja, cTES, cEspecie, cCodProd, lSignature,lReembolso)
	Local cTaxas    := ""
	Local cTmp   	:= getNextAlias()
	Local nX        := 1
	Local nBaseImp	:= 0
	Local nValImp	:= 0
	Local nAliqImp	:= 0
	Local aProdSRI  := {}
	Local cAliasSD	:= IIf(cEspecie $ 'NF|NDC',"SD2","SD1")
	Local cBasImpSD	:= IIf(cEspecie $ 'NF|NDC',"D2_BASIMP","D1_BASIMP")
	Local cValImpSD	:= IIf(cEspecie $ 'NF|NDC',"D2_VALIMP","D1_VALIMP")
	Local cAlqImpSD	:= IIf(cEspecie $ 'NF|NDC',"D2_ALQIMP","D1_ALQIMP")	
	Local aImp      := {}
	Local cSalto 	:= (chr(13)+chr(10))
	Local nImpIncD  := 0
	
	Default lSignature := .F.
	Default lReembolso := .F.
	
	BeginSql alias cTmp
		SELECT FC_TES, FB_CODIMP, FB_CODIGO, FB_CPOLVRO, FB_ALIQ, FC_INCDUPL, F4_CALCIVA, F4_TARIVA
		FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON SFB.FB_CODIGO = SFC.FC_IMPOSTO
		INNER JOIN %table:SF4% SF4 ON SFC.FC_TES = SF4.F4_CODIGO
		WHERE FB_FILIAL = %exp:xfilial("SFB")%
		AND FC_FILIAL = %exp:xfilial("SFC")%
		AND F4_FILIAL = %exp:xfilial("SF4")%
		AND FB_CLASSE='I'
		AND SFC.%notDel%
		AND SFB.%notDel%
		AND SF4.%notDel%
		AND SFC.FC_TES = %exp:cTES%
	EndSql
	
	dbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (!(cTmp)->(EOF()))
		AADD( aImp , { (cTmp)->FC_TES, ;      //[1]Código TES
		               (cTmp)->FB_CODIMP, ;   //[2]Código Impuesto SRI
		               (cTmp)->FB_CODIGO, ;   //[3]Código Impuesto
		               (cTmp)->FB_CPOLVRO, ;  //[4]Número Libro Fiscal
		               (cTmp)->FB_ALIQ, ;     //[5]Alícuota
		               (cTmp)->FC_INCDUPL, ;  //[6]1 (suma), 2 (resta), 3 (impuesto incluido en precio)
		                "", ;                 //[7]Cód. Tarifa SRI
		                0.00, ;               //[8]Base Impuesto
		                0.00, ;               //[9]Importe Impuesto
		                (cTmp)->F4_CALCIVA, ; //[10]Calcula IVA
		                (cTmp)->F4_TARIVA })  //[11]Tarifa IVA
		(cTmp)->(dbskip())
	EndDo	
	
	For nX := 1 To Len(aImp)
		If lReembolso
			nBaseImp := AQ0->AQ0_VALOR
			nValImp  := AQ0->AQ0_VALIMP
			nAliqImp := aImp[nX,5]
		Else
			nBaseImp := (cAliasSD)->&(cBasImpSD + aImp[nX,4])
			nValImp  := (cAliasSD)->&(cValImpSD + aImp[nX,4])
			nAliqImp := (cAliasSD)->&(cAlqImpSD + aImp[nX,4])
		EndIf

		If (nBaseImp > 0 .or. nValImp > 0)
			If aImp[nX,2] == "2"       //IVA
				If aImp[nX,10] == "1" //Calculado
					aImp[nX,7] := ObtColSAT("S017",Str(Int(nAliqImp)) + "%",2,30,1,1)
				Else
					aImp[nX,7] := aImp[nX,11]
				EndIf
			ElseIf aImp[nX,2] == "3"   //ICE
				aProdSRI   := TarifaSRI(cCodProd)
				aImp[nX,7] := aProdSRI[1]
			EndIf
			aImp[nX,5] := nAliqImp
			aImp[nX,8] := nBaseImp
			aImp[nX,9] := nValImp
			If aImp[nX,6] == "3"
				nImpIncD += nValImp
			EndIf
		EndIf	
	Next nX
	
	If lSignature
		For nX := 1 To Len(aImp)
			cTaxas += '    <ImpuestosDet>'  + cSalto
			cTaxas += '        <TipoImp>'+  Alltrim(aImp[nX,2]) + '</TipoImp>' + cSalto
			cTaxas += '        <CodTasaImp>' +  Alltrim(aImp[nX,7]) + '</CodTasaImp>' + cSalto
			cTaxas += '        <TasaImp>' +  Alltrim(Str(aImp[nX,5],14,2)) + '</TasaImp>' + cSalto
			cTaxas += '        <MontoBaseImp>'+  Alltrim(STR(aImp[nX,8],14,2)) + '</MontoBaseImp>' + cSalto
			cTaxas += '        <MontoImp>'+  Alltrim(STR(aImp[nX,9],14,2)) + '</MontoImp>' + cSalto
			cTaxas += '    </ImpuestosDet>'  + cSalto
		Next	
	ElseIf lReembolso
		For nX := 1 To Len(aImp)	
			cTaxas := '                         <detalleImpuesto>'  + cSalto 
			cTaxas += '                    			<codigo>'+  Alltrim(aImp[nX,2]) + '</codigo>' + cSalto
			cTaxas += '                   			<codigoPorcentaje>' +  Alltrim(aImp[nX,7]) + '</codigoPorcentaje>' + cSalto
			cTaxas += '                    			<tarifa>' + Alltrim(STR(aImp[nX,5])) + '</tarifa>' + cSalto
			cTaxas += '                    			<baseImponibleReembolso>' + Alltrim(TRANSFORM( AQ0->AQ0_VALOR ,"99999999999999.99"))+ '</baseImponibleReembolso>' + cSalto
			cTaxas += '                    			<impuestoReembolso>' + Alltrim(TRANSFORM(AQ0->AQ0_VALIMP,"99999999999999.99"))+ '</impuestoReembolso>' + cSalto
			cTaxas += '                			</detalleImpuesto>'  + cSalto
		Next
	Else
		For nX := 1 To Len(aImp)
			cTaxas += '                <impuesto>'  + cSalto
			cTaxas += '                    <codigo>'+  Alltrim(aImp[nX,2]) + '</codigo>' + cSalto
			cTaxas += '                    <codigoPorcentaje>' +  Alltrim(aImp[nX,7]) + '</codigoPorcentaje>' + cSalto
			cTaxas += '                    <tarifa>' +  Alltrim(Str(aImp[nX,5],14,2)) + '</tarifa>' + cSalto
			cTaxas += '                    <baseImponible>'+  Alltrim(STR(aImp[nX,8],14,2)) + '</baseImponible>' + cSalto
			cTaxas += '                    <valor>'+  Alltrim(STR(aImp[nX,9],14,2)) + '</valor>' + cSalto
			cTaxas += '                </impuesto>'  + cSalto
		Next
	EndIf	
Return {cTaxas, nImpIncD}

/*/{Protheus.doc} CveAccEcu
Genera clave de acceso
@type function
@author luis.enriquez
@since 17/Septiembre/2018
@version 1.0
@param cFil, character, Filial de documento
@param cDoc, character, Número de documento
@param cSerie, character, Serie del documentos
@param cCliente, character, Código de Cliente
@param cLoja, character, Código de tienda
@return ${return}, ${cCveAcceso}
/*/
Function CveAccEcu(cFil, cNumDoc, cSerie, cCliente, cLoja)
	Local cCveAcceso := ""
	Local nTamDoc 	 := TamSX3("F2_DOC")[1]
	Local cRuc       := Alltrim(SM0->M0_CGC)
	
	If Alltrim(cEspecie) == "NCC"	
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO    
		If SF1->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 
			cCveAcceso := Padl(Alltrim(Str(DAY(SF1->F1_EMISSAO))),2,'0') + Padl(Alltrim(Str(MONTH(SF1->F1_EMISSAO))),2,'0') + ; 
			              Alltrim(Str(YEAR(SF1->F1_EMISSAO)))               //1. Fecha de emisión (Tam 8)
			cCveAcceso += "04"   //2.Tipo de Comprobante (Tam 2)
			cCveAcceso += cRuc                                              //3.Número de RUC (Tam 13)
			cCveAcceso += SuperGetMV("MV_CFDIAMB",.F.,"1")                  //4.Tipo de Ambiente (Tam 1)
			cCveAcceso += SF1->F1_ESTABL + SF1->F1_PTOEMIS                  //5.Serie            (Tam 6)
			cCveAcceso += Alltrim(Substr(SF1->F1_DOC,(nTamDoc-8),9))        //6.Número del Comprobante (Tam 9)
			cCveAcceso += Alltrim(Substr(SF1->F1_DOC,(nTamDoc-7),8))        //7.Código Númerico (Tam 8)
			cCveAcceso += "1"                                               //8.Tipo de Emisión (Tam 1)
	//		cCveAcceso += Alltrim(Str(DigMod11(cCveAcceso)))                    //9.Digito Verificador (Tam 1)	
			cCveAcceso += MODULO11(cCveAcceso,2,7)                      //9.Digito Verificador (Tam 1)			
		EndIf
	ElseIf Alltrim(cEspecie) $ "NF|NDC"
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
		If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 
			cCveAcceso := Padl(Alltrim(Str(DAY(SF2->F2_EMISSAO))),2,'0') + Padl(Alltrim(Str(MONTH(SF2->F2_EMISSAO))),2,'0') + ; 
			              Alltrim(Str(YEAR(SF2->F2_EMISSAO)))               //1. Fecha de emisión (Tam 8)
			cCveAcceso += IIf(Alltrim(SF2->F2_ESPECIE) == "NF","01","05")   //2.Tipo de Comprobante (Tam 2)
			cCveAcceso += cRuc                                              //3.Número de RUC (Tam 13)
			cCveAcceso += SuperGetMV("MV_CFDIAMB",.F.,"1")                  //4.Tipo de Ambiente (Tam 1)
			cCveAcceso += SF2->F2_ESTABL + SF2->F2_PTOEMIS                  //5.Serie            (Tam 6)
			cCveAcceso += Alltrim(Substr(SF2->F2_DOC,(nTamDoc-8),9))        //6.Número del Comprobante (Tam 9)
			cCveAcceso += Alltrim(Substr(SF2->F2_DOC,(nTamDoc-7),8))        //7.Código Númerico (Tam 8)
			cCveAcceso += "1"                                               //8.Tipo de Emisión (Tam 1)
	//		cCveAcceso += Alltrim(Str(DigMod11(cCveAcceso)))                    //9.Digito Verificador (Tam 1)	
			cCveAcceso += MODULO11(cCveAcceso,2,7)                      //9.Digito Verificador (Tam 1)			
		EndIf	
	EndIf	
Return cCveAcceso

/*/{Protheus.doc} TarifaSRI
Obtiene datos del producto
@type function
@author luis.enriquez
@since 10/Septiembre/2018
@version 1.0
@param cCveProd, character, Código de producto
@return ${return}, ${aDatosPro}
/*/
Static Function TarifaSRI(cCveProd)
	Local aDatosPro := {}
	Local aArea    := getArea()
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1)) //B1_FILIAL + B1_COD
	If SB1->(dbSeek(xFilial("SB1") + cCveProd))
		aDatosPro := {SB1->B1_CODICE}
	EndIf
	RestArea(aArea)
Return aDatosPro

/*/{Protheus.doc} DigMod11
Obtiene digito verificador mediante modulo11
@type function
@author luis.enriquez
@since 11/Septiembre/2018
@version 1.0
@param cCadena, character, Cadena para obtener digito verificador
@return ${return}, ${nDigito}
/*/
Static Function DigMod11(cCadena)
	Local nTam    := 0
	Local nDigito := 0
	Local nMult   := 0
	
	nTam := Len(cCadena)
	nDigito := 0
	nMult := 1
	While nTam > 0
	     nMult := nMult + 1
	     nDigito := nDigito + (Val(Substr(cCadena, nTam, 1)) * nMult)
	     If nMult = 8
	          nMult := 1
	     EndIf
	     nTam := nTam - 1
	EndDo
	nDigito := 11 - (mod(nDigito,11))
	IF (nDigito == 0 .Or. nDigito == 1 .Or. nDigito == 10 .Or. nDigito == 11)
	     nDigito := 1
	EndIf
Return (nDigito)

//Funciones para transmisión electrónica
/*/{Protheus.doc} M486SENDST
Consume web services de envío de documento electrónico para proveedor tecnológico STUPENDO
@type function
@author luis.enriquez
@since 24/Septiembre/2018
@version 1.0
@param aFact, array, Arreglo de documentos a enviar
@param aError, array, Arreglo de errores de envío de documentos
@param aTrans, array, Arreglo de documentos enviados sin error
@param cEsp, character, Especie del documento
@return ${return}, ${lRet}
/*/
Function M486SENDST(aFact, aError, aTrans, cEsp)
	Local lRet       := .T.
	Local nI         := 0
	Local cDocs 	 := GetNewPar("MV_CFDDOCS","")
	Local cResXML    := ""
	Local cDocXML    := ""	
	Local cNomDocXML := ""
	Local cTipDoc    := ""
	Local oWS	     := Nil
	Local cMsj       := ""
	Local cURL       := M486GETPAR(1)
	Local lCpoLComp  := SF2->(ColumnPos("F2_TPVENT")) > 0 .And. Alltrim(cEsp) == "NF"
	
	If Alltrim(cEsp) == "NF" //Factura de Venta
		cTipDoc := "01"
	ElseIf Alltrim(cEsp) == "NCC" //Nota de Crédito
		cTipDoc	:= "04"	
	ElseIf Alltrim(cEsp) == "NDC" //Nota de Débito
		cTipDoc := "05"		
	ElseIf Alltrim(cEsp) == "RET" //Comprobantes de retención
		cTipDoc := "07"
	EndIf
	
	//Carga XML en el arreglo
	For nI:= 1 to len(aFact)
		If Alltrim(cEsp) == "RET"
			cNomDocXML := "RET" + Alltrim(SM0->M0_DSCCNA) + Alltrim(cCRet) + ".XML"
		Else
			cNomDocXML := M486NOMARC(aFact[nI,6], aFact[nI,2], aFact[nI,1], aFact[nI,3], aFact[nI,4]) + ".XML"
		EndIf
		cXMLFile   := FsLoadTXT(&(cDocs) + cNomDocXML,.F.)
		cMsj       := ""
		
		oWS := WSFileUploader():NEW()
		oWS:cRucEmpresa    := Alltrim(SM0->M0_CGC)
		oWS:carchivo       := cXMLFile 
		oWS:cNombreArchivo := cNomDocXML
		oWS:_URL		   := cURL
		
		If oWS:UploadFile()
			If "correctamente" $ oWS:cUploadFileResult 
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], oWS:cmensaje})			
				aAdd(aTrans, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],oWS:cmensaje,IIf(lCpoLComp,aFact[nI,11],.F.)})			
			Else
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],oWS:cmensaje}) 
			EndIf
			
			If !Empty(cMsj)
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],cMsj})
			EndIf
		Else
			cMsj := GetWSCError()
			
			If !Empty(cMsj)
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],cMsj})
			EndIf
		EndIf
		
		oWS := Nil
	Next nI	
Return lRet

/*/{Protheus.doc} ValParEq
Validación de parámetros necesarios para facturación electrónica
@type function
@author luis.enriquez
@since 24/Septiembre/2018
@version 1.0
@return ${return}, ${lRet}
/*/
Function ValParEq()
	Local cProvFE	:= ""
	Local cMsj		:= ""
	Local cMsjErr   := ""
	Local cCRLF		:= (chr(13)+chr(10))
	Local lRet		:= .T.
	
	If Empty(cProvFE := SuperGetMV("MV_PROVFE",,""))
		cMsj += "MV_PROVFE - " + STR0179 + CRLF	//"Parámetro no existe o se encuentra vacío."
	Else
		If !(SuperGetMV("MV_PROVFE",,"") $ "STUPENDO")
			cMsj += "MV_PROVFE - " + STR0189 + CRLF	//"Parámetro contiene un valor no permitido (opciones: STUPENDO)."
		EndIf
	EndIf
	
	If Empty(SuperGetMV("MV_CFDIAMB",.F.,"")) .Or. (!(SuperGetMV("MV_CFDIAMB",.F.,"") $ "1|2"))
		cMsj += "MV_CFDIAMB - " + STR0180 + CRLF	//"Parámetro no existe o contiene valores diferentes a 1 (Pruebas) y 2 (Producción)."
	EndIf
	
	If Empty(SuperGetMV("MV_CFDDOCS",,""))
		cMsj += "MV_CFDDOCS - " + STR0179 + CRLF //"Parámetro no existe o se encuentra vacío."
	EndIf
	
	If Empty(SuperGetMV("MV_CFDFTS",,""))
		cMsj += "MV_CFDFTS - " + STR0179 + CRLF	//"Parámetro no existe o se encuentra vacío."
	EndIf	
	
	If Empty(SuperGetMV("MV_WSURL01",,""))
		cMsj += "MV_WSURL01 - " + STR0179 + CRLF //"Parámetro no existe o se encuentra vacío."	
	EndIf	
	
	If Empty(SuperGetMV("MV_WSURL02",,""))
		cMsj += "MV_WSURL02 - " + STR0179 + CRLF //"Parámetro no existe o se encuentra vacío."	
	EndIf	
	
	If Empty(SuperGetMV("MV_WSURL03",,""))
		cMsj += "MV_WSURL03 - " + STR0179 + CRLF //"Parámetro no existe o se encuentra vacío."
	EndIf	
	
	If Empty(SuperGetMV("MV_WSURL04",,""))
		cMsj += "MV_WSURL04 - " + STR0179 + CRLF //"Parámetro no existe o se encuentra vacío."	
	EndIf		
	
	If !Empty(cMsj)
		cMsjErr := STR0181 + CRLF //"Validación: "
		cMsjErr += STR0182 + CRLF //"Antes de transmitir facturas, debe configurar los parámetros necesarios."
		cMsjErr += cMsj
		MsgStop( cMsjErr )
		lRet := .F.
	EndIf	
Return lRet

/*/{Protheus.doc} M486VSM0EQ
Validaciones de datos obligatorios para la empresa (SM0)
@type function
@author luis.enriquez
@since 24/Septiembre/2018
@version 1.0
@return ${return}, ${lRet}
/*/
Function M486VSM0EQ()
	Local lRet := .T.
	Local cMsg := ""

	If Empty(SM0->M0_CGC)
		cMsg += "-RUC" + CHR(13) + CHR(10) //"-RUC"
	ElseIf Empty(SM0->M0_NOME).OR. Empty(SM0->M0_NOMECOM)
		cMsg += "-Nombre de la Empresa" + CHR(13) + CHR(10) //"-Nombre de la Empresa"
	EndIF	
	
	If !Empty(cMsg)
		cMsg := "-Nombre de la Empresa" + CHR(13) + CHR(10) + cMsg // "-Nombre de la Empresa" 
		cMsg += "-Nombre de la Empresa" + CHR(13) + CHR(10) + SM0->M0_NOMECOM // "-Nombre de la Empresa" 		
		MsgInfo(cMsg,"Atención") //  "Atención"
		lRet := .F.
	EndIF	
Return lRet

/*/{Protheus.doc} M486VLDCE
Validaciones de datos de cliente para obligatorios para facturación electrónica
@type function
@author luis.enriquez
@since 24/Septiembre/2018
@version 1.0
@param cCodCli, character, Código de Cliente
@param cCodLoj, character, Código de tienda
@param cDocumento, character, Número de documento
@param cSerDoc, character, Serie del documentos
@param aError, array, Arreglo de errores detectados en configuración de cliente
@return ${return}, ${lRet}
/*/
Function M486VLDCE(cCodCli, cCodLoj, cDocumento, cSerDoc, cEspDoc,aError)
 	Local lRet		:= .T.
 	Local aArea		:= GetArea()
 	Local cFormPag  := ""
	Local cAliasSA  := Iif(cEspDoc == "RCD","SA2","SA1")
	Local cPreSA    := Iif(cEspDoc == "RCD","A2","A1")
	Local cFilSA    := xFilial(cAliasSA)

 	dbSelectArea(cAliasSA)
 	(cAliasSA)->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
 	
 	
 	If (cAliasSA)->(dbSeek(cFilSA + cCodCli + cCodLoj))
 		//RUC
 		If Empty((cAliasSA)->&(cPreSA + "_CGC"))
 			lRet := .F.
 			aAdd(aError ,{cSerDoc, cDocumento, cCodCli, cCodLoj, Iif(cAliasSA == "SA2",STR0363,STR0122)}) // "Información faltante registro del proveedor - RUC (A2_CGC)"-"Información faltante registro del cliente - No. de documento de identificación (A1_CGC o A1_PFISICA)"		
 		EndIf
 		//Tipo de identificador
 		If Empty((cAliasSA)->&(cPreSA + "_TIPDOC")) .And. cAliasSA == "SA1"
 			lRet := .F.
 			aAdd(aError ,{cSerDoc, cDocumento, cCodCli, cCodLoj, STR0117}) //"Información faltante registro del cliente - Tipo de documento de identificación (A1_TIPDOC)"		
		EndIf
 		//Razón social
  		If Empty((cAliasSA)->&(cPreSA + "_NOME"))
 			lRet := .F.
 			aAdd(aError ,{cSerDoc, cDocumento, cCodCli, cCodLoj, STR0118}) //"Información faltante registro cliente Nombre (A1_NOME)."		
 		EndIf
 		//Email
 		If Empty((cAliasSA)->&(cPreSA + "_EMAIL"))
 			lRet := .F.
 			aAdd(aError ,{cSerDoc, cDocumento, cCodCli, cCodLoj, Iif(cAliasSA == "SA2",STR0364,STR0184)}) //"Información faltante registro proveedor - Email (A2_EMAIL)."-"Información faltante registro cliente Email (A1_EMAIL)."
 		Else
 			If !IsEmail((cAliasSA)->&(cPreSA + "_EMAIL"))
	 			lRet := .F.
	 			aAdd(aError ,{cSerDoc, cDocumento, cCodCli, cCodLoj, Iif(cAliasSA == "SA2",STR0365,STR0185)}) //"Información no válida en registro proveedor - Email (A2_EMAIL)."-"Información no válida en registro cliente Email (A1_EMAIL)."		
 			EndIf 			
 		EndIf 
 	EndIf 	 	
 	
	If (!(Alltrim(cEspDoc) $ "RFN|RTS|RCD"))
		dbSelectArea("AI0")
		AI0->(dbSetOrder(1)) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
		
		If AI0->(dbSeek(xFilial("AI0") + cCodCli + cCodLoj))
			cFormPag := AI0_MPAGO 
		EndIf
		
		If (!(M486ValF3I("S024",cFormPag,1,2)) .Or. Empty(cFormPag))
			lRet := .F.
			aAdd(aError ,{cSerDoc, cDocumento, cCodCli, cCodLoj, "Información no válida en registro complementario de cliente Forma Pago (AI0_MPAGO)."}) // Información faltante registro cliente RUC (A1_CGC)
		EndIf
	Endif
	(cAliasSA)->(DBCloseArea())
 	RestArea(aArea)
Return lRet

Function M486VDDEQ()
	Local lRet := .T.
Return lRet

/*/{Protheus.doc} fObtDocRef
Obtiene documento datos de documento relacionado 
para notas de crédito y notas de débito
@type function
@author luis.enriquez
@since 04/Octubre/2018
@version 1.0
@param cPFil, character, Filial de documento
@param cPNumDoc, character, Número de documento
@param cPSerie, character, Serie del documentos
@param cPCliente, character, Código de Cliente
@param cPLoja, character, Código de tienda
@return ${return}, ${aDatosRef}
/*/
Function fObtDocRef(cPFil, cPNumDoc, cPSerie, cPCliente, cPLoja, lSignature)
	Local aDatosRef := {}
	Local nTamCpo   := TamSX3("F2_DOC")[1]
	Local cCodDoc   := ""
	Local cFiltro   := SF2->(DBFilter())
	Local cTempSD   := getNextAlias()
	Local aArea		:= GetArea()
	Local cFil      := ""
	Local cNumDoc   := ""
	Local cSerie    := ""
	Local cCliente  := ""
	Local cLoja     := ""
	Local nCount    := 0
	Local cHora     := ""
	Local cFechRef  := ""
	
	Default lSignature := .F.
	
	If Alltrim(cEspecie) == "NDC"
		cFil     := cPFil
		cNumDoc  := cPNumDoc
		cSerie   := cPSerie
		cCliente := cPCliente
		cLoja    := cPLoja	
	ElseIf Alltrim(cEspecie) == "NCC"
		BEGINSQL ALIAS cTempSD
			SELECT SD1.D1_NFORI, SD1.D1_SERIORI
			FROM %Table:SD1% SD1
			WHERE SD1.D1_FILIAL=%exp:cPFil%
				AND SD1.D1_DOC=%exp:cPNumDoc%
				AND SD1.D1_SERIE=%exp:cPSerie%
				AND SD1.D1_FORNECE=%exp:cPCliente%
				AND SD1.D1_LOJA=%exp:cPLoja%
				AND SD1.%notDel%
			GROUP BY SD1.D1_NFORI, SD1.D1_SERIORI
		ENDSQL
		
		count to nCount
		
		If nCount == 1
			(cTempSD)->(dbGoTop())
			While (!(cTempSD)->(EOF()))
					cNumDoc  := (cTempSD)->D1_NFORI
					cSerie   := (cTempSD)->D1_SERIORI
					(cTempSD)->(dbSkip())
			EndDo
			cFil     := cPFil
			cCliente := cPCliente
			cLoja    := cPLoja			
		EndIf
		
		(cTempSD)->(dbCloseArea())
	EndIf
	
	dbSelectArea("SF2")
 	SET FILTER TO
 	SF2->(dbGotop())
	
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
	If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 
		If Alltrim(SF2->F2_ESPECIE) == "NF" //Factura
			cCodDoc := "01"
		EndIf
		If lSignature
			If ! Empty(SF2->F2_HORA)
				If Len(alltrim(SF2->F2_HORA)) == 5
					cHora := SF2->F2_HORA + ":00"
				Else
					cHora := SF2->F2_HORA
				EndIF
			EndIf
			cFechRef := SubStr(DTOS(SF2->F2_EMISSAO),0,4) + "-" +;
			  SubStr(DTOS(SF2->F2_EMISSAO),5,2) + "-" +;
			  SubStr(DTOS(SF2->F2_EMISSAO),7,2) + "T" + cHora +"Z"
			 cPorc := Alltrim(Transform((SF2->F2_DESCONT*100) / SF2->F2_VALBRUT, "9.99"))
			 aDatosRef := {cCodDoc, SF2->F2_ESTABL, SF2->F2_PTOEMIS, Alltrim(Substr(SF2->F2_DOC,(nTamCpo-8),9)), cFechRef, SF2->F2_MOTIVO, cPorc, Alltrim(STR(SF2->F2_VALBRUT))}
		Else
			aDatosRef := {cCodDoc, SF2->F2_ESTABL, SF2->F2_PTOEMIS, Alltrim(Substr(SF2->F2_DOC,(nTamCpo-8),9)), cValtoChar( SF2->F2_EMISSAO ), SF2->F2_FLFTEX, SF2->F2_FECAUT}
		EndIf		
	EndIf
	
	SET FILTER TO &(cFiltro)
		
	RestArea(aArea)
Return aDatosRef

/*/{Protheus.doc} M486IMPEQ
Generación de nombre para archivo .XML a enviar a Stupendo
@type function
@author luis.enriquez
@since 04/Octubre/2018
@version 1.0
@param cFil, character, Filial de documento
@param cDoc, character, Número de documento
@param cSerie, character, Serie del documentos
@param cCliente, character, Código de Cliente
@param cLoja, character, Código de tienda
@return ${return}, ${cUrl}
/*/
Function M486NOMARC(cFil, cNumDoc, cSerie, cCliente, cLoja)
	Local cNomArc := ""
	Local nTamDoc 	 := TamSX3("F2_DOC")[1]
	Local cFecha := ""
	
	If Alltrim(cEspecie) $ "NCC"
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO    
		If SF1->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 
			cFecha := Padl(Alltrim(Str(DAY(SF1->F1_EMISSAO))),2,'0') + ;
			Padl(Alltrim(Str(MONTH(SF1->F1_EMISSAO))),2,'0') + ;
			Alltrim(Str(YEAR(SF1->F1_EMISSAO)))
			cNomArc := Alltrim(SF1->F1_ESPECIE) + "-" + Alltrim(cFecha) + "-" + Alltrim(SF1->F1_ESTABL) + ;
			Alltrim(SF1->F1_PTOEMIS) + Alltrim(Substr(SF1->F1_DOC,(nTamDoc-8),9)) + "-" + Alltrim(Str(SF1->F1_SECSRI))
		EndIf
	ElseIf Alltrim(cEspecie) $ "NF|NDC|RFN|RTS|RCD"
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
		If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 
			cFecha := Padl(Alltrim(Str(DAY(SF2->F2_EMISSAO))),2,'0') + ;
			Padl(Alltrim(Str(MONTH(SF2->F2_EMISSAO))),2,'0') + ;
			Alltrim(Str(YEAR(SF2->F2_EMISSAO)))
			cNomArc := Alltrim(SF2->F2_ESPECIE) + "-" + Alltrim(cFecha) + "-" + Alltrim(SF2->F2_ESTABL) + ;
			Alltrim(SF2->F2_PTOEMIS) + Alltrim(Substr(SF2->F2_DOC,(nTamDoc-8),9)) + "-" + Alltrim(Str(SF2->F2_SECSRI))
		EndIf
	EndIf
Return cNomArc

/*/{Protheus.doc} M486IMPEQ
Validación de que impuesto pertenece a TES
@type function
@author luis.enriquez
@since 04/Octubre/2018
@version 1.0
@param cCodImp, character, Código del impuesto
@param cTes, character, Código de la TES
@return ${return}, ${cUrl}
/*/
Function M486IMPEQ(cCodImp, cTes)
	Local lRet := .F.
 	dbSelectArea("SFC")
 	dbSetOrder(2) //FC_FILIAL + FC_TES + FC_IMPOSTO
 	If SFC->(DbSeek(xFilial("SFC") + cTes))
		Do While SFC->(!Eof()) .And. (SFC->FC_FILIAL + SFC->FC_TES == xFilial("SFC") + cTes)
			If SFC->FC_IMPOSTO == cCodImp
				lRet := .T.
				Exit
			EndIf
			SFC->(dbSkip())
		EndDo
	EndIf
Return lRet

/*/{Protheus.doc} M486GETPAR
Obtiene url para web services de acuerdo a ambiente y opción de envío 
o consulta de documentos electrónicos para ecuador
@type function
@author luis.enriquez
@since 04/Octubre/2018
@version 1.0
@param nOpc, character, Opción de operación 1 - Envio y 2 - Consulta
@return ${return}, ${cUrl}
/*/
Function M486GETPAR(nOpc)
	Local cUrl := ""
	Local cAmb := SuperGetMV("MV_CFDIAMB",,"")
	
	If SuperGetMV("MV_PROVFE",,"") == "STUPENDO"
		If Alltrim(cAmb) == "1" //Pruebas			
			If nOpc == 1 //Envío
				cUrl := SuperGetMV("MV_WSURL01",,"")
			ElseIf nOpc == 2 //Consulta
				cUrl := SuperGetMV("MV_WSURL02",,"") 
			EndIf
		ElseIf Alltrim(cAmb) == "2" //Producción
			If nOpc == 1 //Envío
				cUrl := SuperGetMV("MV_WSURL03",,"")
			ElseIf nOpc == 2 //Consulta
				cUrl := SuperGetMV("MV_WSURL04",,"")
			EndIf
		EndIf
	EndIf
Return cUrl

Function fRetDoc() 
Return(cVeiculo)

Function fConsDoc()
Local aArrayVei := {}
Local aArea     := GetArea()
Local cBitmap   := "PROJETOAP"
Local cListVei  := ""
Local cVeiculo  := ""
Local lDisable  := .F.
Local cCpoCapac := IIf(SuperGetmv("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local nCapac    := 0
Local oEnable   := LoadBitmap(GetResources(), "ENABLE")
Local oDisable  := LoadBitmap(GetResources(), "DISABLE")
Local oListVei
Local oDlg
Local oBmp


SF2->(DbSetOrder(1))
SF2->(MsSeek(xFilial("SF2")))
While SF2->(!Eof()) .And. SF2->F2_FILIAL == xFilial("SF2")

	AAdd(aArrayVei,{SF2->F2_DOC, SF2->F2_SERIE})

	SF2->(dbSkip())
EndDo

DEFINE FONT oFont NAME "Arial" SIZE 0, -11

cBitmap := "PROJETOAP"

DEFINE MSDIALOG oDlg TITLE OemtoAnsi("Notas Fiscales") FROM 280,320 TO 580,840 OF oMainWnd PIXEL //"Notas Fiscales"
@ 0 , 0 BITMAP oBmp RESNAME cBitMap oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

@ 06,50 SAY OemtoAnsi("STR0004")  Of oDlg Pixel
@ 15,50 SAY "Rangos"  Of oDlg Pixel

@ 23,50 LISTBOX oListVei Var cListVei FIELDS HEADER OemToAnsi("Documento"),OemToAnsi("Serie") SIZE 210,100  OF oDlg PIXEL  

//	oListVei:nFreeze := 1
	oListVei:SetArray(aArrayVei)
	oListVei:bLine:={ ||{aArrayVei[oListVei:nAT,1],aArrayVei[oListVei:nAT,2]}}

DEFINE SBUTTON oBut2 FROM 130, 195 TYPE 1 ENABLE OF oDlg PIXEL ACTION (cVeiculo := aArrayVei[oListVei:nAt][1],oDlg:End())
DEFINE SBUTTON oBut2 FROM 130, 225 TYPE 2 ENABLE OF oDlg PIXEL ACTION (nOpca := 0, oDlg:End())

ACTIVATE MSDIALOG oDlg

Restarea( aArea    )

Return( cVeiculo )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M486VPROEQ  ºAutor  ³Luis Enríquez     º Data ³  16/11/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida datos de proveedor.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ M486XFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M486VPROEQ(cCodPro, cCodLoj, cDocumento, cCert, aError)
 	Local lRet 	:= .T.
 	Local aArea 	:= GetArea()
 	
 	dbSelectArea("SA2")
 	SA2->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
 	
 	If SA2->(dbSeek(xFilial("SA2") + cCodPro + cCodLoj)) 
 		//Tipo de identificación
 		If Empty(SA2->A2_TIPDOC) 
 		 	aAdd(aError ,{"", cCert, cCodPro, cCodLoj, STR0126}) // "Información faltante registro proveedor - Tipo de documento de Identificación del Proveedor(A2_TIPDOC)"
 			lRet := .F.
 		EndIf
 		//Nombre
 		If Empty(SA2->A2_NOME) 
 		 	aAdd(aError ,{"", cCert, cCodPro, cCodLoj, STR0127}) // "Información faltante registro proveedor - Nombre del Proveedor (A2_NOME)"
 			lRet := .F.
 		EndIf
 		//RUT
 		If Empty(SA2->A2_CGC) 
 		 	aAdd(aError ,{"", cCert, cCodPro, cCodLoj, STR0128}) // "Información faltante registro proveedor - RUT del Proveedor (A2_CGC)"
 			lRet := .F.
 		EndIf 		
 		//Dirección
 		If Empty(SA2->A2_END) 
 		 	aAdd(aError ,{"", cCert, cCodPro, cCodLoj, STR0121}) //  "Información faltante registro del cliente - Dirección(A1_END)"
 			lRet := .F.
 		EndIf  		
 		//Email
 		If Empty(SA2->A2_EMAIL) 
 		 	aAdd(aError ,{"", cCert, cCodPro, cCodLoj, STR0186}) // "Información faltante registro proveedor Email (A2_EMAIL)."
 			lRet := .F.
 		Else
 			If !IsEmail(SA2->A2_EMAIL)
	 			lRet := .F.
	 			aAdd(aError ,{"", cDocumento, cCodCli, cCodLoj, STR0187}) // "Información no válida en registro proveedor Email (A2_EMAIL)."		
 			EndIf 		
 		EndIf  		
 	Else
 		lRet := .F.
 		aadd(aError ,{cSerDoc, cCert, cCodPro, cCodLoj, STR0125}) // "Proveedor sin registro" 	
 	EndIf
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M486ValF3I  ºAutor  ³Luis Enríquez     º Data ³  16/11/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica codigo no Cadastro de Tabelas                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ M486XFUNEQ                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M486ValF3I(cCodigo,cConteudo,nPos1,nPos2)
	Local lRet := .F.
	Local cTRB := ""
	Local cQry := ""

	Default nPos1 := 0
	Default nPos2 := 0
	
	If cCodigo <> Nil .And. cConteudo <> Nil
		
		If Select("TRB")>0
			TRB->(dbCloseArea())
		EndIf
		
		cQry := " SELECT F3I_CODIGO,F3I_SEQUEN,F3I_CONTEU "
		cQry += " FROM " + RetsqlName("F3I") + " F3I "
		cQry += " WHERE F3I_FILIAL = '" + xFilial("F3I") + "' "
		cQry += " AND F3I_CODIGO = '" + cCodigo + "' "
		cQry +=" AND F3I.D_E_L_E_T_='' "
		
		cTRB := ChangeQuery(cQry)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRB ) ,"TRB", .T., .F.)
		
		dbSelectArea( "TRB" )
		TRB->(dbGoTop())	
		
		While TRB->(!Eof())
			If Alltrim(Substr(TRB->F3I_CONTEUDO,nPos1,nPos2)) == Alltrim(cConteudo)
				lRet := .T.
				Exit
			EndIf
			TRB->(dBSkip())
		EndDo
	EndIf

Return(lRet)

/*/{Protheus.doc} M486RECHEQU
  Obtiene los motivos de rechazo desde el monitor de documentos electrónicos para el país Ecuador
  @type
  @author luis.enríquez
  @since 30/11/2020
  @version 1.0
  @param nLin, numeric, Número de línea
  @param oList, objeto, Objeto con los ítems del listbox
  @example
  (examples)
  @see (links_or_references)
  /*/
Function M486RECHEQU(nLin, oList)
	Local cObs := ""
	If oList:aArray[nLin,1] == 5
		cObs := oList:aArray[nLin,6]
		CursorArrow()
		Aviso(STR0162,alltrim(cObs),{"Ok"},3)
	Else
		MsgAlert(STR0306) //"Opción válida solo para documentos rechazados."
		CursorArrow()
		Return Nil
	EndIf
Return Nil

/*/{Protheus.doc} obtTotReem
  Obtiene totales del reembolso
  @type
  @author Alfredo Medrano
  @since 02/09/2021
  @version 1.0
  @param cDoc -  Núm Docto.
  @param cSerie - Serie Docto.
  @param cCliente - Cliente Docto.
  @param cLoja	 - Tienda Docto.
  @example
  (examples)
  @see (links_or_references)
  /*/
function obtTotReem(cDoc, cSerie, cCliente, cLoja)
Local aArea 	:= GetArea()
Local cTmp   	:= getNextAlias()
Local aTotReem := {}
	BeginSql alias cTmp
		SELECT AQ0_SERIE ,AQ0_DOC ,AQ0_CLIENT ,AQ0_TIENDA ,SUM(AQ0_VALOR) TOTBASIMP ,SUM(AQ0_VALIMP) TOTIMP, SUM(AQ0_TOTAL) TOTREEM
		FROM %table:AQ0% AQ0
		WHERE AQ0_FILIAL = %exp:xfilial("AQ0")%
		AND AQ0_DOC=%exp:cDoc%
		AND AQ0_SERIE=%exp:cSerie%
		AND AQ0_CLIENT=%exp:cCliente%
		AND AQ0_TIENDA=%exp:cLoja%
		AND AQ0.%notDel%
		GROUP BY AQ0_SERIE ,AQ0_DOC ,AQ0_CLIENT ,AQ0_TIENDA
	EndSql

	If (cTmp)->(!EOF())
		aadd(aTotReem, {(cTmp)->TOTREEM, (cTmp)->TOTBASIMP, (cTmp)->TOTIMP  } )
	EndIf
	(cTmp)->(dbCloseArea())
	RestArea(aArea)
return aTotReem

/*/{Protheus.doc} fgetDocEqu
	Obtiene datos del Documento de Sustento para guias de remisión.
	@type  Function
	@author eduardo.manriquez
	@since 26/03/2022
	@version 1.0
	@param cFil  , Caracter , Filial .
	@param cDoc , Caracter , Número de Documento.
	@param cSer , Caracter , Serie del Documento.
	@return cEspecie, Caracter, Especie del documento.
	@return aDatosRef, arreglo, Arreglo que contiene la información del documento sustento
	{número documento,punto de emisión,establecimiento,número autorización,fecha emisión}
	@example
	fgetDocEqu(cFil,cDoc,cSer,cEspecie)
	@see (links_or_references)
/*/
function fgetDocEqu(cFil,cDoc,cSer,cEspecie)
	Local aDatosRef := {}
	Local nCount     := 0
	Local cTempSF   := getNextAlias()

	BEGINSQL ALIAS cTempSF
			SELECT SF2.F2_DOC,SF2.F2_PTOEMIS,SF2.F2_ESTABL,SF2.F2_EMISSAO, SF2.F2_NUMAUT
			FROM %Table:SF2% SF2
			WHERE SF2.F2_FILIAL=%exp:cFil%
				AND SF2.F2_DOC=%exp:cDoc%
				AND SF2.F2_SERIE=%exp:cSer%
				AND SF2.F2_ESPECIE=%exp:cEspecie%
				AND SF2.%notDel%
	ENDSQL

	count to nCount

	If nCount == 1
		(cTempSF)->(dbGoTop())
		While (!(cTempSF)->(EOF()))
			Aadd(aDatosRef, (cTempSF)->F2_DOC)
			Aadd(aDatosRef, (cTempSF)->F2_PTOEMIS)
			Aadd(aDatosRef, (cTempSF)->F2_ESTABL)
			Aadd(aDatosRef, AllTrim((cTempSF)->F2_NUMAUT))
			Aadd(aDatosRef, Right((cTempSF)->F2_EMISSAO,2)  + "/" + Substr((cTempSF)->F2_EMISSAO,5,2)+ "/" +Left((cTempSF)->F2_EMISSAO,4))
			(cTempSF)->(dbSkip())
		EndDo
	EndIf
	(cTempSF)->(dbCloseArea())
Return aDatosRef

/*/{Protheus.doc} fVldEqu
	Valida los campos del pedido requeridos en la generación del XML para guias de remisión.
	@type  Function
	@author eduardo.manriquez
	@since 26/03/2022
	@version 1.0
	@param 
	@return lRet, Logico, Retorna .T. si el contenido de los campos es correcto, de lo contrario retorna .F..
	@example
	fVldEqu()
	@see (links_or_references)
/*/
Function fVldEqu()
	Local lRet			:= .T.
	Local cProvFE		:= SuperGetMV("MV_PROVFE",,"")
	Local lValCp        := SuperGetMV("MV_VALGREQ",,.F.)
	Local cCRLF			:= (chr(13) + chr(10))
	Local cModTras		:= ""
	Local cPlaca        := ""
	Local cFilSA4		:= xFilial("SA4")
	Local cFilDA3       := xFilial("DA3")
	Local cProblem      := STR0276 //"Para guías de remisión electrónicas:"
	Local cErrGR		:= ""

	If !Empty(cProvFE) .And. Alltrim(cProvFE) == "STUPENDO" .And. lValCp
		If M->C5_DOCGER == "2" //Doc Gener. (Remisión)
			//Transportadora
			If Empty(M->C5_TRANSP)
				cErrGR += STR0356 + cCRLF //"-El campo Transportadora(C5_TRANSP) es requerido"
			Else
				dbSelectArea("SA4")
				SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
				If SA4->(dbSeek(cFilSA4 + M->C5_TRANSP))
					cModTras  := Iif(SA4->(ColumnPos("A4_TIPOTRA"))> 0,SA4->A4_TIPOTRA,"")
				EndIf

				If Empty(cModTras)
					cErrGR += STR0354 + cCRLF //"-La Transportadora(C5_TRANSP), no tiene definido un tipo de identificación(A4_TIPOTRA)."
				EndIf
			EndIf
			if Empty(M->C5_VEICULO)
				cErrGR += STR0358 + cCRLF //"-El campo Vehiculo(C5_VEICULO) es requerido."
			Else
				dbSelectArea("DA3")
				DA3->(dbSetOrder(1)) //DA3_FILIAL + DA3_COD
				If DA3->(dbSeek(cFilDA3+ M->C5_VEICULO))
					cPlaca  := DA3->DA3_PLACA
				EndIf

				If Empty(cPlaca)
					cErrGR += STR0353 + cCRLF //"-El vehiculo(C5_VEICULO) informado, no cuenta con una placa informada(DA3_PLACA)."
				EndIf
			EndIf
			//Cliente de entrega
			If Empty(M->C5_CLIENT) .Or. Empty(M->C5_LOJAENT)
				cErrGR += STR0274 + cCRLF //"-Cliente de entrega no existe o no ha sido informado (C5_CLIENT + C5_LOJAENT)"
			EndIf

			//Fecha de inicio de traslado
			If SC5->(ColumnPos("C5_FECDSE")) > 0
				If Empty(M->C5_FECDSE)
					cErrGR += STR0275 + cCRLF //"-La fecha de inicio de traslado debe ser informada (C5_FECDSE)."
				Endif
			else
				cErrGR += STR0359 + cCRLF //"-El campo fecha de inicio de traslado(C5_FECDSE) no existe. "
			EndIf

			//Fecha de fin de traslado
			If Empty(M->C5_FECENT)
				cErrGR += STR0355 + cCRLF //"-La fecha de entrega de traslado debe ser informada (C5_FECENT)."
			EndIf

			//Motivo de traslado
			If SC5->(ColumnPos("C5_MODTRAS")) > 0
				If Empty(M->C5_MODTRAS)
					cErrGR += STR0357 + cCRLF //"-El Pedido no tiene el motivo del traslado (C5_MODTRAS)"
				Endif
			Else
				cErrGR += STR0360 + cCRLF // "-El campo motivo del traslado (C5_MODTRAS) no existe."
			EndIf
		EndIf
		If !Empty(cErrGR)
			lRet := .F.
			Help(" ",1,"fVldEqu",,cProblem + cCRLF + cErrGR,1,0)
		EndIf
	EndIf
Return lRet

