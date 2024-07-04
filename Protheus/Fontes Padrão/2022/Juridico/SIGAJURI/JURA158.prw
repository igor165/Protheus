#INCLUDE "JURA158.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"

#DEFINE TABSCONFIG "O05"	//Tabelas que podem ser configuradas na aba de tabelas 
Static _cChavSX2    := "" //variável criada para compor o retorno do F3 da consulta de tabelas na configuração de pesquisas


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA158
Inclusão de tipos de assuntos jurídicos

@author André Spirigoni Pinto
@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA158()

Local oBrowse
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('NYB')
oBrowse:SetDescription(STR0008)//"Cadastro de Tipos de Assunto Jurídico"

JurSetBSize( oBrowse )

oBrowse:Activate()
	
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

@author André Spirigoni Pinto
@since 18/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA158", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA158", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA158", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA158", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0007, "JA158CLOTE"     , 0, 3, 0, NIL } ) // "Campos em Lote"
aAdd( aRotina, { STR0073, "J163AjuNVH"     , 0, 3, 0, NIL } ) // "Atualizar Nome Tabela"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Time Sheets dos Profissionais

@author André Spirigoni Pinto
@since 19/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := ModelDef()
Local oStructNYB := FWFormStruct( 2, "NYB" )
Local oStructNYC := FWFormStruct( 2, 'NYC' )
Local oStructNVJ := FWFormStruct( 2, 'NVJ' )
Local oStructNUZ := FWFormStruct( 2, 'NUZ' )
Local oStructNYD := FWFormStruct( 2, 'NYD' )
Local oStructNZ6 := FWFormStruct( 2, 'NZ6' )
Local oStructNZN
Local lNZNInDic  := FWAliasInDic("NZN")

If lNZNInDic
	oStructNZN := FWFormStruct( 2, 'NZN' )
	oStructNZN:RemoveField( "NZN_TIPOAS" )
EndIf

oStructNYC:RemoveField( "NYC_CTPASJ" )
oStructNVJ:RemoveField( "NVJ_CASJUR" )
oStructNVJ:RemoveField( "NVJ_DASJUR" )
oStructNUZ:RemoveField( "NUZ_CTAJUR" )
oStructNUZ:RemoveField( "NUZ_DTAJUR" )
oStructNYD:RemoveField( "NYD_CTPASJ" )
oStructNZ6:RemoveField( "NZ6_TIPOAS" )

JurSetAgrp( 'NYB',, oStructNYB )
JurLoadAsJ()

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA158_NYB",oStructNYB ,"NYBMASTER" )
oView:AddGrid( "JURA158_NYC", oStructNYC, "NYCDETAIL" )
oView:AddGrid( "JURA158_NVJ", oStructNVJ, "NVJDETAIL" )
oView:AddGrid( "JURA158_NUZ", oStructNUZ, "NUZDETAIL" )
oView:AddGrid( "JURA158_NYD", oStructNYD, "NYDDETAIL" )
oView:AddGrid( "JURA158_NZ6", oStructNZ6, "NZ6DETAIL" )

oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

oView:CreateFolder("FOLDER_01","INFERIOR")
oView:AddSheet("FOLDER_01", "ABA_NYC", STR0009 )//"Guias"
oView:AddSheet("FOLDER_01", "ABA_NVJ", STR0010 )//"Pesquisas"
oView:AddSheet("FOLDER_01", "ABA_NUZ", STR0011 )//"Campos"
oView:AddSheet("FOLDER_01", "ABA_NYD", STR0012 )//"Exceção Campos"
oView:AddSheet("FOLDER_01", "ABA_NZ6", STR0077 )//"Parâmetros"

oView:CreateHorizontalBox("FORMFOLDERNYC",100,,,'FOLDER_01',"ABA_NYC")
oView:CreateHorizontalBox("FORMFOLDERNVJ",100,,,'FOLDER_01',"ABA_NVJ")
oView:CreateHorizontalBox("FORMFOLDERNUZ",100,,,'FOLDER_01',"ABA_NUZ")
oView:CreateHorizontalBox("FORMFOLDERNYD",100,,,'FOLDER_01',"ABA_NYD")
oView:CreateHorizontalBox("FORMFOLDERNZ6",100,,,'FOLDER_01',"ABA_NZ6")

oView:SetOwnerView( "JURA158_NYB", "SUPERIOR" )
oView:SetOwnerView( "JURA158_NYC", "FORMFOLDERNYC" )
oView:SetOwnerView( "JURA158_NVJ", "FORMFOLDERNVJ" )
oView:SetOwnerView( "JURA158_NUZ", "FORMFOLDERNUZ" )
oView:SetOwnerView( "JURA158_NYD", "FORMFOLDERNYD" )
oView:SetOwnerView( "JURA158_NZ6", "FORMFOLDERNZ6" )

If lNZNInDic
	oView:AddGrid( "JURA158_NZN", oStructNZN, "NZNDETAIL" )
	oView:AddSheet("FOLDER_01", "ABA_NZN", STR0081 )//"Relatórios"
	oView:CreateHorizontalBox("FORMFOLDERNZN",100,,,'FOLDER_01',"ABA_NZN")
	oView:SetOwnerView( "JURA158_NZN", "FORMFOLDERNZN" )
EndIf

oView:SetDescription( STR0013 ) // "Tipos de Assuntos Jurídicos"
oView:EnableControlBar( .T. )

oView:AddUserButton( STR0014,"CLIPS", { | oView | JA158TITC() } )//"Inclui Títulos"

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Operações Lote Levantamento

@author André Spirigoni Pinto
@since 18/07/13
@version 1.0


/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNYB    := FWFormStruct( 1, "NYB" )
Local oStructNYC    := FWFormStruct( 1, "NYC" )
Local oStructNVJ    := FWFormStruct( 1, "NVJ" )
Local oStructNUZ    := FWFormStruct( 1, "NUZ" )
Local oStructNYD    := FWFormStruct( 1, "NYD" )
Local oStructNZ6    := FWFormStruct( 1, "NZ6" )
Local oStructNZN
Local lNZNInDic     := FWAliasInDic("NZN")

If lNZNInDic
	oStructNZN    := FWFormStruct( 1, "NZN" )
	oStructNZN:RemoveField( "NZN_TIPOAS" )
EndIf

oStructNYC:RemoveField( "NYC_CTPASJ" )
oStructNVJ:RemoveField( "NVJ_CASJUR" )
oStructNVJ:RemoveField( "NVJ_DASJUR" )
oStructNUZ:RemoveField( "NUZ_CTAJUR" )
oStructNUZ:RemoveField( "NUZ_DTAJUR" )
oStructNYD:RemoveField( "NYD_CTPASJ" )
oStructNZ6:RemoveField( "NZ6_TIPOAS" )

//Alguns parâmetros não teram preenchimento obrigatório
oStructNZ6:SetProperty("NZ6_CONTEU", MODEL_FIELD_OBRIGAT, .F.) 

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA158", /*Pre-Validacao*/, /*Pos-Validacao*/ {|oModel| JA158TOK(oModel)}, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NYBMASTER", NIL, oStructNYB,/*Pre-Validacao*/,/*Pos-Validacao*/ )

oModel:AddGrid( "NYCDETAIL", "NYBMASTER" /*cOwner*/, oStructNYC, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( "NVJDETAIL", "NYBMASTER" /*cOwner*/, oStructNVJ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( "NUZDETAIL", "NYBMASTER" /*cOwner*/, oStructNUZ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( "NYDDETAIL", "NYBMASTER" /*cOwner*/, oStructNYD, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( "NZ6DETAIL", "NYBMASTER" /*cOwner*/, oStructNZ6, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:GetModel( "NYCDETAIL" ):SetUniqueLine( {"NYC_TABELA"} )
oModel:GetModel( "NVJDETAIL" ):SetUniqueLine( {"NVJ_PESQUI"} )
oModel:GetModel( "NUZDETAIL" ):SetUniqueLine( {"NUZ_CAMPO"} )
oModel:GetModel( "NYDDETAIL" ):SetUniqueLine( {"NYD_CAMPO"} )
oModel:GetModel( "NZ6DETAIL" ):SetUniqueLine( {"NZ6_CPARAM"} )

oModel:SetRelation( "NYCDETAIL", { { "NYC_FILIAL", "XFILIAL('NYC')" }, { "NYC_CTPASJ", "NYB_COD" } }, NYC->( IndexKey( 1 ) ) )
oModel:SetRelation( "NVJDETAIL", { { "NVJ_FILIAL", "XFILIAL('NVJ')" }, { "NVJ_CASJUR", "NYB_COD" } }, NVJ->( IndexKey( 1 ) ) )
oModel:SetRelation( "NUZDETAIL", { { "NUZ_FILIAL", "XFILIAL('NUZ')" }, { "NUZ_CTAJUR", "NYB_COD" } }, NUZ->( IndexKey( 1 ) ) )
oModel:SetRelation( "NYDDETAIL", { { "NYD_FILIAL", "XFILIAL('NYD')" }, { "NYD_CTPASJ", "NYB_COD" } }, NYD->( IndexKey( 1 ) ) )
oModel:SetRelation( "NZ6DETAIL", { { "NZ6_FILIAL", "XFILIAL('NZ6')" }, { "NZ6_TIPOAS", "NYB_COD" } }, NZ6->( IndexKey( 1 ) ) )	

oModel:SetDescription( STR0015 ) // "Modelo de dados dos tipos de assunto Jurídico"
oModel:GetModel( "NYBMASTER" ):SetDescription( STR0016 ) //"Dados de tipos de assunto jurídico"
oModel:GetModel( "NYCDETAIL" ):SetDescription( STR0017 ) //"Guias Vinculadas"
oModel:GetModel( "NVJDETAIL" ):SetDescription( STR0018 ) //"Pesquisas Vinculadas"
oModel:GetModel( "NUZDETAIL" ):SetDescription( STR0019 ) //"Campos vinculados"
oModel:GetModel( "NYDDETAIL" ):SetDescription( STR0020 ) //"Exceções Campos"
oModel:GetModel( "NZ6DETAIL" ):SetDescription( STR0077 ) //"Parâmetros"

oModel:SetOptional( "NYCDETAIL" , .T. )
oModel:SetOptional( "NVJDETAIL" , .T. )
oModel:SetOptional( "NUZDETAIL" , .T. )
oModel:SetOptional( "NYDDETAIL" , .T. )    
oModel:SetOptional( "NZ6DETAIL" , .T. )

JurSetRules( oModel, "NYBMASTER",, "NYB",,  )
JurSetRules( oModel, "NYCDETAIL",, "NYC",,  )
JurSetRules( oModel, "NVJDETAIL",, "NVJ",,  )
JurSetRules( oModel, "NUZDETAIL",, "NUZ",,  )
JurSetRules( oModel, "NYDDETAIL",, "NYD",,  )
JurSetRules( oModel, "NZ6DETAIL",, "NZ6",,  )

If lNZNInDic
	oModel:AddGrid( "NZNDETAIL", "NYBMASTER" /*cOwner*/, oStructNZN, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NZNDETAIL" ):SetUniqueLine( {"NZN_CFGREL","NZN_CAMPO"} )
	oModel:SetRelation( "NZNDETAIL", { { "NZN_FILIAL", "XFILIAL('NZN')" }, { "NZN_TIPOAS", "NYB_COD" } }, NZN->( IndexKey( 1 ) ) )
	oModel:GetModel( "NZNDETAIL" ):SetDescription( STR0081 ) //"Relatórios"
	oModel:SetOptional( "NZNDETAIL" , .T. )
	JurSetRules( oModel, "NZNDETAIL",, "NZN",,  )
EndIf

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} JA158TOK()
Valida informações ao salvar.
Uso na configuração de pesquisa

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158TOK(oModel)
Local aArea     := GetArea()
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local oModelNYB := oModel:GetModel('NYBMASTER')

If nOpc == OP_INCLUIR

	If lRet .And. oModelNYB:GetValue("NYB_COD") <= "050"
		lRet := .F.
		JurMsgErro(STR0021 + oModelNYB:GetValue("NYBMASTER", "NYB_COD") + STR0022)//"Código: "  + " não pode ser usado. Utilize códigos acima de 050"
	EndIf

	If lRet .And. oModelNYB:GetValue("NYB_COD") > "050" .And. Empty(Alltrim(oModelNYB:GetValue("NYB_CORIG")))
		lRet := .F.
		JurMsgErro(STR0023)//"Preencha o código do Assunto Jurídico de origem"
	EndIf

	If lRet
		lRet := JA158NYCOK(oModel, nOpc)
	EndIf
	
	If lRet
		lRet := JA158NUZOK(oModel, nOpc)
	EndIf
	
	If lRet
		lRet := JA158NYDOK(oModel, nOpc)
	EndIf

ElseIf nOpc == OP_ALTERAR
	
	If lRet .And. oModelNYB:GetValue("NYB_COD") <= "050" .And. !Empty(Alltrim(oModelNYB:GetValue("NYB_CORIG")))
		lRet := .F.
		JurMsgErro(STR0025) //"Não é permitido alterar assuntos juridicos padrão."
	EndIf
	
	If lRet .And. oModelNYB:GetValue("NYB_COD") > "050" .And. Empty(Alltrim(oModelNYB:GetValue("NYB_CORIG")))
		lRet := .F.
		JurMsgErro(STR0026) //"Não é permitido que este assunto não tenha uma origem."
	EndIf
	
	If lRet
		lRet := JA158NYCOK(oModel, nOpc)
	EndIf
	
	If lRet
		lRet := JA158NUZOK(oModel, nOpc)
	EndIf
	
	If lRet
		lRet := JA158NYDOK(oModel, nOpc)
	EndIf
	
ElseIf nOpc == OP_EXCLUIR

	If lRet .And. oModelNYB:GetValue("NYB_COD") <= "050"
		lRet := .F.
		JurMsgErro(STR0027)//"Não é permitido excluir assuntos juridicos padrão."
	EndIf	

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158LDP()
Verifica se os tipos de assuntos padrão estão cadastrados.

@author André Spirigoni Pinto
@since 23/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158LDP()
Local lRet      := .T.
Local oModel    := FWModelActive()
Local nOpc      := oModel:GetOperation()
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local lLinha    := .F.
Local lZero     := .F.
Local nI        := 0

If nOpc == 3 .And. !Empty(FWFLDGET('NYB_CORIG'))

	//-------------------------------------------------------------------------------------------
	//Carrega tabelas do tipo de assunto de origem para atualizar no filho   
	//-------------------------------------------------------------------------------------------
	cQuery := " SELECT NYC_TABELA "
	cQuery +=   " FROM " + RetSqlName("NYC") + " NYC "
	cQuery +=  " WHERE NYC.NYC_CTPASJ = '" + FWFLDGET('NYB_CORIG') + "' "
	cQuery +=    " AND NYC.NYC_FILIAL = '" + xFilial("NYC") + "' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T.)

	//Apaga as linhas que existem, caso a query do banco tenha resultado
	For nI := 1 To oModel:GetModel( "NYCDETAIL" ):Length()
		oModel:GetModel( "NYCDETAIL" ):GoLine( nI )
		If !oModel:GetModel( "NYCDETAIL" ):IsDeleted() .And. !Empty(oModel:GetModel( "NYCDETAIL" ):GetValue( "NYC_TABELA")) 
			oModel:GetModel( "NYCDETAIL" ):DeleteLine()
			lZero := .T.
		EndIf
	Next
	
	While !(cAliasQry)->( EOF())
		
		If lLinha .Or. lZero
			oModel:GetModel( "NYCDETAIL" ):AddLine()
			lLinha := .F.
		Endif
		
		If !oModel:GetModel( "NYCDETAIL" ):SetValue("NYC_TABELA", (cAliasQry)->NYC_TABELA)
			lRet := .F.
			JurMsgErro(STR0040)//"Tabela não permitida."
		Else
			lLinha := .T.
		EndIf
		
		(cAliasQry)->( dbSkip() )
		
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	//-------------------------------------------------------------------------------------------
	//Carrega parametros do tipo de assunto de origem para atualizar no filho   
	//-------------------------------------------------------------------------------------------
	cQuery := " SELECT NZ6_CPARAM, NZ6_TIPO, NZ6_CONTEU "
	cQuery += " FROM " + RetSqlName("NZ6") + " NZ6"
	cQuery += " WHERE NZ6.NZ6_TIPOAS = '" + FWFLDGET('NYB_CORIG') + "' "
	cQuery += " AND NZ6.NZ6_FILIAL = '" + xFilial("NZ6") + "' "
	cQuery += " AND NZ6.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T.)

	//Apaga as linhas que existem, na aba parâmetros
	For nI := 1 To oModel:GetModel( "NZ6DETAIL" ):Length()
		oModel:GetModel( "NZ6DETAIL" ):GoLine( nI )
		If !oModel:GetModel( "NZ6DETAIL" ):IsDeleted()
			oModel:GetModel( "NZ6DETAIL" ):DeleteLine()
		EndIf
	Next nI

	//Atualiza o tipo de assunto filho com os parametros do tipo de assunto de origem	
	While !(cAliasQry)->( EOF())
		
		oModel:GetModel( "NZ6DETAIL" ):AddLine()
		
		oModel:GetModel( "NZ6DETAIL" ):SetValue("NZ6_CPARAM", (cAliasQry)->NZ6_CPARAM)
		oModel:GetModel( "NZ6DETAIL" ):SetValue("NZ6_TIPO"	, (cAliasQry)->NZ6_TIPO)
		oModel:GetModel( "NZ6DETAIL" ):SetValue("NZ6_CONTEU", (cAliasQry)->NZ6_CONTEU)
		
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->(dbCloseArea())
	
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158TITC()
Verifica se os tipos de assuntos padrão estão cadastrados.

@author André Spirigoni Pinto
@since 23/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158TITC()
Local lRet := .T.
Local oModel := FWModelActive()
Local nI := 0

For nI := 1 To oModel:GetModel( "NUZDETAIL" ):Length()
	oModel:GetModel( "NUZDETAIL" ):GoLine( nI )
	If !oModel:GetModel( "NUZDETAIL" ):IsDeleted() .And. !Empty(oModel:GetModel( "NUZDETAIL" ):GetValue( "NUZ_CAMPO")) 
		oModel:GetModel( "NUZDETAIL" ):SetValue("NUZ_DESCPO",RetTitle(oModel:GetModel( "NUZDETAIL" ):GetValue( "NUZ_CAMPO")))         
	EndIf
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158CLOTE()
Verifica se os tipos de assuntos padrão estão cadastrados.

@author André Spirigoni Pinto
@since 23/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158CLOTE(cAlias, nRecNo, nOpcx, lAutomato, cAutOp, cAssJur)
Local lRet      := .T.
Local aListBox1 := {}
Local aListBox2 := {}
Local oGrupList := Nil
Local oDlg      := Nil
Static CAMPOSNAOCONFIG := 'NT9_CNOMEA|NT9_CNOMEP'

Default lAutomato := .F.
Default cAutOp    := ''
Default cAssJur   := ''

If !lAutomato
	
	If 1 > 0 
	
		//DEFINE MSDIALOG oDlg TITLE "Alterações em lote - Tipos de Assuntos Jurídicos X Campos" FROM C(0),C(0) TO C(400),C(650) PIXEL
		DEFINE MSDIALOG oDlg TITLE STR0042 FROM C(0),C(0) TO C(370),C(620) PIXEL //"Alterações em lote - Tipos de Assuntos Jurídicos X Campos"
	
		// Cria Componentes Padroes do Sistema 
		@ C(006),C(010) Say    STR0043 Size C(115),C(007) COLOR CLR_BLACK PIXEL OF oDlg //"Tabelas"	
		@ C(030),C(010) Say    STR0044 Size C(115),C(007) COLOR CLR_BLACK PIXEL OF oDlg //"Lista de campos"
		@ C(030),C(157) Say    STR0045 Size C(106),C(008) COLOR CLR_BLACK PIXEL OF oDlg //"Campos configurados"
		@ C(037),C(114) Button STR0046 Size C(040),C(010) PIXEL OF oDlg Action oGrupList:AllToSel () //"Add. Todos >>"  
		@ C(052),C(114) Button STR0047 Size C(040),C(010) PIXEL OF oDlg Action oGrupList:OneToSel () //"Adicionar >>"
		@ C(067),C(114) Button STR0048 Size C(040),C(010) PIXEL OF oDlg Action oGrupList:OneToDisp () //"<< Remove" 
		@ C(082),C(114) Button STR0049 Size C(040),C(010) PIXEL OF oDlg Action J158AllDel(oGrupList) //"<< Rem. Todos"	
		@ C(169),C(220) Button STR0050 Size C(039),C(010) PIXEL OF oDlg Action JA158NVCFG(oGrupList:GetCmpSel(),oGrupList,1,NYB->NYB_COD) //"Salvar"
		@ C(169),C(266) Button STR0051 Size C(039),C(010) PIXEL OF oDlg Action oDlg:End() //"Sair"
	
		oGrupList := JurLstBoxD():New()
		//Habilita pesquisa por título dos campos disponíveis e renomear títulos dos campos selecionados
		oGrupList:SetEnabSch(.T.)
		oGrupList:SetEnabRen(.T.)

		oGrupList:SetPosCmbTabela( {015,010,133,007} )
		oGrupList:SetCmbTabela(JA158Tabs(NYB->NYB_COD))
		oGrupList:SetSelectTab( { |x|JA158Lista(x) } )
		oGrupList:SetRefresh( { |x|JA158AtCps(x,NYB->NYB_COD,NYB->NYB_CORIG) } )
  
		oGrupList:SetRemove( { |x|JA158Orig(x) } )

		//Habilita as opções de configuração
		oGrupList:SetEnabConfig(.F.)
	
		//Coordenadas do get e button da pesquisa
		oGrupList:SetPosGetSearch( {195,010,133,007} )
		oGrupList:SetPosBtnSearch( {193,150,045,012} )
	
		//Coordenadas do get e button de renomeio
		oGrupList:SetPosGetRename( {195,200,133,007} )
		oGrupList:SetPosBtnRename( {193,340,050,012} )

		//Array de campos disponíveis e coordenadas
		oGrupList:SetCmpDisp(aListBox1)
		oGrupList:SetPosCmpDisp( {047,010,133,140} )    
	
		//Array de campos selecionados e coordenadas
		oGrupList:SetCmpSel(aListBox2)
		oGrupList:SetPosCmpSel( {047,200,133,140} )
		oGrupList:SetDlgWin( oDlg )
		oGrupList:Activate()
	
		oGrupList:RefreshDados() 
	
		ACTIVATE MSDIALOG oDlg CENTERED
		
	EndIf

Else

	If FindFunction("GetParAuto")
		aRetAuto := GetParAuto("JURA163TestCase")
		JA158NVCFG(aRetAuto, nil, 1, cAssJur, lAutomato, cAutOp)
	EndIf	

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158Tabs
Gera o array de campos de tabelas
Uso Geral.

@return aRet    Array de tabelas

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Static Function JA158Tabs(cAssJur)
Local aRet      := {}
Local aArea     := GetArea() 
Local cAliasQry := GetNextAlias()
Local cTitulo   := ""
Local aNSY      := JAEXCNSY(cAssJur)


BeginSql Alias cAliasQry
		SELECT NYC_TABELA,NYC_DTABEL,NYC_CTPASJ
		FROM %table:NYC% NYC
		WHERE NYC.NYC_CTPASJ = %Exp:cAssJur%
		AND NYC.NYC_FILIAL = %xFilial:NYC%
		AND NYC.%notDel%
EndSql

aAdd(aRet,{'','','',''})
aAdd(aRet,{'NSZ'+"=",AllTrim(JA023TIT('NSZ')) + " (" + "NSZ" + ")","NSZ","NSZ"}) //tabela padrão NSZ
aAdd(aRet,{'NTA'+"=",AllTrim(JA023TIT('NTA')) + " (" + "NTA" + ")","NTA","NTA"}) //tabela de Follow-Up NTA
aAdd(aRet,{'NT4'+"=",AllTrim(JA023TIT('NT4')) + " (" + "NT4" + ")","NT4","NT4"}) //tabela de Andamentos NT4

If Len(aNSY) > 0
	Aadd(aRet,aNSY)
EndIf

dbSelectArea(cAliasQry)
(cAliasQry)->(DbgoTop())
	
	While !(cAliasQry)->( EOF())

		cTitulo := Alltrim((cAliasQry)->NYC_DTABEL) + " ("+(cAliasQry)->NYC_TABELA+")"	  
		aAdd(aRet,{ (cAliasQry)->NYC_TABELA+"=", cTitulo, (cAliasQry)->NYC_TABELA, (cAliasQry)->NYC_TABELA })	
		
		(cAliasQry)->( dbSkip() )

	EndDo

(cAliasQry)->(dbCloseArea())	
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158Lista            
Atualiza o array de campos disponíveis para exportação
Uso Geral. 

@param oGrupList    Objeto da lista
@return aLista	    Lista de campos

@author Juliana Iwayama Velho
@since 05/01/10
@version 1.0
/*/
//-------------------------------------------------------------------  
Function JA158Lista( oGrupList )
Local aLista   := {}
Local aTab     := {}
Local aExporta := oGrupList:GetCmpSel()
Local cTabela  := oGrupList:GetTabela()
Local aArea    := GetArea()
Local aAreaSX3  := SX3->( GetArea() )
Local nI, nJ, nCt, nPos

oGrupList:oCmpSel:Reset()
oGrupList:oCmpSel:aItems := oGrupList:GetItemsAry(oGrupList:aCmpSel)

If !Empty(cTabela)
	
	SX3->( dbSetOrder( 1 ) )
	
	If SX3->( dbSeek( cTabela ) )
		
		nCt := 0
		
		While !SX3->( EOF() ) .AND. SX3->X3_ARQUIVO == NQ2->NQ2_TABELA
			nCt++
			SX3->( dbSkip() )
		End
		
		// Alterar aTab para que o mesmo traga o nome 		
		aTab := JA158Camps( cTabela, '', nCt > 1 ) 
		
		// Copia o conteudo do Array aTab para o array aLista
		For nI:= 1 to Len(aTab)    
			 aAdd(aLista,aTab[nI])			  
		Next
		
		//Exclui os campos selecionados da lista dos disponíveis
		If !Empty( aExporta )
			For nJ := 1 To Len (aExporta)			

				//Verifica se o campo já esta na configurado
				nPos := aScan( aLista, { |x| AllTrim(x[3]) == AllTrim(aExporta[nJ][3])} )
				If nPos <> 0
					aDel(aLista, nPos)
					aSize(aLista, LEN(aLista)-1)
				EndIf
			Next
		EndIf
		
	EndIf
	
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return aLista

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158Camps            
Gera a lista de campos disponíveis para exportação
Uso Geral. 
		    				    
@param  cTabela     Nome da tabela
@param  cNomeAp     Nome do apelido
@param  lApelido    Se o apelido será ou não usado

@return aCampos	    Lista de campos

@author Juliana Iwayama Velho
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------  
Function JA158Camps( cTabela, cNomeAp, lApelido )
Local cApelido   := ""
Local aCampos    := {}
Local aCampos2   := {} 
Local aArea      := GetArea()
Local aAreaSX3   := SX3->( GetArea() )
Local cCmpRef	 := ''

If !Empty(NYB->NYB_CORIG)
	cCmpRef := NYB->NYB_CORIG
Else
	cCmpRef := NYB->NYB_COD
EndIf

dbSelectArea( 'SX3' )
SX3->( dbSetOrder( 1 ) )
SX3->( dbSeek( cTabela ) )  

While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == cTabela

	//Verifica se o campo esta sendo utilizado para listar nos campos que podem ser configurados
	If X3USO(SX3->X3_USADO)
		
		AAdd( aCampos2, JA158MtCps(SX3->X3_CAMPO, SX3->X3_CAMPO, cApelido, cApelido, SX3->X3_ARQUIVO,SX3->X3_ARQUIVO, '', '', .F., SX3->X3_TITULO, 1) )
		AAdd( aCampos ,aCampos2[1][1])

		aCampos2 := {}
	EndIf
	SX3->(DbSkip())
End	
	
RestArea(aAreaSX3)
RestArea(aArea   )

Return aCampos

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158MtCps            
Monta o array dos campos da exportação personalizada
Uso Geral. 

@param cCampoTela	Campo de tela (para substituir no select)
@param cCampo		Campo disponível 
@param cApelido1n	Apelido 1º Nível
@param cApelido2n	Apelido 2º Nível
@param cTab1n		Tabela 1º Nível
@param cTab2n		Tabela 2º Nível
@param cFiltro		Filtro
@param cOrdem		Ordem do campo nas colunas da exportação
@param lApelido		Se o título terá ou não apelido 
@param cTitCampo	Título do campo
@param nTipo 	  1 - Campos disponiveis para conf
									2 - Campos já configurados
				    				    				    		    				    
@return aCampos	    Array com informações do campo

@author Juliana Iwayama Velho
@since 17/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
Static Function JA158MtCps(cCampoTela, cCampo, cApelido1n, cApelido2n, cTab1n, cTab2n, cFiltro, cOrdem, lApelido, cTitCampo, nTipo)
Local cMudaCampo:= ''
Local cTab      := ''
Local cNomeTab  := ''
Local cTitulo   := ''
Local aInfCampos:= {}
Local aCampos   := {}
Local lAgrupa   := .F.

Default cTitCampo := ''
Default nTipo     := 1

cMudaCampo:= IIf( Empty( cCampoTela ), AllTrim( cCampo ), AllTrim( cCampoTela ) )
cTab      := Left( cMudaCampo, At( '_', cMudaCampo ) - 1 )
aInfCampos:= AVSX3(cMudaCampo)

If nTipo == 1
	// Chama a função do qual receberá a descrição do campo passado como parametro
	cTitCampo :=  AllTrim( JA158InfX3( cMudaCampo, 'SX3->X3_TITULO' ) )
EndIf

If Empty( cCampoTela )
	cApelido :=	cApelido2n
Else
	cApelido :=	cApelido1n
EndIf

cNomeTab  := AllTrim(JA023TIT(cTab))

//cTitulo  := ' - ('+cNomeTab + ' / '+cApelido+')'
cTitulo  :=  '  -  ( ' + AllTrim(cNomeTab) + ' ) '

aAdd( aCampos, { cTitCampo ,cTitulo, AllTrim(cCampo), cTab1n, cTab2n, cApelido1n, cApelido2n,;
IIf ( Empty(cOrdem), Val(aInfCampos[1]), Val(cOrdem) ), AInfCampos[2], cFiltro, cCampoTela, lAgrupa } )

// Desaloca o contéudo da memoria.
cMudaCampo := nil
cTab := nil
aInfCampos:= nil
cTitCampo := nil

Return aCampos

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158AtCps            
Gera o array de campos de uma configuração já existente
cadastro.
Uso Geral. 
		   
@param  oGrupList   Objeto de lista		    				    
@return aCampos	    Array de Campos

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158AtCps( oGrupList, cAssJur, cOrig )
Local cQuery		:= ""
Local cAlias		:= GetNextAlias()
Local aArea		:= GetArea()
Local aCampos	:= {}
Local aCampos2	:= {}
Local cTitulo

Default cOrig := ""

If !Empty (cAssJur)
	
	cQuery += "SELECT NUZ_CAMPO, NUZ_DESCPO"+ CRLF
	cQuery += "  FROM "+RetSqlName("NUZ")+" NUZ"+ CRLF
	cQuery += " WHERE NUZ_FILIAL = '"+xFilial("NUZ")+"'"+ CRLF
	//cQuery += "   AND (NUZ_CTAJUR = '"+cAssJur+"' OR NUZ_CTAJUR = '"+cOrig+"')"+ CRLF
	cQuery += "   AND (NUZ_CTAJUR = '"+cAssJur+"')"+ CRLF
	cQuery += "   AND NUZ.D_E_L_E_T_ = ' '"+ CRLF
	cQuery += " ORDER BY NUZ_CAMPO"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	(cAlias)->( dbGoTop() )
	
	While !(cAlias)->( EOF() )
	
		cTitulo := IIF(Empty((cAlias)->NUZ_DESCPO),RetTitle((cAlias)->NUZ_CAMPO),(cAlias)->NUZ_DESCPO)
			
		AAdd( aCampos2, JA158MtCps( (cAlias)->NUZ_CAMPO, (cAlias)->NUZ_CAMPO, cTitulo, SubStr((cAlias)->NUZ_CAMPO,1,3),;
	   								SubStr((cAlias)->NUZ_CAMPO,1,3),SubStr((cAlias)->NUZ_CAMPO,1,3), '', '',.F., (cAlias)->NUZ_DESCPO /*JA158InfX3((cAlias)->NUZ_CAMPO, 'SX3->X3_TITULO')*/, 2) )
										
		aAdd(aCampos,aCampos2[1][1])
		
		aCampos2 := {}		
		
		(cAlias)->( dbSkip() )
		
	End
	
	(cAlias)->( dbcloseArea() )
		
EndIf

RestArea(aArea)

Return aCampos

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158NVCFG            
Salva a lista de campos selecionados para uma configuração de 
exportação
Uso Geral. 

@param aCampos     Array de campos selecionados
@param cCfg		   Configuração
@param nTipo	   Indica o tipo de operação 
				   1=Salvar nova configuração / 2= Atualizar já existente				   			

@author Juliana Iwayama Velho
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------                 
Static Function JA158NVCFG(aCampos, oGrupList, nTipo, cAssJur, lAutomato, cAutOp)
Local nI
Local aArea       := GetArea()
Local aAreaNUZ    := NUZ->(GetArea())
Local lOk         := .F.
Local aExcluir    := {}
Local nTamDesNuz  := TamSx3("NUZ_DESCPO")[1]  

Default lAutomato := .F.
Default cAutOp    := ''

If !lAutomato
	aExcluir := oGrupList:GetaRemove()
ElseIf (cAutOp == 'E')
	aExcluir := aCampos
EndIf

If !Empty( aExcluir ) .And. (Empty(cAutOp) .Or. (cAutOp == 'E')) 

	NUZ->( dbGoTop() )
	NUZ->( dbSetOrder( 1 ) )
				
	For nI:= 1 to Len(aExcluir)
		If  NUZ->( dbSeek( xFilial('NUZ') + cAssJur + aExcluir[nI][3] ) )
			While !NUZ->( EOF() ) .AND. RTRIM(NUZ->(NUZ_FILIAL + NUZ_CTAJUR + NUZ_CAMPO)) == RTRIM(xFilial( 'NUZ' ) + cAssJur + aExcluir[nI][3])
				RecLock('NUZ', .F.)
				
				dbDelete()
				MsUnlock()
				If Deleted()
					lOk := .T.
				Else
					lOk := .F.
					JurMsgErro(STR0052)//"Erro ao apagar registro"
					Exit
				EndIf
				
				NUZ->(DbSkip())
							
			End
		EndIf
	Next
	
Endif

If !Empty( cAssJur ) .And. !Empty( aCampos ) .And. (Empty(cAutOp) .Or. (cAutOp == 'I'))

	NUZ->( dbGoTop() )
	NUZ->( dbSetOrder( 1 ) )
				
	For nI:= 1 to Len(aCampos)
	
		aCampos[nI][1] := AllTrim(aCampos[nI][1])
	
		If NUZ->( DbSeek( xFilial('NUZ') + cAssJur + aCampos[nI][3] ) )

			While !NUZ->( EOF() ) .AND. RTRIM(NUZ->(NUZ_FILIAL + NUZ_CTAJUR + NUZ_CAMPO)) == RTRIM(xFilial( 'NUZ' ) + cAssJur + aCampos[nI][3])

				RecLock('NUZ', .F.)
					NUZ->NUZ_DESCPO :=  Left(aCampos[nI][1], nTamDesNuz)
				MsUnlock()
				
				If __lSX8
					ConFirmSX8()
					lOk := .T.
				EndIf
			
				NUZ->(DbSkip())
			End

		Else
		
			RecLock('NUZ', .T.)
				NUZ->NUZ_FILIAL := xFilial('NUZ')
				NUZ->NUZ_CAMPO  := aCampos[nI][3]
				NUZ->NUZ_DESCPO :=  Left(aCampos[nI][1], nTamDesNuz)
				NUZ->NUZ_CTAJUR := cAssJur
			MsUnlock() 
			
			If __lSX8
				ConFirmSX8()
				lOk := .T.
			EndIf
			
		Endif
	Next
				
	
Endif
	
MSGINFO(STR0053) //"Configuração salva com sucesso"	

RestArea(aAreaNUZ)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158Orig            
Gera o array de campos a remover da exportação e inserir na lista de
campos disponíveis
Uso Geral. 

@param  oGrupList   Objeto de lista			   	    				    
@return aRemover    Array de tabelas

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158Orig( oGrupList)
Local aArea      := GetArea()
Local aRemover   := {}
Local aCampos    := oGrupList:GetCmpSel()
Local cTabOrigem := ''
Local cTab       := oGrupList:GetTabela()
Local nPos       := oGrupList:oCmpSel:nAt
Local nI
Local nCampo     := nPos
Local aRemove    := oGrupList:GetaRemove()

If valtype(aRemove) == 'U'
	aRemove := {}
Endif	

If oGrupList:lAllToDisp 
	oGrupList:oCmpSel:Reset()
	oGrupList:oCmpSel:aItems := oGrupList:GetItemsAry(oGrupList:aCmpSel)
	nPos := 0
endif

If !Empty( aCampos )

	For nI:=1 to Len(aCampos)
		
		If nPos == 0
			nCampo := nI
		EndIf
		
		cTabOrigem := Left( aCampos[nCampo][3], At( '_', aCampos[nCampo][3] ) - 1 )
		
		//Verifica se o nome da tabela vem do campo inicial ou de tela
		If !(aCampos[nCampo][4] == aCampos[nCampo][5])
			If !Empty( aCampos[nCampo][11] )
				cTabOrigem := Left( aCampos[nCampo][11], At( '_', aCampos[nCampo][11] ) - 1 )
			EndIf
		EndIf
		
		aAdd(aRemove,aCampos[nCampo])
		
		If (cTab == aCampos[nCampo][7])
			aAdd(aRemover,aCampos[nCampo])
		EndIf
		
		If nPos != 0
			nI := Len(aCampos) + 1
		Endif
	
	Next
	
EndIf

oGrupList:SetaRemove(aRemove)

RestArea(aArea)

Return aRemover

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158F3CPO            
Realiza o filtro de tabelas para busca dos campos usado no F3 de campos
Uso Geral. 

@param
@return 

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158F3CPO(cTipo)
Local aArea     := GetArea() 
Local oModel    := FwModelActive()
Local oModelNYB := oModel:GetModel("NYBMASTER")
Local oModelNYC := oModel:GetModel("NYCDETAIL")
Local oModelNUZ := oModel:GetModel("NUZDETAIL")
Local nQtdNYC   := 0
Local nQtdNUZ   := 0
Local nQtdNYD   := 0
Local nNYCAnt   := 0
Local nNYC      := 0
Local nI        := 0
Local lRet      := .F.
Local lIni      := .T.
Local lVazio    := .F.
Local cFiltro   := ""
Local cCampos   := ""
Local cTmpCps   := ""

nQtdNYC := oModelNYC:GetQtdLine()
nQtdNUZ := oModelNUZ:GetQtdLine()
nQtdNYD := oModelNYC:GetQtdLine()
nNYCAnt := oModelNYC:GetLine()

If cTipo == '1'
	
	//<- Verifica os campos do perfil pai para perfil filho ->
	If oModelNYB:GetValue("NYB_COD") > '050' .And. !Empty(Alltrim(oModelNYB:GetValue("NYB_CORIG")))
		cFiltro += JA158QrCpo(oModelNYB:GetValue("NYB_CORIG"),cTipo)	
	EndIf
	
	//<- Adiciona excessão aos campos já preenchidos ->
	If nQtdNUZ > 0
		For nI := 1 to nQtdNUZ
			//lIni:= Iif(lIni,.F.,lIni)		
			
			lVazio:= IIf ( EMPTY(oModelNUZ:GetValue("NUZ_CAMPO", nI)),.T., .F.)
							  		
		  	If !(oModelNUZ:IsDeleted(nI)) .And. !EMPTY(oModelNUZ:GetValue("NUZ_CAMPO", nI))			  	
				cTmpCps += ALLTRIM( oModelNUZ:GetValue("NUZ_CAMPO", nI) )+"|"
		  	EndIf
		Next
				
		If !EMPTY(cTmpCps)			
			cTmpCps := LEFT(cTmpCps , RAT('|',cTmpCps)-1 )						 
			//cTmpCps += ")"			
			
			If LEN(cFiltro) > 0		
				If ( RAT('.AND.',cFiltro) <>  LEN(cFiltro) ).AND.( RAT('.AND.',cFiltro) < LEN(cFiltro) )  
					cFiltro += ".AND."
				EndIF
				
		 		cFiltro += "!( ALLTRIM(X3_CAMPO) $ '" + cTmpCps + "' )"
	 		EndIf
	 	EndIf	 			
	EndIF
	
	If LEN(cFiltro) > 0 .AND. ( !lIni .And. !Empty(AllTrim(cFiltro)) )
		cFiltro += ")"
	EndIf
	
	// Nome das tabelas 
	If LEN(cFiltro) > 0
		cFiltro+= ".AND."
	EndIf
		
	cFiltro+= "(X3_ARQUIVO=='NSZ'.OR.X3_ARQUIVO=='NT4'.OR.X3_ARQUIVO=='NTA' .OR. X3_ARQUIVO=='NSY'"

	For nNYC := 1 to nQtdNYC
		If !(oModelNYC:IsDeleted(nNYC)).AND. !EMPTY(oModelNYC:GetValue("NYC_TABELA", nNYC))
			cFiltro += ".OR.X3_ARQUIVO=='" + oModelNYC:GetValue("NYC_TABELA", nNYC) + "'"			 
		EndIF
	Next
	
	cFiltro += ").AND.X3USO(X3_USADO) "	
Else

	If oModelNYB:GetValue("NYB_COD") > '050' .And. !Empty(Alltrim(oModelNYB:GetValue("NYB_CORIG")))
		cCampos := JA158QrCpo(oModelNYB:GetValue("NYB_CORIG"),cTipo)
		
		If !Empty(Alltrim(cCampos))
			cFiltro		:= "(X3_ARQUIVO=='NSZ'.OR.X3_ARQUIVO=='NT4'.OR.X3_ARQUIVO=='NTA' .OR. X3_ARQUIVO=='NSY'"
				
			For nNYC := 1 to nQtdNYC
				If !(oModelNYC:IsDeleted(nNYC)) .AND. !Empty(oModelNYC:GetValue("NYC_TABELA", nNYC) )
					cFiltro += " .Or.X3_ARQUIVO=='" + oModelNYC:GetValue("NYC_TABELA", nNYC) + "'"
				EndIf
			Next
			
			cFiltro += ").And.X3USO(X3_USADO)"
			
			cFiltro += cCampos
		Else
			cFiltro := " X3_CAMPO=='' .AND. X3_ARQUIVO==''"
		EndIf
	Else
		cFiltro := " X3_CAMPO=='' .AND. X3_ARQUIVO==''"
	EndIf

EndIf

//<- Tratativa para o filtro não iniciar com expressão invalida ->
If AT('.AND.', cFiltro)== 1
	cFiltro := SubStr(cFiltro,6,LEN(cFiltro)) // ".AND."

ElseIF AT('.OR.', cFiltro) == 1
	cFiltro := SubStr(cFiltro,5,LEN(cFiltro)) // ".OR."
EndIf

lRet := JURF3SX3(cFiltro)

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158F3NYB            
Retorna os assuntos juridicos "pais"
Uso Geral. 

@param
@return 

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158F3NYB()
Local cRet := "@#@#"

If  IsInCallStack("JURA158") .AND. (M->NYB_COD > '050')
	cRet := "@#NYB->NYB_COD < '051'@#"
EndIf

Return cRet

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158F3NYC            
Retorna as tabelas a serem usadas
Uso Geral. 

@param 
@return 

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158F3NYC()
Local lRet       := .F.
Local oDlg, oBrowse, oBtnOK, oBtnCan, oMainWnd, oTela, oPnlBrw, oPnlRoda
Local oModel     := FwModelActive()
Local oModelNYB  := oModel:GetModel("NYBMASTER")
Local cOrig      := oModelNYB:GetValue("NYB_CORIG")
Local cCod       := oModelNYB:GetValue("NYB_COD")
Local cAliasQry  := ''
Local aTabs      := {}
Local aCols      := {}
Local nEspButton := 10
Local cIdBrowse  := ''
Local cIdRodape  := ''

aAdd(aCols,{"Tabela","Tabela",'@!',3,,,,'C',,'R',,,,,,,,})
aAdd(aCols,{"Descrição","DESC",'@!',30,,,,'C',,'R',,,,,,,,})

If cCod > '050'
	If !Empty(AllTrim(cOrig))
	
		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
				SELECT NYC_TABELA
				FROM %table:NYC% NYC
				WHERE NYC.NYC_CTPASJ = %Exp:cOrig%
				AND NYC.NYC_FILIAL = %xFilial:NYC%
				AND NYC.%notDel%
		EndSql
		
		aTabs := {}
		
		dbSelectArea(cAliasQry)
		(cAliasQry)->(DbgoTop())
		
		If !(cAliasQry)->( EOF())
			While !(cAliasQry)->( EOF())
				aAdd(aTabs,{(cAliasQry)->NYC_TABELA,FWX2Nome((cAliasQry)->NYC_TABELA)})
				(cAliasQry)->( dbSkip() )
			EndDo
		EndIf
		
		(cAliasQry)->(dbCloseArea()) 
	EndIf
Else
	Aadd(aTabs,{'NUQ',FWX2Nome('NUQ')})
	Aadd(aTabs,{'NT9',FWX2Nome('NT9')})
	Aadd(aTabs,{'NXY',FWX2Nome('NXY')})
	Aadd(aTabs,{'NYJ',FWX2Nome('NYJ')})
	Aadd(aTabs,{'NYP',FWX2Nome('NYP')})
	Aadd(aTabs,{'NSY',FWX2Nome('NSY')})
EndIf
Define MsDialog oDlg From 178, 0 To 543, 800 Title STR0054 Pixel Of oMainWnd // "Consulta PadrÃ£o - Campos do Sistema"

	oTela     := FWFormContainer():New( oDlg )
	cIdBrowse := oTela:CreateHorizontalBox( 84 )
	cIdRodape := oTela:CreateHorizontalBox( 16 )
	oTela:Activate( oDlg, .F. )

	oPnlBrw   := oTela:GeTPanel( cIdBrowse )
	oPnlRoda  := oTela:GeTPanel( cIdRodape )
	
	oBrowse := TJurBrowse():New(oPnlBrw)
	oBrowse:SetDataArray()
	oBrowse:SetDoubleClick({||lRet := .T.,_cChavSX2 := aTabs[oBrowse:nAT][1] ,  oDlg:End()})
	oBrowse:setHeader(aCols)
	oBrowse:Activate()
	
	oBrowse:setArray(aTabs)
	oBrowse:Refresh()	

	@oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton Button oBtnOk Prompt STR0059;
			Size 25 , 12 Of oPnlRoda Pixel Action ( lRet := .T., _cChavSX2 := aTabs[oBrowse:nAT][1] , oDlg:End() )
	@oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton + 30 Button oBtnCan Prompt STR0060;
			Size 25 , 12 Of oPnlRoda Pixel Action ( lRet := .F., oDlg:End() )
			
Activate MsDialog oDlg Centered

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158VLNYC            
Validação do cadastro de Guias
Uso Geral. 

@param
@return 

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158VlNYC()
Local nI        := 0
Local aTabelas  := JURRELASX9('NSZ',.F.)
Local aArea     := GetArea()
Local lRet      := .F.
Local oModel    := FwModelActive()
Local oModelNYB := oModel:GetModel("NYBMASTER")
Local cOrig     := oModelNYB:GetValue("NYB_CORIG")
Local cCod      := oModelNYB:GetValue("NYB_COD")

For nI := 1 to Len(aTabelas)
	If !(aTabelas[nI] $ "NSZ|NT2|NT3|NT4|NTA|NTF|NUN|NUV|NWU|NY0|NSU|NSY|") //Tabelas Relacionadas no SX9 com a tabela NSZ que não devem aparecer nas guias para configuração de novas pesquisas.
		If aTabelas[nI] == M->NYC_TABELA
			lRet := .T.
			Exit
		Else
			JurMsgErro(STR0061)//"Tabela inválida!"
		EndIf	
	Else
		JurMsgErro(STR0061)//"Tabela inválida!"
	EndIf
Next

If lRet .And. cCod > '050'
	If !Empty(AllTrim(cOrig))
		NYC->(DBSetOrder(1))
		If !(NYC->( DBSeek(XFILIAL('NYC')+AllTrim(cOrig)+M->NYC_TABELA) ))	
			JurMsgErro(STR0093)	//"Tabela não localizada no tipo de assunto jurídico de origem, verifique!"
			lRet := .F.
		EndIF
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158VlNYD            
Validação do cadastro de Exceção de Campos
Uso Geral. 

@param  			   	    				    
@return 

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158VlNYD()
Local aArea			:= GetArea() 
Local oModel   	:= FwModelActive()
Local oModelNYB := oModel:GetModel("NYBMASTER")
Local oModelNYC := oModel:GetModel("NYCDETAIL")
Local nQtdNYC		:= 0
Local nNYCAnt 		:= 0
Local nNYC				:= 0
Local lRet				:= .F.
Local cTabela		:= ""
Local cFiltro		:= ""

cTabela := SUBSTR(M->NYD_CAMPO, 1, 3)
nQtdNYC := oModelNYC:GetQtdLine()
nNYCAnt := oModelNYC:GetLine()

If cTabela == 'NSZ' .Or. cTabela == 'NTA' .Or. cTabela == 'NT4'
	lRet := .T.
Else
	For nNYC := 1 to nQtdNYC
		If !(oModelNYC:IsDeleted(nNYC))
			If cTabela == oModelNYC:GetValue("NYC_TABELA", nNYC)
				lRet := .T.
				Exit
			EndIf
		EndIf
	Next
EndIf

If lRet .And. oModelNYB:GetValue("NYB_COD") > '050'
	If !Empty(AllTrim(oModelNYB:GetValue("NYB_CORIG")))
		cFiltro := JA158QrCpo(oModelNYB:GetValue("NYB_CORIG"),"2")
		If !(AllTrim(M->NYD_CAMPO) $ cFiltro)
			lRet := .F.
		EndIf
	EndIf
EndIf

If !lRet
	JurMsgErro(STR0062 + STR0071)//"Campo inválido " +  "ou inexistente no assunto jurídico de origem"
EndIf

If lRet .And. oModelNYB:GetValue("NYB_COD") > '050' .And. !ExistChav("NYD", xFilial("NYD") + AllTrim(oModelNYB:GetValue("NYB_COD")) + M->NYD_CAMPO, 1)
	lRet := .F.
	JurMsgErro(STR0063)//"Linha duplicada!"
EndIf

If lRet .And. oModelNYB:GetValue("NYB_COD") <= '050'
	If !Empty(AllTrim(M->NYD_CAMPO))
		lRet := .F.
		JurMsgErro(STR0064)//"Não é possível ter exceções para assuntos jurídicos padrão!"
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158VlNUZ            
Validação do cadastro de Campos
Uso Geral. 

@param  			   	    				    
@return 

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158VlNUZ()
Local aArea		:= GetArea() 
Local oModel   	:= FwModelActive()
Local aTabGuias := J158TbGuia()	//Retorno das tabelas ques estão na aba guia
Local lRet		:= .F.
Local cTabela	:= ""

If oModel:GetID() == "JURA158"

	cTabela := SUBSTR(M->NUZ_CAMPO, 1, 3)
	
	If aScan( aTabGuias , cTabela ) > 0
		lRet := .T.
	Else
		lRet := .F.		
		JurMsgErro(STR0074+ SUBSTR( M->NUZ_CAMPO,1,3) + STR0075 ) // "Tabela " + SUBSTR( M->NUZ_CAMPO,1,3) + " não foi selecionada na aba 'Guias' ")
		Return lRet 
	EndIf
		
	If !JurExistSX3(M->NUZ_CAMPO, .T.)
		lRet := .F.			
		JurMsgErro(STR0076) // "Campo não existe. "
	EndIf

Else
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158QrCpo            
Seleciona campos usados pelo assunto pai.


Uso Geral. 

@param			cAJ				Codigo do assunto juridico
						cTipo			1 - Seleciona os campos para não indica-los no F3 de campo
						cTipo			2 - Seleciona os campos para indica-los no F3 de exceção
@return 

@author Jorge Luis Branco Martins Junior
@since 07/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Static Function JA158QrCpo(cAJ,cTipo)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cTmpAlias	:= GetNextAlias()
Local cFiltro	:= ""
Local cCampos	:= ""
Local lExtCont:= .F.

	cQuery := " SELECT NUZ.NUZ_CAMPO CAMPO "
	cQuery += 		" FROM " + RetSqlName("NUZ") + " NUZ "
	cQuery += " WHERE NUZ.NUZ_CTAJUR = '"+cAJ+"' "
	cQuery +=    "	AND NUZ.NUZ_FILIAL  = '" + xFilial("NUZ") + "' " + CRLF
	cQuery +=    "	AND NUZ.D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.T.,.T.)
		
	(cTmpAlias)->(DbGoTop())
	
	While !(cTmpAlias)->( EOF())		
		cCampos += ALLTRIM( (cTmpAlias)->CAMPO )+"|"
		(cTmpAlias)->( dbSkip() )
		lExtCont := .T.
	End
	
	If lExtCont
		If cTipo == '1'		
			cFiltro += "( !ALLTRIM(X3_CAMPO) $ '" + cCampos + "' )"
		Else		
			cFiltro += ".AND.( ALLTRIM(X3_CAMPO) $ '" + cCampos + " ')"
		EndIf
	
		(cTmpAlias)->( dbCloseArea())
		
		If Len(cFiltro) > 1 .And. RAT('|',cFiltro) > 2 
			cFiltro:= LEFT(cFiltro , RAT('|',cFiltro)-1 )
			cFiltro += "')"
		EndIf
	EndIF
		
RestArea(aArea)

Return cFiltro

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158AjPsq            
Realiza o ajuste/preenchimento do campo de Código da pesquisa, pois
antes não existia esse campo

Uso Geral. 

@param			
@return 

@author Jorge Luis Branco Martins Junior
@since 11/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158AjPsq()
Local aArea			:= GetArea()
Local cQuery			:= ""
Local cAlias			:= Nil
Local nNumero		:= 0
Local cPesq			:= ""
Local cRecno			:= ""
Local cPesqAtu		:= ""

cQuery := " SELECT NVG_DESC DESCR, R_E_C_N_O_ RECNONVG FROM " + RetSqlName("NVG") + " NVG " 
cQuery +=  	"	WHERE D_E_L_E_T_ = ' ' "
cQuery += 			" AND NVG_FILIAL = '"+xFilial("NVG")+"'"
cQuery +=  		"	AND NVG_DESC <> '' "
cQuery +=  		"	AND NVG_CPESQ = '' "
cQuery += " 	ORDER BY NVG_DESC "

cAlias := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
(cAlias)->( dbGoTop() )

	If !(cAlias)->(EOF())
		While !(cAlias)->(EOF())
			
			cPesq			:= (cAlias)->DESCR	
			cRecno		:= (cAlias)->RECNONVG
			
			If cPesq <> cPesqAtu
				cPesqAtu := cPesq
				nNumero	:= nNumero+1
			EndIf
			
			NVG->( DBGoTo( (cAlias)->RECNONVG ) )
			RecLock('NVG',.F.)
			NVG->NVG_CPESQ := strzero( nNumero, 3 ) 
			NVG->(MsUnLock())
			
			(cAlias)->( dbSkip() )
		End

		//JA158AjRef()

	EndIf

	(cAlias)->(dbCloseArea())

RestArea(aArea)

Return Nil
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158AjRef            
Realiza o ajuste/preenchimento do campo que faz referência ao
Código da pesquisa, pois antes não existia esse campo.

Tabelas NVA - NVJ - NVK

Uso Geral. 

@param			
@return 

@author Jorge Luis Branco Martins Junior
@since 11/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158AjRef()
Local aArea			:= GetArea()
Local cQuery			:= ""
Local cAlias			:= Nil
Local nLen				:= 0
Local cSpc				:= ""

cQuery := " SELECT NVA_PESQ DESCR, R_E_C_N_O_ RECNONVA FROM " + RetSqlName("NVA") + " NVA " 
cQuery +=  	"	WHERE D_E_L_E_T_ = ' ' "
cQuery += 			"	AND NVA_FILIAL = '"+xFilial("NVA")+"'"+ CRLF
cQuery +=  		"	AND NVA_PESQ <> '' "
cQuery +=  		"	AND NVA_CPESQ = '' "
cQuery += " 	ORDER BY NVA_PESQ "

cAlias := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
(cAlias)->( dbGoTop() )

	If !(cAlias)->(EOF())
		While !(cAlias)->(EOF())

			nLen		:= TamSX3('NVA_PESQ')[1] - Len((cAlias)->DESCR)
			cSpc		:= Space ( nLen )		

			cQryCod := " SELECT NVG_CPESQ CPESQ FROM " + RetSqlName("NVG") + " NVG " 
			cQryCod +=  	"	WHERE D_E_L_E_T_ = ' ' "
			cQryCod += 		"	AND NVG_FILIAL = '"+xFilial("NVG")+"'"
			cQryCod +=  		"	AND NVG_DESC = '"+(cAlias)->DESCR+cSpc+"' "
			cQryCod +=  " GROUP BY NVG_CPESQ "
			
			cAliasCod 	:= GetNextAlias()
			cQryCod 		:= ChangeQuery(cQryCod)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCod),cAliasCod,.T.,.T.)
			(cAliasCod)->( dbGoTop() )
			
			If !(cAliasCod)->(EOF())
			
					NVA->( DBGoTo( (cAlias)->RECNONVA ) )
					RecLock('NVA',.F.)
					NVA->NVA_CPESQ := (cAliasCod)->CPESQ
					NVA->(MsUnLock())					
				
			EndIf 
			(cAliasCod)->(dbCloseArea())
			
			(cAlias)->( dbSkip() )
		End
	EndIf

	(cAlias)->(dbCloseArea())

cQuery := " SELECT NVJ_PESQUI DESCR, R_E_C_N_O_ RECNONVJ FROM " + RetSqlName("NVJ") + " NVJ " 
cQuery +=  	"	WHERE D_E_L_E_T_ = ' ' "
cQuery += 			"	AND NVJ_FILIAL = '"+xFilial("NVJ")+"'"+ CRLF
cQuery +=  		"	AND NVJ_PESQUI <> '' "
cQuery +=  		"	AND NVJ_CPESQ = '' "
cQuery += " 	ORDER BY NVJ_PESQUI "

cAlias := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
(cAlias)->( dbGoTop() )

	If !(cAlias)->(EOF())
		While !(cAlias)->(EOF())

			nLen		:= TamSX3('NVJ_PESQUI')[1] - Len((cAlias)->DESCR)
			cSpc		:= Space ( nLen )		

			cQryCod := " SELECT NVG_CPESQ CPESQ FROM " + RetSqlName("NVG") + " NVG " 
			cQryCod +=  	"	WHERE D_E_L_E_T_ = ' ' "
			cQryCod += 		"	AND NVG_FILIAL = '"+xFilial("NVG")+"'"
			cQryCod +=  		"	AND NVG_DESC = '"+(cAlias)->DESCR+cSpc+"' "
			cQryCod +=  " GROUP BY NVG_CPESQ "
			
			cAliasCod 	:= GetNextAlias()
			cQryCod 		:= ChangeQuery(cQryCod)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCod),cAliasCod,.T.,.T.)
			(cAliasCod)->( dbGoTop() )
			
			If !(cAliasCod)->(EOF())
			
					NVJ->( DBGoTo( (cAlias)->RECNONVJ ) )
					RecLock('NVJ',.F.)
					NVJ->NVJ_CPESQ := (cAliasCod)->CPESQ
					NVJ->(MsUnLock())					
				
			EndIf 
			(cAliasCod)->(dbCloseArea())
			
			(cAlias)->( dbSkip() )
		End
	EndIf

	(cAlias)->(dbCloseArea())

cQuery := " SELECT NVK_PESQ DESCR, R_E_C_N_O_ RECNONVK FROM " + RetSqlName("NVK") + " NVK " 
cQuery +=  	"	WHERE D_E_L_E_T_ = ' ' "
cQuery += 			"	AND NVK_FILIAL = '"+xFilial("NVK")+"'"+ CRLF
cQuery +=  		"	AND NVK_PESQ <> '' "
cQuery +=  		"	AND NVK_CPESQ = '' "
cQuery += " 	ORDER BY NVK_PESQ "

cAlias := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
(cAlias)->( dbGoTop() )

	If !(cAlias)->(EOF())
		While !(cAlias)->(EOF())

			nLen		:= TamSX3('NVK_PESQ')[1] - Len((cAlias)->DESCR)
			cSpc		:= Space ( nLen )		
			
			cQryCod := " SELECT NVG_CPESQ CPESQ FROM " + RetSqlName("NVG") + " NVG " 
			cQryCod +=  	"	WHERE D_E_L_E_T_ = ' ' "
			cQryCod += 		"	AND NVG_FILIAL = '"+xFilial("NVG")+"'"
			cQryCod +=  		"	AND NVG_DESC = '"+(cAlias)->DESCR+cSpc+"' "
			cQryCod +=  " GROUP BY NVG_CPESQ "
			
			cAliasCod 	:= GetNextAlias()
			cQryCod 		:= ChangeQuery(cQryCod)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCod),cAliasCod,.T.,.T.)
			(cAliasCod)->( dbGoTop() )
			
			If !(cAliasCod)->(EOF())
			
					NVK->( DBGoTo( (cAlias)->RECNONVK ) )
					RecLock('NVK',.F.)
					NVK->NVK_CPESQ := (cAliasCod)->CPESQ
					NVK->(MsUnLock())					
				
			EndIf 
			(cAliasCod)->(dbCloseArea())
			
			(cAlias)->( dbSkip() )
		End
	EndIf

	(cAlias)->(dbCloseArea())

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158NewCPq()
Função utilizada para devolver o ultimo reigstro do banco
Uso Geral
@author Clóvis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158NewCPq()
Local aArea     := GetArea()
Local cNextCode := '051'
Local cAliasQry := GetNextAlias()               

  BeginSql Alias cAliasQry    
	
    SELECT MAX(NYB_COD) NYB_MAX
      FROM %table:NYB% NYB
     WHERE NYB.NYB_FILIAL = %xFilial:NYB%
       AND NYB.%notDEL%	                           			
   		 		
  EndSql
  dbSelectArea(cAliasQry)

  if !Empty((cAliasQry)->NYB_MAX) .And. (cAliasQry)->NYB_MAX >= cNextCode 	
    cNextCode := PadL((Val((cAliasQry)->NYB_MAX) + 1),3,'0')
  Endif            
  
  (cAliasQry)->(dbCloseArea())  
	RestArea(aArea)

Return cNextCode

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158AAsj()
Função que ajusta o código de assunto jurídico das tabelas, passando de
tamanho 2 para 3

Uso Geral
@author Jorge Luis Branco Martins Junior
@since 17/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158AAsj()

DbSelectArea("NSZ")
NSZ->(DbGoTop())
Do While NSZ->(!Eof())
	If Len(AllTrim(NSZ->NSZ_TIPOAS)) < 3
		RecLock("NSZ",.F.)
		NSZ->NSZ_TIPOAS := '0' + NSZ->NSZ_TIPOAS
		NSZ->(MsUnlock())
	EndIf
	NSZ->(DbSkip())
End

DbSelectArea("NVJ")
NVJ->(DbGoTop())
Do While NVJ->(!Eof())
	If Len(AllTrim(NVJ->NVJ_CASJUR)) < 3
		RecLock("NVJ",.F.)
		NVJ->NVJ_CASJUR := '0' + NVJ->NVJ_CASJUR
		NVJ->(MsUnlock())
	EndIf
	NVJ->(DbSkip())
End

DbSelectArea("NVL")
NVL->(DbGoTop())
Do While NVL->(!Eof())
	If Len(AllTrim(NVL->NVL_CTIPOA)) < 3
		RecLock("NVL",.F.)
		NVL->NVL_CTIPOA := '0' + NVL->NVL_CTIPOA
		NVL->(MsUnlock())
	EndIf
	NVL->(DbSkip())
End

DbSelectArea("NUZ")
NUZ->(DbGoTop())
Do While NUZ->(!Eof())
	If Len(AllTrim(NUZ->NUZ_CTAJUR)) < 3
		RecLock("NUZ",.F.)
		NUZ->NUZ_CTAJUR := '0' + NUZ->NUZ_CTAJUR
		NUZ->(MsUnlock())
	EndIf
	NUZ->(DbSkip())
End

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158ANmCp()
Função que ajusta o as descrições de campos segundo X3 caso
estejam em branco

Uso Geral
@author Jorge Luis Branco Martins Junior
@since 17/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158ANmCp()

DbSelectArea("NUZ")
NUZ->(DbGoTop())
Do While NUZ->(!Eof())
	If Empty(AllTrim(NUZ->NUZ_DESCPO))
		RecLock("NUZ",.F.)
		NUZ->NUZ_DESCPO := JURX3INFO( NUZ->NUZ_CAMPO, "X3_TITULO" )
		NUZ->(MsUnlock())
	EndIf
	NUZ->(DbSkip())
End

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158NYCOK()
Validação para TUDOOK da tabela NYC - Guias

Uso Geral
@author Jorge Luis Branco Martins Junior
@since 30/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA158NYCOK(oModel, nOpc)
Local lRet      := .T.
Local oModelNYB := oModel:GetModel("NYBMASTER")
Local oModelNYC := oModel:GetModel("NYCDETAIL")
Local cOrig     := oModelNYB:GetValue("NYB_CORIG")
Local cCod      := oModelNYB:GetValue("NYB_COD")
Local nQtdNYC   := oModelNYC:GetQtdLine()
Local nI        := 0

Default nOpc    := 0

//Pesquisas Filhas
If cCod > '050'
	If !Empty(AllTrim(cOrig))
		NYC->(DBSetOrder(1))
		For nI := 1 to nQtdNYC
			oModelNYC:GoLine(nI)
			If !oModelNYC:IsDeleted()
				If !(NYC->( DBSeek(XFILIAL('NYC')+AllTrim(cOrig)+oModelNYC:GetValue("NYC_TABELA", nI)) ))	 .And. !Empty(Alltrim(oModelNYC:GetValue("NYC_TABELA", nI)))
					JurMsgErro(STR0055 +  " " + oModelNYC:GetValue("NYC_TABELA", nI) + STR0066)//"Tabela " + " é inválida para esse tipo de origem! Verifique no assunto origem quais tabelas podem ser configuradas"  
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf
	
//Pesquisas padrões
Else

	For nI:=1 To nQtdNYC 
	
		oModelNYC:GoLine(nI)
		If ( oModelNYC:IsUpdated() .And. !oModelNYC:IsInserted() ) .OR.; 
		   ( oModelNYC:IsDeleted() .Or. oModelNYC:IsInserted() ) .And. !( AllTrim(oModelNYC:GetValue("NYC_TABELA", nI)) $ TABSCONFIG )
		    
			If !( nQtdNYC == 1 .And. oModelNYC:IsInserted() .And. Empty(oModelNYC:GetValue("NYC_TABELA", nQtdNYC)) )
				JurMsgErro(STR0024) //"Não é permitido alterar as guias de assuntos juridicos padrão."			
				lRet := .F.
				Exit
			EndIf
			
		EndIf
	Next nI
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158NUZOK()
Validação para TUDOOK da tabela NUZ - Campos

Uso Geral
@author Jorge Luis Branco Martins Junior
@since 31/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA158NUZOK(oModel, nOpc)
Local lRet      := .T.
Local oModelNYC := oModel:GetModel("NYCDETAIL")
Local oModelNUZ := oModel:GetModel("NUZDETAIL")
Local nQtdNYC   := oModelNYC:GetQtdLine()
Local nQtdNUZ   := oModelNUZ:GetQtdLine()
Local nI        := 0
Local cTabelas  := 'NSZ|NTA|NT4|NSY'

Default nOpc	:= 0

	NUZ->( dbSetOrder( 1 ) )

	For nI := 1 to nQtdNYC
		If !(oModelNYC:IsDeleted(nI))
			cTabelas += "|"+oModelNYC:GetValue("NYC_TABELA", nI)
		EndIf
	Next

	For nI := 1 to nQtdNUZ
	
		If !(oModelNUZ:IsDeleted(nI)) .And. !(SubStr(oModelNUZ:GetValue("NUZ_CAMPO", nI),1,3) $ cTabelas) .And. !Empty(Alltrim(oModelNUZ:GetValue("NUZ_CAMPO", nI)))
			JurMsgErro(STR0067 + " " + oModelNUZ:GetValue("NUZ_CAMPO", nI) + STR0068)// "Campo " + " é inválido. Verifique se a guia referente a este campo está configurada!"
			lRet := .F.
			Exit
		EndIf
	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158NYDOK()
Validação para TUDOOK da tabela NYD - Campos restritos

Uso Geral
@author Jorge Luis Branco Martins Junior
@since 31/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA158NYDOK(oModel, nOpc)
Local lRet				:= .T.
Local oModelNYB	:= oModel:GetModel("NYBMASTER")
Local oModelNYC	:= oModel:GetModel("NYCDETAIL")
Local oModelNYD	:= oModel:GetModel("NYDDETAIL")
Local cCod				:= oModelNYB:GetValue("NYB_COD")
Local nQtdNYC		:= oModelNYC:GetQtdLine()
Local nQtdNYD		:= oModelNYD:GetQtdLine()
Local nI					:= 0
Local cTabelas	:= 'NSZ|NTA|NT4' 

Default nOpc			:= 0

	For nI := 1 to nQtdNYC
		If !(oModelNYC:IsDeleted(nI))
			cTabelas += "|"+oModelNYC:GetValue("NYC_TABELA", nI)
		EndIf
	Next

	If cCod > '050'
		For nI := 1 to nQtdNYD
			If !(SubStr(oModelNYD:GetValue("NYD_CAMPO", nI),1,3) $ cTabelas)  .And. !Empty(Alltrim(oModelNYD:GetValue("NYD_CAMPO", nI))) 	
				JurMsgErro(STR0067 + oModelNYD:GetValue("NYD_CAMPO", nI) + STR0070)//"Campo " + " é inválido. Verifique se a guia referente a este campo está configurada!"
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158InfX3
Retorna qualquer informação do campo da tabela SX3, indicado pelo
parametro, informando o X3_CAMPO e qual informação se deseja

@Param    cCampo Nome do campo que se deseja trazer a informação
@Param    cCampo Nome do campo do qual deseja que a descrição

@Return   cRet   Retorna a informação do campo indicado

@author Jorge Luis Branco Martins Junior
@since 11/12/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA158InfX3(cCampo, cInfo)
Local aAreaSX3 := SX3->( GetArea() )
Local aArea       := GetArea()                                                                                
Local lRet   		:= .F.
Local cRet 		:= ''

If !Empty(cCampo)
	dbSelectArea('SX3')
	SX3->( dbSetOrder(2) )
	lRet := SX3->( dbSeek(cCampo) )

	If lRet  := .T.
		cRet := allTrim(&cInfo)
	EndIf
EndIf	

RestArea(aAreaSX3)
RestArea(aArea)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J158TbGuia
Retorno array das tabelas que estão no grid de "Guias" e mais
as tabelas já pré-definidas que o sistema usa

Uso Geral
@author Rafael Rezende Costa
@since 12/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J158TbGuia()
Local aTbs		:= {'NSZ', 'NUQ' ,'NT9', 'NTA' , 'NT4', 'NSY' }	 // Tabelas pré definidas NSZ|NUQ|NT9|NTA|NT4|NSY|
Local oModel	:= FwModelActive()
Local oModelNYC := oModel:GetModel("NYCDETAIL") 
Local nQtdNYC 	:= oModelNYC:GetQtdLine()
Local nNYC		:= 0 

For nNYC := 1 to nQtdNYC
	If !(oModelNYC:IsDeleted(nNYC))
		If aScan( aTbs , oModelNYC:GetValue("NYC_TABELA", nNYC)  ) == 0 
			aADD( aTbs , oModelNYC:GetValue("NYC_TABELA", nNYC) )			// adiciona a tabela no array aTbs
		EndIF
	EndIf
Next nNYC

Return aTbs

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158RtNYC()
Retornar as tabelas relacionadas aos tipos de assuntos juridicos
Uso Geral
@param	cTiposAssu 	- Tipos de assuntos juridicos. (opcional)
@return	aTabelas	- Tabela que estão relacionadas a ao assunto juridico passado no parametro.
@author Rafael Tenorio da Costa
@since 	05/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158RtNYC( cTiposAssu )

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cQuery	:= ""
	Local aTabelas	:= {}
	
	Default cTiposAssu := ""
	
	cQuery := " SELECT NYC_TABELA " + CRLF
	cQuery += " FROM " +RetSqlName("NYC") + CRLF
	cQuery += " WHERE NYC_FILIAL = '" + xFilial("NYC") + "' " + CRLF
	   	
   	If !Empty(cTiposAssu)
   		cQuery += " AND NYC_CTPASJ = '" + cTiposAssu + "' " + CRLF
   	EndIf

   	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T.)
  
  	While !(cAliasQry)->( Eof() )
  	
  		If Ascan( aTabelas, { |x| x == (cAliasQry)->NYC_TABELA } ) == 0
  			Aadd( aTabelas, (cAliasQry)->NYC_TABELA )
  		EndIf
  		
  		(cAliasQry)->( DbSkip() )	
  	EndDo 
	(cAliasQry)->( DbCloseArea() )
	  
	RestArea(aArea)

Return aTabelas

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158NZ6Cmp(cCampo)
Validacao de campos da NZ6

@param	cCampo		- Nome do campo a ser validado
@return	lRetorno	- Informa se o conteudo do campo eh valido
@author Rafael Tenorio da Costa
@since 	08/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158NZ6Cmp( cCampo, cConteudo )

	Local lRetorno := .T.
	
	cCampo		:= AllTrim( cCampo )
	cConteudo	:= AllTrim( cConteudo )
	
	Do Case
	
		Case cCampo == "NZ6_CPARAM"
		
			If !(cConteudo $ "MV_JNUMCNJ|MV_JPESPEC|MV_JAREAC|MV_JALTREG|MV_JANDAUT|MV_JATOAUT|" + ;
				"MV_JANDEXC|MV_JAJUENC|MV_JTPANAU|MV_JVLRCO|MV_JVLPROV|MV_JINVINC|MV_JFORVAR")
				lRetorno := .F.
				JurMsgErro(STR0078 + CRLF + ;
					"MV_JNUMCNJ, MV_JPESPEC, MV_JAREAC, " + CRLF + ; 
					"MV_JALTREG, MV_JINVINC, MV_JFORVAR, " + CRLF + ;
					"MV_JANDAUT, MV_JATOAUT, MV_JANDEXC, " + CRLF + ;
					"MV_JAJUENC, MV_JTPANAU, MV_JVLRCO e MV_JVLPROV")	//"Parâmetro inválido, por enquanto os parametros valídos são: "				
			EndIf
		
	End Case	

Return lRetorno

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA158F3NZN(cConfig)
Realiza o filtro de tabelas para busca dos campos usado no F3 de campos
Uso Geral. 

@param  			   	    				    
@return 

@author Wellington Coelho
@since 11/02/16
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA158F3NZN()
Local oModel   := FwModelActive()
Local cFiltro  := ""
Local cTab     := ""
Local lRet
Local cConfig  := oModel:GetValue("NZNDETAIL","NZN_TPCONF")

If EMPTY(cConfig)
	cConfig := "1"
EndIf

If cConfig == '1' //Processo
	cTab := "NSZ"
ElseIf cConfig == '2' //Envolvido
	cTab := "NT9"
ElseIf cConfig == '3' //Aditivos
	cTab := "NXY"
ElseIf cConfig == '4' //Instância
	cTab := "NUQ"
ElseIf cConfig == '5' //Valores
	cTab := "NSY"
ElseIf cConfig == '6' //Andamentos
	cTab := "NT4"
ElseIf cConfig == '7' //Acordos/Negociações
	cTab := "NYP"
ElseIf cConfig == '8' //Valores Históricos
	cTab := "NYZ"
ElseIf cConfig == '9' //Despesas
	cTab := "NT3"
ElseIf cConfig == 'A' //Garantias/Alvarás
	cTab := "NT2"
/*ElseIf cConfig == 'B' //Follow-up
	cTab := "NTA"*/
Else
	cTab := "!@#"
EndIf


cFiltro := "(X3_ARQUIVO == '" + cTab + "').AND.X3USO(X3_USADO)"

lRet := JURF3SX3( cFiltro )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA158LstNZN
Lista de opções do combo do campo NZN_TPCONF

@param cRet  Tipo

@Return Lista de opções como array ou caractere

@author Jorge Luis Branco Martins Junior
@since 29/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA158LstNZN(cRet)
Local nCont  := 0
Local aLst   := {}
Local cLst   := ""
Default cRet := "C"

aAdd(aLst,STR0082) //"1=Assuntos Jurídicos"
aAdd(aLst,STR0083) //"2=Envolvidos"
aAdd(aLst,STR0092) //"3=Aditivos"
aAdd(aLst,STR0085) //"4=Instâncias" 
aAdd(aLst,STR0086) //"5=Valores"
aAdd(aLst,STR0087) //"6=Andamentos"
aAdd(aLst,STR0088) //"7=Acordos/Negociações"
aAdd(aLst,STR0089) //"8=Valores Históricos"
aAdd(aLst,STR0090) //"9=Despesas"
aAdd(aLst,STR0091) //"A=Garantias/Alvarás"
//aAdd(aLst,STR0084) //"B=Follow-ups" - Por enquanto não será usado pois os campos do relatório de follow-up não são controlados nessa configuração e não existem campos de follow-up no relatório de processos

For nCont := 1 To Len(aLst)
	cLst += aLst[nCont]+";"
Next

cLst := Substr(cLst,1,Len(cLst)-1)

Return Iif(Upper(cRet)=="C",cLst,aLst)

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} J158VLDNZN(cCampo)
Valida os campos digitados na consulta padrão
Uso Geral. 

@param
@return 

@author Wellington Coelho
@since 11/02/16
@version 1.0
/*/
//------------------------------------------------------------------- 
Function J158VLDNZN()
Local oModel  := FwModelActive()
Local cCampo  := oModel:GetValue("NZNDETAIL","NZN_CAMPO")
Local lRet    := .F.

If (SubStr(cCampo,1,3) $ "NSZ|NT9|NUQ|NSY|NT4|NYP|NYZ|NT3|NT2|NXY") // Foi retirada a NTA pois não é usada no relatório que pode ser configurado através dessa opção.
	
	dbSelectArea('SX3')
	SX3->( dbSetOrder(2) )

	lRet := SX3->( dbSeek(cCampo) )
	
	If !lRet
		ApMsgInfo(STR0079)//Campo não encontrado no dicionario de dados
	EndIf
ElseIf Empty(AllTrim(cCampo)) 
	lRet := .T.
Else 
	ApMsgInfo(STR0080+CRLF+;
	"NSZ - "+ AllTrim(SubStr(STR0082,3,Len(STR0082)))+Chr(10)+;
	"NT9 - "+ AllTrim(SubStr(STR0083,3,Len(STR0082)))+Chr(10)+;
	"NUQ - "+ AllTrim(SubStr(STR0085,3,Len(STR0082)))+Chr(10)+;
	"NSY - "+ AllTrim(SubStr(STR0086,3,Len(STR0082)))+Chr(10)+;
	"NT4 - "+ AllTrim(SubStr(STR0087,3,Len(STR0082)))+Chr(10)+;
	"NYP - "+ AllTrim(SubStr(STR0088,3,Len(STR0082)))+Chr(10)+;
	"NYZ - "+ AllTrim(SubStr(STR0089,3,Len(STR0082)))+Chr(10)+;
	"NT3 - "+ AllTrim(SubStr(STR0090,3,Len(STR0082)))+Chr(10)+;
	"NT2 - "+ AllTrim(SubStr(STR0091,3,Len(STR0082)))+Chr(10)+;
	"NXY - "+ AllTrim(SubStr(STR0092,3,Len(STR0082)))+CRLF)
	
	//Por enquanto não será usado pois os campos do relatório de follow-up não são controlados nessa configuração e não existem campos de follow-up no relatório de processos
	//"NTA - "+ AllTrim(SubStr(STR0084,3,Len(STR0082)))+Chr(10)+;
	
	//São permitidos campos das tabelas: NSZ|NT9|NTA|NUQ|NSY|NT4|NYP|NYZ|NT3|NT2|NXY
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J158FTPREL()
Filtro da consulta padrão NQYNYB, para exibir apenas configurações de 
relatório que sejam do assunto posicionado

Uso Geral. 

@return 

@author Jorge Luis Branco Martins Junior
@since 09/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J158FTPREL()
Local aArea     := GetArea()
Local cCodCon   := J158FltNQY()
Local cRet      := "@#@#"

cRet := "@#NQY->NQY_COD $ '"+cCodCon+"' @#"

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J158VLDREL()
Valid do campo de configuração do relatório na aba de relatórios, 
para permitir apenas configurações de relatório que sejam do 
assunto posicionado

Uso Geral. 

@return 

@author Jorge Luis Branco Martins Junior
@since 09/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J158VLDREL()
Local aArea     := GetArea()
Local cCodCon   := J158FltNQY()
Local lRet      := .F.

lRet := M->NZN_CFGREL $ cCodCon

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J158FltNQY()
Filtro para exibir apenas configurações de relatório que sejam do 
assunto posicionado
 
Uso Geral. 

@return 

@author Jorge Luis Branco Martins Junior
@since 09/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J158FltNQY()
Local cQuery    := ""
Local cAliasQry := Nil
Local cCodCon   := ""

cQuery := " SELECT NQY.NQY_COD CODCON FROM " + RetSqlName("NQY") + " NQY " 
cQuery +=   " INNER JOIN " + RetSqlName("NQR") + " NQR ON( "
cQuery +=     " NQR.NQR_FILIAL = '"+xFilial("NQR")+"' AND "
cQuery +=     " NQY.D_E_L_E_T_ = NQR.D_E_L_E_T_ AND "
cQuery +=     " NQY.NQY_CRPT = NQR.NQR_COD AND "
cQuery +=     " NQR.NQR_EXTENS = '3' ) "
cQuery +=   " INNER JOIN " + RetSqlName("NVL") + " NVL ON( "
cQuery +=     " NVL.NVL_FILIAL = '"+xFilial("NVL")+"' AND "
cQuery +=     " NQY.D_E_L_E_T_ = NVL.D_E_L_E_T_ AND "
cQuery +=     " NVL.NVL_CODCON = NQY_COD AND "
cQuery +=     " NVL.NVL_CTIPOA = '"+M->NYB_COD+"' ) "
cQuery +=   " WHERE NQY.D_E_L_E_T_ = ' ' "
cQuery +=     " AND NQY.NQY_FILIAL = '"+xFilial("NQY")+"'"

cAliasQry := GetNextAlias()
cQuery    := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
(cAliasQry)->( dbGoTop() )

	If !(cAliasQry)->(EOF())
		While !(cAliasQry)->(EOF())
			cCodCon += (cAliasQry)->CODCON + "|"
			(cAliasQry)->( dbSkip() )
		EndDo

	EndIf

	(cAliasQry)->(dbCloseArea())

Return cCodCon

//-------------------------------------------------------------------
/*/{Protheus.doc} J158AllDel()
Seta uma tabela na configuração para possibilitar a remoção de 
todos os campos.
Uso Geral. 
@return 
@author Andreia Lima
@since 09/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J158AllDel(oGrupList)

If Empty(oGrupList:GetTabela())
	oGrupList:SetTabela("NSZ")
EndIf

oGrupList:AllToDisp()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J158GChav

Função que retorna a tabela selecionada no F3

@Return _cChavSX2 variável com a tabela selecionada

@author Beatriz Gomes
@since 14/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J158GChav()
Return _cChavSX2
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JAEXCNSY
Verifica se o assunto juridico poderá configurar a NSY
Uso Geral. 

@return aRet Array de tabelas

@author Brenno Gomes
@since 05/11/2018
@version 1.0
/*/
//------------------------------------------------------------------- 
Static Function JAEXCNSY(cAssJur)

Local cQuery   := ""
Local cAlias   := GetNextAlias()
Local aArea    := GetArea()
Local aRet     := {}

	cQuery += "SELECT NYB.NYB_COD "
	cQuery += "FROM " + RetSqlName('NYB') +" NYB "
	cQuery += "WHERE (NYB.NYB_COD IN ('001','002','003','004')"
	cQuery += "OR NYB_CORIG IN ('001','002','003','004'))"
	cQuery += "AND NYB.NYB_COD = '" + cAssJur + "'"

	cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
		(cAlias)->( dbGoTop() )
	If !(cAlias)->( EOF() )
		aRet := {'NSY'+"=",AllTrim(JA023TIT('NSY')) + " (" + "NSY" + ")","NSY","NSY"} //tabela de Andamentos NT4
	EndIf

Return aRet

