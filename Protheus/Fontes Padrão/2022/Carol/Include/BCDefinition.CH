#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
//   ENTITIES.
//-------------------------------------------------------------------
#DEFINE FACT		"F"
#DEFINE DIMENSION 	"D"

//-------------------------------------------------------------------
// XCOMMANDS.  
//-------------------------------------------------------------------
// DAtaModel
#XCOMMAND NEW DATAMODEL <entity>;
	=>;
   Function BCX<entity>();;
   Return nil

// Aplicação
#XCOMMAND NEW APPLICATION <app>;
	=>;
   Function BC_<app>();;
   Return nil

#DEFINE MSG_SUCESS              0 // Gerada com sucesso
#DEFINE MSG_ERR_TABLE_NOT_EXIST 1 // Tabela nao existe; 
#DEFINE MSG_ERR_EMPTY_QUERY     2 // Erro de query em branco ou vazia.
#DEFINE MSG_ERR_CREATE_VIEW     3 // Erro ao criar a view
#DEFINE MSG_ERR_VIEW_STRUCT     4 // Erro na estrutura da view ou tabela nao existe.

//-------------------------------------------------------------------
// GENERICOS.
//-------------------------------------------------------------------
#DEFINE CRYPT_TYPE 	"RC4" 