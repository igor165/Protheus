#Include 'UBAW110.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)


/*/{Protheus.doc} UBAI110
//Retorna Status da Medicao do Contrato - ContractMeasurementStatus-ResultCottonProcessing
@author carlos.augusto
@since 21/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function UBAI110( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()		//Salva contexto do alias atual  
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo
	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função
	Local cXMLRet	  := ''				//Xml que será enviado pela função
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como parâmetro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como parâmetro
	Local cEvent	  := 'request'		
	Local cSafra		:= ""
	Local cIntIdSaf		:= ""
	Local aMedCtr		:= {}
	Local cMovDate		:= ""
	Local cMovHour		:= ""
	Local lSeek			:= .F.
	Local cEntity	  := 'ResultCottonProcessing'

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'NJU'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "NJU_CODSAF"	//É o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//Código externo para gravacao - Código InternalId do PIMS
	Local cValInt	  := ''				//Código interno para gravação
	Local oXML 		  := Nil				//Objeto com o conteúdo do arquivo Xml
	Local oXMLEvent	  := Nil				//Objeto com o conteúdo da BusinessEvent apenas
	Local oXMLContent := Nil				//Objeto com o conteúdo da BusinessContent apenas



	//*************************************
	// Trata o recebimento de mensagem                              
	//*************************************
	If ( nTypeTrans == TRANS_RECEIVE )

		//*********************************
		// Recebimento da Business Message
		//*********************************
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
			oXML := tXmlManager():New()
			oXML := XmlParser( cXML, '_', @cError, @cWarning )	

			If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )

				//-- Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") = "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cReferen := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0003 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "ResultCottonProcessing" } 
					Return aRet
				EndIf

				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

				//Guarda o código da tabela recebido na mensagem.
				//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5
				If ( XmlChildEx( oXMLContent, '_AGRICULTURALYEARCODE' ) != Nil )
					cSafra		:= PADR(oXMLContent:_AgriculturalYearCode:Text,TamSx3("NJU_CODSAF")[1] ," ")
				EndIf

				If ( XmlChildEx( oXMLContent, '_AGRICULTURALYEARINTERNALID' ) != Nil )
					cIntIdSaf	:= PADR(oXMLContent:_AgriculturalYearInternalId:Text,TamSx3("NJU_ID")[1] ," ")
				EndIf

				If ( XmlChildEx( oXMLContent, '_MOVIMENTDATE' ) != Nil )
					cMovDate	:= oXMLContent:_MovimentDate:Text
				EndIf				

				If lRet
					
					cMovDate := StrTran(cMovDate, '-', '')
					cMovHour :=  SUBSTR(cMovDate, 10, 5)
					If .Not. Empty(cMovHour)
						cMovDate :=  SUBSTR(cMovDate, 1, 8)
						
						aMedCtr := MedCtrXml(cSafra, cMovDate, cMovHour)
						lRet	:= aMedCtr[1]
						cXmlRet	:= aMedCtr[2]
	
						If !lRet
							cXMLRet := EncodeUTF8( cXmlRet )
							DisarmTransaction()
						Else 
							//--------------------------------------------
							//--- TRATAMENTO DE RETORNO PARA O DE/PARA QUANDO SE ALTERA A SAFRA
							//--------------------------------------------
							cValExt := cIntIdSaf
							dbSelectArea('NJU')
							NJU->( dbSetOrder(2) )	//Filial + Safra | NJU_FILIAL + NJU_ID
							lSeek := NJU->( DbSeek( fwxFilial('NJU') + cIntIdSaf  ) )							
							If lSeek
								cValInt := NJU->NJU_CODSAF 
								cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + cValInt
								CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .F.,,, cEntity)
							EndIf
	
						EndIf
					Else
					lRet    := .F.
					cXMLRet := STR0006 //"Favor informar o horário na tag MovimentDate."
					cXMLRet := EncodeUTF8(cXMLRet)
					EndIf				
				Else
					//Tratamento no erro do parse Xml
					lRet    := .F.
					cXMLRet := STR0001 //'Erro na criação do produto. '
					cXMLRet += IIf ( !Empty(cError), cError, cWarning )

					cXMLRet := EncodeUTF8(cXMLRet)

				EndIf

			Else
				//Tratamento no erro do parse Xml
				lRet    := .F.
				cXMLRet := STR0002 //'Erro na manipulação do Xml recebido. '
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )

				cXMLRet := EncodeUTF8(cXMLRet)
			EndIf

		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			//--------------------------------------------
			//--- RECEBIMENTO DA WHOIS   
			//--------------------------------------------			
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXMLRet := "1.000|1.001|1.002"
		EndIf

	ElseIf ( nTypeTrans == TRANS_SEND )

		/**
		Deixar esta parte comentada para eventuais testes sem o ambiente PIMS (Protheus x Protheus)
		aInput	:= Tela('Safra',)
		cSafra	:= aInput[1]
		cData	:= aInput[2]
		**/

		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>'+ cEntity +'</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
			cXMLRet += '<CompanyId>18</CompanyId>'
			cXMLRet += '<CompanyInternalId>18</CompanyInternalId>'
			cXMLRet += '<BranchId>D MG 01</BranchId>'
			cXMLRet += '<AgriculturalYearCode>959596</AgriculturalYearCode>'
			cXMLRet += '<AgriculturalYearInternalId>||3274674140792770732</AgriculturalYearInternalId>'
			cXMLRet += '<ProductionPeriodCode>959597</ProductionPeriodCode>'
			cXMLRet += '<ProductionPeriodInternalId>||959597</ProductionPeriodInternalId>'
			cXMLRet += '<MovimentDate>2018-07-10T23:59:59</MovimentDate>'
			cXMLRet += '<ClassValueCode>01</ClassValueCode>'
			cXMLRet += '<ClassValueInternalId>||3337021085813890507</ClassValueInternalId>'
			cXMLRet += '<AccountingItemCode/>'
			cXMLRet += '<AccountingItemInternalId>||</AccountingItemInternalId>'
		cXMLRet += '</BusinessContent>'	
	EndIf

	//-------------------------------------
	//-- Carrega array de retorno - PARA INTEGRAÇÃO
	aRet := {lRet, cXmlRet, "ResultCottonProcessing"}
	//-------------------------------------

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aArea)

Return aRet


/*/{Protheus.doc} MedCtrXml
@author carlos.augusto
@since 30/06/2018
@version undefined
@param cSafra, characters, descricao
@param cMovDate, characters, descricao
@type function
/*/
Static Function MedCtrXml(cSafra, cMovDate, cMovHour)
	Local cXmlRet 		:= ""
	Local cAliasQry 	:= GetNextAlias()
	Local cQuery		:= ""
	Local lRet			:= .T.
	Local nPsFardao		:= 0
	Local nPsFardos		:= 0
	Local nRealizado	:= 0
	Local nPsTotRealiz	:= 0
	Local nPercVarProj	:= 0
	Local dMinDtBen := ""
	Local dMaxDtBen := ""
	Local nSomaPercFixo		:= 0
	Local nPercRealizObtid := 0
	Local nPercVarObtid := 0
	Local cDriver		:= TCGetDB()
	Local cCct			:= "||"
	
	If cDriver = "MSSQL"
		cCct := "+"  //Caracter de concatenaçao 
	EndIF
	
	cQuery := " SELECT SUM(DXI_PSLIQU) AS TOTPSLIQU, MIN(DXI_DATA) AS MINDTBEN, " 
	cQuery += "		   MAX(DXI_DATA) as MAXDTBEN "
	cQuery += "   FROM " + RetSqlName('DXI')+ " DXI "
	cQuery += "  WHERE DXI_FILIAL 	= '"+ FWxFilial("DXI")	+"'"
	cQuery += "	   AND DXI_SAFRA 	= '"+ cSafra 	+"'	"
	
	If cDriver = 'ORACLE'
		cQuery += "	   AND TO_CHAR(DXI_DATA)    <= '"+ cMovDate 	+"'	"
	Else
		cQuery += "	   AND DXI_DATA    <= '"+ cMovDate 	+"'	"
	Endif
	
	cQuery += "	   AND DXI_HORA    <= '"+ cMovHour 	+"'	"
	cQuery += "	   AND D_E_L_E_T_   = ' ' "	 	
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	IF (cAliasQry)->(!Eof())
		nPsFardos	:= (cAliasQry)->TOTPSLIQU
		dMinDtBen	:= STOD((cAliasQry)->MINDTBEN)
		dMaxDtBen	:= STOD((cAliasQry)->MAXDTBEN)
	endIf

	(cAliasQry)->(dbCloseArea())
	cAliasQry := GetNextAlias()

	cQuery := " SELECT SUM(DXL_PSLIQU) AS TOTPSLIQU "
	cQuery += " FROM " + RetSqlName('DXL') + " DXL "

	cQuery += " INNER JOIN " + RetSqlName('SC2') + " SC2 ON " 
	cQuery += " (C2_FILIAL = '" + FWxFilial("SC2") + "'"
	cQuery += " AND (DXL_OP = C2_NUM " + cCct + " C2_ITEM " + cCct + " C2_SEQUEN))"
	cQuery += " WHERE DXL.DXL_FILIAL =  '"+ FWxFilial("DXL") +"'"
	cQuery += " AND DXL.DXL_SAFRA    =  '"+ cSafra +"' "
	cQuery += " AND DXL.DXL_STATUS   >= '4' " //Fardoes processados ou em processamento
	//4=Em Beneficiamento;5=Beneficiado;6=Finalizado
	
	If cDriver = 'ORACLE'
		cQuery += " AND TO_CHAR(DXL.DXL_DTDIGI)   <= '"+ cMovDate +"' "
	Else
		cQuery += " AND DXL.DXL_DTDIGI   <= '"+ cMovDate +"' "
	Endif
	cQuery += "	AND DXL.D_E_L_E_T_   =  ' ' "	 	

	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	IF (cAliasQry)->(!Eof())
		nPsFardao	:= (cAliasQry)->TOTPSLIQU
	endIf

	(cAliasQry)->(dbCloseArea())

	cXmlRet := "<ListOfIndex>"

	dbSelectArea('DXE')
	DXE->(dbSetOrder(1))
	If DXE->(DbSeek(FWxFilial('DXE')))
		While DXE->(!Eof()) .AND. DXE->DXE_FILIAL == FWxFilial('DXE')
			cXmlRet +=     "<Index>"
			If .Not. Empty(DXE->DXE_DTINIB)
				//Data prevista para inicio beneficiamento algodao - Campo do Conjunto 
				cXmlRet += "<StartCottonGinForecast>" + SubStr(DTOS(DXE->DXE_DTINIB), 1, 4) + '-' + SubStr(DTOS(DXE->DXE_DTINIB), 5, 2) + '-' + SubStr(DTOS(DXE->DXE_DTINIB), 7, 2) + "</StartCottonGinForecast>
			EndIf

			If .Not. Empty(DXE->DXE_DTFINB)
				//Data prevista para final beneficiamento algodão - Campo do Conjunto
				cXmlRet += "<ClosingCottonGinForecast>" + SubStr(DTOS(DXE->DXE_DTFINB), 1, 4) + '-' + SubStr(DTOS(DXE->DXE_DTFINB), 5, 2) + '-' + SubStr(DTOS(DXE->DXE_DTFINB), 7, 2) + "</ClosingCottonGinForecast>"
			EndIf

			If .Not. Empty(dMinDtBen)
				//Data início beneficiamento algodão:
				//Menor data de transação da tabela de fardinhos para a safra e conjunto (por beneficiadora)
				cXmlRet +="<StartCottonGin>"+ SubStr(DTOS(dMinDtBen), 1, 4) + '-' + SubStr(DTOS(dMinDtBen), 5, 2) + '-' + SubStr(DTOS(dMinDtBen), 7, 2) +"</StartCottonGin>"
			EndIf

			If .Not. Empty(dMaxDtBen)
				//Data final beneficiamento algodão:
				//Maior data de transação da tabela de fardinhos para a safra e conjunto (por beneficiadora)
				cXmlRet += "<ClosingCottonGin>" + SubStr(DTOS(dMaxDtBen), 1, 4) + '-' + SubStr(DTOS(dMaxDtBen), 5, 2) + '-' + SubStr(DTOS(dMaxDtBen), 7, 2) + "</ClosingCottonGin>"			
			EndIf

			//2DXC_FILIAL+DXC_CODIGO+DXC_TIPO-Realizado
			dbSelectArea('DXC')
			DXC->(DbGoTop())
			DXC->(dbSetOrder(2))
			If DXC->(DbSeek(FWxFilial('DXC') + DXE->DXE_CODIGO + "3"))
				While DXC->(!Eof()) .AND. DXC->DXC_FILIAL == FWxFilial('DXC') .AND. DXE->DXE_CODIGO == DXC->DXC_CODIGO .AND. DXC->DXC_TIPO == "3"
					If Empty(DXC->DXC_SITLAV)
						cXmlRet := STR0004 + DXC->DXC_CODIGO + '.' //'É necessário verificar o cadastro de tipo de produto(Pluma, Caroço, Fibrilha, Casquinha, Resíduo) do conjunto '
						Return {.F., cXmlRet}
					Else
						If DXC->DXC_SITLAV == '1' //Pluma

							nRealizado := DXE->DXE_RDMED
							If nRealizado > 0
								//% índice rendimento caroço projeto 
								cXmlRet += "<CottonFiberYieldIndexForecast>" + cValToChar(nRealizado) + "</CottonFiberYieldIndexForecast>"

								If nPsFardao > 0
									//% índice rendimento pluma obtida (Regra de 3 entre toda a produção colhida de algodão em caroço (representando 100%) 
									//e toda a produção beneficiada de pluma em fardinhos)		
									nPercRealizObtid := ROUND((nPsFardos / nPsFardao * 100), 2)
									cXmlRet += "<CottonFiberYieldIndex>" + cValToChar(nPercRealizObtid) + "</CottonFiberYieldIndex>"
									nPsTotRealiz := ROUND((nPsFardao * nRealizado / 100), 2)
								EndIf
							EndIf
						EndIf
					EndIF
					DXC->(dbSkip())
				EndDo
			EndIf

			//2DXC_FILIAL+DXC_CODIGO+DXC_TIPO-Fixo
			dbSelectArea('DXC')
			DXC->(DbGoTop())
			DXC->(dbSetOrder(2))
			If DXC->(DbSeek(FWxFilial('DXC') + DXE->DXE_CODIGO + "1"))
				While DXC->(!Eof()) .AND. DXC->DXC_FILIAL == FWxFilial('DXC') .AND. DXE->DXE_CODIGO == DXC->DXC_CODIGO .AND. DXC->DXC_TIPO == "1" 
					If Empty(DXC->DXC_SITLAV)
						cXmlRet := STR0004 + DXC->DXC_CODIGO + '.' //'É necessário verificar o cadastro de tipo de produto(Pluma, Caroço, Fibrilha, Casquinha, Resíduo) do conjunto '
						Return {.F., cXmlRet}
					Else
						If DXC->DXC_SITLAV == '2' //Caroco
							//% índice rendimento caroço projeto 
							cXmlRet += "<CottonSeedYieldIndexForecast>" + cValToChar(DXC->DXC_PERC) + "</CottonSeedYieldIndexForecast>"
							nSomaPercFixo += DXC->DXC_PERC

							If nPsFardao > 0
								cXmlRet += "<CottonSeedYieldIndex>" + cValToChar(DXC->DXC_PERC) + "</CottonSeedYieldIndex>"
							EndIf
						EndIf
						If DXC->DXC_SITLAV == '3' //Fibrilha
							//% índice rendimento fibrilha projeto 
							cXmlRet += "<CottonStickYieldIndexForecast>" + cValToChar(DXC->DXC_PERC) + "</CottonStickYieldIndexForecast>"
							nSomaPercFixo += DXC->DXC_PERC

							If nPsFardao > 0
								cXmlRet += "<CottonStickYieldIndex>" + cValToChar(DXC->DXC_PERC) + "</CottonStickYieldIndex>"
							EndIf							

						EndIf					
						If DXC->DXC_SITLAV == '4' //Casquinha
							//% índice rendimento casquinha projeto 
							cXmlRet += "<CottonLeafYieldIndexForecast>" + cValToChar(DXC->DXC_PERC) + "</CottonLeafYieldIndexForecast>"
							nSomaPercFixo += DXC->DXC_PERC

							If nPsFardao > 0
								cXmlRet += "<CottonLeafYieldIndex>" + cValToChar(DXC->DXC_PERC) + "</CottonLeafYieldIndex>"
							EndIf									

						EndIf
						If DXC->DXC_SITLAV == '5' //Residuo
							//% índice rendimento impurezas projeto 
							cXmlRet += "<CottonResidueYieldIndexForecast>" + cValToChar(DXC->DXC_PERC) + "</CottonResidueYieldIndexForecast>"
							nSomaPercFixo += DXC->DXC_PERC

							If nPsFardao > 0
								cXmlRet += "<CottonResidueYieldIndex>" + cValToChar(DXC->DXC_PERC) + "</CottonResidueYieldIndex>"
							EndIf									
						EndIf

					EndIF
					DXC->(dbSkip())
				EndDo
			EndIf		

			nPercVarObtid := 100 - (nSomaPercFixo + nPercRealizObtid)
			nPercVarProj  := 100 - (nRealizado + nSomaPercFixo)

			//2DXC_FILIAL+DXC_CODIGO+DXC_TIPO-Variavel
			dbSelectArea('DXC')
			DXC->(DbGoTop())
			DXC->(dbSetOrder(2))
			If DXC->(DbSeek(FWxFilial('DXC') + DXE->DXE_CODIGO + "2"))
				While DXC->(!Eof()) .AND. DXC->DXC_FILIAL == FWxFilial('DXC') .AND. DXE->DXE_CODIGO == DXC->DXC_CODIGO .AND. DXC->DXC_TIPO == "2"
					If Empty(DXC->DXC_SITLAV)
						cXmlRet := STR0004 + DXC->DXC_CODIGO + '.' //'É necessário verificar o cadastro de tipo de produto(Pluma, Caroço, Fibrilha, Casquinha, Resíduo) do conjunto ' 
						Return {.F., cXmlRet}
					Else
						If DXC->DXC_SITLAV == '2' //Caroco
							//% índice rendimento caroço projeto 
							cXmlRet += "<CottonSeedYieldIndexForecast>" + cValToChar(nPercVarProj * DXC->DXC_PERC / 100 ) + "</CottonSeedYieldIndexForecast>"

							If nPsFardao > 0
								cXmlRet += "<CottonSeedYieldIndex>" + cValToChar(ROUND((nPercVarObtid * DXC->DXC_PERC / 100), 2)) + "</CottonSeedYieldIndex>"
							EndIf
						EndIf

						If DXC->DXC_SITLAV == '3' //Fibrilha
							//% índice rendimento fibrilha projeto 
							cXmlRet += "<CottonStickYieldIndexForecast>" + cValToChar(nPercVarProj * DXC->DXC_PERC / 100 ) + "</CottonStickYieldIndexForecast>"

							If nPsFardao > 0
								cXmlRet += "<CottonStickYieldIndex>" + cValToChar(ROUND((nPercVarObtid * DXC->DXC_PERC / 100), 2)) + "</CottonStickYieldIndex>"
							EndIf	
						EndIf	

						If DXC->DXC_SITLAV == '4' //Casquinha
							//% índice rendimento casquinha projeto
							cXmlRet += "<CottonLeafYieldIndexForecast>" + cValToChar(nPercVarProj * DXC->DXC_PERC / 100 ) + "</CottonLeafYieldIndexForecast>"

							If nPsFardao > 0
								cXmlRet += "<CottonLeafYieldIndex>" + cValToChar(ROUND((nPercVarObtid * DXC->DXC_PERC / 100), 2)) + "</CottonLeafYieldIndex>"
							EndIf	
						EndIf

						If DXC->DXC_SITLAV == '5' //Residuo
							//% índice rendimento impurezas projeto
							cXmlRet += "<CottonResidueYieldIndexForecast>" + cValToChar(nPercVarProj * DXC->DXC_PERC / 100 ) + "</CottonResidueYieldIndexForecast>"

							If nPsFardao > 0
								cXmlRet += "<CottonResidueYieldIndex>" + cValToChar(ROUND((nPercVarObtid * DXC->DXC_PERC / 100), 2)) + "</CottonResidueYieldIndex>"
							EndIf	
						EndIf
					EndIF
					DXC->(dbSkip())
				EndDo
			EndIf
			DXE->(dbSkip())
			cXmlRet +=     "</Index>"
		EndDo
		DXE->(DbCloseArea())
		cXmlRet += "</ListOfIndex>"
	Else
		lRet := .F.
		cXmlRet += STR0005 + cFilAnt //"Nenhum conjunto cadastrado para a filial: "
	EndIf

Return {lRet, cXmlRet}




/**
Deixar esta parte comentada para eventuais testes sem o ambiente PIMS (Protheus x Protheus)
{Protheus.doc} Tela
@author carlos.augusto
@since 30/06/2018
@version undefined
@param cTitulo, characters, descricao
@param cCampo, characters, descricao
@type function
Static Function Tela(cTitulo, cCampo)
Local cValor	:= "               "
Local cData		:= "          "
Local cRetorno	:= "               "
Local oDlg4

DEFINE MSDIALOG oDlg4 TITLE OemToAnsi( cTitulo) From 15,15 To 45,90 OF oMainWnd
@ 5,2 say OemtoAnsi( "Safra" ) //"Nome Funcao"
@ 6,2 MSget cValor Picture "@!" SIZE 150,12 

@ 7,2 say OemtoAnsi( "Data Inicial" ) //"Nome Funcao"
@ 8,2 MSget cData Picture "@!" SIZE 150,12 

ACTIVATE MSDIALOG oDlg4 ON INIT EnchoiceBar(oDlg4,{||oDlg4:End()},{||oDlg4:End()})

cRetorno := ALLTRIM(cValor)

Return {cRetorno,cData}
**/