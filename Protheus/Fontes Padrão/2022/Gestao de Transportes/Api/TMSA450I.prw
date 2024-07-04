#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TMSCustomerShippingAddressAdapter
Adapter do resource Group of Regions

Verbos disponíveis: POST, GET, PUT, DELETE
@author Izac Silvério Ciszevski
/*/

CLASS TMSCustomerShippingAddressAdapter FROM BaseResourceAdapter

    METHOD New()

    METHOD FieldMap()
    METHOD SendObject()
    METHOD ReceiveObject()

    METHOD PostAction()
    METHOD PutAction()
    METHOD DeleteAction()

EndClass

/**
 * Construtor
 */
Method New( oRestObj ) CLASS TMSCustomerShippingAddressAdapter
    Self := _Super:New( oRestObj )
    ::SetMainAlias( "DUL" )

Return Self

/**
 * Mapeia as propriedades do objeto definido com os campos do sistema.
 */
Method FieldMap() CLASS TMSCustomerShippingAddressAdapter
    Local aFieldMap as Array

    aFieldMap := { ;
                    { "branchId"                                 , "DUL_FILIAL" } , ;
                    { "code"                                     , "DUL_SEQEND" } , ;
                    { "RequesterCode"                            , "DUL_CODSOL" } , ;
                    { "CustomerCode"                             , "DUL_CODCLI" } , ;
                    { "CustomerStoreID"                          , "DUL_LOJCLI" } , ;
                    { "regionGroupCode"                          , "DUL_CDRDES" } , ;
                    { "DifficultAccessFee"                       , "DUL_TDA"    } , ;
                    { "ShippingAddress.Address"                  , "DUL_END"    } , ;
                    { "ShippingAddress.city.cityDescription"     , "DUL_MUN"    } , ;
                    { "ShippingAddress.city.cityCode"            , "DUL_CODMUN" } , ;
                    { "ShippingAddress.state.stateCode"          , "DUL_EST"    } , ;
                    { "ShippingAddress.state.stateCodeInternalId", "DUL_EST"    } , ;
                    { "ShippingAddress.district"                 , "DUL_BAIRRO" } , ;
                    { "ShippingAddress.ZipCode"                  , "DUL_CEP"    } , ;
                    { "ShippingAddress.PointofReference"         , "DUL_PONREF" } ;
                }

Return aFieldMap


/**
 * Define o objeto que será enviado como resposta, no seguinte formato:
   array := { {"propriedade", {|cAlias, xValue | bloco } } }
   Permite definir blocos de código para o preenchimento de propriedades.
   Caso não informe o valor/bloco, será retornado o valor do campo relacionado se houver mapeamento.

   IMPORTANTE: Esse método pode ser omitido. Caso não seja declarado, será utilizado o mapeamento para definir os campos.
 */
Method SendObject() CLASS TMSCustomerShippingAddressAdapter

    Local aObj := { ;
                    { "companyId"        , { |cAlias, xValue| cEmpAnt                                 } } ,;
                    { "branchId"         , { |cAlias, xValue| XFilial("DUL")                          } } ,;
                    { "companyInternalId", { |cAlias, xValue| cEmpAnt + cFilAnt                       } } ,;
                    { "internalId"       , { |cAlias, xValue| ( cAlias )->( DUL_FILIAL + DUL_SEQEND ) } } ,;
                    { "code" } ,;
                    { "RequesterCode" } ,;
                    { "CustomerCode" } , ;
                    { "CustomerStoreID" } , ;
                    { "regionGroupCode" } ,;
                    { "regionGroup" , { |cAlias| Posicione("DUY", 1, xFilial("DUY") + (cAlias)->DUL_CDRDES,"DUY_DESCRI") } } , ;
                    { "ShippingAddress", {;
                                    { "address", {|cAlias| trataEnd((cAlias)->DUL_END, "L") } } , ;
                                    { "number",  {|cAlias| trataEnd((cAlias)->DUL_END, "N") } } , ;
                                    { "complement" } , ;
                                    { "district" } , ;
                                    { "zipCode" } , ;
                                    { "region" } , ;
                                    { "poBox" } , ;
                                    { "mainAddress" , { | | .F. }} , ;
                                    { "shippingAddress" } , ;
                                    { "billingAddress" } , ;
                                    { "state", {;
                                                    { "stateCode"       } , ;
                                                    { "stateInternalId" } , ;
                                                    { "stateDescription", { |cAlias, xValue| If(!Empty((cAlias)->DUL_EST), FWGetSX5( "12", PadR( (cAlias)->DUL_EST, 6) )[1][4], "")} };
                                                } } ,;
                                    { "country", { |cAlias| RetCountryInfo(cAlias)}  },;
                                    { "city", {;
                                                    { "cityCode" } , ;
                                                    { "cityInternalId" } , ;
                                                    { "cityDescription"} };
                                                } ;
                                  } }  ,;
                    { "DifficultAccessFee" } ,;
                    { "GovernmentalInformation", { |cAlias| RetGovInfo( (cAlias)->DUL_INSCR, (cAlias)->DUL_CGC ) } }, ;
                    { "ShippingAddressInformation", { |cAlias| RetShipInfo( cAlias ) } } ;
                }

Return aObj

Static Function RetCountryInfo( cAlias )

    Local cPais       := Posicione("DUY", 1,  xFilial("DUY") + (cAlias)->DUL_CDRDES ,"DUY_PAIS")
    Local cPaisDescr  := AllTrim( Posicione( "SYA", 1, xFILIAL("SYA") + PadR(cPais, TamSx3("YA_CODGI")[1]),"YA_DESCR"))
    Local aCountry :=  { ;
                        { "countryInternalId" , { || ""         } } , ;
                        { "countryCode"       , { || cPais      } } , ;
                        { "countryDescription", { || cPaisDescr } } ;
            }

Return aCountry

Static Function RetShipInfo( cAlias )
    Local aAreas := {DUL->(GetArea()), SA1->(GetArea()), GetArea()}
    Local aGovInfo := {}

    If SA1->(DbSeek(xFilial('SA1') + DUL->DUL_CODRED + DUL->DUL_LOJRED))
        aGovInfo := RetGovInfo( SA1->A1_INSCR, SA1->A1_CGC)
    EndIf

    AEval(aAreas, {|aArea| RestArea(aArea)})

Return aGovInfo

Static Function RetGovInfo( cInscEst, cCGC )
    Local aGovInfo := { }
    Local aInfo    := { }

    If !Empty(DUL->DUL_INSCR)
        aInfo := { ;
                        { "Id"    , { || cInscEst             } } , ;
                        { "scope" , { || "State"              } } , ;
                        { "name"  , { || "Inscrição Estadual" } }  ;
                 } ;

        AAdd( aGovInfo, aInfo )
    EndIf

    If !Empty(cCGC) .And. Len(AllTrim(cCGC)) == 14
        aInfo := { ;
                        { "Id"    , { || cCGC      } } , ;
                        { "scope" , { || "Federal" } } , ;
                        { "name"  , { || "CNPJ"    } }  ;
                 } ;

        AAdd( aGovInfo, aInfo )
    EndIf

    If !Empty(cCGC) .And. Len(AllTrim(cCGC)) == 11
        aInfo := { ;
                        { "Id"    , { || cCGC      } } , ;
                        { "scope" , { || "Federal" } } , ;
                        { "name"  , { || "CPF"     } }  ;
                 } ;

        AAdd( aGovInfo, aInfo )
    EndIf

    If Empty(aGovInfo)
        aGovInfo := Nil
    EndIf

Return aGovInfo


/**
 * Define um array com  como resposta, no seguinte formato:
   array := { {"propriedade", {|cAlias, xValue | bloco } } }
   Permite definir blocos de código para o preenchimento de propriedades.
   Caso não informe o valor/bloco, será retornado o valor do campo relacionado se houver mapeamento.

   IMPORTANTE: Esse método pode ser omitido. Caso não seja declarado, será utilizado o mapeamento para definir os campos.
 */

Method ReceiveObject() CLASS TMSCustomerShippingAddressAdapter

    Local aObj := { ;
                    {"DUL_FILIAL"} , ;
                    {"DUL_SEQEND"} , ;
                    {"DUL_CODSOL"} , ;
                    {"DUL_CODCLI"} , ;
                    {"DUL_LOJCLI"} , ;
                    {"DUL_CGC"     , {|oObject| RecGovInfo("CGC", oObject)}} , ;
                    {"DUL_INSCR"   , {|oObject| RecGovInfo("IE" , oObject)}} , ;
                    {"DUL_CODRED"  , {|oObject| RecRedInfo("cod", oObject)}} , ;
                    {"DUL_LOJRED"  , {|oObject| RecRedInfo("loj", oObject)}} , ;
                    {"DUL_END"     , {|oObject| RecEnd(oObject)}} , ;
                    {"DUL_CDRDES"} , ;
                    {"DUL_TDA"}    , ;
                    {"DUL_END"}    , ;
                    {"DUL_MUN"}    , ;
                    {"DUL_CODMUN"} , ;
                    {"DUL_EST"}    , ;
                    {"DUL_EST"}    , ;
                    {"DUL_BAIRRO"} , ;
                    {"DUL_CEP"}    , ;
                    {"DUL_PONREF"} ;
                }


Return aObj


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

Static Function RecRedInfo( cTipo, oObject )
    Local nX := 1
    Local cKey  := ""
    Local cInfo 
    Local aInfo := {}

    If ValType(oObject["ShippingAddressInformation"]) == "A"
        aInfo := oObject["ShippingAddressInformation"]
    EndIf

    For nX:= 1 to Len(aInfo)
        If aInfo[nX]["name"] == "CNPJ" .OR. aInfo[nX]["name"] == "CPF"
            cKey := aInfo[nX]["Id"]
            Exit
        EndIf
    Next

    SA1->( dbSetOrder( 3 ) )
	If !Empty( cKey ) .And. SA1->( MsSeek( xFilial( "SA1" ) + cKey ) )
        If cTipo == "cod"
            cInfo   := SA1->A1_COD
        ElseIf cTipo == "loj"
		    cInfo   := SA1->A1_LOJA
        EndIf
    EndIf

Return cInfo

Static Function RecEnd( oObject )
    Local cEnd

    If ValType(oObject["address"]) != "U"

        If ValType(oObject["ShippingAddress"]["address"]) != "U"
            cEnd := oObject["ShippingAddress"]["address"]
        EndIf

        If ValType(oObject["ShippingAddress"]["number"]) != "U"
            cEnd +=  ", " +  oObject["ShippingAddress"]["number"]
        EndIf

    EndIf

Return cEnd
/**
  Define a query de pesquisa. Recebe os campos do FieldMap, o filtro SQL criado com o
  QueryParam e a ordem, também recebida pelo QueryParam. Deve Existir o campo RECNO.

  IMPORTANTE: Esse método pode ser omitido.
 */
/*
Method CreateQuery( aFields, cWhere, cOrder ) CLASS TMSCustomerShippingAddressAdapter

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

/**
  Método que será executado quando o método DELETE for chamado.
  Recebe o Recno do registro a ser deletado.
 */
Method DeleteAction( nRecno ) CLASS TMSCustomerShippingAddressAdapter
    Local aError  := {}
    Local aCampos := {}

    DUL->( DbGoTo( nRecno ) )

    If !( lOk := ManutReg( MODEL_OPERATION_DELETE, aCampos, @aError ) )
        // SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails )
        ::SetError( aError[5], , aError[6])
    EndIf

Return lOk

/**
  Método que será executado quando o método PUT for chamado.
  Recebe o Recno do registro a ser alterado e um array no formato
  { { "campo", valor } }, transformando o objeto recebido conforme
  a definição ReceiveObject.
 */
Method PutAction( nRecno, aCampos ) CLASS TMSCustomerShippingAddressAdapter
    Local aError  := {}

    DUL->( DbGoTo( nRecno ) )

    If !( lOk := ManutReg( MODEL_OPERATION_UPDATE, aCampos, @aError ) )
        // SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails )
        ::SetError( aError[5], , aError[6])
    EndIf

Return lOk

/**
  Método que será executado quando o método POST for chamado.
  Recebe um array no formato { { "campo", valor } }, transformando o objeto recebido
  conforme a definição ReceiveObject.
 */
Method PostAction( aCampos ) CLASS TMSCustomerShippingAddressAdapter
    Local aError  := {}

    If !( lOk := ManutReg( MODEL_OPERATION_INSERT, aCampos, @aError ) )
        // SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails )
        ::SetError( aError[5], , aError[6])
    Else
        //-- Adicionar o filtro da região criada para retornar
        ::AddFilter( "code", DUL->DUL_SEQEND )
    EndIf

Return lOk

/**
  Função para realizar a manutenção de um modelo MVC. Recebe a operação ( 3, 4, 5) e
  um array no formato { { "campo", valor } }. O parâmetro aError recebe o array de erros, caso exista.
 */
Static Function ManutReg( nOperation, aCampos, aError )
    Local lOK     := .F.
    Local nCampo  := 1
    Local oModel, oModelFields
    Local aError  := {}
    Local cFonte  := "TMSA450"
    Local cModelo := "MdFieldDUL"

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
        Else
            lOk := .T.
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