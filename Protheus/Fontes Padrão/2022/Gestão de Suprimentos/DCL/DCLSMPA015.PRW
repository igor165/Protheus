#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA015()
Cadastro de Embarcacoes i-SIMP ANP
Adaptação da função TSMPA015
@author Itamar Oliveira
@since 23/12/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA015()

Private cString := "D31"

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

dbSelectArea("D31")
dbSetOrder(1)
	
AxCadastro(cString,"Cadastro de Embarcações","Dcl15VlExc()")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Dcl15VlExc()
Valida a exclusao das embarcacoes
@author Itamar Oliveira
@since 16/02/2005
@version 1.0
@return lValida
/*/
//-------------------------------------------------------------------
Function Dcl15VlExc()
Local lValida:=.T., Area:=GetArea(), cMens:=""

	// Verifica se existe relacao na entrada de Notas Fiscais e Pedidos de Vendas.
	// Se existir a relacao nao deixa apagar.
	DbSelectArea("DH4")
	DH4->(DbSetOrder(4)) // Codigo i-SIMP da Embarcacao //DH4_FILIAL+DH4_CODEMB
	If DBSEEK(xFilial()+D31->D31_EMBCOD)
		cMens:= "Esse registro nao pode ser excluido por estar relacionado com nota fiscal de entrada."
		Alert(cMens)
		lValida:=.F.
	Else               
		DbSelectArea("SC5")
		SC5->(DbSetOrder(7)) // Codigo i-SIMP da Embarcacao
		If DBSEEK(xFilial()+D31->D31_EMBCOD)
			cMens:= "Esse registro nao pode ser excluido por estar relacionado com pedidos de vendas."
			Alert(cMens)
			lValida:=.F.
		EndIf
	EndIf

RestArea(Area)
Return(lValida)