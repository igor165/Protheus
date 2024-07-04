// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIEvtObject.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject
Classe b�sica dos sistemas de BI, com implementa��o de tratamento de eventos.
As classes que implementam eventos devem necessariamente derivar TBIEvtObject.
Caracter�sticas: 
	- m�todo FireEvent() dispara de forma centralizada todos os eventos.
	- bEvents() define um bloco de c�digo a ser escrito para momentos e instancias
	diferentes da classe, promovendo flexibilidade no tratamento.
	O bloco receber� da chamada os seguintes parametros:
		- oSource: objeto que disparou o evento.
		- nMoment: constante identifica o momento do disparo. (implementa��o espec�fica)
		- nEvent: constante identifica o evento ocorrido. (implementa��o espec�fica)
--------------------------------------------------------------------------------------*/
class TBIEvtObject from TBIObject
	
	data fbEvents	// Bloco para tratamento de eventos
	
	method New() constructor
	method Free()
	method NewEvtObject()
	method FreeEvtObject()
    
	method bEvents(bCode)
	method lFireEvent(nMoment, nEvent)

endclass


/*--------------------------------------------------------------------------------------
@constructor New()
Constroe o objeto em mem�ria.
--------------------------------------------------------------------------------------*/
method New() class TBIEvtObject
	::NewEvtObject()
return

method NewEvtObject() class TBIEvtObject
	::NewObject()
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBIEvtObject
	::FreeEvtObject()
return

method FreeEvtObject() class TBIEvtObject
return


/*-------------------------------------------------------------------------------------
@property bEvents(bCode)
Define/Recupera um bloco de c�digo a tratar a ocorrencia dos eventos.
O bloco receber� da chamada os seguintes parametros, em ordem:
	- oSource: objeto que disparou o evento.
	- nMoment: constante identifica o momento do disparo. (implementa��o espec�fica)
	- nEvent: constante identifica o evento ocorrido. (implementa��o espec�fica)
@param bCode - Bloco de c�digo a definir para os eventos.
@return - Bloco de c�digo atualmente definido para os eventos.
--------------------------------------------------------------------------------------*/
method bEvents(bCode) class TBIEvtObject
	property ::fbEvents := bCode
return ::fbEvents

/*-------------------------------------------------------------------------------------
@method lFireEvent(nMoment, nEvent)
Dispara o evento.
@param nMoment: constante identifica o momento do disparo. (implementa��o espec�fica)
@param nEvent: constante identifica o evento ocorrido. (implementa��o espec�fica)
--------------------------------------------------------------------------------------*/
method lFireEvent(nMoment, nEvent) class TBIEvtObject
	// Abstrato ?
return

function _TBIEvtObject()
return nil