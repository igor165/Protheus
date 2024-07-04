#INCLUDE 'SFCA020.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA020.
Tela de cadastro de Família

@author André Luis Oliveira Pereira
@since 01/02/2012
@version P12

/*/
//-------------------------------------------------------------------
Function SFCA020()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CY6')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Família'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA020' OPERATION 2 ACCESS 0  // 'Visualizar'
//ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA020' OPERATION 3 ACCESS 0  // 'Incluir'
//ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA020' OPERATION 4 ACCESS 0  // 'Alterar'
//ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA020' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA020' OPERATION 8 ACCESS 0  // 'Imprimir'
//ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA020' OPERATION 9 ACCESS 0  // 'Copiar'
If DPRIntegra() == 1 .Or. SFCIntegra() == 1
	ADD OPTION aRotina TITLE STR0009 ACTION 'SFCA020LOA()' OPERATION 3 ACCESS 0  	// 'Regerar'
EndIf

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCY6 := FWFormStruct( 1, 'CY6', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA020', /*bPreValidacao*/,  /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CY6MASTER', /*cOwner*/, oStructCY6, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0010 ) //'Modelo de Dados da Família'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CY6MASTER' ):SetDescription( STR0011 )  //'Dados de centro de Trabalho'

// Remove a obrigatoriedade dos campos quando estiver integrando com o PCP
If DPRIntegra() == 1 .Or. SFCIntegra() == 1
	oStructCY6:SetProperty( 'CY6_CDUN'  , MODEL_FIELD_OBRIGAT ,  .F. )
	oStructCY6:SetProperty( 'CY6_CDFA'  , MODEL_FIELD_TAMANHO , TamSX3('X5_CHAVE')[1]   )
	oStructCY6:SetProperty( 'CY6_DSFA'  , MODEL_FIELD_TAMANHO , TamSX3('X5_DESCRI')[1]  )
	oStructCY6:SetProperty( 'CY6_CDUN'  , MODEL_FIELD_TAMANHO , TamSX3('AH_UNIMED')[1]  )
	oStructCY6:SetProperty( 'CY6_CDDPPA', MODEL_FIELD_TAMANHO , TamSX3('NNR_CODIGO')[1] )
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA020' )
// Cria a estrutura a ser usada na View
Local oStructCY6 := FWFormStruct( 2, 'CY6' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CY6', oStructCY6, 'CY6MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CY6', 'TELA' )

Return oView

//-------------------------------------------------------------------
Function SFCA020LOA()
Local oModel, nI, nX, aApaga := {}
Local aDados := {}
Local cError := ''
Local cQuery

dbSelectArea( 'CY6' )
CY6->( dbGoTop() )
While CY6->( !EOF() ) .AND. CY6->CY6_FILIAL == xFilial('CY6')
	aAdd( aApaga, CY6->CY6_CDFA )
	CY6->( dbSkip() )
End

aDados := FWGetSX5("02")
For nX := 1 To Len(aDados)
	oModel := FWLoadModel( 'SFCA020' )
	dbSelectArea( 'CY6' )
	If !CY6->(dbSeek( xFilial('CY6') + AllTrim(aDados[nX,3]) ))
        oModel:SetOperation(3)
	Else
        oModel:SetOperation(4)
	EndIf

  	// Remove do array que será apagado -------
	For nI := 1 to len( aApaga )
    	If AllTrim(aApaga[nI]) == AllTrim(aDados[nX,3])
       		ADel( aApaga, nI )
       		nI--
       	    ASize( aApaga, len(aApaga)-1 )
       	    Exit
    	EndIf
    Next

	oModel:Activate()
    oModel:SetValue('CY6MASTER', 'CY6_CDFA' , AllTrim(aDados[nX,3])  )
    oModel:SetValue('CY6MASTER', 'CY6_DSFA' , AllTrim(aDados[nX,4]) )
    If oModel:VldData()
    	oModel:CommitData()
    EndIf
Next nX

For nI := 1 to len( aApaga )
	dbSelectArea( 'CY6' )
 	If CY6->( dbSeek( xFilial('CY6') + aApaga[nI] ))
		oModel := FWLoadModel( 'SFCA020' )
		oModel:SetOperation(5)
  		oModel:Activate()
	    If oModel:VldData()
	    	oModel:CommitData()
	    Else
	    	cError += STR0019 + AllTrim(aApaga[nI]) + STR0020 + oModel:GetErrorMessage()[6] + CRLF  // 'Família ' ### ' não pode ser removida: '
		EndIf
	EndIf
Next

If !Empty(cError)
	DEFINE MSDIALOG oDlg TITLE STR0021 From 0,0 TO 250,400 PIXEL // 'Problemas encontrados'
	oMemo := TSimpleEditor():New( 5,5,oDlg,192,100, cError, .T., , , .T.  )
	oMemo:Load(cError)
	oMemo:lCanGotFocus:= .F.
	TButton():New( 110, 158, STR0022, oDlg,{|| oDlg:End()},40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'OK'
	ACTIVATE MSDIALOG oDlg CENTER
EndIf

Return Nil

//-------------------------------------------------------------------
/*Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet    	:= .T.
Local lFound
Local cXMLRet  	:= ''
Local oXML, oModel
Local oBusinessContent
Local oBusinessEvent
Local nOpc			:= 3
Local aArea    	:= GetArea()
Local cCDFA     	:= ''

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
        	Return { lValid,  STR0012 } // 'Não foi enviada uma mensagem válida'
        EndIf

        cCDFA := UPPER(ALLTRIM(oBusinessContent:_FamilyCode:TEXT))

        // Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
		dbSelectArea('CY6')
		CY6->(dbSetOrder(1))
		lFound := CY6->(dbSeek(xFilial('CY6')+cCDFA))

		// Instancia o modelo
		oModel := FWLoadModel( 'SFCA020' )

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
					lAssign := oModel:SetValue('CY6MASTER', 'CY6_CDFA', cCDFA)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				EndIf

				lAssign := oModel:SetValue('CY6MASTER', 'CY6_DSFA'  , oBusinessContent:_FamilyDescription:TEXT)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('CY6MASTER', 'CY6_CDDPPA', oBusinessContent:_Warehouse:TEXT)			;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('CY6MASTER', 'CY6_CDUN'  , oBusinessContent:_UnitOfMeasure:TEXT)		;If !lAssign; Return INTEGERROR( oModel ); EndIf
	        EndIf

	        // Validação no Model
			If oModel:VldData()
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()

				// Retorna OK
				cXMLRet := STR0013 + IF(nOpc == 3, STR0014, IF(nOpc == 4, STR0015, STR0016)) + STR0017  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
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
    	cXMLRet := STR0018 // 'Resposta recebida com sucesso.'

    // Mensagem é de Whois
    ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
        Return {.T., '1.000'}
    EndIf

// Chamada é para envio, solicitada pelo MODEL
ElseIf nTypeTrans == TRANS_SEND

	// Busca o Model que está Ativo no momento da chamada
    oModel := FwModelActive()

	// Cria a estrutura de TAGs BusinessEvent, já identificando se é Upsert ou Delete, e colocando as Identifications
    cXMLRet :=  FWEAIBusEvent( 'Family', oModel:GetOperation(), { { 'FamilyCode', oModel:GetValue('CY6MASTER', 'CY6_CDFA') } }  )

    // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
    cXMLRet += '<BusinessContent>'

	cXMLRet += '<FamilyCode>'	+ INTEGXTOS(oModel:GetValue('CY6MASTER', 'CY6_CDACDV'))	+ '</FamilyCode>'

	// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
	If oModel:GetOperation() # 5
		cXMLRet += '<FamilyDescription>'	+ INTEGXTOS(oModel:GetValue('CY6MASTER', 'CY6_DSFA'  ))	+ '</FamilyDescription>'
		cXMLRet += '<Warehouse>'			+ INTEGXTOS(oModel:GetValue('CY6MASTER', 'CY6_CDDPPA'))	+ '</Warehouse>'
		cXMLRet += '<UnitOfMeasure>'		+ INTEGXTOS(oModel:GetValue('CY6MASTER', 'CY6_CDUN'  ))	+ '</UnitOfMeasure>'
  	EndIf

    cXMLRet += '</BusinessContent>'
EndIf

RestArea(aArea)

Return { lRet, cXMLRet }    */