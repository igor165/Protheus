#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPV007()
Validacao para liberacao de alteracao do campo DHH_CODIGO  Tabela de Municipios
Adaptação da função TSMPV007
@author Itamar Oliveira
@since 18/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPV007()
Local lValida:=.T., Area:=GetArea()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return .F.
Endif

If ALTERA
	DbSelectArea("AI0") // Clientes
	DbSetOrder(6) // AI0_FILIAL+AI0_MUNSI
	If DBSEEK(xFilial("AI0")+M->CC2_CODANP)
		lValida:=.F.
	Else
		DbSelectArea("D30") // Fornecedores
		DbSetOrder(5) // D30_FILIAL+D30_CODFOR+D30_LOJFOR+D30_MUNSIM
		If DBSEEK(xFilial("D30")+M->D30_CODFOR+M->D30_LOJFOR+M->CC2_CODANP)
			lValida:=.F.
		EndIf
	EndIf
EndIf

RestArea(Area)
Return(lValida)