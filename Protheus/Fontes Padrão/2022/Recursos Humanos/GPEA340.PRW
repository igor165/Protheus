#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA340.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ GPEA340    ³ Autor ³ Mauricio Takakura            ³ Data ³ 17/11/10     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Cadastro de Sindicatos em MVC                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ GPEA340()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Generico ( DOS e Windows )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ FNC                    ³  Motivo da Alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car. ³03/07/2014³TPUSXB-00000017461/2014 ³Serão efetuadas as validadações nos³±±
±±³             ³          ³                        ³campos desconto minimo/desconto ma-³±±
±±³             ³          ³                        ³ximo assistencial/confederativa/men³±±
±±³             ³          ³                        ³salidade sindical, ano/mes referên-³±±
±±³             ³          ³                        ³cia cálculo, data inicial e final  ³±±
±±³             ³          ³                        ³adic.tem.ser. anuênio, biênio, triê³±±
±±³             ³          ³                        ³nio, quadriênio e quinquênio.      ³±±
±±³Raquel Hager ³08/07/2014³TPZTB0                  ³Inclusao de replicas versao 11     ³±±
±±³             ³          ³                        ³com itens  do eSocial.             ³±±
±±³Cecilia Car. ³16/07/2014³TPUSXB-00000017461/2014 ³Incluida validacao para limpar o   ³±±
±±³             ³          ³                        ³campo Ano/Mes Ref (PLR) quando for ³±±
±±³             ³          ³                        ³selecionada a opcao 3 ou 4 da base ³±±
±±³             ³          ³                        ³de calculo do PLR.                 ³±±
±±³Flavio Corr  ³19/03/15  ³PCREQ-4163              ³Integração Mensagem Unica          ³±±
±±³Christiane V.³31/07/2015³PCDEF-52539             ³Alteração da mensagem do CNPJ      ³±±
±±³Allyson M    ³05/01/2016³TUCOAO                  ³Ajuste p/ validacao dos campos de  ³±±
±±³             ³          ³                        ³limite de % dos adicionais.        ³±±
±±³M. Silveira  ³03/02/2017³MRH-6040                ³Ajuste no cpo RCE_DESAFA para poder³±±
±±³             ³          ³                        ³calcular outras contribuicoes.     ³±±
±±³Gabriel A.   ³16/06/2017³DRHPAG-2380             ³Inclusão de tratamento para o campo³±±
±±³             ³          ³                        ³RCE_QTDCAR.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA340()

	Local oMBrowse
	Local cFiltraRh

	//--Altera o Set Epch para 1920
	nEpoca := SET( 5,1920)

	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias("RCE")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Cadastro de Sindicatos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRh := CHKRH("GPEA340","RCE","1")
	oMBrowse:SetFilterDefault( cFiltraRh )

	oMBrowse:Activate()

	//--Retornar Set Epoch Padrao
	SET(5,nEpoca)

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Mauricio Takakura³ Data ³17/11/2010³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Criacao do Menu do Browse                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA340                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA340" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.GPEA340" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA340" 		OPERATION 4 ACCESS 0				//'Alterar'
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.GPEA340" 		OPERATION 5 ACCESS 0				//'Excluir'

Return aRotina

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ModelDef 		³Autor³  Mauricio Takakura³ Data ³17/11/2010³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Modelagem da gravacao.                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA340                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ModelDef()

	Local oModel
	Local oStructRCE
	Local oStructRG4
    Local bCommit		:= { |oMdl| Gp340Grav( oMdl ) }
    Local bValid		:= { |oMdl| gp340TudOk(oMdl) }
    Local lLimPer		:= ColumnPos( "RCE_LIMPAN" ) > 0

	// Criacao do Objeto de Modelagem de dados da tabela RCE //
	oModel	:= MPFormModel():New("GPEA340", NIL, bValid , bCommit )

	oModel:SetDescription( OemToAnsi(STR0001) ) //"Cadastro de Sindicatos"

	// Estrutura de campos do Model //
	oStructRCE := FWFormStruct(1, "RCE")

	If cPaisLoc == "BRA"
		oStructRG4 := FWFormStruct(1, "RG4")
	EndIf

	oStructRCE:RemoveField("RCE_FILIAL")

	If (cPaisLoc == "AUS")
		oStructRCE:RemoveField("RCE_NROSEM")
		oStructRCE:RemoveField("RCE_INI1SM")
		oStructRCE:RemoveField("RCE_FIM1SM")
		oStructRCE:RemoveField("RCE_INI2SM")
		oStructRCE:RemoveField("RCE_FIM2SM")
	EndIf

	oModel:AddFields("GPEA340_RCE", NIL, oStructRCE)

	If cPaisLoc == "BRA"
		oStructRCE:SetProperty( 'RCE_PLRBSC', MODEL_FIELD_VALID, {|oMdl| VldPlrBsc() } )

		oStructRCE:SetProperty( 'RCE_PLRBSC', MODEL_FIELD_WHEN, {|oMdl| HabilitCpo('GPEA340_RCE',"1") } )
		oStructRCE:SetProperty( 'RCE_PLRVLR', MODEL_FIELD_WHEN, {|oMdl| HabilitCpo('GPEA340_RCE',"2") } )
		oStructRCE:SetProperty( 'RCE_PLRPER', MODEL_FIELD_WHEN, {|oMdl| HabilitCpo('GPEA340_RCE',"1") } )
		oStructRCE:SetProperty( 'RCE_PLRMAS', MODEL_FIELD_WHEN, {|oMdl| HabilitCpo('GPEA340_RCE',"1*2","RCE_PLRBSC") } )
		oStructRCE:SetProperty( 'RCE_PLRVMI', MODEL_FIELD_WHEN, {|oMdl| HabilitCpo('GPEA340_RCE',"1") } )
		oStructRCE:SetProperty( 'RCE_PLRVMA', MODEL_FIELD_WHEN, {|oMdl| HabilitCpo('GPEA340_RCE',"1") } )
		oStructRCE:SetProperty( 'RCE_PLRQTD', MODEL_FIELD_WHEN, {|oMdl| HabilitCpo('GPEA340_RCE',"2","RCE_PLRPAR") } )

		//Carlos Eduardo - M12RH01\RQ0313 - 26/07/2013
		oStructRCE:SetProperty( 'RCE_VLRAN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 1)})
		oStructRCE:SetProperty( 'RCE_VLRBI', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 1)})
		oStructRCE:SetProperty( 'RCE_VLRQN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 1)})
		oStructRCE:SetProperty( 'RCE_VLRQR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 1)})
		oStructRCE:SetProperty( 'RCE_VLRTR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 1)})

		oStructRCE:SetProperty( 'RCE_BASCAT', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_PERAN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_PERBI', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_PERTR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_PERQR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_PERQN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_LIMAN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_LIMBI', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_LIMTR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_LIMQR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		oStructRCE:SetProperty( 'RCE_LIMQN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})

		If lLimPer
			oStructRCE:SetProperty( 'RCE_LIMPAN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
			oStructRCE:SetProperty( 'RCE_LIMPBI', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
			oStructRCE:SetProperty( 'RCE_LIMPTR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
			oStructRCE:SetProperty( 'RCE_LIMPQR', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
			oStructRCE:SetProperty( 'RCE_LIMPQN', MODEL_FIELD_WHEN, {|oMdl| ChkTPCATS(oMdl, 2)})
		EndIf

		lUsaSalMin := GetMV("MV_USASMIN")

		If lUsaSalMin
			oStructRCE:SetProperty("RCE_BCALIN", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '1' ))
		Endif

		oModel:AddGrid("GPEA340_RG4", "GPEA340_RCE"/*cOwner*/, oStructRG4 , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*{|oGrid| CargaSR8(oGrid) }bLoad*/)
		oModel:GetModel('GPEA340_RG4'):SetOptional(.T.)
		oModel:SetRelation("GPEA340_RG4",{{"RG4_FILIAL",'xFilial("RG4")'},{"RG4_CODIGO","RCE_CODIGO"}},RG4->(IndexKey()))
	EndIf

	oModel:SetPrimaryKey({"RCE_CODIGO"})

	oModel:GetModel( "GPEA340_RCE" ):SetDescription( OemToAnsi(STR0001) )  //"Cadastro de Sindicatos"

Return( oModel )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ViewDef  		³Autor³  Mauricio Takakura³ Data ³17/11/2010³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Interface com o Usuario                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA340                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ViewDef()
	Local oView
	Local oModel
	Local oStructRCE
	Local lLimPer    := ColumnPos( "RCE_LIMPAN" ) > 0
	Local lQtdCar    := ColumnPos( "RCE_QTDCAR" ) > 0
	Local lF3 		 := .F. //ColumnPos - retirar esse quando descongelar release

	dbSelectArea("SXB")
	SXB->(dbSetOrder(1))
	lF3 := SXB->(dbSeek("RCEDES"))

	// Criacao da Interface //
	oView := FWFormView():New()

	// Vincular o View ao Model //
	oModel := FWLoadModel("GPEA340")
	oStructRCE := FWFormStruct(2, "RCE")

	oStructRCE:RemoveField("RCE_FILIAL")

	// Remoção de campos para localização Austrália
	If (cPaisLoc == "AUS")
		oStructRCE:RemoveField("RCE_NROSEM")
		oStructRCE:RemoveField("RCE_INI1SM")
		oStructRCE:RemoveField("RCE_FIM1SM")
		oStructRCE:RemoveField("RCE_INI2SM")
		oStructRCE:RemoveField("RCE_FIM2SM")
	EndIf

	If cPaisLoc == "BRA"

		oStructRCE:AddGroup( 'Grupo00', OemToAnsi(STR0019) , '', 2 )   	//'Informações Gerais'
		oStructRCE:SetProperty( "RCE_TPCATS" , MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
		oStructRCE:SetProperty( "RCE_BASCAT" , MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
		If lQtdCar
			oStructRCE:SetProperty( "RCE_QTDCAR" , MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
		EndIf

		oStructRCE:AddGroup( 'Grupo01', OemToAnsi(STR0020) , '', 2 )       //'Anuênio'
		oStructRCE:SetProperty( "RCE_VLRAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStructRCE:SetProperty( "RCE_PERAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStructRCE:SetProperty( "RCE_LIMAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStructRCE:SetProperty( "RCE_DTIAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStructRCE:SetProperty( "RCE_DTFAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStructRCE:SetProperty( "RCE_ACUAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStructRCE:SetProperty( "RCE_CARAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )

		oStructRCE:AddGroup( 'Grupo02', OemToAnsi(STR0021) , '', 2 )       //'Biênio'
		oStructRCE:SetProperty( "RCE_VLRBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
		oStructRCE:SetProperty( "RCE_PERBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
		oStructRCE:SetProperty( "RCE_LIMBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
		oStructRCE:SetProperty( "RCE_DTIBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
		oStructRCE:SetProperty( "RCE_DTFBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
		oStructRCE:SetProperty( "RCE_ACUBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
		oStructRCE:SetProperty( "RCE_CARBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )

		oStructRCE:AddGroup( 'Grupo03', OemToAnsi(STR0022) , '', 2 )       //'Triênio'
		oStructRCE:SetProperty( "RCE_VLRTR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
		oStructRCE:SetProperty( "RCE_PERTR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
		oStructRCE:SetProperty( "RCE_LIMTR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
		oStructRCE:SetProperty( "RCE_DTITR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
		oStructRCE:SetProperty( "RCE_DTFTR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
		oStructRCE:SetProperty( "RCE_ACUTR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
		oStructRCE:SetProperty( "RCE_CARTR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )

		oStructRCE:AddGroup( 'Grupo04', OemToAnsi(STR0023) , '', 2 )       //'Quadriênio'
		oStructRCE:SetProperty( "RCE_VLRQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
		oStructRCE:SetProperty( "RCE_PERQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
		oStructRCE:SetProperty( "RCE_LIMQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
		oStructRCE:SetProperty( "RCE_DTIQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
		oStructRCE:SetProperty( "RCE_DTFQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
		oStructRCE:SetProperty( "RCE_ACUQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
		oStructRCE:SetProperty( "RCE_CARQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )

		oStructRCE:AddGroup( 'Grupo05', OemToAnsi(STR0024) , '', 2 )      //'Quinquênio'
		oStructRCE:SetProperty( "RCE_VLRQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )
		oStructRCE:SetProperty( "RCE_PERQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )
		oStructRCE:SetProperty( "RCE_LIMQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )
		oStructRCE:SetProperty( "RCE_DTIQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )
		oStructRCE:SetProperty( "RCE_DTFQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )
		oStructRCE:SetProperty( "RCE_ACUQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )
		oStructRCE:SetProperty( "RCE_CARQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )

		If lLimPer
			oStructRCE:SetProperty( "RCE_LIMPAN" , MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStructRCE:SetProperty( "RCE_LIMPBI" , MVC_VIEW_GROUP_NUMBER , 'Grupo02' )
			oStructRCE:SetProperty( "RCE_LIMPTR" , MVC_VIEW_GROUP_NUMBER , 'Grupo03' )
			oStructRCE:SetProperty( "RCE_LIMPQR" , MVC_VIEW_GROUP_NUMBER , 'Grupo04' )
			oStructRCE:SetProperty( "RCE_LIMPQN" , MVC_VIEW_GROUP_NUMBER , 'Grupo05' )
		EndIf

		oStructRCE:AddGroup( 'Grupo06', OemToAnsi(STR0025) , '', 2 )      //'Periculosidade'
		oStructRCE:SetProperty( "RCE_BCALPE" , MVC_VIEW_GROUP_NUMBER , 'Grupo06' )
		oStructRCE:SetProperty( "RCE_PERPE"  , MVC_VIEW_GROUP_NUMBER , 'Grupo06' )

		oStructRCE:AddGroup( 'Grupo07', OemToAnsi(STR0026) , '', 2 )      //'Insalubridade'
		oStructRCE:SetProperty( "RCE_BCALIN" , MVC_VIEW_GROUP_NUMBER , 'Grupo07' )
		oStructRCE:SetProperty( "RCE_PINSMI" , MVC_VIEW_GROUP_NUMBER , 'Grupo07' )
		oStructRCE:SetProperty( "RCE_PINSME" , MVC_VIEW_GROUP_NUMBER , 'Grupo07' )
		oStructRCE:SetProperty( "RCE_PINSMA" , MVC_VIEW_GROUP_NUMBER , 'Grupo07' )

		If RCE->(ColumnPos("RCE_DESAFA")) > 0 .And. TamSX3("RCE_DESAFA")[1] == 3 .And. lF3
			oStructRCE:SetProperty('RCE_DESAFA' , MVC_VIEW_LOOKUP, "RCEDES" )
		EndIf
	EndIf

	oView:SetModel(oModel)
	oView:AddField("GPEA340_RCE", oStructRCE)

  	oView:CreateHorizontalBox("FIELDS", 100)

  	If cPaisLoc == "BRA"
	  	oView:AddUserButton( STR0012, "CLIPS", {|oView| Gp340PLRHist()} )
	  	oView:AddUserButton( "Histórico", "CLIPS", {|oView| Gp340Hist()} )

		If RCE->(ColumnPos("RCE_DESAFA")) > 0 .And. TamSX3("RCE_DESAFA")[1] == 3 .and. !lF3
			oView:SetFieldAction( "RCE_DESAFA", { || fOpDescAfa(.F.), oView:Refresh() } )
		EndIf
	EndIf

	oView:SetOwnerView("GPEA340_RCE", "FIELDS")


Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp340Grav   ³ Autor ³ IP-Inovacao           ³ Data ³ 04/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pelo commit do Cadastro de Sindicatos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp340Grav( oMdlSQ3 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA340                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp340Grav( oMdlSQ3 )
Local lTSREP	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Local nOperation

Local lJob		:= .F.

Private oObjREP	:= Nil

//-- Inicializa a integracao via WebServices TSA
If lTSREP
	oObjREP := PTSREPOBJ():New()
Endif

// Seta qual é a operacao corrente
nOperation := oMdlSQ3:GetOperation()

If cPaisLoc == "BRA" .and. nOperation == 4 //--Alteracao - Grava historico dos campos alterados
	fGrvHist(oMdlSQ3)

	if oMdlSQ3:GetModel("GPEA340_RCE"):GetValue("RCE_MESDIS") <> RCE->RCE_MESDIS
		lJob := .T.
	EndIf
EndIf

/* Realiza os tratamentos necessarios para gravacao dos formularios de edicao. A Gravacao e
realizada em niveis onde o primeiro elemento do modelo e posteriormente seus filhos sao gravados.*/
FWFormCommit( oMdlSQ3 )

    // Integracao PIMS GRAOS
If (nOperation == 3 .OR. nOperation == 4)

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Executa o WebServices TSA - Sindicato                        ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lTSREP .And. oObjREP:WSSindicatoLegal( 1 )
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Grava o ontrole de exportacao para o TSA - Sindicato         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		oObjRep:WSUpdRHExp( "RCE" )
	Endif

ElseIf (nOperation == 5)

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Executa o WebServices TSA - Sindicato                        ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lTSREP .And. oObjREP:WSSindicatoLegal( 3 )
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Grava o ontrole de exportacao para o TSA - Sindicato         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		oObjRep:WSUpdRHExp( "RCE" )
	Endif

EndIf

IF lJob
	GRVRJB()
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp340PLRHist³ Autor ³ Leandro Drumond       ³ Data ³ 01/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel por exibir o historico de PLR do sindicato³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp340PLRHist( )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil					                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA340                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp340PLRHist()

Local oView			:= Nil
Local oStructRG4 	:= Nil
Local oModel		:= FwLoadModel("GPEA340")

oView := FWFormView():New()

oStructRG4 := FWFormStruct(2,"RG4") 		//Item

oStructRG4:RemoveField("RG4_CAMPO")
oStructRG4:RemoveField("RG4_CONTEU")
oStructRG4:RemoveField("RG4_USER")
oStructRG4:RemoveField("RG4_TIPO")
oStructRG4:RemoveField("RG4_NCAMPO")
//
oStructRG4:SetProperty( "RG4_PLRTPC" , MVC_VIEW_CANCHANGE  , .F. )
oStructRG4:SetProperty( "RG4_PLRBSC" , MVC_VIEW_CANCHANGE  , .F. )
oStructRG4:SetProperty( "RG4_PLRVLR" , MVC_VIEW_CANCHANGE  , .F. )
oStructRG4:SetProperty( "RG4_PLRPER" , MVC_VIEW_CANCHANGE  , .F. )
oStructRG4:SetProperty( "RG4_PLRVMI" , MVC_VIEW_CANCHANGE  , .F. )
oStructRG4:SetProperty( "RG4_PLRVMA" , MVC_VIEW_CANCHANGE  , .F. )
oStructRG4:SetProperty( "RG4_PLRMAS" , MVC_VIEW_CANCHANGE  , .F. )

oModel:SetRelation("GPEA340_RG4",{{"RG4_FILIAL",'xFilial("RG4")'},{"RG4_CODIGO","RCE_CODIGO"},{"RG4_TIPO","'1'"}},RG4->(IndexKey()))

oView:SetModel(oModel)

oView:AddGrid("GPEA340_RG4", oStructRG4)

oView:CreateHorizontalBox("RG4", 100)

oView:SetOwnerView("GPEA340_RG4", "RG4")



oView:EnableControlBar(.T.)
oView:SetOperation(4)

oFWMVCWindow := FWMVCWindow():New()

oFWMVCWindow:SetUseControlBar(.T.)
oFWMVCWindow:SetView(oView)
oFWMVCWindow:SetCentered(.T.)
oFWMVCWindow:SetPos(0,0)
oFWMVCWindow:SetSize(380,700)
oFWMVCWindow:SetTitle(STR0012)//'Histórico de PLR'
oFWMVCWindow:Activate()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp340Hist   ³ Autor ³ Leandro Drumond       ³ Data ³ 10/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel por exibir o historico do sindicato		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp340Hist( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil					                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA340                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp340Hist()

Local oView			:= Nil
Local oStructRG4 	:= Nil
Local oModel		:= FwLoadModel("GPEA340")

oView := FWFormView():New()

oStructRG4 := FWFormStruct(2,"RG4") 		//Item

oStructRG4:RemoveField("RG4_PLRTPC")
oStructRG4:RemoveField("RG4_PLRBSC")
oStructRG4:RemoveField("RG4_PLRVLR")
oStructRG4:RemoveField("RG4_PLRPER")
oStructRG4:RemoveField("RG4_PLRVMI")
oStructRG4:RemoveField("RG4_PLRVMA")
oStructRG4:RemoveField("RG4_PLRMAS")
oStructRG4:RemoveField("RG4_PLRARC")
oStructRG4:RemoveField("RG4_PLRAMP")
oStructRG4:RemoveField("RG4_TIPO")

oStructRG4:SetProperty( "RG4_CAMPO" , MVC_VIEW_CANCHANGE  , .F. )
oStructRG4:SetProperty( "RG4_USER" , MVC_VIEW_CANCHANGE  , .F. )


oModel:SetRelation("GPEA340_RG4",{{"RG4_FILIAL",'xFilial("RG4")'},{"RG4_CODIGO","RCE_CODIGO"},{"RG4_TIPO","'2'"}},RG4->(IndexKey()))

oMdlAux:= oModel:GetModel('GPEA340_RG4')
oStructAux:= oMdlAux:GetStruct()
oStructAux:SetProperty('RG4_PLRTPC', 10 , .F.)
oStructAux:SetProperty('RG4_PLRARC', 10 , .F.)

oView:SetModel(oModel)

oView:AddGrid("GPEA340_RG4", oStructRG4)

oView:CreateHorizontalBox("RG4", 100)

oView:SetOwnerView("GPEA340_RG4", "RG4")

oView:EnableControlBar(.T.)
oView:SetOperation(4)

oFWMVCWindow := FWMVCWindow():New()

oFWMVCWindow:SetUseControlBar(.T.)
oFWMVCWindow:SetView(oView)
oFWMVCWindow:SetCentered(.T.)
oFWMVCWindow:SetPos(0,0)
oFWMVCWindow:SetSize(380,700)
oFWMVCWindow:SetTitle("Histórico")//'Histórico'
oFWMVCWindow:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HabilitCpo    ºAutor ³Leandro Drumond  º Data ³  05/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³WHEN do campo RCE_PLRBSC					                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function HabilitCpo(cExtru,xComp,cCpo)
Local lRet 		:= .F.
Local oMdl     	:= FWModelActive()
Local oMyMdl01  := oMdl:GetModel(cExtru)
Local xMyCod

DEFAULT cCpo := 'RCE_PLRTPC'

If !(oMdl:IsActive())
	oMdl:Activate() //Ativa o model
EndIf

xMyCod := oMyMdl01:GetValue(cCpo)

If xMyCod $ xComp
	lRet := .T.
EndIf

If cCpo == "RCE_PLRBSC" .And. lRet
	If oMyMdl01:GetValue("RCE_PLRTPC") <> "1"
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ChkTPATS      ºAutor ³Carlos E. Oli.   º Data ³  26/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Habilita/desabilita campos no formulario conforme a opcao  º±±
±±º          ³ selecionada no campo RCE_TPCATS.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³WHEN dos campos:                                            º±±
±±º          ³   RCE_VLRAN, RCE_VLRBI, RCE_VLRTR, RCE_VLRQR, RCE_VLRQN,   º±±
±±º          ³   RCE_BASCAT, RCE_PERAN, RCE_PERBI, RCE_PERTR, RCE_PERQR,  º±±
±±º          ³   RCE_PERQN, RCE_LIMAN, RCE_LIMBI, RCE_LIMTR, RCE_LIMQR,   º±±
±±º          ³   RCE_LIMQN                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ChkTPCATS(oModel, nGrupo)

	Local lRet := (nGrupo == 1 .And. oModel:GetValue("RCE_TPCATS") != "1");
					.Or. (nGrupo == 2 .And. oModel:GetValue("RCE_TPCATS") != "3" )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gp340TudOk    ºAutor ³Leandro Drumond  º Data ³  22/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida campos do modelo					                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function gp340TudOk(oModel)
Local lRet		:= .T.
Local oMyMdl01	:= oModel:GetModel("GPEA340_RCE")
Local cAnoMes    := ""
Local cEFDAv:= If( cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), "0")
Local cAliasTmp	:= GetNextAlias()
Local lRet		:= .T.
Local nOp		:= 0

If cPaisLoc == "BRA"
	Begin Sequence

		BeginSQL Alias cAliasTmp
			SELECT RG4_DATA FROM %Table:RG4% RG4
			WHERE RG4.%NotDel%
			AND RG4_FILIAL = %Exp:xFilial("RG4")%
			AND RG4_TIPO = %Exp:'2'%
			AND RG4_DATA > %Exp:DtoS(dDataBase)%
		EndSQL

		If !(cAliasTmp)->(Eof())
			lRet := MsgNoYes( STR0052 )//Já existe histórico de alteração para esse sindicato com data posterior a database atual, se continuar isso irá impactar nos cálculos. Deseja continuar?
		EndIf
		(cAliasTmp)->(DbCloseArea())

		If !lRet
			Help(,,'HELP',,STR0053 ,1,0 )//"Registro não será salvo"
			Break
		EndIf

		If oMyMdl01:GetValue('RCE_PLRTPC') == "1" .and. oMyMdl01:GetValue('RCE_PLRPER') <= 0 //Percentual
			Help(,,'HELP',, STR0013,1,0 ) //"Perc. PLR deve ser informado quando tipo de cálculo da PLR for percentual"
			lRet := .F.
			Break
		EndIf
		If oMyMdl01:GetValue('RCE_PLRTPC') == "2" .and. oMyMdl01:GetValue('RCE_PLRVLR') <= 0 //Valor Fixo
			Help(,,'HELP',, STR0014,1,0 ) //"Vlr. PLR deve ser informado quando tipo de cálculo da PLR for Valor Fixo"
			lRet := .F.
			Break
		EndIf
		If oMyMdl01:GetValue('RCE_PLRTPC') == "1" .and. oMyMdl01:GetValue('RCE_PLRBSC') == "3" .and. oMyMdl01:GetValue('RCE_PISO') <= 0//Percentual -- PISO
			Help(,,'HELP',, STR0015,1,0 ) //"Piso Categ deve ser informado quando tipo de cálculo da PLR for Percentual e Bs. de Cálc. for Piso Sindicato"
			lRet := .F.
			Break
		EndIf
		If oMyMdl01:GetValue('RCE_PLRTPC') $ "1" .and. ( ( Empty( oMyMdl01:GetValue('RCE_PLRMAS') ) .and. oMyMdl01:GetValue('RCE_PLRBSC') $ "1*2" ) .or. Empty( oMyMdl01:GetValue('RCE_PLRARC') ) )
			Help(,,'HELP',, STR0016,1,0 ) //"Mes/ano de referência do salário e Ano de referência para cálculo de PLR devem ser informados"
			lRet := .F.
			Break
		EndIf
		If oMyMdl01:GetValue('RCE_PLRTPC') == "1" .and. Empty(oMyMdl01:GetValue('RCE_PLRBSC'))//Percentual
			Help(,,'HELP',, STR0017,1,0 ) //"Bs. de Calc. deve ser informado quando tipo de cálculo da PLR for Percentual"
			lRet := .F.
			Break
		EndIf
		If oMyMdl01:GetValue('RCE_PLRPAR') == "2" .and. oMyMdl01:GetValue('RCE_PLRQTD') <= 0 //Percentual
			Help(,,'HELP',, STR0018,1,0 ) //"Perc. da primeira parcela deve ser informado quando quantidade de parcelas for diferente de 1"
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_ASSMAX') <> 0 .or. oMyMdl01:GetValue('RCE_ASSMIN') <> 0) .and. (oMyMdl01:GetValue('RCE_ASSMIN') > oMyMdl01:GetValue('RCE_ASSMAX'))
			Help(,,'HELP',, STR0028,1,0 ) //"O valor máximo do desconto da contribuição assistencial não deve ser inferior ao valor do desconto mínimo."
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_CONMAX') <> 0 .or. oMyMdl01:GetValue('RCE_CONMIN') <> 0) .and. (oMyMdl01:GetValue('RCE_CONMIN') > oMyMdl01:GetValue('RCE_CONMAX'))
			Help(,,'HELP',, STR0029,1,0 ) //"O valor máximo do desconto da contribuição confederativa não deve ser inferior ao valor do desconto mínimo."
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_MENMAX') <> 0 .or. oMyMdl01:GetValue('RCE_MENMIN') <> 0) .and. (oMyMdl01:GetValue('RCE_MENMIN') > oMyMdl01:GetValue('RCE_MENMAX'))
			Help(,,'HELP',, STR0030,1,0 ) //"O valor máximo do desconto da mensalidade sindical não deve ser inferior ao valor do desconto mínimo."
			lRet := .F.
			Break
		EndIf
		// Verificar o mes da data
 		cAnoMes := oMyMdl01:GetValue('RCE_PLRMAS')
		If !Empty(cAnoMes)
			If 	Val(Substr(cAnoMes,5,2)) < 1 .Or. ;
				Val(Substr(cAnoMes,5,2)) > 12
				Help(,,'HELP',, STR0031,1,0 ) //"Mês do campo Ano/Mês referência deve ser 01 a 12."
				lRet := .F.
				Break
			EndIf
			// Verificar o ano da data
			If 	Val(Substr(cAnoMes,1,4)) == 0 	.Or.;
				Val(Substr(cAnoMes,1,4)) < 1900
				Help(,,'HELP',, STR0032,1,0 ) //"Ano do campo Ano/Mês referência inválido."
				lRet := .F.
				Break
			EndIf
		EndIf
		// Verificar o ano
		If oMyMdl01:GetValue('RCE_PLRTPC') $ "1*2"
			If 	Val(oMyMdl01:GetValue('RCE_PLRARC')) == 0 	.Or.;
				Val(oMyMdl01:GetValue('RCE_PLRARC')) < 1900
				Help(,,'HELP',, STR0033,1,0 ) //"Ano referência p/ cálculo inválido."
				lRet := .F.
				Break
			EndIf
		EndIf
		If (oMyMdl01:GetValue('RCE_DTIAN') <> Ctod("") .and. oMyMdl01:GetValue('RCE_DTFAN') <> Ctod("")) .and. (Dtos(oMyMdl01:GetValue('RCE_DTIAN')) > Dtos(oMyMdl01:GetValue('RCE_DTFAN')))
			Help(,,'HELP',, STR0034,1,0 ) //"A data final de adicional por tempo de serviço para anuênio não deve ser inferior a data inicial"
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_DTIBI') <> Ctod("") .and. oMyMdl01:GetValue('RCE_DTFBI') <> Ctod("")) .and. (Dtos(oMyMdl01:GetValue('RCE_DTIBI')) > Dtos(oMyMdl01:GetValue('RCE_DTFBI')))
			Help(,,'HELP',, STR0035,1,0 ) //"A data final de adicional por tempo de serviço para biênio não deve ser inferior a data inicial"
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_DTITR') <> Ctod("") .and. oMyMdl01:GetValue('RCE_DTFTR') <> Ctod("")) .and. (Dtos(oMyMdl01:GetValue('RCE_DTITR')) > Dtos(oMyMdl01:GetValue('RCE_DTFTR')))
			Help(,,'HELP',, STR0036,1,0 ) //"A data final de adicional por tempo de serviço para triênio não deve ser inferior a data inicial"
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_DTIQR') <> Ctod("") .and. oMyMdl01:GetValue('RCE_DTFQR') <> Ctod("")) .and. (Dtos(oMyMdl01:GetValue('RCE_DTIQR')) > Dtos(oMyMdl01:GetValue('RCE_DTFQR')))
			Help(,,'HELP',, STR0037,1,0 ) //"A data final de adicional por tempo de serviço para quadriênio não deve ser inferior a data inicial"
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_DTIQN') <> Ctod("") .and. oMyMdl01:GetValue('RCE_DTFQN') <> Ctod("")) .and. (Dtos(oMyMdl01:GetValue('RCE_DTIQN')) > Dtos(oMyMdl01:GetValue('RCE_DTFQN')))
			Help(,,'HELP',, STR0038,1,0 ) //"A data final de adicional por tempo de serviço para quinquênio não deve ser inferior a data inicial"
			lRet := .F.
			Break
		EndIf
		If (oMyMdl01:GetValue('RCE_ASSSAL') == "3" .Or. oMyMdl01:GetValue('RCE_CONSAL') == "3" .Or. oMyMdl01:GetValue('RCE_MENSAL') == "3") .And. oMyMdl01:GetValue('RCE_PISO') == 0
			lRet := .F.
			Help(,,'HELP',, STR0041,1,0 ) //"Configure um valor maior que zero para o piso da categoria"
			Break
		EndIf
		//Periculosidade / insalubridade
		If (oMyMdl01:GetValue('RCE_BCALPE') $ "4/7" .Or. oMyMdl01:GetValue('RCE_BCALIN') $ "5/7") .And. Empty(oMyMdl01:GetValue('RCE_UF'))
			lRet := .F.
			Help(,,'HELP',, STR0043,1,0 ) //"Salario mínimo estadual escolhido como base de periculosidade/insalubridade, campo UF obrigatório!"
			Break
		EndIf

		If (oMyMdl01:GetValue('RCE_BCALPE') $ "5/8" .Or. oMyMdl01:GetValue('RCE_BCALIN') $ "6/8") .And. Empty(oMyMdl01:GetValue('RCE_PISO'))
			lRet := .F.
			Help(,,'HELP',, STR0044,1,0 ) //"Piso do sindicato escolhido como base de periculosidade/insalubridade, campo Piso Sindicato obrigatório!"
			Break
		EndIf

		//Gravação da tabela RG4
		If !IsBlind()
		nOp := Aviso(OemToAnsi(STR0010),OemToAnsi(STR0056) + CRLF +  OemToAnsi(STR0059) + CRLF + OemToAnsi(STR0057) + dToC(dDataBase) + CRLF + OemToAnsi(STR0060),{OemToAnsi(STR0058),OemToAnsi(STR0054)})//Os dados alterados são válidos a partir da database atual e pode impactar no cálculo de dissídio.
			If nOp == 1
				lRet := .F.
				shellExecute("Open","http://tdn.totvs.com/x/hB4MEQ", "", "", 1)
				Help(,,'HELP',, OemToAnsi(STR0055),1,0 ) //Operação cancelada pelo usuário
				Break
			EndIf
		EndIF

		// eSocial
		If Empty(oMyMdl01:GetValue( 'RCE_CGC' ))
			If cEFDAv <> "2"
				If cEFDAv == "1"
					Help(,,'HELP',, STR0040,1,0 ) // // "Atencao" ## "O 'CNPJ' do sindicato e um campo obrigatorio - e será impeditivo para gravacao conforme configuracao do parametro MV_EFDAVIS."
					lRet := .F.
					Break
				Else
					MsgInfo(OemToAnsi(STR0039), OemToAnsi(STR0010))  // "Atencao" ## "O 'CNPJ' do sindicato e um campo obrigatorio - mas nao sera impeditivo para gravacao conforme configuracao do parametro MV_EFDAVIS."
					Break
				EndIf
			EndIf
		EndIf

	End Sequence
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGrvHist      ºAutor ³Leandro Drumond  º Data ³  10/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava historico dos campos alterados na RCE                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGrvHist(oModel)
Local aArea		:= GetArea()
Local oMyMdl01	:= oModel:GetModel("GPEA340_RCE")
Local oStruct 	:= oMyMdl01:GetStruct()
Local aAux 		:= oStruct:GetFields()
Local cSind		:= oMyMdl01:GetValue("RCE_CODIGO")
Local cCampo	:= ""
Local cTipo		:= ""
Local cConteudo	:= ""
Local cFilRG4	:= xFilial("RG4")
Local nX		:= 0

DbSelectArea("RG4")
DbSetOrder(2)

For nX := 1 To Len(aAux)
	cCampo 		:= aAux[nX, MODEL_FIELD_IDFIELD ]
	cTipo  		:= aAux[nX, MODEL_FIELD_TIPO ]
	If cTipo == "D"
		cConteudo  	:= DtoC(&("RCE->"+cCampo))
	Else
		cConteudo   := If(cTipo=="N",AllTrim(STR(&("RCE->"+cCampo))),&("RCE->"+cCampo))
	EndIf
	If cTipo $ "C*N*D" .and. cCampo <> "RCE_FILIAL" .and. SubStr(cCampo,5,3) <> "PLR" .and. oMyMdl01:GetValue(cCampo) <> &("RCE->"+cCampo)
		If RG4->(DbSeek(cFilRG4+cSind+"2"+DtoS(dDataBase)+__cUserId+Padr(cCampo,10)))
			RecLock("RG4",.F.)
		Else
			RecLock("RG4",.T.)
		EndIf
		RG4->RG4_FILIAL	:= cFilRG4
		RG4->RG4_CODIGO	:= cSind
		RG4->RG4_TIPO	:= "2"
		RG4->RG4_DATA	:= dDataBase
		RG4->RG4_USER	:= __cUserId
		RG4->RG4_CAMPO	:= cCampo
		RG4->RG4_CONTEU	:= cConteudo
		RG4->(MsUnLock())
	EndIf
Next nX

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA340   ºAutor  ³Microsiga           º Data ³ 16/07/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Usado no Valid do campo RCE_PLRBSC:                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ VldPlrBsc                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VldPlrBsc()
Local lRet := .T.
Local oModel
Local oGrid
Local cMyCod  := ""
Local oView

oView 	:= FWViewActivate()
oModel	:= FWModelActivate()
oGrid  := oModel:GetModel("GPEA340_RCE")
cMyCod := oGrid:GetValue("RCE_PLRBSC")
If	cMyCod == "3" .Or. cMyCod == "4"
	 oGrid:LoadValue( "RCE_PLRMAS", "      " )
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³INTEGDEF  ºAutor  ³                     º Data ³ 23/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para a interação com EAI                             º±±
±±º          ³envio e recebimento                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXml, nType, cTypeMsg, cVersaoMsg )

Local aRet := {}

aRet:= GPEI340( cXml, nType, cTypeMsg, cVersaoMsg )

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fboxPeri  ºAutor  ³                     º Data ³ 19/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cbox do campo RCE_BCALPE                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fboxPeri()
Local cOpcBox := ""
cOpcBox += STR0046//"1=Salario;2=Salario+Verbas;3=Salario Minimo;4=Salario Minimo Estadual;5=Piso Sindicato;6=Salario Minimo + Verbas;7=Salario Minimo Estadual+Verbas;8=Piso Sindicato+Verbas"

Return cOpcBox

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fboxInsal  ºAutor  ³                     º Data ³ 19/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cbox do campo RCE_BCALIN                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fboxInsal()
Local cOpcBox := ""
cOpcBox += STR0047//"1=Salario Minimo;2=Salario;3=Salario+Verbas;4=Salario Minimo+Verbas;5= Salario Minimo Estadual;6=Piso Sindicato;7= Salario Minimo Estadual+Verbas;8=Piso Sindicato+Verbas"

Return cOpcBox

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fOpDescAfa³ Autor ³ Marcelo Silveira      ³ Data ³ 02/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define quais as contribuicoes que poderao ser descontadas  ³±±
±±³          ³ de funcionarios afastados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fOpDescAfa(lF3)

Local cTitulo  := OemToAnsi(STR0048) //"Desconta a contribuição de funcionarios afastados"
Local MvPar    :=""
Local MvParDef :=""
Local lRet     := .T.
Local l1Elem   := .F.
Local lGpa943

Local oModel   := FWModelActive()
DEFAULT lF3		:= .T.

Private aDesc  := {}

aDesc := {;
				OemToAnsi(STR0049),;	//"A - Assistencial"
				OemToAnsi(STR0050),; 	//"C - Confederativa",;
				OemToAnsi(STR0051) } 	//"S - Mensalidade Sindical"

If lF3
	lGpa943 := IsInCallStack("GPEA943")
	VAR_IXB	:= space(3)
	If lGpa943
		MvPar := oModel:GetValue( 'GPEA943_SWY', 'WY_DESAFA')
	Else
		MvPar := oModel:GetValue( 'GPEA340_RCE', 'RCE_DESAFA')
	EndIf
	MvParDef:= "ACS"

	If f_Opcoes(@MvPar,cTitulo,aDesc,MvParDef,,,l1Elem,1,3)
		If MvPar # "M->RCE_DESAFA" .and. MvPar # "M->WY_DESAFA"
			VAR_IXB	:= MvPar
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	Endif
Else
	MvPar := "M->RCE_DESAFA"

	MvParDef:= "ACS"

	f_Opcoes(@MvPar,cTitulo,aDesc,MvParDef,,,l1Elem,1,3)

	If MvPar # "M->RCE_DESAFA"
		oModel:LoadValue( 'GPEA340_RCE', 'RCE_DESAFA', MvPar )
	EndIf
EndIf

Return( lRet )


Static Function GRVRJB()

if ChkFile("RJB") .and. ChkFile("RJC") // se existem as tabelas RJB e RJC, continua com o processamento

	RJB->(DbSetOrder(2)) //RJB_FILIAL+RJB_CODIGO+RJB_FCHAVE+RJB_CHAVE
	RecLock("RJB", .T.)
		RJB->RJB_FILIAL 	:= RCE->RCE_FILIAL
		RJB->RJB_CODIGO 	:= GetSxeNum("RJB", "RJB_CODIGO")
		RJB->RJB_EVENT  	:= "S2206"
		RJB->RJB_TIPO		:= "1" //Atualização Sindicato
		RJB->RJB_STATUS		:= "0" // Pendente
		RJB->RJB_FCHAVE 	:= RCE->RCE_FILIAL
		RJB->RJB_CHAVE		:= RCE->RCE_CODIGO
		RJB->RJB_DTINC		:= dDataBase
	MsUnLock()
	ConfirmSx8()
Endif

Return

/*/{Protheus.doc} fVldRCEDes
	Valid do campo RCE_DESAFA
	@type  Function
	@author gabriel.almeida
	@since 27/11/2019
	@param cConteudo, caracter, conteúdo do campo
	@return lValido, lógico, retorna se a expressão digitada é válida
	/*/
Function fVldRCEDes(cConteudo)
	Local lValido := .T.

	If !( cConteudo $ "ACS|*CS|A*S|**S|AC*|*C*|A*S|A**|***|   |" )
		lValido := .F.
	EndIf
Return lValido
