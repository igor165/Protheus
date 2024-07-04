#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}  Fase4
Verifica se o pais do ambiente em uso (cPaisLoc), utiliza fontes da
Fase 4 (Angola, Argentina, Bolívia, Colombia, Haiti, México, Peru,
Portugal, Venezuela).

@author Rogerio Ribeiro da Cruz
@since 26/03/2010
@version 11.0
@return lRet Verdadeiro se o pais utilizar Fase 4, Falso se nao.
@sample cFields:= "R8_FILIAL, R8_MAT, "

if Fase4()
	cFields+= "R8_TIPOAFA"
Else
	cFields+= "R8_TIPO"
EndIf
/*/
//-------------------------------------------------------------------
Function Fase4()
	Local lRet:= (cPaisLoc $ "ANG/ARG/BOL/COL/HAI/MEX/PER/PTG/VEN")	//!"BRA/CHI/COS/DOM/EQU/EUA/PAN/PAR/POR/SAL/URU"
Return lRet
