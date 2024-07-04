#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TECA742.CH" 

Static aBase := {}
Static aLoca := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} TECA742
Programa de Consulta de Disponibilidade
@author Filipe Gonçalves
@since 22/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function TECA742()

Local oBrowse := FWMBrowse():New()
oBrowse:SetAlias('TFI')
oBrowse:SetDescription(STR0001)
oBrowse:Activate()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author Filipe Gonçalves
@since 22/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002   ACTION "VIEWDEF.TECA742"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //"Visualizar"

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Filipe Gonçalves
@since 22/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel	:= NIL
Local oStruTFI	:= FWFormModelStruct():New()	
Local oStruAA3	:= FWFormModelStruct():New()	

oStruTFI:AddTable("   ",{" "}," ")
oStruAA3:AddTable("   ",{" "}," ")

//|-------------------------------------------------|
//| GERAÇÃO DA ESTRUTURA DE LOCAÇÃO DE EQUIPAMENTOS |
//|-------------------------------------------------|
If Empty(aLoca)
	aAdd(aLoca,{'TMP_PRODUT','C',TamSX3('TFI_PRODUT')[1],PesqPict('TFI','TFI_PRODUT'),STR0006,STR0006,{},"SB5TFI",Nil,{|a,b,c,d| TC742CARGA(a,b,c,d,'TMP')},NIl ,.T.} )
	aAdd(aLoca,{'TMP_DESCRI','C',TamSX3('TFI_DESCRI')[1],PesqPict('TFI','TFI_DESCRI'),STR0007,STR0007,{},/*F3*/  ,Nil,/*bValid*/,Nil ,.F.} )
	aAdd(aLoca,{'TMP_PERINI','D',TamSX3('TFI_PERINI')[1],PesqPict('TFI','TFI_PERINI'),STR0015,STR0015,{},/*F3*/  ,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aLoca,{'TMP_PERFIM','D',TamSX3('TFI_PERFIM')[1],PesqPict('TFI','TFI_PERFIM'),STR0016,STR0016,{},/*F3*/  ,Nil,/*bValid*/,NIl ,.F.} )
EndIf
T742Model(aLoca,"STRU1_",oStruTFI)

//|---------------------------------------------|
//| GERAÇÃO DA ESTRUTURA DE BASE DE ATENDIMENTO |
//|---------------------------------------------|
If Empty(aBase)
	aAdd(aBase,{'TMP1_CODPRO' ,'C',TamSX3('AA3_CODPRO')[1]	,PesqPict('AA3','AA3_CODPRO')	,STR0006,STR0006,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aBase,{'TMP1_DESPRO' ,'C',TamSX3('AA3_DESPRO')[1]	,PesqPict('AA3','AA3_DESPRO')	,STR0007,STR0007,{},/*F3*/,Nil,/*bValid*/,Nil ,.F.} )
	aAdd(aBase,{'TMP1_NUMSER' ,'C',TamSX3('AA3_NUMSER')[1]	,PesqPict('AA3','AA3_NUMSER')	,STR0008,STR0008,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aBase,{'TMP1_EXIGNF' ,'C',TamSX3('AA3_EXIGNF')[1]	,PesqPict('AA3','AA3_EXIGNF')	,STR0009,STR0009,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aBase,{'TMP1_MANPRE' ,'C',TamSX3('AA3_MANPRE')[1]	,PesqPict('AA3','AA3_MANPRE')	,STR0010,STR0010,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aBase,{'TMP1_CBASE'  ,'C',TamSX3('AA3_CBASE')[1]	,PesqPict('AA3','AA3_CBASE')	,STR0011,STR0011,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aBase,{'TMP1_ITEM'   ,'C',TamSX3('AA3_ITEM')[1]	,PesqPict('AA3','AA3_ITEM')		,STR0012,STR0012,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aBase,{'TMP1_CHAPA'  ,'C',TamSX3('AA3_CHAPA')[1]	,PesqPict('AA3','AA3_CHAPA')	,STR0013,STR0013,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
	aAdd(aBase,{'TMP1_MODELO' ,'C',TamSX3('AA3_MODELO')[1]	,PesqPict('AA3','AA3_MODELO')	,STR0014,STR0014,{},/*F3*/,Nil,/*bValid*/,NIl ,.F.} )
EndIf
T742Model(aBase,"STRU2_",oStruAA3)

//-- Cria a estrutura basica
oModel := MPFormModel():New('TECA742',/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)

//³Adiciona Cabeçalho³
oModel:AddFields( 'TFIMASTER', /*cOwner*/, oStruTFI,/*bPreValid*/,/*bPosValid*/,/*Carga*/)

//³Adiciona Grids³
oModel:AddGrid('AA3DETAIL' ,'TFIMASTER', oStruAA3,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)

oModel:SetPrimaryKey({})

oModel:GetModel("TFIMASTER"):SetOnlyQuery(.T.)
oModel:GetModel("AA3DETAIL"):SetOnlyQuery(.T.)

oModel:GetModel('TFIMASTER'):SetDescription(STR0003)//'Locação de Equipamentos'
oModel:GetModel('AA3DETAIL'):SetDescription(STR0004)//'Base de Atendimento'

oModel:SetDescription(STR0005)//'Consulta de Disponibilidade'

oModel:GetModel("AA3DETAIL"):SetNoDeleteLine(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados

@author Filipe Gonçalves
@since 22/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel("TECA742")
Local oStruTFI	:= FWFormViewStruct():New()
Local oStruAA3	:= FWFormViewStruct():New()
Local oView		:= FWFormView():New()

T742View(aLoca ,'TMP_' ,oStruTFI)
T742View(aBase  ,'TMP1_',oStruAA3)

//-- Define qual o modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField( 'VIEW_TFI' , oStruTFI,	'TFIMASTER'	)
oView:AddGrid(	'VIEW_AA3' , oStruAA3,	'AA3DETAIL'	)

//-- Divide a tela nas partes a utilizar
oView:CreateHorizontalBox( 'CABEC',20 )
oView:CreateHorizontalBox( 'GRID',80    )


oView:SetOwnerView( 'VIEW_TFI'	, 'CABEC')
oView:SetOwnerView( 'VIEW_AA3'	, 'GRID'	)

oView:EnableTitleView("VIEW_AA3", STR0005)

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} T742Model
Função para adicionar dinamicamente os campos na estrutura

@param aCampos Estrutura dos campos que serão adicionados
@param cStru Descrição da estrutura onde os campos serão adicionados
@param oStru Objeto referente a estrutura

@author filipe.goncalves

@since 27/01/2016
@version 12.1.11
/*/
//-------------------------------------------------------------------
Function T742Model(aCampos,cStru,oStru)
Local nCampo := 1
Local cCampo := ''

For nCampo := 1 To Len(aCampos)
	//cCampo := cStru + aCampos[nCampo][01]
	//-- Adiciona campos header do filtro de busca de fornecedor 
	oStru:AddField(aCampos[nCampo][05]		,;	// 	[01]  C   Titulo do campo
				 	aCampos[nCampo][06]		,;	// 	[02]  C   ToolTip do campo
				 	aCampos[nCampo][01]		,;	// 	[03]  C   Id do Field
				 	aCampos[nCampo][02]		,;	// 	[04]  C   Tipo do campo
				 	aCampos[nCampo][03]		,;	// 	[05]  N   Tamanho do campo
				 	0						,;	// 	[06]  N   Decimal do campo
				 	aCampos[nCampo][10]		,;	// 	[07]  B   Code-block de validação do campo
				 	aCampos[nCampo][09]		,;	// 	[08]  B   Code-block de validação When do campo
				 	aCampos[nCampo][07]		,;	//	[09]  A   Lista de valores permitido do campo
				 	.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	aCampos[nCampo][11]		,;	//	[11]  B   Code-block de inicializacao do campo
				 	NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
				 	.F.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.F.						)	// 	[14]  L   Indica se o campo é virtual
Next nCampo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T742View
Função para adicionar dinamicamente os campos na view

@param aCampos Estrutura dos campos que serão adicionados
@param cStru Descrição da estrutura onde os campos serão adicionados
@param oStru Objeto referente a estrutura

@author filipe.goncalves

@since 27/01/2016
@version 12.1.11
/*/
//-------------------------------------------------------------------

Function T742View(aCampos,cStru,oStru)
Local nCampo := 0
Local cCampo := ''

For nCampo := 1 To Len(aCampos)
	//--> [01] - campo, [02] - tipo, [03] - tamanho, [04] mascara, [05] - descrição, [06] - titulo, [07] - combo, [08] - consulta padrão, [09] - bWhen, [10] - bValid, [11] bInit
	//cCampo := cStru + aCampos[nCampo][01]
	cOrdem := StrZero(nCampo,2)
	//-- Adiciona campos header do filtro de busca de fornecedor 
	oStru:AddField(aCampos[nCampo][01]		,;	// [01]  C   Nome do Campo
					cOrdem					,;	// [02]  C   Ordem
					aCampos[nCampo][05] 	,;	// [03]  C   Titulo do campo
					aCampos[nCampo][06] 	,;	// [04]  C   Descricao do campo
					{}						,;	// [05]  A   Array com Help
					aCampos[nCampo][02]		,;	// [06]  C   Tipo do campo
					aCampos[nCampo][04]		,;	// [07]  C   Picture
					NIL						,;	// [08]  B   Bloco de Picture Var
					aCampos[nCampo][08]		,;	// [09]  C   Consulta F3
					aCampos[nCampo][12]		,;	// [10]  L   Indica se o campo é alteravel
					NIL						,;	// [11]  C   Pasta do campo
					NIL						,;	// [12]  C   Agrupamento do campo
					aCampos[nCampo][07]		,;	// [13]  A   Lista de valores permitido do campo (Combo)
					2						,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL						,;	// [15]  C   Inicializador de Browse
					.F.						,;	// [16]  L   Indica se o campo é virtual
					NIL						,;	// [17]  C   Picture Variavel
					.F.						)	// [18]  L   Indica pulo de linha após o campo
Next nCampo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AT742LOAD
Função para fazer a carga no cabeçalho

@author Filipe Gonçalves
@since 26/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function AT742LOAD(oModel, oModConsu)
Local aArea			:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local oModelCab		:= oModConsu:GetModel('TFIMASTER')
Local oModelTFI		:= oModel:GetModel('TFI_LE')
Local cProd			:= oModelTFI:GetValue('TFI_PRODUT')
Local dDtIni		:= oModelTFI:GetValue('TFI_PERINI')
Local dDtFim		:= oModelTFI:GetValue('TFI_PERFIM')
Local cDesc			:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")

oModelCab:SetValue('TMP_PERINI',dDtIni)
oModelCab:SetValue('TMP_PERFIM',dDtFim)
oModelCab:SetValue('TMP_PRODUT',cProd)
oModelCab:SetValue('TMP_DESCRI',cDesc)

 
RestArea(aArea)
FWRestRows( aSaveLines )

Return oModConsu

//-------------------------------------------------------------------
/*/{Protheus.doc} AT742LOAD
Função para fazer a carga na grid ao setar o produto

@author Filipe Gonçalves
@since 26/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function TC742CARGA(oModMaster,cField,cValue,xOldValue,cPrefix)
Local aArea			:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local oModelGrid	:= oModel:GetModel('AA3DETAIL')
Local dDtIni		:= oModMaster:GetValue('TMP_PERINI')
Local dDtFim		:= oModMaster:GetValue('TMP_PERFIM')
Local cProd			:= oModMaster:GetValue('TMP_PRODUT')
Local cTmpQry		:= ""
Local cQryDesc		:= ""
Local xProdSel		:= Nil
Local lRet			:= .T.

CNTA300DlMd(oModelGrid,'TMP1_CODPRO')

If ( lResKit := At810IsKit( xFilial('TEZ')+cValue ) )
	aCompKit := At810GetKit( xFilial('TEZ')+cValue )
	xProdSel := {}
	aResVld  := {}
	AEval( aCompKit, {|x| aAdd( xProdSel, x[1] ) } )
Else
	xProdSel := cValue
EndIf

cTmpQry := At180xDisp( xProdSel, dDtIni, dDtFim )

While (cTmpQry)->(!EOF())
	If !Empty(oModelGrid:GetValue('TMP1_CODPRO')) // Não é primeira linha
		oModelGrid:AddLine()					          		                       				
	EndIf
	cQryDesc := Posicione("SB1",1,xFilial("SB1")+(cTmpQry)->AA3_CODPRO,"B1_DESC")
	oModelGrid:SetValue('TMP1_CODPRO',(cTmpQry)->AA3_CODPRO)
	oModelGrid:SetValue('TMP1_DESPRO',cQryDesc)
	oModelGrid:SetValue('TMP1_NUMSER',(cTmpQry)->AA3_NUMSER)
	oModelGrid:SetValue('TMP1_EXIGNF',(cTmpQry)->AA3_EXIGNF)
	oModelGrid:SetValue('TMP1_MANPRE',(cTmpQry)->AA3_MANPRE)
	oModelGrid:SetValue('TMP1_CBASE',(cTmpQry)->AA3_CBASE)
	oModelGrid:SetValue('TMP1_ITEM',(cTmpQry)->AA3_ITEM)
	oModelGrid:SetValue('TMP1_CHAPA',(cTmpQry)->AA3_CHAPA)
	oModelGrid:SetValue('TMP1_MODELO',(cTmpQry)->AA3_MODELO)
	(cTmpQry)->(dbSkip())
End

(cTmpQry)->(DbCloseArea())

RestArea(aArea)
FWRestRows( aSaveLines )

Return lRet