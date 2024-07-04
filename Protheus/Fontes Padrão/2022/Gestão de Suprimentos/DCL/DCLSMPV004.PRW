#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV004()
Validacao para liberacao de alteracao do campo D3C_CDOPSI
Adaptação da função TSMPV004
@author Itamar Oliveira
@since 17/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV004()
Local lValida:=.T., Area:=GetArea()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return .F.
Endif

If ALTERA
	DbSelectArea("SF4") // TES
	DbSetOrder(4) // F4_FILIAL+F4_COPSIMP
	If DBSEEK(xFilial("SF4")+M->D3C_CDOPSI)
		lValida:=.F.
	Else
		DbSelectArea("SF5") // TM
		DbSetOrder(3) // F5_FILIAL+COPSIMP
		If DBSEEK(xFilial("SF5")+M->D3C_CDOPSI)
			lValida:=.F.
		EndIf
	EndIf
EndIf

RestArea(Area)
Return(lValida)