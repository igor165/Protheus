#INCLUDE "JURA106.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static xVarSugFw   	:= NIL 	// Variavel Static  para passagem de valores entre funcoes
Static xVarCodFw   	:= ''	// Variavel Static do Código do Follow-up para passagem de valores entre funções
Static xVarAutPag	:= ''	// Variavel Static para passagem de valor para a criacao do andamento

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106
Follow-ups

@param  cProcesso   Código do processo vigente
@param  lPesq   	    .T. - Indica que a rotina foi chamada pela tela de
											Pesquisa(JURA106) ou
											.F. - Indica que a rotina foi chamada por dentro
											do Processo(JURA095) via ações relacionadas

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106( cProcesso, lChgAll, cFilFiltro )

	Local cHabPesqF	:= SuperGetMV("MV_JHBPESF",, '1') //“Habilita a tela de pesquisa de follow-ups (1=Sim;2=Não)"
	Local oBrowse
	Local aArea     := GetArea()
	Local aAreaNSZ  := NSZ->( GetArea() )

	Default cProcesso  := ''
	Default cFilFiltro := xFilial("NTA")
	Default lChgAll	   := .T.


	If cHabPesqF == '1' .AND. !(IsInCallStack( 'JURA095' ) .Or. IsInCallStack( 'JURA162' ).Or. IsInCallStack('JURA219'))
		MsgRun(STR0046,STR0047, {||JURA162("2",STR0007,"JURA106")}) //"Carregando..." # "Aguarde..."
	Else
		oBrowse := FWMBrowse():New()
		oBrowse:SetChgAll( lChgAll )
		oBrowse:SetDescription( STR0007 )
		oBrowse:SetAlias( "NTA" )
		oBrowse:SetLocate()
		//oBrowse:DisableDetails()
		If !Empty( cProcesso )
			oBrowse:SetFilterDefault( "NTA_FILIAL == '" + cFilFiltro + "' .AND. NTA_CAJURI == '" + cProcesso + "'" )
		EndIf
		oBrowse:SetMenuDef( 'JURA106' )
		JurSetBSize( oBrowse, '50,50,50' )
		JurSetLeg( oBrowse, "NTA"  )
		oBrowse:Activate()
		RestArea( aAreaNSZ )
		RestArea( aArea )
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	Local lJ106Menu		:= ExistBlock("J106MENU")

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0021, "JurAnexos('NTA', NTA->NTA_COD, 1)", 0, 1, 0, .T. } ) // "Anexos"

	If JA162AcRst('05')
		aAdd( aRotina, { STR0002, "VIEWDEF.JURA106", 0, 2, 0, NIL } ) // "Visualizar"
	EndIf

	If JA162AcRst('05',3 )
		aAdd( aRotina, { STR0003, "VIEWDEF.JURA106", 0, 3, 0, NIL } ) // "Incluir"
	EndIf
	If JA162AcRst('05',4 )
		aAdd( aRotina, { STR0004, "VIEWDEF.JURA106", 0, 4, 0, NIL } ) // "Alterar"
	EndIf
	If JA162AcRst('05',5 )
		aAdd( aRotina, { STR0005, "VIEWDEF.JURA106", 0, 5, 0, NIL } ) // "Excluir"
	EndIf
	If JA162AcRst('05',3 )
		aAdd( aRotina, { "Copiar", "VIEWDEF.JURA106", 0, 9, 0, NIL } ) // 'Copiar'
	EndIf

	//Ponto de Entrada para adicionar novas funções no
	//Ações Relacionadas do Browse de Follow-ups.
	If lJ106Menu
		uRotina := ExecBlock("J106MENU",.F.,.F.,{aRotina})
		If ValType(uRotina) == "A"
			aRotina := aClone(uRotina)
	    EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Follow-ups

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel     := FWLoadModel( "JURA106" )
	Local oStruct
	Local oStructNTE := FWFormStruct( 2, "NTE" )
	//Local oStructNTF := FWFormStruct( 2, "NTF" ) comentado enquanto a rotina não está pronta
	Local aBotoes    := {}
	Local cTipoAs    := ""
	Local cTipoAsP   := ""
	Local cCajuri    := JA106CAJUR() //Pega o cajuri usando a função usada no inicializador padrão

	If Empty(AllTrim(cCajuri)) // Caso seja visualização a função JA106CAJUR() retornará vazio e a variável deverá ser preenchida com o conteúdo gravado na tabela.
		cCajuri := NTA->NTA_CAJURI
	EndIf

	If Type("cTipoAj") == 'U'
		cTipoAJ := 'CFG' //Indica que se trata da configuração de papeis de trabalho feitos pelo SIGACFG
		cTipoAs := cTipoAj
	ElseIf !Empty(AllTrim(cTipoAj)) //Private vinda da JURA162
		If cTipoAj == JurGetDados("NSZ",1,XFILIAL("NSZ")+cCajuri, "NSZ_TIPOAS")
			cTipoAs := JurGetDados("NSZ",1,XFILIAL("NSZ")+cCajuri, "NSZ_TIPOAS")
		Else
			cTipoAs := cTipoAj
		EndIf
	Else
		cTipoAs := JurGetDados("NSZ",1,XFILIAL("NSZ")+cCajuri, "NSZ_TIPOAS")
	EndIf

	cTipoAsP  := cTipoAs

	If cTipoAsP > '050' .And. cTipoAsP != 'CFG'
		cTipoASP := JurGetDados('NYB', 1, xFilial('NYB') + cTipoAS, 'NYB_CORIG')
	EndIf

	If cTipoAJ != 'CFG'
		oStruct    := FWFormStruct( 2, "NTA", { | cCampo | JURCPO(cCampo, xFilial('NTA'), cCajuri, cTipoAS) } ) //restrição normal dos campos.
		JGetNmFld(oStruct, cTipoAs, cTipoAsP)
	Else
		oStruct    := FWFormStruct( 2, "NTA") //quando na tela de papel de trabalho, não ocultar nenhum campo.
	Endif

	JurSetAgrp( 'NTA',, oStruct )

	oStructNTE:RemoveField("NTE_CAJURI")
	oStructNTE:RemoveField("NTE_CFLWP")
	oStructNTE:RemoveField("NTE_CPART")
//oStructNTF:RemoveField( "NTF_CFLWP" )comentado enquanto a rotina não está pronta
//oStructNTF:RemoveField( "NTF_CAJURI" )comentado enquanto a rotina não está pronta

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "JURA106_VIEW"   , oStruct   , "NTAMASTER"  )

	oView:AddGrid ( "JURA106_GRIDNTE", oStructNTE, "NTEDETAIL"  )
//oView:AddGrid ( "JURA106_GRIDNTF", oStructNTF, "NTFDETAIL"  )comentado enquanto a rotina não está pronta

	oView:CreateFolder("FOLDER_01")
	oView:AddSheet("FOLDER_01", "ABA_01_01", STR0007 )
//oView:AddSheet("FOLDER_01", "ABA_01_02", STR0013 )comentado enquanto a rotina não está pronta

	oView:createHorizontalBox("BOX_01_F01_A01", 70,,,"FOLDER_01","ABA_01_01")
	oView:createHorizontalBox("BOX_01_F01_A02", 30,,,"FOLDER_01","ABA_01_01")
//oView:createHorizontalBox("BOX_01_F01_A03",100,,,"FOLDER_01","ABA_01_02")comentado enquanto a rotina não está pronta

	oView:CreateFolder("FOLDER_02","BOX_01_F01_A02")
	oView:AddSheet("FOLDER_02","ABA_02_01", STR0010)

	oView:createHorizontalBox("BOX_01_F02_A01",100,,,"FOLDER_02","ABA_02_01")

	oView:SetOwnerView( "JURA106_VIEW"   , "BOX_01_F01_A01" )
	oView:SetOwnerView( "JURA106_GRIDNTE", "BOX_01_F02_A01" )
//oView:SetOwnerView( "JURA106_GRIDNTF", "BOX_01_F01_A03" )comentado enquanto a rotina não está pronta

	oView:SetDescription( STR0007 ) // "Follow-ups"
	oView:EnableControlBar( .T. )

	If Existblock( 'J106RETBOT' )
		aBotoes := Execblock('J106RETBOT', .F., .F.)
	EndIf

	If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT01"} ) <= 0 ) ) .And. JA162AcRst('03')
		oView:AddUserButton( STR0021, "CLIPS", {| oView | IIF( J95AcesBtn(), JurAnexos("NTA", NTA->NTA_COD, 1), FWModelActive()) } )
	EndIf

//Fluxo de correspondente 1=Follow-up
	If SuperGetMV("MV_JFLXCOR", , 1) == 1
		oView:AddUserButton( STR0092, "BMPPOST", { |oView| BtnReenWfC() } )		//"Reenvia WF"
	EndIf

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Follow-ups

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0

@obs NTAMASTER - Dados do Follow-ups

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStruct    := FWFormStruct( 1, "NTA" )
	Local oStructNTE := FWFormStruct( 1, "NTE" )
	Local oStructNZK
	Local oStructNZM
	//Local oStructNTF := FWFormStruct( 1, "NTF" )comentado enquanto a rotina não está pronta
	Local lNteCajuri := oStructNTE:HasField("NTE_CAJURI")		//Campo ira existir no release 12.1.9
	Local lNZKInDic  := FWAliasInDic("NZK") //Verifica se existe a tabela NZK no Dicionário (Proteção)
	Local lNZMInDic  := FWAliasInDic("NZM") //Verifica se existe a tabela NZM no Dicionário (Proteção)
	Local lWSTLegal  := JModRst()

	If lNteCajuri
		oStructNTE:RemoveField("NTE_CAJURI")
	EndIf

	If lNZKInDic
		oStructNZK := FWFormStruct( 1, "NZK" )
		oStructNZK:RemoveField( "NZK_CFLWP" )
	EndIf

	If lNZMInDic
		oStructNZM := FWFormStruct( 1, "NZM" )
		oStructNZM:RemoveField( "NZM_CFLWP" )
	EndIf

	oStructNTE:RemoveField( "NTE_CFLWP" )
	//oStructNTF:RemoveField( "NTF_CFLWP" )comentado enquanto a rotina não está pronta
	//oStructNTF:RemoveField( "NTF_CAJURI" )comentado enquanto a rotina não está pronta

	oStruct:AddField( ;
	STR0123        , ;     // [01] Titulo do campo   //"Obs Fluig"
	STR0124        , ;     // [02] ToolTip do campo  //"Observacao do Executor Fluig"
	"NTA__OBSER"   , ;     // [03] Id do Field
	"M"            , ;     // [04] Tipo do campo
	10             , ;     // [05] Tamanho do campo
	0              , ;     // [06] Decimal do campo
	NIL            , ;     // [07] Code-block de validação do campo
	NIL            , ;     // [08] Code-block de validação When do campo
	NIL            , ;     // [09] Lista de valores permitido do campo
	.F.            )       // [10] Indica se o campo tem preenchimento obrigatório

	oStruct:AddField( ;
	STR0125       , ;     // [01] Titulo do campo   //"Valor Fluig"
	STR0126       , ;     // [02] ToolTip do campo  //"Valor aprovacao Fluig"
	"NTA__VALOR"  , ;     // [03] Id do Field
	"N"           , ;     // [04] Tipo do campo
	12            , ;     // [05] Tamanho do campo
	2             , ;     // [06] Decimal do campo
	NIL           , ;     // [07] Code-block de validação do campo
	NIL           , ;     // [08] Code-block de validação When do campo
	NIL           , ;     // [09] Lista de valores permitido do campo
	.F.           )       // [10] Indica se o campo tem preenchimento obrigatório

	oStruct:AddField( ;
	STR0163                                  , ;     // [01] Titulo do campo   //"Número do Caso"
	STR0163                                  , ;     // [02] ToolTip do campo  //"Número do Caso"
	"NTA__NUMCAS"                            , ;     // [03] Id do Field
	GetSx3Cache("NSZ_NUMCAS", "X3_TIPO")     , ;     // [04] Tipo do campo
	GetSx3Cache("NSZ_NUMCAS", "X3_TAMANHO")  , ;     // [05] Tamanho do campo
	GetSx3Cache("NSZ_NUMCAS", "X3_DECIMAL")  , ;     // [06] Decimal do campo
	NIL                                      , ;     // [07] Code-block de validação do campo
	NIL                                      , ;     // [08] Code-block de validação When do campo
	NIL                                      , ;     // [09] Lista de valores permitido do campo
	.F.           )                                  // [10] Indica se o campo tem preenchimento obrigatório

	If lWSTLegal // Se a chamada estiver vindo do TOTVS Legal
		//Campo que indica se o registro posicionado possui anexo - criado para o TOTVS Legal
		oStruct:AddField( ;
			""                                                 , ; // [01] Titulo do campo
			""		                                           , ; // [02] ToolTip do campo
			"NTA__TEMANX"                                      , ; // [03] Id do Field
			"C"                                                , ; // [04] Tipo do campo
			2                                                  , ; // [05] Tamanho do campo
			0                                                  , ; // [06] Decimal do campo
			,                                                    ; // [07] Bloco de código de validação do campo
			,                                                    ; // [08] Bloco de código de validação when do campo
			,                                                    ; // [09] Lista de valores permitido do campo
			,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
			{|| JTemAnexo("NTA",NTA->NTA_CAJURI,NTA->NTA_COD)} , ; // [11] Bloco de código de inicialização do campo
			,                                                    ; // [12] Indica se trata-se de um campo chave
			,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                                  ; // [14] Indica se o campo é virtual
			,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
	Endif

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA106", /*Pre-Validacao*/, {|oX| JURA106TOK(oX)}/*Pos-Validacao*/, {|oX| JURA106COM(oX)}/*Commit*/,/*Cancel*/)
	oModel:AddFields( "NTAMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:AddGrid( "NTEDETAIL", "NTAMASTER" /*cOwner*/, oStructNTE, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	//oModel:AddGrid( "NTFDETAIL", "NTAMASTER" /*cOwner*/, oStructNTF, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )comentado enquanto a rotina não está pronta

	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Follow-ups"
	oModel:GetModel( "NTAMASTER" ):SetDescription( STR0009 ) // "Dados de Follow-ups"

	oModel:GetModel( "NTEDETAIL" ):SetUniqueLine( { "NTE_CPART" } )
	//oModel:GetModel( "NTFDETAIL" ):SetUniqueLine( { "NTF_CADVCR" , "NTF_CENVOL" , "NTF_CPREPO" } )comentado enquanto a rotina não está pronta

	oModel:SetRelation( "NTEDETAIL", { { "NTE_FILIAL", "XFILIAL('NTE')" }, { "NTE_CFLWP", "NTA_COD" },{ "NTE_CAJURI", "NTA_CAJURI" }  }, NTE->( IndexKey( 1 ) ) )
	//oModel:SetRelation( "NTFDETAIL", { { "NTF_FILIAL", "XFILIAL('NTF')" }, { "NTF_CFLWP", "NTA_COD" } }, NTF->( IndexKey( 1 ) ) )comentado enquanto a rotina não está pronta

	oModel:GetModel( "NTEDETAIL" ):SetDescription( STR0010 ) //"Responsaveis"

	If lNZKInDic
		oModel:AddGrid( "NZKDETAIL", "NTAMASTER" /*cOwner*/, oStructNZK, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		oModel:GetModel( "NZKDETAIL" ):SetUniqueLine( { "NZK_FONTE", "NZK_MODELO", "NZK_CAMPO" } )
		oModel:SetRelation( "NZKDETAIL", { { "NZK_FILIAL", "XFILIAL('NZK')" }, { "NZK_CFLWP", "NTA_COD" } }, NZK->( IndexKey( 1 ) ) )
		oModel:GetModel( "NZKDETAIL" ):SetDescription( "Tarefas" ) //???
		oModel:GetModel( "NZKDETAIL" ):SetDelAllLine( .F. )
		oModel:GetModel( "NZKDETAIL" ):SetUseOldGrid( .F. )
		oModel:SetOptional( "NZKDETAIL" , .T. )
		JurSetRules( oModel, 'NZKDETAIL',, 'NZK' )
	EndIf

	If lNZMInDic
		oModel:AddGrid( "NZMDETAIL", "NTAMASTER" /*cOwner*/, oStructNZM, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		oModel:GetModel( "NZMDETAIL" ):SetUniqueLine( { "NZM_CSTEP", "NZM_CAMPO" } )
		oModel:SetRelation( "NZMDETAIL", { { "NZM_FILIAL", "XFILIAL('NZM')" }, { "NZM_CFLWP", "NTA_COD" } }, NZM->( IndexKey( 1 ) ) )
		oModel:GetModel( "NZMDETAIL" ):SetDescription( "Destino WF Fluig" ) //???
		oModel:GetModel( "NZMDETAIL" ):SetDelAllLine( .F. )
		oModel:GetModel( "NZMDETAIL" ):SetUseOldGrid( .F. )
		oModel:SetOptional( "NZMDETAIL" , .T. )
		JurSetRules( oModel, 'NZMDETAIL',, 'NZM' )
	EndIf

	If !lWSTLegal
		oModel:SetActivate ( { |oX| JA106INCPS( oX ) } )
	EndIf
	oModel:GetModel( "NTEDETAIL" ):SetDelAllLine( .F. )
	oModel:GetModel( "NTEDETAIL" ):SetUseOldGrid( .F. )

	JurSetRules( oModel, 'NTAMASTER',, 'NTA' )
	JurSetRules( oModel, 'NTEDETAIL',, 'NTE' )
	//JurSetRules( oModel, 'NTFDETAIL',, 'NTF' )comentado enquanto a rotina não está pronta

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106AVA
Verifica se o tipo de follow-up tem configuração para avaliação
obrigatória
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 20/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
/*comentado enquanto a rotina não está pronta
Function JURA106AVA()
Local lRet     := .F.
Local aArea    := GetArea()
Local oModel   := FWModelActive()

lRet := Posicione('NQS', 1 , xFilial('NQS') + oModel:GetValue('NTAMASTER','NTA_CTIPO') , 'NQS_AVALIA') == '1'

RestArea( aArea )

Return lRet*/

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106TAV
Verifica se já existe avaliação de participação para o follow-up
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 29/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
/*comentado enquanto a rotina não está pronta
Function JURA106TAV()
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := ""
Local oModel   := FWModelActive()
Local cFollowup:= oModel:GetValue('NTAMASTER','NTA_COD')
Local cAlias   := GetNextAlias()

cQuery += "SELECT COUNT(*) NTF_QTDE"
cQuery += " FROM "+RetSqlName("NTF")+" NTF"
cQuery += " WHERE NTF_FILIAL = '"+xFilial("NTF")+"'"
cQuery += " AND NTF_CFLWP = '"+cFollowup+"'"
cQuery += " AND NTF.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

if !Eof()
	lRet := (cAlias)->NTF_QTDE == 0
endif

(cAlias)->( dbcloseArea() )
RestArea( aArea )

Return lRet*/

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106DPD
Valida se o tipo de follow-up está configurado para sugerir a descrição
ao incluir um follow-up
Uso no cadastro de Follow-ups (gatilho no campo de Tipo).

@param 	cTipo  		Tipo a ser verificado
@Return cDescPad	Descrição padrão
@sample

@author Juliana Iwayama Velho
@since 20/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106DPD(cTipo)
	Local cDescPad := ""
	Local oModel   := FWModelActive()
	Local nOpc     := oModel:GetOperation()
	Local aArea    := GetArea()

	cDescPad := oModel:GetValue('NTAMASTER','NTA_DESC')

	If nOpc == 3

		If Posicione('NQS', 1 , xFilial('NQS') + cTipo , 'NQS_SUGDES') == '1'

			cDescPad := Posicione('NQS', 1 , xFilial('NQS') + cTipo , 'NQS_DESPAD')

		EndIf

	EndIf

	RestArea( aArea )

Return cDescPad

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106NQN
Valida se o resultado de follow-up é do tipo concluido
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 20/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106NQN()
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local oModel   := FWModelActive()

	lRet := Posicione('NQN', 1 , xFilial('NQN') + oModel:GetValue('NTAMASTER','NTA_CRESUL') , 'NQN_TIPO') == '2'

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample
oModel:AddFields( "NTAMASTER", NIL, oStruct,, {|oX| JURA106TOK(oX)})

@author Juliana Iwayama Velho
@since 20/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106TOK(oModel)

	Local lRet       := .T.
	Local aArea      := GetArea()
	Local aAreaNTA   := NTA->( GetArea() )
	Local nOpc       := oModel:GetOperation()
	Local cRespons   := AllTrim(oModel:GetValue('NTEDETAIL','NTE_CPART'))
	//Local oM       := oModel:GetModel( 'NTFDETAIL')comentado enquanto a rotina não está pronta
	Local cFwpPrinc  := ''
	Local cAndPrinc  := ''
	Local cAto       := ''
	Local dDtLiAcei  := CtoD("")
	Local cNQNTipo1  := ''              //NQN_TIPO do valor antes da alteração
	Local cNQNTipo2  := ''              //NQN_TIPO do valor alterado
	Local lAltCRESUL := oModel:IsFieldUpdated('NTAMASTER','NTA_CRESUL')
	Local cCResul    := NTA->NTA_CRESUL //Salva o valor do campo antes da alteracao
	Local lProxEve   := oModel:GetModel( 'NTAMASTER' ):HasField('NTA_DTPREV') //Indica se o campo NTA_DTPREV (Data do próximo evento) está no struct para que sejam exibidas suas validações caso necessário
	Local cComplemnt := ''
	Local cValor     := ''
	Local aUltAnd    := {}
	Local cCodRecPai :=''
	Local oModelNZK  := Nil
	Local lNZKInDic  := FWAliasInDic("NZK") //Verifica se existe a tabela NZK no Dicionário (Proteção)
	Local lNZLInDic  := FWAliasInDic("NZL") //Verifica se existe a tabela NZL no Dicionário (Proteção)
	Local lNZMInDic  := FWAliasInDic("NZM") //Verifica se existe a tabela NZM no Dicionário (Proteção)
	Local lFluig     := SuperGetMV('MV_JFLUIGA',,'2') == '1' .And. JurGetDados("NQS", 1, xFilial("NQS") + oModel:GetValue("NTAMASTER","NTA_CTIPO"), "NQS_FLUIG") != '2'
	Local cUsuAlt    := ""

	If lNZKInDic
		oModelNZK := oModel:GetModel( 'NZKDETAIL' )
	EndIf

	If nOpc == 3 .Or. nOpc == 4

		If lRet

			cNQNTipo1 := Posicione('NQN',1,xFilial('NQN')+cCResul,'NQN_TIPO')
			cNQNTipo2 := Posicione('NQN',1,xFilial('NQN')+FwFldGet( 'NTA_CRESUL' ),'NQN_TIPO')

			If M->NTA_DTFLWP < DATE() .And. cNQNTipo2="5" .And. oModel:IsFieldUpdated('NTAMASTER','NTA_DTFLWP') //"Em Andamanto"
				JurMsgErro(STR0159)	//"Não é permitido Follow-Up com data retroativa com Cód. Resultado igual a Em Andamento"
				lRet := .F.
			Endif

			If nOpc == 4 //Alteração
				If (cNQNTipo1="2" .Or. cNQNTipo1="3") .And. cNQNTipo2="5" // "Cancelado/" mudar para "Em Andamanto"
					JurMsgErro(STR0160)	//"Não é permitido alterar um Follow-Up com Cod. Resultado Cancelado ou Concluído para Em Andamento"
					lRet := .F.
				Endif
			Endif
		Endif

		If Empty(cRespons)
			JurMsgErro(STR0035)
			lRet := .F.
		EndIf

		If lRet
			If !Empty(M->NTA_COD)
				JA106setCf(M->NTA_COD)
			ElseIf !Empty(M->NTA_CFLWPP)
				JA106setCf(M->NTA_CFLWPP)
			EndIf
		Endif
	//-----------------------------------------------------------------
	//Verifica o parametro para inclusão com data retroativa
	//-----------------------------------------------------------------
		If lRet
			lRet := JURA106DTR(nOpc,oModel)
		EndIf
	//-----------------------------------------------------------------
	//Verifica o parametro para bloqueio de data em final de semana ou
	//feriado
	//-----------------------------------------------------------------
		If lRet
			lRet := JURA106FDS()
		EndIf
	//-----------------------------------------------------------------
	//Verifica se o tipo de follow-up está configurado pra obrigar o
	//preenchimento da hora
	//-----------------------------------------------------------------
		If lRet
			lRet := JURA106HDU()
		EndIf

	//-----------------------------------------------------------------
	//Verifica onde de ser preenchido o correspondente.
	//-----------------------------------------------------------------
		If lRet
			lRet := JA106VCOR()
		EndIf

	//-----------------------------------------------------------------
	//Verifica se o ato indicado no follow-up ou no tipo é um ato de
	//prazo fixo. Se for deve obrigar preencher a data Próximo Evento
	//-----------------------------------------------------------------
		If lRet
			 if NQS->NQS_SUGERE == '1'
				If !(!JurAuto() .And. ( nOpc == 3 .AND. (Empty(NQS->NQS_CRESUL) .OR. NQS->NQS_CRESUL == FwFldGet( 'NTA_CRESUL' ));
						.OR. nOpc == 4 .AND. lAltCRESUL .And. NQS->NQS_CRESUL == FwFldGet( 'NTA_CRESUL' )))

					lProxEve := .F.
				EndIf
			EndIf

			cAto := oModel:GetValue("NTAMASTER","NTA_CATO")

			If Empty(AllTrim(cAto))
				cAto := JurGetDados("NQS", 1, xFilial("NQS") + oModel:GetValue("NTAMASTER","NTA_CTIPO"), "NQS_CSUGES")
			EndIf

			If lProxEve
				If Empty(oModel:GetValue("NTAMASTER","NTA_DTPREV")) .And. !Empty(AllTrim(cAto)) .And. JurGetDados("NRO",1,xFilial("NR0")+cAto,"NRO_PRFIXO") == '1'
					lRet := .F.
					JurMsgErro(STR0098) //Foi indicado um ato de prazo fixo, portanto preencha o campo de Data do Próximo Evento.
				ElseIf !Empty(oModel:GetValue("NTAMASTER","NTA_DTPREV"))
					If !Empty(AllTrim(cAto)) .And. JurGetDados("NRO",1,xFilial("NRO")+cAto,"NRO_PRFIXO") <> '1'
						oModel:LoadValue("NTAMASTER",'NTA_DTPREV', CToD('') )
					EndIf
					If !Empty(oModel:GetValue("NTAMASTER","NTA_DTPREV")) .And. oModel:GetValue("NTAMASTER","NTA_DTPREV") < oModel:GetValue("NTAMASTER","NTA_DTFLWP")
						lRet := .F.
						JurMsgErro(STR0105)//'Data do próximo evento não pode ser inferior a data do follow-up'
					EndIf
				EndIf
			EndIf
		EndIf

		//-----------------------------------------------------------------
		//Atualiza data limite para aceite de correspondente.
		//-----------------------------------------------------------------
		If 	oModel:IsFieldUpdated('NTAMASTER', 'NTA_CCORRE') .Or. oModel:IsFieldUpdated('NTAMASTER', 'NTA_CADVCR') .Or.;
				oModel:IsFieldUpdated('NTAMASTER', 'NTA_DTFLWP')


			If Empty( FwFldGet( "NTA_CCORRE" ) )
				dDtLiAcei := CtoD("")
			Else
			//Pega a data Limite para Aceite do correspondente
				dDtLiAcei := CalcDtLiAc( oModel )
			EndIf
			oModel:SetValue("NTAMASTER", 'NTA_DTLIAC', dDtLiAcei)
		EndIf

		If lRet
			If nOpc == 3
				//-----------------------------------------------------------------
				//Preenche a data original com a data do follow-up ao incluí-lo
				//-----------------------------------------------------------------
				If lRet
					oModel:LoadValue("NTAMASTER",'NTA_DTORIG', FwFldGet( 'NTA_DTFLWP' ) )
				EndIf

				If lRet .And. SuperGetMV('MV_JVINCAF',, '2') == '1' //.And. IsInCallStack( 'JURA100COM')
					JA106SetCf( oModel:GetValue("NTAMASTER","NTA_COD") )
				EndIf

			ElseIf nOpc == 4
				oModel:SetValue("NTAMASTER",'NTA_DTALT' ,DATE())
				If !Empty(__CUSERID)
					oModel:LoadValue("NTAMASTER",'NTA_USUALT',Left( PswChave(__CUSERID), TamSX3('NTA_USUALT')[1] ) )
				EndIf
				//-----------------------------------------------------------------
				//Verifica a alteração do resultado do follow-up, para preenchimento
				//do campos
				//-----------------------------------------------------------------
				If oModel:IsFieldUpdated('NTAMASTER','NTA_CRESUL') .And.;
						(Posicione('NQN', 1 , xFilial('NQN') + oModel:GetValue('NTAMASTER','NTA_CRESUL'), 'NQN_TIPO') == '2' .Or.;
						Posicione('NQN', 1 , xFilial('NQN') + oModel:GetValue('NTAMASTER','NTA_CRESUL'), 'NQN_TIPO') == '3')

					oModel:SetValue("NTAMASTER",'NTA_DTCON' ,DATE())
						oModel:LoadValue("NTAMASTER",'NTA_USUCON',Left( PswChave(__CUSERID), TamSX3('NTA_USUCON')[1] ) )
			
				EndIf
				//-----------------------------------------------------------------
				//Reagenda o follow-up ao alterar a data e o mesmo estiver pendente
				//-----------------------------------------------------------------
				If (oModel:IsFieldUpdated('NTAMASTER','NTA_DTFLWP') .Or. oModel:IsFieldUpdated('NTAMASTER','NTA_HORA')) .And. ;
						Posicione('NQN', 1 , xFilial('NQN') + oModel:GetValue('NTAMASTER','NTA_CRESUL'), 'NQN_TIPO') == '1'

					oModel:SetValue("NTAMASTER",'NTA_REAGEN' ,'1')

					//alterar a data do prazo no fluig
					if !( Empty(FwFldGet( 'NTA_CODWF' )) ) .And. lFluig
						J106WFReag(FwFldGet( 'NTA_CODWF' ), FwFldGet( 'NTA_DTFLWP' ), FwFldGet( 'NTA_HORA' ))
					Endif
				EndIf
			EndIf
		EndIf

		If lRet .AND. SuperGetMV("MV_JFLXCOR", , 1) == 1
			If oModel:GetValue('NTAMASTER','NTA_ACEITO') == '1'
				If (oModel:IsFieldUpdated('NTAMASTER','NTA_CCORRE') .OR. oModel:IsFieldUpdated('NTAMASTER','NTA_LCORRE')) .AND. (!EMPTY(NTA->NTA_CCORRE) .AND. !EMPTY(NTA->NTA_LCORRE))
					oModel:LoadValue("NTAMASTER",'NTA_ACEITO' ,'3')
				ElseIf EMPTY(oModel:GetValue('NTAMASTER','NTA_CCORRE')) .OR. EMPTY(oModel:GetValue('NTAMASTER','NTA_LCORRE'))
					JurMsgErro(STR0119)//"É necessário preencher os campos de correspondente"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If nOpc > 2 .And. lRet
		cUsuAlt := Left( oModel:GETValue("NTAMASTER", "NTA_DCORRE"), TamSX3('NTA_USUALT')[1] )
		lRet := JURSITPROC(oModel:GetValue("NTAMASTER","NTA_CAJURI"), 'MV_JTVENFW',,,cUsuAlt)

		// Exclusão de Follow-Up
		If nOpc == 5 .And. lRet

			If lRet .And. ;
			   JurGetDados('NQN',1,xFilial('NQN')+oModel:GetValue("NTAMASTER","NTA_CRESUL"),'NQN_TIPO') == "4" .And. ;
			   !Empty(oModel:GetValue("NTAMASTER","NTA_CODWF"))

				lRet := .F.
				JurMsgErro(STR0155 + oModel:GetValue("NTAMASTER","NTA_CODWF")) // "Existe um workflow no FLUIG para este follow-up que está pendente de aprovação. Acesse o FLUIG e procure pelo workflow "

			EndIf

			If lRet
				// Guarda código do Follow-up pai para ser usado na exclusão de andamentos
				cCodRecPai:=RecPai(oModel:GetValue("NTAMASTER","NTA_COD"))

				//Executa Rotina de Exclusão de andamentos
				lRet := JA106EXCL(oModel:GetValue("NTAMASTER","NTA_COD"))

				If lRet == .F.
					//Operação cancelada pelo usuário.
					JurMsgErro(STR0150)
				EndIf
			EndIf

			// Verificar se há integração de Andamentos e follow-ups para exclusão de andamentos
			If lRet .And. SuperGetMV('MV_JVINCAF',, '2') == '1'
				cFwpPrinc := cCodRecPai //NTA->NTA_COD Raiz
				cAndPrinc := JurGetDados("NTA", 1, xFilial("NTA") + cCodRecPai, "NTA_CANDAM")
				JA106SetCf(cFwpPrinc)
				lRet := JA106VincA(1,cFwpPrinc,cAndPrinc)
				If lRet
					lRet := JA106VincA(2,cFwpPrinc,cAndPrinc)
				EndIf
			EndIf

			If lRet//Exclui os documentos anexados ao excluir o registro-pai.
				lRet := JurExcAnex('NTA',oModel:GetValue("NTAMASTER","NTA_COD"),oModel:GetValue("NTAMASTER", "NTA_CAJURI"))
			EndIf
		EndIf
	EndIf

	if lRet .And. SuperGetMV('MV_JINTJUR',, '2') == '1'
		JurIntJuri(oModel:GetValue("NTAMASTER","NTA_COD"),oModel:GetValue("NTAMASTER","NTA_CAJURI"), "3", Str(nOpc))
	Endif

	If lRet .And. oModel:GetValue("NTAMASTER","NTA_ACEITO") == "2" .And. Empty(oModel:GetValue("NTAMASTER","NTA_JUSTIF"))
		JurMsgErro(STR0012+RetTitle("NTA_JUSTIF"))
		lRet := .F.
	EndIf

	If lRet .And. nOpc == 4 .And. SuperGetMV("MV_JFLXCOR", , 1) == 1 .And. oModel:IsFieldUpdated("NTAMASTER","NTA_ACEITO")
		J106RPCOR(oModel)
	Endif

	//Se utiliza integração com o Fluig ('1') ou não utiliza ('2').
	If lNZKInDic .And. lNZLInDic .And. lNZMInDic .And. lRet .And. (cValToChar(nOpc) $ "34") .And. (lFluig) .And.;
			!( IsInCallStack('MTJurSyncFollowUp') ) /*Origem nao é do Webservice Fluig*/

		If (nOpc == 4) .And. lAltCRESUL .And. !( Empty(FwFldGet( 'NTA_CODWF' )) )

			cNQNTipo1 := Posicione('NQN',1,xFilial('NQN')+cCResul,'NQN_TIPO')

			cNQNTipo2 := Posicione('NQN',1,xFilial('NQN')+FwFldGet( 'NTA_CRESUL' ),'NQN_TIPO')

			If (cNQNTipo1 == '1') .And. (cNQNTipo2 == '2') //DE Pendente PARA Concluido
				If  Empty(Posicione('NQS',1,xFilial('NQS')+FwFldGet( 'NTA_CTIPO' ),'NQS_CSUGES')) //Sugestao de andamento
					MsgInfo(STR0127)	//"Para concluir este follow-up, será necessário a inclusão de um andamento!"
				Endif

				//valida se a alteração da descrição ja foi feita
				if !oModel:IsFieldUpdated('NTAMASTER','NTA_DESC')
					MsgInfo(STR0127)	//"Para concluir este follow-up, será necessário a inclusão de um andamento!"
				Else
					oModel:SetValue("NTAMASTER","NTA__OBSER", oModel:GetValue("NTAMASTER","NTA_DESC" ) )
				Endif

				//Monta complemento - Será lançado na descrição do Andamento - Para que seja lançado como complemento no FLUIG

				cComplemnt := AllTrim(JurGetDados("NVE",1,xFilial("NVE")+NSZ->NSZ_CCLIEN+NSZ->NSZ_LCLIEN+NSZ->NSZ_NUMCAS,"NVE_TITULO")) //Complemento - Título do caso
				cValor := IIF(ValType(FwFldGet('NTA__VALOR'))=="N",cValToChar(FwFldGet('NTA__VALOR')),FwFldGet('NTA__VALOR'))

				//Valor
				if (!Empty(cValor) .And. Alltrim(cValor) != "0")
					cComplemnt += CRLF + "Novo valor: " + Transform(val(cValor), "@E 999,999.99" )
				Endif

				//Último andamento
				aUltAnd := JUltAnd(FwFldGet('NTA_CAJURI'),FwFldGet('NTA_FILIAL'))
				if len(aUltAnd)>0
					cComplemnt += CRLF + DtoC(StoD(aUltAnd[1][4])) + " - (" + AllTrim(aUltAnd[1][6]) + ") - " + AllTrim(aUltAnd[1][7])
				Endif

				If !( JA106GerNT4(oModel, cComplemnt) )
					JurMsgErro(STR0128)	//"Gravação do follow-up cancelada!"
					lRet := .F.
				EndIf

				If lRet .And. !JA106WFConf(FwFldGet('NTA_CODWF'))  //valida se o retorno foi OK e o WF foi concluida ou esta em Aprovacao
					DbSelectArea('NQN')
					DbSetOrder(1) //NQN_FILIAL+NQN_COD

					DbGoTop()

					Do  While !( Eof() ) .And. (NQN->NQN_TIPO != '4')
						DbSkip()
					EndDo

					If  !( Eof() )
						oModel:LoadValue("NTAMASTER", "NTA_CRESUL", NQN->NQN_COD) //Preenche o status para em aprovação.
					EndIf
				EndIf
			ElseIf (cNQNTipo2 == '3') //valida se o FW foi cancelado
				If JA106WS002(FwFldGet('NTA_CODWF'))
					JA106ConfNZK(oModel, .F.) //Excluir os registros da NZK
				Else
					JurMsgErro(STR0129)	//"Não foi possível cancelar o WF no FLUIG!"
					lRet := .F.
				EndIf
			EndIf
		EndIf

	EndIf

RestArea(aAreaNTA)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106WFConf
Gera WorkFlow no Fluig do processo do follow-up
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 17/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA106WFConf(cIdWF)

	Local aArea       := GetArea()
	Local nC          := 0
	Local cSolicitId  := ''
	Local cUsuario    := SuperGetMV('MV_ECMUSER',,'')
	Local cSenha      := SuperGetMV('MV_ECMPSW',,'')
	Local cEmpresa    := SuperGetMV('MV_ECMEMP',,'0')
	Local cMensagem   := ''
	Local aValores    := {}
	Local aCardData   := {}
	Local aSubs       := {}
	Local xRet        := ''
	Local oXml        := nil
	Local cErro       := ''
	Local cAviso      := ''
	Local cTag        := ''
	Local lRet        := .F.

	Begin Sequence

    //Solicitante como o usuario logado.
	cSolicitId        := JColId(cUsuario,cSenha,cEmpresa,UsrRetMail(__cUserID))

	If  Empty( cSolicitId )
		cMensagem := STR0120  //"Problema para obter id do solicitante!"
		Break
	EndIf

	aadd(aValores, {"username"          , cUsuario   })
	aadd(aValores, {"password"          , JurEncUTF8(cSenha)})
	aadd(aValores, {"companyId"         , cEmpresa   })
	aadd(aValores, {"processInstanceId" , cIdWF      })
	aadd(aValores, {"userId"            , cSolicitId })

  //Retirado o elemento da tag devido o obj nao suportar
	aadd( aSubs, {'"', "'"})
	aadd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
	aadd( aSubs, {"<item />", ""})

	If  !( JA106TWSDL("ECMWorkflowEngineService", "getAllActiveStates", aValores, aCardData, aSubs, @xRet, @cMensagem) )
		Break
	EndIf

  //Obtem somente a Tag do XML de retorno
	cTag := '</States>'
	nC   := At(StrTran(cTag,"/",""),xRet)
	xRet := SubStr(xRet, nC, Len(xRet))
	nC   := At(cTag,xRet) + Len(cTag) - 1
	xRet := Left(xRet, nC)

  //Gera o objeto do Result Tag
	oXml := XmlParser( xRet, "_", @cErro, @cAviso )

	If  Empty(oXml) .And. !Empty(cMensagem)
		cMensagem := JMsgErrFlg(oXML)
		Break
	EndIf

    //Verifica se esta concluido ou nao.
	if oXml != nil .And. !Empty(oXml) .And. Empty(cMensagem)
		lRet := (If(ValType(oXml:_States:_Item) != 'A', oXml:_States:_Item:TEXT, oXml:_States:_Item[1]:TEXT) == '9')
	Endif

    //valida se o processo ja foi concluído e o retorno é vazio
	if (oXml == nil .Or. Empty(oXml)) .And. Empty(cMensagem)
		lRet := .T.
	Endif

End Sequence

If  !( Empty(cMensagem) )
	ConOut('JA106WFConf: ' + STR0122 + cMensagem) //"Erro: "
EndIf

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106R
Verifica se há preferência para sugestão do resultado do follow-up e atualiza as
informações de código e descrição na tela
Uso no cadastro de Follow-ups.

@param 	cCampo  	Campo a ser verificado
@Return cResultPad	Código do resultado do folllow-up
@sample

@author Juliana Iwayama Velho
@since 21/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106R( cCampo, nOpc )
	Local aArea     := GetArea()
	Local cResultPad:= ''
	Local aVar      := {}

	cCampo := PadR( cCampo, 10 )

	If nOpc == 3

		If cCampo $ 'NTA_CRESUL/NTA_DRESUL'

			If !(IsInCallStack( 'JURA100COM' ))

				cResultPad := SuperGetMV('MV_JRESUFW',, '')

			ElseIf !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))

				cResultPad:= JURA106ATO( 'NRT_CRESUL' )

			EndIf

			If !Empty(cResultPad)

				cResultPad := Posicione('NQN', 1 , xFilial('NQN') + cResultPad, 'NQN_COD')

			EndIf

			If IsInCallStack( 'JA106GFWIU' )

				aVar := JURGETXVAR()
				If aVar <> NIL
					cResultPad:= aVar[7]
				EndIf
			EndIf

		EndIf

	EndIf

	RestArea( aArea )

Return cResultPad

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106F3SU5
Customiza a consulta padrão de advogado credenciado para verificar o
escritório credenciado do assunto jurídico
Uso no cadastro de Follow-ups.

@param 	cMaster  	NTAMASTER - Dados do Follow-ups
@Return cCampo	    NTA_CAJURI - Campo de código de Assunto Jurídico
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 22/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106F3SU5(cMaster, cCampo)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cQuery   := ''
	Local aPesq    := {"U5_CODCONT","U5_CONTAT"}
	Local nResult  := 0

	cQuery := JA106SU5(cMaster)
	cQuery := ChangeQuery(cQuery, .F.)

	RestArea( aArea )

	nResult := JurF3SXB("SU5", aPesq,, .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("SU5")
		SU5->(dbgoTo(nResult))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106SU5
Monta a query de advogado a partir de parâmetro para filtro de

Uso no cadastro de Follow-up.

@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 29/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106SU5(cMaster)
Local cQuery   	:= ""
Local oModel   	:= FWModelActive()
Local cCodCor	:= ""
Local cLojCor	:= ""
Local lFilCor := .T.

Default cMaster := "NTAMASTER"

If cMaster != "JURA132"
	lFilCor := .F.
EndIf

If oModel <> Nil .And. oModel:GetId() == "JURA106"
	If oModel:GetModel(cMaster):HasField( "NTA_CCORRE" )
		cCodCor	:= FwFldGet( "NTA_CCORRE" )
	EndIf

	If oModel:GetModel(cMaster):HasField( "NTA_LCORRE" )
		cLojCor	:= FwFldGet( "NTA_LCORRE" )
	EndIf
EndIf

cQuery += "SELECT DISTINCT U5_CODCONT, U5_CONTAT, SU5.R_E_C_N_O_ SU5RECNO "
cQuery += " FROM "+RetSqlName("SU5")+" SU5,"+RetSqlName("SA2")+" SA2,"+RetSqlName("AC8")+" AC8"
cQuery += " WHERE U5_FILIAL = '"+xFilial("SU5")+"'"
cQuery += " AND A2_FILIAL = '"+xFilial("SA2")+"'"
cQuery += " AND AC8_FILIAL = '"+xFilial("AC8")+"'"
cQuery += " AND AC8_CODCON = U5_CODCONT"
cQuery += " AND AC8_ENTIDA = 'SA2'"
cQuery += " AND A2_COD     = SUBSTRING( AC8_CODENT, 1," + AllTrim( Str( TamSX3('A2_COD')[1] ) ) + ")"
cQuery += " AND A2_LOJA    = SUBSTRING( AC8_CODENT, 7," + AllTrim( Str( TamSX3('A2_LOJA')[1] ) ) + ")"

If lFilCor
	If !Empty( cCodCor )
		cQuery += " AND A2_COD	   = '" + cCodCor + "'"
	EndIf
	If !Empty( cLojCor )
		cQuery += " AND A2_LOJA	   = '" + cLojCor + "'"
	EndIf
EndIf

cQuery += " AND SU5.D_E_L_E_T_ = ' '"
cQuery += " AND SA2.D_E_L_E_T_ = ' '"
cQuery += " AND AC8.D_E_L_E_T_ = ' '"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106VSU5
Verifica se o valor do campo de advogado credenciado é válido
Uso no cadastro de Follow-up.

@param 	cMaster  	NTAMASTER - Dados do Pedido Valor Juridico
@Return cCampo	    NTA_CAJURI - Campo de código de Assunto Jurídico
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 29/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106VSU5(cMaster, cCampo)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local oModel   := FWModelActive()
	Local cQuery   := JA106SU5(cMaster)
	Local cAlias   := GetNextAlias()

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	While !(cAlias)->( EOF() )
		If (cAlias)->U5_CODCONT == oModel:GetValue(cMaster,'NTA_CADVCR')
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0012)
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J106HABCAJ
Verifica se é a tela de follow-up não está sendo chamada a partir de Assunto Jurídico
nem Andamento e se a operação é de inclusão, para habilitar o campo de
Código de Assunto Jurídico para preenchimento pelo usuário

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 30/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106HABCAJ()
	Local lRet  := .F.

	If Empty(M->NSZ_COD) .And. INCLUI .And. !IsInCallStack( 'JURA100COM' ) .AND. !IsInCallStack( 'JA106GFWIU' )
		lRet := .T.
	Else
		lRet:= Empty(M->NSZ_COD) .AND. !IsInCallStack( 'JURA100COM' ) .AND. !IsInCallStack( 'JA106GFWIU' ) .AND. INCLUI
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGDT
Verifica se o ato processual possui configurações para a sugestão da data do follow-up
Se a data do andamento for no sábado ou domingo, verifica a quantidade de dias para alteração

@Return dFollowup	 	Data do Follow-up

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106SGDT()
	Local dFollowup := ctod('')
	Local aArea     := GetArea()
	Local aVar      := {}
	Local nQteDias  := 0
	Local cTpData   := ""
	Local dData     := ctod('')
	Local lDtProxEv := .F. //Define se a data é do campo proximo evento

	If  IsInCallStack( 'JURA100COM' ) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))

		cTpData   := JURA106ATO( 'NRT_DATAT' )
		nQteDias  := JURA106ATO( 'NRT_QTDED' )

		If !Empty(NT4->NT4_DTPREV)//Se a data de prox evento for preenchida ela será utilizada para incluir o proximo fup
			dData     := NT4->NT4_DTPREV
			lDtProxEv := .T.
		else
			dData := NT4->NT4_DTANDA
		EndIf

		dFollowup := JUR106DTFU(cTpData, dData, nQteDias,lDtProxEv)

	ElseIf IsInCallStack( 'JA106GFWIU' ) .And. !JModRst()

		aVar := JURGETXVAR()
		If aVar <> NIL
			dFollowup := aVar[2]
		EndIf

	EndIf

	RestArea(aArea)

Return dFollowup

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106DTFU
Regra para calculo da data de follow-up contando a qtde de dias e considerando feriados para
data retroativa ou futura.

@param cTpData - Tipo de Calculo.
		[1] - Retroativo
		[2] - Futuro dias corridos
		[3] - Futuro dias úteis
@param dFollow-up - Data do Follow-up
@param nQteDias   - Quantidades a se calculado
@param lDtProxEv  - Se a data vem do campo prox evento, se sim, não calcula as datas 

@Return dFollowup - Data calculada

@author Antonio Carlos Ferreira
@since 17/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106DTFU(cTpData, dFollowup, nQteDias, lDtProxEv)
Local nDow     := 0
Local nI       := 0
Local lBlqFer  := SuperGetMV('MV_JBLQFER',, '2') = '1'


Default cTpData    := "2"
Default dFollowup  := Date()
Default nQteDias   := 0
Default lDtProxEv  := .F.

	If lDtProxEv//Se vier do campo prox evento, nao calcula os dias, mas ainda assim, valida o fds
		nQteDias := 0
	EndIf
	If (cTpData == "1")  //Retroativa

		If lBlqFer
			nDow := DOW(dFollowup - nQteDias)

			If  (nDow == 1)    //Domingo
				dFollowup := dFollowup - nQteDias - 2
			ElseIf (nDow == 7) //Sabado
				dFollowup := dFollowup - nQteDias - 1
			Else
				dFollowup := dFollowup - nQteDias
			EndIf

			If (SuperGetMV('MV_JBLQFER', , '2') == '1')  //Considera e verifica feriado
				dFollowup := DataValida(dFollowup, .F./*Retroceder*/)  //Utiliza o parametro MV_SABFERI = "S" para considerar sabado e domingo como feriado.
			EndIf
		Else
			dFollowup := (dFollowup - nQteDias)
		EndIf

	ElseIf (cTpData == "2")  //Futura - dias corridos

		If lBlqFer

			nDow := DOW(dFollowup + nQteDias)

			If (nDow == 1)    //Domingo
				dFollowup := dFollowup + nQteDias + 1
			ElseIf (nDow == 7) //Sabado
				dFollowup := dFollowup + nQteDias + 2
			Else
				dFollowup := dFollowup + nQteDias
			EndIf

			If (SuperGetMV('MV_JBLQFER',, '2') == '1')  //Considera e verifica feriado
				dFollowup := DataValida(dFollowup, .T./*Avancar*/)  //Utiliza o parametro MV_SABFERI = "S" para considerar sabado e domingo como feriado.
			EndIf
		Else
			dFollowup := (dFollowup + nQteDias)
		EndIf

	ElseIf (cTpData == "3")  //Futura - dias úteis

		Do While nI <= nQteDias
			
			nDow := DOW(dFollowup + nI)
			
			//Valida finais de semana e feriados
			If (cValToChar(nDow) $ '17') .Or. ((dFollowup + nI)  != DataValida(dFollowup + nI))
				nQteDias++
			EndIf

			nI++
		EndDo

		dFollowup := (dFollowup + nQteDias)

	EndIf
	
Return dFollowup


//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGDE
Verifica se o ato processual possui configurações para a sugestão da descrição do follow-up
a partir da descrição do andamento ou da descrição do follow-up padrão

@Return cDescricao	 	Descrição do Follow-up

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106SGDE()
	Local cDescricao:= ""
	Local cSugere   := ""
	Local aArea     := GetArea()
	Local aVar      := {}

	If IsInCallStack( 'JURA100COM') .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))

		cSugere := JURA106ATO( 'NRT_SUGDES' )

		If cSugere == '1'
			cDescricao := NT4->NT4_DESC
		ElseIf cSugere = '2'
			cDescricao := JURA106ATO( 'NRT_DESC' )
		EndIf

	ElseIf IsInCallStack( 'JA106GFWIU' )

		aVar := JURGETXVAR()

		If aVar <> NIL
			cDescricao := aVar[11]
		EndIf

	EndIf

	RestArea(aArea)

Return cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGTF
Sugere o tipo de follow-up configurado no follow-up padrão do ato processual
do andamento

@Return cTipo	 	Tipo do Follow-up

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JUR106SGTF()
	Local cTipo := ""
	Local aArea := GetArea()
	Local aVar  := {}

	If(IsInCallStack( 'JURA100COM' )) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))
		cTipo := JURA106ATO( 'NRT_CTIPOF' )

	ElseIf IsInCallStack( 'JA106GFWIU' )

		aVar  := JURGETXVAR()
		If aVar <> NIL
			cTipo := aVar[1]
		EndIf

	EndIf

	RestArea(aArea)

Return cTipo

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGHO
Sugere o horário configurado no follow-up padrão do ato processual
do andamento

@Return cHora	 	Hora do Follow-up

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106SGHO()
Local cHora := ""
Local aArea := GetArea()
Local aVar  := {}

	If(IsInCallStack( 'JURA100COM' )) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))
		cHora := JURA106ATO( 'NRT_HORAF' )

	ElseIf IsInCallStack( 'JA106GFWIU' )

		aVar := JURGETXVAR()
		If aVar <> NIL
			cHora:= aVar[3]
		EndIf

	EndIf

	cHora := StrTran(cHora, ":", "")
	RestArea(aArea)

Return cHora

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGPR
Sugere o preposto configurado no follow-up padrão do ato processual
do andamento

@Return cPreposto	 	Código do Preposto do Follow-up

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106SGPR()
	Local cPreposto := ""
	Local aArea     := GetArea()
	Local aVar      := {}

	If(IsInCallStack( 'JURA100COM' )) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))
		cPreposto := JURA106ATO( 'NRT_CPREPO' )

	ElseIf IsInCallStack( 'JA106GFWIU' )

		aVar := JURGETXVAR()
		If aVar <> NIL
			cPreposto:= aVar[5]
		EndIf

	EndIf

	RestArea(aArea)

Return cPreposto

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGAT
Sugere o ato configurado no follow-up padrão do ato processual
do andamento

@Return cAto	 	Código do Ato

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106SGAT()
	Local cAto := ""
	Local aArea:= GetArea()
	Local aVar := {}

	If(IsInCallStack( 'JURA100COM' )) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))

		cAto := JURA106ATO( 'NRT_CSUATO' )

	ElseIf IsInCallStack( 'JA106GFWIU' )

		aVar := JURGETXVAR()
		If aVar <> NIL
			cAto := aVar[8]
		EndIf

	EndIf

	RestArea(aArea)

Return cAto

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGFS
Sugere a fase configurada no follow-up padrão do ato processual
do andamento

@Return cFase	 	Código da Fase

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106SGFS()
	Local cFase := ""
	Local aArea := GetArea()
	Local aVar  := {}

	If(IsInCallStack( 'JURA100COM' )) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))

		cFase := JURA106ATO( 'NRT_CFASE' )

	ElseIf IsInCallStack( 'JA106GFWIU' )

		aVar := JURGETXVAR()
		If aVar <> NIL
			cFase:= aVar[9]
		EndIf

	EndIf

	RestArea(aArea)

Return cFase

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGDU
Sugere a duração configurada no follow-up padrão do ato processual
do andamento

@Return cDuracao	 	Duração

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106SGDU()
	Local cDuracao := ""
	Local aArea    := GetArea()
	Local aVar     := {}

	If(IsInCallStack( 'JURA100COM' )) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))
		cDuracao := JURA106ATO( 'NRT_DURACA' )

	ElseIf IsInCallStack( 'JA106GFWIU' )

		aVar := JURGETXVAR()
		If aVar <> NIL
			cDuracao:= aVar[4]
		EndIf

	EndIf

	cDuracao := StrTran(cDuracao, ":", "")
	RestArea(aArea)

Return cDuracao

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106ATO
Verifica qual campo do cadastro de follow-up é necessário para realizar
as configurações de sugestão de follow-up a partir do andamento

@Return xCampo	 	Valor do campo solicitado
@param 	cCampo  	Campo a ser verificado

@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA106ATO(cCampo)
	Local xCampo   := nil
	Local aArea    := GetArea()
	Local aAreaNRO := NRO->( GetArea() )
	Local aAreaNRT := NRT->( GetArea() )

	NRO->( dbSetOrder( 1 ) )
	If NRO->( dbSeek( xFilial( 'NRO' ) + NT4->NT4_CATO ) )
		If !Empty(NRO->NRO_CFWPAD)
			NRT->( dbSetOrder( 1 ) )
			If NRT->( dbSeek( xFilial( 'NRT' ) + NRO->NRO_CFWPAD ) )
				xCampo:= &('NRT->'+cCampo)
			EndIf
		EndIf
	EndIf

	RestArea(aAreaNRO)
	RestArea(aAreaNRT)
	RestArea(aArea)

	xCampo := Iif(xCampo == nil, "", xCampo)
Return xCampo

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106HDU
Valida se o campo de tipo de follow-up está configurado para compromisso
com hora marcada ou duração
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 06/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA106HDU()
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local oModel   := FWModelActive()

	If Posicione('NQS', 1 , xFilial('NQS') + oModel:GetValue('NTAMASTER','NTA_CTIPO') , 'NQS_HORAM') == '1'

		If Empty(oModel:GetValue('NTAMASTER','NTA_HORA')) .Or. (oModel:GetValue('NTAMASTER','NTA_HORA') == '  :  ') .Or.;
				(oModel:GetValue('NTAMASTER','NTA_HORA') == ':    ')
			JurMsgErro(STR0014)
			lRet := .F.
		EndIf

		If lRet .And. (Empty(oModel:GetValue('NTAMASTER','NTA_DURACA')) .Or. oModel:GetValue('NTAMASTER','NTA_DURACA') == ':    ' .Or.;
				oModel:GetValue('NTAMASTER','NTA_DURACA') == '  :  ' .Or. oModel:GetValue('NTAMASTER','NTA_DURACA') == '00:00')
			JurMsgErro(STR0015)
			lRet := .F.
		EndIf

	EndIf

	RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106DUR
Verifica se o campo de tipo de follow-up possui configuração de duração
Uso no cadastro de Follow-ups.

@Return cDuracao	 	Duracao do follow-up
@param 	cTipo  			Tipo de follow-up

@author Juliana Iwayama Velho
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106DUR(cTipo)
	Local cDuracao := ""
	Local oModel   := FWModelActive()
	Local nOpc     := oModel:GetOperation()
	Local aArea    := GetArea()

	If nOpc == 3 .Or. nOpc == 4

		cDuracao := Posicione('NQS', 1 , xFilial('NQS') + cTipo , 'NQS_DURACA')
		cDuracao := StrTran(cDuracao,":","")

	EndIf

	RestArea( aArea )

Return cDuracao

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106SGRP
Sugere os responsáveis configurados no follow-up padrão do ato processual
do andamento
Uso no cadastro de Follow-ups.

@Return oModel	 	Model a ser verificado

@author Juliana Iwayama Velho
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR106SGRP(oModel)
	Local cFwPadrao  := ''
	Local aArea      := GetArea()
	Local cQuery     := ''
	Local cAlias     := GetNextAlias()
	Local oModelGrid := NIL
	Local nCt 		 := 0
	Local aVar       := {}
	Local lRet		 := .T.
	Local aPartiNZ5	 := {}
	Local nCont		 := 0
	Local nPosDel	 := 0
	Local cCajuri	 := oModel:GetValue("NTAMASTER", "NTA_CAJURI")

	If oModel:GetOperation() == 3

		If IsInCallStack( 'JURA100COM' ) .And. !(IsInCallStack( 'JA100GFWAT' )) .And. !(IsInCallStack( 'JA106GFWIU' ))

			cFwPadrao := JURA106ATO( 'NRT_COD' )

		ElseIf IsInCallStack( 'JA106GFWIU' )

			aVar := JURGETXVAR()
			If aVar <> NIL
				cFwPadrao:= aVar[12]
			EndIf

		EndIf

		If !Empty(cFwPadrao)

			cQuery := ChangeQuery( JURA106NRR(cFwPadrao) )

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .T., .F. )

			oModelGrid 	:= oModel:GetModel( "NTEDETAIL" )
			nCt			:= 0

			While !(cAlias)->( EOF() )

				nCt++

				If nCt > 1
					oModelGrid:AddLine()
				EndIf

				If !oModel:SetValue("NTEDETAIL", "NTE_CPART", (cAlias)->NRR_CPART)

					//Valida participante
					lRet := J106aVlPar(cCajuri, (cAlias)->NRR_CPART, @oModel)

					If !lRet
						Exit
					EndIf
				EndIf

				If lRet
					If !oModel:LoadValue("NTEDETAIL", "NTE_SIGLA", (cAlias)->NRR_SIGLA )
						JurMsgErro( STR0153  + "NTE_SIGLA" + STR0154 + AllToChar( (cAlias)->NRR_SIGLA ) ) // "Erro ao incluir follow-up: Campo = " " Conteúdo = "
						lRet := .F.
						Exit
					EndIf
				endif

				(cAlias)->( dbSkip() )
			End

			(cAlias)->( dbCloseArea() )

			If lRet

				//Carrega os participantes relacionados a tabela NZ5
				aPartiNZ5 := JURA106NZ5(cFwPadrao, cCajuri)

				//Remove participantes do array aPartiNZ5 que ja estao grid
				If Len(aPartiNZ5) > 0 .AND. !Empty( oModel:GetValue("NTEDETAIL", "NTE_CPART") )

					For nCont := 1 To oModelGrid:GetQtdLine()

						oModelGrid:GoLine( nCont )

						If !oModelGrid:IsDeleted()

							nPosDel := 1
							While nPosDel > 0

								nPosDel := Ascan(aPartiNZ5, { |x| x[1] == oModel:GetValue("NTEDETAIL" ,"NTE_CPART") } )
								If nPosDel > 0
									Adel( aPartiNZ5, nPosDel)
									Asize( aPartiNZ5, Len(aPartiNZ5) - 1)
								EndIf
							EndDo
						EndIf
					Next nCont
				EndIf

			//Carrega grid
				For nCont:=1 To Len(aPartiNZ5)

					If !Empty( oModel:GetValue("NTEDETAIL", "NTE_CPART") )
						oModelGrid:AddLine()
					EndIf

					If !oModel:SetValue("NTEDETAIL", "NTE_CPART", aPartiNZ5[nCont][1])

						//Valida participante
						lRet := J106aVlPar(cCajuri, aPartiNZ5[nCont][1], @oModel)

						If !lRet
							Exit
						EndIf
					EndIf

					If lRet
						If !oModel:LoadValue("NTEDETAIL", "NTE_SIGLA", aPartiNZ5[nCont][2] )
							JurMsgErro( STR0153  + "NTE_SIGLA" + STR0154 + AllToChar( aPartiNZ5[nCont][2] ) )	// "Erro ao incluir follow-up: Campo = " " Conteúdo = "
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nCont
			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106FDS
Verifica parametro para validação da data de follow-up quando é um final
de semana ou feriado
Uso no cadastro de Follow-ups.

@param dData: Data que será validada

@Return lRet .T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 06/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106FDS(dData)
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local aArea    := GetArea()
	Default dData  := oModel:GetValue('NTAMASTER','NTA_DTFLWP')

	//Verifica se o parâmetro bloqueia feriado
	If SuperGetMv('MV_JBLQFER',, '2') == '1'

		nDow:= DOW(dData)

		If nDow == 1 .Or. nDow == 7

			JurMsgErro(STR0016)
			lRet := .F.

		Else

			dFollowup := DataValida(dData)
			If dFollowup <> dData

				JurMsgErro(STR0017)
				lRet := .F.

			EndIf

		EndIf

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106DTR
Verifica parametro para validação da data de follow-up retroativa

@Return lRet	 	.T./.F. As informações são válidas ou não
Uso no cadastro de Follow-ups.

@author Juliana Iwayama Velho
@since 07/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA106DTR(nOpc,oModel)
	Local lRet     := .T.

	If SuperGetMV('MV_JTRFWDR',, '2') == '1' .AND. oModel:GetValue('NTAMASTER','NTA_DTFLWP') < DATE()

		If nOpc == 3
			JurMsgErro(STR0018) //"Bloqueia a inclusão de follow-up com data retroativa"
			lRet := .F.
		EndIF
		If nOpc == 4 .AND. oModel:IsFieldUpdated('NTAMASTER','NTA_DTFLWP')
			JurMsgErro(STR0018) //"Bloqueia a inclusão de follow-up com data retroativa"
			lRet := .F.
		EndIF
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106COM
Salvar as informações do follow-up e verificação a inclusão/alteração
automática e de intervenção de usuário

@param 	oModel  	Model a ser verificado

@author Juliana Iwayama Velho
@since 10/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA106COM(oModel)

	Local cAssJur     := oModel:GetValue("NTAMASTER","NTA_CAJURI")
	Local aArea       := GetArea()
	Local dDtFlwpOld  := FwFldGet( 'NTA_DTORIG' )
	Local aAreaNQS    := NQS->( GetArea() )
	Local nOpc        := oModel:GetOperation()
	Local oModelNTA   := oModel:GetModel( 'NTAMASTER' )
	Local oModelNZK
	Local oModelNZM
	Local lRet        := .T.
	Local lMaior      := .T.
	Local nQtdeDias   := 0
	Local lVincAnd    := SuperGetMV('MV_JVINCAF',, '2') == '1'
	Local lSeekNQS    := .F.
	Local cCResul     := NTA->NTA_CRESUL //Salva o valor do campo antes da alteracao
	Local cNQNTipo1   := ''              //NQN_TIPO do valor antes da alteração
	Local cNQNTipo2   := ''              //NQN_TIPO do valor alterado
	Local lAltDTFLWP  := oModelNTA:IsFieldUpdated('NTA_DTFLWP')
	Local lAltHORA    := oModelNTA:IsFieldUpdated('NTA_HORA')
	Local lAltCCORRE  := oModelNTA:IsFieldUpdated('NTA_CCORRE')
	Local lAltLCORRE  := oModelNTA:IsFieldUpdated('NTA_LCORRE')
	Local lAltCADVCR  := oModelNTA:IsFieldUpdated('NTA_CADVCR')
	Local lAltCRESUL  := oModelNTA:IsFieldUpdated('NTA_CRESUL')
	Local cIdFluigWF  := ''
	Local cDescFupWF  := ''
	Local lConcWF     := .F. //Variável que vai controlar se o workflow está em aprovação no FLUIG ou não.
	Local lDifWF      := .F. //variável que vai controlar se o status do follow-up está diferente do WF
	Local lNZKInDic   := FWAliasInDic("NZK") //Verifica se existe a tabela NZK no Dicionário (Proteção)
	Local lNZLInDic   := FWAliasInDic("NZL") //Verifica se existe a tabela NZL no Dicionário (Proteção)
	Local lNZMInDic   := FWAliasInDic("NZM") //Verifica se existe a tabela NZM no Dicionário (Proteção)
	Local lFluig      := SuperGetMV('MV_JFLUIGA',,'2') == '1' .And. JurGetDados("NQS", 1, xFilial("NQS") + oModel:GetValue("NTAMASTER","NTA_CTIPO"), "NQS_FLUIG") != '2'
	Local dData       := cToD('')
	Local lDtProxEv   := .F.

	If lNZKInDic
		oModelNZK := oModel:GetModel( 'NZKDETAIL' )
	EndIf
	If lNZMInDic
		oModelNZM := oModel:GetModel( 'NZMDETAIL' )
	EndIf

	//Se utiliza integração com o Fluig ('1') ou não utiliza ('2').
	If  lFluig .And. lNZKInDic .And. lNZLInDic .And. lNZMInDic

		If  (nOpc == 3) .And. Empty(FwFldGet( 'NTA_CODWF' ))
			cNQNTipo2 := Posicione('NQN',1,xFilial('NQN')+FwFldGet('NTA_CRESUL'),'NQN_TIPO')

			If  (cNQNTipo2 $ '14') //Pendente ou Em Aprovação
				cIdWF   := SuperGetMV('MV_JWFAPRV',,'')
				If  Empty(cIdWF)
					JurMsgErro(STR0130) //"Parâmetro MV_JWFAPRV não definido com o id do workflow do Fluig!"
					lRet := .F.
				Else

					If  JA106WS001(cAssJur, cNQNTipo2, cIdWF, @cIdFluigWF, oModel, @cDescFupWF)
						oModelNTA:SetValue('NTA_CODWF', cIdFluigWF)   //Grava o id do workflow

						If Empty(oModelNTA:GetValue('NTA_DESC')) .AND. !Empty(cDescFupWF)
							cDescFupWF := StrTran(cDescFupWF, "&#10;", CRLF)
							oModelNTA:SetValue('NTA_DESC', cDescFupWF)
						EndIf

						lConcWF := JA106WFConf(cIdFluigWF)

						//valida se o workflow está com o status diferente do followup
						if (!lConcWF .And. cNQNTipo2 == "2" )
							cNQNTipo2 := "4" //se não finalizou e o tipo está como concluído, manda para aprovação
							lDifWF := .T.
						Endif

						if (lConcWF .And. cNQNTipo2 == "4" )
							cNQNTipo2 := "2" //se finalizou e o tipo está como em aprovação, manda para concluído.
							lDifWF := .T.
						Endif

						If (lDifWF)
							//Busca o tipo de resultado que seja Em Aprovação
							DbSelectArea('NQN')
							NQN->( DbSetOrder(1) ) //NQN_FILIAL+NQN_COD

							NQN->( dbGoTop())

							Do  While !( Eof() ) .And. (NQN->NQN_TIPO != cNQNTipo2)
								DbSkip()
							EndDo

							//muda o resultado do followup.
							oModelNTA:SetValue("NTA_CRESUL",NQN->NQN_COD)
						Endif

					Else //Erro ao criar o workflow no FLUIG.
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		If (nOpc == 4) .And. lAltCRESUL .And. !( Empty(FwFldGet( 'NTA_CODWF' )) )

			cNQNTipo1 := Posicione('NQN',1,xFilial('NQN')+cCResul,'NQN_TIPO')

			cNQNTipo2 := Posicione('NQN',1,xFilial('NQN')+FwFldGet( 'NTA_CRESUL' ),'NQN_TIPO')

			If (cNQNTipo1 $ '14') .And. (cNQNTipo2 == '2') //DE Pendente/Em Aprovação PARA Concluido ou Em Aprovacao

				If cNQNTipo1 $ "14" .And. IsInCallStack( 'MTJurSyncFollowUp' ) /*Webservice Fluig*/ .And. ;
						!( Empty(Posicione('NQS',1,xFilial('NQS')+FwFldGet( 'NTA_CTIPO' ),'NQS_CSUGES')) ) //Sugestao de andamento
					JA106GerNT4(oModel)
				EndIf

				If cNQNTipo1 == "4" //só executa a NZK se o fw for concluído.
					JA106ConfNZK(oModel, .T.) //Confirmar o valor e excluir os registros da NZK
				EndIf

			ElseIf (cNQNTipo1 == '4') .And. (cNQNTipo2 == '1') //DE Em Aprovação PARA Pendente
				JA106ConfNZK(oModel, .F.) //Excluir os registros da NZK
				If IsInCallStack( 'MTJurSyncFollowUp' )
					oModelNTA:SetValue('NTA_DESC', "Retorno Fluig: ("+ oModelNTA:GetValue("NTA__OBSER" )+")"+ CRLF + CRLF +;
														oModelNTA:GetValue("NTA_DESC" ))
				EndIf

			ElseIf (cNQNTipo1 $ '14') .And. (cNQNTipo2 == '3') //DE Em Aprovação/Pendente PARA Cancelado

				//Executar NZM caso tenha algum caminho ou texto informado.
				JA106GerNT4(oModel)

				//Cancelar o WF no Fluig
				If IsInCallStack('MTJurSyncFollowUp') .Or. JA106WS002(FwFldGet('NTA_CODWF'))
					JA106ConfNZK(oModel, .F.) //Excluir os registros da NZK
					oModelNTA:SetValue('NTA_DESC', "Retorno Fluig: ("+ oModelNTA:GetValue("NTA__OBSER" )+")"+ CRLF + CRLF +;
														oModelNTA:GetValue("NTA_DESC" ))
				EndIf
			EndIf

		EndIf

		If (nOpc == 5) .And. !( Empty(FwFldGet( 'NTA_CODWF' )) )
			//Cancelar o WF no Fluig
			If !IsInCallStack('MTJurSyncFollowUp')
				If !JA106WS002(FwFldGet('NTA_CODWF'))
					JurMsgErro(STR0129)	//"Não foi possível cancelar o WF no FLUIG!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet

		FWFormCommit(oModel)

		NTA->( dbSeek( xFilial( 'NTA' )  + FwFldGet( 'NTA_COD' ) ) )

		If nOpc == 3 .Or. nOpc == 4

			//--------------------------------------------------------------
			// Verifica	recursividade na configuração
			//--------------------------------------------------------------
			If Empty( FwFldGet( 'NTA_CFLWPP' ) ) .AND. lRet
				lRet := JA106TIPOP( FwFldGet( 'NTA_CTIPO' ) )
			EndIf

			//--------------------------------------------------------------
			// Posiciona Tipos de Follow Up
			//--------------------------------------------------------------
			NQS->( dbSetOrder( 1 ) )
			lSeekNQS := NQS->( dbSeek( xFilial( 'NQS' ) + FwFldGet( 'NTA_CTIPO' ) ) )

			If lRet
				//--------------------------------------------------------------
				// Verifica	a inclusão / alteração de follow-ups de configuração
				// automática ou intervenção de usuário
				//--------------------------------------------------------------
				If lSeekNQS
					//-------------------------------------------------------------------------------------
					//Verifica configuração para sugestão de andamento e o codigo do resultado de conclusão
					//-------------------------------------------------------------------------------------
					If NQS->NQS_SUGERE == '1' .And.;
						( nOpc == 3 .AND. (Empty(NQS->NQS_CRESUL) .OR. NQS->NQS_CRESUL == FwFldGet( 'NTA_CRESUL' ));//Se for inclusão, verifica se o resul do tipoFu esta vazio ou se estão iguais
						.OR. nOpc == 4 .AND. lAltCRESUL .And. NQS->NQS_CRESUL == FwFldGet( 'NTA_CRESUL' ))//Se for alteração, verifica se houve alteração no resul e se são igual

						If NQS->( FieldPos("NQS_TIPOGA") ) > 0	//ColumnPos não funciona quando o Dic é no Banco !
							If NQS->NQS_TIPOGA == '1'
								JA106IncAn( nOpc,oModel )
							Else
								If (!JurAuto() .And. ApMsgYesNo(STR0034)) .Or. JModRst()
									JA106IncAn( nOpc,oModel )
								EndIf
							EndIf
						Else
							If !JurAuto() .And. ApMsgYesNo(STR0034)
								JA106IncAn( nOpc,oModel )
							EndIf
						EndIf
					//-------------------------------------------------------------------------------------
					//Verifica codigo do resultado de rejeicao quanto tem correspondente
					//-------------------------------------------------------------------------------------
					ElseIf nOpc == 4 .AND. !Empty( FwFldGet( 'NTA_CCORRE' ) ) .And. lAltCRESUL .And. NQS->NQS_CRESRE == FwFldGet( 'NTA_CRESUL' )

						//Incluida a linha abaixo porque, essa variavel é utilizada da função JURCPO
						INCLUI := .F.

						MsgInfo(STR0090)	//"Será necessário a inclusão de um novo follow-up, para o mesmo correspondente ou outro, para não se perder o histórico das operações."

						MsgRun(STR0046 + STR0009, STR0047, {|| FWExecView(STR0091, "JURA106", 9, , {|| .T.}, , 1, , , , , )})	//"Carregando..."	"Dados do Follow-up"	"Aguarde..."	"Copia de Follow-up Rejeitado"
					EndIf

					/*o usuário respondendo sim ou não, zeramos o valor da variável para
					que futuros andamentos não venham com o valor do código do follow up
					preenchido*/
					If nOpc == 3
						If !Empty(M->NTA_COD)
							JA106SetCf(M->NTA_COD)
						ElseIf !Empty(M->NTA_CFLPP)
							JA106SetCf(M->NTA_CFLPP)
						EndIf

						If !Empty(NTA->NTA_DTPREV)
							dData     := NTA->NTA_DTPREV
							lDtProxEv := .T.
						Else
							dData := NTA->NTA_DTFLWP
						EndIf

						JA106GFLWP(NTA->NTA_CAJURI, NTA->NTA_COD, dData, NTA->NTA_CTIPO, NTA->NTA_CFLWPP, lDtProxEv)
					EndIF
					If nOpc == 4
						If lAltDTFLWP
							If FwFldGet( 'NTA_DTFLWP' ) > dDtFlwpOld
								nQtdeDias := FwFldGet( 'NTA_DTFLWP' ) - dDtFlwpOld
							Else
								nQtdeDias := dDtFlwpOld - FwFldGet( 'NTA_DTFLWP' )
								lMaior    := .F.
							EndIf

							JA106ALTFP(FwFldGet( 'NTA_COD' ), nQtdeDias, lMaior , .F.)
						EndIf
					EndIf
				EndIf
				//Vínculo de andamento e follow-up
				If lRet .And. lVincAnd
					JA100SetCa('')
				EndIf

				//Envia WorkfFlow para Correspondente
				If lRet .And. !Empty( NTA->NTA_CCORRE ) .And.;
						(lAltDTFLWP .Or. lAltHORA .Or. lAltCCORRE .Or. lAltLCORRE .Or. lAltCADVCR)

					JA106WFECO(oModel, .F.)
				EndIf
			EndIf
		EndIf
	EndIF
	//Retorna ao default o valor de codigode follow-up
	JA106SetCf("")

	RestArea( aAreaNQS )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106WS001
Gera WorkFlow no Fluig do processo do follow-up
Uso no cadastro de Follow-ups.

@Param cAssJur    - Código do Assunto Jurídico
@Param cNQNTipo2  - Status atual da Atividade
@Param cIdWF      - Código do Workflow
@Param cIdFluigWF - Código da Solicitação criada no Fluig
@Param oModel     - Modelo da JURA106 criada
@Param cDescFup   - Descrição do Complemento usado na Solicitação.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 29/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA106WS001(cAssJur, cNQNTipo2, cIdWF, cIdFluigWF, oModel, cDescFup)

	Local aArea        := GetArea()
	Local nA           := 0
	Local nC           := 0
	Local lRet         := .T.
	Local nPrazoAprov  := 0
	Local cSolicitId   := ''
	Local cExecutor    := ''
	Local cUsuario     := SuperGetMV('MV_ECMUSER',,'')
	Local cSenha       := SuperGetMV('MV_ECMPSW',,'')
	Local cEmpresa     := SuperGetMV('MV_ECMEMP',,'0')
	Local cMensagem    := ''
	Local aValores     := {}
	Local aCardData    := {}
	Local aSubs        := {}
	Local xRet         := ''
	Local oXml         := nil
	Local cErro        := ''
	Local cAviso       := ''
	Local cComplemento := AllTrim(JurGetDados("NVE",1,xFilial("NVE")+NSZ->NSZ_CCLIEN+NSZ->NSZ_LCLIEN+NSZ->NSZ_NUMCAS,"NVE_TITULO"))
	Local cTag         := ''
	Local cPastaCaso   := ''
	Local aUltAnd      := {}
	Local cStatusFW    := "1" //Valida se o follow-up ja foi executado ou está pendente.1 = Execução; 2 = Aprovação (FLUIG)
	Local cValor       := IIF(ValType(FwFldGet('NTA__VALOR'))=="N",cValToChar(FwFldGet('NTA__VALOR')),FwFldGet('NTA__VALOR'))
	Local cTipAssJur   := IIF(Empty(M->NSZ_TIPOAS),JurGetDados("NSZ",1,xFilial("NSZ")+cAssJur, "NSZ_TIPOAS"),M->NSZ_TIPOAS)
	Local cCliente     := IIF((cAssJur!=NSZ->NSZ_COD),M->NSZ_CCLIEN + M->NSZ_LCLIEN,NSZ->NSZ_CCLIEN + NSZ->NSZ_LCLIEN)
	Local cCaso        := FwFldGet("NTA__NUMCAS") //IIF((cAssJur!=NSZ->NSZ_COD),M->NSZ_NUMCAS,NSZ->NSZ_NUMCAS)
	Local nValorOld    := IIF((cAssJur!=NSZ->NSZ_COD),0,NSZ->NSZ_VLPROV)
	Local oModelNTE    := oModel:GetModel("NTEDETAIL")
	Local aRetNQS      := JurGetDados("NQS", 1, xFilial("NQS")+FwFldGet('NTA_CTIPO'), {"NQS_DPRAZO", "NQS_TAPROV"})

	Default cDescFup   := ""

	//Posiciona no primeiro participante valido, para enviar à ele a execução
	For nA:=1 To oModelNTE:GetQtdLine()
		oModelNTE:GoLine(nA)
		If !oModelNTE:IsDeleted()
			Exit
		EndIf
	Next nA

	//Pasta do caso criada no FLUIG.
	If M->NSZ_CCLIEN == NSZ->NSZ_CCLIEN .AND. M->NSZ_LCLIEN == NSZ->NSZ_LCLIEN .AND. M->NSZ_NUMCAS == NSZ->NSZ_NUMCAS
		cPastaCaso:= JurGetDados("NZ7",1,xFilial("NZ7")+AtoC(JurGetDados("NSZ",1,xFilial("NSZ")+cAssJur, {"NSZ_CCLIEN","NSZ_LCLIEN","NSZ_NUMCAS"}),''),"NZ7_LINK")
	Else
		cPastaCaso:= JurGetDados("NZ7",1,xFilial("NZ7") + cCliente + cCaso, "NZ7_LINK") //Pasta do caso criada no FLUIG.
	EndIf

	Begin Sequence

	//Solicitante como o usuario logado.
	cSolicitId := JColId(cUsuario,cSenha,cEmpresa,UsrRetMail(__cUserID))

	If Empty( cSolicitId )
		cMensagem := STR0120  //"Problema para obter id do solicitante. Verifique se o seu usuário possui cadastro do FLUIG."
		Break
	EndIf

	//Valida o usuario do fluig do executor
	cExecutor := JurGetDados("RD0", 1, xFilial("RD0")+FwFldGet('NTE_CPART'), "RD0_USER")

	If Empty(cExecutor) .Or. Empty( JColId(cUsuario,cSenha,cEmpresa,UsrRetMail(cExecutor)) )
		cMensagem := STR0161	//"Problema para obter id do executor. Verifique se o 1º participante possui cadastro no FLUIG."
		Break
	EndIf

	//Prazo de aprovacao
	nPrazoAprov := aRetNQS[1]

	If ValType(nPrazoAprov) == "C"
		nPrazoAprov := val(nPrazoAprov)
	EndIf

	//Pasta do caso criada no FLUIG.
	if (!Empty(AllTrim(cPastaCaso)))
		cPastaCaso := StrTokArr(cPastaCaso,";")[1]
	Else
		cPastaCaso := "0"
	Endif

	//Monta complemento

	//Verifica se tem valor e se a aprovação é de Valor de Provisão ou Encerramento
	If !Empty(cValor) .And. Alltrim(cValor) != "0" .And. aRetNQS[2] $ "1|5"
		cComplemento += "&#10;" + STR0156 + Transform(nValorOld, "@E 99,999,999,999.99" ) // "Valor de provisão atual: "
		cComplemento += "&#10;" + STR0157 + Transform(val(cValor), "@E 99,999,999,999.99" ) // "Valor para aprovação: "
		cComplemento += "&#10;" + STR0158 + Transform(nValorOld + val(cValor), "@E 99,999,999,999.99" ) //"Valor da provisão após aprovação: "
	Endif

	//Último andamento
	aUltAnd := JUltAnd(FwFldGet('NTA_CAJURI'),xFilial("NT4"))
	if len(aUltAnd)>0
		cComplemento += "&#10;" + DtoC(StoD(aUltAnd[1][4])) + " - (" + AllTrim(aUltAnd[1][6]) + ") - " + AllTrim(aUltAnd[1][7])
	Endif

	If (JurGetDados('NQN',1,xFilial('NQN')+FwFldGet( 'NTA_CRESUL' ),'NQN_TIPO') == "4")
		cStatusFW := "2"
	Endif

	//caso o valor seja negativo, ou seja, diminuído, multiplicar por -1 para ficar positivo. Por ser a diferença que vale.
	if (val(cValor) < 0)
		cValor := cValToChar((val(cValor) * -1))
	Endif

	If !Empty(JurEncUTF8(FwFldGet('NTA_DESC')))
		cDescFup := JurEncUTF8(FwFldGet('NTA_DESC'))
	EndIf

	aAdd(aCardData, {"cdAssJur"         , cTipAssJur                                               , 0, 0 })  //código do tipo do assunto juridico
	aAdd(aCardData, {"cdTipoFU"         , FwFldGet('NTA_CTIPO')                                    , 0, 0 })  //código do tipo de follow-up
	aAdd(aCardData, {"cdFollowUp"       , FwFldGet('NTA_COD')                                      , 0, 0 })  //código do follow-up
	aAdd(aCardData, {"cdStatusAtividade", cNQNTipo2                                                , 0, 0 })  //código do status da atividade: 1 – Pendente, 2 – Concluída, 3 – Cancelada e 4 – Em Aprovação.
	aAdd(aCardData, {"cdSolicitante"    , UsrRetMail(__cUserID)                                    , 0, 0 })  //Login do fluig do Solicitante
	aAdd(aCardData, {"cdUserExec"       , UsrRetMail(cExecutor)                                    , 0, 0 })  //Login do Fluig do Executor
	aAdd(aCardData, {"sCodigoJuridico"  , cCliente + '/' + cCaso                                   , 0, 0 })  //Codigo Juridico do Follow-Up
	aAdd(aCardData, {"dtPrazoTarefa"    , DtoC(FwFldGet('NTA_DTFLWP'))                             , 0, 0 })  //Prazo da tarefa no format dd/MM/aaaa
	aAdd(aCardData, {"sHora"            , FwFldGet('NTA_HORA')                                     , 0, 0 })  //Hora do Follow-up
	aadd(aCardData, {'dtPrazoAprova'    , DToC(J106DtVal(FwFldGet('NTA_DTFLWP')+nPrazoAprov))      , 0, 0 })  //Prazo da Aprovação no format dd/MM/aaaa
	aAdd(aCardData, {"sTipoFU"          , JurEncUTF8(Alltrim(FwFldGet('NTA_DTIPO')))               , 0, 0 })  //Descrição do tipo de Follow-Up, correspondente ao cdTipoFU
	aAdd(aCardData, {"sValor"           , cValor                                                   , 0, 0 })  //Valor do Follow-Up
	aAdd(aCardData, {"sDescAtividade"   , AllTrim(SubStr(cDescFup, 1,4000))						   , 0, 0 })  //Descrição da atividade
	aAdd(aCardData, {"sComplemento"     , JurEncUTF8(AllTrim(SubStr(cComplemento, 1,4000)))        , 0, 0 })  //Campo de Complemento
	aAdd(aCardData, {"cdExecAprova"     , cStatusFW                                                , 0, 0 })  //Identifica se o follow-up deve ser enviado para Execução ou para a checagem de Aprovação. 1 = Execução; 2 = Aprovação
	aAdd(aCardData, {"sPastaCaso"       , cPastaCaso                                               , 0, 0 })  //Identifica a pasta onde estão os documentos do caso referente ao processo.
	aAdd(aCardData, {"sFilial"	        , xFilial("NSZ")	                                       , 0, 0 })  //filial do assunto juridico
	aAdd(aCardData, {"sCajuri"   	    , cAssJur           	                                   , 0, 0 })  //codigo do assunto jurídico

	aadd(aValores, {"username"         , cUsuario      })
	aadd(aValores, {"password"         , JurEncUTF8(cSenha)})
	aadd(aValores, {"companyId"        , cEmpresa      })
	aadd(aValores, {"processId"        , cIdWF         })
	aadd(aValores, {"choosedState"     , "2"           })
	aadd(aValores, {"userId"           , cSolicitId    })
	aadd(aValores, {"completeTask"     , "true"        })
	aadd(aValores, {"managerMode"      , "false"       })
	aadd(aValores, {"comments"         , STR0147       }) //"WF iniciado pelo SIGAJURI"


	//Retirado o elemento da tag devido o obj nao suportar
	aadd(aSubs,{'"', "'"})
	aadd(aSubs,{" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
	aadd(aSubs,{"<item />", ""})


	If  !( JA106TWSDL("ECMWorkflowEngineService", "startProcessClassic", aValores, aCardData, aSubs, @xRet, @cMensagem) )
		Break
	EndIf

  	//Obtem somente a Tag do XML de retorno
	cTag := '</result>'
	nC   := At(StrTran(cTag,"/",""),xRet)
	xRet := SubStr(xRet, nC, Len(xRet))
	nC   := At(cTag,xRet) + Len(cTag) - 1
	xRet := Left(xRet, nC)

  	//Gera o objeto do Result Tag
	oXml := XmlParser( xRet, "_", @cErro, @cAviso )

	If Empty(oXml)
		cMensagem := JMsgErrFlg(oXML)
		Break
	EndIf

	//Analisa o tipo de retorno do Fluig
	If ValType(oXml) == "O" .And. XmlChildEx(oXml:_RESULT, "_ITEM") <> Nil

		If ValType(oXml:_RESULT:_ITEM) == "O"

			If AllTrim( Upper(oXml:_RESULT:_ITEM:_KEY:TEXT) ) == "ERROR"
				cMensagem  := AllTrim( oXml:_RESULT:_ITEM:_VALUE:TEXT )
				Break
			EndIf
		Else

		  	//Obtem o codigo do WorkFlow gerado no Fluig
			For nA := 1 to Len(oXml:_Result:_Item)
				If  (Upper(oXml:_Result:_Item[nA]:_Key:TEXT) != 'IPROCESS')
					Loop
				EndIf

				cIdFluigWF := oXml:_Result:_Item[nA]:_Value:TEXT
				Exit
			Next nA

		EndIf
	EndIf

	If  Empty(cIdFluigWF)
		cMensagem := STR0131 //"Codigo do workflow do Fluig nao retornado!"
		Break
	Else
		cDescFup :=  cComplemento
	EndIf

End Sequence

If !( Empty(cMensagem) )
	JurMsgErro(STR0122 + ' ' + cMensagem)
	lRet := .F.
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106TWSDL
Prepara e executa a classe TWSDLManager
Uso generico.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 25/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106TWSDL(cWebService, cWSMetodo, aValores, aCardData, aSubs, xRet, cMensagem)
Local nA         := 0
Local nB         := 0
Local nC         := 0
Local nPos       := 0
Local oWsdl      := nil
Local cUrl       := StrTran(AllTrim(JFlgUrl())+"/" + cWebService,'//','/',2) //URL do Web Service
Local aComplex   := {}
Local aSimple    := {}
Local nOccurs    := 0
Local cMsg       := ""

Default cWSMetodo  := ''
Default aValores   := {}
Default aCardData  := {}
Default aSubs      := {}
Default xRet       := ''
Default cMensagem  := ''

Begin Sequence

//Cria e conecta no Wsdl
oWsdl := JurConWsdl(cUrl + "?wsdl", @cMensagem)

If !Empty(cMensagem)
	Break
Endif

 //Define a operação
If  !( oWsdl:SetOperation( cWSMetodo ) )
	cMensagem := If(!Empty(oWsdl:cError), oWsdl:cError, STR0133) //"Problema para configurar o método webservice!"
	Break
EndIf

  //Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
oWsdl:cLocation := cUrl

  //Lista os tipos complexos (estruturas no xml) da mensagem de input envolvida na operação
aComplex := oWsdl:NextComplex()

Do  While (ValType(aComplex) == "A")
	If  (aComplex[2] == "item") .And. (aComplex[5] == "cardData#1")
		nOccurs := Len(aCardData)
	Else
		nOccurs := 0
	EndIf

	If  !( oWsdl:SetComplexOccurs(aComplex[1], nOccurs) )
		cMensagem := STR0134 + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + STR0135 + cValToChar( nOccurs ) + STR0136 //"Erro ao definir elemento "##", com "##" ocorrencias"
		Break
	EndIf

	aComplex := oWsdl:NextComplex()
EndDo

aSimple := oWsdl:SimpleInput()
//varinfo( "", aSimple )

For nA := 1 to Len(aValores)
	nPos := aScan( aSimple, {|x| x[2] == aValores[nA][1] } )

	If  !( oWsdl:SetValue( aSimple[nPos][1], aValores[nA][2] ) )
		cMensagem := If(!Empty(oWsdl:cError), oWsdl:cError, STR0137 + aValores[nA][1]) //"Problema para configurar o valor da tag: "
		Break
	EndIf
Next nA

If  (Len(aCardData) > 0)
	//Atribui os dados do formulario
	For nA := 4 to Len(aSimple)
		If  !("cardData#1.item#" $ aSimple[nA][5])
			Loop
		EndIf

		nB := Val(StrTran(aSimple[nA][5], "cardData#1.item#", ""))

		If  (nB > 0)
			nC := If(aSimple[nA][2]=="key", 1, 2)

			If  !( oWsdl:SetValue( aSimple[nA][1], aCardData[nB][nC] ) )
				cMensagem := If(!Empty(oWsdl:cError), oWsdl:cError, STR0138 + cValToChar(aCardData[nB][nC])) //"Problema para configurar o valor do item da tag cardData: "
				Break
			EndIf
		EndIf
	Next nA
EndIf

cMsg := oWsdl:GetSoapMsg()

//Retirado o elemento da tag devido o obj nao suportar
For nA := 1 to Len(aSubs)
	cMsg := StrTran(cMsg, aSubs[nA][1], aSubs[nA][2])
Next nA

// Log do XML de envio
JConLogXML(cMsg,"E")
//Envia a mensagem SOAP ao servidor
xRet := oWsdl:SendSoapMsg(cMsg)

// Pega a mensagem de resposta
xRet := oWsdl:GetSoapResponse()
JConLogXML(xRet,"R")

End Sequence

Return Empty(cMensagem)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106WS002
Cancela o WorkFlow no Fluig do processo do follow-up
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 29/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA106WS002(cIdFluigWF)

	Local aArea       := GetArea()
	Local cSolicitId  := ''
	Local cMensagem   := ''
	Local cUsuario    := SuperGetMV('MV_ECMUSER',,'')
	Local cSenha      := SuperGetMV('MV_ECMPSW',,'')
	Local cEmpresa    := SuperGetMV('MV_ECMEMP',,'0')
	Local xRet        := ''
	Local aValores    := {}
	Local aCardData   := {}
	Local aSubs       := {}
	Local cUsrSol     := ""

	//cUsrSol := JurGetDados("RD0", 1, xFilial("RD0")+FwFldGet('NTE_CPART'), "RD0_USER")
	cUsrSol := JA106GCard(cIdFluigWF,"cdSolicitante")

	Begin Sequence

  //Solicitante
	cSolicitId := JColId(cUsuario,cSenha,cEmpresa,cUsrSol)

	If  Empty( cSolicitId )
		cMensagem := STR0120  //"Problema para obter id do solicitante!"
		Conout("JA106WS002:" + STR0120)
		Break
	EndIf

	aadd(aValores, {"username"         , cUsuario   })
	aadd(aValores, {"password"         , JurEncUTF8(cSenha)})
	aadd(aValores, {"companyId"        , cEmpresa   })
	aadd(aValores, {"processInstanceId", cIdFluigWF })
	aadd(aValores, {"userId"           , cSolicitId })
	aadd(aValores, {"cancelText"       , STR0139    })   //"Cancelado via SIGAJURI!"

  //Retirado o elemento da tag devido o obj nao suportar
	aadd( aSubs, {'"', "'"})
	aadd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
	aadd( aSubs, {"<item />", ""})

	If  !( JA106TWSDL("ECMWorkflowEngineService", "cancelInstance", aValores, aCardData, aSubs, @xRet, @cMensagem) )
		Break
	EndIf

	If  !('<result>OK</result>' $ xRet)
		cMensagem := STR0140 + CRLF + cMensagem  //"Problema no cancelamento do workflow no Fluig!"
		Conout("JA106WS002:" + STR0140 + CRLF + cMensagem + CRLF + xRet)
		Break
	EndIf

End Sequence

RestArea( aArea )

Return Empty(cMensagem)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106GerNT4
Gera andamento para o follow-up atualizado pelo Fluig.
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 16/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA106GerNT4(oModel, cComplemento)

	Local aArea      := GetArea()
	Local nA         := 0
	Local lRet       := .T.
	Local oMMaster   := nil
	Local oModelNZL  := nil
	Local oModelNT4  := nil
	Local lCancelado := .F.
	Local cAto       := JurGetDados('NQS',1,xFilial('NQS')+oModel:GetValue("NTAMASTER","NTA_CTIPO" ),'NQS_CSUGES')
	Local oModelNZM  := oModel:GetModel( 'NZMDETAIL' )
	Local nQtdNZM    := oModelNZM:GetQtdLine()
	Local cTipoNQN   := JurGetDados('NQN',1,xFilial('NQN')+oModel:GetValue("NTAMASTER","NTA_CRESUL"),'NQN_TIPO')
	Local cUsuario   := Left( UsrRetName( JurGetDados("RD0",1,xFilial("RD0")+oModel:GetValue("NTEDETAIL","NTE_CPART"),"RD0_USER") ), TamSx3("NT4_USUINC")[1] )

	Default cComplemento := ""

	Begin Sequence

	//Seta o Cajuri
		JA106SETXV( {"",cAto,Date(),"","",oModel:GetValue("NTAMASTER","NTA_CAJURI" ),"","" } )

		oMMaster := FWLoadModel("JURA100")
		oMMaster:SetOperation( 3 )
		oMMaster:Activate()

		oModelNT4 := oMMaster:GetModel( 'NT4MASTER' )
		oModelNZL := oMMaster:GetModel( 'NZLDETAIL' )

		oModelNT4:SetValue('NT4_CATO'  , cAto)  //Seta o ato processual
		oModelNT4:SetValue('NT4_DESC'  , oModel:GetValue("NTAMASTER","NTA__OBSER" ))  //Grava a mudança de Status
		oModelNT4:SetValue('NT4_USUINC', cUsuario )  //Seta o usuário de inclusão
		oModelNT4:SetValue('NT4_USUALT', cUsuario )  //Seta o usuário de alteração

		if Empty(oModelNT4:getValue("NT4_CAJURI"))
			oModelNT4:LoadValue('NT4_CAJURI',oModel:GetValue("NTAMASTER","NTA_CAJURI" ))  //Seta o usuário de alteração
		Endif

		If Empty(oModel:GetValue("NTAMASTER","NTA__OBSER" ))  //Origem Protheus irá preencher o campo do Fluig no futuro.

			oModelNT4:SetValue('NT4_DESC'  , cComplemento )  //Grava a mudança de Status

			oModelNZL:SetValue('NZL_CODWF' , oModel:GetValue("NTAMASTER","NTA_CODWF" ) )
			oModelNZL:SetValue('NZL_DCAMPO', "sObsExecutor")
			oModelNZL:SetValue('NZL_CSTEP' , "16")

			FWExecView(STR0003,'JURA100',3,,{|| .T. },/*bOk*/,/*nPercReducao*/,/*aEnableButtons*/,{|| lCancelado := .T.}/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oMMaster)  //"Incluir"

			lRet := !( lCancelado )

		Else

			If nQtdNZM > 1
				For nA := 1 to nQtdNZM

					If nA > 1 .And. !oModelNZL:isEmpty()
						oModelNZL:AddLine()
					EndIf

					If oModelNZM:GetValue("NZM_STATUS", nA) == cTipoNQN
						oModelNZL:SetValue('NZL_CODWF' , oModelNZM:GetValue("NZM_CODWF", nA) )
						oModelNZL:SetValue('NZL_DCAMPO', oModelNZM:GetValue("NZM_CAMPO", nA) )
						oModelNZL:SetValue('NZL_CSTEP' , oModelNZM:GetValue("NZM_CSTEP", nA) )
					EndIf
				Next
			Elseif !IsInCallStack('MTJurSyncFollowUp')
               oModelNZL:SetValue('NZL_CODWF' , oModel:GetValue("NTAMASTER","NTA_CODWF" ) )
               oModelNZL:SetValue('NZL_DCAMPO', "sObsExecutor")
               oModelNZL:SetValue('NZL_CSTEP' , "16")
			EndIf

			If  !( oMMaster:VldData() )
				ConOut( "JA106GerNT4: " + STR0141 + CRLF + oMMaster:GetErrorMessage()[6]) //"Problema na validação do andamento!"
				lRet := .F.
				Break
			EndIf

			If  lRet .And. !( oMMaster:CommitData() )
				ConOut( "JA106GerNT4: " + STR0142 + CRLF + oMMaster:GetErrorMessage()[6]) //"Problema no commit do andamento!"
				lRet := .F.
				Break
			EndIf

			oMMaster:DeActivate()

		EndIf

	End Sequence

	FWModelActive(oModel,.T.)

	//valida se foi realizado com sucesso para limpar o NZM
	If lRet .And. nQtdNZM > 0
		For nA := 1 to nQtdNZM
			If !oModelNZM:isEmpty() .And. !oModelNZM:isDeleted(nA)
				oModelNZM:GoLine(nA)
				oModelNZM:DeleteLine()
			Endif
		Next
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106ConfNZK
Confirma o valor conforme o status do follow-up
Uso no cadastro de Follow-ups.

@param 	oModelNZK  Modelo da NZK
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 16/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA106ConfNZK(oModel, lConfirma)

	Local aArea      := GetArea()
	Local nA, nI     := 0  
	Local lRet       := .T.
	Local cStatus    := ''
	Local cFonte     := ''
	Local cModelo    := ''
	Local cCampo     := ''
	Local cValor     := ''
	Local xValor     := ''
	Local cAlias     := ''
	Local cChave     := ''
	Local cCmpChave  := ''
	Local cFiltro    := ''
	Local bFiltro    := nil
	Local oModelX    := nil
	Local oModelZ    := nil
	Local cTpCampo   := ''
	Local aErro      := {}
	Local oModelNZK  := oModel:GetModel( 'NZKDETAIL' )
	Local aCampos 	 := {} //fonte - modelo - campo - linha
	Local nIndexChv  := 1	//NSY_FILIAL+NSY_COD+NSY_CAJURI
	Local cChaveConc := ""

	//Inclui primeiro no array para poder ordenar de acordo com o dicionário
	For nA := 1 to oModelNZK:Length(.T.)
		If  oModelNZK:isEmpty()
			lRet := .F.
			Exit
		Endif

		cStatus := oModelNZK:GetValue('NZK_STATUS',nA)

		If  (cStatus $ '23') .Or. oModelNZK:IsDeleted(nA)  //1- Pendente / 2- Executado.
			Loop
		EndIf

		aAdd(aCampos,{Alltrim(oModelNZK:GetValue('NZK_FONTE',nA) ),Alltrim(oModelNZK:GetValue('NZK_MODELO',nA) ),Alltrim(oModelNZK:GetValue('NZK_CAMPO',nA) ),JURX3INFO( Alltrim(oModelNZK:GetValue('NZK_CAMPO',nA) ), "X3_ORDEM" ),nA})
	Next

	//Ordem do array baseado no dicionário para evitar erros com o WHEN
	aSort(aCampos, , ,{|x,y| (x[1]+x[2]+x[4]) < (y[1]+y[2]+y[4]) })

	For nA := 1 to LEN(aCampos)

		oModelNZK:GoLine( aCampos[nA][5] )
		cStatus := oModelNZK:GetValue('NZK_STATUS')

		If  lConfirma

			//valida se o fonte é diferente
			If (cFonte != AllTrim( oModelNZK:GetValue('NZK_FONTE') ))

				If  !Empty(cFonte) //valida se o fonte não estava vazio pois indica que o modelo esta ativo.

              		//Commita as alterações
					If !oModelX:VldData() .Or. !oModelX:CommitData()
						JurConOut(STR0143 + ' (1)') //"Problema na validação do valor: "
						aErro := oModelX:GetErrorMessage()
						VarInfo("GetErrorMessage()", aErro)
						Loop
					EndIf

					oModelX:DeActivate()
				EndIf

				cFonte  := Alltrim(oModelNZK:GetValue('NZK_FONTE') )
				cModelo := Alltrim(oModelNZK:GetValue('NZK_MODELO') )
				cChave  := oModelNZK:GetValue('NZK_CHAVE')
				cFiltro := Alltrim(oModelNZK:GetValue('NZK_FILTRO'))

	            //Define o alias do fonte
				Do Case
					Case cFonte == "JURA095"
						cAlias := "NSZ"
					Case cFonte == "JURA100"
						cAlias := "NT4"
					Case cFonte == "JURA106"
						cAlias := "NTA"
					Case cFonte == "JURA098"
						cAlias := "NT2"
					Case cFonte == "JURA099"
						cAlias := "NT3"
					Case cFonte == "JURA270"
						cAlias := "O0W"
					Case cFonte == "JURA094"
						cAlias	  := "NSY"
						nIndexChv := 3	//NSY_FILIAL+NSY_COD+NSY_CAJURI
				EndCase

				DbSelectArea(cAlias)
				DbSetOrder(nIndexChv)

				If  !( DbSeek(cChave) )
					ConOut( "JA106AltProc: " + STR0145 + cChave ) //"Chave não encontrada na base! Chave: "
					Loop
				EndIf

				cCmpChave := IndexKey()

				If  !( Empty(cFiltro) )
					bChave  := &('{|| Rtrim(' + cCmpChave + ') == "' + RTrim(cChave) + '"}')
					bFiltro := &('{|| ' + Alltrim(cFiltro) + '}')
					Do  While !( Eof() ) .And. Eval(bChave) .And. !( Eval( bFiltro ) )
						DbSkip()
					EndDo

					If  Eof() .Or. !( Eval(bChave) ) .Or. !( Eval(bFiltro) )
						ConOut( "JA106AltProc: " + STR0146 + cFiltro ) //"Filtro não encontrado na base! Filtro: "
						Loop
					EndIf
				EndIf

				if (cFonte == "JURA095")
					cTipoAsJ :=	JurGetDados('NSZ', 1 , xFilial('NSZ') + oModel:GetValue('NTAMASTER','NTA_CAJURI') , 'NSZ_TIPOAS')
					c162TipoAs := cTipoAsJ
				Endif

				//Carrega o modelo configurado na NZK com a Tabela e o Registro posicionado
				oModelX := FWLoadModel( cFonte )
				oModelX:SetOperation( 4 )
				oModelX:Activate()

				oModelZ := oModelX:GetModel( cModelo )

			EndIf //fim da validação se mudou o campo

			//valida se não mudou apenas o modelo e não o fonte.
			If  cModelo != AllTrim( oModelNZK:GetValue('NZK_MODELO') )
				cModelo := AllTrim( oModelNZK:GetValue('NZK_MODELO') )
				oModelZ := oModelX:GetModel( cModelo )
			EndIf

			cCampo  := Alltrim(oModelNZK:GetValue('NZK_CAMPO'))
			cAlias  := Left(cCampo,3)
			cValor  := Alltrim(oModelNZK:GetValue('NZK_VALOR'))

			cTpCampo := TamSx3(cCampo)[3]

			If  (cTpCampo == 'N')
				xValor := Val(cValor)
			ElseIf  (cTpCampo == 'D')
				xValor := StoD(cValor)
			Else
				xValor := AllTrim(cValor)
			EndIf

			//Altera o valor da tabela conforme aprovação do follow-up.
			If cFonte == "JURA270"
				For nI := 1 To oModelZ:Length()
					oModelZ:GoLine(nI)
					//Posiciona na verba correta
					cChaveConc := xFilial("O0W")+oModelZ:GetValue('O0W_COD')
					If AllTrim(cChaveConc) == AllTrim(cChave)
						lRet := oModelZ:SetValue(cCampo, xValor)
						Exit
					EndIf
				Next
			Else 
				lRet := oModelX:SetValue(cModelo, cCampo, xValor)
			EndIf

			//Atualiza a NZK
			If lRet
				oModelNZK:SetValue("NZK_STATUS", "2")
			Else
				JurMsgErro( I18n(STR0162, {cCampo}) )	//"Não foi possível atualizar o campo #1"
			EndIf

			//valida se é a última linha e confirma as alterações
			If  (nA >= oModelNZK:Length(.T.))
				//Commita as alterações
				If !oModelX:VldData() .Or. !oModelX:CommitData()
					JurConOut(STR0143 + ' (2)') //"Problema na validação do valor: "
					lRet  := .F.
					aErro := oModelX:GetErrorMessage()
					VarInfo("GetErrorMessage()", aErro)
				EndIf
				oModelX:DeActivate()
			EndIf

		Else //Limpa NZK (Faz exclusão lógica dos registros) - Alteração do Resultado do Follow-up de EM APROVAÇÃO para PENDENTE
			If !Empty(oModelNZK:GetValue('NZK_STATUS'))
				//oModelNZK:SetValue('NZK_STATUS',"2")
				If !(oModelNZK:IsDeleted() .And. oModelNZK:isEmpty())
					oModelNZK:DeleteLine()
				EndIf
			EndIf
		EndIf
	Next nA

	FWModelActive(oModel,.T.)
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106WFWhen
Libera a edição do campo NTA_CODWF para a integração FLUIG e bloqueia para a tela.
Uso no cadastro de Follow-ups.

@param 	cTipoPai  	Código do tipo de follow-up
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 19/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106WFWhen()
	Local lRet     := .T.
	Local cNQNTipo := ''

	If  !( IsInCallStack('MTJurSyncFollowUp') ) .And. !( Empty(FwFldGet( 'NTA_CODWF' )) ) .And. (SuperGetMV('MV_JFLUIGA',,'2') == '1')
		cNQNTipo := Posicione('NQN',1,xFilial('NQN')+FwFldGet( 'NTA_CRESUL' ),'NQN_TIPO')

		lRet := !(cNQNTipo == '4') //Nao Em Aprovacao
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106TIPOP
Verifica se o tipo de follow-up está configurado com recursividade
Uso no cadastro de Follow-ups.

@param 	cTipoPai  	Código do tipo de follow-up
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106TIPOP(cTipoPai)
	Local lRet     := .T.

	aTipoFW := {} // Array para controlar a  recursividade das chamadas de tipo de follow-up

	aAdd( aTipoFW, cTipoPai )
	lRet := JA106VTIPO(cTipoPai)
	aTipoFW := {}

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106VTIPO
Valida o tipo de follow-up se possui configuração de follow-up padrão
com recursividade
Uso no cadastro de Follow-ups.

@param 	cTipoPai  	Código do tipo de follow-up
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106VTIPO(cTipoPai)
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaNVD := NVD->( GetArea() )
	Local aAreaNRT := NRT->( GetArea() )
	Local nPos     := 0
	Local nAt      := 0

	NVD->( dbSetOrder( 1 ) )
	NVD->( dbSeek( xFilial( 'NVD' ) + cTipoPai ) )

	While !NVD->( EOF() ) .And. xFilial( 'NVD' ) + cTipoPai == NVD->NVD_FILIAL + NVD->NVD_CTIPOF

		NRT->( dbSetOrder( 1 ) )

		If NRT->( dbSeek( xFilial( 'NRT' ) + NVD->NVD_CTFPAD) )

			If ( nAt := aScan( aTipoFW, NRT->NRT_CTIPOF) ) > 0

				lRet := .F.
				JurMsgErro( STR0032 ) //"Não será possível gerar o(s) outro(s) follow-up(s). Verificar configuração de tipo e follow-up padrão"
				Exit

			EndIf

			aAdd( aTipoFW, NRT->NRT_CTIPOF )

			nPos := Len( aTipoFW )

			If !JA106VTIPO(NRT->NRT_CTIPOF)
				lRet := .F.
				Exit
			EndIf

			aDel( aTipoFW, nPos  )

		EndIf

		NVD->( dbSkip() )

	End

	RestArea( aAreaNVD )
	RestArea( aAreaNRT )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106NRR
Monta a query de responsáveis do follow-up padrão
Uso no cadastro de Follow-up.

@Return cFwPadrao   Código de Follow-up Padrão
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 08/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106NRR(cFwPadrao)
	Local cQuery  := ""

	cQuery := "SELECT NRR.NRR_CPART, RD0.RD0_SIGLA NRR_SIGLA  "
	cQuery += "FROM " + RetSqlName( "NRR" ) + " NRR, "+ RetSqlName( "RD0" ) + " RD0 "
	cQuery += "WHERE NRR_FILIAL = '" + xFilial( "NRR" ) + "' "
	cQuery += "  AND RD0.D_E_L_E_T_ = ' ' "
	cQuery += "  AND RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "' "
	cQuery += "  AND NRR.NRR_CFOLWP = '" +cFwPadrao+ "' "
	cQuery += "  AND NRR.D_E_L_E_T_ = ' ' "
	cQuery += "  AND NRR.NRR_CPART  = RD0.RD0_CODIGO"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106REAG
Verifica se um follow-up pendente foi reagendado
Uso na Legenda do cadastro de Follow-up.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 20/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106REAG()
	Local lRet := .F.

	lRet := Posicione('NQN',1,xFilial('NQN')+NTA->NTA_CRESUL,'NQN_TIPO') == '1' .AND. ;
		NTA->NTA_DTFLWP >= DATE() .AND. NTA->NTA_REAGEN == '1'

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR106PEN
Verifica se um follow-up pendente não foi reagendado, ou seja, está em
andamento
Uso na Legenda do cadastro de Follow-up.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 20/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR106PEN()
	Local lRet := .F.

	lRet:= Posicione('NQN',1,xFilial('NQN')+NTA->NTA_CRESUL,'NQN_TIPO') == '1' .AND. ;
		NTA->NTA_DTFLWP >= DATE() .AND. NTA->NTA_REAGEN == '2'

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106CAJUR
Verifica o preenchimento do campo de código de assunto jurídico
Uso no cadastro de Follow-up.

@Return cRet	 	Código do assunto jurídico

@author Juliana Iwayama Velho
@since 06/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106CAJUR()
	Local cRet := ''
	Local aVar := {}

	If IsInCallStack('JURA100COM')
		cRet := NT4->NT4_CAJURI
	ElseIf IsInCallStack('JA106GFWIU')
		aVar := JURGETXVAR()
		If aVar <> NIL
			cRet:= aVar[13]
		EndIf
	ElseIf ! Empty(M->NSZ_COD)
		cRet := M->NSZ_COD
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106CFPAI
Verifica o preenchimento do campo de código de followup pai
Uso no cadastro de Follow-up.

@Return cRet	 	Código do follow-up pai

@author Juliana Iwayama Velho
@since 06/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106CFPAI()
Local cRet := ''
Local aVar := {}

	If IsInCallStack('JURA100COM') 
		cRet := JA106getCf()
	EndIf

	If IsInCallStack('JA106GFWIU') .And. Empty(cRet)
		aVar := JURGETXVAR()
		If aVar <> NIL
			cRet:= aVar[14]
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106SETXV
Guarda os valores do array de sugestão de campos de follow-up para o
andamento
Uso Follow-up.

@Param xConteudo	 	Array de valores

@author Juliana Iwayama Velho
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106SETXV( xConteudo )
	xVarSugFw := xConteudo
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106GETXV
Retorna o valor guardado na variável
Uso Geral.

@Return xVarSugFw	 	Conteúdo de valores

@author Juliana Iwayama Velho
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106GETXV()
Return xVarSugFw

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106CLEXV
Limpa o conteúdo da variavel
Uso Geral.

@author Juliana Iwayama Velho
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106CLEXV()
	xVarSugFw := NIL
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106INCPS
Verifica se os campos devem ser preenchidos ao entrar na tela. Utilização
desta rotina ao invés de inicializador padrão em cada campo
Uso no cadastro de Follow-ups.

@param 	oModel  	Model a ser verificado
@sample

@author Juliana Iwayama Velho
@since 17/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA106INCPS(oModel)
	Local aArea  := GetArea()
	Local nOpc   := oModel:GetOperation()

	If nOpc == 3

		oModel:SetValue("NTAMASTER",'NTA_DTFLWP',JUR106SGDT())
		oModel:SetValue("NTAMASTER",'NTA_HORA'  ,JUR106SGHO())
		oModel:SetValue("NTAMASTER",'NTA_CTIPO' ,JUR106SGTF())
		oModel:SetValue("NTAMASTER",'NTA_DURACA',JUR106SGDU())
		oModel:SetValue("NTAMASTER",'NTA_CPREPO',JUR106SGPR())
		oModel:SetValue("NTAMASTER",'NTA_CRESUL',JURA106R( 'NTA_CRESUL' , nOpc))
		oModel:SetValue("NTAMASTER",'NTA_CATO'  ,JUR106SGAT())
		oModel:SetValue("NTAMASTER",'NTA_CFASE' ,JUR106SGFS())
		oModel:SetValue("NTAMASTER",'NTA_DESC'  ,JUR106SGDE())
		oModel:SetValue("NTAMASTER",'NTA_CFLWPP',JA106CFPAI())
		JUR106SGRP(oModel)
		oModel:SetValue("NTAMASTER",'NTA_CANDAM',JA100GetCa())

		If IsInCallStack( 'JURA100COM' ) //Geração de follow-up por intervenção do usuário a partir de andamento com data do próximo evento preenchido.
			If !Empty(NT4->NT4_DTPREV)
				oModel:SetValue("NTAMASTER",'NTA_DTFLWP',NT4->NT4_DTPREV)
			EndIf
		EndIf

		If !Empty( oModel:GetValue("NTAMASTER",'NTA_DTFLWP') )
			oModel:SetValue("NTAMASTER",'NTA_DTLIMT',oModel:GetValue("NTAMASTER",'NTA_DTFLWP') + 1)
		EndIf

	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106SetCf
Guarda o valor do código do follow-up inserido pela sugestão de andamento

@Param xConteudo	 	Código do follow-up

@author Juliana Iwayama Velho
@since 08/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106SetCf( xConteudo )
	xVarCodFw := xConteudo
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106GetCf
Retorna o valor guardado na variável
Uso Geral.

@Return xVarCodFw	 	Código do follow-up

@author Juliana Iwayama Velho
@since 08/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106GetCf()
Return xVarCodFw

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106VincA
Verifica o vínculo de andamento ao follow-up

@param   nVez    - Indica se esta executando a função pela 1 ou 2 vez
@param  cCodAnd - Código do andamento
@param   cCodPai - Código pai
@Return lRet	- .T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 22/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106VincA(nVez,cCod,cCodPai)
Local lRet     := .T.
Local dDtAnd   := ctod('')
Local cCodAto  := ''
Local cDesAto  := ''
Local cCodAnd  := ''
Local cCodProx := ''
Local lApaga   := .F.

	If !Empty(cCod)
		cCodAnd:= Posicione('NT4', 5 , xFilial('NT4') + cCod, 'NT4_COD')
	EndIf

	If Empty(cCodAnd)
		cCodAnd :=  JACodAnd(cCod)
	Endif

	If nVez = 2
		cCodAnd:= Posicione('NTA', 1 , xFilial('NTA') + cCod, 'NTA_CANDAM')
		If Empty(cCodAnd)
			cCodAnd := cCodPai
		EndIf
	ElseIf cCodAnd == JA100GetCa()
		cCodAnd := ''
	EndIf

	If !Empty(cCodAnd)
		DbSelectArea("NT4")
		NT4->( dbSetOrder( 1 ) )
		If NT4->( dbSeek( xFilial( 'NT4' ) + cCodAnd ) )
			dDtAnd    := Posicione('NT4', 1 , xFilial('NT4') + cCodAnd, 'NT4_DTANDA'       )
			cCodAto   := Posicione('NT4', 1 , xFilial('NT4') + cCodAnd, 'NT4_CATO'         )
			cDesAto   := AllTrim(Posicione('NRO', 1 , xFilial('NRO') + cCodAto, 'NRO_DESC'))

			If Empty(cCod)
				cCod  := Posicione('NTA', 5 , xFilial('NTA') + cCodAnd, 'NTA_COD')
			EndIf


			If !Empty(NT4->NT4_CFWLP)
				cCodProx:= NT4->NT4_CFWLP
			Else
				cCodProx := cCod
			EndIf

			If nVez == 1
				If Empty(Posicione('NTA', 5 , xFilial('NTA') + cCodAnd, 'NTA_COD'))
					lApaga  := .T.
				EndIf
			Else
				If Empty(Posicione('NT4', 5 , xFilial('NT4') + cCodProx, 'NT4_COD'))
					lApaga  := .T.
				EndIf
			EndIf

			DbSelectArea("NT4")
			NT4->( dbSetOrder( 1 ) )
			If NT4->( dbSeek( xFilial( 'NT4' ) + cCodAnd ) )
				Reclock( 'NT4', .F. )
				dbDelete()
				MsUnlock()
				lRet := DELETED()
			EndIf

			If nVez == 1
				If Empty(Posicione('NTA', 5 , xFilial('NTA') + cCodAnd, 'NTA_COD'))
					lApaga  := .T.
				EndIf
			Else
				If Empty(Posicione('NT4', 5 , xFilial('NT4') + cCodProx, 'NT4_COD'))
					lApaga  := .T.
				EndIf

				If cCod == JA106GetCf() .And. !Empty(NTA->NTA_CANDAM)
					Reclock( 'NTA', .F. )
					NTA->NTA_CANDAM := ''
					MsUnlock()
				EndIf

			EndIf

			If !Empty(cCodAnd)
				DbSelectArea("NT4")
				NT4->( dbSetOrder( 1 ) )
				If NT4->( dbSeek( xFilial( 'NT4' ) + cCodAnd ) )
					Reclock( 'NT4', .F. )
					NT4->NT4_CFWLP := ''
					MsUnlock()
				EndIf
			EndIf

			If lRet

				If lApaga
					cCodAnd := ''
					cCodProx:= ''
				EndIf

				If cCodProx == JA106GetCf()
					cCodProx := ''
				EndIf
				lRet := JA100VincF(nVez,cCodAnd,cCodProx,dDtAnd,cCodAto)
			EndIf

		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JACodAnd
Verifica o vínculo de andamento ao follow-up
@param 	cCodAnd  	Código do andamento
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 22/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JACodAnd(cCodFw)
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cCodAnd   := ''

	BeginSql Alias cAliasQry

		SELECT NT4.NT4_COD
		FROM %Table:NT4% NT4
		WHERE NT4.NT4_CFWLP  = %Exp:cCodFW%
		AND NT4.NT4_FILIAL = %xFilial:NT4%
		AND NT4.%notDel%
	EndSql

	IF !(cAliasQry)->(EOF())
		cCodAnd := (cAliasQry)->NT4_COD
	Endif

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return cCodAnd

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106VCOR
Valida correspondente.
Uso nos campos NTA_CCORRE\NTA_LCORRE.
@return 	lRet - .T./.F. As informações são válidas ou não
@author		Rafael Tenorio da Costa
@since 		24/02/15
@version	1.0
/*/
//-------------------------------------------------------------------
Function JA106VCOR()

	Local lRet        := .T.
	Local aArea       := GetArea()
	Local oModel      := FWModelActive()
	Local cCodCorres  := oModel:GetValue("NTAMASTER", "NTA_CCORRE")
	Local cLojCorres  := oModel:GetValue("NTAMASTER", "NTA_LCORRE")
	Local cCodAdvoga  := oModel:GetValue("NTAMASTER", "NTA_CADVCR")
	Local nFlxCorres  := SuperGetMV("MV_JFLXCOR", , 1)				//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
	Local cEmailCorr  := ""
	Local cEmailAdvo  := ""
	Local cProcesso   := oModel:GetValue("NTAMASTER", "NTA_CAJURI")
	Local aAux1       := {}
	Local cTipoAssu   := ""
	Local cAreaJuri   := ""
	Local cComarca    := ""
	Local aTabelas    := {}

	If nFlxCorres == 2

		If !Empty(cCodCorres) .OR. !Empty(cLojCorres)
			JurMsgErro(STR0060)		//Fluxo de correspondente configurado para ser preenchido no Assunto Jurídico, verifique o parametro MV_JFLXCOR
			lRet := .F.
		EndIf
	Else

		//Valida preenchimento do E-mail de Advogado\Correspondente
		If !Empty(cCodAdvoga)

			cEmailAdvo	:= JurGetDados("SU5", 1, xFilial("SU5") + cCodAdvoga, "U5_EMAIL")

			If Empty(cEmailAdvo)
				JurMsgErro(STR0061)		//Email do Advogado não cadastrado, verifique o cadastro.
				lRet := .F.
			EndIf
		Else

			If !Empty(cCodCorres)
				cEmailCorr	:= JurGetDados("SA2", 1, xFilial("SA2") + cCodCorres + cLojCorres, "A2_EMAIL")

				If Empty(cEmailCorr)
					JurMsgErro(STR0062)		//Email do Correspondente não cadastrado, verifique o cadastro.
					lRet := .F.
				EndIf
			EndIf
		EndIf
		//Valida corresponde com comarca e area do processo
		If lRet
			If M->NSZ_TIPOAS == NSZ->NSZ_TIPOAS .AND. M->NSZ_CAREAJ == NSZ->NSZ_CAREAJ
				aAux1 := JurGetDados("NSZ", 1, xFilial("NSZ") + cProcesso, {"NSZ_TIPOAS", "NSZ_CAREAJ"} )	//NSZ_FILIAL+NSZ_COD
			else
				AADD(aAux1,M->NSZ_TIPOAS)
				AADD(aAux1,M->NSZ_CAREAJ)
			endif

			If Len(aAux1) > 1
				cTipoAssu := aAux1[1]
				cAreaJuri := aAux1[2]
			EndIf

			//Pega as tabelas relacionadas ao assunto juridico
			aTabelas := JA158RtNYC( cTipoAssu )

			//Pega a comarca
			If Ascan( aTabelas, {|x| AllTrim(x) == "NUQ"} ) > 0
				cComarca := JurGetDados("NUQ", 2, xFilial("NUQ") + cProcesso + "1", "NUQ_CCOMAR" )	//NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
			EndIf

			//Valida correspondente com a comarca e area do processo
			If !Ja095CorCA(cCodCorres, cLojCorres, cAreaJuri, cComarca)
				JurMsgErro(STR0096)		//"Correspondente configurado no follow-up não está relacionado com a área jurídica ou comarca do processo."
				lRet := .F.
			EndIf
		EndIf

	EndIf

	RestArea( aArea )

Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} JA106SETAP
Guarda o valor da autorizacao de pagamento para o andamento
Uso Andamento.

@Param cConteudo - Define se autoriza o pagamento 1-Sim\2-Nao

@author Rafael Tenorio da Costa
@since 27/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106SETAP( cConteudo )
	Default cConteudo := ''

	xVarAutPag := cConteudo
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106GETAP
Retorna o valor da autorizacao de pagamento para o andamento
Uso Andamento.

@Return xVarAutPag - Define se autoriza o pagamento 1-Sim\2-Nao

@author Rafael Tenorio da Costa
@since 27/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106GETAP()
Return xVarAutPag

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106WFECO
Prepara o WorkFlow que sera enviado ao Correspondente para Aceite
Uso Follow-up.

@param	oModel 		- Model do NTA
@param	lReenvio	- Defini se é reenvio de workflow
@param	cErro		- Mensagem de erro

@author Rafael Tenorio da Costa
@since 27/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106WFECO(oModel, lReenvio, cErro)

	Local lRetorno   := .T.
	Local aArea      := GetArea()
	Local aAreaSA2   := SA2->( GetArea() )
	Local aAreaSU5   := SU5->( GetArea() )
	Local aAreaNSZ   := NSZ->( GetArea() )
	Local aAreaNUQ   := NUQ->( GetArea() )
	Local aAreaNT9   := NT9->( GetArea() )
	Local oProcess   := Nil
	Local cProcess   := "" //Codigo do processo gerado pelo WF
	Local oHtml      := Nil
	Local cCodProWf  := SuperGetMv("MV_JCDWFCO", .F., "000001") //Codigo do processo de workflow do aceite de correspondente
	Local cCaModWfAt := SuperGetMv("MV_JCAWFCO", .F., "\WORKFLOW\MODELOS\ACEITE_CORRESPONDENTE.HTM") //Caminho e modelo de workflow do aceite de correspondente
	Local cImgWfCorr := SuperGetMv("MV_JIMWFCO", .F., "http://www.totvs.com/sites/all/themes/totvs/logo.png") //Caminho com o logo da imagem que sera apresentada no html
	Local cSiteWfCor := SuperGetMv("MV_JSIWFCO", .F., "http://www.totvs.com/") //Caminho do site que sera aberto quando clicado na imagem no html
	Local cDirHttp   := SuperGetMv("MV_WFBRWSR", .F., "127.0.0.1:82") //IP ou nome do servidor HTTP
	Local cAssunto   := STR0065 //"Aceite de Correspondente"
	Local cPasta     := "aceite_correspondente" //Pasta dentro do diretorio http onde sera salvo o html gerado
	Local cCorpo     := ""
	Local cMsg       := ""
	Local cCodCorres := oModel:GetValue("NTAMASTER", "NTA_CCORRE")
	Local cLojCorres := oModel:GetValue("NTAMASTER", "NTA_LCORRE")
	Local aCmpsCorre := GetAdvFVal("SA2", {"A2_NOME", "A2_EMAIL"}, xFilial("SA2") + cCodCorres + cLojCorres, 1)
	Local cCodAdvoga := oModel:GetValue("NTAMASTER", "NTA_CADVCR")
	Local aCmpsAdvog := GetAdvFVal("SU5", {"U5_CONTAT", "U5_EMAIL"}, xFilial("SU5") + cCodAdvoga, 1)
	Local cAssJur    := oModel:GetValue("NTAMASTER", "NTA_CAJURI")
	Local cNome      := ""
	Local cEmail     := ""
	Local cJustifica := ""
	Local cMsgEmail  := ""
	Local cTexto     := ""
	Local cTipoAjuri := JurGetDados("NSZ", 1, xFilial("NSZ") + cAssJur, "NSZ_TIPOAS")
	Local cCodigoFw  := oModel:GetValue("NTAMASTER", "NTA_COD")
	Local aEmails    := {}
	Local nX         := 0
	Local lValidMail := .T.

	Default lReenvio := .F.

	//Verifica se foi preenchido o destinatario
	If Empty(cCodCorres) .And. Empty(cCodAdvoga)

		If lReenvio
			cErro := STR0007 + " " + cCodigoFw + " - " + STR0093 //"Follow-up"	#	"Não foi preenchido o correspondente para envio do workflow."
		Else
			If oModel:GetValue("NTAMASTER", "NTA_ACEITO") <> "2"
				cErro := STR0093 	//"Não foi preenchido o correspondente para envio do workflow."
				JurMsgErro(cErro)
			EndIf
		EndIf

		lRetorno := .F.
	Else

		//-----------------------------------------
		//Inicializa processo de WorkFlow
		//-----------------------------------------
		oProcess             := TWFProcess():New( cCodProWf, /*cDescr*/, /*cProcID*/ )
		oProcess:NewTask( cAssunto, cCaModWfAt )
		oProcess:cSubject    := cAssunto
		oProcess:bReturn     := "JA106WFRCO()"
		oProcess:nEncodeMime := 0
		oProcess:cTo         := cPasta
		oProcess:UserSiga    := __cUserID
		oProcess:NewVersion(.T.)

		//-----------------------------------------
		//Prepara Html que sera enviado
		//-----------------------------------------
		oHtml					:= oProcess:oHTML

		//-----------------------------------------
		//Carrega campos do html
		//-----------------------------------------
		If oHtml == Nil

			JurMsgErro(STR0086)	//"Não foi enviado workflow de correspondente, porque não foi encontrado o modelo de html, verifique o parâmetro MV_JCAWFCO."
			lRetorno := .F.
		Else

			//Carregando imagem
			oHtml:ValByName( "IMAGEM", cImgWfCorr )
			oHtml:ValByName( "SITE" , cSiteWfCor )

			//Assuntos Juridicos
			DbSelectArea("NSZ")
			NSZ->( DbSetOrder( 1 ) ) //NSZ_FILIAL+NSZ_COD
			If NSZ->( DbSeek( xFilial("NSZ") + cAssJur ) )

				oHtml:ValByName( "NSZ_CCLIEN", NSZ->NSZ_CCLIEN )
				oHtml:ValByName( "NSZ_LCLIEN", NSZ->NSZ_LCLIEN )
				oHtml:ValByName( "NSZ_DCLIEN", JurGetDados("SA1", 1, xFilial("SA1") + NSZ->NSZ_CCLIEN + NSZ->NSZ_LCLIEN, "A1_NOME") )
			EndIf

			//Follow-up
			oHtml:ValByName( "NTA_DESC"  , oModel:GetValue("NTAMASTER", "NTA_DESC") )
			oHtml:ValByName( "NTA_DTFLWP", DtoC( oModel:GetValue("NTAMASTER", "NTA_DTFLWP") ) )
			oHtml:ValByName( "NTA_DTLIMT", DtoC( oModel:GetValue("NTAMASTER", "NTA_DTLIMT") ) )
			oHtml:ValByName( "NTA_CTIPO" , JurGetDados("NQS", 1, xFilial("NQS") + FwFldGet( "NTA_CTIPO" ), "NQS_DESC") )
			oHtml:ValByName( "NTA_CRESUL", JurGetDados("NQN", 1, xFilial("NQN") + FwFldGet( "NTA_CRESUL"), "NQN_DESC") )

			//Adiciona campos no html dependendo do tipo de assunto juridico
			JA106CAMWF( oModel, oHtml, cTipoAjuri )

			//Pega informacoes do destinatario
			If !Empty(cCodAdvoga)
				cNome  := aCmpsAdvog[1]
				cEmail := aCmpsAdvog[2]
			Else
				cNome  := aCmpsCorre[1]
				cEmail := aCmpsCorre[2]
			EndIf

			//Adiciona parametros de retorno
			Aadd( oProcess:aParams, xFilial("NTA") )
			Aadd( oProcess:aParams, cCodigoFw)
			Aadd( oProcess:aParams, cEmail )

			//Inicia proceso de envio e grava html e tabela do WF
			cProcess := oProcess:Start()

			//Carrega mensagem
			cMsg := ""
			cMsg += STR0066 + cNome + CRLF		//"Sr.(a) "
			cMsg += CRLF
			cMsg += STR0067 + CRLF				//"Enviamos o e-mail com o link abaixo para seu aceite. "
			cMsg += CRLF
			cMsg += STR0068 + CRLF				//"Atenciosamente, "
			cMsg += CRLF
			cMsg += STR0069 + CRLF				//"Workflow Totvs Protheus"
			cMsg += CRLF
			cMsg += '<p><a href="http://' + cDirHttp + '/messenger/emp' + cEmpAnt + '/' + cPasta + '/' + Alltrim(cProcess) + '.htm" target="_blank">' + STR0070 + '</a></p>'		//"clique aqui"
			cMsg += CRLF

			//Gera corpo do e-mail
			cCorpo := '<html>'
			cCorpo += '<div><span class=610203920-12022004><font face=Verdana color=#ff0000 '
			cCorpo += 'size=2><strong> ' + STR0069 + ' </strong></font></span></div><hr>'			//"Workflow Totvs Protheus"
			cCorpo += '<div><font face=verdana color=#000080 size=3><span class=216593018-10022004>' + cMsg + '</span></font></div><p>'
			cCorpo += '</html>'

			aEmails := Separa(AllTrim(cEmail),";")
			//Valida todos os e-mails cadastrados antes de enviar
			For nX:= 1 to Len(aEmails)
				If lValidMail
					lValidMail := IsEmail(AllTrim(aEmails[nX]))
				EndIf
			Next
			If lValidMail  
				//Envia e-mail
				lRetorno := JurEnvMail( /*cDe*/, cEmail, /*cCc*/, /*cCCO*/, cAssunto, /*cAnexo*/, cCorpo, /*cServer*/, /*cEmail*/, /*cPass*/, /*lAuth*/, /*cContAuth*/, /*cPswAuth*/)
			Else

				If !Empty(cCodAdvoga)
					cTexto := STR0116 //'Advogado'
				Else
					cTexto := STR0117 //'Correspondente'
				EndIf

				cMsgEmail := I18N( STR0118 + CRLF + CRLF, {cTexto, cNome}) //'E-mail do #1 #2 é inválido! Verifique.'
				lRetorno  := .F.
			EndIf

			//Atualiza campo de aceite\justificativa
			If lRetorno

				cJustifica := AllTrim( FwFldGet( "NTA_JUSTIF" ) ) + CRLF
				cJustifica += DtoC( dDataBase ) + " - " + Time() + " - " + STR0071 + ": " + cEmail //"Enviado"

				Reclock( "NTA", .F. )
				NTA->NTA_ACEITO := "3"
				NTA->NTA_JUSTIF := cJustifica
				NTA->( MsUnlock() )
			EndIf
		EndIf

		If !lRetorno

			cErro := STR0087 + STR0097 + CRLF + STR0088 + STR0092 + "."
			//"Não foi enviado workflow de correspondente"	#	", mas o follow-up será salvo."
			//"Para reenviar o workflow utilize a opção "	#	"Reenvia WF"

			JurMsgErro(cMsgEmail + cErro)
		EndIf

	EndIf

	RestArea( aAreaNT9 )
	RestArea( aAreaNUQ )
	RestArea( aAreaNSZ )
	RestArea( aAreaSU5 )
	RestArea( aAreaSA2 )
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106CAMWF
Adiciona campos no Html do Workflow de aceite de correspondente, dependendo do tipo de assunto juridico
Uso cadastro de Follou-up.

@param 	oModel	- Model do cadastro de follou-up
@param	oHtml 	- Objeto com os campos do workflow
@return	oHtml	- Objeto com os campos do workflow

@author Rafael Tenorio da Costa
@since 05/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA106CAMWF( oModel, oHtml, cTipoAjuri )

	Local aArea		:= GetArea()
	Local aAreaNUQ	:= NUQ->( GetArea() )
	Local aAreaNT9	:= NT9->( GetArea() )
	Local aCampos 	:= {}
	Local cAssJur	:= oModel:GetValue("NTAMASTER", "NTA_CAJURI")
	Local nCont		:= 0

	If cTipoAjuri > '050'
		cTipoAjuri := JurGetDados('NYB', 1, xFilial('NYB') + cTipoAjuri, 'NYB_CORIG')
	EndIf

	Do Case

	Case cTipoAjuri $ "001|004|009"

			//Instancia
		DbSelectArea("NUQ")
		NUQ->( DbSetOrder( 2 ) )	//NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
		If NUQ->( DbSeek( xFilial("NUQ") + cAssJur + "1" ) )

			Aadd(aCampos, {STR0072	, NUQ->NUQ_INSTAN } )		//"Instância"
			Aadd(aCampos, {STR0073	, NUQ->NUQ_NUMPRO } )		//"Processo"
			Aadd(aCampos, {STR0074	, JurGetDados("NQ1", 1, xFilial("NQ1") + NUQ->NUQ_CNATUR, "NQ1_DESC") } )		//"Natureza"
			Aadd(aCampos, {STR0075	, JurGetDados("NQ6", 1, xFilial("NQ6") + NUQ->NUQ_CCOMAR, "NQ6_DESC") } )		//"Comarca"
		EndIf

			//Envolvidos
		DbSelectArea("NT9")
		NT9->( DbSetOrder( 3 ) )	//NT9_FILIAL+NT9_CAJURI+NT9_TIPOEN+NT9_PRINCI
		If NT9->( DbSeek(xFilial("NT9") + cAssJur + "1" + "1" ) )
			Aadd(aCampos, {STR0076	, NT9->NT9_NOME } )		//"Pólo Ativo"
		EndIf

		If NT9->( DbSeek(xFilial("NT9") + cAssJur + "2" + "1" ) )
			Aadd(aCampos, {STR0077, NT9->NT9_NOME } )		//"Pólo Passívo"
		EndIf

	Case cTipoAjuri == "006"

			//Contratos
		Aadd(aCampos, {STR0078, NSZ->NSZ_NUMCON } )			//"Número do Contrato"

	Case cTipoAjuri == "010"

			//Licitações
		Aadd(aCampos, {STR0079, NSZ->NSZ_NUMLIC } )			//"Número da Licitação"

	Case cTipoAjuri == "011"

			//Marcas e Patentes
		Aadd(aCampos, {STR0080	, NSZ->NSZ_NUMPED } )		//"Número do Pedido"
		Aadd(aCampos, {STR0081	, NSZ->NSZ_NOMEMA } )		//"Nome da Marca"

	EndCase

	//Carrega html
	If Len(aCampos) == 0
		AAdd( (oHtml:ValByName( "CAMPO.1" )), " " )
		AAdd( (oHtml:ValByName( "CAMPO.2" )), " " )
		AAdd( (oHtml:ValByName( "CAMPO.3" )), " " )
		AAdd( (oHtml:ValByName( "CAMPO.4" )), " " )
	Else
		For nCont:=1 To Len(aCampos)

			AAdd( (oHtml:ValByName( "CAMPO.1" )), AllTrim( aCampos[nCont][1] ) + ":" )
			AAdd( (oHtml:ValByName( "CAMPO.2" )), aCampos[nCont][2] )

			If Len(aCampos) > nCont
				nCont++

				AAdd( (oHtml:ValByName( "CAMPO.3" )), AllTrim( aCampos[nCont][1] ) + ":" )
				AAdd( (oHtml:ValByName( "CAMPO.4" )), aCampos[nCont][2] )
			Else

				AAdd( (oHtml:ValByName( "CAMPO.3" )), " " )
				AAdd( (oHtml:ValByName( "CAMPO.4" )), " " )
			EndIf

		Next nCont
	EndIf

	RestArea( aAreaNT9 )
	RestArea( aAreaNUQ )
	RestArea( aArea )

Return oHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106WFRCO
Processa o retorno do WorkFlow que foi enviado ao Correspondente para Aceite
Uso retorno do WorkFlow chamada pelo html.

@param	oProcess 	- Objeto com o processo do workflow de aceite de correspondente
@return	lRet		- Define se o retorno do aceite de correspondente foi feito corretamente

@author Rafael Tenorio da Costa
@since 27/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106WFRCO(oProcess)

	Local aArea     := GetArea()
	Local aAreaNTA  := NTA->( GetArea() )
	Local lRet      := .T.
	Local cMsg      := ""
	Local cAceite   := ""
	Local cJustifica:= ""
	Local cEmail    := ""
	Local cFilNta   := ""
	Local cCodNta   := ""
	Local oModelFw  := FWLoadModel( "JURA106" )

	If oProcess <> Nil

		ConOut( JurTimeStamp( 2 ) + ' ' + STR0064 )		//"Executando processo de retorno do workflow de aceite de correspondente."

		//Parametros carregados ao enviar o WF
		cFilNta := oProcess:aParams[1]
		cCodNta := oProcess:aParams[2]
		cEmail	:= AllTrim( oProcess:aParams[3] )
		DbSelectArea( "NTA" )
		NTA->( DbSetOrder(1) )		//NTA_FILIAL+NTA_COD
		If NTA->( DbSeek(cFilNta + cCodNta) ) .AND. ( Empty(NTA->NTA_ACEITO) .Or. NTA->NTA_ACEITO == "3" )

			oModelFw:SetOperation( 4 )
			oModelFw:Activate()

			//Retorna campos do html
			cAceite    := oProcess:oHtml:RetByName("ACEITE")
			cJustifica := Alltrim( oProcess:oHtml:RetByName("JUSTIFICATIVA") )

			//----------------------------
			//Atualiza campos do follow-up
			//----------------------------
			oModelFw:LoadValue("NTAMASTER", "NTA_USUALT" , Left( oModelFw:GETValue("NTAMASTER", "NTA_DCORRE"), TamSX3('NTA_USUALT')[1] ))
			oModelFw:LoadValue("NTAMASTER", "NTA_ACEITO" , cAceite)
			oModelFw:LoadValue("NTAMASTER", "NTA_JUSTIF" , cJustifica)

			If ( lRet := oModelFw:VldData() )
				oModelFw:CommitData()
			EndIf

			oModelFw:DeActivate()
		Else

			cMsg := STR0063		//"Processo aceite de correspondente desprezado, não encontrou o Follou-up ou o Aceite já foi feito."
			ConOut( JurTimeStamp( 2 ) + ' ' + cMsg )
			lRet := .F.
		EndIf

		//Finaliza o processo
		oProcess:Finish()
	Endif

	RestArea( aAreaNTA )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106IncAn
Efetua a inclusao do andamento
Uso Follow-up

@param	nOpc	- Tipo de manutencao que o registro esta sofrend
@return	lRet	- Foi incluido corretamente o andamento

@author Rafael Tenorio da Costa
@since 06/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106IncAn( nOpc, oModel )
Local lRet       := .T.
Local cDescAndto := ""
Local nFlxCorres := SuperGetMV("MV_JFLXCOR", , 1)		//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
Local dData      := CtoD("")
Local cDescAto   := ""
Local cAto       := ""
Local oModelJ100 := Nil
Local lWSTLegal  := JModRst()

	//Inclusao ou Fluxo de correspondente por Assunto Jurídico
	If nOpc == 3 .Or. nFlxCorres == 2

		If !Empty(FwFldGet( 'NTA_CATO' ))

			If JurGetDados("NRO",1,xFilial("NR0") + FwFldGet( 'NTA_CATO' ), "NRO_PRFIXO") == '1'
				dData := FwFldGet( 'NTA_DTPREV' )
			EndIf

			JA106SETXV( { FwFldGet( 'NTA_DATO' ), FwFldGet( 'NTA_CATO' ), FwFldGet( 'NTA_DTFLWP' ), FwFldGet( 'NTA_HORA' ),;
				FwFldGet( 'NTA_DESC' ), FwFldGet( 'NTA_CAJURI' ), dData , FwFldGet( 'NTA_CFASE' ), FwFldGet( 'NTA_DFASE' )} )

		Else

			If JurGetDados("NRO",1,xFilial("NR0") + NQS->NQS_CSUGES, "NRO_PRFIXO") == '1'
				dData := FwFldGet( 'NTA_DTPREV' )
			EndIf

			JA106SETXV( { NQS->NQS_DESCRI, NQS->NQS_CSUGES, FwFldGet( 'NTA_DTFLWP' ), FwFldGet( 'NTA_HORA' ),;
				FwFldGet( 'NTA_DESC' ), FwFldGet( 'NTA_CAJURI' ), dData , FwFldGet( 'NTA_CFASE' ), FwFldGet( 'NTA_DFASE' )} )

		EndIf

	//Fluxo de correspondente por Follow-up
	Else

		//Carrega descricao do andamento
		cDescAndto := 	FwFldGet( 'NTA_DESC' ) + FwFldGet( 'NTA_CCORRE' ) +"\"+ FwFldGet( 'NTA_LCORRE' ) + "-" + ;
						AllTrim( FwFldGet( 'NTA_DCORRE' ) ) + " " + FwFldGet( 'NTA_CRESUL' ) + "-" + FwFldGet( 'NTA_DRESUL' )

		If !Empty(FwFldGet( 'NTA_CATO' ))

			If JurGetDados("NRO",1,xFilial("NR0") + FwFldGet( 'NTA_CATO' ), "NRO_PRFIXO") == '1'
				dData := FwFldGet( 'NTA_DTPREV' )
			EndIf

			JA106SETXV( {"", FwFldGet( 'NTA_CATO' ), FwFldGet( 'NTA_DTCON' ), "", cDescAndto, FwFldGet( 'NTA_CAJURI' ), dData , FwFldGet( 'NTA_CFASE' ), FwFldGet( 'NTA_DFASE' ) } )

		Else

			If JurGetDados("NRO",1,xFilial("NR0") + NQS->NQS_CSUGES, "NRO_PRFIXO") == '1'
				dData := FwFldGet( 'NTA_DTPREV' )
			EndIf

			JA106SETXV( {"", NQS->NQS_CSUGES, FwFldGet( 'NTA_DTCON' ), "", cDescAndto, FwFldGet( 'NTA_CAJURI' ), dData , FwFldGet( 'NTA_CFASE' ), FwFldGet( 'NTA_DFASE' ) } )

		EndIf

	EndIf

	//Seta valor de codigo de follow-up
	JA106SetCf( FwFldGet( 'NTA_COD' ) )

	//Seta valor de autorizacao de pagamento NT4_AUTPGO
	JA106SETAP( "1" )

	If EMPTY(oModel:GetValue("NTAMASTER","NTA_CATO"))
		cAto := NQS->NQS_CSUGES
	Else
		cAto := oModel:GetValue("NTAMASTER","NTA_CATO")
	EndIf

	//Pega a descrição do ato pelo fup
	cDescAto := Alltrim(JurGetDados("NRO",1,xFilial("NRO") + NTA->NTA_CATO, "NRO_DESC"))

	//Pega a descrição do tipo de FUP
	If EMPTY(cDescAto)
		cDescAto := Alltrim(JurGetDados("NRO",1,xFilial("NRO") + NQS->NQS_CSUGES, "NRO_DESC"))
	EndIf

	//Monta a descição do andamento
	If !(Empty(oModel:GetValue("NTAMASTER","NTA_DESC")))
		cDescAto := oModel:GetValue("NTAMASTER","NTA_DESC") + CRLF + cDescAto
	EndIf

	//Inclusão automática de andamento
	If NQS->NQS_TIPOGA == '1' // Valida se a inclusão de Andamentos será automatica.

		lRet := J106INCAUT(oModel:GetValue("NTAMASTER","NTA_CAJURI"), Date(), cDescAto,;
							oModel:GetValue("NTAMASTER","NTA_COD"), oModel:GetValue("NTAMASTER","NTA_FLAG01"),;
							cAto, oModel:GetValue("NTAMASTER","NTA_CFASE"))
	Else
		If !(lWSTLegal)
			oModelJ100 := FWLoadModel("JURA100")
			oModelJ100:SetOperation(MODEL_OPERATION_INSERT)
			oModelJ100:Activate()

			oModelJ100:SetValue("NT4MASTER","NT4_CATO",cAto)
			oModelJ100:SetValue("NT4MASTER","NT4_DESC",cDescAto)
			oModelJ100:LoadValue("NT4MASTER","NT4_CFWLP",NTA->NTA_COD)

			lRet := ( FWExecView(STR0003, "JURA100", 3, , {||.T.}, , , , , , , oModelJ100) == 0 )	//"Incluir"
		Else
			lRet := J100IUJson(,FwFldGet( 'NTA_COD' ))
		EndIf
	EndIf

	//Retorna ao default o valor de autorizacao de pagamento NT4_AUTPGO
	JA106SETAP()

	//Retorna ao default o valor de codigode follow-up
	JA106SetCf("")

	JA106CLEXV()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106NZ5
Retorna codigo e sigla dos participantes relacionados a tabela NZ5 no modelo do follow-up
Uso no cadastro de Follow-up.

@Param cFwPadrao   	- Código de modelo de follow-up
@Param cAssJur		- Código do assunto juridico
@Return aParticips	- Codigo e sigla dos participantes relacionados a tabela NZ5 no modelo do follow-up

@author Rafael Tenorio da Costa
@since 18/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA106NZ5(cFwPadrao, cAssJur)

Local aArea      := GetArea()
Local aAreaNZ5   := NZ5->( GetArea() )
Local aCampos    := {}
Local aCamposNZ5 := {}
Local cTabPartic := ""
Local cCodPartic := ""
Local cSigPartic := ""
Local cChave     := ""
Local aParticips := {}
Local aAux       := {}
Local nIndex     := 0
Local nCont      := 0

	DbSelectArea("NZ5")
	NZ5->( DbSetOrder(1) ) //NZ5_FILIAL+NZ5_CFOLWP+NZ5_CAMPO

	If NZ5->( DbSeek(xFilial("NZ5") + cFwPadrao) )

		//Carrega campo da NZ5
		While !NZ5->( Eof() ) .And. NZ5->NZ5_FILIAL == xFilial("NZ5") .And. NZ5->NZ5_CFOLWP == cFwPadrao
			Aadd(aCamposNZ5, NZ5->NZ5_CAMPO)
			NZ5->( DbSkip() )
		EndDo

		//Verifica se existe registros na NZ5
		If Len(aCamposNZ5) > 0

			//Carrega tabela do primeiro campo da NZ5
			cTabPartic := JurPrefTab( aCamposNZ5[1] )

			//Carrega codigo e siga de participante
			For nCont:=1 To Len(aCamposNZ5)

				//Verifica se a tabela eh a mesma do registro anterior
				If cTabPartic == JurPrefTab( aCamposNZ5[nCont] ) .And. nCont < Len(aCamposNZ5)

					//Carrega campos
					Aadd(aCampos, aCamposNZ5[nCont] )
				Else

					//Carrega ultimo campo
					If nCont == Len(aCamposNZ5)
						Aadd(aCampos, aCamposNZ5[nCont] )
					EndIf

					nIndex := 0
					aAux   := {}

					If cTabPartic == "NSZ"
						nIndex := 1 //NSZ_FILIAL+NSZ_COD
						cChave := xFilial(cTabPartic) + cAssJur
					ElseIf cTabPartic == "NUQ"
						nIndex := 2 //NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
						cChave := xFilial(cTabPartic) + cAssJur + "1"
					EndIf

					If nIndex > 0

						//Busca dados do participante
						aAux := JurGetDados(cTabPartic, nIndex, cChave, aCampos)

						//Se for apenas 1 campo retorno eh caracter
						If ValType(aAux) == "C"
							aAux := {aAux}
						EndIf

						//Carrega o codigo de participante e a sigla
						For nCont:=1 To Len(aAux)

							cCodPartic := aAux[nCont]

							If !Empty(cCodPartic) .And. ( Ascan(aParticips, { |x| x[1] == cCodPartic } ) <= 0 )
								cSigPartic := JurGetDados("RD0", 1, xFilial("RD0") + cCodPartic, "RD0_SIGLA")
								Aadd(aParticips, {cCodPartic, cSigPartic} )
							EndIf
						Next nCont
					EndIf

					//Carrega nova tabela
					cTabPartic == JurPrefTab( NZ5->NZ5_CAMPO )

					//Carrega campo da nova tabela
					aCampos := {}
					Aadd(aCampos, NZ5->NZ5_CAMPO )
				EndIf
			Next nCont
		EndIf
	EndIf

	RestArea(aAreaNZ5)
	RestArea(aArea)

Return aParticips

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcDtLiAc
Calcula a data de limite de aceite do correspondente.
Uso no cadastro de Follow-up.

@return dDtLiAcei - Data de limite de aceite do correspondente

@author Rafael Tenorio da Costa
@since 03/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcDtLiAc( oModel )

	Local nOpc		:= oModel:GetOperation()
	Local dDtIncAlt	:= IIF( nOpc == 3, FwFldGet("NTA_DTINC"), Date() )
	Local dDtLiAcei := dDtIncAlt + SuperGetMv("MV_JQTDIAC", .F., 5)						//Data limite para aceite de correspondente

	//-------------------------------------------------------------------------------------------------------------------------
	//Quando o a data de limite de aceite for maior igual a data do FUP, gravar como data limite a data de inclusão\alteracao
	//-------------------------------------------------------------------------------------------------------------------------
	If dDtLiAcei >= FwFldGet("NTA_DTFLWP")
		dDtLiAcei := dDtIncAlt
	EndIf

Return dDtLiAcei

//-------------------------------------------------------------------
/*/{Protheus.doc} BtnReenWfC
Botao para reenviar workflow de aceite de correspondente.
Uso no cadastro de Follow-up.

@author Rafael Tenorio da Costa
@since 22/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BtnReenWfC()

	Local lRetorno	:= .F.
	Local oModel	:= FWModelActive()

	If oModel:GetOperation() <> 3

		MsgRun(STR0094, STR0047, { || lRetorno := JA106WFECO(oModel, .F.) } ) //"Reenviando workflow de aceite de correspondente." # "Aguarde..."

		If lRetorno
			ApMsgInfo(STR0095)		//"Workflow de corresponde reenviado corretamente."
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J106HbDtPE()
Habilita campo de data do próximo evento quando tem ato com prazo fixo

@author Jorge Luis Branco Martins Junior
@since 07/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106HbDtPE()
	Local cAto   := ""
	Local lRet   := .F.

	cAto := M->NTA_CATO

	If Empty(AllTrim(cAto))
		cAto := JurGetDados("NQS", 1, xFilial("NQS") + M->NTA_CTIPO, "NQS_CSUGES")
	EndIf

	If !Empty(AllTrim(cAto)) .And. JurGetDados("NRO",1,xFilial("NR0")+cAto,"NRO_PRFIXO") == '1'
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J106UsrGra()
Retorna as siglas do usuário logado e dos membros de sua equipe caso
seja um líder para que nos gráficos sejam exibidos apenas dados
desses participantes.

@author Jorge Luis Branco Martins Junior
@since 07/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106UsrGra()
	Local aArea      := GetArea()
	Local cCodUsr    := RetCodUsr()
	Local aListParts := {}
	Local cQuery     := ""
	Local cConfigs	 := ""

	cQuery := "SELECT RD0.RD0_CODIGO "
	cQuery += "FROM " + RetSqlName("RD0") +" RD0 "
	cQuery += "WHERE RD0.RD0_FILIAL = '"+xFilial("NZ8")+"' "
	cQuery += "AND RD0.RD0_USER = '" + cCodUsr + "' "
	cQuery += "AND RD0.D_E_L_E_T_=' '"

	cConfigs := GetNextAlias()
	cQuery	 := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cConfigs, .T., .F.)

	While (cConfigs)->(!Eof())
		aAdd(aListParts, (cConfigs)->RD0_CODIGO)
		(cConfigs)->(dbSkip())
	End
	(cConfigs)->( dbcloseArea() )

	cQuery :=  "SELECT NZ9.NZ9_CPART "
	cQuery +=  "FROM " +RetSqlName("RD0")+ " RD0 INNER JOIN " +RetSqlName("NZ8")+ " NZ8 "
	cQuery +=	 "ON RD0.RD0_FILIAL = NZ8.NZ8_FILIAL AND "
	cQuery +=		"RD0.RD0_CODIGO = NZ8.NZ8_CPARTL "
	cQuery +=  "INNER JOIN " +RetSqlName("NZ9")+ " NZ9 "
	cQuery += 	 "ON NZ8.NZ8_FILIAL = NZ9.NZ9_FILIAL AND "
	cQuery += 		"NZ8.NZ8_COD = NZ9.NZ9_CEQUIP "
	cQuery +=  "WHERE RD0.RD0_FILIAL = '" +xFilial("RD0")+ "' AND "
	cQuery += 		 "RD0.RD0_USER = '" +cCodUsr+ "' AND "
	cQuery += 		 "RD0.D_E_L_E_T_=' ' AND "
	cQuery += 		 "NZ8.D_E_L_E_T_=' ' AND "
	cQuery += 		 "NZ9.D_E_L_E_T_=' '"

	cConfigs := GetNextAlias()
	cQuery	 := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cConfigs, .T., .F.)

	While (cConfigs)->(!Eof())
		aAdd(aListParts,(cConfigs)->NZ9_CPART)
		(cConfigs)->(dbSkip())
	End
	(cConfigs)->( dbcloseArea() )

	RestArea(aArea)

Return aListParts

//-------------------------------------------------------------------
/*/{Protheus.doc} J106VlDtPE()
Valida data do próximo evento para que não seja inferior a data
da follow-up (PAI)

@author Jorge Luis Branco Martins Junior
@since 14/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106VlDtPE()
	Local lRet := .T.

	If M->NTA_DTPREV < M->NTA_DTFLWP
		lRet := .F.
		JurMsgErro(STR0105)//'Data do próximo evento não pode ser inferior a data do follow-up'
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J106MailRe()
Envia email para responsáveis do follow-up indicando a recusa da tarefa

@author Jorge Luis Branco Martins Junior
@since 14/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106MailRe(oModelFw, cJustif)
	Local aArea      := GetArea()
	Local aCampos    := {}
	Local aMail      := {}
	Local nI         := 0
	Local cTipoAjuri := ""
	Local cCliente	 := ""
	Local cMsg       := ""
	Local cAssunto   := ""
	Local cCorpo     := ""
	Local cCorres    := ""
	Local cAssJur    := oModelFw:GetValue("NTAMASTER", "NTA_CAJURI")

	Local lRetorno

	//Assuntos Jurídicos
	DbSelectArea("NSZ")
	NSZ->( DbSetOrder( 1 ) )	//NSZ_FILIAL+NSZ_COD
	If NSZ->( DbSeek( xFilial("NSZ") + cAssJur) )
		cTipoAjuri := NSZ->NSZ_TIPOAS //Tipo do assunto jurídico
		cCliente   := NSZ->NSZ_CCLIEN + " \ " + NSZ->NSZ_LCLIEN + " - " + JurGetDados("SA1", 1, xFilial("SA1") + NSZ->NSZ_CCLIEN + NSZ->NSZ_LCLIEN, "A1_NOME") //Cliente, loja e nome
	EndIf

	If cTipoAjuri > '050'
		cTipoAjuri := JurGetDados('NYB', 1, xFilial('NYB') + cTipoAjuri, 'NYB_CORIG')
	EndIf

	//Criação de array com campos que serão indicados na descrição do follow-up no email. Campos serão diferentes conforme assunto jurídico
	Do Case

	Case cTipoAjuri $ "001|004|009" //Contencioso|Cade|Oficios

			//Instancia
		DbSelectArea("NUQ")
		NUQ->( DbSetOrder( 2 ) ) //NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
		If NUQ->( DbSeek( xFilial("NUQ") + cAssJur + "1" ) )
			Aadd(aCampos, {STR0072 , NUQ->NUQ_INSTAN } ) //"Instância"
			Aadd(aCampos, {STR0073 , NUQ->NUQ_NUMPRO } ) //"Processo"
			Aadd(aCampos, {STR0074 , JurGetDados("NQ1", 1, xFilial("NQ1") + NUQ->NUQ_CNATUR, "NQ1_DESC") } ) //"Natureza"
			Aadd(aCampos, {STR0075 , JurGetDados("NQ6", 1, xFilial("NQ6") + NUQ->NUQ_CCOMAR, "NQ6_DESC") } ) //"Comarca"
		EndIf

			//Envolvidos
		DbSelectArea("NT9")
		NT9->( DbSetOrder( 3 ) ) //NT9_FILIAL+NT9_CAJURI+NT9_TIPOEN+NT9_PRINCI
		If NT9->( DbSeek(xFilial("NT9") + cAssJur + "1" + "1" ) )
			Aadd(aCampos, {STR0076, NT9->NT9_NOME } ) //"Pólo Ativo"
		EndIf

		If NT9->( DbSeek(xFilial("NT9") + cAssJur + "2" + "1" ) )
			Aadd(aCampos, {STR0077, NT9->NT9_NOME } ) //"Pólo Passívo"
		EndIf

	Case cTipoAjuri == "006" //Contratos
		Aadd(aCampos, {STR0078, NSZ->NSZ_NUMCON } ) //"Número do Contrato"
	Case cTipoAjuri == "010" //Licitações
		Aadd(aCampos, {STR0079, NSZ->NSZ_NUMLIC } ) //"Número da Licitação"
	Case cTipoAjuri == "011" //Marcas e Patentes
		Aadd(aCampos, {STR0080	, NSZ->NSZ_NUMPED } ) //"Número do Pedido"
		Aadd(aCampos, {STR0081	, NSZ->NSZ_NOMEMA } ) //"Nome da Marca"
	EndCase

	//Descrição padrão do follow-up
	cDescFw := STR0109 + oModelFw:GetValue("NTAMASTER", "NTA_DESC") //'Descrição Follow-up: '
	cDescFw += CRLF
	cDescFw += STR0110 + DToC(oModelFw:GetValue("NTAMASTER", "NTA_DTFLWP")) //'Dt. Follow-up: '
	cDescFw += CRLF
	cDescFw += STR0111 + DToC(oModelFw:GetValue("NTAMASTER", "NTA_DTLIMT")) //'Dt. Limite: '
	cDescFw += CRLF
	cDescFw += STR0112 + JurGetDados("NQS", 1, xFilial("NQS") + oModelFw:GetValue("NTAMASTER", "NTA_CTIPO"), "NQS_DESC") //'Tipo Follow-up: '
	cDescFw += CRLF
	cDescFw += STR0113 + JurGetDados('NQN', 1 , xFilial('NQN') + oModelFw:GetValue("NTAMASTER","NTA_CRESUL"), 'NQN_DESC') //'Resultado Follow-up: '
	cDescFw += CRLF
	cDescFw += STR0114 + cCliente //'Cliente: '
	cDescFw += CRLF

	//Descrição do follow-up por tipo de assunto jurídico
	If Len(aCampos) > 0
		For nI := 1 to Len(aCampos)
			cDescFw += aCampos[nI][1] + ": " + aCampos[nI][2]
			cDescFw += CRLF
		Next
	EndIf

	DbSelectArea("NTE")
	NTE->(DbSetOrder(2))//NTE_FILIAL, NTE_CFOLWP
	NTE->(dbSeek(xFilial("NTE")+Alltrim(oModelFw:GetValue("NTAMASTER", "NTA_COD"))))

	//Montagem do array com nome e email dos participantes responsáveis pelo follow-up
	While NTE->(!Eof()) .AND. Alltrim(NTE->NTE_CFLWP) == Alltrim(oModelFw:GetValue("NTAMASTER", "NTA_COD"))
		DbSelectArea("RD0")
		RD0->(DbSetOrder(1))//RD0_FILIAL, RD0_COD
		If RD0->(DbSeek(xFilial("RD0")+NTE->NTE_CPART))
			If !Empty(Alltrim(RD0->RD0_EMAIL))
				aAdd(aMail, {RD0->RD0_EMAIL, RD0->RD0_NOME})
			EndIf
		EndIf
		NTE->(DbSkip())
	End

	//Nome do Correspondente
	cCorres := JurGetDados("SA2", 1, xFilial("SA2") + oModelFw:GetValue("NTAMASTER", "NTA_CCORRE") + oModelFw:GetValue("NTAMASTER", "NTA_LCORRE"), "A2_NOME")

	For nI := 1 To Len(aMail)
		//Carrega mensagem
		cMsg := ""
		cMsg += STR0066 + aMail[nI][2] + CRLF //"Sr.(a) "
		cMsg += CRLF
		cMsg += I18N( STR0106, {cCorres}) + CRLF //'Enviamos este e-mail para informar que o correspondente '+cCorres+' recusou o seguinte follow-up:'
		cMsg += CRLF
		cMsg += cDescFw + CRLF
		cMsg += CRLF
		cMsg += STR0107 + CRLF //"Justificativa informada pelo correspondente:"
		cMsg += CRLF
		cMsg += '"'+ cJustif + '"' + CRLF + CRLF
		cMsg += CRLF
		cMsg += STR0108 + CRLF // 'Mensagem automática, favor não responder este e-mail.'
		cMsg += CRLF
		cMsg += STR0068 + CRLF //"Atenciosamente, "
		cMsg += CRLF
		cMsg += STR0069 + CRLF //"Workflow Totvs Protheus"
		cMsg += CRLF

		cAssunto := STR0115 //'Recusa do Correspondente'

		//Gera corpo do e-mail
		cCorpo := '<html>'
		cCorpo += '<div><span class=610203920-12022004><font face=Verdana color=#ff0000 '
		cCorpo += 'size=2><strong> ' + STR0069 + ' </strong></font></span></div><hr>' //"Workflow Totvs Protheus"
		cCorpo += '<div><font face=verdana color=#000080 size=3><span class=216593018-10022004>' + cMsg + '</span></font></div><p>'
		cCorpo += '</html>'

		lRetorno := JurEnvMail( /*cDe*/, aMail[nI][1], /*cCc*/, /*cCCO*/, cAssunto, /*cAnexo*/, cCorpo, /*cServer*/, /*cEmail*/, /*cPass*/, /*lAuth*/, /*cContAuth*/, /*cPswAuth*/)
	Next

	RestArea( aArea )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja106NszCor
Retorna os codigo de assuntos juridicos que o correspondente tem follow-up
Uso geral.

@param 	cCodCor 	- Codigo do correspondente
@param 	cLojCor 	- Loja do correspondente
@param 	cWhere 		- Mais alguma restricao que queira colocar no select da NTA
@return aCodsNsz	- Codigos da Nsz que o correspondente tem follow-up
@author Rafael Tenorio da Costa
@since 15/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja106NszCor(cCodCor, cLojCor, cWhere)

	Local aArea	 	:= GetArea()
	Local aCodsNsz	:= {}
	Local cQuery 	:= ""
	Local cTabela	:= GetNextAlias()

	Default	cWhere	:= ""

	cQuery := " SELECT DISTINCT NTA_CAJURI " + CRLF
	cQuery += " FROM " + RetSqlName("NTA") + CRLF
	cQuery += " WHERE NTA_CCORRE = '" +cCodCor+ "' " + CRLF
	cQuery += 	" AND NTA_LCORRE = '" +cLojCor+ "' " + CRLF

	If !Empty(cWhere)
		cQuery += " AND " + AllTrim(cWhere) + CRLF
	EndIf

	cQuery += 	" AND D_E_L_E_T_ = ' ' " + CRLF

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cTabela, .F., .T.)

	While !(cTabela)->( Eof() )

		Aadd(aCodsNsz, (cTabela)->NTA_CAJURI)
		(cTabela)->( DbSkip() )
	EndDo
	(cTabela)->( DbCloseArea() )

	RestArea( aArea )

Return aCodsNsz


//-------------------------------------------------------------------
/*/{Protheus.doc} J106RPCOR
Faz as alterações no modelo, durante o tudoOk de acordo com a resposta do
correspondente.
Uso Follow-up.

@param	oModel 		- Model do NTA
@param	lReenvio	- Defini se é reenvio de workflow
@param	cErro		- Mensagem de erro

@author André Spirigoni Pinto
@since 21/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106RPCOR(oModel)
	Local lRet       := .T.
	Local cNome      := ""
	Local cEmail     := ""
	Local cAceite    := oModel:GetValue("NTAMASTER", "NTA_ACEITO")
	Local cCodCorres := oModel:GetValue("NTAMASTER", "NTA_CCORRE")
	Local cLojCorres := oModel:GetValue("NTAMASTER", "NTA_LCORRE")
	Local cCodAdvoga := oModel:GetValue("NTAMASTER", "NTA_CADVCR")
	Local cJustifica := oModel:GetValue("NTAMASTER", "NTA_JUSTIF")
	Local aCmpsCorre := GetAdvFVal("SA2", {"A2_NOME", "A2_EMAIL"}, xFilial("SA2") + cCodCorres + cLojCorres, 1)
	Local aCmpsAdvog := GetAdvFVal("SU5", {"U5_CONTAT", "U5_EMAIL"}, xFilial("SU5") + cCodAdvoga, 1)

//Pega informacoes do destinatario
	If !Empty(cCodAdvoga)
		cNome  := aCmpsAdvog[1]
		cEmail := aCmpsAdvog[2]
	Else
		cNome  := aCmpsCorre[1]
		cEmail := aCmpsCorre[2]
	EndIf

//Tratamento da justificativa no envio de emails de correspondentes

//Envio de email quando o workflow é rejeitado
	If cAceite == "2"
//Se não for aceito limpa campos
	//Envia email para responsáveis do follow-up indicando a recusa da tarefa
		J106MailRe(oModel, Alltrim( oModel:GetValue("NTAMASTER", "NTA_JUSTIF") ))

		oModel:LoadValue("NTAMASTER", "NTA_CCORRE" , "")
		oModel:LoadValue("NTAMASTER", "NTA_LCORRE" , "")
		oModel:LoadValue("NTAMASTER", "NTA_CADVCR" , "")
		oModel:LoadValue("NTAMASTER", "NTA_DTLIAC" , CtoD(""))
		If Empty(cJustifica)
			JurMsgErro(STR0012+RetTitle("NTA_JUSTIF"))
			lRet := .F.
		EndIf
	Endif


If lRet
	//Incremento da justificativa
	SET DATE FORMAT "dd/mm/yyyy"
	cJustifica	:= DtoC( dDataBase ) + " - " + Time() + " - " + STR0082 + ": " + cEmail + " - " +;		//"Recebido"
				   STR0083 + ": " + IIF(cAceite == "1", STR0084, STR0085) + " - " + CRLF + cJustifica			//"Aceite"		//"Sim"		//"Não"


	//Atualiza o campo de justificativa.
	oModel:LoadValue("NTAMASTER", "NTA_JUSTIF", cJustifica)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J106INCAUT(NTA_CAJURI, DTOC(NTA_DTFLWP), cDescAto, NTA_COD, NTA_FLAG01, cAto)
Gera Andamnto automatico.
Uso Follow-up.

@param cCajuri   Código do assunto jurídico
@param dDataAnd  Data do Andamento
@param cDescAto  Descrição do Ato processual
@param cCodFlw   Código do Follow-up
@param cEmail    E-mail
@param cAto      Código do Ato Processual
@param cFase     Código da Fase Processual

@author Wellington Coelho
@since 16/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106INCAUT(cCajuri, dDataAnd, cDescAto, cCodFlw, cEmail, cAto, cFase)

	Local oModelAnd  := FWLoadModel( "JURA100" )
	Local lRet       := .T.
	Local oModelAtl  := FWModelActive()

	oModelAnd:SetOperation( 3 )
	oModelAnd:Activate()

	oModelAnd:SetValue("NT4MASTER", "NT4_CAJURI" , cCajuri)
	oModelAnd:SetValue("NT4MASTER", "NT4_DTANDA" , dDataAnd)
	oModelAnd:SetValue("NT4MASTER", "NT4_CATO"   , cAto)
	oModelAnd:LoadValue("NT4MASTER", "NT4_CFWLP" , cCodFlw)
	oModelAnd:SetValue("NT4MASTER", "NT4_FLAG01" , cEmail)
	
	If !Empty(cFase)
		oModelAnd:SetValue("NT4MASTER", "NT4_CFASE"  , cFase)
	EndIF

	If Empty(cDescAto)
		cDescAto := oModelAnd:GetValue("NT4MASTER", "NT4_DESC")
	EndIf

	oModelAnd:SetValue("NT4MASTER", "NT4_DESC"   , cDescAto + ' - ' + DTOC(dDataAnd))

	If ( lRet := oModelAnd:VldData() )
		lRet := oModelAnd:CommitData()
	EndIf

	If !lRet
		JurMsgErro()
	EndIf

	oModelAnd:DeActivate()
	oModelAnd:Destroy()

	If oModelAtl <> Nil
		FwModelActive(oModelAtl, .T.)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106GCard
Cancela o WorkFlow no Fluig do processo do follow-up
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 29/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106GCard(cIdFluigWF,cCampo)
Local aArea       := GetArea()
Local cSolicitId  := ''
Local cMensagem   := ''
Local cUsuario    := SuperGetMV('MV_ECMUSER',,'')
Local cSenha      := SuperGetMV('MV_ECMPSW',,'')
Local cEmpresa    := SuperGetMV('MV_ECMEMP',,'0')
Local xRet        := ''
Local cRet        := ''
Local aValores    := {}
Local aCardData   := {}
Local aSubs       := {}
Local cTag        := ''
Local oXml := Nil
Local cErro := ""
Local cAviso := ""
Local nC

Begin Sequence

//Solicitante
cSolicitId := JColId(cUsuario,cSenha,cEmpresa,cUsuario)

If  Empty( cSolicitId )
	cMensagem := STR0120  //"Problema para obter id do solicitante!"
	Conout("JA106GCard:" + STR0120)
	Break
EndIf

aadd(aValores, {"username"         , cUsuario   })
aadd(aValores, {"password"         , JurEncUTF8(cSenha)})
aadd(aValores, {"companyId"        , cEmpresa   })
aadd(aValores, {"processInstanceId", cIdFluigWF })
aadd(aValores, {"userId"           , cSolicitId })
aadd(aValores, {"cardFieldName"    , cCampo    })

  //Retirado o elemento da tag devido o obj nao suportar
aadd( aSubs, {'"', "'"})
aadd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
aadd( aSubs, {"<item />", ""})

If  !( JA106TWSDL("ECMWorkflowEngineService", "getCardValue", aValores, aCardData, aSubs, @xRet, @cMensagem) )
	Break
EndIf

//Obtem somente a Tag do XML de retorno
cTag := '</content>'
nC   := At(StrTran(cTag,"/",""),xRet)
xRet := SubStr(xRet, nC, Len(xRet))
nC   := At(cTag,xRet) + Len(cTag) - 1
xRet := Left(xRet, nC)

//Gera o objeto do Result Tag
oXml := XmlParser( xRet, "_", @cErro, @cAviso )

If  Empty(oXml) .And. !Empty(cMensagem)
	cMensagem := JMsgErrFlg(oXML)
	Break
EndIf

//Verifica se esta concluido ou nao.
if oXml != nil .And. !Empty(oXml) .And. Empty(cMensagem)
	cRet := oXml:_content:TEXT
Endif

End Sequence

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J106WFReag
Gera WorkFlow no Fluig do processo do follow-up
Uso no cadastro de Follow-ups.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 17/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J106WFReag(cIdWF, dtNew, cHora)
Local aArea      := GetArea()
Local nC         := 0
Local cSolicitId := ''
Local cUsuario   := SuperGetMV('MV_ECMUSER',,'')
Local cSenha     := SuperGetMV('MV_ECMPSW',,'')
Local cEmpresa   := SuperGetMV('MV_ECMEMP',,'0')
Local cMensagem  := ''
Local aValores   := {}
Local aCardData  := {}
Local aSubs      := {}
Local xRet       := ''
Local oXml       := nil
Local cErro      := ''
Local cAviso     := ''
Local cTag       := ''
Local cTime      := ""
Local lRet       := .F.

	if len(Alltrim(cHora))==4
		cTime := Alltrim(str((val(LEFT(Alltrim(cHora),2)) * 3600) +  (val(RIGHT(AllTrim(cHora),2))*60)))
	Else
		cTime := "32400"
	Endif

	Begin Sequence

   	//Executor
   	cSolicitId := JA106GCard(cIdWF,"sExecutorFluig")

	If  Empty( cSolicitId )
		cMensagem := STR0120  //"Problema para obter id do solicitante!"
		Break
	EndIf

	aadd(aValores, {"username"          , cUsuario   })
	aadd(aValores, {"password"          , JurEncUTF8(cSenha)})
	aadd(aValores, {"companyId"         , cEmpresa   })
	aadd(aValores, {"processInstanceId" , cIdWF      })
	aadd(aValores, {"threadSequence"    , "0"        })
	aadd(aValores, {"userId"            , cSolicitId })
	aadd(aValores, {"newDueDate"        , Year2Str(dtNew) + "-" + Month2Str(dtNew) + "-" + Day2Str(dtNew)})
	aadd(aValores, {"timeInSecods"      , cTime })

  //Retirado o elemento da tag devido o obj nao suportar
	aadd( aSubs, {'"', "'"})
	aadd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
	aadd( aSubs, {"<item />", ""})

	If  !( JA106TWSDL("ECMWorkflowEngineService", "setDueDate", aValores, aCardData, aSubs, @xRet, @cMensagem) )
		Break
	EndIf

  //Obtem somente a Tag do XML de retorno
	cTag := '</result>'
	nC   := At(StrTran(cTag,"/",""),xRet)
	xRet := SubStr(xRet, nC, Len(xRet))
	nC   := At(cTag,xRet) + Len(cTag) - 1
	xRet := Left(xRet, nC)

  //Gera o objeto do Result Tag
	oXml := XmlParser( xRet, "_", @cErro, @cAviso )

	If  Empty(oXml) .Or. (ValType(oXml:_Result) != 'O')
		cMensagem := JMsgErrFlg(oXML)
		Break
	EndIf

  //Obtem o codigo do WorkFlow gerado no Fluig
	lRet := (At("sucesso",lower(oXml:_Result:TEXT)) > 0)

End Sequence

If  !( Empty(cMensagem) )
	ConOut('J106WFReag: ' + STR0122 + cMensagem) //"Erro: "
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J106DtVal
Retorna uma Data Válida
Uso no cadastro de Follow-ups.

@param 	dData

@Return dDataVal 	Retorna uma data válida de acordo com o parâmetro MV_JBLQFER -> Impede a criação de follow-up aos finais de semana e feriados? 1-Sim; 2- Não

@author Marcelo Araujo Dente
@since 24/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106DtVal(dData)
Local dDataVal := dData

If ValType(dData) == 'D' .And. SuperGetMV('MV_JBLQFER',, '2') == '1'
		dDataVal:= DataValida(dData)
EndIf

Return dDataVal

//-------------------------------------------------------------------
/*/{Protheus.doc} J106MetFup()
Envia métricas para o License server referente a uso de envio de email
de prazos e tarefas (Fups)

@return .T.
/*/
//-------------------------------------------------------------------
Function J106MetFup()

Local lEnvEmail := J106QryMtr()  // Valida se possui config de envio de email de Fups

	If !lEnvEmail
		J106SetMet("false")
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J106QryMtr()
Valida se há configuração de envio de e-mail de prazos e tarefas (Fups)

@return lEnvEmail - boolean
              .T. - Possui configuração
              .F. - Não possui configuração
/*/
//-------------------------------------------------------------------
Function J106QryMtr()

Local aArea     := GetArea()
Local cAlias    := ""
Local cQuery    := ""
Local lNSX      := FWAliasInDic("NSX") .AND. Findfunction('TCObject') .AND. TCObject( RetSqlName("NSX") )
Local lEnvEmail := .T.

	If lNSX
		cQuery := " SELECT COUNT(NSX_COD) TOTAL_CONFIG "
		cQuery += " FROM " + RetSqlName("NSX") + " NSX "
		cQuery += " WHERE NSX.NSX_FILIAL = '" + xFilial("NSX") + "' "
		cQuery +=       " AND NSX.NSX_TABFLG = 'NTA' "
		cQuery +=       " AND NSX.D_E_L_E_T_ = ' '  "

		cAlias := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		If !(cAlias)->(EOF())
			lEnvEmail := (cAlias)->TOTAL_CONFIG > 0
		EndIf

		(cAlias)->(DbCloseArea())
	EndIf

	RestArea( aArea )

Return lEnvEmail

//-------------------------------------------------------------------
/*/{Protheus.doc} J106SetMet()
Seta as métrica de uso de envio de e-mail de prazos e tarefas (FUPs)
para o License server

@param cStatus - string - "true" / "false

@return .T.
/*/
//-------------------------------------------------------------------
Function J106SetMet(cStatus)

Local cSubRot   := 'email_fups_'
Local cIdMetric := 'sigajuri-protheus_uso-rotina-envio-de-email-de-prazos-e-tarefas_count'

Default cStatus := "false"

	cSubRot := cSubRot + cStatus

	JurMetric('unique', cSubRot, cIdMetric, '1' /*xValue*/ , /*dDateSend*/, /*nLapTime*/, 'JURA091')

Return .T.
