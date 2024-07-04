#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
// XCOMMANDS.  
//-------------------------------------------------------------------
// DataModel
#XCOMMAND NEW DATAMODEL <entity>;
	=>;
   Function BCZ<entity>();;
   Return nil

// Aplicação
#XCOMMAND NEW APPLICATION <app>;
	=>;
   Function BCY<app>();;
   Return nil

#DEFINE MSG_SUCESS              0 // Gerada com sucesso
#DEFINE MSG_ERR_TABLE_NOT_EXIST 1 // Tabela não existe; 
#DEFINE MSG_ERR_EMPTY_QUERY     2 // Erro de query em branco ou vazia.
#DEFINE MSG_ERR_CREATE_VIEW     3 // Erro ao criar a view
#DEFINE MSG_ERR_VIEW_STRUCT     4 // Erro na estrutura da view ou tabela não existe.

//-------------------------------------------------------------------
// GENÉRICOS.
//-------------------------------------------------------------------
#DEFINE CRYPT_TYPE 	"RC4" 