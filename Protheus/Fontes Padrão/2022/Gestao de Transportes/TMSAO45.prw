#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'
#include 'TMSAO45.ch'
#Include 'MSGRAPHI.CH'

#DEFINE RETSTATUS 	1
#DEFINE RETFILORI 	2
#DEFINE RETVGE 		3
#DEFINE RETNUMSIM 	4
#DEFINE RETTABFRE 	5
#DEFINE RETTIPTAB	6
#DEFINE RETTABCAR	7
#DEFINE RETVALRCT	8
#DEFINE RETVALTMS	9
#DEFINE RETVALGFE	10
#DEFINE RETVALTOT	11
#DEFINE RETPERCUS	12
#DEFINE RETRENTAB	13

Static cAliasTmp		:= ""
Static oGraphic1		:= Nil
Static oGraphic2		:= Nil
Static PESO_TOT			:= 0
Static PESOM3_TOT		:= 0
Static PESOM3REAL		:= 0
Static VALMER_TOT		:= 0
Static QTDVOL_TOT		:= 0
Static VLR_PERCUS		:= 0
Static VLR_RECEBER		:= 0
Static VLR_PAGTMS		:= 0
Static VLR_PAGGFE		:= 0
Static VLR_PAGTOT		:= 0
Static aSetKey			:= LoadSetKey()

/*/{Protheus.doc} TMSAO45
//Rentabilidade Prévia
@author caio.y
@since 04/07/2017
@version undefined

@type function
/*/
Function TMSAO45()
Local oBrowse	:= Nil

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'DL3' )
oBrowse:DisableDetails()
oBrowse:SetDescription( STR0007 ) //-- Rentabilidade Prévia
oBrowse:AddLegend( "DL3->DL3_RENTAB > DL3->DL3_PERCUS"	, "BR_VERDE"	, STR0034  )	//-- "Rentabilidade acima do esperado"
oBrowse:AddLegend( "DL3->DL3_RENTAB == DL3->DL3_PERCUS"	, "BR_AMARELO"  , STR0035   )	//-- "Rentabilidade igual ao esperado"
oBrowse:AddLegend( "DL3->DL3_RENTAB < DL3->DL3_PERCUS"	, "BR_VERMELHO" , STR0036   ) 	//-- "Rentabilidade abaixo do esperado"
oBrowse:Activate()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author caio.y
@since 17/04/2017
@version undefined

@type function
/*/
Static Function ModelDef()
Local oModel		:= Nil
Local bPosValid		:= {|oModel|PosVldMdl(oModel)}
Local bCommit		:= {|oModel|CommitMdl(oModel)}
Local bCancel		:= {|oModel|CancelMdl(oModel)}
Local bPre			:= Nil
Local oStruSim		:= Nil //-- Estrutura da Simulação
Local oStruRes		:= Nil //-- Estrutura Resumo de Cálculo
Local oStruDev		:= Nil //-- Estrutura Pagadores
Local oStruNf		:= Nil //-- Estrutura Notas Fiscais
Local oStruDoc		:= Nil //-- Estrutura Conhecimentos
Local oStruGfe		:= Nil //-- Estrutura Trechos GFE

Pergunte("TMSAO45",.F.)

/*------------------------------------------
//-- Monta estruturas
------------------------------------------*/
oStruSim	:= RetStrSim("1")
oStruRes	:= RetStrRes("1")
oStruDev	:= RetStrDev("1")
oStruDoc	:= RetStrDoc("1")
oStruNf		:= RetStrNf("1")
oStruGfe	:= RetStrGfe("1")

/*------------------------------------------
//-- Inicializa Modelo de Dados
------------------------------------------*/
oModel := MPFormModel():New( "TMSAO45", bPre , bPosValid , bCommit , bCancel )

/*------------------------------------------
//-- Inicializa Cabeçalho
------------------------------------------*/
oModel:AddFields( 'MdFieldSim',, oStruSim , /*bPre*/, /*bPost*/, {|oModel,lCopy|LoadField(oModel,lCopy)} )
oModel:GetModel("MdFieldSim"):SetForceLoad(.T.)

/*------------------------------------------
//-- Inicializa Grid Resumo Cálculo
------------------------------------------*/
oModel:AddGrid("MdGridRes" , "MdFieldSim" , oStruRes, , , , , {|oModel,lCopy|LoadGrid(oModel,lCopy,"MdGridRes") }  )
oModel:SetRelation("MdGridRes",{{"FILIAL","xFilial('DEV')" },{"NUMSIM","NUMSIM"} }  )
oModel:GetModel("MdGridRes"):SetDescription(STR0008) //-- Resumo Cálculo
oModel:SetOptional("MdGridRes",.T.)
oModel:GetModel("MdGridRes"):SetForceLoad(.T.)
oModel:GetModel("MdGridRes"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridRes"):SetNoDeleteLine(.T.)
oModel:GetModel("MdGridRes"):SetOnlyQuery(.T.)
oModel:GetModel("MdGridRes"):SetMaxLine(999)

/*------------------------------------------
//-- Inicializa Grid Pagador
------------------------------------------*/
oModel:AddGrid("MdGridDev" , "MdFieldSim" , oStruDev, , , , , {|oModel,lCopy|LoadGrid(oModel,lCopy,"MdGridDev") }  )
oModel:SetRelation( "MdGridDev",{{"FILIAL","xFilial('DEV')" },{"NUMSIM","NUMSIM"} }  )
oModel:GetModel("MdGridDev"):SetDescription(STR0009) //-- Rentabilidade por Pagador
oModel:SetOptional("MdGridDev",.T.)
oModel:GetModel("MdGridDev"):SetForceLoad(.T.)
oModel:GetModel("MdGridDev"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridDev"):SetNoDeleteLine(.T.)
oModel:GetModel("MdGridDev"):SetOnlyQuery(.T.)
oModel:GetModel("MdGridDev"):SetMaxLine(999)

/*------------------------------------------
//-- Inicializa Grid Conhecimentos
------------------------------------------*/
oModel:AddGrid("MdGridDoc" , "MdFieldSim" , oStruDoc, , , , , {|oModel,lCopy|LoadGrid(oModel,lCopy,"MdGridDoc") }  )
oModel:SetRelation( "MdGridDoc",{{"FILIAL","xFilial('DT6')" },{"NUMSIM","NUMSIM"} }  )
oModel:GetModel("MdGridDoc"):SetDescription(STR0010) //-- Rentabilidade por Conhecimento
oModel:SetOptional("MdGridDoc",.T.)
oModel:GetModel("MdGridDoc"):SetForceLoad(.T.)
oModel:GetModel("MdGridDoc"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridDoc"):SetNoDeleteLine(.T.)
oModel:GetModel("MdGridDoc"):SetOnlyQuery(.T.)
oModel:GetModel("MdGridDoc"):SetMaxLine(999)

/*------------------------------------------
//-- Inicializa Grid Notas Fiscais do Cliente
------------------------------------------*/
oModel:AddGrid("MdGridNf" , "MdFieldSim" , oStruNf, , , , , {|oModel,lCopy|LoadGrid(oModel,lCopy,"MdGridNf") }  )
oModel:SetRelation( "MdGridNf",{{"FILIAL","xFilial('DTC')" },{"NUMSIM","NUMSIM"} }  )
oModel:GetModel("MdGridNf"):SetDescription(STR0011) //-- Notas Fiscais Cliente
oModel:SetOptional("MdGridNf",.T.)
oModel:GetModel("MdGridNf"):SetForceLoad(.T.)
oModel:GetModel("MdGridNf"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridNf"):SetNoDeleteLine(.T.)
oModel:GetModel("MdGridNf"):SetOnlyQuery(.T.)
oModel:GetModel("MdGridNf"):SetMaxLine(999)

/*------------------------------------------
//-- Inicializa Grid Trechos GFE
------------------------------------------*/
oModel:AddGrid("MdGridGfe" , "MdGridDoc" , oStruGfe, , , , , {|oModel,lCopy|LoadGrid(oModel,lCopy,"MdGridGfe") }  )
oModel:GetModel("MdGridGfe"):SetDescription(STR0012 + " " + RTrim(mv_par02) ) //-- Trechos de Transporte ETC
oModel:SetOptional("MdGridGfe",.T.)
oModel:GetModel("MdGridGfe"):SetForceLoad(.T.)
oModel:GetModel("MdGridGfe"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridGfe"):SetNoDeleteLine(.T.)
oModel:GetModel("MdGridGfe"):SetMaxLine(999)
oModel:SetRelation( "MdGridGfe", { {"FILIAL","xFilial('DJN')" },{"NUMSIM","NUMSIM"}, {'FILORI','FILORI'} , {'VIAGEM','VIAGEM'} })

oModel:SetPrimaryKey( {"FILIAL","NUMSIM" } )
oModel:SetActivate({|oModel|AO35Act(oModel)})

Return oModel

/*/{Protheus.doc} ViewDef
//View Def
@author caio.y
@since 17/04/2017
@version undefined

@type function
/*/
Static Function ViewDef()

Local oView			:= Nil
Local oStruRes		:= Nil
Local oStruDev		:= Nil
Local oStruDoc		:= Nil
Local oStruNf		:= Nil
Local oStruGfe		:= Nil
Local oStruSim		:= Nil
Local oModel		:= Nil

PESO_TOT	:= 0
PESOM3_TOT	:= 0
PESOM3REAL	:= 0
VLR_RECEBER	:= 0
VLR_PAGTMS	:= 0
VLR_PAGGFE	:= 0
VLR_PAGTOT	:= 0
VLR_PERCUS	:= 0
VALMER_TOT	:= 0
QTDVOL_TOT	:= 0

oModel := FwLoadModel("TMSAO45")

/*------------------------------------------
//-- Monta estruturas
------------------------------------------*/
oStruSim	:= RetStrSim("2")
oStruRes	:= RetStrRes("2")
oStruDev	:= RetStrDev("2")
oStruDoc	:= RetStrDoc("2")
oStruNf		:= RetStrNf("2")
oStruGfe	:= RetStrGfe("2")

/*------------------------------------------
//-- Inicializa ViewDef
------------------------------------------*/
oView := FwFormView():New()
oView:SetModel(oModel)

/*------------------------------------------
//-- Incializa cabeçalho
------------------------------------------*/
oView:AddField( 'VwFieldSim'  , oStruSim  , 'MdFieldSim' )

/*------------------------------------------
//-- Inicializa Grid Resumo
------------------------------------------*/
oView:AddGrid('VwGridRes',oStruRes,'MdGridRes')
oView:EnableTitleView("VwGridRes")

/*------------------------------------------
//-- Inicializa Grid Devedores
------------------------------------------*/
oView:AddGrid('VwGridDev',oStruDev,'MdGridDev')
oView:EnableTitleView("VwGridDev")

/*------------------------------------------
//-- Inicializa Grid Conhecimentos
------------------------------------------*/
oView:AddGrid('VwGridDoc',oStruDoc,'MdGridDoc')
oView:EnableTitleView("VwGridDoc")

/*------------------------------------------
//-- Inicializa Grid Notas Fiscais do Cliente
------------------------------------------*/
oView:AddGrid('VwGridNf',oStruNf,'MdGridNf')
oView:EnableTitleView("VwGridNf")

/*------------------------------------------
//-- Inicializa Grid Trechos GFE
------------------------------------------*/
oView:AddGrid('VwGridGfe',oStruGfe,'MdGridGfe')
oView:EnableTitleView("VwGridGfe")

/*------------------------------------------
//-- Inicializa Gráficos
------------------------------------------*/
oView:AddOtherObject( "VwGraphic1", { |oGraphic| AO45Graf1( oGraphic ) } )
oView:AddOtherObject( "VwGraphic2", { |oGraphic| AO45Graf2( oGraphic ) } )
oView:AddOtherObject( "VwTree", { |oView| MontaTree( oView ) } )
oView:EnableTitleView( 'VwGraphic1' ,STR0024  ) //--"Rentabilidade Total"
oView:EnableTitleView( 'VwGraphic2' ,STR0025  ) //--"Rentabilidade por Devedor"

/*------------------------------------------
//-- Manipulação Box de Telas
------------------------------------------*/
oView:CreateVerticalBox('LEFT', 6 )
oView:CreateVerticalBox('DETALHES',94)

//--TREE
oView:CreateHorizontalBox('BOX1', 1 ,'LEFT' )
oView:CreateHorizontalBox('TREE',99 ,'LEFT')

//-- Folders
oView:CreateFolder('PASTAS','DETALHES')

//-- Pastas nos folders
oView:AddSheet('PASTAS','ABA01','Gráfico')
oView:AddSheet('PASTAS','ABA02','Dados')

//-- ABA 01 - GRÁFICO
oView:CreateHorizontalBox('SIMULACAO',0,,,'PASTAS','ABA01')
oView:CreateHorizontalBox('RESUMO',25,,,'PASTAS','ABA01')
oView:CreateHorizontalBox('GRAFICO',74,,,'PASTAS','ABA01')
oView:CreateVerticalBox('GRAF1',50,'GRAFICO',,'PASTAS','ABA01')
oView:CreateVerticalBox('GRAF2',50,'GRAFICO',,'PASTAS','ABA01')

//-- ABA02 - DADOS
oView:CreateHorizontalBox('PAGADOR',35,,,'PASTAS','ABA02')
oView:CreateHorizontalBox('CONHECIMENTO',35,,,'PASTAS','ABA02')
oView:CreateHorizontalBox('INFOS',30,,,'PASTAS','ABA02')
oView:CreateVerticalBox('NF',50,'INFOS',,'PASTAS','ABA02')
oView:CreateVerticalBox('GFE',50,'INFOS',,'PASTAS','ABA02')

oView:SetOwnerView("VwTree","TREE")
oView:SetOwnerView("VwGraphic1","GRAF1")
oView:SetOwnerView("VwGraphic2","GRAF2")
oView:SetOwnerView("VwFieldSim","SIMULACAO")
oView:SetOwnerView("VwGridRes","RESUMO")
oView:SetOwnerView("VwGridDev","PAGADOR")
oView:SetOwnerView("VwGridDoc","CONHECIMENTO")
oView:SetOwnerView("VwGridNf","NF")
oView:SetOwnerView("VwGridGfe","GFE")

oView:AddUserButton(STR0033,'PARAMETROS',{||AO45Leg()})	//-- Legenda
oView:SetAfterViewActivate({|oView|AfterView(oView)})
oView:SetViewCanActivate( {|oView|CanActView(oView)} )

Return oView

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author caio.y
@since 17/04/2017
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0005 	ACTION "PesqBrw"         	OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSAO45"	OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSAO45" 	OPERATION 5 ACCESS 0  //"Excluir"
ADD OPTION aRotina TITLE STR0037 	ACTION "AO45Pergunte"		OPERATION 6 ACCESS 0  //"Parametros"

Return ( aRotina )

/*/{Protheus.doc} AO45Pergunte
//Troca parâmetros do Pergunte
@author caio.y
@since 21/07/2017
@version undefined

@type function
/*/
Function AO45Pergunte( cTabela , nRecDL3 , nOpc ,  aSetKey , lBrowse  )

Default cTabela		:= "DL3"
Default nRecDL3		:= 0
Default nOpc		:= 4
Default aSetKey		:= {}
Default lBrowse		:= .F.

If lBrowse
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
EndIf

Pergunte("TMSAO45",.T.)

If lBrowse
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

Return

/*/{Protheus.doc} RetStrSim
Retorna estrutura da simulação
@author caio.y
@since 12/05/2017
@version undefined
@param cTipo,character,Tipo do retorno
@type function
/*/
Static Function RetStrSim(cTipo)
Local aModel	:= {}
Local aView		:= {}
Local aAux		:= {}
Local nCount	:= 1
Local nAux		:= 1
Local cPicture	:= ""
Local aRet		:= {}

Default cTipo	:= "1" //-- 1=Model;2=View

aAdd(aModel,	{ RetTitle("DTC_FILIAL")	, Nil , 'FILIAL'	,'C',	FWGETTAMFILIAL				, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial
aAdd(aModel,	{ RetTitle("EI9_SIMULA")	, Nil , 'NUMSIM'	,'C',	TamSX3("DL3_NUMSIM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Simulação
aAdd(aModel,	{ RetTitle("DTQ_FILORI")	, Nil , 'FILORI'	,'C',	TamSX3("DTQ_FILORI")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial de Origem
aAdd(aModel,	{ RetTitle("DTQ_VIAGEM")	, Nil , 'VIAGEM'	,'C',	TamSx3("DTQ_VIAGEM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Viagem

If cTipo == "1"

	//-- Cria estrutura ModelDef
	oStru	:= FWFormModelStruct():New()
	oStru:AddTable("FIELD", {} , STR0026) //-- Número Simulação

ElseIf cTipo == "2"

	//-- Cria estrutura ViewDef
	oStru	:= FWFormViewStruct():New()
	//-- Monta estrutura ViewDef
	aView	:= MontStrView(aModel , "MdFieldSim")

EndIf

//-- Retorna a estrutura com a composição dos campos
oStru	:= AddStruCpo(oStru , Iif(cTipo == "1",aModel,aView) , cTipo)

Return oStru

/*/{Protheus.doc} RetStrRes
Retorna estrutura resumo
@author caio.y
@since 12/05/2017
@version undefined
@param cTipo,character,Tipo do retorno
@type function
/*/
Static Function RetStrRes(cTipo)
Local aModel	:= {}
Local aView		:= {}
Local aAux		:= {}
Local aRet		:= {}
Local nCount	:= 1
Local nAux		:= 1
Local cPicture	:= ""
Local oStru		:= Nil

Default cTipo	:= "1" //-- 1=Model;2-View

/*---------------------------------------------------------------------------------
oStruct:AddField(	'' ,;	//-- [01] C Titulo do campo
'' ,; 						//-- [02] C ToolTip do campo
'TRB_MARK' ,;				//-- [03] C identificador (ID) do Field
'L' ,; 						//-- [04] C Tipo do campo
1 ,; 						//-- [05] N Tamanho do campo
0 ,;						//-- [06] N Decimal do campo
Nil ,;					 	//-- [07] B Code-block de validação do campo      //-- {|| T146MrkDoc() }
Nil ,;						//-- [08] B Code-block de validação When do campo //-- {|| TMA146VDoc(FwFldGet('T01_SERTMS'),'D') }
NIL ,; 						//-- [09] A Lista de valores permitido do campo
NIL ,; 						//-- [10] L Indica se o campo tem preenchimento obrigatório
NIL ,; 						//-- [11] B Code-block de inicializacao do campo
NIL ,; 						//-- [12] L Indica se trata de um campo chave
NIL ,; 						//-- [13] L Indica se o campo pode receber valor em uma operação de update.
.T.  ) 						//-- [14] L Indica se o campo é virtual
---------------------------------------------------------------------------------*/
aAdd(aModel,	{ RetTitle("DTC_FILIAL")	, Nil , 'FILIAL'	,'C',	FWGETTAMFILIAL				, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.T., .F.}) //-- Filial
aAdd(aModel,	{ RetTitle("EI9_SIMULA")	, Nil , 'NUMSIM'	,'C',	TamSX3("DL3_NUMSIM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.T., .T.}) //-- Simulação
aAdd(aModel,	{ RetTitle("DTQ_FILORI")	, Nil , 'FILORI'	,'C',	TamSX3("DTQ_FILORI")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial de Origem
aAdd(aModel,	{ RetTitle("DTQ_VIAGEM")	, Nil , 'VIAGEM'	,'C',	TamSx3("DTQ_VIAGEM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Viagem
aAdd(aModel,	{ ""						, Nil , 'MARK'		,'L',	1							, 0  						,FwBuildFeature(STRUCT_FEATURE_VALID,"AO45VldMrk()"),Nil,Nil,Nil,Nil,Nil,.T., .T.}) //-- Mark
aAdd(aModel,	{ "  "						, Nil , 'LOG_BTSTA'	,'BT',	1							, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Status
aAdd(aModel,	{ "  "						, Nil , 'ERR_BTSTA'	,'BT',	1							, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Erro
aAdd(aModel,	{ "  "						, Nil , 'RAT_BTSTA'	,'BT',	1							, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Rateio
aAdd(aModel,	{ RetTitle("DT6_TABFRE")	, Nil , 'TABFRE'	,'C',	TamSX3("DT6_TABFRE")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- Tabela Frete
aAdd(aModel,	{ RetTitle("DT6_TIPTAB")	, Nil , 'TIPTAB'	,'C',	TamSX3("DT6_TIPTAB")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- Tipo Tabela
aAdd(aModel,	{ RetTitle("DTR_TABCAR")	, Nil , 'TABCAR'	,'C',	TamSX3("DTR_TABCAR")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- Tabela Carreteiro
aAdd(aModel,	{ STR0019					, Nil , 'RENTAB'	,'N',	TamSX3("DL3_RENTAB")[1]	+ 5	, TamSX3("DL3_RENTAB")[2] + 2	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- % Rentabilidade
aAdd(aModel,	{ STR0016					, Nil , 'VLRRCT'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- Vlr. Receita
aAdd(aModel,	{ STR0018 + " " +RTrim(mv_par01)	, Nil , 'VLDSPTMS'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- Vlr. Despesa TMS
aAdd(aModel,	{ STR0018 + " " +RTrim(mv_par02)	, Nil , 'VLDSPGFE'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- Vlr. Despesa GFE
aAdd(aModel,	{ STR0018 + " " + STR0017	, Nil , 'VLDSPTOT'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- Vlr. Despesa Total
aAdd(aModel,	{ STR0020					, Nil , 'PERCUS'	,'N',	TamSX3("DDC_PERCUS")[1]	+ 2	, TamSX3("DDC_PERCUS")[2] + 2 	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- % Mínimo Rentabilidade
aAdd(aModel,	{ RetTitle("DDB_CODNEG")	, Nil , 'CODNEG'	,'C',	TamSX3("DDB_CODNEG")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Código Negociação
aAdd(aModel,	{ RetTitle("DDB_DESCRI")	, Nil , 'DESNEG'	,'C',	TamSX3("DDB_DESCRI")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Descrição Negociação
aAdd(aModel,	{ RetTitle("DC5_SERVIC")	, Nil , 'SERVIC'	,'C',	TamSX3("DC5_SERVIC")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Código Serviço
aAdd(aModel,	{ RetTitle("DC5_DESSER")	, Nil , 'DESSER'	,'C',	TamSX3("DC5_DESSER")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Descrição Serviço
aAdd(aModel,	{ RetTitle("DL3_OBSERV")	, Nil , 'OBSERV'	,'M',	TamSX3("DL3_OBSERV")[1]	 + 25	, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Observação

If cTipo == "1"

	//-- Cria estrutura ModelDef
	oStru	:= FWFormModelStruct():New()
	oStru:AddTable("GRID1", {} ,STR0027)//-- Resumo de cálculo

ElseIf cTipo == "2"

	//-- Cria estrutura ViewDef
	oStru	:= FWFormViewStruct():New()
	//-- Monta estrutura ViewDef
	aView	:= MontStrView(aModel , "MdGridRes")

EndIf

//-- Retorna a estrutura com a composição dos campos
oStru	:= AddStruCpo(oStru , Iif(cTipo == "1",aModel,aView) , cTipo)

Return oStru

/*/{Protheus.doc} RetStrDev
Retorna estrutura do Devedor
@author caio.y
@since 12/05/2017
@version undefined
@param cTipo,character,Tipo do retorno
@type function
/*/
Static Function RetStrDev(cTipo)
Local aModel	:= {}
Local aView		:= {}
Local aAux		:= {}
Local nCount	:= 1
Local nAux		:= 1
Local cPicture	:= ""
Local aRet		:= {}

Default cTipo	:= "1" //-- 1=Model;2=View

aAdd(aModel,	{ RetTitle("DTC_FILIAL")	, Nil , 'FILIAL'	,'C',	FWGETTAMFILIAL				, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial
aAdd(aModel,	{ RetTitle("EI9_SIMULA")	, Nil , 'NUMSIM'	,'C',	TamSX3("DL3_NUMSIM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Simulação
aAdd(aModel,	{ RetTitle("DTQ_FILORI")	, Nil , 'FILORI'	,'C',	TamSX3("DTQ_FILORI")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial de Origem
aAdd(aModel,	{ RetTitle("DTQ_VIAGEM")	, Nil , 'VIAGEM'	,'C',	TamSx3("DTQ_VIAGEM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Viagem
aAdd(aModel,	{ STR0021					, Nil , 'ITEM'		,'C',	3							, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Item
aAdd(aModel,	{ "  "						, Nil , 'LOG_BTSTA'	,'BT',	1							, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Status
aAdd(aModel,	{ RetTitle("DTC_CLIDEV")	, Nil , 'CLIDEV'	,'C',	TamSX3("DTC_CLIDEV")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Código Devedor
aAdd(aModel,	{ RetTitle("DTC_LOJDEV")	, Nil , 'LOJDEV'	,'C',	TamSX3("DTC_LOJDEV")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Loja Devedor
aAdd(aModel,	{ RetTitle("A1_NOME")		, Nil , 'NOMDEV'	,'C',	TamSX3("A1_NOME")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Nome Devedor
aAdd(aModel,	{ STR0016					, Nil , 'VLRRCT'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Receita
aAdd(aModel,	{ STR0018 + " " +RTrim(mv_par01)	, Nil , 'VLDSPTMS'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Despesa TMS
aAdd(aModel,	{ STR0018 + " " +RTrim(mv_par02)	, Nil , 'VLDSPGFE'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Despesa GFE
aAdd(aModel,	{ STR0018 + " " + STR0017	, Nil , 'VLDSPTOT'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Despesa Total
aAdd(aModel,	{ STR0019					, Nil , 'RENTAB'	,'N',	TamSX3("DL3_RENTAB")[1]	+ 5	, TamSX3("DL3_RENTAB")[2] + 2	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- % Rentabilidade!
aAdd(aModel,	{ RetTitle("DT6_PESO")		, Nil , 'PESO'		,'N',	TamSX3("DT6_PESO")[1]		, TamSX3("DT6_PESO")[2] 	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Peso
aAdd(aModel,	{ RetTitle("DT6_PESOM3")	, Nil , 'PESOM3'	,'N',	TamSX3("DT6_PESOM3")[1]		, TamSX3("DT6_PESOM3")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Peso M3
aAdd(aModel,	{ RetTitle("DT6_VALMER")	, Nil , 'VALMER'	,'N',	TamSX3("DT6_VALMER")[1]		, TamSX3("DT6_VALMER")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Valor Mercadoria
aAdd(aModel,	{ RetTitle("DT6_QTDVOL")	, Nil , 'QTDVOL'	,'N',	TamSX3("DT6_QTDVOL")[1]		, TamSX3("DT6_QTDVOL")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Quantidade de Volumes

If cTipo == "1"

	//-- Cria estrutura ModelDef
	oStru	:= FWFormModelStruct():New()
	oStru:AddTable("GRID2", {} , STR0009 ) //-- Rentabilidade por Deveodr

ElseIf cTipo == "2"

	//-- Cria estrutura ViewDef
	oStru	:= FWFormViewStruct():New()
	//-- Monta estrutura ViewDef
	aView	:= MontStrView(aModel , "MdGridDev")

EndIf

//-- Retorna a estrutura com a composição dos campos
oStru	:= AddStruCpo(oStru , Iif(cTipo == "1",aModel,aView) , cTipo)

Return oStru

/*/{Protheus.doc} RetStrDoc
Retorna a estrutura dos conheicmentos de transporte
@author caio.y
@since 12/05/2017
@version undefined
@param cTipo, characters, Tipo de Retorno
@type function
/*/
Static Function RetStrDoc(cTipo)
Local aModel	:= {}
Local aView		:= {}
Local aAux		:= {}
Local nCount	:= 1
Local nAux		:= 1
Local cPicture	:= ""
Local aRet		:= {}

Default cTipo 	:= "1" //- 1=Model;2=View

aAdd(aModel,	{ RetTitle("DTC_FILIAL")	, Nil , 'FILIAL'	,'C',	FWGETTAMFILIAL				, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})	//-- Filial
aAdd(aModel,	{ RetTitle("EI9_SIMULA")	, Nil , 'NUMSIM'	,'C',	TamSX3("DL3_NUMSIM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Simulação
aAdd(aModel,	{ RetTitle("DTQ_FILORI")	, Nil , 'FILORI'	,'C',	TamSX3("DTQ_FILORI")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial de Origem
aAdd(aModel,	{ RetTitle("DTQ_VIAGEM")	, Nil , 'VIAGEM'	,'C',	TamSx3("DTQ_VIAGEM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Viagem
aAdd(aModel,	{ STR0021					, Nil , 'ITEM'		,'C',	3							, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Item
aAdd(aModel,	{ "  "						, Nil , 'LOG_BTSTA'	,'BT',	1							, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Status
aAdd(aModel,	{ RetTitle("DT6_FILDOC")	, Nil , 'FILDOC'	,'C',	TamSX3("DT6_FILDOC")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial Documento
aAdd(aModel,	{ RetTitle("DT6_DOC")		, Nil , 'DOC'		,'C',	TamSX3("DT6_DOC")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.})	//-- Documento
aAdd(aModel,	{ RetTitle("DT6_SERIE")		, Nil , 'SERIE'		,'C',	TamSX3("DT6_SERIE")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Série
aAdd(aModel,	{ RetTitle("DT6_DATEMI")	, Nil , 'DATAEMI'	,'D',	TamSX3("DT6_DATEMI")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.})	//-- Data Emissão
aAdd(aModel,	{ RetTitle("DTC_CLIREM")	, Nil , 'CLIREM'	,'C',	TamSX3("DTC_CLIREM")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.})	//-- Código Remetente
aAdd(aModel,	{ RetTitle("DTC_LOJREM")	, Nil , 'LOJREM'	,'C',	TamSX3("DTC_LOJREM")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Loja Remetente
aAdd(aModel,	{ RetTitle("A1_NOME")		, Nil , 'NOMREM'	,'C',	TamSX3("A1_NOME")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Nome Remetente
aAdd(aModel,	{ RetTitle("DTC_CLIDES")	, Nil , 'CLIDES'	,'C',	TamSX3("DTC_CLIDES")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Destinatário
aAdd(aModel,	{ RetTitle("DTC_LOJDES")	, Nil , 'LOJDES'	,'C',	TamSX3("DTC_LOJDES")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Loja Destinatário
aAdd(aModel,	{ RetTitle("A1_NOME")		, Nil , 'NOMDES'	,'C',	TamSX3("A1_NOME")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Nome Destinatário
aAdd(aModel,	{ RetTitle("DT6_CDRORI")	, Nil , 'CDRORI'	,'C',	TamSX3("DT6_CDRORI")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Cd. Região Origem
aAdd(aModel,	{ RetTitle("DT6_CDRDES")	, Nil , 'CDRDES'	,'C',	TamSX3("DT6_CDRDES")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Cd. Região Destino
aAdd(aModel,	{ RetTitle("DA8_COD")		, Nil , 'ROTA'		,'C',	TamSX3("DA8_COD")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Rota
aAdd(aModel,	{ RetTitle("DT6_PESO")		, Nil , 'PESO'		,'N',	TamSX3("DT6_PESO")[1]		, TamSX3("DT6_PESO")[2] 	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Peso
aAdd(aModel,	{ RetTitle("DT6_PESOM3")	, Nil , 'PESOM3'	,'N',	TamSX3("DT6_PESOM3")[1]		, TamSX3("DT6_PESOM3")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Peso M3
aAdd(aModel,	{ STR0016					, Nil , 'VLRRCT'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Receita
aAdd(aModel,	{ STR0018 + " " +RTrim(mv_par01)	, Nil , 'VLDSPTMS'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Despesa TMS
aAdd(aModel,	{ STR0018 + " " +RTrim(mv_par02)	, Nil , 'VLDSPGFE'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Despesa GFE
aAdd(aModel,	{ STR0018 + " " + STR0017	, Nil , 'VLDSPTOT'	,'N',	TamSX3("DTR_VALFRE")[1]		, TamSX3("DTR_VALFRE")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Vlr. Despesa Total
aAdd(aModel,	{ STR0019					, Nil , 'RENTAB'	,'N',	TamSX3("DL3_RENTAB")[1]	+ 5	, TamSX3("DL3_RENTAB")[2] + 2	,Nil,{||.F.},Nil,Nil,Nil,Nil,.T., .T.}) //-- % Rentabilidade!
aAdd(aModel,	{ RetTitle("DT6_VALMER")	, Nil , 'VALMER'	,'N',	TamSX3("DT6_VALMER")[1]		, TamSX3("DT6_VALMER")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) 	//-- Valor Mercadoria
aAdd(aModel,	{ RetTitle("DT6_QTDVOL")	, Nil , 'QTDVOL'	,'N',	TamSX3("DT6_QTDVOL")[1]		, TamSX3("DT6_QTDVOL")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) 	//-- Quantidade de Volumes

If cTipo == "1"

	//-- Cria estrutura ModelDef
	oStru	:= FWFormModelStruct():New()
	oStru:AddTable("GRID3", {} , STR0028) //-- Rentabilidade por Documento

ElseIf cTipo == "2"

	//-- Cria estrutura ViewDef
	oStru	:= FWFormViewStruct():New()
	//-- Monta estrutura ViewDef
	aView	:= MontStrView(aModel , "MdGridDoc" )

EndIf

//-- Retorna a estrutura com a composição dos campos
oStru	:= AddStruCpo(oStru , Iif(cTipo == "1",aModel,aView) , cTipo)

Return oStru

/*/{Protheus.doc} RetStrNf
Retorna estrutura de notas fiscais
@author caio.y
@since 12/05/2017
@version undefined
@param cTipo, characters, descricao
@type function
/*/
Static Function RetStrNf(cTipo)
Local aModel	:= {}
Local aView		:= {}
Local aAux		:= {}
Local nCount	:= 1
Local nAux		:= 1
Local cPicture	:= ""
Local aRet		:= {}

Default cTipo	:= "1"

aAdd(aModel,	{ RetTitle("DTC_FILIAL")	, Nil , 'FILIAL'	,'C',	FWGETTAMFILIAL				, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})	//-- Filial
aAdd(aModel,	{ RetTitle("EI9_SIMULA")	, Nil , 'NUMSIM'	,'C',	TamSX3("DL3_NUMSIM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Simulação
aAdd(aModel,	{ RetTitle("DTQ_FILORI")	, Nil , 'FILORI'	,'C',	TamSX3("DTQ_FILORI")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial de Origem
aAdd(aModel,	{ RetTitle("DTQ_VIAGEM")	, Nil , 'VIAGEM'	,'C',	TamSx3("DTQ_VIAGEM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Viagem
aAdd(aModel,	{ STR0021					, Nil , 'ITEM'		,'C',	3							, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Item
aAdd(aModel,	{ RetTitle("DTC_FILDOC")	, Nil , 'FILDOC'	,'C',	TamSX3("DTC_FILDOC")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial Documento
aAdd(aModel,	{ RetTitle("DTC_NUMNFC")	, Nil , 'NUMNFC'	,'C',	TamSX3("DTC_NUMNFC")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Doc. Cliente
aAdd(aModel,	{ RetTitle("DTC_SERNFC")	, Nil , 'SERNFC'	,'C',	TamSX3("DTC_SERNFC")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.})	//-- Série Dc. Cli
aAdd(aModel,	{ RetTitle("DTC_EMINFC")	, Nil , 'EMINFC'	,'D',	TamSX3("DTC_EMINFC")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.})	//-- Data Emissão
aAdd(aModel,	{ RetTitle("DT6_CDRORI")	, Nil , 'CDRORI'	,'C',	TamSX3("DT6_CDRORI")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Cd. Região Origem
aAdd(aModel,	{ RetTitle("DT6_CDRDES")	, Nil , 'CDRDES'	,'C',	TamSX3("DT6_CDRDES")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Cd. Região Destino
aAdd(aModel,	{ RetTitle("DA8_COD")		, Nil , 'ROTA'		,'C',	TamSX3("DA8_COD")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Rota
aAdd(aModel,	{ RetTitle("DTC_PESO")		, Nil , 'PESO'		,'N',	TamSX3("DTC_PESO")[1]		, TamSX3("DTC_PESO")[2] 	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Peso
aAdd(aModel,	{ RetTitle("DTC_PESOM3")	, Nil , 'PESOM3'	,'N',	TamSX3("DTC_PESOM3")[1]		, TamSX3("DTC_PESOM3")[2]	,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Peso M3

If cTipo == "1"

	//-- Cria estrutura ModelDef
	oStru	:= FWFormModelStruct():New()
	oStru:AddTable("GRID4", {} ,  STR0029 ) //-- Rentabilidade por Nota Fiscal

ElseIf cTipo == "2"

	//-- Cria estrutura ViewDef
	oStru	:= FWFormViewStruct():New()
	//-- Monta estrutura ViewDef
	aView	:= MontStrView(aModel , "MdGridNf")

EndIf

//-- Retorna a estrutura com a composição dos campos
oStru	:= AddStruCpo(oStru , Iif(cTipo == "1",aModel,aView) , cTipo)

Return oStru

/*/{Protheus.doc} RetStrGfe
Retorna estrutura de trechos do GFE
@author caio.y
@since 15/05/2017
@version undefined
@param cTipo, characters, 1=Model;2=View
@type function
/*/
Static Function RetStrGfe(cTipo)
Local aModel	:= {}
Local aView		:= {}
Local aAux		:= {}
Local nCount	:= 1
Local nAux		:= 1
Local cPicture	:= ""
Local aRet		:= {}

Default cTipo	:= "1"

aAdd(aModel,	{ RetTitle("DTC_FILIAL")	, Nil , 'FILIAL'		,'C',	FWGETTAMFILIAL				, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})	//-- Filial
aAdd(aModel,	{ RetTitle("EI9_SIMULA")	, Nil , 'NUMSIM'		,'C',	TamSX3("DL3_NUMSIM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Simulação
aAdd(aModel,	{ RetTitle("DTQ_FILORI")	, Nil , 'FILORI'		,'C',	TamSX3("DTQ_FILORI")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial de Origem
aAdd(aModel,	{ RetTitle("DTQ_VIAGEM")	, Nil , 'VIAGEM'		,'C',	TamSx3("DTQ_VIAGEM")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Viagem
aAdd(aModel,	{ RetTitle("DJN_FILDOC")	, Nil , 'FILDOC'		,'C',	TamSX3("DJN_FILDOC")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Filial Documento
aAdd(aModel,	{ RetTitle("DJN_DOC")		, Nil , 'DOC'			,'C',	TamSX3("DJN_DOC")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- Doc. Cliente
aAdd(aModel,	{ RetTitle("DJN_SERIE")		, Nil , 'SERIE'			,'C',	TamSX3("DJN_SERIE")[1]		, 0  						,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})	//-- Série Dc. Cli
aAdd(aModel,	{ STR0021					, Nil , 'ITEM'			,'C',	3							, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Item
aAdd(aModel,	{ RetTitle("GWU_CDTRP")		, Nil , 'CGCTRAN'		,'C',	TamSX3("GWU_CDTRP")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Tranportador
aAdd(aModel,	{ RetTitle("GWU_NMTRP ")	, Nil , 'NOMETRAN'		,'C',	TamSX3("GWU_NMTRP")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Nome Transportador
aAdd(aModel,	{ RetTitle("GWU_NRCIDD")	, Nil , 'MUNDES'		,'C',	TamSX3("GWU_NRCIDD")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Municipio Destino
aAdd(aModel,	{ RetTitle("GWU_NMCIDD")	, Nil , 'NOMEMUNDES'	,'C',	TamSX3("GWU_NMCIDD")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- nome Mun
aAdd(aModel,	{ RetTitle("GWU_UFD")		, Nil , 'UFDEST'		,'C',	TamSX3("GWU_UFD")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- UF Destino
aAdd(aModel,	{ RetTitle("GWU_NRCIDO")	, Nil , 'MUNORI'		,'C',	TamSX3("GWU_NRCIDO")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Municipio origem
aAdd(aModel,	{ RetTitle("GWU_NMCIDO")	, Nil , 'NOMEMUNORI'	,'C',	TamSX3("GWU_NMCIDO")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- Nome
aAdd(aModel,	{ RetTitle("GWU_UFO")		, Nil , 'UFORI'			,'C',	TamSX3("GWU_UFO")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- UF Origem
aAdd(aModel,	{ RetTitle("GWU_CEPO")		, Nil , 'CEPORI'		,'C',	TamSX3("GWU_CEPO")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- CEP Origem
aAdd(aModel,	{ RetTitle("GWU_CEPD")		, Nil , 'CEPDES'		,'C',	TamSX3("GWU_CEPD")[1]		, 0  						,Nil,{||.F.},Nil,Nil,Nil,Nil,.F., .T.}) //-- CEP Destino

If cTipo == "1"

	//-- Cria estrutura ModelDef
	oStru	:= FWFormModelStruct():New()
	oStru:AddTable("GRID5", {} , STR0030 ) //-- Rentabilidade por Trecho

ElseIf cTipo == "2"

	//-- Cria estrutura ViewDef
	oStru	:= FWFormViewStruct():New()
	//-- Monta estrutura ViewDef
	aView	:= MontStrView(aModel , "MdGridGfe")

EndIf

//-- Retorna a estrutura com a composição dos campos
oStru	:= AddStruCpo(oStru , Iif(cTipo == "1",aModel,aView) , cTipo)

Return oStru

/*/{Protheus.doc} LoadField
//Carrega Fields
@author caio.y
@since 11/07/2017
@version undefined
@param oModel, object, Modelo de Dados
@param lCopy, logical, Indica se é uma cópia
@type function
/*/
Static Function LoadField( oModel, lCopy )
Local nOpc		:= 3
Local aLoad		:= {}

Default oModel	:= FwModelActive()
Default lCopy	:= .F.

nOpc	:= oModel:GetOperation()

If nOpc == MODEL_OPERATION_VIEW

	aAdd(aLoad, {xFilial('DL3'),;
                    DL3->DL3_NUMSIM,;
                    DL3->DL3_FILORI,;
                    DL3->DL3_VIAGEM }) //-- Dados

    aAdd(aLoad, DL3->(RECNO())) //-- Recno

EndIf

Return aLoad

/*/{Protheus.doc} LoadGrid
//-- Carrega Grid
@author caio.y
@since 30/06/2017
@version undefined
@param oModel,object,Modelo de Dados
@param lCopy, logical, Indica se é uma cópia
@param cGrid, characters, Nome do grid
@type function
/*/
Static Function LoadGrid( oModel, lCopy , cGrid )
Local aLoad			:= {}
Local aInfoTot		:= {}
Local oMdlField		:= Nil
Local cFilOri		:= ""
Local cViagem		:= ""
Local cQuery		:= ""
Local cAliasQry		:= ""
Local cItem			:= ""
Local cNumSim		:= ""
Local cTabFre		:= ""
Local cTipTab		:= ""
Local cTabCar		:= ""
Local cCodNeg		:= ""
Local cServic		:= ""
Local cDescNeg		:= ""
Local cDescServic	:= ""
Local cStatus		:= "BR_VERDE"
Local cErro			:= "PMSINFO"
Local cRateio		:= "f10_azul"
Local cBItmap		:= ""
Local cObserv		:= ""
Local nValPagTms	:= 0
Local nValPagGfe	:= 0
Local nTotPag		:= 0
Local nValRecebe	:= 0
Local nRentab		:= 0
Local nPercus		:= 0
Local nOpc			:= 3
Local nCount		:= 1
Local nAux			:= 1

Default oModel	:= FwModelActive()
Default lCopy	:= .F.
Default cGrid	:= ""

nOpc	:= oModel:GetOperation()

Pergunte("TMSAO45",.F.)

//-- Rateio de valores
If mv_par03 == '1' //-- PESO REAL X PESO CUBADO
	cRateio		:= "f10_azul"
ElseIf mv_par03 == '2' //-- PESO REAL
	cRateio		:= "f10_cinz"
Elseif mv_par03 == '3'  //-- PESO CUBADO
	cRateio		:= "f10_lara"
ElseIf mv_par03 == '4'  //-- Valor mercadoria
	cRateio		:= "f10_pret"
ElseIf mv_par03 == '5' .Or. mv_par03 == '6' //-- Qtd Volumes ou Quantidade

	If mv_par03 == '5'
		cRateio		:= "f10_amar"
	Else
		cRateio		:= "f10_pink"
	EndIf

EndIf

If nOpc == MODEL_OPERATION_INSERT

	(cAliasTmp)->(dbGoTop())
	cFilOri		:= (cAliasTmp)->FILORI
	cViagem		:= (cAliasTmp)->VIAGEM

	If PESO_TOT == 0 .And. PESOM3_TOT == 0
		aInfoTot	:= RetInfoTot("DT6",cFilOri,cViagem )
		If Len(aInfoTot) > 0
			For nAux := 1 To Len(aInfoTot)
				PESO_TOT	+= aInfoTot[nAux][1]
				PESOM3_TOT	+= aInfoTot[nAux][2]
				VALMER_TOT	+= aInfoTot[nAux][3]
				QTDVOL_TOT	+= aInfoTot[nAux][4]

				If aInfoTot[nAux][1] > 0 .And. aInfoTot[nAux][1] > aInfoTot[nAux][2]
					PESOM3REAL	+= aInfoTot[nAux][1]
				Else
					PESOM3REAL	+= aInfoTot[nAux][2]
				EndIf

			Next nAux
		EndIf
	EndIf

	If cGrid == "MdGridRes"

		While (cAliasTmp)->(!Eof())

			cNumSim		:= (cAliasTmp)->SIMULADO
			cFilOri		:= (cAliasTmp)->FILORI
			cViagem		:= (cAliasTmp)->VIAGEM
			cCodNeg		:= (cAliasTmp)->CODNEG
			cServic		:= (cAliasTmp)->SERVIC
			nPercus		:= (cAliasTmp)->PERCUS
			cTabFre		:= (cAliasTmp)->TABFRE
			cTipTab		:= (cAliasTmp)->TIPTAB
			cTabCar		:= (cAliasTmp)->TABCAR
			cObserv		:= (cAliasTmp)->OBSERV
			cItem		:= "000"

			//-- Gatilho código negociação
			DDB->(dbSetOrder(1))
			If DDB->( MsSeek( xFilial("DDB") + cCodNeg ))
				cDescNeg	:= DDB->DDB_DESCRI
			EndIf

			//-- Gatilho código serviço
			If !Empty(Tabela("L4",cServic,.F.))
				cDescServic := Tabela("L4",cServic,.F.)
			EndIf

			nValRecebe	:= Round( (cAliasTmp)->VLRRCT, TamSX3("DT6_VALFRE")[2] )
			nValPagTms	:= Round( (cAliasTmp)->VLRDSPTMS , TamSX3("DT6_VALFRE")[2] )
			nValPagGfe	:= Round( (cAliasTmp)->VLRDSPGFE, TamSX3("DT6_VALFRE")[2] )

			nTotPag		:= nValPagTms + nValPagGfe
			nRentab		:= ((nValRecebe/nTotPag) - 1 ) * 100
			nRentab		:= Round( nRentab , 2  )

			If nRentab <= 0 .Or. nRentab < nPercus
				cStatus	:= "BR_VERMELHO"
			ElseIf nRentab == nPercus
				cStatus	:= "BR_AMARELO"
			ElseIf nRentab > nPercus
				cStatus	:= "BR_VERDE"
			EndIf

			If !Empty(cObserv)
				cErro	:= "PMSINFO"
			Else
				cErro	:= ""
			EndIf

			//-- Cache de memória com os valores totais da primeira linha
			If VLR_RECEBER == 0  .And. VLR_PAGTOT == 0
				VLR_RECEBER	:= nValRecebe
				VLR_PAGTMS	:= nValPagTms
				VLR_PAGGFE	:= nValPagGfe
				VLR_PAGTOT	:= nTotPag
				VLR_PERCUS	:= nPercus
 			EndIf

			aAdd(aLoad,{0,{,;						//-- FILIAL
						cNumSim,;					//-- NUMSIM
						cFilOri,;					//-- FILORI
						cViagem,;					//-- VIAGEM
						,;							//-- MARK
						cStatus,;					//-- STATUS
						cErro,;						//-- ERRO
						cRateio,;					//-- RATEIO
						cTabFre,;					//-- TABFRE
						cTipTab,;					//-- TIPTAB
						cTabCar,;					//-- TABCAR
						nRentab,;					//-- RENTAB
						nValRecebe,;				//-- VLRRCT
						nValPagTms,;				//-- VLRDSPTMS
						nValPagGfe,;				//-- VLRDSPGFE
						nTotPag ,;					//-- VLRDSPTOT
						nPercus,;					//-- PERCUS
						cCodNeg,;					//-- CODNEG
						cDescNeg,;					//-- DESNEG
						cServic,;					//-- SERVIC
						cDescServic,;				//-- DESSERV
						cObserv}})					//-- OBSERV

			(cAliasTmp)->(dbSkip())

		EndDo

	ElseIf cGrid == "MdGridDev"
		aLoad	:= RetGridDev(cNumSim,cFilOri,cViagem)
	ElseIf cGrid == "MdGridDoc"
		aLoad	:= RetGridDoc(cNumSim , cFilOri, cViagem )
	ElseIf cGrid == "MdGridNf"
		aLoad	:= RetGridNf(cNumSim , cFilOri,cViagem)
	ElseIf cGrid == "MdGridGfe"
		aLoad	:= RetGridGFE(cNumSim , cFilOri, cViagem, oModel )
	EndIf

ElseIf nOpc == MODEL_OPERATION_VIEW .Or. nOpc == MODEL_OPERATION_DELETE

	cNumSim		:= DL3->DL3_NUMSIM
	cFilOri		:= DL3->DL3_FILORI
	cViagem		:= DL3->DL3_VIAGEM
	nValPagTms	:= DL3->DL3_VLRTMS
	nValPagGfe	:= DL3->DL3_VLRGFE
	nValRecebe	:= DL3->DL3_VLRRCT
	nTotPag		:= DL3->DL3_VLRTOT
	nPercus		:= DL3->DL3_PERCUS
	nRentab		:= DL3->DL3_RENTAB
	cTabFre		:= DL3->DL3_TABFRE
	cTipTab		:= DL3->DL3_TIPTAB
	cTabCar		:= DL3->DL3_TABCAR
	cCodNeg		:= DL3->DL3_CODNEG
	cServic		:= DL3->DL3_SERVIC
	cObserv		:= DL3->DL3_OBSERV

	If PESO_TOT == 0 .And. PESOM3_TOT == 0
		aInfoTot	:= RetInfoTot("DT6",cFilOri,cViagem )
		If Len(aInfoTot) > 0
			For nAux := 1 To Len(aInfoTot)
				PESO_TOT	+= aInfoTot[nAux][1]
				PESOM3_TOT	+= aInfoTot[nAux][2]
				VALMER_TOT	+= aInfoTot[nAux][3]
				QTDVOL_TOT	+= aInfoTot[nAux][4]

				If aInfoTot[nAux][1] > 0 .And. aInfoTot[nAux][1] > aInfoTot[nAux][2]
					PESOM3REAL	+= aInfoTot[nAux][1]
				Else
					PESOM3REAL	+= aInfoTot[nAux][2]
				EndIf

			Next nAux
		EndIf
	EndIf

	//-- Cache de memória com os valores totais da primeira linha
	If VLR_RECEBER == 0  .And. VLR_PAGTOT == 0
		VLR_RECEBER	:= nValRecebe
		VLR_PAGTMS	:= nValPagTms
		VLR_PAGGFE	:= nValPagGfe
		VLR_PAGTOT	:= nTotPag
		VLR_PERCUS	:= nPercus
	EndIf

	If cGrid == "MdGridRes"

		If nRentab <= 0 .Or. nRentab < nPercus
			cStatus	:= "BR_VERMELHO"
		ElseIf nRentab == nPercus
			cStatus	:= "BR_AMARELO"
		ElseIf nRentab > nPercus
			cStatus	:= "BR_VERDE"
		EndIf

		If !Empty(cObserv)
			cErro	:= "PMSINFO"
		Else
			cErro	:= ""
		EndIf

		//-- Gatilho código negociação
		DDB->(dbSetOrder(1))
		If DDB->( MsSeek( xFilial("DDB") + cCodNeg ))
			cDescNeg	:= DDB->DDB_DESCRI
		EndIf

		//-- Gatilho código serviço
		If !Empty(Tabela("L4",cServic,.F.))
			cDescServic := Tabela("L4",cServic,.F.)
		EndIf

		aAdd(aLoad,{0,{,;						//-- FILIAL
					cNumSim,;					//-- NUMSIM
					cFilOri,;					//-- FILORI
					cViagem,;					//-- VIAGEM
					.T.,;						//-- MARK
					cStatus,;					//-- STATUS
					cErro,;						//-- ERRO
					cRateio,;					//-- RATEIO
					cTabFre,;					//-- TABFRE
					cTipTab,;					//-- TIPTAB
					cTabCar,;					//-- TABCAR
					nRentab,;					//-- RENTAB
					nValRecebe,;				//-- VLRRCT
					nValPagTms,;				//-- VLRDSPTMS
					nValPagGfe,;				//-- VLRDSPGFE
					nTotPag ,;					//-- VLRDSPTOT
					nPercus,;					//-- PERCUS
					cCodNeg,;					//-- CODNEG
					cDescNeg,;					//-- DESNEG
					cServic,;					//-- SERVIC
					cDescServic,;				//-- DESSERV
					cObserv}})					//-- OBSERV

	ElseIf cGrid == "MdGridGfe"
		aLoad	:= RetGridGFE(cNumSim,cFilOri,cViagem,oModel)
	ElseIf cGrid == "MdGridDev"
		aLoad	:= RetGridDev(cNumSim,cFilOri,cViagem)
	ElseIf cGrid == "MdGridNf"
		aLoad	:= RetGridNf(cNumSim,cFilOri,cViagem )
	ElseIf cGrid == "MdGridDoc"
		aLoad	:= RetGridDoc(cNumSim,cFilOri,cViagem )
	EndIf

EndIf

Return aLoad

/*/{Protheus.doc} MontStrView
//Monta Estrutura da ViewDef
@author caio.y
@since 12/05/2017
@version undefined
@param aModel, array, Array estrutura model
@param cModel, character, Nome do modelo de dados
@type function
/*/
Static Function MontStrView(aModel , cModel )
Local cPicture	:= ""
Local nCount	:= 1
Local aView		:= {}
Local nTam		:= 0
Local nDecimal	:= 0
Local cF3		:= ""
Local cTipo		:= "GET"
Local lContinua	:= .T.

Default aModel	:= {}
Default cModel	:= ""

/*-----------------------------------------------------------------------------------
oStruCab:AddField(	'MRK_ALL'	, ; 	// [1] Nome do Campo
'01'   	, ; 	// [2] Ordem
STR0006	, ; 	// [3] Titulo do campo  		//-- "Marcar Todos Itens MRP"
STR0006	, ; 	// [4] Descrição do campo	//-- "Marcar Todos Itens MRP"
{" "}  	, ; 	// [5] Array com Help
'L'    	, ; 	// [6] Tipo do campo
''     	, ; 	// [7] Picture
NIL    	, ; 	// [8] Bloco de Picture Var
''     	, ; 	// [9] Consulta F3
.T.    	, ; 	// [10] Indica se o campo é editável
NIL    	, ; 	// [11] Pasta do campo
NIL    	, ; 	// [12] Agrupamento do campo
{ }    	, ; 	// [13] Lista de valores permitido do campo (Combo)
NIL    	, ; 	// [14] Tamanho Maximo da maior opção do combo
NIL    	, ; 	// [15] Inicializador de Browse
.T.    	, ; 	// [16] Indica se o campo é virtual
NIL      	)   // [17] Picture Variável
-----------------------------------------------------------------------------------*/

For nCount := 1 To Len(aModel)
	cPicture	:= '@!'
	cF3			:= ""
	lContinua	:= .T.

	//-- Validações
	If aModel[nCount,3] $ "FILIAL"
		lContinua	:= .F.
	ElseIf ( aModel[nCount,3] $ "NUMSIM" .Or. aModel[nCount,3] $ "FILORI" .Or. aModel[nCount,3] $ "VIAGEM" ) .And. cModel <> "MdFieldSim"
		lContinua	:= .F.
	ElseIf Upper(AllTrim(cModel)) == "MDGRIDGFE" .And.  ( aModel[nCount,3] $ "FILDOC" .Or. aModel[nCount,3] $ "DOC" .Or. aModel[nCount,3] $ "SERIE" )
		lContinua	:= .F.
	EndIf

	If lContinua
		cTipo	:= "GET"
		//-- Pictures
		If aModel[nCount,4] == "N"
			nTam		:= aModel[nCount,5]	//-- Tamanho do campo
			nDecimal	:= aModel[nCount,6]	//-- Decimal

			If nDecimal > 0
				cPicture	:= " @E " + Replicate( "9", nTam - ( nDecimal + 1 ) )

				If aModel[nCount,3] $ "RENTAB" .Or. aModel[nCount,3] $ "PERCUS"
					cPicture	+= "." + Replicate("9",nDecimal - 1) + " "
					cPicture += "%"
				Else
					cPicture	+= "." + Replicate("9",nDecimal) + " "
				EndIf
			Else
				cPicture	:= " @E " + Replicate( "9", nTam )
			EndIf
		ElseIf aModel[nCount,4] == "L"
			cPicture	:= "@BMP"
			cTipo		:= "L"
		EndIf

		//-- F3
		If aModel[nCount,3] $ "TABFRE"
			cF3		:= "DTL"
		ElseIf aModel[nCount,3] $ "CDRORI" .Or. aModel[nCount,3] $ "CDRDES"
			cF3		:= "DUY"
		ElseIf aModel[nCount,3] $ "ROTA"
			cF3		:= "DA8"
		ElseIf aModel[nCount,3] $ "CLIDES" .Or. aModel[nCount,3] $ "CLIREM" .Or. aModel[nCount,3] $ "CLIDEV"
			cF3		:= "SA1"
		ElseIf aModel[nCount,3] $ "TRANSP"
			cF3		:= "SA4"
		ElseIf aModel[nCount,3] $ "SERTMS" .Or. aModel[nCount,3] $ "TIPTRA"
			cF3		:= "DLC"
		EndIf

		//-- Adiciona estrutura view def
		Aadd(aView, { aModel[nCount,3] , StrZero(nCount,3) , aModel[nCount,1], aModel[nCount,1]  ,Nil	, cTipo	,cPicture ,Nil,cF3,.T.,Nil,Nil,Nil,Nil,Nil,.T.})

	EndIf

Next nCount

Return aView

/*/{Protheus.doc} AddStruCpo
Compõe a estrutura de campos que devem constar na estrutura a ser criada
@author caio.y
@since 12/05/2017
@version undefined
@param oStru, object, Estrutura FWFormModelStruct ou FWFormViewtruct
@param aCampos, array, Campos que irão compor a esturutra
@param cTipo, characters, 1=Model;2=View
@type function
/*/
Static Function AddStruCpo(oStru , aCampos , cTipo)
Local nCount	:= 1

Default oStru	:= Nil
Default aCampos	:= {}
Default cTipo	:= "1" //-- 1=Model;2-View

If cTipo == "1" //-- ModelDef

	For nCount := 1 To Len(aCampos)

		oStru:AddField( ;
		aCampos[nCount,01]		, ;		// [01] Titulo do campo
		aCampos[nCount,01]		, ;		// [02] ToolTip do campo
		aCampos[nCount,03]		, ;		// [03] Id do Field
		aCampos[nCount,04]		, ;		// [04] Tipo do campo
		aCampos[nCount,05]		, ;		// [05] Tamanho do campo
		aCampos[nCount,06]		, ;		// [06] Decimal do campo
		aCampos[nCount,07]		, ;		// [07] Code-block de validação do campo
		aCampos[nCount,08]		, ;		// [08] Code-block de validação When do campoo
		aCampos[nCount,09]		, ;		// [09] Lista de valores permitido do campo
		aCampos[nCount,10]		, ;		// [10] Indica se o campo tem preenchimento obrigatório
		aCampos[nCount,11]		, ;		// [11] Code-block de inicializacao do campo
		aCampos[nCount,12]		, ;		// [12] Indica se trata-se de um campo chave
		aCampos[nCount,13]		, ;		// [13] Indica se o campo pode receber valor em uma operação de update.
		aCampos[nCount,14]	    )		// [14] Indica se o campo é virtual

	Next nCount

ElseIf cTipo == "2" //-- ViewDef

	For nCount := 1 To Len(aCampos)

		oStru:AddField( ;
		aCampos[nCount,01]	,;    	// [01] Campo
		aCampos[nCount,02]	,;    	// [02] Ordem
		aCampos[nCount,03]	,;    	// [03] Titulo   	// Rota
		aCampos[nCount,04]	,;   	// [04] Descricao	// Rota
		aCampos[nCount,05]	,;   	// [05] Help
		aCampos[nCount,06]	,;    	// [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCount,07]	,;    	// [07] Picture
		aCampos[nCount,08]	,;  	// [08] PictVar
		aCampos[nCount,09]	,;		// [09] F3
		aCampos[nCount,10]	,;    	// [10] Editavel
		aCampos[nCount,11]	,;   	// [11] Folder
		aCampos[nCount,12]	,;    	// [12] Group
		aCampos[nCount,13]	,;    	// [13] Lista Combo
		aCampos[nCount,14]	,;    	// [14] Tam Max Combo
		aCampos[nCount,15]	,;    	// [15] Inic. Browse
		aCampos[nCount,16]	) 		// [16] Virtual

	Next nCount
EndIf

Return oStru

/*/{Protheus.doc} AO35Act
//Ativação do modelo e carga no cabeçalho
@author caio.y
@since 03/07/2017
@version undefined
@param oModel, object, Modelo de Dados
@type function
/*/
Static Function AO35Act(oModel)
Local aArea			:= GetArea()
Local oMdlField		:= Nil
Local nOpc			:= 3

Default oModel		:= FwModelActive()

nOpc		:= oModel:GetOperation()
oMdlField	:= oModel:GetModel("MdFieldSim")

If nOpc == MODEL_OPERATION_INSERT
	(cAliasTmp)->(dbGoTop())
	oMdlField:LoadValue( "FILIAL", xFilial("DT6"))
	oMdlField:LoadValue( "NUMSIM", (cAliasTmp)->SIMULADO )
	oMdlField:LoadValue( "FILORI", (cAliasTmp)->FILORI )
	oMdlField:LoadValue( "VIAGEM", (cAliasTmp)->VIAGEM )
EndIf

RestArea(aArea)
Return .T.

/*/{Protheus.doc} ResetTmp
//Reseta alias temporário
@author caio.y
@since 30/06/2017
@version undefined

@type function
/*/
Static Function ResetTmp()
	cAliasTmp	:= ""
	oGraphic1	:= Nil
	oGraphic2	:= Nil
	PESO_TOT	:= 0
	PESOM3_TOT	:= 0
	PESOM3REAL	:= 0
	VLR_RECEBER	:= 0
	VLR_PAGTMS	:= 0
 	VLR_PAGGFE	:= 0
 	VLR_PAGTOT	:= 0
 	VLR_PERCUS	:= 0
 	VALMER_TOT	:= 0
 	QTDVOL_TOT	:= 0
 	aSetKey		:= {}
Return

/*/{Protheus.doc} GravaTmp
//Grava Tabela Temporária
@author caio.y
@since 30/06/2017
@version undefined
@param aFrete, array, Array com informações a Pagar
@aparam aFreteGFE, array, Array com informações a pagar GFE
@type function
/*/
Function AO45GrvTmp(cFilOri , cViagem , aFrete , aFreteGFE , cObserv   )
Local oTempTable	:= Nil
Local cTabTmpRent	:= ""
Local cCodNeg		:= ""
Local cServic		:= ""
Local cQuery		:= ""
Local cNumSim		:= GetSX8Num("DL3","DL3_NUMSIM")
Local cTabFre		:= ""
Local cTipTab		:= ""
Local cTabCar		:= ""
Local cMsgGFE		:= ""
Local aFields		:= {}
Local aRet			:= {}
Local lRet			:= .F.
Local lContinua		:= .F.
Local nRet			:= 1 //-- 0=Ok;1=Cancelar
Local nRecebe		:= 0
Local nPagTms		:= 0
Local nPagGFE		:= 0
Local nPagTot		:= 0
Local nRentab		:= 0
Local nCount		:= 0
Local nI			:= 1
Local nValReceber	:= 0
Local nPercus		:= 0
Local nPeso			:= 0
Local nMinimo		:= SuperGetMv('MV_MINRENT',,0)

Default cFilOri		:= ""
Default cViagem		:= ""
Default aFrete		:= {}
Default aFreteGFE	:= {}
Default cObserv		:= ""

DUD->(dbSetOrder(2))
DT6->(dbSetOrder(1))
If DUD->(MsSeek(xFilial("DUD") + cFilOri + cViagem ))
	While DUD->(!EOF()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial("DUD") + cFilOri + cViagem
		If DT6->(MsSeek(xFilial("DT6") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE ) ))
			nValReceber		+= DT6->DT6_VALFRE
		EndIf
		DUD->(dbSkip())
	EndDo
EndIf

If Len(aFreteGFE) > 0
	For nCount := 1 To Len(aFreteGFE)
		If aFreteGFE[nCount,4] > 0
			nPagGFE		+= aFreteGFE[nCount,4]
		Else
			cMsgGFE		+= STR0040 + chr(10) + chr(13)	//-- Frete zerado
			cMsgGFE		+= STR0039 + aFreteGFE[nCount,2] + "/" + aFreteGFE[nCount,3] + chr(10) + chr(13) //-- Transportadora
			cMsgGFE		+= STR0041 + aFreteGFE[nCount,9] + chr(10) + chr(13)	//-- Trecho
		EndIf
	Next nCount

	cObserv	+= cMsgGFE

EndIf

cAliasTmp	:= GetNextAlias()

AAdd(aFields, { "FILIAL" 	, "C", TamSX3("DTR_FILIAL")[1]	, TamSX3("DTR_FILIAL")[2] })	//-- Filial
AAdd(aFields, { "SIMULADO" 	, "C", TamSX3("DL3_NUMSIM")[1]	, TamSX3("DL3_NUMSIM")[2] })	//-- Número simulação
AAdd(aFields, { "FILORI"  	, "C", TamSX3("DTQ_FILORI")[1]	, TamSX3("DTQ_FILORI")[2] })	//-- Filial de Origem
AAdd(aFields, { "VIAGEM"  	, "C", TamSX3("DTQ_VIAGEM")[1]	, TamSX3("DTQ_VIAGEM")[2] })	//-- Viagem
AAdd(aFields, { "TABFRE"  	, "C", TamSX3("DTR_TABFRE")[1]	, TamSX3("DTR_TABFRE")[2] })	//-- Tabela Frete
AAdd(aFields, { "TIPTAB"  	, "C", TamSX3("DTR_TIPTAB")[1]	, TamSX3("DTR_TIPTAB")[2] })	//-- Tipo Tabela
AAdd(aFields, { "TABCAR"  	, "C", TamSX3("DTR_TABCAR")[1]	, TamSX3("DTR_TABCAR")[2] })	//-- Tabela Carreteiro
AAdd(aFields, { "CODNEG"  	, "C", TamSX3("DDB_CODNEG")[1]	, TamSX3("DDB_CODNEG")[2] })	//-- Código da negociação
AAdd(aFields, { "SERVIC"  	, "C", TamSX3("DC5_SERVIC")[1]	, TamSX3("DC5_SERVIC")[2] })	//-- Código do serviço
AAdd(aFields, { "PERCUS"  	, "N", TamSX3("DDC_PERCUS")[1]	, TamSX3("DDC_PERCUS")[2] })	//-- Percentual Mínimo
AAdd(aFields, { "VLRRCT"  	, "N", TamSX3("DTR_VALFRE")[1]	, TamSX3("DTR_VALFRE")[2] })	//-- Valor Receita
AAdd(aFields, { "VLRDSPTMS"	, "N", TamSX3("DTR_VALFRE")[1]	, TamSX3("DTR_VALFRE")[2] })	//-- Valor Despesa TMS
AAdd(aFields, { "VLRDSPGFE"	, "N", TamSX3("DTR_VALFRE")[1]	, TamSX3("DTR_VALFRE")[2] })	//-- Valor Despesa GFE
AAdd(aFields, { "VLRDSPTOT"	, "N", TamSX3("DTR_VALFRE")[1]	, TamSX3("DTR_VALFRE")[2] })	//-- Valor Despesa Total
AAdd(aFields, { "OBSERV"	, "M", TamSX3("DL3_OBSERV")[1] + 25	, TamSX3("DL3_OBSERV")[2] })	//-- Observacao

oTempTable		:= FwTemporaryTable():New(cAliasTmp)
oTempTable:SetFields( aFields )
oTempTable:AddIndex("01", {"FILIAL","SIMULADO"	, "FILORI", "VIAGEM", "TABFRE" , "TIPTAB" , "TABCAR" } )
oTempTable:AddIndex("02", {"FILIAL","SIMULADO"	, "FILORI", "VIAGEM", "TABCAR" , "TABFRE" , "TIPTAB" } )
oTempTable:AddIndex("03", {"FILIAL","FILORI"	, "VIAGEM" 	} )
oTempTable:Create()

cTabTmpRent:= oTempTable:GetRealName()

If Len(aFrete) > 0
	For nCount := 1 To Len(aFrete)
		lContinua	:= .T.
		cTabFre		:= aFrete[nCount][1]
		cTiptab		:= aFrete[nCount][2]
		nPagTms		:= aFrete[nCount][3]
		nPeso		:= aFrete[nCount][5]
		cTabCar		:= aFrete[nCount][13]
		nPercus		:= Iif( aFrete[nCount][16] == 0 , nMinimo , aFrete[nCount][16] )

		If Len(aFrete[nCount]) > 23
			cCodNeg		:= aFrete[nCount][23]
			cServic		:= aFrete[nCount][24]
			cObserv		+= aFrete[nCount][25]
			cObserv		:= StrTran(cObserv,"'","")
			cObserv		:= StrTran(cObserv,'"' , '')
		EndIf

		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->FILIAL		:= xFilial("DTC")
		(cAliasTMP)->SIMULADO	:= cNumSim
		(cAliasTMP)->FILORI		:= cFilOri
		(cAliasTMP)->VIAGEM		:= cViagem
		(cAliasTMP)->TABFRE		:= cTabFre
		(cAliasTMP)->TIPTAB		:= cTiptab
		(cAliasTMP)->TABCAR		:= cTabCar
		(cAliasTMP)->CODNEG		:= cCodNeg
		(cAliasTMP)->SERVIC		:= cServic
		(cAliasTMP)->PERCUS		:= nPercus
		(cAliasTMP)->VLRRCT		:= nValReceber
		(cAliasTMP)->VLRDSPTMS	:= nPagTms
		(cAliasTMP)->VLRDSPGFE  := nPagGfe
		(cAliasTMP)->VLRDSPTOT  := nPagTms + nPagGfe
		(cAliasTMP)->OBSERV     := cObserv
		(cAliasTmp)->(MsUnlock())

		
	Next nCount

Else
	lContinua	:= .T.

	If !Empty(cObserv)
		cObserv		:= StrTran(cObserv,"'","")
		cObserv		:= StrTran(cObserv,'"' , '')
	EndIf

	RecLock(cAliasTmp,.T.)
	(cAliasTmp)->FILIAL		:= xFilial("DTC")
	(cAliasTMP)->SIMULADO	:= cNumSim
	(cAliasTMP)->FILORI		:= cFilOri
	(cAliasTMP)->VIAGEM		:= cViagem
	(cAliasTMP)->TABFRE		:= cTabFre
	(cAliasTMP)->TIPTAB		:= cTiptab
	(cAliasTMP)->TABCAR		:= cTabCar
	(cAliasTMP)->CODNEG		:= cCodNeg
	(cAliasTMP)->SERVIC		:= cServic
	(cAliasTMP)->PERCUS		:= nPercus
	(cAliasTMP)->VLRRCT		:= nValReceber
	(cAliasTMP)->VLRDSPTMS	:= nPagTms
	(cAliasTMP)->VLRDSPGFE  := nPagGfe
	(cAliasTMP)->VLRDSPTOT  := nPagTms + nPagGfe
	(cAliasTMP)->OBSERV     := cObserv
	(cAliasTmp)->(MsUnlock())

EndIf

If lContinua
	nRet	:= FwExecView(,"TMSAO45",3)

	If nRet == 0
		cNumSim		:= DL3->DL3_NUMSIM
		cTabFre		:= DL3->DL3_TABFRE
		cTipTab		:= DL3->DL3_TIPTAB
		cTabCar		:= DL3->DL3_TABCAR
		nRecebe		:= DL3->DL3_VLRRCT
		nPagTms		:= DL3->DL3_VLRTMS
		nPagGFE		:= DL3->DL3_VLRGFE
		nPagTot		:= DL3->DL3_VLRTOT
		nPercus		:= DL3->DL3_PERCUS
		nRentab		:= DL3->DL3_RENTAB
		cObserv		:= DL3->DL3_OBSERV
	EndIf

	oTempTable:Delete()
	ResetTmp()
Else
	nRet	:= 1
	RollBackSX8()
EndIf

If nRet == 0
	lRet	:= .T.
Else
 	cNumSim		:= ""
 	cTabFre		:= ""
 	cTipTab		:= ""
 	cTabCar		:= ""
 	nRecebe		:= 0
 	nPagTms		:= 0
 	nPagGFE		:= 0
 	nPagTot		:= 0
 	nPercus		:= 0
 	nRentab		:= 0
	lRet	:= .F.
EndIf

aRet	:= {}
AAdd(aRet , { lRet , cFilOri , cViagem , cNumSim , cTabFre, cTipTab, cTabCar , nRecebe, nPagTMS , nPagGFE , nPagTot, nPercus , nRentab , cObserv } )

Return aRet

/*/{Protheus.doc} AO45Graf1
//Monta objeto gráfico em tela
@author caio.y
@since 04/07/2017
@version undefined
@param oView, object, ViewDef
@type function
/*/
Static Function AO45Graf1(oView)
Local oModel	:= FwModelActive()
Local cTabFre	:= ""
Local cTipTab	:= ""
Local cTabCar	:= ""
Local nValPag	:= 0
Local nValRct	:= 0
Local nRentab	:= 0
Local nPercus	:= 0
Local nCount	:= 1
Local aTabFre	:= {}
Local aPercus	:= {}
Local aSaveLine	:= FWSaveRows()

Default oView	:= FwViewActive()

oModel	:= oModel:GetModel("MdGridRes")

oGraphic1 := FWChartBarComp():New()
oGraphic1:Init( oView , .T. , .T. )
oGraphic1:SetLegend( CONTROL_ALIGN_LEFT )

For nCount := 1 To oModel:Length()

	oModel:GoLine(nCount)

	cTabFre		:= oModel:GetValue("TABFRE")
	cTipTab		:= oModel:GetValue("TIPTAB")
	cTabCar		:= oModel:GetValue("TABCAR")
	nValPag		:= oModel:GetValue("VLDSPTOT")
	nValRct		:= oModel:GetValue("VLRRCT")
	nRentab		:= oModel:GetValue("RENTAB")
	nPercus		:= oModel:GetValue("PERCUS")

	If !Empty(cTabFre)
		Aadd( aTabFre , {{ cTabFre + "/" + cTipTab , nRentab }} )
	Else
		Aadd( aTabFre , {{ cTabCar , nRentab }} )
	EndIf

Next nCount

Aadd( aPercus , { "" , nPercus } )
oGraphic1:addSerie( STR0032 , aPercus ) //-- Rentabilidade mínima

DUS->(dbSetOrder(1))
For nCount := 1 To Len(aTabFre)

	If DUS->(dbSeek(xFilial("DUS") + RTrim( aTabFre[nCount][1][1]) ))
		cTabFre		:= RetTitle("DUS_TABCAR") + ": " + aTabFre[nCount][1][1]
	Else
		cTabFre		:= RetTitle("DT6_TABFRE") + ": " + aTabFre[nCount][1][1]
	EndIf
	oGraphic1:addSerie( cTabFre, aTabFre[nCount] )

Next nCount
oGraphic1:Build()

FWRestRows( aSaveLine )
Return .T.

/*/{Protheus.doc} AO45Graf2
//Monta objeto gráfico em tela
@author caio.y
@since 04/07/2017
@version undefined
@param oView, object, ViewDef
@type function
/*/
Static Function AO45Graf2(oView)
Local aSaveLine	:= FWSaveRows()
Local aDevedor	:= {}
Local aTarget	:= {}
Local nRentab	:= 0
Local nCount	:= 0
Local cCodCli	:= ""
Local cLojCli	:= ""
Local oModel	:= FwModelActive()
Local oMdlGrid	:= oModel:GetModel("MdGridDev")
Local oMdlRes	:= oModel:GetModel("MdGridRes")

Default oView	:= FwViewActive()

oGraphic2 := FwChartLine():New()
oGraphic2:Init( oView , .T. , .T. )
oGraphic2:SetLegend( CONTROL_ALIGN_LEFT )

For nCount := 1 To oMdlGrid:Length()
	oMdlGrid:GoLine(nCount)

	cCodCli		:= oMdlGrid:GetValue("CLIDEV")
	cLojCli		:= oMdlGrid:GetValue("LOJDEV")
	nRentab		:= oMdlGrid:GetValue("RENTAB")

	Aadd(aDevedor, { RTrim(Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli , "A1_NOME")) , nRentab } )
	Aadd(aTarget , { RTrim(Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli , "A1_NOME"))  , VLR_PERCUS } )

Next nCount
oGraphic2:addSerie( STR0032 , aTarget )	 //-- Rentabilidade Mínima
oGraphic2:addSerie( STR0031 , aDevedor ) //-- Devedores
oGraphic2:Build()

FWRestRows( aSaveLine )
Return .T.

/*/{Protheus.doc} MontaTree
//TODO Monta objeto oTree
@author caio.y
@since 05/07/2017
@version undefined
@param oView, object, descricao
@type function
/*/
Static Function MontaTree(oView)
Local oFont := TFont():New('Arial',,-12,.T.)

Default oView	:= FwViewActive()

oTree := DbTree():New(0,0,0,0,oView,{|oTree|ChangeTree(oTree)},,.T.,,oFont)
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:AddItem(STR0022, "GRAF" + Space(1), "GRAF3D" ,,,,1) 	//-- Gráfico
oTree:AddItem(STR0023, "DADOS" + Space(1), "BUDGET" ,,,,1) 	//-- Dados
oTree:EndTree()

Return .T.

/*/{Protheus.doc} ChangeTree
//Função executada ao trocar de item
@author caio.y
@since 05/07/2017
@version undefined

@type function
/*/
Static Function ChangeTree(oTree,oView)
Local nAba		:= 1
Local nHide		:= 2
Local cCargo	:= ""

Default oTree	:= Nil
Default oView	:= FwViewActive()

cCargo	 := oTree:GetCargo()
If cCargo == "GRAF"
	nAba	:= 1
	nHide	:= 2
ElseIf cCargo == "DADOS"
	nAba	:= 2
	nHide	:= 1
EndIf

oView:HideFolder("PASTAS",nHide,2)
oView:SelectFolder("PASTAS",nAba ,2)

oView:Refresh()

Return .T.

/*/{Protheus.doc} AfterView
//TODO Bloco executado após Activate da ViewDef
@author caio.y
@since 05/07/2017
@version undefined
@param oView, object, ViewDef
@type function
/*/
Static Function AfterView(oView)

Default oView	:= FwViewActive()

oView:HideFolder('PASTAS',2,2)

Return

/*/{Protheus.doc} CanActView
//TODO Descrição auto-gerada.
@author caio.y
@since 20/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function CanActView(oView)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return .T.

/*/{Protheus.doc} PosVldMdl
//Pós validação do modelo de dados
@author caio.y
@since 19/07/2017
@version undefined
@param oModel, object, Modelo de Dados
@type function
/*/
/*/{Protheus.doc} PosVldMdl
//TODO Descrição auto-gerada.
@author caio.y
@since 20/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function PosVldMdl(oModel)
Local lRet	 	:= .T.
Local oMdlGrid	:= Nil
Local nCount	:= 1
Local nOpc		:= 0

Default oModel	:= FwModelActive()

oMdlGrid	:= oModel:GetModel("MdGridRes")
nOpc		:= oModel:GetOperation()

If nOpc == MODEL_OPERATION_INSERT
	lRet	:= .F.
	For nCount := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nCount)

		If oMdlGrid:GetValue("MARK")
			lRet	:= .T.
			Exit
		EndIf
	Next

	If !lRet
		Help('',1,'TMSAO4503',,) //-- É necessário escolher no mínimo 1 opção.
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} CommitMdl
//TODO Gravação do modelo de dados
@author caio.y
@since 06/07/2017
@version undefined
@param oModel, object, Modelo de dados
@type function
/*/
Static Function CommitMdl(oModel)

Local lRet			:= .T.
Local lDelFisico	:= SuperGetMv('MV_DELRENT',,.F.)
Local oMdlGrid		:= ""
Local oMdlField		:= ""
Local cNumSim		:= ""
Local cFilOri		:= ""
Local cViagem		:= ""
Local cTabFre		:= ""
Local cTipTab		:= ""
Local cTabCar		:= ""
Local cCliDev		:= ""
Local cLojDev		:= ""
Local cCodNeg		:= ""
Local cServic		:= ""
Local cObserv		:= ""
Local nVlrRct		:= 0
Local nVlrTMS		:= 0
Local nVlrGFE		:= 0
Local nVlrTot		:= 0
Local nRentab		:= 0
Local nPercus		:= 0
Local nOpc			:= 0
Local nLinAtu		:= 0
Local nCount		:= 1
Local cQuery		:= ""

Default oModel		:= FwModelActive()

nOpc	:= oModel:GetOperation()

If nOpc == MODEL_OPERATION_INSERT

	BEGIN TRANSACTION

		oMdlGrid	:= oModel:GetModel("MdGridRes")

		For nCount := 1 To oMdlGrid:Length()
			oMdlGrid:GoLine(nCount)

			If oMdlGrid:GetValue("MARK")
				cNumSim		:= oMdlGrid:GetValue("NUMSIM")
				cFilOri		:= oMdlGrid:GetValue("FILORI")
				cViagem		:= oMdlGrid:GetValue("VIAGEM")
				cTabFre		:= oMdlGrid:GetValue("TABFRE")
				cTipTab		:= oMdlGrid:GetValue("TIPTAB")
				cTabCar		:= oMdlGrid:GetValue("TABCAR")
				nVlrRct		:= oMdlGrid:GetValue("VLRRCT")
				nVlrTms		:= oMdlGrid:GetValue("VLDSPTMS")
				nVlrGFE		:= oMdlGrid:GetValue("VLDSPGFE")
				nVlrTot		:= oMdlGrid:GetValue("VLDSPTOT")
				nPercus		:= oMdlGrid:GetValue("PERCUS")
				nRentab		:= Round( oMdlGrid:GetValue("RENTAB"),TamSX3("DL3_RENTAB")[2] )
				cCodNeg		:= oMdlGrid:GetValue("CODNEG")
				cServic		:= oMdlGrid:GetValue("SERVIC")
				cObserv		:= oMdlGrid:GetValue("OBSERV")

				//-- Atualiza valores dos grids
				RefreshVlr()

				Exit
			EndIf
		Next nCount

		If RecLock("DL3",.T.)

			DL3->DL3_FILIAL	:= xFilial("DL3")
			DL3->DL3_FILORI	:= cFilOri
			DL3->DL3_VIAGEM	:= cViagem
			DL3->DL3_NUMSIM	:= cNumSim
			DL3->DL3_TABFRE	:= cTabFre
			DL3->DL3_TIPTAB	:= cTipTab
			DL3->DL3_TABCAR := cTabCar
			DL3->DL3_VLRRCT	:= nVlrRct
			DL3->DL3_VLRTMS	:= nVlrTMS
			DL3->DL3_VLRGFE	:= nVlrGFE
			DL3->DL3_VLRTOT	:= nVlrTot
			DL3->DL3_PERCUS	:= nPercus
			DL3->DL3_RENTAB	:= nRentab
			DL3->DL3_CODNEG	:= cCodNeg
			DL3->DL3_SERVIC	:= cServic
			DL3->DL3_OBSERV	:= AllTrim(cObserv)

			MsUnlock()

			oMdlGrid	:= oModel:GetModel("MdGridDev")

			For nCount := 1 To oMdlGrid:Length()
				oMdlGrid:GoLine(nCount)

				cCliDev		:= oMdlGrid:GetValue("CLIDEV")
				cLojDev		:= oMdlGrid:GetValue("LOJDEV")
				nVlrRct		:= oMdlGrid:GetValue("VLRRCT")
				nVlrTMS		:= oMdlGrid:GetValue("VLDSPTMS")
				nVlrGFE		:= oMdlGrid:GetValue("VLDSPGFE")
				nVlrTot		:= oMdlGrid:GetValue("VLDSPTOT")
				nRentab		:= Round( oMdlGrid:GetValue("RENTAB") , TamSX3("DL4_RENTAB")[2] )

				RecLock("DL4",.T.)
				DL4->DL4_FILIAL		:= xFilial("DL4")
				DL4->DL4_NUMSIM		:= cNumSim
				DL4->DL4_FILORI		:= cFilOri
				DL4->DL4_VIAGEM		:= cViagem
				DL4->DL4_CLIDEV		:= cCliDev
				DL4->DL4_LOJDEV		:= cLojDev
				DL4->DL4_VLRRCT		:= nVlrRct
				DL4->DL4_VLRTMS		:= nVlrTMS
				DL4->DL4_VLRGFE		:= nVlrGfe
				DL4->DL4_VLRTOT		:= nVlrTot
				DL4->DL4_RENTAB		:= nRentab
				MsUnlock()

			Next nCount

			ConfirmSx8()
		Else
			RollBackSX8()
		EndIf

	END TRANSACTION

ElseIf nOpc == MODEL_OPERATION_DELETE

	oMdlGrid	:= oModel:GetModel("MdGridRes")
	cNumSim		:= oMdlGrid:GetValue("NUMSIM")

	BEGIN TRANSACTION

		lRet	:= AO45ExcRent(cNumSim)

		If lRet
			//-- Exclui cache
			ResetTmp()
		EndIf

	END TRANSACTION

EndIf

TmsKeyOff(aSetKey)

Return lRet

/*/{Protheus.doc} AO45ExcRent
//Exclusão rentabilidade prévia
@author caio.y
@since 21/07/2017
@version undefined
@param cNumSim, characters, descricao
@type function
/*/
Function AO45ExcRent(cNumSim)
Local lDelFisico	:= SuperGetMv('MV_DELRENT',,.F.)
Local cQuery		:= ""
Local lRet			:= .T.

Default cNumSim		:= ""

If lDelFisico

	cQuery 	:= "DELETE FROM " + RetSQLName("DL3") + " "
	cQuery 	+= "WHERE DL3_FILIAL = '" + xFilial("DL3") + "' "
	cQuery	+= " AND DL3_NUMSIM = '" + cNumSim + "' "
	If TCSqlExec( cQuery ) < 0
		lRet	:= .F.
	Else
		cQuery 	:= "DELETE FROM " + RetSQLName("DL4") + " "
		cQuery 	+= "WHERE DL4_FILIAL = '" + xFilial("DL4") + "' "
		cQuery	+= " AND DL4_NUMSIM = '" + cNumSim + "' "
		If TCSqlExec( cQuery ) < 0
			lRet	:= .F.
		EndIf

	EndIf

Else

	DL3->(dbSetOrder(1)) //-- FILIAL+NUMSIM
	DL4->(dbSetOrder(1)) //-- FILIAL+NUMSIM
	If DL3->(MsSeek(xFilial("DL3") + cNumSim ))
		While DL3->(!Eof()) .And. DL3->(DL3_FILIAL+DL3_NUMSIM) == xFilial("DL3") + cNumSim
			RecLock("DL3",.F.)
			DL3->( dbDelete() )
			DL3->(dbSkip())
		EndDo
	EndIf

	If DL4->(MsSeek(xFilial("DL4") + cNumSim ))
		While DL4->(!Eof()) .And. DL4->(DL4_FILIAL+DL4_NUMSIM) == xFilial("DL4") + cNumSim
			RecLock("DL4",.F.)
			DL4->( dbDelete() )
			DL4->(dbSkip())
		EndDo
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} CancelMdl
//TODO Descrição auto-gerada.
@author caio.y
@since 11/07/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function CancelMdl(oModel)
Local nOpc	:= 3

Default oModel	:= FwModelActive()

nOpc := oModel:GetOperation()

If nOpc == MODEL_OPERATION_INSERT
	RollBackSX8()
EndIf

TmsKeyOff(aSetKey)

Return .T.

/*/{Protheus.doc} RefreshVlr
//Função realiza o refresh dos valores
@author caio.y
@since 12/07/2017
@version undefined

@type function
/*/
Static Function RefreshVlr()
Local oModel		:= FwModelActive()
Local oMdlRes		:= oModel:GetModel("MdGridRes")
Local oMdlDoc		:= oModel:GetModel("MdGridDoc")
Local oMdlDev		:= oModel:GetModel("MdGridDev")
Local lRet			:= .T.
Local nVlrTMS		:= 0
Local nVlrGFE		:= 0
Local nVlrRecebe	:= 0
Local nTotPag		:= 0
Local nPercus		:= 0
Local nRentab		:= ""
Local cStatus		:= "BR_VERDE"
Local nLineAtu		:= oMdlRes:GetLine()
Local nCount		:= 1
Local oView			:= FwViewActive()
Local aSaveLines	:= FWSaveRows()

If nLineAtu >= 0
	oMdlRes:GoLine(nLineAtu)

	nVlrRecebe	:= oMdlRes:GetValue("VLRRCT")
	nVlrTms		:= oMdlRes:GetValue("VLDSPTMS")
	nVlrGfe		:= oMdlRes:GetValue("VLDSPGFE")
	nTotPag		:= oMdlRes:GetValue("VLDSPTOT")
	nPercus		:= oMdlRes:GetValue("PERCUS")

	//-- Cache de memória com os valores totais da primeira linha
	VLR_RECEBER	:= nVlrRecebe
	VLR_PAGTMS	:= nVlrTMS
	VLR_PAGGFE	:= nVlrGFE
	VLR_PAGTOT	:= nTotPag
	VLR_PERCUS	:= nPercus

	//-- Atualiza valores dos devedores
	For nCount := 1 To oMdlDev:Length()
		oMdlDev:GoLine(nCount)

		nVlrRecebe	:= oMdlDev:GetValue("VLRRCT")
		nVlrTMS		:= RateiaVal( "2" , oMdlDev:GetValue("PESOM3") , oMdlDev:GetValue("PESO") , oMdlDev:GetValue("VALMER") , oMdlDev:GetValue("QTDVOL")  )
		nVlrGFE		:= RateiaVal( "3" , oMdlDev:GetValue("PESOM3") , oMdlDev:GetValue("PESO") , oMdlDev:GetValue("VALMER") , oMdlDev:GetValue("QTDVOL")  )
		nTotPag		:= RateiaVal( "4" , oMdlDev:GetValue("PESOM3") , oMdlDev:GetValue("PESO") , oMdlDev:GetValue("VALMER") , oMdlDev:GetValue("QTDVOL")   )

		nRentab		:= ((nVlrRecebe/nTotPag) - 1 ) * 100
		nRentab		:= Round( nRentab , 2  )

		If nRentab <= 0 .Or. nRentab < VLR_PERCUS
			cStatus	:= "BR_VERMELHO"
		ElseIf nRentab == VLR_PERCUS
			cStatus	:= "BR_AMARELO"
		ElseIf nRentab > VLR_PERCUS
			cStatus	:= "BR_VERDE"
		EndIf

		oMdlDev:LoadValue("LOG_BTSTA",cStatus)
		oMdlDev:LoadValue("VLDSPTMS",nVlrTMS)
		oMdlDev:LoadValue("VLDSPGFE",nVlrGFE)
		oMdlDev:LoadValue("VLDSPTOT",nTotPag)
		oMdlDev:LoadValue("RENTAB"	,nRentab)

	Next nCount

	//-- Atualiza valores dos documentos
	For nCount := 1 To oMdlDoc:Length()
		oMdlDoc:GoLine(nCount)

		nVlrRecebe	:= oMdlDoc:GetValue("VLRRCT")
		nVlrTMS		:= RateiaVal( "2" , oMdlDoc:GetValue("PESOM3") , oMdlDoc:GetValue("PESO") , oMdlDoc:GetValue("VALMER") , oMdlDoc:GetValue("QTDVOL")  )
		nVlrGFE		:= RateiaVal( "3" , oMdlDoc:GetValue("PESOM3") , oMdlDoc:GetValue("PESO") , oMdlDoc:GetValue("VALMER") , oMdlDoc:GetValue("QTDVOL")  )
		nTotPag		:= RateiaVal( "4" , oMdlDoc:GetValue("PESOM3") , oMdlDoc:GetValue("PESO") , oMdlDoc:GetValue("VALMER") , oMdlDoc:GetValue("QTDVOL")  )

		nRentab		:= ((nVlrRecebe/nTotPag) - 1 ) * 100
		nRentab		:= Round( nRentab , 2  )

		If nRentab <= 0 .Or. nRentab < VLR_PERCUS
			cStatus	:= "BR_VERMELHO"
		ElseIf nRentab == VLR_PERCUS
			cStatus	:= "BR_AMARELO"
		ElseIf nRentab > VLR_PERCUS
			cStatus	:= "BR_VERDE"
		EndIf

		oMdlDoc:LoadValue("LOG_BTSTA",cStatus)
		oMdlDoc:LoadValue("VLDSPTMS",nVlrTMS)
		oMdlDoc:LoadValue("VLDSPGFE",nVlrGFE)
		oMdlDoc:LoadValue("VLDSPTOT",nTotPag)
		oMdlDoc:LoadValue("RENTAB"	,nRentab)

	Next nCount

EndIf

oView:Refresh()

FWRestRows( aSaveLines )
Return lRet

/*/{Protheus.doc} RetInfoTot
//Retorna as informações do total PESO e PESOM3
@author caio.y
@since 12/07/2017
@version undefined
@param cTabela, characters, Tabela
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Static Function RetInfoTot(cTabela , cFilOri , cViagem )
Local aArea		:= GetArea()
Local aRet		:= {}
Local cAliasQry	:= ""
Local cQuery	:= ""

Default cTabela		:= "DT6"
Default cFilOri		:= ""
Default cViagem		:= ""

If cTabela == "DT6"

	cAliasQry	:= GetNextAlias()

	cQuery	:= " SELECT DT6_PESO PESO , DT6_PESOM3 PESOM3 , DT6_VALMER VALMER , DT6_QTDVOL QTDVOL "
	cQuery	+= " FROM " + RetSQLName("DUD") + " DUD "
	cQuery	+= " INNER JOIN " + RetSQLName("DT6") + "  DT6 "
	cQuery	+= " 	ON DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery	+= " 	AND DT6_FILDOC = DUD_FILDOC "
	cQUery	+= " 	AND DT6_DOC = DUD_DOC "
	cQuery	+= " 	AND DT6_SERIE = DUD_SERIE "
	cQuery	+= "	AND DT6.D_E_L_E_T_ = '' "
	cQuery	+= " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery	+= " 	AND DUD_FILORI = '" + cFilOri + "' "
	cQuery	+= " 	AND DUD_VIAGEM = '" + cViagem + "' "
	cQuery	+= " 	AND DUD.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	While (cAliasQry)->(!Eof())
		Aadd(aRet , { (cAliasQry)->PESO , (cAliasQry)->PESOM3 , (cAliasQry)->VALMER , (cAliasQry)->QTDVOL } )
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

EndIf

RestArea(aArea)
Return aRet

/*/{Protheus.doc} RateiaVal
//A função realiza o rateio dos valores de acordo com parametrização de rateio de frete
@author caio.y
@since 13/07/2017
@version undefined
@param cTipo, characters, Tipo: 1= Receber;2=Pagar TMS;3=Pagar GFE;4=Pagar Total
@param nPesoM3, numeric, Peso cubado
@param nPeso, numeric, Peso Real
@param nValMer, numeric, Valor Mercadoria
@param nQtdVol, numeric, Quantidade de Volumes
@type function
/*/
Static Function RateiaVal( cTipo , nPesoM3 , nPeso , nValMer , nQtdVol )
Local nRet			:= 0
Local nPesoTot		:= 0

Default cTipo	:= "" //-- 1=Receber;2=Pagar TMS;3=Pagar GFE;4=Pagar Total
Default nPesoM3	:= 0
Default nPeso	:= 0
Default nValMer	:= 0
Default nQtdVol	:= 0

Pergunte("TMSAO45",.F.)

//-- Rateio de valores
If mv_par03 == '1' //-- PESO REAL X PESO CUBADO

	nPesoTot	:= PESOM3REAL

	If nPesoM3 > 0 .And. nPesoM3 > nPeso
		If cTipo == "1"
				nRet	:= ( nPesoM3 * VLR_RECEBER ) / nPesoTot
			ElseIf cTipo == "2"
				nRet	:= ( nPesoM3 * VLR_PAGTMS ) / nPesoTot
			ElseIf cTipo == "3"
				nRet	:= ( nPesoM3 * VLR_PAGGFE ) / nPesoTot
			ElseIf cTipo == "4"
				nRet	:= ( nPesoM3 * VLR_PAGTOT ) / nPesoTot
			EndIf
		Else
			If cTipo == "1"
				nRet	:= ( nPeso * VLR_RECEBER ) / nPesoTot
			ElseIf cTipo == "2"
				nRet	:= ( nPeso * VLR_PAGTMS ) / nPesoTot
			ElseIf cTipo == "3"
				nRet	:= ( nPeso * VLR_PAGGFE ) / nPesoTot
			ElseIf cTipo == "4"
				nRet	:= ( nPeso * VLR_PAGTOT ) / nPesoTot
			EndIf
	EndIf

ElseIf mv_par03 == '2' //-- PESO REAL

	If cTipo == "1"
		nRet	:= ( nPeso * VLR_RECEBER ) / PESO_TOT
	ElseIf cTipo == "2"
		nRet	:= ( nPeso * VLR_PAGTMS ) / PESO_TOT
	ElseIf cTipo == "3"
		nRet	:= ( nPeso * VLR_PAGGFE ) / PESO_TOT
	ElseIf cTipo == "4"
		nRet	:= ( nPeso * VLR_PAGTOT ) / PESO_TOT
	EndIf

ElseIf mv_par03 == '3' //-- PESO CUBADO

	If cTipo == "1"
		nRet	:= ( nPesoM3 * VLR_RECEBER ) / PESOM3_TOT
	ElseIf cTipo == "2"
		nRet	:= ( nPesoM3 * VLR_PAGTMS ) / PESOM3_TOT
	ElseIf cTipo == "3"
		nRet	:= ( nPesoM3 * VLR_PAGGFE ) / PESOM3_TOT
	ElseIf cTipo == "4"
		nRet	:= ( nPesoM3 * VLR_PAGTOT ) / PESOM3_TOT
	EndIf

ElseIf mv_par03 == '4' //-- VALOR

	If cTipo == "1"
		nRet	:= ( nValMer * VLR_RECEBER ) / VALMER_TOT
	ElseIf cTipo == "2"
		nRet	:= ( nValMer * VLR_PAGTMS ) / VALMER_TOT
	ElseIf cTipo == "3"
		nRet	:= ( nValMer * VLR_PAGGFE ) / VALMER_TOT
	ElseIf cTipo == "4"
		nRet	:= ( nValMer * VLR_PAGTOT ) / VALMER_TOT
	EndIf

ElseIf mv_par03 == '5' .Or.mv_par03 == '6' //-- VOLUME ou QUANTIDADE

	If cTipo == "1"
		nRet	:= ( nQtdVol * VLR_RECEBER ) / QTDVOL_TOT
	ElseIf cTipo == "2"
		nRet	:= ( nQtdVol * VLR_PAGTMS ) / QTDVOL_TOT
	ElseIf cTipo == "3"
		nRet	:= ( nQtdVol * VLR_PAGGFE ) / QTDVOL_TOT
	ElseIf cTipo == "4"
		nRet	:= ( nQtdVol * VLR_PAGTOT ) / QTDVOL_TOT
	EndIf

EndIf

nRet	:= Round(nRet,2)

Return nRet

/*/{Protheus.doc} AO45Leg
//Legenda
@author caio.y
@since 14/07/2017
@version undefined

@type function
/*/
Static Function AO45Leg( lF5 )
Local aCores	:= {}

Default lF5		:= .F.

aCores := {	{ 'BR_VERDE'	, STR0034	},;		//-- "Rentabilidade acima do esperado"
			{ 'BR_AMARELO'	, STR0035	},;		//-- "Rentabilidade igual ao esperado"
			{ 'BR_VERMELHO'	, STR0036	},;		//-- "Rentabilidade abaixo do esperado"
			{ 'PMSINFO'     , STR0038 	},;		//-- "Erros encontrados durante o cálculo de frete"
			{ "f10_azul"	, AllTrim(STR0042) + " " +STR0043	},;		//-- "Rateio Valores" "Peso Real X Peso Cubado"
			{ "f10_cinz"	, AllTrim(STR0042) + " " +STR0044	},;		//-- "Rateio Valores" "Peso Real"
			{ "f10_lara"	, AllTrim(STR0042) + " " +STR0045	},;		//-- "Rateio Valores" "Peso Cubado"
			{ "f10_pret"	, AllTrim(STR0042) + " " +STR0049	},;		//-- "Rateio Valores" "Valor mercadoria"
			{ "f10_amar"	, AllTrim(STR0042) + " " +STR0050	},;		//-- "Rateio Valores" "Volumes"
			{ "f10_pink"	, AllTrim(STR0042) + " " +STR0051	}}		//-- "Rateio Valores" "Quantidade"

If lF5
	TmsKeyOff(aSetKey)
EndIf

BrwLegenda( STR0033 + " " + STR0006 , STR0033, aCores) //'Legenda Rentabilidade'

If lF5
	TmsKeyOn(aSetKey)
EndIf

Return NIL

/*/{Protheus.doc} RetGridDev
// Retorna o grid de devedores
@author caio.y
@since 19/07/2017
@version undefined
@param cNumSim, characters, Simulação
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Static Function RetGridDev(cNumSim,cFilOri,cViagem)
Local aLoad			:= {}
Local cItem			:= ""
Local cQuery		:= ""
Local cAliasQry		:= ""
Local nValRecebe	:= 0
Local nValPagTms	:= 0
Local nValPagGfe	:= 0
Local nTotPag		:= 0
Local nRentab		:= 0
Local cStatus		:= "BR_VERMELHO"

Default cNumSim		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT DISTINCT( CASE WHEN DT6_TIPFRE = '1' THEN DT6_CLIDEV ELSE DT6_CLIDES END ) DEVEDOR, "
cQuery	+= " CASE WHEN DT6_TIPFRE = '1' THEN DT6_LOJDEV ELSE DT6_LOJDES END LOJA , "
cQuery	+= " SUM(DT6_PESO) PESO , SUM(DT6_PESOM3) PESOM3 , SUM(DT6_VALFRE) VALFRE , SUM(DT6_VALMER) VALMER , SUM(DT6_QTDVOL) QTDVOL  "
cQuery	+= " FROM " + RetSQLName("DUD") + " DUD "
cQuery	+= " INNER JOIN " + RetSQLName("DT6") + "  DT6 "
cQuery	+= " 	ON DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery	+= " 	AND DT6_FILDOC = DUD_FILDOC "
cQUery	+= " 	AND DT6_DOC = DUD_DOC "
cQuery	+= " 	AND DT6_SERIE = DUD_SERIE "
cQuery	+= "	AND DT6.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI = '" + cFilOri + "' "
cQuery	+= " 	AND DUD_VIAGEM = '" + cViagem + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ = '' "
cQuery	+= " GROUP BY CASE WHEN DT6_TIPFRE = '1' THEN DT6_CLIDEV ELSE DT6_CLIDES END , CASE WHEN DT6_TIPFRE = '1' THEN DT6_LOJDEV ELSE DT6_LOJDES END  "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

cItem	:= "000"

While (cAliasQry)->( !Eof() )

	nValRecebe	:= (cAliasQry)->VALFRE
	nValPagTms	:= RateiaVal( "2" , (cAliasQry)->PESOM3 , (cAliasQry)->PESO , (cAliasQry)->VALMER , (cAliasQry)->QTDVOL )
	nValPagGfe	:= RateiaVal( "3" , (cAliasQry)->PESOM3 , (cAliasQry)->PESO , (cAliasQry)->VALMER , (cAliasQry)->QTDVOL  )
	nTotPag		:= RateiaVal( "4" , (cAliasQry)->PESOM3 , (cAliasQry)->PESO , (cAliasQry)->VALMER , (cAliasQry)->QTDVOL  )

	nRentab		:= ((nValRecebe/nTotPag) - 1 ) * 100
	nRentab		:= Round( nRentab , 2  )

	If nRentab <= 0  .Or. nRentab < VLR_PERCUS
		cStatus	:= "BR_VERMELHO"
	ElseIf nRentab == VLR_PERCUS
		cStatus	:= "BR_AMARELO"
	ElseIf nRentab > VLR_PERCUS
		cStatus	:= "BR_VERDE"
	EndIf

	aAdd(aLoad,{0,{xFilial("SA1"),;	//-- FILIAL
		cNumSim,;					//-- NUMSIM
		cFilOri,;					//-- FILORI
		cViagem,;					//-- VIAGEM
		cItem	:= Soma1( cItem ),;	//-- ITEM
		cStatus,;					//-- STATUS
		(cAliasQry)->DEVEDOR,;		//-- CLIDEV
		(cAliasQry)->LOJA,;			//-- LOJDEV
		Posicione("SA1",1,xFilial("SA1") + (cAliasQry)->DEVEDOR + (cAliasQry)->LOJA , "A1_NOME" ),;		//-- NOMDEV
		nValRecebe,; 				//-- VLRRCT
		nValPagTms,;				//-- VLDSPTMS
		nValPagGfe,;				//-- VLDSPGFE
		nTotPag,;					//-- VLDSPTOT
		nRentab,;					//-- RENTAB
		(cAliasQry)->PESO,;			//-- PESO
		(cAliasQry)->PESOM3,; 		//-- PESOM3
		(cAliasQry)->VALMER,; 		//-- VALMER
		(cAliasQry)->QTDVOL	}})		//-- QTDVOL

	(cAliasQry)->(dbSkip())
EndDo

Return aLoad

/*/{Protheus.doc} RetGridDoc
//Retorna as informações dos conhecimentos de transporte
@author caio.y
@since 19/07/2017
@version undefined
@param cNumSim, characters, Simulação
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Static Function RetGridDoc(cNumSim , cFilOri, cViagem )
Local cQuery		:= ""
Local cAliasQry		:= ""
Local aLoad			:= {}
Local cItem			:= ""
Local nValRecebe	:= 0
Local nValPagTms	:= 0
Local nValPagGfe	:= 0
Local nTotPag		:= 0
Local nRentab		:= 0
Local cStatus		:= "BR_VERMELHO"

Default cNumSim		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT DT6_FILDOC FILDOC , DT6_DOC DOC , DT6_SERIE SERIE , DT6_DATEMI DATAEMI , DT6_CLIREM CLIREM , DT6_LOJREM LOJREM , DT6_CLIDES CLIDES , DT6_LOJDES LOJDES , DT6_CDRORI CDRORI , DT6_CDRDES CDRDES , "
cQuery	+= " DT6_ROTENT ROTA ,  DT6_PESO PESO , DT6_PESOM3 PESOM3 , DT6_VALFRE VALFRE , DT6_VALMER VALMER , DT6_QTDVOL QTDVOL   "
cQuery	+= " FROM " + RetSQLName("DUD") + " DUD "
cQuery	+= " INNER JOIN " + RetSQLName("DT6") + "  DT6 "
cQuery	+= " 	ON DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery	+= " 	AND DT6_FILDOC = DUD_FILDOC "
cQUery	+= " 	AND DT6_DOC = DUD_DOC "
cQuery	+= " 	AND DT6_SERIE = DUD_SERIE "
cQuery	+= "	AND DT6.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI = '" + cFilOri + "' "
cQuery	+= " 	AND DUD_VIAGEM = '" + cViagem + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ = ''  "
cQuery	+= " ORDER BY 1,2,3 "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

cItem	:= "000"

While (cAliasQry)->( !Eof() )

	nValRecebe	:= (cAliasQry)->VALFRE
	nValPagTms	:= RateiaVal( "2" , (cAliasQry)->PESOM3 , (cAliasQry)->PESO , (cAliasQry)->VALMER , (cAliasQry)->QTDVOL )
	nValPagGfe	:= RateiaVal( "3" , (cAliasQry)->PESOM3 , (cAliasQry)->PESO , (cAliasQry)->VALMER , (cAliasQry)->QTDVOL  )
	nTotPag		:= RateiaVal( "4" , (cAliasQry)->PESOM3 , (cAliasQry)->PESO , (cAliasQry)->VALMER , (cAliasQry)->QTDVOL  )

	nRentab		:= ((nValRecebe/nTotPag) - 1 ) * 100
	nRentab		:= Round( nRentab , 2  )

	If nRentab <= 0 .Or. nRentab < VLR_PERCUS
		cStatus	:= "BR_VERMELHO"
	ElseIf nRentab == VLR_PERCUS
		cStatus	:= "BR_AMARELO"
	ElseIf nRentab > VLR_PERCUS
		cStatus	:= "BR_VERDE"
	EndIf

	aAdd(aLoad,{0,{xFilial("DT6"),;			//-- FILIAL
		cNumSim,;							//-- NUMSIM
		cFilOri,;							//-- FILORI
		cViagem,;							//-- VIAGEM
		cItem := Soma1(cItem),;				//-- ITEM
		cStatus,;							//-- STATUS
		(cAliasQry)->FILDOC,;				//-- FILDOC
		(cAliasQry)->DOC,;					//-- DOC
		(cAliasQry)->SERIE,;				//-- SERIE
		SToD( (cAliasQry)->DATAEMI ),; 		//-- DATAEMI
		(cAliasQry)->CLIREM,;				//-- CLIREM
		(cAliasQry)->LOJREM,;				//-- LOJREM
		Posicione("SA1",1,xFilial("SA1") + (cAliasQry)->CLIREM + (cAliasQry)->LOJREM, "A1_NOME"),;		//-- NOMREM
		(cAliasQry)->CLIDES,;				//-- CLIDES
		(cAliasQry)->LOJDES,;				//-- LOJDES
		Posicione("SA1",1,xFilial("SA1") + (cAliasQry)->CLIDES + (cAliasQry)->LOJDES, "A1_NOME"),;		//-- NOMDES
		(cAliasQry)->CDRORI,;				//-- CDRORI
		(cAliasQry)->CDRDES,;				//-- CDRDES
		(cAliasQry)->ROTA,;					//-- ROTA
		(cAliasQry)->PESO,;					//-- PESO
		(cAliasQry)->PESOM3,;				//-- PESOM3
		nValRecebe,;						//-- VLRRCT
		nValPagTms,;						//-- VLDSPTMS
		nValPagGfe,;						//-- VLDSPGFE
		nTotPag,;							//-- VLDSPTOT
		nRentab,;							//-- RENTAB
		(cAliasQry)->VALMER,;				//-- VALMER
		(cAliasQry)->QTDVOL}})				//-- QTDVOL

	(cAliasQry)->( dbSkip() )
EndDo

Return aLoad

/*/{Protheus.doc} RetGridNf
//Retorna notas fiscais e itens das solicitações de coleta
@author caio.y
@since 19/07/2017
@version undefined
@param cNumSim, characters  Número simulação
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Static Function RetGridNf(cNumSim , cFilOri,cViagem)
Local cAliasQry		:= ""
Local cQuery		:= ""
Local cItem			:= ""
Local aLoad			:= {}

Default cNumSim		:= ""
Default cFilOri		:= DL3->DL3_FILORI
Default cViagem		:= DL3->DL3_VIAGEM

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT DTC_FILDOC FILDOC, DTC_NUMNFC NUMNFC , DTC_SERNFC SERNFC , DTC_EMINFC EMINFC , DTC_CDRORI CDRORI , DTC_CDRDES CDRDES , DTC_ROTA ROTA ,"
cQuery	+= " DTC_PESO PESO , DTC_PESOM3 PESOM3 "
cQuery	+= " FROM " + RetSQLName("DUD") + " DUD "
cQuery	+= " INNER JOIN " + RetSQLName("DT6") + "  DT6 "
cQuery	+= " 	ON DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery	+= " 	AND DT6_FILDOC = DUD_FILDOC "
cQUery	+= " 	AND DT6_DOC = DUD_DOC "
cQuery	+= " 	AND DT6_SERIE = DUD_SERIE "
cQuery	+= "	AND DT6.D_E_L_E_T_ = '' "
cQuery	+= " INNER JOIN " + RetSQLName("DTC") + " DTC "
cQuery	+= " 	ON DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery	+= " 	AND DTC_FILDOC = DT6_FILDOC "
cQuery	+= "	AND DTC_DOC = DT6_DOC "
cQuery	+= "	AND DTC_SERIE = DT6_SERIE "
cQuery	+= "    AND DTC.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI = '" + cFilOri + "' "
cQuery	+= " 	AND DUD_VIAGEM = '" + cViagem + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ = '' "
cQuery	+= " UNION ALL ( "
cQuery	+= " SELECT DT5_FILDOC FILDOC, DUM_NUMSOL NUMNFC , DT5_SERIE SERNFC , "
cQuery	+= " DT5_DATSOL EMINFC , DT5_CDRORI CDRORI , DT5_CDRDCA CDRDES , DT5_ROTPRE ROTA ,"
cQuery	+= " DUM_PESO PESO , DUM_PESOM3 PESOM3 "
cQuery	+= " FROM " + RetSQLName("DUD") + " DUD "
cQuery	+= " INNER JOIN " + RetSQLName("DT5") + "  DT5 "
cQuery	+= " 	ON DT5_FILIAL = '" + xFilial("DT5") + "' "
cQuery	+= " 	AND DT5_FILORI = DUD_FILDOC "
cQUery	+= " 	AND DT5_DOC = DUD_DOC "
cQuery	+= " 	AND DT5_SERIE = DUD_SERIE "
cQuery	+= "	AND DT5.D_E_L_E_T_ = '' "
cQuery	+= " INNER JOIN " + RetSQLName("DUM") + " DUM "
cQuery	+= " 	ON DUM_FILIAL = '" + xFilial("DUM") + "' "
cQuery	+= " 	AND DUM_FILORI = DT5_FILORI "
cQuery	+= "	AND DUM_NUMSOL = DT5_NUMSOL "
cQuery	+= "    AND DUM.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI = '" + cFilOri + "' "
cQuery	+= " 	AND DUD_VIAGEM = '" + cViagem + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ = ''  ) "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

cItem	:= "000"

While (cAliasQry)->( !Eof() )

	aAdd(aLoad,{0,{xFilial("DTC"),;			//-- FILIAL
		cNumSim,;							//-- NUMSIM
		cFilOri,;							//-- FILORI
		cViagem,;							//-- VIAGEM
		cItem	:= Soma1(cItem),;			//-- ITEM
		(cAliasQry)->FILDOC,;				//-- FILDOC
		(cAliasQry)->NUMNFC,;				//-- NUMNFC
		(cAliasQry)->SERNFC,;				//-- SERNFC
		SToD( (cAliasQry)->EMINFC ),; 		//-- EMINFC
		(cAliasQry)->CDRORI,;				//-- CDRORI
		(cAliasQry)->CDRDES,;				//-- CDRDES
		(cAliasQry)->ROTA,;					//-- ROTA
		(cAliasQry)->PESO,;					//-- PESO
		(cAliasQry)->PESOM3}})				//-- PESOM3

	(cAliasQry)->(dbSkip())

EndDo

Return aLoad

/*/{Protheus.doc} RetGridGFE
//TODO Descrição auto-gerada.
@author caio.y
@since 28/07/2017
@version undefined
@param cNumSim, characters, Numero Simulação
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@param oModel, objetct, Modelo de Dados
@type function
/*/
Static Function RetGridGFE(cNumSim , cFilOri,cViagem, oModel )
Local cAliasQry		:= ""
Local cQuery		:= ""
Local cItem			:= "000"
Local cCodFor		:= ""
Local cLojFor		:= ""
Local cTransp		:= ""
Local cNomeTrans	:= ""
Local cCgcTransp	:= ""
Local lPagGfe		:= .F.
Local lNumProp   	:= SuperGetMv("MV_EMITMP") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
Local aLoad			:= {}
Local aAreaDTQ		:= DTQ->(GetArea())
Local aAreaDTR		:= DTR->(GetArea())
Local oMdlGridDoc	:= Nil
Local cFilDoc		:= ""
Local cDoc			:= ""
Local cSerie		:= ""

Default cNumSim		:= ""
Default cFilOri		:= DL3->DL3_FILORI
Default cViagem		:= DL3->DL3_VIAGEM
Default oModel		:= Nil

oMdlGridDoc		:= oModel:GetModel("MdGridDoc")
oMdlGridDoc		:= oMdlGridDoc:GetModel("MdGridDoc")

cFilDoc		:= oMdlGridDoc:GetValue("FILDOC")
cDoc		:= oMdlGridDoc:GetValue("DOC")
cSerie		:= oMdlGridDoc:GetValue("SERIE")

DTQ->(dbSetOrder(2))
If DTQ->(dbSeek(xFilial("DTQ") + cFilOri + cViagem))
	lPagGfe		:= IIf(DTQ->DTQ_PAGGFE == "1" , .T. , .F.)
EndIf

If lPagGfe

	DTR->(dbSetOrder(1))
	If DTR->( dbSeek(xFilial("DTR") + cFilOri + cViagem ))
		cCodFor		:= DTR->DTR_CODFOR
		cLojFor		:= DTR->DTR_LOJFOR
		cTransp		:= Posicione("SA2",1,xFilial('SA2')+cCodFor+cLojFor,"A2_TRANSP")

		If Empty(cTransp)
			SA2->( dbSetOrder(1) )
			If SA2->( dbSeek( xFilial("SA2")+cCodFor+cLojFor ))
				If !lNumProp
					cCgcTransp 	:= IIF(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA) )
				Else
					cCgcTransp := OMSM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
				EndIf
			EndIf
		Else
			If lNumProp
				cCgcTransp := Posicione("GU3",13,xFilial("GU3")+cTransp,"GU3_CDEMIT")
			Else
				cCgcTransp := Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_CGC")
			EndIf
		EndIf
	EndIf

	cNomeTrans	:= RTrim( POSICIONE("GU3",1,XFILIAL("GU3")+cCgcTransp,"GU3_NMEMIT") )

	cAliasQry	:= GetNextAlias()

	cQuery	:= " SELECT * "
	cQuery	+= " FROM " + RetSQlName("DUD") + " DUD "
	cQuery	+= " WHERE DUD_FILIAL 	= '" + xFilial("DUD") + "' "
	cQuery	+= " 	AND DUD_FILORI 	= '" + cFilOri+ "' "
	cQuery	+= " 	AND DUD_VIAGEM  = '" + cViagem + "' "
	cQuery	+= "    AND DUD_FILDOC  = '" + cFilDoc +"' "
	cQuery	+= "    AND DUD_DOC  	= '" + cDoc +"' "
	cQuery	+= "    AND DUD_SERIE  	= '" + cSerie +"' "
	cQuery	+= "	AND DUD.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	While (cAliasQry)->( !Eof() )

		aAdd(aLoad,{0,{xFilial("DTC"),;						//-- FILIAL
						cNumSim,;							//-- NUMSIM
						cFilOri,;							//-- FILORI
						cViagem,;							//-- VIAGEM
						cFilDoc,;							//-- FILDOC
						cDoc,;								//-- DOC
						cSerie,;							//-- SERIE
						cItem	:= Soma1(cItem),;			//-- ITEM
						cCgcTransp,; 						//-- CGCTRAN
						cNomeTrans,;						//-- NOMETRAN
						TMS120CDUF((cAliasQry)->DUD_UFDES, "1") + (cAliasQry)->DUD_CDMUND ,;	//-- MUNDES
						Posicione("CC2",1,xFilial("CC2")+(cAliasQry)->DUD_UFDES+(cAliasQry)->DUD_CDMUND,"CC2_MUN"),;		//-- NOMEMUNDES
						(cAliasQry)->DUD_UFDES ,;			//-- UFDEST
						TMS120CDUF( (cAliasQry)->DUD_UFORI , "1") + (cAliasQry)->DUD_CDMUNO,;	//-- MUNORI
						Posicione("CC2",1,xFilial("CC2")+(cAliasQry)->DUD_UFORI+(cAliasQry)->DUD_CDMUNO,"CC2_MUN"),;		//-- NOMEMUNORI
						(cAliasQry)->DUD_UFORI,;			//-- UFORI
						(cAliasQry)->DUD_CEPORI,;			//-- CEPORI
						(cAliasQry)->DUD_CEPDES }} )		//-- CEPDES

		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->(dbCloseArea())

EndIf

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT * "
cQuery	+= " FROM " + RetSQlName("DUD") + " DUD "
cQuery	+= " 	INNER JOIN " + RetSQlName("DJN") + " DJN "
cQuery	+= " 		ON DJN_FILIAL 	= '" + xFilial("DJN") + "' "
cQuery	+= " 		AND DJN_FILDOC 	= DUD_FILDOC "
cQuery	+= " 		AND DJN_DOC 	= DUD_DOC "
cQuery	+= " 		AND DJN_SERIE 	= DUD_SERIE "
cQuery	+= " 		AND DJN.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DUD_FILIAL 	= '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI 	= '" + cFilOri+ "' "
cQuery	+= " 	AND DUD_VIAGEM  = '" + cViagem + "' "
cQuery	+= "    AND DUD_FILDOC  = '" + cFilDoc +"' "
cQuery	+= "    AND DUD_DOC  	= '" + cDoc +"' "
cQuery	+= "    AND DUD_SERIE  	= '" + cSerie +"' "
cQuery	+= "	AND DUD.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

While (cAliasQry)->( !Eof() )

	cCodFor		:= (cAliasQry)->DJN_CODFOR
	cLojFor		:= (cAliasQry)->DJN_LOJFOR
	cTransp		:= Posicione("SA2",1,xFilial('SA2')+cCodFor+cLojFor,"A2_TRANSP")

	If Empty(cTransp)
		SA2->( dbSetOrder(1) )
		If SA2->( dbSeek( xFilial("SA2")+cCodFor+cLojFor ))
			If !lNumProp
				cCgcTransp 	:= IIF(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA) )
			Else
				cCgcTransp := OMSM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
			EndIf
		EndIf
	Else
		If lNumProp
			cCgcTransp := Posicione("GU3",13,xFilial("GU3")+cTransp,"GU3_CDEMIT")
		Else
			cCgcTransp := Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_CGC")
		EndIf
	EndIf

	cNomeTrans	:= RTrim( POSICIONE("GU3",1,XFILIAL("GU3")+cCgcTransp,"GU3_NMEMIT") )

	aAdd(aLoad,{0,{xFilial("DTC"),;			//-- FILIAL
		cNumSim,;							//-- NUMSIM
		cFilOri,;							//-- FILORI
		cViagem,;							//-- VIAGEM
		cFilDoc,;							//-- FILDOC
		cDoc,;								//-- DOC
		cSerie,;							//-- SERIE
		cItem	:= Soma1(cItem),;			//-- ITEM
		cCgcTransp,; 						//-- CGCTRAN
		cNomeTrans,;						//-- NOMETRAN
		TMS120CDUF((cAliasQry)->DJN_UFDES, "1") + (cAliasQry)->DJN_CDMUND ,;	//-- MUNDES
		Posicione("CC2",1,xFilial("CC2")+(cAliasQry)->DJN_UFDES+(cAliasQry)->DJN_CDMUND,"CC2_MUN"),;		//-- NOMEMUNDES
		(cAliasQry)->DJN_UFDES ,;			//-- UFDEST
		TMS120CDUF( (cAliasQry)->DJN_UFORI , "1") + (cAliasQry)->DJN_CDMUNO,;	//-- MUNORI
		Posicione("CC2",1,xFilial("CC2")+(cAliasQry)->DJN_UFORI+(cAliasQry)->DJN_CDMUNO,"CC2_MUN"),;		//-- NOMEMUNORI
		(cAliasQry)->DJN_UFORI,;			//-- UFORI
		(cAliasQry)->DJN_CEPORI ,;			//-- CEPORI
		(cAliasQry)->DJN_CEPDES }} ) 			//-- CEPDES

	(cAliasQry)->(dbSkip())

EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aAreaDTR)
RestArea(aAreaDTQ)
Return aLoad
/*/{Protheus.doc} VldMark
//Valida markbrowse
@author caio.y
@since 19/07/2017
@version undefined

@type function
/*/
Function AO45VldMrk()
Local lRet		:= .T.
Local oModel	:= FwModelActive()
Local oMdlGrid	:= oModel:GetModel("MdGridRes")
Local nLinAtu	:= oMdlGrid:GetLine()
Local lMark		:= oMdlGrid:GetValue("MARK")
Local nCount	:= 1
Local aSaveLine	:= FWSaveRows()
Local oMdlDev	:= NIl
Local cCodCli	:= ""
Local cLojCli	:= ""
Local nRentab	:= 0
Local nPercus	:= 0
Local aDevedor	:= {}
Local aTarget	:= {}

For nCount := 1 To oMdlGrid:Length()
	oMdlGrid:Goline(nCount)

	If lMark	.And. nCount <> nLinAtu .And. lMark == oMdlGrid:GetValue("MARK")
		oMdlGrid:LoadValue("MARK",.F.)
		Exit
	EndIf

Next nCount

If lRet

	oMdlGrid:GoLine(nLinAtu)
	nPercus		:= oMdlGrid:GetValue("PERCUS")
	oMdlDev		:= oModel:GetModel("MdGridDev")

	//-- Executa o refresh dos grids
	RefreshVlr()

	oGraphic2:Reset()

	For nCount := 1 To oMdlDev:Length()
		oMdlDev:GoLine(nCount)

		cCodCli		:= oMdlDev:GetValue("CLIDEV")
		cLojCli		:= oMdlDev:GetValue("LOJDEV")
		nRentab		:= oMdlDev:GetValue("RENTAB")

		Aadd(aDevedor, { RTrim(Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli , "A1_NOME")) , nRentab } )
		Aadd(aTarget , { RTrim(Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli , "A1_NOME")) , nPercus } )

	Next nCount
	oGraphic2:addSerie( STR0032 , aTarget )	//-- Rentabilidade Mínima
	oGraphic2:addSerie( STR0031 , aDevedor)	//-- Devedores
	oGraphic2:Build()

EndIf

FwRestRows(aSaveLine)
Return lRet

/*/{Protheus.doc} LoadSetKey
//Carrega teclas de atalho
@author caio.y
@since 19/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function LoadSetKey()
Local aRet	:= {}

AAdd( aRet ,{ VK_F12	,{ || AO45Pergunte(,,,aSetKey,.T.) } } )
AAdd( aRet ,{ VK_F5 	,{ || AO45Leg(.T.) } } )

Return aRet
