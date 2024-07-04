#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV008()
Validacao para liberacao de alteracao do campo DHD_CODIGO Tabela de Carac. Fis-Quim
Adaptação da função TSMPV008
@author Itamar Oliveira
@since 18/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV008()
Local lValida	:= .T.
Local aArea	:= DHD->(GetArea())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If ALTERA
	DbSelectArea("DHE") // Laudos de Qualidade
	DHE->(DbSetOrder(2)) // DHE_FILIAL+DHE_CODCAR
	If DHE->(DbSeek(xFilial("DHE") + DHD->DHD_CODIGO))
		lValida := .F.
	EndIf
EndIf

RestArea(aArea)
Return lValida