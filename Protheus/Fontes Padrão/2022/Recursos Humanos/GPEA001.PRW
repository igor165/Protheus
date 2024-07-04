#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA001.CH"

Static 	__oModelCopy
Static oRHNModel
Static cEmpChg
Static aPerAtual
Static cFilOld := ""


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEA001    Ё Autor Ё Mauricio Takakura           Ё Data Ё 24/08/11    Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Controle de Planos Ativos - Ass. Medica e Odontologica                Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEA001()                                                             Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                            Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.                           Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁLeandro Dr.  Ё07/02/2012ЁM12RH01         ЁUnificacao da Folha.                       Ё╠╠
╠╠Ё				Ё	   	   ЁRHU210_03_07    Ё                                           Ё╠╠
╠╠ЁCecilia Carv.Ё16/04/2014ЁM_RH003         ЁReplica da versao 11 para versao 12.       Ё╠╠
╠╠Ё	   			Ё         Ё002951_04        Ё                                           Ё╠╠
╠╠ЁRaquel Hager Ё05/06/2014ЁTPTBN8          ЁInclusao de replicas versao 11  com itens  Ё╠╠
╠╠Ё             Ё          Ё                Ёdo eSocial.                                Ё╠╠
╠╠ЁJosИ Cunha   Ё14/08/2014ЁChamado: TPZKFV	ЁAjuste na funГЦo RHK_LinhaOK, 	para        Ё╠╠
╠╠Ё				Ё		   Ё                Ёpermitir a inclusЦo de planos diferentes , Ё╠╠
╠╠Ё				Ё		   Ё				Ёpara o mesmo fornecedor.                   Ё╠╠
╠╠ЁAllyson M.   Ё18/08/2014ЁTPSEOI          ЁAjuste p/ permitir transferencia em lote doЁ╠╠
╠╠Ё				Ё		   Ё				Ёplano de faixa salarial/etaria.            Ё╠╠
╠╠ЁFlavio CorreaЁ03/09/2014ЁTQMHV8 		    ЁRetirado bodao Salvar e Criar novo, pois   Ё╠╠
╠╠Ё				Ё		   Ё				Ёnesse caso nЦo se aplica por se tratar de  Ё╠╠
╠╠Ё				Ё		   Ё				Ёuma rotina de manutenГЦo                   Ё╠╠
╠╠ЁAllyson M.   Ё19/02/2015ЁTRLZVE 		    ЁAjuste na validacao da transferencia em    Ё╠╠
╠╠Ё				Ё		   Ё				Ёlote p/ apenas verificar os planos que     Ё╠╠
╠╠Ё				Ё		   Ё				Ёestao dentro do range da parametrizacao.   Ё╠╠
╠╠ЁChristiane V.Ё26/11/2015ЁTTQDOQ          ЁAjuste na montagem da query para corrigir 	Ё╠╠
╠╠Ё				Ё		   Ё				Ёerror.log em banco Postgres.    			Ё╠╠
╠╠ЁRenan Borges Ё25/04/2016ЁTUZCRD          ЁAjuste pra ao cadastrar um plano de saude  Ё╠╠
╠╠Ё				Ё		   Ё				Ёno funcionАrio, alterar o campo "Tem Plano Ё╠╠
╠╠Ё				Ё		   Ё				Ёde Saude" para "Sim".                      Ё╠╠
╠╠ЁRenan Borges Ё05/05/2016ЁTUYOIQ          ЁAjuste para ao executar uma transferЙncia  Ё╠╠
╠╠Ё				Ё		   Ё				Ёem lote para um funcionАrio com dependente Ё╠╠
╠╠Ё				Ё		   Ё				Ёe agregado, o sistema grava na tabela RHN aЁ╠╠
╠╠Ё				Ё		   Ё				ЁinformaГЦo de nome de ambos corretamente.  Ё╠╠
╠╠ЁRaquel H.    Ё05/05/2016ЁTUVYC3          ЁAtualizar o campo RA_PLSAUDE quando excluirЁ╠╠
╠╠Ё				Ё		   Ё				Ёum registro.								Ё╠╠
╠╠ЁRaquel H.    Ё11/05/2016ЁTUVY62          ЁValidar tipo de plano de saЗde + perМodo.  Ё╠╠
╠╠ЁRaquel H.    Ё30/05/2016ЁTUVY62          ЁAjuste na comparaГЦo do periodo final do   Ё╠╠
╠╠Ё				Ё		   Ё				Ёdo plano de saude de um mesmo fornecedor.  Ё╠╠
╠╠ЁGabriel A.   Ё16/06/2016ЁTUVY62          ЁAjuste para permitir inclusЦo via MILE.    Ё╠╠
╠╠ЁRaquel Hager Ё30/06/2016ЁTVHB83          ЁAjustes para importaГЦo via MILE. 		    Ё╠╠
╠╠ЁAllyson M.   Ё26/09/2016ЁTVVKRA 		    ЁAjuste p/ permitir a ediГЦo do campo CODIGOЁ╠╠
╠╠Ё				Ё		   Ё				Ёda tabela RHM quando for rotina GPEM027    Ё╠╠
╠╠ЁJoЦo Balbino Ё16/01/2016ЁMPRIMESSP-637   ЁAjuste na RHK_LINHAOK para validar o perМo-Ё╠╠
╠╠Ё				Ё		   Ё				Ёdo corretamente.                           Ё╠╠
╠╠ЁEduardo K.   Ё23/02/2017ЁMPRIMESP-9187   ЁAjuste na validaГЦo do campo de data final.Ё╠╠
╠╠ЁJaqueline L. Ё19/02/2018ЁDRHPAG-5733     ЁCorreГЦo para validar se o Fornecedor add  Ё╠╠
╠╠Ё				Ё		   Ё				ЁjА existe dentro do perМodo informado      Ё╠╠
╠╠ЁWinstonCosta Ё02/01/2019ЁDRHPAG-22991    ЁRetirada do trecho que trata o AS/400      Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEA001()

	Local oMBrowse
	Local cFiltraRh

	// Tratamento de ambiente configurado com 2 Digitos no Ano da Data.
	// Se "on"  indica 4 digitos e __SetCentury( ) retorna .T.	- Neste caso, nao ha necessidade de alteracao na configuracao.
	// Se "off" indica 2 digitos e __SetCentury( ) retorna .F.	- Neste caso, sera efetuada a alteracao na configuracao.
	Private lSetCentury := __SetCentury( )	// Guarda Configuracao original do ambiente.

	If ! lSetCentury			// __SetCentury( ) retornou .F. - Neste caso, SERA efetuada a alteracao na configuracao.
		__SetCentury( "on" )	// Forca a utilizacao do Ano com 4 Digitos.
	EndIf


	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Controle dos Planos MИdico e OdontolСgico Ativos"
	oMBrowse:SetChgAll(.F.)
	GpLegMVC(@oMBrowse)	// Adicionar a Legenda no Browse

	oMBrowse:ForceQuitButton()								//"Incluir botao de sair"

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cFiltraRh := CHKRH("GPEA001","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )

	oMBrowse:DisableDetails()
	oMBrowse:Activate()

	If ! lSetCentury			// __SetCentury( ) retornou .F. - Neste caso, FOI efetuada a alteracao na configuracao e
		__SetCentury( "off" )	// DEVE retornar configuracao original do ambiente.
	EndIf

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Mauricio TakakuraЁ Data Ё24/08/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE OemToAnsi(STR0002)  ACTION "PESQBRW"				OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0051)  ACTION "fManutCalc()"			OPERATION 2 ACCESS 0 				//'Manut. CАlculo'
	ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION "VIEWDEF.GPEA001" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0004)  ACTION "VIEWDEF.GPEA001" 		OPERATION 3 ACCESS 0				//'Planos Ativos'
	ADD OPTION aRotina TITLE OemToAnsi(STR0005)  ACTION "VIEWDEF.GPEA001" 		OPERATION 5 ACCESS 0				//'Excluir'
	ADD OPTION aRotina TITLE OemToAnsi(STR0006)  ACTION "VIEWDEF.GPEA002" 		OPERATION 2 ACCESS 0				//'Historico de Alteracoes'
	ADD OPTION aRotina TITLE OemToAnsi(STR0021)  ACTION "fViewCalc()" 			OPERATION 2 ACCESS 0				//'Consultar Calculo'
	ADD OPTION aRotina TITLE OemToAnsi(STR0044)  ACTION "fTransfLote()" 		OPERATION 2 ACCESS 0				//'Transf. Lote'
	ADD OPTION aRotina TITLE OemToAnsi(STR0069)  ACTION "GPEM120()" 			OPERATION 2 ACCESS 0				//'Fechamento'

Return aRotina

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Mauricio TakakuraЁ Data Ё24/08/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

	Local oModel
	Local oStructSRA
	Local oStructRHK	// Titulares
	Local oStructRHL	// Dependentes
	Local oStructRHM	// Agregados
	Local lRelatPlan	:= SuperGetMv("MV_RELPLAN",NIL,.F.)
	Local bActivate		:= { |oModel| fActiv_Model(oModel) }
	Local bCancel		:= { |oModel| ( cFilAnt := cFilOld ), .T. }
	Local aAux			:= {}

	// Criacao do Objeto de Modelagem de dados //
	oModel     := MPFormModel():New("GPEA001",,{ |oModel| Gp001PosValid(oModel) }, { |oModel| Gp001Commit(oModel) }, bCancel )
	oModel:SetDescription( OemToAnsi(STR0001) ) //"Controle dos Planos MИdico e OdontolСgico Ativos"

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cabecalho de dados - SRA (Funcionario)		                         Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	oStructSRA := FWFormStruct(1, "SRA",  { |cCampo| Gpa001SRAStru(cCampo) })
	oModel:AddFields("GPEA001_MSRA", NIL, oStructSRA)
	oModel:GetModel( "GPEA001_MSRA" ):SetDescription( OemToAnsi(STR0001) ) //"Controle dos Planos MИdico e OdontolСgico Ativos"
	oModel:GetModel('GPEA001_MSRA'):SetOnlyQuery(.T.)
	oModel:GetModel('GPEA001_MSRA'):SetOnlyView(.T.)

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Estrutura de campos do Model - RHK - Planos Ativos do Funcionario      Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	oStructRHK := FWFormStruct(1, "RHK")
	oStructRHK:SetProperty( "RHK_TPFORN", MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEA001_MRHK") } )
	If RHK->(ColumnPos("RHK_DATFIM")) > 0
		oStructRHK:SetProperty("RHK_DATFIM",MODEL_FIELD_VALID,{|oModel| fVldRHKDtF(oModel)})
	EndIf
	oModel:AddGrid("GPEA001_MRHK", "GPEA001_MSRA", oStructRHK,{ |oModel,nLine,cAcao,cCampo| RHK_VlDel( oModel, nLine, cAcao, cCampo ) }, { |oModel| RHK_LinhaOK(oModel) },, { |oModel| RHK_TudoOK(oModel) } )

	oModel:GetModel( "GPEA001_MRHK" ):SetDescription( OemToAnsi(STR0007) ) //"Planos Ativos do Titular"
	oModel:GetModel( "GPEA001_MRHK" ):SetOptional( .T. )
	oModel:SetRelation( "GPEA001_MRHK", { { "RHK_FILIAL", 'xFilial("RHK",SRA->RA_FILIAL)' }, { "RHK_MAT", 'RA_MAT' }}, RHK->( IndexKey( 1 ) ) )

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Estrutura de campos do Model (RHL)Planos Ativos Dependentes 			    Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	oStructRHL := FWFormStruct(1, "RHL")

	// ADICIONANDO OS ELEMENTOS QUE SERцO USADOS NOS GATILHOS.
	aAux := FwStruTrigger('RHL_CODIGO', 'RHL_NOME', 'SRB->RB_NOME', .T., 'SRB', 1, 'xFilial("SRB", SRA->RA_FILIAL) + SRA->RA_MAT + M->RHL_CODIGO')
	
	// ADICIONANDO OS GATILHOS A ESTRUTURA DO MODEL.
	oStructRHL:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

	If !IsInCallStack("FWMILEIMPORT") .And. !IsInCallStack("GPEM027")
		oStructRHL:SetProperty( "RHL_CODIGO", MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEA001_MRHL") } )
	EndIf

	DbSelectArea("RHL")
	If RHL->(ColumnPos("RHL_DATFIM")) > 0
		oStructRHL:SetProperty("RHL_DATFIM",MODEL_FIELD_VALID,{|oModel| fVldRHLDtF(oModel)})
	EndIf
	oModel:AddGrid("GPEA001_MRHL", "GPEA001_MRHK", oStructRHL,{ |oModel,nLine,cAcao,cCampo| RHL_VlDel( oModel, nLine, cAcao, cCampo ) }, { |oModel| RHL_LinhaOK(oModel) },, { |oModel| RHL_TudoOK(oModel) } )
	oModel:GetModel( "GPEA001_MRHL" ):SetDescription( OemToAnsi(STR0008) ) //"Planos Ativos dos Dependentes"
	oModel:GetModel( "GPEA001_MRHL" ):SetOptional( .T. )
	oModel:GetModel( "GPEA001_MRHL" ):SetUniqueLine( { 'RHL_CODIGO', 'RHL_TPPLAN', 'RHL_PLANO' } )
	If lRelatPlan
		oModel:SetRelation( "GPEA001_MRHL", { { "RHL_FILIAL", 'xFilial( "RHK" )' }, { "RHL_MAT", 'RHK_MAT' }, { "RHL_TPFORN", 'RHK_TPFORN' }, { "RHL_CODFOR", 'RHK_CODFOR' }, { "RHL_PLANO", 'RHK_PLANO' } }, RHL->( IndexKey( 1 ) ) )
	Else
		oModel:SetRelation( "GPEA001_MRHL", { { "RHL_FILIAL", 'xFilial( "RHK" )' }, { "RHL_MAT", 'RHK_MAT' }, { "RHL_TPFORN", 'RHK_TPFORN' }, { "RHL_CODFOR", 'RHK_CODFOR' } }, RHL->( IndexKey( 1 ) ) )
	EndIf
	If !IsInCallStack("FWMILEIMPORT")
		oModel:SetPrimaryKey({"RHL_MAT", "RHL_CODIGO"})
	EndIf

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Estrutura de campos do Model (RHM)Planos Ativos Agregados				 Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	oStructRHM := FWFormStruct(1, "RHM")
	If !IsInCallStack("FWMILEIMPORT")
		oStructRHM:SetProperty( "RHM_CODIGO", MODEL_FIELD_WHEN, { || IsBlind() } )
	EndIf

	DbSelectArea("RHM")
	If RHM->(ColumnPos("RHM_DATFIM")) > 0
		oStructRHM:SetProperty("RHM_DATFIM",MODEL_FIELD_VALID,{|oModel| fVldRHMDtF(oModel)})
	EndIf
	oModel:AddGrid("GPEA001_MRHM", "GPEA001_MRHK", oStructRHM,{ |oModel,nLine,cAcao,cCampo| RHM_VlDel( oModel, nLine, cAcao, cCampo ) }, { |oModel| RHM_LinhaOK(oModel) })
	oModel:GetModel( "GPEA001_MRHM" ):SetDescription( OemToAnsi(STR0009) ) //"Planos Ativos dos Agregados"
	oModel:GetModel( "GPEA001_MRHM" ):SetOptional( .T. )

	If lRelatPlan
		oModel:SetRelation( "GPEA001_MRHM", { { "RHM_FILIAL", 'xFilial( "RHK" )' }, { "RHM_MAT", 'RHK_MAT' }, { "RHM_TPFORN", 'RHK_TPFORN' }, { "RHM_CODFOR", 'RHK_CODFOR' }, { "RHM_PLANO", 'RHK_PLANO' } }, RHM->( IndexKey( 1 ) ) )
	Else
		oModel:SetRelation( "GPEA001_MRHM", { { "RHM_FILIAL", 'xFilial( "RHK" )' }, { "RHM_MAT", 'RHK_MAT' }, { "RHM_TPFORN", 'RHK_TPFORN' }, { "RHM_CODFOR", 'RHK_CODFOR' } }, RHM->( IndexKey( 1 ) ) )
	EndIf
	oModel:SetVldActivate( { |oModel| Gp001IniMod( oModel,oModel:GetOperation() ) } )

	oModel:SetActivate( bActivate )

Return( oModel )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Mauricio TakakuraЁ Data Ё24/08/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()
	Local oView
	Local oModel
	Local oStructSRA
	Local oStructRHK
	Local oStructRHL
	Local oStructRHM

	// Vincular o View ao Model //
	oModel := FWLoadModel("GPEA001")

	// Criacao da Interface //
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Criacao do Cabecalho - SRA (Funcionario) //
	oStructSRA := FWFormStruct(2, "SRA", { |cCampo| Gpa001SRAStru(cCampo) })
	oStructSRA:SetNoFolder()
	oView:AddField("GPEA001_VSRA", oStructSRA, "GPEA001_MSRA" )

	// Criacao do Cabecalho - RHK (Planos Ativos do Titular) //
	oStructRHK := FWFormStruct(2,"RHK")
	oStructRHK:RemoveField("RHK_MAT")
	oStructRHK:RemoveField("RHK_CDPSAG")
	oView:AddGrid("GPEA001_VRHK", oStructRHK, "GPEA001_MRHK" )

	// Criacao do Cabecalho - RHK (Planos Ativos dos Dependentes e Agregados) //
	oStructRHL := FWFormStruct(2, "RHL")
	oView:AddGrid("GPEA001_VRHL", oStructRHL, "GPEA001_MRHL" )
	oStructRHL:RemoveField("RHL_MAT")
	oStructRHL:RemoveField("RHL_TPFORN")
	oStructRHL:RemoveField("RHL_CODFOR")

	oStructRHM := FWFormStruct(2, "RHM")
	oView:AddGrid("GPEA001_VRHM", oStructRHM, "GPEA001_MRHM" )
	oView:AddIncrementField( "GPEA001_VRHM", "RHM_CODIGO" )
	oStructRHM:RemoveField( "RHM_MAT" )
	oStructRHM:RemoveField( "RHM_TPFORN" )
	oStructRHM:RemoveField( "RHM_CODFOR" )

	//VerificaГЦo de visualizaГЦo dos campos RHK_TPCALC, RHL_TPCALC e RHM_TPCALC

	DbSelectArea("SLY")
	SLY->(DbSetOrder(1))//LY_FILIAL+LY_TIPO+LY_AGRUP+LY_ALIAS+LY_FILENT+LY_CHVENT+LY_CODIGO+DTOS(LY_DTINI)
	DbSelectArea("SG0")
	SG0->(DbSetOrder(2))//G0_FILIAL+G0_STATUS+G0_CODIGO

	If ((!(SLY->(MsSeek(xFilial("SLY")+"PS")))) .OR. fRetCriter()=="" .OR. ((!(SG0->(MsSeek(xFilial("SG0")+"1"))))))
		oStructRHK:RemoveField("RHK_TPCALC")
		oStructRHL:RemoveField("RHL_TPCALC")
		oStructRHM:RemoveField("RHM_TPCALC")
	EndIf

	// Desenho da Tela //
	oView:CreateHorizontalBox("SRA_HEAD", 12)
	oView:CreateHorizontalBox("RHK_PLFUNC", 25)
	oView:CreateHorizontalBox("PLDEPAGR", 63)

	oView:CreateVerticalBox( 'RHL_PLDEP', 50, 'PLDEPAGR' )
	oView:CreateVerticalBox( 'RHM_PLAGR', 50, 'PLDEPAGR' )

	oView:SetOwnerView( "GPEA001_VSRA", "SRA_HEAD" )
	oView:SetOwnerView( "GPEA001_VRHK", "RHK_PLFUNC" )
	oView:SetOwnerView( "GPEA001_VRHL", "RHL_PLDEP" )
	oView:SetOwnerView( "GPEA001_VRHM", "RHM_PLAGR" )

	oView:EnableTitleView( "GPEA001_VRHK", OemToAnsi(STR0007) ) //"Planos Ativos do Titular"
	oView:EnableTitleView( "GPEA001_VRHL", OemToAnsi(STR0008) ) //"Planos Ativos dos Dependentes"
	oView:EnableTitleView( "GPEA001_VRHM", OemToAnsi(STR0009) ) //"Planos Ativos dos Agregados"
	oView:SetCloseOnOk({ || .T. })		//Apos COMMIT gravacao fecha a tela

	oView:SetViewCanActivate({|oView| VldView(oView)})

Return oView

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fActiv_Model	ЁAutorЁMauricio Takakura  Ё Data Ё22/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁReplicando o Model para comparacao dos dados                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fActiv_Model(oModel)
	Local nOperation	:= oModel:GetOperation()

	aPerAtual := {}

	__oModelCopy:= FWLoadModel("GPEA001")
	__oModelCopy:SetOperation(nOperation)
	__oModelCopy:SetActivate({|| .T.})
	__oModelCopy:Activate()

Return( .T. )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gp001PosValid	ЁAutorЁ  Mauricio TakakuraЁ Data Ё21/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁPos Valid do Model para geracao do Historico 				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gp001PosValid(oModel )

	Local aAreaGPE 		:= GetArea()
	Local aRHKFields
	Local aRHLFields

	Local cTpDIRF

	Local lRet 		:= .T.
	Local lRHKDelet := .F.
	Local lResult 	:= .F.

	Local nI
	Local nP
	Local nJ
	Local nLinha		:= 1
	Local nRHKNLines
	Local nRHKCpyLines
	Local nRHLLine
	Local nRHLCpyLines
	Local nRHMLine
	Local nRHMCpyLines

	Local oRHNStruct
	Local oRHKStruct
	Local oRHLStruct
	Local oRHMStruct
	Local oCpyRHKStru
	Local oCpyRHLStru
	Local oCpyRHMStru
	Local oRHKStru
	Local oRHLStru
	Local oRHMStru
	Local oMdlAtual

	oMdlAtual := FWModelActive()

	oRHNModel := NIL
	oRHNModel := FWLoadModel("GPEA002")
	oRHNModel:SetOperation(3)
	oRHNModel:SetActivate({|| .T.})
	oRHNModel:Activate()

	FWModelActive( oMdlAtual )

	oRHNStruct	:= oRHNModel:GetModel( "GPEA002_MRHN" )
	oRHKStruct	:= oModel:GetModel( "GPEA001_MRHK" )
	oRHLStruct	:= oModel:GetModel( "GPEA001_MRHL" )
	oRHMStruct	:= oModel:GetModel( "GPEA001_MRHM" )
	oCpyRHKStru := __oModelCopy:GetModel( "GPEA001_MRHK" )

	// Verificar necessidade de geracao de historico //
	nRHKNLines	:= oRHKStruct:Length()
	nRHKCpyLines:= oCpyRHKStru:Length()
	For nI := 1 To nRHKNLines
		oRHKStruct:GoLine( nI )

		// Comparacao somente com registros ja gravados no banco - Comparar com __oModelCopy //
		lRHKDelet := .F.
		uTypeoper := ""
		If nI <= nRHKCpyLines
			oCpyRHKStru:GoLine( nI )
			If !oCpyRHKStru:IsInserted()

				oRHKStru 	:= oRHKStruct:GetStruct()
				aRHKFields 	:= oRHKStru:GetFields()
				If oRHKStruct:IsUpdated()
					For nP := 1 To Len(aRHKFields)
						cCampo := aRHKFields[nP, MODEL_FIELD_IDFIELD ]
						If oRHKStruct:GetValue( cCampo ) <> oCpyRHKStru:GetValue( cCampo )

							// Gerar o Codigo para Gravacao do Tipo para DIRF //
							If cCampo == "RHK_CODFOR"
								cTpDIRF := "01"
							ElseIf cCampo == "RHK_PLANO" .and. Empty(cTpDIRF)
								cTpDIRF := "03"
							ElseIf cCampo == "RHK_TPPLAN" .and. Empty(cTpDIRF)
								cTpDIRF := "02"
							ElseIf (cCampo == "RHK_PERINI" .Or. cCampo == "RHK_PERFIM")  .and. Empty(cTpDIRF)
								cTpDIRF := "04"
							ElseIf Empty(cTpDIRF)
								cTpDIRF := "05"
							EndIf
							uTypeoper := "1"
						EndIf
					Next nP

				//Geracao do historico para Registros Deletados //
				ElseIf oRHKStruct:IsDeleted() .Or. oModel:GetOperation() == 5
					lResult := 	Gp001ChkDl()
					If lResult
						cTpDIRF := "01"
						uTypeoper := "2"
						lRHKDelet := .T.
					Else
						Help( ,, STR0028,, OemToAnsi( STR0064 + STR0065 ), 1, 0 )
						Return lResult
					EndIF
				EndIf
			EndIf

			//--> Ajuste para caso nЦo haja linha de plano de saЗde e o campo RA_PLSAUDE == 1(Sim) voltar o conteЗdo do campo para 2(NЦo)
			If lResult .And. lRHKDelet
				RecLock("SRA", .F.)
				SRA->RA_PLSAUDE := "2"
				SRA->( MsUnlock() )
			EndIf


			// Geracao na tabela de historicos //
			If !Empty( uTypeoper )
				If nLinha > 1
					oRHNStruct:AddLine()
				EndIf
				nLinha++
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_FILIAL"	, SRA->RA_FILIAL )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MAT"		, SRA->RA_MAT )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_DATA"		, dDataBase )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_OPERAC"	, uTypeOper )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_ORIGEM"	, "1" )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPALT"	, cTpDIRF )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPFORN"	, oCpyRHKStru:GetValue( "RHK_TPFORN" ) )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CODFOR"	, oCpyRHKStru:GetValue( "RHK_CODFOR" ) )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_NOME"		, SRA->RA_NOME )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPPLAN"	, oCpyRHKStru:GetValue( "RHK_TPPLAN" ) )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PLANO"	, oCpyRHKStru:GetValue( "RHK_PLANO" ) )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PD"		, oCpyRHKStru:GetValue( "RHK_PD" ) )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PDDAGR"	, oCpyRHKStru:GetValue( "RHK_PDDAGR" ) )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PERINI"	, oCpyRHKStru:GetValue( "RHK_PERINI" ) )
				oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PERFIM"	, oCpyRHKStru:GetValue( "RHK_PERFIM" ) )

				If (RHK->(ColumnPos( "RHK_CNS")) > 0) .AND. (RHK->(ColumnPos( "RHK_MATSAU")) > 0) .AND. (RHK->(ColumnPos( "RHK_MATODO")) > 0)
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CNS"	    , oCpyRHKStru:GetValue( "RHK_CNS" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MATSAU"	, oCpyRHKStru:GetValue( "RHK_MATSAU" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MATODO"	, oCpyRHKStru:GetValue( "RHK_MATODO" ) )
				EndIf
			EndIf
		EndIf

		// Gravacao do historio dos Dependentes //
		oCpyRHLStru := __oModelCopy:GetModel( "GPEA001_MRHL" )
		nRHLLine 	:= oRHLStruct:Length()
		nRHLCpyLines:= oCpyRHLStru:Length()
		If cTpDIRF <> "01"
			cTpDIRF := ""
		EndIf
		For nJ := 1 To nRHLLine
			oRHLStruct:GoLine( nJ )

			uTypeoper := ""
			If nJ <= nRHLCpyLines
				oCpyRHLStru:GoLine( nJ )
				If !oCpyRHLStru:IsInserted()
					oRHLStru 	:= oRHLStruct:GetStruct()
					aRHLFields 	:= oRHLStru:GetFields()
					If oRHLStruct:IsUpdated()
						For nP := 1 To Len(aRHLFields)
							cCampo := aRHLFields[nP, MODEL_FIELD_IDFIELD ]
							If oRHLStruct:GetValue( cCampo ) <> oCpyRHLStru:GetValue( cCampo )
								If cCampo == "RHL_PLANO" .and. Empty(cTpDIRF)
									cTpDIRF := "03"
								ElseIf cCampo == "RHL_TPPLAN" .and. Empty(cTpDIRF)
									cTpDIRF := "02"
								ElseIf (cCampo == "RHL_PERINI" .Or. cCampo == "RHL_PERFIM")  .and. Empty(cTpDIRF)
									cTpDIRF := "04"
								ElseIf Empty(cTpDIRF)
									cTpDIRF := "05"
								EndIf
								uTypeoper := "1"
							EndIf
						Next nP
					ElseIf oRHLStruct:IsDeleted() .Or. lRHKDelet
						uTypeoper := "2"
					EndIf
				EndIf

				// Geracao na tabela de historicos //
				If !Empty( uTypeoper )
					If nLinha > 1
						oRHNStruct:AddLine()
					EndIf
					nLinha++
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_FILIAL"	, SRA->RA_FILIAL )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MAT"		, SRA->RA_MAT )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_DATA"		, dDataBase )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_OPERAC"	, uTypeOper )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_ORIGEM"	, "2" )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPALT"	, cTpDIRF )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CODIGO"	, oCpyRHLStru:GetValue( "RHL_CODIGO" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_NOME"		, Alltrim(oCpyRHLStru:GetValue( "RHL_NOME" )) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPFORN"	, oCpyRHKStru:GetValue( "RHK_TPFORN" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CODFOR"	, oCpyRHKStru:GetValue( "RHK_CODFOR" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPPLAN"	, oCpyRHLStru:GetValue( "RHL_TPPLAN" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PLANO"	, oCpyRHLStru:GetValue( "RHL_PLANO" ) )
   				    oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PD"    	, oCpyRHKStru:GetValue( "RHK_PD" ) )
				    oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PDDAGR"	, oCpyRHKStru:GetValue( "RHK_PDDAGR" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PERINI"	, oCpyRHLStru:GetValue( "RHL_PERINI" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PERFIM"	, oCpyRHLStru:GetValue( "RHL_PERFIM" ) )

					If (RHL->(ColumnPos( "RHL_CNS")) > 0) .AND. (RHL->(ColumnPos( "RHL_MATSAU")) > 0) .AND. (RHL->(ColumnPos( "RHL_MATODO")) > 0)
						oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CNS"	    , oCpyRHLStru:GetValue( "RHL_CNS" ) )
						oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MATSAU"   , oCpyRHLStru:GetValue( "RHL_MATSAU" ) )
						oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MATODO"   , oCpyRHLStru:GetValue( "RHL_MATODO" ) )
					EndIf

				EndIf
			EndIf
		Next nJ

		// Gravacao do historio dos Agregados //
		oCpyRHMStru := __oModelCopy:GetModel( "GPEA001_MRHM" )
		nRHMLine 		:= oRHMStruct:Length()
		nRHMCpyLines	:= oCpyRHMStru:Length()
		If cTpDIRF <> "01"
			cTpDIRF := ""
		EndIf
		For nJ := 1 To nRHMLine

			oRHMStruct:GoLine( nJ )

			uTypeoper := ""
			If nJ <= nRHMCpyLines
				oCpyRHMStru:GoLine( nJ )
				If !oCpyRHMStru:IsInserted()
					oRHMStru := oRHMStruct:GetStruct()
					aRHMFields := oRHMStru:GetFields()
					If oRHMStruct:IsUpdated()
						For nP := 1 To Len(aRHMFields)
							cCampo := aRHMFields[nP, MODEL_FIELD_IDFIELD ]
							If oRHMStruct:GetValue( cCampo ) <> oCpyRHMStru:GetValue( cCampo )
								If cCampo == "RHM_PLANO" .and. Empty(cTpDIRF)
									cTpDIRF := "03"
								ElseIf cCampo == "RHM_TPPLAN" .and. Empty(cTpDIRF)
									cTpDIRF := "02"
								ElseIf (cCampo == "RHM_PERINI" .Or. cCampo == "RHM_PERFIM")  .and. Empty(cTpDIRF)
									cTpDIRF := "04"
								ElseIf Empty(cTpDIRF)
									cTpDIRF := "05"
								EndIf
								uTypeoper := "1"
							EndIf
						Next nP
					ElseIf oRHMStruct:IsDeleted() .Or. lRHKDelet
						uTypeoper := "2"
					EndIf
				EndIf

				// Geracao na tabela de historicos //
				If !Empty( uTypeoper )
					If nLinha > 1
						oRHNStruct:AddLine()
					EndIf
					nLinha++
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_FILIAL"	, SRA->RA_FILIAL )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MAT"		, SRA->RA_MAT )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_DATA"		, dDataBase )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_OPERAC"	, uTypeOper )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_ORIGEM"	, "3" )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPALT"		, cTpDIRF )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPFORN"	, oCpyRHKStru:GetValue( "RHK_TPFORN" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CODFOR"	, oCpyRHKStru:GetValue( "RHK_CODFOR" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CODIGO"	, oCpyRHMStru:GetValue( "RHM_CODIGO" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_NOME"		, Alltrim(oCpyRHMStru:GetValue( "RHM_NOME" )) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_TPPLAN"	, oCpyRHMStru:GetValue( "RHM_TPPLAN" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PLANO"	, oCpyRHMStru:GetValue( "RHM_PLANO" ) )
				    oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PD"		, oCpyRHKStru:GetValue( "RHK_PD" ) )
				    oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PDDAGR"	, oCpyRHKStru:GetValue( "RHK_PDDAGR" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PERINI"	, oCpyRHMStru:GetValue( "RHM_PERINI" ) )
					oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_PERFIM"	, oCpyRHMStru:GetValue( "RHM_PERFIM" ) )

					If (RHK->(ColumnPos( "RHK_CNS")) > 0) .AND. (RHK->(ColumnPos( "RHK_MATSAU")) > 0) .AND. (RHK->(ColumnPos( "RHK_MATODO")) > 0)
						oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_CNS"	    , oCpyRHKStru:GetValue( "RHK_CNS" ) )
						oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MATSAU"   , oCpyRHKStru:GetValue( "RHK_MATSAU" ) )
						oRHNModel:LoadValue( "GPEA002_MRHN", "RHN_MATODO"   , oCpyRHKStru:GetValue( "RHK_MATODO" ) )
					EndIf

				EndIf
			EndIf
		Next nJ
	Next nI

	RestARea(aAreaGPE)

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gp001Commit	ЁAutorЁ  Mauricio TakakuraЁ Data Ё31/10/2010Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁGravacao dos dados do MODEL                                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gp001Commit(oModel)

	FwFormCommit( oModel )
	FwFormCommit( oRHNModel )

	__oModelCopy:DeActivate()

	cFilAnt := cFilOld
	fActiv_Model(oModel)

Return .T.

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpa001SRAStru	ЁAutorЁ  Mauricio TakakuraЁ Data Ё31/10/2010Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRA                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpa001SRAStru( cCampo )
	Local lRet := .F.

	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_FILIAL*RA_MAT*RA_NOME*RA_ADMISSA'
		lRet := .T.
	EndIf

Return lRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RHK_LinhaOK	ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao da Linha OK                                       Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHK_LinhaOK(oRHKStruct)

	Local aLog		:= { {}, {} }

	Local cLog
	Local cPerIni
	Local cPerFim
	Local cTpForn
	Local cCodFor
	Local cCodPlano
	Local cRHKMAFim := "" //mesAno fim referente a RHK_DATFIM
	Local cRHKDatFim := ""
	Local cVbDifTit := ""
	Local cVbDifDeAg := ""

	Local lRet 		:= .T.
	Local lRHKDatFim := RHK->(ColumnPos("RHK_DATFIM")) > 0

	Local nI
	Local nLines

	Local oModel		:= FWModelActive()
	Local oRHLStruct	:= oModel:GetModel( "GPEA001_MRHL" )
	Local oRHMStruct	:= oModel:GetModel( "GPEA001_MRHM" )
	Local nLinAtual		:= 0

	Local cMesAntes		:= ""
	Local cRot			:= ""
	Local nPos			:= 0
	Local lCalc			:= .F.


	// Validacao do Plano de Saude para o Titular //
	cTpForn 	:= oRHKStruct:GetValue( "RHK_TPFORN" )
	cCodFor	    := oRHKStruct:GetValue( "RHK_CODFOR" )
	cTpPlano	:= oRHKStruct:GetValue( "RHK_TPPLAN" )
	cCodPlano	:= oRHKStruct:GetValue( "RHK_PLANO"	 )

	cPerIni		:= oRHKStruct:GetValue( "RHK_PERINI" )
	cPerFim		:= oRHKStruct:GetValue( "RHK_PERFIM" )


	lRet := fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano)

	If ! lRet
		Return( lRet )
	EndIf

	// Verifico se jА existe CСdigo do Fornecedor no PerМodo Inicial informado!
	nLinAtual	:= oRHKStruct:GetLine( )
	nLines		:= oRHKStruct:Length()

	// Validacao das Verbas do titular e Dep. / Agreg.
	cVerbaTit	:= oRHKStruct:GetValue( "RHK_PD" )
	cVerbaDeAg	:= oRHKStruct:GetValue( "RHK_PDDAGR" )

	If cVerbaTit == cVerbaDeAg
		Help( , , 'HELP', , OemToAnsi( STR0053 ), 1, 0 )		// "As Verbas do Titular e dos Dep./Agreg. nЦo podem ser iguais!"
		lRet := .F.
	EndIf

	// Validacao do Periodo de Validade do Plano //
	If ! Empty( cPerFim )
		cRot := If (SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar())
		If Type("aPerAtual") == "U" .or. Empty(aPerAtual) .or. !(aPerAtual[1,8] == SRA->RA_PROCES)
			fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRot )

			If Empty(aPerAtual)
				Help( , , 'HELP', , OemToAnsi( STR0057 + CRLF + STR0055 + CRLF+CRLF + STR0056  ), 1, 0 ) // '"Periodo Final deve ser Igual ou Maior ao MЙs do Periodo Atual.' ### "Caso queira reativar o plano, retire o PerМodo Final e altere os dados se for necessАrio. Novos registros devem ser informados apenas em caso de novo Fornecedor de Plano de saЗde."
				Return(.F.)
			Else
				nPos := Ascan( aPerAtual ,{|x| x[3] == cRot})
			EndIf
			cMesAntes := AnoMes(aPerAtual[1,6]-1)
		EndIf
		If Ctod( "01/"+Substr(cPerFim,1,2)+"/"+Substr(cPerFim,3,4) ) < Ctod( "01/"+Substr(cPerIni,1,2)+"/"+Substr(cPerIni,3,4) )
			Help(,,'HELP',,OemToAnsi(STR0010),1,0)				//'Periodo Final menor que o Periodo Inicial!'
			lRet := .F.
		ElseIf Substr( cPerFim, 3, 4 ) + Substr( cPerFim, 1, 2 ) < cMesAntes
			Help( , , 'HELP', , OemToAnsi( STR0057 + CRLF + STR0055 + CRLF+CRLF + STR0056  ), 1, 0 )	// '"Periodo Final deve ser Igual ou Maior ao MЙs do Periodo Atual.' ### "Caso queira reativar o plano, retire o PerМodo Final e altere os dados se for necessАrio. Novos registros devem ser informados apenas em caso de novo Fornecedor de Plano de saЗde."
			lRet := .F.
		ElseIf nPos > 0
			// o cPerfim pode ser igual ou maior que o Periodo Atual (aPerAtual[1,6])
			//Porem, se o cPerfim for igual ao cMesAntes eh necessario verificar se o Periodo Atual jah possui calculo realizado
			If Substr( cPerFim, 3, 4 ) + Substr( cPerFim, 1, 2 ) == cMesAntes
				If GetCalcPla(aPerAtual[1, 1])
					// "PerМodo Final" # "O perМodo final informado И anterior ao atual e existe cАlculo para o funcinАrio no perМodo atual." #
					// "и necessАrio cancelar o cАlculo atual para informar um perМodo final anterior."
					Help(NIL, NIL, STR0104, NIL,  STR0083, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0084})
					lRet := .F.
				Endif
			EndIf
		EndIf
	EndIf

	If Substr(cPerIni,3,4) + Substr(cPerIni,1,2) < Substr(Dtos(SRA->RA_ADMISSA),1,6)
		Help(,,'HELP',,OemToAnsi(STR0027),1,0)	//'Periodo Inicial menor que o MЙs da AdmissЦo do FuncionАrio!'
		lRet := .F.
	EndIf

	// Analisar Tipo de Fornecedor e Codigo Fornecedor em duplicidade para o titular
	If lRet
		cLog		:= ""
		nLinAtual	:= oRHKStruct:GetLine( )
		nLines		:= oRHKStruct:Length()

		For nI := 1 To nLines
			oRHKStruct:GoLine( nI )
			If 	oRHKStruct:GetValue( "RHK_TPFORN" ) == cTpForn .and. oRHKStruct:GetValue( "RHK_CODFOR" ) == cCodFor .and. ;
				oRHKStruct:GetLine( ) <> nLinAtual	.and. ! oRHKStruct:IsDeleted() .and. !Empty(cPerFim) .and. !Empty(oRHKStruct:GetValue( "RHK_PERFIM" ))
        		If Empty( oRHKStruct:GetValue( "RHK_PERFIM" ) )
        			Help( , , 'HELP', , OemToAnsi( STR0079 ) + OemToAnsi( STR0080 ), 1, 0 ) // Fornecedor jА utilizado no perМodo informado. PerМodo anterior em aberto.
        			lRet := .F.
        			Exit
        		ElseIf Ctod( "01/"+Substr(cPerIni,1,2)+"/"+Substr(cPerIni,3,4) ) < Ctod( "01/"+Substr(oRHKStruct:GetValue( "RHK_PERFIM" ),1,2)+"/"+Substr(oRHKStruct:GetValue( "RHK_PERFIM" ),3,4) ) .And.;
        		 		oRHKStruct:GetValue( "RHK_TPPLAN" )	 == cTpPlano .and.  oRHKStruct:GetValue( "RHK_PLANO" ) == cCodPlano
        			//Help( , , 'HELP', , OemToAnsi( STR0079 ), 1, 0 ) // Fornecedor jА utilizado no perМodo informado.
        			Help( , , 'HELP', , OemToAnsi( STR0052 + CRLF + STR0055 + CRLF+CRLF + STR0056 ), 1, 0 )	// '"Tipo e CСdigo de Fornecedor jА cadastrado para o Titular!"' ### "Caso queira reativar o plano, retire o PerМodo Final e altere os dados se for necessАrio. Novos registros devem ser informados apenas em caso de novo Fornecedor de Plano de saЗde."
        			lRet := .F.
        			Exit
				EndIf
	        EndIf

			// verifico se jА nЦo existe o mesmo fornecedor
			if oRHKStruct:GetValue( "RHK_TPFORN" ) == cTpForn .and. oRHKStruct:GetValue( "RHK_CODFOR" ) == cCodFor .and. ;
				oRHKStruct:GetLine( ) <> nLinAtual .and. ! oRHKStruct:IsDeleted() .and. oRHKStruct:GetValue( "RHK_TPPLAN" )	 == cTpPlano .and. ;
				oRHKStruct:GetValue( "RHK_PLANO" ) == cCodPlano .and. IF( Empty(oRHKStruct:GetValue( "RHK_PERFIM" )), .T. , cPerIni <= oRHKStruct:GetValue( "RHK_PERFIM" ) )
				Help( , , 'HELP', , OemToAnsi( STR0079 ), 1, 0 ) // Fornecedor jА utilizado no perМodo informado.
				lRet := .F.
				Exit
			endif

		Next nI
		oRHKStruct:GoLine( nLinAtual )
	EndIf

	If lRet
		cLog := ""
		// Analisar e Compatibilizar Codigo Fornecedor com os Registros Filhos //
		nLinAtual	:= oRHLStruct:GetLine( )
		nLines		:= oRHLStruct:Length()
		For nI := 1 To nLines
			oRHLStruct:GoLine( nI )

			If !Empty(oRHLStruct:GetValue( "RHL_CODIGO" )) .and. !oRHLStruct:IsDeleted()
				cTpPlano	:= oRHLStruct:GetValue( "RHL_TPPLAN" )
				cCodPlano	:= oRHLStruct:GetValue( "RHL_PLANO" )

				If !fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano, .F.)
					aAdd( aLog[1], nI )
        		ElseIf lRHKDatFim .AND. !Empty(oRHLStruct:GetValue( "RHL_DATFIM" )) .AND. Empty(oRHKStruct:GetValue( "RHK_PDDIFD" ))
        			Help(,,'HELP',,OemToAnsi(STR0085),1,0) //"A Verba de pagamento da DiferenГa do Plano do Dep./Agreg. deve ser peenchida !"
					lRet := .F.
					Exit
				ElseIf lRHKDatFim .AND. !Empty(oRHKStruct:GetValue( "RHK_DATFIM" )) .AND. Empty(oRHLStruct:GetValue( "RHL_DATFIM" ))
        			Help(,,'HELP',,OemToAnsi(STR0086),1,0) //"A Data Final do Plano do Dependente deve ser peenchida !"
					lRet := .F.
					Exit
        		EndIf
            EndIf
		Next nI
		oRHLStruct:GoLine( nLinAtual )

		nLinAtual	:= oRHMStruct:GetLine( )
		nLines		:= oRHMStruct:Length()
		For nI := 1 To nLines
			oRHMStruct:GoLine( nI )
			If !Empty(oRHMStruct:GetValue( "RHM_CODIGO" )) .And.!Empty(oRHMStruct:GetValue( "RHM_NOME" )) .and. !oRHMStruct:IsDeleted()
				cTpPlano	:= oRHMStruct:GetValue( "RHM_TPPLAN" )
				cCodPlano	:= oRHMStruct:GetValue( "RHM_PLANO" )

				If !fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano, .F. )
					aAdd( aLog[2], nI )
				ElseIf lRHKDatFim .AND. !Empty(oRHMStruct:GetValue( "RHM_DATFIM" )) .AND. Empty(oRHKStruct:GetValue( "RHK_PDDIFD" ))
        			Help(,,'HELP',,OemToAnsi(STR0085),1,0) //"A Verba de pagamento da DiferenГa do Plano do Dep./Agreg. deve ser peenchida !"
					lRet := .F.
					Exit
				ElseIf lRHKDatFim .AND. !Empty(oRHKStruct:GetValue( "RHK_DATFIM" )) .AND. Empty(oRHMStruct:GetValue( "RHM_DATFIM" ))
        			Help(,,'HELP',,OemToAnsi(STR0087),1,0) //"A Data Final do Plano do Agregado deve ser peenchida !"
					lRet := .F.
					Exit
        		EndIf
	    	EndIf
		Next nI
		oRHMStruct:GoLine( nLinAtual )

		If Len( aLog[1] ) > 0 .Or. Len( aLog[2] ) > 0
			If Len( aLog[1] ) > 0
				cLog := OemToAnsi( STR0016 ) + CRLF // 'InconsistЙncias nas InformaГУes do Plano dos Dependentes: '
				For nI := 1 To Len( aLog[1] )
					cLog += OemToAnsi( STR0017 ) + Str( aLog[1, nI], 3, 0 ) + CRLF  // "Linha: "
				Next
			EndIf

			If Len( aLog[2] ) > 0
				If !Empty(cLog)
					cLog += CRLF
				EndIf
				cLog += OemToAnsi( STR0018 ) + CRLF // 'InconsistЙncias nas InformaГУes do Plano dos Agregados: '
				For nI := 1 To Len( aLog[2] )
					cLog += OemToAnsi( STR0017 ) + Str( aLog[2, nI], 3, 0 ) + CRLF  // "Linha: "
				Next
			EndIf

			AutoGrLog( cLog )

			MostraErro()

			lRet := .F.

		EndIf
	EndIf

	If lRet .AND. lRHKDatFim
		If !Empty(oRHKStruct:GetValue("RHK_DATFIM"))
			cRHKMAFim := StrZero(Month(oRHKStruct:GetValue("RHK_DATFIM")),2) + cValToChar(Year(oRHKStruct:GetValue("RHK_DATFIM")))
			cRHKDatFim := StrZero(Day(oRHKStruct:GetValue("RHK_DATFIM")),2) + "/" + StrZero(Month(oRHKStruct:GetValue("RHK_DATFIM")),2) +"/"+ cValToChar(Year(oRHKStruct:GetValue("RHK_DATFIM")))
			If !Empty(oRHKStruct:GetValue("RHK_PERFIM")) .AND. cRHKMAFim <> oRHKStruct:GetValue("RHK_PERFIM")
				Help(,,'HELP',,OemToAnsi(STR0088) +" ("+cRHKDatFim+") "+OemToAnsi(STR0089)+" ("+oRHKStruct:GetValue("RHK_PERFIM")+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo Final informado ().
				lRet := .F.
			EndIf
		EndIf
		cVbDifTit := oRHKStruct:GetValue("RHK_PDDIFT")
		cVbDifDeAg := oRHKStruct:GetValue("RHK_PDDIFD")
		If lRet .AND. (!Empty(cVbDifTit) .AND. (cVbDifTit == cVerbaTit .OR. cVbDifTit == cVerbaDeAg .OR. cVbDifTit == cVbDifDeAg)) .OR. ;
			(!Empty(cVbDifDeAg) .AND. (cVbDifDeAg == cVerbaTit .OR. cVbDifDeAg == cVerbaDeAg .OR. cVbDifTit == cVbDifDeAg))
			Help(,,'HELP',,OemToAnsi(STR0090)+CRLF+OemToAnsi(STR0091)+cVerbaTit+CRLF+OemToAnsi(STR0092)+cVerbaDeAg+CRLF+OemToAnsi(STR0093)+cVbDifTit+CRLF+OemToAnsi(STR0094)+cVbDifDeAg,1,0)
			//"As verbas de pagamento nЦo podem ser iguais!"##"Verba Titular: "##"Verba Dep./Agreg.: "##"Verba Dif. Titular: "##"Verba Dif. Dep./Agreg.: "
			lRet := .F.
		EndIf
		If lRet .AND. !Empty(oRHKStruct:GetValue("RHK_DATFIM")) .AND. Empty(cVbDifTit)
			Help(,,'HELP',,OemToAnsi(STR0095),1,0) //"A Verba de pagamento da DiferenГa do Plano do Titular deve ser peenchida!"
			lRet := .F.
		EndIf
	EndIf

	If !IsInCallStack("GPEM027") .AND. lRet
		lRet := fVldTpCalc("RHK")
	EndIf

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RHK_TudoOK		ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao do Tudo OK                                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHK_TudoOK(oModel)

	Local aTpPD	:= {}

	Local cPDAnt:= ""
	Local cTipo	:= ""

	Local lRet 	:= .T.
	Local lTemPlano := .F.

	Local nI
	Local nLines := oModel:Length()

	aAdd( aTpPD, { "1", "" } ) // Assistencia Medica
	aAdd( aTpPD, { "2", "" } ) // Assistencia Medica

	For nI := 1 To nLines
		oModel:GoLine( nI )

	    If !oModel:IsDeleted()
			cPDAnt 	:= oModel:GetValue( "RHK_PDDAGR" )
			lTemPlano	:= .T.
			If !Empty(cPDAnt)
				cTipo	:= oModel:GetValue( "RHK_TPFORN" )
				nPos := aScan( aTpPD, { |x| x[1] == cTipo .and. x[2] == cPDAnt } )
				If cTipo == "1"
					If nPos == 0
						aAdd( aTpPD, { "1", cPDAnt } ) // Assistencia Medica
					EndIf
					cTipo := "2"
				Else
					If nPos == 0
						aAdd( aTpPD, { "2", cPDAnt } ) // Assistencia Medica
					EndIf
					cTipo := "1"
				EndIf

				nPos := aScan( aTpPD, { |x| x[1] == cTipo .and. x[2] == cPDAnt } )
				If nPos > 0
					Help(,,'HELP',,OemToAnsi(STR0015),1,0)	//'As verbas entre Planos de Assist. Medica e Odontologica nao podem ser repetidas!'
					lRet := .F.
				EndIf
			EndIf
	    EndIf

	Next nI

	If lRet .AND. lTemPlano
		RecLock("SRA",.F.)
			SRA->RA_PLSAUDE := "1"
		SRA->(msUnlock())
	EndIf

	//--> Ajuste para caso nЦo haja linha de plano de saЗde e o campo RA_PLSAUDE == 1(Sim) voltar o conteЗdo do campo para 2(NЦo)
	If lRet .And. !lTemPlano
		RecLock("SRA", .F.)
		SRA->RA_PLSAUDE := "2"
		SRA->( MsUnlock() )
	EndIf

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RHL_LinhaOK	ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao da Linha OK                                       Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHL_LinhaOK(oModel)
	Local cPerIni
	Local cPerFim
	Local cTitPerIni
	Local cTitPerFim
	Local cTpForn
	Local cCodFor
	Local cCodPlano
	Local cPDDAGR
	Local cRot
	Local cRHLMAFim := "" //mesAno fim referente a RHK_DATFIM
	Local cRHLDatFim := ""

	Local lRet := .T.
	Local lRHKDatFim := RHK->(ColumnPos("RHK_DATFIM")) > 0

	Local oModelRHK
	Local oStructRHK
	Local oStructRHL

	Local cMesAntes		:= ""

	// Validacao do Plano de Saude //
	oModelRHK 	:= FWModelActive()
	oStructRHK	:= oModelRHK:GetModel( "GPEA001_MRHK" )
	oStructRHL	:= oModelRHK:GetModel( "GPEA001_MRHL" )
	cTpForn		:= oStructRHK:GetValue("RHK_TPFORN")
	cCodFor		:= oStructRHK:GetValue("RHK_CODFOR")
	cTitPerIni	:= oStructRHK:GetValue("RHK_PERINI")
	cTitPerFim	:= oStructRHK:GetValue("RHK_PERFIM")
	cPDDAGR		:= oStructRHK:GetValue("RHK_PDDAGR")

	cTpPlano	:= oModel:GetValue( "RHL_TPPLAN" )
	cCodPlano	:= oModel:GetValue( "RHL_PLANO" )

	lRet := fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano)

	// Validacao dos Periodos //
	cPerIni := oModel:GetValue( "RHL_PERINI" )
	cPerFim := oModel:GetValue( "RHL_PERFIM" )

	If ! Empty( cPerFim )
		If Type("aPerAtual") == "U" .or. Empty(aPerAtual) .or. !(aPerAtual[1,8] == SRA->RA_PROCES)
			cRot := If (SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar())
			fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRot )

			If Empty(aPerAtual)
				Help( , , 'HELP', , OemToAnsi( STR0057 + CRLF + STR0055 + CRLF+CRLF + STR0056  ), 1, 0 ) //Nao foi encontrado Periodo ativo para calculo da Folha. Verifique os Cadastro de Periodos.
				// '"Periodo Final deve ser Igual ou Maior ao MЙs do Periodo Atual.' ### "Caso queira reativar o plano, retire o PerМodo Final e altere os dados se for necessАrio. Novos registros devem ser informados apenas em caso de novo Fornecedor de Plano de saЗde."
				Return(.F.)
			EndIf
			cMesAntes := AnoMes(aPerAtual[1,6]-1)
		EndIf
		If Ctod( "01/"+Substr(cPerFim,1,2)+"/"+Substr(cPerFim,3,4) ) < Ctod( "01/"+Substr(cPerIni,1,2)+"/"+Substr(cPerIni,3,4) )
			Help(,,'HELP',,OemToAnsi(STR0010),1,0)				//'Periodo Final menor que o Periodo Inicial!'
			lRet := .F.
		ElseIf Substr( cPerFim, 3, 4 ) + Substr( cPerFim, 1, 2 ) < cMesAntes
			Help( , , 'HELP', , OemToAnsi( STR0070 + CRLF + STR0055 + CRLF+CRLF + STR0056 ), 1, 0 )	// 'Periodo Final deve ser Igual ou Maior ao MЙs Anterior da Folha!' ### "Caso queira reativar o plano, retire o PerМodo Final e altere os dados se for necessАrio. Novos registros devem ser informados apenas em caso de novo Fornecedor de Plano de saЗde."
			lRet := .F.
		EndIf
	EndIf

	// Validacao do Periodo do Dependente em relacao ao Periodo do Titular
	If lRet .and. Ctod( "01/"+Substr(cPerIni,1,2)+"/"+Substr(cPerIni,3,4) ) < Ctod( "01/"+Substr(cTitPerIni,1,2)+"/"+Substr(cTitPerIni,3,4) )
		Help(,,'HELP',,OemToAnsi(STR0013),1,0)	//'Periodo Inicial deve ser maior ou igual ao Periodo Inicial do Titular'
		lRet := .F.
	EndIf

	If lRet .and. !Empty( cTitPerFim )
		If (Ctod( "01/"+Substr(cPerFim,1,2)+"/"+Substr(cPerFim,3,4) ) > Ctod( "01/"+Substr(cTitPerFim,1,2)+"/"+Substr(cTitPerFim,3,4) )) .Or. Empty( cPerFim )
			Help(,,'HELP',,OemToAnsi(STR0014),1,0)	//'Periodo Final deve ser menor ou igual ao Periodo Final do Titular'
			lRet := .F.
		EndIf
	EndIf

	If lRet .and. Empty(cPDDAGR)
		Help(,,'HELP',,OemToAnsi(STR0019),1,0)	//'Existem lanГamentos para Agregados/Dependentes. Obrigatorio o lanГamento da Verba!'
		lRet := .F.
	EndIf

	If lRet .AND. lRHKDatFim
		If !Empty(oStructRHL:GetValue("RHL_DATFIM"))
			cRHLMAFim := StrZero(Month(oStructRHL:GetValue("RHL_DATFIM")),2) + cValToChar(Year(oStructRHL:GetValue("RHL_DATFIM")))
			cRHLDatFim := StrZero(Day(oStructRHL:GetValue("RHL_DATFIM")),2) + "/" + StrZero(Month(oStructRHL:GetValue("RHL_DATFIM")),2) +"/"+ cValToChar(Year(oStructRHL:GetValue("RHL_DATFIM")))
			If !Empty(oStructRHL:GetValue("RHL_PERFIM")) .AND. cRHLMAFim <> oStructRHL:GetValue("RHL_PERFIM")
				Help(,,'HELP',,OemToAnsi(STR0088)+" ("+cRHLDatFim+") "+OemToAnsi(STR0089)+" ("+oStructRHL:GetValue("RHL_PERFIM")+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo Final informado ().
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If !IsInCallStack("GPEM027") .AND. lRet
		lRet := fVldTpCalc("RHL")
	EndIf

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RHM_LinhaOK	ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao da Linha OK                                       Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHM_LinhaOK(oModel)
	Local cPerIni
	Local cPerFim
	Local cTitPerIni
	Local cTitPerFim
	Local cTpForn
	Local cCodFor
	Local cCodPlano
	Local cPDDAGR
	Local dDtNasc
	Local cCPF
	Local cRot
	Local cRHMMAFim := "" //mesAno fim referente a RHK_DATFIM
	Local cRHMDatFim := ""

	Local nAge

	Local lRet := .T.
	Local lRHKDatFim := RHK->(ColumnPos("RHK_DATFIM")) > 0

	Local oModelRHK
	Local oStructRHK
	Local oStructRHM

	Local cMesAntes		:= ""

	Local cVersaoEnv	:= ''
	Local lVersao		:= .f.

	Local lObgESocial 	:= (SuperGetMv("MV_EFDAVIS",NIL,"2") == "1")

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersaoEnv )
	Else
		cVersaoEnv := '2.2'
	EndIf

	lVersao := cVersaoEnv >= "2.5.00"

	// Validacao do Plano de Saude //
	oModelRHK 	:= FWModelActive()
	oStructRHK	:= oModelRHK:GetModel( "GPEA001_MRHK" )
	oStructRHM	:= oModelRHK:GetModel( "GPEA001_MRHM" )
	cTpForn		:= oStructRHK:GetValue("RHK_TPFORN")
	cCodFor		:= oStructRHK:GetValue("RHK_CODFOR")
	cTitPerIni	:= oStructRHK:GetValue("RHK_PERINI")
	cTitPerFim	:= oStructRHK:GetValue("RHK_PERFIM")
	cPDDAGR		:= oStructRHK:GetValue("RHK_PDDAGR")

	cTpPlano	:= oModel:GetValue( "RHM_TPPLAN" )
	cCodPlano	:= oModel:GetValue( "RHM_PLANO" )

	lRet := fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano)

	// Validacao dos Periodos //
	cPerIni := oModel:GetValue( "RHM_PERINI" )
	cPerFim := oModel:GetValue( "RHM_PERFIM" )

	If ! Empty( cPerFim )
		If Type("aPerAtual") == "U" .or. Empty(aPerAtual) .or. !(aPerAtual[1,8] == SRA->RA_PROCES)
			cRot := If (SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar())
			fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRot )

			If Empty(aPerAtual)
				Help( , , 'HELP', , OemToAnsi( STR0057 + CRLF + STR0055 + CRLF+CRLF + STR0056  ), 1, 0 )
				// '"Periodo Final deve ser Igual ou Maior ao MЙs do Periodo Atual.' ### "Caso queira reativar o plano, retire o PerМodo Final e altere os dados se for necessАrio. Novos registros devem ser informados apenas em caso de novo Fornecedor de Plano de saЗde."
				Return(.F.)
			EndIf
			cMesAntes := AnoMes(aPerAtual[1,6]-1)
		EndIf
		If Ctod( "01/"+Substr(cPerFim,1,2)+"/"+Substr(cPerFim,3,4) ) < Ctod( "01/"+Substr(cPerIni,1,2)+"/"+Substr(cPerIni,3,4) )
			Help(,,'HELP',,OemToAnsi(STR0010),1,0)				//'Periodo Final menor que o Periodo Inicial!'
			lRet := .F.
		ElseIf Substr( cPerFim, 3, 4 ) + Substr( cPerFim, 1, 2 ) < cMesAntes
			Help( , , 'HELP', , OemToAnsi( STR0070 + CRLF + STR0055 + CRLF+CRLF + STR0056 ), 1, 0 )	// 'Periodo Final deve ser Igual ou Maior ao MЙs Anterior da Folha!' ### "Caso queira reativar o plano, retire o PerМodo Final e altere os dados se for necessАrio. Novos registros devem ser informados apenas em caso de novo Fornecedor de Plano de saЗde."
			lRet := .F.
		EndIf
	EndIf

	// Validacao do Periodo do Dependente em relacao ao Periodo do Titular
	If lRet .and. Ctod( "01/"+Substr(cPerIni,1,2)+"/"+Substr(cPerIni,3,4) ) < Ctod( "01/"+Substr(cTitPerIni,1,2)+"/"+Substr(cTitPerIni,3,4) )
		Help(,,'HELP',,OemToAnsi(STR0013),1,0)	//'Periodo Inicial deve ser maior ou igual ao Periodo Inicial do Titular'
		lRet := .F.
	EndIf

	If lRet .and. !Empty( cTitPerFim )
		If (Ctod( "01/"+Substr(cPerFim,1,2)+"/"+Substr(cPerFim,3,4) ) > Ctod( "01/"+Substr(cTitPerFim,1,2)+"/"+Substr(cTitPerFim,3,4) )) .Or. Empty( cPerFim )
			Help(,,'HELP',,OemToAnsi(STR0014),1,0)	//'Periodo Final deve ser menor ou igual ao Periodo Final do Titular'
			lRet := .F.
		EndIf
	EndIf

	If lRet .and. Empty(cPDDAGR)
		Help(,,'HELP',,OemToAnsi(STR0019),1,0)	//'Existem lanГamentos para Agregados/Dependentes. Obrigatorio o lanГamento da Verba!'
		lRet := .F.
	EndIf

	// Validar idade do Agregado para CPF
	dDtNasc		:= oModel:GetValue("RHM_DTNASC")
	cCPF		:= oModel:GetValue("RHM_CPF")


	If lRet .and. Empty( cCPF )
		if lObgESocial .and. lVersao
			Help(,,'HELP',,OemToAnsi(STR0103),1,0)	//"и necessario informar o CPF do agregado para Planos de SaЗde."
			lret := .f.
		Else
			nAge := DateDiffYear( dDataBase , dDtNasc )
			If nAge > 18
				Help(,,'HELP',,OemToAnsi(STR0020),1,0)	//"и necessario informar o CPF para maiores de 18 anos para Planos de SaЗde."
			EndIf
		endif
	EndIf

	If lRet .AND. lRHKDatFim
		If !Empty(oStructRHM:GetValue("RHM_DATFIM"))
			cRHMMAFim := StrZero(Month(oStructRHM:GetValue("RHM_DATFIM")),2) + cValToChar(Year(oStructRHM:GetValue("RHM_DATFIM")))
			cRHMDatFim := StrZero(Day(oStructRHM:GetValue("RHM_DATFIM")),2) + "/" + StrZero(Month(oStructRHM:GetValue("RHM_DATFIM")),2) +"/"+ cValToChar(Year(oStructRHM:GetValue("RHM_DATFIM")))
			If !Empty(oStructRHM:GetValue("RHM_PERFIM")) .AND. cRHMMAFim <> oStructRHM:GetValue("RHM_PERFIM")
				Help(,,'HELP',,OemTOAnsi(STR0088)+" ("+cRHMDatFim+") "+OemToAnsi(STR0089)+" ("+oStructRHM:GetValue("RHM_PERFIM")+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo Final informado ().
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If !IsInCallStack("GPEM027") .AND. lRet
		lRet := fVldTpCalc("RHM")
	EndIf

Return( lRet )


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fVldSRB		ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao dos Dependentes                                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fVldSRB()
	Local aArea 		:= GetArea()
	Local lRet 			:= .F.	
	Local oModel 		:= FWModelActive()
	Local oStructSRA 	:= oModel:GetModel( "GPEA001_MSRA" )
	Local cFilSRA		:= xFilial("SRA")
	Local cMatSRA		:= oStructSRA:GetValue("RA_MAT")

	DbSelectArea( "SRB" )
	DbSetOrder( 1 )
	If DbSeek( cFilSRA	 + cMatSRA, .F. )
		While SRB->(!Eof()) .and. (SRB->RB_FILIAL + SRB->RB_MAT == xFilial("SRB",cFilSRA)	 + cMatSRA)
			If SRB->RB_COD == M->RHL_CODIGO
				lRet := .T.
				Exit
			EndIf
			SRB->(DbSkip())
		EndDo
	EndIf

	If SRB->(!Eof()) .and. !lRet
		Help(,,'HELP',,OemToAnsi(STR0011),1,0)	//"Sequencia do Beneficiario nao cadastrado!"
	ElseIf !IsInCallStack("FWMILEIMPORT")
		oModel:LoadValue("GPEA001_MRHL", "RHL_NOME", SRB->RB_NOME)
		RunTrigger()
	EndIf

	RestArea(aArea)

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fInitSRB		ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCarga do Inicializador Padrao de Nome da tabela SRB         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fInitSRB(cCodSeq)

	Local cRet
	Local lRet 			:= .F.
	Local oModel 		:= FWModelActive()
	Local oStructRHL	:= oModel:GetModel( "GPEA001_MRHL" )
	Local nRegRHL		:= oStructRHL:Length()

	DEFAULT cCodSeq := ""

	If nRegRHL == 0
		DbSelectArea( "SRB" )
		DbSetOrder( 1 )
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
		While !Eof() .and. (SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT)
			If SRB->RB_COD == cCodSeq
				lRet := .T.
				Exit
			EndIf
			DbSkip()
		EndDo

		If Eof() .Or. !lRet
			cRet := ""
		Else
			cRet := SRB->RB_NOME
		EndIf
	Else
		cRet := ""
	EndIf

Return (cRet)

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё When_NotEdit   ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁPermite somente digitacao em inclusao                       Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function When_NotEdit(oStruct, cModel)
	Local lRet	:= .T.

	Local nCpyLines

	Local oCpyStru := __oModelCopy:GetModel( cModel )

	nCpyLines	:= oCpyStru:Length()

	If oStruct:GetLine() <= nCpyLines .And. !oStruct:IsInserted()
		lRet := .F.
	EndIf

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fVldPlano		ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao do Plano de Saude                                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fVldPlano()

	Local cVar := Alltrim(ReadVar())
	Local cTpForn
	Local cCodFor
	Local cTpPlano
	Local cCodPlano

	Local lRet := .T.

	Local oModel
	Local oStructRHK
	Local oStructRHN

	oModel 		:= FWModelActive()

	If cVar <> "M->RHN_PLANO"
		oStructRHK	:= oModel:GetModel( "GPEA001_MRHK" )
		cTpForn		:= oStructRHK:GetValue("RHK_TPFORN")
		cCodFor		:= oStructRHK:GetValue("RHK_CODFOR")
	Else
		oStructRHN	:= oModel:GetModel( "GPEA002_MRHN" )
		cTpForn		:= oStructRHN:GetValue("RHN_TPFORN")
		cCodFor		:= oStructRHN:GetValue("RHN_CODFOR")
	EndIf

	If cVar == "M->RHK_PLANO"
		cTpPlano := oStructRHK:GetValue("RHK_TPPLAN")
		cCodPlano := oStructRHK:GetValue("RHK_PLANO")
	ElseIf cVar == "M->RHL_PLANO"
		oStructRHL	:= oModel:GetModel( "GPEA001_MRHL" )
		cTpPlano := oStructRHL:GetValue("RHL_TPPLAN")
		cCodPlano := oStructRHL:GetValue("RHL_PLANO")
	ElseIf cVar == "M->RHM_PLANO"
		oStructRHM	:= oModel:GetModel( "GPEA001_MRHM" )
		cTpPlano := oStructRHM:GetValue("RHM_TPPLAN")
		cCodPlano := oStructRHM:GetValue("RHM_PLANO")
	ElseIf cVar == "M->RHN_PLANO"
		cTpPlano := oStructRHN:GetValue("RHN_TPPLAN")
		cCodPlano := oStructRHN:GetValue("RHN_PLANO")
	EndIf

	lRet := fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano)

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fValidPlano	ЁAutorЁ  Mauricio TakakuraЁ Data Ё04/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao do Plano de Saude                                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano, lHelp)
	Local cCodTab := ""

	Local lRet 	  := .T.

	Local nColFor := 0
	Local nPosTab
	Local lChange := .F.

	DEFAULT lHelp	:= .T.

	If Type("cEmpChg") == "U"
		cEmpChg := cEmpAnt
		lChange := .T.
	ElseIf ( cEmpChg != cEmpAnt )
		lChange := lChange
	EndIf

	If cTpForn == "1"
		If cTpPlano == "1"
			cCodTab := "S008"
			nColFor := 13
		ElseIf cTpPlano == "2"
			cCodTab := "S009"
			nColFor := 13
		ElseIf cTpPlano == "3"
			cCodTab := "S028"
			nColFor := 12
		ElseIf cTpPlano == "4"
			cCodTab := "S029"
			nColFor := 15
		ElseIf cTpPlano == "5"
			cCodTab := "S059"
			nColFor := 14
		ElseIf cTpPlano == "6"
			cCodTab := "S140"
			nColFor := 14
		EndIf
	ElseIf cTpForn == "2"
		If cTpPlano == "1"
			nColFor := 13
			cCodTab := "S013"
		ElseIf cTpPlano == "2"
			cCodTab := "S014"
			nColFor := 13
		ElseIf cTpPlano == "3"
			cCodTab := "S030"
			nColFor := 12
		ElseIf cTpPlano == "4"
			cCodTab := "S031"
			nColFor := 15
		ElseIf cTpPlano == "5"
			cCodTab := "S060"
			nColFor := 14
		ElseIf cTpPlano == "6"
			cCodTab := "S141"
			nColFor := 14
		EndIf
	EndIf

	If FunName() == "GPEA063"
		nPosTab := fPosTab( cCodTab,cCodFor,"=",nColFor,cCodPlano,"=",4,,,,lChange,xFilial("RCC",cFilAnt),,,,,,,,.T.)
	else
		nPosTab := fPosTab( cCodTab,cCodFor,"=",nColFor,cCodPlano,"=",4,,,,lChange)
	EndIf

	If nPosTab == 0
		nPosTab := fPosTab( cCodTab,cCodFor,"=",nColFor,cCodPlano,"=",4,,,,lChange,Space(FwGetTamFilial))
	EndIf
	If nPosTab <= 0
		If lHelp
			Help(,,'HELP',,OemToAnsi(STR0012),1,0)	//'Codigo do Plano nao cadastrado!'
		EndIf
		lRet := .F.
	EndIf

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fViewCalc		ЁAutorЁ  Mauricio TakakuraЁ Data Ё23/10/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVisualizar o Calculo do Plano                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fViewCalc()

	Private cCompFil := ""

	If Pergunte("GPA001",.T.)

		cCompFil := Substr(MV_PAR01,3,4) + Substr(MV_PAR01,1,2)

		FWExecView(OemToAnsi(STR0021), "GPEM008" )

	EndIf

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GpLegMVC		ЁAutorЁ  Mauricio TakakuraЁ Data Ё24/10/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCria uma janela contendo a legenda da mBrowse               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GpLegMVC(oBrowse)
	Local lGestPubl := ExistFunc("fUsaGFP") .And. fUsaGFP()

	oBrowse:AddLegend( "SRA->RA_SITFOLH=='A'"		, 'YELLOW'	, OemToAnsi(STR0025) ) //Afastado
	oBrowse:AddLegend( "SRA->RA_SITFOLH=='F'"		, 'BLUE'	, OemToAnsi(STR0026) ) //Ferias

	If lGestPubl // Modulo Gestao de Folha Publica
		oBrowse:AddLegend( "SRA->RA_CATFUNC $ '78' .AND. SRA->RA_SITFOLH==' '   ", "GRAY"	, OemToAnsi(STR0105) ) //Aposentado
		oBrowse:AddLegend( "SRA->RA_CATFUNC $ '9'  .AND. SRA->RA_SITFOLH==' '   ", "ORANGE"	, OemToAnsi(STR0106) ) //Pensionista
	EndIf

	oBrowse:AddLegend( "SRA->RA_SITFOLH==' '"		, 'GREEN'	, OemToAnsi(STR0023) ) //Situacao Normal
	oBrowse:AddLegend( "SRA->RA_RESCRAI$'30/31'"	, 'PINK'	, OemToAnsi(STR0022) ) //"Transferido
	oBrowse:AddLegend( "SRA->RA_SITFOLH=='D'"		, 'RED'		, OemToAnsi(STR0024) ) //Demitido
Return( .T. )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fTrans			ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁTransferencia em Lote de Planos de Saude                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fTransfLote()

	Local aSays			:= {}
	Local aButtons		:= {}

	Local bProcesso		:= {|oSelf| GPMProc_Trans(oSelf)}

	Local cPergCal
	Local cDesc1		:= OemToAnsi(STR0037)	//"Transferencia em Lote de Planos de Saude"
	Local cDescricao	:= OemToAnsi(STR0038)	//"Este Programa realizara a transferencia entre Planos de Saude"

	Local nOpca := 0

	Private lAbortPrint := .F.
	Private aLog		:= {}
	Private aTitle		:= {}

	cPergCal 	:= "GPA001T"
	Pergunte(cPergCal,.F.)

	If !IsBlind()
		tNewProcess():New( "GPEA001", cDesc1, bProcesso, cDescricao, cPergCal, , , , , .T., .T.  )
	Else
		GPMProc_Trans()
	EndIf

	If Len(aLog) > 0
		//Apresenta com Log de erros
		fMakeLog(aLog,aTitle,,.T.,"TRFLOTE",STR0036,"M","P",,.F.)  //"LOG de Transferencia em Lote do Plano de Saude"
	EndIf
Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPMProc_Trans	ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁProcessamento da transferencia                              Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GPMProc_Trans(oSelf)
	Local cAliasSRA 	:= "SRA"
	Local cCposQuery	:= ""
	Local aRecRHK		:= {}
	Local aRecRHL		:= {}
	Local aRecRHM		:= {}
	Local lAllTransf
	Local lTransf
	Local lFound
	Local cCodPlano
	Local nI
	Local nRecno
	Local cPerEncerr	:= ""	// Periodo de Encerramento Padrao para Planos de Saude
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
	Local lOfusca		:= Len(aFldRel) > 0

	Default oSelf := Nil

	// Leitura dos parametros
	cFilDe 		:= mv_par01
	cFilAte		:= mv_par02
	cMatrDe		:= mv_par03
	cMatrAte	:= mv_par04
	cCCDe		:= mv_par05
	cCCAte		:= mv_par06
	cCatQuery	:= mv_par07
	cSitQuery	:= mv_par08
	cTpForn		:= StrZero(mv_par09,1)
	cCodForDe	:= mv_par10
	cCodForPara	:= mv_par11
	cFxSalDe	:= mv_par12
	cFxSalPara	:= mv_par13
	cFxEtaDe	:= mv_par14
	cFxEtaPara	:= mv_par15
	cVlFxDe		:= mv_par16
	cVlFxPara	:= mv_par17
	cPerSalDe	:= mv_par18
	cPerSalPara	:= mv_par19
	cSalEtaDe	:= mv_par20
	cSalEtaPara	:= mv_par21
	cPerIni		:= mv_par22
	cPerFim		:= mv_par23

	// O Per. Encerramento Padrao sera igual ao novo Per. Inicial (cPerIni) menos
	// 1 Mes e sera utilizado na gravacao do Hist. Alteracao do plano de saude.
	If Substr( cPerIni, 1, 2 ) == '01'
		cPerEncerr := '12' + AllTrim(Str(Val(Substr(cPerIni,3,4))-1))
	Else
		cPerEncerr := StrZero(Val(Substr(cPerIni,1,2))-1,2) + Substr(cPerIni,3,4)
	EndIf

	// Filtrar os funcionarios que serao processados //
	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( cFilDe + cMatrDe , .T. )

	cAliasSRA 	:= "QSRA"
	If ( Select( cAliasSRA ) > 0 )
		( cAliasSRA )->( dbCloseArea() )
	EndIf

	cCposQuery 	:= "%SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME%"
	cCatQuery 	:= Upper("%" + fSqlIN( cCatQuery, 1 ) + "%")
	cSitQuery	:= Upper("%" + fSqlIN( cSitQuery, 1 ) + "%")

	BeginSql alias cAliasSRA
		SELECT %exp:cCposQuery%
		FROM %table:SRA% SRA
		WHERE  SRA.RA_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAte%
			   AND SRA.RA_MAT BETWEEN %exp:cMatrDe% AND %exp:cMatrAte%
			   AND SRA.RA_CC BETWEEN %exp:cCCDe% AND %exp:cCCAte%
			   AND SRA.RA_CATFUNC IN (%exp:cCatQuery%)
			   AND SRA.RA_SITFOLH IN (%exp:cSitQuery%)
			   AND SRA.%notDel%
	EndSql


	If !IsBlind()
		oSelf:SetRegua1(SRA->(RecCount()))
		oSelf:SaveLog( STR0037 + " - " + STR0039) //"Transferencia em Lote de Planos de Saude"##"Inicio do processamento"
	EndIf

	If SRA->( Eof()	 )
		Aadd(aTitle, OemToAnsi(STR0040))  //"Nenhum funcionАrio a processar!"
		Aadd( aLog,{} )
	Else
		Aadd(aTitle, OemToAnsi(STR0041))  //"InconsistЙncia na TransferЙncia dos Planos de SaЗde!"
		Aadd(aLog,{} )
		Aadd(aTitle, OemToAnsi(STR0071))  //"Aviso - registro(s) que nЦo foi(foram) transferido(s)"
		Aadd(aLog,{} )
	EndIf

	// Processar a transferencia dos planos de saude //
	While (cAliasSRA)->( !Eof() )

		If !IsBlind()
			If oSelf:lEnd
				Break
			EndIf
		EndIf

		If Eof() .Or. ( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT > cFilAte + cMatrAte )
			Exit
		Endif

		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Posiciona na tabela SRA - Fisica                    	 	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		DbSelectArea( "SRA" )
		DbSetOrder( RetOrder( "SRA", "RA_FILIAL+RA_MAT" ))
		DbSeek( (cAliasSRA)->(RA_FILIAL+RA_MAT),.F.)

		/*
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁConsiste Filiais e Acessos                                             Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		IF !( (cAliasSRA)->RA_FILIAL $ fValidFil() )
			dbSelectArea(cAliasSRA)
			dbSkip()
			Loop
		EndIF

		If !IsBlind()
			oSelf:IncRegua1(OemToAnsi(STR0042) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + If(lOfusca, "", " - " + SRA->RA_NOME) )//"Transferindo o Plano de Saude de:"
		EndIf

		aRecRHK		:= {}
		aRecRHL		:= {}
		aRecRHM		:= {}
		lAllTransf  := .T.

		DbSelectArea( "RHK" )
		DbSetOrder( RetOrder( "RHK", "RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR" ) )
		DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForDe, .F. )
		While !Eof() .and. RHK->( RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR ) == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForDe

		    lFound 	:= .F.
		    lTransf := .F.
		    If RHK->RHK_TPCALC == '2' //so transfere se tipo de calculo for diferente de automatico
				DbSelectArea( "RHK" )
		 		DbSkip()
		 		Loop
			EndIf
			If RHK->RHK_TPPLAN == "1" //Faixa Salarial
				If RHK->RHK_PLANO == cFxSalDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHK->RHK_TPPLAN, cFxSalPara, .F.)
				EndIf
				cCodPlano := cFxSalPara
			ElseIf RHK->RHK_TPPLAN == "2" // Faixa Etaria
				If RHK->RHK_PLANO == cFxEtaDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHK->RHK_TPPLAN, cFxEtaPara, .F.)
				EndIf
				cCodPlano := cFxEtaPara
			ElseIf RHK->RHK_TPPLAN == "3" // Valor Fixo
				If RHK->RHK_PLANO == cVlFxDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHK->RHK_TPPLAN, cVlFxPara, .F.)
				EndIf
				cCodPlano := cVlFxPara
			ElseIf RHK->RHK_TPPLAN == "4" // % Sobre Salario
				If RHK->RHK_PLANO == cPerSalDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHK->RHK_TPPLAN, cPerSalPara, .F.)
				EndIf
				cCodPlano := cPerSalPara
			ElseIf RHK->RHK_TPPLAN == "5" // % Sobre Salario
				If RHK->RHK_PLANO == cSalEtaDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHK->RHK_TPPLAN, cSalEtaPara, .F.)
				EndIf
				cCodPlano := cSalEtaPara
			EndIf

            nRecno := RHK->(Recno())
			If lFound .and. lTransf
			   aAdd( aRecRHK, { nRecno, cCodPlano } )
			EndIf

			If !Empty(cCodPlano) .and. lTransf .and. !lFound
				lAllTransf  := .F.

				aAdd( aLog[1], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[1], Space(6) + OemToAnsi(STR0046) + " - " + OemToAnsi(STR0032) + " " + ;										//"Titular" ##"Plano nЦo cadastrado: "
								OemToAnsi(STR0033) + " " + cCodForPara + " / " + ; 							//"Fornecedor: "
								OemToAnsi(STR0034) + " " + RHK->RHK_TPPLAN + " / " +; 	// "Tipo Plano: "
								OemToAnsi(STR0035) + " " + cCodPlano ) 										// "Codigo do Plano: "
			ElseIf !Empty(cCodPlano) .and. !lTransf
				aAdd( aLog[2], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[2], Space(6) + OemToAnsi(STR0046) + " - " + ;										//"Titular"
								OemToAnsi(STR0033) + " " + RHK->RHK_CODFOR + " / " + ; 							//"Fornecedor: "
								OemToAnsi(STR0034) + " " + RHK->RHK_TPPLAN + " / " +; 	// "Tipo Plano: "
								OemToAnsi(STR0035) + " " + RHK->RHK_PLANO )
			EndIf

			// Tratamento para Chave Duplicada //
			DbSelectArea( "RHK" )
			DbSetOrder( RetOrder( "RHK", "RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR" ) )
			DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForPara, .F. )
			While !Eof() .and. RHK->( RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR ) == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForPara
				If RHK->RHK_PLANO == cCodPlano
					lAllTransf  := .F.

					aAdd( aLog[1], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
					aAdd( aLog[1], Space(6) + OemToAnsi(STR0046) + " - " + OemToAnsi(STR0049) + " " + ;										//"Titular" ##"Chave Duplicada: "
									OemToAnsi(STR0033) + " " + cCodForPara + " / " + ; 							//"Fornecedor: "
									OemToAnsi(STR0034) + " " + RHK->RHK_TPPLAN + " / " +; 						// "Tipo Plano: "
									OemToAnsi(STR0035) + " " + cCodPlano ) 										// "Codigo do Plano: "
				EndIf

				RHK->( DbSkip() )

			EndDo
			DbGoTo( nRecno )
		 	DbSelectArea( "RHK" )
		 	DbSkip()
		EndDo

		DbSelectArea( "RHL" )
		DbSetOrder( RetOrder( "RHL", "RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR+RHL_CODIGO") )
		DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForDe, .F. )
		While !Eof() .and. RHL->( RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR ) == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForDe

		    lFound 	:= .F.
		    lTransf := .F.
		    If RHL->RHL_TPCALC == '2' //so transfere se tipo de calculo for diferente de automatico
				DbSelectArea( "RHL" )
		 		DbSkip()
		 		Loop
			EndIf
			If RHL->RHL_TPPLAN == "1" //Faixa Salarial
				If RHL->RHL_PLANO == cFxSalDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHL->RHL_TPPLAN, cFxSalPara, .F.)
				EndIf
				cCodPlano := cFxSalPara
			ElseIf RHL->RHL_TPPLAN == "2" // Faixa Etaria
				If RHL->RHL_PLANO == cFxEtaDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHL->RHL_TPPLAN, cFxEtaPara, .F.)
				EndIf
				cCodPlano := cFxEtaPara
			ElseIf RHL->RHL_TPPLAN == "3" // Valor Fixo
				If RHL->RHL_PLANO == cVlFxDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHL->RHL_TPPLAN, cVlFxPara, .F.)
				EndIf
				cCodPlano := cVlFxPara
			ElseIf RHL->RHL_TPPLAN == "4" // % Sobre Salario
				If RHL->RHL_PLANO == cPerSalDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHL->RHL_TPPLAN, cPerSalPara, .F.)
				EndIf
				cCodPlano := cPerSalPara
			ElseIf RHL->RHL_TPPLAN == "5" // Salarial/Etaria
				If RHL->RHL_PLANO == cSalEtaDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHL->RHL_TPPLAN, cSalEtaPara, .F.)
			EndIf
				cCodPlano := cSalEtaPara
			EndIf

            	nRecno := RHL->( Recno() )
			If lFound .and. lTransf
		   		aAdd( aRecRHL, { nRecno, cCodPlano } )
			EndIf

			If lTransf .and. !lFound
				lAllTransf  := .F.

				aAdd( aLog[1], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[1], Space(6) + OemToAnsi(STR0047) + " - " + OemToAnsi(STR0032) + " " + ;										//"Dependente" ## "Plano nЦo cadastrado: "
							OemToAnsi(STR0033) + " " + cCodForPara + " / " + ; 							//"Fornecedor: "
							OemToAnsi(STR0034) + " " + RHL->RHL_TPPLAN + " / " +; 						// "Tipo Plano: "
							OemToAnsi(STR0035) + " " + cCodPlano ) 										// "Codigo do Plano: "
			ElseIf !Empty(cCodPlano) .and. !lTransf
				aAdd( aLog[2], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[2], Space(6) + OemToAnsi(STR0047) + " - " +;										//"Dependente"
								OemToAnsi(STR0033) + " " + RHL->RHL_CODFOR + " / " + ; 							//"Fornecedor: "
								OemToAnsi(STR0034) + " " + RHL->RHL_TPPLAN + " / " +; 	// "Tipo Plano: "
								OemToAnsi(STR0035) + " " + RHL->RHL_PLANO )
			EndIf

			// Tratamento para Chave Duplicada //
			DbSelectArea( "RHL" )
			DbSetOrder( RetOrder( "RHL", "RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR+RHL_CODIGO") )
			DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForPara + cCodPlano, .F. )
			If RHL->( !Eof() )
				lAllTransf  := .F.

				aAdd( aLog[1], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[1], Space(6) + OemToAnsi(STR0047) + " - " + OemToAnsi(STR0049) + " " + ;										//"Dependente" ## "Chave Duplicada: "
							OemToAnsi(STR0033) + " " + cCodForPara + " / " + ; 							//"Fornecedor: "
							OemToAnsi(STR0034) + " " + RHL->RHL_TPPLAN + " / " +; 						// "Tipo Plano: "
							OemToAnsi(STR0035) + " " + cCodPlano ) 										// "Codigo do Plano: "
			EndIf

			DbGoTo( nRecno )
		 	DbSelectArea( "RHL" )
		 	DbSkip()
		EndDo

		DbSelectArea( "RHM" )
		DbSetOrder( RetOrder( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO") )
		DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForDe, .F. )
		While !Eof() .and. RHM->( RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR ) == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForDe

		    lFound 	:= .F.
		    lTransf := .F.
		    If RHM->RHM_TPCALC == '2' //so transfere se tipo de calculo for diferente de automatico
				DbSelectArea( "RHM" )
		 		DbSkip()
		 		Loop
			EndIf
			If RHM->RHM_TPPLAN == "1" //Faixa Salarial
				If RHM->RHM_PLANO == cFxSalDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHM->RHM_TPPLAN, cFxSalPara, .F.)
				EndIf
				cCodPlano := cFxSalPara
			ElseIf RHM->RHM_TPPLAN == "2" // Faixa Etaria
				If RHM->RHM_PLANO == cFxEtaDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHM->RHM_TPPLAN, cFxEtaPara, .F.)
				EndIf
				cCodPlano := cFxEtaPara
			ElseIf RHM->RHM_TPPLAN == "3" // Valor Fixo
				If RHM->RHM_PLANO == cVlFxDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHM->RHM_TPPLAN, cVlFxPara, .F.)
				EndIf
				cCodPlano := cVlFxPara
			ElseIf RHM->RHM_TPPLAN == "4" // % Sobre Salario
				If RHM->RHM_PLANO == cPerSalDe
					lTransf := .T.
					lFound := fValidPlano(cTpForn, cCodForPara, RHM->RHM_TPPLAN, cPerSalPara, .F.)
				EndIf
				cCodPlano := cPerSalPara
			EndIf

         	nRecno := RHM->( Recno() )
			If lFound .and. lTransf
		   		aAdd( aRecRHM, { nRecno, cCodPlano } )
			EndIf

			If lTransf .and. !lFound
				lAllTransf  := .F.

				aAdd( aLog[1], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[1], Space(6) + OemToAnsi(STR0048) + " - " + OemToAnsi(STR0032) + " " + ;										//"Agregado" ## "Plano nЦo cadastrado: "
							OemToAnsi(STR0033) + " " + cCodForPara + " / " + ; 							//"Fornecedor: "
							OemToAnsi(STR0034) + " " + RHM->RHM_TPPLAN + " / " +; 						// "Tipo Plano: "
							OemToAnsi(STR0035) + " " + cCodPlano ) 										// "Codigo do Plano: "
			ElseIf !Empty(cCodPlano) .and. !lTransf
				aAdd( aLog[2], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[2], Space(6) + OemToAnsi(STR0048) + " - " + ;										//"Agregado"
								OemToAnsi(STR0033) + " " + RHM->RHM_CODFOR + " / " + ; 							//"Fornecedor: "
								OemToAnsi(STR0034) + " " + RHM->RHM_TPPLAN + " / " +; 	// "Tipo Plano: "
								OemToAnsi(STR0035) + " " + RHM->RHM_PLANO )
			EndIf

			// Tratamento para Chave Duplicada //
			DbSelectArea( "RHM" )
			DbSetOrder( RetOrder( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO") )
			DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cTpForn + cCodForPara + cCodPlano, .F. )
			If RHM->( !Eof() )
				lAllTransf  := .F.

				aAdd( aLog[1], OemToAnsi(STR0031) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), SRA->RA_NOME ) )//"Funcionario: "
				aAdd( aLog[1], Space(6) + OemToAnsi(STR0048) + " - " + OemToAnsi(STR0049) + " " + ;										//"Dependente" ## "Chave Duplicada: "
							OemToAnsi(STR0033) + " " + cCodForPara + " / " + ; 							//"Fornecedor: "
							OemToAnsi(STR0034) + " " + RHL->RHL_TPPLAN + " / " +; 						// "Tipo Plano: "
							OemToAnsi(STR0035) + " " + cCodPlano ) 										// "Codigo do Plano: "
			EndIf

			DbGoTo( nRecno )
		 	DbSelectArea( "RHM" )
		 	DbSkip()
		EndDo

		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Transferencia realizada com Sucesso - Realizar a Gravacao				 Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If lAllTransf
        	Begin Transaction
        		For nI := 1 To Len( aRecRHK )
        			RHK->( DbGoTo( aRecRHK[nI, 1] ) )

        			RecLock( "RHN", .T. )
        			RHN->RHN_FILIAL 	:= (cAliasSRA)->RA_FILIAL
					RHN->RHN_MAT		:= (cAliasSRA)->RA_MAT
					RHN->RHN_DATA		:= dDataBase
					RHN->RHN_OPERAC		:= "1"
					RHN->RHN_ORIGEM		:= "1"
					RHN->RHN_TPALT		:= "01"
					RHN->RHN_TPFORN		:= cTpForn
					RHN->RHN_CODFOR		:= cCodForDe
					RHN->RHN_NOME		:= (cAliasSRA)->RA_NOME
					RHN->RHN_TPPLAN		:= RHK->RHK_TPPLAN
					RHN->RHN_PLANO		:= RHK->RHK_PLANO
					RHN->RHN_PD			:= RHK->RHK_PD
					RHN->RHN_PDDAGR		:= RHK->RHK_PDDAGR
					RHN->RHN_PERINI		:= RHK->RHK_PERINI
					RHN->RHN_PERFIM		:= cPerEncerr
					RHN->( MsUnlock() )

					RecLock( "RHK", .F. )
					RHK->RHK_CODFOR		:= cCodForPara
					RHK->RHK_PLANO		:= aRecRHK[nI, 2]
					RHK->RHK_PERINI		:= cPerIni
					RHK->RHK_PERFIM		:= cPerFim
        			RHK->( MsUnlock() )

        		Next nI

        		For nI := 1 To Len( aRecRHL )
        			RHL->( DbGoTo( aRecRHL[nI, 1] ) )

        			RecLock( "RHN", .T. )
        			RHN->RHN_FILIAL 	:= (cAliasSRA)->RA_FILIAL
					RHN->RHN_MAT		:= (cAliasSRA)->RA_MAT
					RHN->RHN_DATA		:= dDataBase
					RHN->RHN_OPERAC		:= "1"
					RHN->RHN_ORIGEM		:= "2"
					RHN->RHN_TPALT		:= "01"
					RHN->RHN_TPFORN		:= cTpForn
					RHN->RHN_CODFOR		:= cCodForDe
					RHN->RHN_NOME		:= Posicione("SRB",1,xFilial("SRB")+RHL->RHL_MAT+RHL->RHL_CODIGO, "RB_NOME")
					RHN->RHN_TPPLAN		:= RHL->RHL_TPPLAN
					RHN->RHN_PLANO		:= RHL->RHL_PLANO
					RHN->RHN_CODIGO		:= RHL->RHL_CODIGO
					RHN->RHN_PD			:= RHK->RHK_PD
					RHN->RHN_PDDAGR		:= RHK->RHK_PDDAGR
					RHN->RHN_PERINI		:= RHL->RHL_PERINI
					RHN->RHN_PERFIM		:= cPerEncerr
					RHN->( MsUnlock() )

					RecLock( "RHL", .F. )
					RHL->RHL_CODFOR		:= cCodForPara
					RHL->RHL_PLANO		:= aRecRHL[nI, 2]
					RHL->RHL_PERINI		:= cPerIni
					RHL->RHL_PERFIM		:= cPerFim
        			RHL->( MsUnlock() )

        		Next nI

        		For nI := 1 To Len( aRecRHM )
        			RHM->( DbGoTo( aRecRHM[nI, 1] ) )

        			RecLock( "RHN", .T. )
        			RHN->RHN_FILIAL 	:= (cAliasSRA)->RA_FILIAL
					RHN->RHN_MAT		:= (cAliasSRA)->RA_MAT
					RHN->RHN_DATA		:= dDataBase
					RHN->RHN_OPERAC		:= "1"
					RHN->RHN_ORIGEM		:= "3"
					RHN->RHN_TPALT		:= "01"
					RHN->RHN_TPFORN		:= cTpForn
					RHN->RHN_CODFOR		:= cCodForDe
					RHN->RHN_TPPLAN		:= RHM->RHM_TPPLAN
					RHN->RHN_PLANO		:= RHM->RHM_PLANO
					RHN->RHN_PD			:= RHK->RHK_PD
					RHN->RHN_PDDAGR		:= RHK->RHK_PDDAGR
					RHN->RHN_CODIGO		:= RHM->RHM_CODIGO
					RHN->RHN_NOME		:= RHM->RHM_NOME
					RHN->RHN_PERINI		:= RHM->RHM_PERINI
					RHN->RHN_PERFIM		:= cPerEncerr
					RHN->( MsUnlock() )

					RecLock( "RHM", .F. )
					RHM->RHM_CODFOR		:= cCodForPara
					RHM->RHM_PLANO		:= aRecRHM[nI, 2]
					RHM->RHM_PERINI		:= cPerIni
					RHM->RHM_PERFIM		:= cPerFim
        			RHM->( MsUnlock() )

        		Next nI

        	End Transaction
		EndIf

		DbSelectArea( cAliasSRA )
		DbSkip()

	EndDo

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fValFor		ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidar Fornecedor 			                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fValFor(nItem)
	Local cCodTab

	Local nPosTab

	Local lRet

	If MV_PAR09 == 1
		cCodTab := "S016"
	Else
		cCodTab := "S017"
	EndIf

	nPosTab := fPosTab( cCodTab, If(nItem==1, MV_PAR10, MV_PAR11),"=",4)

	If nPosTab <= 0
		Help(,,'HELP',,OemToAnsi(STR0045),1,0)	//"Fornecedor nЦo cadastrado!"
		lRet := .F.
	EndIf

	If lRet
		If MV_PAR10 == MV_PAR11
			Help(,,'HELP',,OemToAnsi(STR0043),1,0)	//"Codigo de Fornecedor De/Para devem ser diferentes!"
			lRet := .F.
		EndIf
	EndIf

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fValPlano		ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidar Planos     			                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fValPlano(nItem, nTipo)
	Local lRet := .T.
	Local cTpForn
	Local cCodForn
	Local cTpPlan
	Local cPlano

	cTpForn := StrZero(MV_PAR09,1)

	If nTipo == 1
		cCodForn := MV_PAR10
	Else
		cCodForn := MV_PAR11
	EndIf

	If nItem == 1
		cTpPlan := "1"
		If nTipo == 1
			cPlano := MV_PAR12
		Else
			cPlano := MV_PAR13
		EndIf
	ElseIf nItem == 2
		cTpPlan := "2"
		If nTipo == 1
			cPlano := MV_PAR14
		Else
			cPlano := MV_PAR15
		EndIf
	ElseIf nItem == 3
		cTpPlan := "3"
		If nTipo == 1
			cPlano := MV_PAR16
		Else
			cPlano := MV_PAR17
		EndIf
	ElseIf nItem == 4
		cTpPlan := "4"
		If nTipo == 1
			cPlano := MV_PAR18
		Else
			cPlano := MV_PAR19
		EndIf
	ElseIf nItem == 5
		cTpPlan := "5"
		If nTipo == 1
			cPlano := MV_PAR20
		Else
			cPlano := MV_PAR21
		EndIf
	EndIf

	lRet := fValidPlano(cTpForn, cCodForn, cTpPlan, cPlano)

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GP001_MEDODO	ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDirecionar para o Grupo de Perguntas                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GP001_MEDODO()
	Local xRet
	Local cCons := ""
	Local cCpoRet

	If MV_PAR09 == 1
		cCons := "S016"
	Else
		cCons := "S017"
	EndIf

 	cCpoRet := "CODIGO"
	xRet := Gp310SXB(cCons, cCpoRet )

	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	Endif

	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf

Return( xRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GP001_FXSAL	ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDirecionar para o Grupo de Perguntas                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GP001_FXSAL()
	Local xRet
	Local cCons := ""
	Local cCpoRet

	If MV_PAR09 == 1
		cCons := "S008"
	Else
		cCons := "S013"
	EndIf

 	cCpoRet := "CODIGO"
	xRet := Gp310SXB(cCons, cCpoRet )

	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	Endif

	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf

Return( xRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GP001_FXETA	ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDirecionar para o Grupo de Perguntas                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GP001_FXETA()
	Local xRet
	Local cCons := ""
	Local cCpoRet

	If MV_PAR09 == 1
		cCons := "S009"
	Else
		cCons := "S014"
	EndIf

 	cCpoRet := "CODIGO"
	xRet := Gp310SXB(cCons, cCpoRet )

	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	Endif

	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf

Return( xRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GP001_VLRFX	ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDirecionar para o Grupo de Perguntas                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GP001_VLRFX()
	Local xRet
	Local cCons := ""
	Local cCpoRet

	If MV_PAR09 == 1
		cCons := "S028"
	Else
		cCons := "S030"
	EndIf

 	cCpoRet := "CODIGO"
	xRet := Gp310SXB(cCons, cCpoRet )

	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	Endif

	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf

Return( xRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GP001_PESAL	ЁAutorЁ  Mauricio TakakuraЁ Data Ё06/12/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDirecionar para o Grupo de Perguntas                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GP001_PESAL()
	Local xRet
	Local cCons := ""
	Local cCpoRet

	If MV_PAR09 == 1
		cCons := "S029"
	Else
		cCons := "S031"
	EndIf

 	cCpoRet := "CODIGO"
	xRet := Gp310SXB(cCons, cCpoRet )

	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	Endif

	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf

Return( xRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GP001_SALETA	ЁAutorЁ  Allyson Mesashi  Ё Data Ё02/07/2014Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDirecionar para o Grupo de Perguntas                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GP001_SALETA()
	Local xRet
	Local cCons := ""
	Local cCpoRet

	If MV_PAR09 == 1
		cCons := "S059"
	Else
		cCons := "S060"
	EndIf

 	cCpoRet := "CODIGO"
	xRet := Gp310SXB(cCons, cCpoRet )

	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	Endif

	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf

Return( xRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fManutCalc		ЁAutorЁ TOTVS			  Ё Data Ё18/05/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o Ё Manutencao do Calculo do Plano                             Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      Ё GPEA001                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё aRotina													Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fManutCalc()

Local cPerg			:= "GPA001"
Private cCompFil 	:= ""

If Pergunte( cPerg, .T. )

	cCompFil := Substr( MV_PAR01, 3, 4 ) + Substr( MV_PAR01, 1, 2 )
	
	fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, IIf(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()) )	

	If Empty(aPerAtual)
		Help( ,, 'HELP',, OemToAnsi( STR0109 + SRA->RA_PROCES ), 1, 0 )	// "NЦo hА um perМodo aberto para o funcionАrio selecionado. Por favor verifique no cadastro de perМodos o processo "
	Else
		FWExecView( OemToAnsi( STR0051 ), "GPEM008", MODEL_OPERATION_UPDATE )	// "Manut. CАlculo"
	EndIf

EndIf

Return


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGp001ChkDl   	ЁAutorЁClaudinei Soares   Ё Data Ё15/03/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVerificar se um registro pode ser excuido                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >		 						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA001		                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >       					     	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gp001ChkDl()

Local aArea		:= GetArea()
Local aAreas	:= Array( 04 , 03 )
Local aLog		:= {}
Local aLogTitle := {}
Local cFilRHK	:= xFilial( "RHK" )
Local cChave	:= ""
Local cChaveAux := ""
Local cArqInd	:= ""
Local cCondDel	:= ""
Local cVerba	:= FwFldGet('RHK_PD')
Local cMat		:= FwFldGet('RHK_MAT')
Local cUseAlias	:= ""
Local cMsg		:= ""
Local lDelOk	:= .T.
Local lRet		:= .T.
Local nArea		:= 0.00
Local nAreas	:= 0.00
Local lResult	:= .F.

Private cFilAux	:= ""
Private lGpea040AUT := .F.

aAreas[01,1] := SRC->( GetArea() )
If Empty( cFilRHK )
	aAreas[01,2] := 'RC_PD == "'+cVerba+'"+ RC_MAT == "'+cMat+'"'
	aAreas[01,3] := "RC_PD+RC_MAT"
Else
	aAreas[01,2] := 'RC_FILIAL == cFilAux .and. RC_PD == "'+cVerba+'" .and. RC_MAT == "'+cMat+'"'
	aAreas[01,3] := "RC_FILIAL + RC_PD + RC_MAT"
EndIf

aAreas[02,1] := SRD->( GetArea() )
If Empty( cFilRHK )
	aAreas[02,2] := 'RD_PD == "'+cVerba+'"+ RD_MAT == "'+cMat+'"'
	aAreas[02,3] := "RD_PD+RD_MAT"
Else
	aAreas[02,2] := 'RD_FILIAL == cFilAux .and. RD_PD == "'+cVerba+'" .and. RD_MAT == "'+cMat+'"'
	aAreas[02,3] := "RD_FILIAL + RD_PD + RD_MAT"
EndIf

aAreas[03,1] := RHR->( GetArea() )
If Empty( cFilRHK )
	aAreas[03,2] := 'RHR_PD == "'+cVerba+'"+ RHR_MAT == "'+cMat+'"'
	aAreas[03,3] := "RHR_PD+RHR_MAT"
Else
	aAreas[03,2] := 'RHR_FILIAL == cFilAux .and. RHR_PD == "'+cVerba+'" .and. RHR_MAT == "'+cMat+'"'
	aAreas[03,3] := "RHR_FILIAL + RHR_PD + RHR_MAT"
EndIf

aAreas[04,1] := RHS->( GetArea() )
If Empty( cFilRHK )
	aAreas[04,2] := 'RHS_PD == "'+cVerba+'"+ RHS_MAT == "'+cMat+'"'
	aAreas[04,3] := "RHS_PD+RHS_MAT"
Else
	aAreas[04,2] := 'RHS_FILIAL == cFilAux .and. RHS_PD == "'+cVerba+'" .and. RHS_MAT == "'+cMat+'"'
	aAreas[04,3] := "RHS_FILIAL + RHS_PD + RHS_MAT"
EndIf

If lRet

	Begin Sequence

		nAreas := Len( aAreas )
		For nArea := 1 To nAreas
			cFilAux		:= xFilial( aAreas[ nArea , 1 , 1 ] )
			cFilAux		:= IF( !Empty( cFilAux ) , cFilAux , IF( Empty( cFilAux ) , cFilAux , cFilRHK ) )
			cCondDel	:= aAreas[ nArea , 2 ]
			cArqInd 	:= CriaTrab( "" , .F. )
			cChave		:= aAreas[ nArea , 3 ]
			cChaveAux   := If( Empty(cFilRHK), cVerba+cMat, cFilAux + cVerba + cMat )
			IndRegua( aAreas[ nArea , 1 , 1 ] , cArqInd , cChave , NIL , cCondDel , STR0063 ) //"Criando Indice no Servidor..."
			IF !( lDelOk := !( aAreas[ nArea , 1 , 1 ] )->( dbSeek( cChaveAux , .F. ) ) )
				IF Empty( aLog )
					aAdd( aLog , STR0060  + STR0062 ) //"O Plano deste funcionАrio nao pode ser excluido, Esta sendo utilizada pelos arquivos abaixo"
					aAdd( aLog , "" )
					aAdd( aLog , "" )
				EndIF
				While ( aAreas[ nArea , 1 , 1 ] )->( !Eof() .and. &( cChave ) == cChaveAux )
					aAdd( aLog , aAreas[ nArea , 1 , 1 ] + Space( 05 ) + ( aAreas[ nArea , 1 , 1 ] )->( StrZero( Recno() , 10 )))
					( aAreas[ nArea , 1 , 1 ] )->( dbSkip() )
				End While
			EndIF
			cArqInd := ( cArqInd + OrdBagExt() )
			IF File( cArqInd )
				fErase( cArqInd )
			EndIF
			RetIndex( aAreas[ nArea , 1 , 1 ] )
			RestArea( aAreas[ nArea , 1 ] )
		Next nAreas

	End Sequence

	IF !Empty( aLog )
		/*
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Gera e Mostra o Log 										  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				10        20       30        40        50        60        70        80        90       100       110...
		1234567890123456789023456789012345678901234567890123456789012345678901234567890123456789012345678901234567890...
		Arquivo Registro   Conteudo
		XXX     9999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
		aAdd( aLogTitle , STR0058 )	//"Arquivo Registro"
		MsAguarde( { || fMakeLog( { aLog } , aLogTitle , NIL , NIL , FunName() , STR0059 ) } , STR0059 ) //"Log de Ocorrencias na Exclusao de Plano de Saude Ativo"
        Help( ,, STR0064,, OemToAnsi( STR0064 ), 1, 0 )
	Else
		/*
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Executa a Delecao   										  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		lResult:= .T.
	EndIf

EndIf

RestArea( aArea )

Return( lResult )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRHK_VlDel   	ЁAutorЁEquipe RH          Ё Data Ё06/06/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVerificar se um titular pode ser excuido                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >		 						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA001		                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >       					     	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHK_VlDel( oModelGrid, nLinha, cAcao, cCampo )
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel()

// Se o dependente possuir calculo nao pode deletar
If cAcao == 'DELETE' .And. Gp001Calc(1, oModel, nLinha, cCampo) == .T.
	lRet := .F.
	Help( ,, STR0028,, OemToAnsi( STR0068 ), 1, 0 )	//"Atencao" ## "HА valores calculados para o titular e por isso nЦo И permitido excluм-lo do plano ativo. Aconselhamos o preenchimento do campo (Per. Final) nos planos activos ao invИs da eliminaГЦo do plano."
EndIf
Return lRet
/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRHL_VlDel   	ЁAutorЁEquipe RH          Ё Data Ё06/06/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVerificar se um dependente pode ser excuido                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >		 						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA001		                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >       					     	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHL_VlDel( oModelGrid, nLinha, cAcao, cCampo )
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel()

// Se o dependente possuir calculo nao pode deletar
If cAcao == 'DELETE' .And. Gp001Calc(2, oModel, nLinha, cCampo) == .T.
	lRet := .F.
	Help( ,, STR0028,, OemToAnsi( STR0066 ), 1, 0 )	//"Atencao" ## "HА valores calculados para o dependente e por isso nЦo И permitido excluм-lo do plano ativo. Aconselhamos o preenchimento do campo (Per. Final) nos planos activos ao invИs da eliminaГЦo do plano."
EndIf
Return lRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRHM_VlDel   	ЁAutorЁEquipe RH          Ё Data Ё06/06/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVerificar se um agregado pode ser excuido                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >		 						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA001		                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >       					     	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHM_VlDel( oModelGrid, nLinha, cAcao, cCampo )
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel()

// Se o dependente possuir calculo nao pode deletar
If cAcao == 'DELETE' .And. Gp001Calc(3, oModel, nLinha, cCampo) == .T.
	lRet := .F.
	Help( ,, STR0028,, OemToAnsi( STR0067 ), 1, 0 )	//"Atencao" ## "HА valores calculados para o agregado e por isso nЦo И permitido excluм-lo do plano ativo. aconselhamos o preenchimento do campo (Per. Final) nos planos activos ao invИs da eliminaГЦo do plano."
EndIf
Return lRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGp001Calc   	ЁAutorЁEquipe RH          Ё Data Ё06/06/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVerificar se existe calculo efetuado                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >		 						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA001		                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >       					     	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gp001Calc( nTipo, oModelGrid, nLinha, cCampo)
Local lRet       := .F.
Local cPesqFil   := ""
Local cPesqMat   := ""
Local cPesqOri   := ""
Local cPesqCod   := ""
Local cPesqTpF 	 := ""
Local cPesqCodF	 := ""
Local cPesqTpP	 := ""
Local cPesqCodP	 := ""
Local cPesqDe    := ""
Local cPesqAte   := ""
Local cCposQuery := ""
Local cAliasRHR  := "RHR"
Local aArea		 := RHR->(GetArea())

Local oModel
Local oStructRHK
Local oStructRHL
Local oStructRHM

oModel 		:= FWModelActive()
oStructRHK	:= oModel:GetModel( "GPEA001_MRHK" )
oStructRHL	:= oModel:GetModel( "GPEA001_MRHL" )
oStructRHM	:= oModel:GetModel( "GPEA001_MRHM" )

cPesqFil  := SRA->RA_FILIAL
cPesqMat  := SRA->RA_MAT
cPesqTpF  := oStructRHK:GetValue( "RHK_TPFORN" )
cPesqCodF := oStructRHK:GetValue( "RHK_CODFOR" )

If nTipo == 1 //titular
    cPesqOri   := "1"
    cPesqCod   := "  "
	cPesqTpP   := oStructRHK:GetValue( "RHK_TPPLAN" )
	cPesqCodP  := oStructRHK:GetValue( "RHK_PLANO"	 )
    cPesqDe    := oStructRHK:GetValue( "RHK_PERINI" )
    cPesqAte   := oStructRHK:GetValue( "RHK_PERFIM" )
ElseIf nTipo == 2 //dependente
    cPesqOri   := "2"
    cPesqCod   := oStructRHL:GetValue( "RHL_CODIGO" )
	cPesqTpP   := oStructRHL:GetValue( "RHL_TPPLAN" )
	cPesqCodP  := oStructRHL:GetValue( "RHL_PLANO"	 )
    cPesqDe    := oStructRHL:GetValue( "RHL_PERINI" )
    cPesqAte   := oStructRHL:GetValue( "RHL_PERFIM" )
Else //agregado
    cPesqOri   := "3"
    cPesqCod   := oStructRHM:GetValue( "RHM_CODIGO" )
	cPesqTpP   := oStructRHM:GetValue( "RHM_TPPLAN" )
	cPesqCodP  := oStructRHM:GetValue( "RHM_PLANO"	 )
    cPesqDe    := oStructRHM:GetValue( "RHM_PERINI" )
    cPesqAte   := oStructRHM:GetValue( "RHM_PERFIM" )
EndIf

cPesqDe := Substr(cPesqDe,3,4)+Substr(cPesqDe,1,2)

If Empty(cPesqAte)
    cPesqAte := '999999'
Else
    cPesqAte := Substr(cPesqAte,3,4)+Substr(cPesqAte,1,2)
EndIf

If ( Select( cAliasRHR ) > 0 )
	( cAliasRHR )->( dbCloseArea() )
EndIf

cCposQuery 	:= "%RHR.RHR_FILIAL, RHR.RHR_MAT, RHR_CODIGO, RHR_TPPLAN, RHR_TPFORN, RHR_CODFOR, RHR_PLANO, RHR_COMPPG%"

BeginSql alias cAliasRHR
	SELECT %exp:cCposQuery%
	FROM %table:RHR% RHR
	WHERE  RHR.RHR_FILIAL = %exp:cPesqFil%
		   AND RHR.RHR_ORIGEM = %exp:cPesqOri%
		   AND RHR.RHR_MAT = %exp:cPesqMat%
		   AND RHR.RHR_CODIGO = %exp:cPesqCod%
		   AND RHR.RHR_TPFORN = %exp:cPesqTpF%
		   AND RHR.RHR_CODFOR = %exp:cPesqCodF%
		   AND RHR.RHR_TPPLAN = %exp:cPesqTpP%
		   AND RHR.RHR_PLANO = %exp:cPesqCodP%
		   AND RHR.RHR_COMPPG BETWEEN %exp:cPesqDe% AND %exp:cPesqAte%
		   AND RHR.%notDel%
EndSql


If !(cAliasRHR)->( Eof()	 )
    lRet := .T.
EndIf

( cAliasRHR )->( dbCloseArea() )

RHR->(RestArea(aArea))

Return lRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGP001Fech   	ЁAutorЁLeandro Drumond    Ё Data Ё06/06/2014Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁFechamento do plano de saude.      o                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >		 						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA001		                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >       					     	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GP001Fech()

GPEM120() //Fechamento do plano de saude

Return Nil

/*/{Protheus.doc}fVldTpCalc
ValidaГЦo dos campos TPCALC(Tipo de cАlculo).
@author Gabriel de Souza Almeida
@since 09/04/2015
@version P12
@return LСgico, lRet
/*/
Function fVldTpCalc(cTab)

	Local lRet := .T.
	Local oModel := FwModelActive()
	Local oStructSRA := oModel:GetModel("GPEA001_MSRA")
	Local cRA_MAT := oStructSRA:GetValue("RA_MAT")

	Local oStructRHK := oModel:GetModel("GPEA001_MRHK")
	Local cM_TPCALCK := oStructRHK:GetValue("RHK_TPCALC")
	Local cM_TPFORN := oStructRHK:GetValue("RHK_TPFORN")
	Local cM_CODFOR := oStructRHK:GetValue("RHK_CODFOR")
	Local cM_TPPLAN := oStructRHK:GetValue("RHK_TPPLAN")
	Local cM_PLANO := oStructRHK:GetValue("RHK_PLANO")
	Local cM_PD := oStructRHK:GetValue("RHK_PD")
	Local cM_PDDAGR := oStructRHK:GetValue("RHK_PDDAGR")
	Local cM_PERINI := oStructRHK:GetValue("RHK_PERINI")
	Local cM_PERFIM := oStructRHK:GetValue("RHK_PERFIM")

	Local oStructRHL := oModel:GetModel("GPEA001_MRHL")
	Local cM_TPCALCL := oStructRHL:GetValue("RHL_TPCALC")
	Local cM_CODL := oStructRHL:GetValue("RHL_CODIGO")
	Local cM_PERINIL := oStructRHL:GetValue("RHL_PERINI")
	Local cM_PERFIML := oStructRHL:GetValue("RHL_PERFIM")

	Local oStructRHM := oModel:GetModel("GPEA001_MRHM")
	Local cM_TPCALCM := oStructRHM:GetValue("RHM_TPCALC")
	Local cM_NOMEM := oStructRHM:GetValue("RHM_NOME")
	Local cM_PERINIM := oStructRHM:GetValue("RHM_PERINI")
	Local cM_PERFIMM := oStructRHM:GetValue("RHM_PERFIM")

	Local nLinhas := 0
	Local nCountL := 0
	Local nCountM := 0
	Local nI := 0
	Local lMsg := .F.

	DbSelectArea("RHK")
	RHK->(DbSetOrder(1))
	(RHK->(MsSeek(xFilial("RHK")+cRA_MAT)))

	DbSelectArea("RHM")
	RHM->(DbSetOrder(1))
	(RHM->(MsSeek(xFilial("RHM")+cRA_MAT)))

	DbSelectArea("RHL")
	RHL->(DbSetOrder(1))
	(RHL->(MsSeek(xFilial("RHL")+cRA_MAT)))

	nLinhas := oStructRHL:GetQtdLine()

	For nI := 1 To nLinhas
		oStructRHL:GoLine(nI)
		If !oStructRHL:IsDeleted() .AND. !Empty(cM_CODL)
			nCountL++
		EndIf
	Next nI

	nLinhas := oStructRHM:GetQtdLine()

	For nI := 1 To nLinhas
		oStructRHM:GoLine(nI)
		If !oStructRHM:IsDeleted() .AND. !Empty(cM_NOMEM)
			nCountM++
		EndIf
	Next nI

	//O campo RHK_TPCALC nЦo pode ser alterado para "2-AutomАtico"
	If (RHK->RHK_TPCALC == "1" .OR. RHK->RHK_TPCALC == " ") .AND. cM_TPCALCK == "2" .AND. cTab == "RHK"
		lRet := .F.
		Help(" ", 1, "Help",, OemToAnsi(STR0072), 1, 0) //O tipo de cАlculo nЦo pode ser alterado para AutomАtico
	EndIf

	//Verifica se hА conteЗdo no campo RHK_CDPSAG
	If Empty(RHK->RHK_CDPSAG) .AND. lRet
		//Se nЦo houver conteЗdo, os campos RHM_TPCALC e RHL_TPCALC nЦo podem ser alterados para "2-AutomАtico"
		If (RHM->RHM_TPCALC == "1" .OR. RHM->RHM_TPCALC == " ") .AND. cM_TPCALCM == "2"
			lRet := .F.
			Help(" ", 1, "Help",, OemToAnsi(STR0072), 1, 0) //O tipo de cАlculo nЦo pode ser alterado para AutomАtico
		EndIf
		If (RHL->RHL_TPCALC == "1" .OR. RHL->RHL_TPCALC == " ") .AND. cM_TPCALCL == "2"
			lRet := .F.
			Help(" ", 1, "Help",, OemToAnsi(STR0072), 1, 0) //O tipo de cАlculo nЦo pode ser alterado para AutomАtico
		EndIf
	Else
		//Havendo conteЗdo no campo RHK_CDPSAG, os campos RHM_TPCALC e RHL_TPCALC podem ser alterados para automАtico apenas*
		//*se houver registro nas tabelas SL0 ou SLE
		DbSelectArea("SG0")
		SG0->(DbSetOrder(2))//G0_FILIAL+G0_STATUS+G0_CODIGO
		If cM_TPCALCM == "2" .AND. lRet
			DbSelectArea("SLE")
			SLE->(DbSetOrder(1))//LE_FILIAL+LE_CODIGO+LE_TPFORN+LE_CODFORN
			If !(SLE->(MsSeek(xFilial("SLE")+RHK->RHK_CDPSAG))) .OR. !(SG0->(MsSeek(xFilial("SG0")+"1"+RHK->RHK_CDPSAG)))
				lRet := .F.
				Help(" ", 1, "Help",, OemToAnsi(STR0077), 1, 0) //O tipo de cАlculo nЦo pode ser alterado para AutomАtico. Verifique a definiГЦo de plano de saЗde.
			EndIf
		EndIf
		If cM_TPCALCL == "2"
			DbSelectArea("SL0")
			SL0->(DbSetOrder(1))//L0_FILIAL+L0_CODIGO+L0_TPFORN+L0_CODFORN
			If (!(SL0->(MsSeek(xFilial("SL0")+RHK->RHK_CDPSAG))) .OR. !(SG0->(MsSeek(xFilial("SG0")+"1"+RHK->RHK_CDPSAG)))) .AND. lRet
				lRet := .F.
				Help(" ", 1, "Help",, OemToAnsi(STR0077), 1, 0) //O tipo de cАlculo nЦo pode ser alterado para AutomАtico. Verifique a definiГЦo de plano de saЗde.
			EndIf
		EndIf
	EndIf

	If RHK->RHK_TPCALC == "2" .AND. cM_TPCALCK == "2" .AND. lRet
		//Se um dos campos abaixo for alterado, o tipo de cАlculo torna-se 1-Informado
		If RHK->RHK_TPFORN <> cM_TPFORN .OR. RHK->RHK_CODFOR <> cM_CODFOR .OR. RHK->RHK_TPPLAN <> cM_TPPLAN .OR. RHK->RHK_PLANO <> cM_PLANO;
			.OR. RHK->RHK_PD <> cM_PD .OR. RHK->RHK_PDDAGR <> cM_PDDAGR .OR. RHK->RHK_PERINI <> cM_PERINI .OR. RHK->RHK_PERFIM <> cM_PERFIM
			MsgAlert(OemToAnsi(STR0075))//Essas alteraГУes impactam diretamente no tipo de cАlculo e ele se tornarА '1-Informado'
			oModel:SetValue("GPEA001_MRHK", "RHK_TPCALC", "1")
			If nCountL > 0
				oModel:SetValue("GPEA001_MRHL", "RHL_TPCALC", "1")
			EndIf
			If nCountM > 0
				oModel:SetValue("GPEA001_MRHM", "RHM_TPCALC", "1")
			EndIf
		EndIf

		DbSelectArea("SRB")
		cIndKeySRB	:= "RB_FILIAL+RB_MAT+RB_COD"
		cArqSRB := CriaTrab( Nil, .F. )
		IndRegua( "SRB", cArqSRB, cIndKeySRB, , , '', .T. )
		nIndexSRB	:= SRB->( RetIndex( ) ) + 1
		SRB->(DbSetOrder(nIndexSRB))

		If SRB->(MsSeek(xFilial("SRB")+cRA_MAT+cM_CODL)) .AND. nCountL > 0 .AND. lRet
			If cM_TPCALCL == "2" .AND. SRB->RB_PLSAUDE == "2"
				Help(" ", 1, "Help",, OemToAnsi(STR0076), 1, 0)//O campo "Tem Plano de SaЗde" no cadastro de dependentes estА preenchido como '2-NЦo'.
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//Se o campo RHK_TPCALC for alterado para "1-Informado", os campos RHL_TPCALC e RHM_TPCALC tambИm serЦo alterados para "1-Informado"
	If (RHK->RHK_TPCALC == "2" .OR. RHK->RHK_TPCALC == " ") .AND. cM_TPCALCK == "1" .AND. cTab == "RHK" .AND. lRet
		If RHL->(MsSeek(xFilial("RHL")+cRA_MAT)) .AND. nCountL > 0
			If !lMsg
				MsgInfo(OemToAnsi(STR0074),OemToAnsi(STR0073))//O tipo de cАlculo dos dependentes e dos agregados tambИm serА alterado para 1-Informado
				lMsg := .T.
			EndIf
			oModel:LoadValue("GPEA001_MRHL", "RHL_TPCALC", "1")
		EndIf
		If RHM->(MsSeek(xFilial("RHM")+cRA_MAT)) .AND. nCountM > 0
			If !lMsg
				MsgInfo(OemToAnsi(STR0074),OemToAnsi(STR0073))//O tipo de cАlculo dos dependentes e dos agregados tambИm serА alterado para 1-Informado
				lMsg := .T.
			EndIf
			oModel:LoadValue("GPEA001_MRHM", "RHM_TPCALC", "1")
		EndIf
			oModel:LoadValue("GPEA001_MRHK", "RHK_CDPSAG", "    ")
	EndIf

	//Se um dos campos abaixo for alterado, o tipo de cАlculo torna-se 1-Informado
	cM_TPPLAN := oStructRHL:GetValue("RHL_TPPLAN")
	cM_PLANO := oStructRHL:GetValue("RHL_PLANO")
	If RHL->RHL_TPCALC == "2" .AND. lRet
		If  nCountL > 0 .AND. (RHL->RHL_TPPLAN <> cM_TPPLAN .OR. RHL->RHL_PLANO <> cM_PLANO .OR. RHL->RHL_PERINI <> cM_PERINIL .OR. RHL->RHL_PERFIM <> cM_PERFIML)
			MsgAlert(OemToAnsi(STR0075))//Essas alteraГУes impactam diretamente no tipo de cАlculo e ele se tornarА '1-Informado'
			oModel:SetValue("GPEA001_MRHL", "RHL_TPCALC", "1")
		EndIf
	EndIf

	cM_TPPLAN := oStructRHM:GetValue("RHM_TPPLAN")
	cM_PLANO := oStructRHM:GetValue("RHM_PLANO")
	If RHM->RHM_TPCALC == "2" .AND. lRet
		If nCountM > 0 .AND. (RHM->RHM_TPPLAN <> cM_TPPLAN .OR. RHM->RHM_PLANO <> cM_PLANO .OR. RHM->RHM_PERINI <> cM_PERINIM .OR. RHM->RHM_PERFIM <> cM_PERFIMM)
			MsgAlert(OemToAnsi(STR0075))//Essas alteraГУes impactam diretamente no tipo de cАlculo e ele se tornarА '1-Informado'
			oModel:SetValue("GPEA001_MRHM", "RHM_TPCALC", "1")
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc}fLoadPlan
Carrega os dados do plano cadastrado na rotina de definiГЦo de planos de saЗde, quando o tipo de cАlculo И automАtico.
@author Gabriel de Souza Almeida
@since 10/04/2015
@version P12
@return LСgico, lRet
/*/
Function fLoadPlan(cTab)
	Local lRet := .T.
	Local oModel := FwModelActive()

	Local oStructSRA := oModel:GetModel("GPEA001_MSRA")
	Local cRA_MAT := oStructSRA:GetValue("RA_MAT")

	DbSelectArea("RHK")
	RHK->(DbSetOrder(1))
	If (RHK->(MsSeek(xFilial("RHK")+cRA_MAT)))
		DbSelectArea("SG0")
		SG0->(DbSetOrder(2))//G0_FILIAL+G0_STATUS+G0_CODIGO
		DbSelectArea("SL0")
		SL0->(DbSetOrder(1))//L0_FILIAL+L0_CODIGO+L0_TPFORN+L0_CODFORN
		DbSelectArea("SLE")
		SLE->(DbSetOrder(1))//LE_FILIAL+LE_CODIGO+LE_TPFORN+LE_CODFORN
		If cTab == "RHL"
			If SG0->(MsSeek(xFilial("SG0")+"1"+RHK->RHK_CDPSAG)) .AND. SL0->(MsSeek(xFilial("SL0")+RHK->RHK_CDPSAG))
				oModel:SetValue("GPEA001_MRHL", "RHL_TPPLAN", SL0->L0_TPPLANO)
				oModel:SetValue("GPEA001_MRHL", "RHL_PLANO", SL0->L0_PLANO)
				oModel:SetValue("GPEA001_MRHL", "RHL_PERINI", SL0->L0_PERINI)
				oModel:SetValue("GPEA001_MRHL", "RHL_PERFIM", SL0->L0_PERFIM)
			EndIf
		EndIf
		If cTab == "RHM"
			If SG0->(MsSeek(xFilial("SG0")+"1"+RHK->RHK_CDPSAG)) .AND. SLE->(MsSeek(xFilial("SLE")+RHK->RHK_CDPSAG))
				oModel:SetValue("GPEA001_MRHM", "RHM_TPPLAN", SLE->LE_TPPLANO)
				oModel:SetValue("GPEA001_MRHM", "RHM_PLANO", SLE->LE_PLANO)
				oModel:SetValue("GPEA001_MRHM", "RHM_PERINI", SLE->LE_PERINI)
				oModel:SetValue("GPEA001_MRHM", "RHM_PERFIM", SLE->LE_PERFIM)
			EndIf
		EndIf
	EndIf

Return lRet


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RHL_TudoOK		ЁAutorЁ  Renan BorgesЁ      Data Ё14/04/2016Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao do Tudo OK                                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHL_TudoOK(oModel)

	Local lRet 	:= .T.

	Local nI
	Local nLines := oModel:Length()

	For nI := 1 To nLines
		oModel:GoLine( nI )

	    If !oModel:IsDeleted()
    		RecLock("SRB",.F.)
				SRB->RB_PLSAUDE := "1"
			SRB->(msUnlock())
			Exit
	    EndIf

	Next nI

Return( lRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё VLDVIEW		ЁAutorЁ  Renan BorgesЁ      Data Ё14/04/2016Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida abertura da view                                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA001                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/


Static Function VLDVIEW(oView)

Local lRet := .T.
Local aArea  := GetArea()
Local oModel := oView:GetModel()

oModel:Activate()

If oModel:GetOperation() == 5
	If oModel:GetModel("GPEA001_MRHK"):IsEmpty()
		Help(,,'HELP',,OemToAnsi(STR0078),1,0) //"NЦo hА planos ativos para este FuncionАrio"
		lRet:= .F.
	EndIf
EndIf

oModel:DeActivate()

RestArea(aArea)

Return lRet

/*/{Protheus.doc}Gp001IniMod
Valida inicializaГЦo do Model
@author Gabriel de Souza Almeida
@since 15/06/2016
@version P12
/*/
Function Gp001IniMod(oModel,nOperacao)
Local lRet 		:= .T.
Local cCpartSRA := ""
Local cCpartRHK := ""
Local cCpartRHL := ""
Local cCpartRHM := ""

//Modo de compartilhamento da tabela SRA
cCpartSRA := FWModeAccess("SRA", 1)
cCpartSRA += FWModeAccess("SRA", 2)
cCpartSRA += FWModeAccess("SRA", 3)

//Modo de compartilhamento da tabela RHK
cCpartRHK := FWModeAccess("RHK", 1)
cCpartRHK += FWModeAccess("RHK", 2)
cCpartRHK += FWModeAccess("RHK", 3)

//Modo de compartilhamento da tabela RHL
cCpartRHL := FWModeAccess("RHL", 1)
cCpartRHL += FWModeAccess("RHL", 2)
cCpartRHL += FWModeAccess("RHL", 3)

//Modo de compartilhamento da tabela RHM
cCpartRHM := FWModeAccess("RHM", 1)
cCpartRHM += FWModeAccess("RHM", 2)
cCpartRHM += FWModeAccess("RHM", 3)

// Verifica se as tabelas estao com o mesmo modo de compartilhamento
If (cCpartSRA != cCpartRHK) .OR. (cCpartSRA != cCpartRHL) .OR. (cCpartSRA != cCpartRHM)
	Help( , , 'HELP', , OemToAnsi(STR0108), 1, 0 )  //"Verifique o compartilhamento entre as tabelas SRA, RHK, RHL e RHM. O compartilhamento dessas tabelas deve ser idЙntico."
	lRet := .F.
EndIf

If lRet .and. !(IsInCallStack("CFG600lmdl")) .And. (nOperacao == 3 .OR. (nOperacao == 4 .AND. IsInCallStack("GPEW020")))
	oModel:SetOperation( 4 )

	cFilOld		:= cFilAnt
	cFilAnt		:= SRA->RA_FILIAL
EndIf

Return lRet

/*/{Protheus.doc} GetCalcPla
Verifica se existe cАlculo de plano de saЗde para o funcionАrio posicionado no perМodo informado
@author  CМcero Alves
@since   27/09/2019
@param cPer, Caracter, CСdigo do perМodo para busca - YYYYmm
@return lCalc, LСgico, Verdadeiro caso encontre algum registro na RHR para o funcionАrio no perМodo informado
/*/
Static Function GetCalcPla (cPer)

	Local cAliasQry	:= GetNextAlias()
	Local cPeriodo	:= cPer
	Local lCalc		:= .F.

	BeginSql alias cAliasQry
		SELECT COUNT(*) NREG
		FROM %table:RHR% RHR
		WHERE RHR_FILIAL = %exp:SRA->RA_FILIAL% AND
		RHR.RHR_MAT = %exp:SRA->RA_MAT% AND
		RHR.RHR_COMPPG = %exp:cPer% AND
		RHR.%notDel%
	EndSql

	If (cAliasQry)->NREG > 0
		lCalc := .T.
	EndIf

	(cAliasQry)->(DbCloseArea())

Return(lCalc)

//Valida RHK_DATFIM
Static Function fVldRHKDtF(oModel)
Local lRet := .T.
Local cRHKMAFim := "" //mesAno fim referente a RHK_DATFIM
Local cRHKDatFim := ""
Local cRotFOL := ""
Local cRotPLA := ""
Local aArea  := GetArea()
Local aPerFol:= {} //periodo atual da Folha
Local aPerPLA:= {} //periodo atual do PLA
Local oModel := FwModelActive()
Local oStructRHK := oModel:GetModel("GPEA001_MRHK")
Local oStructRHL := oModel:GetModel("GPEA001_MRHL")
Local oStructRHM := oModel:GetModel("GPEA001_MRHM")
Local cMsgLog := ""

cRotFOL := If(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar())
cRotPLA := fGetCalcRot("C")
fGetPerAtual( @aPerFol, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cRotFOL )
fGetPerAtual( @aPerPLA, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cRotPLA )

	If !Empty(aPerPLA)
		If !Empty(aPerFol)
			If !Empty(oStructRHK:GetValue("RHK_DATFIM"))
				cRHKMAFim := StrZero(Month(oStructRHK:GetValue("RHK_DATFIM")),2) + cValToChar(Year(oStructRHK:GetValue("RHK_DATFIM")))
				cRHKDatFim := StrZero(Day(oStructRHK:GetValue("RHK_DATFIM")),2) + "/" + StrZero(Month(oStructRHK:GetValue("RHK_DATFIM")),2) +"/"+ cValToChar(Year(oStructRHK:GetValue("RHK_DATFIM")))
				If !Empty(oStructRHK:GetValue("RHK_PERFIM")) .AND. cRHKMAFim <> oStructRHK:GetValue("RHK_PERFIM")
					Help(,,'HELP',,OemToAnsi(STR0088)+" ("+cRHKDatFim+") "+OemToAnsi(STR0089)+" ("+oStructRHK:GetValue("RHK_PERFIM")+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo Final informado ().
					lRet := .F.
				EndIf
				If lRet .AND. (AnoMes(oStructRHK:GetValue("RHK_DATFIM")) < aPerFol[1,1] .OR. AnoMes(oStructRHK:GetValue("RHK_DATFIM")) < aPerPLA[1,1])
					Help(,,'HELP',,OemToAnsi(STR0088)+" ("+cRHKDatFim+") "+OemToAnsi(STR0096)+" ("+aPerFol[1,1]+") "+OemToAnsi(STR0097)+" ("+aPerPLA[1,1]+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo aberto da Folha () ou ao perМodo aberto do Plano de SaЗde().
					lRet := .F.
				EndIf
				If lRet .AND. Empty(oStructRHK:GetValue("RHK_PERFIM"))
					oStructRHK:SetValue("RHK_PERFIM",cRHKMAFim)
				EndIf
			EndIf
		Else
			Help(,,'HELP',,OemToAnsi(STR0107),1,0) //NЦo hА um roteiro de Folha selecionado no PerМodo atual. Selecione um roteiro de Folha para o PerМodo atual antes de continuar!
			lRet := .F.
		EndIf
	Else
		Help(,,'HELP',,OemToAnsi(STR0102),1,0) //"NЦo hА um roteiro de Plano de SaЗde selecionado no PerМodo atual. Selecione um roteiro de Plano de SaЗde para o PerМodo atual, antes de continuar!"
		lRet := .F.
	EndIf

RestArea(aArea)
Return lRet


//Valida RHL_DATFIM
Static Function fVldRHLDtF(oModel)
Local lRet := .T.
Local cRHLMAFim := "" //mesAno fim referente a RHK_DATFIM
Local cRHLDatFim:= ""
Local cRHKDatFim := ""
Local cRotFOL := ""
Local cRotPLA := ""
Local aArea  := GetArea()
Local aPerFol:= {} //periodo atual da Folha
Local aPerPLA:= {} //periodo atual do PLA
Local oModel := FwModelActive()
Local oStructRHK := oModel:GetModel("GPEA001_MRHK")
Local oStructRHL := oModel:GetModel("GPEA001_MRHL")

cRotFOL := If(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar())
cRotPLA := fGetCalcRot("C")
fGetPerAtual( @aPerFol, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cRotFOL )
fGetPerAtual( @aPerPLA, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cRotPLA )

	If !Empty(aPerPLA)
		If !Empty(oStructRHL:GetValue("RHL_DATFIM"))
			cRHLMAFim := StrZero(Month(oStructRHL:GetValue("RHL_DATFIM")),2) + cValToChar(Year(oStructRHL:GetValue("RHL_DATFIM")))
			cRHLDatFim := StrZero(Day(oStructRHL:GetValue("RHL_DATFIM")),2) + "/" + StrZero(Month(oStructRHL:GetValue("RHL_DATFIM")),2) +"/"+ cValToChar(Year(oStructRHL:GetValue("RHL_DATFIM")))
			If !Empty(oStructRHL:GetValue("RHL_PERFIM")) .AND. cRHLMAFim <> oStructRHL:GetValue("RHL_PERFIM")
				Help(,,'HELP',,OemToAnsi(STR0088)+" ("+cRHLDatFim+") "+OemToAnsi(STR0089)+" ("+oStructRHL:GetValue("RHL_PERFIM")+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo Final informado ().
				lRet := .F.
			EndIf
			If lRet .AND. !Empty(oStructRHK:GetValue("RHK_DATFIM")) .AND. (oStructRHL:GetValue("RHL_DATFIM") > oStructRHK:GetValue("RHK_DATFIM"))
				cRHKDatFim := StrZero(Day(oStructRHK:GetValue("RHK_DATFIM")),2) + "/" + StrZero(Month(oStructRHK:GetValue("RHK_DATFIM")),2) +"/"+ cValToChar(Year(oStructRHK:GetValue("RHK_DATFIM")))
				Help(,,'HELP',,OemToAnsi(STR0100)+" ("+cRHLDatFim+") "+OemToAnsi(STR0099)+" ("+cRHKDatFim+")!",1,0) //"Data Final do Plano do Dependente(//) deve ser igual ou menor Ю Data Final do Plano do Titular (//)
				lRet := .F.
			EndIf
			If lRet .AND. (AnoMes(oStructRHL:GetValue("RHL_DATFIM")) < aPerFol[1,1] .OR. AnoMes(oStructRHL:GetValue("RHL_DATFIM")) < aPerPLA[1,1])
				Help(,,'HELP',,OemToAnsi(STR0088)+" ("+cRHLDatFim+") "+OemToAnsi(STR0096)+" ("+aPerFol[1,1]+") "+OemToAnsi(STR0097)+" ("+aPerPLA[1,1]+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo aberto da Folha () ou ao perМodo aberto do Plano de SaЗde().
				lRet := .F.
			EndIf
			If lRet .AND. Empty(oStructRHL:GetValue("RHL_PERFIM"))
				oStructRHL:SetValue("RHL_PERFIM",cRHLMAFim)
			EndIf
		EndIf
	Else
		Help(,,'HELP',,OemToAnsi(STR0102),1,0) //"NЦo hА um roteiro de Plano de SaЗde selecionado no PerМodo atual. Selecione um roteiro de Plano de SaЗde para o PerМodo atual, antes de continuar!"
		lRet := .F.
	EndIf

RestArea(aArea)
Return lRet


//Valida RHM_DATFIM
Static Function fVldRHMDtF(oModel)
Local lRet := .T.
Local cRHMMAFim := "" //mesAno fim referente a RHK_DATFIM
Local cRHMDatFim:= ""
Local cRotFOL := ""
Local cRotPLA := ""
Local aArea  := GetArea()
Local aPerFol:= {} //periodo atual da Folha
Local aPerPLA:= {} //periodo atual do PLA
Local oModel := FwModelActive()
Local oStructRHK := oModel:GetModel("GPEA001_MRHK")
Local oStructRHM := oModel:GetModel("GPEA001_MRHM")

cRotFOL := If(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar())
cRotPLA := fGetCalcRot("C")
fGetPerAtual( @aPerFol, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cRotFOL )
fGetPerAtual( @aPerPLA, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cRotPLA )

	If !Empty(aPerPLA)
		If !Empty(oStructRHM:GetValue("RHM_DATFIM"))
			cRHMMAFim := StrZero(Month(oStructRHM:GetValue("RHM_DATFIM")),2) + cValToChar(Year(oStructRHM:GetValue("RHM_DATFIM")))
			cRHMDatFim := StrZero(Day(oStructRHM:GetValue("RHM_DATFIM")),2) + "/" + StrZero(Month(oStructRHM:GetValue("RHM_DATFIM")),2) +"/"+ cValToChar(Year(oStructRHM:GetValue("RHM_DATFIM")))
			If !Empty(oStructRHM:GetValue("RHM_PERFIM")) .AND. cRHMMAFim <> oStructRHM:GetValue("RHM_PERFIM")
				Help(,,'HELP',,OemToAnsi(STR0088)+" ("+cRHMDatFim+") "+OemToAnsi(STR0089)+" ("+oStructRHM:GetValue("RHM_PERFIM")+")!",1,0) //"Data Final do Plano (//) deve pertencer ao PerМodo Final informado ().
				lRet := .F.
			EndIf
			If lRet .AND. !Empty(oStructRHK:GetValue("RHK_DATFIM")) .AND. (oStructRHM:GetValue("RHM_DATFIM") > oStructRHK:GetValue("RHK_DATFIM"))
				cRHKDatFim := StrZero(Day(oStructRHK:GetValue("RHK_DATFIM")),2) + "/" + StrZero(Month(oStructRHK:GetValue("RHK_DATFIM")),2) +"/"+ cValToChar(Year(oStructRHK:GetValue("RHK_DATFIM")))
				Help(,,'HELP',,OemToAnsi(STR0098)+" ("+cRHMDatFim+") "+OemToAnsi(STR0099)+" ("+cRHKDatFim+")!",1,0) //"Data Final do Plano do Agregado (//) deve ser igual ou menor Ю Data Final do Plano do Titular(//)
				lRet := .F.
			EndIf
			If lRet .AND. (AnoMes(oStructRHM:GetValue("RHM_DATFIM")) < aPerFol[1,1] .OR. AnoMes(oStructRHM:GetValue("RHM_DATFIM")) < aPerPLA[1,1])
				Help(,,'HELP',,OemToAnsi(STR0088)+" ("+cRHMDatFim+") "+OemToAnsi(STR0096)+" ("+aPerFol[1,1]+") "+OemToAnsi(STR0097)+" ("+aPerPLA[1,1]+")!",1,0) //
				lRet := .F.
			EndIf
			If lRet .AND. Empty(oStructRHM:GetValue("RHM_PERFIM"))
				oStructRHM:SetValue("RHM_PERFIM",cRHMMAFim)
			EndIf
		EndIf
	Else
		Help(,,'HELP',,OemToAnsi(STR0102),1,0) //"NЦo hА um roteiro de Plano de SaЗde selecionado no PerМodo atual. Selecione um roteiro de Plano de SaЗde para o PerМodo atual, antes de continuar!"
		lRet := .F.
	EndIf

RestArea(aArea)
Return lRet
