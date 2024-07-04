#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RetailSalesOrdersObj
    Classe para tratamento da API de Pedidos de Venda do Varejo
/*/
//-------------------------------------------------------------------
Class RetailSalesOrdersObj From LojRestObj

	Method New(oWsRestObj)  Constructor

    Method SetFields()
    Method SetSelect(cTable)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API

@author  Rafael Tenorio da Costa
@since   02/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class RetailSalesOrdersObj

    _Super:New(oWsRestObj)

    self:lRetHasNext := .T. //Define o tipo de retorno como array

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos que serão retornados

@author  Rafael Tenorio da Costa
@since   02/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class RetailSalesOrdersObj

    Do Case
         Case self:cTable == "SC5"

                                //Tag                       Campo           Expressão que será executada para gerar o retorno   Tag que será utilizada para preencher o objeto de retorno
            HmAdd(self:oFields, {"COMPANYID"				, ""			, "cEmpAnt"                 						, "companyId"           	} , 1, 3)
            HmAdd(self:oFields, {"COMPANYINTERNALID"		, ""			, "cEmpAnt +'|'+ cFilAnt"    						, "companyInternalId"   	} , 1, 3)            
            HmAdd(self:oFields, {"BRANCHID"					, "C5_FILIAL"	, "C5_FILIAL"               						, "branchId"				} , 1, 3)
            HmAdd(self:oFields, {"ORDER"					, "C5_NUM"	    , "C5_NUM"                  						, "order"					} , 1, 3)
            HmAdd(self:oFields, {"INTERNALID"				, ""            , "C5_FILIAL +'|'+ C5_NUM"  						, "internalId"          	} , 1, 3)
            HmAdd(self:oFields, {"REGISTERDATE"				, "C5_EMISSAO"  , "C5_EMISSAO"       								, "registerDate"			} , 1, 3)
            HmAdd(self:oFields, {"CUSTOMERCODE"   			, "C5_CLIENTE"  , "C5_CLIENTE"       								, "customerCode"          	} , 1, 3)
            HmAdd(self:oFields, {"CUSTOMERSTORE"   			, "C5_LOJACLI"  , "C5_LOJACLI"          								, "customerStore"          	} , 1, 3)
            HmAdd(self:oFields, {"INVOICENUMBER"			, "C5_NOTA"     , "C5_NOTA"      	 								, "invoiceNumber"         	} , 1, 3)
            HmAdd(self:oFields, {"INVOICESERIES"   			, "C5_SERIE"    , "C5_SERIE"     	 								, "invoiceSeries"         	} , 1, 3)
            HmAdd(self:oFields, {"BUDGETNUMBER"   			, "C5_ORCRES"   , "C5_ORCRES"     	 								, "budgetNumber"          	} , 1, 3)
            HmAdd(self:oFields, {"ECOMMERCEORDER" 			, "C5_PEDECOM" 	, "C5_PEDECOM"     	 								, "ecommerceOrder"       	} , 1, 3)
            HmAdd(self:oFields, {"ECOMMERCESTATUS"			, "C5_STATUS"   , "C5_STATUS"  		 								, "ecommerceStatus"			} , 1, 3)
            HmAdd(self:oFields, {"ECOMMERCETRACKINGCODE" 	, "C5_RASTR"	, "C5_RASTR"     	 								, "ecommerceTrackingCode"	} , 1, 3)
            HmAdd(self:oFields, {"CURRENCY" 				, "C5_MOEDA"    , "C5_MOEDA"     	 								, "currency"				} , 1, 3)
            HmAdd(self:oFields, {"PAYMENTTERM" 				, "C5_CONDPAG"  , "C5_CONDPAG"     	 								, "paymentTerm"				} , 1, 3)
            HmAdd(self:oFields, {"SELLERCODE1" 				, "C5_VEND1"    , "C5_VEND1"     	 								, "sellerCode1"				} , 1, 3)
            HmAdd(self:oFields, {"COMMISSIONSELLER1" 		, "C5_COMIS1"   , "C5_COMIS1"     	 								, "commissionSeller1"		} , 1, 3)
            HmAdd(self:oFields, {"CARRIERCODE" 				, "C5_TRANSP"   , "C5_TRANSP"     	 								, "carrierCode"				} , 1, 3)
            HmAdd(self:oFields, {"TYPEFREIGHT" 				, "C5_TPFRETE"  , "C5_TPFRETE"     	 								, "typeFreight"				} , 1, 3)
            HmAdd(self:oFields, {"FREIGHTVALUE" 			, "C5_FRETE"    , "C5_FRETE"     	 								, "freightValue"			} , 1, 3)
            HmAdd(self:oFields, {"INSURANCEVALUE" 			, "C5_SEGURO"   , "C5_SEGURO"     	 								, "insuranceValue"			} , 1, 3)
            HmAdd(self:oFields, {"EXPENSEVALUE" 			, "C5_DESPESA"  , "C5_DESPESA"     	 								, "expenseValue"			} , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTVALUE1" 			, "C5_DESC1"    , "C5_DESC1"     	 								, "discountValue1"			} , 1, 3)
            HmAdd(self:oFields, {"CLASSVOLUME1" 			, "C5_ESPECI1"  , "C5_ESPECI1"     	 								, "classVolume1"			} , 1, 3)
            HmAdd(self:oFields, {"VOLUMEAMOUNT" 			, "C5_VOLUME1"  , "C5_VOLUME1"     	 								, "volumeAmount"			} , 1, 3)
            HmAdd(self:oFields, {"NETWEIGHT" 				, "C5_PESOL"    , "C5_PESOL"     	 								, "netWeight"				} , 1, 3)
            HmAdd(self:oFields, {"GROSSWEIGHT" 				, "C5_PBRUTO"   , "C5_PBRUTO"     	 								, "grossWeight"				} , 1, 3)
            HmAdd(self:oFields, {"INVOICEMESSAGE" 			, "C5_MENNOTA"  , "C5_MENNOTA"     	 								, "invoiceMessage"			} , 1, 3)
            HmAdd(self:oFields, {"ORIGIN" 					, "C5_ORIGEM"   , "C5_ORIGEM"     	 								, "origin"					} , 1, 3)
            HmAdd(self:oFields, {"RELEASETYPE" 				, "C5_TIPLIB"   , "C5_TIPLIB"     	 								, "releaseType"				} , 1, 3)
            HmAdd(self:oFields, {"LOAD" 					, "C5_TPCARGA"  , "C5_TPCARGA"     	 								, "load"					} , 1, 3)
            HmAdd(self:oFields, {"GENERATEWMS" 				, "C5_GERAWMS"  , "C5_GERAWMS"     	 								, "generateWms"				} , 1, 3)

         Case self:cTable == "SC6"

                                //Tag					Campo           Expressão que será executada para gerar o retorno 	Tag que será utilizada para preencher o objeto de retorno
            HmAdd(self:oFields, {"COMPANYID"			, ""			, "cEmpAnt"                                         , "companyId"           } , 1, 3)
            HmAdd(self:oFields, {"COMPANYINTERNALID"	, ""			, "cEmpAnt +'|'+ cFilAnt"                           , "companyInternalId"   } , 1, 3)
            HmAdd(self:oFields, {"BRANCHID"				, "C6_FILIAL"	, "C6_FILIAL"                   					, "branchId"			} , 1, 3)
            HmAdd(self:oFields, {"ORDER"				, "C6_NUM"		, "C6_NUM"											, "order"				} , 1, 3)
            HmAdd(self:oFields, {"INTERNALID"	    	, ""			, "C6_FILIAL +'|'+ C6_NUM"							, "internalId"  	    } , 1, 3)
            HmAdd(self:oFields, {"ITEM"       			, "C6_ITEM"		, "C6_ITEM"											, "item"       			} , 1, 3)
            HmAdd(self:oFields, {"PRODUCTCODE"			, "C6_PRODUTO"	, "C6_PRODUTO"										, "productCode"			} , 1, 3)
            HmAdd(self:oFields, {"DESCRIPTION"			, "C6_DESCRI"	, "C6_DESCRI"										, "description"			} , 1, 3)
            HmAdd(self:oFields, {"MEASUREUNIT"			, "C6_UM"		, "C6_UM"											, "measureUnit"			} , 1, 3)
            HmAdd(self:oFields, {"QUANTITY"   			, "C6_QTDVEN"	, "C6_QTDVEN"										, "quantity"   			} , 1, 3)
            HmAdd(self:oFields, {"UNITARYPRICE"			, "C6_PRCVEN"	, "C6_PRCVEN"										, "unitaryPrice"		} , 1, 3)
            HmAdd(self:oFields, {"TOTALVALUE"      		, "C6_VALOR"	, "C6_VALOR"										, "totalValue"      	} , 1, 3)
            HmAdd(self:oFields, {"OUTFLOWTYPE"			, "C6_TES"		, "C6_TES"											, "outflowType"			} , 1, 3)
            HmAdd(self:oFields, {"FISCALCODE"			, "C6_CF"		, "C6_CF"											, "fiscalCode"			} , 1, 3)
            HmAdd(self:oFields, {"WAREHOUSEINTERNALID"	, "C6_LOCAL"	, "C6_LOCAL"										, "warehouseInternalId"	} , 1, 3)
            HmAdd(self:oFields, {"CUSTOMERCODE"	        , "C6_CLI"		, "C6_CLI"											, "customerCode"	    } , 1, 3)
            HmAdd(self:oFields, {"CUSTOMERSTORE"        , "C6_LOJA"		, "C6_LOJA"											, "customerStore"		} , 1, 3)
            HmAdd(self:oFields, {"PRICELIST" 			, "C6_PRUNIT"	, "C6_PRUNIT"										, "priceList" 			} , 1, 3)
            HmAdd(self:oFields, {"TYPEPRODUCTIONORDER"	, "C6_TPOP"		, "C6_TPOP"											, "typeProductionOrder"	} , 1, 3)
            HmAdd(self:oFields, {"LOT"        			, "C6_LOTECTL"	, "C6_LOTECTL"										, "lot"        			} , 1, 3)
            HmAdd(self:oFields, {"DELIVERYDATE"        	, "C6_ENTREG"	, "C6_ENTREG"										, "deliveryDate"        } , 1, 3)
            HmAdd(self:oFields, {"TAXATIONSTATUS"      	, "C6_CLASFIS"	, "C6_CLASFIS"										, "taxationStatus"      } , 1, 3)
            HmAdd(self:oFields, {"PARTTYPE"  			, "C6_VDMOST"	, "C6_VDMOST"										, "partType"  			} , 1, 3)
            HmAdd(self:oFields, {"SHIFT"      			, "C6_TURNO"	, "C6_TURNO"										, "shift"      			} , 1, 3)
            HmAdd(self:oFields, {"EXTENDEDWARRANTY"		, "C6_ITEMGAR"	, "C6_ITEMGAR"										, "extendedWarranty"	} , 1, 3)
            HmAdd(self:oFields, {"EXTENDEDWARRANTYQUOT"	, "C6_ORCGAR"	, "C6_ORCGAR"										, "extendedWarrantyQuot"} , 1, 3)
            HmAdd(self:oFields, {"FCICODE"   			, "C6_FCICOD"	, "C6_FCICOD"										, "fciCode"   			} , 1, 3)
            HmAdd(self:oFields, {"IMPORTVALUE"         	, "C6_VLIMPOR"	, "C6_VLIMPOR"										, "importValue"         } , 1, 3)
            HmAdd(self:oFields, {"APPROVEDAMOUNT"		, "C9_QTDLIB"	, "C9_QTDLIB"										, "approvedAmount"		} , 1, 3)
            HmAdd(self:oFields, {"STOCKBLOCK"			, "C9_BLEST"	, "C9_BLEST"										, "stockBlock"			} , 1, 3)
            HmAdd(self:oFields, {"CREDITBLOCK"			, "C9_BLCRED"	, "C9_BLCRED"										, "creditBlock"			} , 1, 3)
            HmAdd(self:oFields, {"BLOCK"				, "C9_BLOQUEI"	, "C9_BLOQUEI"										, "block"				} , 1, 3)
            HmAdd(self:oFields, {"TMSBLOCK"				, "C9_BLWMS"	, "C9_BLWMS"										, "tmsBlock"			} , 1, 3)
            HmAdd(self:oFields, {"WMSBLOCK"				, "C9_BLTMS"	, "C9_BLTMS"										, "wmsBlock"			} , 1, 3)
            HmAdd(self:oFields, {"BLOCKINFORMATION"		, "C9_BLINF"	, "C9_BLINF"										, "blockInformation"	} , 1, 3)

    EndCase

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSelect
Carrega a query que será executada

@author  Rafael Tenorio da Costa
@since   02/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSelect(cTable) Class RetailSalesOrdersObj

    Local cInternalId   := ""
    Local aParam        := {}
    Local cSelect       := "SELECT * FROM " + RetSqlName("SC5") + " SC5"
    Local cWhere        := "WHERE SC5.D_E_L_E_T_ = ' ' AND C5_ORCRES <> '" + Space( TamSx3("C5_ORCRES")[1] ) + "'"
    Local cGroupBy      := ""

    If cTable == "SC6"

        cSelect += " INNER JOIN " + RetSqlName("SC6") + " SC6"
        cSelect +=  " ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC5.D_E_L_E_T_ = SC6.D_E_L_E_T_"
        cSelect += " LEFT JOIN " +  RetSqlName("SC9") + " SC9"
        cSelect +=  " ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND C6_PRODUTO = C9_PRODUTO AND SC6.D_E_L_E_T_ = SC9.D_E_L_E_T_"

        cGroupBy := "GROUP BY *"    //Coloca todos os campos retornados no group by
    EndIf

	//Carrega Filtro do InternalId
	If self:oWsRestObj:internalId <> Nil .And. !Empty(self:oWsRestObj:internalId)
		cInternalId := self:oWsRestObj:internalId
    EndIf

	If !Empty(cInternalId)
		aParam := Separa(cInternalId, "|")

		If !Empty(aParam)
			cWhere += " AND C5_FILIAL = '" + aParam[1] + "' AND C5_NUM = '" + aParam[2] + "'"
		EndIf
	EndIf

    self:cTable     := cTable
    self:cSelect    := cSelect
    self:cWhere     := cWhere
    self:cGroupBy   := cGroupBy

Return Nil