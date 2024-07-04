#INCLUDE "FINA685.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA685
Conferencia das Faturas de prestacao de servico contra o que foi
solicitado na viagem.

@author Alexandre Circenis
@since 22/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function FINA685()

Local oBrowse
Local cFiltro  := "FLQ->FLQ_ORIGEM != 'FINA686'"	

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FLQ' )
oBrowse:SetDescription( STR0009 )
oBrowse:SetFilterDefault( cFiltro )
oBrowse:AddLegend( "FLQ_STATUS=='1'", "GREEN", STR0001       ) //"Confirmada"
oBrowse:AddLegend( "FLQ_STATUS=='2'", "RED"  , STR0002  ) //"Estornada"
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0010	Action 'VIEWDEF.FINA685' OPERATION 2 ACCESS 0  	//Visualizar
ADD OPTION aRotina Title STR0011   	Action 'FN685Inc' 		 OPERATION 3 ACCESS 0	//Incluir
ADD OPTION aRotina Title STR0012    Action 'VIEWDEF.FINA685' OPERATION 5 ACCESS 0	//Estornar
ADD OPTION aRotina Title STR0013  	Action 'VIEWDEF.FINA685' OPERATION 8 ACCESS 0	//Imprimir

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFLQ := FWFormStruct( 1, 'FLQ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFLR := FWFormStruct( 1, 'FLR', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFLU := FWFormStruct( 1, 'FLU', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FINA685A', /*bPreValidacao*/, /*bPosValidacao*/,  {|oObj|FN685CM( oObj )}/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FLQMASTER', /*cOwner*/, oStruFLQ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'FLRDETAIL', 'FLQMASTER', oStruFLR, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'FLUDETAIL', 'FLRDETAIL', oStruFLU, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Carga
//oModel:AddGrid( 'FLRDETAIL', 'FLQMASTER', oStruFLR, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FLRDETAIL', { { 'FLR_FILIAL', 'xFilial( "FLR" )' }, { 'FLR_CONFER' , 'FLQ_CONFER'  } } , FLR->( IndexKey( 1 ) )  )
oModel:SetRelation( 'FLUDETAIL', { { 'FLU_FILIAL', 'xFilial( "FLU" )' }, { 'FLU_VIAGEM' , 'FLR_VIAGEM'  } } , FLU->( IndexKey( 1 ) )  )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'FLRDETAIL' ):SetUniqueLine( { 'FLR_MUSICA' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0003 ) //'Modelo de Conferencia'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FLQMASTER' ):SetDescription( STR0004 ) //'Conferencia'
oModel:GetModel( 'FLRDETAIL' ):SetDescription( STR0005  ) //'Pedidos Conferidos'

// Nao Permite Incluir, Alterar ou Excluir linhas na formgrid
//oModel:GetModel( 'ZA5DETAIL' ):SetNoInsertLine()
//oModel:GetModel( 'ZA5DETAIL' ):SetNoUpdateLine()
//oModel:GetModel( 'ZA5DETAIL' ):SetNoDeleteLine()

// Adiciona regras de preenchimento
//
// Tipo 1 pre-validacao
// Adiciona uma relação de dependência entre campos do formulário,
// impedindo a atribuição de valor caso os campos de dependëncia
// náo tenham valor atribuido.
//
// Tipo 2 pos-validacao
// Adiciona uma relação de dependência entre a referência de origem e
// destino, provocando uma reavaliação do destino em caso de atualização
// da origem.
//
// Tipo 3 pre e pos-validacao
// oModel:AddRules( 'FLQMASTER', 'FLQ_DATA', 'FLQMASTER', 'FLQ_DESCRI', 1 )

oModel:SetVldActive( { |oModel| FN685ACT( oModel ) } )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruFLQ := FWFormStruct( 2, 'FLQ' )
Local oStruFLR := FWFormStruct( 2, 'FLR' )

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA685' )
Local oView


// Remove campos da estrutura
oStruFLR:RemoveField( 'FLR_CONFER' )


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FLQ', oStruFLQ, 'FLQMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FLR', oStruFLR, 'FLRDETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 40 )
oView:CreateHorizontalBox( 'MEIO'   , 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FLQ', 'EMCIMA'   )
oView:SetOwnerView( 'VIEW_FLR', 'MEIO'     )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_FLQ' )
oView:EnableTitleView( 'VIEW_FLR', STR0006, RGB( 224, 30, 43 )  ) //"Pedidos Conferidos"

// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_FLR', "ENABLEDGRIDDETAIL", { 60 } )
//oView:SetViewProperty( 'VIEW_ZA5', "ENABLEDGRIDDETAIL", { 60 } )

// Acrescenta um objeto externo ao View do MVC
// AddOtherObject(cFormModelID,bBloco)
// cIDObject - Id
// bBloco    - Bloco chamado evera ser usado para se criaros objetos de tela externos ao MVC.

//oView:AddOtherObject("OTHER_PANEL", {|oPanel| COMP23BUT(oPanel)})
//oView:SetOwnerView("OTHER_PANEL",'EMBAIXODIR')    

//Remove os campos criados para a conferencia de servicos II (FINA686)
oStruFLQ:RemoveField( 'FLQ_NATUR' )
oStruFLQ:RemoveField( 'FLQ_TIPO'  )
oStruFLQ:RemoveField( 'FLQ_PEDIDO')
oStruFLQ:RemoveField( 'FLQ_TPPGTO')
oStruFLQ:RemoveField( 'FLQ_COND'  )

Return oView


//----------------------------------------------------------------------------------
Function FN685Inc(cAlias,nRec,nOpc)

if Pergunte("FINA685",.T.)
    FLQ->(dbGoTop())
	dbSkip()
	FWExecView (STR0007, "FINA685A", MODEL_OPERATION_INSERT) //"Conferencia"

endif
	
Return   

//-------------------------------------------------------------------
Static Function FN685CM( oModel )

Local aArea      := GetArea()
Local nI         := 0
Local nOperation := oModel:GetOperation()
Local lOk        := .T.
Local aSaveLines := FWSaveRows()
Local oModelCon
Local oModelFLU  := oModel:GetModel("FLUDETAIL")
Local cViagemItem:= ""
Local nPartic    := 0


Begin Transaction

If nOperation = MODEL_OPERATION_DELETE

	
	oModelFLR := oModel:GetModel( 'FLRDETAIL' )
	oModelFLQ := oModel:GetModel( 'FLQMASTER' )

	// Ajustar o Valor conferido do Pedido
	if	!DelTitPg(oModelFLQ:GetValue( 'FLQ_FORNEC'), oModelFLQ:GetValue( 'FLQ_LOJA'),oModelFLQ:GetValue('FLQ_PREFIX'),;
		oModelFLQ:GetValue('FLQ_NUMTIT'), oModelFLQ:GetValue('FLQ_PARC'))
		if !IsBlind()
			MostraErro()
		endif
		DisarmTransaction()	
        lOk := .F.
	endif  
	
    if lOk
		For nI := 1 To oModelFLR:Length()

   			oModelFlR:GoLine( nI )  

   		    cViagemItem := oModelFLR:GetValue( 'FLR_VIAGEM', nI, oModel ) + oModelFLR:GetValue( 'FLR_ITEMVI', nI, oModel ) 
			FL6->( dbSetOrder( 1 ) )
			If FL6->( dbSeek( xFilial( 'FL6' ) + cViagemItem ) )
				RecLock("FL6",.F.)
				FL6->FL6_VCONFE -= oModelFLR:GetValue( 'FLR_VALOR', nI, oModel )
				FL6->FL6_STATUS := IF(FL6->FL6_VCONFE= 0, '0', If(FL6->FL6_VCONFER >= FL6->FL6_TOTAL, "2","1")) 
				msUnlock()
			Endif                                                                              
			
            If FL5->( dbSeek( xFilial( 'FL5' ) + oModelFLR:GetValue( 'FLR_VIAGEM', nI, oModel ) ) )
            	Reclock("FL5",.F.)
            	FL5->FL5_STATUS := FN685STAT(oModelFLR:GetValue( 'FLR_VIAGEM', nI, oModel ))
            	msUnlock()
            endif
            
			If !Empty(oModelFLR:GetValue( 'FLR_PARTIC', nI, oModel ))
				FLU->( dbSetOrder( 1 ) )
				If FLU->( dbSeek( xFilial( 'FLU' ) + cViagemItem + oModelFLU:GetValue( 'FLU_PARTIC', nI, oModel )))
					RecLock("FLU",.F.)
					FLU->FLU_VCONFER += oModelFLR:GetValue( 'FLR_VINFOR', nI, oModel )
   			        msUnlock()
 				Endif 
 			endif   
        
		Next nI 
		 
 	    RecLock("FLQ",.F.)
	    FLQ->FLQ_STATUS := '2'
		MsUnlock()
		
    endif
endif	
/*
FWModelActive( oModel )
FWFormCommit( oModel )
//FWRestRows( aSaveLines )
*/

end Transaction
RestArea( aArea )

Return .T.

//--------------------------------------------------------------------------
Static Function DelTitPg(cCODFOR, cLOJFOR, cPrefixo, cNumero, cParcela   )

LOCAL aTitulo := {}
PRIVATE lMSHelpAuto := .f. // para nao mostrar os erro na tela
PRIVATE lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e' que deu erro
					
//Será gerado o financeiro se os tres paramtros estaiver preenchidos

	 aTitulo := {	{"E2_PREFIXO"	,cPrefixo	 		,Nil},;      
	  				{"E2_NUM"		,cNumero        	,Nil},;      
					{"E2_PARCEL"	,cParcela  	     	,Nil},;      
					{"E2_FORNECE"	,cCODFOR           	,Nil},;      
					{"E2_LOJA"		,cLOJFOR			,Nil}}      

	MSExecAuto({|x,z,y| FINA050(x,z,y)},aTitulo,,5)


Return !lMSErroAuto   

//--------------------------------------------------------------------------------
Static Function FN685ACT(oModel)
Local aArea      := GetArea()
Local lRet       := .T.
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE
		
	If FLQ->FLQ_STATUS = '2'
		Help( ,, 'HELP',, STR0008, 1, 0) //'Está conferencia já foi estornada'
		lRet := .F.
	EndIf

	If FLQ->FLQ_ORIGEM == 'FINA686'
		Help( ,, 'HELP',,STR0014, 1, 0)	//"Este processo foi gerado por outra rotina de conferência de serviços, não sendo permitido seu estorno."
		lRet := .F.
	EndIf
	
EndIf

RestArea( aArea )
                 
Return lRet      

//
// -----------------------------------------------------------------------------
//
Function FN685STAT(cViagem)
Local cStatus := '1' // Aguardando conferencia
Local aArea := GetArea()
Local cQuery 
Local cAliasTrb := GetNextAlias()
Local lF685STA	:= ExistBlock("F685STA")

cQuery := "SELECT COUNT(*) CONFER FROM "
cQuery += RetSqlName("FL6") + " FL6 "
cQuery += " WHERE "                                    
cQuery += "FL6_FILIAL = '"+xFilial("FL6")+"'"
cQuery += " AND  FL6_VIAGEM = '" + cViagem + "'"
cquery += " AND FL6_STATUS <> '2'"
cQuery += " AND FL6.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
		
dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTrb,.F.,.T.)
// Se houver pedidos não conferidos ou conferidos parcialmente o status da viagem continua com "1" - Aguardando conferencia
// Se só houverem pedido conferidos totalmente alterar status para '2' - Conferidos
cStatus := if( (cAliasTrb)->CONFER = 0, "2","1")

If lF685STA
	cStatus := ExecBlock("F685STA",.F.,.F.,{cViagem,cStatus})
EndIf

			
dbCloseArea()
              
RestArea(aArea)
Return cStatus         

