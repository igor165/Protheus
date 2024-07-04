#include "GTPA311A.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Definição do Modelo do MVC

@return: 
	oModel:	Object. Objeto da classe MPFormModel

@sample: oModel := ModelDef()

@author Fernando Radu Muscalu

@since 28/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStrCab := FWFormModelStruct():New()
Local oStrGrd := FWFormModelStruct():New()

GA311Struct(oStrCab,oStrGrd)

oModel := MPFormModel():New("GTPA311A")

oModel:AddFields('MASTER', /*cOwner*/, oStrCab, , , {|oMdl| GA311ACab(oMdl)}) 
oModel:AddGrid('DETAIL', 'MASTER', oStrGrd, , , , , {|oGrd| GA311AGrd(oGrd)} ) 

oModel:SetDescription(STR0001)//"Log de Inconsistências"
oModel:GetModel('MASTER'):SetDescription("Log de Inconsistências")//"Log de Inconsistências"
oModel:GetModel('DETAIL'):SetDescription(STR0042)//"Detalhes do Log"

oModel:GetModel('MASTER'):SetOnlyView(.t.)
oModel:GetModel('DETAIL'):SetOnlyView(.t.)

oModel:GetModel('MASTER'):SetOnlyQuery(.t.)
oModel:GetModel('DETAIL'):SetOnlyQuery(.t.)

oModel:SetPrimaryKey({})

Return(oModel)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef

Definição da View do MVC

@return: 
	oView:	Object. Objeto da classe FWFormView

@sample: oView := ViewDef()

@author Fernando Radu Muscalu

@since 28/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel	:= ModelDef()
Local oStrCab := FWFormViewStruct():New()
Local oStrGrd := FWFormViewStruct():New()

GA311Struct(oStrCab,oStrGrd, .f.)

oView := FwFormView():New()

oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddGrid('VW_DETAIL', oStrGrd, 'DETAIL')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('CORPO', 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VW_DETAIL', 'CORPO')

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView('VW_DETAIL')

oView:SetViewProperty("VW_DETAIL", "ENABLEDGRIDDETAIL", {55})

Return(oView)

//-------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA311Struct

Função responsável pela definição das estruturas utilizadas no Model ou na View.

@Params: 
	oStrCab:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do parâmetro lModel. Cabeçalho 	
	oStrGrd:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do parâmetro lModel. Grid
	lModel:		Lógico. .t. - Será criado/atualizado a estrutura do Model; .f. - será criado/atualizado a
	estrutura da View
	
@sample: GA311Struct(oStrCab, oStrGrd, lModel)

@author Fernando Radu Muscalu

@since 28/12/2015
@version 1.0
*/
//--------------------------------------------------------------------------------------------------------------
Static Function GA311Struct(oStrCab,oStrGrd, lModel)

Default lModel	:= .t.

If ( lModel )
	
	//Estrutura do Model do Cabeçalho (Field)
	oStrCab:AddField(	"Fake Field",;	// Titulo//"Cód. Viagem"
						"Fake Field",;	// Descrição Tooltip//"Código da Viagem"
						"FAKE_FIELD",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						3,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	
	//Estrutura do Model dos Itens (Grid) - Início
	oStrGrd:AddField(	STR0003,;	// Titulo//"Cód. Viagem"//"Matrícula"
						STR0003,;	// Descrição Tooltip//"Código da Viagem"//"Matrícula"
						"MATRICULA",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						TamSx3("RA_MAT")[1],;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?

	oStrGrd:AddField(	STR0005,;	// Titulo//"Cód. Viagem"//"Funcionário"
						STR0005,;	// Descrição Tooltip//"Código da Viagem"//"Funcionário"
						"NOME_FUNCIO",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						TamSx3("RA_NOME")[1],;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0007,;	// Titulo//"Cód. Viagem"//"Dt. Marcação"
						STR0007,;	// Descrição Tooltip//"Código da Viagem"//"Dt. Marcação"
						"DT_MARCA",;	// Nome do Campo
						"D",;			// Tipo de dado do campo
						8,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0009,;	// Titulo//"Cód. Viagem"//"1ª Entrada"
						STR0010,;	// Descrição Tooltip//"Código da Viagem"//"Horário da 1ª Entrada"
						"HR_1ENTRAD",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0011,;	// Titulo//"Cód. Viagem"//"1ª Saida"
						STR0012,;	// Descrição Tooltip//"Código da Viagem"//"Horário da 1ª Saída"
						"HR_1SAIDA",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0013,;	// Titulo//"Cód. Viagem"//"2ª Entrada"
						STR0014,;	// Descrição Tooltip//"Código da Viagem"//"Horário da 2ª Entrada"
						"HR_2ENTRAD",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?

	oStrGrd:AddField(	STR0015,;	// Titulo//"Cód. Viagem"//"2ª Saida"
						STR0016,;	// Descrição Tooltip//"Código da Viagem"//"Horário da 2ª Saída"
						"HR_2SAIDA",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?

	oStrGrd:AddField(	STR0017,;	// Titulo//"Cód. Viagem"//"Detalhes"
						STR0017,;	// Descrição Tooltip//"Código da Viagem"//"Detalhes"
						"DETALHE",;		// Nome do Campo
						"M",;			// Tipo de dado do campo
						10,;			// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Validação do campo
						{|| .T.},;		// Bloco de Edição do campo
						{}, ; 			// Opções do combo
						.f., ; 			// Obrigatório
						Nil, ; 			// Bloco de Inicialização Padrão
						.f., ; 			// Campo é chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	//Estrutura do Model dos Itens (Grid) - Fim
	
Else
	
	//Estrutura da View dos Itens (Grid) - Início
	oStrGrd:AddField(	"MATRICULA",;		// [01] C Nome do Campo
						"01",;				// [02] C Ordem
						STR0019,; 			// [03] C Titulo do campo//"Mat. Funcionario"
						STR0020,; 		// [04] C Descrição do campo//"Matricula do Funcionário"
						{STR0020} ,;		// [05] A Array com Help//"Matricula do Funcionário"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual
	
	oStrGrd:AddField(	"NOME_FUNCIO",;		// [01] C Nome do Campo
						"02",;				// [02] C Ordem
						STR0005,; 			// [03] C Titulo do campo//"Funcionario"
						STR0023,; 		// [04] C Descrição do campo//"Nome do Funcionário"
						{STR0023} ,;		// [05] A Array com Help//"Nome do Funcionário"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual

	oStrGrd:AddField(	"DT_MARCA",;		// [01] C Nome do Campo
						"03",;				// [02] C Ordem
						STR0007,; 			// [03] C Titulo do campo//"Dt. Marcação"
						STR0026,; 		// [04] C Descrição do campo//"Data da Marcação"
						{STR0026} ,;		// [05] A Array com Help//"Data da Marcação"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual
	
	oStrGrd:AddField(	"HR_1ENTRAD",;		// [01] C Nome do Campo
						"04",;				// [02] C Ordem
						STR0009,; 			// [03] C Titulo do campo//"1º Entrada"
						STR0010,; 		// [04] C Descrição do campo//"Horário da 1ª Entrada"
						{STR0010} ,;		// [05] A Array com Help//"Horário da 1ª Entrada"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual

	oStrGrd:AddField(	"HR_1SAIDA",;		// [01] C Nome do Campo
						"05",;				// [02] C Ordem
						STR0011,; 			// [03] C Titulo do campo//"1º Saida"
						STR0012,; 		// [04] C Descrição do campo//"Horário da 1ª Saída"
						{STR0012} ,;		// [05] A Array com Help//"Horário da 1ª Saída"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual

	oStrGrd:AddField(	"HR_2ENTRAD",;		// [01] C Nome do Campo
						"06",;				// [02] C Ordem
						STR0013,; 			// [03] C Titulo do campo//"2º Entrada"
						STR0014,; 		// [04] C Descrição do campo//"Horário da 2ª Entrada"
						{STR0014} ,;		// [05] A Array com Help//"Horário da 2ª Entrada"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual

	oStrGrd:AddField(	"HR_2SAIDA",;		// [01] C Nome do Campo
						"07",;				// [02] C Ordem
						STR0015,; 			// [03] C Titulo do campo//"2º Saida"
						STR0016,; 		// [04] C Descrição do campo//"Horário da 2ª Saída"
						{STR0016} ,;		// [05] A Array com Help//"Horário da 2ª Saída"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual

	oStrGrd:AddField(	"DETALHE",;		// [01] C Nome do Campo
						"08",;				// [02] C Ordem
						STR0017,; 			// [03] C Titulo do campo//"Detalhes"
						STR0017,; 		// [04] C Descrição do campo//"Detalhes"
						{STR0042} ,;		// [05] A Array com Help//"Detalhes do Log"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo é editável
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo é virtual
	//Estrutura da View dos Itens (Grid) - Fim
	
	oStrCab:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
	oStrGrd:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
	
Endif

If (lModel)	
	oStrCab:AddTable("",{},"Master")
	oStrGrd:AddTable("",{},STR0017)	//"Detalhes"
Endif

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA311ACab()
Carga dos Dados do Cabeçalho.
 
@Params:
	oModel:	Objeto da Classe FwFormFieldsModel. Submodelo do cabeçalho do MVC (Fields)

@Return
	aRet:	Array. Retorno que será utilizado no bloco de carga.
		aRet[n,1]: Array. Valores (n) com Dados referentes a estrutura do Cabeçalho
		aRet[n,2]: Numérico. Valor do Recno
		 						
@sample aRet := GA311ACab(oMdl)
@author Fernando Radu Muscalu

@since 28/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GA311ACab(oMdl)
 
Local aRet 	:= {}
Local aAux	:= {}

aAdd(aAux, StrZero(Randomize(1,999),3) ) 

aRet := {aAux, 0} 
 
Return(aRet)

//------------------------------------------------------------------------------------------------------
/*
{Protheus.doc} GA311AGrd()

Função utilizada para a carga das informações do Grid 
 
@Params:
	oGrd:	Objeto da Classe FWFormGridModel. Submodelo grid do MVC

@Return
	aRet:	Array. Retorno que será utilizado no bloco de carga.
		aRet[n,1]: Numérico. Valor do Recno
		aRet[n,2]: Array. Valores (n) com Dados referentes a estrutura dos Itens
		 						
@sample aRet := GA311AGrd(oGrd)
@author Fernando Radu Muscalu

@since 28/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GA311AGrd(oGrd)

Local nI	:= 0

Local aRet	:= {}
Local aAux	:= {}
Local aLog	:= GA311GetError()

For nI := 1 to Len(aLog)
	
	aAux := {	aLog[nI,1],;	//Cód do Funcionário
				aLog[nI,2],;	//Nome do Funcionário
				aLog[nI,3],;	//Data da Marcação
				aLog[nI,4],;	//1ª Marcação (1ª Entrada)
				aLog[nI,5],;	//2ª Marcação (1ª Saída)
				aLog[nI,6],;	//3ª Marcação (2ª Entrada)
				aLog[nI,7],;	//4ª Marcação (2ª Saída)
				aLog[nI,8]}		//Observação do Erro ocorrido
	
	aAdd(aRet, {0,aClone(aAux)})

Next nI

Return(aRet)
