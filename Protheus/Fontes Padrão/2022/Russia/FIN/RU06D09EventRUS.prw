#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Class RU06D09EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
    Method VldActivate()
    Method ModelPosVld()
    Method AfterTTS()
    Method InTTS()
    Method BeforeTTS()
				
EndClass

Method New() Class RU06D09EventRUS
Return Nil

/*{Protheus.doc} RU06D09EventRUS
@type 		method
@author Konstantin Cherchik 
@since 04/10/2019
@version 	P12.1.25
*/
Method VldActivate(oModel, cModelID) Class RU06D09EventRUS
Local lRet as Logical
Local nOperation as Numeric

lRet := .T.
nOperation := oModel:GetOperation() 

lRet    := lRet .And. (nOperation != MODEL_OPERATION_UPDATE .Or. F5X->F5X_STATUS != "2")

Return lRet

/*{Protheus.doc} RU06D09EventRUS
@type 		method
@author Konstantin Cherchik 
@since 06/13/2019
@version 	P12.1.25
*/
Method ModelPosVld(oModel, cModelID) Class RU06D09EventRUS
Local lRet as Logical
Local nOperation as Numeric
Local nCounter as Numeric
Local nX as Numeric
Local oModelDetail as Object

lRet := .T.
nOperation := oModel:GetOperation() 
oModelDetail := oModel:GetModel("F5WDETAIL")

If nOperation == MODEL_OPERATION_INSERT .And. !oModelDetail:SeekLine({{"MVC_CHK",.T.}}) // Protection, we should export something only if there is selected lines in the grid.
    lRet := .F.
EndIf

Return lRet


/*{Protheus.doc} RU06D09EventRUS
@type 		method
@author Konstantin Cherchik  
@since 04/10/2019
@version 	P12.1.25
*/
Method BeforeTTS(oModel, cModelID) Class RU06D09EventRUS
Local lRet as Logical
Local nOperation as Numeric

lRet := .T.
nOperation := oModel:GetOperation() 

If nOperation == MODEL_OPERATION_INSERT
    lRet := RU06D09018_DelGridLine(oModel) 
ElseIf nOperation == MODEL_OPERATION_UPDATE
    lRet := RU06D09026_POControl(oModel)
EndIf

Return lRet

/*{Protheus.doc} RU06D09EventRUS
@type 		method
@author Konstantin Cherchik 
@since 04/10/2019
@version 	P12.1.25
*/
Method InTTS(oModel, cModelID) Class RU06D09EventRUS
Local lRet as Logical
Local nOperation as Numeric

lRet := .T.
nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE
    lRet := RU06D09022_EditGridLines(oModel)
EndIf

Return lRet 

/*{Protheus.doc} RU06D09EventRUS
@type 		method
@author Konstantin Cherchik 
@since 04/10/2019
@version 	P12.1.25
*/
Method AfterTTS(oModel, cModelID) Class RU06D09EventRUS
Local lRet as Logical
Local nOperation as Numeric

lRet := .T.
nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT
    lRet := RU06D09010_Fopen(oModel)
EndIf

Return lRet 