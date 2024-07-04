#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TMSGroupOfRegionstAdapter
Adapter do resource Group of Regions

Verbos disponíveis: POST, GET, PUT, DELETE
@author Izac Silvério Ciszevski
/*/

CLASS TMSGroupOfRegionstAdapter FROM BaseResourceAdapter

    METHOD New()

    METHOD FieldMap()
    METHOD SendObject()
    // METHOD ReceiveObject()
    // METHOD CreateQuery()
    // METHOD GetAction()
    METHOD PostAction()
    METHOD PutAction()
    METHOD DeleteAction()

EndClass

Method New( oRestObj ) CLASS TMSGroupOfRegionstAdapter
    Self := _Super:New( oRestObj )
    ::SetMainAlias( "DUY" )

Return Self

Method FieldMap() CLASS TMSGroupOfRegionstAdapter
    Local aFieldMap as Array

    aFieldMap := { ;
                    { "branchId"                   , "DUY_FILIAL" } ,;
                    { "code"                       , "DUY_GRPVEN" } ,;
                    { "description"                , "DUY_DESCRI" } ,;
                    { "topGroup"                   , "DUY_GRPSUP" } ,;
                    { "destinationBranch"          , "DUY_FILDES" } ,;
                    { "associatedCompanyRegionCode", "DUY_CDRCOL" } ,;
                    { "regionCategory"             , "DUY_CATREG" } ,;
                    { "baseTaxRegion"              , "DUY_CDRTAX" } ,;
                    { "groupCategory"              , "DUY_CATGRP" } ,;
                    { "regionExemptTaxes"          , "DUY_REGISE" } ,;
                    { "ISSRate"                    , "DUY_ALQISS" } ,;
                    { "state.stateCode"            , "DUY_EST"    } , ;
                    { "state.stateInternalId"      , "DUY_EST"    } , ;
                    { "country.countryCode"        , "DUY_PAIS"   } , ;
                    { "country.countryInternalId"  , "DUY_PAIS"   } , ;
                    { "city.cityCode"              , "DUY_CODMUN" } , ;
                    { "city.cityInternalId"        , "DUY_CODMUN" } , ;
                    { "TMSPortal"                  , "DUY_FILDES" } ;
                }

Return aFieldMap


Method SendObject() CLASS TMSGroupOfRegionstAdapter

    Local aObj := { ;
                    { "companyId"        , { |cAlias, xValue| cEmpAnt                                 } } ,;
                    { "branchId"         , { |cAlias, xValue| cFilAnt                                 } } ,;
                    { "companyInternalId", { |cAlias, xValue| cEmpAnt + cFilAnt                       } } ,;
                    { "internalId"       , { |cAlias, xValue| ( cAlias )->( DUY_FILIAL + DUY_GRPVEN ) } } ,;
                    { "code" } ,;
                    { "description" } ,;
                    { "topGroup" } ,;
                    { "destinationBranch" } ,;
                    { "associatedCompanyRegionCode" } ,;
                    { "associatedCompanyRegion", { |cAlias, xValue| RetDesc(cAlias) } } ,;
                    { "regionCategory" } ,;
                    { "baseTaxRegion" } ,;
                    { "groupCategory" } ,;
                    { "regionExemptTaxes" } ,;
                    { "ISSRate" } ,;
                    { "state", {;
                                    { "stateCode"       } , ;
                                    { "stateInternalId" } , ;
                                    { "stateDescription", { |cAlias, xValue|  If(!Empty((cAlias)->DUY_EST), FWGetSX5( "12", PadR( (cAlias)->DUY_EST, 6) )[1][4], "")} };
                                  } } ,;
                    { "country", {;
                                    { "countryCode" } , ;
                                    { "countryInternalId" } , ;
                                    { "countryDescription", { |cAlias, xValue| Posicione("SYA", 1, xFilial("DUY") + (cAlias)->DUY_PAIS,"YA_DESCR") } };
                                  } } ,;
                    { "city", {;
                                    { "cityCode" } , ;
                                    { "cityInternalId" } , ;
                                    { "cityDescription", { |cAlias, xValue| Posicione('CC2', 1, xFilial("DUY")+ (cAlias)->( DUY_EST + DUY_CODMUN) ,"CC2_MUN") } };
                                  } } ,;
                    { "TMSPortal" } ;
                }

Return aObj

Static Function RetDesc( cAlias )
    aArea := DUY->( GetArea( ) )
    cDesc := Posicione("DUY", 1, xFilial("DUY") + (cAlias)->DUY_CDRCOL,"DUY_DESCRI")
    RestArea( aArea )
Return cDesc

/*
Method ReceiveObject() CLASS TMSGroupOfRegionstAdapter

    Local aObj := { ;
                    { "DUY_FILIAL", { |oObject, xValue| ConOut( xValue ) } } ,;
                    { "DUY_GRPVEN" } ,;
                    { "DUY_DESCRI" } ,;
                    { "DUY_GRPSUP" } ,;
                    { "DUY_FILDES" } ,;
                    { "DUY_CDRCOL" } ,;
                    { "DUY_CATREG" } ,;
                    { "DUY_CDRTAX" } ,;
                    { "DUY_CATGRP" } ,;
                    { "DUY_REGISE" } ,;
                    { "DUY_ALQISS" } ,;
                    { "DUY_FILDES" } ;
                }

Return aObj

Method CreateQuery( aFields, cWhere, cOrder ) CLASS TMSGroupOfRegionstAdapter

    Local cQuery  := ""
    Local cFields := ""
    Local cAlias  := ::cMainAlias
    Local nX

    for nX := 1 To len( aFields )
        cFields += aFields[nX][2]
        cFields += ", "
    next nX

    cFields += cAlias+".R_E_C_N_O_ nRecno"

    cQuery += " SELECT " + cFields
    cQuery += " FROM " + RetSqlName( cAlias ) + " " + cAlias
    cQuery += " WHERE " + cWhere
    cQuery += "     AND " + cAlias + ".D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY " + cOrder

Return cQuery
*/

Method DeleteAction( nRecno ) CLASS TMSGroupOfRegionstAdapter
    Local aError  := {}
    Local aCampos := {}

    DUY->( DbGoTo( nRecno ) )

    If !( lOk := ManutReg( MODEL_OPERATION_DELETE, aCampos, @aError ) )
        // SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails )
        ::SetError( aError[5], , aError[6])
    EndIf

Return lOk

Method PutAction( nRecno, aCampos ) CLASS TMSGroupOfRegionstAdapter
    Local aError  := {}

    DUY->( DbGoTo( nRecno ) )

    If !( lOk := ManutReg( MODEL_OPERATION_UPDATE, aCampos, @aError ) )
        // SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails )
        ::SetError( aError[5], , aError[6])
    EndIf

Return lOk

Method PostAction( aCampos ) CLASS TMSGroupOfRegionstAdapter
    Local aError  := {}

    If !( lOk := ManutReg( MODEL_OPERATION_INSERT, aCampos, @aError ) )
        // SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails )
        ::SetError( aError[5], , aError[6])
    Else
        //-- Adicionar o filtro da região criada para retornar
        ::AddFilter( "code", DUY->DUY_GRPVEN )
    EndIf

Return lOk

Static Function ManutReg( nOperation, aCampos, aError )
    Local lOK     := .T.
    Local nCampo  := 1
    Local oModel, oModelFields
    Local aError  := {}
    Local cFonte  := "TMSA115"
    Local cModelo := "MdFieldDUY"

    Local oModelAnt := FwModelActive()

    Default aCampos  := {}
    Default cRetorno := ""

    BEGIN SEQUENCE

        oModel := FWLoadModel( cFonte )
        oModel:SetOperation( nOperation )
        oModel:Activate()

        If nOperation != MODEL_OPERATION_DELETE
            lOk := .F.
            oModelFields := oModel:GetModel( cModelo )
            For nCampo := 1 To Len( aCampos )
                If oModelFields:CanSetValue( aCampos[nCampo][1] )
                    If ! ( lOK := oModelFields:SetValue( aCampos[nCampo][1], aCampos[nCampo][2] ) )
                        Exit
                    EndIf
                EndIf
            Next
        EndIf

        If !( lOK .and. ( lOk := oModel:VldData() .and. oModel:CommitData() ) )
            aError := oModel:GetErrorMessage()
            cRetorno := aError[5] + " | " + aError[6] + " | " + aError[7]
        EndIf

        oModel:Destroy()
    RECOVER
        cRetorno := "MVC - Falha não identificada"
            lOK:= .F.
    END SEQUENCE

    If ValType( oModelAnt ) == "O"
        FwModelActive( oModelAnt )
    EndIf

Return lOK