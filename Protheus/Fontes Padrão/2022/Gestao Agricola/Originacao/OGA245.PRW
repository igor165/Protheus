#INCLUDE "OGA245.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"

STATIC __lAutomato      := IiF(IsBlind(),.T.,.F.) //automação

/** {Protheus.doc} OGA245
Rotina para cadastro de Ordens de Trânsito e emissão de NFs de Trânsito

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@type function
*/
Function OGA245()
	Local oMBrowse := Nil
	Local bTeclaF12		:= SetKey( VK_F12, { || OGA245F12() } )

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NK2" )
	oMBrowse:SetDescription( STR0001 ) //"Ordens de Trânsito"
	oMBrowse:SetMenuDef( "OGA245" )
	oMBrowse:AddLegend( "NK2_STATUS='1'", "YELLOW"	,	X3CboxDesc( "NK2_STATUS", "1" ) ) //"Ordem de trânsito"
	oMBrowse:AddLegend( "NK2_STATUS='2'", "BLUE"	,	X3CboxDesc( "NK2_STATUS", "2" ) ) //"NF Trânsito emitida"
	oMBrowse:AddLegend( "NK2_STATUS='3'", "GREEN"	,	X3CboxDesc( "NK2_STATUS", "3" ) ) //"Romaneio vinculado"
	oMBrowse:AddLegend( "NK2_STATUS='4'", "RED"		,	X3CboxDesc( "NK2_STATUS", "4" ) ) //"NF Trânsito estornada"
	oMBrowse:AddLegend( "NK2_STATUS='5'", "GRAY"	,	X3CboxDesc( "NK2_STATUS", "5" ) ) //"Ordem cancelada"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

	SetKey( VK_F12, bTeclaF12 )

Return( )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA245 - Ordens de Trânsito
*/
Static Function MenuDef()
	Local aRotina := {}
	Local aRetPe  := {}
	Local nX  := 0

	aAdd( aRotina, { STR0007, "PesqBrw"       	, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0008, "ViewDef.OGA245"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0009, "ViewDef.OGA245"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0010, "ViewDef.OGA245"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0011, "ViewDef.OGA245"	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0012, "OGA245Cancel"  	, 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0013, "OGR245" 			, 0, 8, 0, Nil } ) //"Imprimir Ordem"
	aAdd( aRotina, { STR0028, "ViewDef.OGA245"	, 0, 8, 0, Nil } ) //"Imprimir Lista"
	aAdd( aRotina, { STR0014, "ViewDef.OGA245"	, 0, 9, 0, Nil } ) //"Copiar"
	aAdd( aRotina, { STR0015, "OGA245NFT"  		, 0, 4, 0, Nil } ) //"Emitir NFT"
	aAdd( aRotina, { STR0016, "OGA245EstNFT"  	, 0, 4, 0, Nil } ) //"Estornar NFT"
	aAdd( aRotina, { STR0057, "SPEDNFE"  		, 0, 4, 0, Nil } ) //"Sped.NfE"

	//Ponto de Entrada para adicionar novos botões na tela do OGA245 na parte do Browse
	IF ExistBlock("OG245MNU")
		aRetPe := ExecBlock("OG245MNU",.F.,.F.)
		If ValType(aRetPe) == "A" 
			For nX := 1 To Len(aRetPe)
				Aadd(aRotina,aRetPe[nX])
			Next nX 
		EndIf	
	EndIF

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA245 - Ordens de Trânsito
*/
Static Function ModelDef()
	Local oStruNK2	:= FWFormStruct( 1, "NK2" )
	Local oStruNK3	:= FWFormStruct( 1, "NK3" )
	Local oModel
	Local bPlacaVld := "ExistCpo('DA3',M->NK2_PLACA,3) .OR. VAZIO()"

	oStruNK2:SetProperty( "NK2_CODENT" , MODEL_FIELD_VALID	, {| oField | ValEntidade( oField, 1 )	} )
	oStruNK2:SetProperty( "NK2_LOJENT" , MODEL_FIELD_VALID	, {| oField | ValEntidade( oField, 2 )	} )
	If GetRpoRelease() <= "12.1.033" 
		oStruNK2:SetProperty( 'NK2_PLACA'  , MODEL_FIELD_OBRIGAT , .F.)
		oStruNK2:SetProperty( 'NK2_PLACA'  , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bPlacaVld))
	EndIf
	oStruNK3:SetProperty( "NK3_CODPRO" , MODEL_FIELD_VALID	, {| oField | ValCodPro( oField ) 		} )

	oStruNK3:RemoveField( "NK3_CODIGO" )

	// cIdField 			Nome (ID) do campo de origem;
	// cTargetIdField 	Nome (ID) do campo de destino;
	// bPre 				Bloco de código de validação da execução do gatilho;
	// bSetValue 			Bloco de código de execução do gatilho;
	oStruNK3:AddTrigger( "NK3_QUANT", "NK3_TOTAL",   {|| .T. }, {| x | TrgTotItem( x ) } )
	oStruNK3:AddTrigger( "NK3_PRECO", "NK3_TOTAL",   {|| .T. }, {| x | TrgTotItem( x ) } )

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "OGA245", /*bPre*/, /*bPost*/{| oMod | PosModelo( oMod ) }, /*bCommit*/ , /*bCancel*/  )

	oModel:SetVldActivate( { |oMod| OGA245VLD( oMod ) } )
	oModel:SetDescription( STR0001 ) //"Ordens de Trânsito"

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields( "NK2MASTER", /*cOwner*/, oStruNK2, {|oFieldModel, cAction, cIDField, xValue| validPre(oFieldModel, cAction, cIDField, xValue)}, , /*bLoad */ {|oMod, lCopy| OGA245LOAD(oMod, lCopy)} )
	oModel:SetPrimaryKey( { "NK2_FILIAL", "NK2_CODIGO" } )
	oModel:GetModel( "NK2MASTER" ):SetDescription( STR0017 ) //"Cabeçalho da Ordem de Trânsito"

	// cId				Identificador do modelo
	// cOwner			Identificador superior do submodelo
	// oModelStruct	Objeto com a estrutura de dados 	 
	// bLinePre		Bloco de Código de pré-edição da linha do grid.
	// bLinePost		Bloco de código de pós-validação da linha do grid, equivale ao "LINHAOK".
	// bPre			Bloco de Código de pré-validação do submodelo. 
	// bPost			Bloco de código de pós-validação dO submodelo. Equivale ao "TUDOOK".
	// bLoad			Bloco de carga dos dados do submodelo. 
	oModel:AddGrid( "NK3DETAIL", "NK2MASTER", oStruNK3, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
	oModel:SetRelation( "NK3DETAIL", { { "NK3_FILIAL", "xFilial( 'NK3' )" }, { "NK3_CODIGO", "NK2_CODIGO" } }, NK3->( IndexKey( 1 ) ) )
	oModel:GetModel( "NK3DETAIL" ):SetDescription( STR0018 ) //"Itens da Ordem de Trânsito"

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA245 - Ordens de Trânsito
*/
Static Function ViewDef()
	Local oStruNK2 := FWFormStruct( 2, "NK2" )
	Local oStruNK3 := FWFormStruct( 2, "NK3" )
	Local oModel   := FWLoadModel( "OGA245" )
	Local oView    := FWFormView():New()

	oStruNK3:RemoveField( "NK3_CODIGO" )

	oView:SetModel( oModel )

	oView:AddField( "VIEW_NK2", oStruNK2, "NK2MASTER" )
	oView:AddGrid( "VIEW_NK3", oStruNK3, "NK3DETAIL" )

	oView:AddIncrementField( "VIEW_NK3", "NK3_ITEM" )

	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 50, "TELANOVA" )
	oView:CreateHorizontalBox( "INFERIOR" , 50, "TELANOVA" )

	oView:SetOwnerView( "VIEW_NK2", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NK3", "INFERIOR" )

	oView:EnableTitleView( "VIEW_NK2" )
	oView:EnableTitleView( "VIEW_NK3" )

	oView:SetCloseOnOk( {||.t.} )

	If (ExistBlock("OGA245BUT"))
		oView := ExecBlock("OGA245BUT",.F.,.F.,{oView})
	EndIf

Return( oView )

/** {Protheus.doc} ValEntidade
Validação e gatilho no campo Cod.Entidade e Loja

@param: 	oNK2 - modelo de dados
@return:	lRetorno
@author: 	Marlon Richard Trettin
@since: 	18/09/14
@Uso: 		OGA245
*/
Static Function ValEntidade( oNK2, nOper )
	Local aAreaAtu	:= GetArea()
	Local lRetorno 	:= .T.

	Local cCodEnt		:= oNK2:GetValue( "NK2_CODENT" )
	Local cLojEnt		:= oNK2:GetValue( "NK2_LOJENT" )

	Local cChavCabBusca := iIf( nOper==1, cCodEnt, cCodEnt + cLojEnt )

	dbSelectArea( "NJ0" ) // Cadastro de entidades
	dbSetOrder( 1 )

	If dbSeek( xFilial( "NJ0" ) + cChavCabBusca )
		oNK2:SetValue( "NK2_LOJENT", NJ0->( NJ0_LOJENT ) )
		oNK2:SetValue( "NK2_NOMENT", NJ0->( NJ0_NOME ) )
		//oView:Refresh()
	Else
		Help( ,, STR0020,, STR0052+cChavCabBusca, 1, 0,) //"HELP"##"Não foi possível localizar a Entidade no cadastro de Entidades (tabela NJ0): "######
		lRetorno := .f.
	EndIf

	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} ValCodPro
Validação e gatilho no campo Cód. Produto

@param: 	oNK3 - modelo de dados
@return:	lRetorno
@author: 	Marlon Richard Trettin
@since: 	18/09/14
@Uso: 		OGA245
*/
Static Function ValCodPro( oNK3 )
	Local aAreaAtu	:= GetArea()
	Local lRetorno 	:= .T.

	Local cCodPro		:= oNK3:GetValue( "NK3_CODPRO" )

	dbSelectArea( "SB1" ) // Produtos
	dbSetOrder( 1 )
	If dbSeek( xFilial( "SB1" ) + cCodPro )

		oNK3:SetValue( "NK3_DESPRO", SubStr( SB1->( B1_DESC ), 1, TamSX3("NK3_DESPRO")[1] ) )
		oNK3:SetValue( "NK3_UM1PRO", SB1->( B1_UM ) )

		//oView:Refresh()

	Else
		Help( ,, STR0020,, STR0055+cCodPro, 1, 0,) //"HELP"##"Não foi possível localizar o Produto no cadastro de Produtos (tabela SB1): "######
		lRetorno := .f.
	EndIf

	RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} TrgTotItem
Trigger para calcular o valor total do item

@param: 	oParModel - modelo de dados
@return:	nTotal
@author: 	Marlon Richard Trettin
@since: 	08/06/2010
@Uso: 		OGA245
*/
Static Function TrgTotItem( oParModel )
	Local oModel		:= oParModel:GetModel()
	Local oNK3			:= oModel:GetModel( "NK3DETAIL" )
	Local nQuant		:= oNK3:GetValue( "NK3_QUANT" )
	Local nPreco		:= oNK3:GetValue( "NK3_PRECO" )
	Local nTotal		:= oNK3:GetValue( "NK3_TOTAL" )

	nTotal := nQuant * nPreco

	oNK3:SetValue( "NK3_TOTAL", nTotal )

	//oView:Refresh()

Return( nTotal )


/** {Protheus.doc} PosModelo
Pós validação do modelo, antes da gravação.

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	21/10/2014
@Uso: 		OGA245 - Ordens de Transito
*/
Static Function PosModelo( oParModel )
	Local aAreaAtu		:= GetArea()
	Local lRetorno		:= .t.
	Local nX 			:= 0
	Local oModel		:= oParModel:GetModel()
	Local nOperation	:= oModel:GetOperation()
	Local oNK2			:= oModel:GetModel( "NK2MASTER" )
	Local oNK3			:= oModel:GetModel( "NK3DETAIL" )
	Local cCodCtr		:= oNK2:GetValue( "NK2_CODCTR" )
	Local cCodProCtr	:= Posicione( "NJR", 1, xFilial( "NJR" ) + cCodCtr, "NJR_CODPRO" ) // Busca o produto do contrato

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		If !Empty( cCodCtr ) // Se foi informado o contrato

			If oNK3:length() > 0 // Se possuir alguma linha no grid

				For nX := 1 to oNK3:length()	
					oNK3:GoLine( nX ) // Posiciona na linha do grid
					If !oNK3:IsDeleted( nX )
						If cCodProCtr <> oNK3:GetValue( "NK3_CODPRO" ) // Se produto diferente do contrato
							Help( ,, STR0020,, STR0047+oNK3:GetValue( "NK3_CODPRO" )+STR0048+cCodProCtr, 1, 0,) //"HELP"##"O produto informado "######" não pode ser diferente do produto do contrato "######
							lRetorno := .f.
							Exit
						EndIf
					EndIf
				Next nX

			Else // Senão, se não possuir nenhuma linha no grid, dá erro
				Help( ,, STR0020,, STR0049, 1, 0,) //"HELP"##"Você deve informar ao menos uma linha no grid 'Itens da Ordem de Transito'"
				lRetorno := .f.
			EndIf
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} OGA245VLD
Função que valida a execução de operações de Alteração ou Exclusão.

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA245 - Ordens de Trânsito
*/
Function OGA245VLD( oModel )

	Local nOpc := oModel:GetOperation()

	/* --- Alteração --- */
	// Só é possível alterar O.T. com STATUS = '1' 
	If nOpc == MODEL_OPERATION_UPDATE .And. NK2->( NK2_STATUS ) <> "1"
		Help( ,, STR0020,, STR0019, 1, 0,) //"HELP"##"Operação não permitida para Ordens de Trânsito com STATUS diferente de '1' (Ordem de Trânsito)."
		Return( .F. )
	EndIf

	/* --- Exclusão  --- */
	// Só é possível excluir O.T. com STATUS = '1' 
	If nOpc == MODEL_OPERATION_DELETE .And. NK2->( NK2_STATUS ) <> "1"
		Help( ,, STR0020,, STR0019, 1, 0,) //"HELP"##"Operação não permitida para Ordens de Trânsito com STATUS diferente de '1' (Ordem de Trânsito)."
		Return( .F. )
	EndIf

Return( .T. )


/** {Protheus.doc} OGA245LOAD
Função de tratamento para carga dos dados para o formulário.

@param: 	oModel		Objeto de Model do MVC
lCopy		.T. ou .F. = indica se está sendo efetuada a cópia de um registro ou não
@return:	aLoad 		:= {{},} // Array de retorno com os valores dos campos da tela (Ex.: { { '01', 'XXXXX', 999 }, Recno()} )
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA245 - Ordens de Trânsito
*/
Static Function OGA245LOAD( oModel, lCopy )

	Local aLoad		:= {{},} // Array de retorno com os valores dos campos da tela (Ex.: { { '01', 'XXXXX', 999 }, Recno()} )
	Local aFieldsNK2	:= oModel:GetStruct():aFields
	Local nOpc			:= oModel:GetOperation()
	Local nX 			:= 0
	Local xValue
	Local cFieldsNotCopy := "NK2_CODIGO,NK2_DATINC,NK2_STATUS,NK2_NUMNFT,NK2_SERNFT,NK2_DATNFT,NK2_ROMANE,NK2_NUENFT,NK2_SEENFT,NK2_DTENFT"

	For nX := 1 to Len( aFieldsNK2 )

		// Se campo VIRTUAL, ou campo pertence ao grupo de campos que não devem ser copiados
		If aFieldsNK2[nX][14] .Or. ( AllTrim( aFieldsNK2[nX][3] ) $ cFieldsNotCopy .And. ( lCopy .Or. nOpc == 3 ) )
			xValue := oModel:GetValue( aFieldsNK2[nX][3] )	// Inicializa com o padrão
		Else
			xValue := NK2->( &( aFieldsNK2[nX][3] ) ) 			// Inicializa com os dados da tabela
		EndIf

		// Adiciona o valor do campo no array aLoad	
		aAdd( aLoad[1], xValue )

	Next nX

	If nOpc == 3 .Or. lCopy 	// Se for Inclusão ou Cópia
		aLoad[2] := 0	 					// recno = 0
	Else
		aLoad[2] := NK2->( Recno() ) 	// pega o recno atual
	EndIf

Return aLoad


/** {Protheus.doc} OGA245Cancel
Cancela uma Ordem de Trânsito

@param: 	oModel - Modelo de Dados
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		SIGAAGR
*/
Function OGA245Cancel()

	Local aSaveArea := GetArea()
	Local lRet      := .t.

	dbSelectArea( "NK2" )
	If NK2->( NK2_STATUS ) <> "1"
		Help( ,, STR0020,, STR0019, 1, 0,) //"HELP"##"Operação não permitida para Ordens de Trânsito com STATUS diferente de '1' (Ordem de Trânsito)."
		Return( .F. )
	Else
		If !__lAutomato
			lRet := MsgNoYes( STR0029 +Chr(13)+"["+NK2->NK2_CODIGO+"]" ) //"Confirma o cancelamento da Ordem de Trânsito posicionada?"
		EndIf
		If lRet
			RecLock( "NK2", .f. )
			NK2->NK2_STATUS := "5" // Cancelada
			MsUnLock()

			MsgInfo( STR0030 ) //"Ordem de Trânsito cancelada."
		EndIf
	EndIf

	RestArea( aSaveArea )
Return( .T. )


/** {Protheus.doc} OGA245NFT
Gerar NF de Trânsito

@param: 	oModel - Modelo de Dados
@return:	lRetorno - .t. ou .f.
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		SIGAAGR
*/
Function OGA245NFT()

	Local aSaveArea := GetArea()
	Local aCab 		:= {}
	Local aItens 		:= {}
	Local aLinha		:= {}
	Local cTpFrete  := 'S'
	/** Variaveis do Cabeçalho do Documento de Entrada */
	Local cFormulario	:= "S"
	Local cTipo		:= "N"
	Local cFornecedor	:= ""
	Local cLoja		:= ""
	Local cEspecie		:= "SPED"
	Local cUF			:= ""
	Local cCondPg		:= SuperGetMV( "MV_CONDPAD", .f., "001" )
	Local cCodDocF1	:= NK2->( NK2_CODIGO )
	Local cItemSeq    := Space( TamSX3( "NK3_ITEM" )[1] )

	/** Variaveis dos Itens do Documento de Entrada */
	Local cTes			:= GETMV( "MV_TESNFT")
	Local cLocal		:= ""

	Local cSerie		:= CriaVar("F1_SERIE",.f. )
	Local cNumero		:= CriaVar("F1_DOC"	,.f. )
	Local aRetPe		:= {}

	/*
	Private cSerie		:= CriaVar("F1_SERIE",.f. )
	Private cNumero		:= CriaVar("F1_DOC",.f. )
	*/	
	Private lMsErroAuto 	:= .f.

	If NK2->( NK2_STATUS ) <> "1"
		Help( ,, STR0020,, STR0019, 1, 0,) //"HELP"##"Operação não permitida para Ordens de Trânsito com STATUS diferente de '1' (Ordem de Trânsito)."
		RestArea( aSaveArea )
		Return( .F. )
	EndIf

	//Não permite usar contrato cancelado na ordem de transito - DAGROGAP-256
	DbSelectArea("NJR")
	DbSetOrder(1)
	If ( DbSeek( xFilial("NJR")+NK2->( NK2_CODCTR )))
		If NJR->(NJR_STATUS) = "E"
			Help( ,, STR0020,, STR0059, 1, 0,) //"HELP"##"O contrato vinculado a ordem de transito encontra-se cancelado."  ######
			NJR->(DbCloseArea())
			Return( .F. )
		EndIf
		
		If NK2->(ColumnPos('NK2_TPFRET')) > 0 
			cTpFrete	:= NJR->NJR_TPFRET  	//--Vai pegar o Tipo de frete do contrato 
		EndIf
	EndIf

	// Busca o código do fornecedor no cadastro de entidades
	NJ0->( dbSetOrder( 1 ) )
	If NJ0->( dbSeek( xFilial( "NJ0" ) + NK2->( NK2_CODENT + NK2_LOJENT ) ) )

		DbSelectArea("SA2")
		DbSetOrder(1)
		If !( DbSeek( xFilial("SA2")+NJ0->( NJ0_CODFOR )+NJ0->( NJ0_LOJFOR ) ) )
			Help( ,, STR0020,, STR0039 + NK2->( NK2_CODENT ) +"-"+ NK2->( NK2_LOJENT ) , 1, 0,) //"HELP"##//"Não foi encontrado cadastro de Fornecedor associado à Entidade. Verifique os campos Fornecedor e Loja no cadastro da Entidade "
			RestArea( aSaveArea )
			Return( .F. )
		EndIf
		cFornecedor	:= NJ0->( NJ0_CODFOR )
		cLoja 		 	:= NJ0->( NJ0_LOJFOR )
		cUF				:= Posicione( "SA2", 1, xFilial( "SA2" ) + NJ0->( NJ0_CODFOR + NJ0_LOJFOR ), "A2_EST" )

	Else
		Help( ,, STR0020,, STR0031 + NK2->( NK2_CODENT ) +"-"+ NK2->( NK2_LOJENT ), 1, 0,) //"HELP"##//"Não foi possível localizar o cadastro da Entidade "
		RestArea( aSaveArea )
		Return( .F. )
	EndIf

	If Empty( cTes )
		Help( ,, STR0020,, STR0032, 1, 0,) //"HELP"##//"Cadastre o Tipo de Entrada para NF de Trânsito através da tecla F12."
		RestArea( aSaveArea )
		Return( .F. )
	EndIf

	If !__lAutomato
		If !MsgYesNo( STR0033 +Chr(13)+"["+NK2->NK2_CODIGO+"]" ) //"Confirma a geração da NF de Trânsito para a Ordem de Trânsito posicionada?"
			MsgInfo( STR0034 ) //"Operação abortada!"
			RestArea( aSaveArea )
			Return( .F. )
		EndIf
	EndIf
	

	/**Função utilizada para preenchimento de Número/Serie do Documento**/
	If cFormulario == "S"

		If Empty(cSerie) .and. (NK2->(FieldPos("NK2_DOCSER")) > 0)
			cSerie := Alltrim(NK2->NK2_DOCSER)	
		EndIf
		If Empty(cSerie)
			cSerie	 := SuperGetMV("MV_OGASERE", .f., " ")	
		EndIf

		If Empty(cSerie)
			If .Not. SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
				MsgInfo( STR0034 ) //"Operação abortada!"
				RestArea( aSaveArea )
				Return( .F. )
			EndIf
		EndIf

		If Empty(cNumero) .and. SuperGetMV("MV_TPNRNFS", .f., " ") <> "3"
			cNumero := NxtSX5Nota(cSerie)

			If !Len(cNumero)= TamSx3('F1_DOC')[1]
				cNumero := PadR(Alltrim(cNumero),TamSx3('F1_DOC')[1] )
			EndIf	
		EndIf
	EndIf

	If !Len(cSerie)= TamSx3('F1_SERIE')[1]
		cSerie := PadR(Alltrim(cSerie),TamSx3('F1_SERIE')[1] )
	EndIf
	
	If NK2->(ColumnPos('NK2_TPFRET')) > 0 
		cTpFrete 	:= IF( !Empty(NK2->NK2_TPFRET), NK2->NK2_TPFRET, cTpFrete )
	EndIf

	// Monta o cabecalho
	aAdd( aCab, { "F1_TIPO"		, cTipo 		} )
	aAdd( aCab, { "F1_FORMUL"	, cFormulario	} )
	aAdd( aCab, { "F1_SERIE"  	, cSerie		} )
	aAdd( aCab, { "F1_DOC"		, cNumero		} )
	aAdd( aCab, { "F1_EMISSAO"	, dDataBase	} )
	aAdd( aCab, { "F1_FORNECE"	, cFornecedor	} )
	aAdd( aCab, { "F1_LOJA"		, cLoja		} )
	aAdd( aCab, { "F1_ESPECIE"	, cEspecie		} )
	aAdd( aCab, { "F1_CODROM"	, cCodDocF1	} )      
	aAdd( aCab, { "F1_COND"		, cCondPg		} )
	aAdd( aCab, { "F1_EST"		, cUF			} )
	aadd( aCab, { "F1_TPFRETE"	, cTpFrete		} ) //C=CIF;F=FOB;T=Por conta terceiros;S=Sem frete                                                                                   
	If !( Empty( NK2->( NK2_PLACA ) ) )
		aAdd( aCab, { "F1_PLACA"		, NK2->( NK2_PLACA )	} )
	EndIf
	If !( Empty( NK2->( NK2_CODTRA ) ) )
		aAdd( aCab, { "F1_TRANSP"	, NK2->( NK2_CODTRA )	} )
	EndIf
	If !( Empty( NK2->( NK2_OBS ) ) )
		aAdd( aCab, { "F1_MENNOTA"	, NK2->( NK2_OBS ) 	} )
	EndIf

	// Monta os itens
	dbSelectArea( "NK3" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "NK3" ) + NK2->( NK2_CODIGO ) )
	While .Not. NK3->( Eof() ) .And. NK3->( NK3_FILIAL + NK3_CODIGO ) == xFilial( "NK3" ) + NK2->( NK2_CODIGO )

		cLocal		:= Posicione( "SB1", 1, xFilial( "SB1" ) + NK3->( NK3_CODPRO  ), "B1_LOCPAD" )
		cItemSeq 	:= StrZero( Val( NK3->( NK3_ITEM ) ), TamSX3( "D1_ITEM" )[1] )

		aLinha := {}
		aAdd( aLinha, { "D1_ITEM"		, cItemSeq				, Nil } )
		aAdd( aLinha, { "D1_COD"			, NK3->( NK3_CODPRO )	, Nil } )
		aAdd( aLinha, { "D1_QUANT"		, NK3->( NK3_QUANT )	, Nil } )
		aAdd( aLinha, { "D1_VUNIT"		, NK3->( NK3_PRECO )	, Nil } )
		aAdd( aLinha, { "D1_TOTAL"		, NK3->( NK3_TOTAL )	, Nil } )
		aAdd( aLinha, { "D1_LOCAL"		, cLocal				, Nil } )
		aAdd( aLinha, { "D1_TES"			, cTes					, Nil } )
		aAdd( aLinha, { "D1_CTROG"		, NK2->( NK2_CODCTR )	, Nil } )
		If !( Empty( NK2->( NK2_PLACA ) ) )
			aAdd( aLinha, { "D1_PLACA"		, NK2->( NK2_PLACA )	, Nil } )
		EndIf
		aAdd( aItens, aLinha )

		NK3->( dbSkip() )
	EndDo

	// Ponto de entrada inserido para controlar dados especificos do cliente 16/12/2015
	// Antes de Chamar a Mata103
	If ExistBlock("OG245ANF")
		aRetPe := ExecBlock("OG245ANF",.F.,.F.,{aCab,aItens})
		If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
			aCab	:= aClone(aRetPe[1])
			aItens	:= aClone(aRetPe[2])
		EndIf
		/* Exemplo do PE
		#include 'protheus.ch'
		#include 'parmtype.ch'

		User Function OG245ANF()
		Local aCab 		:= aClone(PARAMIXB[1])
		Local aItens 	:= aClone(PARAMIXB[2])
		Local aRet := {} //Customizações do usuário

		Local nPMenNf	:=  aSCAN(aCab, {|aCab| aCab[1] == "F1_MENNOTA" })

		IF nPMenNf > 0 // Ja stá no array
		aCab[nPmenNf,1] += 'Mensagem do PE og245anf'  // 
		Else // Ainda n. se encontra no Array Adicionar
		aAdd( aCab, { "F1_MENNOTA"	, 'Mensagem do PE og245anf'	} )
		EndIF

		aRet := {aCab,aItens}

		Return aRet
		*/
	EndIf

	// Gera a Nota de Transito
	MsgRun( STR0044, STR0043	, {|| MSExecAuto( { | x, y, z | Mata103( x, y, z ) }, aCab, aItens, 3 ) } ) //"Gerando Nota de Trânsito..."##"AGUARDE"

	If lMsErroAuto
		MostraErro()
		ROLLBACKSX8()
		RestArea( aSaveArea )
		Return( .F. )
	Else
		CONFIRMSX8()
		// Atualiza o número da NF de Trânsito gerada na tabela de Ordens de Trânsito
		NK2->( RecLock( "NK2", .f. ) )
		NK2->( NK2_NUMNFT ) := SF1->( F1_DOC     )
		NK2->( NK2_SERNFT ) := SF1->( F1_SERIE   )
		NK2->( NK2_DATNFT ) := SF1->( F1_EMISSAO )
		NK2->( NK2_STATUS ) := "2" // 2=NF Transito Emitida
		NK2->( msUnLock() )

		//Ponto de Entrada após a transmissão da Nota de Transito e gravação das informações da NK2
		IF ExistBlock("OG245TNFE")	
			//Tabelas NK2 e SF1 posicionadas.
			ExecBlock("OG245TNFE",.F.,.F.,{SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_EMISSAO})
		EndIF

	EndIf

	RestArea( aSaveArea )
Return( .T. )


/** {Protheus.doc} OGA245EstNFT
Gerar Estorno de NF de Trânsito

@param: 	oModel - Modelo de Dados
@return:	lRetorno - .t. ou .f.
@author: 	Marlon Richard Trettin
@since: 	05/09/2014
@Uso: 		SIGAAGR
*/
Function OGA245EstNFT()

	Local aSaveArea := GetArea()
	Local aCab 		:= {}
	Local aItens 		:= {}
	Local aLinha		:= {}
	Local aNFS			:= {}
	Local cTpFrete      := "S"
	/** Variaveis do Cabeçalho do Documento de Entrada */
	Local cCliente		:= ""
	Local cLoja		:= ""
	Local cCondPg		:= SuperGetMV( "MV_CONDPAD", .f., " " )

	/** Variaveis dos Itens do Documento de Entrada */
	Local cTes			:= GETMV( "MV_TESNFET", .f., " " )
	Local cLocal		:= ""
	Local cItemSeq    := Space( TamSX3( "NK3_ITEM" )[1] )

	//Vars Tratamento Vinculo Com o PV
	Local aVincCabPV    := {}
	Local aVincItePV  	:= {}
	Local lVinculou		:= .f.
	Local lRetorno      := .t.
	Local cModAtu       := cModulo
	Local nModAtu       := nModulo

	Private cSerie			:= Space(03)
	Private cNumero		:= Space(09)
	Private lMsErroAuto 	:= .f.

	Private cNumPV := Criavar('C5_NUM',.F.)    //GetSxeNum("SC5","C5_NUM") retirado daqui pq o c5_num fica travado se abandonar a rotina.

	If NK2->( NK2_STATUS ) <> "2"
		Help( ,, STR0020,, STR0035, 1, 0,) //"HELP"##"Operação não permitida para Ordens de Trânsito com STATUS diferente de '2' (NF Trânsito emitida)."
		RestArea( aSaveArea )
		Return( .F. )
	EndIf

	If Empty( cCondPg )
		Help( ,, STR0020,, STR0056, 1, 0,) //"HELP"##"Condição de pagamento padrão não cadastrada no parâmetro MV_CONDPAD."
		RestArea( aSaveArea )
		Return( .F. )
	EndIf

	// Busca o código do fornecedor no cadastro de entidades
	NJ0->( dbSetOrder( 1 ) )
	If NJ0->( dbSeek( xFilial( "NJ0" ) + NK2->( NK2_CODENT + NK2_LOJENT ) ) )

		DbSelectArea("SA1")
		DbSetOrder(1)
		If !( DbSeek( xFilial("SA1")+NJ0->( NJ0_CODCLI )+NJ0->( NJ0_LOJCLI ) ) )
			Help( ,, STR0020,, STR0038 + NK2->( NK2_CODENT ) +"-"+ NK2->( NK2_LOJENT ) , 1, 0,) //"HELP"##//"Não foi encontrado cadastro de Cliente associado à Entidade. Verifique os campos Cliente e Loja no cadastro da Entidade "
			RestArea( aSaveArea )
			Return( .F. )
		EndIf
		cCliente		:= NJ0->( NJ0_CODCLI )
		cLoja 		 	:= NJ0->( NJ0_LOJCLI )

	Else
		Help( ,, STR0020,, STR0031 + NK2->( NK2_CODENT ) +"-"+ NK2->( NK2_LOJENT ), 1, 0,) //"HELP"##//"Não foi possível localizar o cadastro da Entidade "
		RestArea( aSaveArea )
		Return( .F. )
	EndIf


	If Empty( cTes )
		Help( ,, STR0020,, STR0037, 1, 0,) //"HELP"##//"Cadastre o Tipo de Saída para estorno de NF de Trânsito através da tecla F12."
		RestArea( aSaveArea )
		Return( .F. )
	EndIf

	If !__lAutomato
		If !MsgYesNo( STR0036 +Chr(13)+"["+NK2->NK2_NUMNFT+" / "+NK2->NK2_SERNFT+"]" ) //"Confirma o Estorno da NF de Trânsito?"
			MsgInfo( STR0034 ) //"Operação abortada!"
			RestArea( aSaveArea )
			Return( .F. )
		EndIf
	EndIf

	If NK2->(ColumnPos('NK2_TPFRET')) > 0

		If  !Empty(NK2->NK2_TPFRET)
			cTpFrete 	:=  NK2->NK2_TPFRET
		else
			DbSelectArea("NJR")
			DbSetOrder(1)
			If ( DbSeek( xFilial("NJR")+NK2->( NK2_CODCTR )))
				cTpFrete	:= NJR->NJR_TPFRET  	//--Vai pegar o Tipo de frete do contrato 
			EndIf
		EndIf
			
	EndIf

	// Cabeçalho do pedido
	cNumPV := GetSxeNum("SC5","C5_NUM")
	
	aadd( aCab, { "C5_NUM"    , cNumPV		, Nil } )
	aadd( aCab, { "C5_TIPO"   , "N"			, Nil } )
	aadd( aCab, { "C5_CLIENTE", cCliente	, Nil } )
	aadd( aCab, { "C5_LOJACLI", cLoja		, Nil } )
	aadd( aCab, { "C5_CLIENT" , cCliente	, Nil } )
	aadd( aCab, { "C5_LOJAENT", cLoja		, Nil } )
	aadd( aCab, { "C5_CONDPAG", cCondPg		, Nil } )
	aadd( aCab, { "C5_EMISSAO", dDataBase	, Nil } )
	aadd( aCab, { "C5_TPFRETE", cTpFrete	, Nil } ) //C=CIF;F=FOB;T=Por conta terceiros;S=Sem frete                                                                                   
	aAdd( aCab, { "C5_TIPLIB" , "2"			, Nil } ) //1=Libera por item; 2=Libera por pedido
	aAdd( aCab, { "C5_LIBEROK", "S"			, Nil } ) //Pedido liberado total	

	// Alimentando as tabelas de auxiliares de vinculo com ERP
	If GetRpoRelease() > "12.1.017" 
		aadd( aVincCabPV, { "N8H_FILIAL"    , FwXfilial('N8H') 	} )
		aadd( aVincCabPV, { "N8H_NUMPV"    	, cNumPV		  	} )
		aadd( aVincCabPV, { "N8H_CODCTR"    , NK2->NK2_CODCTR 	} )
		aadd( aVincCabPV, { "N8H_CODROM"    , ''		 	 	} )
		aadd( aVincCabPV, { "N8H_CODFIX"   	, ""				} )
		aadd( aVincCabPV, { "N8H_CODOTR"   	, NK2->NK2_CODIGO	} )
		aadd( aVincCabPV, { "N8H_ORIGEM"   	, "OGA245"			} )
		aadd( aVincCabPV, { "N8H_HISTOR"   	, FWI18NLang("OGA245","STR0061",61)	} )  //"Estorno NFT (OGA245)"	
	Endif

	// Monta os itens
	dbSelectArea( "NK3" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "NK3" ) + NK2->( NK2_CODIGO ) )
	While .Not. NK3->( Eof() ) .And. NK3->( NK3_FILIAL + NK3_CODIGO ) == xFilial( "NK3" ) + NK2->( NK2_CODIGO )

		cLocal		:= Posicione( "SB1", 1, xFilial( "SB1" ) + NK3->( NK3_CODPRO  ), "B1_LOCPAD" )
		cItemSeq 	:= StrZero( Val( NK3->( NK3_ITEM ) ), TamSX3( "C6_ITEM" )[1] )

		aLinha := {}
		aAdd( aLinha, { "C6_ITEM"		, cItemSeq				, Nil } )
		aAdd( aLinha, { "C6_PRODUTO"	, NK3->( NK3_CODPRO ), Nil } )
		aAdd( aLinha, { "C6_TES"			, cTes					, Nil } )
		aAdd( aLinha, { "C6_QTDVEN"		, NK3->( NK3_QUANT )	, Nil } )
		aAdd( aLinha, { "C6_QTDLIB"		, NK3->( NK3_QUANT )	, Nil } )
		aAdd( aLinha, { "C6_QTDEMP"		, NK3->( NK3_QUANT )	, Nil } ) /* Faz Liberacao do Pedido se C5_LiberOk = "S" e C6_QtdLib = C6_QtdEmp*/
		aAdd( aLinha, { "C6_PRCVEN"		, NK3->( NK3_PRECO )	, "alwaystrue()" } )
		aAdd( aLinha, { "C6_VALOR"		, NK3->( NK3_TOTAL )	, Nil } )
		aAdd( aLinha, { "C6_LOCAL"		, cLocal				, Nil } )
		aAdd( aLinha, { "C6_NFORI"		, NK2->( NK2_NUMNFT ), Nil } )
		aAdd( aLinha, { "C6_SERIORI"	, NK2->( NK2_SERNFT ), Nil } )
		aAdd( aLinha, { "C6_ITEMORI"	, NK3->( NK3_ITEM )	, Nil } )
		If GetRpoRelease() < "12.1.023"
			If !( Empty( NK2->( NK2_CODCTR ) ) )
				aAdd( aLinha, { "C6_CTROG"		, NK2->( NK2_CODCTR )	, Nil } )
			EndIf
		EndIf
		aAdd( aItens, aLinha )
		If GetRpoRelease() > "12.1.017"
			//Array de vinculo do Agro com os Itens do Pedido
			aLinha := {}
			aadd( aLinha  , { "N8I_FILIAL"    	, FwXfilial('N8I') 					} )
			aadd( aLinha, { "N8I_NUMPV" 	   	, cNumPV		 					} )
			aadd( aLinha, { "N8I_ITEMPV"    	, cItemSeq 							} )
			aadd( aLinha, { "N8I_PRODUT"    	, NK3->NK3_CODPRO 					} )
			aadd( aLinha, { "N8I_TPPROD"    	, ''			 					} )
			aadd( aLinha, { "N8I_CODCTR"    	, NK2->NK2_CODCTR					} )
			aadd( aLinha, { "N8I_SAFRA"    		, NK2->NK2_CODSAF 					} )
			aadd( aLinha, { "N8I_CODROM"    	, ''								} )
			aadd( aLinha, { "N8I_ITEROM"    	, ''			 					} )
			aadd( aLinha, { "N8I_CODOTR"   		, NK2->NK2_CODIGO					} )
			aadd( aLinha, { "N8I_ITEOTR"   		, NK3->NK3_ITEM						} )
			aadd( aLinha, { "N8I_CODFIX"    	, ''			 					} )
			aadd( aLinha, { "N8I_ORIGEM"    	, 'OGA245'			 				} )		
			aadd( aLinha, { "N8I_HISTOR"    	, FWI18NLang("OGA245","STR0061",61)	} ) //"Estorno NFT (OGA245)"

			aAdd( aVincITEPV, aLinha )
		EndIf
		NK3->( dbSkip() )
	EndDo


	// Cria o pedido de venda pela rotina automatica
	Begin Transaction
		/* Necessitamos solicitar o modulo pois alguns campos como LOTE e DTLOTE
		não estao setados para trabalhar com o SIGAAGR */
		cModulo := "FAT" // FIN ALTERADO POIS GERAVA ERRO DE C6_CODROM INVALIDO NO ROMANEIO S/PESAGEM
		nModulo := 5

		MsgRun( STR0045, STR0043	, {|| MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCab, aItens, 3 )  } ) //"Gerando PV da Nota de Estorno..."##"AGUARDE"
		//Retornando o modulo do SIGAAGR
		cModulo := cModAtu
		nModulo := nModAtu

		If lMsErroAuto
			If __lSX8
				RollBackSX8()
			EndIf
			lRetorno := .f.
			MostraErro()
			RestArea( aSaveArea )
			DisarmTransaction()
			Break
		Else
			If __lSX8 
				ConfirmSX8()
				If GetRpoRelease() > "12.1.017"
					lVinculou := fAgrVncPV (aVincCabPV,aVincITEPV  , 3)  //Incluir
					IF .not. lvinculou	
						lRetorno := .f.
						Help(" ",1,"OG245PV") //Não foi possivel Vincular o PV, às tabelas do SigaAGR. Verificque se a tabela N8H/N8I Não possui o PV que esta sendo criado.
						DisarmTransaction()
						Break 
					EndIF
				EndIF 
			EndIf
			cAliasPVSV := Alias()
			nRecnoPVSV := Recno()
		EndIf
	End Transaction

	If lRetorno
		// Faz a geração da NF de Saída
		MsgRun( STR0046, STR0043	, {|| aNFS := AgrGeraNFS( SC5->C5_NUM ) } ) //"Gerando Nota de Estorno..."##"AGUARDE"

		If Len( aNFS ) > 0
			// Atualiza o número da NF de Estorno de Trânsito gerada, na tabela de Ordens de Trânsito
			NK2->( RecLock( "NK2", .f. ) )
			NK2->( NK2_NUENFT ) := aNFS[1] // F2_DOC
			NK2->( NK2_SEENFT ) := aNFS[2] // F2_SERIE
			NK2->( NK2_DTENFT ) := dDataBase
			NK2->( NK2_STATUS ) := "4" // 4=NF Trânsito estornada
			NK2->( msUnLock() )
		EndIf
	Else
		Return .f.
	EndIf

	RestArea( aSaveArea )
Return( .T. )


/** {Protheus.doc} OGA245F12
Abre a tela para alterar os parâmetros do F12
@param: 	NIL
@return:	NIL
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA245
*/
Static Function OGA245F12()

	Local aSaveArea := GetArea()
	Local aButtons  := {}
	Local lOK 		:= .F.
	Local cPar1  	:= PadR( SuperGetMV( "MV_TESNFT", .f., " " ), 3, " " )
	Local cPar2  	:= PadR( SuperGetMV( "MV_TESNFET", .f., " " ), 3, " " )
	Local oDlg, oSay1, oSay2, oGet1, oGet2

	oDlg 	:= TDialog():New( 0, 0, 200, 450, OemToAnsi( STR0021 ),,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Parâmetros de TES para NF de Trânsito"

	oSay1 := TSay():New( 035, 005, {|| OemToAnsi( STR0022 ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 180, 010 ) //"Tipo de Entrada para NF de Transito"
	oGet1 := TGet():New( 045, 005, {|u| If( PCount() > 0, cPar1 := u, cPar1 ) } , oDlg, 080, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., "SF4"	, "cPar1", , , , )

	oSay2 := TSay():New( 065, 005, {|| OemToAnsi( STR0023 ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 180, 010 ) /*  "Tipo de Saída para Estorno de NF de Transito */
	oGet2 := TGet():New( 075, 005, {|u| If( PCount() > 0, cPar2 := u, cPar2 ) } , oDlg, 080, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., "SF4"	, "cPar2", , , , )

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| lOK := .T., oDlg:End() },{|| lOK := .F., oDlg:End() },, @aButtons ) } )

	If lOK
		If cPar1 >= "500"
			MsgStop( STR0024 ) //"Tipo de Entrada deve ser menor que '500'!"
			Return( .F. )
		EndIf
		If cPar2 < "500"
			MsgStop( STR0025 ) //"Tipo de Saída deve ser maior ou igual a '500'!"
			Return( .F. )
		EndIf

		If Empty(cPar1)
			MsgAlert( STR0026 ) //"Se o parâmetro MV_TESNFT for deixado em branco, não será possível gerar NF de Trânsito!"
		EndIf
		If Empty(cPar2)
			MsgAlert( STR0027 ) //"Se o parâmetro MV_TESNFET for deixado em branco, não será possível gerar Estorno de NF de Trânsito!"
		EndIf

		// Grava os parametros alterados	
		PutMV( "MV_TESNFT" , cPar1 )
		PutMV( "MV_TESNFET", cPar2 )
	EndIf
	RestArea( aSaveArea )
Return( .T. )

/*/{Protheus.doc} OGA245AtRom
Atualiza o número do romaneio na Ordem de Trânsito vinculada (se houver).
@type function
@author Marlon Richard Trettin
@since 25/09/2014
@param nRegNJJ, numeric, recno do registro da NJJ
@param lVinc, logical, se vincula nf de transito(.T) ou desvincula(.F)
/*/
Function OGA245AtRom( nRegNJJ, lVinc )

	Local aSaveArea := GetArea()
	Local aAreaNJJ :=NJJ->(GetArea())
	Local aAreaNJM :=NJM->(GetArea())
	Local aAreaNK2 :=NK2->(GetArea())

	dbSelectArea( "NJJ" ) // Romaneios
	NJJ->(dbGoTo( nRegNJJ ))
	dbSelectArea( "NJM" ) // Comercializações do Romaneio
	NJM->(dbSetOrder( 1 ))
	If NJM->(dbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ))
		While !NJM->( EoF() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial( "NJM" ) + NJJ->( NJJ_CODROM )

			dbSelectArea( "NK2" ) // Ordens de Transito
			NK2->(dbSetOrder( 2 )) // NK2_FILIAL+NK2_SERNFT+NK2_NUMNFT
			If NK2->(dbSeek( xFilial( "NK2" ) + NJM->( NJM_NFPSER + NJM_NFPNUM ) )) .and. !Empty(NJM->(NJM_NFPSER))
				// Grava o número do romaneio na ordem de transito
				If RecLock('NK2', .F.)
					Do Case
						Case lvinc
						NK2->( NK2_ROMANE ) := NJM->( NJM_CODROM )
						NK2->( NK2_STATUS ) := '3' // 3=Romaneio vinculado
						Otherwise
						NK2->( NK2_ROMANE ) := ''
						NK2->( NK2_STATUS ) := '2' // 2=Nf. Emitida
					EndCase
					NK2->(MsUnlock())
				EndIf

			EndIf

			NJM->( dbSkip() )

		EndDo
	EndIf

	RestArea(aAreaNJJ )
	RestArea(aAreaNJM )
	RestArea(aAreaNK2 )
	RestArea( aSaveArea )
Return NIL



/** {Protheus.doc} "OGA245DANFE"
Permite imprimir Danfe desde q a Nf. ja steja autorizada

@param: 	NIL
@return:	NIL
@author: 	Emerson Coelho
@since: 	07/01/2015
@Uso: 		OGA245
*/
/*
Function OGA245DANFE
AgrImpDanf()

Return ( nil )
*/

/** {Protheus.doc} OGA245SAF
Função que verifica a Safra X Contrato
@param:   	Safra e Contrato
Retorno:  	.t. ou .f. 
@author: 	Ana Laura Olegini
@since: 	20/05/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA245SAF(cCodSaf,cCodCtr)
	Local lContinua	:= .t.
	Local cSafCtr	:= ""

	If !Empty(cCodCtr)
		cSafCtr := POSICIONE('NJR',1,XFILIAL('NJR')+cCodCtr,'NJR_CODSAF')

		If cSafCtr != cCodSaf
			Help( ,, STR0020,, STR0060, 1, 0,) //"HELP"##//"Safra do Contrato difere da Safra informada."
			lContinua := .F.
		EndIf 
	EndIf 

	Return( lContinua )

	/*/{Protheus.doc} validPre()
	Pré Validação
	@type  Static Function
	@author mauricio.joao
	@since 27/06/2019
	@version 1.0
	/*/
Static Function validPre(oFieldModel, cAction, cIDField, xValue)
	Local lRetorno := .T.
	Local aAreaAtu	:= GetArea()

	Local oModel		:= FwModelActive()
	Local oNK3			:= oModel:GetModel( "NK3DETAIL" )
	Local oNK2			:= oModel:GetModel( "NK2MASTER" )

	If !Empty(xValue)
		If cIDField == "NK2_CODCTR" //valida contrato

			cCodPro		:= oNK3:GetValue( "NK3_CODPRO" )
			cUM			:= oNK3:GetValue( "NK3_UM1PRO" )
			nPreco		:= oNK3:GetValue( "NK3_PRECO" )
			nVlrUni     := 0

			dbSelectArea( "NJR" ) // Contrato
			dbSetOrder( 1 )
			If MsSeek( xFilial( "NJR" ) + xValue )

				//Não permite vincular contrato cancelado a ordem de transito - DAGROGAP-256
				If NJR->( NJR_STATUS ) $ "A|I"			
					oNK2:SetValue( "NK2_CODENT", NJR->( NJR_CODENT ) )
					oNK2:SetValue( "NK2_LOJENT", NJR->( NJR_LOJENT ) )
					oNK2:SetValue( "NK2_NOMENT", POSICIONE('NJ0',1,XFILIAL('NJ0')+NJR->( NJR_CODENT )+NJR->( NJR_LOJENT ),'NJ0_NOME')  )
					oNK2:SetValue( "NK2_CODSAF", NJR->( NJR_CODSAF ) )

					If oNK3:length() <= 1 // Se existir somente  0 ou 1 linha no grid

						If oNK3:length() == 0 // Se não possuir nenhuma linha no grid			

							oNK3:AddLine() // Insere uma linha

						Else // Senão, se já possui uma linha no grid, posiciona nela

							oNK3:GoLine( 1 )

						EndIf

						cCodPro := NJR->( NJR_CODPRO )						
						cUM		 := Posicione( "SB1", 1, xFilial( "SB1" ) + cCodPro, "B1_UM" )

						//--<< 28/11/2014 emerson >>--
						//--<< Garantindo Integridade da UM DO produto e Um de preço do contrato e ajustando o VlrUni para a Und. do Produto >>--
						nQtAux		:= 	AGRX001( NJR->NJR_UMPRC, cUM , 1, cCodPro )

						If NK0->( dbSeek( xFilial( "NK0" ) + NJR->( NJR_CODIDX ) ) )
							// Busca valor do índice de acordo com o tipo de cotação (diária ou mais atual)
							nVlrUni := AgrGetInd( NK0->NK0_INDICE, NK0->NK0_TPCOTA, dDataBase )
						Else
							nVlrUni := NJR->( NJR_VLRUNI )
						EndIf

						nPreco	:=	Round( nVlrUni / nQtAux , TamSX3('NJR_VLRUNI')[2] )

						// Converte a Cotação da unidade de medida do Contrato (NJR) para a unidade de medida do Produto (SB1) 
						//nPreco  := AGRX001( cUM, NJR->( NJR_UM1PRO ), NJR->( NJR_VLRUNI ) ) 				

						oNK3:SetValue( "NK3_CODPRO", cCodPro )
						oNK3:SetValue( "NK3_PRECO", nPreco )

					EndIf

				Else
					Help( ,, STR0020,, STR0058, 1, 0,) //"HELP"##"Só é permitido vincular contratos Abertos ou Iniciados.."######
					lRetorno := .f.		
					//oView:Refresh()
				EndIf	
			Else
				Help( ,, STR0020,, STR0050+xValue, 1, 0,) //"HELP"##"Não foi possível localizar o Contrato no cadastro de Contratos (tabela NJR): "######
				lRetorno := .f.
			EndIf


			RestArea( aAreaAtu )

		ElseIf cIdField == "NK2_PLACA" //valida placa

			dbSelectArea( "DA3" ) // Cadastro de veículos
			dbSetOrder( 3 )
			If dbSeek( xFilial( "DA3" ) + xValue )

				oNK2:SetValue( "NK2_CODMOT", DA3->( DA3_MOTORI ) )

				If oNK3:length() <= 1 // Se existir somente  0 ou 1 linha no grid

					If oNK3:length() == 0 // Se não possuir nenhuma linha no grid         

						oNK3:AddLine() // Insere uma linha

					Else // Senão, se já possui uma linha no grid, posiciona nela

						oNK3:GoLine( 1 )

					EndIf

					oNK3:SetValue( "NK3_QUANT", DA3->( DA3_CAPACN ) )

				EndIf

				//oView:Refresh()

			Else
				Help( ,, STR0020,, STR0051+xValue, 1, 0,) //"HELP"##"Não foi possível localizar a Placa no cadastro de Veículos (tabela DA3): "######
				lRetorno := .f.
			EndIf

		ElseIf cIdField == "NK2_CODMOT" //valida motorista
			
			dbSelectArea( "DA4" ) // Cadastro de Motoristas
			dbSetOrder( 1 )
			If dbSeek( xFilial( "DA4" ) + xValue )

				oNK2:SetValue( "NK2_NOMMOT", DA4->( DA4_NOME ) )
				//oView:Refresh()

			Else
				Help( ,, STR0020,, STR0053+xValue, 1, 0,) //"HELP"##"Não foi possível localizar o Motorista no cadastro de Motoristas (tabela DA4): "######
				lRetorno := .f.
			EndIf

		ElseIf cIdField == "NK2_CODTRA" //valida transportadora

			dbSelectArea( "SA4" ) // Cadastro de Transportadores
			dbSetOrder( 1 )
			If dbSeek( xFilial( "SA4" ) + xValue )

				oNK2:SetValue( "NK2_NOMTRA", SA4->( A4_NOME ) )

			Else
				Help( ,, STR0020,, STR0054+xValue, 1, 0,) //"HELP"##"Não foi possível localizar o Transportador no cadastro de Transportadores (tabela SA4): "######
				lRetorno := .f.
			EndIf
		EndIf
	EndIf

Return lRetorno

