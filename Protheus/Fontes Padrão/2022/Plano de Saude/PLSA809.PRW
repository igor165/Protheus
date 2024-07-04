#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA809.ch'

//Variavel que vai determinar a busca da RDA ou Prospect
Static cSTACRMCGC := ""
Static lExistEsp  := .T.
Static aIndic     := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809
Funcao para abrir Agendamento de Captação
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809(cMatric)
Local oBrowse	:= nil
default cMatric := ""

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9Y')
oBrowse:SetDescription(STR0001)//"Indicação de Prestador via CallCenter"
oBrowse:SetFilterDefault( "B9Y_ROTINA=='2'" )
if(!empty(cMatric))
	oBrowse:SetFilterDefault( "B9Y_CARTEI=='" + cMatric + "'" )
	private cMatricula := cMatric
endIf

oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

//Esse If é por causa do browse de indicações da B88, caso a chamada venha desta função, irá gerar um
//MenuDef sem ações, de outro modo, irá gerar o MenuDef da rotina.
If !(IsInCallStack('PLSA809VIN'))
	Add Option aRotina Title STR0014 /*VISUALIZAR*/ Action 'VIEWDEF.PLSA809' Operation 2 Access 0
	Add Option aRotina Title STR0015 /*INCLUIR*/    Action 'VIEWDEF.PLSA809' Operation 3 Access 0
	Add Option aRotina Title STR0016 /*IMPRIMIR*/   Action 'VIEWDEF.PLSA809' Operation 8 Access 0
EndIf

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 	:= nil// Modelo de dados construído
// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
Local oStrB9Y	:= FWFormStruct(1,'B9Y', { |cCampo| PLSAB9Y809(cCampo) } )
Local oStrB9V	:= FWFormStruct(1,'B9V', { |cCampo| PLSAB9V809(cCampo) } ) 
Local oStrB9Q	:= FWFormStruct(1,'B9Q', { |cCampo| PLSAB9Q809(cCampo) } )
Local lObrigat 	:= GetNewPar("MV_PL809OB", .T.) // Indica se o Campo B9Y_CRMCGC será Obrigatório

//Cria o campo combo para informar se indicação é de pessoa fisica/juridica e alterar a mascara para informar.
oStrB9Y:AddField( ; 												// Ord. Tipo Desc.
STR0002/*'Tipo Pessoa'*/, ; 											       // [01] C Titulo do campo
STR0002/*'Tipo Pessoa'*/ , ; 							                     // [02] C ToolTip do campo
'B9Y_TIPPES' , ; 													// [03] C identificador (ID) do Field
'C' , ; 															// [04] C Tipo do campo
1   , ; 															// [05] N Tamanho do campo
0   , ; 															// [06] N Decimal do campo
NIL , ; 															// [07] B Code-block de validação do campo
NIL , ; 															// [08] B Code-block de validação When do campo
NIL , ; 															// [09] A Lista de valores permitido do campo
.T. , ; 															// [10] L Indica se o campo tem preenchimento obrigatório
{ || PLSA809TPP(oModel) } , ; 									// [11] B Code-block de inicializacao do campo
NIL , ; 															// [12] L Indica se trata de um campo chave
.T. , ; 															// [13] L Indica se o campo pode receber valor em uma operação de update.
.T. ) 																// [14] L Indica se o campo é virtual

//Cria o campo para informar se indicação é de pessoa fisica/juridica que recebe CRM/CNPJ.
oStrB9Y:AddField( ; 												// Ord. Tipo Desc.
STR0003/*'CRM/CNPJ'*/, ; 											       // [01] C Titulo do campo
STR0003/*'CRM/CNPJ'*/ , ; 							                     // [02] C ToolTip do campo
'B9Y_CRMCGC' , ; 													// [03] C identificador (ID) do Field
'C' , ; 															// [04] C Tipo do campo
15   , ; 															// [05] N Tamanho do campo
0   , ; 															// [06] N Decimal do campo
{ || PLSA809VCG(oModel) } , ;									// [07] B Code-block de validação do campo
NIL , ; 															// [08] B Code-block de validação When do campo
NIL , ; 															// [09] A Lista de valores permitido do campo
lObrigat , ; 														// [10] L Indica se o campo tem preenchimento obrigatório
{ || PLSA809ICG(oModel) } , ;									// [11] B Code-block de inicializacao do campo
NIL , ; 															// [12] L Indica se trata de um campo chave
.T. , ; 															// [13] L Indica se o campo pode receber valor em uma operação de update.
.T. ) 																// [14] L Indica se o campo é virtual

//Cria campo para informar protocolo do credenciamento; caso exista
oStrB9Q:AddField( ; 												// Ord. Tipo Desc.
STR0004/*'Protocolo'*/, ; 											       // [01] C Titulo do campo
STR0004/*'Protocolo'*/ , ; 							                     // [02] C ToolTip do campo
'B9Q_NROPRO' , ; 													// [03] C identificador (ID) do Field
'C' , ; 															// [04] C Tipo do campo
12   , ; 															// [05] N Tamanho do campo
0   , ; 															// [06] N Decimal do campo
NIL , ; 															// [07] B Code-block de validação do campo
NIL , ; 															// [08] B Code-block de validação When do campo
NIL , ; 															// [09] A Lista de valores permitido do campo
NIL , ; 															// [10] L Indica se o campo tem preenchimento obrigatório
NIL , ; 													       // [11] B Code-block de inicializacao do campo
NIL , ; 															// [12] L Indica se trata de um campo chave
.T. , ; 															// [13] L Indica se o campo pode receber valor em uma operação de update.
.T. ) 																// [14] L Indica se o campo é virtual

//Cria campo para controlar poder contar indicação.
oStrB9Q:AddField( ; 												// Ord. Tipo Desc.
STR0005/*'Indicar'*/, ; 											          // [01] C Titulo do campo
STR0005/*'Indicar'*/ , ; 							                     // [02] C ToolTip do campo
'B9Q_INDPRE' , ; 													// [03] C identificador (ID) do Field
'L' , ; 															// [04] C Tipo do campo
1   , ; 															// [05] N Tamanho do campo
0   , ; 															// [06] N Decimal do campo
NIL , ; 															// [07] B Code-block de validação do campo
NIL , ; 															// [08] B Code-block de validação When do campo
NIL , ; 															// [09] A Lista de valores permitido do campo
NIL , ; 															// [10] L Indica se o campo tem preenchimento obrigatório
{ || .F. } , ; 													// [11] B Code-block de inicializacao do campo
NIL , ; 															// [12] L Indica se trata de um campo chave
.T. , ; 															// [13] L Indica se o campo pode receber valor em uma operação de update.
.T. ) 																// [14] L Indica se o campo é virtual


//Cria campo para controlar linhas editaveis da grid de especialidades.
oStrB9Q:AddField( ; 												// Ord. Tipo Desc.
'STATUS REGISTRO B9Q', ; 											       // [01] C Titulo do campo
'STATUS REGISTRO B9Q' , ; 							                     // [02] C ToolTip do campo
'B9Q_STAREG' , ; 													// [03] C identificador (ID) do Field
'L' , ; 															// [04] C Tipo do campo
1   , ; 															// [05] N Tamanho do campo
0   , ; 															// [06] N Decimal do campo
NIL , ; 															// [07] B Code-block de validação do campo
NIL , ; 															// [08] B Code-block de validação When do campo
NIL , ; 															// [09] A Lista de valores permitido do campo
NIL , ; 															// [10] L Indica se o campo tem preenchimento obrigatório
{ || .F. } , ; 															// [11] B Code-block de inicializacao do campo
NIL , ; 															// [12] L Indica se trata de um campo chave
.T. , ; 															// [13] L Indica se o campo pode receber valor em uma operação de update.
.T. ) 																// [14] L Indica se o campo é virtual

//Cria campo para controlar linhas editaveis da grid de endereços.
oStrB9V:AddField( ; 												// Ord. Tipo Desc.
'STATUS REGISTRO B9V', ; 											       // [01] C Titulo do campo
'STATUS REGISTRO B9V' , ; 							                     // [02] C ToolTip do campo
'B9V_STAREG' , ; 													// [03] C identificador (ID) do Field
'L' , ; 															// [04] C Tipo do campo
1   , ; 															// [05] N Tamanho do campo
0   , ; 															// [06] N Decimal do campo
NIL , ; 															// [07] B Code-block de validação do campo
NIL , ; 															// [08] B Code-block de validação When do campo
NIL , ; 															// [09] A Lista de valores permitido do campo
NIL , ; 															// [10] L Indica se o campo tem preenchimento obrigatório
{ || .F. } , ; 															// [11] B Code-block de inicializacao do campo
NIL , ; 															// [12] L Indica se trata de um campo chave
.T. , ; 															// [13] L Indica se o campo pode receber valor em uma operação de update.
.T. ) 																// [14] L Indica se o campo é virtual

// Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
oModel := MPFormModel():New( 'PLSA809', , {|| PLSA809OK(oModel) }, {|| PLSA809COM(oModel) }, {|| PLSA809ZVA() } )
//MPFormModel():New( STR0038, /*bPreValidacao*/, /*bPosValidacao*/, {|oModel|PMGRVBOK(oModel)}/*bCommit*/, /*bCancel*/ ) //'Elegiveis/Inscritos' 

// Adiciona ao modelo um componente de formulário
oModel:addFields('MasterB9Y',/*cOwner*/,oStrB9Y)  

// Adiciona ao modelo uma componente de grid
oModel:AddGrid('B9VDetail', 'MasterB9Y', oStrB9V)

// Adiciona ao modelo uma componente de grid 
oModel:AddGrid('B9QDetail', 'B9VDetail', oStrB9Q) 

oModel:GetModel('B9QDetail'):SetOptional(.T.) //Torna o preenchimento da Grid opicional
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'B9VDetail', { { 'B9V_FILIAL', 'xFilial( "B9V" )' } ,{ 'B9V_CODINT', 'B9Y_CODINT' } ,{ 'B9V_CODPRO', 'B9Y_CODIGO' } },B9V->( IndexKey( 1 ) ) )  
oModel:SetRelation( 'B9QDetail', { { 'B9Q_FILIAL', 'xFilial( "B9Q" )' } ,{ 'B9Q_CODINT', 'B9V_CODINT' } ,{ 'B9Q_CODLOC', 'B9V_CODSEQ' } ,{ 'B9Q_CODPRO', 'B9V_CODPRO' } },B9Q->( IndexKey( 1 ) ) ) 

//Nao deixa cadastrar dois registros iguais 
oModel:GetModel( 'B9QDetail' ):SetUniqueLine( { 'B9Q_CODESP' } ) 
oModel:GetModel( 'B9VDetail' ):SetUniqueLine( { 'B9V_CIDADE', 'B9V_ENDER'} ) 

 // Adiciona a descrição do Modelo de Dados										
oModel:SetDescription(STR0001)//"Indicação de Prestador via CallCenter")
//Tratamento para os campos da tabela B9Q que não poderão ser alterados
//como há apenas um campo na linha que será alterado preciso colocar um WHEN pra cada campo
//o WHEN foi colocado no fonte pois a tabela é usada em outra rotina e o campo que é o resultado do WHEN tbm é criado aqui no fonte
oStrB9Q:SetProperty( 'B9Q_CODESP' , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9Q') } )
oStrB9Q:SetProperty( 'B9Q_DESESP' , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9Q') } )
oStrB9Q:SetProperty( 'B9Q_CODLOC' , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9Q') } )
oStrB9Q:SetProperty( 'B9Q_CODSEQ' , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9Q') } )
oStrB9Q:SetProperty( 'B9Q_INDPRE' , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9Q', 'B9Q_INDPRE') } )

//Tratamento para os campos da tabela B9V que não poderão ser alterados
//como há apenas um campo na linha que será alterado preciso colocar um WHEN pra cada campo
//o WHEN foi colocado no fonte pois a tabela é usada em outra rotina e o campo que é o resultado do WHEN tbm é criado aqui no fonte
oStrB9V:SetProperty( 'B9V_ENDER'   , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_NUMERO'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_COMEND'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_BAIRRO'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_CIDADE'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_CEP'     , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_CODLOG'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_DESLOG'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_CODSEQ'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )
oStrB9V:SetProperty( 'B9V_CODCID'  , MODEL_FIELD_WHEN, { || PLSA809EDT(oModel, 'B9V') } )

//DEFINE INICIALIZADOR DO CAMPO 
//É COLOCADO NO FONTE POIS A TABELA É USADA EM OUTRA ROTINA
oStrB9Y:SetProperty( 'B9Y_ROTINA' , MODEL_FIELD_INIT, { || "2" } )
oStrB9Y:SetProperty( 'B9Y_SOINDI' , MODEL_FIELD_INIT, { || .F. } )
oStrB9V:SetProperty( 'B9V_CODPRO' , MODEL_FIELD_INIT, { || oModel:getModel("MasterB9Y"):getValue("B9Y_CODIGO")} )
oStrB9Q:SetProperty( 'B9Q_CODPRO' , MODEL_FIELD_INIT, { || oModel:getModel("MasterB9Y"):getValue("B9Y_CODIGO")} )
oStrB9Q:SetProperty( 'B9Q_CODLOC' , MODEL_FIELD_INIT, { || oModel:getModel("B9VDetail"):getValue("B9V_CODSEQ")} )

//DEFINE OBRIGATORIEDADE DO CAMPO
//É COLOCADO NO FONTE POIS A TABELA É USADA EM OUTRA ROTINA QUE NÃO USA O CAMPO 
oStrB9Y:SetProperty( 'B9Y_CARTEI' , MODEL_FIELD_OBRIGAT, .T. )

if (type("cMatricula") == "C" .and. !empty(cMatricula))
	oStrB9Y:SetProperty( 'B9Y_CARTEI' , MODEL_FIELD_INIT, { || cMatricula} )
	oStrB9Y:SetProperty( 'B9Y_NOMBEN' , MODEL_FIELD_INIT, { || POSICIONE("BA1",2, XFILIAL("BA1") + cMatricula, "BA1_NOMUSR") })
endIf


Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

 // Interface de visualização construída
Local oView 

// Carrega o model existente
Local oModel := FWLoadModel( 'PLSA809' )

// Cria as estruturas a serem usadas na View 
Local oStrB9Y:= FWFormStruct(2, 'B9Y', { |cCampo| PLSA809VI(cCampo) } )
Local oStrB9V:= FWFormStruct(2, 'B9V', { |cCampo| PLSA809VI(cCampo) } )
Local oStrB9Q:= FWFormStruct(2, 'B9Q', { |cCampo| PLSA809VI(cCampo) } )

//Cria o campo combo para informar se indicação é de pessoa fisica/juridica e alterar a mascara para informar.
oStrB9Y:AddField( ; 							// Ord. Tipo Desc.
'B9Y_TIPPES' , ; 								// [01] C Nome do Campo
'05' , ; 										// [02] C Ordem
STR0002/*'Tipo pessoa'*/ , ; 						   // [03] C Titulo do campo
STR0002/*'Tipo pessoa'*/ , ;	                         // [04] C Descrição do campo
NIL , ; 										// [05] A Array com Help
'C' , ; 										// [06] C Tipo do campo
'@!' , ; 										// [07] C Picture
NIL , ; 						              // [08] B Bloco de Picture Var
''  , ; 										// [09] C Consulta F3
.T. , ; 										// [10] L Indica se o campo é editável
NIL , ; 										// [11] C Pasta do campo
NIL , ; 										// [12] C Agrupamento do campo
{'F=Física','J=Jurídica'} , ; 				// [13] A Lista de valores permitido do campo (Combo)
NIL , ; 										// [14] N Tamanho Maximo da maior opção do combo
NIL , ; 										// [15] C Inicializador de Browse
.T. , ; 										// [16] L Indica se o campo é virtual
NIL ) 											// [17] C Picture Variável

//Cria o campo para informar se indicação é de pessoa fisica/juridica que recebe CRM/CNPJ.
oStrB9Y:AddField( ; 							// Ord. Tipo Desc.
'B9Y_CRMCGC' , ; 								// [01] C Nome do Campo
'06' , ; 										// [02] C Ordem
STR0003/*'CRM/CNPJ'*/ , ; 						       // [03] C Titulo do campo
STR0003/*'CRM/CNPJ'*/ , ;	                         // [04] C Descrição do campo
NIL , ; 										// [05] A Array com Help
'C' , ; 										// [06] C Tipo do campo
'@!' , ; 										// [07] C Picture
{|| PLSA809PTV(oModel) } , ; 						// [08] B Bloco de Picture Var
''  , ; 										// [09] C Consulta F3
.T. , ; 										// [10] L Indica se o campo é editável
NIL , ; 										// [11] C Pasta do campo
NIL , ; 										// [12] C Agrupamento do campo
NIL , ; 										// [13] A Lista de valores permitido do campo (Combo)
NIL , ; 										// [14] N Tamanho Maximo da maior opção do combo
NIL , ; 										// [15] C Inicializador de Browse
.T. , ; 										// [16] L Indica se o campo é virtual
NIL ) 											// [17] C Picture Variável

//Cria o campo para informar o protocolo de cada especialidade
oStrB9Q:AddField( ; 							// Ord. Tipo Desc.
'B9Q_NROPRO' , ; 								// [01] C Nome do Campo
'07' , ; 										// [02] C Ordem
STR0004/*'Protocolo'*/ , ; 						       // [03] C Titulo do campo
STR0004/*'Protocolo'*/ , ;	                        // [04] C Descrição do campo
NIL , ; 										// [05] A Array com Help
'C' , ; 										// [06] C Tipo do campo
'@!' , ; 										// [07] C Picture
NIL , ; 				                     // [08] B Bloco de Picture Var
''  , ; 										// [09] C Consulta F3
.F. , ; 										// [10] L Indica se o campo é editável
NIL , ; 										// [11] C Pasta do campo
NIL , ; 										// [12] C Agrupamento do campo
NIL , ; 										// [13] A Lista de valores permitido do campo (Combo)
NIL , ; 										// [14] N Tamanho Maximo da maior opção do combo
NIL , ; 										// [15] C Inicializador de Browse
.T. , ; 										// [16] L Indica se o campo é virtual
NIL ) 											// [17] C Picture Variável

//Cria o campo para informar se o prestador for indicado novamente.
oStrB9Q:AddField( ; 							// Ord. Tipo Desc.
'B9Q_INDPRE' , ; 								// [01] C Nome do Campo
'08' , ; 										// [02] C Ordem
STR0005/*'Indicar'*/ , ; 						       // [03] C Titulo do campo
STR0005/*'Indicar'*/ , ;	                            // [04] C Descrição do campo
NIL , ; 										// [05] A Array com Help
'L' , ; 										// [06] C Tipo do campo
'' , ; 										// [07] C Picture
NIL , ; 				                     // [08] B Bloco de Picture Var
''  , ; 										// [09] C Consulta F3
.T. , ; 										// [10] L Indica se o campo é editável
NIL , ; 										// [11] C Pasta do campo
NIL , ; 										// [12] C Agrupamento do campo
NIL , ; 										// [13] A Lista de valores permitido do campo (Combo)
NIL , ; 										// [14] N Tamanho Maximo da maior opção do combo
NIL , ; 										// [15] C Inicializador de Browse
.T. , ; 										// [16] L Indica se o campo é virtual
NIL ) 											// [17] C Picture Variável

oView := FWFormView():New() // Cria o objeto de View

// Define qual Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona nas views um controle do tipo formulário 
oView:AddField('ViewB9Y' , oStrB9Y,'MasterB9Y' ) 
oView:AddGrid( 'ViewB9V' , oStrB9V,'B9VDetail' ) 
oView:AddGrid( 'ViewB9Q' , oStrB9Q,'B9QDetail' ) 

//Adiciona Campo incremental na View
oView:AddIncrementField( 'ViewB9Q' , 'B9Q_CODSEQ') 
oView:AddIncrementField( 'ViewB9V' , 'B9V_CODSEQ') 
// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 40 ) 
oView:CreateHorizontalBox( 'INFERIOR1', 30 ) 
oView:CreateHorizontalBox( 'INFERIOR2', 30 )

//Atribui a cada view os respectivos "box" criados acima
oView:SetOwnerView('ViewB9Y','SUPERIOR') 
oView:SetOwnerView('ViewB9V','INFERIOR1') 
oView:SetOwnerView('ViewB9Q','INFERIOR2') 

//Atribui título para as Views de detalhe
oView:EnableTitleView( 'ViewB9V', STR0006 ) //'Endereços'			) 
oView:EnableTitleView( 'ViewB9Q', STR0007 )//'Especialidades' 	) 

// REGRA para não alterar os códidos sequenciais 
if (type("cMatricula") == "C" .and. !empty(cMatricula))
	oStrB9Y:SetProperty( 'B9Y_CARTEI' ,  MVC_VIEW_CANCHANGE, .F. )
endif
oStrB9Q:SetProperty( 'B9Q_CODSEQ'  , MVC_VIEW_CANCHANGE, .F. )
oStrB9V:SetProperty( 'B9V_CODSEQ'  , MVC_VIEW_CANCHANGE, .F. )

oView:SetFieldAction('B9Y_CRMCGC', { |oView| PLS809VB9Y(oView, oModel)}) //Carrega grids

//AQUIAQUI
oView:SetFieldAction('B9Y_TIPPES', { |oView| PLSA809SALI(oModel, oView)})
// Retorna o objeto de View criado

oView:SetFieldAction('B9Q_CODESP', { |oView| PlRefrGrid(oModel, oView)})

//Adiciona botão na barra de botões "ações relacionadas"
oView:AddUserButton( STR0017 /*Ver indicações*/ , '', {|| PLSA809VIN(oModel)} )

Return oView 


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809VIN
Abre grid com as especialidades já indicadas pelo beneficiario (B88)
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809VIN(oModel)
Local nOpc := oModel:GetOperation()
Local cProt 
Local oBrwInd

//Se opção = VIEW
If nOpc == 1
	cProt := oModel:GetValue('MasterB9Y', 'B9Y_NROPRO')
	oBrwInd := FWMBrowse():New()
	oBrwInd:SetAlias('B88')
	oBrwInd:SetDescription(STR0018)//Indicações
	oBrwInd:SetMenuDef('PLSA809') //Define o MenuDef
	oBrwInd:SetFilterDefault( "B88_NROPRO == '" + cProt + "' " )
	oBrwInd:Activate()
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9Y809
Tratamento para definir os campos da B9Y que serão usados na Model
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9Y809 (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo <> "B9Y_FILIAL" .AND. cCampo <> "B9Y_CODIGO"; 
                          .AND. cCampo <> "B9Y_CARTEI";
                          .AND. cCampo <> "B9Y_NOMBEN";
                          .AND. cCampo <> "B9Y_NOME";
                          .AND. cCampo <> "B9Y_EMAIL";
                          .AND. cCampo <> "B9Y_TEL";
                          .AND. cCampo <> "B9Y_TIPOAT";
                          .AND. cCampo <> "B9Y_OBS";
                          .AND. cCampo <> "B9Y_NROPRO";
                          .AND. cCampo <> "B9Y_CPFCGC";
                          .AND. cCampo <> "B9Y_CRMNUM";
                          .AND. cCampo <> "B9Y_STCRED";
                          .AND. cCampo <> "B9Y_FCAPTA";
                          .AND. cCampo <> "B9Y_DATAIN";
                          .AND. cCampo <> "B9Y_CODINT";
                          .AND. cCampo <> "B9Y_SOINDI";
                          .AND. cCampo <> "B9Y_ROTINA"
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9Y809
Tratamento para definir os campos da B9Y, B9V e B9Q que serão usados na View
Todo e qualquer campo que será visualizado na rotina deve ser incluido no metodo
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809VI (cCampo)

Local lRet	:= .T.
Local cAliasCpo
cCampo := Alltrim(cCampo)
cAliasCpo := LEFT(cCampo, 3)

If cAliasCpo == "B9Y"
			If (cCampo <> "B9Y_FILIAL" .AND. ;
			    cCampo <> "B9Y_CODIGO" .AND. ;
			    cCampo <> "B9Y_CARTEI" .AND. ;
			    cCampo <> "B9Y_NOMBEN" .AND. ;
			    cCampo <> "B9Y_NOME"   .AND. ;
			    cCampo <> "B9Y_EMAIL"  .AND. ;
			    cCampo <> "B9Y_TEL"    .AND. ;
			    cCampo <> "B9Y_TIPOAT" .AND. ;
			    cCampo <> "B9Y_OBS")
			    
			    		lRet := .F.
			    		
			EndIf
    
ElseIf cAliasCpo == "B9V"
       
			If (cCampo <> "B9V_FILIAL" .AND. ; 
			    cCampo <> "B9V_ENDER"  .AND. ;
			    cCampo <> "B9V_NUMERO" .AND. ;
			    cCampo <> "B9V_COMEND" .AND. ;
			    cCampo <> "B9V_BAIRRO" .AND. ;
			    cCampo <> "B9V_CIDADE" .AND. ;
			    cCampo <> "B9V_CEP"    .AND. ;
			    cCampo <> "B9V_CODLOG" .AND. ;
			    cCampo <> "B9V_DESLOG" .AND. ;
			    cCampo <> "B9V_CODSEQ" .AND. ;
			    cCampo <> "B9V_CODCID")
			                                
						lRet := .F.
			Endif

ElseIf cAliasCpo == "B9Q"		
			If (cCampo <> "B9Q_FILIAL" .AND. ; 
	           cCampo <> "B9Q_CODSEQ" .AND. ;
	           cCampo <> "B9Q_CODESP" .AND. ;
	           cCampo <> "B9Q_DESESP")
		         
		    		lRet := .F.
		   EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9V809
Tratamento para definir os campos da B9V que serão usados na Model
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9V809 (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo <> "B9V_CODPRO" .AND. cCampo <> "B9V_FILIAL";
                          .AND. cCampo <> "B9V_ENDER";
                          .AND. cCampo <> "B9V_NUMERO";
                          .AND. cCampo <> "B9V_COMEND";
                          .AND. cCampo <> "B9V_BAIRRO";
                          .AND. cCampo <> "B9V_CIDADE";
                          .AND. cCampo <> "B9V_CEP";
                          .AND. cCampo <> "B9V_CODLOG";
                          .AND. cCampo <> "B9V_DESLOG";
                          .AND. cCampo <> "B9V_CODSEQ";
                          .AND. cCampo <> "B9V_CODCID";
                          .AND. cCampo <> "B9V_CODPRO";
                          .AND. cCampo <> "B9V_CODINT";
                          .AND. cCampo <> "B9V_CODPRO";
                          .AND. cCampo <> "B9V_SEQB9V"
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9Q809
Tratamento para definir os campos da B9Q que serão usados na Model
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9Q809 (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo <> "B9Q_CODPRO" .AND. cCampo <> "B9Q_FILIAL";
                          .AND. cCampo <> "B9Q_CODSEQ";
                          .AND. cCampo <> "B9Q_CODESP";
                          .AND. cCampo <> "B9Q_DESESP";
                          .AND. cCampo <> "B9Q_CODLOC";
                          .AND. cCampo <> "B9Q_CODINT";
                          .AND. cCampo <> "B9Q_CODPRO"
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809OK
Validar Inclusão da Visita
@author Karine Riquena Limp
@since 14/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809OK(oModel)

Local lRet     		:= .T.
Local oModelMaster   := oModel:GetModel( 'MasterB9Y' )
Local nOpc				:= oModel:GetOperation()
Local cNome          := oModelMaster:GetValue('B9Y_NOME')
Local cEmail         := oModelMaster:GetValue('B9Y_EMAIL')
Local cTel           := oModelMaster:GetValue('B9Y_TEL')
Local cCartei        := oModelMaster:GetValue('B9Y_CARTEI')
Local cMes
Local cAno
Local cProt          := ""

//SE HOUVER ESPECIALIDADE VINCULADA A UM ENDEREÇO EXCLUIDO, EU TBM AS EXCLUO 
PLS809VDEL(oModel)

If Empty(AllTrim(cCartei))
	cMsg := STR0008 //"Informe a carteirinha do beneficiário!"
	Help( ,, 'HELP',, cMsg, 1, 0)
	lRet := .F.
Else
		If Empty(AllTrim(cNome))
			cMsg := STR0009 //"Informe o nome do médico!"
			Help( ,, 'HELP',, cMsg, 1, 0)
			lRet := .F.
		Else
				If Empty(AllTrim(cEmail)) .AND. Empty(AllTrim(cTel))
					cMsg := STR0010 //"Informe o e-mail ou o telefone do médico!"
					Help( ,, 'HELP',, cMsg, 1, 0)
					lRet := .F.
				EndIf
		EndIf
EndIf

If lRet
	   
	If nOpc == 3

	  	cMes        := ALLTRIM(STRZERO(Month(Date()), 2))
	  	cAno        := SUBSTR(ALLTRIM(STR(Year(Date()))), -2) 
	  	cProt       := cMes + cAno + ALLTRIM(oModelMaster:GetValue('B9Y_CODIGO'))
	  	PLSA809NTIP(oModel, cProt)
		
		If !(PLSA809SALI(oModel, cProt))
			cMsg := STR0019 /*"Nenhuma especialidade foi inserida ou indicada!"*/
			Help( ,, 'HELP',, cMsg, 1, 0)
			lRet := .F.
		EndIf
		
    EndIf                       
EndIf

cSTACRMCGC := ""

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807VDEL
Tratamento para deletar registros de especialiade e serviços, caso seja 
deletado o registro do endereço correspondente
@author Karine Limp
@since 05/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS809VDEL(oModel)

Local oB9V		:= oModel:GetModel( 'B9VDetail' ) //Endereço
Local oB9Q		:= oModel:GetModel( 'B9QDetail' ) //Especialidade
Local nI		:= 0
Local nJ		:= 0

For nI := 1 To oB9V:Length() //Verifica quantas linhas tem o Model de Endereços
	oB9V:GoLine( nI ) //Vai para a primeira referente a nI
	
	If oB9V:IsDeleted() //Se o endereço foi deletado, exclui as especialidades e serviços vinculados
	
		For nJ := 1 To oB9Q:Length() //Exclusão das Especialidades sem endereço correspondente
			oB9Q:GoLine( nJ )
			If oB9Q:GetValue( 'B9Q_CODLOC' ) == oB9V:GetValue('B9V_CODSEQ')
				oB9Q:DeleteLine()
			EndIf
		Next
		
	EndIf
Next

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809NTIP
Preenche os códigos do tipo de logradouro e código múnicipio
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809NTIP(oModel, cProt)
Local oModelDetail	:= oModel:GetModel( 'MasterB9Y' )
local oObjB9V		:= oModel:GetModel( 'B9VDetail' )
Local cCRMCNPJ      := oModelDetail:GetValue('B9Y_CRMCGC')
Local cTpPes 		:= oModelDetail:GetValue('B9Y_TIPPES')
Local cCodInt 		:= PLSINTPAD()
local nFor			:= 0
DEFAULT cProt 		:= ""

//Alterando o codigo da operadora no model cabeçalho
oModelDetail:SetValue('B9Y_CODINT', cCodInt)
//Alterando a data no model cabeçalho
oModelDetail:SetValue('B9Y_DATAIN', dDataBase)

If !(Empty(cProt))
		oModelDetail:SetValue('B9Y_NROPRO', cProt)
		oModelDetail:SetValue('B9Y_STCRED', "1")
		oModelDetail:SetValue('B9Y_FCAPTA', "2")
EndIf

//garantir a passagem do valor de chave para os demais "relacionamentos"....
for nFor := 1 to oObjB9V:length()
	oObjB9V:GoLine( nFor )
	oObjB9V:SetValue("B9V_CODPRO", oModelDetail:getValue("B9Y_CODIGO"))
next

If cTpPes == "F"
	oModelDetail:SetValue('B9Y_CRMNUM', cCRMCNPJ) //cCRMCNPJ)
Else
	oModelDetail:SetValue('B9Y_CPFCGC', cCRMCNPJ)//cCRMCNPJ)
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809CAR
Valida carteirinha usuário
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809CAR(cCampo)
local cMsg		:= ""
local lRet 		:= .T.
local dDataAtu	:= Date()
local oModel	:= FwModelActive()
local nOperac	:= iif( oModel:IsActive(), oModel:GetOperation(), 3)
local lInclAlt	:= iif( (nOperac == MODEL_OPERATION_INSERT .or. nOperac == MODEL_OPERATION_UPDATE), .t., .f. )

If lInclAlt .and. GetNewPar("MV_PL809CT", .T.)

	BA1->(DbSetOrder(2)) // BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	If !(BA1->(MsSeek(xFilial("BA1") + Alltrim(cCampo))))
		cMsg := STR0011 //"Beneficiário não encontrado com a carteirinha informada"
		Help( ,, 'HELP',, cMsg, 1, 0)
		lRet := .F.
	Else 
		If GetNewPar("MV_PL809VL",.T.) //Parametro para entrar na validação da validade da Carteirinha
			If dDataAtu > BA1->BA1_DTVLCR
				cMsg := STR0012 //"Carteirinha vencida!"
				Help( ,, 'HELP',, cMsg, 1, 0)
				lRet := .F.
			EndIf
		EndIF
	EndIf
	BA1->(DbCloseArea())
		
EndIf
Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809VCG
Valida CNPJ se tipo de pessoa for "J" 
@author Karine Riquena Limp
@since 06/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809VCG(oModel)
Local lRet := .T.
Local cTipPes := Alltrim(oModel:GetValue('MasterB9Y', 'B9Y_TIPPES'))
Local cCrmCgc := Alltrim(oModel:GetValue('MasterB9Y', 'B9Y_CRMCGC'))

If cTipPes == "J"
	lRet := CGC(cCrmCgc)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809ICG
Inicializa o campo com CRM ou CNPJ 
@author Karine Riquena Limp
@since 06/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809ICG(oModel)
Local cInip := ""
Local cCnpj := Alltrim(oModel:GetValue('MasterB9Y', 'B9Y_CPFCGC'))
Local cCrm  := Alltrim(oModel:GetValue('MasterB9Y', 'B9Y_CRMNUM'))
If !oModel:getOperation() == MODEL_OPERATION_INSERT
	//Como o beneficiário pode informar somente CRM para PF e CNPJ para PJ
	//Verifico se o campo B9Y_CPFCGC é não vazio e maior que 11 (pq depois na rotina de credenciamento pode ser inserido CPF que não entra aqui)
	If !Empty(cCnpj) .AND. Len(cCnpj) > 11 
		cInip := cCnpj
	Else
		cInip := cCrm
	EndIf
EndIf
Return cInip


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809TPP
Inicializa o campo criado no fonte "B9Y_TIPPES"
@author Karine Riquena Limp
@since 06/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809TPP(oModel)
Local cInip := "F"
Local cCnpj := Alltrim(oModel:GetValue('MasterB9Y', 'B9Y_CPFCGC'))
//Como o beneficiário pode informar somente CRM para PF e CNPJ para PJ
//Verifico se o campo B9Y_CPFCGC é não vazio e maior que 11 (pq depois na rotina de credenciamento pode ser inserido CPF que não entra aqui)
If !oModel:getOperation() == MODEL_OPERATION_INSERT .AND. !Empty(cCnpj) .AND. Len(cCnpj) > 11 
	cInip := "J"
EndIf
	
Return cInip


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809PTV
Valida picture de acordo com tipo de pessoa escolhida
@author Karine Riquena Limp
@since 03/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809PTV(oModel)
Local cRetorno := ""
Local oModelMaster 
Local cCRMCGC 
Local cTIPPES

//Se a função for chama da B88
If Valtype(M->B88_CRMCGC) <> "U"
	If M->B88_TIPPES == "J"
		cRetorno := PicPes(M->B88_TIPPES)
	Else
		cRetorno := "@R 999999999999999%C"
	EndIf
//Se chamada do fonte
Else
	If oModel <> NIL
	
		oModelMaster := oModel:GetModel( 'MasterB9Y' )
		cCRMCGC := AllTrim(oModelMaster:GetValue('B9Y_CRMCGC'))
		cTIPPES := AllTrim(oModelMaster:GetValue('B9Y_TIPPES'))
	
		If cTIPPES == "J"
			cRetorno := PicPes(cTIPPES)
		Else
			cRetorno := "@R 999999999999999%C"
		EndIf
		
	Endif	
EndIf

Return (cRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809PTV
Funcao que limpa a grid quando o CRM/CNPJ é trocado
@author Karine Riquena Limp
@since 20/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS809VB9Y(oView, oModel)

Local oModelMaster := oModel:GetModel( 'MasterB9Y' )
Local oB9V		     := oModel:GetModel( 'B9VDetail' ) //Endereço
Local oB9Q         := oModel:GetModel( 'B9QDetail' ) //Especialidade
Local cCRMCNPJ     := AllTrim(oModelMaster:GetValue('B9Y_CRMCGC'))
Local cTpPes       := oModelMaster:GetValue( 'B9Y_TIPPES' )
Local cCodInt      := PLSINTPAD()
Local aCodPro      := {}
Local aCodPre      := {}
Local cDesLog      := ""
Local cDesCid      := ""
Local cDesEsp      := ""
Local aArea   
Local nCountB9V       := 1
Local nCountB9Q       := 1
Local aCamposB9Y  := {}
Local aValB9Y	    := {}
Local nIndUt := 0
Local nI		:= 1
//Se o CRM/CNPJ for igual ao que estava no campo não executo nada
If cSTACRMCGC <> cCRMCNPJ
	//Verifico se foi inserido algo na grid e alerto o usuario
	If !(PLSA809VCR(oModel))
		oModelMaster:SetValue('B9Y_CRMCGC', cSTACRMCGC)
		oView:Refresh()
	Else
		//Atualizo a STATIC do endereço
		cSTACRMCGC := cCRMCNPJ
		//Pego a estrutura de campos do cabeçalho
		aCamposB9Y := oModelMaster:GetStruct():GetFields()
		//Pego os campos e valores da estrutura e salvo num array para não perde-los no DeActivate do model
		aEval( aCamposB9Y, { |aX| Aadd(aValB9Y, {aX[3], oModelMaster:GetValue(aX[3])} ) } )   
		//Desativo o modelo para limpar os dados para que sejam recarregados de acordo com o CRM/CNPJ informado
		oModel:DeActivate()
		//Ativo o modelo para recarregar os dados
		oModel:Activate()
		//Devolvo os valores do cabeçalho 
		aEval( aValB9Y, { |aX| oModelMaster:SetValue(aX[1], aX[2]) } )
							
	   //se for pessoa fisica busco pelo CRM, se juridica CNPJ							
		B9Y->(DbSelectArea("B9Y"))
		If cTpPes == "F"
				B9Y->(DbSetOrder(2))
		Else
				B9Y->(DbSetOrder(3))
		EndIf
	
		If B9Y->(MsSeek(xFilial("B9Y") + cCodInt + cCRMCNPJ ))
			While (B9Y->(!Eof()) .AND. B9Y->B9Y_FILIAL == xFilial("B9Y"))
				If cTpPes == "F" 
					//Adiciono num array todos os códigos que correspondem ao CRM/CNPJ informado
					If (AllTrim(B9Y->B9Y_CRMNUM) == cCRMCNPJ)					
						aAdd(aCodPro, {B9Y->B9Y_CODIGO, B9Y->B9Y_NROPRO} )
					EndIf
					
			   Else
			   
			   		If (AllTrim(B9Y->B9Y_CPFCGC) == cCRMCNPJ)					
						aAdd(aCodPro, {B9Y->B9Y_CODIGO, B9Y->B9Y_NROPRO} )
					EndIf
					
				EndIf
				B9Y->(DbSkip())
			EndDo
		EndIf
		
		B9Y->(DbCloseArea())
		
		//Pego os endereços que tem os codigos encontrados acima
		B9V->(DbSelectArea("B9V"))
		B9V->(DbSetOrder(1))
						
		For nI := 1 To Len(aCodPro)
			If B9V->(MsSeek(xFilial("B9V") + cCodInt + aCodPro[nI][1]))
				While (B9V->(!Eof()) .AND. B9V->B9V_FILIAL == xFilial("B9V") .AND. AllTrim(B9V->B9V_CODPRO) == aCodPro[nI][1])						
							//Pego a descrição da cidade e do logradouro
							aArea := GetArea()
								cDesLog := Posicione("B18",1,xFilial("B18")+B9V->B9V_CODLOG,"B18_DESCRI")
								cDesCid := Posicione("BID",1,xFilial("BID")+B9V->B9V_CODCID,"BID_DESCRI")
							RestArea(aArea)
							
							
							If(nCountB9V > 1)
								oB9V:AddLine()
							EndIf
							//Seto os valores no model
							oB9V:Goline( nCountB9V )
			            	oB9V:SetValue("B9V_FILIAL" , B9V->(B9V_FILIAL))
							oB9V:SetValue("B9V_CODPRO" , B9V->(B9V_CODPRO))
							oB9V:SetValue("B9V_ENDER"  , B9V->(B9V_ENDER))
							oB9V:SetValue("B9V_NUMERO" , B9V->(B9V_NUMERO))
							oB9V:SetValue("B9V_COMEND" , B9V->(B9V_COMEND))
							oB9V:SetValue("B9V_BAIRRO" , B9V->(B9V_BAIRRO))
							oB9V:SetValue("B9V_CEP"    , B9V->(B9V_CEP))
							oB9V:SetValue("B9V_CODCID" , B9V->(B9V_CODCID))
							oB9V:SetValue("B9V_CIDADE" , Alltrim(cDesCid))						
							oB9V:SetValue("B9V_CODLOG" , B9V->(B9V_CODLOG))
							oB9V:SetValue("B9V_DESLOG" , Alltrim(cDesLog))				
							oB9V:SetValue("B9V_STAREG" , .T.)
							nCountB9V++
							
							aArea := GetArea()
							
							//Pego as especialidades com o codigo da B9Y e codigo do Local do endereço da B9V
							B9Q->(DbSelectArea("B9Q"))
							B9Q->(DbSetOrder(5))
							
							If B9Q->(MsSeek(xFilial("B9Q") + cCodInt + B9V->B9V_CODPRO + B9V->B9V_CODSEQ))			
									While((B9Q->(!Eof()) .AND. B9Q->B9Q_FILIAL == xFilial("B9Q")) .AND. (Alltrim(B9Q->B9Q_CODPRO) == AllTrim(B9V->B9V_CODPRO)) .AND. (AllTrim(B9Q->B9Q_CODLOC) == AllTrim(B9V->B9V_CODSEQ)) )
										aArea := GetArea()
											//Descrição da especialidade
											cDesEsp := Posicione("BAQ",7,XFILIAL("BAQ")+B9Q->B9Q_CODESP,"BAQ_DESCRI")
										RestArea(aArea)
										
										If(nCountB9Q > 1)
											oB9Q:AddLine()
										EndIf
										//Seto os valores no model
										oB9Q:SetValue("B9Q_FILIAL" , B9Q->(B9Q_FILIAL))
										oB9Q:SetValue("B9Q_CODPRO" , B9Q->(B9Q_CODPRO))
										oB9Q:SetValue("B9Q_CODLOC" , B9Q->(B9Q_CODLOC))
										oB9Q:SetValue("B9Q_CODESP" , B9Q->(B9Q_CODESP))
										oB9Q:SetValue("B9Q_DESESP" , cDesEsp)
										oB9Q:SetValue("B9Q_NROPRO" , aCodPro[nI][2])
										oB9Q:SetValue("B9Q_STAREG" , .T.)				
										nCountB9Q++
										B9Q->(DbSkip())
									EndDo
									nCountB9Q := 1	
							EndIf
							
							B9Q->(DbCloseArea())
							RestArea(aArea)
					B9V->(DbSkip())
				EndDo	
			EndIf
		Next
						
		B9V->(DbCloseArea()) 
		
		//Aqui é para pegar os medicos credenciados que tenham o CRM/CNPJ informado							
		BAU->(DbSelectArea("BAU"))
		If cTpPes == "F"
				//Na BAU tem um indice só para o Uruguai, que é o 9, portanto ele não consta na base de outros paises
				//Então todos os indices abaixo dele, assumem sua ordem - 1, o 11 fica 10, o 10 fica 9, etc
				nIndUt := PLSBUIND("BAU","BAU_FILIAL + BAU_TIPDOC + BAU_RG") /// Busca da Ordem do indice pela descrição
				nInd := IIF(nIndUt <> 9, 10, 11)
				BAU->(DbSetOrder(nInd))
		Else
				BAU->(DbSetOrder(4))
		EndIf
		
		//Pego os codigos com CRM/CNPJ informado
		If BAU->(MsSeek(xFilial("BAU") + cCRMCNPJ ))
			While (BAU->(!Eof()) .AND. BAU->BAU_FILIAL == xFilial("BAU"))
				If cTpPes == "F" 
					
					If (AllTrim(BAU->BAU_CONREG) == cCRMCNPJ)					
						aAdd(aCodPre, BAU->BAU_CODIGO)
					EndIf
					
			   Else
			   
			   		If (AllTrim(BAU->BAU_CPFCGC) == cCRMCNPJ)					
						aAdd(aCodPre, BAU->BAU_CODIGO)
					EndIf
					
				EndIf
				BAU->(DbSkip())
			EndDo
		EndIf
		
		BAU->(DbCloseArea())
		//Pego os endereços com os codigos encontrados acima
		BB8->(DbSelectArea("BB8"))
		BB8->(DbSetOrder(6))
						
		For nI := 1 To Len(aCodPre)
			If BB8->(MsSeek(xFilial("BB8") + cCodInt + aCodPre[nI]))
				While (BB8->(!Eof()) .AND. BB8->BB8_FILIAL == xFilial("BB8") .AND. BB8->BB8_CODINT == cCodInt .AND. AllTrim(BB8->BB8_CODIGO) == aCodPre[nI])										
							
							If(nCountB9V > 1)
								oB9V:AddLine()
							EndIf
							//Seto os valores no model
							oB9V:Goline( nCountB9V )
			            	oB9V:SetValue("B9V_FILIAL" , BB8->(BB8_FILIAL))
							oB9V:SetValue("B9V_CODPRO" , BB8->(BB8_CODIGO))
							oB9V:SetValue("B9V_ENDER"  , BB8->(BB8_END))
							oB9V:SetValue("B9V_NUMERO" , BB8->(BB8_NR_END))
							oB9V:SetValue("B9V_COMEND" , BB8->(BB8_COMEND))
							oB9V:SetValue("B9V_BAIRRO" , Alltrim(BB8->(BB8_BAIRRO)))
							oB9V:SetValue("B9V_CEP"    , BB8->(BB8_CEP))
							oB9V:SetValue("B9V_CODLOG" , BB8->(BB8_TIPLOG))
							oB9V:SetValue("B9V_CODCID" , BB8->(BB8_CODMUN))
							oB9V:SetValue("B9V_STAREG" , .T.)
							nCountB9V++
							
							aArea := GetArea()
							//Pego as especialidades com os codigos e codigo do endereço acima
							BAX->(DbSelectArea("BAX"))
							BAX->(DbSetOrder(4))
							
							If BAX->(MsSeek(xFilial("BAX") + cCodInt + BB8->BB8_CODIGO + BB8->BB8_CODLOC))			
									While((BAX->(!Eof()) .AND. BAX->BAX_FILIAL == xFilial("BAX")) .AND. BAX->BAX_CODINT == cCodInt .AND. (Alltrim(BAX->BAX_CODIGO) == AllTrim(BB8->BB8_CODIGO)) .AND. (AllTrim(BAX->BAX_CODLOC) == AllTrim(BB8->BB8_CODLOC)) )
									
										aArea := GetArea()
											cDesEsp := Posicione("BAQ",7,XFILIAL("BAQ")+BAX->BAX_CODESP,"BAQ_DESCRI")
										RestArea(aArea)
										
										If(nCountB9Q > 1)
											oB9Q:AddLine()
										EndIf
										//Seto os valores no model
										oB9Q:SetValue("B9Q_FILIAL" , BAX->(BAX_FILIAL))
										oB9Q:SetValue("B9Q_CODPRO" , BAX->(BAX_CODIGO))
										oB9Q:SetValue("B9Q_CODESP" , BAX->(BAX_CODESP))
										oB9Q:SetValue("B9Q_CODLOC" , BAX->(BAX_CODLOC))
										oB9Q:SetValue("B9Q_DESESP" , cDesEsp)
										oB9Q:SetValue("B9Q_NROPRO" , "CREDENCIADO")
										oB9Q:SetValue("B9Q_STAREG" , .T.)				
										nCountB9Q++
										BAX->(DbSkip())
									EndDo
									nCountB9Q := 1	
							EndIf
							
							BAX->(DbCloseArea())
							RestArea(aArea)
					BB8->(DbSkip())
				EndDo	
			EndIf
		Next
						
		BB8->(DbCloseArea())
									
		oView:Refresh()
	EndIf
EndIf				
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809EDT
Validar Edição do campo de indicação ou registros que foram carregados do BD 
@author Karine Riquena Limp
@since 19/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809EDT(oModel, cAlias, cCampo)
Local lRet := .T.
Local lStareg := IIF(cAlias == 'B9Q', oModel:GetValue( 'B9QDetail', 'B9Q_STAREG' ), oModel:GetValue( 'B9VDetail', 'B9V_STAREG' ))
DEFAULT cCampo := ""

If lStareg .AND. cCampo == ""
	lRet := .F.
ElseIf !lStareg .AND. cCampo <> ""
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809VCR
Alertar o usuário na troca do CRM/CNPJ caso ele tenha inserido registros nas grids
@author Karine Riquena Limp
@since 19/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809VCR(oModel)
Local lRet := .T.
Local oB9V		     := oModel:GetModel( 'B9VDetail' ) //Endereço
Local oB9Q         := oModel:GetModel( 'B9QDetail' ) //Especialidade
Local nI          := 1
Local nJ			:= 1
Local nInserted   := 0

		For nI := 1 To oB9V:Length()
			oB9V:Goline( nI )
			If !(oB9V:GetValue('B9V_STAREG'))
				nInserted++
			EndIf
			
			
			//Sempre que as grids tiverem vazias e for inserido um CRM/CNPJ 
			//Precisamos descartar a primeira linha que vem na grid
			//verifico se o codigo da especialidade está vazio e se o endereço e o logradouro tbm estão
			//se estiverem é pq a grid está vazia então a linha deve ser descartada da nossa contagem
		   If oB9Q:Length() == 1
		   		oB9Q:Goline( 1 )
		   		If Empty(AllTrim(oB9Q:GetValue('B9Q_CODESP')))
		   			If Empty(AllTrim(oB9V:GetValue('B9V_DESLOG'))) .AND. Empty(AllTrim(oB9V:GetValue('B9V_ENDER')))
		   				nInserted--
		   			EndIf
		   		EndIf
		   	Else
		   		For nJ := 1 To oB9Q:Length()
					oB9Q:Goline( nJ )
					If !(oB9Q:GetValue('B9Q_STAREG'))
						 nInserted++
					ElseIf (oB9V:GetValue('B9V_STAREG')) .AND. !(oB9Q:GetValue('B9Q_STAREG'))
						 nInserted++
					EndIf
				Next
		    EndIf
				
		Next
				
		If nInserted > 0
			lRet := MsgYesNo(STR0013) //"Existem alterações feitas nos endereços e especialidades que serão perdidas ao alterar o CRM/CNPJ. Deseja mesmo alterar o campo ?"
		EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809SALI
Função que faz a separação dos registros da grid de dados, os que foram inseridos pelo usuário
e os que foram indicados novamente, que serão salvos em outra tabela
@author Karine Riquena Limp
@since 23/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809SALI(oModel, cProt)
Local oModelMaster	:= oModel:GetModel( 'MasterB9Y' )
Local oB9V		  	:= oModel:GetModel( 'B9VDetail' ) //Endereço
Local oB9Q        	:= oModel:GetModel( 'B9QDetail' ) //Especialidade
Local cCRMCNPJ    	:= AllTrim(oModelMaster:GetValue('B9Y_CRMCGC'))
Local nCountB9V   	:= 1
Local nCountB9Q   	:= 1

Local aCamposB9Y	:= {}
Local aValB9Y		:= {}
Local aCamposB9V 	:= {}
Local aValB9V	 	:= {}
Local aAuxB9V    	:= {}
Local aCamposB9Q	:= {}
Local aAuxB9Q		:= {}

Local cCodSeqB9V	:= ""
Local cCodSeqB9Q	:= ""

Local nTamJ			:= 0
Local nJ			:= 1
Local nI			:= 1
Local nK			:= 1
Local nZ			:= 1
 //SALVAR CODLOGRADOURO, CODCIDADE
 
 		//Salvo os valores dos campos do cabecalho para não perde-los no DeActivate do model
		aCamposB9Y := oModelMaster:GetStruct():GetFields()
		aEval( aCamposB9Y, { |aX| Aadd(aValB9Y, {aX[3], oModelMaster:GetValue(aX[3])} ) } ) 
		
		//Pego a estrutura dos campos das grids
		aCamposB9V := oB9V:GetStruct():GetFields()
		aCamposB9Q := oB9Q:GetStruct():GetFields()  

     
       //Percorro a grid de endereços   
		For nI := 1 To oB9V:Length()
			//Posiciono a linha
		    oB9V:Goline(nI)
			if !oB9V:IsDeleted()
				//Pego os campos e os valores dos campos da linha usando um array auxiliar 
				aEval( aCamposB9V, { |aX| Aadd(aAuxB9V, {aX[3], oB9V:GetValue(aX[3])} ) } )
				//Adiciono o array auxiliar para separar cada linha com seus campos e valores
				aAdd(aValB9V, aAuxB9V)
				//Zero o array auxiliar para a proxima linha
				aAuxB9V := {}
			
				If Len(aValB9V) > 0 
				       //Adiciono uma posição vazia que receberá as especialidades do endereço
						aAdd(aValB9V[nI], {})
						//Percorro a grid de especialidades	
						For nJ := 1 To oB9Q:Length()
							//Posiciono a linha
							oB9Q:Goline( nJ )
							//B9Q_STAREG indica se uma especialidade veio do BD (.T.) ou foi inserida (.F.)
							//Verifico se o codigo não está vazio e se a especialidade foi inserida pelo usuario
							If !(Empty(AllTrim(oB9Q:GetValue('B9Q_CODESP')))) .AND. !(oB9Q:GetValue('B9Q_STAREG')) .and. !oB9Q:IsDeleted()
								//Pego os campos e valores dos campos da linha usando um array auxiliar 
								aEval( aCamposB9Q, { |aX| Aadd(aAuxB9Q, {aX[3], oB9Q:GetValue(aX[3])} ) } )
								//Adiciono o array auxiliar para separar cada linha com seus campos e valores
								aAdd(aValB9V[nI][Len(aValB9V[nI])], aAuxB9Q)
								//Zero o array auxiliar para a proxima linha
								aAuxB9Q := {}
							//B9Q_INDPRE serve para quando a especialidade já esta em processo de credenciamento ou credenciada e foi indicada novamente
							//verifico se é .T., isto é, se foi indicada novamente 
							ElseIf !(Empty(AllTrim(oB9Q:GetValue('B9Q_CODESP'))))  .AND. (oB9Q:GetValue('B9Q_STAREG')) .AND. (oB9Q:GetValue('B9Q_INDPRE'))							
								//Adiciono num array de especialidades indicadas que será gravado em outra tabela
								aAdd(aIndic, { { "B88_FILIAL" , xFilial("B88") } , { "B88_CODINT", PLSINTPAD() }, { "B88_CODIGO", GETSXENUM("B88", "B88_CODIGO") }, {"B88_CODESP", oB9Q:GetValue('B9Q_CODESP') } , { "B88_CODLOG", oB9V:GetValue('B9V_CODLOG') }, { "B88_ENDER", oB9V:GetValue('B9V_ENDER') }, { "B88_NUMERO", oB9V:GetValue('B9V_NUMERO') } ,{ "B88_BAIRRO", oB9V:GetValue('B9V_BAIRRO') }, { "B88_CODCID", oB9V:GetValue('B9V_CODCID') }, { "B88_CEP", oB9V:GetValue('B9V_CEP') }, { "B88_CARTEI", oModelMaster:GetValue('B9Y_CARTEI') }, {"B88_TIPPES", oModelMaster:GetValue('B9Y_TIPPES') }, { "B88_CRMCGC", cCRMCNPJ }, { "B88_NROPRO", cProt }, { "B88_FCAPTA", "2" }, { "B88_DATAIN", dDataBase } })
							EndIf
					   Next
					   
					   //Sempre que as grids tiverem vazias e for inserido um CRM/CNPJ 
					   //Precisamos eliminar do array essas posiçoes 'vazias' pois elas não contam como algo inserido pelo usuario
					   If oB9Q:Length() == 1
					   		oB9Q:Goline( 1 )
					   		If Empty(AllTrim(oB9Q:GetValue('B9Q_CODESP')))
					   		   //Se o tipo de logradouro ou endereço  não estiverem preenchidos elimino-os do array
					   			If Empty(AllTrim(oB9V:GetValue('B9V_DESLOG'))) .AND. Empty(AllTrim(oB9V:GetValue('B9V_ENDER')))
					   				nTamI := Len(aValB9V)
					   				ADEL(aValB9V, nTamI)
			   						nTamI--			   						
			   						ASIZE(aValB9V, nTamI)
					   			EndIf
					   		EndIf
					   EndIf
				EndIf
			else
				aAdd(aValB9V, {})
			endif
		Next
		
		//Ajusta o tamanho do array, tirando as posições que foram deletadas da B9V.....
		aAuxB9V := {}
		for nI := 1 to len(aValB9V)
			if ( !empty(aValB9V[nI]) )
				aadd(aAuxB9V, aValB9V[nI])
			endif
		next
		aValB9V := {}
		aValB9V := aClone(aAuxB9V)
		//

		nTamI := Len(aValB9V)
		nI    := nTamI	
		While nI > 0		
			//Verifico se o endereço possui alguma especialidade que tenha sido inserida pelo usuário na grid
			//e caso ele não tenha especialidade, verifico se ele foi inserido pelo usuario
			//as duas condiçoes sendo verdadeiras, deleto esse endereço
			If(nTamI > 0)
			   // Faço Len(aValB9V[nI] - 1) porque a ultima posição do array é outro array com as especialidades
			   //ou seja, temos como saber se houve alteração dentro de um endereço que veio da base
				For nJ := 1 To (Len(aValB9V[nI]) - 1)
					If AllTrim(aValB9V[nI][nJ][1]) == 'B9V_STAREG'
					  If(aValB9V[nI][nJ][2])	 //SE B9V_STAREG == .T.pois a posição "2" é valor do campo	
					  		//Se não tem especialidades	inseridas
							If(Len(aValB9V[nI][Len(aValB9V[nI])]) <= 0)
								ADEL(aValB9V, nI)
			   					nTamI--
			   					ASIZE(aValB9V, nTamI)
			   				EndIf
			   		  EndIf			   		
		   			EndIf
		   		Next
		   	EndIf
		   	
		   	nI--
		EndDo
		
		nTamJ := Len(aValB9V)
		If Len(aIndic) <= 0 .AND. nTamJ <= 0
			Return .F.
		ElseIf Len(aIndic) > 0 .AND. nTamJ <= 0
			oModelMaster:SetValue('B9Y_SOINDI', .T.)
		EndIf

		oModel:DeActivate()
		oModel:Activate()
		
		aEval( aValB9Y, { |aX| oModelMaster:SetValue(aX[1], aX[2]) } )
		
		//Coloco na model apenas os registros que salvarei na base de dados
		For nI := 1 To nTamJ
				//Reordeno o codigo sequencial da grid
				cCodSeqB9V := StrZero((Val(cCodSeqB9V) + 1), Len(Space(TamSX3("B9V_CODSEQ")[1]))) 
				//Adiciono uma linha caso a primeira ja tenha sido adicionada
				//Lembrando que sempre tem uma linha no grid por padrão
				If(nCountB9V > 1)
					oB9V:AddLine()
				EndIf
						//Posiciono a linha para setar os valores
						oB9V:Goline( nCountB9V )
						nTamInI := Len(aValB9V[nI])
						// Faço Len(aValB9V[nI] - 1) porque a ultima posição do array é outro array com as especialidades
						For nJ := 1 To (nTamInI - 1)
							//A terceira dimensão do array indica o nome do campo, se não for o sequencial seto o valor normal
							If AllTrim(aValB9V[nI][nJ][1]) <> 'B9V_CODSEQ'
								oB9V:SetValue(aValB9V[nI][nJ][1], aValB9V[nI][nJ][2])
						   //Senão coloco minha variavel de controle do sequencial
							Else
							    oB9V:SetValue('B9V_CODSEQ', cCodSeqB9V)
							EndIf
						Next
						//Como as especialidades serão sempre a ultima posição de cada endereço, nTamInI recebe o tamanho do array
						If(Len(aValB9V[nI][nTamInI]) > 0)
						   //Para 1 até quantidade de especialidades
							For nK := 1 To Len( aValB9V[nI][nTamInI] )
								//Reordeno o codigo sequencial da grid
								cCodSeqB9Q := StrZero((Val(cCodSeqB9Q) + 1), Len(Space(TamSX3("B9Q_CODSEQ")[1])))
								//Adiciono uma linha caso a primeira ja tenha sido adicionada
								//Lembrando que sempre tem uma linha no grid por padrão
								If(nCountB9Q > 1)
									oB9Q:AddLine()
								EndIf
								//Como dentro da ultima posição do endereço temos as especialidades, preciso percorre-las, e a terceira dimensão do array da ultima posição, são as especialidades
								For nZ := 1 To Len(aValB9V[nI][nTamInI][nK])
									//A quarta dimensão tem o array com campo e valor
									//Exemplo: {B9Q_FILIAL, "01"} 
									//Seto os valores na model
									If (AllTrim(aValB9V[nI][nTamInI][nK][nZ][1]) <> 'B9Q_CODSEQ') .AND. ;
					                 (AllTrim(aValB9V[nI][nTamInI][nK][nZ][1]) <> 'B9Q_CODLOC') .AND. ;
					                 (AllTrim(aValB9V[nI][nTamInI][nK][nZ][1]) <> 'B9Q_INDPRE')
					                 
										oB9Q:SetValue(aValB9V[nI][nTamInI][nK][nZ][1], aValB9V[nI][nTamInI][nK][nZ][2])
										
									ElseIf (AllTrim(aValB9V[nI][nTamInI][nK][nZ][1]) == 'B9Q_CODLOC')
										//Atribuo o codigo do endereço para manter o relacionamento
										oB9Q:SetValue('B9Q_CODLOC', cCodSeqB9V)
										
									ElseIf (AllTrim(aValB9V[nI][nTamInI][nK][nZ][1]) == 'B9Q_CODSEQ') 
										//Atribuo o sequencial de controle
										oB9Q:SetValue('B9Q_CODSEQ', cCodSeqB9Q)
										
									EndIf
								Next
							//Contador de linhas de especialidade
							 nCountB9Q++
							Next
										
						EndIf
						//Contador de linhas de endereços				
			 			nCountB9V++
			 			//Zero o sequencial de especialidades pois começara de 001 para o proximo endereço
			 			cCodSeqB9Q := ""	
			 			nCountB9Q := 1		
		Next
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809ZVA
Função que limpa variável static no clique do botão cancelar (bCancel do Model) e dar rollback no sxe reservado 
@author Karine Riquena Limp
@since 23/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809ZVA()
	cSTACRMCGC := ""
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809COM
Função do Commit do MODEL, momento em que se deve enviar o email na rotina 
@author Karine Riquena Limp
@since 23/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA809COM(oModel)
	Local oModelMaster := oModel:GetModel('MasterB9Y')
	Local nOpc         := oModel:GetOperation()
	Local cProt        := ""
	Local nTamNi
	Local nTamNj
	Local cEmailBenef
	Local cCartei      
	Local cCodigo   
	Local cCodInt      	:= PLSINTPAD()    

	Local cCodSin	:= ""
	Local cMsg
	Local lRet := .T.
	Local nJ			:= 1
	Local nI			:= 1
		
	//PEGO VALORES DA MODEL ANTES DA SALVAR PARA DEIXAR O ALIAS ABERTO NOS POSICIONAMENTOS DO EMAIL
	cCodigo     := oModelMaster:GetValue('B9Y_CODIGO')
	cCartei     := oModelMaster:GetValue('B9Y_CARTEI')
	cCodSin := Left( Funname() + Space( TamSX3("BOJ_ROTINA")[1] ), TamSX3("BOJ_ROTINA")[1] ) + ALLTRIM(str(nOpc))
	cProt       := oModelMaster:GetValue('B9Y_NROPRO')
			
	//Commit manual do model
	FWFormCommit( oModel )	
	nTamNi  := Len(aIndic)

	//RECLOCK para salvar a B88 - indicações/solicitações que "já existem"
	If nTamNi > 0
		Begin Transaction
			For nI := 1 To nTamNi
				B88->(RecLock("B88", .T.))
					nTamNj :=  Len(aIndic[nI])
					For nJ := 1 To nTamNj
						&("B88->" + aIndic[nI][nJ][1]) := aIndic[nI][nJ][2] 						
					Next
				B88->(MsUnlock())
			Next
		End Transaction
	EndIf

	aIndic := {}

	//Confirm SX8
	While __lSx8
		ConfirmSx8()
	End

	//Abertura do ALIAS para posicionar no registro "recém inserido"
	B9Y->(DbSetOrder(1))
	B9Y->(MsSeek(xFilial("B9Y") + cCodInt + cCodigo ))
	//Email do beneficiário que fez a indicação
	cEmailBenef := POSICIONE("BA1",2,XFILIAL("BA1")+cCartei,"BA1_EMAIL")
	//Chamada da Função do envio de email
	If !(Empty(Alltrim(cEmailBenef)))
		cMsg := STR0020 //"Foi enviado um email com as informações da indicação feita pelo beneficiário"
		cMsg += chr(13) + STR0021 //"Se por algum motivo o email não for entregue, informe o protocolo para acompanhamento do andamento da indicação feita"
		cMsg += chr(13) + STR0022 /*"PROTOCOLO: "*/ + cProt
		
		cMsgNotFnd := STR0024//"Cadastro de envio de email não definido para esta rotina, favor cadastrar o mesmo para que seja possível enviar o email ao beneficiário!"
		cMsgNotFnd += chr(13) + STR0025//"O protocolo para acompanhamento do andamento da indicação é:"
		cMsgNotFnd += chr(13) + STR0022 /*"PROTOCOLO: "*/ + cProt
		
		PLSinaliza(cCodSin,cMsg,0,cEmailBenef,"Email agradecimento beneficiário",;
				NiL, "", "", .F., "",;
				.F., "", .F., "000002", "",;
				.F.,cMsgNotFnd)				
	Else
		cMsg := STR0023 //"O beneficiário não possui email cadastrado na base de dados, favor informar o protocolo a ele para que seja possível acompanhar a indicação feita"
		cMsg +=  chr(13) + STR0022 /*"PROTOCOLO: "*/ + cProt
		MsgAlert(cMsg)
	EndIf   	

	lExistEsp  := .T.
	aIndic     := {}
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PL809FBRW
Monta o aRotina para ser utilizado na chamada do call center ³Prestador
@author Fábio S. dos Santos
@since 10/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PL809FBRW(cMatric)
Private aRotina := {}
default cMatric := ""

aAdd( aRotina, { 'Visualizar' 	, 'VIEWDEF.PLSA809' , 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'		, 'VIEWDEF.PLSA809' , 0, 3, 0, NIL } )
aAdd( aRotina, { 'Imprimir'		, 'VIEWDEF.PLSA809' , 0, 8, 0, NIL } )
PLSA809(cMatric)

Return


static function PlRefrGrid(oModel, oView)
local oB9Q	:= oModel:GetModel('B9QDetail')
local oB9V	:= oModel:GetModel('B9VDetail')
if empty( oB9Q:getValue("B9Q_CODLOC") )
	oB9Q:loadvalue("B9Q_CODLOC", oB9V:getValue("B9V_CODSEQ"))
endif
return
