#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
// XCOMMANDS.  
//-------------------------------------------------------------------
// Entidades
#XCOMMAND NEW ENTITY <entity>;
	=>;
   Function BAX<entity>();;
   Return nil

// App
#XCOMMAND NEW APP <app>;
	=>;
   Function BA_<app>();;
   Return nil
//-------------------------------------------------------------------
// ENTITIES.
//-------------------------------------------------------------------
#DEFINE FACT		"F"
#DEFINE DIMENSION 	"D"

//-------------------------------------------------------------------
// QUERIES.
//-------------------------------------------------------------------
#DEFINE COMPANY_QUERY 1 // Posição da query.
#DEFINE COMPANY_NAME  2 // Posição da Empresa.

//-------------------------------------------------------------------
// GENÉRICOS.
//-------------------------------------------------------------------
#DEFINE CRYPT_TYPE 	"RC4" 

//-------------------------------------------------------------------
// TRATAMENTO DE ERROS
//-------------------------------------------------------------------
#DEFINE MSG_SUCESS              0 // Gerada com sucesso
#DEFINE MSG_ERR_TABLE_NOT_EXIST 1 // Tabela não existe; 
#DEFINE MSG_ERR_EMPTY_QUERY     2 // Erro de query em branco ou vazia.

//-------------------------------------------------------------------
// TIPO DE EXTRAÇÃO DA ENTIDADE
// Este item define o tipo de extração da entidade e caso não seja 
// informado durante a criação da entidade, o sistema adota o padrão
// P=período. Este define é de uso específico das fatos e não deve
// alterar o fluxo das dimensões, independentemente do tipo informado. 
//-------------------------------------------------------------------
#DEFINE BYMONTH		"M"	//Mensal
