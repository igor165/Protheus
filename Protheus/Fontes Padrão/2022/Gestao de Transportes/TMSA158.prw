#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TMSA158.ch'

/*/{Protheus.doc} TMSA158
//Tela usada para consulta de demandas
@author wander.horongoso
@since 31/01/2019
@version 1.0
@type function
/*/
Function TMSA158()
Private oBrowse := nil
Private c158RetSta := ''
Private cRetF3Esp  := ''
	
  	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0003) // Consulta de Demandas	
	oBrowse:SetAlias('DL8')
	oBrowse:SetMenuDef('TMSA158')
	oBrowse:AddStatusColumns({||TMSCLegDmd('DL8_STATUS', DL8->DL8_STATUS)}, {||TMSLegDmd('DL8_STATUS')})
		
	TMA158Par(1)
		       
Return

/*/{Protheus.doc} MenuDef
//Menu do programa
@author wander.horongoso
@since 31/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
Local aRotina := {}

	aAdd(aRotina, {STR0001, 'VIEWDEF.TMSA153A', 0, 2, 0, NIL}) //Visualizar
	aAdd(aRotina, {STR0002, 'TMA154Par(3, "", DL8->DL8_COD, DL8->DL8_SEQ, "", DL8->DL8_CLIDEV, DL8->DL8_LOJDEV, 2)', 0, 2, 0, NIL}) //Tracking
	aAdd(aRotina, {STR0004, 'TMA158Par(2)', 0, 2, 0, NIL}) //Parâmetros (F5)

Return aRotina

/*/{Protheus.doc} TMA158Par
//parametros do browse
@author wander.horongoso
@since 31/01/2019
@version 1.0
@type function
/*/
Function TMA158Par(nOpc)
		
	If Pergunte('TMSA158',.T.)
		If nOpc == 1 
			SetKey(VK_F5,{ ||TMA158Par(2)} )
			oBrowse:SetFilterDefault(TMA158Filt())
			oBrowse:Activate()
		ElseIf nOpc == 2
			oBrowse:SetFilterDefault(TMA158Filt()) 
			oBrowse:Refresh(.T.)
		EndIf
	EndIf		
	
Return Nil

/*/{Protheus.doc} TMA158Filt
//Filtro da tela de consulta de demandas
@author wander.horongoso
@since 31/01/2019
@version 1.0
@type function
/*/
Function TMA158Filt()
Local cRet  := ""
Local cMult := " "
Local aMult := {}
Local nX    := 0
		
	aMult := StrtoKArr(MV_PAR01, ";")
	If !(Empty(MV_PAR01)) .AND. AllTrim(aMult[1]) <> STR0005 //Todos
		For nX := 1 to len(aMult)
			cMult += "'" + AllTrim(aMult[nX]) + "'"
			If nX < Len(aMult)
				cMult += ','
			EndIf 
		Next nX
	EndIf
	
	If !Empty(cMult)
		cRet += "@DL8_FILEXE IN (" + Alltrim(cMult) + ")"
	EndIf
	
	If !Empty(MV_PAR02) .Or. !Empty(MV_PAR03)
		cRet += Iif(Empty(cRet), "@", " AND ") + "DL8_CRTDMD >= '" +  Alltrim(MV_PAR02) + "'" + " AND DL8_CRTDMD <= '" +  Alltrim(MV_PAR03) + "'"
	EndIf
		
	If !Empty(MV_PAR04) .Or. !Empty(MV_PAR06)
		cRet += Iif(Empty(cRet), "@", " AND ") + "DL8_CLIDEV >= '" +  Alltrim(MV_PAR04) + "'" + " AND DL8_CLIDEV <= '" +  Alltrim(MV_PAR06) + "'"
	EndIf

	If !Empty(MV_PAR05) .Or. !Empty(MV_PAR07)
		cRet += Iif(Empty(cRet), "@", " AND ") + "DL8_LOJDEV >= '" +  Alltrim(MV_PAR05) + "'" + " AND DL8_LOJDEV <= '" +  Alltrim(MV_PAR07) + "'"
	EndIf
	
	If !Empty(MV_PAR08) .Or. !Empty(MV_PAR09)
		cRet += Iif(Empty(cRet), "@", " AND ") + "DL8_COD >= '" +  Alltrim(MV_PAR08) + "'" + " AND DL8_COD <= '" +  Alltrim(MV_PAR09) + "'"
	EndIf

	If !Empty(MV_PAR10) .Or. !Empty(MV_PAR11)
		cRet += Iif(Empty(cRet), "@", " AND ") + "DL8_DATPRV >= '" +  Alltrim(dToS(MV_PAR10)) + "'" + " AND DL8_DATPRV <= '" +  Alltrim(dToS(MV_PAR11)) + "'"
	EndIf

	cMult := ''
	aMult := StrtoKArr(MV_PAR12, ";")
	If !(Empty(MV_PAR12)) .AND. AllTrim(aMult[1]) <> STR0005 //Todos
		For nX := 1 to len(aMult)
			cMult += "'" + AllTrim(aMult[nX]) + "'"
			If nX < Len(aMult)
				cMult += ','
			EndIf 
		Next nX
	EndIf
	
	If !Empty(cMult)	
		cRet += Iif(Empty(cRet), "@", " AND ") + "DL8_STATUS IN (" + Alltrim(cMult) + ")"
	EndIf

Return cRet


/*/{Protheus.doc} A158F3Sta
//Cria uma tela MVC para selecionar status da demanda e retorna para a variavel c158RetSta.
@author Wander Horongoso
@since 31/01/2019
@version 12.1.17
@return return, sem retorno
/*/
Function A158F3Sta()
Local aButtons    := {}
Local aStructBrw  := {} //Estrutura da tela
Local aCamposBrw  := {} //Campos que compoem a tela
Local aColsBrw    := {} //Colunas que compoem a tela
Local cAliComp    := GetNextAlias()
Local nX          := 1
Local aTodos      := {}
Local aItem       := {}
Local a158RetSta  := {}
	
	aAdd(aCamposBrw,"DMD_STATUS")
	
	aAdd(aStructBrw, {"MARK",       "C",   2, 0})
	aAdd(aStructBrw, {"DMD_CODIGO", "C",   1, 0})
	aAdd(aStructBrw, {"DMD_STATUS", "C",  20, 0})
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| DMD_STATUS }"))
	oBrwCol:SetTitle(STR0009) //Descrição
	oBrwCol:SetSize(20)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("DMD_STATUS")
	AAdd(aColsBrw, oBrwCol)

	If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
		cAliComp := GetNextAlias()
		oTempTable := FWTemporaryTable():New("DMD")
		oTempTable:SetFields(aStructBrw)
		oTempTable:AddIndex("01",{"DMD_CODIGO"})
		oTempTable:Create()
		cAliComp := oTempTable:GetAlias()
	EndIf
	
	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	oDlgMan:SetTitle(STR0006) //"Selecione os status das demandas"
	oDlgMan:SetEscClose(.F.)
	oDlgMan:SetSize(220, 350)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()

	oFWLayer := FWLayer():New()                 //-- Container
	oFWLayer:Init(oPnlModal, .F., .F.)          //-- Inicializa container

	oFWLayer:AddLine('LIN', 100, .F.)           //-- Linha
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') //-- Coluna

	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	
	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetMenuDef("")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:AddStatusColumns({||TMSCLegDmd("DL8_STATUS", ("DMD")->DMD_CODIGO)})
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("DMD")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})

	c158RetSta := AllTrim(MV_PAR12)
	a158RetSta := StrToKArr(c158RetSta, ';')
	aItem := TMSStaDmd('DL8_STATUS', 1)

	DbSelectArea("DMD")
	
	For nX := 1 To Len(aItem)
		("DMD")->(RecLock(("DMD"), .T.))
		("DMD")->DMD_CODIGO := aItem[nX][1]
		("DMD")->DMD_STATUS := aItem[nX][2]
		
		If aScan(a158RetSta, aItem[nX][1]) > 0
			("DMD")->MARK := GetMark()
		EndIf
		
		("DMD")->(MsUnlock())
	Next

	bConfirm := {|| A158SelSta(), oDlgMan:DeActivate()}
	bCancel := {|| oDlgMan:DeActivate()}
	    
	//-- Cria botoes de operacao
	aAdd(aButtons, {"", STR0007, bConfirm, , , .T., .F.}) // 'Confirmar'
	aAdd(aButtons, {"", STR0008, bCancel, , , .T., .F.})  // 'Cancelar'
	oDlgMan:AddButtons(aButtons)		               
	
	If !Empty(MV_PAR12)
		aTodos := StrToKArr(MV_PAR12,';')
	EndIf
	
	oMarkBrw:Activate()
	While DMD->(!Eof())
		If aScan(aTodos,DMD->(DMD_CODIGO)) > 0
			oMarkBrw:MarkRec() 
		EndIf
		DMD->(dbSkip())
	EndDo
	oMarkBrw:Refresh(.T.)
	oMarkBrw:GoTop(.T.)
	
	oDlgMan:Activate()
	
	//-- Ao finalizar, elimina tabelas temporarias
	DbSelectArea('DMD')
	DbCloseArea()
	If File(cAliComp+GetDBExtension())
		FErase(cAliComp+GetDBExtension())
	EndIf
	
Return .T.

/*/{Protheus.doc} A158SelSta
//Alimenta a variavel c158RetSta com os status selecionados pelo usuario.
@author Wander Horongonso
@since 31/01/2019
@version 12.1.25
@return verdadeiro 
/*/
Function A158SelSta()
Local lTodos := .T.
	
	c158RetSta := ''
	
	DbSelectArea('DMD')
	dbGoTop()
	While !(EoF())
		If !Empty(MARK)
			c158RetSta += Trim(DMD_CODIGO) + ';'
		Else
			lTodos := .F.
		EndIf

		DbSkip()
	EndDo
	
	If lTodos
		c158RetSta := 'Todos'
	Else
		If !Empty(c158RetSta)
			c158RetSta := Substr(c158RetSta, 1, Len(c158RetSta)-1)
		EndIf
	Endif

Return .T. 