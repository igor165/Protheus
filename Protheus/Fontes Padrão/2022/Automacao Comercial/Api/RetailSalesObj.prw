#INCLUDE "PROTHEUS.CH"
#INCLUDE "RETAILSALESAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RetailSalesObj
    Classe para tratamento da API de Vendas do Varejo
/*/
//-------------------------------------------------------------------
Class RetailSalesObj From LojRestObj

    Data lPedVend As Logical

	Method New(oWsRestObj)  Constructor

    Method SetFields()
    Method SetTables()
    Method SetSelect(cTable)
    Method ExecAuto()
    Method ExecLoja701() 
    Method FormatVar() 
    Method PedVen() 
    Method SetTes()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API

@author  rafael.pessoa
@since   09/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class RetailSalesObj

    _Super:New(oWsRestObj)

    self:SetTables()

    self:lRetHasNext := .T. //Define o tipo de retorno como array
    Self:lPedVend := .F.

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTables
Carrega as tabelas que serão manipuladas

@author  rafael.pessoa
@since   09/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTables() Class RetailSalesObj
    Aadd(self:aTables, {"SL1", ""                                 })
    Aadd(self:aTables, {"SL2", "ListOfSaleItem:SaleItem"          })
    Aadd(self:aTables, {"SL4", "ListOfSaleCondition:SaleCondition"})
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos que serão retornados

@author  rafael.pessoa
@since   09/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class RetailSalesObj

    Do Case

        Case self:cTable == "SL1"
                                //Tag                             Campo           Expressão que será executada para gerar o retorno  Tag que será utilizada para preencher o objeto de retorno    Tipo do campo
            HmAdd(self:oFields, {"COMPANYID"				    , ""			, "cEmpAnt"                                         , "CompanyId"           	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"BRANCHID"					    , "L1_FILIAL"	, "L1_FILIAL"                                       , "BranchId"				                                , "C"  } , 1, 3)                  
            HmAdd(self:oFields, {"ID"					        , "L1_NUM"	    , "L1_NUM"                                          , "Id"				                                        , "C"  } , 1, 3)                  
            HmAdd(self:oFields, {"INTERNALID"				    , ""            , "L1_FILIAL +'|'+ L1_NUM"                          , "InternalId"                                              , "C"  } , 1, 3)            
            HmAdd(self:oFields, {"CUSTOMERCODE"   			    , "L1_CLIENTE"  , "L1_CLIENTE"       								, "CustomerCode"          	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"CUSTOMERSTORE"   			    , "L1_LOJA"     , "L1_LOJA"          								, "CustomerStore"          	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SELLERCODE"   			    , "L1_VEND"     , "L1_VEND"          								, "SellerCode"          	                                , "C"  } , 1, 3)			
            HmAdd(self:oFields, {"COMISSIONPERCENT"   		    , "L1_COMIS"    , "L1_COMIS"       	                                , "ComissionPercent"   		                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"TOTALPRICE"			        , "L1_VLRTOT"   , "L1_VLRTOT"      	 	                            , "TotalPrice"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTVALUE"			    , "L1_DESCONT"  , "L1_DESCONT" 			                            , "DiscountValue"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"INCREASEVALUE"			    , "L1_DESPESA"  , "L1_DESPESA + L1_SEGURO" 	                        , "IncreaseValue"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"NETPRICE"			            , "L1_VLRLIQ"   , "L1_VLRLIQ" 			                            , "NetPrice"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CASHVALUE"			        , "L1_DINHEIR"  , "L1_DINHEIR" 			                            , "CashValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CHECKSVALUE"			        , "L1_CHEQUES"  , "L1_CHEQUES" 			                            , "ChecksValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CARDSVALUE"			        , "L1_CREDITO"  , "L1_CREDITO" 			                            , "CardsValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DEBITVALUE"			        , "L1_VLRDEBI"  , "L1_VLRDEBI" 			                            , "DebitValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COVENANTVALUE"			    , "L1_CONVENI"  , "L1_CONVENI" 			                            , "CovenantValue"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"VOUCHERSVALUE"			    , "L1_VALES"    , "L1_VALES" 			                            , "VouchersValue"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FINANCEDVALUE"			    , "L1_FINANC"   , "L1_FINANC" 			                            , "FinancedValue"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"OTHERSVALUE"			        , "L1_OUTROS"   , "L1_OUTROS" 			                            , "OthersValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"INPUTVALUE"			        , "L1_ENTRADA"  , "L1_ENTRADA" 			                            , "InputValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ISSUEDATEDOCUMENT"		    , "L1_EMISSAO"  , "L1_EMISSAO" 			                            , "IssueDateDocument"		                                , "DF" } , 1, 3)
            HmAdd(self:oFields, {"EMISNF"          		        , "L1_EMISNF"   , "L1_EMISNF" 			                            , "EmisNf"          		                                , "DF" } , 1, 3)
            HmAdd(self:oFields, {"DATETIME"    		            , "L1_HORA"     , "L1_HORA" 			                            , "DateTime"           		                                , "T"  } , 1, 3)
            HmAdd(self:oFields, {"NUMCFIS"  			        , "L1_NUMCFIS"  , "L1_NUMCFIS"  	                                , "NumCFis"     		                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"INVOICEMESSAGES"			    , "L1_MENNOTA"  , "L1_MENNOTA" 			                            , "InvoiceMessages"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"DOCUMENTCODE"			        , "L1_DOC"      , "L1_DOC" 			                                , "DocumentCode"		                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SERIECODE"			        , "L1_SERIE"    , "L1_SERIE" 			                            , "SerieCode"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"GROSSPRICE"			        , "L1_VALBRUT"  , "L1_VALBRUT" 			                            , "GrossPrice"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COMMODITYPRICE"			    , "L1_VALMERC"  , "L1_VALMERC" 			                            , "CommodityPrice"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTPERCENT"			    , "L1_DESCNF"   , "L1_DESCNF" 			                            , "DiscountPercent"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"OPERATORCODE"			        , "L1_OPERADO"  , "L1_OPERADO" 			                            , "OperatorCode"		                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"CURRENCYRATE"			        , "L1_TXMOEDA"  , "L1_TXMOEDA" 			                            , "CurrencyRate"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CHANGE"			            , "L1_TROCO1"   , "L1_TROCO1" 			                            , "Change"			                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"STATIONCODE"			        , "L1_PDV"      , "L1_PDV" 			                                , "StationCode"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTPAYMENTTERM"		    , "L1_DESCFIN"  , "L1_DESCFIN" 			                            , "DiscountPaymentTerm"		                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CREDITVALUE"			        , "L1_CREDITO"  , "L1_CREDITO" 			                            , "CreditValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"KINDOFDOCUMENT"			    , "L1_ESPECIE"  , "L1_ESPECIE" 			                            , "KindOfDocument"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"CARRIERCODE"			        , "L1_TRANSP"   , "L1_TRANSP" 			                            , "Carriercode"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"MD5"			                , "L1_PAFMD5"   , "L1_PAFMD5" 			                            , "MD5"			                                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"MOVEMENTNUMBER"			    , "L1_NUMMOV"   , "L1_NUMMOV" 			                            , "MovementNumber"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"PERSONALIDENTIFICATION"		, "L1_CGCCLI"   , "L1_CGCCLI" 			                            , "PersonalIdentification"		                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"NFCEPROTOCOL"			        , "L1_PRONFCE"  , "L1_PRONFCE" 			                            , "NfceProtocol"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"STATIONSALEPOINTCODE"			, "L1_ESTACAO"  , "L1_ESTACAO" 			                            , "StationSalePointCode"		                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SERIALNUMBERSATEQUIPAMENT"	, "L1_SERSAT"   , "L1_SERSAT" 			                            , "SerialNumberSATEquipament"	                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SALETYPE"			            , "L1_TIPO"     , "L1_TIPO" 			                            , "SaleType"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"KEYACESSNFE"			        , "L1_KEYNFCE"  , "L1_KEYNFCE" 			                            , "KeyAcessNFe"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"STATETAXBURDEN"			    , "L1_TOTEST"   , "L1_TOTEST" 			                            , "StateTaxBurden"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"MUNICIPALTAXBURDEN"			, "L1_TOTMUN"   , "L1_TOTMUN" 			                            , "MunicipalTaxBurden"			                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FEDERALTAXBURDEN"			    , "L1_TOTFED"   , "L1_TOTFED" 			                            , "FederalTaxBurden"			                            , "N"  } , 1, 3)                        
            HmAdd(self:oFields, {"TAXSOURCE"			        , "L1_LTRAN"    , "L1_LTRAN" 			                            , "TaxSource"			                                    , "C"  } , 1, 3)
			HmAdd(self:oFields, {"ECOMMERCEORDER"			    , "L1_ECPEDEC"  , "L1_ECPEDEC" 			                            , "ECommerceOrder"		                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSVALUE"   	                , "L1_VALICM"   , "L1_VALICM" 			                            , "IcmsValue"   			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ISSVALUE"			            , "L1_VALISS"   , "L1_VALISS" 			                            , "IssValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PISVALUE"			            , "L1_VALPIS"   , "L1_VALPIS" 			                            , "PisValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COFVALUE"			            , "L1_VALCOFI"  , "L1_VALCOFI" 			                            , "CofValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CSLLVALUE"		            , "L1_VALCSLL"  , "L1_VALCSLL" 			                            , "CsllValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IRRFVALUE"		            , "L1_VALIRRF"  , "L1_VALIRRF" 			                            , "IrrfValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPVALUE"		            , "L1_VALFECP"  , "L1_VALFECP" 			                            , "FecpValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPBASCALC"			        , "L1_BASFECP"  , "L1_BASFECP" 			                            , "FecpBasCalc"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPSTBASCALC"		        , "L1_BSFCPST"  , "L1_BSFCPST" 			                            , "FecpStBasCalc"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPSTVALUE"			        , "L1_VFECPST"  , "L1_VFECPST" 			                            , "FecpStValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IPIVALUE"			            , "L1_VALIPI"   , "L1_VALIPI" 			                            , "IpiValue"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IPIBASCALC"			        , "L1_BASEIPI"  , "L1_BASEIPI" 			                            , "IpiBasCalc"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSRETVALUE"		            , "L1_ICMSRET"  , "L1_ICMSRET" 			                            , "IcmsRetValue"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSRETBASCALC"		        , "L1_BRICMS"   , "L1_BRICMS" 			                            , "IcmsRetBasCalc"			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"SALESITUATION"			    , "L1_SITUA"    , "L1_SITUA" 			                            , "SaleSituation"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"UNIQUEFOREIGNKEY"			    , "L1_LTRAN"    , "L1_LTRAN" 			                            , "UniqueForeignKey"			                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"FREIGHTVALUE"   	            , "L1_FRETE"    , "L1_FRETE" 			                            , "FreightValue"   			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COMISSIONVALUE"   	        , "L1_VALCOMI"  , "L1_VALCOMI" 			                            , "ComissionValue"   			                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CARDS"   	                    , "L1_CARTAO"   , "L1_CARTAO" 			                            , "Cards"          			                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"POSSERIE"	                    , "L1_SERPDV"   , "L1_SERPDV" 			                            , "PosSerie"       			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"TYPEORC"	                    , "L1_TPORC"    , "L1_TPORC" 			                            , "TypeOrc"       			                                , "C"  } , 1, 3)

        Case self:cTable == "SL2"                       
                                //Tag                              Campo           Expressão que será executada para gerar o retorno  Tag que será utilizada para preencher o objeto de retorno   Tipo do campo
            HmAdd(self:oFields, {"ITEMCODE"				        , "L2_PRODUTO"   , "L2_PRODUTO"                                     , "ItemCode"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ITEMORDER"				    , "L2_ITEM"      , "L2_ITEM"                                        , "ItemOrder"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"QUANTITY"				        , "L2_QUANT"     , "L2_QUANT"                                       , "Quantity"				                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"UNITPRICE"				    , "L2_VRUNIT"    , "L2_VRUNIT"                                      , "UnitPrice"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ITEMPRICE"				    , "L2_VLRITEM"   , "L2_VLRITEM"                                     , "ItemPrice"			                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTPERCENTAGE"		    , "L2_DESC"      , "L2_DESC"                                        , "DiscountPercentage"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTAMOUNT"				, "L2_VALDESC"   , "L2_VALDESC"                                     , "DiscountAmount"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTTOTALPRORATED"		, "L2_DESCPRO"   , "L2_DESCPRO"                                     , "DiscountTotalProrated"                                   , "N"  } , 1, 3)
            HmAdd(self:oFields, {"OPERATIONCODE"				, "L2_CF"        , "L2_CF"                                          , "OperationCode"		                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"INCREASE"				        , "L2_VALACRS"   , "L2_VALACRS"                                     , "Increase"				                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"UNITOFMEASURECODE"			, "L2_UM"        , "L2_UM"                                          , "UnitOfMeasureCode"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"WAREHOUSECODE"				, "L2_LOCAL"     , "L2_LOCAL"                                       , "WarehouseCode"		                                    , "C"  } , 1, 3)            
            HmAdd(self:oFields, {"ITEMRESERVECODE"				, "L2_RESERVA"   , "L2_RESERVA"                                     , "ItemReserveCode"		                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ITEMDELIVERYTYPE"				, "L2_ENTREGA"   , "L2_ENTREGA"                                     , "ItemDeliveryType"		                                , "C"  } , 1, 3)          
            HmAdd(self:oFields, {"ITEMSOLD"     				, "L2_VENDIDO"   , "L2_VENDIDO"                                     , "ItemSold"        		                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"DOCUMENTCODE"    				, "L2_DOC"       , "L2_DOC"                                         , "DocumentCode"        		                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SERIECODE"    				, "L2_SERIE"     , "L2_SERIE"                                       , "SerieCode"           		                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"STATIONCODE"    				, "L2_PDV"       , "L2_PDV"                                         , "StationCode"           		                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ITEMDELIVERYDATE"				, "L2_FDTENTR"   , "L2_FDTENTR"                                     , "ItemDeliveryDate"		                                , "DF" } , 1, 3)
            HmAdd(self:oFields, {"LOTNUMBER"				    , "L2_LOTECTL"   , "L2_LOTECTL"                                     , "LotNumber"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SUBLOTNUMBER"				    , "L2_NLOTE"     , "L2_NLOTE"                                       , "SubLotNumber"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ADDRESSITEM"				    , "L2_LOCALIZ"   , "L2_LOCALIZ"                                     , "AddressItem"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SERIESITEM"				    , "L2_NSERIE"    , "L2_NSERIE"                                      , "SeriesItem"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"FISCALCONFIGURATIONCODE"		, "L2_TES"       , "L2_TES"                                         , "FiscalConfigurationCode" 			                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"TAXSITUATION"		   		    , "L2_SITTRIB"   , "L2_SITTRIB"                                     , "TaxSituation"		                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSVALUE"		 	        , "L2_VALICM"    , "L2_VALICM"                                      , "IcmsValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSBASCALC"		    		, "L2_BASEICM"   , "L2_BASEICM"                                     , "IcmsBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSPERCENTAGE"	    		, "L2_PICM"      , "L2_PICM"                                        , "IcmsPercentage"	                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSREDUCTBASPERCE"  		    , "L2_PREDIC"    , "L2_PREDIC"                                      , "IcmsReductBasPercent"                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ISSVALUE"		 		        , "L2_VALISS"    , "L2_VALISS"                                      , "IssValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ISSBASCALC"		 		    , "L2_BASEISS"   , "L2_BASEISS"                                     , "IssBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ISSPERCENTAGE"    		    , "L2_ALIQISS"   , "L2_ALIQISS"                                     , "IssPercentage"                                           , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PISVALUE"		 		        , "L2_VALPIS"    , "L2_VALPIS"                                      , "PisValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PISBASCALC"		 		    , "L2_BASEPIS"   , "L2_BASEPIS"                                     , "PisBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PISPERCENTAGE"			    , "L2_ALIQPIS"   , "L2_ALIQPIS"                                     , "PisPercentage"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PISAPURVALUE"			        , "L2_VALPS2"    , "L2_VALPS2"                                      , "PisApurValue"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PISAPURBASCALC"			    , "L2_BASEPS2"   , "L2_BASEPS2"                                     , "PisApurBasCalc"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PISAPURPERCENTAGE"		    , "L2_ALIQPS2"   , "L2_ALIQPS2"                                     , "PisApurPercentage"		                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COFVALUE"		 		        , "L2_VALCOFI"   , "L2_VALCOFI"                                     , "CofValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COFBASCALC"		 		    , "L2_BASECOF"   , "L2_BASECOF"                                     , "CofBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COFPERCENTAGE"			    , "L2_ALIQCOF"   , "L2_ALIQCOF"                                     , "CofPercentage"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COFAPURVALUE"			        , "L2_VALCF2"    , "L2_VALCF2"                                      , "CofApurValue"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COFAPURBASCALC"			    , "L2_BASECF2"   , "L2_BASECF2"                                     , "CofApurBasCalc"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"COFAPURPERCENTAGE"		    , "L2_ALIQCF2"   , "L2_ALIQCF2"                                     , "CofApurPercentage"		                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CSLLVALUE"		 		    , "L2_VALCSLL"   , "L2_VALCSLL"                                     , "CsllValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CSLLBASCALC"		 		    , "L2_BASCSLL"   , "L2_BASCSLL"                                     , "CsllBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CSLLPERCENTAGE"			    , "L2_ALQCSLL"   , "L2_ALQCSLL"                                     , "CsllPercentage"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IRRFVALUE"		 		    , "L2_VALIRRF"   , "L2_VALIRRF"                                     , "IrrfValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IRRFBASCALC"		 		    , "L2_BASIRRF"   , "L2_BASIRRF"                                     , "IrrfBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IRRFPERCENTAGE"			    , "L2_ALQIRRF"   , "L2_ALQIRRF"                                     , "IrrfPercentage"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPVALUE"		 		    , "L2_VALFECP"   , "L2_VALFECP"                                     , "FecpValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPBASCALC"		 		    , "L2_BASFECP"   , "L2_BASFECP"                                     , "FecpBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPPERCENTAGE"			    , "L2_ALQFECP"   , "L2_ALQFECP"                                     , "FecpPercentage"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPSTVALUE"		 		    , "L2_VFECPST"   , "L2_VFECPST"                                     , "FecpStValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPSTBASCALC"			    , "L2_BSFCPST"   , "L2_BSFCPST"                                     , "FecpStBasCalc"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FECPSTPERCENTAGE"		        , "L2_ALQFCST"   , "L2_ALQFCST"                                     , "FecpStPercentage"		                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IPIVALUE"		 		        , "L2_VALIPI"    , "L2_VALIPI"                                      , "IpiValue"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IPIBASCALC"		 		    , "L2_BASEIPI"   , "L2_BASEIPI"                                     , "IpiBasCalc"		                                        , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IPIPERCENTAGE"			    , "L2_IPI"       , "L2_IPI"                                         , "IpiPercentage"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSRETVALUE"			        , "L2_ICMSRET"   , "L2_ICMSRET"                                     , "IcmsRetValue"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSRETBASCALC"			    , "L2_BRICMS"    , "L2_BRICMS"                                      , "IcmsRetBasCalc"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSRETPERCENTAGE"		    , "L2_ALIQSOL"   , "L2_ALIQSOL"                                     , "IcmsRetPercentage"		                                , "N"  } , 1, 3)                        
            HmAdd(self:oFields, {"STOREIDENTIFICATIONCODE"		, "L2_LOJARES"   , "L2_LOJARES"                                     , "StoreIdentificationCode"			                        , "C"  } , 1, 3)
            HmAdd(self:oFields, {"RESERVEBRANCH"				, "L2_FILRES"    , "L2_FILRES"                                      , "ReserveBranch"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SELLERITEM"			    	, "L2_VEND"      , "L2_VEND"                                        , "SellerItem"			                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"INCREASEITEM"		            , "L2_VALACRS"   , "L2_VALACRS"                                     , "IncreaseItem"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ITEMTABLEPRICE"		        , "L2_PRCTAB"    , "L2_PRCTAB"                                      , "ItemTablePrice"		                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FREIGHTVALUEPRORATED"		    , "L2_VALFRE"    , "L2_VALFRE"                                      , "FreightValueProrated"		                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"INCREASEVALUEPRORATED"		, "L2_DESPESA"   , "L2_DESPESA"                                     , "IncreaseValueProrated"		                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"CODETAXSITUATIONPIS"  		, "L2_CSTPIS"    , "L2_CSTPIS"                                      , "CodeTaxSituationPis"		                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"CODETAXSITUATIONCOF"  		, "L2_CSTCOF"    , "L2_CSTCOF"                                      , "CodeTaxSituationCof"		                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"CODETAXSITUATIONICMS"  		, "L2_CLASFIS"   , "L2_CLASFIS"                                     , "CodeTaxSituationIcms"		                            , "C"  } , 1, 3)
                
        Case self:cTable == "SL4"
            //|                 //Tag                              Campo           Expressão que será executada para gerar o retorno  Tag que será utilizada para preencher o objeto de retorno   Tipo do campo
            HmAdd(self:oFields, {"DATEOFPAYMENT"			    , "L4_DATA"      , "L4_DATA"                                        , "DateOfPayment"			                                , "DF" } , 1, 3)
            HmAdd(self:oFields, {"PAYMENTVALUE"				    , "L4_VALOR"     , "L4_VALOR"                                       , "PaymentValue"				                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"PAYMENTMETHODCODE"			, "L4_FORMA"     , "L4_FORMA"                                       , "PaymentMethodCode"		                                , "C"  } , 1, 3)            
            HmAdd(self:oFields, {"FINANCIALMANAGERCODE"			, "L4_ADMINIS"   , "L4_ADMINIS"                                     , "FinancialManagerCode"		                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"CARDNUMBER"				    , "L4_NUMCART"   , "L4_NUMCART"                                     , "CardNumber"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"SERIECHECK"				    , "L4_SERCHQ"    , "L4_SERCHQ"                                      , "SerieCheck"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"BANKCHECK"				    , "L4_ADMINIS"   , "L4_ADMINIS"                                     , "BankCheck"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"AGENCYCHECK"				    , "L4_AGENCIA"   , "L4_AGENCIA"                                     , "AgencyCheck"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ACCOUNTCHECK"				    , "L4_CONTA"     , "L4_CONTA"                                       , "AccountCheck"				                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"DOCUMENTOFIDENTIFICATION"     , "L4_RG"        , "L4_RG"                                          , "DocumentOfIdentification"                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"PHONENUMBER"				    , "L4_TELEFON"   , "L4_TELEFON"                                     , "PhoneNumber"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"EFTDATE"				        , "L4_DATATEF"   , "L4_DATATEF"                                     , "EftDate"				                                    , "D" } , 1, 3)
            HmAdd(self:oFields, {"EFTDOCUMENT"				    , "L4_DOCTEF"    , "L4_DOCTEF"                                      , "EftDocument"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"EFTAUTORIZATION"			    , "L4_AUTORIZ"   , "L4_AUTORIZ"                                     , "EftAutorization"			                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"EFTCANCELLATIONDATE"			, "L4_DATCANC"   , "L4_DATCANC"                                     , "EftCancellationDate"		                                , "D" } , 1, 3)
            HmAdd(self:oFields, {"EFTCANCELLATIONDOCUMENT"		, "L4_DOCCANC"   , "L4_DOCCANC"                                     , "EftCancellationDocument"	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"EFTINSTITUTE"				    , "L4_INSTITU"   , "L4_INSTITU"                                     , "EftInstitute"				                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"UNIQUESERIALNUMBER"			, "L4_NSUTEF"    , "L4_NSUTEF"                                      , "UniqueSerialNumber"		                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"EFTPARCEL"				    , "L4_PARCTEF"   , "L4_PARCTEF"                                     , "EftParcel"				                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"FINANCIALDOCUMENTCODE"	    , "L4_IDCNAB"    , "L4_IDCNAB"                                      , "FinancialDocumentCode"	                                , "C"  } , 1, 3)
			HmAdd(self:oFields, {"NOTE"	                        , "L4_OBS"       , "L4_OBS"                                         , "Note"                	                                , "C"  } , 1, 3)
			
    End Case

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSelect
Carrega a query que será executada

@author  rafael.pessoa
@since   09/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSelect(cTable) Class RetailSalesObj

    Local cInternalId   := ""
    Local aParam        := {}
    Local cSelect       := ""
    Local cWhere        := ""
    Local cGroupBy      := ""

    cSelect := "SELECT * FROM " + RetSqlName("SL1") + " SL1"    
    cSelect += " INNER JOIN " + RetSqlName("SL2") + " SL2"
    cSelect +=  " ON L1_FILIAL = L2_FILIAL AND L1_NUM = L2_NUM AND SL1.D_E_L_E_T_ = SL2.D_E_L_E_T_"
    cSelect += " LEFT JOIN " +  RetSqlName("SL4") + " SL4"
    cSelect +=  " ON L1_FILIAL = L4_FILIAL AND L1_NUM = L4_NUM AND SL1.D_E_L_E_T_ = SL4.D_E_L_E_T_"
    cWhere  += "WHERE SL1.D_E_L_E_T_ = ' '"

	//Carrega Filtro do InternalId
	If self:oWsRestObj:internalId <> Nil .And. !Empty(self:oWsRestObj:internalId)
		cInternalId := self:oWsRestObj:internalId
    EndIf

	If !Empty(cInternalId)
		aParam := Separa(cInternalId, "|")

		If !Empty(aParam)
			cWhere += " AND L1_FILIAL = '" + aParam[1] + "' AND L1_NUM = '" + aParam[2] + "'"
		EndIf
	EndIf

    self:cTable     := cTable
    self:cSelect    := cSelect
    self:cWhere     := cWhere
    self:cGroupBy   := cGroupBy

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecAuto
Executa a ExecAuto da RetailSales

@author  rafael.pessoa
@since   09/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method ExecAuto() Class RetailSalesObj
    
    Local aRetorno := {}

    //Chama gravação de venda\cancelamento utilizada pelo RMI
    Self:SetTes()
    If Self:lSuccess

        SetFunName("RetailSales")
        aRetorno := RsGrvVenda(self:aExecAuto[1], self:aExecAuto[2], self:aExecAuto[3], 3)

        If !aRetorno[1]
            
            self:lSuccess    := .F.
            self:nStatusCode := 404
            self:cError      := STR0001 + CRLF + aRetorno[2]    //"Não foi possível realizar a execução automática."
        Else

            self:cInternalId := SL1->L1_FILIAL + "|" + SL1->L1_NUM
            self:cBody 		 := '{ "InternalId": "' + self:cInternalId + '" }'
        EndIf

    EndIf

    aSize(aRetorno, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecLoja701
Executa a ExecAuto do LOJA701

@author  Bruno Almeida
@since   08/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method ExecLoja701() Class RetailSalesObj
    
    Local aErroAuto := {}   //Logs de erro do ExecAuto
    Local nI        := 0    //Variavel de loop

    Private lMsErroAuto     := .F.  //Variavel que informa a ocorrência de erros no ExecAuto
	Private lAutoErrNoFile  := .T.  //Habilita a gravacao do erro da rotina automatica
	Private lMsHelpAuto     := .T.

    //Ajusta os campos do array, considerando que o 
    //ExecAuto do LOJA701 espera receber os campos da SLQ e SLR
    Self:FormatVar()

    //Verifica se existe itens para entrega == 3, com base nessa informação altera alguns campos 
    //do cabeçalho da venda igual é feito na rotina da Vtex (LOJI701O.PRW)
    Self:PedVen()

    //Chama gravação de venda
    Begin Transaction
        SetFunName("LOJA701")
       
       // -- PE para alteração do orçamento antes da execução do execAuto. 
        If ExistBlock("RSAPI001")
            LjGrvLog("RSAPI001", "PE RSAPI001 compilado")
            LjGrvLog("RSAPI001", "Antes do PE RSAPI001 -> {SL1,SL2,SL4}",{Self:aExecAuto[1],Self:aExecAuto[2],Self:aExecAuto[3]})
			
            aRet := ExecBlock("RSAPI001",.F.,.F.,{Self:aExecAuto[1], Self:aExecAuto[2],Self:aExecAuto[3] })
            
			If ValType( aRet ) == "A" .AND. Len(aRet) == 3 
				Self:aExecAuto[1] := aRet[1]
                Self:aExecAuto[2] := aRet[2]
                Self:aExecAuto[3] := aRet[3]
			EndIf

            LjGrvLog("RSAPI001", "Depois do PE RSAPI001 -> {SL1,SL2,SL4}",{Self:aExecAuto[1],Self:aExecAuto[2],Self:aExecAuto[3]})
		EndIf

        MSExecAuto({|a,b,c,d,e,f,g,h,i,j| Loja701(a,b,c,d,e,f,g,h,i,j)}, .F., 3, "", "", {}, Self:aExecAuto[1], Self:aExecAuto[2], Self:aExecAuto[3],.F.,.T.)

        If lMsErroAuto
            //Erro na ExecAuto
            aErroAuto   := GetAutoGrLog()
            Self:cError := ""

            //Armazena mensagens de erro
            For nI := 1 To Len(aErroAuto)
                Self:cError += aErroAuto[nI] + Chr(10)
            Next nI
                                            
            DisarmTransaction()

            //Libera sequencial 
            RollBackSx8()
            MsUnLockAll()

            self:lSuccess    := .F.
            self:nStatusCode := 404

            LjGrvLog("RetailSalesObj", "Falha ao executar MsExecAuto Loja701(ExecLoja701):", {self:lSuccess, self:nStatusCode, self:cError}, .T.)
        Else
            //Sucesso na ExecAuto
            ConfirmSx8()
        
            RecLock("SL1", .F.)
                SL1->L1_SITUA := "RX"
                If Self:lPedVend
                    SL1->L1_DOCPED  := SL1->L1_DOC
                    SL1->L1_SERPED  := SL1->L1_SERIE
                    SL1->L1_DOC     := ""
                    SL1->L1_SERIE   := ""
                    SL1->L1_NUMCFIS := ""
                    SL1->L1_TIPO    := "P"
                    SL1->L1_RESERVA := "S"
                    Self:lPedVend   := .F.
                EndIf
            SL1->(MsUnLock())

            Self:cInternalId := SL1->L1_FILIAL + "|" + SL1->L1_NUM
            Self:cBody 		 := '{ "InternalId": "' + Self:cInternalId + '" }'
        EndIf
    End Transaction

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PedVen
Verifica se existe itens para entrega == 3, com base nessa informação altera alguns campos 
do cabeçalho da venda igual é feito na rotina da Vtex (LOJI701O.PRW)

@author  Bruno Almeida
@since   08/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method PedVen() Class RetailSalesObj

    Local nI            := 0 //Variavel de loop
    Local nPosEntrega   := 0 //Posicao do campo LR_ENTREGA
    Local nPosDocL2     := 0 //Posicao do campo LR_DOC
    Local nPosSerL2     := 0 //Posicao do campo LR_SERIE
    Local nPosVendid    := 0 //Posicao do campo LR_VENDIDO

    For nI := 1 To Len(Self:aExecAuto[2])
        nPosEntrega := aScan(Self:aExecAuto[2][nI], {|x| x[1] == "LR_ENTREGA"})
        If nPosEntrega > 0 .AND. !Empty(Self:aExecAuto[2][nI][nPosEntrega][2]) .AND. AllTrim(Self:aExecAuto[2][nI][nPosEntrega][2]) <> "2"
            Self:lPedVend := .T.

            nPosDocL2   := aScan(Self:aExecAuto[2][nI], {|x| x[1] == "LR_DOC"})
            nPosSerL2   := aScan(Self:aExecAuto[2][nI], {|x| x[1] == "LR_SERIE"})
            nPosVendid  := aScan(Self:aExecAuto[2][nI], {|x| x[1] == "LR_VENDIDO"})

            If nPosDocL2 > 0
                Self:aExecAuto[2][nI][nPosDocL2][2] := ""
            EndIf

            If nPosSerL2 > 0
                Self:aExecAuto[2][nI][nPosSerL2][2] := ""
            EndIf

            If nPosVendid > 0
                Self:aExecAuto[2][nI][nPosVendid][2] := ""
            EndIf

        EndIf
    Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FormatVar
Metodo para ajustar o array da SL1, SL2 e SL4 para enviar na estrutura
que o execauto do LOJA701 espera.

@author  Bruno Almeida
@since   08/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method FormatVar() Class RetailSalesObj

    Local nI            := 0 //Variavel de Loop
    Local nX            := 0 //Variavel de Loop
    Local nPosFormaId   := 0 //Posicao do campo L4_FORMAID
    Local aCpoL1        := {"LQ_CLIENTE","LQ_LOJA","LQ_VEND"}
    Local nPos          := 0 //Posicao dos campos

    //Altera o nome dos campos da SL1
    For nI := 1 To Len(Self:aExecAuto[1])
        Self:aExecAuto[1][nI][1] := "LQ_" + SubStr(Self:aExecAuto[1][nI][1],4)        
    Next nX

    //Altera o nome dos campos da SL2
    For nI := 1 To Len(Self:aExecAuto[2])
        For nX := 1 To Len(Self:aExecAuto[2][nI])
            Self:aExecAuto[2][nI][nX][1] := "LR_" + SubStr(Self:aExecAuto[2][nI][nX][1],4)
        Next nX
    Next nX

    //Add o campo FormaID
    For nI := 1 To Len(Self:aExecAuto[3])
        nPosFormaId := aScan(Self:aExecAuto[3][nI], {|x| x[1] == "L4_FORMAID"})
        If nPosFormaId == 0            
            Aadd(Self:aExecAuto[3][nI],{"L4_FORMAID", "", Nil})
        EndIf
    Next nX

    //Formata com PadR os campos do array aCpoL1 (SL1)
    For nI := 1 To Len(aCpoL1)
        nPos := aScan(Self:aExecAuto[1], {|x| x[1] == aCpoL1[nI]})
        If nPos > 0
            Self:aExecAuto[1][nPos][2] := Padr(Self:aExecAuto[1][nPos][2], TamSx3(aCpoL1[nI])[1])
        EndIf
    Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTes
Metodo para setar a tes no array

@author  Bruno Almeida
@since   02/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTes() Class RetailSalesObj

    Local nI            := 0    //Variavel de loop
    Local cAuxOpeCod    := ""   //Operação fiscal tag OperationCode
    Local nPosCf        := 0    //Posição do campo L2_CF
    Local cTesPrd       := ""   //Tes que sera gravado no campo L2_TES
    Local cTpOpera      := ""   //Código da operação
    Local cCodCli       := ""   //Codigo do cliente
    Local cLojCli       := ""   //Codigo da loja
    Local cProduto      := ""   //Codigo do produto
    Local nPosCli       := 0    //Posicao do codigo do cliente
    Local nPosLoj       := 0    //Posicao da loja do cliente
    Local nPosProd      := 0    //Posicao do codigo do produto
    Local cCfop         := ""   //Codigo do CFOP
    Local cTpVenda      := ""   //Tipo da venda
    Local nPosEspec     := 0    //Posicao do campo L1_ESPECIE
    Local nPosTes       := 0    //Posicao do campo L2_TES
    Local aArea		    := GetArea() //Salva a area atual
    Local cMsgRet       := "" //Guarda a mensagem de erro

    If Len(Self:aExecAuto[1]) > 0 .AND. Len(Self:aExecAuto[2]) > 0

        nPosCli := aScan(Self:aExecAuto[1], {|x| x[1] == "L1_CLIENTE"})
        nPosLoj := aScan(Self:aExecAuto[1], {|x| x[1] == "L1_LOJA"})

        If nPosCli > 0
            cCodCli := Self:aExecAuto[1][nPosCli][2]
        EndIf

        If nPosLoj > 0
            cLojCli := Self:aExecAuto[1][nPosLoj][2]
        EndIf

        For nI := 1 To Len(Self:aExecAuto[2])
            cCfop   := ""
            cTesPrd := ""
            nPosTes := aScan(Self:aExecAuto[2][nI], {|x| x[1] == "L2_TES"})

            //Só tenta pegar a TES se não foi enviado na API
            If (nPosTes > 0 .AND. Empty(Self:aExecAuto[2][nI][nPosTes][2])) .OR. (nPosTes == 0)

                nPosCf      := aScan(Self:aExecAuto[2][nI], {|x| x[1] == "L2_CF"})
                nPosProd    := aScan(Self:aExecAuto[2][nI], {|x| x[1] == "L2_PRODUTO"})

                If nPosProd > 0
                    cProduto := Padr(Self:aExecAuto[2][nI][nPosProd][2], TamSx3("L2_PRODUTO")[1])
                EndIf

                If nPosCf > 0
                    cAuxOpeCod := Self:aExecAuto[2][nI][nPosCf][2]
                EndIf

                If Len(Alltrim(cAuxOpeCod)) <= 2

                    cTpOpera := Padr(cAuxOpeCod,TamSX3('FM_TIPO')[1] )
                    cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)

                    LjGrvLog("RetailSalesObj","TES Inteligente 1- Codigo da Operacao  : " + cTpOpera + " ,Codigo do Cliente: " + AllTrim(cCodCli) + "/" + "Loja:" + " " + cLojCli + " , Produto: " + AllTrim(cProduto) + ". Retorno TES: " + cTesPrd )
                                                                    
                    If Empty(cTesPrd)
                        cTpOpera := "01" //Inicializa tipo de operacao para Tes Inteligente
                        cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)
                    Endif

                    LjGrvLog("RetailSalesObj","TES Inteligente 2- Codigo da Operacao  : " + cTpOpera + " ,Codigo do Cliente: " + AllTrim(cCodCli) + "/" + "Loja:" + " " + cLojCli + " , Produto: " + AllTrim(cProduto) + ". Retorno TES: " + cTesPrd )

                //Tes
                Elseif 	Len(Alltrim(cAuxOpeCod)) == 3
                    cTesPrd := Alltrim(cAuxOpeCod)
                
                //Cfop
                ElseIf Len(Alltrim(cAuxOpeCod)) == 4
                    cCfop 	:= Padr(cAuxOpeCod, TamSx3("L2_CF")[1])
                
                EndIf

                LjGrvLog("RetailSalesObj","TES Inteligente 3- Codigo da Operacao  : " + cTpOpera + " ,Codigo do Cliente: " + AllTrim(cCodCli) + "/" + "Loja:" + " " + cLojCli + " , Produto: " + cProduto + ". Retorno TES: " + cTesPrd )

                //Se nao encontrou Tes Inteligente continua a busca
                If Empty(cTesPrd)
                    SBZ->(dbSetOrder(1)) //BZ_FILIAL+BZ_COD
                    SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
                    If AllTrim(SuperGetMv("MV_ARQPROD",, "SB1")) == "SBZ" .And.;
                            SBZ->(dbSeek(xFilial("SBZ") + cProduto)) .And. !Empty(SBZ->BZ_TS) //Busca Tes na SBZ
                    
                        cTesPrd := SBZ->BZ_TS
                    ElseIf SB1->(dbSeek(xFilial("SB1") + cProduto)) .AND. !Empty(SB1->B1_TS) //Busca Tes na SB1
                        cTesPrd := SB1->B1_TS
                    Else //Busca Tes no parametro
                        
                        If Empty(cTpVenda)
                            nPosEspec := aScan(Self:aExecAuto[1], {|x| x[1] == "L1_ESPECIE"})

                            If nPosEspec > 0
                                cTpVenda := AllTrim(Self:aExecAuto[1][nPosEspec][2])
                            EndIf
                        EndIf

                        If cTpVenda == "RPS"
                            cTesPrd := SuperGetMv("MV_TESSERV") //Tes para Servico
                        Else
                            cTesPrd := SuperGetMv("MV_TESVEND") //Tes para Venda
                        EndIf
                    EndIf
                EndIf
            
                //Validacao TES
                If Empty(cTesPrd)
                    cMsgRet             := STR0009 + " " + AllTrim(cProduto) + ", " + STR0010 //#"Inconsistencia no produto" ##"TES nao informada, verifique o Cadastro de Produto no Protheus campo B1_TS e/ou as configurações para TES Inteligente(DHJ e SFM) e/ou parametros MV_TESSERV e MV_TESVEND."
                    Self:lSuccess       := .F.
                    Self:nStatusCode    := 404
                    Self:cError         := cMsgRet
                    LjGrvLog("RetailSalesObj", cMsgRet)
                    Exit
                Else
                    If nPosTes > 0
                        Self:aExecAuto[2][nI][nPosTes][2] := cTesPrd
                    Else
                        Aadd(Self:aExecAuto[2][nI],{"L2_TES", cTesPrd, Nil})
                    EndIf
                EndIf

                //Não atualizar o CFOP quando recebeu a integração com o código de CFOP
                If Empty(cCfop)
                    cTesPrd := PadR(cTesPrd,TamSx3('F4_CODIGO')[1])
                    
                    dbSelectArea('SF4')
                    SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO

                    If SF4->(dbSeek(xFilial('SF4')+cTesPrd))
                        cCfop := SF4->F4_CF

                        If nPosCf > 0
                            Self:aExecAuto[2][nI][nPosCf][2] := cCfop
                        Else
                            Aadd(Self:aExecAuto[2][nI],{"L2_CF", cCfop, Nil})
                        EndIf
                    EndIf                    
                EndIf

            EndIf

        Next nI
        
    EndIf
    RestArea(aArea)

Return .T.
