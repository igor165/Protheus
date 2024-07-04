#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA016()
Cadastro de ARI's i-SIMP ANP
Adaptação da função TSMPA016
@author Itamar Oliveira
@since 18/02/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA016()

If FindFunction("DclValidCp") .AND. DclValidCp()

    Private cString := "D33"

    dbSelectArea("D33")
    dbSetOrder(1)
        
    AxCadastro(cString,"Cadastro de ARI's i-SIMP", "DclValExcARI()")

EndIf
	
Return
         
//-------------------------------------------------------------------
/*/{Protheus.doc} DclValExcARI()
Valida a exclusao dos ARI's
Adaptação da função TSMPA016
@author Itamar Oliveira
@since 18/02/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclValExcARI()
Local lValida	:= .T.
Local aArea		:= GetArea()
Local cMens	:= ""

	// Verifica se existe no relacao no cadastro de clientes e fornecedores padrao.
	// Se existir a relacao nao deixa apagar.
	DbSelectArea("AI0")
	AI0->(DbSetOrder(3)) // Codigo i-SIMP do ARI
	If AI0->(DbSeek(xFilial()+D33->D33_CDSIMP))     
		cMens:= "Esse registro nao pode ser excluido por estar relacionado com o cadastro de clientes."
		Alert(cMens)
		lValida:=.F.
	Else
		DbSelectArea("D30")
		D30->(DbSetOrder(8)) // Codigo i-SIMP do ARI //D30_FILIAL+D30_CODSIM
		If D30->(DbSeek(xFilial()+D33->D33_CDSIMP))
			cMens:= "Esse registro nao pode ser excluido por estar relacionado com o cadastro de fornecedores."
			Alert(cMens)
			lValida:=.F.
		EndIf
	EndIf

RestArea(aArea)
Return(lValida)