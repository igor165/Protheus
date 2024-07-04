#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXFIN.CH"

Static lNewGrvTC := Nil //Variável para controlar como o sistema deve fazer a gravação dos movimentos de troco  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTrocoInc
Efetua a inclusão de movimento financeiro referente a Entrada ou Saída de Troco.

@type       Function
@author     Alberto Deviciente
@since      05/06/2020
@version    12.1.27

@param nValor   , Numérico, Valor do Troco
@param nMoeda   , Numérico, Código da Moeda
@param nOpcao   , Numérico, Opção de chamada (1=Venda Comum; 2=Venda com Entrega, 3=Recebimento de Título)
@param dDataMov , Data, Data do Movimento
@param cBanco   , Caractere, Código do Banco (Caixa/Operador)
@param cAgencia , Caractere, Código da Agencia
@param cConta   , Caractere, Código da Conta
@param cPrefixo , Caractere, Prefixo do Título
@param cNumero  , Caractere, Número do Título
@param cParcela , Caractere, Parcela do Título 
@param cMsgErro , Caractere, Mensagem de erro caso ocorra algum problema de execução
@param cHistor  , Caractere, Histórico do movimento
@param cRecPag  , Caractere, Indica se é saída de troco (P=Pagamento) ou entrada de Troco (R=Recebimento) 
@param cSitua   , Caractere, Situação do Registro para integração do PDV com Retaguarda (00, TX, OK)

@return lRet, Lógico, Retorna se gerou o movimento de Troco com sucesso (.T.) ou não (.F.)
/*/
//-------------------------------------------------------------------------------------
Function LjTrocoInc( nValor     , nMoeda    , nOpcao    , dDataMov  ,;
                     cBanco     , cAgencia  , cConta    , cPrefixo  ,;
                     cNumero    , cParcela  , cMsgErro  , cHistor   ,;
                     cRecPag    , cSitua    , cLojaCli  , cCliFor )
Local lRet          := .T.
Local aDados        := {}
Local aAreaAtual    := GetArea()
Local aAreaSA6      := SA6->(GetArea())
Local aAreaSE5      := SE5->(GetArea())
Local cNatTroc      := IIf( cPaisLoc <> "BRA", SuperGetMV("MV_NATTROC"), GetNewPar("MV_NATTROC",'"TROCO"') )
Local cNatureza     := &(cNatTroc)
Local nTamSEQ       := TamSX3("E5_SEQ")[1]
Local nTamTpDoc     := TamSx3("E5_TIPODOC")[1]
Local cMotBx        := "NOR" //Motivo da Baixa do Título (NOR=Normal)
Local cTipoDoc      := PadR("VL",nTamTpDoc) //Tipo da Movimentação (VL=Movimentação Bancária ou Baixas que movimentem banco)
Local cSequencia    := StrZero(1,nTamSEQ)
Local nOperacao     := 0 //Operação que deseja realizar (3=Inclusão de Movimento "Pagar"; 4=Inclusão de Movimento "Receber")
Local cNumMov		:= AllTrim(LjNumMov()) //Retorno o numero do movimento atual
Local cSimbMoeda    := SuperGetMV("MV_SIMB"+AllTrim(Str(nMoeda)))
Local cTipo         := ""

Default cAgencia    := Iif(nMoeda > 1, cSimbMoeda, ".")
Default cConta      := "."
Default cParcela    := ""
Default cMsgErro    := ""
Default cHistor     := STR0001 //"Registro de Saida de Troco"
Default cRecPag     := "P" //P=Pagamento; R= Recebimento
Default cSitua      := ""
Default cLojaCli    := ""   // Código da Loja que será gravado no campo SE5->E5_LOJA
Default cCliFor     := ""   // Código Cliente que será gravado no campo SE5->E5_CLIFOR

Private lMsErroAuto := .F.

If nValor > 0
    LjGrvLog("", "Inicio da funcao de geracao de movimento de troco. Tipo Movimento: " + cRecPag)

    If cRecPag == "P"
        nOperacao := 3 //3=Inclusão de Movimento "Pagar"
    ElseIf cRecPag == "R"
        nOperacao := 4 //4=Inclusão de Movimento "Receber"
    EndIf

    cNatureza   := PadR(cNatureza   , TamSx3("E5_NATUREZ")[1])
    cPrefixo    := PadR(cPrefixo    , TamSx3("E5_PREFIXO")[1])
    cNumero     := PadR(cNumero     , TamSx3("E5_NUMERO" )[1])
    cParcela    := PadR(cParcela    , TamSx3("E5_PARCELA")[1])
    cTipo       := PadR(cTipo       , TamSx3("E5_TIPO"   )[1])
    cBanco      := PadR(cBanco      , TamSx3("A6_COD"    )[1])
    cAgencia    := PadR(cAgencia    , TamSx3("A6_AGENCIA")[1])
    cConta      := PadR(cConta      , TamSx3("A6_NUMCON" )[1])
    cMotBx      := PadR(cMotBx      , TamSx3("E5_MOTBX"  )[1])

    //Necessário estar posicionado na SA6 no indice 1 por causa da ExecAuto FINA100
    SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
    If SA6->(DbSeek( xFilial("SA6") + cBanco + cAgencia + cConta ))	.Or. SA6->(DbSeek( xFilial("SA6") + cBanco ))
        cBanco	:= SA6->A6_COD
        cAgencia:= SA6->A6_AGENCIA
        cConta  := SA6->A6_NUMCON
    EndIf

    If nOpcao == 3 //3=Recebimento de Título
        cSequencia  := FaNxtSeqBx("SE1")
        cSequencia  := StrZero(Val(cSequencia)-1,nTamSEQ)
    EndIf

    aAdd( aDados, {"E5_DATA"    , dDataMov  , NIL} )
    aAdd( aDados, {"E5_DTDIGIT" , dDataMov  , NIL} )
    aAdd( aDados, {"E5_DTDISPO" , dDataMov  , NIL} )
    aAdd( aDados, {"E5_VALOR"   , nValor    , NIL} )
    aAdd( aDados, {"E5_MOEDA"   , "TC"      , NIL} )
    aAdd( aDados, {"E5_MOTBX"   , cMotBx    , NIL} )
    aAdd( aDados, {"E5_TIPODOC" , cTipoDoc  , NIL} )
    aAdd( aDados, {"E5_BANCO"   , cBanco    , NIL} )
    aAdd( aDados, {"E5_AGENCIA" , cAgencia  , NIL} )
    aAdd( aDados, {"E5_CONTA"   , cConta    , NIL} )
    aAdd( aDados, {"E5_NATUREZ" , cNatureza , NIL} )
    aAdd( aDados, {"E5_HISTOR"  , cHistor   , NIL} )
    aAdd( aDados, {"E5_PREFIXO" , cPrefixo  , NIL} )
    aAdd( aDados, {"E5_NUMERO"  , cNumero   , NIL} )
    aAdd( aDados, {"E5_PARCELA" , cParcela  , NIL} )
    aAdd( aDados, {"E5_TIPO"    , cTipo     , NIL} )
    aAdd( aDados, {"E5_SITUA"   , cSitua    , NIL} )
    aAdd( aDados, {"E5_NUMMOV"  , cNumMov   , NIL} )
    aAdd( aDados, {"E5_SEQ"     , cSequencia, NIL} )

    //Efetua a inclusão do Troco via Rotina Automática FINA100 (Movimentos Bancários)
    MsExecAuto( {|w,x, y| FINA100(w, x, y)}, 0, aDados, nOperacao )
    
    If lMsErroAuto
        cMsgErro:= MostraErro("\")
        cMsgErro := STR0002 + Chr(13) + cMsgErro //"Erro de Inclusao do troco na Rotina Automatica FINA100:"###
        Conout(cMsgErro)
        LjGrvLog(cNumero, cMsgErro, Nil, .T.)
        lRet := .F.
    Else 
        /* A gravação do campo SE5->E5_CLIFOR neste ponto, foi necessária devido, se passada via MsExecAuto para função FINA100(),
        iria efetuar a consulta da informação, a ser gravada no campo E5_CLIFOR, na tabela SA2.
        Desta forma, por se tratar de um registro de troco, entenderia ser uma saída ou pagamento e na função FINA100, 
        realizaria a consulta de forma errada na tabela SA2. 
        */
        If Empty(SE5->E5_LOJA) .AND. !Empty(cLojaCli) .OR. Empty(SE5->E5_CLIFOR) .AND. !Empty(cCliFor)
            RecLock("SE5",.F.)
            SE5->E5_LOJA    := cLojaCli
            SE5->E5_CLIFOR  := cCliFor
		    SE5->(MsUnlock())        
        EndIf    
    EndIf

	//Atualiza a moeda do novo Caixa criado devido ao tratamento de multi-moeda
	If nMoeda > 1
        SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
        If SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
            RecLock("SA6",.F.)
            SA6->A6_MOEDA  := nMoeda
            SA6->(MsUnlock())
        EndIf
	EndIf

    LjGrvLog("", "Fim da funcao de geracao de movimento de troco", aDados)
EndIf

RestArea(aAreaSE5)
RestArea(aAreaSA6)
RestArea(aAreaAtual)

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTrocoExc
Efetua a exclusao ou estorno de movimento financeiro referente ao Troco.

@type       Function
@author     Alberto Deviciente
@since      05/06/2020
@version    12.1.27

@param nRecnoReg, Numérico, Recno do Registro que será excluído ou estornado.
@param nOperacao, Numérico, Operação que deseja realizar (5=Exclusão; 6=Estorno)
@param cMsgErro, Caractere, Mensagem de erro caso ocorra algum problema de execução.

@return lRet, Lógico, Retorna se estornou ou excluiu o movimento de Troco com sucesso (.T.) ou não (.F.)
/*/
//-------------------------------------------------------------------------------------
Function LjTrocoExc(nRecnoReg, nOperacao, cMsgErro)
Local lRet          := .T.
Local aDados        := {}
Local aAreaAtual    := {}
Local aAreaSA6      := {}
Local aAreaSE5      := {}
Local cNumero       := ""
Local aCmpCopy      := {} //Campos da tabela SE5 que terão o conteúdo copiado do registro original

Default nOperacao   := 5
Default cMsgErro    := ""

Private lMsErroAuto := .F.

If nRecnoReg > 1
    LjGrvLog("", "Inicio da funcao de exclusao ou estorno de movimento financeiro referente ao Troco", nRecnoReg)

    aAreaAtual  := GetArea()
    aAreaSA6    := SA6->(GetArea())
    aAreaSE5    := SE5->(GetArea())

    //Posiciona no Registro que será estornado
    DbSelectArea("SE5")
    SE5->(DbGoTo(nRecnoReg))

    If nOperacao == 6 //6=Estorno
        //Campos que terão o conteúdo copiado do registro original
        aCmpCopy := {   { "E5_PREFIXO"  , Nil } ,;
                        { "E5_NUMERO"   , Nil } ,;
                        { "E5_PARCELA"  , Nil } ,;
                        { "E5_CLIFOR"   , Nil } ,;
                        { "E5_LOJA"     , Nil } }

        //Faz a cópia do registro original para gravar no novo registro de estorno que será gerado.
        AEval( aCmpCopy, { |x| x[2] := FieldGet(FieldPos(x[1])) } )
    EndIf
    
    cNumero := SE5->E5_NUMERO

    aAdd( aDados, {"E5_PREFIXO" , SE5->E5_PREFIXO   , NIL} )
    aAdd( aDados, {"E5_NUMERO"  , cNumero           , NIL} )
    aAdd( aDados, {"E5_PARCELA" , SE5->E5_PARCELA   , NIL} )

    //Efetua a Exclusão ou Estorno do Troco via Rotina Automática FINA100 (Movimentos Bancários)
    MsExecAuto( {|w,x, y| FINA100(w, x, y)}, 0, aDados, nOperacao )

    If lMsErroAuto
        cMsgErro:= MostraErro("\")
        cMsgErro := STR0003 + Chr(13) + cMsgErro //"Erro de Exclusao ou Estorno do troco na Rotina Automatica FINA100:"
        Conout(cMsgErro)
        LjGrvLog(cNumero, cMsgErro, Nil, .T.)
        lRet := .F.
    Else
        //-----------------------------------------------------------------------------------
        // Atualiza campos para manter o legado de informações que eram gravadas antes desse 
        // novo processo de gravação de troco pela rotina automática FINA100.
        //-----------------------------------------------------------------------------------
        If nOperacao == 6 .And. Len(aCmpCopy) > 0 //6=Estorno
            DbSelectArea("SE5")
            RecLock("SE5",.F.)
            AEval( aCmpCopy , { |x| FieldPut( FieldPos(x[1]), x[2] ) } )
            SE5->(MsUnlock())
        EndIf
    EndIf

    RestArea(aAreaSE5)
    RestArea(aAreaSA6)
    RestArea(aAreaAtual)

    LjGrvLog("", "Fim da funcao de exclusao ou estorno de movimento financeiro referente ao Troco")
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjNewGrvTC
Verifica se o sistema está atualizado para executar o novo procedimento 
para gravação dos movimentos de troco para gerar registro na tabela FK5.

@type       Function
@author     Alberto Deviciente
@since      05/06/2020
@version    12.1.27

@return lNewGrvTC, Lógico, Retorna .T. se deve utilizar a nova forma de 
                    gravação do troco e .F. se utiliza a forma antiga.
/*/
//-------------------------------------------------------------------------------------
Function LjNewGrvTC()

If lNewGrvTC == Nil
    //Verifica se está com o fonte FINA100 atualizado e verifica se existe o registro "TC" (TROCO) na tabela "06" do SX5
    lNewGrvTC := GetApoInfo("FINA100.PRX")[4] >= Ctod("05/06/2020") .And. GenTabPos("06", "TC")
EndIf

Return lNewGrvTC

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjNxtSecE5
Busca a próxima sequencia com base na chave passada.

@type       Function
@author     Alberto Deviciente
@since      03/07/2020
@version    12.1.27

@param cChave, Caractere, Chave da tabela SE5 a ser considerada na busca.

@return cRet, Caractere, Retorna a próxima sequencia do campo E5_SEQ a ser usada.
/*/
//-------------------------------------------------------------------------------------
Function LjNxtSecE5(cChave)
Local cRet      :=  ""
Local nSequencia:= 0
Local aArea     := GetArea()
Local aAreaSE5  := SE5->(GetArea())

DbSelectArea("SE5")
SE5->(DbSetOrder(2)) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA+E5_CLIFOR+E5_LOJA+E5_SEQ

If SE5->(DbSeek( xFilial("SE5") + cChave ))
    While !SE5->(Eof()) .AND. xFilial("SE5") + cChave == SE5->E5_FILIAL + SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA)
        nSequencia  := Val(SE5->E5_SEQ)
        SE5->(DbSkip())
    End 
EndIf

cRet := StrZero(nSequencia + 1, TamSX3("E5_SEQ")[1])

RestArea(aAreaSE5)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjFilTitRc
Retorna a filial correta quando movimento de recebimento foi realizado entre filiais diferentes (Uso: CTBAFIN).

@type       Function
@author     Evandro Pattaro
@since      13/07/2021
@version    12.1.27

@return cFil, Caractere, Retorna a filial para a busca do título na SE1.
/*/
//-------------------------------------------------------------------------------------
Function LjFilTitRc()
Local cFil := xFilial("SE1")

If AllTrim(SE5->E5_ORIGEM) == 'LOJXREC' .And. SuperGetMV("MV_LJRECFI",,.F. ) .And. SE5->(ColumnPos("E5_MSFIL")) > 0
    cFil := xFilial("SE1",SE5->E5_MSFIL)
EndIf

Return cFil