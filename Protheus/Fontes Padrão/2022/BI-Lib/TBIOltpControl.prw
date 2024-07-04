// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIOltpController.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIOltpController
Classe gera um objeto controlador de transa��o para conex�o com o top.
Caracter�sticas: 
	- Begin transaction.
	- Commit.
	- Rollback.
	- End transaction.
--------------------------------------------------------------------------------------*/
class TBIOltpController from TBIObject

	data fnPilha			// Ordem do comando na pilha (n�o alterar)

	data flRollbacked		// Indica se houve rollback durante a transa��o

	data faTransactions		// Pilha de transa��es, formato elemento: [nome rotina, linha rotina]
							// Empilha os nomes das funcoes que abriram transa��o
							// Desempilha quando as mesmas fecham a transa��o que abriram
							// Gera erro se a mesma fun��o que abriu n�o fechar sua transa��o

	method New() constructor
	method Free()
	method NewOltpController() 
	method FreeOltpController()
               
	method lOnTransaction()
	method lBeginTransaction()
	method lCommit()
	method lRollback()
	method lEndTransaction()

endclass

/*--------------------------------------------------------------------------------------
@constructor New()
Constroe o objeto em mem�ria.
--------------------------------------------------------------------------------------*/
method New() class TBIOltpController
	::NewOltpController()
return

method NewOltpController() class TBIOltpController
	::NewObject()
     
	::flRollbacked := .f.
	::faTransactions := {}
	::fnPilha := 1
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBIOltpController
	::FreeOltpController()
return

method FreeOltpController() class TBIOltpController
	::FreeObject()
return


/*--------------------------------------------------------------------------------------
@property lOnTransaction()
Recupera se est� ocorrendo uma transa��o.
@return - .t. se est� em transa��o. / .f. se n�o est� em transa��o.
--------------------------------------------------------------------------------------*/                         
method lOnTransaction() class TBIOltpController
return (len(::faTransactions) > 0)

/*--------------------------------------------------------------------------------------
@method lBeginTransaction()
Abre uma transa��o no contexto corrente.
@return - .t. se fechar ok / .f. se gerar exce��o
--------------------------------------------------------------------------------------*/                         
method lBeginTransaction() class TBIOltpController
	local lRet := .t.
	
	if( len(::faTransactions) == 0 )
		::flRollbacked := .f.
		TCCOMMIT(1) // begin transaction
	endif
	
	aAdd(::faTransactions, { alltrim(cBIStr(procname(::fnPilha))), alltrim(cBIStr(procline(::fnPilha))) })
	
return lRet

/*--------------------------------------------------------------------------------------
@method lCommit()
"Comita" (grava dados) de uma transa��o na contexto corrente.
@return - .t. se fechar ok / .f. se gerar exce��o
--------------------------------------------------------------------------------------*/                         
method lCommit() class TBIOltpController
	local lRet := .t.
	
	if( len(::faTransactions) == 0 )
		// error
		ExUserException("OltpController Error: Commit sem Begin Transaction.")
	endif

	TCCOMMIT(2) // commit
	
return lRet

/*--------------------------------------------------------------------------------------
@method lRollback()
"Rollback" (retorna os dados anteriores) a uma transa��o na contexto corrente.
@return - .t. se fechar ok / .f. se gerar exce��o
--------------------------------------------------------------------------------------*/                         
method lRollback() class TBIOltpController
	local lRet := .t.
	
	if( len(::faTransactions) == 0 )
		// error
		ExUserException("OltpController Error: Rollback sem Begin Transaction.")
	endif
	
	::flRollbacked := .t.
	dbgotop()

	TCCOMMIT(3) //rollback  
	TCCOMMIT(4) //end transaction
	
return lRet

/*--------------------------------------------------------------------------------------
@method lEndTransaction()
Fecha uma transa��o na contexto corrente.
@return - .t. se fechar ok / .f. se gerar exce��o
--------------------------------------------------------------------------------------*/                         
method lEndTransaction() class TBIOltpController
	local lRet := .t.

	if( len(::faTransactions) == 0 )
		// error
		ExUserException("OltpController Error: End Transaction sem Begin Transaction.")
	endif

	if( ::faTransactions[len(::faTransactions)][1] != alltrim(cBIStr(procname(::fnPilha))) )
		// error
		ExUserException("OltpController Error: Transa��o aberta em " + ::faTransactions[len(::faTransactions)][1] ;
			+ "(" + ::faTransactions[len(::faTransactions)][2] + ") deve ser fechada antes com End Transaction.")
	endif

	BIADel(::faTransactions, len(::faTransactions))

	if( len(::faTransactions) == 0 .and. !::flRollbacked)
		TCCOMMIT(2) // commit
		TCCOMMIT(4) // end transaction
	endif

	if( len(::faTransactions) == 0)	
		dBUnlockAll()
	endif
	
return lRet

function _tbioltpcontrol()
return nil