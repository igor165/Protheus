#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F012CreTab
Creación de tabla temporal para generación de informe FISR012.
@type function
@author Oscar García López
@since 11/06/2019
@version 1.0
@Param 
	cpArqTRB2: Nombre de la tabla temporal.

@example
	F012CreTab(cpArqTRB2) 
@see (links_or_references)
/*/
Function F012CreTab(cpArqTRB2)
	Local aCampos	:= {}
	Local aOrder	:= {}
	Local nX		:= 0
	Local cTipCampo	:= ""
	
	Default cpArqTRB2 = ""
	
	//Actualiza estructura
	aCampos := TRB3->(DBStruct())
	
	For nX := 1 To Len(aCampos)
		cTipCampo := FWSX3Util():GetFieldType(aCampos[nX][1]) 
		If !Empty(cTipCampo)
			aCampos[nX][3] := GetSX3Cache(aCampos[nX][1], "X3_TAMANHO")
			aCampos[nX][4] := GetSX3Cache(aCampos[nX][1], "X3_DECIMAL")
		EndIf
	Next nX
	
	//Creacion de Objeto
	aOrder := {"F3_ENTRADA","F3_CLIEFOR","F3_LOJA","F3_NFISCAL","F3_SERIE"}
	oTmpTRB4 := FWTemporaryTable():New("TRB4")
	oTmpTRB4:SetFields(aCampos)
	oTmpTRB4:AddIndex("I1", aOrder)
	oTmpTRB4:Create()
	
	//Llenado de la tabla temporal
	DbSelectArea("TRB3")
	TRB3->(DBGoTop())
	
	While TRB3->(!Eof())
		RecLock("TRB4", .T.)
			For nX := 1 To Len(aCampos)
				TRB4->(&(aCampos[nX][1])) := TRB3->(&(aCampos[nX][1]))
			Next nX
		TRB4->(MsUnlock())
	TRB3->(DBSkip())
	EndDo
Return

/*/{Protheus.doc} F012DelTab
Cierre de tabla temporal para generación de informe FISR012.
@type function
@author Oscar García López
@since 11/06/2019
@version 1.0 
@example
	F012DelTab() 
@see (links_or_references)
/*/
Function F012DelTab()
	If Select("TRB4") > 0
		TRB4->(DBCloseArea())
	EndIf	

	If oTmpTRB4 <> Nil
		oTmpTRB4:Delete()
		FreeObj(oTmpTRB4)
		oTmpTRB4 := Nil
	EndIf
Return