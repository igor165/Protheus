#INCLUDE 'DPRA100.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} DPRA100
Tela de Cadastro de Produto Desenvolvido

@author Ana Carolina Tome Klock
@since 09/01/2012
@version P12
/*/
//------------------------------------------------------------------
Function DPRA100()
Local oBrowse
Local aValidaDPR := ValidaDPR()
Private oView

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA100', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG3')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Produto Desenvolvido'

SetKey(VK_F12,{|| Pergunte('DPRA100A',.T.)})

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//Se a função DPRFicha não existir lFicha fica com padrão Falso
	Local lFicha := .F.
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf
	ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0   // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA100' OPERATION 2 ACCESS 0   // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA100' OPERATION 3 ACCESS 0   // 'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA100' OPERATION 4 ACCESS 0   // 'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA100' OPERATION 5 ACCESS 0   // 'Excluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA100' OPERATION 8 ACCESS 0   // 'Imprimir'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA300' OPERATION 3 ACCESS 0   // 'Criar Versão'
	ADD OPTION aRotina Title STR0022 ACTION 'DPRFORMULA(2)'   OPERATION 6 ACCESS 0   // Fórmulas

	if lFicha
		ADD OPTION aRotina TITLE STR0019 ACTION 'DPRA210()' OPERATION 4 ACCESS 0 // Ficha Técnica
		ADD OPTION aRotina TITLE STR0020 ACTION 'PCPA104()' OPERATION 4 ACCESS 0 // Ficha Família Técnica
	Endif
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructDG3 := FWFormStruct( 1, 'DG3', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDG6 := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGF := FWFormStruct( 1, 'DGF', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGA := FWFormStruct( 1, 'DGA', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGK := FWFormStruct( 1, 'DGK', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGN
	Local oStructDGO
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('DPRA100', /*bPreValidacao*/, { |oModel| DPRA100POS( oModel ) }, { |oModel| DPRA100CMM ( oModel ) }, /*bCancel*/ )

	oStructDG3:AddField(;
		"Protótipo Temp"		,;	// [01]  C   Titulo do campo  - Produto
		"Protótipo Temp"		,;	// [02]  C   ToolTip do campo - Código do Produto
		"TMP_PROTOTI"	   		,;	// [03]  C   Id do Field
		"C"						,;	// [04]  C   Tipo do campo
		TamSX3("DG3_CDACPY")[1]	,;	// [05]  N   Tamanho do campo
		TamSX3("DG3_CDACPY")[2]	,;	// [06]  N   Decimal do campo
		NIL						,;	// [07]  B   Code-block de validação do campo
		NIL				   		,;	// [08]  B   Code-block de validação When do campo
		NIL						,; 	// [09]  A   Lista de valores permitido do campo
		.F.						,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
		{|| DG3->DG3_CDACPY}	,;	// [11]  B   Code-block de inicializacao do campo
		NIL						,; 	// [12]  L   Indica se trata-se de um campo chave
		NIL						,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.						 ;	// [14]  L   Indica se o campo é virtual
	)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'DG3MASTER', /*cOwner*/, oStructDG3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'DG6DETAIL', 'DG3MASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGFDETAIL', 'DG3MASTER', oStructDGF, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGADETAIL', 'DG3MASTER', oStructDGA, { |oModel| DPRA100DGA( oModel ) }, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGKDETAIL', 'DG3MASTER', oStructDGK, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG3_IDNV'   } }, DG6->(IndexKey(1)) )
	oModel:SetRelation( 'DGFDETAIL', { { 'DGF_FILIAL', 'xFilial( "DGF" )' }, { 'DGF_CDACDV', 'DG3_CDACDV' } }, DGF->(IndexKey(1)) )
	oModel:SetRelation( 'DGADETAIL', { { 'DGA_FILIAL', 'xFilial( "DGA" )' }, { 'DGA_CDACDV', 'DG3_CDACDV' } }, DGA->(IndexKey(1)) )
	oModel:SetRelation( 'DGKDETAIL', { { 'DGK_FILIAL', 'xFilial( "DGK" )' }, { 'DGK_CDACDV', 'DG3_CDACDV' } }, DGK->(IndexKey(1)) )

	oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'DGFDETAIL' ):SetUniqueLine( { 'DGF_CDJZ' } )
	oModel:GetModel( 'DGADETAIL' ):SetUniqueLine( { 'DGA_NRAS', 'DGA_DTPR' } )
	oModel:GetModel( 'DGKDETAIL' ):SetUniqueLine( { 'DGK_DSAB' } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0009 ) // 'Modelo de Dados de Produto Desenvolvido'

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'DG3MASTER' ):SetDescription( STR0010 ) // 'Dados de Produto Desenvolvido'
	oModel:GetModel( 'DG6DETAIL' ):SetDescription( STR0011 ) // 'Dados da Narrativa'
	oModel:GetModel( 'DGFDETAIL' ):SetDescription( STR0012 ) // 'Dados do Peso Critério'
	oModel:GetModel( 'DGADETAIL' ):SetDescription( STR0013 ) // 'Dados do Concorrente'
	oModel:GetModel( 'DGKDETAIL' ):SetDescription( STR0014 ) // 'Dados do Atributo Extra'

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'DGFDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DGADETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DGKDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)

	// Inclui a obrigatoriedade dos campos quando estiver integrando com o PCP
	If DPRIntegra() == 1
		oStructDG3:SetProperty( 'DG3_CDUNDE', MODEL_FIELD_OBRIGAT,  .T. )
		oStructDG3:SetProperty( 'DG3_CDDPPA', MODEL_FIELD_OBRIGAT,  .T. )
		oStructDG3:SetProperty( 'DG3_DSACDE', MODEL_FIELD_OBRIGAT,  .T. )
		oStructDG3:SetProperty( 'DG3_CDFA'  , MODEL_FIELD_TAMANHO , TamSX3('X5_DESCRI')[1]  )
		oStructDG3:SetProperty( 'DG3_CDUN'  , MODEL_FIELD_TAMANHO , TamSX3('AH_UNIMED')[1]  )
		oStructDG3:SetProperty( 'DG3_CDDPPA', MODEL_FIELD_TAMANHO , TamSX3('NNR_CODIGO')[1] )
		oStructDG6:SetProperty( 'DG6_IDNV'  , MODEL_FIELD_OBRIGAT,  .F. )
	Else
		oStructDG3:SetProperty( 'DG3_CDES'  , MODEL_FIELD_OBRIGAT,  .T. )
		oStructDG3:SetProperty( 'DG3_CDACPY', MODEL_FIELD_INIT 	 , { || SuperGetMV('MV_DPRPROT',.F.,'') } )
		oStructDG3:SetProperty( 'DG3_DSACPY', MODEL_FIELD_INIT	 , { || If (!INCLUI, Posicione('CZ3',1,xFilial('CZ3')+DG3->DG3_CDACPY,'CZ3_DSAC'), Posicione('CZ3',1,xFilial('CZ3')+SuperGetMV('MV_DPRPROT',.F.,''),'CZ3_DSAC')) } )
	EndIf

	// Cria a estrutura a ser usada no Modelo de Dados
	oStructDGN := FWFormStruct( 1, 'DGN', /*bAvalCampo*/, /*lViewUsado*/ )
	oStructDGO := FWFormStruct( 1, 'DGO', /*bAvalCampo*/, /*lViewUsado*/ )
	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'DGNDETAIL', 'DG3MASTER', oStructDGN, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGODETAIL', 'DGNDETAIL', oStructDGO, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'DGNDETAIL', { { 'DGN_FILIAL', 'xFilial( "DGN" )' }, { 'DGN_CDACDV', 'DG3_CDACDV' } }, DGN->(IndexKey(1)) )
	oModel:SetRelation( 'DGODETAIL', { { 'DGO_FILIAL', 'xFilial( "DGO" )' }, { 'DGO_CDACDV', 'DGN_CDACDV' }, { 'DGO_NRVRAC', 'DGN_NRVRAC' }, { 'DGO_CDMQ', 'DGN_CDMQ' }, { 'DGO_CDMD', 'DGN_CDMD' } }, DGO->(IndexKey(1)) )
	// Faz relaciomaneto entre os compomentes do model
	oModel:GetModel( 'DGNDETAIL' ):SetNoInsertLine()
	oModel:GetModel( 'DGNDETAIL' ):SetNoUpdateLine()
	oModel:GetModel( 'DGNDETAIL' ):SetNoDeleteLine()
	oModel:GetModel( 'DGODETAIL' ):SetNoInsertLine()
	oModel:GetModel( 'DGODETAIL' ):SetNoUpdateLine()
	oModel:GetModel( 'DGODETAIL' ):SetNoDeleteLine()
	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'DGNDETAIL' ):SetUniqueLine( { 'DGN_CDMQ', 'DGN_CDMD' } )
	oModel:GetModel( 'DGODETAIL' ):SetUniqueLine( { 'DGO_CDAB' } )
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'DGNDETAIL' ):SetDescription( STR0021 ) // Dados de Ficha Técnica
	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'DGNDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DGODETAIL' ):SetOptional(.T.)
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local lFicha := .F.
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel     := FWLoadModel( 'DPRA100' )
	// Cria a estrutura a ser usada na View
	Local oStructDG3 := FWFormStruct( 2, 'DG3' ) // Produto
	Local oStructDG6 := FWFormStruct( 2, 'DG6' ) // Narrativa
	Local oStructDGF := FWFormStruct( 2, 'DGF' ) // Critério
	Local oStructDGA := FWFormStruct( 2, 'DGA' ) // Concorrente
	Local oStructDGK := FWFormStruct( 2, 'DGK' ) // Atributo
	Local oStructDGN
	Local oStructDGO
	//Se a função DPRFicha não existir lFicha fica com padrão Falso
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_DG3', oStructDG3, 'DG3MASTER' )
	
	// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid( 'VIEW_DG6', oStructDG6, 'DG6DETAIL' )
	oView:AddGrid( 'VIEW_DGF', oStructDGF, 'DGFDETAIL' )
	oView:AddGrid( 'VIEW_DGA', oStructDGA, 'DGADETAIL' )
	If DPRIntegra() == 2
		oView:AddGrid( 'VIEW_DGK', oStructDGK, 'DGKDETAIL' )
	EndIf
	
	// Cria um box horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )
	
	// Cria Folder na view
	oView:CreateFolder( 'FOLDER', 'INFERIOR' )
	
	// Cria pastas nas folders
	oView:AddSheet( 'FOLDER', 'TAB01', STR0015 )   // 'Narrativa'
	oView:AddSheet( 'FOLDER', 'TAB02', STR0016 )   // 'Peso Critério'
	oView:AddSheet( 'FOLDER', 'TAB03', STR0017 )   // 'Concorrente'
	If DPRIntegra() == 2
		oView:AddSheet( 'FOLDER', 'TAB04', STR0018 )   // 'Atributo Extra'
	EndIf
	
	// Cria um box horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'DG6', 100, , ,'FOLDER', 'TAB01' )
	oView:CreateHorizontalBox( 'DGF', 100, , ,'FOLDER', 'TAB02' )
	oView:CreateHorizontalBox( 'DGA', 100, , ,'FOLDER', 'TAB03' )
	If DPRIntegra() == 2
		oView:CreateHorizontalBox( 'DGK', 100, , ,'FOLDER', 'TAB04' )
	EndIf
	
	// Relaciona o ID da View com o box para exibicao
	oView:SetOwnerView( 'VIEW_DG3', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_DG6', 'DG6' )
	oView:SetOwnerView( 'VIEW_DGF', 'DGF' )
	oView:SetOwnerView( 'VIEW_DGA', 'DGA' )
	If DPRIntegra() == 2
		oView:SetOwnerView( 'VIEW_DGK', 'DGK' )
	EndIf
	
	// Remove o campo repetido em tela
	oStructDG3:RemoveField( 'DG3_IDNV'   )
	oStructDG3:RemoveField( 'DG3_CDGRAC' )
	oStructDG6:RemoveField( 'DG6_IDNV'   )
	oStructDGF:RemoveField( 'DGF_CDACDV' )
	oStructDGF:RemoveField( 'DGF_DSACDV' )
	oStructDGA:RemoveField( 'DGA_CDACDV' )
	oStructDGA:RemoveField( 'DGA_DSACDV' )
	
	If DPRIntegra() == 1
		oStructDG3:RemoveField( 'DG3_CDES'   )
		oStructDG3:RemoveField( 'DG3_CDFACM' )
		oStructDG3:RemoveField( 'DG3_CDUNNG' )
		oStructDG3:RemoveField( 'DG3_VLPNRF' )
		oStructDG3:SetProperty( 'DG3_VLPNUN', MVC_VIEW_PICT, PesqPict('SB1', 'B1_CONV' ) )
		oStructDG3:SetProperty( 'DG3_VLPRRO', MVC_VIEW_PICT, PesqPict('SB1', 'B1_CUSTD') )
		oStructDG3:SetProperty( 'DG3_VLULEN', MVC_VIEW_PICT, PesqPict('SB1', 'B1_UPRC' ) )
	Else
		oStructDG3:RemoveField( 'DG3_CDUN2'  )
		oStructDG3:RemoveField( 'DG3_DSUN2'  )
		oStructDG3:RemoveField( 'DG3_VLPN2'  )
		oStructDG3:RemoveField( 'DG3_TPPNUN' )
		oStructDGK:RemoveField( 'DGK_CDACDV' )
		oStructDGK:RemoveField( 'DGK_VLAB2' )
	EndIf
	
	if FindFunction("DPRFicha") .AND. !DPRFicha(2)
		oStructDG3:RemoveField( 'DG3_CDFATD' )
		oStructDG3:RemoveField( 'DG3_DSFATD' )
	Endif
	
	oStructDG3:RemoveField('DG3_DSFOPJ')
	oStructDG3:RemoveField('DG3_DSFOCS')
	oStructDG3:RemoveField('DG3_DSFOUT')
	
	// Permite apenas visualizar campos virtuais
	oView:GetViewStruct('VIEW_DGA'):SetProperty('DGA_NRSQ', MVC_VIEW_CANCHANGE , .F.)
	
	If lFicha
		oStructDGN := FWFormStruct( 2, 'DGN' ) // Ficha Técnica
		oStructDGO := FWFormStruct( 2, 'DGO' ) // Ficha Técnica
		
		oView:AddGrid( 'VIEW_DGN', oStructDGN, 'DGNDETAIL' )
		oView:AddGrid( 'VIEW_DGO', oStructDGO, 'DGODETAIL' )
		
		oView:AddSheet( 'FOLDER', 'TAB05', STR0019 ) // Ficha Técnica
		
		oView:CreateHorizontalBox( 'DGN1', 50, , ,'FOLDER', 'TAB05' )
		oView:CreateHorizontalBox( 'DGN2', 50, , ,'FOLDER', 'TAB05' )
		
		oView:SetOwnerView( 'VIEW_DGN', 'DGN1' )
		oView:SetOwnerView( 'VIEW_DGO', 'DGN2' )
		
		oStructDGN:RemoveField( 'DGN_CDACDV' )
		oStructDGN:RemoveField( 'DGN_NRVRAC' )
		oStructDGN:RemoveField( 'DGN_DSVR' )
	
		oStructDGO:RemoveField( 'DGO_CDACDV' )
		oStructDGO:RemoveField( 'DGO_NRVRAC' )
		oStructDGO:RemoveField( 'DGO_CDMD' )
		oStructDGO:RemoveField( 'DGO_CDMQ' )
		
		oModel:GetModel('DGNDETAIL'):SetLoadFilter({{'DGN_NRVRAC' ,"''",1}})
	EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA100DGA
Realiza a pre-validacao da linha para a tabela DGA (Concorrentes)

@param 		oModel		Modelo de dados da tela

@return 	lRet		Se foi validado (.T.) ou não (.F.)

@author Ana Carolina Tome Klock
@since 28/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA100DGA( oModel )
Local lRet := .T.

// Cria um número para a sequência da tabela DGA
If Empty( oModel:GetValue('DGA_NRSQ') ) .And. DPRXVldMdl( oModel )
	lRet := DPRXSetVal( oModel, 'DGA_NRSQ' )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPR_CDACDE
Valida o Produto Destino

@param 		cCDACDE		Código do Produto Destino
@param		nValida		Identifica o tipo de validação (1=Validação do Sistema, 2=Modo Edição)

@return 	lRet		Informa se o campo está correto

@author Ana Carolina Tome Klock
@since 06/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPR_CDACDE( cCDACDE, nValida )
Local lRet 		:= .T.
Default nValida := 1

// X3_VALID
If nValida == 1

	dbSelectArea( 'DG3' )
	dbSetOrder(2)

	// Valida se outro Produto desenvolvido possui o mesmo Produto Destino
	If dbSeek( xFilial('DG3')+cCDACDE )
		If DG3->DG3_CDACDV != FwFldGet('DG3_CDACDV')
			DPRXError( 'DPRA100', 'DPRA100_REPLI1', 3 )
			lRet := .F.
		EndIf
	Else
		// Valida se não é o mesmo que o Produto Protótipo atual
		If FwFldGet('DG3_CDACPY') == cCDACDE .And. !Empty(cCDACDE)
			DPRXError( 'DPRA100', 'DPRA100_REPLI3', 3 )
			lRet := .F.

		// Valida se não é um Produto Configurado no PCP (Caso integrado)
		ElseIf DPRIntegra() == 1 .and. !Empty(A093VLDBASE( cCDACDE ))
	    
			dbSelectArea('CZ3')
			CZ3->(dbSetOrder(1))
			IF !CZ3->(dbSeek(xFilial('CZ3')+cCDACDE)) .AND. !Empty( ( cCDACDE ))
				DPRXError( 'DPRA100', 'DPRA100_CONFIG', 3 )
				lRet := .F.
			Endif
		Endif
	EndIf

// X3_WHEN
ElseIf nValida == 2

	dbSelectArea('DG0')
	dbSetOrder(3)
	// Impede alteração caso já tenha alguma versão liberada
	If ( dbSeek( xFilial('DG0')+FwFldGet("DG3_CDACDV")+'6' ) .Or. ;
		 dbSeek( xFilial('DG0')+FwFldGet("DG3_CDACDV")+'7' ) .Or. ;
		 dbSeek( xFilial('DG0')+FwFldGet("DG3_CDACDV")+'8' ) )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPR_CDACPY
Valida o Produto Protótipo

@param 		cCDACPY		Código do Produto Protótipo
@param 		cCDACDE		Código do Produto Destino
@return 	lRet		Informa se o campo está correto

@author Ana Carolina Tome Klock
@since 06/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPR_CDACPY( cCDACPY, cCDACDE, cCDACDV )
Local lRet := .T.

If !Empty(cCDACDE) .AND. AllTrim(cCDACPY) == AllTrim(cCDACDE)
	DPRXError( 'DPRA100', 'DPRA100_REPLI4', 3 )
	lRet := .F.
EndIf

dbSelectArea('DG3')
DG3->(dbSetOrder(2))
if DG3->(dbSeek(xFilial('DG3')+cCDACPY))
	While DG3->(!EOF()) .AND. DG3->DG3_CDACDE == cCDACPY
		if (IsInCallStack('DPRA100') .AND. DG3->DG3_CDACDV != cCDACDV) .OR.;
		    IsInCallStack('DPRA300')
			DPRXError( 'DPRA100', 'DPRA100_REPLI6', 3 )
			lRet := .F.	
			Exit
		Endif
		DG3->(dbSkip())
	End
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA100POS
Realiza a pos-validacao dos dados da tela

@param 		oModel		Modelo de dados da tela
@return 	lRet		Informa se a tela está pronta para realizar o Commit

@author Ana Carolina Tome Klock
@since 11/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA100POS( oModel )
Local nLine      :=  0
Local lRet       := .T.
Local nOpc       := oModel:GetOperation()
Local cCDACPY    := oModel:GetModel('DG3MASTER'):GetValue('DG3_CDACPY')
Local cCDACDV    := oModel:GetModel('DG3MASTER'):GetValue('DG3_CDACDV')
Local cCDACDE    := oModel:GetModel('DG3MASTER'):GetValue('DG3_CDACDE')
Local cTableDGN  := ""

// Limpa os campos de atributo
If nOpc == 3 .Or. nOpc == 4

	For nLine := 1 To oModel:GetModel('DGKDETAIL'):Length()
		oModel:GetModel('DGKDETAIL'):GoLine(nLine)
		dbSelectArea( 'DGB' )
		dbSetOrder(1)
		If dbSeek( xFilial( 'DGB' )+ FwFldGet('DGK_DSAB') )
			If DGB->DGB_TPAB != '1'
				oModel:ClearField('DGKDETAIL', 'DGK_VLAB1')
			EndIf
			If DGB->DGB_TPAB != '2'
				oModel:LoadValue('DGKDETAIL', 'DGK_VLABFM', 0)
			Else
				oModel:LoadValue('DGKDETAIL', 'DGK_VLAB2', oModel:GetModel('DGKDETAIL'):GetValue('DGK_VLABFM')*(10^DGB->DGB_NRFM) )
			EndIf
			If DGB->DGB_TPAB != '3'
				oModel:ClearField('DGKDETAIL', 'DGK_VLAB3')
			EndIf
			If DGB->DGB_TPAB != '4'
				oModel:ClearField('DGKDETAIL', 'DGK_VLAB4')
			EndIf
		EndIf
	Next

	// Define o valor da narrativa
	If !Empty( FwFldGet('DG6_DSNV') ) .And. Empty( FwFldGet('DG6_IDNV') )
		oModel:GetModel('DG6DETAIL'):LoadValue('DG6_IDNV', GETSXENUM('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 1 ) )
	 	oModel:GetModel('DG3MASTER'):LoadValue('DG3_IDNV', FwFldGet('DG6_IDNV') )
	EndIf
	
	// Verifica se o produto é protótipo em um produto desenvolvido
	DG3->(dbSetOrder(3))
	If DG3->(dbSeek( xFilial('DG3')+cCDACDE ))
		DPRXError( 'DPRA100', STR0024 + alltrim(DG3->DG3_CDACDV) + STR0025 + alltrim(cCDACDE) + STR0027, 4 ) // 'O produto desenvolvido ' ## ' utiliza ' ## ' como produto protótipo.'
		lRet := .F.
	Endif
		
	// Verifica se o produto é protótipo em uma versão
	if cCDACDE == Posicione("DG0",5,xFilial("DG0")+cCDACDE,"DG0_CDACPY")
		DPRXError( 'DPRA100', STR0024 + alltrim(DG0->DG0_CDACDV) + STR0026 + alltrim(DG0->DG0_NRVRAC) + STR0025 + alltrim(cCDACDE) + STR0027, 4 ) // 'O produto desenvolvido ' ## ' de versão ' ## ' utiliza ' ## ' como produto protótipo.'
		lRet := .F.
	Endif

EndIf

// Verifica se existe ficha técnica.
cTableDGN := GetNextAlias()
	
cQuery := "SELECT DG3_CDGE, DG3_CDFA "
cQuery += "FROM " + RetSqlName('DG3') + " DG3 "
cQuery += "  INNER JOIN " + RetSqlName('DGN') + " DGN ON DGN.DGN_FILIAL = DG3.DG3_FILIAL AND DGN.DGN_CDACDV = DG3.DG3_CDACDV "
cQuery += "WHERE DG3.DG3_FILIAL = '" + xFilial("DG3") + "' "
cQuery += "  AND DG3.DG3_CDACDV = '" + cCDACDV + "' "
cQuery += "  AND DG3.D_E_L_E_T_ = ' ' "
cQuery += "  AND DGN.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTableDGN, .F., .T.)

While (cTableDGN)->(!EOF())

	If oModel:GetModel('DG3MASTER'):GetValue('DG3_CDGE') != (cTableDGN)->(DG3_CDGE) .OR. oModel:GetModel('DG3MASTER'):GetValue('DG3_CDFA') != (cTableDGN)->(DG3_CDFA)
		DPRXError( 'DPRA100', 'DPRA100_ALTDES', 3 ) //"Não é permitido alterar Grupo de estoque e família pois existe ficha técnica para este produto."
		lRet := .F.
		Exit
	EndIf
	
	(cTableDGN)->(dbSkip())
End

(cTableDGN)->(dbCloseArea())

// -----Atualiza detalhes do Produto para informar se o mesmo é protótipo ou não
If DPRIntegra() == 1 .AND. lRet .AND. !Empty(cCDACPY)
	lRet := DPRA100SB5(nOpc, cCDACPY)
EndIf

Return lRet

//-------------------------------------------------------------------
// Realiza a busca do registro após commit
// Input: Model
//-------------------------------------------------------------------
Function DPRA100SB5(nOpc, cProt)
Local aDadosSB5  := {}
Local lRet       := .T.
Local cDescricao := ""
Private lMsErroAuto := .F.

IF nOpc == 3 .Or. nOpc == 4
	dbselectarea('SB1')
	SB1->(dbSetOrder(1))
	if dbSeek( xFilial('SB1')+cProt)
		cDescricao := PadR(SB1->B1_DESC, TamSx3('B5_CEME')[1]) 
	Endif

	dbSelectArea('SB5')
	SB5->(dbSetOrder(1))
	
	aDadosSB5 := {	{'B5_COD',     cProt,      NIL},;
					{'B5_PROTOTI', .T.,        NIL},;
					{'B5_CEME',    cDescricao, NIL}}
	
	MSExecAuto({|x,y| Mata180(x,y)},aDadosSB5,if(SB5->(dbSeek(xFilial('SB5')+cProt)),4,3))
	If lMsErroAuto
		MostraErro()
		lRet := .F.
	EndIf
Endif

Return lRet
//---------------------------------------------------------------------
/*Apresenta um grid com todas OPs abertas para seleção do que será
ou não regerada operações do roteiro*/
//---------------------------------------------------------------------
Static Function GridProVer(aVersoes,cProdDV,cProdProt)
	Local oDlgUpd, nI, oBtnCancelar, oBtnAvanca, oTexto, oBtnDetalhar, oList, oCheckBoxOP, oPanel3
	Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
	Local oNOk		:= LoadBitmap( GetResources(), "LBNO" )
	Local aVerGrid	:= {}
	Public lToggleCheckBoxOP
		
	For nI := 1 To Len(aVersoes)
		aAdd(aVerGrid,{.T.,AllTrim(aVersoes[nI][1]),AllTrim(aVersoes[nI][2])})
	Next
	
	DEFINE DIALOG oDlgUpd TITLE STR0028 FROM 0, 0 TO 22, 75 SIZE 550, 350 PIXEL//"Versões do Produto Desenvolvido"
		
	@ 005,005 GET oTexto VAR (STR0029 + " " + AllTrim(Str(Len(aVersoes))) + " " + STR0030) OF oDlgUpd MEMO PIXEL SIZE 270,20 NO BORDER //"Este produto possui" x "versões cadastradas sem produto protótipo informado e com situação "Em Aberto". Deseja alterar algumas destas versões?"
	oTexto:lReadOnly := .T.
	
	oPanel3 := TPanel():New( 25, 05, ,oDlgUpd, , , , , , 270, 120, .F.,.T. )	
	
	oList := TWBrowse():New( 05, 05, 260, 110,,{"",STR0031,STR0032},,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"Código Versão","Descrição Versão"
	
	@ 8, 6 CHECKBOX oCheckBoxOP VAR lToggleCheckBoxOP PROMPT "" WHEN PIXEL OF oPanel3 SIZE 015,015 MESSAGE ""
	oCheckBoxOP:bChange := {|| MarcaTodos(oList, lToggleCheckBoxOP)}
	lToggleCheckBoxOP := .T.	
	
	oList:SetArray(aVerGrid)
	oList:bLine := {|| {If(aVerGrid[oList:nAT,1],oOk,oNOK),aVerGrid[oList:nAt,2],aVerGrid[oList:nAT,3]}}
	oList:bLDblClick := {|| aVerGrid[oList:nAt,1] := !aVerGrid[oList:nAt,1], controlCheckAllState(oCheckBoxOP, aVerGrid)}
	
	@ 155,005 BUTTON oBtnDetalhar PROMPT STR0033 SIZE 60,14 ACTION VisVersao(cProdDV,aVerGrid,oList) OF oDlgUpd PIXEL//"Detalhar"
	@ 155,140 BUTTON oBtnCancelar PROMPT STR0034 SIZE 60,14 ACTION oDlgUpd:End() OF oDlgUpd PIXEL//"Cancelar"
	@ 155,210 BUTTON oBtnAvanca   PROMPT STR0035 SIZE 60,14 ACTION {|| AltVersoes(aVerGrid,cProdDV,cProdProt),oDlgUpd:End()} OF oDlgUpd PIXEL//"Confirmar"
	
	ACTIVATE DIALOG oDlgUpd CENTER
Return Nil
//--------------------------------------------------------------
Static Function VisVersao(cProdDV,aVerGrid,oList)

	Local oModelDG0	:= FWLoadModel('DPRA300')

	dbSelectArea("DG0")
	DG0->(dbSetOrder(1))
	DG0->(dbSeek(xFilial("DG0")+cProdDV+aVerGrid[oList:nAT][2]))

	oModelDG0:SetOperation(1)
	oModelDG0:Activate()

	FWExecView( "" , "DPRA300", /**/, /*oDlg*/, /*{|| .T. }*/ ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModelDG0 )

Return Nil
//--------------------------------------------------------------
Static Function AltVersoes(aVerGrid,cProdDV,cProdProt)
	Local nI
	Local lRet
	Local oModelDG0	:= FWLoadModel('DPRA300')

	dbSelectArea("DG0")
	DG0->(dbSetOrder(1))
	For nI := 1 To Len(aVerGrid)
		//Se a ordem de produção tiver sido marcada
		If  aVerGrid[nI][1]
			DG0->(dbSeek(xFilial("DG0")+cProdDV+aVerGrid[nI][2]))
			lRet := .T.
			Begin Transaction   
			
				oModelDG0:SetOperation(4)
				oModelDG0:Activate()

				oModelDG0:LoadValue('DG0MASTER','DG0_CDACDV',DG0->DG0_CDACDV)
				oModelDG0:LoadValue('DG0MASTER','DG0_DSVR',DG0->DG0_DSVR)
				oModelDG0:SetValue('DG0MASTER','DG0_CDACPY',cProdProt)
				
				If oModelDG0:VldData()
					oModelDG0:CommitData()
				Else
					aErro	:= oModelDG0:GetErrorMessage()
					lRet	:= .F.
					SFCMsgErro(aErro[6],"DPRA300")
				Endif
				oModelDG0:DeActivate()   
				
				If !lRet
					DisarmTransaction()
				EndIf
			End Transaction
		EndIf
	Next
Return Nil
//---------------------------------------------------------------------
/* A função terá comportamento de toggle se o lFixedBool não foi informado.*/
Static Function MarcaTodos( oBrw, lFixedBool )

	Local bSeek := {|x| x[1] == .F. }
	Local lSet  := .F.
	
	Default lFixedBool := Nil
	
	If lFixedBool != Nil
		lSet := lFixedBool
	ElseIf aScan(@oBrw:aArray, bSeek) > 0
		lSet := .T.
	EndIf
	
	aEval(@oBrw:aArray, {|x| x[1] := lSet})
	oBrw:Refresh()

Return NIL
//---------------------------------------------------------------------
/* Controladora do estado de checkbox */
Static Function controlCheckAllState(oCheckBox,aArray)
	
	Local bSeek := {|x| x[1] == .F. }
		
	@lToggleCheckBoxOP := If(aScan(aArray, bSeek) > 0, .F., .T.)
	oCheckBox:Refresh()
	
Return Nil
//-------------------------------------------------------------------
// Input: Model
//-------------------------------------------------------------------
Static Function DPRA100CMM (oModel)
	Local nOpc		:= oModel:GetOperation()  
	Local cProdDV	:= oModel:GetValue("DG3MASTER","DG3_CDACDV")
	Local cProdProt	:= oModel:GetValue("DG3MASTER","DG3_CDACPY")
	Local cProdAnt	:= oModel:GetValue("DG3MASTER","TMP_PROTOTI")
	Local aVersoes	:= {}

	If FWFormCommit( oModel ) // Salva os campos padrões do model

		//Verifica se possui versões em aberto sem protótipo informado(caso informe protótipo)
		If nOpc == 4 .And. !Empty(cProdProt) .And. cProdProt != cProdAnt
			dbSelectArea("DG0")
			DG0->(dbSetOrder(1))

			If DG0->(dbSeek( xFilial("DG0")+cProdDV))
		   		While DG0->( !EOF() ) .And. DG0->DG0_FILIAL+DG0_CDACDV == xFilial("DG0")+cProdDV

					If DG0->DG0_TPST == "1" .And. Empty(DG0->DG0_CDACPY)
						aAdd(aVersoes,{DG0->DG0_NRVRAC,DG0->DG0_DSVR})
					EndIf
					DG0->(dbSkip())
		   		End
			EndIf

			If Len(aVersoes) > 0
				GridProVer(aVersoes,cProdDV,cProdProt)
			EndIf
		EndIf

		//Realiza a busca do registro após commit
		If nOpc == 3 .Or. nOpc == 4

			dbSelectArea('DG3')
			DG3->(dbSetOrder(1))
			DG3->(dbSeek(xFilial('DG3')+oModel:GetValue('DG3MASTER','DG3_CDACDV')))

		Endif
	EndIf

Return .T.
