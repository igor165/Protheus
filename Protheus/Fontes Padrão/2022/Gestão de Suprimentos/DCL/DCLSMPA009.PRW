#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA009()
Cadastro de Produtos i-SIMP ANP
Adaptação da função TSMPA009
@author Itamar Oliveira
@since 22/12/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA009()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cString := "DHH"

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

dbSelectArea("DHH")
dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Produtos i-SIMP", "DclValExcProd()")

Return
         
//-------------------------------------------------------------------
/*/{Protheus.doc} DclValExcProd()
Valida a exclusao dos produtos
@author Itamar Oliveira
@since 16/02/2005
@version 1.0
@return lValida
/*/
//-------------------------------------------------------------------
Function DclValExcProd()
Local lValida	:= .T.
Local aArea	:= GetArea()
Local aAreaSB1:= SB1->(GetArea())
Local cMens	:= ""

// Verifica se existe no relacao no cadastro de produtos padrao.
// Se existir a relacao nao deixa apagar.
DbSelectArea("DH5")
DH5->(DbSetOrder(2)) // DH5_FILIAL+DH5_CODSIM
If DH5->(DbSeek(xFilial("DH5")+DHH->DHH_CODIGO))
	  
	cMens	:= "Esse registro nao pode ser excluido por estar relacionado com o produto "
	cMens	+= AllTrim(DH5->DH5_COD) + "-" + AllTrim(Posicione("SB1",1,xFilial("SB1") + DH5->DH5_COD,SB1->B1_DESC)) + " no cadastro de produtos padrao. "
	Alert(cMens)
	lValida := .F.
EndIf

RestArea(aArea)
RestArea(aAreaSB1)

Return(lValida)
