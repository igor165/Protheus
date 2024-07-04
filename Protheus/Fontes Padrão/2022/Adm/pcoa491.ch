// Definições para rotinas de planejamento
// Copyright (C) 2007, Microsiga

// GetScreenRes()
#define IDX_SCREEN_WIDTH  1
#define IDX_SCREEN_HEIGHT 2

// identificadores do tipo de nó
#define NODE_TYPE_UNKNOWN    0
#define NODE_TYPE_WORKSHEET     1
#define NODE_TYPE_PRODUCT       2
#define NODE_TYPE_DISTRIBUTION  4
#define NODE_TYPE_TYPES        16 
#define NODE_TYPE_VALUES       32 
#define NODE_TYPE_UNCLASSIFIED  64

// identificadores de layout
#define LAYOUT_WORKSHEET "layout_worksheet"
#define LAYOUT_UNKNOWN   "layout_unknown"

// identificadores de janela         
#define WND_WORKSHEET  "wnd_worksheet" 
#define WND_UNKNOWN    "wnd_unknown"
#define WND_SIDEBAR    "wnd_sidebar"

// identificadores de painel
#define PANEL_WORKSHEET "panel_worksheet" 
#define PANEL_UNKNOWN   "panel_unknown"
#define PANEL_SIDEBAR   "panel_sidebar"

#define SIDEBAR "sidebar"

// imagens 
#define IMG_COL_WORKSHEET "RPMCPO"
#define IMG_EXP_WORKSHEET "RPMCPO"

#define IMG_COL_PRODUCT "PRODUTO"
#define IMG_EXP_PRODUCT "PRODUTO"

#define IMG_COL_DISTRIBUTION "CHECKED"
#define IMG_EXP_DISTRIBUTION "CHECKED"

#define IMG_COL_TYPES "BUDGET" 
#define IMG_EXP_TYPES "BUDGET"

//Lancamentos valores planejamento 
#define IMG_COL_VALUE "BTCALEND"

//Sem Valor
#define IMG_NO_ENTRY "BPMSRELAE"

// status
#define STATUS_UNKNOWN 0  // desconhecido
#define STATUS_CREATE  1  // incluir
#define STATUS_READ    2  // visualizar
#define STATUS_UPDATE  4  // alterar
#define STATUS_DELETE  8  // excluir

// aButtons
#define IDX_CANCEL   1
#define IDX_CONFIRM  2
#define IDX_DELETE   3
#define IDX_UPDATE   4
#define IDX_CREATE   5  
#define IDX_QUANTITY 6
#define IDX_VALUES   7
#define IDX_VCANCEL  8
#define IDX_VCONFIRM 9

#define IDX_SB_DELETE 2
#define IDX_SB_COPY   5
#define IDX_SB_CUT    6
#define IDX_SB_PASTE  4

// botões
#define IMG_CREATE "BMPINCLUIR"
#define IMG_READ   ""
#define IMG_UPDATE "NOTE"
#define IMG_DELETE "EXCLUIR"

#define IMG_OK     "OK"
#define IMG_CANCEL "CANCEL"

#define IMG_SEARCH "PESQUISA"

#define IMG_COPY "S4WB005N"
#define IMG_CUT
#define IMG_PASTE "S4WB007N"      

#define CLIPBOARD_COPY 1
#define CLIPBOARD_CUT  2
#define CLIPBOARD_UNKNOWN 0‰PNG