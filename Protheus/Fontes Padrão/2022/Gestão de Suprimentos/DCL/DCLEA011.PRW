#INCLUDE "rwmake.ch" 

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA011
Cadastro temperaturas/densidades para conversao a 20 graus        

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Function DCLEA011()  

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

AxCadastro("DHC","Temperaturas/Densidades Fator correcao",".T.",".T.")

Return(nil)

