#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
#DEFINE ARQ_LOG_DES		"log_limpa_despesa.log"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@return aRotina	Lista de opcoes do menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina		:= {}
	Local aRotSIP		:= {}
	Local aRotSIB		:= {}
	Local aRotDiops		:= {}
	Local aRotObr		:= {}
	Local aCadastral	:= {}
	Local aQuaComun		:= {}
	Local aQuaAdmin		:= {}
	Local aQuaCoope		:= {}
	Local aRotRelSIB	:= {}
	Local aRotMonit		:= {}
	Local aProcGuia		:= {}
	Local aFornDir		:= {}
	Local aOutRem		:= {}
	Local aVlrPre		:= {}
	Local aRotDmed		:= {}
	Local lMonit        := FWAliasInDic("B5P", .F.) //verificar se aplicou o pacote do monitoramento
	Local lDmed         := FWAliasInDic("B2Y", .F.) //verificar se aplicou o pacote do monitoramento
	Local lNewQdr       := FWAliasInDic("B6X", .F.)
	Local lQdrIna       := FWAliasInDic("B7W", .F.)

	//Funções de relatoria do sib
	ADD OPTION aRotRelSIB Title 'Rel. Sintético'              Action 'CenValOpc("2","PLSR460()")'OPERATION 2 ACCESS 0
	ADD OPTION aRotRelSIB Title 'Rel. Analitico'              Action 'CenValOpc("2","PLSR465()")'OPERATION 2 ACCESS 0

	//Funções do SIP
	ADD OPTION aRotSIP Title 'Resumo do XML'	              Action 'CenValOpc("1","CenResSIP(.F.)")' OPERATION 2 ACCESS 0
	ADD OPTION aRotSIP Title 'Relatório Sintético'	          Action 'CenValOpc("1","PLSR499(B3D->B3D_TIPOBR)")' OPERATION 2 ACCESS 0
	ADD OPTION aRotSIP Title 'Relatório Analítico'	          Action 'CenValOpc("1","PLSR500()")' OPERATION 2 ACCESS 0
	ADD OPTION aRotSIP Title 'Limpa Processamento'	          Action 'CenValOpc("1","CENLMPPROC()")' OPERATION 2 ACCESS 0
	ADD OPTION aRotSIP Title 'Limpa Desp. Criticadas'	      Action 'CenValOpc("1","CENCLSCRIT()")' OPERATION 2 ACCESS 0

	ADD OPTION aRotSIP Title 'Eventos X Despesas'	          Action 'CenValOpc("1","PLSMVCDESP()")' OPERATION 2 ACCESS 0
	ADD OPTION aRotSIP Title 'Beneficiários Expostos'         Action 'CenValOpc("1","PLSMVCCAR()")' OPERATION 2 ACCESS 0
	ADD OPTION aRotSIP Title 'Validações'			          Action 'CenValOpc("1","PLMSIPVAL()")' OPERATION 2 ACCESS 0

	If FindFunction("CenAnaSip")
		ADD OPTION aRotSIP Title 'Análise SIP'	                  Action 'CenValOpc("1","CENANASIP(.f.)")' OPERATION 2 ACCESS 0
	EndIf

	If FindFunction("CenSIPWiz")
		If !lLibSupFw .Or. !lVrsAppSw .Or. !lHabMetric
			lHabMetric:= .F.
		EndIf
		ADD OPTION aRotSIP Title 'Wizard SIP'	                  Action 'CenValOpc("1","CenSIPWiz(lHabMetric)")' OPERATION 2 ACCESS 0
	EndIf

	//Funções do SIB
	ADD OPTION aRotSIB Title 'Impor Arq Ret RPX'              Action 'CenValOpc("2","PLSSIBRPX(B3D->B3D_TIPOBR)")'OPERATION 2 ACCESS 0
	ADD OPTION aRotSIB Title 'Impor Arq Conf CNX'             Action 'CenValOpc("2","PLSSIBCNX(B3D->B3D_TIPOBR)")'OPERATION 2 ACCESS 0
	ADD OPTION aRotSIB Title 'Histórico Arq SBX'              Action 'CenValOpc("2","PLSARQSIB(B3D->B3D_TIPOBR)")'OPERATION 4 ACCESS 0
	ADD OPTION aRotSIB Title 'Movimen. SIB'		              Action 'CenValOpc("2","PLSMOVSIB()")'OPERATION 2 ACCESS 0
	ADD OPTION aRotSIB Title 'Rel. Taxa Saúde'	              Action aRotRelSIB OPERATION 2 ACCESS 0
	ADD OPTION aRotSIB Title 'Gerar Arquivo XML Parcial'      Action 'CenValOpc("2","PLCNXMLSIB(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO,B3A->B3A_TIPO,.T. )")'OPERATION 2 ACCESS 0
	ADD OPTION aRotSIB Title 'Benef. Não Env. a ANS'		  Action 'CENEXPBEN()' OPERATION 3 ACCESS 0 //Exporta Beneficiarios não enviados a ANS

	If lDmed

		//ADD OPTION aRotDmed Title 'Despesas Analíticas'		Action 'CenValOpc("4","CENMVCB2Y()")' 	OPERATION 2 ACCESS 0
		ADD OPTION aRotDmed Title 'Movimentos'	    		Action 'CenValOpc("4","CENMVCB2W()")'	OPERATION 2 ACCESS 0
		ADD OPTION aRotDmed Title 'Histórico de Arquivos'	Action 'CenValOpc("4","CENMVCB2U()")'	OPERATION 2 ACCESS 0

	EndIF

	If lMonit
		//Funções Monitoramento - Fornecimento Direto
		ADD OPTION aFornDir Title 'Movimentação'		Action 'CenValOpc("5","CENMVCBVQ()")'	OPERATION 2 ACCESS 0
		//Funções Monitoramento - Outra Remuneração
		ADD OPTION aOutRem Title 'Movimentação'			Action 'CenValOpc("5","CENMVCBVZ()")'	OPERATION 2 ACCESS 0
		//Funções Monitoramento - Valor Preestabelecido
		ADD OPTION aVlrPre Title 'Movimentação'			Action 'CenValOpc("5","CENMVCB9T()")' OPERATION 2 ACCESS 0
		//Funções Monitoramento - Guia Monitoramento
		ADD OPTION aProcGuia Title 'Movimentações'		Action 'CenValOpc("5","CENMVCBKR()")' 	OPERATION 2 ACCESS 0
	Endif

	// Funções DIOPS Cadastral
	// Removido na versão 2018 de acordo com o link abaixo
	// http://www.ans.gov.br/atualizacoes/cadastral/4657-2018-diops-xml-cadastral-alteracao-no-envio-de-informacoes-cadastrais
	//ADD OPTION aCadastral Title 'Representantes'		      Action 'CenValOpc("3","PLSMVCREP()")'	OPERATION 2 ACCESS 0
	//ADD OPTION aCadastral Title 'Responsaveis'			  Action 'CenValOpc("3","PLSMVCRES()")'	OPERATION 2 ACCESS 0

	// Removendo as opções de diops cadastral da tela do painel da central
	//ADD OPTION aCadastral Title 'Acionitas/Cotistas'	      Action 'CenValOpc("3","PLSMVCACO()")'	OPERATION 2 ACCESS 0
	//ADD OPTION aCadastral Title 'Controladas/Coligadas'	      Action 'CenValOpc("3","PLSMVCCON()")'	OPERATION 2 ACCESS 0
	//ADD OPTION aCadastral Title 'Dependências'			      Action 'CenValOpc("3","PLSMVCDEP()")'	OPERATION 2 ACCESS 0

	//Funções DIOPS Quadros Administradoras
	ADD OPTION aQuaAdmin Title 'Balancete'					  Action 'CenValOpc("3","PLSMVCBLC()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaAdmin Title 'Atv. Gar. - Imobiliario'	  Action 'CenValOpc("3","PLSMVCAGI()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaAdmin Title 'Lucros e Prejuizos'			  Action 'CenValOpc("3","PLSMVCLCR()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaAdmin Title 'Fluxo de Caixa'				  Action 'CenValOpc("3","PLSMVCFLCX()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaAdmin Title 'Idade Saldos - A Pagar'		  Action 'CenValOpc("3","PLSMVCIDSA()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaAdmin Title 'Idade Saldos - A Receber'	  Action 'CenValOpc("3","PLSMVCIDSP()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaAdmin Title 'Segr. Mont. Contr. Repassar'  Action 'CenValOpc("3","PLSMVCSMCR()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaAdmin Title 'Contratos Estipulados'		  Action 'CenValOpc("3","PLSMVCCOE()")'	OPERATION 2 ACCESS 0
	If lNewQdr
		ADD OPTION aQuaAdmin Title 'CBR - Risco de Crédito - Parcela 1' Action 'CenValOpc("3","CENMVCCDO()")'	OPERATION 2 ACCESS 0
		ADD OPTION aQuaAdmin Title 'CBR - Risco de Crédito - Parcela 2'   Action 'CenValOpc("3","CENMVCDFI()")'	OPERATION 2 ACCESS 0
	Endif
	If lQdrIna
		ADD OPTION aQuaAdmin Title 'Inadimplência'                Action 'CenValOpc("3","CENMVCINA()")'	OPERATION 2 ACCESS 0
	EndIf
	//Funções DIOPS Quadros Cooperativas
	ADD OPTION aQuaCoope Title 'Balancete'					  Action 'CenValOpc("3","PLSMVCBLC()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Atv. Gar. - Imobiliario'	  Action 'CenValOpc("3","PLSMVCAGI()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Lucros e Prejuizos'			  Action 'CenValOpc("3","PLSMVCLCR()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Fluxo de Caixa'				  Action 'CenValOpc("3","PLSMVCFLCX()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Idade Saldos - A Pagar'		  Action 'CenValOpc("3","PLSMVCIDSA()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Idade Saldos - A Receber'	  Action 'CenValOpc("3","PLSMVCIDSP()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Cobertura Assistencial'		  Action 'CenValOpc("3","PLSMVCCOAS()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Prov Eve/Sinis a Liq'		  Action 'CenValOpc("3","PLSMVCPESL()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Agrupamento Contratos'		  Action 'CenValOpc("3","PLSMVCAGCN()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Eventos Indenizáveis'		  Action 'CenValOpc("3","PLSMVCEVIN()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Conta Tributo Passivo'		  Action 'CenValOpc("3","PLSMVCCTP()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Conta Corrente Cooperado'	  Action 'CenValOpc("3","PLSMVCCCC()")'	OPERATION 2 ACCESS 0
	//Descontinuado //DSAUCEN-DSAUCEN-1840
	//ADD OPTION aQuaCoope Title 'Eventos Corresponsabilidade'	Action 'CenValOpc("3","PLSMVCEVCO()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Fundos Comuns'				  Action 'CenValOpc("3","PLSMVCFUCO()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Contrapr.Corresp.Cedida'	  Action 'CenValOpc("3","PLSMVCCCED()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Modelo Padrão de Capital'	  Action 'CenValOpc("3","PLSMVCMPC()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Teste Adequação do Passivo'	  Action 'CenValOpc("3","PLSMVCTAP()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaCoope Title 'Contraprestações Pecuniárias' Action 'CenValOpc("3","CENMCONTPE()")'	OPERATION 2 ACCESS 0
	If lNewQdr
		ADD OPTION aQuaCoope Title 'CBR - Risco de Crédito - Parcela 1' Action 'CenValOpc("3","CENMVCCDO()")'	OPERATION 2 ACCESS 0
		ADD OPTION aQuaCoope Title 'CBR - Risco de Crédito - Parcela 2'   Action 'CenValOpc("3","CENMVCDFI()")'	OPERATION 2 ACCESS 0
	endif

	If lMonit
		// Funções do Monitoramento
		//ADD OPTION aRotMonit Title 'Monitor Jobs'				Action 'Teste()'						OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Lotes'						Action 'CenValOpc("5","CENMVCBKW()")' 	OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Guia Monitoramento'	 		Action aProcGuia						OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Fornecimento Direto'	 	Action aFornDir							OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Outra Remuneração'	 		Action aOutRem							OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Valor Preestabelecido' 		Action aVlrPre							OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Download XTE' 				Action 'CenValOpc("5","CenDownXTE()")'	OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Importar XTR Retorno'		Action 'CenValOpc("5","CENIMPXTR()")'	OPERATION 2 ACCESS 0
		ADD OPTION aRotMonit Title 'Gerar XTE Sem Movimentação' Action 'CenValOpc("5","PLSXTESEMM()")'	OPERATION 2 ACCESS 0
	EndIF
	//Funções DIOPS Quadros Demais Modalidades
	ADD OPTION aQuaComun Title 'Balancete'					  Action 'CenValOpc("3","PLSMVCBLC()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Atv. Gar. - Imobiliario'	  Action 'CenValOpc("3","PLSMVCAGI()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Idade Saldos - A Pagar'		  Action 'CenValOpc("3","PLSMVCIDSA()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Idade Saldos - A Receber'	  Action 'CenValOpc("3","PLSMVCIDSP()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Lucros e Prejuizos'			  Action 'CenValOpc("3","PLSMVCLCR()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Fluxo de Caixa'				  Action 'CenValOpc("3","PLSMVCFLCX()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Cobertura Assistencial'		  Action 'CenValOpc("3","PLSMVCCOAS()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Prov Eve/Sinis a Liq'		  Action 'CenValOpc("3","PLSMVCPESL()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Agrupamento Contratos'		  Action 'CenValOpc("3","PLSMVCAGCN()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Eventos Indenizáveis'		  Action 'CenValOpc("3","PLSMVCEVIN()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Contrapr.Corresp.Cedida'	  Action 'CenValOpc("3","PLSMVCCCED()")'	OPERATION 2 ACCESS 0
	//Descontinuado //DSAUCEN-DSAUCEN-1840
	//ADD OPTION aQuaComun Title 'Eventos Corresponsabilidade'	Action 'CenValOpc("3","PLSMVCEVCO()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Fundos Comuns'				  Action 'CenValOpc("3","PLSMVCFUCO()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Modelo Padrão de Capital'	  Action 'CenValOpc("3","PLSMVCMPC()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Teste Adequação do Passivo'	  Action 'CenValOpc("3","PLSMVCTAP()")'	OPERATION 2 ACCESS 0
	ADD OPTION aQuaComun Title 'Contraprestações Pecuniárias' Action 'CenValOpc("3","CENMCONTPE()")' OPERATION 2 ACCESS 0
	If lNewQdr
		ADD OPTION aQuaComun Title 'CBR - Risco de Crédito - Parcela 1' Action 'CenValOpc("3","CENMVCCDO()")'	OPERATION 2 ACCESS 0
		ADD OPTION aQuaComun Title 'CBR - Risco de Crédito - Parcela 2'   Action 'CenValOpc("3","CENMVCDFI()")'	OPERATION 2 ACCESS 0
	Endif
	//Funções do Diops
	ADD OPTION aRotDiops Title 'Envio Automático Financeiro'  Action 'CenValOpc("3","EnviaDiops()")'	OPERATION 2 ACCESS 0
	ADD OPTION aRotDiops Title 'Plano de Contas'			  Action 'CenValOpc("3","PLSMVCPLAC()")'	OPERATION 2 ACCESS 0
	ADD OPTION aRotDiops Title 'Imprime Quadros'			  Action 'CenValOpc("3","PLSRDIOPS(.F.)")'	OPERATION 7 ACCESS 0
	//Retirando a chamada do menu cadastral que será utilizado na raíz da central
	//ADD OPTION aRotDiops Title 'Cadastral'					  Action aCadastral	OPERATION 2 ACCESS 0
	ADD OPTION aRotDiops Title 'Demais Modalidades'			  Action aQuaComun	OPERATION 2 ACCESS 0
	ADD OPTION aRotDiops Title 'Quadros Administradoras'	  Action aQuaAdmin	OPERATION 2 ACCESS 0
	ADD OPTION aRotDiops Title 'Quadros Cooperativas'		  Action aQuaCoope	OPERATION 2 ACCESS 0

	//Menu Principal
	ADD OPTION aRotObr Title 'SIB'							Action aRotSIB 		OPERATION 2 ACCESS 0
	ADD OPTION aRotObr Title 'SIP'							Action aRotSIP 		OPERATION 2 ACCESS 0
	ADD OPTION aRotObr Title 'DIOPS'						Action aRotDiops	OPERATION 2 ACCESS 0

	If lDmed
		ADD OPTION aRotObr Title 'DMED'						Action aRotDmed 	OPERATION 2 ACCESS 0
	EndIF

	If lMonit
		ADD OPTION aRotObr Title 'Monitoramento'				Action aRotMonit	OPERATION 2 ACCESS 0
	EndIF
	ADD OPTION aRotObr Title 'Críticas' 					Action 'PlCritCom'	OPERATION 2 ACCESS 0
	ADD OPTION aRotObr Title 'Críticas Agrupadas' 			Action 'CenCritAgr(.F.)'	OPERATION 2 ACCESS 0
	ADD OPTION aRotObr Title 'Gerar Arquivo Envio'			Action 'PLGERXMLCN'	OPERATION 2 ACCESS 0
	ADD OPTION aRotObr Title 'Monitor de Jobs'		 		Action 'CENMONJOB()' OPERATION 2 ACCESS 0
	ADD OPTION aRotObr Title 'Mudar Status Comprom.' 		Action 'PLCOMPMF(.T.)'	OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 						Action 'VIEWDEF.PLSMVCCOMPROM'	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Obrigações'					Action aRotObr OPERATION 2 ACCESS 0

	SvcTabKey()

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para o conjunto B3D e B3E

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB3D 		:= FWFormStruct( 1, 'B3D' )
	Local oStruB3E 		:= FWFormStruct( 1, 'B3E' )
	Local oModel 		:= MPFormModel():New( 'PLSMVCCOMPROM' )
	Local oEvent  	    := CENEVTCENT():New()

	oStruB3D:SetProperty("B3D_CODOPE", MODEL_FIELD_WHEN, {|| .F.})
	oStruB3D:SetProperty("B3D_FILIAL", MODEL_FIELD_WHEN, {|| .F.})
	oStruB3E:SetProperty("B3E_FILIAL", MODEL_FIELD_WHEN, {|| .F.})

	oModel:AddFields( 'B3DMASTER', /*cOwner*/ , oStruB3D )
	oModel:AddGrid( 'B3EDETAIL', 'B3DMASTER', oStruB3E )

	oModel:SetRelation( 'B3EDETAIL',  { 	{ 'B3E_FILIAL', 'xFilial( "B3E" )' },;
		{ 'B3E_CODOPE' , 'B3D_CODOPE' },;
		{ 'B3E_CDOBRI' , 'B3D_CDOBRI' },;
		{ 'B3E_ANO' , 'B3D_ANO' },;
		{ 'B3E_CDCOMP' , 'B3D_CODIGO' };
		}, B3E->( IndexKey( 1 ) ) )

	oModel:SetDescription( 'Compromissos' )
	oModel:GetModel( 'B3DMASTER' ):SetDescription( "Compromissos" )
	oModel:GetModel( 'B3EDETAIL' ):SetDescription( "Contatos" )

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("EVTATUB3D", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3D e B3E

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 		:= FWLoadModel( 'PLSMVCCOMPROM' )
	Local oStruB3D 		:= FWFormStruct( 2, 'B3D' )
	Local oStruB3E 		:= FWFormStruct( 2, 'B3E' )
	Local oView 		:= FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_B3D', oStruB3D, 'B3DMASTER' )
	oView:AddGrid( 'VIEW_B3E', oStruB3E, 'B3EDETAIL' )

	oStruB3E:RemoveField('B3E_CODOPE')
	oStruB3E:RemoveField('B3E_CDOBRI')
	oStruB3E:RemoveField('B3E_ANO')
	oStruB3E:RemoveField('B3E_CDCOMP')

	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 50 )

	oView:SetOwnerView( 'VIEW_B3D', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3E', 'INFERIOR' )
	oView:EnableTitleView( 'VIEW_B3D', "Compromisso" )
	oView:EnableTitleView( 'VIEW_B3E', "Contatos do Compromisso" )

	oView:AddIncrementField( 'VIEW_B3E', 'B3E_CODIGO' )

Return oView
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLBRWCOMPR

Tela que exibe todos os compromissos

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLBRWCOMPR()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer
	Local oPnl
	Local oBrowse
	Private oDlgPrinc

	B3D->(dbSetOrder(2))

	Define MsDialog oDlgPrinc Title 'Compromissos' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	oFWLayer:AddLine( 'LINE', 100, .F. )
	oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )

	oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )

	oBrowse:SetDescription( "Compromissos" )
	oBrowse:SetAlias( 'B3D' )

	oBrowse:SetMenuDef( 'PLSMVCCOMPROM' )
	oBrowse:SetProfileID( '1' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:AddLegend( "B3D_STATUS=='1'", "YELLOW", "Pendente Envio" )
	oBrowse:AddLegend( "B3D_STATUS=='2'", "RED", "Criticado" )
	oBrowse:AddLegend( "B3D_STATUS=='3'", "BLUE", "Pronto para o Envio" )
	oBrowse:AddLegend( "B3D_STATUS=='4'", "ORANGE", "Em processamento ANS" )
	oBrowse:AddLegend( "B3D_STATUS=='5'", "BLACK", "Criticado pela ANS" )
	oBrowse:AddLegend( "B3D_STATUS=='6'", "GREEN", "Finalizado" )

	oBrowse:SetFilterDefault( "B3D_FILIAL=xFilial('B3D') .AND. B3D_CODOPE=B3A->B3A_CODOPE .AND. B3D_CDOBRI=B3A->B3A_CODIGO" )

	oBrowse:Activate()

	Activate MsDialog oDlgPrinc Center

Return NIL
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCOMPMF

Rotina que centraliza as regras de mudanca de fase de um compromisso

@param cStatus	 Status em que quero colocar o compromisso

@return lRet	Indica se atualizou .T. ou nao .F. o status

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCOMPMF(lManual, cStatus)
	Local lRet			:= .F.
	Local aArea			:= GetArea()
	Local aButtons		:= {}
	Local aItens		:= {"1=Pendente Envio",;
		"2=Criticado",;
		"3=Pronto para o Envio",;
		"4=Em processamento ANS",;
		"5=Criticado pela ANS",;
		"6=Finalizado"}
	Local oCmbStatus	:= Nil
	Local oDlg			:= Nil
	Local nOpca			:= 0
	Local bOK			:= { || nOpca := 1, oDlg:End() }
	Local bCancel		:= { || oDlg:End() }

	Default lManual		:= .T.
	Default cStatus	:= ""

	If lManual
		DEFINE MSDIALOG oDlg TITLE "Mudança de Status" FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL

		@ 048, 029 MSCOMBOBOX oCmbStatus VAR cStatus ITEMS aItens SIZE 090, 010 OF oDlg COLORS 0, 16777215 PIXEL
		EnchoiceBar(oDlg,bOK,bCancel,,aButtons)

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		nOpca := 1
	EndIf

	If nOpca == 1 .and. cStatus != ""
		cStatusAtual := B3D->B3D_STATUS
		//1=Pendente Envio;2=Criticado;3=Pronto para o Envio;4=Pendente Envio ANS;5=Criticado pela ANS;6=Finalizado
		If CECOMPMF(cStatus,cStatusAtual,B3D->B3D_TIPOBR)
			If !lManual .OR. ApMsgNoYes ("Deseja mudar a fase de " + X3COMBO("B3D_STATUS",cStatusAtual) + " para " + X3COMBO("B3D_STATUS",cStatus) ,"Central de Obrigações")
				BEGIN TRANSACTION
					Reclock("B3D",.F.)
					B3D->B3D_STATUS := cStatus
					StaticCall(PLSMVCCENTRAL,refreshB3D)
					MsUnlock()
					lRet := .T.
					//Gravar histórico da mudança de fase
					PlCompHist(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,cStatusAtual,cStatus)
					ConfirmSX8()
				END TRANSACTION
			EndIf
		Else
			lRet := .F.
			If lManual
				If cStatus == ""
					cMensagem := "Informe o status"
				Else
					cMensagem := "Não é permitido passar do Status " + X3COMBO("B3D_STATUS",cStatusAtual) + " para o Status " + X3COMBO("B3D_STATUS",cStatus)
				EndIf
				Help( ,, 'HELP',,  cMensagem, 1, 0,,,,,,{'Esta alteração quando permitida será executada automaticamente pelo sistema.'})
			EndIf
			RollBackSx8()
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

Function CECOMPMF(cStatus,cStatusAtual,cTipObr)
	Local lRet				:= .F.
	Default cStatus			:= ""
	Default cStatusAtual	:= ""
	Default cTipObr         := ""

	If !Empty(cStatus) .And. !Empty(cStatusAtual)

		lRet := cStatus == "" .OR.;
			(cStatus == "1" .AND. (cStatusAtual$"6,5,3,2") ) .OR.;
			(cStatus == "2" .AND. (cStatusAtual$"1,3") ) .OR.;
			(cStatus == "3" .AND. (cStatusAtual$"1,2") ) .OR.;
			(cStatus == "4" .AND. (cStatusAtual$"1,2,3,5") ) .OR.;
			(cStatus == "5" .AND. !(cStatusAtual$"4") ) .OR.;
			(cStatus == "6" .AND. (!(cStatusAtual$"4") .Or. cTipObr == "1"))
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlCompHist

Funcao generica para incluir historico da mudanca do status do compromisso

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObri		Chave da obrigacao
@param cAno			Ano do compromisso
@param cCodComp		Chave do compromisso
@param cStatusAnt	Status anterior
@param cStatus		Novo Status

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlCompHist(cCodOpe,cCodObri,cAno,cCodComp, cStatusAnt, cStatus)

	Reclock("B3G",.T.)
	B3G->B3G_FILIAL := xFilial("B3D")
	B3G->B3G_CODOPE := cCodOpe
	B3G->B3G_CDOBRI := cCodObri
	B3G->B3G_ANO 	:= cAno
	B3G->B3G_CDCOMP := cCodComp
	B3G->B3G_DATA 	:= dDataBase
	B3G->B3G_HORA 	:= Time()
	B3G->B3G_STANTE := cStatusAnt
	B3G->B3G_STATUA := cStatus
	B3G->B3G_LOGIN 	:= __cUserId + " - " + cUserName
	MsUnlock()

Return nil
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlExpCriNIO

Funcao criada para exportar dados de criticas para arquivo CSV

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlExpCriNIO(cOpe,cObri,cAno,cComp)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGERXMLCN

Funcao criada para exportar dados de criticas para arquivo CSV

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLGERXMLCN()

	If B3A->B3A_TIPO == "1"//SIP
		PLCNXMLSIP(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO,B3A->B3A_TIPO )
	ElseIf B3A->B3A_TIPO == "2"//SIB
		PLCNXMLSIB(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO,B3A->B3A_TIPO )
	ElseIf B3A->B3A_TIPO == "3" //DIOPS
		PLXMLDIOPS( B3A->B3A_TIPO )
	ElseIf B3A->B3A_TIPO == "4" //dmed
		CenArqDMed( B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO,B3A->B3A_TIPO )
	ElseIf B3A->B3A_TIPO == "5" //Monitoramento
		PLSXTECOMP()
	EndIf

Return

MenuDef()
ModelDef()
ViewDef()
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlCritCom
Funcao criada para verificar se o número de criticas não ultrapassa o limite do grid do MVC

@param cAlias		Area de trabalho corrente

@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------

Function PlCritCom()
	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
		" B3F_CODOPE = '" + B3D->B3D_CODOPE + "' .AND. " +;
		" B3F_CDOBRI = '" + B3D->B3D_CDOBRI + "' .AND. " +;
		" B3F_ANO = '" 	+ B3D->B3D_ANO + "' .AND. " +;
		" B3F_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	If B3D->B3D_TIPOBR == '2'
		cFIltro += " .AND. B3F_ORICRI = 'B3X' "
	EndIf

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Críticas", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If B3D->B3D_TIPOBR == '2'

		CnMBRWCrit(cFiltro, .F.,.T.)
	Else
		PLBRWCrit(cFiltro)
	Endif

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenValOpc

Funcao criada para validar as opcoes da central de acordo com a obrigacao selecionada

@param cOpc		Opcao selecionada 1-SIB, 2-SIP, 3-DIOPS, 5-Monitoramento
@param cMacro	Macro a ser executada

@author timoteo.bega
@since 06/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CenValOpc(cOpc,cFunc)

	Local cDescOpc	:= ""
	Local cDescObr	:= ""
	Local aObri		:= {{"1","SIP"},{"2","SIB"},{"3","DIOPS"},{"4","DMED"},{"5","MONITORAMENTO"}}
	Default cOpc	:= ""
	Default cFunc	:= ""

	If Empty(cFunc)
		cFunc := "Alert('Opção em desenvolvimento!')"
	EndIf

	If !Empty(cOpc) .And. !Empty(B3D->B3D_TIPOBR)

		If B3D->B3D_TIPOBR <> cOpc
			cDescObr := aObri[Val(B3D->B3D_TIPOBR),2]
			cDescOpc := aObri[Val(cOpc),2]
			Help(,,'Aviso',," Não é possível executar uma opção do " + cDescOpc + " com uma obrigação " + cDescObr + " selecionada!", 1, 0)
		Else
			&cFunc
		EndIf

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENSIBTM

Retorna um ou mais tipos de movimento SIB para ser usado na consulta padrao B3KTPM

@param cCampo - Campo utilizado para formar a string de retorno	| Deve conter conteudo no campo X3_CBOX
@param cMV    - Parâmetro do pergunte a receber o retorno

@author Pedro Drivas
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CENGETXB(cCampo,cMV)

	Local oDlg		:= Nil
	Local aConjunto	:= {}
	Local aPosic    := {}
	Local nFor		:= 0
	Local nOpc		:= 0
	Local nI        := 0
	Local nIi       := 0
	Local nOpcoes   := 0
	Local bOK		:= { || nOpc := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }

	Local cBox      := AllTrim(GetAdvFVal("SX3","X3_CBOX",cCampo,2,""))

	Default cMV	:= ''

	If len(cBox) > 0

		For nI := 1 to len(cBox)
			If SUBSTR(cBox,nI,1) == "="
				nOpcoes++
				aAdd(aPosic,{nI,0})
			ElseIf SUBSTR(cBox,nI,1) == ";"
				aPosic[nOpcoes][2] := nI
			EndIF
		Next nI

		aPosic[nOpcoes][2] := len(cBox)

		Iif(cCampo=="B3X_OPERA",nOpcoes--,nOpcoes:=nOpcoes)
		For nIi := 1 to nOpcoes
			If nIi == 1
				aAdd(aConjunto,{CVALTOCHAR(nIi),SUBSTR(cBox,aPosic[nIi][1]+1,aPosic[nIi][2]-3),.F.})
			ElseIf	nIi == nOpcoes
				aAdd(aConjunto,{CVALTOCHAR(nIi),SUBSTR(cBox,aPosic[nIi][1]+1,aPosic[nIi][2]-(aPosic[nIi-1][2]+2)),.F.})
			Else
				aAdd(aConjunto,{CVALTOCHAR(nIi),SUBSTR(cBox,aPosic[nIi][1]+1,aPosic[nIi][2]-(aPosic[nIi-1][2]+3)),.F.})
			EndIf
		Next nIi

		DEFINE MSDIALOG oDlg TITLE 'Tipo de Movimento' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
		@ 020,012 SAY oSay PROMPT 'Selecione o(s) tipo(s) de movimento a ser(em) processado(s)' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
		oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
		oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
		oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
		oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
		oConjunto:SetArray(aConjunto)
		oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 12 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
		ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

		If nOpc == 1
			cMV := ""
			For nFor := 1 To Len(aConjunto)
				If aConjunto[nFor,3]
					cMV += aConjunto[nFor,1]
				Endif
			Next
		Endif

	ENDIF

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENSIBTM

Retorna os registros com DISTINCT de um Alias e campo especificados via parametro

@param cAlias - Tabela
@param cCampo - Nome do campo
@param cMV    - Parâmetro do pergunte a receber o retorno

@author Pedro Drivas
@since 27/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CENGETDIST(cAlias,cCampo,cMV)

	Local oDlg		:= Nil
	Local aConjunto	:= {}
	Local bOK		:= { ||cMv:=aConjunto[oConjunto:nAt,1],oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Local cQuery    := ''
	Local cTab      := GetNextAlias()

	Default cMV	    := ''

	cQuery += " SELECT DISTINCT " + cCampo
	cQuery += " FROM " + RetSQLName(cAlias)
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + cCampo

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.T.)

	(cTab) -> (DBGoTop())

	If !(cTab)->(EOF())
		While (cTab)->(!EOF())

			aAdd(aConjunto,{(cTab)->B3K_CNPJCO,.F.})
			(cTab) -> (DBSkip())
		EndDo
	EndIf

	DEFINE MSDIALOG oDlg TITLE 'CNPJ' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT '' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
	oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oConjunto:AddColumn(TcColumn():New('CNPJ'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:SetArray(aConjunto)
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

Return .T.

Function SelEmpCO(cAlias,cCampo,cMV)

	Local oDlg		:= Nil
	Local aConjunto	:= {}
	Local bOK		:= { ||cMv:=aConjunto[oConjunto:nAt,1],oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Local cQuery    := ''
	Local cTab      := GetNextAlias()

	Default cMV	    := ''

	cQuery += " SELECT DISTINCT " + cCampo
	cQuery += " 	FROM " + RetSQLName(cAlias)
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " 	ORDER BY " + cCampo

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.T.)

	(cTab) -> (DBGoTop())

	If !(cTab)->(EOF())
		While (cTab)->(!EOF())
			aAdd(aConjunto,{(cTab)->B3K_NOMECO,.F.})
			(cTab) -> (DBSkip())
		EndDo
	EndIf

	DEFINE MSDIALOG oDlg TITLE 'NOME EMPRESA' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT '' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
	oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oConjunto:AddColumn(TcColumn():New('NOME EMPRESA',{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) } ,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:SetArray(aConjunto)
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

Return .T.