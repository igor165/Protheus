#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV001()
Validacao para liberacao dos campos D1_DUTO e D1_T_SERVI
Adaptação da função TSMPV001
@author Itamar Oliveira
@since 04/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV001()
Local lRet		:= .T. // variável de retorno
Local oModel	:= FwModelActive()
Local oModDH4 := oModel:GetModel("DH4DETAIL")
Local cCod		:= oModDH4:GetValue("DH4_MODANP")

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return .F. 
Endif

If cCod <> "05"
	lRet := .F.
EndIf
 
Return lRet

