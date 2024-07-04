#include "GTPA311A.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Defini��o do Modelo do MVC

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

oModel:SetDescription(STR0001)//"Log de Inconsist�ncias"
oModel:GetModel('MASTER'):SetDescription("Log de Inconsist�ncias")//"Log de Inconsist�ncias"
oModel:GetModel('DETAIL'):SetDescription(STR0042)//"Detalhes do Log"

oModel:GetModel('MASTER'):SetOnlyView(.t.)
oModel:GetModel('DETAIL'):SetOnlyView(.t.)

oModel:GetModel('MASTER'):SetOnlyQuery(.t.)
oModel:GetModel('DETAIL'):SetOnlyQuery(.t.)

oModel:SetPrimaryKey({})

Return(oModel)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef

Defini��o da View do MVC

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

//Habitila os t�tulos dos modelos para serem apresentados na tela
oView:EnableTitleView('VW_DETAIL')

oView:SetViewProperty("VW_DETAIL", "ENABLEDGRIDDETAIL", {55})

Return(oView)

//-------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA311Struct

Fun��o respons�vel pela defini��o das estruturas utilizadas no Model ou na View.

@Params: 
	oStrCab:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do par�metro lModel. Cabe�alho 	
	oStrGrd:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do par�metro lModel. Grid
	lModel:		L�gico. .t. - Ser� criado/atualizado a estrutura do Model; .f. - ser� criado/atualizado a
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
	
	//Estrutura do Model do Cabe�alho (Field)
	oStrCab:AddField(	"Fake Field",;	// Titulo//"C�d. Viagem"
						"Fake Field",;	// Descri��o Tooltip//"C�digo da Viagem"
						"FAKE_FIELD",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						3,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	
	//Estrutura do Model dos Itens (Grid) - In�cio
	oStrGrd:AddField(	STR0003,;	// Titulo//"C�d. Viagem"//"Matr�cula"
						STR0003,;	// Descri��o Tooltip//"C�digo da Viagem"//"Matr�cula"
						"MATRICULA",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						TamSx3("RA_MAT")[1],;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?

	oStrGrd:AddField(	STR0005,;	// Titulo//"C�d. Viagem"//"Funcion�rio"
						STR0005,;	// Descri��o Tooltip//"C�digo da Viagem"//"Funcion�rio"
						"NOME_FUNCIO",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						TamSx3("RA_NOME")[1],;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0007,;	// Titulo//"C�d. Viagem"//"Dt. Marca��o"
						STR0007,;	// Descri��o Tooltip//"C�digo da Viagem"//"Dt. Marca��o"
						"DT_MARCA",;	// Nome do Campo
						"D",;			// Tipo de dado do campo
						8,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0009,;	// Titulo//"C�d. Viagem"//"1� Entrada"
						STR0010,;	// Descri��o Tooltip//"C�digo da Viagem"//"Hor�rio da 1� Entrada"
						"HR_1ENTRAD",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0011,;	// Titulo//"C�d. Viagem"//"1� Saida"
						STR0012,;	// Descri��o Tooltip//"C�digo da Viagem"//"Hor�rio da 1� Sa�da"
						"HR_1SAIDA",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	oStrGrd:AddField(	STR0013,;	// Titulo//"C�d. Viagem"//"2� Entrada"
						STR0014,;	// Descri��o Tooltip//"C�digo da Viagem"//"Hor�rio da 2� Entrada"
						"HR_2ENTRAD",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?

	oStrGrd:AddField(	STR0015,;	// Titulo//"C�d. Viagem"//"2� Saida"
						STR0016,;	// Descri��o Tooltip//"C�digo da Viagem"//"Hor�rio da 2� Sa�da"
						"HR_2SAIDA",;	// Nome do Campo
						"C",;			// Tipo de dado do campo
						4,;				// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?

	oStrGrd:AddField(	STR0017,;	// Titulo//"C�d. Viagem"//"Detalhes"
						STR0017,;	// Descri��o Tooltip//"C�digo da Viagem"//"Detalhes"
						"DETALHE",;		// Nome do Campo
						"M",;			// Tipo de dado do campo
						10,;			// Tamanho do campo
						0,;				// Tamanho das casas decimais
						Nil,;			// Bloco de Valida��o do campo
						{|| .T.},;		// Bloco de Edi��o do campo
						{}, ; 			// Op��es do combo
						.f., ; 			// Obrigat�rio
						Nil, ; 			// Bloco de Inicializa��o Padr�o
						.f., ; 			// Campo � chave
						.T., ; 			// Atualiza?
						.t. ) 			// Virtual?
	
	//Estrutura do Model dos Itens (Grid) - Fim
	
Else
	
	//Estrutura da View dos Itens (Grid) - In�cio
	oStrGrd:AddField(	"MATRICULA",;		// [01] C Nome do Campo
						"01",;				// [02] C Ordem
						STR0019,; 			// [03] C Titulo do campo//"Mat. Funcionario"
						STR0020,; 		// [04] C Descri��o do campo//"Matricula do Funcion�rio"
						{STR0020} ,;		// [05] A Array com Help//"Matricula do Funcion�rio"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual
	
	oStrGrd:AddField(	"NOME_FUNCIO",;		// [01] C Nome do Campo
						"02",;				// [02] C Ordem
						STR0005,; 			// [03] C Titulo do campo//"Funcionario"
						STR0023,; 		// [04] C Descri��o do campo//"Nome do Funcion�rio"
						{STR0023} ,;		// [05] A Array com Help//"Nome do Funcion�rio"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual

	oStrGrd:AddField(	"DT_MARCA",;		// [01] C Nome do Campo
						"03",;				// [02] C Ordem
						STR0007,; 			// [03] C Titulo do campo//"Dt. Marca��o"
						STR0026,; 		// [04] C Descri��o do campo//"Data da Marca��o"
						{STR0026} ,;		// [05] A Array com Help//"Data da Marca��o"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual
	
	oStrGrd:AddField(	"HR_1ENTRAD",;		// [01] C Nome do Campo
						"04",;				// [02] C Ordem
						STR0009,; 			// [03] C Titulo do campo//"1� Entrada"
						STR0010,; 		// [04] C Descri��o do campo//"Hor�rio da 1� Entrada"
						{STR0010} ,;		// [05] A Array com Help//"Hor�rio da 1� Entrada"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual

	oStrGrd:AddField(	"HR_1SAIDA",;		// [01] C Nome do Campo
						"05",;				// [02] C Ordem
						STR0011,; 			// [03] C Titulo do campo//"1� Saida"
						STR0012,; 		// [04] C Descri��o do campo//"Hor�rio da 1� Sa�da"
						{STR0012} ,;		// [05] A Array com Help//"Hor�rio da 1� Sa�da"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual

	oStrGrd:AddField(	"HR_2ENTRAD",;		// [01] C Nome do Campo
						"06",;				// [02] C Ordem
						STR0013,; 			// [03] C Titulo do campo//"2� Entrada"
						STR0014,; 		// [04] C Descri��o do campo//"Hor�rio da 2� Entrada"
						{STR0014} ,;		// [05] A Array com Help//"Hor�rio da 2� Entrada"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual

	oStrGrd:AddField(	"HR_2SAIDA",;		// [01] C Nome do Campo
						"07",;				// [02] C Ordem
						STR0015,; 			// [03] C Titulo do campo//"2� Saida"
						STR0016,; 		// [04] C Descri��o do campo//"Hor�rio da 2� Sa�da"
						{STR0016} ,;		// [05] A Array com Help//"Hor�rio da 2� Sa�da"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@R 99:99",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual

	oStrGrd:AddField(	"DETALHE",;		// [01] C Nome do Campo
						"08",;				// [02] C Ordem
						STR0017,; 			// [03] C Titulo do campo//"Detalhes"
						STR0017,; 		// [04] C Descri��o do campo//"Detalhes"
						{STR0042} ,;		// [05] A Array com Help//"Detalhes do Log"
						"GET",; 			// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;				// [07] C Picture
						NIL,; 				// [08] B Bloco de Picture Var
						"",; 				// [09] C Consulta F3
						.t.,; 				// [10] L Indica se o campo � edit�vel
						NIL, ; 				// [11] C Pasta do campo
						NIL,; 				// [12] C Agrupamento do campo
						{},; 				// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 				// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;	 			// [15] C Inicializador de Browse
						.t.) 				// [16] L Indica se o campo � virtual
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
Carga dos Dados do Cabe�alho.
 
@Params:
	oModel:	Objeto da Classe FwFormFieldsModel. Submodelo do cabe�alho do MVC (Fields)

@Return
	aRet:	Array. Retorno que ser� utilizado no bloco de carga.
		aRet[n,1]: Array. Valores (n) com Dados referentes a estrutura do Cabe�alho
		aRet[n,2]: Num�rico. Valor do Recno
		 						
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

Fun��o utilizada para a carga das informa��es do Grid 
 
@Params:
	oGrd:	Objeto da Classe FWFormGridModel. Submodelo grid do MVC

@Return
	aRet:	Array. Retorno que ser� utilizado no bloco de carga.
		aRet[n,1]: Num�rico. Valor do Recno
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
	
	aAux := {	aLog[nI,1],;	//C�d do Funcion�rio
				aLog[nI,2],;	//Nome do Funcion�rio
				aLog[nI,3],;	//Data da Marca��o
				aLog[nI,4],;	//1� Marca��o (1� Entrada)
				aLog[nI,5],;	//2� Marca��o (1� Sa�da)
				aLog[nI,6],;	//3� Marca��o (2� Entrada)
				aLog[nI,7],;	//4� Marca��o (2� Sa�da)
				aLog[nI,8]}		//Observa��o do Erro ocorrido
	
	aAdd(aRet, {0,aClone(aAux)})

Next nI

Return(aRet)
