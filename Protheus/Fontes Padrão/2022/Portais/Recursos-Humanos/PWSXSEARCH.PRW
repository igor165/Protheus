#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWEBEX.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"  
#INCLUDE "PWSXSEARCH.CH"
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    11/06/2015        ³  307858   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/
WEB FUNCTION PWSXSEARCH()
	Local cHtml := ""
	Local oCfgDictionary
	Local nCountRow, nCountColumn
	Local nTotalRows, nTotalColumns
	Local lRet:= .T.
	
	Private cQueryName:= HttpGet->cStandardQuery
	Private aIndexData
	Private aHeaderData:= {}
	Private aRows:= {}
	Private aRecNos:= {}
	Private nPagina:= IIf(ValType(HttpGet->nPage) != "U", Val(HttpGet->nPage), 1)
	Private cBusca:= IIf(ValType(HttpGet->cSearch) != "U", HttpGet->cSearch, "")
	Private cSequencia:= IIf(ValType(HttpGet->cSequence) != "U", HttpGet->cSequence, "01")
	Private cReturnID:= IIf(ValType(HttpGet->cReturnID) != "U", HttpGet->cReturnID, "")
	Private cFiltro	:= IIf(ValType(HttpGet->cFiltro) != "U", HttpGet->cFiltro, "")
	Private cFunction := IIf(ValType(HttpGet->cFunction) != "U", HttpGet->cFunction, "")
	
	Private nTotalPaginas
	Private cTitulo
    If !Empty(HttpSession->cFunction) .And. Empty(cFunction)
		cFunction := HttpSession->cFunction
	EndIf

	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml //START "InSite"
	
	oCfgDictionary := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	If !Empty(httpSession->cEmpTrans) .And. HttpSession->cTypeRequest == "4"
		WsChgURL(@oCfgDictionary, "CfgDictionary.APW",,,httpSession->cEmpTrans)
	Else
		WsChgURL(@oCfgDictionary, "CfgDictionary.APW",,,GetEmpFun())
	EndIf
	lRet:= oCfgDictionary:GetSXBData(cQueryName, cFiltro)

	If lRet
		cTitulo:= oCfgDictionary:oWSGetSXBDataRESULT:cTitle
		nTotalPaginas:= oCfgDictionary:oWSGetSXBDataRESULT:nPageCount
		aIndexData:= oCfgDictionary:oWSGetSXBDataRESULT:oWSListOfIndex:oWSXBDataIndexView
		
		For nCountColumn:= 1 to Len(oCfgDictionary:oWSGetSXBDataRESULT:OWSLISTOFCOLUMN:OWSXBDATACOLUMNVIEW)
			AAdd(aHeaderData, oCfgDictionary:oWSGetSXBDataRESULT:OWSLISTOFCOLUMN:OWSXBDATACOLUMNVIEW[nCountColumn]:OWSLISTOFFIELD:OWSXBDATAFIELDVIEW)
		Next nCountColumn
		
		
		lRet:= oCfgDictionary:GetSXBDataPage(cQueryName, cSequencia, nPagina, cBusca, cFiltro)

		If lRet
			If Len(oCfgDictionary:oWSGetSXBDataPageRESULT:OWSLISTOFFIELD:OWSXBDBFIELDVIEW) > 0			
				nTotalRows:= Len(oCfgDictionary:oWSGetSXBDataPageRESULT:OWSLISTOFFIELD:OWSXBDBFIELDVIEW[1]:OWSLISTOFVALUE:OWSXBDBVALUEVIEW)
				nTotalColumns:= Len(oCfgDictionary:oWSGetSXBDataPageRESULT:OWSLISTOFFIELD:OWSXBDBFIELDVIEW)
			EndIf
			
			For nCountRow:= 1 To nTotalRows
				AAdd(aRows, Array(nTotalColumns))
				AAdd(aRecNos, oCfgDictionary:oWSGetSXBDataPageRESULT:OWSLISTOFFIELD:OWSXBDBFIELDVIEW[1]:OWSLISTOFVALUE:OWSXBDBVALUEVIEW[nCountRow]:nRecNo)
				
				For nCountColumn:= 1 To nTotalColumns
					aRows[nCountRow, nCountColumn]:= oCfgDictionary:oWSGetSXBDataPageRESULT:OWSLISTOFFIELD:OWSXBDBFIELDVIEW[nCountColumn]:OWSLISTOFVALUE:OWSXBDBVALUEVIEW[nCountRow]:CVALUE
				Next				
			Next
			
			cHtml += ExecInPage( "PWSXSEARCH" )
		EndIf		
	EndIf
	
	If !lRet
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "javascript:CloseSearch();"}
		Return ExecInPage("PWSAMSG")
	EndIf
	
	WEB EXTENDED END
RETURN cHtml




WEB FUNCTION PWSXRESULT()
	Local cHtml := ""
	Local cAlias	:=IIf(ValType(HttpGet->cStandardQuery) != "U",	HttpGet->cStandardQuery,	"")
	Local nRecno	:=IIf(ValType(HttpGet->nRecNo) != "U",			val(HttpGet->nRecNo), 		0)	
	Private aResult

	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml	

	oCfgDictionary := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	If !Empty(httpSession->cEmpTrans) .And. HttpSession->cTypeRequest == "4"
		WsChgURL(@oCfgDictionary, "CfgDictionary.APW",,,httpSession->cEmpTrans)
	Else
		WsChgURL(@oCfgDictionary, "CfgDictionary.APW",,,GetEmpFun())
	EndIf
	
	If oCfgDictionary:GetSXBResult(cAlias, nRecno)
		aResult:= oCfgDictionary:oWSGetSXBResultRESULT:OWSXBRESULTVIEW

		cHtml += ExecInPage( "PWSXRESULT" )				
	EndIf
			
	WEB EXTENDED END
RETURN cHtml

Function GetEmpFun()
Local cEmpFun	:= ""

If type("HttpSession->DadosFunc:CEMPLOYEEEMP") == "C"
	If !Empty(HttpSession->DadosFunc:CEMPLOYEEEMP)
		cEmpFun := HttpSession->DadosFunc:CEMPLOYEEEMP
	EndIf
EndIf

Return cEmpFun
