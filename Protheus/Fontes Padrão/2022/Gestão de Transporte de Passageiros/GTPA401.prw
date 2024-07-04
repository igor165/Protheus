#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GTPA401
Função paleativa para chamada do cadastro de veículos dentro do gtp
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
        ATENÇÃO!!!!!!
        Função criada para chamar o cadastro de veículos enquanto não for avaliado 
        junto com a NG a possibilidade de permitir a utilização do cadastro no sigagtp
        Avaliar com o modulo do MNT para adicionar o modulo 88 na validação.
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
    //    cErro := 'Rotina apenas disponível para utilização paleativa para cadastro de veículos'
    //    cSolution := "Versões anteriores da 12.1.033 deverão utilizar a rotina de veículos (MNTA084)"
    //    Help( " ",1,"NAO CONFORMIDADE",,cErro + CRLF + cSolution,3,1 )
    //EndIf
Return 
