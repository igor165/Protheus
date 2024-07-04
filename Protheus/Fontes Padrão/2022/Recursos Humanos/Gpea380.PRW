#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA380.CH"
#INCLUDE "FWMVCDEF.CH"
/********************************************************************************************/
/*/{Protheus.doc} GPEA380
Montagem da rotina GPEA380 Cadastro de Agentes de Risco, estruturada para MVC

@author Rodrigo Lopes
@since 03/02/2011
@version P11.5
/*/
/********************************************************************************************/
/*

эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё GPEA380  Ё Autor Ё Rodrigo Lopes    	    Ё Data Ё 03/02/11 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Cadastro de Agentes de Risco                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё GPEA380()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico ( DOS e Windows )                                 Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠ЁCecilia C.  Ё15/05/14ЁTPPCSBЁIncluido o fonte da 11 para a 12 e efetua-Ё╠╠
╠╠Ё            Ё        Ё      Ёda a limpeza.                             Ё╠╠
╠╠ЁEmerson CampЁ25/07/14ЁTQDKJCЁAjuste na validaГЦo para apresentaГЦo do  Ё╠╠
╠╠Ё            Ё        Ё      Ёhelp corretamente.                        Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEA380()

	Local cFiltraRh			//Variavel para filtro
	Local oBrwTMA

	oBrwTMA := FWmBrowse():New()
	oBrwTMA:SetAlias( 'TMA' )
	oBrwTMA:SetDescription( STR0006 )   //'Cadastro de Agentes'

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH("GPEA380","TMA","1")

	//Filtro padrao do Browse conforme tabela TMA (Cadastro de Agentes de Risco)
	oBrwTMA:SetFilterDefault(cFiltraRh)
	oBrwTMA:Activate()

Return Nil

/*/
зддддддддддбддддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef 	  Ё Autor ЁRodrigo Lopes       Ё Data Ё03/02/2011Ё
цддддддддддеддддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁMenuf - Menu Funcional com array contendo os itens        	 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё                                                             Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide parametros formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁaRotina                                               	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico		                                             Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function MenuDef()
    Local aRotina := {}

	ADD OPTION aRotina Title STR0001  Action 'PesqBrw'         OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0002  Action 'VIEWDEF.GPEA380' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.GPEA380' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA380' OPERATION 4 ACCESS 0 //"Atualizar"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA380' OPERATION 5 ACCESS 0 //"Excluir"

   	If ExistBlock("GP380MNU")
		ExecBlock("GP380MNU", .F., .F.)
	EndIf

Return aRotina

/*/
зддддддддддбддддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef	  Ё Autor ЁRodrigo Lopes       Ё Data Ё03/02/2011Ё
цддддддддддеддддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁModelo de dados Regras Preenchimento do Cadastro de Agentes  Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё                                                             Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide parametros formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁoModel                                               	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico		                                             Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTMA := FWFormStruct( 1, 'TMA' )
	Local oModel
	Local bCommit

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('GPEA380',,{ |oModel| Gp380PosVal(oModel) } )

	// Adiciona ao modelo uma estrutura de formulАrio de ediГЦo por campo
	oModel:AddFields( 'TMAMASTER',, oStruTMA  )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0006) //'Cadastro de Agentes'

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'TMAMASTER' ):SetDescription( STR0006 ) //'Cadastro de Agentes'

Return oModel

/*/
зддддддддддбддддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef 	  Ё Autor ЁRodrigo Lopes       Ё Data Ё03/02/2011Ё
цддддддддддеддддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁView de dados do Cadastro de Agentes 						 Ё
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
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'GPEA380' )

	// Cria a estrutura a ser usada na View
	Local oStruTMA := FWFormStruct( 2, 'TMA' )
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serА utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_GPEA380', oStruTMA, 'TMAMASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_GPEA380', 'FORMFIELD' )

Return oView


/*/
зддддддддддбддддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gp380PosVal  Ё Autor ЁRodrigo Lopes       Ё Data Ё03/02/2011Ё
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
Static Function Gp380PosVal( oModel )
	Local lRetorno := .T.
	Local lRet 	:= .T.
	Local nOpcA

	// Seta qual И a operacao corrente
	nOpca := oModel:GetOperation()

	If nOpcA == 5

		lRetorno := RC7->(dbSeek( xFilial("RC7") + TMA->TMA_AGENTE,.T. ))

		dbSelectArea( "TMA" )

		If lRetorno
			lRet := .F.
			Help( ,, 'Help',, OemtoAnsi(STR0012), 1, 0 )
		EndIf
	EndIf

Return( lRet )