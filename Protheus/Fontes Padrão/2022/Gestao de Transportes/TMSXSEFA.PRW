#INCLUDE "Protheus.ch"
#INCLUDE "TMSXSEFA.ch"
#Include "FWMVCDEF.ch" 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ retUpdCte  ≥ Fabio Marchiori Sampaio≥ Data ≥ 03/02/2017  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Autoriza o estorno do CTe Rejeicao SEFAZ  220              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ retUpdCte()                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/ 

Function retUpdCte(cFilOri,cDocTMS,cSerTMS,cCodRet)

Local aAreaDT6		:= {}
Local lRet			:= .T.
Local lCTECan		:= SuperGetMv( "MV_CTECAN", .F., .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
Local lRtCTeId		:= SuperGetMv( "MV_RTCTEID", .F., .F. ) //-- Habilita o bot„o Retorno de Status

Default cFilOri := ' '
Default cDocTMS := ' '
Default cSerTMS := ' '
Default cCodRet := ' '

If lCTECan .And. lRtCTeId .And. cCodRet $ '220'
	aAreaDT6 := DT6->(GetArea())
	
	dbSelectArea("DT6")
	DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
	If DT6->(dbSeek(xFilial("DT6")+cFilOri+cDocTMS+cSerTMS))
		If DT6->DT6_IDRCTE $ '100' .And. DT6->DT6_STATUS = '1'

			lRet := .F.
		
		EndIf
	EndIf
	
	RestArea(aAreaDT6)
EndIf

Return lRet	 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ ExportMdfe  ≥ Fabio Marchiori Sampaio≥ Data ≥ 03/12/2018   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Exporta XML MDF-e do TOTVSColab 2.0                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ ExportMdfe()                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function ExportMdfe(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd,dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe,cSerMax)

Local lUsacolab := UsaColaboracao("5")
Local cAliasQry := GetNextAlias()
Local cCmpNum 	:= ""
Local cCmpSer 	:= ""
Local cNfes		:= ""
Local cDestino	:= ""
Local cDrive	:= ""

	SplitPath(cDirDest,@cDrive,@cDestino,"","")
	cDestino := cDrive+cDestino

	cQuery := " SELECT DTX_FILMAN, DTX_MANIFE, DTX_FILORI, DTX_SERMAN, DTX_VIAGEM, DTX_DATMAN "
	cQuery += "   FROM  " + RetSqlName("DTX") + " DTX "  
	cQuery += "  WHERE DTX_FILIAL = '" + xFilial("DTX") + "' "
	cQuery += "    AND DTX_FILORI = '" + cFilAnt + "' "
	cQuery += "    AND DTX_MANIFE >= '" + cNotaIni + "' "
	cQuery += "    AND DTX_MANIFE <= '" + cNotaFim + "' "
	cQuery += "    AND DTX_SERMAN  = '" + cSerie + "' "
	cQuery += "    AND DTX_DATMAN >= '" + DtoS(dDataDe) + "' "
	cQuery += "    AND DTX_DATMAN <= '" + DtoS(dDataAte) + "' "
	cQuery += "    AND DTX.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())

		If lUsaColab
			
			cCnpjDFim := iif(empty(cCnpjDFim),"99999999999999", cCnpjDFim)
	
	    		cCmpNum 	:= (cAliasQry)->DTX_MANIFE
	    		cCmpSer 	:= (cAliasQry)->DTX_SERMAN
	    		cPrefix 	:= 'MDF'  
	
				if cPrefix $ "MDF"
					cXML := ""
	
					aInfXml	:= {}
					aInfXml := ColExpDoc(cCmpSer,cCmpNum,cPrefix ,@cXml)

					//Ponto de Entrada para permitir filtrar as NF
					If ExistBlock("SPDNFE01")
						If !ExecBlock("SPDNFE01",.f.,.f.,{aInfXml})
							(cAliasQry)->(dbSkip())
							loop
						Endif
					Endif
					//Encontrou documento
					if aInfXMl[1]
	
						if cPrefix $ "MDF"
							//IinutilizaÁ„o
							if !Empty( aInfXMl[5] )
								cXmlInut  := aInfXMl[5]
								cAnoInut1 := At("<ano>",cXmlInut)+5
								cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
								cXmlProt  := aInfXMl[6]
	
						 		nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3,2)+cAnoInut+SubStr(aInfXMl[2],5,39)+"-ped-inu.xml")
					 			If nHandle > 0
						 			FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
						 			FClose(nHandle)
						 			aadd(aDeleta,oXml:cID)
						 		EndIf
					 			nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(aInfXMl[2],5,39)+".xml")
					 			If nHandle > 0
						 			FWrite(nHandle,cXmlProt)
						 			FClose(nHandle)
						 		EndIf
						 		cNFes+=SubStr(cCmpSer,1,3)+"/"+ cCmpNum+CRLF
							endif
							//Cancelamento
							if !Empty( aInfXMl[4] ) .And. aInfXMl[8] != '135'
								cXml    := StaticCall(SPEDNFE, SpecCharc, aInfXMl[4])
					 			nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-canc.xml")
					 			if nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
						 			FClose(nHandle)
						 		endIf
						 		cNFes+=SubStr(cCmpSer,1,3)+"/" + cCmpNum+CRLF
							endif
	
							if !Empty( aInfXML[3] )
								cXml    := StaticCall(SPEDNFE, SpecCharc, aInfXMl[3])
	
				 				If ExistBlock("FISEXPNFE")
		                   		ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
					 			EndIF
	
					 			nHandle := FCreate(cDestino+SubStr(aInfXMl[2],4)+"-"+cPrefix+".xml")
					 			if nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
						 			FClose(nHandle)
						 		endIf
	
						 		cNFes+=SubStr(cCmpSer,1,3)+"/" + cCmpNum+CRLF
							endif
						endif
						IncProc()
					 endif
				endif
			If !Empty(cNfes)
	    		If Aviso("SPED",STR0001,{"Sim","N„o"}) == 1	//"SolicitaÁ„o processada com sucesso."
					Aviso(STR0002,STR0003 +" "+Upper(cDestino)+CRLF+CRLF+cNFes,{STR0004},3) //STR0151-"XML Exportados para", "XML's Exportados para"
				EndIf
			endif
			delclassintf()
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ TMSMonSEF   ≥ Felipe M. Barbiere     ≥ Data ≥ 25/02/2019   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Verifica o Status da SEFAZ antes de enviar o CTe/MDFe      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ TMSMonSEF(cModelo)                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function TMSMonSEF(cModelo,cModalidade)
Local lUsacolab     := UsaColaboracao("5")
Local cIdEnt 	 	:= '' 
Local cURL       	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOK			:= .T.
Local nCont 		:= 0
Local oWSM          := Nil
Local cAltSEFAZ 	:= SuperGetMV('MV_ALTMSEF',,'') 
Local aXML          := {}

Default cModelo 	:= '57'
Default cModalidade := ""

If !lUsaColab .And. CTIsReady(,,,lUsaColab)
	cIdEnt:= RetIdEnti(lUsaColab)

	//Verifica a Modalidade
	oWSM := WsSpedCfgNFe():New()
	oWSM:cUSERTOKEN := "TOTVS"
	oWSM:cID_ENT    := cIdEnt
	oWSM:nModalidade:= 0
	oWSM:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWSM:cModelo   	:= cModelo
	If cModelo == '57'
		lOk 			:= oWSM:CFGModalidade()
		cModalidade    	:= oWSM:cCfgModalidadeResult
	ElseIf cModelo == '58'
		oWSM:nAmbienteMDFE   := 0 //Val(SubStr(cAmbiente,1,1))
		oWSM:cVersaoMDFE     := "0.00"
		oWSM:nModalidadeMDFE := 0
		oWSM:cVERMDFELAYOUT  := "0.00"
		oWSM:cVERMDFELAYEVEN := "0.00"
		oWSM:nSEQLOTEMDFE    := 0
		oWSM:cHORAVERAOMDFE  := '0'
		oWSM:cHORARIOMDFE    := '0'
		lOk := oWSM:CFGMDFE()
		If lOk
			If VALTYPE(oWSM:OWSCFGMDFERESULT) == 'O' .And. VALTYPE(oWSM:OWSCFGMDFERESULT:CMODALIDADEMDFE) == 'C'
				cModalidade := SubStr(oWSM:OWSCFGMDFERESULT:CMODALIDADEMDFE,1,1)
			Else			
				lOK:= .F.
			EndIf	
		EndIf	
	EndIf
		
	//Verifica o Status do ServiÁo na SEFAZ
	If lOk
		oWs:= WsNFeSBra():New()
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWs:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
		lOk := oWS:MONITORSEFAZMODELO()
	EndIf	
	
	If lOk
		aXML := OWS:OWSMONITORSEFAZMODELORESULT:OWSMONITORSTATUSSEFAZMODELO

		If Len(aXML) > 0 .And. Substr(AllTrim(cModalidade), 1, 1) $ "2/5/8/9" 
			For nCont := 1 to Len(aXML)
				If aXml[nCont]:CMODELO == cModelo .And. !(aXML[nCont]:CSTATUSCODIGO $ "107/113")			
					Aviso("SPED",aXML[nCont]:CSTATUSCODIGO + " - " + aXML[nCont]:CSTATUSMENSAGEM + CHR(10)+CHR(13)+;//Motivo do Retorno
								AllTrim(aXML[nCont]:CSUGESTAO),{STR0004},3) //Sugestao do retorno
					If (cModelo = '58' .And. aXML[3]:CSTATUSCODIGO = "999")
						lOk := .T.
					Else
						lOk := .F.
					EndIf
				ElseIf cModelo $ cAltSEFAZ .And. (Substr(AllTrim(cModalidade), 1, 1) == "5" .Or. Substr(AllTrim(cModalidade), 1, 1) == "2") .And. aXML[nCont]:CMODELO == cModelo ;
						.And. aXML[nCont]:CSTATUSCODIGO $ "107/113"
						TMSRetSt(cModelo)						
						Exit
				EndIf
			Next		
		EndIf	
	EndIf	
EndIf

Return lOk

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ TMSRetSt    ≥ Felipe M. Barbiere     ≥ Data ≥ 25/02/2019   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Altera o Status da transmissao do CTe/MDFe para Normal     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ TMSRetSt(cModelo)                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSRetSt(cModelo)

Local lOk 		 := .F.
Local cError	 := ""
Local lUsaColab  := UsaColaboracao("5")
Local cIdEnt 	 := RetIdEnti(lUsaColab)
Local oWS		 := Nil
Local cURL     	 := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cModalidade:= ""

Default cModelo := '57'

If cModelo == '57' 
	cModalidade		:= getCfgModalidade(@cError, cIdEnt, cModelo)
	lOk 			:= Empty(cError)
	
	If lOk .And. Substr(AllTrim(cModalidade), 1, 1) $ '5;7;8;9'
		getCfgModalidade(@cError, cIdEnt, cModelo, "1-Normal")
	EndIf
ElseIf cModelo == '58' 
	oWS :=  WsSpedCfgNFe():New()
	oWS:cUSERTOKEN      := "TOTVS"
	oWS:cID_ENT         := cIdEnt
	oWS:nModalidadeMDFE := 1
	oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo         := cModelo
	oWS:nAmbienteMDFE   := 0 //Val(SubStr(cAmbiente,1,1))
	oWS:cVersaoMDFE     := "0.00"
	oWS:cVERMDFELAYOUT  := "0.00"
	oWS:cVERMDFELAYEVEN := "0.00"
	oWS:nSEQLOTEMDFE    := 0
	oWS:cHORAVERAOMDFE  := '0'
	oWS:cHORARIOMDFE    := '0'
	lOk:= oWS:CFGMDFE()
EndIf

Return Nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedDesMnt
FunÁ„o que monitora os eventos do Evento de Desacordo

@author Felipe Barbieri
@since 23.03.2017
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function TMSPedMDes(cAliasDes)

Local aListBox	:= {}
Local cEstDoc	:= ""
Local lUsaColab	:= .F.
Local dEmissao	:= CtoD("//")
Local cDoc		:= ""
Local cSerie	:= ""
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2

Default cAliasDes := ""

If Empty(cAliasDes)
	If IsInCallStack("MATA103")
		cAliasDes := "SF1"
	Elseif IsInCallStack("TMSA500")
		cAliasDes := "DT6"
	Endif
Endif

If cAliasDes == "SF1"
	cEstDoc	:= SF1->F1_IDDES
	dEmissao	:= SF1->F1_EMISSAO
	cDoc		:= SF1->F1_DOC
	cSerie		:= SF1->F1_SERIE
Elseif cAliasDes == "DT6"
	cEstDoc	:= DT6->DT6_IDDES
	dEmissao	:= DT6->DT6_DATEMI
	cDoc		:= DT6->DT6_DOC
	cSerie		:= DT6->DT6_SERIE
Endif

lUsaColab := UsaColaboracao("2")

DEFINE FONT oBold BOLD

	aListBox := TMSpedWDes(cAliasDes)

	If !Empty(aListBox)

			DEFINE MSDIALOG oDlg TITLE STR0015 From 10,10 TO 450,1012 OF oMainWnd PIXEL

			@015,010 SAY	STR0011			PIXEL OF oDlg FONT oBold	//Numero
			@015,036 SAY	cDoc				PIXEL OF oDlg
			@015,074 SAY	STR0012			PIXEL OF oDlg FONT oBold	//SÈrie
			@015,093 SAY	cSerie				PIXEL OF oDlg

			@030,010 LISTBOX oListBox 	FIELDS HEADER "",STR0006,STR0007,STR0008,STR0009,STR0010 SIZE 480,150 PIXEL OF oDlg	//"Protocolo ID Evento Ambiente Status do Evento Retorno da Transmissao Retorno Processamento do Evento"

			oListBox:SetArray(aListBox)
			oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;
									aListBox[oListBox:nAt][02],;
									aListBox[oListBox:nAt][03],;
									aListBox[oListBox:nAt][04],;
									aListBox[oListBox:nAt][05],;
									aListBox[oListBox:nAt][06]}}

			@ 200,400 BUTTON oBtn1 PROMPT STR0013 ACTION (aListBox := TMSpedWDes(cAliasDes),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
			@ 200,455 BUTTON oBtn2 PROMPT STR0014 ACTION (TMSHlpDes(cAliasDes), oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"OK"

			ACTIVATE MSDIALOG oDLg CENTERED
		EndIf
Return

/*/{Protheus.doc} SpedHlpDes
Informativo para o usuario excluir CTE apÛs evento
de desacordo for vinculado.

@author Rodrigo M Pontes
@since 23.03.2017
@version 1.00

@param	Null
/*/

Static Function TMSHlpDes(cAliasDes)

If cAliasDes == "SF1"
	Help(,,'EVDESACORDO',,STR0016, 1, 0) //"… recomendavel que exclua o CTE apÛs a confirmaÁ„o do evento. O CTE continuara com todas seus lanÁamentos ativos atÈ que seja excluido."
Endif

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedDesMnt
FunÁ„o que monitora os eventos do Evento de Desacordo

@author Felipe Barbieri
@since 23.03.2017
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function TMSpedWDes(cAliasDes)

Local cIdEnt		:= ""
Local aListBox		:= {}
Local cEstDoc		:= ""
Local lUsaColab		:= UsaColaboracao("2")
Local dEmissao		:= CtoD("//")
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWS	
Local lOk 			:= .F.
Local aStatus		:= {	{1,"1-Evento recebido"},;
							{2,"2-Evento assinado"},;
							{3,"3-Evento com falha no schema XML"},;
							{4,"4-Evento transmitido"},;
							{5,"5-Evento com problemas"},;
							{6,"6-Evento vinculado"	} }
Local nStatPos		:= 0
Local cStatus		:= ""
Local cStatRetEven	:= ""
Local cStatRet		:= ""
Local cStatRetEnv	:= ""
Local cProtocolo    := ""
Local cChvCte		:= ""
Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")

If cAliasDes == "SF1"
	cEstDoc	:= SF1->F1_IDDES
	dEmissao:= SF1->F1_EMISSAO
	cChvCte	:= SF1->F1_CHVNFE
Elseif cAliasDes == "DT6"
	cEstDoc	:= DT6->DT6_IDDES
	dEmissao:= DT6->DT6_DATEMI
	cChvCte	:= DT6->DT6_CHVCTE
Endif

DEFINE FONT oBold BOLD

cIdEnt := RetIdEnti(lUsaColab)

// Verifica se a entidade foi configurada
If !Empty(cIdEnt)
	// Executa o metodo NfeRetornaEvento()
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN	:= "TOTVS"
	oWS:cID_ENT		:= cIdEnt
	oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cEVENTO		:="610110"
	oWS:cCHVINICIAL	:= cChvCte
	oWS:cCHVFINAL	:= cChvCte
	lOk := oWS:NFEMONITORLOTEEVENTO()

	If lOk
		// Tratamento do retorno do evento
		If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U" .And. ;
		   !Empty(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) .And. ;
		   ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"

			oDados := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento[1]

			If ( nStatPos := aScan(aStatus,{ |x| x[1] == oDados:nStatus}) ) > 0
				cStatus := aStatus[nStatPos][2]
			Endif
			cIDEvenRet	:= oDados:cId_Evento
			cAmbiente	:= Alltrim(Str(oDados:nAmbiente))		//1-Producao ### 2-Homologacao

			If oDados:nStatus > 2
				// Retorno da transmissao
				cStatRetEnv := cValToChar(oDados:nCSTATENV) + " - " + Alltrim(oDados:cCMOTENV)
					// Retorno do processamento do evento
				If oDados:nCStatEven > 0
					cStatRetEven := cValToChar(oDados:nCStatEven)+" - "+Alltrim(oDados:cCMotEven)
					// Evento registrado e vinculado a NF-e
					If oDados:nCStatEven == 135
						cProtocolo := StrZero(oDados:nProtocolo,15)
						If cEstDoc <> '6'
							If cAliasDes == "SF1"
								If RecLock('SF1',.F.)
									SF1->F1_IDDES  := AllTrim(Str(oDados:nStatus))
										If AllTrim(Str(oDados:nStatus)) == "6"
										SF1->F1_STATUS := "E" // Evento desacordo vinculado
									Elseif AllTrim(Str(oDados:nStatus)) == "5" .Or. AllTrim(Str(oDados:nStatus)) == "3"
										SF1->F1_STATUS := "F" // Evento desacordo rejeiÁ„o
									Endif
										SF1->(MsUnLock())
								Endif
						Elseif cAliasDes == "DT6"
								If RecLock('DT6',.F.)
									DT6->DT6_IDDES  := AllTrim(Str(oDados:nStatus))
									DT6->(MsUnLock())
								Endif
							Endif
						EndIf
					ElseIf oDados:nCStatEven >= 201 //RejeiÁ„o
						If cEstDoc <> '6'
							If cAliasDes == "SF1"
								If RecLock('SF1',.F.)
									SF1->F1_IDDES  := AllTrim(Str(oDados:nStatus))
										If AllTrim(Str(oDados:nStatus)) == "6"
										SF1->F1_STATUS := "E" // Evento desacordo vinculado
									Elseif AllTrim(Str(oDados:nStatus)) == "5" .Or. AllTrim(Str(oDados:nStatus)) == "3"
										SF1->F1_STATUS := "F" // Evento desacordo rejeiÁ„o
									Endif
										SF1->(MsUnLock())
								Endif
							Elseif cAliasDes == "DT6"
								If RecLock('DT6',.F.)
									DT6->DT6_IDDES  := AllTrim(Str(oDados:nStatus))
									DT6->(MsUnLock())
								Endif
							Endif
						EndIf
					Endif
				Endif
			Else
				cXmlRet := ""
			Endif
			cAmbiente := IIf(cAmbiente == "1",STR0017,STR0018)

			If Empty(cStatRetEven)
				cStatRet := cStatRetEnv
			Else
				cStatRet := cStatRetEven
			Endif
			AADD( aListBox, {	IIf(Empty(cProtocolo),oNo,oOk),;
							cProtocolo,;
							cIDEvenRet,;
							cAmbiente,;		//[04] 1-Producao ### 2-Homologacao
							cStatus,;		//[05] Status do evento
							cStatRet})		//[06] Status retorno da transmissao
		Else
			Aviso("SPED",STR0021,{STR0020},3)	//-- "Nenhuma NF-e encontrada de acordo com os parametros informados!"	### "Ok"
		EndIf
	EndIf
Else
	Aviso("SPED",STR0019,{STR0020},3)	//"Execute o mÛdulo de configuraÁ„o do serviÁo, antes de utilizar esta opÁ„o!!!"
EndIf

Return aListBox 


/*/
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    TMSWsCte   ≥ Autor ≥ Andre Godoi          ≥ Data ≥ 25.03.10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Solicita o Status do documento ao TSS e grava os retornos  ≥±±
±±≥          ≥na tabela DT6                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ExpC1: Serie do Documento                                   ≥±±
±±≥          ≥ExpC2: Documento Inicial                                    ≥±±
±±≥          ≥ExpC3: Documento Maximo                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function TMSSpedCte(cSerie, cDocMin, cDocMax, lCTE)

Local aAreaSF2  := SF2->(GetArea())
Local aAreaSF3  := SF3->(GetArea())
Local aAreaSFT  := SFT->(GetArea())
Local nX        := 0
Local nY        := 0
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOk       := .T.
Local oWS
Local oRetorno
Local cNrSerie  := ''
Local cNrDocto  := ''
Local cSitCTE   := ''
Local cIDRCTE   := ''
Local cIdEnt    := ''
Local lTmsCteAut:= ExistBlock("TMSCTEAUT")
Local aArrayDel := {}
Local lCTECan	  := SuperGetMv( "MV_CTECAN", .F., .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
Local cMV_INTTAF:= GetNewPar( 'MV_INTTAF', 'N' ) //Verifica se o par‚metro da integraÁ„o online esta como 'S'
Local lTafKey   := SFT->( ColumnPos( 'FT_TAFKEY' ) ) > 0
Local lIntegTaf := ( cMV_INTTAF == 'S' .and. lTafKey )
Local lTAFVldAmb:= ExistFunc( 'TAFVldAmb' ) .And. TAFVldAmb( '1' ) .And. ExistFunc( 'DocFisxTAF' ) //Valida se o cliente habilitou a integraÁ„o nativa Protheus x TAF
Local cTMSERP   := SuperGetMV("MV_TMSERP",," ")	//-- CondiÁ„o de integraÁ„o com ERP (0 - Protheus, 1 - Datasul)
Local lretUpdCte:= ExistFunc( "retUpdCte" )
Local lretCte   := .T.
Local lUsaColab	:= UsaColaboracao("2")
Local lRtCTeId		:= SuperGetMv( "MV_RTCTEID", .F., .F. ) //-- Habilita o bot„o Retorno de Status

Local nLinhaDTP := 0
Local nCntFor1  := 0
Local aRejCanc	:= IIf(ExistFunc("Ae70LiRej"), Ae70LiRej(), {}) //RejeiÁ„o para os eventos de cancelamento do CT-e.

Default lCTE    := .T.

Private oXml

cIdEnt := RetIdEnti(lUsaColab)

If !Empty(cIdEnt)
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN    := "TOTVS"
	oWS:cID_ENT       := cIdEnt
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
	if(!empty(cSerie) )
		oWS:cIdInicial    := cSerie + cDocMin
		oWS:cIdFinal      := cSerie + cDocMax
	else
		oWS:cIdInicial    := cDocMin
		oWS:cIdFinal      := cDocMax
	endif
	
	lOk 	:= oWS:MONITORFAIXA()
	oRetorno:= oWS:oWsMonitorFaixaResult
	
	For nX := 1 To Len(oRetorno:oWSMONITORNFE)
		nY       := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)
		cNrSerie := SubStr(oRetorno:OWSMONITORNFE[nX]:CID,1, TamSx3("DT6_SERIE")[1])
		cNrDocto := SubStr(oRetorno:OWSMONITORNFE[nX]:CID, (TamSx3("DT6_SERIE")[1] + 1), TamSx3("DT6_DOC")[1])
	
		If (!Empty(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO))		//-- Mensagem do TSS.
			cSitCTE := oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
			cCodRet := Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3)
			DT6->(dbSetOrder(1))
			If	DT6->(MsSeek(xFilial('DT6')+cFilAnt+PadR(cNrDocto, Len(DT6->DT6_DOC))+cNrSerie))
			  	If lretUpdCte
			  		lretCte := retUpdCte(cFilAnt,PadR(cNrDocto, Len(DT6->DT6_DOC)),cNrSerie,cSitCTE)
				EndIf
				If lretCte
					RecLock('DT6',.F.)
					cIDRCTE := DT6->DT6_IDRCTE
					DT6->DT6_IDRCTE := cSitCTE
					DT6->DT6_PROCTE := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
		
					If !Empty(cCodRet) .And. !(cCodRet $ '003/002/004/009/016/039')
						DT6->DT6_RETCTE := SubStr(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CCODRETNFE;
												 + " - " +;
												  oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE,1,150)
					Else
						DT6->DT6_RETCTE := SubStr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,150)
					EndIf
					DT6->DT6_AMBIEN := oRetorno:OWSMONITORNFE[nX]:NAMBIENTE	//-- Grava o Ambiente que foi gerado o Doc.
		
					If cCodRet $ '002/016'
						DT6->DT6_SITCTE := StrZero(0,Len(DT6->DT6_SITCTE))		//-- Nao Transmitido
		
					ElseIf cCodRet $ '003/004/009/039'
						DT6->DT6_SITCTE := StrZero(1,Len(DT6->DT6_SITCTE))		//-- Aguardando.....
						If oRetorno:OWSMONITORNFE[nX]:NMODALIDADE == 7
							If Type("aPChvCtg") <> "U" .And. Len(aPChvCtg)>0
								nPos := Ascan(aPChvCtg,{ | e | e[1]+e[2]+e[3] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE })
								If nPos>0
									DT6->DT6_CHVCTG := aPChvCtg[nPos,4]
								EndIf
							EndIf
					 	EndIf
		
					ElseIf cCodRet $ '001/015'
						DT6->DT6_SITCTE := StrZero(2,Len(DT6->DT6_SITCTE))		//-- Autorizado o uso do Cte.
		
					ElseIf cCodRet $ '005/010/011/012/013/014/017/026'
						DT6->DT6_SITCTE := StrZero(3,Len(DT6->DT6_SITCTE))		//-- Nao Autorizado
		
					ElseIf cCodRet $ '007/008'
						DT6->DT6_SITCTE := StrZero(4,Len(DT6->DT6_SITCTE))		//-- Autorizado Contingencia
						If Type("aPChvCtg") <> "U" .And. Len(aPChvCtg)>0
							nPos := Ascan(aPChvCtg,{ | e | e[1]+e[2]+e[3] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE })
							If nPos>0
									DT6->DT6_CHVCTG := aPChvCtg[nPos,4]
							EndIf
						EndIf
					EndIf
		
					MsUnLock()
					//-- Se for reentrega diminui 1 na quantidade de reentregas do documento original
					If DT6->DT6_DOCTMS == StrZero(7,Len(DT6->DT6_DOCTMS)) .And. !Empty(cIDRCTE) .And. cIDRCTE <> "101" .And. cSitCTE == '101' //Cancelamento autorizado
					    aAreaDT6 := DT6->(GetArea())
					    DT6->(dbSetOrder(1))
					    If DT6->(MsSeek(xFilial('DT6')+ DT6->DT6_FILDCO + DT6->DT6_DOCDCO + DT6->DT6_SERDCO)) .And. DT6->DT6_REENTR > 0
						     RecLock("DT6",.F.)
						     DT6->DT6_REENTR := DT6->DT6_REENTR - 1
						     DT6->(MsUnLock())
				    	EndIf
			    		RestArea(aAreaDT6)
			   		EndIf
					If lTmsCteAut
						ExecBlock("TMSCTEAUT",.F.,.F.,{DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, DT6->DT6_SITCTE})
					EndIf
		
					//Nota de saida
		
					dbSelectArea("SF2")
					dbSetOrder(1)	//-- F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
					If SF2->(MsSeek(xFilial("SF2") + DT6->DT6_DOC + DT6->DT6_SERIE + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,.T.)) .And. SF2->F2_CHVNFE != DT6->DT6_CHVCTE
						RecLock("SF2",.F.)
						SF2->F2_CHVNFE := DT6->DT6_CHVCTE
						MsUnlock()
		
						//FunÁ„o para gravaÁ„o de campos da Nota no modulo Controle de Lojas com LegislaÁ„o PAF-ECF
						If !lCTE .And. ExistFunc("STFMMd5NS")
							STFMMd5NS()
						EndIf
					EndIf
		
					//Livros Fiscais
					dbSelectArea("SF3")
					dbSetOrder(4) //-- F3_FILIAL+F3_CLIFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
					If SF3->(MsSeek(xFilial("SF3") + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV + DT6->DT6_DOC +DT6->DT6_SERIE,.T.))
						cChave := xFilial("SF3")+ DT6->DT6_CLIDEV + DT6->DT6_LOJDEV + DT6->DT6_DOC +DT6->DT6_SERIE
						Do While cChave == xFilial("SF3") + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE .And. !SF3->(Eof())
							RecLock("SF3",.F.)
							SF3->F3_CHVNFE  := DT6->DT6_CHVCTE
							SF3->F3_CODRSEF := cSitCTE
							MsUnLock()
		
							//-- Executa integraÁ„o do Datasul
							If cTMSERP == "1" .And. FindFunction("TMSAE76")
								TMSAE76()
							EndIf
					    SF3->(dbSkip())
					    EndDo
					EndIf
		
					//-- Livro Fiscal por Item de NF
					SFT->(dbSetOrder(1))
					cChave := xFilial("SFT")+"S"+ DT6->DT6_SERIE + DT6->DT6_DOC + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV
					If SFT->(MsSeek(xFilial("SFT")+"S"+ DT6->DT6_SERIE + DT6->DT6_DOC + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,.T.))
						If SFT->(FieldPos("FT_CHVNFE"))>0  .And. SFT->(FieldPos("FT_CODNFE"))>0
							Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
								RecLock("SFT",.F.)
								SFT->FT_CHVNFE := DT6->DT6_CHVCTE
								SFT->FT_CODNFE := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
								MsUnLock()
		
								//-----------------------------------------------------------------------------------------
								//Quando o cliente utiliza integraÁ„o com o TAF no retorno do TSS faÁo o envio do documento
								//-----------------------------------------------------------------------------------------
								If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
									FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
								EndIf
		
								SFT->(dbSkip())
							EndDo
						EndIf
					EndIf
		
					//-- Monta o vetor de estorno dos documentos do lote (TMS)
					If lCTECan .And. cSitCTE == '101'
						If (nLinhaDTP := Ascan(aArrayDel,{|x| x[1] == DT6->DT6_LOTNFC})) > 0
							Aadd(aArrayDel[nLinhaDTP,2],{DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,"",.T.,DT6->DT6_SITCTE})
						Else
							Aadd(aArrayDel,{DT6->DT6_LOTNFC,{{DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,"",.T.,DT6->DT6_SITCTE}}})
						EndIf
					EndIf 
		
					If FindFunction ("AvbeGrvCte") .AND. AliasInDic("DL5")
						AvbeGrvCte( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE,DT6->DT6_DATEMI,DT6->DT6_HOREMI,DT6->DT6_IDRCTE,DT6->DT6_DOCTMS, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV)
					EndIF
				EndIf

				If lCTECan .And. lRtCTeId .And. Ascan( aRejCanc, { |x| x == cSitCTE } ) > 0
					XSfVldSt( DT6->( RECNO() ) )
				EndIf
			EndIf

			If FindFunction ("AvbeGrvCte") .AND. AliasInDic("DL5") .AND. !lCTECan .AND. cSitCTE == '101'
				AvbeGrvCte( cFilAnt, +PadR(cNrDocto, Len(DT6->DT6_DOC)), cNrSerie,,,'101',,,)
			EndIF
		EndIf
	
	Next nX
	
	//-- Chama o estorno dos documentos to lote (TMS)
	If lCTECan .And. !Empty(aArrayDel) .And. !IsInCallStack("monitorUpd") .Or. (IsInCallStack("monitorUpd") .And. !Empty(aArrayDel))
		For nCntFor1 := 1 To Len(aArrayDel)
			TMSA200Exc(aArrayDel[nCntFor1,2], aArrayDel[nCntFor1,1], .F., .F.,)
		Next nCntFor1
	EndIf 
EndIf

RestArea(aAreaSF2)
RestArea(aAreaSF3)
RestArea(aAreaSFT)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} FIntegNfTaf
FunÁ„o respons·vel pelo envio do documento fiscal eletrÙnico para o TAF apÛs
o retorno do TSS com a chave eletrÙnica.

@Param	aDocSFT    -> Array com a chave do documento fiscal para integraÁ„o
		lTAFVldAmb -> Controle do ERP para saber se a integraÁ„o online pode ser realizada

@author	 Rodrigo Aguilar
@since	 16/02/2017
/*/
//-------------------------------------------------------------------------
Static Function FIntegNfTaf( aDocSFT, lTAFVldAmb )

 //-----------------------------------------------------------
// Chama Job para intregacao NATIVA do documento fiscal no TAF
//-----------------------------------------------------------
If lTAFVldAmb
    StartJob( 'DocFisxTAF', GetEnvServer(), .F., cEmpAnt, cFilAnt , aDocSFT )
EndIf

Return

/*/{Protheus.doc} ProdPred(cFilDoc,cDocto,cSerie,nTipo)
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function ProdPred(cFilDoc,cDocto,cSerie,nTipo,cFilMan,cManifest,cSerman) 
 Local jResult		:= JsonObject():New()
 Local cQuery		:= ""
 Local lComplemento	:= .F.
 Local cFilDco		:= ""
 Local cDocDco		:= ""
 Local cSerDco		:= ""
 Local aAreaDT6		:= DT6->(GetArea())
 Local aAreaDTQ		:= DTQ->(GetArea())
 Local cAliasALL	:= GetNextAlias()
 Local cCTeUnico	:= ""
 Local cDTCObs		:= ""
 Default cFilDoc	:= Space(Len(DT6->DT6_FILDOC))
 Default cDocto		:= Space(Len(DT6->DT6_DOC   ))
 Default cSerie		:= Space(Len(DT6->DT6_SERIE))
 Default cFilMan	:= Space(Len(DUD->DUD_FILMAN))
 Default cManifest	:= Space(Len(DUD->DUD_MANIFE))
 Default cSerman    := Space(Len(DUD->DUD_SERMAN)) 
 
			JResult['PRODUTO'    ] := ""
			JResult['DSCPRODUTO' ] := ""
			JResult['UNIDMEDIDA' ] := ""

			jResult['DOCTOAPOIO' ] := .F.	//-- documento de apoio? .T. ou .F.
			jResult['OBSERVACAO' ] := ""	//-- observaÁıes provenientes da Entrada de NF Cliente
			jResult['DOCTODPC'   ] := ""	//-- Numero Documento CT-e Despachante
			jResult['SERIEDPC'   ] := ""	//-- Serie CT-e Despachante
			jResult['TPDOCTOANT' ] := ""	//-- Tipo do Documento do Despachante 0=CTRC;2=ACT;3=Nota Fiscal;4=AWB;5=Outros
			jResult['EMISSAODPC' ] := ""	//-- Data Emiss„o do Documento do Despachante
			jResult['NRDOCTOANT' ] := ""	//-- Numero do Documento Anterior
			jResult['TIPONF'     ] := ""	//-- Tipo da NF -0=Normal;1=Devolucao;2=SubContratacao;3=Nao Fiscal;4=Exportacao;5=Redesp;6=Nao Fiscal 1;7=Nao Fiscal 2;8=Serv Vincul.Multimodal
			JResult['DEVEDOR'    ] := ""	//-- Devedor do Frete - 1=Remetente;2=Destinatario;3=Consignatario;4=Despachante;6=Expedidor;7=Recebedor
			JResult['SELORIGEM'  ] := ""	//-- Selecao de Origem
			JResult['SEQENDDES'  ] := ""	//-- Sequencia de Endereco de Entrega
			JResult['FILORIGEM'  ] := ""	//-- Filial de Origem do Documento
			JResult['SOLICITACAO'] := ""	//-- Numero da Solicitacao de Coleta
			JResult['INSREMOPC'  ] := ""	//-- Inscricao Estadual do Remetente proveniente da tabela DV3
			JResult['INSDESOPC'  ] := ""	//-- Inscricao Estadual do Destinatario proveniente da tabela DV3
			JResult['INSAUXOPC'  ] := ""
			JResult['INSDESOPC'  ] := ""
			JResult['INSREMOPC'  ] := ""
			JResult['NCM'        ] := ""    //-- Nomenclatura Comum do Mercosul (NCM)
			JResult['cEAN'       ] := ""	//-- Codigo de Barras do Produto
			JResult['cCEPOrigem'  ] := ""  
			JResult['cOrigLatit'  ] := ""
			JResult['cOrigLongi'  ] := ""
			JResult['cCEPDestin'  ] := ""
			JResult['cDestLatit'  ] := ""
			JResult['cDestLongi'  ] := ""

			//???????????????????????????????????????????????????????????????????
			//? Verifica se È documento complementar de frete                   ?
			//???????????????????????????????????????????????????????????????????
			If Empty(cFilMan) .And. Empty(cManifest)
				//--1:DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
				DT6->(DbSetOrder(1)) ///8-DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO
				If DT6->(Dbseek(xFilial("DT6")+cFilDoc+cDocto+cSerie))
					If !Empty(DT6->DT6_DOCDCO)
						cFilDco := DT6->DT6_FILDCO
						cDocDco := DT6->DT6_DOCDCO
						cSerDco := DT6->DT6_SERDCO
						lComplemento := .T.
					EndIf
				Else
					RestArea(aAreaDT6)
					Return JResult
				EndIf
			EndIf

			//???????????????????????????????????????????????????????????????????
			//? Tipo de Servico                                                 ?
			//? 0 - Normal                                                      ?
			//? 1 - SubContratacao                                              ?
			//? 2 - Redespacho                                                  ?
			//? 3 - Redespacho Intermediario                                    ?
			//???????????????????????????????????????????????????????????????????
			//???????????????????????????????????????????????????????????????????
			//? DTC - Notas Fiscais: (Informacao do campo DTC_TIPNFC)           ?
			//? 0 - Normal                                                      ?
			//? 1 - Devolucao                                                   ?
			//? 2 - SubContratacao                                              ?
			//? 3 - Dcto Nao Fiscal                                             ?
			//? 4 - Exportacao                                                  ?
			//? 5 - Redespacho                                                  ?
			//? 6 - Dcto Nao Fiscal 1                                           ?
			//? 7 - Dcto Nao Fiscal 2                                           ?
			//???????????????????????????????????????????????????????????????????
			//???????????????????????????????????????????????????????????????????
			//? Seleciona as informacoes do produto, baseado na DTC             ?
			//? Pega o produto com maior valor de mercadoria, definido como     ?
			//? o produto predominante                                          ?
			//???????????????????????????????????????????????????????????????????
			cAliasAll := GetNextAlias()
			cQuery := " SELECT MAX(DTC.DTC_VALOR) AS MAX_DTC_VALOR,"
			cQuery +=			"DTC.DTC_TIPNFC,"
			cQuery +=			"DTC.DTC_DEVFRE,"
			cQuery +=			"DTC.DTC_CODOBS,"
			cQuery +=			"DTC.DTC_CTRDPC,"
			cQuery +=			"DTC.DTC_SERDPC,"
			cQuery +=			"DTC.DTC_TIPANT,"
			cQuery +=			"DTC.DTC_DPCEMI,"
			cQuery +=			"DTC.DTC_CTEANT,"
			cQuery +=			"DTC.DTC_SELORI,"
			cQuery +=			"DTC.DTC_CLIDES,"
			cQuery +=			"DTC.DTC_LOJDES,"
			cQuery +=			"DTC.DTC_CLIREM,"
			cQuery +=			"DTC.DTC_LOJREM,"
			cQuery +=			"A1DES.A1_CEP CEPDES,"
			cQuery +=			"DTC.DTC_SQEDES,"
			cQuery +=			"A1REM.A1_CEP CEPREM,"
			cQuery +=			"DTC.DTC_CLIREC,"
			cQuery +=			"DTC.DTC_LOJREC,"
			cQuery +=			"A1REC.A1_CEP CEPREC,"
			cQuery +=			"DTC.DTC_FILORI,"
			cQuery +=			"DTC.DTC_NUMSOL,"
			cQuery +=			"DTC.DTC_CLIEXP,"
			cQuery +=			"DTC.DTC_LOJEXP,"
			cQuery +=			"A1EXP.A1_CEP CEPEXP,"
			cQuery +=			"DTC.DTC_FILORI,"
			cQuery +=			"DTC.DTC_LOTNFC,"
			cQuery +=			"DV3REM.DV3_INSCR REMDV3_INSCR,"
			cQuery +=			"DV3DES.DV3_INSCR DESDV3_INSCR,"
			cQuery +=			"SB1.B1_DESC,"
			cQuery +=			"SB1.B1_COD,"
			cQuery +=			"SB1.B1_UM,"
			cQuery +=			"SB1.B1_POSIPI,"
			cQuery +=			"SB1.B1_CODBAR,"
			cQuery +=			"SB1.B1_TIPCAR,"
			cQuery +=			"DUD.DUD_FILMAN,"
			cQuery +=			"DUD.DUD_MANIFE,"
			cQuery +=			"DUD.DUD_NUMROM,"
			cQuery +=			"DUD.DUD_FILORI,"
			cQuery +=			"DUD.DUD_VIAGEM,"
			cQuery +=			"DTC.DTC_FILDOC,"
			cQuery +=			"DTC.DTC_DOC,"
			cQuery +=			"DTC.DTC_SERIE, "
			cQuery +=			"DTC.DTC_SQIREM "

			cQuery += " FROM " + RetSqlName("DUD") + " DUD "

			cQuery +=			" LEFT JOIN " + RetSqlName('DT6') + " DT6 "
			cQuery += 					" ON (DT6.DT6_FILIAL = '" + xFilial("DT6") + "'" 
			cQuery += 					" AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
			cQuery += 					" AND DUD.DUD_DOC = DT6.DT6_DOC "
			cQuery += 					" AND DUD.DUD_SERIE = DT6.DT6_SERIE "
			cQuery += 					" AND DT6.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('DTC') + " DTC "
			cQuery += 					" ON (DTC.DTC_FILIAL = '" + xFilial("DTC") + "'" 
			cQuery += 					" AND DT6.DT6_FILDOC = DTC.DTC_FILDOC "
			cQuery += 					" AND DT6.DT6_DOC = DTC.DTC_DOC "
			cQuery += 					" AND DT6.DT6_SERIE = DTC.DTC_SERIE "
			cQuery += 					" AND DTC.D_E_L_E_T_ = ' ') "

			cQuery +=			" INNER JOIN " + RetSqlName('SB1') + " SB1 "
			cQuery += 					" ON (SB1.B1_FILIAL = '" + xFilial("SB1") + "'" 
			cQuery += 					" AND ( SB1.B1_COD = DTC.DTC_CODPRO ) "
			cQuery += 					" AND SB1.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('DV3') + " DV3REM "
			cQuery += 					" ON (DV3REM.DV3_FILIAL = '" + xFilial("DV3") + "'" 
			cQuery += 					" AND DV3REM.DV3_CODCLI = DTC.DTC_CLIREM "
			cQuery += 					" AND DV3REM.DV3_LOJCLI = DTC.DTC_LOJREM "
			cQuery += 					" AND DV3REM.DV3_SEQUEN = DTC.DTC_SQIREM "
			cQuery += 					" AND DV3REM.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('DV3') + " DV3DES "
			cQuery += 					" ON (DV3DES.DV3_FILIAL = '" + xFilial("DV3") + "'" 
			cQuery += 					" AND DV3DES.DV3_CODCLI = DTC.DTC_CLIDES "
			cQuery += 					" AND DV3DES.DV3_LOJCLI = DTC.DTC_LOJDES "
			cQuery += 					" AND DV3DES.DV3_SEQUEN = DTC.DTC_SQIdES "
			cQuery += 					" AND DV3DES.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1REM "
			cQuery += 					" ON (A1REM.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1REM.A1_COD = DTC.DTC_CLIREM "
			cQuery += 					" AND A1REM.A1_LOJA = DTC.DTC_LOJREM "
			cQuery += 					" AND A1REM.D_E_L_E_T_ = ' ' ) "
 
			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1EXP "
			cQuery += 					" ON (A1EXP.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1EXP.A1_COD = DTC.DTC_CLIEXP "
			cQuery += 					" AND A1EXP.A1_LOJA = DTC.DTC_LOJEXP "
			cQuery += 					" AND A1EXP.D_E_L_E_T_ = ' ' ) "

			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1DES "
			cQuery += 					" ON (A1DES.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1DES.A1_COD = DTC.DTC_CLIDES "
			cQuery += 					" AND A1DES.A1_LOJA = DTC.DTC_LOJDES "
			cQuery += 					" AND A1DES.D_E_L_E_T_ = ' ' ) "

			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1REC "
			cQuery += 					" ON (A1REC.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1REC.A1_COD = DTC.DTC_CLIREC "
			cQuery += 					" AND A1REC.A1_LOJA = DTC.DTC_LOJREC "
			cQuery += 					" AND A1REC.D_E_L_E_T_ = ' ' ) "

			cQuery += " WHERE "

			//???????????????????????????????????????????????????????????????????
			//? Se o tipo de Conhecimento for de Complemento, seleciona as      ?
			//? informacoes do CTR principal, pois o complemento nao tem DTC    ?
			//???????????????????????????????????????????????????????????????????
			If lComplemento
				cFildoc := cFilDco
				cDocto	:= cDocDco
				cSerie	:= cSerDco
			EndIf
			If !Empty(cFilMan) .And. !Empty(cManifest)
				cQuery += " DUD.DUD_FILMAN = '" + cFilMan + "' "
				cQuery += " AND DUD.DUD_MANIFE = '" + cManifest + "' "
			Else
				cQuery += " AND DTC.DTC_FILDOC = '" + cFilDoc + "'"
				cQuery += " AND (DTC.DTC_DOC = '" + cDocto  + "' OR DTC.DTC_DOCPER = '" + cDocto + "')"
				cQuery += " AND DTC.DTC_SERIE = '" + cSerie  + "'"
			EndIf

			// Group By
			cQuery += " GROUP BY DV3REM.DV3_INSCR, DV3DES.DV3_INSCR, DTC.DTC_TIPNFC, DTC.DTC_DEVFRE, DTC.DTC_CODOBS, DTC.DTC_CTRDPC, DTC.DTC_SERDPC, DTC.DTC_TIPANT, DTC.DTC_CLIREC, DTC.DTC_LOJREC, "
			cQuery += " DTC.DTC_DPCEMI, DTC.DTC_CTEANT, DTC.DTC_SELORI, DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_CLIREM, DTC.DTC_LOJREM, DTC.DTC_SQEDES, DTC.DTC_FILORI, DTC.DTC_NUMSOL, "
			cQuery += " DTC.DTC_CLIEXP,	DTC.DTC_LOJEXP, "
			cQuery += " SB1.B1_DESC, SB1.B1_COD, SB1.B1_UM, "
			cQuery += " SB1.B1_TIPCAR,"
			cQuery += " SB1.B1_POSIPI,"
			cQuery += " SB1.B1_CODBAR,"			
			cQuery += " DUD.DUD_FILMAN,"
			cQuery += " DUD.DUD_MANIFE,"
			cQuery += " DUD.DUD_NUMROM,"
			cQuery += " DUD.DUD_FILORI,"
			cQuery += " DUD.DUD_VIAGEM,"
			cQuery += " DTC.DTC_FILDOC,"
			cQuery += " DTC.DTC_DOC,"
			cQuery += " DTC.DTC_SERIE,"
			cQuery += " DTC.DTC_SQIREM,"
			cQuery += " DTC.DTC_FILORI,"
			cQuery += " DTC.DTC_LOTNFC,"
			cQuery += " A1DES.A1_CEP, "
			cQuery += " A1REM.A1_CEP, "
			cQuery += " A1EXP.A1_CEP, "
			cQuery += " A1REC.A1_CEP "
			
			cQuery += " UNION "

			cQuery += " SELECT MAX(DTC.DTC_VALOR) AS MAX_DTC_VALOR,"
			cQuery +=			"DTC.DTC_TIPNFC,"
			cQuery +=			"DTC.DTC_DEVFRE,"
			cQuery +=			"DTC.DTC_CODOBS,"
			cQuery +=			"DTC.DTC_CTRDPC,"
			cQuery +=			"DTC.DTC_SERDPC,"
			cQuery +=			"DTC.DTC_TIPANT,"
			cQuery +=			"DTC.DTC_DPCEMI,"
			cQuery +=			"DTC.DTC_CTEANT,"
			cQuery +=			"DTC.DTC_SELORI,"
			cQuery +=			"DTC.DTC_CLIDES,"
			cQuery +=			"DTC.DTC_LOJDES,"
			cQuery +=			"DTC.DTC_CLIREM,"
			cQuery +=			"DTC.DTC_LOJREM,"
			cQuery +=			"A1DES.A1_CEP CEPDES,"
			cQuery +=			"DTC.DTC_SQEDES,"
			cQuery +=			"A1REM.A1_CEP CEPREM,"
			cQuery +=			"DTC.DTC_CLIREC,"
			cQuery +=			"DTC.DTC_LOJREC,"
			cQuery +=			"A1REC.A1_CEP CEPREC,"
			cQuery +=			"DTC.DTC_FILORI,"
			cQuery +=			"DTC.DTC_NUMSOL,"
			cQuery +=			"DTC.DTC_CLIEXP,"
			cQuery +=			"DTC.DTC_LOJEXP,"
			cQuery +=			"A1EXP.A1_CEP CEPEXP,"
			cQuery +=			"DTC.DTC_FILORI,"
			cQuery +=			"DTC.DTC_LOTNFC,"
			cQuery +=			"DV3REM.DV3_INSCR REMDV3_INSCR,"
			cQuery +=			"DV3DES.DV3_INSCR DESDV3_INSCR,"
			cQuery +=			"SB1.B1_DESC,"
			cQuery +=			"SB1.B1_COD,"
			cQuery +=			"SB1.B1_UM,"
			cQuery +=			"SB1.B1_POSIPI,"
			cQuery +=			"SB1.B1_CODBAR,"
			cQuery +=			"SB1.B1_TIPCAR,"
			cQuery +=			"DUD.DUD_FILMAN,"
			cQuery +=			"DUD.DUD_MANIFE,"
			cQuery +=			"DUD.DUD_NUMROM,"
			cQuery +=			"DUD.DUD_FILORI,"
			cQuery +=			"DUD.DUD_VIAGEM,"
			cQuery +=			"DTC.DTC_FILDOC,"
			cQuery +=			"DTC.DTC_DOC,"
			cQuery +=			"DTC.DTC_SERIE, "
			cQuery +=			"DTC.DTC_SQIREM "

			cQuery += " FROM " + RetSqlName("DUD") + " DUD "

			cQuery +=			" LEFT JOIN " + RetSqlName('DT6') + " DT6 "
			cQuery += 					" ON (DT6.DT6_FILIAL = '" + xFilial("DT6") + "'" 
			cQuery += 					" AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
			cQuery += 					" AND DUD.DUD_DOC = DT6.DT6_DOC "
			cQuery += 					" AND DUD.DUD_SERIE = DT6.DT6_SERIE "
			cQuery += 					" AND DT6.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('DTC') + " DTC "
			cQuery += 					" ON (DTC.DTC_FILIAL = '" + xFilial("DTC") + "'" 
			cQuery += 					" AND DT6.DT6_FILDCO = DTC.DTC_FILDOC "
			cQuery += 					" AND DT6.DT6_DOCDCO = DTC.DTC_DOC "
			cQuery += 					" AND DT6.DT6_SERDCO = DTC.DTC_SERIE "
			cQuery += 					" AND DT6.DT6_DOCDCO <> '' "
			cQuery += 					" AND DTC.DTC_DOC <> '' "
			cQuery += 					" AND DTC.D_E_L_E_T_ = ' ') "

			cQuery +=			" INNER JOIN " + RetSqlName('SB1') + " SB1 "
			cQuery += 					" ON (SB1.B1_FILIAL = '" + xFilial("SB1") + "'" 
			cQuery += 					" AND ( SB1.B1_COD = DTC.DTC_CODPRO ) "
			cQuery += 					" AND SB1.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('DV3') + " DV3REM "
			cQuery += 					" ON (DV3REM.DV3_FILIAL = '" + xFilial("DV3") + "'" 
			cQuery += 					" AND DV3REM.DV3_CODCLI = DTC.DTC_CLIREM "
			cQuery += 					" AND DV3REM.DV3_LOJCLI = DTC.DTC_LOJREM "
			cQuery += 					" AND DV3REM.DV3_SEQUEN = DTC.DTC_SQIREM "
			cQuery += 					" AND DV3REM.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('DV3') + " DV3DES "
			cQuery += 					" ON (DV3DES.DV3_FILIAL = '" + xFilial("DV3") + "'" 
			cQuery += 					" AND DV3DES.DV3_CODCLI = DTC.DTC_CLIDES "
			cQuery += 					" AND DV3DES.DV3_LOJCLI = DTC.DTC_LOJDES "
			cQuery += 					" AND DV3DES.DV3_SEQUEN = DTC.DTC_SQIdES "
			cQuery += 					" AND DV3DES.D_E_L_E_T_ = ' ') "

			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1REM "
			cQuery += 					" ON (A1REM.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1REM.A1_COD = DTC.DTC_CLIREM "
			cQuery += 					" AND A1REM.A1_LOJA = DTC.DTC_LOJREM "
			cQuery += 					" AND A1REM.D_E_L_E_T_ = ' ' ) "

			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1EXP "
			cQuery += 					" ON (A1EXP.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1EXP.A1_COD = DTC.DTC_CLIEXP "
			cQuery += 					" AND A1EXP.A1_LOJA = DTC.DTC_LOJEXP "
			cQuery += 					" AND A1EXP.D_E_L_E_T_ = ' ' ) "

			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1DES "
			cQuery += 					" ON (A1DES.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1DES.A1_COD = DTC.DTC_CLIDES "
			cQuery += 					" AND A1DES.A1_LOJA = DTC.DTC_LOJDES "
			cQuery += 					" AND A1DES.D_E_L_E_T_ = ' ' ) "

			cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1REC "
			cQuery += 					" ON (A1REC.A1_FILIAL = '" + xFilial("SA1") + "'" 
			cQuery += 					" AND A1REC.A1_COD = DTC.DTC_CLIREC "
			cQuery += 					" AND A1REC.A1_LOJA = DTC.DTC_LOJREC "
			cQuery += 					" AND A1REC.D_E_L_E_T_ = ' ' ) "

			cQuery += " WHERE "

			//???????????????????????????????????????????????????????????????????
			//? Se o tipo de Conhecimento for de Complemento, seleciona as      ?
			//? informacoes do CTR principal, pois o complemento nao tem DTC    ?
			//???????????????????????????????????????????????????????????????????
			If lComplemento
				cFildoc := cFilDco
				cDocto	:= cDocDco
				cSerie	:= cSerDco
			EndIf
			If !Empty(cFilMan) .And. !Empty(cManifest)
				cQuery += " DUD.DUD_FILMAN = '" + cFilMan + "' "
				cQuery += " AND DUD.DUD_MANIFE = '" + cManifest + "' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' '
			Else
				cQuery += " AND DTC.DTC_FILDOC = '" + cFilDoc + "'"
				cQuery += " AND (DTC.DTC_DOC = '" + cDocto  + "' OR DTC.DTC_DOCPER = '" + cDocto + "')"
				cQuery += " AND DTC.DTC_SERIE = '" + cSerie  + "'"
			EndIf

			// Group By
			cQuery += " GROUP BY DV3REM.DV3_INSCR, DV3DES.DV3_INSCR, DTC.DTC_TIPNFC, DTC.DTC_DEVFRE, DTC.DTC_CODOBS, DTC.DTC_CTRDPC, DTC.DTC_SERDPC, DTC.DTC_TIPANT, DTC.DTC_CLIREC, DTC.DTC_LOJREC, "
			cQuery += " DTC.DTC_DPCEMI, DTC.DTC_CTEANT, DTC.DTC_SELORI, DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_CLIREM, DTC.DTC_LOJREM, DTC.DTC_SQEDES, DTC.DTC_FILORI, DTC.DTC_NUMSOL, "
			cQuery += " DTC.DTC_CLIEXP,	DTC.DTC_LOJEXP, "
			cQuery += " SB1.B1_DESC, SB1.B1_COD, SB1.B1_UM, "
			cQuery += " SB1.B1_TIPCAR,"
			cQuery += " SB1.B1_POSIPI,"
			cQuery += " SB1.B1_CODBAR,"			
			cQuery += " DUD.DUD_FILMAN,"
			cQuery += " DUD.DUD_MANIFE,"
			cQuery += " DUD.DUD_NUMROM,"
			cQuery += " DUD.DUD_FILORI,"
			cQuery += " DUD.DUD_VIAGEM,"
			cQuery += " DTC.DTC_FILDOC,"
			cQuery += " DTC.DTC_DOC,"
			cQuery += " DTC.DTC_SERIE,"
			cQuery += " DTC.DTC_SQIREM,"
			cQuery += " DTC.DTC_FILORI,"
			cQuery += " DTC.DTC_LOTNFC,"
			cQuery += " A1DES.A1_CEP, "
			cQuery += " A1REM.A1_CEP, "
			cQuery += " A1EXP.A1_CEP, "
			cQuery += " A1REC.A1_CEP "

			cQuery += " ORDER BY MAX_DTC_VALOR DESC"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAll, .F., .T.)
			
			//-- Nao localizou documentos... Procura documentos de apoio...
			If ((cAliasAll)->(Eof())) .And. Empty(cFilMan) .And. Empty(cManifest)

				(cAliasAll)->(DbCloseArea())
				cQuery := " SELECT MAX(DTC.DTC_VALOR) AS MAX_DTC_VALOR,"
				cQuery +=			"DTC.DTC_TIPNFC,"
				cQuery +=			"DTC.DTC_DEVFRE,"
				cQuery +=			"DTC.DTC_CODOBS,"
				cQuery +=			"DTC.DTC_CTRDPC,"
				cQuery +=			"DTC.DTC_SERDPC,"
				cQuery +=			"DTC.DTC_TIPANT,"
				cQuery +=			"DTC.DTC_DPCEMI,"
				cQuery +=			"DTC.DTC_CTEANT,"
				cQuery +=			"DTC.DTC_SELORI,"
				cQuery +=			"DTC.DTC_CLIDES,"
				cQuery +=			"DTC.DTC_LOJDES,"
				cQuery +=			"A1DES.A1_CEP CEPDES,"
				cQuery +=			"DTC.DTC_SQEDES,"
				cQuery +=			"DTC.DTC_CLIREM,"
				cQuery +=			"DTC.DTC_LOJREM,"				
				cQuery +=			"A1REM.A1_CEP CEPREM,"
				cQuery +=			"DTC.DTC_SQEDES,"
				cQuery +=			"DTC.DTC_FILORI,"
				cQuery +=			"DTC.DTC_NUMSOL,"
				cQuery +=			"DTC.DTC_CLIEXP,"
				cQuery +=			"DTC.DTC_LOJEXP,"
				cQuery +=			"A1EXP.A1_CEP CEPEXP,"
				cQuery +=			"DTC.DTC_CLIREC,"
				cQuery +=			"DTC.DTC_LOJREC,"
				cQuery +=			"A1REC.A1_CEP CEPREC,"
				cQuery +=			"DTC.DTC_FILORI,"
				cQuery +=			"DTC.DTC_LOTNFC,"			
				cQuery +=			"DV3REM.DV3_INSCR REMDV3_INSCR,"
				cQuery +=			"DV3DES.DV3_INSCR DESDV3_INSCR,"
				cQuery +=			"SB1.B1_DESC,"
				cQuery +=			"SB1.B1_COD,"
				cQuery +=			"SB1.B1_UM,"
				cQuery +=			"SB1.B1_POSIPI,"
				cQuery +=			"SB1.B1_CODBAR,"
				cQuery +=			"SB1.B1_TIPCAR,"
				cQuery +=			"DUD.DUD_FILMAN,"
				cQuery +=			"DUD.DUD_MANIFE,"
				cQuery +=			"DUD.DUD_NUMROM,"
				cQuery +=			"DUD.DUD_FILORI,"
				cQuery +=			"DUD.DUD_VIAGEM,"
				cQuery +=			"DTC.DTC_FILDOC,"
				cQuery +=			"DTC.DTC_DOC,"
				cQuery +=			"DTC.DTC_SERIE,"
				cQuery +=			"DTC.DTC_SQIREM "

				cQuery += " FROM " + RetSqlName("DTC") + " DTC "

				cQuery +=			" INNER JOIN " + RetSqlName('SB1') + " SB1 "
				cQuery += 					" ON ( SB1.B1_COD = DTC.DTC_CODPRO ) "  
				cQuery += 					" AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
				cQuery += 					" AND SB1.D_E_L_E_T_ = ' '"

				cQuery +=			" LEFT JOIN " + RetSqlName('DV3') + " DV3REM "
				cQuery += 					" ON (DV3REM.DV3_FILIAL = '" + xFilial("DV3") + "'" 
				cQuery += 					" AND DV3REM.DV3_CODCLI = DTC.DTC_CLIREM "
				cQuery += 					" AND DV3REM.DV3_LOJCLI = DTC.DTC_LOJREM "
				cQuery += 					" AND DV3REM.DV3_SEQUEN = DTC.DTC_SQIREM "
				cQuery += 					" AND DV3REM.D_E_L_E_T_ = ' ') "

				cQuery +=			" LEFT JOIN " + RetSqlName('DV3') + " DV3DES "
				cQuery += 					" ON (DV3DES.DV3_FILIAL = '" + xFilial("DV3") + "'" 
				cQuery += 					" AND DV3DES.DV3_CODCLI = DTC.DTC_CLIDES "
				cQuery += 					" AND DV3DES.DV3_LOJCLI = DTC.DTC_LOJDES "
				cQuery += 					" AND DV3DES.DV3_SEQUEN = DTC.DTC_SQIDES "
				cQuery += 					" AND DV3DES.D_E_L_E_T_ = ' ') "

				cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1REM "
				cQuery += 					" ON (A1REM.A1_FILIAL = '" + xFilial("SA1") + "'" 
				cQuery += 					" AND A1REM.A1_COD = DTC.DTC_CLIREM "
				cQuery += 					" AND A1REM.A1_LOJA = DTC.DTC_LOJREM "
				cQuery += 					" AND A1REM.D_E_L_E_T_ = ' ' ) "

				cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1EXP "
				cQuery += 					" ON (A1EXP.A1_FILIAL = '" + xFilial("SA1") + "'" 
				cQuery += 					" AND A1EXP.A1_COD = DTC.DTC_CLIEXP "
				cQuery += 					" AND A1EXP.A1_LOJA = DTC.DTC_LOJEXP "
				cQuery += 					" AND A1EXP.D_E_L_E_T_ = ' ' ) "

				cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1DES "
				cQuery += 					" ON (A1DES.A1_FILIAL = '" + xFilial("SA1") + "'" 
				cQuery += 					" AND A1DES.A1_COD = DTC.DTC_CLIDES "
				cQuery += 					" AND A1DES.A1_LOJA = DTC.DTC_LOJDES "
				cQuery += 					" AND A1DES.D_E_L_E_T_ = ' ' ) "

				cQuery +=			" LEFT JOIN " + RetSqlName('SA1') + " A1REC "
				cQuery += 					" ON (A1REC.A1_FILIAL = '" + xFilial("SA1") + "'" 
				cQuery += 					" AND A1REC.A1_COD = DTC.DTC_CLIREC "
				cQuery += 					" AND A1REC.A1_LOJA = DTC.DTC_LOJREC "
				cQuery += 					" AND A1REC.D_E_L_E_T_ = ' ' ) "

				cQuery +=			" LEFT JOIN " + RetSqlName("DUD") + " DUD ON "
				cQuery += 					" DUD.D_E_L_E_T_ = ' ' "
				cQuery += 					" AND DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
				cQuery += 					" AND DUD.DUD_FILDOC = DTC.DTC_FILDOC "
				cQuery += 					" AND DUD.DUD_DOC    = DTC.DTC_DOC "
				cQuery += 					" AND DUD.DUD_SERIE  = DTC.DTC_SERIE "
				cQuery +=			" INNER JOIN " + RetSqlName("DT6") + " DT6 "
				cQuery += 					" ON DT6.DT6_FILIAL   = '" + xFilial("DT6") + "'" 
				cQuery += 					" AND DT6.DT6_CLIDEV   = '" + DT6->DT6_CLIDEV + "'"
				cQuery += 					" AND DT6.DT6_LOJDEV   = '" + DT6->DT6_LOJDEV + "'"
				cQuery += 					" AND DT6.DT6_PREFIX   = '" + DT6->DT6_PREFIX + "'"
				cQuery += 					" AND DT6.DT6_NUM      = '" + DT6->DT6_NUM    + "'"
				cQuery += 					" AND DT6.DT6_TIPO     = '" + DT6->DT6_TIPO   + "'"
				cQuery += 					" AND DT6.DT6_DOCTMS IN('B','C','H','I','N','O') "
				cQuery += 					" AND DT6.D_E_L_E_T_   = ' '"

				cQuery += " WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "'"
				cQuery +=		" AND DTC.D_E_L_E_T_   = ' '"

				If lComplemento
					cFildoc := cFilDco
					cDocto	:= cDocDco
					cSerie	:= cSerDco
				EndIf
				If !Empty(cFilMan) .And. !Empty(cManifest)
					cQuery += " AND DTC.DTC_FILDOC = DUD.DUD_FILDOC "
					cQuery += " AND (DTC.DTC_DOC = DUD.DUD_DOC "
					cQuery += " OR DTC.DTC_DOCPER = DUD.DUD_DOC) "
					cQuery += " AND DTC.DTC_SERIE = DUD.DUD_SERIE "
					cQuery += " AND DUD.DUD_FILMAN = '" + cFilMan + "' "
					cQuery += " AND DUD.DUD_MANIFE = '" + cManifest + "' "
				Else
					cQuery += " AND DTC.DTC_FILDOC = '" + cFilDoc + "'"
					cQuery += " AND (DTC.DTC_DOC = '" + cDocto  + "' OR DTC.DTC_DOCPER = '" + cDocto + "')"
					cQuery += " AND DTC.DTC_SERIE = '" + cSerie  + "'"
				EndIf

				cQuery += " GROUP BY DV3REM.DV3_INSCR, DV3DES.DV3_INSCR, DTC.DTC_TIPNFC, DTC.DTC_DEVFRE, DTC.DTC_CODOBS, DTC.DTC_CTRDPC, DTC.DTC_SERDPC, DTC.DTC_TIPANT, "
				cQuery += " DTC.DTC_DPCEMI, DTC.DTC_CTEANT, DTC.DTC_SELORI, DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_SQEDES, DTC.DTC_LOJREM, DTC.DTC_CLIREM, DTC.DTC_FILORI, DTC.DTC_NUMSOL, "
				cQuery += " DTC.DTC_CLIEXP,	DTC.DTC_LOJEXP, "
				cQuery += "	DTC.DTC_CLIREC, DTC.DTC_LOJREC,	"
				cQuery += " SB1.B1_DESC, SB1.B1_COD , SB1.B1_UM, "
				cQuery += " SB1.B1_TIPCAR, "
				cQuery += " SB1.B1_POSIPI, "
				cQuery += " SB1.B1_CODBAR, "				
				cQuery += " DUD.DUD_FILMAN, "
				cQuery += " DUD.DUD_MANIFE, "
				cQuery += " DUD.DUD_NUMROM, "
				cQuery += " DUD.DUD_FILORI, "
				cQuery += " DUD.DUD_VIAGEM, "
				cQuery += " DTC.DTC_FILDOC, "
				cQuery += " DTC.DTC_DOC, "
				cQuery += " DTC.DTC_SERIE, "
				cQuery += " DTC.DTC_SQIREM, "
				cQuery += " DTC.DTC_FILORI, "
				cQuery += " DTC.DTC_LOTNFC, "
				cQuery += " A1DES.A1_CEP, "
				cQuery += " A1REM.A1_CEP, "
				cQuery += " A1EXP.A1_CEP, "
				cQuery += " A1REC.A1_CEP "				

				cQuery += " ORDER BY MAX_DTC_VALOR DESC"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAll, .F., .T.)
				jResult['DOCTOAPOIO'] := !(cAliasAll)->(Eof())
			EndIf

			If !(cAliasAll)->(Eof())
									
				If ( AllTrim(DT6->DT6_DOCTMS) $ "6/7/8/P" .Or. cCTeUnico == '4' )
					cDTCObs    := NoAcentoCte( StrTran(MsMM(DT6->DT6_CODOBS),Chr(13),"") )
				EndIf
				
				If Empty(cDTCObs)
					cDTCObs    := NoAcentoCte( StrTran(MsMM((cAliasALL)->DTC_CODOBS),Chr(13),"") )
				Else
					cDTCObs    += " " + NoAcentoCte( StrTran(MsMM((cAliasALL)->DTC_CODOBS),Chr(13),"") )
				EndIf	
				jResult['OBSERVACAO'    ] := cDTCObs
				jResult['DOCTODPC'      ] := NoAcentoCte( (cAliasALL)->DTC_CTRDPC )
				jResult['SERIEDPC'      ] := NoAcentoCte( (cAliasALL)->DTC_SERDPC )
				jResult['TPDOCTOANT'    ] := NoAcentoCte( (cAliasALL)->DTC_TIPANT )
				jResult['EMISSAODPC'    ] := SubStr(AllTrim((cAliasALL)->DTC_DPCEMI), 1, 4) + "-";
											+ SubStr(AllTrim((cAliasALL)->DTC_DPCEMI), 5, 2) + "-";
											+ SubStr(AllTrim((cAliasALL)->DTC_DPCEMI), 7, 2)
				jResult['NRDOCTOANT'    ] := NoAcentoCte( (cAliasALL)->DTC_CTEANT)
				jResult['TIPONF'        ] := NoAcentoCte( (cAliasAll)->DTC_TIPNFC ) 
				JResult['DEVEDOR'       ] := (cAliasAll)->( DTC_DEVFRE ) //-- 1=Remetente;2=Destinatario;3=Consignatario;4=Despachante;6=Expedidor;7=Recebedor
				JResult['SELORIGEM'     ] := (cAliasAll)->( DTC_SELORI ) //-- Selecao de Origem 1=Transportadora;2=Cliente Remetente;3=Local Coleta ou Expedidor
				
				If (AllTrim((cAliasAll)->DTC_CLIDES) + AllTrim((cAliasAll)->DTC_LOJDES)) ==;
					(AllTrim(DT6->DT6_CLIDES) + AllTrim(DT6->DT6_LOJDES))
					JResult['SEQENDDES' ]   := (cAliasAll)->( DTC_SQEDES ) //-- Sequencia de EndereÁo do Destinat·rio
				EndIF
				
				JResult['FILORIGEM'     ] := (cAliasAll)->( DTC_FILORI )
				JResult['SOLICITACAO'   ] := (cAliasAll)->( DTC_NUMSOL )

				If !Empty((cAliasAll)->REMDV3_INSCR)
					JResult['INSREMOPC' ] := StrTran( (cAliasALL)->REMDV3_INSCR, ".", "" ) //-- InscriÁ„o estadual do Remetente do Clinte
				EndIf
				If !Empty((cAliasAll)->DESDV3_INSCR)
					JResult['INSDESOPC' ] := StrTran( (cAliasALL)->DESDV3_INSCR, ".", "" ) //-- InscriÁ„o estadual do Destinat·rio do Clinte
				EndIf

				If AllTrim(DT6->DT6_DOCTMS) == "6"
					JResult['INSAUXOPC'] := JResult['INSDESOPC' ]
					JResult['INSDESOPC'] := JResult['INSREMOPC' ]
					JResult['INSREMOPC'] := JResult['INSDESOPC' ]
				EndIf

				JResult['DSCPRODUTO'] := NoAcentoCte( (cAliasAll)->B1_DESC )
				JResult['PRODUTO'   ] := NoAcentoCte( (cAliasAll)->B1_COD  )
				JResult['UNIDMEDIDA'] := NoAcentoCte( (cAliasAll)->B1_UM   )
				JResult['cEAN'      ] := NoAcentoCte( (cAliasAll)->B1_CODBAR )
				JResult['NCM'       ] := NoAcentoCte( (cAliasAll)->B1_POSIPI )

				// *** TAG Lotacao ***
				DAR->(dbSetOrder(1))
				//Quando SelOri for remetente
				If (cAliasAll)->( DTC_SELORI ) == "1"
					JResult['cCEPOrigem'] := SM0->M0_CEPENT
				ElseIf (cAliasAll)->( DTC_SELORI ) == '2'
					JResult['cCEPOrigem'] := (cAliasAll)->CEPREM
					If DAR->(DBSeek(xFilial("DAR")+xFilial("SA1")+"SA1"+(cAliasAll)->DTC_CLIREM+(cAliasAll)->DTC_LOJREM)) 
						JResult['cOrigLatit'] := AllTrim(DAR->DAR_LATITU)
						JResult['cOrigLongi'] := AllTrim(DAR->DAR_LONGIT)
					EndIf
				ElseIf (cAliasAll)->( DTC_SELORI ) == '3' //Expedidor
					If !Empty((cAliasAll)->CEPEXP)
						JResult['cCEPOrigem'] := (cAliasAll)->CEPEXP
					Else
						DT5->( DbSetOrder( 3 ) )
						If	DT5->( MsSeek( xFilial('DT5') + (cAliasAll)->( DTC_NUMSOL )) )
							If Empty(DT5->DT5_SEQEND)
								DUE->(dbSetOrder(1))
								If DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
									JResult['cCEPOrigem'] := DUE->DUE_CEP
								EndIf
							Else
								DUL->(dbSetOrder(3))
								If DUL->(MsSeek(xFilial("DUL")+DT5->DT5_CODSOL+DT5->DT5_SEQEND))
									JResult['cCEPOrigem'] := DUL->DUL_CEP 
								EndIf
							EndIf
						EndIf
					EndIf
					If !Empty((cAliasAll)->DTC_SQIREM) .And. DAR->(DBSeek(xFilial("DAR")+xFilial("SA1")+"SA1"+((cAliasAll)->DTC_CLIEXP+(cAliasAll)->DTC_LOJEXP))) 
						JResult['cOrigLatit'] := AllTrim(DAR->DAR_LATITU)
						JResult['cOrigLongi'] := AllTrim(DAR->DAR_LONGIT)
					EndIf
				EndIf

				//Destinat·rio				
				If !Empty((cAliasAll)->DTC_CLIREC) 
					JResult['cCEPDestin'] := (cAliasAll)->CEPREC
					If DAR->(DBSeek(xFilial("DAR")+xFilial("SA1")+"SA1"+(cAliasAll)->DTC_CLIREC+(cAliasAll)->DTC_LOJREC))
						JResult['cDestLatit'] := AllTrim(DAR->DAR_LATITU)
						JResult['cDestLongi'] := AllTrim(DAR->DAR_LONGIT)
					EndIf
				Else
					JResult['cCEPDestin'] := (cAliasAll)->CEPDES
					If DAR->(DBSeek(xFilial("DAR")+xFilial("SA1")+"SA1"+(cAliasAll)->DTC_CLIDES+(cAliasAll)->DTC_LOJDES))					
						JResult['cDestLatit'] := AllTrim(DAR->DAR_LATITU)
						JResult['cDestLongi'] := AllTrim(DAR->DAR_LONGIT)
					EndIf
				EndIf

				DTQ->(DbSetOrder(1))
				If DTQ->(MsSeek(fwxFilial("DTQ")+(cAliasAll)->(DUD_FILORI + DUD_VIAGEM)))
					If DTQ->(ColumnPos('DTQ_TPOPVG')) > 0 .And. DLO->(ColumnPos('DLO_CODTPC')) > 0
						JResult['TIPOCARGA' ] := Posicione('DLO',1,FwxFilial('DLO')+DTQ->DTQ_TPOPVG,'DLO_CODTPC')
					EndIf
				EndIf

			EndIf
			(cAliasAll)->(DbCloseArea())
	
	RestArea(aAreaDTQ)
	RestArea(aAreaDT6)

Return JResult

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ TMSQtDocVg  ≥ Felipe M Barbiere       ≥ Data ≥ 09/03/2020  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Verifica quantos documentos ha na viagem ou MDF-e          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ TMSQtDocVg(cFilVge, cViagem, cFilMan, cManife)             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥   cFilVge, cViagem, cFilMan, cManife                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function TMSQtDocVg(cFilVge, cViagem, cFilMan, cManife, cSerman) 
Local cQuery 	:= ""
Local nQtdDoc 	:= 0
Local cAliasDUD := ""

Default cFilVge := ""
Default cViagem	:= ""
Default cFilMan := ""
Default cManife := ""
Default cSerman := ""  


//Verifica a quantidade de documentos da viagem
cQuery := " SELECT COUNT(DUD_DOC) QTDDOC "
cQuery += "   FROM " + RetSqlName("DUD")
cQuery += " Where DUD_FILIAL = '"+xFilial("DUD")+"'"
If !Empty(cFilVge) .And. !Empty(cViagem)
	cQuery += " AND DUD_FILORI = '" + cFilAnt + "'"
	cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
ElseIf !Empty(cFilMan) .And. !Empty(cManife) 
	cQuery += " AND DUD_FILMAN = '" + cFilMan + "'"
	cQuery += " AND DUD_MANIFE = '" + cManife + "'"
	If !Empty(cSerman)	
		cQuery += " AND DUD_SERMAN = '" + cSerman + "'" 
	EndIf
EndIf
cQuery += " AND DUD_STATUS <> '9' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
cAliasDUD := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.)
If (cAliasDUD)->(!Eof())
	nQtdDoc := (cAliasDUD)->QTDDOC
EndIf		
(cAliasDUD)->(DbCloseArea())

Return nQtdDoc


/*/{Protheus.doc} TMSMonPrev
//Monta o Preview a Pagar para a Montagem do XML do Manifesto Eletronico
@version undefined
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
@retorn aFrete
/*/
Function TMSMonPrev(cFilOri , cViagem )
Local bWhileVei		:= {||}
Local aRet			:= {}
Local aArea			:= GetArea()
Local aAreaDUP      := DUP->(GetArea())
Local aFornec		:= {}
Local aMsgErr		:= {}
Local aErros		:= {}
Local aFrete		:= {}
Local aDiaHist		:= {}
Local cSeekVei		:= ""
Local cMsgErr		:= ""
Local nGrupVei		:= 1
Local nCnt			:= 1
Local cTipCont      := "1"
Local cCodMot       := ""
Local cAliasVei		:= "DTR"
Local nValPedag     := 0
Local cCodOpe       := ""
Local nValAdto      := 0

//-- Variaveis utilizadas pela funcao FA050NAT2 (Fina050)
Private lGerTit   	:= GetMV('MV_GERTIT' ,,.T.) 
Private lF050Auto   := .F.
Private lAltera     := .F.
Private nOldValor   := 0
Private nOldIrr     := 0
Private nOldIss     := 0
Private nOldInss    := 0
Private nOldSEST    := 0

Default cFilOri     := ""
Default cViagem     := ""

//Preenche Array com todos os Fornecedores dos veÌculos da viagem
//Parametros da aFornec:                                         
//01- Codigo do Fornecedor                                       
//02- Loja do fornecedor                                         
//03- Codigo do Veiculo ou do Reboque                            
//04- Tipo da frota  1=PrÛpria; 2=Terceiro; 3=Agregado           
//05- Tipo do Veiculo                                            
//06- Grupo de Veiculo  0=Veiculo  1=1o Reb.  2=2oReb. 3=3oReb.  

If ExistFunc("A250FreCal")	
	DTR->(dbSetOrder(1))
	cSeekVei  := xFilial('DTR')+cFilOri+cViagem
	bWhileVei := {|| DTR->(! Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM == cSeekVei }
	If (cAliasVei)->(MsSeek(cSeekVei))
		While Eval(bWhileVei)
			aFornec	:= StaticCall(TMSA250,TMA250Forn,1,,"DTR")

			For nCnt := 1 To Len(aFornec)
				cCodForn	:= aFornec[nCnt,1]
				cLojForn	:= aFornec[nCnt,2]
				cCodVei		:= aFornec[nCnt,3]
				nGrupVei   	:= aFornec[nCnt,6]
				cMsgErr		:= ""
				aErros		:= {}

				//-- Motorista da Viagem
				DUP->(dbSetOrder(1))
				If DUP->(dbSeek(xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM)) 
					cCodMot:= DUP->DUP_CODMOT
				EndIf

				If nGrupVei == 0 //Veiculo
					nValPedag := DTR->DTR_VALPDG
					cCodOpe   := DTR->DTR_CODOPE
					nValAdto  := DTR->DTR_ADIFRE
				Else //1o e 2o Reboque
					nValPedag := 0
				EndIf

				aRet    :=  A250FreCal( cFilOri , cViagem, cCodForn , cLojForn , cCodVei, cCodMot, 3 ,cCodOpe, 'DTY' , cTipCont ,  , , .f. , nValPedag , nValAdto , nGrupVei, @aFrete, @aDiaHist , @aMsgErr, .T. )
				
				nCnt:= Len(aFornec) + 1 //Somente o Fornecedor Principal
			Next nCnt

			(cAliasVei)->(dbSkip())
		EndDo

	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDUP)
Return aRet

/*/{Protheus.doc} XMLIncCond
//Retorna os dados do motorista para a geraÁ„o do XML da inclus„o do condutor.
@version undefined
@param nViagem, nFilOri, cCodMot
@type function
@retorn aRet
/*/
Function XMLIncCond( nViagem, nFilOri, cCodMot, lUsaColab )

Local cQuery		:= ''
Local cAliasQry 	:= GetNextAlias()
Local cRet			:= ''

Default	nViagem		:= ''
Default nFilOri		:= ''
Default cCodMot		:= ''
Default lUsaColab   := .F.

		//Busca Motoristas para Inclus„o
		cQuery := " SELECT DUP.DUP_CODMOT, DA4.DA4_NOME, DA4.DA4_CGC "
		cQuery += " FROM " + RetSqlName('DUP') + " DUP "
		cQuery += " INNER JOIN " + RetSqlName('DA4') + " DA4 "
		cQuery += " ON DA4_FILIAL = '" + xFilial('DA4') + "'"
		cQuery += " AND DUP.DUP_CODMOT = DA4.DA4_COD "
		cQuery += " WHERE DUP.DUP_FILIAL = '" + xFilial('DUP') + "'"
		cQuery += " AND DUP.DUP_VIAGEM = '" + nViagem + "' "
		cQuery += " AND DUP.DUP_STMDFE <> '3' " //Somente Motorista nao transmitido.
		cQuery += " AND DUP.DUP_FILORI = '" + nFilOri + "' "
		cQuery += " AND DUP.DUP_CODMOT = '" + cCodMot + "' "
		cQuery += " AND DUP.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			If lUsaColab
				cRet+='<xNome>'+AllTrim(NoAcentoCte((cAliasQry)->DA4_NOME))+'</xNome>'
				cRet+='<CPF>'+AllTrim((cAliasQry)->DA4_CGC)+'</CPF>'	
			Else
				cRet+='<NOMECONDUTOR>'+AllTrim(NoAcentoCte((cAliasQry)->DA4_NOME))+'</NOMECONDUTOR>'
				cRet+='<CPFCONDUTOR>'+AllTrim((cAliasQry)->DA4_CGC)+'</CPFCONDUTOR>'	
			EndIf
		EndIf

(cAliasQry)->(dbCloseArea())

Return (cRet)

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AE70VldSt
@descricao:	A nova configuraÁ„o seria .T. para manter o status do documento de antes da recusa da SEFAZ, 
			e .F. n„o mantÈm o status do documento porÈm exibe o bot„o para ajuste manual. 
			O descritivo do par‚metro passar· a ser ìMantÈm status do documento na recusa do cancelamentoî.
@autor:		Rodrigo.Pirolo
@since:		12/08/2020
@using:		
@review:
@param:		
/*/
//----------------------------------------------------------------------------------------------------------

Function XSfVldSt( nRecnoDT6 )

Local lRet			:= .T.
Local lCTECan		:= SuperGetMv( "MV_CTECAN", .F., .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
Local lRtCTeId		:= SuperGetMv( "MV_RTCTEID", .F., .F. ) //-- Habilita o bot„o Retorno de Status

Default nRecnoDT6 := 0

If nRecnoDT6 > 0 .And. ExistFunc("AE70StDT6")
	DT6->(DbGoTo(nRecnoDT6))
	If !(DT6->DT6_SITCTE <> "1|0" .AND. DT6->DT6_STATUS == "B" .AND. DT6->DT6_IDRCTE == "100" .AND. lCTECan .AND. lRtCTeId)
		AE70StDT6(nRecnoDT6)
	Else
		lRet := .F.
	EndIf
	
EndIf

Return lRet
