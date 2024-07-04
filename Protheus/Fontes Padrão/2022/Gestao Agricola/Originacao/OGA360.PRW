#INCLUDE "OGA360.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// -- Contantes --
#DEFINE   CTRATOCPRA '1'
#DEFINE   CTRATOVND  '2'

// Atenção as Folders estão definidas na View nesta sequencia na 
#DEFINE   FLDDADOSFIN 1  // Folder 'Dados Financeiro',2)
#DEFINE   FLDENTREGAS 2  // Folder Entregas   
#DEFINE   FLDINFLIQDS 3  // Folder 'Infs.Liquidação'

// --Staticas --
STATIC xTpCtrato	:=  nil
STATIC xTpLiq		:=  nil   	//Apartir do chamado TUDBDE, Utilizou-se uma outra forma de selecionar os titulos para Liquidação  1 = Atual, 0=Sera Anterior
STATIC xBrowseEnt	:=  Nil   	// Ira conter o Browse das Entregas

STATIC xVrMrkdo  	:=  0		//Irá conter o total fixado dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot
STATIC xVrMrkFre 	:=  0		//Irá conter o total de Frete  a  Baixar dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot
STATIC xVrMrkSeg 	:=  0		//Irá conter o total de Seguro a  Baixar dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot
STATIC xVrMrkDsp 	:=  0		//Irá conter o total de DSP    a  Baixar dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot

STATIC xTRBTITS  		 		//Irá conter o Arquivo de trabalho temporario
STATIC xVrAcresLq	:= 0		//Irá conter Acrescimo  da Liquidação caso contenha
STATIC xVrDecreLq	:= 0		//Irá conter Decrescimo da Liquidação caso contenha
STATIC xVrDifCalc	:= 0.05		// Dif. entre vr. calc. pela fixacao e vr do tit. considerada normal devido ao calc. impostos

STATIC xVrFrete		:= 0		// Irá conter o Vr. total de Frete  	da OP/OR
STATIC xVrSeguro	:= 0		// Irá Conter o Vr. total de Seguro 	da OP/OR
STATIC xVrDespesa	:= 0		// Irá conter o Vr. total de Desp.Acess da OP/OR

STATIC xConsidFre	:=	.f. 	// Indica que deve Considerar o Frete 	para Liquidar ( Var Ajustada na funcao iniModelo de acordo com o parametro MV_OGLQDSP )
STATIC xConsidSEG	:=	.f. 	// Indica que deve Considerar o Seguro para Liquidar ( Var Ajustada na funcao iniModelo de acordo com o parametro MV_OGLQDSP )
STATIC xConsidDsp	:=	.f. 	// Indica que deve Considerar a Despesa acessoria  para Liquidar ( Var Ajustada na funcao iniModelo de acordo com o parametro MV_OGLQDSP )
Static xlUltOPOR	:= 	.f.		//Indica se é a Ultima a OPOR

Static oTrbTits     := Nil

Static __aTab1220 := {"N8M"}
Static __lLib1220 := AGRTABDIC(__aTab1220)

/** {Protheus.doc} OGA360
Rotina para inclusão de Ordens de Pagamento/Recebimenot (Normal - Antecipada)

@param: 	Nil
@author: 	Vitor Alexandre de Barba
@since: 	29/11/2014
@Uso: 		SIGAARM - Originação de Grãos
*/

Function OGA360()
	Local cTitle		:= ''
	Local oMBrowse	:= Nil

	//-- Se xTpCtrato, não estiver inicializada Inicializa --//
	IF xTpCtrato == nil
		fGetTpCtr()
	EndIF

	IF xTpCtrato == CTRATOCPRA
		cTitle	:= STR0001 					//"Ordem de Pagamento"
	ElseIF xTpCtrato == CTRATOVND
		cTitle	:= 	STR0035					//"Ordem de Recebimento"
	EndIF

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NN5" )
	oMBrowse:SetMenuDef( "OGA360" )
	oMBrowse:SetDescription( cTitle ) 		//"Ordem de Pagamento" ou "Ordem de Recebimento"
	oMBrowse:AddLegend( "NN5_STATUS='1'"	, "GREEN"	, 	STR0002 ) //"Programada"
	oMBrowse:AddLegend( "NN5_STATUS='2'"	, "BLUE"	, 	STR0003 ) //"Parcialmente Executada"
	oMBrowse:AddLegend( "NN5_STATUS='3'"	, "RED"	, 	STR0004 ) //"Totalmente Executada"

	oMBrowse:SetWalkThru(.F.)
	oMBrowse:SetAmbiente(.F.)

	oMBrowse:DisableDetails()
	oMBrowse:Activate()	

Return( Nil )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Vitor Alexandre de Barba
@since: 	29/11/2014
@Uso: 		OGA360 - Espécies
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0005 	, 'PesqBrw'        	, 0, 1, 0, .T. } ) //'Pesquisar'
	aAdd( aRotina, { STR0006	, 'ViewDef.OGA360'	, 0, 2, 0, Nil } ) //'Visualizar'
	aAdd( aRotina, { STR0007	, 'ViewDef.OGA360'	, 0, 3, 0, Nil } ) //'Incluir'
	aAdd( aRotina, { STR0008   	, 'ViewDef.OGA360'	, 0, 5, 0, Nil } ) //'Excluir'
	aAdd( aRotina, { STR0009  	, 'ViewDef.OGA360'	, 0, 8, 0, Nil } ) //'Imprimir'


Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Vitor Alexandre de Barba
@since: 	29/11/2014
@Uso: 		OGA360 - Ordem de Pagamento/Recebimento
*/
Static Function ModelDef()
	Local oStruNN5		:= FWFormStruct( 1, "NN5" )
	Local oStruNN6		:= FWFormStruct( 1, "NN6" )
	Local oStruNKK		:= FWFormStruct( 1, "NKK" )
	Local oModel		:= MPFormModel():New( "OGA360", , {| oModel | PosModelo( oModel ) }, {| oModel | OG360GRVMD( oModel ) } )
	Local cTitle		:=''
	Local cTitleA		:=''
	Local cTitleB		:=''

	//-- Se xTpCtrato, não estiver inicializada Inicializa --//
	IF xTpCtrato == nil
		fGetTpCtr()
	EndIF

	if cPaisLoc <> "PAR"

		IF xTpCtrato == CTRATOCPRA
			ctitle	:= STR0011 		//"Dados da Ordem de Pagamento"
			cTitleA	:= STR0012  	//"Dados dos Favorecidos"
			cTitleB	:= STR0001		//"Ordem de Pagamento"
		ElseIF xTpCtrato == CTRATOVND
			cTitle	:= STR0036		// "Dados da Ordem de Recebimento"
			cTitleA	:= STR0037		//"Dados do Cliente"
			cTitleB	:= STR0035		// "Ordem de Recebimento"
			//Retira a obrigatoriedade dos campos, Abaixo que não são necessarios para Recebimentos
			oStruNN6:SetProperty("NN6_CODBCO",	MODEL_FIELD_OBRIGAT,.F.)
			oStruNN6:SetProperty("NN6_CODAGE",	MODEL_FIELD_OBRIGAT,.F.)
			oStruNN6:SetProperty("NN6_DVAGE",	MODEL_FIELD_OBRIGAT,.F.)
			oStruNN6:SetProperty("NN6_CODCTA",	MODEL_FIELD_OBRIGAT,.F.)
			oStruNN6:SetProperty("NN6_DVCTA",	MODEL_FIELD_OBRIGAT,.F.)
			oStruNN6:SetProperty("NN6_CSSCRD",	MODEL_FIELD_OBRIGAT,.F.)
		EndIF

		/*/
		!-------------------------------------------------------!
		! Devido a Termos Un. medida do Produto e Um. de Preço;	!
		! Ajusto os titulos de Qtd. e Vr. Un. para, Un de medida!
		! do produto. Na Ordem de pagto o Vr. Un. é equalizado  !
		! Para a Un. de medida do produto.						!
		!  	ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM!
		!	PARA FUNCIONAR OS FILTROS DO GRID 					!
		!-------------------------------------------------------!
		/*/
		oStruNN5:SetProperty( 'NN5_QTDFIN' , MODEL_FIELD_TITULO, "Qtidade/" + ALLTRIM(NJR->NJR_UM1PRO) ) 		//#Qtidade/
		oStruNN5:SetProperty( 'NN5_VLRUNI' , MODEL_FIELD_TITULO, "Vr.Un./"  + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Vr.Un./
		/*/----------------------------------------------------/*/

		//-- Removendo cpos dO Model ( tbem foram retirados da View )
		oStruNN5:RemoveField( "NN5_PERJUR" )

		// -- Incluindo Init no NN6_CODOPG --
		oStrunn6:SetProperty( 'NN6_CODOPG'    ,    MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, "FWFLDGET('NN5_CODOPG')") )

		// -- Incluindo Valids da NN5
		oStruNN5:SetProperty( "NN5_QTDFIN" 		, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg360Vld1()") )
		oStruNN5:SetProperty( "NN5_CONPAG" 		, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg360Vld2()") )

		oStruNN5:SetProperty( "NN5_VLRTOT" 		, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg360Vld3()") )

		//--Inicializador  da NN6 *//
		oStruNN6:SetProperty( 'NN6_NATFIN'   	,    MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, "MV_PAR02" ))

		//--Verifica Entidade
		oStruNN6:SetProperty( "NN6_LOJFAV" 	, MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"OG360VdEn()") ) 

		oModel:AddFields( "NN5UNICO", Nil, oStruNN5 )

		oModel:GetModel( "NN5UNICO" ):SetDescription( cTitle ) // "Dados da Ordem de Pagamento" ou "Dados da Ordem de Recebimento"

		oModel:AddGrid( "NN6UNICO", "NN5UNICO", oStruNN6, , { |x| PosLGrdNN6( x ) }, , { |x| fTudoOk( x )} , )
		oModel:GetModel( "NN6UNICO" ):SetUniqueLine( { "NN6_ITEM" } )
		oModel:GetModel( "NN6UNICO" ):SetDescription( cTitleA ) //"Dados dos Favorecidos" ou "Dados do Cliente"
		oModel:SetDescription( cTitleB ) //"Ordem de Pagamento" ou "Ordem de Recebimento"
		oModel:SetRelation( "NN6UNICO", { { "NN6_FILIAL", "xFilial( 'NN6' )" }, { "NN6_CODOPG", "NN5_CODOPG" } }, NN6->( IndexKey( 1 ) ) )

		//Adicionando Modelo da Tabela de Baixa de titulos NKK
		oModel:AddGrid( "NKKUNICO", "NN5UNICO", oStruNKK )
		oModel:SetRelation( "NKKUNICO", { { "NKK_FILIAL", "xFilial( 'NKK' )" }, { "NKK_OPOR", "NN6_CODOPG" }, { "NKK_ITOPOR", "NN6_ITEM" } }, NKK->( IndexKey( 1 ) ) )
		oModel:GetModel( "NKKUNICO" ):SetUniqueLine( { "NKK_ITEM" } )
		oModel:GetModel( "NKKUNICO" ):SetOptional( .t. )

		oModel:SetActivate( { | oMod | IniModelo( oMod, oModel:GetOperation() ) } )
		oModel:SetVldActivate( { |oMod| fVldActivate( oMod ) } )

		oModel:SetDeActivate( { | oModel | fFimModelo( oModel ) } ) //-- Encerrando o Modelo --//

	Else //Localização = Paraguai

		IF xTpCtrato == CTRATOCPRA
			ctitle	:= STR0056 		// "Pedido de Compra"			
		ElseIF xTpCtrato == CTRATOVND
			cTitle	:= STR0057		// "Pedido de Venda"
		EndIF

		oStruNN5:SetProperty( 'NN5_QTDFIN' , MODEL_FIELD_TITULO, "Qtidade/" + ALLTRIM(NJR->NJR_UM1PRO) ) 		//#Qtidade/
		oStruNN5:SetProperty( 'NN5_VLRUNI' , MODEL_FIELD_TITULO, "Vr.Un./"  + ALLTRIM(NJR->NJR_UMPRC) ) 		//#Vr.Un./
		/*/----------------------------------------------------/*/

		//-- Removendo cpos dO Model ( tbem foram retirados da View )
		//blalbaoStruNN6:RemoveField( "NN6_CODOPG" )  -- RETIRAR SOMENTE NA VIEW
		oStruNN5:RemoveField( "NN5_PERJUR" )

		// -- Incluindo Valids da NN5
		oStruNN5:SetProperty( "NN5_QTDFIN" 		, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg360Vld1()") )
		oStruNN5:SetProperty( "NN5_CONPAG" 		, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg360Vld2()") )
		oStruNN5:SetProperty( "NN5_VLRTOT" 		, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg360Vld3()") )
		
		//--Inicializador  da NN5 *//
		oStruNN5:SetProperty( 'NN5_QTDFIN'   	,    MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, "NN8->NN8_QTDENT - NN8->NN8_QTDFIN" ))
		
		oModel:AddFields( "NN5UNICO", Nil, oStruNN5 )

		oModel:GetModel( "NN5UNICO" ):SetDescription( cTitle ) // "Pedido de Compra" ou "Pedido de Venda"
		oModel:SetDescription( cTitle ) 						// "Pedido de Compra" ou "Pedido de Venda"

		oModel:SetActivate( { | oMod | IniModelo( oMod, oModel:GetOperation() ) } )
		oModel:SetVldActivate( { |oMod| fVldActivate( oMod ) } )

		oModel:SetDeActivate( { | oModel | fFimModelo( oModel ) } ) //-- Encerrando o Modelo --//

	EndIf

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Vitor Alexandre de Barba
@since: 	29/11/2014
@Uso: 		OGA360 - Ordem de Pagamento/Recebimento
*/
Static Function ViewDef()
	Local oStruNN5	:= FWFormStruct( 2, "NN5" )
	Local oStruNN6	:= FWFormStruct( 2, "NN6" )
	Local oStruNKK	:= FWFormStruct( 2, "NKK" )	

	Local oModel	:= FWLoadModel( "OGA360" )
	Local oView		:= FWFormView():New()

	If cPaisLoc <> "PAR"

		IF xTpCtrato == CTRATOVND
			// Para os Contratos de Venda, Retiro da View infs. de Bco/Ag/Cta,etc;
			// pq essas sao informacoes utiliadas na OP.para o financeiro identificar
			// Qual Conta Dev Pagar o Produtor. No Recebto quem faz a OR, não sabe
			// em qual Bco/Cta/ ou se será em dinheiro o Pagto.
			oStruNN6:RemoveField("NN6_CODBCO")
			oStruNN6:RemoveField("NN6_CODAGE")
			oStruNN6:RemoveField("NN6_DVAGE")
			oStruNN6:RemoveField("NN6_CODCTA")
			oStruNN6:RemoveField("NN6_DVCTA")
			oStruNN6:RemoveField("NN6_CSSCRD")
		EndIF

		//-- Removendo cpos da View ( tbem foram retirados do MODEL )
		oStruNN6:RemoveField( "NN6_CODOPG" )
		oStruNN5:RemoveField( "NN5_PERJUR" )

		//-- Removendo Cpos da View ( tirado somente na View para Usuario n. ver pois é um Cpo de controle interno)
		oStruNN5:RemoveField( "NN5_TPLIQ" )
		oStruNN5:RemoveField( "NN5_VRACRE" )
		oStruNN5:RemoveField( "NN5_VRDECR" )

		// -- Removendo cpos da View, pois as consultas padroes não retornam digito verificado da agencia -- //
		//oStruNN6:RemoveField( "NN6_DVAGE" )

		oView:SetModel( oModel )

		oView:AddField( "VIEW_NN5",	oStruNN5, "NN5UNICO" )

		oView:AddGrid( "VIEW_NN6",	oStruNN6, "NN6UNICO" )
		oView:AddIncrementField( "VIEW_NN6", "NN6_ITEM" )

		oView:AddGrid( "VIEW_NKK",	oStruNKK, "NKKUNICO" )
		oView:AddIncrementField( "VIEW_NKK", "NKK_ITEM" )

		oView:AddOtherObject("VIEW_ENTREGAS", {|oPanel| fBrwEntreg(oPanel) })//,Nil,fBrwEntreg(oPanel)})

		oView:CreateVerticallBox( "TELANOVA" , 100 				)
		oView:CreateHorizontalBox( "SUPERIOR" , 40, "TELANOVA" 	)
		oView:CreateHorizontalBox( "INFERIOR" , 60, "TELANOVA" 	)

		//-- Criando Grades na Pasta Inferior
		oView:CreateFolder( "GRADES", "INFERIOR")
		oView:AddSheet( "GRADES", "PASTA01", OemToAnsi( 'Dados Financeiro') )

		oView:CreateHorizontalBox( "PASTA_NN6"		, 100, , , "GRADES", "PASTA01" )

		oView:AddSheet( "GRADES", "PASTA02", OemToAnsi( 'Entregas'), {|oPanel| fBrwEntreg(oPanel)})
		oView:CreateHorizontalBox( "PASTA_ENTREGAS"	, 100, , , "GRADES", "PASTA02" )
		oView:SetOwnerView( "VIEW_ENTREGAS", "PASTA_ENTREGAS" )

		oView:AddSheet( "GRADES", "PASTA03", OemToAnsi( 'Infs.Liquidação'), {|oPanel| fBrwEntreg(oPanel)})
		oView:CreateHorizontalBox( "PASTA_LIQDADOS"	, 100, , , "GRADES", "PASTA03" )
		oView:SetOwnerView( "VIEW_NKK", "PASTA_LIQDADOS" )	

		oView:SetOwnerView( "VIEW_NN5", "SUPERIOR" )
		oView:SetOwnerView( "VIEW_NN6", "PASTA_NN6" )

		oView:EnableTitleView( "VIEW_NN5" )
		oView:EnableTitleView( "VIEW_NN6" )

		/*/
		!-------------------------------------------------------!
		! Devido a Termos Un. medida do Produto e Um. de Preço;	!
		! Ajusto os titulos de Qtd. e Vr. Un. para, Un de medida!
		! do produto. Na Ordem de pagto o Vr. Un. é equalizado  !
		! Para a Un. de medida do produto.						!
		!  	ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM!
		!	PARA FUNCIONAR OS FILTROS DO GRID 					!
		!-------------------------------------------------------!
		/*/
		oStruNN5:SetProperty( 'NN5_QTDFIN' , MVC_VIEW_TITULO, "Qtidade/" + ALLTRIM(NJR->NJR_UM1PRO) ) 		//#Qtidade/
		oStruNN5:SetProperty( 'NN5_VLRUNI' , MVC_VIEW_TITULO, "Vr.Un./"  + ALLTRIM(NJR->NJR_UM1PRO) ) 		//#Vr.Un./
		/*/----------------------------------------------------/*/

		oView:AddUserButton( STR0059, STR0059, { | x | OG360RTITS() } ) //Recria o Arquivo de Entregas ###"Refresh TitS/Entregas"

		oView:SetCloseOnOk( {||.t.} )

	Else //Localização = Paraguai

		oStruNN5:RemoveField( "NN5_PERJUR" )

		//-- Removendo Cpos da View ( tirado somente na View para Usuario n. ver pois é um Cpo de controle interno)
		oStruNN5:RemoveField( "NN5_TPLIQ"  )
		oStruNN5:RemoveField( "NN5_VRACRE" )
		oStruNN5:RemoveField( "NN5_VRDECR" )
		oStruNN5:RemoveField( "NN5_MOEDA"  )
		oStruNN5:RemoveField( "NN5_TIPO"   )
		oStruNN5:RemoveField( "NN5_VLRTOT" )
		oStruNN5:RemoveField( "NN5_STATUS" )

		oView:SetModel( oModel )

		oView:AddField( "VIEW_NN5",	oStruNN5, "NN5UNICO" )

		oView:CreateVerticallBox( "TELANOVA" , 100 	)

		oView:SetOwnerView( "VIEW_NN5", "TELANOVA" )

		oView:EnableTitleView( "VIEW_NN5" )

	EndIf

Return( oView )

/** {Protheus.doc} 7
Função que Inicializa o modelo NN6, com os dados
financeiro q forma digitados no contrato tabela NN7

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		OGA360 - Ordem de Pagto.
*/
Static Function IniModelo( oModel , nOperation )

	Local ofldNN5		:= oModel:GetModel( "NN5UNICO" )
	Local oGrdNN6		:= oModel:GetModel( "NN6UNICO" )
	Local aAreaAtu 		:= GetArea()
	Local aAreaNN7 		:= NN7->(GetArea())
	Local oView			:= FwViewActive()
	Local nI			:= 0
	Local cMvOgLqDsp	:= SuperGetMV("MV_OGLQDSP",.F.,'1')	// Se não Existir considera como 1 não Considera as Despesas, 2 considera as Despesas  
	
	fIniStatic()  						// Inicializa as Vars Staticas

	fGetTpCtr()							// -- Inicializando a Variavel Statica xTpCtrato

	IF xTpCtrato == CTRATOCPRA
		Pergunte("OGA360" , .F.)		//-- Perg. ref. Ordem Pagto				--//
	ElseIF xTpCtrato == CTRATOVND
		Pergunte("OGA360A" , .F.)		//-- Perg. ref. Ordem Recebto				--//
	EndIF

	//Inicializando variaveis q controlam se considera as Depesas de Frete/Seg/DspAcess na Liquidação
	Do Case
		Case Alltrim( cMvOgLqDsp) == '1'   // Não considera nenhuma das Despesas
		xConsidFre	:=	.f.
		xConsidSEG	:=	.f.
		xConsidDsp	:=	.f.
		Case Alltrim( cMvOgLqDsp) == '2'   // Considera Todas as Despesas
		xConsidFre	:=	.t.
		xConsidSEG	:=	.t.
		xConsidDsp	:=	.t.
	EndCase
	// Fim Inicializando variaveis q controlam se considera as Depesas de Frete/Seg/DspAcess na Liquidação

	/*/
	!---------------------------------------------------	!
	!-Inicializa Cpos da NN5 com a Fixação posicionada;	!
	!-Le a NN7 relacionada ao Ctrato para inicializar a 	!
	!	NN6 com dados financeiros digitados no Ctrato.	!
	!---------------------------------------------------	!
	/*/
	If nOperation == MODEL_OPERATION_INSERT
				
		SetKey( VK_F11, { || fSetF11(xTpCtrato == CTRATOCPRA, oModel) } )			

		// -- Inicializando Vars do NN5 ref. a Tabela NN8 --//
		nVrUni := Round( NN8->NN8_VLRLIQ / AGRX001( NJR->NJR_UMPRC , NJR->NJR_UM1PRO, 1, NJR->NJR_CODPRO ) , TamSX3("NN8_VLRUNI")[2] )

		ofldNN5:SetValue( "NN5_CODCTR", NN8->NN8_CODCTR 	)
		ofldNN5:SetValue( "NN5_CODFIX", NN8->NN8_ITEMFX 	)
		
		If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG" 
		   ofldNN5:SetValue( "NN5_VLRUNI",	round(nVrUni,5)	)			        
		Else
			ofldNN5:SetValue( "NN5_VLRUNI",	round(nVrUni,TamSX3("NN5_VLRUNI")[2] )	)           
		EndIf
		
		ofldNN5:SetValue( "NN5_DTEXEC", dDataBase           )

		IF xTpCtrato == CTRATOCPRA
			ofldNN5:SetValue( "NN5_TIPO", 	'2' )	// Pagamento
		ElseIF xTpCtrato == CTRATOVND
			ofldNN5:SetValue( "NN5_TIPO", 	'1' )	// Recebimento
		EndIF

		ofldNN5:SetValue( "NN5_CONPAG", MV_PAR01 			)

		//-- Preenche o Grid com os Dados fin. q estão no ctrato --//

		If cPaisLoc <> "PAR"

			NN7->( dbSetOrder( 1 ) )			//NN7_FILIAL+NN7_CODCTR+NN7_ITEM
			If NN7->( dbSeek( fWxFilial( 'NN7' ) + ofldNN5:GetValue("NN5_CODCTR" ) ) )
				oGrdNN6:cleardata() 			// --- Limpa todas as Linhas do Grid ---//
				oGrdNN6:InitLine()

				nI := 0
				While ! NN7->( Eof() ) .AND. NN7->( NN7_FILIAL + NN7_CODCTR ) == fWxFilial( 'NN7' ) + FWFLDGET("NN5_CODCTR" )

					nI+=1
					IF nI > 1
						oGrdNN6:AddLine()
					EndIF
					oGrdNN6:GoLine( nI )

					oGrdNN6:LoadValue( "NN6_CODFAV" 		,NN7->NN7_CODFAV	)
					oGrdNN6:LoadValue( "NN6_LOJFAV" 		,NN7->NN7_LOJFAV	)
					//tratar favorecido
					IF xTpCtrato == CTRATOCPRA 
						oGrdNN6:LoadValue( "NN6_NOMFAV"	, POSICIONE('NJ0',1,XFILIAL('NJ0')+ NN7->(NN7_CODFAV+NN7_LOJFAV),'NJ0_NOME') 	)
						oGrdNN6:LoadValue( "NN6_NLJFAV" , POSICIONE('NJ0',1,XFILIAL('NJ0')+ NN7->(NN7_CODFAV+NN7_LOJFAV),'NJ0_NOMLOJ') 	)
					ElseIF xTpCtrato == CTRATOVND
						oGrdNN6:LoadValue( "NN6_NOMFAV"	, POSICIONE('NJ0',1,XFILIAL('NJ0')+ NN7->(NN7_CODFAV+NN7_LOJFAV),'NJ0_NOME') 	)
						oGrdNN6:LoadValue( "NN6_NLJFAV" , POSICIONE('NJ0',1,XFILIAL('NJ0')+ NN7->(NN7_CODFAV+NN7_LOJFAV),'NJ0_NOMLOJ') 	)
					EndIf

					IF !Empty( MV_PAR02 )
						oGrdNN6:LoadValue( "NN6_NATFIN" 	,MV_PAR02			)
					Else
						oGrdNN6:LoadValue( "NN6_NATFIN" 	,NN7->NN7_NATURE	)
					EndIF
					oGrdNN6:LoadValue( "NN6_CODBCO" 	,NN7->NN7_CODBCO		)
					oGrdNN6:LoadValue( "NN6_CODAGE" 	,NN7->NN7_CODAGE		)
					oGrdNN6:LoadValue( "NN6_DVAGE"		,NN7->NN7_DVAGE			)
					oGrdNN6:LoadValue( "NN6_CODCTA"		,NN7->NN7_CODCTA		)
					oGrdNN6:LoadValue( "NN6_DVCTA"		,NN7->NN7_DVCTA			)

					NN7->( DbSkip() )
				EndDo
			EndIF
		EndIF
	EndIF

	RestArea( aAreaNn7 )
	RestArea( aAreaAtu )
	// --- Fim LÊ NN7 relacionada ao Contrato para inicializar a NN6 Com os Dados Financeiros Digitados no Ctrato ---  //

	// Tratamento Ref. ao nova Forma de Sel. Tits. Para Liquidar
	xTpLiq := fGetTPLIQ()		// -- Verificando o Tipo de Sel.Titulos Para Liquidar e abastecendo a Var Statica xTpLiq


	If oView != NIL

		IF !xTpLiq = '1'		// Indica que é o tipo de Liquidação Antigo  
			//EMERoView:HideFolder('GRADES','ENTREGAS',2)
			//EMERoView:HideFolder('GRADES','Infs.Liquidação',2)
			oView:HideFolder('GRADES', FLDENTREGAS ,2) // Retira a Folder 'ENTREGAS'
			oView:HideFolder('GRADES', FLDINFLIQDS ,2) // Retira a Folder 'Infs.Liquidação'
		Else   // Modo de Liquidação mais Atual
			IF ! nOperation = MODEL_OPERATION_VIEW		//So Mostro a Pasta de Infs. da liquidação qdo for visualizar
				///EMERoView:HideFolder('GRADES','Infs.Liquidação',2)
				oView:HideFolder('GRADES', FLDINFLIQDS ,2) // Retira a Folder 'Infs.Liquidação'
			EndIF
		EndIF
		//-- Setando a Abra Padrão ao Abrir a rotina para Incluir/alterar/Excluir/visualizar
		///oView:SelectFolder('GRADES','Dados Financeiro',2)
		oView:SelectFolder('GRADES', FLDDADOSFIN ,2) // 
	EndIF

	IF ! nOperation = MODEL_OPERATION_VIEW
		__lBTNRefresh := .T.
	EndIF




Return(.t.)

/** {Protheus.doc} fVldActivate
Função que pré-valida a entrada na tela

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	08/11/2014
@Uso: 		OGA430F
*/
Static Function fVldActivate( oModel )
	Local nOperation	:= oModel:GetOperation()
	Local nQtEntreg		:= NN8->NN8_QTDENT
	Local aAreaAtu		:= GetArea()
	Local aAreaNJR 		:= NJR->(GetArea())
	Local lContinua		:= .T.

	NJR->( dbSetOrder( 1 ) ) //NJR_FILIAL+NJR_CODCTR
	NJR->( dbSeek( xFilial( "NJR" ) + NN8->NN8_CODCTR ) ) //Posiciona na Njr para Pegar a Entidade

	If nOperation == MODEL_OPERATION_INSERT

		//VERIFICA ENTIDADE
		If OGA360ENT( NJR->NJR_CODENT , NJR->NJR_LOJENT, NJR->NJR_TIPO )	
			If NJR->NJR_TIPO == '1'			//COMPRA - FORNECEDOR
				lContinua := AgrEntidOk( "SA2", NJR->NJR_CODENT , NJR->NJR_LOJENT ) 
			ElseIf NJR->NJR_TIPO == '2'		//VENDA - CLIENTE
				lContinua := AgrEntidOk( "SA1", NJR->NJR_CODENT , NJR->NJR_LOJENT ) 
			EndIf
		EndIf 	

		If lContinua .AND. NJR->( NJR_MODELO ) == "1" //Pré-Contrato
			Help( ,, STR0011,, STR0015 , 1, 0,) //"HELP"##"Operação não permitida para Pré-Contratos."
			lContinua := .f. //Return( .F. )
		ElseIf lContinua .AND. !( NJR->( NJR_STATUS ) $ "A|I" ) //Se status do contrato for diferente de Aberto ou Iniciado
			Help( ,, STR0011,, STR0016+NJR->( NJR_STATUS )+"="+ X3CboxDesc( "NJR_STATUS", NJR->( NJR_STATUS ) ) , 1, 0,) //"HELP"##"Operação não permitida para Contratos com STATUS igual a "
			lContinua := .f. //Return( .F. )
		ElseIF lContinua .AND. nQtEntreg == 0 // Não possui qtidade Entregue
			Help( ,, STR0011,, STR0027, 1, 0,) //"HELP"##"Não Existe Estregas Relacionadas a esta Fixação."
			lContinua := .f.
		ElseIF lContinua .AND. .not. fEntregaOK()    //Verifica se tem alguma, Pendencia nas nfs. de ntrega, tipo NF. de Complemento a ser Emitida; etc.
			Help( ,, STR0011,, STR0047 , 1, 0,) //"HELP"##'Existe divergencia entre o Vr. Fixado e os Vrs. fiscais das Entregas. Verifique o Status das Entregas desta fixação'
			lContinua:= .f.
		EndIF	
	EndIF

	RestArea( aAreaNJR )
	RestArea( aAreaAtu )
Return( lContinua )

/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA360 - Ordem de Pagamento/Recebimento
*/
Static Function PosModelo( oModel )
	Local lContinua		:= .T.
	Local aAreaAtu		:= GetArea()
	Local nOperation	:= oModel:GetOperation()

	Local oNN5			:= oModel:GetModel( "NN5UNICO" )
	Local cCodCtr		:= oNN5:GetValue( "NN5_CODCTR" )
	Local cCodFix		:= oNN5:GetValue( "NN5_CODFIX" )
	Local nQtdOrd		:= oNN5:GetValue( "NN5_QTDFIN" )
	Local nVrOPOR		:= oNN5:GetValue( "NN5_VLRTOT" )  //oNN5:GetValue( "NN5_VRFIXT" ) //oNN5:GetValue( "NN5_VLRTOT" )
	Local cStatus		:= oNN5:GetValue( "NN5_STATUS" )

	//Local nVlrCrd		:= 0
	//Local nVlrExe		:= 0

	Local nQtEntreg 	:= NN8->NN8_QTDENT
	Local nQtOpagto 	:= NN8->NN8_QTDFIN // fQtOpagto()	// -- Encontra a Qt. Que ja possuem Ordem de Pagamento
	Local cAliasSE2 	:= ''
	Local cAliasSE1 	:= ''
	Local cQrySE2		:= ''
	Local cQrySE1		:= ''
	Local nTotCPagar 	:= 0
	Local nTotalRec 	:= 0
	Local nVrNoFinan	:= 0


	If nOperation == MODEL_OPERATION_INSERT   	// Se for Inserção

		// -- Identificando Tp. de Liq. q deve ocorrer SE1 ou SE2, de acordo com o Tp do Ctrato
		Do Case
			Case xTpCtrato == CTRATOCPRA   	// Ctrato de Compra
			// -- Buscando o Vr. de tits. a Pagar ref as entregas dos romaneios deste ctrato e fixação--//
			IF ! xTpLiq = '1' // Tratamento  Para Manter forma Antiga de Liquidação no futuro basta tirar o q está no IF e deixar o que está no Else e eliminar fqryse2
				cQrySE2	:= fQrySE2(cCodCtr , cCodFix, 1 ) //1 Indica que a Qry seram montada para Retornar a Sum(E2_SALDO)
				cAliasSE2 	:= GetNextAlias()
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQrySE2),cAliasSE2,.F.,.T.)
				(cAliasSE2)->( DbGoTop() )
				nTotCPagar := (cAliasSE2)->SldTotal
				(cAliasSE2)->( DbCloseArea() )
			EndIF
			Case xTpCtrato == CTRATOVND
			IF ! xTpLiq = '1' // Tratamento  Para Manter forma Antiga de Liquidação no futuro basta tirar o q está no IF e deixar o que está no Else e eliminar fqryse2
				cQrySE1	:=fQrySE1(cCodCtr , cCodFix, 1 ) //1 Indica que a Qry seram montada para Retornar a Sum(E1_SALDO)
				cAliasSE1 	:= GetNextAlias()
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQrySE1),cAliasSE1,.F.,.T.)
				(cAliasSE1)->( DbGoTop() )
				nTotalRec 	:= (cAliasSE1)->SldTotal
				(cAliasSE1)->( DbCloseArea() )
			EndIF
		EndCase
		//---------------------------------------------------------------------------------------	//
		IF lContinua .and.  ! xTpLiq = '1' // Tratamento  Para Manter forma Antiga de Liquidação no futuro basta tirar o q está no IF e deixar o que está no Else e eliminar fqryse2
			IF  ( nQtOpagto + nQtdOrd ) > nQtEntreg											//--Validando qt da op contra a Qtd Entregue --//
				nQtAux	:=  nQtEntreg - nQtOpagto
				Help( ,, STR0011,, STR0028 + cValTochar(nQtAux) , 1, 0,) 			//"HELP"##"Quantidade Informada maior que o Saldo de Quantidade Entregue : "
				lContinua := .f.
			ElseIF xTpCtrato == CTRATOCPRA .and. nTotCPagar < nVrOPOR 					//-- Valid. Vr da ordem de Pagto Ctra o sld. de tits. a pagar da fixacao em questão --//
				Help( ,, STR0011,, STR0034 + ": " + cValTochar( nTotaPagar ) , 1, 0,) 	//"HELP"##"Valor da Ordem de Pagto. maior que o Saldo de Titulos ref. as Qtidades Entregue : "
				lContinua := .f.
			ElseIF xTpCtrato == CTRATOVND .and. ! fOg360Vld2()   //VAlida a Condicao de Pagto/Recebto
				lContinua := .f.
			ElseIF xTpCtrato == CTRATOVND .and. nTotalRec < nVrOPOR 					//-- Valid. Vr da ordem de Pagto Ctra o sld. de tits. a Receber da fixacao em questão --//
				Help( ,, STR0011,, STR0034 + ": " + cValTochar( nTotalRec ) , 1, 0,) 	//"HELP"##"Valor da Ordem de Pagto. maior que o Saldo de Titulos ref. as Qtidades Entregue : "
				lContinua := .f.
			EndIF
		ElseIF lContinua .and.  xTpLiq == '1'   // Nova forma de Liquidar
			IF  ( nQtOpagto + nQtdOrd ) > nQtEntreg											//--Validando qt da op contra a Qtd Entregue --//
				nQtAux	:=  nQtEntreg - nQtOpagto
				Help( ,, STR0011,, STR0028 + cValTochar(nQtAux) , 1, 0,) 			//"HELP"##"Quantidade Informada maior que o Saldo de Quantidade Entregue : "
				lContinua := .f.
			ElseIF xTpCtrato == CTRATOVND .and. ! fOg360Vld2()   //VAlida a Condicao de Pagto/Recebto
				lContinua := .f.
			ElseIF xVrAcresLq > 0 .or. xVrDecreLq > 0   // Indica que se tem que fazer acrescimo ou decrescimo nos titulos
				// Ou seja o calculo de ajuste da fixação em seus complementos apresentaram diferença
				//-- Para n. termos um tit. com residuo no financeiro
				nVrOPOR 	:= xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp
				nVrNoFinan  := xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp + xVrDecreLq - xVrAcresLq
				lContinua:= FTratarDif(nVrOPOR,nVrNoFinan, xVrAcresLq, xVrDecreLq)
				IF ! lContinua
					Help( , , STR0013, , STR0050 , 1, 0 ) //"AJUDA"###'OP/OR não será incluída. Há diferenças de Vrs. no titulo da Entrega x Vr. Fixado'
				EndIF
			EndIF
		EndIF
	EndIF

	If nOperation == MODEL_OPERATION_DELETE
		If cStatus <> "1"
			Help( , , STR0013, , STR0020, 1, 0 ) //"AJUDA"###"Ordem de Pagamento ja -Executada-! Entre em contato com a Tesouraria."
			lContinua := .f.
		EndIf
	EndIf
	
	If cPaisLoc = "PAR" .AND. lContinua
		If nOperation == MODEL_OPERATION_INSERT  //Valida se a operação é inclusão

			If xTpCtrato == CTRATOCPRA //Compra
				MsgRun( STR0051	, STR0055 , {|| lContinua := GeraPdComp() } ) //"Gerando Pedido de Compra"###"Movimentação"
			ElseIf xTpCtrato == CTRATOVND //Venda
				MsgRun( STR0052	, STR0055 , {|| lContinua := GeraPdVend() } ) //"Gerando Pedido de Venda"###"Movimentação"
			EndIf

		Elseif nOperation == MODEL_OPERATION_DELETE //Valida se a operação é deleção

			If xTpCtrato == CTRATOCPRA //Compra
				MsgRun( STR0053	, STR0055 , {|| lContinua := GeraPdComp() } ) //"Eliminando Pedido de Compra"###"Movimentação"
			ElseIf xTpCtrato == CTRATOVND //Venda
				MsgRun( STR0054	, STR0055 , {|| lContinua := GeraPdVend() } ) //"Eliminando Pedido de Venda"###"Movimentação"
			EndIf  
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( lContinua )

/** {Protheus.doc} ''Modelo
Funcao para gravar dados adicionais e o modelo de dados

@param: 	oModel - Modelo de Dados
@return:	lRetorno - .t. ou .f.
@author: 	Vitor Alexandre de Barba
@since: 	29/11/2014
@Uso: 		OGA360 - Ordem de Pagamento
*/
//Static Function GrvModelo( oModel )
Static Function OG360GrvMd (oModel)
	Local oView			:= FwViewActive()
	Local lRetorno 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oNN5			:= oModel:GetModel( "NN5UNICO" )
	Local oGRDNN6		:= oModel:GetModel( "NN6UNICO" )
	Local oGRDNKK		:= oModel:GetModel( "NKKUNICO" )
	Local cForma		:= "1" //oNN5:GetValue( "NN5_FORMA" )
	Local nX			:= 0
	Local nI			:= 0
	Local aSaveLines	:= {}
	Local aTitsGrdo 	:= {}    // -Irá conter a Tabela onde o Tit. foi Gerado SE1/SE2 e o Recno do Titulo.
	Local cAliasTit 	:= ''

    Private _lNN6_CHVLIQ := NN6->(ColumnPos("NN6_CHVLIQ")) > 0

	If oNN5:CanSetValue("NN5_CONPAG") .and. nOperation == MODEL_OPERATION_INSERT
		// Utilizado o valid field pois ao confirmar pela segunda vez exibia a msg "Formulário não alterado, não precisa ser salvo"
		// A funcao valid field tambem atribui valor. A diferenca eh que o formulario reconhece a alteracao.
		oView:ValidField("NN5UNICO","NN5_CONPAG",oNN5:GetValue("NN5_CONPAG"),.T.)
	EndIf


	If nOperation == MODEL_OPERATION_INSERT

		If cForma = "1"

			Begin Transaction //()
				// --- Executa processo de liquidaçaõ dos titulos gerados no Romaneio Gerando um tit d Acordo com a OPagto. --- //
				//Indica que e Compra

				If cPaisLoc <> "PAR"
					If xTpCtrato == CTRATOCPRA
						Processa({||lRetorno := fGerLiqCPR()}, STR0038	) //Liquidando titulos...
					ElseIF xTpCtrato == CTRATOVND 	//Indica que É Venda
						Processa({||lRetorno := fGerLiqVND()}, STR0038	) //Liquidando titulos...
					EndIf
					IF ! lRetorno //Algo de Errado Aconteceu
						DisarmTransaction()
					EndIf
				EndIf
				IF lRetorno 		//   -- Tudo Certo Liqd. Gerada , Atualizando Cpo de Controle Interno

					IF ! xTpLiq = '0'   //Cpo de controle Interno ( Indica que está utilizando a formula de Calc. da Fixação mais Atual )
						oNN5:LoadValue('NN5_TPLIQ' , '1')						//Indica que o tipo de Seleção Para Liqdar dos tits. é o Mais Atual

						//Atualizando Tabela do Originação NNC E NKC informando o qdo dessa fixação já se encontra em OP ou OR
						//Para o nova formula de calculo. Em Algum momento no futuro Poderei tirar o IF xTpLiq == '1' e o endif
						//somente foi colocado para garantir que o legado n. tente atualizar esses cpos pois o array stará vazio

						aSaveLines := FWSaveRows() 		// Salva a posição de todos os Grids

						If cPaisLoc <> "PAR"

							For nI := 1 To oGRDNN6:Length()
								oGrdNN6:GoLine( nI )
								IF oGrdNN6:IsDeleted()
									Loop
								EndIF
								For nX:= 1 To oGrdNKK:Length() Step 1   // Atenção Modelo da NKK e SubModelo da NN6
									oGrdNKK:GoLine( nX )
									IF oGrdNKK:IsDeleted()
										Loop
									EndIF

									cAliasAux := oGrdNKK:GetValue('NKK_TABORG') //Identificando o Alias origem NNC ou NKK
									//Encontrando o Recno da Tab. que contem o vinculo com o Titulo NNC OU NKC
									nRecnoORG := 0
									nRecnoORG := fGetRegORG( cAliasAux, oGrdNKK:GetValue('NKK_CPOORG'),oGrdNKK:GetValue('NKK_CHVORG')  )
									IF nRecnoORG > 0 
										(cAliasAux)->( DbGoto( nRecnoORG ))    //Posicionando na NNC OU NKC com Tab Origem
										Reclock(cAliasAux, .f.)
										IF Upper(Alltrim(cAliasAux)) =='NKC'
											(cAliasAux)->NKC_VRFIN += oGrdNKK:GetValue('NKK_VRLQDF')    	//Vr. Fixado em financeiro
										ElseIF Upper(Alltrim(cAliasAux)) =='NNC'
											(cAliasAux)->NNC_VRFIN  += oGrdNKK:GetValue('NKK_VRLQDF')
											(cAliasAux)->NNC_FREFIN += oGrdNKK:GetValue('NKK_FRELQD')	//Vr. do Frete 		em Financeiro
											(cAliasAux)->NNC_SEGFIN += oGrdNKK:GetValue('NKK_SEGLQD')	//Vr. do Seguro 	em Financeiro
											(cAliasAux)->NNC_DSPFIN += oGrdNKK:GetValue('NKK_DSPLQD')	//Vr. da DspAcess 	em Financeiro
										EndIF
										(cAliasAux)->( MsUnlock() )
									Else
										Help( ,, STR0013,, STR0060 + '[' + cAliasAux + ']'  , 1, 0,) //"HELP"##'O registro de origem dos tits. a serem liquidados não foi encontrado. Favor verificar. Origem :' + alias tab origem
										DisarmTransaction()   //a Transação foi Aberta no OGA360, tenho q desarmar Aqui
										Break
										lRetorno := .f.
									EndIF
								Next nX
							Next nI
							FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids
						Endif
					Else
						oNN5:SetValue('NN5_TPLIQ' , Criavar('NN5_TPLIQ',.F.))	//Tipo de Select de Titulos de forma Antiga
					EndIF

					// Abastecendo os cpos ref. acresc / decresc na liquidação
					oNN5:SetValue('NN5_VRACRE' , xVrAcresLq)
					oNN5:SetValue('NN5_VRDECR' , xVrDecreLq)

					// -- Atualizando Cpos da Fixação --
					NN8->(DbSetOrDer(1))
					IF NN8->(dBsEEK(fWXfilial('NN8') + NN8->(NN8_CODCTR+NN8_ITEMFX) ))
						RecLock('NN8', .F.)
						NN8->NN8_QTDFIN		+= oNN5:GetValue('NN5_QTDFIN')
						NN8->NN8_VLRFIN		+= oNN5:GetValue('NN5_VRFIXT')
						//Gravando qdo considera frete/seg/DspAcess na liquidacao
						NN8->NN8_FREFIN		+= oNN5:GetValue('NN5_FRETE' )
						NN8->NN8_SEGFIN		+= oNN5:GetValue('NN5_SEGURO')
						NN8->NN8_DSPFIN		+= oNN5:GetValue('NN5_DESPES')

						NN8->( MsUnlock() )
					Else
						DisarmTransaction()
						Help( ,, STR0011,, STR0061, 1, 0,) //"HELP"##'Atenção o Refistro de Fixação Selecionado. Não se encontra Mais disponivel. Verifique e Tente novamente'
						lRetorno := .f.
						MostraErro()
					EndIF
				EndIF
				
				If lRetorno
					lRetorno := FWFormCommit( oModel )
				EndIf
								
				If !lRetorno		            
		             DisarmTransaction()
		        EndIf 
			End Transaction         

		EndIf
		
		If ExistBlock("OG360NNC")
			ExecBlock("OG360NNC",.F.,.F.,{ NN5_CODOPG })
		EndIF


	ElseIf nOperation == MODEL_OPERATION_DELETE

		Begin Transaction //()			//Inicia o Controle de Transações
			// --- Executa processo de Deleção de liquidação --- //
			If cPaisLoc <> "PAR"
				If xTpCtrato == CTRATOCPRA			//Indica que e Compra
					If lRetorno
						Processa({||lRetorno := fDelLiqCpr()}, STR0039	) //"Cancelando Liquidação..."
					EndIf
				ElseIf xTpCtrato == CTRATOVND	//Indica que É Venda
					If lRetorno
						Processa({||lRetorno := fDelLiqVnd()}, STR0039	) //"Cancelando Liquidação..."
					EndIf
				EndIf

				If ! lRetorno
					DisarmTransaction()
					MostraErro()
				Else
					If ! xTpLiq = '0'	 // Indica que é a nova forma de Liquidar
						//Atualizando Tabela do Originação NNC E NKC informando o qdo dessa fixação já se encontra em OP ou OR
						//Para o nova formula de calculo. Em Algum momento no futuro Poderei tirar o IF xTpLiq == '1' e o endif
						//somente foi colocado para garantir que o legado n. tente atualizar esses cpos pois o array stará vazio

						aSaveLines := FWSaveRows() 		// Salva a posição de todos os Grids

						For nI := 1 To oGRDNN6:Length()
							oGRDNN6:GoLine( nI )
							IF oGRDNN6:IsDeleted()
								Loop
							EndIF
							For nX:= 1 To oGrdNKK:Length() Step 1   // Atenção Modelo da NKK e SubModelo da NN6
								oGrdNKK:GoLine( nX )
								IF oGrdNKK:IsDeleted()
									Loop
								EndIF

								cAliasAux := oGrdNKK:GetValue('NKK_TABORG') //Identificando o Alias origem NNC ou NKK

								IF Len( Alltrim(cAliasAux) ) = 0
									Loop
								EndIF

								//Encontrando o Recno da Tab. que contem o vinculo com o Titulo NNC OU NKC
								nRecnoORG := 0
								nRecnoORG := fGetRegORG( cAliasAux, oGrdNKK:GetValue('NKK_CPOORG'),oGrdNKK:GetValue('NKK_CHVORG')  )
								If nRecnoORG > 0 
									(cAliasAux)->( DbGoto( nRecnoORG ))    //Posicionando na NNC OU NKC com Tab Origem
									Reclock(cAliasAux, .f.)
									If Upper(Alltrim(cAliasAux)) =='NKC'
										(cAliasAux)->NKC_VRFIN -= oGrdNKK:GetValue('NKK_VRLQDF')    	//Vr. Fixado em financeiro
									ElseIF Upper(Alltrim(cAliasAux)) =='NNC'
										(cAliasAux)->NNC_VRFIN  -= oGrdNKK:GetValue('NKK_VRLQDF')
										(cAliasAux)->NNC_FREFIN -= oGrdNKK:GetValue('NKK_FRELQD')	//Vr. do Frete 		em Financeiro
										(cAliasAux)->NNC_SEGFIN -= oGrdNKK:GetValue('NKK_SEGLQD')	//Vr. do Seguro 	em Financeiro
										(cAliasAux)->NNC_DSPFIN -= oGrdNKK:GetValue('NKK_DSPLQD')	//Vr. da DspAcess 	em Financeiro
									EndIF
									(cAliasAux)->( MsUnlock() )
								Else
									DisarmTransaction()
									Help( ,, STR0013,, STR0060 + '[' + cAliasAux + ']'  , 1, 0,) //"HELP"##'O registro de origem dos tits. a serem liquidados não foi encontrado. Favor verificar. Origem :' + alias tab origem
									lRetorno := .f.
								EndIf
							Next nX
						Next nI
						FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids
					EndIf
				EndIf
			EndIF

			IF lRetorno
				// -- Atualizando Cpos do Registro de Fixação
				NN8->(DbSetOrDer(1))
				IF NN8->(dBsEEK(fWXfilial('NN8') + NN8->(NN8_CODCTR+NN8_ITEMFX) ))
					RecLock('NN8', .F.)
					NN8->NN8_QTDFIN		-= oNN5:GetValue('NN5_QTDFIN')
					NN8->NN8_VLRFIN		-= oNN5:GetValue('NN5_VRFIXT')
					//Gravando qdo considera frete/seg/DspAcess na liquidacao
					//Gravando qdo considera frete/seg/DspAcess na liquidacao
					NN8->NN8_FREFIN		-= oNN5:GetValue('NN5_FRETE' )
					NN8->NN8_SEGFIN		-= oNN5:GetValue('NN5_SEGURO')
					NN8->NN8_DSPFIN		-= oNN5:GetValue('NN5_DESPES')

					NN8->( MsUnlock() )
				Else
					DisarmTransaction()
					Help( ,, STR0011,, STR0061, 1, 0,) //"HELP"##'Atenção o Refistro de Fixação Selecionado. Não se encontra Mais disponivel. Verifique e Tente novamente'
					lRetorno := .f.
				EndIF
			EndIF

			If lRetorno
				lRetorno := FWFormCommit( oModel )
			EndIf
			If ! lRetorno 
				DisarmTransaction()
				lRetorno := .F.
			EndIf
			
		End transaction         
	EndIf

	IF lRetorno .and. nOperation == MODEL_OPERATION_INSERT
		/** Identificando os titulos para utilização em PE **/
		aTitsGrdo 	:= {}    // -Irá conter a Tabela onde o Tit. foi Gerado SE1/SE2 e o Recno do Titulo.
		IF xTpCtrato == CTRATOCPRA		//Indica que e Compra
			cAliasTit := 'SE2'
		ElseIF xTpCtrato == CTRATOVND	//Indica que É Venda
			cAliasTit := 'SE1'
		EndIF

		If cPaisLoc <> "PAR"

			ASaveLines := FWSaveRows() 		// Salva a posição de todos os Grids
			For nI := 1 To oGRDNN6:Length()
				oGRDNN6:GoLine( nI )
				IF oGRDNN6:IsDeleted()
					Loop
				EndIF

				aAdd(aTitsGrdo,{cAliasTit,oGRDNN6:GETVALUE( "NN6_RECLIQ ", nI ) } )
			nEXT nI

			FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids

		Endif

		// Ponto de entrada inserido para Manipulação dos Titulos Gerados APOS Dados Gravados, Transação Já foi encerrada //
		If ExistBlock("OG360FIM")
			ExecBlock("OG360FIM",.F.,.F.,{ aTitsGrdo })
		EndIF
	EndIF

Return( lRetorno )

/** {Protheus.doc} fOg360Vld1
valida a Qtidade informada / Calculada

@param: 	nil
@return:	lRetorno - verdadeiro ou falso
@author: 	E.Coelho
@since: 	11/08/2015
@Uso: 		OGA360
*/
Function fOg360Vld1()
	Local oModel        	:= FWModelActive()
	Local oNN5				:= oModel:GetModel( "NN5UNICO" )
	Local lRetorno			:= .t.
	Local nQtdFin			:= oNN5:GetValue( "NN5_QTDFIN" )

	Local nQtEntreg  		:=  NN8->NN8_QTDENT
	Local nQtOpagto  		:=  NN8->NN8_QTDFIN //fQtOpagto()	// -- Encontra a Qt. Que ja possuem Ordem de Pagamento
	Local nQtAux 			:= 0

	// --- Valida a Qtd.da O.Pagto.(' Para que a soma das Qtds das O.Pagtos não seja Maior que a Soma das Qtidades já Entregue --- //
	IF  ( nQtOpagto + nQtdFin ) > nQtEntreg
		nQtAux	:= nQtEntreg - nQtOpagto
		Help( ,, STR0011,, STR0028 + cValTochar(nQtAux) , 1, 0,) //"HELP"##"Quantidade Informada maior que o Saldo de Quantidade Entregue : "
		lRetorno := .f.
	EndIf

	IF !xTpLiq = '1'		// Indica que é o tipo de Liquidação Antigo Devemos tirar o If. em Algum tempo no futuro
		fNN5VRFIXT()
		Return ( lRetorno )
	EndIF

	IF lRetorno
		//Identificando se esta OPOR será a Ultima OP
		IF ( nQtOpagto + nQtdFin ) == NN8->NN8_QTDFIX
			xlUltOPOR := .t.
		Else
			xlUltOPOR := .f.
		EndIF
		//--------------------------------------------

		fNN5VRFIXT()
		SelTitLiq('NN5_QTDFIN')
	EndIF

	//Bruna - essa validação sempre estará inconsistente, pois, se for preciso selecionar duas parcelas, vai ficar retornando negativo
	/*If cPaisLoc <> "PAR"
		IF xVrMrkdo < oNN5:GetValue('NN5_VRFIXT')
			Help( ,, STR0011,, STR0062, 1, 0,) //'Dados da Ordem de Pagamento'##'Sistema não possui Vr. no financeiro suficiente sara a quantidade informada na OPOR.'
			lRetorno := .f.
		EndIf
	EndIf*/

Return( lRetorno )

/** {Protheus.doc} fOg360Vld2
Valida a Condição de Pagto/Recebimento, do modelo
e tambem do Pergunte qdo for uma Ordem de recebimento.

@param: 	nil
@return:	lRetorno - verdadeiro ou falso
@author: 	E.Coelho
@since: 	11/08/2015
@Uso: 		OGA360
*/
Function fOg360Vld2()

	Local oModel        	:= FWModelActive()
	Local oNN5				:= oModel:GetModel( "NN5UNICO" )
	Local lRetorno		:= .t.
	Local cCondicao		:= oNN5:GetValue( "NN5_CONPAG" )
	Local nParcelas     	:= 0
	aAreaAtu				:= GetArea()
	aAreaSE4				:= SE4->( GetArea() )
	aAreaNJR				:= NJR->( GetArea() )

	IF xTpCtrato == CTRATOVND
		// Para os Ctratos de Venda utilizo  Exec auto da Liquidação e ele não aceita condicao tipo 9
		// Tenho tbem q garantir que a condição gere apenas 1 parcela (senão o execauto ocorre erro),
		// pois hj a nossa Ordem de recebimento Liquida varios titulos para uma Data, Conceito de Fatura

		IF IsInCallStack('Pergunte') // Indica q veio do pergunte , tenho q ajustar cCondição
			cCondicao := MV_PAR01   	//Condicao de pagto
		EndIF

		// Verificando o Tipo da Condição
		dbSelectArea("SE4")
		SE4->( dbSetOrder(1) )
		If SE4->( dbSeek(xFilial("SE4")+cCondicao) )
			If SE4->E4_TIPO == "9"
				Help( ,, STR0011,, STR0040 , 1, 0,) //"HELP"##"Utilize uma condição de recebimento, que gere apenas uma parcela e não seja tipo 9"
				lRetorno := .f.
			Else  // Condição não tipo 9
				// Verificando se a condição escolhida retorna apenas uma Parcela, se retornar mais de uma parcela não pode
				// Porque o processo de Geração de Ordem de Pagto/Recebto  liquida varios titulos para um Titulo em uma Unica Data
				nParcelas := Len( Condicao( 10000, cCondicao, , ddatabase ) ) // Retorna o nr. de parcelas que ira ser gerado
				IF  ! nParcelas = 1
					Help( ,, STR0011,, STR0041 , 1, 0,) //"HELP"##"Escolha uma condição de recebimento que gere apenas uma parcela. Ex. condição de pagamento a vista ou 30 dias"
					lRetorno := .f.
				EndIF
			EndIF
		Else
			Help( ,, STR0011,, STR0042 , 1, 0,) //"HELP"##"Condição de pagamento invalida. Verifique a condição informada."
			lRetorno := .f.
		EndIF
	EndIF
Return( lRetorno )

/** {Protheus.doc} fOg360Vld3
valida a Qtidade informada / Calculada

@param: 	nil
@return:	lRetorno - verdadeiro ou falso
@author: 	E.Coelho
@since: 	11/08/2015
@Uso: 		OGA360
*/
Function fOg360Vld3()
	Local oModel        	:= FWModelActive()
	Local oNN5				:= oModel:GetModel( "NN5UNICO" )
	Local lRetorno			:= .t.
	Local nQtdFin			:= ''
	Local nQtEntreg  		:=  NN8->NN8_QTDENT
	Local nQtOpagto  		:=  NN8->NN8_QTDFIN //fQtOpagto()	// -- Encontra a Qt. Que ja possuem Ordem de Pagamento
	Local nQtAux 			:= 0
	Local nVrFixar			:= 0


	IF !xTpLiq = '1'		// Indica que é o tipo de Liquidação Antigo, devo tirar o if e seu conteudo em algum momento no futuro.
		fNN5QTDFIN( 0 )
		Return( .t. )
	EndIF

	SelTitLiq('NN5_VLRTOT')
	//Encontro a Qtidade q deveria ter na Fixação de Acordo com o Vr. informado pelo usuario, subtraindo as despesas de frete - Seguro - Acess.
	nVrFixar := oNN5:GetValue( "NN5_VLRTOT" ) - FwFldGet('NN5_FRETE' ) - FwFldGet('NN5_SEGURO') - FwFldGet('NN5_DESPES')

	// Se o Vr. total - Frete - DspAcess - Seguro for diferente do vr. encontrado de fixação; Recalculo a Qtidade
	IF !nVrFixar =  fwFldGet('NN5_VRFIXT')    //fwFldGet('NN5_VRFIXT') contem  vr. Fixo de acordo com o Vr. fixado dos titulos
		fNN5QTDFIN( nVrFixar )   //Encontrando a Qtidade novamente
	EndIF

	nQtdFin	:=	oNN5:GetValue( "NN5_QTDFIN" )

	// --- Valida a Qtd.da O.Pagto.(' Para que a soma das Qtds das O.Pagtos não seja Maior que a Soma das Qtidades já Entregue --- //
	If cPaisLoc <> "PAR"
		IF  ( nQtOpagto + nQtdFin ) > nQtEntreg
			nQtAux	:= nQtEntreg - nQtOpagto
			Help( ,, STR0011,, STR0063 + cValTochar(nQtdFin) + STR0064 + cValTochar(nQtAux) , 1, 0,) //"HELP"##"Quantidade Informada maior que o Saldo de Quantidade Entregue : "
			lRetorno := .f.

		/*ElseIF ! round(( xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ),TamSx3("NN5_VLRTOT")[2]) = round(oNN5:GetValue( "NN5_VLRTOT" ),TamSx3("NN5_VLRTOT")[2])
			Help( ,, STR0011,, STR0028, 1, 0,) //"HELP"##"Quantidade Informada maior que o Saldo de Quantidade Entregue : "
			lRetorno := .f.*/ //avaliar com o pessoal essa validação, tá bem estranha
		EndIf
	EndIf

Return( lRetorno )


/** {Protheus.doc} fNN5VRFIXT
Gatilho de preenchimento do Campo de Valor total

@param: 	oModel
@return:	lRetorno - verdadeiro ou falso
@author: 	Agro
@since: 	11/082015
@Uso: 		OGA360
*/
Static Function fNN5VRFIXT( )
	Local oModel  		:= FWModelActive()
	Local oNN5			:= oModel:GetModel( "NN5UNICO" )
	Local nQtOPOR		:= oNN5:GetValue( "NN5_QTDFIN" )
	Local nVlrTot		:= 0

	//---------------------------------------------------------------------------------------------------------
	// Calculo do Vr. a Fixar sempre levando em consideração o Acumulado já em OPOR
	// Evitando que no final de varios pagtos da fixação se tenha a qtidade em opor
	// batendo com a da fixação; enquanto o Vr. n. irá bater devito a arredondamento para baixo (isso eh normal)
	// Este calculo //nVlrtot := A410ARRED( NN8->NN8_VLRLQT * ( nQtdFin / NN8->NN8_QTDFIX),'D1_TOTAL' )
	// nao pode ser usado causa a dif. acima citada
	//----------------------------------------------------------------------------------------------------------
	IF ! nQtOPOR = 0
		nVlrTot 	:= A410ARRED( NN8->NN8_VLRLQT * ( nQTOPOR / NN8->NN8_QTDFIX),'D1_TOTAL' )  
	Else
		nVlrTot 	:=0
	EndIF
	
	//---------------------------------------------------------------------------------------------------
	If xTpLiq == '0'    // Indica que é a forma antiga de Liquidacao antes de 02/2016 devemos tirar o if em algum tempo no futuro
		oNN5:LoadValue('NN5_VLRTOT' ,round(nVlrtot,TamSX3("NN5_VLRTOT")[2]) )
	EndIF

	oNN5:SetValue('NN5_VRFIXT', round(nVlrtot,TamSX3("NN5_VLRTOT")[2]))
	oNN5:SetValue('NN5_VLRTOT', round(nVlrtot,TamSX3("NN5_VLRTOT")[2]))

Return ( nVlrtot )

/** {Protheus.doc} fNN5QTDFIN
Gatilho de preenchimento dqa Qtidade

@param: 	nVlrTotFix ( Vr. total Ref. a Fixação )
@return:	lRetorno - verdadeiro ou falso
@author: 	Agro
@since: 	11/082015
@Uso: 		OGA360
*/
Static Function fNN5QTDFIN( nVlrTotFix )

	Local nQtdOPOR		:= 0

	//Mantendo a forma antiga temos que retirar o q estah no if no futuro
	IF xTpLiq = '0'		// Indica que é o tipo de Liquidação Antigo  
		nQtdFin	:= A410ARRED(NN8->NN8_QTDFIX * ( fwFldGet('NN5_VLRTOT')  / NN8->NN8_VLRLQT ) ,'D1_QUANT')
		fwfldput( "NN5_QTDFIN", nQtdOPOR,,,,.t.)
		fwfldput( "NN5_VRFIXT", fwFldGet('NN5_VLRTOT'),,,,.t.)
		Return(.t.)
	EndIF

	IF  ! nVlrTotFix = 0
		nQtdOPOR	:= A410ARRED(NN8->NN8_QTDFIX * ( (nVlrTotFix + NN8->NN8_VLRFIN) / NN8->NN8_VLRLQT ) ,'NN5_QTDFIN')
		nQtdOPOR 	-= NN8->NN8_QTDFIN
	Else
		nQtdOPOR 	:= 0
	EndIF

	fwfldput( "NN5_QTDFIN", nQtdOPOR,,,,.t.)

Return ( nQtdOPOR )

/** {Protheus.doc} PosLGrdNN6
@param: 	oNN6 - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA360
*/
Static Function PosLGrdNN6( oNN6 )
	Local lRetorno	:= .T.
	Local oNN5		:= oNN6:GetModel():GetModel( "NN5UNICO" )
	Local nLinha	:= 0
	Local nX      	:= 0
	Local nPerDiv 	:= 0

	Local nVlTota 	:= Round(oNN5:GetValue( "NN5_VLRTOT" ),TamSX3("NN5_VLRTOT")[2])

	If oNN6:Length() > 0

		nLinha := oNN6:GetLine()
		For nX := 1 to oNN6:Length()
			oNN6:GoLine( nX )
			If .Not. oNN6:IsDeleted()
				nPerDiv += oNN6:GetValue( "NN6_VALOR" )
			EndIf
		Next nX
		oNN6:GoLine( nLinha )

		If nPerDiv > nVlTota
			Help(, , STR0013, , STR0025, 1, 0 ) //"Ajuda"###"O valor total não pode ser maior que o pagamento."
			lRetorno := .F.
		EndIF
	EndIf

Return( lRetorno )

/** {Protheus.doc} fTudoOK
@param: 	oNN6 - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA360
*/
Static Function fTudoOk( oNN6 )
	Local lRetorno	:= .T.
	Local oNN5		:= oNN6:GetModel():GetModel( "NN5UNICO" )
	Local nLinha	:= 0
	Local nX      	:= 0
	Local nPerDiv 	:= 0

	Local nVlTota 	:= Round(oNN5:GetValue( "NN5_VLRTOT" ),TamSX3("NN5_VLRTOT")[2])

	If oNN6:Length() > 0

		nLinha := oNN6:GetLine()
		For nX := 1 to oNN6:Length()
			oNN6:GoLine( nX )
			If .Not. oNN6:IsDeleted()
				nPerDiv += oNN6:GetValue( "NN6_VALOR" )
			EndIf
		Next nX
		oNN6:GoLine( nLinha )
		
		
		If nPerDiv > nVlTota
			Help(, , STR0013, , STR0025, 1, 0 ) //"Ajuda"###"O valor total não pode ser maior que o pagamento."
			lRetorno := .F.
		ElseIf nPerDiv < nVlTota
			Help(, , STR0013, , STR0026, 1, 0 ) //"Ajuda"###"O valor total não pode ser menor que o pagamento."
			lRetorno := .F.
		EndIf
		
		
	EndIf

Return( lRetorno )

/** {Protheus.doc} 7 ffimModelo
Função executada no Deactivate do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso 
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fFimModelo( oModel )
	Local oNN5		:= oModel:GetModel( "NN5UNICO" )
	Local oNN6		:= oModel:GetModel( "NN6UNICO" )

	SetKey (VK_F11, nil)

	IF ! xBrowseEnt = nil
		xBrowseEnt:Deactivate()
	EndIF
		
	// Setando statics Para Vr. Inicial
	xTpCtrato 	:=  Nil
	xTpLiq		:=  Nil
	xBrowseEnt	:=  Nil
	xVrMrkdo  	:= 0

	If cPaisLoc <> "PAR"
		oNN6:Deactivate()
	EndIf
	
	oNN5:Deactivate()

Return( .t. )

/** {Protheus.doc} fGerLiqCPR
Função utilizada nas O.Pagtos. de Contratos
de Compra.
Liquida os tits. gerados no recebimento do romaneio,
gerando novos titulos de acordo com a Ordem de Pagamento

@param: 	nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static Function fGerliqCPR()
	Local oModel		:= FwModelActive()
	Local oNN5			:= oModel:GetModel( "NN5UNICO" )
	Local oGrdNN6		:= oModel:GetModel( "NN6UNICO" )
	Local oGrdNKK		:= oModel:GetModel( "NKKUNICO" )

	Local lRetorno	:= .t.

	Local aAreaAtu	:= GetArea()
	Local aAreaSE2 	:= SE2->(GetArea())
	Local aSaveLines
	Local nX			:= 0
	Local aRecNewtit := {} //Array contera o recno dos titulos gerados na Liq.

	//---Vars a Passar na para OGA360LIQ ---//
	Local cOpagto		:= oNN5:GetValue("NN5_CODOPG" )
	Local cCtrato		:= oNN5:GetValue("NN5_CODCTR" )	//Ctrato
	Local cItFix		:= oNN5:GetValue("NN5_CODFIX" )	//Item de Fixacao
	Local cCPagto		:= oNN5:GetValue("NN5_CONPAG" )	//Condicao de Pagto
	Local cCodSaf		:= POSICIONE('NJR', 1, FwXfilial('NJR') + cCtrato, 'NJR_CODSAF')
	Local cTpo			:= 'OP'   						//Tipo OP, Ordem de Pagto (definido pelo Vitor)
	LOCAL cNaturez		:= ''							//Natureza de Pagamento
	Local cPrefix		:= 'OP'						//Prefixo OP, ( Definido Pelo Vitor )
	Local nMoeda		:=  oNN5:GetValue("NN5_MOEDA" )	//Moeda
	Local nVrOpag		:= 0							//Vr. que sera pago ao favorecido
	Local nVrAcres		:= 0							//Vr. a acrescer na Liquidação;
	Local nVrDecre		:= 0							//Vr. a Decrescer na Liauidação
	Local dDtVencto		:= oNN5:GetValue("NN5_DATVNC" )	//Data de vencto do tit.
	Local cForDe		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_CODFOR")	// Cod Forn. Origem
	Local cLjaDe		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_LOJFOR")	// Loja Forn. Origem
	Local cForPara		:= ''							// Favorecido
	Local cLjaPara		:= ''							//Lja do Favorecido
	Local cBco			:= ''							//Banco
	Local cAg			:= ''							//Agencia
	Local cConta		:= ''							//Conta
	Local cQry			:= ''
	Local aTitsLqdar	:={}
	Local aLinVncAux2	:={}
	Local aVncCPag		:={}
	

	//---Fim das variaveis do  OGA360LIQ ---//

	//Tratamento para Nova Forma de Sel. Tits. para Liq No futuro basta Tirar o que está no IF e deixr o Else
	IF xTpLiq != '1'
		cQry := fQrySe2(cCtrato , cItFix, 2 )  //Monta Query do SE2 Selec.. somente o Recno
		aTitsLqdar :=  Array( oGrdNN6:Length() )
	Else
		cQry:= fQrySe2New()

		//Valida se é Localizado Paraguay e bloqueia a liquidação	

		If cPaisLoc <> "PAR"
			IF .not. fTitsLqdar(  )   	// Abastecendo o Grid NKK .t. OK, .f. Houve erro na validacao do Modelo da NKK
				Return(.f.)  			
			EndIF

			// Verificando se está tudo Ok Com os tits. Para liquidar
			IF ! fTitsLqdOK(  )
				Return(.f.)
			EndIf
		EndIf

		oView			:= FwViewActive()
		oView:Refresh('VIEW_NKK')
	EndIF

	// --- Lendo o Grid de Favorecidos para identificar : nVrOpag  , cFor, cLja )
	aSaveLines := FWSaveRows() // Salva a posição de todos os Grids
		For nX := 1 to oGrdNN6:Length()
			oGrdNN6:GoLine( nX )
			If .Not. oGrdNN6:IsDeleted()
				cNaturez	:=	oGrdNN6:GetValue("NN6_NATFIN")
				nVrOpag		:=	oGrdNN6:GetValue("NN6_VALOR ")
				cForPara	:=	Posicione("NJ0",1, FwxFilial("NJ0") + oGrdNN6:GetValue("NN6_CODFAV") + oGrdNN6:GetValue("NN6_LOJFAV") , "NJ0_CODFOR")	
				cLjaPara	:=	Posicione("NJ0",1, FwxFilial("NJ0") + oGrdNN6:GetValue("NN6_CODFAV") + oGrdNN6:GetValue("NN6_LOJFAV") , "NJ0_LOJFOR")	
				cBco		:=	oGrdNN6:GetValue("NN6_CODBCO")
				cAg			:=	oGrdNN6:GetValue("NN6_CODAGE")
				cConta		:=	oGrdNN6:GetValue("NN6_CODCTA")

				IF nX == oGrdNN6:Length() 			// Indica que é o ultima Liq. que será feita nessa OP
					nVrAcres		:= xVrAcresLq
					nVrDecre		:= xVrAcresLq
				EndIF

				lOk := .t.
				lOK := OGA360LIQ(cCtrato, cItFix, cCPagto, cTpo, cNaturez, cPrefix, nMoeda, nVroPag, dDtVencto, cForDe, cLjaDe, cForPara, cLjaPara, cBco, cAg, cConta,cQry,oGrdNKK,xtpLiq,nVrAcres,nVrDecre )
				IF !lOK   // Não conseguiu gerar a Liquidação
					// Transação foi disarmada no OGA360LIQ DisarmTransaction()
					Break
					lRetorno := .f.
				EndIF

				oGrdNN6:SetValue( "NN6_RECLIQ", SE2->( Recno() ) )  //--- Armazena o Recno do Novo Titulo da SE2
                If _lNN6_CHVLIQ
                    oGrdNN6:SetValue( "NN6_CHVLIQ", SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
                EndIf
				aAdd( aRecNewtit , {SE2->( Recno() ),oGrdNN6:Getvalue(' NN6_ITEM ')} )	//Guardando os Recnos, e os respectivos itens que o gerou Gerados para Manutenção Posterior

			EndIf
		Next nX

	FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids

	If __lLib1220
	
		aVncCPag := {}
	
		If lRetorno
			For nX := 1 to Len( aRecNewtit )
				SE2->(dbGoTo( aRecNewtit[nX,1 ] ))
			
			    aLinVncAux2 := {}
												
				aadd( aLinVncAux2, { "N8M_FILIAL"    	, PadR( SE2->E2_FILIAL , 	TamSX3( "N8M_FILIAL" )[1] )   		} )
				aadd( aLinVncAux2, { "N8M_FILORI"    	, PadR( SE2->E2_FILORIG , 	TamSX3( "N8M_FILORI" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_PREFIX"    	, PadR( SE2->E2_PREFIXO , 	TamSX3( "N8M_PREFIX" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_NUM"    		, PadR( SE2->E2_NUM 	 , 	TamSX3( "N8M_NUM"    )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_PARCEL"    	, PadR( SE2->E2_PARCELA , 	TamSX3( "N8M_PARCEL" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_TIPO"    		, PadR( SE2->E2_TIPO	 , 	TamSX3( "N8M_TIPO"   )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_FORNEC"    	, PadR( SE2->E2_FORNECE , 	TamSX3( "N8M_FORNEC" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_LOJA"    		, PadR( SE2->E2_LOJA	 , 	TamSX3( "N8M_LOJA"   )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_CODCTR"    	, PadR( cCtrato		 , 		TamSX3( "N8M_CODCTR" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_CODSAF"	    , PadR( cCodSaf		 , 		TamSX3( "N8M_CODSAF" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_CODROM"    	, PadR( ''			 , 		TamSX3( "N8M_CODROM" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_ITEROM"   	, PadR( ''			 , 		TamSX3( "N8M_ITEROM" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_ITEMFX"   	, PadR( ''			 , 		TamSX3( "N8M_ITEMFX" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_ORPGRC"    	, PadR( cOpagto			 , 	TamSX3( "N8M_ORPGRC" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_ITPGRC"    	, PadR( aRecNewtit[ nX,2 ] ,TamSX3( "N8M_ITPGRC" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_ORDTRA"    	, PadR( ''				 , 	TamSX3( "N8M_ORDTRA" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_CODNGC"   	, PadR( ''				 , 	TamSX3( "N8M_CODNGC" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_VERNGC"   	, PadR( ''				 , 	TamSX3( "N8M_VERNGC" )[1] )  		} )
				aadd( aLinVncAux2, { "N8M_ORIGEM"    	, PadR( 'OGA360'		  , TamSX3( "N8M_ORIGEM" )[1] )  		} )
				aAdd( aLinVncAux2, { "N8M_HISTOR"    	, PadR( FWI18NLang("OGA360","STR0001",001) , TamSX3( "N8M_HISTOR" )[1] )  				} )
				aAdd(aVncCPag,aLinVncAux2)
				
			Next nX
			
			IF  Len( aVncCPag ) > 0
				fAgrVncPag (aVncCPag, 3 )  	//Incluir
			EndIF
		EndIf
		
	ElseIf SE2->(ColumnPos("E2_CTROG")) > 0
	
	aVncCPag := {}
	
		If lRetorno
			For nX := 1 to Len( aRecNewtit )
			SE2->(dbGoTo( aRecNewtit[nX][1]))
			RecLock('SE2', .f.)
			SE2->E2_CTROG 	:= cCtrato
			SE2->E2_ARMFIX	:= cItFix
			SE2->E2_CODSAF	:= cCodSaf
			SE2->( MsUnlock())
			
			Next nX
		EndIf
	EndIf

	RestArea( aAreaSE2 )
	RestArea( aAreaAtu )

Return( lRetorno )


/** {Protheus.doc} fGerLiqVND
Função utilizada para liquidar os tits. de contas a Receber
@param: 	nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static Function fGerliqVND()
	Local oModel		:= FwModelActive()
	Local oNN5			:= oModel:GetModel( "NN5UNICO" )
	Local oGrdNN6		:= oModel:GetModel( "NN6UNICO" )
	Local oGrdNKK		:= oModel:GetModel( "NKKUNICO" )

	Local aAreaAtu		:= GetArea()
	Local aAreaSE1 		:= SE1->(GetArea())
	Local aSaveLines	:= {}
	Local nX			:= 0

	//---Vars Para Gerar Liquidação ---//
	Local cCtrato		:= oNN5:GetValue("NN5_CODCTR" )			//Ctrato
	Local cItFix		:= oNN5:GetValue("NN5_CODFIX" )			//Item de Fixacao
	Local cCond			:= oNN5:GetValue("NN5_CONPAG" )			//Condicao de Pagto
	Local cCodSaf		:= POSICIONE('NJR', 1, FwXfilial('NJR') + cCtrato, 'NJR_CODSAF')
	Local cTpo			:= 'OR'   							//Tipo OR, Ordem de Recebto (definido pelo Vitor)
	LOCAL cNaturez		:= ''								//Natureza de Pagamento
	Local cPrefix		:= 'OR'								//Prefixo OR, ( Definido Pelo Vitor )
	Local nMoeda		:=  oNN5:GetValue("NN5_MOEDA" )			//Moeda
	Local nVrOpag		:= 0								//Vr. que sera pago ao favorecido
	Local nVrAcres		:= 0								// Vr. a Acresc. na Liquidação
	Local nVrDecre		:= 0								// vr. decrescer na Liquidação

	Local dDtVencto		:= oNN5:GetValue("NN5_DATVNC" )		//Data de vencto do tit.

	Local cCliDe		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODCLI")	// Cod Forn. Origem
	Local cLjaDe		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJCLI")	// Loja Forn. Origem

	Local cCLIPara		:= ''							// Favorecido
	Local cLjAPara		:= ''							//Lja do Favorecido
	Local cBco			:= ''							//Banco
	Local cAg			:= ''							//Agencia
	Local cConta		:= ''							//Conta
	Local cQry			:= ''
	Local cNrLiquid		:= Criavar('E1_NUMLIQ', .F.)
	Local lContinua  	:= .t.
	Local nRecLiquid	:= 0
	//---Fim Vars. Para Gerar Liquidação---//

	procregua(0)   //Tratanto Requa de processamento

	//Tratamento para Nova Forma de Sel. Tits. para Liq No futuro basta Tirar o que está no IF e deixr o Else
	IF xTpLiq != '1'
		cQry := fQrySe1(cCtrato , cItFix, 2 )//Monta Query do SE1 somente o Recno
		//		aTitsLqdar :=  Array( oGrdNN6:Length() )
	Else

		//Valida se é Localizado Paraguay e bloqueia a liquidação
		If cPaisLoc <> "PAR"
			cQry:= fQrySe1New()
			IF .not. fTitsLqdar(  )   	// Abastecendo o Grid NKK .t. OK, .f. Houve erro na validacao do Modelo da NKK
				Return(.f.)  			
			EndIF


			// Verificando se está tudo Ok Com os tits. Para liquidar
			IF ! fTitsLqdOK(  )
				Return(.f.)
			EndIF
		Endif
	EndIF
	// Fim Tratamento para Nova Forma de Sel. Tits. para Liq No futuro basta Tirar o que está no IF e deixr o Else

	aSaveLines := FWSaveRows() // Salva a posição de todos os Grids

	Begin Transaction 
		// --- Lendo o Grid de Favorecidos para identificar : nVrOpag  , cFor, cLja , Gera a Liquidacao por favorecido
		For nX := 1 to oGrdNN6:Length()
			oGrdNN6:GoLine( nX )

			If oGrdNN6:IsDeleted() //Deletados
				Loop
			EndIF

			cNaturez	:=	oGrdNN6:GetValue("NN6_NATFIN")
			nVrOpag		:=	oGrdNN6:GetValue("NN6_VALOR ")
			cCliPara	:=	Posicione("NJ0",1,FwxFilial("NJ0")+oGrdNN6:GetValue("NN6_CODFAV") + oGrdNN6:GetValue("NN6_LOJFAV"),"NJ0_CODCLI") 
			cLjaPara	:=	Posicione("NJ0",1,FwxFilial("NJ0")+oGrdNN6:GetValue("NN6_CODFAV") + oGrdNN6:GetValue("NN6_LOJFAV"),"NJ0_LOJCLI") 
			cBco		:=	oGrdNN6:GetValue("NN6_CODBCO")
			cAg			:=	oGrdNN6:GetValue("NN6_CODAGE")
			cEmit 		:=''
			cNrLiquid	:= cPrefix + oNN5:GetValue("NN5_CODOPG")

			IF nX == oGrdNN6:Length() 			// Indica que é o ultima Liq. que será feita nessa OP
				nVrAcres		:= xVrAcresLq
				nVrDecre		:= xVrAcresLq
			EndIF

			lOk := .t.
			lOK :=  OG360LQVND ( @cNrLiquid, cCond, cCliDe, cLjaDe,cCliPara,cLjaPara, cTpo, cNaturez, nMoeda,cPrefix, cBco,cAg,cConta,dDtVencto,cEmit,nVrOpag,nVrAcres,nVrDecre,cQry,oGrdNKK,@nRecLiquid )

			IF !lOK   // Não conseguiu gerar a Liquidação
				// Transação foi disarmada no OGA360LIQ DisarmTransaction()
				lContinua := .f.
				Exit
			EndIF

			//Encontrando qual é o registro recno da Liquidação
			SE1->(dbSetOrder(15)) //E1_FILIAL+E1_NUMLIQ
			SE1->( DbGoTo( nRecLiquid ) )
			If Alltrim(SE1->( E1_NUM )) = Alltrim(cNrLiquid )
				oGrdNN6:SetValue( "NN6_RECLIQ", nRecLiquid )   //Vinculando NN6 com a Liquidação
                If _lNN6_CHVLIQ
                    oGrdNN6:SetValue( "NN6_CHVLIQ", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
                EndIf
                
				//Ajustando Cpos ref. ao negocio
				 If SE1->(ColumnPos("E1_CTROG")) > 0
					RecLock('SE1', .f. )
					SE1->E1_CTROG 	:= cCtrato
					SE1->E1_ARMFIX	:= cItFix
					SE1->E1_CODSAF	:= cCodSaf
					SE1->( MsUnlock())
				EndIf
			Else
				DisarmTransaction()
				lContinua := .f.
				Help( ,, STR0011,, STR0044 , 1, 0, ) //"HELP"##"Não foram encontrados titulos a liquidar.
				Exit
			EndIF
		Next nX

	end transaction 

	FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids

	RestArea( aAreaSE1 )
	RestArea( aAreaAtu )

	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()

Return( lContinua )


/** {Protheus.doc} fDelLiqCpr
Cancela Liquidações ref. a contratos de compras

@param: 	nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static Function fDelLiqCPR()
	Local oModel		:= FwModelActive()
	//	Local oNN5			:= oModel:GetModel( "NN5UNICO" )
	Local oGrdNN6		:= oModel:GetModel( "NN6UNICO" )
	Local lRetorno	:= .t.

	Local aAreaAtu	:= GetArea()
	Local aAreaSE2 	:= SE2->(GetArea())
	Local aSaveLines
	Local nX			:= 0
	Local aVncCPag		:= {}
	Local aLinVncAux2	:= {}
	

	procregua(0)   //Tratanto Requa de processamento

	//--- Verifica se data do movimento n„o ‚ menor que data limite de movimentacao no financeiro ---//
	If !DtMovFin()
		lRetorno := .f.
	EndIf

	IF lRetorno
		// --- Verificando se as Liquidações podem ser Canceladas 						--- //
		// --- Lendo o Grid de Favorecidos para identificar : nVrOpag  , cFor, cLja )--- //
		aSaveLines := FWSaveRows() // Salva a posição de todos os Grids
		For nX := 1 to oGrdNN6:Length()
			oGrdNN6:GoLine( nX )

			IIf ( Select("TRB") != 0, TRB->( dbCloseArea() ) , nil ) // --- Trb se Encontra na rotina Padrao A565filtra() ---//

			If .Not. oGrdNN6:IsDeleted()
				lRetorno	:=.f.
				
                If _lNN6_CHVLIQ
                    SE2->(dbSetOrder(1))
                    If !SE2->(dbSeek(oGrdNN6:GetValue("NN6_CHVLIQ")))
                        lRetorno := .f.
					    Exit
                    EndIf
                else
                    SE2->(dbGoTo( FWFLDGET("NN6_RECLIQ ", nX) )) // Verificando a Liquidação q foi gerada    
                    nRecno := SE2->( Recno() ) // --- Verifica o Recno posicionado, Pois o Dbgoto() , retorno é sempre nulo ---//
                    IF ! nRecno =  FWFLDGET("NN6_RECLIQ ", nX) // --- Não encontrou o recno passado ---//
					    lRetorno := .f.
					    Exit
                    EndIf
                EndIf                
				
				If A565Filtra( SE2->E2_NUMLIQ )
					lRetorno := .t.
				Else
					lRetorno := .f.
				EndIF
			EndIF
		Next nX
		FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids
	EndIF

	// --- Se lRetorno == .f. n. é possivel cancelar a Liquidação --- //
	IF lRetorno

		// --- Chamando Rotina de Cancelamento de Liquidações ---//
		aSaveLines := FWSaveRows() // Salva a posição de todos os Grids
		For nX := 1 to oGrdNN6:Length()
			oGrdNN6:GoLine( nX )

			IIf ( Select("TRB") != 0, TRB->( dbCloseArea() ) , nil ) // --- Trb se Encontra na rotina Padrao A565filtra() ---//
			//pode abrir na verificação.
			If .Not. oGrdNN6:IsDeleted()
				If _lNN6_CHVLIQ
                    SE2->(dbSetOrder(1))
                    If !SE2->(dbSeek(oGrdNN6:GetValue("NN6_CHVLIQ")))
                        lRetorno := .f.
					    Exit
                    EndIf
                else
                    SE2->(dbGoTo( FWFLDGET("NN6_RECLIQ ", nX) )) // Verificando a Liquidação q foi gerada
                EndIf
				
				If __lLib1220
					
					aLinVncAux2 := {}
					aadd( aLinVncAux2, { "N8M_FILIAL"	, PadR( SE2->E2_FILIAL ,  TamSX3( "N8M_FILIAL" )[1] )		} )
					aadd( aLinVncAux2, { "N8M_FILORI"	, PadR( SE2->E2_FILORIG , TamSX3( "N8M_FILORI" )[1] )		} )
					aadd( aLinVncAux2, { "N8M_PREFIX"	, PadR( SE2->E2_PREFIXO , TamSX3( "N8M_PREFIX" )[1] )		} )
					aadd( aLinVncAux2, { "N8M_NUM"		, PadR( SE2->E2_NUM ,     TamSX3( "N8M_NUM" )[1] 	)		} )
					aadd( aLinVncAux2, { "N8M_PARCEL"	, PadR( SE2->E2_PARCELA , TamSX3( "N8M_PARCEL" )[1] )		} )
					aadd( aLinVncAux2, { "N8M_TIPO"		, PadR( SE2->E2_TIPO ,    TamSX3( "N8M_TIPO" )[1]   )		} )
					aadd( aLinVncAux2, { "N8M_FORNEC"	, PadR( SE2->E2_FORNECE , TamSX3( "N8M_FORNEC" )[1] )		} )
					aadd( aLinVncAux2, { "N8M_LOJA"    	, PadR( SE2->E2_LOJA ,    TamSX3( "N8M_LOJA" )[1] 	) 		} )						

				aAdd(aVncCPag,aLinVncAux2)
				EndIf

				OGA360LIQC( 'SE2', nil, 4 ) //Chamando a função de Cancela
				
			EndIF
		Next nX
		FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids
	EndIF
	
	IF  Len( aVncCPag ) > 0 .AND. __lLib1220
		fAgrVncPag (aVncCPag, 5 )  	//Excluir
	EndIF

	RestArea( aAreaSE2 )
	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} fDelLiqVnd
Cancela Liquidações ref. a contratos de Venda

@param: 	nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static Function fDelLiqVND()
	Local oModel		:= FwModelActive()
	Local oGrdNN6		:= oModel:GetModel( "NN6UNICO" )
	Local lRetorno	:= .t.

	Local aAreaAtu		:= GetArea()
	Local aAreaSE1 		:= SE1->(GetArea())
	Local aSaveLines	:= {}
	Local nX			:= 0
	Local cLiqCan		:= CRIAVAR('E1_NUM',.F.)

	//-- Vars. Ctrole ExecAuto -- //
	Local	lRetFina460 := .t.	// Retorno do Fina460
	Private	lMsHelpAuto := .t.  // se .t. direciona as mensagens de help
	Private	lMsErroAuto := .f.	//necessario a criacao, pois sera

	procregua(0)   //Tratanto Requa de processamento

	//--- Verifica se data do movimento n„o ‚ menor que data limite de movimentacao no financeiro ---//
	If !DtMovFin()
		lRetorno 		:= .f.
	EndIf

	// --- Chamando Rotina de Cancelamento de Liquidações ---//
	IF lRetorno
		aSaveLines := FWSaveRows() 									// Salva a posição de todos os Grids
		For nX := 1 to oGrdNN6:Length()
			oGrdNN6:GoLine( nX )

			IF .Not. oGrdNN6:IsDeleted()
				If _lNN6_CHVLIQ
                    SE1->(dbSetOrder(1))
                    If !SE1->(dbSeek(oGrdNN6:GetValue("NN6_CHVLIQ")))
                        lRetorno := .f.
					    Exit
                    EndIf
                else
                    SE1->(dbGoTo( oGrdNN6:GetValue("NN6_RECLIQ ") )) 		// Verificando a Liquidação q foi gerada
                EndIf

				cLiqCan := SE1->E1_NUMLIQ
				lRetFina460 :=FINA460( , , , 5, , cLiqCan )			//Cancelamento da liquidacao

				IF lMsErroAuto
					DisarmTransaction()
					lRetorno := .f.
					Mostraerro()
					Exit
				ElseIF ! lRetFina460
					DisarmTransaction()
					lRetorno := .f.
					Help( ,, STR0011,, STR0043, 1, 0, ) //"HELP"##Não foi possível gerar liquidação.
					Exit
				EndIF
			EndIF
		Next nX
		FWRestRows( aSaveLines ) 									//Restaura a posição anterior dos Grids
	EndIF
	
	RestArea( aAreaSE1 )
	RestArea( aAreaAtu )

Return( lRetorno )

/** {Protheus.doc} fQrySE2
Função que Retorna a Qry montada que será executada
para gerar a Liquição
@param: 	Liquidação a Cancelar Caso já exista Uma
@return:	cQry
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static function fQrySE2NEW()
	Local cQry 		:= ''
	Local cFor		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODFOR")	// Cod Forn.
	Local cLja		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJFOR")	// Loja Forn.

	/*/
	*-----------------------------------------------------------------------------------------------------------
	!	Monta a Qry q será executado na Liquidação da SE1																!
	!	Lista somente os registros da SE1 que o documento gerador se encontra na NNC (Vinc. Romaneio c Fixação) e!
	!	na NKC doctos de complemento da NNC																				!
	*----------------------------------------------------------------------------------------------------------*
	/*/
	//-- Select da NNC (Entregas da Fixação )
	cQry:= "SELECT "
	// Cpos NNC
	cQry+=  	" CASE WHEN NNC.NNC_VRFIN = CAST((NNC.NNC_VRENPF-NNC.NNC_VLIMPF) AS NUMERIC(18,2)) THEN 'Z' "
	cQry+=		" ELSE 'A'	"
	cQry+=      " END AS ORDEM, "
	cQry+=      " NNC.R_E_C_N_O_ AS RECNOORIG, "
	cQry+= 		"'NNC' AS TABELA,'A' AS SEQDEBAIXA,"
	cQry+=      " NNC.NNC_CODCTR AS CONTRATO,"
	cQry+= 		" NNC.NNC_CODROM AS ROMANEIO,NNC.NNC_ITEROM AS ITEMROMAN,NNC.NNC_ITEMFX AS FIXACAOITE, ' ' AS ITSEQ, "
	cQry+= 		" NNC.NNC_QTDENT AS QTENTREGA, NNC.NNC_QTDFIX AS QTFIXDA, NNC.NNC_VRFIN AS VRFIX_OPOR, NNC.NNC_VRENPF-NNC.NNC_VLIMPF - NNC_DECFIN + NNC_ACRFIN AS VRTITFIXDO,"
	// Cpos Ref. ao Frete/Seguro/Despesas Acessorias
	cQry+=      " NNC.NNC_VLFRET AS FRETE		,NNC.NNC_VLSEGU AS SEGURO		,NNC.NNC_VLDESP AS DESPESA	,"
	cQry+=      " NNC.NNC_FREFIN AS VRFRE_OPOR,NNC.NNC_SEGFIN AS VRSEG_OPOR,NNC.NNC_DSPFIN AS VRDSP_OPOR,"
	//Cpos SF1
	cQry+=		" SF1.F1_PREFIXO AS TITPREFIXO, SF1.F1_DUPL AS DUPLNUM,"
	//Cpos SE2
	cQry+= 		" SE2.*, "
    cQry+=   " (SELECT COUNT(*) " +;
	            " FROM " + RetSqlName('SE2') + " SE2_B  "+;
		       " WHERE SE2_B.E2_FILIAL  = SE2.E2_FILIAL "+;
		        "  AND SE2_B.E2_PREFIXO = SE2.E2_PREFIXO"+;
			     " AND SE2_B.E2_NUM     = SE2.E2_NUM    "+;
			     " AND SE2_B.D_E_L_E_T_ != '*'          "+;
		         " ) QTD_PARCELA "
	// Cpo Utilizado Pela rotina de Liquidação , Não Retirar
	cQry+= 	"FROM " + RetSqlName('NNC') + ' NNC '
	// Join com SF1
	cQry+= 	" LEFT JOIN " + RetSqlName('SF1') + ' SF1 '
	cQry+= 		" ON  SF1.F1_FILIAL  = '" + FwxFilial('SF1') + "' "
	cQry+=		" AND SF1.F1_FORNECE = '" + cFor + "'"
	cQry+=		" AND SF1.F1_LOJA    = '" + cLja + "'"
	cQry+=	    " AND SF1.F1_DOC     = NNC.NNC_NUMDOC"
	cQry+=		" AND SF1.F1_SERIE   = NNC_SERDOC"
	cQry+=		" AND SF1.D_E_L_E_T_ != '*' "
	// Join com SE2
	cQry+= 	"LEFT JOIN " +  RetSqlName('SE2') + ' SE2 '
	cQry+= 		" ON  SE2.E2_FILIAL = '" + FwxFilial('SE2') + "' "
	cQry+=		" AND SE2.E2_PREFIXO = SF1.F1_PREFIXO"
	cQry+=		" AND SE2.E2_NUM = SF1.F1_DUPL"
	cQry+= 		" AND SE2.E2_FORNECE = SF1.F1_FORNECE"
	cQry+=		" AND SE2.E2_LOJA    = SF1.F1_LOJA"
	cQry+=		" AND SE2.E2_TIPO IN ('NF','NFE')"
	cQry+=		" AND SE2.E2_NUMLIQ = ' ' "
	cQry+=		" AND SE2.D_E_L_E_T_ != '*' "
	//Clausula Where
	cQry+= " WHERE NNC.NNC_FILIAL  = '" + fwXfilial('NNC') + "'"
	cQry+= "	AND NNC.NNC_CODCTR = '" + NN8->NN8_CODCTR + "'"
	cQry+= "	AND NNC.NNC_ITEMFX = '" + NN8->NN8_ITEMFX + "'"
	//    cQry+= " 	AND NNC.NNC_VRFIN != NNC.NNC_VRENPF-NNC.NNC_VLIMPF"
	cQry+= "	AND NNC.D_E_L_E_T_ != '*' "

	// Aplicando Union
	cQry += " UNION ALL "

	// Select da NKC Tipo de Docto = 1 Nf. DE ENTRADA DE COMPL. DE PRECO

	cQry += "SELECT CASE WHEN NKC.NKC_VRFIN = CAST((NKC.NKC_VRTOT - NKC_VRIMP) AS NUMERIC(18,2)) THEN 'Z'	ELSE 'A'	END AS ORDEM, NKC.R_E_C_N_O_ AS RECNOORIG, "
	//--Cpos NKC
	cQry += 	" 'NKC' AS TABELA, 'B' AS SEQDEBAIXA, NKC.NKC_CODCTR AS CONTRATO,NKC.NKC_CODROM AS ROMANEIO,"
	cQry += 	" NKC.NKC_ITEROM AS ITEMROMAN,NKC.NKC_ITEMFX AS FIXACAOITE,NKC.NKC_ITEM  AS ITSEQ,"
	cQry +=     " 0     AS QTENTREGA, 0  AS QTFIXDA, NKC.NKC_VRFIN AS VRFIX_OPOR, "
	cQry += 	" NKC.NKC_VRTOT - NKC_VRIMP  AS VRTITFIXDO,"

	//Cpos Ref. Frete/Seguro/Despesa ( A NKC não possui )
	cqry +=     " 0 AS FRETE 		,0 AS SEGURO		,0 AS DESPESA		, " // NKC N. possui frete/seguro/despesa
	cQry+=      " 0 AS VRFRE_OPOR	,0 AS VRSEG_OPOR	,0 AS VRDSP_OPOR	, " // NKC N. possui frete/seguro/despesa

	//Cpos SF1
	cQry +=		" SF1.F1_PREFIXO AS TITPREFIXO, SF1.F1_DUPL AS DUPLNUM,"
	//Cpos SE2
	cQry += 	" SE2.*, "
    cQry+=   " (SELECT COUNT(*) " +;
	            " FROM " + RetSqlName('SE2') + " SE2_B  "+;
		       " WHERE SE2_B.E2_FILIAL  = SE2.E2_FILIAL "+;
		        "  AND SE2_B.E2_PREFIXO = SE2.E2_PREFIXO"+;
			     " AND SE2_B.E2_NUM     = SE2.E2_NUM    "+;
			     " AND SE2_B.D_E_L_E_T_ != '*'          "+;
		         " ) QTD_PARCELA "
	cqry +=  " FROM " + RetSqlName('NKC') + ' NKC '
	//Join SF1
	cQry += " LEFT JOIN " + RetSqlName('SF1') + ' SF1 '
	cQry +=		"  ON SF1.F1_FILIAL = '" + fWXfilial('SF1') + "' "
	cQry += 	" AND SF1.F1_FORNECE = '" + cFor + "'"
	cQry += 	" AND SF1.F1_LOJA = '" + cLja + "'"
	cQry += 	" AND SF1.F1_DOC = NKC.NKC_DOCTO "
	cQry += 	" AND SF1.F1_SERIE = NKC_SERIE "
	cQry += 	" AND SF1.D_E_L_E_T_ != '*' ""
	//Join SE2
	cQry +=	" LEFT JOIN " + RetSqlName('SE2') + ' SE2 '
	cQry +=		" ON SE2.E2_FILIAL = '" + fWxfilial('SE2') + "' "
	cQry +=		" AND SE2.E2_PREFIXO = SF1.F1_PREFIXO"
	cQry += 	" AND SE2.E2_NUM = SF1.F1_DUPL"
	cQry +=		" AND SE2.E2_FORNECE = SF1.F1_FORNECE"
	cQry +=		" AND SE2.E2_LOJA  = SF1.F1_LOJA"
	cQry += 	" AND SE2.E2_TIPO IN ('NF','NFE')"
	cQry +=		" AND SE2.E2_NUMLIQ = ' '
	cQry += 	" AND SE2.D_E_L_E_T_ != '*'"
	//Clausula Where
	cQry +=	" WHERE NKC.NKC_FILIAL = '" + fWxfilial('NKC') + "'"
	cQry += 	" AND NKC.NKC_TPDOC	IN ('1','7') "			//1= "Nf. compl. de prc  de compra" e 7 = "Nf. Complemento/Produtor Vinculada"
	cQry +=		" AND NKC.D_E_L_E_T_ != '*'"
	cQry +=		" AND NKC.NKC_CODCTR = '" + NN8->NN8_CODCTR + "'"
	cQry +=		" AND NKC.NKC_ITEMFX = '" + NN8->NN8_ITEMFX + "'"
	//cQry += 	" AND NKC_VRFIN != (NKC.NKC_VRTOT - NKC_VRIMP)"
	cQry +=		" AND NKC.D_E_L_E_T_ != '*'"

	//--Ordenando a Query
	cQry += " ORDER BY  ORDEM,ROMANEIO,SEQDEBAIXA,RECNOORIG"

	cQry := ChangeQuery( cQry )

Return( cqry )


/** {Protheus.doc} fQrySE1New
Função que Retorna a Qry montada que será executada
para gerar a Liquição
@param: 	Liquidação a Cancelar Caso já exista Uma
@return:	cQry
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static function fQrySE1NEW(  )
	Local cQry 		:= ''
	Local cCli		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODCLI")	// Cod Cliente.
	Local cLja		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJCLI")	// Loja Cliente.

	/*/
	*-----------------------------------------------------------------------------------------------------------
	!	Monta a Qry q será executado na Liquidação da SE1																!
	!	Lista somente os registros da SE1 que o documento gerador se encontra na NNC (Vinc. Romaneio c Fixação) e!
	!	na NKC doctos de complemento da NNC																				!
	*----------------------------------------------------------------------------------------------------------*
	/*/
	//-- Select da NNC (Entregas da Fixação )
	cQry:= "SELECT "
	cQry+= "CASE WHEN NNC.NNC_VRFIN = CAST((NNC.NNC_VRENPF-NNC.NNC_VLIMPF) AS NUMERIC(18,2)) THEN 'Z'	ELSE 'A'	END AS ORDEM,	NNC.R_E_C_N_O_ AS RECNOORIG, "
	// Cpos NNC
	cQry+= 		"'NNC' AS TABELA,'A' AS SEQDEBAIXA, NNC.NNC_CODCTR AS CONTRATO,"
	cQry+= 		" NNC.NNC_CODROM AS ROMANEIO,NNC.NNC_ITEROM AS ITEMROMAN,NNC.NNC_ITEMFX AS FIXACAOITE, ' ' AS ITSEQ, "
	cQry+=		" NNC.NNC_QTDENT AS QTENTREGA, NNC.NNC_QTDFIX AS QTFIXDA, "
	cQry+= 		" NNC.NNC_VRFIN AS VRFIX_OPOR, NNC.NNC_VRENPF-NNC.NNC_VLIMPF-NNC_DECFIN+NNC_ACRFIN AS VRTITFIXDO,"
	// Cpos Ref. ao Frete/Seguro/Despesas Acessorias
	cQry+=      " NNC.NNC_VLFRET AS FRETE		,NNC.NNC_VLSEGU AS SEGURO		,NNC.NNC_VLDESP AS DESPESA	,"
	cQry+=      " NNC.NNC_FREFIN AS VRFRE_OPOR,NNC.NNC_SEGFIN AS VRSEG_OPOR,NNC.NNC_DSPFIN AS VRDSP_OPOR,"
	//Cpos SF2
	cQry+=		" SF2.F2_PREFIXO TITPREFIXO, SF2.F2_DUPL AS DUPLNUM,"
	//Cpos SE1
	cQry+= 		" SE1.*, "
    cQry+=   " (SELECT COUNT(*) " +;
	            " FROM " + RetSqlName('SE1') + " SE1_B  "+;
		       " WHERE SE1_B.E1_FILIAL  = SE1.E1_FILIAL "+;
		        "  AND SE1_B.E1_PREFIXO = SE1.E1_PREFIXO"+;
			     " AND SE1_B.E1_NUM     = SE1.E1_NUM    "+;
			     " AND SE1_B.D_E_L_E_T_ != '*'          "+;
		         " ) QTD_PARCELA, "
	cQry+=		" SE1.R_E_C_N_O_  AS RECNO "					//Utilizado pela rotina de liquidação n. retirar
	cQry+= 	"FROM " + RetSqlName('NNC') + ' NNC '
	// Join com SF2
	cQry+= 	" LEFT JOIN " + RetSqlName('SF2') + ' SF2 '
	cQry+= 		" ON  SF2.F2_FILIAL  = '" + FwxFilial('SF2') + "' "
	cQry+=		" AND SF2.F2_CLIENTE = '" + cCli + "'"
	cQry+=		" AND SF2.F2_LOJA    = '" + cLja + "'"
	cQry+=	    " AND SF2.F2_DOC     = NNC.NNC_NUMDOC"
	cQry+=		" AND SF2.F2_SERIE   = NNC_SERDOC"
	cQry+=		" AND SF2.D_E_L_E_T_ != '*' "
	// Join com SE1
	cQry+= 	"LEFT JOIN " +  RetSqlName('SE1') + ' SE1 '
	cQry+= 		" ON  SE1.E1_FILIAL = '" + FwxFilial('SE1') + "' "
	cQry+=		" AND SE1.E1_PREFIXO = SF2.F2_PREFIXO"
	cQry+=		" AND SE1.E1_NUM = SF2.F2_DUPL"
	cQry+= 		" AND SE1.E1_CLIENTE = SF2.F2_CLIENTE"
	cQry+=		" AND SE1.E1_LOJA    = SF2.F2_LOJA"
	cQry+=		" AND SE1.E1_TIPO IN ('NF','NFE')"
	cQry+=		" AND SE1.E1_NUMLIQ = ' ' "
	cQry+=		" AND SE1.D_E_L_E_T_ != '*' "
	//Clausula Where
	cQry+= " WHERE NNC.NNC_FILIAL  = '" + fwXfilial('NNC') + "'"
	cQry+= "	AND NNC.NNC_CODCTR = '" + NN8->NN8_CODCTR + "'"
	cQry+= "	AND NNC.NNC_ITEMFX = '" + NN8->NN8_ITEMFX + "'"
	//    cQry+= " 	AND NNC.NNC_VRFIN != NNC.NNC_VRENPF-NNC.NNC_VLIMPF"
	cQry+= "	AND NNC.D_E_L_E_T_ != '*' "

	// Aplicando Union
	cQry += " UNION ALL "

	// Select da NKC Tipo de Docto = 1 Nf. DE ENTRADA DE COMPL. DE PRECO
	cQry += "SELECT "
	cQry += "CASE WHEN NKC.NKC_VRFIN = CAST((NKC.NKC_VRTOT - NKC_VRIMP) AS NUMERIC(18,2)) THEN 'Z'	ELSE 'A'	END AS ORDEM, NKC.R_E_C_N_O_ AS RECNOORIG, "
	//--Cpos NKC
	cQry += 	" 'NKC' AS TABELA, 'B' AS SEQDEBAIXA, NKC.NKC_CODCTR AS CONTRATO,NKC.NKC_CODROM AS ROMANEIO,"
	cQry += 	" NKC.NKC_ITEROM AS ITEMROMAN,NKC.NKC_ITEMFX AS FIXACAOITE,NKC.NKC_ITEM  AS ITSEQ, "
	cQry +=     " 0     AS QTENTREGA, 0  AS QTFIXDA, NKC.NKC_VRFIN AS VRFIX_OPOR, "
	cQry += 	" NKC.NKC_VRTOT - NKC_VRIMP  AS VRTITFIXDO,"
	//Cpos Ref. Frete/Seguro/Despesa ( A NKC não possui )
	cqry +=     " 0 AS FRETE 		,0 AS SEGURO		,0 AS DESPESA		, " // NKC N. possui frete/seguro/despesa
	cQry+=      " 0 AS VRFRE_OPOR	,0 AS VRSEG_OPOR	,0 AS VRDSP_OPOR	, " // NKC N. possui frete/seguro/despesa
	//Cpos SF2
	cQry +=		" SF2.F2_PREFIXO AS TITPREFIXO, SF2.F2_DUPL AS DUPLNUM,"
	//Cpos SE1
	cQry += 	" SE1.*, "
    cQry+=   " (SELECT COUNT(*) " +;
	            " FROM " + RetSqlName('SE1') + " SE1_B  "+;
		       " WHERE SE1_B.E1_FILIAL  = SE1.E1_FILIAL "+;
		        "  AND SE1_B.E1_PREFIXO = SE1.E1_PREFIXO"+;
			     " AND SE1_B.E1_NUM     = SE1.E1_NUM    "+;
			     " AND SE1_B.D_E_L_E_T_ != '*'          "+;
		         " ) QTD_PARCELA, "
	cQry+=		" SE1.R_E_C_N_O_  AS RECNO "					//Utilizado pela rotina de liquidação n. retirar
	cqry +=  " FROM " + RetSqlName('NKC') + ' NKC '
	//Join SF2
	cQry += " LEFT JOIN " + RetSqlName('SF2') + ' SF2 '
	cQry +=		"  ON SF2.F2_FILIAL = '" + fWXfilial('SF2') + "' "
	cQry += 	" AND SF2.F2_CLIENTE = '" + cCli + "'"
	cQry += 	" AND SF2.F2_LOJA = '" + cLja + "'"
	cQry += 	" AND SF2.F2_DOC = NKC.NKC_DOCTO "
	cQry += 	" AND SF2.F2_SERIE = NKC_SERIE "
	cQry += 	" AND SF2.D_E_L_E_T_ != '*' ""
	//Join SE1
	cQry +=	" LEFT JOIN " + RetSqlName('SE1') + ' SE1 '
	cQry +=		" ON SE1.E1_FILIAL = '" + fWxfilial('SE1') + "' "
	cQry +=		" AND SE1.E1_PREFIXO = SF2.F2_PREFIXO"
	cQry += 	" AND SE1.E1_NUM = SF2.F2_DUPL"
	cQry +=		" AND SE1.E1_CLIENTE = SF2.F2_CLIENTE"
	cQry +=		" AND SE1.E1_LOJA  = SF2.F2_LOJA"
	cQry += 	" AND SE1.E1_TIPO IN ('NF','NFE')"
	cQry +=		" AND SE1.E1_NUMLIQ = ' '
	cQry += 	" AND SE1.D_E_L_E_T_ != '*'"
	//Clausula Where
	cQry +=	" WHERE NKC.NKC_FILIAL = '" + fWxfilial('NKC') + "'"
	cQry += 	" AND NKC.NKC_TPDOC	= '2'"				//nf. compl. prc de venda
	cQry +=		" AND NKC.D_E_L_E_T_ != '*'"
	cQry +=		" AND NKC.NKC_CODCTR = '" + NN8->NN8_CODCTR + "'"
	cQry +=		" AND NKC.NKC_ITEMFX = '" + NN8->NN8_ITEMFX + "'"
	cQry +=		" AND NKC.D_E_L_E_T_ != '*'"

	//--Ordenando a Query
	cQry += " ORDER BY  ROMANEIO,SEQDEBAIXA,RECNOORIG"

	cQry := ChangeQuery( cQry )

	//AVISO("Aviso", cQry, {"OK"}, 1)

Return( cqry )
/** {Protheus.doc} fQrySE2
Função que Retorna a Qry montada que será executada
para gerar a Liquição
@param: 	cTrato    = Contrato
citemFx   = Item de Fixação
nTpSelect = 	1 - Select Sum(SE2.E2_SALDO)
2 -	Select  SE2.R_E_C_N_O_
@return:	cQry
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static function fQrySE2(cCtrato , cItFix, nTpSelect )
	Local cQry := ''
	/*/
	*----------------------------------------------------------------------------------------------------------
	!	Monta a Qry q será executado na SE2 no OGA360LIQ 																!
	!	Lista somente os registros da Sa2 q o documento gerador se encontra na NNC (Vinc. Romaneio c Fixação) e	!
	!	na NKC doctos de complemento da NNC																				!
	*----------------------------------------------------------------------------------------------------------*
	/*/
	cQry:= 'SELECT'
	IF nTpSelect == 1
		cQry += ' SUM(SE2.E2_SALDO) as SldTotal '
	ElseIF nTpSelect == 2
		cQry += 'SE2.E2_SALDO, SE2.R_E_C_N_O_ '
	EndIF
	cQry += " FROM " + RETSQLNAME('SE2') + ' SE2 '
	cQry += " 	WHERE SE2.E2_FILIAL = '"+ fWxFilial('SE2') + "'"
	cQry += "	AND SE2.D_E_L_E_T_ != '*'"
	cQry += "	AND SE2.E2_TIPO IN (     'NF' , 'NFE'   )"
	cQry += "   AND SE2.E2_SALDO > 0 "
	cQry += "   AND SE2.E2_NUMLIQ = ' '"
	cQry += "	AND (
	cQry += " 		SE2.E2_NUM IN (
	cQry += "						SELECT  NNC.NNC_NUMDOC FROM " + RETSQLNAME('NNC') + ' NNC '
	cQry += " 							WHERE NNC.NNC_SERDOC = SE2.E2_PREFIXO
	cQry += "					 		AND NNC.NNC_NUMDOC 	=  SE2.E2_NUM
	cQry += "							AND NNC.NNC_FILIAL 	= '" + fWxFilial('NNC') + "'"
	cQry += "						   	AND NNC.D_E_L_E_T_ != '*'"
	cQry += "							AND NNC.NNC_CODCTR = '" + cCtrato+ "'"
	cQry += "					  		AND NNC.NNC_ITEMFX = '"	+ cItFix + "'"
	cQry += "						)
	cQry += "		OR SE2.E2_NUM IN (
	cQry += "							SELECT  NKC.NKC_DOCTO FROM " + RETSQLNAME('NKC') + ' NKC '
	cQry += "							WHERE NKC.NKC_SERIE = SE2.E2_PREFIXO
	cQry += "							AND NKC.NKC_DOCTO   =  SE2.E2_NUM
	cQry += "							AND NKC.NKC_FILIAL  = '" + fWxFilial('NKC') + "'"
	cQry += "							AND NKC.D_E_L_E_T_ != '*'"
	cQry += "							AND NKC.NKC_CODCTR  = '" + cCtrato + "'"
	cQry += "							AND NKC.NKC_ITEMFX  = '" + cItFix  + "'"
	cQry += "							)"
	cQry += "		)"

	cQry := ChangeQuery( cQry )

Return( cqry )

/** {Protheus.doc} fQrySE1
Função que Retorna a Qry montada que Contem o filtro
que será executado para gerar a Liquidação
@param: 	cTrato    = Contrato
citemFx   = Item de Fixação
nTpAcao 	= 	1 - Select Sum(SE1.E1_SALDO)
2 -	SE1.R_E_C_N_O_
@return:	cQuery
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static function fQrySE1(cCtrato , cItFix, nTpAcao )
	Local cQry := ''
	/*/
	*-----------------------------------------------------------------------------------------------------------
	!	Monta a Qry q será executado na Liquidação da SE1																!
	!	Lista somente os registros da SE1 que o documento gerador se encontra na NNC (Vinc. Romaneio c Fixação) e!
	!	na NKC doctos de complemento da NNC																				!
	*----------------------------------------------------------------------------------------------------------*
	/*/
	cQry:= 'SELECT'
	IF nTpAcao == 1
		cQry += ' SUM(SE1.E1_SALDO) as SldTotal '
	ElseIF nTpAcao == 2
		cQry += ' SE1.R_E_C_N_O_ '
	EndIF
	cQry += " FROM " + RETSQLNAME('SE1') + ' SE1 '
	cQry += " 	WHERE SE1.E1_FILIAL = '"+ fWxFilial('SE1') + "'"
	cQry += "	AND SE1.D_E_L_E_T_ != '*'"
	cQry += "	AND SE1.E1_TIPO IN (     'NF' , 'NFE'   )"
	cQry += " 	AND SE1.E1_SALDO > 0 "
	cQry += " 	AND SE1.E1_NUMLIQ = ' '"
	cQry += "	AND (
	cQry += " 		SE1.E1_NUM IN (
	cQry += "						SELECT  NNC.NNC_NUMDOC FROM " + RETSQLNAME('NNC') + ' NNC '
	cQry += " 							WHERE NNC.NNC_SERDOC = SE1.E1_PREFIXO
	cQry += "					 		AND NNC.NNC_NUMDOC 	=  SE1.E1_NUM
	cQry += "							AND NNC.NNC_FILIAL 	= '" + fWxFilial('NNC') + "'"
	cQry += "						   	AND NNC.D_E_L_E_T_ != '*'"
	cQry += "							AND NNC.NNC_CODCTR 	= '" + cCtrato+ "'"
	cQry += "					  		AND NNC.NNC_ITEMFX 	= '"	+ cItFix + "'"
	cQry += "						)
	cQry += "		OR SE1.E1_NUM IN (
	cQry += "							SELECT  NKC.NKC_DOCTO FROM " + RETSQLNAME('NKC') + ' NKC '
	cQry += "							WHERE NKC.NKC_SERIE = SE1.E1_PREFIXO
	cQry += "							AND NKC.NKC_DOCTO   =  SE1.E1_NUM
	cQry += "							AND NKC.NKC_FILIAL  = '" + fWxFilial('NKC') + "'"
	cQry += "							AND NKC.D_E_L_E_T_ != '*'"
	cQry += "							AND NKC.NKC_CODCTR  = '" + cCtrato + "'"
	cQry += "							AND NKC.NKC_ITEMFX  = '" + cItFix  + "'"
	cQry += "							)"
	cQry += "		)"

	cQry := ChangeQuery( cQry )

Return( cqry )

/** {Protheus.doc} fGetTpCtr
Função que identifica o Tipo do Contrato,
necessita NN8 posicionada no ctrato
@param: 	nil
@return:	xTpCtrato preenchida
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static Function fGetTpCtr()

	NJR->( dbSetOrder( 1 ) )
	IF NJR->( dbSeek( xFilial( "NJR" ) + NN8->NN8_CODCTR ) )
		IF NJR->NJR_TIPO == '1'
			xTpCtrato := CTRATOCPRA
		ElseIF NJR->NJR_TIPO == '2'
			xTpCtrato := CTRATOVND
		EndIF
	EndIF

Return

/** {Protheus.doc} fGetTPLIQ
Função que identifica o Tipo do Liquidação de Sel. de titulos
para Liquidar da fixação. Apartir do Chamad TUDBDE Tivemos
que mudar a forma. Porem os Ctratos que já Se encontravam
com titulos liquidados na forma antiga deveriam mante-la
por isso foi criado uma flag NN5_TPLIQ, onde vazio indica
forma antiga e 1 Indica a forma Atual.

necessita NN8 posicionada no ctrato
@param: 	nil
@return:	xTpCtrato preenchida
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static Function fGetTpLiq()

	Local aAreaAtu 		:= GetArea()
	Local aAreaNN5		:= NN5->( GetArea() )
	Local cAliasQry 	:= GetNextAlias()
	Local cTpLiq		:= '1'    //'1' -> Indica que é Atual

	BeginSql Alias cAliasQry
	SELECT Count ( NN5.R_E_C_N_O_) NRREGISTROS
	FROM %Table:NN5% NN5
	WHERE NN5.%notDel%
	AND NN5_FILIAL = %xFilial:NN5%
	AND NN5_CODCTR = %exp:NN8->NN8_CODCTR%
	AND NN5_TPLIQ = ' '
	EndSQL

	( cAliasQry )->( DbGoTop() )

	IF ( cAliasQry )->NRREGISTROS > 0
		cTpLiq	:= '0' //Indica que não para utilizar a forma Atual
	EndIF

	( cAliasQry )->( DbCloseArea() )

	RestArea( aAreaAtu )
	RestArea( aAreaNN5 )

Return ( cTPLiq )

/** {Protheus.doc} fEntregaOK
Função que verifica a situação das Entregas,
no intuito de n. deixar emitir uma OP/OR para entregas que necessitam de nf. de
complemento, NCC, etc.
@param: 	nil
@return:	Valor logico .t. Indica que esta tudo ok, .f. Indica que n. stá tudo OK
@author: 	Emerson Coelho
@since: 	14/01/2015
@Uso: 		OGA360
*/
Static Function fEntregaOK()
	Local lok	:= .f.
	Local cAliasNNC 	:= GetNextAlias()

	BeginSql Alias cAliasNNC
	SELECT COUNT(NNC.R_E_C_N_O_) AS NRECNOS FROM %Table:NNCC% NNC
	WHERE	NNC.%notDel%
	AND 	NNC.NNC_FILIAL  	= %xFilial:NNC%
	AND 	NNC.NNC_CODCTR  	= %exp:NN8->NN8_CODCTR%
	AND 	NNC.NNC_ITEMFX 	 	= %exp:NN8->NN8_ITEMFX%
	AND 	NNC.NNC_STATUS IN ('1','2','5')   ////Legenda dos Status Até hj 15012016	:='1=Requer NF.Compl/Propria;2=Requer NF.Compl/Produtor;3=Não Requer NF.Compl.;4=Nf. Compl.Emitida;5=VR.Fixação a Menor'
	EndSQL

	( cAliasNNC )->( DbGoTop() )

	IF ( cAliasNNC )->NRECNOS > 0   	// Indica que já existe uma nfcmpl de Ajuste e não devemos ajustar em outra
		lOK := .f.
	Else
		lOK := .t.
	EndIF

Return( lOk )

Static Function fBrwEntreg(oPanel)
	Local oModel        := FWModelActive()
	Local nOperation	:= oModel:GetOperation()

	// -- Vars Utilizada para Gerar TRB NNC --//rwnnc
	Local   aColumns	:= {}
	Local	nX			:= 0
	Local 	aCposBrowse	:= {}
	Local 	aCposQry	:= {}

	//------------------------------------------
	//Criação da MarkBrowse da NNC
	//------------------------------------------

	IF xBrowseEnt == nil

		nAuxTam := 0.40   // Indica que irei utilizar 40 % to tamanho definido no x3_tamanho para as colunas n. ficarem muito grandes
		fGerTrbTIT()  //Gerando /Refresh TRB da SE2/SE1

		//Define as colunas do Browse de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
		aCposBrowse := {"NNC_CODROM","NNC_ITEROM","E2_NUM","E2_PARCELA", "E2_PREFIXO",'E2_VALOR','D1_TOTAL','D1_TOTAL','D1_TOTAL','E2_VALOR','E2_SALDO','E2_VALOR','E2_VALOR','E2_VALOR'}
		//Define as colunas do Browse de Acordo com a Qry para Identificar os Dados
		aCposQry 	:= {"ROMANEIO","ITEMROMAN","TIT_NUM","TIT_PARCEL","TIT_PREFIX",'VRTITFIXDO','VRFRETE','VRSEGURO','VRDESPESA','VRFIX_OPOR','VRFRE_OPOR','VRSEG_OPOR','VRDSP_OPOR','TIT_SALDO' }

		//Definindo as colunas do Browse

		nX := 1
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(RetTitle(aCposBrowse[nX])))
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 2
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(STR0065/*AllTrim(SX3->X3_TITULO)*/) //'Item'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
		
		nX := 3
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle( STR0066/*AllTrim(SX3->X3_TITULO)*/) //'Título'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
		
		nX := 4
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(RetTitle(aCposBrowse[nX])))
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
		
		nX := 5
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(RetTitle(aCposBrowse[nX])))
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 6
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0067)) //'Vr.Rom.Fixdo'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 7
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0068) ) //'Frete'			
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 8
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0069) ) //'Seguro'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 9
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0070) ) //'Despesa'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 10
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0071) ) //'Vr.Fix.OP/OR'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 11
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0072)	) //'Frete OP/OR'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 12
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0073) ) //'Seguro OP/OR'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX := 13
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0074) ) //'Desp.OP/OR'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		nX :=14
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(STR0075) ) //'Sldo. Tit.'
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1]  * nAuxTam)
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		//Criando o Browse

		xBrowseEnt:=FwMarkBrowse():New()   // --Mudado de F3markBrowse para Browse comun neste momento pois não iremos permitir o usuario selecionar quais rom. serão baixados ainda --
		xBrowseEnt:SetDescription( STR0076 + fwFldGet('NN5_CODOPG')) //"Entregas a baixar da fixação para gerar a ordem de pagamento:"
		xBrowseEnt:SetOwner(oPanel)
		xBrowseEnt:SetDataQuery(.f.)
		xBrowseEnt:SetDataTable(.T.)
		xBrowseEnt:SetTemporary(.T.)
		xBrowseEnt:SetAlias( xTRBTITS )
		xBrowseEnt:SetMenuDef("")
		xBrowseEnt:SetColumns( aColumns )
		xBrowseEnt:SetProfileID( "1" )

		// Para melhor entendimento do Codigo Irei tratar em unico lugar qdo for um delete na view
		IF !nOperation = MODEL_OPERATION_INSERT  	//Qdo for delete tenho q retirar tdo q se refere a Marcar pois ao
			//n. devo marcar ou desmarcar nada no browse entregas deve ser somente um Browse normal
			//xBrowseEnt:SetFieldMark( nil )			//Comentado intesionalmente eu ´so preciso Marcar/desm qdo estou inserindo
			xBrowseEnt:SetCustomMarkRec({||})
			xBrowseEnt:bAllMark := { ||}
		Else
			xBrowseEnt:SetFieldMark("MARCA")
			xBrowseEnt:SetCustomMarkRec({||  })
			//		xBrowseEnt:bAllMark := { ||SelTitLiq()  }
		EndIF

		xBrowseEnt:Activate()
		
	EndIF

Return()


/*{Protheus.doc}
Função q Seleciona Tits. de forma automatica
até atingir o vr. da OP/OR
@param		cCampo que há Chamou pode ser do nn5_qtdfin e do NN5_VLRTOT
@return   	Browse Marcado
@author   	Agro
@since    	27/01/2015
@version  	P11
*/

Static function SelTitLiq( cCampo )

	Local oModel        := FWModelActive()
	Local oNN5		    := oModel:GetModel( "NN5UNICO" )
	Local lCpoOriQTd 	:= IIF(cCampo == 'NN5_QTDFIN',.T., .F.)
	Local nMaxLqdar		:= IIF(cCampo == 'NN5_QTDFIN',fwFldGet('NN5_VRFIXT'),  fwFldGet('NN5_VLRTOT'))

	Local nFrete		:= 0		// Frete
	Local nSeguro		:= 0		// Seguro
	Local nDspAces		:= 0 		// Desp. Acess.

	Local nVrTitLqd		:= 0		// Vr. do titulo a Liquidar
	Local nFretLqd		:= 0		// Vr. do Frete a liquidar
	Local nSeguLqd		:= 0		// Vr. do Seguro a Liquidar
	Local nDespLqd		:= 0		// Vr. da Despesa a Liquidar

	Local nVrAcresc		:= 0		// Vr. de Acrescimo
	Local nVrDecresc	:= 0        // Vr. de Decrescimo
	Local nVrTotal		:= 0		//vr. total
	Local nVrFixAtu 	:= 0
	Local nI			:= 0
	Local nRegUltSel    := 0
    
    Local nQtdTit       := 0
    Local cRomAnt       := ""    

	aTitAcres			:= {}
	aTitDecres			:= {}

	xVrAcresLq			:= 0
	xVrDecresLq			:= 0

	If cPaisLoc = "PAR" //Se pais for Paraguai, sai da função
		Return
	Else
		cAliasTmp := xBrowseEnt:Alias()
	EndIf

	IF !xTpLiq = '1' // Tratamento para manter a forma antiga de sel. de tits. para liqdacao, Em algum momento no futuro basta tirar esse if e seu conteudo tambem
		fNN5QTDFIN( nMaxLqdar  )
		///oNN5:LoadValue('NN5_VRFIXT', nMaxLqdar )	
		Return( nMaxLqdar )
	EndIF

	xVrMrkdo	:=0
	xVrMrkFre	:=0
	xVrMrkSeg	:=0
	xVrMrkDsp	:=0



	// -- Desmarcando os Registros -- 
	( xBrowseEnt:Alias() )->( DbGotop() )
	While  ( xBrowseEnt:Alias() )->(! Eof() )

		RecLock( xBrowseEnt:Alias(),.f.)

		(xBrowseEnt:Alias())->VRLQDFIX 	:= 0
		(xBrowseEnt:Alias())->VRLQDFRE		:= 0
		(xBrowseEnt:Alias())->VRLQDSEG		:= 0
		(xBrowseEnt:Alias())->VRLQDDSP		:= 0

		(xBrowseEnt:Alias())->VRLQDECR		:= 0
		(xBrowseEnt:Alias())->VRLQACRE		:= 0

		(xBrowseEnt:Alias())->VRLQDTIT 		:=	0

		(xBrowseEnt:Alias() )->MARCA		:= ''

		(xBrowseEnt:Alias() )->( MsUnLock() )
		( xBrowseEnt:Alias() )->( DbSkip()  ) 

	EndDo


	( xBrowseEnt:Alias() )->( DbGotop() )
	While  ( xBrowseEnt:Alias() )->(! Eof() )		
		// Tratando Despesas de Frete/Seguro/Desp.Acessorias //
        nVrFixAtu 	:= ( ( xBrowseEnt:Alias())->VRTITFIXDO - (xBrowseEnt:Alias())->VRFIX_OPOR ) 	// Vr. fixado - o que já se encontra em OP, esse eh o vr. a Baixar no tit.

		nFrete 		:= 0
		nSeguro 	:= 0
		nDspAces	:= 0

		//IF xConsidFRE
		nFrete 		:= ( ( xBrowseEnt:Alias())->VRFRETE   - (xBrowseEnt:Alias())->VRFRE_OPOR )		// Encontra o Vr. do Frete    q ainda Falta Liquidar
		//EndIF

		//IF xConsidSEG
		nSeguro		:= ( ( xBrowseEnt:Alias())->VRSEGURO  - (xBrowseEnt:Alias())->VRSEG_OPOR )		// Encontra o Vr. do Seguro   q ainda Falta Liquidar
		//EndIF

		//IF xConsidDSP
		nDspAces 	:= ( ( xBrowseEnt:Alias())->VRDESPESA - (xBrowseEnt:Alias())->VRDSP_OPOR )		// Encontra o Vr. do Dsp.Aces q ainda Falta Liquidar
		//EndIF

		nAuxDif		:= 0
		nVrAcresc	:= 0
		nVrDecresc	:= 0
        
        If cRomAnt != ( xBrowseEnt:Alias())->ROMANEIO
            fGetTotTit(@nQtdTit)
            cRomAnt := ( xBrowseEnt:Alias() )->ROMANEIO        
        EndIf
        
        IF  ((xBrowseEnt:Alias())->TIT_SALDO == 0) .and.  (nVrFixAtu+nFrete+nSeguro+nDspAces) > 0	// Titl zerado e Vr. a fixar > 0 , Indica q tit foi baixado
			//conout('Problema: o Registro de Entrega da fixação está pendente de Baixa, Porem o titulo já se encontra Zerado ')
			( xBrowseEnt:Alias() )->( DbSkip() )
			Loop
		ELSEIF ((xBrowseEnt:Alias())->TIT_SALDO == 0) .and.  (nVrFixAtu+nFrete+nSeguro+nDspAces) == 0
			//Conout ('Titulo e Registro de entrega já foram Liquidados anteriormente')
			( xBrowseEnt:Alias() )->( DbSkip() )
			Loop
		ElseIF ( (nVrFixAtu+nFrete+nSeguro+nDspAces) <> (xBrowseEnt:Alias())->TIT_SALDO  ) .and. nQtdTit == 1	// Se o Saldo do Titulo for diferente do Vr. que foi fixado
			If (xBrowseEnt:Alias())->TIT_SALDO < (nVrFixAtu+nFrete+nSeguro+nDspAces) 
				nAuxDif := (nVrFixAtu+nFrete+nSeguro+nDspAces) - (xBrowseEnt:Alias())->TIT_SALDO 
				//Conout('Dif. considerada normal devido o calc. de impostos')
			EndIf
		EndIF


		// Qdo n. considero o frete eu zero os campos para nao fazerem parte do calculo
		IF ! xConsidFRE
			nFrete 		:= 0
		EndIF

		IF ! xConsidSEG
			nSeguro		:= 0
		EndIF

		IF ! xConsidDSP
			nDspAces 	:= 0
		EndIF	

		IF nAuxDif <> 0  //Indica que temos diferença entre o vr. que foi Fixado e o Vr. que esta no Cpargar ou CReceber
			nRecno := OG360RgTIT( (xBrowseEnt:Alias())->TABORG, (xBrowseEnt:Alias())->CPosOrigem,(xBrowseEnt:Alias())->ChveOrigem  ) //identificando registro na NKC
			NKC->(dbGoTo(nRecno))
			cDocPropri := NKC->NKC_FORMUL
			IF nAuxDif <> 0 .and.  cDocPropri == "S" .and. (xBrowseEnt:Alias())->QTFIXDA <  (xBrowseEnt:Alias())->QTENTREGA 	
				// Indica que Somente parte do romaneio está nessa fixação
				// portanto a dif. é normal contanto que nenhuma das associacoes
				// dos romaneios foi baixada
				// Neste momento n. irei fazer nada.
			ElseIf nAuxDif <> 0 .and. cDocPropri == "N" .and. fNumDocVin(NKC->NKC_CODCTR, NKC->NKC_DOCTO, NKC->NKC_SERIE) > 1 
				// Verifica se é uma nota de complemento de terceiros e se esta vinculada a mais de um formulario 
				// neste caso o valor total do complemento sera maior que o valor total do complemento esperado pela fixacao				
			ElseIF nAuxDif > 0 .and. nAuxdif < xVrDifCalc
				nVrAcresc := nAuxDif
			ElseIF nAuxDif < 0 .and. (nAuxDif * (-1) ) < xVrDifCalc
				nVrDecresc := nAuxDif * (-1)
			Else //Diferença nao considerada normal e n. Marcamos o titulo para Baixar baixamos o titulo
				( xBrowseEnt:Alias() )->( DbSkip() )
				Loop
			EndIF
		EndIF

		RecLock( xBrowseEnt:Alias(),.f.)

		IF (xVrMrkdo +  xVrMrkFre + xVrMrkSEG + xVrMrkDsp) < nMaxLqdar //fwFldGet('NN5_VLRTOT')
		            
            nVrTitLqd	:= IIF( (nMaxLqdar - (xVrMrkdo +  xVrMrkFre + xVrMrkSEG + xVrMrkDsp)) > nVrFixAtu, nVrFixAtu,(nMaxLqdar - (xVrMrkdo +  xVrMrkFre + xVrMrkSEG + xVrMrkDsp)))   //Vr. a Lqdar. do titulo ref. ao Produto Fixado
            
            nTotDSPS 	:=  nFrete + nSeguro + nDspAces													//Vr. a Lqdar. Ref. as Despesas (Frete/Seg/Dsp.Acess)

			(xBrowseEnt:Alias() )->MARCA := xBrowseEnt:Mark()

			IF (nVrFixAtu + nTotDSPS) <= (xBrowseEnt:Alias())->TIT_SALDO + xVrDifCalc //Indica que o titulo Ficou menor ou Igual a fixação

				IF !(nVrTitLqd + nTotDSPS )  = (nVrFixAtu + nTotDSPS)	// Indica que n. vou liquidar o vr. fixado total , portanto liquido Parcial tambem o frete/Seg/Dsp.Acess

					IF lCpoOriQTd   // Se a chamada veio do Cpo NN5_QTD
						nFretLqd	:= a410Arred(nFrete		* (nVrTitLqd / nVrFixAtu), 'D1_VALFRE')
						nSeguLqd    := a410Arred(nSeguro 	* (nVrTitLqd / nVrFixAtu), 'D1_SEGURO')
						nDespLqd	:= A410ARRED(nDspAces	* (nVrTitLqd / nVrFixAtu), 'D1_DESPESA')
					Else   // Se a chamada Veio do Cpo de Total
						nTotDSPS 	:= nVrFixAtu + nFrete + nSeguro + nDspAces
						nFretLqd	:= a410Arred(nVrTitLqd	* (nFrete	/ nTotDSPS ), 'D1_VALFRE')
						nSeguLqd    := a410Arred(nVrTitLqd 	* (nSeguro	/ nTotDSPS ), 'D1_SEGURO')
						nDespLqd	:= A410ARRED(nVrTitLqd	* (nDspAces	/ nTotDSPS ), 'D1_DESPESA')

						nVrTitLqd	-= (nFretLqd + nSeguLqd + nDespLqd)
						nMaxLqdar	-= (nFretLqd + nSeguLqd + nDespLqd)

					ENDIF
				Else
					nFretLqd	:= nFrete
					nSeguLqd	:= nSeguro
					nDespLqd	:= nDspAces
				EndIF			

                xVrMrkdo		+= nVrTitLqd
				xVrMrkFre		+= nFretLqd
				xVrMrkSeg		+= nSeguLqd
				xVrMrkDsp		+= nDespLqd

				(xBrowseEnt:Alias())->VRLQDFIX 	:= nVrTitLqd 		// Vr. a Lqdar do Prod. Fixado
				(xBrowseEnt:Alias())->VRLQDFRE	:= nFretLqd
				(xBrowseEnt:Alias())->VRLQDSEG	:= nSeguLqd
				(xBrowseEnt:Alias())->VRLQDDSP	:= nDespLqd

				(xBrowseEnt:Alias())->VRLQDECR	:= nVrDecresc
				(xBrowseEnt:Alias())->VRLQACRE	:= nVrAcresc

				(xBrowseEnt:Alias())->VRLQDTIT :=	(xBrowseEnt:Alias())->( VRLQDFIX + VRLQDFRE + VRLQDSEG + VRLQDDSP) 

				xVrAcresLq 	+= nVrAcresc
				xVrDecresLq += nVrDecresc

				// Se tivermos discrepancia entre Saldo dos titulos Separo-os em Array Para Tratalos;
				IF nVrAcresc > 0
					aAdd( aTitAcres,  (xBrowseEnt:Alias())->( Recno() ) )
				ElseIF nVrDecresc > 0
					aAdd( aTitDecres,  (xBrowseEnt:Alias())->( Recno() ) )
				EndIF

				nRegUltSel := (xBrowseEnt:Alias())->( Recno() )   //Quarda Ultimo titulo Selecionado.

				IF cCampo == 'NN5_QTDFIN' // Qdo for chamada do cpo qtidade
					nMaxLqdar += nFretLqd + nSeguLqd + nDespLqd
				EndIF
			EndIF
		Else
			Exit
		EndIF

		(xBrowseEnt:Alias() )->( MsUnLock() )
		( xBrowseEnt:Alias() )->( DbSkip() )
	EndDO

	//1a Tratamento para Os Acrescimos e Decrescimos encontratos entre o Calculo da Fixacao e o q tenho nos titulos Exemplo nnc diz q tenho q ter x e no titulo tenho x-0,01
	// e tentar compensar um com outro;
	// Os Cpos 	XVrAcresLq 	- Indica que alguns titulos tem o Vr. de financeiro Menor que o Vr. encontrado na Fixação
	// 			XvrDecreslq	- Indica que alguns titulos tem o Vr. de financeiro Maior que o Vr. encontrado na Fixação
	// Tentarei distribuir o Vr. a Acrescer nos titulos que estão a Maior, dessa forma n. preciso fazer nenhum acrescimo
	// de liquidação; 
	aAuxVrDecr 	:= {}
	If cPaisLoc = "PAR"
		IF xVracreslq > 0 						// Indica que algums doctos  da fixação  tiveram titulos com vrs. Menores que o que a fixação Cauculou
			For nI := 1 to Len( aTitDecres )   	//Tento Ajustar verificando se temos Algum Titulo que Teve a Fixacao Calculando um Vr. menor Que o que temos no titulo
				( cAliasTMP )->( dBGoto( aTitDecres[nI] ) )
				RecLock( cAliasTMP,.f.)

				IF xVracreslq >= ( cAliasTMP )->VRLQDECR
					( cAliasTMP )->VRLQDTIT 	+= ( cAliasTMP )->VRLQDECR
					xVracreslq 				-= ( cAliasTMP )->VRLQDECR   //Abatendo O Acrescer, com o Decrescer
					XvrDecreslq 				-= ( cAliasTMP )->VRLQDECR	//Abatendo o Decrescer, com Acrescer
					/// Nao irei zerar o decrescimo para poder gravalo...( cAliasTMP )->VRLQDECR 	:= 0
				ElseIF xVracreslq < ( cAliasTMP )->VRLQDECR
					( cAliasTMP )->VRLQDTIT += xVracreslq
					xVracreslq 				-= xVracreslq
					// nao irei diminuir para poder zera-lo  (  cAliasTMP )->VRLQDECR -= xVracreslq
					XvrDecreslq 				-= xVracreslq
					aAdd(aAuxDecr, aTitDecres[nI] )
				Else
					aAdd(aAuxDecr, aTitDecres[nI] ) 
				EndIF

				( cAliasTMP )->( MsUnLock() )
			nExt nI
		EndIF

		aTitDecres := aAuxVrDecr

		//Tratamento para  titulos q tem Decrescimo. ( nnc diz q tenho q ter x e no titulo tenho x-0,01 )
		// Apos tentar compensar os titulos que precisam acrescer com os que precisam decrescer ( pode ser que tinha 0,01 a acrescer, e 0,02 a decrescer )
		// Vou verificar se ainda tem algo a Decrescer;
		aAuxVrDecr 	:= {}

		IF XvrDecreslq > 0 					// Indica que algums doctos  da fixação  tiveram titulos com vrs. Menores que o que a fixação Calculou e n. consegui 
			// Compensa-los com os que precisavam de acrescimo
			XvrDecreslq := 0
			For nI := 1 to Len( aTitDecres )   	//Ajustando o Vr. do titulo a Liquidar considerando o Decrescimo na Liquidação
				( cAliasTMP )->( dBGoto( aTitDecres[nI] ) )
				RecLock( cAliasTMP, .f. )
				( cAliasTMP )->VRLQDTIT 	+= ( cAliasTMP )->VRLQDECR
				XvrDecreslq 				+= ( cAliasTMP )->VRLQDECR
			nExt nI
		EndIF

		//--Fim Tratamento difs entre NNc e titulos --------

		// Aqui somente uma das variaveis xVrAcresLq ou XvrDecreslq terá vrs.
		// Se Apos Distribuir possivel Vlr de Acrescimo nos Titulos que selecionamos ( Pois alguns podem tem q ser acrescidos outros decrescidos )
		// ainda tivermos vr. a Acrescer Verifico se nos proximos titulos tem algum que tem Algum vr. sobrando
		// Irá ser tratado como Acrescimo de Liquidação

		IF !lCpoOriQTd					// N. veio da Qtidade Então Chamo função que calcula a Qtidade;
			//-- Verifica possivel diferença entre o que calculou o registro da fixacao NN8 e o q a NNC diz. q deveria Ter --//
			//-- Ex. Apesar de tudo q a NNC. Calculou esta no Cpagr ou Receber, a NN8 no total diz q tem q ter X, e a soma das NNC diz q tem X-0,01 ou tem X+0,01)
			nAuxDif 	:= 0
			IF  ( xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) < oNN5:GetValue( "NN5_VLRTOT" )
				nAuxDif	:=  oNN5:GetValue( "NN5_VLRTOT" ) - ( xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp )

				IF nAuxDif > 0
					nVrAcresc := nAuxDif
				EndIF

				IF nAuxDif <= xVrDifCalc   // Dif. n. pode Ser Maior que dif. permitida

					xVrMrkdo -= nVrDecresc
					xVrDecresLq += nVrDecresc

					(cAliasTMP)->( DbGoto(nRegUltSel) )
					RecLock( cAliasTMP,.f.)
					(cAliasTMP)->VRLQDECR	+= nVrDecresc
					(cAliasTMP)->( MsUnlock() )

				EndIF
			EndIF
			//-- Fim Verifica possivel diferença entre o que calculou o registro da fixacao NN8 e o que os itens da fixação tem        --//

			fNN5QTDFIN( xVrMrkdo )
			oNN5:LoadValue('NN5_VRFIXT' ,xVrMrkdo ) 
		Else
			//-- Verifica possivel diferença entre o que calculou o registro da fixacao NN8 e o q a NNC diz. q deveria Ter --//
			//-- Ex. Apesar de tudo q a NNC. Calculou esta no Cpagr ou Receber, a NN8 no total diz q tem q ter X, e a soma das NNC diz q tem X-0,01 ou tem X+0,01)

			nAuxDif 	:= 0
			IF  xVrMrkdo < oNN5:GetValue('NN5_VRFIXT')
				nAuxDif	:= xVrMrkdo - oNN5:GetValue('NN5_VRFIXT')

				IF nAuxDif < 0
					nVrAcresc := nAuxDif * (-1)
				EndIF

				IF nAuxDif <= xVrDifCalc   // Dif. n. pode Ser Maior que dif. permitida
					xVrMrkdo += nVrAcresc
					xVrAcresLq 	+= nVrAcresc

					(cAliasTMP)->( DbGoto(nRegUltSel) )
					RecLock( cAliasTMP,.f.)
					(cAliasTMP)->VRLQACRE	+= nVrAcresc
					(cAliasTMP)->( MsUnlock() )

				EndIF
			EndIF
			//-- Fim Verifica possivel diferença entre o que calculou o registro da fixacao NN8 e o que os itens da fixação tem        --//	


			//Seta o Vr. total que é igaul ao Vr. Fixado + Frete/Seguro/Despesa
			nVrtotal := xVrMrkdo + xVrMrkFre+ xVrMrkSeg + xVrMrkDsp
			oNN5:LoadValue('NN5_VLRTOT' ,round(nVrtotal,TamSX3("NN5_VLRTOT")[2]) )
		EndIF
	EndIf	    	
    
    oNN5:LoadValue('NN5_FRETE' ,xVrMrkFre)
	oNN5:LoadValue('NN5_SEGURO',xVrMrkSeg)
	oNN5:LoadValue('NN5_DESPES',xVrMrkDsp)

	/* FORÇA O REFRESH DO bROWSE dos dados da query	*/
	xBrowseEnt:Refresh(.T.)
Return( xVrMrkdo )

/*{Protheus.doc}
Retorna aArray na Forma q a Liquidação deve ocorrer
contendo registro da NNC,NKC,SE2 OU SE1, para garantir
que o vr. dos regs. da nnc,nkc sejam respeitados em
cada titulo e tambem os Vrs. dos favorecidos/parcelas
sejam respeitados;
@param		nil.
@return   	Array
@author   	Agro
@since    	20/01/0216
@version  	P11
*/

Static function fTitsLqdar(  )

	Local oModel        	:= FWModelActive()
	Local oGrdNN6			:= oModel:GetModel( "NN6UNICO" )
	Local oGrdNKK			:= oModel:GetModel( "NKKUNICO" )
	Local cNkkItem			:= Criavar('NKK_ITEM',.f.)

	Local nVrJaEmLqd	:= 0
	Local nVrDistrib	:= 0
	Local nVrFixAtu		:= 0
	Local nFreLqd		:= 0
	Local nSegLqd		:= 0
	Local nDspLqd		:= 0

	Local nFreJaLqd		:= 0
	Local nSegJaLqd		:= 0
	Local nDspJaLqd		:= 0
	Local nTotComDSP	:= 0

	Local nAcresc		:= 0
	Local nDecresc		:= 0

	Local nX			:= 0
	Local nNewLine		:= 0

	Local aErro			:= 0
	Local lContinua		:= .t.

	aTitsLqd 			:= {}
	nVrJaEmLqd			:= 0

	( xBrowseEnt:Alias() )->( DbGotop() )
	// --- Lendo o Grid de Favorecidos

	aSaveLines := FWSaveRows() // Salva a posição de todos os Grids
	For nX := 1 to oGrdNN6:Length()
		oGrdNN6:GoLine( nX )

		oGrdNKK:ClearData()		//Limpando o Modelo da NKK Baixas da Liqd. qdo tiver mais q uma Linha
		oGrdNKK:InitLine()

		nVrDistrib := FWFLDGET("NN6_VALOR ",	nX)

		//	aAdd( aTitsLqdar,  Array(1) )			//Adiciona 1 Linha no Array dos Titulos a Liquidar com q Qtd. de Colunas que Irei Utilizar
		///aTitsLqdAux	:= {}
		If .Not. oGrdNN6:IsDeleted()

			nNewLine := 0
			cNkkItem := Criavar('NKK_ITEM',.f.)

			While ( xBrowseEnt:Alias() )->(! Eof() )
				IF ( !xBrowseEnt:IsMark() )     //Se não tiver Marcado Vou ao Proximo.
					( xBrowseEnt:Alias() )->( DbSkip() )
					Loop
				EndIF

				nVrFixAtu	:= ( xBrowseEnt:Alias() )->VRLQDFIX + ( xBrowseEnt:Alias() )->VRLQDFRE + ( xBrowseEnt:Alias() )->VRLQDSEG + ( xBrowseEnt:Alias() )->VRLQDDSP

				nVrFixAtu		-= (nVrJaEmLqd + nFreJaLqd + nSegJaLqd + nDspJaLqd)  // Deduzindo Vr. Já utilizado do Tit. Ref. a Uma Linha anterior da NN6
				IF nVrDistrib 	>= nVrfixAtu
					nVrLiqd 	:= nVrfixAtu
				Else
					nVrLiqd	:= nVrDistrib //--Saldo
				EndIF
				nVrDistrib -= nVrLiqd				//Subtrai o q Já foi alocado para baixar
				///				nVrRestant := nVrFixAtu - nVrLiqd 	//Indica que O Vr. da NN6 que tenho q distribuir irá utilizar apenas parte do Titulo marcado
				//O Vr. Restante deve ser lqdado para a Proxima Linha da NN6

				nAcresc 	:= 0
				nDecresc	:= 0
				IF ! nvrLiqd = ( xBrowseEnt:Alias() )->VRLQDFIX   + ( xBrowseEnt:Alias() )->VRLQDFRE + ( xBrowseEnt:Alias() )->VRLQDSEG + ( xBrowseEnt:Alias() )->VRLQDDSP 	// Indica q n. Liquidei todo vr. q deve ser liquidado nessa linha da NN6
					// Então Calculo tbem o Vr. do Frete/Seg/Dsps Proporcional,  por linha da NN6

					IF ( nvrLiqd + nVrJaEmLqd + nFreJaLqd + nSegJaLqd + nDspJaLqd ) == ( xBrowseEnt:Alias() )->VRLQDFIX + nFreJaLqd + nSegJaLqd + nDspJaLqd
						nFreLqd 	:=   ( xBrowseEnt:Alias() )->VRLQDFRE - nFreJaLqd
						nSegLqd 	:= 	 ( xBrowseEnt:Alias() )->VRLQDSEG - nSegJaLqd
						nDspLqd 	:= 	 ( xBrowseEnt:Alias() )->VRLQDDSP - nDspJaLqd
					Else

						nTotComDSP 	:= nVrFixAtu //+ ( xBrowseEnt:Alias() )->( VRLQDFRE + VRLQDSEG + VRLQDDSP)
						nFreLqd		:= a410Arred(nVrLiqd	* ( ( xBrowseEnt:Alias() )->VRLQDFRE	/ nTotComDSP ), 'D1_VALFRE') - nFreJaLqd
						nSegLqd   	:= a410Arred(nVrLiqd 	* ( ( xBrowseEnt:Alias() )->VRLQDSEG	/ nTotComDSP ), 'D1_SEGURO') - nSegJaLqd
						nDspLqd		:= A410ARRED(nVrLiqd	* (( xBrowseEnt:Alias() )->VRLQDDSP	/ nTotComDSP ), 'D1_DESPESA')	- nDspJaLqd

					EndIF
				Else
					nFreLqd		:= ( xBrowseEnt:Alias() )->VRLQDFRE
					nSegLqd		:= ( xBrowseEnt:Alias() )->VRLQDSEG
					nDspLqd		:= ( xBrowseEnt:Alias() )->VRLQDDSP
				EndIF

				nVrRestant := nVrFixAtu - nVrLiqd  //Indica que O Vr. da NN6 que tenho q distribuir irá utilizar apenas parte do Titulo marcado

				IF nVrRestant == 0   // Inica que é a ultima vez q irei utilizar/liqdar o titulo então se tenho q acrescer eu acresco ou decresco na ultima vez q irei utiliza-lo
					nAcresc		:= ( xBrowseEnt:Alias() )->VRLQACRE
					nDecresc	:= ( xBrowseEnt:Alias() )->VRLQDECR
				EndIF

				// -- Fazendo o Load dos Dados de como os titulos serão baixados na NKk ( Bxs. Liquidacao )
				nNewLine+=1
				IF nNewLine > 1
					nNewLine:= oGrdNKK:AddLine()
				EndIF
				oGrdNKK:GoLine( nNewLine )

				cNkkItem := SOMA1( cNkkItem )
				//oGrdNKK:LoadValue('NKK_FILIAL', FwXfilial('NKK')																)
				oGrdNKK:SetValue('NKK_OPOR',	FWFLDGET('NN5_CODOPG')															)
				oGrdNKK:SetValue('NKK_ITOPOR',	oGrdNN6:GetValue('NN6_ITEM')													)
				oGrdNKK:SetValue('NKK_ITEM',	cNkkItem																		)

				oGrdNKK:SetValue('NKK_TABORG',	( xBrowseEnt:Alias())->TABORG													)
				oGrdNKK:SetValue('NKK_CPOORG',	PadR(Alltrim( ( xBrowseEnt:Alias())->CPosOrigem ), TamSX3( "NKK_CPOORG" )[1] )		)				
				oGrdNKK:SetValue('NKK_CHVORG',	PadR(Alltrim( ( xBrowseEnt:Alias())->CHVEORIGEM ), TamSX3( "NKK_CHVORG" )[1] ) 	)
				oGrdNKK:SetValue('NKK_TABLQD',	IIF ( xTpCtrato == CTRATOCPRA,'SE2','SE1')										)
				oGrdNKK:SetValue('NKK_CPOTIT',	PadR(Alltrim( ( xBrowseEnt:Alias())->CPOSTIT  ), TamSX3( "NKK_CPOTIT" )[1] )	)				
				oGrdNKK:SetValue('NKK_CHVTIT',	PadR(Alltrim( ( xBrowseEnt:Alias())->TITCHAVE ), TamSX3( "NKK_CHVTIT" )[1] )	)

				oGrdNKK:SetValue('NKK_CODROM', ( xBrowseEnt:Alias())->ROMANEIO	)
				oGrdNKK:SetValue('NKK_ITEROM', ( xBrowseEnt:Alias())->ITEMROMAN)
				oGrdNKK:SetValue('NKK_VRLQDF', nVrLiqd	-= (nFreLqd + nSegLqd + nDspLqd)							)
				oGrdNKK:SetValue('NKK_FRELQD', nFreLqd							)
				oGrdNKK:SetValue('NKK_SEGLQD', nSegLqd							)
				oGrdNKK:SetValue('NKK_DSPLQD', nDspLqd							)
				oGrdNKK:SetValue('NKK_SLDTIT', ( xBrowseEnt:Alias())->TIT_SALDO	)

				oGrdNKK:SetValue('NKK_SLDFIX', ( xBrowseEnt:Alias())->VRTITFIXDO   	- (xBrowseEnt:Alias())->VRFIX_OPOR 	)
				oGrdNKK:SetValue('NKK_SLDFRE', ( xBrowseEnt:Alias())->VRFRETE 		- ( xBrowseEnt:Alias())->VRFRE_OPOR	)
				oGrdNKK:SetValue('NKK_SLDSEG', ( xBrowseEnt:Alias())->VRSEGURO 		- ( xBrowseEnt:Alias())->VRSEG_OPOR	)
				oGrdNKK:SetValue('NKK_SLDDSP', ( xBrowseEnt:Alias())->VRDESPESA 	- ( xBrowseEnt:Alias())->VRDSP_OPOR	)
				oGrdNKK:SetValue('NKK_ACRESC',nAcresc																	)
				oGrdNKK:SetValue('NKK_DECRES',nDecresc																	)


				IF nVrRestant > 0 							// Se tem Vr. Restante Abasteço variaveis que indica o q Já Baixei deste titulo
					nVrJaEmLqd += nVrLiqd
					nFreJaLqd  += nFreLqd
					nSegJaLqd  += nSegLqd
					nDspJaLqd  += nDspLqd
				Else										// Se n. tem eu as Zero 
					nVrJaEmLqd := 0
					nFreJaLqd  := 0
					nSegJaLqd  := 0
					nDspJaLqd  := 0
				EndIF

				IF nVrdistrib == 0 // Se o Vr. a distribuir Zerou Indica que tenho q Mudar de  Linha no GridNN6 Para ver a proxima Parcela
					IF nVrRestant > 0 // Indica que ainda tenho vr. a liquidar no titulo premaneco nele
						//Conout('continuo no titulo ')
					Else 
						( xBrowseEnt:Alias() )->( DbSkip() )
					EndIF

					Exit
				Else  // Inica que tenho ainda Vr. a Distribuir então pulo para o proximo titulo.
					( xBrowseEnt:Alias() )->( DbSkip() )
				EndIF

			EndDO
		EndIf

	Next nX


	FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids

	// Validando o Modelo de dados da NKK que foi atribuido de forma Interna
	oGrdNKK:VldData()
	IF ! oGrdNKK:VldData()
		aErro 		:= oModel:GetErrorMessage()
		oModel:GetModel():SetErrorMessage( , ,,,, aErro[4] + "-" +  aErro[6],,,)
		//Help( ,, STR0011,, cMsgErro , 1, 0,) //"HELP"##"Operação não permitida para Pré-Contratos."
		lContinua := .f.
	EndIF

	IF lContinua 
		IF ! oGrdNN6:VldData()
			aErro 		:= oModel:GetErrorMessage()
			oModel:GetModel():SetErrorMessage('' ,'' ,'', '', '', aErro[4] + "-" +  aErro[6],/*'SOLUCAO*/ ,'', '')
			lcontinua := .f.
		EndIF
	EndIF   
	
Return(lContinua)


/*{Protheus.doc}
Verifica se os Tits. selec. na Tela estão Ok para Liquidar
Verifica se o Registro do tit. n. Está Locdo e Se o Vr. dos
Tits. não estão menores q os Vrs. a Liquidar

@param		nil.
@return   	Array
@author   	Agro
@since    	20/01/0216
@version  	P11
*/

Static Function fTitsLqdOK(  )

	Local oModel        	:= FWModelActive()
	Local oGrdNN6			:= oModel:GetModel( "NN6UNICO" )
	Local oGrdNKK			:= oModel:GetModel( "NKKUNICO" )

	Local lContinua := .t.
	Local cAux		:= ''
	Local nX		:= 0
	Local nZ		:= 0
	Local aSaveLines:= {}
	Local nVrLqdAux	:= 0
	Local nRecnoTIT	:= 0
	Local nSE2Saldo	:= 0

	aSaveLines := FWSaveRows() // Salva a posição de todos os Grids

	IF ( xTpCtrato == CTRATOCPRA )
		For nX := 1 to oGrdNN6:Length()
			oGrdNN6:GoLine( nX )

			If oGrdNN6:IsDeleted()
				Loop
			EndIF

			For nZ := 1 to  oGrdNKK:Length()
				oGrdNKK:GoLine( nZ )
				IF oGrdNKK:IsDeleted()
					Loop
				EndIF

				// Vr. do Titulo a Liquidar = Vr. fixado a Liquidar + Vr. do Frete + Vr. Seguro + Vr. Despesa //
				nVrLqdAux := oGrdNKK:GetValue('NKK_VRLQDF') + oGrdNKK:GetValue('NKK_FRELQD') + oGrdNKK:GetValue('NKK_SEGLQD') + oGrdNKK:GetValue('NKK_DSPLQD')

				//Encontrando o Recno do titulo
				nRecnoTIT := 0
				nRecnoTIT := OG360RgTIT( oGrdNKK:GetValue('NKK_TABLQD'), oGrdNKK:GetValue('NKK_CPOTIT'),oGrdNKK:GetValue('NKK_CHVTIT')  )

				SE2->( DbGoto(nRecnoTIT) )
				IF nRecnoTIT =  0
					//IF ! SE2->(MSSeek( oGrdNKK:GetValue('NKK_CHVTIT') ))    //Contem Recno do Tit a Liquidar
					Help( ,, STR0011,, STR0077 + '[' + SE2->E2_NUM + '/' + SE2->E2_PARCELA + ']' , 1, 0,) //"HELP"##Titulo está sendo atualizado por outro processo. Aguarde e tente novamente;Titulo/Parcela:' + '[' +SE2->E2_NUM + "/" E2_PARCELA + ']'
					lContinua:= .f.
					Exit
				EndIF

				//IF lContinua .and.  SE2->E2_SALDO <  nVrLqdAux 
				nSE2Saldo := IIF(SE2->E2_STATUS == "A", SE2->E2_SALDO + SE2->E2_ACRESC - SE2->E2_DECRESC, SE2->E2_SALDO )
				IF lContinua .and.  !(nSE2Saldo = oGrdNKK:GetValue('NKK_SLDTIT'))
					cAux := '[' + SE2->E2_NUM + '/' + SE2->E2_PARCELA + '/' + SE2->E2_PREFIXO + '/' + SE2->E2_FORNECE + '-' + SE2->E2_LOJA + ']'
					Help( ,, STR0011,, STR0078 + cAux , 1, 0,) //"HELP"##Titulo está sendo atualizado por outro processo. Aguarde e tente novamente;Titulo/Parcela:' + '[' +SE2->E2_NUM + "/" E2_PARCELA + ']'
					lContinua := .f.
					Exit
				EndIF
			nExt nZ
			IF !lContinua
				Exit
			EndIF
		nExt NX
	ElseIF ( xTpCtrato == CTRATOVND )
		For nX := 1 to oGrdNN6:Length()
			oGrdNN6:GoLine( nX )

			If oGrdNN6:IsDeleted()
				Loop
			EndIF
			For nZ := 1 to  oGrdNKK:Length()
				oGrdNKK:GoLine( nZ )
				IF oGrdNKK:IsDeleted()
					Loop
				EndIF

				// Vr. do Titulo a Liquidar = Vr. fixado a Liquidar + Vr. do Frete + Vr. Seguro + Vr. Despesa //
				nVrLqdAux := oGrdNKK:GetValue('NKK_VRLQDF') + oGrdNKK:GetValue('NKK_FRELQD') + oGrdNKK:GetValue('NKK_SEGLQD') + oGrdNKK:GetValue('NKK_DSPLQD')

				//Encontrando o Recno do Titulo
				nRecnoTIT := 0
				nRecnoTIT := OG360RgTIT( oGrdNKK:GetValue('NKK_TABLQD'), oGrdNKK:GetValue('NKK_CPOTIT'),oGrdNKK:GetValue('NKK_CHVTIT')  )

				SE1->( DbGoto(nRecnoTIT) )
				IF nRecnoTit = 0
					Help( ,, STR0011,, STR0077 + '[' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + ']' , 1, 0,) //"HELP"##Titulo está sendo atualizado por outro processo. Aguarde e tente novamente;Titulo/Parcela:' + '[' +SE1->E1_NUM + "/" E1_PARCELA + ']'
					lContinua:= .f.
					Exit
				EndIF
				IF lContinua .and.  SE1->E1_SALDO <  oGrdNKK:GetValue('NKK_SLDTIT')
					cAux := '[' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_PREFIXO + '/' + SE1->E1_FORNECE + '-' + SE1->E1_LOJA + ']'
					Help( ,, STR0011,, STR0078 + cAux , 1, 0,) //"HELP"##Titulo está sendo atualizado por outro processo. Aguarde e tente novamente;Titulo/Parcela:' + '[' +SE1->E1_NUM + "/" E1_PARCELA + ']'
					lContinua := .f.
					Exit
				EndIF
			nExt nZ
			IF !lContinua
				Exit
			EndIF
		nExt NX
	EndIF
Return( lContinua )

/** {Protheus.doc} fGerTrbTIT
Função que Cria o Arq. de auxilio, que será utilizado pelo
browse Mark xBrowseEnt

@param: 	Nil
@return:	Arquivo Gerado
@author: 	Emerson
@since: 	18/02/2015
@Uso: 		Agro (oga430)
*/
Static Function fGerTrbTit()
	Local aFieldsTRB 	:= {}
	Local aIndice		:= {}
	Local cTITQUERY		:= GetNextAlias()
	Local  cQuery		:= IIF( xTpCtrato == CTRATOVND, fQrySe1NEW(), fQrySe2NEW() )
	Local  aTamSX3		:={}

	CursorWait()

	aAdd( 	aFieldsTRB , { 'MARCA',			'C', 				4,					0} ) 					// -- Campo que obtera a Marca 		//
	aAdd( 	aFieldsTRB , { 'TABORG',		'C', 				3,					0} ) 					// -- Tabela de origme NNC / NKC 	//
	aAdd( 	aFieldsTRB , { 'SEQDEBAIXA',	'C', 				1,					0} ) 					// -- Indica a Seq. de Baixa		//

	aAdd( 	aFieldsTRB , { 'CPOSORIGEM',	'C', 				200,				0} ) 					// -- Cpos que Compoe a ChveOrigem		//	
	aAdd( 	aFieldsTRB , { 'CHVEORIGEM',	'C', 				200,				0} ) 					// -- Chave do Reg. de Origem			//

	aAdd( 	aFieldsTRB , { 'CPOSTIT',		'C', 				200,				0} ) 					// -- Campos que compoe a Chave do tit	//
	aAdd( 	aFieldsTRB , { 'TITCHAVE',		'C',				200,				0} ) 					// -- Chave Da Tabela SE2/SE1			//


	aTamSX3 := TamSX3('NJM_CODROM')
	aAdd( 	aFieldsTRB , { 'ROMANEIO',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} ) 				// -- Nr. do Romaneio

	aTamSX3 := TamSX3('NJM_ITEROM')
	aAdd( 	aFieldsTRB , { 'ITEMROMAN',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} ) 				// -- Item do Romaneio

	aTamSX3 := TamSX3('NNC_QTDENT')
	aAdd( 	aFieldsTRB , { 'QTENTREGA',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} ) 				// -- Item do Romaneio

	aTamSX3 := TamSX3('NNC_QTDFIXD')
	aAdd( 	aFieldsTRB , { 'QTFIXDA',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} ) 				// -- Item do Romaneio

	aTamSX3 := TamSX3('E2_NUM')
	aAdd( 	aFieldsTRB , { 'TIT_NUM',	   		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Nr. do titulo

	aTamSX3 := TamSX3('E2_PARCELA')
	aAdd( 	aFieldsTRB , { 'TIT_PARCEL',		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- PARCELA

	aTamSX3 := TamSX3('E2_PREFIXO')
	aAdd( 	aFieldsTRB , { 'TIT_PREFIX',		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Tit.Prefixo

	aTamSX3 := TamSX3('NNC_VRENPF')
	aAdd( 	aFieldsTRB , { 'VRTITFIXDO',		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. Fixado

	aTamSX3 := TamSX3('D1_TOTAL')
	aAdd( 	aFieldsTRB , { 'VRFRETE',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. FRETE

	aTamSX3 := TamSX3('D1_TOTAL')
	aAdd( 	aFieldsTRB , { 'VRSEGURO',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. SEGURO

	aTamSX3 := TamSX3('D1_TOTAL')
	aAdd( 	aFieldsTRB , { 'VRDESPESA',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. DESP. ACESSORIA

	aTamSX3 := TamSX3('NNC_VRENPF')
	aAdd( 	aFieldsTRB , { 'VRFIX_OPOR',		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. Fixado q já se encontra em OP ou OR	//

	aTamSX3 := TamSX3('NNC_FREFIN')
	aAdd( 	aFieldsTRB , { 'VRFRE_OPOR',		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. FRETE	 q já se encontra em OP ou OR	//

	aTamSX3 := TamSX3('NNC_SEGFIN')
	aAdd( 	aFieldsTRB , { 'VRSEG_OPOR',		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. SEGURO q já se encontra em OP ou OR	//

	aTamSX3 := TamSX3('NNC_DSPFIN')
	aAdd( 	aFieldsTRB , { 'VRDSP_OPOR',		aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. SEGURO q já se encontra em OP ou OR	//

	aTamSX3 := TamSX3('E2_SALDO')
	aAdd( 	aFieldsTRB , { 'TIT_SALDO',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Saldo do tit.	//

	aTamSX3 := TamSX3('E2_SALDO')
	aAdd( 	aFieldsTRB , { 'VRLQDFIX',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. fixado a Liqdar	//

	aTamSX3 := TamSX3('E2_SALDO')
	aAdd( 	aFieldsTRB , { 'VRLQACRE',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. a Acrescer na liquidação //

	aTamSX3 := TamSX3('E2_SALDO')
	aAdd( 	aFieldsTRB , { 'VRLQDECR',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. a decrescer na Liquidação //


	aTamSX3 := TamSX3('NNC_FREFIN')
	aAdd( 	aFieldsTRB , { 'VRLQDFRE',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. Frete a Liqdar	//

	aTamSX3 := TamSX3('NNC_SEGFIN')
	aAdd( 	aFieldsTRB , { 'VRLQDSEG',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. Frete a Liqdar	//

	aTamSX3 := TamSX3('NNC_SEGFIN')
	aAdd( 	aFieldsTRB , { 'VRLQDDSP',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. Despesa a Liqdar	//

	aTamSX3 := TamSX3('E2_SALDO')
	aAdd( 	aFieldsTRB , { 'VRLQDTIT',			aTamSX3[3],			aTamSX3[1],	aTamSX3[2]} )				// -- Vr. Do Titulo que será Liquidado	//
	// -- As vezes por questoes de Ajuste de Calculo
	// -- Teremos o Vr. a liquidar diferente da soma	
	// dos Cpos VRLQDFIX + VRLQDFRE + VRLQDSEG + VRLQDDSP
	// Pq pode ser que a fixação diga que esperamos um vr. X e no
	// financeiro o tiulo e x - 0.01 centavos ou u = 0,01 centavos.
	// -- Abrindo a Query no Banco e Retornando os Dados
	IF Select( cTitQUERY ) != 0
		(cTitQUERY)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,, cQuery ),cTitQUERY,.F.,.T.)
	// -- Query Aberta

	// -- Verifica se o TRB Esta Aberto se estiver ao envez de Fehcar e Cria-lo novamente eu Evito Criar TRB Crio somente qdo  ainda não existe --//
	If Select( xTrbTits ) > 0
		DbSelectArea( xTrbTits )
		//		Zap
	Else
		//Elimina a tabela temporária
		AGRDLTPTB(oTrbTits)

		xTrbTits    := GetNextAlias()
		aadd(aIndice, {"IND360","ROMANEIO+ITEMROMAN+TIT_NUM"})
		oTrbTits    := AGRCRTPTB(xTrbTits, {aFieldsTRB, aIndice} /* Campos / Indices */ )
		dbSelectArea(xTrbTits)	
	EndIF

	// -- Trb Criado

	// Lendo Query Até o fim Para Gravar no TRB
	(cTitQUERY)->( DbGotop() )
	While (cTitQUERY)->( !EOF() )
		RecLock( xTRBTITS, .T. )
		(XTRBTITS)->MARCA			:= ''
		(XTRBTITS)->TABORG		:= (cTitQUERY)->TABELA
		(XTRBTITS)->SEQDEBAIXA	:= (cTitQUERY)->SEQDEBAIXA
		IF (cTitQUERY)->TABELA == 'NNC'
			(XTRBTITS)->CPosOrigem	:= 'NNC_FILIAL/NNC_CODCTR/NNC_ITEMFX/NNC_CODROM/NNC_ITEROM'
			(XTRBTITS)->ChveOrigem	:= fWxFilial('NNC') + '/' + (cTitQUERY)->CONTRATO + '/' + NN8->NN8_ITEMFX + '/' + (cTitQUERY)->ROMANEIO + '/' + (cTitQUERY)->ITEMROMAN
		ElseIF (cTitQUERY)->TABELA == 'NKC'
			(XTRBTITS)->CPosOrigem	:= 'NKC_FILIAL/NKC_CODCTR/NKC_ITEMFX/NKC_CODROM/NKC_ITEROM/NKC_ITEM'
			(XTRBTITS)->ChveOrigem	:= fWxFilial('NKC') + '/' + (cTitQUERY)->CONTRATO +  '/' + NN8->NN8_ITEMFX + '/' + (cTitQUERY)->ROMANEIO + '/' + (cTitQUERY)->ITEMROMAN + '/' + (cTitQUERY)->ITSEQ
		EndIF        

		(XTRBTITS)->Romaneio			:= (cTitQUERY)->ROMANEIO
		(XTRBTITS)->ITEMROMAN			:= (cTitQUERY)->ITEMROMAN

		(XTRBTITS)->QTFIXDA				:= (cTitQUERY)->QTFIXDA
		(XTRBTITS)->QTENTREGA			:= (cTitQUERY)->QTENTREGA

		(XTRBTITS)->VRTITFIXDO			:= (cTitQUERY)->VRTITFIXDO / (cTitQUERY)->QTD_PARCELA

		(XTRBTITS)->VRFRE_OPOR			:= (cTitQUERY)->VRFRE_OPOR
		(XTRBTITS)->VRSEG_OPOR			:= (cTitQUERY)->VRSEG_OPOR
		(XTRBTITS)->VRDSP_OPOR			:= (cTitQUERY)->VRDSP_OPOR

		(XTRBTITS)->VRLQDFIX			:= 0
		(XTRBTITS)->VRLQDFRE			:= 0
		(XTRBTITS)->VRLQDSEG			:= 0
		(XTRBTITS)->VRLQDDSP			:= 0

		(XTRBTITS)->VRLQDTIT			:= 0

		(XTRBTITS)->VRLQACRE			:= 0
		(XTRBTITS)->VRLQDECR			:= 0

		(XTRBTITS)->VRFRETE				:= (cTitQUERY)->FRETE   / (cTitQUERY)->QTD_PARCELA
		(XTRBTITS)->VRSEGURO			:= (cTitQUERY)->SEGURO  / (cTitQUERY)->QTD_PARCELA
		(XTRBTITS)->VRDESPESA			:= (cTitQUERY)->DESPESA / (cTitQUERY)->QTD_PARCELA

		IF xTpCtrato == CTRATOCPRA
			If (cTitQUERY)->E2_SALDO = 0
                (XTRBTITS)->VRFIX_OPOR			:= (cTitQUERY)->E2_VALOR
            else
                (XTRBTITS)->VRFIX_OPOR			:= (cTitQUERY)->E2_VALOR - (cTitQUERY)->E2_SALDO
            EndIf

            (XTRBTITS)->TIT_NUM			:= (cTitQUERY)->E2_NUM
			(XTRBTITS)->TIT_PARCEL		:= (cTitQUERY)->E2_PARCELA
			(XTRBTITS)->TIT_PREFIX		:= (cTitQUERY)->E2_PREFIXO

			If (cTitQUERY)->E2_STATUS == "A" //titulo aberto -- analisado que qdo titulo aberto se houver decrescimo/acrescimeto não atualiza saldo, somente após alguma movimentação do titulo
				(XTRBTITS)->TIT_SALDO		:= (cTitQUERY)->E2_SALDO  + (cTitQUERY)->E2_ACRESC - (cTitQUERY)->E2_DECRESC
			Else
				(XTRBTITS)->TIT_SALDO		:= (cTitQUERY)->E2_SALDO 
			EndIf  

			(XTRBTITS)->CposTit			:= 'E2_FILIAL/E2_PREFIXO/E2_NUM/E2_PARCELA/E2_TIPO/E2_FORNECE/E2_LOJA'
			(XTRBTITS)->TITCHAVE		:= (cTitQUERY)->E2_FILIAL + '/' + (cTitQUERY)->E2_PREFIXO + '/' +  (cTitQUERY)->E2_NUM + '/' + (cTitQUERY)->E2_PARCELA + '/' + (cTitQUERY)->E2_TIPO + '/'  + (cTitQUERY)->E2_FORNECE + '/' + (cTitQUERY)->E2_LOJA
		ELSEIF xTpCtrato == CTRATOVND
			(XTRBTITS)->TIT_NUM			:= (cTitQUERY)->E1_NUM
			(XTRBTITS)->TIT_PARCEL		:= (cTitQUERY)->E1_PARCELA
			(XTRBTITS)->TIT_PREFIX		:= (cTitQUERY)->E1_PREFIXO

			If (cTitQUERY)->E1_SALDO = 0
                (XTRBTITS)->VRFIX_OPOR			:= (cTitQUERY)->E1_VALOR
            else
                (XTRBTITS)->VRFIX_OPOR			:= (cTitQUERY)->E1_VALOR - (cTitQUERY)->E1_SALDO
            EndIf

            (XTRBTITS)->TIT_SALDO		:= (cTitQUERY)->E1_SALDO  + (cTitQUERY)->E1_ACRESC - (cTitQUERY)->E1_DECRESC

			(XTRBTITS)->CposTit			:= 'E1_FILIAL/E1_PREFIXO/E1_NUM/E1_PARCELA/E1_TIPO/E1_CLIENTE/E1_LOJA'
			(XTRBTITS)->TITCHAVE		:= (cTitQUERY)->E1_FILIAL + '/'  + (cTitQUERY)->E1_PREFIXO + '/' + (cTitQUERY)->E1_NUM + '/' + (cTitQUERY)->E1_PARCELA + '/' + (cTitQUERY)->E1_TIPO + '/' + (cTitQUERY)->E1_CLIENTE + '/' + (cTitQUERY)->E1_LOJA
		EndIF

		(XTRBTITS)->( MsUnlock() )

		(cTitQUERY)->( DbSkip() )
	Enddo

	(cTitQUERY)->( DbCloseArea() )

	CursorArrow()

Return( nil )

/** {Protheus.doc} OG360RTits()
Função Auxiliar que re-monta o TRB do Grid de Entregas,
Buscando Vrs. de Saldos Atuais dos Tits.

@param: 	Nil
@return:	Arquivo Gerado
@author: 	Emerson
@since: 	18/02/2015
@Uso: 		Agro (oga430)
*/
Static Function OG360RTits ()
	fGerTrbTIT()     //Gerando /Refresh TRB da SE2/SE1
	xBrowseEnt:Refresh()
	SelTitLiq('NN5_QTDFIN')

Return

/** {Protheus.doc} FTratarDif
Função que dá opção de Utilizar Acrescimo / decrescimo
Qdo ocorrer dif. entre o Vr. total liquido das Entregas
e o Vr. total liquido calculado pela Fixação que saiu na
Boleta de fixação;
@param: 	nVrOPOR 	- Vr. da Ordem de Pagto/REc esse vr. sempre é calulado baseado na QTD;
nVrTitsEnt	- Vr. Liquido dos tituslo no financeiro correspondente as Entregas da Fixação
nVrAcres	- Variavel Ponteiro, q conterá o Vr. a Acrescer
nVrDecres	- Variavel Ponteiro, q conterá o Vr. a Decrescer
@return:	.t. (Verdadeiro) ->  Acresce ou Decresc a dif. nos titulos
.f. Simplesmente -> não continua o Processo
@author: 	Emerson Coelho
@since: 	27/01/2014
@Uso: 		Modulo 12 Loja
*/

static function FTratarDif(nVrOPOR,nVrTitsEnt, nVrAcres, nVrDecre)
	Local aCords 		:= FWGetDialogSize( oMainWnd )
	Local oFwLayer		:= Nil
	Local lContinua		:= .F.
	Local cEOL     		:= Chr(13)+Chr(10)
	Local nDif			:= 0

	// --- 			Vars Aux do obj Tfont 		---
	Local cName 		:= 'Courier New'//'Verdana'
	Local nWidth 		:=  07
	Local nHeight 		:= -12
	Local lBold 		:= .T.
	Local lUnderline	:= .F.
	Local lItalic 		:= .F.
	// ---------------------------------------------

	Default nVrOPOR		:= 100			//somente para Testes
	Default nVrTitsEnt	:= 99.99		// Somente para Testes

	oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ]/2.3, aCords[ 4 ]/2, STR0079, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Ordem de Pagamento / Recebimento"
	oDlg:lEscClose := .F.

	//--<< Cria Layer >>--
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	//--<<Cria 2  colunas no Layer>>--
	oFwLayer:addCollumn('Col01',100,.F.)

	//--<< Cria 2 Janelas na Coluna da Esquerda do Layer >>--
	oFwLayer:addWindow('Col01','C1_Win01',STR0080,100,.f.,.F.,{|| Alert(STR0081) },,{|| Alert(STR0082) }) // "Atenção"###"Clique janela 01!"###"Janela 01 recebeu foco!"

	//--<< pega o Painel das duas Janelas que estão na coluna 1 do Layer >>>--
	oPanel := oFwLayer:getWinPanel('Col01','C1_Win01')  // Get panel da Janela esquerda de cima

	IF nVrOPOR > nVrTitsEnt
		nVrAcres := nVrOPOR - nVrTitsEnt
	ElseIF nVrTitsEnt < nVrOPOR
		nVrDecre :=  nVrTitsEnt - nVrOPOR
	EndIF

	cMsg	:= STR0083 + '	:' +  Transform(nVROPOR ,PesqPict('SE1', 'E1_VALOR') ) + cEOL //'O Sistema identificou que o Vr. da Ordem Pagto / Recebimento'
	IF nVrOPOR > nVrtitsEnt
		cMsg	+= STR0084 //'É maior '
	ElseIF nVrOPOR < nVrtitsEnt
		cMsg	+= STR0085 //'É menor '
	EndIF
	cMsg += STR0086 + '	:'  +  Transform(nVrtitsEnt ,PesqPict('SE1', 'E1_VALOR') )  + cEOL //'que o Valor do saldo dos títulos das entregas'
	cMsg += STR0087 + '	:' +  Transform(nVrOPOR - nVrtitsEnt ,PesqPict('SE1', 'E1_VALOR') ) + cEOL //'Resultando em diferença Entre o Vr.Fixado - Vrs. das Entregas'
	cMsg += '' + cEOL
	cMsg += STR0088 + IIF( nVrOPOR > nVrtitsEnt, STR0089, STR0090) + STR0091 + cEOL //'O que significa que a soma dos tits. do financeiro das entregas estão '###'Menor'###'Maior'###' que o valor'
	cMsg += STR0092 //'encontrado no cálculo da Fixação.' 
	cMsg += '' + cEOL
	cMsg += '' + cEOL

	IF nDif<= 0.10   //Até 10 centavos deixamos a opção de fazer acrescimo no financeiro
		IF nVrAcres > 0
			cMsg += STR0093 + cEOL //'Deseja  efetuar acrescimo financeiro, para que a composição dos valores dos títulos, se'
		ElseIF nVrDecre > 0
			cMsg 	+= STR0094 + cEOL //'Deseja efetuar decrescimo financeiro, para que a composição dos valores dos títulos, se'
		EndIF
		cMsg += STR0095 + cEOL //'equipare ao cálculo realizado na fixação?'

		oBtnConfir	:= TButton():New( 085,240,STR0096,oPanel,{|| lContinua := .T., oDlg:End()},037,010,,,,.T.,,"",,,,.F. ) //"Confirmar"
	EndIF

	oBtnFechar	:= TButton():New( 085,280,STR0097,oPanel,{|| lContinua := .f., oDlg:End()},037,010,,,,.T.,,"",,,,.F. ) //"Fechar   "

	// Texto em Negrito
	cName := 'Courier New'//'Verdana'
	nWidth :=  07
	nHeight := -12
	lBold := .T.
	lUnderline := .F.
	lItalic := .F.
	oTFont := TFont():New(cName,nWidth,nHeight,,lBold,,,,,lUnderline,lItalic)

	//    oTSay := TSay():New( 14,01,{||'Texto em Negrito'},oDlg;               ,,oTFont,.T.,.F.,.F.,.T.,0,,250,20,.F.,.T.,.F.,.F.,.F.,.F. )

	@ 005, 005 SAY oSay1 PROMPT cMsg SIZE 400, 075 OF oPanel COLORS 0, 16777215 PIXEL
	oSay1:oFont:= oTfont
	//DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION (lSelecao := .F., oDlg:End()) ENABLE OF oDlg

	//ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	oDlg:Activate( , , , .t., { || .t. }, , { || } )

	IF lcontinua
		xVrAcresLq	:=	nVrAcres
		xVrDecreLq	:= nVrDecre
	EndIF

	RETURN( lContinua )
	******************

/** {Protheus.doc} fGetRegORG
Função que retorna o RECNO de Origem

@param: 	Tabela,Cpos da Chave, e Dados da Chave
@return:	Recno
@author: 	Marlon Richard Trettin
@since: 	06/11/2014
@Uso: 		OGA360
*/
Static Function fGetRegORG( cTab, cCPosChv,cChave  )

	Local cAliasQry 	:= GetNextAlias()
	Local aCposChv		:= Separa(cCPosChv,'/') 
	Local aChave		:= Separa(cChave,'/')
	Local cQuery		:= ''
	Local cFiltro		:= ''
	Local nI			:= 0
	Local nRetorno		:= 0

	For nI := 1 to Len( aCposChv )
		IF nI = 1
			cFiltro += ' WHERE '
		Else
			cFiltro += ' AND   '
		EndIF

		cFiltro += AllTrim( aCposChv[ nI ] ) + " = '" + Alltrim( aChave[ nI ] ) + "' "
	nExt nI

	cQuery := " SELECT R_E_C_N_O_ AS NRECNO FROM " + RetSqlName( cTab )
	cQuery += cFiltro
	cQuery += " AND D_E_L_E_T_ = ' ' "

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	(cAliasQry)->( DbGoTop() )

	nRetorno := (cAliasQry)->nRecno 

	(cAliasQry)->( DbCloseArea() )

Return( nRetorno )

/** {Protheus.doc} fGetRegTIT
Função que retorna o RECNO do Titulo

@param: 	Tabela,Cpos da Chave, e Dados da Chave
@return:	Recno
@author: 	Marlon Richard Trettin
@since: 	06/11/2014
@Uso: 		OGA360
*/
Function OG360RgTIT( cTab, cCPosChv,cChave  )
	Local cAliasQry 	:= GetNextAlias()
	Local aCposChv		:= Separa(cCPosChv,'/') 
	Local aChave		:= Separa(cChave,'/')
	Local cQuery		:= ''
	Local cFiltro		:= ''
	Local nI			:= 0
	Local nRetorno		:= 0

	For nI := 1 to Len( aCposChv )
		IF nI = 1
			cFiltro += ' WHERE '
		Else
			cFiltro += ' AND   '
		EndIF

		cFiltro +=  Alltrim( aCposChv[ nI ] ) + " = '" + Alltrim( aChave[ nI ] ) + "' "
	nExt nI

	cQuery := " SELECT R_E_C_N_O_ AS NRECNO FROM " + RetSqlName( cTab )
	cQuery += cFiltro
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	(cAliasQry)->( DbGoTop() )

	nRetorno := (cAliasQry)->nRecno 

	(cAliasQry)->( DbCloseArea() )

Return( nRetorno )



/** {Protheus.doc} fIniStatic
função que inicializa as Vars Staticas no Ini do modelo, pois
qdo Inserimos/deletamos se as alteramos elas permanecem com
o vr. alterado

@param: 	nil
@return:	nil
@author: 	Marlon Richard Trettin
@since: 	06/11/2014
@Uso: 		OGA360
*/

Static function fIniStatic()

	xTpCtrato	:=  nil
	xTpLiq		:=  nil   	//Apartir do chamado TUDBDE, Utilizou-se uma outra forma de selecionar os titulos para Liquidação  1 = Atual, 0=Sera Anterior
	xBrowseEnt	:=  Nil   	// Ira conter o Browse das Entregas

	xVrMrkdo  	:=  0		//Irá conter o total fixado dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot
	xVrMrkFre 	:=  0		//Irá conter o total de Frete  a  Baixar dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot
	xVrMrkSeg 	:=  0		//Irá conter o total de Seguro a  Baixar dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot
	xVrMrkDsp 	:=  0		//Irá conter o total de DSP    a  Baixar dos titulos selecioados , (xVrMrkdo + xVrMrkFre + xVrMrkSeg + xVrMrkDsp ) nunca pode ser maior Que o nnn5_vlrtot

	xTRBTITS  	:= nil 		//Irá conter o Arquivo de trabalho temporario
	xVrAcresLq	:= 0		//Irá conter Acrescimo  da Liquidação caso contenha
	xVrDecreLq	:= 0		//Irá conter Decrescimo da Liquidação caso contenha
	xVrDifCalc	:= 0.05		// Dif. entre vr. calc. pela fixacao e vr do tit. considerada normal devido ao calc. impostos

	xVrFrete	:= 0		// Irá conter o Vr. total de Frete  	da OP/OR
	xVrSeguro	:= 0		// Irá Conter o Vr. total de Seguro 	da OP/OR
	xVrDespesa	:= 0		// Irá conter o Vr. total de Desp.Acess da OP/OR

	xConsidFre	:=	.f. 	// Indica que deve Considerar o Frete 	para Liquidar ( Var Ajustada na funcao iniModelo de acordo com o parametro MV_OGLQDSP )
	xConsidSEG	:=	.f. 	// Indica que deve Considerar o Seguro para Liquidar ( Var Ajustada na funcao iniModelo de acordo com o parametro MV_OGLQDSP )
	xConsidDsp	:=	.f. 	// Indica que deve Considerar a Despesa acessoria  para Liquidar ( Var Ajustada na funcao iniModelo de acordo com o parametro MV_OGLQDSP )
	xlUltOPOR	:= 	.f.		//Indica se é a Ultima a OPOR

Return

/** {Protheus.doc} OGA360ENT
Descrição:  Validação para verificar se entidade está valida
@param:     Nil
@author:    Ana Laura Olegini
@since:     03/05/2016
@Uso:       OGA270 
*/
Static Function OGA360ENT( cCodEnt, cLojEnt, cTipo)
	Local lContinua := .T.

	//Acessa a tabela de entidades para a verificação
	DbSelectArea("NJ0") // Entidades
	NJ0->(dbSetOrder(1))
	If NJ0->(dbSeek(xFilial("NJ0")+cCodEnt+cLojEnt))
		//Verifica se esta ativo
		If NJ0->(NJ0_ATIVO) == '2' // 1=Ativo; 2=Inativo
			Help(,,STR0013,,STR0048+NJ0->(NJ0_CODENT)+" "+NJ0->(NJ0_LOJENT),1,0) 		//"AJUDA"#"Cadastro de Entidade está INATIVO e não pode ser usado para esta função. Verifique o cadastro da entidade: "
			Return( .F. )
		EndIf		

		If cTipo == '1'			//COMPRA
			lContinua := AgrEntidOk( "SA2", cCodEnt, cLojEnt )
		ElseIf cTipo == '2'		//VENDA
			lContinua := AgrEntidOk( "SA1", cCodEnt, cLojEnt )
		EndIf

	EndIf
	If !lContinua
		Help(,,STR0013,,STR0049+cCodEnt+" "+cLojEnt,1,0) 								//"AJUDA"#"Entidade não localizada no cadastro de Entidades (NJ0): "
		Return( .F. )
	EndIf

Return(lContinua)

/** {Protheus.doc} OG360VdEn
Função para gatilho de favorecido

@param:     Nil
@author:    Ana Laura Olegini
@since:     12/08/2014
@Uso:       SIGAAGR - Originação de Grãos
*/ 
Function OG360VdEn()
	Local aAreaAtu  := GetArea()
	Local lContinua	:= .T.
	Local oModel    := FwModelActive()
	Local oNN5 		:= oModel:GetModel("NN5UNICO")
	Local oNN6 		:= oModel:GetModel("NN6UNICO")

	Local cContrato := oNN5:GetValue("NN5_CODCTR")
	Local cCodEntT  := oNN6:GetValue("NN6_CODFAV")
	Local cLojEntT  := oNN6:GetValue("NN6_LOJFAV")   

	Local nLinha    := 0
	Local nX        := 0

	nLinha := oNN6:GetLine()
	For nX := 1 to oNN6:Length()
		oNN6:GoLine( nX )
		If .Not. oNN6:IsDeleted()       

			//Acessa a tabela de Entidade - para verificar se possiu favorecido
			//Contrato de Compra/Arm. Em 3º = o Favorecido é o Fornecedor.
			NJ0->( dbSelectArea("NJ0") )
			NJ0->( dbSetOrder( 1 ) )
			If NJ0->( dbSeek( xFilial( "NJ0" ) + cCodEntT + cLojEntT ) )		    	
				NJR->(dbSelectArea("NJR"))
				NJR->( dbSetOrder( 1 ) )
				If NJR->( dbSeek( xFilial( "NJR" ) + cContrato ) )		      
					If NJR->NJR_TIPO == '1'			//COMPRA
						lContinua := AgrEntidOk( "SA2", cCodEntT, cLojEntT )
					ElseIf NJR->NJR_TIPO == '2'		//VENDA
						lContinua := AgrEntidOk( "SA1", cCodEntT, cLojEntT )
					EndIf
				EndIf
			EndIf			
			oNN6:GoLine( nLinha )
		EndIf
	Next nx

	RestArea (aAreaAtu)
Return( lContinua )


/*{Protheus.doc} fNumDocVin
-- Funcao para retornar a quantidade de romaneios vinculados em uma unica nota

@author 	ana.olegini
@since 		08/08/2016
@version 	1.0
@param		cContrato 	-- contrato 
cDocto		-- documento 
cSerie		-- série do documento
@return 	nQtdade		-- retorno da quantidade de romaneios vinculados na nota
*/
Static Function fNumDocVin(cContrato, cDocto, cSerie)
	Local cAliasVinc 	:= GetNextAlias()
	Local cVinc 		:= ""

	cVinc := "SELECT COUNT(NKC_CODROM) AS QTIDADE  "
	cVinc +=  " FROM "+ RetSqlName("NKC") + " NKC " 
	cVinc += " WHERE NKC.NKC_FILIAL = '" + xFilial( "NKC" ) + "'" 
	cVinc +=   " AND NKC.NKC_CODCTR = '" + cContrato + "'"
	cVinc +=   " AND NKC.NKC_DOCTO  = '" + cDocto	 + "'" 
	cVinc +=   " AND NKC.NKC_SERIE  = '" + cSerie	 + "'" 
	cVinc := ChangeQuery(cVinc)
	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cAliasVinc) <> 0
		(cAliasVinc)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cVinc),cAliasVinc,.T.,.T.)

	//-- Seleciona a tabela
	dbSelectArea(cAliasVinc)
	(cAliasVinc)->(dbGoTop())	

	nQtdade := (cAliasVinc)->QTIDADE

	Return( nQtdade )



	//---------------------------------------------------------------------
	/*/{Protheus.doc} GeraPdComp()
	Gera Pedido de Compra para o Manifesto     

	@author  Thiago Henrique Rover
	@since   26/05/2017
	@version P11
	@return  .T.
	/*/
//---------------------------------------------------------------------

Static Function GeraPdComp()

	Local cAliasQry := GetNextAlias()	
	Local cNumPc    := ""
	Local lMov		:= .F.
	Local cCodLocal
	Local nDKPMoeda
	Local oModel    := FwModelActive()
	Local oNN5 		:= oModel:GetModel("NN5UNICO")
	Local cCodTES	:= ""
	Local cProduto
	private lMsErroAuto := .F.
	private lMSHelpAuto := .T. // para mostrar os erros na tela

	nModulo := 2
	
	dbSelectArea("NJR")
	dbSetOrder(1)
	If dbSeek(xFilial("NJR")+IIF(Inclui,M->NN5_CODCTR,NN5->NN5_CODCTR))
		If !Empty(NJR->NJR_TESFIN)
			cCodTES := NJR->NJR_TESFIN
		Else
			cCodTES := NJR->NJR_TESEST
		EndIf
		nDKPMoeda := NJR->NJR_MOEDA
		cProduto := NJR->NJR_CODPRO
		cCodFor := Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODFOR") 
		cCodLoj := Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJFOR")	
	EndIf

	dbSelectArea("NJJ")
	dbSetOrder(1)
	If MsSeek(FwxFilial("NJJ")+NNC->NNC_CODROM)
		cCodLocal := NJJ->NJJ_LOCAL
	EndIf
	
	If Empty(cCodLocal)
		cCodLocal := Posicione("SB1",1,FWxFilial("SB1")+cProduto,"B1_LOCPAD")
	Endif

	If Inclui
		cNumPc :=  SOMA1(GetSxeNum("SC7","C7_NUM"))
	Else
		cNumPc := NN5->NN5_PEDIDO
    	cQuery := "SELECT SC7.C7_NUM, SC7.C7_QUJE "
		cQuery +=  " FROM "+ RetSqlName("SC7") + " SC7 " 
		cQuery += "WHERE SC7.C7_FILIAL='"+NN5->NN5_FILIAL+"' AND "
		cQuery += "SC7.C7_NUM = '"+cNumPc+"' AND "
		cQuery += "SC7.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY "+SqlOrder(SC7->(IndexKey()))

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
		If !(cAliasQry)->(Eof())
			lMov := IIF((cAliasQry)->C7_QUJE>0,.T.,.F.)
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	
	If lMov
		Help(1," ",STR0080,,STR0098,3,0)
		Return
	Endif
   
	aCab   := {}
	aItens := {}
	aLinha := {}

	aCab:={{"C7_FILIAL"          ,IIF(Inclui, xFilial("SC7"), NN5->NN5_FILIAL),Nil},; //Filial
	{"C7_NUM"                     ,cNumPc        				 				,Nil},; //Número do Pedido
	{"C7_EMISSAO"                 ,dDataBase   					  				,Nil},; //Data da Emissão do Pedido
	{"C7_FORNECE"                 ,cCodFor                                  	,Nil},; //Fornecedor
	{"C7_LOJA"                    ,cCodLoj                                  	,Nil},; //Loja
	{"C7_COND"                    ,IIF(Inclui, M->NN5_CONPAG, NN5->NN5_CONPAG)	,Nil},; //Condição de Pagamento
	{"C7_FILENT"                  ,xFilEnt(xFilial("SC7"))        				,Nil},; //Filial         
	{"C7_TXMOEDA"                 ,NN8->NN8_TXMOED                				,Nil},; //Taxa Moeda
	{"C7_CONTATO"                 ,""    					      				,Nil},; //Contato
	{"C7_MOEDA"                   , nDKPMoeda      								,Nil}}  //Moeda

	aLinha:=   {{"C7_FILIAL"          ,IIF(Inclui, xFilial("SC7"), NN5->NN5_FILIAL),Nil},; //Filial
	{"C7_ITEM"   				  ,NN8->NN8_ITEMFX                										,Nil},; //Item
	{"C7_PRODUTO"                ,NJR->NJR_CODPRO          												,Nil},; //Produto    
	{"C7_UM"					  ,NJR->NJR_UM1PRO         												,Nil},; //Unidade de Medida             
	{"C7_QUANT" 				  ,IIF(Inclui,M->NN5_QTDFIN,NN5->NN5_QTDFIN)    						,Nil},; //Quantidade 
	{"C7_PRECO"                  ,IIF(Inclui,M->NN5_VLRUNI,NN5->NN5_VLRUNI)							    ,Nil},; //Preço
	{"C7_TOTAL"                  ,IIF(Inclui,M->(NN5_VLRUNI*NN5_QTDFIN),NN5->(NN5_VLRUNI*NN5_QTDFIN))	,Nil},; //Total 
	{"C7_LOCAL"                  ,cCodLocal	                  										    ,Nil},; //Local   
	{"C7_CONTATO"                ,""                             										,Nil},; //Contato
	{"C7_DATPRF"                 ,dDataBase                      										,Nil},; //Data de Entrega
	{"C7_TES"                	 ,cCodTES                      										    ,Nil},; //Data de Emissão
	{"C7_MOEDA"                  ,IIF(Inclui,M->NN5_MOEDA,NN5->NN5_MOEDA)							    ,Nil}}  //Moeda   


	//Manipula array antes da chamada de geração do Pedido
	If EXISTBLOCK ("OG360PC")
		aPedido := ExecBlock("OG360PC",.F.,.F.,{aCab,aLinha})
		If ValType(aPedido)== 'A' .and. Len(aPedido) > 0
			aCab 	:= aPedido[1]
			aLinha 	:= aPedido[2]
		EndIf
	Endif
	
	AAdd(aItens, aLinha)
	
	nModulo := 2
	cModulo := 'COM'
	// Carrego pergunte do exec
	Pergunte("MTA120",.F.)
	MSExecAuto({|x, y, z| MATA121(x, y, z)},aCab,aItens,IIF(Inclui,3,5))

	If lMSErroAuto  //Determina se houve alguma inconsistencia na execucao da rotina
		Mostraerro()
		ROLLBACKSX8()
	Else
		If INCLUI
			oNN5:SetValue( "NN5_PEDIDO", SC7->C7_NUM		)
		Endif
	EndIf
		        
   //Retorno os perguntes da tela
	IF xTpCtrato == CTRATOCPRA
		Pergunte("OGA360" , .F.)		//-- Perg. ref. Ordem Pagto				--//
	ElseIF xTpCtrato == CTRATOVND
		Pergunte("OGA360A" , .F.)		//-- Perg. ref. Ordem Recebto				--//
	EndIF	   
	
	nModulo := 67
	cModulo := 'AGR'
	Return !lMSErroAuto

	//---------------------------------------------------------------------
	/*/{Protheus.doc} GeraPdVend()
	Gera Pedido de Venda para o Manifesto     

	@author  Marcos Wagner Junior
	@since   18/05/2017
	@version P12
	@return  .T.
	/*/
//---------------------------------------------------------------------
Static Function GeraPdVend()

	Local cAliasQry   := GetNextAlias()	
	Local cPedido := ""
	Local cCodTES := ""
	Local nDKPMoeda 
	Local oModel    := FwModelActive()
	Local oNN5 		:= oModel:GetModel("NN5UNICO")
	
	//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
	Local lVinculou		:= .f.	
	Private lMsErroAuto := .F.
	Private lMSHelpAuto := .T. // para mostrar os erros na tela

	nModulo := 5

	dbSelectArea("NJR")
	dbSetOrder(1)
	If MsSeek(xFilial("NJR")+IIF(Inclui,M->NN5_CODCTR,NN5->NN5_CODCTR))
		If !Empty(NJR->NJR_TESFIN)
			cCodTES := NJR->NJR_TESFIN
		Else
			cCodTES := NJR->NJR_TESEST
		EndIf
		nDKPMoeda := NJR->NJR_MOEDA
		cCodCli := Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODCLI") 
		cCodLCl := Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJCLI")	
	EndIf

	If Inclui
		cPedido := GetSxeNum("SC5","C5_NUM")
	Else
		cQuery := "SELECT N8H_NUMPV  "
		cQuery +=  " FROM "+ RetSqlName("N8H") + " N8H " 
		cQuery += " WHERE N8H.N8H_FILIAL = '" + FwxFilial("N8H") + "'" 
		cQuery +=   " AND N8H.N8H_ORPGRC  = '" + NN5->NN5_CODOPG	 + "'" 
		cQuery +=   " AND N8H.D_E_L_E_T_  = ' ' " 
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			cPedido := (cAliasQry)->N8H_NUMPV
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	aCab   := {}
	aItens := {}
	aReg   := {}

	aCab := {{"C5_FILIAL"        ,IIF(Inclui,xFilial("SC5"),NN5->NN5_FILIAL),Nil},;  //filial
	{"C5_NUM"        ,cPedido                                   ,Nil},;  // Nro.do Pedido
	{"C5_TIPO"       ,"N"    		                             ,Nil},;  //Tipo de Pedido - Normal
	{"C5_CLIENTE"    ,cCodCli                                   ,Nil},;  //Cod. Cliente	
	{"C5_LOJACLI"    ,cCodLCl                                   ,Nil},;  //Loja Cliente 
	{"C5_TIPOCLI"    ,"N"                                       ,Nil},;  //Tipo Cliente - A=Afeto;N=No Afeto 
	{"C5_TIPOREM"    ,"0"                                       ,Nil},;  //Tipo Cliente - A=Afeto;N=No Afeto Dekalpar
	{"C5_DOCGER"    ,"1"                                       	,Nil},;  //Tipo Cliente - A=Afeto;N=No Afeto Dekalpar
	{"C5_EMISSAO"    ,dDatabase                               	,Nil},;  //Data de Emissão
	{"C5_TABELA"     ,oNN5:GetValue("NN5_TABELA")    	 		,Nil},;  //Validar Dekalpar - NN5-com gatilho
	{"C5_VEND1"    	, NJR->NJR_VENDED                           ,Nil},;  //Validar Dekalpar - Criar no contrato
	{"C5_NATUREZ"   , NJR->NJR_CODSAF                           ,Nil}}  //Validar Dekalpar - Criar no contrato	 

	aReg := {{"C6_FILIAL"        ,IIF(Inclui,xFilial("SC5"),NN5->NN5_FILIAL),Nil},; // Pedido
	{"C6_NUM"        ,cPedido                                 								,Nil},; // Pedido
	{"C6_ITEM"       ,"01"                                    								,Nil},; // Item sequencial
	{"C6_PRODUTO"    ,NJR->NJR_CODPRO                   								,Nil},; // Cod.Item Dekalpar
	{"C6_UM"         ,NJR->NJR_UM1PRO                  								,Nil},; // Unidade Dekalpar
	{"C6_QTDVEN"     ,IIF(Inclui,M->NN5_QTDFIN,NN5->NN5_QTDFIN)							,Nil},; // Quantidade
	{"C6_QTDLIB"     ,IIF(Inclui,M->NN5_QTDFIN,NN5->NN5_QTDFIN)							,Nil},; // Quantidade
	{"C6_PRCVEN"     ,IIF(Inclui,M->NN5_VLRUNI,NN5->NN5_VLRUNI)							,Nil},; // Preco Unit.
	{"C6_VALOR"      ,A410Arred(IIF(Inclui,M->(NN5_VLRUNI*NN5_QTDFIN),NN5->(NN5_VLRUNI*NN5_QTDFIN)), "C6_VALOR" )	,Nil},; // Valor Tot.
	{"C6_TES"        ,cCodTES                                 								,Nil}} // Tipo de Saida
		
	//Manipula array antes da chamada de geração do Pedido
	//aPedido [1] = Cabeçalho
	//aPedido [2] = Itens
	If EXISTBLOCK ("OG360PV")
		aPedido := ExecBlock("OG360PV",.F.,.F.,{aCab,aReg})
		If ValType(aPedido)== 'A' .and. Len(aPedido) > 0
			aCab := aPedido[1]
			aReg := aPedido[2]
		EndIf
	Endif
	
    // Tab. de vinculo dos romaneios //	
	aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 								} )
	aadd( aVincCab, { "N8H_NUMPV"    	, cPedido 										} )
	aadd( aVincCab, { "N8H_CODCTR"    	, (cAliasCTR)->C_CODCTR 						} )
	aadd( aVincCab, { "N8H_CODROM"    	, ''											} )  
	aadd( aVincCab, { "N8H_CODFIX"   	, IIF(Inclui,M->NN5_CODFIX,NN5->NN5_CODFIX)		} )
	aadd( aVincCab, { "N8H_CODOTR"   	, ""											} )
	aadd( aVincCab, { "N8H_ORPGRC"   	, IIF(Inclui,M->NN5_CODOPG,NN5->NN5_CODOPG)		} )
	aadd( aVincCab, { "N8H_ORIGEM"   	, "OGA360"										} )
	aAdd( aVincCab, { "N8H_HISTOR"    	, FWI18NLang("OGA360","STR0058",58) 										} ) //Ordem financeira
					    	
	//Criando Vinculo com SC5 / SC6
	aLinhaVinc := {}
	aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 							} )
	aadd( aLinhaVinc, { "N8I_ITEMPV"    	, '01'										} )
	aadd( aLinhaVinc, { "N8I_PRODUT"    	, SC6->C6_PRODUTO							} )
	aadd( aLinhaVinc, { "N8I_TPPROD"    	, ''			 							} )
	aadd( aLinhaVinc, { "N8I_CODCTR"    	, (cAliasCTR)->C_CODCTR						} )
	aadd( aLinhaVinc, { "N8I_SAFRA"    		, (cAliasSLD)->S_CODSAF						} )
	aadd( aLinhaVinc, { "N8I_CODROM"    	, ''										} )
	aadd( aLinhaVinc, { "N8I_ITEROM"    	, ''										} )
	aadd( aLinhaVinc, { "N8I_CODOTR"   		, ''										} )
	aadd( aLinhaVinc, { "N8I_ITEOTR"   		, ''										} )
	aadd( aLinhaVinc, { "N8I_CODFIX"    	, IIF(Inclui,M->NN5_CODFIX,NN5->NN5_CODFIX) } )
	aadd( aLinhaVinc, { "N8I_ORPGRC"   		, IIF(Inclui,M->NN5_CODOPG,NN5->NN5_CODOPG)	} )	
	aadd( aLinhaVinc, { "N8I_ORIGEM"    	, 'OGA360'		 							} )
	aAdd( aLinhaVinc, { "N8I_HISTOR"    	, FWI18NLang("OGA360","STR0058",58)			} )  //Ordem financeira
					
	aAdd( aVincITE, aLinhaVinc )
	

	aAdd(aItens,aClone(aReg))  

	Begin Transaction

	MSExecAuto({|x,y,z| Mata410(x,y,z)}, aCab, aItens, IIF(Inclui,3,5)) //Opção para Inclusão

	If lMsErroAuto
		DisarmTransaction()
		Mostraerro()	
	Else
		If INCLUI
			oNN5:SetValue( "NN5_PEDIDO", cPedido		)
		Endif
		If __lSX8
			ConfirmSX8()
			lVinculou := fAgrVncPV (aVincCab,aVincITE  , IIF(Inclui,3,5) )  //Incluir,Exluir
			IF .not. lvinculou	
				DisarmTransaction()
				Help(" ",1,"OG360PV") //Não foi possivel Vincular o PV, às tabelas do SigaAGR. Verificque se a tabela N8H/N8I Não possui o PV invormado'
			EndIF
		EndIf
	EndIf
	
	End Transaction   
	
	nModulo := 67
	//Retorno pergunte da tela
	IF xTpCtrato == CTRATOCPRA
		Pergunte("OGA360" , .F.)		//-- Perg. ref. Ordem Pagto				--//
	ElseIF xTpCtrato == CTRATOVND
		Pergunte("OGA360A" , .F.)		//-- Perg. ref. Ordem Recebto				--//
	EndIF	

Return !lMSErroAuto

/*/{Protheus.doc} fSetF11
	Chamada da função F11 e atualização dos campos no modelo
	@type  Static Function
	@author user
	@since 28/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fSetF11(lCompra, oModel)
	Local ofldNN5		:= oModel:GetModel( "NN5UNICO" )
	Local oGrdNN6		:= oModel:GetModel( "NN6UNICO" )
	Local nX            := 0
	Local oView			:= FwViewActive()

	If lCompra
		Pergunte("OGA360",.t.)	//Ref. Ordem de Pagto
	Else		
		Pergunte("OGA360A",.t.) //Ref. Ordem de Recebto	
	EndIf

	ofldNN5:SetValue( "NN5_CONPAG", MV_PAR01 )

	For nX := 1 To oGrdNN6:Length() 
		IF !Empty( MV_PAR02 ) 
			oGrdNN6:LoadValue( "NN6_NATFIN" 	,MV_PAR02)	
		EndIF
	Next nX	
	
	If ValType(oView) != "U" // Atualiza a View
		oView:Refresh()
	EndIf	
Return 

/*/{Protheus.doc} fGetTotTit
    Função para verificar se o romaneio possui mais de uma parcela de pgto ou recbto
    @type  Function
    @author user
    @since 12/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description    
    /*/
Function fGetTotTit(nQtdTit)    
    Local cAliasQry := GetNextAlias()
    Local cTableTit := oTrbTits:GetRealName()
	Local cQuery  := ""

	cQuery := " SELECT COUNT(*) QTD_TITULOS "
	cQuery += " FROM "+ cTableTit + " BLC "	
	cQuery += " WHERE ROMANEIO = '" + (xBrowseEnt:Alias())->ROMANEIO + "' "
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	If (cAliasQry)->(!EOF())

		nQtdTit := (cAliasQry)->QTD_TITULOS    

	EndIf		    
    (cAliasQry)->(dbCloseArea())

Return 

