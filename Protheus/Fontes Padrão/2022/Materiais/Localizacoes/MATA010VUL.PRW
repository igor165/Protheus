#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'MATA010BOL.CH'

/*/{Protheus.doc} MATA010VUL
Clase responsable por los eventos para vulcan.

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		18/02/2022
/*/
Class MATA010VUL From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method BeforeTTS()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		18/02/2022
/*/
Method New() Class MATA010VUL
	
Return Nil	


/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		18/02/2022
/*/
Method BeforeTTS(oModel, cModelId) Class MATA010VUL
Local nOperation    := oModel:GetOperation()
Local oModelSB1     := oModel:GetModel('SB1MASTER')
Local cToken        := ""
Local lRet          := .T.
Local cCodUM        := ""
Local cMsg          := ""
Local aError        := {}
Local lEdit         := nOperation == MODEL_OPERATION_UPDATE
Local cActEcon      := ""

    If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
        If (SB1->(ColumnPos("B1_PRODACT")) > 0) .and. (SuperGetmv("MV_CFDUSO", , "") <> "0") .and. ("VULCAN" $ SuperGetMV("MV_PROVFE", , "")) .and. oModelSB1:GetValue("B1_PRODACT") <> "2"
            If lEdit .and. !(oModelSB1:GetValue("B1_PRODACT") $ "1")
                Return Nil
            EndIf
            If Empty(oModelSB1:GetValue("B1_PRODSAT"))
                cMsg += STR0002 + "B1_PRODSAT" + STR0003 + chr(10) + chr(13)
                lRet := .F.
            EndIf
            cCodUM := GetAdvFVal("SAH", "AH_COD_CO", xFilial("SAH") + oModelSB1:GetValue("B1_UM"), 1, "")
            If Empty(cCodUM)
                cMsg += STR0002 + "AH_COD_CO" + STR0004 + oModelSB1:GetValue("B1_UM") + chr(10) + chr(13)
                lRet := .F.
            EndIf
            If (SB1->(ColumnPos("B1_ACTECON")) > 0) .and. !Empty(oModelSB1:GetValue("B1_ACTECON"))
                cActEcon := oModelSB1:GetValue("B1_ACTECON")
            EndIf
            If lRet
                cToken	:= VulcanTkn()
                If VulcanProd(cToken, @aError, oModelSB1:GetValue("B1_FILIAL"), oModelSB1:GetValue("B1_COD"), oModelSB1:GetValue("B1_DESC"), cCodUM, oModelSB1:GetValue("B1_PRODSAT"), 0, lEdit, cActEcon)
                        oModelSB1:SetValue("B1_PRODACT","2")
                        If !IsBlind()
                            MsgAlert(Iif(lEdit,STR0009,STR0008))
                        EndIf
                Else
                    oModelSB1:SetValue("B1_PRODACT",IIf(lEdit,"1","0"))
                    If Len(aError) > 0
                        Help(NIL, NIL, Iif(lEdit,STR0010,STR0005), NIL, aError[1][4], 1, 0, NIL, NIL, NIL, NIL, NIL, {})
                    EndIf
                EndIf
            EndIf
            If !Empty(cMsg)
                oModelSB1:SetValue("B1_PRODACT",IIf(lEdit,"1","0"))
                Help(NIL, NIL, Iif(lEdit,STR0010,STR0005), NIL, cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006,STR0001})
            EndIf
        EndIf
    EndIf

Return Nil
