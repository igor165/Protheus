#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU69T01RUS.CH"


/*{Protheus.doc} RU06D06EventRUS
@type 		class
@author Konstantin Cherchik 
@since 10/31/2018
@version P12.1.23
@description Class to handle business procces of RU69T01RUS
*/

Class RU69T01EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
    Method ModelPosVld()
    Method BeforeTTS()
				
EndClass

Method New() Class RU69T01EventRUS
Return Nil

/*{Protheus.doc} RU69T01EventRUS
@type 		method
@author Konstantin Cherchik 
@since 10/31/2018
@version P12.1.23
@description Model pos validation
*/
Method ModelPosVld(oModel, cModelId) Class RU69T01EventRUS
Local lRet      as logical
Local oModelF5Q as object

lRet    := .T.
If cModelId == "RU69T01RUS"
    oModelF5Q   := oModel:GetModel("F5QMASTER")
    If (Empty(oModelF5Q:GetValue("F5Q_A1COD")) .Or. Empty(oModelF5Q:GetValue("F5Q_A1LOJ"))) .And. (Empty(oModelF5Q:GetValue("F5Q_A2COD")) .Or. Empty(oModelF5Q:GetValue("F5Q_A2LOJ")))
        lRet    := .F.
        MsgStop(STR0010)
   /* ElseIf ! Empty(oModelF5Q:GetValue("F5Q_A1COD")) .And. ! Empty(oModelF5Q:GetValue("F5Q_A2COD"))    
        lRet    := .F.
        MsgStop(STR0011)*/  //According to the demand of the consultant, it is possible to fill both the buyer and the supplier at the same time, with the appropriate choice of relationships. Maybe this approach will be changed over time.
    EndIf

    If AllTrim(oModelF5Q:GetValue("F5Q_TYPE")) == '01' .And. (!Empty(oModelF5Q:GetValue("F5Q_A2COD")) .Or. !Empty(oModelF5Q:GetValue("F5Q_A2LOJ"))) 
        If MsgYesNo(STR0018,STR0017)
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2COD","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2LOJ","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2NAME","") 
            lRet := .T.
        Else
            lRet := .F.
        EndIf
    ElseIf AllTrim(oModelF5Q:GetValue("F5Q_TYPE")) == '02' .And. (!Empty(oModelF5Q:GetValue("F5Q_A1COD")) .Or. !Empty(oModelF5Q:GetValue("F5Q_A1LOJ")))
        If MsgYesNo(STR0019,STR0017)
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1COD","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1LOJ","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1NAME","")
            lRet := .T.
        Else
            lRet := .F.
        EndIf
    EndIf

EndIf

Return lRet

/*{Protheus.doc} RU69T01EventRUS
@type 		method
@author Konstantin Cherchik 
@since 04/02/2020
@version 	P12.1.27
@description Key transfer from the header table.  
*/
Method BeforeTTS(oModel, cModelId) Class RU69T01EventRUS 

    Local lRet as logical

    lRet := .T.

    If (oModel:GetOperation() != 5)     //if operation is not a delete 
        lRet := oModel:GetModel("F5RDETAIL"):SetValue("F5R_UIDF5Q",oModel:GetModel("F5QMASTER"):GetValue("F5Q_UID"))
    EndIf

Return lRet
