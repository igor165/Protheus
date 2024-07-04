#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA002.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEA002    Ё Autor Ё Mauricio Takakura     	      Ё Data Ё 27/09/11 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Historico de Alteracoes dos Planos Ativos                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEA002()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car. Ё15/05/2014ЁTPPCSB          ЁIncluido o fonte da 11 para a 12 e efetuadaЁ╠╠
╠╠Ё             Ё          Ё                Ё a limpeza.                                Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEA002()
	Local oMBrowse
	Local cFiltraRh

	oMBrowse := FWMBrowse():New()
	
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Historico de Alteracoes Planos Ativos"

	GpLegMVC(@oMBrowse)	// Adicionar a Legenda no Browse
	
	oMBrowse:ForceQuitButton()								//"Incluir botao de sair" 
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cFiltraRh := CHKRH("GPEA002","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	                           
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
	
Return

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Mauricio TakakuraЁ Data Ё27/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA002                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar' 
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA002" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.GPEA002" 		OPERATION 4 ACCESS 0				//'Manutencao'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA002" 		OPERATION 5 ACCESS 0				//'Excluir'
								
Return aRotina
	
/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Mauricio TakakuraЁ Data Ё27/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA002                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

	Local oModel
	Local oStructSRA
	Local oStructRHN	// Historico de Alteracoes de Planos Ativos
	
	// Criacao do Objeto de Modelagem de dados //	
	oModel     := MPFormModel():New("GPEA002",,, /*{ |oModel| Gp001Commit(oModel) }*/ )
	oModel:SetDescription( OemToAnsi(STR0001) ) //"Historico de Alteracoes Planos Ativos"
    
	// Cabecalho de dados - SRA (Funcionario)//
	oStructSRA := FWFormStruct(1, "SRA",  { |cCampo| Gpa002SRAStru(cCampo) })
	oModel:AddFields("GPEA002_MSRA", NIL, oStructSRA)
	oModel:GetModel( "GPEA002_MSRA" ):SetDescription( OemToAnsi(STR0001) ) //"Historico de Alteracoes Planos Ativos"
	oModel:GetModel('GPEA002_MSRA'):SetOnlyQuery(.T.)
	oModel:GetModel('GPEA002_MSRA'):SetOnlyView(.T.)

	// Estrutura de campos do Model - RHN - Historico de Alteracoes dos Planos Ativos //
	oStructRHN := FWFormStruct(1, "RHN")
	oStructRHN:SetProperty( "RHN_CODIGO", MODEL_FIELD_WHEN, { |oModel| Gpea002_When(oModel, 1) } )
	oStructRHN:SetProperty( "RHN_NOME", MODEL_FIELD_WHEN, { |oModel| Gpea002_When(oModel, 2) } )
	oStructRHN:SetProperty( "RHN_PDDAGR", MODEL_FIELD_WHEN, { |oModel| Gpea002_When(oModel, 3) } )
	
	oModel:AddGrid("GPEA002_MRHN", "GPEA002_MSRA", oStructRHN,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, { |x,y| LoadInforRHN(x, y)} ) //x=Grid, y=Copia
	
	oModel:GetModel( "GPEA002_MRHN" ):SetDescription( OemToAnsi(STR0001) ) //"Historico de Alteracoes Planos Ativos"

	oModel:SetRelation( "GPEA002_MRHN", { { "RHN_FILIAL", 'xFilial( "SRA" )' }, { "RHN_MAT", 'SRA->RA_MAT' }}, RHN->( IndexKey( 1 ) ) )
	
Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Mauricio TakakuraЁ Data Ё27/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA002                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()
	Local oView 
	Local oModel
	Local oStructSRA
	Local oStructRHN

	// Vincular o View ao Model //
	oModel := FWLoadModel("GPEA002")

	// Criacao da Interface //
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Criacao do Cabecalho - SRA (Funcionario) //
	oStructSRA := FWFormStruct(2, "SRA", { |cCampo| Gpa002SRAStru(cCampo) })
	oStructSRA:SetNoFolder()
	oView:AddField("GPEA002_VSRA", oStructSRA, "GPEA002_MSRA" )
	
	// Criacao do Cabecalho - RHN (Historico Alteracoes dos Planos Ativos) //
	oStructRHN 	:= FWFormStruct(2, "RHN")
	oStructRHN:RemoveField( "RHN_MAT" )

	oView:AddGrid("GPEA002_VRHN", oStructRHN, "GPEA002_MRHN" )

	// Desenho da Tela //
	oView:CreateHorizontalBox("SRA_HEAD", 12)
	oView:CreateHorizontalBox("RHN_HIST", 88)
	
	oView:SetOwnerView( "GPEA002_VSRA", "SRA_HEAD" )
	oView:SetOwnerView( "GPEA002_VRHN", "RHN_HIST" )
		
Return oView

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpa002SRAStru	ЁAutorЁ  Mauricio TakakuraЁ Data Ё27/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRA                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA002                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpa002SRAStru( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME*RA_ADMISSA' 
		lRet := .T.
	EndIf
	
Return lRet

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё LoadInforRHN	ЁAutorЁ  Mauricio TakakuraЁ Data Ё11/10/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRealizar a leitura dos dados da tabela de Historico         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA002                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function LoadInforRHN(oGrid, lCopia)
	Local aRet			:= {}
	
	Local cFunc			:= FunName()
	
	Local nOperation 	:= oGrid:GetOperation()
    
	If !(cFunc == "GPEA001") .Or. (cFunc == "GPEA001" .and. nOperation <> 3 )
		aRet := FormLoadGrid( oGrid, lCopia )
	EndIf

Return( aRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpea002_When	ЁAutorЁ  Mauricio TakakuraЁ Data Ё27/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁHabilitar pelo When Campos para edicao                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA002                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpea002_When(oModel, nCampo)
	Local cOrigem	:= ""
	
	Local lRet 		:= .T.
	
	cOrigem			:= oModel:GetValue( "RHN_ORIGEM" )
	
	If nCampo <> 3 .and. cOrigem == "1"
		lRet := .F. 
	ElseIf nCampo == 2 .and. cOrigem <> "3"
		lRet := .F. 
	ElseIf nCampo == 3 .and. cOrigem <> "1"
		lRet := .F. 
	ElseIf Empty(cOrigem)
		lRet := .F. 
	EndIf
	
Return( lRet )


/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPA002_ORIG	ЁAutorЁ  Mauricio TakakuraЁ Data Ё23/10/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidacao da Origem da Informacao                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA003                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GPA002_ORIG()
	Local aArea		:= GetArea()
	
	Local lRet		:= .T.
	
	Local oModel 		:= FWModelActive()
	Local oStruct		:= oModel:GetModel( "GPEA002_MRHN" )

	oStruct:LoadValue("RHN_CODIGO", Space(GetSx3Cache("RHN_CODIGO", "X3_TAMANHO"))  )

	RestArea( aArea )
	
Return( lRet )
