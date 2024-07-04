#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __XXS_New

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author bsobieski

@since 24/02/2016
@version 1.0
/*/

User Function FlavorEdt(lFilter)
    Local aMenuAnt := SaveMenu()

    Default lFilter := .F.

	Private oBrowseZA1

    If ! U_ZA1HasCache()
		MsgAlert("Warning! ZA1 cache is disable!")
	EndIf

    oBrowseZA1 := FwMBrowse():New()
	oBrowseZA1:SetAlias("ZA1")
	oBrowseZA1:AddLegend("ZA1_STATUS == '1'", "BROWN" , "Unchanged"       )
	oBrowseZA1:AddLegend("ZA1_STATUS == '2'", "YELLOW", "ABBY Sent"       )
	oBrowseZA1:AddLegend("ZA1_STATUS == '3'", "RED"   , "Pending Approval")
    oBrowseZA1:AddLegend("ZA1_STATUS == '4'", "BLUE"  , "Translated"      )

	If lFilter
		oBrowseZA1:SetFilterDefault(FilterZA1())
	EndIf

	oBrowseZA1:SetDescription("Translations maintenance")
	oBrowseZA1:SetMenuDef("FlavorEdt")
	oBrowseZA1:Activate()

    RestMenu(aMenuAnt)

Return

Static Function SaveMenu()
    Local aRotAnt :={}
    If Type("aRotina") =="A"
        aRotAnt := aClone(aRotina)
        aRotina := {}
    EndIf
Return aRotAnt

Static Function RestMenu(aMenuAnt)
   
    If ! Empty(aMenuAnt)
        aRotina := aMenuAnt
    EndIf

Return

Static Function FilterZA1()

	Local aParam    := {1, 1}
	Local aPergs    := {}
	Local aSavePar  := SaveMVPAR()
    Local cCondicao := "RTrim(ZA1_IDIOM) == '" + RTrim(FwRetIdiom()) + "'"

    AAdd(aPergs, {3, "Session Filter", 2, {"This Session", "All Sessions"}                               , 100, , .F.,  })
    AAdd(aPergs, {3, "Program Filter", 1, {"Current Program", "Current + Empty Programs", "All Programs"}, 100, , .F.,  })

    If ParamBox(aPergs , "Initial filters parameters", aParam, , , , , , , , .F., .T.)
        If aParam[1] == 1
            cCondicao += " .And. ZA1_THREAD == '" + StrZero(ThreadId(), 6) + "' "
        EndIf

        If aParam[2] == 1
            cCondicao += " .And. RTrim(ZA1_FUNNAM) == '" + RTrim(FunName()) + "'"
        ElseIf aParam[2] == 2
            cCondicao += " .And. (RTrim(ZA1_FUNNAM) == '" + RTrim(FunName()) + "' .Or. Empty(ZA1_FUNNAM))"
        EndIf
    EndIf

    RestMVPAR(aSavePar)

Return cCondicao

Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE "Search"                                               ACTION "PesqBrw"           OPERATION OP_PESQUISAR  ACCESS 0
    ADD OPTION aRotina TITLE "View"                                                 ACTION "VIEWDEF.FlavorEdt" OPERATION OP_VISUALIZAR ACCESS 0
    ADD OPTION aRotina TITLE "Edit"                                                 ACTION "VIEWDEF.FlavorEdt" OPERATION OP_ALTERAR    ACCESS 0
    ADD OPTION aRotina TITLE "Delete"                                               ACTION "VIEWDEF.FlavorEdt" OPERATION OP_EXCLUIR    ACCESS 0
    ADD OPTION aRotina TITLE "Reply current translation to current filtered items" 	ACTION "U_ApplyZA1()"      OPERATION OP_ALTERAR    ACCESS 0

Return aRotina

Static Function ModelDef()

	Local oModel     := MPFormModel():New("MFLAVEDT", , {|oModel| VldModel(oModel)}, {|oModel| GravaModel(oModel)})
	Local oStructZA1 := FwFormStruct(1, "ZA1", {|cCampo| cCampo != "ZA1_HIST"})

	oModel:AddFields("ZA1MASTER", , oStructZA1)
	oModel:SetPrimaryKey({"ZA1_FILIAL", "ZA1_IDIOM", "ZA1_ORIGIN", "ZA1_KEY" })

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author bsobieski

@since 24/02/2016
@version 1.0
/*/
Static Function ViewDef()

	Local oView
	Local oStructZA1 := FwFormStruct(2, "ZA1", {|cCampo| cCampo != "ZA1_HIST"})
	Local oModel     := FwLoadModel("FLAVOREDT")
	
	oStructZA1:RemoveField("ZA1_FILIAL")
	oStructZA1:RemoveField("ZA1_THREAD")
	oStructZA1:RemoveField("ZA1_MARK")
	oView := FwFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox("BOX", 100)
	oView:AddField("ZA1_VIEW" , oStructZA1, "ZA1MASTER")
	oView:SetOwnerView("ZA1_VIEW", "BOX")
	oView:AddUserButton("Check English Original"   , "CLIPS", {|oView| CheckLang("en")   })
	oView:AddUserButton("Check Spanish Original"   , "CLIPS", {|oView| CheckLang("es")   })
	oView:AddUserButton("Check Portuguese Original", "CLIPS", {|oView| CheckLang("pt-br")})
	oView:AddUserButton("Check History"            , "CLIPS", {|oView| CheckHist()       })
Return oView

Static Function VldModel(oModel)
    Local lOK := .T.

    If IsInCallStack("U_FLAVOREDT")
        If oModel:GetModel("ZA1MASTER"):GetValue("ZA1_STATUS") == "2"
            lOk := .F.
            Help(" ", 1, "String in Translation", , "The current String is being translated by ABBY.",;
                2, 0, , , , , , {"Wait for the translated string."})
        EndIf
    EndIf

Return lOk

Static Function GravaModel(oModel)

    Local cFil	  := oModel:GetModel("ZA1MASTER"):GetValue("ZA1_FILIAL")
	Local cIdiom  := oModel:GetModel("ZA1MASTER"):GetValue("ZA1_IDIOM")
	Local cOrigin := oModel:GetModel("ZA1MASTER"):GetValue("ZA1_ORIGIN")
	Local cKey	  := oModel:GetModel("ZA1MASTER"):GetValue("ZA1_KEY")
	Local cText	  := oModel:GetModel("ZA1MASTER"):GetValue("ZA1_TEXT")
	Local oModelUpd

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
        ZA1->(DbSetOrder(1))
        If ZA1->(DbSeek(cFil + cIdiom + cOrigin + cKey))
            If cText <> ZA1->ZA1_TEXT
                oModelUpd := FWLoadModel("FLAVOREDT")
                oModelUpd:SetOperation(4)
                oModelUpd:Activate()
                oModelUpd:LoadJsonData(oModel:GetJsonData())
                FwFormCommit(oModelUpd)
            EndIf
        Else
            FwFormCommit(oModel)
        EndIf
        ZA1->(Reclock("ZA1", .F.))
        ZA1->ZA1_HIST := U_ZA1Hist("Registry received from local station")
        ZA1->(MsUnlock())
    Else
        If IsInCallStack("U_FLAVOREDT")
            FwFormCommit(oModel)
            If ! Empty(ZA1->ZA1_MANUAL)
                ZA1->(Reclock("ZA1", .F.))
                ZA1->ZA1_STATUS := "3"
                ZA1->ZA1_SENT   := " "
                ZA1->ZA1_APLICA := " "
                ZA1->ZA1_HIST := U_ZA1Hist("Suggested ")
                ZA1->(MsUnlock())
            EndIf
        EndIf
    EndIf

Return .T.

Static Function CheckHist()

    Local aHist    := {}
    Local aData    := {}
    Local aColumns := {}
    Local aFields  := {"Time Stamp", "Status", "Message"}
    Local nCol     := 1
    Local oCol
    Local oDlgHist
    Local oBrwHist

    aHist := StrTokArr(ZA1->ZA1_HIST, CRLF)
    AEval(aHist, {|cLine| AAdd(aData, StrTokArr(cLine, "|"))})

    DEFINE MSDIALOG oDlgHist TITLE "Registry History" FROM 0, 0 TO 600, 600 PIXEL

    oBrwHist := FWBrowse():New(oDlgHist)
	oBrwHist:SetDataArray(.T.)
	oBrwHist:SetDescription("Registry History")

	For nCol := 1 To Len(aFields)
		oCol := FWBrwColumn():New()
		oCol:SetTitle(aFields[nCol])
		oCol:SetData(&("{|oBrowse| oBrowse:oData:aArray[oBrowse:At()][" + Str(nCol) + "]}"))
		AAdd(aColumns, oCol)
	Next

    oBrwHist:SetColumns(aColumns)
	oBrwHist:SetArray(aData)

	oBrwHist:Activate()

    ACTIVATE MSDIALOG oDlgHist CENTERED

Return

Static Function CheckLang(cIdiom)

	Local oModel    := FwModelActive()
	Local oModelZA1 := oModel:GetModel("ZA1MASTER")
	Local cString   := oModelZA1:GetValue("ZA1_TEXT")
	Local cOrigin   := oModelZA1:GetValue("ZA1_ORIGIN")
	Local cKey1	    := RTrim(oModelZA1:GetValue("ZA1_KEY1"))
	Local cKey2	    := RTrim(oModelZA1:GetValue("ZA1_KEY2"))
	Local cKey3	    := RTrim(oModelZA1:GetValue("ZA1_KEY3"))
	Local cKey4	    := RTrim(oModelZA1:GetValue("ZA1_KEY4"))
	Local cKey5	    := RTrim(oModelZA1:GetValue("ZA1_KEY5"))
	Local cKey	    := RTrim(oModelZA1:GetValue("ZA1_KEY"))
	Local cRet	    := ""
	Local cIni	    := "-------Original Data Start-------" + CRLF
	Local cFim	    := "-------Original Data End---------" + CRLF
	Local cIdTmp    := ""
    Local nSize     := 0

    cIdTmp := FwRetIdiom()
    FwSetIdiom(cIdiom)
    Do Case
        Case cOrigin == "S"
            FwSetIdiom(cIdiom)
            cString := FwI18NLang(cKey1, "STR" + cKey2, Val(cKey2))

            FwSetIdiom("pt-br")
            nSize := Max(Len(FwI18NLang(cKey1, "STR" + cKey2, Val(cKey2))), nSize)
            FwSetIdiom("es")
            nSize := Max(Len(FwI18NLang(cKey1, "STR" + cKey2, Val(cKey2))), nSize)
            FwSetIdiom("en")
            nSize := Max(Len(FwI18NLang(cKey1, "STR" + cKey2, Val(cKey2))), nSize)

            cRet += "Recommended max size is " + StrZero(nSize, 2) + "!!!" + CRLF
            cRet += "Original text: " + cString + CRLF
        Case cOrigin == "2" .And. cKey2 == "X2_NOME"
            SX2->(DbSetOrder(1))
            SX2->(DbSeek(cKey1))
            cRet += "Max size is " + StrZero(Len(SX2->X2_NOME), 2) + "!!!" + CRLF
            cRet += "Original text: " + X2Nome() + CRLF
        Case cOrigin == "3"
            SX3->(DbSetOrder(2))
            SX3->(DbSeek(cKey1))

            DO Case
                Case RTrim(cKey2) == "X3_CBOX"
                    cRet += "Max size is "        + StrZero(Len(SX3->X3_CBOX), 3) + "!!!" + CRLF
                    cRet += "Original text: "     + RTrim(X3CBox())    + CRLF
                    cRet += "Field Title: "       + RTrim(X3Titulo())  + CRLF
                    cRet += "Field Description: " + RTrim(X3Descric()) + CRLF
                CASE RTrim(cKey2) == "X3_TITULO"
                    cRet += "Max size is "       + StrZero(Len(SX3->X3_TITULO), 3) + "!!!" + CRLF
                    cRet += "Original text: "    + RTrim(X3Titulo())  + CRLF
                    cRet += "Field Description:" + RTrim(X3Descric()) + CRLF
                CASE RTrim(cKey2) == "X3_DESCRIC"
                    cRet += "Max size is "       + StrZero(Len(SX3->X3_DESCRIC), 3) + "!!!" + CRLF
                    cRet += "Original text: "    + RTrim(X3Descric()) + CRLF
            EndCase

            cRet += "Field Help:" + RTrim(Ap5GetHelp(cKey1)) + CRLF

        Case cOrigin == "5"
            SX5->(DbSetOrder(1))
            SX5->(DbSeek(XFilial() + RTrim(cKey1) + RTrim(cKey2)))
            cRet += "Max size is "    + StrZero(Len(SX5->X5_DESCRI), 3) + "!!!" + CRLF
            cRet += "Original text: " + X5Descri() + CRLF
            FwSetIdiom(cIdTmp)
        Case cOrigin == "M"
            cRet := "Original text : " + FwFlavMenu("", cIdiom, cKey1, cKey2, cKey3, cKey4, cKey5)
        Case cOrigin == "H"
            cRet := "Original text : " + FwFlavHelp("", cIdiom, cKey1, cKey2)
    Case cOrigin	==	"1"
            SX1->(DbSetOrder(1))
            SX1->(DbSeek(PadR(cKey1, Len(SX1->X1_GRUPO)) + cKey3))

            If cKey4 == "X1_PERGUNT"
                cRet := "Original text : " + RTrim(X1Pergunt()) + CRLF
                cRet += "Size limit: "     + StrZero(Len(SX1->X1_PERGUNT), 3) + CRLF
            Else
                cRet := "Original text : "

                Do Case
                    Case cKey4 == "X1_DEF01"
                        cRet += RTrim(X1Def01()) + CRLF
                    Case cKey4 == "X1_DEF02"
                        cRet += RTrim(X1Def02()) + CRLF
                    Case cKey4 == "X1_DEF03"
                        cRet += RTrim(X1Def03()) + CRLF
                    Case cKey4 == "X1_DEF04"
                        cRet += RTrim(X1Def04()) + CRLF
                    Case cKey4 == "X1_DEF05"
                        cRet += RTrim(X1Def05()) + CRLF
                EndCase

                cRet += "Size limit: " + StrZero(Len(SX1->X1_DEF01), 3) + CRLF
            Endif
            cRet += "Question group " + RTrim(SX1->X1_GRUPO) + " order " + SX1->X1_ORDEM + CRLF

            cHelp := Ap5GetHelp("." + RTrim(SX1->X1_GRUPO) + SX1->X1_ORDEM + ".")
            
            If !Empty(cHelp)
                cRet += "Help for question : " + cHelp + CRLF
            Endif
       
        Case cOrigin == "6"
            SX6->(DbSetOrder(1))
            SX6->(DbSeek(xFilial() + RTrim(cKey1)))
            cRet := "Original text : " + RTrim(X6Desc1()) + CRLF
            cRet += "Size limit: "     + StrZero(Len(SX6->X6_DESC1), 3) + CRLF
            cRet += "Full parameter description: " + CRLF
            cRet += "     " + RTrim(X6Descric()) + CRLF
            cRet += "     " + RTrim(X6Desc1()) + CRLF
            cRet += "     " + RTrim(X6Desc2()) + CRLF
        Case cORIGIN =="G"
            SXG->(DbSetOrder(1))
            SXG->(DbSeek(RTrim(cKey1)))
            cRet := "Original text : " + XGDescri() + CRLF
            cRet += "Size limit: "     + StrZero(Len(SXG->XG_DESCRI), 3) + CRLF
        Case cOrigin == "A"
            SX2->(DbSetOrder(1))
            SX2->(MsSeek(cKey1))
            SXA->(DbSetOrder(1))
            SXA->(MsSeek(RTrim(cKey1) + cKey3))
            cRet := "Original text : "     + RTrim(XADescric()) + CRLF
            cRet += "Size limit: "         + StrZero(Len(SXA->XA_DESCRIC), 3) + CRLF
            cRet += "Folders for table : " + RTrim(X2Nome()) + "(" + SX2->X2_CHAVE + ")" + CRLF
        Case cOrigin == "B"
            SXB->(DbSetOrder(1))
            SXB->(MsSeek(PadR(cKey1, Len(XB_ALIAS)) + PadR(cKey2, Len(XB_TIPO)) + PadR(cKey3, Len(XB_SEQ)) + PadR(cKey4, Len(XB_COLUNA))))
            cRet := "Original text : " + RTrim(XBDescri()) + CRLF
            cRet += "Size limit: "     + StrZero(Len(SXB->XB_DESCRI), 3) + CRLF
        Otherwise
            MsgStop("NOT IMPLEMENTED YET")
    EndCase

    FwSetIdiom(cIdTmp)

	If !Empty(cRet)
        If oModel:GetOperation() <> MODEL_OPERATION_UPDATE
            MsgInfo(cIni + cRet + cFim + cString)
        Else
            oModelZA1:SetValue("ZA1_MANUAL", cIni + cRet + cFim + cString)
        EndIf
    EndIf
Return .T.

User Function ApplyZA1()
	
    Local cTextOri  := RTrim(ZA1->ZA1_TEXT)
	Local cTextDest := ZA1->ZA1_MANUAL
	Local cOrigin   := ZA1->ZA1_ORIGIN
	Local cIdiom    := ZA1->ZA1_IDIOM
	Local cKey2	    := ZA1->ZA1_KEY2
	Local cKey4	    := ZA1->ZA1_KEY4
    Local aAreaZA1  := ZA1->(GetArea("ZA1"))
	Local nRecno    := ZA1->(Recno())

	Local nContaS   := 0
	Local nContaN   := 0

	If ZA1->ZA1_STATUS =="1"
		MsgAlert("This string has not changed, nothing to be done", "Warning")
        Return
    EndIf

    If Empty(ZA1->ZA1_NEWTEX) .And. Empty(ZA1->ZA1_MANUAL)
    	MsgAlert("This string has not been translated, nothing to be done", "Warning")
        Return
    EndIf

    If Empty(cTextDest)
        cTextDest := ZA1->ZA1_NEWTEX
    EndIf

    If ! Aviso("Warning", "Current translation correction will be applied to all itens fitered in this screen"       + CRLF + ;
                          "Data origin will be respected to avoid wrong sizes adjustments, except for those labels " + CRLF + ;
                          "that come from sources. In source code example, correction will be applied to all items.", {"Confirm", "Cancel"}) == 1
        Return
    EndIf

    cFiltro := oBrowseZA1:FwFilter():GetExprADVPL()

    ZA1->(DbSetOrder(2))
    ZA1->(DbSeek(XFilial("ZA1") + cIdiom + cTextOri))
    While ZA1->(! Eof() .And. ZA1_FILIAL == XFilial("ZA1") .And. ZA1_IDIOM == cIdiom .And. RTrim(ZA1_TEXT) == cTextOri )

        If nRecno == ZA1->(Recno())
            ZA1->(DbSkip())
            Loop
        EndIf

        If ZA1->ZA1_STATUS =="2"
            ZA1->(DbSkip())
            Loop
        EndIf

        If ! (cOrigin $ "13") .Or. ;
             (cOrigin =="3"   .And. ZA1->ZA1_KEY2 == cKey2) .Or. ;
             (cOrigin == "1"  .And. SubStr(ZA1->ZA1_KEY4, 1, 5) == SubStr(cKey4, 1, 5))

            If Empty(cFiltro) .Or. &cFiltro.
                nContaS ++
                ZA1->(Reclock("ZA1", .F.))
                    ZA1->ZA1_STATUS := "3"
                    ZA1->ZA1_MANUAL := cTextDest
                    ZA1->ZA1_HIST   := U_ZA1Hist("Batch Suggestion ")
                ZA1->(MsUnlock())
            Else
                nContaN ++
            EndIf
        EndIf
        ZA1->(DbSkip())
    Enddo

    ZA1->(RestArea(aAreaZA1))
    ZA1->(DbGoto(nRecno))

    MsgInfo(StrZero(nContaS, 4) + " records have been updated" + CRLF + ;
    IIf(nContaN > 0, StrZero(nContaN, 4) + " matches have been found without filter applied, you may want to clean filters and run again...", ""), "Successful")

Return

Static Function SaveMVPAR()

    Local aSavePar := {;
                        MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, ;
                        MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, ;
                        MV_PAR09, MV_PAR10, MV_PAR11, MV_PAR12, ;
                        MV_PAR13, MV_PAR14, MV_PAR15, MV_PAR16;
                     }

Return aSavePar

Static Function RestMVPAR(aSavePar)

    Local nPar := 0

    For nPar := 1 To Len(aSavePar)
        &("MV_PAR" + StrZero(nPar, 2)) := aSavePar[nPar]
    Next

Return
// Russia_R5
