#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMVC03
Rotina de cadastro Estado X Municํpios

@author Diego Silva
@since 21/10/2010
@version P11
/*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSMVC03  บAutor  ณMicrosiga           บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSMVC03()
Local oBrowse
Local cFiltro	:= ""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Validacao
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If !PLSALIASEXI("B12")                                       
	MsgAlert( "Nใo ้ possํvel utilizar esta rotina! (Execute o compatibilizador da rotina)" )
	Return
EndIf
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ@ฟ
//ณPonto de Entrada para filtrar conteudo do Browse B12ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ@ู
ENDDOC*/
If ExistBlock("PLMVC03FIL")
	cFiltro := ExecBlock("PLMVC03FIL",.F.,.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Browse
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B12' )
oBrowse:SetDescription( Fundesc()/*'Estado x Mun x TDE'*/ )

If ValType(cFiltro)= "C"
	If !Empty(cFiltro)
		oBrowse:SetFilterDefault(cFiltro)
	Endif
Endif

oBrowse:Activate()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Rotina
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณMicrosiga           บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  Action 'PesqBrw'          	OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.PLSMVC03' 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.PLSMVC03' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.PLSMVC03' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.PLSMVC03' 	OPERATION 5 ACCESS 0
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณMicrosiga           บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB12 := FWFormStruct( 1, 'B12', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruB13 := FWFormStruct( 1, 'B13', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSMVCMODEL',/*bPreValidacao*/,{|| PlsVldMdl(oModel)},/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'B12MASTER', /*cOwner*/, oStruB12 )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por grid
oModel:AddGrid( 'B13DETAIL', 'B12MASTER', oStruB13, /*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPreVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model                                                      
If B12->( FieldPos("B12_SEQUEN") ) > 0 .and. B13->( FieldPos("B13_SEQB12") ) > 0 
	oModel:SetRelation( 'B13DETAIL', { 	{ 'B13_FILIAL', 'xFilial( "B13" )' },;
										{ 'B13_CODINT', 'B12_CODINT' },;
										{ 'B13_CODEST', 'B12_CODEST' },;
										{ 'B13_SEQB12', 'B12_SEQUEN' }}, 'B13_FILIAL + B13_CODINT + B13_CODEST' )	
Else
	oModel:SetRelation( 'B13DETAIL', { { 'B13_FILIAL', 'xFilial( "B13" )' }, { 'B13_CODINT', 'B12_CODINT' }, { 'B13_CODEST', 'B12_CODEST' } }, 'B13_FILIAL + B13_CODINT + B13_CODEST' )
Endif
//Setando a chave primแria com os campos da tabala "Pai" depois do relacionamento entre as tabelas
oModel:SetPrimaryKey( {"B12_FILIAL", "B12_CODINT", "B12_CODEST", "B12_SEQUEN"} )
// Liga o controle de nao repeticao de linha
If B13->( FieldPos("B13_SEQUEN") ) > 0 
	oModel:GetModel( 'B13DETAIL' ):SetUniqueLine( {'B13_CODMUN','B13_CODTAB','B13_SEQUEN'} ) 
Else
	oModel:GetModel( 'B13DETAIL' ):SetUniqueLine( {'B13_CODMUN','B13_CODTAB'} ) 
Endif
// Indica que ้ opcional ter dados informados na Grid
oModel:GetModel( 'B13DETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Estados X Municipios X TDE' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B12MASTER' ):SetDescription( 'Estado X TDE' )
oModel:GetModel( 'B13DETAIL' ):SetDescription( 'Estado X Municipio X TDE'  )  
oStruB13:SetProperty( 'B13_SEQB12', MODEL_FIELD_INIT, { || oModel:GetModel( 'B12MASTER' ):getvalue("B12_SEQUEN") } )

Return oModel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณMicrosiga           บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB12 := FWFormStruct( 2, 'B12' )
Local oStruB13 := FWFormStruct( 2, 'B13' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSMVC03' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B12', oStruB12, 'B12MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B13', oStruB13, 'B13DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B12', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B13', 'INFERIOR' )

// Define campos que terao Auto Incremento      
If B13->( FieldPos("B13_SEQUEN") ) > 0 
	oView:AddIncrementField( 'VIEW_B13', 'B13_SEQUEN' )
Endif

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_B13','Estado X Municipio X TDE')

// Liga a Edi็ใo de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_B13', "ENABLEDGRIDDETAIL", { 60 } )

// Forcar o fechamento da tela ao salvar o model
oView:SetCloseOnOk({|| .T.})

Return oView    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPlsVldMdl บAutor  ณMicrosiga           บ Data ณ  10/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PlsVldMdl(oModel)                       
Local aArea := GetArea()
Local nOperation := oModel:GetOperation()
LOCAL oGrid 	:= oModel:GetModel( "B13DETAIL" ) 
LOCAL lRet		:= .T.
Local nLines 	:= oGrid:GetQtdLine()
LOCAL nX		
	                                     
If nOperation == MODEL_OPERATION_INSERT
	oModel:SetValue( 'B12MASTER', 'B12_CODINT', PLSINTPAD() )
EndIf
                  
// Valida o encerramento da vigencia do cadastro de estado.
If B12->( FieldPos("B12_VIGDE") ) > 0 .and. B12->( FieldPos("B12_VIGATE") ) > 0
	If nOperation <> MODEL_OPERATION_DELETE
		// Primeiro valida as vigencias.
		If PlsVldB12() .and. PlsVldB13(10,"B13","B13DETAIL")
			For nX := 1 To nLines
				oGrid:GoLine( nX )
				// Valida deletados.
				If !oGrid:IsDeleted() .and. !Empty(FwFldGet('B13_CODMUN',nX))      
					If FwFldGet('B13_VIGDE',nX) < M->B12_VIGDE
						Help( ,, 'HELP',,"O Inicio da vig๊ncia do municํpio nใo pode ser anterior ao inicio da vig๊ncia do Estado!", 1, 0)
						lRet := .F.   
					Endif
				Endif
			Next
		Endif
	Endif
Endif

RestArea( aArea )

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSVldMun บAutor  ณMicrosiga           บ Data ณ  10/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de filtro da consulta padrao de municipios B5APLS   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSVldMun(lF3)
Local aArea  	:= GetArea()
Local lRet   	:= .F. 
Local nFor      := 0
Default lF3     := .T.

If !lF3
	If ReadVar() == "M->B13_CODMUN"  
		
		oModel     := FWModelActive()
		oModelDet  := oModel:GetModel("B13DETAIL")
		nLine  	   := oModelDet:GetLine()
					
		// Recupero as informacoes da linha atual
	 	cMun	:= FwFldGet('B13_CODMUN',nLine)
		cEst    := M->B12_CODEST
		
	    BID->(DbSetOrder(4))//BID_FILIAL+BID_EST+BID_CODMUN
	    If BID->(MsSeek(xFilial("BID")+cEst+cMun))
	    	lRet:= .T.
	    Endif
	    
	ElseIf ReadVar() == "M->B12_CODEST"
	
		If ExistCpo('SX5','12'+M->B12_CODEST,1) .And. Type('M->B12_CODEST')=='C' 
		
			oModel     := FWModelActive()
			oModelDet  := oModel:GetModel("B13DETAIL")
			nLine  	   := oModelDet:GetLine() 
			
			// Valida a Primeira Inclusao
			If oModelDet:GetQtdLine() == 1 .And. Empty(FwFldGet('B13_CODMUN',1))
				lRet:= .T.
			Else
				For nFor := 1 To oModelDet:GetQtdLine() 
					oModelDet:GoLine( nFor )
					// Valida deletados.
					If !oModelDet:IsDeleted() .And. !Empty(FwFldGet('B13_CODMUN',nFor))
				    	lRet :=.F.
				    	EXIT
					Endif 
				Next nFor
			Endif
			If !lRet 
				Help( ,, 'HELP',,"Nใo ้ permitido mudar o Estado, pois jแ existem Municipio Informado!", 1, 0)
			Endif
		Else
			Help( ,, 'HELP',,"Estado ้ Invalido!", 1, 0)
		Endif
	Endif				
Else
	If Inclui
		If Type("M->B12_CODEST") == "C"
			lRet := BID->BID_EST == M->B12_CODEST 
		EndIf
	Else
		lRet := BID->BID_EST == B12->B12_CODEST      
	EndIf
Endif
	
RestArea(aArea)

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPlsVldB12 บAutor  ณMicrosiga           บ Data ณ  17/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funca de validacao das datas de vigencia da tabela B12	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PlsVldB12()
Local lRet     	:= .T.
Local aArea	    := GetArea() 
LOCAL cDatDe   	:= "B12_VIGDE"
LOCAL cDatAte  	:= "B12_VIGATE"           
LOCAL oModel	:= FWModelActive()
LOCAL cCodEst 	:= oModel:GetValue("B12MASTER", "B12_CODEST")
LOCAL cCodTab 	:= oModel:GetValue("B12MASTER", "B12_CODTAB")
LOCAL cTabPre 	:= ""
LOCAL aChave    := {01,xFilial("B12")+PlsIntPad()+cCodEst+cCodTab,'xFilial("B12")+PlsIntPad()+B12_CODEST+B12_CODTAB'}   

If B12->(FieldPos("B12_TABPRE")) > 0
	cTabPre 	:= oModel:GetValue("B12MASTER", "B12_TABPRE") 
	aChave      := {01,xFilial("B12")+PlsIntPad()+cCodEst+cCodTab+cTabPre,'xFilial("B12")+PlsIntPad()+B12_CODEST+B12_CODTAB+B12_TABPRE'} 
Endif 

If B12->( FieldPos("B12_VIGDE") ) > 0 .And. B12->( FieldPos("B12_VIGATE") ) > 0
	lRet := PLSVLDVIG("B12",0,NIL,cDatDe,cDatAte,aChave,.T.)
EndIf

RestArea(aArea)

Return(lRet)   
                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPlsVldB13 บAutor  ณMicrosiga           บ Data ณ  05/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunca de validacao das datas de vigencia da tabela B12	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PlsVldB13(nTipo,cAlias,cModel)

LOCAL oModel    := FWModelActive()  
LOCAL oStru 	:= oModel:GetModel( cModel ) 
LOCAL lRet		:= .T.

lRet := PlsLineB13(oStru, oModel)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณPlsLineB13  ณ Autor ณ Tulio Cesar       ณ Data ณ 25.06.2002 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Valida data na digitacao da tabela de preco				  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PlsLineB13(oGrid, oModel)
Local lRet		:= .T.
Local nOperation:= oGrid:GetOperation()
Local aArea 	:= GetArea()
Local aAcolsAx	:= aClone(oGrid:aCols)
Local nLines 	:= oGrid:GetQtdLine()
Local nPosDtIni := GdFieldPos("B13_VIGDE",oGrid:aHeader)
Local nPosDtFim := GdFieldPos("B13_VIGATE",oGrid:aHeader)
Local nX
Local aMat 		:= {}
Local nPos		:= 0
LOCAL dDtIni 	:= CTOD("")
LOCAL dDtFim 	:= CTOD("")
LOCAL cCodMun 	:= ""

If nOperation == 3 .OR. nOperation == 4
	
	// Essas sใo as datas da linha atual.
	dDtIni 	:= oGrid:GetValue("B13_VIGDE",oGrid:nLine)
	dDtFim 	:= oGrid:GetValue("B13_VIGATE",oGrid:nLine)
	cCodMun := oGrid:GetValue("B13_VIGDE",oGrid:nLine)
	
	If !Empty(cCodMun)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Vigencia do item deve ser maior ou igual a vigencia do cabecalho.
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If dDtIni < M->B12_VIGDE
			Help( ,, 'HELP',,"O Inicio da vig๊ncia do municํpio nใo pode ser anterior ao inicio da vig๊ncia do Estado!", 1, 0)
			lRet := .F.
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se data inicio for maior que final nao permite									 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lRet .and. dDtIni > dDtFim .And. ! Empty(dDtFim)
			Help("",1,"PLSANAFAI2")	// NAO OK
			lRet := .F.
		Endif
	Endif
	
	If lRet
		For nX := 1 To nLines
			// Desconsidera a propria linha.
			If nX == oGrid:nLine
				Loop
			Endif
			     
			// Compara a chave completa.
		   	If B13->(FieldPos("B13_TABPRE")) > 0			
				If 	!( oGrid:GetValue("B13_CODMUN",oGrid:nLine) + oGrid:GetValue("B13_CODTAB",oGrid:nLine) + oGrid:GetValue("B13_TABPRE",oGrid:nLine) ==;
					oGrid:GetValue("B13_CODMUN",nX) + oGrid:GetValue("B13_CODTAB",nX) + oGrid:GetValue("B13_TABPRE",nX) )
			    
				    Loop
				Endif
			Else
				If 	!( oGrid:GetValue("B13_CODMUN",oGrid:nLine) + oGrid:GetValue("B13_CODTAB",oGrid:nLine)  ==;
					oGrid:GetValue("B13_CODMUN",nX) + oGrid:GetValue("B13_CODTAB",nX)  )
			    
				    Loop
				Endif
			Endif
						
			// Atualiza a linha do grid para futuras verifica็๕es
			If (!Empty(oGrid:GetValue("B13_VIGDE", nX)) .OR. !Empty(oGrid:GetValue("B13_VIGATE", nX))) .and. !oGrid:IsDeleted(nX)
				AaDd( aMat,{ oGrid:GetValue("B13_VIGDE", nX), oGrid:GetValue("B13_VIGATE", nX) } )
			Endif
			
		Next
		
		oModel:SetValue( 'B13DETAIL', 'B13_SEQB12', allTrim(M->B12_SEQUEN))
		
		If Len(aMat) > 0
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se ja cadastrado												 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nPos := AsCan(aMat,{ |x| Empty(x[2])} )
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Se tem vigencia com data final em aberta verifica se a data final e menor que a inicialณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nPos > 0
				If Empty(dDtFim)
					Help(" ",1,'PLSA112A')	// OK
					lRet := .F.
				EndIf
				
				If lRet .and. dDtFim >= aMat[nPos,1]
					Help(" ",1,'PLSA112B')	// NAO OK
					lRet := .F.
				EndIf
				
				nPos := AsCan(aMat,{ |x| dDtIni >= x[1] .And. dDtIni <= x[2] .Or. dDtIni < x[1] .And. dDtFim > x[1] } )
				If lRet .and. nPos > 0
					Help(" ",1,'PLSA112C')	// NAO OK
					lRet := .F.
				EndIf
				
				nPos := AsCan(aMat,{ |x| dDtIni >= x[1] .And. dDtFim <= x[2]  } )
				If lRet .and. nPos > 0
					Help(" ",1,'PLSA112C')	// NAO OK
					lRet := .F.
				EndIf
			Else
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Se e valido o intervalo																   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nPos := AsCan(aMat,{ |x| dDtIni <= x[2]  } )
				If lRet .and. nPos > 0
					Help(" ",1,'PLSA112D')	// OK
					lRet := .F.
				EndIf
			EndIf
		Endif
	Endif
Endif


// Restaura area.
RestArea(aArea)
Return(lRet)	