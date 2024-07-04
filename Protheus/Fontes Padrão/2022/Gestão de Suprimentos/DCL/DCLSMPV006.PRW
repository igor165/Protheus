#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV006()
Validacao para liberacao de alteracao do campo D31_EMBCOD Tabela de Embarcaçoes
Adaptação da função TSMPV006
@author Itamar Oliveira
@since 18/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV006()
Local lValida:=.T., Area:=GetArea()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return .F.
Endif

If ALTERA
	DbSelectArea("DH4") // NFE
	DbSetOrder(4) // DH4_FILIAL+DH4_CODEMB
	If DBSEEK(xFilial("DH4")+M->D31_EMBCOD)
		lValida:=.F.
	Else
		DbSelectArea("SC5") // NFE
		DbSetOrder(8) // C5_FILIAL+C5_CODEMB
		If DBSEEK(xFilial("SC5")+M->D31_EMBCOD)
			lValida:=.F.
		EndIf
	EndIf
EndIf

RestArea(Area)
Return(lValida)