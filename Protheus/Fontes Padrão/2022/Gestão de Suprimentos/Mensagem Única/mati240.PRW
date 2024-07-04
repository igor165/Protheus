#Include "PROTHEUS.CH"
#Include "FWADAPTEREAI.CH"
#Include "MATI240.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} MATI240
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
Function MATI240(cXML,nTypeTrans,cTypeMessage )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local nCount	:= 0
Local cXMLRet	:= ""
Local cXmlErro	:= ""
Local cXmlWarn	:= ""
Local cValExt	:= ""
Local cValInt	:= ""
Local cEvento	:= "upsert"
Local oXmlMvInt	:= Nil
Local cMarca    := ""

Private oXmlInt
Private lMsErroAuto := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

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
					cXmlRet := STR0021 //"Versão da mensagem não informada!"
					Return {lRet, cXmlRet}
				Endif
			EndIf
			
			If cVersao == "1"
				aRet := v1000(cXML,nTypeTrans,cTypeMessage)
				lRet := aRet[1]
				cXmlRet := aRet[2]
			Else
				lRet := .F.
				cXmlRet := STR0021 //"Versão da mensagem não implementada."
				Return {lRet, cXmlRet}
			EndIf
		Else  
			lRet    := .F.
			cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
		EndIf		
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		If FindFunction("CFGA070Mnt")	
			oXmlMvInt := XmlParser(cXml, "_", @cXmlErro, @cXmlWarn)
			
			If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
				cMarca  := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				cValInt := oXmlMvInt:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_MovementsInternal:_Destination:Text
				cValExt := oXmlMvInt:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_MovementsInternal:_Origin:Text
				oXmlMvInt := oXmlMvInt:_TotvsMessage     
				
				//-- Identifica se o processamento pelo parceiro ocorreu com sucesso
				If XmlChildEx(oXmlMvInt:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And. ;
					Upper(oXmlMvInt:_ResponseMessage:_ProcessingInformation:_Status:Text)=='OK'
		
					If !Empty(cValExt) .And.!Empty(cValInt)
						If CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
							lRet := .T.
						EndIf
					Else
						lRet := .F.
					EndIf
				Else
					lRet    := .F.
					cXmlRet := STR0019 //-- Processamento pela outra aplicação não teve sucesso
					
					//-- Transforma estrutura das mensagens de erro em array para concatenar com a mensagem de retorno
					If XmlChildEx( oXmlMvInt:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil .And. ;
								ValType(oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages)<>'A'
						XmlNode2Arr(oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_ListOfMessages")
					EndIf
				
					For nCount := 1 To Len( oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages )
						If XmlChildEx( oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount], '_MESSAGE' ) <> Nil
							cXmlRet += ' | ' + oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount]:_Message:Text
						EndIf	
					Next nCount
					
					If InTransact()
						DisarmTransaction()
					EndIf
				EndIf
			Else
				lRet    := .F.
				cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
			EndIf
		EndIf
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	EndIf
ElseIf nTypeTrans == TRANS_SEND
	
	If !Inclui .AND. !Altera
		cEvento	:=	"Delete"
	EndIf
	
	//Monta XML de envio de mensagem unica
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>MovementsInternal</Entity>'
	cXMLRet +=     '<Event>' +cEvento +'</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' +xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ) +'</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet += '	<CompanyId>' +cEmpAnt +'</CompanyId>'
	cXMLRet += '	<BranchId>' +xFilial("SD3") +'</BranchId>'
	cXMLRet +=      '<CompanyInternalId>' +cEmpAnt  +'</CompanyInternalId>'
	cXMLRet +=      '<InternalId>' +SD3->D3_FILIAL +'</InternalId>'
	cXMLRet += '    <typeMovementCode>' +SD3->D3_TM +'</typeMovementCode>' 		// codigo do tipo de movimento interno
	cXMLRet += '    <EmissionDate>' +DToS(SD3->D3_EMISSAO) +'</EmissionDate>'          		// data de emissao
	cXMLRet += '    <ItemCode>' +xFilial("SB1") +SD3->D3_COD +'</ItemCode>'      		// item/ produto
	cXMLRet += '    <UnitOfMeasureCode>' +xFilial("SAH") +SD3->D3_UM +'</UnitOfMeasureCode>'		// unidade de medida
	cXMLRet += '    <Quantity>' +Str(SD3->D3_QUANT) +'</Quantity>'      // quantidade
	cXMLRet += '    <WarehouseCode>' +xFilial("NNR") +SD3->D3_LOCAL +'</WarehouseCode>'          // codigo do armazem
	cXMLRet += '    <LotNumber>' +SD3->D3_LOTECTL +'</LotNumber>'          // numero do lote
	cXMLRet += '    <SubLotNumber>' +SD3->D3_NUMLOTE +'</SubLotNumber>'    // numero do sub-lote
	cXMLRet += '    <LotExpirationDate>' +DToS(SD3->D3_DTVALID) +'</LotExpirationDate>'		// data valida do lote
	cXMLRet += '    <FamilyCode>' +xFilial("SBM")+SD3->D3_GRUPO +'</FamilyCode>'			// grupo do produto
	cXMLRet += '    <Address>' +SD3->D3_LOCALIZ +'</Address>'              // endereço origem
	cXMLRet += '    <NumberSeries>' +SD3->D3_NUMSERI +'</NumberSeries>'    // numero de serie
	
	If SD3->D3_TM <= '500'
		cXMLRet += ' <InputOrOutput>E</InputOrOutput>'       // Identifica o tipo de movimento se E = Entrada, S = Saida
	ElseIf SD3->D3_TM > '500'
		cXMLRet += ' <InputOrOutput>S</InputOrOutput>'       // Identifica o tipo de movimento se E = Entrada, S = Saida
	EndIf
	
	cXMLRet += '</BusinessContent>'	
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
	Local aArea     := GetArea()
	Local dtEmiss   := CToD("")
	Local dtValLot  := CToD("")
	Local nQuant    := 0
	Local nCount    := 0
	Local nOpcx     := 0
	Local nI        := 0
	Local nPos      := 0
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
	//Local cNumOp    := "" Definida como Private no WSPCP.prw
	//Local cOperacao := "" Definida como Private no WSPCP.prw
	Local cRoteiro  := ""
	Local cQuery    := ""
	Local cNewAlias := GetNextAlias()
	Local aMovAux   := {}
	Local lOp       := .F.
	Local oXmlBusin

	Private oXmlMvInt
	Private nRegSD3 := 0

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
					cXmlRet := STR0022 //"Integração com o TOTVS MES desativada. Processamento não permitido."
					Return {lRet, cXMLRet}
				EndIf
			EndIf
			
			If XmlChildEx(oXmlBusin:_BusinessContent, '_INPUTOROUTPUT') <> NIL
				If AllTrim(Upper(cMarca)) == "PPI"
					dbSelectArea("SOE")
					SOE->(dbSetOrder(1))
					If SOE->(dbSeek(xFilial("SOE")+"SF5"))
						If (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "E"
							If SOE->(ColumnPos("OE_VAR4"))
								cTpMov := SOE->OE_VAR4
							EndIf
						ElseIf (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "S"
							cTpMov := SOE->OE_VAR2
						Else
							lRet := .F.
							cXmlRet := STR0023 //"InputOrOutput não é válido. Valores válidos: 'E'=Entrada, 'S'=Saída."
							Return {lRet, cXmlRet}
						EndIf
						If Empty(cTpMov)
							lRet := .F.
							cXmlRet := STR0024 //"Tipo de movimentação não cadastrado nos parâmetros do TOTVS MES (PCPA109)."
							Return {lRet, cXmlRet}
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0024 //"Tipo de movimentação não cadastrado nos parâmetros do TOTVS MES (PCPA109)."
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
						cXmlRet := "Tipo de movimentação não cadastrado nos parâmetros do TOTVS MES (PCPA109)." //"Tipo de movimentação não cadastrado nos parâmetros do TOTVS MES (PCPA109)."
					Else
						cXmlRet := STR0018 + "MV_MTI241E | MV_MTI241S" // "O Tipo de movimentação não foi cadastrado nos parâmetros "
					EndIf
				Else
					aAdd(aMovInt,{"D3_TM",cTpMov,})
				EndIf
			Else 
				lRet := .F.
				cXMLRet := STR0001 //"Não existe a Tag InputOrOutput"
			EndIf
			
			If lRet .And. FindFunction("CFGA070INT")
				If AllTrim(Upper(cMarca)) == "PPI"
					cValInt := cValExt
				Else
					cValInt := CFGA070INT(cMarca,'SD3','D3_NUMSEQ',cValExt)
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_ITEMCODE') <> NIL
						//cProdExt := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
						//cProd := CFGA070INT( cMarca, 'SB1', 'B1_COD', cProdExt )
						cProd := PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text,Len(SB1->B1_COD))
						If Type("lRunPPI") == "L" .And. lRunPPI
							cProduto := cProd //(cProduto) definida no WSPCP.prw. Utilizada para gerar a tabela SOG
						EndIf
						/*If SB1->(dbSeek(xFilial("SB1")+cProd))
							cProd := SB1->B1_COD*/
							aAdd(aMovInt,{"D3_COD",PadR(cProd,TamSX3("D3_COD")[1]),})
						/*Else
							lRet := .F.
							cXMLRet := STR0002 //'Não encontrado o Produto'
						EndIf*/
					Else
						lRet := .F.
						cXMLRet := STR0003 //'Não existe a Tag ItemCode'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_UNITOFMEASURECODE') <> NIL
						cUnMed := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureCode:Text
						aAdd(aMovInt,{"D3_UM",cUnMed,})
					Else
						lRet := .F.
						cXMLRet := STR0004 //'Não existe a Tag UnitOfMeasure'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_WAREHOUSECODE') <> NIL
						//cArmzmExt := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text
						//cArmzm := CFGA070INT( cMarca, 'NNR', 'NNR_CODIGO', cArmzmExt )
						cArmzm := PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text,Len(NNR->NNR_CODIGO))
						/*If NNR->(dbSeek(xFilial("NNR")+cArmzm))
							cArmzm := NNR->NNR_CODIGO*/
							aAdd(aMovInt,{"D3_LOCAL",PadR(cArmzm,TamSX3("D3_LOCAL")[1]),})
						/*Else
							lRet := .F.
							cXMLRet := STR0005 //'Não encontrado o Armazem'
						EndIf*/
					Else
						lRet := .F.
						cXMLRet := STR0006 //'Não existe a Tag "WarehouseCode"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_QUANTITY') <> NIL
						nQuant := VAL(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Quantity:Text)
						aAdd(aMovInt,{"D3_QUANT",nQuant,})
						If Type("lRunPPI") == "L" .And. lRunPPI
							nQtdSOG := nQuant //(nQtdSOG) definida no WSPCP.prw. Utilizada para gerar a tabela SOG
						EndIf
					Else
						lRet := .F.
						cXMLRet := STR0007 //'Não exite a Tag "Quantity"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_EMISSIONDATE') <> NIL    ///EmissionDate
						dtEmiss := StrTran(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text, '-', '')
						dtEmiss := STOD( dtEmiss )
						aAdd(aMovInt,{"D3_EMISSAO",dtEmiss,})
					Else
						lRet := .F.
						cXMLRet := STR0008 //'Não existe a Tag "Date"'
					EndIf
				EndIf
				
				If SuperGetMv("MV_RASTRO",.F.,"N") == "S" .And. Rastro(cProd) 
					If XmlChildEx(oXmlBusin:_BusinessContent, '_LOTNUMBER') <> NIL 
						cLote		:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotNumber:Text
						aAdd(aMovInt,{"D3_LOTECTL",cLote,})
					Else
						lRet := .F.
						cXMLRet := STR0009 //'Não existe a Tag "LotNumber"'
					EndIf
					
					If lRet .And. Rastro(cProd,"S") .And. XmlChildEx(oXmlBusin:_BusinessContent, '_SUBLOTNUMBER') <> NIL
						SD5->(dbSetOrder(2)) //D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
						If dbSeek(xFilial("SD5")+cProd+cArmzm+cLote+oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text)
							cSubLote	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text
							aAdd(aMovInt,{"D3_NUMLOTE",cSubLote,})
						EndIf
					EndIf
					
					If lRet
						If XmlChildEx(oXmlBusin:_BusinessContent, '_LOTEXPIRATIONDATE') <> NIL
							dtValLot 	:= StrTran( oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotExpirationDate:Text, '-', '')
							dtValLot	:= STOD( dtValLot )
							aAdd(aMovInt,{"D3_DTVALID",dtValLot,})
						Else
							lRet := .F.
							cXMLRet := STR0011 //'Não existe a Tag "LotExpirationDate"'
						EndIf
					EndIf						
				EndIf
				
				//Quando é integração com o TOTVS MES não utiliza o FAMILICODE
				If lRet .And. AllTrim(Upper(cMarca)) != "PPI"
					If XmlChildEx(oXmlBusin:_BusinessContent, '_FAMILYCODE') <> NIL
						//cGrpExt	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_FamilyCode:Text
						//cGrpPrd	:= CFGA070INT( cMarca, 'SBM', 'BM_GRUPO', cGrpExt )
						cGrpPrd	:= PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_FamilyCode:Text,Len(SBM->BM_GRUPO))
						/*If SBM->(dbSeek(xFilial("SBM")+cGrpPrd))
							cGrpPrd := SBM->BM_GRUPO*/
							aAdd(aMovInt,{"D3_GRUPO",cGrpPrd,})
						/*Else
							lRet := .F.
							cXMLRet := STR0012 //'Não encontrado o "Grupo de Produto"'
						EndIf*/
					Else
						lRet := .F.
						cXMLRet := STR0013 //'Não existe a Tag "GroupCode"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_ADDRESS') <> NIL
						cEnd	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address:Text
						aAdd(aMovInt,{"D3_LOCALIZ",cEnd,})
					Else
						lRet := .F.
						cXMLRet := STR0014 //'Não existe a Tag "Address"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_NUMBERSERIES') <> NIL
						cNumSer	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text
						aAdd(aMovInt,{"D3_NUMSERI",cNumSer,})
					Else
						lRet := .F.
						cXMLRet := STR0015 //'Não existe a Tag "NumberSeries"'
					EndIf
				EndIf
				
				If Upper(oXmlMvInt:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					Inclui	:= .T.
					nOpcx	:= 3	// Inclusao
				Else
					nOpcx	:= 5	// Estorno
					If AllTrim(Upper(cMarca)) == "PPI"
						SD3->(dbSetOrder(3))
						If SD3->(dbSeek(cValInt))
							aAdd(aMovInt,{"D3_NUMSEQ",SD3->D3_NUMSEQ,Nil})
							aAdd(aMovInt,{"INDEX",3,Nil})
							nRegSD3 := SD3->(Recno())
						EndIf
					Else
						aAdd(aMovInt,{"D3_NUMSEQ",Substr(cValInt,26,6),})
						aAdd(aMovInt,{"INDEX",7,})
					EndIf
				EndIf
			Else
				If lRet
					lRet   := .F.
					cXMLRet := STR0016 //"Atualize EAI"
				EndIf
			EndIf
			
			If lRet .And. AllTrim(Upper(cMarca)) == "PPI"
				aAdd(aMovInt,{"D3_OBSERVA","TOTVSMES",Nil})
			EndIf
			
			If lRet
				If XmlChildEx(oXmlBusin:_BusinessContent, '_PRODUCTIONORDERNUMBER') <> NIL
					cNumOp := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text
					If !Empty(cNumOp)
						dbSelectArea("SC2")
						SC2->(dbSetOrder(1))
						If SC2->(dbSeek(xFilial("SC2")+AllTrim(cNumOp))) 
							//Trata para caso o número do documento seja apenas uma parte de uma OP, que encontra no Seek.
							If AllTrim(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)) == AllTrim(cNumOp)
								aAdd(aMovInt,{"D3_OP" ,PadR(cNumOp,TamSX3("D3_OP")[1]),Nil})
								lOp := .T.
							Else
								aAdd(aMovInt,{"D3_DOC",cNumOp,Nil})
							EndIf
						Else
							aAdd(aMovInt,{"D3_DOC",cNumOp,Nil})
						EndIf
						
						If XmlChildEx(oXmlBusin:_BusinessContent, '_SCRIPTCODE') <> NIL
							cRoteiro := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ScriptCode:Text
						EndIf
						If XmlChildEx(oXmlBusin:_BusinessContent, '_ACTIVITYCODE') <> NIL
							cOperacao := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text
						EndIf
						
						//Se foi informado roteiro/operação, realiza a validação na SD4.
						If lOp .And. !Empty(cRoteiro) .And. !Empty(cOperacao) .And. SD4->(FieldPos("D4_ROTEIRO")) > 0
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
								cXmlRet := STR0025 //"Roteiro/Operação inválido para esta ordem de produção/produto."
								(cNewAlias)->(dbCloseArea())
								Return {lRet,cXmlRet}
							EndIf
							(cNewAlias)->(dbCloseArea())
						EndIf
					EndIf
				EndIf
			EndIf
			
		EndIf
		
		
		// PE MATI240CRG
		If lRet .And. ExistBlock('MATI240CRG')
			aMovAux := ExecBlock('MATI240CRG',.F.,.F.,aMovInt)
			For nCount := 1 To Len(aMovAux)
				//Verifica se o campo já existe no array aMovInt. Se já existir, substitui o valor.
				nPos := aScan(aMovInt,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aMovAux[nCount,1])) })
				If nPos == 0
					aAdd(aMovInt, {aMovAux[nCount,1],aMovAux[nCount,2], Nil})
				Else
					aMovInt[nPos,2] := aMovAux[nCount,2]
				EndIf
			Next nCount
		EndIf
		
		If lRet
			MsExecAuto({|x,y| MATA240(x,y)}, aMovInt, nOpcx)  
		
			If lMsErroAuto
				aErroAuto := GetAutoGRLog()
				cLogErro := getMsgErro(aErroAuto) 
				lRet	 := .F.
				cXMLRet := EncodeUTF8( cLogErro )					
			Else
				If nOpcx == 3
					cValInt := xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)
					CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
				Else
					CFGA070Mnt(,"SD3","D3_NUMSEQ",,cValInt,.T.)
				EndIf
				
				//-- Dados ok para gravação
				cXMLRet := '<ListOfInternalId>'
				cXMLRet += 	'<MovementsInternal>'
				cXMLRet += 		'<Origin>'     + cValExt +'</Origin>'
				cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
				cXMLRet += 	'</MovementsInternal>'
				cXMLRet += '</ListOfInternalId>'
			EndIf
		EndIf
	Else
		lRet    := .F.
		cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
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
