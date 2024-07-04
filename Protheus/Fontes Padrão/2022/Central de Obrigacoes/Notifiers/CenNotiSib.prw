#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#IFDEF lLinux
    #define CRLF Chr(13) + Chr(10)
#ELSE
    #define CRLF Chr(10)
#ENDIF

Class CenNotiSib from CenEveIns

    Data cMensagem
    Data nDia
    Data nAno
    Data nMes
    Data cDateIni
    Data cDateFim
    Data dHoje

    Method New() Constructor
    Method Execute()
    Method qtdCritSIB()
    Method Mapdate()
    Method GetDateStr()
    Method GetVencimento()

EndClass

/*/{Protheus.doc}
    Classe que notifica um resumo da obrigação SIB
    @type  Class
    @author lima.everton
    @since 20200821
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=565739667
/*/
Method New() Class CenNotiSib
    _Super:New()
    self:cMensagem := ""
    self:SetEventID("072")
    self:LvInfo()
    self:EnvAll()
    self:MapDate()
Return self

Method Execute() Class CenNotiSib
    self:qtdCritSIB()
Return .T.

Method qtdCritSIB() Class CenNotiSib

    Local oCenCltObri := CenCltObri():New()
    Local oCenCltCrit := CenCltCrit():New()
    Local oCenCltComp := nil
    Local oCenCltB3X := nil
    Local oCenObri := nil
    Local oCenComp := nil
    Local nQuantidade := 0
    Local aMovQtd := {0,0,0,0}

    oCenCltObri:setValue("obligationType","2") //SIB
    oCenCltObri:setValue("activeInactive","1") //Ativo

    oCenCltObri:buscar()
    While (oCenCltObri:hasNext())

        oCenObri := oCenCltObri:getNext()
        If oCenObri:getValue("activeInactive") == "1"

            oCenCltComp := CenCltComp():New()

            oCenCltComp:setValue("providerRegister", oCenObri:getValue("operatorRecord"))
            oCenCltComp:setValue("requirementCode", oCenObri:getValue("requirementCode"))
            oCenCltComp:setValue("obligationType", oCenObri:getValue("obligationType"))
            oCenCltComp:setValue("commitmentCode", StrZero(self:nMes,3))
            oCenCltComp:setValue("referenceYear", AllTrim(Str(self:nAno)))
            oCenCltComp:buscar()

            While (oCenCltComp:hasNext())
                oCenComp := oCenCltComp:getNext()

                //Diferente de Finalizado (6) | data atual igual ou maior dias marcados para avisos | Data atual menos que vencimento
                If oCenComp:getValue("status") <> "6" .AND. self:dHoje >= self:GetVencimento() - oCenComp:getValue("dueDateNotification") .AND. self:dHoje <= self:GetVencimento()

                    oCenCltB3X := CenCltB3X():New()
                    oCenCltCrit := CenCltCrit():New()

                    oCenCltCrit:setValue("operatorRecord", oCenComp:getValue("operatorRecord"))
                    oCenCltCrit:setValue("requirementCode", oCenComp:getValue("obligationCode"))
                    oCenCltCrit:setValue("commitReferenceYear", oCenComp:getValue("referenceYear"))
                    oCenCltCrit:setValue("commitmentCode",  oCenComp:getValue("commitmentCode"))

                    nQuantidade := oCenCltCrit:bscQtdCrit()
                    aMovQtd := oCenCltB3X:bscMovCount(self:cDateIni, self:cDateFim, oCenComp:getValue("operatorRecord"))

                    self:SetTitulo("SIB - Resumo do periodo "+ self:GetDateStr() +" | Operadora " + oCenComp:getValue("operatorRecord") +".")

                    self:cMensagem := ""
                    self:cMensagem += Alltrim(str(nQuantidade)) + " Criticas." + CRLF
                    self:cMensagem += Alltrim(str(aMovQtd[1])) + " movimentos de Inclusões." + CRLF
                    self:cMensagem += Alltrim(str(aMovQtd[2])) + " movimentos de Retificações." + CRLF
                    self:cMensagem += Alltrim(str(aMovQtd[3])) + " movimentos de Mudanças contratuais." + CRLF
                    self:cMensagem += Alltrim(str(aMovQtd[4])) + " movimentos de Cancelamentos."

                    self:SetMensagem(self:cMensagem)
                    self:Send()

                    oCenCltB3X:Destroy()
                    oCenCltCrit:Destroy()

                EndIf
                oCenComp:Destroy()
            EndDo
            oCenCltComp:Destroy()
        EndIf
        oCenObri:Destroy()
    End

    oCenCltObri:Destroy()

Return .T.

Method MapDate() Class CenNotiSib
    self:dHoje := DATE()
    self:nDia := DAY(self:dHoje)
    self:nAno := YEAR(self:dHoje)
    self:nMes := MONTH(self:dHoje)
    self:cDateIni := AllTrim(Str(self:nAno))+AllTrim(StrZero(self:nMes,2))+"01"
    self:cDateFim := AllTrim(Str(self:nAno))+AllTrim(StrZero(self:nMes,2))+"31"
Return

Method GetDateStr() Class CenNotiSib
Return AllTrim(StrZero(self:nMes,2))+"/"+AllTrim(Str(self:nAno))

Method GetVencimento() Class CenNotiSib
    Local nMesConf := 0
    nMesConf := self:nMes + 1
    If nMesConf > 12
        nMesConf := 1
        self:nAno++
    EndIf
Return STOD(AllTrim(Str(self:nAno))+AllTrim(StrZero(nMesConf,2))+"05")