#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GTPA401
Fun��o paleativa para chamada do cadastro de ve�culos dentro do gtp
@type  Function
@author user
@since 11/01/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA401()
    Local oBrowse
    //Filtro Browse
	Local cFiltro	:= "ST9->T9_CATBEM $ '24'"
    //Local cErro     := ""
    //Local cSolution := ""
    
    /*
        ATEN��O!!!!!!
        Fun��o criada para chamar o cadastro de ve�culos enquanto n�o for avaliado 
        junto com a NG a possibilidade de permitir a utiliza��o do cadastro no sigagtp
        Avaliar com o modulo do MNT para adicionar o modulo 88 na valida��o.
    */
    //If( GetRPORelease() >= '12.1.033')
        //Initializes Browse
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("ST9")
        oBrowse:SetDescription( "Cadastro de Veiculos" )
        oBrowse:SetFilterDefault( cFiltro )
        oBrowse:SetMenuDef("MNTA084")
        StaticCall(MNTA080,fAddLegend,oBrowse)
        oBrowse:Activate()
    //Else
    //    cErro := 'Rotina apenas dispon�vel para utiliza��o paleativa para cadastro de ve�culos'
    //    cSolution := "Vers�es anteriores da 12.1.033 dever�o utilizar a rotina de ve�culos (MNTA084)"
    //    Help( " ",1,"NAO CONFORMIDADE",,cErro + CRLF + cSolution,3,1 )
    //EndIf
Return 
