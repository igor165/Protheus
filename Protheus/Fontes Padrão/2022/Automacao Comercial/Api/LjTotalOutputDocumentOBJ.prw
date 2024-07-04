#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWADAPTEREAI.CH" 
 
Class TotalOutputDocument
	DATA cError     	 as CHARACTER	
	DATA oOutputDocument     as OBJECT	
	DATA cDetail      	 as CHARACTER
	DATA oFieldsJson 	 as OBJECT
	DATA oEaiobjSnd  	 as OBJECT
	DATA oEaiobjRec  	 as OBJECT
	DATA aParam          as ARRAY
	DATA oFields         as array
	
	METHOD NEW()
	METHOD GetFieldsNames()
	METHOD CreateQuery()
	METHOD GetVersion()
	METHOD GetOutputDocument()	
	METHOD GetCanceledOutputDocument()
EndClass

Method NEW() CLASS TotalOutputDocument
	
	Self:cError       := ''  
	Self:cDetail      := ""
	self:oFieldsJson  := self:GetFieldsNames()
	self:oFields 	  := {}
	self:oEaiobjSnd   := FWEAIObj():NEW()
	self:oEaiObjRec   := Nil

return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetBranch
Método que ira buscar e retornar as filais

@param oModel Modelo de dados para criaçao da mensagem de envio

@return Vazio

@author Caio Quiqueto dos Santos
@since 13/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetOutputDocument() CLASS TotalOutputDocument
Local nPos       	as NUMERIC
Local nCount     	as NUMERIC
Local cError       	as CHARACTER
Local cAliasTSale 	as CHARACTER
Local aArea      	as ARRAY
Local aFields		as ARRAY
Local oPage      	as OBJECT
Local cFromDate	   as CHARACTER
Local cToDate	   as CHARACTER

aArea   := getArea()

nCount := 0

cError := ''

if !empty(Self:oEaiObjRec:GetPage())
	oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
EndIf

Self:oEaiobjSnd:Activate()
cAliasTSale:=Self:CreateQuery(@cFromDate,@cToDate)
aFields := Self:oFieldsJson:getProperties()

If !(cAliasTSale)->(EOF())
	If !Empty(Self:oFields) .AND. Upper('FromDate') $ Upper(Self:oFields)
		Self:oEaiobjSnd:setProp('FromDate'   	,sTod(cFromDate))
	ElseIf Empty(Self:oFields)
		Self:oEaiobjSnd:setProp('FromDate'   	,sTod(cFromDate))
	EndIf	
	If !Empty(Self:oFields) .AND. Upper('ToDate') $ Upper(Self:oFields)
		Self:oEaiobjSnd:setProp('ToDate'     	,sTod(cToDate))
	ElseIf Empty(Self:oFields)
		Self:oEaiobjSnd:setProp('ToDate'     	,sTod(cToDate))
	EndIf	
	For nPos:= 1 to Len(aFields) 
		If !Empty(Self:oFields) .AND. Upper(aFields[nPos]) $ Upper(Self:oFields) 
			Self:oEaiobjSnd:setProp(aFields[nPos],(cAliasTSale)->&(Self:oFieldsJson[aFields[nPos]])) 
		ElseIf Empty(Self:oFields)
			Self:oEaiobjSnd:setProp(aFields[nPos],(cAliasTSale)->&(Self:oFieldsJson[aFields[nPos]])) 
		EndIf	
	Next	
EndIf
Self:oEaiobjSnd:setHasNext(.F.)

(cAliasTSale)->(DBCloseArea())
restArea(aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetcanceledOutputDocument
Método que ira buscar e retornar Totais das Vendas Canceladas

@param Vazio

@return Vazio

@author Caio Quiqueto dos Santos
@since 13/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCanceledOutputDocument() CLASS TotalOutputDocument
Local nPos       	as NUMERIC
Local nCount     	as NUMERIC
Local cError       	as CHARACTER
Local cAliasTSale 	as CHARACTER
Local aArea      	as ARRAY
Local aFields		as ARRAY
Local oPage      	as OBJECT
Local cFromDate	   	as CHARACTER
Local cToDate	   	as CHARACTER
Local lCanceled		as LOGICAL	

aArea   := getArea()
lCanceled := .T.
nCount := 0

cError := ''

if !empty(Self:oEaiObjRec:GetPage())
	oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
EndIf

Self:oEaiobjSnd:Activate()
cAliasTSale:=Self:CreateQuery(@cFromDate,@cToDate,lCanceled)
aFields := Self:oFieldsJson:getProperties()

If !(cAliasTSale)->(EOF())
	If !Empty(Self:oFields) .AND. Upper('FromDate') $ Upper(Self:oFields)
		Self:oEaiobjSnd:setProp('FromDate'   	,sTod(cFromDate))
	ElseIf Empty(Self:oFields)
		Self:oEaiobjSnd:setProp('FromDate'   	,sTod(cFromDate))
	EndIf	
	If !Empty(Self:oFields) .AND. Upper('ToDate') $ Upper(Self:oFields)
		Self:oEaiobjSnd:setProp('ToDate'     	,sTod(cToDate))
	ElseIf Empty(Self:oFields)
		Self:oEaiobjSnd:setProp('ToDate'     	,sTod(cToDate))
	EndIf	
	For nPos:= 1 to Len(aFields) 
		If !Empty(Self:oFields) .AND. Upper(aFields[nPos]) $ Upper(Self:oFields) 
			Self:oEaiobjSnd:setProp(aFields[nPos],IIF(Upper(aFields[nPos]) == 'AMOUNT',Alltrim(TRANSFORM((cAliasTSale)->&(Self:oFieldsJson[aFields[nPos]]),"@E 99,999,999,999.99")) , (cAliasTSale)->&(Self:oFieldsJson[aFields[nPos]]) ) )
		ElseIf Empty(Self:oFields)
			Self:oEaiobjSnd:setProp(aFields[nPos],IIF(Upper(aFields[nPos]) == 'AMOUNT',Alltrim(TRANSFORM((cAliasTSale)->&(Self:oFieldsJson[aFields[nPos]]),"@E 99,999,999,999.99")), (cAliasTSale)->&(Self:oFieldsJson[aFields[nPos]]) ) )
		EndIf	
	Next	
EndIf
Self:oEaiobjSnd:setHasNext(.F.)

(cAliasTSale)->(DBCloseArea())
restArea(aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} CreateQuery
Metodo que monta a query para busca de valores nas tabelas necessarias

@param Vazio

@return Vazio

@author Caio Quiqueto dos Santos
@since 13/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method CreateQuery(cFromDate,cToDate,lCanceled) CLASS TotalOutputDocument
Local lRet 		   as LOGICAL
Local nX 		   as NUMERIC
Local cWhere       as CHARACTER
Local cOrder	   as CHARACTER
Local cFields	   as CHARACTER
Local cEmp		   as CHARACTER
Local cBRANCHES	   as CHARACTER
Local aTemp		   as ARRAY
Local oJsonFilter  as OBJECT

Default lCanceled := .F.

	lRet := .T.
	//verifica se foi enviado o Range de data.
	oJsonFilter  := Self:oEaiObjRec:getFilter()	
	If oJsonFilter != Nil
		cFromDate := iIF(!Empty(oJsonFilter["FROMDATE"]),StrTran(oJsonFilter["FROMDATE"], "-", "" ),dTos((dDataBase -30)))
		cToDate	  := iIF(!Empty(oJsonFilter["TODATE"])  ,StrTran(oJsonFilter["TODATE"]  , "-", "" ),dTos(dDataBase))
		cFromDate := iIF(Len(cFromDate) > 8,cFromDate := &cFromDate,cFromDate)//tratamento de memoria, por algum motivo o retorno na varivel fica com tamanho de 10.
		cToDate   := iIF(Len(cToDate) > 8,cToDate := &cToDate,cToDate)//tratamento de memoria, por algum motivo o retorno na varivel fica com tamanho de 10.
	Else
		cFromDate := dTos((dDataBase -30))
		cToDate	  := dTos(dDataBase)
	EndIf
	cAliasTSale := "OutputDocument"
	cWhere := "1=1"
	cWhere += " AND "
	cWhere += " SF2.F2_EMISSAO BETWEEN '"+cFromDate+"' AND '"+cTodate+"' "
	//Faz o Tratamento do filtro de Filiais retira a empresa.
	If !Empty(oJsonFilter["BRANCHES"])
		nX := At('|',oJsonFilter["BRANCHES"])
		cEmp := Substr(oJsonFilter["BRANCHES"],1,nX- 1)//retirar empresa da filial
		cBRANCHES := StrTran(oJsonFilter["BRANCHES"]  , cEmp+"|","") 
		cWhere += " AND SF2.F2_FILIAL IN ("+"'"+StrTran(cBRANCHES  , ",", "','")+"')"
	Else
		//Se não passar as filiais então deve buscar de todas.
		//cWhere += " AND SF2.F2_FILIAL = '"+xFilial("SF2")+"'" 
	EndIf	
 	
 	aTemp := Self:oEaiObjRec:getOrder()
	cOrder := ''
	for nX := 1 to len(aTemp)
		if nX != 1
			cOrder += ','
		Endif

		if substr(aTemp[nX],1,1) == '-'
			if !empty(Self:oFieldsJson[upper(substr(aTemp[nX],2))])
				cOrder += Self:oFieldsJson[upper(substr(aTemp[nX],2))] + ' desc'
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
				lRet := .F.
			EndIf
		Else
			if !Empty(Self:oFieldsJson[upper(aTemp[nX])])
				cOrder += Self:oFieldsJson[upper(aTemp[nX])]
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
				lRet := .F.
			EndIf
		EndIf
	next nX

	IF Empty(cOrder)
		cOrder := '1'
	EndIf

	if lRet
		cFields := "1"
		cFields += ","
		cFields += "SUM(F2_VALBRUT) as F2_VALBRUT "
		cFields += ", COUNT(F2_DOC) as F2_DOC "
		  
		cWhere  := '%'+cWhere+'%'
		cOrder  := '%'+cOrder+'%'
		cFields := '%'+cFields+'%'
		If !lCanceled 
			BeginSql alias cAliasTSale
				column F2_EMISSAO as Date
				SELECT %exp:cFields%
				FROM
					%table:SF2% SF2
				INNER JOIN %table:SL1% SL1 ON
				SL1.%NotDel%
				AND SL1.L1_FILIAL = SF2.F2_FILIAL
				AND SL1.L1_DOC    = SF2.F2_DOC
				AND SL1.L1_SERIE  = SF2.F2_SERIE
				AND SL1.L1_SITUA  = 'OK'
				AND SL1.L1_ORIGEM = 'N' ////Integracao Mensagem Unica adiciona informacoes da integracao Fonte:LOJA701C
				WHERE %exp:cWhere% 
				AND SF2.%NotDel%
				ORDER BY %exp:cOrder%
			EndSql
		Else
			BeginSql alias cAliasTSale
				column F3_EMISSAO as Date
				column F2_EMISSAO as Date
				SELECT %exp:cFields%
				FROM
					%table:SF2% SF2
				INNER JOIN %table:SF3% SF3 ON  	
				SF2.F2_FILIAL = SF3.F3_FILIAL
				AND SF2.F2_DOC = SF3.F3_NFISCAL	
				AND SF2.F2_SERIE = SF3.F3_SERIE
				WHERE %exp:cWhere% 
				AND SF3.%NotDel%
				AND SF3.F3_DTCANC <> %exp:Space(TAMSX3("F3_DTCANC")[1])%
				ORDER BY %exp:cOrder% 
			EndSql
		EndIf	
	EndIf

Return cAliasTSale
//-------------------------------------------------------------------
/*/{Protheus.doc} GetFieldsNames
Método que retorna a estrutura da mensagem em um objeto JSON

@param Vazio

@return nil

@author Everson S. P. Junior
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFieldsNames() CLASS TotalOutputDocument
Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')
	oFieldsJson['Quantity']  	:= 'F2_DOC'
	oFieldsJson['Amount']		:= 'F2_VALBRUT'
return oFieldsJson



