#INCLUDE "rwmake.ch" 

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA001
Cadastro de Dados para faturamento cessionarias  
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA008()  

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

AxCadastro("D35","Dados Fat Cessionarias",".T.",".T.")

Return(nil)

