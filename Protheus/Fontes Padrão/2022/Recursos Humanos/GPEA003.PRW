#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA003.CH"

Static aPerAtual

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    	³ GPEA003    ³ Autor ³ Mauricio Takakura     	      ³ Data ³ 13/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o 	³ Lancamento de Co-Participacao e Reembolso                    			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEA003()                                                    			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      	³ Generico ( DOS e Windows )                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ FNC			³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr.  ³07/02/2012³M12RH01         ³Unificacao da Folha.                  		³±±
±±³				³		   ³RHU210_03_07	³       .									³±±
±±³Renan Borges	³28/08/2014³00000026008/2014³Validação do cadastro de co-participação ou³±±
±±³				³		   ³				³reembolso, pois é possível o lançamento dos³±±
±±³				³		   ³				³mesmo após o término do plano saúde já que ³±±
±±³				³		   ³				³no fechamento mensal o plano ativo que ex- ³±±
±±³				³		   ³				³pirou é colocado na tabela de historico de ³±±
±±³				³		   ³				³alterações de planos de saude (RHN).       ³±±
±±³Cícero Alves	³17/04/2015³		  TSDRKP³Atera consulta padrão para dependentes para³±±
±±³				³		   ³				³mostar apenas os que pssuem planos ativos  ³±±
±±³Cícero Alves	³01/06/2015³		  TSDRKP³Correção na consulta padrão dos dependentes³±±
±±³				³		   ³				³											³±±
±±³M. Silveira  ³10/08/2015³          TSWILH³Ajuste na RHO_LinhaOK p/ validar os campos ³±±
±±³				³		   ³				³corretos do dependente na tabela RHN.      ³±±
±±³Mariana M.  	³11/08/2015³TTADRF          ³Ajuste inclusão de Coparticipação/Reembolso³±±
±±³				³		   ³				³para dependentes para que apareça somente  ³±±
±±³				³		   ³				³os dependentes cadastrados nos planos e    ³±±
±±³				³		   ³				³quando selecionado o segundo dependente,   ³±±
±±³				³		   ³				³trazer a informação correta.				³±±
±±³Mariana M.  	³07/12/2015³TTYSCB          ³Ajuste no filtro da Coparticipação na fun- ³±±
±±³				³		   ³				³çao GPE_DEP para que seja possivel escolher³±±
±±³				³		   ³				³somente os dependentes que estão vinculados³±±
±±³				³		   ³				³no determinado fornecedor					³±±
±±³Renan Borges ³22/04/2016³TUW511          ³Ajuste para lançar coparticipação para fun-³±±
±±³				³		   ³				³cionários com o processo 00003 corretamente³±±
±±³Eduardo F.   ³09/05/2016³TUZYRE          ³Ajuste para validação do cadastro de copar-³±±
±±³				³		   ³				³ticipação ou reembolso em período fechado. ³±±
±±³Gabriel A.   ³09/05/2016³TVQZ66          ³Ajuste para que a validação de vigência do ³±±
±±³             ³          ³                ³plano não impeça o lançamento.             ³±±
±±³Raquel Hager ³15/11/2016³TVZKGR          ³Ajuste para permitir importar txt via Mile.³±±
±±³Renan Borges	³28/12/2016³MRH-1174		³Ajuste para ao lançar uma cooparticipação, ³±±
±±³				³		   ³				³seja realizada a busca do dependente no his³±±
±±³				³		   ³				³tórico dos planos, de acordo com as informa³±±
±±³				³		   ³				³ções geradas pelo sistema no fechamento da ³±±
±±³				³		   ³				³folha do mes de vencimento do período.     ³±±
±±³Wesley Alves	³16/07/2018³DRHGCH-12047	³Alteração para buscar os dados da tabela   ³±±
±±³				³		   ³				³de historico de alteração quando o motivo  ³±±
±±³				³		   ³				³da alteração for a mudança do fornecedor   ³±±
±±³				³		   ³				³do plano de saúde.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA003()

	Local oMBrowse
	Local cFiltraRh
	Private cFilOld	:= cFilAnt
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica existencia da nova tabela de Lancamento de Co-participacao e	³
	//³ Reembolso - RHO. Se Nao Existir apresenta mensagem informando a neces-	³
	//³ sidade da execucao do update para criacao e aborta o acesso ate que o	³
	//³ update seja executado.													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( RetTableName( "RHO" ) )
		Aviso( STR0012, STR0013, { STR0014 } ) // "Atenção"## "Execute a opção do compatibilizador referente ao Novo Plano de Saúde. Para maiores informações, verifique respectivo Boletim Técnico." ## "OK"
		Return
	EndIf

	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Lançamento de Co-participação e Reembolso"

	GpLegMVC(@oMBrowse)	// Adicionar a Legenda no Browse

	oMBrowse:ForceQuitButton()					//"Incluir botao de sair"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cFiltraRh := CHKRH("GPEA003","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )

	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Mauricio Takakura³ Data ³13/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Criacao do Menu do Browse.                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE OemToAnsi(STR0002)  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION "VIEWDEF.GPEA003" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0004)  ACTION "VIEWDEF.GPEA003" 		OPERATION 3 ACCESS 0				//'Lançamentos'
	ADD OPTION aRotina TITLE OemToAnsi(STR0005)  ACTION "VIEWDEF.GPEA003" 		OPERATION 5 ACCESS 0				//'Excluir'

Return aRotina

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ModelDef 		³Autor³  Mauricio Takakura³ Data ³13/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Modelagem da gravacao.                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ModelDef()

	Local oModel
	Local oStructSRA
	Local oStructRHO	// Lancamentos de Co-participacao e Reembolso
	Local bCommiM003	:= { | oModel | fCommit003(oModel) }
	Local bCancel		:= { | oModel | fCancel003(oModel) }
	Local bTudoOK		:= { | oModel | fTudOk003(oModel) }
	Local lSldCabc		:= .F.


	// Criacao do Objeto de Modelagem de dados //
	oModel     := MPFormModel():New("GPEA003", /*bPreValid*/, bTudoOK, bCommiM003, bCancel)
	oModel:SetDescription( OemToAnsi(STR0001) ) //"Lançamento de Co-participação e Reembolso"

	// Cabecalho de dados - SRA (Funcionario)//
	oStructSRA := FWFormStruct(1, "SRA",  { |cCampo| Gpa003SRAStru(cCampo) })

	DbSelectArea('RHO')
	if RHO->(FieldPos("RHO_SALDO"  ))  > 0
		lSldCabc := .T.
		oStructSRA:AddField(OemToAnsi(STR0020)											,;	// 	[01]  C   Titulo do campo  
					 OemToAnsi(STR0020)													,;	// 	[02]  C   ToolTip do campo
					 "RHO_SALDO"		     											,;	// 	[03]  C   Id do Field
					 'N'																,;	// 	[04]  C   Tipo do campo
					 12                       											,;	// 	[05]  N   Tamanho do campo
					 2																	,;	// 	[06]  N   Decimal do campo
					 Nil																,;	// 	[07]  B   Code-block de validação do campo
					 NIL																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL					        									,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.																)	// 	[14]  L   Indica se o campo é virtual
	endif

	

	oModel:AddFields("GPEA003_MSRA", NIL, oStructSRA)
	oModel:GetModel( "GPEA003_MSRA" ):SetDescription( OemToAnsi(STR0001) ) //"Lançamento de Co-participação e Reembolso"
	oModel:GetModel('GPEA003_MSRA'):SetOnlyQuery(.T.)
	oModel:GetModel('GPEA003_MSRA'):SetOnlyView(.T.)

	// Estrutura de campos do Model - RHO - "Lançamento de Co-participação e Reembolso" //
	oStructRHO := FWFormStruct(1, "RHO")
	oStructRHO:SetProperty( "RHO_CODIGO", MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEA003_MRHO") } )
	If GetRpoRelease() == "12.1.017"
		oStructRHO:SetProperty( "RHO_NOME", MODEL_FIELD_TAMANHO, TamSX3("RB_NOME")[1] )
	Endif

	if lSldCabc
		oStructRHO:AddTrigger("RHO_SALDO", "RHO_SALDO", {||.T.}, {|oModel|triggSld(oModel)})
		oModel:SetActivate({|oModel| iniPadSld(oModel)} )
	endif

	oModel:AddGrid("GPEA003_MRHO", "GPEA003_MSRA", oStructRHO, {|oModel, nLine, cAction| RHO_LinhaPre(oModel, nLine, cAction)} , { |oModel| RHO_LinhaOK(oModel) } )
	oModel:GetModel( "GPEA003_MRHO" ):SetUniqueLine( { 'RHO_DTOCOR', 'RHO_TPFORN', 'RHO_CODFOR', 'RHO_ORIGEM','RHO_CODIGO','RHO_PD','RHO_COMPPG' } )

	oModel:GetModel( "GPEA003_MRHO" ):SetDescription( OemToAnsi(STR0001) ) //"Lançamento de Co-participação e Reembolso" //
	oModel:GetModel( "GPEA003_MRHO" ):SetOptional( .T. )

	oModel:SetRelation( "GPEA003_MRHO", { { "RHO_FILIAL", 'xFilial( "SRA" )' }, { "RHO_MAT", 'SRA->RA_MAT' }}, RHO->( IndexKey( 1 ) ) )	

	oModel:SetVldActivate( { |oModel| Gp003IniMod( oModel,oModel:GetOperation() ) } )


Return( oModel )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ViewDef  		³Autor³  Mauricio Takakura³ Data ³13/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Interface com o Usuario                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ViewDef()
	Local oView
	Local oModel
	Local oStructSRA
	Local oStructRHO

	// Vincular o View ao Model //
	oModel := FWLoadModel("GPEA003")

	// Criacao da Interface //
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Criacao do Cabecalho - SRA (Funcionario) //
	oStructSRA := FWFormStruct(2, "SRA", { |cCampo| Gpa003SRAStru(cCampo) })

	DbSelectArea('RHO')
	if RHO->(FieldPos("RHO_SALDO"  ))  > 0
		oStructSRA:AddField("RHO_SALDO"		     											,;	// [01]  C   Nome do Campo
						"99"																,;	// [02]  C   Ordem
						OemToAnsi(STR0020)													,;	// [03]  C   Titulo do campo//"Descrição"
						OemToAnsi(STR0020)													,;	// [04]  C   Descricao do campo//"Descrição"
						NIL																	,;	// [05]  A   Array com Help
						"N"																	,;	// [06]  C   Tipo do campo
						"@E 999,999,999.99 "												,;	// [07]  C   Picture
						NIL																	,;	// [08]  B   Bloco de Picture Var
						NIL																	,;	// [09]  C   Consulta F3
						.T.																	,;	// [10]  L   Indica se o campo é alteravel
						NIL																	,;	// [11]  C   Pasta do campo
						NIL																	,;	// [12]  C   Agrupamento do campo
						NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL																	,;	// [15]  C   Inicializador de Browse
						.T.																	,;	// [16]  L   Indica se o campo é virtual
						NIL																	,;	// [17]  C   Picture Variavel
						NIL																	)	// [18]  L   Indica pulo de linha após o campo
	endif


	oStructSRA:SetNoFolder()
	oView:AddField("GPEA003_VSRA", oStructSRA, "GPEA003_MSRA" )

	// Criacao do Cabecalho - RHO - "Lançamento de Co-participação e Reembolso" //
	oStructRHO 	:= FWFormStruct(2, "RHO")
	oStructRHO:RemoveField( "RHO_MAT" )
	If RHO->( ColumnPos("RHO_CPF") ) > 0
		oStructRHO:SetProperty("RHO_CPF", MVC_VIEW_PVAR, FwBuildFeature(STRUCT_FEATURE_PICTVAR, "'@R 999.999.999-99'"))
	EndIf

	oView:AddGrid("GPEA003_VRHO", oStructRHO, "GPEA003_MRHO" )

	// Desenho da Tela //
	oView:CreateHorizontalBox("SRA_HEAD", 12)
	oView:CreateHorizontalBox("RHO_LANC", 88)

	oView:SetOwnerView( "GPEA003_VSRA", "SRA_HEAD" )
	oView:SetOwnerView( "GPEA003_VRHO", "RHO_LANC" )
	oView:SetViewCanActivate({|oView| VldLanct(oView)})

Return oView

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ Gpa003SRAStru	³Autor³  Mauricio Takakura³ Data ³13/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Selecionar os campos para a estrutura do SRA                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA002                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Gpa003SRAStru( cCampo )
	Local lRet := .F.

	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME*RA_ADMISSA'
		lRet := .T.
	EndIf

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ When_NotEdit   ³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Permite somente digitacao em inclusao                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function When_NotEdit(oStruct, cModel)
	Local lRet	:= .T.

	cOrigem := oStruct:GetValue( "RHO_ORIGEM" )

	If cOrigem == "1"
		lRet := .F.
	EndIf

Return( lRet )


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ RHO_LinhaOK	³Autor³  Mauricio Takakura³ Data ³16/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Validacao da Linha OK                                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function RHO_LinhaOK(oStruct)
	Local aArea		:= GetArea()

	Local cPerIni	:= ""
	Local cPerFim	:= ""
	Local cCodigo	:= ""
	Local cDtOcor	:= ""
	Local cSvAlias:= ""

	Local lRet 		:= .T.
	Local lFound 	:= .F.

	cOrigem	:= oStruct:GetValue( "RHO_ORIGEM" )
	cTpForn	:= oStruct:GetValue( "RHO_TPFORN" )
	cCodigo	:= oStruct:GetValue( "RHO_CODIGO" )
	cCodFor	:= oStruct:GetValue( "RHO_CODFOR" )
	cDtOcor	:= oStruct:GetValue( "RHO_DTOCOR" )
	cDtOcor	:= Substr(DTOS( cDtocor ), 1, 6 )

	If cOrigem == "1"

		// CHAMA FUNÇAO PARA VALIDAR SE O CPF DO TITULAR ESTA PREENCHIDO.
		If RHO->( ColumnPos("RHO_CPF") ) > 0
			fVldCPF()
		EndIf

		DbSelectArea( "RHK" )
		DbSetOrder( RetOrdem( "RHK", "RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR" ) )
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor, .F. )
		If Eof() // Não achou o registro na RHK então é necessário procurar na RHN (Histórico)
			DbSelectArea( "RHN" )
			DbSetOrder( 1 )
			DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
			//Ao realizar o fechamento Mensal o sistema exclui da RHK o plano cujo periodo tenha expirado e o coloca na RHN
			//Se encontrar a Filial e a Matricula na RHN irá procurar o plano correto, que tenha sido Excluido e o tipo de alteração for Vigência
			While !Eof() .AND.;
			RHN->(RHN_FILIAL + RHN_MAT + RHN_ORIGEM + RHN_TPFORN + RHN_CODFOR) != ;
			SRA->RA_FILIAL  + SRA->RA_MAT + cOrigem + cTpForn + cCodFor
				DbSkip()
			EndDo
			If Eof() //Se não encontrar tanto na RHK quanto na RHN irá informar a mensagem abaixo
				Help(,,'HELP',,OemToAnsi(STR0009),1,0)	//"Plano não cadastrado para o usuario!"
				lRet := .F.
			EndIf
		EndIf

		If !Eof() //Se encontrou ou na RHK ou na RHN irá verificar se a data de Ocorrencia está de acordo com o periodo do plano
			cSvAlias := Alias() //Se for RHK significa que encontrou nela e não teve a necessidade de procurar na RHN
			lFound := .F.
			//Irá realizar a pesquisa de acordo com a tabela corrente.
			While !Eof() .and. (If(cSvAlias == "RHK",(RHK->(RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR ) == SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor),;
				(RHN->(RHN_FILIAL + RHN_MAT + RHN_TPFORN + RHN_CODFOR) == SRA->RA_FILIAL  + SRA->RA_MAT + cTpForn + cCodFor))		)
				If cSvAlias == "RHK"
					cPerIni := Substr(RHK->RHK_PERINI,3,4) + Substr( RHK->RHK_PERINI,1,2)
					cPerFim	:= Substr(RHK->RHK_PERFIM,3,4) + Substr( RHK->RHK_PERFIM,1,2)
				Else
					If RHN->(RHN_OPERAC + RHN_ORIGEM + RHN_TPALT) == "2" + cOrigem + "04"
						cPerIni := Substr(RHN->RHN_PERINI,3,4) + Substr( RHN->RHN_PERINI,1,2)
						cPerFim	:= Substr(RHN->RHN_PERFIM,3,4) + Substr( RHN->RHN_PERFIM,1,2)
					Else
						( cSvAlias )->( DbSkip() )
						Loop
					EndIf
				EndIf
				If (cDtOcor >= cPerIni .And. (Empty(cPerFim) .Or. cDtOcor <= cPerFim))
					lFound := .T.
					Exit
				EndIf
				( cSvAlias )->( DbSkip() )
			EndDo
			If !lFound
				If IsBlind()
					Help(,,'HELP',,OemToAnsi(STR0010),1,0)	//"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				Else
					MsgInfo(OemToAnsi(STR0010)) //"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				EndIf
			EndIf
		EndIf
	ElseIf cOrigem == "2"
		DbSelectArea( "RHL" )
		DbSetOrder( RetOrdem( "RHL", "RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR+RHL_CODIGO" ) )
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor + cCodigo, .F. )
		If Eof() // Não achou o registro na RHL então é necessário procurar na RHN (Histórico)
			DbSelectArea( "RHN" )
			DbSetOrder( 1 )
			DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
			//Ao realizar o fechamento Mensal o sistema exclui da RHL o plano cujo periodo tenha expirado e o coloca na RHN
			//Se encontrar a Filial e a Matricula na RHN irá procurar o plano correto, que tenha sido Excluido e o tipo de alteração for Vigência


			While !Eof() ;
			.AND. ( ;
						( RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) != ;
						  SRA->RA_FILIAL  + SRA->RA_MAT + "2" + cOrigem + "04" + cTpForn + cCodFor );
 			.AND.  ;
						( RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) != ;
						  SRA->RA_FILIAL  + SRA->RA_MAT + "1" + cOrigem + "01" + cTpForn + cCodFor ) ;
			)
				DbSkip()
			EndDo

			If Eof() //Se não encontrar tanto na RHL quanto na RHN irá informar a mensagem abaixo
				Help(,,'HELP',,OemToAnsi(STR0009),1,0)	//"Plano não cadastrado para o usuario!"
				lRet := .F.
			EndIf
		EndIf

		If !Eof() //Se encontrou ou na RHL ou na RHN irá verificar se a data de Ocorrencia está de acordo com o periodo do plano
			cSvAlias := Alias() //Se for RHL significa que encontrou nela e não teve a necessidade de procurar na RHN
			lFound := .F.
			//Irá realizar a pesquisa de acordo com a tabela corrente.
			While !Eof() .and. (If(cSvAlias == "RHL",(RHL->(RHL_FILIAL + RHL_MAT + RHL_TPFORN + RHL_CODFOR ) == SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor),;
				(RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) == SRA->RA_FILIAL  + SRA->RA_MAT + "2" + cOrigem + "04" + cTpForn + cCodFor)) )
				If cSvAlias == "RHL"
					cPerIni := Substr(RHL->RHL_PERINI,3,4) + Substr( RHL->RHL_PERINI,1,2)
					cPerFim	:= Substr(RHL->RHL_PERFIM,3,4) + Substr( RHL->RHL_PERFIM,1,2)
				Else
					If RHN->(RHN_OPERAC + RHN_ORIGEM + RHN_TPALT) == "2" + cOrigem + "04"
						cPerIni := Substr(RHN->RHN_PERINI,3,4) + Substr( RHN->RHN_PERINI,1,2)
						cPerFim	:= Substr(RHN->RHN_PERFIM,3,4) + Substr( RHN->RHN_PERFIM,1,2)
					Else
						( cSvAlias )->( DbSkip() )
						Loop
					EndIf
				EndIf
				If (cDtOcor >= cPerIni .And. (Empty(cPerFim) .Or. cDtOcor <= cPerFim))
					lFound := .T.
					Exit
				EndIf
				( cSvAlias )->( DbSkip() )
			EndDo
			If !lFound
				If IsBlind()
					Help(,,'HELP',,OemToAnsi(STR0010),1,0)	//"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				Else
					MsgInfo(OemToAnsi(STR0010)) //"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				EndIf
			EndIf
		EndIf
	ElseIf cOrigem == "3"
		DbSelectArea( "RHM" )
		DbSetOrder( RetOrdem( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO" ) )
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor + cCodigo, .F. )
		If Eof() // Não achou o registro na RHM então é necessário procurar na RHN (Histórico)
			DbSelectArea( "RHN" )
			DbSetOrder( 1 )
			DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
			//Ao realizar o fechamento Mensal o sistema exclui da RHM o plano cujo periodo tenha expirado e o coloca na RHN
			//Se encontrar a Filial e a Matricula na RHN irá procurar o plano correto, que tenha sido Excluido e o tipo de alteração for Vigência
			While !Eof() .AND.;
			RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) != ;
			SRA->RA_FILIAL  + SRA->RA_MAT + "2" + cOrigem + "04" + cTpForn + cCodFor
				DbSkip()
			EndDo
			If Eof() //Se não encontrar tanto na RHM quanto na RHN irá informar a mensagem abaixo
				Help(,,'HELP',,OemToAnsi(STR0009),1,0)	//"Plano não cadastrado para o usuario!"
				lRet := .F.
			EndIf
		EndIf
		If !Eof() //Se encontrou ou na RHM ou na RHN irá verificar se a data de Ocorrencia está de acordo com o periodo do plano
			cSvAlias := Alias() //Se for RHM significa que encontrou nela e não teve a necessidade de procurar na RHN
			lFound := .F.
			//Irá realizar a pesquisa de acordo com a tabela corrente.
			While !Eof() .and. (If(cSvAlias == "RHM",(RHM->(RHM_FILIAL + RHM_MAT + RHM_TPFORN + RHM_CODFOR ) == SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor),;
				(RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) == SRA->RA_FILIAL  + SRA->RA_MAT + "2" + cOrigem + "04" + cTpForn + cCodFor))		)
				If cSvAlias == "RHM"
					cPerIni := Substr(RHM->RHM_PERINI,3,4) + Substr( RHM->RHM_PERINI,1,2)
					cPerFim	:= Substr(RHM->RHM_PERFIM,3,4) + Substr( RHM->RHM_PERFIM,1,2)
				Else
					If RHN->(RHN_OPERAC + RHN_ORIGEM + RHN_TPALT) == "2" + cOrigem + "04"
						cPerIni := Substr(RHN->RHN_PERINI,3,4) + Substr( RHN->RHN_PERINI,1,2)
						cPerFim	:= Substr(RHN->RHN_PERFIM,3,4) + Substr( RHN->RHN_PERFIM,1,2)
					Else
						( cSvAlias )->( DbSkip() )
						Loop
					EndIf
				EndIf
				If (cDtOcor >= cPerIni .And. (Empty(cPerFim) .Or. cDtOcor <= cPerFim))
					lFound := .T.
					Exit
				EndIf
				( cSvAlias )->( DbSkip() )
			EndDo
			If !lFound
				If IsBlind()
					Help(,,'HELP',,OemToAnsi(STR0010),1,0)	//"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				Else
					MsgInfo(OemToAnsi(STR0010)) //"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ GPA003_Cod	    ³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Validacao do campo Codigo                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPA003_Cod()
	Local aArea		:= GetArea()

	Local cOrigem 	:= ""
	Local cTpForn	:= ""
	Local cCodFor	:= ""

	Local lRet		:= .F.

	Local oModel 		:= FWModelActive()
	Local oStruct		:= oModel:GetModel( "GPEA003_MRHO" )

	cOrigem := oStruct:GetValue( "RHO_ORIGEM" )

	If cOrigem == "2"
		DbSelectArea( "SRB" )
		DbSetOrder( 1 )
		DbSeek(SRA->RA_FILIAL + SRA->RA_MAT, .F.)
		While SRB->( !EOF() ) .and. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If SRB->RB_COD == M->RHO_CODIGO
				lRet := .T.
				Exit
			EndIf
			SRB->( DbSkip() )
		EndDo

		If !lRet
			Help(,,'HELP',,OemToAnsi(STR0006),1,0)	//"Codigo informado não cadastrado!"
		Else
			oStruct:SetValue("RHO_NOME"	, SRB->RB_NOME)

			If RHO->( ColumnPos("RHO_CPF") ) > 0
				oStruct:SetValue("RHO_CPF"	, SRB->RB_CIC)
			EndIf
		EndIf

	ElseIf cOrigem == "3"
		cTpForn	:= oStruct:GetValue( "RHO_TPFORN" )
		cCodFor	:= oStruct:GetValue( "RHO_CODFOR" )
		DbSelectArea( "RHM" )
		DbSetOrder( RetOrdem( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO" ) )
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor + M->RHO_CODIGO, .F. )
		If Eof()
			Help(,,'HELP',,OemToAnsi(STR0006),1,0)	//"Codigo informado não cadastrado!"
		Else
			oStruct:SetValue("RHO_NOME"	, RHM->RHM_NOME)

			If RHO->( ColumnPos("RHO_CPF") ) > 0
				oStruct:SetValue("RHO_CPF"	, RHM->RHM_CPF)
			EndIf
			lRet := .T.
		EndIf

	EndIf

	RestArea( aArea )

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ InitNome_A003  ³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Inicializador Padrao Nome                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function InitNome_A003()
	Local aArea		:= GetArea()

	Local cOrigem 	:= ""
	Local cTpForn	:= ""
	Local cCodFor	:= ""

	Local cRet		:= ""

	Local lRet

	Local oModel 		:= FWModelActive()
	Local oStruct		:= oModel:GetModel( "GPEA003_MRHO" )

	If oStruct:GetLine() > 0

		cRet := SRA->RA_NOME
		Return( cRet )

	EndIf

	cOrigem := RHO->RHO_ORIGEM

	If cOrigem == "1" .Or. Empty( cOrigem )
		cRet := SRA->RA_NOME
	ElseIf cOrigem == "2"
		DbSelectArea( "SRB" )
		DbSetOrder( 1 )
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
		While SRB->( !EOF() ) .and. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If SRB->RB_COD == RHO->RHO_CODIGO
				lRet := .T.
				Exit
			EndIf
			SRB->( DbSkip() )
		EndDo
		If !lRet
			cRet := OemToAnsi( STR0007 ) // "CODIGO NAO CADASTRADO"
		Else
			cRet := SRB->RB_NOME
		EndIf
	ElseIf cOrigem == "3"
		cTpForn	:= RHO->RHO_TPFORN
		cCodFor	:= RHO->RHO_CODFOR
		DbSelectArea( "RHM" )
		DbSetOrder( RetOrdem( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO" ) )
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor + RHO->RHO_CODIGO, .F. )
		If Eof()
			cRet := OemToAnsi( STR0007 ) // "CODIGO NAO CADASTRADO"
		Else
			cRet := RHM->RHM_NOME
		EndIf

	EndIf

	RestArea( aArea )

Return( cRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ GPA003_PD	    ³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Validacao do campo de Verba - Gatilho                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPA003_PD()
	Local aArea		:= GetArea()

	Local oModel 		:= FWModelActive()
	Local oStruct		:= oModel:GetModel( "GPEA003_MRHO" )
	Local nTamPD		:= GetSx3Cache("RV_COD", "X3_TAMANHO")

	lRet := ExistCpo( "SRV" )

	If lRet
		DbSelectArea( "SRV" )
		DbSetOrder( RetOrdem( "SRV", "RV_FILIAL+RV_COD" ) )
		DbSeek( xFilial( "SRV" ) + M->RHO_PD, .F. )
		oStruct:LoadValue("RHO_DESCPD", SRV->RV_DESC )
	Else
		oStruct:LoadValue("RHO_DESCPD", Space(nTamPD))
	EndIf
	RestArea( aArea )

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ A003_COMP		³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Validacao da Competencia de Pagamento                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function A003_COMP()
	Local aArea		:= GetArea()

	Local lRet		:= .T.
	Local cMesAtual := ""
	Local cRoteiro := If(SRA->RA_CATFUNC $ 'A|P',fGetCalcRot('9'),fGetCalcRot('1'))

	If Type("aPerAtual") == "U" .or. Empty(aPerAtual) .or. !(aPerAtual[1,8] == SRA->RA_PROCES)
	   	If fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRoteiro )
			cMesAtual := AnoMes(aPerAtual[1,6])
		Else
			Help(,,'HELP',,OemToAnsi(STR0015),1,0)	//"Período informado não cadastrado ou já foi fechado"
			lRet := .F.
		EndIf
	EndIf

    If lRet .and. M->RHO_COMPPG < cMesAtual
    	Help(,,'HELP',,OemToAnsi(STR0008),1,0)	//"Competencia de Pagamento devera ser igual ou maior a Competencia da Folha!"
    	lRet := .F.
    EndIf

	RestArea( aArea )

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ GPA003_ORIG	³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Validacao da Origem da Informacao                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPA003_ORIG()
	Local aArea		:= GetArea()

	Local lRet		:= .T.

	Local oModel 		:= FWModelActive()
	Local oStruct		:= oModel:GetModel( "GPEA003_MRHO" )

	oStruct:LoadValue("RHO_CODIGO", Space(GetSx3Cache("RHO_CODIGO", "X3_TAMANHO"))  )
	oStruct:LoadValue("RHO_NOME", Space(GetSx3Cache("RHO_NOME", "X3_TAMANHO")) )
	If M->RHO_ORIGEM == "1"
		oStruct:LoadValue("RHO_NOME", SRA->RA_NOME )
	EndIf

	RestArea( aArea )

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ InitPD_A003    ³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Inicializador Padrao Verba                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function InitPD_A003()
	Local aArea		:= GetArea()

	Local cRet		:= ""

	Local oModel 		:= FWModelActive()
	Local oStruct		:= oModel:GetModel( "GPEA003_MRHO" )

	If oStruct:GetLine() > 0

		cRet := Space(GetSx3Cache("RV_DESC", "X3_TAMANHO"))
		Return( cRet )

	EndIf

	cRet := fDesc( "SRV" , RHO->RHO_PD, "RV_DESC" )

	RestArea( aArea )

Return( cRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ GPE_DEPAGR     ³Autor³  Mauricio Takakura³ Data ³14/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Consulta Padrao para direcionar ao Dependente ou Agregado   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPE_DEPAGR()

	Local cOrigem	:= ""

	Local lRet 			:= .T.

	Local oModel 		:= FWModelActive()
	Local oStruct

	Private cTpForn	:= ""
	Private cCodFor	:= ""

	If ReadVar() == "M->RHO_CODIGO"
		oStruct	:= oModel:GetModel( "GPEA003_MRHO" )
		cOrigem := oStruct:GetValue( "RHO_ORIGEM" )
		cTpForn	:= oStruct:GetValue( "RHO_TPFORN" )
		cCodFor	:= oStruct:GetValue( "RHO_CODFOR" )
	ElseIf ReadVar() == "M->RHN_CODIGO"
		oStruct		:= oModel:GetModel( "GPEA002_MRHN" )
		cOrigem := oStruct:GetValue( "RHN_ORIGEM" )
		cTpForn	:= oStruct:GetValue( "RHN_TPFORN" )
		cCodFor	:= oStruct:GetValue( "RHN_CODFOR" )
	EndIf
	If cOrigem == "2"
		lRet := GPE_DEP()
		If ! lRet
			VAR_IXB := Space(GetSx3Cache("RHL_CODIGO", "X3_TAMANHO"))
		EndIf
	Elseif cOrigem == "3"

		lRet := ConPad1(,,,"RHM" )
		If lRet
			VAR_IXB := RHM->RHM_CODIGO
		Else
			VAR_IXB := Space(GetSx3Cache("RHM_CODIGO", "X3_TAMANHO"))
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc}GPE_DEP
Consulta padrão para planos ativos dos dependentes
@Author Cícero Alves
@Since 14/04/2015
@Version P11.8
/*/
Function GPE_DEP()

	Local aArea		:= GetArea()
	Local aObjCoords:= {}
	Local aAdvSize	:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize 	:= {}
	Local aAvFields	:= {}
	Local aPDFields	:= {}
	Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
	Local aOfuscaCpo:= {}
	Local lOK     	:= .F.
	Local lPerComp	:= Empty(xFilial("RHL"))
	Local nPosLbxA	:= 0.00
	Local oDlg		:= NIL
	Local oLbxA		:= NIL
	Local nOpca		:= 0
	Local nX		:= 0
	Local nPos		:= 0
	Local bSet15 := {|| NIL}
	Local bSet24 := {|| NIL}

	Local oModel 	:= FWModelActive()
	Local oStructG
	Local oStructH

	Local cMat := ""
	Local cTpForn	:= ""
	Local cCodFor	:= ""
	Local cNome := ""
	Local cCodigo := ""
	local Filial := ""

	aLbxA := {}

	VAR_IXB := ""

	oStructG:= oModel:GetModel( "GPEA003_MRHO" )
	oStructH:= oModel:GetModel( "GPEA003_MSRA" )

	cMat := oStructH:GetValue( "RA_MAT" )

	cTpForn	:= oStructG:GetValue( "RHO_TPFORN" )
	cCodFor	:= oStructG:GetValue( "RHO_CODFOR" )


	dbSelectArea("RHL")
	RHL->(dbSetOrder(1))

	if RHL->(dbSeek(xFilial("RHL") + cMat + cTpForn + cCodFor))

		While RHL->(! EOF()).AND. RHL_MAT == cMat .and. RHL_TPFORN = cTpForn .and. RHL_CODFOR = cCodFor

			Filial := RHL_FILIAL
			cCodigo := RHL_CODIGO

			dbSelectArea("SRB")
			SRB->(dbSetOrder(1))
				If SRB->(dbSeek(xFilial("SRB") + cMat))
					While SRB->(! EOF()) .AND. RB_MAT == cMat
						If cCodigo == RB_COD
							cNome := RB_NOME
							EXIT
						EndIf
						SRB->(dbSkip())
					EndDo
				EndIf
			SRB->(dbCloseArea())


			if lPerComp
				aAdd( aLbxA, { RHL_CODIGO,  cNome} )
			else
				aAdd( aLbxA, { Filial, cCodigo, cNome } )
			EndIf
			RHL->(dbSkip())
		EndDo
	Endif

	RHL->(dbCloseArea())

	dbSelectArea("RHN")
	RHN->(dbSetOrder(1))

	if RHN->(dbSeek(xFilial("RHN") + cMat))

		While RHN->(! EOF()).AND. RHN_MAT == cMat

			If RHN_TPFORN = cTpForn .and. RHN_CODFOR = cCodFor

				 If (RHN->RHN_OPERAC + RHN->RHN_ORIGEM + RHN->RHN_TPALT == "2"+ "2" + "04") ;
					.OR. ;
					(RHN->RHN_OPERAC + RHN->RHN_ORIGEM + RHN->RHN_TPALT == "1"+ "2" + "01") .AND.  FUNNAME() == "GPEA003" ;
					.OR. ;
					(RHN->RHN_ORIGEM + RHN->RHN_TPALT == "2" + "04") .AND.  FUNNAME() == "GPEA003"

					Filial := RHN_FILIAL
					cCodigo := RHN_CODIGO

					dbSelectArea("SRB")
					SRB->(dbSetOrder(1))
						If SRB->(dbSeek(xFilial("SRB") + cMat + cCodigo))
							cNome := RB_NOME
						EndIf
					SRB->(dbCloseArea())


					if lPerComp
						aAdd( aLbxA, { RHN_CODIGO,  cNome} )
					else
						aAdd( aLbxA, { Filial, cCodigo, cNome } )
					EndIf

				EndIf

			EndIf

			RHN->(dbSkip())
		EndDo
	Endif

	RHN->(dbCloseArea())

	If Empty(aLbxA)
		If lPerComp
			aAdd( aLbxA , {'',''} )
		Else
			aAdd( aLbxA , {'','',''} )
		EndIf
	EndIf


	aAdvSize		:= MsAdvSize( , .T., 390)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 15 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )


	//Abaixo utilizamos o tamanho da janela como na versão 10, pois cada objeto tem seu posicionamento específico,
	//o cada qual eh realocado conforme a resolução da tela do usuário
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0016 ) PIXEL		// "Planos ativos dependentes"

	    If lPerComp
			@ aObjSize[1,1], aObjSize[1,2] LISTBOX oLbxA FIELDS HEADER GetSx3Cache("RHL_CODIGO", "X3_TITULO"), GetSx3Cache("RHL_NOME", "X3_TITULO"),;
			SIZE 290,130 OF oDlg PIXEL ON DBLCLICK ( lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End() )
		Else
			@ aObjSize[1,1], aObjSize[1,2] LISTBOX oLbxA FIELDS HEADER GetSx3Cache("RHL_FILIAL", "X3_TITULO"),GetSx3Cache("RHL_CODIGO", "X3_TITULO"), GetSx3Cache("RHL_NOME", "X3_TITULO"),;
			SIZE 290,130 OF oDlg PIXEL ON DBLCLICK ( lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End() )
		EndIf

		oLbxA:SetArray(aLbxA)
		If lPerComp
			oLbxA:bLine := { || {aLbxA[oLbxA:nAt,1],aLbxA[oLbxA:nAt,2]}}
		Else
			oLbxA:bLine := { || {aLbxA[oLbxA:nAt,1], aLbxA[oLbxA:nAt,2], aLbxA[oLbxA:nAt,3]}}
		EndIf

		bSet15 := { || nOpca := 1, lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End()}
		bSet24 := { || nOpca := 0, lOk := .F., oDlg:End() }

		//Protecao de Dados Sensiveis
		If aOfusca[2]
			oLbxA:lObfuscate := .T.
			aAvFields := {"RHL_CODIGO","RB_COD","RHN_CODIGO", "RHL_NOME","RB_NOME","RHN_NOME"}
			aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList(aAvFields)
			If lPerComp
				aOfuscaCpo := { .F.,.F. }
			Else
				aOfuscaCpo := { .F.,.F.,.F. }
			EndIf
			For nX := 1 to Len(aPDFields)
				nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
				If nPos < 4 //CODIGO
					If lPerComp
						aOfuscaCpo[1] := .T.
					Else
						aOfuscaCpo[2] := .T.
					EndIf
				ElseIf nPos > 3 //NOME
					If lPerComp
						aOfuscaCpo[2] := .T.
					Else
						aOfuscaCpo[3] := .T.
					EndIf
				EndIf
			Next nX
			oLbxA:aObfuscatedCols := aOfuscaCpo
		EndIf

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, bSet15, bSet24))

	If lOk
		If lPerComp
			VAR_IXB	:= aLbxA[nPosLbxA,1]
		Else
			VAR_IXB	:= aLbxA[nPosLbxA,2]
		EndIf
	EndIf

	RestArea( aArea )

Return lOk
/*/{Protheus.doc}VLDLANCT
Validação de exclusão de registros.
@Author Totvs
@Since  06/05/2016
@Version P11.8
/*/
Function VLDLANCT(oView)
Local lRet	:= .T.
Local aArea		:= GetArea()
Local oModel	:= oView:GetModel('GPEA003_MRHO')
Local nOper		:= oModel:GetOperation()

oModel:Activate()

If nOper == 5
	If oModel:IsEmpty()
		Help(,,'HELP',,OemToAnsi(STR0017),1,0)	//"Não há lançamentos para este Funcionário"
		lRet:= .F.
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc}Gp003IniMod
Pré-inicialização e troca de nOperation
@Author raquel.andrade
@Since  15/11/2016
@Version P12.1.15
/*/
Function Gp003IniMod(oModel,nOperacao)
Local aArea := GetArea()
cFilOld 	:=  If( Type("cFilOld") == "U" ,cFilAnt, cFilOld)

If !(IsInCallStack("CFG600lmdl")) .And. nOperacao == 3
	oModel:SetOperation( 4 )
	cFilOld := cFilAnt
	cFilAnt := SRA->RA_FILIAL
EndIf

RestArea(aArea)

Return .T.

Static Function fCommit003(oModel)
Local aArea      	:= GetArea()

FWFormCommit( oModel ) 						//--Grava model
cFilAnt := cFilOld

RestArea(aArea)

Return .T.

Static Function fCancel003(oModel)
Local aArea      	:= GetArea()

cFilAnt := cFilOld
RestArea(aArea)

Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fVldCPF  ³Autor³  Silvio C. Stecca³ Data ³11/06/2019³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Valida se o CPF do Titular esta preechido                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Static Function fVldCPF()

	Local aArea		:= GetArea()
	Local oModel 	:= FWModelActive()
	Local oStruct	:= oModel:GetModel( "GPEA003_MRHO" )

	If oStruct:GetLine() > 0
		If oStruct:GetValue("RHO_ORIGEM") == "1" .And. Empty(oStruct:GetValue("RHO_CPF"))
			oStruct:SetValue("RHO_CPF"	, SRA->RA_CIC)
		EndIf
	EndIf

	RestArea( aArea )

Return ()

/*/{Protheus.doc} RHO_LinhaPre
Valida edição da linha
@author Allyson Mesashi
@since 01/10/2021
@version P12.1.27
/*/
Static Function RHO_LinhaPre(oStruct, nLine, cAction)

Local lRet := .T.

If RHO->( ColumnPos("RHO_PERORI") ) > 0 .And. oStruct:GetValue( "RHO_PERORI" ) == "2"
	If cAction == "DELETE"
		Help(,,'HELP',,OemToAnsi(STR0018),1,0)	//"Não é permitido excluir lançamento de coparticipação originado de período anterior."
		lRet := .F.
	ElseIf cAction == "CANSETVALUE"
		Help(,,'HELP',,OemToAnsi(STR0019),1,0)	//"Não é permitido alterar lançamento de coparticipação originado de período anterior."
		lRet := .F.
	EndIf
EndIf

If cAction == "DELETE" .OR. cAction == "UNDELETE"
	oModel := oStruct:GetModel('GPEA003_MSRA')
	nRemanesc := calculaSaldo(oStruct,nLine,cAction)
	if nRemanesc > 0 
		oModel:GetModel('GPEA003_MSRA'):LoadValue("RHO_SALDO",nRemanesc)
	endif
Endif

Return( lRet )


/*/{Protheus.doc} fTudOk003
Tudo Ok do Model
@author Allyson Mesashi
@since 06/10/2021
@version P12.1.27
/*/
Static Function fTudOk003(oModel)

Local lRet 			:= .T.
Local lTemPerOri	:= RHO->( ColumnPos("RHO_PERORI") ) > 0
Local nLenGrid		:= 0
Local nLinha		:= 0
Local nOperation	:= oModel:GetOperation()
Local oGrid			:= oModel:GetModel("GPEA003_MRHO")

nLenGrid  := oGrid:Length()

If lTemPerOri .And. nOperation == MODEL_OPERATION_DELETE
	For nLinha := 1 To nLenGrid
		oGrid:GoLine(nLinha)
		If oGrid:GetValue("RHO_PERORI") == "2"
			Help(,,'HELP',,OemToAnsi(STR0018),1,0)	//"Não é permitido excluir lançamento de coparticipação originado de período anterior."
			lRet := .F.
			Exit
		EndIf
	Next nLinha
EndIf

Return lRet 

/*/{Protheus.doc} triggSld(oModel)
	Altera o campo RHO_SALDO do cabeçalho conforme a alteração dos valores na grid.
	@type  Static Function
	@author gustavo.baptista
	@since 22/11/2021
/*/
Static Function triggSld(oModel)
	Local oModelCbc := oModel:GetModel('GPEA003_MSRA')
	Local nRemanesc := 0

	nRemanesc := calculaSaldo(oModel)

	if nRemanesc > 0 
		oModelCbc:GetModel('GPEA003_MSRA'):LoadValue("RHO_SALDO",nRemanesc)
	endif
Return

/*/{Protheus.doc} iniPadSld(oModel)
	Inicializa o campo RHO_SALDO do cabeçalho
	@type  Static Function
	@author gustavo.baptista
	@since 22/11/2021
/*/
Static Function iniPadSld(oModel)
	
	Local oModelDet := oModel:GetModel('GPEA003_MRHO')
	Local oModelCbc := oModel:GetModel('GPEA003_MSRA')
	Local nRemanesc := 0

	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		nRemanesc := calculaSaldo(oModelDet)

		if nRemanesc > 0 
			oModelCbc:LoadValue("RHO_SALDO",nRemanesc)
		endif
	EndIf

Return .T.

/*/{Protheus.doc} calculaSaldo
	Passa em todas as linhas do grid e calcula o saldo devedor do funcionário, ou seja: RHO_SALDO - RHO_VLRFUN
	@type  Static Function
	@author gustavo.baptista
	@since 19/11/2021
/*/
Static Function calculaSaldo(oModelDet,nline,nOper)
	
	Local nLintemp 	:= oModelDet:GetLine()
	Local nX 		:= 0
	Local nRemanesc := 0
	Local cTpLan 	:= "1"
	Local lConsidera  := .T.

	Default nLine :=0
	Default nOper :=""

	For nX := 1 to oModelDet:GetQtdLine()
		oModelDet:GoLine(nX)  //Vai pra primeira linha para varrer o grid de regiao.
		cTpLan := oModelDet:GetValue('RHO_TPLAN')
		lConsidera:= .T.
		
		if nOper == "UNDELETE"
			if oModelDet:ISDELETED()
				if nline != nX
					lConsidera:= .F.
				ENDIF
			endif
		endif
		if nOper == "DELETE"
			lConsidera:= !(oModelDet:ISDELETED()  .OR. nline == nx)
		endif
		if nOper == ''
			lConsidera:= !oModelDet:ISDELETED()
		endif
		if Alltrim(cTpLan) == "1" .and. lConsidera
			nSaldo  := oModelDet:GetValue('RHO_SALDO')
			nRemanesc += nSaldo 
		endif

	Next nx
	oModelDet:GoLine(nLintemp)

Return nRemanesc
