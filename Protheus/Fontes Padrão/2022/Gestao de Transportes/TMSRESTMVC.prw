#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static IsRest := .F.
 
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSRESTMVC
Publicação dos modelos que devem ficar disponíveis no REST.
Vide classe FwRestModel.
@author Gustavo Krug
@since 05/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Class TMSRestModel From FwRestModel
    Method Activate()
    Method DeActivate()
EndClass

Method Activate() Class TMSRestModel
    IsRest := .T.
Return _Super:Activate()

Method DeActivate() Class TMSRestModel
    IsRest := .F.
Return _Super:DeActivate()

Function TMSIsRest()
Return IsRest 

// Publicacao dos modelos que sao disponibilizados no REST

PUBLISH MODEL REST NAME TMSA153A SOURCE TMSA153A RESOURCE OBJECT TMSRestModel
