#INCLUDE "SFCC101.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCC101
Tela de consulta de item

@author Samantha Preima
@since 18/10/2010
@version P11
/*/
//-------------------------------------------------------------------
Function SFCC101()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'CZ3' )
oBrowse:SetDescription( STR0001 )  //'Item'
oBrowse:Activate()

Return NIL 

//-------------------------------------------------------------------
// Menu item
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.SFCC101' OPERATION 2 ACCESS 0  //'Visualizar'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.SFCC101' OPERATION 4 ACCESS 0  //'Alterar'

Return aRotina  

//-------------------------------------------------------------------
// Model de item
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCZ3 := FWFormStruct( 1, 'CZ3', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento de Parada
Local oModel   := MPFormModel():New( 'SFCC101', /*bPreValidacao*/, { | oMdl | SFCC101POS ( oMdl ) }, /*Commit*/,, /*bCancel*/ )
Local nI
Local oModelDet
Local oModDetStr

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CZ3MASTER', /*cOwner*/, oStruCZ3 )       

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )    //'Item'

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({"CZ3_FILIAL","CZ3_CDAC"})

oModelDet := oModel:GetModel( 'CZ3MASTER' )

// Adiciona a descricao do Componente do Modelo de Dados
oModelDet:SetDescription( STR0001 )  //'Item'

If IsInCallStack("SFCC101")
	oModDetStr := oModelDet:GetStruct()

	For nI := 1 To Len(oModDetStr:aFields) 
		If AllTrim(oModDetStr:aFields[nI][3]) != "CZ3_TPRPOR"
			oModDetStr:SetProperty(oModDetStr:aFields[nI][3], MODEL_FIELD_WHEN, { || .F. } )
		EndIf
	Next
EndIf

Return oModel

//-------------------------------------------------------------------
// View de Item
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCZ3 := FWFormStruct( 2, 'CZ3' ) // Pai - Apontamento de Parada
Local oModel   := FWLoadModel( 'SFCC101' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )    

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CZ3', oStruCZ3, 'CZ3MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI', 100 ) 

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CZ3', 'PAI' )

IF SFCIntegra() == 1
	oStruCZ3:RemoveField('CZ3_CDACRF')
	oStruCZ3:RemoveField('CZ3_CDFACM')
	oStruCZ3:RemoveField('CZ3_DSFACM')
	oStruCZ3:RemoveField('CZ3_LGCQ')
	oStruCZ3:RemoveField('CZ3_LGFC')
	oStruCZ3:RemoveField('CZ3_LGRF')
	oStruCZ3:RemoveField('CZ3_LGRFFI')
	oStruCZ3:RemoveField('CZ3_QTLOEC')
	oStruCZ3:RemoveField('CZ3_QTLOMI')
	oStruCZ3:RemoveField('CZ3_QTLOMU')
	oStruCZ3:RemoveField('CZ3_TPFO')
	oStruCZ3:RemoveField('CZ3_TPVF')
	oStruCZ3:RemoveField('CZ3_TPVFIV')
	oStruCZ3:RemoveField('CZ3_VLACRF')
	oStruCZ3:RemoveField('CZ3_VLPPM')
	oStruCZ3:RemoveField('CZ3_VLPSBR')
	oStruCZ3:RemoveField('CZ3_VLPSLQ')
Endif

Return oView     

//-------------------------------------------------------------------
// Validações
//-------------------------------------------------------------------
Static Function SFCC101POS (oModel)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local cMensagem := STR0007 //'O(s) campo(s) '
Local lExibe    := .F.

if nOpc == 3

	dbSelectArea("CZ3")
	CZ3->(dbSetOrder(1))	
	if CZ3->(dbSeek(xFilial('CZ3')+oModel:GetValue('CZ3MASTER','CZ3_CDAC')))
		SFCMsgErro(STR0003,"SFCC101") // 'Item já existe com a chave informada'
		lRet := .F.
	Endif  
	If lRet .And. SFCIntegra() == 1
		If Empty(oModel:GetValue('CZ3MASTER','CZ3_DTBG'))
	    	oModel:GetModel('CZ3MASTER'):SetValue('CZ3_DTBG', Date() )
	    EndIf
	    If Empty(oModel:GetValue('CZ3MASTER','CZ3_DTLB'))
	    	oModel:GetModel('CZ3MASTER'):SetValue('CZ3_DTLB', oModel:GetValue('CZ3MASTER','CZ3_DTBG') )
	    EndIf
	    If Empty(oModel:GetValue('CZ3MASTER','CZ3_CDES')) 
	    	oModel:GetModel('CZ3MASTER'):SetValue('CZ3_CDES', xFilial("CZ3") )
		EndIf 
	EndIf

EndIf	                   
If lRet .And. (nOpc == 3 .Or. nOpc ==4)
	 
	// Validações Integração Protheus
	If SFCIntegra() == 1
		If Empty(oModel:GetValue('CZ3MASTER','CZ3_CDUN'))
			SFCMsgErro(STR0004,"SFCC101") // 'Código da Unidade de Medida deve ser informado'
	   		lRet := .F.
	    ElseIf Empty(oModel:GetValue('CZ3MASTER','CZ3_CDFA'))
			SFCMsgErro(STR0005,"SFCC101") // 'Código da Família deve ser informado'
	   		lRet := .F.	   
	    Else 
	    	If Empty(oModel:GetValue('CZ3MASTER','CZ3_DSUN'))
	    		cMensagem += STR0008 //"'Descrição da Unidade de Medida', "
	    		lExibe    := .T.
	    	EndIf
	    	If lExibe
	    		cMensagem := Substr( cMensagem, 1, RAT( cMensagem, ',' ) )
	    		cMensagem += STR0011 // " não estão preenchidos"
	    		alert(cMensagem)                    
	    	EndIf
	    EndIf
	EndIf

	if SFCIntegra() == 1 .OR. DPRIntegra() == 1
		If Empty(oModel:GetValue('CZ3MASTER','CZ3_CDGR'))
			SFCMsgErro(STR0006,"SFCC101") // 'Código do Grupo de Estoque deve ser informado'
	   		lRet := .F.
		Endif
	Endif
	
Endif

Return lRet

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
                      

If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf


// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCC101: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))


	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCC101 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.
			
			If oXML != NIL
				If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
					oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
					oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
					
					lValid := .T.
				ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
					oBusinessContent = oXML:_BusinessContent
					oBusinessEvent = EAI_EVENT_UPSERT   
					
					lValid := .T.
				EndIf
			EndIf
			
            If lValid == .F.
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
			        
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCC101' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CZ3')
			CZ3->(dbSetOrder(1))
			lFound := CZ3->(dbSeek(xFilial('CZ3')+ oBusinessContent:_Code:TEXT))
			
			// Verifica se a mensagem é de Inclusão/Alteração
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como Alteração
				If lFound
					nOpc := 4
				Else 
					// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
					nOpc := 3						
				EndIf
			Else  
				// Apaga o registro  
				nOpc := 5						
			EndIf
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
            
            // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_CDAC', oBusinessContent:_Code:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
	            If XmlChildEx(oBusinessContent, '_NAME') != NIL
					lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_DSAC', 	SFCXXtoS(oBusinessContent:_Name:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				 
				If XmlChildEx(oBusinessContent, '_UNITOFMEASURECODE') != NIL
					lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_CDUN', 	SFCXXtoS(oBusinessContent:_UnitOfMeasureCode:TEXT) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					//oModel:SetValue('CZ3MASTER', 'CZ3_DSUN', 	SFCXXtoS(oBusinessContent:_UnitOfMeasureDescription:TEXT) )
				EndIf
				
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_TPAC', 	SFCXXtoS(oBusinessContent:_ObtainingType:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_CDGR', 	SFCXXtoS(oBusinessContent:_StockGroupCode:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_DSGR', 	SFCXXtoS(oBusinessContent:_StockGroupDescription:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_CDFA', 	SFCXXtoS(oBusinessContent:_FamilyCode:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_DSFA', 	SFCXXtoS(oBusinessContent:_FamilyDescription:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_DTBG', 	SFCXStoX(oBusinessContent:_DeployDate:TEXT, 'D') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_DTLB', 	SFCXSTOX(oBusinessContent:_ReleaseDate:TEXT, 'D') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_CDDP', 	SFCXXtoS(oBusinessContent:_StandardWarehouseCode:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_DSDP', 	SFCXXtoS(oBusinessContent:_StandardWarehouseDescription:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_QTLOMU', 	SFCXStoX(oBusinessContent:_MultipleLot:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_QTLOEC', 	SFCXStoX(oBusinessContent:_EconomicLot:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_QTLOMI', 	SFCXStoX(oBusinessContent:_MinimumLot:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_LGCQ', 	SFCXStoX(oBusinessContent:_QualityControl:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_TPVF', 	SFCXXtoS(oBusinessContent:_ControlType:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_TPVFIV', 	SFCXXtoS(oBusinessContent:_StockControlType:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_LGFC', 	SFCXSTOX(oBusinessContent:_FractionalQuantity:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_VLPSLQ', 	SFCXSTOX(oBusinessContent:_NetWeight:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_VLPSBR', 	SFCXSTOX(oBusinessContent:_GrossWeight:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				//oModel:SetValue('CZ3MASTER', 'CZ3_CDES', 	SFCXXtoS(oBusinessContent:_SiteCode:TEXT) )
				//oModel:SetValue('CZ3MASTER', 'CZ3_DSES', 	SFCXXtoS(oBusinessContent:_SiteDescription:TEXT) )
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_CDFACM', 	SFCXXtoS(oBusinessContent:_ComercialFamilyCode:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_DSFACM', 	SFCXXtoS(oBusinessContent:_ComercialFamilyDescription:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_TPFO', 	SFCXXtoS(oBusinessContent:_FormulaType:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_VLPPM', 	SFCXSTOX(oBusinessContent:_PerMillion:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_LGRF', 	SFCXSTOX(oBusinessContent:_IsScrapStockControl:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_LGRFFI', 	SFCXSTOX(oBusinessContent:_IsScrapFiscalPrice:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_CDACRF', 	SFCXXtoS(oBusinessContent:_ScrapItemCode:TEXT) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CZ3MASTER', 'CZ3_VLACRF', 	SFCXSTOX(oBusinessContent:_ScrapItemQuantity:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				


             EndIf
            
            // Validação no Model    
			if oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()    
				
				// Retorna OK
				cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'
				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem é de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCC101 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCC101 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCC101 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "Item",oModel:GetOperation(), { { "Code", oModel:GetValue("CZ3MASTER", 'CZ3_CDAC') } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          

		cXMLRet += '<Code>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDAC')) 		+ '</Code>'
		cXMLRet += '<Description>' 					+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DSAC')) 		+ '</Description>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<UnitOfMeasureCode>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDUN')) 		+ '</UnitOfMeasureCode>'
		   //	cXMLRet += '<UnitOfMeasureDescription>' 		+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DSUN')) 		+ '</UnitOfMeasureDescription>'
			cXMLRet += '<ObtainingType>' 					+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_TPAC')) 		+ '</ObtainingType>'
			cXMLRet += '<StockGroupCode>' 					+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDGR')) 		+ '</StockGroupCode>'
			cXMLRet += '<StockGroupDescription>' 			+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DSGR')) 		+ '</StockGroupDescription>'
			cXMLRet += '<FamilyCode>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDFA')) 		+ '</FamilyCode>'
			cXMLRet += '<FamilyDescription>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DSFA')) 		+ '</FamilyDescription>'
			cXMLRet += '<DeployDate>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DTBG')) 		+ '</DeployDate>'
			cXMLRet += '<ReleaseDate>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DTLB')) 		+ '</ReleaseDate>'
		   	cXMLRet += '<StandardWarehouseCode>' 			+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDDP')) 		+ '</StandardWarehouseCode>'
			cXMLRet += '<StandardWarehouseDescription>' 	+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DSDP')) 		+ '</StandardWarehouseDescription>'
			cXMLRet += '<MultipleLot>' 			   			+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_QTLOMU')) 		+ '</MultipleLot>'
			cXMLRet += '<EconomicLot>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_QTLOEC')) 		+ '</EconomicLot>'
			cXMLRet += '<MinimumLot>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_QTLOMI')) 		+ '</MinimumLot>'
			cXMLRet += '<QualityControl>' 					+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_LGCQ')) 		+ '</QualityControl>'
		   	cXMLRet += '<ControlType>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_TPVF')) 		+ '</ControlType>'
			cXMLRet += '<StockControlType>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_TPVFIV')) 		+ '</StockControlType>'
			cXMLRet += '<FractionalQuantity>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_LGFC')) 		+ '</FractionalQuantity>'
			cXMLRet += '<NetWeight>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_VLPSLQ')) 		+ '</NetWeight>'
			cXMLRet += '<GrossWeight>' 				   		+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_VLPSBR')) 		+ '</GrossWeight>'
			//cXMLRet += '<SiteCode>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDES')) 		+ '</SiteCode>'
			//cXMLRet += '<SiteDescription>' 					+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DSES')) 		+ '</SiteDescription>'                     
			cXMLRet += '<ComercialFamilyCode>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDFACM')) 		+ '</ComercialFamilyCode>'
			cXMLRet += '<ComercialFamilyDescription>' 		+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_DSFACM')) 		+ '</ComercialFamilyDescription>'
			cXMLRet += '<FormulaType>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_TPFO')) 		+ '</FormulaType>'
			cXMLRet += '<PerMillion>' 						+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_VLPPM')) 		+ '</PerMillion>'
			cXMLRet += '<IsScrapStockControl>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_LGRF'))   		+ '</IsScrapStockControl>'
			cXMLRet += '<IsScrapFiscalPrice>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_LGRFFI')) 		+ '</IsScrapFiscalPrice>'
			cXMLRet += '<ScrapItemCode>' 					+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_CDACRF')) 		+ '</ScrapItemCode>'
			cXMLRet += '<ScrapItemQuantity>' 				+ SFCXXtoS(oModel:GetValue("CZ3MASTER", 'CZ3_VLACRF')) 		+ '</ScrapItemQuantity>'

        EndIf
		                
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }


Function INTDF_C101( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)