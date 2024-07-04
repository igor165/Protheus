#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'
/*/{Protheus.doc} GTPI115
GTPI115 - Adapter da rotina de Horarios e Serviços
@author jacomo.fernandes
@since 16/08/2017
@version 12.1.7
@param cXml, characters, O XML recebido pelo EAI Protheus
@param nTypeTrans, numeric, Tipo de transacao
		0	- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
		1	- para mensagem sendo enviada (DEFINE TRANS_SEND) 
@param cTypeMessage, characters, Tipo da mensagem do EAI
		20	- Business Message (DEFINE EAI_MESSAGE_BUSINESS)
		21	- Response Message (DEFINE EAI_MESSAGE_RESPONSE)
		22	- Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
		23	- WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@Return aRet, array, Retorna um array contendo as informações do adaper
		aRet[1]	- lRet		- Indica se ocorreu com sucesso
		aRet[2]	- cXMLRet	- String contendo o Xml que serÃ¡ Enviado
		aRet[3]	- cMsgUnica	- Nome do Adapter
@type function
/*/
Function GTPI115(cXml, nTypeTrans, cTypeMessage,cVersao )
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'TravelTicket'
Local aArea		:= GetArea()

If nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem Ãºnica TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI115Resp(cXml,@lRet)
		
		//chegada de mensagem de negÃ³cios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI115Receb(cXml,@lRet)
	EndCase
EndIF

RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Resp

@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI115Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"TravelTicket","GIC","GIC_CODIGO"})

If oXml:Parse(cXml)
	GxResponse(oXml,aMsgUnic)
Else
	lRet	:= .F.
	cXmlRet := STR0009//"Falha no Parse"
Endif

GTPDestroy(aMsgUnic)
GTPDestroy(oXml)
Return cXMLRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Receb

@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI115Receb(cXml,lRet)
Local oModel		:= FwLoadModel("GTPA115")
Local oMdlGIC		:= Nil
Local oMdlGZP		:= Nil
Local oStruGIC		:= oModel:GetModel('GICMASTER'):GetStruct()
Local oXml			:= tXMLManager():New()
Local cXmlRet		:= ""
Local cBusiMsg		:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont		:= cBusiMsg+'/BusinessContent'
Local lDelete		:= .F.
Local cMarca		:= "PROTHEUS"
Local cCode			:= ""
Local cIntID		:= ""
Local cExtID		:= ""
Local nOpc			:= 0
Local lOk			:= .T.
Local cErro			:= ""
Local aInt			:= {}
Local aCpoGIC		:= {"GIC_FILIAL","GIC_CODIGO"}//BILHETES
Local aCpoGI2		:= {"GI2_FILIAL","GI2_COD"}//Linhas
Local aCpoGI1		:= {"GI1_FILIAL","GI1_COD"}//localidades
Local aCpoGID		:= {"GID_FILIAL","GID_COD"}//Horarios
Local aCpoGYN		:= {"GYN_FILIAL","GYN_CODIGO"}//Viagens
Local aCpoGI6		:= {"GI6_FILIAL","GI6_CODIGO"}//AGENCIA
Local aCpoGYG		:= {"GYG_FILIAL","GYG_CODIGO"}//COLAB
//Local aCpoGZ2		:= {"GZ2_FILIAL","GZ2_CODIGO"}//ECF
Local aCpoG9B		:= {"G9B_FILIAL","G9B_CODIGO"}//COLAB
Local aDados		:= {}
Local lMsblql		:= AllTrim(GetSx3Cache("GIC_MSBLQL", "X3_CAMPO")) == "GIC_MSBLQL"
Local n1			:= 0
Local cHrViagem     := ""
Local cHrVenda      := ""
Local nCont			:= 0
Local n2			:= 0
Local nItem			:= 0
Local cLine			:= ''
Local cItem			:= ''
Local cLstOFItem	:= cBusiCont+'/ListOfPaymentForm/PaymentForm'
Local aDadosSeq		:= {}
Local aDadosGZV		:= {}
Local cCardName		:= ""
Local cTpPagto		:= ""
Local cNsu			:= ""
Local cAut			:= ""
Local lErroInt		:= .F.

Static cBilRef		:= ""
Static cCodeLin		:= ""
Static cCodeHr		:= ""
Static cCodeViag	:= ""
Static cOriLocCod	:= ""
Static cDesLocCod	:= ""
Static cAgencia     := ""
Static cColab       := ""
Static cEcf			:= ""
Static cCodCat		:= ""

If Type("Inclui") == "U"
	Private Inclui := .F.
Endif

oStruGIC:SetProperty("GIC_ORIGEM" 	, MODEL_FIELD_INIT, {|| "2" })
oStruGIC:SetProperty("GIC_CODIGO" 	, MODEL_FIELD_INIT, {|| GTPXENUM('GIC','GIC_CODIGO',1) })

oStruGIC:SetProperty("GIC_CODSRV" 	, MODEL_FIELD_OBRIGAT, .F.)
oStruGIC:SetProperty('GIC_BILREF'	, MODEL_FIELD_NOUPD ,.F.)
oStruGIC:SetProperty('GIC_LINHA'	, MODEL_FIELD_NOUPD ,.F.)
oStruGIC:SetProperty('GIC_CODGID'	, MODEL_FIELD_NOUPD ,.F.)
oStruGIC:SetProperty('GIC_LOCORI'	, MODEL_FIELD_NOUPD ,.F.)
oStruGIC:SetProperty('GIC_LOCDES'	, MODEL_FIELD_NOUPD ,.F.)

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	
	cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
    cCode		:= GTPxRetId(cMarca, "GIC", "GIC_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCpoGIC,1)
	
	If lRet
		GIC->(DbSetOrder(1))//GIC_FILIAL+GIC_CODIGO
		If !lDelete
			If Empty(cIntID)
				nOpc := MODEL_OPERATION_INSERT
				Inclui := .T.
			ElseIf lOk .and. GIC->(DbSeek(xFilial('GIC')+cCode))
				nOpc := MODEL_OPERATION_UPDATE
			Else 
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
			Endif
		ElseIf lOk .and. GIC->(DbSeek(xFilial('GIC')+cCode))
			nOpc := MODEL_OPERATION_DELETE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,STR0007)
		Endif
	Endif

	
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ReferenceTicketInternalId'))	,"cBilRef"		,"GIC","GIC_CODIGO"		,3,			, ,'GZV_EXTGIC'})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/LineInternalId'))	            ,"cCodeLin"		,"GI2","GI2_COD"		,3,aCpoGI2	,1,'GZV_EXTGI2'})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ServiceScheduleInternalId'))	,"cCodeHr"		,"GID","GID_COD"		,3,aCpoGID	,1,'GZV_EXTGID'})
    aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TravelServiceInternalId'))  	,"cCodeViag"	,"GYN","GYN_CODIGO"		,3,aCpoGYN	,1,'GZV_EXTGYN'})
    aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DepartureLocalityInternalId'))	,"cOriLocCod"	,"GI1","GI1_COD"		,3,aCpoGI1	,1,'GZV_GI1ORI'})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ArrivalLocalityInternalId'))	,"cDesLocCod"	,"GI1","GI1_COD"		,3,aCpoGI1	,1,'GZV_GI1DES'})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/AgencyInternalId'))	        ,"cAgencia"		,"GI6","GI6_CODIGO"		,3,aCpoGI6	,1,'GZV_EXTGI6'})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CollaboratorInternalId'))   	,"cColab"		,"GYG","GYG_CODIGO"		,3,aCpoGYG	,1,'GZV_EXTGYG'})
	//aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ECFInternalId'))  			 	,"cEcf"			,"GZ2","GZ2_CODIGO"		,3,aCpoGZ2	,1})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TicketCategoryInternalId'))   	,"cCodCat"		,"G9B","G9B_CODIGO"		,3,aCpoG9B	,1,'X'})
	
	For n1 := 1 To Len(aInt)
		If !Empty(aInt[n1,1])
			&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1], aInt[n1,2], aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
			aAdd(aDadosGZV,{aInt[n1,8],aInt[n1,1]})
			If !lOk .And. aInt[n1,2] $ 'cBilRef/cCodeViag'
			
				&(aInt[n1,2]):= ''
				
				lOk 		:= .T.
				lErroInt	:= .T.
				
			Endif 
							
			If !lOk
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
				Exit
			Endif
		Endif
	Next

	cHrViagem   := GTFormatHour(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TravelTime')),'9999')
    cHrVenda    := GTFormatHour(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TimeOfSale')),'9999')
    
	If lRet
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			oMdlGIC := oModel:GetModel('GICMASTER')
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGIC:GetValue("GIC_CODIGO"))
					aAdd(aDados,{"GIC_CODIGO"	,		,cBusiCont + '/Code'})
				Endif
                aAdd(aDados,{"GIC_TIPO" 	,			,cBusiCont + '/Type'                        })
                aAdd(aDados,{"GIC_BILHET"	,			,cBusiCont + '/TicketNumber'				})
                aAdd(aDados,{"GIC_LINHA"	,cCodeLin	,cBusiCont + '/LineInternalId'			    }) 
                aAdd(aDados,{"GIC_SENTID"	,			,cBusiCont + '/Direction'				    }) 
                aAdd(aDados,{"GIC_CODGID"	,cCodeHr	,cBusiCont + '/ServiceScheduleInternalId'   })		
                aAdd(aDados,{"GIC_CODSRV"	,cCodeViag	,cBusiCont + '/TravelServiceInternalId'     })		
                aAdd(aDados,{"GIC_LOCORI"	,cOriLocCod ,cBusiCont + '/DepartureLocalityInternalId' })	
                aAdd(aDados,{"GIC_LOCDES"	,cDesLocCod ,cBusiCont + '/ArrivalLocalityInternalId'   })	
                aAdd(aDados,{"GIC_BILREF"	,cBilRef	,cBusiCont + '/ReferenceTicketInternalId'   })	
                aAdd(aDados,{"GIC_DTVIAG"	,			,cBusiCont + '/TravelDate'                  })
                aAdd(aDados,{"GIC_HORA" 	,cHrViagem	,cBusiCont + '/TravelTime'                  })
                aAdd(aDados,{"GIC_TAR"  	,			,cBusiCont + '/Fare'                        })
                aAdd(aDados,{"GIC_TAX"  	,			,cBusiCont + '/BoardRate'                   })
                aAdd(aDados,{"GIC_PED"	    ,			,cBusiCont + '/TollFee'                     })
                aAdd(aDados,{"GIC_SGFACU"	,			,cBusiCont + '/OptionalInsuranceValue'      })
                aAdd(aDados,{"GIC_OUTTOT"	,			,cBusiCont + '/OtherAmount'                 })
                aAdd(aDados,{"GIC_VALTOT"	,			,cBusiCont + '/TotalValue'                  })
                aAdd(aDados,{"GIC_AGENCI"	,cAgencia   ,cBusiCont + '/AgencyInternalId'	    	})
                aAdd(aDados,{"GIC_COLAB"    ,cColab		,cBusiCont + '/CollaboratorInternalId'      })
                aAdd(aDados,{"GIC_DTVEND"	,			,cBusiCont + '/DateOfSale'		            })
                aAdd(aDados,{"GIC_HRVEND"	,cHrVenda	,cBusiCont + '/TimeOfSale'		            })
                aAdd(aDados,{"GIC_STATUS"	,			,cBusiCont + '/Status'                      })
				aAdd(aDados,{"GIC_MOTCAN"	,			,cBusiCont + '/CancellationReason'			})

				If GIC->(FieldPos('GIC_TIPCAN')) > 0
					aAdd(aDados,{"GIC_TIPCAN"	,			,cBusiCont + '/cancellationTypeId'		})
				Endif

				aAdd(aDados,{"GIC_ECF"		,/*cEcf*/	,cBusiCont + '/ECFInternalId'				})
				aAdd(aDados,{"GIC_ECFSER"	,			,cBusiCont + '/ECFSerie'					})
				aAdd(aDados,{"GIC_ECFSEQ"	,			,cBusiCont + '/ECFSequence'					})
				aAdd(aDados,{"GIC_CCF"	,				,cBusiCont + '/CCFSequence'					})
				
				aAdd(aDados,{"GIC_CODG9B"	,cCodCat	,cBusiCont + '/TicketCategoryInternalId'	})
				aAdd(aDados,{"GIC_CHVBPE"	,			,cBusiCont + '/chBpe'						})
				aAdd(aDados,{"GIC_NUMPRO"	,			,cBusiCont + '/protocolo'					})
				aAdd(aDados,{"GIC_CHVSUB"	,			,cBusiCont + '/chBpeSubstituicao'			})

				If lMsblql
					aAdd(aDados,{"GIC_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGIC,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
				
				If lRet .And. (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfPaymentForm') ) > 0 .AND. AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Status'))$('V|T')
					
					oMdlGZP := oModel:GetModel('GZPPAGTO')
					For n2 := 1 to nCont
						cLine		:= cLstOFItem+"["+cValToChar(n2)+"]"
						If AllTrim(oXml:XPathGetNodeValue(cLine + '/TypeOfPaymentForm'))$('CR|DE|CD')
							nItem ++					
							
							cTpPagto	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/TypeOfPaymentForm'))
							cCardName	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/CardName'))
							cNsu		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/NSU'))
							cAut		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/Autorization'))
							
							If !oMdlGZP:SeekLine({{'GZP_TPAGTO',cTpPagto},{'GZP_NSU',cNsu},{'GZP_AUT',cAut}}) 
								If !Empty(oMdlGZP:GetValue("GZP_ITEM"))  
									oMdlGZP:AddLine()
								Endif
								If oMdlGZP:Length() > 1
									cItem := Strzero(Val( oMdlGZP:GetValue("GZP_ITEM",oMdlGZP:Length() -1 ))+1 ,TamSx3("GZP_ITEM")[1]  )
								Else
									cItem := StrZero(1,TamSx3("GZP_ITEM")[1])
								Endif
							Else
								cItem := oMdlGZP:GetValue('GZP_ITEM')
							Endif
							
							aSize(aDadosSeq,0)
							
							aAdd(aDadosSeq,{'GZP_DCART'	,		,cLine + '/CardName'			,})
							aAdd(aDadosSeq,{'GZP_ITEM'	,cItem	,cLine + '/Sequence'			,.T.})
							aAdd(aDadosSeq,{'GZP_TPAGTO',       ,cLine + '/TypeOfPaymentForm'	,})
							aAdd(aDadosSeq,{'GZP_VALOR'	,		,cLine + '/Value'				,})
							aAdd(aDadosSeq,{'GZP_QNTPAR',		,cLine + '/Installments'		,})
							aAdd(aDadosSeq,{'GZP_NSU'	,		,cLine + '/NSU'					,})
							aAdd(aDadosSeq,{'GZP_AUT'	,		,cLine + '/Autorization'		,})
							aAdd(aDadosSeq,{'GZP_ESTAB'	,		,cLine + '/Establishment'		,})

							If AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Status'))$('T')
								aAdd(aDadosSeq,{"GZP_BILREF"	,cBilRef	,cBusiCont + '/ReferenceTicketInternalId',   })
							Endif
							
							For n1 := 1 to Len(aDadosSeq)
								If !GxGetNdXml(oMdlGZP,oXml,aDadosSeq[n1][1],aDadosSeq[n1][2],aDadosSeq[n1][3],aDadosSeq[n1][4])
									lRet := .F.
									Exit
								Endif
							Next
							If !lRet .or. !oMdlGZP:VldLineData()
								lRet := .F.
								Exit
							Endif
						Endif
					Next		
				
				Endif
			Endif
			

			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGIC:GetValue('GIC_CODIGO'), 'GIC')
				Endif
				cXmlRet := GxListOfId({{"TravelTicket",cExtID,cIntId,cMarca,"GIC","GIC_CODIGO"}},lDelete)
				
				//Criação de/para dos registros informados
				GTPXUpdGZV("GIC",cMarca,cExtId,1,xFilial('GIC')+oMdlGIC:GetValue('GIC_CODIGO'),aDadosGZV,lDelete,"GTPA115",lErroInt)
				
				
			Else
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
			Endif
			oModel:DeActivate()
		Endif
	Endif
Else
	lRet	:= .F.
	cXmlRet := STR0009//"Falha no Parse"
Endif

oModel:Destroy()

GTPDestroy(oModel)
GTPDestroy(oMdlGIC)
GTPDestroy(oXml)
GTPDestroy(aInt)		
GTPDestroy(aCpoGI2)		
GTPDestroy(aCpoGI1)		
GTPDestroy(aCpoGID)		
GTPDestroy(aCpoGYN)		
GTPDestroy(aCpoGI6)		
GTPDestroy(aCpoGYG)		
//GTPDestroy(aCpoGZ2)
GTPDestroy(aCpoG9B)
GTPDestroy(aDados)		
GTPDestroy(aDadosGZV)

Return cXmlRet
