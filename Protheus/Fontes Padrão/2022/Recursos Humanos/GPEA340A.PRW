#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA340.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o     Ё GPEA340A   Ё Autor Ё Mauricio Takakura            Ё Data Ё 17/11/10     Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o  Ё Cadastro de Sindicatos em MVC                                           Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe    Ё GPEA340()                                                               Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso       Ё Generico ( DOS e Windows )                                              Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.                           Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддддддддддбддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC                    Ё  Motivo da Alteracao              Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддддддддддеддддддддддддддддддддддддддддддддддд╢╠╠
*/
Function GPEA340A()

	Local oMBrowse
	Local cFiltraRh

	//--Altera o Set Epch para 1920
	nEpoca := SET( 5,1920)

	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias("RCE")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Cadastro de Sindicatos"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cFiltraRh := CHKRH("GPEA340","RCE","1")
	oMBrowse:SetFilterDefault( cFiltraRh )

	oMBrowse:Activate()

	//--Retornar Set Epoch Padrao
	SET(5,nEpoca)

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Mauricio TakakuraЁ Data Ё17/11/2010Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse                                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA340                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA340A" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA340A" 		OPERATION 4 ACCESS 0				//'Alterar'

Return aRotina

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Mauricio TakakuraЁ Data Ё17/11/2010Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA340                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()
Local oModel := FWLoadModel( "GPEA340" )
Return( oModel )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Mauricio TakakuraЁ Data Ё17/11/2010Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA340                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()
Local oView 	:= FWFormView():New()
Local oModel	:= FWLoadModel("GPEA340")
Local oStructRCE:= FWFormStruct(2, "RCE",{|cCampo|  AllTrim(cCampo) $ "|RCE_MED01|RCE_MED02|RCE_MED03|RCE_MED04|"})
Local oStruct	:= FWFormStruct(2, "RCE",{|cCampo|  AllTrim(cCampo) $ "|RCE_CODIGO|RCE_DESCRI|"})
Local nI 		:= 1

oView:SetModel(oModel)

oStruct:SetProperty('RCE_CODIGO', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetProperty('RCE_DESCRI', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetNofolder()
oView:AddField("GPEA340_RCE", oStruct,"GPEA340_RCE")
oView:AddField("GPEA340_1", oStructRCE,"GPEA340_RCE")
oView:CreateHorizontalBox("FIELDS", 10)
oView:CreateHorizontalBox("FIELDS1", 90)
oView:SetOwnerView("GPEA340_RCE", "FIELDS")
oView:SetOwnerView('GPEA340_1', 'FIELDS1')
Return oView
