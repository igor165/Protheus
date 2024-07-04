#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAC15A.CH'

Static lRestRepom 	:= SuperGetMV('MV_VSREPOM',,"1") == "2.2"

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriverByDoc()
Realiza o tratamento do Json retornado do GetDrvrByDoc e GetDrvrByName

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cGet    retorno do get a ser tratado
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
@Return     aRet    { 
                        { Locked,                       , Logico} ,
                        { LockedReason,                 , "" } ,
                        { driver_country                , "" } ,
                        { driver_national_id            , "" } ,
                        { driver_license_number         , "" } ,
                        
                        { driver_address_street         , "" } ,
                        { driver_address_number         , "" } ,
                        { driver_address_complement     , "" } ,
                        { driver_address_neighborhood   , "" } ,
                        { driver_address_zipcode        , "" } ,

                        { driver_birthdate              , "" } ,
                        { driver_gender                   , "" } ,
                        { driver_name                 , "" } ,
                        
                        {
                            driver_phone_areacode       , ""
                            driver_phone_number         , ""
                            driver_phone_preferential   , Logical
                            driver_phone_typeid         , ""
                        }
                    }
/*/
//--------------------------------------------------------------------

Function TMSGDriver( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGDArr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGDArr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf

            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf
    
    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGDArr()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetGDArr( oResult )

    Local nCount    := 0
    Local aResult   := {}
    Local aTel      := {}
    Local aPhones   := {}

    AAdd( aResult, { "Locked",                  oResult:Locked                 } )
    AAdd( aResult, { "LockedReason",            oResult:LockedReason           } )
    AAdd( aResult, { "driver_country",          oResult:Country                } )
    AAdd( aResult, { "driver_national_id",      oResult:NationalId             } )
    AAdd( aResult, { "driver_license_number",   oResult:DriverLicenseNumber    } )

    If AttIsMemberOf( oResult, "ADDRESS" )
        AAdd( aResult, { "driver_address_street",          oResult:Address:Street        } )
        AAdd( aResult, { "driver_address_number",          oResult:Address:Number        } )
        AAdd( aResult, { "driver_address_complement",      oResult:Address:Complement    } )
        AAdd( aResult, { "driver_address_neighborhood",    oResult:Address:Neighborhood  } )
        AAdd( aResult, { "driver_address_zipcode",         oResult:Address:ZipCode       } )
    EndIf

    If AttIsMemberOf( oResult, "DriverPersonalInformation" )
        AAdd( aResult, { "driver_birthdate",  RetForDt(oResult:DriverPersonalInformation:BirthDate)   } )
        AAdd( aResult, { "driver_gender",     oResult:DriverPersonalInformation:Gender      } )
        AAdd( aResult, { "driver_name",       oResult:DriverPersonalInformation:Name        } )
    EndIf

    If AttIsMemberOf( oResult, "PHONES" )
        
        For nCount := 1 To Len( oResult:Phones )
        
            AAdd( aTel, { "driver_phone_areacode",       oResult:Phones[nCount]:AreaCode     } )
            AAdd( aTel, { "driver_phone_number",         oResult:Phones[nCount]:Number       } )
            AAdd( aTel, { "driver_phone_preferential",   oResult:Phones[nCount]:Preferential } )
            AAdd( aTel, { "driver_phone_typeid",         oResult:Phones[nCount]:TypeId       } )

            AAdd( aPhones, aTel )

            aTel := {}
        Next nCount

        AAdd( aResult, aPhones )

        aPhones := {}
    EndIf

    FWFreeArray(aPhones)
    FWFreeArray(aTel)

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGCard
Realiza o tratamento do Json retornado do GetCardHired, 
GetCardDriver e GetCardDvrHrd.

@param      cGet    string a ser tratada
@return     aRet    {
                        {
                            "CardNumber": 0,
                            "CardType": "string",
                            "HiredNationalID": "string",
                            "HiredName": "string",
                            "DriverNationalID": "string",
                            "DriverName": "string",
                            "Status": "Active"
                        }
                    }
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Function TMSGCard( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGCdAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGCdAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGDArr()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetGCdAr( oResult )

    Local aResult   := {}

    AAdd( aResult, { "Card_Number",             oResult:CardNumber          } )
    AAdd( aResult, { "Card_Type",               oResult:CardType            } )
    AAdd( aResult, { "Card_HiredNationalID",    oResult:HiredNationalID     } )
    AAdd( aResult, { "Card_HiredName",          oResult:HiredName           } )
    AAdd( aResult, { "Card_DriverNationalID",   oResult:DriverNationalID    } )
    AAdd( aResult, { "Card_DriverName",         oResult:DriverName          } )

    If oResult:Status == "Active"
        AAdd( aResult, { "Card_Status",         .T.                         } )
    Else
        AAdd( aResult, { "Card_Status",         .F.                         } )
    EndIf

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} RetErrRep()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetErrRep( nResult )

    Local aRet      := {}

    Default nResult := 0

    If nResult == 400
        AAdd( aRet, { 400, "400	Bad Request", STR0001           } ) // STR0001 "O Servidor não pode processar a requisição devido a algum erro do cliente."
    ElseIf nResult == 401
        AAdd( aRet, { 401, "401	Unauthorized", STR0002          } ) // STR0002 "A solicitação não foi aplicada porque não possui credenciais de autenticação válidas."
    ElseIf nResult == 404
        AAdd( aRet, { 404, "404	Not Found", STR0003             } ) // STR0003 "O Servidor não conseguiu encontrar o recurso solicitado."
    ElseIf nResult == 500
        AAdd( aRet, { 500, "500	Internal Server Error", STR0004 } ) // STR0004 "O Servidor encontrou uma condição inesperada que o impediu de atender à solicitação."
    EndIf

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetLoadTypes

@param      cGet    string a ser tratada
@return     aRet    { {"CodeType": 1, "Description": "Granel sólido"} }
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Function TMSGLdTp( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aResult   := {}
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "A"
                    
                    For nCount := 1 To Len( oResult:Result )
                        
                        AAdd( aResult, { "Load_CodeType",       oResult:Result[nCount]:CodeType    } )
                        AAdd( aResult, { "Load_Description",    DecodeUTF8(oResult:Result[nCount]:Description) } )
                        
                        AAdd( aRet, aResult )
                        
                        aResult := {}

                    Next nCount

                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetHiredByName, GetHiredByDoc

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    
{   { "Hired_Country",               oResult:Country                 },
    { "Hired_NationalId",            oResult:NationalId              },
    { "Hired_Type",                  oResult:HiredType               },
    { "Hired_Locked",                oResult:Locked                  },
    { "Hired_LockedReason",          oResult:LockedReason            },
    { "Hired_Email",                 oResult:Email                   },
    { "Hired_Status",                oResult:Status                  },
    { "Hired_FuelVoucherPercentage", oResult:FuelVoucherPercentage   },
    { "Hired_UsesFuelVoucher",       oResult:UsesFuelVoucher         },
    { "Hired_RNTRC",     oResult:BrazilianSettings:RNTRC    },
    { "Hired_INSS",  oResult:BrazilianSettings:HiredPessoaFisica:INSS    },
    { "Hired_RG",    oResult:BrazilianSettings:HiredPessoaFisica:RG      },
    { "Hired_InscricaoEstadual",         oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoEstadual         },
    { "Hired_InscricaoMunicipal",        oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoMunicipal        },
    { "Hired_NomeFantasia",              oResult:BrazilianSettings:HiredPessoaJuridica:NomeFantasia              },
    { "Hired_OptanteSimplesNacional",    oResult:BrazilianSettings:HiredPessoaJuridica:OptanteSimplesNacional    },
    { "Hired_address_street",          oResult:Address:Street        },
    { "Hired_address_number",          oResult:Address:Number        },
    { "Hired_address_complement",      oResult:Address:Complement    },
    { "Hired_address_neighborhood",    oResult:Address:Neighborhood  },
    { "Hired_address_zipcode",         oResult:Address:ZipCode       },
    { "Hired_CompanyName",             oResult:CompanyInformation:CompanyName  },
    { "Hired_birthdate",         oResult:DriverPersonalInformation:BirthDate         },
    { "Hired_gender",            oResult:DriverPersonalInformation:Gender            },
    { "Hired_LegalDependents",   oResult:DriverPersonalInformation:LegalDependents   },
    { "Hired_name",              oResult:DriverPersonalInformation:Name              },
    { "ANTTDataConsulta",        oResult:BrazilianTransportRegulatoryAgency:ANTTDataConsulta     },
    { "ANTTEquiparadoTAC",       oResult:BrazilianTransportRegulatoryAgency:ANTTEquiparadoTAC    },
    { "ANTTNomeRazaoSocial",     oResult:BrazilianTransportRegulatoryAgency:ANTTNomeRazaoSocial  },
    { "ANTTRNTRCAtivo",          oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCAtivo       },
    { "ANTTRNTRCDataValidade",   oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCDataValidade},
    { "ANTTTransportadorTipo",   oResult:BrazilianTransportRegulatoryAgency:ANTTTransportadorTipo},
    {   { "Hired_phone_areacode",       oResult:Phones[nCount]:AreaCode     },
        { "Hired_phone_number",         oResult:Phones[nCount]:Number       },
        { "Hired_phone_preferential",   oResult:Phones[nCount]:Preferential },
        { "Hired_phone_typeid",         oResult:Phones[nCount]:TypeId       } }
/*/
//--------------------------------------------------------------------
Function TMSGHBNm( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGHBNAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGHBNAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGDArr()
Retorna o contudo do objeto no formato de array

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetGHBNAr( oResult )

    Local nCount    := 0
    Local aResult   := {}
    Local aTel      := {}
    Local aPhones   := {}

    AAdd( aResult, { "Hired_Country",               oResult:Country                 } )
    AAdd( aResult, { "Hired_NationalId",            oResult:NationalId              } )
    AAdd( aResult, { "Hired_Type",                  oResult:HiredType               } )
    AAdd( aResult, { "Hired_Locked",                oResult:Locked                  } )
    AAdd( aResult, { "Hired_LockedReason",          oResult:LockedReason            } )
    AAdd( aResult, { "Hired_Email",                 oResult:Email                   } )
    AAdd( aResult, { "Hired_Status",                oResult:Status                  } )
    
    If AttIsMemberOf( oResult, "FuelVoucherPercentage" )
        AAdd( aResult, { "Hired_FuelVoucherPercentage", oResult:FuelVoucherPercentage   } )
    EndIf
    
    If AttIsMemberOf( oResult, "UsesFuelVoucher" )
        AAdd( aResult, { "Hired_UsesFuelVoucher",       oResult:UsesFuelVoucher         } )
    EndIf

    If AttIsMemberOf( oResult, "BrazilianSettings" )
        AAdd( aResult, { "Hired_RNTRC",     oResult:BrazilianSettings:RNTRC } )

        If ValType( oResult:BrazilianSettings:HiredPessoaFisica ) == "O"
            AAdd( aResult, { "Hired_INSS",  oResult:BrazilianSettings:HiredPessoaFisica:INSS    } )
            AAdd( aResult, { "Hired_RG",    oResult:BrazilianSettings:HiredPessoaFisica:RG      } )
        EndIf
        
        If ValType( oResult:BrazilianSettings:HiredPessoaJuridica ) == "O"
            AAdd( aResult, { "Hired_InscricaoEstadual",         oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoEstadual         } )
            AAdd( aResult, { "Hired_InscricaoMunicipal",        oResult:BrazilianSettings:HiredPessoaJuridica:InscricaoMunicipal        } )
            AAdd( aResult, { "Hired_NomeFantasia",              oResult:BrazilianSettings:HiredPessoaJuridica:NomeFantasia              } )
            AAdd( aResult, { "Hired_OptanteSimplesNacional",    oResult:BrazilianSettings:HiredPessoaJuridica:OptanteSimplesNacional    } )//Logico
        EndIf
    EndIf

    If AttIsMemberOf( oResult, "ADDRESS" )
        AAdd( aResult, { "Hired_address_street",          oResult:Address:Street        } )
        AAdd( aResult, { "Hired_address_number",          oResult:Address:Number        } )
        AAdd( aResult, { "Hired_address_complement",      oResult:Address:Complement    } )
        AAdd( aResult, { "Hired_address_neighborhood",    oResult:Address:Neighborhood  } )
        AAdd( aResult, { "Hired_address_zipcode",         oResult:Address:ZipCode       } )
    EndIf

    If ValType( oResult:CompanyInformation ) == "O"
        AAdd( aResult, { "Hired_CompanyName",             oResult:CompanyInformation:CompanyName  } )
    EndIf

    If AttIsMemberOf( oResult, "HiredPersonalInformation" ) .And. oResult:HiredPersonalInformation <> Nil
        AAdd( aResult, { "Hired_birthdate",         RetForDt(oResult:HiredPersonalInformation:BirthDate)} )
        AAdd( aResult, { "Hired_gender",            oResult:HiredPersonalInformation:Gender             } )
        AAdd( aResult, { "Hired_LegalDependents",   oResult:HiredPersonalInformation:LegalDependents    } )
        AAdd( aResult, { "Hired_name",              oResult:HiredPersonalInformation:Name               } )
    EndIf

    If AttIsMemberOf( oResult, "BrazilianTransportRegulatoryAgency" )
        AAdd( aResult, { "ANTTDataConsulta",        RetForDt(oResult:BrazilianTransportRegulatoryAgency:ANTTDataConsulta)     } )
        AAdd( aResult, { "ANTTEquiparadoTAC",       oResult:BrazilianTransportRegulatoryAgency:ANTTEquiparadoTAC    } )
        AAdd( aResult, { "ANTTNomeRazaoSocial",     oResult:BrazilianTransportRegulatoryAgency:ANTTNomeRazaoSocial  } )
        AAdd( aResult, { "ANTTRNTRCAtivo",          oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCAtivo       } )
        AAdd( aResult, { "ANTTRNTRCDataValidade",   RetForDt(oResult:BrazilianTransportRegulatoryAgency:ANTTRNTRCDataValidade)} )
        AAdd( aResult, { "ANTTTransportadorTipo",   oResult:BrazilianTransportRegulatoryAgency:ANTTTransportadorTipo} )
    EndIf

    If AttIsMemberOf( oResult, "PHONES" )
        
        For nCount := 1 To Len( oResult:Phones )
        
            AAdd( aTel, { "Hired_phone_areacode",       oResult:Phones[nCount]:AreaCode     } )
            AAdd( aTel, { "Hired_phone_number",         oResult:Phones[nCount]:Number       } )
            AAdd( aTel, { "Hired_phone_preferential",   oResult:Phones[nCount]:Preferential } )
            AAdd( aTel, { "Hired_phone_typeid",         oResult:Phones[nCount]:TypeId       } )

            AAdd( aPhones, aTel )

            aTel := {}
        Next nCount

        AAdd( aResult, aPhones )

        aPhones := {}
    EndIf

    FWFreeArray(aPhones)
    FWFreeArray(aTel)

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} RetForDt( cData )
Faz tratamento na string enviada para ser transformada em Data

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      oResult     Objeto com o resultado do get
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

Static Function RetForDt( cData )

    Local dRetData  := SToD("19000101")
    
    Default cData   := "19000101"

    dRetData    := SToD( StrTran( SubStr( cData, 1, 10 ), "-", "" ) )

Return dRetData

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetRtByCEP GetRtByIBGE GetRtByTrcId

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
                    "TraceCode": 0,
                    "RouteCode": 0,
                    "Distance": 0,
                    "RoundTrip": true,
                    "Name": "string",
                    "TotalVPRValue": 0,
                    "TraceIdentifier": "string"
                    }
/*/
//--------------------------------------------------------------------

Function TMSGRota( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGRtAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGRtAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetGRtAr
Realiza o tratamento do Json retornado do GetRtByCEP GetRtByIBGE GetRtByTrcId

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
{
  "TraceCode": 0,
  "RouteCode": 0,
  "Distance": 0,
  "RoundTrip": true,
  "Name": "string",
  "TotalVPRValue": 0,
  "TraceIdentifier": "string"
}
/*/
//--------------------------------------------------------------------

Static Function RetGRtAr( oResult )

    Local aResult   := {}

    AAdd( aResult, { "Route_TraceCode",         oResult:TraceCode       } )
    AAdd( aResult, { "Route_RouteCode",         oResult:RouteCode       } )
    AAdd( aResult, { "Route_Distance",          oResult:Distance        } )
    AAdd( aResult, { "Route_RoundTrip",         oResult:RoundTrip       } )
    AAdd( aResult, { "Route_Name",              oResult:Name            } )
    AAdd( aResult, { "Route_TotalVPRValue",     oResult:TotalVPRValue   } )
    AAdd( aResult, { "Route_TraceIdentifier",   oResult:TraceIdentifier } )

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetRtRequest

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
                    "Id": 0,
                    "Status": "Pending",
                    "TraceCode": 0,
                    "RouteCode": 0,
                    "DisapprovalReason": "string",
                    "DisapprovalReasonCode": 0,
                    "TraceIdentifier": "string"
                    }
/*/
//--------------------------------------------------------------------

Function TMSGRoReq( cGet )

    Local nCount    := 0
    Local oResult   := Nil
    Local aRet      := {}

    Default cGet    := ""

    If FWJsonDeserialize( cGet, @oResult )
        If ValType(oResult) == "O"
            If AttIsMemberOf( oResult, "RESULT" )

                If ValType(oResult:Result) == "O"
                    
                    AAdd( aRet, RetGRRAr( oResult:Result ) )

                Else
                    For nCount := 1 To Len( oResult:Result )

                        AAdd( aRet, RetGRRAr( oResult:Result[nCount] ) )
                        
                    Next nCount
                EndIf
            EndIf
        ElseIf ValType(oResult) == "N"
            aRet := RetErrRep( oResult )
        EndIf
    EndIf

    FwFreeObj(oResult)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGLdTp
Realiza o tratamento do Json retornado do GetRtRequest

@param      cGet    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     aRet    {
{
  "Id": 0,
  "Status": "Pending",
  "TraceCode": 0,
  "RouteCode": 0,
  "DisapprovalReason": "string",
  "DisapprovalReasonCode": 0,
  "TraceIdentifier": "string"
}
/*/
//--------------------------------------------------------------------

Static Function RetGRRAr( oResult )

    Local aResult   := {}

    AAdd( aResult, { "Route_Id",                    cValToChar(oResult:Id)          } )
    AAdd( aResult, { "Route_Status",                oResult:Status                  } )
    AAdd( aResult, { "Route_TraceCode",             cValToChar(oResult:TraceCode)   } )
    AAdd( aResult, { "Route_RouteCode",             cValToChar(oResult:RouteCode)   } )
    AAdd( aResult, { "Route_DisapprovalReason",     oResult:DisapprovalReason       } )
    AAdd( aResult, { "Route_DisapprovalReasonCode", cValToChar(oResult:DisapprovalReasonCode)   } )
    AAdd( aResult, { "Route_TraceIdentifier",       oResult:TraceIdentifier         } )

Return aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriver
Aciona o metodo Create ou Update do Motorista

@param      cCodMot    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSDriver( cCodMot )

    Local oRepom    := Nil
    Local aDriver   := {}
    Local nI        := 0
    Local lRepInc	:= .T.
    Local lErro		:= .F.
    Local lRepom    := .T.

    Default cCodMot := ""

	oRepom := TMSBCARepomFrete():New()
	oRepom:Auth()

	aDriver := oRepom:GetDrvrByDoc( cCodMot )
    
    For nI := 1 To Len(aDriver)
        If Valtype( aDriver[nI][1] ) == "N"

            If aDriver[nI][1] == 404// Not Found
                lRepInc := .T. // Realiza a inclusão
            Else
                lErro	:= .T.
                Exit
            EndIf

        Else
            lRepInc := .F. // Realiza a alteração
        EndIf
    Next nI

	If !lErro
		If lRepInc
			lRepom := oRepom:DriverCreate( cCodMot )
		Else
			lRepom := oRepom:DriverUpdate( cCodMot )
		EndIf
	EndIf

	oRepom:Destroy()
	FwFreeObj(oRepom)

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriLoc
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSDriLoc( cCodMot, lLock, cObserv )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local lRepExc   := .F.
    Local lErro     := .F.
    Local aDriver   := {}
    Local nI        := 0

    Default cCodMot := ""
    Default lLock   := .F.
    Default cObserv := ""
    
    If !Empty(cCodMot)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aDriver := oRepom:GetDrvrByDoc( cCodMot )

        For nI := 1 To Len(aDriver)
            If Valtype( aDriver[nI][1] ) == "N"

                If aDriver[nI][1] == 404// Not Found
                    lRepExc := .F. // Realiza a Exclusão
                Else
                    lErro	:= .T.
                    Exit
                EndIf

            Else
                lRepExc := .T. // Realiza a Exclusão
            EndIf
        Next nI
        
        If !lErro .AND. lRepExc
            lRepom := oRepom:DriverLock( cCodMot, lLock, cObserv )
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSVCard
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSVCard( cCodMot, cStatus, cCard )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local aCard     := {}
    Local nI        := 0

    Default cCodMot := ""
    Default cStatus := ""
    Default cCard   := ""

    If !Empty( cCodMot )
        TmsRepTrac("TMSBCARepomFrete - Instanciado ")
        
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        TmsRepTrac("GetCardDriver - Instanciado ")
        
        aCard := oRepom:GetCardDriver( cCodMot )
        oRepom:Destroy()
        FwFreeObj(oRepom)

        If Len(aCard) > 0
            For nI := 1 To Len(aCard)
                If Valtype( aCard[nI][1] ) == "N"
                    Aviso( aCard[nI][2], aCard[nI][3], { "Ok" } )
                    lRepom := .F.
                    Exit
                Else
                    lRepom  := .T.
                    cStatus := If( aCard[nI][7][2], "Ativo", "Desativado" )
                    TmsRepTrac( "GetCardDriver - Consumido "+ AllToChar( aCard[nI][7][2] ) )
                    Exit
                EndIf
            Next nI
        Else
            lRepom := .F.
        EndIf
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriver
Aciona o metodo Create ou Update do Motorista

@param      cCodMot    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSVehic( cCodVei )

    Local oRepom    := Nil
    Local aVeicul   := {}
    Local lRepInc	:= .T.
    Local lErro		:= .F.
    Local lRepom    := .T.

    Default cCodVei := ""

	oRepom := TMSBCARepomFrete():New()
	oRepom:Auth()

	aVeicul := oRepom:GetVeicByDoc( cCodVei )
    
    If Len(aVeicul) > 0
        lRepInc := .F. // Realiza a Alteração
    EndIf

	If !lErro
		If lRepInc
			lRepom := oRepom:VehicleCreate( cCodVei )
		Else
			lRepom := oRepom:VehicleUpdate( cCodVei )
		EndIf
	EndIf

	oRepom:Destroy()
	FwFreeObj(oRepom)

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriLoc
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSVeiLoc( cCodVei, lLock, cObserv )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local lRepExc   := .F.
    Local lErro     := .F.
    Local aVeicul   := {}

    Default cCodVei := ""
    Default lLock   := .F.
    Default cObserv := ""
    
    If !Empty(cCodVei)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aVeicul := oRepom:GetVeicByDoc( cCodVei )

        If Len(aVeicul) > 0
            lRepExc := .T.
        EndIf

        If !lErro .AND. lRepExc
            lRepom := oRepom:VehicleLock( cCodVei, lLock, cObserv )
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriver
Aciona o metodo Create ou Update do Motorista

@param      cCodMot    string a ser tratada
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSHired( cCodFor, cLoja )

    Local oRepom    := Nil
    Local aDriver   := {}
    Local nI        := 0
    Local lRepInc	:= .T.
    Local lErro		:= .F.
    Local lRepom    := .T.

    Default cCodFor := ""
    Default cLoja   := ""

    If !Empty(cCodFor) .AND. !Empty(cLoja)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aDriver := oRepom:GetHrdByDoc( cCodFor, cLoja )
        
        For nI := 1 To Len(aDriver)
            If Valtype( aDriver[nI][1] ) == "N"

                If aDriver[nI][1] == 404// Not Found
                    lRepInc := .T. // Realiza a inclusão
                Else
                    lErro	:= .T.
                    Exit
                EndIf

            Else
                lRepInc := .F. // Realiza a alteração
            EndIf
        Next nI

        If !lErro
            If lRepInc
                lRepom := oRepom:HiredCreate( cCodFor, cLoja )
            Else
                lRepom := oRepom:HiredUpdate( cCodFor, cLoja )
            EndIf
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSDriLoc
Aciona o metodo Patch do Motorista

@param      cCodMot, lLock, cObserv
@author     Rodrigo A. Pirolo
@since      29/09/2020
@version    1.0
@return     lRepom  
/*/
//--------------------------------------------------------------------

Function TMSHirLoc( cCodFor, cLoja, lLock, cObserv )

    Local oRepom    := Nil
    Local lRepom    := .T.
    Local lRepExc   := .F.
    Local lErro     := .F.
    Local aDriver   := {}
    Local nI        := 0

    Default cCodFor := ""
    Default cLoja   := ""
    Default lLock   := .F.
    Default cObserv := "Delete"
    
    If !Empty(cCodFor) .AND. !Empty(cLoja)
        oRepom := TMSBCARepomFrete():New()
        oRepom:Auth()

        aDriver := oRepom:GetHrdByDoc( cCodFor, cLoja )

        For nI := 1 To Len(aDriver)
            If Valtype( aDriver[nI][1] ) == "N"

                If aDriver[nI][1] == 404// Not Found
                    lRepExc := .F. // Realiza a Exclusão
                Else
                    lErro	:= .T.
                    Exit
                EndIf

            Else
                lRepExc := .T. // Realiza a Exclusão
            EndIf
        Next nI
        
        If !lErro .AND. lRepExc
            lRepom := oRepom:HiredLock( cCodFor, cLoja, lLock, cObserv )
        EndIf

        oRepom:Destroy()
        FwFreeObj(oRepom)
    EndIf

Return lRepom

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSGravDEG
Realiza gravação do token e seu limite de uso

@param      cToken, nExpire
@author     Rodrigo A. Pirolo
@since      09/10/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMSGravDEG( cToken, nExpire )

    Local lRet      := .F.
    Local aAreaDEG  := DEG->(GetArea())

    Default cToken  := ""
    Default nExpire := 0
    
    If !Empty( cToken )
        DbSelectArea("DEG")
        DEG->( DbSetOrder( 1 ) )

        If DEG->( DbSeek( xFilial( "DEG" ) + "01" ) )
            RecLock("DEG", .F.)
                DEG->DEG_TOKEN  := cToken
                DEG->DEG_DTTOKE := Date()
                DEG->DEG_HRTOKE := Time()
                DEG->DEG_EXPIRE := nExpire
            DEG->( MsUnlock() )
            lRet := .T.
        EndIf
    EndIf
    
    RestArea(aAreaDEG)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMS15TstR
Realiza teste de comunicaç~ão do cadastro da repom.

@param      cToken, nExpire
@author     Rodrigo A. Pirolo
@since      09/10/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------

Function TMS15TstR()

	Local oObj          := Nil
	Local cToken        := ""
    Local cTitulo       := ""
    Local cMsg          := ""
	
	If ( DEG->DEG_CODOPE == "01" .AND. AllTrim( SuperGetMV( 'MV_VSREPOM',, '1' ) ) == '2.2' ) .OR. ( DEG->DEG_CODOPE == "03" .AND. FindFunction("TMSIntgPB") )
        If DEG->DEG_CODOPE == "01"
            oObj  := TMSBCARepomFrete():New()
        
            If oObj:Auth()
                cToken  := AllTrim( oObj:Access_Token )
            EndIf
            cTitulo := STR0005
            cMsg    := If( !Empty(cToken), STR0006 + cToken, STR0007 )

        ElseIf DEG->DEG_CODOPE == "03"
            oObj := TMSBCAPagBem():New()
        
            If oObj:Auth( DEG->DEG_URLWS/*cUrlToken*/, DEG->DEG_USER/*cUser*/, DEG->DEG_SENHA/*cPassword*/ )
                cToken  := oObj:GetToken()
                oObj:GetLastError()
                oObj:GetErrorDescription()
            EndIf
            cTitulo := STR0017
            cMsg    := If( !Empty(cToken), STR0018 + cToken, STR0019 )
            
        EndIf
	
	    Aviso( cTitulo, cMsg, { "Ok" } )//STR0005"Integração Prtheus TMS x REPOM" STR0006"A comunicação com o Sistema Repom foi realizada com sucesso. O Token de acesso é: "
	    	
	    FwFreeObj( oObj )

	Else
        Help( "", 1, 'TMS15TstR', , STR0008, 1, 0, , , , , .T., )//STR0008 'Apenas a Gerenciadora de Frota REPOM possui esta funcionalidade.'
	EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} TMS15IdShip
Realiza GET para obter o ShippingID 

@param      cFilOri, cViagem
@author     Caio Murakami
@since      05/11/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------
Function TMS15IdShip( cFilOri , cViagem , lAtuDTR , nSegRest )
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())
Local oRepom    := Nil
Local aRet      := {} 
Local lRet      := .T.
Local nPos      := 0 
Local cStatus   := ""
Local cRet      := ""
Local nTryMax   := 0 
Local aError    := {} 
Local nCount    := 1 
Local lShipID   := .F.
Local nSleep    := TM15TmpEsp()   //Tempo maximo de Espera
Local aRetErr   := {}
Local cPending  := ""
Local cCIOT     := ""

Default cFilOri     := ""
Default cViagem     := ""
Default lAtuDTR     := .T. 
Default nSegRest    := 0

oRepom  := TMSBCARepomFrete():New()
oRepom:Auth()

 
While Empty(cRet) .And. nTryMax <= 1 .AND. Len(aError) == 0  
    aRet        := {}
    aRet        := oRepom:GetShipStPrcBy( cFilOri , cViagem ) 
    cPending    := ""
    nPos        := aScan(aRet,{|x| x[1] == "STATUS" }) 

    If nPos > 0 
        cStatus := Upper(AllTrim(aRet[nPos,2]))
        If cStatus  == "FINISHED" .Or. cStatus  == "PROCESSING" ;
            .Or. cStatus  $ "PENDING" .Or. cStatus $ "INTRANSIT"  .Or. cStatus $ "PENDINGISSUE"
            nPos    := aScan( ARET , {|X| X[1] == "SHIPPINGID" })
            If nPos > 0 
                cRet    := cValToChar(aRet[nPos,2])
                If Empty(cRet) .Or. AllTrim(cRet) == '0'
                    lRet:= .F.
                    cRet:= ""
                Else
                    lRet    := .T. 
                EndIf

                //--- Atualiza DTR_PRCTRA
                If lRet .And. !Empty(cRet) 
                    nPos    := aScan( ARET , {|X| X[1] == "CIOT" })
                    If nPos > 0 
                        cCIOT    := cValToChar(aRet[nPos,2])
                    EndIf 

                    AtuPrcDTR(cFilOri,cViagem,cRet,cCIOT,.F.)
                    lShipID:= .T.
                EndIf
            EndIf

            If !lRet .And. ( cStatus == "PENDING" .Or. cStatus == "PENDINGISSUE" .Or. cStatus == "PROCESSING" )
                lRet        := .F. 
                cPending    := "Status: "  + cStatus   
            EndIf 
        ElseIf cStatus == "CANCELLED"
            lRet    := .F. 
            AtuPrcDTR(cFilOri,cViagem,,,.T.)
        ElseIf cStatus == "ERROR"
            nPos    := aScan( ARET , {|X| X[1] == "ERRORS" })
            If nPos > 0 
                aError  := aClone(aRet[nPos,2])

                For nCount := 1 To Len(aError)
                    cRet  += AllTrim( DecodeUtf8( aError[nCount]:Message ) ) + chr(10) + chr(13)
                    AAdd( aRetErr, AllTrim( DecodeUtf8( aError[nCount]:Message ) ) )
                Next nCount 

                lRet    := .F. 
            EndIf 
        EndIf 
    EndIf  
	
    If nSleep > 0 
        If !lRet 
            Sleep( nSleep ) 
            nSleep:= 0
        EndIf
    EndIf

    nTryMax++ 
    FWFreeArray(aRet)    
EndDo 

If lRet 
    //--- Se não executou o sleep na primeira consulta, libera o tempo para a proxima consulta (CIOT)
    nSegRest:= nSleep 
Else 
    If !Empty(cPending)
        cRet    := cPending
        AAdd( aRetErr, AllTrim(cPending) )
    EndIf 
EndIf 

//---- Não retornou o Nro do Processo
If lAtuDTR .And. !lShipID
    lRet:= .F.
EndIf

oRepom:Destroy()
FwFreeObj(oRepom)
RestArea( aAreaDTR )
RestArea( aArea )
Return { lRet , cRet, aRetErr}

//-----------------------------------------------------------------
/*/{Protheus.doc} AtuPrcDTR
Atualiza DTR_PRCTRA

@param      cFilOri, cViagem
@author     Caio Murakami
@since      06/11/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------
Function AtuPrcDTR(cFilOri,cViagem,cShippID,cCIOT,lCancela)
Local lRet      := .T. 
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())
Local cChave    := ""
Local lTabDM5   := AliasIndic("DM5")

Default cFilOri     := ""
Default cViagem     := ""
Default cShippID    := ""
Default cCIOT       := ""
Default lCancela    := .F.  //Executado pelo Cancela Contrato (Menu Viagem/Alteração Viagem)

DTR->(dbSetOrder(1))
cChave := xFilial("DTR") + cFilOri + cViagem 
If DTR->(dbSeek( cChave ))
    While DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == cChave
        RecLock("DTR",.F.)
        If !lCancela
            If !Empty(cShippID)
                DTR->DTR_PRCTRA := RTrim(cShippID)
            EndIf

            If !Empty(cCIOT)
                DTR->DTR_CIOT:=  cCIOT
            EndIf
        Else            
            DTR->DTR_PRCTRA := CriaVar('DTR_PRCTRA')
            DTR->DTR_CIOT   := CriaVar("DTR_CIOT")
        EndIf

        DTR->(MsUnlock())

        DTR->(dbSkip())
    EndDo
EndIf

//-- Atualizada dados da viagem Modelo 3
If lTabDM5 
    If (!lCancela .And. !Empty(cShippID)) .Or. lCancela
        TM15AtuDM5(cFilOri,cViagem,RTrim(cShippID))
    EndIf    
EndIf

//-- Atualizada dados do Contrato de Carreteiro
If (!lCancela .And. !Empty(cShippID)) .Or. lCancela
    TM15AtuDTY(cFilOri,cViagem,RTrim(cShippID))
EndIf

RestArea(aAreaDTR)
RestArea(aArea)
Return lRet 

//--------------------------------------------------------------------------
/*/{Protheus.doc} TM15StaPrc  
Função que retorna o Dados do Contrato na Repom
/Shipping/StatusProcessing/ByIdentifier
@author Katia
@since 04/11/2020
@version 2.2
@Param  cFilOri, cViagem
@return aRetShip
/*/
//---------------------------------------------------------------------------
Function TM15StaPrc(cFilOri,cViagem)  
Local aRetShip:= {}
Local aAreaDTR:= DTR->(GetArea())
Local oRepom  := Nil

Default cFilOri:= ""
Default cViagem:= ""

DTR->(DbSetOrder(1)) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
	If DTR->DTR_CODOPE == '01' .And. !Empty(DTR->DTR_PRCTRA)
		oRepom:= TMSBCARepomFrete():New()
   		oRepom:Auth()
		
		aRetShip:= oRepom:GetShipByShip( cFilOri , cViagem )
		
		oRepom:Destroy()
		FwFreeObj(oRepom)
	EndIf
EndIf

RestArea(aAreaDTR)
Return aRetShip


//--------------------------------------------------------------------------
/*/{Protheus.doc} RepStaShip
Função que retorna o Status do Contrato na Repom
/Shipping/StatusProcessing/ByIdentifier
@author Katia
@since 04/11/2020
@version 2.2
@Param  aRetShip
@return cStatus
/*/
//---------------------------------------------------------------------------
Function RepStaShip(aRetShip)  
Local cStatus:= ""
Local nPos   := 0

Default aRetShip:= {}

If Len(aRetShip) > 0
    nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("STATUS"))} )
    If nPos > 0
	    cStatus:= aRetShip[nPos][2]
    EndIf
EndIf

Return cStatus

//--------------------------------------------------------------------------
/*/{Protheus.doc} TM15MovPrc
Função que retorna os Movimentos do Contrato
/Shipping/StatusProcessing/ByIdentifier
@author Katia
@since 04/11/2020
@version 2.2
@type function
@Param   aRetShip array
@return array array
/*/
//---------------------------------------------------------------------------
Function TM15MovPrc(aRetShip) 
Local cImpostos := "1|2|3|34"  //1- IRRF, 2- SEST, 3- SENAT, 34- INSS, 
Local cAdiantam := "131"  //PENDENTE VERIFICAR COM REPOM
//Local cMovTxCar := "118" //-- Taxa de desconto por troca de cartão pelo motorista //PENDENTE VERIFICAR COM REPOM
//Local cMovDescon:= '6'
Local cCodIdent := ""
Local cDesIdent := ""
Local cTxBan    := "119" //-- 119 - Tx Ativacao Debito
Local nValIdent := 0
Local nPos      := 0
Local nX        := 0
Local nSaldoRep := 0
Local aRetOpe   := {}
Local nMovType  := 0

Default aRetShip   := {}

If Len(aRetShip) > 0
	aRetOpe    := Array(4)
	aRetOpe[1] := aRetShip[18][2]	 //-- [1] Status Repom
	aRetOpe[2] := {}	             //-- [2] Array Movtos
	aRetOpe[3] := 0	                 //-- [3] Valor Saldo Repom
	aRetOpe[4] := 0	                 //-- [4] Valor Complementares Repom

	//----- Carrega o aRetOpe[2] Movtos
	nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("ACCOUNTINGADJUSTMENTS")) })
	If nPos > 0
		For nX:=1 To Len(aRetShip[nPos][2])
            nMovType  = aRetShip[nPos][2][nX]:MovementType //Movimentos 1-Repom, 2- Cliente (TMS)

            If nMovType == 1
                cCodIdent:= aRetShip[nPos][2][nX]:Identifier
                cDesIdent= aRetShip[nPos][2][nX]:Description
                cTypeIdent= aRetShip[nPos][2][nX]:AdjustmentType //"Credit" / "Debit"
                nValIdent:= abs(aRetShip[nPos][2][nX]:Value)
                            
                //--- Seleciona somente os  Impostos e Tx. Bancária
                //1- IRRF, 2- SEST, 3- SENAT, 34- INSS
                If cCodIdent $ cImpostos .Or. cCodIdent $ cTxBan
                    nPos1:= Ascan(aRetOpe[nPos], { |x| x[1]  == cCodIdent })
                    If nPos1 > 0
                        aRetOpe[nPos][nPos1][2]+= nValIdent
                    Else
                        aAdd(aRetOpe[2],{ cCodIdent, nValIdent, cDesIdent })
                    EndIf
                EndIf
            EndIf

		Next nX        
	EndIf

	//--- Adiantamento
	nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("ADVANCEMONEYVALUE"))} )
	If nPos > 0
		nAdtoRep:= aRetShip[nPos][2]

		//Pendente Verificar REPOM o Codigo para Adiantamento
		aAdd(aRetOpe[2],{ cAdiantam, nAdtoRep, 'ADIANTAMENTO' })
	EndIf

	//--- Saldo disponivel na Repom
	nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("TOTALFREIGHTVALUE"))} )
	If nPos > 0
		nSaldoRep := aRetShip[nPos][2]
		aRetOpe[3]:= nSaldoRep  
	EndIf
EndIf

Return aRetOpe

//--------------------------------------------------------------------------
/*/{Protheus.doc} TM15ChkSta //RepVldStCt
Funcao que Valida o Status do Contrato na Operadora de Frotas
@author Katia
@since 05/11/2020
@version 2.2
/*/
//---------------------------------------------------------------------------
Function TM15ChkSta(cStaShip,aMsgErr,cFilOri,cViagem)
Local lRet:= .T.
Local cStatus:= 'INTRANSIT'

Default cStaShip:= ""  //Status Shipping
Default cFilOri := ""
Default cViagem := ""

	If !(Upper(cStaShip) $ Upper(AllTrim(cStatus)))  //-- diferente de "Em Transito"
		Aadd( aMsgErr,{'Viagem ' + cFilOri+"/"+cViagem + "possui integração com a Repom e o contrato não encontra-se em " + cStatus + " na Operadora!" ,"01",""})
		Aadd( aMsgErr,{"Entre em contato com a Repom","01",""})
		Aadd( aMsgErr,{"Status Repom: " + AllToChar(cStaShip)  ,"01",""}) //--"Status Esperado: 'INTRANSIT'
		lRet := .F.
	Else
		lRet := .T.
	EndIf


Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15AtuDM5
Atualiza DM5_PRCTRA

@param      cFilOri, cViagem
@author     Katia
@since      06/11/2020
@version    2.2
@return     Nil
/*/
//--------------------------------------------------------------------
Function TM15AtuDM5(cFilOri,cViagem,cShippID)
Local aAreaDM5  := DM5->(GetArea())
Local cChave    := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cShippID    := CriaVar('DM5_PRCTRA')

DM5->(dbSetOrder(1))
cChave := xFilial("DM5") + cFilOri + cViagem 
If DM5->(dbSeek( cChave ))
    RecLock("DM5",.F.)
    DM5->DM5_PRCTRA:= cShippID
    DM5->(MsUnlock())
EndIf

RestArea(aAreaDM5)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15VlShip
Valida a inclusao do contrato na REPOM (ShippingCreate)
Caso existir o contrato, atualizara somente Nro Processo e CIOT.
@param      cFilOri, cViagem
@author     Katia
@since      10/11/2020
@version    2.2
/*/
//------------------------------------------------------------------
Function TM15VlShip(cFilOri, cViagem, lAtualiza, lExiste)
Local lShipId       := .F.
Local cStatus       := ""
Local cShippingId   := ""
Local cCIOT         := ""
Local oRepom        := Nil
Local aRet          := {} 
Local nPos          := 0 

Default cFilOri  := ""
Default cViagem  := ""
Default lAtualiza:= .F.
Default lExiste  := .F. 

aRet:= TM15GtById(cFilOri,cViagem)  
If Len(aRet) > 0
    cStatus    := aRet[1]  
    cShippingId:= aRet[2]  
    cCIOT      := aRet[3]
EndIf

If Empty(cStatus) .Or. Upper(AllTrim(cStatus)) == 'PENDINGCANCELLATION' .Or. Upper(AllTrim(cStatus)) == 'CANCELLED' 
    lShipId     := .F.     //Não tem ShippingID valido
    lExiste    := .F. 
Else
    //----Se encontrou o Contrato ativo, atualiza dados do contrato na DTR e DM5.
    If !Empty(cShippingId) .Or. !Empty(cCIOT)  
        If lAtualiza
            AtuPrcDTR(cFilOri,cViagem,cShippingId,cCIOT)
        EndIf
        If !Empty(cShippingId) .And. !Empty(cCIOT) 
            lShipId:= .T.     //Utilizado para efetuar o Fechamento da Viagem
        EndIf
    EndIf
     lExiste    := .T. 
EndIf

If !lExiste
    aRet    := {} 
    oRepom  := TMSBCARepomFrete():New()
    oRepom:Auth()
    aRet    := oRepom:GetShipStPrcBy( cFilOri , cViagem ) 
    nPos        := aScan(aRet,{|x| x[1] == "STATUS" }) 

    If nPos > 0
        cStatus := Upper(AllTrim(aRet[nPos,2]))
        If cStatus  == "PROCESSING" .Or. cStatus  $ "PENDING" .Or. cStatus $ "INTRANSIT"
            lExiste := .T. 
        EndIf 
    EndIf 

EndIf 

Return lShipId

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15GtById
Retorna informações do contrato da Repom a partir da Viagem
@param      cFilOri, cViagem
@author     Katia
@since      10/11/2020
@version    2.2
@Return    {Status, ShippingId, CIOT}
/*/
//------------------------------------------------------------------
Function TM15GtById(cFilOri, cViagem)  
Local oRepom      := Nil
Local aRetShip    := {}
Local aRet        := {}   //Status,ShippingId,CIOT
Local nPos        := 0
Local cStatus     := ""
Local cShippingId := ""
Local cCIOT       := ""
Local cCIOTCont     := ""

Default cFilOri:= ""
Default cViagem:= ""

oRepom := TMSBCARepomFrete():New()
If oRepom:Auth()

    aRetShip:= oRepom:GetShipById( cFilOri , cViagem )  

    If Len(aRetShip) > 0
        nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("STATUS"))} )
        If nPos > 0
            cStatus:= aRetShip[nPos][2]
        EndIf

        nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("SHIPPINGID"))} )
        If nPos > 0
            cShippingId:= cValToChar(aRetShip[nPos,2])
        EndIf

        nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("CIOT"))} )
        If nPos > 0
            cCIOT:= aRetShip[nPos][2]
        EndIf

        nPos:= Ascan(aRetShip, { |x| x[1]  == UPPER(AllTrim("CIOTINCONTINGENCY"))} )
        If nPos > 0
            If ValType( aRetShip[nPos][2] ) == "N"
                cCIOTCont   := cValToChar( aRetShip[nPos][2] )
            EndIf 
        EndIf

        Aadd(aRet, cStatus   )
        Aadd(aRet, RTrim(cShippingId))
        Aadd(aRet, cCIOT      )
        Aadd(aRet, cCIOTCont )
    EndIf

    oRepom:Destroy()
EndIf

FwFreeObj(oRepom)
FWFreeArray(aRetShip)
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMS15Ciot
Realiza GET para obter o CIOT

@param      cFilOri, cViagem
@author     Caio Murakami
@since      05/11/2020
@version    1.0
@return     lRepom
/*/
//--------------------------------------------------------------------
Function TMS15Ciot( cFilOri , cViagem , lAtuDTR , nSegRest )
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())
Local oRepom    := Nil
Local aRet      := {} 
Local lRet      := .T.
Local nPos      := 0 
Local cStatus   := ""
Local cRet      := ""
Local nTryMax   := 0 
Local aError    := {} 
Local nCount    := 1 
Local nSleep    := TM15TmpEsp()   //Tempo maximo de Espera

Default cFilOri     := ""
Default cViagem     := ""
Default lAtuDTR     := .T. 
Default nSegRest	:= nSleep

oRepom  := TMSBCARepomFrete():New()
oRepom:Auth()

While Empty(cRet)  .And. nTryMax <= 1  .And. Len(aError) == 0 
    aRet    := {}
    aRet    := oRepom:GetShipById( cFilOri , cViagem ) 

    nPos    := aScan(aRet,{|x| x[1] == "STATUS" }) 

    If nPos > 0 
        cStatus := Upper(AllTrim(aRet[nPos,2]))
                  
        If cStatus == "ERROR"
            nPos    := aScan( ARET , {|X| X[1] == "ERRORS" })
            If nPos > 0 
                aError  := aClone(aRet[nPos,2])

                For nCount := 1 To Len(aError)
                    cRet  += AllTrim( DecodeUtf8( aError[1]:Message ) ) + chr(10) + chr(13)
                Next nCount 

                Help(" ",1,"TMSAC15A000001",,cRet)  //-- Ocorreu um erro na integração com a REPOM.
                lRet    := .F. 
            EndIf 
        Else
            //--- CIOT
            nPos    := aScan( ARET , {|X| X[1] == "CIOT" })            
            If nPos > 0 
                cRet    := cValToChar(aRet[nPos,2])
                If Empty(cRet) .Or. AllTrim(cRet) == '0'
                    lRet:= .F.
                    cRet:= ""                   
                Else
                    lRet    := .T. 
                EndIf

                //--- Atualiza DTR_CIOT
                If lRet .And. !Empty(cRet) 
                    AtuPrcDTR(cFilOri,cViagem,'',cRet)
                EndIf
            EndIf
        EndIf        
    EndIf  

    If !lRet
        If nSegRest > 0            
            Sleep(nSegRest)
            nSegRest:= 0
        EndIf
    EndIf 

    nTryMax++
    FWFreeArray(aRet)    
          
EndDo 

If !lRet 
      If cStatus == "PENDING" .Or. cStatus == "PENDINGISSUE" .Or. cStatus == "PROCESSING"
        cRet    := "Status: "  + cStatus
    EndIf 
EndIf 

oRepom:Destroy()
FwFreeObj(oRepom)
RestArea( aAreaDTR )
RestArea( aArea )
Return { lRet , cRet }

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15CFGREP()
Retorna configuração do campo 
(Contrato/Quitacao/Autorizacao)
@param      cCampo
@author     Katia
@since      16/11/2020
@version    1.0
@return     cRet
/*/
//--------------------------------------------------------------------
Function TM15CFGREP(cCampo)
Local cRet:= ""

DbSelectArea("DEG")
DEG->( DbSetOrder( 1 ) )
If DEG->( DbSeek( xFilial( "DEG" ) + "01" ) )
    cRet:= DEG->&(cCampo)
EndIf

Return AllTrim(cRet)

//--------------------------------------------------------------------------
/*/{Protheus.doc} TM15ChkPag
Função que valida o Status do Contrato para Autorização de Pagamento e ou
Estorno da Quitação ou Estorno da Autorização de Pagamento.
Cleared - Utilizado quando na Repom esta habilitado o Agendamento de Pgto
@author Katia
@since 18/11/2020
@version 2.2
/*/
//---------------------------------------------------------------------------
Function TM15ChkPag(cFilOri,cViagem, nOpc , lPaid )  
Local lRet       := .F.
Local cStaShip   := ""
Local aRetShip   := {}

Default cFilOri := ""
Default cViagem := ""
Default nOpc    := 3 
Default lPaid   := .F. 

aRetShip:= TM15GtById(cFilOri,cViagem) 

If nOpc == 3 

    If Len(aRetShip) > 0
        cStaShip:= Upper(AllTrim(aRetShip[1])) 
        lRet    := cStaShip == "CLEARED"    

        If !lRet .And. lPaid
             lRet    := cStaShip == "PAID"
        EndIf 

    EndIf
ElseIf nOpc == 5 
    If Len(aRetShip) > 0
        cStaShip:= Upper(AllTrim(aRetShip[1])) 
        lRet    := cStaShip <> "CLEARED"  .And.  cStaShip <> "PAID" 
    EndIf
EndIf 

FWFreeArray(aRetShip)
Return lRet

/*{Protheus.doc} TMSC15ARep
REPOM
@type Function
@author Caio Murakami
@since 17/11/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSC15ARep( nOpc , cFilOri , cViagem, lMostraMsg, cCodVei, lFechto  )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local oRepom	:= Nil 
Local aRet		:= {} 
Local aExibe	:= {}
Local cAux		:= ""
Local nCount	:= 1 
Local cObs		:= ""
Local lExiste   := .F. 
Local nPos      := 0 
Local aAux      := {} 
Local aObj      := {} 
Local nAux      := 1 
Local nNames    := 1 
Local aNames    := {} 
Local cJson     := "" 

Default nOpc	  := 1 
Default cFilOri   := DTQ->DTQ_FILORI
Default cViagem	  := DTQ->DTQ_VIAGEM
Default lMostraMsg:= .T.
Default cCodVei   := ""
Default lFechto   := .F.   //Processo pelo Fechamento da Viagem

If lRestRepom
    DTR->(dbSetOrder(1))
    If DTR->( MsSeek( xFilial("DTR") + cFilOri + cViagem )) .And. DTR->DTR_CODOPE == "01" //-- repom
        If nOpc == 1 	//-- Gera Contrato
            TM15VlShip(cFilOri,cViagem,.T. , @lExiste)  

            If !lExiste
                oRepom  := TMSBCARepomFrete():New()
                If oRepom:Auth()
                    FwMsgRun( ,{|| lRet	:= oRepom:ShippingCreate(cFilOri,cViagem) } ,STR0009 , STR0009 ) //-- "Comunicação REPOM"
                EndIf
            EndIf 
        ElseIf nOpc == 2 //-- Atualiza Status
            FwMsgRun( ,{|| TM15VlShip( cFilOri , cViagem , .T. ) } ,STR0009 , STR0009 ) //-- "Comunicação REPOM"
        ElseIf nOpc == 3 //-- Consulta Status
            oRepom  := TMSBCARepomFrete():New()
            If oRepom:Auth()
                lRet	:= .T. 
                        
                If Empty(DTR->DTR_PRCTRA)
                    FwMsgRun( ,{|| aRet	:= oRepom:GetShipStPrcBy(cFilOri,cViagem  ) } ,STR0009 , STR0009 )
                Else
                    FwMsgRun( ,{|| aRet	:= oRepom:GetShipById(cFilOri,cViagem  ) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
                EndIf 

                If Len(aRet) > 0 
                    For nCount := 1 To Len(aRet)
                        If Len(aRet[nCount]) == 2 .And. ValType(  aRet[nCount][1] ) == "C" .And.  ( ValType(  aRet[nCount][2] ) == "C" .Or. ValType(  aRet[nCount][2] ) == "N" )
                            If ValType(  aRet[nCount][2] ) == "N"
                                cAux	:= cValToChar( aRet[nCount][2]  )
                            Else
                                cAux	:= RTrim(aRet[nCount][2])
                            EndIf 
                            Aadd( aExibe , { RTrim(aRet[nCount][1]) + ": " + DecodeUtf8(cAux) })
                        ElseIf Len(aRet[nCount]) == 2 .And. ValType(  aRet[nCount][1] ) == "C" .And.  ( ValType(  aRet[nCount][2] ) == "A"  )

                            Aadd( aExibe , { RTrim(aRet[nCount][1]) })
                            aObj    := AClone(  aRet[nCount][2]  )
                            
                            For nAux := 1  To Len(aObj)
                                If Len(aObj[nAux]) == 2 .And. ValType(  aObj[nAux][1] ) == "C" .And.  ( ValType(  aObj[nAux][2] ) == "C" .Or. ValType(  aObj[nAux][2] ) == "N" )
                                    If ValType(  aObj[nAux][2] ) == "N"
                                        cAux	:= cValToChar( aObj[nAux][2]  )
                                    Else
                                        cAux	:= RTrim(aObj[nAux][2])
                                    EndIf 
                                    Aadd( aExibe , { RTrim(aObj[nAux][1]) + ": " + DecodeUtf8(cAux) })
                                ElseIf ValType(  aObj[nAux] ) == "J"

                                    aNames  := aObj[nAux]:GetNames()

                                    For nNames := 1 To Len(aNames)
                                        cAux    := ""
                                        If ValType(aObj[nAux][aNames[nNames]]) == "N"
                                            cAux	:= cValToChar( aObj[nAux][aNames[nNames]] )
                                        ElseIf ValType(aObj[nAux][aNames[nNames]]) == "C"
                                            cAux	:= RTrim( aObj[nAux][aNames[nNames]] )
                                        EndIf 
                                        Aadd( aExibe , { "     - " + RTrim(aNames[nNames]) + ": " + RTrim(cAux)  })
                                    Next nNames

                                ElseIf Len(aObj[nAux] )== 1 .And. ValType(  aObj[nAux][1] ) == "C"
                                    Aadd( aExibe , { aObj[nAux][1] })
                                EndIf 
                            Next nAux 

                        ElseIf Len(aRet[nCount] )== 1 .And. ValType(  aRet[nCount][1] ) == "C"
                            Aadd( aExibe , { aRet[nCount][1] })
                        EndIF  
                    Next nCount 

                    TMultiGet(aExibe)
                    
                EndIf 
            EndIf 
        ElseIf nOpc == 4  //-- Interrompe Contrato
            
            lRet    := TM15Interr( cFilOri , cViagem )
            
        ElseIf nOpc == 5 //-- Bloqueia Contrato
            oRepom  := TMSBCARepomFrete():New()
            If oRepom:Auth()
                lRet	:= .T. 
                cObs	:= "Lock - " + FunName() + " " + __cUserId + " " + DToS(dDataBase) + " " + Time()
                FwMsgRun( ,{|| lRet	:= oRepom:ShippingLock(cFilOri,cViagem,,.T.,cObs) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"

                If lRet
                    MsgInfo(STR0010 + " " + cObs) //-- Operação realizada com sucesso
                EndIf 

            EndIf
        ElseIf nOpc == 6 //-- Desbloqueia Contrato
            oRepom  := TMSBCARepomFrete():New()
            If oRepom:Auth()
                lRet	:= .T. 
                FwMsgRun( ,{|| lRet	:= oRepom:ShippingLock(cFilOri,cViagem,,.F.) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"

                If lRet
                    MsgInfo(STR0010)
                EndIf 
            EndIf
        ElseIf nOpc == 7 //-- Cancela Contrato
            If !lFechto //Executado pelo opção do Menu Viagem ou Alteração da Viagem
                lRet:= TM15StaVge(cFilOri,cViagem,nOpc)            
            EndIf

            If lRet
                TM15VlShip(cFilOri,cViagem,.T. , @lExiste)  
            EndIf

            If lExiste
                oRepom  := TMSBCARepomFrete():New()
                If oRepom:Auth()
                    lRet	:= .T. 
                    FwMsgRun( ,{|| lRet	:= oRepom:ShippingCancel(cFilOri,cViagem) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"

                    If lRet .And. !lFechto
                        //--- Atualiza DTR/DM5 e DTY
                        AtuPrcDTR(cFilOri,cViagem,"","",.T.)
                        If lMostraMsg
                            MsgInfo(STR0010)
                        EndIf
                    EndIf 
                EndIf
            EndIf 

        ElseIf nOpc == 8  //-- Quitacao 
            lRet    := .F. 
            oRepom  := TMSBCARepomFrete():New()
            If oRepom:Auth()
                lRet	:= .T. 
                FwMsgRun( ,{|| lRet	:= oRepom:PaymentCreate(cFilOri,cViagem) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
            EndIf    
        ElseIf nOpc == 9  //-- Cancela Quitação

            FwMsgRun( ,{|| aRet:= TM15GtById(cFilOri, cViagem, .F.) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
            If Len(aRet) > 0
                If (Upper(AllTrim(aRet[1])) $ "CLEARED|PAID|ACCOUNTABILITY")  
                    lExiste := .T. 
                ElseIf (Upper(AllTrim(aRet[1])) $ "INTERRUPTED") 
                    lExiste := .F. 
                    lRet    := .T. 
                EndIf 
            EndIf

            If lExiste
                oRepom  := TMSBCARepomFrete():New()
                If oRepom:Auth()
                    lRet	:= .T. 
                    FwMsgRun( ,{|| lRet	:= oRepom:PaymentCancel(cFilOri,cViagem) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
                EndIf    
            EndIf 

        ElseIf nOpc == 10  //-- Verifica se o Contrato está Quitado
            FwMsgRun( ,{|| aRet:= TM15GtById(cFilOri, cViagem, .F.) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
            If Len(aRet) > 0
                lRet:= (Upper(AllTrim(aRet[1])) $ "PAID|CLEARED|ACCOUNTABILITY|INTERRUPTED")  //Pago,Quitado,Prestado Contas
            EndIf

        ElseIf nOpc == 11  //-- Autoriza Pagamento - Somente quando utiliza o Agendamento de Pagamento na REPOM
            lRet:= TM15ChkPag(cFilOri, cViagem)  //status = Cleared
            If lRet
                oRepom  := TMSBCARepomFrete():New()
                If oRepom:Auth()
                    FwMsgRun( ,{|| lRet	:= oRepom:AuthorizationCreate(cFilOri,cViagem,cCodVei) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
                EndIf
            EndIf    
        ElseIf nOpc == 12 
            FwMsgRun( ,{|| TMSAC16A( cFilOri , cViagem ) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
        ElseIf nOpc == 13 
            oRepom  := TMSBCARepomFrete():New()
            If oRepom:Auth()
                lRet	:= .T. 
                FwMsgRun( ,{|| aRet	:= oRepom:GetShipById(cFilOri,cViagem) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
               
                If Len(aRet) > 0 
                    nPos    := ASCAN( ARET , {|X| X[1] == "SHIPPINGPAYMENT"})

                    If nPos > 0 
                        aAux    := aRet[nPos]
                    EndIf 

                    If Len(aAux) > 0 

                        For nCount := 1 To Len(aAux)
                            If ValType(  aAux[nCount] ) == "C" 
                                Aadd( aExibe , { RTrim(  aAux[nCount] ) })
                            ElseIf ValType(  aAux[nCount] ) == "J" 
                                Aadd( aExibe , { RTrim( "DELIVERYDATE" + ": " + aAux[nCount]["DELIVERYDATE"] ) })
                                Aadd( aExibe , { RTrim( "DELIVERYLOCATIONNAME" + ": " + aAux[nCount]["DELIVERYLOCATIONNAME"] ) })
                                Aadd( aExibe , { RTrim( "DELIVERYLOCATIONUSER" + ": " + aAux[nCount]["DELIVERYLOCATIONUSER"] ) })
                                Aadd( aExibe , { RTrim( "DELIVERYLOCATIONTYPE" + ": " + aAux[nCount]["DELIVERYLOCATIONTYPE"] ) })
                                Aadd( aExibe , { RTrim( "EXPECTEDDELIVERYDATE" + ": " + aAux[nCount]["EXPECTEDDELIVERYDATE"] ) })
                                Aadd( aExibe , { RTrim( "EXPECTEDDELIVERYLOCATIONTYPE" + ": " + aAux[nCount]["EXPECTEDDELIVERYLOCATIONTYPE"] ) })
                            EndIf      
                        Next nCount 
                    EndIf 
                   
                    lRet    := TmsMsgErr( aExibe )
                EndIf 
            EndIf 
        ElseIf nOpc == 14 
            TM15VlShip(cFilOri,cViagem,.T. , @lExiste)  

            If lExiste
                TM15AddTax( cFilOri , cViagem )
            Else 
                HELP(" ",1,"REGNOIS")
            EndIf 
        EndIf

        If nOpc <> 2 .And. oRepom <> Nil 
            oRepom:Destroy()
            oRepom  := nIL 
            FwFreeObj(oRepom)
        EndIf
    EndIf 
EndIf 

RestArea(aArea)
Return lRet

/*/{Protheus.doc}  TM15AddTax 
    Adiciona taxas
    @type  Function
    @author CAio Murakami
    @since 07/05/2021
    @version 1.0
    @param cfilori, character , filial de origem
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TM15AddTax( cFilOri , cViagem , cNumCtc , lEstorno  )
Local aArea     := GetArea()
Local aAreaDTY  := DTY->( GetArea() )
Local oRepom    := Nil 
Local cImpCTC 	:= SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
Local lRet      := .T. 
Local cCodVei   := "" 
Local lSoma     := .F. 
Local nValSest  := 0 
Local nValSenat := 0 
Local nValInss  := 0
Local nValIRRF  := 0 

Default cFilOri     := ""
Default cViagem     := ""
Default cNumCtc     := ""
Default lEstorno    := .F. 

If lRestRepom .And. cImpCTC == "0" //.And.  TM15CFGREP('DEG_REPQUI') == "1" //-- 1=Contrato de Carreteiro
  
    DTY->( dbSetOrder(2) )
    If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem ))

        While DTY->(!Eof()) .And. DTY->( DTY_FILIAL + DTY_FILORI + DTY_VIAGEM ) == xFilial("DTY") + cFilOri + cViagem
            
            lSoma   := .F. 

            If !Empty(cNumCtc)
                If RTrim(DTY->DTY_NUMCTC) == RTrim(cNumCtc)
                    If lEstorno 
                        lSoma   := .F. 
                    Else
                        lSoma   := .T. 
                    EndIf 
                Else 
                    lSoma   := .T. 
                EndIf 
            Else
                lSoma   := .T. 
            EndIf 

            If lSoma
                nValSest    += DTY->DTY_SEST
                nValSenat   += 0
                nValInss    += DTY->DTY_INSS
                nValIRRF    += DTY->DTY_IRRF
                cCodVei     := DTY->DTY_CODVEI 
            EndIf 

            DTY->(dbSkip())
        EndDo
        
        oRepom  := TMSBCARepomFrete():New()
        If oRepom:Auth()
            lRet	:= oRepom:ShippingAddTax( cFilOri , cViagem , cCodVei , nValSEST , nValSENAT , nValINSS, nValIRRF )
        EndIf 

    EndIf 
EndIf 

RestArea( aAreaDTY )
RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Função para validar o Veiculo na Operadora (V2.2.)
@type Function
@author Katia
@since 19/11/2020
@version 12.1.31
@param cCodVei
@return lRet
*/
//-------------------------------------------------------------------
Function TM15VldVei(cCodVei,aMsgErr)
Local lRet    := .T.
Local aRet     := {}
Local nPos     := 0
Local oRepom   := Nil
Local cMsgError:= ""

Default cCodVei := ""

If !Empty(cCodVei)
	oRepom := TMSBCARepomFrete():New()
	oRepom:Auth()

	aRet:= oRepom:GetShipVeicVld(cCodVei)
    If Len(aRet) > 0
        nPos:= aScan (aRet, { |x| x[1] == 'VEHICLES' }) 
        If nPos > 0
            If aRet[nPos][2][1] <> Nil
                lRet:= aRet[nPos][2][1]:VALIDATE   
            
                If !lRet
                    If aRet[nPos][2][1]:MESSAGEERROR <> Nil
                        cMsgError:= aRet[nPos][2][1]:MESSAGEERROR 
                        cMsgError:= DecodeUTF8(cMsgError)
                    Else  
                        Aadd( aMsgErr,{STR0013 + " " + "/ShippingValidation/ByVehicles/","01",""})  //Erro Validação
                        cMsgError:= STR0011 + " " + DecodeUTF8(aRet[nPos][2][1]:LICENSEPLATE) + " " +   STR0012 //"Placa:"" "Consulte Repom/ANTT para maiores informações"
                    EndIf
                    Aadd( aMsgErr,{cMsgError,"01",""})
                EndIf
            Else
                Aadd( aMsgErr,{STR0013 + " " + "/ShippingValidation/ByVehicles/","01",""})  //Erro Validação
                lRet:= .F.
            EndIf


        EndIf
    EndIf

	oRepom:Destroy()
    FwFreeObj(oRepom)
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Função para validar o Documento do Fornecedor 
@type Function
@author Katia
@since 19/11/2020
@version 12.1.31
@param cCodFor, cLojFor
@return lRet
*/
//-------------------------------------------------------------------
Function TM15VldHir(cCodFor,cLojFor,aMsgErr)
Local lRet      := .F.
Local aRet      := {}
Local nPos      := 0
Local oRepom    := Nil
Local cMsgError := ""

Default cCodFor := ""
Default cLojFor := ""

If  !Empty(cCodFor) .And. !Empty(cLojFor)
	oRepom := TMSBCARepomFrete():New()
	If oRepom:Auth()
        aRet:= oRepom:GetShipHiredVld(cCodFor,cLojFor)
        If Len(aRet) > 0
            nPos:= aScan (aRet, { |x| x[1] == 'HIREDVALIDATE' }) 
            If nPos > 0
                lRet:= aRet[nPos][2]
                If !lRet 
                    cMsgError:= DecodeUtf8( aRet[nPos][3] )
                    Aadd( aMsgErr,{cMsgError,"01",""})
                EndIf
            EndIf
        EndIf
    EndIf
	oRepom:Destroy()
    FwFreeObj(oRepom)
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Função que Retorna as Operações da REPOM
@type Function
@author Katia
@since 20/11/2020
@version 12.1.31
@param  Nil
@return aRet (Codigo,Descrição)
*/
//-------------------------------------------------------------------
Function TM15GetOpe()
Local aRet   := {}
Local aRetOpe:= {}
Local oRepom := Nil
Local nPos   := 0
Local nX     := 0
Local cCodOpe:= ""
Local cDesOpe:= ""

oRepom := TMSBCARepomFrete():New()
If oRepom:Auth()
	aRetOPe:= oRepom:GetOperation()

	For nX:= 1 To Len(aRetOPe)
		nPos:= AScan(aRetOPe[nX], {|x| AllTrim(x[1]) == AllTrim("OPERATIONIDENTIFIER")})
		If nPos > 0
			cCodOpe:= AllTrim(aRetOPe[nX][nPos][2])
		EndIf

		nPos:= AScan(aRetOPe[nX], {|x| AllTrim(x[1]) == AllTrim("NAME")})
		If nPos > 0
			cDesOpe:= AllTrim(aRetOPe[nX][nPos][2])
		EndIf

		AAdd(aRet,{cCodOpe,cDesOpe})
	Next nX

    oRepom:Destroy()
	FwFreeObj(oRepom)
EndIf

Return aRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} TM15TmpEsp
Função para calcular o tempo de espera para o Retorno da Repom
@author Katia
@since 20/11/2020
@version 12.1.31
/*/
//---------------------------------------------------------------------------
Function TM15TmpEsp()
Local aAreaDEG  := DEG->(GetArea())
Local nSleep    := 0

DbSelectArea("DEG")
DEG->( DbSetOrder( 1 ) )

If DEG->( DbSeek( xFilial("DEG") + "01" ) ) 
    nSleep := Val( DEG->DEG_TMPESP )
EndIf    

If nSleep == 0
    nSleep:= 60 //segundos
EndIf

nSleep:= (nSleep * 1000)  // Para o processamento por 1 segundo

RestArea(aAreaDEG)
Return nSleep

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15AtuDTY

Atualiza DTY_IDOPE quando o Contrato de Carreteiro é gerado antes do
Fechamento da Viagem (mv_impctc = 0)

@param      cFilOri, cViagem
@author     Katia
@since      04/02/2021
@version    2.2
@return     Nil
/*/
//--------------------------------------------------------------------
Function TM15AtuDTY(cFilOri,cViagem,cShippID)
Local aAreaDTY  := DTY->(GetArea())
Local cImpCTC 	:= SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
Local cTmsErp   := SuperGetMV("MV_TMSERP",,'0') //  Verifica se o TMS está integrado com o Protheus ou Outro ERP
Local lTMSOPdg  := SuperGetMV('MV_TMSOPDG',,'0') == '2'

Default cFilOri     := ""
Default cViagem     := ""
Default cShippID    := CriaVar('DTY_IDOPE')

If lTMSOPdg .And.  cImpCTC == '0' .And. cTmsErp == '0'
    DTY->( dbSetOrder(2) )
    If DTY->(MsSeek( xFilial("DTY") + cFilOri + cViagem ))
        While DTY->( DTY_FILIAL + DTY_FILORI + DTY_VIAGEM ) ==  xFilial("DTY") + cFilOri + cViagem
            If DTY->DTY_CODOPE == '01'
                RecLock("DTY",.F.)
                DTY->DTY_IDOPE:= cShippID
                DTY->(MsUnlock())
            EndIf
            DTY->(dbSkip())
        EndDo
    EndIf
EndIf

RestArea(aAreaDTY)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15CNTCAR
Verifica se foi gerado o Contrato de Carreteiro para a Viagem
para executar o fechamento da viagem (mv_impctc = 0)
@since      09/02/2021
@version    2.2
@param      cFilOri, cViagem
@return     lRet
/*/
//--------------------------------------------------------------------
Function TM15CNTCAR(cFilOri,cViagem)
Local lRet      := .T.
Local aAreaDTY  := DTY->(GetArea())
Local aAreaDTR  := DTR->(GetArea())
Local aAreaDA3  := DA3->(GetArea())
Local lFrotaProp:= .F.

Default cFilOri:= ""
Default cViagem:= ""

DTR->(DbSetOrder(1)) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
    If DTR->DTR_CODOPE == '01' .And. Empty(DTR->DTR_PRCTRA)    	
        lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
        If !lFrotaProp
            If TM15CFGREP('DEG_REPQUI') == "2"  //-- 2=Encerramento da viagem
                DTY->( dbSetOrder(2) )
                If !DTY->(DbSeek( xFilial("DTY") + cFilOri + cViagem ))
                    lRet:= .F.
                EndIf
            EndIf 
        EndIf
    EndIf
EndIf

RestArea(aAreaDTY)
RestArea(aAreaDTR)
RestArea(aAreaDA3)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15StaVge
Valida o Status da Viagem 
@author     Katia
@since      10/02/2021
@version    2.2
@param      cFilOri, cViagem, nOpc
@return     lRet
/*/
//--------------------------------------------------------------------
Function TM15StaVge(cFilOri,cViagem,nOpc)
Local lRet    := .T.

Default cFilOri:= DTQ->DTQ_FILORI
Default cViagem:= DTQ->DTQ_VIAGEM
Default nOpc   := 0

    If nOpc == 7  //Cancela Contrato, se a viagem estiver Fechada, deve ser executada pelo Estorno do Fechamento
        If DTQ->DTQ_STATUS <> StrZero(1,Len(DTQ->DTQ_STATUS))  //Em Aberto
            Help(,,'HELP',,'O Cancelamento do Contrato deve ser executado pelo Estorno Fechamento da Viagem.',1,0 )
            lRet:= .F.            
        EndIf
    EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15Interr
Interropme Contrato 
@author     Caio Murakami
@since      05/03/2021
@version    2.2
@param      cFilOri, cViagem, nOpc
@return     lRet
@type       function
/*/
//--------------------------------------------------------------------
Function TM15Interr( cFilOri , cViagem )
Local lRet      := .F. 
Local oRepom    := Nil 
Local aMovto    := {} 
Local cBanco    := ""
Local cAgencia  := ""
Local cConta    := ""
Local cCodVei   := ""
Local nValRep   := 0
Local nValBx    := 0 
Local nValAux   := 0 
Local cCodForn  := ""
Local cLojForn  := ""
Local cParcela  := ""
Local cPrefix   := ""
Local aBaixa    := {} 
Local cTipCTC   := Padr("PA",Len( SE2->E2_TIPO ) )
Local cNumSE2   := ""
Local lContinua := .F. 
Local nPos      := 0 
Local cFilSE2   := ""

Private lMSErroAuto := .F. 

Default cFilOri     := ""
Default cViagem     := ""

Begin Transaction 
            
//-- Verifica se possui contrato de carreteiro
DTY->( dbSetOrder(2) )
If DTY->( !MsSeek( xFilial("DTY") + cFilOri + cViagem ))

    //-- "O contrato será interrompido na Repom e o valor de consumo do motorista será consultado para realizarmos a baixa parcial do do adiantamento se houver." 
    //-- "Demais processos devem ser realizados de maneira manual."
    //-- "Deseja interromper essa viagem?"
    If MsgYesNo( STR0015 + " " + STR0016 , STR0014 ) 
        lRet    := .T. 
    EndIf 
    
    If lRet
        oRepom  := TMSBCARepomFrete():New()
        If oRepom:Auth() 
            FwMsgRun( ,{|| aMovto	:= oRepom:GetShipByShip(cFilOri,cViagem) } ,STR0009 , STR0009 )

            If Len(aMovto) > 0 
                nPos    := aScan( aMovto , {|x| x[1] = "CONSUMEDVALUE"})
                If nPos > 0 
                    nValRep     := aMovto[nPos,2]
                    FwMsgRun( ,{|| lRet	:= oRepom:ShippingInter(cFilOri,cViagem) } ,STR0009 , STR0009 )	 //-- "Comunicação REPOM"
                EndIf 
            EndIf 
        EndIf

        If lRet 
            cPrefix     := TMA250GerPrf(cFilOri)
            cNumSE2     := Padr( cViagem ,Len( SE2->E2_NUM ) )
            DEG->(DbSetOrder(1))
            If DEG->(MsSeek(xFilial("DEG")+"01"))
                cBanco  	:= DEG->DEG_BANCO
                cAgencia 	:= DEG->DEG_AGENCI
                cConta		:= DEG->DEG_NUMCON

                DTR->( dbSetOrder(1) )
                If DTR->( MsSeek( xFilial("DTR") + cFilOri + cViagem ))
                    cCodVei     := DTR->DTR_CODVEI 
                    cCodForn    := DTR->DTR_CODFOR
                    cLojForn    := DTR->DTR_LOJFOR
                EndIf 

            EndIf

            DT7->( dbSetOrder(1))
            SDG->( DbSetOrder(5))             //-- numero da sequencia para baixa
            SDG->( DbSeek( xFilial('SDG') + cFilOri + cViagem + cCodVei) )
            While SDG->(!Eof()) .And. SDG->DG_FILIAL == xFilial('SDG') .And. SDG->DG_FILORI == cFilOri .And. SDG->DG_VIAGEM == cViagem
                
                If DT7->( MsSeek( xFilial("DT7") + SDG->DG_CODDES )) .And. DT7->DT7_MOVBCO == '1' 
                    cParcela    := SDG->DG_PARC
                    If nValRep > nValBx                
                        If SDG->DG_VALCOB <= nValRep - nValBx                     
                            nValAux     := SDG->DG_VALCOB
                        ElseIf SDG->DG_VALCOB >  nValRep - nValBx   
                            nValAux     := nValRep - nValBx 
                        EndIf                 

                        TMSA070Bx("1",SDG->DG_NUMSEQ,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,,,nValAux,,SDG->DG_IDENT)
                        nValBx  += nValAux
                    Else 
                        Exit 
                    EndIf 
                EndIf 

                SDG->(dbSkip())
            Enddo

            If !Empty(FwFilial("SE2")) 
                cFilSE2 := cFilOri
            Else 
                cFilSE2 := xFilial("SE2") 
            EndIF 

            SE2->(DbSetOrder(1))   //-- saldo para baixa
            If SE2->(MsSeek(cFilSE2+cPrefix+ cNumSE2+cParcela+cTipCTC+cCodForn+cLojForn))
            
                AADD(aBaixa , {"E2_FILIAL"  , cFilSE2              	,Nil})
                AADD(aBaixa , {"E2_PREFIXO" , cPrefix           	,Nil})
                AADD(aBaixa , {"E2_NUM"     , cNumSE2 				,Nil})
                AADD(aBaixa , {"E2_PARCELA" , cParcela         		,Nil})
                AADD(aBaixa , {"E2_TIPO"    , cTipCTC	            ,Nil})
                AADD(aBaixa , {"E2_FORNECE" , cCodForn          	,Nil})
                AADD(aBaixa , {"E2_LOJA"    , cLojForn           	,Nil})
                AADD(aBaixa , {"AUTBANCO"	, cBanco             	,Nil})
                AADD(aBaixa , {"AUTAGENCIA" , cAgencia           	,Nil})
                AADD(aBaixa , {"AUTCONTA"	, cConta           		,Nil})
                AADD(aBaixa , {"AUTMOTBX"	, "DEBITO CC"          	,Nil})
                AADD(aBaixa , {"AUTDTBAIXA" , dDataBase            	,Nil})
                AADD(aBaixa , {"AUTHIST"	, 'Interrupcao viagem'  ,Nil})
                AADD(aBaixa , {"AUTDESCONT" , 0                   	,Nil})
                AADD(aBaixa , {"AUTMULTA"   , 0                   	,Nil})
                AADD(aBaixa , {"AUTJUROS"   , 0                   	,Nil})
                AADD(aBaixa , {"AUTVLRPG"   , SE2->E2_SALDO - nValBx 	,Nil})
                AADD(aBaixa , {"AUTVLRME"   , 0                   	,Nil})

                //-- Executa a Baixa do Titulo
                MsExecAuto({|x,y| FINA080(x, y)},aBaixa,3)
            
                If lMSErroAuto
                    lRet    := .F. 
                    MostraErro()
                Endif
            EndIf
        
            If !lRet 
                DisarmTransaction()
            EndIf 
        EndIf
    EndIf 
Else 
    lRet    := .F. 
    Help('',1,'TMSAC15A0001')   // "Não é possivel prosseguir com a interrupção do contrato na Repom. Para realizar o procedimento o Contrato de Carreteiro deve estar excluído, pois podem ocorrer mudanças nos valores.
                                //  "O contrato interrompido será consultado a fim de se    obter os valores de consumo do motorista, e assim                               realizar a baixa parcial do adiantamento se houver"
EndIf 

End Transaction 

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TM15LocQuit
Atualiza local de quitação 
@author     Caio Murakami
@since      23/04/2021
@version    2.2
@param      cFilOri, cViagem, nOpc
@return     lRet
@type       function
/*/
//--------------------------------------------------------------------
Function TM15LocQuit( cFilOri , cViagem , nOpc)
Local aArea         := GetArea()
Local cLocQuit      := "" 
Local oRepom        := Nil 
Local aAux          := {} 
Local nPos          := 0 

Default cFilOri     := ""
Default cViagem     := ""
Default nOpc        := 3

If lRestRepom
    If nOpc == 3 
        oRepom := TMSBCARepomFrete():New()
	    If oRepom:Auth()
           aAux	:= oRepom:GetShipByShip(cFilOri,cViagem) 
            
            If Len(aAux) > 0 
                nPos    := aScan( aAux , {|x| Upper(x[1]) = "SHIPPINGPAYMENT"})
                If nPos > 0 
                    If Upper( AllTrim( aAux[nPos][2]["DELIVERYLOCATIONTYPE"] ) ) == "BRANCH"
                        cLocQuit    := "0" //-- Filial
                    ElseIf !Empty( aAux[nPos][2]["DELIVERYLOCATIONTYPE"] )
                        cLocQuit    := "1" //-- Posto
                    EndIf 
                EndIf 
            EndIf 
        EndIf 
    EndIf 
EndIf 

RestArea(aArea)
Return cLocQuit 

//-----------------------------------------------------------------
/*/{Protheus.doc} TMultiGet
Exibe informações
@author     Caio Murakami
@since      26/08/2021
@version    2.2
@param      cFilOri, cViagem, nOpc
@return     lRet
@type       function
/*/
//--------------------------------------------------------------------
Static Function TMultiGet( aExibe )
Local oDlg, oGet
Local nCount    := 1
Local cText     := "" 

Default aExibe := {}

For nCount := 1 To Len(aExibe)
    cText   += aExibe[nCount,1] + chr(10) + chr(13)
Next nCount 

DEFINE DIALOG oDlg TITLE STR0005 FROM 180,180 TO 550,700 PIXEL
 
// Cria o Objeto tGet usando o comando @ .. GET MULTILINE
@ 10,10 GET oGet VAR cText SIZE 200,160 MULTILINE OF oDlg PIXEL
 
ACTIVATE DIALOG oDlg CENTERED
 
Return

