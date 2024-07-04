#INCLUDE "PROTHEUS.CH"    
#INCLUDE "FWADAPTEREAI.CH"                                                
#INCLUDE "PONY040.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPONY040Aบ   Autor ณLutchen Henrique   บ Data ณ  04/12/2013  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecebe funcionario e data e retorna ponto do funcionario.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExp1 => Variavel com conteudo xml para envio/recebimento.   บฑฑ
ฑฑบ          ณExp2 => Tipo de transacao. (Envio/Recebimento)              บฑฑ
ฑฑบ          ณExp3 => Tipo de mensagem. (Business Type, WhoIs, etc)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PONY040(cXML, nTypeTrans, cTypeMessage,cVersao)

Local		aCodVerbas	:= {}
Local		aMessages	:= {}
Local		cPais		:= ""
Local		cConVerbs	:= ""
Local		cError		:= ""
Local		cWarning	:= ""
Local		aMatricula	:= {}
Local		cFuncao		:= ""
Local		cXmlRet		:= ""
Local		dDtIni		:= CToD("")
Local		dDtFim		:= CToD("")
Local		lReturn		:= .T.
Local 		aAux		:= {}  
Local 		cFili  		:= xFilial("SRA")
Local 		cEmp		:= ""
Local 		aAuxMat		:= {}
Local 		nEmp 		:= 0     
Local 		aPonto 		:= {}           
Local 		aRetPortal	:= {}      
Local 		dIniPonMes 	:= Ctod("//") //Data inicial do periodo em aberto
Local 		dFimPonMes 	:= Ctod("//") //Data final do periodo em aberto                                                                      
Local 		lImpAcum 	:= .F. 
Local 		cAlias 		:= ""  
Local 		cPrefix		:= ""    
Local		cValInt		:= ""
Local 		nXi			:= 0
Local 		nY			:= 0
Local 		nX			:= 0
Local 		nI			:= 0
Local 		lAchou		:= .T.
Local		cCodMat		:= ""     
Local		cMsgRet		:= ""
Local 		cMarca 		:= "" 

Default cVersao        := "1.000"

//Rafael Almeida - Os comandos abaixo sใo para garantir que as datas sejam no formato dd/mm/aaaa.
SET CENTURY ON
SET DATE BRITISH
                             
VarInfo("XML: ", cXML)

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		// Faz o parse do xml em um objeto
		oXml := XmlParser(cXml, "_", @cError, @cWarning)
		// Se nใo houve erros
		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
	 		cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID") == "U"
				lBuscaMat	:= .F.   
				cMsgRet := STR0001
				AAdd(aMessages, {cMsgRet, 1, "001"})
			Else
				If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID") == "A"
					For nXi := 1 To Len(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID)
						cValExt := OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID[NXI]:TEXT
						cValInt := CFGA070INT( cMarca, 'SRA', 'RA_MAT', cValExt )
						If !Empty(cValInt)
							AAdd( aAuxMat, {cValInt, 0 })
						EndIf
					Next
				Else
					cValExt := OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID:TEXT
					cValInt := CFGA070INT( cMarca, 'SRA', 'RA_MAT', cValExt )
					If !Empty(cValInt)
						AAdd( aAuxMat, {cValInt, 0 })
					EndIf
				EndIf
			EndIf
				
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_TIMESHEETSTARTDATE:TEXT") == "U" .Or.;
				Empty(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_TIMESHEETSTARTDATE:TEXT)
				lReturn	:= .F. 
				cMsgRet := STR0002
				AAdd(aMessages, {cMsgRet, 1, "002"})
			Else
				dDtIni	:= SToD(StrTran(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_TIMESHEETSTARTDATE:TEXT, "-"))
			EndIf
			
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_TIMESHEETFINISHDATE:TEXT") == "U" .Or.;
				Empty(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_TIMESHEETFINISHDATE:TEXT)
				lReturn	:= .F. 
				cMsgRet := STR0003
				AAdd(aMessages, {cMsgRet, 1, "003"})
			Else
				dDtFim	:= SToD(StrTran(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTTIMESHEET:_TIMESHEETFINISHDATE:TEXT, "-"))
			EndIf                                     
			        
		EndIf

		If !Empty(aMessages)
			cXMLRet := FWEAILOfMessages( aMessages )
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณObtem datas do periodo em abertoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			GetPonMesDat(@dIniPonMes, @dFimPonMes, cFili)
			                        	                           	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se busca acumuladoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lImpAcum := ( dDtFim < dIniPonMes)	
			cAlias := iif ( lImpAcum,"SPG","SP8")
			cPrefix := substr(cAlias,-2)	
				
			cXMLRet += "<ReturnTimeSheet>"
			cXMLRet += "<CompanyId>"+cEmpAnt+"</CompanyId>"
			cXMLRet += "<BranchId>"+xFilial("SRA")+"</BranchId>"
			cXMLRet += "<ListOfEmployeeTimeSheet>"

			For ni:= 1 To len(aAuxMat)   
				//Extaํdo o c๓digo da matrํcula da TAG EmployeeInternalID enviada pelo RM - Rafael Almeida. 08/05/2014
				cCodMat := AvKey(StrToKarr(aAuxMat[ni][1],"|")[3],"RA_MAT")
				
				SRA->(dbSetorder(1))
				SRA->(dbSeek(xFilial("SRA")+cCodMat))
				lAchou:= SRA->(!Eof())
		
				cValInt := GPEI030Snd( { cEmpAnt, xFilial("SRA"), cCodMat } )
		
				cXMLRet += "<EmployeeTimeSheet>"
				cXMLRet += "<CompanyId>"+cEmpAnt+"</CompanyId>"
				cXMLRet += "<BranchId>"+xFilial("SRA")+"</BranchId>"
				cXMLRet += "<EmployeeCode>"+cCodMat+"</EmployeeCode>"
				cXMLRet += "<EmployeeInternalId>"+cValInt+"</EmployeeInternalId>"
				cXMLRet += "<ListOfTimeSheet>"
	         	
				If lAchou     
					//Busca apontamentos
					ponr010(.T.,cFili,cCodMat,dtos(dDtIni)+dtos(dDtFim),.T.,@aRetPortal)
			        
					(cAlias)->(dbSetorder(2))
					If Len(aRetPortal) > 0 .AND. (cAlias)->(dbSeek(xFilial(cAlias)+cCodMat))
						For nx := 1 to len(aRetPortal)
							cXMLRet += "<TimeSheet>"
							cXMLRet += "<EventDate>"+DTOC(aRetPortal[nx][1])+"</EventDate>"
							If len(aRetPortal[nx]) > 3
								cXMLRet += "<ListOfInOutTime>"
								For nY := 4 to Len(aRetPortal[nx])						
									If (cAlias)->(dbSeek(xFilial(cAlias)+cCodMat+dtos(aRetPortal[nX][1])+StrTran(aRetPortal[nx][ny],":",".")))
										cXMLRet += "<InOutTime>"
										cXMLRet += "<RegisterTime>"+StrTran(aRetPortal[nx][ny],":",".")+"</RegisterTime>"
										cXMLRet += "<RegisterType>"+ConvMarca((cAlias)->(&(cPrefix+"_TPMARCA")))+"</RegisterType>"
										cXMLRet += "<Order>"+(cAlias)->(&(cPrefix+"_TURNO"))+"</Order>"
										cXMLRet += "</InOutTime>"                     
									EndIf
								Next ny
								cXMLRet += "</ListOfInOutTime>"
							EndIf
							cXMLRet += "</TimeSheet>"
						Next nx
					EndIf
				EndIf
		
				cXMLRet += "</ListOfTimeSheet>"
				cXMLRet += "</EmployeeTimeSheet>"
			Next ni

			cXMLRet += "</ListOfEmployeeTimeSheet>"
			cXMLRet += "</ReturnTimeSheet>"
		EndIf
		

	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVersao
	EndIf
EndIf  

Return{lReturn, EncodeUTF8(cXMLRet)}

/*/{Protheus.doc} ConvMarca
Converte a marca็ใo extraํda do Protheus para o padrใo do EAI.
	
@author rafaelalmeida
@since 16/05/2014
@version 1.0
		
@param cMarca, character, Marca็ใo realizada no Protheus.

@return cMarca, Marca็ใo Convertida.

/*/
Static Function ConvMarca(cMarca)

Default cMarca := ""

cMarca := AllTrim(Upper(cMarca))

Do Case
	Case At("E",cMarca) > 0
		cMarca := "IN"
	Case At("S",cMarca) > 0
		cMarca := "OUT"
EndCase

Return cMarca


