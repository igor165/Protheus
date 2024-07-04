#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} A140IPRD

Ponto de entrada para determinar qual o produto deverá ser utilizado na entrada 

@type		function
@author 	Ectore Cecato - Totvs IP Jundiaí
@since 		22/11/2018
@version 	Protheus 12 - Totvs Colaboração

@return 	caracter, Código do produto

@see 		SCACOL01.PRW

/*/

User Function A140IPRD()
	
	Local cProd := ""
	
	If ExistBlock("SCACOL01")
		cProd := ExecBlock("SCACOL01", .F., .F., ParamIXB)
	EndIf
	
Return cProd