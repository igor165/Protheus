#INCLUDE "SFCA003.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA003
Tela de cadastro de Motivo Refugo

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA003()
Local oBrowse

UPDMotiRef()

If !campoCYO()
	SFCValInt() // Verifica integração ligada
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYO')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Motivo Refugo'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA003' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA003' OPERATION 3 ACCESS 0  // 'Incluir'   
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA003' OPERATION 4 ACCESS 0  // 'Alterar'    
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA003' OPERATION 5 ACCESS 0  // 'Excluir'    
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA003' OPERATION 8 ACCESS 0  // 'Imprimir'   
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA003' OPERATION 9 ACCESS 0  // 'Copiar'     

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYO := FWFormStruct( 1, 'CYO', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA003', /*bPreValidacao*/, { |oX| SFCA003INC( oX ) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYOMASTER', /*cOwner*/, oStructCYO, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) // 'Modelo de Dados de Motivo Refugo'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYOMASTER' ):SetDescription( STR0010 )   // 'Dados de Dados de Motivo Refugo'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA003' )
// Cria a estrutura a ser usada na View
Local oStructCYO := FWFormStruct( 2, 'CYO' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYO', oStructCYO, 'CYOMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYO', 'TELA' )  

If !campoCYO()
	If SFCIntegra() == 0
		oStructCYO:RemoveField("CYO_LGRT")
		oStructCYO:RemoveField("CYO_LGRFMP")
	Endif
EndIf

Return oView  

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA003INC 
Rotina para Validar os dados no momento da inclusão ou alteração
Uso Geral.

@param   oModel        Objeto do model principal
@author Tiago Gauziski
@since 31/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA003INC (oModel)
Local lRet     := .T.
local nOpc     := (oModel:GetOperation()) 
Local aArea    := GetArea() 
Local aAreaCY0 := CY0->(GetArea())
Local aAreaCZ5 := CZ5->(GetArea())

If nOpc == 3 .Or. nOpc == 4
	if SFCIntegra() == 0 .AND.  oModel:GetValue('CYOMASTER','CYO_LGRFMP') == .F.
		oModel:SetValue('CYOMASTER','CYO_LGRFMP',.T.)
	Else
		If oModel:GetValue('CYOMASTER','CYO_LGRT') == .F. .AND. oModel:GetValue('CYOMASTER','CYO_LGRFMP') == .F.
			SFCMsgErro(STR0011, "SFCA003")  // 'É necessário marcar Refugo Material ou Retrabalho'
			lRet := .F.
		EndIf
	Endif
Else
	dbSelectArea('CY0')
	CY0->(dbSetOrder(2))
	IF CY0->(dbSeek(xFilial('CY0')+oModel:GetValue('CYOMASTER','CYO_CDRF')))
		SFCMsgErro(STR0012 + ALLTRIM(CY0->CY0_NRSQRP), "SFCA003") //"Registro está sendo usado no Apontamento de Produção "###"SFCA003"
    	lRet := .F.
	Endif
	
	dbSelectArea('CZ5')
	CZ5->(dbSetOrder(2))
	IF CZ5->(dbSeek(xFilial('CZ5')+oModel:GetValue('CYOMASTER','CYO_CDRF')))
		SFCMsgErro(STR0013, "SFCA003") //"Registro está sendo usado nos Indicadores da Produção"###"SFCA003"
    	lRet := .F.
	Endif
EndIf

RestArea(aAreaCZ5)
RestArea(aAreaCY0)
RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
Function UPDMotiRef()
Local lRet := .T.
Local aTabGen
Local nI

aTabGen := FWGetSX5('43')

dbSelectArea('CYO')
If CYO->(FieldPos("CYO_LGRFMP")) > 0

	if SFCIntegra() == 1

		For nI := 1 to Len(aTabGen)

			dbSelectArea('CYO')
			CYO->(dbSetOrder(1))
			IF !CYO->(dbSeek(xFilial('CYO')+aTabGen[nI][3]))
				RecLock('CYO',.T.)
				
				CYO->CYO_FILIAL := xFilial('CYO')
				CYO->CYO_CDRF   := aTabGen[nI][3]
				CYO->CYO_DSRF   := aTabGen[nI][4]
				CYO->CYO_LGRFMP := .T.
				
				CYO->(MsUnLock())
			Endif
		Next
	Else
		dbSelectArea('CYO')
		CYO->(dbSetOrder(1))
		IF !CYO->(dbSeek(xFilial('CYO')))
		
			For nI := 1 to Len(aTabGen)

				RecLock('CYO',.T.)
				
				CYO->CYO_FILIAL := xFilial('CYO')
				CYO->CYO_CDRF   := aTabGen[nI][3]
				CYO->CYO_DSRF   := aTabGen[nI][4]
				CYO->CYO_LGRFMP := .T.
				
				CYO->(MsUnLock())
			Next
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
Local aArea    := GetArea() 
Local aAreaCYO := CYO->(GetArea())
         
If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE  

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA003: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))
 
	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA003 Recebendo Mensagem Business' )
            
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
			oModel := FWLoadModel( 'SFCA003' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYO')
			CYO->(dbSetOrder(1))
			lFound := CYO->(dbSeek(xFilial('CYO')+ PadR(oBusinessContent:_Code:TEXT, Len(CYO_CDRF)) ))
			
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
					lAssign := oModel:SetValue('CYOMASTER', 'CYO_CDRF', oBusinessContent:_Code:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				lAssign := oModel:SetValue('CYOMASTER', 'CYO_DSRF', oBusinessContent:_Description:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYOMASTER', 'CYO_LGRFMP', SFCXStoX(oBusinessContent:_IsScrapMaterial:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYOMASTER', 'CYO_LGRT', SFCXStoX(oBusinessContent:_IsRework:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
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
            //conout( '+ IntegDef SFCA003 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA003 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
	// Chamada é para envio, solicitada pelo MODEL      
	ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA003 Enviando Mensagem' )

      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet := FWEAIBusEvent( "WasteReason", oModel:GetOperation(), { { "Code", oModel:GetValue('CYOMASTER', "CYO_CDRF") } }  )         
      
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          
                                                                                                               
		cXMLRet += '<Code>' 					  	 	+ oModel:GetValue('CYOMASTER', 'CYO_CDRF') 					+ '</Code>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<Description>'					+ oModel:GetValue('CYOMASTER', 'CYO_DSRF') 			     	+ '</Description>'
			cXMLRet += '<IsScrapMaterial>' 				+ SFCXXtoS( oModel:GetValue('CYOMASTER', 'CYO_LGRFMP') )	+ '</IsScrapMaterial>'
			cXMLRet += '<IsRework>'		 				+ SFCXXtoS( oModel:GetValue('CYOMASTER', 'CYO_LGRT') ) 		+ '</IsRework>'
        EndIf
		                
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aAreaCYO)
RestArea(aArea)
      
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }


Function INTDF_A003( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
