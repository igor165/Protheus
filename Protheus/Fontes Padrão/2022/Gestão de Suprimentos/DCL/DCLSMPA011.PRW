#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA011()
Cadastro das Operacoes SIMP
Adaptação da função TSMPA011
@author Itamar Oliveira
@since 19/01/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA011()
Local cNameTable := ""

Private cString := "D3C"

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

cNameTable := RetSQLName("D3C")
If ! Empty(cNameTable)
	TCSqlExec("DELETE FROM "+cNameTable+" WHERE D3C_DESCRI = 'Carga Fresca processada em unidades de destila‡ao prim ria                      '")
EndIf

dbSelectArea("D3C")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Operacoes SIMP","DclValExcOp()")

Return     

//-------------------------------------------------------------------
/*/{Protheus.doc} DclValExcOp()
Valida a exclusao das Operacoes SIMP 
@author Itamar Oliveira
@since 16/02/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclValExcOp()
Local lValida	:= .T.
Local aArea	:= GetArea()
Local cMens	:= ""

// Verifica se existe no relacao no cadastro de TES e TM.
// Se existir a relacao, nao deixa apagar.
DbSelectArea("SF4")
SF4->(DbSetOrder(4)) // Codigo i-SIMP do Produto //F4_FILIAL+F4_COPSIMP
If SF4->(DbSeek(xFilial() + D3C->D3C_CDOPSI))
	cMens:= "Esse registro nao pode ser excluido por estar relacionado com o TES de numero " + SF4->F4_CODIGO
	Alert(cMens)
	lValida := .F.
Else
	DbSelectArea("SF5")
	SF5->(DbSetOrder(3)) // Codigo i-SIMP do Produto //F5_FILIAL+F5_COPSIMP
	If DbSeek(xFilial() + D3C->D3C_CDOPSI)
		cMens:= "Esse registro nao pode ser excluido por estar relacionado com o Tipo de Movimentacao de numero " + SF5->F5_CODIGO
		Alert(cMens)
		lValida := .F.
	EndIf
EndIf

RestArea(aArea)
Return(lValida)
