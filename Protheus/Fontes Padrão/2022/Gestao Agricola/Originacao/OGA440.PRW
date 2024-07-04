#INCLUDE "OGA440.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"
#INCLUDE "POSCSS.CH"

/** {Protheus.doc} OGA440
Rotina de Movimentações de Contrato

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA440()
	Local oBrowseNKM	:= Nil

	oBrowseNKM := FWMBrowse():New()
	oBrowseNKM:SetAlias( "NKM" )
	oBrowseNKM:SetDescription( STR0001 ) //"Movimentações"
	oBrowseNKM:SetMenuDef( "OGA440" )
	oBrowseNKM:AddLegend( "NKM_STATUS=='1'", "YELLOW"	, X3CboxDesc( "NKM_STATUS", "1" ) ) //"Aberta"
	oBrowseNKM:AddLegend( "NKM_STATUS=='2'", "GREEN"	, X3CboxDesc( "NKM_STATUS", "2" ) ) //"Encerrada"
	oBrowseNKM:AddLegend( "NKM_STATUS=='3'", "BR_CANCEL", X3CboxDesc( "NKM_STATUS", "3" ) ) //"Cancelada"
	oBrowseNKM:Activate()
	
Return( NIL )


/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		OGA440
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002	    , "PesqBrw"							, 0, 1, 0, .t. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003		, "ViewDef.OGA440"					, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004		, "OGA440Inc()"						, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005		, "ViewDef.OGA440"					, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006		, "ViewDef.OGA440"					, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007		, "OGA440Encer()"				    , 0, 4, 0, Nil } ) //"Encerrar"
	aAdd( aRotina, { STR0008		, "OGA440Reabr()"					, 0, 4, 0, Nil } ) //"Reabrir"
	aAdd( aRotina, { STR0009		, "OGA440Cance()"					, 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0010		, "ViewDef.OGA440"					, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0011        , "AGRCONHECIM('NKM')"              , 0, 4, 0, Nil } ) //"Conhecimento"
	aAdd( aRotina, { STR0012		, "OGA440HIS"						, 0, 7, 0, Nil } ) //"Histórico"
Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		OGA440
*/
Static Function ModelDef()
	Local oStruNKM := FWFormStruct( 1, "NKM" )
	Local oStruNJM := FWFormStruct( 1, "NJM" )
	Local oModel

    //----------------Estrutura para criação do campo-----------------------------
    // [01] C Titulo do campo
    // [02] C ToolTip do campo
    // [03] C identificador (ID) do Field
    // [04] C Tipo do campo
    // [05] N Tamanho do campo
    // [06] N Decimal do campo
    // [07] B Code-block de validação do campo
    // [08] B Code-block de validação When do campo
    // [09] A Lista de valores permitido do campo
    // [10] L Indica se o campo tem preenchimento obrigatório
    // [11] B Code-block de inicializacao do campo
    // [12] L Indica se trata de um campo chave
    // [13] L Indica se o campo pode receber valor em uma operação de update.
    // [14] L Indica se o campo é virtual
    // [15] C Valid do usuario em formato texto e sem alteracao, usado para se criar o aheader de compatibilidade 
	
	oStruNJM:AddField( " "                     , RetTitle( "NJJ_STATUS" ), "TMP_STATUS", "C", 11                     , 0, , , {}, .F., {|| fIniLeg() }  , .F., .F., .T., )
	oStruNJM:AddField( " "                     , RetTitle( "F2_FIMP" )  ,  "TMP_STANFE", "C", 11                     , 0, , , {}, .F., {|| fLegNfe() }  , .F., .F., .T., )
	oStruNJM:AddField( RetTitle( "NJM_FILIAL" ), RetTitle( "NJM_FILIAL" ), "NJM_FILIAL", "C", TamSX3("NJM_FILIAL")[1], 0, , , {}, .F., /*bInit*/        , .F., .F., .F., )
	oStruNJM:AddField( RetTitle( "NJJ_TIPO" )  , RetTitle( "NJJ_TIPO" )  , "TMP_TIPO"  , "C", 30                     , 0, , , {}, .F., {|| fIniTipo()}  , .F., .F., .T., )
	oStruNJM:AddField( RetTitle( "NJJ_TIPENT" ), RetTitle( "NJJ_TIPENT" ), "TMP_TIPENT", "C", 10                     , 0, , , {}, .F., {|| fIniTipEnt()}, .F., .F., .T., )
	oStruNJM:AddField( STR0049, STR0049, "TMP_SUBTIP", "C", 30                     , 0, , , {}, .F., {|| fIniSubTip()}, .F., .F., .T., )
	
	////////////////////////
	// Inicializa o Model //
	////////////////////////
				//MPFORMMODEL():New(<cID >, <bPre >, <bPost >, <bCommit >, <bCancel >)
	oModel := 	  MPFormModel():New( "OGA440", , , {| oModel | GrvModelo( oModel ) } )
	
	oModel:SetVldActivate( { |oMod| fVldActivate( oMod ) } )
	
	oModel:AddFields( "NKMUNICO", Nil, oStruNKM, , )
	oModel:AddGrid( "NJMUNICO", "NKMUNICO", oStruNJM, /*bLinePre*/, /*bLinePos*/, /*bPre*/, /*bPos*/, /*{ |oModel| bLoadNJM( oModel ) }bLoad*/ )

	oModel:SetRelation( "NJMUNICO", { { "NJM_IDMOV", "NKM_IDMOV" } }, NJM->( IndexKey( 4 ) ) )
	
	oModel:GetModel( "NJMUNICO" ):SetOptional( .t. )
	oModel:GetModel( "NJMUNICO" ):SetNoInsertLine( .t. )
	oModel:GetModel( "NJMUNICO" ):SetNoUpdateLine( .t. )
	oModel:GetModel( "NJMUNICO" ):SetNoDeleteLine( .t. )
	
	oModel:SetDescription( STR0001 ) //"Movimentações"
	oModel:GetModel( "NKMUNICO" ):SetDescription( STR0013 ) //"Dados da Movimentacao"
	oModel:GetModel( "NJMUNICO" ):SetDescription( STR0014 ) //"Romaneios Vinculados"
	
Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR
*/
Static Function ViewDef()
	Local oStruNKM 	:= FWFormStruct( 2, "NKM" )
	Local oStruNJM 	:= FWFormStruct( 2, "NJM" )
	Local oModel   	:= FWLoadModel( "OGA440" )
	Local oView    	:= FWFormView():New()
//	Local nOpc 		:= oModel:GetOperation()
	
	//---------------- Estrutura para criação de campos virtuais -----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é editável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	
	oStruNJM:AddField( "TMP_STATUS", "00", " "					   , RetTitle( "NJJ_STATUS" ), {}, "BT", "@BMP", , , .F., , , , , , .T., , )
	oStruNJM:AddField( "TMP_STANFE", "00", " "					   , RetTitle( "F2_FIMP" ),    {}, "BT", "@BMP", , , .F., , , , , , .T., , )
	oStruNJM:AddField( "NJM_FILIAL", "01", RetTitle( "NJM_FILIAL" ), RetTitle( "NJM_FILIAL" ), {}, "G" , "@!"  , , , .F., , , , , , .F., , )
	oStruNJM:AddField( "TMP_TIPO"  , "02", RetTitle( "NJJ_TIPO" )  , RetTitle( "NJJ_TIPO"   ), {}, "G" , "@!"  , , , .F., , , , , , .T., , )
	oStruNJM:AddField( "TMP_SUBTIP", "02", STR0049, STR0049, {}, "G" , "@!"  , , , .F., , , , , , .T., , )
	oStruNJM:AddField( "TMP_TIPENT", "02", RetTitle( "NJJ_TIPENT" ), RetTitle( "NJJ_TIPO"   ), {}, "G" , "@!"  , , , .F., , , , , , .T., , )
	
	////////////////////////
	// Inicializa o View  //
	////////////////////////
	oView:SetModel( oModel )

	oView:CreateHorizontalBox( "SUPERIOR" , 30 )	// altura em %
	oView:CreateHorizontalBox( "BOTAOEXE" , 30, , .T. ) // altura em pixels
	oView:CreateHorizontalBox( "MEIOTELA" , 50 )	// altura em %
	oView:CreateHorizontalBox( "BOTOES"   , 30, , .T. ) // altura em pixels
	oView:CreateHorizontalBox( "INFERIOR" , 20 )	// altura em %

	oView:AddField( "V440_NKM", oStruNKM, "NKMUNICO" )
	oView:EnableTitleView( "V440_NKM" )
	oView:SetOwnerView( "V440_NKM", 	"SUPERIOR" )
	
	If ! IsInCallStack( "OGA440Inc" ) // Se não for Inclusão 
		oView:AddGrid( "V440_NJM", oStruNJM, "NJMUNICO" )
		oView:EnableTitleView( "V440_NJM" )
		oView:SetOwnerView( "V440_NJM", 	"MEIOTELA" )
		
		oView:SetViewProperty( "V440_NJM", "ENABLENEWGRID" )		// Define que o grid deve usar como interface visual o browse (FWBrowse)
		oView:SetViewProperty( "V440_NJM", "SETCSS", { "QTableView { selection-background-color: #0091FF; }" } ) // Seta a cor de backgroud da linha selecionda         
//		oView:SetViewProperty( "V440_NJM", "GRIDNOORDER")		// Define não permitir ordenação no grid

		// Evento de duplo click no Grid pra exibir Legenda
		oView:SetViewProperty("V440_NJM","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| LoadLegnd(oFormulario,cFieldName,nLineGrid,nLineModel,oView)}})
	
		//FWFORMVIEW():AddOtherObject(<cViewID >, [ bActivate ], [ bDeActivate ], <bRefresh >)
		oView:AddOtherObject( "OTHER_BOTAO", { |oPanel| fBotoesPanel( oPanel ) } )
		oView:SetOwnerView( "OTHER_BOTAO", "BOTOES"   )	
		
		oView:AddOtherObject( "OTHER_TOTAL", { |oPanel| fTotalView( oPanel ) }, , { |oPanel| fTotalView( oPanel ) } )
		oView:SetOwnerView( "OTHER_TOTAL",	"INFERIOR" )
		
		// Define botões da tela  
		oView:AddUserButton( STR0028, "", { || fBrwLeg() } )   //"Legenda"
		oView:AddUserButton( STR0041, "", { || fBrwLegNf() } ) //"Legenda NFe"
	EndIf
	
//	oView:showUpdateMsg( .F. )
//	oView:SetViewAction( "BUTTONOK", {|| .t. } )
//	oView:SetViewAction( "BUTTONCANCEL", {|| .T. } )
	oView:SetCloseOnOk( {|| .t. } )
	
Return( oView )

///////////////////////////////////////////////////
Function OGA440Inc()
	Local xRet 

	//FWExecView([ cTitulo ], <cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
	xRet := FWExecView('', 'VIEWDEF.OGA440', MODEL_OPERATION_INSERT, , {|| .T. }) //"Incluir"
	
Return xRet

/** {Protheus.doc} fViewRefresh()
Função que faz refresh dos dados da View.

@param: 	NIL
@return:	NIL
@author: 	Marlon Richard Trettin
@since: 	23/06/2015
@Uso: 		OGA440
*/
Static Function fViewRefresh()
	Local oView  := FwViewActive()
	Local oModel := FwModelActive()
	
	oModel:CommitData()
	oModel:Deactivate()
	dbSelectArea( 'NKM' )
	oModel:Activate()
	oView:Refresh()
Return( NIL ) 

/** {Protheus.doc} fIniLeg()
Função que inicializa a legenda.

@param: 	NIL
@return:	cRetorno
@author: 	Marlon Richard Trettin
@since: 	23/06/2015
@Uso: 		OGA440
*/
Static Function fIniLeg()
	Local cRetorno := "####"
	Local aAreaAtu := GetArea()
	
	If fPosicNJJ( NJM->( NJM_FILIAL ), NJM->( NJM_CODROM ) )
		Do Case 
			Case NJJ->( NJJ_STATUS ) == "0"	// Pendente
				cRetorno := "BR_VERMELHO"
			Case NJJ->( NJJ_STATUS ) == "1"	// Completo
				cRetorno := "BR_AMARELO"
			Case NJJ->( NJJ_STATUS ) == "2"	// Atualizado
				cRetorno := "BR_LARANJA"
			Case NJJ->( NJJ_STATUS ) == "3"	// Confirmado
				cRetorno := "BR_VERDE"
			Case NJJ->( NJJ_STATUS ) == "4"	// Cancelado
				cRetorno := "BR_CANCEL"
		EndCase 
	EndIf
	
	RestArea( aAreaAtu )
Return ( cRetorno )  

/** {Protheus.doc} fIniTipo()
Função que inicializa a coluna NJJ_TIPO

@param: 	NIL
@return:	cRetorno
@author: 	Marlon Richard Trettin
@since: 	23/06/2015
@Uso: 		OGA440
*/
Static Function fIniTipo()
	Local cRetorno := "####"
	Local aAreaAtu := GetArea()
	
	If fPosicNJJ( NJM->( NJM_FILIAL ), NJM->( NJM_CODROM ) )
		cRetorno := NJJ->( NJJ_TIPO ) + " - " + Posicione( "SX5", 1, xFilial( "SX5" ) + "K5" + NJJ->( NJJ_TIPO ), "X5_DESCRI" )
	EndIf
	
	RestArea( aAreaAtu )
Return ( cRetorno )  

/** {Protheus.doc} fIniSubTip()
Função que inicializa a coluna NJM_SUBTIP

@param: 	NIL
@return:	cRetorno
@author: 	Tamyris Ganzenmueller
@since: 	03/04/2018
@Uso: 		OGA440
*/
Static Function fIniSubTip()
	Local cRetorno := "####"
	Local cDescr   := ''
	
	Local aAreaAtu := GetArea()
	
	If NJM->(ColumnPos('NJM_SUBTIP')) > 0 
		If !Empty(NJM->NJM_SUBTIP)
			cRetorno := NJM->( NJM_SUBTIP ) + " - " + Posicione( "SX5", 1, xFilial( "SX5" ) + "K0" + NJM->NJM_SUBTIP, "X5_DESCRI" )
		EndIf
	EndIF
	
	If cRetorno == "####"
	
		If fPosicNJJ( NJM->( NJM_FILIAL ), NJM->( NJM_CODROM ) )
			cDescr := Posicione( "SX5", 1, xFilial( "SX5" ) + "K0" + (NJJ->NJJ_TIPO + "0"), "X5_DESCRI" )
			If !Empty(cDescr)
				cRetorno := NJJ->( NJJ_TIPO ) + "0 - " + cDescr 
			Else
				cRetorno := NJJ->( NJJ_TIPO ) + " - " + Posicione( "SX5", 1, xFilial( "SX5" ) + "K5" + NJJ->( NJJ_TIPO ), "X5_DESCRI" )
			EndIF
		EndIf
	EndIf
	
	RestArea( aAreaAtu )
Return ( cRetorno )  

/** {Protheus.doc} fIniTipEnt()
Função que inicializa a coluna NJJ_TIPENT

@param: 	NIL
@return:	cRetorno
@author: 	Marlon Richard Trettin
@since: 	23/06/2015
@Uso: 		OGA440
*/
Static Function fIniTipEnt()
	Local cRetorno := "####"
	Local aAreaAtu := GetArea()
	
	If fPosicNJJ( NJM->( NJM_FILIAL ), NJM->( NJM_CODROM ) )
		cRetorno := X3CboxDesc( "NJJ_TIPENT", NJJ->( NJJ_TIPENT ) )
	EndIf
	
	RestArea( aAreaAtu )
Return ( cRetorno )  

/** {Protheus.doc} fVldActivate
Função que valida a execução de operações de Alteração ou Exclusão.

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		OGA440
*/
Static Function fVldActivate( oModel )
	Local aAreaAtu  := GetArea()
	Local cAliasQry := GetNextAlias() 
	Local nOpc 	    := oModel:GetOperation()
	Local lRet      := .T.
	
	// Se for Alteração ou Exclusão
	If nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE 
		If NKM->( NKM_STATUS ) $ "2|3" //2=Encerrado; 3=Cancelado
			Help( ,, STR0015,, STR0016 + NKM->( NKM_STATUS ) + " - " + X3CboxDesc( "NKM_STATUS", NKM->( NKM_STATUS ) ), 1, 0,) //"Ajuda"##"Operacao nao permitida para Movimentacao com status "
			lRet := .F.
		EndIf
	EndIf
	If nOpc == MODEL_OPERATION_DELETE
		BeginSql Alias cAliasQry
			Select	NJM.*
			  From %Table:NJM% NJM
			 Where	NJM.%NotDel% 
			   And	NJM.NJM_IDMOV = %exp:NKM->( NKM_IDMOV )%
		EndSql
		DbselectArea( cAliasQry )
		If .Not. ( cAliasQry )->( Eof() )
			Help( ,, STR0008,, STR0024, 1, 0,) //"Ajuda"##"Antes de excluir uma Movimentacao, desvincule todos os Romaneios associados a mesma."
			lRet := .F.
		EndIf
		( cAliasQry )->( dbCloseArea() )
	EndIf
	
	RestArea( aAreaAtu )
Return lRet

/** {Protheus.doc} GrvModelo
Funcao para gravar dados adicionais e o modelo de dados

@param:     oModel - Modelo de Dados
@return:    .t.
@author:    Marlon Richard Trettin
@since:     08/07/2015
@Uso:       OGA440
*/
Static Function GrvModelo( oModel )
	Local aAreaAtu	 := GetArea()
	Local nOperation := oModel:GetOperation()
	Local lRetorno   := .t.
	Local oModelNKM  := oModel:GetModel( "NKMUNICO" )
	
	If lRetorno .And. (ExistBlock("OGA440GRV"))
		lRetorno := ExecBlock("OGA440GRV",.F.,.F.,{oModel,"PosModelo","OGA440"})
	EndIf
	
	If lRetorno
		// Gravar Histórico Automaticamente
		If nOperation == MODEL_OPERATION_INSERT
			AgrGravaHis( ,,,, { "NKM", xFilial("NKM") + oModelNKM:Getvalue('NKM_IDMOV'), "3", STR0004 } )	//"Incluir"
		ElseIf nOperation == MODEL_OPERATION_UPDATE
			AgrGravaHis( ,,,, { "NKM", xFilial("NKM") + NKM->( NKM_IDMOV ), "4", STR0005 } )	//"Alterar"
		ElseIf nOperation == MODEL_OPERATION_DELETE
			AgrGravaHis( ,,,, { "NKM", xFilial("NKM") + NKM->( NKM_IDMOV ), "5", STR0006 } )	//"Excluir"
		Endif
		
		FWFormCommit( oModel )
		
	Endif
	
	lF10Exec := .t.
		
	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} fBotoesPanel()
Função que insere botões num panel não-MVC da View.

@param: 	oPanel	-	objeto oPanel que receberá os objetos não-MVC
@return:	NIL
@author: 	Marlon Richard Trettin
@since: 	30/06/2015
@Uso: 		OGA440
*/
Static Function fBotoesPanel( oPanel )
	Local oBtn1, oBtn2, oBtn3 
	Local oModel := FwModelActive()
	Local nOpc   := oModel:GetOperation()
	
	If nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE
		oBtn1 := TButton():New( 002, 010, STR0020, oPanel, { || OGA440V( FWFldGet( "NKM_IDMOV" ) ), fViewRefresh() }, 80, 10, , , .F., .T., .F., , .F., , ,.F. )	//"Vincular / Desvincular"
		
		oBtn2 := TButton():New( 002, 100, STR0027, oPanel, {|| }, 80, 10, , , .F., .T., .F., , .F., , ,.F. )	//"Romaneios"
		// Cria menu popup do botão
		oMenuTel := TMenu():New(0,0,0,0,.T.)    
		oMenuTel:Add( TMenuItem():New( oPanel, STR0017,,,,{ || OGA250(), fViewRefresh() },,,,,,,,,.T.) )	//"Físicos"
		oMenuTel:Add( TMenuItem():New( oPanel, STR0018,,,,{ || OGA251(), fViewRefresh() },,,,,,,,,.T.) )	//"Simbólicos"
		oMenuTel:Add( TMenuItem():New( oPanel, STR0019,,,,{ || OGA255(), fViewRefresh() },,,,,,,,,.T.) )	//"Gerenciais"
		oBtn2:SetPopupMenu( oMenuTel ) // Seta popup do botão		
		
		oBtn3 := TButton():New( 002, 190, STR0023, oPanel, {|| }, 80, 10, , , .F., .T., .F., , .F., , ,.F. )	//"Operações"
		// Cria menu popup do botão
		oMenuOpe := TMenu():New(0,0,0,0,.T.)    
		oMenuOpe:Add( TMenuItem():New( oPanel, STR0003,,,,{ || iIf( fPosicNJJ( FWFldGet( "NJM_FILIAL" ), FWFldGet( "NJM_CODROM" ) ), OGX001VRom( NJJ->( Recno() ) ), Nil) },,,,,,,,,.T.) )	//"Visualizar"
		oMenuOpe:Add( TMenuItem():New( oPanel, STR0021,,,,{ || iIf( fPosicNJJ( FWFldGet( "NJM_FILIAL" ), FWFldGet( "NJM_CODROM" ) ), OGA250ATUC(), Nil ), fViewRefresh()  },,,,,,,,,.T.) )	//"Atualizar"
		oMenuOpe:Add( TMenuItem():New( oPanel, STR0022,,,,{ || iIf( fPosicNJJ( FWFldGet( "NJM_FILIAL" ), FWFldGet( "NJM_CODROM" ) ), OGA250NF(),   Nil ), fViewRefresh()  },,,,,,,,,.T.) )	//"Confirmar"
		oMenuOpe:Add( TMenuItem():New( oPanel, STR0008,,,,{ || iIf( fPosicNJJ( FWFldGet( "NJM_FILIAL" ), FWFldGet( "NJM_CODROM" ) ), OGA250REA(),  Nil ), fViewRefresh()  },,,,,,,,,.T.) )	//"Reabrir"
		oMenuOpe:Add( TMenuItem():New( oPanel, STR0009,,,,{ || iIf( fPosicNJJ( FWFldGet( "NJM_FILIAL" ), FWFldGet( "NJM_CODROM" ) ), OGA250CAN(),  Nil ), fViewRefresh()  },,,,,,,,,.T.) )	//"Cancelar"
		oMenuOpe:Add( TMenuItem():New( oPanel, STR0042,,,,{ || iIf( fPosicNJJ( FWFldGet( "NJM_FILIAL" ), FWFldGet( "NJM_CODROM" ) ), OGA440NFE(),    Nil ), fViewRefresh()  },,,,,,,,,.T.) )	//"Sped.NFe"
		oBtn3:SetPopupMenu( oMenuOpe ) // Seta popup do botão		
	ElseIf nOpc <> MODEL_OPERATION_INSERT 
		If ! IsInCallStack( "OGX001VRom" )
			oBtn3 := TButton():New( 002, 190, STR0023, oPanel, {|| }, 80, 10, , , .F., .T., .F., , .F., , ,.F. )	//"Operações"
			// Cria menu popup do botão
			oMenuOpe := TMenu():New(0,0,0,0,.T.)    
			oMenuOpe:Add( TMenuItem():New( oPanel, STR0003,,,,{ || iIf( fPosicNJJ( FWFldGet( "NJM_FILIAL" ), FWFldGet( "NJM_CODROM" ) ), OGX001VRom( NJJ->( Recno() ) ), Nil) } ,,,,,,,,,.T.) )	//"Visualizar"
			oBtn3:SetPopupMenu( oMenuOpe ) // Seta popup do botão		
		EndIf
	EndIf
Return( NIL ) 

/** {Protheus.doc} fTotalView()
Função que mostra os totais no rodapé não-MVC da View.

@param: 	oPanel	-	objeto oPanel que será passado para a função AgrMosTotais()
@return:	NIL
@author: 	Marlon Richard Trettin
@since: 	30/06/2015
@Uso: 		OGA440
*/
Static Function fTotalView( oPanel )
	Local aCabTot  :=	 { 	{ "TOTAIS", "C", 60, 0, "TOTAIS", "@!" },;
							{ "NJM_QTDFCO"},; 
							{ "NJM_QTDFIS"},;
							{ "NJM_VLRTOT"},;
							{ "BRANCO", "C", 60, 0, " ", "@!" } }
	Local aIteTot  := {}
	Local oModel   := FwModelActive()
	Local oNJM	   := oModel:GetModel( "NJMUNICO" )
	Local nLinha   := 0
	Local nX       := 0
	Local nPos 	   := 0
	Local cTipoRom := " "
	Local cSubTip  := " "
	
	// Totaliza itens do grid NJM 
	nLinha := oNJM:GetLine()
	For nX := 1 to oNJM:Length()
		
		oNJM:GoLine( nX )
		cTipoRom := oNJM:GetValue( "TMP_TIPO" )
		cSubTip  := IIf(Empty( oNJM:GetValue("TMP_SUBTIP")) ,cTipoRom ,oNJM:GetValue("TMP_SUBTIP")) 
		
		nPos := aScan( aIteTot, { |x| AllTrim( x[1] ) == AllTrim( cSubTip ) } )
		If nPos == 0
			aAdd( aIteTot, { cSubTip , oNJM:GetValue( "NJM_QTDFCO" ), oNJM:GetValue( "NJM_QTDFIS" ), oNJM:GetValue( "NJM_VLRTOT" ), "" } )
		Else
			aIteTot[nPos,2] += oNJM:GetValue( "NJM_QTDFCO" )
			aIteTot[nPos,3] += oNJM:GetValue( "NJM_QTDFIS" )
			aIteTot[nPos,4] += oNJM:GetValue( "NJM_VLRTOT" )
		EndIf
		
	Next nX
	oNJM:GoLine( nLinha )
	If Len( aIteTot ) == 0
		aAdd( aIteTot, { " ", 0, 0, 0, "" } )
	EndIf
	
	//	AGRMOSTOTAIS( aMatCam, vVetDad, oBjeto, oBFWFor )
	AgrMosTotais( aCabTot, aIteTot, oPanel, , .T.)
	
Return( NIL )

/** {Protheus.doc} OGA440Encer
Função para Encerrar uma Movimentação

@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		SIGAAGR
*/
Function OGA440Encer()
	
	If NKM->( NKM_STATUS ) == "1" // 1=Aberta
		If fEncerOk( NKM->( NKM_IDMOV ) )
			
			If AgrGravaHis( STR0037, "NKM", NKM->( NKM_FILIAL + NKM_IDMOV ), "E" ) == 1	//"Digite uma observacao e Confime o encerramento da Movimentacao."
				If RecLock( "NKM", .F. )
					NKM->( NKM_STATUS ) := "2" // 2=Encerrada 
					NKM->( MsUnLock() )
				EndIf
			EndIf
		Else
			Help( ,, STR0015,, STR0016 + NKM->( NKM_STATUS ) + " - " + X3CboxDesc( "NKM_STATUS", NKM->( NKM_STATUS ) ), 1, 0,) //"Ajuda"##"Operacao nao permitida para Movimentacao com status "
			Return( .F. )
		EndIf
	Else
		Help( ,, STR0015,, STR0016 + NKM->( NKM_STATUS ) + " - " + X3CboxDesc( "NKM_STATUS", NKM->( NKM_STATUS ) ), 1, 0,) //"Ajuda"##"Operacao nao permitida para Movimentacao com status "
		Return( .F. )
	EndIf
	
Return .T.

/** {Protheus.doc} fEncerOk
Função para Validar se uma Movimentação está OK para ser encerrada

@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		SIGAAGR
*/
Static Function fEncerOk( pcIDMov )
	Local lRet 	    := .T.
	Local aAreaAtu  := GetArea()
	Local cAliasQry := GetNextAlias() 
	
	// Verifica Romaneios da Movimentação 
	BeginSql Alias cAliasQry
		Select	NJM.*, NJJ.*
		  From %Table:NJM% NJM
		 Inner Join %Table:NJJ% NJJ
		    On NJJ.%NotDel%
		   And NJJ.NJJ_FILIAL = NJM.NJM_FILIAL
		   And NJJ.NJJ_CODROM = NJM.NJM_CODROM
		 Where	NJM.%NotDel% 
		   And	NJM.NJM_IDMOV = %exp:NKM->( NKM_IDMOV )%
	EndSql
		
	DbselectArea( cAliasQry )
	While .Not. ( cAliasQry )->( Eof() )
		
		If	! ( ( cAliasQry )->( NJJ_STATUS ) $ "3|4" ) 	// 3=Confirmado; 4=Cancelado 
			Help( ,, STR0008,, STR0036, 1, 0,) //"Ajuda"##"Movimentacao possui romaneios ainda em aberto. Nao podera ser encerrada."
			lRet := .F.
			Exit
		EndIf
		
		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( dbCloseArea() )
	
	RestArea( aAreaAtu )
Return( lRet )

/** {Protheus.doc} OGA440Reabr
Função para Reabrir uma Movimentação

@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		SIGAAGR
*/
Function OGA440Reabr()
	
	If NKM->( NKM_STATUS ) $ "2|3" //2=Encerrado; 3=Cancelado
		If AgrGravaHis( STR0039, "NKM", NKM->( NKM_FILIAL + NKM_IDMOV ), "B" ) == 1	//"Digite uma observacao e Confime a reabertura da Movimentacao"
			If RecLock( "NKM", .F. )
				NKM->( NKM_STATUS ) := "1" // 1=Aberta
				NKM->( MsUnLock() )
			EndIf
		EndIf
	Else
		Help( ,, STR0015,, STR0016 + NKM->( NKM_STATUS ) + " - " + X3CboxDesc( "NKM_STATUS", NKM->( NKM_STATUS ) ), 1, 0,) //"Ajuda"##"Operacao nao permitida para Movimentacao com status "
		Return( .F. )
	EndIf
	
Return .T.

/** {Protheus.doc} OGA440Cance
Função para Cancelar uma Movimentação

@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		SIGAAGR
*/
Function OGA440Cance()
	Local aAreaAtu  := GetArea()
	Local cAliasQry := GetNextAlias() 
	
	If NKM->( NKM_STATUS ) $ "1|2" //1=Aberta; 2=Encerrada

		If AgrGravaHis( STR0040, "NKM", NKM->( NKM_FILIAL + NKM_IDMOV ), "C" ) == 1	//"Digite uma observacao e Confime o cancelamento da Movimentacao"
			
			// Verifica Romaneios da Movimentação 
			BeginSql Alias cAliasQry
				Select	NJM.*, NJM.R_E_C_N_O_ as NJM_RECNO
				  From %Table:NJM% NJM
				 Where	NJM.%NotDel% 
				   And	NJM.NJM_IDMOV = %exp:NKM->( NKM_IDMOV )%
			EndSql
			DbselectArea( cAliasQry )
			If .Not. ( cAliasQry )->( Eof() )
				If MsgYesNo( STR0038 ) //"Deseja desvincular os romaneios associados a Movimentacao?"
					( cAliasQry )->( DbGoTop() )
					While .Not. ( cAliasQry )->( Eof() )
						DbSelectArea( "NJM" )
						DbGoTo( ( cAliasQry )->( NJM_RECNO ) )
						If RecLock( "NJM", .F. )
							NJM->( NJM_IDMOV ) := Space( TamSX3( "NJM_IDMOV" )[1] )
							NJM->( MsUnLock() )
						EndIf
						( cAliasQry )->( DbSkip() )
					EndDo
				EndIf
			EndIf
			( cAliasQry )->( dbCloseArea() )
			
			If RecLock( "NKM", .F. )
				NKM->( NKM_STATUS ) := "3" // 3=Cancelada
				NKM->( MsUnLock() )
			EndIf
		EndIf
		
	Else
		Help( ,, STR0015,, STR0016 + NKM->( NKM_STATUS ) + " - " + X3CboxDesc( "NKM_STATUS", NKM->( NKM_STATUS ) ), 1, 0,) //"Ajuda"##"Operacao nao permitida para Movimentacao com status "
		Return( .F. )
	EndIf
	
	RestArea( aAreaAtu )
Return( .T. )

/** {Protheus.doc} fPosicNJJ
Função para posicionar na tabela NJJ no romaneio atual da NJM

@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		SIGAAGR
*/
Function fPosicNJJ( pcFilial, pcCodRom )
	
	DbSelectArea( "NJJ" )
	DbSetOrder( 1 )
	If ! DbSeek( pcFilial + pcCodRom )
		Help( ,, STR0015,, STR0025 + Chr(10) + Chr(13) + "[ "+  pcFilial + pcCodRom + " ]", 1, 0,) //"Ajuda"##"Nao foi possivel localizar o cabecalho do romaneio na tabela NJJ."
		Return( .F. )
	EndIf
	
Return( .T. )

/** {Protheus.doc} fBrwLeg()
Função para mostrar legenda dos status dos romaneios da View

@author: 	Marlon Richard Trettin
@since: 	11/06/2015
@Uso: 		SIGAAGR
*/
Static Function fBrwLeg()
	BrwLegenda( STR0027, STR0028, ; //"Romaneios"###"Legenda"
				  {	{ "BR_VERMELHO", X3CboxDesc( "NJJ_STATUS", "0" ) },;	//"Pendente"
					{ "BR_AMARELO" , X3CboxDesc( "NJJ_STATUS", "1" ) },;	//"Completo"
					{ "BR_LARANJA" , X3CboxDesc( "NJJ_STATUS", "2" ) },;	//"Atualizado"
					{ "BR_VERDE"   , X3CboxDesc( "NJJ_STATUS", "3" ) },;	//"Encerrado"
					{ "BR_CANCEL"  , X3CboxDesc( "NJJ_STATUS", "4" ) } } )	//"Cancelado"
Return( NIL )

/** {Protheus.doc} OGA440HIS
Mostra em tela de Historico

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	08/07/2015
@Uso: 		OGA440 
*/
Function OGA440HIS()
	Local cChaveI := "NKM->(" + Alltrim( AgrSeekDic( "SIX", "NKM1", 1, "CHAVE" ) ) + ")"
	Local cChaveA := &(cChaveI) + Space( Len( NK9->NK9_CHAVE ) - Len( &cChaveI ) )

	AgrHistTabe( "NKM", cChaveA )
Return( NIL )

/*/{Protheus.doc} StNfe
Função que retorna a cor da legenda conforme status da Nota fiscal vinculada ao item do romaneio
@type  Static Function
@author rafael.kleestadt
@since 01/02/2018
@version 1.0
@param param, param_type, param_descr
@return cRetorno, caractere, caractere que indica a legenda que será exibida no campo posicionado.
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
/*/
Function fLegNfe(nOpc)
	Local cRetorno := "####"
	Local aAreaAtu := GetArea()
	Local cStaNfe  := StNfe()
	
	Default nOpc := 1
	
	If nOpc == 1
		
		Do Case 
			Case cStaNfe == "S"	      // NF Autorizada
				cRetorno := "ENABLE"
			Case cStaNfe == " "	      // NF Não Transmitida
				cRetorno := "DISABLE"
			Case cStaNfe == "T"	      // NF Transmitida
				cRetorno := "BR_AZUL"
			Case cStaNfe == "N"	      // NF Não Autorizada
				cRetorno := "BR_PRETO"
			Case cStaNfe == "D"	      // NF Uso Denegado
				cRetorno := "BR_CINZA"
		EndCase
	Else
		
		Do Case 
			Case cStaNfe == "S"	      // NF Autorizada
				cRetorno := "NF Autorizada"
			Case cStaNfe == " "	      // NF Não Transmitida
				cRetorno := "NF Não Transmitida"
			Case cStaNfe == "T"	      // NF Transmitida
				cRetorno := "NF Transmitida"
			Case cStaNfe == "N"	      // NF Não Autorizada
				cRetorno := "NF Não Autorizada"
			Case cStaNfe == "D"	      // NF Uso Denegado
				cRetorno := "NF Uso Denegado"
		EndCase
	Endif
	
	RestArea( aAreaAtu )

Return ( cRetorno ) 

/*/{Protheus.doc} StNfe
Função que retorna o status da Nota fiscal vinculada ao item do romaneio
@type  Static Function
@author rafael.kleestadt
@since 01/02/2018
@version 1.0
@param param, param_type, param_descr
@return cStaNfe, caractere, valor do campo F1_FIMP/F2_FIMP da Nf vinculada ao item do romaneio 
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
/*/
Static Function StNfe()
Local cStaNfe := ' '

If !IsInCallStack("OGC003") .Or. Type('cQryFixo') == "U"

	If fPosicNJJ( NJM->( NJM_FILIAL ), NJM->( NJM_CODROM ) )//Posiciona no romaneio
	
		If NJJ->( NJJ_TIPO ) $ "2|4|6|8|11" // Se tipo do romaneio for de SAÍDA
	
			DbSelectArea( "SC5" )       
			DbSetOrder( 1 ) 
			//C5_FILIAL+C5_NUM       
			If DbSeek( NJM->( NJM_FILIAL + NJM_PEDIDO ) )
				DbSelectArea( "SF2" )       
				DbSetOrder( 1 ) 
				//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO       
				If DbSeek( xFilial( "SF2" ) + SC5->( C5_NOTA + C5_SERIE + C5_CLIENTE + C5_LOJACLI ) )
					cStaNfe := SF2->( F2_FIMP )
				EndIf
				SF2->(DbCloseArea())
			EndIf
			SC5->(DbCloseArea())
	
		Else // Se tipo do romaneio for de ENTRADA
	
			//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
			aCliFor := OGA250ClFr( NJM->( NJM_CODENT ), NJM->( NJM_LOJENT ), NJM->( NJM_TES ), NJM->( NJM_TIPO ), NJM->( NJM_QTDFIS ) )
			cTipoNF	:= aCliFor[1]
			cCliFor	:= aCliFor[2]
			cLoja 	:= aCliFor[3]
	
			DbSelectArea( "SF1" )
			DbSetOrder( 1 ) 
			//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If DbSeek( xFilial( "SF1" ) + NJM->( NJM_DOCNUM ) + NJM->( NJM_DOCSER ) + cCliFor + cLoja )
				cStaNfe := SF1->( F1_FIMP )
			EndIf
			SF1->(DbCloseArea())
	
		EndIf
	
	EndIf
Else	

	If Type('cQryFixo') != "U"
	
		If fPosicNJJ( (cQryFixo)->NJM_FILIAL, (cQryFixo)->NJM_CODROM )//Posiciona no romaneio
		
			If (cQryFixo)->NJM_TIPO $ "2|4|6|8|11" // Se tipo do romaneio for de SAÍDA
			
				//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
				aCliFor := OGA250ClFr( (cQryFixo)->NJM_CODENT, (cQryFixo)->NJM_LOJENT, (cQryFixo)->NJM_TES , (cQryFixo)->NJM_TIPO, (cQryFixo)->NJM_QTDFIS )
				cTipoNF	:= aCliFor[1]
				cCliFor	:= aCliFor[2]
				cLoja 	:= aCliFor[3]
		
				DbSelectArea( "SC5" )       
				DbSetOrder( 1 ) 
				//C5_FILIAL+C5_NUM       
				If DbSeek( (cQryFixo)->( NJM_FILIAL + NJM_PEDIDO ) ) 
					DbSelectArea( "SF2" )       
					DbSetOrder( 1 ) 
					//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO       
					If DbSeek( xFilial( "SF1" ) + (cQryFixo)->NJM_DOCNUM + (cQryFixo)->NJM_DOCSER + cCliFor + cLoja )
						cStaNfe := SF2->( F2_FIMP )
					EndIf
					SF2->(DbCloseArea())
				EndIf
				SC5->(DbCloseArea())
		
			Else // Se tipo do romaneio for de ENTRADA
		
				//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
				aCliFor := OGA250ClFr( (cQryFixo)->NJM_CODENT, (cQryFixo)->NJM_LOJENT, (cQryFixo)->NJM_TES , (cQryFixo)->NJM_TIPO, (cQryFixo)->NJM_QTDFIS )
				cTipoNF	:= aCliFor[1]
				cCliFor	:= aCliFor[2]
				cLoja 	:= aCliFor[3]
		
				DbSelectArea( "SF1" )
				DbSetOrder( 1 ) 
				//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If DbSeek( xFilial( "SF1" ) + (cQryFixo)->NJM_DOCNUM + (cQryFixo)->NJM_DOCSER + cCliFor + cLoja )
					cStaNfe := SF1->( F1_FIMP )
				EndIf
				SF1->(DbCloseArea())
		
			EndIf
		
		EndIf
	EndIF

EndIf


Return cStaNfe

/*/{Protheus.doc} fBrwLegNf()
Função que exibe a legenda do status da Nota fiscal vinculada ao item do romaneio
@type  Static Function
@author rafael.kleestadt
@since 01/02/2018
@version 1.0
@param param, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
/*/
Static Function fBrwLegNf()

	BrwLegenda( STR0043, STR0028, ; //"Notas Fiscais"###"Legenda"
				{ { "DISABLE",  STR0044 },;  //"NF Não Transmitida/Gerada"
				  { "ENABLE",   STR0045 },;  //NF Autorizada
				  { "BR_AZUL" , STR0046 },;  //NF Transmitida
				  { "BR_CINZA", STR0047 },;  //NF Uso Denegado	
				  { "BR_PRETO", STR0048 } } )//NF Não Autorizada
			
Return( NIL )

/*/{Protheus.doc} LoadLegnd

Rotina que exibe o log do processamento no duplo click do campo NKM_STATUS

@sample    LoadLegnd(oFormulario,cFieldName,nLineGrid,nLineModel,oView)

@param      oFormulario - Objeto do Formulário
            cFieldName  - Nome do Campo
            nLineGrid   - Linha do Grid
            nLineModel  - Linha do Model    
            oView - Objetio do modelo de interface

@author     Thiago Henrique Rover
@since      16/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function LoadLegnd( oFormulario, cFieldName, nLineGrid, nLineModel, oView )
    Default oFormulario := Nil
    Default oView       := Nil
    Default cFieldName  := ""
    Default nLineGrid   := 0
    Default nLineModel  := 0

    If ( oView <> Nil .And. ValType(oView) == "O" .And. cFieldName == "TMP_STANFE" ) 
        
         fBrwLegNf()
    Elseif oView <> Nil .And. ValType(oView) == "O" .And. cFieldName == "TMP_STATUS"
    
    	fBrwLeg()
    EndIf
Return

/*/{Protheus.doc} OGA440NFE()
Função para chamar o monitor de Nfe e setar a filial da nota do romaneio.
@type  Static Function
@author rafel.kleestadt
@since 25/05/2018
@version 1.0
@param param, param_type, param_descr
@return .T., Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGA440NFE(nOpc)
Local cFilBkp    := cFilAnt

Local oModel := FwModelActive()
Local oNJM   := Nil

Default nOpc := 1

If nOpc == 1

	oNJM := oModel:GetModel( "NJMUNICO" )

	cFilAnt := oNJM:GetValue( "NJM_FILIAL" )
ElseIf nOpc == 2

	cFilAnt := (cAlT2)->NJJ_FILIAL
EndIF

SPEDNFE()

cFilAnt := cFilBkp

Return .T.