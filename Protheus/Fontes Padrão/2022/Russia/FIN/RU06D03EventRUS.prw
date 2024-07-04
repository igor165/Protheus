#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
  

/*{Protheus.doc} RU06D03EventRUS
@type 		class
@author 	Alexander Salov
@version 	1.0
@since		20.12.2017
@description Class to handle business procces of RU06D03
*/

Class RU06D03EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
    Method BeforeTTS()
				
EndClass

/*{Protheus.doc} RU06D03EventRUS
@type 		method
@author 	Alexander Salov
@version 	1.0
@since		20.12.2017
@description Basic constructor. 
*/
Method BeforeTTS(oModel, cModelId) Class RU06D03EventRUS 

oModel:GetModel("F4NMASTER"):LoadValue("FAKEFIELD",'X')
oModel:GetModel("F4NDETAILS"):LoadValue("F4N_FILIAL",xFilial("F4N"))
oModel:GetModel("F4NDETAILS"):LoadValue("F4N_CLIENT",SA1->A1_COD)
oModel:GetModel("F4NDETAILS"):LoadValue("F4N_LOJA",SA1->A1_LOJA)

Return Nil

Method New() Class RU06D03EventRUS
Return Nil


// Russia_R5
