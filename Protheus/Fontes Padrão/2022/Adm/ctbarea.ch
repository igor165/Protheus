//
// Definições necessárias para a nova interface CTB
// Copyright (C) 2007, Microsiga
//

// GetScreenRes()
#define IDX_SCREEN_WIDTH  1
#define IDX_SCREEN_HEIGHT 2

// identificadores do tipo de nó
#define NODE_TYPE_UNKNOWN    0
#define NODE_TYPE_MODULE     1
#define NODE_TYPE_PROCESS    2
#define NODE_TYPE_OPERATION  4
#define NODE_TYPE_ENTRY     16
#define NODE_TYPE_UNCLASSIFIED 32

// identificadores de layout
#define LAYOUT_MODULE    "layout_module"
#define LAYOUT_UNKNOWN   "layout_unknown"

// identificadores de janela
#define WND_MODULE     "wnd_module"
#define WND_UNKNOWN    "wnd_unknown"
#define WND_SIDEBAR    "wnd_sidebar"

// identificadores de painel
#define PANEL_MODULE    "panel_module"
#define PANEL_UNKNOWN   "panel_unknown"
#define PANEL_SIDEBAR   "panel_sidebar"

#define SIDEBAR "sidebar"

// imagens para o item de módulo
#define IMG_COL_MODULE "PCOCUBE"
#define IMG_EXP_MODULE "PCOCUBE"

// imagens para o item de processo
#define IMG_COL_PROCESS "FOLDER516"
#define IMG_EXP_PROCESS "FOLDER616"

// imagens para o item de operação
#define IMG_COL_OPERATION "FOLDER516"
#define IMG_EXP_OPERATION "FOLDER616"

// lançamentos padrão ativos
#define IMG_COL_ENTRY_DEB "DEBITO16"
#define IMG_EXP_ENTRY_DEB "DEBITO16"
#define IMG_COL_ENTRY_CRD "CREDITO16"
#define IMG_EXP_ENTRY_CRD "CREDITO16"
#define IMG_COL_ENTRY_PART_DOB "DEB_CRED16"
#define IMG_EXP_ENTRY_PART_DOB "DEB_CRED16"

// lançamentos padrão inativos
#define IMG_COL_ENTRY_DEB_PB "DEBITOPB16"
#define IMG_EXP_ENTRY_DEB_PB "DEBITOPB16"
#define IMG_COL_ENTRY_CRD_PB "CREDITOPB16"
#define IMG_EXP_ENTRY_CRD_PB "CREDITOPB16"
#define IMG_COL_ENTRY_PART_DOB_PB "DEB_CREDPB16"
#define IMG_EXP_ENTRY_PART_DOB_PB "DEB_CREDPB16"

// lançamento não encontrado
#define IMG_NO_ENTRY "BPMSRELAE"

// status
#define STATUS_UNKNOWN 0  // desconhecido
#define STATUS_CREATE  1  // incluir
#define STATUS_READ    2  // visualizar
#define STATUS_UPDATE  4  // alterar
#define STATUS_DELETE  8  // excluir
#define STATUS_REFRESH 16 // atualização

// aButtons
#define IDX_CANCEL  1
#define IDX_CONFIRM 2
#define IDX_DELETE  3
#define IDX_UPDATE  4
#define IDX_CREATE  5  

#define IDX_SB_DELETE 2
#define IDX_SB_COPY   5
#define IDX_SB_CUT    6
#define IDX_SB_PASTE  4
#define IDX_SB_CREATE 3
#define IDX_SB_REFRESH 7

// botões
#define IMG_CREATE "BMPINCLUIR"
#define IMG_READ   ""
#define IMG_UPDATE "NOTE"
#define IMG_DELETE "EXCLUIR"

#define IMG_OK     "OK"
#define IMG_CANCEL "CANCEL"

#define IMG_SEARCH "PESQUISA"

#define IMG_COPY "S4WB005N"
#define IMG_CUT   "s4wb006n"
#define IMG_PASTE "S4WB007N"      
#define IMG_REFRESH "RELOAD"

#define CLIPBOARD_COPY 1
#define CLIPBOARD_CUT  2
#define CLIPBOARD_UNKNOWN 0