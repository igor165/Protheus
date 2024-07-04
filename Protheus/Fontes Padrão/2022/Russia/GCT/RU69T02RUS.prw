#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU69T01RUS.CH"


/*{Protheus.doc} RU69T02RUS
@author Konstantin Cherchik
@since 10/31/2018
@version P12.1.23
@return 
@type function
@description Legal Contract
*/
Function RU69T02RUS(nOper)

FWExecView(STR0006, "RU69T02", nOper, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, /* [ oModel ] */)

Return

Static Function ModelDef()
Local oModel        as Object
Local oStruHead     as Object
Local oStruGrid     as Object

oStruHead   := FWFormStruct(1, "F5T", /*bSX3*/)
oStruGrid   := FWFormStruct(1, "F5T", /*bSX3*/)

oModel      := MPFormModel():New("RU69T02", /* Pre-valid */, /* Pos-Valid */, /* Commit */)
oModel:AddFields("F5TMASTER", /*cOwner*/, oStruHead)
oModel:AddGrid("F5TDETAIL", "F5TMASTER", oStruGrid, /* bLinePre */, {|oModelGrid, nOper| GridPosValid(oModelGrid, nOper)}, /* bPre */, /* */, /* bLoadGrid */)

oModel:SetDescription(STR0006) // "Legal Contracts"
oModel:SetRelation("F5TDETAIL", {{"F5T_FILIAL","xFilial('F5T')"}, {"F5T_ENTITY", "F5T_ENTITY"}, {"F5T_PARUID", "F5T_PARUID"}}, F5T->(IndexKey(2)))    //F5T_FILIAL+F5T_ENTITY+F5T_PARUID+DTOS(F5T_DTINI)

Return oModel

Static Function ViewDef()
Local oModel        as Object
Local oView         as Object
Local oStruHead     as Object
Local oStruGrid     as Object

oModel      := FWLoadModel("RU69T02")
oStruHead   := FWFormStruct(2, "F5T", {|x| AllTrim(x) $ "F5T_DTINI|F5T_DTEND"})
oStruGrid   := FWFormStruct(2, "F5T", {|x| AllTrim(x) $ "F5T_DTINI|F5T_DTEND|F5T_DESC"})

oView       := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_HEAD", oStruHead, "F5TMASTER")
oView:AddGrid("VIEW_GRID", oStruGrid, "F5TDETAIL")
oView:CreateHorizontalBox("MAIN", 000)
oView:CreateHorizontalBox("GRID", 100)
oView:SetOwnerView("VIEW_HEAD", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID") 
oView:SetNoInsertLine("VIEW_GRID")
oView:SetNoDeletLine("VIEW_GRID")

oView:SetViewProperty("VIEW_GRID", "GRIDDOUBLECLICK", {{|oView, cField, nLineGrid, nLineModel| GridDblClick(oView, cField, nLineGrid, nLineModel)}})

Return oView

Static Function GridDblClick(oView as Object, cField as Char, nLineGrid as Numeric, nLineModel as Numeric)
Local cEntity       as Char
Local cParUid       as Char
Local dDtIni        as Date
Local dOldDate      as Date
Local oModelGrid    as Object

oModelGrid  := oView:GetModel()
cEntity     := oModelGrid:GetValue("F5T_ENTITY")
cParUid     := oModelGrid:GetValue("F5T_PARUID")
dDtIni      := oModelGrid:GetValue("F5T_DTINI")
dOldDate    := dDataBase

(cEntity)->(dbSetOrder(1))
If (cEntity)->(dbSeek(xFilial(cEntity) + cParUid))
    dDataBase   := dDtIni
    FWExecView(STR0001, "RU69T01", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, /* [ oModel ] */)
    dDataBase   := dOldDate
Else
    Help("",1,"RU69T02NPDBF",,STR0014,1,0)
EndIf

Return Nil

Static Function GridPosValid(oModelGrid as Object, nOper as Numeric)
Local nX        as Numeric
Local nY        as Numeric
Local nLine     as Numeric
Local dDtIni    as Date
Local dDtEnd    as Date
Local lRet      as Logical
Local aSpans    as Array

Default lRet    := .T.
Default aSpans  := {}

For nX := 1 To oModelGrid:Length()
    If ! oModelGrid:IsDeleted(nX)
        dDtIni      := oModelGrid:GetValue("F5T_DTINI", nX)
        dDtEnd      := oModelGrid:GetValue("F5T_DTEND", nX)
        aAdd(aSpans, {dDtIni, dDtEnd, nX})
    EndIf
Next nX

For nX := 1 To Len(aSpans)
    dDtIni  := aSpans[nX, 01]
    dDtEnd  := aSpans[nX, 02]
    nLine   := aSpans[nX, 03]
    For nY := 1 To Len(aSpans)
        If nX <> nY
            If dDtIni >= aSpans[nY, 01] .And. dDtIni <= aSpans[nY, 02]
                lRet    := .F.
            ElseIf dDtEnd >= aSpans[nY, 01] .And. dDtEnd <= aSpans[nY, 02]
                lRet    := .F.
            EndIf

            If ! lRet
                oModelGrid:GoLine(nX)
                Help("",1,"RU69T02CONF",,STR0015,1,0)
                Exit
            EndIf
        EndIf
    Next nY
    If ! lRet
        Exit
    EndIf
Next nX

Return lRet

Function RU69T0201_GetChild( cEntity as char, cChildEnt as char, cParUid as char, dDateSearch as Date, lSilent as Logical ) 
Local cChildUid     as Char 
Local cQuery        as Char 
Local cAliasTmp     as Char 

Default cChildUid   := ""
Default dDateSearch := dDataBase
Default lSilent     := .F.

cQuery  := " select f5t_dtini, f5t.r_e_c_n_o_ as f5trecno, child.r_e_c_n_o_ as childrec, "+cChildEnt+"_uid as childuid "
cQuery  += "   from "+RetSqlName("F5T")+" f5t "
cQuery  += "   join "+RetSqlName(cChildEnt)+" child on "+cChildEnt+"_uid = f5t_chiuid "
cQuery  += "  where f5t.d_e_l_e_t_ = ' ' "
cQuery  += "    and child.d_e_l_e_t_ = ' ' "
cQuery  += "    and f5t_filial = '"+xFilial("F5T")+"' "
cQuery  += "    and "+cChildEnt+"_filial = '"+xFilial(cChildEnt)+"' "
cQuery  += "    and f5t_entity = '"+cEntity+"' "
cQuery  += "    and f5t_paruid = '"+cParUid+"' "
cQuery  += "    and f5t_dtini <= '"+DToS(dDateSearch)+"' "
cQuery  += " order by 1 desc "
cAliasTmp   := RU01GETALS(cQuery)

If (cAliasTmp)->(EOF())
    If ! lSilent
        Help(" ",1,"RU69T02RUSNAN",,STR0012,1,0)
    EndIf
Else
    F5T->(dbGoTo((cAliasTmp)->F5TRECNO))
    (cChildEnt)->(dbGoTo((cAliasTmp)->CHILDREC))
    cChildUid   := (cAliasTmp)->CHILDUID
EndIf

(cAliasTmp)->(dbCloseArea())

Return cChildUid

Function RU69T0202_CreateTimeSpan( cEntity as char, cChildEnt as char, cParUid as char, cChildUid as char, dParIni as date, dParEnd as date) 
Local nX                as Numeric
Local nRecDelOld        as Numeric
Local nRecCreated       as Numeric
Local lRet              as Logical
Local dIni              as Date
Local dEnd              as Date
Local dOldIni           as Date
Local dOldEnd           as Date
Local dRegEnd           as Date
Local cOldChildUid      as Char
Local cNewId            as Char
Local cQuery            as Char
Local cAliasTmp         as Char
Local aRegister         as Array
Local aChildInfo        as Array
Local aChildStruct      as Array
Local xValue

Default dParIni := dDataBase
Default dParEnd := &(GetSX3Cache("F5T_DTEND ", "X3_RELACAO"))

lRet            := .T.
lDelOld         := .T.
nRecDelOld      := 0
aChildInfo      := {}
cOldChildUid    := RU69T0201_GetChild(cEntity, cChildEnt, cParUid, Nil, .T.)

cQuery          := " select r_e_c_n_o_ as f5trecno "
cQuery          += "   from " + RetSqlName("F5T")
cQuery          += "  where d_e_l_e_t_ = ' ' "
cQuery          += "    and f5t_filial = '"+xFilial("F5T")+"' "
cQuery          += "    and f5t_entity = '"+cEntity+"' "
cQuery          += "    and f5t_paruid = '"+cParUid+"' "
cQuery          += "    and ( "
cQuery          += "            (f5t_dtini > '"+DToS(dParIni)+"' and f5t_dtend < '"+DToS(dParEnd)+"') "
cQuery          += "         or (f5t_dtini = '"+DToS(dParIni)+"' and f5t_dtend <= '"+DToS(dParEnd)+"') "
cQuery          += "         or (f5t_dtend = '"+DToS(dParEnd)+"' and f5t_dtini >= '"+DToS(dParIni)+"') "
cQuery          += "        ) "
cAliasTmp       := RU01GETALS(cQuery)
While (cAliasTmp)->(! EOF())
    F5T->(dbGoTo((cAliasTmp)->F5TRECNO))
    RecLock("F5T", .F.)
    F5T->(dbDelete())   // Replace time span intersections
    MsUnlock()
    (cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

cQuery          := " select r_e_c_n_o_ as f5trecno "
cQuery          += "   from " + RetSqlName("F5T")
cQuery          += "  where d_e_l_e_t_ = ' ' "
cQuery          += "    and f5t_filial = '"+xFilial("F5T")+"' "
cQuery          += "    and f5t_entity = '"+cEntity+"' "
cQuery          += "    and f5t_paruid = '"+cParUid+"' "
cQuery          += "    and '"+DToS(dParEnd)+"' between f5t_dtini and f5t_dtend "
cAliasTmp       := RU01GETALS(cQuery)
While (cAliasTmp)->(! EOF())
    F5T->(dbGoTo((cAliasTmp)->F5TRECNO))
    RecLock("F5T", .F.)
    F5T->F5T_DTINI := dParEnd + 1
    MsUnlock()
    (cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

cQuery          := " select r_e_c_n_o_ as f5trecno "
cQuery          += "   from " + RetSqlName("F5T")
cQuery          += "  where d_e_l_e_t_ = ' ' "
cQuery          += "    and f5t_filial = '"+xFilial("F5T")+"' "
cQuery          += "    and f5t_entity = '"+cEntity+"' "
cQuery          += "    and f5t_paruid = '"+cParUid+"' "
cQuery          += "    and '"+DToS(dParIni)+"' between f5t_dtini and f5t_dtend "
cAliasTmp       := RU01GETALS(cQuery)
While (cAliasTmp)->(! EOF())
    F5T->(dbGoTo((cAliasTmp)->F5TRECNO))
    RecLock("F5T", .F.)
    F5T->F5T_DTEND := dParIni - 1
    MsUnlock()
    (cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

If ! Empty(cOldChildUid)
    cChildUid   := RU01UUIDV4()
    RecLock(cChildEnt, .F.)
    &(cChildEnt+"->"+cChildEnt+"_UID := '"+cChildUid+"'")
    MsUnlock()

    aChildStruct:= (cChildEnt)->(dbStruct())
    For nX := 1 To Len(aChildStruct)
        If AllTrim(aChildStruct[nX, 01]) == cChildEnt + "_UID"
            aAdd(aChildInfo, cOldChildUid)
        Else
            aAdd(aChildInfo, &(cChildEnt+"->"+aChildStruct[nX, 01]))
        EndIf
    Next nX

    RecLock(cChildEnt, .T.)
    For nX := 1 To Len(aChildInfo)
        xValue      := aChildInfo[nX]
        If ValType(xValue) == "N"
            xValue  := AllTrim(Str(xValue))
        ElseIf ValType(xValue) == "D"
            xValue  := "STOD('"+DToS(xValue)+"')"
        ElseIf ValType(xValue) == "L"
            xValue  := IIf(xValue, ".T.", ".F.")
        Else
            xValue  := "'"+xValue+"'"
        EndIf
        &(cChildEnt+"->"+aChildStruct[nX, 01]+" := "+xValue)
    Next nX
    MsUnlock()
EndIf

RecLock("F5T", .T.)
F5T->F5T_FILIAL := xFilial("F5T")
F5T->F5T_UID    := RU01UUIDV4()
F5T->F5T_ENTITY := cEntity
F5T->F5T_PARUID := cParUid
F5T->F5T_DTINI  := dParIni
F5T->F5T_DTEND  := dParEnd
F5T->F5T_CHIUID := cChildUid
MsUnlock()

Return cChildUid
