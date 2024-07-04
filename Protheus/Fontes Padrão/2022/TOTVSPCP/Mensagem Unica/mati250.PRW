#Include "PROTHEUS.CH"
#Include "FWADAPTEREAI.CH"
#Include "MATI250.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} MATI250
Programa de interpretacao da mensagem unica

@since 12/05/2016
@version P11
@param	cXML - Variavel com conteudo xml para envio/recebimento.
@param	nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param	cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
	aRet[1] - (boolean) Indica o resultado da execução da função
	aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Function MATI250(cXML,nTypeTrans,cTypeMessage )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local cXMLRet	:= ""
Local cXmlErro	:= ""
Local cXmlWarn	:= ""
Local cVersao   := ""

Private oXmlInt

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXmlInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
		If oXmlInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			// Versão da mensagem
			If Type("oXmlInt:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXmlInt:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXmlInt:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				If Type("oXmlInt:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXmlInt:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
					cVersao := StrTokArr(oXmlInt:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := STR0001 //"Versão da mensagem não informada!"
					Return {lRet, cXmlRet}
				Endif
			EndIf
			
			If cVersao == "1"
				aRet := v1000(cXML,nTypeTrans,cTypeMessage)
				lRet := aRet[1]
				cXmlRet := aRet[2]
			Else
				lRet := .F.
				cXmlRet := STR0002 //"Versão da mensagem não implementada."
				Return {lRet, cXmlRet}
			EndIf
		Else  
			lRet    := .F.
			cXMLRet := STR0003 + ' | ' +cXmlErro + ' | ' + cXmlWarn // "Erro ao realizar o parse do XML. "
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return {lRet,cXMLRet}

//-------------------------------------------------------------------
/*{Protheus.doc} v1000
Programa de interpretacao da mensagem unica

@since 09/11/2012
@version P11
@param	cXML - Variavel com conteudo xml para envio/recebimento.
@param	nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param	cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
	aRet[1] - (boolean) Indica o resultado da execução da função
	aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Static Function v1000(cXML,nTypeTrans,cTypeMessage)
	Local lRet      := .T.
	Local aErroAuto := {}
	Local aMovInt   := {}
	Local aCab      := {}
	Local aItens    := {}
	Local aArea     := GetArea()
	Local dtEmiss   := CToD("")
	Local dtValLot  := CToD("")
	Local nQuant    := 0
	Local nCount    := 0
	Local nOpcx     := 0
	Local nI        := 0
	Local cMarca    := ""
	Local cXMLRet   := ""
	Local cXmlErro  := ""
	Local cXmlWarn  := ""
	Local cValExt   := ""
	Local cValInt   := ""
	Local cLogErro  := ""
	Local cTpMov    := ""
	Local cProd     := ""
	Local cUnMed    := ""
	Local cArmzm    := ""
	Local cLote     := ""
	Local cSubLote  := ""
	Local cGrpPrd   := ""
	Local cEnd      := ""
	Local cNumSer   := ""
	Local cProdExt  := ""
	Local cArmzmExt := ""
	Local cGrpExt   := ""
	Local cEvento   := "upsert"
	//Local cNumOp    := "" //Definida como Private no WSPCP.prw
	//Local cOperacao := "" //Definida como Private no WSPCP.prw
	Local cRoteiro  := ""
	Local cQuery    := ""
	Local cNewAlias := GetNextAlias()
	Local aMovAux   := {}
	Local lEstorno  := .F.
	Local oXmlBusin

	Private oXmlMvInt
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private nRegSD3        := 0

	oXmlMvInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
	If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
		cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		oXmlBusin := oXmlMvInt:_TotvsMessage:_BusinessMessage
		If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil
			If XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
				If ValType(oXmlBusin:_BusinessEvent:_Identification:_Key) == "O"
					cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
				ElseIf ValType(oXmlBusin:_BusinessEvent:_Identification:_Key) == "A"
					For nI := 1 To Len(oXmlBusin:_BusinessEvent:_Identification:_Key)
						If ! AllTrim(Upper(oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:_Name:Text)) $ "IDPCFACTORY|REPROCESS"
							If AllTrim(Upper(cMarca)) == "PPI" .And. AllTrim(Upper(oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:_Name:Text)) == "ESTORNO"
								cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:Text
								Exit
							Else
								cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:Text
								Exit
							EndIf
						EndIf
					Next nI
				EndIf
			EndIf
			
			If AllTrim(Upper(cMarca)) == "PPI"
				If !PCPIntgPPI()
					lRet := .F.
					cXmlRet := STR0004 //"Integração com o TOTVS MES desativada. Processamento não permitido."
					Return {lRet, cXMLRet}
				EndIf
			EndIf
			
			cValInt := cValExt
			
			If XmlChildEx(oXmlBusin:_BusinessContent, '_INPUTOROUTPUT') <> NIL
				If AllTrim(Upper(cMarca)) == "PPI"
					dbSelectArea("SOE")
					SOE->(dbSetOrder(1))
					If SOE->(dbSeek(xFilial("SOE")+"SF5"))
						If (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "E"
							cTpMov := SOE->OE_VAR1
						ElseIf (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "S"
							cTpMov := SOE->OE_VAR2
						Else
							lRet := .F.
							cXmlRet := STR0005 //"InputOrOutput não é válido. Valores válidos: 'E'=Entrada, 'S'=Saída."
							Return {lRet, cXmlRet}
						EndIf
						If Empty(cTpMov)
							lRet := .F.
							cXmlRet := STR0006 //"Tipo de movimentação não cadastrado nos parâmetros do TOTVS MES (PCPA109)."
							Return {lRet, cXmlRet}
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0006 //"Tipo de movimentação não cadastrado nos parâmetros do TOTVS MES (PCPA109)."
						Return {lRet, cXmlRet}
					EndIf
				Else
					If (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "E"
						cTpMov	:= SuperGetMv('MV_MTI241E',.F.,"")
					ElseIf (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "S"
						cTpMov	:= SuperGetMv('MV_MTI241S',.F.,"")
					EndIf
				EndIf
		
				If Valtype(cTpMov) <> 'C' .Or. Empty(cTpMov)
					lRet := .F.
					If AllTrim(Upper(cMarca)) == "PPI"
						cXmlRet := STR0006 //"Tipo de movimentação não cadastrado nos parâmetros do TOTVS MES (PCPA109)."
					Else
						cXmlRet := STR0007 // "O Tipo de movimentação não foi cadastrado nos parâmetros "
					EndIf
				Else
					aAdd(aMovInt,{"D3_TM",cTpMov,})
				EndIf
			Else 
				lRet := .F.
				cXMLRet := STR0008 //"Não existe a Tag InputOrOutput"
			EndIf
			
			If lRet
				If XmlChildEx(oXmlBusin:_BusinessContent, '_ITEMCODE') <> NIL .And. ;
				   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text)
					cProd := PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text,TamSX3("B1_COD")[1])
					If Type("lRunPPI") == "L" .And. lRunPPI
						cProduto := cProd //(cProduto) definida no WSPCP.prw. Utilizada para gerar a tabela SOG
					EndIf
					aAdd(aMovInt,{"D3_COD",PadR(cProd,TamSX3("D3_COD")[1]),})
				Else
					lRet := .F.
					cXMLRet := STR0009 //'Não existe a Tag ItemCode'
				EndIf
				
				If XmlChildEx(oXmlBusin:_BusinessContent, '_PRODUCTIONORDERNUMBER') <> NIL .And. ;
					!Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text)
					cNumOp := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text
					aAdd(aMovInt,{"D3_OP" ,PadR(cNumOp,TamSX3("D3_OP")[1]),Nil})
					If XmlChildEx(oXmlBusin:_BusinessContent, '_SCRIPTCODE') <> NIL
						cRoteiro := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ScriptCode:Text
					EndIf
					If XmlChildEx(oXmlBusin:_BusinessContent, '_ACTIVITYCODE') <> NIL
						cOperacao := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text
					EndIf
					
					//Se foi informado roteiro/operação, realiza a validação na SD4.
					If !Empty(cRoteiro) .And. !Empty(cOperacao) .And. SD4->(FieldPos("D4_ROTEIRO")) > 0
						cQuery := " SELECT COUNT(*) TOTAL "
						cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
						cQuery +=  " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
						cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "
						cQuery +=    " AND SD4.D4_COD     = '" + cProd + "' "
						cQuery +=    " AND SD4.D4_OP      = '" + cNumOp + "' "
						cQuery +=    " AND SD4.D4_ROTEIRO = '" + cRoteiro + "' "
						cQuery +=    " AND SD4.D4_OPERAC  = '" + cOperacao + "' "
						
						cQuery := ChangeQuery(cQuery)
						
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNewAlias,.T.,.T.)
						If (cNewAlias)->(TOTAL) < 1
							lRet := .F.
							cXmlRet := STR0013 //"Roteiro/Operação inválido para esta ordem de produção/produto."
							(cNewAlias)->(dbCloseArea())
							Return {lRet,cXmlRet}
						EndIf
						(cNewAlias)->(dbCloseArea())
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_WAREHOUSECODE') <> NIL .And. ;
						!Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text)
						cArmzm := PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text,TamSX3("NNR_CODIGO")[1])
						aAdd(aMovInt,{"D3_LOCAL",PadR(cArmzm,TamSX3("D3_LOCAL")[1]),})
					Else
						lRet := .F.
						cXMLRet := STR0010 //'Não existe a Tag "WarehouseCode"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_QUANTITY') <> NIL .And. ;
					   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Quantity:Text)
						nQuant := VAL(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Quantity:Text)
						If Type("lRunPPI") == "L" .And. lRunPPI
							nQtdSOG := nQuant //(nQtdSOG) definida no WSPCP.prw. Utilizada para gerar a tabela SOG
						EndIf
						aAdd(aMovInt,{"D3_QUANT",nQuant,})
					Else
						lRet := .F.
						cXMLRet := STR0011 //'Não exite a Tag "Quantity"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_EMISSIONDATE') <> NIL .And. ;    ///EmissionDate
					   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text)
						dtEmiss := StrTran(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text, '-', '')
						dtEmiss := STOD( dtEmiss )
						aAdd(aMovInt,{"D3_EMISSAO",dtEmiss,})
					Else
						lRet := .F.
						cXMLRet := STR0012 //'Não existe a Tag "EmissionDate"'
					EndIf
				EndIf
				
				//If SuperGetMv("MV_RASTRO",.F.,"N") == "S" .And. Rastro(cProd) 
					If XmlChildEx(oXmlBusin:_BusinessContent, '_LOTNUMBER') <> NIL .And. ;
					   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotNumber:Text) 
						cLote		:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotNumber:Text
						aAdd(aMovInt,{"D3_LOTECTL",cLote,})
					EndIf
					
					If lRet .And. Rastro(cProd,"S") .And. XmlChildEx(oXmlBusin:_BusinessContent, '_SUBLOTNUMBER') <> NIL .And. ;
					   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text)
						SD5->(dbSetOrder(2)) //D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
						If dbSeek(xFilial("SD5")+cProd+cArmzm+cLote+oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text)
							cSubLote	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text
							aAdd(aMovInt,{"D3_NUMLOTE",cSubLote,})
						EndIf
					EndIf
					
					If lRet
						If XmlChildEx(oXmlBusin:_BusinessContent, '_LOTEXPIRATIONDATE') <> NIL .And. ;
						   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotExpirationDate:Text)
							dtValLot 	:= StrTran( oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotExpirationDate:Text, '-', '')
							dtValLot	:= STOD( dtValLot )
							aAdd(aMovInt,{"D3_DTVALID",dtValLot,})
						EndIf
					EndIf						
				//EndIf
			EndIf
			
			If lRet .And. AllTrim(Upper(cMarca)) == "PPI"
				aAdd(aMovInt,{"D3_OBSERVA","TOTVSMES",Nil})
			EndIf	
		EndIf
		
		
		// PE MATI240CRG
		If lRet .And. ExistBlock('MATI250CRG')
			aMovAux := ExecBlock('MATI250CRG',.F.,.F.,aMovInt)
			For nCount := 1 To Len(aMovAux)
				//Adiciona no array da SD3 somente os campos que não recebem informações do XML recebido.
				If aScan(aMovInt,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aMovAux[nCount,1])) }) == 0
					aAdd(aMovInt, {aMovAux[nCount,1],aMovAux[nCount,2], Nil})
				EndIf
			Next nCount
		EndIf
		
		If Upper(oXmlMvInt:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
			lEstorno := .T.
			SD3->(dbSetOrder(3))
			If SD3->(dbSeek(cValInt))
				aAdd(aMovInt,{"D3_NUMSEQ",SD3->D3_NUMSEQ,Nil})
				aAdd(aMovInt,{"INDEX",3,Nil})
				nRegSD3 := SD3->(Recno())
			EndIf
		EndIf
		
		If lRet
			BeginTran()
			
			If lEstorno
				//Se for estorno, primeiro executa o estorno do endereçamento.
				cEnd    := ""
				cNumSer := ""
				If XmlChildEx(oXmlBusin:_BusinessContent, '_ADDRESS') <> NIL .And. ;
				   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address:Text)
					cEnd	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address:Text
					aAdd(aMovInt,{"D3_LOCALIZ",cEnd,})
				EndIf
				
				If XmlChildEx(oXmlBusin:_BusinessContent, '_NUMBERSERIES') <> NIL .And. ;
				   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text)
					cNumSer	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text
					aAdd(aMovInt,{"D3_NUMSERI",cNumSer,})
				EndIf
				
				//Se foi enviado endereço, faz o endereçamento do produto no MATA265.
				If !Empty(cEnd) .Or. !Empty(cNumSer)
					dbSelectArea("SDA")
					SDA->(dbSetOrder(1))
					If !SDA->(dbSeek(xFilial("SDA")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)))
						cXmlRet := "Não foi possível encontrar o registro para estornar o endereçamento."
						lRet := .F.
						DisarmTransaction()
						Return {lRet,cXmlRet}
					EndIf
					aCab := {{"DA_PRODUTO",SD3->D3_COD   , nil},;
								{"DA_LOCAL"  ,SD3->D3_LOCAL  , nil},;
								{"DA_NUMSEQ" ,SD3->D3_NUMSEQ , nil},; 
								{"DA_DOC"    ,SD3->D3_DOC    , nil}}

					lAchou := .F.
					SDB->(dbSetOrder(1))
					If SDB->(dbSeek(xFilial("SDB")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC)))
						While SDB->(!Eof()) .And. SDB->(DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC) == ;
						                          xFilial("SDB")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC)
							If (Empty(cEnd) .Or. (!Empty(cEnd) .And. AllTrim(SDB->DB_LOCALIZ) == AllTrim(cEnd))) .And. ;
								(Empty(cNumSer) .Or. (!Empty(cNumSer) .And. AllTrim(SDB->DB_SERIE) == AllTrim(cNumSer))) .And. SDB->DB_ESTORNO != "S"
								lAchou := .T.
								Exit
							EndIf
							SDB->(dbSkip())
						End
					EndIf
					If !lAchou
						lRet	:= .F.
						cXMLRet := "Não foi possível localizar o endereçamento do produto '" + AllTrim(SD3->D3_COD) + "' para realização do estorno." 
						DisarmTransaction()
					Else
						aItens := {{{'DB_ITEM',SDB->DB_ITEM,NIL},;
									{'DB_LOCAL',SDB->DB_LOCAL,NIL},;
									{'DB_LOCALIZ',SDB->DB_LOCALIZ,NIL},;
									{'DB_QUANT',SDB->DB_QUANT,NIL},;
									{'DB_DATA',SDB->DB_DATA,NIL},;
									{'DB_PRODUTO',SDB->DB_PRODUTO,NIL},;
									{'DB_NUMSERI',SDB->DB_NUMSERI,NIL},;
									{'DB_ESTORNO','S',Nil}}}
					
						lMSErroAuto := .F.
						msExecAuto({|x,y,z| mata265(x,y,z)},aCab,aItens,4)
						If lMsErroAuto
							aErroAuto := GetAutoGRLog() 
							cLogErro := getMsgErro(aErroAuto)
							
							lRet	 := .F.
							cXMLRet := EncodeUTF8( cLogErro )
							DisarmTransaction()
						EndIf
					EndIf
				EndIf
			EndIf
			
			If lRet
				MsExecAuto({|x,y| MATA250(x,y)}, aMovInt, Iif(lEstorno,5,3))  
				If lMsErroAuto
					aErroAuto := GetAutoGRLog() 
					cLogErro := getMsgErro(aErroAuto)
					
					lRet	 := .F.
					cXMLRet := EncodeUTF8( cLogErro )
					DisarmTransaction()					
				Else
					cEnd    := ""
					cNumSer := ""
					If XmlChildEx(oXmlBusin:_BusinessContent, '_ADDRESS') <> NIL .And. ;
					   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address:Text)
						cEnd	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address:Text
						aAdd(aMovInt,{"D3_LOCALIZ",cEnd,})
					EndIf
					
					If XmlChildEx(oXmlBusin:_BusinessContent, '_NUMBERSERIES') <> NIL .And. ;
					   !Empty(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text)
						cNumSer	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text
						aAdd(aMovInt,{"D3_NUMSERI",cNumSer,})
					EndIf
					
					//Se foi enviado endereço, faz o endereçamento do produto no MATA265.
					If !lEstorno .And. (!Empty(cEnd) .Or. !Empty(cNumSer))
						dbSelectArea("SDA")
						SDA->(dbSetOrder(1))
						If !SDA->(dbSeek(xFilial("SDA")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)))
							cXmlRet := "Não foi possível encontrar o registro para realizar o endereçamento."
							lRet := .F.
							DisarmTransaction()
							Return {lRet,cXmlRet}
						EndIf
						aCab := {{"DA_PRODUTO",SD3->D3_COD   , nil},;
									{"DA_LOCAL"  ,SD3->D3_LOCAL  , nil},;
									{"DA_NUMSEQ" ,SD3->D3_NUMSEQ , nil},; 
									{"DA_DOC"    ,SD3->D3_DOC    , nil}}
	
						aItens := {{{'DB_ITEM',StrZero(1,TamSX3("DB_ITEM")[1]),NIL},;
										{'DB_LOCAL',SD3->D3_LOCAL,NIL},;
										{'DB_LOCALIZ',cEnd,NIL},;
										{'DB_QUANT',SD3->D3_QUANT,NIL},;
										{'DB_DATA',dDataBase,NIL},;
										{'DB_PRODUTO',SD3->D3_COD,NIL},;
										{'DB_NUMSERI',cNumSer,NIL}}}
						
						lMSErroAuto := .F.
						msExecAuto({|x,y,z| mata265(x,y,z)},aCab,aItens,3)
						If lMsErroAuto
							aErroAuto := GetAutoGRLog() 
							cLogErro := getMsgErro(aErroAuto)
							
							lRet	 := .F.
							cXMLRet := EncodeUTF8( cLogErro )
							DisarmTransaction()
						Else
							cValInt := xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)
							CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
							
							//-- Dados ok para gravação
							cXMLRet := '<ListOfInternalId>'
							cXMLRet += 	'<MovementsInternal>'
							cXMLRet += 		'<Origin>'     + cValExt +'</Origin>'
							cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
							cXMLRet += 	'</MovementsInternal>'
							cXMLRet += '</ListOfInternalId>'
						EndIf
					Else
						cValInt := xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)
						CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
						
						//-- Dados ok para gravação
						cXMLRet := '<ListOfInternalId>'
						cXMLRet += 	'<MovementsInternal>'
						cXMLRet += 		'<Origin>'     + cValExt +'</Origin>'
						cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
						cXMLRet += 	'</MovementsInternal>'
						cXMLRet += '</ListOfInternalId>'
					EndIf
				EndIf
			EndIf
			EndTran()
		EndIf
	Else
		lRet    := .F.
		cXMLRet := STR0003 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Erro ao realizar o parse do XML "
	EndIf
Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getMsgErro

Transforma o array com as informações de um erro em uma string para ser retornada.

@param aErro - Array com a mensagem de erro, obtido através da função GetAutoGRLog

@return cMsg - Mensagem no formato String

@author  Lucas Konrad França
@version P12
@since   07/03/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function getMsgErro(aErro)
	Local cMsg   := ""
	Local nCount := 0
	
	For nCount := 1 To Len(aErro)
		If AT(':=',aErro[nCount]) > 0 .And. AT('< --',aErro[nCount]) < 1
			Loop
		EndIf
		If AT("------", aErro[nCount]) > 0
			Loop
		EndIf
		//Retorna somente a mensagem de erro (Help) e o valor que está inválido, sem quebras de linha e sem tags '<>'
		If !Empty(cMsg)
			cMsg += " "
		EndIf
		cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
	Next nCount
	
	If Empty(cMsg) .And. Len(aErro) > 0
		For nCount := 1 To Len(aErro)
			If !Empty(cMsg)
				cMsg += " "
			EndIf
			cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
		Next nCount
	EndIf

Return cMsg