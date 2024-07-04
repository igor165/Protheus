#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV002()
Validacao para liberacao dos campos DH4_CODEMB
Adaptação da função TSMPV002
@author Itamar Oliveira
@since 17/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV002()
Local lRet		:= .T. // variável de retorno
Local oModel	:= FwModelActive()
Local oModDH4 := oModel:GetModel("DH4DETAIL")
Local cCod		:= oModDH4:GetValue("DH4_MODANP")

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If cCod <> "04"
	lRet := .F.
EndIf
 
Return lRet