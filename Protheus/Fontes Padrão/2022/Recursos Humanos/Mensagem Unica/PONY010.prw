#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PONY010.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PONY010Aº   Autor ³Lutchen Henrique   º Data ³  13/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recebe funcionario e retorna total de horas do func no mês. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Exp1 => Variavel com conteudo xml para envio/recebimento.   º±±
±±º          ³Exp2 => Tipo de transacao. (Envio/Recebimento)              º±±
±±º          ³Exp3 => Tipo de mensagem. (Business Type, WhoIs, etc)       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PONY010(cXML, nTypeTrans, cTypeMessage, cVersao)

Local	aMessages	:= {}
Local	cError		:= ""
Local	cWarning	:= ""
Local	cXmlRet		:= ""
Local	dDtIni		:= CToD("")
Local	dDtFim		:= CToD("")
Local	lReturn		:= .T.
Local 	aAuxMat		:={}
Local 	nHrTrb 		:= 0
Local	nHrNTrb 	:= 0   
Local 	nXi			:= 0
Local 	ni			:= 0     
Local	cMsgRet		:= ""
Local 	cMarca 		:= "" 
Local	cValInt		:= ""
Local   dBkpData	:= dDataBase

Default cVersao        := "1.000"

VarInfo("XML: ", cXML)

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		// Faz o parse do xml em um objeto
		oXml := XmlParser(cXml, "_", @cError, @cWarning)
		// Se não houve erros
		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)     
			cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID") == "U"
				lBuscaMat	:= .F.   
				cMsgRet := STR0001
				AAdd(aMessages, {cMsgRet, 1, "000"})
			Else
				If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID") == "A"
					For nXi := 1 To Len(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID)
						cValExt := OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID[NXI]:TEXT
						cValInt := CFGA070INT( cMarca, 'SRA', 'RA_MAT', cValExt ) 
						If !Empty(cValInt)
							AAdd( aAuxMat, {cValInt, "", 0, 0  })
						EndIf
					Next
				Else                                                                                                                                                               
					cValExt := OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_LISTOFEMPLOYEE:_EMPLOYEEINTERNALID:TEXT
					cValInt := CFGA070INT( cMarca, 'SRA', 'RA_MAT', cValExt )
					If !Empty(cValInt)
						AAdd( aAuxMat, {cValInt, "", 0, 0  })
					EndIf
				EndIf
			EndIf
				
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_STARTDATE:TEXT") == "U" .Or.;
				Empty(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_STARTDATE:TEXT)
				lReturn	:= .F. 
				cMsgRet := STR0002
				AAdd(aMessages, {cMsgRet, 1, "002"})
			Else
				dDtIni	:= SToD(StrTran(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_STARTDATE:TEXT, "-"))
			EndIf
			
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_FINISHDATE:TEXT") == "U" .Or.;
				Empty(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_FINISHDATE:TEXT)
				lReturn	:= .F.    
				cMsgRet := STR0003
				AAdd(aMessages, {cMsgRet, 1, "003"})
			Else
				dDtFim	:= SToD(StrTran(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTWORKEDHOURS:_FINISHDATE:TEXT, "-"))
			EndIf                                     
			
			If lReturn
				
				dDataBase := dDtFim
				
				For nXi := 1 To Len(aAuxMat)
					nHrTrb	:= 0
					nHrNTrb:= 0 
					
					//Extaído o código da matrícula da TAG EmployeeInternalID enviada pelo RM - Rafael Almeida. 08/05/2014
					cCodMat := AvKey(StrToKarr(aAuxMat[nXi][1],"|")[3],"RA_MAT")
					aAuxMat[nXi][1] := cCodMat
					
					cValInt := GPEI030Snd( { cEmpAnt, xFilial("SRA"), cCodMat } )
					aAuxMat[nXi][2]:= cValInt
					
					If SRA->(MsSeek(xFilial("SRA")+aAuxMat[nXi][01]))
						//Funcao para buscar o total de hora do funcionario
						CALTOTHR(aAuxMat[nXi][1], dDtIni, dDtFim, xFilial("SRA"), @nHrTrb, @nHrNTrb)
					EndIf
					
					aAuxMat[nXi][3]:= nHrTrb
					aAuxMat[nXi][4]:= nHrNTrb       
				Next
			EndIf
			
		EndIf
		
		If !Empty(aMessages)
			cXMLRet := FWEAILOfMessages( aMessages )
		Else
			cXmlRet += "<ReturnWorkedHours>"
			cXmlRet += "<CompanyId>"+cEmpAnt+"</CompanyId>" //Codigo da coligada/empresa/companhia
			cXmlRet += "<BranchId>"+xFilial("SRA")+"</BranchId>" //Id da filial
			cXmlRet += "<ListOfEmployeeWorkedHours>"
			
			For ni:= 1 to len(aAuxMat)
				cXmlRet += "<EmployeeWorkedHours>"
				cXmlRet += "<CompanyId>"+cEmpAnt+"</CompanyId>" //Id da coligada/empresa/companhia do funcionário
				cXmlRet += "<BranchId>"+xFilial("SRA")+"</BranchId>" //Id da filial do funcionário
				cXmlRet += "<EmployeeCode>"+aAuxMat[ni][1]+"</EmployeeCode>" //Chapa/Matricula do funcionario
				cXmlRet += "<EmployeeInternalId>"+aAuxMat[ni][2]+"</EmployeeInternalId>" //InternalId do funcionário
				cXmlRet += "<WorkedHours>"+Alltrim(str(aAuxMat[ni][3]))+"</WorkedHours>" //Total de horas trabalhadas do funcionário.
				cXmlRet += "<AbsenceHours>"+Alltrim(str(aAuxMat[ni][4]))+"</AbsenceHours>" //Total de horas de faltas do funcionário.
				cXmlRet += "</EmployeeWorkedHours>"
			Next ni
			
			cXmlRet += "</ListOfEmployeeWorkedHours>"
			cXmlRet += "</ReturnWorkedHours>"
		EndIf
		
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVersao
	EndIf
EndIf  

dDataBase := dBkpData

Return{lReturn, EncodeUTF8(cXMLRet)}
