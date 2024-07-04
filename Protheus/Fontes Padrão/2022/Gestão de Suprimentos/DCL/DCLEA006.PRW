#INCLUDE "rwmake.ch"  

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA001
Cadastro de Arqueacao de Tanques    
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA006()  

	If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
		Return
	EndIf

	AxCadastro("DHG","Arqueacao Tanques",".T.",".T.")

Return(nil)   



