#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA110
Rotina de gravacao do Codigo de Lancamento Cat83

@author Flavio Luiz Vicco
@since 22/06/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA110()

    Local oProcess
    Local aSM0      := {}
    Local lCancel   := .F.
    Local lOk       := .F.

    If pergunte('FISA110',.T.,'Parâmetros de gravação do Cod.Lancto')
        /*Busca as filiais selecionadas pelo usuário*/
        oProcess:= FISProgress():New({||x110Proc(oProcess,@lOk,@lCancel)},'Processando Cod.Lancto CAT83')
        oProcess:Activate()
        If lCancel
            Alert('Operação Cancelada pelo usuário','Cat83')
        EndIf
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x110Proc()
Função que irá processar as tabelas de movimentações para a gravação do codigo de lancamento

@param oProcess,obj,obj.regua
@param lOk,boolean,proc.finalizado
@param lCancel,boolean,proc.cancel

@author Flavio Luiz Vicco
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x110Proc(oProcess,lOk,lCancel)

    Local TimeInicio    := ''
    Local TimeFim       := ''
    Local aSM0          := FSA008Fil(MV_PAR03==1)
    Local nQtdProc      := Len(aSM0)
    Local nX            := 0

    oProcess:Set1Progress((6*nQtdProc))
    oProcess:Set2Progress(1)
    TimeInicio := Time()
    oProcess:Inc1Progress('Iniciando processamento')

    For nX := 1 to Len(aSM0)
        cFilAnt := aSM0[nX][02]

        oProcess:Inc1Progress('Processando Filial : '+cFilAnt)
        oProcess:SetDetProgress('Inicio do processamento',TimeInicio,;
            'Fim do Processamento',"",;
            'Tempo de processamento',"",;
            "","")
        If MV_PAR04==1
            x110Grv('SD1')
            oProcess:Inc2Progress('Processando Doc.Entrada')
        EndIf
        If MV_PAR05==1
            x110Grv('SD2')
            oProcess:Inc2Progress('Processando Doc.Saidas')
        EndIf
        If MV_PAR06==1
            PCAT83_SD3(MV_PAR01, MV_PAR02, IIF(MV_PAR07==1, .T., .F.))
            oProcess:Inc2Progress('Processando Mov.Interno')
        EndIf
    Next nX
    cFilAnt := FwCodFil()
    oProcess:Set1Progress(1)
    oProcess:Set2Progress(1)
    oProcess:Inc1Progress('Concluído')
    oProcess:Inc2Progress('Concluído')
    TimeFim := Time()
    oProcess:Inc2Progress('Concluído')
    oProcess:SetDetProgress('Inicio do processamento',TimeInicio,;
        'Fim do Processamento',TimeFim,;
        'Tempo de processamento',ELAPTIME(TimeInicio,TimeFim),;
        "","")
    If !lcancel
        MsgInfo('Processo finalizado com Sucesso','Cat83')
        lOk	:= .T.
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} x110Grv()
Função que irá processar as tabelas de movimentações para a gravação do codigo de lancamento

@param cAlias,caracter,Alias

@author Flavio Luiz Vicco
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x110Grv(cAlias)
    Local cTabela   := ""
    Local cWhere    := "WHERE "
    Local cQuery    := ""
    Local cPrefix   := Substr(cAlias,2,2)
    Local cUpdate   := "UPDATE " + RetSqlName(cAlias) + " SET "  + cPrefix+"_CODLAN = "
    Local cFrom     := ""

    cFrom  := "SF4.F4_CODLAN FROM " + RetSqlName(cAlias) + " AS " + cAlias + " INNER JOIN "
    cFrom  += RetSqlName("SF4") + " SF4 ON F4_FILIAL = '"+ xFilial('SF4') + "' AND " + cAlias + "." + cPrefix+"_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' '"
    cWhere += cAlias + "." + cPrefix+"_FILIAL   = '" + xFilial(cAlias) + "' AND "
    cWhere += cAlias + "." +cPrefix+"_EMISSAO >= '" + dTos(MV_PAR01)  + "' AND "
    cWhere += cAlias + "." +cPrefix+"_EMISSAO <= '" + dTos(MV_PAR02)  + "'"
    //Se marcar a opção de não sobrepor
    If MV_PAR07 == 2
        cWhere += " AND " + cAlias + "." + cPrefix+"_CODLAN   = ' '"
    EndIf
    
    cWhere += " AND " + cAlias + "." + "D_E_L_E_T_ = ' '"
    
    cQuery := cUpdate + cFrom + cWhere
    
    TcSqlExec(cQuery)

Return Nil


