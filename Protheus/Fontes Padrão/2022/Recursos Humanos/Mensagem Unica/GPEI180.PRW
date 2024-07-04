#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEI180.CH"

#Define	cEol	Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEI180    ºAutor  ³ Flavio Correa      º Data ³  03/06/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e   º±±
±±º          ³ envio de informacoes de Transferencias		               º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONA160                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GPEI180(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aArea		:= GetArea()
Local lRet     	:= .T.
Local cXMLRet  	:= ""
Local oXmlFunc	:= ""
Local cXmlErro	:= ""
Local cXmlWarn	:= ""
Local cEvento	:= "upsert"
Local cValExt	:= ""
Local cValInt 	:= ""
Local cVersoesOk 	:= "1.000|"
Local cAux			:= ""
Local nOpcx			:= 3
Local nI			:= 1
/*DADOS DA ORIGEM DO FUNCIONÁRIO*/
Local cEmpOrigem	:= ""
Local cFilOrigem	:= ""
Local cMatOrigem	:= ""
/*DADOS DO DESTINO DO FUNCIONÁRIO*/
Local cEmpDestino 	:= ""
Local cFilialDestino := ""
Local cMatDestino 	:= ""
Local cDeptDestino 	:= ""
Local cCCDestino 	:= ""


Default cVersion 	:= "1.000"

Private oXml           := ""

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS
			lRet := .F.
			cXMLRet	:= STR0012 //"Adapter não preperado para recepção de mensagens"

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			//  tratando a recepção da mensagem quando é realizado envio
			TrataResp( @lRet, @cXMLRet, cXml )

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS

			cXmlRet := cVersoesOk

		EndIf

	ElseIf nTypeTrans == TRANS_SEND
		lRet := .T.
		/*
		cValInt := GPEI180Snd( {  cEmpAnt, xFilial("SRE"), SRE->RE_MATD } )

		cXMLRet +='<BusinessEvent>'
		cXMLRet +=     '<Entity>EmployeeBranchTransfer</Entity>'
		cXMLRet +=     '<Event>'+ cEvento +'</Event>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="Code">'+ cValInt +'</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet +='</BusinessEvent>'
		cXMLRet +='<BusinessContent>'
		cXMLRet +=  '<CompanyId>'+ cEmpAnt +'</CompanyId>'
		cXMLRet +=  '<BranchId>'+ xFilial("SRE") +'</BranchId>'
		cXMLRet +=  '<CompanyInternalId>'+ cEmpAnt+"|"+xFilial("SRE") +'</CompanyInternalId>'
		cXMLRet +=  '<EmployeeCode>'+SRE->RE_MATD+'</EmployeeCode>'
		cXMLRet +=  '<EmployeeInternalId>'+IntFunExt( cEmpAnt, xFilial("SRE"), SRE->RE_MATD, "2.000" )[2]+'</EmployeeInternalId>'
		cXMLRet +=  '<EmployeeBranchTransfered>'
		cXMLRet +=  '	<CompanyId>'+SRE->RE_EMPP+'</CompanyId>'
		cXMLRet +=  '   <CompanyInternalId>'+ SRE->RE_EMPP+"|"+SRE->RE_FILIALP +'</CompanyInternalId>'
		cXMLRet +=  '   <BranchId>'+SRE->RE_FILIALP+'</BranchId>'
		cXMLRet +=  '   <TransferDate>'+Transform(DTOS(SRE->RE_DATA), "@R 9999-99-99")+'</TransferDate>'
		cXMLRet +=  '   <EmployeeCode>'+SRE->RE_MATP+'</EmployeeCode>'
		cXMLRet +=  '   <EmployeeInternalId>'+IntFunExt( cEmpAnt, SRE->RE_FILIALP, SRE->RE_MATP, "2.000" )[2]+'</EmployeeInternalId>'
		cXMLRet +=  '   <DepartamentCode>' + SRE->RE_DEPTOP + '</DepartamentCode>'
		cXMLRet +=  '   <DepartamentInternalId>' + SRE->RE_EMPP + '|' + xFilial("SQB",SRE->RE_FILIALP) + '|' + SRE->RE_DEPTOP + '</DepartamentInternalId>'
		cXMLRet +=  '   <CostCenterCode>' + SRE->RE_CCP + '</CostCenterCode>'
		cXMLRet +=  '   <CostCenterInternalId>'+IntCusExt( , xFilial("CTT",SRE->RE_FILIALP), SRE->RE_CCP, '2.000')[2]+'</CostCenterInternalId>'
		cXMLRet +=  '   <ValueClass>' + SRE->RE_CLVLP + '</ValueClass>'
		cXMLRet +=  '   <AccountancyItem>' + SRE->RE_ITEMP + '</AccountancyItem>'
		cXMLRet +=  '   <OccupationPlaceCode>' + SRE->RE_POSTOP + '</OccupationPlaceCode>'
		cXMLRet +=  '   <OccupationPlaceInternalId></OccupationPlaceInternalId>'
		cXMLRet +=  '</EmployeeBranchTransfered>
		cXMLRet +='</BusinessContent>'
		*/

		cEmpOrigem	:= SRE->RE_EMPD

		/*DADOS DA ORIGEM DO FUNCIONÁRIO*/
		cFilOrigem	:= SubStr(SRE->RE_FILIALD, 1, FWGETTAMFILIAL)
		cMatOrigem	:= SRE->RE_MATD

		/*DADOS DO DESTINO DO FUNCIONÁRIO*/
		cEmpDestino 	:= SRE->RE_EMPP
		cFilialDestino	:= SubStr(SRE->RE_FILIALP, 1, FWGETTAMFILIAL)
		cMatDestino 	:= SRE->RE_MATP
		cDeptDestino 	:= SRE->RE_DEPTOP
		cCCDestino 		:= SRE->RE_CCP

		cXmlRet := '<BusinessContent>'+cEol
		cXmlRet += '  <EmployeeBranchTranferring>'+cEol

		/*ORIGEM*/
		cXmlRet += '      <EmployeeTransferring>'+cEol
		cXmlRet += GetClosedTag('CompanyId',cEmpOrigem)
		cXmlRet += GetClosedTag('BranchId',cFilOrigem)
		cXmlRet += GetClosedTag('CompanyInternalId',cEmpOrigem+"|"+cFilOrigem)
		cXmlRet += GetClosedTag('EmployeeInternalId',IntFunExt( cEmpOrigem, cFilOrigem, cMatOrigem, "2.000" )[2])
		cXmlRet += GetClosedTag('Code',AllTrim(cMatOrigem))
		cXmlRet += '      </EmployeeTransferring>'+cEol

		/*DESTINO*/
		cXmlRet += '      <EmployeeTransfered>'+cEol
		cXmlRet += GetClosedTag('CompanyId',cEmpDestino)
		cXmlRet += GetClosedTag('CompanyInternalId',cEmpDestino+"|"+cFilialDestino)
		cXmlRet += GetClosedTag('BranchId',cFilialDestino)
		cXmlRet += GetClosedTag('EmployeeInternalId',IntFunExt( cEmpDestino, cFilialDestino, cMatDestino, "2.000" )[2] )
		cXmlRet += GetClosedTag('Code',AllTrim(cMatDestino))
		cXmlRet += GetClosedTag('DepartamentCode',cDeptDestino)
		cXmlRet += GetClosedTag('DepartamentInternalId', IntDeptoExt(cEmpDestino, cFilialDestino, cDeptDestino)[2] )
		cXmlRet += GetClosedTag('CostCenterCode',cCCDestino)
		cXmlRet += GetClosedTag('CostCenterInternalId', IntCusExt(cEmpDestino, xFilial("CTT", cFilialDestino), cCCDestino , '2.000')[2] )
		cXmlRet += GetClosedTag('TransferDate',Transform(DTOS(SRE->RE_DATA), "@R 9999-99-99"))
		cXMLRet += GetClosedTag('ValueClass',SRE->RE_CLVLP)
		cXMLRet += GetClosedTag('AccountancyItem', SRE->RE_ITEMP)
		cXMLRet += GetClosedTag('OccupationPlaceCode',SRE->RE_POSTOP)
		cXMLRet += GetClosedTag('OccupationPlaceInternalId',"")
		cXmlRet += '      </EmployeeTransfered>'+cEol
		cXmlRet += '    </EmployeeBranchTranferring>'+cEol
		cXmlRet += '</BusinessContent>'
	EndIf

	RestArea(aArea)

	cXmlRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI180Snd
Rotina para integração por EAI

@since 14/05/2014
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI180Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := {}

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )

Return cTempKey

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataResp
	Trata a resposta da aplicação destino para gravação do De/Para

@since 14/05/2014
@version P11
@params 	lProcOk 	Status do processamento (referência)
@params 	cMsgRet 	Mensagem de retorno do processamento (referência)
@params 	cXml    	Mensagem da response para tratamento

/*/
//-------------------------------------------------------------------
Static Function TrataResp( lProcOk, cMsgRet, cXml )

Local aAreaSRA		:= SRA->(GetArea())
Local aChaveSRA		:= {}
Local oObjXml		:= Nil
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local nZ			:= 1
Local cMarca		:= ""
Local cAliasSRA		:= "SRA"
Local cCodExt		:= ""
Local cCodInt		:= ""

	oObjXml := XmlParser( cXml, "_", @cXmlErro, @cXmlWarn )
	If oObjXml <> Nil .And. Empty( cXmlErro ) .And. Empty( cXmlWarn )

		cMarca := oObjXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		If cMarca == "PIMS"

			If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_STATUS" ) <> Nil .And. ;
			Upper( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_Status:Text ) == "OK"

				oObjXml := XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ReturnContent, "_LISTOFINTERNALID" )

				If oObjXml <> Nil

					If XmlChildEx( oObjXml, "_INTERNALID" ) <> Nil

						If Valtype( oObjXml:_InternalId ) <> "A"
							XmlNode2Arr( oObjXml:_InternalId, "_InternalId" )
						EndIf

						For nZ := 1 To Len( oObjXml:_InternalId )

							If XmlChildEx( oObjXml:_InternalId[nZ], "_NAME" ) <> Nil .And. ;
								Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "SETEMPLOYEEBRANCHTRANSFER" .And. ;
								XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
								XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil

								cCodExt := oObjXml:_InternalId[nZ]:_Destination:Text
								cCodInt := oObjXml:_InternalId[nZ]:_Origin:Text

								If Empty(cCodExt)
									lProcOk := .F.
									cMsgRet := STR0014 //"InternalId: tag Destination não informada"
								Else
									If Empty(cCodInt)
										lProcOk := .F.
										cMsgRet := STR0015 //"InternalId: tag Origin não informada"
									Else

										If Empty( CFGA070Ext(cMarca, "SRA", "RA_MAT", cCodInt) )
											aChaveSRA := StrTokArr( cCodInt, "|" )
											If Len(aChaveSRA) == 3
												If aChaveSRA[1] != cEmpAnt
													fAbrEmpresa("SRA", 1, aChaveSRA[1], aChaveSRA[2])
													cAliasSRA := "GPESRA"
												EndIf
												(cAliasSRA)->(dbSetOrder(1))
												If (cAliasSRA)->( DbSeek( aChaveSRA[2] + Rtrim(aChaveSRA[3]) ))
													CFGA070Mnt( cMarca, 'SRA', 'RA_MAT', cCodExt, cCodInt )
												Else
													lProcOk := .F.
													cMsgRet := STR0016 //"Registro do funcionário não encontrado com a chave origin informada em InternalId"
												EndIf
												fFecEmpresa("SRA")
											EndIf
										EndIf

									EndIf
								EndIf

							EndIf

						Next nZ

					Else

						lProcOk := .F.
						cMsgRet := STR0007 // 'Não enviado conteúdo de retorno para cadastro de de-para'

					EndIf

				Else

					lProcOk := .F.
					cMsgRet := STR0008 // 'Não é possível gravar de-para por causa de erro na leitura do retorno'

				EndIf

			Else

				lProcOk 	:= .F.
				cMsgRet 	:= STR0009 + "|" // 'Erro no processamento pela outra aplicação'

				If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_LISTOFMESSAGES" ) <> Nil
					oObjXml := oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages

					If XmlChildEx( oObjXml, "_MESSAGE" ) <> Nil

						If Valtype( oObjXml:_Message ) <> "A"
							XmlNode2Arr( oObjXml:_Message, "_Message" )
						EndIf

						For nZ := 1 To Len( oObjXml:_Message )
							cMsgRet += Alltrim( oObjXml:_Message[nZ]:Text ) + "|"
						Next nZ
					Else

						lProcOk := .F.
						cMsgRet := STR0010 // 'Erro no processamento, mas sem detalhes do erro pela outra aplicação'

					EndIf
				EndIf
			EndIf
		EndIf

	Else
		lProcOk 	:= .F.
		cMsgRet 	:= STR0011 + "|" + cXmlErro + "|" + cXmlWarn // 'Falha na leitura da resposta, de-para não será gravado'
	EndIf

	oObjXml := Nil
	oObjResult := Nil
	RestArea(aAreaSRA)
	DelClassIntF()

Return

Static Function GetClosedTag(cTag,cValue)
	Local cResult := ''
	cResult := '<'+ cTag + '>'
	cResult += cValue
	cResult += '</'+ cTag + '>'
	cResult += cEol
Return(cResult)