#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA440.CH'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA440
	Constrói o browse para as operações relacionadas com a gestão da disciplina

@sample		TECA440(Nil)

@since		12/02/2014
@version 	P12

@param		cFilDef, Caracter, filtro padrão a ser inserido na exibição do browse

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA440(cFilDef)

GPEA643(cFilDef)

Return
