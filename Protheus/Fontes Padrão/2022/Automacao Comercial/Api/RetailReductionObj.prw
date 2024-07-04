#INCLUDE "PROTHEUS.CH"
//#INCLUDE "RETAILREDUCTIONAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RetailReductionObj
    Classe para tratamento da API de Redução Z do Varejo
/*/
//-------------------------------------------------------------------
Class RetailReductionObj From LojRestObj

	Method New(oWsRestObj)  Constructor

    Method SetFields()
    Method SetTables()
    Method ExecAuto()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API

@author  rafael.pessoa
@since   26/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class RetailReductionObj

    _Super:New(oWsRestObj)
    self:SetTables()
    self:lRetHasNext := .T. //Define o tipo de retorno como array

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega as Tabelas de trabalho

@author  rafael.pessoa
@since   26/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTables() Class RetailReductionObj
    Aadd(self:aTables, {"SFI", ""})
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos que serão retornados

@author  rafael.pessoa
@since   26/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class RetailReductionObj

    Do Case

        Case self:cTable == "SFI"

            //|                 //Tag                              Campo           Expressão que será executada para gerar o retorno  Tag que será utilizada para preencher o objeto de retorno   Tipo do campo
            HmAdd(self:oFields, {"BRANCHID"	                 	    , "FI_FILIAL"     , "FI_FILIAL"                                         , "BranchId"	                                	, "C"  } , 1, 3)
            HmAdd(self:oFields, {"MOVEMENTDATE"	             	    , "FI_DTMOVTO"    , "FI_DTMOVTO"                                        , "MovementDate"	                                , "DF" } , 1, 3)
            HmAdd(self:oFields, {"ID"	                         	, "FI_NUMERO"     , "FI_NUMERO"                                         , "Id"	                                			, "C"  } , 1, 3)			
            HmAdd(self:oFields, {"POSNUMBER"	                 	, "FI_PDV"    	  , "FI_PDV"    	                                    , "PosNumber"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"POSSERIENUMBER"	             	, "FI_SERPDV"     , "FI_SERPDV"                                         , "PosSerieNumber"	                                , "C"  } , 1, 3)			
            HmAdd(self:oFields, {"REDUCTIONCODE"	             	, "FI_NUMREDZ"    , "FI_NUMREDZ"                                        , "ReductionCode"	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"INITIALVALUE"	             	    , "FI_GTINI"      , "FI_GTINI"                                          , "InitialValue"	                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FINALVALUE"	                 	, "FI_GTFINAL"    , "FI_GTFINAL"                                        , "FinalValue"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"INITIALCOUNTER"	             	, "FI_NUMINI"     , "FI_NUMINI"                                         , "InitialCounter"	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"FINALCOUNTER"	             	    , "FI_NUMFIM"     , "FI_NUMFIM"                                         , "FinalCounter"	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"VALUECANCELLATIONS"	         	, "FI_CANCEL"     , "FI_CANCEL"                                         , "ValueCancellations"	                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"SALESVALUENET"	             	, "FI_VALCON"     , "FI_VALCON"                                         , "SalesValueNet"	                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"TAXREPLACEMENTVALUE"	         	, "FI_SUBTRIB"    , "FI_SUBTRIB"                                        , "TaxReplacementValue"	                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DISCOUNTVALUE"	             	, "FI_DESC"       , "FI_DESC"                                           , "DiscountValue"	                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"FREEVALUE"	                 	, "FI_ISENTO"     , "FI_ISENTO"                                         , "FreeValue"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"UNTAXEDVALUE"	             	    , "FI_NTRIB"      , "FI_NTRIB"                                          , "UntaxedValue"	                                , "N"  } , 1, 3)			
            HmAdd(self:oFields, {"ICMSBAS7"	                 	    , "FI_BAS7"       , "FI_BAS7"                                           , "IcmsBas7"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSBAS12"	                 	, "FI_BAS12"      , "FI_BAS12"                                          , "IcmsBas12"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSBAS18"	                 	, "FI_BAS18"      , "FI_BAS18"                                          , "IcmsBas18"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ICMSBAS25"	                 	, "FI_BAS25"      , "FI_BAS25"                                          , "IcmsBas25"	                                    , "N"  } , 1, 3)			
            HmAdd(self:oFields, {"COUNTERCODE"	                 	, "FI_COO"        , "FI_COO"                                            , "CounterCode"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"VALUEOFOTHERSRECEIVABLES"	 	    , "FI_OUTROSR"    , "FI_OUTROSR"                                        , "ValueOfOthersReceivables"	                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"AMOUNTOFTAXDUE"	             	, "FI_IMPDEBT"    , "FI_IMPDEBT"                                        , "AmountOfTaxDue"	                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ISSVALUE"	                 	    , "FI_ISS"        , "FI_ISS"                                            , "IssValue"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"REDUCTIONSITUATION"	         	, "FI_SITUA"      , "FI_SITUA"                                          , "ReductionSituation"	                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"COUNTERRESET"	             	    , "FI_CRO"        , "FI_CRO"                                            , "CounterReset"	                                , "C"  } , 1, 3)			
            HmAdd(self:oFields, {"ICMSBASMG"	                 	, "FI_BAS001"     , "FI_BAS001"                                         , "IcmsBasMG"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"DETAILS"	                     	, "FI_OBS"        , "FI_OBS"                                            , "Details"	                                        , "C"  } , 1, 3)			
            HmAdd(self:oFields, {"ISSUEDATEREDUCTION"	         	, "FI_DTREDZ"     , "FI_DTREDZ"                                         , "IssueDateReduction"	                            , "DF" } , 1, 3)
            HmAdd(self:oFields, {"ISSUEHOURREDUCTION"	         	, "FI_HRREDZ"     , "FI_HRREDZ"                                         , "IssueHourReduction"	                            , "C"  } , 1, 3)
            HmAdd(self:oFields, {"LASTDOCBC"	                 	, "FI_DOCBC"      , "FI_DOCBC"                                          , "LastDocBC"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"LASTDOCA"	                 	    , "FI_DOCA"       , "FI_DOCA"                                           , "LastDocA"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"DOCFISCALVALUE"	             	, "FI_DOCFIS"     , "FI_DOCFIS"                                         , "DocFiscalValue"	                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IVAFISCALVALUE"	             	, "FI_IVAFIS"     , "FI_IVAFIS"                                         , "IvafiscalValue"	                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"TAXINTVALUE"	                 	, "FI_IINTFIS"    , "FI_IINTFIS"                                        , "TaxIntValue"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"TAXPERCENT"	                 	, "FI_PERCFIS"    , "FI_PERCFIS"                                        , "TaxPercent"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"LASTNCCBC"	                 	, "FI_NCREDBC"    , "FI_NCREDBC"                                        , "LastNccBC"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"LASTNCCA"	                 	    , "FI_NCREDA"     , "FI_NCREDA"                                         , "LastNccA"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"NCCVALUE"	                 	    , "FI_NCRED"      , "FI_NCRED"                                          , "NccValue"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"IVANCCVALUE  "	             	, "FI_IVANCC"     , "FI_IVANCC"                                         , "IvaNccValue" 	                                , "N"  } , 1, 3)
            HmAdd(self:oFields, {"INTNCCVALUE"	                 	, "FI_IINTNCC"    , "FI_IINTNCC"                                        , "IntNccValue"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"NCCPERCENT"	                 	, "FI_PERCNCC"    , "FI_PERCNCC"                                        , "NccPercent"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"LASTREMIT"	                 	, "FI_ULTREMI"    , "FI_ULTREMI"                                        , "LastRemit"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"MD5"         	             	    , "FI_PAFMD5"     , "FI_PAFMD5"                                         , "Md5"         	                                , "C"  } , 1, 3)
            HmAdd(self:oFields, {"BAS12RATE"	                 	, "FI_COD12"      , "FI_COD12"                                          , "Bas12Rate"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"BAS18RATE"	                 	, "FI_COD18"      , "FI_COD18"                                          , "Bas18Rate"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"BAS25RATE"	                 	, "FI_COD25"      , "FI_COD25"                                          , "Bas25Rate"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"BAS7RATE"	                 	    , "FI_COD7"       , "FI_COD7"                                           , "Bas7Rate"	                                    , "C"  } , 1, 3)
            HmAdd(self:oFields, {"ISSDISCOUNT"	                 	, "FI_DESISS"     , "FI_DESISS"                                         , "IssDiscount"	                                    , "N"  } , 1, 3)
            HmAdd(self:oFields, {"ISSCANCELLATIONS"	         	    , "FI_CANISS"     , "FI_CANISS"                                         , "IssCancellations"	                            , "N"  } , 1, 3)
            HmAdd(self:oFields, {"MD5TAX"      	             	    , "FI_MD5TRIB"    , "FI_MD5TRIB"                                        , "Md5Tax"      	                                , "C"  } , 1, 3) 

    End Case

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ExecAuto
Executa a ExecAuto da Reduction Z

@author  rafael.pessoa
@since   26/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method ExecAuto() Class RetailReductionObj

    Local lRet      := .F.
    Local aErroAuto := {}
    Local nI        := 0
    Local lConSfi   := .F. //Retorno da funcao LjxConSfi

    Private lMsHelpAuto 		:= .T. //Variavel de controle interno do ExecAuto
    Private lMsErroAuto 		:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
    Private lAutoErrNoFile 	    := .T. //força a gravação das informações de erro em array 

    SetFunName("RetailReduction")
    
    lConSfi := LjxConSfi(self:aExecAuto[1])

    If !lConSfi
        lRet := MsExecAuto( {|a,b| RetailReduction(a,b)}, self:aExecAuto[1], 3)
    EndIf

    If lConSfi .Or. lMsErroAuto .Or. !lRet
        
        self:lSuccess    := .F.

        If lConSfi
            self:nStatusCode := 404
            self:cError      := "Redução já existe cadastrado na base."   //"Redução já existe cadastrado na base."
        Else
            self:nStatusCode := 404
            self:cError      := "Não foi possível realizar a execução automática."   //"Não foi possível realizar a execução automática."
        EndIf

        aErroAuto := GetAutoGrLog() 
        For nI := 1 To Len(aErroAuto)
            self:cDetail += aErroAuto[nI] + CRLF
        Next nI
    
    Else

        self:cInternalId := SFI->FI_FILIAL + "|" + DToS(SFI->FI_DTMOVTO) + "|" + RTrim(SFI->FI_PDV) + "|" + RTrim(SFI->FI_NUMERO)
    EndIf

    aSize(aErroAuto, 0)

Return Nil