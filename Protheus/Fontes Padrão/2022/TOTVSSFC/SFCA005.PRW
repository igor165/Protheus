#INCLUDE "SFCA005.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA005  
Tela de cadastro de Item Controle

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA005()
Local oBrowse as Object

Default lAutomacao := .F.

SFCValInt() // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYK')
oBrowse:SetDescription( STR0001 )  // 'Cadastro de Item Controle'

IF !lAutomacao
	oBrowse:Activate()
ENDIF

Return Nil
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0   // 'Pesquisar' 
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA005' OPERATION 2 ACCESS 0   // 'Visualizar'
If SFCIntegra() == 1
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA005' OPERATION 3 ACCESS 0   // 'Incluir'    
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA005' OPERATION 4 ACCESS 0   // 'Alterar'   
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA005' OPERATION 5 ACCESS 0   // 'Excluir'    
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA005' OPERATION 9 ACCESS 0   // 'Copiar'    
Endif

ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA005' OPERATION 8 ACCESS 0   // 'Imprimir'  

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYK := FWFormStruct( 1, 'CYK', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA005', /*bPreValidacao*/, { |oMdl| SFCA005POS(oMdl) } /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYKMASTER', /*cOwner*/, oStructCYK, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados de Item Controle'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYKMASTER' ):SetDescription( STR0010 )   //'Dados de Dados de Item Controle'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA005' )

// Cria a estrutura a ser usada na View
Local oStructCYK := FWFormStruct( 2, 'CYK' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYK', oStructCYK, 'CYKMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYK', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA005POS 
Rotina para Validar se o Tipo Resulta é tabela.

@param  oModel        Objeto do model principal
@author Ana Carolina Tome Klock
@since  23/12/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA005POS(oModel)
Local lRet      := .T.
Local nOpc      := (oModel:GetOperation()) 
Local aArea     := GetArea()    
Local aAreaCYT  := CYT->(GetArea())

Default lAutomacao := .F.

If nOpc == 3 .Or. nOpc == 4
	If FwFldGet('CYK_TPRS') != '2'
 		FwFldPut('CYK_CDTB','')
 	Else
 		if Empty(oModel:GetValue('CYKMASTER','CYK_CDTB'))
 			SFCMsgErro("Deve ser informado uma tabela de resultado para item controle de tipo 'Tabela'", 'SFCA005') // Deve ser informado uma tabela de resultado para item controle de tipo 'Tabela'
			lRet := .F.
 		Endif 
 	endIf
Else
	dbSelectArea('CYT')
	CYT->(dbSetOrder(2))
	IF CYT->(dbSeek(xFilial('CYT')+oModel:GetValue('CYKMASTER','CYK_CDVF'))) .Or. lAutomacao
		SFCMsgErro(STR0011, 'SFCA005') //"Registro está sendo usado no Apontamento de Item Controle "
    	lRet := .F.
	Endif		
endIf

RestArea(aAreaCYT)
RestArea(aArea)

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
Local aAreaCYK := CYK->(GetArea())

Default lAutomacao := .F.

IF !lAutomacao  
	If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
		//ConOut('Envio a partir do programa de carga, ignorando...')
		Return { .T., 'Envio ignorado.' }
	EndIf
ENDIF

// Se mensagem for de Recebimento
If IIF(!lAutomacao, nTypeTrans == TRANS_RECEIVE, .F. )
	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA005: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA005 Recebendo Mensagem Business' )
            
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
			oModel := FWLoadModel( 'SFCA005' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYK')
			CYK->(dbSetOrder(1))
			lFound := CYK->(dbSeek(xFilial('CYK')+oBusinessContent:_Code:TEXT))
			
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
					lAssign := oModel:SetValue('CYKMASTER', 'CYK_CDVF', oBusinessContent:_Code:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYKMASTER', 'CYK_TPRS'  , oBusinessContent:_ResultType:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf                                                                     
				
				lAssign := oModel:SetValue('CYKMASTER', 'CYK_DSVF'  , oBusinessContent:_Description:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				
				If XmlChildEx(oBusinessContent, "_ABBREVIATIONVALUE") != NIL 				       
					lAssign := oModel:SetValue('CYKMASTER', 'CYK_VLSI'  , oBusinessContent:_AbbreviationValue:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				 
				If XmlChildEx(oBusinessContent, "_FORMATVALUE") != NIL 				       
					lAssign := oModel:SetValue('CYKMASTER', 'CYK_VLFM'	 , oBusinessContent:_FormatValue:TEXT )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				lAssign := oModel:SetValue('CYKMASTER', 'CYK_LGMQ'  , SFCXStoX(oBusinessContent:_IsMachine:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYKMASTER', 'CYK_LGAC'  , SFCXStoX(oBusinessContent:_IsItem:TEXT, 'L') )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYKMASTER', 'CYK_LGPE'	 , SFCXStoX(oBusinessContent:_IsProcess:TEXT, 'L') )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_PRODUCTIONRESULTSTABLECODE") != NIL .And. oBusinessContent:_ProductionResultsTableCode:TEXT <> '0'
					lAssign := oModel:SetValue('CYKMASTER', 'CYK_CDTB'  , oBusinessContent:_ProductionResultsTableCode:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYKMASTER', 'CYK_DSTB'  , oBusinessContent:_ProductionResultsTableDescription:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
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
            //conout( '+ IntegDef SFCA005 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA005 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf IIF(!lAutomacao, nTypeTrans == TRANS_SEND, .T.)
      //conout( '+ IntegDef SFCA005 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "ControlItem",oModel:GetOperation(), { { "Code", oModel:GetValue("CYKMASTER", "CYK_CDVF") } }  )          

      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          
                                                                                                               
		cXMLRet += '<Code>' 					  	 	+ oModel:GetValue("CYKMASTER", 'CYK_CDVF') 					+ '</Code>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<Description>'					+ oModel:GetValue("CYKMASTER", 'CYK_DSVF') 			     	+ '</Description>'
			cXMLRet += '<ResultType>' 					+ oModel:GetValue("CYKMASTER", 'CYK_TPRS') 					+ '</ResultType>'
			cXMLRet += '<AbbreviationValue>'			+ oModel:GetValue("CYKMASTER", 'CYK_VLSI') 	   				+ '</AbbreviationValue>'   
			cXMLRet += '<FormatValue>'		 			+ oModel:GetValue("CYKMASTER", 'CYK_VLFM')     				+ '</FormatValue>'
			cXMLRet += '<IsMachine>'		 			+ SFCXXtoS( oModel:GetValue("CYKMASTER", 'CYK_LGMQ') ) 		+ '</IsMachine>'
			cXMLRet += '<IsItem>'				  		+ SFCXXtoS( oModel:GetValue("CYKMASTER", 'CYK_LGAC') )     	+ '</IsItem>'
			cXMLRet += '<IsProcess>' 					+ SFCXXtoS( oModel:GetValue("CYKMASTER", 'CYK_LGPE') )		+ '</IsProcess>'
			cXMLRet += '<ProductionResultsTableCode>'		 		   		+ oModel:GetValue("CYKMASTER", 'CYK_CDTB')     				+ '</ProductionResultsTableCode>'
			cXMLRet += '<ProductionResultsTableDescription>' 				+ oModel:GetValue("CYKMASTER", 'CYK_DSTB') 	   				+ '</ProductionResultsTableDescription>'   
        EndIf
		                
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aAreaCYK)
RestArea(aArea)
                        
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }

Function INTDF_A005( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
