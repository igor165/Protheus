#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURA013.CH'

/*/{Protheus.doc} TURA013
Função de cadastro de Planos de Seguros
@author	Elton Teodoro Alves
@since 22/04/2015
@version 1.0
/*/
Function TURA013()
	
	Local	oBrowse	:=	FwMBrowse():New()
	Local	cAlias	:=	'G4G'
	
	oBrowse:SetAlias( cAlias )
	
	oBrowse:SetDescription( STR0010 )	// "Cadastro de Planos de Seguros"
	
	oBrowse:Activate()
	
Return

/*/{Protheus.doc} MENUDEF
Função que monta o Menu de Rotinas do Cadastro de Planos de Seguros
@author	Elton Teodoro Alves
@since 22/04/2015
@version 1.0
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina Title STR0001	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0 // Pesquisa
	ADD OPTION aRotina Title STR0002	ACTION 'VIEWDEF.TURA013'	OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina Title STR0003	ACTION 'VIEWDEF.TURA013'	OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina Title STR0004	ACTION 'VIEWDEF.TURA013'	OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina Title STR0005	ACTION 'VIEWDEF.TURA013'	OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina Title STR0006	ACTION 'VIEWDEF.TURA013'	OPERATION 8 ACCESS 0 // Imprimir
	ADD OPTION aRotina Title STR0007	ACTION 'VIEWDEF.TURA013'	OPERATION 9 ACCESS 0 // Copiar
	
Return aRotina

/*/{Protheus.doc} MODELDEF
Função que monta o Modelo de Dados do cadastro de Planos de Seguros
@author	Elton Teodoro Alves
@since 22/04/2015
@version 1.0
/*/
Static Function ModelDef()
	
	Local	oModel	:=	MpFormModel():New( 'TURA013', , { | oModel | TudoOk( oModel ) } )
	Local	oStruct	:=	FWFormStruct( 1, 'G4G' )
	
	oModel:AddFields( 'MASTER', , oStruct )
	oModel:SetDescription( STR0010 )	// "Cadastro de Planos de Seguros"
	oModel:GetModel( 'MASTER' ):SetDescription( STR0008 ) // Dados do Cadastro de Planos de Seguros
	
Return oModel
/*/{Protheus.doc} VIEWDEF
Função que monta a View de Dados do cadastro de Planos de Seguros
@author	Elton Teodoro Alves
@since 22/04/2015
@version 1.0
/*/
Static Function ViewDef()
	
	Local	oModel	:=	FWLoadModel( 'TURA013' )
	Local	oStruct	:=	FWFormStruct( 2, 'G4G' )
	Local	oView	:=	FWFormView():New()
	
	oView:SetModel( oModel )
	oView:AddField( 'VIEW', oStruct, 'MASTER' )
	oView:CreateHorizontalBox( 'TELA', 100 )
	oView:SetOwnerView( 'VIEW', 'TELA' )
	
Return oView
/*/{Protheus.doc} TudoOk
Função que verifica se o código de Plano de Seguros já existe para o Fornecedor.
@author	Elton Teodoro Alves
@since 22/04/2015
@version 1.0
@param oModel, objeto, Modelo de dados da Field
@return Lógico Retorno da validação do modelo de dados
/*/
Static Function TudoOk( oModel )
	
	Local	lRet		:=	.T.
	Local	nOperation	:=	oModel:GetOperation()
	Local	aArea		:=	GetArea()
	
	If cValToChar( nOperation ) $ '3'
		
		DbSelectArea( 'G4G' )
		DbSetOrder( 2 )
		
		If DbSeek(;
				xFilial( 'G4G' ) +;
				oModel:GetModel( 'MASTER' ):GetValue( 'G4G_FORNEC' ) +;
				oModel:GetModel( 'MASTER' ):GetValue( 'G4G_LOJA' ) +;
				oModel:GetModel( 'MASTER' ):GetValue( 'G4G_CODIGO' ) )
			
			Help( ,, 'Help',, STR0009, 1, 0 ) // Já Existe este Código cadastrado para este Fornecedor.
			
			lRet	:=	.F.
			
		End If
		
		RestArea( aArea )
		
	End If
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	28/09/2015
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

Local aRet := {}

aRet:= TURI013( cXml, nTypeTrans, cTypeMessage )

Return aRet