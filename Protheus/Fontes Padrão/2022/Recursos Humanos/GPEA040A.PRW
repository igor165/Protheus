#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA040.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o     Ё GPEA040A   Ё Autor Ё Mauricio Takakura            Ё Data Ё 17/11/10     Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o  Ё Cadastro de Verbas em MVC                                           Ё╠╠
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
Function GPEA040A()

	Local oMBrowse
	Local cFiltraRh

	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias( "SRV" )
	oMBrowse:SetDescription( OemToAnsi( STR0009 ) ) //"Cadastro de Verbas"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cFiltraRh := CHKRH("GPEA040","SRV","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	oMBrowse:Activate()

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
	ADD OPTION aRotina TITLE STR0005				ACTION 'VIEWDEF.GPEA040A' 			OPERATION 2 ACCESS 0 				// "Visualizar"
	ADD OPTION aRotina TITLE STR0007 				ACTION 'VIEWDEF.GPEA040A'	 		OPERATION 4 ACCESS 0 				// "Alterar"

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
Local oModel := FWLoadModel( "GPEA040" )
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
Local oModel	:= FWLoadModel("GPEA040")
Local oStructSRV:= FWFormStruct(2, "SRV",{|cCampo|  AllTrim(cCampo) $ "|RV_MED13|RV_MEDFER|RV_MEDAVI|RV_GRAMED|RV_CONVCOL|RV_MEDREAJ|"})
Local oStruct	:= FWFormStruct(2, "SRV",{|cCampo|  AllTrim(cCampo) $ "|RV_COD|RV_DESC|"})
Local nI 		:= 1

oView:SetModel(oModel)

oStruct:SetProperty('RV_COD', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetProperty('RV_DESC', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetNofolder()
oView:AddField("GPEA040_SRV", oStruct,"SRVMASTER")
oView:AddField("GPEA040_1", oStructSRV,"SRVMASTER")
oView:CreateHorizontalBox("FIELDS", 10)
oView:CreateHorizontalBox("FIELDS1", 90)
oView:SetOwnerView("GPEA040_SRV", "FIELDS")
oView:SetOwnerView('GPEA040_1', 'FIELDS1')
Return oView
