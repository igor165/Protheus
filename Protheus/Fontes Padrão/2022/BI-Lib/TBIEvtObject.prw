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
Classe básica dos sistemas de BI, com implementação de tratamento de eventos.
As classes que implementam eventos devem necessariamente derivar TBIEvtObject.
Características: 
	- método FireEvent() dispara de forma centralizada todos os eventos.
	- bEvents() define um bloco de código a ser escrito para momentos e instancias
	diferentes da classe, promovendo flexibilidade no tratamento.
	O bloco receberá da chamada os seguintes parametros:
		- oSource: objeto que disparou o evento.
		- nMoment: constante identifica o momento do disparo. (implementação específica)
		- nEvent: constante identifica o evento ocorrido. (implementação específica)
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
Constroe o objeto em memória.
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
Define/Recupera um bloco de código a tratar a ocorrencia dos eventos.
O bloco receberá da chamada os seguintes parametros, em ordem:
	- oSource: objeto que disparou o evento.
	- nMoment: constante identifica o momento do disparo. (implementação específica)
	- nEvent: constante identifica o evento ocorrido. (implementação específica)
@param bCode - Bloco de código a definir para os eventos.
@return - Bloco de código atualmente definido para os eventos.
--------------------------------------------------------------------------------------*/
method bEvents(bCode) class TBIEvtObject
	property ::fbEvents := bCode
return ::fbEvents

/*-------------------------------------------------------------------------------------
@method lFireEvent(nMoment, nEvent)
Dispara o evento.
@param nMoment: constante identifica o momento do disparo. (implementação específica)
@param nEvent: constante identifica o evento ocorrido. (implementação específica)
--------------------------------------------------------------------------------------*/
method lFireEvent(nMoment, nEvent) class TBIEvtObject
	// Abstrato ?
return

function _TBIEvtObject()
return nil