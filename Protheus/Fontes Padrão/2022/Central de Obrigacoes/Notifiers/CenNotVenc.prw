#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

#Define OBRI_SIP "1"
#Define OBRI_SIB "2"
#Define OBRI_DIOPS "3"
#Define OBRI_DMED "4"
#Define OBRI_MONIT "5"

Class CenNotVenc from CenEveIns

    Data cMensagem
    Data nDia
    Data nAno
    Data nMes
    Data cDateIni
    Data cDateFim
    Data dHoje
    Data cTipoObri
    Data cObriDesc

    Method New() Constructor
    Method Execute()
    Method avisaVenci()
    Method GetVenSIB()
    Method MapDate()
    Method GetVenSIP()
    Method SetTipoObri()
    Method GetDateStr()
    Method GetVencimento()
    Method GetDescri()
    Method GetVenDIOPS()
    Method GetVenDMED()

EndClass

/*/{Protheus.doc}
    Classe que notifica vencimentos de obigações da central de obrigações.
    @type  Class
    @author lima.everton
    @since 20200821
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=566463653
/*/
Method New() Class CenNotVenc
    _Super:New()
    self:cMensagem := ""
    self:SetEventID("073")
    self:LvInfo()
    self:EnvAll()
    self:MapDate()
Return self

Method Execute() Class CenNotVenc
    self:avisaVenci()
Return .T.

Method avisaVenci() Class CenNotVenc

    Local oCenCltObri := CenCltObri():New()
    Local oCenCltComp := CenCltComp():New()
    Local oCenCltCrit := CenCltCrit():New()

    Local oCenObri := nil
    Local oCenComp := nil

    oCenCltObri:setValue("activeInactive","1") //Ativo

    oCenCltObri:buscar()
    While (oCenCltObri:hasNext())

        oCenObri := oCenCltObri:getNext()
        If oCenObri:getValue("activeInactive") == "1"

            oCenCltComp:setValue("providerRegister", oCenObri:getValue("operatorRecord"))
            oCenCltComp:setValue("requirementCode", oCenObri:getValue("requirementCode"))
            oCenCltComp:setValue("obligationType", oCenObri:getValue("obligationType"))
            oCenCltComp:setValue("commitmentCode", StrZero(self:nMes,3))
            oCenCltComp:setValue("referenceYear", AllTrim(Str(self:nAno)))
            oCenCltComp:buscar()

            While (oCenCltComp:hasNext())

                oCenComp := oCenCltComp:getNext()
                self:SetTipoObri(oCenCltComp:getValue("obligationType"))

                //Diferente de Finalizado (6) | data atual igual ou maior dias marcados para avisos | Data atual menos que vencimento
                If oCenComp:getValue("status") <> "6" .AND. self:dHoje >= self:GetVencimento() - oCenComp:getValue("dueDateNotification") .AND. self:dHoje <= self:GetVencimento()
                    self:SetTitulo("Aviso de vencimento "+ self:GetDescri() + " | Operadora " + oCenComp:getValue("operatorRecord") +".")
                    self:cMensagem := ""
                    self:cMensagem := "A obrigação "+ self:GetDescri() + " vence em " + Dtoc(self:GetVencimento()) + "."
                    self:LvWarning()
                    self:SetMensagem(self:cMensagem)
                    self:Send()
                EndIf
                //oCenComp:Destroy()
            EndDo
            oCenCltComp:getDao():fechaQuery()
        EndIf
        //oCenObri:Destroy()
    EndDo

    oCenCltObri:Destroy()
    oCenCltComp:Destroy()
    oCenCltCrit:Destroy()

Return .T.

Method MapDate() Class CenNotVenc
    self:dHoje := DATE()
    self:nDia := DAY(self:dHoje)
    self:nAno := YEAR(self:dHoje)
    self:nMes := MONTH(self:dHoje)
Return

Method GetDateStr() Class CenNotVenc
Return AllTrim(StrZero(self:nMes,2))+"/"+AllTrim(Str(self:nAno))

Method SetTipoObri(cTipoObri) Class CenNotVenc
    self:cTipoObri := cTipoObri
Return

Method GetVencimento() Class CenNotVenc
    Local dDate := Date()
    If self:cTipoObri == OBRI_SIB
        dDate := self:GetVenSIB()
    ElseIf self:cTipoObri == OBRI_SIP
        dDate := self:GetVenSIP()
    ElseIf self:cTipoObri == OBRI_DIOPS
        dDate := self:GetVenDIOPS()
    EndIf
Return dDate

Method GetVenSIB() Class CenNotVenc
    Local nMesConf := 0
    nMesConf := self:nMes + 1
    If nMesConf > 12
        nMesConf := 1
        self:nAno++
    EndIf
Return STOD(AllTrim(Str(self:nAno))+AllTrim(StrZero(nMesConf,2))+"05")

Method GetDescri() Class CenNotVenc
    Local cDescricao := "Obrigacao"
    If self:cTipoObri == OBRI_SIB
        cDescricao :=  "SIB"
    ElseIf self:cTipoObri == OBRI_SIP
        cDescricao := "SIP"
    ElseIf self:cTipoObri == OBRI_DIOPS
        cDescricao := "DIOPS"
    ElseIf self:cTipoObri == OBRI_DMED
        cDescricao := "DMED"
    ElseIf self:cTipoObri == OBRI_MONIT
        cDescricao := "Monitoramento."
    EndIf
Return cDescricao

Method GetVenSIP() Class CenNotVenc
    Local dDate := Date()
    If self:nMes > 2 .AND. self:nMes <= 5 //1 tri
        dDate := STOD(AllTrim(Str(self:nAno))+"0531")
    ElseIf self:nMes > 5 .AND. self:nMes <= 8 //2 tri
        dDate := STOD(AllTrim(Str(self:nAno))+"0831")
    ElseIf  self:nMes > 8 .AND. self:nMes <= 11 //3 tri
        dDate := STOD(AllTrim(Str(self:nAno))+"1130")
    ElseIf self:nMes > 11 .OR. self:nMes <= 2
        If self:nMes > 11
            self:nAno++
        EndIf
        dDate := STOD(AllTrim(Str(self:nAno))+"0228")
    EndIf
Return dDate

Method GetVenDIOPS() Class CenNotVenc
    Local dDate := Date()
    If self:nMes > 2 .AND. self:nMes <= 4 // 4 tri ano anterior
        dDate := STOD(AllTrim(Str(self:nAno))+"0430")
    ElseIf self:nMes > 4 .AND. self:nMes <= 5 // 1 tri
        dDate := STOD(AllTrim(Str(self:nAno))+"0531")
    ElseIf  self:nMes > 5 .AND. self:nMes <= 8 //2 tri
        dDate := STOD(AllTrim(Str(self:nAno))+"0815")
    ElseIf self:nMes > 8 .OR. self:nMes <= 11 // 3 Tri
        dDate := STOD(AllTrim(Str(self:nAno))+"1115")
    EndIf
Return dDate

Method GetVenDMED() Class CenNotVenc
    If self:nMes == 12
        self:nAno++
    EndIf
Return STOD(AllTrim(Str(self:nAno))+"0228")