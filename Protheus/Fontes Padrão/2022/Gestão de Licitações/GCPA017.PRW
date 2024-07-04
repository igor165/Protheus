                                                                                                                                                                     #INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GCPA017.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA017
Programa configurador de licitacoes
@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCPA017()
	Local oBrowse

	If(GCPATtLei()[1])
		MSGAlert(STR0038 + CRLF + STR0054, STR0041)//"Existem novas leis disponibilizadas pela TOTVS." # "Acesse 'Outras Ações -> Carregar Regras' para atualizar!" # "IMPORTANTE"
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CO0')
	oBrowse:SetCacheView(.F.)
	oBrowse:DisableDetails()
	oBrowse:SetDescription(STR0022)
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
			[n,5] Nivel de acesso
			[n,6] Habilita Menu Funcional

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.GCPA017"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GCPA017"	OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0003 ACTION "GCPA017Upd()"		OPERATION MODEL_OPERATION_UPDATE	ACCESS 4 //"Alterar"
ADD OPTION aRotina TITLE STR0004 ACTION "GCPA017Exc()"		OPERATION MODEL_OPERATION_DELETE	ACCESS 3 //"Excluir"
ADD OPTION aRotina TITLE STR0021 ACTION "GCP017CARGA()"		OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Carregar regras"
ADD OPTION aRotina TITLE STR0034 ACTION "GCP017RUAT()"		OPERATION MODEL_OPERATION_UPDATE	ACCESS 4 //"Atualizar regras"

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel	:= NIL
Local oStruCO0	:= FWFormStruct(1,'CO0')
Local oStruCP5	:= FWFormStruct(1,'CP5')
Local oStruCOZ	:= FWFormStruct(1,'COZ')
Local oStruCOD	:= FWFormStruct(1,'COD')
Local oStruCP0	:= FWFormStruct(1,'CP0')
Local oStruCP1	:= FWFormStruct(1,'CP1')
Local oStruCPK	:= FWFormStruct(1,'CPK')

oStruCO0:SetProperty('CO0_LEI'	, MODEL_FIELD_VALUES, GCP017Leis(3)) //Possíveis valores p/ campo Lei dinamicamente
oStruCO0:SetProperty("CO0_LEI" 	, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID, "Pertence('"+ GCP017Leis(5) +"')")) //Altera o valid p/ validar dinamicamente as leis

oModel := MPFormModel():New('GCPA017',/*bPreValid*/,{|oModel| GCPA017Pos(oModel) },/*bCommit*/,/*bCancel*/)

/*
	Hierarquia das tabelas:	
 	CO0 -> Regras para Licitações
		CP5 -> Modelos de Licitação
			COZ -> Tipo de liciticação
			CP0 -> Etapas De Licitação
				CP1 -> CheckList
		COD -> Regras para Licitações Itens
		CPK -> Permissão de Carona no SRP
*/

oModel:AddFields( 'CO0MASTER', /*cOwner*/, oStruCO0,/*bPreValid*/,/*bPosValid*/,/*Carga*/)
//Adiciona Grids
oModel:AddGrid('CP5DETAIL' ,'CO0MASTER', oStruCP5,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:AddGrid('COZDETAIL' ,'CP5DETAIL', oStruCOZ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:AddGrid('CODDETAIL1','CO0MASTER', oStruCOD,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:AddGrid('CODDETAIL2','CO0MASTER', oStruCOD,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:AddGrid('CODDETAIL3','CO0MASTER', oStruCOD,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:addGrid('CP0DETAIL' ,'CP5DETAIL', oStruCP0,/*bLinePre*/,/*bLinePost*/,/*bPre*/,{|oModel|A017VlMod(oModel)}/*bPost*/,/*Carga*/)
oModel:addGrid('CP1DETAIL' ,'CP0DETAIL', oStruCP1,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:AddGrid('CPKDETAIL' ,'CO0MASTER', oStruCPK,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)

oModel:GetModel('CP5DETAIL'	):SetUniqueLine( {"CP5_MODALI"} )
oModel:GetModel('COZDETAIL'	):SetUniqueLine( { "COZ_TIPO" } )
oModel:GetModel('CP0DETAIL'	):SetUniqueLine( { "CP0_ETAPA"} )
oModel:GetModel('CP1DETAIL'	):SetUniqueLine( { "CP1_CHECK"} )
oModel:GetModel("CODDETAIL1"):SetUniqueLine( {"COD_MODALI"} )
oModel:GetModel("CODDETAIL2"):SetUniqueLine( {"COD_MODALI"} )
oModel:GetModel("CODDETAIL3"):SetUniqueLine( {"COD_MODALI"} )
oModel:GetModel("CPKDETAIL"):SetUniqueLine( {"CPK_UFCAR"} )

//Seta relacao entre os grids
oModel:SetRelation( 'CP5DETAIL' , { { 'CP5_FILIAL', 'xFilial( "CP5" )' }, { 'CP5_REGRA', 'CO0_REGRA' } }, CP5->( IndexKey( 1 ) ) )
oModel:SetRelation( 'CODDETAIL1', { { 'COD_FILIAL', 'xFilial( "COD" )' }, { 'COD_REGRA', 'CO0_REGRA' } }, COD->( IndexKey( 1 ) ) )
oModel:SetRelation( 'CODDETAIL2', { { 'COD_FILIAL', 'xFilial( "COD" )' }, { 'COD_REGRA', 'CO0_REGRA' } }, COD->( IndexKey( 1 ) ) )
oModel:SetRelation( 'CODDETAIL3', { { 'COD_FILIAL', 'xFilial( "COD" )' }, { 'COD_REGRA', 'CO0_REGRA' } }, COD->( IndexKey( 1 ) ) )
oModel:SetRelation( 'COZDETAIL' , { { 'COZ_FILIAL', 'FWXFilial("COZ")' }, { 'COZ_REGRA', 'CO0_REGRA' } , { 'COZ_MODALI', 'CP5_MODALI' } }, COZ->(IndexKey(1)) )
oModel:SetRelation( 'CP0DETAIL' , { { 'CP0_FILIAL', 'FWXFilial("CP0")' }, { 'CP0_REGRA', 'CO0_REGRA' } , { 'CP0_MODALI', 'CP5_MODALI' } }, CP0->(IndexKey(2)) )
oModel:SetRelation( 'CP1DETAIL' , { { 'CP1_FILIAL', 'FWXFilial("CP1")' }, { 'CP1_REGRA', 'CO0_REGRA' } , { 'CP1_MODALI', 'CP5_MODALI' }, { 'CP1_ETAPA', 'CP0_ETAPA' } }, CP1->(IndexKey(1)) )
oModel:SetRelation( 'CPKDETAIL' , { { 'CPK_FILIAL', 'xFilial( "CPK" )' }, { 'CPK_REGRA', 'CO0_REGRA' } }, CPK->( IndexKey( 1 ) ) )

oModel:GetModel( 'CODDETAIL3' ):SetOptional( .T. )
oModel:GetModel( 'CP1DETAIL' ):SetOptional( .T. )
oModel:SetPrimaryKey({"CO0_FILIAL","CO0_REGRA"})

//Filtra os dados para Obras, Compras e Alienacao
oModel:GetModel('CODDETAIL1'):SetLoadFilter({{'COD_ESPECI',"'1'",MVC_LOADFILTER_EQUAL}})
oModel:GetModel('CODDETAIL2'):SetLoadFilter({{'COD_ESPECI',"'2'",MVC_LOADFILTER_EQUAL}})
oModel:GetModel('CODDETAIL3'):SetLoadFilter({{'COD_ESPECI',"'3'",MVC_LOADFILTER_EQUAL}})

GCP017BMod(oModel,{'CP5DETAIL','CODDETAIL1','CODDETAIL2','CODDETAIL3','CPKDETAIL'},.T.)//Bloquear Modelos

//Bloquear deleção de linhas do modelo
oModel:GetModel('COZDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('COZDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('CP0DETAIL'):SetUseOldGrid(.T.)
oModel:GetModel('CP5DETAIL'):SetUseOldGrid(.T.)
oModel:SetActivate({|oModel| GCPA017TCoz(oModel)})
oModel:SetVldActivate({|oModel| GC017VlAct(oModel)})

Return oModel

/*/{Protheus.doc} GC017VlAct
	Valida a ativação do modelo de dados do GCPA017
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instância de MPFormModel antes da ativação
@return lResult, lógico, verdadeiro se puder ativar o modelo
*/
Function GC017VlAct(oModel)
	Local lResult := .T.

	If (oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE)
		If !(FwIsInCallStack('GCP017CARGA') .Or. FwIsInCallStack("GCP017ATRE"))
			lResult := VldRegPadr(CO0->CO0_REGRA)			
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc} VldRegPadr
	Valida <cRegra>, se for padrão, informa ao usuário que o valor é inválido
@author philipe.pompeu
@since 10/03/2022
@param cRegra, caractere, regra a ser validada
@return lResult, lógico, verdadeiro se <cRegra> não for padrão
*/
Static Function VldRegPadr(cRegra)
	Local lResult := .T.
	
	If IsRegrPadr(cRegra)
		Help(' ', 1,'A017RANGE') //As regras de 001 a 020 são reservadas e de uso exclusivo da Totvs. Não é permitido incluir ou excluir estas regras.
		lResult := .F.	
	EndIf
Return lResult

/*/{Protheus.doc} IsRegrPadr
	Retorna se <cRegra> é um código padrão do sistema
@author philipe.pompeu
@since 10/03/2022
@param cRegra, caractere, regra a ser validada
@return lResult, lógico, verdadeiro se <cRegra> for padrão
*/
Static Function IsRegrPadr(cRegra)
	Local lResult := .F.
	lResult := (cRegra $ "000|001|002|003|004|005|006|007|008|009|010|011|012|013|014|015|016|017|018|019|020")
Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA017Pos
Pós-validação do modelo
@author Raphael Augustos
@since 19/09/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCPA017Pos(oModel)
	Local lRet	:= .T.
	Local aTemp	:= {}
	Local nLine	:= 0
	Local cTitle:= "Erro no fluxo da modalidade: "
	Local nX
	Local oGrafo
	Local oGridCP0
	Local oGridCP5 	:= oModel:GetModel('CP5DETAIL')
	Local l13303	:= oModel:GetValue('CO0MASTER','CO0_LEI') == '5' //- Define se Lei 13.303/2016
	Local lPG13303  := .F.

	If oModel:GetOperation()== MODEL_OPERATION_INSERT
		lRet := VldRegPadr(oModel:GetValue("CO0MASTER","CO0_REGRA"))		
	EndIf

	If lRet
		//-----------------------------------------
		// Valida o fluxo de todas as modalidades
		//-----------------------------------------
		nLine := oGridCP5:Getline()
		For nX :=  1 To oGridCP5:Length()
			oGridCP5:GoLine(nX)
			oGridCP0 := oModel:GetModel( "CP0DETAIL" )
			aTemp := aClone(oGridCP0:aCols)
			oGrafo   := GCPGrafo():New(aTemp)
			lPG13303 := oGridCP5:GetValue("CP5_MODALI") == "PG"
			//-------------------------------------------------------------------
			// Válida o fluxo de etapas - CP0 (CP0DETAIL)
			//-------------------------------------------------------------------
			oGrafo:nAtual 		:= GdFieldPos("CP0_ETAPA",oGridCP0:aHeader)		//Coluna das etapas
			oGrafo:nNext 		:= GdFieldPos("CP0_PROXIV",oGridCP0:aHeader)	//Coluna do verdadeiro
			oGrafo:nBack 		:= GdFieldPos("CP0_PROXIF",oGridCP0:aHeader)	//Coluna do falso
			oGrafo:cInicio 		:= Iif(l13303 .And. !lPG13303, "PR", "ED")						//Etapa inicial
			oGrafo:cMeio 		:= Iif(l13303 .And. !lPG13303, "DV", "PB")						//Etapa do meio
			oGrafo:cFim 	 	:= "FI"											//Etapa Final

			//--------------------------------------------------
			// Valida as etapas obrigatórios por modalidade
			//--------------------------------------------------
			Do Case
				Case oGridCP5:GetValue("CP5_MODALI") == "CC"
					oGrafo:aCDObrig 	:= {"ED","PB","JP","AD","FI"}
				Case oGridCP5:GetValue("CP5_MODALI") == "CV"
					oGrafo:aCDObrig 	:= {"ED","PB","JP","AD","FI"}
				Case oGridCP5:GetValue("CP5_MODALI") == "TP"
					oGrafo:aCDObrig 	:= {"ED","PB","JP","AD","FI"}
				Case oGridCP5:GetValue("CP5_MODALI") == "DL"
					oGrafo:aCDObrig 	:= Iif (l13303,{"PR","DV","HA","AD","FI"},{"ED","PB","JP","AD","FI"})
				Case oGridCP5:GetValue("CP5_MODALI") == "IN"
					oGrafo:aCDObrig 	:= Iif (l13303,{"PR","DV","HA","AD","FI"},{"ED","PB","JP","AD","FI"})
				Case oGridCP5:GetValue("CP5_MODALI") == "LL"
					oGrafo:aCDObrig 	:= {"ED","PB","JP","AD","FI"}
				Case oGridCP5:GetValue("CP5_MODALI") == "PL"
					oGrafo:aCDObrig 	:= {"PR","DV","JP","HA","AD","FI"}
			EndCase

			oGrafo:DelLine() // Deleta fisicamente as linhas deletadas
			oGrafo:GeraGrafo()

			If Len(oGrafo:aErro) > 0
				lRet :=  .F.			
				//-------------------------------------------------------------------
				// Exibe tela com os erros do fluxo de etapas
				//-------------------------------------------------------------------
				If !IsBlind()
					oGrafo:LogGrafo(oGrafo:aErro ,cTitle + oGridCP5:GetValue("CP5_MODALI"))
				EndIf
				Exit
			Else
				If oGridCP5:GetValue("CP5_MODALI") == "PG" .And. FwFldGet('CO0_LEI') == '3'
					If !(lRet := A017VldCN(oGrafo:aVerdade, oModel))
						If !IsBlind()
							oGrafo:LogGrafo(oGrafo:aErro ,"ERRO CN")
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX
		oGridCP5:GoLine(nLine)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCO0	:= FWFormStruct(2,'CO0')
Local oStruCOZ	:= FWFormStruct(2, 'COZ')
Local oStruCP5	:= FWFormStruct(2, 'CP5')
Local oStruCOD	:= FWFormStruct(2,'COD', {|cCampo| !AllTrim(cCampo) $ "COD_ESPECI"} )
Local oStruCP0	:= FWFormStruct(2, 'CP0')
Local oStruCP1	:= FWFormStruct(2, 'CP1')
Local oStruCPK	:= FWFormStruct(2, 'CPK')
Local oModel	:= FWLoadModel("GCPA017")
Local oView
Local aCombo	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o modelo da interface do formulário³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:= FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_CO0' , oStruCO0,	'CO0MASTER'	)

aAdd(aCombo, GCP017Leis(4))
oView:SetFieldProperty("CO0MASTER","CO0_LEI","COMBOVALUES", aCombo)

oView:AddGrid(	'VIEW_CP5' , oStruCP5,	'CP5DETAIL'	)
oView:AddGrid(	'VIEW_COD1', oStruCOD, 'CODDETAIL1' )
oView:AddGrid(	'VIEW_COD2', oStruCOD, 'CODDETAIL2' )
oView:AddGrid(  'VIEW_COD3', oStruCOD, 'CODDETAIL3' )
oView:AddGrid(	'VIEW_COZ' , oStruCOZ,	'COZDETAIL'	)
oView:AddGrid(	'VIEW_CPO' , oStruCP0,	'CP0DETAIL'	)
oView:AddGrid(	'VIEW_CP1' , oStruCP1,	'CP1DETAIL'	)
oView:AddGrid(	'VIEW_CPK' , oStruCPK,	'CPKDETAIL'	)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria as 3 divisoes da interface³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox( 'SUPERIOR',25 )
oView:CreateHorizontalBox( 'MEDIO',35    )
oView:CreateHorizontalBox( 'INFERIOR',40 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a pasta e planilhas do Modelo de Licitacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateFolder( 'FLDMOD', 'MEDIO')
oView:AddSheet('FLDMOD','GRDMOD',STR0042)//"Modalidades da Licitação"
oView:CreateHorizontalBox( 'MODAL', 100, /*owner*/, /*lUsePixel*/, 'FLDMOD', 'GRDMOD')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a pasta e planilhas do Sistema de Registro de Preços ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oView:CreateFolder( 'FLDSRP', 'MEDIO')
oView:AddSheet('FLDMOD','GRDSRP',STR0043)//'Sistema de Registro de preços'
oView:CreateHorizontalBox( 'SRP', 100, /*owner*/, /*lUsePixel*/, 'FLDMOD', 'GRDSRP')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria Segunda pasta e demais planilhas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateFolder( 'FldGeral', 'INFERIOR')
oView:AddSheet('FldGeral','GRDTPO',STR0015) 	  		// "Tipo"
oView:AddSheet('FldGeral','GRDLMT',STR0018) 			// "Limites"
oView:AddSheet('FldGeral','GRDFLX',STR0019) 			// "Fluxo"

oView:CreateHorizontalBox( 'TIPO', 100, /*owner*/, /*lUsePixel*/, 'FldGeral', 'GRDTPO')
oView:CreateHorizontalBox( 'LIMT', 100, /*owner*/, /*lUsePixel*/, 'FldGeral', 'GRDLMT')
oView:CreateHorizontalBox( 'FLUX', 100, /*owner*/, /*lUsePixel*/, 'FldGeral', 'GRDFLX')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria folder dos Limites ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateFolder('FldLimit','LIMT')
oView:AddSheet('FldLimit' ,"GRDOBS"	,STR0005)				//"Obras e Servicos de Engenharia"
oView:AddSheet('FldLimit' ,"GRDCOM"	,STR0006)				//"Compras e Demais Serviços"
oView:AddSheet('FldLimit' ,"GRDBNS"	,STR0007)				// "Alienação de Bens"

oView:CreateHorizontalBox('OBRAS',100,,,'FldLimit',"GRDOBS")
oView:CreateHorizontalBox('COMPR',100,,,'FldLimit',"GRDCOM")
oView:CreateHorizontalBox('ALIEN',100,,,'FldLimit',"GRDBNS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria folder do Fluxo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateFolder( 'FldFluxo', 'FLUX')
oView:AddSheet('FldFluxo','GRDETP',STR0016)		// "Etapas"
oView:AddSheet('FldFluxo','GRDCHK',STR0017)		// "Check-List"

oView:CreateVerticalBox( 'ETPESQ', 93, /*owner*/, /*lUsePixel*/, 'FldFluxo', 'GRDETP')
oView:CreateVerticalBox( 'ETPDDIR', 07, /*owner*/, /*lUsePixel*/, 'FldFluxo', 'GRDETP')
oView:CreateHorizontalBox( 'CHK' , 100, /*owner*/, /*lUsePixel*/, 'FldFluxo', 'GRDCHK')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relaciona o identificador (ID) da View com o "box" para exibição³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:SetOwnerView( 'VIEW_CO0'	, 'SUPERIOR')
oView:SetOwnerView( 'VIEW_CP5'	, 'MODAL'	)
oView:SetOwnerView( 'VIEW_COD1' , 'OBRAS'	)
oView:SetOwnerView( 'VIEW_COD2' , 'COMPR'	)
oView:SetOwnerView( 'VIEW_COD3' , 'ALIEN'	)
oView:SetOwnerView( 'VIEW_COZ'	, 'TIPO'	)
oView:SetOwnerView( 'VIEW_CPO'	, 'ETPESQ'	)
oView:SetOwnerView( 'VIEW_CP1'	, 'CHK'		)
oView:SetOwnerView( 'VIEW_CPK'	, 'SRP'		)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona controles incrementais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddIncrementField("VIEW_CP5","CP5_ITEM")
oView:AddIncrementField("VIEW_COD1","COD_ITEM")
oView:AddIncrementField("VIEW_COD2","COD_ITEM")
oView:AddIncrementField("VIEW_COD3","COD_ITEM")
oView:AddIncrementField('VIEW_CPO' , 'CP0_ORDEM' )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adicona os botoes Acima, Abaixo, Inicio, Fim³
//³Para movimentar a ordem das etapas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddOtherObject("OTHER_PANEL", {|oPanel| GCPGrdOrd( oPanel, oView, 'CP0DETAIL', 'CP0_ORDEM' )})
oView:SetOwnerView("OTHER_PANEL",'ETPDDIR')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remove campos de amarracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStruCP5:RemoveField( "CP5_REGRA" )

oStruCOZ:RemoveField("COZ_MODALI")
oStruCOZ:RemoveField("COZ_REGRA")

oStruCOD:RemoveField("COD_REGRA")

oStruCP0:RemoveField("CP0_REGRA")
oStruCP0:RemoveField("CP0_MODALI")
oStruCP0:RemoveField("CP0_TIPO")

oStruCP1:RemoveField("CP1_REGRA")
oStruCP1:RemoveField("CP1_DESREG")
oStruCP1:RemoveField("CP1_DESESP")
oStruCP1:RemoveField("CP1_MODALI")
oStruCP1:RemoveField("CP1_DESMOD")
oStruCP1:RemoveField("CP1_TIPO")
oStruCP1:RemoveField("CP1_DESTIP")
oStruCP1:RemoveField("CP1_ETAPA")
oStruCP1:RemoveField("CP1_DESETA")

oStruCPK:RemoveField("CPK_REGRA")

oStruCP0:SetProperty('CP0_ORDEM', MVC_VIEW_CANCHANGE, .F.)//Bloqueia a edição do campo ORDEM
oStruCPK:SetProperty('CPK_ITEM', MVC_VIEW_CANCHANGE, .F.)//Bloqueia a edição do campo ITEM
oStruCP5:SetProperty('CP5_ITEM', MVC_VIEW_CANCHANGE, .F.) 	
oStruCP5:SetProperty('CP5_MODALI', MVC_VIEW_CANCHANGE, .F.) 	
	

oStruCOZ:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruCOZ:SetProperty('COZ_USADO', MVC_VIEW_CANCHANGE, .T.)

oView:AddUserButton(STR0044, 'CLIPS', {|oView|  GCP017Etap(oModel)})//'Carregar etapas'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA017Ini
Inicializador padrao executado pelo x3_relacao do campo COD_ESPECI

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCPA017Ini(oModel,cField,xConteudo)
Local cRet := "0"

If	oModel:GetId()=='CODDETAIL1'
	cRet:="1"
ElseIf oModel:GetId()=='CODDETAIL2'
	cRet:="2"
ElseIf oModel:GetId()=='CODDETAIL3'
	cRet:="3"
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA017Lim
Valida os limites das modalidades conforme a Lei

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCPA017Lim(cRegra,cEspeci,cModali,nVlrEdt, lMostraHelp)
Local aAreaAnt 	:= GetArea()
Local aVldMdl   	:= {}
Local cAliasCOD 	:= ""
Local cMsg    	:= ""
Local lRet 		:= .T.
Local aRet    	:= {}
Local clei			:= ''
Local nVlrLim		:= 0
Local nMenorFx	:= 0

Default lMostraHelp := .T.
Default cModali := ''

//--Valida se a modalidade é leilão e se o valor é maior que R$ 650.000,00
If cModali == "LL"
	DbSelectArea("COD")
	COD->(DbSetOrder(2))
	If COD->(dbSeek(xFilial('COD')+cRegra+cModali+cEspeci))
		nVlrLim := COD->COD_FXFIM
		If nVlrEdt > nVlrLim
			Help("",1,STR0045,,STR0031,4,1)//'Para o valor total informado utilize a Modalidade "CC" (Concorrência) com o campo Gera Docs. igual a 2=Venda, conforme Art. 17, § 6º, da Lei nº 8.666/93.'
			lRet := .F.
		EndIf
	EndIf
EndIf
//--

DbSelectArea("CO0")
DbSetOrder(1)
If CO0->(DbSeek(xFilial("CO0")+cRegra))
	cLei := CO0->CO0_LEI
EndIf

//-- ATENCAO: Apenas as modalidades relacionadas no vetor aVldMdl serao limitadas
Do Case
	Case cLei=="1" //-- 8.666

		aVldMdl:={"CV","TP","DL"}

	Case cLei=="2" //-- Sistema "S"

	   If    cEspeci<>"3"
	         aVldMdl:={"CV","CC","DL"}
	   Else
	         aVldMdl:={"CC","LL","DL"}
	   EndIf

	Case cLei == '5' //-- 13.303
		If IsInCallStack("GCPA100") .Or. IsInCallStack("GCPA101") .or. (A200ARTPAR('29','I',.T.) .Or. A200ARTPAR('29','II',.T.))
			aVldMdl:={"DL"}
		EndIf
	Case cLei == '6' // 14.133/21
		aVldMdl:= {}//TODO: conferir implicações para lei 14.133
EndCase

If AScan(aVldMdl,cModali)>0 .Or. !lMostraHelp

       cAliasCOD := GetNextAlias()

       BeginSQL Alias cAliasCOD

       SELECT COD.COD_MODALI, COD.COD_FXINI, COD.COD_FXFIM

       FROM %table:COD% COD

       WHERE COD.COD_FILIAL = %xfilial:COD%
             AND COD.COD_REGRA = %exp:cRegra%
             AND COD.COD_ESPECI = %exp:cEspeci%
	         AND ((%exp:nVlrEdt% BETWEEN COD.COD_FXINI AND COD.COD_FXFIM)

	         OR ((%exp:nVlrEdt% > COD.COD_FXINI AND COD.COD_FXFIM = '9999999999999.99'))
	         OR  (COD.COD_FXEXC>0 AND COD.COD_FXEXC = %exp:nVlrEdt%))
             AND COD.%NotDel%
       ORDER BY %Order:COD%

       EndSql

		While (cAliasCOD)->(!EOF())
			
			If nMenorFx == 0
				nMenorFx := (cAliasCOD)->COD_FXFIM
				aRet := {(cAliasCOD)->COD_MODALI,cMsg}
			EndIf
			
			If (cAliasCOD)->COD_MODALI # cModali
				//Montar mensagem com as modalidades que podem ser utilizadas
				If Empty(cMsg)
					cMsg := STR0008 +cModali +" - " +AllTrim(Tabela("LF",cModali,.F.)) +STR0009 +CRLF       //"A modalidade "###" não é vãlido para o valor total desse edital."
					cMsg += STR0010 +CRLF //"Utilize uma das seguintes modalidades:"
					cMsg += (cAliasCOD)->COD_MODALI + " - " + AllTrim(Tabela("LF",(cAliasCOD)->COD_MODALI,.F.)) +CRLF

					If cLei == "1"
						cMsg += CRLF +STR0011 + STR0012 //"Conforme "###"Lei 8.666 Art. 23 inciso I e II.
					ElseIf cLei == "2"
						cMsg += CRLF +STR0011 + STR0013  //"Conforme Regulamento de Licitações e Contratos Art. 6 inciso I, II e III."
					EndIf

					//Quando a modalidade é DL, existem artigos e parágrafos que permitem exceder o limite
					If cModali == "DL" .And. cLei $ "1*5"
						cMsg += CRLF + CRLF + STR0037
					EndIf
				EndIf
				If lMostraHelp
					lRet := .F.
				Else
					If nMenorFx > (cAliasCOD)->COD_FXFIM
						nMenorFx := (cAliasCOD)->COD_FXFIM
						aRet := {(cAliasCOD)->COD_MODALI,cMsg}
					EndIf
				EndIf
			Else
				cMsg := ""
				lRet := .T.
				If !lMostraHelp
					If nMenorFx > (cAliasCOD)->COD_FXFIM
						nMenorFx := (cAliasCOD)->COD_FXFIM
						aRet := {(cAliasCOD)->COD_MODALI,cMsg}
					EndIf
				EndIf
				Exit
			EndIf
			(cAliasCOD)->(DbSkip())
		End
       (cAliasCOD)->(DbCloseArea())

		If !lRet .And. lMostraHelp
			Help("",1,STR0014,,cMsg,4,1)//Atenção
		EndIf

EndIf

RestArea(aAreaAnt)
Return Iif(lMostraHelp,lRet,aRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} GCP017Carga
Efetua carga inicial nas tabelas CO0 e COD

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//--------------------------------------------------------------------
Function GCP017Carga()
	Local oModel
	Local lRet		:= .T.
	Local aLeis 	:= {}
	Local nX		:= 1
	Local nTotLei	:= GCP017Leis(1)
	Local nLeiAtu	:= GCPATtLei()[2]
	Local lContinua	:= .F.
	Local nTamRegra := TAMSX3('CO0_REGRA')[1]
	Local cRegra	:= ""
	Local cFilCO0	:= xFilial('CO0')

	lContinua := IIF(IsBlind(), .T., MSGYESNO(STR0024,STR0014))

	If lContinua
		Begin Transaction

			aLeis := GCP017Leis(2) //Obtem as descrições das leis

			for nX := 1 to Len(aLeis)
				IncluiLei(nX, aLeis[nX])
			next nX
			FwFreeArray(aLeis)

			CO0->(DbGoTop())
		End Transaction
		
		oModel:= FWLoadModel("GCPA017")
		For nX := nTotLei - (nLeiAtu - 1) To nTotLei
			cRegra := StrZero(nX,nTamRegra)
			If (lRet := CO0->(MsSeek(cFilCO0 + cRegra)))
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				
				If (lRet := oModel:Activate())				
					MsgRun(STR0046 + AllTrim(STR(nX)) + STR0047 + AllTrim(STR(nTotLei)) , STR0048 ,{||GCP017Etap(oModel) }) //"Carregando Leis  " # " de " # "Processando..."

					If lRet := oModel:VldData()
						lRet := oModel:CommitData()
					EndIf
				EndIf				
				oModel:DeActivate()
			EndIf

			If !lRet			
				Help(' ', 1,'A017ERRCAR')
				Exit
			EndIf
		Next nX
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017Etap(oModel)
Função utlizada para gerar etapas e fluxo padrão

@author guilherme.pimentel
@param oModel Modelo de dados da Rotina
@return Nil
@since 16/09/2013
@version P11
/*/
//-------------------------------------------------------------------

Function GCP017Etap(oModel)
	Local oRegra	:= oModel:GetModel('CO0MASTER')
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local lRet 		:= .T.
	Local cAliasCOV := ''
	Local cLei		:= ""
	Local nTamOrdem	:= TamSx3("CP0_ORDEM")[1]

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		Help(' ', 1,'A017DELETE')
	ElseIf oModel:GetOperation() == MODEL_OPERATION_VIEW
		Help(' ', 1,'A017VIEW')
	Else

		GCP017BMod(oModel,{'CPKDETAIL'},.F.)

		//-- Durante a carga das etapas o checklist esta sendo gravado no campo CP1_CHECK, portanto eh necessario primeiramente gravar as tabelas de checklist
		//-- COV e COX chamando a funcao A120Import()
		COV->(DbSetOrder(1))

		cAliasCOV := GetNextAlias()

		BeginSQL Alias cAliasCOV
			SELECT COUNT(COV.COV_CODIGO) CODIGO
			FROM %table:COV% COV
			WHERE	COV.COV_FILIAL = %xfilial:COV% AND
					COV.COV_CODIGO IN ('ELA','ANA','PUB','JUL','HOM','ADJ','DIS','PRE','JPE','VER','NEG','HBE','REC','ADE','HOE')
		EndSql

		If (cAliasCOV)->CODIGO < 15
			A120Import()
		EndIf

		oModali:GoLine(1)
		If Empty(oModali:GetValue('CP5_MODALI'))
			GCP017Carona(oModel) // Carregamento do SRP
		EndIf

		GCP017BMod(oModel,{'CP5DETAIL','CODDETAIL1','CODDETAIL2','CODDETAIL3', 'COZDETAIL'},.F.)

		cLei := oModel:GetValue('CO0MASTER','CO0_LEI')

		If (cLei == '1')//CONCORRENCIA, CONVITE, TOMADA DE PRECOS E CONCURSO			
			IncConcorr(oModel) 				//Inclui modalidade Concorrência
			IncConvite(oModel)				//Inclui modalidade Convite
			IncTomadPr(oModel)				//Inclui modalidade Tomada de Preço
			IncConcurs(oModel)				//Inclui modalidade concurso
			IncDispLicit(oModel, nTamOrdem) //Inclui modalidade Dispensa de Licitação
			IncLeilao(oModel, nTamOrdem) 	//Inclui modalidade Leilão
			IncInexig(oModel, nTamOrdem) 	//Inclui modalidade Inexigibilidade				
		ElseIf (cLei == '2')
			IncConcorr(oModel)				//Inclui modalidade Concorrência
			IncConvite(oModel)				//Inclui modalidade Convite
			IncConcurs(oModel)				//Inclui modalidade concurso
			IncPregao(oModel, nTamOrdem)	//Inclui modalidade PREGAO
			IncModal5(oModel, nTamOrdem)	//Inclui modalidade 5
			IncLeilao(oModel, nTamOrdem) 	//Inclui modalidade Leilão
			IncInexig(oModel, nTamOrdem) 	//Inclui modalidade Inexigibilidade
		ElseIf (cLei == '3') //PREGAO
			IncPregao(oModel, nTamOrdem)	//Inclui modalidade PREGAO
		ElseIf (cLei == '4') //RDC
			IncRegDifC(oModel, nTamOrdem) 	//Inclui a modalidade Regime Diferenciado de Contratação			
		ElseIf (cLei == '5') //- Lei 13.303
			IncProcLic(oModel, nTamOrdem)//-- Procedimentos Licitatórios			

			//-- Dispensa de Licitação -----------------------------------------------
			oModali:Addline()
			oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
			oModali:SetValue("CP5_MODALI","DL")

			IncluiTipo(oTipo, "DL", STR0066)
			IncluiTipo(oTipo, "MP", STR0055)
			IncluiTipo(oTipo, "MD", STR0056)
			IncluiTipo(oTipo, "TP", STR0059)
			IncluiTipo(oTipo, "MT", STR0057)
			IncluiTipo(oTipo, "CA", STR0058)
			IncluiTipo(oTipo, "MO", STR0060)
			IncluiTipo(oTipo, "MR", STR0061)
			IncluiTipo(oTipo, "BA", STR0062)

			//-- Etapas
			//-- Etapa Preparação --------------------------------------------
			oEtapas:SetValue("CP0_ETAPA","PR")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","DV")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","PRE")

			//-- Etapa Divulgação --------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","DV")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","JP")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","PR")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","DIV")

			//-- Julgamento ---------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","JP")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","HA")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","DV")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","JPE")

			//-- Habilitação ---------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","HA")
			oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
			oEtapas:SetValue("CP0_PROXIV","AD")
			oEtapas:SetValue("CP0_PROXIF","RV")
			oEtapas:SetValue("CP0_ETPANT","JP")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","HBE")
			
			//-- Adjudicação --------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","AD")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","HO")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","HA")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","ADE")
			
			//-- Homologação --------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","HO")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","FI")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","HOE")

			//-- Revogação --------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","RV")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","FI")
			oEtapas:SetValue("CP0_PROXIF","DV")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","REV")

			//-- Ata de Registro de Preço ------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","AT")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","AA")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","REV")

			//-- Assinatura da Ata de Registro de Preço ----------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","AA")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","FI")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","ASA")

			//-- Etapa Final -------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","FI")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

			//-- Inexigibilidade -------------------------------------------------------
			oModali:Addline()
			oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
			oModali:SetValue("CP5_MODALI","IN")

			IncluiTipo(oTipo, "VZ", STR0067)

			//-- Etapas
			//-- Etapa Preparação --------------------------------------------
			oEtapas:SetValue("CP0_ETAPA","PR")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","DV")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","PRE")

			//-- Etapa Divulgação --------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","DV")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","JP")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","PR")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","DIV")

			//-- Julgamento ---------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","JP")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","HA")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","DV")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","JPE")

			//-- Habilitação ---------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","HA")
			oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
			oEtapas:SetValue("CP0_PROXIV","AD")
			oEtapas:SetValue("CP0_PROXIF","RV")
			oEtapas:SetValue("CP0_ETPANT","JP")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","HBE")
			
			//-- Adjudicação --------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","AD")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","HO")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","HA")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","ADE")
			
			//-- Homologação --------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","HO")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","FI")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","HOE")

			//-- Revogação --------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","RV")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","FI")
			oEtapas:SetValue("CP0_PROXIF","DV")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","REV")

			//-- Ata de Registro de Preço ------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","AT")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","AA")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","REV")

			//-- Assinatura da Ata de Registro de Preço ----------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","AA")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","FI")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:SetValue("CP0_ETPANT","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
			oCheckList:SetValue("CP1_CHECK","ASA")

			//-- Etapa Final -------------------------------------------------
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA","FI")
			oEtapas:LoadValue("CP0_CONDIC","")
			oEtapas:SetValue("CP0_PROXIV","")
			oEtapas:SetValue("CP0_PROXIF","")
			oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

			//-- Pregão -------------------------------------------------------
			oModali:Addline()
			oModali:LoadValue("CP5_ITEM", StrZero(oModali:GetLine(), TamSx3("CP5_ITEM")[1]))
			oModali:SetValue("CP5_MODALI", "PG")

			IncluiTipo(oTipo, "MP", STR0055)
			IncluiTipo(oTipo, "MO", STR0060)

			//-- Etapa Análise do Edital
			oEtapas:SetValue("CP0_ETAPA", "ED")
			oEtapas:LoadValue("CP0_CONDIC", "")
			oEtapas:SetValue("CP0_PROXIV", "AN")
			oEtapas:SetValue("CP0_PROXIF", "")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))
			oCheckList:SetValue("CP1_CHECK", "ELA")

			//-- Etapa Análise do Edital
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "AN")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017ANL()")
			oEtapas:SetValue("CP0_PROXIV", "PB")
			oEtapas:SetValue("CP0_PROXIF", "ED")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))
			oCheckList:SetValue("CP1_CHECK", "ANA")

			//-- Etapa Publicação do Edital
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "PB")
			oEtapas:LoadValue("CP0_CONDIC", "")
			oEtapas:SetValue("CP0_PROXIV", "AE")
			oEtapas:SetValue("CP0_PROXIF", "")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))
			oCheckList:SetValue("CP1_CHECK", "PUB")

			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "AE")
			oEtapas:LoadValue("CP0_CONDIC", "")
			oEtapas:SetValue("CP0_PROXIV", "JP")
			oEtapas:SetValue("CP0_PROXIF", "")
			oEtapas:SetValue("CP0_ETPANT", "PB")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa de Julgamento das Propostas
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "JP")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017Julg()")
			oEtapas:SetValue("CP0_PROXIV", "HA")
			oEtapas:SetValue("CP0_PROXIF", "RC")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa de Habilitacao
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "HA")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017Habi()")
			oEtapas:SetValue("CP0_PROXIV", "HO")
			oEtapas:SetValue("CP0_PROXIF", "RC")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa de Homologação
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "HO")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017HOML()")
			oEtapas:SetValue("CP0_PROXIV", "AD")
			oEtapas:SetValue("CP0_PROXIF", "AT")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))
			oCheckList:SetValue("CP1_CHECK", "HOM")

			//-- Etapa de ComprasNet
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "CN")
			oEtapas:SetValue("CP0_PROXIV", "AD")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa de Adjudicação
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "AD")
			oEtapas:LoadValue("CP0_CONDIC", "")
			oEtapas:SetValue("CP0_PROXIV", "FI")
			oEtapas:SetValue("CP0_PROXIF", "")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))
			oCheckList:SetValue("CP1_CHECK", "ADJ")

			//-- Etapa Impugnação do Edital
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "IM")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017Impu()")
			oEtapas:SetValue("CP0_PROXIV", "ED")
			oEtapas:SetValue("CP0_PROXIF", "JP")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa de Recurso do Edital
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "RC")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017Rec()")
			oEtapas:SetValue("CP0_PROXIV", "ED")
			oEtapas:SetValue("CP0_PROXIF", "FI")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa Revogação do Edital
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "RV")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017Revog()")
			oEtapas:SetValue("CP0_PROXIV", "FI")
			oEtapas:SetValue("CP0_PROXIF", "PB")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa Anulação do Edital
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "AL")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017Anul()")
			oEtapas:SetValue("CP0_PROXIV", "FI")
			oEtapas:SetValue("CP0_PROXIF", "PB")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa Remanescente do Edital
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "RM")
			oEtapas:LoadValue("CP0_CONDIC", "GCP017Reman()")
			oEtapas:SetValue("CP0_PROXIV", "AD")
			oEtapas:SetValue("CP0_PROXIF", "FI")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa Ata de Registro de Preco
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "AT")
			oEtapas:LoadValue("CP0_CONDIC", "")
			oEtapas:SetValue("CP0_PROXIV", "AA")
			oEtapas:SetValue("CP0_PROXIF", "")
			oEtapas:LoadValue("CP0_MODALI", "CC")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))

			//-- Etapa Assinatura da Ata de Registro de Preco
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "AA")
			oEtapas:LoadValue("CP0_CONDIC", "")
			oEtapas:SetValue("CP0_PROXIV", "FI")
			oEtapas:SetValue("CP0_PROXIF", "")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))
			oCheckList:SetValue("CP1_CHECK", "ASA")

			//-- Etapa Final
			oEtapas:Addline()
			oEtapas:SetValue("CP0_ETAPA", "FI")
			oEtapas:LoadValue("CP0_CONDIC", "")
			oEtapas:SetValue("CP0_PROXIV", "")
			oEtapas:SetValue("CP0_PROXIF", "")
			oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), nTamOrdem))
		ElseIf(cLei == '6')//Lei 14.133/21

			//Art. 28. São modalidades de licitação:pregão, concorrência, concurso, leilão e diálogo competitivo
			IncPregao(oModel, nTamOrdem)	//Inclui modalidade PREGAO
			IncConcorr(oModel) 				//Inclui modalidade Concorrência
			IncConcurs(oModel)				//Inclui modalidade concurso
			IncLeilao(oModel, nTamOrdem) 	//Inclui modalidade Leilão
			IncDlgCompt(oModel)				//Inclui modalidade Diálogo competitivo

			//Art. 72. Processo de contratação direta, que compreende os casos de inexigibilidade e de dispensa de licitação
			IncDispLicit(oModel, nTamOrdem) //Inclui modalidade Dispensa de Licitação
			IncInexig(oModel, nTamOrdem) 	//Inclui modalidade Inexigibilidade
			IncCredenc(oModel,nTamOrdem)	//Inclui modalidade credenciamento
		EndIf

		oModali:Goline(1)//- Reposiciona modelo
		oTipo:Goline(1)
		oEtapas:Goline(1)
		IncLimites(oModel, cLei) //Inclui limites p/ Lei

		If !(IsRegrPadr(oRegra:GetValue('CO0_REGRA'))) .And. oRegra:GetValue('CO0_LEI') == '2'
			GCP017BMod(oModel,{'COZDETAIL', 'CPKDETAIL'},.T.)
			oModel:GetModel("CP5DETAIL"):SetNoInsertLine(.T.)
			oModel:GetModel("CP5DETAIL"):SetNoDeleteLine(.T.)
		Else
			GCP017BMod(oModel,{'CP5DETAIL', 'COZDETAIL', 'CPKDETAIL'},.T.)
		EndIf		
		
		If IsRegrPadr(oRegra:GetValue('CO0_REGRA')) .Or. oRegra:GetValue('CO0_LEI') != '2'//Bloqueia os limites caso for regra exclusiva totvs ou lei diferente de RLC - sistema s
			GCP017BMod(oModel,{'CODDETAIL1','CODDETAIL2','CODDETAIL3'},.T.)
		EndIf

		//Desbloquear para edição
		oModel:GetModel('COZDETAIL'):SetNoUpdateLine(.F.)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017PPET
@author Israel.Escorizza
@since 06/09/2017
@version P12.1.17

Função de validação para Proseguir para Proxima ETapa

/*/
//-------------------------------------------------------------------
Function GCP017PPET()
Local lRet 	:= .T.

If !IsBlind()
	lRet := MsgYesNo(STR0032 + Posicione("SX5",1,xFilial("SX5")+'LE'+CP2->CP2_ETAPA,"X5_DESCRI"),STR0014) //"Deseja prosseguir com a " # "Atenção"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017HOML

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCP017HOML()
Return !(CO1->CO1_SRP=="1")

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017REMAN

@author Alex Egydio
@since 27/03/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCP017REMAN()
Local lRet := .T.
Local lAuto := IsBlind()
	
If !lAuto
	lRet := MsgYesNo(STR0032+Posicione("SX5",1,xFilial("SX5")+'LE'+CP2->CP2_ETAPA,"X5_DESCRI"),STR0014) //'Deseja prosseguir com a ' # "Atenção"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017BLei()
Função when do campo e CO0_LEI, com finalidade de bloquear
alteração em caso de modalidades ja cadastradas.

@author alexandre.gimenez
@since 16/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP017BLei()
Local lRet 		:= .T.
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModMod		:= oModel:getModel("CP5DETAIL")

lRet := oModMod:Length() == 1 .And. Empty(oModMod:GetValue("CP5_MODALI"))

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017BMod()
Funcao para bloquear modelo de dados

@author alexandre.gimenez
@since 16/10/2013
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function GCP017BMod(oModel,aMod,cBlock)
Local nX := 0

For nX := 1 to Len(aMod)
	If ValType(oModel:GetModel(aMod[nX])) == "O"
		oModel:GetModel(aMod[nX]):SetNoUpdateLine(cBlock)
		oModel:GetModel(aMod[nX]):SetNoInsertLine(cBlock)
		oModel:GetModel(aMod[nX]):SetNoDeleteLine(cBlock)
	EndIf
Next nX

Return Nil

/*/{Protheus.doc} IncLimites()
	Função que da carga nos limites de de acordo com o lei
@author alexandre.gimenez
@since 16/10/2013
@return lRet
/*/
Static Function IncLimites(oModel,cLei)
	Local lRet 		:= .T.
	Local aSaveLines	:= FWSaveRows()
	Local oModCOD1	:= oModel:GetModel('CODDETAIL1')
	Local oModCOD2	:= oModel:GetModel('CODDETAIL2')
	Local oModCOD3	:= oModel:GetModel('CODDETAIL3')

	If cLei == '1'
		//Obras e Serviço de Engenharia
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0001")
		oModCOD1:SetValue("COD_MODALI","DL")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",15000)
		oModCOD1:LoadValue("COD_FXEXC",30000)

		oModCOD1:AddLine()
		oModCOD1:GoLine(2)

		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0002")
		oModCOD1:SetValue("COD_MODALI","CV")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",330000)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(3)

		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0003")
		oModCOD1:SetValue("COD_MODALI","TP")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",3300000)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(4)

		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0004")
		oModCOD1:SetValue("COD_MODALI","CC")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(5)
		
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0005")
		oModCOD1:SetValue("COD_MODALI","IN")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC",0)

		//Compras e demais serviços
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0001")
		oModCOD2:SetValue("COD_MODALI","DL")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",8000)
		oModCOD2:LoadValue("COD_FXEXC",16000)

		oModCOD2:AddLine()
		oModCOD2:GoLine(2)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0002")
		oModCOD2:SetValue("COD_MODALI","CV")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",176000)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(3)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0003")
		oModCOD2:SetValue("COD_MODALI","TP")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",1430000)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(4)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0004")
		oModCOD2:SetValue("COD_MODALI","CC")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(5)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0005")
		oModCOD2:SetValue("COD_MODALI","LL")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",650000.00)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(6)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0006")
		oModCOD2:SetValue("COD_MODALI","CS")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(7)
		
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0007")
		oModCOD2:SetValue("COD_MODALI","IN")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

	ElseIf cLei == '2'
		//Obras e Serviço de Engenharia
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0001")
		oModCOD1:SetValue("COD_MODALI","DL")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",79000)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(2)

		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0002")
		oModCOD1:SetValue("COD_MODALI","CV")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",1179000)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(3)

		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0003")
		oModCOD1:SetValue("COD_MODALI","CC")
		oModCOD1:LoadValue("COD_FXINI",1179000.01)
		oModCOD1:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(4)
		
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0004")
		oModCOD1:SetValue("COD_MODALI","IN")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC",0)

		//Compras e demais serviços
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0001")
		oModCOD2:SetValue("COD_MODALI","DL")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",44000)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(2)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0002")
		oModCOD2:SetValue("COD_MODALI","CV")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",395000)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(3)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0003")
		oModCOD2:SetValue("COD_MODALI","CC")
		oModCOD2:LoadValue("COD_FXINI",395000.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(4)

		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0004")
		oModCOD2:SetValue("COD_MODALI","LL")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",650000.00)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(5)
		
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0005")
		oModCOD2:SetValue("COD_MODALI","IN")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		//Alienação de bens
		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0001")
		oModCOD3:SetValue("COD_MODALI","DL")
		oModCOD3:LoadValue("COD_FXINI",0.01)
		oModCOD3:LoadValue("COD_FXFIM",44000)
		oModCOD3:LoadValue("COD_FXEXC",0)

		oModCOD3:AddLine()
		oModCOD3:GoLine(2)

		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0002")
		oModCOD3:SetValue("COD_MODALI","CC")
		oModCOD3:LoadValue("COD_FXINI",44000.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)

		oModCOD3:AddLine()
		oModCOD3:GoLine(3)

		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0003")
		oModCOD3:SetValue("COD_MODALI","LL")
		oModCOD3:LoadValue("COD_FXINI",44000.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)

		oModCOD3:AddLine()
		oModCOD3:GoLine(4)
		
		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0004")
		oModCOD3:SetValue("COD_MODALI","IN")
		oModCOD3:LoadValue("COD_FXINI",0.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)

	ElseIf cLei == '3' .Or. cLei == '4'
		//Obras e serviços de Engenharia
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0001")
		oModCOD1:SetValue("COD_MODALI",If(cLei == '3',"PG","RD"))
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC",0)

		//Compras e demais serviços
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0001")
		oModCOD2:SetValue("COD_MODALI",If(cLei == '3',"PG","RD"))
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		//Alienação de Bens
		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0001")
		oModCOD3:SetValue("COD_MODALI",If(cLei == '3',"PG","RD"))
		oModCOD3:LoadValue("COD_FXINI",0.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)

	ElseIf cLei == '5'
		//Obras e Serviço de Engenharia
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0001")
		oModCOD1:SetValue("COD_MODALI","PL")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(2)
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0002")
		oModCOD1:SetValue("COD_MODALI","DL")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",100000.00)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:GoLine(3)
		oModCOD1:LoadValue("COD_ESPECI","1")
		oModCOD1:LoadValue("COD_ITEM","0003")
		oModCOD1:SetValue("COD_MODALI","IN")
		oModCOD1:LoadValue("COD_FXINI",0.01)
		oModCOD1:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC",0)

		oModCOD1:AddLine()
		oModCOD1:LoadValue("COD_ESPECI", "1")
		oModCOD1:LoadValue("COD_ITEM", StrZero(oModCOD1:GetLine(), TamSx3("COD_ITEM")[1]))
		oModCOD1:SetValue("COD_MODALI", "PG")
		oModCOD1:LoadValue("COD_FXINI", 0.01)
		oModCOD1:LoadValue("COD_FXFIM", 9999999999999.99)
		oModCOD1:LoadValue("COD_FXEXC", 0)

		//Compras e demais serviços
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0001")
		oModCOD2:SetValue("COD_MODALI","PL")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(2)
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0002")
		oModCOD2:SetValue("COD_MODALI","DL")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",50000.00)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:GoLine(3)
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM","0003")
		oModCOD2:SetValue("COD_MODALI","IN")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		oModCOD2:AddLine()
		oModCOD2:LoadValue("COD_ESPECI","2")
		oModCOD2:LoadValue("COD_ITEM", StrZero(oModCOD2:GetLine(), TamSx3("COD_ITEM")[1]))
		oModCOD2:SetValue("COD_MODALI","PG")
		oModCOD2:LoadValue("COD_FXINI",0.01)
		oModCOD2:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD2:LoadValue("COD_FXEXC",0)

		//Alienação de Bens
		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0001")
		oModCOD3:SetValue("COD_MODALI","PL")
		oModCOD3:LoadValue("COD_FXINI",0.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)

		oModCOD3:AddLine()
		oModCOD3:GoLine(2)
		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0002")
		oModCOD3:SetValue("COD_MODALI","DL")
		oModCOD3:LoadValue("COD_FXINI",0.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)

		oModCOD3:AddLine()
		oModCOD3:GoLine(3)
		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM","0003")
		oModCOD3:SetValue("COD_MODALI","IN")
		oModCOD3:LoadValue("COD_FXINI",0.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)

		oModCOD3:AddLine()
		oModCOD3:LoadValue("COD_ESPECI","3")
		oModCOD3:LoadValue("COD_ITEM", StrZero(oModCOD3:GetLine(), TamSx3("COD_ITEM")[1]))
		oModCOD3:SetValue("COD_MODALI","PG")
		oModCOD3:LoadValue("COD_FXINI",0.01)
		oModCOD3:LoadValue("COD_FXFIM",9999999999999.99)
		oModCOD3:LoadValue("COD_FXEXC",0)
	ElseIf cLei == '6'		
		IncLimites(oModel,'1') //Cria limites iguais ao da lei 1 p/ modalidades em comum
		IncLimites(oModel,'3')//Inclui limites p/ Pregão
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017Carona(oModel)
Função utlizada para gerar regras relativas a aceitação de carona no SRP

@author José Eulálio
@param oModel Modelo de dados da Rotina
@return Nil
@since 11/11/2013
@version P11
/*/
//-------------------------------------------------------------------

Function GCP017Carona(oModel)
Local oCarona 	:= oModel:GetModel('CPKDETAIL')
Local oModelCO0 	:= oModel:GetModel('CO0MASTER')
Local lRet 		:= .T.
Local aSaveLines	:= FWSaveRows()

oCarona:GoLine(1)
If lRet
        //-- Carrega regras para Carona por Estados
        oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
        oCarona:LoadValue("CPK_ITEM","001")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art.1º, parágrafo 3, Decreto nº 5.967 de 30/12/2010")
        oCarona:LoadValue("CPK_UFCAR","AC")
        oCarona:LoadValue("CPK_CONDIC","Órgão ou entidade da Administração Pública Estadual")

       	oCarona:Addline()
       	oCarona:Goline(2)
       	oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","002")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 17, Decreto nº 3.744, de 9/10/2007")
        oCarona:LoadValue("CPK_UFCAR","AL")
        oCarona:LoadValue("CPK_CONDIC","Não poderão exceder, por órgão ou entidade (da Administração Pública Estadual - Decreto 4.163/2009), a 100% (cem por cento) dos quantitativos registrados na Ata de Registro de Preços, limitadas essas mesmas contratações às 05 (cinco) primeiras adesões solicitadas e autorizadas")

        oCarona:Addline()
       	oCarona:Goline(3)
       	oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","003")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 22, Decreto nº 7.892/2013")
        oCarona:LoadValue("CPK_UFCAR","AP")
        oCarona:LoadValue("CPK_CONDIC","Deverão consultar o órgão gerenciador da ata para manifestação sobre a possibilidade de adesão")

        oCarona:Addline()
       	oCarona:Goline(4)
       	oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","004")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 8º, parágrafo 1, Decreto n° 24.052, de 27/02/2005")
        oCarona:LoadValue("CPK_UFCAR","AM")
        oCarona:LoadValue("CPK_CONDIC","Deverão manifestar seu interesse junto ao órgão detentor da Ata")

        oCarona:Addline()
       	oCarona:Goline(5)
       	oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","005")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 22 do Decreto nº 7.892/2013")
        oCarona:LoadValue("CPK_UFCAR","BA")
        oCarona:LoadValue("CPK_CONDIC","Poderão, justificadamente, utilizar-se de registros cadastrais")

        oCarona:Addline()
       	oCarona:Goline(6)
       	oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","006")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 17, Decreto nº 28.087, de 10/01/2006")
        oCarona:LoadValue("CPK_UFCAR","CE")
        oCarona:LoadValue("CPK_CONDIC","Deverão manifestar seu interesse junto ao Órgão Gestor do Registro de Preços")
        //-----
        oCarona:Addline()
       	oCarona:Goline(7)
       	oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","007")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 23 parágrafo 4 Decreto nº 34.509, de 10/07/2013 e TCE-DF - Processo nº 35.501/05")
        oCarona:LoadValue("CPK_UFCAR","DF")
        oCarona:LoadValue("CPK_CONDIC","Poderá ser utilizada por qualquer órgão ou entidade da administração pública não participante do registro, mediante anuência do órgão gerenciador")

        oCarona:Addline()
       	oCarona:Goline(8)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
		oCarona:LoadValue("CPK_ITEM","008")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 7º, parágrafo 12, Decreto nº 1790, de 24/01/2007")
        oCarona:LoadValue("CPK_UFCAR","ES")
        oCarona:LoadValue("CPK_CONDIC","Caberá ao órgão gerenciador da Ata autorizar a utilização da Ata de Registro de Preços por órgãos não participantes")

        oCarona:Addline()
       	oCarona:Goline(9)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","009")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 8º, parágrafo 3, Decreto Nº 7.437, de 06/09/2011")
        oCarona:LoadValue("CPK_UFCAR","GO")
        oCarona:LoadValue("CPK_CONDIC","Poderá ser utilizada por qualquer órgão ou entidade da Administração, que não tenha participado do certame licitatório, mediante prévia consulta ao órgão gerenciador")

        oCarona:Addline()
       	oCarona:Goline(10)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","010")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 8º Decreto nº 28.493, de 8/08/2012")
        oCarona:LoadValue("CPK_UFCAR","MA")
        oCarona:LoadValue("CPK_CONDIC","Deve ser dirigida ao órgão gerenciador, com indicação de seu interesse e da quantidade a ser contratada")

        oCarona:Addline()
       	oCarona:Goline(11)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","011")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 8º Decreto 44.787, de 18/04/2008")
        oCarona:LoadValue("CPK_UFCAR","MG")
        oCarona:LoadValue("CPK_CONDIC","Deve ser dirigida ao órgão gerenciador, com indicação de seu interesse e da quantidade a ser contratada")

        oCarona:Addline()
       	oCarona:Goline(12)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","012")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Lei Federal 8.666/93")
        oCarona:LoadValue("CPK_UFCAR","MS")
        oCarona:LoadValue("CPK_CONDIC","Deverão consultar o órgão gerenciador da ata para manifestação sobre a possibilidade de adesão")

        oCarona:Addline()
       	oCarona:Goline(13)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","013")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 22, Decreto nº 7.892/2013")
        oCarona:LoadValue("CPK_UFCAR","MT")
        oCarona:LoadValue("CPK_CONDIC","Poderão, justificadamente, utilizar-se de registros cadastrais")

        oCarona:Addline()
       	oCarona:Goline(14)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","014")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 22, Decreto nº 7.892/2013")
        oCarona:LoadValue("CPK_UFCAR","PA")
        oCarona:LoadValue("CPK_CONDIC","Poderão, justificadamente, utilizar-se de registros cadastrais")

        oCarona:Addline()
       	oCarona:Goline(15)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","015")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 12, Decreto nº 26.375, de 19/10/2005")
        oCarona:LoadValue("CPK_UFCAR","PB")
        oCarona:LoadValue("CPK_CONDIC","Poderá ainda ser utilizada por outros órgãos ou entidades integrantes da administração pública")

        oCarona:Addline()
       	oCarona:Goline(16)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","016")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 7º, Decreto nº 2.391, de 24/03/2008")
        oCarona:LoadValue("CPK_UFCAR","PR")
        oCarona:LoadValue("CPK_CONDIC","Não é possível à Câmara Municipal aderir a licitações realizadas pela Prefeitura porque, para isso, seria necessário existir previsão em lei nacional, emanada da União, nos termos do inciso XXVII do art. 22 da Constituição da República. (TCE-PR - Acórdão nº984/11). Os órgãos e entidades integrantes do Poder Judiciário e Legislativo Estadual, bem como o Tribunal de Contas, o Ministério Público Estadual e os Municípios do Estado do Paraná poderão utilizar o Sistema de Registro de Preços regulamentado por este Decreto ")

        oCarona:Addline()
       	oCarona:Goline(17)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","017")
        oCarona:LoadValue("CPK_CARONA","2")
        oCarona:LoadValue("CPK_LEICAR","TCE-PE - Decisão TC nº 0948/2010, proferida no Processo de Consulta TC nº 1002105-0")
        oCarona:LoadValue("CPK_UFCAR","PE")
        oCarona:LoadValue("CPK_CONDIC","não é possível a adesão, pelo município, à licitação realizada por outrem, tendo em vista não existir na Lei nº 8.666/1993 a previsão de tal hipótese de dispensa")

        oCarona:Addline()
       	oCarona:Goline(18)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","018")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 24, parágrafo 1, Decreto nº 11.319, de 13/02/2004")
        oCarona:LoadValue("CPK_UFCAR","PI")
        oCarona:LoadValue("CPK_CONDIC","Poderá ser utilizada por qualquer órgão ou ente da Administração que não tenha participado ou aderido ao certame licitatório, mediante prévia consulta ao órgão controlador")

        oCarona:Addline()
       	oCarona:Goline(19)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","019")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 17, Decreto nº 41.135, de 21/01/2008")
        oCarona:LoadValue("CPK_UFCAR","RJ")
        oCarona:LoadValue("CPK_CONDIC","A adesão a Registro de Preço efetuado por outros entes da Federação dependerá de prévia autorização emitida pela SEPLAG")

        oCarona:Addline()
       	oCarona:Goline(20)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","020")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 26 parágrafo 1, Decreto nº 21.008, de 12/01/09")
        oCarona:LoadValue("CPK_UFCAR","RN")
        oCarona:LoadValue("CPK_CONDIC","Pode ser utilizada por qualquer órgão ou entidade da Administração Pública, mediante prévia consula ao órgão gerenciador")

        oCarona:Addline()
       	oCarona:Goline(21)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","021")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 2º, Decreto nº 45.375, de 04/12/2007")
        oCarona:LoadValue("CPK_UFCAR","RS")
        oCarona:LoadValue("CPK_CONDIC","Os Órgão e Entidades da Administração Pública Estadual que não tiverem participado do certame licitatório realizado por Órgãos e Entidades da União, Estados ou Municípios, poderão aderir à Ata de Registro de Preços vigente, mediante prévia consulta ao respectivo órgão gerenciador")

        oCarona:Addline()
       	oCarona:Goline(22)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","022")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Lei Federal 8.666/93")
        oCarona:LoadValue("CPK_UFCAR","RO")
        oCarona:LoadValue("CPK_CONDIC","Deverão consultar o órgão gerenciador da ata para manifestação sobre a possibilidade de adesão")

        oCarona:Addline()
       	oCarona:Goline(23)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","023")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 23, Decreto nº 16223-E, de 07/10/2013")
        oCarona:LoadValue("CPK_UFCAR","RR")
        oCarona:LoadValue("CPK_CONDIC","Poderá ser utilizada por qualquer órgão ou entidade da administração pública que não tenha participado do certame licitatório, mediante anuência do órgão gerenciador")

        oCarona:Addline()
       	oCarona:Goline(24)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","024")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 103, Decreto nº 2.617, de 16/09/09 e TCE-SC - Prejulgado nº1.894")
        oCarona:LoadValue("CPK_UFCAR","SC")
        oCarona:LoadValue("CPK_CONDIC","É vedada a utilização da Ata de Registro de Preços por órgãos e entidades que não tenham participado do certame licitatório na condição de Unidades Participantes, ressalvado quando vinculado a Programa do Governo Federal, de abrangência nacional, de comprovado interesse público, nas áreas de assistência social, educação e saúde pública (TCE-SC - Prejulgado nº1.894)")

        oCarona:Addline()
       	oCarona:Goline(25)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","025")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Decreto nº 58.494, DE 29/10/2012")
        oCarona:LoadValue("CPK_UFCAR","SP")
        oCarona:LoadValue("CPK_CONDIC","Utilização de atas de registro de preços por outros órgãos ou entidades da Administração que não participaram do certame ('carona'). Artigos 15A e 15B do Decreto Estadual n.º 47.945, de 16 de julho de 2003, acrescentados pelo Decreto Estadual n.º 51.809, de 16 de maio de 2007, e parcialmente alterados pelo Decreto Estadual n.º 54.939, de 20 de outubro de 2009. Hipótese de dispensa de licitação não autorizada por lei")

        oCarona:Addline()
       	oCarona:Goline(26)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","026")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 10, Decreto n° 25.728, de 25/11/2008")
        oCarona:LoadValue("CPK_UFCAR","SE")
        oCarona:LoadValue("CPK_CONDIC","O Termo de Adesão do carona deve ser dirigido à Unidade Gerenciadora, com indicação de seu interesse e da quantidade estimada para conhecimento daquela unidade.")

         oCarona:Addline()
       	oCarona:Goline(27)
		oCarona:LoadValue("CPK_REGRA",oModelCO0:GetValue("CO0_REGRA"))
       	oCarona:LoadValue("CPK_ITEM","027")
        oCarona:LoadValue("CPK_CARONA","1")
        oCarona:LoadValue("CPK_LEICAR","Art. 12, parágrafo 3, Decreto nº 2.435, de 06/06/2005")
        oCarona:LoadValue("CPK_UFCAR","TO")
        oCarona:LoadValue("CPK_CONDIC","Pode ser utilizada por qualquer órgão ou entidade da administração que não tenha participado do certame licitatório, mediante previa consulta ao órgão gerenciador")

        FWRestRows( aSaveLines )


        //Volta para a primeira linha na visualização
        oCarona:Goline(1)

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA017TCoz
Validação para não inserir registro "Tipo Modalidade" no intervalo de 001 a 020
@author Taniel Balsanelli
@since 20/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------

Function GCPA017TCoz(oModel)
	Local lRet := .T.
	Default oModel := FWModelActive()

	If lRet
		oCO0Master := oModel:GetModel('CO0MASTER')
		oCOZDetail := oModel:GetModel('COZDETAIL')

		If IsRegrPadr(oCO0Master:GetValue('CO0_REGRA'))
			oCOZDetail:SetNoInsertLine(.T.)
			oCOZDetail:SetNoDeleteLine(.T.)
		Else
			oCOZDetail:SetNoInsertLine(.F.)
			oCOZDetail:SetNoDeleteLine(.F.)
		EndIf
	EndIf
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .and. lRet
		oCO0Master := oModel:GetModel('CO0MASTER')
		lVld := A017VldUso(oModel)
		If oCO0Master:GetValue('CO0_REGRA')  > "020" .and. oCO0Master:GetValue('CO0_LEI') == '2' .and. lVld
			GCP017BMod(oModel,{'CP5DETAIL'},.F.)
		EndIF 
	EndIF
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A017VlMod
Validação da linha das etapas

@author guilherme.pimentel
@param oModel
@since 21/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A017VlMod(oModel)
Local lRet := .T.
If !Empty(oModel:GetValue('CP0_CONDIC')) .And. Empty(oModel:GetValue('CP0_PROXIF'))
	lRet := .F.
	Help("",1,"Atenção",,STR0028,4,1)//"Quando há condição é necessário informar a próxima etapa caso o resultado seja falso"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017JUL3
Validação da etapa AE/J3

@author aline.sebrian
@since 07/02/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP017JUL3()
Local lRet := .T.
Local lAuto := IsBlind()

If !(CO1->CO1_MODISP $ '34')
	lRet := .F.
Else
	If !lAuto
		lRet := MsgYesNo('Deseja prosseguir com a '+Posicione("SX5",1,xFilial("SX5")+'LE'+CP2->CP2_ETAPA,"X5_DESCRI"),"Atenção")
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA017Upd
Validação para não permitir alterar as regras default.
@author antenor.silva
@since 13/02/2014
@version P12
/*/
//-------------------------------------------------------------------
Function GCPA017Upd()
	Local lRet 	:= .T.
	
	FWExecView (STR0003, "GCPA017", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA017Exc
Validação para não permitir excluir as regras default.
@author antenor.silva
@since 13/02/2014
@version P12
/*/
//-------------------------------------------------------------------
Function GCPA017Exc()
	Local lRet 	:= .T.
	FWExecView (STR0004, "GCPA017", MODEL_OPERATION_DELETE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A017VldCN()
Função para validar etapa vinda do ComprasNet
@author filipe.goncalves
@param aVerdade
@since 10/09/2015
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A017VldCN(aVerdade, oModel)
	Local aSaveLines	:= FWSaveRows()
	Local oModelCP5	:= oModel:GetModel('CP5DETAIL')
	Local oModelCP0	:= oModel:GetModel('CP0DETAIL')
	Local cEtapa 		:= aVerdade[1][3][Len(aVerdade[1][3])-2]
	Local cPrxEtp		:= ""
	Local lRet 		:= .T.
	Local nX 			:= 0
	Local nPos			:= 0

	For nX :=  1 To oModelCP5:Length()
		oModelCP5:GoLine(nX)
		If oModelCP5:GetValue('CP5_MODALI') == "PG"
			nPos := MTFindMVC(oModelCP0,{{'CP0_ETAPA',"CN"}})
			If nPos > 0
				oModelCP0:GoLine(nPos)
				While lRet == Nil
					cPrxEtp := oModelCP0:GetValue('CP0_PROXIV')
					If cPrxEtp == 'JP' .Or. !MTFindMVC(oModelCP0,{{'CP0_PROXIV',cPrxEtp}})
						lRet := .F.
						Help("",1,"A017ERRO",,STR0050,4,1)//"Existe no fluxo a etapa JP depois da etapa CN, portanto não será validado!"
					ElseIf cPrxEtp == cEtapa
						lRet := .T.
					EndIf 
				End
			Else
				Help("",1,"A017ERRO",,STR0051,4,1)//"Não foi encontrado a etapa CN do CompraNet, favor avaliar fluxo!"
			EndIf			
		EndIF
	Next nX
	FWRestRows( aSaveLines )
	FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017ATRE()
Função para utilizar o MsgRun no botão atualizar as regras
@author filipe.goncalves
@param aVerdade
@since 11/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCP017RUAT()

MsgRun(STR0052 , STR0048 ,{||GCP017ATRE()})//"Verificando atualizações! " # "Processando"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP017ATRE()
Função para atualizar as regras padrões
@author filipe.goncalves
@since 11/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCP017ATRE(lModLoad)
Local aArea			:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local oModel		:= Nil
Local oModelCP0		:= Nil

Local lAtu			:= .F.
Local lAtuLei5		:= .F.

Local nX			:= 0
Local nY			:= 0

Local aAreaCP5		:= CP5->(GetArea())
Local aAreaCOD		:= COD->(GetArea())
Local aAreaCO0		:= CO0->(GetArea())

Default lModLoad	:= .F.

//           Lei, Item, Especie,Item Limite COD
aRegras := {	{"1","007",{{"1","0005"},{"2","0007"}}},;
				{"2","007",{{"1","0004"},{"2","0005"},{"3","0004"}}},;
				{"6","007",{{"1","0005"},{"2","0007"}}};
			}
CP5->(dbSetOrder(2)) //filial+regra+modalidade
COD->(dbSetOrder(2)) //filial+regra+modalidade+ESPECI
COZ->(dbSetOrder(1)) //COZ_FILIAL+COZ_REGRA+COZ_MODALI+COZ_TIPO

CO0->(dbGoTop())
While CO0->(! Eof())
	If CO0->CO0_LEI $ '12'	
		For nx := 1 to Len(aRegras)
			If CO0->CO0_LEI != aRegras[nx,1]
				Loop
			EndIf	 

			//Incluir Modalidade(
			if CP5->(! dbSeek(xFilial("CP5")+CO0->CO0_REGRA+"IN"))
				RecLock("CP5",.T.)
				CP5->CP5_FILIAL:=xFilial("CP5")
				CP5->CP5_REGRA:=CO0->CO0_REGRA
				CP5->CP5_ITEM:=aRegras[nx,2]
				CP5->CP5_MODALI:="IN"
				CP5->(MsUnLock())
				lAtu := .T.
			EndIf	
				
			//Incluir Tipos(COZ)
			if COZ->(! dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"INVZ"))
				RecLock("COZ",.T.)
				COZ->COZ_FILIAL:=xFilial("COZ")
				COZ->COZ_REGRA:=CO0->CO0_REGRA
				COZ->COZ_MODALI:="IN"
				COZ->COZ_TIPO:="VZ"
				COZ_DESCRI:=STR0067
				COZ_USADO:=.T.
				COZ->(MsUnLock())
				lAtu := .T.
			EndIf	
			
			If CO0->CO0_LEI == '2'
				If COZ->(! dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"CVTP"))
					RecLock("COZ",.T.)
					COZ->COZ_FILIAL:=xFilial("COZ")
					COZ->COZ_REGRA:=CO0->CO0_REGRA
					COZ->COZ_MODALI:="CV"
					COZ->COZ_TIPO:="TP"
					COZ_DESCRI:=STR0059
					COZ_USADO:=.T.
					COZ->(MsUnLock())
					lAtu := .T.
				EndIf	
				
				If COZ->(! dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"CSMT"))
					RecLock("COZ",.T.)
					COZ->COZ_FILIAL:=xFilial("COZ")
					COZ->COZ_REGRA:=CO0->CO0_REGRA
					COZ->COZ_MODALI:="CS"
					COZ->COZ_TIPO:="MT"
					COZ_DESCRI:=STR0057
					COZ_USADO :=.T.
					COZ->(MsUnLock())
					lAtu := .T.
				EndIf
				
				If COZ->(! dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"LLMO"))
					RecLock("COZ",.T.)
					COZ->COZ_FILIAL:=xFilial("COZ")
					COZ->COZ_REGRA:=CO0->CO0_REGRA
					COZ->COZ_MODALI:="LL"
					COZ->COZ_TIPO:="MO"
					COZ_DESCRI:=STR0060
					COZ_USADO :=.T.
					COZ->(MsUnLock())
					lAtu := .T.
				EndIf
				
				If COZ->(! dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"CVMP"))
					RecLock("COZ",.T.)
					COZ->COZ_FILIAL:=xFilial("COZ")
					COZ->COZ_REGRA:=CO0->CO0_REGRA
					COZ->COZ_MODALI:="CV"
					COZ->COZ_TIPO:="MP"
					COZ_DESCRI:=STR0055
					COZ_USADO:=.T.
					COZ->(MsUnLock())
					lAtu := .T.
				EndIf	
				
				If COZ->(! dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"CVMO"))
					RecLock("COZ",.T.)
					COZ->COZ_FILIAL:=xFilial("COZ")
					COZ->COZ_REGRA:=CO0->CO0_REGRA
					COZ->COZ_MODALI:="CV"
					COZ->COZ_TIPO:="MO"
					COZ_DESCRI:=STR0060
					COZ_USADO:=.T.
					COZ->(MsUnLock())
					lAtu := .T.
				EndIf
			EndIf
		
			//Incluir Limites(COD)
			For nY:=1 to Len(aRegras[nx,3])
				COD->(dbSetOrder(2))   //aRegras[nx,3]+
				cChaveCOD:= xFilial("COD")+CO0->CO0_REGRA+"IN"+aRegras[nx,3,nY,1]
				If COD->(!dbSeek(cChaveCOD))
					RecLock("COD",.T.)
					COD->COD_FILIAL:=xFilial("COD")
					COD->COD_REGRA:=CO0->CO0_REGRA
					COD->COD_MODALI:="IN"		
					COD->COD_ESPECI:=aRegras[nx,3,nY,1]
					COD->COD_ITEM:=aRegras[nx,3,nY,2]
					COD->COD_FXINI:=0.01
					COD->COD_FXFIM:=9999999999999.99
					COD->COD_FXEXC:=0
					COD->(MsUnLock())
					lAtu := .T.
				EndIf
			Next nY
			// Atualizar limites Lei 8666. Decreto nº9412 (http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/decreto/D9412.htm)
			IF CO0->CO0_LEI == '1'
				COD->(DbGotOP())
				DbSelectarea("COD")
				DbSetOrder(1)
				cChave:= xFilial("COD")+CO0->CO0_REGRA
				dbSeek(cChave)
		
				While !COD->(Eof()) .and. xFilial("COD")+CO0->CO0_REGRA == cChave 
					If  COD->COD_MODALI == 'CV' .and. COD->COD_ESPECI == '1'
						RecLock("COD",.F.)
						COD->COD_FXFIM:=330000.00
						COD->(MsUnLock())
					EndIF
					If  COD->COD_MODALI == 'TP' .and. COD->COD_ESPECI == '1'
						RecLock("COD",.F.)
						COD->COD_FXFIM:=3300000.00
						COD->(MsUnLock())
					EndIF
					If  COD->COD_MODALI == 'CV' .and. COD->COD_ESPECI == '2'
						RecLock("COD",.F.)
						COD->COD_FXFIM:=176000.00
						COD->(MsUnLock())
					EndIF
					If  COD->COD_MODALI == 'TP' .and. COD->COD_ESPECI == '2'
						RecLock("COD",.F.)
						COD->COD_FXFIM:=1430000.00
						COD->(MsUnLock())
					EndIF
					COD->(DbSkip())
				EndDo
			EndIF
			
		
			//Excluir da tabela Tipos de Licitação(COZ)
			if COZ->( dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DLIN"))
				RecLock("COZ",.F.)
				COZ->(dbDelete())
				COZ->(MsUnLock())
				lAtu := .T.
			EndIf
			
				
		Next nX

		//Etapa ED
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INED')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='001'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='ED'	
		CP0->CP0_CONDIC:=''
		CP0->CP0_PROXIV:='AN'
		CP0->CP0_PROXIF:=''
		CP0->CP0_ETPANT:=''
		CP0->(msUnLock())
		
		//Etapa AN
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INAN')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='002'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='AN'	
		CP0->CP0_CONDIC:='GCP017ANL()'
		CP0->CP0_PROXIV:='PB'
		CP0->CP0_PROXIF:='ED'
		CP0->CP0_ETPANT:=''
		CP0->(msUnLock())
		
		//Etapa PB
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INPB')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='003'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='PB'	
		CP0->CP0_CONDIC:='GCP017ANL()'
		CP0->CP0_PROXIV:='HA'
		CP0->CP0_PROXIF:=''
		CP0->CP0_ETPANT:=''
		CP0->(msUnLock())
		
		//Etapa AE
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INAE')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='004'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='AE'	
		CP0->CP0_CONDIC:=''
		CP0->CP0_PROXIV:='HA'
		CP0->CP0_PROXIF:=''
		CP0->CP0_ETPANT:='PB'
		CP0->(msUnLock())
		
		//Etapa HA
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INHA')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='005'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='HA'	
		CP0->CP0_CONDIC:='GCP017Habi()'
		CP0->CP0_PROXIV:='JP'
		CP0->CP0_PROXIF:=''
		CP0->CP0_ETPANT:=''
		CP0->(msUnLock())
		
		//Etapa JP
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INJP')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='006'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='JP'	
		CP0->CP0_CONDIC:='GCP017Julg()'
		CP0->CP0_PROXIV:='HO'
		CP0->CP0_PROXIF:=''
		CP0->CP0_ETPANT:=''
		CP0->(msUnLock())
		
		//Etapa HO
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INHO')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='007'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='HO'	
		CP0->CP0_CONDIC:=''
		CP0->CP0_PROXIV:='AD'
		CP0->CP0_PROXIF:=''
		CP0->CP0_ETPANT:=''
		CP0->(msUnLock())
		
		//Etapa AD
		RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INAD')))
		CP0->CP0_FILIAL:=xFilial('CP0')
		CP0->CP0_ORDEM :='008'
		CP0->CP0_REGRA :=CO0->CO0_REGRA
		CP0->CP0_MODALI:='IN'
		CP0->CP0_ETAPA :='AD'	
		CP0->CP0_CONDIC:=''
		CP0->CP0_PROXIV:='FI'
		CP0->CP0_PROXIF:=''
		CP0->CP0_ETPANT:=''
		CP0->(msUnLock())
		
		//Etapa FI
		If CO0->CO0_LEI $ '1|6'
			RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INFI')))
			CP0->CP0_FILIAL:=xFilial('CP0')
			CP0->CP0_ORDEM :='009'
			CP0->CP0_REGRA :=CO0->CO0_REGRA
			CP0->CP0_MODALI:='IN'
			CP0->CP0_ETAPA :='FI'	
			CP0->CP0_CONDIC:=''
			CP0->CP0_PROXIV:=''
			CP0->CP0_PROXIF:=''
			CP0->CP0_ETPANT:=''
			CP0->(msUnLock())
		Else
			RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INRC')))
			CP0->CP0_FILIAL:=xFilial('CP0')
			CP0->CP0_ORDEM :='009'
			CP0->CP0_REGRA :=CO0->CO0_REGRA
			CP0->CP0_MODALI:='IN'
			CP0->CP0_ETAPA :='RC'	
			CP0->CP0_CONDIC:='GCP017Rec()'
			CP0->CP0_PROXIV:='ED'
			CP0->CP0_PROXIF:='FI'
			CP0->CP0_ETPANT:=''
			CP0->(msUnLock())
			
			RecLock("CP0",CP0->(! dbSeek(xFilial('CP0')+CO0->CO0_REGRA+'INFI')))
			CP0->CP0_FILIAL:=xFilial('CP0')
			CP0->CP0_ORDEM :='010'
			CP0->CP0_REGRA :=CO0->CO0_REGRA
			CP0->CP0_MODALI:='IN'
			CP0->CP0_ETAPA :='FI'	
			CP0->CP0_CONDIC:=''
			CP0->CP0_PROXIV:=''
			CP0->CP0_PROXIF:=''
			CP0->CP0_ETPANT:=''
			CP0->(msUnLock())
			
		EndIf
		
		If CO0->CO0_LEI == '2'
			//Etapa AT
			Reclock("CP0",CP0->(! dbSeek(xFilial("CP0")+CO0->CO0_REGRA+'CCAT')))
			CP0->CP0_FILIAL:=xFilial('CP0')
			CP0->CP0_ORDEM:='015'
			CP0->CP0_REGRA:= CO0->CO0_REGRA
			CP0->CP0_MODALI:='CC'
			CP0->CP0_ETAPA:='AT'
			CP0->CP0_CONDIC:=''
			CP0->CP0_PROXIV:='AA'
			CP0->CP0_PROXIF:=''
			CP0->CP0_ETPANT:=''
			CP0->(msUnLock())
			
			//Etapa AA
			Reclock("CP0",CP0->(! dbSeek(xFilial("CP0")+CO0->CO0_REGRA+'CCAA')))
			CP0->CP0_FILIAL:=xFilial('CP0')
			CP0->CP0_ORDEM:='016'
			CP0->CP0_REGRA:= CO0->CO0_REGRA
			CP0->CP0_MODALI:='CC'
			CP0->CP0_ETAPA:='AA'
			CP0->CP0_CONDIC:=''
			CP0->CP0_PROXIV:='FI'
			CP0->CP0_PROXIF:=''
			CP0->CP0_ETPANT:=''
			CP0->(msUnLock())
		EndIf
		
		AtuCP1()
		
	ElseIf CO0->CO0_LEI == '3'
		//Inclusão do tipo de modalidade maior oferta de preço para a modalidade pregão.
		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"PG"+"MO")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "PG"
			COZ->COZ_TIPO		:= "MO"
			COZ->COZ_DESCRI	:= STR0060
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtu := .T.
		EndIf

	ElseIf CO0->CO0_LEI == '5' //-- Lei 13.303
		//Inclusão dos novos tipos de modalidade para atender a Lei 13.303 Art 54
		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"MP")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "MP"
			COZ->COZ_DESCRI	:= STR0055
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.
		EndIf

		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"MD")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "MD"
			COZ->COZ_DESCRI	:= STR0056
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.
		EndIf

		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"TP")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "TP"
			COZ->COZ_DESCRI	:= STR0059
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.		
		EndIf

		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"MT")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "MT"
			COZ->COZ_DESCRI	:= STR0057
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.	
		EndIf

		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"CA")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "CA"
			COZ->COZ_DESCRI	:= STR0058
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.	
		EndIf

		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"MO")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "MO"
			COZ->COZ_DESCRI	:= STR0060
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.	
		EndIf

		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"ME")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "ME"
			COZ->COZ_DESCRI	:= STR0061
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.	
		EndIf

		If !(COZ->(dbSeek(xFilial("COZ")+CO0->CO0_REGRA+"DL"+"BA")))
			RecLock('COZ',.T.)
			COZ->COZ_FILIAL	:= xFilial("COZ")
			COZ->COZ_MODALI	:= "DL"
			COZ->COZ_TIPO	:= "BA"
			COZ->COZ_DESCRI	:= STR0062
			COZ->COZ_USADO	:= .T.
			COZ->COZ_REGRA	:= CO0->CO0_REGRA
			COZ->(MsUnlock())
			lAtuLei5 := .T.	
		EndIf

		//-- Incluir Modalidade Pregão (PG)
		If  !CP5->(DbSeek(xFilial("CP5")+CO0->CO0_REGRA+"PG")) .Or.;
			!COZ->(DbSeek(xFilial("COZ")+CO0->CO0_REGRA+"PG"+"MO")) .Or.;
			!COZ->(DbSeek(xFilial("COZ")+CO0->CO0_REGRA+"PG"+"MP"))
			lAtu := .T.
		EndIf
		
		If lAtu
			//-- Pregão -------------------------------------------------------
			CO0->(MsSeek(xFilial('CO0') + CO0->CO0_REGRA))
			oModel:= FWLoadModel("GCPA017")
			oModel:SetOperation(4) //-- 4-UPDATE
			If oModel:Activate()

				GCP017BMod(oModel, {'CP5DETAIL', 'CODDETAIL1', 'CODDETAIL2', 'CODDETAIL3', 'COZDETAIL'}, .F.)

				oRegra	   := oModel:GetModel('CO0MASTER')
				oModali	   := oModel:GetModel('CP5DETAIL')
				oTipo	   := oModel:GetModel('COZDETAIL')
				oEtapas	   := oModel:GetModel('CP0DETAIL')
				oCheckList := oModel:GetModel('CP1DETAIL')
				oModCOD1   := oModel:GetModel('CODDETAIL1')
				oModCOD2   := oModel:GetModel('CODDETAIL2')
				oModCOD3   := oModel:GetModel('CODDETAIL3')

				//-- Pregão -------------------------------------------------------
				oModali:Addline()
				oModali:LoadValue("CP5_ITEM", StrZero(oModali:GetLine(), TamSx3("CP5_ITEM")[1]))
				oModali:SetValue("CP5_MODALI", "PG")

				IncluiTipo(oTipo, "MP", STR0055)
				IncluiTipo(oTipo, "MO", STR0060)

				//-- Etapa Análise do Edital
				oEtapas:SetValue("CP0_ETAPA", "ED")
				oEtapas:LoadValue("CP0_CONDIC", "")
				oEtapas:SetValue("CP0_PROXIV", "AN")
				oEtapas:SetValue("CP0_PROXIF", "")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))
				oCheckList:SetValue("CP1_CHECK", "ELA")

				//-- Etapa Análise do Edital
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "AN")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017ANL()")
				oEtapas:SetValue("CP0_PROXIV", "PB")
				oEtapas:SetValue("CP0_PROXIF", "ED")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(),TamSx3("CP0_ORDEM")[1]))
				oCheckList:SetValue("CP1_CHECK", "ANA")

				//-- Etapa Publicação do Edital
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "PB")
				oEtapas:LoadValue("CP0_CONDIC", "")
				oEtapas:SetValue("CP0_PROXIV", "AE")
				oEtapas:SetValue("CP0_PROXIF", "")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))
				oCheckList:SetValue("CP1_CHECK", "PUB")

				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "AE")
				oEtapas:LoadValue("CP0_CONDIC", "")
				oEtapas:SetValue("CP0_PROXIV", "JP")
				oEtapas:SetValue("CP0_PROXIF", "")
				oEtapas:SetValue("CP0_ETPANT", "PB")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa de Julgamento das Propostas
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "JP")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017Julg()")
				oEtapas:SetValue("CP0_PROXIV", "HA")
				oEtapas:SetValue("CP0_PROXIF", "RC")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa de Habilitacao
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "HA")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017Habi()")
				oEtapas:SetValue("CP0_PROXIV", "HO")
				oEtapas:SetValue("CP0_PROXIF", "RC")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa de Homologação
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "HO")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017HOML()")
				oEtapas:SetValue("CP0_PROXIV", "AD")
				oEtapas:SetValue("CP0_PROXIF", "AT")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))
				oCheckList:SetValue("CP1_CHECK", "HOM")

				//-- Etapa de ComprasNet
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "CN")
				oEtapas:SetValue("CP0_PROXIV", "AD")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa de Adjudicação
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "AD")
				oEtapas:LoadValue("CP0_CONDIC", "")
				oEtapas:SetValue("CP0_PROXIV", "FI")
				oEtapas:SetValue("CP0_PROXIF", "")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))
				oCheckList:SetValue("CP1_CHECK", "ADJ")

				//-- Etapa Impugnação do Edital
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "IM")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017Impu()")
				oEtapas:SetValue("CP0_PROXIV", "ED")
				oEtapas:SetValue("CP0_PROXIF", "JP")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa de Recurso do Edital
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "RC")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017Rec()")
				oEtapas:SetValue("CP0_PROXIV", "ED")
				oEtapas:SetValue("CP0_PROXIF", "FI")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa Revogação do Edital
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "RV")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017Revog()")
				oEtapas:SetValue("CP0_PROXIV", "FI")
				oEtapas:SetValue("CP0_PROXIF", "PB")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa Anulação do Edital
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "AL")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017Anul()")
				oEtapas:SetValue("CP0_PROXIV", "FI")
				oEtapas:SetValue("CP0_PROXIF", "PB")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa Remanescente do Edital
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "RM")
				oEtapas:LoadValue("CP0_CONDIC", "GCP017Reman()")
				oEtapas:SetValue("CP0_PROXIV", "AD")
				oEtapas:SetValue("CP0_PROXIF", "FI")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa Ata de Registro de Preco
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "AT")
				oEtapas:LoadValue("CP0_CONDIC", "")
				oEtapas:SetValue("CP0_PROXIV", "AA")
				oEtapas:SetValue("CP0_PROXIF", "")
				oEtapas:LoadValue("CP0_MODALI", "CC")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//-- Etapa Assinatura da Ata de Registro de Preco
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "AA")
				oEtapas:LoadValue("CP0_CONDIC", "")
				oEtapas:SetValue("CP0_PROXIV", "FI")
				oEtapas:SetValue("CP0_PROXIF", "")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))
				oCheckList:SetValue("CP1_CHECK", "ASA")

				//-- Etapa Final
				oEtapas:Addline()
				oEtapas:SetValue("CP0_ETAPA", "FI")
				oEtapas:LoadValue("CP0_CONDIC", "")
				oEtapas:SetValue("CP0_PROXIV", "")
				oEtapas:SetValue("CP0_PROXIF", "")
				oEtapas:LoadValue("CP0_ORDEM", StrZero(oEtapas:GetLine(), TamSx3("CP0_ORDEM")[1]))

				//- Reposiciona modelos
				oModali:Goline(1)
				oTipo:Goline(1)
				oEtapas:Goline(1)

				//Obras e Serviço de Engenharia
				oModCOD1:AddLine()
				oModCOD1:LoadValue("COD_ESPECI", "1")
				oModCOD1:LoadValue("COD_ITEM", StrZero(oModCOD1:GetLine(), TamSx3("COD_ITEM")[1]))
				oModCOD1:SetValue("COD_MODALI", "PG")
				oModCOD1:LoadValue("COD_FXINI", 0.01)
				oModCOD1:LoadValue("COD_FXFIM", 9999999999999.99)
				oModCOD1:LoadValue("COD_FXEXC", 0)

				//Compras e demais serviços
				oModCOD2:AddLine()
				oModCOD2:LoadValue("COD_ESPECI", "2")
				oModCOD2:LoadValue("COD_ITEM", StrZero(oModCOD2:GetLine(), TamSx3("COD_ITEM")[1]))
				oModCOD2:SetValue("COD_MODALI", "PG")
				oModCOD2:LoadValue("COD_FXINI", 0.01)
				oModCOD2:LoadValue("COD_FXFIM", 9999999999999.99)
				oModCOD2:LoadValue("COD_FXEXC", 0)

				//Alienação de Bens
				oModCOD3:AddLine()
				oModCOD3:LoadValue("COD_ESPECI", "3")
				oModCOD3:LoadValue("COD_ITEM", StrZero(oModCOD3:GetLine(), TamSx3("COD_ITEM")[1]))
				oModCOD3:SetValue("COD_MODALI", "PG")
				oModCOD3:LoadValue("COD_FXINI", 0.01)
				oModCOD3:LoadValue("COD_FXFIM", 9999999999999.99)
				oModCOD3:LoadValue("COD_FXEXC", 0)

				If !oModel:VldData() .Or. !oModel:CommitData() //-- Se falhar a validação ou commit dos dados, aborta a operação
					Help(' ', 1,'A017ERRCAR')
					lAtu := .F.
					Exit
				EndIf
			
				GCP017BMod(oModel, {'CP5DETAIL', 'COZDETAIL', 'CPKDETAIL'}, .T.)
				
				If  IsRegrPadr(oRegra:GetValue('CO0_REGRA'))//Bloqueia os limites caso for regra exclusiva totvs ou lei diferente de RLC - sistema s
					GCP017BMod(oModel, {'CODDETAIL1', 'CODDETAIL2', 'CODDETAIL3'}, .T.)
				EndIf
			
				oModel:Deactivate()
			EndIf
		EndIf
	ElseIf CO0->CO0_LEI == '6'		
		CP5->(DbSetOrder(2))//CP5_FILIAL+CP5_REGRA+CP5_MODALI
		If !(CP5->(DbSeek(xFilial("CP5") + CO0->CO0_REGRA + "CR")))
			oModel:= FWLoadModel("GCPA017")
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			If oModel:Activate()
				GCP017BMod(oModel,{'CP5DETAIL','CODDETAIL1','CODDETAIL2','CODDETAIL3', 'COZDETAIL'},.F.)

				IncCredenc(oModel, TamSx3("CP0_ORDEM")[1]) //Inclui modalidade de credenciamento
				IIF((lAtu := (oModel:VldData() .And. oModel:CommitData())), .T., Help(' ', 1,'A017ERRCAR'))			
			EndIf
			oModel:DeActivate()
			FreeObj(oModel)
		EndIf
		
	EndIf
	
	CO0->(dbSkip())	
EndDo

CO0->(RestArea(aAreaCO0))
CP5->(RestArea(aAreaCP5))
COD->(RestArea(aAreaCOD))

dbSelectArea("CP1")
dbSetorder(1)
If dbSeek(xFilial("CP1")+"002")
	While(CP1_FILIAL+CP1_REGRA == xFilial("CP1")+"002")

		If Alltrim(CP1_CHECK) == "ELA"
			Reclock("CP1",.F.)
				CP1_CHECK := "EDS"
			MsUnlock()
			lAtu := .T.
		ElseIf Alltrim(CP1_CHECK) == "ANA"
			Reclock("CP1",.F.)
				CP1_CHECK := "ANS"
			MsUnlock()
			lAtu := .T.
		ElseIf Alltrim(CP1_CHECK) == "HOM"
			Reclock("CP1",.F.)
				CP1_CHECK := "HOS"
			MsUnlock()
			lAtu := .T.
		ElseIf Alltrim(CP1_CHECK) == "ADJ"
			Reclock("CP1",.F.)
				CP1_CHECK := "ADS"
			MsUnlock()
			lAtu := .T.
		EndIf

		dbSkip()
	End
EndIf

dbSelectArea("CO0")
CO0->(dbSetorder(1))
CO0->(dbGotop())
While CO0->(!EOF())
	If CO0->CO0_REGRA == "003"
		dbSelectArea("CP0")
		CP0->(dbSetOrder(1))
		CP0->(dbGoTop())
		If CP0->(DbSeek(xFilial("CP0")+CO0->CO0_REGRA))
			oModel := FWLoadModel("GCPA017")
			oModel:SetOperation(MODEL_OPERATION_UPDATE) //Altera o modelo para atualização.
			oModel:Activate()
			oModelCP0 := oModel:GetModel('CP0DETAIL')
			For nX := 1 To oModelCP0:Length()
				oModelCP0:GoLine(nX)
				If oModelCP0:GetValue('CP0_ETAPA') == "CN"
					Exit
				ElseIf oModelCP0:GetValue('CP0_ETAPA') == "FI"
					//-- Etapa de ComprasNet
					oModelCP0:Goline(oModelCP0:Length())
					oModelCP0:SetValue("CP0_ETAPA","CN")
					oModelCP0:SetValue("CP0_PROXIV","AD")
										
					//Nova Etapa FIM
					oModelCP0:Addline()
					oModelCP0:SetValue("CP0_ETAPA","FI")
					oModelCP0:LoadValue("CP0_CONDIC","")
					oModelCP0:SetValue("CP0_PROXIV","")
					oModelCP0:SetValue("CP0_PROXIF","")
					oModelCP0:LoadValue("CP0_ORDEM",StrZero(17, TamSx3("CP0_ORDEM")[1]))
					
					If oModel:Activate() 
						If oModel:VldData() 
							oModel:CommitData()
						EndIf
					EndIf
					lAtu := .T.
				EndIf
			Next nX
		EndIf	
	EndIF
	
	// Altera permissão para carona no estado de São Paulo
	dbSelectArea("CPK")
	dbSetOrder(1)
	
	If CPK->(dbSeek(xFilial("CPK")+CO0->CO0_REGRA+"SP")) .And. CPK->CPK_CARONA <> '1'
		RecLock('CPK',.F.)
		CPK->CPK_CARONA := '1'
		CPK->(MsUnLock())
		lAtu := .T.
	EndIf
	
	CO0->(dbSkip())
End

A017Artigos(@lAtu)

If lAtu .Or. lAtuLei5
	MsgInfo(STR0035,"GCPA017ATU")
ElseIf !lModLoad
	MsgInfo(STR0036,"GCPA017ATU")
EndIf

RestArea(aArea)
FWRestRows( aSaveLines )
Return

/*/{Protheus.doc} AtuCP1()
Função para atualizar as CheckLists
@author vitor.pires
@since 12/08/2015
@version P12
/*/
Static Function AtuCP1()

	If CO0->CO0_LEI $ '1|6'
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INEDELA')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='ED'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='ELA'
		CP1->(msUnLock())
		
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INANANA')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='AN'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='ANA'
		CP1->(msUnLock())
			
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INPBDIS')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='PB'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='DIS'
		CP1->(msUnLock())
			
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INHOHOM')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='HO'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='HOM'
		CP1->(msUnLock())
			
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INADADJ')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='AD'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='ADJ'
		CP1->(msUnLock())

	ElseIf CO0->CO0_LEI == '2'
			
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INEDEDS')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='ED'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='EDS'
		CP1->(msUnLock())
			
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INANANS')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='AN'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='ANS'
		CP1->(msUnLock())
		
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INHOHOS')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='HO'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='HOS'
		CP1->(msUnLock())
			
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INADADS')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='IN'
		CP1->CP1_ETAPA :='AD'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='ADS'
		CP1->(msUnLock())
			
		RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'CCAAASA')))
		CP1->CP1_FILIAL:=xFilial('CP1')
		CP1->CP1_REGRA :=CO0->CO0_REGRA
		CP1->CP1_MODALI:='CC'
		CP1->CP1_ETAPA :='AA'	
		CP1->CP1_USADO :=.T.
		CP1->CP1_CHECK :='ASA'
		CP1->(msUnLock())

	EndIf

	RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INPBPUB')))
	CP1->CP1_FILIAL:=xFilial('CP1')
	CP1->CP1_REGRA :=CO0->CO0_REGRA
	CP1->CP1_MODALI:='IN'
	CP1->CP1_ETAPA :='PB'	
	CP1->CP1_USADO :=.T.
	CP1->CP1_CHECK :='PUB'
	CP1->(msUnLock())

	RecLock("CP1",CP1->(! dbSeek(xFilial('CP1')+CO0->CO0_REGRA+'INJPJUL')))
	CP1->CP1_FILIAL:=xFilial('CP1')
	CP1->CP1_REGRA :=CO0->CO0_REGRA
	CP1->CP1_MODALI:='IN'
	CP1->CP1_ETAPA :='JP'	
	CP1->CP1_USADO :=.T.
	CP1->CP1_CHECK :='JUL'
	CP1->(msUnLock())

Return Nil

/*/{Protheus.doc} A017Artigos
Inclui/Atualiza Artigos
@param lAtu Logico, por referencia, não obrigatório. usada no controle de Atualização 
@author vitor.pires
@since 26/08/2016
@version 1.0
/*/
Function A017Artigos(lAtu)
	Local aAreaCP8 := CP8->(GetArea())
	Local aAreaCP9 := CP9->(GetArea())
	Local nTamParag := TAMSX3("CP9_PARAG")[1]
	Local nTamArt   := TAMSX3("CP9_ARTIGO")[1]
	Local cArtigo	:= ''
	Local cParagrafo:= ''
	Local aArts 	:= {{{'48','Dispensável de validação ME/EPP'},;
							{{'I','deverá realizar processo licitatório destinado exclusivamente à participação de microempresas e empresas de pequeno porte nos itens de contratação cujo valor seja de até R$ 80.000,00 (oitenta mil reais)'},;
							{'II','poderá, em relação aos processos licitatórios destinados à aquisição de obras e serviços, exigir dos licitantes a subcontratação de microempresa ou empresa de pequeno porte'},;
							{'III','deverá estabelecer, em certames para aquisição de bens de natureza divisível, cota de até 25% (vinte e cinco por cento) do objeto para a contratação de microempresas e empresas de pequeno porte.'}}},;
						{{'49','Não se aplica os arts. 47 e 48 desta Lei Complementar quando'},;
							{{'II','não houver um mínimo de 3 (três) fornecedores competitivos enquadrados como microempresas ou empresas de pequeno porte sediados local ou regionalmente e capazes de cumprir as exigências estabelecidas no instrumento convocatório;'},;
							{'III','o tratamento diferenciado e simplificado para as microempresas e empresas de pequeno porte não for vantajoso para a administração pública ou representar prejuízo ao conjunto ou complexo do objeto a ser contratado;'}}}}
	Local nI		:= 0 
	Local nZ		:= 0 
	Local nCount	:= 0
	Local nLei		:= 0
	Local cLeiCompl	:= "123/2006" //Lei Complementar que trata a dispensa de validação de ME/EPP
	Local nLeis		:= GCP017Leis(1)
	Local lCp8LC	:= CP8->(FieldPos("CP8_LC")) > 0
	CP8->(DbSetOrder(1))
	//Grava artigos da lei 123/2006 - Microempresas
	For nLei := 1 to nLeis

		cLei := Str(nLei,1)
		
		If (cLei == '2')
			Loop
		EndIf	
		
		For nI := 1 to Len(aArts)
			cArtigo := Padr(aArts[nI,1,1],nTamArt) 
			If	CP8->( ! DbSeek(xFilial("CP8")+cLei+cArtigo) )
				//-- Cabeçalho
				RecLock("CP8",.T.)
				CP8->CP8_FILIAL:=xFilial("CP8")
				CP8->CP8_LEI:=cLei
				CP8->CP8_ARTIGO:=cArtigo
				CP8->CP8_DESART:=aArts[nI,1,2]
				If lCp8LC .And. (Alltrim(cArtigo) == '48' .Or. Alltrim(cArtigo) == '49')
					CP8->CP8_LC := cLeiCompl
				EndIf
				MsUnLock()
				nCount++
			ElseIf lCp8LC .And. (Alltrim(cArtigo) == '48' .Or. Alltrim(cArtigo) == '49')
				If Empty(CP8->CP8_LC)
					RecLock("CP8",.F.)
					CP8->CP8_LC := cLeiCompl
					MsUnLock()
				EndIf
			EndIf
				
			For nZ := 1 To Len(aArts[nI,2])	
				cParagrafo:=Padr(aArts[nI,2,nZ,1],nTamParag)
				If CP9->(! dbSeek(xFilial("CP9")+cLei+cArtigo+cParagrafo))
					RecLock("CP9",.T.)
					CP9->CP9_FILIAL:=xFilial("CP9")
					CP9->CP9_LEI:=cLei
					CP9->CP9_ARTIGO:=cArtigo
					CP9->CP9_PARAG:=cParagrafo 
					CP9->CP9_DESPAR:=aArts[nI,2,nZ,2]
					MsUnLock()
					nCount++
				EndIf
			Next nZ	
		Next nI
	Next nLei

	CP8->(RestArea(aAreaCP8))
	CP9->(RestArea(aAreaCP9))
	lAtu:= lAtu .Or. (nCount>0)

	FwFreeArray(aArts)
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPATtLei()
Função para verificar quantidade de leis cadastradas disponibilziadas pela Totvs
@author israel.escorizza
@since 11/09/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GCPATtLei()
	Local aAreaCO0 	:= CO0->(GetArea())
	Local cAliasCO0	:= GetNextAlias()
	Local nTotLei	:= GCP017Leis(1)
	Local aRet		:= {.F.,0}

	BeginSQL Alias cAliasCO0
		SELECT COUNT(*) REGS
		FROM %Table:CO0%
		WHERE
		CO0_FILIAL = %xFilial:CO0% AND
		CO0_REGRA < %EXP:StrZero(20,TAMSX3('CO0_REGRA')[1])% AND
		%NotDel%
	EndSql

	If (aRet[2] := nTotLei - (cAliasCO0)->(REGS)) > 0
		aRet[1] := .T.
	EndIf

	(cAliasCO0)->(dbCloseArea())

	CO0->(RestArea(aAreaCO0))
Return aRet

/*/{Protheus.doc} GCP017Neg()
Função de validação da negociação
@author israel.escorizza
@since 13/09/2017
@version P12
/*/
Function GCP017Neg(lValid)
	Local aSaveLines	:= FWSaveRows()
	Local aArea			:= GetArea()
	Local oModel 		:= FWModelActive()
	Local oModelCO3		:= oModel:GetModel('CO3DETAIL')
	Local oModelItm		:= Nil
	Local lRet 			:= .T.
	Local lRevog		:= .F.
	Local lItem			:= oModel:GetValue('CO1MASTER','CO1_AVAL') == '1' //- Verifica Edital por Item
	Local nValOrc		:= oModel:GetValue('CO1MASTER','CO1_VLLL')
	Local nValVenc		:= 0
	Local nQuant		:= 0
	Local nX			:= 1
	Local nY			:= 0
	Local cMsg			:= ""
	Local cLei			:= oModel:GetValue( "CO1MASTER", "CO1_LEI" )

	Default lValid 		:= .F.

	If cLei == "5" //Aplica a regra de somatória das propostas ser superior ao valor orçado, apenas para a lei "5" (13.303) 

		If lItem //- Verifica Edital por Item ou Lote
			oModelItm := oModel:GetModel('CO2DETAIL')
		Else
			oModelItm := oModel:GetModel('CP3DETAIL')
		EndIf
		
		While !lRevog .And. nX <= oModelItm:Length()
			oModelItm:GoLine(nX)
			nQuant := Iif( lItem, oModelItm:GetValue('CO2_QUANT'), 1 )
			
			For nY := 1 To oModelCO3:Length()
				oModelCO3:GoLine( nY )
				If oModelCO3:GetValue('CO3_STATUS') == "5" //Se for licitante vencedor, soma o valor das propostas
					nValVenc += ( oModelCO3:GetValue('CO3_VLRPRE') * nQuant )
				EndIf
			Next nY
					
			lRevog := nValVenc > nValOrc
			nX++
		EndDo
		
		If lValid
			If !IsBlind()
				If lRevog
					//- Msg Revogação
					cMsg += "A somatoria das propostas vencedoras é superior ao valor orçado para este processo licitatório."+CRLF+CRLF
					cMsg += "De acordo com a Lei 13.303 Art. 57 §3º - Caso não for obtido valor igual ou inferior ao orçamento estimado para a contratação, será revogada a licitação."+CRLF+CRLF
					cMsg += "Deseja prosseguir com a revogação da licitação ?"
		
					lRet := MsgYesNo(cMsg,"ATENÇÃO")
					
					If !lRet
						Help("",1,"GCPA017NEG")
					Else
						oModel:GetModel("CO1MASTER"):LoadValue("CO1_STATUS", "A")
					EndIf
				EndIf
			Else
				lRet := !lRevog
			EndIf
		Else
			lRet := !lRevog
		EndIf

		RestArea(aArea)
		FwFreeArray(aArea)
		FWRestRows( aSaveLines )
		FwFreeArray(aSaveLines)
	EndIf

Return lRet

//-Funções para manter compatibilidade com versões anteriores da condição. -------------------------------
/*/{Protheus.doc} GCP017ANL/*/
Function GCP017ANL()
Return GCP017PPET()
/*/{Protheus.doc} GCP017HABI/*/
Function GCP017HABI()
Return GCP017PPET()
/*/{Protheus.doc} GCP017IMPU/*/
Function GCP017IMPU()
Return GCP017PPET()
/*/{Protheus.doc} GCP017JULG/*/
Function GCP017JULG()
Return GCP017PPET()
/*/{Protheus.doc} GCP017QUES/*/
Function GCP017QUES()
Return GCP017PPET()
/*/{Protheus.doc} GCP017REC/*/
Function GCP017REC()
Return GCP017PPET()
/*/{Protheus.doc} GCP017REVOG/*/
Function GCP017REVOG()
Return GCP017PPET()
/*/{Protheus.doc} GCP017ANUL/*/
Function GCP017ANUL()
Return GCP017PPET()
/*/{Protheus.doc} GCP017Prep/*/
Function GCP017Prep()
Return GCP017PPET()

/*/{Protheus.doc} A017VldUso
Validação da linha das etapas

@author Ronaldo.Robes
@param oModel
@since 14/08/2018
@version 1.0
@return lRet
/*/
Function A017VldUso(oModel)
	Local lRet := .T.
	Local oModelCO0 := oModel:GetModel("CO0MASTER")
	Local cAliasSql := GetNextAlias()

	BeginSQL Alias cAliasSql

		Select CO1_REGRA
			From  %Table:CO1%  CO1
		Where
			CO1.CO1_REGRA = %exp:oModelCO0:GetValue('CO0_REGRA')%
			And CO1.%NotDel%

	EndSql

	If !(cAliasSql)->(Eof())
		lRet:= .F.
	EndIF
	(cAliasSql)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} GCP017Leis
	Centraliza informações sobre as Leis padrão do sistema
@author philipe.pompeu
@since 10/03/2022
@param nTipo, numerico, informação desejada
@return xResult, indefinido, resultado variável de acordo com <nTipo>
*/
Function GCP017Leis(nTipo)
	Local nX		:= 0
	Local xResult 	:= Nil
	Local aLeis		:= {}
	Default nTipo 	:= 1
	
	aLeis := {	{'NORMAS GERAIS PARA LICITACOES E CONTRATOS 8.666/93'	, '8.666'	},;
				{'REGULAMENTO DE LICITACOES E CONTRATOS "SISTEMA S"'	, 'RLC'		},;
				{'NORMAS GERAIS PARA PREGÃO 10.520/02'					, '10.520'	},;
				{'REGIME DIFERENCIADO DE CONTRATAÇÕES'					, 'RDC'		},;
				{'DISP. APLI. EMP. PÚBLICAS E SOC. DE ECONOMIA MISTA'	, '13.303'	},;
				{'LEI DE LICITAÇÕES 14.133/21'							, '14.133'	}}

	Do Case
		Case (nTipo == 1)//Retorna quantidade de leis
			xResult := Len(aLeis)
		Case (nTipo == 2)//Retorna as descrições das leis
			xResult := {}
			aEval(aLeis, {|x|  aAdd(xResult, x[1]) })
		Case (nTipo == 3)//Retorna possíveis valores para campos XXX_LEI(MODEL_FIELD_VALUES)
			xResult := {}
			for nX := 1 to Len(aLeis)
				aAdd(xResult, cValToChar(nX))
			next nX
		Case (nTipo == 4)//Retorna os possíveis valores para view dos campos XXX_LEI(COMBOVALUES)
			xResult := {}
			for nX := 1 to Len(aLeis)				
				aAdd(xResult, cValToChar(nX) +'='+ aLeis[nX,2])
			next nX
		Case (nTipo == 5)//Retorna possíveis valores para campos XXX_LEI(Pertence)
			xResult := ""
			for nX := 1 to Len(aLeis)
				xResult += cValToChar(nX)				
			next nX
	EndCase

	FwFreeArray(aLeis)
Return xResult

/*/{Protheus.doc} IncluiLei
	Insere/Atualiza a lei informada na tabela CO0
@author philipe.pompeu
@since 10/03/2022
@param nLei, numerico, numero da lei
@param cDescricao, caractere, descrição da lei
@return Nil, Nulo
*/
Static Function IncluiLei(nLei, cDescricao)
	Local aArea	:= CO0->(GetArea())
	Local lFind	:= .F.
	Local cRegra:= ""

	cRegra := StrZero(nLei, 3)
	
	CO0->(DbSetOrder(1))

	lFind := CO0-> (DbSeek(xFilial("CO0") + cRegra) )
		
	RecLock("CO0",If(lFind,.F.,.T.))
	CO0->CO0_FILIAL	:= xFilial("CO0")
	CO0->CO0_REGRA 	:= cRegra
	CO0->CO0_DSCRGR	:= cDescricao
	CO0->CO0_LEI	:= cValToChar(nLei)
	MsUnlock()

	RestArea(aArea)
	FwFreeArray(aArea)
Return

/*/{Protheus.doc} IncDispLicit
	Inclui a modalidade Dispensa de Licitação
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@param nTamOrdem, numerico, tamanho do campo CP0_ORDEM
@return Nil, Nulo
*/
Static Function IncDispLicit(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')

	If !Empty(oModali:GetValue('CP5_MODALI'))		
		oModali:Addline()
	EndIf
	
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","DL")

	IncluiTipo(oTipo, "DE", STR0063)
	IncluiTipo(oTipo, "DR", STR0064)
	IncluiTipo(oTipo, "DV", STR0065)
	IncluiTipo(oTipo, "MT", STR0057)
	IncluiTipo(oTipo, "TP", STR0059)
	IncluiTipo(oTipo, "MP", STR0055)
	IncluiTipo(oTipo, "MO", STR0060)
	IncluiTipo(oTipo, "MD", STR0056)

	//-- Etapa Inicial
	oEtapas:SetValue("CP0_ETAPA","ED")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AN")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ELA")

	//-- Etapa Análise do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AN")
	//oEtapas:LoadValue("CP0_DESCTP","Análise do Edital")
	oEtapas:LoadValue("CP0_CONDIC","GCP017ANL()")
	oEtapas:SetValue("CP0_PROXIV","PB")
	oEtapas:SetValue("CP0_PROXIF","ED")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ANA")

	//-- Etapa Publicação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","PB")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","PUB")

	// Check lists para os caso exclusivo de dispensa.
	oCheckList:Addline()
	oCheckList:SetValue("CP1_CHECK","DIS")

	//-- Etapa de Abertura de Envelopes
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AE")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV",IIF((cLei == '6'), 'JP', 'HA'))
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	If (cLei == '6')//Na lei 14133, há uma inversão das fases do processo licitatório(Julgamento vindo antes da Habilitação)
		//-- Etapa de Julgamento das Propostas
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","JP")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
		oEtapas:SetValue("CP0_PROXIV","HA")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK","JUL")
		
		//-- Etapa de Habilitacao
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","HA")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
		oEtapas:SetValue("CP0_PROXIV","HO")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	Else
		//-- Etapa de Habilitacao
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","HA")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
		oEtapas:SetValue("CP0_PROXIV","JP")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

		//-- Etapa de Julgamento das Propostas
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","JP")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
		oEtapas:SetValue("CP0_PROXIV","HO")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK","JUL")
	EndIf

	//-- Etapa de Homologação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","HOM")

	//-- Etapa de Adjudicação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ADJ")

	//-- Etapa Final
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncLeilao
	Inclui a modalidade Leilão
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@param nTamOrdem, numerico, tamanho do campo CP0_ORDEM
@return Nil, Nulo
*/
Static Function IncLeilao(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')
	Local cCheckList:= ""

	If !Empty(oModali:GetValue('CP5_MODALI'))
		oModali:Addline()
	EndIf
	
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","LL")

	IncluiTipo(oTipo, "VZ", STR0067)
	IncluiTipo(oTipo, "MO", STR0060)
	
	If (cLei != '2')		
		IncluiTipo(oTipo, "TP", STR0059)
		IncluiTipo(oTipo, "MP", STR0055)
		IncluiTipo(oTipo, "MT", STR0057)
		IncluiTipo(oTipo, "MD", STR0056)
	EndIf

	//-- Etapa Inicio do Edital
	oEtapas:SetValue("CP0_ETAPA","ED")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AN")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "EDS", "ELA")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Análise do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AN")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","PB")
	oEtapas:SetValue("CP0_PROXIF","ED")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "ANS", "ANA")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Publicação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","PB")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","AN")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","PUB")

	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AE")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","JP")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Julgamento das Propostas
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","JP")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
	oEtapas:SetValue("CP0_PROXIV",IIF((cLei == "6"), "HO", "HA"))//Lei 14.133, Art. 31, paragrafo 4º, o leilão não terá fase de habilitação
	oEtapas:SetValue("CP0_PROXIF","RC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	If (cLei != "6")//Lei 14.133, Art. 31, paragrafo 4º, o leilão não terá fase de habilitação
		//-- Etapa de Habilitacao
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","HA")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
		oEtapas:SetValue("CP0_PROXIV","HO")
		oEtapas:SetValue("CP0_PROXIF","RC")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	EndIf

	//-- Etapa de Homologação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "HOS", "HOM")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa de Adjudicação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "ADS", "ADJ")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Impugnação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","IM")	
	oEtapas:LoadValue("CP0_CONDIC"	,"GCP017Impu()")
	oEtapas:SetValue("CP0_PROXIV"	,"ED")
	oEtapas:SetValue("CP0_PROXIF"	,IIF((cLei == "6"), "", "HA"))
	oEtapas:LoadValue("CP0_ORDEM"	,StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Recurso do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RC")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Rec()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Revogação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RV")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Revog()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Anulação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AL")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Anul()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Remanescente do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Reman()")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Final
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncInexig
	Inclui a modalidade Inexigibilidade
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@param nTamOrdem, numerico, tamanho do campo CP0_ORDEM
@return Nil, Nulo
*/
Static Function IncInexig(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')
	Local cCheckList:= ""
	Local cProxFalso:= ""

	If !Empty(oModali:GetValue('CP5_MODALI'))		
		oModali:Addline()
	EndIf

	//-- Inexigibilidade
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","IN")

	IncluiTipo(oTipo, "VZ", STR0067)

	//-- Etapa Inicial
	oEtapas:SetValue("CP0_ETAPA","ED")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AN")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	
	cCheckList := IIF((cLei == '2'), "EDS", "ELA")
	oCheckList:SetValue("CP1_CHECK",cCheckList)

	//-- Etapa Análise do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AN")
	oEtapas:LoadValue("CP0_CONDIC","GCP017ANL()")
	oEtapas:SetValue("CP0_PROXIV","PB")
	oEtapas:SetValue("CP0_PROXIF","ED")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "ANS", "ANA")
	oCheckList:SetValue("CP1_CHECK",cCheckList)

	//-- Etapa Publicação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","PB")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","PUB")

	If (cLei != '2')	
		oCheckList:Addline()
		oCheckList:SetValue("CP1_CHECK","DIS")
	EndIf

	//-- Etapa de Abertura de Envelopes
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AE")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","HA")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Habilitacao
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HA")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
	oEtapas:SetValue("CP0_PROXIV","JP")

	cProxFalso := IIF((cLei == '2'), "RC", "")
	oEtapas:SetValue("CP0_PROXIF", cProxFalso)

	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Julgamento das Propostas
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","JP")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
	oEtapas:SetValue("CP0_PROXIV","HO")

	cProxFalso := IIF((cLei == '2'), "RC", "")
	oEtapas:SetValue("CP0_PROXIF", cProxFalso)

	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","JUL")

	//-- Etapa de Homologação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "HOS", "HOM")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa de Adjudicação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "ADS", "ADJ")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	If (cLei == '2')//Se Lei 2, antes da etapa final deve-se incluir etapa Recurso do Edital
		//-- Etapa de Recurso do Edital
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","RC")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Rec()")
		oEtapas:SetValue("CP0_PROXIV","ED")
		oEtapas:SetValue("CP0_PROXIF","FI")
		oEtapas:LoadValue("CP0_MODALI","CC")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	EndIf

	//-- Etapa Final
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncConvite
	Inclui a modalidade Convite
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@return Nil, Nulo
*/
Static Function IncConvite(oModel as Object)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')

	If !Empty(oModali:GetValue('CP5_MODALI'))		
		oModali:Addline()	
	EndIf

	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","CV")

	oTipo:LoadValue("COZ_TIPO","TP")
	oTipo:LoadValue("COZ_DESCRI",STR0059)
	oTipo:LoadValue("COZ_USADO",.T.)

	IncluiTipo(oTipo, "MP", STR0055)
	IncluiTipo(oTipo, "MO", STR0060)
	IncluiTipo(oTipo, "VZ", STR0067)

	If (cLei != "2")
		IncluiTipo(oTipo, "MT", STR0057)
		IncluiTipo(oTipo, "MD", STR0056)
	EndIf

	InEtpComum(oEtapas, oCheckList, cLei) //Inclui Etapas Comuns
Return

/*/{Protheus.doc} IncTomadPr
	Inclui a modalidade Tomada de Preço
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@return Nil, Nulo
*/
Static Function IncTomadPr(oModel as Object)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')

	oModali:Addline()
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","TP")

	IncluiTipo(oTipo, "MT", STR0057)
	IncluiTipo(oTipo, "TP", STR0059)
	IncluiTipo(oTipo, "MP", STR0055)
	IncluiTipo(oTipo, "MO", STR0060)
	IncluiTipo(oTipo, "VZ", STR0067)
	IncluiTipo(oTipo, "MD", STR0056)
	
	InEtpComum(oEtapas, oCheckList, cLei) //Inclui Etapas Comuns
Return

/*/{Protheus.doc} IncConcorr
	Inclui a modalidade Concorrência
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@return Nil, Nulo
*/
Static Function IncConcorr(oModel as Object)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')

	If !Empty(oModali:GetValue('CP5_MODALI'))
		oModali:Addline()
	EndIf

	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","CC")
	IF CP5->(Columnpos ("CP5_QTDDIA"))> 0 	
		oModali:LoadValue("CP5_QTDDIA",0)
		oModali:LoadValue("CP5_DUTEIS",'2')
	endIF   
	IncluiTipo(oTipo, "MT", STR0057)
	IncluiTipo(oTipo, "TP", STR0059)
	IncluiTipo(oTipo, "MP", STR0055)
	IncluiTipo(oTipo, "MO", STR0060)
	IncluiTipo(oTipo, "VZ", STR0067)
	IncluiTipo(oTipo, "MD", STR0056)

	InEtpComum(oEtapas, oCheckList, cLei) //Inclui Etapas Comuns
Return

/*/{Protheus.doc} IncConcurs
	Inclui a modalidade Concurso
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@return Nil, Nulo
*/
Static Function IncConcurs(oModel as Object)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')

	If !Empty(oModali:GetValue('CP5_MODALI'))
		oModali:Addline()
	EndIf
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","CS")

	IncluiTipo(oTipo, "VZ", STR0067)

	If (cLei == '2')
		IncluiTipo(oTipo, "MT", STR0057)
	EndIf

	InEtpComum(oEtapas, oCheckList, cLei) //Inclui Etapas Comuns
Return

/*/{Protheus.doc} InEtpComum
	Inclui as etapas que são comuns as modalides Convite/Tomada de Preço/Concorrencia/Concurso/Dialogo Competitivo
@author philipe.pompeu
@since 10/03/2022
@param oEtapas, objeto, instancia de FwFormGridModel(CP0DETAIL)
@param oCheckList, objeto, instancia de FwFormGridModel(CP1DETAIL)
@param cLei, caractere, lei sendo processada
@param lCC, logico, se é concorrencia
@return Nil, Nulo
*/
Static Function InEtpComum(oEtapas as Object, oCheckList as Object, cLei)
	Local oModel	:= oEtapas:GetModel()	
	Local cModalidad:= oModel:GetValue('CP5DETAIL', 'CP5_MODALI')
	Local nTamOrdem	:= TamSx3("CP0_ORDEM")[1]
	Local lCC 		:= (cModalidad == 'CC')
	Local cCheckList:= ""
	Local cProxFalso:= ""

	//-- Etapa Inicio do Edital
	oEtapas:SetValue("CP0_ETAPA","ED")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AN")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))	
	cCheckList := IIF((cLei == '2'), "EDS", "ELA")//Checklist distinto p/ o sistema S(lei 2)
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Análise do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AN")
	oEtapas:LoadValue("CP0_CONDIC","GCP017ANL()")
	oEtapas:SetValue("CP0_PROXIV","PB")
	oEtapas:SetValue("CP0_PROXIF","ED")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '2'), "ANS", "ANA")//Checklist distinto p/ o sistema S(lei 2)
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Publicação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","PB")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","PUB")

	//-- Etapa de Abertura de Envelopes
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AE")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV",IIF((cLei == '6'), 'JP', 'HA'))
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	If (cLei == '6')//Na lei 14133, há uma inversão das fases do processo licitatório(Julgamento vindo antes da Habilitação)
		//-- Etapa de Julgamento das Propostas
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","JP")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
		oEtapas:SetValue("CP0_PROXIV","HA")
		oEtapas:SetValue("CP0_PROXIF","RC")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK","JUL")

		//-- Etapa de Habilitacao
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","HA")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
		oEtapas:SetValue("CP0_PROXIV","HO")
		oEtapas:SetValue("CP0_PROXIF","RC")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	Else
		//-- Etapa de Habilitacao
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","HA")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
		oEtapas:SetValue("CP0_PROXIV","JP")
		oEtapas:SetValue("CP0_PROXIF","RC")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

		//-- Etapa de Julgamento das Propostas
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","JP")
		oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
		oEtapas:SetValue("CP0_PROXIV","HO")
		oEtapas:SetValue("CP0_PROXIF","RC")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK","JUL")
	EndIf
	
	//-- Etapa de Homologação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	cCheckList := IIF((cLei == '2'), "HOS", "HOM")//Checklist distinto p/ o sistema S(lei 2)
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa de Adjudicação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	cCheckList := IIF((cLei == '2'), "ADS", "ADJ")//Checklist distinto p/ o sistema S(lei 2)
	oCheckList:SetValue("CP1_CHECK", cCheckList)	
	
	//-- Etapa Impugnação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","IM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Impu()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	cProxFalso := IIF((cLei == '2'), "JP", "HA")//Prox Falso distinto p/ o sistema S(lei 2)
	oEtapas:SetValue("CP0_PROXIF",cProxFalso)
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Recurso do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RC")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Rec()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Revogação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RV")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Revog()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Anulação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AL")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Anul()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Remanescente do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Reman()")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	If	(lCC .Or. cLei == '2')//Concorrencia ou sistema S(lei 2)
		//-- Etapa Ata de Registro de Preco
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","AT")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","AA")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

		//-- Etapa Assinatura da Ata de Registro de Preco
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","AA")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","FI")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK","ASA")
	EndIf
	//-- Etapa Final
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")	
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncDlgCompt
	Inclui a modalidade Dialogo Competitivo
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@return Nil, Nulo
*/
Static Function IncDlgCompt(oModel as Object)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')
	Local cCodModal	:= "DC"

	If ExistCpo("SX5","LF" + cCodModal)
		If !Empty(oModali:GetValue('CP5_MODALI'))		
			oModali:Addline()
		EndIf
		oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
		oModali:SetValue("CP5_MODALI",cCodModal)

		IncluiTipo(oTipo, "VZ", STR0067)

		InEtpComum(oEtapas, oCheckList, cLei)
	EndIf
Return

/*/{Protheus.doc} IncPregao
	Inclui a modalidade Pregão
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@param nTamOrdem, numerico, tamanho do campo CP0_ORDEM
@return Nil, Nulo
*/
Static Function IncPregao(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cLei		:= oModel:GetValue('CO0MASTER','CO0_LEI')
	Local cCheckList:= ""
	
	If !Empty(oModali:GetValue('CP5_MODALI'))
		oModali:Addline()		
	EndIf
	//PREGAO
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","PG")

	IncluiTipo(oTipo, "MP", STR0055)

	If cLei == "3"
		IncluiTipo(oTipo, "MO", STR0060)
	EndIf

	//-- Etapa Análise do Edital
	oEtapas:SetValue("CP0_ETAPA","ED")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AN")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '3'), "ELA", "EDS")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Análise do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AN")
	oEtapas:LoadValue("CP0_CONDIC","GCP017ANL()")
	oEtapas:SetValue("CP0_PROXIV","PB")
	oEtapas:SetValue("CP0_PROXIF","ED")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '3'), "ANA", "ANS")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Publicação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","PB")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","PUB")

	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AE")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","JP")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Julgamento das Propostas
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","JP")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
	oEtapas:SetValue("CP0_PROXIV","HA")
	oEtapas:SetValue("CP0_PROXIF","RC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Habilitacao
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HA")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
	oEtapas:SetValue("CP0_PROXIV","HO")
	oEtapas:SetValue("CP0_PROXIF","RC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Homologação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","GCP017HOML()")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","AT")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '3'), "HOM", "HOS")
	oCheckList:SetValue("CP1_CHECK",cCheckList)

	If (cLei == '3')
		//-- Etapa de ComprasNet
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","CN")
		oEtapas:SetValue("CP0_PROXIV","AD")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	EndIf

	//-- Etapa de Adjudicação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	cCheckList := IIF((cLei == '3'), "ADJ", "ADS")
	oCheckList:SetValue("CP1_CHECK", cCheckList)

	//-- Etapa Impugnação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","IM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Impu()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	oEtapas:SetValue("CP0_PROXIF","JP")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Recurso do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RC")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Rec()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Revogação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RV")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Revog()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Anulação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AL")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Anul()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Remanescente do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Reman()")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Ata de Registro de Preco
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AT")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AA")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_MODALI","CC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Assinatura da Ata de Registro de Preco
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AA")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ASA")

	//-- Etapa Final
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncModal5
	Inclui a modalidade do tipo 5(dispensa licitacao)
@author philipe.pompeu
@since 10/03/2022
@param oModel, objeto, instancia de MPFormModel
@param nTamOrdem, numerico, tamanho do campo CP0_ORDEM
@return Nil, Nulo
*/
Static Function IncModal5(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')

	If !Empty(oModali:GetValue('CP5_MODALI'))		
		oModali:Addline()	
	EndIf
	// Modalidade 5
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","DL")

	IncluiTipo(oTipo, "DE", STR0063)
	IncluiTipo(oTipo, "DR", STR0064)
	IncluiTipo(oTipo, "DV", STR0065)

	//-- Etapa Inicial
	oEtapas:SetValue("CP0_ETAPA","ED")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AN")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","EDS")

	//-- Etapa Análise do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AN")
	oEtapas:LoadValue("CP0_CONDIC","GCP017ANL()")
	oEtapas:SetValue("CP0_PROXIV","PB")
	oEtapas:SetValue("CP0_PROXIF","ED")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ANS")

	//-- Etapa Publicação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","PB")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","PUB")

	//-- Etapa de Abertura de Envelopes
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AE")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","HA")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Habilitacao
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HA")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
	oEtapas:SetValue("CP0_PROXIV","JP")
	oEtapas:SetValue("CP0_PROXIF","RC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Julgamento das Propostas
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","JP")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
	oEtapas:SetValue("CP0_PROXIV","HO")
	oEtapas:SetValue("CP0_PROXIF","RC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","JUL")

	//-- Etapa de Homologação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","HOS")

	//-- Etapa de Adjudicação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ADS")

	//-- Etapa de Recurso do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RC")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Rec()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_MODALI","CC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Final
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncRegDifC
	Inclui a modalidade Regime Diferenciado de Contratação
@author philipe.pompeu
@since 11/03/2022
@param oModel, objeto, instancia de MPFormModel
@param nTamOrdem, numerico, tamanho do campo CP0_ORDEM
@return Nil, Nulo
*/
Static Function IncRegDifC(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","RD")

	IncluiTipo(oTipo, "MO", STR0060)
	IncluiTipo(oTipo, "MR", STR0061)
	IncluiTipo(oTipo, "TP", STR0059)
	IncluiTipo(oTipo, "MP", STR0055)
	IncluiTipo(oTipo, "MT", STR0057)
	IncluiTipo(oTipo, "MD", STR0056)

	//-- Etapa Elaboração do Edital
	oEtapas:SetValue("CP0_ETAPA","ED")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AN")
	oEtapas:SetValue("CP0_PROXIF","")
	oCheckList:SetValue("CP1_CHECK","RDE")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Análise do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AN")
	oEtapas:LoadValue("CP0_CONDIC","GCP017ANL()")
	oEtapas:SetValue("CP0_PROXIV","PB")
	oEtapas:SetValue("CP0_PROXIF","ED")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK"," ")

	//-- Etapa Publicação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","PB")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK"," ")

	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AE")
	oEtapas:LoadValue("CP0_CONDIC","GCP017JUL3()")
	oEtapas:SetValue("CP0_PROXIV","J3")
	oEtapas:SetValue("CP0_PROXIF","JP")
	oEtapas:SetValue("CP0_ETPANT","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Julgamento das Propostas - Modo de disputa combinado
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","J3")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","JP")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","RDJ")

	//-- Etapa de Julgamento das Propostas
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","JP")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Julg()")
	oEtapas:SetValue("CP0_PROXIV","HA")
	oEtapas:SetValue("CP0_PROXIF","RC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","RDJ")

	//-- Etapa de Habilitacao
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HA")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Habi()")
	oEtapas:SetValue("CP0_PROXIV","HO")
	oEtapas:SetValue("CP0_PROXIF","RC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","RDH")

	//-- Etapa de Homologação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","GCP017HOML()")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","AT")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK"," ")

	//-- Etapa de Adjudicação
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK"," ")

	//-- Etapa Impugnação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","IM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Impu()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	oEtapas:SetValue("CP0_PROXIF","JP")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa de Recurso do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RC")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Rec()")
	oEtapas:SetValue("CP0_PROXIV","ED")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Revogação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RV")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Revog()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Anulação do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AL")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Anul()")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","PB")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Remanescente do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Reman()")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Ata de Registro de Preco
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AT")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AA")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_MODALI","CC")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Assinatura da Ata de Registro de Preco
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AA")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ASA")

	//-- Etapa Final
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncProcLic
	Inclui a modalidade Procedimentos Licitatórios
@author philipe.pompeu
@since 11/03/2022
@param oModel, objeto, instancia de MPFormModel
@param nTamOrdem, numerico, tamanho do campo CP0_ORDEM
@return Nil, Nulo
*/
Static Function IncProcLic(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	
	oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
	oModali:SetValue("CP5_MODALI","PL")

	IncluiTipo(oTipo, "MP", STR0055)
	IncluiTipo(oTipo, "MD", STR0056)
	IncluiTipo(oTipo, "TP", STR0059)
	IncluiTipo(oTipo, "MT", STR0057)
	IncluiTipo(oTipo, "CA", STR0058)
	IncluiTipo(oTipo, "MO", STR0060)
	IncluiTipo(oTipo, "MR", STR0061)	
	IncluiTipo(oTipo, "BA", STR0062)	

	//-- Etapas
	//-- Etapa Preparação --------------------------------------------
	oEtapas:SetValue("CP0_ETAPA","PR")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","DV")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","PRE")

	//-- Etapa Divulgação --------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","DV")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","LP")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","PR")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","DIV")


	//-- Apresentação Lances/Propostas -------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","LP")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","JP")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","DV")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ALP")

	//-- Julgamento ---------------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","JP")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","VP")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","LP")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","JPE")

	//-- Ver. da Efetividade dos Lances/Propostas ----------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","VP")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","NE")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","JP")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","VER")

	//-- Negociação ---------------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","NE")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Neg()")
	oEtapas:SetValue("CP0_PROXIV","HA")
	oEtapas:SetValue("CP0_PROXIF","RV")
	oEtapas:SetValue("CP0_ETPANT","VP")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","NEG")

	//-- Habilitação ---------------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HA")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","IR")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","NE")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","HBE")

	//-- Interposição de recursos --------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","IR")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Rec()")
	oEtapas:SetValue("CP0_PROXIV","AD")
	oEtapas:SetValue("CP0_PROXIF","RV")
	oEtapas:SetValue("CP0_ETPANT","HA")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","REC")

	//-- Adjudicação --------------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AD")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","HO")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","IR")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ADE")

	//-- Homologação --------------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","HO")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","HOE")

	//-- Revogação --------------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RV")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","DV")
	oEtapas:SetValue("CP0_ETPANT","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","REV")

	//-- Ata de Registro de Preço ------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AT")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","AA")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","REV")

	//-- Assinatura da Ata de Registro de Preço ----------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","AA")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","FI")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	oCheckList:SetValue("CP1_CHECK","ASA")

	//-- Etapa Remanescente do Edital
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","RM")
	oEtapas:LoadValue("CP0_CONDIC","GCP017Reman()")
	oEtapas:SetValue("CP0_PROXIV","HO")
	oEtapas:SetValue("CP0_PROXIF","FI")
	oEtapas:LoadValue("CP0_MODALI","PL")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

	//-- Etapa Final -------------------------------------------------
	oEtapas:Addline()
	oEtapas:SetValue("CP0_ETAPA","FI")
	oEtapas:LoadValue("CP0_CONDIC","")
	oEtapas:SetValue("CP0_PROXIV","")
	oEtapas:SetValue("CP0_PROXIF","")
	oEtapas:SetValue("CP0_ETPANT","")
	oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
Return

/*/{Protheus.doc} IncCredenc
	Inclui a modalidade Credenciamento
@author philipe.pompeu
@since 19/04/2022
@param oModel, objeto, instancia de MPFormModel
@return Nil, Nulo
*/
Static Function IncCredenc(oModel as Object, nTamOrdem as Numeric)
	Local oModali 	:= oModel:GetModel('CP5DETAIL')
	Local oTipo 	:= oModel:GetModel('COZDETAIL')
	Local oEtapas 	:= oModel:GetModel('CP0DETAIL')
	Local oCheckList:= oModel:GetModel('CP1DETAIL')
	Local cCodModal	:= "CR"

	If ExistCpo("SX5","LF" + cCodModal) .And. ExistCpo("SX5","LEPQ")
		If !Empty(oModali:GetValue('CP5_MODALI'))		
			oModali:Addline()
		EndIf
		oModali:LoadValue("CP5_ITEM",StrZero(oModali:GetLine(),TamSx3("CP5_ITEM")[1]))
		oModali:SetValue("CP5_MODALI",cCodModal)		

		IncluiTipo(oTipo, "MP", STR0055)
		IncluiTipo(oTipo, "MD", STR0056)
		IncluiTipo(oTipo, "MT", STR0057)
		IncluiTipo(oTipo, "CA", STR0058)
		IncluiTipo(oTipo, "TP", STR0059)
		IncluiTipo(oTipo, "MO", STR0060)
		IncluiTipo(oTipo, "MR", STR0061)

		//Analise do Edital
		oEtapas:SetValue("CP0_ETAPA","ED")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","PB")
		oEtapas:SetValue("CP0_PROXIF","")
		oCheckList:SetValue("CP1_CHECK"," ")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

		//-- Etapa Publicação do Edital
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","PB")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","PQ")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK","PUB")

		//Etapa Pré-Qualificação
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","PQ")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","HO")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK"," ")

		//-- Etapa de Homologação
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","HO")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","AD")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))

		//-- Etapa de Adjudicação
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","AD")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","FI")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
		oCheckList:SetValue("CP1_CHECK","ADJ")

		//-- Etapa Final -------------------------------------------------
		oEtapas:Addline()
		oEtapas:SetValue("CP0_ETAPA","FI")
		oEtapas:LoadValue("CP0_CONDIC","")
		oEtapas:SetValue("CP0_PROXIV","")
		oEtapas:SetValue("CP0_PROXIF","")
		oEtapas:LoadValue("CP0_ORDEM",StrZero(oEtapas:GetLine(),nTamOrdem))
	EndIf
Return

/*/{Protheus.doc} IncluiTipo
	Inclui <cTipo> no submodelo COZDETAIL(oTipo)
@author philipe.pompeu
@since 02/06/2022
@param oTipo, objeto, instancia de FwFormGridModel
@param cTipo, caractere, código do tipo
@param cDescricao, caractere, descrição p/ o tipo
@return Nil, Nulo
*/
Static Function IncluiTipo(oTipo, cTipo, cDescricao)
	If !Empty(oTipo:GetValue("COZ_TIPO"))
		oTipo:Addline()
	EndIf
	oTipo:LoadValue("COZ_TIPO"	,cTipo)
	oTipo:LoadValue("COZ_DESCRI",cDescricao)
	oTipo:LoadValue("COZ_USADO"	,.T.)
Return
