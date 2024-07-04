#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA010()
Cadastro das Caract. Fis-Quimi do Produto
Adaptação da função TSMPA010
@author Itamar Oliveira
@since 22/12/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA010()
//Declaracao de Variaveis
Local cQuery
Local cNameTable := ""

Private cString	:= "DHD"
Private cCadastro	:= "Cadastro de Caract. Fis-Quim."

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

cNameTable := RetSQLName("DHD")

If ! Empty(cNameTable)
	cQuery := "DELETE"
	cQuery += " FROM " + cNameTable 
	cQuery += " WHERE R_E_C_N_O_"
	cQuery += " NOT IN(SELECT MIN(R_E_C_N_O_)"
	cQuery += " FROM " + cNameTable 
	cQuery += " GROUP BY DHD_FILIAL, DHD_CODIGO)"
	
	TcSqlExec(cQuery)
EndIf

dbSelectArea("DHD")
DHD->(dbSetOrder(1))

AxCadastro(cString,cCadastro,"DclValExcC()")
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DclValExcC()
Valida a exclusao das caracteristicas fis-quim. do produto 
@author Itamar Oliveira
@since 17/02/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclValExcC()
Local lValida	:= .T.
Local aArea	:= GetArea()
Local cMens	:= ""

// Verifica se existe relacao no cadastro de clientes e fornecedores
// Se existir a relacao nao deixa apagar.
DbSelectArea("DHE")
DHE->(DbSetOrder(2)) // Codigo do Laudo de Qualidade
If DHE->(DbSeek(xFilial()+DHD->DHD_CODIGO)) //DHE_FILIAL+DHE_CODCAR
	cMens := "Esse registro nao pode ser excluido por estar relacionado com laudos de qualidade."
	Alert(cMens)
	lValida := .F.
EndIf

RestArea(aArea)

Return(lValida)