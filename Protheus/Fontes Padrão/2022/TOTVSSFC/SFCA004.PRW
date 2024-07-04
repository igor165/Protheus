#INCLUDE "SFCA004.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA004  
Tela de cadastro de Motivo Parada

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA004()
Local oBrowse
Local lAtuCYN  := .F.

CYN->(dbSelectArea("CYN"))
If CYN->(FieldPos("CYN_LGMOD")) > 0
	lAtuCYN := .T.
EndIf

If lAtuCYN
	UPDMotiPar()
Else
	SFCValInt() // Verifica integração ligada
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYN')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Motivo Parada'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar' 
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA004' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA004' OPERATION 3 ACCESS 0    // 'Incluir'    
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA004' OPERATION 4 ACCESS 0    // 'Alterar'   
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA004' OPERATION 5 ACCESS 0    // 'Excluir'    
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA004' OPERATION 8 ACCESS 0    // 'Imprimir'   
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA004' OPERATION 9 ACCESS 0    // 'Copiar'   

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYN := FWFormStruct( 1, 'CYN', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA004', /*bPreValidacao*/, { |oMdl| SFCA004POS (oMdl) } , /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYNMASTER', /*cOwner*/, oStructCYN, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) // 'Modelo de Dados de Motivo Parada'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYNMASTER' ):SetDescription( STR0010 )   // 'Dados de Dados de Motivo Parada'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA004' )
// Cria a estrutura a ser usada na View
Local oStructCYN := FWFormStruct( 2, 'CYN' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYN', oStructCYN, 'CYNMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYN', 'TELA' )
          
// No Datasul, este campo possui tamanho 8
If SFCIntegra() == 0 
	oStructCYN:RemoveField("CYN_LGEF")
	oStructCYN:RemoveField("CYN_LGSU")
	oStructCYN:RemoveField("CYN_LGSS")
	oStructCYN:RemoveField("CYN_LGELEQ")
Endif

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA004POS
Rotina de validação da tabela

@param   oModel        Model da tabela

@author Samantha Preima
@since 04/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFCA004POS(oModel)
Local lRet     := .T.
Local nOpc     := oModel:GetOperation()
Local aArea    := GetArea()
Local aAreaCYX := CYX->(GetArea())
Local aAreaCZ2 := CZ2->(GetArea())
Local aAreaCZ7 := CZ7->(GetArea())
Local aAreaCZ5 := CZ5->(GetArea())
Local lSFC     := SFCIntegra() == 1

if lSFC
	If (nOpc == 4 .And. ((CYN->CYN_LGSU != oModel:GetValue('CYNMASTER','CYN_LGSU')) .Or. (CYN->CYN_LGSS != oModel:GetValue('CYNMASTER','CYN_LGSS'))) ) .Or. nOpc == 5  
		dbSelectArea('CYX')
		CYX->(dbSetOrder(6))
		IF CYX->(dbSeek(xFilial('CYX')+oModel:GetValue('CYNMASTER','CYN_CDSP')))
			SFCMsgErro(STR0011, 'SFCA004') //"Registro está sendo usado em Apontamento de Parada"
	    	lRet := .F.
		Endif              
	Endif
		
	if nOpc == 5
		dbSelectArea('CZ2')
		CZ2->(dbSetOrder(3))
		IF CZ2->(dbSeek(xFilial('CZ2')+oModel:GetValue('CYNMASTER','CYN_CDSP')))
			SFCMsgErro(STR0012, 'SFCA004') //"Registro está sendo usado em Manutenção Programada"
	    	lRet := .F.
		Endif
		
		dbSelectArea('CZ7')
		CZ7->(dbSetOrder(4))
		IF CZ7->(dbSeek(xFilial('CZ7')+oModel:GetValue('CYNMASTER','CYN_CDSP')))
			SFCMsgErro(STR0013 + ALLTRIM(CZ7->CZ7_IDSPTT), 'SFCA004') //"Registro está sendo usado na Parada Geral "
	    	lRet := .F.
		Endif
		
		dbSelectArea('CZ5')
		CZ5->(dbSetOrder(4))
		IF CZ5->(dbSeek(xFilial('CZ5')+oModel:GetValue('CYNMASTER','CYN_CDSP')))
			SFCMsgErro(STR0014, 'SFCA004') //"Registro está sendo usado nos Indicadores da Produção"
	    	lRet := .F.
		Endif     
	Endif
EndIf

RestArea(aAreaCYX)
RestArea(aAreaCZ2)
RestArea(aAreaCZ7)
RestArea(aAreaCZ5)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
Function UPDMotiPar()
Local lRet    := .T.
Local nI      := 0
Local cNaoMod := SuperGetMv('MV_MOTNMOD')
Local aDados  := {}

dbSelectArea('CYN')
CYN->(dbSetOrder(1))
IF !CYN->(dbSeek(xFilial('CYN')))
	aDados := FWGetSX5("44")
	For nI := 1 To Len(aDados)

		RecLock('CYN',.T.)
		
		CYN->CYN_FILIAL := xFilial('CYN')
		CYN->CYN_CDSP   := aDados[nI,3]
		CYN->CYN_LGMOD := !(ALLTRIM(aDados[nI,3]) $ cNaoMOD)
		CYN->CYN_DSSP   := aDados[nI,4]
		CYN->(MsUnLock())
	Next nI
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
Local aArea    := GetArea()
Local aAreaCYN := CYN->(GetArea())
                  
If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA004: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))


	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA004 Recebendo Mensagem Business' )
            
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
			oModel := FWLoadModel( 'SFCA004' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYN')
			CYN->(dbSetOrder(1))
			lFound := CYN->(dbSeek(xFilial('CYN')+oBusinessContent:_Code:TEXT))
			
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
					lAssign := oModel:SetValue('CYNMASTER', 'CYN_CDSP', oBusinessContent:_Code:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				lAssign := oModel:SetValue('CYNMASTER', 'CYN_DSSP'  , oBusinessContent:_Description:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYNMASTER', 'CYN_LGEF'  , SFCXStoX(oBusinessContent:_IsEfficiency:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYNMASTER', 'CYN_LGELEQ', SFCXStoX(oBusinessContent:_IsEmailEquipment:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				    
				//Seta os valores quando for inclusão ou quando for alterado
				If nOpc == 3 .Or. CYN->CYN_LGSS # SFCXStoX(oBusinessContent:_IsServiceRequest:TEXT, 'L') .Or. CYN->CYN_LGSS # SFCXStoX(oBusinessContent:_IsServiceRequest:TEXT, 'L')
					
					lAssign := oModel:SetValue('CYNMASTER', 'CYN_LGSS'  , SFCXStoX(oBusinessContent:_IsServiceRequest:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYNMASTER', 'CYN_LGSU'  , SFCXStoX(oBusinessContent:_IsSetup:TEXT, 'L') )                                                                          ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
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
            //conout( '+ IntegDef SFCA004 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA004 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA004 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "StopReason",oModel:GetOperation(), { { "Code", oModel:GetValue("CYNMASTER", "CYN_CDSP") } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          
                                                                                                               
		cXMLRet += '<Code>' 					  	 	+ oModel:GetValue("CYNMASTER", 'CYN_CDSP') 					+ '</Code>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<Description>'					+ oModel:GetValue("CYNMASTER", 'CYN_DSSP') 			     	+ '</Description>'
			cXMLRet += '<IsEfficiency>' 				+ SFCXXtoS( oModel:GetValue("CYNMASTER", 'CYN_LGEF') )		+ '</IsEfficiency>'
			cXMLRet += '<IsEmailEquipment>'				+ SFCXXtoS( oModel:GetValue("CYNMASTER", 'CYN_LGELEQ') )	+ '</IsEmailEquipment>'   
			cXMLRet += '<IsServiceRequest>' 			+ SFCXXtoS( oModel:GetValue("CYNMASTER", 'CYN_LGSS') )  	+ '</IsServiceRequest>'
			cXMLRet += '<IsSetup>'		 				+ SFCXXtoS( oModel:GetValue("CYNMASTER", 'CYN_LGSU') ) 		+ '</IsSetup>'
        EndIf
		                
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aAreaCYN)
RestArea(aArea)
                        
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }

Function INTDF_A004( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
