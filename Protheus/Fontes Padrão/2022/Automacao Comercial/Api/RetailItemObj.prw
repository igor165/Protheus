#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RetailItemObj
    Classe para tratamento da API de Produtos do Varejo
/*/
//-------------------------------------------------------------------
Class RetailItemObj From LojRestObj

	Method New(oWsRestObj)  Constructor

    Method SetFields()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API

@author  Rafael Tenorio da Costa
@since   17/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class RetailItemObj

    _Super:New(oWsRestObj)

    self:SetSelect("SB1")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos que serão retornados

@author  Rafael Tenorio da Costa
@since   17/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class RetailItemObj

                        //Tag   			        Campo           Expressão que será executada para gerar o retorno	     Tag que será utilizada para preencher o objeto de retorno
    HmAdd(self:oFields, {"COMPANYID"				, ""			, "cEmpAnt"												, "CompanyId"					}, 1, 3)
    HmAdd(self:oFields, {"BRANCHID"					, "B1_FILIAL"   , "B1_FILIAL"                                           , "BranchId"					}, 1, 3)
    HmAdd(self:oFields, {"CODE"						, "B1_COD"      , "B1_COD"                                              , "Code"						}, 1, 3)
    HmAdd(self:oFields, {"INTERNALID"				, "" 			, "B1_FILIAL +'|'+ B1_COD"                              , "InternalId"				    }, 1, 3)
    HmAdd(self:oFields, {"DESCRIPTION"				, "B1_DESC"     , "B1_DESC"                                             , "Description"				    }, 1, 3)
    HmAdd(self:oFields, {"ACTIVE"					, "B1_ATIVO"    , "B1_ATIVO"                                            , "Active"					    }, 1, 3)
    HmAdd(self:oFields, {"UNITOFMEASURECODE"		, "B1_UM"       , "B1_UM"                                               , "UnitOfMeasureCode"		    }, 1, 3)
    HmAdd(self:oFields, {"STANDARDWAREHOUSECODE"	, "B1_LOCPAD"   , "B1_LOCPAD"                                           , "StandardWarehouseCode"	    }, 1, 3)
    HmAdd(self:oFields, {"ECONOMICLOT"				, "B1_LE"       , "B1_LE"                                               , "EconomicLot"				    }, 1, 3)
    HmAdd(self:oFields, {"MINIMUMLOT"				, "B1_LM"       , "B1_LM"                                               , "MinimumLot"				    }, 1, 3)
    HmAdd(self:oFields, {"NETWEIGHT"				, "B1_PESO"     , "B1_PESO"                                             , "NetWeight"				    }, 1, 3)
    HmAdd(self:oFields, {"GROSSWEIGHT"				, "B1_PESBRU"   , "B1_PESBRU"                                           , "GrossWeight"				    }, 1, 3)
    HmAdd(self:oFields, {"FAMILYCODE"				, "B1_FPCOD"    , "B1_FPCOD"                                            , "FamilyCode"				    }, 1, 3)
    HmAdd(self:oFields, {"ORIGIN"					, "B1_ORIGEM"   , "B1_ORIGEM"                                           , "Origin"					    }, 1, 3)
    HmAdd(self:oFields, {"COSTCENTERCODE"			, "B1_CC"       , "B1_CC"                                               , "CostCenterCode"			    }, 1, 3)
    HmAdd(self:oFields, {"ACCOUNTITEM"             	, "B1_ITEMCC"   , "B1_ITEMCC"                                           , "AccountItem"             	}, 1, 3)
    HmAdd(self:oFields, {"GROUPCODE"				, "B1_GRUPO"    , "B1_GRUPO"                                            , "GroupCode"				    }, 1, 3)
    HmAdd(self:oFields, {"SECONDUNITOFMEASURECODE"	, "B1_SEGUM"    , "B1_SEGUM"                                            , "SecondUnitOfMeasureCode"	    }, 1, 3)
    HmAdd(self:oFields, {"MULTIPLICATIONFACTORVALUE", "B1_CONV"     , "B1_CONV"                                             , "MultiplicationFactorValue"   }, 1, 3)
    HmAdd(self:oFields, {"PRODUCTTYPE"				, "B1_TIPO"     , "B1_TIPO"                                             , "ProductType"				    }, 1, 3)
    HmAdd(self:oFields, {"TRAIL"					, "B1_RASTRO"   , "B1_RASTRO"                                           , "Trail"					    }, 1, 3)
    HmAdd(self:oFields, {"ADDRESSINGCONTROL"		, "B1_LOCALIZ"  , "B1_LOCALIZ"                                          , "AddressingControl"		    }, 1, 3)
    HmAdd(self:oFields, {"MANUFACTURERCODE"			, "B1_FABRIC"   , "B1_FABRIC"                                           , "ManufacturerCode"			}, 1, 3)
    HmAdd(self:oFields, {"ICMSTAXRATE"				, "B1_PICM"     , "B1_PICM"                                             , "IcmsTaxRate"				    }, 1, 3)
    HmAdd(self:oFields, {"IPITAXRATE"				, "B1_IPI"      , "B1_IPI"                                              , "IpiTaxRate"				    }, 1, 3)
    HmAdd(self:oFields, {"ISSTAXRATE"				, "B1_ALIQISS"	, "B1_ALIQISS"                                          , "IssTaxRate"				    }, 1, 3)
    HmAdd(self:oFields, {"MERCOSULNOMENCLATURE"		, "B1_POSIPI"	, "B1_POSIPI"                                           , "MercosulNomenclature"		}, 1, 3)
    HmAdd(self:oFields, {"SALESPRICE"              	, "B1_PRV1"     , "B1_PRV1"                                             , "SalesPrice"              	}, 1, 3)
    HmAdd(self:oFields, {"STANDARDCOST"            	, "B1_CUSTD"    , "B1_CUSTD"                                            , "StandardCost"            	}, 1, 3)
    HmAdd(self:oFields, {"LASTPURCHASEPRICE"		, "B1_UPRC"     , "B1_UPRC"                                             , "LastPurchasePrice"		    }, 1, 3)

Return Nil