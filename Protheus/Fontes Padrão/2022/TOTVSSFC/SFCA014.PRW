#INCLUDE "SFCA014.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA014
Tela de cadastro de Tabela Resultado

@author Tiago Gauziski
@since 24/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA014()
Local oBrowse

SFCValInt() // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CY1')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Tabela Resultado'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA014' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA014' OPERATION 3 ACCESS 0    // 'Incluir'    
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA014' OPERATION 4 ACCESS 0    // 'Alterar'   
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA014' OPERATION 5 ACCESS 0    // 'Excluir'    
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA014' OPERATION 8 ACCESS 0    // 'Imprimir'   
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA014' OPERATION 9 ACCESS 0    // 'Copiar'     

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCY1 := FWFormStruct( 1, 'CY1', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStructCY2 := FWFormStruct( 1, 'CY2', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA014', /*bPreValidacao*/, { |oMdl| SFCA014POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CY1MASTER', /*cOwner*/, oStructCY1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CY2DETAIL', 'CY1MASTER', oStructCY2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CY2DETAIL', { { 'CY2_FILIAL', 'xFilial( "CY2" )' }, { 'CY2_CDTB', 'CY1_CDTB' } }, CY2->(IndexKey(1)) )  

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CY2DETAIL' ):SetUniqueLine( { 'CY2_NRSQ' } )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CY2DETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados de Tabela Resultado'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CY1MASTER' ):SetDescription( STR0010 ) //'Dados de Dados de Tabela Resultado'
oModel:GetModel( 'CY2DETAIL' ):SetDescription( STR0011 )   //'Dados do Componente da Tabela Resultado'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA014' )
// Cria a estrutura a ser usada na View
Local oStructCY1 := FWFormStruct( 2, 'CY1' )
Local oStructCY2 := FWFormStruct( 2, 'CY2' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CY1', oStructCY1, 'CY1MASTER' )    

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CY2', oStructCY2, 'CY2DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 18 )
oView:CreateHorizontalBox( 'INFERIOR', 82 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CY1', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CY2', 'INFERIOR' )       

//Remove o campo repetido em tela
oStructCY2:RemoveField("CY2_CDTB") 

//Adiciona auto incremento
oView:AddIncrementField("VIEW_CY2","CY2_NRSQ")
  
//Define mascara numerica para o campo chave
oView:GetViewStruct('VIEW_CY1'):SetProperty('CY1_CDTB'  , 7, "@E 99999")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA014POS 

@param   oModel        Objeto do model principal
@author Samantha Preima
@since 04/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA014POS (oModel)
Local lRet 	   := .T.
Local nOpc     := (oModel:GetOperation())  
Local aArea    := GetArea()
Local aAreaCYK := CYK->(GetArea())

if nOpc == 5
	dbSelectArea('CYK')
	CYK->(dbSetOrder(2))
	IF CYK->(dbSeek(xFilial('CYK')+oModel:GetValue('CY1MASTER','CY1_CDTB')))
		SFCMsgErro(STR0012 + ALLTRIM(CYK->CYK_CDVF), 'SFCA014') //"Registro está sendo usado no Item Controle "
    	lRet := .F.
	Endif
Endif

RestArea(aAreaCYK)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oComponentContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local oModelCY2
Local nI
Local aComponents := {}
Local aArea    := GetArea()
Local aAreaCY1 := CY1->(GetArea())

If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf


// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA014: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA014 Recebendo Mensagem Business' )
            
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
			oModel := FWLoadModel( 'SFCA014' )
			oModelCY2 := oModel:GetModel('CY2DETAIL')
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CY1')
			CY1->(dbSetOrder(1))
			lFound := CY1->(dbSeek(xFilial('CY1')+ oBusinessContent:_Code:TEXT))
			
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
					lAssign := oModel:SetValue('CY1MASTER', 'CY1_CDTB', SFCXXtoS(oBusinessContent:_Code:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CY1MASTER', 'CY1_DSTB', SFCXXtoS(oBusinessContent:_Description:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf

				For nI := 1 To oModelCY2:Length()
		
					oModelCY2:GoLine( nI )
					
					If !oModelCY2:IsDeleted()
				       	oModelCY2:DeleteLine()
					Endif
					
				Next
	            
	            
				If XmlChildEx(oBusinessContent, "_LISTOFCOMPONENTS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfComponents) > 0
					aComponents := oBusinessContent:_ListOfComponents:_Component
					If valType(aComponents) == 'O'
					   aComponents := { aComponents }
					EndIf
	            		EndIf
				
				For nI := 1 To Len(aComponents)
					oModelCY2:AddLine()
				    
				    oComponentContent := aComponents[nI]
				    	     
					lAssign := oModelCY2:SetValue('CY2_NRSQ', SFCXXtoS(oComponentContent:_Sequence:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY2:SetValue('CY2_DSRS', SFCXXtoS(oComponentContent:_ResultDescription:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY2:SetValue('CY2_VLRS', SFCXStoX(oComponentContent:_ResultValue:TEXT, 'N'));If !lAssign; Return SFCXMKERR(oModel); EndIf
				Next				


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
            //conout( '+ IntegDef SFCA014 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA014 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA014 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()
      oModelCY2 := oModel:GetModel('CY2DETAIL')

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "ProductionResultsTable",oModel:GetOperation(), { { "Code", oModel:GetValue("CY1MASTER", 'CY1_CDTB') } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          


		cXMLRet += '<Code>' 						+ SFCXXtoS(oModel:GetValue("CY1MASTER", 'CY1_CDTB')) 		+ '</Code>'
		cXMLRet += '<Description>' 					+ SFCXXtoS(oModel:GetValue("CY1MASTER", 'CY1_DSTB')) 		+ '</Description>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<ListOfComponents>'

				For nI := 1 To oModelCY2:Length()
					oModelCY2:GoLine( nI )
				
				   	If !oModelCY2:IsDeleted()
				   		cXMLRet += '<Component>'  
							cXMLRet += '<Sequence>' 					+ SFCXXtoS(oModelCY2:GetValue('CY2_NRSQ')) 		+ '</Sequence>'
							cXMLRet += '<ResultValue>' 					+ SFCXXtoS(oModelCY2:GetValue('CY2_VLRS')) 		+ '</ResultValue>'
				   	   		cXMLRet += '<ResultDescription>' 			+ SFCXXtoS(oModelCY2:GetValue('CY2_DSRS')) 		+ '</ResultDescription>'
				   		cXMLRet += '</Component>'
				   	EndIf	      	        
				Next
			
			cXMLRet += '</ListOfComponents>'
			
        EndIf
		                
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aAreaCY1)
RestArea(aArea)
                        
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }

Function INTDF_A014( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
