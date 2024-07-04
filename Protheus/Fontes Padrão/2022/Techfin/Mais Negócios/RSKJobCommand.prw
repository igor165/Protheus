#INCLUDE "Protheus.ch"
#INCLUDE "RSKDefs.ch"
#INCLUDE "RSKJobCommand.ch"  

#DEFINE INVOICE_INSTALLMENT      1   // Parcelas da Invoice 
#DEFINE PURCHASE_LIMIT           2   // Limites do cliente

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobCommand
Função chamada pelo Schedule para execução das rotinas de atualização entre a base 
Protheus e as informações da Plataforma.

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada por
User Function
@param lConciliation, logical, variável que define a execução do Schedule RSKJobBank.
@param nOriginSched, numeric, define a origem da chamada dos Schedule apartados.
    Opções:
    SCHEDULE_JOBCOMMAND     - RSKJobCommand     [0]
    SCHEDULE_JOBBANK        - RSKJobBank        [1]
    SCHEDULE_JOBPOST        - RSKJobPost        [2]
    SCHEDULE_JOBGETMOVEMENT - RSKJobGetMovement [3]
    SCHEDULE_JOBGETRECORDS  - RSKJobGetRecords  [4]
@param cLock, caracter, define qual o codigo que sera usado no Lock do Schedule.
@param aEntityList, array, vetor com as rotinas que serão executadas pelos Schedule apartados.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Marcia Junko
@since   22/05/2020
/*/
//-------------------------------------------------------------------
Function RSKJobCommand( aParam, cFil, lConciliation, nOriginSched, cLock ,aEntityList, lAutomato )
    Local nType         := 0
    Local cHost         := ''
    Local lJob          := .F.
    Local lRskNTkt      := .T.  //Geração\cancelamento de ticket de crédito automática após liberação de pedidos.
    Local cMessage      := ""
    Local aJobCmdInf    := {}
    Local lSplitSched   := .F.
    Local lProcessOk    := .T.
     
    Default aParam := nil 
    Default cFil := NIL
    Default lConciliation := .F.
    Default nOriginSched  := SCHEDULE_JOBCOMMAND      // 0=RSKJobCommand
    Default cLock         := "RSKJobCommand"
    Default aEntityList   := {}
    Default lAutomato := .F.

    If nOriginSched <= SCHEDULE_JOBBANK // Se for RSKJobCommand ou JobBank faço o login no ambiente
        lJob := RskProcJob( aParam, cFil )
    EndIF

    //--------------------------------------------------------------------------------
    // Verifica a forma de como executar os Schedules, de acordo com o parâmetro 
    // MV_RSKSPLS,1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records
    //--------------------------------------------------------------------------------
    lSplitSched := IIF(SuperGetMv( "MV_RSKSPLS", .F., 1 ) == 1, .F., .T.)
    If (lSplitSched .And. nOriginSched == SCHEDULE_JOBCOMMAND) .Or. ( .Not. lSplitSched .And. nOriginSched > SCHEDULE_JOBBANK)    // 0=RSKJobCommand ### 1=RskJobBank
        lProcessOk := .F.
    EndIf

    If RskIsActive() .And. lProcessOk 
        aJobCmdInf  := GetAPOInfo( "RSKJobCommand.prw" )
        
        LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0038, {cLock, cEmpAnt, cFilAnt} )) //" ****** Iniciando #1 Empresa: #2 Filial: #3 ******"
        If Len( aJobCmdInf ) == 5
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0039, {cLock, dToc(aJobCmdInf[4]), aJobCmdInf[5]} ) ) //" ****** #1 Version #2 #3 ******"
        EndIf      

        //--------------------------------------------------------------------------------
        // Cria uma thread separada para rodar as rotinas que precisam ser executadas por 
        // filial, devido o processamento entre o Protheus e a Plataforma
        //--------------------------------------------------------------------------------
        If nOriginSched == SCHEDULE_JOBCOMMAND .Or. nOriginSched == SCHEDULE_JOBPOST    // 0=RSKJobCommand ### 1=RskJobPost
            RskJobFil( aParam, cFil, lAutomato )  
        EndIf

        If nOriginSched <> SCHEDULE_JOBPOST      // 1=RskJobPost
            //--------------------------------------------------------------------------------
            // Efetua a trava para efetuar apenas um processamento por empresa
            //--------------------------------------------------------------------------------
            If LockByName( cLock, .T., .F. )       
                cHost   := GetRSKPlatform()   //Host Plataforma Risk

                If !lConciliation
                    lRskNTkt := SuperGetMv( "MV_RSKNTKT", .F., .T. ) 
                
                    If Len(aEntityList) == 0
                        If lRskNTkt   
                            //------------------------------------------------------------------------------
                            // Cria novos tickets de forma automática
                            //------------------------------------------------------------------------------
                            aAdd( aEntityList, NEWTICKET )      // 1=Criação de novo ticket
                        EndIf 

                        //------------------------------------------------------------------------------
                        // Atualiza as informações do ticket de acordo com o retorno da plataforma
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, UPDTICKET )          // 2=Atualiza ticket

                                
                        //------------------------------------------------------------------------------
                        // Atualiza as informações da NFS Mais Negócios de acordo com a plataforma
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, UPDARINVOICE )       // 3=Atualiza fatura

                        //------------------------------------------------------------------------------
                        // Atualização dos dados do pós-faturamento de acordo com o Antecipa
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, AFTERSALES  )        // 4=Pos venda
                                    
                        //------------------------------------------------------------------------------
                        // Executa a atualização dos pedidos de concessão
                        //------------------------------------------------------------------------------
                        If AliasInDic( "AR5" ) .And. AR5->( ColumnPos( "AR5_RCOUNT" ) ) > 0
                            aAdd( aEntityList, CONCESSION )     // 5=Concessão
                        EndIf

                        //------------------------------------------------------------------------------
                        // Executa o cancelamento de NFS Mais Negocios  
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, NFSCANCEL )          // 7=Cancelamento de NFS Mais Negócios

                        //------------------------------------------------------------------------------
                        // Atualiza a posição dos clientes
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, CLIENTPOSITION )     // 10=Posição do Cliente     

                        //------------------------------------------------------------------------------
                        // Monitora as tentativa de Cancelamento de NFS Mais Negócios
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, MONITCANCEL )        // 11=Tentativa de Cancelamento de NFS Mais Negócios
                    EndIf

                    For nType := 1 To Len( aEntityList )                      
                        cMessage := ""
                        If aEntityList[ nType ] == AFTERSALES   // 4=Pos vemda
                            cHost :=  RSKURLAntecipa()     
                        EndIf
                        
                        Do Case 
                            Case aEntityList[ nType ] == NEWTICKET         // 1=Criação de novo ticket
                                cMessage := STR0018 //"Executando o processo => Processamento do Ticket de Credito"
                            Case aEntityList[ nType ] == UPDTICKET         // 2=Atualiza ticket
                                cMessage := STR0019 //"Executando o processo => Atualizacao de Ticket de Credito / Liberacao de Pedidos"
                            Case aEntityList[ nType ] == UPDARINVOICE      // 3=Atualiza fatura
                                cMessage := STR0020 //"Executando o processo => Processamento da NFS Mais Negocios"
                            Case aEntityList[ nType ] == AFTERSALES        // 4=Pos vemda
                                cMessage := STR0021 //"Executando o processo => Processamento do Pos-Faturamento"
                            Case aEntityList[ nType ] == CONCESSION        // 5=Concessão
                                cMessage := STR0022 //"Executando o processo => Atualizacao da Concessao de Credito"
                            Case aEntityList[ nType ] == NFSCANCEL         // 7=Cancelamento de NFS Mais Negócios
                                cMessage := STR0024 //"Executando o processo => Cancelamento de NFS Mais Negocios"  
                            Case aEntityList[ nType ] == CLIENTPOSITION    // 10=Posição do Cliente     
                                cMessage := STR0035 //"Executando o processo => Atualizando posição dos clientes" 
                            Case aEntityList[ nType ] == MONITCANCEL       // 11=Tentativa de Cancelamento de NFS Mais Negócios
                                cMessage := STR0037 //"Executando o processo => Processamento do Cancelamento de NFS Mais Negocios"
                        EndCase  
                        
                        LogMsg( "RSKJobCommand", 23, 6, 1, "", "", cMessage + I18N( STR0027, { cEmpAnt, cFilAnt } ))  //" Empresa: #1 Filial: #2"  

                        //--------------------------------------------------------------
                        // Executa a rotina de acordo com o tipo
                        //--------------------------------------------------------------     
                        RSKUpdEntity( cHost, aEntityList[ nType ], lAutomato ) 
                    Next                                     
                Else                
                    LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0028, { cEmpAnt, cFilAnt } )) //"Executando o processo => Processamento da Conciliacao Financeira Empresa: #1 Filial: #2" 

                    //--------------------------------------------------------------
                    // Executa a rotina de conciliação
                    //--------------------------------------------------------------     
                    RSKUpdEntity( cHost, CONCILIATION, lAutomato )      // 9=Conciliação                    
                Endif              
                UnLockByName( cLock, .T., .F. )
            Else
                LogMsg( "RSKJobCommand", 23, 6, 1, "", "", STR0001 )    //"Job já está em execução por outra instância" 
            EndIf        
        EndIf
        LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0040, {cLock, cEmpAnt, cFilAnt} ))   //"Fim #1 Empresa: #2 Filial: #3"
    EndIf
    
    If nOriginSched <= SCHEDULE_JOBBANK // Se for RSKJobCommand ou JobBank reset do ambiente
        If lJob .And. !lAutomato  
            RPCClearEnv()        
        EndIF
    EndIf

    FWFreeArray( aEntityList )
    FWFreeArray( aJobCmdInf )
    FWFreeArray( aParam )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKUpdEntity
Função chamada pelo Schedule para execução das rotinas de atualização entre a base 
Protheus e as informações da Plataforma.

@param cHost, caracter, endereço onde está a plataforma
@param nType, number, identifica qual a entidade está semdo executada. Sendo:
    1 - Criação de Tickets
    2 - Ticket
    3 - Faturamento
    4 - Pos Venda
    5 - Concessão de Credito
    6 - Requisições da plataforma
    7 - Cancelamento de NFS Mais Negócios
    9 - Conciliação
    10 - Posição do cliente
    11 - Tentativa de Cancelamento de NFS Mais Negócios
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Marcia Junko
@since   22/05/2020
/*/
//-------------------------------------------------------------------
Static Function RSKUpdEntity( cHost, nType, lAutomato )
    Local aRecords := {}
    Local aItemsByBranch := {}
    Local nRec := 0

    Default lAutomato := .F.

    //------------------------------------------------------------------------------
    // Lista de registros por operação
    //------------------------------------------------------------------------------
    aRecords := GetRSKItems( cHost, nType, lAutomato )     
    
    If !Empty( aRecords )
        //------------------------------------------------------------------------------
        // Separa os registros por filial
        //------------------------------------------------------------------------------
        aItemsByBranch := RSKRecbyBranch( nType, aRecords ) 
        If !Empty( aItemsByBranch )
            For nRec := 1 to Len( aItemsByBranch )
                //------------------------------------------------------------------------------
                // Executa as rotinas para os registros de acordo com a operação
                //------------------------------------------------------------------------------
                RSKAction( nType, cHost, aItemsByBranch[ nRec ], lAutomato )
            Next  
        EndIf
    EndIf

    FWFreeArray( aRecords )
    FWFreeArray( aItemsByBranch )
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRSKItems
Extrator central de todas as dimensões e fatos para o TOTVS KPI.
Esta função deverá ser chamada via Protheus Scheduler

@param cHost, caracter, endereço onde está a plataforma
@param nEntity, number, define qual a entidade está sendo pesquisada
    1 - Criação de Tickets
    2 - Ticket
    3 - Faturamento
    4 - Pos Venda
    5 - Concessão de Credito
    6 - Requisições da plataforma
    7 - Cancelamento de NFS Mais Negócios
    9 - Conciliação
    10 - Posição do cliente
    11 - Tentativa de Cancelamento de NFS Mais Negócios
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, dados retornados pela plataforma, dependendo do tipo 
    1 = Criação de tickets
        [1] - filial
        [2] - pedido
        [3] - cliente
        [4] - loja
        [5] - sequencia
    2 = Atualização de ticket
        [1] - filial
        [2] - numero do ticket
        [3] - status
        [4] - motivo da reprovação
        [5] - id do ticket
        [6] - observação
        [7] - ID da linha de crédito
        [8] - data da avaliação de crédito pela plataforma
        [9] - código de pré-autorização
        [10] - Faturado Parcial ou Total ( 1=Parcial e 2=Total )
        [11] - saldo do ticket
    3 = Faturamento
        [1] - filial
        [2] - numero do documento
        [3] - id da fatura
        [4] - codigo do retorno
        [5] - mensagem do retorno
        [6] - codigo da transação
        [7] - boleto em base64
        [8] - valor total das taxas
        [9] - valor total das parcelas
        [10] - data recebimento parceiro
        [11] - informações das parcelas
            [1] - numero da parcela
            [2] - data de vencimento da parcela
            [3] - valor da parcela
            [4] - valor de recebimento parceiro
            [5] - data de recebimento parceiro
            [6] - id tipo de taxa  
            [7] - tipo de taxa Parcela
            [8] - valor da taxa Parcela
            [9] - valor da taxa da parcela em reais
        [12] - informações dos tickets de crédito
            [1] - Código de pré-autorização
            [2] - Número do Pedido
    4 = Pós-venda (Antecipa)
        [1] - tenantId - ID do Tenant na Plataforma e Fluig
        [2] - platformId - PK da plataforma posteriormente enviada no POST para conclusão da sincronia da parcela
        [3] - erpId - Id de identificação do Titulo ( ArInvoiceInstallment )
        [4] - date - Data do movimento (dataHoraConclusaoProcessamento da API Supplier) com pattern AAAAMMDD
        [5] - operation - tipo de operação ( numero )
                Opções:
                    0-Antecipação
                    1-Baixa de título
                    2-Estorno da baixa do título
                    3-Coobrigação
                    4-Divergencia comercial
                    8-Recompra
                    11-Prorrogação de vencimentos
                    12-Bonificação
                    13-Devolução
                    14-Liberação de NCC
                    20-Conciliação bancária 
        [6] - history - Descrição do histórico
        [7] - localAmount - Valor bruto da operação - valor original da parcela ( numero )
        [8] - feeAmount - Valor do custo da operação ( numero )
        [9] - debitDate - data do débito do parceiro ( Data em que ocorrerá o débito do valor ao parceiro )
        [10] - creditUnits - Array com a relação de notas de credito e seu valor a ser compensado.
            [1] - Id de identificação da Nota de Crédito ( ArInvoiceInstalment ) - ERPID
            [2] - empresa - ERPID
            [3] - filial - ERPID
            [4] - prefixo - ERPID
            [5] - numero do titulo - ERPID
            [6] - parcela - ERPID
            [7] - tipo - ERPID
            [8] - Valor a ser compensado utilizando essa nota de crédito ( numero )
        [11] - creditAmount - Valor da soma das NCCs utilizadas nessa operação ( Terá valor apenas quando a operação for 12-Bonificação - numero )
        [12] - discountAmount - Valor do desconto a ser aplicado ( Terá valor apenas quando a operação for 12-Bonificação - numero )
        [13] - feeAmountOrigin - Estorno da taxa de antecipação ( Terá valor apenas quando a operação for 4-Divergência comercial ou 13-Devolução - numero )
        [14] - newDueDate - Nova data de vencimento
    
    5 = Concessao de Credito
        [1] - ErpId da Concessão
        [2] - Id da Concessão
        [3] - Id da Concessão Risk
        [4] - Filial do cliente
        [5] - Codigo do cliente
        [6] - Loja do cliente
        [7] - Limite Desejado  
        [8] - Limite Aprovado
        [9] - Data da Requisição
        [10] - Data da Avaliação
        [11] - Status
        [12] - Observações
        [13] - Origem (1=Plataforma ou 2=Protheus)
    6 = Requisições da plataforma
        [1] - Grupo de Empresa do cliente
        [2] - Filial do cliente
        [3] - Código do cliente
        [4] - Loja do cliente
        [5] - Filial do ErpID
        [6] - Código do ErpID
        [7] - OrganizationID
        [8] - Tipo de requisição
        [9] - Número do protocolo
    7 = Cancelamento de NFS Mais Negócios
        [1] - Chave da empresa/filial
        [2] - Código da NF Mais Neg.
        [3] - Guide do Cancelamento
        [4] - Status do cancelamento (2=aprovado;3=reprovado)
        [5] - Observação
        [6] - Valor da Taxa
        [7] - Saldo do ticket
        [8] - Número da Parcela
        [9] - Data de Pagamento da taxa.
        [10] - Valor do Devolvido por parcela.
        [11] - Valor da parcela.
        [12] - Estorno da taxa.
    9 = Conciliação
        [1] - Id da conciliação (guide)
        [2] - Código do grupo
        [3] - Data dos lançamentos
        [4] - Id da conta (guide)
        [5] - Banco
        [6] - Agencia 
        [7] - Conta corrente
        [8] - Parcela 
        [9] - Número de parcelas 
        [10] - Número da nota fiscal 
        [11] - Código da transação 
        [12] - Tipo de evento 
        [13] - Descrição do tipo de evento
        [14] - Tipo de lançamento 
        [15] - Tipo de transação 
        [16] - Descrição do tipo de transação
        [17] - Lançamento Futuro ?
        [18] - Data do lançamento 
        [19] - Data do evento 
        [20] - Data do vencimento original da parcela 
        [21] - Data do vencimento atual da parcela 
        [22] - Valor principal da transação 
        [23] - Valor total da transação 
        [24] - Valor principal da parcela 
        [25] - Valor total da parcela 
        [26] - Valor do lançamento 
        [27] - Custo de antecipação da parcela 
        [28] - Valor dos impostos
        [29] - Cnpj do parceiro (SIGAMAT)
        [30] - Cnpj/Cpf do cliente 
        [31] - Evento divergencia comercial
        [32] - Id do lançamento (guide)
    10 - Posição do Cliente
        [1] - Id do cliente (guide)
        [2] - Numero do CNPJ
        [3] - Status do Cliente
        [4] - Descrição do status da posição do cliente.
        [5] - Limite total do cliente
        [6] - Limite disponivel do cliente
        [7] - Limite total do cliente
        [8] - Limite disponivel do cliente 
        [9] - Limite liberado do clientee
        [10] - Limite pré-autorizado do cliente 
        [11] - Limite usado do cliente
    11 - Cancelamento de NFS Mais Negócios
        [1] - filial
        [2] - código de identificação

@author  Marcia Junko
@since   22/05/2020
/*/
//-------------------------------------------------------------------
Function GetRSKItems( cHost, nEntity, lAutomato )
    Local oRest 
    Local oJSON
    Local aJSONItens     := {}
    Local aItems         := {}
    Local aAux           := {}
    Local aProperties    := {}
    Local aERPID         := {}
    Local aSubItems      := {}
    Local aParcel        := {}
    Local aCreditTickets := {}
    Local aAuxParcel     := {}
    Local aSubAux        := {} 
    Local aAuxProperties := {}
    Local cBody          := ''
    Local cAction        := ''
    Local cEndPoint      := ''
    Local cAuxContent    := ''
    Local cPropertie     := ''
    Local nJSON          := 0
    Local nProp          := 0
    Local nPage          := 1
    Local nAux           := 0
    Local nSize          := 0
    Local nOption        := 0
    Local nBranchSize    := FWSizeFilial()
    Local nLenProperties := 0
    Local nLenJSONItens  := 0
    Local lContinue      := .T. 
    Local lInsert        := .F.
    Local jItems
    Local xValue         := NIL

    Default lAutomato    := .F.

    If nEntity == NEWTICKET         // 1=Criação de novo ticket
        Return RSKGetNewOrders( lAutomato )
    ElseIf nEntity == AFTERSALES    // 4=Pos vemda
        Return RSKRecPosVenda( lAutomato )
    ElseIf nEntity == MONITCANCEL   // 11=Cancelamento de NFS Mais Negócios
        Return RskMonitCancel( lAutomato )
    ENDIF

    If !Empty( cHost ) .Or. lAutomato
        Do Case    
            Case nEntity == UPDTICKET           // 2=Atualiza ticket
                cAction := '/v1/credit_ticket'
                aProperties := { 'erpId', 'status', 'disapprovalReason', 'id', 'obs', 'creditLineId', 'dateCreditAnalysis', ;
                                "preAuthorizationCode", "typeInvoice", "balanceCreditTicket" }
            Case nEntity == UPDARINVOICE        // 3=Atualiza fatura
                cAction := '/v3/invoice_partner'
                aProperties := { 'erpId', 'id', 'responseCode', 'responseMessage','transaction' }
                aAuxProperties := { 'transaction', 'bankSlip', 'installments' }
            Case nEntity == CONCESSION          // 5=Concessão
                cAction := '/v3/credit_concession'
                aProperties := { 'erpId', 'id', 'customerErpId', 'desiredLimit', 'approvedCreditLimit', ;  
                                'requestDate', 'evaluationDate', 'status', 'observationReason', 'origin' }   
            Case nEntity == NFSCANCEL           // 7=Cancelamento de NFS Mais Negócios
                cAction := '/v3/invoice_cancellation' 
                aProperties := { 'erpId', 'id', 'status', 'observation', 'amountDebitTax', 'balanceCreditTicket', ;
                                'instalment', 'debitDate', 'amountDebitTotal', 'amountReturn', 'amountReversalTax' }
            Case nEntity == CONCILIATION        // 9=Conciliação 
                cAction := '/v1/conciliation'
                aProperties := { 'ConciliacaoId', 'codigoGrupo', 'dataLancamentos', 'contas' }
            Case nEntity == CLIENTPOSITION      // 10=Posição do Cliente     
                cAction := '/v1/position
                aProperties := { 'id', 'cpfCnpj', 'status', 'statusDescription', 'customerType', 'numberOfDaysPaymentOverdue', 'purchaseLimit', 'allowForwardSale' }
        EndCase        

        LogMsg( "GetRSKItems", 23, 6, 1, "", "", "GetRSKItems -> API " + cAction)

        While lContinue
            cEndPoint := cAction + "?page=" + Alltrim( Str( nPage ) ) 

            //------------------------------------------------------------------------------
            // Busca os registros que serão tratados
            //------------------------------------------------------------------------------
            If !lAutomato
                cBody := RSKRestExec( RSKGET, cEndPoint, @oRest )   // GET 
            Else
                cBody := RskADVPRData( 'RSKJobCommand', NIL, { nEntity } )
            EndIf

            If !Empty( cBody )
                oJSON := JSONObject():New() 
                oJSON:FromJSON( cBody )

                //------------------------------------------------------------------------------
                // Carrega os items da propriedade principal
                //------------------------------------------------------------------------------
                aJSONItens := oJSON:GetJsonObject( 'items' )
                
                lContinue := oJSON:GetJsonObject( "hasNext" )  
                If ValType( aJSONItens ) == "A" .And. len( aJSONItens ) > 0 

                    nLenJSONItens  := Len( aJSONItens )
                    nLenProperties := Len( aProperties )
                    
                    For nJSON := 1 to nLenJSONItens
                        aAux := {}
                        lInsert := .F.
                        cContent := ''
                        xValue := NIL

                        //------------------------------------------------------------------------------
                        // Trata somente as propriedades necessárias para o fluxo
                        //------------------------------------------------------------------------------
                        For nProp := 1 to nLenProperties
                            cPropertie := aProperties[ nProp ]
                            xValue := aJSONItens[ nJSON ][ cPropertie ]
                            
                            If Valtype( xValue ) != "U"
                                If cPropertie == 'erpId'  
                                    aErpID := StrTokArr2( xValue , '|', .T.)
                                
                                    cContent += Padr( aErpID[2], nBranchSize )
                                    If nEntity == CONCESSION .And. Empty( aErpID[3] ) // 5=Concessão ### 6=Requisições da plataforma 
                                        //------------------------------------------------------------------------------
                                        // Reserva espaco no array para gerar a numeracao. 
                                        //------------------------------------------------------------------------------
                                        cContent += '|' + " "
                                    Else
                                        cContent += '|' + aErpID[3]
                                    EndIf
                                ElseIf cPropertie == 'customerErpId'
                                    aErpID := StrTokArr2( xValue , '|', .T. )
                                
                                    cContent += Padr( aErpID[2], nBranchSize ) + '|' + aErpID[3] + '|' + aErpID[4]
                                ElseIf cPropertie == "preAuthorizationCode"
                                    cContent += Iif( xValue == 0, ' ', Alltrim( Str( xValue ) ) ) 
                                ElseIf 'id' $ Lower( cPropertie )
                                    cContent += StrTran( xValue, '-', '')
                                ElseIf cPropertie $ 'dataLancamentos'
                                    cAuxContent := Subs( xValue, 1, At( 'T', xValue ) - 1 )

                                    cContent += StrTran( cAuxContent, '-', '')
                                ElseIf cPropertie == 'obs'
                                    cContent += StrTran( DecodeUTF8( xValue ), '|', CHR(13) + CHR(10) )
                                ElseIf cPropertie  $ 'transaction|purchaseLimit'
                                    lInsert := .T.
                                    cAuxContent := ''
                                    
                                    //------------------------------------------------------------------------------
                                    // Carrega as informações sobre as transações
                                    //------------------------------------------------------------------------------
                                    IF( cPropertie == 'transaction')
                                        nOption := INVOICE_INSTALLMENT      // 1=Parcelas da Invoice
                                        jItems := aJSONItens[ nJSON ]:GetJsonObject( "transaction" )
                                    Else
                                        nOption := PURCHASE_LIMIT           // 2=Limites do cliente
                                        jItems := aJSONItens[ nJSON ]:GetJsonObject( "purchaseLimit" )
                                    ENDIF
                                    cAuxContent := GetTransactions( jItems, @aParcel, nOption, @aCreditTickets )
                                    
                                    //------------------------------------------------------------------------------
                                    // Inclui os dados no vetor de controle
                                    //------------------------------------------------------------------------------
                                    cAuxContent := cContent + Subs( cAuxContent, 1, Len( cAuxContent ) - 1 )
                                    Aadd( aItems, StrTokArr2( cAuxContent , '|', .T. ) )
                                    nSize := Len( aItems )

                                    //------------------------------------------------------------------------------
                                    // Volta para numerico as posições de valor
                                    //------------------------------------------------------------------------------
                                    IF( nOption ==  1 )
                                        aItems[ nSize ][ UPD_I_TOTAL_FEE ]  := Val( aItems[ nSize ][ UPD_I_TOTAL_FEE ] )    // [8]-valor total das taxas
                                        aItems[ nSize ][ UPD_I_TOTAL_PARC ] := Val( aItems[ nSize ][ UPD_I_TOTAL_PARC ] )   // [9]-valor total das parcelas
                                    Else
                                        aItems[ nSize ][ UPD_C_DAYSPAYOVER ]:= Val( aItems[ nSize ][ UPD_C_DAYSPAYOVER ] )  // [6]-Dias em atraso.
                                        aItems[ nSize ][ UPD_C_TOTALPUR ]   := Val( aItems[ nSize ][ UPD_C_TOTALPUR ] )     // [7]-imite total do cliente
                                        aItems[ nSize ][ UPD_C_AVALIPUR ]   := Val( aItems[ nSize ][ UPD_C_AVALIPUR ] )     // [8]-Limite disponivel do cliente
                                        aItems[ nSize ][ UPD_C_RELEAPUR ]   := Val( aItems[ nSize ][ UPD_C_RELEAPUR ] )     // [9]-Limite liberado do cliente
                                        aItems[ nSize ][ UPD_C_PREAUTPUR ]  := Val( aItems[ nSize ][ UPD_C_PREAUTPUR ] )    // [10]-Limite pré-autorizado do cliente
                                        aItems[ nSize ][ UPD_C_USEPUR ]     := Val( aItems[ nSize ][ UPD_C_USEPUR ] )       // [11]-Valor faturado do cliente
                                    ENDIF

                                    cContent := ''
                                ElseIf cPropertie == 'observationReason' .And. Empty( xValue )
                                    cContent += " "  
                                ElseIf cPropertie == 'contas'
                                    //------------------------------------------------------------------------------
                                    // Salva informações sobre as contas
                                    //------------------------------------------------------------------------------
                                    jItems := aJSONItens[ nJSON ]:GetJsonObject( "contas" )
                                    GetAccounts( jItems, cContent, @aItems ) 

                                    cContent := ''
                                ElseIf cPropertie == 'allowForwardSale'
                                    AADD( aItems[Len( aItems )], IF(xValue, "0", "1" ) )
                                Else
                                    //------------------------------------------------------------------------------
                                    // Faz o tratamento necessário para incluir a informação na variável
                                    //------------------------------------------------------------------------------
                                    If Valtype( xValue ) == "N"
                                        cContent += Alltrim( Str( xValue ) )
                                    Else
                                        cContent += DecodeUTF8( xValue )
                                    EndIf
                                EndIf
                            else
                                //------------------------------------------------------------------------------
                                // Adiciona as posições que não tem informação preenchida para manter a mesma
                                // estrutura e ordem da variável de retorno desta função, de acordo com o que é
                                // esperado nas demais funções.
                                //------------------------------------------------------------------------------
                                If nEntity != UPDTICKET     // 2=Atualiza ticket
                                    cContent += ' '
                                else
                                    If nProp != Len( aProperties ) 
                                        cContent += ' '
                                    else
                                        //------------------------------------------------------------------------------
                                        // Adiciona também as posições que não fazem parte do payload
                                        //------------------------------------------------------------------------------
                                        For nAux := 1 to len( aAuxProperties ) + 3
                                            If nAux > 1
                                                cContent += '|'
                                            EndIf
                                            cContent += ' '
                                        Next
                                    EndIf    
                                EndIf
                            EndIF
                            
                            If len( cContent ) > 1
                                cContent += '|'
                            EndIf
                        Next

                        //------------------------------------------------------------------------------
                        // Transforma as propriedades selecionadas no array de itens para o fluxo
                        //------------------------------------------------------------------------------
                        If !Empty( cContent ) 
                            cContent := Subs( cContent, 1, Len( cContent ) - 1 )

                            Aadd( aItems, StrtokArr( cContent, '|' ) )
                        ENDIF

                        //------------------------------------------------------------------------------
                        // Só atribui as parcelas no array se estiver rodando atualização de fatura
                        //------------------------------------------------------------------------------
                        If nEntity == UPDARINVOICE      // 3=Atualiza fatura
                            If Len( aItems[ Len( aItems ) ] ) >= UPD_I_PARCELS  // [11]-informações das parcelas
                                If lInsert
                                    aItems[ Len( aItems ) ][ UPD_I_PARCELS ] := aClone( aParcel )        // [11]-informações das parcelas
                                Else
                                    aItems[ Len( aItems ) ][ UPD_I_PARCELS ] := {}                  // [11]-informações das parcelas
                                EndIf
                            EndIf
                            If lInsert
                                aItems[ Len( aItems ) ][ 12 ] := aClone( aCreditTickets ) // [12]-informações dos Tickets
                            EndIf

                        EndIf                    
                    Next
                else
                    lContinue := .F.
                EndIf
            else
                lContinue := .F. 
                If !lAutomato
                    LogMsg( "GetRSKItems", 23, 6, 1, "", "", "GetRSKItems -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )   
                Endif
            Endif
            nPage++ 
        End 
    EndIf

    FWFreeArray( aAux )
    FWFreeArray( aJSONItens )
    FWFreeArray( aProperties )
    FWFreeArray( aERPID )
    FWFreeArray( aSubItems )
    FWFreeArray( aParcel )
    FWFreeArray( aCreditTickets )
    FWFreeArray( aAuxParcel )
    FWFreeArray( aSubAux )
    FWFreeArray( aAuxProperties )
    FreeObj( oRest )
    FreeObj( oJSON )    
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTransactions
Função auxiliar para carga dos dados de transação no endpoint invoice_partner.

@param jItems, JSON, objeto com os itens da transação
@param @aParcel, array, vetor que armazena os dados de parcela para serem encaminhados 
    à função do Protheus resposável pelo processamento.
@param nOption, number, sendo: 1 = parcelas Invoice e 2 = Limites do Cliente.   
@param aCreditTickets, array, vetpr que armazena os dados dos Tickets de Créditos.   

@return caracter, conteúdo que será transformado em vetor.
@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetTransactions( jItems, aParcel, nOption, aCreditTickets )
    Local nAux           := 0
    Local nPayment       := 0
    Local nFee           := 0
    Local nSub           := 0
    Local nSubAux        := 0
    Local cReceiptDt     := ''
    Local cAuxContent    := ''
    Local cPropertie     := ''
    Local aAuxProperties := {}
    Local aSubItems      := {}
    Local aAuxParcel     := {}
    Local aAuxTktCrd     := {}
    Local aSubAux        := {}
    Local aParcelaAux    := {}
    Local aCTickets      := {}
    Local xAuxValue      := NIL
    Local oSubItems
    Local oSubAux

    IF ( nOption == INVOICE_INSTALLMENT )   // 1=Parcelas da Invoice
        aAuxProperties := { 'transactionCode', 'bankSlip', 'installments', 'creditTickets', 'issuerReceiptType' }
    Else                                    // 2=Limites do cliente
        aAuxProperties := { 'totalPurchaseLimit', 'availablePurchaseLimit', 'releasedPurchaseLimit', ;
                     'preAuthorizationPurchaseLimit', 'usedPurchaseLimit' }
    ENDIF

    //------------------------------------------------------------------------------
    // Trata somente as propriedades necessárias para o fluxo
    //------------------------------------------------------------------------------
    For nAux := 1 To Len( aAuxProperties )
        cPropertie := aAuxProperties[ nAux ]
        xAuxValue  := jItems[ cPropertie ]

        If Valtype( xAuxValue ) != "U"
            If cPropertie $ 'dataVencimentoOriginalParcela|dataVencimentoAtualParcela'
                cAuxContent += StrTran( xAuxValue, '-', '' )
            Elseif cPropertie == 'tipoLancamento'
                cAuxContent += Iif( Upper( Alltrim( xAuxValue ) ) == 'CREDITO', '1', '2')
            ElseIf cPropertie == 'installments'
                nPayment   := 0
                nFee       := 0
                cReceiptDt := ''
                aSubItems  := jItems:GetJsonObject( "installments" )
                For nSub := 1 To Len( aSubItems )
                    aAuxParcel := Array(9)
                    oSubItems  := aSubItems[ nSub ]
                    cReceiptDt := oSubItems[ 'issuerReceiptDate' ]
                    cReceiptDt := StrTran( cReceiptDt, '-', '' )
                    nPayment   += oSubItems[ 'issuerReceiptAmount' ]
                    aSubAux    := oSubItems[ "installmentFees" ]
                    For nSubAux := 1 To Len( aSubAux )
                        oSubAux := aSubAux[ nSubAux ] 
                        
                        If oSubAux[ 'feeTypeId' ] == "1" .Or. oSubAux[ 'feeTypeId' ] == "4"
                            nFee += oSubAux[ 'feeAmountBRL' ]   
                    
                            aAuxParcel[ PARCEL_FEEID ]    := oSubAux[ 'feeTypeId' ]      // [6]-id tipo de taxa
                            aAuxParcel[ PARCEL_FEETYPE ]  := oSubAux[ 'feeType' ]        // [7]-tipo de taxa Parcela
                            aAuxParcel[ PARCEL_FEEVALUE ] := oSubAux[ 'feeAmount' ]      // [8]-valor da taxa Parcela
                            aAuxParcel[ PARCEL_RSVALUE ]  := oSubAux[ 'feeAmountBRL' ]   // [9]-valor da taxa da parcela em reais
                        EndIf        
                    Next 

                    aAuxParcel[ PARCEL_NUMBER ]    := oSubItems[ 'numberOfInstallments' ]                     // [1]-numero da parcela
                    aAuxParcel[ PARCEL_DUEDATE ]   := StrTran(oSubItems[ 'installmentExpireDate' ], '-', '' ) // [2]-data de vencimento da parcela
                    aAuxParcel[ PARCEL_VALUE ]     := oSubItems[ 'installmentAmount' ]                        // [3]-valor da parcela
                    aAuxParcel[ PARCEL_RECAMOUNT ] := oSubItems[ 'issuerReceiptAmount' ]                      // [4]-valor de recebimento parceiro
                    aAuxParcel[ PARCEL_AMOUNTDT ]  := StrTran(oSubItems[ 'issuerReceiptDate' ], '-', '' )      // [5]-data de recebimento parceiro
                    
                    aAdd( aParcelaAux, aAuxParcel )
                Next

                //------------------------------------------------------------------------------
                // ATENÇÂO - Não retirar o espaço no fim da proxima linha, pois ela faz parte do fluxo 
                //------------------------------------------------------------------------------
                cAuxContent += Alltrim( Str( nFee ) ) + '|' + Alltrim( Str( nPayment ) ) + '|' + cReceiptDt + '| '
            ElseIf cPropertie == 'creditTickets'
                aSubItems := jItems:GetJsonObject( "creditTickets" )
                For nSub := 1 To Len( aSubItems )
                    aAuxTktCrd := Array(2)
                    oSubItems  := aSubItems[ nSub ]
                    aAuxTktCrd[ 01 ]    := oSubItems[ 'preAuthorizationCode' ]   // [1]-Código de Pré-Autorização
                    aAuxTktCrd[ 02 ]    := oSubItems[ 'orderNumber' ]            // [2]-Número do Pedido
                    aAdd( aCTickets, aAuxTktCrd )
                Next
            Else 
                If Valtype( xAuxValue ) == "N"
                    cAuxContent += Alltrim( Str( xAuxValue ) )
                else
                    cAuxContent += DecodeUTF8( xAuxValue )
                ENDIF
            EndIf
        else 
            cAuxContent += ' '
        EndIf                     
        cAuxContent += '|'
    Next

    aParcel        := aClone(aParcelaAux)
    aCreditTickets := aClone(aCTickets)

    FWFreeArray( aAuxProperties )
    FWFreeArray( aSubItems )
    FWFreeArray( aAuxParcel )
    FWFreeArray( aAuxTktCrd )
    FWFreeArray( aSubAux )
    FWFreeArray( aParcelaAux )
    FWFreeArray( aCTickets )
    FreeObj( oSubItems )
    FreeObj( oSubAux )
 Return cAuxContent

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetAccounts
Função auxiliar para carga dos dados de conta no endpoint conciliation.

@param jItems, JSON, objeto com os itens da transação
@param cContent, caracter, string com dados básicos para gravação
@param @aItems, array, vetor com itens que serão retornados ao vetor principal

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetAccounts( jItems, cContent, aItems ) 
    Local oItem
    Local oSubItem
    Local nCount := 0
    Local nAux := 0
    Local nSub := 0 
    Local nSubAux := 0
    Local nLen := 0
    Local aAuxProperties := {}
    Local aSubItems := {}
    Local aSubProperties := {}
    Local cAuxContent := ''
    Local cSubContent := ''
    Local cAddItem := ''
    Local cPropertie := ''
    Local xAuxValue := NIL
    Local xSubValue := NIL

    aAuxProperties := { 'contaId', 'banco', 'agencia', 'contaCorrente', 'lancamentos' }
    aSubProperties := { 'parcela', 'numeroParcelas', 'numeroNotaFiscal', 'codigoTransacao', 'tipoEvento', ;
        'tipoEventoDesc', 'tipoLancamento', 'tipoTransacao', 'tipoTransacaoDesc', 'lancamentoFuturo', ;
        'dataLancamento', 'dataEvento', 'dataVencimentoOriginalParcela', 'dataVencimentoAtualParcela', ;
        'valorPrincipalTransacao', 'valorTotalTransacao', 'valorPrincipalParcela', 'valorTotalParcela', ;
        'valorLancamento', 'custoAntecipacaoParcela', 'valorImpostos', ;
        'cnpjParceiro', 'cnpjCpf', 'eventoDivergenciaComercial', 'lancamentoId' }

    //------------------------------------------------------------------------------
    // Itera pelos items do JSON
    //------------------------------------------------------------------------------
    For nCount := 1 to len( jItems )                                            
        cAuxContent := ''
        oItem := jItems[ nCount ]

        //------------------------------------------------------------------------------
        // Trata somente as propriedades necessárias para o fluxo
        //------------------------------------------------------------------------------
        For nAux := 1 to len( aAuxProperties )
            cPropertie := aAuxProperties[ nAux ]
            xAuxValue := oItem[ cPropertie ]

            If Valtype( xAuxValue ) != "U"
                If 'id' $ Lower( cPropertie )
                    cAuxContent += StrTran( xAuxValue, '-', '')
                ElseIf cPropertie == 'lancamentos'
                    aSubItems := oItem:GetJsonObject( "lancamentos" )
                    
                    For nSub := 1 to len( aSubItems )
                        oSubItem := aSubItems[ nSub ]

                        cSubContent := ''
                        For nSubAux := 1 to len( aSubProperties )
                            cPropertie := aSubProperties[ nSubAux ]
                            xSubValue := oSubItem[ cPropertie ]

                            If Valtype( xSubValue ) != "U"
                                If cPropertie $ 'dataLancamento|dataEvento|dataVencimentoOriginalParcela|dataVencimentoAtualParcela'
                                    xSubValue := Subs( xSubValue, 1, At('T', xSubValue) - 1 )
                                    cSubContent += StrTran( xSubValue, '-', '' )
                                ElseIf 'id' $ Lower( cPropertie )
                                    cSubContent += StrTran( xSubValue, '-', '' )
                                Elseif cPropertie == 'tipoLancamento'
                                    cSubContent += Iif( Upper( Alltrim( xSubValue ) ) == 'CREDITO', '1', '2' )
                                Else 
                                    If Valtype( xSubValue ) == "N"
                                        cSubContent += Alltrim( Str( xSubValue ) )
                                    else
                                        cSubContent += DecodeUTF8( xSubValue )
                                    ENDIF
                                EndIf
                            else
                                cSubContent += ' '
                            EndIf                        
                            cSubContent += '|'
                        Next

                        cAddItem := cContent + cAuxContent + Subs( cSubContent, 1, Len( cSubContent ) - 1 )                           
                        Aadd( aItems, StrtokArr( cAddItem , '|' ) )


                        //------------------------------------------------------------------------------
                        // Volta para numerico as posições de valor
                        //------------------------------------------------------------------------------
                        nLen := len( aItems ) 
                        aItems[ nLen ][ BANK_TRANS_MAIN ] := Val( aItems[ nLen ][ BANK_TRANS_MAIN ] )       // [22]-Valor principal da transação 
                        aItems[ nLen ][ BANK_TRANS_TOTAL ] := Val( aItems[ nLen ][ BANK_TRANS_TOTAL ] )     // [23]-Valor total da transação 
                        aItems[ nLen ][ BANK_PARC_MAIN ] := Val( aItems[ nLen ][ BANK_PARC_MAIN ] )         // [24]-Valor principal da parcela 
                        aItems[ nLen ][ BANK_PARC_TOTAL ] := Val( aItems[ nLen ][ BANK_PARC_TOTAL ] )       // [25]-Valor total da parcela 
                        aItems[ nLen ][ BANK_ENTRY_VALUE ] := Val( aItems[ nLen ][ BANK_ENTRY_VALUE ] )     // [26]-Valor do lançamento 
                        aItems[ nLen ][ BANK_PARC_COST ] := Val( aItems[ nLen ][ BANK_PARC_COST ] )         // [27]-Custo de antecipação da parcela 
                        aItems[ nLen ][ BANK_TAXES ] := Val( aItems[ nLen ][ BANK_TAXES ] )                 // [28]-Valor dos impostos
                    Next
                Else 
                    If Valtype( xAuxValue ) == "N"
                        cAuxContent += Alltrim( Str( xAuxValue ) )
                    else
                        cAuxContent += DecodeUTF8( xAuxValue )
                    ENDIF
                EndIf
            else
                cAuxContent += ' '
            EndIf                        
            cAuxContent += '|'
        Next
    NEXT

    FWFreeArray( aAuxProperties )
    FWFreeArray( aSubItems )
    FWFreeArray( aSubProperties )
    FreeObj( oItem )
    FreeObj( oSubItem )

Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKAction
Função auxiliar para carga dos dados de conta no endpoint conciliation.

@param nType, number, tipo de ação que será executada
@param cHost, caracter, URL da plataforma onde será executado os endpoints
@param aRecords, array, vetor com as informações a serem processadas
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKAction( nType, cHost, aRecords, lAutomato )
    Local cCompany := ''
    Local cBranch := ''
    Local cBKPCompany := ''
    Local cBKPBranch := ''
    Local aRecordInfo := {}
    Local lConfirmation := .T.
    Local lNewCompany := .F.

    Default lAutomato := .F.

    cBKPCompany := cEmpAnt
    cBKPBranch := cFilAnt

    cCompany := aRecords[ REC_COMPANY ]     // [1]-grupo de empresa
    cBranch := aRecords[ REC_BRANCH ]       // [2]-codigo da filial
    aRecordInfo := aRecords[ REC_ITEMS ]    // [5]-lista de registros

    If Empty( cCompany )
        cCompany := cEmpAnt
    EndIf

    If Empty( cBranch )
        cBranch := cFilAnt
    EndIf

    If cBKPCompany != cCompany
        lNewCompany := .T.
        RpcSetType(3)
        RpcSetEnv( cCompany, cBranch )
    else
        cFilAnt := cBranch

        //-----------------------------------------------------------------------------------------
        // O comando abaixo é necessário pois existem algumas rotinas do padrão que pesquisam 
        // a empresa\filial, mas não retornam o ponteiro para o registro anterior. 
        // Este comando serve para garantir que o sistema esteja posicionado no registro correto.
        //-----------------------------------------------------------------------------------------
        SM0->( MSSeek( cEmpAnt + cFilAnt ) )
    EndIf

    //-----------------------------------------------------------------------------------------
    // Se houver registros para processar, executa as rotinas de acordo com a ação necessária
    //-----------------------------------------------------------------------------------------
    If !Empty( aRecordInfo )
        Do Case
            Case nType == NEWTICKET         // 1=Criação de novo ticket        
                lConfirmation := .F.
                
                //--------------------------------------------------------------
	            // Funcao que cancela os tickets de credito da filial corrente
	            //--------------------------------------------------------------
	            RskCanTicket( lAutomato )
	    
	            //--------------------------------------------------------------
	            // Funcao que gera os tickets de credito da filial corrente
	            //--------------------------------------------------------------
	            RskNewTicket( aRecordInfo, lAutomato ) 
            Case nType == UPDTICKET         // 2=Atualiza ticket       
                RSKUpdTicket( aRecordInfo, lAutomato )
            Case nType == UPDARINVOICE      // 3=Atualiza fatura
                RSKDesdobr( aRecordInfo, lAutomato ) 
            Case nType == AFTERSALES        // 4=Pos vemda
                RSKMovAftSales( aRecordInfo, lAutomato )      
            Case nType == CONCESSION        // 5=Concessão
                RskUpdConcession( aRecordInfo, lAutomato )        
            Case nType == NFSCANCEL         // 7=Cancelamento de NFS Mais Negócios
            	lConfirmation := .F.
            	RSKConfCanc( aRecordInfo, lAutomato )
            Case nType == CONCILIATION      // 9=Conciliação
                //-------------------------------------------------------------------
                // Ordena pelo CNPJ do cliente. 
                //-------------------------------------------------------------------       
                aSort( aRecordInfo, , , {|x, y| AllTrim( Upper( x[ BANK_CUST_CNPJ ] ) ) < AllTrim( Upper( y[ BANK_CUST_CNPJ ] ) ) } )   // [30]=Cnpj/Cpf do cliente 

                RSKBankConciliation( aRecordInfo, lAutomato )
            case nType == CLIENTPOSITION    // 10=Posição do Cliente     
                lConfirmation := .F.
                RskUpdClientPos( aRecordInfo, lAutomato )
            Case nType == MONITCANCEL       // 11=Cancelamento de NFS Mais Negócios
                lConfirmation := .F.
                RSKCancNf( aRecordInfo, lAutomato ) 
        EndCase

        //-------------------------------------------------------------------
        // Executa a ação de recebimento do dado pelo Protheus
        //-------------------------------------------------------------------       
        If lConfirmation     
            RSKPlatConfirm( cHost, nType, aRecordInfo, lAutomato )     
        EndIf
    EndIf

    If lNewCompany
        RPCClearEnv()

        RpcSetType(3)
        RpcSetEnv( cBKPCompany, cBKPBranch )
    Else
        cFilAnt := cBKPBranch
        
        SM0->( MSSeek( cEmpAnt + cFilAnt ) )  
    EndIf

    FWFreeArray( aRecordInfo )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKPlatConfirm
Função de confirmação dos dados na plataforma RISK

@param cHost, caracter, URL da plataforma onde será executado os endpoints
@param nType, number, tipo de ação que será executada
@param aRecords, array, vetor com as informações a serem processadas
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKPlatConfirm( cHost, nType, aRecords, lAutomato ) 
    Local aSvAlias  := GetArea()
    Local oRest     := Nil
    Local oJASales  := Nil
    Local nItem     := 0
    Local nPosID    := 0
    Local nRecCode  := 0
    Local cAction   := ''
    Local cEndPoint := ''
    Local cBody     := ''
    Local cAlias    := ''
    Local lSent     := .F.  
    Local lStatus   := .F.
    Local nOrder    := 1 
    Local nPosFind  := 1
    Local cChvFind  := ""
    Local cErpId    := ""
    Local nTypePlat := RISK         // 1=Plataforma Risk
    Local nTypeRac  := SERVICE      // 2=URL de autenticação de serviços
    
    Default lAutomato := .F.

    If !Empty( cHost ) .Or. lAutomato
        If nType == AFTERSALES      // 4=Pos vemda
            nTypePlat   := ANTECIPA // 2=Plataforma Antecipa
            nTypeRac    := AUTH     // 1=URL de autenticação no RAC
        EndIf   

        oRest := FWRest():New( cHost )   

        If nType == UPDTICKET           // 2=Atualiza ticket
            cAction := '/v1/credit_ticket'
            cAlias := 'AR0'
            nPosID := UPD_T_ID          // [5]-id do ticket   
            nRecCode := UPD_T_TICKET    // [2]-numero do ticket
        Elseif nType == UPDARINVOICE    // 3=Atualiza fatura
            cAction := '/v3/invoice_partner'
            cAlias := 'AR1'
            nPosID := UPD_I_INVOICEID   // [3]-id da fatura   
            nRecCode := UPD_I_INVOICE   // [2]-numero do documento
        Elseif nType == AFTERSALES      // 4=Pos vemda
            nOrder := 2
            cAction := '/integration/api/v2/bearers' 
            cAlias := 'AR4'
            nPosID := AFTER_ERPID       // [3]-Id de identificação do Titulo ( ArInvoiceInstallment )  
            nPosFind := 2
            nRecCode := AFTER_ERPID     // [3]-Id de identificação do Titulo ( ArInvoiceInstallment )  
        Elseif nType == CONCESSION      // 5=Concessão
            cAction :=  '/v3/credit_concession' 
            cAlias  := "AR5"
            nPosID  := CONCESSION_RSKID     // [3]-Id da concessao RISK     
            nRecCode := CONCESSION_ID       // [2]-ID da concessão
        Elseif nType == CONCILIATION    // 9=Conciliação 
            nOrder := 2
            cAction := '/v1/conciliation/confirmation' 
            cAlias := 'AR4'
            nPosID := BANK_ENTRY_ID      // [32]-Id do lançamento (guide) 
            nPosFind := 32
            nRecCode := BANK_ID         // [1]-ID da conciliação (guide)
        EndIf
        
        DbSelectArea( cAlias )
        DbSetOrder( nOrder )
        For nItem := 1 to len( aRecords )
            lSent := .F.
            If nType == AFTERSALES .Or. nType == CONCILIATION    // 4=Pos vemda ### 9=Conciliação
                cChvFind := xFilial( "AR4" ) + aRecords[ nItem ][ nPosFind ] 
            Else 
                cChvFind := xFilial( cAlias, aRecords[ nItem ][ nPosFind ] ) + aRecords[ nItem ][2]
            EndIf  
        
            If ( cAlias )->( DBSeek( cChvFind ) )
                If ( nType == UPDTICKET .Or. nType == UPDARINVOICE .Or. nType == CONCESSION )   // 2=Atualiza ticket ### 3=Atualiza fatura ### 5=Concessão
                    If nType == UPDTICKET .And. AR0->AR0_STATUS == AR0_STT_CANCELED      // 2=Atualiza ticket ### 4=Cancelado
                        lStatus := .T.  
                    Else
                        lStatus := ( cAlias )->&( cAlias + '_STARSK' ) == STARSK_RECEIVED // 3=Recebido
                    EndIf
                ElseIf nType == AFTERSALES  // 4=Pos vemda
                    lStatus := ( cAlias )->&( cAlias + '_STARSK' ) == STT_RSK_CONFIRMED // 1=Confirmado
                Else 
                    lStatus := AR4->AR4_STATUS <> STARSK_CONFIRMED      // 4=Confirmado
                EndIf     
                
                If lStatus
                    If nType != AFTERSALES  // 4=Pos vemda
                        If nType == CONCESSION  // 5=Concessão
                            cErpId := AllTrim(cEmpAnt) + '|' + AllTrim(aRecords[ nItem ][ CONCESSION_BRANCH  ]) + '|' + AllTrim(aRecords[ nItem ][ CONCESSION_ID  ])    // [1]=Filial da concessao ### [2]=ID da concessao
                            cEndPoint := cAction + '/' + aRecords[ nItem ][ nPosID ] + '/' + cErpId + '/confirmation' 
                        Else
                            cEndPoint := cAction + '/' + aRecords[ nItem ][ nPosID ] + Iif( nType != CONCILIATION, '/confirmation', '')     // 9=Conciliação
                        EndIf

                        If !lAutomato
                            cResult := RSKRestExec( RSKPUT, cEndPoint, @oRest, cBody, nTypePlat, nTypeRac )
                        else
                            cResult := RskADVPRData( 'RSKJobCommand', NIL, { nType, Iif( nRecCode > 0, aRecords[ nItem ][ nRecCode ], aRecords[ nItem ][ nPosID ] ) } )
                        EndIf
    
                        IF !Empty( cResult )
                            oJSON := JSONObject():New()
                            oJSON:FromJSON( cResult )   

                            lSent := oJSON:GetJsonObject( "sent" )

                            If lSent 
                                RecLock( cAlias, .F. )
                                    If nType == UPDTICKET .And. AR0->AR0_STATUS == AR0_STT_CANCELED       // 2=Atualiza ticket ### 4=Cancelado
                                        AR0->AR0_STARSK := STARSK_SUBMIT        // 1=Enviar 
                                    Else
                                        &( cAlias + '_STARSK' ) := STARSK_CONFIRMED     // 4=Confirmado
                                    EndIf
                                MSUnlock()     
                            EndIf
                        Else
                            IF !lAutomato
                                LogMsg( "RSKPlatConfirm", 23, 6, 1, "", "", "RSKPlatConfirm -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )  
                            EndIf
                        EndIf
                    Else
                        oJASales := JsonObject():New()

                        oJASales["tenantId"]    := Nil
                        oJASales["platformId"]  := aRecords[ nItem ][ nPosFind ] 
                        oJASales["erpId"]       := aRecords[ nItem ][ nPosID ]
                        oJASales["history"]     := STR0003      //"Processado com sucesso..."
                        oJASales["returnType"]  := "00"

                        If !lAutomato
                            cResult := RSKRestExec( RSKPOST, cAction, @oRest, oJASales, nTypePlat, nTypeRac ) 
                        else
                            cResult := RskADVPRData( 'RSKJobCommand', NIL, { nType, '' } )
                        EndIf

                        IF !Empty( cResult )
                            RecLock( cAlias, .F. )
                                AR4->AR4_STARSK := STT_RSK_PROCESSED  // 2=Processado
                            MSUnlock()   
                        Else
                            If !lAutomato
                                LogMsg( "RSKPlatConfirm", 23, 6, 1, "", "", "RSKPlatConfirm -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf 
        Next
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias ) 
    FreeObj( oJASales )
    FreeObj( oRest )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobBank
Função chamada pelo Schedule para execução da rotina de conciliação.

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada 
    por User Function

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKJobBank( aParam, cFil )
    Local lConciliation  := .T.
    Local nTypeSchedule  := SCHEDULE_JOBBANK // 1=RSKJobBank
    Local cLockSchedule  := 'RSKJobBank'

    RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskProcJob
Função auxiliar para iniciar o ambiente para execução das funções

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada por
User Function

@return boolean, indica se está sendo executado via Schedule ou User Function
@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RskProcJob( aParam, cFil )
    Local cCompany := NIL
    Local cBranch := NIL
    Local lJob := .F.

    Default aParam := nil
    Default cFil := NIL

    //------------------------------------------------------------------------------
    // Tratamento para validar se a execução é via JOB ou User Function
    //------------------------------------------------------------------------------
    If Valtype( aParam ) != "A" 
        If ValType( aParam ) <> "C" .AND. !Empty( cEmpAnt )
            cCompany := cEmpAnt
            cBranch := cFilant
        Else
            cCompany := aParam
            cBranch := cFil
            lJob  := .T.
        EndIf
    Else
        lJob :=  .T.
        cCompany := aParam[1]
        cBranch := aParam[2]
    EndIf
    
    IF lJob
        RPCSetType( 3 )
        RPCSetEnv( cCompany, cBranch )
    EndIF 
Return lJob

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRecbyBranch
Função auxiliar para separar os registros do endpoint por filial

@param nType, number, tipo de ação que será executada
@param aRecords, array, vetor com as informações a serem processadas

@return array, vetor com itens retornados pelo endpoint por filial
    [1] = grupo de empresa
    [2] = codigo da filial
    [3] = cgc da filial
    [4] = nome da filial
    [5] = lista de registros de acordo com o tipo. Para informações, verifique a 
            documentação do retorno da função GetRSKItems

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRecbyBranch( nType, aRecords )
    Local aSM0 := {}
    Local aRecByBranch := {}
    Local nRec := 0
    Local nBranch := 0
    Local nLen := 0
    Local nFind := 0
    Local nRecPos := 0          // Posição do array aRecord a validar
    Local nByBranch := 0        // Posição do array aRecByBranch a pesquisar
    Local nPosSM0 := 0          // Posição do SIGAMAT para validar
    Local cBranch := ""

    Default nType :=  NEWTICKET     // 1=Criação de novo ticket

    If nType ==  CONCILIATION       // 9=Conciliação
        nRecPos := BANK_PART_CNPJ       // [29]-Cnpj do parceiro (SIGAMAT)
        nByBranch := REC_CNPJ           // [3]-CNPJ/CGC da filial        
        nPosSm0 := SM0_CGC
    else
        If nType == AFTERSALES      // 4=Pos vemda
            nRecPos := AFTER_BRANCH           // [15]-Filial 
        ElseIf nType == CONCESSION  // 5=Concessão
            nRecPos     := CONCESSION_CUSTBRANCH    // [4]-Filial do cliente               
        Else
            nRecPos := 1  
        EndIf
        nByBranch := REC_BRANCH     // [2]-código da filial         
        nPosSm0 := SM0_CODFIL
    EndIf

    aSM0 := FWLoadSM0()
    For nRec := 1 to len( aRecords )
		cBranch := IIF( nType != CLIENTPOSITION, rtrim(aRecords[ nRec ][ nRecPos ]), '' )   // 10=Posição do Cliente     
        
        IF !Empty( aRecByBranch ) .And. ( ( nFind := Ascan( aRecByBranch, {|x| x[ SM0_GRPEMP ] == cEmpAnt .And. ;
            Subs( x[ nByBranch ], 1, Len( cBranch ) ) == cBranch } ) ) > 0 ) 
                Aadd( aRecByBranch[ nFind ][ REC_ITEMS ], aRecords[ nRec ] )        // [5]-lista de registros
        Else
            If !Empty( cBranch ) 
                nBranch :=  Ascan( aSM0, {|x| x[ SM0_GRPEMP ] == cEmpAnt .And. Subs( x[ nPosSm0 ], 1, Len( cBranch ) ) == cBranch  } )
            Else
                nBranch :=  Ascan( aSM0, {|x| x[ SM0_GRPEMP ] == cEmpAnt } )      
            EndIf 

            IF nBranch > 0
                aAdd( aRecByBranch, Array(5) ) 

                nLen := len( aRecByBranch )
                aRecByBranch[ nLen ][ REC_COMPANY ] := aSM0[ nBranch ][ SM0_GRPEMP ]    // [1]-grupo de empresa  
                aRecByBranch[ nLen ][ REC_BRANCH ] := aSM0[ nBranch ][ SM0_CODFIL ]     // [2]-código da filial
                aRecByBranch[ nLen ][ REC_CNPJ ] := aSM0[ nBranch ][ SM0_CGC ]          // [3]-CNPJ\CGC da filial
                aRecByBranch[ nLen ][ REC_NAME ] := aSM0[ nBranch ][ SM0_NOMRED ]       // [4]-nome da filial
                aRecByBranch[ nLen ][ REC_ITEMS ] := {}                                 // [5]-lista de registros

                Aadd( aRecByBranch[ nLen ][ REC_ITEMS ], aRecords[ nRec ] )             // [5]-lista de registros
            EndIf
        EndIf  
    Next

    FWFreeArray( aSM0 )
Return aRecByBranch 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKGetNewOrders
Função que busca os pedidos que ainda não viraram ticket.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os pedidos para transformar em ticket.
    [1] - filial
    [2] - numero do pedido
    [3] - cliente 
    [4] - loja
@author  Marcia Junko
@since   25/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKGetNewOrders( lAutomato )
    Local aSvAlias := GetArea()
    Local aItems := {}
    Local aBranches := {}
    Local aKnownBranches := {}
    Local cTemp := ''
    Local cBranch := ''
    
    Default lAutomato := .F.

    aBranches := FWLoadSM0()
    cTemp := GetQryNewOrders()

    While ( cTemp )->( !EOF() )
        cBranch := SeekFullBranch( aBranches, @aKnownBranches, ( cTemp )->FILIAL )

        aAdd( aItems, { cBranch, ( cTemp )->PEDIDO, ( cTemp )->CLIENTE, ( cTemp )->LOJA } )

        ( cTemp )->( DBSkip() )
    End

    ( cTemp )->( DBCloseArea() )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )    
    FWFreeArray( aBranches )    
    FWFreeArray( aKnownBranches )    
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetQryNewOrders
Função auxiliar para montagem da query de pesquisa dos pedidos que ainda não 
viraram ticket.

@return caracter, nome do alias temporária com a consulta dos novos tickets.
@author  Marcia Junko
@since   25/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetQryNewOrders()
    Local aSvAlias := GetArea()
    Local cQuery := ''
    Local cTempAlias := ''

    cQuery := "SELECT C9_FILIAL FILIAL, C9_PEDIDO PEDIDO, C9_CLIENTE CLIENTE, " + ;
            " C9_LOJA LOJA " + ;
            " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
            " WHERE SC9.C9_TICKETC = ' ' AND SC9.C9_BLCRED = '80' " + ; 
                " AND SC9.C9_NFISCAL = ' ' AND SC9.C9_SERIENF = ' ' " + ;
                " AND SC9.D_E_L_E_T_ = ' ' " + ;
            " GROUP BY C9_FILIAL,C9_PEDIDO, C9_CLIENTE, C9_LOJA " + ;
            " ORDER BY C9_FILIAL,C9_PEDIDO, C9_CLIENTE, C9_LOJA "
    
    cQuery := ChangeQuery( cQuery )  

    cTempAlias := MPSysOpenQuery( cQuery )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )
Return cTempAlias 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SeekFullBranch
Função auxiliar para buscar a filial completa do registro para poder associar corretamente
o registro na plataforma.
Esta função é útil, pois não há CNPJ da filial em registros com algum nível de 
compartilhamento e somente com a filial completa é possível atrelar ao organization na 
.plataforma

@param aBranches, array, vetor com todas as filiais do sistema
@param @aKnownBranches, array, vetor com as filiais que já foram processadas para diminuir 
    a pesquisa devido ao WHILE.
@param cBranch, caracter, filial a ser pesquisada

@return caracter, filial completa que foi retornada.
@author  Marcia Junko
@since   27/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SeekFullBranch( aBranches, aKnownBranches, cBranch )
    Local cFullBranch := ''
    Local cSeek := ''
    Local nItem := 0
    Local nLen := 0

    If ( nItem := Ascan( aKnownBranches, {|x| x[1] == Upper( Alltrim( cBranch ) ) } ) ) > 0
        cFullBranch := aKnownBranches[ nItem ][2]
    else
        cSeek := Upper( Alltrim( cBranch ) )
        nLen := Len( cSeek )

        If nLen != 0
            nItem := Ascan( aBranches, {|x| Upper( Subs( x[ SM0_CODFIL ], 1, nLen ) ) == cSeek } )

            cFullBranch := aBranches[ nItem ][ SM0_CODFIL ]
        else
            cFullBranch := aBranches[ 1 ][ SM0_CODFIL ]
        EndIf

        aAdd( aKnownBranches, { cSeek, cFullBranch } )
    EndIf
Return cFullBranch

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRecPosVenda
Função que separa somente os registros do Pos-venda ( 11-Prorrogação de vencimentos | 
    12-Bonificação | 13-Devolução | 14-Liberação de NCC ) dos dados do antecipa.
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, dados de pós venda do Antecipa. Para informações, verifique a documentação 
    do retorno da função GetRSKItems para o tipo 4.
@author  Marcia Junko
@since   29/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRecPosVenda( lAutomato )
    Local aSvAlias := GetArea()
    Local aItems := {}
    Local aRecAntecipa := {}
    Local cOperations := "11|12|13|14"              // 11-Prorrogação de vencimentos | 12-Bonificação | 13-Devolução | 14-Liberação de NCC
    Local nPosOperation := AFTER_MOVTYPE            // [5]-Posição do tipo de operação

    Default lAutomato := .F.

    aRecAntecipa := RSKRecAntecipa( lAutomato )
    If !Empty( aRecAntecipa )
        aEval( aRecAntecipa, {|x|  Iif( alltrim( Str( x[ nPosOperation ] ) )  $ cOperations, Aadd( aItems , aClone(x) ), ) } )
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aRecAntecipa )
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRecAntecipa
Função que busca os registros do Antecipa para execução das funções do Pos venda.
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, dados retornados pela plataforma do Antecipa. Para informações, 
    verifique a documentação do retorno da função GetRSKItems para o tipo 4.
@author  Marcia Junko
@since   27/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRecAntecipa( lAutomato )
    Local aSvAlias  := GetArea()
    Local aItems := {}
    Local aProperties := {}
    Local aCreditUnits := {}
    Local aNumberProp := {}
    Local aERPID := {}
    Local aAuxCred := {}
    Local aObject := {}
    Local cAction := ''
    Local cERPIDFrom := ''
    Local cERPIDTo := ''
    Local cResult := ''
    Local cContent := ''
    Local cPropertie := ''
    Local cBranch := ''
    Local cERPId := ''
    Local nRec := 0
    Local nProp := 0
    Local nSub := 0
    Local nLen := 0
    Local nBranchSize := FWSizeFilial()
    Local nSAccBranch  := TamSX3( "E1_FILIAL")[1] 
    Local nSAccPrefix  := TamSX3( "E1_PREFIXO")[1]
    Local nSAccNumber  := TamSX3( "E1_NUM" )[1]
    Local nSAccParcel  := TamSx3( "E1_PARCELA" )[1]
    Local nSAccType    := TamSx3( "E1_TIPO" )[1]
    Local xValue := NIL
    Local oRest
    Local oJSON
    Local oRecord
    Local oCreditUnits

    Default lAutomato := .F.
     
    cERPIDFrom  := cEmpAnt + "|              "
    cERPIDTo    := cEmpAnt + "|||||||||||||||"

    cAction := "/integration/api/v2/bearers?ErpId.from=" + Escape( cERPIDFrom ) + "&ErpId.to=" + Escape( cERPIDTo ) + "&AppCode=Risk"
    aProperties := { 'tenantId', 'platformId', 'erpId', 'date', 'operation', 'history', 'localAmount', 'feeAmount', 'debitDate', ;
            'creditUnits', 'creditAmount', 'discountAmount', 'feeAmountOrigin', 'newDueDate' }

    If !lAutomato
        cResult := RSKRestExec( RSKGET, cAction, @oRest, NIL, ANTECIPA, AUTH, .F. )   // GET ### 2=Antecipa ### 1=URL de autenticação no RAC
    Else
        cResult := RskADVPRData( 'RSKJobCommand' )
    EndIf
    
    If !Empty( cResult )
        oJSON := JSONObject():New()
        oJson:fromJson( cResult )

        aObject := oJSON:GetNames()

        If ValType( aObject ) == "A" 
            SE1->( DbSetOrder(1) )  //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

            For nRec := 1 to len( oJSON )
                oRecord := oJSON[ nRec ]  

                cContent    := ''
                xValue      := NIL
                aCreditUnits := {}

                //------------------------------------------------------------------------------
                // Trata somente as propriedades necessárias para o fluxo
                //------------------------------------------------------------------------------
                For nProp := 1 to len( aProperties )                       
                    cPropertie := aProperties[ nProp ]
                    xValue := oRecord[ cPropertie ]  
                    If Valtype( xValue ) != "U"
                        If cPropertie == 'erpId'
                            cERPId := StrTran( xValue, '|', ';')
                            aErpID := StrTokArr2( xValue , '|', .T.)  
                            cContent += cERPId      

                            If SE1->( MSSeek( Padr( aERPID[2], nSAccBranch ) + Padr( aERPID[3], nSAccPrefix ) + Padr( aERPID[4], nSAccNumber ) + ;
                                    Padr( aERPID[5], nSAccParcel ) + Padr( aERPID[6], nSAccType ) ) )
                                cBranch := SE1->E1_FILORIG 
                            Else 
                                cBranch := Padr( aErpID[2], nBranchSize )  
                            EndIf 
                            
                        ElseIf cPropertie == 'creditUnits' 
                            cContent += ' '
                            oCreditUnits := oRecord:GetJsonObject( "creditUnits" )
                            For nSub := 1 to len( oCreditUnits )
                                aAuxCred := Array(8)
                                oSubItems := oCreditUnits[ nSub ]

                                aERPID := StrToKArr2( oSubItems[ 'creditErpId' ], '|', .T. )

                                aAuxCred[1] := oSubItems[ 'creditErpId' ]   // ERPID completo
                                aAuxCred[2] := aERPID[ ERPID_COMPANY ]      // [1]-empresa
                                aAuxCred[3] := aERPID[ ERPID_BRANCH ]       // [2]-filial
                                aAuxCred[4] := aERPID[ ERPID_PREFIX ]       // [3]-prefixo
                                aAuxCred[5] := aERPID[ ERPID_INVOICE ]      // [4]-numero do titulo
                                aAuxCred[6] := aERPID[ ERPID_PARCEL ]       // [5]-parcela
                                aAuxCred[7] := aERPID[ ERPID_TYPE]          // [6]-tipo
                                aAuxCred[8] := oSubItems[ 'creditAmount' ]  // valor a ser compensado

                                aAdd( aCreditUnits, aAuxCred )
                            Next
                        ElseIf 'id' $ Lower( cPropertie )
                            cContent += StrTran( xValue, '-', '')
                        Else
                            If Valtype( xValue ) == "N"                            
                                cContent += Alltrim( Str( xValue ) )
                            Else
                                cContent += xValue
                            EndIf
                        EndIf
                    Else
                        cContent += ' '
                    EndIF
                    
                    cContent += '|'
                Next

                cContent += cBranch + '|'

                If !Empty( cContent ) 
                    cContent := Subs( cContent, 1, Len( cContent ) - 1 )

                    Aadd( aItems, StrtokArr( cContent, '|' ) )
                ENDIF

                nLen := Len( aItems )
                aItems[ nLen ][ AFTER_CREDITUNITS ] := aClone( aCreditUnits )     // [10]-Vetor com as notas de crédito
    
                //------------------------------------------------------------------------------
                // Ajusta o conteúdo para o formato necessário
                //------------------------------------------------------------------------------            
                aItems[ nLen ][ AFTER_ERPID ] := StrTran( aItems[ nLen ][ AFTER_ERPID ], ';', '|' )     // [3]-Id de identificação do Titulo

                //------------------------------------------------------------------------------
                // Ajusta as posições de valor
                //------------------------------------------------------------------------------
                aItems[ nLen ][ AFTER_MOVTYPE ] := Val( aItems[ nLen ][ AFTER_MOVTYPE ] )                   // [5]-tipo de operação
                aItems[ nLen ][ AFTER_LOCALAMOUNT ] := Val( aItems[ nLen ][ AFTER_LOCALAMOUNT ] )           // [7]-Valor bruto da operação - valor original da parcela
                aItems[ nLen ][ AFTER_FEEAMOUNT ] := Val( aItems[ nLen ][ AFTER_FEEAMOUNT ] )               // [8]-Valor do custo da operação 
                aItems[ nLen ][ AFTER_CREDITAMOUNT ] := Val( aItems[ nLen ][ AFTER_CREDITAMOUNT ] )         // [11]-Valor da soma das NCCs utilizadas nessa operação 
                aItems[ nLen ][ AFTER_DISCOUNTAMOUNT ] := Val( aItems[ nLen ][ AFTER_DISCOUNTAMOUNT ] )     // [12]-Valor do desconto a ser aplicado 
                aItems[ nLen ][ AFTER_FEEAMOUNTORIGIN ] := Val( aItems[ nLen ][ AFTER_FEEAMOUNTORIGIN ] )   // [13]-Estorno da taxa de antecipação
            Next
        EndIf
    EndIF      

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aProperties )
    FWFreeArray( aCreditUnits )
    FWFreeArray( aNumberProp )
    FWFreeArray( aERPID )
    FWFreeArray( aAuxCred )
    FWFreeArray( aObject )
    FreeObj( oRest )
    FreeObj( oJSON )
    FreeObj( oRecord ) 
    FreeObj( oCreditUnits )
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskJobFil
Função chamada pelo RskJobCommand para processamento de rotinas de processamento
por filial.

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando 
    executada por User Function
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT
@since  30/04/2021 
/*/
//-------------------------------------------------------------------
Static Function RskJobFil( aParam, cFil, lAutomato )
    If aParam == Nil .And. cFil == Nil  
        aParam  := cEmpAnt
        cFil    := cFilAnt
    EndIf
    StartJob("RskJobBranch", GetEnvServer() , .T., aParam, cFil, lAutomato )
Return Nil 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskJobBranch
Função que cria uma thread separada para processsar as rotinas por filial. 

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando 
    executada por User Function
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT
@since  30/04/2021 
/*/
//-------------------------------------------------------------------
Function RskJobBranch( aParam, cFil, lAutomato )
    Local lJob      := RskProcJob( aParam, cFil )
    Local lLock     := LockByName("RskJobBranch", .T., .T. )
    Local lRskNTkt  := .T. //Geração\Cancelamento de ticket de crédito automática após liberação de pedidos.

    If lLock
        lRskNTkt  := SuperGetMv( "MV_RSKNTKT", .F., .T. )  

        //---------------------------------------------
        // Cancela os tickets de credito.  
        //---------------------------------------------
        If lRskNTkt
            I18N( STR0030, { cEmpAnt, cFilAnt} ) 
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0030, { cEmpAnt, cFilAnt } )) //"Executando o processo => Geracao de Cancelamento de Ticket Empresa: #1 Filial: #2"       
            RskCanTicket( lAutomato )
        EndIf

        //--------------------------------------------------------------------------
        // Funcao que envia os tickets de credito diretamente para plataforma risk.
        //--------------------------------------------------------------------------
        If AR0->( ColumnPos( "AR0_RCOUNT" ) ) > 0 
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0031, { cEmpAnt, cFilAnt } ))  //"Executando o processo => Enviando Ticket de Credito para Plataforma Risk Empresa: #1 Filial: #2" 
            //------------------------------------------------------------------------------
            // Envia os tickets de credito que foram cancelados.
            // Os tickets cancelados deverao ser enviados primeiro para evitar rejeicao
            // de credito devido o valor pre-autorizado ser proximo do limite disponivel.
            //------------------------------------------------------------------------------
            RskPostTicket( AR0_STT_CANCELED, lAutomato )        // 4=Cancelado 
            
            //---------------------------------------------
            // Envia os tickets de credito para analise.
            //---------------------------------------------
            RskPostTicket( AR0_STT_AWAIT, lAutomato )           // 0=Aguardando Envio
        EndIf  
            
        //--------------------------------------------------------------------------
        // Envia as concessões de credito diretamente para plataforma risk.
        //--------------------------------------------------------------------------
        If AliasInDic( "AR5" ) .And. AR5->( ColumnPos( "AR5_RCOUNT" ) ) > 0   
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0032, { cEmpAnt, cFilAnt } )) //"Executando o processo => Enviando Concessao de Credito para Plataforma Risk Empresa: #1 Filial: #2"       
            RskPostConcession( lAutomato )              
        EndIf

        //--------------------------------------------------------------------------
        // Envia as NFS Mais Negócios diretamente para plataforma risk.
        //--------------------------------------------------------------------------
        If AR1->(ColumnPos("AR1_RCOUNT")) > 0
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0033, { cEmpAnt, cFilAnt } ))    //"Executando o processo => Enviando NFS Mais Negocios para Plataforma Risk Empresa: #1 Filial #2"
            RskPostNFS( lAutomato )  
        EndIf

        UnLockByName( "RskJobBranch", .T., .T. )
    Else
        LogMsg( "RskJobBranch", 23, 6, 1, "", "", STR0034 )    //"Job já está em execução por outra instância" 
    EndIf

    If lJob   
        RPCClearEnv()        
    EndIF
Return Nil  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskMonitCancel
Função que busca as notas fiscais pendentes de retorno da Sefaz
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os códigos da AR1 para processamento do cancelamento
    [1] - filial
    [2] - código de identificação
@author  Claudio Yoshio Muramatsu
@since   14/09/2021
/*/
//-------------------------------------------------------------------------------------
Static Function RskMonitCancel( lAutomato )
    Local aSvAlias       := GetArea()
    Local aItems         := {}
    Local aBranches      := {}
    Local aKnownBranches := {}
    Local cTemp          := ''
    Local cBranch        := ''
    Local cQuery         := ''

    Default lAutomato := .F.
    
    aBranches := FWLoadSM0()
    cQuery :=   "SELECT AR1_FILIAL FILIAL, AR1_COD CODIGO " + ;
                " FROM " + RetSqlName( "AR1" ) + " AR1 " + ;
                " WHERE AR1.AR1_STATUS = '" + AR1_STT_CANCELINGSEF + "' " + ; 
                    " AND AR1.D_E_L_E_T_ = ' ' " + ;
                " ORDER BY AR1_FILIAL,AR1_COD "
    
    cQuery := ChangeQuery( cQuery )
    cTemp  := MPSysOpenQuery( cQuery )

    While ( cTemp )->( !EOF() )
        cBranch := SeekFullBranch( aBranches, @aKnownBranches, ( cTemp )->FILIAL )

        aAdd( aItems, { cBranch, ( cTemp )->CODIGO } )

        ( cTemp )->( DBSkip() )
    End

    ( cTemp )->( DBCloseArea() )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )    
    FWFreeArray( aBranches )    
    FWFreeArray( aKnownBranches )
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobPost
Função chamada pelo Schedule para execução da rotina RskJobFil.
Comandos da Plataforma para o Protheus nos processos de atualizações.

@param aParam, array, vetor com as informações para execução da função via Schedule.

@author  Daniel Moda
@since   14/10/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKJobPost( aParam As Array)
    Local cFil           As Character
    Local lConciliation  As Logical
    Local nTypeSchedule  As Numeric
    Local cLockSchedule  As Character
    Local aTasksSchedule As Array
    Local nTypeProcess   As Numeric

    cFil           := NIL
    lConciliation  := .F.
    nTypeSchedule  := SCHEDULE_JOBPOST // 2=RskJobPost
    cLockSchedule  := 'RSKJobPost'
    aTasksSchedule := {}

    If RskProcJob( aParam, cFil )
        nTypeProcess := SuperGetMv( "MV_RSKSPLS", .F., 1 ) //1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records

        If nTypeProcess == 3  // 3-Post, Movement e Records
            RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule )
        EndIf
        RPCClearEnv()
    EndIf
    
    FWFreeArray( aTasksSchedule )    
    FWFreeArray( aParam )

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobGetMovement
Função chamada pelo Schedule para execução da rotina RSKUpdEntity.
Comandos da Plataforma para o Protheus nos processos de movimentações.
Obs. Quando o parâmetro MV_RSKSPLS for 2 executará os comandos para de atualizações
nessa chamada.

@param aParam, array, vetor com as informações para execução da função via Schedule.

@author  Daniel Moda
@since   14/10/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKJobGetMovement( aParam As Array)
    Local cFil           As Character
    Local lConciliation  As Logical
    Local nTypeSchedule  As Numeric
    Local cLockSchedule  As Character
    Local aTasksSchedule As Array
    Local nTypeProcess   As Numeric

    cFil           := NIL
    lConciliation  := .F.
    nTypeSchedule  := SCHEDULE_JOBGETMOVEMENT // 3=RSKJobGetMovement
    cLockSchedule  := 'RSKJobGetMovement'
    aTasksSchedule := { NEWTICKET, UPDTICKET , UPDARINVOICE, MONITCANCEL, AFTERSALES, NFSCANCEL }

    If RskProcJob( aParam, cFil )
        nTypeProcess := SuperGetMv( "MV_RSKSPLS", .F., 1 ) //1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records

        If nTypeProcess == 2 .Or. nTypeProcess == 3 // 2=Post+Movement e Records # 3-Post, Movement e Records
            RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule )
        EndIf
        If nTypeProcess == 2 // 2=Post+Movement e Records
            nTypeSchedule  := SCHEDULE_JOBPOST // 2=RskJobPost
            cLockSchedule  := 'RSKJobPost'
            aTasksSchedule := {}
            RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule )
        EndIf

        RPCClearEnv()
    EndIf

    FWFreeArray( aTasksSchedule )
    FWFreeArray( aParam )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobGetRecords
Função chamada pelo Schedule para execução da rotina RSKUpdEntity.
Comandos da Plataforma para o Protheus nos processos de cadastros.

@param aParam, array, vetor com as informações para execução da função via Schedule.

@author  Daniel Moda
@since   14/10/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKJobGetRecords( aParam As Array)
    Local cFil           As Character
    Local lConciliation  As Logical
    Local nTypeSchedule  As Numeric
    Local cLockSchedule  As Character
    Local aTasksSchedule As Array
    Local nTypeProcess   As Numeric

    cFil           := NIL
    lConciliation  := .F.
    nTypeSchedule  := SCHEDULE_JOBGETRECORDS // 4=RSKJobGetRecords
    cLockSchedule  := 'RSKJobGetRecords'
    aTasksSchedule := { CONCESSION , CLIENTPOSITION }

    If RskProcJob( aParam, cFil )
        nTypeProcess := SuperGetMv( "MV_RSKSPLS", .F., 1 ) //1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records

        If nTypeProcess == 2 .Or. nTypeProcess == 3 // 2=Post+Movement e Records # 3-Post, Movement e Records
            RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule )
        EndIf
        RPCClearEnv()
    EndIf
    
    FWFreeArray( aTasksSchedule )
    FWFreeArray( aParam )
Return
