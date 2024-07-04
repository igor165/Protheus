#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#include "CRMA610.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRMI610O   ºAutor  ³Totvs Cascavel     º Data ³  27/07/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações cadastro Segmentos de Clientes        º±±
±±º          ³ utilizando o conceito de mensagem unica JSON.        	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRMI610O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRMI610O( oEAIObEt, nTypeTrans, cTypeMessage )

	Local lRet          := .T.
	Local lDelete		:= .F.
	Local nOpcx         := 3
	Local nX			:= 0
	Local nI			:= 0
	Local cLogErro      := ""
	Local aMakSeg      	:= {}
	Local aErroAuto     := {}	
	Local aChilds		:= {}
	Local cEvent        := "upsert"
	Local cProduct      := ""
	Local cValInt       := ""
	Local cValExt       := ""
	Local cAlias        := "AOV"
	Local cField        := "AOV_CODSEG" 
	Local cMsgUnica		:= 'MARKETSEGMENT'
	Local oModel		:= Nil
	Local oModAOV		:= Nil
	
	//Instancia objeto JSON
	Local ofwEAIObj	:= FWEAIobj():NEW()
	
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
	
   	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	If nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O' 
	
		//--------------------------------------
		//chegada de mensagem de negocios
		//--------------------------------------
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			
			cEvent := AllTrim(oEAIObEt:getEvent())
			
			If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
				cProduct := oEAIObEt:getHeaderValue("ProductName")
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := "ProductName é obrigatório!" //Ajustar Include
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
			EndIf
			
			//Codigo externo
			If oEAIObEt:getPropValue("CompanyInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("CompanyInternalId") )
				cValExt := oEAIObEt:getPropValue("CompanyInternalId")
			Endif
			
			//Codigo Segmento
			If oEAIObEt:getPropValue("MarketSegmentCode") != nil .And. !Empty( oEAIObEt:getPropValue("MarketSegmentCode") )
				aAdd(aMakSeg, {"AOV_CODSEG", oEAIObEt:getPropValue("MarketSegmentCode"), Nil})
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := "Codigo obrigatório!" //Ajustar Include
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)					
			Endif
			
			//Descricao
			If oEAIObEt:getPropValue("MarketSegmentDescription") != nil .And. !Empty( oEAIObEt:getPropValue("MarketSegmentDescription") ) 	
				aAdd(aMakSeg, {"AOV_DESSEG", oEAIObEt:getPropValue("MarketSegmentDescription"), Nil})
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := "Descricao obrigatório!" //Ajustar Include
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)					
			Endif
			
			//Segmento Principal
			If oEAIObEt:getPropValue("MainMarketSegment") != nil .And. !Empty( oEAIObEt:getPropValue("MainMarketSegment") )
				aAdd(aMakSeg, {"AOV_PRINC", Iif( Upper(oEAIObEt:getPropValue("MainMarketSegment")) == 'TRUE','1','2'), Nil})
			Endif
			
			//Segmento Pai
			If oEAIObEt:getPropValue("ParentMarketSegment") != nil .And. !Empty( oEAIObEt:getPropValue("ParentMarketSegment") )
				aAdd(aMakSeg, {"AOV_PAI", oEAIObEt:getPropValue("ParentMarketSegment"), Nil})
			Endif
			
			//Descricao Segmento Pai
			If oEAIObEt:getPropValue("ParentMarketSegmentDescription") != nil .And. !Empty( oEAIObEt:getPropValue("ParentMarketSegmentDescription") )
				aAdd(aMakSeg, {"AOV_DESPAI", oEAIObEt:getPropValue("ParentMarketSegmentDescription"), Nil})
			Endif
			
			//Bloqueado
			If oEAIObEt:getPropValue("IsActive") != nil .And. !Empty( oEAIObEt:getPropValue("IsActive") )
				aAdd(aMakSeg, {"AOV_MSBLQL", Iif( Upper(oEAIObEt:getPropValue("IsActive")) == 'TRUE','2','1'), Nil})	
			Endif			
			
			//Valida se roda rotina automatica
			If lRet
			
				//Obtém o valor interno da tabela XXF (de/para)		
				cValInt := CFGA070Int(cProduct, cAlias, cField, cValExt)
				
				If !Empty( cValInt )
					//Verifica tipo de evento
					If Upper(cEvent) == 'UPSERT' .Or. Upper(cEvent) == 'REQUEST'
						nOpcx := 4 // Update	
					ElseIf Upper(cEvent) == 'DELETE'
						nOpcx := 5 // Update
						lDelete := .T.
					Endif	
				Else
					cValInt := cFilAnt+'|'+oEAIObEt:getPropValue("MarketSegmentCode")
				Endif
			
				// Executa comando para insert, update ou delete conforme evento
				MSExecAuto({|x,y| CRMA610(x,y)}, aMakSeg, nOpcx)				
				
				// Se houve erros no processamento do MSExecAuto
				If lMsErroAuto
	         		aErroAuto := GetAutoGRLog()
	             	cLogErro := ""
		
	               	For nI := 1 To Len(aErroAuto)
	                  	cLogErro += aErroAuto[nI] + Chr(10)
	               	Next nI
	               	
	               	If Empty( cLogErro )
	               		cLogErro := MostraErro()
	               	Endif
		               	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
		         	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
		
		      		lRet := .F.
				Else
					// Monta o JSON de retorno
					ofwEAIObj:Activate()
																					
					ofwEAIObj:setProp("ReturnContent")
												
					ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cMsgUnica,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cValInt,,.T.)				
									
					CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, lDelete)	
				EndIf
					
			Endif
		
		//--------------------------------------
		//resposta da mensagem Unica TOTVS
		//--------------------------------------
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			
			//Verifica tipo do evento Inclusao/Alteracao/Exclusao
			If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
				lDelete := .T.					
			Endif	

			If oEAIObEt:getHeaderValue("ProductName") !=  nil
				cProduct := oEAIObEt:getHeaderValue("ProductName")
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := "Erro no retorno. O Product é obrigatório!" //Ajustar Include
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
			Endif
			
			If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
				cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := "Erro no retorno. O OriginalInternalId é obrigatório!" //Ajustar Include
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
			Endif
			
			If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
				cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := "Erro no retorno. O DestinationInternalId é obrigatório" //Ajustar Include
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
			Endif
			
			If !Empty(cValInt) .And. !Empty(cValExt) .And. lRet
				CFGA070MNT(cProduct, cAlias, cField, cValExt, cValInt, lDelete)
			Endif
			
		//--------------------------------------
	  	//whois
	  	//--------------------------------------
		ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
			Return {lRet,"1.000",cMsgUnica}
		EndIf
		
	//--------------------------------------
	//envio mensagem
	//--------------------------------------
	ElseIf(nTypeTrans == TRANS_SEND)
		
		//Recupera modelo ativo		
		oModel := FwModelActive()
		oModAOV := oModel:GetModel('AOVMASTER')
			
		//Montagem da mensagem de Segmento
		cEvent := If(oModel:GetOperation() = MODEL_OPERATION_DELETE, 'delete', 'upsert')
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)	
			
		ofwEAIObj:setprop("CompanyId", cEmpAnt)
		ofwEAIObj:setprop("CompanyInternalId", cFilAnt+"|"+oModAOV:GetValue('AOV_CODSEG'))
		ofwEAIObj:setprop("BranchId", cFilAnt)
		
		//Codigo Segmento
		ofwEAIObj:setprop("MarketSegmentCode", oModAOV:GetValue('AOV_CODSEG'))
		
		//Descricao
		ofwEAIObj:setprop("MarketSegmentDescription", RTrim( oModAOV:GetValue('AOV_DESSEG') ) )
		
		//Segmento Principal
		ofwEAIObj:setprop("MainMarketSegment", Iif( oModAOV:GetValue('AOV_PRINC') == '1' , 'True', 'False' ))
		
		//Segmento Pai
		ofwEAIObj:setprop("ParentMarketSegment", oModAOV:GetValue('AOV_PAI'))
		
		//Descricao Segmento Pai
		ofwEAIObj:setprop("ParentMarketSegmentDescription", RTrim( oModAOV:GetValue('AOV_DESPAI') ) )
		
		//Bloqueado
		ofwEAIObj:setprop("IsActive", Iif( oModAOV:GetValue('AOV_MSBLQL') == '2' , 'True', 'False' ))
		
		//Valida se e o segmento Pai
		If oModAOV:GetValue('AOV_PRINC') == '1'
			aChilds := RTCHILDS( oModAOV:GetValue('AOV_CODSEG') )
			
			If Len( aChilds ) > 0
				varinfo("aChilds",aChilds)
				For nX := 1 To Len( aChilds )
					ofwEAIObj:setprop('ListofChilds',{},'Child',,.T.)
					ofwEAIObj:get("ListofChilds")[nX]:setprop("MarketSegmentCode", aChilds[nX][1],,.T.)
					ofwEAIObj:get("ListofChilds")[nX]:setprop("MarketSegmentDescription", Rtrim(aChilds[nX][2]),,.T.)
				Next nX
			Endif
		Else
			//Segmento Filho
			ofwEAIObj:setprop('ListofChilds',{},'Child',,.T.)
		Endif
	
	Endif
	
	aSize(aChilds,0 )
	aChilds := {}
	
	aSize(aMakSeg,0 )
	aMakSeg := {}
	
	aSize(aErroAuto,0 )
	aErroAuto := {}

Return { lRet, ofwEAIObj, cMsgUnica }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTCHILDS  ºAutor  ³ Totvs Cascavel       º Data ³  27/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o codigo e descricao dos filhos do segmento PAI		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RTCHILDS( cCodSeg )

	Local aArea := GetArea()
	Local aRet 	:= {}

	Default cCodSeg := ""
	
	dbSelectArea("AOV")
	AOV->( dbSetOrder( 3 ) )
	AOV->( dbGoTop( ) )
	If dbSeek( xFilial("AOV")+cCodSeg )
		While AOV->( !Eof( ) ) .And. xFilial("AOV") == AOV->AOV_FILIAL .And. cCodSeg == AOV->AOV_PAI 
			Aadd( aRet,{ AOV->AOV_CODSEG, AOV->AOV_DESSEG } )
			AOV->( dbSkip( ) )
		Enddo
	Endif

	RestArea(aArea)
	aSize(aArea,0)

Return aRet


