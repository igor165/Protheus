#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} A140IGRV

Ponto de entrada respons�vel pela grava��o de itens personalizados (Regras Comerciais)

@type		function
@author 	Ectore Cecato - Totvs IP Jundia�
@since 		22/11/2018
@version 	Protheus 12 - Totvs Colabora��o

@see 		SCACOL02.PRW

/*/

User Function A140IGRV_PE()
	
	If ExistBlock("SCACOL02")
		ExecBlock("SCACOL02", .F., .F., ParamIXB)
	EndIf
	
Return Nil