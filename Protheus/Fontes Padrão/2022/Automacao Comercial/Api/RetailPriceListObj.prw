#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RetailPriceListObj
    Classe para tratamento da API de Tabela de Preços do Varejo
/*/
//-------------------------------------------------------------------
Class RetailPriceListObj From LojRestObj

	Method New(oWsRestObj)  Constructor

    Method SetFields()
    Method SetSelect(cTable)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class RetailPriceListObj

    _Super:New(oWsRestObj)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos que serão retornados

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class RetailPriceListObj

    Do Case
         Case self:cTable == "DA0"

                                //Tag               Campo           Expressão que será executada para gerar o retorno                   Tag que será utilizada para preencher o objeto de retorno
            HmAdd(self:oFields, {"COMPANYID"		, ""			, "cEmpAnt"                                                         , "companyId"           } , 1, 3)
            HmAdd(self:oFields, {"BRANCHID"			, "DA0_FILIAL"	, "DA0_FILIAL"                                                      , "branchId"			} , 1, 3)	
            HmAdd(self:oFields, {"COMPANYINTERNALID", ""			, "cEmpAnt +'|'+ DA0_FILIAL"                                        , "companyInternalId"   } , 1, 3)
            HmAdd(self:oFields, {"CODE"				, "DA0_CODTAB"	, "DA0_CODTAB"                                                      , "code"				} , 1, 3)
            HmAdd(self:oFields, {"INTERNALID"		, ""            , "DA0_FILIAL +'|'+ DA0_CODTAB"                                     , "internalId"          } , 1, 3)
            HmAdd(self:oFields, {"NAME"				, "DA0_DESCRI"	, "DA0_DESCRI"                                                      , "name"                } , 1, 3)
            HmAdd(self:oFields, {"INITIALDATE"		, "DA0_DATDE"   , "DA0_DATDE"                                                       , "initialDate"         } , 1, 3)
            HmAdd(self:oFields, {"FINALDATE"		, "DA0_DATATE"  , "DA0_DATATE"                                                      , "finalDate"           } , 1, 3)
            HmAdd(self:oFields, {"INITIAHOUR"		, "DA0_HORADE"  , "DA0_HORADE"                                                      , "initiaHour"          } , 1, 3)
            HmAdd(self:oFields, {"FINALHOUR"		, "DA0_HORATE"	, "DA0_HORATE"                                                      , "finalHour"           } , 1, 3)
            HmAdd(self:oFields, {"ACTIVETABLEPRICE"	, "DA0_ATIVO"   , "DA0_ATIVO"                                                       , "activeTablePrice"    } , 1, 3)

         Case self:cTable == "DA1"

                                //Tag				Campo           Expressão que será executada para gerar o retorno                   Tag que será utilizada para preencher o objeto de retorno
            HmAdd(self:oFields, {"COMPANYID"		, ""			, "cEmpAnt"                                                         , "companyId"           } , 1, 3)
            HmAdd(self:oFields, {"BRANCHID"			, "DA1_FILIAL"	, "DA1_FILIAL"                                                      , "branchId"			} , 1, 3)	
            HmAdd(self:oFields, {"COMPANYINTERNALID", ""			, "cEmpAnt +'|'+ DA1_FILIAL"                                        , "companyInternalId"   } , 1, 3)
            HmAdd(self:oFields, {"CODE"				, "DA1_CODTAB"	, "DA1_CODTAB"                                                      , "code"				} , 1, 3)
            HmAdd(self:oFields, {"INTERNALID"	    , ""			, "DA1_FILIAL +'|'+ DA1_CODTAB"                                     , "internalId"  	    } , 1, 3)
            HmAdd(self:oFields, {"ITEMLIST"			, "DA1_ITEM"    , "DA1_ITEM"                                                        , "itemList"			} , 1, 3)
            HmAdd(self:oFields, {"ITEMCODE"			, "DA1_CODPRO"  , "DA1_CODPRO"                                                      , "itemCode"			} , 1, 3)
            HmAdd(self:oFields, {"ITEMINTERNALID"	, ""			, "DA1_FILIAL +'|'+ DA1_CODTAB +'|'+ DA1_ITEM +'|'+ DA1_CODPRO"     , "itemInternalId"	    } , 1, 3)
            HmAdd(self:oFields, {"MINIMUMSALESPRICE", "DA1_PRCVEN"  , "DA1_PRCVEN"                                                      , "minimumSalesPrice"   } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTVALUE"	, "DA1_VLRDES"  , "DA1_VLRDES"                                                      , "discountValue"	    } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTFACTOR"	, "DA1_PERDES"  , "DA1_PERDES"                                                      , "discountFactor"	    } , 1, 3)
            HmAdd(self:oFields, {"ITEMVALIDITY"		, "DA1_DATVIG"  , "DA1_DATVIG"                                                      , "itemValidity"		} , 1, 3)
            HmAdd(self:oFields, {"TYPEPRICE"		, "DA1_TIPPRE"  , "DA1_TIPPRE"                                                      , "typePrice"		    } , 1, 3)
            HmAdd(self:oFields, {"ACTIVEITEMPRICE"	, "DA1_ATIVO"   , "DA1_ATIVO"                                                       , "activeItemPrice"	    } , 1, 3)
    EndCase

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSelect
Carrega a query que será executada

@author  Rafael Tenorio da Costa
@since   23/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSelect(cTable) Class RetailPriceListObj

    Local cInternalId   := ""
    Local aParam        := {}

    self:cTable := cTable

    self:cSelect := "SELECT * FROM " + RetSqlName(cTable)
    self:cWhere  := "WHERE D_E_L_E_T_ = ' '"

	//Carrega Filtro do InternalId
	If self:oWsRestObj:internalId <> Nil .And. !Empty(self:oWsRestObj:internalId)
		cInternalId := self:oWsRestObj:internalId
    EndIf

	If !Empty(cInternalId)
		aParam := Separa(cInternalId, "|")

		If !Empty(aParam)
			self:cWhere += " AND " + self:cTable + "_FILIAL = '" + aParam[1] + "' AND " + self:cTable + "_CODTAB = '" + aParam[2] + "'"
		EndIf
	EndIf

Return Nil