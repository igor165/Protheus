#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"    
#INCLUDE "GPEICAL2.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGPEICAL2บ Autor ณFernando Ferreira  บ Data ณ  15/04/2013    บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o custo do funcionario                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExp1 => Variavel com conteudo xml para envio/recebimento.   บฑฑ
ฑฑบ          ณExp2 => Tipo de transacao. (Envio/Recebimento)              บฑฑ
ฑฑบ          ณExp3 => Tipo de mensagem. (Business Type, WhoIs, etc)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEICAL2(cXML, nTypeTrans, cTypeMessage, cVersao)

Local		aAreaOld	:= {SRA->(GetArea()), GetArea()}
Local		aCodVerbas	:= {}
Local		aMessages	:= {}
Local		cPais		:= ""
Local		cConVerbs	:= ""
Local		cError		:= ""
Local		cWarning	:= ""
Local		aMatricula	:= {}
Local		cFuncao	:= ""
Local		cXmlRet	:= ""
Local		dDtIni		:= CToD("")
Local		dDtFim		:= CToD("")
Local		lBuscaMat	:= .T.
Local		lBuscaFun	:= .T.
Local		lReturn	:= .T.
Local		nXi			:= 0
Local		nCusto		:= 0
Local		nValHour	:= 0  
Local		cMsgRet		:= ""
Local		cMarca		:= ""
Local 		cValInt		:= "" 
Local 		cCodMat		:= ""
Local       aMat        := {}

Default cVersao        := "1.000"

VarInfo("XML: ", cXML)

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS
		// Faz o parse do xml em um objeto
		oXml := XmlParser(cXml, "_", @cError, @cWarning)
		// Se nใo houve erros
		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
			cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFEMPLOYEES:_EMPLOYEEINTERNALID") == "U"
				lBuscaMat	:= .F.      
				cMsgRet := STR0001
				AAdd(aMessages, {cMsgRet, 1, "000"})
			Else
				If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFEMPLOYEES:_EMPLOYEEINTERNALID") == "A"
					For nXi := 1 To Len(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFEMPLOYEES:_EMPLOYEEINTERNALID)
						cValExt := OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFEMPLOYEES:_EMPLOYEEINTERNALID[NXI]:TEXT
						cValInt := CFGA070INT( cMarca, 'SRA', 'RA_MAT', cValExt ) 
						If !Empty(cValInt)
							AAdd( aMatricula, {cValInt, "", 0, 0  })		
						EndIf				
					Next
				Else
					cValExt := OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFEMPLOYEES:_EMPLOYEEINTERNALID:TEXT
					cValInt := CFGA070INT( cMarca, 'SRA', 'RA_MAT', cValExt )
					If !Empty(cValInt)
						AAdd( aMatricula, {cValInt, "", 0, 0  })
					EndIf
				EndIf
			EndIf
			
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_COUNTRY:TEXT") == "U" .Or.;
				Empty(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_COUNTRY:TEXT)
				lReturn	:= .F.     
				cMsgRet := STR0002
				AAdd(aMessages, {cMsgRet, 1, "001"})
			Else
				cPais	:= OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_COUNTRY:TEXT
				If 	Upper(cPais) == "BRA" .Or. Upper(cPais) == "BRASIL" .Or. Upper(cPais) == "BRAZIL"
					cPais := "BRA"
				EndIf
			EndIf
			
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_STARTDATE:TEXT") == "U" .Or.;
				Empty(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_STARTDATE:TEXT)
				lReturn	:= .F.   
				cMsgRet := STR0003
				AAdd(aMessages, {cMsgRet, 1, "002"})
			Else
				dDtIni	:= SToD(StrTran(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_STARTDATE:TEXT, "-"))
			EndIf
			
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_ENDDATE:TEXT") == "U" .Or.;
				Empty(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_ENDDATE:TEXT)
				lReturn	:= .F. 
				cMsgRet := STR0004
				AAdd(aMessages, {cMsgRet, 1, "003"})
			Else
				dDtFim	:= SToD(StrTran(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_ENDDATE:TEXT, "-"))
			EndIf
			
			If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_ONLYFUNDS:TEXT") != "U"
				cConVerbs	:= OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_ONLYFUNDS:TEXT
			EndIf
			
			
			If !Empty(cConVerbs) .And. cConVerbs == "1" 
				If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFFUNDS:_CODEOFFUNDING") == "U"
					lReturn	:= .F.   
					cMsgRet := STR0005
					AAdd(aMessages, {cMsgRet, 1, "004"})                                     
				Else
					If Type("OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFFUNDS:_CODEOFFUNDING") == "A"
						For nXi := 1 To Len(OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFFUNDS:_CODEOFFUNDING)
							AAdd(aCodVerbas, OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFFUNDS:_CODEOFFUNDING[nXi]:TEXT)							
						Next
					Else
						AAdd( aCodVerbas, OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTEDCOST:_LISTOFFUNDS:_CODEOFFUNDING:TEXT)
					EndIf
				EndIf
			EndIf
			
			If !Empty(aMatricula)
				VarInfo("aMatricula: ", aMatricula)
				// RA_FILIAL+RA_MAT
				SRA->(dbSetOrder(01))
				For nXi := 1 To Len(aMatricula)
					//Extaํdo o c๓digo da matrํcula da TAG EmployeeInternalID enviada pelo RM - Rafael Almeida. 08/05/2014
					AAdd(aMat,aMatricula[nXi][1])
					cCodMat := AvKey(StrToKarr(aMatricula[nXi][1],"|")[3],"RA_MAT")
					aMatricula[nXi][1] := cCodMat
									
					If !SRA->(MsSeek(xFilial("SRA")+aMatricula[nXi][01]))
						lReturn	:= .F.    
						cMsgRet := STR0006
						AAdd(aMessages, {cMsgRet, 1, "005"})
					EndIf	
				Next
			EndIf
			
			If lReturn
				If !Empty(cConVerbs) .And. cConVerbs == "1" .And. cPais == "BRA" .And. !Empty(aCodVerbas)
					// Realizo o Cแlculo do custo do funcionแrio somente das verbas definidas no aCodVerbas
					For nXi := 1 To Len(aMatricula)
						aMatricula[nXi][02] := FCalBraVrb(aCodVerbas, aMatricula[nXi][01], dDtIni, dDtFim)
					Next
				ElseIf !Empty(cConVerbs) .And. cConVerbs = "2" .And. cPais == "BRA"
					// Realizo o Cแlculo do custo do funcionแrio abatendo o valor das verbas nใo definidas
					// no parโmetro aCodVerbas
					For nXi := 1 To Len(aMatricula)
						aMatricula[nXi][02] := FCalBra( aMatricula[nXi][01], dDtIni, dDtFim)
					Next
				Else
					// Realizo o cแlculo das verbas definidas no parโmetro aCodVerbas
					For nXi := 1 To Len(aMatricula)
						aMatricula[nXi][02] := FCalBra( aMatricula[nXi][01], dDtIni, dDtFim)
					Next
				EndIf
			EndIf
		EndIf
		
		//Avalia se tive erro
		If !Empty(aMessages)
			cXMLRet := FWEAILOfMessages( aMessages )
		Else
			//Monta mensagem de retorno
			cXMLRet += "<ReturnedCost>"
			cXMLRet += "	<ListOfCostEmployees>"
			For nXi := 1 To Len(aMatricula)
				cXMLRet += "		<CostEmployee>"
				cXMLRet += "			<EmployeeInternalId>"+aMat[nXi]+"</EmployeeInternalId>"
				cXMLRet += "			<CostOfEmployee>"+cValToChar(aMatricula[nXi][02])+"</CostOfEmployee>"
				cXMLRet += "		</CostEmployee>"
			Next
			cXMLRet += "	</ListOfCostEmployees>"
			cXMLRet += "</ReturnedCost>"
		EndIf
		
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVersao
	EndIf
	
EndIf

aEval(aAreaOld, {|x| RestArea(x)})

Return{lReturn, EncodeUTF8(cXMLRet)}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFGetMatFunบAutor ณFernando Ferreira  บ Data ณ  16/04/2013   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a mแtricula de um funcionแrio valido                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExp1 => C๓digo da fun็ใo a ser buscada   						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FGetMatFun(cFuncao)
Local		cMatricula		:= ""
Local		cAlias			:= GetNextAlias()
Default	FGetMatFun		:= ""

BeginSql Alias cAlias
	SELECT SRA.RA_MAT FROM %table:SRA% SRA
	WHERE SRA.%notdel%
	AND RA_SITFOLH = ' '
	AND RA_FILIAL = %xFilial:SRA%
	AND RA_CODFUNC = %Exp:cFuncao%
EndSql

// Busco o primeiro registro vแlido
If (cAlias)->(!Eof())
	cMatricula := (cAlias)->RA_MAT
EndIf

(cAlias)->(dbCloseArea())

Return cMatricula

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFGetValHorบAutor ณFernando Ferreira  บ Data ณ  24/04/2013   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o valor da hora do funcionแrio                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe    ณExp1 => Custo geral do funcionแrio     							   บฑฑ
ฑฑบ           ณExp1 => Matricula do funcionแrio      							   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FGetValHor(nCusto, cMatricula)
Local		cAlias			:= GetNextAlias()
Local		nValHour		:= 0

BeginSql Alias cAlias
	SELECT SRA.RA_HRSMES
	FROM %table:SRA% SRA
	WHERE SRA.%notdel%
	AND RA_SITFOLH = ' '
	AND RA_FILIAL = %xFilial:SRA%
	AND RA_MAT = %Exp:cMatricula%
EndSql

If (cAlias)->(!Eof())
	nValHour := nCusto / (cAlias)->RA_HRSMES
EndIf

(cAlias)->(dbCloseArea())

Return Round(nValHour, 2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFCalBraVrbบAutor ณFernando Ferreira  บ Data ณ  16/04/2013   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o custo do funcionแrio s๓ das verbas definidas para บฑฑ
ฑฑ           ณo paํs Brasil                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExp1 => C๓digo da verbas definidas pela mensagem            บฑฑ
ฑฑบ          ณExp2 => Mแtricula do funcionแrio a ser buscado o custo      บฑฑ
ฑฑบ          ณExp3 => Data inicial da pesquisa                            บฑฑ
ฑฑบ          ณExp4 => Data Final  da pesquisa                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FCalBraVrb(aCodVerbas,cMatricula, dDtIni, dDtFim)
Local		aVerbas	:= {}
Local		nXi			:= 0
Local		nCusto		:= 0

Default	aCodVerbas	:= {}
Default	cMatricula	:= ""
Default	dDtIni		:= CTod("")
Default	dDtFim		:= CTod("")

CalCustoFun(xFilial("SRD"), cMatricula,.F., .F., dDtIni, dDtFim,"", {}, {},;
{}, {}, {}, {}, @aVerbas, {}, {}, .F., {}, {}, "")
// Realizo a soma somente das verbas definidas na solicita็ใo
For nXi := 1 To Len(aCodVerbas)
	aEval(aVerbas, {|x| IIF(x[01] == aCodVerbas[nXi], nCusto += x[03], Nil) })
Next

Return nCusto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFCalBraบAutor ณFernando Ferreira  บ Data ณ  16/04/2013   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o custo do funcionแrio                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExp1 => C๓digo da verbas definidas pela mensagem            บฑฑ
ฑฑบ          ณExp2 => Mแtricula do funcionแrio a ser buscado o custo      บฑฑ
ฑฑบ          ณExp3 => Data inicial da pesquisa                            บฑฑ
ฑฑบ          ณExp4 => Data Final  da pesquisa                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FCalBra( cMatricula, dDtIni, dDtFim, cPais)
Local		nCusto		:= 0

Default	cMatricula	:= ""
Default	dDtIni		:= CTod("")
Default	dDtFim		:= CTod("")
Default 	cPais		:= ""

nCusto := CalCustoFun(xFilial("SRD"), cMatricula,.F., .F., dDtIni, dDtFim,"", {}, {},;
{}, {}, {}, {}, {}, {}, {}, .F., {}, {}, "")

Return nCusto
