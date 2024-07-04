#include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenAjuCriB

/*/
//--------------------------------------------------------------------------------------------------
Function CenAjuCriB(lAuto)
    Local aSay      := {}
    Local aButton   := {}
    Local nOpc      := 0
    Local cDesc1	:= 'Esta rotina limpa as críticas anteriores a 2 anos, considerando o período'
    Local cDesc2	:= 'informado nos parâmetros Ano de: e Ano até:.'
    Local cTitulo   := "Realiza a limpeza de críticas anteriores a 2 anos."
    Local lOk       := .F.
    Default lAuto   := .F.

    aAdd( aSay, cDesc1 )
    aAdd( aSay, cDesc2 )

    aAdd( aButton, { 5, .T., { || nOpc := 1, Pergunte('CENCRITB3F',.T.,cTitulo,.F.) } } )
    aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
    aAdd( aButton, { 2, .T., { || FechaBatch() } } )

    IIF(!lAuto,FormBatch( cTitulo, aSay, aButton, , 200, 450 ),"")

    If nOpc == 2 .Or. lAuto

        cCodOpe	:= IIF(lAuto,"417505",MV_PAR01)
        cAnoDe	:= IIF(lAuto,"1955"  ,MV_PAR02)
        cAnoAte	:= IIF(lAuto,"1955"  ,MV_PAR03)
        cTipObr	:= IIF(lAuto,"1"     ,MV_PAR04)

        If !Empty(cCodOpe) .Or. !Empty(cAnoDe) .Or. !Empty(cTipObr)
            Processa( { || lOk := CenAjuQryC(cCodOpe,cAnoDe,cAnoAte,Alltrim(cTipObr),lAuto)},'Aguarde','Processando...',.F.)
            lOk:=.T.
        Else
            MsgInfo("Para confirmar o processamento informe todos os parâmetros.","TOTVS")
        EndIf

    EndIf

    If lOk
        IIF(lAuto,"",MsgAlert("Limpeza das críticas concluída!"))
    Endif

Return lOk

Static Function ValidaPergunta(lAuto)
    Local lRet	  := .T.
    Local cMsg	  := ""
    Default lAuto :=.F.

    If Empty(mv_par01)
        lRet := .F.
        cMsg += "Pergunta 1: Informe a Operadora." + CRLF
    Else
        B8M->(dbSetOrder(1))
        B8M->(dbGoTop())
        If !B8M->(dbSeek(xFilial("B8M")+mv_par01))
            lRet := .F.
            cMsg += "Pergunta 1: Número informado não existe no cadastro de Operadoras." + CRLF
        Endif
    Endif

    If Empty(mv_par02)
        lRet := .F.
        cMsg += "Pergunta 2: Informe o ano." + CRLF
    Else
        If val(mv_par02) >= (Year(dDataBase)-2)
            lRet := .F.
            cMsg += "Pergunta 2: O ano informado deve ser inferior a 2 anos atrás." + CRLF
        endIf
    EndIF

    If Empty(mv_par03)
        lRet := .F.
        cMsg += "Pergunta 3: Informe o ano." + CRLF
    Else
        If val(mv_par03) >= (Year(dDataBase)-2)
            lRet := .F.
            cMsg += "Pergunta 3: O ano informado deve ser inferior a 2 anos atrás." + CRLF

        ElseiF Val(mv_par03) < Val(mv_par02)
            lRet := .F.
            cMsg += "Pergunta 3: O ano até deve ser maior ou igual ao informado no parâmetro anterior." + CRLF

        EndIF

    EndIF

    If Empty(mv_par04)
        lRet := .F.
        cMsg += "Pergunta 4: Informe ao menos 1 obrigação a ser processada." + CRLF
    Endif

    If !lRet
        MsgInfo("Os seguintes parametros nao foram respondidos corretamente: " + CRLF + CRLF + cMsg ,"TOTVS")
    EndIf

Return lRet

Static Function CenAjuQryC(cCodOpe,cAnoDe,cAnoAte,cTipObr,lAuto)
    Local cSql     := ""
    LOCAL aObr     := {}
    Local nI       := 0
    Local nRet     := 0
    Default cCodOpe:= ""
    Default cAnoDe := ""
    Default cAnoAte:= ""
    Default cTipObr:= ""
    Default lAuto  := .F.

    aObr:=StrTokArr(cTipObr,",")

    cTipObr:=""

    For nI:=1 to Len(aObr)
        cTipObr+="'"+aObr[nI]+"'"
        If nI < Len(aObr)
            cTipObr+=","
        Endif
    Next

    IIF(lAuto,"",MsgAlert("Esta rotina limpa críticas(B3F) que tenham mais de 2 anos, considerando o conteúdo informado nos parâmetros Ano De e Ano Até."))

    If lAuto .Or. MsgYesNo("Este processo é irreversível!! Críticas de "+ CValToChar(mv_par02) +" até "+CValToChar(mv_par03)+" serão excluídas de acordo com parâmetros informados. Deseja continuar?")

        cSql := " UPDATE " + retSQLName("B3F") + " SET D_E_L_E_T_ = '*' "

        if CenChkUn("B3F")
            cSql += " ,R_E_C_D_E_L_ = R_E_C_N_O_"
        endIf

        cSql += "  WHERE B3F_FILIAL = '" + xFilial("B3F") + "' "
        cSql += "    AND B3F_CODOPE = '" + cCodOpe + "' "
        cSql += "    AND B3F_ANO BETWEEN '" + cAnoDe + "' AND '" + cAnoAte + "'
        cSql += "    AND B3F_TIPO   IN (" + cTipObr + ") "
        cSql += "    AND D_E_L_E_T_ = ' ' "

        nRet := TCSQLEXEC(cSql)
        If nRet >= 0
            TcSQLExec("COMMIT")
        EndIf
    EndIF

Return nRet >= 0


Function CENB3FAJU(cDado,lAuto)
    Local oDlg		:= Nil
    Local aConjunto	:= {}
    Local nFor		:= 0
    Local nOpc		:= 0
    Local bOK		:= { || nOpc := 1, oDlg:End() }
    Local bCancel	:= { || oDlg:End() }
    Default cDado	:= ''
    Default lAuto   := .F.

    aAdd(aConjunto,{'1','SIP'			,.F.})
    aAdd(aConjunto,{'2','SIB'		    ,.F.})
    aAdd(aConjunto,{'3','DIOPS'			,.F.})
    aAdd(aConjunto,{'4','DMED'	        ,.F.})
    aAdd(aConjunto,{'5','MONITORAMENTO'	,.F.})

    If !lAuto
        DEFINE MSDIALOG oDlg TITLE 'Obrigações' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()

        oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
        oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
        oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
        oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
        oConjunto:SetArray(aConjunto)
        oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 12 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
        ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
    Endif

    If nOpc == 1 .Or. lAuto
        cDado := ""
        For nFor := 1 To Len(aConjunto)
            If aConjunto[nFor,3] .Or. lAuto
                cDado += aConjunto[nFor,1]+","
            Endif
        Next
    Endif

    //Tira a virgula do final
    If Subs(cDado,Len(cDado),1) == "," .Or. lAuto
        cDado := Subs(cDado,1,Len(cDado)-1)
    EndIf
Return .T.


Function CenChkUn(cAlias)
    local lAtu := ! empty(FWX2Unico(cAlias))

return(lAtu)