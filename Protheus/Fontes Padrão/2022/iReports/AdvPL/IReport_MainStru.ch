//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Ireport_mainstru
Estruturas dos Web Service

@version   	P11
/*/
//------------------------------------------------------------------------------------- 
WSSTRUCT InterStru
	WSDATA	Text		As String//Texto para gerar o arquivo de internacionalizacao
	WSDATA 	Language	As String//Lingua para gerar o arquivo
	WSDATA 	FileName	As String//Nome do arquivo de internacionalizacao
ENDWSSTRUCT

// Estrutura das tabelas
WSSTRUCT SysTablesStru
	WSDATA 	Description	As String //Descricao
	WSDATA 	Tabela		As String //Nome do arquivo.
	WSDATA 	Mode		As String //Indica o modo de compartilhamento da Filial.    
	WSDATA 	ModeUn		As String //Indica o modo de compartilhamento da Unidade de Negócio.       
	WSDATA 	ModeEmp		As String //Indica o modo de compartilhamento da Empresa. 
ENDWSSTRUCT

//Estrutura dos campos
WSSTRUCT SysFieldsStru
	WSDATA	Name		As String//Nome do campo
	WSDATA 	Description	As String//Descricao
	WSDATA 	Type		As String//Tipo C,N,L	
ENDWSSTRUCT

//Lista de Relacionamentos
WSSTRUCT lstRelations
	WSDATA Name				As String//Nome da tabela
	WSDATA listConnection	As Array Of lstConnection//Lista de conexoes
ENDWSSTRUCT

//Lista de conexoes
WSSTRUCT lstConnection
	WSDATA TableCDom	As String//Tabela de Contra Dominio	
	WSDATA FieldDom		As String//Campo de Dominio
	WSDATA FieldCDom	As String//Campo de Contra Dominio
ENDWSSTRUCT

//Estrutura das perguntas
WSSTRUCT lstParameters
	WSDATA ParName	As String//Nome do parametro.//Nao usado
	WSDATA ParOrder	As String//Ordem do parametro.
	WSDATA ParValue	As String//Valor do parametro.
ENDWSSTRUCT
