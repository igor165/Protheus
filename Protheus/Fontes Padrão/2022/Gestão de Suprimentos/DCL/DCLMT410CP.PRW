#INCLUDE "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} A2460GrEst
Gera movimento provisório quando o parâmetro MV_ESTZERO está ativo e TES que atualiza estoque
@return   Nil

@author   José Eulálio
@since    08.02.2017
@version  P12
/*/
//-------------------------------------------------------------------

Function DCLMT410CP()
Local cCmpUsr   := SuperGetMV("MV_CMPUSR",,"C5_MENNOTA")

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If SuperGetMV("MV_DCLNEW",.F.,.F.)
	//-- Validar conteudo parametro MV_CMPUSR
	If (Empty(cCmpUsr) .Or. SC5->(FieldPos(cCmpUsr)) == 0)
		cCmpUsr := "C5_MENNOTA"
	EndIf
	//-- Limpar campos copiados
	If SC5->(FieldPos("C5_SLENVT")) > 0
		M->C5_T_ENVT := ""
	EndIf
	&(cCmpUsr) := ""
EndIf

Return Nil