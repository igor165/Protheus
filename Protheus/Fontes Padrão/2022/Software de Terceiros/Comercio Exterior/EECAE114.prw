#INCLUDE "FWBROWSE.CH"
#INCLUDE "AVERAGE.CH"
#Include "TOPCONN.ch"
#include "EEC.CH"

Function EECAE114()
//Informa��es para prepara��o da tela
Local aCoors := FWGetDialogSize( oMainWnd ), oDlg, lOk := .F., cTitulo := "Altera��o de Embarques"
Local bValid		:= {|| If(PossuiEmbMarcado(), lOk := MsgYesNo("Confirma a atualia��o dos embarques marcados?", "Aviso"), MsgYesNo("N�o foram marcados processos para atualiza��o, deseja sair?", "Aviso"))}
//Informa��es dos campos que ser�o exibidos na tela
Local aCampos		:= {"EEC_FILIAL", "EEC_PREEMB", "EEC_DTEMBA", "EEC_NRCONH", "EEC_DTCONH"}
Local aEditaveis    := {"EEC_DTEMBA", "EEC_NRCONH", "EEC_DTCONH"}
Local aIndices      := {{"EEC_FILIAL", "EEC_PREEMB"}, {"EEC_PREEMB"},{"EEC_DTEMBA", "EEC_PREEMB"},{"EEC_DTCONH", "EEC_DTEMBA"}}
//Informa��es sobre o grid de sele��o/altera��o de embarques
Local oColumn, aFields := {}
Local bMarca		:= {|| If(Empty(WORKEEC->WK_MARCA), WORKEEC->WK_MARCA := cMarca, WORKEEC->WK_MARCA := "") }
Local bMarcaTodos	:= {|oBrowse| MarkAllItens(Empty(WORKEEC->WK_MARCA)), oBrowse:Refresh() }
Local aFilter       := {}, aPesquisa := {}, oTemp, i, j
Private cMarca := GetMark()
Private oBrowse
//Vari�vel necess�ria para execu��o da atualiza��o autom�tica
Private lEE7Auto := .T.

if valtype(cTipoProc) <> Nil .and. cTipoProc <> PC_RG
    MsgStop("N�o � poss�vel utilizar essa rotina para embarques que n�o sejam do tipo regular","Aten��o!")
    Return Nil
endif

//Cria arquivo tempor�rio para registrar as informa��es dos embarques que ainda n�o foram embarcados
//Adiciona no array a Fields a estrutura do campo de marca��o
aAdd(aFields, {"WK_MARCA", "C", 2, 0})
//Adiciona no array aFields a estrutura dos campos relacionados no array aCampos
aEval(aCampos, {|x| aAdd(aFields, {x, GetSx3Cache(x, "X3_TIPO"), GetSx3Cache(x, "X3_TAMANHO"), GetSx3Cache(x, "X3_DECIMAL")}) })
//Adiciona no array aFilter a estrutura das chaves definidas no array aIndices
aEval(aCampos, {|x| AAdd(aFilter, {x, GetSx3Cache(x, "X3_TITULO"), GetSx3Cache(x, "X3_TIPO"), GetSx3Cache(x, "X3_TAMANHO"), GetSx3Cache(x, "X3_DECIMAL"), GetSx3Cache(x, "X3_PICTURE")}) })
For i := 1 To Len(aIndices)
    cNomeIndice := ""
    aIdCampos := {}
    For j := 1 To Len(aIndices[i])
        cNomeIndice += AllTrim(GetSx3Cache(aIndices[i][j], "X3_TITULO")) + If(j<Len(aIndices[i]), "+", "")
        aAdd(aIdCampos, {, GetSx3Cache(aIndices[i][j], "X3_TIPO"),GetSx3Cache(aIndices[i][j], "X3_TAMANHO"),GetSx3Cache(aIndices[i][j], "X3_DECIMAL"), GetSx3Cache(aIndices[i][j], "X3_TITULO")})
    Next
    aAdd(aPesquisa, {cNomeIndice, aIdCampos, i})
Next
//Cria o arquivo tempor�rio no banco de dados
oTemp := FWTemporaryTable():New("WORKEEC", aFields)
//Adiciona os �ndices
For i := 1 To Len(aIndices)
    oTemp:AddIndex(StrZero(i, 2), aIndices[i])
Next
//Cria um �ndice no campo de marca��o
oTemp:AddIndex(StrZero(i, 2), {"WK_MARCA"})
oTemp:Create()

dDataLimite := dtos((dDatabase-30))
//Consulta a base de dados para identificar os processos dispon�veis. N�o ser�o retornados na consulta processos n�o embarcados que ainda possuam algum item sem nota fiscal ou processos embarcados com c�mbio contratado
BeginSql Alias "EMBARQUES"
    column EEC_DTEMBA as Date
    Select Distinct
       EEC.R_E_C_N_O_ AS REC_EEC
    From 
        %table:EEC% EEC
    inner join %table:EE9% EE9
        on  EE9.EE9_FILIAL = EEC.EEC_FILIAL
        And EE9.EE9_PREEMB = EEC.EEC_PREEMB
        And EE9.%NotDel%
    Where
        EEC.%NotDel%
        AND EEC.EEC_STATUS NOT IN ('9','A')
        AND EEC.EEC_INTERM<>'1'
        AND EEC.EEC_TIPO=' '
        AND ((EEC.EEC_DTEMBA=' ' AND EE9.EE9_NF<>' ')
            OR 
            (EEC.EEC_DTEMBA<>'' AND EEC.EEC_DTEMBA>= %exp:(dDatabase-30)%))
EndSql

//Adiciona os embarques identificados no arquivo tempor�rio
EMBARQUES->(dbgotop())
While EMBARQUES->(!Eof())
    EEC->(DbGoTo(EMBARQUES->REC_EEC))
    WORKEEC->(RECLOCK("WORKEEC",.T.))
    For i := 1 To Len(aCampos)
        WORKEEC->&(aCampos[i]) := EEC->&(aCampos[i])
    Next
    EMBARQUES->(DbSkip())
EndDo
WORKEEC->(MsUnlock())
EMBARQUES->(DbCloseArea())

//Cria tela para exibi��o das informa��es
oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)

    //Cria objeto Browse para listar os embarques e receber as informa��es
    oBrowse := FWBrowse():New(oDlg)
    oBrowse:SetDataTable(.T.)
    oBrowse:SetAlias("WORKEEC")
    oBrowse:SetDescription("Sele��o de Embarques para atualiza��o em lote")
    oBrowse:SetLocate()
    oBrowse:SetSeek(,aPesquisa)
    oBrowse:SetUseFilter()
    oBrowse:SetFieldFilter(aFilter)
    //oBrowse:AddFilter ("Processos n�o embarcados", "Empty(WORKEEC->EEC_DTEMBA) .Or. !Empty(WORKEEC->WK_MARCA)",,.T.) 
    oBrowse:SetEditCell (.T., {|| .T. })
 
    // Cria uma coluna de marca/desmarca
    oColumn := oBrowse:AddMarkColumns({|| If(Empty(WORKEEC->WK_MARCA), 'LBNO', 'LBOK') },bMarca,bMarcaTodos)
    
    //Cria as colunas com base no array aCampos
    For i := 1 To Len(aCampos)
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{ ||" + aCampos[i] + " }"))
        oColumn:SetTitle(GetSx3Cache(aCampos[i], "X3_TITULO"))
        oColumn:SetSize(GetSx3Cache(aCampos[i], "X3_TAMANHO"))
        oColumn:SetEdit(.T.)
        //Habilita a edi��o dos campos definidos no array aEditaveis
        If aScan(aEditaveis, aCampos[i]) > 0
            oColumn:SetReadVar("WORKEEC->"+aCampos[i])
            oColumn:SetValid({|| ValidCampo(ReadVar()) })
        EndIf
        oBrowse:SetColumns({oColumn})
    Next

	oBrowse:Activate()
	oDlg:lMaximized := .T.

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, {|| If(Eval(bValid), oDlg:End(), Nil) }, {|| oDlg:End() }) CENTERED

If lOk//Caso o usu�rio tenha confirmado e existam embarques marcados, executa a atualiza��o
    oProcess := MsNewProcess():New({|| AtuEmbarque(aCampos, oProcess)}, "Atualizando processos de embarque", "Iniciando execu��o", .F.)
    oProcess:Activate()
EndIf
//Apaga o tempor�rio
oTemp:Delete()
Return Nil

//Executa a atuali��o dos embarques via rotina autom�tica
Static Function AtuEmbarque(aCampos,oProcess)
Local i := 0, j
Local cFilAtu := cFilAnt
Local nTotalEmb := PossuiEmbMarcado(,.T.)
Local cMensagens := ""
Private lMsErroAuto := .F.

    //Cria regua de processamento com o total de embarques a atualizar
    oProcess:SetRegua1(nTotalEmb)
    WORKEEC->(DbSetorder(5))
    WORKEEC->(DbSeek(cMarca))
    While WORKEEC->(!Eof() .And. !Empty(cMarca))
        i++
        //Vari�vel de controle de erros na rotina autom�tica
        lMsErroAuto := .F.
        //Zera o log para n�o concatenar com o log do pr�ximo processo
        __cFileLog := Nil
        EEC->(DbSetOrder(1))
        //Posiciona no processo de embarque
        If EEC->(DbSeek(WORKEEC->(EEC_FILIAL+EEC_PREEMB)))
            //Atualiza a regua de processamento
            oProcess:IncRegua1("Embarque:" + AllTrim(EEC->EEC_PREEMB) + " Filial: " + AllTrim(EEC->EEC_FILIAL) + " (" + AllTrim(Str(i)) + "/" + AllTrim(Str(nTotalEmb)) + ")")
            //Como o objeto mostra obrigatoriamente duas reguas, for�a a anima��o da segunda regua
            oProcess:SetRegua2(0)
            oProcess:IncRegua2()
            oProcess:IncRegua2("Executando atualiza��o")
            SysRefresh()
            //Cria array com os campos a serem atualizados
            aEEC := {}
            For j := 1 To Len(aCampos)
                aAdd(aEEC, {aCampos[j], WORKEEC->&(aCampos[j]), Nil})
            Next
            //Altera a filial corrente para a filial do processo
            cFilAnt := EEC->EEC_FILIAL
            //Executa a atualiza��o autom�tica
            MsExecAuto({|x,y| EECAE100(,x,y)}, 4, {{"EEC", aEEC}})
            //Caso tenha ocorrido erro, pergunta se o usu�rio quer visualizar as mensagens
            If lMsErroAuto
                //Apresenta os erros da rotina autom�tica
                If !Empty(MemoRead(NomeAutoLog()))
                    cMensagens += "Mensagens retornadas na atualiza��o do Embarque: " + Alltrim(WORKEEC->EEC_PREEMB) + " da Filial: " + AllTrim(WORKEEC->EEC_FILIAL) + Chr(13) + Chr(10)
                    cMensagens += MemoRead(NomeAutoLog()) + Chr(13) + Chr(10)
                    cMensagens += Chr(13) + Chr(10)
                EndIf
            EndIf
        EndIf
        WORKEEC->(DbSkip())
    EndDo
    //Restaura a filial anterior
    cFilAnt := cFilAtu
    If !Empty(cMensagens) .And. MsgYesNo("A atualiza��o retornou mensagens de valida��o/erro e alguns processos podem n�o ter sido atualizados. Deseja visualizar as mensagens?", "Aviso")
        EECView(cMensagens, "Aviso")
    EndIf
    MsgInfo("Atualiza��o conclu�da.", "Aviso")

Return Nil

//Valida as altera��es dos campos edit�veis
Static Function ValidCampo(cCampo)
//Guarda o posicionamento do tempor�rio
Local aOrd := SaveOrd("WORKEEC")
Local lReplica, lSobrescreve, i, xInfo

    //Caso tenha digitado alguma informa��o no campo e o embarque n�o esteja marcado, marca automaticamente
    If Empty(WORKEEC->WK_MARCA)
        WORKEEC->WK_MARCA := cMarca
    EndIf

    //Caso exista mais de um embarque marcado, verifica os demais
    If PossuiEmbMarcado(.T.)
        //Guarda a informa��o do processo atual
        cProc := WORKEEC->(EEC_FILIAL+EEC_PREEMB)
        //Guarda a informa��o do campo que foi digitado
        xInfo := &cCampo
        WORKEEC->(DbSetOrder(5))
        WORKEEC->(DbSeek(cMarca))
        While !Empty(WORKEEC->WK_MARCA)
            If WORKEEC->(EEC_FILIAL+EEC_PREEMB) <> cProc
                //Caso a informa��o seja diferente pergunta se o usu�rio quer atualizar esta informa��o para este e para os demais processos
                If &cCampo <> xInfo
                    If lReplica == Nil .And. !(lReplica := MsgYesNo("Deseja replicar a informa��o para os demais processos marcados?", "Aviso"))
                        Exit
                    EndIf
                    //Se estiver em branco e o usu�rio tiver confirmado, replica a informa��o
                    If Empty(&cCampo)
                        &cCampo := xInfo
                    Else
                        //Se n�o estiver em branco, avisa o usu�rio e pergunta se ele deseja sobrescrever a informa��o digitada para este e para os demais processos
                        If lSobrescreve == Nil
                            lSobrescreve := MsgYesNo("Existem processos marcados onde este campo j� foi informado, deseja sobrescrever?", "Aviso")
                        EndIf
                        //Se tiver confirmado, sobrescreve a informa��o
                        If lSobrescreve
                            &cCampo := xInfo
                        EndIf
                    EndIf
                EndIf
            EndIf
            WORKEEC->(DbSkip())
        EndDo
    EndIf
//Restaura o posicionamento da tabela
Restord(aOrd, .T.)
//Atualiza a tela/browse
oBrowse:Refresh()
Return .T.

//Verifica se existe algum processo marcado.
//lMaisdeUm: Verifica se existe mais de um processo marcado; lRetTotal: Retorna o total de processos marcados
Static Function PossuiEmbMarcado(lMaisdeUm, lRetTotal)
Local lRet := .F.
Local nTotal := 0
Local aOrd := SaveOrd("WORKEEC")
Local cFilter := WORKEEC->(DbFilter())
Default lMaisdeUm := .F.
Default lRetTotal := .F.

    WORKEEC->(DbClearFilter())
    WORKEEC->(DbSetOrder(5))
    If WORKEEC->(DbSeek(cMarca))
        If lRetTotal
            While WORKEEC->(!Eof() .And. !Empty(WK_MARCA))
                nTotal++
                WORKEEC->(DbSkip())
            EndDo
        Else
            If lMaisdeUm
                WORKEEC->(DbSkip())
                If !Empty(WORKEEC->WK_MARCA)
                    lRet := .T.
                EndIf
            Else
                lRet := .T.
            EndIf
        EndIf
    EndIf
    If !Empty(cFilter)
        WORKEEC->(DbSetFilter(&("{||" + cFilter + "}"), cFilter))
    EndIf

RestOrd(aOrd, .T.)
Return If(lRetTotal, nTotal, lRet)

//Marca todos os itens
Static Function MarkAllItens(lMarca)
Local aOrd := SaveOrd("WORKEEC")

    WORKEEC->(DbGoTop())
    While WORKEEC->(!Eof())
        If lMarca
            WORKEEC->WK_MARCA := cMarca
        Else
            WORKEEC->WK_MARCA := ""
        EndIf
        WORKEEC->(DbSkip())
    EndDo

RestOrd(aOrd, .T.)
Return Nil