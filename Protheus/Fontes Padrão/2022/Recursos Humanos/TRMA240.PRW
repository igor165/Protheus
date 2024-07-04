#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCOMMAND.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TRMA240()
Cadastro de Certificados

@author Marcelo Faria
@since 20/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function TRMA240()
	Local oMBrowse := FWMBrowse():New()	
	oMBrowse:SetAlias("RHG")
	//oMBrowse:SetFilterDefault("RAX_SEQUEN == '01'") //Exemplo filtro
	oMBrowse:Activate()	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PESQBRW"         OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.TRMA240" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.TRMA240" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.TRMA240" OPERATION 4 ACCESS 143
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.TRMA240" OPERATION 5 ACCESS 144
	ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.TRMA240" OPERATION 8 ACCESS 0	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do modelo da regra de negocios

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRHG := FWFormStruct( 1, 'RHG', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruRAX := FWFormStruct( 1, 'RAX', /*bAvalCampo*/, /*lViewUsado*/ )
	Local bPreVal  := { |oModel,nLine,cAcao| TRMA240PreVal( oModel, nline, cAcao )}
	Local oModel

	//oStcRAX2:SetProperty( 'RAX_CODIGO', MODEL_FIELD_KEY, .F. )
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'TRMA240', NIL, NIL, {|oModel| TRMA240Commit(oModel)} )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'RHGMASTER', /*cOwner*/, oStruRHG )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'RAXDETAIL', 'RHGMASTER', oStruRAX, /*bLinePre*/, /*bLinePost*/, bPreVal, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'RAXDETAIL', { { 'RAX_FILIAL', 'xFilial( "RAX" )' }, { 'RAX_CODIGO', 'RHG_CODIGO' } }, RAX->( IndexKey( 1 ) ) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'RAXDETAIL' ):SetUniqueLine( { 'RAX_SEQUEN' } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oStruRHG := FWFormStruct( 2, 'RHG' )
	Local oStruRAX := FWFormStruct( 2, 'RAX' )

	// Cria a estrutura a ser usada na View
	Local oModel   := FWLoadModel( 'TRMA240' )
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	oStruRAX:RemoveField( 'RAX_CODIGO' )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RHG', oStruRHG, 'RHGMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_RAX', oStruRAX, 'RAXDETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 15 )
	oView:CreateHorizontalBox( 'INFERIOR', 85 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RHG', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RAX', 'INFERIOR' )

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_RAX', 'RAX_SEQUEN' )

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_RHG','Certificado')
	oView:EnableTitleView('VIEW_RAX','Posicionamento')

	// Liga a Edição de Campos na FormGrid
	oView:SetViewProperty( 'VIEW_RAX', "DISABLEDGRIDDETAIL", { 60 } )

Return oView

Static Function TRMA240PreVal(oModel, nline, cAcao)
	Local lRet			:= .T.
	Local oModelRHG		:= oModel:GetModel( 'RHGMASTER' )
	Local oModelRAX		:= oModel:GetModel( 'RAXDETAIL' )

	Local cRhgCabecCod	:= FwFldGet('RHG_CODIGO',,oModelRHG)
	Local cRaxCabecCod	:= FwFldGet('RAX_CODIGO',,oModelRAX)
	
	If cAcao <> 'DELETE' .AND. empty(cRaxCabecCod)
		FwFldPut ('RAX_CODIGO', cRhgCabecCod, nline, oModelRAX ,.T. ,.T.)
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TRMA240Commit

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TRMA240Commit(oModel)
	Local nCount, oWSCert, oCertificado
	Local nOldSet := SetVarNameLen(255)           		
			
	FWFormCommit(oModel)

	If SuperGetMv("MV_TRMINTG", NIL, .F.)
		oWSCert:= EPMWSNew("Certificado")
		
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .OR.;
		   oModel:GetOperation() == MODEL_OPERATION_INSERT
			oCertificado:= CertificadoWSService_CertificadoWSHolder():New()
			oCertificado:cCdExterno 									:= oModel:GetModel("RHGMASTER"):GetValue("RHG_CODIGO")
			oCertificado:cDescricao 									:= oModel:GetModel("RHGMASTER"):GetValue("RHG_DESC")
			oCertificado:oWSListaTextoCertificado						:= CertificadoWSService_ListaTextoCertificadoWSHolder():New()
			oCertificado:oWSListaTextoCertificado:oWSTextoCertificado	:= {}
	
			for nCount:= 1 to oModel:GetModel("RAXDETAIL"):GetQtdLine()
				oItem:= CertificadoWSService_TextoCertificadoWSHolder():New()			
	
				oItem:cCdCertificadoExterno := oModel:GetModel("RHGMASTER"):GetValue("RHG_CODIGO")
				oItem:cAlinhamentoX 		:= oModel:GetModel("RAXDETAIL"):GetValue("RAX_ALIGNX", nCount)
				oItem:nPosicaoX 			:= oModel:GetModel("RAXDETAIL"):GetValue("RAX_POSICX", nCount)
				oItem:nPosicaoY 			:= oModel:GetModel("RAXDETAIL"):GetValue("RAX_POSICY", nCount)
				oItem:cTexto 				:= oModel:GetModel("RAXDETAIL"):GetValue("RAX_TEXTO", nCount)
				
				AAdd(oCertificado:oWSListaTextoCertificado:oWSTextoCertificado, oItem)
			next
		
			If !oWSCert:InsertCertificado(oCertificado)
				Alert("Erro: " + GetWSCError())
			ElseIf !Empty(oWSCert:cReturn)
				Alert("Erro: " + oWSCert:cReturn)
			EndIf
		ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
			If !oWSCert:deleteCertificado( oModel:GetModel("RHGMASTER"):GetValue("RHG_CODIGO") )
				Alert("Erro: " + GetWSCError())
			ElseIf !Empty(oWSCert:cReturn)
				Alert("Erro: " + oWSCert:cReturn)
			EndIf			
		EndIf
	EndIf
	
	SetVarNameLen(nOldSet)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SeqRAX

@author Flavio Correa
@since 26/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function SeqRAX()
Local oModel		:= FWModelActive()
Local oModelRAX	:= oModel:GetModel("RAXDETAIL")
Local cSeq := ""

cSeq := StrZero(oModelRAX:GetLine()+1,2)

Return cSeq