#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'RU09T06.ch'
#include 'RU09XXX.ch'

Class RU09T06EventRUS From FwModelEvent 
	Method New() CONSTRUCTOR	
	Method VldActivate(oModel, cModelID)   
				
EndClass

Method New() Class RU09T06EventRUS
Return Nil
/*{Protheus.doc} RU09T06EventRUS
@type 		method
@author Daria Sergeeva 
@since 07/02/2019
@version 	P12.1.25
*/
Method VldActivate(oModel, cModelID) Class RU09T06EventRUS
Local lRet as Logical
Local nOperation as Numeric

lRet := .T.
nOperation := oModel:GetOperation() 

lRet    := lRet .And. (nOperation != MODEL_OPERATION_UPDATE .Or. F3D->F3D_STATUS != "3" .Or. Empty(F3D_DTLA).Or. FWIsInCallStack('RU09T06001_RETWRIOFF'))

Return lRet