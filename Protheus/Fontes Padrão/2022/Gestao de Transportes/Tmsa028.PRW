#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA028.CH"

//-------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} TMSA028
@autor		: Eduardo Alberti
@descricao	: Funcao principal da rotina para cadastramento das divergencias entre Classes de Risco De Produtos
@since		: Oct./2014
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA028()

	Local oMBrowse	:= Nil
	Local aArea		:= GetArea()

	Private aRotina	:= MenuDef()

	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If !(AliasInDic("DDT"))
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('DDT')
	oMBrowse:SetDescription( STR0001 )	// 'Divergencias Das Classes De Risco/Grupo Embalagens'
	oMBrowse:DisableDetails()

	oMBrowse:Activate()

	RestArea(aArea)

Return NIL
//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Funcao Para Montagem Do Menu Funcional Padrao Protheus
@since		: Oct./2014
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	:
*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aArea		:= GetArea()
Local aRotina 	:= {}

ADD OPTION aRotina TITLE STR0002  	ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 DISABLE MENU	// 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.TMSA028' OPERATION 2 ACCESS 0 DISABLE MENU	// 'Visualizar'
ADD OPTION aRotina TITLE STR0004  	ACTION 'VIEWDEF.TMSA028' OPERATION 3 ACCESS 0					// 'Incluir'
ADD OPTION aRotina TITLE STR0005  	ACTION 'VIEWDEF.TMSA028' OPERATION 4 ACCESS 0 DISABLE MENU	// 'Alterar'
ADD OPTION aRotina TITLE STR0006  	ACTION 'VIEWDEF.TMSA028' OPERATION 5 ACCESS 0 DISABLE MENU	// 'Excluir'
ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.TMSA028' OPERATION 8 ACCESS 0 DISABLE MENU	// 'Imprimir'
ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.TMSA028' OPERATION 9 ACCESS 0 DISABLE MENU	// 'Copiar'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CDDDTMNU")
	ExecBlock("CDDDTMNU",.F.,.F.)
EndIf

RestArea(aArea)

Return aRotina
//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} ModelDef
@autor		: Eduardo Alberti
@descricao	: Modelo de Dados
@since		: Oct./2014
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	    :
*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local aArea		:= GetArea()
Local oStructCab 	:= Nil
Local oStructVie 	:= Nil
Local oModel     	:= Nil

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructCab := FWFormStruct(1,"DDT",{|cCampo|  AllTrim(cCampo)+"|" $ "DDT_RISCOP|DDT_DESCRP|DDT_GREMBP|DDT_DCEMBP|"})
oStructVie := FWFormStruct(1,"DDT",{|cCampo| !AllTrim(cCampo)+"|" $ "DDT_RISCOP|DDT_DESCRP|DDT_GREMBP|DDT_DCEMBP|"})

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New("MSTMSA028", /*Pré-Validação*/, { |oMdl| DDTPosVl( oMdl ) }/*Pos-Validacao*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields("TMSA028_CAB",/*cOwner*/, oStructCab)

oModel:SetPrimaryKey({"DDT_FILIAL","DDT_RISCOP","DDT_GREMBP","DDT_RISCOI","DDT_GREMBI"})

oModel:GetModel("TMSA028_CAB"):SetDescription( STR0001 )	// "Divergências Das Classes De Risco/Grupo Embalagens"

oModel:AddGrid("TMSA028_ITM", "TMSA028_CAB", oStructVie,/*bLinePre*/, { |oMdlG,nLine| PosVldDDt( oMdlG, nLine) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:GetModel("TMSA028_ITM"):SetDescription( STR0009 )	// "Itens De Incompatibilidade"

oModel:SetRelation("TMSA028_ITM",{		{"DDT_FILIAL","FWxFilial('DDT')"},;
											{"DDT_RISCOP","DDT_RISCOP"},;
											{"DDT_GREMBP","DDT_GREMBP"} ;
											}, DDT->(IndexKey(1)) )

oModel:GetModel( "TMSA028_ITM" ):SetUniqueLine( { "DDT_RISCOI","DDT_GREMBI" } )

//oModel:GetModel("TMSA028_ITM"):SetNoInsertLine(.F.)

RestArea(aArea)

Return(oModel)
//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} ModelDef
@autor		: Eduardo Alberti
@descricao	: Retorna a View (tela) da rotina
@since		: Oct./2014
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	    :
*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local aArea		:= GetArea()
Local oView		:= Nil
Local oStructCAB	:= Nil
Local oStructVie	:= Nil
Local oModel     	:= FWLoadModel("TMSA028")

oStructCab := FwFormStruct( 2,"DDT", { |cCampo|  AllTrim( cCampo ) + "|" $ "DDT_RISCOP|DDT_DESCRP|DDT_GREMBP|DDT_DCEMBP|" } )
oStructVie := FwFormStruct( 2,"DDT", { |cCampo| !AllTrim( cCampo ) + "|" $ "DDT_RISCOP|DDT_DESCRP|DDT_GREMBP|DDT_DCEMBP|" } )

oView := FWFormView():New()
oView:SetModel(oModel)
oView:EnableControlBar(.T.)

oView:AddField( "TMSA028_CAB",oStructCab)
oView:CreateHorizontalBox("CABEC",25)
oView:SetOwnerView( "TMSA028_CAB","CABEC")

oView:AddGrid("TMSA028_ITM",oStructVie)
oView:CreateHorizontalBox("GRID",75)
oView:SetOwnerView( "TMSA028_ITM","GRID")

RestArea(aArea)

Return oView
//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} DDTPosVl
@autor		: Eduardo Alberti
@descricao	: Validação Do Campo DDT_GREMBP Acionada Apos Selecionar o Botao "Confirma"
@since		: Oct./2014
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	:
*/
//-------------------------------------------------------------------------------------------------
//Static Function DDTPosVl(oModel)
Function DDTPosVl(oModel)

Local lRet       	:= .T.
Local aArea	 	:= GetArea()
Local nOperation 	:= 0 //oModel:GetOperation()
Local cTmp       	:= ""
Local cQuery     	:= ""
Local cCodPrc		:= ""
Local cEmpPrc		:= ""

Default oModel	:= FWModelActive()

nOperation 		:= oModel:GetOperation()

// Validacao Do Cabeçalho Para Não Permitir Duplicidades
If nOperation == 3 // Inclusao

	cTmp		:= GetNextAlias()
	cCodPrc 	:= oModel:GetValue( 'TMSA028_CAB', 'DDT_RISCOP')
	cEmpPrc 	:= oModel:GetValue( 'TMSA028_CAB', 'DDT_GREMBP')

	cQuery := "SELECT		DDT.R_E_C_N_O_ "
	cQuery += "FROM 		" + RetSqlTab('DDT') + " "
	cQuery += "WHERE 		DDT.DDT_FILIAL = '" + xFilial("DDT") 	+ "' "
	cQuery += "AND 		DDT.DDT_RISCOP = '" + cCodPrc 			+ "' "
	cQuery += "AND 		DDT.DDT_GREMBP = '" + cEmpPrc 			+ "' "
	cQuery += "AND 		DDT.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .T.)

	If	(cTmp)->(!Eof())

		lRet := .F.
		Help( ,, 'HELP',, STR0010 + cCodPrc + ' / ' + cEmpPrc + '.', 1, 0 )	// 'Já Existe Cadastro Efetuado Para o Código: '

	EndIf

	If Select(cTmp) > 0
		(cTmp)->(dbcloseArea())
	EndIf

EndIf

RestArea(aArea)

Return lRet
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosVldDDt
@autor		: Eduardo Alberti
@descricao	: Funcao Para Validação Da Linha Do Grid Apos Digitacao
@since		: Oct./2014
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	:
/*/
//------------------------------------------------------------------------------------------------
Static Function PosVldDDt( oModelGrid, nLinha)

Local aArea		:= GetArea()
Local lRet   		:= .T.
Local oModel     	:= oModelGrid:GetModel()
Local nOperation 	:= oModel:GetOperation()

// Validação Da Linha Do Grid Apos Digitacao
If nOperation == 3 .Or. nOperation == 4

	cCodPrc := oModel:GetValue( 'TMSA028_CAB', 'DDT_RISCOP')
	cEmpPrc := oModel:GetValue( 'TMSA028_CAB', 'DDT_GREMBP')
	cCodInc := oModel:GetValue( 'TMSA028_ITM', 'DDT_RISCOI')
	cEmbInc := oModel:GetValue( 'TMSA028_ITM', 'DDT_GREMBI')

	If cCodPrc == cCodInc .And. cEmpPrc == cEmbInc
		lRet := .F.
		Help('',1,'TMSA02801')	// "Código De Incompatibilidade/Grupo Embalagens é o Mesmo Que o Código Principal!"
	EndIf
EndIf

// Executa Mesma Validacao De Quando Confirma a Tela De Inclusão
If lRet

	DDTPosVl(oModel)

EndIf

RestArea(aArea)

Return lRet
