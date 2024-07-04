#INCLUDE 'SFCA021.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA021
Tela de cadastro de Grupo Estoque

@author André Luis Oliveira Pereira
@since 01/02/2012
@version P12

/*/
//-------------------------------------------------------------------
Function SFCA021()
Local oBrowse
                     
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CY7')
oBrowse:SetDescription( STR0001 ) // 'Grupo Estoque'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA021' OPERATION 2 ACCESS 0  // 'Visualizar'
//ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA021' OPERATION 3 ACCESS 0  // 'Incluir'
//ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA021' OPERATION 4 ACCESS 0  // 'Alterar'
//ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA021' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA021' OPERATION 8 ACCESS 0  // 'Imprimir'
//ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA021' OPERATION 9 ACCESS 0  // 'Copiar'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCY7 := FWFormStruct( 1, 'CY7', /*bAvalCampo*/,/*lViewUsado*/ ) 
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA021', /*bPreValidacao*/,  { |oModel| SFCA021POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CY7MASTER', /*cOwner*/, oStructCY7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados do Grupo Estoque'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CY7MASTER' ):SetDescription( STR0010 )  //'Dados do Grupo Estoque'

// Altera o tamanho do campo para integrar com o produto PCP
If DPRIntegra() == 1
	oStructCY7:SetProperty( 'CY7_CDGE'  , MODEL_FIELD_TAMANHO, TamSX3('BM_GRUPO')[1]	)  
	oStructCY7:SetProperty( 'CY7_DSGE'  , MODEL_FIELD_TAMANHO, TamSX3('BM_DESC')[1] 	)  
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA021' )
// Cria a estrutura a ser usada na View
Local oStructCY7 := FWFormStruct( 2, 'CY7' )

// Cria o objeto de View
oView := FWFormView():New()
                                
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CY7', oStructCY7, 'CY7MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )                                        

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CY7', 'TELA' ) 

Return oView 

//-------------------------------------------------------------------
Static Function SFCA021POS( oModel )
Local lRet := .T.

If !IsInCallStack('A035IntDPR')
	lRet := AUTO035( oModel )
EndIf

Return lRet

//-------------------------------------------------------------------
Function AUTO035( oModel )
Local aArea   	:= GetArea()
Local lRet    	:= .T.		
Local aCampos 	:= {}			
Local aAux    	:= {}		
Local nI	  		:= 0			
Local nOpc  		:= oModel:GetOperation()
Local oModelSBM  

// Verifica se o registro incluso existe e altera
dbSelectArea( 'SBM' )
If dbSeek( xFilial('SBM') + oModel:GetValue('CY7MASTER', 'CY7_CDGE') ) .And. nOpc == 3
	nOpc := 4
EndIf

// Define os campos a serem carregados
If nOpc == 3
	aAdd( aCampos, { 'BM_GRUPO', oModel:GetValue('CY7MASTER', 'CY7_CDGE'), Nil } )
EndIf
If nOpc # 5
	aAdd( aCampos, { 'BM_DESC' , AllTrim( oModel:GetValue('CY7MASTER', 'CY7_DSGE') ), Nil } )
EndIf

// Carrega o modelo
oModelSBM := FwLoadModel( 'MATA035' )
oModelSBM:SetOperation(nOpc)
oModelSBM:Activate()

// Carrega valores nos campos
aAux := oModelSBM:GetModel('MATA035_SBM'):GetStruct():GetFields()
For nI := 1 To Len(aCampos)
	If aScan(aAux, { |x| AllTrim(x[3]) ==  AllTrim(aCampos[nI,1]) } )  > 0
		If !( oModelSBM:SetValue("MATA035_SBM", aCampos[nI,1], aCampos[nI,2]) )
			lRet := .F.
			Exit       
		EndIf
	EndIf
Next

// Valida modelo
If lRet .And. oModelSBM:VldData()
	lRet := oModelSBM:CommitData()
Else
	aErro := oModelSBM:GetErrorMessage()
	DPRXError('MATA035', INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")' )           
EndIf

// Desativa o modelo
oModelSBM:DeActivate()
RestArea(aArea)

Return lRet         

//-------------------------------------------------------------------
/*Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet      := .T.
Local lFound 
Local cXMLRet   := ''    
Local oXML, oModel
Local oBusinessContent
Local oBusinessEvent
Local nOpc      := 3 
Local cCDGE     := ''

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
        
        cCDGE := UPPER(ALTRIM(oBusinessContent:_Code:TEXT))
        
        // Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
        dbSelectArea('CY7')
        CY7->(dbSetOrder(1))
        lFound := CY7->(dbSeek(xFilial('CY7')+cCDGE))
                    
        // Instancia o modelo   
        oModel := FWLoadModel( 'SFCA021' )                      
            
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
        
        if nOpc == 3 .OR. lFound
            
	        // Set a operação e Ativa o Model
	        oModel:SetOperation(nOpc)
	        oModel:Activate()
	           
	        // Se operação for diferente de exclusão
	        If nOpc # 5
	            // Adiciona a chave apenas se for inclusão
	            If nOpc == 3
	                 lAssign := oModel:SetValue('CY7MASTER', 'CY7_CDGE' , cCDGE)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
	            EndIf                                                                                                           
	        
	            lAssign := oModel:SetValue('CY7MASTER', 'CY7_DSGE' , oBusinessContent:_Description:TEXT)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
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
    cXMLRet :=  FWEAIBusEvent( 'InventoryGroup', oModel:GetOperation(), { { 'Code', oModel:GetValue('CY7MASTER', 'CY7_CDGE') } }  )         
       
    // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
    cXMLRet += '<BusinessContent>'
      
    cXMLRet += '<Code>'	+ INTEGXTOS(oModel:GetValue('CY7MASTER', 'CY7_CDGE')) + '</Code>'
        
    // Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
    If oModel:GetOperation() # 5   
        cXMLRet += '<Description>' + INTEGXTOS(oModel:GetValue('CY7MASTER', 'CY7_DSGE'  )) + '</Description>'
    EndIf   
    
    cXMLRet += '</BusinessContent>'   
EndIf*/