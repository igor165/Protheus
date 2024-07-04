#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA014()
Cadastro de Dutos i-SIMP ANP
Adaptação da função TSMPA014
@author Itamar Oliveira
@since 23/12/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA014()

Private cString := "D32"

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

dbSelectArea("D32")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Dutos","DclValExcDuto()")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DclValExcDuto()
Valida a exclusao dos dutos 
Adaptação da função ValExcDuto
@author Itamar Oliveira
@since 16/02/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclValExcDuto()
Local lValida	:= .T. 
Local Area		:= GetArea()
Local cMens	:= ""

// Verifica se existe no relacao no cadastro de produtos padrao.
// Se existir a relacao nao deixa apagar.
DbSelectArea("DH4")
DH4->(DbSetOrder(3)) // Codigo i-SIMP do Duto
If DH4->(DbSeek(xFilial()+D32->D32_CODDUT))                                                           
	cMens:= "Esse registro nao pode ser excluido por estar relacionado com nota fiscal de entrada."
	Alert(cMens)
	lValida:=.F.
EndIf

RestArea(Area)
Return(lValida)