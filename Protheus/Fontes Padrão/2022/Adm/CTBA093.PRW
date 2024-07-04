#INCLUDE 'protheus.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA093.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTBA093   ³ Autor ³ Mayra Camargo         ³ Data ³09/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registro de fórmulas para asientos contables interface     ³±±
±±³          ³ amigable.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA093()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³J. Penaloza ³02/09/14³TQKTXL³Se cambia el uso de aCols por metodo      ³±±
±±³            ³        ³      ³GetValue() al ingresar o actualizar       ³±±
±±³            ³        ³      ³registro                                  ³±±
±±³Alf Medrano ³23/10/14³TQTSWU³Se agrega metodo SetUseOldGrid para el uso³±±
±±³            ³        ³      ³de acols                                  ³±±
±±³Alf Medrano ³06/02/15³TROSEN³Se agrega ELSE a la estructura del IF     ³±±
±±³            ³        ³      ³dependiendo el tipo de dato en la Función ³±±
±±³            ³        ³      ³CTB93GEN solo para Valor Fijo             ³±±
±±³M.Camargo   ³21/10/15³TTRBJ0³Se agrega consulta std ampo CWK_VALOR y se³±±
±±³            ³        ³      ³activa uso de mnemónicos y realizar traduc³±±
±±³            ³        ³      ³ción al llamar CTB93GEN                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function CTBA093()
	
	Local oBrowse
	
	Private __cCTB93		:= "" // Retorno consulta std
	Private __nCTB93TD	:= ""  // Tipo de dato
	Private __aCT93Oper	:= fDefOper()
	Private __cCodMne	:= ""
	Private __lOblig		:= .F.
	Private __aCTB93For	:= {}
	Private __cExp
	Private __lMDtVin	:= .T.
	Private __aCWQTab	:= {}	
	// Inicializamos las Tablas
	
	dbSelectArea("CWK")
	dbSelectArea("CWL")
	dbSelectArea("CWM")
	dbSelectArea("CWJ")
	
	oBrowse:= FwMBrowse():New()
   oBrowse:SetAlias('CWK')
   oBrowse:SetDescription(STR0001)   
   oBrowse:Activate()

Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MenuDef  ³ Autor ³ Mayra Camargo         ³ Data ³09/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ define las operaciones que serán realizadas por la         ³±±
±±³          ³ aplicación: incluir, alterar, excluir etc.                 ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ FWMVCMenu                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA093                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0109)	ACTION 'VIEWDEF.CTBA093'		OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0110)	ACTION 'VIEWDEF.CTBA093' 	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE OemToAnsi(STR0111)	ACTION 'VIEWDEF.CTBA093' 	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE OemToAnsi(STR0112)	ACTION 'VIEWDEF.CTBA093' 	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE OemToAnsi(STR0113) 	ACTION 'VIEWDEF.CTBA093' 	OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE OemToAnsi(STR0114) 	ACTION 'VIEWDEF.CTBA093'		OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE OemToAnsi(STR0115) 	ACTION 'CTBA093POL(,0,2)' 	OPERATION 2 ACCESS 0 //"Consulta"
Return aRotina


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ModelDef ³ Autor ³ Mayra Camargo         ³ Data ³09/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Contiene la construcción y la definición del Modelo        ³±±
±±³          ³ (Model) contiene las reglas del negocio.                   ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oModel                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA093                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ModelDef()

	Local oStruCWK	:= FwFormStruc(1,'CWK',{ | cCampo |!( AllTrim( cCampo ) $ "CWK_ADVPL") })
	Local oStruSup 	:= FwFormStruc(1,'CWK',{ | cCampo |   AllTrim( cCampo ) $ "CWK_ADVPL"  })
	Local oStruCWL 	:= FWFormStruc(1,'CWL', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel  
	//Agregamos botón Generar formula
	oStruSup:AddField( ;
	STR0016	,;               // [01] Titulo do campo
	STR0016	,;               // [02] ToolTip do campo
	'BOTAO'   ,;               // [03] Id do Field
	'BT'		,;               // [04] Tipo do campo
	1			,;               // [05] Tamanho do campo
	0			,;               // [06] Decimal do campo
	{ |oMdl| CTB93GEN	( oMdl ), .T. }  )               // [07] Code-block de validação do campo
	
	
	// Campos vistuales que mostraran la descripción de cada mnemónico utilizado en la formulación del asiento por línea.
	oStruSup:AddField( ;      	// Ord. Tipo Desc.
	STR0137       	, ;      // [01]  C   Titulo do campo
	STR0137			, ;      // [02]  C   ToolTip do campo
	'CWK_DESOP1'		, ;      // [03]  C   Id do Field
	'C'					, ;      // [04]  C   Tipo do campo
	250            	, ;      // [05]  N   Tamanho do campo
	0					, ;      // [06]  N   Decimal do campo
	NIL					, ;      // [07]  B   Code-block de validação do campo
	NIL					, ;      // [08]  B   Code-block de validação When do campo
	NIL            	, ;      // [09]  A   Lista de valores permitido do campo
	.F.             , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL   				, ;      // [11]  B   Code-block de inicializacao do campo
	NIL					, ;      // [12]  L   Indica se trata-se de um campo chave
	NIL					, ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.             )        // [14]  L   Indica se o campo é virtual
	
	oStruSup:AddField( ;                      // Ord. Tipo Desc.
	STR0138       	, ;      // [01]  C   Titulo do campo
	STR0138			, ;      // [02]  C   ToolTip do campo
	'CWK_DESOP2'		, ;      // [03]  C   Id do Field
	'C'					, ;      // [04]  C   Tipo do campo
	250            	, ;      // [05]  N   Tamanho do campo
	0					, ;      // [06]  N   Decimal do campo
	NIL					, ;      // [07]  B   Code-block de validação do campo
	NIL					, ;      // [08]  B   Code-block de validação When do campo
	NIL            	, ;      // [09]  A   Lista de valores permitido do campo
	.F.             , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL   				, ;      // [11]  B   Code-block de inicializacao do campo
	NIL					, ;      // [12]  L   Indica se trata-se de um campo chave
	NIL					, ;      // [13]  L   Indica se o campo pode recebeadmir valor em uma operação de update.
	.T.             )        // [14]  L   Indica se o campo é virtual	
	
	oStruSup:SetProperty("CWK_ADVPL",MODEL_FIELD_OBRIGAT,.F.)
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('CTBA093', /*bPreValidacao*/, { | oMdl | CTB093POS( oMdl ) }, /*{ | oMdl | CTBA093COMM( oMdl ) }*/, /*bCancel */ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('CWKMASTER' 	, /*cOwner */, oStruCWK )
	oModel:AddFields('PARAMETROS'	, 'CWKMASTER', oStruSup )
	oModel:AddGrid( 'CWLDETAIL'    , 'CWKMASTER', oStruCWL,{|oModelGrid, nLine ,cAction,cField| CTB93LPRE(oModelGrid, nLine, cAction, cField) },{|oModelGrid,nLine,cAction|CTB93LPOS(oModelGrid,nLine,cAction)}) //
	
	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'CWLDETAIL' , { { 'CWL_FILIAL', 'xFilial( "CWL" ) ' } , { 'CWL_CODFOR', 'CWK_CODFOR' } } , CWL->( IndexKey(1)))

	oModel:GetModel('PARAMETROS'):SetOnlyQuery(.T.)
	oModel:GetModel('CWLDETAIL' ):SetOptional(.T.)

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'CWLDETAIL' ):SetUniqueLine( { 'CWL_CODFOR', 'CWL_SEC' } )	
	oModel:SetPrimaryKey( {} ) 
	//utiliza el comportamiento de acols anterior a version 12
	oModel:GetModel("CWLDETAIL"):SetUseOldGrid()
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription(STR0001 )	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'CWKMASTER' ):SetDescription( STR0001 )
	// Limpa o Cód da Fórmula(CWK_CODFOR) na copia
	oModel:GetModel("CWKMASTER"):SetFldNoCopy({"CWK_CODFOR"})
	
Return oModel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ViewDef  ³ Autor ³ Mayra Camargo         ³ Data ³09/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Contiene la construcción y la definición de la View        ³±±
±±³          ³ construcción de la interfaz                                ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA093                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ViewDef()

	Local oModel 		:= FWLoadModel('CTBA093')
	Local oStruCWK	:= FwFormStruc(2,'CWK',{ | cCampo | !(AllTrim( cCampo ) $ "CWK_ADVPL")	},)
	Local oStruSup 	:= FwFormStruc(2,'CWK',{ | cCampo |   AllTrim( cCampo ) $ "CWK_ADVPL"	},)
	Local oStruCWL	:= FwFormStruc(2,'CWL',,)
	Local cOrdem 		:= "00"
	
	Local oView
		
	oStruCWL:RemoveField("CWL_CODFOR")
	//Pega a ultima ordem
	aEval( oStrucwk:aFields, { |aX| cOrdem := IIf( aX[MVC_VIEW_ORDEM] > cOrdem, aX[MVC_VIEW_ORDEM] , cOrdem )  } )
	cOrdem := Soma1( cOrdem )
	oStruSup:AddField(;
	'BOTAO'	,;   	// [01] Campo
	cOrdem		,;   	// [02] Ordem
	STR0016	,;   	// [03] Titulo	
	STR0016	,;   	// [04] Descricao
	NIL      	,;   	// [05] Help
	'BT'      )		// [06] Tipo do campo   COMBO, Get ou CHECK
	
	
	// Agregamos visualizador de desc de menménicos
	
	cOrdem := Soma1( cOrdem )
	oStruSup:AddField(; 	      // Ord. Tipo Desc.
	'CWK_DESOP1'		, ;      // [01]  C   Nome do Campo
	cOrdem         	, ;      // [02]  C   Ordem
	STR0137			, ;      // [03]  C   Titulo do campo
	STR0137     		, ;      // [04]  C   Descricao do campo
	{ STR0137 }		, ;      // [05]  A   Array com Help
	'C' 				, ;      // [06]  C   Tipo do campo
	'@!'           	, ;      // [07]  C   Picture
	NIL            	, ;      // [08]  B   Bloco de Picture Var
	''             	, ;      // [09]  C   Consulta F3
	.f.					, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL            	, ;      // [12]  C   Agrupamento do campo
	NIL            	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL            	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL            	, ;      // [15]  C   Inicializador de Browse
	.T.             , ;      // [16]  L   Indica se o campo é virtual
	NIL            	, ;      // [17]  C   Picture Variavel
	NIL            	)        // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruSup:AddField(; 	      // Ord. Tipo Desc.
	'CWK_DESOP2'		, ;      // [01]  C   Nome do Campo
	cOrdem         	, ;      // [02]  C   Ordem
	STR0138			, ;      // [03]  C   Titulo do campo
	STR0138     		, ;      // [04]  C   Descricao do campo
	{ STR0138 }		, ;      // [05]  A   Array com Help
	'C' 				, ;      // [06]  C   Tipo do campo
	'@!'           	, ;      // [07]  C   Picture
	NIL            	, ;      // [08]  B   Bloco de Picture Var
	''             	, ;      // [09]  C   Consulta F3
	.f.					, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL            	, ;      // [12]  C   Agrupamento do campo
	NIL            	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL            	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL            	, ;      // [15]  C   Inicializador de Browse
	.T.             , ;      // [16]  L   Indica se o campo é virtual
	NIL            	, ;      // [17]  C   Picture Variavel
	NIL            	)        // [18]  L   Indica pulo de linha após o campo
			
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_CWK'	, oStruCWK, 'CWKMASTER' )
	oView:AddField( 'VIEW_SUP' 	, oStruSup, 'PARAMETROS')
	oView:AddGrid(  'VIEW_CWL'	, oStruCWL, 'CWLDETAIL' )
	oView:AddIncrementField( 'VIEW_CWL', 'CWL_SEC' )
	
	// Criar Grupos do campos
	oStruCWK:AddGroup( 'GRUPO01', STR0004, '', 1 )
	oStruCWK:AddGroup( 'GRUPO02', STR0005, '', 1 )
	oStruCWK:AddGroup( 'GRUPO03', STR0006, '', 1 )
	
	oStruSup:SetProperty( "CWK_ADVPL", MVC_VIEW_CANCHANGE   , .F. )
	oStruSup:AddGroup('GRUPO04',STR0140,'PARAMETROS')
	oStruSup:AddGroup('GRUPO05',STR0139,'PARAMETROS')
	
	//Grupo 1
	oStruCWK:SetProperty( 'CWK_CODFOR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruCWK:SetProperty( 'CWK_DESC'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruCWK:SetProperty( 'CWK_GRUPO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruCWK:SetProperty( 'CWK_DESGPO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruCWK:SetProperty( 'CWK_TIPO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruCWK:SetProperty( 'CWK_TIPDAT'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	
	//Grupo 2
	oStruCWK:SetProperty( 'CWK_VALOR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruCWK:SetProperty( 'CWK_CONASI' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	
	//Grupo 3
	oStruCWK:SetProperty( 'CWK_CUENTA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruCWK:SetProperty( 'CWK_CC' 		, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruCWK:SetProperty( 'CWK_ITECTB'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruCWK:SetProperty( 'CWK_CLVALO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruCWK:SetProperty( 'CWK_HELP'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

	// grupo 4
	oStruSup:SetProperty( 'CWK_ADVPL'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruSup:SetProperty( 'BOTAO'		, MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	//grupo 5
	oStruSup:SetProperty( 'CWK_DESOP1'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO05' )
	oStruSup:SetProperty( 'CWK_DESOP2'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO05' )
		
	// Cria Folder na view
	oView:CreateFolder('FOLDER01')
	
	// Cria pastas nas folders
	oView:AddSheet( 'FOLDER01', 'ABA01', STR0002 )
	oView:AddSheet( 'FOLDER01', 'ABA02', STR0003)

	// Criar um "box" horizontal para receber algum elemento da view
	
	oView:CreateHorizontalBox( 'CONFRAPIDA'	, 100,,, 'FOLDER01', 'ABA01' )
	oView:CreateHorizontalBox( 'FORMSUP'		,  45,,, 'FOLDER01', 'ABA02' )
	oView:CreateHorizontalBox( 'FORMINF'		,  55,,, 'FOLDER01', 'ABA02' )
		
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_CWK'	, 'CONFRAPIDA')
	oView:SetOwnerView( 'VIEW_CWL'	, 'FORMINF' )
	oView:SetOwnerView( 'VIEW_SUP'	, 'FORMSUP' )	
	
	oView:SetFieldAction( 'CWK_TIPO'	, { |oView| CTB93CLNCP(oView) 		} )
	oView:SetFieldAction( 'CWL_OPER'	, { |oView| CTB93CLGRID(oView) 	} )
	oView:SetViewAction( 'BUTTONOK' 	, { |oView| CTBA093COMM( oView ) 	} )
	oView:SetViewProperty( 'VIEW_CWL', "CHANGELINE", {{ |oView, cViewID| changeline(oview,cViewid) }} )
Return oView


Static function changeline(oview,cviewid)
	local oModel := FWModelActivate()
	Local omodelGrid := omodel:getmodel('CWLDETAIL')
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation <> MODEL_OPERATION_DELETE
		CTB93SHOWDES(oview,"",omodelGrid,oModelGrid:nLine)
	EndIF
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTB93GEN   ³ Autor ³ Mayra Camargo       ³ Data ³06/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Genera formula en campo cwk_advpl			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB93GEN(oView)                              		           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cFormula:= Fórmula generada a partid de grid               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ModelDef                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 :  objeto de modelo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Genera formula en campo cwk_advpl
Static function CTB93GEN(oMdl,lVal)
	Local aArea 		:= getArea()
	Local oModel    	:= FWModelActive()
	Local oView		:= FwViewActive()
	Local oModelSUP 	:= oModel:GetModel('PARAMETROS')
	Local cTipo		:= ""
	Local cFormula	:= ""
	Local cContenido	:= ""
	Local cRes		:= ""
	Local 	cTipDato	:= ""
	Local uTipRet		
		
	cTipo 		:= oModel:GetValue("CWKMASTER","CWK_TIPO")
	cTipDato	:= oModel:GetValue("CWKMASTER","CWK_TIPDAT")
	
	
	//1=Numérico;2=Caracter;3=Data  
	IF cTipDato == '1'
		uTipRet := '0'
	ElseIf cTipDato == '2'
		uTipRet := '""'
	ElseIf cTipDato == '3'
		uTipRet := 'Ctod(" / / ")'
	EndIf
	
	IF !(cTipo $ "6")//If //!Empty(cTipo)
	
		Do Case
			Case ctipo == '1'
				cContenido := oModel:GetValue("CWKMASTER","CWK_CUENTA")
			Case ctipo == '2'
				cContenido := oModel:GetValue("CWKMASTER","CWK_CC")	
			Case ctipo == '3'
				cContenido := oModel:GetValue("CWKMASTER","CWK_ITECTB")	
			Case ctipo == '4'
				cContenido := oModel:GetValue("CWKMASTER","CWK_CLVALO")
			Case ctipo == '5'
				cContenido := oModel:GetValue("CWKMASTER","CWK_VALOR")
		End Case
		
				
		If "M_" $ cContenido .and. cTipo <> '5'
			cFormula := CTB93VALMNE(cContenido)				
		ElseIf ctipo == '5'
			// Si la condición de asiento está vacía, se debe colocar solo el valor de campo valor sin la sentencia del IF
			cFormula := CTB93VALMNE(cContenido)		
			If !Empty(M->CWK_CONASI)
				cFormula := "IF(" + alltrim(M->CWK_CONASI) + "," + alltrim(cFormula) + "," + uTipRet +")"
			Else
				cFormula :=  alltrim(cFormula) 
			EndIF				
		Else
			cFormula := alltrim(cContenido) 
		EndIf	
		
		cRes := oModel:GetValue("CWKMASTER","CWK_TIPDAT")
		If !Empty(cRes)
		
			If cRes <> '1' .and. cTipo <> '5' .and. !("->" $ cFormula)
				cFormula := '"' + alltrim(cFormula) +'"'
			Else
				cFormula :=  alltrim(cFormula)
			EndIF
			
		EndIF
				
	Else
		// Generamos la fórmula según datos del grid
		oModelSup:SetValue("CWK_ADVPL", " ") 
		__aCTB93For:= {}
		__aCWQTab:={}						
		cFormula := fGenFormLn(@lVal)
			
	EndIf
	
	oModelSup:SetValue("CWK_ADVPL", cFormula) 
	RestArea(aArea)
	If !IsBlind()
		oView:Refresh()
	EndIf
	
Return cFormula

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTB93CLNCP ³ Autor ³ Mayra Camargo       ³ Data ³06/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpia el contenido de los campos combo.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB93CLNCP(oView)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ModelDef                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 :  objeto de interfaz view                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB93CLNCP(oView)

	Local oModel 	:= FWModelActive()
	Local cTipo	:= ""
	Local lBorrar	:= .T.
	Local cVALOR	:= oModel:GetValue("CWKMASTER","CWK_VALOR")
	Local cCC		:= oModel:GetValue("CWKMASTER","CWK_CC")
	Local cITECTB	:= oModel:GetValue("CWKMASTER","CWK_ITECTB")
	Local cCLVALO	:= oModel:GetValue("CWKMASTER","CWK_CLVALO")
	Local cCUENTA	:= oModel:GetValue("CWKMASTER","CWK_CUENTA")
	Local cCONASI	:= oModel:GetValue("CWKMASTER","CWK_CONASI")
	Local cTipAnt	:= M->CWK_TIPO
	Local cTipC	:= ""
	Local aCbox	:= {}
	Local nPos	:= 0
		
	ctipo := oModel:GetValue("CWKMASTER","CWK_TIPO")
	
	If !(cTipo $ "6") //!Empty(cTipo)
		If !Empty(cTipAnt)
			cTipC	:= cTipAnt
			aCbox	:= fGetCBOXSx3("CWK_TIPO") //obtiene un array con los valores del campo X3_CBOX
			nPos	:= aScan(aCbox,{|x| left(x,1) == cTipAnt}) //Retorna Numero de posicion del elemento
			If nPos>0
				cTipAnt :=aCbox[nPos]
			EndIf
			
		EndIf
		
		Do Case
			Case cTipo == '1'
				If !Empty(cVALOR) .OR. !Empty(cCC) .OR. !Empty(cCLVALO) .OR. !Empty(cITECTB) .OR. !Empty(cCONASI)
					lBorrar := MsgNoYes(OemToAnsi(STR0101) + cTipAnt + OemToAnsi(STR0102))	//"Los Campos relacionados al Tipo " x " se limpiaran.  ¿Está seguro que desea cambiar de Tipo?"		
				EndIf
				if lBorrar
					oModel:LoadValue( 'CWKMASTER', 'CWK_VALOR' 	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CC'		, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_ITECTB'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CLVALO'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CONASI'	, '')
				EndIf			
			Case cTipo == '2'
				If !Empty(cVALOR) .OR. !Empty(cCONASI) .OR. !Empty(cCUENTA) .OR. !Empty(cITECTB) .OR. !Empty(cCLVALO) 
					lBorrar := MsgNoYes(OemToAnsi(STR0101) + cTipAnt + OemToAnsi(STR0102))	//"Los Campos relacionados al Tipo " x " se limpiaran.  ¿Está seguro que desea cambiar de Tipo?"					
				EndIf
				if lBorrar
					oModel:LoadValue( 'CWKMASTER', 'CWK_VALOR'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CONASI'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CUENTA'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_ITECTB'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CLVALO'	, '')
				EndIf		
			Case cTipo == '3'
				If !Empty(cVALOR) .OR. !Empty(cCONASI) .OR. !Empty(cCC) .OR. !Empty(cCUENTA) .OR. !Empty(cCLVALO) 
					lBorrar := MsgNoYes(OemToAnsi(STR0101) + cTipAnt + OemToAnsi(STR0102))	//"Los Campos relacionados al Tipo " x " se limpiaran.  ¿Está seguro que desea cambiar de Tipo?"				
				EndIf
				if lBorrar
					oModel:LoadValue( 'CWKMASTER', 'CWK_VALOR'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CONASI'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CC'	 	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CUENTA'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CLVALO'	, '')
				EndIf		
			Case ctipo == '4'
				If !Empty(cVALOR) .OR. !Empty(cCONASI) .OR. !Empty(cCC) .OR. !Empty(cITECTB) .OR. !Empty(cCUENTA)
			    	lBorrar := MsgNoYes(OemToAnsi(STR0101) + cTipAnt + OemToAnsi(STR0102))	//"Los Campos relacionados al Tipo " x " se limpiaran.  ¿Está seguro que desea cambiar de Tipo?"				
				EndIf
				If lBorrar
					oModel:LoadValue( 'CWKMASTER', 'CWK_VALOR'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CONASI'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CC'	 	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_ITECTB'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CUENTA'	, '')
				EndIf	
			Case cTipo == '5'
				If !Empty(cCUENTA) .OR. !Empty(cCC) .OR. !Empty(cITECTB) .OR. !Empty(cCLVALO)
					lBorrar := MsgNoYes(OemToAnsi(STR0101) + cTipAnt + OemToAnsi(STR0102))	//"Los Campos relacionados al Tipo " x " se limpiaran.  ¿Está seguro que desea cambiar de Tipo?"		
				EndIf
				If lBorrar
					oModel:LoadValue( 'CWKMASTER', 'CWK_CUENTA'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CC'	 	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_ITECTB'	, '')
					oModel:LoadValue( 'CWKMASTER', 'CWK_CLVALO'	, '')
				EndIf					
		End Case
		// Deshabilitar Grid
		oModel:GetModel( 'CWLDETAIL' ):SetNoInsertLine( .T. )
		oModel:GetModel( 'CWLDETAIL' ):SetNoUpdateLine( .T. )
	EndIF
	
	IF cTipo $ "6"
	
		// limpia campos
		If !Empty(cCUENTA) .OR. !Empty(cCC) .OR. !Empty(cITECTB) .OR. !Empty(cCLVALO) .or.  !Empty(cVALOR) .OR. !Empty(cCONASI) 
			lBorrar := MsgNoYes(OemToAnsi(STR0101) + cTipAnt + OemToAnsi(STR0102))	//"Los Campos relacionados al Tipo " x " se limpiaran.  ¿Está seguro que desea cambiar de Tipo?"		
		EndIf
		If lBorrar
			oModel:LoadValue( 'CWKMASTER', 'CWK_VALOR'	, '')
			oModel:LoadValue( 'CWKMASTER', 'CWK_CUENTA'	, '')
			oModel:LoadValue( 'CWKMASTER', 'CWK_CONASI'	, '')
			oModel:LoadValue( 'CWKMASTER', 'CWK_CC'	 	, '')
			oModel:LoadValue( 'CWKMASTER', 'CWK_ITECTB'	, '')
			oModel:LoadValue( 'CWKMASTER', 'CWK_CLVALO'	, '')
			oModel:LoadValue( 'PARAMETROS','CWK_ADVPL'	, '')
		EndIf		
	
		// 	Habilitar Grid
		oModel:GetModel( 'CWLDETAIL' ):SetNoInsertLine( .F. )
		oModel:GetModel( 'CWLDETAIL' ):SetNoUpdateLine( .F. )	
	EndIf
	
	If ! lBorrar
		oModel:SetValue(  'CWKMASTER', 'CWK_TIPO' 	, cTipC)
	EndIf
		
	oView:Refresh()
Return


//Limpia grid
Static Function CTB93CLGRID(oView)
	Local oModel		:= FwModelActivate()
   Local cOper 		:= ""
   Local cOp1  		:= ""
   Local cOp2  		:= "" 
   Local cConj 		:= ""
   Local cSelSec   	:= ""
   Local lOblig2		:= .F.
   Local cTpOP		:= "U"
   
   Local nPos		:= 0
      
   cOper     := oModel:GetValue("CWLDETAIL","CWL_OPER")
   cOp1      := oModel:GetValue("CWLDETAIL","CWL_OPER1")
   cOp2      := oModel:GetValue("CWLDETAIL","CWL_OPER2")
   cConj 		:= oModel:GetValue("CWLDETAIL","CWL_CONJUN")
   cSelSec		:= oModel:GetValue("CWLDETAIL","CWL_SELSEC")
   	
   nPos :=  aScan(__aCT93Oper, { |x,y| x[1] == cOper })
   
   If nPos > 0
   		lOblg2:= "O" $ __aCT93Oper[nPos,6]	
   		cTpOp := __aCT93Oper[nPos,3]	
   		If !lOblg2
   			oModel:LoadValue("CWLDETAIL","CWL_OPER2","")   			  			
   		EndIf
   		
   		If !(cTpOp $ "C")
   			oModel:LoadValue("CWLDETAIL","CWL_CONJUN","") 
   		EndIF
   EndIF 
   
	oView:Refresh()
Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTBA093COMM³ Autor ³ Mayra Camargo       ³ Data ³06/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Guarda el valor de la Formula                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA093COMM(ExpO1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ModelDef                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 :  objeto de interfaz view                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTBA093COMM(oMdl)

	Local aArea		:= getArea()
	Local oModel		:= FWModelActive()
	Local cTipo		:= ""
	Local cCodFOR 	:= GetMemVar("CWK_CODFOR") //--- codigo de la Formula
	Local nOperation	:= oModel:GetOperation()
	Local cFormula	:= Space(TamSx3("CWK_ADVPL")[1])
	Local nI			:= 0
			
	cTipo 		:= oModel:GetValue("CWKMASTER","CWK_TIPO")
	cChave 	:= FWCODFIL("CWK") + oModel:GetValue("CWKMASTER","CWK_CODFOR")
	cFormula 	:= oModel:GetValue("PARAMETROS","CWK_ADVPL")

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		
		// Se regenera la fórmula.
		cFormula := CTB93GEN(oModel)	
	
		DbSelectArea("CWK")
		CWK->(dbSetOrder(1)) 
		IF CWK->(DBSeek(XFILIAL("CWK")+cCodFOR))			
			//---BLOQUEA EL REGISTRO
			RecLock("CWK",.f. )
			CWK->CWK_FOREJE := 'EJEFOR("'+cCodFOR+'")'  
			CWK->CWK_ADVPL	:= cFormula
			CWK->(MsUnlock())
		EndIf	
			
	EndIf
	
	If nOperation == MODEL_OPERATION_INSERT 
		// Guardamos Relación Tablas en CWQ
		
		// CWQ_FILIAL+CWQ_CODFOR+CWQ_TABLA
		For nI:= 1 to len(__aCWQTab)
			RecLock("CWQ",.t.)
				CWQ->CWQ_FILIAL	:= xFilial("CWQ")
				CWQ->CWQ_CODFOR 	:= cCodFor
				CWQ->CWQ_TABLA	:= __aCWQTab[nI] 
			CWQ->(MsUnlock())
		
		Next ni
	ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE
		dbSelectArea("CWQ")
		CWQ->(dbSetOrder(1))
		
		While CWQ->(!eof()) 
			IF CWQ->(dbseek(xFilial("CWQ")+cCodFor))
				RecLock("CWQ",.f.)
					CWQ->(dbDelete())
				CWQ->(MsUnlock())
			EndIF
			CWQ->(dbSkip())
		EndDO
		
		If nOperation == MODEL_OPERATION_UPDATE
			For nI:= 1 to len(__aCWQTab)
				RecLock("CWQ",.t.)
					CWQ->CWQ_FILIAL	:= xFilial("CWQ")
					CWQ->CWQ_CODFOR 	:= cCodFor
					CWQ->CWQ_TABLA	:= __aCWQTab[nI] 
				CWQ->(MsUnlock())			
			Next ni
		EndIF
	EndIF
	
	RestArea(aArea)
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTB93LPOS  ³ Autor ³ Mayra Camargo       ³ Data ³06/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza validación al bajar de línea				           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93LPOS(oModelGrid,nLine)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet := Indica si la sintaxis fue válida.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ oModelGrid                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oModelGrid	:= Modelo que contiene el grid                ³±±
±±³          ³ nLine			:= Línea a Validar			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CTB93LPOS(oModelGrid,nLine)
	Local lRet		:= .T.
	Local oModel		:= oModelGrid:GetModel()
	Local nOperation	:= oModel:GetOperation()
	Local aLnGrid		:= {}
	
	CTB93SKYP(oModelGrid, nLine, "","") 
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		aLnGrid := aClone(oModelGrid:ACols)
		lRet:=	fValStx(aLnGrid)
	EndIf
	
Return lRet

Static function CTB93DESC(oModelGrid,nLine)

	Local oView		:= FwViewActivate()
	Local nPos1		:= 0
	Local nPos2		:= 0
	Local aLnGrid 	:= {}
	Local oView		:= FwViewActivate()
	aLnGrid := aClone(oModelGrid:ACols)
	
	aAdd(oModelGrid:aLinesChanged,nLine)
	
	
	nPos1 := aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_OPER1"	} )
	nPos2 := aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_OPER2"	} )
	
	CTB93SHOWDES(oview,aLnGrid[1,nPos1],oModelGrid,nLine)
	CTB93SHOWDES(oview,aLnGrid[1,nPos2],oModelGrid,nLine)
	
	
	
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fGenFormLn ³ Autor ³ Mayra Camargo       ³ Data ³06/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera la fórmula que será guardada en cwk_advpl           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGenFormLn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cForm := Fórmnula generada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93GEN()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGenFormLn(lVal)
	Local oModel		:= FwModelActive()
	Local oModelGrid	:= oModel:GetModel("CWLDETAIL")	
	Local aGrid		:= {}
	Local aLnGrid		:= {}
	Local nLine		:= 1
	Local cForm		:= ""
	Local lTermina	:= .F.
	Local aFormula	:= {}
	Local nPos		:= 0
	Local nNext		:= 0
	Local nInicio		:= 0
	Local nCont		:= 0
	Local aAux		:= {}
	Local aStack[LEN(oModelGrid:ACols)]
	Local aTmp		:= {}
	Local nY			:= 0
	Local lConjAnt	:= .F.
	Local nPosConj	:= 0
	Local nPosAux		:= 0
	Local lcontinua	:= .F.
	Local nI			:= 0
	Local nTopS		:= 0
	Local nBottomS	:= 0
	Local nArgs		:= 0
	Local nCam		:= 0
	Local nPtro		:= 0
	Local nIndica		:= 0
	Local aArgs[LEN(oModelGrid:ACols)]

	DEFAULT lVal := .F.
			
	aGrid 		:= aClone(oModelGrid:ACols)
	nPosConj	:= aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_CONJUN"	} )
	
	// Validamos cada línea del grid
	For nLine := 1 to len(aGrid)
		IF !(aGrid[nLine,10])	
			AADD(aLnGrid,aGrid[nLine])
			
			//La primera línea no tiene línea anterior
			If nLine >1 
				lConjAnt := !Empty(aGrid[nLine-1,nPosConj])
			EndIF		
			
			lRet:=	fValStx(aLnGrid,.T.,lConjAnt)		//Valida y genera sintaxis de fórmula por línea				
			If !lRet 
				//Help( ,, OemToAnsi(STR0061),, OemToAnsi(STR0103) + StrZero(nLine,TamSx3("CWL_SEC")[1]),1, 0 )   // "Aviso" // "Sintasis incorrecta, verificar línea "			
				Return cForm
			End IF	
			lConjAnt:= .F.		
		EndIF
	Next
	
	//Indicamos el final del array
	AADD(	__aCTB93For,{"X",;	// Sintaxis Fórmula
				,;	// Secuencia Sig.
		 	.F.	,;	// Procesado
			.F.	,; // Conjuncion o no
			.F.,; // Condición
			LEN(__aCTB93For)+1})	//Sec. actual   				
			
	If !(len(__aCTB93For) > 1)
		Return ""
	EndIf
	
	nLine 	:= 1
	nNext 	:= 1
	nCont 	:= 1
	nInicio:= 1
	nFin	:= len(__aCTB93For)
	nPos	:= nLine
	nLnIF	:= 0
	lConjant := .F.
	
	//Ordenamos el array conforme a la secuencia
	nCam 	:= 1
	nPtro 	:= 0
	
	While nCam < len(__aCTB93For)		//Recorrer todos los elementos 
		nPtr := 1
		
		While nPtr < len(__aCTB93For) 
			if !__aCTB93For[nPtr,3]
				__aCTB93For[nptr,3] := .T.
				AADD(aTmp,__aCTB93For[nPtr])	
				
				If nCam = 1 .and. !__aCTB93For[nptr,5] .AND.  len(__aCTB93For) > 2
					Help( ,, OemToAnsi(STR0061),, OemToAnsi(STR0126),1, 0 )   // "Aviso" // "órmula inválida "
					cForm := ""	
					Return cForm
				EndIF
				
				nCam++
								
				If !Empty(__aCTB93For[nPtr,2])
					nPtr := __aCTB93For[nPtr,2]
				Else
					nPtr := __aCTB93For[nPtr+1,6]
				EndIF
				
			Else
				nptr := __aCTB93For[nptr+1,6]
			EndIF
			
			
		EndDo
		
	EndDo
	//Simplificamos agrupando condiciones que tengas conjunción en un solo elemento
	While nLine < nFin
		cForm += aTmp[nLine,1]	 
										
		If aTmp[nLine,4] //Si tiene conjunción
			If len(atmp) > 1
				lContinua := .T.
			Else
				lContinua := .F.
			EndIf							
		Else
			lContinua := .F.
		EndIF											
		aTmp[nLine,3] := .T.
			
		If !LContinua
			aAdd(aAux,{cForm,aTmp[nLine,5]})
			cForm := ""
		EndIf
		nLine ++	
	EndDo
		
	//Llenamos la Stack 
	nLine 		:= 1
	nTopS		:= 1
	nBottomS	:= 1
	nArgs		:= 0
	nI			:= 0
	cForm 		:= ""
	
	
	For nLine:= 1 to len(aAux)
		//Vamos agregando elementos a la pila
		aIns(aStack,nTopS)		
		aStack[nTopS] := aAux[nLine,1]
		
		aIns(aArgs,nTopS)
		aArgs[nTops] := aAux[nLine,2]
				
		//If nArgs == 2	// Si ya tenemos dos argumentos podemos completar un if
		If nTops > 2
			while !aArgs[nTopS-1] .and. !aArgs[nTopS]	
				ntops++
				fConStack(@aStack,@nTops,nBottoms,@aArgs)			
				If nTops = nBottoms
					Exit
				EndIf		
			EndDo	
			
		EndIF
		nTops++														
		//EndIF	
			
	Next 	//Comsumir la Pila
	
		
	//Comenzamos a consumir los últimos elementos del Stack
		
	While nTopS > nBottomS		
		IF nTopS > 3
			For nI := 1 to 3
				ntopS--
				aAdd(aFormula,aStack[nTopS])
				aDel(aStack,nTopS)									
			Next
				
			cForm := aFormula[3] + "," + aFormula[2] + "," + aFormula[1] + ")"
			aFormula := {}
			aIns(aStack,nTopS)
			aStack[nTopS] := cForm
			nArgs := 1	
			nTopS++	
		Else
			nTopS--
		End IF
	EndDo
	
	// Cuando el fondo y el borde del Stack son iguales, entonces tenemos la formula compuesta 
	If nTopS == nBottomS
		cForm := aStack[nTopS]	
	End IF
	
	//Validamos sintaxis.	
	lRet 	:= CTB93FORM(cForm ,.F.)
	
	//Si no fue válida la sintaxis, entonces se envía mensaje al usuario
	IF !lRet 
		lVal := lRet
		Help( ,, OemToAnsi(STR0061),, OemToAnsi(STR0104),1, 0 )   // "Aviso" // "órmula inválida "
		cForm := CTB93VALMNE(cForm,.F.)			
		Return cForm
	EndIF
	
	//Traducimos los mnemónicos a su valor 
	cForm := CTB93VALMNE(cForm,.F.)
	lVal := lRet
Return cForm

//Consumir Stack
Static Function fConStack(aStack,nTops,nBottoms,aArgs,nArgs)

	Local nI			:= 0
	Local cForm 		:= ""
	Local aFormula	:= {}
	
	For nI := 1 to 3
		ntopS--
		If nTopS > 0
			aAdd(aFormula,aStack[nTopS]) 	//Vamos sacando los elementos del stack y colocandolos en otro array
			aDel(aStack,nTopS)				//Eliminamos el elemento del stack
			aDel(aArgs,nTops)					//Guardamos si es condición o no	
		EndIF				
	Next
			
	//Formamos un nuevo elemento y los agregamos al stack
	If len(aFormula) > 0 //Evitar error array out of bounds
		cForm := aFormula[3] + "," + aFormula[2] + "," + aFormula[1] + ")"
			aFormula := {}
			aIns(aStack,nTopS)
			aStack[nTopS] := cForm		
				
			aIns(aArgs,nTops)
			aArgs[nTops] := .F.
	Else
		cForm := ""
	EndIf

									
	//nTops++	
Return 

//+-----------------------------------------------------------------------------------------------+//
//|CONSULTAS ESPECÍFICAS Y VALIDACIONES DE CAMPOS														|//
//+-----------------------------------------------------------------------------------------------+//


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTB91CESP ³ Autor ³ Mayra Camargo         ³ Data ³09/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define las consulta estándar CWKTIP dependiendo del origen ³±±
±±³          ³ de la llamada a la consulta                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB91CESP()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB93CESP()

	Local cRedVar := ReadVar()
	
	If cRedVar != NIL
	
		DO CASE
			CASE cRedVar == "M->CWK_CUENTA" 
				__cCTB93 := CTB93EXP(1,"CWK_CUENTA","CT1")
			CASE cRedVar == "M->CWK_CC" 
				__cCTB93 := CTB93EXP(2,"CWK_CC","CTT")
			CASE cRedVar == "M->CWK_ITECTB"
				__cCTB93 := CTB93EXP(3,"CWK_ITECTB","CTD") 
			CASE cRedVar == "M->CWK_CLVALO"
				__cCTB93 := CTB93EXP(4,"CWK_CLVALO","CTH") 
		ENDCASE
	EndIf
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTB93EXP ³  Autor³ Mayra.Camargo         ³ Data ³09/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara el cuadro de dialogo para la consulta CWKTIP       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parámetros³ nOpc   := M->CWK_TIPO                                      ³±±
±±³          ³ cCampo := Campo de Origen de la consulta                   ³±±
±±³          ³ cF3    := Consulta Std a mostrar en pantalla               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet := Código                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93EXP()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CTB93EXP(nOpc,cCampo,cF3)

	Local oDlg 
	Local oBtnOk 
	Local oBtnCa
	Local oCmbFor
	Local oArial10
	Local oGetHlp
	Local cField		:= space(TamSX3(cCampo)[1])
	Local aArea		:= getArea() 
	Local cRet		:= "" 
	Local cTabla 		:= "CWJ001"
	Local aFormula	:= {}
	Local cCodMne		:= space(TamSX3("CWJ_CODMNE")[1])
	Local cTitulo		
	
	
	Do Case
		Case nOpc == 1
			cTitulo := STR0007
		Case nOpc = 2
			cTitulo := STR0009
		Case nOpc = 3
			cTitulo := STR0010
		case nOpc = 4
			cTitulo := STR0011
	End Case
	
	//Crea el cuadro de dialogo 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 180,250 PIXEL TITLE OemToAnsi(STR0015)  // Seleccione el Dato
		
		oSay	:= tSay():New(10,10,{||OemToAnsi(cTitulo)},oDlg,,oArial10,,,,.T.) 			// Campo
		@ 18,10   MSGET	cField	  SIZE 100,10 WHEN Empty(cCodMne)  OF oDlg  F3 cF3 VALID CTB93VLDAT(cField,cF3)  PIXEL HASBUTTON	
			
		oSay	:= tSay():New(38,10,{||OemToAnsi(STR0008)},oDlg,,oArial10,,,,.T.) 			// Mnemónico
		@ 46,10   MSGET cCodMne	SIZE 100,10 WHEN Empty(cField) OF oDlg  F3 cTabla  VALID CTB93VLMNE(cCodMne) PIXEL HASBUTTON
		
					  
		oBtnOk:=tButton():New(70,30,OemToAnsi(STR0012),oDlg,{||( cRet:= IIF(!Empty(cField),cField,cCodMne),oDlg:End()  )} ,30,12,,,,.T.) //  Ok
		oBtnCa:=tButton():New(70,65,OemToAnsi(STR0013),oDlg,{||( oDlg:End() )},30,12,,,,.T.)  // Anular
		
	ACTIVATE MSDIALOG oDlg CENTERED
	  
	RestArea(aArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB93VLMNEºAutor  ³mayra.camargo       º Data ³ 09/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida código de Mnemónico que exista en CWJ                º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parámetros³ cCodMNE:= Código del mnemónico a validar                   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB93EXP Consulta std CWKTIP                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CTB93VLMNE(cCodMne)

	Local lRet 	:= .T.
	Local aArea 	:= getArea()
	
	If !Empty(cCodMne)
		dbSelectArea("CWJ")
		CWJ->(dbSetOrder(1))
		lRet := cwj->(dbSeek(xFilial("CWJ")+cCodMne))
	EndIf			
	
	RestArea(aArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB93VLDATºAutor  ³mayra.camargo       º Data ³ 09/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida que el códico(cCod) exista en la tabla(cAlias)       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta std CWKTIP                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB93VLDAT(cCod,cAlias)

	Local lRet 	:= .T.
	Local aArea 	:= getArea()
	
	If !Empty(cCod)
		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(1))
		lRet := (cAlias)->(dbSeek(xFilial(cAlias)+cCod))
	EndIf			
	
	RestArea(aArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB93VALIDºAutor  ³ mayra.camargo      º Data ³  10/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida que el campo exista en la tabla según la opcnión.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CTB93VALID(cMemDat,nOpc)                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cMemDat := Código o dato a validar                         º±±
±±º          ³ nOpc := Opción Origen para realizar la validación.         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Validación de Campos CWK_CUENTA, CWK_CC,CWK_ITECBT          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTB93VALID(cMemDat,nOpc)

	Local lRet := .T.
	DEFAULT cMemDat := &(ReadVar())
	DEFAULT nOpc 	   := 1
		
	IF "M_" $ cMemDat 
		lRet := CTB93VLDAT(cMemDat,"CWJ")
	Else
		Do Case
			case nOpc == 1
				lRet := CTB93VLDAT(cMemDat,"CT1")
			case nOpc == 2
				lRet := CTB93VLDAT(cMemDat,"CTT")
			case nOpc == 3
				lRet := CTB93VLDAT(cMemDat,"CTD")
			case nOpc == 4
				lRet := CTB93VLDAT(cMemDat,"CTH")				
		End Case 
	EndIF 
		
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB93LBOX ºAutor  ³Mayra camargo       º Data ³ 21/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Genera lista de elementos para el campo CWL_OPER            º±±
±±º          ³según el contenido del array de menmónicos                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CTB93LBOX                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTB93LBOX() 
	Local cRetorno	:= ""
	Local nI		  	:= 0
	
	If type('__aCT93Oper') == 'U'
		__aCT93Oper := fDefOper()
	EndIF
	
	For nI := 1 to len(__aCT93Oper)
		cRetorno +=__aCT93Oper[nI,1]+"="+ __aCT93Oper[nI,2] 
		//cRetorno +=__aCT93Oper[nI,2] 
		If nI < len(__aCT93Oper)
			cRetorno += ";"	
		EndIF
		
	Next nI
		
Return (cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB93CWJFILºAutor ³ mayra.camargo      º Data ³  21/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Genera dialogo para consulta específica CWJFOR y filtre soloº±±
±±º          ³el tipo de mnemónico según corresponda.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CTB93CWJFIL()                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CTBA93                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB93CWJFIL()
	
	Local aArea 	:= getArea()
	Local oMdl	:= FwModelActivate()
	Local cFiltro	:= "" 	
	Local cMemDat	:= &(ReadVar())
	Local cMneFil	:= ""
	Local aMnem	:= {}
	Local cOprndo	:= ReadVar()
	Local aOrdenes	:= {1}
	Local i,j            
	Local nOpca 	:= 0 
	Local nInd 	:= 0
	local oOrdem, oChave
	Local cChave	:= Space(255)
	Local nPosLbx	:= 0
	local cOper 	:=oMdl:GetValue("CWLDETAIL","CWL_OPER")
	Local oDlgRec	:= NIL
	Local aCabec	:={}
	Local aLBX	:={}
	Local lRet	:= .T.
	Local nPos	:= 0
	Local cClave	:= cMemDat
	Local oBoton	:= NIL
	Local oBusca	:= NIL
	Local cBusca	:= Space(80)
	Local nOrd	:= 1
	
	Private oLbx		:= Nil
	Private oDlg2	:= Nil 
	Private cIndx
	Private nOrdem 	:= 1
	Private aIndx	:= {}
	Private bLinea
	Private aItems 	:= {}
	
	cClave := rtrim(cClave)
	__cCodMne := IIF(cClave == "M_","",cClave)
				
	If "M_" $ cMemDat //Si el dato en memoria a buscar es un Mnemónico
		
		//Validar que si el tipo de operador es C o T permita concatenar mnem´nicos 
		//de lo contrario regresa un solo valor para el código del menmónico
		
		CursorWait()
		//-- Campos por los que hara las busquedas
		aAdd(aIndx, STR0048)  
		aAdd(aIndx, STR0051)

		//Se obtienen los mnemónicos según el operador y si es el operando 1 o 2
		aItems := fFilMne(cOper,cOprndo,.T.,.F.)
		CursorArrow()
					
		//Si no existen mnemónicos que correspondan al tipo de dato del operando se envía mensaje en pantalla
		If Valtype(aItems) <> 'A'//Len(aItems) == 0
			Aviso(STR0059,STR0060,{'Ok'})//"No hay informaci¢n para consultar."
			lRet:= .F.
			Return lRet
		ElseIf	 Len(aItems) == 0	
			Aviso(STR0059,OemToAnsi(STR0136),{'Ok'})//"No hay informaci¢n para consultar."
			lRet:= .F.
			RestArea(aArea)	
			Return lRet
		Endif
		
		bLinea := {|| {	aItems[oLbx1:nAt,1],;
							aItems[oLbx1:nAt,2],;
							aItems[oLbx1:nAt,3],;
							aItems[oLbx1:nAt,4],;
							aItems[oLbx1:nAt,5],;
							aItems[oLbx1:nAt,6],;
							aItems[oLbx1:nAt,7],;
							aItems[oLbx1:nAt,8],;
							aItems[oLbx1:nAt,9]}}
		
		//-- Posicion en el arreglo donde esta la actual clave de producto
		If !Empty(cClave) .and. cClave <> "M_"
			nPos := aScan(aItems,{|x| x[1] = cClave}) //posiciona en el producto contenid en el campo ReadVar
		EndIf
		
		
		//-- Despliega consulta
		DEFINE MSDIALOG oDlgRec Title STR0047 From 000,000 To 421,522 Pixel 
		
			@ 02,05 MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx size 210,08 PIXEL OF oDlgRec
			oIndx:bChange := {|| (nOrd:=oIndx:nAt, Reordena(@oLbx1, aItems, nOrd)) }
			
			@ 02,220 BUTTON oBoton PROMPT OEMTOANSI(STR0049) SIZE 35,10 ; //"Buscar"
					ACTION (oLbx1:nAT := BuscaCve(oLbx1, aItems, nOrd, aOrdenes, cBusca), ;
							oLbx1:bLine := bLinea, ;
							oLbx1:SetFocus());
					PIXEL OF oDlgRec
			@ 14,05 MSGET oBusca VAR cBusca PICTURE "@!" SIZE 210,08 PIXEL OF oDlgRec
			  
			
			@ 28,05 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER OemToAnsi(STR0050),OemToAnsi(STR0051),;
																	OemToAnsi(STR0052),OemToAnsi(STR0053),;
																	OemToAnsi(STR0054),OemToAnsi(STR0055),;
																	OemToAnsi(STR0056),OemToAnsi(STR0057),;
																	OemToAnsi(STR0058),;
									 SIZE 255,149 OF oDlgRec PIXEL 
			
			oLbx1:SetArray(aItems)
			
			If nPos > 0
				oLbx1:nAt := nPos
			Endif
			
			oLbx1:bLine:= if(len(aItems)>0,bLinea,{||})
			oLbx1:BlDblClick := {||(lRet:=.T.,nPos:=oLbx1:nAt,oDlgRec:End())}
			oLbx1:Refresh()
			
			DEFINE SBUTTON FROM 195, 05 TYPE 1 ENABLE OF oDlgRec ACTION (lRet:=.T.,nPos:=oLbx1:nAt,oDlgRec:End())
			DEFINE SBUTTON FROM 195, 36 TYPE 2 ENABLE OF oDlgRec ACTION (lRet:=.F.,nPos:=0,oDlgRec:End())
		
		ACTIVATE MSDIALOG oDlgRec CENTERED
		
		//-- Posiciona cwj en el numero de registro seleccionado
		If lRet .and. nPos <> 0
			dbSelectArea("CWJ")                          
		   CWJ->(dbSetOrder(1))
		   IF 	CWJ->(dbSeek(fwcodfil("CWJ")+aItems[nPos,1]))
		   		cClave := CWJ->CWJ_CODMNE
		   	EndIF 
		   	
		   If aT('+', __cCodMne) > 0
		   		__cCodMne += cClave
		   	Else
		   		__cCodMne := cClave
		   	EndIf
		Endif
	Else
		Aviso(STR0059,STR0060,{'Ok'})//"No hay informaci¢n para consultar."
	EndIF
	
	RestArea(aArea)			
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaCve  ºAutor  ³Mayra camargo       º Data ³ 21/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca la posición de una clave en el listbox y retorna      º±±
±±º          ³su posición                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CTBA093                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscaCve(oLbx1, aItems, nOrd, aOrdenes, cBusca)
	Local nPos := 0
	Local nCol := aOrdenes[nOrd]
	
	cBusca := Upper(Trim(cBusca))
	nPos := ASCAN(aItems, {|aVal| aVal[nCol]=cBusca} ) // valor corto de lado derecho del '=' puede coincidir; es como softseek
	
	If nPos == 0
		nPos := oLbx1:nAt
	EndIf

Return nPos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReOrdena  ºAutor  ³Mayra camargo       º Data ³ 21/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Re Ordena los elementos de un listbox según el índice.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CTBA093                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Reordena(oLbx1,aItems,nOrd)

	CursorWait()
	
	If nOrd == 1
		aItems := aSort(aItems,,,{|x,y| x[1]+x[2] <= y[1]+y[2] }) 
	ElseIf nOrd == 2
		aItems := aSort(aItems,,,{|x,y| x[2]+x[1] <= y[2]+y[1] }) 
	Endif
	
	oLbx1:SetArray(aItems)
	oLbx1:nAt := 1
	oLbx1:bLine := bLinea
	oLbx1:Refresh()
	
	CursorArrow()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fFilMne    ³ Autor ³  Mayra.Camargo       ³ Data ³21/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validar sintáxis                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fFilMne(@ExpC1,@ExpC2,@ExpL3,@ExpC4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ uRet: Array o Logico            	                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93VOP, CTB93CWJFIL                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Operador                                           ³±±
±±³          ³ ExpC2 = Operando                                           ³±±
±±³          ³ ExpL3 =  .T. si sera un Array, .F. si retornará un Lógico  ³±±
±±³          ³ ExpC4 = Código del Mnemónico                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fFilMne(cOper,cOperando,lOpt,cCodMne,lTpMne)
	
	Local aArea 		:= getArea()
	Local cRet 		:= ""
	Local nPos 		:= 0
	Local cTpOp		:= "U"
	Local nPosTpOp	:= 0
	Local lAdd		:= .F.
	Local aRet		:= {}
	Local cTpfor		:= "U"
	Local lTodos	:= .F.
	Local uRet
	Local cCodFOR 	:= GetMemVar("CWK_CODFOR") //--- codigo de la Formula
	Default lOpt 	:= .T. //indica que regresara un Array
	Default cCodMne	:= "" //codigo de Mnemónico
	Default lTpMne 	:= .F.
	
	dbSelectArea("CWJ")
	CWJ->(dbSetOrder(1))
	CWJ->(dbGotop())
	
	nPosTpOp := IIf("1" $ cOperando,5,7)	
	If "CWK_VALOR" $ cOperando
		nPos := 1
		lTodos := .T.
	Else
	nPos :=  aScan(__aCT93Oper, { |x,y| x[1] == cOper }) 
	EndIF 
	
	If nPos > 0
		cTpOp := __aCT93Oper[nPos,nPosTpOp]
		
		
		//para validacion individual de Mnemónicos
		If lOpt == .F. .And. !Empty(cCodMne) 
			CWJ->(dbSeek(xFilial("CWJ")+cCodMne))
		EndIf
		While CWJ->(!Eof())
			
			If !lTodos
			Do Case
				Case CWJ->CWJ_TIPDAT == "1"
					cTpFor := fGetTpSX3(CWJ->CWJ_CAMPO)
					IF cTpFor $ cTpOP .or. cTpOp == "CAMPO"						
						lAdd := .T.					
					EndIF										
				Case CWJ->CWJ_TIPDAT == "2" .and. cTpOp == "TABLA"
					lAdd := .T.
				Case CWJ->CWJ_TIPDAT == "3" .AND. (cTpOp <> "TABLA" .OR.  cTpOp <> "CAMPO"	)
					cTpFor:=fGetTpDato(CWJ->CWJ_DATVIN,"CWK")
					IF cTpFor $ cTpOp
						lAdd := .T.
					EndIF
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Si el tipo de dato del operando es una Formula (cwj_tipdat='3'³
				³validar que la formula asociada al mnemónico (cwj_datvin) no  ³ 
				³sea la misma que la que se está registrando                   ³    
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
					If CWJ->CWJ_DATVIN==cCodFOR .And. !lOpt
						__lMDtVin:= .F.
							lAdd := .T.
					EndIf
						
				Case  CWJ->CWJ_TIPDAT == "4" .AND. (cTpOp <> "TABLA" .OR.  cTpOp <> "CAMPO"	)
					cTpFor:=fGetTpDato(CWJ->CWJ_DATVIN,"CWN")
					IF cTpFor $ cTpOp
						lAdd := .T.
					EndIF	
				Case  CWJ->CWJ_TIPDAT == "5" .AND. (cTpOp <> "TABLA" .OR.  cTpOp <> "CAMPO"	)
					lAdd := .T.
				Case  CWJ->CWJ_TIPDAT == "6" .AND. (cTpOp <> "TABLA" .OR.  cTpOp <> "CAMPO"	)
					cTpFor := Valtype(&(CWJ->CWJ_VALOR))
					lAdd := .T.
				Otherwise
					lAdd := .F.						
			EndCase
			Else
				lAdd := .T.
			EndIf
			If lOpt
				If lAdd
					aAdd(aRet,{CWJ->CWJ_CODMNE	,;
								CWJ->CWJ_DESCRI	,;
								CWJ->CWJ_TIPDAT	,;
								CWJ->CWJ_GRUPO	,;
								CWJ->CWJ_TABLA	,;
								CWJ->CWJ_CAMPO	,;
								CWJ->CWJ_DATVIN	,;
								CWJ->CWJ_FUNRPO	,;
								CWJ->CWJ_VALOR	})
				End If
				lAdd := .f.
				uRet := aRet
				CWJ->(dbSkip())								
			ElseIF ltpMne
				uRet := cTpFor
				CWJ->(dbCloseArea())	
				RestArea(aArea)					
				Return uRet		
			Else
				//para validacion individual de Mnemónicos retorna boleano
				uRet := lAdd
				Exit	
			EndIf							
		EndDo
		

	EndIf
	CWJ->(dbCloseArea())	
	RestArea(aArea)

Return uRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fGetTpSx3  ³ Autor ³  Mayra.Camargo       ³ Data ³21/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtiene el Tipo de Dato del Campo                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGetTpSx3(@ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTipo            	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93VOP, fFilMne                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nombre del Campo                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGetTpSx3(cCampo)
	Local aArea := getArea()
	Local cTipo := "U"
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	
	If SX3->(dbSeek(cCampo))
		cTipo := SX3->X3_TIPO	
	EndIF 
	
	RestArea(aArea)
Return cTipo	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fGetTpDato ³ Autor ³  Mayra.Camargo       ³ Data ³21/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtiene el Tipo de Dato del Campo  CWN_TIPDAT, CWK_TIPDAT  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGetTpDato(@ExpC1,@ExpC2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet            	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fFilMne                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo                                             ³±±
±±³          ³ ExpC2 = Tabla                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function fGetTpDato(cCodigo,cTab)
	Local aArea 	:= getArea()
	Local cRet	:= ""
	
	cRet:= POSICIONE(cTab,1,FWCODFIL(cTab)+cCodigo,cTab + "_TIPDAT")
		
	Do Case
		Case cRet == "1"
			cRet := "N"
		Case cRet == "2"
			cRet := "C"
		Case cRet == "3"
			cRet := "D"
		Otherwise
			cRet := "U"	
	EndCase 
	
	RestArea(aArea)

Return cRet


//+-----------------------------------------------------------------------------------------------+//
//|DEFINICIÓN DE OPERADORES																					|
//+-----------------------------------------------------------------------------------------------+//


// Define el array con los operadores disponibles, el tipo de operandos que requiere y su sintaxis
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ fDefOper  ³ Autor ³  Mayra.Camargo       ³ Data ³21/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define el array con los operadores disponibles, el tipo    ³±±
±±³          ³ de operandos que requiere y su sintaxis                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fDefOper()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aOper            	                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA093                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fDefOper()

	Local aOper := {}
	
	// 				Codigo	Descripcion	Tipo					Op1			Tipo Op1.	Op2		Tipo Op2	Sintaxis															Sintaxis 2
	
	//--operadores aritméticos
	
	AADD(aOper	,{	"01"	,STR0017		,"A"	,"O"		,"N"		,"O"	,"N"		, "OP1+OP2" 											, ""	})
	AADD(aOper	,{	"02"	,STR0018		,"A"	,"O"		,"N"		,"O"	,"N"		, "OP1-OP2" 											, ""	})
	AADD(aOper	,{	"03"	,STR0019		,"A"	,"O"		,"N"		,"O"	,"N"		, "OP1*OP2" 											, ""	})
	AADD(aOper	,{	"04"	,STR0020		,"A"	,"O"		,"N"		,"O"	,"N"		, "OP1/OP2" 											, ""	})
	AADD(aOper	,{	"05"	,STR0021		,"A"	,"O"		,"N"		,"O"	,"N"		, "(OP1/100)*OP2" 									, ""	})
	AADD(aOper	,{	"06"	,STR0022		,"A"	,"O"		,"D"		,"O"	,"N"		, "RECMOEDA(CTOD('OP1'),OP2)"						, ""	})
	
	//--Operadores Condicionales
	
	AADD(aOper	,{	"07"	,STR0023		,"C"	,"O"		,"CDN"		,"O"	,"CDN"		, "OP1>OP2"											, "IF(OP1>OP2"	})
	AADD(aOper	,{	"08"	,STR0024		,"C"	,"O"		,"CDN"		,"O"	,"CDN"		, "OP1<OP2" 											, "IF(OP1<OP2"	})
	AADD(aOper	,{	"09"	,STR0025		,"C"	,"O"		,"CDN"		,"O"	,"CDN"		, "OP1<>OP2"											, "IF(OP1<>OP2"	})
	AADD(aOper	,{	"10"	,STR0026		,"C"	,"O"		,"C"		,"O"	,"C"		, "OP1$OP2"	 										, "IF(OP1$OP2"	})
	AADD(aOper	,{	"11"	,STR0027		,"C"	,"O"		,"C"		,"O"	,"C"		, "AT(OP2,OP1) == 1"									, "IF(AT(OP2,OP1)==1"  	})
	AADD(aOper	,{	"12"	,STR0028		,"C"	,"O"		,"C,D"		,"V"	," "		, "EMPTY(OP1)"										, "IF(EMPTY(OP1)"	})
	AADD(aOper	,{	"13"	,STR0029		,"C"	,"O"		,"TABLA"	,"O"	,"CAMPO"	, "OP1->(DBSEEK(XFILIAL('OP1')+OP2))"				, "IF(OP1->(DBSEEK(XFILIAL('OP1')+OP2))"	})
	AADD(aOper	,{	"14"	,STR0030		,"C"	,"O"		,"C"		,"V"	," "		, "FUNNAME() == OP1" 								, "IF(FUNNAME()==OP1" 	})
	AADD(aOper	,{	"15"	,STR0031		,"C"	,"O"		,"CDN"		,"O"	,"CDN"		, "OP1==OP2" 											, "IF(OP1==OP2"	})
	
	//Operadores de cadenas
	
	AADD(aOper	,{	"16"	,STR0032		,"S"	,"O"		,"N"		,"V"	," "		, "STR(OP1)" 											, ""	})
	AADD(aOper	,{	"17"	,STR0033		,"S"	,"O"		,"C"		,"V"	," "		, "VAL(OP1)" 											, ""	})
	AADD(aOper	,{	"18"	,STR0034		,"S"	,"O"		,"C"		,"V"	," "		, "ALLTRIM(OP1)" 										, ""	})

	//Operadores Diccionario
	
	AADD(aOper	,{	"19"	,STR0035		,"D"	,"O"		,"TABLA"	,"V"	," "		, "XFILIAL('OP1')" 									, ""	})
	AADD(aOper	,{	"20"	,STR0036		,"D"	,"O"		,"C"		,"V"	," "		, "GETMV(OP1)"										, ""	})
	 
	//Operadores numéricos
	AADD(aOper	,{	"21"	,STR0037		,"N"	,"O"		,"N"		,"O"	,"N"		, "ROUND(OP1,OP2)" 									, ""	})
	AADD(aOper	,{	"22"	,STR0038		,"N"	,"O"		,"N"		,"O"	,"N"		, "MOD(OP1,OP2)"										, ""	})
	AADD(aOper	,{	"23"	,STR0039		,"N"	,"O"		,"N"		,"O"	,"N"		, "ROUND(OP1,OP2)" 									, ""	})
	
	//Operadores lectura de tablas	
	AADD(aOper	,{	"24"	,STR0040		,"T"	,"O"		,"C"		,"O"	,"C"		, "POSICIONE('SB1',1,XFILIAL('SB1')+OP1,OP2)" 	, ""	})
	AADD(aOper	,{	"25"	,STR0041		,"T"	,"O"		,"C"		,"O"	,"C"		, "POSICIONE('SED',1,XFILIAL('SED')+OP1,OP2)" 	, ""	})
	AADD(aOper	,{	"26"	,STR0042		,"T"	,"O"		,"C"		,"O"	,"C"		, "POSICIONE('SF4',1,XFILIAL('SF4')+OP1,OP2)" 	, ""	})
	AADD(aOper	,{	"27"	,STR0043		,"T"	,"O"		,"C"		,"O"	,"C"		, "POSICIONE('SA2',1,XFILIAL('SA2')+OP1,OP2)" 	, ""	})
	AADD(aOper	,{	"28"	,STR0044		,"T"	,"O"		,"C"		,"O"	,"C"		, "POSICIONE('SA1',1,XFILIAL('SA1')+OP1,OP2)" 	, ""	})
	AADD(aOper	,{	"29"	,STR0045		,"T"	,"O"		,"C"		,"O"	,"C"		, "POSICIONE('SBM',1,XFILIAL('SBM')+OP1,OP2)" 	, ""	})
	
	// Operadores de Retorno
	AADD(aOper	,{	"30"	,STR0046		,"F"	,"O"		,"CND"		,"V"	," "		, "OP1"												, ""	})
	
	//Nuevos operadores
	
	AADD(aOper	,{	"31"	,STR0141	,"S"	,"O"		,"C"		,"O"	,"C"		, "OP1+OP2"												, ""	})
	
	
Return aOper

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTB93VOP    ³ Autor ³ Alfredo Medrano     ³ Data ³22/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida el Operando 1 y Operando 2. Mnemónicos (M_),        ³±±  
±±³          ³ Valores Numéricos, caracteres y Números de secuencia (S_)  ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB93VOP()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID: CWL_OPER1, CWL_OPER2                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB93VOP()
Local aArea 		:= getArea()
Local lRet 		:= .T. 			
Local nPos 		:= 0
Local nDesc 		:= 2
Local nTip 		:= 3
Local cTpOp		:= "U"
Local nPosTpOp	:= 0
Local cTipo		:= ""
Local aValores	:= {}
Local ni			:= 0
Local cValor		:= ""
Local cStr		:= ""
Local oMdl		:= FwModelActivate()
local cOper 		:= oMdl:GetValue("CWLDETAIL","CWL_OPER") // obtiene el valor
Local nMenm 		:= TamSX3("CWJ_CODMNE")[1] //Obtiene tamaño de campo
Local cMemDat		:= Alltrim(&(ReadVar())) //obtiene el valor del campo 
Local cOprndo		:= ReadVar() 	// obtiene el Nombre del campo
Local uStr
Local cTipO1		:= ""
Local cValOp1		:= ""
Local dValor		
Local cTipoOP		:= ""
Local cMsgOp		:= ""

nPosTpOp := IIf("1" $ cOprndo,5,7)	 						// si es Operando 1 = columna 5 // si es Operando 2 = columna 7
nPos :=  aScan(__aCT93Oper, { |x,y| x[1] == cOper }) 	//Obtiene la Fila en base al operador seleccionado del array con los operadores disponibles

If nPos > 0
		cTpOp := __aCT93Oper[nPos,nPosTpOp] //Obtiene el tipo de Operando en base a la Fila y la Columna
		cTipo := __aCT93Oper[nPos,nTip] //Obtiene el tipo operador en base a la Fila y la Columna
		cDesc := __aCT93Oper[nPos,nDesc] //Obtiene la drescripción del operador en base a la Fila y la Columna
		
		IF "D" $ cTpOp
				cTipoOp += STR0124 + "-" + STR0125 + chr(10) + chr(13)
		EndIF
		IF "C" $cTpOp 
				cTipoOp += STR0123 + "-" + STR0127 + chr(10) + chr(13)
		EndIf
		IF "N" $ cTpOp 
				cTipoOp += STR0122 + "-" + STR0128 + chr(10) + chr(13)
		ElseIf cTpOp $ "CAMPO|TABLA" .AND. cTpOp <> "C"
				cTipoOp := cTpOp			
		EndIF
		
EndIf

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Verifica si existe algún separador “+” para Operadores        ³
³Condicionales(Tipo C) y Operadores lectura de tablas(Tipo T)  ³      
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aValores:=SEPARA(cMemDat,"+")

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
|Valida los Tipos: 			   							       |
|"A" = operadores aritméticos  -  "S" = Operadores de cadenas  |
|"D" = Operadores Diccionario  -  "N" = Operadores numéricos   |
|"N" = Operadores numéricos	   -  "R" = Operadores de Retorno  |
|Estos Tipos no aceptan contactenacion de valores			   |
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If !(cTipo $ "C|T")
	If Len(aValores) > 1 
		lRet := .F.
		Help( ,, OemToAnsi(STR0061),, OemToAnsi(STR0062) + cOper + " - " + cDesc +  OemToAnsi(STR0063),1, 0 )   // "Aviso" // "El operador" //" no acepta concatenación de valores."
		Return lRet
	EndIf
EndIf 


For ni:= 1 to len(aValores) //Recorre los valores Obtenidos
	cValor:=""
	If !empty(aValores[ni])
		If substr(aValores[ni],1,2)=="M_" // Si es Mnemónico
			cValor:=padr(aValores[ni],nMenm) //alinea el valor dentro de la longitud del campo
			If CTB93VLMNE(cValor) //Verifica si el Mnemónico Existe
				If !fFilMne(cOper,cOprndo,.F.,cValor,.F.) //Se Validan los mnemónicos según el operador y si es el operando 1 o 2
					Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0064) + aValores[ni] + OemToAnsi(STR0070) + OemToAnsi(STR0116) + cTipoOp,1, 0 ) //"Aviso" // "El Tipo de dato del Mnemónico "//" no es valido, no coincide con el tipo de dato del Operando "
					lRet :=.f.
				Else
					If !__lMDtVin // bandera que indica que la formula asociada al mnemónico (cwj_datvin) no sea la misma que la que se está registrando 
						Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0106) + aValores[ni] + OemToAnsi(STR0070)+ OemToAnsi(STR0116)+cTipoOP,1, 0 ) //"Aviso" // "El Tipo de dato del Mnemónico "//" no es valido, no coincide con el tipo de dato del Operando "
						__lMDtVin	:= .T.
							 lRet	:= .F.
					EndIf
				EndIf
			Else
				Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0066) + aValores[ni],1, 0 ) // "Aviso"// "No es Un Mnemónico :"
				lRet:= .f.
		    Endif
		Else
			If substr(aValores[ni],1,3)=="M->" //Si es variable de memoria
		    	cValor:=padr(substr(aValores[ni],4,len(aValores[ni])),10) //alinea el valor dentro de una longitud
              lRet  := CTB92BC(cValor) //busca el campo en sx3
           	If !lRet 
              		Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0067) + aValores[ni] + OemToAnsi(STR0068),1, 0 )   // "Aviso" // "No existe el campo:" // "en el diccionario de datos." 
              ElseIf !(fGetTpSx3(cValor)  $ cTpOp) //Valida los tipos de dato del campo y del Operando
					Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0069) + aValores[ni] + OemToAnsi(STR0070) + OemToAnsi(STR0116) + cTipoOp,1, 0 ) //"El Tipo de dato del Campo " //" no es valido, no coincide con el tipo de dato del Operando "
					lRet :=.f.
              EndIf 
           Else 
           	If CTB93VART(aValores[ni]) // valida la variable de Tabla
              	cValor:=padr(substr(aValores[ni],6,len(aValores[ni])),10) //alinea el valor dentro de una longitud
              	If cTpOp == "CAMPO"
	              lRet  := CTB92BC(cValor) //busca el campo en sx3
	              If !lRet 
	              		Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0067)+aValores[ni]+OemToAnsi(STR0068),1, 0 )   // "Aviso" // "No existe el campo:" // " en el diccionario de datos."
	              ElseIf !(fGetTpSx3(cValor) $ cTpOp) //Valida los tipos de dato del campo y del Operando
				   		Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0069) + aValores[ni] + OemToAnsi(STR0070) + OemToAnsi(STR0116) + cTipoOp,1, 0 )//"Aviso" //"El Tipo de dato del Campo " //" no es valido, no coincide con el tipo de dato del Operando "
						lRet := .F.
	              EndIf 
	             Elseif cTpOp $ "TABLA"
	             	lRet := .T.	             
	             EndIf	             
            	Else
              		cStr := Alltrim(aValores[ni])
              		If aT('"', cStr) > 0  // Verifica si el valor contiene comillas
              			If  (Substr(cStr, 1,1)!= '"' .OR. Substr(cStr,Len(cStr),1)!='"')            
		             	 	lRet	:= .F.
		              		Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0071)+ cStr + OemToAnsi(STR0072),1, 0 )//"Aviso"//"El dato " // " de tipo Carácter debe ir entre comillas. "
              			ElseIf cTpOp != "C" //si el valor esta entre comillas debe ser de Tipo Carácter (C)
              		    
		             	 	lRet	:= .F.
              				Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0075) + cStr + OemToAnsi(STR0070) + OemToAnsi(STR0116)+cTipoOp,1, 0 ) //"El Tipo de dato del valor asignado  " //" no es valido, no coincide con el tipo de dato del Operando "
              								              					
              			EndIf
              		Else
	              		/*IF Substr(cStr, 1,2) == "S_" //Si es variable de Números de Secuencia
	              			cValor := substr(cStr,3,len(aValores[ni]))
	              			If !CTB93CAMSEC(cValor) //Valida que exista el número de secuencia      
			             		lRet := .F.
			              		Help( ,, OemToAnsi(STR0061),,OemToAnsi(STR0071) + cStr + OemToAnsi(STR0073),1, 0 )//"Aviso"//"El dato " // " no es un número de secuencia valido. "
	              			EndIf
	              		Else*/
	              		
	              		IF at("/",cStr) == 0 // Si no contiene diagonales, entonces es un dato tipo Numérico 
	              			IF genErro(cStr)
		              			IIF(Val(cStr)!=0 ,uStr:= Val(cStr),IIF("0" $ cStr,uStr:=Val(cStr), uStr:=cStr))//convierte la cadena en dato numérico o deja el string dependiendo el contenido del campo  
		              			cVTip := ValType(uStr)
		              			IF !(cVTip $ cTpOp) //Verifica que el tipo de dato este contenido en los Tipos del operador seleccionado          
				             		lRet := .F.
		              				Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0075) + cStr + OemToAnsi(STR0070) +  OemToAnsi(STR0116) + cTipoOp,1, 0 ) //"El Tipo de dato del valor asignado  " //" no es valido, no coincide con el tipo de dato del Operando "
		              			ElseIf cVTip == "C" //Si el valor es carácter debe tener un identificador asignado
		              				cValor:=cStr            
				             		lRet := .F.
				              		Help( ,, OemToAnsi(STR0061),,OemToAnsi(STR0071) + cValor + OemToAnsi(STR0074),1, 0 )//"Aviso"//"El dato " //" no tiene un identificador (“S_”, “M_”, “M->”,“Alias->” ó “”) asignado. "
				              	ElseIF cVTip == "U"
				              		cValor	:= uStr 
				              		cMsgOp += OemToAnsi(STR0071) + cValor + OemToAnsi(STR0074) //"Aviso"//"El dato " //" no tiene un identi
				              		cMsgOp += STR0121 + STR0116										// . Tipo de dato esperado
				              		cMsgOp += cTipoOp
				              		lRet := .F.		              		
				              		Help( ,, OemToAnsi(STR0061),,cMsgOp,1, 0 )
		              			EndIf
	              			Else
	              				cMsgOp += OemToAnsi(STR0071) + cValor + OemToAnsi(STR0074) //"Aviso"//"El dato " //" no tiene un identi
				              	cMsgOp += STR0121 + STR0116	 + chr(10) + chr(13)									// . Tipo de dato esperado
				              	cMsgOp += cTipoOp
				              	lRet := .F.			              		
				              	Help( ,, OemToAnsi(STR0061),,cMsgOp,1, 0 )
	              			EndIf
	              		Else
	              			//Debe ser un tipo fecha
              				dValor := IIF("/" $ cStr,CTOD(cStr),STOD(cStr))
								
								IF ValType(dValor) $ cTpOp
									If Empty(dValor) .or. dValor == Nil
										lRet	:= .F.
	              					Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0075) + cStr + OemToAnsi(STR0070) + OemToAnsi(STR0116)+ cTpOp,1, 0 ) //"El Tipo de dato del valor asignado  " //" no es valido, no coincide con el tipo de dato del Operando "										
									EndIF	
								Else
									lRet	:= .F.
	              				Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0075) + cStr + OemToAnsi(STR0070) + OemToAnsi(STR0116)+ cTpOp + STR0121 + STR0125,1, 0 ) //"El Tipo de dato del valor asignado  " //" no es valido, no coincide con el tipo de dato del Operando "									
								EndIF
	              				              				              			
	              		EndIF
	              		//EndIf
             		EndIf
	           EndIf  	
           EndIf
      EndIf
      
      //Validar que si es el operando 2, sea del mismo tipo que el operando 1
      If "2" $ cOprndo .and. lRet
      		cValOp1:= oMdl:GetValue("CWLDETAIL","CWL_OPER1")      		
      		lRet 	:= fCompareOp(cOper,cValOp1,aValores[ni])
		EndIF
      
	EndIf
	
Next	

RestArea(aArea)
Return lRet

//Valida que el tipo de dato del operando 1 y 2 sea igual en caso de que así lo defina el tipo de operador usado.
Static Function fCompareOp(cOper,cOp1,cOp2)
	Local aArea 	:= getArea()
	Local lRet 	:= .T.
	Local cTipOp1	:= ""
	Local cTipOp2	:= ""
	Local cTpOp1	:= "U"
	Local cTpOp2	:= "U"
	Local nPos	:= 0
	Local cTipoOp	:= ""
	Local cOPAux	:= ""
	Local cTpAux	:= "U"

	
	cOpAux := cOp2
	
	nPos 	:=  aScan(__aCT93Oper, { |x,y| x[1] == cOper }) 	//Obtiene la Fila en base al operador seleccionado del array con los operadores disponibles
	cTpOp1	:= __aCT93Oper9193[nPos,5]
	cTpOp2	:= __aCT93Oper9193[nPos,7]
	
	Do Case
		Case "D" $ cTpOp1  
			cTipoOp := STR0124 + "-"
		Case "C" $ cTpOp1 .and. cTpOp1 <> "CAMPO"
			cTipoOp := STR0123 + "-"
		Case "N" $ cTpOp1
			cTipoOp := STR0122 + "-"
	EndCase 
			
	IF !((Substr(cOp1,1,2) $ "M_"))
		
		If !('"' $ cOp1) .and. at("/",cOp1) > 0
			cTipOp1 := Valtype(cTod(cOp1))
			cOP1 := "CTOD('" + alltrim(cOp1) + "')"
		Else	
			If !(cTpOp1	$ "TABLA")			
				If genErro(cOp1) 				
					cTipOp1 := Valtype(&(cOp1))
					cOp1 := cOp1
				Else
					Help( ,,OemToAnsi(STR0061),,STR0135  ,1, 0 )
					Return .F.
				EndIF
			EndIf
		EndIf				
	ElseIf "+" $ cOp1		//Concatenación de mnemónicos en un solo operando.
		//Separamos cada mnemónico del operando 1 y procesamos 
		cTipOp1 := fNmeComp(cOp1,cTpOp1,cOper)					
	Else
		cTipOp1 := fFilMne(cOper,cOp1,.F.,cOp1,.T.)
	EndIf 
	
	IF !(Substr(cOp2,1,2) $ "M_")
		If !('"' $ cOp2) .and. at("/",cOp2) > 0
			cTipOp2 := Valtype(cTod(cOp2))
			cOP2 := "CTOD('" + ALLTRIM(cOp2) + "')"
		Else 	
			if cTpOp2 <> "CAMPO"			
				If genErro(cOp2) 				
					cTipOp2 := Valtype(&(cOp2))
					cOp2 := cOp2
				Else
					Help( ,,OemToAnsi(STR0061),,STR0135  ,1, 0 )
					Return .F.
				EndIF
			EndIF
		EndIf
	ElseIf "+" $ cOp2		//Concatenación de mnemónicos en un solo operando.
		//Separamos cada mnemónico del operando 1 y procesamos 
		cTipOp1 := fNmeComp(cOp2,cTpOp2,cOper)	
	Else
		cTipOp2 := fFilMne(cOper,cOp2,.F.,cOp2,.T.)
	EndIf 
		
	If cTpOp1 == cTpOp2
		IF cTipOp1 <> cTipOp2						
			Help( ,,OemToAnsi(STR0061),,OemToAnsi(STR0117) + cOpAux + OemToAnsi(STR0118) + STR0116 + cTipoOp ,1, 0 )
			Return .F.
		EndIf				
	EndIf
	
	RestArea(aArea)
Return lRet

Static function fNmeComp(cOp,cTpOp,cOper)
	Local aOp1		:= {}
	Local aTpOp2 := {}
	Local nI		:= 0
	Local cRet	:= "U"
	Local cAux	:= ""
	Local cTipOP	:= "U"
		
		// separar mnem´nicos
		aOP1 := separa(cOp,"+")
		
		//Verificar el tipo de dato por cada mnemonico en el operador
		For nI := 1 to len(aOp1)
			IF Substr(aOP1[nI],1,2) $ "M_"  
				cTipOp :=  fFilMne(cOper,aOP1[nI],.F.,aOP1[nI],.T.)
								
			Else
				If !('"' $ aOP1[nI]) .and. at("/",aOP1[nI]) > 0
					cAux := Valtype(cTod(aOP1[nI]))
				Else	
					If !(cTpOp $ "TABLA")			
						If genErro(aOP1[nI]) 				
							cTipOp := Valtype(&(aOP1[nI]))	
						EndIF
					EndIf
				EndIf
			EndIf
		Next nI	
		
		cRet := cTipOp 			
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTB93VART   ³ Autor ³ Alfredo Medrano     ³ Data ³23/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida que exista la variable de Tabla			          	 ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93VART(@ExpC1)                                   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93VALOPER                             				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Variable de tabla (Alias->campo)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB93VART(cVarTab)
Local lRet 	:= .T.
Local aArea 	:= getArea()
Local cTabVar 	:= ""
Local cSep	   	:= ""	

If !Empty(cVarTab)
	DbSelectArea("SX2")
	SX2 ->(DBSETORDER(1))	
	//Si es variable de Tabla
	cTabVar := padr(substr(cVarTab,1,3),3) // obtiene la tabla
	cSep	:= substr(cVarTab,4,2) // obtiene el apuntador
	
	If !SX2->(DbSeek(cTabVar,.T.)) .And. cSep!="->"
		lRet := .F.
	EndIf
	
EndIf				
RestArea(aArea)
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTB93CAMSEC ³ Autor ³ Alfredo Medrano     ³ Data ³24/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida que exista el número de secuencia 			      ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93CAMSEC(@ExpC1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93VALOPER                             				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Numero de Secuencia                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB93CAMSEC(cSec)
Local aArea 	:= getArea()
Local oModel 	:= FWModelActive()
Local oModelCWL	:= oModel:GetModel( 'CWLDETAIL' )
Local nI 		:= 0
Local lRet 		:= .T.
Local cVal 		:= ""

If !Empty(cSec)
	For nI := 1 To oModelCWL:Length()
		oModelCWL:GoLine( nI )
		cVal := oModelCWL:GetValue("CWL_SEC")
		If cSec != cVal
			lRet := .F.
			Exit
		EndIf   
	Next
EndIf
RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTB93EXPR   ³ Autor ³ Alfredo Medrano     ³ Data ³24/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pantalla que permite generar una expresión aritmética      ³±±
±±³			 ³ haciendo uso de operadores y mnemónicos                    ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93EXPR()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cExp	                                                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ consulta CTB931                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB93EXPR()
Local oDlg 
Local oBtnOk 
Local oBtnCa
Local oBtnLmp 
Local oBtnAgr
Local oExpsn
Local oCmbOper
Local oCmbTab
Local oGroup
Local oCmbCampo
Local oGetHlp
Local cGetHlp	:= ""
Local cCmbCampo	:= ""
Local cCmbTab	:= ""
Local cCmbOper := ""
Local cExpsn	:= ""
Local cStrExp	:= ""
Local cGrupo	:= space(6)
Local cTabla 	:= "CZ"
Local aArea		:= getArea() 
Local aOper		:= {"","+","-","*","/",")","("}
Local iSX5		:= RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE") 
Local iCWJ		:= RETORDEM("CWJ","CWJ_FILIAL+CWJ_CODMNE")

	//Crea el cuadro de dialogo 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,415 PIXEL TITLE OemToAnsi(STR0080) // "Editor de Expresiones"
	
	oSay	:= tSay():New(05,05,{||OemToAnsi(STR0081)},oDlg,,,,,,.T.)	// "Expresión a retronar"
	@ 13,05   GET oExpsn VAR cExpsn MEMO  SIZE 200,30 WHEN .T. OF oDlg PIXEL	
	oExpsn:bRClicked := {||AllwaysTrue()}
	
	oBtnLmp	:= tButton():New(45,140,OemToAnsi(STR0082),oDlg,{||( cExpsn := "" )} ,30,12,,,,.T.) //  "Limpiar"
	oBtnAgr	:= tButton():New(45,175,OemToAnsi(STR0083),oDlg,{||( cExpsn += cStrExp )},30,12,,,,.T.)  // "Agregar"
    
	oSay	:= tSay():New(45,05,{||OemToAnsi(STR0084)},oDlg,,,,,,.T.)	//"Operadores"
	oCmbOper:= tComboBox():New(53,05,{|u|if(PCount()>0,cCmbOper:=u,cCmbOper)},aOper ,40,20,oDlg,,{|| cExpsn := cExpsn + cCmbOper },,,,.T.,,,,,,,,,'cCmbOper')  // ComboBox Operadores
	
	oGroup:= tGroup():New(70,05,233,205,OemToAnsi(STR0085),oDlg,,,.T.)// "Mnemónicos"
	
	oSay	:= tSay():New(78,10,{||OemToAnsi(STR0053)},oDlg,,,,,,.T.) 			// "Grupo"
	@ 86,10   MSGET	cGrupo	  SIZE 060,10 OF oDlg  F3 cTabla VALID obtTabla(cGrupo,@oCmbTab:aitems)   PIXEL HASBUTTON	
		
	oSay	:= tSay():New(78,80,{||OemToAnsi(STR0051)},oDlg,,,,,,.T.) 			// "Descripción"
	@ 86,80   MSGET 	IIF(cGrupo!="",POSICIONE("SX5",iSX5,XFILIAL("SX5")+cTabla+cGrupo,"X5_DESCRI"),"")  SIZE 120,10 WHEN .F. OF oDlg PIXEL
	
	oSay	:= tSay():New(100,10,{||OemToAnsi(STR0054)},oDlg,,,,,,.T.) // "Tabla"
	oCmbTab:= tComboBox():New(108,10,{|u|if(PCount()>0,cCmbTab:=u,cCmbTab)},/*ITEMS*/,190,20,oDlg,,{||MsgRun(OemToAnsi(STR0086), OemToAnsi(STR0087) , {|| CursorWait(),obtCampos(padr(cCmbTab,3),@oCmbCampo:aitems) ,CursorArrow()})},,,,.T.,,,,,,,,,'cCmbTab')// "Favor de Aguardar....." // "Selecionando los Mnemónicos"
		
	oSay	:= tSay():New(121,10,{||OemToAnsi(STR0085)},oDlg,,,,,,.T.) // "Mnemónicos"
	oCmbCampo:= tComboBox():New(129,10,{|u|if(PCount()>0,cCmbCampo:=u,cCmbCampo)},/*ITEMS*/,190,20,oDlg,,{|| cStrExp:=  padr(cCmbCampo,16) },,,,.T.,,,,,,,,,'cCmbCampo')// ComboBox Mnemónicos
	
	oSay	:= tSay():New(142,10,{||OemToAnsi(STR0088)},oDlg,,,,,,.T.) // "Ayuda" 			
  	@ 150,10  GET oGetHlp  VAR	ObtHelp(POSICIONE("CWJ",iCWJ,XFILIAL("CWJ")+ padr(cCmbCampo,16),"CWJ_CAMPO"))	MEMO SIZE 105,80 WHEN .F. OF oDlg PIXEL			
 	oGetHlp:bRClicked := {||AllwaysTrue()}

	oBtnOk	:= tButton():New(235,140,OemToAnsi(STR0012),oDlg,{||( cExpsn, oDlg:End())} ,30,12,,,,.T.) //  "Ok"
	oBtnCa	:= tButton():New(235,175,OemToAnsi(STR0013),oDlg,{|| ( cExpsn := "", oDlg:End() ) },30,12,,,,.T.)  // "Anular"
	
 ACTIVATE MSDIALOG oDlg CENTERED
 
__cExp := cExpsn 
RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ObtTablas  ³ Autor ³ Alfredo Medrano     ³ Data ³28/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene las Tablas de la tabla CWJ de acuerdo al Grupo(CZ) ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtTablas(@ExpC1,@ExpA2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93EXPR                             				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Tabla                                             ³±±
±±³          ³ ExpA2  : Array de Mnemónicos                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function obtTabla(cGrupo,aTablas) 
Local	 aDatos	  	:= {}   
Local 	 aArea		:= getArea()        
Local	 cTmpPer	:= CriaTrab(Nil,.F.)
Local   cQuery		:= "" 
Local   cFilCWH	:= FWCODFIL("CWH")   
Default cGrupo		:= ""
Default aTablas	:= {}
	
	cQuery := " SELECT CWH_TABLA, CWH_DESCRI " 
	CQuery += " FROM " + RetSqlName("CWH") 
 	cQuery += " WHERE CWH_GRUPO='"+ cGrupo +"' " 	//Grupo
 	cQuery += " AND CWH_FILIAL =  '" + cFilCWH + "'"
  	cQuery += " AND D_E_L_E_T_ = ' ' "
  	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
    
    AADD(aDatos,"")
	(cTmpPer)->(dbgotop())//primer registro de tabla
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Llena un array con las tablas obtenidas de la consulta        ³   
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	While  (cTmpPer)->(!EOF())
		AADD(aDatos,(cTmpPer)-> CWH_TABLA + " " + (cTmpPer)->CWH_DESCRI )		
		(cTmpPer)-> (dbskip())	 		
	EndDo
	
	(cTmpPer)->( dbCloseArea())
	
		aTablas := aDatos
	
	restArea(aArea)
	 		
Return  .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³obtCampos   ³ Autor ³ Alfredo Medrano     ³ Data ³28/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtiene los Campos de la tabla CWJ dependiendo de la        ³±±
±±³			 ³tabla(CWH) seleccianada y el tipo de dato = 1 (Campo de BD) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ obtCampos(@ExpA1,ExpC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ byRef -> @aDatos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93EXPR                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1  : Nombre de la tabla                                ³±±
±±³          ³ ExpC2  : Array                                             ³±±				
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function obtCampos(cTabla,aCampos) 
Local 	 aDatos		:= {} 
Local 	 aArea		:= getArea()        
Local	 cTmpPer	:= CriaTrab(Nil,.F.)
Local   cQuery		:= "" 
Local   cFilCWJ	:= FWCODFIL("CWJ")   
Default cTabla		:= ""
Default aCampos	:= {}
	
	cQuery := " SELECT CWJ_CODMNE, CWJ_DESCRI " 
	CQuery += " FROM " + RetSqlName("CWJ") 
 	cQuery += " WHERE CWJ_TABLA='"+ cTabla +"' " 	//Tabla
 	cQuery += " AND CWJ_FILIAL =  '" + cFilCWJ + "'"
 	cQuery += " AND CWJ_TIPDAT =  '1'" // Tipo de Registro 1=Campo de BD
  	cQuery += " AND D_E_L_E_T_ = ' ' "
  	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
    
    AADD(aDatos,"")
	(cTmpPer)->(dbgotop())//primer registro de tabla
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Llena un array con las tablas obtenidas de la consulta        ³   
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	While  (cTmpPer)->(!EOF())
		AADD(aDatos,(cTmpPer)-> CWJ_CODMNE + " " + (cTmpPer)->CWJ_DESCRI )		
		(cTmpPer)-> (dbskip())	 		
	EndDo
	
	(cTmpPer)->( dbCloseArea())
	
		aCampos := aDatos
	
	restArea(aArea)
	 		
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ObtHelp    ³ Autor ³ Alfredo Medrano     ³ Data ³28/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Presenta el Help del campo seleccionado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtHelp(@ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cCadena                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93EXPR                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Nombre del campo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ObtHelp(cCampo)
Local aArea		:= getArea() 
Local cTipo		:= ""
Local nTamanio	:= 0
Local cUsado	:= ""
Local cValid	:= ""
Local cTabla	:= ""
Local nDecimal	:= 0
Local cCadena	:= ""
Default cCampo := ""
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Arma la Cadena que contendrá la ayuda del campo con sus      ³
³características: Campo, Tabla, Help de campo, Validación,     ³  
³Tipo de Dato, Tamaño y Decimal                                ³   
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If !Empty(cCampo)

	DbSelectArea("SX3") 
	SX3 -> (DBSETORDER(2))
	
	If SX3 -> (dbSeek(cCampo))
		cTipo 	:= SX3 -> X3_TIPO
		nTamanio:= SX3 -> X3_TAMANHO
		cTabla	:= SX3 -> X3_ARQUIVO
		nDecimal:= SX3 -> X3_DECIMAL
		If SX3->( X3Uso( X3_USADO ) )
			cUsado := OemToAnsi(STR0089) //"Oblig."
		Else
			cUsado := OemToAnsi(STR0090) // "No Oblig."
		EndIf
		cValid := AllTrim( GetSx3Cache(cCampo, "X3_VALID") )
	EndIF
		
	cCadena := cCampo + " " + OemToAnsi(STR0054) + " " + cTabla + Chr(13)+ Chr(10) //"Tabla"
	cCadena += Ap5GetHelp(cCampo) + Chr(13)+ Chr(10)
	cCAdena += OemToAnsi(STR0091) + ":" + Chr(13)+ Chr(10) // "Validación"
	cCadena += cValid + Chr(13)+ Chr(10)
	cCadena += OemToAnsi(STR0092) +" "+ cTipo +" " //"Tipo   "
	cCadena += OemToAnsi(STR0093) +" "+ Alltrim(str(nTamanio)) +" " // "Tamaño "
	cCadena += OemToAnsi(STR0094) +" "+ cUsado +" " // "Uso    "
	cCadena += OemToAnsi(STR0095) +" "+ Alltrim(str(nDecimal)) +" " // "Decimal"

EndIf

RestArea(aArea)
Return cCadena

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB93FORM ³ Autor ³  Alfredo Medrano      ³ Data ³29/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a formula digitada esta OK                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93FORM(@ExpC1,@ExpL2,@ExpL3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA093                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Expresion                                         ³±±
±±³          ³ ExpL2  : Lógico. indica si solo se evaluará el Campo de BD ³±±
±±³          ³ ExpL3  : Lógico. indica si solo se evaluará la sintaxis del³±±
±±³          ³   		código ADVPL									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB93FORM(cForm,lCampo,lVal)
LOCAL xResult,lRet:=.T. 
LOCAL aRetSyntax	:= {}, cLine := "" , lExec := .T., lTxt
LOCAL cOutMod
Local lOptimize		:= GetNewPar("MV_OPTNFE",.F.) .Or. GetNewPar("MV_OPTNFS",.F.)
Local bBlock
Local nPos
Default cForm		:= &(ReadVar())
Default lCampo		:= .T.
Default lVal			:= .F.

cVarOutMod  := If(Type("cVarOutMod") = "U", "", cVarOutMod)	// Prever chamadas externas
cOutMod	 	:= cVarOutMod + If(Right(cVarOutMod, 1) = ",", "", ",")

While ! Empty(cOutMod)		// Verifico se existe digitada alguma variavel nao disponivel
	If Left(cOutMod, At(",", cOutMod) - 1) $ Upper(cForm)		// no modulo
		Help( " ",1,"ERR_FORM",, 	OemToAnsi(STR0096) + Left(cOutMod, At(",", cOutMod) - 1)+; //"Variable "
									OemToAnsi(STR0097),3,1 ) //"no esta disponible para este modulo"
		Return .F.		
	Endif
	cOutMod := Subs(cOutMod, At(",", cOutMod) + 1)
EndDo

aRetSyntax := ParAnalise(cForm)	// An lise estrutural de sintaxe

IF !empty(aRetSyntax[1])
	Help(" ",1,"ERR_FORM",,OemToAnsi( STR0098 + aRetSyntax[1]),3,0) // Estrutura Inconsistente : 
	Return .f.
Endif

For nPos:=1 to len(aRetSyntax[2])
	cLine	:= upper(aRetSyntax[2][nPos])
	If (	lTxt := (	"LERSTR" $ cLine .or.;
						"LERVAL" $ cLine .or.;
						"LERDATA" $ cLine)) .And. M->CT5_LANPAD > "499"
		Help(" ",1,"CA010TXT")
		Return .F.
	ElseIf "M->" $ cLine .or. "m->" $ cLine
		lExec := .F.		
	Endif
	If "EXECBLOCK" $ cLine .or. lTxt
		// Nao executa execblock nem Funcoes da leitura de Txt no cadastramento
		lExec :=.F.
	EndIf
	If lOptimize .And. ( "CTBANFS"$cForm .Or. "CTBANFE"$cForm )
		lExec := .F.
	EndIf
Next nX

If lExec
	
	If !lVal
		cForm := CTB93VALMNE(cForm,lCampo) // Obtiene la Expresion con los campos del Mnemónico
	EndIf
	
	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		xResult := &cForm
	RECOVER
		lRet := .F.
	END SEQUENCE
	ErrorBlock(bBlock)
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ParAnalise³ Autor ³ J£lio Wittwer         ³ Data ³ 17.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza an lise estrutural de parƒmetros / delimitadores   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ParAnalise(cExpressao)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Vetor [1] cStack -> Se preenchido, indica qual caracter na ³±±
±±³          ³ estrutura n„o est  coerente com a mesma.                   ³±±
±±³          ³ Vetor [2] aParam -> Array com os textos correspondentes    ³±±
±±³          ³ dentro das estruturas.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA080                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ expC1 = Texto a ser analisado.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ParAnalise(cTexto)
Local cStack:=""  , cAspas:=""
Local aSepFunc:={"()","[]","{}"}, aParam:={}
Local nPosAt:=1 , uLastPar:=1 , cPosAtual
Local uAbre , uFecha , cSeparador:=","
// Arranca os caracteres da esquerda se forem 'espa‡o' ou 'TAB'
While left(cTexto,1)==" " .or. left(cTexto,1)==chr(9)
   cTexto:=right(cTexto,len(cTexto)-1)
EndDo
While nPosAt<=len(cTexto)
   cPosAtual:=substr(cTexto,nPosAt,1)
   If cPosAtual==chr(34) .or. cPosAtual==chr(39)	// Achou "ASPAS"
		cAspas:=If(empty(cAspas),cPosAtual,If(cAspas == cPosAtual,"",cAspas))
   Endif
   If empty(cAspas)			// Apenas analiza a estrutura caso nao esteja entre aspas
      uAbre :=ascan(aSepFunc,{|_v|  left(_v,1) == cPosAtual})
      uFecha:=ascan(aSepFunc,{|_v| right(_v,1) == cPosAtual})
      If uAbre+uFecha>0		// Abriu ou Fechou uma estrutura
         If uAbre>0	// Abriu uma estrutura ! Acrescenta no STACK
            If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
               aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            Endif
	         uLastPar:=nPosAt+1	 ; cStack:=cStack+cPosAtual
         Else			// Fechou uma estrutura : Checa o STACK
            If right(cStack,1)==Left(aSepFunc[uFecha],1)	// Se fechou certo, tira do Stack
               cStack:=left(cStack,len(cStack)-1)
				Else	// Estrutura fechada incorretamente
					cStack:=right(aSepFunc[uFecha],1)
					EXIT
            Endif
            If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
               aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            Endif
	         uLastPar:=nPosAt+1
         Endif
      Else	// Verifica separador
			If cPosAtual==cSeparador
            aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            uLastPar:=nPosAt+1
         Endif
      Endif
   Endif
	nPosAt++
EndDo
IF !empty(cTexto) .and. len(aParam) == 0
	aadd(aParam,alltrim(cTexto))
Endif
cStack+=if(empty(cAspas),"",cAspas)
Return {cStack,aParam}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ValMnemo   ³ Autor ³ Alfredo Medrano      ³ Data ³29/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica que el nemónico Exista y obtiene el         	  ³±±
±±³          ³ Campo y su tabla                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValMnemo(@ExpC1,@ExpL2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cCamTab:   Tabla,  Campo o Contenido                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93FORM                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Codigo del Menmónico                              ³±±
±±³          ³ ExpL2  : Lógico. indica si solo se evaluara el Campo de BD ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValMnemo(cCodMne,lCampo)
Local	 aArea	:= getArea()        
Local	 cFilCWJ:= XFILIAL("CWJ")
Local 	 cCampo	:= ""
Local   cTabla	:= "" 
Local	 cCamTab:= ""
Local   cTpMne	:= ""
Default cCodMne:= "" 
Default lCampo := .T.

DbSelectArea("CWJ") 
CWJ -> (DBSETORDER(1))
If CWJ -> (dbSeek(cFilCWJ+cCodMne)) // verifica que el Mnemónico Exista
	cTpMne := CWJ -> CWJ_TIPDAT
	Do Case
		Case cTpMne == '1'  // verifica que el Mnemónico sea de Tipo de Registro 1=Campo de BD
			cCampo := CWJ ->CWJ_CAMPO // Obtiene el Campo
			DbSelectArea("SX3") 
			SX3 -> (DBSETORDER(2))
			If SX3 -> (dbSeek(cCampo)) // verifica que el campo Exista en SX3
				cTabla	:= SX3 -> X3_ARQUIVO // Obtiene la tabla
				cCamTab	:= cTabla + "->" + cCampo //Concatena la tabla y campo
				
				If IsMemVar("__aCWQTab")
					If  aScan(__aCWQTab, { |x| x == cTabla }) == 0
						aADD(__aCWQTab,cTabla)
					EndIF
				EndIF
			EndIf
		Case cTpMne == '2' .AND. !lCampo // verifica que el Mnemónico sea de Tipo de Registro 2=Tabla
			cCamTab := CWJ->CWJ_TABLA // Obtiene la tabla
			If IsMemVar("__aCWQTab")
				If  aScan(__aCWQTab, { |x| x[1] == cCamTab }) == 0
					aADD(__aCWQTab,cCamTab)
				EndIF
			EndIF
		Case cTpMne == '3' .AND. !lCampo // verifica que el Mnemónico sea de Tipo de Registro 3=Formula
			cCamTab := POSICIONE("CWK",1,FWCODFIL("CWK")+CWJ->CWJ_DATVIN,"CWK_ADVPL")// Obtiene codigo ADVPL
		Case cTpMne == '4' .AND. !lCampo // verifica que el Mnemónico sea de Tipo de Registro 4=Funcion
			cCamTab := POSICIONE("CWN",1,FWCODFIL("CWN")+CWJ->CWJ_DATVIN,"CWN_ADVPL")// Obtiene codigo ADVPL			
		Case cTpMne == '5' .AND. !lCampo // verifica que el Mnemónico sea de Tipo de Registro 5=Funcion de usuario
			cCamTab := CWJ->CWJ_FUNRPO // Obtiene la Funcion RPO
		Case cTpMne == '6' .AND. !lCampo // verifica que el Mnemónico sea de Tipo de Registro 6=Valor
			cCamTab := CWJ->CWJ_VALOR	// Obtiene el Valor			
	End Case	
EndIF	
	
	restArea(aArea)
	
Return cCamTab


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB93VALMNE³ Autor ³  Alfredo Medrano     ³ Data ³29/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica que el Mnemónico Exista, que sea de tipo “Campo   ³±±
±±³          ³ de BD”, y obtiene su campo								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93VALMNE(@ExpC1,@ExpL2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna la expresión con los campos del Mnemónico          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93FORM                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Expresion con Mnemonicos.                          ³±±
±±³          ³ ExpL2 : Lógico. indica si solo se evaluara el Campo de BD  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB93VALMNE(cExpres,lCampo)
Local		aArea	:= getArea()
Local		nConta	:= 1
Local		nCarac	:= 0
Local 		nX		:= 0
Local		cCampo	:= ""
Local		cCarac	:= ""
Local 		cMnemo	:= ""
Local		cCadena:= ""
Local		cExpStr:= ""
Local 		cValMne:= ""
Local 		aAux	:= {}
Local 		lY		:= .F.
Local		i := 0
Default	cExpres:= ""
Default	lCampo	:= .T.


/*/	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Recorre la Cadena y revisa el carácter obtenido, cuando       ³ 
	³encuentra un operador ("+","-","*","/",")","(") corta la      ³
	³cadena obteniendo solo el dato que esta entre cada operador   ³    
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If !Empty(cExpres) // verifica que la cadena no este vacía
	
	cExpStr := AllTrim(cExpres) + "/"
	nCarac  :=  Len(AllTrim(cExpStr))
	While nConta <= nCarac  //Recorre la cadena
		cCarac := SubStr(cExpStr,nConta,1)//Obtiene caracter
		If !(cCarac $ "+|-|*|/|)|(|=|==|<>|>|<|$|,") 
			//verifica si la cadena contiene M_ 			
			cMnemo += cCarac	
			
			If "M_" $ cMnemo 
				nX := 1
			EndIF	
			
		Else
			cCampo := cMnemo // asigna caracter
/*/	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Si la cadena obtenida contiene "M_" y su limitante fue un     ³ 
	³operador entonces verifica que sea un Mnemónico y Obtiene Su  ³ 
	³campo para ser sustituido en la cadena   					   ³    
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			If nX == 1 
				IF ".AND." $ cMnemo .OR. ".OR." $ cMnemo //SE agerga este bloque de codigo para evaluar cuando hay conjunciones.
				
					if ".AND." $ cMnemo
						aAux := SEPARA(cMnemo,".AND.")
						lY := .T.
					Else
						aAux := SEPARA(cMnemo,".OR.")		
						LY := .F.			
					EndIF
					
					For i:= 1 to len(aAux)
						If "M_" $ aAux[i]
							cValMne := ValMnemo(aAux[i],lCampo) // obtiene el Campo del Menmónico
							If !Empty(cValMne)
								cCampo := cValMne
							EndIf					
														
						Else
							cCampo := 	aAux[i]						
						EndIF	
						If i= 1
								cCampo += IIF(lY," .AND. ", " .OR. " )
						EndIF		
						cCadena += cCampo		
					next
					
				Else
					cValMne := ValMnemo(cMnemo,lCampo) // obtiene el Campo del Menmónico
					If !Empty(cValMne)
						cCampo 	:= cValMne
					EndIf
					cCadena += cCampo	
				EndIF
				
				nX		:= 0
			Else
				cCadena += cCampo	
			EndIf
			cCadena += cCarac 
			cMnemo 	:= ""  
		EndIf
		cCampo := ""
		nConta++
	EndDo
	If !Empty(cCadena)
		cCadena := substr(cCadena,1,Len(cCadena)-1 )
	EndIF	
EndIf
restArea(aArea)

Return cCadena


 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTB093POS   ³ Autor ³Miguel Rojas         ³ Data ³24/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida que exista el número de secuencia                   ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB093POS(ExpO1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA093                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1  : Modelo de datos.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       
Function CTB093POS( oModel )
	Local aArea		:= getArea()
	Local lBorrar		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cFormula	:= Rtrim(CWK->CWK_CODFOR)
	Local nTam		:= TamSX3("CWM_CODFOR")[1]
	Local oMdlGrid	:= oModel:GetModel('CWLDETAIL')
	Local cTipo		:= ""
	Local cFormGen	:= ""
	
	cTipo := oModel:GetValue("CWKMASTER","CWK_TIPO")
	cFormula:=cFormula+(SPACE(nTam-LEN(cFormula)))
	
	DbSelectArea("CWM")
	CWM->(DbSetOrder(2))
	CWM->(DbGoTop())
	   		
	If nOperation ==	MODEL_OPERATION_DELETE   	
		If CWM->(DbSeek(xFilial("CWM")+cFormula))
	      	Help( ,, STR0010,,STR0078,1, 0 )  //Aviso, Existen Asientos utilizando esta fórmula, y no puede ser eliminada
	   		lBorrar := .F.
	   Else  		
		  	lBorrar := MsgNoYes(STR0076 )			// Eliminar la formula?
			If  !lBorrar
		  		Help( ,, STR0061,,STR0077,1, 0 )  // Aviso, No se elimino la formula.
		  	Endif
	   EndIf	
	ElseIF nOperation == MODEL_OPERATION_INSERT 
		//If Empty(cTipo) .and. (Empty(oMdlGrid:aCols[1,4]) .and. Empty(oMdlGrid:aCols[1,9]))
		If Empty(cTipo) .and. (Empty(oMdlGrid:GetValue("CWL_OPER")) .and. Empty(oMdlGrid:GetValue("CWL_EXPRES")))
			Help( ,, STR0061,,STR0079,1, 0 )  //Aviso, Debe elegir el tipo de Fórmula o bien generar una fórmula avanzada..	
			lBorrar := .F.
		EndIF
	ElseIF nOperation == MODEL_OPERATION_UPDATE
		//If Empty(cTipo) .and. (Empty(oMdlGrid:aCols[1,4]) .and. Empty(oMdlGrid:aCols[1,9]))
		If Empty(cTipo) .and. (Empty(oMdlGrid:GetValue("CWL_OPER")) .and. Empty(oMdlGrid:GetValue("CWL_EXPRES")))
			Help( ,, STR0061,,STR0079,1, 0 )  //Aviso, Debe elegir el tipo de Fórmula o bien generar una fórmula avanzada..	
			lBorrar := .F.
		EndIF
		If CWM->(DbSeek(xFilial("CWM")+cFormula))
			lBorrar := MsgNoYes(STR0100 ) // "Existen Asientos utilizando esta fórmula, si guarda la información actualizara los Asientos involucrados ¿Continuar?"
	   EndIf		  	   	  
	EndIF
	
	If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
		cFormGen := oModel:GetValue("PARAMETROS","CWK_ADVPL")
		cFormGen := CTB93GEN(oModel,@lBorrar)				
	EndIF
	
restArea(aArea)
Return lBorrar 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB93CWLEX ³ Autor ³  Miguel Rojas        ³ Data ³24/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Activa o Desactiva los campos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93SKYP()                      						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.	           							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93LPRE                                                  ³±±
±±³          ³ X3_WHEN : CWL_OPER,  CWL_OPER1, CWL_OPER2, CWL_CONJUN      ³±±
±±³          ³ CWL_SELSEC                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB93CWLEX()
      Local lRet 		:= .T.
      Local oModel		:= FwModelActivate()
      Local cOper 		:= ""
      Local cOp1  		:= ""
      Local cOp2  		:= "" 
      Local cConj 		:= ""
      Local cSelSec   	:= ""
      Local oView     	:= FWViewActive()
      Local cCampo 		:= ReadVar()
      Local nPos		:= 0
      
      cOper     := oModel:GetValue("CWLDETAIL","CWL_OPER")
      cOp1      := oModel:GetValue("CWLDETAIL","CWL_OPER1")
      cOp2      := oModel:GetValue("CWLDETAIL","CWL_OPER2")
      cConj 		:= oModel:GetValue("CWLDETAIL","CWL_CONJUN")
      cSelSec		:= oModel:GetValue("CWLDETAIL","CWL_SELSEC")
            
      If (!Empty(cOper) .Or. !Empty(cOp1) .Or. !Empty(cOp2) .Or. !Empty(cConj) .Or. !Empty(cSelSec)) .And. cCampo == "M->CWL_EXPRES"  
         oModel:LoadValue("CWLDETAIL","CWL_EXPRES","")
         lRet := .f.
      EndIf
      
      If Empty(cOper) .And. (cCampo == "M->CWL_OPER1" .Or. cCampo == "M->CWL_OPER2" .Or. cCampo == "M->CWL_CONJUN";
      		.Or. cCampo == "M->CWL_SELSEC")
      		lRet := .F.		
      Else
	      	nPos :=  aScan(__aCT93Oper, { |x,y| x[1] == cOper }) 
			
			If nPos > 0
				// Verifica el tipo de Operador
				cTpOp	:=  __aCT93Oper[nPos,3]
				// Verifica si el operando 2 es obligatorio 
				__lOblig := IIF("O" $ __aCT93Oper[nPos,6],.T.,.F.) 
				
				If cCampo == "M->CWL_OPER1"
					lRet := .T.
				EndIf
				If cCampo == "M->CWL_OPER2"							
					lRet := __lOblig
				EndIf
				If cCampo == "M->CWL_CONJUN" 
					//Si el tipo de operador es condicion, el campo CWL_CONJUN debe activarse, 
					//de lo contrario no se permite la edición.
					If cTpOp != "C"
						lRet :=.F.
					EndIf
				EndIf	
				If cCampo == "M->CWL_SELSEC" 
					//Si el tipo de operador es condicion, el campo CWJ_SELSEC debe activarse, 
					//de lo contrario no se permite la edición.
					If cTpOp != "C" .Or. !Empty(cConj)
						lRet :=.F.
					EndIf
				EndIf					
			EndIf
      EndIf
      oView:Refresh()
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB93LPRE  ³ Autor ³  Miguel Rojas        ³ Data ³24/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Prevalidación de datos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93LPRE()                      						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.	           							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ModelDef                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Modelo                                             ³±±
±±³			 ³ ExpN2 = Numero de Linea                                    ³±±
±±³			 ³ ExpC3 = Acción		                                      ³±±
±±³			 ³ ExpC4 = Campo		                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB93LPRE(oModelGrid, nLine, cAction, cField)
	Local oview := FwViewActivate()
	CTB93CWLEX()      
	CTB93SKYP(oModelGrid, nLine, cAction, cField)   
	CTB93SHOWDES(oview,cField,oModelGrid,nLine)
	  
Return .t.


STATIC FUNCTION CTB93SHOWDES(oView, cField,oMdlGrid,nLine)
	Local oModel 		:= FWModelActive()
	Local cValor		:= ""
	Local aValores 	:= {}
	Local cDesc		:= ""
	Local nI			:= 0
	Local nMenm		:= TamSX3("CWJ_CODMNE")[1]
	Local nPos1		:= 0
	Local nPos2		:= 0
	Local cValor2		:= ""
		
	Default cField := "" 
	
	nPos1:= aScan(oMdlGrid:aHeader, { |x,y| x[2] == "CWL_OPER1" 	} )
	nPos2:= aScan(oMdlGrid:aHeader, { |x,y| x[2] == "CWL_OPER2" 	} )
	
	//cValor	:= 	IF(IsMemVar("CWL_OPER1"),m->cwl_oper1,oMdlGrid:aCols[nLine,nPos1])
	cValor	:= 	IF(IsMemVar("CWL_OPER1"),m->cwl_oper1,oMdlGrid:GetValue("CWL_OPER1"))
	//cValor2:=	IF(IsMemVar("CWL_OPER2"),m->cwl_oper2,oMdlGrid:aCols[nLine,nPos2])
	cValor2:=	IF(IsMemVar("CWL_OPER2"),m->cwl_oper2,oMdlGrid:GetValue("CWL_OPER2"))
	
	If !Empty(cValor)
		cDesc := fGetDesc(cValor)
		oModel:LoadValue( 'PARAMETROS', 'CWK_DESOP1'	, cDesc)
	Else
		oModel:LoadValue( 'PARAMETROS', 'CWK_DESOP1'	, "")
	EndIF	
	
	If !Empty(cValor2)
		cDesc := fGetDesc(cValor2)
		oModel:LoadValue( 'PARAMETROS', 'CWK_DESOP2'	, cDesc)
	Else
		oModel:LoadValue( 'PARAMETROS', 'CWK_DESOP2'	, "")
	EndIF	
									
	oView:Refresh()
			
Return .T.

Static function fGetDesc(cValor)

	Local aValores	:= {}
	Local nI 		:= 0
	Local nMenm	:= TamSX3("CWJ_CODMNE")[1]
	Local cDesc 	:= ""
	Local lDesc	:= .F.
	
	aValores:= separa(cValor,"+")
	If len(aValores)> 1
		lDesc := .T.
	EndIf
	For nI:= 1 to len(aValores)
		cValor := pADR(aValores[nI],nMenm)
		IF Substr(aValores[nI],1,2) $ "M_"
			cDesc+= POSICIONE("CWJ",1,xfilial("CWJ")+cValor,"CWJ_DESCRI")
		Else
			If lDesc
				cDesc+= aValores[nI]
			Else
				cDesc := ""
			EndIf
		EndIF			
				
		If nI< len(aValores)
			cDesc += "+"
		EndIf
	Next
Return cDesc


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB93SKYP  ³ Autor ³  Alfredo Medrano     ³ Data ³10/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida que el operador de la primera línea sea <> a        ³±±
±±³          ³ Tipo condición            								  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB93SKYP(@ExpO1,@ExpN2,@ExpC3,@Exp4)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.	           							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93LPRE                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Modelo                                             ³±±
±±³			 ³ ExpN2 = Numero de Linea                                    ³±±
±±³			 ³ ExpC3 = Acción		                                      ³±±
±±³			 ³ ExpC4 = Campo		                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB93SKYP(oModelGrid, nLine, cAction, cField)
Local cOper 	:= ""
Local oModel   := FwModelActivate()
Local aLnGrid	:= {}
Local nPos		:= 0

aLnGrid := aClone(oModelGrid:ACols)
cOper   := oModel:GetValue("CWLDETAIL","CWL_OPER")

//If !Empty(cOper) .And. Len(aLnGrid) > 0
If !Empty(cOper) .And. Len(aLnGrid) == 1
	nPos :=  aScan(__aCT93Oper, { |x,y| x[1] == cOper }) 
	If nPos > 0
		// Verifica el tipo de Operador
		cTpOp	:=  __aCT93Oper[nPos,3]
		
		//Verifica si el operador de la línea asignada es diferente a Condición (C)
		If cTpOp <> "C" .and. nLine <= 1 
			If cAction <> 'DELETE'
				oModel:GetModel("CWLDETAIL"):SetNoInsertLine( .T. )
			Else
				oModel:GetModel("CWLDETAIL"):SetNoInsertLine( .F. )
			EndIF
		Else
			oModel:GetModel("CWLDETAIL"):SetNoInsertLine( .F. )
		EndIf
	EndIf
EndIf

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fValStx    ³ Autor ³  Mayra.Camargo       ³ Data ³06/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validar sintáxis                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fValStx(@ExpA1,@ExpL2,@ExpL3 )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet            	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fGenFormLn(),CTB93LPOS()                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array                                              ³±±
±±³          ³ ExpL2 = Lógico                                             ³±±
±±³          ³ ExpL3 = Lógico                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fValStx(aLnGrid,lGenera,lConjAnt)
	
	Local lRet	:= .T.
	Local cForm	:= ""
	Local cSint	:= ""
	Local nPosSec	:= 0
	Local nPosOp	:= 0		// Posición del Operador
	Local nPosOp1	:= 0		// Posición del Operando 1
	Local nPosOP2	:= 0		// Posición del Operando 2
	Local nPosExp	:= 0		// Posición de la Expresión
	Local nPosSal	:= 0		// Posición del Salto de Secuencia
	Local nPosCon	:= 0		// Posición de la Conjunción
	Local lObl1	:= .F.
	Local lObl2	:= .F.
	Local nLn		:= len(aLnGrid)
	Local aForTem	:= {}		// Fórmula temporal
	Local cOper	:= ""		// Operador	
	Local cOp1	:= ""		// Operando 1
	Local cOp2	:= ""		// Operando 2
	Local nSelSec	:= ""		// Salta a Secuencia
	Local cConjun	:= ""		// Conjunción
	Local cExpr	:= ""		// Expresión
	Local cSec	:= "" 		// Secuencia
	Local oModel		:= FwModelActive()
	Local oModelGrid	:= oModel:GetModel("CWLDETAIL")
	Local cCarEsp		:= ")"
	Local cTpOp		:= ""
	Local cPosant		:= 0
	Local lConj		:= .F.
	Local lCond		:= .F.
	Local lData		:= .F.
	Local cMsgOp		:= ""
	Local cMsgAux		:= ""
	Local cTipoDato	:= "U"
	Local nPAux		:= 0
	Local cFrmAux		:= ""
	
	DEFAULT lGenera 	:= .F.
	
	nPosSec:= aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_SEC"		} )
	nPosOp := aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_OPER"		} )
	nPosOp1:= aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_OPER1" 	} )
	nPosOp2:= aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_OPER2" 	} )
	nPosExp:= aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_EXPRES"	} )
	nPosSal:= aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_SELSEC"	} )
	nPosCon:= aScan(oModelGrid:aHeader, { |x,y| x[2] == "CWL_CONJUN"	} )
	
		
	IF Len(aLnGrid)> 0
		cOper 	:= aLnGrid[nLn,nPosOP]		
		cExpr	:= aLnGrid[nLn,nPosExp]
							
		If !Empty(cOper)
			
			//Buscar el operador dentro del array de operadores			
			nPos :=  aScan(__aCT93Oper, { |x,y| x[1] == cOper })
						 
			If nPos > 0  
			
				cTpOp	:= __aCT93Oper[nPos,3]
				cOp1	:= aLnGrid[nLn,nPosOP1]		
				cOp2 	:= aLnGrid[nLn,nPosOP2]		
								
				lObl1 	:= __aCT93Oper[nPos,4] == "O"
				lObl2	:= __aCT93Oper[nPos,6] == "O"
				
				If ("/" $cOp1 .and. !('"' $ cOp1))
					lData 	:= .T.
				EndIF
											
				If lObl1 .and. Empty(cOp1) 					
					Help( ,, OemToAnsi(STR0061),, OemToAnsi(STR0103) + StrZero(nLn,TamSx3("CWL_SEC")[1]) + STR0121 + STR0119,1, 0 )   // "Aviso" // "Sintasis incorrecta, verificar línea "	
					Return .F.
				ElseIf lObl1
					cTipoDato := __aCT93Oper[nPos,5]
					
					cMsgAux := STR0133 + CHR(10) + CHR(13) 
					If "C" $ cTipoDato .and. cTipoDato <> "CAMPO"
						cMsgAux += STR0123 + " - " + STR0127  + CHR(10) + CHR(13) 
					EndIF
					
					If "D" $ cTipoDato 
						cMsgAux += STR0124 + " - " + STR0125  + CHR(10) + CHR(13) 
					EndIF
					
					If "N" $ cTipoDato 
						cMsgAux += STR0122 + " - " + STR0128  + CHR(10) + CHR(13) 
					EndIF
					
					IF "CAMPO" $ cTipoDato
						cMsgAux += STR0132 + " - " + STR0129 + CHR(10) + CHR(13) 
					EndIf
						
					If "TABLA" $ cTipoDato
						cMsgAux += STR0131 + " - " + STR0130 + CHR(10) + CHR(13) 
					EndIF										
					
				End 			
								
				If lObl2 .and. Empty(cOp2) 
					Help( ,, OemToAnsi(STR0061),, OemToAnsi(STR0103) + StrZero(nLn,TamSx3("CWL_SEC")[1]) + STR0121 + STR0120,1, 0 )   // "Aviso" // "Sintasis incorrecta, verificar línea "	
					Return .F.	
				ElseIf lObl2
					cTipoDato := __aCT93Oper[nPos,7]
					
					cMsgAux := STR0133 + CHR(10) + CHR(13) 
					If "C" $ cTipoDato .and. cTipoDato <> "CAMPO"
						cMsgAux += STR0123 + " - " + STR0127  + CHR(10) + CHR(13) 
					EndIF
					
					If "D" $ cTipoDato 
						cMsgAux += STR0124 + " - " + STR0125  + CHR(10) + CHR(13) 
					EndIF
					
					If "N" $ cTipoDato 
						cMsgAux += STR0122 + " - " + STR0128  + CHR(10) + CHR(13) 
					EndIF
					
					IF "CAMPO" $ cTipoDato
						cMsgAux += STR0132 + " - " + STR0129 + CHR(10) + CHR(13) 
					EndIf
						
					If "TABLA" $ cTipoDato
						cMsgAux += STR0131 + " - " + STR0130 + CHR(10) + CHR(13) 
					EndIF				
								
				End
				
				 //Validar que si es el operando 2, sea del mismo tipo que el operando 1 		
				If lObl1 .and. lObl2 
			   		lRet 	:= fCompareOp(cOper,@cOp1,@cOp2)	  			   	 	
			   	EndIf	
			   	
			   	cSint 	:= __aCT93Oper[nPos,8]
								
			   	IF lData .and. lObl1
			   		cForm:= STRTRAN(cSint, "OP1", "CTOD('" +alltrim(cOp1) +"')")	
				Else
					cForm:= STRTRAN(cSint, "OP1", alltrim(cOp1))					
			   	EndIF 		
			   	
			   	If cTpOp == "T" 
			   		// Pre-traducción
			   		cFrmAux:= cForm 	
			   		cOp2	:= CTB93VALMNE(cOp2,.F.)
			   		nPaux 	:= at("->", cOp2)			   		
					If !Empty(cOp2) .and. nPaux > 0													
						cOp2 	:= "'" +Substr(CoP2,nPAux+2) +"'"
					EndIf 
			   	EndIF
			   	
			   	cForm 	:= STRTRAN(cForm, "OP2", alltrim(cOp2))
			   	
			  	IF lRet			
					lRet 	:= CTB93FORM(cForm ,.F.)							 
					If lRet 
						// Para la condiciones se valida conforme a sintaxis 1 pero se traduce a sintaxis 2
						
						If "C" $ cTpOp .and. !lConjAnt .and. lGenera		
							
							cSint 	:= __aCT93Oper[nPos,9]
							cForm 	:= STRTRAN(cSint, "OP1", alltrim(cOp1))
							cForm 	:= STRTRAN(cForm, "OP2", alltrim(cOp2))	
																		
						EndIf		
					Else
						cMsgOp := OemToAnsi(STR0071) + cForm + OemToAnsi(STR0074) //"Aviso"//"El dato " //" no tiene un identi
			         	cMsgOp += STR0116	 + CHR(10) + CHR(13) 									// . Tipo de dato esperado
			      		cMsgOp += 	cMsgAux		 
						Help( ,, OemToAnsi(STR0061),, OemToAnsi(STR0103) + StrZero(nLn,TamSx3("CWL_SEC")[1]) + CHR(10) + CHR(13) + cMsgOp ;
						,1, 0 )   // "Aviso" // "Sintasis incorrecta, verificar línea "
												
					EndIf		
				EndIF		
			Else
				Help( ,, STR0061,,STR0099,1, 0 )  //	Aviso, Operador no encontrado.	
				lRet := .F.
			EndIF
				
		ElseIF !Empty(cExpr)
		
			// Buscamos la expresión 	
			cForm:= cExpr		
			lRet := CTB93FORM(cExpr,.F.)		
			
		End If
		
		// Si la sintásis de la línea fue correcta
		// Agregamos la conjunción si es que tiene 
		// y guardamos la secuencia a la que va a saltar en caso de que aplique.
		
		If lRet .and. lGenera
					
			cConjun := aLnGrid[nLn,nPosCon]
			nSelSec := Val(aLnGrid[nLn,nPosSal])
			
			//Si no está vacía la conjunción
			If !(Empty(cConjun))				
				Do Case
					Case "1" $ cConjun	// Y
						cForm += " .AND." 
					Case "2" $ cConjun	// O
						cForm += " .OR. "					
				End Casea
				lConj	 := .T.
				//nSelSec := nLn+1
			EndIf
			
			IF(Empty(nSelSec))	
				nSelSec := ""
			EndIf
			// Agregamos fórmula y siguiente secuencia al array	__aCTB93For
			// que se encargará de almacenar las fórmulas traducidas por línea.
					  	
			AADD(__aCTB93For,{ALLTRIM(cForm),;	// Sintaxis Fórmula
								nSelSec,;			// Secuencia Sig.
								.F.,;				// Procesado
								lConj,;			// Conjuncion o no
								cTpOp $ "C",;		// Condición 		
								len(__aCTB93For)+1})//Val(aLnGrid[nLn,nPosSec])})   
			
		End If
		
	End If
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fGetCBOXSx3³ Autor ³  Alfredo Medrano     ³ Data ³06/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtiene un arreglo a partir de los datos obtenidos del     ³±±
±±³          ³ campo X3_CBOX                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGetCBOXSx3(@ExpC1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna un array		                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTB93CLNCP                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nombre del campo                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGetCBOXSx3(cCampo)
	Local aArea 	:= getArea()
	Local aValores	:= {}
	Local aVal		:= {}
	Local cCbox		:= ""
	Local ni		:= 0 
	
	If !Empty(cCampo)
	//Verifica si el campo existe en la tabla SX3
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek(cCampo))
		//Verifica el Idioma obteniendo los datos del campo al que corresponden 
			cCbox := X3CBox()
		EndIF 
		
		//Separa la cadena por medio del punto y coma para obtener un array
		If !Empty(cCbox)
			aValores:=SEPARA(cCbox,";")
			If Len(aValores) > 1 
				For ni:= 1 to len(aValores) //Recorre los valores Obtenidos
					If !empty(aValores[ni])
						AADD(aVal,ALLTRIM(aValores[ni])) // agrega los valores a un Array
					EndIf
				Next
			EndIf
		EndIf
		
	EndIf
		
	RestArea(aArea)
Return aVal	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  POLx222  º Autor ³  Jordan Lazarine   º Data ³  23/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro Componentes del Combo X Ítems Componente del Comboº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA093POL(cAlias,nReg,nOpcx)

Local aArea		:=	GetArea()
Local aObjects  := {}
Local aPosObj   := {}
Local aInfo		:= {}
Local aSizeAut  := MsAdvSize()
Local aCamCWK := {"CWK_CODFOR","CWK_DESC","CWK_GRUPO","CWK_DESGPO","CWK_ADVPL"}
Local aCamCT5 := {"CT5_LANPAD","CT5_SEQUEN","CT5_STATUS","CT5_DESC","CT5_DC","CT5_DEBITO","CT5_CREDIT","CT5_CCD","CT5_CCC","CT5_ITEMD","CT5_ITEMC",;
					"CT5_CLVLDB","CT5_CLVLCR","CT5_ATIVDE","CT5_ATIVCR","CT5_VLR01","CT5_VLR02","CT5_VLR03","CT5_VLR04","CT5_VLR05","CT5_MOEDAS" }
Local 	cCadastro := OemToAnsi(STR0108) + " - " + OemToAnsi(STR0115) // "Fórmulas de Asientos - Consulta" 
Private lVisual	:=	(nOpcx == 2)
Private lInclui	:=	(nOpcx == 3)
Private lAltera	:=	(nOpcx == 4)
Private lExclui	:=	(nOpcx == 5)
Private aTela   := {}
Private aGets   := {}

Private oDlg	:= NIL
Private oGetD   := NIL
Private nOpcA	:= 0

Private aHeader := {}
Private aCols	:= {}
Private aRecn	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao de aHeader e aCols das GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MontaGet(@aHeader,@aCols,aCamCT5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CWK")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a Variaveis da Enchoice.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("CWK",lInclui,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega dados das GetDados e campos Memo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lInclui
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega conteudo das GetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 LoadGD("CWK",@aHeader,@aCols,@aRecn,1,xFilial("CWK")+CWK->CWK_CODFOR)
		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula posicao dos objetos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 100, 40, .T., .T. } )
AAdd( aObjects, { 100, 60, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define objeto da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Enchoice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EnChoice("CWK",nReg,nOpcx,,,,aCamCWK,aPosObj[1],,3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria as GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIF(!lInclui.And.!lAltera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"U_LocLOk()","U_LocTOk()" ,,/*alteraveis*/,/*freeze*/,9999,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe a tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (nOpca := 1,oDlg:End())},{|| nOpca := 0,ODlg:End()})



RestArea(aArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaGet  ºAutor  ³Norbert Waage Juniorº Data ³  10/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para gerar a o aCols e aHeader de acordo com o Alias º±±
±±º          ³recebido em parametros                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaGet(aH,aC,aCampos)

Local nUsado	:=	0
Local nPos		:=	0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o aHeader³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(2) //X3_CAMPO

For nPos := 1 to Len(aCampos)
	
	If	SX3->(DbSeek(aCampos[nPos]))
		
		nUsado++     
		aadd(aH,{X3Titulo()	,;
		SX3->X3_CAMPO		,;
		SX3->X3_PICTURE		,;
		SX3->X3_TAMANHO		,;
		SX3->X3_DECIMAL		,;
		SX3->X3_VALID		,;
		SX3->X3_USADO		,;
		SX3->X3_TIPO		,;
		SX3->X3_F3			,;
		SX3->X3_CONTEXT 	})
		
	EndIf
	
Next nPos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aC,Array(nUsado+1))
For nPos := 1 To nUsado
	aC[1][nPos] := CriaVar(aH[nPos][2])
Next
aC[1][nUsado+1] := .F.

Return Nil           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadGD    ºAutor  ³Norbert Waage Juniorº Data ³  07/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para carga do aCols da GetDados                      º±±
±±º          ³Parametros:                                                 º±±
±±º          ³cAlias  - Alias trabalhado                                  º±±
±±º          ³aH      - Array do aHeader recebido por referencia          º±±
±±º          ³aC      - Array do aCols recebido por referencia            º±±
±±º          ³aRecnos - Array que armazena os Recnos receb. por referenciaº±±
±±º          ³nIndChv - Chave do indice a ser considerada para filtro     º±±
±±º          ³cChave  - Valor da chave de filtro do indice                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadGD(cAlias,aH,aC,aRecnos,nIndChv,cChave)

Local aArea		:=	GetArea()
Local cIndKey	:=	""
Local aLinha	:=	{}
Local nUsado	:=	Len(aH)
Local nPos		:=	0
Local nLin 		:=	0
Local nLenChave	:=	Len(cChave)
//ÚÄÄÄÄÄÄÄÄÄ¿
//³Abre area³
//ÀÄÄÄÄÄÄÄÄÄÙ
//Local cAliasCWM := 'CWM' 
DbSelectArea('CWM')
CWM->(DbSetOrder(2))

DbSelectArea('CT5')
CT5-> (DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Le chave do indice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndKey :=CWM->(IndexKey())

If CWM->(DbSeek(cChave))
	
	aC := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Percorre area, carregando os campos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While CWM->(!Eof()) .And. SubStr(CWM->(&(cIndKey)),1,nLenChave) ==  cChave
	
		IF CT5->(dbSeek(FWCODFIL("CT5")+CWM->CWM_LANPAD+CWM->CWM_SEQUEN))
		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Incrementa aCols³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd(aC,Array(nUsado+1))
			nLin++
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa campos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nPos := 1 To nUsado
				If aH[nPos][10] == "V"
					aC[nLin][nPos] := CriaVar(aH[nPos][2])
				Else
					aC[nLin][nPos] := CT5->(&(aH[nPos][2]))
					M->(&(aH[nPos][2])) := CT5->(&(aH[nPos][2]))
				EndIf
			Next
	                                                                         
			aC[nLin][nUsado+1] := .F.
			
			/*For nPos:=1 To len(aC)
			     aC[nPos][2]:=POSICIONE("SB1",,XFILIAL("SB1")+aC[nPos][1],"B1_DESC") 	
			Next
			*/
			                           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Recno³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd(aRecnos,(cAlias)->(Recno()))
			
		EndIf
		
		CWM->(DbSkip())
		
	End
	
EndIf

RestArea(aArea)

Return Nil  



Static Function GenErro(cExp)
	
	Local lRet 	:= .T.
	Local xResul	
	
	Default cEXP := ""

	bBlock := ErrorBlock({|e|CTB93ERR(e,cExp)  })
	BEGIN SEQUENCE
		xResult := Valtype(&cExp)
	RECOVER
		lRet := .F.
	END SEQUENCE
	ErrorBlock(bBlock)	
		
Return lRet

Static Function CTB93ERR(oError,cExp)

	If oError:gencode > 0		
		//conout("Hola mundo")
		Break		
	EndIF
	
Return 
