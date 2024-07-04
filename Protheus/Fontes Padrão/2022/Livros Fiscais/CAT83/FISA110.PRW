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
    
    //Somente chama ajusta SX1 na versão 11.
    If GetVersao(.F.) <> "12"
        AtuSx1()
    EndIF

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
            //-- Pendente area Materiais.
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

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSx1()
Função que atualiza pergunte

@author Flavio Luiz Vicco
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSx1()

Local cPerg     := 'FISA110'
Local aPHelpPor := {}
Local aPHelpEng := {}
Local aPHelpSpa := {}

PutSx1(cPerg,"01","Data Inicial","Data Inicial","Data Inicial","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","")
aPHelpPor := {}
Aadd(aPHelpPor,'Informe a data Inicial para ')
Aadd(aPHelpPor,'processamento dos códigos ')
Aadd(aPHelpPor,'de lançamentos CAT83.')
aPHelpEng := aPHelpSpa := aPHelpPor
PutSX1Help("P.FISA11001.",aPHelpPor,aPHelpEng,aPHelpSpa)

PutSx1(cPerg,"02","Data Final  ","Data Final  ","Data Final  ","mv_ch2","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","")
aPHelpPor := {}
Aadd(aPHelpPor,'Informe a data Final para ')
Aadd(aPHelpPor,'processamento dos códigos ')
Aadd(aPHelpPor,'de lançamentos CAT83')
aPHelpEng := aPHelpSpa := aPHelpPor
PutSX1Help("P.FISA11002.",aPHelpPor,aPHelpEng,aPHelpSpa)

PutSx1(cPerg,"03","Seleciona Filiais?","Seleciona Filiais?","Seleciona Filiais?","mv_ch3","C",1,0,0,"C","","","","","mv_par03","1-Sim","1-Yes","1-Si","","2-Não","2-No","2-No")
aPHelpPor := {}
aPHelpEng := {}
aPHelpSpa := {}
Aadd(aPHelpPor,'Seleciona Filiais.')
Aadd(aPHelpPor,'')
Aadd(aPHelpPor,'')
aPHelpEng := aPHelpSpa := aPHelpPor
PutSX1Help("P.FISA11003.",aPHelpPor,aPHelpEng,aPHelpSpa)

PutSx1(cPerg,"04","Grv Doc.Entrada?","Grv Doc.Entrada?","Grv Doc.Entrada?","mv_ch4","C",1,0,0,"C","","","","","mv_par04","1-Sim","1-Yes","1-Si","","2-Não","2-No","2-No","","","","","","")
aPHelpPor := {}
aPHelpEng := {}
aPHelpSpa := {}
Aadd(aPHelpPor,'Informe se processa registros ')
Aadd(aPHelpPor,'de Documentos de Entradas (SD1).')
aPHelpEng := aPHelpSpa := aPHelpPor
PutSX1Help("P.FISA11004.",aPHelpPor,aPHelpEng,aPHelpSpa)

PutSx1(cPerg,"05","Grv Doc.Saídas?","Grv Doc.Saidas?","Grv Doc.Saidas?","mv_ch5","C",1,0,0,"C","","","","","mv_par05","1-Sim","1-Yes","1-Si","","2-Não","2-No","2-No","","","","","","")
aPHelpPor := {}
aPHelpEng := {}
aPHelpSpa := {}
Aadd(aPHelpPor,'Informe se processa registros ')
Aadd(aPHelpPor,'de Documentos de Saídas (SD2).')
aPHelpEng := aPHelpSpa := aPHelpPor
PutSX1Help("P.FISA11005.",aPHelpPor,aPHelpEng,aPHelpSpa)

PutSx1(cPerg,"06","Grv Mov.Interno?","Grv Mov.Interno?","Grv Mov.Interno?","mv_ch6","C",1,0,0,"C","","","","","mv_par06","1-Sim","1-Yes","1-Si","","2-Não","2-No","2-No","","","","","","")
aPHelpPor := {}
aPHelpEng := {}
aPHelpSpa := {}
Aadd(aPHelpPor,'Informe se processa registros ')
Aadd(aPHelpPor,'de Movimentos de Internos (SD3).')
aPHelpEng := aPHelpSpa := aPHelpPor
PutSX1Help("P.FISA11006.",aPHelpPor,aPHelpEng,aPHelpSpa)

PutSx1(cPerg,"07","Sobrepõe ?","Sobrepoe ?","Sobrepoe ?","mv_ch7","C",1,0,0,"C","","","","","mv_par07","1-Sim","1-Yes","1-Si","","2-Não","2-No","2-No","","","","","","")
aPHelpPor := {}
aPHelpEng := {}
aPHelpSpa := {}
Aadd(aPHelpPor,'Informe se grava código ')
Aadd(aPHelpPor,'para registros já gravados ')
Aadd(aPHelpPor,'ou somente em branco.')
aPHelpEng := aPHelpSpa := aPHelpPor
PutSX1Help("P.FISA11007.",aPHelpPor,aPHelpEng,aPHelpSpa)

Return Nil
