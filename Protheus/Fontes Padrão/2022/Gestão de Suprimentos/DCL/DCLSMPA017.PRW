#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA017()
Cadastro de Instalacoes i-SIMP ANP
Adaptação da função TSMPA017
@author Itamar Oliveira
@since 18/02/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA017()
//Declaracao de Variaveis
Local cQuery
Local cNameTable := ""
Private cString := "D36"

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

cNameTable := RetSQLName("D36")

If ! Empty(cNameTable)
	cQuery := "DELETE"
	cQuery += " FROM " + cNameTable 
	cQuery += " WHERE R_E_C_N_O_"
	cQuery += " NOT IN(SELECT MIN(R_E_C_N_O_)"
	cQuery += " FROM " + cNameTable 
	cQuery += " GROUP BY D36_FILIAL, D36_CDINST)"
	
	TcSqlExec(cQuery)
EndIf

dbSelectArea(cString)
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Instalacoes i-SIMP", "Dcl17VlExc()")
Return
         
//-------------------------------------------------------------------
/*/{Protheus.doc} Dcl17VlExc()
Valida a exclusao das Instalcoes
@author Itamar Oliveira
@since 18/02/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function Dcl17VlExc()
Local lValida		:= .T.
Local aArea 		:= GetArea()
Local aAreaAI0	:= AI0->(GetArea())
Local aAreaD30	:= D30->(GetArea())
Local cMens		:= ""

	// Verifica se existe no relacao no cadastro de clientes e fornecedores DCL.
	// Se existir a relacao nao deixa apagar.
	DbSelectArea("AI0")
	DbSetOrder(2) // AI0_FILIAL+AI0_CODINS
	If DBSEEK(xFilial("AI0")+D36->D36_CDINST)
		cMens := "Esse registro nao pode ser excluido por estar relacionado com o cadastro de clientes."
		Alert(cMens)
		lValida := .F.
	Else
		DbSelectArea("D30")
		D30->(DbSetOrder(9)) // D30_FILIAL+D30_INSTSI
		If DBSEEK(xFilial("D30")+D36->D36_CDINST)
			cMens := "Esse registro nao pode ser excluido por estar relacionado com o cadastro de Complemento de Fornecedores DCL."
			Alert(cMens)
			lValida := .F.
		EndIf
	EndIf

RestArea(aArea)
RestArea(aAreaAI0)
RestArea(aAreaD30)

Return(lValida)