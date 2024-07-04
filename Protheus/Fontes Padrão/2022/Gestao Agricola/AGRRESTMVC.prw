#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static IsRest := .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} AGRRestModel

Publicação dos modelos que devem ficar disponíveis no REST.
Vide classe FwRestModel.

@author Bruno Coelho da Silva
@since 09/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class AGRRestModel From FwRestModel
	Method Activate()
	Method DeActivate()
EndClass

Method Activate() Class AGRRestModel
	IsRest := .T.
Return _Super:Activate()

Method DeActivate() Class AGRRestModel
	IsRest := .F.
Return _Super:DeActivate()

Function AGRIsRest()
	Return IsRest

	/* Publicação dos modelos que são disponibilizados no REST */
	PUBLISH MODEL REST NAME AGRA045 SOURCE AGRA045 RESOURCE OBJECT AGRRestModel //Cadastro de locais de estoque
	PUBLISH MODEL REST NAME AGRA601 SOURCE AGRA601 RESOURCE OBJECT AGRRestModel //Cadastro de fardões
	PUBLISH MODEL REST NAME UBAA040 SOURCE UBAA040 RESOURCE OBJECT AGRRestModel //Cadastro de contaminantes
	PUBLISH MODEL REST NAME UBAW050 SOURCE UBAW050 RESOURCE OBJECT AGRRestModel //Lançamento de contaminantes
	PUBLISH MODEL REST NAME UBAA010 SOURCE UBAA010 RESOURCE OBJECT AGRRestModel //Cadastro de esteira
	PUBLISH MODEL REST NAME UBAW020 SOURCE UBAW020 RESOURCE OBJECT AGRRestModel //Esteira x Fardão
	PUBLISH MODEL REST NAME OGA100  SOURCE OGA100  RESOURCE OBJECT AGRRestModel //Cadastro de safra
	PUBLISH MODEL REST NAME AGRA010 SOURCE AGRA010 RESOURCE OBJECT AGRRestModel //Cadastro de talhão
	PUBLISH MODEL REST NAME AGRA005 SOURCE AGRA005 RESOURCE OBJECT AGRRestModel //Cadastro de fazendas
	PUBLISH MODEL REST NAME AGRA050 SOURCE AGRA050 RESOURCE OBJECT AGRRestModel //Cadastro de variedade do produto
	PUBLISH MODEL REST NAME OGA010  SOURCE OGA010  RESOURCE OBJECT AGRRestModel //Cadastro de entidade
	PUBLISH MODEL REST NAME AGRA001 SOURCE AGRA001 RESOURCE OBJECT AGRRestModel //Cadastro de Ciclo Produtivo (NN1)
	PUBLISH MODEL REST NAME AGRA690 SOURCE AGRA690 RESOURCE OBJECT AGRRestModel //Cadastro de Produtores(DX8)
	PUBLISH MODEL REST NAME AGRA611 SOURCE AGRA611 RESOURCE OBJECT AGRRestModel //Cadastro de Conjuntos
	PUBLISH MODEL REST NAME UBAA110 SOURCE UBAA110 RESOURCE OBJECT AGRRestModel //Cadastro de Conjuntos
	PUBLISH MODEL REST NAME UBAW11  SOURCE UBAW11  RESOURCE OBJECT AGRRestModel //Apontamento de Parada
	PUBLISH MODEL REST NAME AGRA601API  SOURCE AGRA601API  RESOURCE OBJECT AGRRestModel //
	
	
