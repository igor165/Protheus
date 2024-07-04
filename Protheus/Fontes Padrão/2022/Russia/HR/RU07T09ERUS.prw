#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RU07T09.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} RU07T09EVRUS()
Event class for RU07T09

@author raquel.andrade
@type Class
@since 05/07/2018
/*/
Class RU07T09EVRUS From FwModelEvent 
    
    Method New() CONSTRUCTOR
    Method InTTS()
    Method ModelPosVld()

    //Records SR9 and SRA
    Method RecALL()

EndClass

//------------------------------------------------------------------
/*/{Protheus.doc} New()
Constructor for the class RU07T09EVRUS

@author raquel.andrade
@type Class
@since 05/07/2018
/*/
Method New() Class RU07T09EVRUS
Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} InTTS()
Method that runs inside the transaction.

@author raquel.andrade
@type Class
@since 05/07/2018
/*/
Method InTTS(oModel, cModelId) Class RU07T09EVRUS
    Local oModelTMP := oModel:GetModel("RU07T09_MOPER")

    //Records SR9 and SRA
    ::RecALL(oModel)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} RecALL()
Method that records the tables SRA/SR9.

@author raquel.andrade
@type Class
@since 05/07/2018
/*/
Method RecALL(oModel) Class RU07T09EVRUS
    Local nX As Numeric
    Local oStruOPER As Object
    Local oModelTMP As Object
    Local aRecFields As Array
    Local aFields As Array
    Local aAreaSR9 As Array
    Local cKey As Char

    aAreaSR9 := SR9->(GetArea())
    oModRd0 := oModel:GetModel("RU07T09_MRD0")
    oModelTMP := oModel:GetModel("RU07T09_MOPER")
    oStruOPER := oModelTMP:GetStruct()
    aFields := oStruOPER:GetFields()

    aRecFields := {	{"NAME","RA_PRINOME"},;
                    {"MDNAME","RA_SECNOME"},;
                    {"SURNAME","RA_PRISOBR"},;
                    {"FULLNME","RA_NOME"},;
                    {"SIGNME","RA_NSOCIAL"}}

    cKey := RU07T0914_GetSraKey(RD0->RD0_CODIGO)

    If !Empty(cKey)
        SRA->(DbSetOrder(1)) // RA_FILIAL + RA_MAT
        If SRA->(DbSeek(cKey))
            For nX :=1 To Len(aFields)
                If (nPos:= aScan(aRecFields,{|x| x[1] == aFields[nX][3]})) > 0
                    If !Empty(oModelTMP:GetValue(aFields[nX][3]))
                        
                        SR9->(DbSetOrder(2))
                        If !SR9->(DbSeek(cKey+aRecFields[nPos][2]))
                            RecLock("SR9",.T.)
                            SR9->R9_FILIAL	:= SRA->RA_FILIAL
                            SR9->R9_MAT		:= SRA->RA_MAT	
                            SR9->R9_DATA	:= SRA->RA_ADMISSA	
                            SR9->R9_CAMPO	:= aRecFields[nPos][2]
                            SR9->R9_DESC	:= AllTrim(SRA->&(aRecFields[nPos][2]))
                            SR9->(MSUnlock())
                        Endif

                        RecLock("SR9",.T.)
                        SR9->R9_FILIAL	:= SRA->RA_FILIAL
                        SR9->R9_MAT		:= SRA->RA_MAT
                        SR9->R9_DATA	:= dDataBase
                        SR9->R9_CAMPO	:= aRecFields[nPos][2]
                        SR9->R9_DESC	:= AllTrim(oModelTMP:GetValue(aFields[nX][3]))
                        SR9->(MSUnlock())

                        RecLock("SRA",.F.)
                        SRA->&(aRecFields[nPos][2])	:=	AllTrim(oModelTMP:GetValue(aFields[nX][3]))
                        SRA->(MSUnlock())
                        
                    Endif
                EndIf
            Next nX

            RecLock("RD0",.F.)
            RD0->RD0_NOME	:= SRA->RA_NOME
            RD0->(MSUnlock())

        EndIf
    EndIf

    RestArea(aAreaSR9)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
Method to validate the model before commit

@author raquel.andrade
@type Class
@since 05/07/2018
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, oModelId) Class RU07T09EVRUS
    Local oModelTMP As Object
    Local aFields As Array
    Local nX As Numeric

    aFields := {"NAME",;
                "MDNAME",;
                "SURNAME",;
                "FULLNME",;
                "SIGNME"}

    oModelTMP := oModel:GetModel("RU07T09_MOPER")

    For nX:=1 To Len(aFields)
        If !Empty(oModelTMP:GetValue(aFields[nX]))
            lRet := .T.
            Exit
        Else
            lRet := .F.
        Endif
    Next nX

    If !lRet
        Help('',1,'RU07T09NOACT',,STR0011,1) //"It is necessary to do at least one action!"
    Endif

Return lRet