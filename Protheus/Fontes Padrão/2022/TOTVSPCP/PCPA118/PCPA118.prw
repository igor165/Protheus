#INCLUDE "PCPA118.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"

Function PCPA118()
	Local aArea   	:= GetArea()
	Local oBrowse	:= BrowseDef()
	oBrowse:Activate()
	RestArea(aArea)

Return NIL

Static Function BrowseDef()
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SMX')
	oBrowse:SetDescription(STR0001) //Lista de operações

Return oBrowse

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCPA118' OPERATION OP_VISUALIZAR ACCESS 0 //VISUALIZAR
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCPA118' OPERATION OP_INCLUIR    ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.PCPA118' OPERATION OP_ALTERAR    ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.PCPA118' OPERATION OP_EXCLUIR    ACCESS 0 //Excluir
	ADD OPTION aRotina Title STR0065 Action 'PCPA118COP()'    OPERATION OP_COPIA      ACCESS 0 //Copiar
	ADD OPTION aRotina Title STR0068 Action 'P118CONSUL()' 	  OPERATION OP_VISUALIZAR ACCESS 0 //Onde se usa

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStruSMX		:= FWFormStruct( 1, 'SMX' )
	Local oStruSVH		:= FWFormStruct( 1, 'SVH' )
	Local oStruSG2		:= FWFormStruct( 1, 'SG2' ,{|cCampo| '|'+AllTrim(cCampo)+'|' $ "|G2_CODIGO|G2_PRODUTO|"})
	Local oStruOldSVH	:= FWFormStruct( 1, 'SVH' )
	Local oStruSMY_R	:= FWFormStruct( 1, 'SMY' )
	Local oStruSMY_F	:= FWFormStruct( 1, 'SMY' )
	Local oEvent		:= PCPA118EVDEF():New()
	Local lUniLin		:= SuperGetMV("MV_UNILIN",.F.,.F.)

	oModel := MPFormModel():New('PCPA118')

	//-- Campo de Controle da Execução das Validações de Divergências - Bloco de código inicializador padrão retorna .T.
	oStruSMX:AddField(STR0034	,;	// [01]  C   Titulo do campo	- "Valid.Divergencia"
	STR0035						,;	// [02]  C   ToolTip do campo	- "Exibe tela de validação de divergências"
	"ValidDivergencias"			,;	// [03]  C   Id do Field
	"L"							,;	// [04]  C   Tipo do campo
	1							,;	// [05]  N   Tamanho do campo
	0, NIL, NIL, NIL, .T., {|| .T. }, NIL, NIL, .T.)

	//-- Campo de Controle da Exibição da Tela de Validação de Divergências - Bloco de código inicializador padrão retorna .F.
	oStruSMX:AddField(STR0034	,;	// [01]  C   Titulo do campo	- "Valid.Divergencia"
	STR0035						,;	// [02]  C   ToolTip do campo	- "Exibe tela de validação de divergências"
	"SemTela"					,;	// [03]  C   Id do Field
	"L"							,;	// [04]  C   Tipo do campo
	1							,;	// [05]  N   Tamanho do campo
	0, NIL, NIL, NIL, .F., {|| .T. }, NIL, NIL, .T.)

	//-- Campo de Controle da Exibição da Tela de Validação de Divergências
	oStruSVH:AddField(	"Recno"			,;	// [01]  C   Titulo do campo	- Recno
	"Recno"								,;	// [02]  C   ToolTip do campo	- Recno
	"RECNO"								,;	// [03]  C   Id do Field
	"C"									,;	// [04]  C   Tipo do campo
	GetSx3Cache("B1_DESC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	0, NIL, NIL, NIL, .F., {|| SVH->(Recno())}, NIL, NIL, .T.)

	If !Empty(GetSX3Cache("VH_ROTALT","X3_CAMPO"))
		oStruSVH:RemoveField("VH_ROTALT")
	Endif

	If lUniLin
		//Adiciona os campos de Linha Produção no cabeçalho do programa.
		oStruSMX:AddField(oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_TITULO)	 ,;	// [01]  C   Titulo do campo  - Produto
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_TOOLTIP) ,;	// [02]  C   ToolTip do campo - Código do Produto
		                  "MX_TPLINHA"                                           ,;	// [03]  C   Id do Field
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_TIPO)    ,;	// [04]  C   Tipo do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_TAMANHO) ,;	// [05]  N   Tamanho do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_DECIMAL) ,;	// [06]  N   Decimal do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_VALID)   ,;	// [07]  B   Code-block de validação do campo
		                  NIL                                                    ,;	// [08]  B   Code-block de validação When do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_VALUES)  ,;	// [09]  A   Lista de valores permitido do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_OBRIGAT) ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
		                  {||A118IniFld("MX_TPLINHA")}                           ,;	// [11]  B   Code-block de inicializacao do campo
		                  NIL                                                    ,;	// [12]  L   Indica se trata-se de um campo chave
		                  oStruSVH:GetProperty("VH_TPLINHA",MODEL_FIELD_NOUPD)   ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		                  .T.									                 )  // [14]  L   Indica se o campo é virtual

		oStruSMX:AddField(oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_TITULO)	 ,;	// [01]  C   Titulo do campo  - Produto
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_TOOLTIP) ,;	// [02]  C   ToolTip do campo - Código do Produto
		                  "MX_LINHAPR"                                           ,;	// [03]  C   Id do Field
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_TIPO)    ,;	// [04]  C   Tipo do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_TAMANHO) ,;	// [05]  N   Tamanho do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_DECIMAL) ,;	// [06]  N   Decimal do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_VALID)   ,;	// [07]  B   Code-block de validação do campo
		                  NIL                                                    ,;	// [08]  B   Code-block de validação When do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_VALUES)  ,;	// [09]  A   Lista de valores permitido do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_OBRIGAT) ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
		                  {||A118IniFld("MX_LINHAPR")}                           ,;	// [11]  B   Code-block de inicializacao do campo
		                  NIL                                                    ,;	// [12]  L   Indica se trata-se de um campo chave
		                  oStruSVH:GetProperty("VH_LINHAPR",MODEL_FIELD_NOUPD)   ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		                  .T.									                 )  // [14]  L   Indica se o campo é virtual
		oStruSMX:AddTrigger("MX_TPLINHA", "MX_TPLINHA",,{||updLinhaPr()})
		oStruSMX:AddTrigger("MX_LINHAPR", "MX_LINHAPR",,{||updLinhaPr()})
	EndIf

	//Adiciona objetos da tela principal
	oModel:AddFields('SMXMASTER'	, /*cOwner*/	, oStruSMX)
	oModel:AddGrid('SVHDETAIL'		, 'SMXMASTER'	, oStruSVH )
	oModel:AddGrid("SMYDETAIL_R"	, "SVHDETAIL"	, oStruSMY_R)
	oModel:AddGrid("SMYDETAIL_F"	, "SVHDETAIL"	, oStruSMY_F)

	A118AddCol(1, @oStruOldSVH)

	oModel:SetPrimaryKey({})
	oModel:SetRelation("SVHDETAIL"	, {{"VH_FILIAL","xFilial('SVH')"},{"VH_CODIGO", "MX_CODIGO" }}, SVH->(IndexKey(1)))
	oModel:SetRelation("SMYDETAIL_R",{{"MY_FILIAL","xFilial('SMY')"},{"MY_CODIGO" ,"MX_CODIGO"},{"MY_OPERAC","VH_OPERAC"},{"MY_RECPRIN","VH_RECURSO"}},SMY->(IndexKey(1)))
	oModel:SetRelation("SMYDETAIL_F",{{"MY_FILIAL","xFilial('SMY')"},{"MY_CODIGO" ,"MX_CODIGO"},{"MY_OPERAC","VH_OPERAC"}},SMY->(IndexKey(1)))

	oStruSMX:SetProperty("MX_CODIGO", MODEL_FIELD_NOUPD,.T.)
	oStruSVH:SetProperty("VH_OPERAC", MODEL_FIELD_OBRIGAT, .T.)

	oModel:GetModel('SMYDETAIL_R'):SetLoadFilter({{'MY_RECALTE',"'"+CriaVar("MY_RECALTE")+"'",2}}) // MVC_LOADFILTER_NOT_EQUAL ----
	oModel:GetModel('SMYDETAIL_F'):SetLoadFilter({{'MY_FERRAM' ,"'"+CriaVar("MY_FERRAM")+"'",2}}) // MVC_LOADFILTER_NOT_EQUAL ----

	oModel:GetModel( "SVHDETAIL" 	):SetUniqueLine( {"VH_OPERAC"} )
	oModel:GetModel( "SMYDETAIL_R" 	):SetUniqueLine( {"MY_RECALTE"} )
	oModel:GetModel( "SMYDETAIL_F" 	):SetUniqueLine( {"MY_FERRAM"} )
	oModel:GetModel( 'SVHDETAIL' 	):SetOptional( .F. )//pelo menos um registro na grid
	oModel:GetModel( 'SMYDETAIL_R' 	):SetOptional( .T. )//Opcional
	oModel:GetModel( 'SMYDETAIL_F' 	):SetOptional( .T. )//Opcional

	//-- Campo de Controle da Exibição da Tela de Validação de Divergências
	oStruSG2:AddField(	STR0051			,;	// [01]  C   Titulo do campo	- Descrição
	STR0052								,;	// [02]  C   ToolTip do campo	- Descrição do Produto
	"B1_DESC"							,;	// [03]  C   Id do Field
	"C"									,;	// [04]  C   Tipo do campo
	GetSx3Cache("B1_DESC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

	//Adiciona objetos da Validação de inconsistência:
	oModel:AddGrid( 'NOK_NEW_SVH'	, 'SMXMASTER'	, oStruSVH		, , , , , {|| StaticCall(PCPA118EVDEF, LoadNewSG2, Len(oStruSVH:aFields)) } )
	oModel:AddGrid( 'NOK_OLD_SVH'	, 'NOK_NEW_SVH'	, oStruOldSVH	, , , , {|| StaticCall(PCPA118EVDEF, LoadNewSG2, Len(oStruSVH:aFields)) } )
	oModel:AddGrid( 'OK_SG2'		, 'SMXMASTER'	, oStruSG2		, , , , , {|| StaticCall(PCPA118EVDEF, LoadSG2Ok, Len(oStruSG2:aFields)) } )

	//Ajustes modelos telas de divergências
	oModel:GetModel('NOK_NEW_SVH'):SetOptional(.T.)
	oModel:GetModel('NOK_NEW_SVH'):SetOnlyQuery()
	oModel:GetModel('NOK_NEW_SVH'):SetNoUpdateLine( .T. )
	oModel:GetModel('NOK_NEW_SVH'):SetNoInsertLine( .T. )
	oModel:GetModel('NOK_OLD_SVH'):SetOptional(.T.)
	oModel:GetModel('NOK_OLD_SVH'):SetOnlyQuery()
	oModel:GetModel('NOK_OLD_SVH'):SetNoUpdateLine( .T. )
	oModel:GetModel('NOK_OLD_SVH'):SetNoInsertLine( .T. )
	oModel:GetModel('OK_SG2'):SetOptional(.T.)
	oModel:GetModel('OK_SG2'):SetOnlyQuery()
	oModel:GetModel('OK_SG2'):SetNoUpdateLine( .T. )
	oModel:GetModel('OK_SG2'):SetNoInsertLine( .T. )

	oModel:GetModel( 'SMXMASTER' ):SetDescription( STR0001 ) //Lista de Operações
	oModel:GetModel( 'SVHDETAIL' ):SetDescription( STR0002 ) //Operações

	oModel:InstallEvent("PCPA118EVDEF", /*cOwner*/, oEvent)

Return oModel

Static Function ViewDef()

	Local oModel 		:= FWLoadModel( 'PCPA118' )
	Local oStruSMX 		:= FWFormStruct( 2, 'SMX')
	Local oStruSVH 		:= FWFormStruct( 2, 'SVH')
	Local oStruSMY_R 	:= FWFormStruct( 2, 'SMY' ,{|cCampo| AllTrim(cCampo) $ "MY_CODIGO|MY_OPERAC|MY_RECPRIN|MY_RECALTE|MY_TIPO|MY_EFICIEN|MY_DESC"})
	Local oStruSMY_F 	:= FWFormStruct( 2, 'SMY' ,{|cCampo| AllTrim(cCampo) $ "MY_CODIGO|MY_OPERAC|MY_FERRAM|MY_DESCFER"})
	Local oView
	Local lUniLin		:= SuperGetMV("MV_UNILIN",.F.,.F.)
	Local cOrdem		:= ""

	If !Empty(GetSX3Cache("VH_ROTALT","X3_CAMPO"))
		oStruSVH:RemoveField("VH_ROTALT")
	Endif

	If lUniLin
		cOrdem := oStruSMX:GetProperty("MX_DESCRI",MVC_VIEW_ORDEM)
		cOrdem := Soma1(cOrdem)

		oStruSMX:AddField("MX_LINHAPR"                                          ,;	// [01]  C   Nome do Campo
		                  cOrdem                                                ,;	// [02]  C   Ordem
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_TITULO)    ,;	// [03]  C   Titulo do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_DESCR)     ,;	// [04]  C   Descricao do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_HELP)      ,;	// [05]  A   Array com Help
		                  "C"                                                   ,; 	// [06]  C   Tipo do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_PICT)      ,;	// [07]  C   Picture
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_PVAR)      ,;	// [08]  B   Bloco de Picture Var
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_LOOKUP)    ,;	// [09]  C   Consulta F3
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_CANCHANGE) ,;	// [10]  L   Indica se o campo é alteravel
		                  NIL                                                   ,;	// [11]  C   Pasta do campo
		                  NIL                                                   ,;	// [12]  C   Agrupamento do campo
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_COMBOBOX)  ,;	// [13]  A   Lista de valores permitido do campo (Combo)
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_MAXTAMCMB) ,;	// [14]  N   Tamanho maximo da maior opção do combo
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_INIBROW)   ,;	// [15]  C   Inicializador de Browse
		                  .T.                                                   ,;	// [16]  L   Indica se o campo é virtual
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_PVAR)      ,;	// [17]  C   Picture Variavel
		                  oStruSVH:GetProperty("VH_LINHAPR",MVC_VIEW_INSERTLINE) )	// [18]  L   Indica pulo de linha após o campo

		cOrdem := Soma1(cOrdem)

		oStruSMX:AddField("MX_TPLINHA"                                          ,;	// [01]  C   Nome do Campo
		                  cOrdem                                                ,;	// [02]  C   Ordem
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_TITULO)    ,;	// [03]  C   Titulo do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_DESCR)     ,;	// [04]  C   Descricao do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_HELP)      ,;	// [05]  A   Array com Help
		                  "C"                                                   ,; 	// [06]  C   Tipo do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_PICT)      ,;	// [07]  C   Picture
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_PVAR)      ,;	// [08]  B   Bloco de Picture Var
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_LOOKUP)    ,;	// [09]  C   Consulta F3
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_CANCHANGE) ,;	// [10]  L   Indica se o campo é alteravel
		                  NIL                                                   ,;	// [11]  C   Pasta do campo
		                  NIL                                                   ,;	// [12]  C   Agrupamento do campo
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_COMBOBOX)  ,;	// [13]  A   Lista de valores permitido do campo (Combo)
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_MAXTAMCMB) ,;	// [14]  N   Tamanho maximo da maior opção do combo
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_INIBROW)   ,;	// [15]  C   Inicializador de Browse
		                  .T.                                                   ,;	// [16]  L   Indica se o campo é virtual
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_PVAR)      ,;	// [17]  C   Picture Variavel
		                  oStruSVH:GetProperty("VH_TPLINHA",MVC_VIEW_INSERTLINE) )	// [18]  L   Indica pulo de linha após o campo


		oStruSVH:RemoveField("VH_TPLINHA")
		oStruSVH:RemoveField("VH_LINHAPR")
	EndIf

	oView :=FWFormView():New()
	oView:SetAfterViewActivate({|oView| AfterViewActivate(oView, oModel)})
	oView:SetModel(oModel)
	oView:AddField('VIEW_SMX'	, oStruSMX		, 'SMXMASTER')
	oView:AddGrid('VIEW_SVH'	, oStruSVH		, 'SVHDETAIL')
	oView:AddGrid("GRID_SMY_R"	, oStruSMY_R	, "SMYDETAIL_R")
	oView:AddGrid("GRID_SMY_F"	, oStruSMY_F	, "SMYDETAIL_F")

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox('SUPERIOR', 15 )
	oView:CreateHorizontalBox('MEIO', 45 )
	oView:CreateHorizontalBox('INFERIOR', 40 )

	// Cria Folder na view
	oView:CreateFolder("PASTAS","INFERIOR")

	// Cria pastas nas folders
	oView:AddSheet("PASTAS", "ABA01", STR0003) //-- Recursos Alternativos / Secundários
	oView:AddSheet("PASTAS", "ABA02", STR0004 ) //-- "Ferramentas Alternativas"

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("ABAS1", 100,,, "PASTAS", "ABA01")
	oView:CreateHorizontalBox("ABAS2", 100,,, "PASTAS", "ABA02")

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView('VIEW_SMX'	, 'SUPERIOR' )
	oView:SetOwnerView('VIEW_SVH'	, 'MEIO' )
	oView:SetOwnerView('GRID_SMY_R'	, 'ABAS1')
	oView:SetOwnerView('GRID_SMY_F'	, 'ABAS2')

	oStruSVH:RemoveField('VH_CODIGO')
	oStruSMY_R:RemoveField('MY_DESCFER')
	oStruSMY_R:RemoveField('MY_CODIGO')
	oStruSMY_F:RemoveField('MY_CODIGO')
	oStruSMY_F:RemoveField('MY_DESC')

Return oView

/*/{Protheus.doc} AfterViewActivate
Execução após ativação da View
@author brunno.costa
@since 14/06/2018
@version 6
@return NIL

@type function
/*/

Static Function AfterViewActivate(oView, oModel)

	//Se Executa ViewDef - Em alteração, seta campo de controle da exibição de divergências como true
	If oModel:GetOperation() ==  MODEL_OPERATION_UPDATE
		oModel:GetModel("SMXMASTER"):SetValue("ValidDivergencias",.T.)
		oModel:GetModel("SMXMASTER"):SetValue("SemTela",.F.)
	EndIf

Return


/*/{Protheus.doc} A118AddCol
Inclui campos na estrutura OLD
@author Marcelo Neumann
@since 05/06/2018
@version 1.0
/*/

Function A118AddCol(nModel, oStru)

	If nModel == 1
		//-- Campo FALHA
		oStru:AddField(	"Falha"					,;	// [01]  C   Titulo do campo
		"Falha"									,;	// [02]  C   ToolTip do campo
		"_FALHA"									,;	// [03]  C   Id do Field
		"M"										,;	// [04]  C   Tipo do campo
		10										,;	// [05]  N   Tamanho do campo
		0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

		//-- Campo ROTEIRO
		oStru:AddField(	STR0009					,;	// [01]  C   Titulo do campo	- "Roteiro"
		STR0009									,;	// [02]  C   ToolTip do campo	- "Roteiro"
		"VH_ROTEIRO"							,;	// [03]  C   Id do Field
		"C"										,;	// [04]  C   Tipo do campo
		GetSx3Cache("G2_CODIGO","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
		0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

		//-- Campo PRODUTO
		oStru:AddField(	RetTitle("G2_PRODUTO")	,;	// [01]  C   Titulo do campo
		RetTitle("G2_PRODUTO")					,;	// [02]  C   ToolTip do campo
		"VH_PRODUTO"							,;	// [03]  C   Id do Field
		"C"										,;	// [04]  C   Tipo do campo
		GetSx3Cache("G2_PRODUTO","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
		0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

		//-- Campo RECNO
		oStru:AddField(	"RECNO"					,;	// [01]  C   Titulo do campo
		"RECNO"									,;	// [02]  C   ToolTip do campo
		"RECNO"									,;	// [03]  C   Id do Field
		"N"										,;	// [04]  C   Tipo do campo
		99										,;	// [05]  N   Tamanho do campo
		0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

	Else
		//-- Campo FALHA
		oStru:AddField(	"_FALHA"			,;	// [01]  C   Nome do Campo
		"0"							,;	// [02]  C   Ordem
		"Falha"							,;	// [03]  C   Titulo do campo
		"Falha"							,;	// [04]  C   Descricao do campo
		NIL, "M", "", NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

		//-- Campo ROTEIRO
		oStru:AddField(	"VH_ROTEIRO"	,;	// [01]  C   Nome do Campo
		"00"							,;	// [02]  C   Ordem
		STR0009							,;	// [03]  C   Titulo do campo	- "Roteiro"
		STR0009							,;	// [04]  C   Descricao do campo	- "Roteiro"
		NIL, "C", "", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

		//-- Campo PRODUTO
		oStru:AddField(	"VH_PRODUTO"	,;	// [01]  C   Nome do Campo
		"01"							,;	// [02]  C   Ordem
		RetTitle("G2_PRODUTO")			,;	// [03]  C   Titulo do campo
		RetTitle("G2_PRODUTO")			,;	// [04]  C   Descricao do campo
		NIL, "C", "", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

		//-- Campo RECNO
		oStru:AddField(	"RECNO"	,;	// [01]  C   Nome do Campo
		"99"					,;	// [02]  C   Ordem
		"RECNO"					,;	// [03]  C   Titulo do campo
		"RECNO"					,;	// [04]  C   Descricao do campo
		NIL, "N", "", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)
	EndIf

Return

/*/{Protheus.doc} A118VldCod
Valida se o codigo do roteiro ja existe
@author Douglas Heydt
@since 11/04/2018
@version 1.0
@return lRet
/*/

Function A118VldCod()
	Local oModel	:= FWModelActive()
	Local oModelSMX := oModel:GetModel("SMXMASTER")
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local cFilSMX	:= xFilial("SMX")
	Local cCodSMX	:= oModelSMX:GetValue("MX_CODIGO")

	If !Empty(cCodSMX)
		dbSelectArea("SMX")
		dbSetOrder(1)
		If MsSeek( cFilSMX+cCodSMX)
			Help(" ",1,"A118JAEXISTE")
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} A118TpLin
Valida campo VH_TPLINHA
@author TOTVS S/A
@since 17/04/2018
@version 1.0
/*/
Function A118TpLin()
	Local lRet      := .T.
	Local lUniLin   := SuperGetMV("MV_UNILIN",.F.,.F.)
	Local oModel	:= FWModelActive()
	Local oModSVH	:= oModel:GetModel("SVHDETAIL")
	Local oModSMX   := oModel:GetModel("SMXMASTER")

	If lUniLin
		If oModSMX:GetValue("MX_TPLINHA") $ "OPD"
			If Empty(oModSMX:GetValue("MX_LINHAPR"))
				Help(" ",1,"A124TPLINO")
				lRet := .F.
			EndIf
		EndIf
	Else
		If oModSVH:GetValue("VH_TPLINHA") == "D"
			If oModSVH:nLine # 1
				If Empty(oModSVH:GetValue("VH_LINHAPR",oModSVH:nLine - 1))
					Help(" ",1,"A124TPLIND")
					lRet := .F.
				Else
					oModSVH:SetValue("VH_LINHAPR",oModSVH:GetValue("VH_LINHAPR",oModSVH:nLine - 1))
				EndIf
			EndIf
		ElseIf FwFldGet("VH_TPLINHA") $ "OP"
			If Empty(FwFldGet("VH_LINHAPR"))
				Help(" ",1,"A124TPLINO")
				lRet := .F.
			EndIf
		EndIf
	EndIF
Return lRet


/*/{Protheus.doc} A118FerAlt
Efetua validações da ferramenta informada
@author Douglas Heydt
@since 19/04/2018
@version 1.0
/*/

Function A118FerAlt()
	Local oModel	:= FWModelActive()
	Local oGridSVH	:= oModel:GetModel("SVHDETAIL")
	Local oGridSMY	:= oModel:GetModel("SMYDETAIL_F")
	Local lRet		:= .T.
	Local aSaveLines:= FWSaveRows(oModel)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Ferramenta Principal j  foi cadastrada como Alternativa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGridSVH:GoLine(oGridSVH:GetLine())
	If !Empty(FwFldGet("MY_FERRAM")) .AND. FwFldGet("MY_FERRAM") == oGridSVH:GetValue("VH_FERRAM")
		Help(" ",1,"A630FERJA")
		lRet:=.F.
	EndIf
	FWRestRows(aSaveLines)
	//-- Inicializa descricao da ferramenta
	If lRet
		oGridSMY:SetValue("MY_DESCFER",PadR(Posicione("SH4",1,xFilial("SH4")+FwFldGet("MY_FERRAM"),"H4_DESCRI"),TamSX3("MY_DESCFER")[1]))
	EndIf

Return lRet



/*/{Protheus.doc} A118Ferram
Efetua validações da ferramenta informada
@author TOTVS S/A
@since 20/04/2018
@version 1.0
/*/

Function A118Ferram()
	Local oModel    := FWModelActive()
	Local oGridSMYF	:= oModel:GetModel("SMYDETAIL_F")
	Local nX        := 0
	Local lRet    	:= .T.
	Local aSaveLines:= FWSaveRows(oModel)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Ferramenta Principal j  foi cadastrada como Alternativa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To oGridSMYF:Length()
		oGridSMYF:GoLine(nX)
		If !Empty(oGridSMYF:GetValue("MY_FERRAM")) .And. FwFldGet("VH_FERRAM") == oGridSMYF:GetValue("MY_FERRAM")
			Help(" ",1,"A630FERJA")
			lRet:=.F.
			Exit
		EndIf
	Next nX

	FWRestRows(aSaveLines)
Return lRet



/*/{Protheus.doc} A118Recur
Realiza busca no cadastro de Recurso alternativo e verifica se existe alguma ocorrencia do mesmo recurso.
@author TOTVS S/A
@since 20/04/2018
@version 1.0
/*/

Function A118Recur()
	Local oModel	:= FWModelActive()
	Local oGridSMYR	:= oModel:GetModel("SMYDETAIL_R")
	Local nX		:= 0
	Local lRet		:= .T.
	Local aSaveLines:= FWSaveRows(oModel)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Recurso Principal j  foi cadastrado como Alternativo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To oGridSMYR:Length(.T.)
		oGridSMYR:GoLine(nX)
		If !Empty(FwFldGet("VH_RECURSO")) .AND. FwFldGet("VH_RECURSO") == oGridSMYR:GetValue("MY_RECALTE")
			If oGridSMYR:GetValue("MY_TIPO") == "S"
				Help(" ",1,"A630JAS")
			Else
				Help(" ",1,"A630JAA")
			EndIf
			lRet:=.F.
			Exit
		EndIf
	Next nX

	FWRestRows(aSaveLines)
Return lRet


/*/{Protheus.doc} A118RecAlt
Verifica se Recurso Alternativo j  foi cadastrado como Principal.
@author Douglas Heydt
@since 20/04/2018
@version 1.0
/*/

Function A118RecAlt()
	Local oModel	:= FWModelActive()
	Local oGridSVH	:= oModel:GetModel("SVHDETAIL")
	Local oGridSMY	:= oModel:GetModel("SMYDETAIL_R")
	Local lRet		:= .T.
	Local aSaveLines:= FWSaveRows(oModel)
	Local OperAtu   := ''
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Recurso Alternativo j  foi cadastrado como Principal.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OperAtu := oGridSVH:GetValue("VH_OPERAC")
	oGridSVH:GoLine(oGridSVH:GetLine() )
	If !Empty(FwFldGet("MY_RECALTE")) .AND. FwFldGet("MY_RECALTE") == oGridSVH:GetValue("VH_RECURSO")
		Help(" ",1,"A118RECP")
		lRet:=.F.
	EndIf

	FWRestRows(aSaveLines)

	//-- Inicializa descricao do recurso
	If lRet
		oGridSMY:SetValue("MY_DESC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("MY_RECALTE"),"H1_DESCRI"),TamSX3("MY_DESC")[1]))
	EndIf

Return lRet



/*/{Protheus.doc} A118Tempo
@author Lucas Pereira

@param nValue	- Valor que será validado. Parâmetro é passado apenas na validação de linha.
@param cField	- Campo que está sendo validado. Parâmetro é passado apenas na validação de linha.

@since 18/12/2014
@version 1.0
/*/

Function A118Tempo(nValue,cField)
	Local cCampo    := ReadVar()
	Local cTipo     := SuperGetMV("MV_TPHR",.F.,"C")
	Local cHelp     := ""
	Local nVal      := 0
	Local nDec      := 0
	Local nPrecisao := SuperGetMV("MV_PRECISA",.F.,4)
	Local lValid    := .F.
	Local oModel 	:= FWModelActive()
	Local oModSVH	:= oModel:GetModel("SVHDETAIL")

	Default nValue  := Nil
	Default cField  := ""

	If !Empty(cField) .And. nValue <> Nil
		cCampo := cField
		nVal   := nValue
	Else
		cCampo := StrTran(cCampo,"M->","")
		nVal   := oModSVH:GetValue(cCampo)
	EndIf

	nDec      := ( nVal - Int( nVal ) ) * 100
	nPrecisao := 60 / nPrecisao

	If cCampo == "VH_TEMPSOB"
		lValid := oModSVH:GetValue("VH_TPSOBRE") == "3"
	ElseIf cCampo == "VH_TEMPDES"
		lValid := oModSVH:GetValue("VH_TPDESD") == "2"
	ElseIf cCampo == "VH_TEMPAD" .Or. cCampo == "VH_SETUP" .Or. cCampo == "VH_TEMPEND"
		lValid := .T.
	Endif

	If nDec >= 60 .And. cTipo == "N" .And. lValid
		Help(" ",1,"NAOMINUTO")
		Return .F.
	EndIf

	If cCampo $ "VH_TEMPAD/VH_SETUP/VH_TEMPEND"
		If cTipo == "N"
			If nVal < 1
				If cCampo == "VH_TEMPAD"
					nDec += (oModSVH:GetValue("VH_SETUP") - Int(oModSVH:GetValue("VH_SETUP"))) * 100
				ElseIf cCampo == "VH_SETUP"
					nDec += (oModSVH:GetValue("VH_TEMPAD") - Int(oModSVH:GetValue("VH_TEMPAD"))) * 100
				ElseIf cCampo == "VH_TEMPEND"
					nDec += (oModSVH:GetValue("VH_TEMPEND") - Int(oModSVH:GetValue("VH_TEMPEND"))) * 100
				EndIf
				If NoRound(nDec,2) < NoRound(nPrecisao,2)
					If Empty(cField) .Or. cField == "VH_TEMPAD"
						Help(" ",1,"MENORPREC")
					Else
						cHelp := " " + STR0018 + " " + RetTitle(cField) + "."
						Help(" ",1,"MENORPREC",,cHelp,04,02)
					EndIf
					If (oModSVH:GetValue("VH_TPOPER")) == "2" .Or. (oModSVH:GetValue("VH_TPOPER")) == "3"
						Return .F.
					EndIf
				EndIf
			EndIf
		ElseIf cTipo == "C"
			If nVal < 1
				nDec := ( nVal - Int( nVal ) ) * 60
				If cCampo == "VH_TEMPAD"
					nDec += (oModSVH:GetValue("VH_SETUP") - Int(oModSVH:GetValue("VH_SETUP"))) * 60
				ElseIf cCampo == "VH_SETUP"
					nDec += (oModSVH:GetValue("VH_TEMPAD") - Int(oModSVH:GetValue("VH_TEMPAD"))) * 60
				ElseIf cCampo == "VH_TEMPEND"
					nDec += (oModSVH:GetValue("VH_TEMPEND") - Int(oModSVH:GetValue("VH_TEMPEND"))) * 60
				EndIf
				If NoRound(nDec,2) < NoRound(nPrecisao,2)
					If Empty(cField) .Or. cField == "VH_TEMPAD"
						Help(" ",1,"MENORPREC")
					Else
						cHelp := " " + STR0018 + " " + RetTitle(cField) + "."
						Help(" ",1,"MENORPREC",,cHelp,04,02)
					EndIf
					If (oModSVH:GetValue("VH_TPOPER")) == "2" .Or. (oModSVH:GetValue("VH_TPOPER")) == "3"
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} cDescOp
Busca a descrição da operação
@since 19/06/2018
@version 1.0
@return .T.
/*/
Function cDescOp()

	Local aAreaSVI	:= SVI->(GetArea())
	Local oModel	:= FWModelActive()
	Local oModelSVH := oModel:GetModel("SVHDETAIL")
	Local cOper		:= oModelSVH:GetValue("VH_OPERAC")
	Local cDescri	:= ""

	SVI->(dbSetOrder(1))
	If SVI->(dbSeek(xFilial('SVI')+cOper))
		cDescri := SVI->VI_DESCRI
		oModelSVH:SetValue("VH_DESCOP", cDescri)
	EndIf
	RestArea(aAreaSVI)
Return .T.

/*/{Protheus.doc} A118IniFld
Função para inicializar valores padrões nos campos.
@type  Function
@author lucas.franca
@since 16/01/2019
@version P12
@param cField, character, Nome do campo que será inicializado.
@return cValue, character, Valor que será inicializado no campo
/*/
Function A118IniFld(cField)
	Local cValue := ""
	Local oModel := FWModelActive()

	SVH->(dbSetOrder(1))
	If SVH->(dbSeek(xFilial("SVH")+SMX->MX_CODIGO))
		If cField == "MX_LINHAPR"
			cValue := SVH->VH_LINHAPR
		ElseIf cField == "MX_TPLINHA"
			cValue := SVH->VH_TPLINHA
		EndIf
	EndIf
Return cValue

/*/{Protheus.doc} updLinhaPr
Atualiza as informações de Linha Produção/Tipo Linha em todas as operações da lista, 
de acordo com o que foi informado no cabeçalho.
@type  Static Function
@author lucas.franca
@since 17/01/2019
@version P12
@return .T.
/*/
Static Function updLinhaPr()
	Local oModel   := FWModelActive()
	Local oMdlCab  := oModel:GetModel("SMXMASTER")
	Local oMdlDet  := oModel:GetModel("SVHDETAIL")
	Local nIndex   := 0
	Local nCurrent := oMdlDet:GetLine()

	For nIndex := 1 To oMdlDet:Length()
		oMdlDet:GoLine(nIndex)
		oMdlDet:LoadValue("VH_LINHAPR",oMdlCab:GetValue("MX_LINHAPR"))
		oMdlDet:LoadValue("VH_TPLINHA",oMdlCab:GetValue("MX_TPLINHA"))
	Next nIndex
	oMdlDet:GoLine(nCurrent)
Return .T.

/*/{Protheus.doc} PCPA118COP
Função responsavel pela opção de cópia do menu.
@type  Function
@author Lucas Fagundes
@since 20/12/2021
@version P12
@return Nil
/*/
Function PCPA118COP()

	Local aErro      := {}
	Local aStructSVH := {}
	Local cCod       := SMX->MX_CODIGO
	Local cDesc      := SMX->MX_DESCRI
	Local cMsgErro   := ""
	Local lTelaOk    := .T.
	Local lUniLin    := SuperGetMV("MV_UNILIN",.F.,.F.)
	Local nCont      := 1
	Local nContSMYF  := 1
	Local nContSMYR  := 1
	Local nI         := 1
	Local nRet       := 0
	Local oModel     := FwLoadModel("PCPA118")
	Local oModelSMX  := oModel:GetModel("SMXMASTER")
	Local oModelSMYF := oModel:GetModel("SMYDETAIL_F")
	Local oModelSMYR := oModel:GetModel("SMYDETAIL_R")
	Local oModelSVH  := oModel:GetModel("SVHDETAIL")

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModelSMX:SetValue("MX_DESCRI", cDesc)

	If lUniLin
		oModelSMX:SetValue("MX_LINHAPR", A118IniFld("MX_LINHAPR"))
		oModelSMX:SetValue("MX_TPLINHA", A118IniFld("MX_TPLINHA"))
	EndIf

	// Consulta na tabela de operações
	DbSelectArea("SVH")
	aStructSVH := SVH->(DbStruct())
	SVH->(DbSetOrder(1))						// VH_FILIAL+VH_CODIGO+VH_OPERAC+VH_RECURSO

	// Consulta na tabela de recursos e ferramentas alternativas
	DbSelectArea("SMY")
	SMY->(DbSetOrder(1))						// MY_FILIAL+MY_CODIGO+MY_OPERAC+MY_RECPRIN

	// Criação do grid das operações
	If SVH->(DbSeek(xFilial("SVH") + cCod))
		While !SVH->(EOF()) .and. SVH->VH_FILIAL == xFilial("SVH") .and. SVH->VH_CODIGO == cCod .and. lTelaOk
			// Adiciona uma nova linha (Caso for a primeira, não adiciona)
			if nCont > 1
				oModelSVH:AddLine()
			EndIf

			// Adiciona os valores no grid
			For nI := 1 to Len(aStructSVH)				
				If !oModelSVH:SetValue(aStructSVH[nI][1], SVH->&(aStructSVH[nI][1]))
					aErro := oModel:GetErrorMessage(.T.)

					cMsgErro := aErro[6] + chr(10) + STR0066 + CValToChar(nCont) + " " + STR0067 + "'" // STR0066 "Linha " STR0067 "Valor "
					If aStructSVH[nI][2] == "N"
						cMsgErro += CValToChar(SVH->&(aStructSVH[nI][1])) + "' "
					Else
						cMsgErro += SVH->&(aStructSVH[nI][1]) + "' "
					EndIf

					Help( , , aErro[5], , cMsgErro,;
						1, 0, , , , , , { aErro[7] })
					lTelaOk := .F.
					Exit
				EndIf
			Next

			// Adiciona os valores para recursos alternativos e ferramentas alternativas
			If SMY->(DbSeek(xFilial("SMY") + cCod + SVH->VH_OPERAC))
				nContSMYF  := 1
				nContSMYR  := 1
				While !SMY->(EOF()) .and. SMY->MY_FILIAL == xFilial("SMY") .and. SMY->MY_CODIGO == cCod .and. SMY->MY_OPERAC == SVH->VH_OPERAC .and. lTelaOk
					
					// Adiciona os recursos alternativos
					If !Empty(SMY->MY_RECALTE)
						if nContSMYR > 1
							oModelSMYR:AddLine()
						EndIf
						
						// Adiciona os valores no grid de recursos alternativos
						If !oModelSMYR:SetValue("MY_RECALTE", SMY->MY_RECALTE);
						.or. !oModelSMYR:SetValue("MY_TIPO", SMY->MY_TIPO);
						.or. !oModelSMYR:SetValue("MY_EFICIEN", SMY->MY_EFICIEN)
						
							aErro := oModel:GetErrorMessage(.T.)
							Help( , , aErro[5], , aErro[6],;
							1, 0, , , , , , { aErro[7] })
							lTelaOk := .F.
						
						EndIf

						nContSMYR++
					EndIf

					// Adiciona as ferramentas alternativas (Semelhante ao rec. alternativos)
					If !Empty(SMY->MY_FERRAM)
						if nContSMYF > 1
							oModelSMYF:AddLine()
						EndIf

						If !oModelSMYF:SetValue("MY_FERRAM", SMY->MY_FERRAM)
							aErro := oModel:GetErrorMessage(.T.)
							Help( , , aErro[5], , aErro[6],;
							1, 0, , , , , , { aErro[7] })
							lTelaOk := .F.
						EndIf

						nContSMYF++
					EndIf
				
					SMY->(DbSkip())
				End
			EndIf

			// Valida a linha
			If lTelaOk .and. !oModelSVH:VldLineData()
				aErro := oModel:GetErrorMessage(.T.)
				Help( , , aErro[5] , , aErro[6] + chr(10) + STR0066 + CValToChar(nCont),; // STR0066 "Linha "
					 1, 0, , , , , , { aErro[7] })
				lTelaOk := .F.
			EndIf

			nCont++
			SVH->(DbSkip())
		End
	EndIf

	oModelSVH:GoLine(1)
	oModelSMYR:GoLine(1)
	oModelSMYF:GoLine(1)
	aSize(aStructSVH, 0)

	// Executa a tela, caso esteja tudo certo
	If lTelaOk
		nRet := FWExecView(STR0006, "PCPA118", OP_INCLUIR, /*oDlg*/, {|| .T. }, /*bOk*/,;
		/*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel)
	EndIf

Return Nil

/*/{Protheus.doc} P118CONSUL
Função utilizada para consultar os produtos que estão utilizando a lista de operações
@type  Function
@author Lucas Fagundes
@since 22/02/2022
@version P12
@return Nil
/*/
Function P118CONSUL()

	// Verifica se a lista está em uso para consultar
	If PCPA118Lis(SMX->MX_CODIGO)
		FWExecView(STR0070, "PCPA118CON", MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. }, /*bOk*/,; // "Roteiros - Onde a Lista de Operações é Usada"
		65, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/)
	Else
		Help( ,  , "Help", , STR0069, 1, 0) // "Não existem roteiros de produtos vinculados a esta lista de operações."
	EndIf

Return Nil
