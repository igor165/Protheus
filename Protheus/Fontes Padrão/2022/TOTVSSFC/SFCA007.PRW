#INCLUDE "SFCA007.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "XMLXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA007  
Tela de cadastro de Área de Produção

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA007()
Local oBrowse as object

Default lAutomacao := .F.

SFCValInt() // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYA')
oBrowse:SetDescription( STR0001 )   // 'Cadastro de Área de Produção'

IF !lAutomacao
	oBrowse:Activate()
ENDIF

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'  
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA007' OPERATION 2 ACCESS 0  // 'Visualizar' 
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA007' OPERATION 3 ACCESS 0  // 'Incluir'    
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA007' OPERATION 4 ACCESS 0  // 'Alterar'    
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA007' OPERATION 5 ACCESS 0  // 'Excluir'    
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA007' OPERATION 8 ACCESS 0  // 'Imprimir'   
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA007' OPERATION 9 ACCESS 0  // 'Copiar'     

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYA := FWFormStruct( 1, 'CYA', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA007', /*bPreValidacao*/, { |oMdl| SFCA007POS(oMdl) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYAMASTER', /*cOwner*/, oStructCYA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados de Área de Produção'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYAMASTER' ):SetDescription( STR0010 )   //'Dados de Dados de Área de Produção'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'SFCA007' )
Local oStructCYA := FWFormStruct( 2, 'CYA' )

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_CYA', oStructCYA, 'CYAMASTER' )

oView:CreateHorizontalBox( 'TELA' , 100 )

oView:SetOwnerView( 'VIEW_CYA', 'TELA' )

// No datasul, o campo de área tem tamanho 8
If SFCIntegra() == 2
	oModel:GetModel( 'CYAMASTER' ):GetStruct():SetProperty( 'CYA_CDARPO', MODEL_FIELD_TAMANHO, 8 )
Endif

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA007POS 

@param  oModel        Objeto do model principal
@author Samantha Preima
@since  04/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA007POS(oModel)      
Local lRet      := .T.     
Local nOpc      := (oModel:GetOperation()) 
Local aArea     := GetArea() 
Local aAreaCYI  := CYI->(GetArea())
Local aAreaCYH  := CYH->(GetArea())
Local aAreaCZ7  := CZ7->(GetArea())
Local aAreaCZ4  := CZ4->(GetArea())

Default lAutomacao := .F.

if nOpc == 5
	dbSelectArea('CYI')
	CYI->(dbSetOrder(2))
	IF CYI->(dbSeek(xFilial('CYI')+oModel:GetValue('CYAMASTER','CYA_CDARPO')))
		SFCMsgErro(STR0011 + ALLTRIM(CYI->CYI_CDCETR), 'SFCA007') //"Registro está sendo usado no Centro de Trabalho "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYH')
	CYH->(dbSetOrder(4))
	IF CYH->(dbSeek(xFilial('CYH')+oModel:GetValue('CYAMASTER','CYA_CDARPO')))
		SFCMsgErro(STR0012 + ALLTRIM(CYH->CYH_IDRC), 'SFCA007') //"Registro está sendo usado no Recurso "
    	lRet := .F.
	Endif
	
	dbSelectArea('CZ7')
	CZ7->(dbSetOrder(3))
	IF CZ7->(dbSeek(xFilial('CZ7')+oModel:GetValue('CYAMASTER','CYA_CDARPO'))) .Or. lAutomacao
		SFCMsgErro(STR0013 + ALLTRIM(CZ7->CZ7_IDSPTT), 'SFCA007') //"Registro está sendo usado no Apontamento de Parada Geral "
    	lRet := .F.
	Endif
	
	dbSelectArea('CZ4')
	CZ4->(dbSetOrder(4))
	IF CZ4->(dbSeek(xFilial('CZ4')+oModel:GetValue('CYAMASTER','CYA_CDARPO'))) .Or. lAutomacao
		SFCMsgErro(STR0014, 'SFCA007') //"Registro está sendo usado nos Indicadores de Fábrica"
    	lRet := .F.
	Endif	
Endif

RestArea(aArea)
RestArea(aAreaCYI)
RestArea(aAreaCZ4)
RestArea(aAreaCYH)
RestArea(aAreaCZ7)

Return lRet
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet             := .T.
Local lFound 
Local cXMLRet          := ""    
Local oXML             as Object
Local oBusinessContent as Object
Local oBusinessEvent   as Object
Local nOpc             := 3
Local oModel           as Object
Local aArea            := GetArea() 
Local aAreaCYA         := CYA->(GetArea())

Default lAutomacao     := .F.

IF !lAutomacao                
	If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
		//ConOut('Envio a partir do programa de carga, ignorando...')
		Return { .T., 'Envio ignorado.' }
	EndIf
ENDIF

// Se mensagem for de Recebimento
If IIF(!lAutomacao, nTypeTrans == TRANS_RECEIVE, .F.)         
	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA007: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA007 Recebendo Mensagem Business' )
            
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
			oModel := FWLoadModel( 'SFCA007' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYA')
			CYA->(dbSetOrder(1))
			lFound := CYA->(dbSeek(xFilial('CYA')+oBusinessContent:_Code:TEXT))
			
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
					lAssign := oModel:SetValue('CYAMASTER', 'CYA_CDARPO', oBusinessContent:_Code:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				lAssign := oModel:SetValue('CYAMASTER', 'CYA_DSARPO', oBusinessContent:_Description:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYAMASTER', 'CYA_CDTN', oBusinessContent:_ProductionShiftCode:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYAMASTER', 'CYA_DSTN', oBusinessContent:_ProductionShiftDescription:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYAMASTER', 'CYA_CDCL', oBusinessContent:_CalendarCode:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYAMASTER', 'CYA_DSCL', oBusinessContent:_CalendarDescription:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYAMASTER', 'CYA_CDES', oBusinessContent:_SiteCode:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_RESPONSIBLECODE") != NIL
					lAssign := oModel:SetValue('CYAMASTER', 'CYA_CDUS', oBusinessContent:_ResponsibleCode:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
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
            //conout( '+ IntegDef SFCA007 Recebendo Mensagem Response' )
            cXMLRet := 'Integracao (Response) efetuada com sucesso'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA007 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf IIF(!lAutomacao, nTypeTrans == TRANS_SEND, .T.)  
      //conout( '+ IntegDef SFCA007 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "ProductionArea",oModel:GetOperation(), { { "Code", oModel:GetValue("CYAMASTER", "CYA_CDARPO") } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          
		cXMLRet += '<Code>' 		+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_CDARPO')) 		+ '</Code>'
		cXMLRet += '<Description>' 	+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_DSARPO')) 		+ '</Description>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<ProductionShiftCode>' 			+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_CDTN')) 		+ '</ProductionShiftCode>'
			cXMLRet += '<ProductionShiftDescription>' 	+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_CDTN')) 		+ '</ProductionShiftDescription>'
			cXMLRet += '<CalendarCode>' 	   			+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_CDCL')) 		+ '</CalendarCode>'
		   	cXMLRet += '<CalendarDescription>' 			+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_DSCL')) 		+ '</CalendarDescription>'
			cXMLRet += '<SiteCode>' 		   			+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_CDES')) 		+ '</SiteCode>'
			cXMLRet += '<ResponsibleCode>' 	   			+ SFCXXtoS(oModel:GetValue("CYAMASTER", 'CYA_CDUS')) 		+ '</ResponsibleCode>'
	    EndIf 
	    		
      cXMLRet += '</BusinessContent>' 
      
EndIf
                         
RestArea(aArea)
RestArea(aAreaCYA)


//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }


Function INTDF_A007( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
