#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"


/*/{Protheus.doc} function fAuthMyRH
Função utilizada para validar autenticação e Permissionamento do Consignado com o Meu RH
@author  Hugo de Oliveira
@since   09/11/2020
@version 1.0
/*/
Function fAuthMyRH(cToken)
	Local cMatSRA	 := ""
	Local cLogin	 := ""
	Local cRD0Cod	 := ""
	Local cBranch	 := ""
	Local lDemit     := .F.
	Local lHabil     := .T.
	Local aDataLogin := {}

	DEFAULT cToken := ""

	If !Empty(cToken)
		// Retorna os dados de Login a partir do usuario gravado no Token
		aDataLogin 	:= GetDataLogin(cToken, .T.)
		
		If Len(aDataLogin) > 0
			cMatSRA    := aDataLogin[1]
			cLogin     := aDataLogin[2]  // Tab. RD0
			cRD0Cod    := aDataLogin[3]
			cBranch    := aDataLogin[5]
			lDemit     := aDataLogin[6]

			//Valida permissionamento do consignado no MeuRH
			fPermission(cBranch, cLogin, cRD0Cod, "payrollLoan", @lHabil)

			If !lHabil .OR. lDemit
				aDataLogin := {}
			EndIf
		EndIf
	EndIf

Return aDataLogin
