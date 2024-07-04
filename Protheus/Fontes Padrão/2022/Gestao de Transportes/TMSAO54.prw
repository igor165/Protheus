#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FATA900.CH"

/*/{Protheus.doc} TMSAO54
	Chama DashBoards do Faturamento
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function TMSAO54()

If FindFunction("FATA900") 
	If !( TableIndic("A1N") .and. TableIndic("A1O") .and. TableIndic("A1P") .and. TableIndic("A1Q") .and. TableIndic("A1R") )
		HELP(" ",1, STR0001 ,, STR0002 ,2,0,,,,,,{ STR0003 }) // "DASHBOARD - Ambiente para acesso" # "Dicionário de Dados Desatualizado" # "Favor procurar o Administrador do Sistema."
		Return .F.
	Else
		TMSLoadDados()
		FATA900()
	Endif
EndIf

Return 