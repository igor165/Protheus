#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV003()
Validacao para liberacao de alteracao do campo DHH_CODIGO
Adaptação da função TSMPV003
@author Itamar Oliveira
@since 17/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV003()
Local lValida		:= .T.
Local aAreaDH5	:= DH5->(GetArea())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If ALTERA    
	DbSelectArea("DH5")
	DH5->(DbSetOrder(2)) // DH5_FILIAL+DH5_CODSIM+DH5_COD
	If DH5->(DbSeek(xFilial("DH5") + M->DHH_CODIGO)) .And. !(Empty(DH5->DH5_COD))
		lValida := .F.
	EndIf
EndIf

RestArea(aAreaDH5)
Return(lValida)