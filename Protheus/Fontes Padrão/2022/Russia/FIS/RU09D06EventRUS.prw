#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
  

/*{Protheus.doc} RU06D06EventRUS
@type 		class
@author Konstantin Cherchik 
@since 02/04/2018
@version 	P12.1.17
@description Class to handle business procces of RU09D06
*/

Class RU09D06EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
    Method BeforeTTS()
				
EndClass

/*{Protheus.doc} RU09D06EventRUS
@type 		method
@author Konstantin Cherchik 
@since 02/04/2018 
@version 	P12.1.17
@description Basic constructor.  
*/
Method BeforeTTS(oModel, cModelId) Class RU09D06EventRUS 

if (oModel:GetOperation() != 5)     //if operation is not a delete 
    oModel:GetModel("F51DETAILS"):SetValue("F51_KEY",oModel:GetModel("F50MAIN"):GetValue("F50_KEY"))
endif

Return Nil

Method New() Class RU09D06EventRUS
Return Nil


// Russia_R5
