#include "TOTVS.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE CCOS   "CCOS"
#DEFINE BUSCA  "07"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc}
Class CenOffApi
Classe genérica responsável por inserir os registros sem a necessidade de API
@author david.juan
@since 04/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Class CenOffApi
    Data oRequest as Object
    Data cJson as String
    Data page as String
    Data pageSize as String
    Data fields as String
    Data search as String
    Data filter as String
    Data expand as String
    Data order as String
    Data uniqueKey as String
    Data cResponse as String
    Data nStatus as Number
    Data lSuccess as Boolean

    Method New(cJson) Constructor
    Method Destroy()

    Method setContent(cContent)
    Method getContent()
    Method setStatus(nStatus)
    Method getStatus()
    Method setResponse(cResponse)
    Method getResponse()
    Method getData()
    Method post()
    Method getCollection()
    Method getSingle()
    Method delete()
    Method getSuccess()
    Method setSuccess(lSuccess)
    Method getPage()
    Method setPage(cPage)
    Method getPageSize()
    Method setPageSize(cPageSize)
    Method getFields()
    Method setFields(cFields)
    Method getSearch()
    Method setSearch(cSearch)
    Method getFilter()
    Method setFilter(cFilter)
    Method getExpand()
    Method setExpand(cExpand)
    Method getOrder()
    Method setOrder(cOrder)
    Method getUniqueKey()
    Method setUniqueKey(cUniqueKey)

EndClass

Method New(cJson) Class CenOffApi
    Default cJson   := '{}'
    self:cJson      := cJson
Return self

Method Destroy() Class CenOffApi
    self:oRequest:Destroy()
    FreeObj(self:oRequest)
    self:oRequest := nil
Return

Method setContent(cContent) Class CenOffApi
    Default cContent := ''
    self:cJson := cContent
Return

Method getContent() Class CenOffApi
Return self:cJson

Method setStatus(nStatus) Class CenOffApi
    Default nStatus := 0
    self:nStatus := nStatus
Return

Method getStatus() Class CenOffApi
Return self:nStatus

Method setResponse(cResponse) Class CenOffApi
    Default cResponse := ''
    self:cResponse := cResponse
Return

Method getResponse() Class CenOffApi
Return self:cResponse

Method getData() Class CenOffApi
    self:oRequest   := nil
    self:setPage()
    self:setPageSize()
    self:setFields()
    self:setSearch()
    self:setFilter()
    self:setExpand()
    self:setOrder()
    self:setUniqueKey()
    self:setResponse()
    self:setStatus()
Return

Method post() Class CenOffApi
    self:lSuccess := .F.

    self:getData()
    If self:oRequest != nil
        self:oRequest:initRequest()
        self:oRequest:checkBody()
        self:oRequest:applyFields(self:getFields())
        self:oRequest:applyPageSize()
        self:lSuccess := self:oRequest:procPost()
        self:oRequest:endRequest()
    endif

Return self:lSuccess

Method getCollection() Class CenOffApi
    self:lSuccess := .F.

    self:getData()
    If self:oRequest != nil
        oRequest:initRequest()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:getFields())
        oRequest:applyExpand(self:getExpand())
        oRequest:applyOrder(self:getOrder())
        oRequest:applyPageSize()
        oRequest:buscar(BUSCA)
        oRequest:applySearch(self:getSearch())
        self:lSuccess := oRequest:procGet(ALL)
        oRequest:endRequest()
    endif
Return self:lSuccess

Method getSingle() Class CenOffApi
    self:lSuccess := .F.

    self:getData()
    If self:oRequest != nil
        oRequest:initRequest()
        oRequest:applyFilter(SINGLE)
        oRequest:applyFields(self:getFields())
        oRequest:applyExpand(self:expand)
        oRequest:applyPageSize()
        oRequest:buscar(BUSCA)
        self:lSuccess := oRequest:procGet(SINGLE)
        oRequest:endRequest()
    endif
Return self:lSuccess

Method delete() Class CenOffApi
    self:lSuccess := .F.

    self:getData()
    If self:oRequest != nil
        oRequest:initRequest()
        oRequest:applyFilter(SINGLE)
        oRequest:applyPageSize()
        oRequest:buscar(SINGLE)
        self:lSuccess := oRequest:procDelete()
        oRequest:endRequest()
    endif
Return self:lSuccess

Method getSuccess() Class CenOffApi
Return self:lSuccess

Method setSuccess(lSuccess) Class CenOffApi
    Default lSuccess:= .F.
    self:lSuccess   := lSuccess
Return

Method getPage() Class CenOffApi
Return self:page

Method setPage(cPage) Class CenOffApi
    Default cPage   := ''
    self:page       := cPage
Return

Method getPageSize() Class CenOffApi
Return self:pageSize

Method setPageSize(cPageSize) Class CenOffApi
    Default cPageSize   := ''
    self:pageSize   := cPageSize
Return

Method getFields() Class CenOffApi
Return self:fields

Method setFields(cFields) Class CenOffApi
    Default cFields := ''
    self:fields     := cFields
Return

Method getSearch() Class CenOffApi
Return self:search

Method setSearch(cSearch) Class CenOffApi
    Default cSearch := ''
    self:search     := cSearch
Return

Method getFilter() Class CenOffApi
Return self:filter

Method setFilter(cFilter) Class CenOffApi
    Default cFilter := ''
    self:filter     := cFilter
Return

Method getExpand() Class CenOffApi
Return self:expand

Method setExpand(cExpand) Class CenOffApi
    Default cExpand := ''
    self:expand     := cExpand
Return

Method getOrder() Class CenOffApi
Return self:order

Method setOrder(cOrder) Class CenOffApi
    Default cOrder  := ''
    self:order      := cOrder
Return

Method getUniqueKey() Class CenOffApi
Return self:uniqueKey

Method setUniqueKey(cUniqueKey) Class CenOffApi
    Default cUniqueKey  := ''
    self:uniqueKey  := cUniqueKey
Return