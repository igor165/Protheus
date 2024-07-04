#include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "CSAA110.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁProgram   Ё CSAA110  Ё Autor Ё Emerson Grassi Rocha              Ё Data Ё 13/08/2003 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Cadastramento de Classe Salariais                                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CSAA110()                                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                                 Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.                           Ё╠╠
╠╠цддддддддддддбддддддддддбддддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data     Ё FNC            Ё  Motivo da Alteracao                       Ё╠╠
╠╠цддддддддддддеддддддддддеддддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car.Ё07/07/2014ЁTPZVTW          ЁIncluido o fonte da 11 para a 12 e          Ё╠╠
╠╠Ё            Ё          Ё                Ёefetuada a limpeza.                         Ё╠╠
╠╠юддддддддддддаддддддддддаддддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function CSAA110()

	Local cFiltraRh			//Variavel para filtro
	Local oMBrowse

	oMBrowse := FWmBrowse():New()		
	oMBrowse:SetAlias( 'RBF' )
	oMBrowse:SetDescription( OemToAnsi(STR0001) )	//"Classes Salariais"
	
	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH(FunName(),"RBF","1")
	
	//Filtro padrao do Browse conforme tabela TMA (Cadastro de Agentes de Risco)
	oMBrowse:SetFilterDefault(cFiltraRh)
	oMBrowse:Activate()

Return(Nil)

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё28/12/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁCSAA100                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar' 
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.CSAA110" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.CSAA110" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.CSAA110" 		OPERATION 4 ACCESS 0				//'Alterar'
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.CSAA110" 		OPERATION 5 ACCESS 0				//'Excluir'

Return aRotina 

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Mauricio TakakuraЁ Data Ё14/06/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁCSAA110                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

	Local oModel
	Local oStructRBF

	// Criacao do Objeto de Modelagem de dados da tabela SRJ //	
	oModel     := MPFormModel():New("CSAA110", NIL, { |oModel| Csaa110PosVal(oModel) } )
	oModel:SetDescription( OemToAnsi(STR0001) ) //
	
	// Estrutura de campos do Model //
	oStructRBF := FWFormStruct(1, "RBF")
	oStructRBF:RemoveField("RBF_FILIAL")

	oModel:AddFields("CSAA110_RBF", NIL, oStructRBF)
	
	oModel:GetModel( "CSAA110_RBF" ):SetDescription( OemToAnsi(STR0001) ) //"Classes Salariais"

Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Mauricio TakakuraЁ Data Ё14/06/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁCSAA110                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()
	Local oView 
	Local oModel
	Local oStructRBF
	                           
	// Criacao da Interface //
	oView := FWFormView():New()
	
	// Vincular o View ao Model //
	oModel := FWLoadModel("CSAA110")	
	oStructRBF := FWFormStruct(2, "RBF")

	oStructRBF:RemoveField("RBF_FILIAL")
	
	oView:SetModel(oModel)
	oView:AddField("CSAA110_RBF", oStructRBF)
	
	oView:CreateHorizontalBox("FIELDS", 100)
	
	oView:SetOwnerView("CSAA110_RBF", "FIELDS")
	
Return oView

/*/
зддддддддддбддддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё CSAA110PosValЁ Autor ЁMauricio Takakura   Ё Data Ё14/06/2011Ё
цддддддддддеддддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidacao para exclusao - Integridade Referencial DBF 		 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё                                                             Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide parametros formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁoView                                                 	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico		                                             Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function Csaa110PosVal( oModel )
	Local lRetorno := .T.

Return( .T. )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁProgram   ЁCs110ClassЁ Autor Ё Emerson Grassi Rocha  Ё Data Ё 28/08/03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁBusca Descricao da Classe Salarial.		                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁcRet - Campo de Retorno da Descricao da Classe.             Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function Cs110Class(cRet)
	Local aSaveArea	:= GetArea() 
	Local lRet		:= .T.
	Local cClasse	:= &(ReadVar())
	Local nPosDesc	:= GdFieldPos(cRet) 
	                   
	// Enchoice
	If Type("M->"+cRet) == "C"
		&("M->"+cRet) := FDesc("RBF",cClasse,"RBF->RBF_DESC")
	EndIf       

	// GetDados
	If nPosDesc > 0
		aCols[n][nPosDesc] := FDesc("RBF",cClasse,"RBF->RBF_DESC")
	EndIf

	RestArea(aSaveArea)
Return .T.