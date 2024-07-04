#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJI140.CH"
#INCLUDE "FWADAPTEREAI.CH"

CLASS RetailSalesCancelationAdapter
    DATA lOk          as LOGICAL
    DATA cBranch      as CHARACTER
    DATA cNumCancDoc  as CHARACTER
    DATA cMsgName     as CHARACTER
    DATA cError       as CHARACTER
    DATA oRetailSales as OBJECT
    DATA oEaiobjRec   as OBJECT
    DATA oEaiobjSnd   as OBJECT
    DATA oFieldsJson  as OBJECT

    METHOD NEW()

    METHOD GetRetailSales()
    METHOD DeleteRetailSales()
    METHOD CreateQuery()
    METHOD GetFieldsNames()
EndClass

Method New() CLASS RetailSalesCancelationAdapter

    Self:lOk         := .F.
    Self:cError      := ''
    Self:cBranch     := ''
    Self:cNumCancDoc := ''
    Self:cMsgName    := 'RETAILSALESCANCELATION'
    Self:oEaiobjSnd  := FWEAIObj():NEW()
    Self:oEaiObjRec  := FWEAIObj():NEW()
    Self:oFieldsJson := Self:GetFieldsNames()

    //Seta processamento EAI para .T.
    Lj140StInD(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRetailSales
Método para buscar a venda e cancelar a venda
@param Nil
@return Vazio
@author Fabricio Panhan Costa
@since 03/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetRetailSales() CLASS RetailSalesCancelationAdapter

    Local lNext         as LOGICAL
    Local nCount        as NUMERIC
    Local cError        as CHARACTER
    Local cAliasRes     as CHARACTER
    Local aArea         as ARRAY
    Local aAreaSL1      as ARRAY
    local cItem         as CHARACTER
    local nK            as NUMERIC

    aAreaSL1    := SL1->(getArea())
    aArea       := getArea()
    nCount      := 0
    cError      := ''
    cAliasRes   := 'SL1'

    Self:oEaiobjSnd:Activate()
    lNext := .T.
    cAliasRes := Self:CreateQuery()

    If Self:lOk
        If (cAliasRes)->( EOF() )
            Self:lOk := .F.
            Self:oEaiobjSnd:setProp('code','404')
            Self:oEaiobjSnd:setProp('message', STR0040)         //"Venda não encontrada"
            Self:oEaiobjSnd:setProp('detailedMessage', STR0040) //"Venda não encontrada"
            Self:oEaiobjSnd:setProp('helpUrl','')
            Self:oEaiobjSnd:setProp('details')
            Self:oEaiobjSnd:GetPropValue('details'):SetProp('code','')
            Self:oEaiobjSnd:GetPropValue('details'):SetProp('message','')
            Self:oEaiobjSnd:GetPropValue('details'):SetProp('detailedMessage','')
            Self:oEaiobjSnd:GetPropValue('details'):SetProp('helpUrl','')
            Self:cError := STR0040  //"Venda não encontrada"
        Else

            While !(cAliasRes)->(EOF())
            
                nCount++
                nK := 1

                If Empty(cItem)
                    cItem :=  AllTrim((cAliasRes)->L1_FILIAL) + AllTrim((cAliasRes)->L1_FILIAL)
                EndIf

                Self:oEaiobjSnd:setProp('BranchId'              , AllTrim((cAliasRes)->L1_FILIAL))
                Self:oEaiobjSnd:setProp('InternalId'            , AllTrim((cAliasRes)->L1_FILIAL +'|'+ (cAliasRes)->L1_NUM))
                Self:oEaiobjSnd:setProp('RetailSalesInternalId' , AllTrim((cAliasRes)->L1_NUM))
                Self:oEaiobjSnd:setProp('OperatorCode'          , AllTrim((cAliasRes)->L1_OPERADO))
                Self:oEaiobjSnd:setProp('CancelDate'            , DtoS(dDataBase))

                (cAliasRes)->(dbskip())
                If lNext
                    cItem := ''
                    Self:oEaiobjSnd:nextItem()
                Else
                    exit
                EndIf
            EndDo
        EndIf

        /*If nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
            Self:oEaiobjSnd:setHasNext(.T.)
        EndIf*/
        (cAliasRes)->(DBCloseArea())
    EndIf

    restArea(aArea)
    restArea(aAreaSL1)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateQuery
Metodo que monta a query para busca de valores na tabela XXXXX
@param Vazio
@return Vazio
@author Fabricio Panhan Costa
@since 03/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method CreateQuery() CLASS RetailSalesCancelationAdapter
Local lRet         as LOGICAL
Local nX           as NUMERIC
Local cWhere       as CHARACTER
Local cOrder       as CHARACTER
Local cFields      as CHARACTER
Local aTemp        as ARRAY
Local oJsonFilter  as OBJECT
Local cParam       as CHARACTER
Local cInternalID  as CHARACTER
Local cNumCancDoc  as CHARACTER
Local aFiltro      as ARRAY

    lRet := .T.
    cAliasRes := "RetailSalesTmp"
    cWhere := "1=1"
    cParam := ''

    oJsonFilter  := Self:oEaiObjRec:getFilter()
    if !empty(Self:oEaiObjRec:getPathParam('InternalId'))
        cInternalID := Self:oEaiObjRec:getPathParam('InternalId')
        aFiltro := Separa(cInternalID, "|")
        cWhere += " AND L1_FILIAL='" + aFiltro[1] + "' "
        cWhere += " AND L1_NUM='" + aFiltro[2] + "' "
    endif

    if oJsonFilter != Nil
        aTemp := oJsonFilter:getProperties()
        for nX := 1 to len(aTemp)
            if !Empty(Self:oFieldsJson[aTemp[nX]])
                cWhere += 'AND '
                if ValType(oJsonFilter[aTemp[nX]]) != "C"
                    oJsonFilter[aTemp[nX]] := str(oJsonFilter[aTemp[nX]])
                EndIf
                cWhere += Self:oFieldsJson[aTemp[nX]] + '=' + oJsonFilter[aTemp[nX]]
            Else
                Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para filtro' + CRLF
                lRet := .F.
            EndIf
        next nX
    Endif

    aTemp := Self:oEaiObjRec:getOrder()
    cOrder := ''
    for nX := 1 to len(aTemp)
        if nX != 1
            cOrder += ','
        Endif

        if substr(aTemp[nX],1,1) == '-'
            if !empty(Self:oFieldsJson[upper(substr(aTemp[nX],2))])
                cOrder += Self:oFieldsJson[upper(substr(aTemp[nX],2))] + ' desc'
            Else
                Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
                lRet := .F.
            EndIf
        Else
            if !Empty(Self:oFieldsJson[upper(aTemp[nX])])
                cOrder += Self:oFieldsJson[upper(aTemp[nX])]
            Else
                Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
                lRet := .F.
            EndIf
        EndIf
    next nX

    IF Empty(cOrder)
        cOrder := '1'
    EndIf

    if lRet
        Self:lOk := .T.
        cFields := '1'
        aTemp := Self:oFieldsJson:getProperties()
        //atribui propriedades de retorno da consulta de acordo com fields informado na consulta rest. Caso não informe as
        //propriedades de retorno, a query será montada com as propriedades do método GetFieldsNames
        for nX := 1 to len(aTemp)
            cFields += ','
            cFields += Self:oFieldsJson[aTemp[nX]]
        next nX

        cWhere  := '%'+cWhere+'%'
        cOrder  := '%'+cOrder+'%'
        cFields := '%'+cFields+'%'
        BeginSql alias cAliasRes
            SELECT %exp:cFields%
            FROM
                %table:SL1%
            WHERE %exp:cWhere%
            AND D_E_L_E_T_ = ' '
            ORDER BY %exp:cOrder%
        EndSql
    EndIf
Return cAliasRes

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFieldsNames
Método que retorna a estrutura da mensagem em um objeto JSON
@param Vazio
@return nil
@author Fabricio Panhan Costa
@since 03/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFieldsNames() CLASS RetailSalesCancelationAdapter
Local oFieldsJson := JsonObject():New()
    oFieldsJson['BRANCHID']              := 'L1_FILIAL'
    //oFieldsJson['COMPANYINTERNALID']   := cEmpAnt
    //oFieldsJson['INTERNALID']          := 'L1_FILIAL|L1_NUM'
    oFieldsJson['RETAILSALESINTERNALID'] := 'L1_NUM'
    oFieldsJson['OPERATORCODE']          := 'L1_OPERADO'
    oFieldsJson['CANCELDATE']            := 'L1_DATCANC'
    //oFieldsJson['NFCECANCELPROTOCOL']  := 'F3_NFISCAN'
    oFieldsJson['CANCELLATIONDOCUMENT']  := 'L1_DOCCCF'
Return oFieldsJson

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteRetailSales
Método que ira fazer o cancelamento de venda feita no varejo do Protheus via API
@param Vazio
@return lRet se o cancelamento foi realizado com sucesso
@author Fabricio Panhan Costa
@since 03/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method DeleteRetailSales() CLASS RetailSalesCancelationAdapter

Local lRet          := .T.
Local aRetFun       := {.T. , ""}
Local cDateCanc     := DtoS(dDataBase)
Local cTimeCanc     := Time()
Local cInternalId   := Self:oEaiObjRec:getPropValue('InternalId')
Local cBranchId     := Self:oEaiObjRec:getPropValue('BranchId')
Local cRetSIntId    := Self:oEaiObjRec:getPropValue('RetailSalesInternalId')
Local cNumCancDoc   := Self:oEaiObjRec:getPropValue('CancellationDocument')
Local cOperador     := Self:oEaiObjRec:getPropValue('OperatorCode')
Local cProtoNfce    := Self:oEaiObjRec:getPropValue('NfceCancelProtocol')
Local aDadosCup     := {}

Private lAutoExec := .T.

SL1->( dbSetOrder(1) )  //L1_FILIAL+L1_NUM
If !SL1->( dbSeek( PadR(cBranchId, TamSx3("L1_FILIAL")[1]) + cRetSIntId ) )

    aRetFun[1] := .F.
    aRetFun[2] := I18n("Venda #1 não encontrada, na tabela de Orçamentos. (SL1)", {cRetSIntId})
Else

    //Armazena informacoes do pedido
    If SL1->L1_SITUA == "FR"
        aAdd(aDadosCup, SL1->L1_SERPED)
        aAdd(aDadosCup, SL1->L1_DOCPED)
        aAdd(aDadosCup, SL1->L1_SERPED)

    //Armazena informacoes do cupom
    Else
        aAdd(aDadosCup, SL1->L1_SERIE)
        aAdd(aDadosCup, SL1->L1_DOC  )
        aAdd(aDadosCup, SL1->L1_PDV  )
    EndIf

    aAdd(aDadosCup, SL1->L1_NUM     )
    aAdd(aDadosCup, cOperador       )
    aAdd(aDadosCup, cTimeCanc       )
    aAdd(aDadosCup, SToD(cDateCanc) )

    Begin Transaction

        //Exclui Venda
        aRetFun := Lji140ExVe(cInternalId, cNumCancDoc, cProtoNfce, aDadosCup)

        If !aRetFun[1]
            DisarmTransaction()
        EndIf

    End Transaction
EndIf

If aRetFun[1]
    Self:lOk := .T.
Else
    Self:oEaiObjRec:setError(aRetFun[2])
    Self:lOk     := .F.
    Self:cError  := cValToChar(aRetFun[2])
    oRetailSales := Self
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJI140O
Funcao de integracao com o adapter EAI para recebimento e
envio de informações de cancelamento de vendas (RETAILSALESCANCELLATION)
utilizando o conceito de mensagem unica com Objeto EAI.
@type function
@param Caracter, cMsgRet, Variavel com conteudo para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author rafael.pessoa
@version P12
@since 19/09/2018
@return Array, Array contendo o resultado da execucao e a mensagem de retorno.
        aRet[1] - (boolean) Indica o resultado da execução da função
        aRet[2] - (caracter) Mensagem para envio
/*/
//-------------------------------------------------------------------
Function LOJI140O( oEAIObEt, nTypeTrans, cTypeMessage )
Local lRet        := .T.       //Indica o resultado da execução da função
Local cRet        := ''        //retorno será enviado pela função
Local cError      := ''        //Mensagem de erro do parse no recebido como parâmetro
Local aRet        := {.T.,""}  //Array de retorno da execucao da versao

Default oEAIObEt     := Nil
Default nTypeTrans   := 3
Default cTypeMessage := ""

LjGrvLog("LOJI140O","ID_INICIO")

If ( nTypeTrans == TRANS_RECEIVE ) .And. oEAIObEt <> Nil
    If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )
        If !Empty(oEAIObEt:getHeaderValue("Version"))
            cVersao := StrTokArr(oEAIObEt:getHeaderValue("Version"), ".")[1]

            If cVersao == "1"
                aRet := v1000(oEAIObEt, nTypeTrans, cTypeMessage )
            Else
                lRet := .F.
                cRet := STR0003 //#"A versao da mensagem informada nao foi implementada!"
                aRet := { lRet , cRet }
            EndIf
        Else
            lRet := .F.
            cRet := STR0002 //#"Versao da mensagem nao informada!"
            aRet := { lRet , cRet }
        EndIf

    ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
        cRet := "1.000|1.001|1.002"
        aRet := { lRet , cRet }
        return {aRet[1], aRet[2],"RETAILSALESCANCELLATION","JSON"}
    EndIf
Else
    lRet := .F.
    cRet := STR0007 + " " + AllTrim(cIdExt) //#"Erro no cancelamento do cupom"
    aRet := { lRet , cRet }
EndIf

LjGrvLog("LOJI140O","ID_FIM")

Return {aRet[1], aRet[2],"RETAILSALESCANCELLATION"}


//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
 Funcao de integracao com o adapter EAI para recebimento e envio de informações de Cancelamento de vendas
utilizando o conceito de mensagem unica. para Versão 1.000
@type function
@param Caracter, cMsgRet, Variavel com conteudo para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author rafael.pessoa
@version P12
@since 19/09/2018
@return Array, Array contendo o resultado da execucao e a mensagem de retorno.
        aRet[1] - (boolean) Indica o resultado da execução da função
        aRet[2] - (caracter) Mensagem para envio
/*/
//-------------------------------------------------------------------
Static Function v1000( oEAIObEt, nTypeTrans, cTypeMessage )
Local aArea       := GetArea()
Local cMarca      := "" //Armazena a Marca que enviou o
Local cValInt     := "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
Local cIdExt      := "" //Identificacao externa do registro
Local cOperador   := "" //Codigo do Operador
Local cDocExt     := "" //Codigo da Venda Integrada
Local cDateCanc   := "" //Data do cancelamento
Local cTimeCanc   := "" //Hora do cancelamento
Local cTimeAux    := "" //Hora auxiliar
Local cProtoNfce  := "" //Protocolo de cancelamento NFCe
Local cMunEst     := "" //Municipio NFSe
Local nI          := 0  //Contador
Local nHoras      := 0  //Horas NFe
Local nTamDoc     := TamSx3("L1_DOC")[1] //Tamanho do campo do Documento
Local nTamSer     := TamSx3("L1_SERIE")[1] //Tamanho da Serie do Cupom Fiscal
Local nTamPdv     := TamSx3("L1_PDV")[1] //Tamanho do PDV
Local nSpedExc    := SuperGetMV("MV_SPEDEXC",,72) //Indica a quantidade de horas q a NFe pode ser cancelada
Local nExcNfs     := SuperGetMv("MV_EXCNFS",, 180)
Local nTpPrz      := SuperGetMv("MV_TIPOPRZ",, 1) //Tipo de Prazo para exclusão das NF de serviço
Local nPosMunic   := 0 //Municipios RPS
Local dDataR      := dDataBase //Data para validacao RPS
Local aAreas      := {} //Array com areas das tabelas
Local aAux        := {} //Array Auxiliar para armazenar Internald
Local aIntVenda   := {} //Array com informacoes da Venda
Local aMunic      := {} //Municipios NFSe
Local aCaixa      := {} //Array com as inforações do De/Para do Protheus.
Local cNumCancDoc := "" //Numero do documento de cancelamento
Local ofwEAIObj   := FWEAIobj():NEW()    // Objeto EAI
Local cMsgRet     := ""
Local lRet        := .T.
Local aInternal   := {}
Local aRetFun     := {}
Local aDadosCup   := {}

Default oEAIObEt     := Nil
Default nTypeTrans   := 0
Default cTypeMessage := ""

//Armazena areas das Tabelas
aAdd(aAreas, SL1->(GetArea()))
aAdd(aAreas, SLX->(GetArea()))
aAdd(aAreas, SLG->(GetArea()))

LjGrvLog("LOJI140","ID_INICIO")

//Mensagem de Recebimento
If nTypeTrans == TRANS_RECEIVE

    LjGrvLog("LOJI140","UUID: " + AllTrim(oEAIObEt:getHeaderValue("UUID")))

    //Marca
    If oEAIObEt:getHeaderValue("ProductName") != Nil .And. !Empty(oEAIObEt:getHeaderValue("ProductName"))
        cMarca := AllTrim(oEAIObEt:getHeaderValue("ProductName"))
    Else
        lRet     := .F.
        cMsgRet := STR0004 //#"Marca nao integrada ao Protheus, verificar a marca da integracao"
    EndIf

    If lRet

        If ( oEAIObEt:getPropValue("InternalId") ) != Nil
            cIdExt := ( oEAIObEt:getPropValue("InternalId") )
        EndIf

        If ( oEAIObEt:getPropValue("RetailSalesInternalId") )  != Nil
            cDocExt := ( oEAIObEt:getPropValue("RetailSalesInternalId") )//Numero do Cupom
        EndIf

        //Verifica se o InternalId do Cupom foi informado
        If Empty(cDocExt)
            lRet     := .F.
            cMsgRet := STR0005 //#"InternalId vazio, informacao obrigatoria, verifique a tag RetailSalesInternalId."
        Else
            aIntVenda := IntVendInt(cDocExt, cMarca)
        EndIf
    EndIf

    If lRet

        If ValType(aIntVenda) == "A" .And. Len(aIntVenda) > 0 .And. aIntVenda[1]
        
            //Valida se a venda existe
            SL1->( dbSetOrder(2) )          //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
            If !SL1->( dbSeek(xFilial("SL1") + Padr(aIntVenda[2][3], nTamSer) + Padr(aIntVenda[2][4], nTamDoc) + Padr(aIntVenda[2][5], nTamPdv)) )

                //Valida se a venda entrega existe
                SL1->( dbSetOrder(11) )     //L1_FILIAL+L1_SERPED+L1_DOCPED
                If !SL1->( dbSeek(xFilial("SL1") + Padr(aIntVenda[2][3], nTamSer) + Padr(aIntVenda[2][4], nTamDoc)) )
                    lRet    := .F.
                    cMsgRet := STR0026 + " " + AllTrim(cDocExt) + " " + STR0027     //#"Venda: ##"nao integrada ao Protheus, verificar integracao de Vendas"
                EndIf
            EndIf

            If lRet

                //Valida situação da venda
                aAux    := VldSitua(SL1->L1_FILIAL, SL1->L1_NUM, SL1->L1_SITUA)
                lRet    := aAux[1]
                cMsgRet := aAux[2]
            EndIf

        Else
            lRet    := .F.
            cMsgRet := STR0026 + " " + AllTrim(cDocExt) + " " + STR0027 //#"Venda: ##"nao integrada ao Protheus, verificar integracao de Vendas"
        EndIf
    EndIf

    If lRet

        //Verifica se cancelamento ja existe
        aAux := IntCancInt(cIdExt, cMarca)

        If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
            lRet    := .F.
            cMsgRet := STR0022 + " " + AllTrim(cIdExt) + " " + STR0013  //#"Cancelamento:" ##" ja integrado ao Protheus"
        EndIf

        If lRet

            //Armazena Operador
            If ( oEAIObEt:getPropValue("OperatorCode") ) != Nil
                cOperador := ( oEAIObEt:getPropValue("OperatorCode") )
            EndIf

            //Valida Operador
            If Empty(cOperador)
                lRet     := .F.
                cMsgRet := STR0015  //#"Operador nao informado na integracao, verifique a Tag OperatorCode"
            EndIf

            //------------------------------------------------------------
            //Tratamento utilizando a tabela XXF com um De/Para de codigos
            //Necessário enquanto não for concluído o Adapter para Msg
            //Unica para cadastro dos caixas.
            //------------------------------------------------------------
            aCaixa := Separa(CFGA070Int(cMarca, "SLF", "LF_COD", cOperador),"|")

            If lRet .and. Len(aCaixa) >= 3

                cOperador := aCaixa[3]

                //Posiciona no Operador do Protheus
                SLF->(dbSetOrder(1))
                If Empty(cOperador) .Or. !SLF->(dbSeek(xFilial("SLF") + cOperador))
                    lRet     := .F.
                    cMsgRet := STR0016 + " " + cOperador + " " + STR0017 //"#Operador:" ##"nao integrado ao Protheus, verificar o cadastro de operador."
                EndIf
            Else
                lRet     := .F.
                cMsgRet := STR0016 + " " + cOperador + STR0023 + CFGA070Int(cMarca, "SLF", "LF_COD", cOperador) + ". " + "verificar se o operador esta cadastrado na filial destino correta"  //#"Operador:" ##"nao encontrado no De/Para " " verificar se o operador esta cadastrado na filial destino correta.
            EndIf
        EndIf
    EndIf

    If lRet
        //Verifica campos obrigatorios
        If Empty(cIdExt)
            lRet    := .F.
            cMsgRet := STR0018 //#"Campo obrigatorio nao informado: Id Interno, verifique a tag: InternalId."
        ElseIf Empty(LjiOVldTag(oEAIObEt, "CancelDate") )
            lRet    := .F.
            cMsgRet := STR0019 //#"Campo obrigatorio nao informado: Data do Cancelamento, verifique a tag: CancelDate."
        EndIf

        cProtoNfce  := LjiOVldTag(oEAIObEt, "NfceCancelProtocol")
        cDateCanc   := LjiOVldTag(oEAIObEt, "CancelDate", "D")
        cTimeCanc   := LjiOVldTag(oEAIObEt, "CancelDate", "T")
        cNumCancDoc := LjiOVldTag(oEAIObEt, "CancellationDocument")

        //Validacao para evitar registro duplicado quando existem cancelamentos de itens
        //na venda que esta sendo cancelada
        If !Empty(cTimeCanc)
            SLX->(dbSetOrder(1))

            If SLX->(dbSeek(xFilial("SLX") + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE))
                While SLX->(!EOF()) .And. SLX->LX_FILIAL == xFilial("SLX") .And. SLX->LX_PDV == SL1->L1_PDV .And.;
                    SLX->LX_CUPOM == SL1->L1_DOC .And. SLX->LX_SERIE == SL1->L1_SERIE

                    If SLX->LX_HORA == Subs(cTimeCanc, 1, 5)
                        //Incrementa 1 minuto na hora de cancelamento para evitar duplicidade
                        cTimeAux  := cTimeCanc
                        cTimeCanc := Subs(cTimeAux, 1, 2)
                        cTimeCanc += ":"

                        //Se minutos inferior a 59, incrementa minuto
                        If Val(Subs(cTimeAux, 4, 2)) < 59
                            cTimeCanc += PadL(CValToChar(Val(Subs(cTimeAux, 4, 2)) + 1), 2, "0")
                        Else //Se minutos igual a 59, decrementa minuto
                            cTimeCanc += PadL(CValToChar(Val(Subs(cTimeAux, 4, 2)) - 1), 2, "0")
                        EndIf

                        Exit
                    EndIf

                    SLX->(dbSkip())
                EndDo
            EndIf
        EndIf

        //Verifica se eh uma notafiscal eletronica , pois neste caso deve respeitar o
        //parametro MV_SPEDEXC que indica o numero de horas que a Nfe pode ser excluidas
        SF2->(dbSetOrder(1))

        If SF2->(dbSeek(xFilial("SF2") + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA))
            //Verifica se eh uma notafiscal eletronica , pois neste caso deve respeitar o
            //parametro MV_SPEDEXC que indica o numero de horas que a Nfe pode ser excluidas
            If AllTrim(SF2->F2_ESPECIE) == "SPED" .And. SF2->F2_FIMP $ "TS" //verificacao apenas da especie como SPED e notas que foram transmitidas ou impressao DANFE
                If !Empty(SF2->F2_CODNFE) .Or. !Empty(SF2->F2_CHVNFE)
                    nHoras := SubtHoras(SF2->F2_EMISSAO, SF2->F2_HORA, dDataBase, SubStr(Time(), 1, 2) + ":" + SubStr(Time(), 4, 2))

                    If nHoras > nSpedExc
                        lRet := .F.
                        cMsgRet := STR0024 + " " + CValToChar(nSpedExc) + " " + STR0025 //#"Nao foi possivel excluir a nota, pois o prazo para o cancelamento da NF-e e de:" ##"horas"
                    EndIf
                ElseIf Month(SF2->F2_EMISSAO) <> Month(dDataBase) .OR. Year(SF2->F2_EMISSAO) <> Year(dDataBase)
                    lRet := .F.
                    cMsgRet := STR0030 //"Nao se pode excluir uma nota fiscal quando o mes ou ano de sua emissao for diferente da database do sistema."
                EndIf
            ElseIf AllTrim(SF2->F2_ESPECIE) == "RPS" //Validacoes RPS - Regras assimiladas do fonte Mata521 - MaCanDelF2()
                aAdd(aMunic,{"SP","São Bernardo do Campo","3548708"})
                aAdd(aMunic,{"AL","Maceió","2704302"})
                aAdd(aMunic,{"CE","Fortaleza","2304400"})
                aAdd(aMunic,{"RN","Natal","2408102"})
                aAdd(aMunic,{"SP","São Paulo","3550308"})
                aAdd(aMunic,{"BA","Salvador","2927408"})
                aAdd(aMunic,{"PR","Londrina","4113700"})
                aAdd(aMunic,{"GO","Goiânia","5208707"})
                aAdd(aMunic,{"PE","Recife","2611606"})
                aAdd(aMunic,{"PI","Teresina","2211001"})
                aAdd(aMunic,{"RS","Porto Alegre","4314902"})
                aAdd(aMunic,{"PA","Parauapebas","1505536"})
                aAdd(aMunic,{"MG","Belo Horizonte","3106200"})
                aAdd(aMunic,{"SP","Guarulhos","3518800"})
                aAdd(aMunic,{"MS","Campo Grande","5002704"})
                aAdd(aMunic,{"DF","Brasília","5300108"})
                aAdd(aMunic,{"RJ","Rio de Janeiro","3304557"})
                aAdd(aMunic,{"AL","Rio Largo","2707701"})
                aAdd(aMunic,{"RO","Porto Velho","1100205"})
                aAdd(aMunic,{"SE","Aracaju","2800308"})

                //Valida os parametros pois eles nao sao utilizados para Salvador
                If AllTrim(SM0->M0_CODMUN) == aMunic[aScan(aMunic, {|x| Alltrim(x[2]) == "Salvador"}), 3]
                    //Informa os valores padroes
                    nExcNfs := 180
                    nTpPrz := 1
                EndIf

                //Municipios que possuem validacao
                nPosMunic := aScan(aMunic, {|x| Alltrim(x[3]) == AllTrim(SM0->M0_CODMUN)})

                If nPosMunic > 0
                    cMunEst := aMunic[nPosMunic, 2] + " - " + aMunic[nPosMunic, 1]

                    If nTpPrz == 1 //Ate dia XX do mes subsequente
                        dDataR := CTOD("01/" + StrZero(Month(SF2->F2_EMISSAO), 2) + Str(Year(SF2->F2_EMISSAO)), "DD/MM/YYYY")
                        dDataR := UltDia(StrZero(Month(dDataR), 2), StrZero(Year(dDataR), 4)) + nExcNfs

                        //Valida data RPS
                        If dDataBase > dDataR
                            lRet := .F.
                            cMsgRet := STR0033 + " " + cMunEst + " " + STR0034 + " " + CValToChar(nExcNfs) //"O prazo para exclusao de NF de servico para o municipio de" #"é de até"
                            cMsgRet += " " + STR0035 + "," + STR0036 + ":" + DtOC(dDataR) //"do mes subsequente da emissao" #"data limite"
                        EndIf
                    ElseIf nTpPrz == 2 //XX dias apos emissao
                        dDataR := SF2->F2_EMISSAO + nExcNfs

                        //Valida data RPS
                        If dDataBase > dDataR
                            lRet := .F.
                            cMsgRet := STR0033 + " " + cMunEst + " " + STR0034 + " " + CValToChar(nExcNfs) //"O prazo para exclusao de NF de servico para o municipio de" #"é de até"
                            cMsgRet += " " + STR0037 + "," + STR0036 + ":" + DtOC(dDataR)  //"dias a partir da sua emissao" #"data limite"
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    If lRet

        //Armazena informacoes do pedido
        If SL1->L1_SITUA == "FR"
            aAdd(aDadosCup, SL1->L1_SERPED)
            aAdd(aDadosCup, SL1->L1_DOCPED)
            aAdd(aDadosCup, SL1->L1_SERPED)

        //Armazena informacoes do cupom
        Else
            aAdd(aDadosCup, SL1->L1_SERIE)
            aAdd(aDadosCup, SL1->L1_DOC  )
            aAdd(aDadosCup, SL1->L1_PDV  )
        EndIf

        aAdd(aDadosCup, SL1->L1_NUM     )
        aAdd(aDadosCup, cOperador       )
        aAdd(aDadosCup, cTimeCanc       )
        aAdd(aDadosCup, SToD(cDateCanc) )

        Begin Transaction

            //Exclui Venda
            aRetFun := Lji140ExVe(cIdExt, cNumCancDoc, cProtoNfce, aDadosCup)

            If aRetFun[1]

                //Gera InternalId do Protheus
                aInternal := IntCancExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV)

                //Gera InternalId do Protheus
                If aInternal[1]
                    cValInt := aInternal[2]
                EndIf

                //Adiciona item no De/Para - XXF
                If CFGA070Mnt(cMarca, "SLX", "LX_CUPOM", cIdExt, cValInt)
                    //Identificacao Interna da Venda
                    cDocInt := IntVendExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV, /*Versao*/)[2]
                    //Remove a venda do De/Para - XXF
                    CFGA070Mnt(cMarca, "SL1", "L1_DOC", cDocExt, cDocInt, .T.)
                EndIf
            Else
                
                DisarmTransaction()

                lRet    := .F.
                cMsgRet += aRetFun[2]
            EndIf

        End Transaction

    EndIf
    ofwEAIObj:Activate()
    ofwEAIObj:setProp("ReturnContent")

    If lRet
        ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID")
        ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID"):setProp("InternalID")
        ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID"):getPropValue("InternalID"):setProp("Name", "RETAILSALESCANCELLATION")
        ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID"):getPropValue("InternalID"):setProp("Origin", cIdExt)
        ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID"):getPropValue("InternalID"):setProp("Destination", cValInt)
    Else
        ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet)
    EndIf

ElseIf nTypeTrans == TRANS_SEND
    lRet    := .F.
    cMsgRet := STR0007 + " " + AllTrim(cIdExt) //#"Erro no cancelamento do cupom: "
EndIf

//Restaura areas
For nI := 1 To Len(aAreas)
    RestArea(aAreas[nI])
Next nI

RestArea(aArea)
LjGrvLog("LOJI140O","ID_FIM")

Return {lRet, ofwEAIObj, "RETAILSALESCANCELLATION"}

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSitua
Função para efetuar validação da situação da Venda - L1_SITUA
SL1 já esta poscicionado.

@param   cFilOrc - Filial do orçamento
@param   cNumOrc - Número do orlçamento
@return  {lRet, cMsgRet}

@author  Rafael Tenorio da Costa
@since   03/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldSitua(cFilOrc, cNumOrc)

    Local aArea     := GetArea()
    Local aAreaSL1  := SL1->( GetArea() )
    Local lRet      := .T.
    Local cMsgRet   := ""
    Local nControle := 1                    //Controle para saida do While

    //Valida L1_SITUA permitidos
    If !( SL1->L1_SITUA $ "OK|FR" ) 

        //Aguarda Execucao do GravaBatch no maximo 5 tentativas
        While !( SL1->L1_SITUA $ "OK|FR" ) .And. nControle <= 5

            //Se venda ainda nao foi gerada, aguarda 5 segundos para GravaBatch executar
            Sleep(5000)

            //Posiciona novamente pois GravaBatch pode ter disposicionado
            SL1->( DbSetOrder(1) )  //L1_FILIAL+L1_NUM
            SL1->( DbSeek(cFilOrc + cNumOrc) )
            nControle++
        EndDo

        //Se apos 5 tentativas a venda nao foi gerada, recusa para verificar
        If !( SL1->L1_SITUA $ "OK|FR" )
            lRet    := .F.
            cMsgRet := I18n(STR0041, {cFilOrc, cNumOrc, SL1->L1_SITUA})    //"Situação da Venda não permite cancelamento. (L1_FILIAL=#1, L1_NUM=#2, L1_SITUA=#3)"
        EndIf

    //Valida pedido
    ElseIf SL1->L1_SITUA == "FR"

        If !Empty( Posicione("SL1", 14, cFilOrc + cNumOrc, "L1_DOC") )    //L1_FILIAL+L1_ORCRES
            lRet    := .F.
            cMsgRet := STR0042  //"Pedido já foi faturado, deve ser feito processo de devolução manual pelo Protheus."
        EndIf
    EndIf

    RestArea(aAreaSL1)
    RestArea(aArea)

Return {lRet, cMsgRet}
