#include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#include "TRMA140.CH"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё TRMA140  Ё Autor Ё Cristina Ogura             Ё Data Ё 12.11.98 Ё╠╠
╠╠цддддддддддеддддддддддадддддддаддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Cadastro dos Instrutores dos Cursos                             Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                          Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддбддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁData      Ё Programador   Ё FNC  ЁManutencao Efetuada                       Ё╠╠
╠╠цддддддддддедддддддддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё21.07.2014ЁCecilia Carv.  ЁTPZSOXЁIncluido o fonte da 11 para a 12 e efetua-Ё╠╠
╠╠Ё          Ё               Ё      Ёda a limpeza.                             Ё╠╠
╠╠юддддддддддадддддддддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function TRMA140()
	Local cFiltraRh			//Variavel para filtro
	Local oMBrowse

	oMBrowse := FWmBrowse():New()
	oMBrowse:SetAlias( 'RA7' )
	oMBrowse:SetDescription( OemtoAnsi(STR0008) )	//"Cadastro de Instrutores dos Cursos"

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH(FunName(),"RA7","1")

	//Filtro padrao do Browse conforme tabela RA7 (Cadastro de Instrutores dos Cursos)
	oMBrowse:SetFilterDefault(cFiltraRh)
	oMBrowse:Activate()

Return(Nil)

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё26/12/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁTRMA140                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0              	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TRMA140" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TRMA140" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TRMA140" 		OPERATION 4 ACCESS 0				//'Alterar'
	ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TRMA140" 		OPERATION 5 ACCESS 0				//'Excluir'

Return aRotina

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Mauricio TakakuraЁ Data Ё14/06/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁTRMA140                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

	Local oModel
	Local oStructRA7

	// Criacao do Objeto de Modelagem de dados da tabela SRJ //
	oModel     := MPFormModel():New("TRMA140" )
	oModel:SetDescription( OemToAnsi(STR0008) ) //"Cadastro de Instrutores dos Cursos"

	// Estrutura de campos do Model //
	oStructRA7 := FWFormStruct(1, "RA7")
	oStructRA7:RemoveField("RA7_FILIAL")

	oModel:AddFields("TRMA140_RA7", NIL, oStructRA7)

	oModel:GetModel( "TRMA140_RA7" ):SetDescription( OemToAnsi(STR0008) ) //"Cadastro de Instrutores dos Cursos"

Return( oModel )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Mauricio TakakuraЁ Data Ё14/06/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁTRMA140                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()
	Local oView
	Local oModel
	Local oStructRA7

	// Criacao da Interface //
	oView := FWFormView():New()

	// Vincular o View ao Model //
	oModel := FWLoadModel("TRMA140")
	oStructRA7 := FWFormStruct(2, "RA7")

	oStructRA7:RemoveField("RA7_FILIAL")

	oView:SetModel(oModel)
	oView:AddField("TRMA140_RA7", oStructRA7)

	oView:CreateHorizontalBox("FIELDS", 100)

	oView:SetOwnerView("TRMA140_RA7", "FIELDS")

Return oView
