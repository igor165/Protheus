#include "protheus.ch"

/*-----------------------------------------------------
                    WIZARD e RSKXFUN
-----------------------------------------------------*/
// Tipos de natureza
#DEFINE INCOME_NATURE            1   // Receita 
#DEFINE EXPENSE_NATURE           2   // Despesa

// Tipos de plataforma
#DEFINE RISK                    1   // Plataforma Risk
#DEFINE ANTECIPA                2   // Plataforma Antecipa

// URL do RAC
#DEFINE AUTH                    1   // URL de autenticação no RAC
#DEFINE SERVICE                 2   // URL de autenticação de serviços

// Ações do Rest
#DEFINE RSKGET                  'GET'   // Executa a ação de GET
#DEFINE RSKPOST                 'POST'  // Executa a ação de POST 
#DEFINE RSKPUT                  'PUT'   // Executa a ação de PUT

// Posições do retorno da RSKTRBFields
#DEFINE TRBHEADER                1  // Informações no modelo aHeader
#DEFINE TRBSTRUCT                2  // Informações no modelo Struct

/*-----------------------------------------------------
                    JOB COMMANDS
-----------------------------------------------------*/
// Ações do Job Commands
#DEFINE NEWTICKET           1   // Criação de novo ticket
#DEFINE UPDTICKET           2   // Atualiza ticket
#DEFINE UPDARINVOICE        3   // Atualiza fatura
#DEFINE AFTERSALES          4   // Pos vemda
#DEFINE CONCESSION          5   // Concessão 
#DEFINE NFSCANCEL           7   // Cancelamento de NFS Mais Negócios

#DEFINE CONCILIATION        9   // Conciliação  
#DEFINE CLIENTPOSITION     10   // Posição do Cliente
#DEFINE MONITCANCEL        11   // Tentativa de Cancelamento de NFS Mais Negócios

// Posições do array de retorno da função RSKRecbyBranch()
#DEFINE REC_COMPANY         1   // grupo de empresa
#DEFINE REC_BRANCH          2   // codigo da filial
#DEFINE REC_CNPJ            3   // CNPJ/CGC da filial
#DEFINE REC_NAME            4   // nome da filial
#DEFINE REC_ITEMS           5   // lista de registros de acordo com o tipo. Para informações, verifique a documentação do retorno da função GetRSKItems

/*-----------------------------------------------------
                CRIAÇÃO DE TICKETS
-----------------------------------------------------*/
// Posições do Array
#DEFINE TKT_BRANCH          1   // filial
#DEFINE TKT_ORDER           2   // pedido
#DEFINE TKT_CUSTOMER        3   // cliente
#DEFINE TKT_UNIT            4   // loja
#DEFINE TKT_SEQUENCE        5   // sequencia

/*-----------------------------------------------------
                ATUALIZAÇÃO DE TICKETS
-----------------------------------------------------*/
// Posições do Array
#DEFINE UPD_T_BRANCH        1   // filial
#DEFINE UPD_T_TICKET        2   // numero do ticket
#DEFINE UPD_T_STATUS        3   // status
#DEFINE UPD_T_REASON        4   // motivo da reprovação
#DEFINE UPD_T_ID            5   // id do ticket
#DEFINE UPD_T_NOTE          6   // observação
#DEFINE UPD_T_CREDITID      7   // ID da linha de crédito
#DEFINE UPD_T_EVALDATE      8   // data da avaliação de crédito pela plataforma
#DEFINE UPD_T_AUTHCODE      9   // código de pré-autorização
#DEFINE UPD_T_TYPEINV      10   // tipo de faturamento ( 1=Parcial ou 2=Total )
#DEFINE UPD_T_BALANCE      11   // saldo do ticket

/*-----------------------------------------------------
                ATUALIZAÇÃO DE POSIÇÂO DE CLIENTES
-----------------------------------------------------*/
// Posições do Array
#DEFINE UPD_C_ID            1   // id do cliente
#DEFINE UPD_C_CPNJ          2   // numero do CNPJ
#DEFINE UPD_C_STATUS        3   // status
#DEFINE UPD_C_DESCSTA       4   // Descrição do status da posição do cliente.
#DEFINE UPD_C_TYPECLI       5   // Tipo de Cliente.
#DEFINE UPD_C_DAYSPAYOVER   6   // Dias em atraso.
#DEFINE UPD_C_TOTALPUR      7   // Limite total do cliente
#DEFINE UPD_C_AVALIPUR      8   // Limite disponivel do cliente
#DEFINE UPD_C_RELEAPUR      9   // Limite liberado do cliente
#DEFINE UPD_C_PREAUTPUR     10  // Limite pré-autorizado do cliente
#DEFINE UPD_C_USEPUR        11  // Valor faturado do cliente

/*-----------------------------------------------------
                NFS Mais Negócios ( AR1 )
-----------------------------------------------------*/
// Posições do Array
#DEFINE UPD_I_BRANCH        1   // filial
#DEFINE UPD_I_INVOICE       2   // numero do documento
#DEFINE UPD_I_INVOICEID     3   // id da fatura
#DEFINE UPD_I_RETURN        4   // codigo do retorno
#DEFINE UPD_I_MESSAGE       5   // mensagem do retorno
#DEFINE UPD_I_TRANSACTION   6   // codigo da transação
#DEFINE UPD_I_BANKSLIP      7   // boleto em base64
#DEFINE UPD_I_TOTAL_FEE     8   // valor total das taxas
#DEFINE UPD_I_TOTAL_PARC    9   // valor total das parcelas
#DEFINE UPD_I_RECEIPT_DT    10  // data recebimento parceiro
#DEFINE UPD_I_PARCELS       11  // informações das parcelas
#DEFINE UPD_I_ISSUERTYPE    13  // tipo de recibo do emissor

// Posições do Array informações das parcelas - UPD_I_PARCELS
#DEFINE PARCEL_NUMBER       1 // numero da parcela
#DEFINE PARCEL_DUEDATE      2 // data de vencimento da parcela
#DEFINE PARCEL_VALUE        3 // valor da parcela
#DEFINE PARCEL_RECAMOUNT    4 // valor de recebimento parceiro
#DEFINE PARCEL_AMOUNTDT     5 // data de recebimento parceiro
#DEFINE PARCEL_FEEID        6 // id tipo de taxa  
#DEFINE PARCEL_FEETYPE      7 // tipo de taxa Parcela
#DEFINE PARCEL_FEEVALUE     8 // valor da taxa Parcela
#DEFINE PARCEL_RSVALUE      9 // valor da taxa da parcela em reais 

// Posições do Array de títulos
#DEFINE BILL_OPERATION      1   // Tipo do título gerado
#DEFINE BILL_BRANCH         2   // Filial
#DEFINE BILL_PREFIX         3   // Prefixo do documento
#DEFINE BILL_NUMBER         4   // Numero do titulo
#DEFINE BILL_INSTALLMENT    5   // Parcela do título
#DEFINE BILL_TYPE           6   // Tipo do título
#DEFINE BILL_CUSTOMER       7   // Código do cliente
#DEFINE BILL_CUST_UNIT      8   // Loja do cliente
#DEFINE BILL_VALUE          9   // Valor do título
#DEFINE BILL_DUEDATA        10  // Data de vencimento do título

// Tipos de títulos gerados
#DEFINE BILL_MAIN           "1" // Título principal
#DEFINE BILL_FEE            "2" // Título de taxas

// Status AR1
#DEFINE AR1_STT_AWAIT        "0"     // Aguardando Envio
#DEFINE AR1_STT_ANALYSIS     "1"     // Em Análise   
#DEFINE AR1_STT_APPROVED     "2"     // Aprovada
#DEFINE AR1_STT_REJECTED     "3"     // Rejeitada
#DEFINE AR1_STT_CANCELED     "4"     // Cancelada
#DEFINE AR1_STT_FLIMSY       "5"     // Inconsistente
#DEFINE AR1_STT_CANCELING    "6"     // Em cancelamento
#DEFINE AR1_STT_CANCELINGSEF "7"     // Em cancelamento Sefaz
#DEFINE AR1_STT_CANCELINGSUP "8"     // Em cancelamento Supplier
#DEFINE AR1_STT_ERRORCANCERP "9"     // Erro no Cancelamento ERP
#DEFINE AR1_STT_CANCREPROSUP "A"     // Cancelamento Reprovado Supplier
#DEFINE AR1_STT_DENIED       "B"     // Negada
#DEFINE AR1_STT_CANSUPOK     "C"     // NF Cancelada na Supplier

/*-----------------------------------------------------
                Movimentações ( AR2 )
-----------------------------------------------------*/
// Tipos de movimento ( AR2_MOV )
#DEFINE AR2_MOV_RECEIVE        "1"     // Receber
#DEFINE AR2_MOV_FEE            "2"     // Taxa
#DEFINE AR2_MOV_BONUS          "3"     // Bonificação
#DEFINE AR2_MOV_EXTENSION      "4"     // Prorrogação
#DEFINE AR2_MOV_DEVOLUTION     "5"     // Devolução
#DEFINE AR2_MOV_BLOCK_NCC      "6"     // Bloqueia NCC
#DEFINE AR2_MOV_RELEASE_NCC    "7"     // Libera NCC
#DEFINE AR2_MOV_PARTIAL_NCC    "8"     // NCC-Baixa Parcial
#DEFINE AR2_MOV_TOTAL_NCC      "9"     // NCC-Baixa Total
#DEFINE AR2_MOV_CANCEL         "A"     // Cancelamento


/*-----------------------------------------------------
                        POS VENDA
-----------------------------------------------------*/
// Posições do Array - Pos Venda
#Define AFTER_TENANTID            1   // ID do Tenant na Plataforma e Fluig
#Define AFTER_PLATFORMID          2   // PK da plataforma posteriormente enviada no POST para conclusão da sincronia da parcela
#Define AFTER_ERPID               3   // Id de identificação do Titulo ( ArInvoiceInstallment )
#Define AFTER_MOVDATE             4   // Data do movimento (dataHoraConclusaoProcessamento da API Supplier) com pattern 
#Define AFTER_MOVTYPE             5   // tipo de operação
#Define AFTER_HISTORY             6   // Descrição do histórico
#Define AFTER_LOCALAMOUNT         7   // Valor bruto da operação - valor original da parcela ( numero )
#Define AFTER_FEEAMOUNT           8   // Valor do custo da operação ( numero )
#Define AFTER_DEBITDATE           9   // data do débito do parceiro ( Data em que ocorrerá o débito do valor ao parceiro )
#Define AFTER_CREDITUNITS         10  // Array com a relação de notas de credito e seu valor a ser compensado.
#Define AFTER_CREDITAMOUNT        11  // Valor da soma das NCCs utilizadas nessa operação ( Terá valor apenas quando a operação for 12-Bonificação - numero )
#Define AFTER_DISCOUNTAMOUNT      12  // Valor do desconto a ser aplicado ( Terá valor apenas quando a operação for 12-Bonificação - numero )
#Define AFTER_FEEAMOUNTORIGIN     13  // Estorno da taxa de antecipação ( Terá valor apenas quando a operação for 4-Divergência comercial ou 13-Devolução - numero )
#Define AFTER_NEWDUEDATE          14  // Nova data de vencimento ( Terá valor apenas quando a operação for 11-Prorrogação )
#Define AFTER_BRANCH              15  // Filial

// Posições da propriedade ERPID do array Pos-Venda
#DEFINE ERPID_COMPANY       1   // empresa
#DEFINE ERPID_BRANCH        2   // filial
#DEFINE ERPID_PREFIX        3   // prefixo
#DEFINE ERPID_INVOICE       4   // número do título
#DEFINE ERPID_PARCEL        5   // parcela
#DEFINE ERPID_TYPE          6   // tipo

// Posições da propriedade CREDITUNITS do array Pos-Venda
#DEFINE CREDITUNITS_KEY     1   // ID de identificação da nota de crédito
#DEFINE CREDITUNITS_COMPANY 2   // empresa
#DEFINE CREDITUNITS_BRANCH  3   // filial
#DEFINE CREDITUNITS_PREFIX  4   // prefixo
#DEFINE CREDITUNITS_INVOICE 5   // número do titulo
#DEFINE CREDITUNITS_PARCEL  6   // parcela
#DEFINE CREDITUNITS_TYPE    7   // tipo
#DEFINE CREDITUNITS_VALUE   8   // Valor

// Ações do Pos Venda
#DEFINE PV_PRO              11  // Prorrogação
#DEFINE PV_BON              12  // Bonificaçãp
#DEFINE PV_DEV              13  // Devolução
#DEFINE PV_LIB_NCC          14  // Liberação de NCC

// Array por tipo de movimento ( retorno da função RskGroupMovements)
#DEFINE AFTER_GRP_TYPE      1  // Tipo de movimento
#DEFINE AFTER_GRP_ITEMS     2  // Array itens do movimento

// Posições do array itens do movimento
#DEFINE AFTER_ARR_KEY       1  // Chave
#DEFINE AFTER_ARR_DATA      2  // array com os dados do item 
#DEFINE AFTER_ARR_AMOUNT    3  // valor bruto da operação
#DEFINE AFTER_ARR_FEE       4  // Valor do custo da operação
#DEFINE AFTER_ARR_FEEORI    5  // Estorno da taxa de antecipação
#DEFINE AFTER_ARR_ERPID     6  // ERPID
#DEFINE AFTER_ARR_CUNIT     7  // Nota de crédito

// Posições do array itens de devolução ( retorno da função RskVldDev )
#DEFINE AFTER_DEV_KEY       1  // Chave
#DEFINE AFTER_DEV_COUNT     2  // Quantidade de notas
#DEFINE AFTER_DEV_ITEMS     3  // Array com as notas de entrada

/*-----------------------------------------------------
                    CONCILIAÇÃO
-----------------------------------------------------*/
// Posições do Array - Conciliação
#DEFINE  BANK_ID            1   // Id da conciliação (guide)
#DEFINE  BANK_GROUP         2   // Código do grupo
#DEFINE  BANK_DATE          3   // Data dos lançamentos
#DEFINE  BANK_ACCOUNT_ID    4   // Id da conta (guide)
#DEFINE  BANK_CODE          5   // Banco
#DEFINE  BANK_AGENCY        6   // Agencia 
#DEFINE  BANK_ACCOUNT       7   // Conta corrente
#DEFINE  BANK_PARCEL        8   // Parcela 
#DEFINE  BANK_PARCEL_NUM    9   // Número de parcelas 
#DEFINE  BANK_INVOICE       10  // Número da nota fiscal 
#DEFINE  BANK_TRANS_CODE    11  // Código da transação 
#DEFINE  BANK_EVENT_TYPE    12  // Tipo de evento 
#DEFINE  BANK_EVENT         13  // Descrição do tipo de evento
#DEFINE  BANK_ENTRY_TYPE    14  // Tipo de lançamento 
#DEFINE  BANK_TRANS_TYPE    15  // Tipo de transação 
#DEFINE  BANK_TRANS_DESC    16  // Descrição do tipo de transação
#DEFINE  BANK_FUTURE        17  // Lançamento Futuro ?
#DEFINE  BANK_ENTRY_DATE    18  // Data do lançamento 
#DEFINE  BANK_EVENT_DATE    19  // Data do evento 
#DEFINE  BANK_ORI_MAT_DATE  20  // Data do vencimento original da parcela 
#DEFINE  BANK_ACT_MAT_DATE  21  // Data do vencimento atual da parcela 
#DEFINE  BANK_TRANS_MAIN    22  // Valor principal da transação 
#DEFINE  BANK_TRANS_TOTAL   23  // Valor total da transação 
#DEFINE  BANK_PARC_MAIN     24  // Valor principal da parcela 
#DEFINE  BANK_PARC_TOTAL    25  // Valor total da parcela 
#DEFINE  BANK_ENTRY_VALUE   26  // Valor do lançamento 
#DEFINE  BANK_PARC_COST     27  // Custo de antecipação da parcela 
#DEFINE  BANK_TAXES         28  // Valor dos impostos
#DEFINE  BANK_PART_CNPJ     29  // Cnpj do parceiro (SIGAMAT)
#DEFINE  BANK_CUST_CNPJ     30  // Cnpj/Cpf do cliente 
#DEFINE  BANK_DIVERGENCY    31  // Evento divergencia comercial
#DEFINE  BANK_ENTRY_ID      32  // Id do lançamento (guide)
#DEFINE  COD_EMP            33  // Código Empresa
#DEFINE  COD_FIL            34  // Código Filial
#DEFINE  BANKP_CODE         1   // Banco
#DEFINE  BANKP_AGENCY       2   // Agencia 
#DEFINE  BANKP_ACCOUNT      3   // Conta corrente
#DEFINE  BANKJ_CODE         4   // Banco
#DEFINE  BANKJ_AGENCY       5   // Agencia 
#DEFINE  BANKJ_ACCOUNT      6   // Conta corrente

/*-----------------------------------------------------
                    Ticket ( AR0 )
-----------------------------------------------------*/
// Status AR0
#DEFINE AR0_STT_AWAIT        "0"     // Aguardando Envio
#DEFINE AR0_STT_ANALYSIS     "1"     // Em Análise   
#DEFINE AR0_STT_APPROVED     "2"     // Aprovada
#DEFINE AR0_STT_DISAPPROVED  "3"     // Reprovado
#DEFINE AR0_STT_CANCELED     "4"     // Cancelado
#DEFINE AR0_STT_EXPIRED      "5"     // Vencido
#DEFINE AR0_STT_PARTIALLY    "6"     // Faturado Parcialmente
#DEFINE AR0_STT_BILLED       "7"     // Faturado

// Tipos de Reprovação ( AR0_MREPRO )
#DEFINE AR0_NOT_REPROVED     " "     // Sem reprovação
#DEFINE AR0_REPRO_EXP        "1"     // Credito Vencido
#DEFINE AR0_REPRO_LIM        "2"     // Limite de Credito
#DEFINE AR0_REPRO_RUL        "3"     // Por Regras

// Tipos de Faturmento
#DEFINE AR0_BILL_PART        "1"     // Faturamento Parcial
#DEFINE AR0_BILL_TOTAL       "2"     // Faturado

// Status do saldo do ticket de crédito
#DEFINE AR0_SLD_NFOUND       "0"    // Pedido de venda não foi encerrado por residuo ou pedido não possui ticket de credito relacionado.
#DEFINE AR0_SLD_RELEASED     "1"    // Saldo do ticket de credito liberado
#DEFINE AR0_SLD_UNRELEASED   "2"    // Saldo do ticket de credito nao liberado.

// Posições do Array de Tickets amarrados com a Nota Fiscal
#DEFINE CREDIT_TICKET_ID       1
#DEFINE SALES_ORDER_NUMBER     2
#DEFINE BILLED_AMOUNT          3

/*-----------------------------------------------------
                    LOG (AR4)
-----------------------------------------------------*/
// Tipos de Movimento (AR4)
#DEFINE LOG_MOV_MAIN            "1"     // Principal
#DEFINE LOG_MOV_FEE             "2"     // Taxas
#DEFINE LOG_MOV_BONUS           "3"     // Bonificação
#DEFINE LOG_MOV_EXTENSION       "4"     // Prorrogação
#DEFINE LOG_MOV_RELEASE_NCC     "5"     // Libera NCC
#DEFINE LOG_MOV_BLOCK_NCC       "6"     // Bloqueia NCC
#DEFINE LOG_MOV_DEVOLUTION      "7"     // Devolução
#DEFINE LOG_MOV_CONCILIATION    "8"     // Conciliação
#DEFINE LOG_MOV_NI              "9"     // Não Integrado

// Status AR4   
#DEFINE AR4_STT_RECEPTION       "1"     // Recepcionado 
#DEFINE AR4_STT_MOVED           "2"     // Movimentado      
#DEFINE AR4_STT_ERROR           "3"     // Corrigir
#DEFINE AR4_STT_CANCEL          "4"     // Camcelado
#DEFINE AR4_STT_SCHED           "5"     // Agendado
#DEFINE AR4_STT_CUSTOM          "6"     // Customizado

// Status Risk
#DEFINE STT_RSK_CONFIRMED    "1"     // Confirmado
#DEFINE STT_RSK_PROCESSED    "2"     // Processado

/*-----------------------------------------------------
                Status RISK ( _STARSK )
-----------------------------------------------------*/
#DEFINE STARSK_SUBMIT        "1"     // Enviar
#DEFINE STARSK_SENT          "2"     // Enviado
#DEFINE STARSK_RECEIVED      "3"     // Recebido
#DEFINE STARSK_CONFIRMED     "4"     // Confirmado
#DEFINE STARSK_CANCELED      "5"     // Cancelado

/*-----------------------------------------------------
                Concessão ( AR5 )
-----------------------------------------------------*/
// Posições do Array
#DEFINE CONCESSION_BRANCH                   1   // Filial da Concessão
#DEFINE CONCESSION_ID		                2   // Id da Concessão
#DEFINE CONCESSION_RSKID                    3   // Id da Concessão Risk
#DEFINE CONCESSION_CUSTBRANCH               4   // Filial do cliente
#DEFINE CONCESSION_CUSTID                   5   // Codigo do cliente
#DEFINE CONCESSION_CUSTUNIT                 6   // Loja do cliente
#DEFINE CONCESSION_DESIREDLIMIT             7   // Limite Desejado
#DEFINE CONCESSION_APPROVEDCREDLIMIT        8   // Limite Aprovado
#DEFINE CONCESSION_REQUESTDATE              9   // Data da Requisição
#DEFINE CONCESSION_EVALUATIONDATE           10  // Data da Avaliação
#DEFINE CONCESSION_STATUS                   11  // Status
#DEFINE CONCESSION_OBSREASON                12  // Observações
#DEFINE CONCESSION_ORIGIN                   13  // Origem (1=Plataforma ou 2=Protheus)

// Status AR5   
#DEFINE AR5_STT_AWAIT               "0" // Aguardando Envio
#DEFINE AR5_STT_ANALYSIS            "1" // Em Análise   
#DEFINE AR5_STT_APPROVED            "2" // Aprovada
#DEFINE AR5_STT_REJECTED            "3" // Rejeitada
#DEFINE AR5_STT_DENIED              "4" // Negado
#DEFINE AR5_STT_CANCELED            "5" // Cancelada
#DEFINE AR5_STT_PENDING             "6" // Pendente

// Origem da concessão
#DEFINE PLATFORM_CONCESSION         "1" // Plataforma
#DEFINE PROTHEUS_CONCESSION         "2" // Protheus


/*-----------------------------------------------------
                Posição cliente ( AR3 )
-----------------------------------------------------*/
// Crédito no parceiro
#DEFINE CREDIT_YES                  "1" // Sim
#DEFINE CREDIT_NO                   "2" // Não


/*-----------------------------------------------------
            Cancelamento de NFS Mais Negócios
-----------------------------------------------------*/
// Posições do Array
#DEFINE CANCEL_COMPANY                      1   // [1]-Chave da empresa/filial
#DEFINE CANCEL_CODE                         2   // [2]-Código da NF Mais Neg.
#DEFINE CANCEL_GUIDE                        3   // [3]-Guide do Cancelamento
#DEFINE CANCEL_STATUS                       4   // [4]-Status do cancelamento (2=aprovado;3=reprovado)
#DEFINE CANCEL_OBS                          5   // [5]-Observação
#DEFINE CANCEL_FEEVALUE                     6   // [6]-Valor da Taxa
#DEFINE CANCEL_BALANCE                      7   // [7]-Saldo do ticket
#DEFINE CANCEL_INSTALLMENT                  8   // [8]-Número da Parcela
#DEFINE CANCEL_PAYDATE                      9   // [9]-Data de Pagamento da taxa.
#DEFINE CANCEL_RETURNED                     10  // [10]-Valor do Devolvido por parcela.
#DEFINE CANCEL_INSTVALUE                    11  // [11]-Valor da parcela.
#DEFINE CANCEL_REVERSAL                     12  // [12]-Estorno da taxa.

/*-----------------------------------------------------
                SCHEDULE OPTIONS
-----------------------------------------------------*/
// Schedule JobCommand
#DEFINE SCHEDULE_JOBCOMMAND       0   // Schedule RSKJobCommand
#DEFINE SCHEDULE_JOBBANK          1   // Schedule RSKJobBank
#DEFINE SCHEDULE_JOBPOST          2   // Schedule RSKJobPost
#DEFINE SCHEDULE_JOBGETMOVEMENT   3   // Schedule RSKJobGetMovement
#DEFINE SCHEDULE_JOBGETRECORDS    4   // Schedule RSKJobGetRecords
