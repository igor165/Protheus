#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'FWADAPTEREAI.CH' 


Static cVerSend := ''

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEI250    ³Autor  ³Alberto M.         v.I         ³ Data ³31/12/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mensagem Unica EmployeeHistorySalaryPosition                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA010 - Funcionario.                                               ³±±
±±³          ³ GPER200 - Reajuste Salarial.                                         ³±±
±±³          ³ GPEM690 - Dissidio Retroativo.                                       ³±±
±±³          ³ GPEA250 - Histório de Salário.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÏÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/

Function GPEI250(cXml, nType, cTypeMsg, cVersaoMsg )


Local nTypeTrans := nType
Local cXMLRet    := ''
Local cOrigem    := ''
Local lRet       := .T.
Local cEvent     := 'upsert'
Local cAliasXXF := ''

If nTypeTrans == TRANS_RECEIVE

	Do Case
			Case cTypeMsg == EAI_MESSAGE_WHOIS
				lRet := .T.
				cXMLRet := cVerSend
			Case cTypeMsg == EAI_MESSAGE_RECEIPT
			Case cTypeMsg == EAI_MESSAGE_BUSINESS
			Case cTypeMsg == EAI_MESSAGE_RESPONSE
	EndCase
			
ElseIf nTypeTrans == TRANS_SEND

	Do Case
		//Funcionarios.
		Case IsInCallStack('GPEA010')
			cOrigem   := 'GPEA010'
			cEvent    := 'upsert'
		//Reajuste Salarial.
		Case IsInCallStack('GPER200')
			cOrigem   := 'GPER200'
			cEvent    := 'upsert'
		//Dissidio Retroativo.
		Case IsInCallStack('GPEM690')
			cOrigem   := 'GPEM690'
			cEvent    := 'upsert'
		//Alteração Salarial.
		Case IsInCallStack('GPEA250')
			cOrigem   := 'GPEA250'
			If l250exc 
				cEvent    := 'delete'
			Else
				cEvent    := 'upsert'
			EndIf
	EndCase


	//Conteúdo do evento.
	cXMLRet += '<BusinessEvent>'
	cXMLRet +=    '<Entity>EmployeeHistorySalaryPosition</Entity>'
	cXMLRet +=    '<Event>' + cEvent+ '</Event>'
	cXMLRet += 	'<Identification>' 
	cXMLRet += 		'<key name="InternalID"></key>' 
	cXMLRet += 	'</Identification>'
	cXMLRet += '</BusinessEvent>'

	//Conteúdo do negócio.
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>' 
	cXMLRet += 	'<BranchId>' + BranchId(cOrigem) + '</BranchId>'
	cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + "|" + BranchId(cOrigem) + '</CompanyInternalId>'
	cXMLRet +=    '<ListOfEmployeeHistorySalaryPosition>'
	cXMLRet +=    	'<EmployeeHistorySalaryPosition>
	cXMLRet += 			'<EmployeeCode>' + EmployCod(cOrigem) + '</EmployeeCode>'
	cXMLRet += 			'<EmployeeInternalID>' + EmploIntID(cOrigem) + '</EmployeeInternalID>'
	cXMLRet += 			'<ChangedDate>' + ChngDate(cOrigem) +'</ChangedDate>'
	cXMLRet += 			'<Salary>' + Salary(cOrigem) +'</Salary>'
	cXMLRet += 			'<PaymentFrequency>'+ PaymentFreq(cOrigem) + '</PaymentFrequency>'
	cXMLRet += 			'<EmployeePositionCode>'+ EmploPosCod(cOrigem) + '</EmployeePositionCode>'
	cXMLRet +=           '<EmployeePositionInternalId>' +PositionId(cOrigem)+ '</EmployeePositionInternalId>'
	cXMLRet +=           '<EmployeePositionLevel>' + '</EmployeePositionLevel>'
	cXMLRet += 		'</EmployeeHistorySalaryPosition>
	cXMLRet += 	'</ListOfEmployeeHistorySalaryPosition>'
	cXMLRet += '</BusinessContent>' 

EndIf	


Return({lRet,cXMLRet})
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EmployCod   ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <EmployeeCode> da mensagem             ³±±
±±³          ³ EmployeeHistorySalaryPosition.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <EmployeeCode>.
Static Function EmployCod (cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := AllTrim(SRA->RA_MAT)
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := AllTrim(SR3->R3_MAT)
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := AllTrim(SRA->RA_MAT)
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		cTag := SR3->R3_MAT//aIntegdef[GdFieldPos( "R3_MAT"		, aHeaderR3All )]
EndCase
Return(cTag)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EmploIntID  ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <EmployeeInternalId> da mensagem       ³±±
±±³          ³ EmployeeHistorySalaryPosition.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <EmployeeInternalId>.
Static Function EmploIntID (cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := cEmpAnt + '|' + SRA->RA_FILIAL + '|' + SRA->RA_MAT
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := cEmpAnt + '|' + SRA->RA_FILIAL + '|' + SR3->R3_MAT
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := cEmpAnt + '|' + SRA->RA_FILIAL + '|' + SRA->RA_MAT
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		cTag := SR3->R3_FILIAL + '|' + SR3->R3_MAT //aIntegdef[GdFieldPos( "R3_FILIAL"		, aHeaderR3All )] + "|" + aIntegdef[GdFieldPos( "R3_MAT"		, aHeaderR3All )]
EndCase


Return(cTag)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ChngDate    ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <ChangedDate> da mensagem              ³±±
±±³          ³ EmployeeHistorySalaryPosition.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <ChangedDate>.
Static Function ChngDate (cOrigem)

Local cTag := ''
Local cAux := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cAux := AllTrim(DtoS(dDataAlt))  
		cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2) 
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cAux := AllTrim(DtoS(SR7->R7_DATA)) 
		cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2) 
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := Substr(RHH->RHH_DATA,1,4) + '-' + Substr(RHH->RHH_DATA,5,2) + '-' + '01' 
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		cTag := Transform( dtos(oGridSr3:getvalue("R3_DATA")), "@R 9999-99-99")//Transform( dtos(aIntegdef[GdFieldPos( "R3_DATA"		, aHeaderR3All )]), "@R 9999-99-99")
EndCase


Return(cTag)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Salary      ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <Salary> da mensagem                   ³±±
±±³          ³ EmployeeHistorySalaryPosition.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <Salary>.
Static Function Salary(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := AllTrim(Str(SRA->RA_SALARIO))
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := AllTrim(Str(SR3->R3_VALOR))
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := AllTrim(Str(RHH->RHH_CALC))
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		cTag := AllTrim(Str(oGridSr3:getValue("R3_VALOR")))
EndCase



Return(cTag)				
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PaymentFreq ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <PaymentFrequency> da mensagem         ³±±
±±³          ³ EmployeeHistorySalaryPosition.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <PaymentFrequency>.
Static Function PaymentFreq(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		Do Case
			Case SRA->RA_TIPOPGT == 'M'
				cTag := '1'
			Case SRA->RA_TIPOPGT == 'S'
				cTag := '6'
		EndCase
		
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
				Do Case
			Case SR7->R7_TIPOPGT == 'M'
				cTag := '1'
			Case SR7->R7_TIPOPGT == 'S'
				cTag := '6'
		EndCase
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		
		Do Case
			Case SRA->RA_TIPOPGT == 'M'
				cTag := '1'
			Case SRA->RA_TIPOPGT == 'S'
				cTag := '6'
		EndCase
		
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		Do Case
			Case SRA->RA_TIPOPGT == 'M'
				cTag := '1'
			Case SRA->RA_TIPOPGT == 'S'
				cTag := '6'
		EndCase
EndCase


Return(cTag)	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EmploPosCod ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <EmployeePositionCode> da mensagem     ³±±
±±³          ³ EmployeeHistorySalaryPosition.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <EmployeePositionCode>.
Static Function EmploPosCod(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := AllTrim(SRA->RA_CARGO)
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := AllTrim(SR7->R7_CARGO)
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := AllTrim(SRA->RA_CARGO)
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		cTag := AllTrim(SRA->RA_CARGO)
EndCase


Return(cTag)		

Static Function PositionId(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SRA->RA_CARGO) } )
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SR7->R7_CARGO) } )
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SRA->RA_CARGO) } )
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SRA->RA_CARGO) } )
EndCase
Return(cTag)	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BranchId ³ Autor ³ Alberto M.              ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <BranchId> da mensagem                 ³±±
±±³          ³ EmployeeHistorySalaryPosition.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <BranchId>.
Static Function BranchId(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := SRA->RA_FILIAL
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := SR3->R3_FILIAL
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := SRA->RA_FILIAL
	//Alteração Salarial.
	Case cOrigem == 'GPEA250'
		cTag := SRA->RA_FILIAL
EndCase


Return(cTag)		