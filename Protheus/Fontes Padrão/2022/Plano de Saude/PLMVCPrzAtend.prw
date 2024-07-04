#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLMVCPRZATEND.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMVCPrzAtend
Rotina de Cadastro dos Prazos de Atendimento de Acordo com a RN 259

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 03/12/2021
/*/
//-------------------------------------------------------------------
Function PLMVCPrzAtend()

    Local oBrowse := Nil

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("B6Y")
    oBrowse:SetDescription(STR0001) // "Prazo do Atendimento do Beneficiário"    
    oBrowse:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina de Prazos de Atendimento

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 03/12/2021
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.PLMVCPrzAtend" OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.PLMVCPrzAtend" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.PLMVCPrzAtend" OPERATION 5 ACCESS 0 // "Excluir"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.PLMVCPrzAtend" OPERATION 8 ACCESS 0 // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Cadastro de Prazos do Atendimento

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 03/12/2021
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oModel := Nil
    Local oStruB6Y := FWFormStruct(1, "B6Y")

	oModel := MPFormModel():New("PLMVCPrzAtend")
	
	oModel:addFields("MASTERB6Y",, oStruB6Y)   
	oModel:GetModel("MASTERB6Y"):SetDescription(STR0001) // "Prazo de Atendimento do Beneficiário"

    oModel:SetPrimaryKey({})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela de Visualização do Rotina de Prazos de Atendimento

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 03/12/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView := Nil
    Local oModel := FWLoadModel("PLMVCPrzAtend")
    Local oStruB6Y := FWFormStruct(2, "B6Y")
        
    oView := FWFormView():New()
    
    oView:SetModel(oModel)

    oView:AddField("VIEW_TELA", oStruB6Y, "MASTERB6Y")

    oView:CreateHorizontalBox("BOX_TELA", 100)  
    oView:SetOwnerView("VIEW_TELA", "BOX_TELA")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLPrazoAtend
Função para instanciar a classe que irá calcular o Prazo do Atendimento

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 03/12/2021
/*/
//-------------------------------------------------------------------
Function PLPrazoAtend(oDadosPrazo)

    Local nX := 0
    Local nPosCampo := 0
    Local cCodProced := ""
    Local cCodTabela := ""
    Local lAuditoria := .F.
    Local cCodSessao := ""
    Local lAltoCusto := .F.
    Local lProcOdonto := .F.
    Local aDadosProc := {}
    Local dDataPrazo := CToD(" / / ")
    Local oPrazoAtend := Nil
    Local lHabilita := PlsAliasExi("B6Y") .And. FindClass("PLCalcPrzAtend") .And. B53->(FieldPos("B53_DATPRZ")) > 0
    Local aAreaBR8 := BR8->(GetArea())

    If lHabilita .And. ValType(oDadosPrazo) == "J"
        oPrazoAtend := PLCalcPrzAtend():New()

        oPrazoAtend:SetTpAdmissao(oDadosPrazo["cTipAdmissao"], oDadosPrazo["lAtendInternacao"])
        oPrazoAtend:SetHospitalDia(oDadosPrazo["lHospitalDia"])
        oPrazoAtend:SetAtendOdonto(oDadosPrazo["lOdonto"])

        For nX := 1 To Len(oDadosPrazo["aColsItens"])

            nPosCampo := Ascan(oDadosPrazo["aHeaderItens"], {|x| x[2] == oDadosPrazo["cAliasItens"]+"_CODPAD"})
            cCodTabela := IIf(nPosCampo > 0, oDadosPrazo["aColsItens"][nX][nPosCampo], "")

            nPosCampo := Ascan(oDadosPrazo["aHeaderItens"], {|x| x[2] == oDadosPrazo["cAliasItens"]+"_CODPRO"})
            cCodProced := IIf(nPosCampo > 0, oDadosPrazo["aColsItens"][nX][nPosCampo], "")

            nPosCampo := Ascan(oDadosPrazo["aHeaderItens"], {|x| x[2] == oDadosPrazo["cAliasItens"]+"_AUDITO"})
            lAuditoria := IIf(nPosCampo > 0, oDadosPrazo["aColsItens"][nX][nPosCampo], "") == "1"

            If lAuditoria
                If PLSISCON(cCodTabela, cCodProced)
                    oPrazoAtend:SetConsulta(oDadosPrazo["cEspecialidade"])
                Else
                    aDadosProc := GetDadosProced(cCodTabela, cCodProced)

                    If Len(aDadosProc) >= 3
                        cCodSessao := aDadosProc[1]
                        lAltoCusto := aDadosProc[2]
                        lProcOdonto := aDadosProc[3]
     
                        oPrazoAtend:SetSessao(cCodSessao)
                        oPrazoAtend:SetProcAltoCusto(lAltoCusto)
                        oPrazoAtend:SetAtendOdonto(lProcOdonto)

                        If Empty(cCodSessao) .And. !lAltoCusto .And. !lProcOdonto
                            oPrazoAtend:SetServicosAmb(oDadosPrazo["lRegAmbulatorio"], oDadosPrazo["lLaboratorio"])
                        EndIf
                    EndIf

                EndIf       
            EndIf

        Next nX

        dDataPrazo := oPrazoAtend:CalcPrazo()
    EndIf

    RestArea(aAreaBR8)
  
Return dDataPrazo


//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadosProced
Retorna os Dados do Procedimento Informado

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Static Function GetDadosProced(cCodTabela, cCodProced)

    Local cAliasTemp := ""
    Local cQuery := ""
    Local cCodSessao := ""
    Local lAltoCusto := .F.
    Local lOdonto := .F.

    Default cCodTabela := ""
    Default cCodProced := ""

    cAliasTemp := GetNextAlias()
    cQuery := " SELECT BR8.BR8_CLASIP, BR8.BR8_ALTCUS, BR8.BR8_ODONTO FROM "+RetSqlName("BR8")+" BR8 "
    cQuery += " WHERE BR8.BR8_FILIAL = '"+xFilial("BR8")+"'"
    cQuery += "   AND BR8.BR8_CODPAD = '"+cCodTabela+"'"
    cQuery += "   AND BR8.BR8_CODPSA = '"+cCodProced+"'"
    cQuery += "   AND BR8.D_E_L_E_T_ = ' '"

    dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)
    
    If !(cAliasTemp)->(Eof())

        If Alltrim((cAliasTemp)->BR8_CLASIP) $ "B1/B2/B3/B4/B5" 
            cCodSessao := Alltrim((cAliasTemp)->BR8_CLASIP)
        EndIf

        If Alltrim((cAliasTemp)->BR8_ALTCUS) == "1"
            lAltoCusto := .T.
        EndIf

        If Alltrim((cAliasTemp)->BR8_ODONTO) == "1"
            lOdonto := .T.
        EndIf 

    EndIf

    (cAliasTemp)->(DbCloseArea())

Return {cCodSessao, lAltoCusto, lOdonto}


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRetLegPrz
Retorna a Legenda da Guia de Acordo com o Prazo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/12/2021
/*/
//-------------------------------------------------------------------
Function PLRetLegPrz(dDataPrazo, cSituacao, lLegenda)
    
    Local cRetorno := ""
    Local nDiasDif := 0

    Default dDataPrazo := CToD(" / / ")
    Default cSituacao := ""
    Default lLegenda := .T.

    If !Empty(dDataPrazo) .And. cSituacao <> "1"
        nDiasDif := dDataPrazo - dDataBase

        Do Case
            Case nDiasDif < 0
                cRetorno := IIf(lLegenda, "BR_PRETO", STR0012) // "Excedido"

            Case nDiasDif == 0
                cRetorno := IIf(lLegenda, "BR_VERMELHO", STR0013) // "Hoje"

            Case nDiasDif <= 3 .And. lLegenda
                cRetorno := "BR_LARANJA"

            Case nDiasDif <= 7 .And. lLegenda
                cRetorno := "BR_AMARELO"

            Case nDiasDif <= 14 .And. lLegenda
                cRetorno := "BR_VERDE"
            
            Case nDiasDif > 14 .And. lLegenda
                cRetorno := "BR_AZUL"       
        EndCase

        If !lLegenda .And. nDiasDif > 0
            cRetorno := cValToChar(nDiasDif) + IIf(nDiasDif == 1, STR0014, STR0015) // " Dia" ; " Dias"
        EndIf

    EndIf

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} PLLegPrzAtend
Tela de Legenda dos Prazos do Atendimentos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Function PLLegPrzAtend()

	Local aLegenda := {}
	
	aAdd(aLegenda, {"BR_PRETO", STR0012}) // "Excedido"
	aAdd(aLegenda, {"BR_VERMELHO", STR0016}) // "Prazo pra Hoje"
	aAdd(aLegenda, {"BR_LARANJA", STR0017}) // "Prazo em até 3 dias"
	aAdd(aLegenda, {"BR_AMARELO", STR0018}) // "Prazo em até 7 dias"
	aAdd(aLegenda, {"BR_VERDE", STR0019}) // "Prazo em até 14 dias"
	aAdd(aLegenda, {"BR_AZUL", STR0020}) // "Prazo a partir de 14 dias"

	BrwLegenda(STR0021, STR0022, aLegenda) // "Legenda dos Prazos do Atendimento" ; "Legenda"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLStaPrzAtend
Status das Guias de Acordo com os Prazos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Function PLStaPrzAtend()

	Local aStatus := {}
	
	aStatus := GetStatusPrazo()

	BrwLegenda(STR0023, STR0024, aStatus) // "Status dos Prazos do Atendimento" ; "Status"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatusPrazo
Retorna o Status do Prazos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Static Function GetStatusPrazo()

    Local aStatus := {}

    aAdd(aStatus, {"BR_PRETO", QtdGuiasPrazo(0, "<", 0, "<")+" ("+STR0012+")"}) // "Excedido"
	aAdd(aStatus, {"BR_VERMELHO", QtdGuiasPrazo(0, "=", 0, "=")+" ("+STR0016+")"}) // "Prazo pra Hoje"
	aAdd(aStatus, {"BR_LARANJA", QtdGuiasPrazo(1, ">=", 3, "<=" )+" ("+STR0017+")"}) // "Prazo em até 3 dias"
	aAdd(aStatus, {"BR_AMARELO", QtdGuiasPrazo(4, ">=", 7, "<=")+" ("+STR0018+")"}) // "Prazo em até 7 dias"
	aAdd(aStatus, {"BR_VERDE", QtdGuiasPrazo(8, ">=", 14, "<=")+" ("+STR0019+")"}) // "Prazo em até 14 dias"
	aAdd(aStatus, {"BR_AZUL", QtdGuiasPrazo(14, ">", 14, ">")+" ("+STR0020+")"}) // "Prazo a partir de 14 dias"

Return aStatus


//-------------------------------------------------------------------
/*/{Protheus.doc} QtdGuiasPrazo
Retorna a Quantidade de Guias de Acordo com o Prazo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Static Function QtdGuiasPrazo(nPrazo1, cOperador1, nPrazo2, cOperador2)

    Local cQuery := ""
    Local cRetorno := ""
    Local nQtdRegistro := 0
    Local cTipoBanco := Alltrim(Upper(TCGetDb()))

    Default nPrazo1 := 0 
    Default cOperador1 := " = "
    Default nPrazo2 := 0 
    Default cOperador2 := " = "

    cQuery := " SELECT COUNT(B53.B53_NUMGUI) AS CONTADOR FROM "+RetSqlName("B53")+" B53 "
    cQuery += " WHERE B53.B53_FILIAL = '"+xFilial("B53")+"' "
    cQuery += "   AND B53.B53_DATPRZ <> ' ' "
    cQuery += "   AND B53.B53_SITUAC <> '1' "

    cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                  " AND DATEDIFF(Day, '"+DToS(dDataBase)+"', B53.B53_DATPRZ) "+cOperador1+" "+cValToChar(nPrazo1),;
                  " AND TO_NUMBER(TO_DATE('"+DToS(dDataBase)+"', 'YYYYMMDD') - TO_DATE(B53.B53_DATPRZ, 'YYYYMMDD'))"+cOperador1+" "+cValToChar(nPrazo1))

    cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                  " AND DATEDIFF(Day, '"+DToS(dDataBase)+"', B53.B53_DATPRZ) "+cOperador2+" "+cValToChar(nPrazo2),;
                  " AND TO_NUMBER(TO_DATE('"+DToS(dDataBase)+"', 'YYYYMMDD') - TO_DATE(B53.B53_DATPRZ, 'YYYYMMDD'))"+cOperador2+" "+cValToChar(nPrazo2))

    If ExistBlock("PL790FIL")
	    cQuery += ExecBlock("PL790FIL")

        cQuery := StrTran(cQuery, ".AND.", " and ")
        cQuery := StrTran(cQuery, ".and.", " and ")
        cQuery := StrTran(cQuery, ".OR.", " or ")
        cQuery := StrTran(cQuery, ".or.", " or ")
    EndIf

    cQuery += " AND B53.D_E_L_E_T_ = ' '"

    nQtdRegistro := MPSysExecScalar(cQuery, "CONTADOR")

	Do Case
        Case nQtdRegistro == 0
            cRetorno := STR0025 // "Nenhuma Guia"
        
        Case nQtdRegistro == 1
            cRetorno := cValToChar(nQtdRegistro)+STR0026 // " Guia"

        OtherWise
            cRetorno := cValToChar(nQtdRegistro)+STR0027 // " Guias"
    EndCase

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} PLConPrzBrw
Realiza a Consulta do Browser na Rotina de Auditoria por Guia

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Function PLConPrzBrw(cTipoFiltro)

    Default cTipoFiltro := ""

    If ValType(oB53) == "O"

        oB53:CleanFilter()
        oB53:CleanExFilter()
        oB53:DeleteFilter("CUSTOM")

        cFiltro := GetFiltroPrazo(cTipoFiltro)
       
        oB53:AddFilter("Filial", cFiltro, .T., .T., "B53", Nil, Nil, "CUSTOM")
        oB53:SetFilterDefault(cFiltro)
        oB53:Refresh(.T.)

    EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetFiltroPrazo
Retorna o Filtro de Acordo com o Tipo do Prazo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Static Function GetFiltroPrazo(cTipoFiltro)

    Local cFiltro := ""

    Default cTipoFiltro := ""

    cFiltro := " B53_FILIAL = '"+xFilial("B53")+"'"
    
    If !Empty(cTipoFiltro)
        cFiltro += " .AND. DToS(B53_DATPRZ) <> ' ' "
        cFiltro += " .AND. B53_SITUAC <> '1' "
    EndIf

    Do Case
        Case cTipoFiltro == "0" // Excedido
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) < 0) "
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) < 0) " 

        Case cTipoFiltro == "1" // "Prazo pra Hoje"
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) = 0) "
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) = 0) "

        Case cTipoFiltro == "2" // "Prazo em até 3 dias"
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) >= 1) "
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) <= 3) "

        Case cTipoFiltro == "3" // "Prazo em até 7 dias"
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) >= 4) "
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) <= 7) "

        Case cTipoFiltro == "4" // "Prazo em até 14 dias"
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) >= 8) "
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) <= 14) "

        Case cTipoFiltro == "5" // "Prazo a partir de 14 dias"
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) > 14) "
            cFiltro += " .AND. ((B53_DATPRZ - dDataBase) > 14) "
    EndCase

    If ExistBlock("PL790FIL")
	    cFiltro += ExecBlock("PL790FIL")
    EndIf

Return cFiltro