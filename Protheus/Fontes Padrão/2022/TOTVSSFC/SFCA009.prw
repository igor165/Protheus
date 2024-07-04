#INCLUDE "SFCA009.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA009  
Tela de cadastro de Indicadores

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA009()
Private oBrowse

SFCValInt() // Verifica integração ligada    

SFCA009RES(.T.)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYJ')
oBrowse:SetDescription( STR0001 )   // 'Cadastro de Metas de Produção' 
oBrowse:SetOnlyFields( { 'CYJ_CDIN', 'CYJ_DSIN', 'CYJ_CDUN', 'CYJ_TPAN', 'CYJ_TPIN', 'CYJ_DSMI', 'CYJ_TPMSMI', 'CYJ_DSSIMI', 'CYJ_DSMSMI', ;
                         'CYJ_DSXA', 'CYJ_TPMSXA', 'CYJ_DSSIXA', 'CYJ_DSMSXA', 'CYJ_DSMX', 'CYJ_TPMSMX', 'CYJ_DSSIMX', 'CYJ_DSMSMX' } ) 
oBrowse:Activate() 

Return NIL
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA009' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA009' OPERATION 3 ACCESS 0  // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA009' OPERATION 4 ACCESS 0  // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA009' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA009' OPERATION 8 ACCESS 0  // 'Imprimir'   
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA009' OPERATION 9 ACCESS 0  // 'Copiar'     
ADD OPTION aRotina TITLE STR0009 ACTION 'SFCA009RES(.F.)' OPERATION 3 ACCESS 0  // 'Restaurar Configurações'

Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYJ := FWFormStruct( 1, 'CYJ', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStructCY3 := FWFormStruct( 1, 'CY3', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA009', /*bPreValidacao*/, { |oMdl| SFCA009PRE( oMdl ) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYJMASTER', /*cOwner*/, oStructCYJ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CY3DETAIL', 'CYJMASTER', oStructCY3, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CY3DETAIL', { { 'CY3_FILIAL', 'xFilial( "CY3" )' }, { 'CY3_CDIN', 'CYJ_CDIN' } }, CY3->(IndexKey(1)) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CY3DETAIL' ):SetUniqueLine( { 'CY3_CDINSO' } ) 

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CY3DETAIL' ):SetOptional(.T.)                                                           

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0010 ) //'Modelo de Dados de Indicadores'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYJMASTER' ):SetDescription( STR0011 )  //'Dados de Indicadores'
oModel:GetModel( 'CY3DETAIL' ):SetDescription( STR0012 ) //'Dados de Indicadores Filhos'

Return oModel
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA009' )
// Cria a estrutura a ser usada na View
Local oStructCYJ := FWFormStruct( 2, 'CYJ' )
Local oStructCY3 := FWFormStruct( 2, 'CY3' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel ) 
                                                     
//Adiciona no nosso view um botão para compor mensagens
oView:AddUserButton(  STR0050 , "SFXCOMPMSG", { || SFXCOMPMSG(1) } ) // 'Compor Mensagem'

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYJ', oStructCYJ, 'CYJMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CY3', oStructCY3, 'CY3DETAIL' ) 

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYJ', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CY3', 'INFERIOR' )

//Remove o campo repetido em tela
oStructCY3:RemoveField("CY3_CDIN")

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA009PRE 
Rotina para Validar os dados no momento da inclusão ou alteração
Uso Geral.

@param   oModel        Objeto do model principal
@author Tiago Gauziski
@since 22/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA009PRE (oModel)
Local lRet       := .T.
Local nOpc       := (oModel:GetOperation())
Local oModelGrid := oModel:GetModel( 'CY3DETAIL' )
Local nI         := 0   
	
If nOpc == 3 .Or. nOpc == 4
	If (FwFldGet('CYJ_VLEDMI') <= 0)
		Help( ,, 'Help',, STR0013 , 1, 0 )  // 'Valor do Limite Inicial da Faixa 1 precisa ser maior que 0'
    	lRet := .F.
	ElseIf (FwFldGet('CYJ_VLEDMI') >= FwFldGet('CYJ_VLEDXA')) 
		Help( ,, 'Help',, STR0014 , 1, 0 )  // 'Valor do Limite Final da Faixa 2 precisa ser maior que o Limite Final da Faixa 1'
    	lRet := .F.
	ElseIf (FwFldGet('CYJ_VLEDXA') > 100) 
   		Help( ,, 'Help',, STR0015 , 1, 0 )  // 'Valor do Limite Final da Faixa 2 precisa ser menor que 100'
    	lRet := .F.
	EndIf
	
	For nI := 1 To oModelGrid:GetQtdLine()
    	If(FwFldGet('CY3_CDINSO', nI) == FwFldGet('CYJ_CDIN') .And. !oModelGrid:IsDeleted( nI ))
    		Help( ,, 'Help',, STR0016 , 1, 0 )  // 'Não é possível criar um Indicador Filho com mesmo código do Indicador'
    		lRet := .F.
    		Exit
    	EndIf
    Next     
EndIf

Return lRet  
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA009RES
Restaura configurações padrões sobre os Indicadores

@param   lAltera   	(Obrigatório) Indica se esta restaurando ou incluindo

@author Ana Carolina Tomé Klock
@since 04/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA009RES( lAltera )  
    Default lAltera := .T.
    
	dbSelectArea("CYJ")
	
	If Empty( dbSeek( xFilial("CYJ") ) ) .Or. lAltera == .F.
		SFCA009CRI( STR0017		 , STR0018   	  	, STR0019  , "6", "01", lAltera ) // 'Q', 'Qualidade', '%'
		SFCA009CRI( STR0020  	 , STR0021			, STR0019  , "6", "02", lAltera ) // 'Q_Real', 'Qualidade Real', '%'
		SFCA009CRI( STR0022		 , STR0023		  	, STR0019  , "3", "03", lAltera ) // 'E', 'Eficiência', '%'
		SFCA009CRI( STR0024		 , STR0025			, STR0019  , "3", "04", lAltera ) // 'U', 'Utilização', '%'
		SFCA009CRI( STR0026 	 , STR0027			, STR0019  , "4", "05", lAltera ) // 'D_Real' , 'Disponibilidade Real', '%'
		SFCA009CRI( STR0028      , STR0029			, STR0019  , "4", "06", lAltera ) // 'D_Planejada', 'Disponibilidade Planejada', '%'
		SFCA009CRI( STR0030		 , STR0031			, STR0019  , "3", "07", lAltera, { STR0022, STR0020 } )  // 'NEE', 'Eficiência Líquida', '%', 'E', 'Q_Real' 
		SFCA009CRI( STR0032 	 , STR0033			, STR0019  , "3", "08", lAltera, { STR0026, STR0030 } )  // 'OEE', 'Eficiência Geral', '%', 'D_Real', 'NEE'
		SFCA009CRI( STR0034		 , STR0035			, STR0019  , "3", "09", lAltera, { STR0032, STR0024 } ) // 'TEEP', 'Produtividade', '%', 'OEE', 'U'
		SFCA009CRI( STR0036		 , STR0037			, STR0019  , "2", "10", lAltera ) // 'BTS_V', 'BTS Volume', '%'
		SFCA009CRI( STR0038		 , STR0039			, STR0019  , "2", "11", lAltera ) // 'BTS_M', 'BTS Mix', '%'
		SFCA009CRI( STR0040		 , STR0041			, STR0019  , "2", "12", lAltera ) // 'BTS_S', 'BTS Sequencia', '%'
		SFCA009CRI( STR0042		 , STR0043			, STR0019  , "2", "13", lAltera, { STR0036, STR0038, STR0040 } ) // 'BTS', 'Acompanhamento de Produção', '%', 'BTS_V', 'BTS_M', 'BTS_S'
		SFCA009CRI( STR0044		 , STR0045			, STR0046  , "5", "14", lAltera ) // 'Tk', 'Takt Time', 'Min/Qtd'     
	EndIf                                                                                    
	CYJ->(dbCloseArea())

Return Nil  
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA009CRI
Cria os indicadores conforme passados os parametros

@param   cCDIN   	(Obrigatório) Código do Indicador
@param 	 cDSIN   	(Obrigatório) Descrição do Indicador   
@param 	 cCDUN      (Obrigatório) Unidade de Medida
@param 	 cTPAN      (Obrigatório) Tipo de Análise
@param 	 cTPIN      (Obrigatório) Tipo do Indicador
@param 	 lAltera	(Obrigatório) Informa se esta alterando ou incluindo  
@param 	 aFilhos	Determina os indicadores filhos

@author Ana Carolina Tomé Klock
@since 04/05/11
@version 1.0
/*/
//------------------------------------------------------------------- 
Function SFCA009CRI( cCDIN, cDSIN, cCDUN, cTPAN, cTPIN, lAltera, aFilhos ) 
	Local lCria := .T.
	Local nI
	Default aFilhos := { }      
	
	If !Empty(Posicione("CYJ",1,xFilial("CYJ")+cCDIN,"CYJ_TPIN")) .And. lAltera == .F.
		lCria := .F.
	EndIf

	RecLock("CYJ", lCria )
		CYJ->CYJ_FILIAL := xFilial('CYJ')
		CYJ->CYJ_CDIN   := cCDIN
		CYJ->CYJ_DSIN   := cDSIN
		CYJ->CYJ_CDUN   := cCDUN
		CYJ->CYJ_TPAN   := cTPAN
		CYJ->CYJ_TPIN   := cTPIN 
		CYJ->CYJ_DSMI   := STR0047 // 'Crítica' 
		CYJ->CYJ_TPMSMI := '1'
		CYJ->CYJ_DSXA   := STR0048 // 'Regular'
		CYJ->CYJ_TPMSXA := '1'
		CYJ->CYJ_DSMX   := STR0049 // 'Melhor'
		CYJ->CYJ_TPMSMX := '1'
		CYJ->CYJ_VLEDMI := 33
		CYJ->CYJ_VLEDXA := 66
	MsUnLock() 
	For nI := 1 to Len(aFilhos) 
		If Empty(Posicione("CY3",1,xFilial("CY3")+PADR(cCDIN, 25)+PADR(aFilhos[nI], 25),"CY3_CDIN")) 
	   		RecLock( "CY3", .T. )
	   			CY3->CY3_FILIAL := xFilial('CY3')
	   			CY3->CY3_CDIN   := cCDIN
				CY3->CY3_CDINSO := aFilhos[nI]
	   		MsUnLock()
		EndIf
	Next     
	
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA009VAL
Valida se a função especifica pode ser informada

@author Ana Carolina Tome Klock	
@since 13/06/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA009VAL() 
Local lRet := .T.         

	If FwFldGet("CYJ_TPIN") != '15'
		lRet := .F.
	EndIf

Return lRet 