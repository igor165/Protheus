#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV005()
Validacao para liberacao de alteracao do campo D32_CODDUT
Adaptação da função TSMPV005
@author Itamar Oliveira
@since 17/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV005()
Local lValida:=.T., Area:=GetArea()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return .F.
Endif

If ALTERA
	DbSelectArea("DH4") // NFE
	DbSetOrder(3) // DH4_FILIAL+DH4_DUTO
	If DBSEEK(xFilial("DH4")+M->D32_CODDUT)
		lValida:=.F.
	EndIf
EndIf

RestArea(Area)
Return(lValida)