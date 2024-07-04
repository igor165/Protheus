#include 'protheus.ch'
#include 'FwAdapterEAI.ch'
#include 'TMSA250.CH'

/*
=========================================================================================================
/{Protheus.doc} TDResultClass
//TODO Classe para guardar o retorno dos Impostos
@author  tiago.dsantos
@since   01/02/2017
@version 1.000

@type class
=========================================================================================================
/*/
Class TDTaxationClass
      DATA nISS         AS Numeric
      DATA nISSAliq     AS Numeric 
      DATA nCOFINS      AS Numeric
      DATA nCOFINSAliq  AS Numeric
      DATA nIRRF        AS Numeric
      DATA nIRRFAliq    AS Numeric
      DATA nINSS        AS Numeric
      DATA nINSSAliq    AS Numeric
      DATA nSEST        AS Numeric
      DATA nSESTAliq    AS Numeric
      DATA nSENAT       As Numeric
      DATA nSENATAliq   As Numeric
      DATA nPIS         AS Numeric
      DATA nPISAliq     AS Numeric
      DATA nCSLL        AS Numeric
      DATA nCSLLAliq    AS Numeric
      DATA nICMS        AS Numeric
      DATA nICMSAliq    AS Numeric
      
      Method New() Constructor
      Method SetTaxProp()

EndClass
/*/
=========================================================================================================
{Protheus.doc} New
//TODO Construtor da Classe TDTaxationClass
@author tiago.dsantos
@since 30/03/2017
@version undefined

@type function
=========================================================================================================
/*/
Method New() Class TDTaxationClass
      SELF:nISS        := 0
      SELF:nISSAliq    := 0 
      SELF:nCOFINS     := 0
      SELF:nCOFINSAliq := 0
      SELF:nIRRF       := 0
      SELF:nIRRFAliq   := 0
      SELF:nINSS       := 0
      SELF:nINSSAliq   := 0
      SELF:nSEST       := 0
      SELF:nSESTAliq   := 0
      SELF:nSENAT      := 0
      SELF:nSENATAliq  := 0
      SELF:nPIS        := 0
      SELF:nPISAliq    := 0
      SELF:nCSLL       := 0
      SELF:nCSLLAliq   := 0
      SELF:nICMS       := 0
      SELF:nICMSAliq   := 0
Return Nil
/*
=========================================================================================================
/{Protheus.doc} SetTaxProp
//TODO : preenche as propriedades de impostos
@author  tiago.dsantos
@since   30/03/2017
@version 1.0
@param cId     , characters, id do impostos( aceitos: ISS,COFINS,IRRF-PF,IRRF-PJ,IRRF,INSS-PF,INSS-PJ,INSS,SEST/SENAT,PIS,CSLL,ICM
@param nValue  , numeric   , valor do imposto
@param nAliq   , numeric   , percentual equivalente
@param cPessoa , characters, tipo de pessoa PF-FISCA ou PJ-JURIDICA
@type metodo.
=========================================================================================================
/*/
Method SetTaxProp(cId, nValue,nAliq,cPessoa)  Class TDTaxationClass

       If cId == "ISS"
            SELF:nISS        := nValue
            SELF:nISSAliq    := nAliq
       EndIf
       If cId == "COFINS"  
            SELF:nCOFINS     := nValue
            SELF:nCOFINSAliq := nAliq
       EndIf
       If ("IRRF-" + cPessoa $ cId) .Or. cId == "IRRF" 
            SELF:nIRRF       := nValue
            SELF:nIRRFAliq   := nAliq
       EndIf
       If ("INSS-"  + cPessoa $ cId) .Or. cId == "INSS"  
            SELF:nINSS       := nValue
            SELF:nINSSAliq   := nAliq
       EndIf
       If cId == "SEST/SENAT"
            SELF:nSEST       := nValue
            SELF:nSESTAliq   := nAliq
       EndIf
       If cId == "SEST"
            SELF:nSEST       := nValue
            SELF:nSESTAliq   := nAliq
       EndIf
       If cId == "SENAT"
            SELF:nSENAT       := nValue
            SELF:nSENATAliq   := nAliq
       EndIf
       If cId == "PIS"
            SELF:nPIS        := nValue
            SELF:nPISAliq    := nAliq
       EndIf
       If cId == "CSLL"
            SELF:nCSLL       := nValue
            SELF:nCSLLAliq   := nAliq
       EndIf
       If cId == "ICM"
            SELF:nICMS       := nValue
            SELF:nICMSAliq   := nAliq
       EndIf

Return Nil

/*
=========================================================================================================
/{Protheus.doc} TDResultClass
//TODO Classe para guardar o retorno do processamento do titulo pela marca receptora
@author  tiago.dsantos
@since   01/02/2017
@version 1.000

@type class
=========================================================================================================
/*/
Class TDResultClass
     
       DATA cDocumentNumber   //| Numero
       DATA cDocumentPrefix   //| Prefixo
       DATA cDocumentType     //| Tipo do Documento/Especie
       DATA nDocumentParcel   //| Parcela
       DATA cIssueDate        //| Data de Emissão
       DATA cDueDate          //| Data de Vencimento
       
       Method New() Constructor
EndClass
Method New() Class TDResultClass
       SELF:cDocumentNumber := "" //| Numero
       SELF:cDocumentPrefix := "" //| Prefixo
       SELF:cDocumentType   := "" //| Prefixo
       SELF:nDocumentParcel := 1  //| Parcela
       SELF:cIssueDate      := "" //| Data de Emissão
       SELF:cDueDate        := "" //| Data de Vencimento
Return Nil

/*
======================================================================================================
/{Protheus.doc} TransportDocumentClass
(long_description)
@author tiago.dsantos
@since 27/09/2016
@version 1.0
@example
(examples)
@see (links_or_references)
======================================================================================================
/*/
Class TransportDocumentClass

          data cVIAGEM         AS STRING
          data cFILORI         AS STRING
          data cPREFTITULO     AS STRING
          data cTITULO         AS STRING
          data cCONDPAGTO      AS STRING
          data nVALORDOC       AS NUMERIC
          data nVALORREEM     AS NUMERIC
          data nVALORPDG       AS NUMERIC
          data nVALORADTO      AS NUMERIC
          data nValorNDF       AS NUMERIC
          data nValorTaxaFrete AS NUMERIC
          data nBaseImp        AS NUMERIC
          data nINSSRetido     AS NUMERIC
          data nAliqISS        AS NUMERIC
          data cCODCLIENTE     AS STRING
          data cLOJCLIENTE     AS STRING
          data cCNPJCPFCLI     AS STRING
          data cDSCCLIENTE     AS STRING
          data cFILDEBITO      AS STRING
          data dEMISSAO        AS DATE
          data dVENCIMENTO     AS DATE
          data dTRANSACAO      AS DATE
          data cNATUREZA       AS STRING
          data cHISTORICO      AS STRING
          data cEventType      AS STRING
          data cEntityName     AS STRING // define o nome da mensagem que será enviada.
          data cTipoMsg        AS STRING
          data cSubTipoMsg     AS STRING
          data cVersion        AS STRING // versão da mensagem.
          data cLiberaTitulo   AS STRING // 1=Liberado;2=Pendente/Bloqueado
          data lPreview
          data cStatusPag      AS STRING // 1=Libera Pagamento;2=Bloqueia Pagamento
          data cPessoa         AS STRING // PF-Pessoa Física ou PJ-Pessoa Juridica
          data aTrips
          data aTaxes
          data oImpostos
          data oResultSet
          data cOperatorCode   AS STRING 
          
          method new() constructor
          method send()
          method receive()
          method setTipoMsg()
          method reset()
          method IncParcela()
          method getBranchInt()
          method addTrip()
          method AddTaxes()
          method getExtId()
          method getIntId()
          method ListErrors()
          method ListOfTaxes()
          method salvaMsgInt()
          method getDocsPerTrip()
          method getResults()

EndClass

/*
======================================================================================================
/{Protheus.doc} setTipoMsg
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 06/10/2016
@version undefined
@param cTipo, characters, define o tipo da mensagem enviada podendo ser uns dos tipos abaixo:
                    1-Viagem
                    2-Contrato Carreteiro
                    3-Ocorrência
                    4-Seguro
                    5-Custos de Transporte

@param cSubTipo, characters, define o sub-tipo da mensagem que reforça a caracteristica desta:
                   101-Viagem - Reservar
                   201-Contrato Carreteiro - NDF
                   202-Contrato Carreteiro - NCF
                   301-Ocorrência – Indenização de Seguro, Sinistros/Roubos da carga/veículos
                   401-Seguro – Premiação
                   402-RCF-DC – Cobertura de Seguro contra Roubo ou Desaparecimento da carga.
                   403-RCTR-C – Cobertura de Seguro contra avarias, tombamentos do equipamento utilizado no transporte.
                   501-Custos de Transporte – Reservar

@type function
======================================================================================================
/*/
method setTipoMsg(cTipo,cSubTipo) Class TransportDocumentClass
     SELF:cTipoMsg    := cTipo
     SELF:cSubTipoMsg := cSubTipo
Return nil

/*
======================================================================================================
/{Protheus.doc} CountReg
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 12/12/2016
@version undefined

@type function
======================================================================================================
/*/
Method getDocsPerTrip(cFilOri,cViagem,cLAlias) Class TransportDocumentClass
Local cQuery  := ""
Local lResult := .T.

      cLAlias := GetNextAlias()

      cQuery := "SELECT DT6.DT6_FILORI,DT6.DT6_FILDOC,DT6.DT6_DOC,DT6.DT6_SERIE FROM " + RetSqlName("DTQ") + " DTQ "
      cQuery += " LEFT JOIN " + RetSqlName("DUD") + " DUD ON "
      cQuery += " DUD.DUD_FILIAL = DTQ.DTQ_FILIAL "
      cQuery += " AND   DUD.DUD_FILORI = DTQ.DTQ_FILORI "
      cQuery += " AND   DUD.DUD_VIAGEM = DTQ.DTQ_VIAGEM "

      cQuery += " LEFT JOIN " + RetSqlName("DT6") + " DT6 ON "
      cQuery += " DT6.DT6_FILIAL = DUD.DUD_FILIAL "
      cQuery += " AND   DT6.DT6_FILDOC = DUD.DUD_FILDOC "
      cQuery += " AND   DT6.DT6_DOC    = DUD.DUD_DOC "
      cQuery += " AND   DT6.DT6_SERIE  = DUD.DUD_SERIE "

      cQuery += " WHERE DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
      cQuery += " AND   DTQ.DTQ_FILORI = '" + cFilOri   + "' "
      cQuery += " AND   DTQ.DTQ_VIAGEM = '" + cViagem   + "' "
      cQuery += " AND   DUD.DUD_VIAGEM = DTQ.DTQ_VIAGEM "
      cQuery += " AND   DT6.DT6_SERIE <> 'COL' "
      
      If Select(cLAlias) <> 0
         (cLAlias)->(DbCloseArea()) 
      EndIf
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cLAlias,.T.,.F.)
      
      lResult := (cLAlias)->(!EOF())
     
Return lResult

/*
======================================================================================================
/{Protheus.doc} new
Metodo construtor
@author tiago.dsantos
@since 27/09/2016 
@version 1.0
@example
(examples)
@see (links_or_references)
======================================================================================================
/*/
Method new() Class TransportDocumentClass
	SELF:cVIAGEM          := ""
	SELF:cFILORI          := ""
	SELF:cPREFTITULO      := ""
	SELF:cTITULO          := ""
	SELF:cCONDPAGTO       := ""
	SELF:nVALORDOC        := 0
	SELF:nVALORPDG        := 0
	SELF:nVALORADTO       := 0
	SELF:cCODCLIENTE      := ""
	SELF:cLOJCLIENTE      := ""
	SELF:cDSCCLIENTE      := ""
	SELF:cCNPJCPFCLI      := ""
	SELF:cPESSOA          := ""
	SELF:cFILDEBITO       := ""
	SELF:dEMISSAO         := dDatabase
	SELF:dTRANSACAO       := Date()
	SELF:dVENCIMENTO      := CTOD("")
	SELF:cNATUREZA        := ""
	SELF:cHISTORICO       := ""
	SELF:cEventType       := "upsert"
	SELF:cEntityName      := "TRANSPORTDOCUMENT"
	SELF:cTipoMsg         := "1"   // Tipo Contrato Carreteiro.
	SELF:cSubTipoMsg      := "101" // Sub Tipo Frete Normal 
	SELF:cLiberaTitulo    := "1"//IIF(GetMV('MV_GERTIT' ,,.F.) == .F.,"1","2") 
	SELF:cTituloPendente
	SELF:lPreview         := .F. // default .F.
	SELF:cStatusPag       := "2" // default .F. = 1-Bloqueado;2-Desbloqueado
	SELF:nINSSRetido      := 0.00
	SELF:nAliqISS         := 0.00
	SELF:nBaseImp         := 0.00
	SELF:nValorNDF        := 0.00
    SELF:nValorTaxaFrete  := 0.00
	SELF:cVersion         := "2.000"
	SELF:aTrips           := {}
    SELF:aTaxes           := {}
    SELF:cOperatorCode    := ""
    SELF:nVALORREEM       := 0
	//| Set dos Retornos
	SELF:oImpostos        := TDTaxationClass():New() //| Conjunto de impostos retornado pelo Datasul
	SELF:oResultSet       := TDResultClass():New()   //| Conjunto de propriedades relacionados ao retorno do titulo processado pela marca receptora.

Return


/*/{Protheus.doc} IncParcela
//TODO Metodo para buscar a próxima parcela para a geração do titulo CP
@author tiago.dsantos
@since 08/11/2016
@version 1.000
@param cPrefixo: prefixo do titulo 
@param cNum: numero do titulo
@param cTipo: espécie relacionada ao tipo do titulo 
@param cCodFor: código de cadastro do fornecedor
@param cLojFor: loja de cadastro do fornecedor
@type function
/*/
Method IncParcela(cPrefixo,cNum,cTipo,cCodFor,cLojFor) Class TransportDocumentClass
Local cParcela := "01"
Local cQuery   := ""
Local cTAlias  := GetNextAlias()

      cQuery := "select MAX(E2_PARCELA) parcela from " + RetSqlName("SE2") + " " 
      cQuery += " where D_E_L_E_T_  = ' ' and e2_filial   = '" + xFilial("SE2") + "' " 
      cQuery += " and e2_prefixo  = '" + cPrefixo + "' " 
      cQuery += " and e2_num      = '" + cNum     + "' " 
      cQuery += " and e2_tipo     = '" + cTipo    + "' " 
      cQuery += " and E2_FORNECE  = '" + cCodFor  + "' " 
      cQuery += " and E2_LOJA     = '" + cLojFor  + "' "

      DbUseArea(.T.,"TOPCON",TcGenQry(,,cQuery),cTAlias,.T.,.F.)
      
      If (cTAlias)->(!EOF())
         cParcela := Soma1((cTAlias)->PARCELA) 
      EndIf
      (cTAlias)->(DbCloseArea())

Return cParcela


/*/{Protheus.doc} getBranchInt
//Retorna o valor para preenchimento da tag BranchInternalID
@author tiago.dsantos
@since 10/11/2016
@version 1.000

@type Method
/*/
Method getBranchInt(cFilOri) Class TransportDocumentClass

Local   cResult := ""

Default cFilOri := ""

cResult := cEmpAnt + "|" + cFilOri //XXD->XXD_EMPPRO + "|" + XXD->XXD_FILPRO

Return cResult


/*/{Protheus.doc} addTrip
// Inclui dados da viagem no Array aTrips 
@author tiago.dsantos
@since 10/11/2016
@version 1.000

@type function
/*/
method addTrip(cBranch,cCode) Class TransportDocumentClass
Local aTrip :=  {cBranch,cCode} //TripClass():New(cBranch,cCode,nAliqISS)
Local nPos  := 0
       
       nPos := AScan(SELF:aTrips,{|R| R[1]+R[2] == cBranch + cCode})
       If nPos == 0
          AADD(SELF:aTrips,aTrip)
       EndIf
Return Nil

/*/{Protheus.doc} AddTaxes
// Inclui dados da viagem no Array aTaxes 
@author leandro Paulino
@since 10/11/2016
@version 1.000

@type function
/*/
method AddTaxes(aTaxes) Class TransportDocumentClass

Default aTaxes := {}

If Len(aTaxes) > 0             
    SELF:aTaxes := aClone(aTaxes)
EndIf

Return Nil


/*
======================================================================================================
/{Protheus.doc} new
Metodo construtor
@author tiago.dsantos
@since 27/09/2016 
@version 1.0
@example
(examples)
@see (links_or_references)
======================================================================================================
/*/
Method reset() Class TransportDocumentClass
	SELF:cVIAGEM          := ""
	SELF:cFILORI          := ""
	SELF:cPREFTITULO      := ""
	SELF:cTITULO          := ""
	SELF:cCONDPAGTO       := ""
	SELF:nVALORDOC        := 0
	SELF:nVALORPDG        := 0
	SELF:nVALORADTO       := 0
	SELF:cCODCLIENTE      := ""
	SELF:cLOJCLIENTE      := ""
	SELF:cDSCCLIENTE      := ""
	SELF:cCNPJCPFCLI      := ""
	SELF:cFILDEBITO       := ""
	SELF:dEMISSAO         := dDatabase
	SELF:dTRANSACAO       := Date()
	SELF:dVENCIMENTO      := CTOD("")
	SELF:cNATUREZA        := ""
	SELF:cHISTORICO       := ""
	SELF:cEventType       := "upsert"
	SELF:cEntityName      := "TRANSPORTDOCUMENT"
	SELF:cLiberaTitulo    := "1"//Iif(GetMV('MV_GERTIT' ,,.F.) == .F.,"1","2")
	SELF:lPreview         := .F. // default .F.
	SELF:cStatusPag       := "2" // default .F. = 1-Bloqueado;2-Desbloqueado
	SELF:nINSSRetido      := 0.00
	SELF:nAliqISS         := 0.00
	SELF:nBaseImp         := 0.00
	SELF:nValorNDF        := 0.00
	SELF:nValorTaxaFrete  := 0.00
	SELF:cVersion         := "2.000"
    SELF:nVAlORREEM       := 0

     SELF:oImpostos        := TDTaxationClass():New() 
     SELF:oResultSet       := TDResultClass():New()
     SELF:aTaxes           := {}
Return

/*
====================================================================================
/{Protheus.doc} method send()
//TODO Trata a montagem do XML de Envio
@author tiago.dsantos
@since 20/09/2016
@version 1.000
@type function
/===================================================================================
*/
Method Send()  Class TransportDocumentClass
Local nCTrip      := 1
Local lRet        := .T.
Local cXMLRet     := ""
Local cDATATU     := Transform(DtoS(Date()),"@R 9999-99-99") + "T" + Time()
Local nMoeda      := 1
Local cMoedaDesc  := ""
Local cMoedaSimb  := "$"
Local cDocPrefix  := ""
Local cDocumento  := ""
Local cCodCli     := ""
Local cLojCli     := ""
Local cNomeFor    := ""
Local cCNPJCPF    := ""
Local cInscrEst   := ""
Local dDocEmiss   := Date()
Local dDocTrans   := Iif(Empty(SELF:dTransacao),Date() ,SELF:dTransacao)
Local cFilDeb     := Iif(Empty(SELF:cFilDebito),cFilAnt,SELF:cFilDebito)
Local cFilDoc     := ""
Local cDocto      := ""
Local cDocSer     := ""
Local nValDocto   := 0
Local nValPDG     := 0
Local nValAdto    := 0
Local nTaxBase    := 0
Local cInternalId := ""
Local cEvent      := "upsert"
Local cHistorico  := SELF:cHistorico 
Local cLAlias     := ""
Local aTaxes      := SELF:aTaxes
Local nCTaxes     := 0
Local lEdtXmlTDC  := ExistBlock('TMSTDCLS')
Local lEAICodUnq  := Iif(Len( FwAdapterInfo("MATA020B","CUSTOMERVENDORRESERVEID") ) , .T. , .F. ) 

      cDocPrefix  := SELF:cPREFTITULO
      cDocumento  := SELF:cTITULO
      cCodCli     := PadR(SELF:cCODCLIENTE,TamSX3("A2_COD")[1])
      cLojCli     := PadR(SELF:cLOJCLIENTE,TamSX3("A2_LOJA")[1])

      SA2->(dbSetOrder(1))
      SA2->(MsSeek(xFilial("SA2")+cCodCli+cLojCli))
      cNomeFor    := Iif(Empty(SELF:cDSCCLIENTE),_noTags(SA2->A2_NOME ),_noTags(SELF:cDSCCLIENTE)) //oDTClass:DESCRICAO_CLIENTE
      cCNPJCPF    := AllTrim(SA2->A2_CGC  )
      cInscrEst   := AllTrim(SA2->A2_INSCR)

      cInternalId := Self:getIntId(cDocumento,SELF:cTipoMsg,SELF:cFilOri)
      nMoeda      := 1
      cMoedaDesc  := "REAL"
      cMoedaSimb  := "$"
      dDocEmiss   := SELF:dEMISSAO  
      nValDocto   := SELF:nVALORDOC
      nValPDG     := SELF:nValorPDG
      nValAdto    := SELF:nValorADTO
      nVlrReem    := SELF:nValorReem
      nTaxBase    := Iif(oDTClass:nBaseImp == 0 .And. SELF:cTipoMsg != '1' ,SELF:nVALORDOC,SELF:nBaseImp)
      cFilDoc     := ""
      cDocto      := ""
      cDocSer     := ""

      cEvent      := SELF:cEventType

      cXMLRet := "<BusinessEvent>"
      cXMLRet +=     "<Entity>" + SELF:cEntityName + "</Entity>"
	  cXMLRet +=     "<Event>" + cEvent + "</Event>"
	  cXMLRet +=     "<Identification>"
	  cXMLRet +=          "<key name='InternalId'>" + cInternalId + "</key>"
	  cXMLRet +=     "</Identification>"
	  cXMLRet += "</BusinessEvent>"
	  

      cXMLRet += "<BusinessContent>"

      cXMLRet +=       "<CompanyId>"          + cEmpAnt                             + "</CompanyId>"
      cXMLRet +=       "<BranchId>"           + SELF:cFILORI                        + "</BranchId>"
      cXMLRet +=       "<BranchInternalId>"   + SELF:getBranchInt(SELF:cFILORI)     + "</BranchInternalId>"
      cXMLRet +=       "<CompanyInternalId>"  + cEmpAnt                             + "</CompanyInternalId>"
      cXMLRet +=       "<InternalId>"         + cInternalId                         + "</InternalId>"
      cXMLRet +=       "<DocumentId>"         + cDocumento                          + "</DocumentId>"     // DocumentNumber

      cXMLRet +=       "<DocumentType>"       + SELF:cTipoMsg                       + "</DocumentType>"   // DocumentTypeCode
      cXMLRet +=       "<DocumentSubType>"    + SELF:cSubTipoMsg                    + "</DocumentSubType>"
      cXMLRet +=       "<VendorCode>"         + cCodCli+IIf(lEAICodUnq,'',cLojCli)  + "</VendorCode>"     // VendorCode 
      cXMLRet +=       "<VendorDescription>"  + RTrim(cNomeFor)                     + "</VendorDescription>"
      
      //| Tags necessárias somente para update ou insert.
      If Upper(cEvent) == "UPSERT"
      
	      cXMLRet +=       "<GovernmentalInformation>"
	      cXMLRet +=             "<Id name='CPFCNPJ' expiresOn='' issueOn='" + cDATATU + "' scope=''>" + cCNPJCPF + "</Id>"
	      cXMLRet +=             "<Id name='INSCRICAO ESTADUAL' expiresOn='' issueOn='" + cDATATU + "' scope=''>" + cInscrEst + "</Id>"
	      cXMLRet +=       "</GovernmentalInformation>"
	      
	      cXMLRet +=       "<LocalCurrency>"
	      cXMLRet +=           "<Code>"        + AllTrim(Str(nMoeda))   + "</Code>"
	      cXMLRet +=           "<Description>" + cMoedaDesc             + "</Description>"
	      cXMLRet +=           "<Simbol>"      + cMoedaSimb             + "</Simbol>"
	      cXMLRet +=       "</LocalCurrency>"
	      
	      cXMLRet +=       "<IssueDate>"       + Transform(DtoS(dDocEmiss),"@R 9999-99-99")  + "</IssueDate>"
	      If !Empty(oDTClass:dVencimento)
	         cXmlRet +=    "<DueDate>"         + Transform(DtoS(SELF:dVencimento),"@R 9999-99-99") + "</DueDate>"
	      EndIf
	      cXMLRet +=       "<TransactionDate>" + Transform(DtoS(dDocTrans),"@R 9999-99-99") + "</TransactionDate> "
	      cXMLRet +=       "<DebitBranchCode>" + cFilDeb         + "</DebitBranchCode>"
	      cXMLRet +=       "<DebitBranchInternalId>" + cEmpAnt + "|" + cFilDeb + "</DebitBranchInternalId>"
      
      
	      cXMLRet +=       "<DocumentValues>"
	      cXMLRet +=            "<TransportDocumentValue>" + AllTrim(Transform(nValDocto,"@R 999999999999.99")) + "</TransportDocumentValue>"
	      cXMLRet +=            "<TollValue>"              + AllTrim(Transform(nValPdg  ,"@R 999999999999.99")) + "</TollValue>"
	      cXMLRet +=            "<AdvancesValue>"          + AllTrim(Transform(nValAdto ,"@R 999999999999.99")) + "</AdvancesValue>"
          cXMLRET +=            "<TaxBaseValue>"           + AllTrim(Transform(nTaxBase ,"@R 999999999999.99")) + "</TaxBaseValue>"
          cXMLRET +=            "<RefundValue>"            + AllTrim(Transform(nVlrReem ,"@R 999999999999.99")) + "</RefundValue>"
          
                If SELF:nINSSRetido > 0
                    //cXMLRet += "<SocialSecurityRetention>" + AllTrim(Transform(SELF:nINSSRetido,"@R 99999999999.99")) + "</SocialSecurityRetention>"
                    cXMLRet +=             "<INSSRetention>" + AllTrim(Transform(SELF:nINSSRetido,"@R 999999999999.99")) + "</INSSRetention>"
	           EndIf
                If SELF:nAliqISS > 0
                    cXMLRet +=             "<ISSRate>" + AllTrim(Transform(SELF:nAliqISS,"@R 9999.99")) + "</ISSRate>"
	           EndIf
	           If SELF:nValorNDF > 0
	               cXMLRet +=             "<TransportCostValue>" + AllTrim(Transform(SELF:nValorNDF,"@R 999999999999.99"))+ "</TransportCostValue>" 
	           EndIf
                IF SELF:nValorTaxaFrete > 0
                    cXMLRet += "<OperatorChargeValue>" + AllTrim(Transform(SELF:nValorTaxaFrete,"@R 999999999999.99"))+ "</OperatorChargeValue>"
                ENDIF
	      cXMLRet +=       "</DocumentValues>"
	      cXMLRet +=       "<DocumentHistory>" + cHistorico + "</DocumentHistory>
	      cXMLRet +=       "<Preview>"         + Iif(SELF:lPreview,"1","2") + "</Preview>"  //|1=SIMULA o Titulo com Retorno dos Impostos se houver;2=Processa o XML e efetiva a geração do título CP
          cXMLRet +=       "<PaymentStatus>"   + SELF:cStatusPag       + "</PaymentStatus>" //| 1-bloqueado;2-desbloqueado;
          cXMLRet +=       "<BondsToPay>"      + SELF:cLiberaTitulo    + "</BondsToPay>"    //| 1=Gera Titulo;2=Titulo Pendente de liberação
          cXMLRet +=       "<OperatorCode>"    + SELF:cOperatorCode    + "</OperatorCode>"  //| Codigo da Operadora de Frota. 01-REPOM; 02-PAMCARD
	      //+---------------------------------------------------------------
	      //| Se existir novas tags/campos que resulta em mudança de versão
	      //| faça a inclusão aqui...
	      //+---------------------------------------------------------------
	      If StrTokArr(oDTClass:cVersion, ".")[1] == "2"
	           //campos relacionados a versão 2 serão tratados aqui...
	      EndIf

	 ENDIF

      //+--------------------------------------------------------------
      //| Monta a lista de Documentos por Viagem
      //| Deve Constar em ambos os modelos UPSERT/DELETE **DATASUL ABP
      //+--------------------------------------------------------------
      cXMLRet +=        "<ListOfDocumentsPerTrip>"
      If SELF:cTipoMsg == "1" //| QUANDO VIAGEM

	           //| Lista de documentos...     
	           If SELF:getDocsPerTrip(SELF:cFILORI,SELF:cVIAGEM,@cLAlias) == .T.

	                While (cLAlias)->(!EOF())
	                      If !Empty((cLAlias)->DT6_DOC)
	                           cXMLRet +=            "<Document>"
	                           cXMLRet +=                  "<BranchId>"         + (cLAlias)->DT6_FILDOC  + "</BranchId>"
	                           cXMLRet +=                  "<BranchInternalId>" + SELF:getBranchInt(SELF:cFilori)    + "</BranchInternalId>"
	                           cXMLRet +=                  "<Code>"             + (cLAlias)->DT6_DOC     + "</Code>"
	                           cXMLRet +=                  "<Serial>"           + (cLAlias)->DT6_SERIE   + "</Serial>"
	                           cXMLRet +=            "</Document>"
                           EndIf
	                      (cLAlias)->(DbSkip())
	                EndDo
	           EndIf
      ElseIf SELF:cTipoMsg == "7" //| QUANDO GNRE
               cXMLRet +=            "<Document>"
               cXMLRet +=                  "<BranchId>"         + SF2->F2_FILIAL  + "</BranchId>"
               cXMLRet +=                  "<BranchInternalId>" + SELF:getBranchInt(SELF:cFilori)    + "</BranchInternalId>"
               cXMLRet +=                  "<Code>"             + SF2->F2_DOC     + "</Code>"
               cXMLRet +=                  "<Serial>"           + SF2->F2_SERIE   + "</Serial>"
               cXMLRet +=            "</Document>"
      EndIf
      cXMLRet +=        "</ListOfDocumentsPerTrip>"

      //+--------------------------------------------------------------
      //| Monta a lista de Documentos por Contrato            
      //+--------------------------------------------------------------
      cXMLRet +=        "<ListOfTripsPerContract>"
      If SELF:cTipoMsg == "2" //| Quando Contrato de Carreteiro

            For nCTrip := 1 To Len(SELF:aTrips)
                    cXMLRet +=            "<Trip>"
                    cXMLRet +=                  "<BranchId>"         + SELF:aTrips[nCTrip][1]/*:cBranch*/      + "</BranchId>"
                    cXMLRet +=                  "<BranchInternalId>" + SELF:getBranchInt(SELF:cFilOri)   /*Empresa|filial*/+ "</BranchInternalId>"
                    cXMLRet +=                  "<Code>"             + SELF:aTrips[nCTrip][2]/*:cCode*/        + "</Code>"
                    cXMLRet +=            "</Trip>"
            Next nCTrip
	                
      EndIf
      cXMLRet +=        "</ListOfTripsPerContract>

      //+--------------------------------------------------------------
      //| Lista de Impostos calculados e que deverão ser considerados 
      //| na integração, ou seja, os impostos não serão calculados pela
      //| marca receptora.
      //+--------------------------------------------------------------
      If Upper(cEvent) == "UPSERT"
        If SELF:cTipoMsg == '2' .And. Len(SELF:aTaxes) > 0 //Quando Contrato de Carreteiro
            cXmlRet += "<ListOfTaxes>"
            For nCTaxes := 1 To Len(SELF:aTaxes)
                If (aTaxes[nCTaxes][2]) > 0

                    cXmlRet += "<Tax>"
                    cXmlRet +=      "<Taxe>"                + aTaxes[nCTaxes][1] + "</Taxe>"
                    cXmlRet +=      "<CountryCode>"         + aTaxes[nCTaxes][3] + " </CountryCode>"                     
                    cXmlRet +=      "<StateCode>"           + aTaxes[nCTaxes][4] + "</StateCode>"                    
                    cXmlRet +=	    "<CalculationBasis>"   + AllTrim(Transform(aTaxes[nCTaxes][5]  ,"@R 99,999,999.99"))  + "</CalculationBasis>"                    
                    cXmlRet +=      "<Value>" +  AllTrim(Transform(aTaxes[nCTaxes][2]  ,"@R 99,999,999.99")) + "</Value>"    
                    cXmlRet += "</Tax>"

                EndIf
            Next nCTaxes  
            cXmlRet += "</ListOfTaxes>"
        EndIf
      EndIf

      //+--------------------------------------------------------------
	 //| Para exclusão...
	 //| Exclui a gravação do De-para
      //+--------------------------------------------------------------
	 If Upper(cEvent) == "DELETE"
	       
	       CFGA070MNT( Nil /*cMarca*/, "DTY", "DTY_NUMCTC" ,;
			                    ,;           //| Código da outra aplicação
			        cInternalId ,;           //| código gerado pelo Protheus
			        .T.)                     //| Quando .T. deleta o registro de depara.
	 EndIf //|[Fecha o If Upper(cEvent) == "UPSERT"]
	  
     cXMLRet += "</BusinessContent>"

     If lEdtXmlTDC 

        cXmlRet := ExecBlock('TMSTDCLS',.F.,.F.,{cXmlRet, SELF:cFILORI,SELF:cVIAGEM, cEvent, SELF:cEventType , SELF:cTipoMsg})

     EndIf



Return {lRet,cXMLRet}


/*
====================================================================================
/{Protheus.doc} metodo: receive
//TODO Trata o XML Recebido pelo Adapter
@author tiago.dsantos
@since 20/09/2016
@version 1.000
@param cXML, characters, 'XML Recebido do Adapter Externo'
@param cMsgType, characters, Tipo de Mensagem onde que: 
@type function
/===================================================================================
*/
Method receive(cXML,cTypeMessage) Class TransportDocumentClass
Local lRet       := .T.
Local cXMLRet    := ""
Local cErrorXml  := ""
Local cWarnXml   := ""
Local oXml       := NIL
Local aErrorMsg  := {} 
Local cCodExt    := ""
Local cCodInt    := ""
Local cPrefixo   := ""
Local cNumTit    := ""
Local cTipo      := ""
Local cParcela   := StrZero(1, Len(SE2->E2_PARCELA))
Local nVlrDocto  := 0
Local nINSSRet   := 0
Local nISSAliq   := 0
Local nBaseImp   := 0 
Local cCodClie   := ""
Local cLojClie   := ""
Local cNatureza  := SuperGetMv("MV_NATDEB",,"")
Local dDatEmiss  := Date()
Local dDatVencto := Date()
Local lExibeLanc := .F.
Local lOnline    := .F.
Local lBcoPag    := .F.
Local cFilRegist := cFilAnt
Local aTemp      := {}
Local cCnpjCpf   := 0 
Local cMarca     := "" 
Local cAlias     := "SE2"// Para gravação do de-para, sera definido de acordo com o tipo da mensagem.
Local cCampo     := ""// Para gravação do de-para
Local cEvent     := ""
Local nOperation := 3    
Local aDadExcSE2 := {}
Local aSE2Area   := {} 
Local aError     := {}
Local nx         := 0
Local cSeekSE2   := ""
Local aIntId     := {} 
Local nMoeda     := 1
Local cSubTipDoc := ""
Local cTipoDocto := ""
Local cCondPag   := ""//| Condicao de pagamento do fornecedor
Local lPreview   := .F.
Local aTVenc     := {}
Local lSE2Matched:= .F.

Private lMsErroAuto := .F.
Private lF050Auto  := .T.
Private lAltera    := .F.
Private nOldValor  := 0
Private nOldIrr    := 0
Private nOldIss    := 0
Private nOldInss   := 0
Private nOldSEST   := 0
Private lGerTit    := GetMV('MV_GERTIT' ,,.T.)
	
      //+------------------------------------------------------------------------------
      //| Recebimento da Mensagem de Negócio
      //+------------------------------------------------------------------------------
      If   cTypeMessage == EAI_MESSAGE_BUSINESS //cTypeMessage == 20

           //| Parse do XML
           oXml := TXmlManager():New()
           If !oXml:Parse(cXml)
                AAdd(aErrorMsg,{"Não foi possível ler o xml recebido.Verifique.",1,"001"})
                // Salvar o XML na pasta de Log de XML do EAI, deve ser criado abaixo do root do Protheus
                // memowrite(...,cXml)
                
                lRet    := .F.
                cXmlRet := FwEAILOfMessages( aErrorMsg )

                Return {lRet,cXmlRet}
           EndIf

           //| Lê as informacoes para geração do titulo contidos na tag business
           
           cMarca     := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )
           cEvent     := Upper(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Event")) 
           cTipoDocto := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentType")
           cSubTipDoc := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentSubType")

	       //| Contrato de Carreteiro ou Custos de transportes
	       If cTipoDocto $ "2;5"
	            cNatureza  := SuperGetMv("MV_NATDEB",,"")
	            cTipo      := SuperGetMv("MV_TPTCTC",,"")
	            If cSubTipDoc $ "202;501" //| Gera NDF || Custos de transportes
	               cTipo      := "NDF"
	            EndIf
	       EndIf
           //|
           //| Quando cTipoDocto for "3-Ocorrência" e cSubTipDoc for "301-Indenização"
           //| Atualiza para a natureza, prefixo e tipo do titulo de acordo com o tipo da mensagem.
           //|
           If cTipoDocto == "3" .And. cSubTipDoc == "301"
                cComSeg    := "DC" //Componente de seguro
                cNatureza  := Posicione("DU3",1,xFilial("DU3")+cComSeg,"DU3_NATIND")
	            cPrefixo   := DU3->DU3_PREIND
	            cTipo      := DU3->DU3_TIPIND
	       EndIf
	       //|
	       //| Premiação de Seguro / Fechamento Seguro.
	       If cTipoDocto == "4" .And. cSubTipDoc == "401"
                cComSeg    := "DC" //Componente de seguro
                cNatureza  := Posicione("DU3",1,xFilial("DU3")+cComSeg,"DU3_NATTPG")
	            cPrefixo   := DU3->DU3_PRETPG
	            cTipo      := DU3->DU3_TIPTPG
	       EndIf
	       
	       If !(cTipoDocto $ "1;2;3;4;5;6")  //| Tipo Invalido.
	            AAdd(aErrorMsg,{"O Tipo " + cTipoDocto + " Informado é invalido.",1,"002"})
                lRet    := .F.
                cXmlRet := FwEAILOfMessages( aErrorMsg )
                Return {lRet,cXmlRet}
	       EndIf

           nVlrDocto  := Val(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentValues/TransportDocumentValue"))
           nINSSRet   := Val(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentValues/INSSRetention"))
           nISSAliq   := Val(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentValues/ISSRate"))
           nBaseImp   := Val(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentValues/TaxBaseValue"))
           
           //| xPathGetChildArray é utilizado para converter as tags em vetor e getAttrib e utilizado para obter o atributo
           aTemp      := oXml:xPathGetChildArray("/TOTVSMessage/BusinessMessage/BusinessContent/GovernmentalInformation")
           
           cCnpjCpf   := getAttrib(oXml,aTemp,"NAME","CPFCNPJ")
           
           //| Flags de controle...
           lPreview := (val(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Preview")) == 1)
           lExibeLanc := .F.
           lOnline    := .F.
           lBcoPag    := .F.
           cFilRegist := cFilAnt

           //|Obtém o código interno da tabela de/para através de um código externo
      	   //|CFGA070Int( cRefer, cAlias, cField, cValExt,cTable )
           
           aTemp      := oXml:xPathGetChildArray("/TOTVSMessage/BusinessMessage/BusinessEvent/Identification")           
           
           cCodExt    := getAttrib(oXml,aTemp,"name","InternalId")
           
           aIntId := SELF:getExtId(cCodExt,cMarca)
           //| Quando já existir um de-para assume o retorno para inicializar as variaveis de pesquisa do SE2
           If Len(aIntId) > 0 .And. aIntId[1] == .T.
                  cPrefixo   := aIntId[2][3] //| E2_PREFIXO
                  cNumTit    := aIntId[2][4] //| E2_NUM
                  cCodInt    := aIntId[3]    //| Chave Interna concatenada por "|"
                  If Empty(cCnpjCpf)         //| ** quando exclusão pega-se o cnpj do de-para, pois a tag referente ao GovernmentalInformation não é informa.
                     cCnpjCpf := aIntId[2][5]//| CNPJ/CPF do Fornecedor 
                  EndIf
                  
                  
           //| Quando não existir De-Para é utilizado o bloco abaixo.
           Else

               cPrefixo := TMA250GerPrf(cFilAnt)
               cNumTit  := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentId")
               
               cCnpjCpf := TMI250GINT(cCodExt)[5] 
               cCodInt  := Self:getIntId(cNumTit,cTipoDocto ) //| Obtem o código interno...
               
           EndIf

           //| Posiciona no fornecedor
           SA2->(dbSetOrder(3))
           SA2->(MsSeek( xFilial("SA2")/*,TamSx3("A2_FILIAL")[1])*/ + PadR(cCnpjCpf,TamSx3("A2_CGC")[1]) ))
           cCodClie     := SA2->A2_COD
           cLojClie     := SA2->A2_LOJA
           cCondPag     := SA2->A2_COND
          
           SELF:cPessoa := IIF(Len(SA2->A2_CGC) > 11,"PJ","PF")

           dDatEmiss  := CtoD(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/IssueDate"))
           dDatVencto := CtoD(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DueDate"))
           
           //| Atualiza o vencimento com base na condicao de pagamento do fonrecedor
           If Empty(dDatVencto) 
               aTVenc := Condicao( nVlrDocto, cCondPag,, dDataBase )
               dDatVencto := Iif(Len(aTVenc) > 0,aTVenc[1,1],dDatEmiss)
           EndIf

           
           //| Define o tipo de operação inclusão, alteração ou exclusão
           If Upper(cEvent) == "UPSERT"
           
               nOperation := 3      //| Inclusão
               DbSelectArea("SE2")
               SE2->(DbSetOrder(1)) //| E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
               
               If SE2->(MsSeek( xFilial("SE2") + cPrefixo + cNumTit + cParcela + cTipo + cCodClie + cLojClie))
                  nOperation := 4 // Alterar

                  //|
                  //| Obtém próxima parcela se for um custo de transporte
                  If cTipoDocto == "5"
                      cParcela := SELF:IncParcela(cPrefixo,cNumTit,cTipo,cCodClie,cLojClie)

                  EndIf
               EndIf

           Else
               nOperation := 5 // Exclusão
               
           EndIf
           
           
           //+-------------------------------------------------------
	       //| Gravação dos Dados
	       //+-------------------------------------------------------
	       //| #01 - Inclusão / Alteração  
	       //Begin Sequence
	       If nOperation != 5
	       
               //| Inclusão do Titulo no Financeiro
               If lPreview == .F.
                         If!(SuperGetMv("MV_TMSFATU",,.F.,))//Parametro para a geração de títulos a partir de um registro de indenização seja o mesmo da filial do registro utilizando o campo DUB_FILRID como referência e não a filial atual.
                              // UNIQUE : E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	                          lRet := A050ManSE2(nOperation, cNumTit, cPrefixo, cTipo,cParcela, nVlrDocto, 0, cCodClie,;
					        	                   cLojClie, cNatureza, 1, ,"SIGATMS", date(),,dDatVencto,;
					        	                   ,,,lExibeLanc,lOnline, lBcoPag,Nil,nINSSRet)
	                     Else
	                           lRet := A050ManSE2(nOperation, cNumTit, cPrefixo, cTipo,cParcela, nVlrDocto , 0, cCodClie,cLojClie;
					        	                   ,cNatureza, 1, ,"SIGATMS", date(),,dDatVencto,;
					        	                   ,cFilAnt,,lExibeLanc,lOnline, lBcoPag,Nil,nINSSRet)
                         EndIf

	           //+-------------------------------------------------------
               //| Simula o calculo dos impostos quando lPreview == .T.
               //| TAGCODE: 20161114-1542
	           //+-------------------------------------------------------
               Else
                         RegToMemory("SE2",.T.)
                         SED->(dbSetOrder(1))
                         SED->(MsSeek(xFilial("SED")+cNatureza))
                         M->E2_NATUREZ := SED->ED_CODIGO
                         M->E2_VALOR   := nBaseImp
                         
                         If SED->ED_CALCISS == "S" .And. nISSAliq > 0 //Calcula o ISS
                              M->E2_ISS     := (nBaseImp * nISSAliq) / 100
                         EndIf			
                         M->E2_INSSRET := nINSSRet
			
                         TM250ClINS()
			
                         //| Calcula o IRRF
                         SA2->(dbSetOrder(1))
                         SA2->(MsSeek(xFilial('SA2')+cCodClie+cLojClie))
                         M->E2_FORNECE := SA2->A2_COD
                         M->E2_LOJA    := SA2->A2_LOJA
				
                         FA050NAT2()

			   EndIf //| Fecha If lPreview = .F.

	       //+-------------------------------------------------------
	       //| Exclusão do Titulo
	       //+-------------------------------------------------------
		   Else

		   	       dbSelectArea("SE2")
			       dbSetOrder(6)
			       aSE2Area := SE2->(getArea())
			       cSeekSE2 := xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cNumTit
			       
			       lSE2Matched := MsSeek( cSeekSE2 )
			       
			       If lSE2Matched
			               Do While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == cSeekSE2
						      //-- Apagar titulo
		   
                                 aDadExcSE2 := {}
                                 AAdd( aDadExcSE2 ,{ "E2_FILIAL"  ,SE2->E2_FILIAL  ,Nil } )
                                 AAdd( aDadExcSE2 ,{ "E2_PREFIXO" ,SE2->E2_PREFIXO ,Nil } )
                                 AAdd( aDadExcSE2 ,{ "E2_NUM"     ,SE2->E2_NUM     ,Nil } )
                                 AAdd( aDadExcSE2 ,{ "E2_PARCELA" ,SE2->E2_PARCELA ,Nil } )
                                 AAdd( aDadExcSE2 ,{ "E2_TIPO"    ,SE2->E2_TIPO    ,Nil } )
                                 AAdd( aDadExcSE2 ,{ "E2_FORNECE" ,SE2->E2_FORNECE ,Nil } )
                                 AAdd( aDadExcSE2 ,{ "E2_LOJA"    ,SE2->E2_LOJA    ,Nil } )
                                 MSExecAuto({| a,b,c,d,e,f,g| FINA050(a,b,c,d,e,f,g)} ,aDadExcSE2, , 5/*excluir*/,,,lExibeLanc,lOnline)

                                 If lMsErroAuto
                                    aError    := GetAutoGrLog()
                                    cErrorXml := ""
	                            
                                    For nx:= 1 To Len(aError)
                                        cErrorXml += _NoTags(aError[nx])
                                    Next nx
                                    lRet := .F.

                                 EndIf
                                 SE2->(DbSkip())
                           EndDo
                  EndIf
                  RestArea(aSE2Area)
                  
		   EndIf
		   //End Sequence

		   //| Monta o Retorno da mensagem ...
		   If lRet == .F.
		      
		      AAdd(aErrorMsg,{"Não foi possível " + IIf( nOperation != 5,"incluir","excluir") + " o titulo no contas à pagar.",1,"001"})
		      AAdd(aErrorMsg,{cErrorXml                                             ,1,"003"})
           
           //| Montagem do retorno da Mensagem informando o dados do titulo cadastrado e seus impostos..
		   Else

		       //| Se for uma Preview do Titulo não precisa gravar o de-para.
		       //| Se for uma exclusão onde que existia o registro no SE2; faz manutenção no XXF
		       If lPreview == .F.
		           lRet := CFGA070Mnt(cMarca , cAlias, "E2_NUM",IIf(nOperation==5,Nil,cCodExt), cCodInt, (nOperation == 5) )
                   //|
                   //| Usado para liberar a exclusão para a marca receptora que estará aguardando o ok da exclusão.
                   //| Como não achou registro e foi solicitado uma exclusão, não há a necessidade de bloquear a exclusão por falta do depara.
                   //|
                   If lRet == .F.
                      //| (Não Achou SE2 )  [ E ] (É uma Exclusão)
                      If lSE2Matched == .F. .And. nOperation == 5
                         lRet := .T.
                      EndIf
                   EndIf
		       EndIf
		       
		       If lRet == .T.
		           
		           //| Monta lista do De-Para para o retorno a aplicação externa.
		           //| Quando delete envia apenas o ListOfInternalId
		           cXmlRet := "<ListOfInternalId>"
		           cXmlRet +=         "<InternalId>"
		           cXmlRet +=                "<Name>"        + SELF:cEntityName  + "</Name>"
		           cXmlRet +=                "<Origin>"      + cCodExt      + "</Origin>"
		           cXmlRet +=                "<Destination>" + cCodInt      + "</Destination>"
		           cXmlRet +=         "</InternalId>"  
		           cXmlRet += "</ListOfInternalId>"

		           //| Posiciona no titulo para obter os valores dos impostos.
		           If nOperation <> 5
                       cXmlRet += retTaxComp(cPrefixo, cNumTit, lPreview, cCodInt, nMoeda)
			       EndIf
			       
			   Else
			       If nOperation != 5
			          lRet    := .F.
			          Aadd(aErrorMsg,{"Falha da gravação do De-para",1,"D001"})
			          Aadd(aErrorMsg,{"Dados Utilizados na Rotina de Depara: Produto:" + cMarca + "; cAlias: " + cAlias + "; Campo E2_NUM " + "; Cod.Ext: " + cCodExt + "; Cod.Int.: " +  cCodInt,;
			                       2,"D002"})
			       EndIf

		       EndIf//|[Close If lRet == .T.

		   EndIf

      //+------------------------------------------------------------------------------
      //| Recebimento da Mensagem de Retorno
      //+------------------------------------------------------------------------------
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE //cTypeMessage == 21

           oXml := XmlParser(cXml,"_",@cErrorXml, @cWarnXml) //TXmlManager():New()
           
           //If oXml:Parse(cXml)
           If oXml <> nil
                
                //cTipoDocto := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
                //cSubTipDoc := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/DocumentSubType")
                
                //If cTipoDocto == "2" //| Contrato de Carreteiro
                   cAlias := "DTY"
                   cCampo := "DTY_NUMCTC"
                //EndIf
                /*
                If cTipoDocto == "3"
                EndIf
                If cTipoDocto == "4" //| Fechamento do Seguro
                   cAlias := "DU8"
                   cCampo := "DU8_DOCSEG"
                EndIf
                */

                lRet := SELF:salvaMsgInt(oXml,cAlias,cCampo,@aErrorMsg)
                If lRet == .T.
                     SELF:ListOfTaxes(oXML)
                     SELF:getResults(oXML)
                     cXmlRet := cXML //| Para retornar a mensagem de Response contendo o retorno com os impostos gerados se houver.
                EndIf
           Else
                //| com.datasul.framework.dcl.exception.DatasulRuntimeException: Communication layer message: General Error: read() error= 1. (7175)
                //| WSCERR044 / Não foi possível POST : URL http://colhetas.jv01.local:8080/eai2-ws/EAIService ( 999 : Invalid HTTP Connection )
                //| ADVPL WSDL Client 1.120703 / TOTVS Série T Serviços MSSQL Tp12-a on 20161214 13:22:58
                If ("EXCEPTION" $ Upper(cXML) .Or. "WSCERR044" $ Upper(cXML))
                     Aadd(aErrorMsg,{STR0249,1,"EXP000"})
                     Aadd(aErrorMsg,{cXML   ,1,"EXP001"})
                EndIf
           EndIf
      
      //+------------------------------------------------------------------------------             
      //| Recebimento da Mensagem de recepção
      //+------------------------------------------------------------------------------
      ElseIf cTypeMessage == EAI_MESSAGE_RECEIPT
      
      
      //+------------------------------------------------------------------------------
      //| Retorna a versao atual da rotina, caso haja a necessidade de mudar a versao
      //| o retorno 'cXMLRET deverá constar todas as versoes separadas por '|' e tem
      //| que estar no formato Versao.Release(3digitos)
      //| exemplo: cXMLRET := "1.000|1.001|2.000"
      //+------------------------------------------------------------------------------
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
             cXMLRET := "1.000|2.000|3.000"
             
      EndIf
      
      //| Monta a mensagem de erro
      If !Empty(aErrorMsg)
         lRet := .F.
         cXmlRet := FWEAILOfMessages( aErrorMsg )
      EndIf

Return {lRet,cXMLRet}

/*
======================================================================================================
/{Protheus.doc} getIntId
//TODO Recupera a identificação interna da mensagem trafegada.
@author tiago.dsantos
@since 15/09/2016
@version 1.001

@type function
======================================================================================================
/*/
Method getIntId(cTitNum,cTipDoc, cFilOri) Class TransportDocumentClass
Local cResult       := ""

Default cTitNum     := ''
Default cTipDoc     := ''
Default cFilori     := ''

cResult := cFilOri + "|" + cTitNum + "|" + cTipDoc
      
Return cResult

/*/{Protheus.doc} getExtId
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 06/10/2016
@version undefined
@param cCodigo  , characters, Codigo externo obtido pelo depara
@param cMarca   , characters, Aplicação externa que enviou a mensagem
@param lPeriodo , logical, descricao
@type function
/*/
Method getExtId(cCodigo, cMarca) Class TransportDocumentClass
Local cValInt		:= ''
Local aRetorno		:= {}
Local aAux			:= {}
Local nX			:= 0
Local aCampos		:= {}

     aCampos		:= {cEmpAnt,'E2_FILIAL','E2_PREFIXO','E2_NUM','A2_CGC'}
	 cValInt 		:= CFGA070Int(cMarca, 'SE2', 'E2_NUM', cCodigo)
     
     If !Empty(cValInt)
	     aAux := Separa(cValInt,'|')
	
	     aAdd(aRetorno, .T.     ) //sucesso na recuperaçao do de-para
	     aAdd(aRetorno, aAux    ) //Array campo a campo do depara
	     aAdd(aRetorno, cValInt ) //chave interna - XXF
	
	     aRetorno[2][1] := Padr(aRetorno[2][1],Len(cEmpAnt))
	     For nX :=2 to Len(aRetorno[2]) //corrigindo  o tamanho dos campos
		      aRetorno[2][nX] := Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	     Next nX
	 
     Else
	     aAdd(aRetorno,.F.)
	     aAdd(aRetorno,{} )
	     aAdd(aRetorno,"" )
     EndIf

Return aRetorno

/*
========================================================================================================================
/{Protheus.doc} retTaxComp
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 11/11/2016
@version undefined
@param cPref, characters, descricao
@param cNum, characters, descricao
@param lPreview, logical, descricao
@param cCodInt, characters, descricao
@param nMoeda, characters, descricao
@type function
========================================================================================================================
/*/
Static Function retTaxComp(cPref,cNum,lPreview,cCodInt,nMoeda)
Local cEmiss     := DtoC(&(Iif(lPreview,"M->","SE2->")+"E2_EMISSAO"))
Local cVencto    := DtoC(&(Iif(lPreview,"M->","SE2->")+"E2_VENCTO" ))
Local cValorBr   := AllTrim(Transform(&(Iif(lPreview,"M->","SE2->")+"E2_VLCRUZ"),"@R 99,999,999.99"))
Local cValorLq   := AllTrim(Transform(&(Iif(lPreview,"M->","SE2->")+"E2_VALLIQ"),"@R 99,999,999.99"))
Local aTxFields  := {}
Local nx         := 1
Local cXmlResult := "" 
Local lMatched   := .F.
Local lEAICodUnq := Iif(Len( FwAdapterInfo("MATA020B","CUSTOMERVENDORRESERVEID") ) , .T. , .F. ) 
  
      //|
      //| Lista para retorno dos possiveis valores de impostos
      //|
      AADD(aTxFields,{"ISS"    , Iif(lPreview,"M->","SE2->")+"E2_ISS"    })
      AADD(aTxFields,{"COFINS" , Iif(lPreview,"M->","SE2->")+"E2_COFINS" })
      AADD(aTxFields,{"IRRF"   , Iif(lPreview,"M->","SE2->")+"E2_IRRF"   })
      AADD(aTxFields,{"INSS"   , Iif(lPreview,"M->","SE2->")+"E2_INSS"   })
      AADD(aTxFields,{"SEST"   , Iif(lPreview,"M->","SE2->")+"E2_SEST"   })
      AADD(aTxFields,{"PIS"    , Iif(lPreview,"M->","SE2->")+"E2_PIS"    })
      AADD(aTxFields,{"CSLL"   , Iif(lPreview,"M->","SE2->")+"E2_CSLL"   })
      
      SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
      lMatched := SE2->(MsSeek(xFilial("SE2") + cPref + cNum ))
      
      //|
      //| Quando não exister o registro no SE2, mas for indicado como previsão é alterado o valor
      //| de lMatched para .T. e assim sera gerado o grupo de tags com o SE2 virtual.
      //| O SE2 é gerado na memório pelo trecho de código abaixo desta chave TAGCODE: 20161114-1542
      //|
      If .Not. lMatched .And. lPreview == .T.
         lMatched := .T.
      EndIf

      If  lMatched

            cXmlResult :=  "<ListOfAccountPayableDocument>"   
            cXmlResult +=       "<AccountPayableDocument>"
            cXmlResult +=              "<CompanyId>"          + cEmpAnt                                      + "</CompanyId>"
            cXmlResult +=              "<BranchId>"           + cFilAnt                                      + "</BranchId>"
            cXmlResult +=              "<VendorCode>"         + SA2->A2_COD+IIf(lEAICodUnq,'',SA2->A2_LOJA)  + "</VendorCode>"
            cXmlResult +=              "<DocumentTypeCode>"   + &(Iif(lPreview,"M->","SE2->")+"E2_TIPO"   )  + "</DocumentTypeCode>"
            cXmlResult +=              "<DocumentPrefix>"     + &(Iif(lPreview,"M->","SE2->")+"E2_PREFIXO")  + "</DocumentPrefix>"
            cXmlResult +=              "<DocumentNumber>"     + &(Iif(lPreview,"M->","SE2->")+"E2_NUM"    )  + "</DocumentNumber>"
            cXmlResult +=              "<DocumentParcel>"     + &(Iif(lPreview,"M->","SE2->")+"E2_PARCELA")  + "</DocumentParcel>"
            cXmlResult +=              "<DocumentInternalId>" + cCodInt                                      + "</DocumentInternalId>"
            cXmlResult +=              "<CurrencyCode>"       + AllTrim(Str(nMoeda))                         + "</CurrencyCode>"
            cXmlResult +=              "<IssueDate>"          + cEmiss                                       + "</IssueDate>"
            cXmlResult +=              "<DueDate>"            + cVencto                                      + "</DueDate>"
            cXmlResult +=              "<GrossValue>"         + cValorBr                                     + "</GrossValue>"
            cXmlResult +=              "<NetValue>"           + cValorLq                                     + "</NetValue>"
				           
            cXmlResult +=              "<ListOfTaxes>
				                             
            //|
            //| Monta a lista de Imposto de acordo com o vetor aTxFields[]
            //| 
            For nx := 1 To Len(aTxFields)
                   If &(aTxFields[nx][2]) > 0
                        cXmlResult += "<Tax>"
                        cXmlResult +=     "<" + aTxFields[nx][1] + ">"  
                        cXmlResult +=         AllTrim(Transform(&(aTxFields[nx][2])  ,"@R 99,999,999.99"))
                        cXmlResult +=     "</" + aTxFields[nx][1] + ">"
                        cXmlResult += "</Tax>"
                   EndIf
            Next nx  

            cXmlResult +=              "</ListOfTaxes>"
            cXmlResult +=       "</AccountPayableDocument>"
            cXmlResult +=  "</ListOfAccountPayableDocument>"
       EndIf
Return cXmlResult

/*/{Protheus.doc} TMI250GINT
//TODO Converte o códio interno em vetor.
@author tiago.dsantos
@since 26/10/2016
@version undefined
@param cInterId, characters, descricao
@type function
/*/
Static Function TMI250GINT(cInterId)
Local aResult := {}
Local aCampos := {cEmpAnt,'E2_FILIAL','E2_PREFIXO','E2_NUM','A2_CGC'}
Local nX      := 1  
         //StrTokArr2( < cValue >, < cToken >, [ lEmptyStr ] )       
         aResult := StrTokArr2(cInterId,"|",.T.)
	     If Len(aResult) > 0
		     aResult[1] := Padr(aResult[1],Len(cEmpAnt))
		     For nX := 2 to Len(aResult)
			      aResult[nX] := Padr(aResult[nX],TamSX3(aCampos[nx])[1])
		     Next nX
	     EndIf
	     
Return aResult 

/*
/{Protheus.doc} getAttr
============================================================================================================
//TODO Função para obter o valor de um atributo de um Nó 
@author tiago.dsantos
@since 03/10/2016
@version 1.001
@param oXml        , object    , objeto do XML traduzido
@param aNodes      , array     , vetor contendo as repetições dentro de um grupo.
@param cAttrName   , characters, nome do atributo
@param cAttrValue  , characters, valor vinculado ao atributo
@type function
============================================================================================================
/*/
Static Function getAttrib(oXml,aNodes,cAttrName,cAttrValue)
Local cResult := ""
Local nI      := 0
Local nPos    := 0

      If Empty(aNodes)
         Return cResult
      EndIf
      
      For nI:=1 To Len(aNodes)
           aAttrib := oXml:xPathGetAttArray(aNodes[nI][2])
           
           nPos    := AScan(aAttrib, {|v| Upper(v[1]) == Upper(cAttrName) .And. Upper(v[2]) == Upper(cAttrValue) })
           
           If nPos > 0
               cResult := aNodes[nI][3] //| Conteudo da Tag ...não é o conteúdo do atributo.
               Exit
           EndIf
      Next nI
      
Return cResult


/*
============================================================================================================
/{Protheus.doc} salvaMsgInt
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 04/10/2016
@version undefined
@param oXml, object, descricao
@param cXmlRet, characters, descricao
@type function
/============================================================================================================
*/
Method salvaMsgInt(oXml,cAlias,cCampo,aMsgERet) Class TransportDocumentClass
Local lRet         := .T.
Local nX           := 1
Local cMarca       := oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
Local lStatus      := .F.
Local oXmlContent  := NIL 
Local cContType    := ""
Local cOrigin      := ""
Local cDestin      := ""
Local cEvent       := "upsert"
Local aMessages    := {}

     lStatus := Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
     
     If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage,"_RECEIVEDMESSAGE") <> Nil
        If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage,"_EVENT") <> Nil
            cEvent := Upper(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text)
        EndIf
     EndIf
                                             
     //|
     //| Tratamento do Retorno da Mensagem para gravar os InternalIds necessarios
     //| para o controle da aplicação.
     //|
     IF lStatus
         
          oXmlContent := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent//:_ReturnContent
          
         If (XmlChildEx( oXmlContent                  , '_LISTOFINTERNALID' ) <> Nil .And. ;
            XmlChildEx( oXmlContent:_ListOfInternalId, '_INTERNALID'       ) <> Nil) .Or.  ;
            XmlChildEx( oXmlContent                   , '_InternalID') 
            
            cContType := ValType(oXmlContent:_ListOfInternalId:_InternalId)
            
            //| Quando houver mais de um InternalId da mensagem
            If cContType == "A"
            
                XmlNode2Arr( oXmlContent:_ListOfInternalId:_InternalId,"_InternalId")
                
                //| Salva os codigos dos produtos na tabela XXF
	            For nX:=1 to Len(oXmlContent:_ListOfInternalId:_InternalId)

	                cOrigin := oXmlContent:_ListOfInternalId:_InternalId[nx]:_Origin:Text
	                cDestin := oXmlContent:_ListOfInternalId:_InternalId[nx]:_Destination:Text
	                
			        CFGA070MNT( cMarca,cAlias,cCampo ,;
			        cDestin ,; //| Código da outra aplicação
			        cOrigin ,; //| código gerado para o Protheus
			        (cEvent == "DELETE")) // Quando .T. deleta o registro de depara.  

		        Next nX
            
            //| Para apenas um InternalId na mensagem
            Else
                    cOrigin := oXmlContent:_ListOfInternalId:_InternalId:_Origin:Text
	                cDestin := oXmlContent:_ListOfInternalId:_InternalId:_Destination:Text
	                
			        CFGA070MNT( cMarca, "DTY", "DTY_NUMCTC" ,;
			        cDestin ,;           //| Código da outra aplicação
			        cOrigin ,;           //| código gerado pelo Protheus
			        (cEvent == "DELETE")) //| Quando .T. deleta o registro de depara.

            EndIf
		  
		  EndIf //[FECHA If XmlChildEx(oXmlContent) ... .And. XmlChildEx( oXmlContent:_ListOfInternalId, '_INTERNALID')]
		 
     //|
     //| Tratamento do Retorno da Mensagem de Erro
     //| 
	 Else
	     lRet    := .F.
	     
	     aMsgERet := SELF:ListErrors(oXML)
	     AAdd(aMsgERet,{"Falha ao gravar a relacao entre os produtos - InternalId",2,"WA001"})// 'Houve um erro na mensagem e este não pôde ser identificado.'
     EndIf
       
Return lRet


/*
========================================================================================================================
/{Protheus.doc} ListOfTaxes
//TODO Preenche as propriedades referentes ao retorno da Marca que processou a mensagem.
@author tiago.dsantos
@since  01/02/2017
@version 1.000
@param oXML, object, descricao
@type function
========================================================================================================================
/*/
Method getResults(oXML) Class TransportDocumentClass
Local oXmlPayDoc := NIL
Local oXmlTaxes  := NIL
Local aList      := {}
Local aTax       := {}
Local nk         := 1
Local nl         := 1

       If XmlChildEx(oXML:_TOTVSMessage,'_RESPONSEMESSAGE') != NIL .And. ;
          XmlChildEx(oXML:_TOTVSMessage:_RESPONSEMESSAGE,'_RETURNCONTENT') != NIL .And. ;
          XmlChildEx(oXML:_TOTVSMessage:_RESPONSEMESSAGE:_RETURNCONTENT,'_LISTOFACCOUNTPAYABLEDOCUMENT') != NIL .AND. ;
          XmlChildEx(oXML:_TOTVSMessage:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFACCOUNTPAYABLEDOCUMENT,'_ACCOUNTPAYABLEDOCUMENT') != NIL
           //| Converte o objeto oXML em vetor para o Grupo AccountPayableDocument caso exista repetição da tag
           //| <AccountPayableDocument> esse tratamento é necessário pois o datasul recebe uma mensagem que se
           //| desdobra em 'N' Titulos por exemplo (Pedágio, Frete e Adiantamento).
           //|
           If Valtype(oXML:_TOTVSMessage:_RESPONSEMESSAGE:_ReturnContent:_ListOfAccountPayableDocument:_ACCOUNTPAYABLEDOCUMENT) == "A"
                oXMLPayDoc := oXML:_TOTVSMessage:_RESPONSEMESSAGE:_ReturnContent:_ListOfAccountPayableDocument:_ACCOUNTPAYABLEDOCUMENT
                //XmlNode2Arr(oXMLPayDoc,"_AccountPayableDocument")
                For  nk := 1 To Len(oXMLPayDoc)
                     AAdd(aList,Nil)                     //| inclui-se no array o valor nil para receber ...
                     aList[Len(aList)] := oXmlPayDoc[nk] //| o objeto xml referente a tag AccountPayableDocument
                Next nk
           Else
                oXMLPayDoc := oXML:_TOTVSMessage:_RESPONSEMESSAGE:_ReturnContent:_ListOfAccountPayableDocument:_AccountPayableDocument
                AAdd(aList,nil)
                aList[Len(aList)] := oXmlPayDoc

           EndIf
           
            //|
            //| Set das propriedades com os valores retornados
            //|
            SELF:oResultSet := TDResultClass():New()

            For  nk := 1 To Len(aList)
                 If XmlChildEx(aList[nk],'_DOCUMENTTYPECODE') != NIL
                    SELF:oResultSet:cDocumentType := aList[nk]:_DOCUMENTTYPECODE:TEXT // Especie/Tipo do Titulo Retornado
                 EndIf
                 If XmlChildEx(aList[nk],'_DOCUMENTNUMBER') != NIL
                     SELF:oResultSet:cDocumentNumber := aList[nk]:_DOCUMENTNUMBER:TEXT // Numero do Titulo Retornado
                 EndIf
                 If XmlChildEx(aList[nk],'_DOCUMENTPARCEL') != NIL
                     SELF:oResultSet:nDocumentParcel := Val(aList[nk]:_DOCUMENTPARCEL:TEXT) // Parcela
                 EndIf
                 SELF:oResultSet:cDocumentPrefix := "" // Prefixo
                 
                 SELF:oResultSet:cIssueDate      := "" // Data de Emissão
                 SELF:oResultSet:cDueDate        := "" // Data de Vencimento

            Next nk //[CLOSE] For nk...

       EndIf

Return Nil
/*
========================================================================================================================
/{Protheus.doc} ListOfTaxes
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 29/11/2016
@version undefined
@param oXML, object, descricao
@type function
========================================================================================================================
/*/
Method ListOfTaxes(oXML) Class TransportDocumentClass
Local oXmlPayDoc := NIL
Local oXmlTaxes  := NIL
Local aList      := {}
Local aTax       := {}
Local nk         := 1
Local nl         := 1
Local cTipoImp   := ""
Local nValue     := 0
Local nPercent   := 0

       If XmlChildEx(oXML:_TOTVSMessage,'_RESPONSEMESSAGE') != NIL .And. ;
          XmlChildEx(oXML:_TOTVSMessage:_RESPONSEMESSAGE,'_RETURNCONTENT') != NIL .And. ;
          XmlChildEx(oXML:_TOTVSMessage:_RESPONSEMESSAGE:_RETURNCONTENT,'_LISTOFACCOUNTPAYABLEDOCUMENT') != NIL .And. ;
          XmlChildEx(oXML:_TOTVSMessage:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFACCOUNTPAYABLEDOCUMENT,'_ACCOUNTPAYABLEDOCUMENT') != NIL
          
           //| Converte o objeto oXML em vetor para o Grupo AccountPayableDocument caso exista repetição da tag
           //| <AccountPayableDocument> esse tratamento é necessário pois o datasul recebe uma mensagem que se
           //| desdobra em 'N' Titulos por exemplo (Pedágio, Frete e Adiantamento).
           //|
           If Valtype(oXML:_TOTVSMessage:_RESPONSEMESSAGE:_ReturnContent:_ListOfAccountPayableDocument:_ACCOUNTPAYABLEDOCUMENT) == "A"
                oXMLPayDoc := oXML:_TOTVSMessage:_RESPONSEMESSAGE:_ReturnContent:_ListOfAccountPayableDocument:_ACCOUNTPAYABLEDOCUMENT
                //XmlNode2Arr(oXMLPayDoc,"_AccountPayableDocument")
                For  nk := 1 To Len(oXMLPayDoc)
                     AAdd(aList,Nil)                     //| inclui-se no array o valor nil para receber ...
                     aList[Len(aList)] := oXmlPayDoc[nk] //| o objeto xml referente a tag AccountPayableDocument
                Next nk
           Else
                oXMLPayDoc := oXML:_TOTVSMessage:_RESPONSEMESSAGE:_ReturnContent:_ListOfAccountPayableDocument:_AccountPayableDocument
                AAdd(aList,nil)
                aList[Len(aList)] := oXmlPayDoc

           EndIf

           //+---------------------------------------------------------------------------------
           //| Monta a listagem de Impostos
           //| Enums aceitos:
           //| ITF              : Imposto sobre movimentação financeira
           //| COFINS           :   
           //| CSLL
           //| FABOV
           //| FACS
           //| INSS-PF
           //| INSS-PJ
           //| INSS-RUR
           //| IOF
           //| IR-CARRETEIRO
           //| IRRF–PF
           //| IRRF–PJ
           //| ISS
           //| ISS-ARQ-ELET
           //| PIS
           //| PIS/COFINS/CSLL
           //| PIS/COFINS-CRED
           //| PIS/COFINS-PROD
           //| SEST/SENAT
           //| ICM
           //| IPI
           //| II               :Impostos sobre produtos Importados.
           //+---------------------------------------------------------------------------------
           For  nk := 1 To Len(aList)
                If XmlChildEx(aList[nk],'_LISTOFTAXES') != Nil .And.;
                   XmlChildEx(aList[nk]:_LISTOFTAXES,'_TAX') != Nil
                      
                      If ValType(aList[nk]:_LISTOFTAXES:_TAX) == "O"

                          cTipoImp := Upper(AllTrim(aList[nk]:_LISTOFTAXES:_TAX:_Taxe:Text))
                          nValue   := Val(aList[nk]:_LISTOFTAXES:_TAX:_Value:Text)
                          nPercent := Val(aList[nk]:_LISTOFTAXES:_TAX:_Percentage:Text)
                          
                          SELF:oImpostos:SetTaxProp(cTipoImp, nValue,nPercent,SELF:cPessoa) 

                      Else
                           //XmlNode2Arr(aList[nK]:_ListOfTaxes:_Tax,"_Tax")
                           For  nl:= 1 To Len(aList[nK]:_ListOfTaxes:_Tax)
                                
                                If XmlChildEx(aList[nk]:_ListOfTaxes:_Tax[nl],'_TAXE') != Nil
                                      
                                      cTipoImp := Upper(AllTrim(aList[nk]:_LISTOFTAXES:_TAX[nl]:_Taxe:Text))
                                      nValue   := Val(aList[nk]:_LISTOFTAXES:_TAX[nl]:_Value:Text)
                                      nPercent := Val(aList[nk]:_LISTOFTAXES:_TAX[nl]:_Percentage:Text)
                                      
                                      SELF:oImpostos:SetTaxProp(cTipoImp, nValue,nPercent,SELF:cPessoa)
                                EndIf

                           Next nl

                      EndIf //|[FECHA] If ValType(aList[nk]:_LISTOFTAXES:_TAX) == "O"

                EndIf //|[FECHA] If XmlChildEx(aList[nk],'_LISTOFTAXES') != Nil .And. (...)

           Next nk

       EndIf

Return Nil

/*
======================================================================================================
 /{Protheus.doc} M050LisMsg
 //TODO Descrição auto-gerada.
 @author tiago.dsantos
 @since 22/11/2016
 @version undefined
 @param oXml, object, descricao
 @type function
======================================================================================================
*/
Method ListErrors(oXML) Class TransportDocumentClass
Local aLisMsg := {}
Local cMsg    := ""
Local cType   := ""
Local cCode   := ""
Local nType   := 1
Local nCount  := 0
	
	//-- Mensagens de erro no padrao ListOfMessages
	If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_PROCESSINGINFORMATION' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' ) != Nil
	   
		//-- Se nao for array
		If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
			//-- Transforma em array
			XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
		EndIf

		//-- Percorre o array para obter os erros gerados
		For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
		
			cMsg    := ""
			cType   := ""
			cCode   := ""
			nType   := 1
			
			cMsg := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text

			//-- Verifica se o tipo da mensagem foi informado
			If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_TYPE' ) != Nil .And.;
			  !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text)
				cType := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text
				Do Case
				Case (Upper(cType) == "ERROR")
					nType := 1
				Case (Upper(cType) == "WARNING")
					nType := 2
				EndCase
			EndIf

			//-- Verifica se o codigo da mensagem foi informado
			If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_CODE' ) != Nil .And.;
			  !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text)
				cCode := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text
			EndIf
			
			If ! Empty(cCode)
				cMsg += " (" + cCode + ")"
			EndIf
			
			Aadd(aLisMsg, {cMsg, nType, cCode})
		Next nCount
	EndIf

Return aLisMsg

