#INCLUDE 'SFCA022.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA022
Tela de cadastro de Depósito

@author André Luis Oliveira Pereira
@since 01/02/2012
@version P12

/*/
//-------------------------------------------------------------------
Function SFCA022()
Local oBrowse
                     
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CZX')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Depósito'
If DPRIntegra() == 1
	oBrowse:SetOnlyFields( { 'CZX_CDDP', 'CZX_DSDP', 'CZX_TPDP' } )  
EndIf
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA022' OPERATION 2 ACCESS 0  // 'Visualizar'
//ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA022' OPERATION 3 ACCESS 0  // 'Incluir'
//ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA022' OPERATION 4 ACCESS 0  // 'Alterar'
//ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA022' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA022' OPERATION 8 ACCESS 0  // 'Imprimir'
//ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA022' OPERATION 9 ACCESS 0  // 'Copiar'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCZX := FWFormStruct( 1, 'CZX', /*bAvalCampo*/,/*lViewUsado*/ ) 
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA022', /*bPreValidacao*/,  { | oModel | SFCA022POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CZXMASTER', /*cOwner*/, oStructCZX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados do Depósito'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CZXMASTER' ):SetDescription( STR0010 )  //'Dados do Depósito'

// Altera o tamanho do campo para integrar com o produto PCP
If DPRIntegra() == 1
	oStructCZX:SetProperty( 'CZX_CDDP'  , MODEL_FIELD_TAMANHO, TamSX3('NNR_CODIGO')[1] )  
	oStructCZX:SetProperty( 'CZX_DSDP'  , MODEL_FIELD_TAMANHO, TamSX3('NNR_DESCRI')[1] )  
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA022' )
// Cria a estrutura a ser usada na View
Local oStructCZX := FWFormStruct( 2, 'CZX' )

// Cria o objeto de View
oView := FWFormView():New()
                                
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CZX', oStructCZX, 'CZXMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )                                        

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CZX', 'TELA' ) 

// Remove campos desnecessários da integração
If DPRIntegra() == 1
	oStructCZX:RemoveField( 'CZX_LGSDDI' )       
	oStructCZX:RemoveField( 'CZX_LGAC'   )
	oStructCZX:RemoveField( 'CZX_LGPE'   )
	oStructCZX:RemoveField( 'CZX_LGCQ'   )
	oStructCZX:RemoveField( 'CZX_LGRF'   )
	oStructCZX:RemoveField( 'CZX_LGRT'   )
EndIf

Return oView 

//-------------------------------------------------------------------
Static Function SFCA022POS( oModel )
Local lRet := .T.

If !IsInCallStack('A045IntSFC') .And. !IsInCallStack('AGRA045') .And. !IsInCallStack('CARGASFC')
	lRet := AUTO045( oModel )
EndIf

Return lRet

//-------------------------------------------------------------------
Static Function AUTO045( oModel )
Local aArea   	:= GetArea()
Local lRet    	:= .T.		
Local aCampos 	:= {}			
Local aAux    	:= {}		
Local nI	  	:= 0			
Local nOpc  	:= oModel:GetOperation()
Local oModelNNR  

// Verifica se o registro incluso existe e altera
dbSelectArea( 'NNR' )
If dbSeek( xFilial('NNR') + oModel:GetValue('CZXMASTER', 'CZX_CDDP') ) .And. nOpc == 3
	nOpc := 4
EndIf

// Define os campos a serem carregados
If nOpc == 3
	aAdd( aCampos, { 'NNR_CODIGO', AllTrim( oModel:GetValue('CZXMASTER', 'CZX_CDDP') ), Nil }  )
EndIf
If nOpc # 5
	aAdd( aCampos, { 'NNR_DESCRI', AllTrim( oModel:GetValue('CZXMASTER', 'CZX_DSDP') ), Nil } )
EndIf

// Carrega o modelo
oModelNNR := FwLoadModel( 'AGRA045' )
oModelNNR:SetOperation(nOpc)
oModelNNR:Activate()

// Carrega valores nos campos
aAux := oModelNNR:GetModel('NNRMASTER'):GetStruct():GetFields()
For nI := 1 To Len(aCampos)
	If aScan(aAux, { |x| AllTrim(x[3]) ==  AllTrim(aCampos[nI,1]) } )  > 0
		If !( oModelNNR:SetValue("NNRMASTER", aCampos[nI,1], aCampos[nI,2]) )
			lRet := .F.
			Exit       
		EndIf
	EndIf
Next

// Valida modelo
If lRet .And. oModelNNR:VldData()
	lRet := oModelNNR:CommitData()
Else
	aErro := oModelNNR:GetErrorMessage()
	DPRXError('AGRA045', INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")' )            
EndIf

// Desativa o modelo
oModelNNR:DeActivate()
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
Local aArea     := GetArea()
Local cCDDP     := ''

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
		
		cCDDP := UPPER(ALLTRIM(oBusinessContent:_Code:TEXT))
		
		// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
        dbSelectArea('CZX')
        CZX->(dbSetOrder(1))
        lFound := CZX->(dbSeek(xFilial('CZX')+cCDDP))
                    
        // Instancia o modelo   
        oModel := FWLoadModel( 'SFCA022' )
                    
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
					 lAssign := oModel:SetValue('CZXMASTER', 'CZX_CDDP' , cCDDP)            ;If !lAssign; Return INTEGERROR( oModel ); EndIf
				EndIf                                                                                                           
			
				lAssign := oModel:SetValue('CZXMASTER', 'CZX_DSDP' , oBusinessContent:_Description:TEXT)            ;If !lAssign; Return INTEGERROR( oModel ); EndIf
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
    cXMLRet :=  FWEAIBusEvent( 'Warehouse', oModel:GetOperation(), { { 'Code', oModel:GetValue('CZXMASTER', 'CZX_CDDP') } }  )         
       
    // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
    cXMLRet += '<BusinessContent>'          
      
    cXMLRet += '<Code>'	+ INTEGXTOS(oModel:GetValue('CZXMASTER', 'CZX_CDDP'))   + '</Code>'
        
    // Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
    If oModel:GetOperation() # 5   
        cXMLRet += '<Description>'      + INTEGXTOS(oModel:GetValue('CZXMASTER', 'CZX_DSDP'  ))     + '</Description>'
    EndIf   
    
    cXMLRet += '</BusinessContent>'   
EndIf

RestArea(aArea)

Return { lRet, cXMLRet } 
*/