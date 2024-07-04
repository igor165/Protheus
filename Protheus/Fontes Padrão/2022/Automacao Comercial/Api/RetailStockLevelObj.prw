#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RetailStockLevelObj
    Classe para tratamento da API de Estoque de Produto do Varejo
/*/
//-------------------------------------------------------------------
Class RetailStockLevelObj From LojRestObj

	Method New(oWsRestObj)  Constructor

    Method SetFields()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API

@author  Danilo Santos
@since   23/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class RetailStockLevelObj

    _Super:New(oWsRestObj)

    self:setSelect("SB2")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos que ser�o retornados

@author  Danilo Santos
@since   23/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class RetailStockLevelObj


                             //Tag   		            Campo		  	  Express�o que ser� executada para gerar o retorno	            Tag que ser� utilizada para preencher o objeto de retorno
    HmAdd(self:oFields, {"COMPANYID"		            , ""			, "cEmpAnt"                                                    , "companyId"                    } , 1, 3)
    HmAdd(self:oFields, {"BRANCHID"			            , "B2_FILIAL"	, "B2_FILIAL"                                                  , "branchId"			            } , 1, 3)	
    HmAdd(self:oFields, {"ITEMINTERNALID"               , "B2_COD"		, "B2_COD"                                                     , "iteminternalId"               } , 1, 3)
    HmAdd(self:oFields, {"CURRENTSTOCKAMOUNT"	        , "B2_QATU"	    , "B2_QATU"                                                    , "currentstockamount"           } , 1, 3)
    HmAdd(self:oFields, {"WAREHOUSEINTERNALID" 	        , "B2_LOCAL"    , "B2_LOCAL"                                                   , "warehouseinternalid"          } , 1, 3)
    HmAdd(self:oFields, {"BOOKEDSTOCKAMOUNT"            , "B2_RESERVA"	, "B2_RESERVA"                                                 , "bookedstockamount"            } , 1, 3)
    HmAdd(self:oFields, {"FUTURESTOCKAMOUNT"            , "B2_SALPEDI"  , "B2_SALPEDI"                                                 , "futurestockamount"            } , 1, 3)
    HmAdd(self:oFields, {"VALUEOFCURRENTSTOCKAMOUNT"	, "B2_VATU1"    , "B2_VATU1"                                                   , "valueofcurrentstockamount"    } , 1, 3)

Return Nil