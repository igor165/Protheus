// constante para nome
#define APP_NAME "PMSPalm"

// constantes para versao
#define APP_MAJOR_VERSION "0"
#define APP_MINOR_VERSION "9"
#define APP_BUILD_VERSION "3"

// constantes para Autorizacao de Entrega
#define AUT_ENTREGA_SIM "1"
#define AUT_ENTREGA_NAO "2"

// constantes para indexar AFF
#define SUB_AFF_FILIAL  1
#define SUB_AFF_PROJET  2
#define SUB_AFF_REVISA  3
#define SUB_AFF_DATA    4
#define SUB_AFF_TAREFA  5
#define SUB_AFF_QUANT   6
#define SUB_AFF_OCORRE  7
#define SUB_AFF_CODMEM  8
#define SUB_AFF_USER    9
#define SUB_AFF_CONFIR 10
#define SUB_AFF_SYNCID 12
#define SUB_AFF_SYNCFL 13
#define SUB_AFF_PERC   11
#define SUB_AFF_MARK   14

// constantes para indexar AF9
#define SUB_AF9_FILIAL  1
#define SUB_AF9_PROJET  2
#define SUB_AF9_REVISA  3
#define SUB_AF9_TAREFA  4
#define SUB_AF9_NIVEL   5
#define SUB_AF9_DESCRI  6
#define SUB_AF9_UM      7
#define SUB_AF9_QUANT   8
#define SUB_AF9_COMPOS  9
#define SUB_AF9_EMAIL  10
#define SUB_AF9_GRPCOM 11
#define SUB_AF9_ORDEM  12
#define SUB_AF9_SYNCID 13
#define SUB_AF9_MARK   14

// constantes para indexar as tabelas
// utilizadas para o PalmPMS

#define PMS_TABLE 1
#define PMS_ALIAS 2

#define PMS_IDX_TABLENAME  1
#define PMS_IDX_FILENAME   2
#define PMS_IDX_EXP        3

// constantes para serem utilizadas
// na funcao dbUseArea()

#define UA_SHARED    .T.
#define UA_EXCLUSIVE .F.

#define UA_READONLY  .T.
#define UA_READWRITE .F.

#define MNU_VISUALIZAR 1
#define MNU_INCLUIR    2
#define MNU_ALTERAR    3
#define MNU_EXCLUIR    4
#define MNU_CONFTODAS  5

#define apCrLf  Chr(13) + Chr(10)

#xcommand DEFAULT <uVar1> := <uVal1> ;
                 [, <uVarN> := <uValN> ] => ;
                  <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
                 [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]


// constantes para indexar AFU
#define SUB_AFU_FILIAL  1
#define SUB_AFU_PROJET  2
#define SUB_AFU_REVISA  3
#define SUB_AFU_TAREFA  4
#define SUB_AFU_RECURS  5
#define SUB_AFU_DATA    6
#define SUB_AFU_HORAI   7
#define SUB_AFU_HORAF   8
#define SUB_AFU_HQUANT  9
#define SUB_AFU_SYNCID 10
#define SUB_AFU_SYNCFL 11

// constantes para indexar SH7
#define SUB_SH7_FILIAL 1
#define SUB_SH7_CODIGO 2
#define SUB_SH7_ALOC   3
#define SUB_SH7_DESCRI 4
#define SUB_SH7_SYNCID 5 

// constantes para indexar AE8
#define SUB_AE8_FILIAL 1
#define SUB_AE8_RECURS 2
#define SUB_AE8_DESCRI 3
#define SUB_AE8_CALEND 4
#define SUB_AE8_CONFIR 5
#define SUB_AE8_APTMRE 6
#define SUB_AE8_SYNCID 7 
