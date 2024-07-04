#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TMSRequestersAdapter
Adapter do resource Requesters

Verbos disponíveis: POST, GET, PUT, DELETE
@author Izac Silvério Ciszevski
/*/

CLASS TMSRequestersAdapter FROM BaseResourceAdapter

    METHOD New()
    METHOD SendObject()
    METHOD ReceiveObject()

    METHOD FieldMap()
    METHOD PostAction()
    METHOD PutAction()
    METHOD DeleteAction()

EndClass

Method New( oRestObj ) CLASS TMSRequestersAdapter
    Self := _Super:New( oRestObj )
    ::SetMainAlias( "DUE" )

Return Self

Method FieldMap() CLASS TMSRequestersAdapter
    Local aMap     := {}

    aMap := {;
                { "branchId"                             , "DUE_FILIAL" } , ;
                { "code"                                 , "DUE_CODSOL" } , ;
                { "CustomerCode"                         , "DUE_CODCLI" } , ;
                { "CustomerStoreId"                      , "DUE_LOJCLI" } , ;
                { "Name"                                 , "DUE_NOME"   } , ;
                { "shortName"                            , "DUE_NREDUZ" } , ;
                { "Address.Address"                      , "DUE_END"    } , ;
                { "Address.city.cityDescription"         , "DUE_MUN"    } , ;
                { "Address.city.cityCode"                , "DUE_CODMUN" } , ;
                { "Address.state.stateCode"              , "DUE_EST"    } , ;
                { "Address.state.stateCodeInternalId"    , "DUE_EST"    } , ;
                { "Address.district"                     , "DUE_BAIRRO" } , ;
                { "Address.ZipCode"                      , "DUE_CEP"    } , ;
                { "Address.PointofReference"             , "DUE_PONREF" } , ;
                { "ContactInfo.ContactInformationName"   , "DUE_CONTAT" } , ;
                { "CommunicationInfo.PhoneNumber"        , "DUE_TEL"    } , ;
                { "CommunicationInfo.EMail"              , "DUE_EMAIL"  } , ;
                { "CommunicationInfo.DiallingCode"       , "DUE_DDD"    } , ;
                { "pickupInfo.TransportTypeCode"         , "DUE_TIPTRA" } , ;
                { "pickupInfo.PickupType"                , "DUE_TIPCOL" } , ;
                { "pickupInfo.pickupDays.Monday"         , "DUE_COLSEG" } , ;
                { "pickupInfo.pickupDays.Tuesday"        , "DUE_COLTER" } , ;
                { "pickupInfo.pickupDays.Wednesday"      , "DUE_COLQUA" } , ;
                { "pickupInfo.pickupDays.Thursday"       , "DUE_COLQUI" } , ;
                { "pickupInfo.pickupDays.Friday"         , "DUE_COLSEX" } , ;
                { "pickupInfo.pickupDays.Saturday"       , "DUE_COLSAB" } , ;
                { "pickupInfo.pickupDays.Sunday"         , "DUE_COLDOM" } , ;
                { "pickupInfo.PickupStart"               , "DUE_HORCOI" } , ;
                { "pickupInfo.PickupEnds"                , "DUE_HORCOF" } , ;
                { "regionGroupCode"                      , "DUE_CDRSOL" } ;
            }


Return aMap

/**
 * Define o objeto que será enviado como resposta, no seguinte formato:
   array := { {"propriedade", {|cAlias, xValue | bloco } } }
   Permite definir blocos de código para o preenchimento de propriedades.
   Caso não informe o valor/bloco, será retornado o valor do campo relacionado se houver mapeamento.

   IMPORTANTE: Esse método pode ser omitido. Caso não seja declarado, será utilizado o mapeamento para definir os campos.
 */
Method SendObject() CLASS TMSRequestersAdapter

    Local aObj := { ;
                    { "companyId"        , { |cAlias, xValue| cEmpAnt                                 } } , ;
                    { "branchId"         , { |cAlias, xValue| XFilial("DUE")                          } } , ;
                    { "companyInternalId", { |cAlias, xValue| cEmpAnt + cFilAnt                       } } , ;
                    { "internalId"       , { |cAlias, xValue| ( cAlias )->( DUE_FILIAL + DUE_CODSOL ) } } , ;
                    { "code" } , ;
                    { "CustomerCode" } , ;
                    { "CustomerStoreID" } , ;
                    { "Name" } , ;
                    { "shortName" } , ;
                    { "regionGroupCode" } , ;
                    { "regionGroup" , { |cAlias| Posicione("DUY", 1, xFilial("DUY") + (cAlias)->DUE_CDRSOL,"DUY_DESCRI") } } , ;
                    { "GovernmentalInformation", { |cAlias| RetGovInfo(cAlias)} } , ;
                    { "address", {;
                                    { "address", {|cAlias| trataEnd((cAlias)->DUE_END, "L") } } , ;
                                    { "number",  {|cAlias| trataEnd((cAlias)->DUE_END, "N") } } , ;
                                    { "complement" } , ;
                                    { "district" } , ;
                                    { "zipCode" } , ;
                                    { "region" } , ;
                                    { "poBox" } , ;
                                    { "mainAddress" , { | | .T. }} , ;
                                    { "shippingAddress" } , ;
                                    { "billingAddress" } , ;
                                    { "state", {;
                                                    { "stateCode"       } , ;
                                                    { "stateInternalId" } , ;
                                                    { "stateDescription", { |cAlias, xValue| If(!Empty((cAlias)->DUE_EST), FWGetSX5( "12", PadR( (cAlias)->DUE_EST, 6) )[1][4], "")} };
                                                } } ,;
                                    { "country", { |cAlias| RetCountryInfo(cAlias)}  },;
                                    { "city", {;
                                                    { "cityCode" } , ;
                                                    { "cityInternalId" } , ;
                                                    { "cityDescription"} ;
                                                } } ;
                                  } } , ;
                    { "contactInfo", { ;
                                        { "ContactInformationName"} ;
                                    } } , ;
                    { "CommunicationInfo", { ;
                                        { "PhoneNumber"} , ;
                                        { "EMail"} , ;
                                        { "DiallingCode"}  ;
                                     } } , ;
                    {"pickUpInfo", {;
                                        { "TransportTypeCode"} , ;
                                        { "TransportType", {|| Left(TMSValField("DUE->DUE_TIPTRA",.F.), 15)} } , ;
                                        { "PickupType"} , ;
                                        { "PickupStart"} , ;
                                        { "PickupEnds"} , ;
                                        { "pickupDays", {;
                                                            { "Monday"   , { | oObject, xValue, Field | xValue == "1" } } , ;
                                                            { "Tuesday"  , { | oObject, xValue, Field | xValue == "1" } } , ;
                                                            { "Wednesday", { | oObject, xValue, Field | xValue == "1" } } , ;
                                                            { "Thursday" , { | oObject, xValue, Field | xValue == "1" } } , ;
                                                            { "Friday"   , { | oObject, xValue, Field | xValue == "1" } } , ;
                                                            { "Saturday" , { | oObject, xValue, Field | xValue == "1" }  } , ;
                                                            { "Sunday"   , { | oObject, xValue, Field | xValue == "1" } };
                                                        } };
                                    } ;
                   },;
                   { "products", { | | RetItems( ) } };
    }

Return aObj

Static Function RetCountryInfo( cAlias )

    Local cPais       := Posicione("DUY", 1,  xFilial("DUY") + (cAlias)->DUE_CDRSOL ,"DUY_PAIS")
    Local cPaisDescr  := AllTrim( Posicione( "SYA", 1, xFILIAL("SYA") + PadR(cPais, TamSx3("YA_CODGI")[1]),"YA_DESCR"))
    Local aCountry :=  { ;
                        { "countryInternalId" , { || ""         } } , ;
                        { "countryCode"       , { || cPais      } } , ;
                        { "countryDescription", { || cPaisDescr } } ;
            }

Return aCountry

Static Function RetGovInfo( aValues )
    Local aGovInfo := { }
    Local aInfo    := { }

    If !Empty(DUE->DUE_INSCR)
        aInfo := { ;
                        { "Id"    , { || DUE->DUE_INSCR       } } , ;
                        { "scope" , { || "State"              } } , ;
                        { "name"  , { || "Inscrição Estadual" } }  ;
                 } ;

        AAdd( aGovInfo, aInfo )
    EndIf

    If !Empty(DUE->DUE_CGC) .And. Len(AllTrim(DUE->DUE_CGC)) == 14
        aInfo := { ;
                        { "Id"    , { || DUE->DUE_CGC } } , ;
                        { "scope" , { || "Federal"    } } , ;
                        { "name"  , { || "CNPJ"       } }  ;
                 } ;

        AAdd( aGovInfo, aInfo )
    EndIf

    If !Empty(DUE->DUE_CGC) .And. Len(AllTrim(DUE->DUE_CGC)) == 11
        aInfo := { ;
                        { "Id"    , { || DUE->DUE_CGC } } , ;
                        { "scope" , { || "Federal"    } } , ;
                        { "name"  , { || "CPF"        } }  ;
                 } ;

        AAdd( aGovInfo, aInfo )
    EndIf

    If Empty(aGovInfo)
        aGovInfo := Nil
    EndIf

Return aGovInfo

Static Function RetItems( )
    Local aItems := {}

    DVJ->(DbSetOrder(1))
    DVJ->(MsSeek(cSeek := xFilial('DVJ')+DUE->DUE_CODSOL))

    While DVJ->( ! Eof() .And. DVJ->DVJ_FILIAL+DVJ->DVJ_CODSOL == cSeek )

        aItem := { ;
                    { "ProductCode" , &('{ || "' +  DVJ->DVJ_CODPRO + '" }') } , ;
                    { "Product"     , &('{ || "' +  POSICIONE("SB1",1,XFILIAL("SB1")+DVJ->DVJ_CODPRO,"B1_DESC")  + '" }') } , ;
                    { "PackageCode" , &('{ || "' +  DVJ->DVJ_CODEMB + '" }') } , ;
                    { "Package"     , &('{ || "' +  TABELA("MG", DVJ->DVJ_CODEMB,.F. ) + '" }') } ;
        }

        AAdd(aItems, aItem)

        DVJ->(dbSkip())
    EndDo

Return aItems

Method ReceiveObject() CLASS TMSRequestersAdapter

    Local aObj :=   {;
                        {"DUE_FILIAL" } , ;
                        {"DUE_CODSOL" } , ;
                        {"DUE_CODCLI" } , ;
                        {"DUE_LOJCLI" } , ;
                        {"DUE_NOME"   } , ;
                        {"DUE_NREDUZ" } , ;
                        {"DUE_CGC"    , {|oObject| RecGovInfo("CGC", oObject)}} , ;
                        {"DUE_INSCR"  , {|oObject| RecGovInfo("IE", oObject)}} , ;
                        {"DUE_END"    , {|oObject| RecEnd(oObject)}} , ;
                        {"DUE_MUN"    } , ;
                        {"DUE_CODMUN" } , ;
                        {"DUE_EST"    } , ;
                        {"DUE_EST"    } , ;
                        {"DUE_BAIRRO" } , ;
                        {"DUE_CEP"    } , ;
                        {"DUE_PONREF" } , ;
                        {"DUE_CONTAT" } , ;
                        {"DUE_TEL"    } , ;
                        {"DUE_EMAIL"  } , ;
                        {"DUE_DDD"    } , ;
                        {"DUE_TIPTRA" } , ;
                        {"DUE_TIPCOL" } , ;
                        {"DUE_COLSEG" , { |oObject, xValue| If( xValue == Nil , Nil , If( xValue, "1", "2")) }  } , ;
                        {"DUE_COLTER" , { |oObject, xValue| If( xValue == Nil , Nil , If( xValue, "1", "2")) }  } , ;
                        {"DUE_COLQUA" , { |oObject, xValue| If( xValue == Nil , Nil , If( xValue, "1", "2")) }  } , ;
                        {"DUE_COLQUI" , { |oObject, xValue| If( xValue == Nil , Nil , If( xValue, "1", "2")) }  } , ;
                        {"DUE_COLSEX" , { |oObject, xValue| If( xValue == Nil , Nil , If( xValue, "1", "2")) }  } , ;
                        {"DUE_COLSAB" , { |oObject, xValue| If( xValue == Nil , Nil , If( xValue, "1", "2")) }  } , ;
                        {"DUE_COLDOM" , { |oObject, xValue| If( xValue == Nil , Nil , If( xValue, "1", "2")) }  } , ;
                        {"DUE_HORCOI" } , ;
                        {"DUE_HORCOF" } , ;
                        {"DUE_CDRSOL" } , ;
                        {"products", { | oObject, xValue | RecItems( xValue ) } }  ;
                    }

Return aObj

Static Function RecItems( aValues )
    Local aItems := {}
    Local nX := 1

    If ValType(aValues) == "A"
        For nX:= 1 to Len(aValues)
            oItem := aValues[nX]

            aItem := {  {"DVJ_CODPRO", oItem["ProductCode"]},;
                        {"DVJ_CODEMB", oItem["PackageCode"]}}

            AAdd(aItems, aItem)
        Next
    Else
        aItems := Nil
    EndIf

Return aItems

Static Function RecGovInfo( cTipo, oObject )
    Local nX := 1
    Local cInfo
    Local aInfo := {}

    If ValType(oObject["GovernmentalInformation"]) == "A"
        aInfo := oObject["GovernmentalInformation"]
    EndIf

    If cTipo == "IE"
        For nX:= 1 to Len(aInfo)
            If aInfo[nX]["name"] == "Inscrição Estadual"
                cInfo := aInfo[nX]["Id"]
                Exit
            EndIf
        Next
    ElseIf cTipo == "CGC"
        For nX:= 1 to Len(aInfo)
            If aInfo[nX]["name"] == "CNPJ" .OR. aInfo[nX]["name"] == "CPF"
                cInfo := aInfo[nX]["Id"]
                Exit
            EndIf
        Next
    EndIf

Return cInfo

Static Function RecEnd( oObject )
    Local cEnd

    If ValType(oObject["address"]) != "U"

        If ValType(oObject["address"]["address"]) != "U"
            cEnd := oObject["address"]["address"]
        EndIf

        If ValType(oObject["address"]["number"]) != "U"
            cEnd +=  ", " +  oObject["address"]["number"]
        EndIf

    EndIf

Return cEnd

Method DeleteAction( nRecno ) CLASS TMSRequestersAdapter
    Local aError  := {}
    Local aCampos := {}

    DUE->( DbGoTo( nRecno ) )

    If !( lOk := ManutReg( MODEL_OPERATION_DELETE, aCampos, @aError ) )
        // SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails )
        ::SetError( aError[5], , aError[6])
    EndIf

Return lOk

Method PutAction( nRecno, aCampos ) CLASS TMSRequestersAdapter
    Local aError  := {}

    DUE->( DbGoTo( nRecno ) )

    If !( lOk := ManutReg( MODEL_OPERATION_UPDATE, aCampos, @aError ) )
        ::SetError( aError[5], , aError[6])
    EndIf

Return lOk

Method PostAction( aCampos ) CLASS TMSRequestersAdapter
    Local aError  := {}

    If !( lOk := ManutReg( MODEL_OPERATION_INSERT, aCampos, @aError ) )
        ::SetError( aError[5], , aError[6])
    Else
        //-- Adicionar o filtro da região criada para retornar
        ::AddFilter( "code", DUE->DUE_CODSOL )
    EndIf

Return lOk

Static Function ManutReg( nOperation, aCampos, aError )
    Local lOK     := .F.
    Local nItem   := 1
    Local nCampo  := 1
    Local oModel, oSubModel
    Local aError  := {}
    Local cFonte  := "TMSA440"
    Local cModelo := "MdFieldDUE"
    Local cSubModelo := "MdGridDVJ"
    Local aItems := {}

    Local oModelAnt := FwModelActive()

    Default aCampos  := {}
    Default cRetorno := ""

    BEGIN SEQUENCE

        oModel := FWLoadModel( cFonte )
        oModel:SetOperation( nOperation )
        oModel:Activate()

        If nOperation != MODEL_OPERATION_DELETE
            oSubModel := oModel:GetModel( cModelo )
            For nCampo := 1 To Len( aCampos )

                If aCampos[nCampo][1] == "products"
                    aItems := aCampos[nCampo][2]
                    If Len( aItems ) > 0
                        lOk := .T.
                    EndIf
                    Loop
                EndIf

                If oSubModel:CanSetValue( aCampos[nCampo][1] )
                    If ! ( lOK := oSubModel:SetValue( aCampos[nCampo][1], aCampos[nCampo][2] ) )
                        Exit
                    EndIf
                EndIf
            Next

            If lOk

                oSubModel := oModel:GetModel( cSubModelo )
                For nItem := 1 To Len(aItems)
                    For nCampo := 1 To Len(aItems[nItem])
                        If oSubModel:CanSetValue( aItems[nItem][nCampo][1] )
                            If ! ( lOK := oSubModel:SetValue( aItems[nItem][nCampo][1], aItems[nItem][nCampo][2] ) )
                                Exit
                            EndIf
                        EndIf
                    Next
                Next
            EndIf
        Else
            lOK := .T.
        EndIf

        If !( lOK .and. ( lOk := oModel:VldData() .and. oModel:CommitData() ) )
            aError := oModel:GetErrorMessage()
            cRetorno := aError[5] + " | " + aError[6] + " | " + aError[7]
        EndIf

        DUE->( DbSetOrder( 1 ) )
        DUE->( DbSeek( XFilial( "DUE" ) + oModel:GetModel( cModelo ):GetValue("DUE_CODSOL") ) )

        oModel:Destroy()
    RECOVER
        cRetorno := "MVC - Falha não identificada"
        lOK:= .F.
    END SEQUENCE

    If ValType( oModelAnt ) == "O"
        FwModelActive( oModelAnt )
    EndIf

Return lOK