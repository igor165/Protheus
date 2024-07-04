#INCLUDE "TOTVS.CH"

Static oRaasInteg
Static lRaasInteg

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxRaasInt()
Verifica os artefatos necessarios para definir se a integração RAAS esta ativa

@type    function
@return  Lógico, Define se a integração esta ativa
@author  Rafael Tenorio da Costa
@since   08/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjxRaasInt()

    Local lTabelas  := .F.
    Local lCampos   := .F.
    Local lFontes   := .F.
    Local lBrasil   := .F.

    If ValType(lRaasInteg) == "U"

        lTabelas  := FwAliasInDic("MII") .And. FwAliasInDic("MIJ")
        lCampos   := SL1->( ColumnPos("L1_DESCFID") ) > 0 .And. SL1->( ColumnPos("L1_FIDCORE") ) > 0
        lFontes   := ExistFonte()
        lBrasil   := ( cPaisLoc == "BRA" )

        If lTabelas .And. lCampos .And. lFontes .And. lBrasil
            lRaasInteg := .T.
        Else
            lRaasInteg := .F.
            LjGrvLog( "LjxRaasInt", "Integração RAAS desativada, verifique os artefatos necessários.", {lTabelas, lCampos, lFontes, lBrasil} )
        EndIf
    EndIf

Return lRaasInteg

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxRaasNew()
Cria objeto de RAAS Integration

@type    function
@param   cCodEst, Caractere, Código da estação
@return  LjRAASIntegration, Objeto instanciado
@author  Rafael Tenorio da Costa
@since   08/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjxRaasNew(cCodEst)
    oRaasInteg := LjRAASIntegration():New("RAAS", cCodEst, /*cEnvironment*/)
Return oRaasInteg

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxRaasGet()
Retorna objeto de RAAS Integration da variavel static

@type    function
@param   cCodEst, Caractere, Código da estação
@return  LjRAASIntegration, Objeto da variavel static
@author  Rafael Tenorio da Costa
@since   08/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjxRaasGet(cCodEst)

    Default cCodEst := ""

    If oRaasInteg == Nil .And. !Empty(cCodEst)
        oRaasInteg := LjxRaasNew(cCodEst)
    EndIf

Return oRaasInteg

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistFonte()
Função estatica que verifica se os fontes existem no RPO

@type    function
@return  Lógico, Define se os fontes foram encontrados
@author  Rafael Tenorio da Costa
@since   08/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ExistFonte()

    Local lRetorno  := .T.
    Local aFontes   := {}
    Local nFonte    := 0

    Aadd(aFontes, "LjCfgInteg.prw"                  )
    Aadd(aFontes, "LjxRaasInt.prw"                  )
    Aadd(aFontes, "Lj7Fideliz.prw"                  )
    Aadd(aFontes, "LjAuthenticationFidelityCore.prw")
    Aadd(aFontes, "LjBonusFidelityCore.prw"         )
    Aadd(aFontes, "LjCampaignFidelityCore.prw"      )
    Aadd(aFontes, "LjCustomerFidelityCore.prw"      )
    Aadd(aFontes, "LjFidelityCore.prw"              )
    Aadd(aFontes, "LjFidelityCoreCommunication.prw" )
    Aadd(aFontes, "LjFidelityCoreInterface.prw"     )
    Aadd(aFontes, "LjSaleFidelityCore.prw"          )
    Aadd(aFontes, "LjAuthentication.prw"            )
    Aadd(aFontes, "LjIntegrationConfiguration.prw"  )
    Aadd(aFontes, "LjProductSettings.prw"           )
    Aadd(aFontes, "LjRAASIntegration.prw"           )
    Aadd(aFontes, "LjRac.prw"                       )
    Aadd(aFontes, "LjServicesSettings.prw"          )
    Aadd(aFontes, "LjCustomer.prw"                  )
    Aadd(aFontes, "LjPhone.prw"                     )
    Aadd(aFontes, "LjSale.prw"                      )
    Aadd(aFontes, "LjJsonIntegrity.prw"             )
    Aadd(aFontes, "LjMessageError.prw"              )
    Aadd(aFontes, "LjSmartPanels.prw"               )
    Aadd(aFontes, "STBRaas.prw"                     )

    For nFonte:=1 To Len(aFontes)

        If Len( GetApoInfo( aFontes[nFonte] ) ) == 0
            lRetorno := .F.
            Exit
        EndIf
    Next nFonte

Return lRetorno