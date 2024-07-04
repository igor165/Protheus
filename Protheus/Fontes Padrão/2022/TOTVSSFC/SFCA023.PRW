#INCLUDE 'SFCA023.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA023
Tela de cadastro de Unidade de Medida

@author André Luis Oliveira Pereira
@since 01/02/2012
@version P12

/*/
//-------------------------------------------------------------------
Function SFCA023()
Local oBrowse
                     
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CZ9')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Unidade Medida'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA023' OPERATION 2 ACCESS 0  // 'Visualizar'
//ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA023' OPERATION 3 ACCESS 0  // 'Incluir'
//ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA023' OPERATION 4 ACCESS 0  // 'Alterar'
//ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA023' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA023' OPERATION 8 ACCESS 0  // 'Imprimir'
//ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA023' OPERATION 9 ACCESS 0  // 'Copiar'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCZ9 := FWFormStruct( 1, 'CZ9', /*bAvalCampo*/,/*lViewUsado*/ ) 
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA023', /*bPreValidacao*/, { |oModel| SFCA023POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CZ9MASTER', /*cOwner*/, oStructCZ9, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados da Unidade Medida'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CZ9MASTER' ):SetDescription( STR0010 )  //'Dados da Unidade Medida'

// Altera o tamanho do campo para integrar com o produto PCP
If DPRIntegra() == 1
	oStructCZ9:SetProperty( 'CZ9_CDUN'  , MODEL_FIELD_TAMANHO, TamSX3('AH_UNIMED')[1] )  
	oStructCZ9:SetProperty( 'CZ9_DSUN'  , MODEL_FIELD_TAMANHO, TamSX3('AH_UMRES')[1]  )  
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA023' )
// Cria a estrutura admina ser usada na View
Local oStructCZ9 := FWFormStruct( 2, 'CZ9' )

// Cria o objeto de View
oView := FWFormView():New()
                                
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CZ9', oStructCZ9, 'CZ9MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )                                        

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CZ9', 'TELA' ) 

Return oView                                                         

//-------------------------------------------------------------------
Static Function SFCA023POS( oModel )
Local lRet := .T.

If !IsInCallStack('Q30IntSFC')
	lRet := AUTO045( oModel )
EndIf

Return lRet

//-------------------------------------------------------------------
Static Function AUTO045( oModel )
Local aDadosAuto		:= {}			
Local lHelpDark  		:= HelpInDark(.F.)
Local lHelp      		:= HelpLog(.T.) 
Local lRet			 	:= .T.    
Private lMsHelpAuto 	:= .T. 		
Private lMsErroAuto 	:= .F.

aAdd( aDadosAuto, { 'AH_UNIMED', AllTrim(oModel:GetValue('CZ9MASTER', 'CZ9_CDUN')), Nil } )
aAdd( aDadosAuto, { 'AH_UMRES' , AllTrim(oModel:GetValue('CZ9MASTER', 'CZ9_DSUN')), Nil } )
aAdd( aDadosAuto, { 'AH_DESCPO', AllTrim(oModel:GetValue('CZ9MASTER', 'CZ9_DSUN')), Nil } )
aAdd( aDadosAuto, { 'AH_DESCIN', AllTrim(oModel:GetValue('CZ9MASTER', 'CZ9_DSUN')), Nil } )
aAdd( aDadosAuto, { 'AH_DESCES', AllTrim(oModel:GetValue('CZ9MASTER', 'CZ9_DSUN')), Nil } )

// Executa a rotina MATA010 - Produtos PCP	
MSExecAuto( { |x,y| QIEA030(x,y) }, aDadosAuto, oModel:GetOperation() )

// Caso encontre erro na execução
If lMsErroAuto
	lRet := .F.
	If !IsTelNet()
		MostraErro()
	Else
		ErroTelnet()
	EndIf
EndIf
	
HelpInDark(lHelpDark)
HelpLog(lHelp)        

Return lRet      

//-------------------------------------------------------------------
/*Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet    	:= .T.
Local lFound 
Local cXMLRet  	:= ''    
Local oXML, oModel
Local oBusinessContent
Local oBusinessEvent
Local nOpc		:= 3 
Local aArea    	:= GetArea()
Local cCDUN     := ''

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE     
       
	//  Se mensagem for de Negócio	
    If cTypeMessage == EAI_MESSAGE_BUSINESS
		cError := ''
		cWarning := '' 
		lValid := .F.
			
		// Cria um objeto XML a partir da estutura dos dados do Model
		oXML := XmlParser(FwNoAccent(cXML), '_', @cError, @cWarning) 
			                                    
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
        	Return { lValid,  STR0011 } // 'Não foi enviada uma mensagem válida'	
        EndIf
        
        cCDUN := UPPER(ALLTRIM(oBusinessContent:_Code:TEXT))
        
        // Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
		dbSelectArea('CZ9')
		CZ9->(dbSetOrder(1))
		lFound := CZ9->(dbSeek(xFilial('CZ9')+cCDUN))
			        
		// Instancia o modelo	
		oModel := FWLoadModel( 'SFCA023' )	
			
		// Verifica se a mensagem é de Inclusão/Alteração
		If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
			// Se foi encontrado, envia como Alteração
			If lFound
				nOpc := 4
			// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
			Else 
				nOpc := 3						
			EndIf
		Else  
			// Apaga o registro  
			nOpc := 5						
		EndIf
		
		IF nOpc == 3 .OR. lFound
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
	           
	        // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('CZ9MASTER', 'CZ9_CDUN', cCDUN)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				EndIf                                                                                                          	
			
				lAssign := oModel:SetValue('CZ9MASTER', 'CZ9_DSUN' , oBusinessContent:_Description:TEXT)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
			EndIf
	            
	        // Validação no Model    
			If oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()    
					
				// Retorna OK
				cXMLRet := STR0012 + IF(nOpc == 3, STR0013, IF(nOpc == 4, STR0014, STR0015)) + STR0016  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
				lRet := .F.
			EndIf
	
			// Desativa o Model
			oModel:DeActivate()
		Endif
	// Mensagem é de Response
    ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
    	cXMLRet := STR0017 // 'Resposta recebida com sucesso.'
            
    // Mensagem é de Whois
    ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
        Return {.T., '1.000'}
    EndIf

// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
  
	// Busca o Model que está Ativo no momento da chamada
    oModel := FwModelActive()

	// Cria a estrutura de TAGs BusinessEvent, já identificando se é Upsert ou Delete, e colocando as Identifications      
    cXMLRet :=  FWEAIBusEvent( 'UnitOfMeasure', oModel:GetOperation(), { { 'Code', oModel:GetValue('CZ9MASTER', 'CZ9_CDUN') } }  )         
       
    // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
    cXMLRet += '<BusinessContent>'          
      
	cXMLRet += '<Code>'		  		+ INTEGXTOS(oModel:GetValue('CZ9MASTER', 'CZ9_CDUN')) 	+ '</Code>'
		
	// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
	If oModel:GetOperation() # 5   
		cXMLRet += '<Description>' 		+ INTEGXTOS(oModel:GetValue('CZ9MASTER', 'CZ9_DSUN'  ))	 	+ '</Description>'
  	EndIf	
    
    cXMLRet += '</BusinessContent>'   
EndIf

RestArea(aArea)

Return { lRet, cXMLRet }    */
