#Include 'Protheus.ch'
#Include 'TMSAVBE.ch'

Static lTMAVBGRV := ExistBlock("TMAVBGRV")

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAVBe
Executa averbacao eletronica.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 26/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function TMSAVBe(cTipo, cFildoc, cDoc, cSerie)
Local aDocs := {}
Local aRetAvbe
Local nX
Local cNfeEltr
Local lDL5CliDev := .F.
Default	cTipo := " "

	aDocs := AvbeSelCte(cTipo, cFildoc, cDoc, cSerie)

	If !Empty(aDocs)
		lDL5CliDev := DL5->(ColumnPos('DL5_CLIDEV')) > 0
 
		For nX := 1 To Len(aDocs)
			aRetAvbe := AvbeIntWs(aDocs[nX])

			If !Empty(aRetAvbe)
				//verifica se o número utilizado para averbação foi o númreo de NFSE ou se foi a RPS
				if(At('<mod>98</mod>',aDocs[nX][6])> 0)
					nPosIni:= At('<nCT>',aDocs[nX][6])
					nPosFim:= At('</nCT>',aDocs[nX][6]) - nPosIni
					cNfeEltr:=  SubStr(aDocs[nX][6],nPosIni+5,nPosFim-5)
				else
					cNfeEltr:= ''
				endif
				aAdd(aRetAvbe,cNfeEltr)			
				AvbeGrvInt(aRetAvbe, lDL5CliDev) 
			EndIF
		Next nX		
	EndIF	

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAVBeM
Executa averbacao eletronica do MDFe.
@type function
@author Rodolfo K Rosseto
@version 12.1.17
@since 28/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TmsAvbeM(cFilMan, cManif, cSerMan, dDatMan,cCodRet,cSeqCond)

Local aManif 	:= {}
Local aRetAvbe	:= {}
Local nX 		:= 0
Local aJobParam := If(Len(cFilMan)>0,cFilMan,{})
Default cFilMan	:= ""
Default cManif 	:= ""
Default cSerMan := ""
Default dDatMan := Ctod('  /  /  ')
Default cCodRet := ""
Default cSeqCond := ""

If Len(aJobParam) > 0 .And. ValType(cFilman) == "A"
	//| Inicializa as variável de argumento da função com o valor padrao.
	cFilMan := ""
	//| Carrega o ambiente
	RpcSetenv(aJobParam[1],aJobParam[2])
EndIf
If !(TableIndic("DL6") .And. TableIndic("DLI"))
	MsgNextRel( "Averbacao de Seguro - Tabelas DLI e DL6" )
	Return
EndIf

If !Empty(cManif) .And. !IsInCallStack("TMSAE74") //--Se chamado pelo monitor ja gravou o evento, nao precisa chamar novamente 
	AvbGrvMdf(cFilMan, cManif, cSerMan, dDatMan, cCodRet, cSeqCond)
EndIf

aManif := AvbSlMdf(cFilMan, cManif, cSerMan, cCodRet, cSeqCond)

For nX := 1 To Len(aManif)
	aRetAvbe := AvbeMdfWs(aManif[nX])
Next nX

Return .T.


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
Permite a execucao da rotina via Scheddef.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 28/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function Scheddef()
Local aParam

aParam := {"P",;  	//Tipo R para relatorio P para processo   
		   ,;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DL5",;  // Alias            
		   ,;   	//Array de ordens   
		   'Schedule - Averbação Eletrônica'} //--> Schedule - Averbação Eletrônica    

Return aParam

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeSelCte
Gera array com os CTes que devem ser averbados.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 25/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeSelCte(cTipo, cFildoc, cDoc, cSerie)

	Local cAliasDL5   := GetNextAlias()
	Local cQuery      := ''
	Local aDocs	  	  := {}
	Local cFilStatus  := ''
	Local cTipoAvb    := ''
	Local lAddDoc     := .F.
	Local lCampoDL5   := DL5->(ColumnPos("DL5_DOCTMS")) > 0
	Local lLogAvb	:= DL6->(FieldPos('DL6_LOGAVB')) > 0
	Local cDir		:= ""
	Local nX		:= 0

	Do Case
		Case (cTipo == "0")//Somente averbacao
			cFilStatus := " AND DL5_STATUS IN ('0','1','3') "	
		Case (cTipo == "1")//Somente cancelamento da averbacao
			cFilStatus := " AND DL5_STATUS IN ('4','5','7') "
		OtherWise //Averbacao e cancelamento
			cFilStatus := " AND DL5_STATUS IN ('0','1','3','4','5','7') "
	EndCase	 
	
	cQuery := " SELECT DISTINCT DL5_FILDOC, DL5_DOC, DL5_SERIE, DL5_STATUS, DL5_CODSEG, DL5_TPMOV "
	If lCampoDL5 
		cQuery += ", DL5_DOCTMS " 
	endif
	cQuery += " FROM " + RetSqlName("DL5") 
	cQuery += " WHERE DL5_FILIAL = '" + xFilial("DL5")  + "' "
	cQuery += cFilStatus
	If !Empty(cFildoc)
		cQuery += " AND DL5_FILDOC = '"+Padr(cFildoc,TamSx3("DL5_FILDOC")[1])+"'" 
	EndIf	
	If !Empty(cDoc)
		cQuery += " AND DL5_DOC = '"+cDoc+"'" 
	EndIf
	If !Empty(cSerie)
		cQuery += " AND DL5_SERIE = '"+cSerie+"'" 
	EndIf
	
	If IsBlind()
		cQuery += " AND DL5_DATEMI >= '" + DToS(DaySub(dDataBase, 10)) + "'" 
	EndIf

	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDL5, .F., .T.)
				
	Do While !(cAliasDL5)->(Eof())
		If Val((cAliasDL5)->DL5_STATUS) < 4
			cTipoAvb := 'N'//Averbacao
		Else
			cTipoAvb := 'C'//Cancelamento da Averbacao
		EndIF

		If lCampoDL5 .And. (cAliasDL5)->DL5_DOCTMS $ "5,D,F,G"  //Nota Fiscal
			lAddDoc:= AvbeVldDoc((cAliasDL5)->DL5_FILDOC,(cAliasDL5)->DL5_DOC,(cAliasDL5)->DL5_SERIE)
		Else
			lAddDoc:= .T.
		EndIf	
		
		If lAddDoc
			aadd(aDocs,{})
			aadd(Atail(aDocs),cTipoAvb)
			aadd(Atail(aDocs),(cAliasDL5)->DL5_FILDOC)
			aadd(Atail(aDocs),(cAliasDL5)->DL5_DOC)
			aadd(Atail(aDocs),(cAliasDL5)->DL5_SERIE)
			aadd(Atail(aDocs),(cAliasDL5)->DL5_CODSEG)
			aadd(Atail(aDocs),AvbeRetXml( cTipoAvb, (cAliasDL5)->DL5_FILDOC, (cAliasDL5)->DL5_DOC, (cAliasDL5)->DL5_SERIE, If ( lCampoDL5, (cAliasDL5)->DL5_DOCTMS," "), (cAliasDL5)->DL5_TPMOV ) )

			DL6->(dbSetOrder(1))
			If DL6->(MsSeek(xFilial('DL6')+(cAliasDL5)->DL5_CODSEG))
				aadd(Atail(aDocs),AllTrim(DL6->DL6_LOGIN))
				aadd(Atail(aDocs),AllTrim(DL6->DL6_SENHA))
				aadd(Atail(aDocs),AllTrim(DL6->DL6_CODEMP))
				aadd(Atail(aDocs),AllTrim(DL6->DL6_ENDSOA))
				aadd(Atail(aDocs), If( lLogAvb, DL6->DL6_LOGAVB, "" ) )
			Else
				aadd(Atail(aDocs),'')
				aadd(Atail(aDocs),'')
				aadd(Atail(aDocs),'')
				aadd(Atail(aDocs),'')
				aadd(Atail(aDocs),'')
			EndIF	
		EndIf

		(cAliasDL5)->(DbSkip())
	EndDo
	(cAliasDL5)->( DbCloseArea() )

	If !( IsBlind() ) .AND. lLogAvb
		Pergunte( "TMSA296", .F. )
		cDir := If( ValType(MV_PAR15) == 'C', MV_PAR15, "" )

		For nX := 1 To Len(aDocs)
			If !Empty( aDocs[ nX, 11 ] )
				If aDocs[nX,11] == '1' .AND. !Empty( aDocs[nX,6] ) .AND. !Empty( cDir )
					TMSGerXML( cDir, aDocs[nX,6], '57' + aDocs[nX,2] + aDocs[nX,3] + aDocs[nX,4] )
				ElseIf aDocs[nX,11] == '2' .AND. !Empty( aDocs[nX,6] ) .AND. !Empty( cDir )
					TMSGerEma( cDir, aDocs[nX,6], '57', aDocs[nX,2], aDocs[nX,3], aDocs[nX,4] )
				EndIf
			EndIf
		Next nX
	EndIf
	
Return aDocs

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeRetXml
Retorna XML homologado do CTe.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 25/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeRetXml( cTipo, cFilDoc, cDoc, cSerie, cDocTms, cTpMov )

	Local cXml := ''
	Local oWS
	Local cXmlCan
	Local oXmlExp
	Local nPosChave
	Local cChaveCan
	Local lOk
	Local oRetEvCanc
	Local aAreaSM0	:= SM0->(GetArea())
	Local cURL		:= '' 
	Local lUsaColab	:= UsaColaboracao("2")	
	Local oDocColab

	If cDocTms == '5'
		If cTipo == 'N'//Averbacao
			cXML:= u_XmlNFSe(cFilDoc,cDoc, cSerie, cTpMov)
		Elseif	cTipo == 'C'//Cancelamento da Averbacao
			cXML:= u_XmlNFSeC(cFilDoc, cDoc, cSerie)
		EndIF
	
	Else
		If !lUsaColab
			SM0->(MsSeek(SM0->M0_CODIGO+cFilDoc))
			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
			
			oWS:= WSNFeSBRA():New()
			oWS:cUSERTOKEN    := "TOTVS"
			oWS:cID_ENT       := RetIdEnti(.F.)
			oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
			oWS:cIdInicial    := cSerie + cDoc
			oWS:cIdFinal      := cSerie + cDoc
			oWS:nDIASPARAEXCLUSAO := 0
			
			If oWS:RETORNAFAIXA()
				If Len(oWs:oWSRETORNAFAIXARESULT:OWSNOTAS:oWSNFES3) > 0
					If cTipo == 'N'
						cXML := AllTrim("<cteProc>")
						cXML += AllTrim(oWs:oWSRETORNAFAIXARESULT:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML)
						cXML += AllTrim(oWs:oWSRETORNAFAIXARESULT:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT)
						cXML += AllTrim("</cteProc>")
						//cXml := StrTran( cXml, "19368927002150", "53113791000122" ) //--Alterar o CNPJ do Sigamat para o da ATM para testes
					EndIF
					If cTipo == 'C'
						cXmlCan	  := oWs:oWSRETORNAFAIXARESULT:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
						nPosChave := At("<chCTe>",cXmlCan)+7
				 	    cChaveCan := SubStr(cXmlCan,nPosChave,44)
				 	    oWS:= WSNFeSBRA():New()
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= RetIdEnti(.F.)
						oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
						oWS:cID_EVENTO	:= "110111"
						oWS:cChvInicial	:= cChaveCan
						oWS:cChvFinal	:= cChaveCan
						lOk				:= oWS:NFEEXPORTAEVENTO()
						oRetEvCanc 		:= oWS:oWSNFEEXPORTAEVENTORESULT
						if lOk
							oXmlExp := XmlParser(oRetEvCanc:CSTRING[1],"_","","")
			 				cXML := AllTrim("<procEventoCTe>")
			 				cXML += XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
			 				cXML += XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
			 				cXML += AllTrim("</procEventoCTe>")
			 				//cXml := StrTran( cXml, "19368927002150", "53113791000122" ) //--Alterar o CNPJ do Sigamat para o da ATM para testes
						EndIF
					EndIF
				EndIf
			EndIf
			RestArea(aAreaSM0)
		Else //TOTVS Colaboracao
			oDocColab 	   := ColaboracaoDocumentos():new()
			oDocColab:cModelo  := "CTE"
			oDocColab:cTipoMov := "1"
			oDocColab:cIDERP   := cSerie+cDoc+FwGrpCompany()+FwCodFil()
			oDocColab:consultar()
			cXml := oDocColab:cXMLRet
		EndIf
	EndIf

Return cXml

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeIntWs
Realiza integracao com Web Service para transmitir os documentos que devem ser averbados/cancelados.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 25/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeIntWs(aDocs)
Local aRetAvbe := {}
Local aAvbOk := {}
Local aAvbErro := {}
Local oWsdl
Local nX
Local cDataAvb
Local cHrAvb
Local cProtocolo

	oWsdl := WSATMWebSvr():New()
	oWsdl:cusuario := aDocs[7]
	oWsdl:csenha := aDocs[8]
	oWsdl:ccodatm := aDocs[9]
	oWsdl:cLinkSoap := aDocs[10]
	oWsdl:cxmlCTe := aDocs[6]	
	oWsdl:averbaCTe()	
	If !Empty(oWsdl:oWsAverbaCteResponse:oWsAverbado) .OR. !Empty(oWsdl:oWsAverbaCteResponse:oWsErros)			
	
		aadd(aRetAvbe,aDocs[1])
		aadd(aRetAvbe,aDocs[2])
		aadd(aRetAvbe,aDocs[3])
		aadd(aRetAvbe,aDocs[4])
		aadd(aRetAvbe,aDocs[5])
		IF !Empty(oWsdl:oWsAverbaCteResponse:oWsAverbado)	
			IF !Empty(oWsdl:oWsAverbaCteResponse:oWsAverbado:cdhAverbacao)
				cDataAvb := SUBSTR(oWsdl:oWsAverbaCteResponse:oWsAverbado:cdhAverbacao,9,2)
				cDataAvb += '/'+SUBSTR(oWsdl:oWsAverbaCteResponse:oWsAverbado:cdhAverbacao,6,2)
				cDataAvb += '/'+SUBSTR(oWsdl:oWsAverbaCteResponse:oWsAverbado:cdhAverbacao,1,4)					
				cHrAvb := SUBSTR(oWsdl:oWsAverbaCteResponse:oWsAverbado:cdhAverbacao,12,2)
				cHrAvb += ':'+SUBSTR(oWsdl:oWsAverbaCteResponse:oWsAverbado:cdhAverbacao,15,2) 
			EndIF
			cProtocolo := oWsdl:oWsAverbaCteResponse:oWsAverbado:cProtocolo
			For nX := 1 to Len(oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro)
				aAdd(aAvbOk, {cDataAvb,;
				          	cHrAvb,;
				          	cProtocolo,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cNumeroAverbacao,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cCNPJSeguradora,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cNomeSeguradora,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cNumApolice,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cTpMov,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cTpDDR,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cValorAverbado,;
				          	oWsdl:oWsAverbaCteResponse:oWsAverbado:oWSDadosSeguro[nX]:cRamoAverbado;
				         	})					
			Next nX
		EndIF
			
		If !Empty(oWsdl:oWsAverbaCteResponse:oWsErros)
			For nX := 1 to Len(oWsdl:oWsAverbaCteResponse:oWsErros:oWsErro)
				aAdd(aAvbErro, {oWsdl:oWsAverbaCteResponse:oWsErros:oWsErro[nX]:CCODIGO, oWsdl:oWsAverbaCteResponse:oWsErros:oWsErro[nX]:CDESCRICAO})		
			Next nX
		EndIf
			
		aadd(aRetAvbe,aAvbOk)			
		aadd(aRetAvbe,aAvbErro)			

	Else
		TMSLogMsg("ERROR","Integracao AT&M - Erro ao acessar WebService")
	EndIF
Return aRetAvbe

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeGrvInt
Grava o retorno da integracao de averbacao no banco de dados.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 27/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeGrvInt(aAvbe, lDL5CliDev)
Local nX		:= 0
Local dDataEmi	:= ''
Local cHoraEmi	:= ''
Local cCliDev	:= '' 
Local cLojDev	:= '' 
Local cStatErro	:= ''
Local cMsgErro	:= ''

	//Averbacao normal
	If aAvbe[1] = 'N'
		DL5->(dbSetOrder(1))
		If DL5->(MsSeek(xFilial('DL5')+aAvbe[2]+aAvbe[3]+aAvbe[4]+aAvbe[5]))			
			
			//Erro na averbacao
			If Len(aAvbe[7]) > 0  
				For nX := 1 to Len(aAvbe[7])							
					If nX == 1
						cMsgErro := aAvbe[7][nx][1]+'-'+aAvbe[7][nx][2]
						If aAvbe[7][nx][1] $ '000/002/907/910'
							cStatErro := '1'//Falha de comunicacao 
						Else
							cStatErro := '3'//Recusado
						End
					Else  
						cMsgErro += ' / '+aAvbe[7][nx][1]+'-'+aAvbe[7][nx][2]
					EndIf			
				Next nX
				RecLock('DL5',.F.)
				DL5->DL5_STATUS := cStatErro				
				DL5->DL5_MSERRO := SubStr(cMsgErro,1,255)
				MsUnLock()		
			EndIF
			
			//Averbacao realizada com sucesso
        	
        	For nX := 1 to Len(aAvbe[6])
        		If nX == 1
        			dDataEmi := DL5->DL5_DATEMI
					cHoraEmi := DL5->DL5_HOREMI
					If lDL5CliDev
						cCliDev  := DL5->DL5_CLIDEV 
						cLojDev  := DL5->DL5_CLIDEV
					EndIf
					        		     	
        			RecLock('DL5',.F.)
        		Else
        			RecLock('DL5',.T.)
					DL5->DL5_FILIAL := xFilial("DL5")
					DL5->DL5_FILDOC := aAvbe[2]	
					DL5->DL5_DOC := aAvbe[3]
					DL5->DL5_SERIE := aAvbe[4]
					DL5->DL5_CODSEG := aAvbe[5]
					DL5->DL5_SEQ := cValToChar(nX)		
					DL5->DL5_DATEMI := dDataEmi
					DL5->DL5_HOREMI := cHoraEmi
					If lDL5CliDev
						DL5->DL5_CLIDEV := cCliDev 
						DL5->DL5_LOJDEV := cLojDev
					EndIf          		
        		EndIF				
				DL5->DL5_STATUS := '2'//averbado
				IF !Empty(aAvbe[6][nX][1])
					DL5->DL5_DATAVB := Ctod(aAvbe[6][nX][1])//Dt Averb
				EndIF
				IF !Empty(aAvbe[6][nX][2])
					DL5->DL5_HORAVB := StrTran(aAvbe[6][nX][2],':','')//Hr Aver
				EndIF
				DL5->DL5_PROTOC := aAvbe[6][nX][3]//Protocolo
				DL5->DL5_NUMAVB := aAvbe[6][nX][4]//Nr Aver
				DL5->DL5_CNPJSE := aAvbe[6][nX][5]//Cnpj Seg
				DL5->DL5_NOMESE := aAvbe[6][nX][6]//Nome Seg
				DL5->DL5_NUMAPO := aAvbe[6][nX][7]//Nr Apolice
				DL5->DL5_TPMOV  := aAvbe[6][nX][8]//Tipo Mov
				DL5->DL5_TPDDR  := aAvbe[6][nX][9]//Tipo DDR
				IF !Empty(aAvbe[6][nX][10])
					DL5->DL5_VALAVB := Val(aAvbe[6][nX][10])//Vlr Aver
				EndIF
				DL5->DL5_RAMO   := aAvbe[6][nX][11]//Ramo					
				DL5->DL5_MSERRO := ''//Msg Erro.
				//preenche com o número da nota fiscal eletrônica
				if !Empty(aAvbe[8])
					DL5->DL5_NFAVBE:= aAvbe[8]
				endif
				MsUnLock()				

				If lTMAVBGRV
					ExecBlock("TMAVBGRV",.F.,.F.,{DL5->DL5_FILDOC,DL5->DL5_DOC,DL5->DL5_SERIE})
				EndIf

			Next nX							
		EndIF
	EndIF
	
	//Cancelamento Averbacao
	If aAvbe[1] = 'C'
		DL5->(dbSetOrder(1))
		If DL5->(MsSeek(xFilial('DL5')+aAvbe[2]+aAvbe[3]+aAvbe[4]+aAvbe[5]))
			
			//Erro no cancelamento da averbacao
			If Len(aAvbe[7]) > 0  
				For nX := 1 to Len(aAvbe[7])							
					If nX == 1
						cMsgErro := aAvbe[7][nx][1]+'-'+aAvbe[7][nx][2]
						If aAvbe[7][nx][1] $ '000/002/907/910'
							cStatErro := '5'//Falha de comunicacao do cancelamento 
						Else
							cStatErro := '7'//Cancelamento Recusado
						End
					Else  
						cMsgErro += ' / '+aAvbe[7][nx][1]+'-'+aAvbe[7][nx][2]
					EndIf			
				Next nX
				
				While DL5->(!EOF()) .And. xFilial("DL5")+aAvbe[2]+aAvbe[3]+aAvbe[4]+aAvbe[5] == DL5->DL5_FILIAL + DL5->DL5_FILDOC + DL5->DL5_DOC + DL5->DL5_SERIE + DL5->DL5_CODSEG
					RecLock('DL5',.F.)
					DL5->DL5_STATUS := cStatErro				
					DL5->DL5_MSERRO := SubStr(cMsgErro,1,255)
					MsUnLock()
					DL5->(dbSkip())
				EndDo		
			EndIF
			
			//Sucesso no cancelamento
			If Len(aAvbe[6]) > 0
				While DL5->(!EOF()) .And. xFilial("DL5")+aAvbe[2]+aAvbe[3]+aAvbe[4]+aAvbe[5] == DL5->DL5_FILIAL + DL5->DL5_FILDOC + DL5->DL5_DOC + DL5->DL5_SERIE + DL5->DL5_CODSEG				
					RecLock('DL5',.F.)				
					DL5->DL5_STATUS := '6'//Cancelado
					DL5->DL5_TPMOV 	:= '2' //--Cancelado
					DL5->DL5_MSERRO := ''//Msg Erro.
					MsUnLock()					
					DL5->(dbSkip())
				EndDo
			EndIf
		EndIF		
	EndIf	

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeGrvCte
Grava CTe na tabela de averbacao eletronica.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 22/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeGrvCte(cFildoc, cDoc, cSerie, dDataEmi, cHoraEmi, cStatusCte, cDocTms, cCliDev, cLojDev )
Local cForSeg	:= SuperGetMv( "MV_FORSEG",,'' )
Local cCodSeg	:= ''
Local cLojaSeg	:= ''
Local cQuery	:= ''
Local cAliasQry	:= ''
Local nTamCod	:= TamSx3("A2_COD")[1]
Local nTamLoj	:= TamSx3("A2_LOJA")[1]
Local dDataIniAv:= CTOD('01/11/2017') 
Local cNumApol	:= ''
Local cTipoMov	:= ''
Local cCNPJSeg	:= ''
Local cNomeSeg	:= ''
Local lDocTms	:= ( DL5->(ColumnPos("DL5_DOCTMS")) > 0 )
Local lCliDev	:= ( DL5->(ColumnPos("DL5_CLIDEV")) > 0 )
Local lVlMerc	:= ( DL5->(ColumnPos("DL5_VALMER")) > 0 )
			
	If cStatusCte == '100'//Aprovado
		If dDataEmi >= dDataIniAv		
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DV6.DV6_CODSEG, DV6.DV6_LOJSEG, DV6_APOL "
			cQuery += "   FROM " + RetSqlName("DV6") + " DV6 "
			cQuery += "   WHERE DV6.DV6_FILIAL = '" + xFilial("DV6") + "' "
			cQuery += "     AND DV6.DV6_CLIDEV = '" + cCliDev + "' "
			cQuery += "     AND DV6.DV6_LOJDEV = '" + cLojDev + "' " 
			cQuery += "     AND DV6.DV6_INIVIG <= '" + DToS(dDataBase) + "' "
			cQuery += "     AND ( DV6.DV6_FIMVIG  = ' ' OR DV6.DV6_FIMVIG >= '" + DToS(dDataBase) + "' )"
			cQuery += "     AND ( DV6.DV6_AVBE = '1' OR DV6.DV6_AVBE = ' ') "
			cQuery += "     AND DV6.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			If (cAliasQry)->(!Eof())
				cCodSeg :=  Padr((cAliasQry)->DV6_CODSEG,nTamCod) 	
				cLojaSeg := Padr((cAliasQry)->DV6_LOJSEG,nTamLoj)
				cNumApol := (cAliasQry)->DV6_APOL
				cTipoMov := '4'//Avb Resp Cliente				
			EndIF
					
			If !(cTipoMov == '4')
			 	cCodSeg := Substr(cForSeg,1,nTamCod)
			 	cLojaSeg := Substr(cForSeg,nTamCod+1,nTamLoj)
			 	cTipoMov := '1' 
			EndIF
			
			SA2->(DbSetOrder(1))
			If SA2->(MsSeek(xFilial("SA2")+cCodSeg+cLojaSeg))
				cCNPJSeg := SA2->A2_CGC
				cNomeSeg := SA2->A2_NOME
				If cTipoMov == '1'
					cNumApol := SA2->A2_APOLICE	
				EndIF
			EndIF
			
			DL6->(dbSetOrder(2))
			If DL6->(MsSeek(xFilial('DL6')+cCodSeg+cLojaSeg))
				If ( (!Empty(DL6->DL6_TIPDOC)) .AND.;
                 	(cDocTms $ DL6->DL6_TIPDOC .OR. AllTrim(DL6->DL6_TIPDOC) == '*') ) 
					DL5->(dbSetOrder(1))										
					If !DL5->(MsSeek(xFilial('DL5')+Padr(cFildoc,TamSx3("DL5_FILDOC")[1])+cDoc+cSerie))						
						
						RecLock( 'DL5', .T. )
							DL5->DL5_FILIAL	:= xFilial("DL5")
							DL5->DL5_FILDOC	:= Padr(cFildoc,TamSx3("DL5_FILDOC")[1])
							DL5->DL5_DOC	:= cDoc
							DL5->DL5_SERIE	:= cSerie
							DL5->DL5_CODSEG	:= DL6->DL6_CODSEG
							DL5->DL5_SEQ	:= '1'
							DL5->DL5_DATEMI	:= dDataEmi
							DL5->DL5_HOREMI	:= cHoraEmi
							DL5->DL5_STATUS	:= '0'
							DL5->DL5_NUMAPO	:= cNumApol
							DL5->DL5_CNPJSE	:= cCNPJSeg
							DL5->DL5_NOMESE	:= cNomeSeg
							DL5->DL5_TPMOV	:= cTipoMov
							If lDocTms
								DL5->DL5_DOCTMS	:= cDocTms
							EndIf		 
							If lCliDev
								DL5->DL5_CLIDEV := cCliDev
								DL5->DL5_LOJDEV := cLojDev 			
							EndIf

							If lVlMerc
								DL5->DL5_VALMER	:= RetDT6VlM( Padr( cFildoc, TamSx3( "DL5_FILDOC")[1] ) + cDoc + cSerie )
							EndIf

						DL5->( MsUnLock() )

						If lTMAVBGRV
							ExecBlock("TMAVBGRV",.F.,.F.,{DL5->DL5_FILDOC,DL5->DL5_DOC,DL5->DL5_SERIE})
						EndIf

					EndIf
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())					
		EndIf
	EndIf

	If cStatusCte $ '101/102'//Cancelado
		DL5->(dbSetOrder(1))
		If	DL5->(MsSeek(xFilial('DL5')+Padr(cFildoc,TamSx3("DL5_FILDOC")[1])+cDoc+cSerie))
			While DL5->(!EOF()) .And. xFilial("DL5") + Padr(cFildoc,TamSx3("DL5_FILDOC")[1]) + cDoc + cSerie == DL5->DL5_FILIAL + DL5->DL5_FILDOC + DL5->DL5_DOC + DL5->DL5_SERIE
				If ( Alltrim(DL5->DL5_STATUS) $ '0/1/3')//Averbacao ainda nao transmitida ou erro na comunicacao/averbacao
					RecLock('DL5',.F.)				
					DL5->DL5_STATUS := '8'//cancelamento antes da averbacao
					MsUnLock()				
				EndIf
				
				if DL5->DL5_STATUS = '2'//Averbado
					RecLock('DL5',.F.)				
					DL5->DL5_STATUS := '4'//Aguardando cancelamento averbacao
					MsUnLock()				
				EndIf
				
				DL5->(dbSkip())
			EndDo
		EndIf
	EndIf
Return .T.


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbGrvMdf
Grava os eventos do MDFe na tabela de eventos do MDFe.
@type function
@author Rodolfo K Rosseto.
@version 12.1.17
@since 06/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function AvbGrvMdf(cFilMan, cManif, cSerMan, dDatMan, cStatMdf, cSeqCond)

Local cSeqEve 	:= "00"
Local lCont 	:= .T.
Local lIncCond 	:= IIf(cStatMdf == "003",.T.,.F.)
Local cForSeg 	:= SuperGetMv( "MV_FORSEG",,'' )
Local nTamCod 	:= TamSx3("A2_COD")[1]
Local nTamLoj 	:= TamSx3("A2_LOJA")[1]
Local cCodSeg 	:= Substr(cForSeg,1,nTamCod)
Local cLojaSeg	:= Substr(cForSeg,nTamCod+1,nTamLoj)

Default cSeqCond := ""

If !(TableIndic("DL6") .And. TableIndic("DLI"))
	MsgNextRel( "Averbacao de Seguro - Tabelas DLI e DL6" )
	lCont := .F.
EndIf	

DL6->(dbSetOrder(2))
If !DL6->(dbSeek(xFilial("DL6")+cCodSeg+cLojaSeg))
	lCont := .F.
EndIf

If lCont	
	//--Grava os eventos do MDFe
	DLI->(dbSetOrder(1))
	If lIncCond //--Inclusao do Condutor
		cSeekDLI := xFilial("DLI")+cFilMan+cManif+cSerMan+cStatMdf+cSeqCond	
	Else
		cSeekDLI := xFilial("DLI")+cFilMan+cManif+cSerMan+cStatMdf+cSeqEve
	EndIf		
	If !DLI->(dbSeek(cSeekDLI))		
		RecLock("DLI",.T.)
		DLI->DLI_FILIAL := xFilial("DLI")
		DLI->DLI_FILMAN := cFilMan
		DLI->DLI_MANIFE := cManif
		DLI->DLI_SERMAN := cSerMan
		DLI->DLI_DATEMI := Date()
		DLI->DLI_HOREMI := SubStr(Time(),1,2) +  SubStr(Time(),4,2)
		DLI->DLI_CODSEG := cCodSeg
		DLI->DLI_LOJSEG := cLojaSeg	
		DLI->DLI_CODEVE := cStatMdf
		If lIncCond
			DLI->DLI_SEQEVE := cSeqCond //--Inclusao de Condutor
		Else
			DLI->DLI_SEQEVE := cSeqEve
		EndIf		
		DLI->DLI_DESEVE := "Aguardando Averbacao"
		DLI->DLI_STATUS := "0" //--Aguardando Averbacao
		DLI->(MsUnLock())
	EndIf	
	
EndIf

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbSlMdf
Gera array com os Mdfes que devem ser averbados.
@type function
@author Rodolfo K Rosseto
@version 12.1.17
@since 28/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function AvbSlMdf(cFilMan, cManif, cSerMan, cCodRet, cSeqCond)

	Local cAliasDLI	  := GetNextAlias()
	Local cQuery      := ''
	Local aMdfe	  	  := {}
	Local lJob 		  := IIF(Empty(cManif),.T.,.F.) 
	Local lLogAvb	:= DL6->(FieldPos('DL6_LOGAVB')) > 0
	Local cDir		:= ""
	Local nX		:= 0

	Default cFilMan   := ""
	Default cManif    := ""
	Default cSerMan   := ""
	Default cCodRet   := ""
	Default cSeqCond  := ""

	cQuery := " SELECT DLI_FILMAN, DLI_MANIFE, DLI_SERMAN, DLI_CODSEG, DLI_DATEMI, DLI_LOJSEG, DLI_CODEVE, DLI_SEQEVE "
	cQuery += " FROM " + RetSqlName("DLI") 
	cQuery += " WHERE DLI_FILIAL = '" + xFilial("DLI")  + "' "
	If !lJob
		cQuery += " AND DLI_FILMAN = '" +Padr(cFilMan,TamSx3("DLI_FILMAN")[1]) + "' "
		cQuery += " AND DLI_MANIFE = '" + cManif + "' "
		cQuery += " AND DLI_SERMAN = '" + cSerMan + "' "
	EndIf
	If !Empty(cCodRet) .And. !Empty(cSeqCond)
		cQuery += " AND DLI_CODEVE = '" + cCodRet + "' "
		cQuery += " AND DLI_SEQEVE = '" + cSeqCond + "' "
	EndIf
	cQuery += " AND DLI_STATUS <> '1' " //--o que ainda nao foi Averbado
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DLI_FILIAL, DLI_FILMAN, DLI_MANIFE, DLI_SERMAN, DLI_CODEVE, DLI_SEQEVE " //--Ordenar pois existem eventos que precisam ir antes de outros
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDLI, .F., .T.)
				
	While !(cAliasDLI)->(Eof())
							
		aadd(aMdfe,{})
		aadd(Atail(aMdfe),(cAliasDLI)->DLI_FILMAN)
		aadd(Atail(aMdfe),(cAliasDLI)->DLI_MANIFE)
		aadd(Atail(aMdfe),(cAliasDLI)->DLI_SERMAN)
		aadd(Atail(aMdfe),AvbeMdfXml((cAliasDLI)->DLI_FILMAN,(cAliasDLI)->DLI_MANIFE,(cAliasDLI)->DLI_SERMAN,(cAliasDLI)->DLI_DATEMI,(cAliasDLI)->DLI_CODEVE,(cAliasDLI)->DLI_SEQEVE ) )
		aadd(Atail(aMdfe),(cAliasDLI)->DLI_CODEVE)

		DL6->(dbSetOrder(2))
		If DL6->(MsSeek(xFilial('DL6')+(cAliasDLI)->DLI_CODSEG+(cAliasDLI)->DLI_LOJSEG))
			aadd(Atail(aMdfe),AllTrim(DL6->DL6_LOGIN))
			aadd(Atail(aMdfe),AllTrim(DL6->DL6_SENHA))
			aadd(Atail(aMdfe),AllTrim(DL6->DL6_CODEMP))
			aadd(Atail(aMdfe),AllTrim(DL6->DL6_ENDSOA))
			aadd(Atail(aMdfe),If( lLogAvb, DL6->DL6_LOGAVB, "" ) )
		Else
			aadd(Atail(aMdfe),'')
			aadd(Atail(aMdfe),'')
			aadd(Atail(aMdfe),'')
			aadd(Atail(aMdfe),'')
			aadd(Atail(aMdfe),'')
		EndIF
		
		aadd(Atail(aMdfe),(cAliasDLI)->DLI_SEQEVE)
		
		(cAliasDLI)->(DbSkip())
	EndDo
	(cAliasDLI)->( DbCloseArea() )

	If !( IsBlind() ) .AND. lLogAvb
		Pergunte( "TMSA296", .F. )
		cDir := If( ValType(MV_PAR15) == 'C', MV_PAR15, "" )

		For nX := 1 To Len(aMdfe)
			If !Empty( aMdfe[ nX, 10 ] )
				If aMdfe[nX,10] == '1' .AND. !Empty( aMdfe[nX,4] ) .AND. !Empty( cDir )
					TMSGerXML( cDir, aMdfe[nX,4], '58' + aMdfe[nX,1] + aMdfe[nX,2] + aMdfe[nX,3] )
				ElseIf aMdfe[nX,10] == '2' .AND. !Empty( aMdfe[nX,4] ) .AND. !Empty( cDir )
					TMSGerEma( cDir, aMdfe[nX,4], '58', aMdfe[nX,1], aMdfe[nX,2], aMdfe[nX,3] )
				EndIf
			EndIf
		Next nX
	EndIf

Return aMdfe

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeMdfWs
Realiza integracao com Web Service para transmitir os documentos que devem ser averbados/cancelados.
@type function
@author Rodolfo K Rosseto.
@version 12.1.17
@since 25/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeMdfWs(aDocs)

Local oWsdl
Local cDataAvb   := ""
Local cHrAvb 	 := ""
Local cProtocolo := ""
Local cMan 		 := "" 
Local cSer 		 := ""
Local cSeqEvento := ""
Local aAreaDLI   := {} 

If !Empty(aDocs[4])
	aAreaDLI := DLI->(GetArea())
	oWsdl := WSATMWebSvr():New()
	oWsdl:cusuario	:= aDocs[6]
	oWsdl:csenha 	:= aDocs[7]
	oWsdl:ccodatm 	:= aDocs[8]
	oWsdl:cLinkSoap := aDocs[9]
	oWsdl:cxmlMDFe 	:= aDocs[4]
	oWsdl:declaraMDFe()
	cSeqEvento      := aDocs[11]
	
	If !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado) .Or. !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsErros)
		If !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado)
			cMan 		:= oWsdl:oWsdeclaraMdfeResponse:cNumero
			cSer 		:= oWsdl:oWsdeclaraMdfeResponse:cSerie
			cDataAvb	:= SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,9,2)
			cDataAvb 	+= '/'+SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,6,2)
			cDataAvb 	+= '/'+SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,1,4)
			cHrAvb 		:= SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,12,2)
			cHrAvb 		+= +SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,15,2)
			
			DLI->(dbSetOrder(1))
			If DLI->(dbSeek(xFilial("DLI") + aDocs[1] + aDocs[2] + aDocs[3] + aDocs[5] + cSeqEvento )) .And. DLI->DLI_CODEVE == aDocs[5]
				RecLock("DLI",.F.)				
				DLI->DLI_DTEVEN := Ctod(cDataAvb)  
				DLI->DLI_HREVEN := cHrAvb
				DLI->DLI_PROTOC := AllTrim(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cProtocolo)   
				DLI->DLI_DESEVE := "Averbado"  
				DLI->DLI_STATUS := "1" //--Averbado
				DLI->DLI_MARK   := " " //Se estiver averbado, desmarca o registro
				DLI->(MsUnLock())
			EndIf					
			
		ElseIf !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsErros)
			If DLI->(dbSeek(xFilial("DLI") + aDocs[1] + aDocs[2] + aDocs[3] + aDocs[5] + cSeqEvento )) .And. DLI->DLI_CODEVE == aDocs[5]
				RecLock("DLI",.F.)
				DLI->DLI_DTEVEN := Date()  
				DLI->DLI_HREVEN := SubStr(Time(),1,2) +  SubStr(Time(),4,2)  
				DLI->DLI_DESEVE := oWsdl:oWsDeclaraMdfeResponse:oWsErros:oWsErro[1]:CCODIGO + " - " + oWsdl:oWsDeclaraMdfeResponse:oWsErros:oWsErro[1]:CDESCRICAO
				DLI->DLI_STATUS := "2" //--Falha
				DLI->(MsUnLock())						
			EndIf
		EndIf
	EndIf
	RestArea(aAreaDLI)
EndIf
	
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeMdfXml
Retorna XML homologado do Mdfe.
@type function
@author Rodolfo K Rosseto.
@version 12.1.17
@since 25/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeMdfXml( cFilMan, cManif, cSerMan, cDatMan, cCodEve, cSeqEvento )

	Local oWS		:= Nil
	Local lOk 		:= .F.
	Local lUsaColab	:= UsaColaboracao("2")	
	Local cURL 		:= PadR(GetNewPar("MV_SPEDURL","http://"),250) 
	Local cVerMDfe 	:= ""
	Local cRetTag 	:= ""
	Local cFilBkp 	:= cFilAnt
	Local cXml 		:= ""
	Local cChaveCte := ""
	Local nZ 		:= 0
	Local aDTXArea := DTX->(GetArea())
	Local aDYNArea := DYN->(GetArea())

	Default cFilMan	:= ""
	Default cManif 	:= ""
	Default cSerMan := ""
	Default cCodEve    := ""
	Default cSeqEvento := ""
	Default cDatMan    := CToD("")
	Default cForLj	:= ""

	Private oXmlExp

	If !lUsaColab
		cFilAnt := cFilMan 

		If cCodEve == "001" //--Autorizacao 
			oWS:= WSNFeSBRA():New()
			oWS:cUSERTOKEN        := "TOTVS"
			oWS:cID_ENT           := RetIdEnti(lUsaColab)
			oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
			oWS:cIdInicial        := '58'+cSerMan+cManif
			oWS:cIdFinal          := '58'+cSerMan+cManif
			oWS:dDataDe           := DaySub(Stod(cDatMan), 3)
			oWS:dDataAte          := DaySum(Stod(cDatMan), 3)
			oWS:cCNPJDESTInicial  := ""
			oWS:cCNPJDESTFinal    := ""
			oWS:nDiasparaExclusao := 0
			lOk := oWS:RETORNAFX()
			oRetorno := oWS:oWsRetornaFxResult
			//--Montagem do XML para envio a Seguradora
			If lOk  .AND. Type('oRetorno:OWSNOTAS:OWSNFES3') == "A" .And. Len(oRetorno:OWSNOTAS:OWSNFES3) > 0
				oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[1]:OWSNFE:CXML,"","","")
				cVerMDfe := Iif(Type("oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT") <> "U", oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT, '')			
				cXml := '<![CDATA['+'<?xml version="1.0" encoding="UTF-8"?>'
				cXml += '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVerMDfe+'">'
				cXml += oRetorno:OWSNOTAS:OWSNFES3[1]:OWSNFE:CXML
				cXml += oRetorno:OWSNOTAS:OWSNFES3[1]:OWSNFE:CXMLPROT
				cXml += '</mdfeProc>' + ']]>'				
				//cXml := StrTran( cXml, "19368927002150", "53113791000122" ) //--Alterar o CNPJ do Sigamat para o da ATM para testes						
			EndIf
		EndIf
			
		If cCodEve $ "015;035;003"  //--015 Cancelamento --035 Encerramento --003 Inclusão de Condutor.		
			oWS:= WSNFeSBRA():New()
			oWS:cUSERTOKEN	:= "TOTVS"
			oWS:cID_ENT		:= RetIdEnti(lUsaColab)
			If cCodEve == "015" //Cancelamento
				cChaveCte := Posicione("DYN",3,xFilial("DYN")+cFilMan+cManif+cSerMan,"DYN_CHVMDF")
				oWS:cID_EVENTO	:= "ID110111" + cChaveCte + "01"
				oWS:cEvenChvNFE	:= cChaveCte
			ElseIf cCodEve == "035" //Encerramento
				cChaveCte := Posicione("DTX",2,xFilial("DTX")+cFilMan+cManif+cSerMan,"DTX_CHVMDF")
				oWS:cID_EVENTO	:= "ID110112" + cChaveCte + "01"
				oWS:cEvenChvNFE	:= Posicione("DTX",2,xFilial("DTX")+cFilMan+cManif+cSerMan,"DTX_CHVMDF")
			ElseIf cCodEve == "003" //Inclusão de Condutor
				cChaveCte := Posicione("DTX",2,xFilial("DTX")+cFilMan+cManif+cSerMan,"DTX_CHVMDF")
				//Verifica se é primeiro condutor
				oWS:cID_EVENTO	:= "ID110114" + cChaveCte + cSeqEvento
				oWS:cEvenChvNFE	:= cChaveCte
			EndIf
			oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
			lOk				:= oWS:NFERETORNAEVENTO()
			
			If lOk
				If valType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"
					aDados := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento
					For nZ := 1 To Len( aDados )
						cVerMDfe := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento[nZ]:cVersao
						cXml := '<procEventoMDFe versao="'+cVerMDfe+'">' //--Alterado o nome da TAG pois o WS da ATM nao aceita o que vem do TSS
						cXml += allTrim(aDados[nZ]:cXML_SIG)
						cXml += allTrim(aDados[nZ]:cXML_RET)																
						cXml += '</procEventoMDFe>'
						//cXml := StrTran( cXml, "19368927002150", "53113791000122" ) //--Alterar o CNPJ do Sigamat para o da ATM para testes
						cRetTag	:= '<mdfeRecepcaoEventoResult xmlns="http://www.portalfiscal.inf.br/mdfe/wsdl/MDFeRecepcaoEvento">' //--Retirado pois o WS da ATM nao aceita
						If AT(cRetTag,cXml) > 0 
							cXml 	:= Stuff(cXml,AT(cRetTag,cXml), (rAt(cRetTag,cXml)-at(cRetTag,cXml)+Len(cRetTag)),"")								
							cRetTag := '</mdfeRecepcaoEventoResult>' //--Retirado pois o WS da ATM nao aceita
							cXml 	:= Stuff(cXml,AT(cRetTag,cXml), (rAt(cRetTag,cXml)-at(cRetTag,cXml)+Len(cRetTag)),"")		
						EndIf														
					Next nZ
				EndIf
			EndIf					
		EndIf
		
		cFilAnt := cFilBkp
	EndIf

	RestArea(aDTXArea)
	RestArea(aDYNArea)
	
Return cXml

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeWsMdf
Realiza integracao com Web Service para transmitir os documentos que devem ser averbados/cancelados.
@type function
@author Rodolfo K Rosseto.
@version 12.1.17
@since 25/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function AvbeWsMdf(aDocs)

Local oWsdl
Local cDataAvb
Local cHrAvb
Local cMan 		:= "" 
Local cSer 		:= ""

If !Empty(aDocs[4])
	oWsdl := WSATMWebSvr():New()
	oWsdl:cusuario	:= aDocs[6]
	oWsdl:csenha 	:= aDocs[7]
	oWsdl:ccodatm 	:= aDocs[8]
	oWsdl:cLinkSoap := aDocs[9]
	oWsdl:cxmlMDFe 	:= aDocs[4]
	oWsdl:declaraMDFe()
	
	If !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado) .Or. !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsErros)
		If !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado)
			cMan 		:= oWsdl:oWsdeclaraMdfeResponse:cNumero
			cSer 		:= oWsdl:oWsdeclaraMdfeResponse:cSerie
			cDataAvb	:= SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,9,2)
			cDataAvb 	+= '/'+SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,6,2)
			cDataAvb 	+= '/'+SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,1,4)
			cHrAvb 		:= SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,12,2)
			cHrAvb 		+= +SUBSTR(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cdhChancela,15,2)
			
			If DLI->(dbSeek(xFilial("DLI")+aDocs[1]+aDocs[2]+aDocs[3]+aDocs[5])) .And. DLI->DLI_CODEVE == aDocs[5]
				RecLock("DLI",.F.)				
				DLI->DLI_DTEVEN := Ctod(cDataAvb)  
				DLI->DLI_HREVEN := cHrAvb
				DLI->DLI_PROTOC := AllTrim(oWsdl:oWsdeclaraMdfeResponse:oWsDeclarado:cProtocolo)   
				DLI->DLI_DESEVE := "Averbado"  
				DLI->DLI_STATUS := "1" //--Averbado
				DLI->(MsUnLock())
			EndIf					
			
		ElseIf !Empty(oWsdl:oWsdeclaraMdfeResponse:oWsErros)
			If DLI->(dbSeek(xFilial("DLI")+aDocs[1]+aDocs[2]+aDocs[3]+aDocs[5])) .And. DLI->DLI_CODEVE == aDocs[5]
				RecLock("DLI",.F.)				
				DLI->DLI_DTEVEN := Date()  
				DLI->DLI_HREVEN := SubStr(Time(),1,2) +  SubStr(Time(),4,2)  
				DLI->DLI_DESEVE := oWsdl:oWsDeclaraMdfeResponse:oWsErros:oWsErro[1]:CCODIGO + " - " + oWsdl:oWsDeclaraMdfeResponse:oWsErros:oWsErro[1]:CDESCRICAO
				DLI->DLI_STATUS := "2" //--Falha
				DLI->(MsUnLock())						
			EndIf
		EndIf
	EndIf
EndIf
	
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AvbeVldDoc
Valida a Nota Fiscal se está transmitida
@type function
@author Katia
@version 12.1.17
@since 23/06/2020
/*/
//-------------------------------------------------------------------------------------------------
Static Function AvbeVldDoc(cFilDoc,cDoc,cSerie)
Local lRet      := .F.
Local aAreaSF3  := SF3->(GetArea())

SF3->(dbSetOrder(6))
If SF3->(dbSeek(xFilial("SF3")+cDoc+cSerie))
	If !Empty(SF3->F3_NFELETR)
		lRet := .T.
	Else
		If (SF3->F3_ESTADO = 'DF' .And. SF3->F3_CODRSEF = '100')
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aAreaSF3)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Valida a Nota Fiscal se está transmitida
@type function
@author Rodrigo.Pirolo
@version 12.1.27
@since 19/03/2021
/*/
//-------------------------------------------------------------------------------------------------

Function TMSGerXML( cDir, cXML, cNome )

	Local lRet      := .F.

	Local nHandle	:= 0
	Local nLen		:= 0
	Local nPos		:= 0

	Default cDir	:= ""
	Default cXML	:= ""
	Default cNome	:= ""

	If !Empty(cDir) .AND. ExistDir(cDir) .AND. !Empty(cXML)
		cDir := AllTrim(cDir)
		
		nLen := Len(cDir)
		nPos := RAt( "\", cDir )
		
		If nLen <> nPos
			cDir += "\"
		EndIf

		nHandle := FCreate( cDir + cNome + ".xml" )

		If nHandle > 0
			lRet := FWrite( nHandle, cXML ) > 0

			If lRet
				FClose(nHandle)
			EndIf

		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Monta o e-mail para envio da averbação

@param		cXML	- Xml da averbação
@param		cDir	- E-mail de destino
@param		cCod	- Codigo idica se é MDF-e (58) ou não (57)
@param		cFil	- Filial do manifesto ou filial do Documento
@param		cNum	- Número do manifesto ou do Documento
@param		cSerie	- Série do manifesto ou do Documento
@type		function
@author		Rodrigo.Pirolo
@version	12.1.27
@since		19/03/2021
/*/
//-------------------------------------------------------------------------------------------------

Function TMSGerEma( cEmail, cXML, cCod, cFil, cNum, cSerie )

Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->( GetArea() )
Local cMsgErr	:= ""
Local cBody		:= ""
Local cTexto	:= ""
Local lSendMail	:= .F.
Local lEditMsg	:= .F.
Local cXML2		:= ""

Default cXML	:= ''
Default cViagem	:= ''

If IsEmail(cEmail)

	If cCod == '57'
		cSubject := STR0001 + cFil + "/" + cNum + "/" + cSerie //STR0001 "XML de Averbação Filial/Doc./Serie: "
	Else
		cSubject := STR0002 + cFil + "/" + cNum + "/" + cSerie //STR0002 "XML de Averbação Filial/Manif./Serie: "
	EndIf

	cBody := STR0003 + Chr(13) + Chr(10) // STR0003 "Olá, "
	cBody += STR0004 + Chr(13) + Chr(10) // STR0004 "Este é um e-mail automático enviado pelo Protheus TMS, ao executar a rotina de Averbação (TMSA296)."
	
	If cCod == '57'
		cTexto := STR0005 + cFil + "/" + cNum + "/" + cSerie // STR0005 "XML de Averbação referente a Filial/Documento/Serie: "
	Else
		cTexto := STR0006 + cFil + "/" + cNum + "/" + cSerie // STR0006 "XML de Averbação referente a Filial/Manifesto/Serie: "
	EndIf

	cBody += STR0007 + cTexto + Chr(13) + Chr(10) // STR0007  'Segue o '
	cBody += STR0008 + Chr(13) + Chr(10) // STR0008 'Atenciosamente,'
	cBody += Chr(13) + Chr(10)
	cBody += Posicione( "SM0", 1, SM0->M0_CODIGO + cFil, "M0_NOMECOM" ) + Chr(13) + Chr(10)
	cBody += Chr(13) + Chr(10)
	cBody += 'XML:' + Chr(13) + Chr(10)

	cXML2 := StrTran( cXML, "<", '&lt;', , )
	cXML2 := StrTran( cXML2, ">", '&gt;', , )

	cBody += cXML2
	
	lSendMail := TMSMAIL( { cEmail }, , cSubject, cBody, lEditMsg, '3', @cMsgErr )

	If !lSendMail .And. !Empty(cMsgErr)
		Help( '', 1, 'TMSGerEma', , cMsgErr, 2, 11 )  //-- Ocorreu um problema no envio do e-mail:
	EndIf

EndIf

RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetDT6VlM
Encontra o documento para gravar o valor da mercadoria.

@param		cSeek	- String para o DbSeek
@type		function
@author		Rodrigo.Pirolo
@version	12.1.33
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------------------------

Static Function RetDT6VlM( cSeek )

	Local aArea		:= GetArea()
	Local aAreaDT6	:= DT6->( GetArea() )
	Local aAreaDL5	:= DL5->( GetArea() )
	Local nRet		:= 0

	Default cSeek	:= ""

	DbSelectArea("DT6")
	DT6->( DbSetOrder(1) ) // DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE

	If DT6->( DbSeek( xFilial('DT6') + cSeek ) )
		nRet := DT6->DT6_VALMER
	EndIf

	RestArea( aArea )
	RestArea( aAreaDT6 )
	RestArea( aAreaDL5 )

Return nRet
